--[[
    ZuzifyMoon
    Authors: Tai (vertexi8) & daviddabag
    Password protected + Owner system
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- ================= PASSWORD + OWNER CHECK =================
local CORRECT_PASSWORD = "password"
local OWNER_USERNAME = "mrcoptai"
local OWNER_USERID = 717544874

local isOwner = (LocalPlayer.Name:lower() == OWNER_USERNAME:lower()) or (LocalPlayer.UserId == OWNER_USERID)
local passwordPassed = false

-- Simple password prompt using a temporary ScreenGui
local function AskPassword()
    local screen = Instance.new("ScreenGui")
    screen.Name = "ZM_Password"
    screen.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 320, 0, 160)
    frame.Position = UDim2.new(0.5, -160, 0.5, -80)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screen

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyMoon - Enter Password"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.8, 0, 0, 36)
    box.Position = UDim2.new(0.1, 0, 0.4, 0)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = "Password..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.ClearTextOnFocus = false
    box.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.8, 0, 0, 36)
    btn.Position = UDim2.new(0.1, 0, 0.7, 0)
    btn.BackgroundColor3 = Color3.fromRGB(80, 40, 120)
    btn.Text = "Unlock"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = frame

    local result = Instance.new("BindableEvent")

    btn.MouseButton1Click:Connect(function()
        if box.Text == CORRECT_PASSWORD or isOwner then
            passwordPassed = true
            screen:Destroy()
            result:Fire(true)
        else
            box.Text = ""
            box.PlaceholderText = "Wrong password"
        end
    end)

    box.FocusLost:Connect(function(enter)
        if enter then
            if box.Text == CORRECT_PASSWORD or isOwner then
                passwordPassed = true
                screen:Destroy()
                result:Fire(true)
            else
                box.Text = ""
                box.PlaceholderText = "Wrong password"
            end
        end
    end)

    return result.Event:Wait()
end

if not isOwner then
    AskPassword()
    if not passwordPassed then
        return -- stop script if password fails
    end
end

-- Owner gets everything unlocked by default
if isOwner then
    print("[ZuzifyMoon] Owner access granted for " .. LocalPlayer.Name)
end

-- Load Modal
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

local Window = Modal:CreateWindow({
    Title = "ZuzifyMoon" .. (isOwner and " [OWNER]" or ""),
    SubTitle = "by Tai (vertexi8) & daviddabag",
    Size = UDim2.fromOffset(630, 610),
    MinimumSize = Vector2.new(430, 410),
    Transparency = 0,
    Icon = "rbxassetid://68073547",
})

Window:SetTheme("Rose")

local Features = {
    -- ESP
    ESP = false,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Chams = false,
    ESP_Tracers = false,
    ESP_Boxes = false,
    ESP_Skeleton = false,
    ESP_Hitbox = false,
    ESP_Health = false,

    -- Movement
    Noclip = false,
    Fly = false,
    FlySpeed = 65,
    InfiniteJump = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AntiAFK = false,
    AntiFling = true,
    HitboxExtender = false,
    HitboxSize = 10,

    -- Aimbot
    Aimbot = false,
    SilentAim = false,
    AimbotFOV = 250,
    AimbotSmooth = 0.12,
    AimbotPrediction = 0.16,
    AimPart = "HumanoidRootPart",
    AimPriority = "Closest",
    AimVisibleOnly = false,
    AimOnlyWhenTool = false,

    -- Combat
    AutoKill = false,
    KnifeAura = false,
    AuraRange = 16,
    KillTarget = false,
    SelectedTarget = nil,
    FlingNearest = false,
    FlingTarget = false,
    FlingAll = false,

    -- Utility
    GrabGun = false,
    CoinFarm = false,
    TPMurderer = false,
    TPSheriff = false,
    RoleNotify = true,
    AntiDie = false,
    Piggyback = false,
    LeanTP = false,

    -- Owner / Beta
    OwnerMode = isOwner,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 20, 20),
    Sheriff  = Color3.fromRGB(25, 95, 255),
    Innocent = Color3.fromRGB(20, 220, 55),
}

local RoleCache = {}
local ESPData = {}
local Tracers = {}
local Boxes = {}
local Skeletons = {}
local HitboxVisuals = {}
local BodyVel = nil
local BodyGyro = nil
local lastFarm = 0
local lastKill = 0
local lastAnti = 0
local lastRoleScan = 0
local lastFling = 0
local currentMurderer = nil
local currentSheriff = nil
local DrawingAvailable = false
local ConfigName = "ZuzifyMoon_Config.json"
local PlayerList = {}

pcall(function()
    if Drawing then DrawingAvailable = true end
end)

-- Role detection
local KnifeWords = {"knife", "dagger", "blade", "sword", "scythe", "axe", "katana", "cleaver"}
local GunWords = {"gun", "revolver", "pistol", "rifle", "shotgun", "sheriff", "handgun"}

