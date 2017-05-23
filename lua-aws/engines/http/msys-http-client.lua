-- Copyright (c) 2015, 2016 Message Systems, Inc. All rights reserved

require('msys.http.client');
local util = require 'lua-aws.util'

return function (req)
  local h = msys.http.client.new();
  util.fill_header(req)
  for k, v in pairs(req.headers) do
    h:set_header(k .. ": " .. v)
  end
  -- XXX Make this support parsing req.protocol
  local uri = "https://" .. req.host .. ":" .. req.port .. req.path
  -- XXX: Unable to transparently hand off work to a threadpool here,
  -- so we use a sync request and require the caller of lua-aws
  -- to use msys.runInPool().
  -- See https://github.com/MessageSystems/lua-aws/issues/6
  local success, errstr, errcode = h:request(req.method, uri, req.body);

  local status = h:get_status();
  return {
    status = tonumber(status),
    body = success and h:get_body() or nil,
    headers = success and h:parse_headers() or nil,
  }
end

-- vim:ts=2:sw=2:et:
