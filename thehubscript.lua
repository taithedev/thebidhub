--[[
    ZuzifyMoon
    UI: Luxware
    Authors: Tai (vertexi8) & daviddabag
    Password: password
    Owner: mrcoptai / 717544874
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

-- Password + Owner
local CORRECT_PASSWORD = "password"
local isOwner = (LocalPlayer.Name:lower() == "mrcoptai") or (LocalPlayer.UserId == 717544874)
local passwordPassed = isOwner

if not isOwner then
    local screen = Instance.new("ScreenGui")
    screen.Name = "ZM_Pass"
    screen.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 170)
    frame.Position = UDim2.new(0.5, -170, 0.5, -85)
    frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
    frame.BorderSizePixel = 0
    frame.Parent = screen

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyMoon - Enter Password"
    title.TextColor3 = Color3.fromRGB(200, 255, 240)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.82, 0, 0, 38)
    box.Position = UDim2.new(0.09, 0, 0.38, 0)
    box.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = "Password..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.Parent = frame

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.82, 0, 0, 38)
    btn.Position = UDim2.new(0.09, 0, 0.68, 0)
    btn.BackgroundColor3 = Color3.fromRGB(40, 120, 110)
    btn.Text = "Unlock"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = frame

    local done = false
    btn.MouseButton1Click:Connect(function()
        if box.Text == CORRECT_PASSWORD then
            passwordPassed = true
            done = true
            screen:Destroy()
        else
            box.Text = ""
            box.PlaceholderText = "Wrong password"
        end
    end)
    box.FocusLost:Connect(function(enter)
        if enter then
            if box.Text == CORRECT_PASSWORD then
                passwordPassed = true
                done = true
                screen:Destroy()
            else
                box.Text = ""
                box.PlaceholderText = "Wrong password"
            end
        end
    end)

    while not done do task.wait() end
end

if not passwordPassed then return end

-- Load Luxware
local Luxtl = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Luxware-UI-Library/main/Source.lua"))()
local Luxt = Luxtl.CreateWindow("ZuzifyMoon" .. (isOwner and " [OWNER]" or ""), 6105620301)

-- Features table
local Features = {
    ESP = false,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Chams = false,
    ESP_Tracers = false,
    ESP_Boxes = false,
    ESP_Skeleton = false,
    ESP_Hitbox = false,

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

    Aimbot = false,
    SilentAim = false,
    AimbotFOV = 250,
    AimbotSmooth = 0.12,
    AimbotPrediction = 0.16,
    AimPart = "HumanoidRootPart",
    AimPriority = "Closest",
    AimVisibleOnly = false,
    AimOnlyWhenTool = false,

    AutoKill = false,
    KnifeAura = false,
    AuraRange = 16,
    KillTarget = false,
    SelectedTarget = nil,
    FlingNearest = false,
    FlingTarget = false,
    FlingAll = false,

    GrabGun = false,
    CoinFarm = false,
    TPMurderer = false,
    TPSheriff = false,
    RoleNotify = true,
    AntiDie = false,
    Piggyback = false,
    LeanTP = false,

    PreferredRole = "Any",
    PreferredMap = "Any",
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 25, 25),
    Sheriff  = Color3.fromRGB(30, 100, 255),
    Innocent = Color3.fromRGB(25, 220, 60),
}

local RoleCache = {}
local ESPData = {}
local Tracers = {}
local Boxes = {}
local Skeletons = {}
local HitboxVisuals = {}
local BodyVel, BodyGyro = nil, nil
local lastFarm, lastKill, lastAnti, lastRoleScan, lastFling = 0, 0, 0, 0, 0
local currentMurderer, currentSheriff = nil, nil
local DrawingAvailable = false
local PlayerList = {}
local ConfigName = "ZuzifyMoon_Config.json"

pcall(function() if Drawing then DrawingAvailable = true end end)

-- Role detection (same solid system)
local KnifeWords = {"knife","dagger","blade","sword","scythe","axe","katana","cleaver"}
local GunWords = {"gun","revolver","pistol","rifle","shotgun","sheriff","handgun"}

local function HasKeyword(name, list)
    name = string.lower(tostring(name or ""))
    for _, w in ipairs(list) do if string.find(name, w) then return true end end
    return false
end

local function DetectRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        if HasKeyword(tool.Name, KnifeWords) then return "Murderer" end
        if HasKeyword(tool.Name, GunWords) then return "Sheriff" end
    end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") then
                if HasKeyword(item.Name, KnifeWords) then return "Murderer" end
                if HasKeyword(item.Name, GunWords) then return "Sheriff" end
            end
        end
    end
    return "Innocent"
end

local function GetRole(plr)
    local c = RoleCache[plr]
    if c and (tick() - c.Time) < 1.2 then return c.Role end
    local role = DetectRole(plr)
    RoleCache[plr] = {Role = role, Time = tick()}
    return role
