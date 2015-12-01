local luasocket_http = require 'socket.http'
local util = require 'lua-aws.util'
local http_print = util.http_print
local ltn12 = require "ltn12"

local run_http_engine = function (eng, req, resp)
	util.fill_header(req)
	http_print('requestto:', req.protocol .. "://" .. req.host .. ":" .. req.port .. req.path)
	http_print('sentbody:', req.body)
	for k,v in pairs(req.headers) do
		http_print('req_header:', k, v)
	end
	resp = resp or {}
	local respbody = resp.body or {}
	local sink = io.type(respbody) and ltn12.sink.file or ltn12.sink.table
	local source = io.type(req.body) and ltn12.source.file or ltn12.source.string
	local result, respcode, respheaders, respstatus = eng.request {
		url = req.protocol .. "://" .. req.host .. ":" .. req.port .. req.path,
		headers = req.headers,
		method = req.method,
		source = source(req.body),
		sink = sink(respbody)
	}
	http_print('result of query:', result, respcode, respstatus)
	if type(respcode) ~= 'number' then
		return { headers = {}, status = respcode, body = "" }
	end
	for k,v in pairs(respheaders) do
		http_print('header:', k, v)
	end
	-- update resp object
	resp.status = respcode
	resp.headers = respheaders
	resp.body = io.type(respbody) and respbody or table.concat(respbody)
	http_print('body:', resp.body)
	if not resp.status then
		-- if respcode is not returns, try to inject it from status line
		respstatus:gsub('^[^%s]*%s(%w*)%s.*$', function (s)
			resp.status = tonumber(s)
		end)
	end
	return resp
end

local luasec_ok, luasec_https = pcall(require, 'ssl.https')
return function (req, resp)
	if req.protocol:match('https') then
		if luasec_ok then
			return run_http_engine(luasec_https, req, resp)
		else
			error('no https module available')
			return nil
		end
	end
	return run_http_engine(luasocket_http, req, resp)
end
