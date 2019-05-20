local class = require ('lua-aws.class')
local API = require ('lua-aws.api')
local util = require ('lua-aws.util')

local specs = {}

local function get_spec(aws, service_name)
	local spec = specs[service_name]
	if spec then
		return spec
	end

	spec = {}

	local service_name_regexp = service_name:gsub('%-', '%%-')

	aws:fs().scandir(util.script_path() .. '/specs/', service_name, function (path)
		local version = path:match('/' .. service_name_regexp .. '%-([%d%-]+)%.min%.json$')
		if version then
			local data = aws:json().decode(util.get_json_part(path))
			spec[version] = data
		end
	end)

	specs[service_name] = spec
	return spec
end

return class.AWS_Service {
	initialize = function (self, aws, service_name)
		self._service_name = service_name or self.class.class_name:gsub('^AWS_', '')
		self._aws = aws
		self._apis = self:build_apis()
	end,
	aws = function (self)
		return self._aws
	end,
	build_apis = function (self)
		local latest
		local apis = {}
		local aws = self._aws
		local service_name = self._service_name:lower()
		local spec = get_spec(aws, service_name)

		for version, data in pairs(spec) do
			apis[version] = API.new(self, data)
			if (not latest) or (latest <= version) then
				apis.latest = apis[version]
				latest = version
			end
		end
		assert(apis.latest, service_name .. ':no api defined.')
		return apis
	end,
	api_latest = function (self)
		return self._apis.latest
	end,
	api_by_version = function (self, ver)
		return self._apis[ver]
	end,
	api = function (self)
		return self:api_latest()
	end,
}
