local _, NeP = ...

-- Local stuff for speed
local UnitExists              = UnitExists
local UnitHealth              = UnitHealth
local UnitGUID                = UnitGUID
local UnitHealthMax           = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetIncomingHeals    = UnitGetIncomingHeals
local UnitGroupRolesAssigned  = UnitGroupRolesAssigned
local UnitIsDeadOrGhost       = UnitIsDeadOrGhost
local UnitPlayerOrPetInParty  = UnitPlayerOrPetInParty
local UnitIsUnit              = UnitIsUnit
local strsplit                = strsplit

NeP.Healing = {}
local Roster = {}
local maxDistance = 40

function NeP.Healing:GetRoster()
	NeP.Healing:Garbage()
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

-- This cleans/updates the Roster
-- Due to Generic OM, a unit can still exist (target) but no longer be the same unit,
-- To counter this we compare GUID's.
function NeP.Healing:Garbage()
	for GUID, Obj in pairs(Roster) do
		if not UnitExists(Obj.key)
		or GUID ~= UnitGUID(Obj.key)
		or Obj.distance > maxDistance
		or UnitIsDeadOrGhost(Obj.key) then
			Roster[GUID] = nil
		end
	end
end

C_Timer.NewTicker(0.1, (function()
	for GUID, Obj in pairs(NeP.OM:Get('Friendly')) do
		if UnitPlayerOrPetInParty(Obj.key) or UnitIsUnit('player', Obj.key) then
			if Roster[GUID] then
				NeP.Healing:Refresh(GUID, Obj)
			elseif Obj.distance < maxDistance then
				NeP.Healing:Add(Obj)
			end
		end
	end
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

-- USAGE: UNIT.area(DISTANCE, HEALTH).heal >= #
NeP.DSL:Register("area.heal", function(unit, args)
	local total = 0
	if not UnitExists(unit) then return total end
	local distance, health = strsplit(",", args, 2)
	for _,Obj in pairs(Roster) do
		local unit_dist = NeP.Protected.Distance(unit, Obj.key)
		if unit_dist < (tonumber(distance) or 20)
		and Obj.health < (tonumber(health) or 100) then
			total = total + 1
		end
	end
	return total
end)

-- USAGE: UNIT.area(DISTANCE, HEALTH).heal.infront >= #
NeP.DSL:Register("area.heal.infront", function(unit, args)
	local total = 0
	if not UnitExists(unit) then return total end
	local distance, health = strsplit(",", args, 2)
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
