local _, NeP = ...

NeP.Protected.Cast = function(spell, target)
	NeP.Faceroll:Set(spell, target)
end

NeP.Protected.CastGround = function(spell, target)
	NeP.Faceroll:Set(spell, target)
end

NeP.Protected.Macro = function(text)
end

NeP.Protected.UseItem = function(name, target)
end

NeP.Protected.UseInvItem = function(name)
end

local rangeCheck = LibStub("LibRangeCheck-2.0")
NeP.Protected.Distance = function (a, b)
	if UnitExists(b) then
		local minRange, maxRange = rangeCheck:GetRange(b)
		return maxRange or minRange
	end
	return 0
end

NeP.Protected.Infront = function (a, b)
	return true
end

NeP.Protected.UnitCombatRange = NeP.Protected.Distance

NeP.Protected.LineOfSight = function (a, b)
	return true
end

local ValidUnits = {'player', 'mouseover', 'target', 'arena1', 'arena2'}
C_Timer.NewTicker(1, (function()
	-- If in Group scan frames...
	if IsInGroup() or IsInRaid() then
		local prefix = (IsInRaid() and 'raid') or 'party'
		for i = 1, GetNumGroupMembers() do
			-- Unit
			local friendly = prefix..i
			if GenericFilter(friendly) then
				NeP.OM:Add(friendly)
				-- Unit's Target
				local target = friendly..'target'
				NeP.OM:Add(target)
			end
		end
	end
	-- Valid Units
	for i=1, #ValidUnits do
		local object = ValidUnits[i]
		NeP.OM:Add(object)
	end
end), nil)