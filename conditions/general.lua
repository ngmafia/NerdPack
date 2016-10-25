local _, NeP = ...
local LibBoss = LibStub("LibBossIDs-1.0")

-- Local stuff for faster performance
-- This does increase memory usage but saves CPU time
local UnitInParty                 = UnitInParty
local UnitInRaid                  = UnitInRaid
local GetNumGroupMembers          = GetNumGroupMembers
local UnitClassification          = UnitClassification
local UnitThreatSituation         = UnitThreatSituation
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitGUID                    = UnitGUID
local GetUnitSpeed                = GetUnitSpeed
local UnitExists                  = UnitExists
local UnitIsUnit                  = UnitIsUnit
local UnitIsPlayer                = UnitIsPlayer
local GetTime                     = GetTime
local UnitIsDeadOrGhost           = UnitIsDeadOrGhost
local UnitCanAttack               = UnitCanAttack
local UnitAffectingCombat         = UnitAffectingCombat
local UnitCreatureType            = UnitCreatureType
local IsEquippedItemType          = IsEquippedItemType
local UnitName                    = UnitName
local IsMounted                   = IsMounted
local GetSpellInfo                = GetSpellInfo
local UnitPowerMax                = UnitPowerMax
local UnitChannelInfo             = UnitChannelInfo
local UnitCastingInfo             = UnitCastingInfo
local UnitPower                   = UnitPower
local GetPowerRegen               = GetPowerRegen
local GetSpellCooldown            = GetSpellCooldown
local GetSpellCharges             = GetSpellCharges
local IsSpellInRange              = IsSpellInRange
local GetSpellCount               = GetSpellCount
local GetShapeshiftForm           = GetShapeshiftForm
local IsUsableSpell               = IsUsableSpell
local strsplit                    = strsplit
local GetGlyphSocketInfo          = GetGlyphSocketInfo
local GetTotemInfo                = GetTotemInfo
local UnitPowerType               = UnitPowerType
local UnitClass                   = UnitClass
local GetWeaponEnchantInfo        = GetWeaponEnchantInfo
local GetSpecialization           = GetSpecialization
local UnitMana                    = UnitMana
local UnitManaMax                 = UnitManaMax
local GetRuneCooldown             = GetRuneCooldown
local GetActiveSpecGroup          = GetActiveSpecGroup
local GetTalentInfo               = GetTalentInfo

local SPELL_POWER_INSANITY       = SPELL_POWER_INSANITY
local SPELL_POWER_FOCUS          = SPELL_POWER_FOCUS
local SPELL_POWER_RUNIC_POWER    = SPELL_POWER_RUNIC_POWER
local SPELL_POWER_MAELSTROM      = SPELL_POWER_MAELSTROM
local SPELL_POWER_SOUL_SHARDS    = SPELL_POWER_SOUL_SHARDS
local SPELL_POWER_CHI            = SPELL_POWER_CHI
local SPELL_POWER_LUNAR_POWER    = SPELL_POWER_LUNAR_POWER
local SPELL_POWER_HOLY_POWER     = SPELL_POWER_HOLY_POWER
local SPELL_POWER_RAGE           = SPELL_POWER_RAGE
local SPELL_POWER_FURY           = SPELL_POWER_FURY
local SPELL_POWER_PAIN           = SPELL_POWER_PAIN
local SPELL_POWER_ARCANE_CHARGES = SPELL_POWER_ARCANE_CHARGES
local SPELL_POWER_COMBO_POINTS   = SPELL_POWER_COMBO_POINTS

------------------------------------GENERAL------------------------------------------
-------------------------------------------------------------------------------------

local function checkChanneling(target)
	local name, _, _, _, startTime, endTime, _, notInterruptible = UnitChannelInfo(target)
	if name then return name, startTime, endTime, notInterruptible end
end

local function checkCasting(target)
	local name, startTime, endTime, notInterruptible = checkChanneling(target)
	if name then return name, startTime, endTime, notInterruptible end
	name, _,_,_, startTime, endTime, _,_, notInterruptible = UnitCastingInfo(target)
	if name then return name, startTime, endTime, notInterruptible end
end

NeP.DSL:Register('timetomax', function(target)
	local max = UnitPowerMax(target)
	local curr = UnitPower(target)
	local regen = select(2, GetPowerRegen(target))
	return (max - curr) * (1.0 / regen)
end)

NeP.DSL:Register('toggle', function(_, toggle)
	return NeP.Config:Read('TOGGLE_STATES', toggle:lower(), false)
end)

