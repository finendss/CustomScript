loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua"))()
local P = game:GetService("Players")
local RunS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local WS = workspace
local UIS = game:GetService("UserInputService")
local lp = P.LocalPlayer

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Zer0neK/o/refs/heads/main/U.lua"))()

local Win = WindUI:CreateWindow({
    Title = "The Rake", Folder = "TR",
    Size = UDim2.fromOffset(480, 360),
    SideBarWidth = 150, HideSearchBar = true, ScrollBarEnabled = false
})

local S1 = Win:Section({ Title = "功能", Opened = true })
local S2 = Win:Section({ Title = "设置", Opened = true })

local T1 = S1:Tab({ Title = "主要功能" })
local T2 = S1:Tab({ Title = "战斗" })
local T3 = S1:Tab({ Title = "传送" })
local T4 = S1:Tab({ Title = "商店" })
local T6 = S1:Tab({ Title = "位置ESP" })
local T100 = S2:Tab({ Title = "窗口设置" })

T100:Keybind({ Title = "PC快捷键", Value = "L", Callback = function(v) Win:SetToggleKey(Enum.KeyCode[v]) end })

local function gc(p) return p and p.Character end
local function gh(c) return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) end
local function getStick()
    local c = gc(lp); if not c then return nil end
    local s = c:FindFirstChild("StunStick"); if s then return s end
    local bp = lp:FindFirstChild("Backpack"); if not bp then return nil end
    s = bp:FindFirstChild("StunStick"); if s then
        local hum = c:FindFirstChildOfClass("Humanoid"); if hum then hum:EquipTool(s) task.wait() end
        return c:FindFirstChild("StunStick")
    end
    return nil
end

local E = {
    stamina = true, rakeEsp = true, playerEsp = true, itemEsp = true,
    fullBright = true, killAura = false, bugRake = false, instaKill = false,
    hitbox = false, noFall = true,
    tpWalk = false, fov = false,
    noclip = false, vfly = false, fling = false, clampKill = false,
    powerGUI = false, timerGUI = false, netStats = false,
}
local V = { tpSpeed = 1, fov = 100, hitboxSize = 5, flySpeed = 50 }

_G.sprinting = true

local function mkBBG(parent, color, text, height, size)
    local b = Instance.new("BillboardGui")
    b.Name = "ESP_BBG"; b.Size = UDim2.new(0, 100, 0, 20)
    b.StudsOffset = Vector3.new(0, height or 3, 0)
    b.AlwaysOnTop = true; b.MaxDistance = 4000; b.LightInfluence = 0; b.Parent = parent
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1; l.Text = text or ""
    l.TextColor3 = color or Color3.new(1, 1, 1)
    l.TextStrokeTransparency = 0; l.TextStrokeColor3 = Color3.new(0, 0, 0)
    l.Font = Enum.Font.Code; l.TextSize = size or 11; l.Parent = b
    return b, l
end

local function clrAll(parent, name)
    if not parent then return end
    for _, d in ipairs(parent:GetChildren()) do if d.Name == name then d:Destroy() end end
end
local function clrAllDesc(parent, name)
    if not parent then return end
    for _, d in ipairs(parent:GetDescendants()) do if d.Name == name then d:Destroy() end end
end

local itemMap = {
    Scrap = "废铁", Supply = "物资", Ammo = "弹药", Medkit = "医疗箱",
    Bandage = "绷带", Battery = "电池", Radio = "对讲机", Candle = "蜡烛",
    StunStick = "电击棒", Pills = "药丸", Vitamin = "维生素",
    FlareGun = "信号枪", Box = "空投箱", WalkieTalkie = "对讲机",
}
local itemKeys = {}
for k in pairs(itemMap) do table.insert(itemKeys, k) end
local function getItemName(n) for k, v in pairs(itemMap) do if n:find(k) then return v end end return n end
local function isItem(m) for _, k in ipairs(itemKeys) do if m.Name:find(k) then return true end end return false end
local function isPlayerTool(m)
    for _, p in ipairs(P:GetPlayers()) do
        local c = gc(p)
        if c then for _, t in ipairs(c:GetChildren()) do if t:IsA("Tool") and t.Name == m.Name then return true end end end
        local bp = p:FindFirstChild("Backpack")
        if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and t.Name == m.Name then return true end end end
    end return false
