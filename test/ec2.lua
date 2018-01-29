local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
helper.iterate_all_engines("ec2", function (preferred)
	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		preferred_engines = preferred,
		endpoint = helper.MOCK_HOST(),
	})

	local ok,r = aws.EC2:api():describeInstances()

	if ok then
		--local serpent = require ('serpent')
		--print(serpent.dump(res, { compact = false }))
		--helper.dump = true
		--helper.dump_res('ec2', r)
		assert(r.value.DescribeInstancesResponse.xarg.xmlns:match("http://ec2.amazonaws.com/doc"))
	else
		assert(false, 'error:' .. r)
	end
end)


-- old retval format error
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	oldReturnValue = true,
	endpoint = helper.MOCK_HOST(),
})

local r = aws.EC2:api():describeInstances()

if not r.code then
	--local serpent = require ('serpent')
	--print(serpent.dump(res, { compact = false }))
	--dump(res)
	assert(r.value.DescribeInstancesResponse.xarg.xmlns:match("http://ec2.amazonaws.com/doc"))
else
	assert(false, 'error:' .. err)
end
