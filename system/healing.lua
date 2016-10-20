local _, NeP = ...

NeP.Healing = {}
local Roster = {}
local maxDistance = 40

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetIncomingHeals = UnitGetIncomingHeals

function NeP.Healing:GetRoster()
	return Roster
end

function NeP.Healing:GetPredictedHealth(unit)
	return UnitHealth(unit)-(UnitGetTotalHealAbsorbs(unit) or 0)+(UnitGetIncomingHeals(unit) or 0)
end

function NeP.Healing:Add(Obj)
	local Role = UnitGroupRolesAssigned(Obj.key)
	local healthRaw = UnitHealth(Obj.key)
	local maxHealth = UnitHealthMax(Obj.key)
	local healthPercent =  (healthRaw / maxHealth) * 100
	Roster[Obj.guid] = {
		key = Obj.key,
		name = Obj.name,
		id = Obj.id,
		health = healthPercent,
		healthRaw = healthRaw,
		healthMax = maxHealth,
		healthPredict = self:GetPredictedHealth(Obj.key),
		distance = Obj.distance,
		role = Role
	}
end

function NeP.Healing:Refresh(GUID, Obj)
	local temp = Roster[GUID]
	local healthRaw = UnitHealth(temp.key)
	local healthPercent =  (healthRaw / temp.healthMax) * 100
	temp.health = healthPercent
	temp.healthRaw = healthRaw
	temp.distance = Obj.distance
end

function NeP.Healing:Grabage()
	for GUID, Obj in pairs(Roster) do
		if not UnitExists(Obj.key) or Obj.distance > maxDistance then
			Roster[GUID] = nil
		end
	end
end

C_Timer.NewTicker(0.25, (function()
	for GUID, Obj in pairs(NeP.OM:Get('Friendly')) do
		if UnitPlayerOrPetInParty(Obj.key) or UnitIsUnit('player', Obj.key) then
			if Roster[GUID] then
				NeP.Healing:Refresh(GUID, Obj)
			elseif Obj.distance < maxDistance then
				NeP.Healing:Add(Obj)
			end
		end
	end
	NeP.Healing:Grabage()
end), nil)

NeP.DSL:Register("health", function(target)
	local GUID = UnitGUID(target)
	local Obj = Roster[GUID]
	return Obj and Obj.health or math.floor((UnitHealth(target) / UnitHealthMax(target)) * 100)
end)

NeP.DSL:Register("health.actual", function(target)
	local GUID = UnitGUID(target)
	local Obj = Roster[GUID]
	return Obj and Obj.healthRaw or UnitHealth(target)
end)

NeP.DSL:Register("health.max", function(target)
	local GUID = UnitGUID(target)
	local Obj = Roster[GUID]
	return Obj and Obj.maxHealth or UnitHealthMax(target)
end)

NeP.DSL:Register("health.predicted", function(unit)
	return NeP.Healing:GetPredictedHealth(unit)
end)

-- USAGE: UNIT.aoe(HEALTH, DISTANCE).heal >= #
NeP.DSL:Register("area.heal", function(unit, args)
	local total = 0
	if not UnitExists(unit) then return total end
	local health, distance = strsplit(",", args, 2)
	for _,Obj in pairs(Roster) do
		local unit_dist = NeP.Protected.Distance(unit, Obj.key)
		if unit_dist < (tonumber(distance) or 20)
		and Obj.health < (tonumber(health) or 100) then
			total = total + 1
		end
	end
	return total
end)

-- USAGE: UNIT.aoe(HEALTH, DISTANCE).heal.infront >= #
NeP.DSL:Register("area.heal.infront", function(unit, args)
	local total = 0
	if not UnitExists(unit) then return total end
	local health, distance = strsplit(",", args, 2)
	for _,Obj in pairs(Roster) do
		local unit_dist = NeP.Protected.Distance(unit, Obj.key)
		if unit_dist < (tonumber(distance) or 20)
		and Obj.health < (tonumber(health) or 100)
		and NeP.Protected.Infront(unit, Obj.key) then
			total = total + 1
		end
	end
	return total
end)

NeP.Globals.OM.GetRoster = NeP.Healing.GetRoster
