local AWS = require ('lua-aws.init')
AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY')
})

local res,err = AWS.EC2:api():describeInstances()

if res then
	--local serpent = require ('serpent')
	--print(serpent.dump(res, { compact = false }))
	--dump(res)
	assert(res.value.DescribeInstancesResponse.xarg.xmlns == "http://ec2.amazonaws.com/doc/2013-02-01/")
	assert(res.value.DescribeInstancesResponse.value.reservationSet.value.item[1].value.ownerId.value == '871570535967')
else
	assert(false, 'error:' .. err)
end