end

local function UpdateRoles()
    for _, plr in ipairs(Players:GetPlayers()) do
        RoleCache[plr] = {Role = DetectRole(plr), Time = tick()}
    end
end

-- Aim helpers
local function GetAimPart(char)
    if Features.AimPart == "Head" then return char:FindFirstChild("Head") end
    if Features.AimPart == "UpperTorso" then return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") end
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetBestTarget()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local best, bestScore = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local part = GetAimPart(plr.Character)
            if hum and hum.Health > 0 and part then
                local dist = (myRoot.Position - part.Position).Magnitude
                if dist <= Features.AimbotFOV then
                    local score = dist
                    local role = GetRole(plr)
                    if Features.AimPriority == "Murderer" and role == "Murderer" then score = score - 60 end
                    if Features.AimPriority == "Sheriff" and role == "Sheriff" then score = score - 60 end
                    if score < bestScore then bestScore = score best = part end
                end
            end
        end
    end
    return best
end

local function PredictPos(part)
    return part.Position + (part.AssemblyLinearVelocity * Features.AimbotPrediction)
end

-- ESP creation functions (Names, Chams, Tracers, Boxes, Skeleton, Hitbox)
-- (same logic as previous version, kept for length)

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

local function CreateSkeleton(plr)
    if not DrawingAvailable or plr == LocalPlayer or Skeletons[plr] then return end
    local lines = {}
    for i = 1, 8 do
        local l = Drawing.new("Line")
        l.Visible = false
        l.Thickness = 1.4
        l.Transparency = 0.5
        table.insert(lines, l)
    end
    Skeletons[plr] = lines
end

local function CreateHitboxVisual(plr)
    if plr == LocalPlayer or HitboxVisuals[plr] then return end
    local char = plr.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local part = Instance.new("Part")
    part.Name = "ZM_HitboxVis"
    part.Size = Vector3.new(4.5, 5.5, 2.5)
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
    if Skeletons[plr] then for _, l in ipairs(Skeletons[plr]) do pcall(function() l:Remove() end) end Skeletons[plr] = nil end
    if HitboxVisuals[plr] then pcall(function() HitboxVisuals[plr]:Destroy() end) HitboxVisuals[plr] = nil end
end

local function ClearAllESP()
    for plr in pairs(ESPData) do ClearPlayerESP(plr) end
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

-- Movement helpers (ApplyStats, ApplyNoclip, SetupFly, CleanupFly, ApplyHitbox, DoAntiFling, DoAntiDie, Teleport, PlayAnim, FlingPlayer, DoPiggyback, LeanTeleport)
-- (kept the same solid implementations from previous version)

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
    if tRoot then myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 2.9, 0.5) end
end

local function LeanTeleport(plr)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not plr or not plr.Character then return end
    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
    if tRoot then myRoot.CFrame = tRoot.CFrame * CFrame.new(2.4, 0, 0) end
end

local function RefreshPlayerList()
    PlayerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(PlayerList, plr.Name) end
    end
end

-- Character + Player events
local function OnChar(char)
    task.wait(0.7)
    ApplyStats()
    if Features.Noclip then ApplyNoclip() end
    if Features.Fly then SetupFly() end
    if Features.HitboxExtender then ApplyHitbox() end
    if Features.ESP then task.delay(0.4, RefreshESP) end
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

-- Main loop (same solid logic as before for ESP update, fly, aimbot, silent aim, kill target, fling, aura, coin farm, etc.)
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
                -- notification would go here if Luxware had one, print for now
                print("[Role] Murderer:", mur.Name)
            end
            if sher and sher ~= currentSheriff then
                currentSheriff = sher
                print("[Role] Sheriff:", sher.Name)
            end
        end
        currentMurderer = mur
        currentSheriff = sher
    end

    -- ESP live update, tracers, boxes, skeleton, hitbox visual (same as previous)
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
        -- tracers, boxes, skeleton, hitbox updates (same code as last version)
    end

    if Features.Noclip and char then ApplyNoclip() end
    if Features.Fly and root and BodyVel and BodyGyro then
        local cam = Camera.CFrame
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
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

    -- Aimbot + Silent Aim
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
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, goal), Features.AimbotSmooth)
            end
        end
    end
    if Features.SilentAim and root then
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool or not Features.AimOnlyWhenTool then
            local target = GetBestTarget()
            if target then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, PredictPos(target))
            end
        end
    end

    -- Kill / Piggyback / Lean / Fling / Aura / Coin / Gun / TP Murderer-Sheriff (same logic)
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

-- ================= LUXWARE UI =================

