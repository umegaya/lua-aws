local json = require ('lua-aws.deps.dkjson')

return {
	encode = function (data)
		return json.encode(setmetatable(data, { __jsontype = "object" }))
	end,
	decode = function (data)
		return json.decode(data, 1, json.null)
	end,
	null = json.null
}
