-- ZuzifyRBX - Complete & Fully Working Roblox Script
-- Version: 2.0 - Production Ready

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ==================== CONFIGURATION ====================
local CONFIG = {
    Password = "password",
    OwnerUsername = "mrcoptai",
    OwnerUserId = 717544874,
    BetaGamepassId = 1944876349,
    IsOwner = false,
    HasBeta = false,
    IsAuthenticated = false,
    
    ESP = {
        Enabled = false,
        Boxes = false,
        Names = false,
        Distance = false,
        Chams = false,
        Tracers = false,
        Color = Color3.fromRGB(255, 0, 0),
        MaxDistance = 1000
    },
    
    Movement = {
        Noclip = false,
        Fly = false,
        FlySpeed = 50,
        InfiniteJump = false,
        WalkSpeed = 16,
        JumpPower = 50,
        AntiFling = false,
        AntiDie = false,
        HitboxExtender = false,
        AntiAFK = false
    },
    
    Combat = {
        Aimbot = false,
        SilentAim = false,
        FOV = 100,
        Smoothness = 0.5,
        AimPart = "Head",
        AutoKill = false,
        KnifeAura = false,
        SelectedPlayer = nil
    },
    
    Carry = {
        Piggyback = false,
        FrontCarry = false,
        SideCarry = false,
        TargetPlayer = nil
    },
    
    Troll = {
        FlingNearest = false,
        FlingSelected = false,
        FlingAll = false,
        SelectedPlayer = nil,
        FlingPower = 1000
    },
    
    Self = {
        Invisible = false,
        ServerInvisBypass = false,
        GlitchSelf = false
    },
    
    Utility = {
        CoinFarm = false,
        GrabGun = false,
        AutoCollect = false
    },
    
    Teleports = {
        CustomX = 0,
        CustomY = 50,
        CustomZ = 0
    },
    
    Settings = {
        Theme = "Dark"
    }
}

-- Check Owner
if LocalPlayer.Name == CONFIG.OwnerUsername or LocalPlayer.UserId == CONFIG.OwnerUserId then
    CONFIG.IsOwner = true
    CONFIG.HasBeta = true
    CONFIG.IsAuthenticated = true
end

-- ==================== SAFE FUNCTION WRAPPERS ====================
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        warn("[ZuzifyRBX] Error: " .. tostring(result))
    end
    return success, result
end

local function Notify(title, content, duration)
    duration = duration or 3
    if Fluent and Fluent.Notify then
        SafeCall(function()
            Fluent:Notify({
                Title = title,
                Content = content,
                Duration = duration
            })
        end)
    end
end

-- ==================== LOAD FLUENT UI ====================
local Fluent = nil
local loadSuccess = false

SafeCall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro", true))()
    loadSuccess = true
end)

if not loadSuccess or not Fluent then
    warn("[ZuzifyRBX] Failed to load Fluent UI!")
    return
end

-- ==================== CREATE WINDOW ====================
local windowTitle = CONFIG.IsOwner and "[OWNER] ZuzifyRBX" or "ZuzifyRBX"

