--[[
    ZuzifyRBX - Super Updated (Modal)
    Ranks: Owner / Developer / Beta / User
    Password: password
    Owner: mrcoptai / 717544874
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= RANK SYSTEM =================
local CORRECT_PASSWORD = "password"
local BETA_GAMEPASS_ID = 1944876349

local Owners = {
    [717544874] = true,
    ["mrcoptai"] = true
}

local Developers = {
    -- Add more developer UserIds or names here
    -- [123456789] = true,
}

local function GetRank()
    local name = LocalPlayer.Name:lower()
    local uid = LocalPlayer.UserId

    if Owners[uid] or Owners[name] then
        return "Owner"
    end
    if Developers[uid] or Developers[name] then
        return "Developer"
    end

    local hasBeta = false
    pcall(function()
        hasBeta = MarketplaceService:UserOwnsGamePassAsync(uid, BETA_GAMEPASS_ID)
    end)
    if hasBeta then
        return "Beta"
    end

    return "User"
end

local Rank = GetRank()
local isOwner = Rank == "Owner"
local isDeveloper = Rank == "Developer" or isOwner
local isBeta = Rank == "Beta" or isDeveloper
local passwordPassed = isOwner

-- Password for everyone except Owner
if not isOwner then
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_Pass"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 400, 0, 220)
    frame.Position = UDim2.new(0.5, -200, 0.5, -110)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 220, 180)
    stroke.Thickness = 1.6
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 45)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX"
    title.TextColor3 = Color3.fromRGB(140, 255, 230)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = frame

    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(1, 0, 0, 22)
    rankLabel.Position = UDim2.new(0, 0, 0, 42)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Text = "Rank: " .. Rank
    rankLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
    rankLabel.Font = Enum.Font.Gotham
    rankLabel.TextSize = 14
    rankLabel.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.84, 0, 0, 40)
    box.Position = UDim2.new(0.08, 0, 0.42, 0)
    box.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = "Enter Password..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 9)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.84, 0, 0, 40)
    btn.Position = UDim2.new(0.08, 0, 0.68, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 140)
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

-- ================= LOAD MODAL =================
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

local Window = Modal:CreateWindow({
    Title = "ZuzifyRBX [" .. Rank:upper() .. "]",
    SubTitle = "by Tai (vertexi8) • Super Updated",
    Size = UDim2.fromOffset(600, 500),
    MinimumSize = Vector2.new(340, 300),
    Transparency = 0,
})

-- ================= FEATURES =================
local Features = {
    -- ESP
    ESP = false,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Chams = true,
    ESP_Boxes = false,
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
    AntiDie = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 140, 255),
    Innocent = Color3.fromRGB(50, 230, 90),
}

local ESPObjects = {}
local BodyVel, BodyGyro = nil, nil
local lastFarm, lastKill, lastAnti, lastRole, lastFling, lastGlitch, lastJump = 0, 0, 0, 0, 0, 0, 0
local currentMurderer, currentSheriff = nil, nil
local PlayerList = {}
local originalTransparency = {}

-- ================= ROLE =================
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
    local root = char:FindFirstChild("HumanoidRootPart")
    if not head or not root then return end

    local role = GetRole(plr)
    local color = RoleColors[role] or RoleColors.Innocent
    local objects = {}

    -- Names + Distance
    if Features.ESP_Names or Features.ESP_Distance then
        local bb = Instance.new("BillboardGui")
        bb.Name = "ZRBX_ESP"
        bb.Adornee = head
        bb.Size = UDim2.new(0, 230, 0, 58)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.MaxDistance = 5000
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

    -- Chams
    if Features.ESP_Chams then
        local hl = Instance.new("Highlight")
        hl.Name = "ZRBX_Chams"
        hl.Adornee = char
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.42
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        objects.Highlight = hl
    end

    -- Boxes (simple)
    if Features.ESP_Boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ZRBX_Box"
        box.Adornee = root
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = color
        box.Transparency = 0.6
        box.AlwaysOnTop = true
        box.ZIndex = 5
        box.Parent = root
        objects.Box = box
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
    end
end

local function ApplyNoclip()
    local char = LocalPlayer.Character
    if not char then return end

    local canCollide = true
    if Features.NoclipType == "None" then
        canCollide = true
    elseif Features.NoclipType == "Normal" or Features.NoclipType == "Smooth" or Features.NoclipType == "Full" or Features.NoclipType == "MM2" then
        canCollide = false
    end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = canCollide
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
        BodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVel.Velocity = Vector3.zero
        BodyVel.Parent = root

        BodyGyro = Instance.new("BodyGyro")
        BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.P = 20000
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
        root.Transparency = 0.5
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
    strength = strength or 170
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(math.random(-strength, strength), math.random(90, 150), math.random(-strength, strength))
    bv.Parent = root
    task.delay(0.3, function() if bv then bv:Destroy() end end)
