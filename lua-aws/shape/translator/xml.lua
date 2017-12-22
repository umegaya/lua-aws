local util = require('lua-aws.util')
local Shape = require('lua-aws.shape.shape')

local _M = {}

function _M.translate(xml, shape)
    for k,v in pairs(xml.value) do
        return _M.parseXml(v.value, shape)
    end
end

function _M.parseXml(xml, shape) 
    if shape.type == 'structure' then 
        return _M.parseStructure(xml, shape)
    elseif shape.type == 'map' then
        return _M.parseMap(xml, shape)
    elseif shape.type == 'list' then 
        return _M.parseList(xml, shape)
    --case undefined: case null: return parseUnknown(xml) => really used?
    else
        return _M.parseScalar(xml, shape)
    end
end

function _M.parseStructure(xml, shape)
    local data = {}
    if not xml then return data end

    for member_name, member_shape in pairs(shape.members) do
        local xml_name = member_shape.name
        if type(xml[xml_name]) == 'table' then
            local xml_child = xml[xml_name]
            data[member_name] = _M.parseXml(xml_child, member_shape)
        elseif member_shape.isXmlAttribute then
            data[member_name] = _M.parseScalar(xml[xml_name], member_shape)
        elseif member_shape.type == "list" then
            data[member_name] = member_shape.defaultValue
        end
    end

    return data
end

function _M.parseMap(xml, shape)
    local data = {}
    if not xml then return data end

    local xmlKey = shape.key.name or 'key'
    local xmlValue = shape.value.name or 'value'
    local iterable = shape.flattened and xml or xml.entry

    if type(iterable) == 'table' and iterable[1] then
        for _, child in ipairs(iterable) do
            data[child[xmlKey][0]] = _M.parseXml(child[xmlValue][0], shape.value)
        end
    end

    return data
end

function _M.parseList(xml, shape)
    local data = {}
    local name = shape.member.name or "member"
    local iterable = shape.flattened and xml or xml[name]
    if type(iterable) == 'table' and iterable[1] then
        for _, child in ipairs(iterable) do
            table.insert(data, _M.parseXml(child.value, shape.member))
        end
    end

    return data
end

function _M.parseScalar(text, shape)
    if text and text["encoding"] == "base64" then
        local shape = Shape:new{type=text["encoding"]}
    end
    if text and text["value"] then
        text = text["value"]
    elseif text and text["xarg"] then
        return nil
    end
    if shape.toType then
        return shape:toType(text)
    else
        return text
    end
end

--[[
function parseUnknown(xml) {
  if (xml === undefined || xml === null) return '';
  if (typeof xml === 'string') return xml;

  // parse a list
  if (Array.isArray(xml)) {
    var arr = [];
    for (i = 0; i < xml.length; i++) {
      arr.push(translate(xml[i], {}));
    }
    return arr;
  }

  // empty object
  var keys = Object.keys(xml), i;
  if (keys.length === 0 || keys === ['$']) {
    return {};
  }

  // object, parse as structure
  var data = {};
  for (i = 0; i < keys.length; i++) {
    var key = keys[i], value = xml[key];
    if (key === '$') continue;
    if (value.length > 1) { // this member is a list
      data[key] = parseList(value, {member: {}});
    } else { // this member is a single item
      data[key] = translate(value[0], {});
    }
  }
  return data;
}
]]

return _M
