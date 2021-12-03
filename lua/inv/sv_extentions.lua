local _E = FindMetaTable("Entity")
local _P = FindMetaTable("Player")

function _P:ClearInvClient()
  net.Start("ClearInvClient")
  net.Send(self)
end

function _P:SendEachItemToClient()
  for i = 1, self.Inv.Capacity do
    self:SendItemToClient(self.Inv.Items[i])
  end
end

function _P:InitInv()
  self.Inv = {}
  self.Inv.Items = {}
  self.Inv.Capacity = 0
  self.Inv.MaxCapacity = MaxDefInvCap
  self:ClearInvClient()
end

function _P:LoadInv()
  local filePath = "memccreesinv/userdata/u_" .. self:AccountID() .. ".json"
  local fileTable = LoadFile(filePath)

  if (not fileTable.Items) then
    self:InitInv()
    file.CreateDir("memccreesinv/userdata")
    SaveFile(filePath, self.Inv)
  else
    self.Inv = fileTable
    self:ClearInvClient()
    self:SendEachItemToClient()
  end
end

function _P:CanPickupItem(item)
  if (self.Inv.Capacity + 1 > self.Inv.MaxCapacity) then return false end
  if (HasValue(InvBlacklist, item.classname) || not HasValue(InvWhitelist, item.classname)) then return false end
  return true
end

function _P:AddItem(item)
  self.Inv.Capacity = self.Inv.Capacity + 1
  self.Inv.Items[self.Inv.Capacity] = item
end

function _P:PickupTrace()
  local tr = self:GetEyeTrace()

  local pos = tr.HitPos
  if (pos:Distance(self:GetPos()) > 150) then
    return NULL
  end

  return tr.Entity
end

function _E:GetItem()
  local item = {}

  if (self:IsWeapon()) then
    item.weapon = true
    item.clip1 = self:Clip1()
    item.clip2 = self:Clip2()
  end

  item.classname = self:GetClass()
  item.model = self:GetModel()
  return item
end

function _P:SendItemToClient(item)
  net.Start("SendItemToClient")
    net.WriteTable(item)
  net.Send(self)
end

function _P:PickupItem()
  local target = self:PickupTrace()
  if (not IsValid(target)) then return end

  local item = target:GetItem()
  if (not self:CanPickupItem(item)) then return end

  self:AddItem(item)
  self:SendItemToClient(item)

  target:Remove()
end

function _P:RemoveItemById(id)
  if (id < 1 || id > self.Inv.Capacity) then return end

  self.Inv.Capacity = self.Inv.Capacity - 1
  for i = id, self.Inv.Capacity do
    self.Inv.Items[i] = self.Inv.Items[i + 1]
  end
end

function _P:RemoveItemByIdClient(id)
  net.Start("RemoveItemByIdClient")
    net.WriteUInt(id, 16)
  net.Send(self)
end

function _P:DropItem(id, distance)
  if (id < 1 || id > self.Inv.Capacity) then return NULL end

  local tr = util.TraceLine({
    start = self:EyePos() - self:EyeAngles():Forward() * (distance / 2),
    endpos = self:EyePos() + self:EyeAngles():Forward() * distance,
    filter = self
  })

  local item = self.Inv.Items[id]
  self:RemoveItemById(id)
  self:RemoveItemByIdClient(id)

  local droppedEnt = ents.Create(item.classname)
  if (IsValid(droppedEnt)) then
    droppedEnt:SetModel(item.model)
    droppedEnt:SetPos(tr.HitPos + tr.HitNormal * 20)
    droppedEnt:SetAngles(Angle(0, 0, 0))
    droppedEnt:Spawn()
    droppedEnt:Activate()

    local phys = droppedEnt:GetPhysicsObject()
    if (IsValid(phys)) then
      phys:Wake()
    end

    if (item.weapon) then
      droppedEnt:SetClip1(item.clip1)
      droppedEnt:SetClip2(item.clip2)
    end
  end

  return droppedEnt
end

function _P:UseItem(id, distance)
  local droppedEnt = self:DropItem(id, distance)

  if (IsValid(droppedEnt)) then
    droppedEnt:Use(self)
    if (droppedEnt:GetClass() == "prop_physics") then
      DropEntityIfHeld(droppedEnt)
    end
  end
end
