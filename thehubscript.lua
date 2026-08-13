--[[
    ZuzifyRBX - Full Combined Build
    MM2 + Cheese Escape
]]

--------------------------- CONFIG ---------------------------
local CORRECT_PASSWORD = "tai"
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1467436721951084792/KYX4LUdBw4K2i2Bpwc4UZRSF1JRNJ0Banw1KK1xrQzjPHXMh0DLIQ0Rs8giXVISjqwt0"
local NEWS_PASTEBIN = "https://pastebin.com/raw/sWSkNRcu"

local Ranks = {
    {Rank = "Owner", UserId = 717544874, Username = "mrcoptai", Perms = 10, NeedsPassword = false},
    {Rank = "Developer", UserId = 0, Username = "ChangeThis", Perms = 8, NeedsPassword = true},
    {Rank = "Beta", UserId = 0, Username = "ChangeThis", Perms = 5, NeedsPassword = true},
    {Rank = "Femboy", UserId = 0, Username = "ChangeThis", Perms = 4, NeedsPassword = true},
    {Rank = "Hailey", UserId = 0, Username = "ChangeThis", Perms = 7, NeedsPassword = true},
    {Rank = "User", UserId = 0, Username = "EveryoneElse", Perms = 1, NeedsPassword = true},
}

local Blacklist = {}
--------------------------- END CONFIG ---------------------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Rank
local CurrentRank, CurrentPerms, NeedsPassword = "User", 1, true

local function IsBlacklisted()
    local name = LocalPlayer.Name:lower()
    local uid = LocalPlayer.UserId
    for _, v in ipairs(Blacklist) do
        if (type(v) == "number" and v == uid) or (type(v) == "string" and v:lower() == name) then return true end
    end
    return false
end

if IsBlacklisted() then
    pcall(function() LocalPlayer:Kick("Blacklisted") end)
    return
end

local function GetPlayerRank()
    local name = LocalPlayer.Name:lower()
    local uid = LocalPlayer.UserId
    for _, data in ipairs(Ranks) do
        if (data.UserId ~= 0 and data.UserId == uid) or (data.Username and data.Username:lower() == name) then
            return data.Rank, data.Perms, data.NeedsPassword
        end
    end
    return "User", 1, true
end

CurrentRank, CurrentPerms, NeedsPassword = GetPlayerRank()

-- Password
local passwordPassed = not NeedsPassword
if NeedsPassword then
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_Pass"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 250)
    frame.Position = UDim2.new(0.5, -210, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 210, 170)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 42)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX"
    title.TextColor3 = Color3.fromRGB(0, 230, 190)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = frame

    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(1, 0, 0, 22)
    rankLabel.Position = UDim2.new(0, 0, 0, 40)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Text = "Rank: " .. CurrentRank .. "  |  Perms: " .. CurrentPerms
    rankLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    rankLabel.Font = Enum.Font.Gotham
    rankLabel.TextSize = 14
    rankLabel.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.84, 0, 0, 42)
    box.Position = UDim2.new(0.08, 0, 0.42, 0)
    box.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderText = "Enter Password..."
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.84, 0, 0, 42)
    btn.Position = UDim2.new(0.08, 0, 0.70, 0)
    btn.BackgroundColor3 = Color3.fromRGB(0, 160, 130)
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

-- Load Modal
local success, Modal = pcall(function()
    return loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()
end)
if not success or not Modal then return end

local Window = Modal:CreateWindow({
    Title = "ZuzifyRBX [" .. CurrentRank:upper() .. "]",
    SubTitle = "MM2 + Cheese Escape",
    Size = UDim2.fromOffset(640, 540),
    MinimumSize = Vector2.new(360, 320),
    Transparency = 0,
})

