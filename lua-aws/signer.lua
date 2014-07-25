local _M = {}

_M.cloudfront = require('lua-aws.signers.cloudfront')
_M.s3 = require ('lua-aws.signers.s3')
_M.v2 = require ('lua-aws.signers.v2')
_M.v3 = require ('lua-aws.signers.v3')
_M.v3https = require ('lua-aws.signers.v3https')
_M.v4 = require ('lua-aws.signers.v4')

return _M
