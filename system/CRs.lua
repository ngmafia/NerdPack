local _, NeP                = ...
NeP.CR                      = {}
NeP.CR.CR                   = {}
local CRs                   = {}
local UnitClass             = UnitClass
local GetSpecialization     = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local noop                  = function() end

function NeP.CR.AddGUI(_, ev)
	local temp = {
		title = ev.name,
		key = ev.name,
		width = 200,
		height = 300,
		config = ev.gui
	}
	NeP.Interface:BuildGUI(temp).parent:Hide()
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

local function add(ev)
	local cr = {}
	cr.name = ev.name
	cr.spec = ev.id
	cr.load = ev.load
	cr.unload = ev.unload
	cr[true] = ev.ic
	cr[false] = ev.ooc
	cr.wow_ver = ev.wow_ver
	cr.nep_ver = ev.nep_ver
	cr.blacklist = ev.blacklist
	cr.blacklist.units = ev.blacklist.units or {}
	cr.blacklist.buff = ev.blacklist.buff or {}
	cr.blacklist.debuff = ev.blacklist.debuff or {}
	CRs[ev.id] = CRs[ev.id] or {}
	CRs[ev.id][ev.name] = cr
end

local function refs(ev, SpecID)
	ev.id = SpecID
	ev.ic = ev.ic or {}
	ev.ooc = ev.ooc or {}
	ev.wow_ver = ev.wow_ver or 0.00
	ev.nep_ver = ev.nep_ver or 0.00
	ev.load = ev.load or noop
	ev.unload = ev.unload or noop
	ev.blacklist = ev.blacklist or {}
	ev.ic = ev.ic or {}
	ev.ic = ev.ic or {}
end

function NeP.CR.Add(_, SpecID, ...)
	local classIndex = select(3, UnitClass('player'))
	-- This only allows crs we can use to be registered
	if classIndex ~= SpecID and not NeP.ClassTable[classIndex][SpecID] then return end
	-- Legacy stuff
	local ev = legacy_PE(...)
	--refs
	refs(ev, SpecID)
	-- Import SpellIDs from the cr
	if ev.ids then
		NeP.Spells:Add(ev.ids)
	end
	-- This compiles the CR
	NeP.Compiler:Iterate(ev.ic, ev.name)
	NeP.Compiler:Iterate(ev.ooc, ev.name)
	--Create user GUI
	if ev.gui then NeP.CR:AddGUI(ev) end
	-- Class Cr (gets added to all specs whitin that clas)
	if classIndex == SpecID then
		SpecID = NeP.ClassTable[classIndex].specs
		for i=1, #SpecID do
			ev.id = SpecID[i]
			add(ev)
		end
		return
	end
	-- normal add
	add(ev)
end

function NeP.CR:Set(Spec, Name)
	Spec = Spec or GetSpecializationInfo(GetSpecialization())
	Name = Name or NeP.Config:Read('SELECTED', Spec)
	-- execute the previous unload
	if self.CR and self.CR.unload then self.CR.unload() end
	self.CR = CRs[Spec][Name]
	NeP.Config:Write('SELECTED', Spec, Name)
	NeP.Interface:ResetToggles()
	--Execute onload
	if self.CR then self.CR.load() end
end

function NeP.CR.GetList(_, Spec)
	return CRs[Spec]
end

----------------------------EVENTS
NeP.Listener:Add("NeP_CR", "PLAYER_LOGIN", function()
	NeP.CR:Set()
end)
NeP.Listener:Add("NeP_CR", "PLAYER_SPECIALIZATION_CHANGED", function(unitID)
	if unitID ~= 'player' then return end
	NeP.CR:Set()
end)

--Globals
NeP.Globals.CR = {
	Add = NeP.CR.Add,
	GetList = NeP.CR.GetList
}