-- Features
local Features = {
    -- Visuals
    ESP = false, ESP_Names = true, ESP_Distance = true, ESP_Chams = true, ESP_Boxes = false,

    -- Movement
    NoclipType = "None", FlyType = "None", FlySpeed = 60, InfiniteJump = false,
    WalkSpeed = 16, JumpPower = 50, SpeedBoost = false, SuperJump = false,
    AntiAFK = true, AntiFling = true, HitboxExtender = false, HitboxSize = 9, AntiDie = false,

    -- Combat
    Aimbot = false, SilentAim = false, AimbotFOV = 230, AimbotSmooth = 0.13, AimbotPrediction = 0.14,
    AimPart = "HumanoidRootPart", AutoKill = false, KnifeAura = false, AuraRange = 15,
    SelectedTarget = nil, KillTarget = false,

    -- Carry
    Piggyback = false, FrontCarry = false, SideCarry = false,

    -- Troll
    FlingType = "Normal", FlingNearest = false, FlingTarget = false, FlingAll = false,

    -- Self
    Invisible = false, ServerInvisBypass = false, GlitchSelf = false,

    -- Utility
    CoinFarm = false, GrabGun = false, TPMurderer = false, TPSheriff = false,

    -- Cheese Escape
    ShowCodes = false, ShowKeys = false, ShowCheese = false,
    RatESP = false, AutoCheese = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 55, 55),
    Sheriff = Color3.fromRGB(55, 145, 255),
    Innocent = Color3.fromRGB(55, 230, 100),
}

local ESPObjects = {}
local ObjectESP = {}
local RatESPObject = nil
local BodyVel, BodyGyro = nil, nil
local lastFarm, lastKill, lastAnti, lastRole, lastFling, lastGlitch, lastJump, lastScan = 0, 0, 0, 0, 0, 0, 0, 0
local currentMurderer, currentSheriff, currentRat = nil, nil, nil
local PlayerList = {}
local originalTransparency = {}

