local _, NeP = ...

-- Lowest
NeP.FakeUnits:Add('lowest', function(num, role)
	local tempTable = {}
	for GUID, Obj in pairs(NeP.Healing:GetRoster()) do
		if not role or (role and Obj.role == role:upper()) then
			tempTable[#tempTable+1] = {
				key = Obj.key,
				prio = prio
			}
		end
	end
	return tempTable[num] and tempTable[num].key
end)