local function HasKeyword(name, list)
    name = string.lower(tostring(name or ""))
    for _, w in ipairs(list) do
        if string.find(name, w) then return true end
    end
    return false
end

local function DetectRole(plr)
    if not plr then return "Innocent" end
    local char = plr.Character
    if not char then return "Innocent" end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if HasKeyword(tool.Name, KnifeWords) then return "Murderer" end
        if HasKeyword(tool.Name, GunWords) then return "Sheriff" end
    end

    local backpack = plr:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                if HasKeyword(item.Name, KnifeWords) then return "Murderer" end
                if HasKeyword(item.Name, GunWords) then return "Sheriff" end
            end
        end
    end

    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            if HasKeyword(child.Name, KnifeWords) then return "Murderer" end
            if HasKeyword(child.Name, GunWords) then return "Sheriff" end
        end
    end
    return "Innocent"
end

local function UpdateRoles()
    for _, plr in ipairs(Players:GetPlayers()) do
        RoleCache[plr] = {Role = DetectRole(plr), Time = tick()}
    end
end

local function GetRole(plr)
    if not plr then return "Innocent" end
    local c = RoleCache[plr]
    if c and (tick() - c.Time) < 1.2 then return c.Role end
    local role = DetectRole(plr)
    RoleCache[plr] = {Role = role, Time = tick()}
    return role
end

-- Aimbot helpers
local function IsVisible(part)
    if not Features.AimVisibleOnly then return true end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local ray = Ray.new(origin, dir)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, part.Parent})
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

local function GetAimPart(char)
    if Features.AimPart == "Head" then
        return char:FindFirstChild("Head")
    elseif Features.AimPart == "UpperTorso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetBestTarget()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local best = nil
    local bestScore = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = GetAimPart(plr.Character)
            if hum and hum.Health > 0 and part then
                local dist = (myRoot.Position - part.Position).Magnitude
                if dist <= Features.AimbotFOV then
                    if IsVisible(part) then
                        local score = dist
                        local role = GetRole(plr)
                        if Features.AimPriority == "Murderer" and role == "Murderer" then score = score - 60 end
                        if Features.AimPriority == "Sheriff" and role == "Sheriff" then score = score - 60 end
                        if score < bestScore then
                            bestScore = score
                            best = part
                        end
                    end
                end
            end
        end
    end
    return best
end

local function PredictPos(part)
    return part.Position + (part.AssemblyLinearVelocity * Features.AimbotPrediction)
end

-- ================= ESP SYSTEM =================

