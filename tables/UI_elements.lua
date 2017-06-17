local n_name, NeP = ...
local LibStub = LibStub
--local DiesalGUI   = LibStub("DiesalGUI-1.0")
--local DiesalTools = LibStub("DiesalTools-1.0")
--local SharedMedia = LibStub("LibSharedMedia-3.0")
local DiesalStyle = LibStub("DiesalStyle-1.0")
local Colors = DiesalStyle.Colors


NeP.UI = {}

NeP.UI.WindowStyleSheet = {
	['frame-outline'] = {
		type			= 'outline',
		layer			= 'BACKGROUND',
		color			= 'FFFFFF',
	},
	['frame-shadow'] = {
		type			= 'shadow',
	},
	['titleBar-color'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= 'FFFFFF',
		alpha			= .75,
	},
	['titletext-Font'] = {
		type			= 'font',
		color			= 'd8d8d8',
	},
	['closeButton-icon'] = {
		type			= 'texture',
		layer			= 'ARTWORK',
    image     = {'DiesalGUIcons', {9,5,16,256,128}},
		alpha 		= .3,
		position	= {-2,nil,-1,nil},
		width			= 16,
		height		= 16,
	},
	['closeButton-iconHover'] = {
		type			= 'texture',
		layer			= 'HIGHLIGHT',
    image     = {'DiesalGUIcons', {9,5,16,256,128}, 'b30000'},
		alpha			= 1,
		position	= {-2,nil,-1,nil},
		width			= 16,
		height		= 16,
	},
	['header-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
    gradient	= {'VERTICAL',Colors.UI_400_GR[1],Colors.UI_400_GR[2]},
    alpha     = .95,
		position 	= {0,0,0,-1},
	},
	['header-inline'] = {
		type			= 'outline',
		layer			= 'BORDER',
    gradient	= {'VERTICAL','ffffff','ffffff'},
    alpha     = {.05,.02},
		position	= {0,0,0,-1},
	},
	['header-divider'] = {
		type			= 'texture',
		layer			= 'BORDER',
		color			= '000000',
		alpha 		= 1,
		position	= {0,0,nil,0},
		height		= 1,
	},
	['content-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= Colors.UI_100,
		alpha			= .95,
	},
	['content-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= 'FFFFFF',
		alpha			= .01
	},
	['footer-background'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
    gradient	= {'VERTICAL',Colors.UI_400_GR[1],Colors.UI_400_GR[2]},
    alpha     = .95,
		position 	= {0,0,-1,0},
	},
	['footer-divider'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '000000',
		position	= {0,0,0,nil},
		height		= 1,
	},
	['footer-inline'] = {
		type			= 'outline',
		layer			= 'BORDER',
    gradient	= {'VERTICAL','ffffff','ffffff'},
    alpha     = {.05,.02},
		position	= {0,0,-1,0},
    debug = true,
	},
}

NeP.UI.buttonStyleSheet = {
  ['frame-color'] = {
    type			= 'texture',
    layer			= 'BACKGROUND',
    color			= 'FFFFFF',
    offset		= 0,
  },
  ['frame-highlight'] = {
    type			= 'texture',
    layer			= 'BORDER',
    gradient	= 'VERTICAL',
    color			= 'FFFFFF',
    alpha 		= 0,
    alphaEnd	= .1,
    offset		= -1,
  },
  ['frame-outline'] = {
    type			= 'outline',
    layer			= 'BORDER',
    color			= '000000',
    offset		= 0,
  },
  ['frame-inline'] = {
    type			= 'outline',
    layer			= 'BORDER',
    gradient	= 'VERTICAL',
    color			= 'ffffff',
    alpha 		= .02,
    alphaEnd	= .09,
    offset		= -1,
  },
  ['frame-hover'] = {
    type			= 'texture',
    layer			= 'HIGHLIGHT',
    color			= 'ffffff',
    alpha			= .1,
    offset		= 0,
  },
  ['text-color'] = {
    type			= 'Font',
    color			= '000000',
  },
}

NeP.UI.spinnerStyleSheet = {
  ['bar-background'] = {
    type			= 'texture',
    layer			= 'BORDER',
    color			= 'ee2200',
  },
}

