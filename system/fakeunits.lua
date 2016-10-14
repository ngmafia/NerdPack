local _, NeP = ...

NeP.FakeUnits = {}
NeP.Globals.FakeUnits = NeP.FakeUnits
local Units = {}

local Roles = {
	['TANK'] = 2,
	['HEALER'] = 1.5,
	['DAMAGER'] = 1,
	['NONE'] = 1	 
}


function NeP.FakeUnits:Add(Name, Func)
	if not Units[Name] then
		Units[Name] = Func
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