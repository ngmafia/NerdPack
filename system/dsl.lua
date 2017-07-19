local _, NeP     = ...
local DSL        = NeP.DSL
local UnitExists = ObjectExists or UnitExists
local unpack     = unpack
local strsplit   = strsplit

function NeP.Core.string_split(_, string, delimiter)
	local result, from = {}, 1
	local delim_from, delim_to = string.find(string, delimiter, from)
	while delim_from do
		table.insert( result, string.sub(string, from , delim_from-1))
		from = delim_to + 1
		delim_from, delim_to = string.find(string, delimiter, from)
	end
	table.insert(result, string.sub(string, from))
	return result
end

local function pArgs(Strg, Spell)
	Strg = Strg or ""
	local Args = Strg:match('%((.+)%)')
	Strg = Strg:gsub('%((.+)%)', '')
	return Strg, Args, Spell
end

local function FilerNumber(str)
	if type(str) ~= 'string' then
		return str
	elseif str:find('^%d') then
		return tonumber(str)
	end
	return str
end

local OPs = {
	['>=']    = function(arg1, arg2) return arg1 >= arg2 end,
	['<=']    = function(arg1, arg2) return arg1 <= arg2 end,
	['==']    = function(arg1, arg2) return arg1 == arg2 end,
	['~=']    = function(arg1, arg2) return arg1 ~= arg2 end,
	['!=']    = self['~='],
	['>']     = function(arg1, arg2) return arg1 > arg2 end,
	['<']     = function(arg1, arg2) return arg1 < arg2 end,
	['+']     = function(arg1, arg2) return arg1 + arg2 end,
	['-']     = function(arg1, arg2) return arg1 - arg2 end,
	['/']     = function(arg1, arg2) return arg1 / arg2 end,
	['*']     = function(arg1, arg2) return arg1 * arg2 end,
	['!']     = function(arg1, arg2, Target) return not DSL.Parse(arg1, arg2, Target) end,
	['@']     = function(arg1) return NeP.Library:Parse(pArgs(arg1)) end,
}

local function DoMath(arg1, arg2, token)
	arg1, arg2 = FilerNumber(arg1), FilerNumber(arg2)
	return OPs[token](arg1 or 1, arg2 or 1)
end

local function _AND(Strg, Spell, Target)
	local Arg1, Arg2 = Strg:match('(.*)&(.*)')
	Arg1 = DSL.Parse(Arg1, Spell, Target)
	-- Dont process anything in front sence we already failed
	if not Arg1 then return false end
	Arg2 = DSL.Parse(Arg2, Spell, Target)
	return Arg1 and Arg2
end

local function _OR(Strg, Spell, Target)
	local Arg1, Arg2 = Strg:match('(.*)||(.*)')
	Arg1 = DSL.Parse(Arg1, Spell)
	-- Dont process anything in front sence we already hit
	if Arg1 then return true end
	Arg2 = DSL.Parse(Arg2, Spell, Target)
	return Arg1 or Arg2
end

local function FindNest(Strg)
	local Start, End = Strg:find('({.*})')
	local count1, count2 = 0, 0
	for i=Start, End do
		local temp = Strg:sub(i, i)
		if temp == "{" then
			count1 = count1 + 1
		elseif temp == "}" then
			count2 = count2 + 1
		end
		if count1 == count2 then
			return Start,  i
		end
	end
end

local function Nest(Strg, Spell, Target)
	local Start, End = FindNest(Strg)
	local Result = DSL.Parse(Strg:sub(Start+1, End-1), Spell, Target)
	Result = tostring(Result or false)
	Strg = Strg:sub(1, Start-1)..Result..Strg:sub(End+1)
	return DSL.Parse(Strg, Spell, Target)
end

local function ProcessCondition(Strg, Spell, Target)
	-- Condition arguments
	local Strg, Args = pArgs(Strg, Spell)
	Args = Args or Spell
	-- Unit prefix
	if not NeP.DSL:Exists(Strg) then
		local unitID, rest = strsplit('.', Strg, 2)
		unitID =  NeP.FakeUnits:Filter(unitID)[1]
		-- condition Target
		if unitID and UnitExists(unitID) then
			Target = unitID
			Strg = rest
		end
	end
	--Strg = Strg:gsub('%s', '')
	-- Process the Condition itself
	local Condition = DSL:Get(Strg)
	return Condition(Target or "player", Args)
end

local function Comperatores(Strg, Spell, Target)
	local OP = ''
	for Token in Strg:gmatch('[><=~]') do OP = OP..Token end
	if Strg:find('!=') then OP = '~=' end --tmp hack beacuse of the !
	local arg1, arg2 = unpack(NeP.Core:string_split(Strg, OP))
	arg1, arg2 = DSL.Parse(arg1, Spell, Target), DSL.Parse(arg2, Spell, Target)
	return DoMath(arg1, arg2, OP)
end

local function StringMath(Strg, Spell, Target)
	local OP, total = Strg:match('[/%*%+%-]'), 0
	local tempT = NeP.Core:string_split(Strg, OP)
	for i=1, #tempT do
		Strg = DSL.Parse(tempT[i], Spell, Target)
		if total == 0 then
			total = Strg
		else
			total = DoMath(total, Strg, OP)
		end
	end
	return total
end

local function ExeFunc(Strg)
	local Args = Strg:match('%((.+)%)')
	if Args then Strg = Strg:gsub('%((.+)%)', '') end
	return _G[Strg](Args)
end

function NeP.DSL.Parse(Strg, Spell, Target)
	local pX = Strg:sub(1, 1)
	if Strg:find('{(.-)}') then
		return Nest(Strg, Spell, Target)
	elseif Strg:find('||') then
		return _OR(Strg, Spell, Target)
	elseif Strg:find('&') then
		return _AND(Strg, Spell, Target)
	elseif OPs[pX] then
		Strg = Strg:sub(2);
		return OPs[pX](Strg, Spell, Target)
	elseif Strg:find("func=") then
		Strg = Strg:sub(6);
		return ExeFunc(Strg)
	elseif Strg:find('[><=~]') or Strg:find('!=') then
		return Comperatores(Strg, Spell, Target)
	elseif Strg:find("[/%*%+%-]") then
		return StringMath(Strg, Spell, Target)
	elseif Strg:find('%a') then
		return ProcessCondition(Strg, Spell, Target)
	end
	return Strg
end

NeP.Globals.DSL = {
	Get = NeP.DSL.Get,
	Register = NeP.DSL.Register,
	Parse = NeP.DSL.Parse
}
