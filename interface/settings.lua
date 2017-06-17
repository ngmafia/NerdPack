local n_name, NeP = ...
local L           = NeP.Locale

local config = {
    key = n_name..'_Settings',
    title = n_name,
    subtitle = L:TA('Settings', 'option'),
    width = 250,
    height = 270,
    config = {
			{ type = 'header', text = n_name..' |r'..NeP.Version..' '..NeP.Branch, size = 25, align = 'Center'},
			{ type = 'spinner', text = L:TA('Settings', 'bsize'), key = 'bsize', min = NeP.min_width, default = 40},
			{ type = 'spinner', text = L:TA('Settings', 'bpad'), key = 'bpad', default = 2},
      { type = 'spinner', text = L:TA('Settings', 'brow'), key = 'brow', step = 1, min = 1, max = 20, default = 10},

      { type = 'spacer' },{ type = 'ruler' },
			{ type = 'button', text = L:TA('Settings', 'apply_bt'), callback = function()
				NeP.ButtonsSize = NeP.Config:Read(n_name..'_Settings', 'bsize', 40)
				NeP.ButtonsPadding = NeP.Config:Read(n_name..'_Settings', 'bpad', 2)
				NeP.Interface:RefreshToggles()
			end}
		}
}

NeP.STs = NeP.Interface:BuildGUI(config)
NeP.Interface:Add(n_name..' '..L:TA('Settings', 'option'), function() NeP.STs:Show() end)
NeP.STs:Hide()
