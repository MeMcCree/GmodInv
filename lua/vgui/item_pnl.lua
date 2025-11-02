local PANEL = {}

function PANEL:Init()
  self.icons = self:Add("DIconLayout")
  self.icons:Dock(FILL)
  self.icons:DockMargin(16, 8, 0, 0)
  self.icons:SetSpaceX(5)
  self.icons:SetSpaceY(5)

  self.icons:LerpPositions(0.1, false)
  self.OnMouseWheeled = function(self, scrollDelta)
    local left, top, right, bot = self.icons:GetDockMargin()
    local childSize = self.icons:GetChildren()[1]:GetTall()
    local min = 8 - self.icons:GetTall() + childSize
    local max = 8
    self.icons:DockMargin(16, math.Clamp(top - scrollDelta*8, min, max), 16, 0)
  end
end

function PANEL:OnRemove()
  TimedAction.active = false
end

function PANEL:ShowItems()
  self.icons:Clear()
  for i = 1, Inv.Capacity do
    local item = Inv.Items[i]
    local itemPnl = self.icons:Add("DPanel")

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
    itemPnl.icon.DoClick = function(pnl)
      local ItemMenu = DermaMenu()
      ItemMenu.DropOption = ItemMenu:AddOption("Drop", function(opt)
        net.Start("DropItem")
          net.WriteUInt(i, 16)
        net.SendToServer()
      end)
      ItemMenu.DropOption:SetIcon("icon16/arrow_down.png")
      ItemMenu.UseOption = ItemMenu:AddOption("Use", function(opt)
        net.Start("UseItem")
          net.WriteUInt(i, 16)
        net.SendToServer()
      end)
      ItemMenu.UseOption:SetIcon("icon16/accept.png")
      ItemMenu:Open()
    end
    
  end
end

function PANEL:Paint(w, h)
end

vgui.Register("item_pnl", PANEL, "DPanel")
