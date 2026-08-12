--[[
    ZuzifyRBX - Fully Upgraded
    UI: Fluent-Modded by StyearX
    Password: password
    Owner: mrcoptai / 717544874
    Beta Gamepass: 1944876349
    News: https://pastebin.com/raw/F3p7v62u
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= PASSWORD + OWNER + BETA =================
local CORRECT_PASSWORD = "password"
local BETA_GAMEPASS_ID = 1944876349
local isOwner = (LocalPlayer.Name:lower() == "mrcoptai") or (LocalPlayer.UserId == 717544874)
local passwordPassed = isOwner
local hasBeta = isOwner

if not isOwner then
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_Pass"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 200)
    frame.Position = UDim2.new(0.5, -190, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 255, 200)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX"
    title.TextColor3 = Color3.fromRGB(140, 255, 230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.84, 0, 0, 42)
    box.Position = UDim2.new(0.08, 0, 0.38, 0)
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = "Enter Password..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 9)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.84, 0, 0, 42)
    btn.Position = UDim2.new(0.08, 0, 0.68, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 180, 150)
    btn.Text = "Unlock"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

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
    box.FocusLost:Connect(function(enter)
        if enter then tryUnlock() end
    end)

    while not done do task.wait() end
end

if not passwordPassed then return end

pcall(function()
    hasBeta = MarketplaceService:UserOwnsGamePassAsync(LocalPlayer.UserId, BETA_GAMEPASS_ID) or isOwner
end)

-- ================= LOAD FLUENT =================
local Fluent = loadstring(game:HttpGet("https://github.com/StyearX/Fluent-Modded/releases/download/Fluent/FluentPro"))()
local SaveManager = Fluent.SaveManager
local InterfaceManager = Fluent.InterfaceManager

local Window = Fluent:CreateWindow({
    Title = "ZuzifyRBX" .. (isOwner and " [OWNER]" or (hasBeta and " [BETA]" or "")),
    SubTitle = "by Tai (vertexi8) • Fully Upgraded",
    TabWidth = 165,
    Size = UDim2.fromOffset(620, 520),
    Acrylic = true,
    Theme = "AMOLED",
    MinimizeKey = Enum.KeyCode.LeftControl,
    Search = true,
})

-- ================= FEATURES TABLE =================
local Features = {
    -- Visuals
    ESP = false,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Chams = true,
    ESP_Tracers = false,

    -- Movement
    NoclipType = "None",
    FlyType = "None",
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

    -- Carry
    Piggyback = false,
    FrontCarry = false,
    SideCarry = false,

    -- Troll
    FlingNearest = false,
    FlingTarget = false,
    FlingAll = false,

    -- Self
    Invisible = false,
    ServerInvisBypass = false,
    GlitchSelf = false,

    -- Utility
    CoinFarm = false,
    GrabGun = false,
    TPMurderer = false,
    TPSheriff = false,
    RoleNotify = true,
    AntiDie = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 45, 45),
    Sheriff = Color3.fromRGB(50, 140, 255),
    Innocent = Color3.fromRGB(50, 230, 90),
}

local ESPObjects = {}
local BodyVel, BodyGyro = nil, nil
local lastFarm, lastKill, lastAnti, lastRole, lastFling, lastGlitch = 0, 0, 0, 0, 0, 0
local currentMurderer, currentSheriff = nil, nil
local PlayerList = {}
local originalTransparency = {}

-- ================= ROLE DETECTION =================
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end

    local function check(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = string.lower(tool.Name)
        if string.find(n, "knife") or string.find(n, "dagger") or string.find(n, "blade") or string.find(n, "sword") then
            return "Murderer"
        elseif string.find(n, "gun") or string.find(n, "revolver") or string.find(n, "pistol") then
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

-- ================= ESP SYSTEM =================
local function ClearESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            pcall(function() obj:Destroy() end)
        end
        ESPObjects[plr] = nil
    end
end

local function ClearAllESP()
    for plr in pairs(ESPObjects) do
        ClearESP(plr)
    end
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
        bb.Name = "ZRBX_ESP"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 220, 0, 55)
        bb.StudsOffset = Vector3.new(0, 3.1, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 4000
        bb.Parent = head

        local nameL = Instance.new("TextLabel")
        nameL.Size = UDim2.new(1, 0, 0.55, 0)
        nameL.BackgroundTransparency = 1
        nameL.Text = plr.Name .. " [" .. role .. "]"
        nameL.TextColor3 = color
        nameL.TextStrokeTransparency = 0.1
        nameL.Font = Enum.Font.GothamBold
        nameL.TextSize = 14
        nameL.Parent = bb

        local distL = Instance.new("TextLabel")
        distL.Size = UDim2.new(1, 0, 0.45, 0)
        distL.Position = UDim2.new(0, 0, 0.55, 0)
        distL.BackgroundTransparency = 1
        distL.Text = "0"
        distL.TextColor3 = color
        distL.TextStrokeTransparency = 0.1
        distL.Font = Enum.Font.Gotham
        distL.TextSize = 12
        distL.Parent = bb

        objects.Billboard = bb
        objects.NameLabel = nameL
        objects.DistLabel = distL
    end

    if Features.ESP_Chams then
        local hl = Instance.new("Highlight")
        hl.Name = "ZRBX_Chams"
        hl.Adornee = char
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.45
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

-- ================= HELPERS =================
local function ApplyStats()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Features.WalkSpeed
        hum.JumpPower = Features.JumpPower
        hum.JumpHeight = Features.JumpPower / 5 -- better compatibility
    end
end

local function ApplyNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = (Features.NoclipType == "None")
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

    if Features.FlyType ~= "None" then
        BodyVel = Instance.new("BodyVelocity")
        BodyVel.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        BodyVel.Velocity = Vector3.zero
        BodyVel.Parent = root

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        BodyGyro.P = 18000
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
        root.CanCollide = true
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
                if part:IsA("BasePart") then
                    pcall(function() part.LocalTransparencyModifier = 1 end)
                end
            else
                if originalTransparency[part] then
                    part.Transparency = originalTransparency[part]
                end
                if part:IsA("BasePart") then
                    pcall(function() part.LocalTransparencyModifier = 0 end)
                end
            end
        end
    end
    if not state then table.clear(originalTransparency) end
end

local function ApplyServerInvisBypass()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.LocalTransparencyModifier = 1
                part.Transparency = 1
            end)
        end
    end
end

local function Teleport(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos)
    end
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

    strength = strength or 160
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bv.Velocity = Vector3.new(math.random(-strength, strength), math.random(80, 140), math.random(-strength, strength))
    bv.Parent = root
    task.delay(0.35, function()
        if bv then bv:Destroy() end
    end)
end

local function DoCarry(style)
    if not Features.SelectedTarget then return end
    local target = Players:FindFirstChild(Features.SelectedTarget)
    if not target or not target.Character then return end

    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end

    if style == "Piggyback" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 3.0, 0.3)
    elseif style == "Front" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -3.0)
    elseif style == "Side" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(2.6, 0.4, 0)
    end
