local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(263, {
  name = '[NeP] Shaman - Enhancement',
  ic = InCombat,
  ooc = OutCombat,
})
