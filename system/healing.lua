local _, NeP = ...

NeP.Healing = {}
local Roster = {}

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetIncomingHeals = UnitGetIncomingHeals

local Roles = {
	['TANK'] = 2,
	['HEALER'] = 1.5,
	['DAMAGER'] = 1,
	['NONE'] = 1	 
}

function NeP.Healing:GetRoster()
	return Roster
end

function NeP.Healing:GetRawHealth(unit)
	return (UnitHealth(unit)-UnitGetTotalHealAbsorbs(unit)) or 0
end

function NeP.Healing:Add(Obj)
	local Role = UnitGroupRolesAssigned(Obj.key)
	local healthRaw = self:GetRawHealth(Obj.key)
	local maxHealth = UnitHealthMax(Obj.key)
	local healthPercent =  (healthRaw / maxHealth) * 100
	Roster[Obj.guid] = {
		key = Obj.key,
		prio = Roles[Role]*healthPercent,
		name = Obj.name,
		id = Obj.id,
		health = healthPercent,
		healthRaw = healthRaw,
		healthMax = maxHealth,
		distance = Obj.distance,
		role = Role
	}
end

function NeP.Healing:Refresh(GUID)
	local temp = Roster[GUID]
	local healthRaw = self:GetRawHealth(temp.key)
	local healthPercent =  (healthRaw / temp.healthMax) * 100
	temp.health = healthPercent
	temp.healthRaw = healthRaw
	temp.distance = temp.distance
end

function NeP.Healing:Grabage()
	for GUID, Obj in pairs(Roster) do
		if not UnitExists(Obj.key) then
			Roster[GUID] = nil
		end
	end
end

C_Timer.NewTicker(0.25, (function()
	NeP.Healing:Grabage()
	for GUID, Obj in pairs(NeP.OM:Get('Friendly')) do
		if UnitPlayerOrPetInParty(Obj.key) or UnitIsUnit('player', Obj.key) then
			if Roster[GUID] then
				NeP.Healing:Refresh(GUID)
			else
				NeP.Healing:Add(Obj)
			end
		end
	end
end), nil)

NeP.DSL:Register("health", function(target)
	return math.floor((UnitHealth(target) / UnitHealthMax(target)) * 100)
end)

NeP.DSL:Register("health.actual", function(target)
	return UnitHealth(target)
end)

NeP.DSL:Register("health.max", function(target)
	return UnitHealthMax(target)
end)

NeP.DSL:Register("health.predicted", function(unit)
	return UnitHealth(unit)-(UnitGetTotalHealAbsorbs(unit) or 0)+UnitGetIncomingHeals(unit)
end)

NeP.Globals.OM.GetRoster = NeP.Healing.GetRoster