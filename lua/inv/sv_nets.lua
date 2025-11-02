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
  "SendItemToStorageClient",
  "StorageRemoveItemByIdClient",
  "ChangeStorageMaxCapClient",
  "OpenStorage",
  "MoveToStorage",
  "MoveFromStorage",
  "StorageClosed"
}

for _, v in ipairs(nets) do
  util.AddNetworkString(v)
end
