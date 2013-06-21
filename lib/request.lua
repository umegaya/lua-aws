local _M = {}

_M.query = require ('requests.query')
_M.json = require ('requests.json')
_M.rest = require ('requests.rest')
_M.rest_json = require ('requests.rest_json')
_M.rest_xml = require ('requests.rest_xml')

return _M

