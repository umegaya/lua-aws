-- class.lua
-- scala style, single inheritance, multiple mix-in-able class
-- mixable class need to implement method 'mixed'. and it will called when target class constructor 
-- try to initialize mixin object instead of normal ctor.

local class = (function ()
	local classes = {}
	local class_factory = function (name)
		local __mixer = function (mixin, self)
			mixin.mixed(self)
			return self
		end
		local __class_lookup = {}
		__class_lookup.exec = function (class, method)
			-->print('classlookupexec:', class.name, method, rawget(class, method))
			if rawget(class, method) then return rawget(class, method) end
			for _,v in ipairs(class.mixin_lookup) do
				local tmp = v[method]
				-->print('mixin', v.name, method, tmp)
				if tmp then return tmp end
			end
			local super = class.super
			while super do
				local tmp = super[method]
				-->print('super', super.name, method, tmp, super.super)
				if tmp then return tmp end
				super = super.super
			end
			return nil
		end
		local __lookup = function(self, method)
			local m = self.class[method]
			if not m then	
				error('no such method: ' .. method .. "\n" .. debug.traceback())
			end
			return m
		end
		local __conflict_detector = function (self)
			return setmetatable({ __proxy = self }, {
				__index = function (t, k) 
					return t.__proxy[k] 
				end,
				__newindex = function (t, k, v) 
					if rawget(t.__proxy, k) then
						error('value for key:' .. k .. ' from mixin:' .. t.__name .. ' of class:' .. t.__proxy.name .. ' already set')
					end
					t.__proxy[k] = v
				end
			})
		end
		local __constructor = function (self, ...)
			-->print('call initialize', self.class.name)
			if not self.class.initialize then
				print('no initializer:', debug.traceback())
			end
			self.class.initialize(self, ...)
			local setter = __conflict_detector(self)
			for _,trait in pairs(self.class.mixin) do
				-->print('mixed:', trait.name)
				rawset(setter, "__name", trait.name)
				trait.mixed(setter)
			end
			local twk = rawget(self.class, "tweak")
			if type(twk) == 'function' then
				twk(self, ...)
			end
			return self
		end	
		local __extends = function (protoclass, super)
			local super_class = (type(super) == 'string' or classes[super] and super)
			if not super_class then
				assert(false, 'no such class: ' .. super)
			end
			protoclass.super = super_class
			if super_class.__extended then
				super_class:__extended(protoclass)
			end
			return protoclass
		end
		local __is_builtin_func_name = function (k)
			return k == 'initialize' or k == 'mixed' or k == "has" or k == "construct" or k == "aspect"
		end
		local __root_class_name = function (klass)
			--> lowest class which defines 'mixed'
			while klass.super do
				if rawget(klass, 'mixed') and (not rawget(klass.super, 'mixed')) then
					break
				end
				klass = klass.super
			end
			return klass.name
		end
		local __mix = function (protoclass, mixed)
			local mixed_class = (type(mixed) == 'string' and classes[mixed] or mixed)
			if not mixed_class then
				assert(false, 'no such class: ' .. mixed)
			end
			local tmp = mixed_class
			while tmp do
				if rawget(tmp, 'mixed') then
					break
				end
				tmp = tmp.super
			end
			--> if this class does not have 'aspect' method, its not mixable
			if not tmp then
				print(debug.traceback())
				assert(false, 'cannot mixable:' .. mixed_class.name) 
			end
			assert(__root_class_name(mixed_class))
			print('mixin:', __root_class_name(mixed_class), mixed_class.name)
			table.insert(protoclass.mixin_lookup, 1, mixed_class)
			return protoclass
		end
		local __newclass = function (protoclass, decl)
			if type(decl) ~= 'table' then
				print(debug.traceback())
			end
			for k,v in pairs(decl) do
				for kk,vv in pairs(protoclass) do
					if k == kk and __is_builtin_func_name(k) then
						print(
							"warning: built in function " .. kk .. 
							" will override by "  .. protoclass.name .. 
							" it may cause unpredictable problem"
						)
					end
				end
				protoclass[k] = v
			end
			--> its not allowed to define same name method is more than 2 traits which belongs to different aspect (in same inheritance stage)
			for aspect,mx in pairs(protoclass.mixin_lookup) do
				for k,v in pairs(mx) do
					for aspect2,mx2 in pairs(protoclass.mixin_lookup) do
						if aspect ~= aspect2 and type(v) == 'function' and mx2[k] then
							--> if protoclass itself have define, we regard function conflict is resolved.
							if (not rawget(protoclass, k)) and (not __is_builtin_func_name(k))then
								assert(false, 'method ' .. k .. ' from mixin:' .. mx.name .. ' and mixin:' .. mx2.name .. ' conflict')
							end
						end
					end
				end
			end
			--> copy parent class's mixin
			for _,mx in ipairs(protoclass.mixin_lookup) do
				protoclass.mixin[mx:aspect()] = mx
			end
			if protoclass.super then
				for k,v in pairs(protoclass.super.mixin) do
					if not protoclass.mixin[k] then
						protoclass.mixin[k] = v
					end
				end
			end
			
			for idx,v in ipairs(protoclass.mixin_lookup) do
				-->print('lookup order:', idx, v.name)
			end
			for k,v in pairs(protoclass.mixin) do
				-->print('mix order:', v.name)
			end
			
			local class = protoclass
			while class and (not rawget(class, 'initialize')) do
				class = class.super
			end
			protoclass.initialize = (class and rawget(class, 'initialize') or (function () end))
			protoclass.__aspect = __root_class_name(protoclass)
			assert(protoclass.name)
			classes[protoclass.name] = protoclass
			return classes[protoclass.name]
		end
		local protoclass = {
			name = name,
			super = false,
			-->__cache = {},
			has = function (self_or_class, name)
				local klass = (self_or_class.class or self_or_class)
				for k,v in pairs(klass.mixin) do
					if v.name == name then
						return true
					end
				end
				return false
			end,
			is_a = function (self_or_class, name)
				local tmp = (self_or_class.class or self_or_class)
				while tmp do
					if tmp.name == name then
						return true
					end
					tmp = tmp.super
				end
				return false
			end,
			extends = setmetatable({}, {
				__index = function (tmp, super)
					return setmetatable({ protoclass = tmp.protoclass, super = super }, {
						__index = function (t, k)
							return __extends(t.protoclass, t.super)[k]
						end,
						__call = function (t, decl)
							return __newclass(__extends(t.protoclass, t.super), decl)
						end,
					})
				end,
				__call = function(t, super)
					return __extends(t.protoclass, super)
				end,
			}),
			with = setmetatable({}, {
				__index = function (tmp, mixed)
					return setmetatable({ protoclass = tmp.protoclass, mixed = mixed }, {
						__index = function(t, k)
							return __mix(t.protoclass, t.mixed)[k]
						end,
						__call = function (t, decl)
							return __newclass(__mix(t.protoclass, t.mixed), decl)
						end,
					})
				end,
				__call = function(t, mixed)
					return __mix(t.protoclass, mixed)
				end,
			}),
			new = setmetatable({}, {
				__call = function(t, ...)
					if not t.protoclass.initialize then
						print(debug.traceback())
					end
					return __constructor(
						setmetatable({ class = t.protoclass }, { __index = __lookup }),
					...)
				end
			}),
			aspect = function (klass)
				return klass.__aspect
			end,
			construct = __constructor,
			__lookup = __lookup,
			mixin = {},
			mixin_lookup = {},
		}
		protoclass.extends.protoclass = protoclass
		protoclass.with.protoclass = protoclass
		protoclass.new.protoclass = protoclass
		return setmetatable(protoclass, { __call = __newclass, __index = __class_lookup.exec })
	end
	return setmetatable(classes, {
		__index = function (t, k)
			return class_factory(k)
		end,
	})
end)()

return class
