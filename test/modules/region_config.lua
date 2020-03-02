local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
local rc = require ('lua-aws.region_config')

local regions = {
	--[["us-east-1",
	"us-east-2",
	"us-west-1",
	"us-west-2",
	"ca-central-1",
	"eu-central-1",
	"eu-west-1",
	"eu-west-2",
	"eu-west-3",
	"eu-north-1",
	"ap-northeast-1",
	"ap-northeast-2",
	"ap-northeast-3",
	"ap-southeast-1",
	"ap-southeast-2",
	"ap-south-1",
	"sa-east-1",

	"us-gov-east-1",
	"us-gov-west-1", ]]--

	"cn-north-1",
	"cn-northwest-1"
}

for _, region in ipairs(regions) do

	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		region = region,
	})
	--[[aws.DynamoDB,
	aws.EC2,
	aws.Kinesis,
	aws.SNS,
	aws.SQS,
	aws.SWF,
	aws.CloudWatch,
	aws.CloudWatchLog,
	aws.S3,
	aws.ECS,
	aws.Athena,
	aws.Firehose,
	aws.Lambda,
	aws.IAM,
	]]--

	local api = aws.IAM:api()
	rc(api)
	local ep = api:endpointFromTemplate(api._config.endpoint)
	print(ep)
	assert(ep == 'iam.' .. region .. '.amazonaws.com.cn', 'wrong ep:'..ep)
end
