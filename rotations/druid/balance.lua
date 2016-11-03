local Keybinds = {
	{'%pause', 'keybind(alt)'},
}

local InCombat = {
	{Keybinds},
}

local OutCombat = {
	{Keybinds},
}

NeP.CR:Add(102, {
  name = '[NeP] Druid - Balance',
  ic = InCombat,
  ooc = OutCombat,
})
