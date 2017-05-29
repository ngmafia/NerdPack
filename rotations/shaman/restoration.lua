local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(264, {
  name = '[NeP] Shaman - Restoration',
  ic = incombat,
  ooc = outcombat,
})
