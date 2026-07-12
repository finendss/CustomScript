local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Window = WindUI:CreateWindow({
    Title = "末世生存",
    Icon = "sparkles",
    Author = "BY.BOBO工作室",
    Folder = "DefenseSystem",
    Size = UDim2.fromOffset(400, 400),
    Theme = "Dark",
})

Window:ToggleTransparency(true)

local TimeTag = Window:Tag({
    Title = "00:00",
    Color = Color3.fromHex("#30ff6a")
})

local hue = 0
task.spawn(function()
    while true do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        
        hue = (hue + 0.01) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        
        TimeTag:SetTitle(hours .. ":" .. minutes)
        TimeTag:SetColor(rainbowColor) 

        task.wait(0.06)
    end
end)

Window:Tag({
    Title = "定制",
    Color = Color3.fromHex("#FFD700")
})

task.wait(0.3)

Window:EditOpenButton({
    Title = "末世生存",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

task.wait(0.2)

local Tab = Window:Tab({
    Title = "主要",
    Icon = "settings",
    Locked = false,
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Range = 50
local AuraEnabled = false
local Connection = nil
local LastAttackTime = 0
local ATTACK_COOLDOWN = 0.15

local function GetWeapon()
    local char = LocalPlayer.Character
    if char then
        local bat = char:FindFirstChild("Bat")
        if bat then return bat end
    end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local bat = backpack:FindFirstChild("Bat")
        if bat then return bat end
    end
    return nil
end

local function StartAura()
    if Connection then return end
    
    Connection = RunService.Heartbeat:Connect(function()
        if not AuraEnabled then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local charactersFolder = workspace:FindFirstChild("Characters")
        if not charactersFolder then return end
        
        local nearbyZombies = {}
        local index = 1
        
        for _, zombie in pairs(charactersFolder:GetChildren()) do
            if zombie.Name == "Zombie" or zombie.Name == "Crawler" then
                local zHumanoid = zombie:FindFirstChild("Humanoid")
                local zRoot = zombie:FindFirstChild("HumanoidRootPart")
                
                if zHumanoid and zHumanoid.Health > 0 and zRoot then
                    if (rootPart.Position - zRoot.Position).Magnitude <= Range then
                        nearbyZombies[index] = zombie
                        index = index + 1
                    end
                end
            end
        end
        
        if #nearbyZombies == 0 then return end
        
        local autoTarget = char:FindFirstChild("AutoTargetClient")
        if autoTarget then
            local updateNearby = autoTarget:FindFirstChild("UpdateNearbyTargets")
            if updateNearby then
                pcall(function() updateNearby:FireServer(nearbyZombies) end)
            end
        end
        
        if os.clock() - LastAttackTime >= ATTACK_COOLDOWN then
            local bat = GetWeapon()
            if bat then
                local swing = bat:FindFirstChild("Swing")
                local hitTargets = bat:FindFirstChild("HitTargets")
                
                if swing and hitTargets then
                    LastAttackTime = os.clock()
                    
                    pcall(function()
                        swing:FireServer()
                        hitTargets:FireServer(nearbyZombies)
                        for _, targetZombie in ipairs(nearbyZombies) do
                            hitTargets:FireServer({targetZombie})
                        end
                    end)
                end
            end
        end
    end)
end

local function StopAura()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
end

Tab:Slider({
    Title = "光环范围",
    Value = {
        Min = 30,
        Max = 400,
        Default = 50,
    },
    Increment = 1,
    Callback = function(value)
        Range = value
    end
})

Tab:Toggle({
    Title = "杀戮光环",
    Default = false,
    Callback = function(state)
        AuraEnabled = state
        if state then
            StartAura()
        else
            StopAura()
        end
    end
})