end

local rakeHrp, rakeLbl
local function updRake()
    local rake = WS:FindFirstChild("Rake")
    if not rake then if rakeHrp then clrAll(rakeHrp, "ESP_BBG") rakeHrp = nil end return end
    local hrp = gh(rake); if not hrp then return end
    if not E.rakeEsp then clrAll(hrp, "ESP_BBG"); rakeHrp = nil; return end
    if rakeHrp ~= hrp then
        if rakeHrp then clrAll(rakeHrp, "ESP_BBG") end
        rakeHrp = hrp
        rakeLbl = select(2, mkBBG(hrp, Color3.new(1, 0.2, 0.2), "RAKE", 4, 11))
    end
    if rakeLbl then
        local myHrp = gh(gc(lp))
        if myHrp then
            local d = math.floor((hrp.Position - myHrp.Position).Magnitude)
            rakeLbl.Text = "RAKE [" .. d .. "m]"
            if d < 50 then rakeLbl.TextColor3 = Color3.new(1, 0, 0)
            elseif d < 150 then rakeLbl.TextColor3 = Color3.new(1, 0.5, 0)
            else rakeLbl.TextColor3 = Color3.new(1, 1, 0.3) end
        end
    end
end

local function updPlayer()
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= lp then
            local char = gc(p); local hrp = gh(char)
            if hrp then
                if not E.playerEsp then clrAll(hrp, "ESP_BBG")
                else
                    local downed = char:FindFirstChild("Downed"); local isDown = downed and downed.Value == true
                    if not hrp:FindFirstChild("ESP_BBG") then local _, l = mkBBG(hrp, Color3.new(0.3, 1, 0.3), p.Name, 3, 10); l.Name = "PLBL" end
                    local l = hrp.ESP_BBG:FindFirstChild("PLBL")
                    if l then
                        local myHrp = gh(gc(lp))
                        local d = myHrp and math.floor((hrp.Position - myHrp.Position).Magnitude) or 0
                        if isDown then l.Text = p.Name .. " [倒地] " .. d .. "m"; l.TextColor3 = Color3.new(1, 0.8, 0)
                        else l.Text = p.Name .. " " .. d .. "m"; l.TextColor3 = Color3.new(0.3, 1, 0.3) end
                    end
                end
            end
        end
    end
end

local function updItem()
    if not E.itemEsp then return end
    for _, d in ipairs(WS:GetDescendants()) do
        if d:IsA("Model") and isItem(d) and not isPlayerTool(d) then
            local hrp = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
            if hrp and not hrp:FindFirstChild("IESP") then
                local b = mkBBG(hrp, Color3.new(0.3, 0.7, 1), getItemName(d.Name), 2, 10)
                b.Name = "IESP"; b.MaxDistance = 800
            end
        end
    end
end

local function hookStamina()
    pcall(function()
        local tks = RS:FindFirstChild("TKSMNA"); local gst = RS:FindFirstChild("GSTMNA")
        if tks and tks:IsA("BindableEvent") and getconnections then
            for _, c in ipairs(getconnections(tks.Event)) do pcall(function() c:Disable() end) end
        end
        if gst and gst:IsA("BindableFunction") then gst.OnInvoke = function() return 100 end end
    end)
end

local function infStamina()
    if not E.stamina then return end
    pcall(function()
        local char = gc(lp); if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then if hum.WalkSpeed < 18 then hum.WalkSpeed = 18 end; hum:SetAttribute("GT_VTMNZ", true) end
        _G.sprinting = true
    end)
    hookStamina()
end

local fbConn
local function doFullBright()
    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    Lighting.Ambient = Color3.fromRGB(255, 255, 255)
    Lighting.Brightness = 2
    Lighting.GlobalShadows = true
    Lighting.ClockTime = 12
    Lighting.FogEnd = 10000000000
    Lighting.ExposureCompensation = 0.5
    for _, d in ipairs(Lighting:GetChildren()) do
        if d:IsA("PostEffect") or d:IsA("ColorCorrectionEffect") or d:IsA("BlurEffect") or d:IsA("BloomEffect") or d:IsA("SunRaysEffect") or d:IsA("Atmosphere") or d:IsA("DepthOfFieldEffect") then d.Enabled = false end
    end
end

