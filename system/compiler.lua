local _, NeP = ...

-- Locals
local tonumber             = tonumber
local GetInventorySlotInfo = GetInventorySlotInfo
local GetInventoryItemID   = GetInventoryItemID
local GetItemInfo          = GetItemInfo
local GetSpellInfo         = GetSpellInfo
local UnitExists           = ObjectExists or UnitExists

NeP.Compiler = {}

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

local function _Items(eval, name, ref)
	ref.spell = ref.spell:sub(2)
	ref.token = 'item'
	eval.nogcd = true
	if invItems[ref.spell] then
		local invItem = GetInventorySlotInfo(invItems[ref.spell])
		ref.spell = GetInventoryItemID("player", invItem)
	end
	if not ref.spell then return end
	local itemID = tonumber(ref.spell)
	if not itemID then
		itemID = NeP.Core:GetItemID(ref.spell)
	end
	if not tonumber(itemID) then return end
	local itemName, itemLink, _,_,_,_,_,_,_, texture = GetItemInfo(itemID)
	if not itemName then return end
	ref.id = itemID
	ref.spell = itemName
	ref.icon = texture
	ref.link = itemLink
	eval.exe = function(eval) return NeP.Protected["UseItem"](eval.spell, eval.target) end
end

local function _Lib(eval, name, ref)
	ref.spell = ref.spell:sub(2)
	ref.token = 'lib'
	eval.nogcd = true
	eval.exe = function() return NeP.Library:Parse(ref.spell, ref.args) end
end

local function _Macro(eval, name, ref)
	ref.token = 'macro'
	eval.nogcd = true
	eval.exe = function(eval) return NeP.Protected["Macro"](eval.spell, eval.target) end
end

local function _Spell(eval, name, ref)
	ref.spell = NeP.Spells:Convert(ref.spell, name)
	ref.icon = select(3,GetSpellInfo(ref.spell))
	eval.exe = function(eval) return NeP.Protected["Cast"](eval.spell, eval.target) end
	ref.token = 'spell_cast'
end

local function _Clip(eval, name, ref)
	ref.interrupts = true
	ref.bypass = true
	ref.spell = ref.spell:sub(2)
end

local function _NoGCD(eval, name, ref)
	ref.bypass = true
	eval.nogcd = true
	ref.spell = ref.spell:sub(2)
end

local function spell_string(eval, name)
	local ref = { spell = eval[1] }
	
	--Arguments
	local arg1, args = ref.spell:match('(.+)%((.+)%)')
	if args then ref.spell = arg1 end
	ref.args = args

	-- Clip
	if ref.spell:find('^!') then
		_Clip(eval, name, ref)
	end
	-- No GCD
	if ref.spell:find('^&') then
		_NoGCD(eval, name, ref)
	end

	-- Macro
	if ref.spell:find('^/') then
		_Macro(eval, name, ref)
	--Lib
	elseif ref.spell:find('^@') then
		_Lib(eval, name, ref)
	--Actions
	elseif ref.spell:find('^%%') then
		ref.token = ref.spell:sub(2)
	-- Items
	elseif ref.spell:find('^#') then
		_Items(eval, name, ref)
	--Normal spell
	else
		_Spell(eval, name, ref)
	end

	--replace with compiled
	eval[1] = ref
end

local _spell_types = {
	['nil'] = function(eval, name)
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Spell cant be a', type(spell))
		eval[1] = {
			spell = 'fake',
			token = 'spell_cast',
		}
		eval[2] = 'true'
	end,
	['table'] = function(eval, name)
		eval[1].is_table = true
		for k=1, #eval[1] do
			NeP.Compiler.Compile(eval[1][k], name)
		end
	end,
	['function'] = function(eval, name)
		local ref = {}
		ref.token = 'function'
		eval.exe = spell
		eval.nogcd = true
		eval[1] = ref
	end,
	['string'] = spell_string
}

-- Takes a valid format for spell and produces a table in its place
function NeP.Compiler.Spell(eval, name)
	local spell_type = _spell_types[type(eval[1])]
	if spell_type then
		spell_type(eval, name)
	else
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Spell cant be a', type(eval[1]))
	end
end

local function unit_ground(ref, eval)
	if ref.target:find('.ground') then
		ref.target = ref.target:sub(0,-8)
		eval.exe = function(eval) return NeP.Protected["CastGround"](eval.spell, eval.target) end
		-- This is to alow casting at the cursor location where no unit exists
		if ref.target:lower() == 'cursor' then ref.cursor = true end
	end
end

local _target_types = {
	['nil'] = function(eval, name, ref)
		ref.target = function() return UnitExists('target') and 'target' or 'player' end
	end,
	['table'] = function(eval, name, ref)
		ref.target = eval[3]
	end,
	['function'] = function(eval, name, ref)
		ref.target = eval[3]
	end,
	['string'] = function(eval, name, ref)
		ref.target = eval[3]
		unit_ground(ref, eval)
	end
}

function NeP.Compiler.Target(eval)
	local ref, unit_type = {}, _target_types[type(eval[3])]
	if unit_type then
		unit_type(eval, name, ref)
	else
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Target cant be a', type(eval[3]))
	end
	eval[3] = ref
end

-- Remove whitespaces (_xspc_ needs to be unique so we dont end up replacing something we shouldn't)
local function CondSpaces(cond)
	return cond:gsub("%b()", function(s) return s:gsub(" ", "_xspc_") end):gsub("%s", ""):gsub("_xspc_", " ")
end

-- FIXME: more needs to be done for conditions like we do for the RangedSlot
function NeP.Compiler.Conditions(eval, name)
	local condtype = type(eval[2])
	if not eval[2] then
		eval[2] = 'true'
	elseif condtype  == 'boolean' then
		eval[2] = tostring(eval[2])
	elseif condtype  == 'table' then
		NeP.Core:Print('Invalid condition format:', condtype, 'in the cr:', name)
		eval[2] = 'true'
	else
		eval[2] = CondSpaces(eval[2])
		-- Convert spells inside ()
		eval[2] = eval[2]:gsub("%((.-)%)", function(s)
			-- we cant convert number due to it messing up other things
			if tonumber(s) then return '('..s..')' end
			return '('..NeP.Spells:Convert(s, name)..')'
		end)
	end
end

function NeP.Compiler.Compile(eval, name)
	-- check if this was already done
	if eval[4] then return end
	eval[4] = true
	--Spell
	NeP.Compiler.Spell(eval, name)
	-- Conditions
	NeP.Compiler.Conditions(eval, name)
	-- Target
	NeP.Compiler.Target(eval, name)
end

function NeP.Compiler.Iterate(_, eval, name)
	if not eval then return end
	NeP.Core:WhenInGame(function()
		for i=1, #eval do
			NeP.Compiler.Compile(eval[i], name)
		end
	end)
end
