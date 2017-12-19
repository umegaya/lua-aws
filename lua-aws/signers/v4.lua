local class = require ('lua-aws.class')
local Signer = require ('lua-aws.signers.base')
local util = require ('lua-aws.util')
local sec_cache = {}
local unsignable_headers = {
	'authorization', 'content-type', 'user-agent',
	'x-amz-user-agent', 'x-amz-content-sha256'
}

return class.AWS_V4Signer.extends(Signer) {
	initialize = function (self, api)
		self._api = api
	end,
	sign = function (self, req, credentials, timestamp)
		self:add_authorization(req, credentials, timestamp)
	end,
    signature = function (self, req, credentials, datetime)
		local signature_name = self._api:signature_name()
		local c = sec_cache[signature_name]
		local date = datetime:sub(1, 8)
		if (not c) or
			(c.akid ~= credentials.accessKeyId) or
			(c.region ~= self._api:region()) or 
			(c.date ~= date) then
			local kSecret = credentials.secretAccessKey
			local kDate = util.hmac('AWS4'..kSecret, date, 'buffer')
			local kRegion = util.hmac(kDate, self._api:region(), 'buffer')
			local kService = util.hmac(kRegion, self._api:signature_name(), 'buffer')
			local kCredentials = util.hmac(kService, 'aws4_request', 'buffer')
			sec_cache[signature_name] = {
				region = self._api:region(), date = date,
				key = kCredentials, akid = credentials.accessKeyId
			}
		end

		local key = sec_cache[signature_name].key
		return util.hmac(key, self:string_to_sign(req, datetime), 'hex');
	end,
	string_to_sign = function (self, req, datetime)
		local parts = {
			'AWS4-HMAC-SHA256',
			datetime,
			self:credential_string(datetime),
			self:hex_encoded_hash(self:canonical_string(req)),
		}
		local str = table.concat(parts, '\n')
		-- print('str2sign:', '['.. str .. ']')
		return str
	end,
	credential_string = function (self, datetime)
		local parts = {
			datetime:sub(1, 8),
			self._api:region(),
			self._api:signature_name(),
			'aws4_request'
		}
		local r = table.concat(parts, '/')
		-- print('credential_string:', '[['.. r .. ']]')
		return r
	end,
	hex_encoded_hash = function (self, str)
		return util.sha2.hash256(str, 'hex')
	end,
	canonical_string = function (self, req)
		local parts = {
			req.method,
			util.pathname(req.path),
			util.searchname(req.path),
			self:canonical_headers(req)..'\n',
			self:signed_headers(req),
			self:hex_encoded_body_hash(req),
		}
		local r = table.concat(parts, '\n')
		-- print('canonical_string:', '[['.. r .. ']]')
		return r
	end,
	canonical_headers = function (self, req)
		local parts = {}
		local headers = {}
		for k,v in pairs(req.headers) do
			table.insert(headers, {k, v})
		end
		table.sort(headers, function (a, b)
			return a[1]:lower() < b[1]:lower()
		end)
		for _, h in ipairs(headers) do
			local key = h[1]:lower()
			if self:is_signable_header(key) then
				table.insert(parts, key:lower()..":"..self:canonical_header_values(tostring(h[2])))
			end
		end
		return table.concat(parts, '\n')
	end,
	canonical_header_values = function (self, values)
		return values:gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', '')
	end,
	signed_headers = function (self, req)
		local keys = {}
		for k,v in pairs(req.headers) do
			local key = k:lower()
			if self:is_signable_header(key) then
				table.insert(keys, key)
			end
		end
		table.sort(keys)
		return table.concat(keys, ';')
	end,
	is_signable_header = function (self, key)
		for _, k in ipairs(unsignable_headers) do
			if k == key then
				return false
			end
		end
		return true
	end,
	hex_encoded_body_hash =  function (self, req)
		if req.headers['X-Amz-Content-Sha256'] then
			return req.headers['X-Amz-Content-Sha256'];
		else
			return self:hex_encoded_hash(req.body or '')
		end	
	end,

	add_authorization = function (self, req, credentials, date)
		local tmp = util.date.iso8601()
		local datetime = tmp:gsub('[:%-]', ''):gsub('%.%d%d%d', '')
		self:add_headers(req, credentials, datetime)
		self:update_body(req, credentials)
		req.headers['Authorization'] = self:authorization(req, credentials, datetime)
	end,
	add_headers = function (self, req, credentials, datetime)
		req.headers['X-Amz-Date'] = datetime
		if credentials.sessionToken then
			req.headers['x-amz-security-token'] = credentials.sessionToken;
		end
	end,
	update_body = function (self, req, credentials)
		if req.body_has_sign then 
			-- if req.params is truly, means its query type. so need to create body from params
			-- to add 
			req.params.AWSAccessKeyId = credentials.accessKeyId
			if credentials.sessionToken then
				req.params.SecurityToken = credentials.sessionToken
			end
			req.body = util.query_params_to_string(req.params)
			req.headers['Content-Length'] = req.body.length
		end
	end,
	authorization = function (self, req, credentials, datetime)
		local credstr = self:credential_string(datetime)
		local parts = {
			'AWS4-HMAC-SHA256 Credential='..credentials.accessKeyId..'/'..credstr,
			'SignedHeaders='..self:signed_headers(req),
			'Signature='..self:signature(req, credentials, datetime),
		}
		return table.concat(parts, ', ')
	end,
}
