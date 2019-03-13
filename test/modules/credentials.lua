local Credentials = require ('lua-aws.credentials')

local credentials = Credentials.new({
  accessKeyId = os.getenv('AWS_ACCESS_KEY'),
  secretAccessKey = os.getenv('AWS_SECRET_KEY'),
})

assert(credentials:accessKeyId)
assert(credentials:secretAccessKey)
assert(not credentials:needsRefresh())
assert(credentials:get())
