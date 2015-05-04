local AWS = require ('lua-aws.init')
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY')
})

local function dump_res(tag, res)
	for k,v in pairs(res) do
		print(tag, k, v)
		if type(v) == 'table' then
			dump_res(tag.."."..k, v)
		end
	end
end

local ok,r
ok,r = aws.SQS:api_by_version('2012-11-05'):createQueue({
	QueueName = "testQueue",
})
assert(ok, r)
dump_res('create', r)

local QueueUrl = r.value.CreateQueueResponse.value.CreateQueueResult.value.QueueUrl.value
print("QueueUrl:", QueueUrl)
local params = {
	QueueUrl = QueueUrl,
	MessageBody = [[{"email_id":2,"contact_id":"1-xxxxx@hotmail.es","bulk_id":1,"email_version_id":14,"client_id":1}]]
}
ok,r = aws.SQS:api_by_version('2012-11-05'):sendMessage(params)
assert(ok, r)
dump_res('message', r)


ok,r = aws.SQS:api_by_version('2012-11-05'):deleteQueue({
	QueueUrl = QueueUrl,
})
assert(ok, r)
dump_res('delete', r)
-- ]]