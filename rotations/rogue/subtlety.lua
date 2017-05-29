local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(261, {
  name = '[NeP] Rogue - Subtlely',
  ic = InCombat,
  ooc = OutCombat,
})