local function toggleFullBright(v)
    E.fullBright = v
    if v then
        if getconnections then
            for _, sig in ipairs({"Ambient", "OutdoorAmbient", "Brightness", "ClockTime", "FogColor", "FogEnd"}) do
                pcall(function()
                    for _, c in ipairs(getconnections(Lighting:GetPropertyChangedSignal(sig))) do pcall(function() c:Disable() end) end
                end)
            end
        end
        if not fbConn then fbConn = RunS.Heartbeat:Connect(function() pcall(doFullBright) end) end
    else
        if fbConn then fbConn:Disconnect() fbConn = nil end
    end
end

local function safeTP(cf)
    pcall(function()
        local char = gc(lp); if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); local hrp = gh(char)
        if not hum or not hrp then return end
        local oW = hum.WalkSpeed; local oJ = hum.JumpPower
        hum.WalkSpeed = 0; hum.JumpPower = 0; hum:ChangeState(Enum.HumanoidStateType.Physics)
        for _ = 1, 6 do char:PivotTo(cf); RunS.RenderStepped:Wait() end
        hum:ChangeState(Enum.HumanoidStateType.Running); hum.WalkSpeed = oW; hum.JumpPower = oJ
    end)
end

local function doKillAura()
    if not E.killAura then return end
    pcall(function()
        local rake = WS:FindFirstChild("Rake"); if not rake then return end
        local rHrp = gh(rake); local char = gc(lp)
        if not char or not rHrp then return end
        local myHrp = gh(char); if not myHrp then return end
        if (rHrp.Position - myHrp.Position).Magnitude > 200 then return end
        local stick = getStick(); if not stick then return end
        stick.Event:FireServer("S"); stick.Event:FireServer("H", rHrp)
        local hp = stick:FindFirstChild("HitPart"); if hp then hp.Position = rHrp.Position end
    end)
end

local function doBugRake()
    if not E.bugRake then return end
    pcall(function()
        local rake = WS:FindFirstChild("Rake"); if not rake then return end
        local hum = rake:FindFirstChildOfClass("Humanoid"); local rHrp = gh(rake)
        if not hum or not rHrp or hum.Health <= 0 then return end
        local stick = getStick(); if not stick then return end
        for _ = 1, 25 do stick.Event:FireServer("S"); stick.Event:FireServer("H", rHrp) end
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    end)
end

local function doInstaKill()
    if not E.instaKill then return end
    pcall(function()
        local rake = WS:FindFirstChild("Rake"); if not rake then return end
        local hum = rake:FindFirstChildOfClass("Humanoid"); local rHrp = gh(rake)
        if not hum or not rHrp or hum.Health <= 0 then return end
        local stick = getStick(); if not stick then return end
        for _ = 1, 15 do stick.Event:FireServer("S"); stick.Event:FireServer("H", rHrp) end
        hum:TakeDamage(1e9); hum.Health = 0
    end)
end

local function doClampKill()
    if not E.clampKill then return end
    pcall(function()
        local rake = WS:FindFirstChild("Rake"); if not rake then return end
        local hum = rake:FindFirstChildOfClass("Humanoid"); local rHrp = gh(rake)
        if not hum or not rHrp or hum.Health <= 0 then return end
        local stick = getStick(); if not stick then return end
        local hp = stick:FindFirstChild("HitPart")
        if hp then hp.Size = Vector3.new(100, 100, 100); hp.Position = rHrp.Position end
        for _ = 1, 50 do stick.Event:FireServer("S"); stick.Event:FireServer("H", rHrp) end
        hum:TakeDamage(1e9); hum.Health = 0
    end)
end

local function updHitbox()
    pcall(function()
        local stick = getStick(); if not stick then return end
        local hp = stick:FindFirstChild("HitPart"); if not hp then return end
        if E.hitbox then
            hp.Size = Vector3.new(V.hitboxSize, V.hitboxSize, V.hitboxSize)
            hp.Transparency = 0.5; hp.Color = Color3.fromRGB(255, 0, 0); hp.Material = Enum.Material.Neon
            local rake = WS:FindFirstChild("Rake"); local rHrp = rake and gh(rake)
            if rHrp then hp.Position = rHrp.Position end
        else
            hp.Size = Vector3.new(1.5, 1.5, 1.5); hp.Transparency = 1; hp.Material = Enum.Material.Plastic
        end
    end)
