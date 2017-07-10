local _, NeP  = ...
local C_Timer = C_Timer

NeP.Protected = {}

local unlockers = {}

function NeP.Protected:AddUnlocker(name, test, functions, extended, om, prio)
	table.insert(unlockers, {
		name = name,
		test = test,
		functions = functions,
		extended = extended,
		om = om;
		prio = prio or 0
	})
	table.sort( unlockers, function(a,b) return a.prio > b.prio end )
end

function NeP.Protected.SetUnlocker(name, unlocker)
	NeP.Core:Print('|cffff0000Found:|r ' .. name, '\nRemember to /reload after attaching a unlocker!')
	for uname, func in pairs(unlocker.functions) do
		NeP.Protected[uname] = func
	end
	if unlocker.extended then
		for uname, func in pairs(unlocker.extended) do
			NeP.Protected[uname] = func
		end
	end
	if unlocker.om then
		NeP.AdvancedOM = true
		NeP.OM.Maker = unlocker.om
	end
	NeP.Unlocked = true
end

C_Timer.After(5, function ()
	C_Timer.NewTicker(0.2, function(self)
		if not NeP.DSL:Get('toggle')(nil, 'mastertoggle') then return end
		for i=1, #unlockers do
			local unlocker = unlockers[i]
			if unlocker.test() then
				NeP.Protected.SetUnlocker(unlocker.name, unlocker)
				self:Cancel()
				break
			end
		end
	end, nil)
end)

NeP.Globals.AddUnlocker = NeP.Protected.AddUnlocker
NeP.Globals.AdvancedOM = NeP.AdvancedOM
