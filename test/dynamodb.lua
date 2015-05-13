local AWS = require ('lua-aws.init')
AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY')
})

local function dump_res(tag, res)
	for k,v in pairs(res) do
		print(tag, k, v)
		if type(v) == 'table' then
			dump_res(tag.."."..k, v)
		end
	end
end

local ok,r 

ok,r = AWS.DynamoDB:api():listTables()

if ok then
	dump_res("listTables", r)
else
	assert(false, 'error:' .. dump_res("listTables", r))
end