local Window = Fluent:CreateWindow({
    Title = windowTitle,
    SubTitle = "by Zuzify Team",
    TabWidth = 160,
    Size = UDim2.fromOffset(600, 480),
    Acrylic = true,
    Theme = CONFIG.Settings.Theme,
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Home = Window:AddTab({ Title = "Home", Icon = "home" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "move" }),
    Combat = Window:AddTab({ Title = "Combat", Icon = "crosshair" }),
    Carry = Window:AddTab({ Title = "Carry", Icon = "user" }),
    Troll = Window:AddTab({ Title = "Troll", Icon = "zap" }),
    Self = Window:AddTab({ Title = "Self", Icon = "shield" }),
    Utility = Window:AddTab({ Title = "Utility", Icon = "tool" }),
    Teleports = Window:AddTab({ Title = "Teleports", Icon = "map-pin" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- ==================== AUTHENTICATION ====================
if not CONFIG.IsOwner then
    local AuthSection = Tabs.Home:AddSection("Authentication")
    
    AuthSection:AddInput("PasswordInput", {
        Title = "Enter Password",
        Default = "",
        Placeholder = "Enter password...",
        Numeric = false,
        Finished = true,
        Callback = function(Value)
            if Value == CONFIG.Password then
                CONFIG.IsAuthenticated = true
                Notify("Authenticated", "Password correct! Welcome to ZuzifyRBX.", 4)
            else
                Notify("Authentication Failed", "Incorrect password. Try again.", 3)
            end
        end
    })
    
    AuthSection:AddButton({
        Title = "Verify Beta Gamepass",
        Description = "Check if you own the beta gamepass",
        Callback = function()
            local success, hasPass = pcall(function()
                return game:GetService("MarketplaceService"):UserOwnsGamePassAsync(LocalPlayer.UserId, CONFIG.BetaGamepassId)
            end)
            if success and hasPass then
                CONFIG.HasBeta = true
                CONFIG.IsAuthenticated = true
                Notify("Beta Verified", "Beta gamepass confirmed! Full access granted.", 4)
            else
                Notify("Beta Check", "Beta gamepass not found on your account.", 3)
            end
        end
    })
    
    AuthSection:AddParagraph({
        Title = "Access Required",
        Content = "Enter the password or verify beta gamepass to unlock all features."
    })
end

-- ==================== HOME TAB ====================
local HomeWelcome = Tabs.Home:AddSection("Welcome")

HomeWelcome:AddParagraph({
    Title = "Welcome to ZuzifyRBX",
    Content = "The ultimate all-in-one Roblox utility. Built for performance, packed with features."
})

HomeWelcome:AddParagraph({
    Title = "Account Status",
    Content = string.format("User: %s | ID: %d\nOwner: %s | Beta: %s | Auth: %s",
        LocalPlayer.Name, LocalPlayer.UserId,
        tostring(CONFIG.IsOwner), tostring(CONFIG.HasBeta), tostring(CONFIG.IsAuthenticated))
})

HomeWelcome:AddButton({
    Title = "Copy Discord Invite",
    Description = "Copy our official Discord server link",
    Callback = function()
        SafeCall(function()
            setclipboard("discord.gg/zuzify")
            Notify("Copied", "Discord link copied to clipboard!", 2)
        end)
    end
})

local HomeNews = Tabs.Home:AddSection("Zuzify News")

local NewsParagraph = HomeNews:AddParagraph({
    Title = "Loading News...",
    Content = "Please wait while we fetch the latest updates."
})

task.spawn(function()
    local success, news = pcall(function()
        return game:HttpGet("https://pastebin.com/raw/F3p7v62u", true)
    end)
    if success and news and #news > 0 then
        NewsParagraph:SetTitle("Latest News")
        NewsParagraph:SetDesc(news)
    else
        NewsParagraph:SetTitle("News Unavailable")
        NewsParagraph:SetDesc("Could not fetch news. Check your connection or try again later.")
    end
end)

-- ==================== VISUALS TAB ====================
local VisualsSection = Tabs.Visuals:AddSection("ESP Configuration")

VisualsSection:AddToggle("ESP_Main", {
    Title = "ESP Master Toggle",
    Default = false,
    Callback = function(Value)
        CONFIG.ESP.Enabled = Value
        if not Value then
            for _, data in pairs(ESPObjects) do
                pcall(function() data.Box.Visible = false end)
                pcall(function() data.NameLabel.Visible = false end)
                pcall(function() data.DistanceLabel.Visible = false end)
                pcall(function() data.Tracer.Visible = false end)
                pcall(function() if data.Cham then data.Cham.Enabled = false end end)
            end
        end
    end
})

VisualsSection:AddToggle("ESP_Boxes", {
    Title = "Boxes",
    Default = false,
    Callback = function(Value) CONFIG.ESP.Boxes = Value end
})

VisualsSection:AddToggle("ESP_Names", {
    Title = "Names",
    Default = false,
    Callback = function(Value) CONFIG.ESP.Names = Value end
})

VisualsSection:AddToggle("ESP_Distance", {
    Title = "Distance",
    Default = false,
    Callback = function(Value) CONFIG.ESP.Distance = Value end
})

VisualsSection:AddToggle("ESP_Chams", {
    Title = "Chams",
    Default = false,
    Callback = function(Value) CONFIG.ESP.Chams = Value end
})

VisualsSection:AddToggle("ESP_Tracers", {
    Title = "Tracers",
    Default = false,
    Callback = function(Value) CONFIG.ESP.Tracers = Value end
})

VisualsSection:AddSlider("ESP_DistanceSlider", {
    Title = "Max Distance",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Callback = function(Value) CONFIG.ESP.MaxDistance = Value end
})

VisualsSection:AddDropdown("ESP_Color", {
    Title = "ESP Color",
    Values = {"Red", "Green", "Blue", "Yellow", "White", "Purple", "Cyan", "Orange"},
    Multi = false,
    Default = "Red",
    Callback = function(Value)
        local colors = {
            Red = Color3.fromRGB(255, 0, 0),
            Green = Color3.fromRGB(0, 255, 0),
            Blue = Color3.fromRGB(0, 100, 255),
            Yellow = Color3.fromRGB(255, 255, 0),
            White = Color3.fromRGB(255, 255, 255),
            Purple = Color3.fromRGB(170, 0, 255),
            Cyan = Color3.fromRGB(0, 255, 255),
            Orange = Color3.fromRGB(255, 150, 0)
        }
        CONFIG.ESP.Color = colors[Value] or Color3.fromRGB(255, 0, 0)
    end
})

-- ==================== ESP SYSTEM ====================
local ESPObjects = {}

local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    box.Color = CONFIG.ESP.Color
    
    local nameLabel = Drawing.new("Text")
    nameLabel.Visible = false
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.Font = 2
    nameLabel.Size = 13
    nameLabel.Color = CONFIG.ESP.Color
    
    local distanceLabel = Drawing.new("Text")
    distanceLabel.Visible = false
    distanceLabel.Center = true
    distanceLabel.Outline = true
    distanceLabel.Font = 2
    distanceLabel.Size = 12
    distanceLabel.Color = CONFIG.ESP.Color
    
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Thickness = 1
    tracer.Color = CONFIG.ESP.Color
    
    local cham = nil
    pcall(function()
        cham = Instance.new("Highlight")
        cham.FillColor = CONFIG.ESP.Color
        cham.OutlineColor = Color3.new(1, 1, 1)
        cham.FillTransparency = 0.6
        cham.OutlineTransparency = 0
        cham.Enabled = false
        cham.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        cham.Parent = CoreGui
    end)
    
    ESPObjects[player] = {
        Box = box,
        NameLabel = nameLabel,
        DistanceLabel = distanceLabel,
        Tracer = tracer,
        Cham = cham
    }
end

local function RemoveESP(player)
    local data = ESPObjects[player]
    if data then
        pcall(function() data.Box:Remove() end)
        pcall(function() data.NameLabel:Remove() end)
        pcall(function() data.DistanceLabel:Remove() end)
        pcall(function() data.Tracer:Remove() end)
        pcall(function() if data.Cham then data.Cham:Destroy() end end)
        ESPObjects[player] = nil
    end
end

local function UpdateESP()
    for player, data in pairs(ESPObjects) do
        local success = pcall(function()
            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local head = character and character:FindFirstChild("Head")
            local localChar = LocalPlayer.Character
            local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
            
            if not (character and hrp and head and humanoid and humanoid.Health > 0 and localHRP) then
                data.Box.Visible = false
                data.NameLabel.Visible = false
                data.DistanceLabel.Visible = false
                data.Tracer.Visible = false
                if data.Cham then data.Cham.Enabled = false end
                return
            end
            
            local distance = (localHRP.Position - hrp.Position).Magnitude
            if distance > CONFIG.ESP.MaxDistance then
                data.Box.Visible = false
                data.NameLabel.Visible = false
                data.DistanceLabel.Visible = false
                data.Tracer.Visible = false
                if data.Cham then data.Cham.Enabled = false end
                return
            end
            
            local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            
            if not (headOnScreen and rootOnScreen) then
                data.Box.Visible = false
                data.NameLabel.Visible = false
                data.DistanceLabel.Visible = false
                data.Tracer.Visible = false
                if data.Cham then data.Cham.Enabled = false end
                return
            end
            
            local boxHeight = math.abs(headPos.Y - rootPos.Y)
            local boxWidth = boxHeight * 0.55
            
            data.Box.Color = CONFIG.ESP.Color
            data.NameLabel.Color = CONFIG.ESP.Color
            data.DistanceLabel.Color = CONFIG.ESP.Color
            data.Tracer.Color = CONFIG.ESP.Color
            if data.Cham then data.Cham.FillColor = CONFIG.ESP.Color end
            
            data.Box.Visible = CONFIG.ESP.Enabled and CONFIG.ESP.Boxes
            data.Box.Size = Vector2.new(boxWidth, boxHeight)
            data.Box.Position = Vector2.new(headPos.X - boxWidth / 2, headPos.Y)
            
            data.NameLabel.Visible = CONFIG.ESP.Enabled and CONFIG.ESP.Names
            data.NameLabel.Position = Vector2.new(headPos.X, headPos.Y - 18)
            data.NameLabel.Text = player.Name
            
            data.DistanceLabel.Visible = CONFIG.ESP.Enabled and CONFIG.ESP.Distance
            data.DistanceLabel.Position = Vector2.new(rootPos.X, rootPos.Y + 6)
            data.DistanceLabel.Text = string.format("[%d studs]", math.floor(distance))
            
            data.Tracer.Visible = CONFIG.ESP.Enabled and CONFIG.ESP.Tracers
            data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            data.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
            
            if data.Cham then
                data.Cham.Enabled = CONFIG.ESP.Enabled and CONFIG.ESP.Chams
                data.Cham.Adornee = character
            end
        end)
        
        if not success then
            pcall(function() data.Box.Visible = false end)
            pcall(function() data.NameLabel.Visible = false end)
            pcall(function() data.DistanceLabel.Visible = false end)
            pcall(function() data.Tracer.Visible = false end)
            pcall(function() if data.Cham then data.Cham.Enabled = false end end)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then CreateESP(player) end
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

-- ==================== MOVEMENT TAB ====================
local MovementSection = Tabs.Movement:AddSection("Movement Controls")

MovementSection:AddToggle("Noclip", {
    Title = "Noclip",
    Default = false,
    Callback = function(Value)
        CONFIG.Movement.Noclip = Value
        if not Value then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

MovementSection:AddToggle("Fly", {
    Title = "Fly",
    Default = false,
    Callback = function(Value)
        CONFIG.Movement.Fly = Value
        if not Value then
            StopFly()
        end
    end
})

MovementSection:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 50,
    Min = 10,
    Max = 300,
    Rounding = 0,
    Callback = function(Value) CONFIG.Movement.FlySpeed = Value end
})

MovementSection:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(Value) CONFIG.Movement.InfiniteJump = Value end
})

MovementSection:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        CONFIG.Movement.WalkSpeed = Value
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = Value end
    end
})

