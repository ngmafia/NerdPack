local _, NeP                = ...
NeP.CR                      = {}
NeP.CR.CR                   = {}
local CRs                   = {}
local UnitClass             = UnitClass
local GetSpecialization     = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local noop                  = function() end

function NeP.CR.AddGUI(_, key, eval)
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

local function legacy_PE(...)
	local ev, InCombat, OutCombat, ExeOnLoad, GUI = ...
	if type(...) == 'string' then
		return {
			name = ev,
			ic = InCombat,
			ooc = OutCombat,
			load = ExeOnLoad,
			gui = GUI
		}
	else
		return ...
	end
end

function NeP.CR.Add(_, SpecID, ...)
	local classIndex = select(3, UnitClass('player'))
	-- This only allows crs we can use to be registered
	if classIndex ~= SpecID and not NeP.ClassTable[classIndex][SpecID] then return end

	-- if no table for the spec, create it
	if not CRs[SpecID] then CRs[SpecID] = {} end

	-- Legacy stuff
	local ev = legacy_PE(...)

	-- do not load cr that dont have names
	if not ev.name then return end
	if CRs[SpecID][ev.name] then return end

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

	--Blacklists
	ev.blacklist = ev.blacklist or {}
	CRs[SpecID][ev.name].blacklist = ev.blacklist
	CRs[SpecID][ev.name].blacklist.units = ev.blacklist.units or {}
	CRs[SpecID][ev.name].blacklist.buff = ev.blacklist.buff or {}
	CRs[SpecID][ev.name].blacklist.debuff = ev.blacklist.debuff or {}
end

function NeP.CR:Set(Spec, Name)
	-- execute the previous unload
	if self.CR and self.CR.unload then self.CR.unload() end

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

	--Execute onload
	if self.CR then self.CR.load() end
end

function NeP.CR.GetList(_, Spec)
	local result = {}
	local classIndex = select(3, UnitClass('player'))
	-- Specs
	if CRs[Spec] then
		for k in pairs(CRs[Spec]) do
			print(k)
			result[#result+1] = k
		end
	end
	-- Class
	if CRs[classIndex] then
		for k in pairs(CRs[classIndex]) do
			result[#result+1] = k
		end
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
	local spec = GetSpecializationInfo(GetSpecialization())
	local last = NeP.Config:Read('SELECTED', spec)
	BuildCRs(spec, last)
	if CRs[spec] and CRs[spec][last] then
		NeP.CR:Set(spec, last)
	end
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
	Add = NeP.CR.Add,
	GetList = NeP.CR.GetList
}
