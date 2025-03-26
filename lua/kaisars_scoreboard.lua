local KaisarScoreboard = {}
local notifications = {}

local function AddNotification(text, duration)
    local notification = vgui.Create("DPanel")
    notification:SetSize(ScrW() * 0.3, 40)
    notification:SetPos(ScrW() * 0.35, ScrH() - 50)
    notification.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 200))
        draw.SimpleText(text, "DermaDefaultBold", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    table.insert(notifications, notification)

    local y = ScrH() - 50
    for _, notif in ipairs(notifications) do
        notif:MoveTo(ScrW() * 0.35, y - 50, 0.3, 0, 1)
        y = y - 50
    end

    timer.Simple(duration, function()
        if IsValid(notification) then
            notification:AlphaTo(0, 0.5, 0, function()
                if IsValid(notification) then
                    notification:Remove()
                    table.RemoveByValue(notifications, notification)
                end
            end)
        end
    end)
end

function KaisarScoreboard:Init()
    self:SetSize(ScrW() * 0.6, ScrH() * 0.85)
    self:Center()
    self:MakePopup()

    local header = vgui.Create("DPanel", self)
    header:Dock(TOP)
    header:SetTall(50)
    header.Paint = function(s, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, Color(40, 40, 40, 240), true, true, false, false)
        draw.SimpleText("Scoreboard", "DermaLarge", w/2, h/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local scrollPanel = vgui.Create("DScrollPanel", self)
    scrollPanel:Dock(FILL)
    scrollPanel:DockMargin(5, 5, 5, 5)
    
    local sbar = scrollPanel:GetVBar()
    sbar:SetWide(8)
    sbar:SetHideButtons(true)
    function sbar:Paint(w, h) draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100)) end
    function sbar.btnGrip:Paint(w, h) draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 200)) end

    self:PopulatePlayerList(scrollPanel)
end

function KaisarScoreboard:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 240))
    surface.SetDrawColor(80, 80, 80, 255)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function KaisarScoreboard:PopulatePlayerList(scrollPanel)
    local players = player.GetAll()
    table.sort(players, function(a, b) return a:Frags() > b:Frags() end)

    local headerRow = vgui.Create("DPanel", scrollPanel)
    headerRow:Dock(TOP)
    headerRow:SetTall(25)
    headerRow:DockMargin(0, 0, 0, 5)
    headerRow.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(60, 60, 60, 200))
    end

    local headers = {
        {"Name", 0.4, 37},  
        {"Kills", 0.2, 0},  
        {"Deaths", 0.2, 0}, 
        {"Ping", 0.2, 0}   
    }

    for i, header in ipairs(headers) do
        local label = vgui.Create("DLabel", headerRow)
        label:SetText(header[1])
        label:SetFont("DermaDefaultBold")
        label:SetTextColor(Color(200, 200, 200))
        label:Dock(LEFT)
        label:DockMargin(5, 0, 0, 0)
        label:SetWide(self:GetWide() * header[2] - header[3])
    end

    for _, ply in ipairs(players) do
        local row = vgui.Create("DButton", scrollPanel)
        row:SetTall(40)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 2)
        row:SetText("")
        
        row.Paint = function(s, w, h)
            local bgColor = Color(50, 50, 50, 200)
            if ply == LocalPlayer() then
                bgColor = Color(70, 70, 50, 200)
            end
            if s:IsHovered() then
                bgColor.a = 230
            end
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
        end

        row.DoClick = function()
            SetClipboardText(ply:SteamID())
            AddNotification("Successfully copied " .. ply:Nick() .. "'s SteamID to clipboard.", 3)
        end

        local avatar = vgui.Create("AvatarImage", row)
        avatar:SetSize(32, 32)
        avatar:Dock(LEFT)
        avatar:SetPlayer(ply, 32)
        avatar:DockMargin(4, 4, 8, 4)

        local nameLabel = vgui.Create("DLabel", row)
        nameLabel:SetText(ply:Nick())
        nameLabel:SetFont("DermaDefaultBold")
        nameLabel:SetTextColor(Color(255, 255, 255))
        nameLabel:Dock(LEFT)
        nameLabel:SetWide(self:GetWide() * 0.4 - 37)

        local killsLabel = vgui.Create("DLabel", row)
        killsLabel:SetText(ply:Frags())
        killsLabel:SetTextColor(Color(150, 255, 150))
        killsLabel:Dock(LEFT)
        killsLabel:SetWide(self:GetWide() * 0.2)
        killsLabel:SetContentAlignment(5)

        local deathsLabel = vgui.Create("DLabel", row)
        deathsLabel:SetText(ply:Deaths())
        deathsLabel:SetTextColor(Color(255, 150, 150))
        deathsLabel:Dock(LEFT)
        deathsLabel:SetWide(self:GetWide() * 0.2)
        deathsLabel:SetContentAlignment(5)

        local pingLabel = vgui.Create("DLabel", row)
        pingLabel:SetText(ply:Ping()) -- Get the player's ping
        pingLabel:SetTextColor(Color(200, 200, 255))
        pingLabel:Dock(LEFT)
        pingLabel:SetWide(self:GetWide() * 0.2)
        pingLabel:SetContentAlignment(5)
    end
end

vgui.Register("KaisarScoreboard", KaisarScoreboard, "DPanel")

local KaisarBoard

hook.Add("ScoreboardShow", "KaisarScoreboard", function()
    if not IsValid(KaisarBoard) then
        KaisarBoard = vgui.Create("KaisarScoreboard")
    end
    return true
end)

hook.Add("ScoreboardHide", "KaisarScoreboard", function()
    if IsValid(KaisarBoard) then
        KaisarBoard:Remove()
        KaisarBoard = nil
    end
    return true
end)