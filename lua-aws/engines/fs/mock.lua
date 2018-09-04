local util = require ('lua-aws.util')
local context = {}

return {
	mocking = function (files) 
		context.files = files
	end,
	scandir = function (path, prefix, fn)
		for _, file in ipairs(context.files) do
			fn(file)
		end
	end,
}
