local class = require ('lua-aws.class')
local Signer = require ('lua-aws.signers.base')
local util = require ('lua-aws.util')
local sec_cache = {}
--[[
  When building the stringToSign, these sub resource params should be
  part of the canonical resource string with their NON-decoded values
]]
local subResources = {
    acl = 1,
    cors = 1,
    lifecycle = 1,
    delete = 1,
    location = 1,
    logging = 1,
    notification = 1,
    partNumber = 1,
    policy = 1,
    requestPayment = 1,
    restore = 1,
    tagging = 1,
    torrent = 1,
    uploadId = 1,
    uploads = 1,
    versionId = 1,
    versioning = 1,
    versions = 1,
    website = 1,
}
--[[
  when building the stringToSign, these querystring params should be
  part of the canonical resource string with their NON-encoded values
]]
local responseHeaders = {
    ['response-content-type'] = 1,
    ['response-content-language'] = 1,
    ['response-expires'] = 1,
    ['response-cache-control'] = 1,
    ['response-content-disposition'] = 1,
    ['response-content-encoding'] = 1
}

return class.AWS_S3Signer.extends(Signer) {
    initialize = function (self, api)
        self._api = api
    end,
    sign = function (self, req, credentials, timestamp)
        self:add_authorization(req, credentials, timestamp)
    end,
    add_authorization = function (self, req, credentials, date)
        if not req.headers['presigned-expires'] then
            req.headers['X-Amz-Date'] = date;
        end

        if credentials.sessionToken then
            -- presigned URLs require this header to be lowercased
            req.headers['x-amz-security-token'] = credentials.sessionToken;
        end

        local signature = self:signature(credentials.secretAccessKey, self:string_to_sign(req));
        local auth = 'AWS ' .. credentials.accessKeyId .. ':' .. signature;

        req.headers['Authorization'] = auth;
    end,
    string_to_sign = function (self, req)
        local parts = {};
        table.insert(parts, req.method)
        table.insert(parts, req.headers['Content-MD5'] or '')
        table.insert(parts, req.headers['Content-Type'] or '')

        -- This is the "Date" header, but we use X-Amz-Date.
        -- The S3 signing mechanism requires us to pass an empty
        -- string for this Date header regardless.
        table.insert(parts, req.headers['presigned-expires'] or '');

        local headers = self:canonicalizedAmzHeaders(req);
        if headers then
            table.insert(parts, headers)
        end
        table.insert(parts, self:canonicalizedResource(req))

        return table.concat(parts, '\n')
    end,
    signature = function (self, secret, str) 
        return util.hmac(secret, str, 'base64');
    end,
    canonicalizedAmzHeaders = function (self, req) 
        local amzHeaders = {};

        for name, _ in pairs(req.headers) do
            if name:match("^x-amz-") then
                table.insert(amzHeaders, name)
            end
        end

        table.sort(amzHeaders, function (a, b)
            return a:lower() < b:lower() and -1 or 1
        end)

        local parts = {};
        for _, name in ipairs(amzHeaders) do
            table.insert(parts, name:lower() .. ':' .. tostring(req.headers[name]))
        end

        return table.concat(parts, '\n')
    end,
    canonicalizedResource = function (self, req) 
        local parts = util.split(req.path, '?');
        local path = parts[1];
        local querystring = parts[2];

        local resource = '';
        if req.virtualHostedBucket then
            resource = resource .. '/' .. req.virtualHostedBucket;
        end
        resource = resource..path;

        if querystring then
            -- collect a list of sub resources and query params that need to be signed
            local resources = {};
            for _, kv in ipairs(util.split(querystring, '&')) do
                local name, value = unpack(util.split(kv, '='))
                if subResources[name] or responseHeaders[name] then
                    local subresource = { name = name }
                    if value then
                        if subResources[name] then
                            subresource.value = value
                        end
                    else
                        subresource.value = util.decodeURI(value);
                    end
                end
                table.insert(resources, subresource)
            end

            table.sort(resources, function (a, b) return a.name < b.name and -1 or 1 end)
            if #resources > 0 then
                local querystrings = {};
                for _, res in ipairs(resources) do
                    if not res.value then
                        table.insert(querystrings, res.name);
                    else
                        table.insert(querystrings, res.name + '=' + res.value);
                    end
                end
                resource = (resource .. '?' .. table.concat(querystring, '&'))
            end
        end
        return resource
    end,
}
