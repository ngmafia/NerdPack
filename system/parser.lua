local _, NeP = ...

NeP.Parser = {}

local function IsMountedCheck()
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID and NeP.ByPassMounts(mountID) then
			return true
		end
	end
	return not IsMounted()
end

local function castingTime()
	local time = GetTime()
	local a_endTime = select(6,UnitCastingInfo("player"))
	if a_endTime then return (a_endTime/1000 )-time end
	local b_endTime = select(6,UnitChannelInfo("player"))
	if b_endTime then return (b_endTime/1000)-time end
	return 0
end

local fake_target = {
	func = function()
		return UnitExists('target') and 'target' or 'player'
	end
}

function NeP.Parser:Target(eval)
	-- This is so we dont generate garbage when using fake_target
	eval = eval or fake_target
	if eval.func then
		eval.target = eval.func()
	end
	-- Check unit
	if UnitExists(eval.target) and UnitIsVisible(eval.target) then
		return true
	end
end

function NeP.Parser:Spell(eval)
	print(eval.spell)
	if eval.token then
		print(eval.token)
		return NeP.Actions[eval.token](eval)
	end
	local skillType = GetSpellBookItemInfo(eval.spell)
	local isUsable, notEnoughMana = IsUsableSpell(eval.spell)
	if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
		local GCD = NeP.DSL:Get('gcd')()
		if GetSpellCooldown(eval.spell) <= GCD then
			return true
		end
	end
end

function NeP.Parser:Parse(eval)
	if not eval[1].spell then
		if NeP.DSL:Parse(eval[2]) then
			local r = self:Parse(eval[1])
			if r then return true end
		end
	elseif eval[1].interrupts or eval[1].token or (castingTime('player') == 0) then
		if self:Target(eval[3]) then
			if self:Spell(eval[1]) and NeP.DSL:Parse(eval[2]) then
				print('final')
				-- Cancels the current cast
				if eval[1].interrupts then
					SpellStopCasting()
				end
				-- TODO, EXECUTE/CAST
				return true
			end
		end
	end
end

C_Timer.NewTicker(0.1, (function()
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle') then
		if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
			local table = NeP.CR.CR[InCombatLockdown()]
			for i=1, #table do
				local r = NeP.Parser:Parse(table[i])
				if r then break end
			end
		end
	end
end), nil)