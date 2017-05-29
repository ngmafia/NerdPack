local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(71, {
  name = '[NeP] Warrior - Arms',
  ic = incombat,
  ooc = outcombat,
})
