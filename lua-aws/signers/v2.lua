local class = require ('lua-aws.class')
local Signer = require ('lua-aws.signers.base')
local util = require ('lua-aws.util')

return class.AWS_V2Signer.extends(Signer) {
	initialize = function (self)
	end,
	sign = function (self, r, credentials, timestamp)
		r.params.Timestamp = timestamp
		r.params.SignatureVersion = '2'
		r.params.SignatureMethod = 'HmacSHA256'
		r.params.AWSAccessKeyId = credentials.accessKeyId
		
		if credentials.sessionToken then
			r.params.SecurityToken = credentials.sessionToken;
		end
		
		r.params.Signature = self:signature(r, credentials);
		r.body = util.query_params_to_string(r.params)
		r.headers['Content-Length'] = r.body.length
	end,

	signature = function (self, r, credentials)
		return util.hmac(credentials.secretAccessKey, self:string_to_sign(r), 'base64')
	end,

	string_to_sign = function (self, req)
		local parts = {
			req.method,
			req.host:lower(),
			util.pathname(req.path),
			util.query_params_to_string(req.params),
		}
		local str = util.join(parts, '\n')
		--print('str2sign:', '['.. str .. ']')
		return str
	end,
}