end

local function DoCarry(style)
    if not Features.SelectedTarget then return end
    local target = Players:FindFirstChild(Features.SelectedTarget)
    if not target or not target.Character then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot or not tRoot then return end

    if style == "Piggyback" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 3.1, 0.2)
    elseif style == "Front" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, -3.1)
    elseif style == "Side" then
        myRoot.CFrame = tRoot.CFrame * CFrame.new(2.7, 0.4, 0)
    end
end

-- ================= CHARACTER =================
local function OnCharacter(char)
    task.wait(0.6)
    ApplyStats()
    ApplyNoclip()
    if Features.FlyType ~= "None" then SetupFly() end
    if Features.HitboxExtender then ApplyHitbox() end
    if Features.Invisible then SetInvisible(true) end
    if Features.ServerInvisBypass then ApplyServerInvisBypass() end
    if Features.ESP then task.delay(0.35, RefreshESP) end
end

if LocalPlayer.Character then OnCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(OnCharacter)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.9)
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

    -- Roles
    if tick() - lastRole > 1.0 then
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

    -- ESP Update
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
                if objs.Box then
                    objs.Box.Color3 = color
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
        if dir.Magnitude > 0 then dir = dir.Unit * Features.FlySpeed end
        BodyVel.Velocity = dir
        BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
    end

    -- Infinite Jump (fixed - no random spam)
    if Features.InfiniteJump and hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if tick() - lastJump > 0.18 then
            lastJump = tick()
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end

    -- Anti Fling
    if Features.AntiFling and root and root.AssemblyLinearVelocity.Magnitude > 160 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    -- Anti Die
    if Features.AntiDie and hum and hum.Health < hum.MaxHealth * 0.22 then
        hum.Health = hum.MaxHealth
    end

    if Features.HitboxExtender then ApplyHitbox() end
    if Features.ServerInvisBypass then ApplyServerInvisBypass() end

    -- Aimbot
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
    if Features.AutoKill and tick() - lastKill > 1.25 then
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
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.5)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
            end
        end
    end

    -- Fling
    if Features.FlingNearest and tick() - lastFling > 0.65 then
        lastFling = tick()
        local closest = GetClosestPlayer(55)
        if closest then Fling(closest) end
    end

    if Features.FlingTarget and Features.SelectedTarget and tick() - lastFling > 0.45 then
        lastFling = tick()
        local target = Players:FindFirstChild(Features.SelectedTarget)
        if target then Fling(target) end
    end

    if Features.FlingAll and tick() - lastFling > 0.95 then
        lastFling = tick()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then Fling(plr) end
        end
    end

    -- Glitch
    if Features.GlitchSelf and char and tick() - lastGlitch > 0.07 then
        lastGlitch = tick()
        SetInvisible(true)
        task.delay(0.045, function()
            if Features.GlitchSelf then SetInvisible(Features.Invisible) end
        end)
    end

    -- Coin Farm
    if Features.CoinFarm and root and tick() - lastFarm > 0.8 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "coin") or string.find(n, "money") or string.find(n, "cash") then
                    if (root.Position - obj.Position).Magnitude < 170 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3.4, 0))
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
                if part and (root.Position - part.Position).Magnitude < 240 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.1, 0))
                    break
                end
            end
        end
    end

    -- TP Roles
    if Features.TPMurderer and currentMurderer and currentMurderer.Character and root then
        local tRoot = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4) end
    end
    if Features.TPSheriff and currentSheriff and currentSheriff.Character and root then
        local tRoot = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4) end
    end

    -- Anti AFK
    if Features.AntiAFK and tick() - lastAnti > 20 then
        lastAnti = tick()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.03)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

-- ================= UI =================

-- HOME
local Home = Window:AddTab("Home")

Home:New("Title")({ Title = "Welcome" })
Home:New("Button")({
    Title = "ZuzifyRBX Super Updated",
    Description = "Rank: " .. Rank .. " | All systems online",
    Callback = function() end
})

Home:New("Title")({ Title = "Zuzify News" })
local newsText = "Loading..."
pcall(function()
    newsText = game:HttpGet("https://pastebin.com/raw/F3p7v62u")
end)
Home:New("Button")({
    Title = "Latest News",
    Description = newsText,
    Callback = function()
        local new = "Failed to load"
        pcall(function() new = game:HttpGet("https://pastebin.com/raw/F3p7v62u") end)
        Window:Notify({
            Title = "Zuzify News",
            Description = new,
            Duration = 6,
            Type = "Info"
        })
    end
})

-- VISUALS
local Visuals = Window:AddTab("Visuals")

