local n_name, NeP = ...

NeP.ActionLog = {}

local Data = {}

local log_height = 16
local log_items = 10
local abs_height = log_height * log_items + log_height
local delta = 0

local DiesalGUI = LibStub('DiesalGUI-1.0')

local NeP_AL = NeP.Interface:BuildGUI({
	key = 'NeP_ALFrame',
	width = 460,
	height = abs_height,
	title = '',
	subtitle = ''
})
NeP_AL:Hide()
NeP.Interface:Add('ActionLog', function() NeP_AL:Show() end)

local ActionLogHeader = CreateFrame('Frame', nil, NeP_AL.frame)
ActionLogHeader:SetFrameLevel(92)
ActionLogHeader:SetHeight(log_height)
ActionLogHeader:SetPoint('TOPLEFT', NeP_AL.frame, 'TOPLEFT')
ActionLogHeader:SetPoint('TOPRIGHT', NeP_AL.frame, 'TOPRIGHT')

local headers = {
	{'LEFT', 'Action', 5},
	{'CENTER', 'Description', 0},
	{'RIGHT', 'Time', -25}
}
for i=1, 3 do
	ActionLogHeader.statusTextA = ActionLogHeader:CreateFontString('NeP_ALHeaderText')
	ActionLogHeader.statusTextA:SetFont('Fonts\\ARIALN.TTF', log_height-3)
	ActionLogHeader.statusTextA:SetPoint(headers[i][1], ActionLogHeader, headers[i][3], 0)
	ActionLogHeader.statusTextA:SetText('|cff'..NeP.Color..headers[i][2])
end

NeP_AL.frame:SetScript('OnMouseWheel', function(self, mouse)
	local top = #Data - log_items

	if IsShiftKeyDown() then
		if mouse == 1 then
			delta = top
		elseif mouse == -1 then
			delta = 0
		end
	else
		if mouse == 1 then
			if delta < top then
				delta = delta + mouse
			end
		elseif mouse == -1 then
			if delta > 0 then
				delta = delta + mouse
			end
		end
	end

	NeP.ActionLog:Update()
end)

local LogItem = { }

for i = 1, (log_items) do

	LogItem[i] = CreateFrame('Frame', nil, NeP_AL.frame)
	LogItem[i]:SetFrameLevel(94)
	local texture = LogItem[i]:CreateTexture(nil, 'BACKGROUND')
	texture:SetAllPoints(LogItem[i])

	LogItem[i].texture = texture

	LogItem[i]:SetHeight(log_height)
	LogItem[i]:SetPoint('LEFT', NeP_AL.frame, 'LEFT')
	LogItem[i]:SetPoint('RIGHT', NeP_AL.frame, 'RIGHT')

	LogItem[i].itemA = LogItem[i]:CreateFontString('itemA')
	LogItem[i].itemA:SetFont('Fonts\\ARIALN.TTF', log_height-3)
	LogItem[i].itemA:SetShadowColor(0,0,0, 0.8)
	LogItem[i].itemA:SetShadowOffset(-1,-1)
	LogItem[i].itemA:SetPoint('LEFT', LogItem[i], 5, 0)

	LogItem[i].itemB = LogItem[i]:CreateFontString('itemA')
	LogItem[i].itemB:SetFont('Fonts\\ARIALN.TTF', log_height-3)
	LogItem[i].itemB:SetShadowColor(0,0,0, 0.8)
	LogItem[i].itemB:SetShadowOffset(-1,-1)
	LogItem[i].itemB:SetPoint('LEFT', LogItem[i], 130, 0)

	LogItem[i].itemC = LogItem[i]:CreateFontString('itemA')
	LogItem[i].itemC:SetFont('Fonts\\ARIALN.TTF', log_height-3)
	LogItem[i].itemC:SetShadowColor(0,0,0, 0.8)
	LogItem[i].itemC:SetShadowOffset(-1,-1)
	LogItem[i].itemC:SetPoint('RIGHT', LogItem[i], -5, 0)

	local position = ((i * log_height) * -1)
	LogItem[i]:SetPoint('TOPLEFT', NeP_AL.frame, 'TOPLEFT', 0, position)
end

function NeP.ActionLog:Refresh(type, spell, spellIcon, target)
	if Data[1] and Data[1]['event'] == type
	and Data[1]['description'] == spell
	and Data[1]['target'] == target then
		Data[1]['count'] = Data[1]['count'] + 1
		Data[1]['time'] = date('%H:%M:%S')
		return true
	end
end

function NeP.ActionLog:Add(type, spell, icon, target)
	if not icon or self:Refresh(type, spell, icon, target) then return end
	table.insert(Data, 1, {
		event = type,
		target = target,
		icon = icon,
		description = spell,
		count = 1,
		time = date('%H:%M:%S')
	})
	if delta > 0 and delta < #Data - log_items then
		delta = delta + 1
	end
	self:Update()
end

function NeP.ActionLog:UpdateRow(row, a, b, c)
	LogItem[row].itemA:SetText(a)
	LogItem[row].itemB:SetText(b)
	LogItem[row].itemC:SetText(c)
end

function NeP.ActionLog:Update()
	local offset = 0
	for i = log_items, 1, -1 do
		offset = offset + 1
		local item = Data[offset + delta]
		if not item then
			self:UpdateRow(i, '', '', '')
		else
			local target = item.target and ' |cfffdcc00@|r (' .. item.target .. ')' or ''
			local icon = '|T'..item.icon..':'..(log_height-3)..':'..(log_height-3)..'|t'
			local desc = icon..' '..item.description..target..' [|cfffdcc00x'..item.count..'|r] '
			self:UpdateRow(i, '|cff85888c'..item.event..'|r', desc, '|cff85888c'..item.time..'|r')
		end
	end
end

-- wipe data when we enter combat
NeP.Listener:Add('NeP_AL','PLAYER_REGEN_DISABLED', function(...)
	wipe(Data)
end)