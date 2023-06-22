local PANEL = {}

function PANEL:Init()
  self.page = 0 -- Page is 4x4
  self.panels = {}
  self.items = {}
  self.numPages = 1
  self.addPanelsCustomize = function() end

  self.footer = self:Add("DPanel")
  self.footer:Dock(BOTTOM)
  self.footer:SetTall(32)
  self.footer.Paint = nil

  self.footer.prevButton = self.footer:Add("DButton")
  self.footer.prevButton:Dock(LEFT)
  self.footer.prevButton:SetWide(32)
  self.footer.prevButton:SetText("<")
  self.footer.prevButton:SetFont("inv_Title")
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
  self.footer.nextButton:SetFont("inv_Title")
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

function PANEL:AddPanels()
  self.numPages = math.Clamp(1 + math.floor((#self.items - 1) / 16), 1, math.huge)
  self.page = math.Clamp(self.page, 0, self.numPages - 1)
  self.footer.info:SetText("Page " .. self.page + 1 .. "/" .. self.numPages)
  for _, v in ipairs(self.panels) do
    v:Remove()
  end
  self.panels = {}

  for i = 1 + self.page*16, self.page*16 + 16 do
    local item = self.items[i]
    if (item == nil) then break end
    local row = math.floor((i - 1 - self.page*16) / 4)
    local posInRow = (i - 1 - self.page*16) % 4
    local itemSize = self:GetWide() / 4
    local itemPnl = self:Add("DPanel")
    itemPnl:SetSize(itemSize, itemSize)
    itemPnl:SetPos(posInRow * itemSize, row * itemSize)
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
    itemPnl.btnBar:SetTall(16)
    itemPnl.btnBar.Paint = nil
    
    itemPnl.icon = itemPnl:Add("ModelImage")
    itemPnl.icon:Dock(FILL)
    itemPnl.icon:SetModel(item.model)
    
    itemPnl.idx = i
    table.insert(self.panels, itemPnl)
  end
  self.addPanelsCustomize()
end

function PANEL:Paint(w, h)
end

vgui.Register("item_pnl", PANEL, "DPanel")
