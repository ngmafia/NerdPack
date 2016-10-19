local _, NeP = ...

NeP.Actions = {}
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
NeP.Actions['dispelall'] = function(eval, args)
	for _, Obj in pairs(NeP.OM:GetRoster()) do
		for _,spellID, _,_,_,_, dispelType in LibDisp:IterateDispellableAuras(Obj.key) do
			local spell = GetSpellInfo(spellID)
			if dispelType then
				eval[1].spell = spell
				eval[3].target = Obj.key
				return true
			end
		end
	end
end

-- Automated tauting
--NeP.Actions['taunt'] = function(eval, args)
	--TODO
--end

-- Ress all dead
--NeP.Actions['ressdead'] = function(eval, args)
	--TODO
--end

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
			--print(item.id, item.spell)
			eval.func = NeP.Protected.UseItem
			return true
		end
	end
end

-- Lib
NeP.Actions['@'] = function(eval)
	eval.breaks = false
	if NeP.DSL.Parse(eval[2]) then
		if NeP.Library:Parse(eval[1].spell, eval[1].args) then
			eval.breaks = true
			return true
		end
	end
end

-- Macro
NeP.Actions['/'] = function(eval)
	eval.func = NeP.Protected.Macro
	return true
end

-- These are special NeP.Actions
NeP.Actions['%'] = function(eval)
	if NeP.Actions[eval[1].spell] then
		return NeP.Actions[eval[1].spell](eval, eval[1].args)
	end
end