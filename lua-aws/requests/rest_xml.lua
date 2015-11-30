local class = require ('lua-aws.class')
local Request = require ('lua-aws.requests.base')
local Serializer = require ('lua-aws.requests.query_string_serializer')
local util = require ('lua-aws.util')
local rest = require ('lua-aws.requests.rest')
local builder = require ('lua-aws.shape.builder.xml')
local translator = require ('lua-aws.shape.translator.xml')

local function populateBody(req, reqdata)
    local input = req:input_format()
    local params = reqdata.params

    local payload = input.payload;
    if payload then
        local payload_member = input.members[payload];
        params = params[payload];
        if not params then return end

        if payload_member.type == 'structure' then
            local root_element = payload_member.name
            req.body = builder.build(params, payload_member, root_element, true)
        else -- non-xml payload
            req.body = payload_member:toWireFormat(params)
        end
    else
        local m = req:method_name()
        local ucfirst_op = m:sub(1, 1):upper()..m:sub(2)
        for k,v in pairs(getmetatable(input)) do
            print(k, v)
        end
        req.body = builder.build(params, input, input.name or input.shape or (ucfirst_op .. 'Request'))
    end
end

return class.AWS_XmlRestRequest.extends(Request) {
    build_request = function (self, req)
        rest.build_request(self, req)
        -- never send body payload on GET/HEAD
        local m = req.method:upper()
        if m == 'GET' or m == 'HEAD' then
            populateBody(self, req)
        end
        return req
    end,
    extract_error = function (self, resp)
        rest.extract_error(self, resp)

        local data = util.xml.decode(resp.body)
        if data.Errors then 
            data = data.Errors
        end
        if data.Error then 
            data = data.Error
        end
        if data.Code then
            resp.error = {
                code = data.Code,
                message = data.Message
            }
        else
            resp.error = {
                code = resp.status,
                message = nil
            }
        end
    end,
    extract_data = function (self, resp) 
        rest.extract_data(self, resp)

        local req = self;
        local body = resp.body;
        local output = self:output_format()

        local payload = output.payload;
        if payload then
            local payload_member = output.members[payload]
            if payload_member.isStreaming then
                resp.data[payload] = body
            elseif payload_member.type == 'structure' then
                resp.data[payload] = translator.translate(util.xml.decode(body), payload_member);
            else
                resp.data[payload] = body
            end
        elseif #body.length > 0 then
            resp.data[payload] = translator.translate(util.xml.decode(body), output);
            util.merge_table(resp.data, data)
        end
    end,
}