end

-- ================= CHARACTER HANDLING =================
local function OnCharacter(char)
    task.wait(0.7)
    ApplyStats()
    ApplyNoclip()
    if Features.FlyType ~= "None" then SetupFly() end
    if Features.HitboxExtender then ApplyHitbox() end
    if Features.Invisible then SetInvisible(true) end
    if Features.ServerInvisBypass then ApplyServerInvisBypass() end
    if Features.ESP then
        task.delay(0.4, RefreshESP)
    end
end

if LocalPlayer.Character then
    OnCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(OnCharacter)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(1)
        if Features.ESP then CreateESP(plr) end
        if not table.find(PlayerList, plr.Name) then
            table.insert(PlayerList, plr.Name)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    ClearESP(plr)
    for i, name in ipairs(PlayerList) do
        if name == plr.Name then
            table.remove(PlayerList, i)
            break
        end
    end
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        table.insert(PlayerList, plr.Name)
    end
end

-- ================= MAIN LOOP =================
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    -- Role update
    if tick() - lastRole > 1.1 then
        lastRole = tick()
        local mur, sher = nil, nil
        for _, plr in ipairs(Players:GetPlayers()) do
            local role = GetRole(plr)
            if role == "Murderer" then mur = plr end
            if role == "Sheriff" then sher = plr end
        end
        currentMurderer = mur
        currentSheriff = sher
    end

    -- ESP update
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

    -- Noclip
    if Features.NoclipType ~= "None" then
        ApplyNoclip()
    end

    -- Fly
    if Features.FlyType ~= "None" and root and BodyVel and BodyGyro then
        local cam = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        if dir.Magnitude > 0 then
            dir = dir.Unit * Features.FlySpeed
        end
        BodyVel.Velocity = dir
        BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
    end

    -- Infinite Jump
    if Features.InfiniteJump and hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- Anti Fling
    if Features.AntiFling and root and root.AssemblyLinearVelocity.Magnitude > 150 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    -- Anti Die
    if Features.AntiDie and hum and hum.Health < hum.MaxHealth * 0.25 then
        hum.Health = hum.MaxHealth
    end

    -- Hitbox
    if Features.HitboxExtender then
        ApplyHitbox()
    end

    -- Server Invis
    if Features.ServerInvisBypass then
        ApplyServerInvisBypass()
    end

    -- Aimbot / Silent Aim
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

    -- Carry
    if Features.Piggyback then DoCarry("Piggyback") end
    if Features.FrontCarry then DoCarry("Front") end
    if Features.SideCarry then DoCarry("Side") end

    -- Knife Aura
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

    -- Auto Kill
    if Features.AutoKill and tick() - lastKill > 1.3 then
        lastKill = tick()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then tool:Activate() end
    end

    -- Kill Selected
    if Features.KillTarget and Features.SelectedTarget and root then
        local target = Players:FindFirstChild(Features.SelectedTarget)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.6)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end

    -- Fling
    if Features.FlingNearest and tick() - lastFling > 0.7 then
        lastFling = tick()
        local closest = GetClosestPlayer(60)
        if closest then Fling(closest) end
    end

    if Features.FlingTarget and Features.SelectedTarget and tick() - lastFling > 0.5 then
        lastFling = tick()
        local target = Players:FindFirstChild(Features.SelectedTarget)
        if target then Fling(target) end
    end

    if Features.FlingAll and tick() - lastFling > 1.0 then
        lastFling = tick()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then Fling(plr) end
        end
    end

    -- Glitch Self
    if Features.GlitchSelf and char and tick() - lastGlitch > 0.08 then
        lastGlitch = tick()
        SetInvisible(true)
        task.delay(0.05, function()
            if Features.GlitchSelf then
                SetInvisible(Features.Invisible)
            end
        end)
    end

    -- Coin Farm
    if Features.CoinFarm and root and tick() - lastFarm > 0.85 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "coin") or string.find(n, "money") or string.find(n, "cash") then
                    if (root.Position - obj.Position).Magnitude < 180 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3.5, 0))
                        break
                    end
                end
            end
        end
    end

    -- Grab Gun
    if Features.GrabGun and root then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "gun")) then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle")
                if part and (root.Position - part.Position).Magnitude < 250 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.2, 0))
                    break
                end
            end
        end
    end

    -- TP Roles
    if Features.TPMurderer and currentMurderer and currentMurderer.Character and root then
        local tRoot = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4.2)
        end
    end

    if Features.TPSheriff and currentSheriff and currentSheriff.Character and root then
        local tRoot = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4.2)
        end
    end

    -- Anti AFK
    if Features.AntiAFK and tick() - lastAnti > 22 then
        lastAnti = tick()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

