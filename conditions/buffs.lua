local _, NeP       = ...
local UnitBuff     = UnitBuff
local UnitDebuff   = UnitDebuff
local GetSpellInfo = GetSpellInfo
local GetTime      = GetTime

local function UnitBuffL(target, spell, own)
  local name,_,_,count,_,_,expires,caster = UnitBuff(target, spell or spell, nil, own and 'PLAYER')
  return name, count, expires, caster
end

local function UnitDebuffL(target, spell, own)
  local name, _,_, count, _,_, expires, caster = UnitDebuff(target, spell or spell, nil, own and 'PLAYER')
  return name, count, expires, caster
end

local heroismBuffs = { 32182, 90355, 80353, 2825, 146555 }
NeP.DSL:Register("hashero", function()
  for i = 1, #heroismBuffs do
    local SpellName = NeP.Core:GetSpellName(heroismBuffs[i])
    local buff = UnitBuffL('player', SpellName)
    if buff then return true end
  end
  return false
end)

------------------------------------------ BUFFS -----------------------------------------
------------------------------------------------------------------------------------------
NeP.DSL:Register("buff", function(target, spell)
  return not not UnitBuffL(target, spell, true)
end)

NeP.DSL:Register("buff.any", function(target, spell)
  return not not UnitBuffL(target, spell)
end)

NeP.DSL:Register("buff.count", function(target, spell)
  local buff, count = UnitBuffL(target, spell, true)
  return not not buff and count or 0
end)

NeP.DSL:Register("buff.duration", function(target, spell)
  local buff,_,expires = UnitBuffL(target, spell, true)
  return buff and (expires - GetTime()) or 0
end)

------------------------------------------ DEBUFFS ---------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL:Register("debuff", function(target, spell)
  return not not UnitDebuffL(target, spell, true)
end)

NeP.DSL:Register("debuff.any", function(target, spell)
  return not not UnitDebuffL(target, spell)
end)

NeP.DSL:Register("debuff.count", function(target, spell)
  local debuff,count = UnitDebuffL(target, spell, true)
  return not not debuff and count or 0
end)

NeP.DSL:Register("debuff.duration", function(target, spell)
  local debuff,_,expires = UnitDebuffL(target, spell)
  return debuff and (expires - GetTime()) or 0
end)
