hook.Add("PlayerSpawn", "LoadInv", function(ply)
  if (not ply.Inv) then
    if (ConVars["SaveInv"]:GetBool()) then
      ply:LoadInv()
    else
      ply:InitInv()
    end
  elseif (not ConVars["KeepInv"]:GetBool()) then
    ply:InitInv()
  end
end)

hook.Add("PlayerDisconnected", "SaveInvOnDisconnect", function(ply)
  if (ConVars["SaveInv"]:GetBool()) then
    ply:SaveInv()
  end
end)

hook.Add("ShutDown", "SaveInvOnShutDown", function()
  if (ConVars["SaveInv"]:GetBool()) then
    local filePath
    file.CreateDir("memccreesinv/userdata")
    for _, ply in ipairs(player.GetAll()) do
      filePath = "memccreesinv/userdata/u_" .. ply:AccountID() .. ".json"
      SaveFile(filePath, ply.Inv)
    end
  end
end)


concommand.Add("inv_pickup", function(ply)
  ply:PickupItem()
end)

net.Receive("DropItem", function(len, ply)
  local id = net.ReadUInt(16)
  ply:DropItem(id, 80)
end)

net.Receive("UseItem", function(len, ply)
  local id = net.ReadUInt(16)
  ply:UseItem(id, 40)
end)