NeP.DSL:Register('casting.percent', function(target)
    local name, startTime, endTime, notInterruptible = checkCasting(target)
    if name and not notInterruptible then
        local castLength = (endTime - startTime) / 1000
        local secondsDone = GetTime() - (startTime / 1000)
        return ((secondsDone/castLength)*100)
    end
    return 0
end)

NeP.DSL:Register('casting.delta', function(target)
	local name, startTime, endTime, notInterruptible = checkCasting(target)
	if name and not notInterruptible then
		local castLength = (endTime - startTime) / 1000
		local secondsLeft = endTime / 1000 - GetTime()
		return secondsLeft, castLength
	end
	return 0
 end)

NeP.DSL:Register('channeling', function (target, spell)
	local name = checkChanneling(target)
	spell = NeP.Core:GetSpellName(spell)
	return spell and (name == spell)
end)

NeP.DSL:Register('casting', function(target, spell)
	local name = checkCasting(target)
	spell = NeP.Core:GetSpellName(spell)
	return spell and (name == spell)
end)

NeP.DSL:Register('interruptAt', function (target, spell)
	if UnitIsUnit('player', target) then return false end
	if spell and NeP.DSL:Get('toggle')(nil, 'Interrupts') then
		local stopAt = (tonumber(spell) or 35) + math.random(-5, 5)
		local secondsLeft, castLength = NeP.DSL:Get('casting.delta')(target)
		return secondsLeft ~= 0 and (100 - (secondsLeft / castLength * 100)) > stopAt
	end
end)

NeP.DSL:Register('spell.cooldown', function(_, spell)
	local start, duration = GetSpellCooldown(spell)
	if not start then return 0 end
	return start ~= 0 and (start + duration - GetTime()) or 0
end)

NeP.DSL:Register('spell.recharge', function(_, spell)
	local time = GetTime()
	local _, _, start, duration = GetSpellCharges(spell)
	if (start + duration - time) > duration then
		return 0
	end
	return (start + duration - time)
end)

NeP.DSL:Register('spell.usable', function(_, spell)
	return IsUsableSpell(spell) ~= nil
end)

NeP.DSL:Register('spell.exists', function(_, spell)
	return NeP.Core:GetSpellBookIndex(spell) ~= nil
end)

NeP.DSL:Register('spell.charges', function(_, spell)
	local charges, maxCharges, start, duration = GetSpellCharges(spell)
	if duration and charges ~= maxCharges then
		charges = charges + ((GetTime() - start) / duration)
	end
	return charges or 0
end)

NeP.DSL:Register('spell.count', function(_, spell)
	return select(1, GetSpellCount(spell))
end)

NeP.DSL:Register('spell.range', function(target, spell)
	local spellIndex, spellBook = NeP.Core:GetSpellBookIndex(spell)
	if not spellIndex then return false end
	return spellIndex and IsSpellInRange(spellIndex, spellBook, target)
end)

NeP.DSL:Register('spell.casttime', function(_, spell)
	local CastTime = select(4, GetSpellInfo(spell)) / 1000
	if CastTime then return CastTime end
	return 0
end)

NeP.DSL:Register('combat.time', function(target)
	return NeP.CombatTracker:CombatTime(target)
end)

NeP.DSL:Register('timeout', function(_, args)
	local name, time = strsplit(',', args, 2)
	time = tonumber(time)
	if time then
		if NeP.timeOut.check(name) then return false end
		NeP.timeOut.set(name, time)
		return true
	end
end)

local waitTable = {}
NeP.DSL:Register('waitfor', function(_, args)
	local name, time = strsplit(',', args, 2)
	if time then
		time = tonumber(time)
		local currentTime = GetTime() % 60
		if waitTable[name] then
			if waitTable[name] + time < currentTime then
				waitTable[name] = nil
				return true
			end
		else
			waitTable[name] = currentTime
		end
	end
end)

NeP.DSL:Register('IsNear', function(target, args)
	local targetID, distance = strsplit(',', args, 2)
	targetID = tonumber(targetID) or 0
	distance = tonumber(distance) or 60
	for _, Obj in pairs(NeP.OM:Get('Enemy')) do
		if Obj.id == targetID then
			return NeP.Protected.Distance('player', target) <= distance
		end
	end
end)

NeP.DSL:Register('equipped', function(_, item)
	return IsEquippedItem(item)
end)

