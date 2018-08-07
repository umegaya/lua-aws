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

-- describeInstance test (only with mock mode)
if helper.MOCK_HOST() then
	local cr = aws.EC2:api():runInstances({
		MinCount = 2, 
		MaxCount = 2,
	})
	-- helper.dump = true
	-- helper.dump_res('ec2 runInstances', cr)
	local iid = cr.value.RunInstancesResponse.value.instancesSet.value.item[1].value.instanceId.value
	local iid2 = cr.value.RunInstancesResponse.value.instancesSet.value.item[2].value.instanceId.value
	-- print('instanceIds', iid, iid2)
	local dr = aws.EC2:api():describeInstances({
		InstanceIds = { iid }
	})
	local dri = dr.value.DescribeInstancesResponse.value.reservationSet.value.item.value.instancesSet.value.item
	-- helper.dump_res('ec2 describeInstances', dr)
	-- print('#dr', (#dri), dri.value.instanceId.value)
	-- item should not be array (only single element returns)
	assert((#dri) == 0)
	assert(dri.value.instanceId.value == iid)

	local dr2 = aws.EC2:api():describeInstances({
		InstanceIds = { iid, iid2 }
	})
	local dri2 = dr2.value.DescribeInstancesResponse.value.reservationSet.value.item.value.instancesSet.value.item

	assert((#dri2) == 2)
	assert(dri2[1].value.instanceId.value == iid)
	assert(dri2[2].value.instanceId.value == iid2)

end
