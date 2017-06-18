local _, NeP = ...
NeP.Parser   = {}

-- Local stuff for speed
local GetTime              = GetTime
local UnitBuff             = UnitBuff
--local IsMounted            = IsMounted
local UnitCastingInfo      = UnitCastingInfo
local UnitChannelInfo      = UnitChannelInfo
local UnitExists           = ObjectExists or UnitExists
local UnitIsVisible        = UnitIsVisible
local GetSpellBookItemInfo = GetSpellBookItemInfo
local GetSpellCooldown     = GetSpellCooldown
local IsUsableSpell        = IsUsableSpell
local SpellStopCasting     = SpellStopCasting
local UnitIsDeadOrGhost    = UnitIsDeadOrGhost
local SecureCmdOptionParse = SecureCmdOptionParse
local InCombatLockdown     = InCombatLockdown
local C_Timer              = C_Timer

--Fake CR so the parser dosent error of no CR is selected
local noop_t = {{(function() NeP.Core:Print("No CR Selected...") end)}}
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
	--return boolean (true if mounted)
	return (SecureCmdOptionParse("[overridebar][vehicleui][possessbar,@vehicle,exists][mounted]true")) ~= "true"
end

--This is used by the parser.spell
--Returns if we're casting/channeling anything, its remaning time and name
--Also used by the parser for (!spell) if order to figure out if we should clip
local function castingTime()
	local time = GetTime()
	local name, _,_,_,_, endTime = UnitCastingInfo("player")
	if not name then name, _,_,_,_, endTime = UnitChannelInfo("player") end
	return (name and (endTime/1000)-time) or 0, name
end

--This works on the current parser target.
--This function takes care of psudo units (fakeunits).
--Returns boolean (true if the target is valid).
function NeP.Parser.Target(eval)
	-- This is to alow casting at the cursor location where no unit exists
	if eval[3].cursor then
		return true
	-- Target is returned from a function
	elseif eval[3].func then
		eval[3].target = eval[3].func()
	end
	-- Filter the unit (FakeUnits)
	eval.target = NeP.FakeUnits:Filter(eval[3].target)
	-- Eval if the unit is valid
	return UnitExists(eval.target) and UnitIsVisible(eval.target)
	and NeP.Protected.LineOfSight('player', eval.target)
end

--This works on the spell the parser is working on.
--Returns boolean (true if the spell is valid).
function NeP.Parser.Spell(eval)
	-- Special (Action, Items, etc)
	if eval[1].token then
		return NeP.Actions[eval[1].token](eval)
	-- Regular spell
	else
		local skillType = GetSpellBookItemInfo(eval[1].spell)
		local isUsable, notEnoughMana = IsUsableSpell(eval[1].spell)
		if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
			local GCD = NeP.DSL:Get('gcd')()
			return GetSpellCooldown(eval[1].spell) <= GCD
			and NeP.Helpers:Check(eval[1].spell, eval.target)
		end
	end
end

-- If a Lib or a function in spell returns true, the loop breaks and starts over
-- Otherwise it will just move to the next castable spell.
local function Exe(eval, tspell)
	-- Special like libs and funcs
	if eval.exe then
		return eval.exe()
	-- Normal
	else
		NeP.Protected[eval.func](tspell, eval.target)
		return true
	end
end

--This is the actual Parser...
--Reads and figures out what it should execute from the CR
--The Cr when it reaches this point must be already compiled and be ready to run.
function NeP.Parser.Parse(eval)
	local spell, cond = eval[1], eval[2]
	local endtime, cname = castingTime()
	-- Its a table
	if not spell.spell then
		if NeP.DSL.Parse(cond) then
			for i=1, #spell do
				if NeP.Parser.Parse(spell[i]) then
					return true
				end
			end
		end
	-- Normal
	elseif (spell.bypass or endtime == 0)
	and (eval.exe or (NeP.Parser.Target(eval) and NeP.Parser.Spell(eval))) then
		-- Evaluate conditions
		local tspell = eval.spell or spell.spell
		if NeP.DSL.Parse(cond, tspell, eval.target) then
			-- (!spell) this clips the spell
			if spell.interrupts then
				if cname == tspell then
					return true
				elseif endtime > 0 then
					SpellStopCasting()
				end
			end
			--Set vars
			NeP.Parser.LastCast = tspell
			NeP.Parser.LastGCD = (not eval.nogcd and tspell) or NeP.Parser.LastGCD
			NeP.Parser.LastTarget = eval.target
			--Update the actionlog and master toggle icon
			NeP.ActionLog:Add(eval.type, tspell, spell.icon, eval.target)
			NeP.Interface:UpdateIcon('mastertoggle', spell.icon)
			--Execute
			return Exe(eval, tspell)
		end
	end
end

-- Delay until everything is ready
NeP.Core:WhenInGame(function()

C_Timer.NewTicker(0.1, (function()
	--Hide Faceroll frame
	NeP.Faceroll:Hide()
	--Only run if mastertoggle is enabled, not dead and valid mount situation
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle')
	and not UnitIsDeadOrGhost('player') and IsMountedCheck() then
		--Run the Queue (If it returns true, end)
		if NeP.Queuer:Execute() then return end
		--Iterate the CR (If it returns true, end)
		local table = NeP.CR.CR[InCombatLockdown()] or noop_t
		for i=1, #table do
			if NeP.Parser.Parse(table[i]) then break end
		end
	end
end), nil)

end, 99)
