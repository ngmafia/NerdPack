local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(266, {
  name = '[NeP] Warlock - Demonology',
  ic = InCombat,
  ooc = OutCombat,
})
