local _, NeP = ...

NeP.Actions = {}
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
NeP.Actions['dispelall'] = function(eval, args)
	--TODO
end

-- Automated tauting
NeP.Actions['taunt'] = function(eval, args)
	--TODO
end

-- Ress all dead
NeP.Actions['ressdead'] = function(eval, args)
	--TODO
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
			eval.func = NeP.Protected.UseItem
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