local n_name, NeP = ...

NeP.Protected.Cast = function(spell, target)
	NeP.Faceroll:Set(spell, target)
end

NeP.Protected.CastGround = function(spell, target)
	NeP.Faceroll:Set(spell, target)
end

NeP.Protected.Macro = function()
end

NeP.Protected.UseItem = function()
end

NeP.Protected.UseInvItem = function()
end

local rangeCheck = LibStub("LibRangeCheck-2.0")
NeP.Protected.Distance = function(_, b)
	local minRange, maxRange = rangeCheck:GetRange(b)
	return maxRange or minRange
end

NeP.Protected.Infront = function(_,b)
	return NeP.Helpers:Infront(b)
end

NeP.Protected.UnitCombatRange = function(_,b)
	local minRange = rangeCheck:GetRange(b)
	return minRange
end

NeP.Protected.LineOfSight = function(_,b)
	return NeP.Helpers:Infront(b)
end

local ValidUnits = {'player', 'mouseover', 'target', 'arena1', 'arena2'}
NeP.OM.Maker = function()
		-- If in Group scan frames...
	if IsInGroup() or IsInRaid() then
		local prefix = (IsInRaid() and 'raid') or 'party'
		for i = 1, GetNumGroupMembers() do
			-- Unit
			local friendly = prefix..i
			NeP.OM:Add(friendly)
			-- Unit's Target
			local target = friendly..'target'
			NeP.OM:Add(target)
		end
	end
	-- Valid Units
	for i=1, #ValidUnits do
		local object = ValidUnits[i]
		NeP.OM:Add(object)
	end
end

-- Dont load this for 7.1 or up
local version = GetBuildInfo()
if not version:find('^7.0') then return end

local lnr = LibStub("AceAddon-3.0"):NewAddon(n_name, "LibNameplateRegistry-1.0")

function lnr:OnEnable()
	self:LNR_RegisterCallback("LNR_ON_NEW_PLATE")
	self:LNR_RegisterCallback("LNR_ON_RECYCLE_PLATE")
end

function lnr:LNR_ON_NEW_PLATE(_, _, plateData)
	NeP.OM:Add(plateData.unitToken)
end

function lnr:LNR_ON_RECYCLE_PLATE()
	NeP.OM:Garbage()
end