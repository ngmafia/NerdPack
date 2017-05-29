local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(259, {
  name = '[NeP] Rogue - Assassination',
  ic = incombat,
  ooc = outcombat,
})
