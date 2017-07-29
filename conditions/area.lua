local _, NeP = ...
local UnitExists = ObjectExists or UnitExists

-- USAGE: UNIT.area(DISTANCE).enemies >= #
NeP.DSL:Register("area.enemies", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  local total = 0
  for _, Obj in pairs(NeP.OM:Get('Enemy', true)) do
    if (NeP.DSL:Get('combat')(unit) or Obj.isdummy)
    and NeP.Protected.Distance(unit, Obj.key) < tonumber(distance) then
      total = total +1
    end
  end
  return total
end)

-- USAGE: UNIT.area(DISTANCE).enemies.infront >= #
NeP.DSL:Register("area.enemies.infront", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  local total = 0
  for _, Obj in pairs(NeP.OM:Get('Enemy', true)) do
    if (NeP.DSL:Get('combat')(unit) or Obj.isdummy)
    and NeP.Protected.Distance(unit, Obj.key) < tonumber(distance)
    and NeP.Protected.Infront(unit, Obj.key) then
      total = total +1
    end
  end
  return total
end)

-- USAGE: UNIT.area(DISTANCE).friendly >= #
NeP.DSL:Register("area.friendly", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  local total = 0
  for _, Obj in pairs(NeP.OM:Get('Friendly', true)) do
    if NeP.Protected.Distance(unit, Obj.key) < tonumber(distance) then
      total = total +1
    end
  end
  return total
end)

-- USAGE: UNIT.area(DISTANCE).friendly.infront >= #
NeP.DSL:Register("area.friendly.infront", function(unit, distance)
  if not UnitExists(unit) then return 0 end
  local total = 0
  for _, Obj in pairs(NeP.OM:Get('Friendly', true)) do
    if NeP.Protected.Distance(unit, Obj.key) < tonumber(distance)
    and NeP.Protected.Infront(unit, Obj.key) then
      total = total +1
    end
  end
  return total
end)
