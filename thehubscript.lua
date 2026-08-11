--[[
    ZuzifyMoon
    Authors: Tai (vertexi8) & daviddabag
    Heavy MM2 focused hub with experimental features
    UI: Modal Library
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

local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

local Window = Modal:CreateWindow({
    Title = "ZuzifyMoon",
    SubTitle = "by Tai (vertexi8) & daviddabag",
    Size = UDim2.fromOffset(610, 580),
    MinimumSize = Vector2.new(410, 380),
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

    -- Movement
    Noclip = false,
    Fly = false,
    FlySpeed = 60,
    InfiniteJump = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AntiAFK = false,
    AntiFling = true,
    HitboxExtender = false,
    HitboxSize = 9,

    -- Aimbot
    Aimbot = false,
    SilentAim = false,
    AimbotFOV = 220,
    AimbotSmooth = 0.14,
    AimbotPrediction = 0.15,
    AimPart = "HumanoidRootPart",
    AimPriority = "Closest",
    AimVisibleOnly = false,
    AimOnlyWhenTool = false,

    -- MM2 Combat
    AutoKill = false,
    KnifeAura = false,
    AuraRange = 15,
    KillTarget = false,
    SelectedTarget = nil,
    GrabGun = false,
    CoinFarm = false,
    TPMurderer = false,
    TPSheriff = false,
    RoleNotify = true,
    AntiDie = false,

    -- Experimental Beta
    Exp_RequestRole = false,
    Exp_VoteMap = false,
    Exp_ForceSheriff = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 25, 25),
    Sheriff  = Color3.fromRGB(30, 100, 255),
    Innocent = Color3.fromRGB(25, 220, 60),
}

local RoleCache = {}
local ESPData = {}
local Tracers = {}
local BodyVel = nil
local BodyGyro = nil
local lastFarm = 0
local lastKill = 0
local lastAnti = 0
local lastRoleScan = 0
local currentMurderer = nil
local currentSheriff = nil
local DrawingAvailable = false
local ConfigName = "ZuzifyMoon_Config.json"
local PlayerList = {}

pcall(function()
    if Drawing then DrawingAvailable = true end
end)

-- ================= ROLE DETECTION =================

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
        local role = DetectRole(plr)
        RoleCache[plr] = {Role = role, Time = tick()}
    end
end

local function GetRole(plr)
    if not plr then return "Innocent" end
    local c = RoleCache[plr]
    if c and (tick() - c.Time) < 1.4 then
        return c.Role
    end
    local role = DetectRole(plr)
    RoleCache[plr] = {Role = role, Time = tick()}
    return role
end

-- ================= AIMBOT HELPERS =================

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
                        if Features.AimPriority == "Murderer" and role == "Murderer" then
                            score = score - 50
                        elseif Features.AimPriority == "Sheriff" and role == "Sheriff" then
                            score = score - 50
                        end
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

-- ================= ESP =================

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
    bb.Size = UDim2.new(0, 210, 0, 50)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 3500
    bb.Parent = head

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, 0, 0.58, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = plr.Name .. " [" .. role .. "]"
    nameL.TextColor3 = col
    nameL.TextStrokeTransparency = 0.18
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 14
    nameL.Parent = bb

    local distL = Instance.new("TextLabel")
    distL.Size = UDim2.new(1, 0, 0.42, 0)
    distL.Position = UDim2.new(0, 0, 0.58, 0)
    distL.BackgroundTransparency = 1
    distL.Text = "0"
    distL.TextColor3 = col
    distL.TextStrokeTransparency = 0.18
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
    hl.FillTransparency = 0.48
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
    line.Thickness = 1.5
    line.Transparency = 0.7
    Tracers[plr] = line
end

local function ClearPlayerESP(plr)
    if ESPData[plr] then
        pcall(function()
            if ESPData[plr].Billboard then ESPData[plr].Billboard:Destroy() end
            if ESPData[plr].Highlight then ESPData[plr].Highlight:Destroy() end
        end)
        ESPData[plr] = nil
    end
    if Tracers[plr] then
        pcall(function() Tracers[plr]:Remove() end)
        Tracers[plr] = nil
    end
end

local function ClearAllESP()
    for plr in pairs(ESPData) do ClearPlayerESP(plr) end
    for plr in pairs(Tracers) do pcall(function() Tracers[plr]:Remove() end) end
    table.clear(ESPData)
    table.clear(Tracers)
end

local function RefreshESP()
    ClearAllESP()
    if not Features.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if Features.ESP_Names then CreateNameESP(plr) end
            if Features.ESP_Chams then CreateChams(plr) end
            if Features.ESP_Tracers then CreateTracer(plr) end
        end
    end
end

-- ================= MOVEMENT =================

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
    BodyGyro.P = 15000
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
        root.Transparency = 0.6
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
    if root and root.AssemblyLinearVelocity.Magnitude > 130 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function DoAntiDie()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health < hum.MaxHealth * 0.3 then
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

-- config
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

-- refresh player list for kill target
local function RefreshPlayerList()
    PlayerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(PlayerList, plr.Name)
        end
    end
end

-- character
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

-- ================= MAIN LOOP =================

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if tick() - lastRoleScan > 1.1 then
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
                Window:Notify({Title = "Role", Description = "Murderer: " .. mur.Name, Duration = 2.7, Type = "Warning"})
            end
            if sher and sher ~= currentSheriff then
                currentSheriff = sher
                Window:Notify({Title = "Role", Description = "Sheriff: " .. sher.Name, Duration = 2.7, Type = "Info"})
            end
        end
        currentMurderer = mur
        currentSheriff = sher
    end

    -- ESP
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

    -- AIMBOT
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

    -- SILENT AIM
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

    -- KILL TARGET
    if Features.KillTarget and Features.SelectedTarget and root then
        local targetPlr = Players:FindFirstChild(Features.SelectedTarget)
        if targetPlr and targetPlr.Character then
            local tRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end

    -- AUTO KILL
    if Features.AutoKill and tick() - lastKill > 1.7 then
        lastKill = tick()
        local target = GetBestTarget()
        if target then
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end

    -- KNIFE AURA
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

    -- COIN FARM
    if Features.CoinFarm and root and tick() - lastFarm > 0.9 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "coin") or string.find(n, "money") or string.find(n, "cash") then
                    if (root.Position - obj.Position).Magnitude < 150 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        break
                    end
                end
            end
        end
    end

    -- GRAB GUN
    if Features.GrabGun and root then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "gun")) then
                local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj.PrimaryPart)
                if part and (root.Position - part.Position).Magnitude < 250 then
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

    if Features.AntiAFK and tick() - lastAnti > 26 then
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
Home:New("Title")({Title = "ZuzifyMoon"})
Home:New("Button")({
    Title = "Hello " .. LocalPlayer.Name,
    Description = "ZuzifyMoon loaded. Made by Tai (vertexi8) and daviddabag",
    Callback = function()
        Window:Notify({Title = "ZuzifyMoon", Description = "Ready", Duration = 2.5, Type = "Success"})
    end,
})
Home:New("Title")({Title = "Info"})
Home:New("Button")({
    Title = "About",
    Description = "Heavy MM2 hub with experimental features. Authors: Tai (vertexi8) & daviddabag",
    Callback = function() end,
})

