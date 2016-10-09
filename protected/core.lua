local _, NeP = ...

NeP.Protected = {}

local unlockers = {}

function NeP.Protected:AddUnlocker(name, test, functions, extended)
	unlockers[name] = {
		name = name,
		test = test,
		functions = functions,
		extended = extended
	}
end

C_Timer.NewTicker(1, (function()
	if NeP.unlocked then return end
	for name, unlocker in pairs(unlockers) do
		if unlocker.test() then
			NeP.Core:Print('|cffff0000Found:|r ' .. name)
			-- Extras
			if unlocker.extended then
				for name, func in pairs(unlocker.extended) do
					NeP.Protected[name] = fn
				end
			end
			-- Basic here
			for name, func in pairs(unlocker.functions) do
				NeP.Protected[name] = func
			end
			NeP.unlocked = true
			break
		end
	end
end), nil)

NeP.Globals.Protected = NeP.Protected