local function AddFont(font, name, size, weight)
  surface.CreateFont("inv_" .. name, {
    font = font,
    size = size,
    weight = weight,
    antialias = true
  })
end

AddFont("Roboto", "ItemName", 12, 240)
AddFont("Roboto", "Title", 24, 240)

function OpenInvPnl()
  invPnl = vgui.Create("inv_frame")
  invPnl:SetSize(ScrW() / 1.5, ScrH() / 1.25)
  invPnl:Center()
  invPnl:SetTitle("Inventory")
  invPnl:MakePopup()

  invPnl.itemPnl = invPnl:Add("item_pnl")
  invPnl.itemPnl:Dock(FILL)

  invPnl.itemPnl.ShowItems = function()
    invPnl.itemPnl.icons:Clear()
    invPnl.itemPnl.icons:InvalidateLayout(true)

    for i = 1, Inv.Capacity do
      local item = Inv.Items[i]
      local itemPnl = invPnl.itemPnl.icons:Add("DPanel")

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

      itemPnl.icon.label = itemPnl.icon:Add("DLabel")
      itemPnl.icon.label:Dock(BOTTOM)
      itemPnl.icon.label:SetTall(18)
      itemPnl.icon.label:SetText(item.name)
      itemPnl.icon.label:SetFont("inv_ItemName")
      itemPnl.icon.label:SetTextColor(InvUI.Colors.Text)
      itemPnl.icon.label:SetContentAlignment(5)

    end
  end

  invPnl.itemPnl.ShowItems()
end

concommand.Add("inv_open", function()
  OpenInvPnl()
end)
