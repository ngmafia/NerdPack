local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(261, {
  name = '[NeP] Rogue - Subtlely',
  ic = incombat,
  ooc = outcombat,
})
