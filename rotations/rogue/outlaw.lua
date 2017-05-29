local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
}

local inCombat = {

}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(260, {
  name = '[NeP] Rogue - Outlaw',
  ic = InCombat,
  ooc = OutCombat,
})
