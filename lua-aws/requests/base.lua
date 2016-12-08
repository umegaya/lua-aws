local class = require ('lua-aws.class')
local util = require ('lua-aws.util')
local AWS = require ('lua-aws.core')
local Signer = require ('lua-aws.signer')
local EndPoint = require ('lua-aws.requests.endpoint')
local Shape = require('lua-aws.shape.shape')

return class.AWS_Request {
	initialize = function (self, api, method, operation)
		self._operation = operation
		self._api = api
		self._method = method
		self._input, self._output = false, false
		local s_version = api:signature_version()
		assert(Signer[s_version], "signer not implement:"..s_version)
		self._signer = Signer[s_version].new(api)
	end,
	send = function (self, params, resp)
		assert(params)
                local cfg = self._api:config()
		local req = self:base_build_request()
                local params_for_sign
		req, params_for_sign = self:build_request(req, params)
		self:validate(req)
		local ts = self._api:signature_timestamp()
		-- if params_for_sign is specified, use it as signature parameter.
		req.params = params_for_sign or params
                req.config = cfg

		self._signer:sign(req, cfg, ts)
		req.params = nil

                local errmsg
		resp, errmsg = self._api:http_request(req, resp)

                if resp == nil then  -- The HTTP request didn't even connect
                  return false, {
                    code = "HttpEngineError",
	            message = errmsg
                  }
		-- aws sometimes returns 2xx codes other than 200. (eg. 204 No Content)
                elseif (resp.status >= 200 and resp.status < 300) then
			return true, self:extract_data(resp)
		else
			self._api:log("lua-aws detected AWS error response:", resp.status, resp.body)
			return false, self:extract_error(resp)
		end
	end,
	method_name = function (self)
		return self._method
	end,
	httpPath = function (self)
		return self._operation.http.requestUri or '/'
	end,
	httpMethod = function (self)
		return self._operation.http.method or 'POST'
	end,
	input_format = function (self)
		-- TODO: now assume all input shape is structure shape, decide we should get rid of this assumption.
		if not self._input then
			self._api:init_shapes()
			self._input = Shape.create(self._operation.input or {["type"] = 'structure'}, { api = self._api }) -- lazy shape creation
		end
		return self._input
	end,
	output_format = function (self)
		-- TODO: now assume all output shape is structure shape, decide we should get rid of this assumption.
		if not self._output then
			self._api:init_shapes()
			self._output = Shape.create(self._operation.output or {["type"] = 'structure'}, { api = self._api }) -- lazy shape creation
		end
		return self._output
	end,
	validate_region = function (self, req)
	end,
	validate_parameter = function (self, req)
		-- local input = self:input_format()
	end,
	validate = function (self, req)
		self:validate_region(req)
		self:validate_parameter(req)
		return true
	end,
	base_build_request = function (self)
		local endpoint = EndPoint.new(self._api:endpoint(), self._api:config())
		local req = {
			path = endpoint:path(),
			headers = {},
			body = '',
			host = endpoint:host(),
			port = endpoint:port(),
			protocol = endpoint:protocol(),
			region = self._api:region(),
			method = 'POST'
		}
		req.headers['User-Agent'] = util.user_agent()
		return req
	end,


	--[[
		local req = {
			path = endpoint:path(),
			headers = {},
			body = '',
			host = endpoint:host(),
			port = endpoint:port(),
			protocol = endpoint:protocol(),
			method = string
		}
		params is table

		should return resulting req object and (if params is modified internally) this modified params
	]]--
	build_request = function (self, req, params)
		assert(false)
	end,
	--[[
		resp is table {
			status = number,
			headers = table,
			body = string,
		}
		returns lua table (any format)
	]]--
	extract_data = function (self, resp)
		assert(false)
	end,
	--[[
		resp is table {
			status = number,
			headers = table,
			body = string,
		}
		returns lua table {
			code = mixed,
			message = string,
		}
	]]--
	extract_error = function (self, resp)
		assert(false)
	end,
}
