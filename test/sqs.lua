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

local res
res = aws.SQS:api_by_version('2012-11-05'):createQueue({
	QueueName = "testQueue",
})
dump_res('create', res)

local QueueUrl = res.value.CreateQueueResponse.value.CreateQueueResult.value.QueueUrl.value
print("QueueUrl:", QueueUrl)
local params = {
	QueueUrl = QueueUrl,
	MessageBody = "testing"
}
res = aws.SQS:api_by_version('2012-11-05'):sendMessage(params)
dump_res('message', res)


res = aws.SQS:api_by_version('2012-11-05'):deleteQueue({
	QueueUrl = QueueUrl,
})
dump_res('delete', res)
-- ]]