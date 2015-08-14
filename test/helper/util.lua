local availables = require 'lua-aws.engines.available'
local _M = {}

function _M.iterate_all_engines(test_name, test)
	for _, h in ipairs(availables.http) do
		for _, j in ipairs(availables.json) do
			for _, f in ipairs(availables.fs) do
				test {
					http = h,
					json = j,
					fs = f,
					strict = true,
				}
				print(test_name, h, j, f, "ok")
			end
		end
	end
end

function _M.dump_res(tag, res)
	if dump then
		for k,v in pairs(res) do
			print(tag, k, v)
			if type(v) == 'table' then
				dump_res(tag.."."..k, v)
			end
		end
	end
end

return _M