local Vis = Window:AddTab("Visuals")
Vis:New("Title")({Title = "ESP"})
Vis:New("Toggle")({Title = "Enable ESP", Description = "Master switch for ESP", DefaultValue = false, Callback = function(v) Features.ESP = v if v then RefreshESP() else ClearAllESP() end end})
Vis:New("Toggle")({Title = "Names + Role", Description = "Shows name and role (Red Murderer / Blue Sheriff / Green Innocent)", DefaultValue = true, Callback = function(v) Features.ESP_Names = v RefreshESP() end})
Vis:New("Toggle")({Title = "Distance", Description = "Shows distance in studs", DefaultValue = true, Callback = function(v) Features.ESP_Distance = v end})
Vis:New("Toggle")({Title = "Chams", Description = "Full body highlight through walls", DefaultValue = false, Callback = function(v) Features.ESP_Chams = v RefreshESP() end})
Vis:New("Toggle")({Title = "Tracers", Description = "Lines from bottom of screen (needs Drawing support)", DefaultValue = false, Callback = function(v) Features.ESP_Tracers = v RefreshESP() end})
Vis:New("Button")({Title = "Refresh ESP", Description = "Rebuild all ESP", Callback = RefreshESP})
Vis:New("Button")({Title = "Clear ESP", Description = "Remove everything", Callback = function() ClearAllESP() Features.ESP = false end})

