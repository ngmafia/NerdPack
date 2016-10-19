local _, NeP = ...

--[[
local Roles = {
	['TANK'] = 1,
	['HEALER'] = 1,
	['DAMAGER'] = 1,
	['NONE'] = 1
}]]

-- Lowest
NeP.FakeUnits:Add('lowest', function(num, role)
	local tempTable = {}
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		if not role or (role and Obj.role == role:upper()) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				health = Obj.health
			}
		end
	end
	table.sort( tempTable, function(a,b) return a.health < b.health end )
	return tempTable[num] and tempTable[num].key
end)

-- Lowest
NeP.FakeUnits:Add('tank', function(num)
	local tempTable = {}
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		if Obj.role == 'TANK' and not UnitIsUnit('player', Obj.key) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				health = Obj.health
			}
		end
	end
	table.sort( tempTable, function(a,b) return a.health < b.health end )
	return tempTable[num] and tempTable[num].key
end)
