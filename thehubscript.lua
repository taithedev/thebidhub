--[[
    ZuzifyStar
    Password: password
    Owner: mrcoptai / 717544874
    Authors: Tai (vertexi8) & daviddabag
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= PASSWORD + OWNER =================
local CORRECT_PASSWORD = "password"
local isOwner = (LocalPlayer.Name:lower() == "mrcoptai") or (LocalPlayer.UserId == 717544874)
local passwordPassed = isOwner

if not isOwner then
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyStar_Pass"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 180)
    frame.Position = UDim2.new(0.5, -180, 0.5, -90)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 48)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyStar"
    title.TextColor3 = Color3.fromRGB(160, 255, 240)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.82, 0, 0, 40)
    box.Position = UDim2.new(0.09, 0, 0.38, 0)
    box.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = "Enter Password..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.82, 0, 0, 40)
    btn.Position = UDim2.new(0.09, 0, 0.68, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 140, 125)
    btn.Text = "Unlock"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local done = false
    local function tryUnlock()
        if box.Text == CORRECT_PASSWORD then
            passwordPassed = true
            done = true
            gui:Destroy()
        else
            box.Text = ""
            box.PlaceholderText = "Wrong password"
        end
    end

    btn.MouseButton1Click:Connect(tryUnlock)
    box.FocusLost:Connect(function(enter) if enter then tryUnlock() end end)

    while not done do task.wait() end
end

if not passwordPassed then return end

-- ================= LOAD UI =================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Luxware-UI-Library/main/Source.lua"))()
local Window = Library.CreateWindow("ZuzifyStar" .. (isOwner and " [OWNER]" or ""), 6105620301)

-- ================= FEATURES =================
local Features = {
    -- ESP
    ESP = false,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Chams = true,

    -- Noclip types
    NoclipType = "None", -- "None", "Normal", "Smooth", "MM2"

    -- Fly types
    FlyType = "None", -- "None", "BodyVelocity", "CFrame", "Smooth"
    FlySpeed = 60,

    InfiniteJump = false,
    WalkSpeed = 16,
    JumpPower = 50,
    AntiAFK = true,
    AntiFling = true,
    HitboxExtender = false,
    HitboxSize = 9,

    -- Combat
    Aimbot = false,
    SilentAim = false,
    AimbotFOV = 230,
    AimbotSmooth = 0.13,
    AimbotPrediction = 0.14,
    AimPart = "HumanoidRootPart",
    AutoKill = false,
    KnifeAura = false,
    AuraRange = 15,
    SelectedTarget = nil,
    KillTarget = false,

    -- Carries
    Piggyback = false,
    FrontCarry = false,
    SideCarry = false,
    BackCarry = false,

    -- Troll
    FlingNearest = false,
    FlingTarget = false,
    FlingAll = false,
    SpinFling = false,
    RageBait = false,

    -- Self
    Invisible = false,
    GlitchSelf = false,
    GlitchSpeed = 0.08,

    -- Utility
    CoinFarm = false,
    GrabGun = false,
    TPMurderer = false,
    TPSheriff = false,
    RoleNotify = true,
    AntiDie = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 35, 35),
    Sheriff  = Color3.fromRGB(40, 120, 255),
    Innocent = Color3.fromRGB(40, 225, 70),
}

local RoleCache = {}
local ESPObjects = {}
local BodyVel, BodyGyro = nil, nil
local lastFarm, lastKill, lastAnti, lastRole, lastFling, lastGlitch = 0, 0, 0, 0, 0, 0
local currentMurderer, currentSheriff = nil, nil
local PlayerList = {}
local ConfigName = "ZuzifyStar_Config.json"
local originalTransparency = {}

-- ================= CONFIG =================
local function SaveConfig()
    local success, err = pcall(function()
        writefile(ConfigName, HttpService:JSONEncode(Features))
    end)
    if success then
        print("[ZuzifyStar] Config saved")
    else
        print("[ZuzifyStar] Save failed:", err)
    end
end

local function LoadConfig()
    local success, err = pcall(function()
        if isfile and isfile(ConfigName) then
            local data = HttpService:JSONDecode(readfile(ConfigName))
            for k, v in pairs(data) do
                if Features[k] ~= nil then
                    Features[k] = v
                end
            end
            print("[ZuzifyStar] Config loaded")
        end
    end)
    if not success then
        print("[ZuzifyStar] Load failed:", err)
    end
end

