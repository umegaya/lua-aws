local util = require('lua-aws.util');
local builder = require('lua-aws.deps.xmlbuilder');

local _M = {}

function _M.build(params, shape, rootElement, noEmpty)
    local xml = builder.create(rootElement)
    _M.applyNamespaces(xml, shape)
    _M.serialize(xml, params, shape)
    return (#xml > 0 or noEmpty) and builder.dump(xml) or ''
end

function _M.serialize(xml, value, shape)
    if shape.type == 'structure' then 
        return _M.serializeStructure(xml, value, shape)
    elseif shape.type == 'map' then
        return _M.serializeMap(xml, value, shape)
    elseif shape.type == 'list' then
        return _M.serializeList(xml, value, shape)
    else
        return _M.serializeScalar(xml, value, shape);
    end
end

function _M.serializeStructure(xml, params, shape) 
    for _, memberName in ipairs(shape.member_names) do
        local memberShape = shape.members[memberName]
        if memberShape.location == 'body' then
            local value = params[memberName]
            local name = memberShape.name
            if value then
                if memberShape.isXmlAttribute then
                    xml.att(name, value);
                elseif memberShape.flattened then
                    _M.serialize(xml, value, memberShape)
                else
                    local element = xml.ele(name)
                    _M.applyNamespaces(element, memberShape)
                    _M.serialize(element, value, memberShape)
                end
            end
        end
    end
end

function _M.serializeMap(xml, map, shape)
    local xmlKey = shape.key.name or 'key';
    local xmlValue = shape.value.name or 'value';

    for key, value in pairs(map) do
        local entry = xml.ele(shape.flattened and shape.name or 'entry');
        _M.serialize(entry.ele(xmlKey), key, shape.key);
        _M.serialize(entry.ele(xmlValue), value, shape.value);
    end
end

function _M.serializeList(xml, list, shape)
    if shape.flattened then
        for _, value in ipairs(list) do
            local name = shape.member.name or shape.name;
            local element = xml.ele(name);
            _M.serialize(element, value, shape.member);
        end
    else
        for _, value in ipairs(list) do
            local name = shape.member.name or 'member';
            local element = xml.ele(name);
            _M.serialize(element, value, shape.member);
        end
    end
end

function _M.serializeScalar(xml, value, shape)
    xml.txt(shape:toWireFormat(value))
end

function _M.applyNamespaces(xml, shape)
    local uri, prefix = nil, 'xmlns'
    if shape.xmlNamespaceUri then
        uri = shape.xmlNamespaceUri
    end
    if shape.xmlNamespacePrefix then 
        prefix = prefix .. ':' .. shape.xmlNamespacePrefix;
    elseif xml.isRoot and shape.api.xmlNamespaceUri then
        uri = shape.api.xmlNamespaceUri
    end
    if uri then
        xml.att(prefix, uri)
    end
end

return _M
