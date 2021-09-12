local nets = {
  "ClearInvClient",
  "SendItemToClient",
  "RemoveItemById",
  "RemoveItemByIdClient",
  "DropItem",
  "UseItem",
  "EmptyListClient",
  "AddToListClient",
  "RemoveFromListClient",
}

for _, v in ipairs(nets) do
  util.AddNetworkString(v)
end
