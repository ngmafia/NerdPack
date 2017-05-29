local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(267, {
  name = '[NeP] Warlock - Destro',
  ic = InCombat,
  ooc = OutCombat,
})
