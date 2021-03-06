local _, NeP = ...

local LibStub = LibStub
local tremove = tremove
local tinsert = tinsert
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local TargetUnit = TargetUnit
local C_Timer = C_Timer
local DiesalGUI = LibStub('DiesalGUI-1.0')
local L = NeP.Locale

local statusBars = {}
local statusBarsUsed = {}

local OM_GUI = NeP.Interface:BuildGUI({
	key = 'NePOMgui',
	width = 500,
	height = 250,
	title = 'ObjectManager GUI'
})
local parent = OM_GUI.parent
parent:Hide()
NeP.Interface:Add(L:TA('OM', 'Option'), function() parent:Show() end)

local dOM = 'Enemy'
local bt = {
	{a = 'TOPLEFT', 	b = 'Enemy'},
	{a = 'TOP', 			b = 'Friendly'},
	{a = 'TOPRIGHT', 	b = 'Dead'}
}
for i=1, #bt do
	local tmp = DiesalGUI:Create("Button")
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetPoint(bt[i].a, parent.content, bt[i].a, 0, 0)
	--bt[k]:SetStylesheet(NeP.Interface.buttonStyleSheet)
	tmp:SetEventListener("OnClick", function() dOM = bt[i].b end)
	tmp:SetText(L:TA('OM', bt[i].b))
	OM_GUI.elements[bt[i].b] = {parent = tmp, type = "button", style = NeP.Interface.buttonStyleSheet}
	tmp.frame:SetSize(parent.content:GetWidth()/3, 30)
end

local ListWindow = DiesalGUI:Create('ScrollFrame')
parent:AddChild(ListWindow)
ListWindow:SetParent(parent.content)
ListWindow:SetPoint("TOP", parent.content, "TOP", 0, -30)
ListWindow.frame:SetSize(parent.content:GetWidth(), parent.content:GetHeight()-30)
ListWindow.parent = parent

local function getStatusBar()
	local statusBar = tremove(statusBars)
	if not statusBar then
		statusBar = DiesalGUI:Create('StatusBar')
		statusBar:SetParent(ListWindow.content)
		parent:AddChild(statusBar)
		statusBar.frame:SetStatusBarColor(1,1,1,0.35)
	end
	statusBar:Show()
	table.insert(statusBarsUsed, statusBar)
	return statusBar
end

local function recycleStatusBars()
	for i = #statusBarsUsed, 1, -1 do
		statusBarsUsed[i]:Hide()
		tinsert(statusBars, tremove(statusBarsUsed))
	end
end

local function GetTable()
	local tmp = {}
	for _, Obj in pairs(NeP.OM:Get(dOM, true)) do
		tmp[#tmp+1] = Obj
	end
	table.sort( tmp, function(a,b) return a.distance < b.distance end )
	return tmp
end

local function RefreshGUI()
	local offset = -5
	recycleStatusBars()
	for _, Obj in pairs(GetTable()) do
		local Health = math.floor(((UnitHealth(Obj.key) or 1) / (UnitHealthMax(Obj.key) or 1)) * 100)
		local SB = getStatusBar()
		local distance = NeP.Core:Round(Obj.distance or 0)
		SB.frame:SetPoint('TOP', ListWindow.content, 'TOP', 2, offset )
		SB.frame.Left:SetText('|cff'..NeP.Core:ClassColor(Obj.key, 'hex')..Obj.name)
		SB.frame.Right:SetText('( |cffff0000ID|r: '..Obj.id..' / |cffff0000Health|r: '..Health..' / |cffff0000Dist|r: '..distance..' )')
		SB.frame:SetScript('OnMouseDown', function() TargetUnit(Obj.key) end)
		SB:SetValue(Health)
		offset = offset -18
	end
end

C_Timer.NewTicker(0.1, (function()
	if parent:IsShown() then
		RefreshGUI()
	end
end), nil)
