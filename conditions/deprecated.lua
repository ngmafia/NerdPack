local _, NeP = ...

NeP.DSL:Register("isself" function(target)
  return self:Get("is")(target, 'player')
end)

NeP.DSL:Register('furydiff', function(target)
  return self:Get("fury.diff")(target)
end)
