local cjson = require 'cjson'

return {
	encode = cjson.encode,
	decode = cjson.decode,
	null = cjson.null
}
