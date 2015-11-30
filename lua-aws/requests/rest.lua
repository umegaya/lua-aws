local _M = {}

local function populateMethod(req, reqdata)
    reqdata.method = req:httpMethod();
end

local function populateURI(req, reqdata)
    local input = req:input_format()
    local uri = table.concat({req:httpPath(), reqdata.path}, '/')
    uri = uri:gsub("%/+", "/")

    local queryString, queryStringSet = {}, false
    for name, member in pairs(input.members or {}) do
        local paramValue = reqdata.params[name];
        if paramValue then
            if member.location == 'uri' then
                local regex = '{' .. member.name .. '(%+?)}'
                uri = uri:gsub(regex, function(_, plus) 
                    local fn = (plus and #plus > 0) and util.uriEscapePath or util.uriEscape;
                    return fn(tostring(paramValue));
                end)
            elseif member.location == 'querystring' then
                queryStringSet = true;
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

    reqdata.path = uri
end

local function populateHeaders(req, reqdata)
    local input = req:input_format()
    for name, member in pairs(input.members) do
        local value = req.params[name];
        if value then
            if member.location == 'headers' and member.type == 'map' then
                for key, memberValue in pairs(value) do
                    reqdata.headers[member.name .. key] = memberValue;
                end
            elseif member.location == 'header' then
                value = member:toWireFormat(value).toString()
                reqdata.headers[member.name] = value
            end
        end
    end
end

-- build request header. 
-- request body is built in subclass (rest_xml, rest_json)
function _M.build_request(req, reqdata)
    populateMethod(req, reqdata)
    populateURI(req, reqdata)
    populateHeaders(req, reqdata)
end

function _M.extract_error(req, resp)

end

-- extract data from header, status code. 
-- body data extraction is implemented in subclass (rest_xml, rest_json)
function _M.extract_data(req, resp)
    local data = {}
    local output = req:output_format()

    -- normalize headers names to lower-cased keys for matching
    local headers = {}
    for k, v in pairs(resp.headers) do
        headers[k:lower()] = v
    end

    for name, member in pairs(output.members or {}) do
        local header = (member.name or name):lower()
        if member.location == 'headers' and member.type == 'map' then
            data[name] = {}
            local location = member.isLocationName and member.name or ''
            local pattern = '^' + location + '(.+)'
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
end

return _M
