local util = require 'lua-aws.util'

return {
	scandir = function (path, prefix, fn)
		return util.dir(path..prefix.."*"):each(fn)
	end,
}
