local _, NeP = ...

NeP.Protected = {}

local unlockers = {}

function NeP.Protected:AddUnlocker(name, test, functions, extended, om)
	table.insert(unlockers, {
		name = name,
		test = test,
		functions = functions,
		extended = extended,
		om = om
	})
end

function NeP.Protected.SetUnlocker(name, unlocker)
	NeP.Core:Print('|cffff0000Found:|r ' .. name)
	for uname, func in pairs(unlocker.functions) do
		NeP.Protected[uname] = func
	end
	if unlocker.extended then
		for uname, func in pairs(unlocker.extended) do
			NeP.Protected[uname] = func
		end
	end
	if unlocker.om then
		NeP.OM.Maker = unlocker.om
	end
	NeP.Unlocked = true
end

C_Timer.After(5, function ()
	C_Timer.NewTicker(0.2, (function()
		if NeP.Unlocked or not NeP.DSL:Get('toggle')(nil, 'mastertoggle') then return end
		for i=1, #unlockers do
			local unlocker = unlockers[i]
			if unlocker.test() then
				NeP.Protected.SetUnlocker(unlocker.name, unlocker)
				break
			end
		end
	end), nil)
end)

NeP.Globals.AddUnlocker = NeP.Protected.AddUnlocker
