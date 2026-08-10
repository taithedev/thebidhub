--[[
    Hailey Bidwell Hub
    Authors: Tai (vertexi8) & daviddabag
    For Hailey Bidwell
    UI: Modal
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

local Window = Modal:CreateWindow({
    Title = "Hailey Bidwell Hub",
    SubTitle = "by Tai (vertexi8) & daviddabag",
    Size = UDim2.fromOffset(590, 550),
    MinimumSize = Vector2.new(390, 350),
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
    FlySpeed = 55,
    InfiniteJump = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AntiAFK = false,
    AntiFling = true,
    HitboxExtender = false,
    HitboxSize = 8,

    -- MM2 Combat
    MM2_Aimbot = false,
    MM2_SilentAim = false,
    MM2_AimbotFOV = 180,
    MM2_AimbotSmooth = 0.18,
    MM2_AimbotPrediction = true,
    MM2_AutoKill = false,
    MM2_KnifeAura = false,
    MM2_AuraRange = 14,
    MM2_GrabGun = false,
    MM2_TPMurderer = false,
    MM2_TPSheriff = false,
    MM2_RoleNotify = true,
    MM2_AntiDie = false,
    MM2_CoinFarm = false,

    -- Other
    AdoptMeFarm = false,
    BrookhavenCollect = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 35, 35),
    Sheriff  = Color3.fromRGB(40, 110, 255),
    Innocent = Color3.fromRGB(35, 220, 70),
}

local ESPData = {}
local Tracers = {}
local BodyVel = nil
local BodyGyro = nil
local lastFarm = 0
local lastKill = 0
local lastAnti = 0
local lastRole = 0
local currentMurderer = nil
local currentSheriff = nil
local DrawingAvailable = false
local ConfigName = "HaileyBidwellHub_Config.json"

pcall(function()
    if Drawing then DrawingAvailable = true end
end)

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

-- role
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local function check(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = string.lower(tool.Name)
        if string.find(n, "knife") or string.find(n, "dagger") or string.find(n, "blade") then
            return "Murderer"
        elseif string.find(n, "gun") or string.find(n, "revolver") or string.find(n, "pistol") then
            return "Sheriff"
        end
        return nil
    end
    local eq = plr.Character:FindFirstChildOfClass("Tool")
    local r = check(eq)
    if r then return r end
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            r = check(item)
            if r then return r end
        end
    end
    return "Innocent"
end

-- closest target for aimbot / silent
local function GetClosestTarget(maxDist, preferRole)
    local closest = nil
    local closestDist = maxDist or 200
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (myRoot.Position - root.Position).Magnitude
                if dist < closestDist then
                    local role = GetRole(plr)
                    -- simple priority: if we are sheriff prefer murderer, etc
                    if preferRole and role ~= preferRole then
                        -- still allow but lower priority by increasing effective dist a bit
                        dist = dist + 15
                    end
                    if dist < closestDist then
                        closestDist = dist
                        closest = root
                    end
                end
            end
        end
    end
    return closest
end

-- prediction helper
local function PredictPosition(targetRoot)
    if not Features.MM2_AimbotPrediction or not targetRoot then return targetRoot.Position end
    local vel = targetRoot.AssemblyLinearVelocity
    return targetRoot.Position + (vel * 0.12)
end

-- ESP functions
local function CreateNameESP(plr)
    if plr == LocalPlayer or (ESPData[plr] and ESPData[plr].Billboard) then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local role = GetRole(plr)
    local col = RoleColors[role] or RoleColors.Innocent

    local bb = Instance.new("BillboardGui")
    bb.Name = "HB_ESP"
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 48)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 3000
    bb.Parent = head

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, 0, 0.58, 0)
    nameL.BackgroundTransparency = 1
    nameL.Text = plr.Name .. " [" .. role .. "]"
    nameL.TextColor3 = col
    nameL.TextStrokeTransparency = 0.2
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 14
    nameL.Parent = bb

    local distL = Instance.new("TextLabel")
    distL.Size = UDim2.new(1, 0, 0.42, 0)
    distL.Position = UDim2.new(0, 0, 0.58, 0)
    distL.BackgroundTransparency = 1
    distL.Text = "0"
    distL.TextColor3 = col
    distL.TextStrokeTransparency = 0.2
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
    hl.Name = "HB_Chams"
    hl.Adornee = char
    hl.FillColor = col
    hl.OutlineColor = col
    hl.FillTransparency = 0.5
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
    line.Thickness = 1.4
    line.Transparency = 0.75
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

-- movement
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
    BodyGyro.P = 14000
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
        root.Transparency = 0.65
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
    if root and root.AssemblyLinearVelocity.Magnitude > 140 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function DoAntiDie()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health < hum.MaxHealth * 0.35 then
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

-- character
local function OnChar(char)
    task.wait(0.75)
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
        task.wait(0.85)
        if Features.ESP then
            if Features.ESP_Names then CreateNameESP(plr) end
            if Features.ESP_Chams then CreateChams(plr) end
            if Features.ESP_Tracers then CreateTracer(plr) end
        end
    end)
