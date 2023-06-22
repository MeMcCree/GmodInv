AddCSLuaFile()
ENT.Type = "anim"
ENT.Base = "base_storage"
ENT.Spawnable = false

ENT.Model = "models/items/item_item_crate.mdl"

if (SERVER) then
  function ENT:RemoveCheck()
    return #self.Storage.Ammo == 0 and self.Storage.Capacity == 0
  end

  function ENT:RemoveItemById(id)
    if (id < 1 || id > self.Storage.Capacity) then return end

    self.Storage.Capacity = self.Storage.Capacity - 1
    table.remove(self.Storage.Items, id)
    if (self:RemoveCheck()) then
      self:Remove()
    end
  end

  function ENT:MoveAmmoFromStorage(ply, ammoId, amount)
    ply:GiveAmmo(amount, ammoId)
    self.Storage.Ammo[ammoId] = self.Storage.Ammo[ammoId] - amount
    self:SendAmmoTypeToStorageClient(ammoId, self.Storage.Ammo[ammoId])
    if (self.Storage.Ammo[ammoId] <= 0) then
      self.Storage.Ammo[ammoId] = nil
    end
    if (self:RemoveCheck()) then
      self:Remove()
    end
  end
end