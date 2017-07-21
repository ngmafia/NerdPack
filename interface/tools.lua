local _, NeP          	= ...
NeP.Interface.usedGUIs	= {}
NeP.Globals.Interface 	= {}

-- Locals
local LibStub     = LibStub
local unpack 			= unpack
local DiesalGUI   = LibStub("DiesalGUI-1.0")

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

function NeP.Interface:BuildElements(table, parent)
	local offset = -5
	self.usedGUIs[table.key].elements = {}
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
		if _Elements[element.type] then
			local func = _Elements[element.type].func
			local _offset = _Elements[element.type].offset
			self[func](self, element, parent, offset, table)
			offset = offset + _offset
		end
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
	return self.usedGUIs[key].elements[element]
end

function NeP.Interface:Body(eval, parent)
	local left, top = unpack(NeP.Config:Read(eval.key, 'Location', {500, 500}))
	parent.settings.left = left
	parent.settings.top = top
	parent:UpdatePosition()
	if not eval.color then eval.color = NeP.Color end
	if type(eval.color) == 'function' then eval.color = eval.color() end
	self.spinnerStyleSheet['bar-background']['color'] = eval.color
	if eval.title then
		parent:SetTitle("|cff"..eval.color..eval.title.."|r", eval.subtitle)
	end
	if eval.config then
		local window = DiesalGUI:Create('ScrollFrame')
		parent:AddChild(window)
		window:SetParent(parent.content)
		window:SetAllPoints(parent.content)
		window.elements = { }
		eval.window = window
		NeP.Interface:BuildElements(eval, window)
	end
end

-- This opens a existing GUI instead of creating another
function NeP.Interface:TestCreated(eval)
	local test = type(eval) == 'string' and eval or eval.key
	if self.usedGUIs[test] then
		self.usedGUIs[test].parent:Show()
		return self.usedGUIs[test].parent
	end
end

function NeP.Interface:BuildGUI(eval)

	--Tests
	local gui_test = NeP.Interface:TestCreated(eval)
	if gui_test then return gui_test end
	if not eval.key then return end

	-- Create a new parent
	NeP.Interface.usedGUIs[eval.key] = {}
	local parent = DiesalGUI:Create('Window')
	NeP.Interface.usedGUIs[eval.key].parent = parent
	parent:SetWidth(eval.width or 200)
	parent:SetHeight(eval.height or 300)
	parent.frame:SetClampedToScreen(true)

	--Save Location after dragging
	parent:SetEventListener('OnDragStop', function(_,_, left, top)
		NeP.Config:Write(eval.key, 'Location', {left, top})
	end)

	-- Only build the body after we'r done loading configs
	NeP.Core:WhenInGame(function()
		NeP.Interface:Body(eval, parent)
	end)

	return parent
end

-- Gobals
NeP.Globals.Interface = {
	BuildGUI = NeP.Interface.BuildGUI,
	Fetch = NeP.Config.Read,
	GetElement = NeP.Interface.GetElement
}
