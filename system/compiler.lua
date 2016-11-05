local _, NeP = ...

-- Locals
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

-- Takes a string a produces a table in its place
function NeP.Compiler.Spell(eval, name)
	local ref = {
		spell = eval[1]
	}
	local skip = false
	local arg1, args = ref.spell:match('(.+)%((.+)%)')
	if args then ref.spell = arg1 end
	ref.args = args
	if ref.spell:find('^!') then
		ref.interrupts = true
		ref.bypass = true
		ref.spell = ref.spell:sub(2)
	end
	if ref.spell:find('^&') then
		ref.bypass = true
		eval.nogcd = true
		ref.spell = ref.spell:sub(2)
	end
	if ref.spell:find('^/') then
		ref.token = '/'
		eval.type = 'Macro'
		eval.nogcd = true
		eval.func = 'Macro'
		skip = true
	end
	if ref.spell:find('^@') then
		ref.spell = ref.spell:sub(2)
		ref.token = 'func'
		eval.type = 'Lib'
		eval.nogcd = true
		eval.exe = function() return NeP.Library:Parse(ref.spell, ref.args) end
		skip = true
	end
	if ref.spell:find('^%%') then
		ref.token = ref.spell:sub(1,1)
		ref.spell = ref.spell:sub(2)
		skip = true
	end
	if ref.spell:find('^#') then
		ref.spell = ref.spell:sub(2)
		ref.token = '#'
		eval.type = 'Item'
		eval.nogcd = true
		eval.func = 'UseItem'
		NeP.Core:WhenInGame(function()
			if invItems[ref.spell] then
				local invItem = GetInventorySlotInfo(invItems[ref.spell])
				ref.spell = GetInventoryItemID("player", invItem)
			end
			if not ref.spell then return end
			local itemName, itemLink, _,_,_,_,_,_,_, texture = GetItemInfo(ref.spell)
			ref.spell = itemName
			ref.icon = texture
			ref.link = itemLink
			ref.id = NeP.Core:GetItemID(itemName)
		end)
		skip = true
	end

	-- Some APIs only work after we'r in-game, so we delay.
	if not skip then
		NeP.Core:WhenInGame(function()
			ref.spell = NeP.Spells:Convert(ref.spell, name)
			ref.icon = select(3,GetSpellInfo(ref.spell))
		end)
	end
	if not eval.func then
		eval.func = 'Cast'
	end
	if not eval.type then
		eval.type = 'Spell'
	end
	eval[1] = ref
end
local fake_unit = {
	target = 'fake',
	func = function()
		return UnitExists('target') and 'target' or 'player'
	end
}

function NeP.Compiler.Target(eval)
	local ref = {}
	if type(eval[3]) == 'string' then
		ref.target = eval[3]
	else
		ref = fake_unit
	end
	if ref.target:find('.ground') then
		ref.target = ref.target:sub(0,-8)
		-- This is to alow casting at the cursor location where no unit exists
		if ref.target:lower() == 'cursor' then ref.cursor = true end
		ref.ground = true
		eval.func = 'CastGround'
	end
	eval[3] = ref
end

-- Remove whitespaces (_xspc_ needs to be unique so we dont end up replacing something we shouldn't)
local function CondSpaces(cond)
	return cond:gsub("%b()", function(s) return s:gsub(" ", "_xspc_") end):gsub("%s", ""):gsub("_xspc_", " ")
end

-- FIXME: more needs to be done for conditions like we do for the RangedSlot
function NeP.Compiler.Conditions(eval, name)
	eval[2] = CondSpaces(eval[2])
	-- Convert spells inside ()
	NeP.Core:WhenInGame(function()
		eval[2] = eval[2]:gsub("%((.-)%)", function(s) return '('..NeP.Spells:Convert(s, name)..')' end)
	end)
end

function NeP.Compiler.CondLegacy(cond)
	local str = ''
	if type(cond) == 'boolean' then
		str = tostring(cond):lower()
	elseif type(cond) == 'function' then
		-- FIXME: this shouldnt go to globals we need a table with these
		local name = tostring(cond)
		_G[name] = cond
		str = 'func='..name
	elseif type(cond) == 'table' then
		-- convert everything into a string so we can then process it
		str = '{'
		for k=1, #cond do
			local tmp = cond[k]
			tmp = NeP.Compiler.CondLegacy(tmp)
			if tmp:lower() == 'or' then
				str = str .. '||' .. tmp
			elseif k ~= 1 then
				str = str .. '&' .. tmp
			else
				str = str .. tmp
			end
		end
		str = str..'}'
	elseif not cond then
		str = 'true'
	else
		str = cond
	end
	return str
end

function NeP.Compiler.Compile(eval, name)
	local spell, cond = eval[1], eval[2]
	-- Spell
	if type(spell) == 'string' then
		NeP.Compiler.Spell(eval, name)
	elseif type(spell) == 'table' then
		for k=1, #spell do
			NeP.Compiler.Compile(spell[k], name)
		end
	elseif type(spell) == 'function' then
		local ref = {}
		ref.spell = tostring(spell)
		ref.token = 'func'
		eval.type = 'Function'
		eval.exe = spell
		eval.nogcd = true
		eval[1] = ref
	else
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Spell cant be a', type(spell))
		eval[1] = {}
	end
	-- Conditions
	eval[2] = NeP.Compiler.CondLegacy(cond)
	NeP.Compiler.Conditions(eval)

	-- Target
	NeP.Compiler.Target(eval)
end

function NeP.Compiler:Iterate(eval, name)
	for i=1, #eval do
		NeP.Compiler.Compile(eval[i], name)
	end
end
