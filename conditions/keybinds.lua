local _, NeP = ...

-- Locals to increase performance
local IsShiftKeyDown          = IsShiftKeyDown
local IsLeftShiftKeyDown      = IsLeftShiftKeyDown
local IsRightShiftKeyDown     = IsRightShiftKeyDown
local IsControlKeyDown        = IsControlKeyDown
local IsLeftControlKeyDown    = IsLeftControlKeyDown
local IsRightControlKeyDown   = IsRightControlKeyDown
local IsAltKeyDown            = IsAltKeyDown
local IsLeftAltKeyDown        = IsLeftAltKeyDown
local IsRightAltKeyDown       = IsRightAltKeyDown
local IsMouseButtonDown       = IsMouseButtonDown
local GetCurrentKeyBoardFocus = GetCurrentKeyBoardFocus

local KEYBINDS = {
	-- Shift
	['shift']    = function() return IsShiftKeyDown() end,
	['lshift']   = function() return IsLeftShiftKeyDown() end,
	['rshift']   = function() return IsRightShiftKeyDown() end,
	-- Control
	['control']  = function() return IsControlKeyDown() end,
	['lcontrol'] = function() return IsLeftControlKeyDown() end,
	['rcontrol'] = function() return IsRightControlKeyDown() end,
	-- Alt
	['alt']      = function() return IsAltKeyDown() end,
	['lalt']     = function() return IsLeftAltKeyDown() end,
	['ralt']     = function() return IsRightAltKeyDown() end,
}

NeP.DSL:Register("keybind", function(_, Arg)
	Arg = Arg:lower()
	return KEYBINDS[Arg] and KEYBINDS[Arg]() and not GetCurrentKeyBoardFocus()
end)

NeP.DSL:Register("mouse", function(_, Arg)
	Arg = tonumber(Arg:lower())
	return KEYBINDS[Arg] and IsMouseButtonDown(Arg) and not GetCurrentKeyBoardFocus()
end)
