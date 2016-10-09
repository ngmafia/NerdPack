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
	local temp = eval or fake_target
	-- Check unit
	if UnitExists(temp.target) and UnitIsVisible(temp.target) then
		return true
	end
end

function NeP.Parser:Spell(eval)
	print(eval[1].spell)
	if eval[1].token then
		print()
		return NeP.Actions[eval[1].token](eval)
	end
	local skillType = GetSpellBookItemInfo(eval[1].spell)
	local isUsable, notEnoughMana = IsUsableSpell(eval[1].spell)
	if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
		local GCD = NeP.DSL:Get('gcd')()
		if GetSpellCooldown(eval[1].spell) <= GCD then
			eval.func = eval[3].ground and NeP.Protected.CastGround or NeP.Protected.Cast
			return true
		end
	end
end

function NeP.Parser:Table(spell, cond)
	if NeP.DSL:Parse(cond) then
		for i=1, #spell do
			local r = self:Parse(spell[i])
			if r then print('broke') return true end
		end
	end
end

function NeP.Parser:Parse(eval)
	local spell, cond, target = eval[1], eval[2], eval[3]
	print('s',spell)
	if not spell.spell then
		self:Table(spell, cond)
	elseif spell.bypass or (castingTime('player') == 0) then
		print(0)
		if self:Target(target) then
			if spell.token == 'func' or self:Spell(eval) then
				print(1)
				if NeP.DSL:Parse(cond, spell.spell) then
					if eval.breaks then
						return true
					end
					if spell.interrupts then
						SpellStopCasting()
					end
					eval.func(spell.spell, target.target)
					print('final')
					return true
				end
			end
		end
	end
end

C_Timer.NewTicker(0.1, (function()
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle') then
		if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
			local table = NeP.CR.CR[InCombatLockdown()]
			print('------------------------------------------')
			for i=1, #table do
				if NeP.Parser:Parse(table[i]) then break end
			end
		end
	end
end), nil)