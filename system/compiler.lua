local _, NeP = ...
local tonumber = tonumber
local noop = function() end
local UnitExists = UnitExists

NeP.Compiler = {}

local tokens = {}

-- DO NOT USE THIS UNLESS YOU KNOW WHAT YOUR DOING!
function NeP.Compiler.RegisterToken(_, token, func)
	tokens[token] = func
end

local function spell_string(eval)
	local ref = { spell = eval[1] }

	--Arguments
	ref.args = ref.spell:match('%((.+)%)')
	ref.spell = ref.spell:gsub('%((.+)%)','')

	-- RegisterToken
	local token = ref.spell:sub(1,1)
	while tokens[token] do
		ref.spell = ref.spell:sub(2)
		tokens[token](eval, ref)
		token = ref.spell:sub(1,1)
	end

	-- spell
	if not eval.exe then
		tokens["spell_cast"](eval, ref)
	end

	--replace with compiled
	eval[1] = ref
end

local _spell_types = {
	['table'] = function(eval)
		eval[1].is_table = true
		eval[1].master = eval.master
		eval[1].spell = tostring(eval[1])
		NeP.Compiler.Compile(eval[1])
	end,
	['function'] = function(eval)
		local ref = {}
		ref.token = 'function'
		ref.spell = tostring(eval[1])
		eval.exe = eval[1]
		eval.nogcd = true
		eval[1] = ref
	end,
	['string'] = spell_string
}

-- Takes a valid format for spell and produces a table in its place
function NeP.Compiler.Spell(eval)
	local spell_type = _spell_types[type(eval[1])]
	if spell_type then
		spell_type(eval)
	else
		NeP.Core:Print('Found a issue compiling: ', eval.master.name, '\n-> Spell cant be a', type(eval[1]))
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


local _target_types = {
	['nil'] = noop,
	['table'] = noop,
	['function'] = noop,
	['string'] = function(eval, ref) unit_ground(ref, eval) end
}

function NeP.Compiler.Target(eval)
	local ref, unit_type = {}, _target_types[type(eval[3])]
	if unit_type then
		ref.target = eval[3]
		unit_type(eval, ref)
	else
		NeP.Core:Print('Found a issue compiling: ', eval.master.name, '\n-> Target cant be a', type(eval[3]))
		_target_types['nil'](eval, ref)
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

function NeP.Compiler.Cond_Legacy_PE(cond)
	local str = '{'
	for k=1, #cond do
		local tmp, tmp_type = cond[k], type(cond[k])
		if not tmp then
			str = 'true'
		elseif tmp_type == 'table' then
			str = NeP.Compiler.Cond_Legacy_PE(cond)
		elseif tmp_type == 'boolean' then
			str = tostring(tmp):lower()
		elseif tmp_type == 'function' then
			-- FIXME: this shouldnt go to globals we need a table with these
			local name = tostring(tmp)
			_G[name] = tmp
			str = 'func='..name
		elseif tmp:lower() == 'or' then
			str = str .. '||' .. tmp
		elseif k ~= 1 then
			str = str .. '&' .. tmp
		else
			str = str .. tmp
		end
	end
	return str..'}'
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
	['string'] = function(eval)
		-- Convert spells inside () and remove spaces
		eval[2] = CondSpaces(eval[2]):gsub("%((.-)%)", function(s)
			-- we cant convert numbers due to it messing up other things
			if tonumber(s) then return '('..s..')' end
			return '('..NeP.Spells:Convert(s, eval.master.name)..')'
		end)
	end,
	['table'] = function(eval)
		-- convert everything into a string so we can then process it
		eval[2] = NeP.Compiler.Cond_Legacy_PE(eval[2])
		NeP.Compiler.Conditions(eval)
  end
}

function NeP.Compiler.Conditions(eval)
	local cond_type = _cond_types[type(eval[2])]
	if cond_type then
		cond_type(eval)
	else
		NeP.Core:Print('Found a issue compiling: ', eval.master.name, '\n-> Condition cant be a', type(eval[2]))
		_cond_types['nil'](eval)
	end
end

function NeP.Compiler.Compile(eval)
	for i=1, #eval do
		-- check if this was already done
		if not eval[i][4] then
			eval[i][4] = true
			eval[i].master = eval.master
			NeP.Compiler.Spell(eval[i])
			NeP.Compiler.Target(eval[i])
			NeP.Compiler.Conditions(eval[i])
		end
	end
end

function NeP.Compiler.Iterate(_, eval)
	if not eval then return end
	NeP.Core:WhenInGame(function()
		NeP.Compiler.Compile(eval)
	end)
end
