local gui = {
	{type = 'header', text = 'Keybinds:'},
	{type = 'text', text = 'Alt: Pause'},
}

local Keybinds = {
	{'%pause', 'keybind(alt)'},
}

local Cooldowns = {
	--Berserk Use on cooldown and right after Tiger's Fury when possible.
	{'Berserk', 'lastcast(Tiger\'s Fury)'},
	--Tiger's Fury Use on every cooldown, but spend any Energy above 35 first. Try to refresh your Bleeds while Tiger's Fury is active.
	{'Tiger\'s Fury', 'player.energy <= 35'},
	--Incarnation: King of the Jungle Use on every cooldown for additional damage (if selected).
	{'Incarnation: King of the Jungle'},
	--Elune's guidance Use at 0 CP and follow with a 5 CP Finishing Move (if selected).
	{'Elune\'s guidance', 'player.combopoints = 0'}
}

local Combo = {
	--Ferocious Bite to refresh Rip when target at <= 25% health.
	{'Ferocious Bite', 'target.health <= 25 & target.debuff(Rip).duration <= 7', 'target'},
	--Savage Roar with 5 CP (if selected).
	{'Savage Roar'},
	--Rip to maintain DoT with 5 CP when target at > 25% health.
	{'Rip', 'target.debuff.duration <= 7'},
	--Ferocious Bite with 5 CP to dump excess CP.
	{'Ferocious Bite', nil, 'target'}
}

local AoE = {
	--Thrash to maintain the DoT.
	{'Thrash', '!target.debuff', 'target'},
	--Rake to maintain the DoT on as many targets as possible.(FIXME: need auto dots)
	{'Rake', '!target.debuff', 'target'},
	--Rip to maintain the DoT on as many targets as possible. (FIXME: need auto dots)
	{'Rip', '!target.debuff', 'target'},
	--Brutal Slash when available (if selected).
	{'Brutal Slash', nil, 'target'},
	--Swipe to build CP with 9+ targets.
	{'Swipe', 'target.area(8).enemies.infront >= 9', 'target'}
}

local ST = {
	{Combo, 'player.combopoints >= 5'},
	--Rake to maintain the DoT at all times.
	{'Rake', '!target.debuff', 'target'},
	--Moonfire to maintain the DoT at all times if Lunar Inspiration is selected.
	{'Moonfire', 'talent(1,3) & !target.debuff', 'target'},
	--Shred to build CP.
	{'Shred', nil, 'target'}
}

local incombat = {
	{Keybinds},
	{Cooldowns, 'toggle(cooldowns)'},
	{AoE, 'target.area(8).enemies >= 3'},
	{ST, 'target.inmelee'}
}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(103, {
  name = '[NeP] Druid - Feral',
  ic = incombat,
  ooc = outcombat,
	gui = gui
})
