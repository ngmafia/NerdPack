local _, NeP = ...

NeP.Actions = {}
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
NeP.Actions['dispelall'] = function(eval, args)
	for i=1,#NeP.OM['unitFriend'] do
		local Obj = NeP.OM['unitFriend'][i]
		for _,spellID, name, _,_,_, dispelType in LibDisp:IterateDispellableAuras(Obj.key) do
			local spell = GetSpellInfo(spellID)
			if dispelType then
				eval.spell = spell
				eval.target = Obj.key
				return NeP.Engine:STRING(eval)
			end
		end
	end
end

-- Automated tauting
NeP.Actions['taunt'] = function(eval, args)
	local spell = NeP.Engine:Spell(args)
	if not spell then return end
	for i=1,#NeP.OM['unitEnemie'] do
		local Obj = NeP.OM['unitEnemie'][i]
		local Threat = UnitThreatSituation("player", Obj.key)
		if Threat and Threat >= 0 and Threat < 3 and Obj.distance <= 30 then
			eval.spell = spell
			eval.target = Obj.key
			return NeP.Engine:STRING(eval)
		end
	end
end

-- Ress all dead
NeP.Actions['ressdead'] = function(eval, args)
	local spell = NeP.Engine:Spell(args)
	if not spell then return false end
	for i=1,#NeP.OM['DeadUnits'] do
		local Obj = NeP.OM['DeadUnits'][i]
		if spell and Obj.distance < 40 and UnitIsPlayer(Obj.Key)
		and UnitIsDeadOrGhost(Obj.key) and UnitPlayerOrPetInParty(Obj.key) then
			eval.spell = spell
			eval.target = Obj.key
			return NeP.Engine:STRING(eval)
		end
	end
end

-- Pause
NeP.Actions['pause'] = function(eval)
	eval.breaks = true
	return true
end

local invItems = {
	['head']		= 'HeadSlot',
	['helm']		= 'HeadSlot',
	['neck']		= 'NeckSlot',
	['shoulder']	= 'ShoulderSlot',
	['shirt']		= 'ShirtSlot',
	['chest']		= 'ChestSlot',
	['belt']		= 'WaistSlot',
	['waist']		= 'WaistSlot',
	['legs']		= 'LegsSlot',
	['pants']		= 'LegsSlot',
	['feet']		= 'FeetSlot',
	['boots']		= 'FeetSlot',
	['wrist']		= 'WristSlot',
	['bracers']		= 'WristSlot',
	['gloves']		= 'HandsSlot',
	['hands']		= 'HandsSlot',
	['finger1']		= 'Finger0Slot',
	['finger2']		= 'Finger1Slot',
	['trinket1']	= 'Trinket0Slot',
	['trinket2']	= 'Trinket1Slot',
	['back']		= 'BackSlot',
	['cloak']		= 'BackSlot',
	['mainhand']	= 'MainHandSlot',
	['offhand']		= 'SecondaryHandSlot',
	['weapon']		= 'MainHandSlot',
	['weapon1']		= 'MainHandSlot',
	['weapon2']		= 'SecondaryHandSlot',
	['ranged']		= 'RangedSlot'
}

-- Items
NeP.Actions['#'] = function(eval)
	local item = eval[1].spell
	if invItems[item] then
		local invItem = GetInventorySlotInfo(invItems[item])
		item = GetInventoryItemID("player", invItem)
	end
	if item and GetItemSpell(item) then
		local itemName, _,_,_,_,_,_,_,_, icon = GetItemInfo(item)
		local isUsable, notEnoughMana = IsUsableItem(itemName)
		local ready = select(2, GetItemCooldown(item)) == 0
		if isUsable and ready and (GetItemCount(itemName) > 0) then
			eval.func = NeP.Engine.UseItem
			return true
		end
	end
end

-- Lib
NeP.Actions['@'] = function(eval)
	eval.breaks = false
	if NeP.DSL.Parse(eval[2]) then
		if NeP.Library:Parse(eval[1].spell) then
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