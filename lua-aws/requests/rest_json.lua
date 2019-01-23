local class = require ('lua-aws.class')
local RestRequest = require ('lua-aws.requests.rest')
local JsonRequest = require ('lua-aws.requests.json')
local util = require ('lua-aws.util')
local builder = require ('lua-aws.shape.builder.json')
local translator = require ('lua-aws.shape.translator.json')

return class.AWS_JsonRestRequest.extends(RestRequest) {
    populate_body = function (self, req, params)
        local input = self:input_format()

        local payload = input.payload;
        if payload then
            local payload_shape = input.members[payload];
            local payload_param = params[payload]
            if not payload_param then
                req.headers["Content-Length"] = 0
                return
            end
            if payload_shape.type == "structure" then
                req.body = builder.build(self._api:json(), payload_param, payload_shape)
                self:apply_content_type_header(req)
                req.headers["Content-Length"] = #req.body
            else -- non-JSON payload
                req.body = payload_param
                if payload_shape.type == "binary" or payload_shape.isStreaming then
                  self:apply_content_type_header(req, true)
                else
                  req.headers["Content-Length"] = #req.body
                end
            end
        else
            req.body = builder.build(self._api:json(), params, input)
            self:apply_content_type_header(req)
            req.headers["Content-Length"] = #req.body
        end
    end,
    apply_content_type_header = function(self, req, is_binary)
        if not req.headers["Content-Type"] then
          local type_
          if is_binary then
            type_ = "binary/octet-stream"
          else
            type_ = "application/json"
          end
          req.headers["Content-Type"] = type_
        end
    end,
    build_request = function (self, req, params)
        RestRequest.build_request(self, req, params)
        -- never send body payload on GET/HEAD/DELETE
        local m = req.method:upper()
        if m ~= 'GET' and m ~= 'HEAD' and m ~= 'DELETE' then
            self:populate_body(req, params)
        else
            req.headers["Content-Length"] = 0
        end
        return req
    end,
    extract_error = function (self, resp)
      return JsonRequest.extract_error(self, resp)
    end,
    extract_data = function (self, resp)
        local data = RestRequest.extract_data(self, resp)

        local req = self;
        local rules = self:output_format()

        local payload = rules.payload;
        if payload then
            local payload_member = rules.members[payload]
            local body = resp.body;
            if payload_member.type == 'structure' or payload_member.type == 'list' then
                data[payload] = translator.translate(body, payload_member);
            else
                data[payload] = body
            end
        else
            local json_data = JsonRequest.extract_data(self, resp)
            util.merge_table(data, json_data)
        end
        return data
    end,
}
