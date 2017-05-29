local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(264, {
  name = '[NeP] Shaman - Restoration',
  ic = InCombat,
  ooc = OutCombat,
})
