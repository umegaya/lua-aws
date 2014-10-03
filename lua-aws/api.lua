local class = require ('lua-aws.class')
local util = require ('lua-aws.util')
local Request = require ('lua-aws.request')

local p
do
  local _obj_0 = require("moon")
  p = _obj_0.p
end

local get_endpoint_from_env = function ()
	local ec2url = os.getenv('EC2_URL')
	if not ec2url then
		return nil
	else
		return ec2url:gsub('https://ec2%.', '')
	end
end
local get_region_from_env = function ()
	local ec2url = os.getenv('EC2_URL')
	if not ec2url then
		return nil
	else
		local region = false
		ec2url:gsub('https://ec2%.(.*)%.amazonaws.com.*', function (s)
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
		return self._defs.apiVersion
	end,
	signature_version = function (self)
		return self._defs.signatureVersion
	end,
	endpoint_prefix = function (self)
		return self._defs.endpointPrefix
	end,
	endpoint = function (self)
		local config = self:config()
    local endpoint = (config.endpoint or get_endpoint_from_env())

		return (self:endpoint_prefix() .. '.' .. endpoint)
	end,
	region = function (self)
		return self:config().region or get_region_from_env()
	end,
	request_format = function (self)
		return self._defs.format
	end,
	timestamp_format = function (self)
		return self._defs.timestampFormat
	end,
	timestamp = function (self)
		local tsf = self:timestamp_format()
		return util.date[tsf]()
	end,
	config = function (self)
		return self._service:aws():config()
	end,
	http_request = function (self, req)
		return self._service:aws():http_request(req)
	end,
	log = function (self, ...)
		self._service:aws():api_log(self, ...)
	end,
	build_methods = function (self)
		local defs = self._defs
		for method,operation in pairs(defs.operations) do
			self[method] = function (API, param)
				local ok, r = pcall(function ()
					local req = Request[API:request_format()].new(API, operation, param)
					return req:send()
				end)
				if not ok then
					API:log(method .. ':error:' .. r)
					return false,r
				end
				return r
			end
		end
	end,
}
