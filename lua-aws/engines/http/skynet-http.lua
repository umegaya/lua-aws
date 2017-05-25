local httpc = require "http.httpc"
local util = require 'lua-aws.util'

return function (req, resp)
	util.fill_header(req)
    resp = resp or {}
    local recvheader = {}
    local status, body = httpc.request(req.method, req.host..":"..req.port, nil, recvheader, req.headers, req.body)
    resp.status = status
    resp.body = body
    resp.headers = recvheader
    return resp
end