end)

Players.PlayerRemoving:Connect(ClearPlayerESP)

-- main loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- ESP live
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
    if Features.MM2_AntiDie then DoAntiDie() end
    if Features.HitboxExtender then ApplyHitbox() end

    -- role tracking
    if tick() - lastRole > 1.6 then
        lastRole = tick()
        local mur, sher = nil, nil
        for _, p in ipairs(Players:GetPlayers()) do
            local r = GetRole(p)
            if r == "Murderer" then mur = p end
            if r == "Sheriff" then sher = p end
        end
        if Features.MM2_RoleNotify then
            if mur and mur ~= currentMurderer then
                currentMurderer = mur
                Window:Notify({Title = "Role", Description = "Murderer: " .. mur.Name, Duration = 2.8, Type = "Warning"})
            end
            if sher and sher ~= currentSheriff then
                currentSheriff = sher
                Window:Notify({Title = "Role", Description = "Sheriff: " .. sher.Name, Duration = 2.8, Type = "Info"})
            end
        end
        currentMurderer = mur
        currentSheriff = sher
    end

    -- better aimbot (smooth)
    if Features.MM2_Aimbot and root then
        local target = GetClosestTarget(Features.MM2_AimbotFOV)
        if target then
            local goal = PredictPosition(target)
            local current = Camera.CFrame
            local look = CFrame.lookAt(current.Position, goal)
            Camera.CFrame = current:Lerp(look, Features.MM2_AimbotSmooth)
        end
    end

    -- silent aim (snaps only when needed / tool active)
    if Features.MM2_SilentAim and root then
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            local target = GetClosestTarget(Features.MM2_AimbotFOV + 40)
            if target then
                local goal = PredictPosition(target)
                -- temporary hard look for the shot
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, goal)
            end
        end
    end

    -- auto kill
    if Features.MM2_AutoKill and tick() - lastKill > 2.0 then
        lastKill = tick()
        local target = GetClosestTarget(80, "Murderer")
        if target then
            local tool = char and char:FindFirstChildOfClass("Tool")
            if tool then tool:Activate() end
        end
    end

    -- knife aura
    if Features.MM2_KnifeAura and root then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tr = p.Character:FindFirstChild("HumanoidRootPart")
                if tr and (root.Position - tr.Position).Magnitude < Features.MM2_AuraRange then
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end

    -- coin farm
    if Features.MM2_CoinFarm and root and tick() - lastFarm > 1.0 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "coin") or string.find(n, "money") or string.find(n, "cash") then
                    if (root.Position - obj.Position).Magnitude < 140 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        break
                    end
                end
            end
        end
    end

    -- grab gun
    if Features.MM2_GrabGun and root then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "gun")) then
                local part = obj:IsA("BasePart") and obj or (obj:FindFirstChild("Handle") or obj.PrimaryPart)
                if part and (root.Position - part.Position).Magnitude < 220 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    break
                end
            end
        end
    end

    if Features.MM2_TPMurderer and currentMurderer and currentMurderer.Character and root then
        local tr = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
        if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, 5) end
    end

    if Features.MM2_TPSheriff and currentSheriff and currentSheriff.Character and root then
        local tr = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
        if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, 5) end
    end

    if Features.AntiAFK and tick() - lastAnti > 28 then
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
Home:New("Title")({Title = "Welcome"})
Home:New("Button")({
    Title = "Hello " .. LocalPlayer.Name,
    Description = "Hailey Bidwell Hub loaded. Authors: Tai (vertexi8) and daviddabag",
    Callback = function()
        Window:Notify({Title = "Hub", Description = "Ready", Duration = 2.5, Type = "Success"})
    end,
})
Home:New("Title")({Title = "Credits"})
Home:New("Button")({
    Title = "About",
    Description = "Made for Hailey Bidwell by Tai (vertexi8) and daviddabag",
    Callback = function() end,
})

