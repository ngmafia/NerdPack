local _, NeP = ...
NeP.Parser   = {}

-- Local stuff for speed
local GetTime              = GetTime
local UnitBuff             = UnitBuff
local UnitCastingInfo      = UnitCastingInfo
local UnitChannelInfo      = UnitChannelInfo
local UnitExists           = ObjectExists or UnitExists
local UnitIsVisible        = UnitIsVisible
local SpellStopCasting     = SpellStopCasting
local UnitIsDeadOrGhost    = UnitIsDeadOrGhost
local SecureCmdOptionParse = SecureCmdOptionParse
local InCombatLockdown     = InCombatLockdown
local C_Timer              = C_Timer

--Fake CR so the parser dosent error of no CR is selected
local noop_t = { {(function() NeP.Core:Print("No CR Selected...") end)} }
NeP.Compiler:Iterate(noop_t, "FakeCR")

--This is used by the ticker
--Its used to determin if we should iterate or not
--Returns true if we're not mounted or in a castable mount
local function IsMountedCheck()
	--Figure out if we're mounted on a castable mount
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID and NeP.ByPassMounts(mountID) then
			return true
		end
	end
	--return boolean (true if not mounted)
	return (SecureCmdOptionParse("[overridebar][vehicleui][possessbar,@vehicle,exists][mounted]true")) ~= "true"
end

--This is used by the parser.spell
--Returns if we're casting/channeling anything, its remaning time and name
--Also used by the parser for (!spell) if order to figure out if we should clip
local function castingTime()
	local time = GetTime()
	local name, _,_,_,_, endTime = UnitCastingInfo("player") or UnitChannelInfo("player")
	return (name and (endTime/1000)-time) or 0, name
end

local function _interrupt(eval, endtime, cname)
	if eval[1].interrupts then
		if cname == eval.spell or endtime < 1 then
			return false
		else
			SpellStopCasting()
		end
	end
	return true
end

local function tst(tbl, _type)
	if not tbl then return end
	for i=1, #tbl do
		local _count = tbl[i].count
		if _count then
			if NeP.DSL:Get(_type..'.count.any')(unit, tbl[i].name) >= _count then return true end
		else
			if NeP.DSL:Get(_type..'.any')(unit, tbl[i]) then return true end
		end
	end
end

function NeP.Parser.Unit_Blacklist(_, unit)
	local bl = NeP.CR.CR.blacklist
	return bl[NeP.Core:UnitID(unit)] or tst(bl.buff, "buff") or tst(bl.debuff, "debuff")
end

--This works on the current parser target.
--This function takes care of psudo units (fakeunits).
--Returns boolean (true if the target is valid).
local noob_target = function() return UnitExists('target') and 'target' or 'player' end
function NeP.Parser.Target(eval)
	-- This is to alow casting at the cursor location where no unit exists
	if eval[3].cursor then return true end
	-- Eval if the unit is valid
	return UnitExists(eval.target)
	and UnitIsVisible(eval.target)
	and NeP.Protected.LineOfSight('player', eval.target)
	and not NeP.Parser:Unit_Blacklist(eval.target)
end

function NeP.Parser.Parse2(eval, tmp_target, endtime, cname, func)
	local res;
	--used to only filter target if it wasnt done already
	if not eval[3].target then
		eval.target = tmp_target or noob_target()
		return func(eval, endtime, cname, tmp_target, func)
	end
	tmp_target = NeP.FakeUnits:Filter(eval[3].target)
	for i=1, #tmp_target do
		eval.target = tmp_target[i]
		res = func(eval, endtime, cname, tmp_target, func)
		if res then return res end
	end
end

function NeP.Parser.Parse3(eval, _,_, tmp_target, func)
	local res;
	if NeP.DSL.Parse(eval[2], eval.target) then
		for i=1, #eval[1] do
			res = NeP.Parser.Parse(eval[1][i], eval.target)
			if res then return res end
		end
	end
end

function NeP.Parser.Parse4(eval, endtime, cname)
	if not NeP.Parser.Target(eval) then return end
	eval.spell = eval.spell or eval[1].spell
	if NeP.DSL.Parse(eval[2], eval.spell, eval.target)
	and NeP.Helpers:Check(eval.spell, eval.target)
	and _interrupt(eval, endtime, cname) then
		NeP.ActionLog:Add(eval[1].token, eval.spell or "", eval[1].icon, eval.target)
		NeP.Interface:UpdateIcon('mastertoggle', eval[1].icon)
		return eval.exe(eval)
	end
end

--This is the actual Parser...
--Reads and figures out what it should execute from the CR
--The CR when it reaches this point must be already compiled and be ready to run.
function NeP.Parser.Parse(eval, tmp_target)
	local endtime, cname = castingTime()
	-- Its a table
	if eval[1].is_table then
		return NeP.Parser.Parse2(eval, tmp_target, endtime, cname, NeP.Parser.Parse3)
	-- Normal
	elseif (eval[1].bypass or endtime == 0)
	and NeP.Actions:Eval(eval[1].token)(eval) then
		return NeP.Parser.Parse2(eval, tmp_target, endtime, cname, NeP.Parser.Parse4)
	end
end

-- Delay until everything is ready
NeP.Core:WhenInGame(function()

C_Timer.NewTicker(0.1, (function()
	NeP.Faceroll:Hide()
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle')
	and not UnitIsDeadOrGhost('player') and IsMountedCheck() then
		if NeP.Queuer:Execute() then return end
		local table = NeP.CR.CR[InCombatLockdown()] or noop_t
		for i=1, #table do
			if NeP.Parser.Parse(table[i]) then break end
		end
	end
end), nil)

end, 99)
