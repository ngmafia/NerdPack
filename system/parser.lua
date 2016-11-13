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

local function IsMountedCheck()
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID and NeP.ByPassMounts(mountID) then
			return true
		end
	end
	return (SecureCmdOptionParse("[overridebar][vehicleui][possessbar,@vehicle,exists][mounted]true")) ~= "true"
end

local function castingTime()
	local time = GetTime()
	local name, _,_,_,_, endTime = UnitCastingInfo("player")
	if not name then name, _,_,_,_, endTime = UnitChannelInfo("player") end
	return (name and (endTime/1000)-time) or 0, name
end

function NeP.Parser.Target(eval)
	local target = eval[3]
	-- Target is returned from a function
	if target.func then
		target.target = target.func()
	-- This is to alow casting at the cursor location where no unit exists
	elseif target.cursor then
		return true
	end
	-- Filter the unit (FakeUnits)
	eval.target = NeP.FakeUnits:Filter(target.target)
	-- Eval if the unit is valid
	return UnitExists(eval.target) and UnitIsVisible(eval.target)
	and NeP.Protected.LineOfSight('player', eval.target)
end

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
	-- Nornal
	elseif (spell.bypass or endtime == 0)
	and (eval.exe or (NeP.Parser.Spell(eval) and NeP.Parser.Target(eval))) then
		local tspell = eval.spell or spell.spell
		if NeP.DSL.Parse(cond, tspell) then
			-- (!spell) this clips the spell
			if spell.interrupts then
				if cname == tspell then
					return true
				elseif endtime > 0 then
					SpellStopCasting()
				end
			end
			NeP.Parser.LastCast = tspell
			NeP.Parser.LastGCD = (not eval.nogcd and tspell) or NeP.Parser.LastGCD
			NeP.Parser.LastTarget = eval.target
			NeP.ActionLog:Add(eval.type, tspell, spell.icon, eval.target)
			NeP.Interface:UpdateIcon('mastertoggle', spell.icon)
			return Exe(eval, tspell)
		end
	end
end

-- Delay until everything is ready
NeP.Core:WhenInGame(function()

C_Timer.NewTicker(0.1, (function()
	NeP.Faceroll:Hide()
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle') then
		if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
			if NeP.Queuer:Execute() then return end
			local table = NeP.CR.CR[InCombatLockdown()]
			for i=1, #table do
				if NeP.Parser.Parse(table[i]) then break end
			end
		end
	end
end), nil)

end, 99)
