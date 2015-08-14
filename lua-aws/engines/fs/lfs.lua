local lfs = require 'lfs'

return {
	scandir = function (path, prefix, fn)
		local pattern = "^"..prefix
		for file in lfs.dir(path) do
			if file:match(pattern) then
				fn(path..file)
			end
		end
	end,
}