Visuals:New("Title")({ Title = "ESP" })
Visuals:New("Toggle")({
    Title = "Enable ESP",
    DefaultValue = false,
    Callback = function(v)
        Features.ESP = v
        if v then RefreshESP() else ClearAllESP() end
    end
})
Visuals:New("Toggle")({
    Title = "Names + Role",
    DefaultValue = true,
    Callback = function(v) Features.ESP_Names = v RefreshESP() end
})
Visuals:New("Toggle")({
    Title = "Distance",
    DefaultValue = true,
    Callback = function(v) Features.ESP_Distance = v end
})
Visuals:New("Toggle")({
    Title = "Chams",
    DefaultValue = true,
    Callback = function(v) Features.ESP_Chams = v RefreshESP() end
})
Visuals:New("Toggle")({
    Title = "Boxes",
    DefaultValue = false,
    Callback = function(v) Features.ESP_Boxes = v RefreshESP() end
})
Visuals:New("Button")({
    Title = "Refresh ESP",
    Callback = RefreshESP
})
Visuals:New("Button")({
    Title = "Clear ESP",
    Callback = function()
        ClearAllESP()
        Features.ESP = false
    end
})

-- MOVEMENT
local Movement = Window:AddTab("Movement")

Movement:New("Title")({ Title = "Movement" })
Movement:New("Dropdown")({
    Title = "Noclip Type",
    Options = {"None", "Normal", "Smooth", "Full", "MM2"},
    Default = "None",
    Callback = function(v)
        Features.NoclipType = v
        ApplyNoclip()
    end
})
Movement:New("Dropdown")({
    Title = "Fly Type",
    Options = {"None", "BodyVelocity", "Smooth"},
    Default = "None",
    Callback = function(v)
        Features.FlyType = v
        if v == "None" then CleanupFly() else SetupFly() end
    end
})
Movement:New("Slider")({
    Title = "Fly Speed",
    Default = 60,
    Minimum = 10,
    Maximum = 300,
    Callback = function(v) Features.FlySpeed = v end
})
Movement:New("Toggle")({
    Title = "Infinite Jump (Fixed)",
    DefaultValue = false,
    Callback = function(v) Features.InfiniteJump = v end
})
Movement:New("Slider")({
    Title = "Walk Speed",
    Default = 16,
    Minimum = 10,
    Maximum = 300,
    Callback = function(v)
        Features.WalkSpeed = v
        ApplyStats()
    end
})
Movement:New("Slider")({
    Title = "Jump Power",
    Default = 50,
    Minimum = 30,
    Maximum = 300,
    Callback = function(v)
        Features.JumpPower = v
        ApplyStats()
    end
})
Movement:New("Toggle")({
    Title = "Anti Fling",
    DefaultValue = true,
    Callback = function(v) Features.AntiFling = v end
})
Movement:New("Toggle")({
    Title = "Anti Die",
    DefaultValue = false,
    Callback = function(v) Features.AntiDie = v end
})
Movement:New("Toggle")({
    Title = "Hitbox Extender",
    DefaultValue = false,
    Callback = function(v)
        Features.HitboxExtender = v
        ApplyHitbox()
    end
})
Movement:New("Slider")({
    Title = "Hitbox Size",
    Default = 9,
    Minimum = 3,
    Maximum = 30,
    Callback = function(v)
        Features.HitboxSize = v
        if Features.HitboxExtender then ApplyHitbox() end
    end
})
Movement:New("Toggle")({
    Title = "Anti AFK",
    DefaultValue = true,
    Callback = function(v) Features.AntiAFK = v end
})

-- COMBAT
local Combat = Window:AddTab("Combat")

Combat:New("Title")({ Title = "Aimbot & Aura" })
Combat:New("Toggle")({
    Title = "Aimbot",
    DefaultValue = false,
    Callback = function(v) Features.Aimbot = v end
})
Combat:New("Toggle")({
    Title = "Silent Aim",
    DefaultValue = false,
    Callback = function(v) Features.SilentAim = v end
})
Combat:New("Slider")({
    Title = "FOV",
    Default = 230,
    Minimum = 50,
    Maximum = 500,
    Callback = function(v) Features.AimbotFOV = v end
})
Combat:New("Slider")({
    Title = "Smoothness",
    Default = 13,
    Minimum = 5,
    Maximum = 50,
    Callback = function(v) Features.AimbotSmooth = v / 100 end
})
Combat:New("Dropdown")({
    Title = "Aim Part",
    Options = {"HumanoidRootPart", "Head", "UpperTorso"},
    Default = "HumanoidRootPart",
    Callback = function(v) Features.AimPart = v end
})
Combat:New("Toggle")({
    Title = "Auto Kill",
    DefaultValue = false,
    Callback = function(v) Features.AutoKill = v end
})
Combat:New("Toggle")({
    Title = "Knife Aura",
    DefaultValue = false,
    Callback = function(v) Features.KnifeAura = v end
})
Combat:New("Slider")({
    Title = "Aura Range",
    Default = 15,
    Minimum = 6,
    Maximum = 40,
    Callback = function(v) Features.AuraRange = v end
})

