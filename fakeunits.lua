local _, NeP = ...

local UnitIsUnit = UnitIsUnit
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

NeP.FakeUnits:Add('lowestpredicted', function(num, role)
	local tempTable = {}
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		if not role or (role and Obj.role == role:upper()) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				health = Obj.predicted
			}
		end
	end
	table.sort( tempTable, function(a,b) return a.health < b.health end )
	return tempTable[num] and tempTable[num].key
end)

-- lowest with certain buff
NeP.FakeUnits:Add('lbuff', function(num, args)
  local role, buff = strsplit(',', args, 2)
    local tempTable = {}
    for _, Obj in pairs(NeP.Healing:GetRoster()) do
        if Obj.role == role and NeP.DSL:Get('buff')(Obj.key, buff) then
            tempTable[#tempTable+1] = {
                key = Obj.key,
                health = Obj.health
            }
        end
    end
    table.sort( tempTable, function(a,b) return a.health < b.health end )
    return tempTable[num] and tempTable[num].key
end)

-- lowets without certain buff
NeP.FakeUnits:Add('lnbuff', function(num, args)
  local role, buff = strsplit(',', args, 2)
    local tempTable = {}
    for _, Obj in pairs(NeP.Healing:GetRoster()) do
        if Obj.role == role and not NeP.DSL:Get('buff')(Obj.key, buff) then
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
				prio = Obj.healthMax
			}
		end
	end
	table.sort( tempTable, function(a,b) return a.prio > b.prio end )
	return tempTable[num] and tempTable[num].key
end)
