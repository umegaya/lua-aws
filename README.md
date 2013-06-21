lua-aws
=======

### pure-lua AWS REST API binding



## Concept
it heavily inspired by [aws-sdk-js](https://raw.github.com/aws/aws-sdk-js/),
which main good point is define all AWS sevices by JSON. and library load these JSON and 
building API code on the fly. so AWS JS SDK is:
- less code to maintain
- only need to update JSON service definition to follow the new version or change of the service API.

also aws-sdk-js seems to be well designed, 
so I decide to copy its architecture, without copying callback storm of aws-sdk-js (only vexing point of it)



## Current Status

only some API of EC2 tested. almost EC2 API is not tested and even entry does not exist most of AWS services.
but I think almost code service-indepenent and well modularized, so it not so hard support other services
if signers and requests are fully implemented.

I currently developing network game which application code is entirely written in lua, and this binding will be used for it,
after that, more services will be support and library itself will be more stable. but now, I don't have enough time to complete this project.



## External libs
- [dkjson](http://dkolf.de/src/dkjson-lua.fsl/home) to decode/encode JSON
- [SLAXML](https://github.com/Phrogz/SLAXML) currently not used, but will be used for encoding
- [sha2](http://lua-users.org/wiki/SecureHashAlgorithm) to generate SHA-256 hash
- [hmac](https://github.com/bjc/prosody/blob/master/util/hmac.lua) to implement Hmac_SHA256 routine

and more code snippets help me to build authentication routines. thanks!


## Installing

unfortunately there is no rockspec so please copy them directory like /usr/local/share/lua/5.1/ manually.



## Usage

need to add ${lua-aws path}/lib to package.path.

see test/ec2.lua

```lua
local AWS = require ('aws')
AWS = AWS.new({
	accessKeyId = os.getenv('AWS_ACCESS_KEY'),
	secretAccessKey = os.getenv('AWS_SECRET_KEY')
})

local res,err = AWS.EC2:api():describeInstances()
```

you can get multiple version
```lua
local res,err = AWS.EC2:api_by_version('2013-02-01'):describeInstances()
```



## License

if it will be more solid, This SDK will be distributed under the
[Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

```no-highlight
Copyright 2013. Takehiro Iyatomi (iyatomi@gmail.com). All Rights Reserved.

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
