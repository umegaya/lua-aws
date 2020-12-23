const blake2 = require('blake2')

exports.lambdaHandler = async (event) => {
    const text = event.text
    const hashed = blake2.createHash('blake2b').update(
        Buffer.from(text)
    ).digest('hex')
    const response = {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json'
        },
        isBase64Encoded: true,
        body: {
            message: "hello lua aws from container in lambda:" + hashed
        }
    };
    return response;
};
