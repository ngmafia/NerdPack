local _, NeP = ...

NeP.FakeUnits = {}
NeP.Globals.FakeUnits = NeP.FakeUnits
local Units = {}

local function _add(name, func)
	if not Units[name] then
		Units[name] = func
	end
end

function NeP.FakeUnits.Add(_, name, func)
	if type(name) == 'table' then
		for i=1, #name do
			_add(name[i], func)
		end
	elseif type(name) == 'string' then
		_add(name, func)
	else
		NeP.Core:Print("ERROR! tried to add an invalid fake unit")
	end
end

function NeP.FakeUnits.Filter(_, unit)
	-- Find and remove num and arg
	local arg = unit:match('%((.+)%)')
	local num = unit:match("%d+") or 1
	if Units[unit] then
		unit = unit:gsub(arg or '', '')
		unit = unit:gsub(num or '', '')
		return Units[unit](tonumber(num), arg)
	end
	return unit
end
