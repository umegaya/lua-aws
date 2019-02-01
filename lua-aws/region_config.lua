local util = require ('lua-aws.util')
local regionConfig = require ('lua-aws.region_config_data')

local function generateRegionPrefix(region)
	if not region then
		return
	end

	local parts = util.split(region, "-")
	if #parts < 3 then
		return
	end

	return util.join(util.slice(parts, 1, #parts - 2), "-") .. "-*"
end

local function derivedKeys(api)
	local region = api:region()
	local regionPrefix = generateRegionPrefix(region)
	local endpointPrefix = api:endpoint_prefix()

	return {
		region .. "/" .. endpointPrefix,
		regionPrefix .. "/" .. endpointPrefix,
		region .. "/*",
		regionPrefix .. "/*",
		"*/" .. endpointPrefix,
		"*/*",
	}
end

local function applyConfig(api, config)
	local c = api:config()
	for key, value in pairs(config) do
		if key ~= "globalEndpoint" and c[key] == nil then
			c[key] = value
		end
	end
end

local function configureEndpoint(api)
	local keys = derivedKeys(api)
	for _, key in ipairs(keys) do
		if key and regionConfig.rules[key] then
			local config = regionConfig.rules[key]
			if type(config) == "string" then
				config = regionConfig.patterns[config]
			end

			if not config.signatureVersion then
				config.signatureVersion = "v4"
			end

			applyConfig(api, config)
			return
		end
	end
end

return configureEndpoint
