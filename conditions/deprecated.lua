local _, NeP = ...

NeP.DSL:Register("isself", "is", function(target)
  return NeP.DSL:Get("fury.diff")(target, 'player')
end)

NeP.DSL:Register('furydiff', 'fury.diff', function(target)
  return NeP.DSL:Get("fury.diff")(target)
end)
