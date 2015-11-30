local _M = {}

_M.query = require ('lua-aws.requests.query')
_M.ec2 = _M.query -- seems to same
_M.json = require ('lua-aws.requests.json')
_M.rest = require ('lua-aws.requests.rest')
_M["rest-json"] = require ('lua-aws.requests.rest_json')
_M["rest-xml"] = require ('lua-aws.requests.rest_xml')

return _M

