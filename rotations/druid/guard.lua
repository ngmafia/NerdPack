local GUI = {
	{type = 'header', text = 'Keybinds:'},
	{type = 'text', text = 'Alt: Pause'},
}

local function ExeOnLoad()
	NeP.Interface:AddToggle({
		key = 'taunt',
		name = 'Taunt Units',
		text = 'Enable to taunt units you dont have aggro from.',
		icon = 'Interface\\Icons\\Ability_warrior_charge',
	})
end

local Keybinds = {
	{'%pause', 'keybind(alt)'},
}

local Cooldowns = {
	--Frenzied Regeneration for a potent self heal.
	{'Frenzied Regeneration', 'player.health <= 60'},
	--Barkskin Use proactively to reduce incoming damage.
	{'Barkskin', 'incdmg(5) > player.health.max'},
	--Survival Instincts Use proactively to reduce incoming damage.
	{'Survival Instincts', 'incdmg(5) > player.health.max'},
	--Ironfur to mitigate physical damage.
	{'Ironfur', 'incdmg(5).phys > player.health.max'},
	--Mark of Ursol to mitigate magic damage.
	{'Mark of Ursol', 'incdmg(5).magic > player.health.max'},
	--Bristling Fur Use as often as possible for additional Rage (if selected). Try not to stack with Survival Instincts.
	{'Bristling Fur', 'player.rage <= 70 & !player.buff(Survival Instincts)'},
	--Incarnation: Guardian of Ursoc Use on cooldown for additional damage (if selected).
	{'Incarnation: Guardian of Ursoc', 'target.ttd > 30'}
}

local ST = {
	--Moonfire with a Galactic Guardian proc (if selected).
	{'Moonfire', 'player.buff(Galactic Guardian)', 'target'},
	--Mangle whenever available to generate Rage. Watch for Gore procs.
	{'Mangle', nil, 'target'},
	--Thrash on cooldown.
	{'Trash', nil, 'target'},
	--Moonfire to maintain the DoT. (FIXME: need auto dots)
	{'Moonfire', '!target.debuff', 'target'},
	--Maul to dump excess Rage.
	{'Maul', 'player.rage >= 60', 'target'},
	--Swipe as a filler ability.
	{'Swipe', nil, 'target'},
}

local InCombat = {
	{Keybinds},
	{Cooldowns, 'toggle(cooldowns)'},
	--Growl Use to establish threat on targets not attacking you.
	{'%taunt(Growl)', 'toggle(taunt)'},
	{ST, 'target.inmelee'}
}

local OutCombat = {
	{Keybinds},
}

NeP.CR:Add(104, {
  name = '[NeP] Druid - Guardian',
  ic = InCombat,
  ooc = OutCombat,
	gui = GUI,
	load = ExeOnLoad
})
