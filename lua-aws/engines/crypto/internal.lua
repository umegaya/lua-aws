local util = require('lua-aws.util')
local sha2 = require('lua-aws.deps.sha2')

return {
    hash_sha256 = function (message, output_format)
      return sha2.hash256(message, output_format)
    end,

    hmac_sha256 = function (key, message, output_format)
      return util.hmac(key, message, output_format) 
    end,
}