NeP.DSL:Register('gcd', function()
	local class = select(3,UnitClass("player"))
	-- Some class's always have GCD = 1
	if class == 4 or (class == 11 and GetShapeshiftForm() == 2) or (class == 10 and GetSpecialization() ~= 2) then
		return 1
	end
	return math.floor((1.5 / ((GetHaste() / 100) + 1)) * 10^3 ) / 10^3
end)

NeP.DSL:Register('UI', function(_, args)
	local key, UI_key = strsplit(",", args, 2)
	UI_key = UI_key or NeP.CR.CR.Name
	return NeP.Config:Read(UI_key, key)
end)

NeP.DSL:Register('haste', function(unit)
	return UnitSpellHaste(unit)
end)

NeP.DSL:Register("talent", function(_, args)
	local row, col = strsplit(",", args, 2)
	row, col = tonumber(row), tonumber(col)
	local group = GetActiveSpecGroup()
	local _,_,_, selected, active = GetTalentInfo(row, col, group)
	return active and selected
end)

-------------------------------------UNITS--------------------------------------------
--------------------------------------------------------------------------------------

NeP.DSL:Register("ingroup", function(target)
	return UnitInParty(target) or UnitInRaid(target)
end)

NeP.DSL:Register("group.members", function()
	return (GetNumGroupMembers() or 0)
end)

local UnitClsf = {
	['elite'] = 2,
	['rareelite'] = 3,
	['rare'] = 4,
	['worldboss'] = 5
}

NeP.DSL:Register('boss', function (target)
	local classification = UnitClassification(target)
	if UnitClsf[classification] then
		return UnitClsf[classification] >= 3
	end
	return LibBoss.BossIDs[NeP.Core:UnitID(target)] ~= nil
end)

NeP.DSL:Register('elite', function (target)
	local classification = UnitClassification(target)
	if UnitClsf[classification] then
		return UnitClsf[classification] >= 2
	end
	return LibBoss.BossIDs[NeP.Core:UnitID(target)] ~= nil
end)

NeP.DSL:Register("id", function(target, id)
	local expectedID = tonumber(id)
	return expectedID and NeP.Core:UnitID(target) == expectedID
end)

NeP.DSL:Register("threat", function(target)
	if UnitThreatSituation("player", target) then
		return select(3, UnitDetailedThreatSituation("player", target))
	end
	return 0
end)

NeP.DSL:Register("aggro", function(target)
	return (UnitThreatSituation(target) and UnitThreatSituation(target) >= 2)
end)

NeP.DSL:Register("moving", function(target)
	local speed, _ = GetUnitSpeed(target)
	return speed ~= 0
end)

NeP.DSL:Register("classification", function (target, spell)
	if not spell then return false end
	local classification = UnitClassification(target)
	if string.find(spell, '[%s,]+') then
		for classificationExpected in string.gmatch(spell, '%a+') do
			if classification == string.lower(classificationExpected) then
			return true
			end
		end
		return false
	else
		return UnitClassification(target) == string.lower(spell)
	end
end)

NeP.DSL:Register("target", function(target, spell)
	return ( UnitGUID(target .. "target") == UnitGUID(spell) )
end)

NeP.DSL:Register("player", function(target)
	return UnitIsPlayer(target)
end)

NeP.DSL:Register("isself", function(target)
	return UnitIsUnit(target, 'player')
end)

NeP.DSL:Register("exists", function(target)
	return UnitExists(target)
end)

NeP.DSL:Register('dead', function (target)
	return UnitIsDeadOrGhost(target)
end)

NeP.DSL:Register("alive", function(target)
	return UnitExists(target) and not UnitIsDeadOrGhost(target)
end)

NeP.DSL:Register("behind", function(target)
	return not NeP.Protected.Infront('player', target)
end)

NeP.DSL:Register("infront", function(target)
	return NeP.Protected.Infront('player', target)
end)

local movingCache = {}

NeP.DSL:Register("lastmoved", function(target)
	if UnitExists(target) then
		local guid = UnitGUID(target)
		if movingCache[guid] then
			local moving = (GetUnitSpeed(target) > 0)
			if not movingCache[guid].moving and moving then
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = true
				return false
			elseif moving then
				return false
			elseif not moving then
				movingCache[guid].moving = false
				return GetTime() - movingCache[guid].last
			end
		else
			movingCache[guid] = { }
			movingCache[guid].last = GetTime()
			movingCache[guid].moving = (GetUnitSpeed(target) > 0)
			return false
		end
	end
	return false
end)

