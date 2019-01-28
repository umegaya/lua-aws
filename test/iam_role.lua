local helper = require 'test.helper.util'
local util = require 'lua-aws.util'
local AWS = require 'lua-aws.init'
local dump_res = helper.dump_res

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	region = 'us-east-1'
})

if not helper.MOCK_HOST() then
	local roleName = "lua-aws-test-default-role"
	local roleArn = helper.create_service_role(aws, roleName)
	local roleArnFound = helper.find_service_role(aws, roleName)
	assert(roleArn and (roleArn == roleArnFound), "role not created or found")
	helper.delete_service_role(aws, roleName)
	roleArnFound = helper.find_service_role(aws, roleName)
	assert(not roleArnFound, "role should not be found")
end
