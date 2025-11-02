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

function TimedActionThink()
  if (not TimedAction.active) then return end
  if (CurTime() < TimedAction.endTime) then return end

  if (TimedAction.action != nil) then
    TimedAction.action()
    TimedAction.active = false
  end
end

TimedAction = TimedAction or {}
TimedAction.startTime = TimedAction.startTime or 0
TimedAction.endTime = TimedAction.endTime or 0
TimedAction.action = TimedAction.action or nil
TimedAction.active = TimedAction.active or false
TimedAction.Start = function(delay, action)
  TimedAction.startTime = CurTime()
  TimedAction.endTime = TimedAction.startTime + delay
  TimedAction.active = true
  TimedAction.action = action
end

hook.Add("Think", "TimedActionThink", TimedActionThink)