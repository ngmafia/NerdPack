local n_name, NeP = ...

NeP.Config = {}
local Data = {}

NeP.Listener:Add("NeP_Config", "ADDON_LOADED", function(addon)
	if addon:lower() == n_name:lower() then
		NePDATA = NePDATA or {}
		Data = NePDATA
	end
end)

function NeP.Config.Read(_, a, b, default)
	return Data[a] and Data[a][b] or default
end

function NeP.Config.Write(_, a, b, value)
	if not Data[a] then Data[a] = {} end
	Data[a][b] = value
end

function NeP.Config.Rest(_, a)
	Data[a] = nil
end

function NeP.Config.Rest_all()
	wipe(NePDATA)
end