local nets = {
  "ClearInvClient",
  "ChangeInvMaxCapClient",
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
  "DropAmmo",
  "MoveAmmoToStorage",
  "MoveAmmoFromStorage",
  "SendAmmoToStorageClient",
  "LootOnClientInitialize",
  "CloseAllMenus",
}

for _, v in ipairs(nets) do
  util.AddNetworkString(v)
end
