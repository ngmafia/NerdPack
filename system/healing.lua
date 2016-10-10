local _, NeP = ...

NeP.Healing = {}
local Roster = {}

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetIncomingHeals = UnitGetIncomingHeals

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