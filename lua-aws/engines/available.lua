return {
	-- try resty http first on openresty
	http = ngx and
		{ "lua-resty-http", "luasocket", "curl" } or
		{ "luasocket", "curl", "lua-resty-http" },
	fs = { "lfs", "os", "mock" },
	json = { "cjson", "dkjson" },
}
