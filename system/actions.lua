local _, NeP = ...

NeP.Actions = {}
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
NeP.Actions['dispelall'] = function(eval)
	for _, Obj in pairs(NeP.Healing:GetRoster()) do
		for _,spellID, _,_,_,_, dispelType in LibDisp:IterateDispellableAuras(Obj.key) do
			if dispelType then
				eval.spell = GetSpellInfo(spellID)
				eval.target = Obj.key
				eval.func = 'Cast'
				return true
			end
		end
	end
end

-- Automated tauting
NeP.Actions['taunt'] = function(eval, args)
	local spell = NeP.Spells:Convert(args)
	if not spell then return end
	for _, Obj in pairs(NeP.OM:Get('Enemy')) do
		local Threat = UnitThreatSituation("player", Obj.key)
		if Threat and Threat >= 0 and Threat < 3 and Obj.distance <= 30 then
			eval.spell = GetSpellInfo(spellID)
			eval.target = Obj.key
			eval.func = 'Cast'
			return true
		end
	end
end

-- Ress all dead
NeP.Actions['ressdead'] = function(eval, args)
	local spell = NeP.Spells:Convert(args)
	if not spell then return end
	for _, Obj in pairs(NeP.OM:Get('Enemy')) do
		if Obj.distance < 40 and UnitIsPlayer(Obj.Key)
		and UnitIsDeadOrGhost(Obj.key) and UnitPlayerOrPetInParty(Obj.key) then
			eval.spell = GetSpellInfo(spellID)
			eval.target = Obj.key
			eval.func = 'Cast'
			return true
		end
	end
end

-- Pause
NeP.Actions['pause'] = function(eval)
	eval.breaks = true
	return true
end

-- Items
NeP.Actions['#'] = function(eval)
	local item = eval[1]
	if item and GetItemSpell(item.spell) then
		local isUsable = IsUsableItem(item.spell)
		local ready = select(2, GetItemCooldown(item.id)) == 0
		if isUsable and ready and (GetItemCount(item.spell) > 0) then
			return true
		end
	end
end

-- Macro
NeP.Actions['/'] = function()
	return true
end

-- These are special NeP.Actions
NeP.Actions['%'] = function(eval)
	if NeP.Actions[eval[1].spell] then
		return NeP.Actions[eval[1].spell](eval, eval[1].args)
	end
end