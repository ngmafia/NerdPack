local _, NeP = ...
local IsInRaid = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local IsInGroup = IsInGroup
local UnitIsFriend = UnitIsFriend
local UnitExists = UnitExists
local UnitGUID = UnitGUID

NeP.Protected = {}
NeP.Globals.Protected = NeP.Protected
NeP.OM.nPlates = {
	Friendly = {},
	Enemy = {},
	Dead = {}
}

NeP.Protected.Cast = function(spell, target)
  NeP.Faceroll:Set(spell, target)
  return true
end

NeP.Protected.CastGround = function(spell, target)
  NeP.Faceroll:Set(spell, target)
  return true
end

NeP.Protected.Macro = function()
  return true
end

NeP.Protected.UseItem = function()
  return true
end

NeP.Protected.UseInvItem = function()
  return true
end

local rangeCheck = LibStub("LibRangeCheck-2.0")
NeP.Protected.Distance = function(_, b)
  local minRange, maxRange = rangeCheck:GetRange(b)
  return maxRange or minRange
end

NeP.Protected.Infront = function(_,b)
  return NeP.Helpers:Infront(b)
end

NeP.Protected.UnitCombatRange = function(_,b)
  local minRange = rangeCheck:GetRange(b)
  return minRange
end

NeP.Protected.LineOfSight = function(_,b)
  return NeP.Helpers:Infront(b)
end

local ValidUnits = {'player', 'mouseover', 'target', 'focus', 'pet',}
local ValidUnitsN = {'boss', 'arena', 'arenapet'}

NeP.OM.Maker = function()
  -- If in Group scan frames...
  if IsInGroup() or IsInRaid() then
    local prefix = (IsInRaid() and 'raid') or 'party'
    for i = 1, GetNumGroupMembers() do
      local unit = prefix..i
			local pet = prefix..'pet'..i
      NeP.OM:Add(unit)
			NeP.OM:Add(pet)
      NeP.OM:Add(unit..'target')
      NeP.OM:Add(pet..'target')
    end
  end
  -- Valid Units
  for i=1, #ValidUnits do
    local object = ValidUnits[i]
    NeP.OM:Add(object)
    NeP.OM:Add(object..'target')
  end
	-- Valid Units with numb (5)
	for i=1, #ValidUnitsN do
		for k=1, 5 do
			local object = ValidUnitsN[i]..k
			NeP.OM:Add(object)
			NeP.OM:Add(object..'target')
		end
	end
  --nameplates
	for i=1, 40 do
		local Obj = 'nameplate'..i
		if UnitExists(Obj) then
			local GUID = UnitGUID(Obj) or '0'
			if UnitIsFriend('player',Obj) then
				NeP.OM:Insert(NeP.OM.nPlates['Friendly'], Obj, GUID)
			else
				NeP.OM:Insert(NeP.OM.nPlates['Enemy'], Obj, GUID)
			end
		end
	end
end
