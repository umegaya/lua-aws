local class = require ('lua-aws.class')
local Request = require ('lua-aws.requests.base')
local util = require ('lua-aws.util')

return class.AWS_RestRequest.extends(Request) {
    populate_method = function (self, req, params)
        req.method = self:httpMethod();
    end,

    populate_uri = function (self, req, params)
        local input = self:input_format()
        local uri = table.concat({req.path, self:httpPath()}, '/')
        uri = uri:gsub("%/+", "/")

        local queryString, queryStringSet = {}, false
        for name, member in pairs(input.members) do
            local paramValue = params[name];
            if paramValue then
                if member.location == 'uri' then
                    local regex = '{' .. member.name .. '(%+?)}'
                    uri = uri:gsub(regex, function(_, plus) 
                        local fn = (plus and #plus > 0) and util.encodeURIPath or util.encodeURI;
                        return fn(tostring(paramValue));
                    end)
                elseif member.location == 'querystring' then
                    queryStringSet = true
                    if member.type == 'list' then
                        queryString[member.name] = {}
                        for _, val in ipairs(paramValue) do
                            table.insert(queryString[member.name], util.uriEscape(val))
                        end
                    else
                        queryString[member.name] = util.uriEscape(tostring(paramValue));
                    end
                end
            end
        end

        if queryStringSet then
            uri = (uri..(uri:find('?') and '&' or '?'))
            local parts = {}
            local tmp = {}
            for k, _ in pairs(queryString) do
                table.insert(tmp, k)
            end
            table.sort(tmp)
            for _, k in ipairs(tmp) do
                if type(queryString[k]) ~= 'table' then
                    queryString[key] = {queryString[key]}
                end
                for _, v in ipairs(queryString[key]) do 
                    table.insert(parts, util.uriEscape(tostring(key)) .. '=' .. v);
                end
            end
            uri = uri .. table.concat(parts, '&');
        end

        req.path = uri
    end,

    populate_headers = function (self, req, params)
        local input = self:input_format()
        for name, member in pairs(input.members) do
            local value = params[name];
            if value then
                if member.location == 'headers' and member.type == 'map' then
                    for key, memberValue in pairs(value) do
                        req.headers[member.name .. key] = memberValue;
                    end
                elseif member.location == 'header' then
                    value = member:toWireFormat(value)
                    req.headers[member.name] = value
                end
            end
        end
    end,

    build_request = function (self, req, params)
        self:populate_method(req, params)
        self:populate_uri(req, params)
        self:populate_headers(req, params)
        return req
    end,

    extract_error = function (self, resp)
    end,

    extract_data = function (self, resp) 
        local data = {}
        local output = self:output_format()

        -- normalize headers names to lower-cased keys for matching
        local headers = {}
        for k, v in pairs(resp.headers) do
            headers[k:lower()] = v
        end

        for name, member in pairs(output.members) do
            local header = (member.name or name):lower()
            if member.location == 'headers' and member.type == 'map' then
                data[name] = {}
                local location = member.isLocationName and member.name or ''
                local pattern = '^' .. location .. '(.+)'
                for kk, vv in pairs(resp.headers) do
                    local result = kk:match(pattern)
                    if result then
                        data[name][result] = vv;
                    end
                end
            elseif member.location == 'header' then
                if headers[header] then
                    data[name] = headers[header]
                end
            elseif member.location == 'statusCode' then
                data[name] = tonumber(r.status)
            end
        end
        return data
    end,
}
