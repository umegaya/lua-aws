local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')

if helper.MOCK_HOST() then
	-- 2017/12/30 current moto_server does not seems to support swf
	-- it raises KeyError: 'swf' at this line:
	-- backend = list(BACKENDS[service].values())[0]
	return
end

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	endpoint = helper.MOCK_HOST(),
})

local ok,r = aws.SWF:api():listDomains({
	registrationStatus = "REGISTERED", 
})

if ok then
	--local serpent = require ('serpent')
	--print(serpent.dump(res, { compact = false }))
	assert(type(r.domainInfos) == 'table')
else
	helper.dump = true
	helper.dump_res('swf', r)
	assert(false, 'error:' .. r)
end