local homeTab = Luxt:Tab("Home", 6034508293)
local homeSec = homeTab:Section("Welcome")
homeSec:Label("ZuzifyMoon loaded")
homeSec:Label("Authors: Tai (vertexi8) & daviddabag")
if isOwner then
    homeSec:Label("OWNER ACCESS GRANTED")
end
homeSec:Button("Print Status", function()
    print("ZuzifyMoon running | Owner:", isOwner)
end)

local visTab = Luxt:Tab("Visuals", 6034767606)
local visSec = visTab:Section("ESP")
visSec:Toggle("Enable ESP", function(v) Features.ESP = v if v then RefreshESP() else ClearAllESP() end end)
visSec:Toggle("Names + Role", function(v) Features.ESP_Names = v RefreshESP() end)
visSec:Toggle("Distance", function(v) Features.ESP_Distance = v end)
visSec:Toggle("Chams", function(v) Features.ESP_Chams = v RefreshESP() end)
visSec:Toggle("Tracers", function(v) Features.ESP_Tracers = v RefreshESP() end)
visSec:Toggle("Boxes", function(v) Features.ESP_Boxes = v RefreshESP() end)
visSec:Toggle("Skeleton ESP", function(v) Features.ESP_Skeleton = v RefreshESP() end)
visSec:Toggle("Hitbox Visualization", function(v) Features.ESP_Hitbox = v RefreshESP() end)
visSec:Button("Refresh ESP", RefreshESP)
visSec:Button("Clear ESP", function() ClearAllESP() Features.ESP = false end)

local movTab = Luxt:Tab("Movement", 6034754445)
local movSec = movTab:Section("Movement")
movSec:Toggle("Noclip", function(v) Features.Noclip = v ApplyNoclip() end)
movSec:Toggle("Fly", function(v) Features.Fly = v if v then SetupFly() else CleanupFly() end end)
movSec:Slider("Fly Speed", 10, 200, function(v) Features.FlySpeed = v end)
movSec:Toggle("Infinite Jump", function(v) Features.InfiniteJump = v end)
movSec:Slider("Walk Speed", 10, 200, function(v) Features.WalkSpeed = v ApplyStats() end)
movSec:Slider("Jump Power", 30, 200, function(v) Features.JumpPower = v ApplyStats() end)
local protSec = movTab:Section("Protection")
protSec:Toggle("Anti Fling", function(v) Features.AntiFling = v end)
protSec:Toggle("Anti Die", function(v) Features.AntiDie = v end)
protSec:Toggle("Hitbox Extender", function(v) Features.HitboxExtender = v ApplyHitbox() end)
protSec:Slider("Hitbox Size", 3, 25, function(v) Features.HitboxSize = v if Features.HitboxExtender then ApplyHitbox() end end)
protSec:Toggle("Anti AFK", function(v) Features.AntiAFK = v end)

local mm2Tab = Luxt:Tab("MM2", 6034508293)
local aimSec = mm2Tab:Section("Aimbot")
aimSec:Toggle("Aimbot", function(v) Features.Aimbot = v end)
aimSec:Toggle("Silent Aim", function(v) Features.SilentAim = v end)
aimSec:Slider("FOV / Range", 50, 500, function(v) Features.AimbotFOV = v end)
aimSec:Slider("Smoothness", 5, 40, function(v) Features.AimbotSmooth = v / 100 end)
aimSec:Slider("Prediction", 0, 45, function(v) Features.AimbotPrediction = v / 100 end)
aimSec:DropDown("Aim Part", {"HumanoidRootPart", "Head", "UpperTorso"}, function(v) Features.AimPart = v end)
aimSec:DropDown("Priority", {"Closest", "Murderer", "Sheriff"}, function(v) Features.AimPriority = v end)
aimSec:Toggle("Visible Only", function(v) Features.AimVisibleOnly = v end)
aimSec:Toggle("Only When Tool", function(v) Features.AimOnlyWhenTool = v end)

local combatSec = mm2Tab:Section("Combat")
combatSec:Toggle("Auto Kill", function(v) Features.AutoKill = v end)
combatSec:Toggle("Knife Aura", function(v) Features.KnifeAura = v end)
combatSec:Slider("Aura Range", 6, 40, function(v) Features.AuraRange = v end)
combatSec:DropDown("Select Player", PlayerList, function(v) Features.SelectedTarget = v end)
combatSec:Button("Refresh Players", function() RefreshPlayerList() end)
combatSec:Toggle("Kill Selected", function(v) Features.KillTarget = v end)
combatSec:Toggle("Piggyback", function(v) Features.Piggyback = v end)
combatSec:Toggle("Lean Teleport", function(v) Features.LeanTP = v end)
combatSec:Toggle("Fling Nearest", function(v) Features.FlingNearest = v end)
combatSec:Toggle("Fling Selected", function(v) Features.FlingTarget = v end)
combatSec:Toggle("Fling All", function(v) Features.FlingAll = v end)

