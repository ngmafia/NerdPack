local Keybinds = {
	{'Charge', 'keybind(shift) & target.range >= 8 & target.range <= 25', 'target'}
}

local incombat = {
	{Keybinds},
	{'Victory Rush'},
	{'Execute', 'target.health <= 20'},
	{'Slam'}
}

local outcombat = {
	{Keybinds}
}

NeP.CR:Add(1, {
  name = '[NeP] Warrior - Basic',
  ic = incombat,
  ooc = outcombat
})
