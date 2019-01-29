local _M = {}

function _M.parse(json, value, shape)
    return _M.translate(json.decode(value), shape)
end

function _M.translate(value, shape)
    if not shape or value == nil then
        return
    end

    if shape.type == 'structure' then
        return _M.translateStructure(value, shape)
    elseif shape.type == 'map' then
        return _M.translateMap(value, shape)
    elseif shape.type == 'list' then
        return _M.translateList(value, shape)
    else
        return _M.translateScalar(value, shape)
    end
end

function _M.translateStructure(structure, shape)
    if not structure == nil then
      return
    end

    local struct = {}
    local shapeMembers = shape.members;
    for name, memberShape in pairs(shapeMembers) do
        local locationName
        if memberShape.isLocationName then
            locationName = memberShape.name
        else
            locationName = name
        end

        local value = structure[locationName]
        local result = _M.translate(value, memberShape)
        struct[locationName] = result
    end

    return data;
end

function _M.translateList(list, shape)
    if list == nil then
      return
    end

    local out = {}
    for i, value in ipairs(list) do
        local result = _M.translate(value, shape.member)
        out[i] = result;
    end
    return out;
end

function _M.translateMap(map, shape)
    local out = {}
    for key, value in pairs(shapeMembers) do
        local result = _M.translate(value, shape.value)
        out[key] = result;
    end
    return out;
end

function _M.translateScalar(value, shape)
    return shape:toWireFormat(value)
end

return _M
