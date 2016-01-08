local class = require ('lua-aws.class')
local util = require ('lua-aws.util')

return class.AWS_RequestSerializer {
	initialize = function (self, api, rules)
		self._api = api
		self._rules = rules
	end,

	serialize = function (self, params, fn)
		self:serialize_struct(false, params, self._rules, fn)
	end,

	serialize_struct = function (self, prefix, struct, rules, fn)
		for name, member in pairs(struct) do
			if rules[name] then
				local n = rules[name].name or name
				local memberName = prefix and (prefix .. '.' .. n) or tostring(n)
				self:serialize_member(memberName, member, rules[name], fn)
			else
				print("parameter", name, "has no rule to handle. ignored.")
			end
		end
	end,

	serialize_map = function (self, name, map, rules, fn)
		local i = 1;
		for key,value in pairs(map) do
			local prefix = rules.flattened and '.' or '.entry.'
			local position = prefix .. tostring(i) .. '.'
			i = (i + 1)
			local keyName = (position .. (rules.key.name or 'key'))
			local valueName = (position .. (rules.value.name or 'value'))
			self:serialize_member(name .. keyName, key, rules.key, fn)
			self:serialize_member(name .. valueName, value, rules.value, fn)
		end
	end,

	serialize_list = function (self, name, list, rules, fn)
		local memberRules = rules.member or {}
		for n,v in ipairs(list) do
			local suffix = ('.' .. tostring(n))
			if rules.flattened then
				if memberRules.name then
					local parts = util.split(name, '.')
					table.remove(parts, 1)
					-- There may have been an empty entry on the end, remove it
					if #parts > 0 and parts[#parts] == "" then
						table.remove(parts, #parts)
					end
					table.insert(parts, memberRules.name)
					name = util.join(parts, '.')
				end
			else
				suffix = ('.member' .. suffix)
			end
			self:serialize_member(name .. suffix, v, memberRules, fn)
		end
	end,

	serialize_member = function (self, name, value, rules, fn)
		if rules.type == 'structure' then
			self:serialize_struct(name, value, rules.members, fn)
		elseif rules.type == 'list' then
			self:serialize_list(name, value, rules, fn)
		elseif rules.type == 'map' then
			self:serialize_map(name, value, rules, fn)
		elseif rules.type == 'timestamp' then
			local timestamp_format = (rules.format or self._api:timestamp_format())
			fn(name, util.date_format(value, timestamp_format))
		else
			fn(name, tostring(value))
		end
	end,
}
