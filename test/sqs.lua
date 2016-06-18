local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
})
local dump_res = helper.dump_res
local ok,r
ok,r = aws.SQS:api_by_version('2012-11-05'):createQueue({
	QueueName = "testQueue",
})
assert(ok, r)
dump_res('create', r)

local QueueUrl = r.value.CreateQueueResponse.value.CreateQueueResult.value.QueueUrl.value
print("QueueUrl:", QueueUrl)
local jsonmsg = [[{"email_id":2,"contact_id":"1-xxxxx@hotmail.es","bulk_id":1,"email_version_id":14,"client_id":1}]]
local params = {
	QueueUrl = QueueUrl,
	MessageBody = jsonmsg
}
ok,r = aws.SQS:api_by_version('2012-11-05'):sendMessage(params)
assert(ok, r)
dump_res('send', r)

ok,r = aws.SQS:api_by_version('2012-11-05'):receiveMessage({
	QueueUrl = QueueUrl,
	Foo = Bar, -- un-ruled parameter test
})
assert(ok, r)
dump_res('recv1', r)
assert(r.value.ReceiveMessageResponse.value.ReceiveMessageResult.value.Message.value.Body.value == jsonmsg)

local params = {
	QueueUrl = QueueUrl,
	Entries = {
		{
			Id = "msg1",
			MessageBody = "test msg 1",
		},
		{
			Id = "msg2",
			MessageBody = "test msg 2",
			MessageAttributes = {
				test_attribute_name_1 = {
					StringValue = "test_attribute_value_1",
					DataType = "String",
				},
			},
		},
	},	
}
ok,r = aws.SQS:api_by_version('2012-11-05'):sendMessageBatch(params)
assert(ok, r)
dump_res('sendbatch', r)


ok,r = aws.SQS:api_by_version('2012-11-05'):receiveMessage({
	QueueUrl = QueueUrl,
	Foo = Bar, -- un-ruled parameter test
})
assert(ok, r)
dump_res('recv2', r)


ok,r = aws.SQS:api_by_version('2012-11-05'):deleteQueue({
	QueueUrl = QueueUrl,
})
assert(ok, r)
dump_res('delete', r)
