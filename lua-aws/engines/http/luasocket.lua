local luasocket_http = require 'socket.http'
local util = require 'lua-aws.util'
local http_print = util.http_print
local ltn12 = require "ltn12"

local run_http_engine = function (eng, req)
	util.fill_header(req)
	http_print('requestto:', req.protocol .. "://" .. req.host .. ":" .. req.port .. req.path)
	http_print('sentbody:', req.body)
	for k,v in pairs(req.headers) do
		http_print('req_header:', k, v)
	end
	local respbody = {}
	local result, respcode, respheaders, respstatus = eng.request {
		url = req.protocol .. "://" .. req.host .. ":" .. req.port .. req.path,
		headers = req.headers,
		method = req.method,
		source = ltn12.source.string(req.body),
		sink = ltn12.sink.table(respbody)
	}
	http_print('result of query:', result, respcode, respstatus)
	if type(respcode) ~= 'number' then
		return { headers = {}, status = respcode, body = "" }
	end
	for k,v in pairs(respheaders) do
		http_print('header:', k, v)
	end
	local resp = {
		headers = respheaders,
		body = table.concat(respbody),
	}
	http_print('body:', resp.body)
	respstatus:gsub('.*%s(%w*)%s.*', function (s)
		resp.status = tonumber(s)
	end)
	return resp
end

local luasec_ok, luasec_https = pcall(require, 'ssl.https')
return function (req)
	if req.protocol:match('https') then
		if luasec_ok then
			return run_http_engine(luasec_https, req)
		else
			error('no https module available')
			return nil
		end
	end
	return run_http_engine(luasocket_http, req)
end
