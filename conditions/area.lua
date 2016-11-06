local _, NeP       = ...
local UnitExists   = UnitExists
local UnitGUID     = UnitGUID
local C_Timer      = C_Timer
local wipe         = wipe
local UnitIsFriend = UnitIsFriend

local Cache = {
  Enemy              = {},
  Enemy_infront      = {},
  Friendly           = {},
  Friendly_infront   = {},
}

C_Timer.NewTicker(1, (function()
  for tb in pairs(Cache) do
    wipe(Cache[tb])
  end
end), nil)

local function testunit(ounit, unit, distance, bypass, infront)
  local unit_dist = NeP.Protected.Distance(ounit, unit)
  if (NeP.DSL:Get('combat')(unit) or bypass)
  and unit_dist <= tonumber(distance)
  and (not infront or NeP.Protected.Infront(ounit, unit)) then
      return true
  end
end

local function iterate(tb, unit, distance, infront)
  -- Cache
  local oGUID = UnitGUID(unit)
  local ct = infront and tb..'_infront' or tb
  if Cache[ct][oGUID] then
    return Cache[ct][oGUID]
  end
  local total, counted = 0, {}
  -- OM
  for _, Obj in pairs(NeP.OM:Get(tb)) do
    if testunit(unit, Obj.key, distance, Obj.isdummy or tb ~= 'Enemy', infront) then
      counted[Obj.guid] = true
      total = total +1
    end
  end
  -- Nameplates hack
  for i=1, 25 do
    local Obj = 'nameplate'..i
    if UnitExists(Obj) then
      local GUID = UnitGUID(Obj)
      if not counted[GUID]
      and testunit(unit, Obj, distance, UnitIsFriend('player', Obj) and tb ~= 'Enemy', infront) then
        total = total +1
      end
    end
  end
  -- cache the result for this unit
  Cache[ct][oGUID] = total
  return total
end

-- USAGE: UNIT.aoe(DISTANCE).enemies >= #
NeP.DSL:Register("area.enemies", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  return iterate('Enemy', unit, distance)
end)

-- USAGE: UNIT.aoe(DISTANCE).enemies.infront >= #
NeP.DSL:Register("area.enemies.infront", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  return iterate('Enemy', unit, distance, true)
end)

-- USAGE: UNIT.aoe(DISTANCE).friendly >= #
NeP.DSL:Register("area.friendly", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  return iterate('Friendly', unit, distance)
end)

-- USAGE: UNIT.aoe(DISTANCE).friendly >= #
NeP.DSL:Register("area.friendly.infront", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  return iterate('Friendly', unit, distance, true)
end)
