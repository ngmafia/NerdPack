local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(262, {
  name = '[NeP] Shaman - Elemental',
  ic = InCombat,
  ooc = OutCombat,
})
