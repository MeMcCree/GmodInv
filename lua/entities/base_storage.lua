AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Spawnable = false

ENT.Model = "models/items/item_item_crate.mdl"

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
      self.Storage.Ammo = {}
      self.Storage.Items = {}
      self.Storage.Capacity = 0
      self.Storage.MaxCapacity = MaxDefInvCap
      self.TempStorage = nil
      self.TempAmmo = nil
  end

  function ENT:Use(activator)
    if (!activator:IsPlayer()) then return end
    self:OpenStorage(activator)
  end

  function ENT:SetStorage(storage)
      self.Storage = storage
      self:SendEachItemToStorageClient()
      self:ChangeStorageMaxCapClient(self.Storage.MaxCapacity)
  end

  function ENT:SetAmmo(ammo)
    self.Storage.Ammo = ammo
    self:SendEachAmmoTypeToStorageClient()
  end

  function ENT:SendEachAmmoTypeToStorageClient()
    for ammoId, amount in pairs(self.Storage.Ammo) do
      self:SendAmmoTypeToStorageClient(ammoId, amount)
    end
  end

  function ENT:SendAmmoTypeToStorageClient(ammoId, amount)
    net.Start("SendAmmoToStorageClient")
      net.WriteEntity(self)
      net.WriteUInt(ammoId, 8)
      net.WriteUInt(amount, 16)
    net.Broadcast()
  end

  function ENT:SendEachItemToStorageClient()
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

  function ENT:ChangeStorageMaxCapClient(capacity)
    net.Start("ChangeStorageMaxCapClient")
      net.WriteEntity(self)
      net.WriteUInt(capacity, 16)
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
    table.remove(self.Storage.Items, id)
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

  function ENT:MoveAmmoToStorage(ply, ammoId, amount)
    ply:RemoveAmmo(amount, ammoId)
    if (self.Storage.Ammo[ammoId] == nil) then
      self.Storage.Ammo[ammoId] = 0
    end
    self.Storage.Ammo[ammoId] = self.Storage.Ammo[ammoId] + amount
    self:SendAmmoTypeToStorageClient(ammoId, self.Storage.Ammo[ammoId])
  end

  function ENT:MoveAmmoFromStorage(ply, ammoId, amount)
    ply:GiveAmmo(amount, ammoId)
    self.Storage.Ammo[ammoId] = self.Storage.Ammo[ammoId] - amount
    self:SendAmmoTypeToStorageClient(ammoId, self.Storage.Ammo[ammoId])
    if (self.Storage.Ammo[ammoId] <= 0) then
      self.Storage.Ammo[ammoId] = nil
    end
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

  net.Receive("MoveAmmoToStorage", function(len, ply)
    local storage = net.ReadEntity()
    local ammoId = net.ReadUInt(8)
    local amount = net.ReadUInt(16)
    storage:MoveAmmoToStorage(ply, ammoId, amount)
  end)

  net.Receive("MoveAmmoFromStorage", function(len, ply)
    local storage = net.ReadEntity()
    local ammoId = net.ReadUInt(8)
    local amount = net.ReadUInt(16)
    storage:MoveAmmoFromStorage(ply, ammoId, amount)
  end)

  net.Receive("LootOnClientInitialize", function(len, ply)
    local storage = net.ReadEntity()
    if (storage.TempStorage != nil and storage.TempAmmo != nil) then
      storage:SetStorage(storage.TempStorage)
      storage:SetAmmo(storage.TempAmmo)
      storage.TempStorage = nil
      storage.TempAmmo = nil
    end
  end)
