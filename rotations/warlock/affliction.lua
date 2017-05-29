local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(265, {
  name = '[NeP] Warlock - Affliction',
  ic = incombat,
  ooc = outcombat,
})