-- ================= UI TABS =================

-- HOME
local HomeTab = Window:AddTab({ Title = "Home", Icon = "solar/home-bold" })
HomeTab:AddParagraph("Welcome", "ZuzifyRBX fully upgraded version loaded.\nPassword + Owner + Beta system active.")
if isOwner then
    HomeTab:AddParagraph("Owner Status", "OWNER ACCESS GRANTED")
end
if hasBeta then
    HomeTab:AddParagraph("Beta Status", "BETA UNLOCKED")
else
    HomeTab:AddParagraph("Beta Status", "Beta locked — buy gamepass 1944876349")
end

-- NEWS TAB (from Pastebin)
local NewsTab = Window:AddTab({ Title = "News", Icon = "solar/letter-bold" })
local newsContent = "Loading Zuzify News..."
pcall(function()
    newsContent = game:HttpGet("https://pastebin.com/raw/F3p7v62u")
end)
NewsTab:AddParagraph("Zuzify News", newsContent)
NewsTab:AddButton({
    Title = "Refresh News",
    Callback = function()
        local newNews = "Failed to load"
        pcall(function()
            newNews = game:HttpGet("https://pastebin.com/raw/F3p7v62u")
        end)
        Fluent:Notify({
            Title = "Zuzify News",
            Content = newNews,
            Duration = 6
        })
    end
})

