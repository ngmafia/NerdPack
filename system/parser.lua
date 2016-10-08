local _, NeP = ...

NeP.Parser = {}

local function checkTarget(eval)
	eval.isGround = false
	-- none defined (decide one)
	if not eval.target then
		eval.target = UnitExists('target') and 'target' or 'player'
	else
		-- fake units
		eval.target = NeP.FakeUnits.Filter(eval.target)
		if not eval.target then return end
	end
	-- is it ground?
	if eval.target:sub(-7) == '.ground' then
		eval.isGround = true
		eval.target = eval.target:sub(0,-8)
	end
	-- Sanity checks
	if eval.isGround and eval.target == 'mouseover'
	or UnitExists(eval.target) and UnitIsVisible(eval.target)
	and NeP.Protected.LineOfSight('player', eval.target) then
	
	else
		eval = nil
	end
end

local function castingTime()
	local time = GetTime()
	local a_endTime = select(6,UnitCastingInfo("player"))
	if a_endTime then return (a_endTime/1000 )-time end
	local b_endTime = select(6,UnitChannelInfo("player"))
	if b_endTime then return (b_endTime/1000)-time end
	return 0
end

local function IsMountedCheck()
	for i = 1, 40 do
		local mountID = select(11, UnitBuff('player', i))
		if mountID and NeP.ByPassMounts(mountID) then
			return true
		end
	end
	return not IsMounted()
end

local SpellSanity = NeP.Helpers.SpellSanity

function NeP.Parser:Spell(eval)
	local spell = eval.spell
	NeP.Spells:Convert(spell)
	if spell and SpellSanity(spell, eval.target) then
		local skillType = GetSpellBookItemInfo(spell)
		local isUsable, notEnoughMana = IsUsableSpell(spell)
		if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
			local GCD = NeP.DSL:Get('gcd')()
			if GetSpellCooldown(spell) <= GCD then
				eval.ready = true
			end
		end
	end
end

function NeP.Parser:FUNCTION(eval)
	eval.func = eval.spell
end

function NeP.Parser:TABLE(eval)
	if NeP.DSL:Parse(eval.conditions) then
		for i=1, #eval.spell do
			if NeP.Parser:Parse(unpack(eval.spell[i])) then
				return true
			end
		end
	end
end

function NeP.Parser:STRING(eval)
	local pX = eval.spell:sub(1, 1)
	if NeP.Actions[pX] then
		NeP.Actions[pX](eval)
	elseif eval.bypass or (castingTime('player') == 0) then
		checkTarget(eval)
		if not eval then return end
		self:Spell(eval)
		if eval.ready then
			eval.icon = select(3, GetSpellInfo(eval.spell))
			eval.func = eval.isGround and NeP.Protected.CastGround or NeP.Protected.Cast
		end
	end
end

function NeP.Parser:NIL()
end

function NeP.Parser:Parse(spell, conditions, target)
	local eval = self[type(spell):upper()](self, {
		spell = spell,
		target = target,
		conditions = conditions
	})
	if eval and NeP.DSL:Parse(eval.conditions, eval.spell) then
		if eval.si then
			SpellStopCasting()
		end
		if eval.breaks then
			return true
		elseif eval.func then
			self.ForceTarget = nil
			self.lastCast = eval.spell
			self.lastTarget = eval.target
			--NeP.ActionLog.insert('Engine_Parser', tostring(eval.spell), eval.icon, eval.target)
			--NeP.Interface.UpdateToggleIcon('mastertoggle', eval.icon)
			eval.func(self, eval.spell, eval.target)
			return true
		end
	end
end

C_Timer.NewTicker(0.1, (function()
	if NeP.DSL:Get('toggle')(nil, 'mastertoggle') then
		if not UnitIsDeadOrGhost('player') and IsMountedCheck() then
			local table = NeP.CR.CR[InCombatLockdown()]
			NeP.Parser:Parse(table)
		end
	end
end), nil)