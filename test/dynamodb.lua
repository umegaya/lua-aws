local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
package.path = package.path..";/root/lua-aws/?.lua"
helper.iterate_all_engines("dynamodb", function (preferred)
	local aws = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY') or "123",
		secretAccessKey = os.getenv('AWS_SECRET_KEY') or "234",
		preferred_engines = preferred,
        --endpoint = "ap-northeast-1.amazonaws.com",
        endpoint = "http://127.0.0.1:8000",
        region = "ap-northeast-1",
        sslEnabled = false,
        LocalEndpoint = true,
	})

	local ok,r 

	ok,r = aws.DynamoDB:api():listTables()
    print("listTables[", ok, r, "]")
    for k, v in pairs(r) do
        print(k, v)
        for i, j in pairs(v) do
            print(i, j)
        end
    end

	if ok then
		helper.dump_res("listTables", r)
	else
		assert(false, 'error:' .. helper.dump_res("listTables", r))
	end
end)
