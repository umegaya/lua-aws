local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
})
local s3api = aws.S3:api();
s3api:init_shapes()
local Shape = require('lua-aws.shape.shape')
local listobject_output_shape = Shape.create(s3api._defs.operations.ListObjects.output, { api = s3api })
local listbucket_output_shape = Shape.create(s3api._defs.operations.ListBuckets.output, { api = s3api })
local translator = require ('lua-aws.shape.translator.xml')
local helper = require 'test.helper.util'
helper.dump = true


local F = require('test.modules.shape.rest_xml_fixture')

local r

r = translator.translate(F.s3_listobjects_resp, listobject_output_shape)
helper.dump_res('s3-listobjects', r)
assert(type(r.Contents) == 'table' and #r.Contents == 2
	and r.Contents[1].ETag and r.Contents[1].Key and r.Contents[1].Size)


r = translator.translate(F.s3_listobjects_single_resp, listobject_output_shape)
helper.dump_res('s3-listobjects-single', r)
assert(type(r.Contents) == 'table' and #r.Contents == 1
	and r.Contents[1].ETag and r.Contents[1].Key and r.Contents[1].Size)


r = translator.translate(F.s3_listbuckets_resp, listbucket_output_shape)
helper.dump_res('s3-listbuckets', r)
assert(type(r.Buckets) == 'table' and #r.Buckets >= 1
	and r.Buckets[1].Name and r.Buckets[1].CreationDate)
