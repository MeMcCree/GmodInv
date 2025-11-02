local PANEL = {}

function PANEL:Init()
    self.progress = 0
end

function PANEL:Think()
    if (TimedAction.active) then
        local len = TimedAction.endTime - TimedAction.startTime
        if (len) then
            self.progress = (TimedAction.endTime - CurTime()) / len
            self.progress = 1 - math.Clamp(self.progress, 0, 1)
        end
    end
end

function PANEL:Paint(w, h)
  draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 25))
  if (self.progress) then
    surface.SetDrawColor(60, 60, 60, 100)
    draw.NoTexture()

    local cx = w / 2
    local cy = h / 2
    local steps = 32
    local step = math.rad(360 / steps)
    local rad = w / 2
    local endstep = math.floor(steps * self.progress)

    for i=0, endstep, 1 do
        local a = i * step - math.pi / 2
        local nexta = (i + 1) % steps * step - math.pi / 2
        local tri = {
            {x = cx + math.cos(a) * rad, y = cy + math.sin(a) * rad},
            {x = cx + math.cos(nexta) * rad, y = cy + math.sin(nexta) * rad},
            {x = cx + math.cos(nexta) * (rad - 16), y = cy + math.sin(nexta) * (rad - 16)},
            {x = cx + math.cos(a) * (rad - 16), y = cy + math.sin(a) * (rad - 16)},
        }
        surface.DrawPoly(tri)
    end
  end
end

vgui.Register("progress_bar", PANEL, "EditablePanel")
