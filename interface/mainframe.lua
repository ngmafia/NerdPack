local n_name, NeP = ...
local logo = '|T'..NeP.Media..'logo.blp:10:10|t'
local L = NeP.Locale

local EasyMenu = EasyMenu
local CreateFrame = CreateFrame
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecialization = GetSpecialization

NeP.Interface.MainFrame = NeP.Interface:BuildGUI({
	key = 'NePMFrame',
	width = 100,
	height = 60,
	title = logo..n_name,
	subtitle = 'v:'..NeP.Version..' - '..NeP.Branch
}).parent
NeP.Interface.MainFrame:SetEventListener('OnClose', function()
	NeP.Core:Print(L:TA('Any', 'NeP_Show'))
end)

local menuFrame = CreateFrame("Frame", 'NeP_DropDown', NeP.Interface.MainFrame.frame, "UIDropDownMenuTemplate")
menuFrame:SetPoint("BOTTOMLEFT", NeP.Interface.MainFrame.frame, "BOTTOMLEFT", 0, 0)
menuFrame:Hide()

local DropMenu = {
	{text = logo..'['..n_name..' |rv:'..NeP.Version..']', isTitle = 1, notCheckable = 1},
	{text = L:TA('mainframe', 'CRS'), hasArrow = true, menuList = {}},
	{text = L:TA('mainframe', 'CRS_ST'), hasArrow = true, menuList = {}}
}

function NeP.Interface.ResetCRs()
	DropMenu[2].menuList = {}
	DropMenu[3].menuList = {}
	local spec = GetSpecializationInfo(GetSpecialization())
	for _,v in pairs(NeP.CR:GetList(spec)) do
		NeP.Interface:AddCR(v)
		NeP.Interface:AddCR_ST(v.name)
	end
end

function NeP.Interface.UpdateCRs()
	local spec = GetSpecializationInfo(GetSpecialization())
	local last = NeP.Config:Read('SELECTED', spec)
	for _,v in pairs(DropMenu[2].menuList) do
		v.checked = last == v.name
	end
	NeP.Core:Print(L:TA('mainframe', 'ChangeCR'), last)
end

function NeP.Interface:AddCR_ST(Name)
	table.insert(DropMenu[3].menuList, {
		text = Name,
		notCheckable = 1,
		func = function()
			self:BuildGUI(Name)
		end
	})
end

function NeP.Interface.AddCR(_, ev)
	local text = ev.name..'|cff0F0F0F <->|r ['..ev.wow_ver..'-'..ev.nep_ver..']'
	table.insert(DropMenu[2].menuList, {
		text = text,
		name = ev.name,
		func = function()
			NeP.CR:Set(ev.spec, ev.name)
		end
	})
end

function NeP.Interface.DropMenu()
	EasyMenu(DropMenu, menuFrame, menuFrame, 0, 0, "MENU")
end

function NeP.Interface.Add(_, name, func)
	table.insert(DropMenu, {
		text = tostring(name),
		func = func,
		notCheckable = 1
	})
end

----------------------------EVENTS
NeP.Listener:Add("NeP_CR_interface", "PLAYER_LOGIN", function()
	NeP.Interface.ResetCRs()
end)
NeP.Listener:Add("NeP_CR_interface", "PLAYER_SPECIALIZATION_CHANGED", function(unitID)
	if unitID ~= 'player' then return end
	NeP.Interface:ResetCRs()
end)

NeP.Globals.Interface.Add = NeP.Interface.Add