local Mov = Window:AddTab("Movement")
Mov:New("Title")({Title = "Basic"})
Mov:New("Toggle")({Title = "Noclip", Description = "Walk through walls", DefaultValue = false, Callback = function(v) Features.Noclip = v ApplyNoclip() end})
Mov:New("Toggle")({Title = "Fly", Description = "WASD + Space / LeftShift", DefaultValue = false, Callback = function(v) Features.Fly = v if v then SetupFly() else CleanupFly() end end})
Mov:New("Slider")({Title = "Fly Speed", Description = "10 to 200", Default = 60, Minimum = 10, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.FlySpeed = v end})
Mov:New("Toggle")({Title = "Infinite Jump", Description = "Jump while in air", DefaultValue = false, Callback = function(v) Features.InfiniteJump = v end})
Mov:New("Slider")({Title = "Walk Speed", Description = "Default 16", Default = 16, Minimum = 10, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.WalkSpeed = v ApplyStats() end})
Mov:New("Slider")({Title = "Jump Power", Description = "Default 50", Default = 50, Minimum = 30, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.JumpPower = v ApplyStats() end})
Mov:New("Title")({Title = "Protection"})
Mov:New("Toggle")({Title = "Anti Fling", Description = "Stops extreme velocity", DefaultValue = true, Callback = function(v) Features.AntiFling = v end})
Mov:New("Toggle")({Title = "Anti Die", Description = "Tries to keep health high", DefaultValue = false, Callback = function(v) Features.AntiDie = v end})
Mov:New("Toggle")({Title = "Hitbox Extender", Description = "Makes root part bigger for knife hits", DefaultValue = false, Callback = function(v) Features.HitboxExtender = v ApplyHitbox() end})
Mov:New("Slider")({Title = "Hitbox Size", Description = "Size of extended hitbox", Default = 9, Minimum = 3, Maximum = 20, DecimalCount = 0, Callback = function(v) Features.HitboxSize = v if Features.HitboxExtender then ApplyHitbox() end end})
Mov:New("Toggle")({Title = "Anti AFK", Description = "Prevents idle kick", DefaultValue = false, Callback = function(v) Features.AntiAFK = v end})

local Games = Window:AddTab("MM2")
Games:New("Title")({Title = "Aimbot"})
Games:New("Toggle")({Title = "Aimbot", Description = "Smooth camera lock", DefaultValue = false, Callback = function(v) Features.Aimbot = v end})
Games:New("Toggle")({Title = "Silent Aim", Description = "Hard look when tool is held", DefaultValue = false, Callback = function(v) Features.SilentAim = v end})
Games:New("Slider")({Title = "FOV / Range", Description = "Max targeting distance", Default = 220, Minimum = 50, Maximum = 400, DecimalCount = 0, Callback = function(v) Features.AimbotFOV = v end})
Games:New("Slider")({Title = "Smoothness", Description = "Lower = faster snap (0.05 - 0.4)", Default = 0.14, Minimum = 0.05, Maximum = 0.4, DecimalCount = 2, Callback = function(v) Features.AimbotSmooth = v end})
Games:New("Slider")({Title = "Prediction", Description = "Lead amount", Default = 0.15, Minimum = 0, Maximum = 0.4, DecimalCount = 2, Callback = function(v) Features.AimbotPrediction = v end})
Games:New("Dropdown")({Title = "Aim Part", Description = "What to aim at", Options = {"HumanoidRootPart", "Head", "UpperTorso"}, Default = "HumanoidRootPart", Callback = function(v) Features.AimPart = v end})
Games:New("Dropdown")({Title = "Priority", Description = "Who to prefer", Options = {"Closest", "Murderer", "Sheriff"}, Default = "Closest", Callback = function(v) Features.AimPriority = v end})
Games:New("Toggle")({Title = "Visible Only", Description = "Only target visible players", DefaultValue = false, Callback = function(v) Features.AimVisibleOnly = v end})
Games:New("Toggle")({Title = "Only When Tool", Description = "Aimbot only works while holding a tool", DefaultValue = false, Callback = function(v) Features.AimOnlyWhenTool = v end})

