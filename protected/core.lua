local _, NeP = ...

NeP.Protected = {}

local unlockers = {}

function NeP.Protected:AddUnlocker(name, test, functions, extended, om)
	unlockers[name] = {
		name = name,
		test = test,
		functions = functions,
		extended = extended,
		om = om
	}
end

function NeP.Protected.SetUnlocker(name, unlocker)
	NeP.Core:Print('|cffff0000Found:|r ' .. name)
	if unlocker.extended then
		for uname, func in pairs(unlocker.extended) do
			NeP.Protected[uname] = func
		end
	end
	if unlocker.om then
		NeP.OM.Maker = unlocker.om
	end
	for uname, func in pairs(unlocker.functions) do
		NeP.Protected[uname] = func
	end
	NeP.Unlocked = true
end

C_Timer.NewTicker(0.2, (function()
	if NeP.Unlocked or not NeP.DSL:Get('toggle')(nil, 'mastertoggle') then return end
	for name, unlocker in pairs(unlockers) do
		if unlocker.test() then
			NeP.Protected.SetUnlocker(name, unlocker)
			break
		end
	end
end), nil)

NeP.Globals.AddUnlocker = NeP.Protected.AddUnlocker