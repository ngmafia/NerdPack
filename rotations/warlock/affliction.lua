local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(265, {
  name = '[NeP] Warlock - Affliction',
  ic = InCombat,
  ooc = OutCombat,
})
