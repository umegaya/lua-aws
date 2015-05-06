local class = require ('lua-aws.class')
local io = require ('io')
local json = require ('dkjson')
local xml_parser_factory = require ('lua-aws.deps.slaxml')
local xml_build = require ('lua-aws.deps.slaxdom')
local sha1 = require ('lua-aws.deps.sha1')

local _M = {}

_M.assert = function (cond, msg)
	assert(cond, (msg or '') .. "\n" .. debug.traceback())
end
_M.json = {
	encode = function (data)
		return json.encode(data)
	end,
	decode = function (data)
		return json.decode(data, 1, json.null)
	end,
}
_M.xml_parser = xml_parser_factory:parser()
_M.xml = (function ()
	-- parser code is from http://lua-users.org/wiki/LuaXml. thanks!
	function parseargs(s)
		local arg = {}
		string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
			arg[w] = a
		end)
		return arg
	end
	return {
		encode = function (data)
			return xml_build:dom(data)
		end,
		decode = function (s, options)
			local stack = {}
			local top = {}
			table.insert(stack, top)
			local ni,c,label,xarg, empty
			local i, j = 1, 1
			local no_xarg = options and options.no_xarg
			while true do
				ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
				if not ni then break end
				local text = string.sub(s, i, ni-1)
				if not string.find(text, "^%s*$") then
					if text:find('<?xml') then
						top.header = text
					else
						top.value = text
					end
				end
				if empty == "/" then  -- empty element tag
					top[label] = {xarg=parseargs(xarg)}
				elseif c == "" then   -- start tag
					local next = {xarg=parseargs(xarg), label = label}
					table.insert(stack, next)   -- add stack depth
					top = next
				else  -- end tag
					local toclose = table.remove(stack)  -- remove top
					top = stack[#stack]
					if #stack < 1 then
						error("nothing to close with "..label)
					end
					if toclose.label ~= label then
						error("trying to close "..toclose.label.." with "..label)
					end
					--print('node value', top.value, #stack, label, toclose.value)
					top.value = (top.value or {})
					local v = top.value[label]
					if not v then
						top.value[label] = toclose
					elseif type(v) ~= 'table' then
						v = {v, toclose}
						top.list = true
						top.value[label] = v
					else
						table.insert(top.value[label], toclose)
					end
					toclose.label = nil --> remove label (only for parsing)
				end
				i = j+1
			end
			local text = string.sub(s, i)
			if not string.find(text, "^%s*$") then
				stack[#stack].CDATA = stack[#stack].CDATA or {}
				table.insert(top.CDATA, text)
			end
			if #stack > 1 then
				error("unclosed "..stack[#stack][0])
			end
			return stack[1]
		end,
	}
end)()

-- this code from lua-users.org/wiki/BaseSixtyFour. thanks!
_M.b64 = (function ()
	-- character table string
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	-- encoding
	local function enc(data)
		return ((data:gsub('.', function(x)
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end

	-- decoding
	local function dec(data)
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end
	return {
		encode = enc,
		decode = dec,
	}
end)()

_M.hexdigit2int = function (ch)
	local b = ch:byte()
	if b >= ('a'):byte() then
		return 10 + (b - ('a'):byte())
	elseif b >= ('0'):byte() then
		return b - ('0'):byte()
	else
		_M.assert(false)
	end
end
_M.to_bin = function (str)
	local data = ''
	str:lower():gsub('([a-z0-9])([a-z0-9])', function (d1, d2)
		d1 = _M.hexdigit2int(d1)
		d2 = _M.hexdigit2int(d2)
		data = (data .. string.char(d1 * 16 + d2))
	end)
	return data
end
_M.to_hex = function (str)
	local data = ''
	for i=1,#str,1 do
		data = (data .. ("%02x"):format(str:byte(i)))
	end
	return data
end

_M.sha2 = require 'lua-aws.deps.sha2'

_M.hmac = (function ()
	--local hmac = require 'hmac'
	local sha2 = _M.sha2

	-- these hmac-ize routine is from https://github.com/bjc/prosody/blob/master/util/hmac.lua.
	-- thanks!
	local s_char = string.char;
	local s_gsub = string.gsub;
	local s_rep = string.rep;
	local xor_map = {0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;1;0;3;2;5;4;7;6;9;8;11;10;13;12;15;14;2;3;0;1;6;7;4;5;10;11;8;9;14;15;12;13;3;2;1;0;7;6;5;4;11;10;9;8;15;14;13;12;4;5;6;7;0;1;2;3;12;13;14;15;8;9;10;11;5;4;7;6;1;0;3;2;13;12;15;14;9;8;11;10;6;7;4;5;2;3;0;1;14;15;12;13;10;11;8;9;7;6;5;4;3;2;1;0;15;14;13;12;11;10;9;8;8;9;10;11;12;13;14;15;0;1;2;3;4;5;6;7;9;8;11;10;13;12;15;14;1;0;3;2;5;4;7;6;10;11;8;9;14;15;12;13;2;3;0;1;6;7;4;5;11;10;9;8;15;14;13;12;3;2;1;0;7;6;5;4;12;13;14;15;8;9;10;11;4;5;6;7;0;1;2;3;13;12;15;14;9;8;11;10;5;4;7;6;1;0;3;2;14;15;12;13;10;11;8;9;6;7;4;5;2;3;0;1;15;14;13;12;11;10;9;8;7;6;5;4;3;2;1;0;};
	local function xor(x, y)
		local lowx, lowy = x % 16, y % 16;
		local hix, hiy = (x - lowx) / 16, (y - lowy) / 16;
		local lowr, hir = xor_map[lowx * 16 + lowy + 1], xor_map[hix * 16 + hiy + 1];
		local r = hir * 16 + lowr;
		return r;
	end
	local opadc, ipadc = s_char(0x5c), s_char(0x36);
	local ipad_map = {};
	local opad_map = {};
	for i=0,255 do
		ipad_map[s_char(i)] = s_char(xor(0x36, i));
		opad_map[s_char(i)] = s_char(xor(0x5c, i));
	end
	local function hmac(key, message, hash, blocksize)
		if #key > blocksize then
			key = hash(key)
		end

		local padding = blocksize - #key;
		local ipad = s_gsub(key, ".", ipad_map)..s_rep(ipadc, padding);
		local opad = s_gsub(key, ".", opad_map)..s_rep(opadc, padding);

		return hash(opad..hash(ipad..message))
	end
	local sha256 = function (data)
		local text = sha2.hash256(data)
		return _M.to_bin(text)
	end
	local digest_routines = {
		hex = _M.to_hex,
		base64 = _M.b64.encode
	}
	local hmac_sha256 = function (key, data, digest)
		local bin = hmac(key, data, sha256, 64)
		--	print(_M.to_hex(bin))
		--local bin = _M.to_bin("8BDD6729CE0F580B7424921D5F0CFD1F1642243762CBA71FFCC8FABCFC72608B")
		return digest_routines[digest] and digest_routines[digest](bin) or bin
	end

	-- here simple test from http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-query-api.html#query-authentication
	local test_key = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
	local test = [[GET
elasticmapreduce.amazonaws.com
/
AWSAccessKeyId=AKIAIOSFODNN7EXAMPLE&Action=DescribeJobFlows&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2011-10-03T15%3A19%3A30&Version=2009-03-31]]

	local test_enc = hmac_sha256(test_key, test, 'base64')
	assert(test_enc == 'i91nKc4PWAt0JJIdXwz9HxZCJDdiy6cf/Mj6vPxyYIs=')
	--]]
	return hmac_sha256
end)()

_M.split = function (str, seps)
	local r = {}
	for v in str:gmatch("([^" .. seps .."]*)[" .. seps .. "]*") do
		table.insert(r, v)
	end
	return r
end
_M.join = function (array, seps)
	local r = ""
	for idx,v in ipairs(array) do
		r = (r .. v .. (idx < #array and seps or ""))
	end
	return r
end
_M.file_exists = function (path, type)
	local cmd = ([[
if [ %s "%s" ]; then
echo '1'
else
echo '0'
fi
]]):format(type or "-r", path)
	local r = io.popen(cmd):read('*l')
	return tonumber(r) ~= 0
end
_M.search_path_with_lua_config = function (path)
	local settings = _M.split(package.path, ';')
	for idx,setting in ipairs(settings) do
		local p = setting:gsub('(.*/)[^/]*', '%1')
		local test = (p .. path):gsub('[^/]*$', '')
		if p and _M.file_exists(test) then
			return p .. path
		end
	end
	return false
end
_M.get_json_part = function (path)
	local f = io.open(path, 'r')
	local str = f:read('*a')
	--[[ TODO: faster load
	while true do
		local line = f:read('*l')
		if not line then
			break
		end
		if not str then
			if type(line) == 'string' and line:match('module.exports') then
				str = '{'
			end
		else
			str = (str ..
				line:gsub("'(.+)'",
					function (s1) return ('"%s"'):format(s1) end)
					:gsub('(%w+):(%s*)',
					function (s1, s2) return ('"%s":%s'):format(s1, s2) end) .. "\n"
			)
		end
	end ]]
	return str
end
local dirscanner = class.AWS_Util_DirectoryScanner {
	initialize = function (self, path)
		self._path = path
		if _M.file_exists(path) then
			self._path = path
		else
			self._path = _M.search_path_with_lua_config(path)
		end
		self:rewind()
	end,
	rewind = function (self)
		self._source = io.popen('ls ' .. self._path)
	end,
	read = function (self)
		return self._source:read()
	end,
	each = function (self, param, iter)
		if not iter then
			iter = param
			param = nil
		end
		while true do
			local name = self:read()
			if not name then break end
			local r = iter(name, param)
			if r == false then return r end
		end
		return true
	end,
}
_M.dir = function (path)
	return dirscanner.new(path)
end
-- following 2 is from
-- 	https://github.com/msva/lua-curl/blob/master/examples/browser.lua. thanks!!
-----------------------------------------------------------------------------
-- Encodes a string into its escaped hexadecimal representation
-- Input
--   s: binary string to be encoded
-- Returns
--   escaped representation of string binary
-- taken from Lua Socket and added underscore to ignore (MIT-License)
-----------------------------------------------------------------------------
function _M.escape(s)
    return string.gsub(s, "([^A-Za-z0-9_%-%.])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

-----------------------------------------------------------------------------
-- Encodes a string into its escaped hexadecimal representation
-- Input
--   s: binary string to be encoded
-- Returns
--   escaped representation of string binary
-- taken from Lua Socket
-----------------------------------------------------------------------------
function _M.unescape(s)
     return string.gsub(s, "%%(%x%x)", function(hex)
         return string.char(tonumber(hex, 16))
    end)
end

_M.query_params_to_string = function (params)
	local items = {};
	local escape = _M.escape
	local sorted_keys = {}

	for k,v in pairs(params) do
		table.insert(sorted_keys, k)
	end
	table.sort(sorted_keys, function (a, b)
		return b > a
	end)

	for idx, name in ipairs(sorted_keys) do
		local value = params[name]
		local ename = escape(name)
		local result = ename
		if type(value) == 'table' then
			local vals = {}
			for idx,item in ipairs(value) do
				table.insert(vals, escape(item))
			end
			table.sort(vals, function (a, b)
				return b < a
			end)
			result = (ename .. '=' .. _M.join(vals, '&' .. ename .. '='))
		elseif value then
			result = (ename .. '=' .. escape(value))
		end
		table.insert(items, result)
	end
	return _M.join(items, '&')
end

_M.pathname = function (path)
	local pos = path:find('?')
	return pos and path:sub(1, pos) or path
end
_M.searchname = function (path)
	local pos = path:find('?')
	return pos and path:sub(pos) or ""
end

_M.user_agent = function ()
	return "lua-aws"
end

_M.chop = function (str)
	local l = #str
	local cnt = 0
	while true do
		local ch = str:byte(l)
		if ch == ('\r'):byte() or ch == ('\n'):byte() then
			l = (l - 1)
		else
			break
		end
		cnt = (cnt + 1)
		if cnt > #str then
			assert(false, "too much check:" .. cnt)
		end
	end
	return str:sub(1, l)
end

--[[
	built in http client by using luasocket or cURL

	input =>
	local req = {
		path = endpoint:path(),
		headers = {"header-name" = "header-value", ...},
		params = {},
		body = '',
		host = endpoint:host(),
		port = endpoint:port(),
		protocol = endpoint:protocol(),
		method = string
	}

	output =>
	local resp = {
		status = number,
		headers = {"header-name" = "header-value", ...},
		body = string,
	}
	returns lua table (any format)
]]--
_M.fill_header = function (req)
	if (not req.headers["Content-Length"]) and req.method == "POST" then
		req.headers["Content-Length"] = #req.body
	end
	req.headers["Connection"] = "Keep-Alive"
end
_M.http_print = function (...)
	-- print(...)
end

_M.date = {
	iso8601 = function (val)
		local tmp = os.date("!%Y-%m-%dT%TZ", val)
		return tmp
	end,
	rfc822 = function (val)
		return os.date("!%a, %d %b %y %T %z", val)
	end,
	unixTimestamp = function (val)
		return tostring(os.time(val))
	end,
}

function _M.script_path()
   local str = debug.getinfo(2, "S").source:sub(2)
   local res = str:match("(.*/)")
   return res
end

return _M