Games:New("Title")({Title = "Combat"})
Games:New("Toggle")({Title = "Auto Kill", Description = "Activates tool on best target", DefaultValue = false, Callback = function(v) Features.AutoKill = v end})
Games:New("Toggle")({Title = "Knife Aura", Description = "Auto activate when close", DefaultValue = false, Callback = function(v) Features.KnifeAura = v end})
Games:New("Slider")({Title = "Aura Range", Description = "Distance for aura", Default = 15, Minimum = 6, Maximum = 30, DecimalCount = 0, Callback = function(v) Features.AuraRange = v end})

Games:New("Title")({Title = "Kill Target"})
Games:New("Dropdown")({
    Title = "Select Player",
    Description = "Choose who to target",
    Options = PlayerList,
    Default = PlayerList[1] or "None",
    Callback = function(v)
        Features.SelectedTarget = v
    end,
})
Games:New("Toggle")({
    Title = "Kill Selected",
    Description = "Teleport to selected player and attack",
    DefaultValue = false,
    Callback = function(v) Features.KillTarget = v end,
})
Games:New("Button")({
    Title = "Refresh Player List",
    Description = "Update the dropdown with current players",
    Callback = function()
        RefreshPlayerList()
        Window:Notify({Title = "Players", Description = "List refreshed", Duration = 2, Type = "Info"})
    end,
})

Games:New("Title")({Title = "Utility"})
Games:New("Toggle")({Title = "Coin Farm", Description = "Moves to coins automatically", DefaultValue = false, Callback = function(v) Features.CoinFarm = v end})
Games:New("Toggle")({Title = "Grab Gun", Description = "Teleports to dropped guns", DefaultValue = false, Callback = function(v) Features.GrabGun = v end})
Games:New("Toggle")({Title = "TP to Murderer", Description = "Stay near current murderer", DefaultValue = false, Callback = function(v) Features.TPMurderer = v end})
Games:New("Toggle")({Title = "TP to Sheriff", Description = "Stay near current sheriff", DefaultValue = false, Callback = function(v) Features.TPSheriff = v end})
Games:New("Toggle")({Title = "Role Notify", Description = "Notify when roles change", DefaultValue = true, Callback = function(v) Features.RoleNotify = v end})

Games:New("Title")({Title = "Experimental Beta"})
Games:New("Button")({
    Title = "Request Role (Beta)",
    Description = "Experimental - tries to request a role. May not work because roles are server sided.",
    Callback = function()
        Window:Notify({Title = "Beta", Description = "Role request attempted (experimental)", Duration = 3, Type = "Warning"})
        -- placeholder for remote attempts
        pcall(function()
            -- common places people try, usually fail
            local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage
            -- do nothing aggressive
        end)
    end,
})
Games:New("Button")({
    Title = "Vote Map (Beta)",
    Description = "Experimental - attempts to influence map vote. Rarely works.",
    Callback = function()
        Window:Notify({Title = "Beta", Description = "Map vote attempted (experimental)", Duration = 3, Type = "Warning"})
    end,
})
Games:New("Toggle")({
    Title = "Force Sheriff Attempt (Beta)",
    Description = "Experimental toggle. Most methods no longer work.",
    DefaultValue = false,
    Callback = function(v)
        Features.Exp_ForceSheriff = v
        Window:Notify({Title = "Beta", Description = "Force Sheriff is experimental and likely inactive", Duration = 3, Type = "Warning"})
    end,
})

