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

function NeP.Interface:UpdateStyles()
  local ClassColor = NeP.Core:ClassColor('player', 'hex')
  local tmp, n1, n2, n3;

  n1, n2, n3 = "WindowStyleSheet", 'frame-outline', "color"
  tmp = NeP.Config:Read(n_name..'_Settings', n1..n2..n3, self[n1][n2][n3])
  if tmp == 'CLASS' then tmp = ClassColor end
  self[n1][n2][n3] = tmp

  n1, n2, n3 = "WindowStyleSheet", 'titleBar-color', "color"
  tmp = NeP.Config:Read(n_name..'_Settings', n1..n2..n3, self[n1][n2][n3])
  if tmp == 'CLASS' then tmp = ClassColor end
  self[n1][n2][n3] = tmp

  n1, n2, n3 = "WindowStyleSheet", 'titleBar-color', "alpha"
  tmp = NeP.Config:Read(n_name..'_Settings', n1..n2..n3, self[n1][n2][n3])
  if tmp == 'CLASS' then tmp = ClassColor end
  self[n1][n2][n3] = tmp

  n1, n2, n3 = "WindowStyleSheet", 'content-background', "color"
  tmp = NeP.Config:Read(n_name..'_Settings', n1..n2..n3, self[n1][n2][n3])
  if tmp == 'CLASS' then tmp = ClassColor end
  self[n1][n2][n3] = tmp

  n1, n2, n3 = "WindowStyleSheet", 'content-background', "alpha"
  tmp = NeP.Config:Read(n_name..'_Settings', n1..n2..n3, self[n1][n2][n3])
  if tmp == 'CLASS' then tmp = ClassColor end
  self[n1][n2][n3] = tmp

  local outline_color = NeP.Interface.WindowStyleSheet['frame-outline'].color

  n1, n2, n3 = "spinnerStyleSheet", 'bar-background', "color"
  self[n1][n2][n3] = outline_color

  n1, n2, n3 = "buttonStyleSheet", 'frame-color', "color"
  self[n1][n2][n3] = outline_color

  n1, n2, n3 = "comboBoxStyleSheet", 'frame-background', "color"
  self[n1][n2][n3] = outline_color

  n1, n2, n3 = "comboBoxStyleSheet", 'dropdown-background', "color"
  self[n1][n2][n3] = outline_color

  for _,gui in pairs(NeP.Interface.usedGUIs) do
    gui.parent:SetStylesheet(NeP.Interface.WindowStyleSheet)
    for _, element in pairs(gui.elements) do
      if element.style then
        element.parent:SetStylesheet(element.style)
      end
    end
  end

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
    { type = 'dropdown', text = L('outline_color'), key = 'WindowStyleSheetframe-outlinecolor', list = CL, default = 'CLASS'},
    { type = 'dropdown', text = L('tittle_color'), key = 'WindowStyleSheettitleBar-colorcolor', list = CL, default = '000000'},
    { type = 'spinner', text = L('tittle_alpha'), key = 'WindowStyleSheettitleBar-coloralpha', step = .05, max = 1, default = .8},
    { type = 'dropdown', text = L('content_color'), key = 'WindowStyleSheetcontent-backgroundcolor', list = CL, default = '000000'},
    { type = 'spinner', text = L('content_alpha'), key = 'WindowStyleSheetcontent-backgroundalpha', step = .05, max = 1, default = .7},

    { type = 'spacer' },{ type = 'ruler' },
		{ type = 'button', text = L('apply_bt'), callback = function() NeP.Interface:UpdateStyles() end },

	}
}

NeP.STs = NeP.Interface:BuildGUI(config)
NeP.Interface:Add(n_name..' '..L('option'), function() NeP.STs.parent:Show() end)
NeP.STs.parent:Hide()
