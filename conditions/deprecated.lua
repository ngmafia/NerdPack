local _, NeP = ...

NeP.DSL:Register_Deprecated("isself", "is", function(target)
  return NeP.DSL:Get("fury.diff")(target, 'player')
end)

NeP.DSL:Register_Deprecated('furydiff', 'fury.diff', function(target)
  return NeP.DSL:Get("fury.diff")(target)
end)