-- ================= ROLE =================
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local function check(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = string.lower(tool.Name)
        if string.find(n, "knife") or string.find(n, "dagger") or string.find(n, "blade") or string.find(n, "sword") or string.find(n, "scythe") then
            return "Murderer"
        elseif string.find(n, "gun") or string.find(n, "revolver") or string.find(n, "pistol") or string.find(n, "rifle") then
            return "Sheriff"
        end
        return nil
    end

    local role = check(plr.Character:FindFirstChildOfClass("Tool"))
    if role then return role end

    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            role = check(item)
            if role then return role end
        end
    end
    return "Innocent"
end

-- ================= ESP =================
local function ClearESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            pcall(function() obj:Destroy() end)
        end
        ESPObjects[plr] = nil
    end
end

local function ClearAllESP()
    for plr in pairs(ESPObjects) do ClearESP(plr) end
end

local function CreateESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local role = GetRole(plr)
    local color = RoleColors[role] or RoleColors.Innocent
    local objects = {}

    if Features.ESP_Names or Features.ESP_Distance then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ZS_ESP"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 210, 0, 52)
        bb.StudsOffset = Vector3.new(0, 2.9, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 3500
        bb.Parent = head

        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1, 0, 0.55, 0)
        nameL.BackgroundTransparency = 1
        nameL.Text = plr.Name .. " [" .. role .. "]"
        nameL.TextColor3 = color
        nameL.TextStrokeTransparency = 0.15
        nameL.Font = Enum.Font.GothamBold
        nameL.TextSize = 14
        nameL.Parent = bb

        local distL = Instance.new("TextLabel")
        distL.Size = UDim2.new(1, 0, 0.45, 0)
        distL.Position = UDim2.new(0, 0, 0.55, 0)
        distL.BackgroundTransparency = 1
        distL.Text = "0"
        distL.TextColor3 = color
        distL.TextStrokeTransparency = 0.15
        distL.Font = Enum.Font.Gotham
        distL.TextSize = 12
        distL.Parent = bb

        objects.Billboard = bb
        objects.NameLabel = nameL
        objects.DistLabel = distL
    end

    if Features.ESP_Chams then
        local hl = Instance.new("Highlight")
        hl.Name = "ZS_Chams"
        hl.Adornee = char
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.48
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        objects.Highlight = hl
    end

    ESPObjects[plr] = objects
end

local function RefreshESP()
    ClearAllESP()
    if not Features.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            CreateESP(plr)
        end
    end
end

-- ================= MOVEMENT HELPERS =================
local function ApplyStats()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Features.WalkSpeed
        hum.JumpPower = Features.JumpPower
    end
end

local function ApplyNoclip()
    local char = LocalPlayer.Character
    if not char then return end

    if Features.NoclipType == "None" then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        return
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end

local function SetupFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if BodyVel then BodyVel:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end

    if Features.FlyType == "BodyVelocity" or Features.FlyType == "Smooth" then
        BodyVel = Instance.new("BodyVelocity")
        BodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        BodyVel.Velocity = Vector3.zero
        BodyVel.Parent = root

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        BodyGyro.P = 16000
        BodyGyro.Parent = root
    end
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
        root.Transparency = 0.55
        root.CanCollide = false
    else
        root.Size = Vector3.new(2, 2, 1)
        root.Transparency = 1
    end
end

local function SetInvisible(state)
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            if state then
                if not originalTransparency[part] then
                    originalTransparency[part] = part.Transparency
                end
                part.Transparency = 1
            else
                if originalTransparency[part] then
                    part.Transparency = originalTransparency[part]
                end
            end
        end
    end
    if not state then
        table.clear(originalTransparency)
    end
end

local function Teleport(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then root.CFrame = CFrame.new(pos) end
end

local function GetClosestPlayer(maxDist)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local closest, closestDist = nil, maxDist or 9999
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local dist = (myRoot.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

local function Fling(plr, strength)
    if not plr or not plr.Character then return end
    local root = plr.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    strength = strength or 140
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(math.random(-strength, strength), math.random(60, 120), math.random(-strength, strength))
    bv.Parent = root
    task.delay(0.4, function() if bv then bv:Destroy() end end)
end

local function DoCarry(style)
    if not Features.SelectedTarget then return end
    local target = Players:FindFirstChild(Features.SelectedTarget)
    if not target or not target.Character then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end

    if style == "Piggyback" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 2.9, 0.4)
    elseif style == "Front" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -2.8)
    elseif style == "Side" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(2.4, 0.5, 0)
    elseif style == "Back" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0.5, 2.6)
    end
end