local function CreateNameESP(plr)
    if plr == LocalPlayer or (ESPData[plr] and ESPData[plr].Billboard) then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local role = GetRole(plr)
    local col = RoleColors[role] or RoleColors.Innocent

    local bb = Instance.new("BillboardGui")
    bb.Name = "ZM_ESP"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 220, 0, 55)
    bb.StudsOffset = Vector3.new(0, 2.9, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 4500
    bb.Parent = head

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, 0, 0.5, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = plr.Name .. " [" .. role .. "]"
    nameL.TextColor3 = col
    nameL.TextStrokeTransparency = 0.12
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 14
    nameL.Parent = bb

    local distL = Instance.new("TextLabel")
    distL.Size = UDim2.new(1, 0, 0.5, 0)
    distL.Position = UDim2.new(0, 0, 0.5, 0)
    distL.BackgroundTransparency = 1
    distL.Text = "0"
    distL.TextColor3 = col
    distL.TextStrokeTransparency = 0.12
    distL.Font = Enum.Font.Gotham
    distL.TextSize = 12
    distL.Parent = bb

    if not ESPData[plr] then ESPData[plr] = {} end
    ESPData[plr].Billboard = bb
    ESPData[plr].NameLabel = nameL
    ESPData[plr].DistLabel = distL
end

local function CreateChams(plr)
    if plr == LocalPlayer or (ESPData[plr] and ESPData[plr].Highlight) then return end
    local char = plr.Character
    if not char then return end
    local role = GetRole(plr)
    local col = RoleColors[role] or RoleColors.Innocent

    local hl = Instance.new("Highlight")
    hl.Name = "ZM_Chams"
    hl.Adornee = char
    hl.FillColor = col
    hl.OutlineColor = col
    hl.FillTransparency = 0.42
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char

    if not ESPData[plr] then ESPData[plr] = {} end
    ESPData[plr].Highlight = hl
end

local function CreateTracer(plr)
    if not DrawingAvailable or plr == LocalPlayer or Tracers[plr] then return end
    local line = Drawing.new("Line")
    line.Visible = false
    line.Thickness = 1.6
    line.Transparency = 0.6
    Tracers[plr] = line
end

local function CreateBox(plr)
    if not DrawingAvailable or plr == LocalPlayer or Boxes[plr] then return end
    local box = Drawing.new("Square")
    box.Visible = false
    box.Thickness = 1.5
    box.Filled = false
    Boxes[plr] = box
end

-- Skeleton ESP
local function CreateSkeleton(plr)
    if not DrawingAvailable or plr == LocalPlayer or Skeletons[plr] then return end
    local lines = {}
    for i = 1, 12 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1.4
        l.Transparency = 0.5
        table.insert(lines, l)
    end
    Skeletons[plr] = lines
end

-- Hitbox visualization
local function CreateHitboxVisual(plr)
    if plr == LocalPlayer or HitboxVisuals[plr] then return end
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local part = Instance.new("Part")
    part.Name = "ZM_HitboxVis"
    part.Size = Vector3.new(4, 5, 2)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 0.7
    part.Color = Color3.fromRGB(255, 80, 80)
    part.Material = Enum.Material.ForceField
    part.Parent = workspace

    HitboxVisuals[plr] = part
end

local function ClearPlayerESP(plr)
    if ESPData[plr] then
        pcall(function()
            if ESPData[plr].Billboard then ESPData[plr].Billboard:Destroy() end
            if ESPData[plr].Highlight then ESPData[plr].Highlight:Destroy() end
        end)
        ESPData[plr] = nil
    end
    if Tracers[plr] then pcall(function() Tracers[plr]:Remove() end) Tracers[plr] = nil end
    if Boxes[plr] then pcall(function() Boxes[plr]:Remove() end) Boxes[plr] = nil end
    if Skeletons[plr] then
        for _, l in ipairs(Skeletons[plr]) do pcall(function() l:Remove() end) end
        Skeletons[plr] = nil
    end
    if HitboxVisuals[plr] then
        pcall(function() HitboxVisuals[plr]:Destroy() end)
        HitboxVisuals[plr] = nil
    end
end

local function ClearAllESP()
    for plr in pairs(ESPData) do ClearPlayerESP(plr) end
    for plr in pairs(Tracers) do pcall(function() Tracers[plr]:Remove() end) end
    for plr in pairs(Boxes) do pcall(function() Boxes[plr]:Remove() end) end
    for plr in pairs(Skeletons) do
        for _, l in ipairs(Skeletons[plr] or {}) do pcall(function() l:Remove() end) end
    end
    for plr in pairs(HitboxVisuals) do pcall(function() HitboxVisuals[plr]:Destroy() end) end
    table.clear(ESPData)
    table.clear(Tracers)
    table.clear(Boxes)
    table.clear(Skeletons)
    table.clear(HitboxVisuals)
end

local function RefreshESP()
    ClearAllESP()
    if not Features.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Features.ESP_Names then CreateNameESP(plr) end
            if Features.ESP_Chams then CreateChams(plr) end
            if Features.ESP_Tracers then CreateTracer(plr) end
            if Features.ESP_Boxes then CreateBox(plr) end
            if Features.ESP_Skeleton then CreateSkeleton(plr) end
            if Features.ESP_Hitbox then CreateHitboxVisual(plr) end
        end
    end
end

-- Movement helpers
local function ApplyStats()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Features.WalkSpeed
        hum.JumpPower = Features.JumpPower
        pcall(function() hum.JumpHeight = Features.JumpPower / 3.4 end)
    end
end

local function ApplyNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then p.CanCollide = not Features.Noclip end
    end
end

local function SetupFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if BodyVel then BodyVel:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end
    BodyVel = Instance.new("BodyVelocity")
    BodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    BodyVel.Velocity = Vector3.zero
    BodyVel.Parent = root
    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    BodyGyro.P = 16000
    BodyGyro.Parent = root
end

local function CleanupFly()
    if BodyVel then BodyVel:Destroy() BodyVel = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
end

local function ApplyHitbox()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if Features.HitboxExtender then
        root.Size = Vector3.new(Features.HitboxSize, Features.HitboxSize, Features.HitboxSize)
        root.Transparency = 0.5
        root.CanCollide = false
    else
        root.Size = Vector3.new(2, 2, 1)
        root.Transparency = 1
    end
end

local function DoAntiFling()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root.AssemblyLinearVelocity.Magnitude > 115 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function DoAntiDie()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health < hum.MaxHealth * 0.25 then
        hum.Health = hum.MaxHealth
    end
end

local function Teleport(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(pos) end
end

local function PlayAnim(id)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    for _, t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop(0.1) end
    local a = Instance.new("Animation")
    a.AnimationId = "rbxassetid://" .. tostring(id)
    hum:LoadAnimation(a):Play()
end

local function FlingPlayer(plr)
    if not plr or not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(math.random(-140, 140), 100, math.random(-140, 140))
    bv.Parent = root
    task.delay(0.4, function() if bv then bv:Destroy() end end)
end

local function DoPiggyback(plr)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not plr or not plr.Character then return end
    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
    if tRoot then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 2.9, 0.5)
    end
end

local function LeanTeleport(plr)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not plr or not plr.Character then return end
    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
    if tRoot then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(2.4, 0, 0)
    end
end

-- Config
local function SaveConfig()
    pcall(function()
        writefile(ConfigName, HttpService:JSONEncode(Features))
        Window:Notify({Title = "Config", Description = "Saved", Duration = 2, Type = "Success"})
    end)
end

local function LoadConfig()
    pcall(function()
        if isfile and isfile(ConfigName) then
            local data = HttpService:JSONDecode(readfile(ConfigName))
            for k, v in pairs(data) do
                if Features[k] ~= nil then Features[k] = v end
            end
            Window:Notify({Title = "Config", Description = "Loaded", Duration = 2, Type = "Success"})
        end
    end)
end

local function RefreshPlayerList()
    PlayerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(PlayerList, plr.Name)
        end
    end
end

-- Character
local function OnChar(char)
    task.wait(0.7)
    ApplyStats()
    if Features.Noclip then ApplyNoclip() end
    if Features.Fly then SetupFly() end
    if Features.HitboxExtender then ApplyHitbox() end
    if Features.ESP then task.delay(0.4, RefreshESP) end
    RoleCache[LocalPlayer] = {Role = DetectRole(LocalPlayer), Time = tick()}
end

if LocalPlayer.Character then OnChar(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(OnChar)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.8)
        RoleCache[plr] = {Role = DetectRole(plr), Time = tick()}
        if Features.ESP then
            if Features.ESP_Names then CreateNameESP(plr) end
            if Features.ESP_Chams then CreateChams(plr) end
            if Features.ESP_Tracers then CreateTracer(plr) end
            if Features.ESP_Boxes then CreateBox(plr) end
            if Features.ESP_Skeleton then CreateSkeleton(plr) end
            if Features.ESP_Hitbox then CreateHitboxVisual(plr) end
        end
        RefreshPlayerList()
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    ClearPlayerESP(plr)
    RoleCache[plr] = nil
    RefreshPlayerList()
end)

