local class = require ('lua-aws.class')
local RestRequest = require ('lua-aws.requests.rest')
local util = require ('lua-aws.util')
local builder = require ('lua-aws.shape.builder.xml')
local translator = require ('lua-aws.shape.translator.xml')

return class.AWS_XmlRestRequest.extends(RestRequest) {
    populate_body = function (self, req, params)
        local input = self:input_format()

        local payload = input.payload;
        if payload then
            local payload_member = input.members[payload];
            local payload_param = params[payload]
            if not payload_param then return end
            if payload_member.isStreaming and io.type(payload_param) == 'file' then
                if io.type(req.body) then
                    error('only 1 file payload can be attached to request')
                end
                req.body = payload_param
            elseif payload_member.type == 'structure' then
                local root_element = payload_member.name
                req.body = builder.build(payload_param, payload_member, root_element, true)
            else -- non-xml payload
                req.body = payload_member:toWireFormat(payload_param)
            end
        else
            local m = self:method_name()
            local ucfirst_op = m:sub(1, 1):upper()..m:sub(2)
            req.body = builder.build(params, input, input.name or input.shape or (ucfirst_op .. 'Request'))
        end
    end,
    build_request = function (self, req, params)
        RestRequest.build_request(self, req, params)
        -- never send body payload on GET/HEAD
        local m = req.method:upper()
        if m ~= 'GET' and m ~= 'HEAD' then
            self:populate_body(req, params)
        end
        return req
    end,
    extract_error = function (self, resp)
        RestRequest.extract_error(self, resp)
        local data
        if type(resp.body) == 'string' then
            data = util.xml.decode(resp.body)
            if data.Errors then 
                data = data.Errors
            end
            if data.Error then 
                data = data.Error
            end
        end
        if data and data.Code then
            return {
                code = data.Code,
                message = data.Message
            }
        else
            return {
                code = resp.status,
                message = nil
            }
        end
    end,
    extract_data = function (self, resp) 
        local data = RestRequest.extract_data(self, resp)

        local req = self;
        local body = resp.body;
        local output = self:output_format()

        local payload = output.payload;
        if payload then
            local payload_member = output.members[payload]
            if payload_member.isStreaming then
                data[payload] = body
            elseif payload_member.type == 'structure' then
                data[payload] = translator.translate(util.xml.decode(body), payload_member);
            else
                data[payload] = body
            end
        elseif #body > 0 then
            local dec = util.xml.decode(body)
            local body_data = translator.translate(dec, output);
            util.merge_table(data, body_data)
        end
        return data
    end,
}