local Vis = Window:AddTab("Visuals")
Vis:New("Title")({Title = "ESP"})
Vis:New("Toggle")({
    Title = "Enable ESP",
    Description = "Master switch for all ESP types",
    DefaultValue = false,
    Callback = function(v)
        Features.ESP = v
        if v then RefreshESP() else ClearAllESP() end
    end,
})
Vis:New("Toggle")({
    Title = "Names + Role",
    Description = "Name and role text. Red Murderer, Blue Sheriff, Green Innocent",
    DefaultValue = true,
    Callback = function(v) Features.ESP_Names = v RefreshESP() end,
})
Vis:New("Toggle")({
    Title = "Distance",
    Description = "Shows distance under name",
    DefaultValue = true,
    Callback = function(v) Features.ESP_Distance = v end,
})
Vis:New("Toggle")({
    Title = "Chams",
    Description = "Full body highlight through walls",
    DefaultValue = false,
    Callback = function(v) Features.ESP_Chams = v RefreshESP() end,
})
Vis:New("Toggle")({
    Title = "Tracers",
    Description = "Lines from screen bottom to players (needs Drawing)",
    DefaultValue = false,
    Callback = function(v) Features.ESP_Tracers = v RefreshESP() end,
})
Vis:New("Button")({Title = "Refresh ESP", Description = "Rebuild everything", Callback = RefreshESP})
Vis:New("Button")({Title = "Clear ESP", Description = "Remove all ESP", Callback = function() ClearAllESP() Features.ESP = false end})

local Mov = Window:AddTab("Movement")
Mov:New("Title")({Title = "Movement"})
Mov:New("Toggle")({Title = "Noclip", Description = "Walk through walls", DefaultValue = false, Callback = function(v) Features.Noclip = v ApplyNoclip() end})
Mov:New("Toggle")({Title = "Fly", Description = "WASD + Space/Shift", DefaultValue = false, Callback = function(v) Features.Fly = v if v then SetupFly() else CleanupFly() end end})
Mov:New("Slider")({Title = "Fly Speed", Description = "10-200", Default = 55, Minimum = 10, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.FlySpeed = v end})
Mov:New("Toggle")({Title = "Infinite Jump", Description = "Jump in air", DefaultValue = false, Callback = function(v) Features.InfiniteJump = v end})
Mov:New("Slider")({Title = "Walk Speed", Description = "Default 16", Default = 16, Minimum = 10, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.WalkSpeed = v ApplyStats() end})
Mov:New("Slider")({Title = "Jump Power", Description = "Default 50", Default = 50, Minimum = 30, Maximum = 200, DecimalCount = 0, Callback = function(v) Features.JumpPower = v ApplyStats() end})
Mov:New("Title")({Title = "Protection"})
Mov:New("Toggle")({Title = "Anti Fling", Description = "Stops high velocity flings", DefaultValue = true, Callback = function(v) Features.AntiFling = v end})
Mov:New("Toggle")({Title = "Anti Die", Description = "Keeps health high when low", DefaultValue = false, Callback = function(v) Features.MM2_AntiDie = v end})
Mov:New("Toggle")({Title = "Hitbox Extender", Description = "Bigger root part for knife", DefaultValue = false, Callback = function(v) Features.HitboxExtender = v ApplyHitbox() end})
Mov:New("Slider")({Title = "Hitbox Size", Description = "Size of extended hitbox", Default = 8, Minimum = 3, Maximum = 18, DecimalCount = 0, Callback = function(v) Features.HitboxSize = v if Features.HitboxExtender then ApplyHitbox() end end})
Mov:New("Toggle")({Title = "Anti AFK", Description = "Prevents idle kick", DefaultValue = false, Callback = function(v) Features.AntiAFK = v end})

