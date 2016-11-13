local _, NeP 			= ...
NeP.Healing 			= {}
local Roster 			= {}
local maxDistance = 40

-- Local stuff for speed
local UnitExists              = ObjectExists or UnitExists
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
local C_Timer 								= C_Timer

function NeP.Healing:GetRoster()
	for GUID, Obj in pairs(Roster) do
		if not Obj or not  UnitExists(Obj.key)
		or Obj.distance > maxDistance
		or UnitIsDeadOrGhost(Obj.key)
		or GUID ~= UnitGUID(Obj.key) then
			Roster[GUID] = nil
		end
	end
	return Roster
end

function NeP.Healing:GetPredictedHealth(unit)
	return UnitHealth(unit)-(UnitGetTotalHealAbsorbs(unit) or 0)+(UnitGetIncomingHeals(unit) or 0)
end

-- This Add's more index to the Obj in the OM table
function NeP.Healing:Add(Obj)
	local Role = UnitGroupRolesAssigned(Obj.key)
	local healthRaw = UnitHealth(Obj.key)
	local maxHealth = UnitHealthMax(Obj.key)
	local healthPercent =  (healthRaw / maxHealth) * 100
	Obj.healthPredict = self:GetPredictedHealth(Obj.key)
	Obj.health = healthPercent
	Obj.healthRaw = healthRaw
	Obj.healthMax = maxHealth
	Obj.role = Role
	Roster[Obj.guid] = Obj
end

function NeP.Healing:Refresh(GUID, Obj)
	local temp = Roster[GUID]
	local healthRaw = UnitHealth(temp.key)
	temp.health = (healthRaw / UnitHealthMax(temp.key)) * 100
	temp.healthRaw = healthRaw
	temp.distance = Obj.distance
end

C_Timer.NewTicker(0.1, (function()
	for GUID, Obj in pairs(NeP.OM:Get('Friendly')) do
		if UnitPlayerOrPetInParty(Obj.key)
		or UnitIsUnit('player', Obj.key) then
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
