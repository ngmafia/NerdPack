local n_name, NeP = ...
local mainframe = NeP.Interface.MainFrame
local L = NeP.Locale
local GameTooltip = GameTooltip
local CreateFrame = CreateFrame

NeP.ButtonsSize = 40
NeP.ButtonsPadding = 2

local min_width = 40
local min_height = 25

-- Load Saved sizes
NeP.Core:WhenInGame(function()
	NeP.ButtonsSize = NeP.Config:Read(n_name..'_Settings', 'bsize', 40)
	NeP.ButtonsPadding = NeP.Config:Read(n_name..'_Settings', 'bpad', 2)
	NeP.Interface:RefreshToggles()
end)

local Toggles = {}
local tcount = 0

local function SetTexture(parent, icon)
	local temp = parent:CreateTexture()
	if icon then
		temp:SetTexture(icon)
		temp:SetTexCoord(.08, .92, .08, .92)
	else
		local r,g,b = unpack(NeP.Core:ClassColor('player', 'rgb'))
		temp:SetColorTexture(r,g,b,.7)
	end
	temp:SetAllPoints(parent)
	return temp
end

local function OnClick(self, func, button)
	if button == 'LeftButton' then
		self.actv = not self.actv
		NeP.Config:Write('TOGGLE_STATES', self.key, self.actv)
	end
	if func then
		func(self, button)
	end
	self:SetChecked(self.actv)
end

local function OnEnter(self, name, text)
	local OnOff = self.actv and L:TA('Any', 'ON') or L:TA('Any', 'OFF')
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddDoubleLine(name, OnOff)
	if text then
		GameTooltip:AddLine('|cffFFFFFF'..text)
	end
	GameTooltip:Show()
end

local function CreateToggle(eval)
	local pos = (NeP.ButtonsSize*tcount)+(tcount*NeP.ButtonsPadding)-(NeP.ButtonsSize+NeP.ButtonsPadding)
	eval.key = eval.key:lower()
	Toggles[eval.key] = CreateFrame("CheckButton", eval.key, mainframe.content)
	local temp = Toggles[eval.key]
	temp:SetFrameStrata("high")
	temp:SetFrameLevel(1)
	temp.key = eval.key
	temp:SetPoint("LEFT", mainframe.content, pos, 0)
	temp:SetSize(NeP.ButtonsSize, NeP.ButtonsSize)
	temp:SetFrameLevel(1)
	temp:SetNormalFontObject("GameFontNormal")
	temp.texture = SetTexture(temp, eval.icon)
	temp.actv = NeP.Config:Read('TOGGLE_STATES', eval.key, false)
	temp:SetChecked(temp.actv)
	temp.nohide = eval.nohide
	temp.Checked_texture = SetTexture(temp)
	temp:SetCheckedTexture(temp.Checked_texture)
	temp:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	temp:SetScript("OnClick", function(self, button) OnClick(self, eval.func, button) end)
	temp:SetScript("OnEnter", function(self) OnEnter(self, eval.name, eval.text) end)
	temp:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

function NeP.Interface:UpdateIcon(key, icon)
	if not icon or not Toggles[key] then return end
	Toggles[key].texture:SetTexture(icon)
end

function NeP.Interface:AddToggle(eval)
	NeP.Core:WhenInGame(function()
		if Toggles[eval.key] then
			Toggles[eval.key]:Show()
		else
			CreateToggle(eval)
		end
		NeP.Interface:RefreshToggles()
	end)
end

function NeP.Interface:RefreshToggles()
	tcount = 0
	for k in pairs(Toggles) do
		if Toggles[k]:IsShown() then
			tcount = tcount + 1
			local pos = (NeP.ButtonsSize*tcount)+(tcount*NeP.ButtonsPadding)-(NeP.ButtonsSize+NeP.ButtonsPadding)
			Toggles[k]:SetSize(NeP.ButtonsSize, NeP.ButtonsSize)
			Toggles[k]:SetPoint("LEFT", mainframe.content, pos, 0)
		end
	end

	-- Set size to match ButtonsSize
	mainframe.settings.width = tcount*(NeP.ButtonsSize+NeP.ButtonsPadding)-NeP.ButtonsPadding
	mainframe.settings.height = NeP.ButtonsSize+18

	-- Dont go bellow the mimimum allowed
	if mainframe.settings.width<min_width then mainframe.settings.width=min_width end
	if mainframe.settings.height<min_height then mainframe.settings.height=min_height end

	-- Dont allow Resize
	mainframe.settings.minHeight = mainframe.settings.height
	mainframe.settings.minWidth = mainframe.settings.width
	mainframe.settings.maxHeight = mainframe.settings.height
	mainframe.settings.maxWidth = mainframe.settings.width

	-- apply
	mainframe:ApplySettings()
end

function NeP.Interface:ResetToggles()
	for k, v in pairs(Toggles) do
		if not v.nohide then
			Toggles[k]:Hide()
		end
	end
	NeP.Interface:RefreshToggles()
end

function NeP.Interface:toggleToggle(key, state)
	local self = Toggles[key:lower()]
	if not self then return end
	self.actv = state or not self.actv
	self:SetChecked(self.actv)
	NeP.Config:Write('TOGGLE_STATES', self.key, self.actv)
end

-- Globals
NeP.Globals.Interface.toggleToggle = NeP.Interface.toggleToggle
NeP.Globals.Interface.AddToggle = NeP.Interface.AddToggle
