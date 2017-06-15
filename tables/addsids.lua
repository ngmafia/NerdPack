local _, NeP       = ...
NeP.AddsID         = {}
NeP.Globals.BossID = NeP.AddsID
local strsplit     = strsplit
local UnitExists   = UnitExists
local UnitGUID     = UnitGUID

--AddsIDs Lib
local addsids = {}

function NeP.BossID:Add(...)
  if type(...) == 'table' then
    for id in pairs(...) do
      id = tonumber(id)
      if id then
        addsids[id] = true
      end
    end
  else
    local id = tonumber(...)
    if id then
      addsids[id] = true
    end
  end
end

function NeP.BossID:Eval(unit)
  if tonumber(unit) then
    return addsids[tonumber(unit)]
  elseif UnitExists(unit) then
    unit = select(6, strsplit("-", UnitGUID(unit)))
    return addsids[tonumber(unit)]
  end
end

NeP.AddsID:Add({
  -- Shadowmoon Burial Grounds
	[75966] = true,	-- Defiled Spirit (Shadowmoon Burial Grounds)
  [76518] = true,	-- Ritual of Bones (Shadowmoon Burial Grounds)
  --(BRF Oregorger
	[77252] = true,	-- Ore Crate (BRF Oregorger)
	[77665] = true,	-- Iron Bomber (BRF Blackhand)
	[77891] = true,	-- Grasping Earth (BRF Kromog)
	[77893] = true,	-- Grasping Earth (BRF Kromog)
	[86752] = true,	-- Stone Pillars (BRF Mythic Kromog)
	[78583] = true,	-- Dominator Turret (BRF Iron Maidens)
	[78584] = true,	-- Dominator Turret (BRF Iron Maidens)
	[79504] = true,	-- Ore Crate (BRF Oregorger)
  --...
	[79511] = true,	-- Blazing Trickster (Auchindoun Heroic)
  [76220] = true,	-- Blazing Trickster (Auchindoun Normal)
	[81638] = true,	-- Aqueous Globule (The Everbloom)
	[86644] = true,	-- Ore Crate (BRF Oregorger)
	[76222] = true,	-- Rallying Banner (UBRS Black Iron Grunt)
	[76267] = true,	-- Solar Zealot (Skyreach)
  --HFC
	[94873] = true,	-- Felfire Flamebelcher (HFC)
	[90432] = true,	-- Felfire Flamebelcher (HFC)
	[95586] = true,	-- Felfire Demolisher (HFC)
	[93851] = true,	-- Felfire Crusher (HFC)
	[90410] = true,	-- Felfire Crusher (HFC)
	[94840] = true,	-- Felfire Artillery (HFC)
	[90485] = true,	-- Felfire Artillery (HFC)
	[93435] = true,	-- Felfire Transporter (HFC)
	[93717] = true,	-- Volatile Firebomb (HFC)
	[188293] = true,	-- Reinforced Firebomb (HFC)
	[94865] = true,	-- Grasping Hand (HFC)
	[93838] = true,	-- Grasping Hand (HFC)
	[93839] = true,	-- Dragging Hand (HFC)
	[91368] = true,	-- Crushing Hand (HFC)
	[94455] = true,	-- Blademaster Jubei'thos (HFC)
	[90387] = true,	-- Shadowy Construct (HFC)
	[90508] = true,	-- Gorebound Construct (HFC)
	[90568] = true,	-- Gorebound Essence (HFC)
	[94996] = true,	-- Fragment of the Crone (HFC)
	[95656] = true,	-- Carrion Swarm (HFC)
	[91540] = true,	-- Illusionary Outcast (HFC)
})
