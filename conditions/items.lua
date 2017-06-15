local _, NeP = ...

NeP.DSL:Register({'equipped', 'item'}, function(_, item)
  return IsEquippedItem(item)
end)

NeP.DSL:Register('item.count', function(_, item)
  return GetItemCount(item, false, true)
end)

NeP.DSL:Register('twohand', function()
  return IsEquippedItemType("Two-Hand")
end)

NeP.DSL:Register('onehand', function()
  return IsEquippedItemType("One-Hand")
end)

NeP.DSL:Register("ilevel", function()
  return math.floor(select(1,GetAverageItemLevel()))
end)
