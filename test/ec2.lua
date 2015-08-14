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
		--dump(res)
		assert(r.value.DescribeInstancesResponse.xarg.xmlns == "http://ec2.amazonaws.com/doc/2013-10-15/")
		assert(r.value.DescribeInstancesResponse.value.reservationSet.value.item[1].value.ownerId.value == '871570535967')
	else
		assert(false, 'error:' .. r)
	end
end)
