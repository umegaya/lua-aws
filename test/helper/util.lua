local availables = require 'lua-aws.engines.available'
local _M = {}
if ngx then
	local allow_write_global = function (GLOBALS_ALLOWED_IN_TEST)
		-- avoid warning during test runs caused by
		-- https://github.com/openresty/lua-nginx-module/blob/2524330e59f0a385a9c77d4d1b957476dce7cb33/src/ngx_http_lua_util.c#L810
		setmetatable(_G, { __newindex = function(table, key, value) rawset(table, key, value) end })

		-- if there's more constants need to be whitelisted for test runs, add here.
		local newindex = function(table, key, value)
			rawset(table, key, value)

			local phase = ngx.get_phase()
			if phase == "init_worker" or phase == "init" then
			  return
			end

			-- we check only timer phase because resty-cli runs everything in timer phase
			if phase == "timer" and GLOBALS_ALLOWED_IN_TEST[key] then
			  return
			end

			local message = "at:" .. phase .. ", writing a global lua variable " .. key ..
			  " which may lead to race conditions between concurrent requests, so prefer the use of 'local' variables "
			-- it's important to do print here because ngx.log is mocked below
			print(message)
		end
		setmetatable(_G, { __newindex = newindex })
	end
	allow_write_global({
		socket = true,
		TIMEOUT = true,
		ltn12 = true,
		mime = true,
		lfs = true
	})
end

function _M.iterate_all_engines(test_name, test)
	for _, h in ipairs(availables.http) do
		for _, j in ipairs(availables.json) do
			for _, f in ipairs(availables.fs) do
				if ngx and (h == "luasocket" or h == "curl") then
					-- using luasec/curl causes following error:
					-- error loading module 'ssl.core' from file '/usr/local/openresty/luajit/lib/lua/5.1/ssl.so':
					-- /usr/local/openresty/openssl/lib/libssl.so.1.1: version `OPENSSL_1_1_1' not found (required by /usr/local/openresty/luajit/lib/lua/5.1/ssl.so)
					print('luasocket/curl skipped because of latest resty environment breaks luasec')
				elseif ((not ngx) or _M.MOCK_HOST()) and h == "lua-resty-http" then
					--[[ lua-resty-http with moto-server causes below error

 					127.0.0.1 - - [29/Jan/2019 01:21:52] code 400, message Bad request syntax ('\x16\x03\x01\x00\xbd\x01\x00\x00\xb9\x03\x03\xd7\xcfy\xf4')
					127.0.0.1 - - [29/Jan/2019 01:21:52] "\xbd\xb9\xd7\xcfy\xf4" HTTPStatus.BAD_REQUEST -
2019/01/29 01:21:52 [error] 201#201: *2 SSL_do_handshake() failed (SSL: error:1408F10B:SSL routines:ssl3_get_record:wrong version number), context: ngx.timer
						
					error:./lua-aws/engines/http/lua-resty-http.lua:29: handshake failed
					
					]] 
					print('lua-resty-http skipped because of no resty environment or with mock server')
				elseif h ~= "mock" and j ~= "mock" and f ~= "mock" then
					test {
						http = h,
						json = j,
						fs = f,
						strict = true,
					}
					print(test_name, h, j, f, "ok")
				end
			end
		end
	end
end

function _M.dump_res(tag, res)
	if _M.dump then
		for k,v in pairs(res) do
			print(tag, k, v)
			if type(v) == 'table' then
				_M.dump_res(tag.."."..k, v)
			end
		end
	end
end

function _M.MOCK_HOST()
	return arg[1]
end

local LUA_AWS_SERVICE_ROLE_PATH = "/LuaAwsTestModuleRolePath/"

function _M.find_service_role(aws, name)
	local ok, r = aws.IAM:api():listRoles({
		PathPrefix = LUA_AWS_SERVICE_ROLE_PATH
	})
	assert(ok, r)
	-- _M.dump = true
	local roles = r.value.ListRolesResponse.value.ListRolesResult.value.Roles
	if not roles then
		return nil -- does not found role with given path
	end
	roles = roles.list and roles.value.member or {roles.value.member}
	for _, role in ipairs(roles) do
		_M.dump_res('role', role)
		if role.value.Arn.value:sub(-#name) == name then
			return role.value.Arn.value
		end
	end
	return nil
end

function _M.delete_service_role(aws, name)
	local ok, r = aws.IAM:api():deleteRole({
		RoleName = name
	})
	assert(ok, r)	
end

function _M.create_service_role(aws, name, policy)
	local roleArn = _M.find_service_role(aws, name)
	if roleArn then
		return roleArn
	end
	local ok, r = aws.IAM:api():createRole({
		RoleName = name,
		AssumeRolePolicyDocument = policy or [[
{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Principal":{"Service":["lambda.amazonaws.com"]},"Action":["sts:AssumeRole"]}]}
]],
		Path = LUA_AWS_SERVICE_ROLE_PATH
	})
	assert(ok, r)
	roleArn = _M.find_service_role(aws, name)
	assert(roleArn, "role does not created")
	return roleArn
end

return _M
