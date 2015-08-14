local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
helper.iterate_all_engines("sqs", function (preferred)
	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		preferred_engines = preferred,
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
end)