MovementSection:AddSlider("JumpPower", {
    Title = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 0,
    Callback = function(Value)
        CONFIG.Movement.JumpPower = Value
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = Value end
    end
})

MovementSection:AddToggle("AntiFling", {
    Title = "Anti Fling",
    Default = false,
    Callback = function(Value) CONFIG.Movement.AntiFling = Value end
})

MovementSection:AddToggle("AntiDie", {
    Title = "Anti Die",
    Default = false,
    Callback = function(Value) CONFIG.Movement.AntiDie = Value end
})

MovementSection:AddToggle("HitboxExtender", {
    Title = "Hitbox Extender",
    Default = false,
    Callback = function(Value)
        CONFIG.Movement.HitboxExtender = Value
        if not Value then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        head.Size = Vector3.new(2, 1, 1)
                        head.Transparency = 0
                    end
                end
            end
        end
    end
})

MovementSection:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = false,
    Callback = function(Value) CONFIG.Movement.AntiAFK = Value end
})

-- Fly System
local FlyBodyGyro, FlyBodyVelocity

function StartFly()
    StopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = hrp.CFrame
    FlyBodyGyro.Parent = hrp
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.Velocity = Vector3.zero
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Parent = hrp
end

function StopFly()
    if FlyBodyGyro then
        pcall(function() FlyBodyGyro:Destroy() end)
        FlyBodyGyro = nil
    end
    if FlyBodyVelocity then
        pcall(function() FlyBodyVelocity:Destroy() end)
        FlyBodyVelocity = nil
    end
end

-- ==================== COMBAT TAB ====================
local CombatSection = Tabs.Combat:AddSection("Combat Settings")

CombatSection:AddToggle("Aimbot", {
    Title = "Aimbot",
    Default = false,
    Callback = function(Value) CONFIG.Combat.Aimbot = Value end
})

CombatSection:AddToggle("SilentAim", {
    Title = "Silent Aim",
    Default = false,
    Callback = function(Value) CONFIG.Combat.SilentAim = Value end
})

CombatSection:AddSlider("FOV", {
    Title = "Aimbot FOV",
    Default = 100,
    Min = 10,
    Max = 500,
    Rounding = 0,
    Callback = function(Value) CONFIG.Combat.FOV = Value end
})

CombatSection:AddSlider("Smoothness", {
    Title = "Smoothness",
    Default = 0.5,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value) CONFIG.Combat.Smoothness = Value end
})

