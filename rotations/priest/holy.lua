local GUI = {
	
	--------------------------------------------TRINKETS------------------------------------------------
	----------------------------------------------------------------------------------------------------
	{type = 'header', 	text = 'Trinkets', align = 'center'},
	{type = 'text', 	text = 'Check to Enable Trinkets', align = 'center'},
	{type = 'checkbox', text = 'Top Trinket enabled', key = 'trinket_1', default = false},
	{type = 'checkbox', text = 'Bottom Trinket enabled', key = 'Trinket_2', default = false},
	
	--------------------------------------------KEYBINDS-----------------------------------------------------
	---------------------------------------------------------------------------------------------------
	
	{type = 'header', 	text = 'Keybinds', align = 'center'},
	{type = 'text', 	text = 'Left Shift: Holy Word: Sanctify | Left Ctrl: Mass Dispel	| Alt: Pause', align = 'center'},
	{type = 'checkbox', text = 'Holy Word: Sanctify enabled', key = 'k_HWS', default = false},
	{type = 'checkbox', text = 'Mass Dispel enabled', key = 'k_MD', default = false},
	{type = 'checkbox', text = 'Pause enabled', key = 'k_P', default = false},

	--------------------------------------------POTIONS-------------------------------------------------
	----------------------------------------------------------------------------------------------------

	{type = 'header', 	text = 'Potions', align = 'center'},
	{type = 'text', 	text = 'Check to enable Potions', align = 'center'},
	{type = 'checkbox', text = 'Health Stone', key = 'p_HS', default = false},
	{type = 'spinner', text = 'Health Stone', key = 'sp_HS', default = 20},
	{type = 'checkbox', text = 'Ancient Healing Potion', key = 'p_AHP', default = false},
	{type = 'spinner', text = 'Ancient Healing Potion', key = 'sp_AHP', default = 20},
	{type = 'checkbox', text = 'Ancient Mana Potion', key = 'p_AMP', default = false},
	{type = 'spinner', text = 'Ancient Mana Potion', key = 'sp_AMP', default = 10},
	
	--------------------------------------------DPS-----------------------------------------------------
	----------------------------------------------------------------------------------------------------
	{type = 'header', 	text = 'DPS mode', align = 'center'},
	{type = 'text', 	text = 'Check to enable extra DPS', align = 'center'},
	{type = 'checkbox', text = 'Holy Word: Chastise enabled', key = 'd_HWC', default = false},
	{type = 'checkbox', text = 'Holy Fire enabled', key = 'd_HF', default = false},

	
}

local Cooldowns = {
	--Guardian Spirit if below or if lowest health is 20% if Guardian Angel Talent selected.
	{'!Guardian Spirit', 'lowest.health <= 20 & talent(4,2)', 'lowest'}
}	

local Trinkets = {
	--Top Trinket usage if UI enables it.
	{'#trinket1', 'UI(trinket_1)'},
	--Bottom Trinket usage if UI enables it.
	{'#trinket2', 'UI(trinket_2)'}
}

local Keybinds = {
	--Mass Dispel on Mouseover target Left Control.
	{'Mass Dispel', 'keybind(lctrl) & UI(k_MD)', 'mouseover.ground'},											 
	--Holy Word: Sanctify on Mouseover target left shift.
	{'Holy Word: Sanctify', 'keybind(lshift) & UI(k_HWS)', 'mouseover.ground'},												 
	-- Pause on left alt.
	{'%pause', 'keybind(lalt)& UI(k_P)'}																														 
}

local Potions = {
	--Health Stone below 20% health. Active when NOT channeling Divine Hymn.
	{'#Health Stone', 'player.health <= UI(sp_HS) & UI(p_HS) & !player.channeling(Divine Hymn)'},
	--Ancient Healing Potion below 20% health. Active when NOT channeling Divine Hymn.
	{'#Ancient Healing Potion', 'player.health <= UI(sp_AHP) & UI(p_AHP) & !player.channeling(Divine Hymn)'},
	--Ancient Mana Potion below 20% mana. Active when NOT channeling Divine Hymn.
	{'#Ancient Mana Potion', 'player.mana <= UI(sp_AMP)& UI(p_AMP) & !player.channeling(Divine Hymn)'}
}

local SpiritOfRedemption = {
	--Holy Word: Serenity when lowest health is below 50%.
	{'Holy Word: Serenity', 'lowest.health < 50', 'lowest'},
	--Flash Heal when lowest health is below 100%.
	{'Flash Heal', 'lowest.health < 100' , 'lowest'}
}
			
local DPS = {
	--Holy Word: Chastise on cooldown if not healing .
	{'Holy Word: Chastise', 'UI(d_HWC)' , 'target'},																
	--Holy Fire on cooldown if not healing.
	{'Holy Fire', 'UI(d_HF)' , 'target'},																					 
	--Smite on cooldown if not healing.
	{'Smite', nil, 'target'}
}

