local helper = require 'test.helper.util'
local util = require 'lua-aws.util'
local AWS = require ('lua-aws.init')
local dump_res = helper.dump_res

local aws = AWS.new({
	role = '',
	sslEnabled = not helper.MOCK_HOST(),
	endpoint = helper.MOCK_HOST(),
})

local ok,r = aws.EC2:api():describeInstances()

if ok then
	assert(r.value.DescribeInstancesResponse.xarg.xmlns:match("http://ec2.amazonaws.com/doc"))
else
	assert(false, 'error:' .. r)
end

