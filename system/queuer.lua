local _, NeP = ...

NeP.Queuer = {}
local Queue = {}

function NeP.Queuer:Add(spell, target)
	spell = NeP.Spells:Convert(spell)
	if not spell then return end
	Queue[spell] = {
		time = GetTime(),
		target = target or UnitExists('target') and 'target' or 'player'
	}
end

function NeP.Queuer:Spell(spell)
 	local skillType = GetSpellBookItemInfo(spell)
	local isUsable, notEnoughMana = IsUsableSpell(spell)
	if skillType ~= 'FUTURESPELL' and isUsable and not notEnoughMana then
		local GCD = NeP.DSL:Get('gcd')()
		if GetSpellCooldown(spell) <= GCD then
			return true
		end
	end
end

function NeP.Queuer:Execute()
	for spell, v in pairs(Queue) do
		if (GetTime() - v.time) > 5 then
			Queue[spell] = nil
		elseif self:Spell(spell) then
			NeP.Protected.Cast(spell, v.target)
			Queue[spell] = nil
			return true
		end
	end
end

NeP.Globals.Queue = NeP.Queuer.Add