NeP.UI.createButtonStyle = {
  type			= 'texture',
  texFile		= 'DiesalGUIcons',
  texCoord		= {1,6,16,256,128},
  alpha 		= .7,
  offset		= {-2,nil,-2,nil},
  width			= 16,
  height		= 16,
}

NeP.UI.deleteButtonStyle = {
  type			= 'texture',
  texFile		='DiesalGUIcons',
  texCoord		= {2,6,16,256,128},
  alpha 		= .7,
  offset		= {-2,nil,-2,nil},
  width			= 16,
  height		= 16,
}

NeP.UI.ButtonNormal = {
  type			= 'texture',
  texColor		= 'ffffff',
  alpha 		= .7,
}

NeP.UI.ButtonOver = {
  type			= 'texture',
  alpha 		= 1,
}

NeP.UI.ButtonClicked = {
  type			= 'texture',
  alpha 		= .3,
}

NeP.UI.statusBarStylesheet = {
  ['frame-texture'] = {
    type		= 'texture',
    layer		= 'BORDER',
    gradient	= 'VERTICAL',
    color		= '000000',
    alpha 		= 0.7,
    alphaEnd	= 0.1,
    offset		= 0,
  }
}

local DiesalGUI = LibStub("DiesalGUI-1.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

DiesalGUI:RegisterObjectConstructor("FontString", function()
  local self 		= DiesalGUI:CreateObjectBase(Type)
  local frame		= CreateFrame('Frame',nil,UIParent)
  local fontString = frame:CreateFontString(nil, "OVERLAY", 'DiesalFontNormal')
  self.frame		= frame
  self.fontString = fontString
  self.SetParent = function(self, parent)
    self.frame:SetParent(parent)
  end
  self.OnRelease = function(self)
    self.fontString:SetText('')
  end
  self.OnAcquire = function(self)
    self:Show()
  end
  self.type = "FontString"
  return self
end, 1)

DiesalGUI:RegisterObjectConstructor("Rule", function()
  local self 		= DiesalGUI:CreateObjectBase(Type)
  local frame		= CreateFrame('Frame',nil,UIParent)
  self.frame		= frame
  frame:SetHeight(1)
  frame.texture = frame:CreateTexture()
  frame.texture:SetColorTexture(1,1,1,1)
  frame.texture:SetAllPoints(frame)
  self.SetParent = function(self, parent)
    self.frame:SetParent(parent)
  end
  self.OnRelease = function(self)
    self:Hide()
  end
  self.OnAcquire = function(self)
    self:Show()
  end
  self.type = "Rule"
  return self
end, 1)

DiesalGUI:RegisterObjectConstructor("StatusBar", function()
  local self  = DiesalGUI:CreateObjectBase(Type)
  local frame = CreateFrame('StatusBar',nil,UIParent)
  self.frame  = frame

  self:SetStylesheet(NeP.UI.statusBarStylesheet)

  frame.Left = frame:CreateFontString()
  frame.Left:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 14)
  frame.Left:SetShadowColor(0,0,0, 0)
  frame.Left:SetShadowOffset(-1,-1)
  frame.Left:SetPoint("LEFT", frame)

  frame.Right = frame:CreateFontString()
  frame.Right:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 14)
  frame.Right:SetShadowColor(0,0,0, 0)
  frame.Right:SetShadowOffset(-1,-1)

  frame:SetStatusBarTexture(1,1,1,0.8)
  frame:GetStatusBarTexture():SetHorizTile(false)
  frame:SetMinMaxValues(0, 100)
  frame:SetHeight(16)

  self.SetValue = function(self, value)
    self.frame:SetValue(value)
  end
  self.SetParent = function(self, parent)
    self.parent = parent
    self.frame:SetParent(parent)
    self.frame:SetPoint("LEFT", parent, "LEFT")
    self.frame:SetPoint("RIGHT", parent, "RIGHT")
    self.frame.Right:SetPoint("RIGHT", self.frame, "RIGHT", -2, 2)
    self.frame.Left:SetPoint("LEFT", self.frame, "LEFT", 2, 2)
  end
  self.OnRelease = function(self)
    self:Hide()
  end
  self.OnAcquire = function(self)
    self:Show()
  end
  self.type = "StatusBar"
  return self
end, 1)
