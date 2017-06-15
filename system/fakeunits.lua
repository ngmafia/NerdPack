local _, NeP = ...

NeP.FakeUnits = {}
NeP.Globals.FakeUnits = NeP.FakeUnits
local Units = {}

local function _add(name, func)
	if not Units[name] then
		Units[name] = func
	end
end

function NeP.FakeUnits:Add(name, func)
	if type(name) == 'table' then
		for i=1, #name do
			_add(name, func)
		end
	elseif type(name) == 'string' then
		_add(name, func)
	else
		NeP.Core:Print("ERROR! tried to add an invalid fake unit")
	end
end

function NeP.FakeUnits:Filter(unit)
	for token,func in pairs(Units) do
		if unit:find(token) then
			local arg2 = unit:match('%((.+)%)')
			local num = unit:match("%d+") or 1
			return func(tonumber(num), arg2)
		end
	end
	return unit
end
