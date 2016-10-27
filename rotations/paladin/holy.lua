local GUI = {
	{type = 'header', text = 'Keybinds', align = 'center'},
	{type = 'text', text = 'Alt: PAUSE CR'},

	{type = 'ruler'},{type = 'spacer'},
	{type = 'header', text = 'General', align = 'center'},
	{type = 'spinner', text = 'PANIC! Lay on Hands', key = 'G_LoH', default = 25},
	{type = 'spinner', text = 'PANIC! Light of the Martyr', key = 'G_LotM', default = 30},

	{type = 'ruler'},{type = 'spacer'},
	{type = 'header', text = 'Tank', align = 'center'},

	{type = 'ruler'},{type = 'spacer'},
	{type = 'header', text = 'Player', align = 'center'},

	{type = 'ruler'},{type = 'spacer'},
	{type = 'header', text = 'Lowest', align = 'center'},
	{type = 'spinner', text = 'Holy Light (Health %)', key = 'L_HL', default = 100},
}

local exeOnLoad = function()
	NeP.Interface:AddToggle({
  		key = 'dps',
  		icon = 'Interface\\Icons\\Spell_shaman_stormearthfire.png‎',
  		name = 'DPS',
  		text = 'Do some damage while healing in party/raid.'
	})
end

local Keybinds = {
	{'%pause', 'keybind(alt)'}
}

local FastHeals = {
	{'!Lay on Hands', 'lowest.health < UI(G_LoH)', 'lowest'},
	-- Automated Dispels
	{'%dispelall'},
	{{--Consume Infusion of Light procs using the appropriate heal before your next Holy Shock
		{'Flash of Light', 'lowest.health < 60', 'lowest'},
		{'Holy Light', 'lowest.health < 100', 'lowest'}
	}, 'player.buff(Infusion of Light)' },
	--Holy Shock use on cooldown to generate Infusion of Light procs.
	{'Holy Shock', 'lowest.health < 100', 'lowest'},
	-- Bestow Faith
	{'Bestow Faith', 'lowest.health < 100', 'lowest'},
	--Light of the Martyr a potent emergency heal as long as you heave health to spare.
	{'!Light of the Martyr', {
		'player.health > 40',
		'lowest.health < UI(G_LotM)'
	}, 'lowest'},
}

local Tank = {
	--Beacon of Light maintain on your primary target at all times.
	{'Beacon of Light', '!tank.buff(Beacon of Light)', 'tank'},
	{'Beacon of Faith', '!tank2.buff(Beacon of Faith)', 'tank2'},
}

local Moving = {
	--Holy Shock use on cooldown to generate Infusion of Light procs.
	{'Holy Shock', 'lowest.health < 100', 'lowest'},
	-- Bestow Faith
	{'Bestow Faith', 'lowest.health < 100', 'lowest'},
}

local Lowest = {
	{'Light of Dawn', 'toggle(AoE) & HealInfront(80, 2, 15)'},
	--Flash of Light use as an emergency heal to save players facing death.
	{'Flash of Light', 'lowest.health < 50', 'lowest'},
	--Holy Light use to heal moderate to high damage.
	{'Holy Light', 'lowest.health < UI(L_HL)', 'lowest'}
}

local DPS = {
	{'Judgment', nil, 'target'},
	{'Holy Shock', nil, 'target'},
	{'Crusader Strike', nil, 'target'}
}

local inCombat = {
	{Keybinds},
	{DPS, 'toggle(dps) & !lowest.health < 70 & target.enemy'},
	{Moving, 'player.moving'},
	{{ -- Not moving
		{FastHeals},
		{Tank},
		{Lowest, 'lowest.health < 100'}
	}, '!player.moving' }
}

local outCombat = {
	{Keybinds},
	{Moving},
	{{ -- Not moving
		{'Holy Light', 'lowest.health < 100', 'lowest'}
	}, '!player.moving' },
}

NeP.CR:Add(65, '[NeP] Paladin - Holy', inCombat, outCombat, exeOnLoad, GUI)