-- ================= HELPERS =================
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local function check(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = string.lower(tool.Name)
        if n:find("knife") or n:find("dagger") or n:find("blade") or n:find("sword") then return "Murderer" end
        if n:find("gun") or n:find("revolver") or n:find("pistol") then return "Sheriff" end
        return nil
    end
    local success, role = pcall(function()
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        local r = check(tool)
        if r then return r end
        local bp = plr:FindFirstChild("Backpack")
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                r = check(item)
                if r then return r end
            end
        end
        return "Innocent"
    end)
    return success and role or "Innocent"
end

local function ClearESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            pcall(function() if obj and obj.Parent then obj:Destroy() end end)
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

    if Features.ESP_Names or Features.ESP_Distance then
        local bb = Instance.new("BillboardGui")
        bb.Adornee = head
        bb.Size = UDim2.new(0, 220, 0, 55)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
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
        hl.Adornee = char
        hl.FillColor = color
        hl.OutlineColor = color
        hl.FillTransparency = 0.42
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char
        objects.Highlight = hl
    end

    if Features.ESP_Boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = root
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = color
        box.Transparency = 0.55
        box.AlwaysOnTop = true
        box.Parent = root
        objects.Box = box
    end

    ESPObjects[plr] = objects
end

local function RefreshESP()
    ClearAllESP()
    if not Features.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then pcall(CreateESP, plr) end
    end
end

-- Cheese Escape Object ESP
local function ClearObjectESP()
    for _, data in pairs(ObjectESP) do
        pcall(function()
            if data.Highlight then data.Highlight:Destroy() end
            if data.Billboard then data.Billboard:Destroy() end
        end)
    end
    table.clear(ObjectESP)
end

local function CreateObjectESP(part, text, color)
    if not part or ObjectESP[part] then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = part
    hl.FillColor = color
    hl.OutlineColor = color
    hl.FillTransparency = 0.4
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = part

    local bb = Instance.new("BillboardGui")
    bb.Adornee = part
    bb.Size = UDim2.new(0, 150, 0, 34)
    bb.StudsOffset = Vector3.new(0, 2.6, 0)
    bb.AlwaysOnTop = true
    bb.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.Parent = bb

    ObjectESP[part] = {Highlight = hl, Billboard = bb}
end

local function ScanObjects()
    ClearObjectESP()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local name = string.lower(obj.Name)
            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
            if not part then continue end

            if Features.ShowCodes and (name:find("code") or name:find("keypad") or name:find("pad")) then
                CreateObjectESP(part, "CODE", Color3.fromRGB(255, 200, 40))
            end
            if Features.ShowKeys and (name:find("key") or name:find("keycard") or name:find("card")) then
                CreateObjectESP(part, "KEY", Color3.fromRGB(80, 170, 255))
            end
            if Features.ShowCheese and (name:find("cheese") or name:find("cheddar") or name:find("swiss")) then
                CreateObjectESP(part, "CHEESE", Color3.fromRGB(255, 220, 50))
            end
        end
    end
end

local function FindRat()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            if plr.Name:lower():find("rat") then return plr end
            for _, v in ipairs(plr.Character:GetDescendants()) do
                local n = v.Name:lower()
                if n:find("rat") or n:find("tail") then return plr end
            end
        end
    end
    return nil
end

local function ClearRatESP()
    if RatESPObject then
        pcall(function()
            if RatESPObject.Highlight then RatESPObject.Highlight:Destroy() end
            if RatESPObject.Billboard then RatESPObject.Billboard:Destroy() end
        end)
        RatESPObject = nil
    end
end

local function CreateRatESP(plr)
    ClearRatESP()
    if not plr or not plr.Character then return end
    local head = plr.Character:FindFirstChild("Head")
    if not head then return end

    local hl = Instance.new("Highlight")
    hl.Adornee = plr.Character
    hl.FillColor = Color3.fromRGB(255, 70, 70)
    hl.OutlineColor = Color3.fromRGB(255, 30, 30)
    hl.FillTransparency = 0.35
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = plr.Character

    local bb = Instance.new("BillboardGui")
    bb.Adornee = head
    bb.Size = UDim2.new(0, 180, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3.3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "RAT - " .. plr.Name
    label.TextColor3 = Color3.fromRGB(255, 80, 80)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.Parent = bb

    RatESPObject = {Highlight = hl, Billboard = bb, Label = label}
end

local function ApplyStats()
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Features.SpeedBoost and 42 or Features.WalkSpeed
            hum.JumpPower = Features.SuperJump and 120 or Features.JumpPower
        end
    end)
end

local function ApplyNoclip()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local canCollide = Features.NoclipType == "None"
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = canCollide end
        end
    end)
end

local function SetupFly()
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if BodyVel then BodyVel:Destroy() end
        if BodyGyro then BodyGyro:Destroy() end
        if Features.FlyType ~= "None" then
            BodyVel = Instance.new("BodyVelocity")
            BodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BodyVel.Parent = root
            BodyGyro = Instance.new("BodyGyro")
            BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyGyro.P = 20000
            BodyGyro.Parent = root
        end
    end)
end

local function CleanupFly()
    pcall(function()
        if BodyVel then BodyVel:Destroy() BodyVel = nil end
        if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
    end)
end

local function ApplyHitbox()
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if Features.HitboxExtender then
            root.Size = Vector3.new(Features.HitboxSize, Features.HitboxSize, Features.HitboxSize)
            root.Transparency = 0.5
            root.CanCollide = false
        else
            root.Size = Vector3.new(2, 2, 1)
            root.Transparency = 1
        end
    end)
end

local function SetInvisible(state)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("Decal") then
                if state then
                    if not originalTransparency[part] then originalTransparency[part] = part.Transparency end
                    part.Transparency = 1
                    if part:IsA("BasePart") then pcall(function() part.LocalTransparencyModifier = 1 end) end
                else
                    if originalTransparency[part] then part.Transparency = originalTransparency[part] end
                    if part:IsA("BasePart") then pcall(function() part.LocalTransparencyModifier = 0 end) end
                end
            end
        end
        if not state then table.clear(originalTransparency) end
    end)
