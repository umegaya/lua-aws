local AWS = require ('lua-aws.init')
AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	sslEnabled = false,
	preferred_engines = {
		http = require 'lua-aws.engines.http.curl'
	},
})

local ok,r = AWS.EC2:api():describeInstances()

if ok then
	--local serpent = require ('serpent')
	--print(serpent.dump(res, { compact = false }))
	--dump(res)
	assert(r.value.DescribeInstancesResponse.xarg.xmlns == "http://ec2.amazonaws.com/doc/2015-04-15/")
else
	assert(false, 'error:' .. r.code .. "|" ..tostring(r.message))
end
