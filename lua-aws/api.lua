local class = require ('lua-aws.class')
local util = require ('lua-aws.util')
local Request = require ('lua-aws.request')

local get_endpoint_from_env = function ()
	local ec2url = os.getenv('EC2_URL')
	if not ec2url then
 		error('neither config.endpoint given nor EC2_URL environment set.')
	else
		return ec2url:gsub('https?://ec2%.', '')
	end
end
local get_region_from_env = function ()
	local ec2url = os.getenv('EC2_URL')
	if not ec2url then
		error('neither config.region given nor EC2_URL environment set.')
	else
		local region = false
		ec2url:gsub('https?://ec2%.(.*)%.amazonaws.com.*', function (s)
			region = s
		end)
		return region
	end
end

return class.AWS_API {
	initialize = function (self, service, defs)
		self._service = service
		self._defs = defs
		self:build_methods()
	end,
	version = function (self)
		return self._defs.metadata.apiVersion
	end,
	signature_version = function (self)
		return self._defs.metadata.signatureVersion
	end,
	signature_name = function (self)
		return self._defs.metadata.signingName or self:endpoint_prefix()
	end,
	endpoint_prefix = function (self)
		return self._defs.metadata.endpointPrefix
	end,
	target_prefix = function (self)
		return self._defs.metadata.targetPrefix
	end,
	json_version = function (self)
		return self._defs.metadata.jsonVersion or "1.0"
	end,
	endpoint = function (self)
		local config = self:config()
		local endpoint = (config.endpoint or get_endpoint_from_env())
		return (self:endpoint_prefix() .. '.' .. endpoint)
	end,
	region = function (self)
		return self:config().region or get_region_from_env()
	end,
	request_protocol = function (self)
		return self._defs.metadata.protocol
	end,
	default_signature_timestamp_format = function (self)
		local v = self:signature_version()
		if v == 'v4' or v == 'v2' then
			return 'iso8601'
		elseif v == 'v3' or v == 's3' then
			return 'rfc822'
		else
			assert(false, "invalid signature version:"..v)
		end
	end,
	signature_timestamp_format = function (self)
		return self._defs.metadata.timestampFormat or self:default_signature_timestamp_format()
	end,
	signature_timestamp = function (self)
		local tsf = self:signature_timestamp_format()
		return util.date[tsf]()
	end,
	config = function (self)
		return self._service:aws():config()
	end,
	http_request = function (self, req)
		return self._service:aws():http_request(req)
	end,
	json = function (self)
		return self._service:aws():json()
	end,
	log = function (self, ...)
		self._service:aws():api_log(self, ...)
	end,
	build_methods = function (self)
		local defs = self._defs
		for method,operation in pairs(defs.operations) do
			self[method] = function (API, param)
				local ok, status_or_err, r = pcall(function ()
					local req = Request[API:request_protocol()].new(API, method, operation, param)
					return req:send()
				end)
				if not ok then
					API:log(method .. ':error:' .. status_or_err)
					return false,status_or_err
				end
				if API:config().oldReturnValue then
					return r
				else
					return status_or_err,r
				end
			end
			-- for backward compatibility, we create entry with old api function name
			local old_method = method:sub(1, 1):lower()..method:sub(2)
			if old_method ~= method then
				self[old_method] = self[method]
			end
		end
	end,
}
