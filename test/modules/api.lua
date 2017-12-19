local class = require ('lua-aws.class')
local API = require ('lua-aws.api')
local util = require ('lua-aws.util')

local AWS = require ('lua-aws.init')
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
})
local aws2 = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	endpoint = 'hoge.amazonaws.com',
})

local region = aws.DynamoDB:api():region()
local endpoint_prefix = aws.DynamoDB:api():endpoint_prefix()

assert(aws.DynamoDB:api():endpoint() == endpoint_prefix..'.'..region..'.amazonaws.com')
assert(aws2.DynamoDB:api():endpoint() == 'hoge.amazonaws.com')

assert(aws.S3:api():endpoint() == 's3.amazonaws.com')
assert(aws2.S3:api():endpoint() == 'hoge.amazonaws.com')
