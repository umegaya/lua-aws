local helper = require 'test.helper.util'
local util = require 'lua-aws.util'
helper.dump = true

local resp = [[<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>302 Found</title>
</head><body>
<h1>Found</h1>
<p>The document has moved <a href="http://s3.amazonaws.com/index.php?http://s3.amazonaws.com/lua-aws-test-1514166120">here</a>.</p>
</body></html>]]

local r = util.xml.decode(resp)
helper.dump_res('parse http error', r)
assert(r.value.html.value.head.value.title.value == '302 Found')
assert(r.value.html.value.body.value.p.value[1] ==	'The document has moved ')
assert(r.value.html.value.body.value.p.value[2] == '.')
assert(r.value.html.value.body.value.p.value.a.xarg.href =='http://s3.amazonaws.com/index.php?http://s3.amazonaws.com/lua-aws-test-1514166120')
assert(r.value.html.value.body.value.p.value.a.value =='here')


local header_field_name = 'x-amz-meta-'
local header_field_name2 = "!#$%&'*+-.^_`|~"
assert(util.escape_header_name_as_regex(header_field_name) == 'x%-amz%-meta%-')
assert(util.escape_header_name_as_regex(header_field_name2) == "%!%#%$%%%&%'%*%+%-%.%^%_%`%|%~")
