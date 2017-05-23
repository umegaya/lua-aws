local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
helper.iterate_all_engines("dynamodb", function (preferred)
	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		preferred_engines = preferred,
		--is_local = false,
	})

	local ok,r 

	ok,r = aws.DynamoDB:api():listTables()

	if ok then
		helper.dump_res("listTables", r)
	else
		assert(false, 'error:' .. helper.dump_res("listTables", r))
	end
end)