RefreshPlayerList()

-- Main loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if tick() - lastRoleScan > 1.0 then
        lastRoleScan = tick()
        UpdateRoles()
        local mur, sher = nil, nil
        for plr, data in pairs(RoleCache) do
            if data.Role == "Murderer" then mur = plr end
            if data.Role == "Sheriff" then sher = plr end
        end
        if Features.RoleNotify then
            if mur and mur ~= currentMurderer then
                currentMurderer = mur
                Window:Notify({Title = "Role", Description = "Murderer: " .. mur.Name, Duration = 2.5, Type = "Warning"})
            end
            if sher and sher ~= currentSheriff then
                currentSheriff = sher
                Window:Notify({Title = "Role", Description = "Sheriff: " .. sher.Name, Duration = 2.5, Type = "Info"})
            end
        end
        currentMurderer = mur
        currentSheriff = sher
    end

    -- ESP update
    if Features.ESP and root then
        for plr, data in pairs(ESPData) do
            if plr.Character and plr.Character:FindFirstChild("Head") then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist = (root.Position - tRoot.Position).Magnitude
                    local role = GetRole(plr)
                    local col = RoleColors[role] or RoleColors.Innocent
                    if data.NameLabel then
                        data.NameLabel.Text = plr.Name .. " [" .. role .. "]"
                        data.NameLabel.TextColor3 = col
                        data.NameLabel.Visible = Features.ESP_Names
                    end
                    if data.DistLabel then
                        data.DistLabel.Text = math.floor(dist) .. " studs"
                        data.DistLabel.TextColor3 = col
                        data.DistLabel.Visible = Features.ESP_Distance
                    end
                    if data.Highlight then
                        data.Highlight.FillColor = col
                        data.Highlight.OutlineColor = col
                    end
                end
            else
                ClearPlayerESP(plr)
            end
        end

        -- Tracers
        if Features.ESP_Tracers and DrawingAvailable then
            for plr, line in pairs(Tracers) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local tPos = plr.Character.HumanoidRootPart.Position
                    local screen, onScreen = Camera:WorldToViewportPoint(tPos)
                    if onScreen then
                        local role = GetRole(plr)
                        line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(screen.X, screen.Y)
                        line.Color = RoleColors[role] or RoleColors.Innocent
                        line.Visible = true
                    else
                        line.Visible = false
                    end
                else
                    line.Visible = false
                end
            end
        end

        -- Boxes
        if Features.ESP_Boxes and DrawingAvailable then
            for plr, box in pairs(Boxes) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local tRoot = plr.Character.HumanoidRootPart
                    local pos, onScreen = Camera:WorldToViewportPoint(tRoot.Position)
                    if onScreen then
                        local role = GetRole(plr)
                        local size = 42 / (pos.Z * 0.08)
                        box.Size = Vector2.new(size, size * 1.7)
                        box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                        box.Color = RoleColors[role] or RoleColors.Innocent
                        box.Visible = true
                    else
                        box.Visible = false
                    end
                else
                    box.Visible = false
                end
            end
        end

        -- Skeleton (simple)
        if Features.ESP_Skeleton and DrawingAvailable then
            for plr, lines in pairs(Skeletons) do
                if plr.Character then
                    local head = plr.Character:FindFirstChild("Head")
                    local root = plr.Character:FindFirstChild("HumanoidRootPart")
                    local torso = plr.Character:FindFirstChild("UpperTorso") or plr.Character:FindFirstChild("Torso")
                    if head and root and torso then
                        local function toScreen(p)
                            local s, on = Camera:WorldToViewportPoint(p)
                            return Vector2.new(s.X, s.Y), on
                        end
                        local h, ho = toScreen(head.Position)
                        local r, ro = toScreen(root.Position)
                        local t, to = toScreen(torso.Position)
                        if ho and ro then
                            lines[1].From = h
                            lines[1].To = t
                            lines[1].Color = RoleColors[GetRole(plr)] or RoleColors.Innocent
                            lines[1].Visible = true
                            lines[2].From = t
                            lines[2].To = r
                            lines[2].Color = lines[1].Color
                            lines[2].Visible = true
                        end
                    end
                end
            end
        end

        -- Hitbox visual update
        if Features.ESP_Hitbox then
            for plr, part in pairs(HitboxVisuals) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    part.CFrame = plr.Character.HumanoidRootPart.CFrame
                    part.Size = Vector3.new(4.5, 5.5, 2.5)
                else
                    part.Transparency = 1
                end
            end
        end
    end

    if Features.Noclip and char then ApplyNoclip() end

    if Features.Fly and root and BodyVel and BodyGyro then
        local cam = Camera.CFrame
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
        if move.Magnitude > 0 then move = move.Unit * Features.FlySpeed end
        BodyVel.Velocity = move
        BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
    end

    if Features.InfiniteJump and hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if Features.AntiFling then DoAntiFling() end
    if Features.AntiDie then DoAntiDie() end
    if Features.HitboxExtender then ApplyHitbox() end

    -- Aimbot
    if Features.Aimbot and root then
        local can = true
        if Features.AimOnlyWhenTool then
            local tool = char and char:FindFirstChildOfClass("Tool")
            if not tool then can = false end
        end
        if can then
            local target = GetBestTarget()
            if target then
                local goal = PredictPos(target)
                local cur = Camera.CFrame
                local look = CFrame.lookAt(cur.Position, goal)
                Camera.CFrame = cur:Lerp(look, Features.AimbotSmooth)
            end
        end
    end

    -- Silent Aim
    if Features.SilentAim and root then
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool or not Features.AimOnlyWhenTool then
            local target = GetBestTarget()
            if target then
                local goal = PredictPos(target)
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, goal)
            end
        end
    end

    -- Kill Target / Piggyback / Lean
    if Features.SelectedTarget then
        local targetPlr = Players:FindFirstChild(Features.SelectedTarget)
        if targetPlr and targetPlr.Character then
            if Features.KillTarget and root then
                local tRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.6)
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
            if Features.Piggyback then DoPiggyback(targetPlr) end
            if Features.LeanTP then LeanTeleport(targetPlr) end
        end
    end

    -- Fling
    if Features.FlingNearest and tick() - lastFling > 0.75 then
        lastFling = tick()
        local closest, cdist = nil, 45
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and root then
                local tr = p.Character:FindFirstChild("HumanoidRootPart")
                if tr then
                    local d = (root.Position - tr.Position).Magnitude
                    if d < cdist then cdist = d closest = p end
                end
            end
        end
        if closest then FlingPlayer(closest) end
    end

    if Features.FlingTarget and Features.SelectedTarget and tick() - lastFling > 0.55 then
        lastFling = tick()
        local targetPlr = Players:FindFirstChild(Features.SelectedTarget)
        if targetPlr then FlingPlayer(targetPlr) end
    end

    if Features.FlingAll and tick() - lastFling > 1.1 then
        lastFling = tick()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then FlingPlayer(p) end
        end
    end

    -- Auto Kill + Aura
    if Features.AutoKill and tick() - lastKill > 1.4 then
        lastKill = tick()
        local target = GetBestTarget()
        if target then
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end

    if Features.KnifeAura and root then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tr = p.Character:FindFirstChild("HumanoidRootPart")
                if tr and (root.Position - tr.Position).Magnitude < Features.AuraRange then
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end

    -- Coin + Gun
    if Features.CoinFarm and root and tick() - lastFarm > 0.8 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "coin") or string.find(n, "money") or string.find(n, "cash") then
                    if (root.Position - obj.Position).Magnitude < 170 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        break
                    end
                end
            end
        end
    end

    if Features.GrabGun and root then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "gun")) then
                local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj.PrimaryPart)
                if part and (root.Position - part.Position).Magnitude < 280 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    break
                end
            end
        end
    end

    if Features.TPMurderer and currentMurderer and currentMurderer.Character and root then
        local tr = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
        if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, 4) end
    end

    if Features.TPSheriff and currentSheriff and currentSheriff.Character and root then
        local tr = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
        if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, 4) end
    end

    if Features.AntiAFK and tick() - lastAnti > 22 then
        lastAnti = tick()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

