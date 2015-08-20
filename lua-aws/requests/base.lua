local class = require ('lua-aws.class')
local util = require ('lua-aws.util')
local AWS = require ('lua-aws.core')
local Signer = require ('lua-aws.signer')
local EndPoint = require ('lua-aws.requests.endpoint')

return class.AWS_Request {
	initialize = function (self, api, method, operation, params)
		self._operation = operation
		self._params = params or {}
		self._api = api
		self._method = method
		local s_version = api:signature_version()
		assert(Signer[s_version], "signer not implement:"..s_version)
		self._signer = Signer[s_version].new(api)
	end,
	send = function (self)
		local req = self:base_build_request()
		self:build_request(req)
		self:validate(req)
		local ts = self._api:signature_timestamp()
		self._signer:sign(req, self._api:config(), ts)
		local resp = self._api:http_request(req)
		if resp.status == 200 then
			return true, self:extract_data(resp)
		else
			self._api:log("Something wrong in the request", resp.status, resp.body)
			return false, self:extract_error(resp)
		end
	end,
	method_name = function (self)
		return self._method
	end,
	validate_region = function (self, req)
	end,
	validate_parameter = function (self, rules, params)
	end,
	validate = function (self, req)
		self:validate_region(req)
		self:validate_parameter(self._operation.input, req.params)
		return true
	end,
	base_build_request = function (self)
		local endpoint = EndPoint.new(self._api:endpoint(), self._api:config())
		local req = {
			path = endpoint:path(),
			headers = {},
			params = {},
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
			params = {},
			body = '',
			host = endpoint:host(),
			port = endpoint:port(),
			protocol = endpoint:protocol(),
			method = string
		}
	]]--
	build_request = function (self)
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
