net.Receive("EmptyListClient", function()
  local id = net.ReadUInt(8)

  if      (id == 1) then InvWhitelist = {}
  elseif  (id == 2) then InvBlacklist = {}
  end
end)

net.Receive("AddToListClient", function()
  local id = net.ReadUInt(8)
  local args = net.ReadTable()

  if      (id == 1) then ParseAddArgs(InvWhitelist, args)
  elseif  (id == 2) then ParseAddArgs(InvBlacklist, args)
  end
end)

net.Receive("RemoveFromListClient", function()
  local id = net.ReadUInt(8)
  local args = net.ReadTable()

  if      (id == 1) then ParseRemoveArgs(InvWhitelist, args)
  elseif  (id == 2) then ParseRemoveArgs(InvBlacklist, args)
  end
end)

hook.Add("Initialize", "LoadListsCl", function()
  InvWhitelist = LoadFile("memccreesinv/whitelist.json")
  InvBlacklist = LoadFile("memccreesinv/blacklist.json")
end)