end

local function Teleport(pos)
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(pos) end
    end)
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
                if dist < closestDist then closestDist = dist closest = plr end
            end
        end
    end
    return closest
end

local function Fling(plr)
    pcall(function()
        if not plr or not plr.Character then return end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root
        if Features.FlingType == "Strong" then
            bv.Velocity = Vector3.new(math.random(-250, 250), math.random(150, 250), math.random(-250, 250))
        elseif Features.FlingType == "Up" then
            bv.Velocity = Vector3.new(0, math.random(300, 450), 0)
        elseif Features.FlingType == "Spin" then
            bv.Velocity = Vector3.new(math.random(-180, 180), 110, math.random(-180, 180))
        else
            bv.Velocity = Vector3.new(math.random(-140, 140), math.random(90, 150), math.random(-140, 140))
        end
        task.delay(0.35, function() if bv then bv:Destroy() end end)
    end)
end

local function DoCarry(style)
    pcall(function()
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
    end)
end

-- Character
local function OnCharacter()
    task.wait(0.5)
    ApplyStats()
    ApplyNoclip()
    if Features.FlyType ~= "None" then SetupFly() end
    if Features.HitboxExtender then ApplyHitbox() end
    if Features.Invisible then SetInvisible(true) end
    if Features.ESP then task.delay(0.4, RefreshESP) end
end

if LocalPlayer.Character then OnCharacter() end
LocalPlayer.CharacterAdded:Connect(OnCharacter)

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.7)
        if Features.ESP then pcall(CreateESP, plr) end
        if not table.find(PlayerList, plr.Name) then table.insert(PlayerList, plr.Name) end
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

