local _M = {}

_M.cloudfront = require('signers.cloudfront')
_M.s3 = require ('signers.s3')
_M.v2 = require ('signers.v2')
_M.v3 = require ('signers.v3')
_M.v3https = require ('signers.v3https')
_M.v4 = require ('signers.v4')

return _M
