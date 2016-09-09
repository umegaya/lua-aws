-- Copyright (c) 2016 Message Systems, Inc. All rights reserved

local evp = require('msys.evp')

return {
    hash_sha256 = function (message, output_format)
      if output_format == 'buffer' then
        return evp.digest('sha256', message)
      elseif output_format == 'hex' then
        return evp.hex_digest('sha256', message)
      else
        error("output_format '" .. output_format ..
              "' is not supported by the msys-evp crypto engine")
      end
    end,

    hmac_sha256 = function (key, message, output_format)
      if output_format == 'buffer' then
        return evp.hmac('sha256', key, message)
      elseif output_format == 'hex' then
        return evp.hex_hmac('sha256', key, message)
      else
        error("output_format '" .. output_format ..
              "' is not supported by the msys-evp crypto engine")
      end
    end,
     
}