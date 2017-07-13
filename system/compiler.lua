local _, NeP = ...
local tonumber = tonumber
local UnitExists = ObjectExists or UnitExists

NeP.Compiler = {}

local tokens = {}

-- DO NOT USE THIS UNLESS YOU KNOW WHAT YOUR DOING!
function NeP.Compiler.RegisterToken(_, token, func)
	tokens[token] = func
end

local function spell_string(eval, name)
	local ref = { spell = eval[1] }

	--Arguments
	local arg1, args = ref.spell:match('(.+)%((.+)%)')
	if args then ref.spell = arg1 end
	ref.args = args

	-- RegisterToken
	local token = ref.spell:sub(1,1)
	while tokens[token] do
		ref.spell = ref.spell:sub(2)
		tokens[token](eval, name, ref)
		token = ref.spell:sub(1,1)
	end

	-- spell
	if not eval.exe then
		tokens["spell_cast"](eval, name, ref)
	end

	--replace with compiled
	eval[1] = ref
end

local _spell_types = {
	['table'] = function(eval, name)
		eval[1].is_table = true
		for k=1, #eval[1] do
			NeP.Compiler.Compile(eval[1][k], name, eval[3].target)
		end
	end,
	['function'] = function(eval)
		local ref = {}
		ref.token = 'function'
		eval.exe = eval[1]
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
		eval[1] = {
			spell = 'fake',
			token = 'spell_cast',
		}
		eval[2] = 'true'
	end
end

local function unit_ground(ref, eval)
	if ref.target:find('.ground') then
		ref.target = ref.target:sub(0,-8)
		eval.exe = function(eva)
			NeP.Parser.LastCast = eva.spell
			NeP.Parser.LastGCD = (not eva.nogcd and eva.spell) or NeP.Parser.LastGCD
			NeP.Parser.LastTarget = eva.target
			return NeP.Protected["CastGround"](eva.spell, eva.target)
		end
		-- This is to alow casting at the cursor location where no unit exists
		if ref.target:lower() == 'cursor' then ref.cursor = true end
	end
end

local noob_target = function() return UnitExists('target') and 'target' or 'player' end

local _target_types = {
	['nil'] = function(eval, _, ref, target)
		ref.target = target or noob_target
	end,
	['table'] = function(eval, _, ref)
		ref.target = eval[3]
	end,
	['function'] = function(eval, _, ref)
		ref.target = eval[3]
	end,
	['string'] = function(eval, _, ref)
		ref.target = eval[3]
		unit_ground(ref, eval)
	end
}

function NeP.Compiler.Target(eval, name, target)
	local ref, unit_type = {}, _target_types[type(eval[3])]
	if unit_type then
		unit_type(eval, name, ref, target)
	else
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Target cant be a', type(eval[3]))
		_target_types['nil'](eval, name, ref)
	end
	eval[3] = ref
end

-- Remove whitespaces (_xspc_ needs to be unique so we dont
-- end up replacing something we shouldn't)
local function CondSpaces(cond)
	return cond:gsub("%b()", function(s)
		return s:gsub(" ", "_xspc_")
	end):gsub("%s", ""):gsub("_xspc_", " ")
end

local _cond_types = {
	['nil'] = function(eval)
		eval[2] = 'true'
	end,
	['function'] = function(eval)
		local _func_name = tostring(eval[2])
		_G[_func_name] = eval[2]
		eval[2] = 'func='.._func_name
	end,
	['boolean'] = function(eval)
		eval[2] = tostring(eval[2])
	end,
	['string'] = function(eval, name)
		-- Convert spells inside () and remove spaces
		eval[2] = CondSpaces(eval[2]):gsub("%((.-)%)", function(s)
			-- we cant convert numbers due to it messing up other things
			if tonumber(s) then return '('..s..')' end
			return '('..NeP.Spells:Convert(s, name)..')'
		end)
	end
}

function NeP.Compiler.Conditions(eval, name)
	local cond_type = _cond_types[type(eval[2])]
	if cond_type then
		cond_type(eval, name)
	else
		NeP.Core:Print('Found a issue compiling: ', name, '\n-> Condition cant be a', type(eval[2]))
		_cond_types['nil'](eval, name)
	end
end

function NeP.Compiler.Compile(eval, name, target)
	-- check if this was already done
	if eval[4] then return end
	eval[4] = true
	-- Target
	NeP.Compiler.Target(eval, name, target)
	--Spell
	NeP.Compiler.Spell(eval, name)
	-- Conditions
	NeP.Compiler.Conditions(eval, name)
end

function NeP.Compiler.Iterate(_, eval, name)
	if not eval then return end
	NeP.Core:WhenInGame(function()
		for i=1, #eval do
			NeP.Compiler.Compile(eval[i], name)
		end
	end)
end
