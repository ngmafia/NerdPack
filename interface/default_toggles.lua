local _, NeP = ...
local L = NeP.Locale

local dToggles = {
	{
		key = 'mastertoggle',
		name = 'MasterToggle',
		text = L:TA('mainframe', 'MasterToggle'),
		icon = 'Interface\\ICONS\\Ability_repair.png',
		func = function(self, button)
			if button == "RightButton" then
				if IsControlKeyDown() then
					NeP.Interface.MainFrame.drag:Show()
				else
					NeP.Interface:DropMenu()
				end
			end
		end
	},
	{
		key = 'interrupts',
		name = 'Interrupts',
		text = L:TA('mainframe', 'Interrupts'),
		icon = 'Interface\\ICONS\\Ability_Kick.png',
	},
	{
		key = 'cooldowns',
		name = 'Cooldowns',
		text = L:TA('mainframe', 'Cooldowns'),
		icon = 'Interface\\ICONS\\Achievement_BG_winAB_underXminutes.png',
	},
	{
		key = 'aoe',
		name = 'Multitarget',
		text = L:TA('mainframe', 'AoE'),
		icon = 'Interface\\ICONS\\Ability_Druid_Starfall.png',
	}
}

function NeP.Interface:DefaultToggles()
	for i=1, #dToggles do
		self:AddToggle(dToggles[i])
	end
end