-- ================= UI =================

local Home = Window:AddTab("Home")
Home:New("Title")({Title = "ZuzifyMoon" .. (isOwner and " [OWNER]" or "")})
Home:New("Button")({
    Title = "Hello " .. LocalPlayer.Name,
    Description = isOwner and "Owner access granted. All features unlocked." or "ZuzifyMoon loaded. Made by Tai (vertexi8) & daviddabag",
    Callback = function()
        Window:Notify({Title = "ZuzifyMoon", Description = "Ready", Duration = 2.5, Type = "Success"})
    end,
})

local Vis = Window:AddTab("Visuals")
Vis:New("Title")({Title = "ESP Types"})
Vis:New("Toggle")({Title = "Enable ESP", Description = "Master switch", DefaultValue = false, Callback = function(v) Features.ESP = v if v then RefreshESP() else ClearAllESP() end end})
Vis:New("Toggle")({Title = "Names + Role", Description = "Name and role", DefaultValue = true, Callback = function(v) Features.ESP_Names = v RefreshESP() end})
Vis:New("Toggle")({Title = "Distance", Description = "Distance text", DefaultValue = true, Callback = function(v) Features.ESP_Distance = v end})
Vis:New("Toggle")({Title = "Chams", Description = "Full body highlight", DefaultValue = false, Callback = function(v) Features.ESP_Chams = v RefreshESP() end})
Vis:New("Toggle")({Title = "Tracers", Description = "Lines from bottom", DefaultValue = false, Callback = function(v) Features.ESP_Tracers = v RefreshESP() end})
Vis:New("Toggle")({Title = "Boxes", Description = "2D boxes", DefaultValue = false, Callback = function(v) Features.ESP_Boxes = v RefreshESP() end})
Vis:New("Toggle")({Title = "Skeleton ESP", Description = "Basic skeleton lines", DefaultValue = false, Callback = function(v) Features.ESP_Skeleton = v RefreshESP() end})
Vis:New("Toggle")({Title = "Hitbox Visualization", Description = "Shows forcefield hitbox on players", DefaultValue = false, Callback = function(v) Features.ESP_Hitbox = v RefreshESP() end})
Vis:New("Button")({Title = "Refresh ESP", Description = "Rebuild", Callback = RefreshESP})
Vis:New("Button")({Title = "Clear ESP", Description = "Remove all", Callback = function() ClearAllESP() Features.ESP = false end})