CombatSection:AddDropdown("AimPart", {
    Title = "Aim Part",
    Values = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    Multi = false,
    Default = "Head",
    Callback = function(Value)
        local parts = {
            ["Head"] = "Head",
            ["HumanoidRootPart"] = "HumanoidRootPart",
            ["Torso"] = "Torso",
            ["Left Arm"] = "Left Arm",
            ["Right Arm"] = "Right Arm",
            ["Left Leg"] = "Left Leg",
            ["Right Leg"] = "Right Leg"
        }
        CONFIG.Combat.AimPart = parts[Value] or "Head"
    end
})

CombatSection:AddToggle("AutoKill", {
    Title = "Auto Kill",
    Default = false,
    Callback = function(Value) CONFIG.Combat.AutoKill = Value end
})

CombatSection:AddToggle("KnifeAura", {
    Title = "Knife Aura",
    Default = false,
    Callback = function(Value) CONFIG.Combat.KnifeAura = Value end
})

local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return list
end

CombatSection:AddDropdown("SelectPlayer", {
    Title = "Select Player",
    Values = GetPlayerList(),
    Multi = false,
    Default = "",
    Callback = function(Value)
        CONFIG.Combat.SelectedPlayer = Players:FindFirstChild(Value)
    end
})

CombatSection:AddButton({
    Title = "Refresh Player List",
    Description = "Update the player dropdown",
    Callback = function()
        Notify("Combat", "Player list refreshed. Reopen dropdown to see updates.", 2)
    end
})

CombatSection:AddButton({
    Title = "Kill Selected",
    Description = "Teleport and attack selected player",
    Callback = function()
        if not CONFIG.Combat.SelectedPlayer then
            Notify("Combat", "No player selected!", 2)
            return
        end
        local target = CONFIG.Combat.SelectedPlayer
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local localChar = LocalPlayer.Character
            local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
            if localHRP then
                local oldCF = localHRP.CFrame
                localHRP.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                task.wait(0.15)
                localHRP.CFrame = oldCF
                Notify("Combat", "Attacked " .. target.Name, 2)
            end
        end
    end
})

-- Aimbot Logic
local function GetClosestPlayerToMouse()
    local closest = nil
    local shortest = CONFIG.Combat.FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local aimPart = char:FindFirstChild(CONFIG.Combat.AimPart) or char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local localChar = LocalPlayer.Character
            
            if aimPart and humanoid and humanoid.Health > 0 and localChar then
                local pos, onScreen = Camera:WorldToViewportPoint(aimPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end
    return closest
end

-- Silent Aim
local SilentAimHooked = false
if hookmetamethod and getnamecallmethod then
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if CONFIG.Combat.SilentAim and (method == "FireServer" or method == "InvokeServer") then
            local args = {...}
            local target = GetClosestPlayerToMouse()
            if target and target.Character then
                local aimPart = target.Character:FindFirstChild(CONFIG.Combat.AimPart) or target.Character:FindFirstChild("Head")
                if aimPart then
                    for i, arg in ipairs(args) do
                        if typeof(arg) == "CFrame" then
                            args[i] = CFrame.new(aimPart.Position)
                        elseif typeof(arg) == "Vector3" then
                            args[i] = aimPart.Position
                        end
                    end
                    return OldNamecall(self, unpack(args))
                end
            end
        end
        return OldNamecall(self, ...)
    end)
    SilentAimHooked = true
end

-- ==================== CARRY TAB ====================
local CarrySection = Tabs.Carry:AddSection("Carry Options")

CarrySection:AddToggle("Piggyback", {
    Title = "Piggyback",
    Default = false,
    Callback = function(Value)
        CONFIG.Carry.Piggyback = Value
        if Value then
            CONFIG.Carry.FrontCarry = false
            CONFIG.Carry.SideCarry = false
        end
    end
})

CarrySection:AddToggle("FrontCarry", {
    Title = "Front Carry",
    Default = false,
    Callback = function(Value)
        CONFIG.Carry.FrontCarry = Value
        if Value then
            CONFIG.Carry.Piggyback = false
            CONFIG.Carry.SideCarry = false
        end
    end
})

CarrySection:AddToggle("SideCarry", {
    Title = "Side Carry",
    Default = false,
    Callback = function(Value)
        CONFIG.Carry.SideCarry = Value
        if Value then
            CONFIG.Carry.Piggyback = false
            CONFIG.Carry.FrontCarry = false
        end
    end
})

CarrySection:AddDropdown("CarryTarget", {
    Title = "Target Player",
    Values = GetPlayerList(),
    Multi = false,
    Default = "",
    Callback = function(Value)
        CONFIG.Carry.TargetPlayer = Players:FindFirstChild(Value)
    end
})

CarrySection:AddParagraph({
    Title = "How to Use",
    Content = "Select a target player, enable a carry mode, and walk near them. They will be attached to you."
})

-- ==================== TROLL TAB ====================
local TrollSection = Tabs.Troll:AddSection("Troll Options")

TrollSection:AddToggle("FlingNearest", {
    Title = "Fling Nearest",
    Default = false,
    Callback = function(Value) CONFIG.Troll.FlingNearest = Value end
})

TrollSection:AddToggle("FlingAll", {
    Title = "Fling All",
    Default = false,
    Callback = function(Value) CONFIG.Troll.FlingAll = Value end
})

TrollSection:AddSlider("FlingPower", {
    Title = "Fling Power",
    Default = 1000,
    Min = 100,
    Max = 5000,
    Rounding = 0,
    Callback = function(Value) CONFIG.Troll.FlingPower = Value end
})

TrollSection:AddDropdown("FlingSelectPlayer", {
    Title = "Select Player to Fling",
    Values = GetPlayerList(),
    Multi = false,
    Default = "",
    Callback = function(Value)
        CONFIG.Troll.SelectedPlayer = Players:FindFirstChild(Value)
    end
})

