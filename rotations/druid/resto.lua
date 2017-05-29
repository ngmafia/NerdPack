local Keybinds = {
	{'%pause', 'keybind(alt)'},
}

local incombat = {
	{Keybinds},
}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(105, {
  name = '[NeP] Druid - Restoration',
  ic = incombat,
  ooc = outcombat,
})
