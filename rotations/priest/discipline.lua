local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(256, {
  name = '[NeP] Priest - Discipline',
  ic = incombat,
  ooc = outcombat,
})