-- Main Loop
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if tick() - lastRole > 1 then
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

    -- Cheese objects
    if (Features.ShowCodes or Features.ShowKeys or Features.ShowCheese) and tick() - lastScan > 3 then
        lastScan = tick()
        ScanObjects()
    end

    -- Rat
    if Features.RatESP and tick() - lastScan > 1.5 then
        currentRat = FindRat()
        if currentRat then CreateRatESP(currentRat) else ClearRatESP() end
    end

    if Features.RatESP and RatESPObject and RatESPObject.Label and currentRat and currentRat.Character and root then
        local rRoot = currentRat.Character:FindFirstChild("HumanoidRootPart")
        if rRoot then
            local dist = math.floor((root.Position - rRoot.Position).Magnitude)
            RatESPObject.Label.Text = "RAT - " .. currentRat.Name .. " [" .. dist .. "]"
        end
    end

    -- Normal ESP
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
                if objs.Box then objs.Box.Color3 = color end
            else
                ClearESP(plr)
            end
        end
    end

    if Features.NoclipType ~= "None" then ApplyNoclip() end

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

    if Features.InfiniteJump and hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        if tick() - lastJump > 0.2 then
            lastJump = tick()
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
        end
    end

    if Features.AntiFling and root and root.AssemblyLinearVelocity.Magnitude > 160 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end

    if Features.AntiDie and hum and hum.Health < hum.MaxHealth * 0.22 then
        hum.Health = hum.MaxHealth
    end

    if Features.HitboxExtender then ApplyHitbox() end

    if (Features.Aimbot or Features.SilentAim) and root then
        local target = GetClosestPlayer(Features.AimbotFOV)
        if target and target.Character then
            local part = target.Character:FindFirstChild(Features.AimPart) or target.Character:FindFirstChild("HumanoidRootPart")
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

    if Features.Piggyback then DoCarry("Piggyback") end
    if Features.FrontCarry then DoCarry("Front") end
    if Features.SideCarry then DoCarry("Side") end

    if Features.KnifeAura and root then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (root.Position - tRoot.Position).Magnitude < Features.AuraRange then
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
        end
    end

    if Features.AutoKill and tick() - lastKill > 1.2 then
        lastKill = tick()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end

    if Features.KillTarget and Features.SelectedTarget and root then
        local target = Players:FindFirstChild(Features.SelectedTarget)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.5)
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end
    end

    if Features.FlingNearest and tick() - lastFling > 0.55 then
        lastFling = tick()
        local closest = GetClosestPlayer(55)
        if closest then Fling(closest) end
    end

    if Features.FlingTarget and Features.SelectedTarget and tick() - lastFling > 0.4 then
        lastFling = tick()
        local target = Players:FindFirstChild(Features.SelectedTarget)
        if target then Fling(target) end
    end

    if Features.FlingAll and tick() - lastFling > 0.85 then
        lastFling = tick()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then Fling(plr) end
        end
    end

    if Features.GlitchSelf and char and tick() - lastGlitch > 0.07 then
        lastGlitch = tick()
        SetInvisible(true)
        task.delay(0.04, function() if Features.GlitchSelf then SetInvisible(Features.Invisible) end end)
    end

    if (Features.CoinFarm or Features.AutoCheese) and root and tick() - lastFarm > 0.7 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if n:find("cheese") or n:find("coin") or n:find("money") then
                    if (root.Position - obj.Position).Magnitude < 180 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3.5, 0))
                        break
                    end
                end
            end
        end
    end

    if Features.TPMurderer and currentMurderer and currentMurderer.Character and root then
        local tRoot = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4) end
    end
    if Features.TPSheriff and currentSheriff and currentSheriff.Character and root then
        local tRoot = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4) end
    end

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
local Home = Window:AddTab("Home")
Home:New("Title")({ Title = "Welcome" })
Home:New("Button")({
    Title = "ZuzifyRBX Full Build",
    Description = "Rank: " .. CurrentRank .. " | MM2 + Cheese Escape",
    Callback = function() end
})
Home:New("Button")({
    Title = "Unlock Beta",
    Description = "Send request",
    Callback = function()
        pcall(function()
            local req = http_request or request or (syn and syn.request)
            if req then
                req({
                    Url = DISCORD_WEBHOOK,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        content = "**Beta Request**\nUser: `" .. LocalPlayer.Name .. "`\nID: `" .. LocalPlayer.UserId .. "`"
                    })
                })
                Window:Notify({Title = "Beta", Description = "Sent", Duration = 3, Type = "Success"})
            end
        end)
    end
})

-- CHEESE ESCAPE PAGE
local Cheese = Window:AddTab("Cheese Escape")
Cheese:New("Title")({ Title = "Object ESP" })
Cheese:New("Toggle")({ Title = "Show Codes", DefaultValue = false, Callback = function(v) Features.ShowCodes = v ScanObjects() end })
Cheese:New("Toggle")({ Title = "Show Keys", DefaultValue = false, Callback = function(v) Features.ShowKeys = v ScanObjects() end })
Cheese:New("Toggle")({ Title = "Show Cheese", DefaultValue = false, Callback = function(v) Features.ShowCheese = v ScanObjects() end })
Cheese:New("Button")({ Title = "Refresh Objects", Callback = function() ScanObjects() Window:Notify({Title = "Scanned", Description = "Updated", Duration = 2, Type = "Success"}) end })

Cheese:New("Title")({ Title = "Rat" })
Cheese:New("Toggle")({ Title = "Rat ESP", DefaultValue = false, Callback = function(v) Features.RatESP = v if v then currentRat = FindRat() if currentRat then CreateRatESP(currentRat) end else ClearRatESP() end end })
Cheese:New("Button")({ Title = "Teleport to Rat", Callback = function()
    if currentRat and currentRat.Character and currentRat.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = currentRat.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5) end
    else
        Window:Notify({Title = "Rat", Description = "Not found", Duration = 3, Type = "Error"})
    end
end })

