--[[

local Keys = {}

local bt = CreateFrame("CheckButton", 'NeP_KeyListener', UIParent)
bt:EnableKeyboard(true)
bt:EnableMouse(true)
bt:EnableMouseWheel(true)
bt:RegisterForClicks("AnyUp", "AnyDown")
bt:SetScript("OnClick", function(self, key)
	print(key)
end)]]