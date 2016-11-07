local _, NeP = ...

-- Local stuff for speed
local UnitExists        = ObjectExists or UnitExists
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
	Enemy    = {},
	Friendly = {},
	Dead     = {},
	Objects  = {}
}

local plates = {
  Friendly = {},
  Enemy = {}
}


-- This cleans/updates the tables and then returns it
-- Due to Generic OM, a unit can still exist (target) but no longer be the same unit,
-- To counter this we compare GUID's.

local function MergeTable(table, Obj, GUID)
	if not table[GUID]
	and UnitExists(Obj.key)
	and GUID == UnitGUID(Obj.key) then
		table[GUID] = Obj
		Obj.distance = NeP.Protected.Distance('player', Obj.key)
	end
end

function NeP.OM:Get(ref, want_plates)
	-- Hack for nameplates
	if want_plates and not NeP.AdvancedOM then
		local temp = {}
		for GUID, Obj in pairs(plates[ref]) do
			MergeTable(temp, Obj, GUID)
		end
		for GUID, Obj in pairs(OM_c[ref]) do
			MergeTable(temp, Obj, GUID)
		end
		return temp
	-- Normal
	else
		local tb = OM_c[ref]
		for GUID, Obj in pairs(tb) do
			-- remove invalid units
			if not UnitExists(Obj.key)
			or GUID ~= UnitGUID(Obj.key)
			or ref ~= 'Dead' and UnitIsDeadOrGhost(Obj.key) then
				tb[GUID] = nil
			else
				-- update
				Obj.distance = NeP.Protected.Distance('player', Obj.key)
			end
		end
		return tb
	end
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
	elseif ObjectIsType and ObjectIsType(Obj, ObjectTypes.GameObject) then
		NeP.OM:Insert('Objects', Obj)
	end
end

local function addPlate(tb, Obj)
	local GUID = UnitGUID(Obj)
	local ObjID = select(6, strsplit('-', GUID))
	local distance = NeP.Protected.Distance('player', Obj)
	plates[tb][GUID] = {
		key = Obj,
		name = UnitName(Obj),
		distance = distance,
		id = tonumber(ObjID) or '0',
		guid = GUID,
		isdummy = NeP.DSL:Get('isdummy')(Obj)
	}
end

C_Timer.NewTicker(1, (function()
	NeP.OM.Maker()
	-- Nameplates
	if not NeP.AdvancedOM then
		for i=1, 40 do
			local Obj = 'nameplate'..i
			if UnitExists(Obj) then
				if UnitIsFriend('player',Obj) then
					addPlate('Friendly', Obj)
				else
					addPlate('Enemy', Obj)
				end
			end
		end
	end
end), nil)

-- Gobals
NeP.Globals.OM = {
	Add = NeP.OM.Add,
	Get = NeP.OM.Get
}
