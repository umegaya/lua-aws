local helper = require 'test.helper.util'
helper.dump = true
local AWS = require ('lua-aws.init')
helper.iterate_all_engines("s3", function (preferred)
	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		preferred_engines = preferred,
	})

	local ok,r = aws.S3:api():listBuckets()

	if ok then
		--local serpent = require ('serpent')
		--print(serpent.dump(res, { compact = false }))
		helper.dump_res('ec2', r)
	else
		helper.dump_res('ec2', r)
		assert(false, 'error:' .. r)
	end
end)
