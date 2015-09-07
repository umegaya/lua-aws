local helper = require 'test.helper.util'
helper.dump = true
local AWS = require ('lua-aws.init')
AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
})

local ok,r

ok,r = AWS.CloudWatchLog:api():DescribeLogGroups()
if ok then
	-- helper.dump_res('cwlog', r)
	assert(type(r.logGroups) == 'table')
else
	assert(false, 'error:' .. r.code .. "|" ..tostring(r.message))
end

ok,r = AWS.CloudWatch:api():ListMetrics()
if ok then
	-- helper.dump_res('cw', r)
	assert(r.value.ListMetricsResponse.xarg.xmlns == "http://monitoring.amazonaws.com/doc/2010-08-01/")
else
	assert(false, 'error:' .. r.code .. "|" ..tostring(r.message))
end
