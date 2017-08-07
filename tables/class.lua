local _, NeP = ...

local rangex = {
	["melee"] = 1.5,
	["ranged"] = 40,
}

NeP.ClassTable = {
	{ -- Warrior
		class = 'Warrior',
		hex = 'c79c6e',
		rgb = {0.78,0.61,0.43},
		specs = {71, 72, 73},
		[71] = {
			range = rangex["melee"],
			name = 'Arms',
			role = 'DPS'
		},
		[72] = {
			range = rangex["melee"],
			name = 'Fury',
			role = 'DPS'
		},
		[73] = {
			range = rangex["melee"],
			name = 'Protection',
			role = 'TANK'
		}
	},
	{  -- Paladin
		class = 'Paladin',
		hex = 'f58cba',
		rgb = {0.96,0.55,0.73},
		specs = {65, 66, 70},
		[65] = {
			range = rangex["melee"],
			name = 'Holy',
			role = 'HEALER'
		},
		[66] = {
			range = rangex["melee"],
			name = 'Protection',
			role = 'TANK'
		},
		[70] = {
			range = rangex["melee"],
			name = 'Retribution',
			role = 'DPS'
		}
	},
	{ -- Hunter
		class = 'Hunter',
		hex = 'abd473',
		rgb = {0.67,0.83,0.45},
		specs = {253, 254, 255},
		[253] = {
			range = rangex["ranged"],
			name = 'Beast Mastery',
			role = 'DPS'
		},
		[254] = {
			range = rangex["ranged"],
			name = 'Marksmanship',
			role = 'DPS'
		},
		[255] = {
			range = rangex["melee"],
			name = 'Survival',
			role = 'DPS'
		}
	},
	{ -- Rogue
		class = 'Rogue',
		hex = 'fff569',
		rgb = {1,0.96,0.41},
		specs = {259, 260, 261},
		[259] = {
			range = rangex["melee"],
			name = 'Assassination',
			role = 'DPS'
		},
		[260] = {
			range = rangex["melee"],
			name = 'Outlaw',
			role = 'DPS'
		},
		[261] = {
			range = rangex["melee"],
			name = 'Subtlety',
			role = 'DPS'
		}
	},
	{  -- Priest
		class = 'Priest',
		hex = 'ffffff',
		rgb = {1,1,1},
		specs = {256, 257, 258},
		[256] = {
			range = rangex["ranged"],
			name = 'Discipline',
			role = 'HEALER'
		},
		[257] = {
			range = rangex["ranged"],
			name = 'Holy',
			role = 'HEALER'
		},
		[258] = {
			range = rangex["ranged"],
			name = 'Shadow',
			role = 'HEALER'
		}
	},
	{ -- DeathKnight
		class = 'DeathKnight',
		hex = 'c41f3b',
		rgb = {0.77,0.12,0.23},
		specs = {250, 251, 252},
		[250] = {
			range = rangex["melee"],
			name = 'Blood',
			role = 'TANK'
		},
		[251] = {
			range = rangex["melee"],
			name = 'Frost',
			role = 'DPS'
		},
		[252] = {
			range = rangex["melee"],
			name = 'Unholy',
			role = 'DPS'
		}
	},
	{  -- Shaman
		class = 'Shaman',
		hex = '0070de',
		rgb = {0,0.44,0.87},
		specs = {262, 263, 264},
		[262] = {
			range = rangex["ranged"],
			name = 'Elemental',
			role = 'DPS'
		},
		[263] = {
			range = rangex["melee"],
			name = 'Enhancement',
			role = 'DPS'
		},
		[264] = {
			range = rangex["ranged"],
			name = 'Restoration',
			role = 'HEALER'
		}
	},
	{  -- Mage
		class = 'Mage',
		hex = '69ccf0',
		rgb = {0.41,0.8,0.94},
		specs = {62, 63, 64},
		[62] = {
			range = rangex["ranged"],
			name = 'Arcane',
			role = 'DPS'
		},
		[63] = {
			range = rangex["ranged"],
			name = 'Fire',
			role = 'DPS'
		},
		[64] = {
			range = rangex["ranged"],
			name = 'Frost',
			role = 'DPS'
		}
	},
	{ -- Warlock
		class = 'Warlock',
		hex = '9482c9',
		rgb = {0.58,0.51,0.79},
		specs = {265, 266, 267},
		[265] = {
			range = rangex["ranged"],
			name = 'Affliction',
			role = 'DPS'
		},
		[266] = {
			range = rangex["ranged"],
			name = 'Demonology',
			role = 'DPS'
		},
		[267] = {
			range = rangex["ranged"],
			name = 'Destruction',
			role = 'DPS'
		}
	},
	{ -- Monk
		class = 'Monk',
		hex = '00ff96',
		rgb = {0,1,0.59},
		specs = {268, 269, 270},
		[268] = {
			range = rangex["melee"],
			name = 'Brewmaster',
			role = 'TANK'
		},
		[269] = {
			range = rangex["melee"],
			name = 'Windwalker',
			role = 'DPS'
		},
		[270] = {
			range = rangex["ranged"],
			name = 'Mistweaver',
			role = 'HEALER'
		}
	},
	{ -- Druid
		class = 'Druid',
		hex = 'ff7d0a',
		rgb = {1,0.49,0.04},
		specs = {102, 103, 104, 105},
		[102] = {
			range = rangex["ranged"],
			name = 'Balance',
			role = 'DPS'
		},
		[103] = {
			range = rangex["melee"],
			name = 'Feral Combat',
			role = 'DPS'
		},
		[104] = {
			range = rangex["melee"],
			name = 'Guardian',
			role = 'TANK'
		},
		[105] = {
			range = rangex["ranged"],
			name = 'Restoration',
			role = 'HEALER'
		}
	},
	{ -- Demon Hunter
		class = 'Demon Hunter',
		hex = 'A330C9',
		rgb = {0.64,0.19,0.79},
		specs = {577, 581},
		[577] = {
			range = rangex["melee"],
			name = 'Havoc',
			role = 'DPS'
		},
		[581] = {
			range = rangex["melee"],
			name = 'Vengeance',
			role = 'TANK'
		}
	}
}

NeP.Globals.ClassTable = NeP.ClassTable