-- ================= CHARACTER =================
local function OnCharacter(char)
    task.wait(0.65)
    ApplyStats()
    ApplyNoclip()
    if Features.FlyType ~= "None" then SetupFly() end
    if Features.HitboxExtender then ApplyHitbox() end
    if Features.Invisible then SetInvisible(true) end
    if Features.ESP then task.delay(0.35, RefreshESP) end
end

if LocalPlayer.Character then OnCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(OnCharacter)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.9)
        if Features.ESP then CreateESP(plr) end
        table.insert(PlayerList, plr.Name)
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    ClearESP(plr)
    for i, name in ipairs(PlayerList) do
        if name == plr.Name then table.remove(PlayerList, i) break end
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then table.insert(PlayerList, plr.Name) end
end

-- ================= MAIN LOOP =================
RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Role update
    if tick() - lastRole > 1.15 then
        lastRole = tick()
        local mur, sher = nil, nil
        for _, plr in ipairs(Players:GetPlayers()) do
            local role = GetRole(plr)
            if role == "Murderer" then mur = plr end
            if role == "Sheriff" then sher = plr end
        end
        if Features.RoleNotify then
            if mur and mur ~= currentMurderer then
                currentMurderer = mur
                print("[ZuzifyStar] Murderer:", mur.Name)
            end
            if sher and sher ~= currentSheriff then
                currentSheriff = sher
                print("[ZuzifyStar] Sheriff:", sher.Name)
            end
        end
        currentMurderer = mur
        currentSheriff = sher
    end

    -- ESP live
    if Features.ESP and root then
        for plr, objs in pairs(ESPObjects) do
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local tRoot = plr.Character.HumanoidRootPart
                local dist = (root.Position - tRoot.Position).Magnitude
                local role = GetRole(plr)
                local color = RoleColors[role] or RoleColors.Innocent

                if objs.NameLabel then
                    objs.NameLabel.Text = plr.Name .. " [" .. role .. "]"
                    objs.NameLabel.TextColor3 = color
                    objs.NameLabel.Visible = Features.ESP_Names
                end
                if objs.DistLabel then
                    objs.DistLabel.Text = math.floor(dist) .. " studs"
                    objs.DistLabel.TextColor3 = color
                    objs.DistLabel.Visible = Features.ESP_Distance
                end
                if objs.Highlight then
                    objs.Highlight.FillColor = color
                    objs.Highlight.OutlineColor = color
                end
            else
                ClearESP(plr)
            end
        end
    end

    -- Noclip types
    if Features.NoclipType ~= "None" then
        ApplyNoclip()
        if Features.NoclipType == "Smooth" and root then
            -- slight velocity assist so you don’t get stuck
            if root.AssemblyLinearVelocity.Magnitude < 2 then
                root.AssemblyLinearVelocity = root.AssemblyLinearVelocity + Vector3.new(0, 0.1, 0)
            end
        elseif Features.NoclipType == "MM2" and root then
            -- stronger push for MM2 maps
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.96
        end
    end

    -- Fly types
    if Features.FlyType ~= "None" and root then
        local cam = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then dir = dir.Unit * Features.FlySpeed end

        if Features.FlyType == "BodyVelocity" or Features.FlyType == "Smooth" then
            if BodyVel and BodyGyro then
                BodyVel.Velocity = dir
                BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
            end
        elseif Features.FlyType == "CFrame" then
            root.CFrame = root.CFrame + dir * dt * 1.1
            root.AssemblyLinearVelocity = Vector3.zero
        end
    end

    if Features.InfiniteJump and hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    if Features.AntiFling and root and root.AssemblyLinearVelocity.Magnitude > 140 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    if Features.AntiDie and hum and hum.Health < hum.MaxHealth * 0.28 then
        hum.Health = hum.MaxHealth
    end

    if Features.HitboxExtender then ApplyHitbox() end

    -- Aimbot / Silent
    if (Features.Aimbot or Features.SilentAim) and root then
        local targetPlr = GetClosestPlayer(Features.AimbotFOV)
        if targetPlr and targetPlr.Character then
            local part = targetPlr.Character:FindFirstChild(Features.AimPart) or targetPlr.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local goal = part.Position + (part.AssemblyLinearVelocity * Features.AimbotPrediction)
                if Features.SilentAim then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, goal)
                else
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, goal), Features.AimbotSmooth)
                end
            end
        end
    end

    -- Carries
    if Features.Piggyback then DoCarry("Piggyback") end
    if Features.FrontCarry then DoCarry("Front") end
    if Features.SideCarry then DoCarry("Side") end
    if Features.BackCarry then DoCarry("Back") end

    -- Combat
    if Features.KnifeAura and root then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (root.Position - tRoot.Position).Magnitude < Features.AuraRange then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end
    end

    if Features.AutoKill and tick() - lastKill > 1.4 then
        lastKill = tick()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end

    if Features.KillTarget and Features.SelectedTarget and root then
        local target = Players:FindFirstChild(Features.SelectedTarget)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.8)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end

    -- Troll / Fling
    if Features.FlingNearest and tick() - lastFling > 0.75 then
        lastFling = tick()
        local closest = GetClosestPlayer(55)
        if closest then Fling(closest, 160) end
    end
    if Features.FlingTarget and Features.SelectedTarget and tick() - lastFling > 0.55 then
        lastFling = tick()
        local target = Players:FindFirstChild(Features.SelectedTarget)
        if target then Fling(target, 180) end
    end
    if Features.FlingAll and tick() - lastFling > 1.1 then
        lastFling = tick()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then Fling(plr, 130) end
        end
    end
    if Features.SpinFling and root then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(25), 0)
    end

    -- Glitch Self
    if Features.GlitchSelf and char and tick() - lastGlitch > Features.GlitchSpeed then
        lastGlitch = tick()
        SetInvisible(not Features.Invisible)
        task.delay(Features.GlitchSpeed * 0.6, function()
            if Features.GlitchSelf then
                SetInvisible(Features.Invisible)
            end
        end)
    end

    -- Utility
    if Features.CoinFarm and root and tick() - lastFarm > 0.9 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "coin") or string.find(n, "money") or string.find(n, "cash") then
                    if (root.Position - obj.Position).Magnitude < 160 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3.2, 0))
                        break
                    end
                end
            end
        end
    end

    if Features.GrabGun and root then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "gun")) then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle")
                if part and (root.Position - part.Position).Magnitude < 220 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    break
                end
            end
        end
    end

    if Features.TPMurderer and currentMurderer and currentMurderer.Character and root then
        local tRoot = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4.5) end
    end
    if Features.TPSheriff and currentSheriff and currentSheriff.Character and root then
        local tRoot = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4.5) end
    end

    if Features.AntiAFK and tick() - lastAnti > 24 then
        lastAnti = tick()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.04)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

