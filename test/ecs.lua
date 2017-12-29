local helper = require 'test.helper.util'
helper.dump = true
local AWS = require ('lua-aws.init')
local aws = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	sslEnabled = not helper.MOCK_HOST(),
	endpoint = helper.MOCK_HOST(),
})

local api = aws.ECS:api_by_version('2014-11-13')

local ok, r
ok, r = api:createCluster({
	clusterName = "lua-aws-test",
})

if (not ok) or (not r.cluster) then
	helper.dump_res(r)
	assert(false, "create cluster fails")
end
if r.cluster.clusterName ~= "lua-aws-test" then
	helper.dump_res(r)
	assert(false, "createCluster invalid response")
end

local arn = r.cluster.clusterArn
print("clusterArn", arn)

ok, r = api:listClusters({
	maxResults = 10,
})

if not ok then
	assert(ok, r)
end
if not r.clusterArns then
	assert(false, "listClusters invalid response")
else
	local found = false
	for k,v in ipairs(r.clusterArns) do
		if v == arn then
			found = true
			break
		end
	end
	assert(found, "arn not found " .. arn)
end

ok, r = api:deleteCluster({
	cluster = arn,
})

if not ok then
	error(ok, r)
end

local ffi = require 'ffi'
if ffi then
	ffi.cdef [[
		unsigned int sleep(unsigned int seconds);
	]]
	ffi.C.sleep(1)

	ok, r = api:listClusters({
		maxResults = 10,
	})

	if #r.clusterArns > 0 then
		assert(false, "cluster should delete")
	end
end