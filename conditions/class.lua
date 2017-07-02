local _, NeP = ...
local UnitPower = UnitPower
local UnitPowerType = UnitPowerType
local UnitPowerMax = UnitPowerMax
local UnitExists = ObjectExists or UnitExists
local UnitMana = UnitMana
local UnitManaMax = UnitManaMax
local GetRuneCooldown = GetRuneCooldown
local GetTotemInfo = GetTotemInfo
local GetTime = GetTime
local GetShapeshiftForm = GetShapeshiftForm
local UnitName = UnitName
local C_Timer = C_Timer

local SPELL_POWER_INSANITY = SPELL_POWER_INSANITY
local SPELL_POWER_FOCUS = SPELL_POWER_FOCUS
local SPELL_POWER_RUNIC_POWER = SPELL_POWER_RUNIC_POWER
local SPELL_POWER_MAELSTROM = SPELL_POWER_MAELSTROM
local SPELL_POWER_SOUL_SHARDS = SPELL_POWER_SOUL_SHARDS
local SPELL_POWER_CHI = SPELL_POWER_CHI
local SPELL_POWER_LUNAR_POWER = SPELL_POWER_LUNAR_POWER
local SPELL_POWER_HOLY_POWER = SPELL_POWER_HOLY_POWER
local SPELL_POWER_RAGE = SPELL_POWER_RAGE
local SPELL_POWER_FURY = SPELL_POWER_FURY
local SPELL_POWER_PAIN = SPELL_POWER_PAIN
local SPELL_POWER_ARCANE_CHARGES = SPELL_POWER_ARCANE_CHARGES
local SPELL_POWER_COMBO_POINTS = SPELL_POWER_COMBO_POINTS

NeP.DSL:Register('energy', function(target)
  return UnitPower(target, UnitPowerType(target))
end)

-- Returns the amount of energy you have left till max
-- (e.g. you have a max of 100 energy and 80 energy now, so it will return 20)
NeP.DSL:Register('energydiff', function(target)
  local max = UnitPowerMax(target, UnitPowerType(target))
  local curr = UnitPower(target, UnitPowerType(target))
  return (max - curr)
end)

NeP.DSL:Register('mana', function(target)
  if UnitExists(target) then
    return math.floor((UnitMana(target) / UnitManaMax(target)) * 100)
  end
  return 0
end)

NeP.DSL:Register('insanity', function(target)
  return UnitPower(target, SPELL_POWER_INSANITY)
end)

NeP.DSL:Register('petrange', function(target)
  return target and NeP.Protected.Distance('pet', target) or 0
end)

NeP.DSL:Register('focus', function(target)
  return UnitPower(target, SPELL_POWER_FOCUS)
end)

NeP.DSL:Register('runicpower', function(target)
  return UnitPower(target, SPELL_POWER_RUNIC_POWER)
end)

NeP.DSL:Register('runes', function()
  local count = 0
  local next = 0
  for i = 1, 6 do
    local _, duration, runeReady = GetRuneCooldown(i)
    if runeReady then
      count = count + 1
    elseif duration > next then
      next = duration
    end
  end
  if next > 0 then count = count + (next / 10) end
  return count
end)

NeP.DSL:Register('maelstrom', function(target)
  return UnitPower(target, SPELL_POWER_MAELSTROM)
end)

NeP.DSL:Register('totem', function(_, totem)
  for index = 1, 4 do
    local totemName = select(2, GetTotemInfo(index))
    if totemName == NeP.Core:GetSpellName(totem) then
      return true
    end
  end
  return false
end)

NeP.DSL:Register('totem.duration', function(_, totem)
  for index = 1, 4 do
    local _, totemName, startTime, duration = GetTotemInfo(index)
    if totemName == NeP.Core:GetSpellName(totem) then
      return math.floor(startTime + duration - GetTime())
    end
  end
  return 0
end)

NeP.DSL:Register('totem.time', function(_, totem)
  for index = 1, 4 do
    local _, totemName, _, duration = GetTotemInfo(index)
    if totemName == NeP.Core:GetSpellName(totem) then
      return duration
    end
  end
  return 0
end)

NeP.DSL:Register('soulshards', function(target)
  return UnitPower(target, SPELL_POWER_SOUL_SHARDS)
end)

NeP.DSL:Register('chi', function(target)
  return UnitPower(target, SPELL_POWER_CHI)
end)

-- Returns the number of chi you have left till max (e.g. you have a max of 5 chi and 3 chi now, so it will return 2)
NeP.DSL:Register('chidiff', function(target)
  local max = UnitPowerMax(target, SPELL_POWER_CHI)
  local curr = UnitPower(target, SPELL_POWER_CHI)
  return (max - curr)
end)

NeP.DSL:Register('form', function()
  return GetShapeshiftForm()
end)

NeP.DSL:Register('lunarpower', function(target)
  return UnitPower(target, SPELL_POWER_LUNAR_POWER)
end)

NeP.DSL:Register('mushrooms', function()
  local count = 0
  for slot = 1, 3 do
    if GetTotemInfo(slot) then
      count = count + 1 end
  end
  return count
end)

NeP.DSL:Register('holypower', function(target)
  return UnitPower(target, SPELL_POWER_HOLY_POWER)
end)

NeP.DSL:Register('rage', function(target)
  return UnitPower(target, SPELL_POWER_RAGE)
end)

NeP.DSL:Register('stance', function()
  return GetShapeshiftForm()
end)

NeP.DSL:Register('fury', function(target)
  return UnitPower(target, SPELL_POWER_FURY)
end)

-- Returns the number of fury you have left till max (e.g. you have a max of 100 fury and 80 fury now,
-- so it will return 20)
NeP.DSL:Register('fury.diff', function(target)
  local max = UnitPowerMax(target, SPELL_POWER_FURY)
  local curr = UnitPower(target, SPELL_POWER_FURY)
  return (max - curr)
end)

NeP.DSL:Register('pain', function(target)
  return UnitPower(target, SPELL_POWER_PAIN)
end)

NeP.DSL:Register('arcanecharges', function(target)
  return UnitPower(target, SPELL_POWER_ARCANE_CHARGES)
end)

NeP.DSL:Register('combopoints', function(target)
  return UnitPower(target, SPELL_POWER_COMBO_POINTS)
end)

--This should be replaced by ids
local minions = {
  count = 0,
  ["Wild Imp"] = 12,
  Dreadstalker = 12,
  Imp = 25,
  Felhunter = 25,
  Succubus = 25,
  Felguard = 25,
  Darkglare = 12,
  Doomguard = 25,
  Infernal = 25,
  Voidwalker = 25
}

NeP.Listener:Add('lock_P', 'COMBAT_LOG_EVENT_UNFILTERED', function(_, event, _,_, sName, _,_,_, dName)
  if not (event == "SPELL_SUMMON" and sName == UnitName("player"))
  or not minions[dName] then return end
  minions.count = minions.count + 1
  C_Timer.After(minions[dName], function() minions.count = minions.count - 1 end)
end)

NeP.DSL:Register('warlock.minions', function()
  return minions.count
end)
