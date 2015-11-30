local util = require('lua-aws.util')
local Shape = require('lua-aws.shape.shape')

local _M = {}

function _M.translate(xml, shape) 
    if shape.type == 'structure' then 
        return _M.parseStructure(xml, shape)
    elseif shape.type == 'map' then
        return _M.parseMap(xml, shape)
    elseif shape.type == 'list' then 
        return _M.parseList(xml, shape)
    --case undefined: case null: return parseUnknown(xml)
    else
        return _M.parseScalar(xml, shape)
    end
end

function _M.parseStructure(xml, shape)
    local data = {}
    if not xml then return data end

    for memberName, memberShape in pairs(shape.members) do
        local xmlName = memberShape.name;
        if xml[xmlName] and type(xml[xmlName]) == 'table' and xml[xmlName][1] then
            local xmlChild = xml[xmlName];
            if not memberShape.flattened then xmlChild = xmlChild[1] end
            data[memberName] = _M.translate(xmlChild, memberShape)
        -- TOOD : what is $? now $ translate to [1]
        elseif memberShape.isXmlAttribute and xml[1] and xml[1][xmlName] then
            data[memberName] = _M.parseScalar(xml[1][xmlName], memberShape)
        elseif memberShape.type == 'list' then
            data[memberName] = memberShape.defaultValue
        end
    end

    return data;
end

function _M.parseMap(xml, shape)
    local data = {}
    if not xml then return data end

    local xmlKey = shape.key.name or 'key';
    local xmlValue = shape.value.name or 'value';
    local iterable = shape.flattened and xml or xml.entry;

    if type(iterable) == 'table' and iterable[1] then
        for _, child in ipairs(iterable) do
            data[child[xmlKey][0]] = _M.translate(child[xmlValue][0], shape.value);
        end
    end

    return data;
end

function _M.parseList(xml, shape)
    local data = {}
    local name = shape.member.name or 'member'
    if shape.flattened then
        for _, xmlChild in ipairs(xml) do
            table.insert(data, _M.translate(xmlChild, shape.member))
        end
    elseif xml and type(xml[name]) == 'table' and xml[name][1] then
        for _, child in ipairs(xml[name]) do
            table.insert(data, _M.translate(child, shape.member))
        end
    end

    return data;
end

function parseScalar(text, shape)
    if text and text[1] and text[1].encoding == 'base64' then
        shape = Shape.create({["type"] = 'base64'})
    end
    if text and text._ then text = text._ end

    if shape.toType then
        return shape.toType(text)
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
