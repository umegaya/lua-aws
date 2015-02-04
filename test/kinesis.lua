local AWS = require ('lua-aws.init')
local util = require 'lua-aws.util'
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	sslEnabled = true
})

local function dump_res(tag, res)
	for k,v in pairs(res) do
		print(tag, k, v)
		if type(v) == 'table' then
			dump_res(tag.."."..k, v)
		end
	end
end

local api = aws.Kinesis:api_by_version('2013-12-02')

local ok,r

ok,r = api:createStream({
	StreamName = "test_stream",
	ShardCount = 1,
})
assert(ok, r)
dump_res('create', r)

ok,r = api:describeStream({
	StreamName = "test_stream",
})
assert(ok, r)
dump_res('list_stream', r)



--[[
for i=1,10 do
	res = api:putRecords({
		StreamName = "test_stream",
		Data = util.b64.encode("very important data "..i), 
		PartitionKey = "lua", 
	})
end
]]

ok,r = api:deleteStream({
	StreamName = "test_stream",
})
assert(ok, r)
dump_res('delete', r)

-- ]]