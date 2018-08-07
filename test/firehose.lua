local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	endpoint = helper.MOCK_HOST(),
})

if not helper.MOCK_HOST() then
	-- 2018/08/07 iyatomi moto_server does not seem to support 

	local ok,r = aws.Firehose:api():listDeliveryStreams()

	if not ok then
		helper.dump = true
		helper.dump_res('athena', r)
		assert(false, 'error:' .. r)
	end
end