-- ================= UI =================
local Home = Window:Tab("Home")
local homeSec = Home:Section("Welcome")
homeSec:Label("ZuzifyStar is ready")
homeSec:Label("Password protected + Owner system")
if isOwner then homeSec:Label("OWNER MODE ACTIVE") end

local Visuals = Window:Tab("Visuals")
local espSec = Visuals:Section("ESP")
espSec:Toggle("Enable ESP", function(v) Features.ESP = v if v then RefreshESP() else ClearAllESP() end end)
espSec:Toggle("Names + Role", function(v) Features.ESP_Names = v RefreshESP() end)
espSec:Toggle("Distance", function(v) Features.ESP_Distance = v end)
espSec:Toggle("Chams", function(v) Features.ESP_Chams = v RefreshESP() end)
espSec:Button("Refresh ESP", RefreshESP)
espSec:Button("Clear ESP", function() ClearAllESP() Features.ESP = false end)

local Movement = Window:Tab("Movement")
local noclipSec = Movement:Section("Noclip Types")
noclipSec:DropDown("Noclip Type", {"None", "Normal", "Smooth", "MM2"}, function(v)
    Features.NoclipType = v
    ApplyNoclip()
end)

local flySec = Movement:Section("Fly Types")
flySec:DropDown("Fly Type", {"None", "BodyVelocity", "CFrame", "Smooth"}, function(v)
    Features.FlyType = v
    if v == "None" then CleanupFly() else SetupFly() end
end)
flySec:Slider("Fly Speed", 10, 200, function(v) Features.FlySpeed = v end)

local movSec = Movement:Section("Other")
movSec:Toggle("Infinite Jump", function(v) Features.InfiniteJump = v end)
movSec:Slider("Walk Speed", 10, 200, function(v) Features.WalkSpeed = v ApplyStats() end)
movSec:Slider("Jump Power", 30, 200, function(v) Features.JumpPower = v ApplyStats() end)
movSec:Toggle("Anti Fling", function(v) Features.AntiFling = v end)
movSec:Toggle("Anti Die", function(v) Features.AntiDie = v end)
movSec:Toggle("Hitbox Extender", function(v) Features.HitboxExtender = v ApplyHitbox() end)
movSec:Slider("Hitbox Size", 3, 22, function(v) Features.HitboxSize = v if Features.HitboxExtender then ApplyHitbox() end end)
movSec:Toggle("Anti AFK", function(v) Features.AntiAFK = v end)

