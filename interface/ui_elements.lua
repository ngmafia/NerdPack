local _, NeP          = ...

-- Locals
local LibStub     = LibStub
local strupper    = strupper
local CreateFrame = CreateFrame

local DiesalGUI   = LibStub("DiesalGUI-1.0")
local DiesalTools = LibStub("DiesalTools-1.0")
local SharedMedia = LibStub("LibSharedMedia-3.0")

function NeP.Interface:Header(element, parent, offset, table)
	local tmp = DiesalGUI:Create("FontString")
	tmp:SetParent(parent.content)
	parent:AddChild(tmp)
	tmp = tmp.fontString
	tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
	tmp:SetText('|cff'..table.color..element.text)
	if element.justify then
		tmp:SetJustifyH(element.justify)
	else
		tmp:SetJustifyH('LEFT')
	end
	tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 13)
	tmp:SetWidth(parent.content:GetWidth()-10)
	if element.align then
		tmp:SetJustifyH(strupper(element.align))
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key] = tmp
	end
end

function NeP.Interface:Text(element, parent, offset, table)
	local tmp = DiesalGUI:Create("FontString")
	tmp:SetParent(parent.content)
	parent:AddChild(tmp)
	tmp = tmp.fontString
	tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
	tmp:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	tmp:SetText(element.text)
	tmp:SetJustifyH('LEFT')
	tmp:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), element.size or 10)
	tmp:SetWidth(parent.content:GetWidth()-10)
	if not element.offset then
		element.offset = tmp:GetStringHeight()
	end
	if element.align then
		tmp:SetJustifyH(strupper(element.align))
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key] = tmp
	end
end

function NeP.Interface:Rule(element, parent, offset, table)
	local tmp = DiesalGUI:Create('Rule')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp.frame:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5, offset-3)
	tmp.frame:SetPoint('BOTTOMRIGHT', parent.content, 'BOTTOMRIGHT', -5, offset-3)
	if element.key then
		self.usedGUIs[table.key].elements[element.key] = tmp
	end
end

function NeP.Interface:Texture(element, parent, offset, table)
	local tmp = CreateFrame('Frame')
	tmp:SetParent(parent.content)
	if element.center then
		tmp:SetPoint('CENTER', parent.content, 'CENTER', (element.x or 0), offset-(element.y or 0))
	else
		tmp:SetPoint('TOPLEFT', parent.content, 'TOPLEFT', 5+(element.x or 0), offset-3+(element.y or 0))
	end
	tmp:SetWidth(parent:GetWidth()-10)
	tmp:SetHeight(element.height)
	tmp:SetWidth(element.width)
	tmp.texture = tmp:CreateTexture()
	tmp.texture:SetTexture(element.texture)
	tmp.texture:SetAllPoints(tmp)
	if element.key then
		self.usedGUIs[table.key].elements[element.key] = tmp
	end
end

function NeP.Interface:Checkbox(element, parent, offset, table)
	local tmp = DiesalGUI:Create('CheckBox')
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset)
	tmp:SetEventListener('OnValueChanged', function(_, _, checked)
		NeP.Config:Write(table.key, element.key, checked)
	end)
	tmp:SetChecked(NeP.Config:Read(table.key, element.key, element.default or false))
	local tmp_text = DiesalGUI:Create("FontString")
	tmp_text:SetParent(parent.content)
	parent:AddChild(tmp_text)
	tmp_text = tmp_text.fontString
	tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 20, offset-1)
	tmp_text:SetText(element.text)
	tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
	if element.desc then
		local tmp_desc = DiesalGUI:Create("FontString")
		tmp_desc:SetParent(parent.content)
		parent:AddChild(tmp_desc)
		tmp_desc = tmp_desc.fontString
		tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-15)
		tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-15)
		tmp_desc:SetText(element.desc)
		tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
		tmp_desc:SetWidth(parent.content:GetWidth()-10)
		tmp_desc:SetJustifyH('LEFT')
		element.push = tmp_desc:GetStringHeight() + 5
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
		self.usedGUIs[table.key].elements[element.key] = tmp
	end
end