NeP.DSL:Register("movingfor", function(target)
	if UnitExists(target) then
		local guid = UnitGUID(target)
		if movingCache[guid] then
			local moving = (GetUnitSpeed(target) > 0)
			if not movingCache[guid].moving then
				movingCache[guid].last = GetTime()
				movingCache[guid].moving = (GetUnitSpeed(target) > 0)
				return false
			elseif moving then
				return GetTime() - movingCache[guid].last
			elseif not moving then
				movingCache[guid].moving = false
				return false
			end
		else
			movingCache[guid] = { }
			movingCache[guid].last = GetTime()
			movingCache[guid].moving = (GetUnitSpeed(target) > 0)
			return false
		end
	end
	return false
end)

NeP.DSL:Register("friend", function(target)
	return UnitExists(target) and not UnitCanAttack("player", target)
end)

NeP.DSL:Register("enemy", function(target)
	return UnitExists(target) and UnitCanAttack("player", target)
end)

NeP.DSL:Register("distance", function(target)
	return NeP.Protected.UnitCombatRange('player', target)
end)

NeP.DSL:Register("range", function(target)
	return NeP.DSL:Get("distance")(target)
end)

NeP.DSL:Register("level", function(target)
	return UnitLevel(target)
end)

NeP.DSL:Register("combat", function(target)
	return UnitAffectingCombat(target)
end)

NeP.DSL:Register("role", function(target, role)
	role = role:upper()
	local damageAliases = { "DAMAGE", "DPS", "DEEPS" }
	local targetRole = UnitGroupRolesAssigned(target)
	if targetRole == role then return true
	elseif role:find("HEAL") and targetRole == "HEALER" then
		return true
	else
		for i = 1, #damageAliases do
			if role == damageAliases[i] then
				return true
			end
		end
	end

	return false
end)

NeP.DSL:Register("name", function (target, expectedName)
	return UnitExists(target) and UnitName(target):lower():find(expectedName:lower()) ~= nil
end)

NeP.DSL:Register("creatureType", function (target, expectedType)
	return UnitCreatureType(target) == expectedType
end)

NeP.DSL:Register("class", function (target, expectedClass)
	local class, _, classID = UnitClass(target)
	if tonumber(expectedClass) then
		return tonumber(expectedClass) == classID
	else
		return expectedClass == class
	end
end)

NeP.DSL:Register("inMelee", function(target)
	return NeP.Protected.UnitCombatRange('player', target) <= 1.5
end)

NeP.DSL:Register("inRanged", function(target)
	return NeP.Protected.UnitCombatRange('player', target) <= 40
end)

NeP.DSL:Register("power.regen", function(target)
	return select(2, GetPowerRegen(target))
end)

NeP.DSL:Register("casttime", function(_, spell)
	return select(3, GetSpellInfo(spell))
end)

NeP.DSL:Register("incdmg", function(target, args)
	if args and UnitExists(target) then
		local pDMG = NeP.CombatTracker:getDMG(target)
		return pDMG * tonumber(args)
	end
	return 0
end)

NeP.DSL:Register("incdmg.phys", function(target, args)
	if args and UnitExists(target) then
		local pDMG = select(3, NeP.CombatTracker:getDMG(target))
		return pDMG * tonumber(args)
	end
	return 0
end)

NeP.DSL:Register("incdmg.magic", function(target, args)
	if args and UnitExists(target) then
		local mDMG = select(4, NeP.CombatTracker:getDMG(target))
		return mDMG * tonumber(args)
	end
	return 0
end)

NeP.DSL:Register("ilevel", function()
	return math.floor(select(1,GetAverageItemLevel()))
end)

NeP.DSL:Register('swimming', function ()
	return IsSwimming()
end)

NeP.DSL:Register("lastcast", function(Unit, Spell)
	Spell = NeP.Spells:Convert(Spell)
	if UnitIsUnit('player', Unit) then
		local LastCast = NeP.Parser.LastCast
		return LastCast == Spell, LastCast
	end
	local LastCast = NeP.CombatTracker:LastCast(Unit)
	return LastCast == Spell, LastCast
end)

NeP.DSL:Register("lastgcd", function(Unit, Spell)
	Spell = NeP.Spells:Convert(Spell)
	if UnitIsUnit('player', Unit) then
		local LastCast = NeP.Parser.LastGCD
		return LastCast == Spell, LastCast
	end
	local LastCast = NeP.CombatTracker:LastCast(Unit)
	return LastCast == Spell, LastCast
end)

NeP.DSL:Register("mounted", function()
	return IsMounted()
end)

