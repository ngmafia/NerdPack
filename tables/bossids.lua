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

local function WoWBossID(unit)
  for i=1, 4 do
    if UnitIsUnit(unit, "boss"..i) then
      return true
    end
  end
end

local function UnitID(unit)
  if tonumber(unit) then
    return nil, tonumber(unit)
  else
    unitid = select(6, strsplit("-", UnitGUID(unit)))
    return unit, tonumber(unitid)
  end
end

function NeP.BossID:Eval(unit)
  if not unit then return false end
  local unit, unitid = UnitID(unit)
  return UnitExists(unit) and WoWBossID(unit) or bossids[unitid]
end

NeP.BossID:Add({
  -- The Nighthold
  [102263] = true, -- Skorpyron
  [101002] = true, -- Krosus
  [104415] = true, -- Chronomatic Anomaly
  [104288] = true, -- Trilliax
  [103758] = true, -- Star Augur Etraeus
  [105503] = true, -- Gul'dan
  [110965] = true, -- Grand Magistrix Elisande
  [107699] = true, -- Spellblade Aluriel
  [104528] = true, -- High Botanist Tel'arn
  [103685] = true, -- Tichondrius
})
