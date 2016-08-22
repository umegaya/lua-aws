local AWS = require ('lua-aws.init')
local util = require ('lua-aws.util')
local helper = require 'test.helper.util'
helper.dump = true

-- full functionality test
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	preferred_engines = preferred,
})

local BUCKET_NAME = "lua-aws-test-"..os.time()
local FILE_NAME = "BmB9X3YIEAARNWy.jpg"
local DEST_FILE_NAME = "dest.jpg"
local DEST_FILE_NAME2 = "dest2.jpg"
local DIR_PATH="./test/resource/"
local ok, r

os.remove(DIR_PATH..DEST_FILE_NAME)

ok, r = aws.S3:api():createBucket({Bucket = BUCKET_NAME})
if not ok then error(r) end
helper.dump_res('s3-createbucket', r)



ok, r = aws.S3:api():listBuckets()
if not ok then error(r) end
helper.dump_res('s3-listbucket', r)
local found = false
for _, b in ipairs(r.Buckets) do
	if b.Name == BUCKET_NAME then
		found = true
		break
	end
end
assert(found, "bucket not created")



local f = io.open(DIR_PATH..FILE_NAME)
ok, r = aws.S3:api():putObject({
	Bucket = BUCKET_NAME, 
	Key = FILE_NAME, 
	Body = f,
	ContentLength = util.filesize(f), -- otherwise got error.
})
if not ok then error(r) end
helper.dump_res('s3-putobject', r)



ok, r = aws.S3:api():getObject({
	Bucket = BUCKET_NAME, 
	Key = FILE_NAME, 
}, {
	body = io.open(DIR_PATH..DEST_FILE_NAME, "w") -- otherwise r.body contains all file contents
})
if not ok then error(r) end
helper.dump_res('s3-getobject', r)



local f1, f2 = os.execute("md5 -q "..DIR_PATH..FILE_NAME), os.execute("md5 -q "..DIR_PATH..DEST_FILE_NAME)
if f1 ~= f2 then
	error("both file should be same: but: " .. f1 .. " vs " .. f2)
end



ok, r = aws.S3:api():deleteObject({
	Bucket = BUCKET_NAME, 
	Key = FILE_NAME, 
})
if not ok then error(r) end
helper.dump_res('s3-deleteobject', r)



ok, r = aws.S3:api():getObject({
	Bucket = BUCKET_NAME, 
	Key = FILE_NAME, 
}, {
	body = io.open(DIR_PATH..DEST_FILE_NAME, "w")
})
if ok then error("should not be read") end
helper.dump_res('s3-getobject', r)



ok, r = aws.S3:api():deleteBucket({Bucket = BUCKET_NAME})
if not ok then error(r) end
helper.dump_res('s3-deletebucket', r)



return true
