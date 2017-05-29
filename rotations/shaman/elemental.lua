local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local incombat = {

}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(262, {
  name = '[NeP] Shaman - Elemental',
  ic = incombat,
  ooc = outcombat,
})