-- VISUALS
local VisualsTab = Window:AddTab({ Title = "Visuals", Icon = "solar/eye-bold" })
VisualsTab:AddToggle("ESP", {
    Title = "Enable ESP",
    Default = false,
    Callback = function(v)
        Features.ESP = v
        if v then RefreshESP() else ClearAllESP() end
    end
})
VisualsTab:AddToggle("Names", {
    Title = "Names + Role",
    Default = true,
    Callback = function(v)
        Features.ESP_Names = v
        RefreshESP()
    end
})
VisualsTab:AddToggle("Distance", {
    Title = "Distance",
    Default = true,
    Callback = function(v) Features.ESP_Distance = v end
})
VisualsTab:AddToggle("Chams", {
    Title = "Chams / Highlights",
    Default = true,
    Callback = function(v)
        Features.ESP_Chams = v
        RefreshESP()
    end
})
VisualsTab:AddButton({ Title = "Refresh ESP", Callback = RefreshESP })
VisualsTab:AddButton({
    Title = "Clear All ESP",
    Callback = function()
        ClearAllESP()
        Features.ESP = false
    end
})

-- MOVEMENT
local MovementTab = Window:AddTab({ Title = "Movement", Icon = "solar/running-bold" })
MovementTab:AddDropdown("NoclipType", {
    Title = "Noclip Type",
    Values = {"None", "Normal", "Smooth", "MM2"},
    Default = 1,
    Callback = function(v)
        Features.NoclipType = v
        ApplyNoclip()
    end
})
MovementTab:AddDropdown("FlyType", {
    Title = "Fly Type",
    Values = {"None", "BodyVelocity", "Smooth"},
    Default = 1,
    Callback = function(v)
        Features.FlyType = v
        if v == "None" then CleanupFly() else SetupFly() end
    end
})
MovementTab:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Default = 60,
    Min = 10,
    Max = 250,
    Callback = function(v) Features.FlySpeed = v end
})
MovementTab:AddToggle("InfiniteJump", {
    Title = "Infinite Jump",
    Default = false,
    Callback = function(v) Features.InfiniteJump = v end
})
MovementTab:AddSlider("WalkSpeed", {
    Title = "Walk Speed",
    Default = 16,
    Min = 10,
    Max = 250,
    Callback = function(v)
        Features.WalkSpeed = v
        ApplyStats()
    end
})
MovementTab:AddSlider("JumpPower", {
    Title = "Jump Power",
    Default = 50,
    Min = 30,
    Max = 250,
    Callback = function(v)
        Features.JumpPower = v
        ApplyStats()
    end
})
MovementTab:AddToggle("AntiFling", {
    Title = "Anti Fling",
    Default = true,
    Callback = function(v) Features.AntiFling = v end
})
MovementTab:AddToggle("AntiDie", {
    Title = "Anti Die",
    Default = false,
    Callback = function(v) Features.AntiDie = v end
})
MovementTab:AddToggle("Hitbox", {
    Title = "Hitbox Extender",
    Default = false,
    Callback = function(v)
        Features.HitboxExtender = v
        ApplyHitbox()
    end
})
MovementTab:AddSlider("HitboxSize", {
    Title = "Hitbox Size",
    Default = 9,
    Min = 3,
    Max = 25,
    Callback = function(v)
        Features.HitboxSize = v
        if Features.HitboxExtender then ApplyHitbox() end
    end
})
MovementTab:AddToggle("AntiAFK", {
    Title = "Anti AFK",
    Default = true,
    Callback = function(v) Features.AntiAFK = v end
})

