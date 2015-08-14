local curl = require 'cURL'
local util = require 'lua-aws.util'
util.make_curl_header = function (headers)
	local res = {}
	for k,v in pairs(headers) do
		table.insert(res, k .. ": " .. v .."\r\n")
	end
	return res
end
return function (req)
		util.fill_header(req)
	local c = curl.easy_init()
	c:setopt_url(req.protocol .. "://" .. req.host .. ":" .. req.port .. req.path)
	c:setopt_useragent(req.headers["User-Agent"])
	c:setopt_httpheader(util.make_curl_header(req.headers))
	if req.method == 'GET' then
	elseif req.method == 'POST' then
		c:post({
			name = {
				file = '/dev/null',
				type = req.headers["Content-Type"],
				data = req.body
			}
		})
	else
		assert(false, "not supported:" .. req.method)
	end
	local headers = {}
	local body = ""
	c:perform({
		headerfunction = function(str)
			str:gsub('(.*):% (.*)', function (s1, s2)
				headers[s1] = util.chop(s2)
			end)
		end,
		writefunction = function(str)
			body = (body .. str)
		end
	})
	return {
		status = c:getinfo_response_code(),
		body = body,
		headers = headers,
	}
end
