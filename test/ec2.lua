local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
helper.iterate_all_engines("ec2", function (preferred)
	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		preferred_engines = preferred,
	})

	local ok,r = aws.EC2:api():describeInstances()

	if ok then
		--local serpent = require ('serpent')
		--print(serpent.dump(res, { compact = false }))
		--helper.dump = true
		--helper.dump_res('ec2', r)
		assert(r.value.DescribeInstancesResponse.xarg.xmlns == "http://ec2.amazonaws.com/doc/2016-11-15/")
	else
		assert(false, 'error:' .. r)
	end
end)
