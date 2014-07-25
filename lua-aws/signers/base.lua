local class = require ('lua-aws.class')
local util = require ('lua-aws.util')

return class.AWS_BaseSigner {
	initialize = function (self)
	end,
	sign = function (self, req, credentials, date)
		assert(false)
	end,
}
