local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')

AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	endpoint = helper.MOCK_HOST(),
})

local ok,r

if not helper.MOCK_HOST() then
	-- 2017/12/30 current moto_server does not seems to support cloud watch logs
	ok,r = AWS.CloudWatchLog:api():DescribeLogGroups()
	if ok then
		-- helper.dump_res('cwlog', r)
		assert(type(r.logGroups) == 'table')
	else
		assert(false, 'error:' .. r.code .. "|" ..tostring(r.message))
	end
end

ok,r = AWS.CloudWatch:api():ListMetrics()
if ok then
	-- helper.dump_res('cw', r)
	assert(r.value.ListMetricsResponse.xarg.xmlns == "http://monitoring.amazonaws.com/doc/2010-08-01/")
else
	assert(false, 'error:' .. r.code .. "|" ..tostring(r.message))
end
