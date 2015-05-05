package = "lua-aws"
version = "0.1-1"
source = {
  url = "https://github.com/umegaya/lua-aws.git"
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
  "lua ~> 5.1",
  "dkjson"
}
build = {
  type = "builtin",
  copy_directories = {
    "lua-aws/services/definitions"
  },
  modules = {
    ["lua-aws"] = "lua-aws/init.lua",
    ["lua-aws.class"] = "lua-aws/class.lua",
    ["lua-aws.deps.sha1"] = "lua-aws/deps/sha1.lua",
    ["lua-aws.deps.slaxdom"] = "lua-aws/deps/slaxdom.lua",
    ["lua-aws.deps.slaxml"] = "lua-aws/deps/slaxml.lua",
    ["lua-aws.deps.sha2"] = "lua-aws/deps/sha2.lua",
    ["lua-aws.request"] = "lua-aws/request.lua",
    ["lua-aws.requests.rest"] = "lua-aws/requests/rest.lua",
    ["lua-aws.requests.rest_json"] = "lua-aws/requests/rest_json.lua",
    ["lua-aws.requests.rest_xml"] = "lua-aws/requests/rest_xml.lua",
    ["lua-aws.requests.base"] = "lua-aws/requests/base.lua",
    ["lua-aws.requests.endpoint"] = "lua-aws/requests/endpoint.lua",
    ["lua-aws.requests.json"] = "lua-aws/requests/json.lua",
    ["lua-aws.requests.query"] = "lua-aws/requests/query.lua",
    ["lua-aws.requests.query_string_serializer"] = "lua-aws/requests/query_string_serializer.lua",
    ["lua-aws.services.dynamodb"] = "lua-aws/services/dynamodb.lua",
    ["lua-aws.services.ec2"] = "lua-aws/services/ec2.lua",
    ["lua-aws.services.sqs"] = "lua-aws/services/sqs.lua",
    ["lua-aws.services.base"] = "lua-aws/services/base.lua",
    ["lua-aws.services.kinesis"] = "lua-aws/services/kinesis.lua",
    ["lua-aws.services.sns"] = "lua-aws/services/sns.lua",
    ["lua-aws.signer"] = "lua-aws/signer.lua",
    ["lua-aws.signers.base"] = "lua-aws/signers/base.lua",
    ["lua-aws.signers.cloudfront"] = "lua-aws/signers/cloudfront.lua",
    ["lua-aws.signers.s3"] = "lua-aws/signers/s3.lua",
    ["lua-aws.signers.v3"] = "lua-aws/signers/v3.lua",
    ["lua-aws.signers.v3https"] = "lua-aws/signers/v3https.lua",
    ["lua-aws.signers.v2"] = "lua-aws/signers/v2.lua",
    ["lua-aws.signers.v4"] = "lua-aws/signers/v4.lua",
    ["lua-aws.api"] = "lua-aws/api.lua",
    ["lua-aws.core"] = "lua-aws/core.lua",
    ["lua-aws.engines.curl"] = "lua-aws/engines/curl.lua",
    ["lua-aws.engines.luasocket"] = "lua-aws/engines/luasocket.lua",
    ["lua-aws.util"] = "lua-aws/util.lua"
  }
}