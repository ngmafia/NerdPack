local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(72, {
  name = '[NeP] Warrior - Fury',
  ic = InCombat,
  ooc = OutCombat,
})
