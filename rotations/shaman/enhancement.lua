local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(263, {
  name = '[NeP] Shaman - Enhancement',
  ic = incombat,
  ooc = outcombat,
})