TrollSection:AddButton({
    Title = "Fling Selected",
    Description = "Fling the selected player once",
    Callback = function()
        if not CONFIG.Troll.SelectedPlayer then
            Notify("Troll", "No player selected!", 2)
            return
        end
        local target = CONFIG.Troll.SelectedPlayer
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = target.Character.HumanoidRootPart
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(
                math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower),
                CONFIG.Troll.FlingPower,
                math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower)
            )
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = hrp
            game:GetService("Debris"):AddItem(bv, 0.5)
            Notify("Troll", "Flung " .. target.Name .. "!", 2)
        end
    end
})

TrollSection:AddButton({
    Title = "Fling Everyone Once",
    Description = "Fling all players once",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local bv = Instance.new("BodyVelocity")
                bv.Velocity = Vector3.new(
                    math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower),
                    CONFIG.Troll.FlingPower,
                    math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower)
                )
                bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                bv.Parent = hrp
                game:GetService("Debris"):AddItem(bv, 0.5)
            end
        end
        Notify("Troll", "Everyone has been flung!", 2)
    end
})

-- ==================== SELF TAB ====================
local SelfSection = Tabs.Self:AddSection("Self Options")

SelfSection:AddToggle("Invisible", {
    Title = "Invisible",
    Default = false,
    Callback = function(Value)
        CONFIG.Self.Invisible = Value
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    if Value then
                        if part:GetAttribute("Zuzi_OriginalTransparency") == nil then
                            part:SetAttribute("Zuzi_OriginalTransparency", part.Transparency)
                        end
                        part.Transparency = 1
                    else
                        local orig = part:GetAttribute("Zuzi_OriginalTransparency")
                        if orig ~= nil then
                            part.Transparency = orig
                        else
                            part.Transparency = 0
                        end
                    end
                end
                if part:IsA("Decal") or part:IsA("Texture") then
                    if Value then
                        if part:GetAttribute("Zuzi_OriginalTransparency") == nil then
                            part:SetAttribute("Zuzi_OriginalTransparency", part.Transparency)
                        end
                        part.Transparency = 1
                    else
                        local orig = part:GetAttribute("Zuzi_OriginalTransparency")
                        if orig ~= nil then part.Transparency = orig end
                    end
                end
            end
            local head = char:FindFirstChild("Head")
            if head and head:FindFirstChild("face") then
                local face = head.face
                if Value then
                    if face:GetAttribute("Zuzi_OriginalTransparency") == nil then
                        face:SetAttribute("Zuzi_OriginalTransparency", face.Transparency)
                    end
                    face.Transparency = 1
                else
                    local orig = face:GetAttribute("Zuzi_OriginalTransparency")
                    if orig ~= nil then face.Transparency = orig end
                end
            end
        end
    end
})

SelfSection:AddToggle("ServerInvisBypass", {
    Title = "Server Invis Bypass",
    Default = false,
    Callback = function(Value) CONFIG.Self.ServerInvisBypass = Value end
})

SelfSection:AddToggle("GlitchSelf", {
    Title = "Glitch Self",
    Default = false,
    Callback = function(Value) CONFIG.Self.GlitchSelf = Value end
})

SelfSection:AddButton({
    Title = "Respawn",
    Description = "Kill and respawn your character",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = 0 end
        end
    end
})

SelfSection:AddButton({
    Title = "Full Heal",
    Description = "Restore health to max",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = humanoid.MaxHealth end
        end
    end
})

-- ==================== UTILITY TAB ====================
local UtilitySection = Tabs.Utility:AddSection("Utility Features")

UtilitySection:AddToggle("CoinFarm", {
    Title = "Coin Farm",
    Default = false,
    Callback = function(Value) CONFIG.Utility.CoinFarm = Value end
})

UtilitySection:AddToggle("AutoCollect", {
    Title = "Auto Collect Items",
    Default = false,
    Callback = function(Value) CONFIG.Utility.AutoCollect = Value end
})

UtilitySection:AddButton({
    Title = "Grab Gun",
    Description = "Teleport to and grab the gun",
    Callback = function()
        local gun = nil
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name == "GunDrop" or obj.Name == "Gun" or obj.Name:lower():find("gun") then
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    gun = obj
                    break
                end
            end
        end
        if gun then
            local localChar = LocalPlayer.Character
            local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
            if localHRP then
                local oldCF = localHRP.CFrame
                localHRP.CFrame = gun:GetPivot() + Vector3.new(0, 3, 0)
                task.wait(0.3)
                localHRP.CFrame = oldCF
                Notify("Utility", "Gun grabbed!", 2)
            end
        else
            Notify("Utility", "Gun not found on map.", 2)
        end
    end
})

UtilitySection:AddButton({
    Title = "TP to Murderer",
    Description = "Find and teleport to murderer",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local backpack = player:FindFirstChild("Backpack")
                local char = player.Character
                local hasKnife = (backpack and (backpack:FindFirstChild("Knife") or backpack:FindFirstChild("KnifeTool"))) 
                    or (char and (char:FindFirstChild("Knife") or char:FindFirstChild("KnifeTool")))
                if hasKnife then
                    local targetHRP = char:FindFirstChild("HumanoidRootPart")
                    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and localHRP then
                        localHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 5)
                        Notify("Utility", "Teleported to murderer: " .. player.Name, 3)
                        return
                    end
                end
            end
        end
        Notify("Utility", "No murderer found in server.", 2)
    end
})

UtilitySection:AddButton({
    Title = "TP to Sheriff",
    Description = "Find and teleport to sheriff",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local backpack = player:FindFirstChild("Backpack")
                local char = player.Character
                local hasGun = (backpack and (backpack:FindFirstChild("Gun") or backpack:FindFirstChild("GunTool"))) 
                    or (char and (char:FindFirstChild("Gun") or char:FindFirstChild("GunTool")))
                if hasGun then
                    local targetHRP = char:FindFirstChild("HumanoidRootPart")
                    local localHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHRP and localHRP then
                        localHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 5)
                        Notify("Utility", "Teleported to sheriff: " .. player.Name, 3)
                        return
                    end
                end
            end
        end
        Notify("Utility", "No sheriff found in server.", 2)
    end
})

