local PANEL = {}

function PANEL:Init()
  self.page = 0 -- Page is 2x4
  self.panels = {}
  self.ammo = {}
  self.numPages = 1
  self.addPanelsCustomize = function() end
  self.layoutSideways = false

  self.footer = self:Add("DPanel")
  self.footer:Dock(BOTTOM)
  self.footer:SetTall(32)
  self.footer.Paint = nil

  self.footer.prevButton = self.footer:Add("DButton")
  self.footer.prevButton:Dock(LEFT)
  self.footer.prevButton:SetWide(32)
  self.footer.prevButton:SetText("<")
  self.footer.prevButton:SetFont("inv_Misc")
  self.footer.prevButton:SetTextColor(InvUI.Colors.Text)
  self.footer.prevButton.Paint = nil
  self.footer.prevButton.DoClick = function()
    self.page = math.Clamp(self.page - 1, 0, self.numPages - 1)
    self:AddPanels()
  end

  self.footer.nextButton = self.footer:Add("DButton")
  self.footer.nextButton:Dock(RIGHT)
  self.footer.nextButton:SetWide(32)
  self.footer.nextButton:SetText(">")
  self.footer.nextButton:SetFont("inv_Misc")
  self.footer.nextButton:SetTextColor(InvUI.Colors.Text)
  self.footer.nextButton.Paint = nil
  self.footer.nextButton.DoClick = function()
    self.page = math.Clamp(self.page + 1, 0, self.numPages - 1)
    self:AddPanels()
  end

  self.footer.info = self.footer:Add("DLabel")
  self.footer.info:Dock(FILL)
  self.footer.info:SetFont("inv_Misc")
  self.footer.info:SetTextColor(InvUI.Colors.Text)
  self.footer.info:SetContentAlignment(5)
  self.footer.info:SetText("Page " .. self.page + 1 .. "/" .. self.numPages)
end

function PANEL:SetAmmo(ammo)
  self.ammo = {}
  for id, am in pairs(ammo) do
    table.insert(self.ammo, {ammoId = id, amount = am})
  end
end