local FastHeals = {
	--Holy Word: Serenity on cooldown if lowest health is below 30%.
	{'Holy Word: Serenity', nil, 'lowest'},
	--Flash Heal on cooldown if lowest health is below 30%.
	{'Flash Heal', nil, 'lowest'}
}

local Tank = {
	--Holy Word: Serenity if tank health below or if 60%.
	{'Holy Word: Serenity', 'tank.health <= 60', 'tank'},
	--Flash heal if tank health below or if 70%.
	{'Flash Heal', 'tank.health <= 70', 'tank'},
	--Prayer of Mending if tank missing Prayer of Mending.
	{'Prayer of Mending', '!tank.buff(Prayer of Mending)', 'tank'},
	--Renew if tank missing Renew.
	{'Renew', '!tank.buff(Renew)', 'tank'}
	
}

local Player = {
	--Gift of the Naaru if player health is below or if 20%.
	{'Gift of the Naaru', 'player.health <= 20', 'player'},
	--Holy Word: Serenity if player health is below or if 60%.
	{'Holy Word: Serenity', 'player.health <= 60', 'player'},
	--Flash Heal if player health is below or if 60%.
	{'Flash Heal', 'player.health <= 60', 'player'},
	--Prayer of Mending if player missing Prayer of Mending.
	{'Prayer of Mending', '!player.buff(Prayer of Mending)', 'player'},
	--Renew if player missing Renew.
	{'Renew', '!player.buff(Renew)', 'player'},
	--Prayer of Healing if... 
	
}
			
local Lowest = {
	--Flash Heal charge Dump if Surge of Light duration is less or equal to 3 seconds.
	{'Flash Heal', 'buff(Surge of Light) & buff(Surge of Light).duration <= 3 & lowest.health < 100', 'lowest'},
	--Gift of the Naaru if lowest health is below or if 20% and has Guardian Spirit.
	{'Gift of the Naaru', 'lowest.health <= 20 & lowest.buff(Guardian Spirit)', 'lowest'},
	--Holy Word: Serenity if lowest health is below or if 60%.
	{'Holy Word: Serenity', 'lowest.health <= 60', 'lowest'},
	--Flash Heal if lowest health is below or if 70%.			
	{'Flash Heal', 'lowest.health <= 70', 'lowest'},
	--Prayer of Healing if...
	
	--Prayer of Mending if lowest health is missing Prayer of Mending.
	{'Prayer of Mending', '!lowest.buff(Prayer of Mending)', 'lowest'},
	--Renew if lowest health is missing Renew.
	{'Renew', '!lowest.buff(Renew)', 'lowest'},
	--Heal if Lowest Healt is below or if 90%.
	{'Heal', 'lowest.health <= 90', 'lowest'}
}

local Moving = {
	--Holy Word: Serenity if lowest health below or if 60% and moving.
	{'Holy Word: Serenity', 'lowest.health <= 60', 'lowest'},
	--Renew if lowest health is missing Renew and Lowest health below 100% and moving.
	{'Renew', '!lowest.buff(Renew) & lowest.health < 100', 'lowest'},
	--Flash Heal charge Dump if Surge of Light duration is less or equal to 3 seconds and moving
	{'Flash Heal', 'buff(Surge of Light) & buff(Surge of Light).duration <= 3 & lowest.health < 100', 'lowest'},
	--Flash Heal when Surge of Light is active, Lowest Health is below 70% and moving.
	{'Flash Heal', 'buff(Surge of Light) & lowest.health < 70', 'lowest'},
	--Angelic Feather if player is moving for 2 seconds or longer and Missing Angelic Feather and if UI enables it. WIP
	{'Angelic Feather', 'player.movingfor >= 2 & !buff(Angelic Feather) & spell(Angelic Feather).charges >= 1', 'player.ground'} --UI enable
	
}

local inCombat = {
	--Fade when you get aggro.
	{'fade', 'aggro'},
	{Cooldowns, 'toggle(cooldowns)'},	
	{Trinkets},
	{Keybinds},
	{Potions},
	{SpiritOfRedemption, 'buff(Spirit of Redemption)'},
	{'%dispelall'},
	{{
		{FastHeals, 'lowest.health < 30'},
		{Tank, 'tank.health < 100'},
		{Player, 'health < 100'},
		{Lowest, 'lowest.health < 100'},
		{DPS},
	}, '!moving'},
	{Moving, 'moving'},
	
}			

local outCombat = {
	{Keybinds},
	{Moving, 'moving'},
}

NeP.CR:Add(257, '[NeP] Priest - Holy', inCombat, outCombat, GUI)
