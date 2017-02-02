local _, NeP        = ...
local IsInRaid           = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local IsInGroup          = IsInGroup

NeP.Protected.Cast = function(spell, target)
  NeP.Faceroll:Set(spell, target)
end

NeP.Protected.CastGround = function(spell, target)
  NeP.Faceroll:Set(spell, target)
end

NeP.Protected.Macro = function()
end

NeP.Protected.UseItem = function()
end

NeP.Protected.UseInvItem = function()
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

local ValidUnits = {'player', 'mouseover', 'target', 'arena1', 'arena2', 'focus', 'pet'}
NeP.OM.Maker = function()
  -- If in Group scan frames...
  if IsInGroup() or IsInRaid() then
    local prefix = (IsInRaid() and 'raid') or 'party'
    for i = 1, GetNumGroupMembers() do
      local object = prefix..i
      NeP.OM:Add(object)
      NeP.OM:Add(object..'target')
    end
  end
  -- Valid Units
  for i=1, #ValidUnits do
    local object = ValidUnits[i]
    NeP.OM:Add(object)
    NeP.OM:Add(object..'target')
  end
end