-- COMBAT
local CombatTab = Window:AddTab({ Title = "Combat", Icon = "solar/sword-bold" })
CombatTab:AddToggle("Aimbot", {
    Title = "Aimbot",
    Default = false,
    Callback = function(v) Features.Aimbot = v end
})
CombatTab:AddToggle("SilentAim", {
    Title = "Silent Aim",
    Default = false,
    Callback = function(v) Features.SilentAim = v end
})
CombatTab:AddSlider("FOV", {
    Title = "Aimbot FOV",
    Default = 230,
    Min = 50,
    Max = 450,
    Callback = function(v) Features.AimbotFOV = v end
})
CombatTab:AddSlider("Smoothness", {
    Title = "Smoothness",
    Default = 13,
    Min = 5,
    Max = 50,
    Callback = function(v) Features.AimbotSmooth = v / 100 end
})
CombatTab:AddDropdown("AimPart", {
    Title = "Aim Part",
    Values = {"HumanoidRootPart", "Head", "UpperTorso"},
    Default = 1,
    Callback = function(v) Features.AimPart = v end
})
CombatTab:AddToggle("AutoKill", {
    Title = "Auto Kill",
    Default = false,
    Callback = function(v) Features.AutoKill = v end
})
CombatTab:AddToggle("KnifeAura", {
    Title = "Knife Aura",
    Default = false,
    Callback = function(v) Features.KnifeAura = v end
})
CombatTab:AddSlider("AuraRange", {
    Title = "Aura Range",
    Default = 15,
    Min = 6,
    Max = 35,
    Callback = function(v) Features.AuraRange = v end
})
CombatTab:AddDropdown("SelectPlayer", {
    Title = "Select Player",
    Values = PlayerList,
    Default = 1,
    Callback = function(v) Features.SelectedTarget = v end
})
CombatTab:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        PlayerList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(PlayerList, plr.Name)
            end
        end
        Fluent:Notify({ Title = "Players", Content = "Player list refreshed", Duration = 3 })
    end
})
CombatTab:AddToggle("KillSelected", {
    Title = "Kill Selected",
    Default = false,
    Callback = function(v) Features.KillTarget = v end
})

-- CARRY
local CarryTab = Window:AddTab({ Title = "Carry", Icon = "solar/users-group-rounded-bold" })
CarryTab:AddToggle("Piggyback", {
    Title = "Piggyback",
    Default = false,
    Callback = function(v) Features.Piggyback = v end
})
CarryTab:AddToggle("FrontCarry", {
    Title = "Front Carry",
    Default = false,
    Callback = function(v) Features.FrontCarry = v end
})
CarryTab:AddToggle("SideCarry", {
    Title = "Side Carry",
    Default = false,
    Callback = function(v) Features.SideCarry = v end
})

-- TROLL
local TrollTab = Window:AddTab({ Title = "Troll", Icon = "solar/danger-bold" })
TrollTab:AddToggle("FlingNearest", {
    Title = "Fling Nearest",
    Default = false,
    Callback = function(v) Features.FlingNearest = v end
})
TrollTab:AddToggle("FlingSelected", {
    Title = "Fling Selected",
    Default = false,
    Callback = function(v) Features.FlingTarget = v end
})
TrollTab:AddToggle("FlingAll", {
    Title = "Fling All",
    Default = false,
    Callback = function(v) Features.FlingAll = v end
})

