local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
})

local ok,r = aws.SWF:api():listDomains({
	registrationStatus = "REGISTERED", 
})

if ok then
	--local serpent = require ('serpent')
	--print(serpent.dump(res, { compact = false }))
	assert(type(r.domainInfos) == 'table')
else
	assert(false, 'error:' .. r)
end
