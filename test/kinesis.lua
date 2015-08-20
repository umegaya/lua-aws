local helper = require 'test.helper.util'
local util = require 'lua-aws.util'
local AWS = require ('lua-aws.init')
local dump_res = helper.dump_res
helper.iterate_all_engines("kinesis", function (preferred)
	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		sslEnabled = true,
		preferred_engines = preferred,
	})

	local ffi = require 'ffi'

	local api = aws.Kinesis:api_by_version('2013-12-02')

	local ok,r

	ok,r = api:createStream({
		StreamName = "test_stream",
		ShardCount = 1,
	})
	assert(ok, r)
	dump_res('create', r)

	if ffi then
		ffi.cdef [[
			unsigned int sleep(unsigned int seconds);
		]]
		local wait
		repeat
			if not wait then 
				ffi.C.sleep(5)
			else
				wait = true
			end
			ok,r = api:describeStream({
				StreamName = "test_stream",
			})
			assert(ok, r)
			print(r.StreamDescription.StreamStatus)
		until r.StreamDescription.StreamStatus == "ACTIVE"
		dump_res('list_stream', r)
		local shard_id = r.StreamDescription.Shards[1].ShardId
		local start_seq = r.StreamDescription.Shards[1].SequenceNumberRange.StartingSequenceNumber
		-- print('shard_id/seq = ', shard_id, start_seq)

		ok, r = api:getShardIterator({
			StreamName = "test_stream",
			ShardId = shard_id,
			ShardIteratorType = "AT_SEQUENCE_NUMBER",
			StartingSequenceNumber = start_seq,
		})
		assert(ok, r)
		local iter = r.ShardIterator


		for i=1,10 do
			ok, r = api:putRecord({
				StreamName = "test_stream",
				Data = util.b64.encode("very important data "..i), 
				PartitionKey = "lua", 
			})
			assert(ok, r)
			-- print('put record', i)
		end

		ffi.C.sleep(10)

		ok, r = api:getRecords({
			ShardIterator = iter,
			limit = 100,
		})
		assert(ok, r)
		-- print('records', #r.Records)
		assert(#r.Records == 10)
		for _, rec in ipairs(r.Records) do
			local data = util.b64.decode(rec.Data)
			print(data)
			assert(data:match('^very important data'))
		end
	end

	ok,r = api:deleteStream({
		StreamName = "test_stream",
	})
	assert(ok, r)
	dump_res('delete', r)
end)