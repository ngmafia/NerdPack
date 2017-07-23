local _, NeP 					= ...
NeP.Helpers 					= {}
local UnitGUID 				= UnitGUID
local UIErrorsFrame 	= UIErrorsFrame
local C_Timer 				= C_Timer

-- A full list can be found at:
-- https://pastebin.com/auAsSL5W
local ERR_SPELL_FAILED_S = LE_GAME_ERR_SPELL_FAILED_S
local ERR_SPELL_OUT_OF_RANGE = LE_GAME_ERR_SPELL_OUT_OF_RANGE
local ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS = LE_GAME_ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS
local ERR_SPELL_COOLDOWN = LE_GAME_ERR_SPELL_COOLDOWN
local ERR_ABILITY_COOLDOWN = LE_GAME_ERR_ABILITY_COOLDOWN
local ERR_CANT_USE_ITEM = LE_GAME_ERR_CANT_USE_ITEM
local ERR_ITEM_COOLDOWN = LE_GAME_ERR_ITEM_COOLDOWN
local ERR_BADATTACKFACING = LE_GAME_ERR_BADATTACKFACING
local ERR_NOT_WHILE_MOVING = LE_GAME_ERR_NOT_WHILE_MOVING

local _Failed = {}
UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")

local function addToData(GUID)
	if not _Failed[GUID] then
		_Failed[GUID] = {}
	end
end

local function blackListSpell(GUID, spell)
	_Failed[GUID][spell] =  true
	C_Timer.After(0.1, (function()
		_Failed[GUID][spell] =  nil
	end), nil)
end

local function blackListInfront(GUID)
	_Failed[GUID].infront = true
	C_Timer.After(0.1, (function()
		_Failed[GUID].infront = nil
	end), nil)
end

local UI_Erros = {
	[ERR_SPELL_FAILED_S] = function(GUID, spell)
		blackListSpell(GUID, spell)
		blackListInfront(GUID)
	end,
	[ERR_BADATTACKFACING] = function(GUID, spell)
		blackListSpell(GUID, spell)
		blackListInfront(GUID)
	end,
	[ERR_SPELL_OUT_OF_RANGE] = function(GUID, spell) blackListSpell(GUID, spell) end,
	[ERR_NOT_WHILE_MOVING] = function(GUID, spell) blackListSpell(GUID, spell) end,
	[ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS] = function(GUID, spell) blackListSpell(GUID, spell) end,
	[ERR_SPELL_COOLDOWN] = function(GUID, spell) blackListSpell(GUID, spell) end,
	[ERR_ABILITY_COOLDOWN] = function(GUID, spell) blackListSpell(GUID, spell) end,
	[ERR_CANT_USE_ITEM] = function(GUID, spell) blackListSpell(GUID, spell) end,
	[ERR_ITEM_COOLDOWN] = function(GUID, spell) blackListSpell(GUID, spell) end,
}

function NeP.Helpers.Infront(_, target, GUID)
	GUID = GUID or UnitGUID(target)
	if _Failed[GUID] then
		 return not _Failed[GUID].infront
	end
	return true
end

function NeP.Helpers.Spell(_, spell, target, GUID)
	GUID = GUID or UnitGUID(target)
	if _Failed[GUID] then
		 return not _Failed[GUID][spell]
	end
	return true
end

function NeP.Helpers:Check(spell, target)

	-- Both MUST be strings
	if type(spell) ~= 'string'
	or type(target) ~= 'string' then
		return true
	end

	local GUID = UnitGUID(target)
	if _Failed[GUID] then
		return self:Spell(spell, target, GUID) and self:Infront(target, GUID)
	end

	return true
end

NeP.Listener:Add("NeP_Helpers", "UI_ERROR_MESSAGE", function(error)
	if not UI_Erros[error] then return end

	local unit, spell = NeP.Parser.LastTarget, NeP.Parser.LastCast
	if not unit or not spell then return end

	local GUID = UnitGUID(unit)
	if GUID then
		addToData(GUID)
		UI_Erros[error](GUID, spell)
	end
end)
