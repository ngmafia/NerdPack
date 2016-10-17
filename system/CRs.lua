local _, NeP = ...

NeP.CR = {}
NeP.CR.CR = {}

local CRs = {}
local UnitClass = UnitClass

function NeP.CR:AddGUI(key, eval)
	local temp = {
		title = key,
		key = key,
		width = 200,
		height = 300,
		config = eval
	}
	NeP.Interface:BuildGUI(temp):Hide()
	NeP.Interface:AddCR_ST(key)
end

function NeP.CR:Add(SpecID, Name, InCombat, OutCombat, ExeOnLoad, GUI)
	local classIndex = select(3, UnitClass('player'))
	if NeP.ClassTable[classIndex][SpecID] or classIndex == SpecID then
		if not CRs[SpecID] then
			CRs[SpecID] = {}
		end

		-- This compiles the CR
		NeP.Compiler:Iterate(InCombat, Name)
		NeP.Compiler:Iterate(OutCombat, Name)

		--Create user GUI
		if GUI then NeP.CR:AddGUI(Name, GUI) end

		CRs[SpecID][Name] = {}
		CRs[SpecID][Name].Name = Name
		CRs[SpecID][Name].Exe = ExeOnLoad
		CRs[SpecID][Name][true] = InCombat
		CRs[SpecID][Name][false] = OutCombat
	end
end

function NeP.CR:Set(Spec, Name)
	local _, englishClass, classIndex  = UnitClass('player')
	local a, b = englishClass:sub(1, 1):upper(), englishClass:sub(2):lower()
	local classCR = '[NeP] '..a..b..' - Basic'
	if not CRs[Spec][Name] then
		Name = classCR
		Spec = classIndex
	end
	self.CR = CRs[Spec][Name]
	NeP.Config:Write('SELECTED', Spec, Name)
	NeP.Interface:SetCheckedCR(Name)
	NeP.Interface:ResetToggles()
	if self.CR.Exe then
		self.CR.Exe()
	end
end

function NeP.CR:GetList(Spec)
	local result = {}
	local classIndex = select(3, UnitClass('player'))
	if CRs[Spec] then
		for k in pairs(CRs[Spec]) do
			result[#result+1] = k
		end
	end
	for k in pairs(CRs[classIndex]) do
		result[#result+1] = k
	end
	return result
end

local function BuildCRs(Spec, Last)
	local CrList = NeP.CR:GetList(Spec)
	for i=1, #CrList do
		local Name = CrList[i]
		NeP.Interface:AddCR(Spec, Name, (Name == Last))
	end
end

local function SetCR()
	local Spec = GetSpecializationInfo(GetSpecialization())
	local englishClass  = select(2, UnitClass('player'))
	local a, b = englishClass:sub(1, 1):upper(), englishClass:sub(2):lower()
	local classCR = '[NeP] '..a..b..' - Basic'
	local last = NeP.Config:Read('SELECTED', Spec, classCR)
	BuildCRs(Spec, last)
	NeP.CR:Set(Spec, last)
end

NeP.Listener:Add("NeP_CR", "PLAYER_LOGIN", function()
	SetCR()
	NeP.Spells:Filter()
end)

NeP.Listener:Add("NeP_CR", "PLAYER_SPECIALIZATION_CHANGED", function(unitID)
	if unitID ~= 'player' then return end
	NeP.Interface:ResetCRs()
	SetCR()
end)

--Globals
NeP.Globals.CR = {
	Add = NeP.CR.Add
}