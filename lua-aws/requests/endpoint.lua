local class = require ('lua-aws.class')
local util = require ('lua-aws.util')

return class.AWS_Endpoint {
	initialize = function (self, endpoint, config)
		util.assert(type(endpoint) == 'string', "invalid type of endpoint:" .. type(endpoint))

		if not endpoint:match("http") then
			local useSSL = (config and config.sslEnabled) and config.sslEnabled or false
			endpoint = (useSSL and 'https' or 'http') .. '://' .. endpoint
		end

		--print('endpoint = ', endpoint)
		endpoint:gsub('(.*)://(.*)', function (s1, s2)
			local host, port, path
			local pos = s2:find(':')
			if pos then
				host = s2:sub(1,pos-1)
				local remain = s2:sub(pos + 1)
				pos = remain:find('/')
				if pos then
					port,path = tonumber(remain:sub(1, pos)),remain:sub(pos + 1)
				else
					port,path = tonumber(remain),false
				end

			else
				pos = s2:find('/')
				if pos then
					host,port,path = s2:sub(1, pos),false,s2:sub(pos + 1)
				else
					host,port,path = s2,false,false
				end
			end
		        self._protocol,self._host,self._port,self._path = s1, host, port, path
		end)
		if not self._port then
			self._port = (self._protocol == 'http' and 80 or 443)
		end
		if not self._path then
			self._path = '/'
		end
	end,
	host = function (self) return self._host end,
	port = function (self) return self._port end,
	path = function (self) return self._path end,
	protocol = function (self) return self._protocol end,
	pathname = function (self) return util.pathname(self._path) end,
	searchname = function (self) return util.searchname(self._path) end,
	to_s = function (self) return (self._protocol .. "://" .. self._host .. ':' .. self._port) end,

}
