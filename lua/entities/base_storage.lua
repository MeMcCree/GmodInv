AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Spawnable = false

ENT.Model = "models/items/item_item_crate.mdl"

function ENT:SetupDataTables()
  self:NetworkVar("String", 0, "StorageName",
  {
    KeyName = "storage_name",
    Edit = {type = "Generic", title = "Name of the storage", order = 0}
  })
  self:NetworkVar("String", 1, "StorageModel",
  {
    KeyName = "storage_model",
    Edit = {type = "Generic", title = "Model", order = 1, waitforenter = true}
  })
  self:NetworkVar("String", 2, "Lootlist",
  {
    KeyName = "storage_lootlist",
    Edit = {type = "Generic", title = "Lootlist", order = 2}
  })
  
  self:NetworkVar("Int", "StorageSound",
  {
    KeyName = "storage_sound",
    Edit = {type = "Combo", title = "Storage sounds", order = 3, text = "Wooden box", values = {
      ["Wooden box"] = 0,
      ["Metal drawer"] = 1,
      -- ...
    }}
  })

  self:NetworkVar("Int", "StorageBackground",
  {
    KeyName = "storage_uibackground",
    Edit = {type = "Combo", title = "Storage theme", order = 4, text = "Wooden box", values = {
      ["Wooden box"] = 0,
      ["Metal drawer"] = 1,
      -- ...
    }}
  })
  
  self:NetworkVar("Int", "MaxCapacity",
  {
    KeyName = "storage_maxcapacity",
    Edit = {type = "Int", title = "Max capacity", order = 5, min = 1, max = 1000}
  })
  
  if (SERVER) then
    self:SetMaxCapacity(20)
    self:NetworkVarNotify("MaxCapacity", self.MaxCapacityChanged)
    self:NetworkVarNotify("StorageModel", self.StorageModelChanged)
  else
    self:NetworkVarNotify("MaxCapacity", self.MaxCapacityChanged)
  end
end

if (SERVER) then
  function ENT:Initialize()
      self:SetModel(self.Model)
      self:PhysicsInit(SOLID_VPHYSICS)
      self:SetMoveType(MOVETYPE_VPHYSICS)
      self:SetSolid(SOLID_VPHYSICS)

      local phys = self:GetPhysicsObject()
      if (IsValid(phys)) then
        phys:Wake()
      end

      self.Storage = {}
      self.Storage.Items = {}
      self.Storage.Capacity = 0
      self.Storage.MaxCapacity = 999
      self.IsUsed = false
  end

  function ENT:Use(activator)
    if (!activator:IsPlayer() || self.IsUsed) then return end
    // self.IsUsed = true
    self:OpenStorage(activator)
  end

  function ENT:MaxCapacityChanged(name, old, new)
    self.Storage.MaxCapacity = new
  end

  function ENT:StorageModelChanged(name, old, new)
    if (IsUselessModel(new)) then return end
    self:SetModel(new)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if (IsValid(phys)) then
      phys:Wake()
    end
  end

  function ENT:SetStorage(storage)
      self.Storage = storage
      self:SendEachItemToStorageClient(item)
      self:SetMaxCapacity(storage.MaxCapacity)
  end

  function ENT:SendEachItemToStorageClient(item)
    for i = 1, self.Storage.Capacity do
      self:SendItemToStorageClient(self.Storage.Items[i])
    end
  end

  function ENT:SendItemToStorageClient(item)
    net.Start("SendItemToStorageClient")
      net.WriteEntity(self)
      net.WriteTable(item)
    net.Broadcast()
  end

  function ENT:RemoveItemByIdClient(id)
    net.Start("StorageRemoveItemByIdClient")
      net.WriteEntity(self)
      net.WriteUInt(id, 16)
    net.Broadcast()
  end

  function ENT:OpenStorage(user)
    net.Start("OpenStorage")
      net.WriteEntity(self)
    net.Send(user)
  end

  function ENT:AddItem(item)
    self.Storage.Capacity = self.Storage.Capacity + 1
    self.Storage.Items[self.Storage.Capacity] = item
  end

  function ENT:RemoveItemById(id)
    if (id < 1 || id > self.Storage.Capacity) then return end

    self.Storage.Capacity = self.Storage.Capacity - 1
    for i = id, self.Storage.Capacity do
      self.Storage.Items[i] = self.Storage.Items[i + 1]
    end
  end

  function ENT:MoveToStorage(ply, id)
    if (self.Storage.Capacity + 1 > self.Storage.MaxCapacity) then return end
    local item = ply.Inv.Items[id]
    ply:RemoveItemById(id)
    ply:RemoveItemByIdClient(id)

    self:AddItem(item)
    self:SendItemToStorageClient(item)
  end

  function ENT:MoveFromStorage(ply, id)
    if (ply.Inv.Capacity + 1 > ply.Inv.MaxCapacity) then return end
    local item = self.Storage.Items[id]
    self:RemoveItemById(id)
    self:RemoveItemByIdClient(id)

    ply:AddItem(item)
    ply:SendItemToClient(item)
  end

  net.Receive("MoveToStorage", function(len, ply)
    local storage = net.ReadEntity()
    local id = net.ReadUInt(16)
    storage:MoveToStorage(ply, id)
  end)

  net.Receive("MoveFromStorage", function(len, ply)
    local storage = net.ReadEntity()
    local id = net.ReadUInt(16)
    storage:MoveFromStorage(ply, id)
  end)

  net.Receive("StorageClosed", function(len, ply)
  end)
