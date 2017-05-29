local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(267, {
  name = '[NeP] Warlock - Destro',
  ic = incombat,
  ooc = outcombat,
})
