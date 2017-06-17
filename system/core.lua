local _, NeP     = ...
NeP.Core         = {}
NeP.Globals.Core = NeP.Core

-- Locals for speed
local UnitExists           = ObjectExists or UnitExists
local UnitClass            = UnitClass
local GetSpellInfo         = GetSpellInfo
local GetItemInfo          = GetItemInfo
local UnitGUID             = UnitGUID
local strsplit             = strsplit
local GetSpellTabInfo      = GetSpellTabInfo
local GetSpellBookItemName = GetSpellBookItemName
local GetFlyoutInfo        = GetFlyoutInfo
local GetNumFlyouts        = GetNumFlyouts
local GetFlyoutID          = GetFlyoutID
local GetFlyoutSlotInfo    = GetFlyoutSlotInfo
local HasPetSpells         = HasPetSpells
local BOOKTYPE_SPELL       = BOOKTYPE_SPELL
local BOOKTYPE_PET         = BOOKTYPE_PET

function NeP.Core.Print(_, ...)
	print('[|cff'..NeP.Color..'NeP|r]', ...)
end

local d_color = {
	hex = 'FFFFFF',
	rgb = {1,1,1}
}

function NeP.Core.ClassColor(_, unit, type)
	type = type and type:lower() or 'hex'
	if UnitExists(unit) then
		local classid  = select(3, UnitClass(unit))
		if classid then
			return NeP.ClassTable[classid][type]
		end
	end
	return d_color[type]
end

function NeP.Core.Round(_, num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function NeP.Core.GetSpellID(_, spell)
	local _type = type(spell)
	if not spell then
		return
	elseif _type == 'string' and spell:find('^%d') then
		return tonumber(spell)
	end
	local index, stype = NeP.Core:GetSpellBookIndex(spell)
	local spellID = select(7, GetSpellInfo(index, stype))
	return spellID or spell
end

function NeP.Core.GetSpellName(_, spell)
	if not spell or type(spell) == 'string' then return spell end
	local spellID = tonumber(spell)
	if spellID then
		return GetSpellInfo(spellID)
	end
	return spell
end

function NeP.Core.GetItemID(_, item)
	if not item or type(item) == 'number' then return item end
	local itemID = string.match(select(2, GetItemInfo(item)) or '', 'Hitem:(%d+):')
	return tonumber(itemID) or item
end

function NeP.Core.UnitID(_, unit)
	if unit and UnitExists(unit) then
		local guid = UnitGUID(unit)
		if guid then
			local type, _, server_id,_,_, npc_id = strsplit("-", guid)
			if type == "Player" then
				return tonumber(server_id)
			elseif npc_id then
				return tonumber(npc_id)
			end
		end
	end
end

function NeP.Core.GetSpellBookIndex(_, spell)
	local spellName = NeP.Core:GetSpellName(spell)
	if not spellName then return end
	spellName = spellName:lower()

	for t = 1, 2 do
		local _, _, offset, numSpells = GetSpellTabInfo(t)
		for i = 1, (offset + numSpells) do
			if GetSpellBookItemName(i, BOOKTYPE_SPELL):lower() == spellName then
				return i, BOOKTYPE_SPELL
			end
		end
	end

	local numFlyouts = GetNumFlyouts()
	for f = 1, numFlyouts do
		local flyoutID = GetFlyoutID(f)
		local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutID)
		if isKnown and numSlots > 0 then
			for g = 1, numSlots do
				local spellID, _, isKnownSpell = GetFlyoutSlotInfo(flyoutID, g)
				local name = NeP.Core:GetSpellName(spellID)
				if name and isKnownSpell and name:lower() == spellName then
					return spellID, nil
				end
			end
		end
	end

	local numPetSpells = HasPetSpells()
	if numPetSpells then
		for i = 1, numPetSpells do
			if string.lower(GetSpellBookItemName(i, BOOKTYPE_PET)) == spellName then
				return i, BOOKTYPE_PET
			end
		end
	end
end

local Run_Cache = {}
function NeP.Core.WhenInGame(_, func, prio)
	if Run_Cache then
		local size = #Run_Cache+1
		Run_Cache[size] = {func = func, prio = (prio or 0) + size}
		table.sort(Run_Cache, function(a,b) return a.prio < b.prio end)
	else
		func()
	end
end

NeP.Listener:Add("NeP_CR2", "PLAYER_LOGIN", function()
	NeP.Color = NeP.Core:ClassColor('player', 'hex')
	for i=1, #Run_Cache do
		Run_Cache[i].func()
	end
	Run_Cache = nil
end)