Cheese:New("Title")({ Title = "Farm" })
Cheese:New("Toggle")({ Title = "Auto Cheese Farm", DefaultValue = false, Callback = function(v) Features.AutoCheese = v end })
Cheese:New("Toggle")({ Title = "Speed Boost", DefaultValue = false, Callback = function(v) Features.SpeedBoost = v ApplyStats() end })
Cheese:New("Toggle")({ Title = "Super Jump", DefaultValue = false, Callback = function(v) Features.SuperJump = v ApplyStats() end })

-- VISUALS
local Visuals = Window:AddTab("Visuals")
Visuals:New("Title")({ Title = "ESP" })
Visuals:New("Toggle")({ Title = "Enable ESP", DefaultValue = false, Callback = function(v) Features.ESP = v if v then RefreshESP() else ClearAllESP() end end })
Visuals:New("Toggle")({ Title = "Names + Role", DefaultValue = true, Callback = function(v) Features.ESP_Names = v RefreshESP() end })
Visuals:New("Toggle")({ Title = "Distance", DefaultValue = true, Callback = function(v) Features.ESP_Distance = v end })
Visuals:New("Toggle")({ Title = "Chams", DefaultValue = true, Callback = function(v) Features.ESP_Chams = v RefreshESP() end })
Visuals:New("Toggle")({ Title = "Boxes", DefaultValue = false, Callback = function(v) Features.ESP_Boxes = v RefreshESP() end })
Visuals:New("Button")({ Title = "Refresh ESP", Callback = RefreshESP })
Visuals:New("Button")({ Title = "Clear ESP", Callback = function() ClearAllESP() Features.ESP = false end })

-- MOVEMENT
local Movement = Window:AddTab("Movement")
Movement:New("Title")({ Title = "Movement" })
Movement:New("Dropdown")({ Title = "Noclip", Options = {"None", "Normal", "Full"}, Default = "None", Callback = function(v) Features.NoclipType = v ApplyNoclip() end })
Movement:New("Dropdown")({ Title = "Fly", Options = {"None", "BodyVelocity"}, Default = "None", Callback = function(v) Features.FlyType = v if v == "None" then CleanupFly() else SetupFly() end end })
Movement:New("Slider")({ Title = "Fly Speed", Default = 60, Minimum = 10, Maximum = 250, Callback = function(v) Features.FlySpeed = v end })
Movement:New("Toggle")({ Title = "Infinite Jump", DefaultValue = false, Callback = function(v) Features.InfiniteJump = v end })
Movement:New("Slider")({ Title = "Walk Speed", Default = 16, Minimum = 10, Maximum = 150, Callback = function(v) Features.WalkSpeed = v ApplyStats() end })
Movement:New("Slider")({ Title = "Jump Power", Default = 50, Minimum = 30, Maximum = 200, Callback = function(v) Features.JumpPower = v ApplyStats() end })
Movement:New("Toggle")({ Title = "Anti Fling", DefaultValue = true, Callback = function(v) Features.AntiFling = v end })
Movement:New("Toggle")({ Title = "Anti Die", DefaultValue = false, Callback = function(v) Features.AntiDie = v end })
Movement:New("Toggle")({ Title = "Hitbox Extender", DefaultValue = false, Callback = function(v) Features.HitboxExtender = v ApplyHitbox() end })
Movement:New("Toggle")({ Title = "Anti AFK", DefaultValue = true, Callback = function(v) Features.AntiAFK = v end })

