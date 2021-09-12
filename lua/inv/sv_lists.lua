local function EmptyListClient(id)
    net.Start("EmptyListClient")
        net.WriteUInt(id, 8)
    net.Broadcast()
end

local function AddToListClient(id, args)
    net.Start("AddToListClient")
        net.WriteUInt(id, 8)
        net.WriteTable(args)
    net.Broadcast()
end

local function RemoveFromListClient(id, args)
    net.Start("RemoveFromListClient")
        net.WriteUInt(id, 8)
        net.WriteTable(args)
    net.Broadcast()
end

concommand.Add("inv_whitelist_add", function(ply, cmd, args)
    ParseAddArgs(InvWhitelist, args)
    AddToListClient(1, args)
end)

concommand.Add("inv_blacklist_add", function(ply, cmd, args)
  ParseAddArgs(InvWhitelist, args)
  AddToListClient(2, args)
end)

concommand.Add("inv_whitelist_remove", function(ply, cmd, args)
  ParseRemoveArgs(InvWhitelist, args)
  RemoveFromListClient(1, args)
end)

concommand.Add("inv_blacklist_remove", function(ply, cmd, args)
  ParseRemoveArgs(InvWhitelist, args)
  RemoveFromListClient(2, args)
end)

concommand.Add("inv_whitelist_empty", function(ply, cmd, args)
  InvWhitelist = {}
  EmptyListClient(1)
end)

concommand.Add("inv_blacklist_empty", function(ply, cmd, args)
  InvBlacklist = {}
  EmptyListClient(2)
end)

hook.Add("Initialize", "LoadLists", function()
  InvWhitelist = LoadFile("memccreesinv/whitelist.json")
  InvBlacklist = LoadFile("memccreesinv/blacklist.json")
end)
