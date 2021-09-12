local PANEL = {}

function PANEL:Init()
  self.header = self:Add("DPanel")
  self.header:Dock(TOP)
  self.header.Paint = function(pnl, w, h)
    draw.RoundedBox(0, 0, 0, w, h, InvUI.Colors.Header)
  end

  self.header.clsBtn = self.header:Add("DButton")
  self.header.clsBtn:Dock(RIGHT)
  self.header.clsBtn:SetText("X")
  self.header.clsBtn:SetFont("DermaLarge")
  self.header.clsBtn:SetTextColor(InvUI.Colors.Text)
  self.header.clsBtn.Paint = nil
  self.header.clsBtn.DoClick = function(pnl)
    self:Remove()
  end

  self.header.title = self.header:Add("DLabel")
  self.header.title:Dock(LEFT)
  self.header.title:SetFont("DermaLarge")
  self.header.title:SetTextColor(InvUI.Colors.Text)
  self.header.title:SetTextInset(16, 0)
end

function PANEL:SetTitle(title)
  self.header.title:SetText(title)
  self.header.title:SizeToContentsX()
end

function PANEL:PerformLayout(w, h)
  self.header:SetTall(32)
  self.header.clsBtn:SetWide(self.header:GetTall())
end

function PANEL:Paint(w, h)
  draw.RoundedBox(0, 0, 0, w, h, InvUI.Colors.Secondary)
end

vgui.Register("inv_frame", PANEL, "EditablePanel")
