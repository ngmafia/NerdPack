local _, NeP                = ...
NeP.CR                      = {}
NeP.CR.CR                   = {}
local CRs                   = {}
local UnitClass             = UnitClass
local GetSpecialization     = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local noop                  = function() end

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

function NeP.CR:Add(SpecID, ...)
	local classIndex = select(3, UnitClass('player'))
	-- This only allows crs we can use to be registered
	if NeP.ClassTable[classIndex][SpecID] or classIndex == SpecID then

		-- if no table for the spec, create it
		if not CRs[SpecID] then
			CRs[SpecID] = {}
		end

		-- Legacy stuff
		local ev, InCombat, OutCombat, ExeOnLoad, GUI = ...
		if type(...) == 'string' then
			ev = {
				name = ev,
				ic = InCombat,
				ooc = OutCombat,
				load = ExeOnLoad,
				gui = GUI
			}
		else
			ev = ...
		end

		-- do not load cr that dont have names
		if not ev.name then error('Tried to load a CR whitout and name') end

		-- This compiles the CR
		NeP.Compiler:Iterate(ev.ic, ev.name)
		NeP.Compiler:Iterate(ev.ooc, ev.name)

		--Create user GUI
		if ev.gui then NeP.CR:AddGUI(ev.name, ev.gui) end

		-- store some ref to the crs
		CRs[SpecID][ev.name] = {}
		CRs[SpecID][ev.name].Name = ev.name
		CRs[SpecID][ev.name].load = ev.load or noop
		CRs[SpecID][ev.name].unload = ev.unload or noop
		CRs[SpecID][ev.name][true] = ev.ic or {}
		CRs[SpecID][ev.name][false] = ev.ooc or {}
	end
end

function NeP.CR:Set(Spec, Name)
	-- execute the previous unload
	if self.CR.unload then
		self.CR.unload()
	end

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
	self.CR.load()
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
