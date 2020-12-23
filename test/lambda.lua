local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
local util = require ('lua-aws.util')

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	endpoint = helper.MOCK_HOST(),
})

-- 2019/01/28 iyatomi current moto server seems to need docker to create/run functions
-- but we already in it :<
if helper.MOCK_HOST() then
	local ok,r = aws.Lambda:api():listFunctions()
	assert(ok, r)

else
	-- prepare for role
	local awsForIAM = AWS.new({
		accessKeyId = os.getenv('AWS_ACCESS_KEY'),
		secretAccessKey = os.getenv('AWS_SECRET_KEY'),
		region = 'us-east-1'
	})

	local TestLambdaFuncName = "hello_lua_aws"
	local roleArn = helper.create_service_role(awsForIAM, "lambda-executer")

	-- prepare for zip file
	os.execute("rm -r /tmp/lua-aws-lambda-project*")
	local code = [[

exports.handler = (event, context, callback) => {
    const response = {
		statusCode: 200,
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({ "message": "helloLuaAWS" })
    };

    callback(null, response);
};
]]
	os.execute("mkdir /tmp/lua-aws-lambda-project")
	os.execute("cat <<CODE > /tmp/lua-aws-lambda-project/index.js" .. code .. "CODE")
	os.execute("cd /tmp/lua-aws-lambda-project && zip -r ../lua-aws-lambda-project .")
	local f = io.open("/tmp/lua-aws-lambda-project.zip", "rb")

	local payload = {
		Code = {
			ZipFile = f:read("*a"),
		},
		FunctionName = TestLambdaFuncName,
		Handler = "index.handler",
		Role = roleArn,
		Runtime = "nodejs12.x"
	}
	-- helper.dump = true
	-- helper.dump_res('lambda-payload', payload)

	--[[
	local ok,r = aws.Lambda:api():createFunction(payload)

	os.execute("rm -r /tmp/lua-aws-lambda-project*")

	ok,r = aws.Lambda:api():listFunctions()

	if ok then
		local found = false
		for idx,f in ipairs(r.Functions) do
			if f.FunctionName == TestLambdaFuncName and f.Handler == "index.handler" then
				found = true
			end
		end
		if not found then
			helper.dump = true
			helper.dump_res("lambda", r)
			assert(false, 'function should be found')
		end

		ok, r = aws.Lambda:api():invoke({
			FunctionName = TestLambdaFuncName
		})
		assert(ok, r)
		local payload = aws.Lambda:api():json().decode(r.Payload)
		local bodyPayload = aws.Lambda:api():json().decode(payload.body)
		assert(bodyPayload.message == "helloLuaAWS", "body wrong")

		ok, r = aws.Lambda:api():deleteFunction({
			FunctionName = TestLambdaFuncName
		})
		assert(ok, r)

		ok, r = aws.Lambda:api():listFunctions()
		found = false
		for idx,f in ipairs(r.Functions) do
			if f.FunctionName == TestLambdaFuncName then
				found = true
			end
		end
		assert(not found, "function should be removed")
	else
		assert(false, "error:" .. r)
	end
	--]]--

	-- test2 lambda by container image
	local Test2LambdaFuncName = "hello_lua_aws_from_container"
	local payload2 = {
		Code = {
			ImageUri = "871570535967.dkr.ecr.ap-northeast-1.amazonaws.com/lua-aws-lambda-test@sha256:21b43c2821cc9dccf17caafa47521fdacb51d41c0a2a6644f5df74884444fb51",
		},
		FunctionName = Test2LambdaFuncName,
		Role = roleArn,
		PackageType = "Image"
	}
	-- helper.dump = true
	-- helper.dump_res('lambda-payload', payload)

	--[[]]
	local ok,r = aws.Lambda:api():createFunction(payload2)
	ok,r = aws.Lambda:api():listFunctions()

	if ok then
		local found = false
		for idx,f in ipairs(r.Functions) do
			if f.FunctionName == Test2LambdaFuncName then
				found = true
			end
		end
		if not found then
			helper.dump = true
			helper.dump_res("lambda", r)
			assert(false, 'function should be found')
		end

		ok, r = aws.Lambda:api():invoke({
			FunctionName = Test2LambdaFuncName,
			Payload = aws.Lambda:api():json().encode({
				text = "lua-aws"
			})
		})
		local expected_blake2b_result = "8413443142d7424287f371029a6f9cb3c7a79482bace0e2625a34f28bd1d7443f84371d78977503bfe92a740c1a2fbdf76a1634030b47cb3ac10429afa969250"
		assert(ok, r)
		local payload = aws.Lambda:api():json().decode(r.Payload)
		local bodyPayload = payload.body
		assert(bodyPayload.message == "hello lua aws from container in lambda:" .. expected_blake2b_result, "body wrong")

		ok, r = aws.Lambda:api():deleteFunction({
			FunctionName = Test2LambdaFuncName
		})
		assert(ok, r)

		ok, r = aws.Lambda:api():listFunctions()
		found = false
		for idx,f in ipairs(r.Functions) do
			if f.FunctionName == Test2LambdaFuncName then
				found = true
			end
		end
		assert(not found, "function should be removed")
	else
		assert(false, "error:" .. r)
	end
end

--]]--
