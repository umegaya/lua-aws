local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
local mock = require ('lua-aws.engines.fs.mock')
local EC2 = require ('lua-aws.services.ec2')

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
	lazyInitialization = true,
	preferred_engines = {
		fs = "mock",
	},
})

local ec2 = EC2.new(aws) 

assert(ec2:api():version() == '2016-11-15', 'version wrong:'..ec2:api():version())