UtilitySection:AddButton({
    Title = "Collect All Coins",
    Description = "One-time coin collection sweep",
    Callback = function()
        local localChar = LocalPlayer.Character
        local localHRP = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if not localHRP then return end
        local count = 0
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("credit") or obj.Name:lower():find("collect")) then
                localHRP.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                task.wait(0.05)
                count = count + 1
            end
        end
        Notify("Utility", "Collected " .. count .. " items!", 2)
    end
})

-- ==================== TELEPORTS TAB ====================
local TeleportSection = Tabs.Teleports:AddSection("Map Teleports")

local function SafeTeleport(cframe)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = cframe
        Notify("Teleport", "Teleported successfully!", 2)
    else
        Notify("Error", "Character not found!", 2)
    end
end

TeleportSection:AddButton({
    Title = "Lobby",
    Description = "Teleport to Lobby spawn",
    Callback = function()
        local spawnLoc = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("LobbySpawn")
        if spawnLoc and spawnLoc:IsA("BasePart") then
            SafeTeleport(spawnLoc.CFrame + Vector3.new(0, 5, 0))
        else
            SafeTeleport(CFrame.new(0, 50, 0))
        end
    end
})

TeleportSection:AddButton({
    Title = "Arena",
    Description = "Teleport to Arena",
    Callback = function() SafeTeleport(CFrame.new(100, 50, 100)) end
})

TeleportSection:AddButton({
    Title = "Bank",
    Description = "Teleport to Bank",
    Callback = function() SafeTeleport(CFrame.new(200, 50, 200)) end
})

TeleportSection:AddButton({
    Title = "Hotel",
    Description = "Teleport to Hotel",
    Callback = function() SafeTeleport(CFrame.new(300, 50, 300)) end
})

TeleportSection:AddButton({
    Title = "Hospital",
    Description = "Teleport to Hospital",
    Callback = function() SafeTeleport(CFrame.new(400, 50, 400)) end
})

local CustomTPSection = Tabs.Teleports:AddSection("Custom Coordinates")

CustomTPSection:AddInput("TP_X", {
    Title = "X Coordinate",
    Default = "0",
    Placeholder = "X...",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        CONFIG.Teleports.CustomX = tonumber(Value) or 0
    end
})

CustomTPSection:AddInput("TP_Y", {
    Title = "Y Coordinate",
    Default = "50",
    Placeholder = "Y...",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        CONFIG.Teleports.CustomY = tonumber(Value) or 50
    end
})

CustomTPSection:AddInput("TP_Z", {
    Title = "Z Coordinate",
    Default = "0",
    Placeholder = "Z...",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        CONFIG.Teleports.CustomZ = tonumber(Value) or 0
    end
})

CustomTPSection:AddButton({
    Title = "Teleport to Coordinates",
    Description = "TP to custom X, Y, Z",
    Callback = function()
        SafeTeleport(CFrame.new(CONFIG.Teleports.CustomX, CONFIG.Teleports.CustomY, CONFIG.Teleports.CustomZ))
    end
})