local Mov = Window:AddTab("Movement")
Mov:New("Title")({Title = "Movement"})
Mov:New("Toggle")({Title = "Noclip", Description = "Walk through walls", DefaultValue = false, Callback = function(v) Features.Noclip = v ApplyNoclip() end})
Mov:New("Toggle")({Title = "Fly", Description = "WASD + Space/Shift", DefaultValue = false, Callback = function(v) Features.Fly = v if v then SetupFly() else CleanupFly() end end})
Mov:New("Slider")({Title = "Fly Speed", Description = "10-200", Default = 65, Minimum = 10, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.FlySpeed = v end})
Mov:New("Toggle")({Title = "Infinite Jump", Description = "Jump in air", DefaultValue = false, Callback = function(v) Features.InfiniteJump = v end})
Mov:New("Slider")({Title = "Walk Speed", Description = "Default 16", Default = 16, Minimum = 10, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.WalkSpeed = v ApplyStats() end})
Mov:New("Slider")({Title = "Jump Power", Description = "Default 50", Default = 50, Minimum = 30, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.JumpPower = v ApplyStats() end})
Mov:New("Title")({Title = "Protection"})
Mov:New("Toggle")({Title = "Anti Fling", Description = "Stops high velocity", DefaultValue = true, Callback = function(v) Features.AntiFling = v end})
Mov:New("Toggle")({Title = "Anti Die", Description = "Keeps health high", DefaultValue = false, Callback = function(v) Features.AntiDie = v end})
Mov:New("Toggle")({Title = "Hitbox Extender", Description = "Bigger root for knife", DefaultValue = false, Callback = function(v) Features.HitboxExtender = v ApplyHitbox() end})
Mov:New("Slider")({Title = "Hitbox Size", Description = "Size", Default = 10, Minimum = 3, Maximum = 25, DecimalCount = 0, Callback = function(v) Features.HitboxSize = v if Features.HitboxExtender then ApplyHitbox() end end})
Mov:New("Toggle")({Title = "Anti AFK", Description = "Prevents idle kick", DefaultValue = false, Callback = function(v) Features.AntiAFK = v end})