end

local function updTpWalk()
    if not E.tpWalk then return end
    pcall(function()
        local char = gc(lp); if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid"); local hrp = gh(char)
        if not hum or not hrp then return end
        if hum.MoveDirection.Magnitude > 0 then
            hrp.CFrame = hrp.CFrame + hum.MoveDirection * V.tpSpeed
        end
    end)
end

local function updFOV()
    if not E.fov then return end
    pcall(function() local cam = WS.CurrentCamera; if cam then cam.FieldOfView = V.fov end end)
end

local function updNoclip()
    if not E.noclip then return end
    pcall(function()
        local char = gc(lp); if not char then return end
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end end
    end)
end

local flyBV, flyBG
local function updVfly()
    pcall(function()
        local char = gc(lp); if not char then return end
        local hrp = gh(char); local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp then return end
        if E.vfly then
            if hum then hum.PlatformStand = true end
            if not flyBV then
                flyBV = Instance.new("BodyVelocity"); flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBV.Velocity = Vector3.zero; flyBV.Parent = hrp
            end
            if not flyBG then
                flyBG = Instance.new("BodyGyro"); flyBG.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBG.P = 1000; flyBG.CFrame = hrp.CFrame; flyBG.Parent = hrp
            end
            local cam = WS.CurrentCamera; local dir = Vector3.zero
            if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            flyBV.Velocity = dir * V.flySpeed; flyBG.CFrame = cam.CFrame
        else
            if hum then hum.PlatformStand = false end
            if flyBV then flyBV:Destroy() flyBV = nil end
            if flyBG then flyBG:Destroy() flyBG = nil end
        end
    end)
end

local function doFling()
    if not E.fling then return end
    pcall(function()
        local char = gc(lp); if not char then return end
        local myHrp = gh(char); if not myHrp then return end
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= lp then
                local tChar = gc(p); local tHrp = gh(tChar)
                if tHrp and (tHrp.Position - myHrp.Position).Magnitude < 30 then
                    local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Velocity = (tHrp.Position - myHrp.Position).Unit * 500 + Vector3.new(0, 300, 0)
                    bv.Parent = tHrp; task.delay(0.5, function() bv:Destroy() end)
                end
            end
        end
    end)
end

local function hookNoFall()
    pcall(function()
        if not getrawmetatable or not hookmetamethod then return end
        local mt = getrawmetatable(game); local oldNC = mt.__namecall
        if setreadonly then pcall(setreadonly, mt, false) end
        hookmetamethod("__namecall", function(self, ...)
            local m = getnamecallmethod and getnamecallmethod() or ""
            if E.noFall and m == "FireServer" and tostring(self) == "FD_Event" then
                local args = table.pack(...); args[1] = 0; args[2] = 0
                return oldNC(self, table.unpack(args))
            end
            return oldNC(self, ...)
        end)
        if setreadonly then pcall(setreadonly, mt, true) end
    end)
end

local shopPos = Vector3.new(-25.1567, 17.2076, -258.362)

local function sellScraps()
    pcall(function()
        local char = gc(lp); if not char then return end
        local hrp = gh(char); if not hrp then return end
        local old = hrp.CFrame
        hrp.CFrame = CFrame.new(shopPos + Vector3.new(0, 3, 0))
        task.wait()
        RS.ShopEvent:FireServer("SellScraps", "Scraps")
        task.wait()
        hrp.CFrame = old
    end)
end

local function pickupScraps()
    pcall(function()
        for _, d in ipairs(WS:GetDescendants()) do
            if d:IsA("ProximityPrompt") and (d.Name:find("Scrap") or (d.ObjectText or ""):find("Scrap") or (d.ActionText or ""):find("Scrap")) then
                if fireproximityprompt then fireproximityprompt(d, 0) end
            end
        end
    end)
end

local function openShop()
    pcall(function()
        local char = gc(lp); if not char then return end
        local hrp = gh(char); if not hrp then return end
        local old = hrp.CFrame
        hrp.CFrame = CFrame.new(shopPos + Vector3.new(0, 3, 0))
        task.wait(0.3)
        for _, d in ipairs(WS.Map:GetDescendants()) do
            if d:IsA("ProximityPrompt") and ((d.ObjectText or ""):find("Shop") or (d.ActionText or ""):find("Shop") or d.Name:find("Shop")) then
                if fireproximityprompt then fireproximityprompt(d, 0) end
            end
        end
        task.wait(0.2)
        hrp.CFrame = old
    end)
