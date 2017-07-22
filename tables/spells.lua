local _, NeP       = ...
NeP.Spells         = {}
NeP.Globals.Spells = NeP.Spells
local SpellsTable  = {}
local GetSpellInfo = GetSpellInfo

local function _add(...)
	local name, id = ...
	local native_spell = GetSpellInfo(id)
	if native_spell then
		SpellsTable[name:lower()] = native_spell
	end
end

function NeP.Spells.Add(_, ...)
	if type(...) == 'table' then
		for name, id in pairs(...) do
			_add(name, id)
		end
	else
		_add(...)
	end
end

function NeP.Spells.Convert(_, spell)
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
