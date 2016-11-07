local _, NeP                = ...
local GetNumSpecializations = GetNumSpecializations
local GetTalentInfo         = GetTalentInfo
local GetActiveSpecGroup    = GetActiveSpecGroup
local GetTalentInfoByID     = GetTalentInfoByID

local talents = {}
local rows = 7
local cols = 3

local function UpdateTalents()
	-- this is always 1, dont know why bother but oh well...
	local spec = GetActiveSpecGroup()
	for i = 1, rows do
		for k = 1, cols do
			local talent_ID, talent_name = GetTalentInfo(i, k, spec)
			talents[talent_name] = talent_ID
			talents[talent_ID] = talent_ID
			talents[tostring(i)..','..tostring(k)] = talent_ID
		end
	end
end

NeP.Listener:Add('NeP_Talents', 'ACTIVE_TALENT_GROUP_CHANGED', function()
	UpdateTalents()
end)

NeP.Listener:Add('NeP_Talents', 'PLAYER_ENTERING_WORLD', function()
	UpdateTalents()
end)

NeP.DSL:Register("talent", function(_, args)
	return select(10, GetTalentInfoByID(talents[args], GetActiveSpecGroup()))
end)
