local function AddFont(font, name, size, weight)
  surface.CreateFont("inv_" .. name, {
    font = font,
    size = size,
    weight = weight,
    antialias = true
  })
end

AddFont("Roboto", "ItemButtons", 24, 240)

function OpenInvPnl()
  invPnl = vgui.Create("inv_frame")
  invPnl:SetSize(ScrW() / 1.5, ScrH() / 1.25)
  invPnl:Center()
  invPnl:SetTitle("Inventory")
  invPnl:MakePopup()

  invPnl.itemPnl = invPnl:Add("item_pnl")
  invPnl.itemPnl:Dock(FILL)

  invPnl.itemPnl.ShowItems = function()
    invPnl.itemPnl.scroll.icons:Clear()
    invPnl.itemPnl.scroll.icons:InvalidateLayout(true)

    for i = 1, Inv.Capacity do
      local item = Inv.Items[i]
      local itemPnl = invPnl.itemPnl.scroll.icons:Add("DPanel")

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

  invPnl.itemPnl.ShowItems()
end

concommand.Add("inv_open", function()
  OpenInvPnl()
end)
