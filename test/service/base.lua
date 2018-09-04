local AWS = require ('lua-aws.init')
local helper = require 'test.helper.util'
local mock = require ('lua-aws.engines.fs.mock')

-- test issue #53 (PR #56)
mock.mocking({
	'./lua-aws/services/specs/ec2-2016-11-15.min.json',
	'./lua-aws/services/specs/ec2-2015-04-15.min.json',
})

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	sslEnabled = not helper.MOCK_HOST(),
	endpoint = helper.MOCK_HOST(),
	preferred_engines = {
		fs = "mock",
	},
})

assert(aws.EC2:api():version() == '2016-11-15', 'version wrong:'..aws.EC2:api():version())
