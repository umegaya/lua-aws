local json = require ('lua-aws.deps.dkjson')

return {
	encode = json.encode,
	decode = function (data)
		return json.decode(data, 1, json.null)
	end,
}
