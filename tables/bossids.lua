local _, NeP       = ...
NeP.BossID         = {}
NeP.Globals.BossID = NeP.BossID
local strsplit     = strsplit
local UnitExists   = UnitExists
local UnitGUID     = UnitGUID

--BossIDs Lib
local bossids = LibStub("LibBossIDs-1.0").BossIDs

function NeP.BossID:Add(...)
  if type(...) == 'table' then
    for id in pairs(...) do
      id = tonumber(id)
      if id then
        bossids[id] = true
      end
    end
  else
    local id = tonumber(...)
    if id then
      bossids[id] = true
    end
  end
end

function NeP.BossID:Eval(unit)
  if tonumber(unit) then
    return bossids[tonumber(unit)]
  elseif UnitExists(unit) then
    unit = select(6, strsplit("-", UnitGUID(unit)))
    return bossids[tonumber(unit)]
  end
end
