local gui = {
	{type = 'header', text = 'Keybinds:'},
	{type = 'text', text = 'Alt: Pause\nControl: Death and Decay'},
	{type = 'spacer'},{type = 'ruler'},
	{type = 'checkbox', text = 'Automated Death and Decay', key = 'aDnD', default = false}
}

local function exeload()
	NeP.Interface:AddToggle({
		key = 'taunt',
		name = 'Taunt Units',
		text = 'Enable to taunt units you dont have aggro from.',
		icon = 'Interface\\Icons\\Ability_warrior_charge',
	})
end

local Taunts = {
	--Dark Command Use to establish threat on targets not attacking you.
	{'%taunt(Dark Command)'},
	--Death Grip Use as a secondary taunt on adds and to bring them to you.
	{'%taunt(Death Grip)'},
}

local Keybinds = {
	-- Pause
	{'%pause', 'keybind(alt)'},
	{'Death and Decay', 'keybind(shift)', 'cursor.ground'}
}

local Cooldowns = {
	--Anti-Magic Shell Carefully time to absorb magic damage or prevent debuffs.
	{'Dancing Rune Weapon', 'incdmg(5).magic > player.health.max'},
	--Dancing Rune Weapon Use before taking a high number of melee attacks.
	{'Dancing Rune Weapon', 'incdmg(5).phys > player.health.max'},
	--Vampiric Blood Use when high damage is received or expected.
	{'Vampiric Blood', 'incdmg(5) > player.health.max'}
}

local ST = {
	--Blood Boil to maintain Blood Plague.
	{'Blood Boil', '!player.buff', 'target'},
	--Death and Decay whenever available. Watch for Crimson Scourge procs.
	{'Death and Decay', 'UI(aDnD)', 'target.ground'},
	--Marrowrend to maintain 5 Bone Shield.
	{'Marrowrend', '!player.buff(Bone Shield).count >= 5', 'target'},
	--Blood Boil with 2 charges.
	{'Blood Boil', 'spell.charges >= 2', 'target'},
	--Death Strike to dump Runic Power.
	{'Death Strike', 'player.runicpower >= 60', 'target'},
	--Heart Strike as a filler to build Runic Power.
	{'Heart Strike'}
}

local incombat = {
	{Keybinds},
	{Cooldowns, 'toggle(cooldowns)'},
	{Taunts, 'toggle(taunt)'},
	{ST, 'target.inmelee'}
}

local outcombat = {
	{Keybinds},
}

NeP.CR:Add(250, '[NeP] Death Knight - Blood', incombat, outcombat, exeload, gui)
