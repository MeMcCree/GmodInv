Inv = Inv or {}
Inv.Items = Inv.Items or {}
Inv.Capacity = Inv.Capacity or 0
Inv.MaxCapacity = Inv.MaxCapacity or MaxDefInvCap

net.Receive("ClearInvClient", function()
  Inv = {}
  Inv.Items = {}
  Inv.Capacity = 0
  Inv.MaxCapacity = MaxDefInvCap
  if (IsValid(invPnl)) then
      invPnl.itemPnl.ShowItems()
  end
end)

net.Receive("SendItemToClient", function()
  local item = net.ReadTable()
  Inv.Capacity = Inv.Capacity + 1
  Inv.Items[Inv.Capacity] = item

  if (IsValid(invPnl)) then
    invPnl.itemPnl.ShowItems()
  elseif (IsValid(storagePnl)) then
    storagePnl.invItems.ShowItems()
  end
end)

net.Receive("RemoveItemByIdClient", function()
  local id = net.ReadUInt(16)
  if (id < 1 || id > Inv.Capacity) then return end

  Inv.Capacity = Inv.Capacity - 1
  for i = id, Inv.Capacity do
    Inv.Items[i] = Inv.Items[i + 1]
  end
  
  if (IsValid(invPnl)) then
    invPnl.itemPnl.ShowItems()
  elseif (IsValid(storagePnl)) then
    storagePnl.invItems.ShowItems()
  end
end)
