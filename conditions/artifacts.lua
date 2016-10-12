local _, NeP = ...
local LAD = LibStub("LibArtifactData-1.0")
--[[
					ARTIFACT CONDITIONS!
			Only submit ARTIFACT specific conditions here.
					KEEP ORGANIZED AND CLEAN!

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
]]

NeP.DSL:Register('artifact.acquired_power', function(artifactID)
  	return LAD.GetAcquiredArtifactPower(artifactID)
end)

NeP.DSL:Register('artifact.active_id', function()
	local artifactID = LAD.GetActiveArtifactID(artifactID)
	return LAD.GetActiveArtifactID()
end)

NeP.DSL:Register('artifact.knowledge', function()
	return select(1,LAD.GetArtifactKnowledge())
end)

NeP.DSL:Register('artifact.power', function(artifactID)
	return select(3,LAD.GetArtifactPower(artifactID))
end)

NeP.DSL:Register('artifact.relics', function(artifactID)
	return LAD.GetArtifactRelics(artifactID)
end)

NeP.DSL:Register('artifact.num_obtained', function()
	return LAD.GetNumObtainedArtifacts()
end)