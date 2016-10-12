local Keybinds = {
	{'%pause', 'keybind(alt)'}
}

local StAI = {
	{'!Void Eruption'},
	{'!Mind Blast'},
	{'!Shadow Word: Death'}
}

local CDs = {
	{'Shadowfiend'},
	{'Mindbender'},
	{'Power Infusion'},
	{'!Void Torrent', '!spell(Mind Blast).casting || !spell(Vampiric Touch).casting || !spell(Void Torrent).casting || !spell(Mind Sear).casting'},
	{'!Dispersion', 'spell(Mind Flay).casting & player.buff(Voidform).count > 50 & player.insanity < 10'},
	{'!Dispersion', 'spell(Mind Flay).casting & player.buff(Voidform).count > 50 & player.insanity < 30 & player.health < 40'},
}

local AoE = {
	{'Mind Bomb'},
	{'Mind Sear'}
}

local ST = {
	{'Shadowform', '!player.buff&!player.buff(Voidform)'},
	{StAI, '!spell(Mind Blast).casting || !spell(Vampiric Touch).casting || !spell(Void Torrent).casting || !spell(Mind Sear).casting'},
	{'Shadow Word: Pain', 'target.debuff(Shadow Word: Pain).duration < 3'},
	{'Vampiric Touch', 'target.debuff(Vampiric Touch).duration < 3'},
	{'Mind Flay'},
	{'Mind Spike'}
}

local inCombat = {
	{Keybinds},
	{CDs},
	{ST}
}

local outCombat = {
	{Keybinds}
}

NeP.CR:Add(258, '[NeP] Priest - Shadow', inCombat, outCombat)