local n_name, NeP = ...
local L           = function(val) return NeP.Locale:TA('Settings', val) end
local DiesalStyle = LibStub("DiesalStyle-1.0")

local CL = {
  {text = 'White', key = 'FFFFFF'},
  {text = 'Black', key = '000000'},
  {text = 'Class Color', key = 'CLASS'},
}

for i=1, #NeP.ClassTable do
  CL[#CL+1] = {text = NeP.ClassTable[i].class, key = NeP.ClassTable[i].hex}
end


local n = {
	['frame-outline'] = {'color'},
	['titleBar-color'] = {'color', 'alpha'},
	['content-background'] = {'color', 'alpha'}
}

local function window_styles()
  local ClassColor = NeP.Core:ClassColor('player', 'hex')
	local tmp1;
  for k1, k2 in pairs(n) do
    for i=1, #k2 do
      tmp1 = NeP.Interface.WindowStyleSheet[k1][k2[i]]
      tmp1 = NeP.Config:Read(n_name..'_Settings', k1..k2[i], tmp1)
      if tmp1 == 'CLASS' then tmp1 = ClassColor end
      NeP.Interface.WindowStyleSheet[k1][k2[i]] = tmp1
    end
  end
end

local function elements_style()
  NeP.Interface:SetElementColor(NeP.Interface.WindowStyleSheet['frame-outline'].color)
  for _,gui in pairs(NeP.Interface.usedGUIs) do
    gui.parent:SetStylesheet(NeP.Interface.WindowStyleSheet)
    for _, element in pairs(gui.elements) do
      if element.style then
        element.parent:SetStylesheet(element.style)
        element.parent:ApplySettings()
      end
    end
  end
end

function NeP.Interface.UpdateStyles()
  window_styles()
  elements_style()
  NeP.ButtonsSize = NeP.Config:Read(n_name..'_Settings', 'bsize', 40)
  NeP.ButtonsPadding = NeP.Config:Read(n_name..'_Settings', 'bpad', 2)
  NeP.Interface:RefreshToggles()
end

-- Update Styles
NeP.Core:WhenInGame(function()
	NeP.Interface:UpdateStyles()
end,999)

local config = {
key = n_name..'_Settings',
title = n_name,
  subtitle = L('option'),
  width = 250,
  height = 270,
  config = {
		{ type = 'header', text = n_name..' |r'..NeP.Version..' '..NeP.Branch, size = 14, align = 'Center'},
		{ type = 'spinner', text = L('bsize'), key = 'bsize', min = NeP.min_width, default = 40},
		{ type = 'spinner', text = L('bpad'), key = 'bpad', default = 2},
    { type = 'spinner', text = L('brow'), key = 'brow', step = 1, min = 1, max = 20, default = 10},

    { type = 'spacer' },{ type = 'ruler' },
    { type = 'dropdown', text = L('outline_color'), key = 'frame-outlinecolor', list = CL, default = 'CLASS'},
    { type = 'dropdown', text = L('tittle_color'), key = 'titleBar-colorcolor', list = CL, default = '000000'},
    { type = 'spinner', text = L('tittle_alpha'), key = 'titleBar-coloralpha', step = .05, max = 1, default = .8},
    { type = 'dropdown', text = L('content_color'), key = 'content-backgroundcolor', list = CL, default = '000000'},
    { type = 'spinner', text = L('content_alpha'), key = 'content-backgroundalpha', step = .05, max = 1, default = .7},

    { type = 'spacer' },{ type = 'ruler' },
		{ type = 'button', text = L('apply_bt'), callback = NeP.Interface.UpdateStyles },

	}
}

NeP.STs = NeP.Interface:BuildGUI(config)
NeP.Interface:Add(n_name..' '..L('option'), function() NeP.STs:Show() end)
NeP.STs:Hide()