else
  function ENT:Initialize()
      self.Storage = {}
      self.Storage.Ammo = {}
      self.Storage.Items = {}
      self.Storage.Capacity = 0
      self.Storage.MaxCapacity = MaxDefInvCap
      self.IsUsed = false
      net.Start("LootOnClientInitialize")
        net.WriteEntity(self)
      net.SendToServer()
  end

  function ENT:Draw()
    self:DrawModel()
  end

  function ENT:OpenStorage()
    if (IsValid(storagePnl)) then return end
    storagePnl = vgui.Create("inv_frame")
    storagePnl.Owner = self
    storagePnl:SetSize(8 + ScrW() / 3 + 16 + ScrW() / 3 + 8, 32 + 32 + ScrW() / 3 + 32 + ScrW() / 6 + 32 + 16)
    storagePnl:Center()
    storagePnl:SetTitle("")
    storagePnl:MakePopup()

    storagePnl.titles = storagePnl:Add("DPanel")
    storagePnl.titles:SetSize(storagePnl:GetWide() - 16, 32)
    storagePnl.titles:SetPos(8, 32)
    storagePnl.titles.Paint = nil

    storagePnl.titles.invTitle = storagePnl.titles:Add("DLabel")
    storagePnl.titles.invTitle:Dock(LEFT)
    storagePnl.titles.invTitle:SetWide(storagePnl.titles:GetWide() / 2)
    storagePnl.titles.invTitle:SetFont("inv_Misc")
    storagePnl.titles.invTitle:SetTextColor(InvUI.Colors.Text)
    storagePnl.titles.invTitle:SetText("Inventory")
    storagePnl.titles.invTitle:SetContentAlignment(5)

    storagePnl.titles.storageTitle = storagePnl.titles:Add("DLabel")
    storagePnl.titles.storageTitle:Dock(RIGHT)
    storagePnl.titles.storageTitle:SetWide(storagePnl.titles:GetWide() / 2)
    storagePnl.titles.storageTitle:SetFont("inv_Misc")
    storagePnl.titles.storageTitle:SetTextColor(InvUI.Colors.Text)
    storagePnl.titles.storageTitle:SetText("Storage")
    storagePnl.titles.storageTitle:SetContentAlignment(5)

    storagePnl.invItems = storagePnl:Add("item_pnl")
    storagePnl.invItems:SetSize(ScrW() / 3, ScrW() / 3 + 32)
    storagePnl.invItems:SetPos(8, 32 + 32)
    storagePnl.invItems.addPanelsCustomize = function()
      for _, itemPnl in ipairs(storagePnl.invItems.panels) do
        itemPnl.btnBar.moveToBtn = itemPnl.btnBar:Add("DButton")
        itemPnl.btnBar.moveToBtn:Dock(FILL)
        itemPnl.btnBar.moveToBtn:SetFont("inv_Misc")
        itemPnl.btnBar.moveToBtn:SetText("Move to")
        itemPnl.btnBar.moveToBtn:SetTextColor(InvUI.Colors.Text)
        itemPnl.btnBar.moveToBtn.Paint = nil
        itemPnl.btnBar.moveToBtn.DoClick = function(pnl)
          if (not IsValid(self)) then storagePnl:Remove() end
          net.Start("MoveToStorage")
            net.WriteEntity(self)
            net.WriteUInt(itemPnl.idx, 16)
          net.SendToServer()
        end
      end
    end

    storagePnl.storageItems = storagePnl:Add("item_pnl")
    storagePnl.storageItems:SetSize(ScrW() / 3, ScrW() / 3 + 32)
    storagePnl.storageItems:SetPos(8 + ScrW() / 3 + 16, 32 + 32)
    storagePnl.storageItems.addPanelsCustomize = function()
      for _, itemPnl in ipairs(storagePnl.storageItems.panels) do
        itemPnl.btnBar.takeBtn = itemPnl.btnBar:Add("DButton")
        itemPnl.btnBar.takeBtn:Dock(FILL)
        itemPnl.btnBar.takeBtn:SetFont("inv_Misc")
        itemPnl.btnBar.takeBtn:SetText("Take")
        itemPnl.btnBar.takeBtn:SetTextColor(InvUI.Colors.Text)
        itemPnl.btnBar.takeBtn.Paint = nil
        itemPnl.btnBar.takeBtn.DoClick = function(pnl)
          if (not IsValid(self)) then storagePnl:Remove() end
          net.Start("MoveFromStorage")
            net.WriteEntity(self)
            net.WriteUInt(itemPnl.idx, 16)
          net.SendToServer()
        end
      end
    end

    storagePnl.invAmmo = storagePnl:Add("ammo_pnl")
    storagePnl.invAmmo:SetSize(ScrW() / 3, ScrW() / 6 + 32)
    storagePnl.invAmmo:SetPos(8, 32 + 32 + ScrW() / 3 + 32)
    storagePnl.invAmmo.layoutSideways = true
    storagePnl.invAmmo.plammo = LocalPlayer():GetAmmo()
    storagePnl.invAmmo.addPanelsCustomize = function()
      for _, ammoPnl in ipairs(storagePnl.invAmmo.panels) do
        ammoPnl.btnBar.moveAllBtn:SetText("Move all")
        ammoPnl.btnBar.moveBtn:SetText("Move some")
  
        ammoPnl.btnBar.moveAllBtn.DoClick = function()
          if (not IsValid(self)) then
            storagePnl:Remove()
            return
          end
          net.Start("MoveAmmoToStorage")
            net.WriteEntity(self)
            net.WriteUInt(ammoPnl.ammoId, 8)
            net.WriteUInt(storagePnl.invAmmo.plammo[ammoPnl.ammoId], 16)
          net.SendToServer()
          storagePnl.invAmmo.plammo[ammoPnl.ammoId] = nil
          storagePnl.invAmmo.ShowAmmo()
        end
  
        ammoPnl.btnBar.moveBtn.DoClick = function()
          if (not IsValid(self)) then
            storagePnl:Remove()
            return
          end
          local ammoToDrop = tonumber(ammoPnl.numSliderArea.ammoToDrop:GetText())
          net.Start("MoveAmmoToStorage")
            net.WriteEntity(self)
            net.WriteUInt(ammoPnl.ammoId, 8)
            net.WriteUInt(ammoToDrop, 16)
          net.SendToServer()
          storagePnl.invAmmo.plammo[ammoPnl.ammoId] = storagePnl.invAmmo.plammo[ammoPnl.ammoId] - ammoToDrop
          if (storagePnl.invAmmo.plammo[ammoPnl.ammoId] <= 0) then
            storagePnl.invAmmo.plammo[ammoPnl.ammoId] = nil
          end
          storagePnl.invAmmo.ShowAmmo()
        end
      end
    end

    storagePnl.storageAmmo = storagePnl:Add("ammo_pnl")
    storagePnl.storageAmmo:SetSize(ScrW() / 3, ScrW() / 6 + 32)
    storagePnl.storageAmmo:SetPos(8 + ScrW() / 3 + 16, 32 + 32 + ScrW() / 3 + 32)
    storagePnl.storageAmmo.layoutSideways = true
    storagePnl.storageAmmo.addPanelsCustomize = function()
      for _, ammoPnl in ipairs(storagePnl.storageAmmo.panels) do
        ammoPnl.btnBar.moveAllBtn:SetText("Move all")
        ammoPnl.btnBar.moveBtn:SetText("Move some")
  
        ammoPnl.btnBar.moveAllBtn.DoClick = function()
          if (not IsValid(self)) then
            storagePnl:Remove()
            return
          end
          local ammoToMove = self.Storage.Ammo[ammoPnl.ammoId]
          net.Start("MoveAmmoFromStorage")
            net.WriteEntity(self)
            net.WriteUInt(ammoPnl.ammoId, 8)
            net.WriteUInt(ammoToMove, 16)
          net.SendToServer()
          if (storagePnl.invAmmo.plammo[ammoPnl.ammoId] == nil) then
            storagePnl.invAmmo.plammo[ammoPnl.ammoId] = 0
          end
          storagePnl.invAmmo.plammo[ammoPnl.ammoId] = storagePnl.invAmmo.plammo[ammoPnl.ammoId] + ammoToMove
          storagePnl.invAmmo.ShowAmmo()
        end
  
        ammoPnl.btnBar.moveBtn.DoClick = function()
          if (not IsValid(self)) then
            storagePnl:Remove()
            return
          end
          local ammoToMove = tonumber(ammoPnl.numSliderArea.ammoToDrop:GetText())
          net.Start("MoveAmmoFromStorage")
            net.WriteEntity(self)
            net.WriteUInt(ammoPnl.ammoId, 8)
            net.WriteUInt(ammoToMove, 16)
          net.SendToServer()
          storagePnl.invAmmo.plammo[ammoPnl.ammoId] = storagePnl.invAmmo.plammo[ammoPnl.ammoId] + ammoToMove
          storagePnl.invAmmo.ShowAmmo()
        end
      end
    end

    storagePnl.invItems.ShowItems = function()
      storagePnl.invItems.items = Inv.Items
      storagePnl.invItems:AddPanels()
    end

    storagePnl.storageItems.ShowItems = function()
      storagePnl.storageItems.items = self.Storage.Items
      storagePnl.storageItems:AddPanels()
    end

    storagePnl.invAmmo.ShowAmmo = function()
      storagePnl.invAmmo:SetAmmo(storagePnl.invAmmo.plammo)
      storagePnl.invAmmo:AddPanels()
    end

    storagePnl.storageAmmo.ShowAmmo = function()
      storagePnl.storageAmmo:SetAmmo(self.Storage.Ammo)
      storagePnl.storageAmmo:AddPanels()
    end

    storagePnl.invItems.ShowItems()
    storagePnl.storageItems.ShowItems()
    storagePnl.invAmmo.ShowAmmo()
    storagePnl.storageAmmo.ShowAmmo()
  end

  net.Receive("OpenStorage", function()
    local storage = net.ReadEntity()
    storage:OpenStorage()
  end)

  net.Receive("SendAmmoToStorageClient", function()
    local storage = net.ReadEntity()
    local ammoId = net.ReadUInt(8)
    local amount = net.ReadUInt(16)

    if (not IsValid(storage)) then return end

    storage.Storage.Ammo[ammoId] = amount
    if (amount <= 0) then
      storage.Storage.Ammo[ammoId] = nil
    end

    if (IsValid(storagePnl)) then
      storagePnl.storageAmmo.ShowAmmo()
    end
  end)

  net.Receive("SendItemToStorageClient", function()
    local storage = net.ReadEntity()
    local item = net.ReadTable()

    if (not IsValid(storage)) then return end

    storage.Storage.Capacity = storage.Storage.Capacity + 1
    storage.Storage.Items[storage.Storage.Capacity] = item

    if (IsValid(storagePnl)) then
      storagePnl.storageItems.ShowItems()
    end
  end)

  net.Receive("ChangeStorageMaxCapClient", function()
    local storage = net.ReadEntity()
    local capacity = net.ReadUInt(16)

    if (not IsValid(storage)) then return end

    storage.Storage.MaxCapacity = capacity
    if (IsValid(storagePnl)) then
      storagePnl.storageItems.ShowItems()
    end
  end)

  net.Receive("StorageRemoveItemByIdClient", function()
    local storage = net.ReadEntity()
    local id = net.ReadUInt(16)

    if (not IsValid(storage)) then return end

    if (id < 1 || id > storage.Storage.Capacity) then return end

    storage.Storage.Capacity = storage.Storage.Capacity - 1
    table.remove(storage.Storage.Items, id)

    if (IsValid(storagePnl)) then
      storagePnl.storageItems.ShowItems()
    end
  end)
end
