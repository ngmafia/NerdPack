local n_name, NeP = ...

local config = {
    key = n_name..'_Settings',
    title = n_name..' Settings',
    subtitle = 'Settings',
    width = 250,
    height = 270,
    config = {
			{ type = 'header', text = n_name..' |r'..NeP.Version..' '..NeP.Branch, size = 25, align = 'Center'},
			{ type = 'spinner', text = 'Toggle Size', key = 'bsize', default = 40},
			{ type = 'spinner', text = 'Toggle Padding', key = 'bpad', default = 2},

			{ type = 'button', text = 'Apply Settings', callback = function()
				NeP.ButtonsSize = NeP.Config:Read(n_name..'_Settings', 'bsize', 40)
				NeP.ButtonsPadding = NeP.Config:Read(n_name..'_Settings', 'bpad', 2)
				NeP.Interface:RefreshToggles()
			end}
		}
}

NeP.STs = NeP.Interface:BuildGUI(config)
NeP.Interface:Add(n_name..' Settings', function() NeP.STs:Show() end)
NeP.STs:Hide()
