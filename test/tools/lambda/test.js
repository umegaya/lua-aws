const blake2 = require('blake2')

const text = "lua-aws"
console.log(blake2.createHash('blake2b').update(
    Buffer.from(text)
).digest('hex'))
