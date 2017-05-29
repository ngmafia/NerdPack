local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(72, {
  name = '[NeP] Warrior - Fury',
  ic = incombat,
  ooc = outcombat,
})
