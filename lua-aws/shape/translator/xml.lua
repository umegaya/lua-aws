local util = require('lua-aws.util')
local Shape = require('lua-aws.shape.shape')

local _M = {}

function _M.translate(xml, shape)
    for k,v in pairs(xml.value) do
        -- each k should be XXXResult, and v.value should be table of shape member key => xml node of corresponding values
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
        return _M.parseScalar(xml.value, shape)
    end
end

-- here, xml means table which has string key and xml node value.
function _M.parseStructure(xml, shape)
    local data = {}
    if not xml then return data end

    for memberName, memberShape in pairs(shape.members) do
        local child = xml[memberName]
        if child then
            -- print('parse child:', memberName, child.value, memberShape.type)
            data[memberName] = _M.parseXml(child, memberShape)
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
            data[child[xmlKey][0]] = _M.parseXml(child[xmlValue][0], shape.value);
        end
    end

    return data;
end

-- here, xml means table which is: 
--  1. array of xml node (when flattened and number of element > 1), 
--  2. xml node which value contains array of xml node whose key is shape.member.name (non-flattened)
function _M.parseList(xml, shape)
    local data = {}
    local iterable
    if shape.flattened then
        -- if flattened, xml is array of node
        iterable = xml
    else
        local name = shape.member.name
        -- regardless element count is 1 or more, value contains proper table structure.
        iterable = xml.value[name]
    end
    if not iterable[1] then
        -- if only single element, xml directly be node.
        table.insert(data, _M.parseXml(iterable.value, shape.member))
        return data
    else 
        for _, child in ipairs(iterable) do
            table.insert(data, _M.parseXml(child.value, shape.member))
        end
    end
--[[
    local data = {}
    local name = shape.member.name
    local iterable = shape.flattened and xml or xml[name]
    if type(iterable) == 'table' and iterable[1] then
        for _, child in ipairs(iterable) do
            table.insert(data, _M.parseXml(child.value, shape.member))
        end
    end
]]

    return data;
end

function _M.parseScalar(text, shape)
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