end

local function restorePower()
    pcall(function()
        local hrp = gh(gc(lp)); if not hrp then return end
        local last = hrp.CFrame; hrp.Anchored = true
        hrp.CFrame = CFrame.new(-280.808014, 20.3924561, -212.159821)
        task.wait(0.3)
        local re = WS.Map:FindFirstChild("PowerStation")
        re = re and re:FindFirstChild("StationFolder")
        re = re and re:FindFirstChildWhichIsA("RemoteEvent")
        if re then
            re:FireServer("StationStart")
            re:FireServer("Start")
            re:FireServer("On")
        end
        for _, d in ipairs(WS.Map.PowerStation:GetDescendants()) do
            if d:IsA("ProximityPrompt") and fireproximityprompt then fireproximityprompt(d, 0) end
        end
        task.wait(20)
        hrp.CFrame = last; hrp.Anchored = false
    end)
end

local powerGUI, timerGUI, netStatsGUI

local function mkInfoLabel(name, posY, h)
    local sg = Instance.new("ScreenGui"); sg.Name = name; sg.ResetOnSpawn = false
    sg.Parent = lp:WaitForChild("PlayerGui")
    local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(0, 200, 0, h or 30)
    tl.Position = UDim2.new(0, 10, 0, posY); tl.BackgroundTransparency = 1
    tl.Font = Enum.Font.Arcade; tl.TextSize = 20; tl.TextColor3 = Color3.new(1, 1, 1)
    tl.TextStrokeTransparency = 0.3; tl.TextStrokeColor3 = Color3.new(0, 0, 0)
    tl.TextXAlignment = Enum.TextXAlignment.Left; tl.Text = "..."; tl.Parent = sg
    return sg, tl
end

