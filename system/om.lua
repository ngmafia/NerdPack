local _, NeP = ...

-- Local stuff for speed
local UnitExists        = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitCanAttack     = UnitCanAttack
local UnitIsFriend      = UnitIsFriend
local UnitGUID          = UnitGUID
local UnitName          = UnitName
local strsplit          = strsplit
local select            = select
local tonumber          = tonumber
local pairs             = pairs

NeP.OM = {}

local OM_c = {
	Enemy = {},
	Friendly = {},
	Dead = {}
}

-- This cleans/updates the tables and then returns it
-- Due to Generic OM, a unit can still exist (target) but no longer be the same unit,
-- To counter this we compare GUID's.
function NeP.OM:Get(ref)
	local tb, count = OM_c[ref], 0
	for GUID, Obj in pairs(tb) do
		if not UnitExists(Obj.key) then
			tb[GUID] = nil
		elseif GUID ~= UnitGUID(Obj.key)
		or ref ~= 'Dead' and UnitIsDeadOrGhost(Obj.key) then
			self:Add(Obj.key)
			tb[GUID] = nil
		else
			count = count + 1
			Obj.distance = NeP.Protected.Distance('player', Obj.key)
		end
	end
	return tb, count
end

function NeP.OM:Insert(ref, Obj)
	local GUID = UnitGUID(Obj) or '0'
	-- Dont add existing Objs
	if OM_c[ref][GUID] then return end
	local ObjID = select(6, strsplit('-', GUID))
	local distance = NeP.Protected.Distance('player', Obj)
	OM_c[ref][GUID] = {
		key = Obj,
		name = UnitName(Obj),
		distance = distance,
		id = tonumber(ObjID) or '0',
		guid = GUID,
		isdummy = NeP.DSL:Get('isdummy')(Obj)
	}
end

function NeP.OM:Add(Obj)
	if not UnitExists(Obj) then return end
	-- Dead Units
	if UnitIsDeadOrGhost(Obj) then
		NeP.OM:Insert('Dead', Obj)
	-- Friendly
	elseif UnitIsFriend('player', Obj) then
		NeP.OM:Insert('Friendly', Obj)
	-- Enemie
	elseif UnitCanAttack('player', Obj) then
		NeP.OM:Insert('Enemy', Obj)
	end
end

C_Timer.NewTicker(1, (function()
	NeP.OM.Maker()
end), nil)

-- Gobals
NeP.Globals.OM = {
	Add = NeP.OM.Add,
	Get = NeP.OM.Get
}
