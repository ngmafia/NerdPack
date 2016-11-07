local _, NeP                = ...
local GetNumSpecializations = GetNumSpecializations
local GetTalentInfo         = GetTalentInfo
local GetActiveSpecGroup    = GetActiveSpecGroup
local GetTalentInfoByID     = GetTalentInfoByID

local talents = {}

NeP.Listener:Add('NeP_Talents', 'PLAYER_ENTERING_WORLD', function()
	for spec =1, GetNumSpecializations() do
		for i=1, 7 do
			for k=1,3 do
				local talent_name = select(2, GetTalentInfo(i, k))
				local talent_ID = GetTalentInfo(i,k,spec)
				talents[spec][talent_name] = talent_ID
				talents[spec][talent_ID] = talent_ID
				talents[spec][tostring(i)..','..tostring(k)] = talent_ID
			end
		end
	end
end)

NeP.DSL:Register("talent", function(_, args)
	local spec = GetActiveSpecGroup()
	local _,_,_, selected, available = GetTalentInfoByID(talents[spec][args], spec)
	return selected and available
end)