Combat:New("Title")({ Title = "Target" })
Combat:New("Dropdown")({
    Title = "Select Player",
    Options = PlayerList,
    Default = PlayerList[1] or "None",
    Callback = function(v) Features.SelectedTarget = v end
})
Combat:New("Button")({
    Title = "Refresh Players",
    Callback = function()
        PlayerList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                table.insert(PlayerList, plr.Name)
            end
        end
        Window:Notify({
            Title = "Players",
            Description = "List refreshed",
            Duration = 3,
            Type = "Success"
        })
    end
})
Combat:New("Toggle")({
    Title = "Kill Selected",
    DefaultValue = false,
    Callback = function(v) Features.KillTarget = v end
})

-- CARRY
local Carry = Window:AddTab("Carry")
Carry:New("Title")({ Title = "Carry Styles" })
Carry:New("Toggle")({
    Title = "Piggyback",
    DefaultValue = false,
    Callback = function(v) Features.Piggyback = v end
})
Carry:New("Toggle")({
    Title = "Front Carry",
    DefaultValue = false,
    Callback = function(v) Features.FrontCarry = v end
})
Carry:New("Toggle")({
    Title = "Side Carry",
    DefaultValue = false,
    Callback = function(v) Features.SideCarry = v end
})

-- TROLL
local Troll = Window:AddTab("Troll")
Troll:New("Title")({ Title = "Fling" })
Troll:New("Toggle")({
    Title = "Fling Nearest",
    DefaultValue = false,
    Callback = function(v) Features.FlingNearest = v end
})
Troll:New("Toggle")({
    Title = "Fling Selected",
    DefaultValue = false,
    Callback = function(v) Features.FlingTarget = v end
})
Troll:New("Toggle")({
    Title = "Fling All",
    DefaultValue = false,
    Callback = function(v) Features.FlingAll = v end
})

-- SELF
local Self = Window:AddTab("Self")
Self:New("Title")({ Title = "Self" })
Self:New("Toggle")({
    Title = "Invisible",
    DefaultValue = false,
    Callback = function(v)
        Features.Invisible = v
        SetInvisible(v)
    end
})
Self:New("Toggle")({
    Title = "Server Invis Bypass",
    DefaultValue = false,
    Callback = function(v)
        Features.ServerInvisBypass = v
        if v then ApplyServerInvisBypass() end
    end
})
Self:New("Toggle")({
    Title = "Glitch Self",
    DefaultValue = false,
    Callback = function(v) Features.GlitchSelf = v end
})

-- UTILITY
local Utility = Window:AddTab("Utility")
Utility:New("Title")({ Title = "Utility" })
Utility:New("Toggle")({
    Title = "Coin Farm",
    DefaultValue = false,
    Callback = function(v) Features.CoinFarm = v end
})
Utility:New("Toggle")({
    Title = "Grab Gun",
    DefaultValue = false,
    Callback = function(v) Features.GrabGun = v end
})
Utility:New("Toggle")({
    Title = "TP to Murderer",
    DefaultValue = false,
    Callback = function(v) Features.TPMurderer = v end
})
Utility:New("Toggle")({
    Title = "TP to Sheriff",
    DefaultValue = false,
    Callback = function(v) Features.TPSheriff = v end
})

-- TELEPORTS
local Teleports = Window:AddTab("Teleports")
Teleports:New("Title")({ Title = "Quick TPs" })
Teleports:New("Button")({
    Title = "Lobby",
    Callback = function() Teleport(Vector3.new(0, 10, 0)) end
})
Teleports:New("Button")({
    Title = "Arena",
    Callback = function() Teleport(Vector3.new(0, 5, 50)) end
})
Teleports:New("Button")({
    Title = "Bank",
    Callback = function() Teleport(Vector3.new(0, 5, 0)) end
})
Teleports:New("Button")({
    Title = "Hotel",
    Callback = function() Teleport(Vector3.new(50, 5, 0)) end
})
Teleports:New("Button")({
    Title = "Hospital",
    Callback = function() Teleport(Vector3.new(-50, 5, 0)) end
})

-- SETTINGS
local Settings = Window:AddTab("Settings")
Settings:New("Title")({ Title = "Server" })
Settings:New("Button")({
    Title = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end
})
Settings:New("Button")({
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

Window:Notify({
    Title = "ZuzifyRBX",
    Description = "Super Updated loaded | Rank: " .. Rank,
    Duration = 5,
    Type = "Success"
})

print("ZuzifyRBX Super Updated | Rank:", Rank)