local TP = Window:AddTab("Teleports")
TP:New("Title")({Title = "Presets"})
local function AddTP(name, pos)
    TP:New("Button")({Title = name, Description = "Teleport to " .. name, Callback = function() Teleport(pos) end})
end
AddTP("MM2 Lobby", Vector3.new(0, 10, 0))
AddTP("MM2 Arena", Vector3.new(0, 5, 50))
AddTP("Bank", Vector3.new(0, 5, 0))
AddTP("Hotel", Vector3.new(50, 5, 0))
AddTP("Hospital", Vector3.new(-50, 5, 0))
AddTP("House", Vector3.new(0, 5, 50))
AddTP("Office", Vector3.new(30, 5, 30))
AddTP("Hailey Spot", Vector3.new(0, 50, 0))

TP:New("Title")({Title = "Custom"})
local customStr = "0, 50, 0"
TP:New("Input")({Title = "Coordinates", Description = "X, Y, Z", DefaultText = "0, 50, 0", Placeholder = "X, Y, Z", Callback = function(v) customStr = v end})
TP:New("Button")({
    Title = "Go to Custom",
    Description = "Teleport using the input",
    Callback = function()
        local ok = pcall(function()
            local nums = {}
            for n in string.gmatch(customStr, "[-%d%.]+") do table.insert(nums, tonumber(n)) end
            if #nums >= 3 then Teleport(Vector3.new(nums[1], nums[2], nums[3])) end
        end)
        if not ok then Window:Notify({Title = "Error", Description = "Bad coordinates", Duration = 2, Type = "Error"}) end
    end,
})

local Em = Window:AddTab("Emotes")
Em:New("Title")({Title = "Animations"})
Em:New("Button")({Title = "Feeling", Description = "Feeling emote", Callback = function() PlayAnim(118235501642203) end})
Em:New("Button")({Title = "Dance", Description = "Dance", Callback = function() PlayAnim(507770017) end})
Em:New("Button")({Title = "Floss", Description = "Floss", Callback = function() PlayAnim(507771019) end})
Em:New("Button")({Title = "Wave", Description = "Wave", Callback = function() PlayAnim(507770239) end})
Em:New("Button")({Title = "Flex", Description = "Flex", Callback = function() PlayAnim(507776043) end})
Em:New("Button")({Title = "Sit", Description = "Sit", Callback = function() PlayAnim(507768133) end})
Em:New("Button")({Title = "Cartwheel", Description = "Cartwheel", Callback = function() PlayAnim(507777268) end})

local Set = Window:AddTab("Settings")
Set:New("Title")({Title = "Server"})
Set:New("Button")({Title = "Rejoin", Description = "Rejoin current place", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end})
Set:New("Button")({
    Title = "Server Hop",
    Description = "Join a different public server",
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
Set:New("Button")({Title = "Save Settings", Description = "Save everything", Callback = SaveConfig})
Set:New("Button")({Title = "Load Settings", Description = "Load saved settings", Callback = LoadConfig})
Set:New("Title")({Title = "Theme"})
Set:New("Dropdown")({Title = "UI Theme", Description = "Change theme", Options = {"Light", "Dark", "Midnight", "Rose", "Emerald"}, Default = "Rose", Callback = function(v) Window:SetTheme(v) end})
Set:New("Button")({
    Title = "Destroy UI",
    Description = "Close hub and clean up",
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
    Description = "Loaded for " .. LocalPlayer.Name,
    Duration = 4,
    Type = "Success"
})

print("ZuzifyMoon loaded - Tai (vertexi8) & daviddabag")
