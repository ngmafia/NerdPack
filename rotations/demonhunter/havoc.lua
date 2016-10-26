local GUI = {
	{type = 'header', text = 'Keybinds:'},
	{type = 'text', text = 'Alt: Pause\nControl: Hold to Vengeful Retreat and Fel Rush'},
}

local Jump = {
	{'Vengeful Retreat'},
	{'Fel Rush'}
}

local Keybinds = {
	{'%pause', 'keybind(alt)'},
	{Jump, 'keybind(control)'}
}

local AoE = {
	--Eye Beam.
	{'EyE Beam'},
	--Blade Dance.
	{'Blade Dance'}
}

local ST = {
	--Chaos Strike or Annihilation when Fury >= 70.
	{'Chaos Strike', 'player.fury >= 70', 'target'},
	{'Annihilation', 'player.fury >= 70', 'target'},
	--Demon's Bite to generate Fury if Demon Blades is not selected.
	{'Demon\'s Bite'}
}

local inCombat = {
	{Keybinds},
	{'Metamorphosis', 'toggle(cooldowns)'},
	{AoE, 'player.area(8).enemies >= 3'},
	{ST, 'target.inmelee'},
}

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(577, '[NeP] Demon Hunter - Havoc', inCombat, outCombat, nil, GUI)
