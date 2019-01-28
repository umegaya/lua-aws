lua-aws
=======

### lua AWS REST API binding



## Concept
it heavily inspired by [aws-sdk-js](https://raw.github.com/aws/aws-sdk-js/),
which main good point is define all AWS sevices by JS data structure. and library read these data and 
building API code on the fly. so AWS JS SDK is:
- less code to maintain
- in almost case, only need to update service definition (from aws-sdk-js :D) to follow the new version or change of the service API.

also aws-sdk-js seems to be well designed, 
so I decide to copy its architecture, without copying callback storm of aws-sdk-js (only vexing point of it)



## Current Status

now it just Proof of Concept.
only some API of EC2, Kinesis,  and SQS tested. almost EC2 API is not tested and even entry does not exist most of AWS services.
but I think almost code service-indepenent and well modularized, so it not so hard support other services
if signers and requests are fully implemented (sorry for my laziness, but patches are welcome!!).

I currently developing network game which application code is entirely written in lua, and this binding will be used for it,
after that, more services will be support and library itself will be more stable. but now, I don't have enough time to complete this project.

EDIT: now some guys seems to use this at least their playground. and v4 signature and json request supported, so more APIs should work (but not tested)



## External libs
- [dkjson](http://dkolf.de/src/dkjson-lua.fsl/home) to decode/encode JSON
- [SLAXML](https://github.com/Phrogz/SLAXML) currently not used, but will be used for encoding
- [sha2](http://lua-users.org/wiki/SecureHashAlgorithm) to generate SHA-256 hash
- [hmac](https://github.com/bjc/prosody/blob/master/util/hmac.lua) to implement Hmac_SHA256 routine
- [base64](http://lua-users.org/wiki/BaseSixtyFour) for base64 encoder

and more code snippets help me to build authentication routines. thanks!


## Installing

now there is only outdated rockspec so please copy them directory like /usr/local/share/lua/5.1/ manually.


## Caveats for lua 5.3 user
- bit library is missing 
  - as of lua 5.3, built-in bit operator like ```&``` is introduced. as a result, no standard bit library is shipped with lua itself, which we used in lua-aws/deps/sha2.lua. so if you want to use lua-aws in such environment, you manually install a module like below which gives compatibility to old bit module. 
    - [bit](https://github.com/aryajur/bit.git) Suggested module to work across Lua versions 5.2 and 5.3


## Usage

see test/ec2.lua

```lua
local AWS = require ('aws')
AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	-- if you write your own http engin
	http_engine = your_http_engine,
	-- if you don't set EC2_URL environment value
	endpoint = "https://ec2.ap-northeast-1.amazonaws.com",
})

local res,err = AWS.EC2:api():describeInstances()
```

where http_engine is callable object of lua which input and output is like following:
```lua
-- input
local req = {
	path = endpoint:path(),
	headers = {"header-name" = "header-value", ...},
	params = {}, -- internal use
	body = "body data",
	host = endpoint:host(),
	port = endpoint:port(),
	protocol = endpoint:protocol(),
	method = string
}

-- output
local resp = {
	status = number,
	headers = {"header-name" = "header-value", ...},
	body = string,
}

-- calling http_engine
resp = http_engine(req)
```

or you just install luasocket, lua-aws detect it autometically and use socket.http to access AWS.



you can get multiple version
```lua
local res,err = AWS.EC2:api_by_version('2013-02-01'):describeInstances()
```

### caution

- current version (from cccc695bfd486f0179d552660dff68044ef79916) will break backward compatibility for return value of api call.
 - because with previous api spec, first argument will be any of response of API (on success), api level error object (on failure at API level), false (on failure at lua level). 
 - and lua level error occurs, it returns lua-error object as its 2nd argument. it is highly inconsistent and should be fixed.
``` lua
local api = AWS.EC2:api()
-- old api call : returns { data or api_level_error or false, lua_level_error(if occurs) }
r, lua_err = api:describeInstances()
-- new api call : returns {status, data or api_level_error or lua_level_error}
ok, r = api:describeInstances()
``` 
- with new API spec, API call returns 2 values which represents status and (response data or api level error or lua level error). 
- add oldReturnValue = true to initial AWS config, you can get previous style return value.
``` lua
local AWS = require ('lua-aws.init')
AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY'),
	oldReturnValue = true,
})
```

### Contributing
- if you fix something, better to make sure it passes test cases. there is 2 way to run test.
  - 1. use real AWS infrastructure
  ```
  # make sure you have export below 2 environment variables.
  export AWS_ACCESS_KEY="your aws access key"
  export AWS_SECRET_KEY="your aws secret key"
  # then just run this
  make test
  ```
  - 2. use mock AWS infrastruture (but some testcases skipped)
  ```
  # install moto_server to mock AWS (instruction from https://github.com/spulec/moto#install)
  pip install moto
  # then run tests with MOCK=1
  make test MOCK=1
  ```


## License

```no-highlight
Copyright 2013-2019. Takehiro Iyatomi (iyatomi@gmail.com). All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
