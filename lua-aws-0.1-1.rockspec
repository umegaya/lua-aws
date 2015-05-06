package = "lua-aws"
version = "0.1-1"
source = {
  url = "git://github.com/umegaya/lua-aws.git"
}
description = {
  summary = "Pure-lua implementation of AWS REST APIs",
  detailed = [[
    It heavily inspired by aws-sdk-js, 
    which main good point is define all AWS sevices by JS data structure. 
    and library read these data and building API code on the fly
  ]],
  homepage = "https://github.com/umegaya/lua-aws",
  license = " Apache License 2.0"
}
dependencies = {
  "lua ~> 5.1"
}
build = {
  type = "command",
  install_command = "cp -r lua-aws /usr/local/share/lua/5.1/lua-aws",
}
