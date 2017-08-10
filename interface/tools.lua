local _, NeP          	= ...
NeP.Interface.usedGUIs	= {}
NeP.Globals.Interface 	= {}

-- Locals
local LibStub = LibStub
local unpack = unpack
local DiesalGUI = LibStub("DiesalGUI-1.0")

function NeP.Interface.Noop() end

local _Elements = {
	header    = { func = 'Header', offset = -16 },
	text      = { func = 'Text', offset = 0 },
	rule      = { func = 'Rule', offset = -10 },
	ruler     = { func = 'Rule', offset = -10 },
	texture   = { func = 'Texture', offset = 0 },
	checkbox  = { func = 'Checkbox', offset = -16 },
	spinner   = { func = 'Spinner', offset = -19 },
	checkspin = { func = 'Checkspin', offset = -19 },
	combo     = { func = 'Combo', offset = -20 },
	dropdown  = { func = 'Combo', offset = -20 },
	button    = { func = 'Button', offset = -20 },
	input     = { func = 'Input', offset = -16 },
	spacer    = { func = 'Noop', offset = -10 },
}

local default_profiles = {{key='default',text='Default'}}
local new_prof_Name = "\"New Profile Name\""

local Crt_PrFl_Frame = DiesalGUI:Create('Window')
Crt_PrFl_Frame:SetTitle("Create Profile")
Crt_PrFl_Frame.settings.width = 200
Crt_PrFl_Frame.settings.height = 75
Crt_PrFl_Frame.settings.minWidth = Crt_PrFl_Frame.settings.width
Crt_PrFl_Frame.settings.minHeight = Crt_PrFl_Frame.settings.height
Crt_PrFl_Frame.settings.maxWidth = Crt_PrFl_Frame.settings.width
Crt_PrFl_Frame.settings.maxHeight = Crt_PrFl_Frame.settings.height
Crt_PrFl_Frame:ApplySettings()

local profileInput = DiesalGUI:Create('Input')
Crt_PrFl_Frame:AddChild(profileInput)
profileInput:SetParent(Crt_PrFl_Frame.content)
profileInput:SetPoint("TOPLEFT", Crt_PrFl_Frame.content, "TOPLEFT", 5, -5)
profileInput:SetPoint("BOTTOMRIGHT", Crt_PrFl_Frame.content, "TOPRIGHT", -5, -25)
profileInput:SetText(new_prof_Name)

local profileButton = DiesalGUI:Create('Button')
Crt_PrFl_Frame:AddChild(profileButton)
profileButton:SetParent(Crt_PrFl_Frame.content)
profileButton:SetPoint("TOPLEFT", Crt_PrFl_Frame.content, "TOPLEFT", 5, -30)
profileButton:SetPoint("BOTTOMRIGHT", Crt_PrFl_Frame.content, "TOPRIGHT", -5, -50)
profileButton:SetStylesheet(NeP.Interface.buttonStyleSheet)
profileButton:SetText("Create New Profile")

Crt_PrFl_Frame:Hide()

function NeP.Interface:BuildGUI_New(table, parent)
	local tmp = DiesalGUI:Create('Button')
	parent:AddChild(tmp)
	tmp:SetParent(parent.footer)
	tmp:SetPoint('TOPLEFT',20,0)
	tmp:SetSettings({width = 20, height = 20}, true)
	tmp:SetText('N')
	tmp:SetStylesheet(self.buttonStyleSheet)
	tmp:SetEventListener('OnClick', function()
		Crt_PrFl_Frame:Show()
		profileButton:SetEventListener('OnClick', function()
			local profileName = profileInput:GetText()
			if profileName == '' or profileName == new_prof_Name then return end
			local profiles = NeP.Config:Read(table.key, 'profiles', default_profiles)
			for _,p in ipairs(profiles) do
				if p.key == profileName then
					return profileButton:SetText('Profile with that name exists!')
				end
			end
			_G.table.insert(profiles, {key = profileName, text = profileName})
			NeP.Config:Write(table.key, 'profiles', profiles)
			NeP.Config:Write(table.key, 'profile', profileName)
			Crt_PrFl_Frame:Hide()
			parent:Hide()
			parent:Release()
			NeP.Interface.usedGUIs[table.key] = nil
			NeP.Interface:BuildGUI(table)
			Crt_PrFl_Frame:Hide()
			profileInput:SetText(new_prof_Name)
		end)
	end)
	self.usedGUIs[table.key].elements["prof_new_bt"] = {parent = tmp, type = "Button", style = self.buttonStyleSheet}
end

function NeP.Interface:BuildGUI_Del(table, parent)
	local tmp = DiesalGUI:Create('Button')
	parent:AddChild(tmp)
	tmp:SetParent(parent.footer)
	tmp:SetPoint('TOPLEFT')
	tmp:SetSettings({width = 20, height = 20}, true)
	tmp:SetText('D')
	tmp:SetStylesheet(self.buttonStyleSheet)
	tmp:SetEventListener('OnClick', function()
		local selectedProfile = NeP.Config:Read(table.key, 'profile', 'Default Profile')
		local profiles = NeP.Config:Read(table.key, 'profiles', default_profiles)
		for i,p in ipairs(profiles) do
			if p.key == selectedProfile then
				profiles[i] = nil
				NeP.Config:Write(table.key, 'profiles', profiles)
				NeP.Config:Write(table.key, 'profile', 'default')
				parent:Hide()
				parent:Release()
				NeP.Interface.usedGUIs[table.key] = nil
				NeP.Interface:BuildGUI(table)
			end
		end
	end)
	self.usedGUIs[table.key].elements["prof_del_bt"] = {parent = tmp, type = "Button", style = self.buttonStyleSheet}
