local helper = require 'test.helper.util'
local AWS = require ('lua-aws.init')
local util = require ('lua-aws.util')

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

local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	endpoint = helper.MOCK_HOST(),
})

local TestLambdaFuncName = "hello_lua_aws"
local roleArn = "arn:aws:iam::871570535967:role/LuaAwsTestModuleRolePath/lambda-executer" -- helper.create_service_role("lambda-executer")
local f = io.open("/tmp/lua-aws-lambda-project.zip", "rb")
local payload = {
	Code = {
		ZipFile = f:read("*a"),
	},
	FunctionName = TestLambdaFuncName,
	Handler = "index.handler",
	Role = roleArn,
	Runtime = "nodejs8.10"
}
helper.dump = true
-- helper.dump_res('lambda-payload', payload)

--[[]]
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
