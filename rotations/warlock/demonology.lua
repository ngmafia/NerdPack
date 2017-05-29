local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(266, {
  name = '[NeP] Warlock - Demonology',
  ic = incombat,
  ooc = outcombat,
})
