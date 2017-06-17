local _, NeP = ...

NeP.DSL = {}

local conditions = {}

local Deprecated_Warn = {}
local function Deprecated(Strg)
	if Deprecated_Warn[Strg] then
		NeP.Core:Print(Strg..' Was deprecated, use: '..Deprecated_Warn[Strg].replace..'instead.')
		Deprecated_Warn[Strg] = nil
	end
end

local noop = function() end

function NeP.DSL.Get(_, Strg)
	Strg = Strg:lower()
	if conditions[Strg] then
		Deprecated(Strg)
		return conditions[Strg]
	end
	return noop
end

local function _add(name, condition, overwrite)
	name = name:lower()
	if not conditions[name] or overwrite then
		conditions[name] = condition
	end
end

function NeP.DSL.Register(_, name, condition, overwrite)
	if type(name) == 'table' then
		for i=1, #name do
			_add(name[i], condition, overwrite)
		end
	elseif type(name) == 'string' then
		_add(name, condition, overwrite)
	else
		NeP.Core:Print("ERROR! tried to add an invalid condition")
	end
end

function NeP.DSL:Register_Deprecated(name, replace, condition, overwrite)
	name = name:lower()
	self:Register(name, condition, overwrite)
	if not Deprecated_Warn[name] then
		Deprecated_Warn[name] = {}
		Deprecated_Warn[name].replace = replace
	end
end