function NeP.Interface:Spinner(element, parent, offset, table)
	local tmp_spin = DiesalGUI:Create('Spinner')
	parent:AddChild(tmp_spin)
	tmp_spin:SetParent(parent.content)
	tmp_spin:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	tmp_spin:SetNumber(
		NeP.Config:Read(table.key, element.key, element.default)
	)
	if element.width then
		tmp_spin.settings.width = element.width
	end
	if element.min then
		tmp_spin.settings.min = element.min
	end
	if element.max then
		tmp_spin.settings.max = element.max
	end
	if element.step then
		tmp_spin.settings.step = element.step
	end
	if element.shiftStep then
		tmp_spin.settings.shiftStep = element.shiftStep
	end
	tmp_spin:ApplySettings()
	tmp_spin:SetStylesheet(self.spinnerStyleSheet)
	tmp_spin:SetEventListener('OnValueChanged', function(_, _, userInput, number)
		if not userInput then return end
		NeP.Config:Write(table.key, element.key, number)
	end)
	local tmp_text = DiesalGUI:Create("FontString")
	tmp_text:SetParent(parent.content)
	parent:AddChild(tmp_text)
	tmp_text = tmp_text.fontString
	tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-4)
	tmp_text:SetText(element.text)
	tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
	tmp_text:SetJustifyH('LEFT')
	tmp_text:SetWidth(parent.content:GetWidth()-10)
	if element.desc then
		local tmp_desc = DiesalGUI:Create("FontString")
		tmp_desc:SetParent(parent.content)
		parent:AddChild(tmp_desc)
		tmp_desc = tmp_desc.fontString
		tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
		tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
		tmp_desc:SetText(element.desc)
		tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
		tmp_desc:SetWidth(parent.content:GetWidth()-10)
		tmp_desc:SetJustifyH('LEFT')
		element.push = tmp_desc:GetStringHeight() + 5
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
		self.usedGUIs[table.key].elements[element.key] = tmp_spin
	end
end

function NeP.Interface:Checkspin(element, parent, offset, table)
	local tmp_spin = DiesalGUI:Create('Spinner')
	parent:AddChild(tmp_spin)
	tmp_spin:SetParent(parent.content)
	tmp_spin:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	if element.width then
		tmp_spin.settings.width = element.width
	end
	if element.min then
		tmp_spin.settings.min = element.min
	end
	if element.max then
		tmp_spin.settings.max = element.max
	end
	if element.step then
		tmp_spin.settings.step = element.step
	end
	if element.shiftStep then
		tmp_spin.settings.shiftStep = element.shiftStep
	end
	tmp_spin:SetNumber(
		NeP.Config:Read(table.key, element.key..'_spin', element.default_spin or 0)
	)
	tmp_spin:SetStylesheet(self.spinnerStyleSheet)
	tmp_spin:ApplySettings()
	tmp_spin:SetEventListener('OnValueChanged', function(_, _, userInput, number)
		if not userInput then return end
		NeP.Config:Write(table.key, element.key..'_spin', number)
	end)
	local tmp_check = DiesalGUI:Create('CheckBox')
	parent:AddChild(tmp_check)
	tmp_check:SetParent(parent.content)
	tmp_check:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-2)
	tmp_check:SetEventListener('OnValueChanged', function(_, _, checked)
		NeP.Config:Write(table.key, element.key..'_check', checked)
	end)
	tmp_check:SetChecked(NeP.Config:Read(table.key, element.key..'_check', element.default_check or false))
	local tmp_text = DiesalGUI:Create("FontString")
	tmp_text:SetParent(parent.content)
	parent:AddChild(tmp_text)
	tmp_text = tmp_text.fontString
	tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 20, offset-4)
	tmp_text:SetText(element.text)
	tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
	tmp_text:SetJustifyH('LEFT')
	tmp_text:SetWidth(parent.content:GetWidth()-10)
	if element.desc then
		local tmp_desc = DiesalGUI:Create("FontString")
		tmp_desc:SetParent(parent.content)
		parent:AddChild(tmp_desc)
		tmp_desc = tmp_desc.fontString
		tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
		tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
		tmp_desc:SetText(element.desc)
		tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
		tmp_desc:SetWidth(parent.content:GetWidth()-10)
		tmp_desc:SetJustifyH('LEFT')
		element.push = tmp_desc:GetStringHeight() + 5
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
		self.usedGUIs[table.key].elements[element.key..'Check'] = tmp_check
		self.usedGUIs[table.key].elements[element.key..'Spin'] = tmp_spin
	end
end