local Games = Window:AddTab("MM2")
Games:New("Title")({Title = "Aimbot"})
Games:New("Toggle")({Title = "Aimbot", Description = "Smooth lock", DefaultValue = false, Callback = function(v) Features.Aimbot = v end})
Games:New("Toggle")({Title = "Silent Aim", Description = "Hard look when tool out", DefaultValue = false, Callback = function(v) Features.SilentAim = v end})
Games:New("Slider")({Title = "FOV / Range", Description = "Max distance", Default = 250, Minimum = 50, Maximum = 500, DecimalCount = 0, Callback = function(v) Features.AimbotFOV = v end})
Games:New("Slider")({Title = "Smoothness", Description = "0.05-0.4", Default = 0.12, Minimum = 0.05, Maximum = 0.4, DecimalCount = 2, Callback = function(v) Features.AimbotSmooth = v end})
Games:New("Slider")({Title = "Prediction", Description = "Lead", Default = 0.16, Minimum = 0, Maximum = 0.45, DecimalCount = 2, Callback = function(v) Features.AimbotPrediction = v end})
Games:New("Dropdown")({Title = "Aim Part", Description = "What to aim at", Options = {"HumanoidRootPart", "Head", "UpperTorso"}, Default = "HumanoidRootPart", Callback = function(v) Features.AimPart = v end})
Games:New("Dropdown")({Title = "Priority", Description = "Who to prefer", Options = {"Closest", "Murderer", "Sheriff"}, Default = "Closest", Callback = function(v) Features.AimPriority = v end})
Games:New("Toggle")({Title = "Visible Only", Description = "Only visible", DefaultValue = false, Callback = function(v) Features.AimVisibleOnly = v end})
Games:New("Toggle")({Title = "Only When Tool", Description = "Only while holding tool", DefaultValue = false, Callback = function(v) Features.AimOnlyWhenTool = v end})

Games:New("Title")({Title = "Combat + Target"})
Games:New("Toggle")({Title = "Auto Kill", Description = "Activates tool", DefaultValue = false, Callback = function(v) Features.AutoKill = v end})
Games:New("Toggle")({Title = "Knife Aura", Description = "Auto when close", DefaultValue = false, Callback = function(v) Features.KnifeAura = v end})
Games:New("Slider")({Title = "Aura Range", Description = "Distance", Default = 16, Minimum = 6, Maximum = 40, DecimalCount = 0, Callback = function(v) Features.AuraRange = v end})
Games:New("Dropdown")({
    Title = "Select Player",
    Description = "Target for kill / fling / piggyback / lean",
    Options = PlayerList,
    Default = PlayerList[1] or "None",
    Callback = function(v) Features.SelectedTarget = v end,
})
Games:New("Button")({Title = "Refresh Players", Description = "Update list", Callback = function() RefreshPlayerList() Window:Notify({Title = "Players", Description = "Refreshed", Duration = 2, Type = "Info"}) end})
Games:New("Toggle")({Title = "Kill Selected", Description = "TP + attack selected", DefaultValue = false, Callback = function(v) Features.KillTarget = v end})
Games:New("Toggle")({Title = "Piggyback", Description = "Sit on back", DefaultValue = false, Callback = function(v) Features.Piggyback = v end})
Games:New("Toggle")({Title = "Lean Teleport", Description = "TP beside player", DefaultValue = false, Callback = function(v) Features.LeanTP = v end})
Games:New("Toggle")({Title = "Fling Nearest", Description = "Fling closest", DefaultValue = false, Callback = function(v) Features.FlingNearest = v end})
Games:New("Toggle")({Title = "Fling Selected", Description = "Fling selected", DefaultValue = false, Callback = function(v) Features.FlingTarget = v end})
Games:New("Toggle")({Title = "Fling All", Description = "Fling everyone", DefaultValue = false, Callback = function(v) Features.FlingAll = v end})

Games:New("Title")({Title = "Utility"})
Games:New("Toggle")({Title = "Coin Farm", Description = "Moves to coins", DefaultValue = false, Callback = function(v) Features.CoinFarm = v end})
Games:New("Toggle")({Title = "Grab Gun", Description = "TP to guns", DefaultValue = false, Callback = function(v) Features.GrabGun = v end})
Games:New("Toggle")({Title = "TP to Murderer", Description = "Stay near murderer", DefaultValue = false, Callback = function(v) Features.TPMurderer = v end})
Games:New("Toggle")({Title = "TP to Sheriff", Description = "Stay near sheriff", DefaultValue = false, Callback = function(v) Features.TPSheriff = v end})
Games:New("Toggle")({Title = "Role Notify", Description = "Notify on role change", DefaultValue = true, Callback = function(v) Features.RoleNotify = v end})

if isOwner then
    Games:New("Title")({Title = "Owner / Beta"})
    Games:New("Button")({
        Title = "Owner Tools Unlocked",
        Description = "You have full access because you are mrcoptai / 717544874",
        Callback = function()
            Window:Notify({Title = "Owner", Description = "All features available", Duration = 3, Type = "Success"})
        end,
    })
end

local TP = Window:AddTab("Teleports")
TP:New("Title")({Title = "Presets"})
local function AddTP(name, pos)
    TP:New("Button")({Title = name, Description = "Teleport to " .. name, Callback = function() Teleport(pos) end})
