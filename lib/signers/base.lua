local class = require ('class')
local util = require ('util')

return class.AWS_BaseSigner {
	initialize = function (self)
	end,
	sign = function (self, req, credentials, date)
		assert(false)
	end,
}