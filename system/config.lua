local n_name, NeP = ...

NeP.Config = {}
local Data;

NeP.Listener:Add("NeP_Config", "ADDON_LOADED", function(addon)
	if addon:lower() == n_name:lower() then
		NePDAT = NePDATA or {}
		Data = NePDATA
	end
end)

function NeP.Config.Read(_, a, b, default)
	-- only return default if its nil in data
	if Data[a] and Data[a][b] ~= nil then
		return Data[a][b]
	end
	return default
end

function NeP.Config.Write(_, a, b, value)
	if not Data[a] then
		Data[a] = {}
	end
	Data[a][b] = value
end
