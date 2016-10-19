local Cooldowns = {
	--Guardian Spirit if below or if lowest health is 20% if Guardian Angel Talent selected.
	{'!Guardian Spirit', 'lowest.health <= 20 & talent(4,2)', 'lowest'}
}	

local Keybinds = {
	--Holy Word: Sanctify on Mouseover target left shift.
	{'Holy Word: Sanctify', 'keybind(lshift)', 'mouseover.ground'},
	-- Pause on left alt.
	{'%pause', 'keybind(lalt)'}
}

local Potions = {
    --Health Stone below 20% health. Active when NOT channeling Divine Hymn.
    {'#Health Stone', {'player.health <= 20 & !player.channeling(Divine Hymn)'},
    --Ancient Healing Potion below 20% health. Active when NOT channeling Divine Hymn.
    {'#Ancient Healing Potion', {'player.health <= 20 & !player.channeling(Divine Hymn)'},
    --Ancient Mana Potion below 20% mana. Active when NOT channeling Divine Hymn.
    {'#Ancient Mana Potion', {'player.mana < 10 & !player.channeling(Divine Hymn)'}
}

local SpiritOfRedemption = {
    --Holy Word: Serenity when lowest health is below 50%.
    {'Holy Word: Serenity', 'lowest.health < 50', 'lowest'},
    --Flash Heal when lowest health is below 100%.
    {'Flash Heal', 'lowest.health < 100' , 'lowest'}
}
			
local DPS = {
	--Holy Word: Chastise on cooldown if not healing .
	{'Holy Word: Chastise', nil , 'target'},
	--Holy Fire on cooldown if not healing.
	{'Holy Fire', nil, 'target'},
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
	{'Renew', '!tank.buff(Renew)', 'tank'},
	
}

local Player = {
	--Gift of the Naaru if player health is below or if 20%.
	{'Gift of the Naaru', 'player.health <= 20', 'player'},
	--Holy Word: Serenity if player health is below or if 50%.
	{'Holy Word: Serenity', 'player.health <= 50', 'player'},
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
	{'Flash Heal', 'buff(Surge of Light) & buff(Surge of Light).duration <= 3', 'lowest'},
	--Gift of the Naaru if lowest health is below or if 20% and has Guardian Spirit.
	{'Gift of the Naaru', 'lowest.health <= 20 & lowest.buff(Guardian Spirit)', 'lowest'},
	--Holy Word: Serenity if lowest health is below or if 50%.
	{'Holy Word: Serenity', 'lowest.health <= 50', 'lowest'},
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
			

local inCombat = {
	{Cooldowns, 'toggle(cooldowns)'},			
	{Keybinds},
	{Potions},
	{SpiritOfRedemption, 'buff(Spirit of Redemption)'},
	{DPS},
	{FastHeals, 'lowest.health < 30'},
	{Tank, 'tank.health < 100'}, 
	{Player, 'health < 100'}, 
	{Lowest, 'lowest.health < 100'}		
}			

local outCombat = {
	{Keybinds},
}

NeP.CR:Add(257, '[NeP] Priest - Holy', inCombat, outCombat)