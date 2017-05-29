local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(71, {
  name = '[NeP] Warrior - Arms',
  ic = InCombat,
  ooc = OutCombat,
})
