-- Copyright (c) 2016 Message Systems, Inc. All rights reserved

local posix = require("posix")

return {
  scandir = function(path, prefix, fn)
    local pattern = "^" .. prefix
    local d = posix.dir(path)
    for _, file in ipairs(d) do
      if file:match(pattern) then
        fn(path .. "/" .. file)
      end
    end
  end,
}

-- vim:ts=2:sw=2:et:
