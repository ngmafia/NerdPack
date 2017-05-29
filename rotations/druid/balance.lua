local Keybinds = {
	{'%pause', 'keybind(alt)'},
}

local incombat = {
	{Keybinds},
}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(102, {
  name = '[NeP] Druid - Balance',
  ic = incombat,
  ooc = outcombat,
})
