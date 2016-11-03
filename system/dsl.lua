local _, NeP = ...

local DSL = NeP.DSL

function NeP.Core:string_split(string, delimiter)
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

local function pArgs(Strg)
	local Args = Strg:match('%((.+)%)')
	if Args then
		Strg = Strg:gsub('%((.+)%)', '')
	end
	return Strg, Args
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
	['>']     = function(arg1, arg2) return arg1 > arg2 end,
	['<']     = function(arg1, arg2) return arg1 < arg2 end,
	['+']     = function(arg1, arg2) return arg1 + arg2 end,
	['-']     = function(arg1, arg2) return arg1 - arg2 end,
	['/']     = function(arg1, arg2) return arg1 / arg2 end,
	['*']     = function(arg1, arg2) return arg1 * arg2 end,
	['!']     = function(arg1, arg2) return not DSL.Parse(arg1, arg2) end,
	['@']     = function(arg1) return NeP.Library:Parse(pArgs(arg1)) end,
	['true']  = function() return true end,
	['false'] = function() return false end,
}

local function DoMath(arg1, arg2, token)
	arg1, arg2 = FilerNumber(arg1), FilerNumber(arg2)
	return (arg1 and arg2) and OPs[token](arg1, arg2)
end

local function _AND(Strg, Spell)
	local Arg1, Arg2 = Strg:match('(.*)&(.*)')
	Arg1 = DSL.Parse(Arg1, Spell)
	-- Dont process anything in front sence we already failed
	if not Arg1 then return false end
	Arg2 = DSL.Parse(Arg2, Spell)
	return Arg1 and Arg2
end

local function _OR(Strg, Spell)
	local Arg1, Arg2 = Strg:match('(.*)||(.*)')
	Arg1 = DSL.Parse(Arg1, Spell)
	-- Dont process anything in front sence we already hit
	if Arg1 then return true end
	Arg2 = DSL.Parse(Arg2, Spell)
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

local function Nest(Strg, Spell)
	local Start, End = FindNest(Strg)
	local Result = DSL.Parse(Strg:sub(Start+1, End-1), Spell)
	Result = tostring(Result or false)
	Strg = Strg:sub(1, Start-1)..Result..Strg:sub(End+1)
	return DSL.Parse(Strg, Spell)
end

local function ProcessCondition(Strg, Spell)
	-- Process Unit Stuff
	local unitID, rest = strsplit('.', Strg, 2)
	-- default target
	local target =  'player'
	unitID =  NeP.FakeUnits:Filter(unitID)
	if unitID and UnitExists(unitID) then
		target = unitID
		Strg = rest
	end
	-- Condition arguments
	local Strg, Args = pArgs(Strg)
	if Args then
		if Args:find('^%a') then
			-- Translates the name to the correct locale
			Args = NeP.Spells:Convert(Args)
		end
	else
		Args = Spell
	end
	Strg = Strg:gsub('%s', '')
	-- Process the Condition itself
	local Condition = DSL:Get(Strg)
	if Condition then return Condition(target, Args) end
end

local fOps = {['!='] = '~=',['='] = '=='}
local function Comperatores(Strg, Spell)
	local OP = ''
	for Token in Strg:gmatch('[><=~]') do OP = OP..Token end
	if Strg:find('!=') then OP = '!=' end
	local arg1, arg2 = unpack(NeP.Core:string_split(Strg, OP))
	arg1, arg2 = DSL.Parse(arg1, Spell), DSL.Parse(arg2, Spell)
	return DoMath(arg1, arg2, (fOps[OP] or OP))
end

local function StringMath(Strg, Spell)
	local OP, total = Strg:match('[/%*%+%-]'), 0
	local tempT = NeP.Core:string_split(Strg, OP)
	for i=1, #tempT do
		Strg = DSL.Parse(tempT[i], Spell)
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

function NeP.DSL.Parse(Strg, Spell)
	local pX = Strg:sub(1, 1)
	if Strg:find('{(.-)}') then
		return Nest(Strg, Spell)
	elseif Strg:find('||') then
		return _OR(Strg, Spell)
	elseif Strg:find('&') then
		return _AND(Strg, Spell)
	elseif OPs[pX] then
		Strg = Strg:sub(2);
		return OPs[pX](Strg, Spell)
	elseif Strg:find("func=") then
		Strg = Strg:sub(6);
		return ExeFunc(Strg)
	elseif Strg:find('[><=~]') then
		return Comperatores(Strg, Spell)
	elseif Strg:find('!=') then
		return Comperatores(Strg, Spell)
	elseif Strg:find("[/%*%+%-]") then
		return StringMath(Strg, Spell)
	elseif OPs[Strg] then
		return OPs[Strg](Strg, Spell)
	elseif Strg:find('%a') then
		return ProcessCondition(Strg, Spell)
	else
		return Strg
	end
end

NeP.Globals.DSL = {
	Get = NeP.DSL.Get,
	Register = NeP.DSL.Register,
	Parse = NeP.DSL.Parse
}
