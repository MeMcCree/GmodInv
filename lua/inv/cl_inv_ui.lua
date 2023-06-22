local function AddFont(font, name, size, weight)
  surface.CreateFont("inv_" .. name, {
    font = font,
    size = size,
    weight = weight,
    antialias = true
  })
end

AddFont("Roboto", "Title", 32, 240)
AddFont("Roboto", "Misc", 24, 240)
AddFont("Roboto", "ItemButtons", 24, 240)
AddFont("Roboto", "AmmoButtons", 12, 240)

GWS_MATERIALS = {
  ["ammo"] = Material("vgui/ammo1.png"),
}

function OpenInvPnl()
  if (IsValid(invPnl)) then return end
  invPnl = vgui.Create("inv_frame")
  invPnl:SetSize(8 + ScrW() / 3 + 32 + ScrW() / 6 + 8, 32 + 8 + 32 + ScrW() / 3 + 32 + 8)
  invPnl:Center()
  invPnl:SetTitle("Inventory")
  invPnl:MakePopup()

  invPnl.itemPnlTitle = invPnl:Add("DLabel")
  invPnl.itemPnlTitle:SetPos(8, 40)
  invPnl.itemPnlTitle:SetSize(ScrW() / 3, 32)
  invPnl.itemPnlTitle:SetFont("inv_Misc")
  invPnl.itemPnlTitle:SetTextColor(InvUI.Colors.Text)
  invPnl.itemPnlTitle:SetContentAlignment(5)
  invPnl.itemPnlTitle:SetText("Items")

  invPnl.ammoPnlTitle = invPnl:Add("DLabel")
  invPnl.ammoPnlTitle:SetPos(8 + ScrW() / 3 + 32, 40)
  invPnl.ammoPnlTitle:SetSize(ScrW() / 6, 32)
  invPnl.ammoPnlTitle:SetFont("inv_Misc")
  invPnl.ammoPnlTitle:SetTextColor(InvUI.Colors.Text)
  invPnl.ammoPnlTitle:SetContentAlignment(5)
  invPnl.ammoPnlTitle:SetText("Ammo")

  invPnl.itemPnl = invPnl:Add("item_pnl")
  invPnl.itemPnl:SetPos(8, 72)
  invPnl.itemPnl:SetSize(ScrW() / 3, ScrW() / 3 + 32)
  invPnl.itemPnl.addPanelsCustomize = function()
    for _, itemPnl in ipairs(invPnl.itemPnl.panels) do
      itemPnl.btnBar.dropBtn = itemPnl.btnBar:Add("DButton")
      itemPnl.btnBar.dropBtn:Dock(LEFT)
      itemPnl.btnBar.dropBtn:SetWide(ScrW() / 24)
      itemPnl.btnBar.dropBtn:SetFont("inv_Misc")
      itemPnl.btnBar.dropBtn:SetTextColor(InvUI.Colors.Text)
      itemPnl.btnBar.dropBtn:SetText("Drop")
      itemPnl.btnBar.dropBtn.Paint = nil
      itemPnl.btnBar.dropBtn.DoClick = function(pnl)
        net.Start("DropItem")
          net.WriteUInt(itemPnl.idx, 16)
        net.SendToServer()
      end

      itemPnl.btnBar.useBtn = itemPnl.btnBar:Add("DButton")
      itemPnl.btnBar.useBtn:Dock(RIGHT)
      itemPnl.btnBar.useBtn:SetWide(ScrW() / 24)
      itemPnl.btnBar.useBtn:SetFont("inv_Misc")
      itemPnl.btnBar.useBtn:SetTextColor(InvUI.Colors.Text)
      itemPnl.btnBar.useBtn:SetText("Use")
      itemPnl.btnBar.useBtn.Paint = nil
      itemPnl.btnBar.useBtn.DoClick = function(pnl)
        net.Start("UseItem")
          net.WriteUInt(itemPnl.idx, 16)
        net.SendToServer()
      end
    end
  end

  invPnl.ammo = LocalPlayer():GetAmmo()

  invPnl.ammoPnl = invPnl:Add("ammo_pnl")
  invPnl.ammoPnl:SetPos(8 + ScrW() / 3 + 32, 72)
  invPnl.ammoPnl:SetSize(ScrW() / 6, ScrW() / 3 + 32)
  invPnl.ammoPnl.addPanelsCustomize = function()
    for _, ammoPnl in ipairs(invPnl.ammoPnl.panels) do
      ammoPnl.btnBar.moveAllBtn:SetText("Drop all")
      ammoPnl.btnBar.moveBtn:SetText("Drop some")

      ammoPnl.btnBar.moveAllBtn.DoClick = function()
        net.Start("DropAmmo")
          net.WriteUInt(ammoPnl.ammoId, 8)
          net.WriteUInt(invPnl.ammo[ammoPnl.ammoId], 16)
        net.SendToServer()
        invPnl.ammo[ammoPnl.ammoId] = nil
        invPnl.ammoPnl.ShowAmmo()
      end

      ammoPnl.btnBar.moveBtn.DoClick = function()
        local ammoToDrop = tonumber(ammoPnl.numSliderArea.ammoToDrop:GetText())
        net.Start("DropAmmo")
          net.WriteUInt(ammoPnl.ammoId, 8)
          net.WriteUInt(ammoToDrop, 16)
        net.SendToServer()
        invPnl.ammo[ammoPnl.ammoId] = invPnl.ammo[ammoPnl.ammoId] - ammoToDrop
        if (invPnl.ammo[ammoPnl.ammoId] <= 0) then
          invPnl.ammo[ammoPnl.ammoId] = nil
        end
        invPnl.ammoPnl.ShowAmmo()
      end
    end
  end

  invPnl.itemPnl.ShowItems = function()
    invPnl.itemPnl.items = Inv.Items
    invPnl.itemPnl:AddPanels()
  end

  invPnl.ammoPnl.ShowAmmo = function()
    invPnl.ammoPnl:SetAmmo(invPnl.ammo)
    invPnl.ammoPnl:AddPanels()
  end

  invPnl.itemPnl.ShowItems()
  invPnl.ammoPnl.ShowAmmo()
end

concommand.Add("inv_open", function()
  OpenInvPnl()
end)