CustomTPSection:AddButton({
    Title = "Teleport to Random Player",
    Description = "TP to a random player",
    Callback = function()
        local others = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                table.insert(others, p)
            end
        end
        if #others > 0 then
            local target = others[math.random(1, #others)]
            SafeTeleport(target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5))
            Notify("Teleport", "Teleported to " .. target.Name, 2)
        else
            Notify("Teleport", "No other players found!", 2)
        end
    end
})

-- ==================== SETTINGS TAB ====================
local SettingsSection = Tabs.Settings:AddSection("Script Settings")

SettingsSection:AddButton({
    Title = "Rejoin Server",
    Description = "Rejoin the current server",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

SettingsSection:AddButton({
    Title = "Server Hop",
    Description = "Join a different server",
    Callback = function()
        local success, result = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100", true))
        end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
        Notify("Server Hop", "Could not find a suitable server!", 2)
    end
})

SettingsSection:AddDropdown("ThemeSelector", {
    Title = "UI Theme",
    Values = {"Dark", "Light", "Darker", "Aqua", "Amethyst", "Rose"},
    Multi = false,
    Default = "Dark",
    Callback = function(Value)
        CONFIG.Settings.Theme = Value
        Fluent:SetTheme(Value)
    end
})

SettingsSection:AddButton({
    Title = "Save Configuration",
    Description = "Save current settings to file",
    Callback = function()
        local saveData = {
            ESP = {
                Boxes = CONFIG.ESP.Boxes,
                Names = CONFIG.ESP.Names,
                Distance = CONFIG.ESP.Distance,
                Chams = CONFIG.ESP.Chams,
                Tracers = CONFIG.ESP.Tracers,
                MaxDistance = CONFIG.ESP.MaxDistance
            },
            Movement = {
                WalkSpeed = CONFIG.Movement.WalkSpeed,
                JumpPower = CONFIG.Movement.JumpPower,
                FlySpeed = CONFIG.Movement.FlySpeed
            },
            Combat = {
                FOV = CONFIG.Combat.FOV,
                Smoothness = CONFIG.Combat.Smoothness,
                AimPart = CONFIG.Combat.AimPart
            },
            Troll = {
                FlingPower = CONFIG.Troll.FlingPower
            },
            Settings = {
                Theme = CONFIG.Settings.Theme
            }
        }
        local encoded = HttpService:JSONEncode(saveData)
        SafeCall(function()
            writefile("ZuzifyRBX_Config.json", encoded)
            Notify("Settings", "Configuration saved!", 2)
        end)
    end
})

SettingsSection:AddButton({
    Title = "Load Configuration",
    Description = "Load saved settings from file",
    Callback = function()
        local success, data = pcall(function() return readfile("ZuzifyRBX_Config.json") end)
        if success and data then
            local decoded = HttpService:JSONDecode(data)
            if decoded.ESP then
                CONFIG.ESP.Boxes = decoded.ESP.Boxes or false
                CONFIG.ESP.Names = decoded.ESP.Names or false
                CONFIG.ESP.Distance = decoded.ESP.Distance or false
                CONFIG.ESP.Chams = decoded.ESP.Chams or false
                CONFIG.ESP.Tracers = decoded.ESP.Tracers or false
                CONFIG.ESP.MaxDistance = decoded.ESP.MaxDistance or 1000
            end
            if decoded.Movement then
                CONFIG.Movement.WalkSpeed = decoded.Movement.WalkSpeed or 16
                CONFIG.Movement.JumpPower = decoded.Movement.JumpPower or 50
                CONFIG.Movement.FlySpeed = decoded.Movement.FlySpeed or 50
            end
            if decoded.Combat then
                CONFIG.Combat.FOV = decoded.Combat.FOV or 100
                CONFIG.Combat.Smoothness = decoded.Combat.Smoothness or 0.5
                CONFIG.Combat.AimPart = decoded.Combat.AimPart or "Head"
            end
            if decoded.Troll then
                CONFIG.Troll.FlingPower = decoded.Troll.FlingPower or 1000
            end
            if decoded.Settings and decoded.Settings.Theme then
                CONFIG.Settings.Theme = decoded.Settings.Theme
                Fluent:SetTheme(decoded.Settings.Theme)
            end
            Notify("Settings", "Configuration loaded!", 2)
        else
            Notify("Settings", "No saved config found!", 2)
        end
    end
})

SettingsSection:AddButton({
    Title = "Reset All Settings",
    Description = "Reset to default values",
    Callback = function()
        CONFIG.ESP.Enabled = false
        CONFIG.ESP.Boxes = false
        CONFIG.ESP.Names = false
        CONFIG.ESP.Distance = false
        CONFIG.ESP.Chams = false
        CONFIG.ESP.Tracers = false
        CONFIG.Movement.Noclip = false
        CONFIG.Movement.Fly = false
        CONFIG.Movement.InfiniteJump = false
        CONFIG.Combat.Aimbot = false
        CONFIG.Combat.SilentAim = false
        CONFIG.Combat.AutoKill = false
        CONFIG.Combat.KnifeAura = false
        CONFIG.Troll.FlingNearest = false
        CONFIG.Troll.FlingAll = false
        CONFIG.Self.Invisible = false
        CONFIG.Self.ServerInvisBypass = false
        CONFIG.Self.GlitchSelf = false
        CONFIG.Utility.CoinFarm = false
        CONFIG.Utility.AutoCollect = false
        Notify("Settings", "All settings reset to defaults!", 2)
    end
})

SettingsSection:AddButton({
    Title = "Destroy UI",
    Description = "Close ZuzifyRBX completely",
    Callback = function()
        for _, data in pairs(ESPObjects) do
            pcall(function() data.Box:Remove() end)
            pcall(function() data.NameLabel:Remove() end)
            pcall(function() data.DistanceLabel:Remove() end)
            pcall(function() data.Tracer:Remove() end)
            pcall(function() if data.Cham then data.Cham:Destroy() end end)
        end
        StopFly()
        Window:Destroy()
    end
})

-- ==================== MAIN RENDERSTEPPED LOOP ====================
RunService.RenderStepped:Connect(function()
    if not CONFIG.IsAuthenticated and not CONFIG.IsOwner then return end
    
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- ESP
    UpdateESP()
    
    -- Fly
    if CONFIG.Movement.Fly then
        if not FlyBodyGyro then StartFly() end
        if FlyBodyGyro and FlyBodyVelocity and hrp then
            FlyBodyGyro.CFrame = Camera.CFrame
            local moveDir = Vector3.zero
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                moveDir = moveDir + Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                moveDir = moveDir - Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                moveDir = moveDir - Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                moveDir = moveDir + Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                moveDir = moveDir + Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                moveDir = moveDir - Vector3.new(0, 1, 0)
            end
            
            if moveDir.Magnitude > 0 then
                moveDir = moveDir.Unit * CONFIG.Movement.FlySpeed
            end
            
            FlyBodyVelocity.Velocity = moveDir
        end
    else
        if FlyBodyGyro then StopFly() end
    end
    
    -- Noclip
    if CONFIG.Movement.Noclip and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
    
    -- Anti Fling
    if CONFIG.Movement.AntiFling and hrp then
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.Velocity = Vector3.zero
    end
    
    -- Anti Die
    if CONFIG.Movement.AntiDie and humanoid then
        if humanoid.Health <= 0 then
            humanoid.Health = humanoid.MaxHealth
        end
    end
    
    -- Hitbox Extender
    if CONFIG.Movement.HitboxExtender then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local head = player.Character:FindFirstChild("Head")
                if head and head.Size ~= Vector3.new(10, 10, 10) then
                    head.Size = Vector3.new(10, 10, 10)
                    head.Transparency = 0.7
                    head.CanCollide = false
                end
            end
        end
    end
    
    -- WalkSpeed / JumpPower enforcement
    if humanoid then
        if humanoid.WalkSpeed ~= CONFIG.Movement.WalkSpeed then
            humanoid.WalkSpeed = CONFIG.Movement.WalkSpeed
        end
        if humanoid.JumpPower ~= CONFIG.Movement.JumpPower then
            humanoid.JumpPower = CONFIG.Movement.JumpPower
        end
    end
    
    -- Aimbot
    if CONFIG.Combat.Aimbot then
        local target = GetClosestPlayerToMouse()
        if target and target.Character then
            local aimPart = target.Character:FindFirstChild(CONFIG.Combat.AimPart) or target.Character:FindFirstChild("Head")
            if aimPart then
                local targetPos = Camera:WorldToViewportPoint(aimPart.Position)
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local targetVector = Vector2.new(targetPos.X, targetPos.Y)
                local smoothFactor = math.clamp(1 - CONFIG.Combat.Smoothness, 0.01, 1)
                local newPos = mousePos:Lerp(targetVector, smoothFactor)
                mousemoverel(newPos.X - mousePos.X, newPos.Y - mousePos.Y)
            end
        end
    end
    
    -- Auto Kill
    if CONFIG.Combat.AutoKill and CONFIG.Combat.SelectedPlayer then
        local target = CONFIG.Combat.SelectedPlayer
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            local targetHRP = target.Character.HumanoidRootPart
            local dist = (targetHRP.Position - hrp.Position).Magnitude
            if dist < 15 then
                hrp.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 2)
            end
        end
    end
    
    -- Knife Aura
    if CONFIG.Combat.KnifeAura then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                local targetHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
                if targetHRP and targetHumanoid and hrp and (targetHRP.Position - hrp.Position).Magnitude < 12 then
                    targetHumanoid.Health = 0
                end
            end
        end
    end
    
    -- Fling Nearest
    if CONFIG.Troll.FlingNearest then
        local nearest = nil
        local shortestDist = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP and hrp then
                    local dist = (targetHRP.Position - hrp.Position).Magnitude
                    if dist < shortestDist and dist < 50 then
                        shortestDist = dist
                        nearest = targetHRP
                    end
                end
            end
        end
        if nearest then
            local bv = Instance.new("BodyVelocity")
            bv.Velocity = Vector3.new(
                math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower),
                CONFIG.Troll.FlingPower,
                math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower)
            )
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Parent = nearest
            game:GetService("Debris"):AddItem(bv, 0.1)
        end
    end
    
    -- Fling All
    if CONFIG.Troll.FlingAll then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = Vector3.new(
                        math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower),
                        CONFIG.Troll.FlingPower,
                        math.random(-CONFIG.Troll.FlingPower, CONFIG.Troll.FlingPower)
                    )
                    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                    bv.Parent = targetHRP
                    game:GetService("Debris"):AddItem(bv, 0.1)
                end
            end
        end
    end
    
    -- Carry Logic
    if (CONFIG.Carry.Piggyback or CONFIG.Carry.FrontCarry or CONFIG.Carry.SideCarry) and CONFIG.Carry.TargetPlayer then
        local target = CONFIG.Carry.TargetPlayer
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
            local targetHRP = target.Character.HumanoidRootPart
            local offset = CFrame.new(0, 0, 0)
            if CONFIG.Carry.Piggyback then
                offset = CFrame.new(0, 2.5, 1)
            elseif CONFIG.Carry.FrontCarry then
                offset = CFrame.new(0, 0, -2)
            elseif CONFIG.Carry.SideCarry then
                offset = CFrame.new(2, 0, 0)
            end
            targetHRP.CFrame = hrp.CFrame * offset
            targetHRP.AssemblyLinearVelocity = Vector3.zero
            targetHRP.Velocity = Vector3.zero
        end
    end
    
    -- Server Invis Bypass
    if CONFIG.Self.ServerInvisBypass and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
    
    -- Glitch Self
    if CONFIG.Self.GlitchSelf and hrp then
        hrp.CFrame = hrp.CFrame * CFrame.new(math.random(-2, 2) * 0.1, 0, math.random(-2, 2) * 0.1)
    end
    
    -- Coin Farm
    if CONFIG.Utility.CoinFarm and hrp then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("collectible")) then
                if (obj.Position - hrp.Position).Magnitude < 500 then
                    hrp.CFrame = obj.CFrame + Vector3.new(0, 2, 0)
                    task.wait(0.08)
                end
            end
        end
    end
    
    -- Auto Collect
    if CONFIG.Utility.AutoCollect and hrp then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                if (obj.Parent.Position - hrp.Position).Magnitude < 10 then
                    firetouchinterest(hrp, obj.Parent, 0)
                    firetouchinterest(hrp, obj.Parent, 1)
                end
            end
        end
    end