end
AddTP("Lobby", Vector3.new(0, 10, 0))
AddTP("Arena", Vector3.new(0, 5, 50))
AddTP("Bank", Vector3.new(0, 5, 0))
AddTP("Hotel", Vector3.new(50, 5, 0))
AddTP("Hospital", Vector3.new(-50, 5, 0))
AddTP("House", Vector3.new(0, 5, 40))
AddTP("Office", Vector3.new(30, 5, 30))
AddTP("Factory", Vector3.new(-30, 5, -20))
AddTP("MilBase", Vector3.new(80, 5, 10))
AddTP("BioLab", Vector3.new(-80, 5, 20))

TP:New("Title")({Title = "Custom + Player"})
local customStr = "0, 50, 0"
TP:New("Input")({Title = "Coordinates", Description = "X, Y, Z", DefaultText = "0, 50, 0", Placeholder = "X, Y, Z", Callback = function(v) customStr = v end})
TP:New("Button")({
    Title = "Go to Custom",
    Description = "Teleport using input",
    Callback = function()
        local ok = pcall(function()
            local nums = {}
            for n in string.gmatch(customStr, "[-%d%.]+") do table.insert(nums, tonumber(n)) end
            if #nums >= 3 then Teleport(Vector3.new(nums[1], nums[2], nums[3])) end
        end)
        if not ok then Window:Notify({Title = "Error", Description = "Bad coords", Duration = 2, Type = "Error"}) end
    end,
})
TP:New("Button")({
    Title = "Teleport to Selected Player",
    Description = "Uses player selected in MM2 tab",
    Callback = function()
        if Features.SelectedTarget then
            local plr = Players:FindFirstChild(Features.SelectedTarget)
            if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                Teleport(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
            end
        end
    end,
})

local Em = Window:AddTab("Emotes")
Em:New("Title")({Title = "Animations (20+)"})
local emotes = {
    {name = "Feeling", id = 118235501642203},
    {name = "Dance", id = 507770017},
    {name = "Floss", id = 507771019},
    {name = "Wave", id = 507770239},
    {name = "Flex", id = 507776043},
    {name = "Sit", id = 507768133},
    {name = "Cartwheel", id = 507777268},
    {name = "Shrug", id = 3576686456},
    {name = "Laugh", id = 3337960521},
    {name = "Point", id = 507770453},
    {name = "Cheer", id = 507770677},
    {name = "Clap", id = 507770818},
    {name = "Bow", id = 507771019},
    {name = "Salute", id = 507771255},
    {name = "Think", id = 507771455},
    {name = "Agree", id = 507771719},
    {name = "Disagree", id = 507771867},
    {name = "Sleep", id = 507772104},
    {name = "Zombie", id = 3489171151},
    {name = "Robot", id = 3333499508},
    {name = "Superhero", id = 3333494501},
    {name = "Ninja", id = 3333499508},
    {name = "Juggle", id = 3333494501},
    {name = "Headless", id = 3333494501},
}

for _, e in ipairs(emotes) do
    Em:New("Button")({
        Title = e.name,
        Description = "Play " .. e.name,
        Callback = function() PlayAnim(e.id) end,
    })
end

local Set = Window:AddTab("Settings")
Set:New("Title")({Title = "Server"})
Set:New("Button")({Title = "Rejoin", Description = "Rejoin current place", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
Set:New("Button")({
    Title = "Server Hop",
    Description = "Join another public server",
    Callback = function()
        local ok, err = pcall(function()
            local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            local list = {}
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(list, s.id) end
                end
            end
            if #list > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1, #list)], LocalPlayer)
            else
                Window:Notify({Title = "Server Hop", Description = "No servers found", Duration = 3, Type = "Warning"})
            end
        end)
        if not ok then Window:Notify({Title = "Error", Description = tostring(err), Duration = 3, Type = "Error"}) end
    end,
})
Set:New("Title")({Title = "Config"})
Set:New("Button")({Title = "Save Settings", Description = "Save all", Callback = SaveConfig})
Set:New("Button")({Title = "Load Settings", Description = "Load saved", Callback = LoadConfig})
Set:New("Title")({Title = "Themes"})
Set:New("Dropdown")({
    Title = "UI Theme",
    Description = "More themes",
    Options = {"Light", "Dark", "Midnight", "Rose", "Emerald"},
    Default = "Rose",
    Callback = function(v) Window:SetTheme(v) end,
})
Set:New("Button")({
    Title = "Destroy UI",
    Description = "Close and clean",
    Callback = function()
        ClearAllESP()
        CleanupFly()
        Features.ESP = false
        Features.Fly = false
        Window:Destroy()
    end,
})

Window:SetTab("Home")
LoadConfig()

Window:Notify({
    Title = "ZuzifyMoon",
    Description = (isOwner and "Owner access granted for " or "Loaded for ") .. LocalPlayer.Name,
    Duration = 4,
    Type = "Success"
})

print("ZuzifyMoon loaded - Tai (vertexi8) & daviddabag | Owner: " .. tostring(isOwner))
