local name, NeP = ...

NeP.Version = 1.7
NeP.Branch  = 'Release2'
NeP.Media   = 'Interface\\AddOns\\' .. name .. '\\Media\\'
NeP.Color   = 'FFFFFF'

-- This exports stuff into global space
NeP.Globals = {}
_G.NeP = NeP.Globals