NeP.DSL:Register("enchant.mainhand", function()
	return (select(1, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL:Register("enchant.offhand", function()
	return (select(4, GetWeaponEnchantInfo()) == 1)
end)

NeP.DSL:Register("falling", function()
	return IsFalling()
end)

NeP.DSL:Register("deathin", function(target)
	return NeP.CombatTracker:TimeToDie(target)
end)

NeP.DSL:Register("ttd", function(target)
	return NeP.DSL:Get("deathin")(target)
end)

NeP.DSL:Register("charmed", function(target)
	return UnitIsCharmed(target)
end)

NeP.DSL:Register("glyph", function(_,spell)
	local spellId = tonumber(spell)
	local glyphName, glyphId
	for i = 1, 6 do
		glyphId = select(4, GetGlyphSocketInfo(i))
		if glyphId then
			if spellId then
				if select(4, GetGlyphSocketInfo(i)) == spellId then
					return true
				end
			else
				glyphName = NeP.Core:GetSpellName(glyphId)
				if glyphName:find(spell) then
					return true
				end
			end
		end
	end
	return false
end)

NeP.DSL:Register('twohand', function()
	return IsEquippedItemType("Two-Hand")
end)

NeP.DSL:Register('onehand', function()
	return IsEquippedItemType("One-Hand")
end)

local communName = NeP.Locale:TA('Dummies', 'Name')
local matchs = NeP.Locale:TA('Dummies', 'Pattern')
NeP.DSL:Register('isdummy', function(unit)
	if not UnitExists(unit) then return end
	if UnitName(unit):lower():find(communName) then return true end
	return NeP.Tooltip:Unit(unit, matchs)
end)

-- USAGE: UNIT.aoe(DISTANCE).enemies >= #
NeP.DSL:Register("area.enemies", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for _, Obj in pairs(NeP.OM:Get('Enemy')) do
		if UnitExists(Obj.key) then
			local unit_dist = NeP.Protected.Distance(unit, Obj.key)
			if (NeP.DSL:Get('combat')(Obj.key) or Obj.isdummy)
			and unit_dist <= tonumber(distance) then
				total = total +1
			end
		end
	end
	return total
end)

-- USAGE: UNIT.aoe(DISTANCE).enemies.infront >= #
NeP.DSL:Register("area.enemies.infront", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for _, Obj in pairs(NeP.OM:Get('Enemy')) do
		if UnitExists(Obj.key) then
			local unit_dist = NeP.Protected.Distance(unit, Obj.key)
			if (NeP.DSL:Get('combat')(Obj.key) or Obj.isdummy)
			and unit_dist <= tonumber(distance)
			and NeP.Protected.Infront(unit, Obj.key) then
				total = total +1
			end
		end
	end
	return total
end)

-- USAGE: UNIT.aoe(DISTANCE).friendly >= #
NeP.DSL:Register("area.friendly", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for _, Obj in pairs(NeP.OM:Get('Friendly')) do
		if UnitExists(Obj.key) then
			local unit_dist = NeP.Protected.Distance(unit, Obj.key)
			if unit_dist <= tonumber(distance) then
				total = total +1
			end
		end
	end
	return total
end)

-- USAGE: UNIT.aoe(DISTANCE).friendly >= #
NeP.DSL:Register("area.friendly.infront", function(unit, distance)
	local total = 0
	if not UnitExists(unit) then return total end
	for _, Obj in pairs(NeP.OM:Get('Friendly')) do
		if UnitExists(Obj.key) then
			local unit_dist = NeP.Protected.Distance(unit, Obj.key)
			if unit_dist <= tonumber(distance)
			and NeP.Protected.Infront(unit, Obj.key) then
				total = total +1
			end
		end
	end
	return total
end)

------------------------------------------ BUFFS/FUNCs -----------------------------------
------------------------------------------------------------------------------------------

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

local function UnitBuff(target, spell, owner)
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

local function UnitDebuff(target, spell, owner)
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

--------------------------------------------SHARED CLASS------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('energy', function(target)
	return UnitPower(target, UnitPowerType(target))
end)

-- Returns the amount of energy you have left till max (e.g. you have a max of 100 energy and 80 energy now, so it will return 20)
NeP.DSL:Register('energydiff', function(target)
	local max = UnitPowerMax(target, UnitPowerType(target))
	local curr = UnitPower(target, UnitPowerType(target))
	return (max - curr)
end)

NeP.DSL:Register('mana', function(target)
	if UnitExists(target) then
		return math.floor((UnitMana(target) / UnitManaMax(target)) * 100)
	end
	return 0
end)

--------------------------------------------------- PRIEST ---------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('insanity', function(target)
	return UnitPower(target, SPELL_POWER_INSANITY)
end)

--------------------------------------------------- HUNTER ---------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('petrange', function(target)
	return target and NeP.Protected.Distance('pet', target) or 0
end)

NeP.DSL:Register('focus', function(target)
	return UnitPower(target, SPELL_POWER_FOCUS)
end)

--------------------------------------------------- DEATHKNIGH -----------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('runicpower', function(target)
	return UnitPower(target, SPELL_POWER_RUNIC_POWER)
end)

NeP.DSL:Register('runes', function()
	local count = 0
	local next = 0
	for i = 1, 6 do
		local _, duration, runeReady = GetRuneCooldown(i)
		if runeReady then
			count = count + 1
		elseif duration > next then
			next = duration
		end
	end
	if next > 0 then count = count + (next / 10) end
	return count
end)

--------------------------------------------------- SHAMMMAN -------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('maelstrom', function(target)
    return UnitPower(target, SPELL_POWER_MAELSTROM)
end)

NeP.DSL:Register('totem', function(_, totem)
	for index = 1, 4 do
		local totemName = select(2, GetTotemInfo(index))
		if totemName == NeP.Core:GetSpellName(totem) then
			return true
		end
	end
	return false
end)

NeP.DSL:Register('totem.duration', function(_, totem)
	for index = 1, 4 do
		local _, totemName, startTime, duration = GetTotemInfo(index)
		if totemName == NeP.Core:GetSpellName(totem) then
			return floor(startTime + duration - GetTime())
		end
	end
	return 0
end)

NeP.DSL:Register('totem.time', function(_, totem)
	for index = 1, 4 do
		local _, totemName, _, duration = GetTotemInfo(index)
		if totemName == NeP.Core:GetSpellName(totem) then
			return duration
		end
	end
	return 0
end)

--------------------------------------------------- WARLOCK --------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('soulshards', function(target)
	return UnitPower(target, SPELL_POWER_SOUL_SHARDS)
end)

--------------------------------------------------- MONK -----------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('chi', function(target)
	return UnitPower(target, SPELL_POWER_CHI)
end)

-- Returns the number of chi you have left till max (e.g. you have a max of 5 chi and 3 chi now, so it will return 2)
NeP.DSL:Register('chidiff', function(target)
    local max = UnitPowerMax(target, SPELL_POWER_CHI)
    local curr = UnitPower(target, SPELL_POWER_CHI)
    return (max - curr)
end)

--------------------------------------------------- DRUID ----------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('form', function()
	return GetShapeshiftForm()
end)

NeP.DSL:Register('lunarpower', function(target)
    return UnitPower(target, SPELL_POWER_LUNAR_POWER)
end)

NeP.DSL:Register('mushrooms', function()
	local count = 0
	for slot = 1, 3 do
	if GetTotemInfo(slot) then
		count = count + 1 end
	end
	return count
end)

--------------------------------------------------- PALADIN --------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('holypower', function(target)
	return UnitPower(target, SPELL_POWER_HOLY_POWER)
end)

--------------------------------------------------- WARRIOR --------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('rage', function(target)
	return UnitPower(target, SPELL_POWER_RAGE)
end)

NeP.DSL:Register('stance', function()
	return GetShapeshiftForm()
end)

--------------------------------------------------- DEMONHUNTER ----------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('fury', function(target)
	return UnitPower(target, SPELL_POWER_FURY)
end)
-- Returns the number of fury you have left till max (e.g. you have a max of 100 fury and 80 fury now, so it will return 20)
NeP.DSL:Register('furydiff', function(target)
	local max = UnitPowerMax(target, SPELL_POWER_FURY)
	local curr = UnitPower(target, SPELL_POWER_FURY)
	return (max - curr)
end)

NeP.DSL:Register('pain', function(target)
	return UnitPower(target, SPELL_POWER_PAIN)
end)

--------------------------------------------------- MAGE -----------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('arcanecharges', function(target)
	return UnitPower(target, SPELL_POWER_ARCANE_CHARGES)
end)

--------------------------------------------------- ROGUE ----------------------------------------------------
--------------------------------------------------------------------------------------------------------------

NeP.DSL:Register('combopoints', function(target)
	return UnitPower(target, SPELL_POWER_COMBO_POINTS)
end)
