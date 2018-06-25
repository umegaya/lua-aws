local helper = require 'test.helper.util'
local util = require 'lua-aws.util'
local AWS = require ('lua-aws.init')
local dump_res = helper.dump_res

if os.getenv('AWS_ACCESS_KEY') then
	-- ignored in non-aws instance environment
	return
end

local aws = AWS.new({
	role = 'aws_auto_cred_test',
	sslEnabled = not helper.MOCK_HOST(),
	region = 'ap-northeast-1',
	endpoint = helper.MOCK_HOST(),
})

local ok,r = aws.EC2:api():describeInstances()

if ok then
	assert(r.value.DescribeInstancesResponse.xarg.xmlns:match("http://ec2.amazonaws.com/doc"))
else
	assert(false, 'error:' .. r)
end