function PANEL:AddPanels()
  self.numPages = math.Clamp(1 + math.floor((#self.ammo - 1) / 8), 1, math.huge)
  self.page = math.Clamp(self.page, 0, self.numPages - 1)
  self.footer.info:SetText("Page " .. self.page + 1 .. "/" .. self.numPages)
  for _, v in ipairs(self.panels) do
    v:Remove()
  end
  self.panels = {}

  for i = 1 + self.page*8, self.page*8 + 8 do
    local ammo = self.ammo[i]
    if (ammo == nil) then break end
    local row = math.floor((i - 1 - self.page*8) / 2)
    local posInRow = (i - 1 - self.page*8) % 2
    local itemSize = self:GetWide() / 2
    if (self.layoutSideways) then
      row = math.floor((i - 1 - self.page*8) / 4)
      posInRow = (i - 1 - self.page*8) % 4
      itemSize = self:GetWide() / 4
    end
    local ammoPnl = self:Add("DPanel")
    ammoPnl:SetSize(itemSize, itemSize)
    ammoPnl:SetPos(posInRow * itemSize, row * itemSize)
    ammoPnl.Paint = function(pnl, w, h)
      draw.RoundedBox(0, 0, 0, w, h, InvUI.Colors.ItemColor)
      surface.SetDrawColor(InvUI.Colors.Primary.r,
      InvUI.Colors.Primary.g,
      InvUI.Colors.Primary.b,
      255)
      surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    ammoPnl.name = ammoPnl:Add("DLabel")
    ammoPnl.name:Dock(FILL)
    ammoPnl.name:SetFont("inv_Misc")
    ammoPnl.name:SetTextColor(InvUI.Colors.Text)
    ammoPnl.name:SetContentAlignment(5)
    ammoPnl.name:SetText(game.GetAmmoName(ammo.ammoId))

    ammoPnl.btnBar = ammoPnl:Add("DPanel")
    ammoPnl.btnBar:Dock(BOTTOM)
    ammoPnl.btnBar:SetTall(16)
    ammoPnl.btnBar.Paint = nil
    
    ammoPnl.btnBar.moveAllBtn = ammoPnl.btnBar:Add("DButton")
    ammoPnl.btnBar.moveAllBtn:Dock(LEFT)
    ammoPnl.btnBar.moveAllBtn:SetWide(ScrW() / 24)
    ammoPnl.btnBar.moveAllBtn:SetFont("inv_AmmoButtons")
    ammoPnl.btnBar.moveAllBtn:SetText("")
    ammoPnl.btnBar.moveAllBtn:SetTextColor(InvUI.Colors.Text)
    ammoPnl.btnBar.moveAllBtn.Paint = nil

    ammoPnl.btnBar.moveBtn = ammoPnl.btnBar:Add("DButton")
    ammoPnl.btnBar.moveBtn:Dock(RIGHT)
    ammoPnl.btnBar.moveBtn:SetWide(ScrW() / 24)
    ammoPnl.btnBar.moveBtn:SetFont("inv_AmmoButtons")
    ammoPnl.btnBar.moveBtn:SetText("")
    ammoPnl.btnBar.moveBtn:SetTextColor(InvUI.Colors.Text)
    ammoPnl.btnBar.moveBtn.Paint = nil

    ammoPnl.numSliderArea = ammoPnl:Add("DPanel")
    ammoPnl.numSliderArea:Dock(BOTTOM)
    ammoPnl.numSliderArea:SetTall(16)
    ammoPnl.numSliderArea.Paint = nil

    ammoPnl.numSliderArea.slider = ammoPnl.numSliderArea:Add("DPanel")
    ammoPnl.numSliderArea.slider:Dock(RIGHT)
    ammoPnl.numSliderArea.slider:SetWide(ScrW() / 12 - 32)
    ammoPnl.numSliderArea.slider.Paint = function(pnl, w, h)
      draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 32))
      draw.RoundedBox(8, ammoPnl.numSliderArea.slider.pos * (ScrW() / 12 - 32 - 8), 0, 8, h, InvUI.Colors.Text)
    end
    ammoPnl.numSliderArea.slider.pos = 1.0
    ammoPnl.numSliderArea.slider.hold = false
    ammoPnl.numSliderArea.slider.Think = function()
      if (not ammoPnl.numSliderArea.slider.hold) then return end
      local mx, my = ammoPnl.numSliderArea.slider:CursorPos()
      if (mx > ScrW() / 12 - 32 - 8 or mx < 0 or my > 16 or my < 0) then
        ammoPnl.numSliderArea.slider.hold = false
      end
      ammoPnl.numSliderArea.slider.pos = math.Clamp(mx / (ScrW() / 12 - 32 - 8), 0, 1)
      ammoPnl.numSliderArea.ammoToDrop:SetText(math.Clamp(math.floor(ammo.amount * ammoPnl.numSliderArea.slider.pos), 1, ammo.amount))
    end
    ammoPnl.numSliderArea.slider.OnMousePressed = function()
      ammoPnl.numSliderArea.slider.hold = true
    end
    ammoPnl.numSliderArea.slider.OnMouseReleased = function()
      ammoPnl.numSliderArea.slider.hold = false
    end

    ammoPnl.numSliderArea.ammoToDrop = ammoPnl.numSliderArea:Add("DLabel")
    ammoPnl.numSliderArea.ammoToDrop:Dock(LEFT)
    ammoPnl.numSliderArea.ammoToDrop:SetWide(32)
    ammoPnl.numSliderArea.ammoToDrop:SetFont("inv_AmmoButtons")
    ammoPnl.numSliderArea.ammoToDrop:SetTextColor(InvUI.Colors.Text)
    ammoPnl.numSliderArea.ammoToDrop:SetContentAlignment(5)
    ammoPnl.numSliderArea.ammoToDrop:SetText(ammo.amount)

    ammoPnl.ammoId = ammo.ammoId

    table.insert(self.panels, ammoPnl)
  end
  self.addPanelsCustomize()
end

function PANEL:Paint(w, h)
end

vgui.Register("ammo_pnl", PANEL, "DPanel")
