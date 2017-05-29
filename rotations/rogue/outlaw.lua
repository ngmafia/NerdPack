local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(260, {
  name = '[NeP] Rogue - Outlaw',
  ic = incombat,
  ooc = outcombat,
})