local function findPowerValue()
    local st = WS:FindFirstChild("Map"); st = st and st:FindFirstChild("PowerStation"); st = st and st:FindFirstChild("StationFolder")
    if not st then return nil end
    for _, v in ipairs(st:GetChildren()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            local n = v.Name:lower()
            if n:match("power") or n:match("charge") or n:match("battery") or n:match("energy") or n:match("percent") or n:match("fuel") then
                return v
            end
        end
    end
    for _, v in ipairs(st:GetChildren()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then return v end
    end
    return nil
end

local function togglePowerGUI()
    if E.powerGUI then
        if powerGUI then powerGUI:Destroy() end
        local _, tl = mkInfoLabel("PowerGUI", 10, 30)
        powerGUI = tl
        task.spawn(function()
            while tl.Parent do
                pcall(function()
                    local pv = findPowerValue()
                    if pv then
                        tl.Text = pv.Name .. ": " .. tostring(pv.Value)
                    else
                        local sp = RS:FindFirstChild("StationPower")
                        tl.Text = "电力: " .. (sp and sp.Value and "ON" or "OFF")
                    end
                end)
                task.wait(0.3)
            end
        end)
    else
        if powerGUI then powerGUI:Destroy() powerGUI = nil end
    end
end

local function toggleTimerGUI()
    if E.timerGUI then
        if timerGUI then timerGUI:Destroy() end
        local _, tl = mkInfoLabel("NightTimerGUI", 40, 30)
        timerGUI = tl
        task.spawn(function()
            while tl.Parent do
                pcall(function()
                    local cl = RS:FindFirstChild("CurrentLightingProperties")
                    local ct = (cl and cl:FindFirstChild("ClockTime") and cl.ClockTime.Value) or Lighting.ClockTime
                    local h = math.floor(ct) % 24
                    local m = math.floor((ct - math.floor(ct)) * 60)
                    local bh = WS:FindFirstChild("Rake") and WS.Rake:FindFirstChild("BloodHourMode")
                    local phase = bh and bh.Value and "血夜" or ((ct >= 6 and ct < 18) and "白天" or "黑夜")
                    tl.Text = string.format("时间: %02d:%02d  %s", h, m, phase)
                end)
                task.wait(0.3)
            end
        end)
    else
        if timerGUI then timerGUI:Destroy() timerGUI = nil end
    end
end

local netConn
local function toggleNetStats()
    if E.netStats then
        if netStatsGUI then netStatsGUI:Destroy() end
        local sg = Instance.new("ScreenGui"); sg.Name = "NetStats"; sg.ResetOnSpawn = false; sg.Parent = lp:WaitForChild("PlayerGui")
        netStatsGUI = sg
        local tl = Instance.new("TextLabel"); tl.Size = UDim2.new(0, 200, 0, 60)
        tl.Position = UDim2.new(1, -210, 0, 10); tl.BackgroundTransparency = 1
        tl.Font = Enum.Font.Arcade; tl.TextSize = 20; tl.TextColor3 = Color3.new(1, 1, 1)
        tl.TextStrokeTransparency = 0.3; tl.TextStrokeColor3 = Color3.new(0, 0, 0)
        tl.TextXAlignment = Enum.TextXAlignment.Left; tl.LineHeight = 1.2; tl.Parent = sg
        local c = 0; local t = 0; local fps = 0
        if netConn then netConn:Disconnect() end
        netConn = RunS.RenderStepped:Connect(function(dt)
            c = c + 1; t = t + dt
            if t >= 0.5 then fps = math.floor(c / t); c = 0; t = 0 end
            local png = math.floor(lp:GetNetworkPing() * 1000)
            tl.Text = string.format("FPS:  %d\nPing: %d ms", fps, png)
        end)
    else
        if netConn then netConn:Disconnect() netConn = nil end
        if netStatsGUI then netStatsGUI:Destroy() netStatsGUI = nil end
    end
end

local function toggleLocationESP(name, pos, color)
    local ex = WS:FindFirstChild("LocESP_" .. name)
    if ex then ex:Destroy() return end
    local part = Instance.new("Part"); part.Name = "LocESP_" .. name; part.Anchored = true
    part.CanCollide = false; part.Transparency = 1; part.Position = pos; part.Parent = WS
    local b = Instance.new("BillboardGui"); b.Name = "ESP_BBG"; b.Size = UDim2.new(0, 100, 0, 20)
    b.StudsOffset = Vector3.new(0, 5, 0); b.AlwaysOnTop = true; b.MaxDistance = 4000; b.LightInfluence = 0; b.Parent = part
    local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.Text = name; l.TextColor3 = color or Color3.new(0, 1, 0)
    l.TextStrokeTransparency = 0; l.TextStrokeColor3 = Color3.new(0, 0, 0)
    l.Font = Enum.Font.Code; l.TextSize = 11; l.Parent = b
end

hookNoFall()
hookStamina()

task.spawn(function()
    task.wait(3)
    while true do
        task.wait(0.1)
        pcall(infStamina); pcall(updRake); pcall(updPlayer)
        pcall(doKillAura); pcall(doBugRake); pcall(doInstaKill); pcall(doClampKill)
        pcall(updHitbox); pcall(updTpWalk); pcall(updFOV)
        pcall(updNoclip); pcall(updVfly); pcall(doFling)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        pcall(updItem)
    end
end)

T1:Toggle({ Title = "无限体力", Value = true, Callback = function(v) E.stamina = v end })
T1:Toggle({ Title = "Rake ESP", Value = true, Callback = function(v)
    E.rakeEsp = v; if not v and rakeHrp then clrAll(rakeHrp, "ESP_BBG") rakeLbl = nil end
end })
T1:Toggle({ Title = "玩家 ESP", Value = true, Callback = function(v)
    E.playerEsp = v; if not v then for _, p in ipairs(P:GetPlayers()) do local h = gh(gc(p)); if h then clrAll(h, "ESP_BBG") end end end
end })
T1:Toggle({ Title = "物资 ESP", Value = true, Callback = function(v) E.itemEsp = v; if not v then clrAllDesc(WS, "IESP") end end })
T1:Toggle({ Title = "视野全亮", Value = true, Callback = function(v) toggleFullBright(v) end })
T1:Toggle({ Title = "防摔伤", Value = true, Callback = function(v) E.noFall = v end })
T1:Toggle({ Title = "FOV", Value = false, Callback = function(v) E.fov = v end })
T1:Slider({ Title = "视野值", Min = 70, Max = 120, Default = 100, Callback = function(v) V.fov = v end })
T1:Toggle({ Title = "甩飞玩家", Value = false, Callback = function(v) E.fling = v end })
T1:Toggle({ Title = "电力显示", Value = false, Callback = function(v) E.powerGUI = v togglePowerGUI() end })
T1:Toggle({ Title = "时间显示", Value = false, Callback = function(v) E.timerGUI = v toggleTimerGUI() end })
T1:Toggle({ Title = "FPS/Ping显示", Value = false, Callback = function(v) E.netStats = v toggleNetStats() end })
T1:Button({ Title = "远程开安全屋门", Callback = function() pcall(function() WS.Map.SafeHouse.Door.RemoteEvent:FireServer("Door") end) end })
T1:Button({ Title = "远程开安全屋灯", Callback = function() pcall(function() WS.Map.SafeHouse.Door.RemoteEvent:FireServer("Light") end) end })
T1:Button({ Title = "远程开塔灯", Callback = function() pcall(function() WS.Map.ObservationTower.Lights.RemoteEvent:FireServer("Light") end) end })
T1:Button({ Title = "恢复电力", Callback = function() restorePower() end })
T1:Button({ Title = "远程拾取废铁", Callback = function() pickupScraps() end })
T1:Button({ Title = "移除隐形墙", Callback = function()
    pcall(function()
        local iw = WS:FindFirstChild("Filter"); iw = iw and iw:FindFirstChild("InvisibleWalls")
        if iw then for _, v in ipairs(iw:GetChildren()) do v:Destroy() end end
    end)
end })

T2:Toggle({ Title = "Rake 范围攻击", Value = false, Callback = function(v) E.killAura = v end })
T2:Toggle({ Title = "Bug Rake", Value = false, Callback = function(v) E.bugRake = v end })
T2:Toggle({ Title = "秒杀 Rake", Value = false, Callback = function(v) E.instaKill = v end })
T2:Toggle({ Title = "夹子秒杀 Rake", Value = false, Callback = function(v) E.clampKill = v end })
T2:Toggle({ Title = "Rake 命中箱", Value = false, Callback = function(v) E.hitbox = v end })
T2:Slider({ Title = "命中箱大小", Min = 3, Max = 50, Default = 5, Callback = function(v) V.hitboxSize = v end })

T3:Dropdown({
    Title = "传送地点", Values = { "安全屋", "发电站", "基地营地", "商店", "观察塔" },
    Value = "安全屋", Callback = function(v)
        if v == "安全屋" then safeTP(CFrame.new(-363.491, 16.8744, 70.3037))
        elseif v == "发电站" then safeTP(CFrame.new(-281.6848, 21.5082, -212.7473))
        elseif v == "基地营地" then safeTP(CFrame.new(-70.7133, 17.6142, 209.0067))
        elseif v == "商店" then safeTP(CFrame.new(-25.1567, 17.2076, -258.362))
        elseif v == "观察塔" then safeTP(CFrame.new(42.63, 57.82, -50.22))
        end
    end
})

T4:Button({ Title = "呼出商店", Callback = function() openShop() end })
T4:Button({ Title = "远程兑换废铁为积分", Callback = function() sellScraps() end })
T4:Button({ Title = "远程拾取废铁", Callback = function() pickupScraps() end })

T6:Toggle({ Title = "安全屋", Value = false, Callback = function() toggleLocationESP("安全屋", Vector3.new(-363.491, 16.8744, 70.3037), Color3.new(0, 1, 0)) end })
T6:Toggle({ Title = "观察塔", Value = false, Callback = function() toggleLocationESP("观察塔", Vector3.new(42.63, 57.82, -50.22), Color3.new(0, 1, 1)) end })
T6:Toggle({ Title = "商店", Value = false, Callback = function() toggleLocationESP("商店", Vector3.new(-25.1567, 17.2076, -258.362), Color3.new(1, 1, 0)) end })
T6:Toggle({ Title = "基地营地", Value = false, Callback = function() toggleLocationESP("基地营地", Vector3.new(-70.7133, 17.6142, 209.0067), Color3.new(1, 0, 1)) end })
T6:Toggle({ Title = "发电站", Value = false, Callback = function() toggleLocationESP("发电站", Vector3.new(-281.6848, 21.5082, -212.7473), Color3.new(1, 0.4, 0)) end })
