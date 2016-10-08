local _, NeP = ...

NeP.Actions = {}
local Actions = NeP.Actions
local LibDisp = LibStub('LibDispellable-1.0')

-- Dispell all
Actions['dispelall'] = function(eval, args)
	
end

-- Automated tauting
Actions['taunt'] = function(eval, args)
	
end

-- Ress all dead
Actions['ressdead'] = function(eval, args)
	
end

-- Pause
Actions['pause'] = function(eval)
	eval.breaks = true
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
Actions['#'] = function(eval)
	local item = eval.spell:sub(2)
	if invItems[item] then
		local invItem = GetInventorySlotInfo(invItems[item])
		item = GetInventoryItemID("player", invItem)
	end
	if item and GetItemSpell(item) then
		local itemName, _,_,_,_,_,_,_,_, icon = GetItemInfo(item)
		local isUsable, notEnoughMana = IsUsableItem(itemName)
		local ready = select(2, GetItemCooldown(item)) == 0
		if isUsable and ready and (GetItemCount(itemName) > 0) then
			eval.spell = itemName
			eval.icon = icon
			eval.func = NeP.Protected.UseItem
		end
	end
end

-- Lib
Actions['@'] = function(eval)
	eval.conditions = NeP.DSL:Parse(eval.conditions)
	if eval.conditions then
		local lib = eval.spell:sub(2)
		if NeP.Library:Parse(lib) then
			eval.breaks = true
		end
	end 
end

-- Macro
Actions['/'] = function(eval)
	eval.func = NeP.Protected.Macro
end

-- These are special Actions
Actions['%'] = function(eval)
	eval.spell = eval.spell:lower():sub(2)
	local arg1, args = eval.spell:match('(.+)%((.+)%)')
	if args then eval.spell = arg1 end
	if Actions[eval.spell] then
		Actions[eval.spell](eval, args)
	end
end

-- Interrupt and cast
Actions['!'] = function(eval)
	eval.spell = eval.spell:sub(2)
	eval.bypass = true
	eval.si = eval.spell ~= UnitCastingInfo('player')
	NeP.Parser:STRING(eval)
end

-- Cast this along with current cast
Actions['&'] = function(eval)
	eval.spell = eval.spell:sub(2)
	eval.bypass = true
	NeP.Parser:STRING(eval)
end