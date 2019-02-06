local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	region = 'us-east-1'
})

local roleName = "lua-aws-test-default-role"
local roleArn = helper.create_service_role(aws, roleName)

local ok, r = aws.STS:api():assumeRole({
	RoleArn = roleArn,
	RoleSessionName = "LuaAwsSTSTestSession"
})

print(ok, r)

helper.dump = true
helper.dump_res('assumeRole', r)
