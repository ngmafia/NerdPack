local _, NeP       = ...
NeP.Spells         = {}
NeP.Globals.Spells = NeP.Spells
local SpellsTable  = {}
local GetSpellInfo = GetSpellInfo

function NeP.Spells:Add(...)
	if type(...) == 'table' then
		for name, id in pairs(...) do
			local native_spell = GetSpellInfo(id)
			if native_spell then
				SpellsTable[name:lower()] = native_spell
			end
		end
	else
		local name, id = ...
		local native_spell = GetSpellInfo(id)
		if native_spell then
			SpellsTable[name:lower()] = native_spell
		end
	end
end

function NeP.Spells:Convert(spell)
	if not spell then return end
	if type(spell) == 'number' or spell:find('%d') then
		spell = GetSpellInfo(spell) or spell
	else
		if SpellsTable[spell:lower()] then
			spell = SpellsTable[spell:lower()]
		end
	end
	return spell
end
