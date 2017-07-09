local _, NeP = ...

NeP.DSL = {}
local conditions = {}
local noop = function() end

function NeP.DSL.Get(_, Strg)
	Strg = Strg:lower()
	if conditions[Strg] then
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
