local _, NeP = ...

-- locals
local LibStub = LibStub
local LibDisp                = LibStub('LibDispellable-1.0')
local GetSpellInfo           = GetSpellInfo
local UnitThreatSituation    = UnitThreatSituation
local UnitIsPlayer           = UnitIsPlayer
local IsUsableItem           = IsUsableItem
local UnitIsDeadOrGhost      = UnitIsDeadOrGhost
local UnitPlayerOrPetInParty = UnitPlayerOrPetInParty
local GetItemCooldown        = GetItemCooldown
local GetItemSpell           = GetItemSpell
local GetItemCount           = GetItemCount
local GetTime                = GetTime
local CancelShapeshiftForm   = CancelShapeshiftForm
local CancelUnitBuff         = CancelUnitBuff
local RunMacro               = RunMacro

-- DispelSelf
NeP.Actions:Add('dispelself', function(eval)
  for _,spellID, _,_,_,_, dispelType, duration, expires in LibDisp:IterateDispellableAuras('player') do
    -- wait a random time before dispelling, makes it look less boot like...
    if dispelType and (duration - expires) > math.random(.5, 1.5) then
      eval[1].spell = GetSpellInfo(spellID)
      eval.target = 'player'
      eval.exe = function(eval) return NeP.Protected["Cast"](eval.spell, eval.target) end
      return true
    end
  end
end)

-- Dispell all
NeP.Actions:Add('dispelall', function(eval)
  for _, Obj in pairs(NeP.Healing:GetRoster()) do
    for _,spellID, _,_,_,_, dispelType in LibDisp:IterateDispellableAuras(Obj.key) do
      if dispelType then
        eval[1].spell = GetSpellInfo(spellID)
        eval.target = Obj.key
        eval.exe = function(eval) return NeP.Protected["Cast"](eval.spell, eval.target) end
        return true
      end
    end
  end
end)

-- Executes a users macro
NeP.Actions:Add('macro', function()
  return true
end)

-- Executes a users macro
NeP.Actions:Add('function', function()
  return true
end)

-- Cancel buff
NeP.Actions:Add('cancelbuff', function(eval, buff)
  eval.exe = function() CancelUnitBuff('player', GetSpellInfo(buff)) end
  return true
end)

-- Cancel Shapeshift Form
NeP.Actions:Add('cancelform', function(eval)
  eval.exe = CancelShapeshiftForm
  return true
end)

-- Automated tauting
NeP.Actions:Add('taunt', function(eval, spell)
  if not spell then return end
  for _, Obj in pairs(NeP.OM:Get('Enemy')) do
    local Threat = UnitThreatSituation("player", Obj.key)
    if Threat and Threat >= 0 and Threat < 3 and Obj.distance <= 30 then
      eval[1].spell = spell
      eval.target = Obj.key
      eval.exe = function(eval) return NeP.Protected["Cast"](eval.spell, eval.target) end
      return true
    end
  end
end)

-- Ress all dead
NeP.Actions:Add('ressdead', function(eval, spell)
  if not spell then return end
  for _, Obj in pairs(NeP.OM:Get('Friendly')) do
    if Obj.distance < 40 and UnitIsPlayer(Obj.Key)
      and UnitIsDeadOrGhost(Obj.key) and UnitPlayerOrPetInParty(Obj.key) then
      eval[1].spell = spell
      eval.target = Obj.key
      eval.exe = function(eval) return NeP.Protected["Cast"](eval.spell, eval.target) end
      return true
    end
  end
end)

-- Pause
NeP.Actions:Add('pause', function(eval)
  eval.type = 'Pause'
  eval.target = nil
  eval.exe = function() return true end
  return true
end)

-- #TODO: Remove this at some point.
--   GetItemCooldown shows items ready when they really are not.
local itemBlacklist = {}

-- Items
NeP.Actions:Add('item', function(eval)
  local item = eval[1]
  if item and item.id and GetItemSpell(item.spell) then
    if IsUsableItem(item.spell)
      and select(2,GetItemCooldown(item.id)) == 0
      and GetItemCount(item.spell) > 0
      and NeP.Helpers:Check(item.spell, eval.target) then
      -- Blacklist for 5 seconds
      local tm = itemBlacklist[item.id] or 0
      if tm > GetTime() then
        return false
      end
	    --make it random to decrease the change of pattern detection if any...
      itemBlacklist[item.id] = GetTime() + math.random(0.5,1.5)
      return true
    end
  end
end)

-- regular spell
NeP.Actions:Add('spell_cast', function(eval)
  local skillType = GetSpellBookItemInfo(eval[1].spell)
	local isUsable, notEnoughMana = IsUsableSpell(eval[1].spell)
	if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
		local GCD = NeP.DSL:Get('gcd')()
		return GetSpellCooldown(eval[1].spell) <= GCD
	end
end)