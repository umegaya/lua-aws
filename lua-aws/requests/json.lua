local class = require ('lua-aws.class')
local Request = require ('lua-aws.requests.base')
local Serializer = require ('lua-aws.requests.query_string_serializer')
local util = require ('lua-aws.util')

return class.AWS_JsonRequest.extends(Request) {
	build_request = function (self, req)
		local operation = self._operation
		local api = self._api
		local target = api:target_prefix()..'.'..operation.name
		local version = api:json_version()

		req.path = '/'
		req.headers['Content-Type'] = 'application/x-amz-json-'..version
		req.headers['X-Amz-Target'] = target
		req.headers['host'] = req.host
		req.body = api:json().encode(self._params)
		return req
	end,
	
	extract_error = function (self, resp)
		local err = {}
		if #resp.body > 0 then
			local e = self._api:json().decode(resp.body)
			if e.__type or e.code then
				err.code = (util.split(e.__type or e.code, '#'))[1]
			else
				err.code = 'UnknownError'
			end
			if err.code == 'RequestEntityTooLarge' then
				err.message = 'Request body must be less than 1 MB'
			else
				err.message = e.message or e.Message
			end
		else
			err.code = resp.status
		end
		return err
	end,

	extract_data = function (self, resp) 
		return #resp.body > 0 and self._api:json().decode(resp.body) or {}
  	end,
}
