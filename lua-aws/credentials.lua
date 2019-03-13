local class = require ('lua-aws.class')

return class.AWS_Credentials {
	initialize = function(self, options)
		self.expired = false
		self.expireTime = nil
		self.accessKeyId = options.accessKeyId
		self.secretAccessKey = options.secretAccessKey
		self.sessionToken = options.sessionToken
	end,

	expiryWindow = 15,

	needsRefresh = function(self)
		if not self.expireTime then
			return self.expired or (not self.accessKeyId) or (not self.secretAccessKey)
		end

		local currentTime = os.time()
		local adjustedTime = currentTime + self.expiryWindow
		return adjustedTime > self.expireTime
	end,

	get = function(self)
		if self:needsRefresh() then
			local ok, err = self:refresh()
			if ok then
				self.expired = false
			end
			return ok, err
		else
			return true
		end
	end,

	refresh = function(self)
		self.expired = false
		return true
	end,
}
