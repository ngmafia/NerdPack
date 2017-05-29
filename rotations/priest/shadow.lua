local Keybinds = {
	{'%pause', 'keybind(alt)'},
	{'Mass Dispell', 'keybind(lalt)', 'mouseover.ground'},
}

local Interrupts = {
	--Silence selected target.
	{'Silence'},
	--Arcane Torrent Blood Elf racial if within 8 yard range of selected target when Silence is on cooldown. -- Credit to Xeer
	{'Arcane Torrent', 'target.range <= 8 & spell(Silence).cooldown > gcd & !lastgcd(Silence)'},
}

local Survival = {
	--Healthstone at or below 20% health. Active when NOT channeling Void Torrent.
	{'#Healthstone', 'player.health <= 20 & !player.channeling(Void Torrent)'},
	--Ancient Healing Potion at or below 20% health. Active when NOT channeling Void Torrent.
	{'#Ancient Healing Potion', 'player.health <= 20 & !player.channeling(Void Torrent)'},
	--Gift of the Naaru at or below 40% health. Active when NOT channeling Void Torrent.
	{'Gift of the Naaru', 'player.health <= 40 & !player.channeling(Void Torrent)'},
	--Power Word: Shield at or below 40% health. Active when NOT in Surrender to Madness or channeling Void Torrent.
	{'Power Word: Shield', 'player.health <= 40 & !player.buff(Surrender to Madness) & !player.channeling(Void Torrent)'},
	--Dispersion at or below 15% health. Last attempt at survival.
	{'!Dispersion', 'player.health <= 15'},
	--Power Word: Shield for Body and Soul to gain increased movement speed if moving. Active when NOT in Surrender to Madness or channeling Void Torrent.
	{'Power Word: Shield', 'talent(2,2) & player.moving & !player.buff(Surrender to Madness)'},
}

local AoE = {
	--Mind Bomb selected target for 2 second AoE stun.
	{'Mind Bomb'},
	--Mind Sear selected target.
	{'Mind Sear'},
}

local CDs = {
	--Berserking Troll racial. Conditions set for both Legacy of the Void/Mind Spike and Surrender to Madness.
	--When in Surrender to Madness and buffed by Power Infusion, you want to use Berserking after 5 Voidform counts.
	--NOTE: Adjust Voidform count '90' to a lower value if you are dead before then.
	--IMPORTANT: Be sure to modify the last Power Infusion Voidform condition (player.buff(Voidform).count >= 85) count to -5 seconds of set value for Berserking.
	{'Berserking', '!talent(7,3) & player.buff(Voidform).count >= 10 || player.buff(Voidform).count >= 90'},
	--Power Infusion. Conditions set for both Legacy of the Void/Mind Spike and Surrender to Madness. Active when NOT in Dispersion or channeling Void Torrent.
	--NOTE: Adjust Voidform count '85' to a lower value if you are dead before then.
	--IMPORTANT: Be sure to modify the last Berserking Voidform condition (player.buff(Voidform).count >= 90) count to +5 seconds of set value for Power Infusion.
	{'Power Infusion', '!talent(7,3) & player.buff(Voidform).count >= 15 & !player.buff(Dispersion) & !player.channeling(Void Torrent) || player.buff(Voidform).count >= 85 & !player.buff(Dispersion) & !player.channeling(Void Torrent)'},
	--Shadowfiend. Conditions set for both Legacy of the Void/Mind Spike and Surrender to Madness. Active when NOT channeling Void Torrent.
	--NOTE: When in Surrender to Madness and buffed by Power Infusion, you want to use Shadowfiend immediately after casting a Shadow Word: Death to ensure you have adequate insanity while on GCD.
	{'Shadowfiend', '!talent(7,3) & player.buff(Voidform).count >= 10 & !player.channeling(Void Torrent) || lastgcd(Shadow Word: Death) & player.buff(Power Infusion) & !player.channeling(Void Torrent)'},
	--Mindbender. Active when NOT channeling Void Torrent.
	{'Mindbender', '!player.channeling(Void Torrent)'},
	--Void Torrent will cancel/clip any current spell cast in favor of being used.
	{'!Void Torrent', '!player.casting(Mind Blast) & !player.casting(Vampiric Touch) & !player.casting(Void Eruption) & !player.channeling(Mind Sear) & !player.channeling(Void Torrent)'},

	{'!Dispersion', 'spell(Mind Flay).casting & player.buff(Voidform).count > 50 & player.insanity < 10'},
	{'!Dispersion', 'spell(Mind Flay).casting & player.buff(Voidform).count > 50 & player.insanity < 30 & player.health < 40'},
}

local StAI = {
	--Void Eruption when out of Voidform and above 85 insanity.
	{'!Void Eruption', '!player.buff(Voidform) & player.insanity >= 85 || player.buff(Voidform)'},
	--Mind Blast on cooldown. Works with Shadowy Insight.
	{'!Mind Blast'},
	--Shadow Word: Death when in Voidform and less than 65 insanity.
	{'!Shadow Word: Death', 'player.buff(Voidform) & player.insanity <= 65 || !player.buff(Voidform)'},
}

local ST = {
	{'Shadowform', '!player.buff&!player.buff(Voidform)'},
	{StAI, '!player.casting(Mind Blast) & !player.casting(Vampiric Touch) & !player.casting(Void Eruption) & !player.channeling(Mind Sear) & !player.channeling(Void Torrent)'},
	--Shadow Word: Pain maintained at all times.
	{'Shadow Word: Pain', 'target.debuff(Shadow Word: Pain).duration < 3.7'},
	--Vampiric Touch maintained at all times.
	{'Vampiric Touch', 'target.debuff(Vampiric Touch).duration < 4.7'},
	--Mind Flay as a filler to build Insanity.
	{'Mind Flay', nil, 'target'},
	--Mind Spike as a filler to build Insanity.
	{'Mind Spike'},
}

local incombat = {
	{Keybinds},
	{Interrupts, 'toggle(interrupts) & target.interruptAt(50) & target.infront & target.range <= 30'},
	{Survival, 'player.health < 100'},
	{AoE, 'keybind(lshift) & !player.channeling(Void Torrent)'},
	{CDs, 'toggle(cooldowns)'},
	{ST},
}

local outcombat = {
	--Power Word: Shield for Body and Soul to gain increased movement speed if moving.
	{'Power Word: Shield', 'talent(2,2) & player.moving', 'player'},
}

NeP.CR:Add(258, {
  name = '[NeP] Priest - Shadow',
  ic = incombat,
  ooc = outcombat,
})
