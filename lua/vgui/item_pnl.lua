local PANEL = {}

function PANEL:Init()
  self.scroll = self:Add("DScrollPanel")
  self.scroll:Dock(FILL)
  self.scroll:DockMargin(16, 8, 0, 0)
  self.scroll.Paint = nil
  local vbar = self.scroll:GetVBar()
  vbar:SetWide(16)
  vbar.Paint = nil
  vbar.btnUp.Paint = nil
  vbar.btnDown.Paint = nil
  vbar.btnGrip.Paint = function(pnl, w, h)
    draw.RoundedBox(32, 0, 0, w, h, InvUI.Colors.Primary)
  end

  self.scroll.icons = self.scroll:Add("DIconLayout")
  self.scroll.icons:Dock(FILL)
  self.scroll.icons:DockMargin(0, 5, 0, 0)
  self.scroll.icons:SetSpaceX(5)
  self.scroll.icons:SetSpaceY(5)
end

function PANEL:ShowItems()
  self.scroll.icons:Clear()
  for i = 1, Inv.Capacity do
    local item = Inv.Items[i]
    local itemPnl = self.scroll.icons:Add("DPanel")

    itemPnl:SetSize(ScrH() / 10, ScrH() / 9.5)
    itemPnl.Paint = function(pnl, w, h)
      draw.RoundedBox(0, 0, 0, w, h, InvUI.Colors.ItemColor)
      surface.SetDrawColor(InvUI.Colors.Primary.r,
                           InvUI.Colors.Primary.g,
                           InvUI.Colors.Primary.b,
                           255)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    itemPnl.btnBar = itemPnl:Add("DPanel")
    itemPnl.btnBar:Dock(BOTTOM)
    itemPnl.btnBar:SetTall(ScrH() / 50)
    itemPnl.btnBar.Paint = nil

    itemPnl.btnBar.dropBtn = itemPnl.btnBar:Add("DButton")
    itemPnl.btnBar.dropBtn:Dock(LEFT)
    itemPnl.btnBar.dropBtn:SetWide(ScrH() / 20)
    itemPnl.btnBar.dropBtn:SetFont("inv_ItemButtons")
    itemPnl.btnBar.dropBtn:SetTextColor(InvUI.Colors.Text)
    itemPnl.btnBar.dropBtn:SetText("Drop")
    itemPnl.btnBar.dropBtn.Paint = nil
    itemPnl.btnBar.dropBtn.DoClick = function(pnl)
      net.Start("DropItem")
        net.WriteUInt(i, 16)
      net.SendToServer()
    end

    itemPnl.btnBar.useBtn = itemPnl.btnBar:Add("DButton")
    itemPnl.btnBar.useBtn:Dock(RIGHT)
    itemPnl.btnBar.useBtn:SetWide(ScrH() / 20)
    itemPnl.btnBar.useBtn:SetFont("inv_ItemButtons")
    itemPnl.btnBar.useBtn:SetTextColor(InvUI.Colors.Text)
    itemPnl.btnBar.useBtn:SetText("Use")
    itemPnl.btnBar.useBtn.Paint = nil
    itemPnl.btnBar.useBtn.DoClick = function(pnl)
      net.Start("UseItem")
        net.WriteUInt(i, 16)
      net.SendToServer()
    end

    itemPnl.icon = itemPnl:Add("ModelImage")
    itemPnl.icon:Dock(FILL)
    itemPnl.icon:SetModel(item.model)
  end
end

function PANEL:Paint(w, h)
end

vgui.Register("item_pnl", PANEL, "DPanel")
