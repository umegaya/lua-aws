return function( req )
    
    local lua_resty_http = require 'resty.http'
    local httpc = lua_resty_http.new()
    
    local u = require 'lua-aws.util'
    u.fill_header( req )
    
    -- req.protocol is being parsed and passed incorrectly by lua-aws, so hardcode it to https for now
    local url = "https://" .. req.host .. ":" .. req.port .. req.path
    
    local opts = {
        -- To enable SSL certificate verification, set the lua_ssl_trusted_certificate line in nginx.conf
        -- and then remove the following line (see https://github.com/pintsized/lua-resty-http/issues/42):
        ssl_verify = false,
        
        method = req.method,
        body = req.body,
        headers = req.headers
    }
    if req.method == 'GET' then
    elseif req.method == 'POST' then
        opts[ 'body' ] = req.body
    else
        error( 'Method not supported: ' .. req.method )
    end
    
    local res, err = httpc:request_uri( url, opts )
    if not res then error( err ) end
    
    return {
        status = res.status,
        body = res.body,
        headers = res.headers,
    }
    
end
