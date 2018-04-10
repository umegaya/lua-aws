local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	endpoint = helper.MOCK_HOST(),
})

local ok,r = aws.Firehose:api():listDeliveryStreams()

if not ok then
	helper.dump = true
	helper.dump_res('athena', r)
	assert(false, 'error:' .. r)
end
