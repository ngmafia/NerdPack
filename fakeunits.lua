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

NeP.FakeUnits:Add({'lowestpredicted', 'lowestp'}, function(num, role)
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
NeP.FakeUnits:Add({'lowestbuff', 'lbuff'}, function(num, args)
  local buff, role = strsplit(',', args, 2)
    local tempTable = {}
    for _, Obj in pairs(NeP.Healing:GetRoster()) do
        if (not role or Obj.role == role) and NeP.DSL:Get('buff')(Obj.key, buff) then
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
NeP.FakeUnits:Add({'lowestnotbuff', 'lnbuff'}, function(num, args)
  	local buff, role = strsplit(',', args, 2)
    local tempTable = {}
    for _, Obj in pairs(NeP.Healing:GetRoster()) do
        if (not role or Obj.role == role) and not NeP.DSL:Get('buff')(Obj.key, buff) then
            tempTable[#tempTable+1] = {
                key = Obj.key,
                health = Obj.health
            }
        end
    end
    table.sort( tempTable, function(a,b) return a.health < b.health end )
    return tempTable[num] and tempTable[num].key
end)

-- lowest with certain buff
NeP.FakeUnits:Add({'lowestdebuff', 'ldebuff'}, function(num, args)
  	local buff, role = strsplit(',', args, 2)
    local tempTable = {}
    for _, Obj in pairs(NeP.Healing:GetRoster()) do
        if (not role or Obj.role == role) and NeP.DSL:Get('debuff.any')(Obj.key, buff) then
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
NeP.FakeUnits:Add({'lowestnotdebuff', 'lndebuff'}, function(num, args)
  	local buff, role = strsplit(',', args, 2)
    local tempTable = {}
    for _, Obj in pairs(NeP.Healing:GetRoster()) do
        if (not role or Obj.role == role) and not NeP.DSL:Get('debuff.any')(Obj.key, buff) then
            tempTable[#tempTable+1] = {
                key = Obj.key,
                health = Obj.health
            }
        end
    end
    table.sort( tempTable, function(a,b) return a.health < b.health end )
    return tempTable[num] and tempTable[num].key
end)

-- Tank
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

-- Healer
NeP.FakeUnits:Add('healer', function(num)
	local tempTable = {}
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		if Obj.role == 'HEALER' and not UnitIsUnit('player', Obj.key) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = Obj.healthMax
			}
		end
	end
	table.sort( tempTable, function(a,b) return a.prio > b.prio end )
	return tempTable[num] and tempTable[num].key
end)

-- DAMAGER
NeP.FakeUnits:Add('damager', function(num)
	local tempTable = {}
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		if Obj.role == 'DAMAGER' and not UnitIsUnit('player', Obj.key) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = Obj.healthMax
			}
		end
	end
	table.sort( tempTable, function(a,b) return a.prio > b.prio end )
	return tempTable[num] and tempTable[num].key
end)

-- Lowest enemy
NeP.FakeUnits:Add({'lowestenemy', 'loweste', 'le'}, function(num)
	local tempTable = {}
	for _, Obj in pairs(NeP.OM:Get('Enemy') do
		tempTable[#tempTable+1] = {
			key = Obj.key,
			health = Obj.health
		}
	end
	table.sort( tempTable, function(a,b) return a.health < b.health end )
	return tempTable[num] and tempTable[num].key
end)

-- enemy with buff
NeP.FakeUnits:Add({'enemybuff', 'ebuff'}, function(num, buff)
    for _, Obj in pairs(NeP.OM:Get('Enemy') do
        if NeP.DSL:Get('buff')(Obj.key, buff) then
            return Obj.key
        end
    end
end)

-- enemy without buff
NeP.FakeUnits:Add({'enemynbuff', 'enbuff'}, function(num, buff)
    for _, Obj in pairs(NeP.OM:Get('Enemy') do
        if not NeP.DSL:Get('buff')(Obj.key, buff) then
            return Obj.key
        end
    end
end)

-- enemy with debuff
NeP.FakeUnits:Add({'enemydebuff', 'edebuff'}, function(num, debuff)
    for _, Obj in pairs(NeP.OM:Get('Enemy') do
        if NeP.DSL:Get('debuff')(Obj.key, debuff) then
            return Obj.key
        end
    end
end)

-- enemy without debuff
NeP.FakeUnits:Add({'enemynbuff', 'enbuff'}, function(num, debuff)
    for _, Obj in pairs(NeP.OM:Get('Enemy') do
        if not NeP.DSL:Get('debuff')(Obj.key, debuff) then
            return Obj.key
        end
    end
end)
