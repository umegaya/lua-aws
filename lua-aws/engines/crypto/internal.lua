local util = require('lua-aws.util')
local sha2 = require('lua-aws.deps.sha2')

return {
    hash_sha256 = sha2.hash256,  -- args: (message, output_format)
    hmac_sha256 = util.hmac,     -- args: (key, message, output_format)
}