local Combat = Window:Tab("Combat")
local aimSec = Combat:Section("Aimbot")
aimSec:Toggle("Aimbot", function(v) Features.Aimbot = v end)
aimSec:Toggle("Silent Aim", function(v) Features.SilentAim = v end)
aimSec:Slider("FOV", 50, 400, function(v) Features.AimbotFOV = v end)
aimSec:Slider("Smoothness", 5, 40, function(v) Features.AimbotSmooth = v / 100 end)
aimSec:DropDown("Aim Part", {"HumanoidRootPart", "Head", "UpperTorso"}, function(v) Features.AimPart = v end)

local combatSec = Combat:Section("Kill / Target")
combatSec:Toggle("Auto Kill", function(v) Features.AutoKill = v end)
combatSec:Toggle("Knife Aura", function(v) Features.KnifeAura = v end)
combatSec:Slider("Aura Range", 6, 30, function(v) Features.AuraRange = v end)
combatSec:DropDown("Select Player", PlayerList, function(v) Features.SelectedTarget = v end)
combatSec:Button("Refresh Players", function()
    PlayerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(PlayerList, plr.Name) end
    end
end)
combatSec:Toggle("Kill Selected", function(v) Features.KillTarget = v end)

local Carry = Window:Tab("Carry")
local carrySec = Carry:Section("Carry Styles")
carrySec:Toggle("Piggyback", function(v) Features.Piggyback = v end)
carrySec:Toggle("Front Carry", function(v) Features.FrontCarry = v end)
carrySec:Toggle("Side Carry", function(v) Features.SideCarry = v end)
carrySec:Toggle("Back Carry", function(v) Features.BackCarry = v end)

local Troll = Window:Tab("Troll")
local flingSec = Troll:Section("Fling")
flingSec:Toggle("Fling Nearest", function(v) Features.FlingNearest = v end)
flingSec:Toggle("Fling Selected", function(v) Features.FlingTarget = v end)
flingSec:Toggle("Fling All", function(v) Features.FlingAll = v end)
flingSec:Toggle("Spin Fling", function(v) Features.SpinFling = v end)

local rageSec = Troll:Section("Ragebait / Fun")
rageSec:Toggle("Ragebait Mode", function(v) Features.RageBait = v end)
rageSec:Button("Fake Thanks", function()
    print("[ZuzifyStar] Thanks for playing! (client)")
end)
rageSec:Button("Glitch Flash Once", function()
    SetInvisible(true)
    task.wait(0.12)
    SetInvisible(false)
end)

local Self = Window:Tab("Self")
local selfSec = Self:Section("Visual")
selfSec:Toggle("Invisible", function(v)
    Features.Invisible = v
    SetInvisible(v)
end)
selfSec:Toggle("Glitch Self (Flash)", function(v) Features.GlitchSelf = v end)
selfSec:Slider("Glitch Speed", 3, 20, function(v) Features.GlitchSpeed = v / 100 end)

local Utility = Window:Tab("Utility")
local utilSec = Utility:Section("Farm")
utilSec:Toggle("Coin Farm", function(v) Features.CoinFarm = v end)
utilSec:Toggle("Grab Gun", function(v) Features.GrabGun = v end)
utilSec:Toggle("TP to Murderer", function(v) Features.TPMurderer = v end)
utilSec:Toggle("TP to Sheriff", function(v) Features.TPSheriff = v end)
utilSec:Toggle("Role Notify", function(v) Features.RoleNotify = v end)

local Teleports = Window:Tab("Teleports")
local tpSec = Teleports:Section("Presets")
tpSec:Button("Lobby", function() Teleport(Vector3.new(0, 10, 0)) end)
tpSec:Button("Arena", function() Teleport(Vector3.new(0, 5, 50)) end)
tpSec:Button("Bank", function() Teleport(Vector3.new(0, 5, 0)) end)
tpSec:Button("Hotel", function() Teleport(Vector3.new(50, 5, 0)) end)
tpSec:Button("Hospital", function() Teleport(Vector3.new(-50, 5, 0)) end)

local Settings = Window:Tab("Settings")
local confSec = Settings:Section("Config")
confSec:Button("Save Config", SaveConfig)
confSec:Button("Load Config", LoadConfig)

local serverSec = Settings:Section("Server")
serverSec:Button("Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
serverSec:Button("Server Hop", function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local list = {}
        for _, s in ipairs(data.data or {}) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                table.insert(list, s.id)
            end
        end
        if #list > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1, #list)], LocalPlayer)
        end
    end)
end)

-- Load config on start
LoadConfig()

print("ZuzifyStar loaded | Owner: " .. tostring(isOwner))