function NeP.Interface:Combo(element, parent, offset, table)
	local tmp_list = DiesalGUI:Create('Dropdown')
	parent:AddChild(tmp_list)
	tmp_list:SetParent(parent.content)
	tmp_list:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	local orderdKeys = { }
	local list = { }
	for i, value in pairs(element.list) do
		orderdKeys[i] = value.key
		list[value.key] = value.text
	end
	tmp_list:SetList(list, orderdKeys)
	tmp_list:SetEventListener('OnValueChanged', function(_, _, value)
		NeP.Config:Write(table.key, element.key, value)
	end)
	tmp_list:SetValue(NeP.Config:Read(table.key, element.key, element.default))
	local tmp_text = DiesalGUI:Create("FontString")
	tmp_text:SetParent(parent.content)
	parent:AddChild(tmp_text)
	tmp_text = tmp_text.fontString
	tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-3)
	tmp_text:SetText(element.text)
	tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
	tmp_text:SetJustifyH('LEFT')
	tmp_text:SetWidth(parent.content:GetWidth()-10)
	if element.desc then
		local tmp_desc = DiesalGUI:Create("FontString")
		tmp_desc:SetParent(parent.content)
		parent:AddChild(tmp_desc)
		tmp_desc = tmp_desc.fontString
		tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
		tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
		tmp_desc:SetText(element.desc)
		tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
		tmp_desc:SetWidth(parent.content:GetWidth()-10)
		tmp_desc:SetJustifyH('LEFT')
		element.push = tmp_desc:GetStringHeight() + 5
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
		self.usedGUIs[table.key].elements[element.key] = tmp_list
	end
end

function NeP.Interface:Button(element, parent, offset, table)
	local tmp = DiesalGUI:Create("Button")
	parent:AddChild(tmp)
	tmp:SetParent(parent.content)
	tmp:SetText(element.text)
	tmp:SetWidth(element.width or parent.content:GetWidth()-10)
	tmp:SetHeight(element.height or 20)
	tmp:SetStylesheet(self.buttonStyleSheet)
	tmp:SetEventListener("OnClick", element.callback)
	if element.desc then
		local tmp_desc = DiesalGUI:Create("FontString")
		tmp_desc:SetParent(parent.content)
		parent:AddChild(tmp_desc)
		tmp_desc = tmp_desc.fontString
		tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-element.height-3)
		tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-element.height-3)
		tmp_desc:SetText(element.desc)
		tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
		tmp_desc:SetWidth(parent.content:GetWidth()-10)
		tmp_desc:SetJustifyH('LEFT')
		element.push = tmp_desc:GetStringHeight() + 5
	end
	if element.align then
		local loc = element.align
		tmp:SetPoint(loc, parent.content, 0, offset)
	else
		tmp:SetPoint("TOP", parent.content, 0, offset)
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key] = tmp
	end
end

function NeP.Interface:Input(element, parent, offset, table)
	local tmp_input = DiesalGUI:Create('Input')
	parent:AddChild(tmp_input)
	tmp_input:SetParent(parent.content)
	tmp_input:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset)
	if element.width then
		tmp_input:SetWidth(element.width)
	end
	tmp_input:SetText(NeP.Config:Read(table.key, element.key, element.default or ''))
	tmp_input:SetEventListener('OnEditFocusLost', function(this)
		NeP.Config:Write(table.key, element.key, this:GetText())
	end)
	local tmp_text = DiesalGUI:Create("FontString")
	tmp_text:SetParent(parent.content)
	parent:AddChild(tmp_text)
	tmp_text = tmp_text.fontString
	tmp_text:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-3)
	tmp_text:SetText(element.text)
	tmp_text:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 10)
	tmp_text:SetJustifyH('LEFT')
	if element.desc then
		local tmp_desc = DiesalGUI:Create("FontString")
		tmp_desc:SetParent(parent.content)
		parent:AddChild(tmp_desc)
		tmp_desc = tmp_desc.fontString
		tmp_desc:SetPoint("TOPLEFT", parent.content, "TOPLEFT", 5, offset-18)
		tmp_desc:SetPoint("TOPRIGHT", parent.content, "TOPRIGHT", -5, offset-18)
		tmp_desc:SetText(element.desc)
		tmp_desc:SetFont(SharedMedia:Fetch('font', 'Calibri Bold'), 9)
		tmp_desc:SetWidth(parent.content:GetWidth()-10)
		tmp_desc:SetJustifyH('LEFT')
		element.push = tmp_desc:GetStringHeight() + 5
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key..'Text'] = tmp_text
		self.usedGUIs[table.key].elements[element.key] = tmp_input
	end
end

function NeP.Interface:Statusbar(element, parent, _, table)
	local tmp_statusbar = DiesalGUI:Create('StatusBar')
	parent:AddChild(tmp_statusbar)
	tmp_statusbar:SetParent(parent.content)
	tmp_statusbar.frame:SetStatusBarColor(DiesalTools:GetColor(element.color))
	if element.value then
		tmp_statusbar:SetValue(element.value)
	end
	if element.textLeft then
		tmp_statusbar.frame.Left:SetText(element.textLeft)
	end
	if element.textRight then
		tmp_statusbar.frame.Right:SetText(element.textRight)
	end
	if element.key then
		self.usedGUIs[table.key].elements[element.key] = tmp_statusbar
	end
end
