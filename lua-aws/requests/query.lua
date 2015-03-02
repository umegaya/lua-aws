local class = require ('lua-aws.class')
local Request = require ('lua-aws.requests.base')
local Serializer = require ('lua-aws.requests.query_string_serializer')
local util = require ('lua-aws.util')

return class.AWS_QueryRequest.extends(Request) {
	serialize_query = function (self, params)
		local rules = self._operation.input
		if rules then 
			rules = rules.members 
		end
		local builder = Serializer.new(self._api, rules)
		builder:serialize(self._params, function(name, value)
			params[name] = value
		end)
	end,
	build_request = function (self, req)
		local operation = self._operation
		req.path = '/'
		req.headers['Content-Type'] = 'application/x-www-form-urlencoded; charset=utf-8'
		req.headers['host'] = req.host
		req.params = {
			Version = self._api:version(),
			Action = operation.name,
		}
		req.body_has_sign = true
		-- convert the request parameters into a list of query params,
		-- e.g. Deeply.NestedParam.0.Name=value
		self:serialize_query(req.params)
		req.body = util.query_params_to_string(req.params)
		return req
	end,
	
	extract_error = function (self, resp)
		local data
		local body = resp.body;
		if body:match('<UnknownOperationException') then
			return {
				Code = 'UnknownOperation',
				Message = 'Unknown operation'
			}
		else
			data = util.xml.decode(body)
		end
		if data.Errors then data = data.Errors end
		if data.Error then data = data.Error end
		if data.Code then
			return {
				code = data.Code,
				message = data.Message
			}
		else
			return {
				code = resp.status,
				message = false
			}
		end
	end,

	extract_data = function (self, resp) 
		return util.xml.decode(resp.body)
  	end,
}
