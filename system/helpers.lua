local _, NeP 					= ...
NeP.Helpers 					= {}
local spellHasFailed 	= {}
local UnitGUID 				= UnitGUID
local UIErrorsFrame 	= UIErrorsFrame
local wipe 						= wipe
local C_Timer 				= C_Timer

local function addToData(GUID)
	if not spellHasFailed[GUID] then
		spellHasFailed[GUID] = {}
	end
end

local UI_Erros = {
	-- infront / LoS
	[50] = function(GUID)
		addToData(GUID)
		spellHasFailed[GUID][spell] = ''
		spellHasFailed[GUID].infront = false
	end,
	-- SPELL_FAILED_OUT_OF_RANGE
	[359] = function(GUID, spell)
		addToData(GUID)
		spellHasFailed[GUID][spell] = ''
	end,
	-- Cant while moving
	[220] = function(GUID, spell)
		addToData(GUID)
		spellHasFailed[GUID][spell] = ''
	end
	--[[ Item not ready FIX:ME wrong ID
	[50] = function(GUID, spell)
		addToData(GUID)
		spellHasFailed[GUID][spell] = ''
	end]]
}

function NeP.Helpers:Infront(target)
	if not target then return end
	local GUID = UnitGUID(target)
	return GUID and spellHasFailed[GUID] and spellHasFailed[GUID].infront or true
end

function NeP.Helpers:Check(spell, target)
	if not target or not spell then return true end
	local GUID = UnitGUID(target)
	return GUID and spellHasFailed[GUID] and spellHasFailed[GUID][spell] == nil or true
end

NeP.Listener:Add("NeP_Helpers", "UI_ERROR_MESSAGE", function(error)
	if not UI_Erros[error] then return end
	local unit, spell = NeP.Parser.LastTarget, NeP.Parser.LastCast
	if not unit or not spell then return end
	local GUID = UnitGUID(unit)
	if not GUID then return end
	UI_Erros[error](GUID, spell)
	UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
end)

C_Timer.NewTicker(1, (function()
	wipe(spellHasFailed)
end), nil)
