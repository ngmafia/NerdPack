local _, NeP = ...
--[[
					BUFFS/DEBUFFS CONDITIONS!
			Only submit BUFF specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

local function oFilter(owner, spell, spellID, caster)
	if not owner then
		if spellID == tonumber(spell) and (caster == 'player' or caster == 'pet') then
			return false
		end
	elseif owner == "any" then
		if spellID == tonumber(spell) then
			return false
		end
	end
	return true
end

local UnitBuff = function(target, spell, owner)
	local name, count, caster, expires, spellID
	if tonumber(spell) then
		local go, i = true, 0
		while i <= 40 and go do
			i = i + 1
			name,_,_,count,_,duration,expires,caster,_,_,spellID = _G['UnitBuff'](target, i)
			go = oFilter(owner, spell, spellID, caster)
		end
	else
		name,_,_,count,_,duration,expires,caster = _G['UnitBuff'](target, spell)
	end
	-- This adds some random factor
	return name, count, expires, caster
end

local UnitDebuff = function(target, spell, owner)
	local name, count, caster, expires, spellID, power
	if tonumber(spell) then
		local go, i = true, 0
		while i <= 40 and go do
			i = i + 1
			name,_,_,count,_,duration,expires,caster,_,_,spellID,_,_,_,power = _G['UnitDebuff'](target, i)
			go = oFilter(owner, spell, spellID, caster)
		end
	else
		name,_,_,count,_,duration,expires,caster = _G['UnitDebuff'](target, spell)
	end
	return name, count, expires, caster, power
end

local heroismBuffs = { 32182, 90355, 80353, 2825, 146555 }
NeP.DSL:Register("hashero", function()
	for i = 1, #heroismBuffs do
		local SpellName = NeP.Core:GetSpellName(heroismBuffs[i])
		local buff = UnitBuff('player', SpellName, "any")
		if buff then return true end
	end
	return false
end)

------------------------------------------ BUFFS -----------------------------------------
------------------------------------------------------------------------------------------
NeP.DSL:Register("buff", function(target, spell)
	local buff,_,_,caster = UnitBuff(target, spell)
	if not not buff and (caster == 'player' or caster == 'pet') then
		return true
	end
end)

NeP.DSL:Register("buff.any", function(target, spell)
	local buff = UnitBuff(target, spell, "any")
	if not not buff then
		return true
	end
end)

NeP.DSL:Register("buff.count", function(target, spell)
	local buff,count,_,caster = UnitBuff(target, spell)
	if not not buff and (caster == 'player' or caster == 'pet') then
		return count
	end
	return 0
end)

NeP.DSL:Register("buff.duration", function(target, spell)
	local buff,_,expires,caster = UnitBuff(target, spell)
	if buff and (caster == 'player' or caster == 'pet') then
		return (expires - GetTime())
	end
	return 0
end)

------------------------------------------ DEBUFFS ---------------------------------------
------------------------------------------------------------------------------------------

NeP.DSL:Register("debuff", function(target, spell)
	local debuff,_,_,caster = UnitDebuff(target, spell)
	if not not debuff and (caster == 'player' or caster == 'pet') then
		return true
	end
end)

NeP.DSL:Register("debuff.any", function(target, spell)
	local debuff = UnitDebuff(target, spell, "any")
	if not not debuff then
		return true
	end
end)

NeP.DSL:Register("debuff.count", function(target, spell)
	local debuff,count,_,caster = UnitDebuff(target, spell)
	if not not debuff and (caster == 'player' or caster == 'pet') then
		return count
	end
	return 0
end)

NeP.DSL:Register("debuff.duration", function(target, spell)
	local debuff,_,expires,caster = UnitDebuff(target, spell)
	if debuff and (caster == 'player' or caster == 'pet') then
		return (expires - GetTime())
	end
	return 0
end)