-- SELF
local SelfTab = Window:AddTab({ Title = "Self", Icon = "solar/user-bold" })
SelfTab:AddToggle("Invisible", {
    Title = "Invisible",
    Default = false,
    Callback = function(v)
        Features.Invisible = v
        SetInvisible(v)
    end
})
SelfTab:AddToggle("ServerInvis", {
    Title = "Server Invis Bypass (Attempt)",
    Default = false,
    Callback = function(v)
        Features.ServerInvisBypass = v
        if v then ApplyServerInvisBypass() end
    end
})
SelfTab:AddToggle("GlitchSelf", {
    Title = "Glitch Self",
    Default = false,
    Callback = function(v) Features.GlitchSelf = v end
})

-- UTILITY
local UtilityTab = Window:AddTab({ Title = "Utility", Icon = "solar/widget-bold" })
UtilityTab:AddToggle("CoinFarm", {
    Title = "Coin Farm",
    Default = false,
    Callback = function(v) Features.CoinFarm = v end
})
UtilityTab:AddToggle("GrabGun", {
    Title = "Grab Gun",
    Default = false,
    Callback = function(v) Features.GrabGun = v end
})
UtilityTab:AddToggle("TPMurderer", {
    Title = "TP to Murderer",
    Default = false,
    Callback = function(v) Features.TPMurderer = v end
})
UtilityTab:AddToggle("TPSheriff", {
    Title = "TP to Sheriff",
    Default = false,
    Callback = function(v) Features.TPSheriff = v end
})
UtilityTab:AddToggle("RoleNotify", {
    Title = "Role Notify",
    Default = true,
    Callback = function(v) Features.RoleNotify = v end
})

-- TELEPORTS
local TeleportsTab = Window:AddTab({ Title = "Teleports", Icon = "solar/map-point-bold" })
TeleportsTab:AddButton({ Title = "Lobby", Callback = function() Teleport(Vector3.new(0, 10, 0)) end })
TeleportsTab:AddButton({ Title = "Arena", Callback = function() Teleport(Vector3.new(0, 5, 50)) end })
TeleportsTab:AddButton({ Title = "Bank", Callback = function() Teleport(Vector3.new(0, 5, 0)) end })
TeleportsTab:AddButton({ Title = "Hotel", Callback = function() Teleport(Vector3.new(50, 5, 0)) end })
TeleportsTab:AddButton({ Title = "Hospital", Callback = function() Teleport(Vector3.new(-50, 5, 0)) end })

-- BETA
local BetaTab = Window:AddTab({ Title = "Beta", Icon = "solar/star-bold" })
if hasBeta then
    BetaTab:AddParagraph("Status", "You own the Beta gamepass or are Owner.\nExtra experimental features can go here.")
else
    BetaTab:AddParagraph("Status", "Beta locked.\n\nGamepass ID: 1944876349")
    BetaTab:AddButton({
        Title = "Open Gamepass Page",
        Callback = function()
            pcall(function()
                MarketplaceService:PromptGamePassPurchase(LocalPlayer, BETA_GAMEPASS_ID)
            end)
        end
    })
end

-- SETTINGS + THEMES
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "solar/settings-bold" })

SettingsTab:AddButton({
    Title = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})

SettingsTab:AddButton({
    Title = "Server Hop",
    Callback = function()
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
    end
})

-- SaveManager + InterfaceManager (Themes + Config)
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("ZuzifyRBX")
SaveManager:SetFolder("ZuzifyRBX/Config")

InterfaceManager:BuildInterfaceSection(SettingsTab) -- Themes live here
SaveManager:BuildConfigSection(SettingsTab)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

Fluent:Notify({
    Title = "ZuzifyRBX",
    Content = "Fully upgraded version loaded" .. (hasBeta and " | Beta Unlocked" or ""),
    Duration = 5
})

print("ZuzifyRBX Upgraded | Owner:", isOwner, "| Beta:", hasBeta)