-- COMBAT
local Combat = Window:AddTab("Combat")
Combat:New("Title")({ Title = "Combat" })
Combat:New("Toggle")({ Title = "Aimbot", DefaultValue = false, Callback = function(v) Features.Aimbot = v end })
Combat:New("Toggle")({ Title = "Silent Aim", DefaultValue = false, Callback = function(v) Features.SilentAim = v end })
Combat:New("Slider")({ Title = "FOV", Default = 230, Minimum = 50, Maximum = 500, Callback = function(v) Features.AimbotFOV = v end })
Combat:New("Toggle")({ Title = "Auto Kill", DefaultValue = false, Callback = function(v) Features.AutoKill = v end })
Combat:New("Toggle")({ Title = "Knife Aura", DefaultValue = false, Callback = function(v) Features.KnifeAura = v end })
Combat:New("Slider")({ Title = "Aura Range", Default = 15, Minimum = 6, Maximum = 40, Callback = function(v) Features.AuraRange = v end })
Combat:New("Title")({ Title = "Target" })
Combat:New("Dropdown")({ Title = "Select Player", Options = PlayerList, Default = PlayerList[1] or "None", Callback = function(v) Features.SelectedTarget = v end })
Combat:New("Button")({ Title = "Refresh Players", Callback = function()
    PlayerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then table.insert(PlayerList, plr.Name) end
    end
    Window:Notify({Title = "Players", Description = "Refreshed", Duration = 2, Type = "Success"})
end })
Combat:New("Toggle")({ Title = "Kill Selected", DefaultValue = false, Callback = function(v) Features.KillTarget = v end })

-- CARRY
local Carry = Window:AddTab("Carry")
Carry:New("Title")({ Title = "Carry" })
Carry:New("Toggle")({ Title = "Piggyback", DefaultValue = false, Callback = function(v) Features.Piggyback = v end })
Carry:New("Toggle")({ Title = "Front Carry", DefaultValue = false, Callback = function(v) Features.FrontCarry = v end })
Carry:New("Toggle")({ Title = "Side Carry", DefaultValue = false, Callback = function(v) Features.SideCarry = v end })

-- TROLL
local Troll = Window:AddTab("Troll")
Troll:New("Title")({ Title = "Fling" })
Troll:New("Dropdown")({ Title = "Fling Type", Options = {"Normal", "Strong", "Up", "Spin"}, Default = "Normal", Callback = function(v) Features.FlingType = v end })
Troll:New("Toggle")({ Title = "Fling Nearest", DefaultValue = false, Callback = function(v) Features.FlingNearest = v end })
Troll:New("Toggle")({ Title = "Fling Selected", DefaultValue = false, Callback = function(v) Features.FlingTarget = v end })
Troll:New("Toggle")({ Title = "Fling All", DefaultValue = false, Callback = function(v) Features.FlingAll = v end })

-- SELF
local Self = Window:AddTab("Self")
Self:New("Title")({ Title = "Self" })
Self:New("Toggle")({ Title = "Invisible", DefaultValue = false, Callback = function(v) Features.Invisible = v SetInvisible(v) end })
Self:New("Toggle")({ Title = "Glitch Self", DefaultValue = false, Callback = function(v) Features.GlitchSelf = v end })

-- UTILITY
local Utility = Window:AddTab("Utility")
Utility:New("Title")({ Title = "Utility" })
Utility:New("Toggle")({ Title = "Coin Farm", DefaultValue = false, Callback = function(v) Features.CoinFarm = v end })
Utility:New("Toggle")({ Title = "TP to Murderer", DefaultValue = false, Callback = function(v) Features.TPMurderer = v end })
Utility:New("Toggle")({ Title = "TP to Sheriff", DefaultValue = false, Callback = function(v) Features.TPSheriff = v end })

-- SETTINGS
local Settings = Window:AddTab("Settings")
Settings:New("Title")({ Title = "Server" })
Settings:New("Button")({ Title = "Rejoin", Callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
Settings:New("Button")({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            local list = {}
            for _, s in ipairs(data.data or {}) do
                if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(list, s.id) end
            end
            if #list > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1, #list)], LocalPlayer)
            end
        end)
    end
})

Window:Notify({
    Title = "ZuzifyRBX",
    Description = "Full Build loaded | Rank: " .. CurrentRank,
    Duration = 5,
    Type = "Success"
})

print("ZuzifyRBX Full Combined Build | Rank:", CurrentRank)