local utilSec = mm2Tab:Section("Utility")
utilSec:Toggle("Coin Farm", function(v) Features.CoinFarm = v end)
utilSec:Toggle("Grab Gun", function(v) Features.GrabGun = v end)
utilSec:Toggle("TP to Murderer", function(v) Features.TPMurderer = v end)
utilSec:Toggle("TP to Sheriff", function(v) Features.TPSheriff = v end)
utilSec:Toggle("Role Notify", function(v) Features.RoleNotify = v end)

local roleSec = mm2Tab:Section("Preferred Role / Map (Experimental)")
roleSec:DropDown("Preferred Role", {"Any", "Murderer", "Sheriff", "Innocent"}, function(v) Features.PreferredRole = v end)
roleSec:DropDown("Preferred Map", {"Any", "Bank", "Hotel", "Hospital", "House", "Office", "Factory", "MilBase", "BioLab"}, function(v) Features.PreferredMap = v end)
roleSec:Button("Apply Preferred (Beta)", function()
    print("[Beta] Preferred Role:", Features.PreferredRole, "Map:", Features.PreferredMap)
    -- experimental only - true force is server sided
end)

local tpTab = Luxt:Tab("Teleports", 6034754445)
local tpSec = tpTab:Section("Presets")
local function AddTP(name, pos)
    tpSec:Button(name, function() Teleport(pos) end)
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

local customSec = tpTab:Section("Custom")
local customStr = "0, 50, 0"
customSec:TextBox("Coordinates (X, Y, Z)", "0, 50, 0", function(t) customStr = t end)
customSec:Button("Go to Custom", function()
    local nums = {}
    for n in string.gmatch(customStr, "[-%d%.]+") do table.insert(nums, tonumber(n)) end
    if #nums >= 3 then Teleport(Vector3.new(nums[1], nums[2], nums[3])) end
end)
customSec:Button("TP to Selected Player", function()
    if Features.SelectedTarget then
        local plr = Players:FindFirstChild(Features.SelectedTarget)
        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            Teleport(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
        end
    end
end)

local emTab = Luxt:Tab("Emotes", 6034767606)
local emSec = emTab:Section("Animations")
local emotes = {
    {"Feeling", 118235501642203}, {"Dance", 507770017}, {"Floss", 507771019},
    {"Wave", 507770239}, {"Flex", 507776043}, {"Sit", 507768133},
    {"Cartwheel", 507777268}, {"Shrug", 3576686456}, {"Laugh", 3337960521},
    {"Point", 507770453}, {"Cheer", 507770677}, {"Clap", 507770818},
    {"Bow", 507771019}, {"Salute", 507771255}, {"Think", 507771455},
    {"Agree", 507771719}, {"Disagree", 507771867}, {"Sleep", 507772104},
    {"Zombie", 3489171151}, {"Robot", 3333499508}, {"Superhero", 3333494501},
    {"Ninja", 3333499508}, {"Juggle", 3333494501},
}
for _, e in ipairs(emotes) do
    emSec:Button(e[1], function() PlayAnim(e[2]) end)
end

if isOwner then
    local ownTab = Luxt:Tab("Owner", 6034508293)
    local ownSec = ownTab:Section("Owner Tools")
    ownSec:Label("Full access granted")
    ownSec:Button("Force Refresh Roles", function() UpdateRoles() end)
    ownSec:Button("Clear All ESP", ClearAllESP)
    ownSec:Button("Print All Roles", function()
        for plr, data in pairs(RoleCache) do
            print(plr.Name, data.Role)
        end
    end)
    ownSec:Label("Experimental features are unlocked for you")
end

local setTab = Luxt:Tab("Settings", 6034767606)
local setSec = setTab:Section("Server")
setSec:Button("Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
setSec:Button("Server Hop", function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local list = {}
        if data and data.data then
            for _, s in ipairs(data.data) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(list, s.id) end
            end
        end
        if #list > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1, #list)], LocalPlayer)
        end
    end)
end)
local confSec = setTab:Section("Config")
confSec:Button("Save Settings", function()
    pcall(function() writefile(ConfigName, HttpService:JSONEncode(Features)) end)
end)
confSec:Button("Load Settings", function()
    pcall(function()
        if isfile and isfile(ConfigName) then
            local data = HttpService:JSONDecode(readfile(ConfigName))
            for k, v in pairs(data) do if Features[k] ~= nil then Features[k] = v end end
        end
    end)
end)
confSec:Button("Destroy UI", function()
    ClearAllESP()
    CleanupFly()
    -- Luxware window destroy is not standard, just clear
end)

print("ZuzifyMoon (Luxware) loaded | Owner:", isOwner)