local Games = Window:AddTab("MM2")
Games:New("Title")({Title = "Aiming"})
Games:New("Toggle")({
    Title = "Aimbot",
    Description = "Smooth camera lock to closest player. Uses FOV and smoothness below.",
    DefaultValue = false,
    Callback = function(v) Features.MM2_Aimbot = v end,
})
Games:New("Toggle")({
    Title = "Silent Aim",
    Description = "Forces aim toward target when you have a tool equipped (less visible snap).",
    DefaultValue = false,
    Callback = function(v) Features.MM2_SilentAim = v end,
})
Games:New("Slider")({
    Title = "Aimbot FOV / Range",
    Description = "Max distance the aimbot and silent aim will target",
    Default = 180,
    Minimum = 60,
    Maximum = 350,
    DecimalCount = 0,
    Callback = function(v) Features.MM2_AimbotFOV = v end,
})
Games:New("Slider")({
    Title = "Aimbot Smoothness",
    Description = "Lower = faster snap, higher = smoother (0.05 - 0.4)",
    Default = 0.18,
    Minimum = 0.05,
    Maximum = 0.4,
    DecimalCount = 2,
    Callback = function(v) Features.MM2_AimbotSmooth = v end,
})
Games:New("Toggle")({
    Title = "Prediction",
    Description = "Leads the target a little based on velocity",
    DefaultValue = true,
    Callback = function(v) Features.MM2_AimbotPrediction = v end,
})

Games:New("Title")({Title = "Combat"})
Games:New("Toggle")({Title = "Auto Kill", Description = "Activates tool on nearby targets", DefaultValue = false, Callback = function(v) Features.MM2_AutoKill = v end})
Games:New("Toggle")({Title = "Knife Aura", Description = "Auto activates when close", DefaultValue = false, Callback = function(v) Features.MM2_KnifeAura = v end})
Games:New("Slider")({Title = "Aura Range", Description = "Knife aura distance", Default = 14, Minimum = 6, Maximum = 25, DecimalCount = 0, Callback = function(v) Features.MM2_AuraRange = v end})

Games:New("Title")({Title = "Utility"})
Games:New("Toggle")({Title = "Coin Farm", Description = "Moves to coins automatically", DefaultValue = false, Callback = function(v) Features.MM2_CoinFarm = v end})
Games:New("Toggle")({Title = "Grab Gun", Description = "Teleports to dropped guns", DefaultValue = false, Callback = function(v) Features.MM2_GrabGun = v end})
Games:New("Toggle")({Title = "TP to Murderer", Description = "Stays near murderer", DefaultValue = false, Callback = function(v) Features.MM2_TPMurderer = v end})
Games:New("Toggle")({Title = "TP to Sheriff", Description = "Stays near sheriff", DefaultValue = false, Callback = function(v) Features.MM2_TPSheriff = v end})
Games:New("Toggle")({Title = "Role Notify", Description = "Notifies when roles change", DefaultValue = true, Callback = function(v) Features.MM2_RoleNotify = v end})

local TP = Window:AddTab("Teleports")
TP:New("Title")({Title = "Presets"})
local function AddTP(name, pos)
    TP:New("Button")({Title = name, Description = "Teleport to " .. name, Callback = function() Teleport(pos) end})
end
AddTP("MM2 Lobby", Vector3.new(0, 10, 0))
AddTP("MM2 Arena", Vector3.new(0, 5, 50))
AddTP("Adopt Me Home", Vector3.new(0, 10, 0))
AddTP("Adopt Me Shop", Vector3.new(100, 10, 0))
AddTP("Brookhaven House", Vector3.new(0, 5, 0))
AddTP("Brookhaven Store", Vector3.new(50, 5, 0))
AddTP("Hockey Rink", Vector3.new(0, 5, 0))
AddTP("Duel Arena", Vector3.new(0, 5, 0))
AddTP("Hailey Spot", Vector3.new(0, 50, 0))

TP:New("Title")({Title = "Custom"})
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
Set:New("Button")({Title = "Save Settings", Description = "Save all toggles and values", Callback = SaveConfig})
Set:New("Button")({Title = "Load Settings", Description = "Load saved settings", Callback = LoadConfig})
Set:New("Title")({Title = "Theme"})
Set:New("Dropdown")({
    Title = "UI Theme",
    Description = "Change window theme",
    Options = {"Light", "Dark", "Midnight", "Rose", "Emerald"},
    Default = "Rose",
    Callback = function(v) Window:SetTheme(v) end,
})
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
    Title = "Hailey Bidwell Hub",
    Description = "Loaded for " .. LocalPlayer.Name,
    Duration = 4,
    Type = "Success"
})

print("Hailey Bidwell Hub loaded - Tai (vertexi8) & daviddabag")
