local Keybinds = {
	{'%pause', 'keybind(alt)'},
}

local InCombat = {
	{Keybinds},
}

local OutCombat = {
	{Keybinds},
}

NeP.CR:Add(105, {
  name = '[NeP] Druid - Restoration',
  ic = InCombat,
  ooc = OutCombat,
})