else
  function ENT:Initialize()
      self.Storage = {}
      self.Storage.Items = {}
      self.Storage.Capacity = 0
      self.Storage.MaxCapacity = MaxDefInvCap
      self.IsUsed = false
  end

  function ENT:Draw()
    self:DrawModel()
  end

  function ENT:OpenStorage()
    if (IsValid(storagePnl)) then return end
    
    storagePnl = vgui.Create("inv_frame")
    storagePnl.Owner = self
    storagePnl:SetSize(ScrW() / 1.5, ScrH() / 1.25)
    storagePnl:Center()
    storagePnl:SetTitle("")
    storagePnl:MakePopup()

    storagePnl.invItems = storagePnl:Add("item_pnl")
    storagePnl.invItems:Dock(LEFT)
    storagePnl.invItems:SetWide(ScrW() / 3)
    storagePnl.invItems.title = storagePnl.invItems:Add("DLabel")
    storagePnl.invItems.title:Dock(TOP)
    storagePnl.invItems.title:SetFont("inv_Title")
    storagePnl.invItems.title:SetTextColor(InvUI.Colors.Text)
    storagePnl.invItems.title:SetText("Inventory")
    storagePnl.invItems.title:SizeToContents()
    storagePnl.invItems.title:SetContentAlignment(5)

    storagePnl.invItems.divider = storagePnl.invItems:Add("DPanel")
    storagePnl.invItems.divider:Dock(RIGHT)
    storagePnl.invItems.divider:SetWide(2)
    storagePnl.invItems.divider.Paint = function(pnl, w, h)
      draw.RoundedBox(32, 0, 0, w, h - 32, InvUI.Colors.ItemColor)
    end

    storagePnl.storageItems = storagePnl:Add("item_pnl")
    storagePnl.storageItems:Dock(RIGHT)
    storagePnl.storageItems:SetWide(ScrW() / 3)
    storagePnl.storageItems.title = storagePnl.storageItems:Add("DLabel")
    storagePnl.storageItems.title:Dock(TOP)
    storagePnl.storageItems.title:SetFont("inv_Title")
    storagePnl.storageItems.title:SetTextColor(InvUI.Colors.Text)
    storagePnl.storageItems.title:SetText(self:GetStorageName())
    storagePnl.storageItems.title:SizeToContents()
    storagePnl.storageItems.title:SetContentAlignment(5)

    storagePnl.storageItems.divider = storagePnl.storageItems:Add("DPanel")
    storagePnl.storageItems.divider:Dock(LEFT)
    storagePnl.storageItems.divider:SetWide(2)
    storagePnl.storageItems.divider.Paint = function(pnl, w, h)
      draw.RoundedBox(32, 0, 0, w, h - 32, InvUI.Colors.ItemColor)
    end

    storagePnl.invItems.ShowItems = function()
      storagePnl.invItems.icons:Clear()
      storagePnl.invItems.icons:InvalidateLayout(true)

      for i = 1, Inv.Capacity do
        local item = Inv.Items[i]
        local itemPnl = storagePnl.invItems.icons:Add("DButton")

        itemPnl:SetSize(ScrH() / 10, ScrH() / 10)
        itemPnl.Paint = function(pnl, w, h)
          draw.RoundedBox(0, 0, 0, w, h, InvUI.Colors.ItemColor)
          surface.SetDrawColor(InvUI.Colors.Primary.r,
                               InvUI.Colors.Primary.g,
                               InvUI.Colors.Primary.b,
                               255)
          surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        itemPnl.icon = itemPnl:Add("SpawnIcon")
        itemPnl.icon:Dock(FILL)
        itemPnl.icon:SetModel(item.model)
        itemPnl.icon:SetTooltip(nil)

        itemPnl.icon.OnMousePressed = function(pnl, keyCode)
          if (self.Storage.Capacity + 1 > self.Storage.MaxCapacity) then return end
          if (TimedAction.active) then return end

          if (keyCode == MOUSE_LEFT or keyCode == MOUSE_RIGHT) then
            TimedAction.Start(0.5, function()
              net.Start("MoveToStorage")
                net.WriteEntity(self)
                net.WriteUInt(i, 16)
              net.SendToServer()
            end)

            itemPnl.icon.bar = itemPnl.icon:Add("progress_bar")
            itemPnl.icon.bar:Dock(FILL)
            itemPnl.icon.label:Remove()
          end
        end

        itemPnl.icon.label = itemPnl.icon:Add("DLabel")
        itemPnl.icon.label:Dock(BOTTOM)
        itemPnl.icon.label:SetTall(18)
        itemPnl.icon.label:SetText(item.name)
        itemPnl.icon.label:SetFont("inv_ItemName")
        itemPnl.icon.label:SetTextColor(InvUI.Colors.Text)
        itemPnl.icon.label:SetContentAlignment(5)

      end
    end

    storagePnl.storageItems.ShowItems = function()
      storagePnl.storageItems.icons:Clear()
      storagePnl.storageItems.icons:InvalidateLayout(true)

      for i = 1, self.Storage.Capacity do
        local item = self.Storage.Items[i]
        local itemPnl = storagePnl.storageItems.icons:Add("DPanel")

        itemPnl:SetSize(ScrH() / 10, ScrH() / 9.5)
        itemPnl.Paint = function(pnl, w, h)
          draw.RoundedBox(0, 0, 0, w, h, InvUI.Colors.ItemColor)
          surface.SetDrawColor(InvUI.Colors.Primary.r,
                               InvUI.Colors.Primary.g,
                               InvUI.Colors.Primary.b,
                               255)
          surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        itemPnl.icon = itemPnl:Add("SpawnIcon")
        itemPnl.icon:Dock(FILL)
        itemPnl.icon:SetModel(item.model)
        itemPnl.icon:SetTooltip(nil)

        itemPnl.icon.OnMousePressed = function(pnl, keyCode)
          if (Inv.Capacity + 1 > Inv.MaxCapacity) then return end
          if (TimedAction.active) then return end

          if (keyCode == MOUSE_LEFT or keyCode == MOUSE_RIGHT) then
            TimedAction.Start(0.5, function()
              net.Start("MoveFromStorage")
                net.WriteEntity(self)
                net.WriteUInt(i, 16)
              net.SendToServer()
            end)

            itemPnl.icon.bar = itemPnl.icon:Add("progress_bar")
            itemPnl.icon.bar:Dock(FILL)
            itemPnl.icon.label:Remove()
          end
        end

        itemPnl.icon.label = itemPnl.icon:Add("DLabel")
        itemPnl.icon.label:Dock(BOTTOM)
        itemPnl.icon.label:SetTall(18)
        itemPnl.icon.label:SetText(item.name)
        itemPnl.icon.label:SetFont("inv_ItemName")
        itemPnl.icon.label:SetTextColor(InvUI.Colors.Text)
        itemPnl.icon.label:SetContentAlignment(5)
      end
    end

    storagePnl.invItems.ShowItems()
    storagePnl.storageItems.ShowItems()

    storagePnl.OnRemove = function(pnl)
      net.Start("StorageClosed")
        net.WriteEntity(pnl.Owner)
      net.SendToServer()
    end
  end

  function ENT:MaxCapacityChanged(name, old, new)
    self.Storage.MaxCapacity = new
    if (IsValid(storagePnl)) then
      storagePnl.storageItems.ShowItems()
    end
  end

  net.Receive("OpenStorage", function()
    local storage = net.ReadEntity()
    storage:OpenStorage()
  end)

  net.Receive("SendItemToStorageClient", function()
    local storage = net.ReadEntity()
    local item = net.ReadTable()

    storage.Storage.Capacity = storage.Storage.Capacity + 1
    storage.Storage.Items[storage.Storage.Capacity] = item

    if (IsValid(storagePnl)) then
      storagePnl.storageItems.ShowItems()
    end
  end)

  net.Receive("StorageRemoveItemByIdClient", function()
    local storage = net.ReadEntity()
    local id = net.ReadUInt(16)
    if (id < 1 || id > storage.Storage.Capacity) then return end

    storage.Storage.Capacity = storage.Storage.Capacity - 1
    for i = id, storage.Storage.Capacity do
      storage.Storage.Items[i] = storage.Storage.Items[i + 1]
    end

    if (IsValid(storagePnl)) then
      storagePnl.storageItems.ShowItems()
    end
  end)
end
