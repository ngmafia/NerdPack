local Keybinds = {
	{'%pause', 'keybind(alt)'},
	{'Mass Dispell', 'keybind(lalt)', 'mouseover.ground'},
}

local StAI = {
	{'!Void Eruption'},
	{'!Mind Blast'},
	{'!Shadow Word: Death', 'player.insanity < 65'},
}

local CDs = {
	{'Shadowfiend'},
	{'Mindbender'},
	{'Power Infusion'},
	{'!Void Torrent', '!player.casting(Mind Blast) & !player.casting(Vampiric Touch) & !player.casting(Void Eruption) & !player.channeling(Mind Sear) & !player.channeling(Void Torrent)'},
	{'!Dispersion', 'spell(Mind Flay).casting & player.buff(Voidform).count > 50 & player.insanity < 10'},
	{'!Dispersion', 'spell(Mind Flay).casting & player.buff(Voidform).count > 50 & player.insanity < 30 & player.health < 40'},
}

local AoE = {
	{'Mind Bomb'},
	{'Mind Sear'},
}

local ST = {
	{'Shadowform', '!player.buff&!player.buff(Voidform)'},
	{StAI, '!player.casting(Mind Blast) & !player.casting(Vampiric Touch) & !player.casting(Void Eruption) & !player.channeling(Mind Sear) & !player.channeling(Void Torrent)'},
	{'Shadow Word: Pain', 'target.debuff(Shadow Word: Pain).duration < 3'},
	{'Vampiric Touch', 'target.debuff(Vampiric Touch).duration < 3'},
	{'Mind Flay', nil, 'target'},
	{'Mind Spike'},
}


local inCombat = {
	{Keybinds},
	{CDs, 'toggle(cooldowns)'},
	{AoE, 'keybind(lshift)'},
	{ST},
}

local outCombat = {
	{'Power Word: Shield', 'player.moving', 'player'},
}

NeP.CR:Add(258, '[NeP] Priest - Shadow', inCombat, outCombat)