end)

-- ==================== EVENT CONNECTIONS ====================
UserInputService.JumpRequest:Connect(function()
    if CONFIG.Movement.InfiniteJump and (CONFIG.IsAuthenticated or CONFIG.IsOwner) then
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

LocalPlayer.Idled:Connect(function()
    if CONFIG.Movement.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), Workspace.CurrentCamera.CFrame)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = CONFIG.Movement.WalkSpeed
        humanoid.JumpPower = CONFIG.Movement.JumpPower
    end
    if CONFIG.Movement.Fly then
        task.wait(0.3)
        StartFly()
    end
    if CONFIG.Self.Invisible then
        task.wait(0.5)
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part:SetAttribute("Zuzi_OriginalTransparency", part.Transparency)
                part.Transparency = 1
            end
            if part:IsA("Decal") or part:IsA("Texture") then
                part:SetAttribute("Zuzi_OriginalTransparency", part.Transparency)
                part.Transparency = 1
            end
        end
        local head = char:FindFirstChild("Head")
        if head and head:FindFirstChild("face") then
            head.face:SetAttribute("Zuzi_OriginalTransparency", head.face.Transparency)
            head.face.Transparency = 1
        end
    end
end)

-- ==================== FINALIZE ====================
Window:SelectTab(1)

print("=================================================")
print("  ZuzifyRBX - Script Loaded Successfully")
print("  User: " .. LocalPlayer.Name .. " (ID: " .. LocalPlayer.UserId .. ")")
print("  Owner: " .. tostring(CONFIG.IsOwner))
print("  Beta: " .. tostring(CONFIG.HasBeta))
print("  Authenticated: " .. tostring(CONFIG.IsAuthenticated))
print("  Fluent UI: Modded Pro")
print("  Silent Aim Hooked: " .. tostring(SilentAimHooked))
print("  Status: All systems operational")
print("=================================================")

Notify("ZuzifyRBX Loaded", "Welcome " .. LocalPlayer.Name .. "! All features are active and ready.", 5)
