local _, NeP = ...

-- Locals
local tonumber             = tonumber
local GetInventorySlotInfo = GetInventorySlotInfo
local GetInventoryItemID   = GetInventoryItemID
local GetItemInfo          = GetItemInfo
local GetSpellInfo         = GetSpellInfo
local UnitExists           = ObjectExists or UnitExists
local unpack               = unpack

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

function NeP.Compiler.Target(eval, name)
	local ref = {}
	if type(eval[3]) == 'string' then
		ref.target = eval[3]
		-- ground
		if ref.target:find('.ground') then
			ref.target = ref.target:sub(0,-8)
			ref.ground = true
			eval.func = 'CastGround'
			-- This is to alow casting at the cursor location where no unit exists
			if ref.target:lower() == 'cursor' then
				ref.cursor = true
				ref.target = 'fake'
			end
		end
	elseif type(eval[3]) == 'function' then
		ref.target = 'fake'
		ref.func = eval[3]
	elseif type(eval[3]) == 'table' then
		-- to be done
	else
		ref.target = 'fake'
		ref.func = function()
			return UnitExists('target') and 'target' or 'player'
		end
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
		NeP.Core:WhenInGame(function()
			eval[2] = eval[2]:gsub("%((.-)%)", function(s)
				-- we cant convert number due to it messing up other things
				if tonumber(s) then return '('..s..')' end
				return '('..NeP.Spells:Convert(s, name)..')'
			end)
		end)
	end
end

function NeP.Compiler.Compile(eval, name)
	-- check if this was already done
	if eval[4] then return end
	eval[4] = true

	local spell, cond = eval[1], eval[2]
	local spelltype = type(spell)
	-- Spell
	if spelltype == 'nil' then
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Spell cant be a', type(spell))
		eval[1] = {
			spell = 'fake',
			func = 'Cast',
			type = 'Spell'
		}
		eval[2] = 'true'
	elseif spelltype == 'string' then
		NeP.Compiler.Spell(eval, name)
	elseif spelltype == 'table' then
		for k=1, #spell do
			NeP.Compiler.Compile(spell[k], name)
		end
	elseif spelltype == 'function' then
		local ref = {}
		ref.spell = tostring(spell)
		ref.token = 'func'
		eval.type = 'Function'
		eval.exe = spell
		eval.nogcd = true
		eval[1] = ref
	else
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Spell cant be a', type(spell))
	end

	-- Conditions
	NeP.Compiler.Conditions(eval, name)

	-- Target
	NeP.Compiler.Target(eval, name)
end

function NeP.Compiler:Iterate(eval, name)
	if not eval then return end
	for i=1, #eval do
		NeP.Compiler.Compile(eval[i], name)
	end
end