end

function NeP.Interface:BuildGUI_Combo(table, parent)
		local profiles = NeP.Config:Read(table.key, 'profiles', default_profiles)
		local selectedProfile = NeP.Config:Read(table.key, 'slctd_profile', 'default')
		local dropdown = DiesalGUI:Create('Dropdown')
		parent:AddChild(dropdown)
		dropdown:SetParent(parent.footer)
		dropdown:SetPoint("TOPRIGHT", parent.footer, "TOPRIGHT", 0, 0)
		dropdown:SetPoint("BOTTOMLEFT", parent.footer, "BOTTOMLEFT", 40, 0)
		local orderdKeys = {}
		local list = {}
		for i, value in pairs(profiles) do
			orderdKeys[i] = value.key
			list[value.key] = value.text
		end
		dropdown:SetList(list, orderdKeys)
		dropdown:SetEventListener('OnValueChanged', function(_,_, value)
			if selectedProfile == value then return end
			NeP.Config:Write(table.key, 'slctd_profile', value)
			parent:Hide()
			parent:Release()
			self.usedGUIs[table.key] = nil
			self:BuildGUI(table)
		end)
		dropdown:SetValue(selectedProfile)
end

function NeP.Interface:BuildElements(table, parent)
	local offset = -5
	for _, element in ipairs(table.config) do
		local push, pull = 0, 0

		-- Create defaults
		if element.key and not NeP.Config:Read(table.key, element.key) then
			if element.default then
				NeP.Config:Write(table.key, element.key, element.default)
			elseif element.default_check then
				NeP.Config:Write(table.key, element.key, element.default_check)
				NeP.Config:Write(table.key, element.key, element.default_Spin)
			end
		end

		--build element
		if _Elements[element.type] then
			element.key = element.key or "fake"
			element.table_color = table.color
			local tmp, style = self[_Elements[element.type].func](self, element, parent, offset, table)
			offset = offset + _Elements[element.type].offset
			self.usedGUIs[table.key].elements[element.key] = {parent = tmp, type = element.type, style = style}
		end

		--offsetS
		if element.type == 'texture' then
			offset = offset + -(element.offset or 0)
		elseif element.type == "text" then
			offset = offset + -(element.offset) - (element.size or 10)
		end
    if element.push then
      push = push + element.push
      offset = offset + -(push)
    end
    if element.pull then
      pull = pull + element.pull
      offset = offset + pull
    end

	end
end

function NeP.Interface:GetElement(key, element)
	return self.usedGUIs[key].elements[element].parent
end

function NeP.Interface.Body(_, eval, parent)
	local left, top = unpack(NeP.Config:Read(eval.key, 'Location', {500, 500}))
	parent.settings.left = left
	parent.settings.top = top
	parent:UpdatePosition()

	--Colors
	if not eval.color then eval.color = NeP.Color end
	if type(eval.color) == 'function' then eval.color = eval.color() end

	if eval.title then
		parent:SetTitle("|cff"..eval.color..eval.title.."|r", eval.subtitle)
	end
	if eval.config then
		local window = DiesalGUI:Create('ScrollFrame')
		parent:AddChild(window)
		window:SetParent(parent.content)
		window:SetAllPoints(parent.content)
		NeP.Interface:BuildElements(eval, window)
	end
end

-- This opens a existing GUI instead of creating another
function NeP.Interface:TestCreated(table)
	local test = type(table) == 'string' and table or table.key
	if self.usedGUIs[test] then
		self.usedGUIs[test].parent:Show()
		return self.usedGUIs[test]
	end
end

function NeP.Interface.BuildGUI(_, table)
	local self = NeP.Interface
	--Tests
	local gui_test = self:TestCreated(table)
	if gui_test then return gui_test end
	if not table.key then return end

	-- Create a new parent
	local parent = DiesalGUI:Create('Window')
	self.usedGUIs[table.key] = {}
	self.usedGUIs[table.key].parent = parent
	self.usedGUIs[table.key].elements = {}

	parent:SetWidth(table.width or 200)
	parent:SetHeight(table.height or 300)
	parent.frame:SetClampedToScreen(true)
	parent:SetStylesheet(self.WindowStyleSheet)

	--Save Location after dragging
	parent:SetEventListener('OnDragStop', function(_,_, left, top)
		NeP.Config:Write(table.key, 'Location', {left, top})
	end)

	-- Only build the body after we'r done loading configs
	NeP.Core:WhenInGame(function()
		self:Body(table, parent)
		if table.profiles then
			parent.settings.footer = true
			self:BuildGUI_Combo(table, parent)
			self:BuildGUI_Del(table, parent)
			self:BuildGUI_New(table, parent)
			parent:ApplySettings()
		end
	end)

	return self.usedGUIs[table.key]
end

-- Gobals
NeP.Globals.Interface = {
	BuildGUI = NeP.Interface.BuildGUI,
	Fetch = NeP.Config.Read,
	GetElement = NeP.Interface.GetElement
}
