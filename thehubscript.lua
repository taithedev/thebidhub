--[[
    ZuzifyRBX - Rayfield Gen2 Build
    Themes work via window:ChangeTheme
    Docs: https://docs.sirius.menu/rayfield-gen2
]]

--------------------------- CONFIG ---------------------------
local CORRECT_PASSWORD = "sofia"
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
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local CurrentRank, CurrentPerms, NeedsPassword = "User", 1, true

local function IsBlacklisted()
    local name, uid = LocalPlayer.Name:lower(), LocalPlayer.UserId
    for _, v in ipairs(Blacklist) do
        if (type(v) == "number" and v == uid) or (type(v) == "string" and v:lower() == name) then
            return true
        end
    end
    return false
end

if IsBlacklisted() then
    pcall(function() LocalPlayer:Kick("Blacklisted") end)
    return
end

local function GetPlayerRank()
    local name, uid = LocalPlayer.Name:lower(), LocalPlayer.UserId
    for _, data in ipairs(Ranks) do
        if (data.UserId ~= 0 and data.UserId == uid) or (data.Username and data.Username:lower() == name) then
            return data.Rank, data.Perms, data.NeedsPassword
        end
    end
    return "User", 1, true
end

CurrentRank, CurrentPerms, NeedsPassword = GetPlayerRank()

-- Password gate
local passwordPassed = not NeedsPassword
if NeedsPassword then
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_Pass"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 250)
    frame.Position = UDim2.new(0.5, -210, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(5, 5, 7)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 180, 150)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 42)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX"
    title.TextColor3 = Color3.fromRGB(0, 220, 180)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 24
    title.Parent = frame

    local rankLabel = Instance.new("TextLabel")
    rankLabel.Size = UDim2.new(1, 0, 0, 22)
    rankLabel.Position = UDim2.new(0, 0, 0, 40)
    rankLabel.BackgroundTransparency = 1
    rankLabel.Text = "Rank: " .. CurrentRank .. "  |  Perms: " .. CurrentPerms
    rankLabel.TextColor3 = Color3.fromRGB(140, 140, 150)
    rankLabel.Font = Enum.Font.Gotham
    rankLabel.TextSize = 14
    rankLabel.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.84, 0, 0, 42)
    box.Position = UDim2.new(0.08, 0, 0.42, 0)
    box.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
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
    btn.BackgroundColor3 = Color3.fromRGB(0, 140, 115)
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

-- ================= RAYFIELD GEN2 =================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

-- OLED dark custom theme
local OLEDTheme = {
    WindowColor = ColorSequence.new(Color3.fromRGB(8, 8, 10), Color3.fromRGB(12, 12, 14)),
    ShadowColor = Color3.fromRGB(0, 0, 0),
    ContentColor = Color3.fromRGB(230, 230, 235),
    TitlingColor = Color3.fromRGB(245, 245, 250),
    AccentColor = Color3.fromRGB(0, 210, 170),
    AccentStroke = Color3.fromRGB(0, 180, 145),
    TabColor = Color3.fromRGB(220, 220, 225),
    TabBackground = ColorSequence.new(Color3.fromRGB(18, 18, 22), Color3.fromRGB(14, 14, 18)),
    ElementGradient = ColorSequence.new(Color3.fromRGB(16, 16, 20), Color3.fromRGB(12, 12, 16)),
    FieldBackground = Color3.fromRGB(14, 14, 18),
    SliderBackground = Color3.fromRGB(22, 22, 28),
    SliderProgress = ColorSequence.new(Color3.fromRGB(0, 210, 170), Color3.fromRGB(0, 160, 130)),
    ToggleTrack = Color3.fromRGB(30, 30, 36),
}

local window = Rayfield:CreateWindow({
    name = "ZuzifyRBX [" .. CurrentRank:upper() .. "]",
    subtitle = "Rayfield Gen2 • OLED",
    theme = OLEDTheme,
    configuration = {
        autoSave = true,
        autoLoad = true,
        fileName = "ZuzifyRBX_Gen2",
    },
})

-- Features
local Features = {
    ESP = false, ESP_Names = true, ESP_Distance = true, ESP_Chams = true, ESP_Boxes = false,
    NoclipType = "None", FlyType = "None", FlySpeed = 60, InfiniteJump = false,
    WalkSpeed = 16, JumpPower = 50, SpeedBoost = false, SuperJump = false,
    AntiAFK = true, AntiFling = true, HitboxExtender = false, HitboxSize = 9, AntiDie = false,
    Aimbot = false, SilentAim = false, AimbotFOV = 230, AimbotSmooth = 0.13, AimbotPrediction = 0.14,
    AimPart = "HumanoidRootPart", AutoKill = false, KnifeAura = false, AuraRange = 15,
    SelectedTarget = nil, KillTarget = false, AutoShoot = false,
    Piggyback = false, FrontCarry = false, SideCarry = false,
    FlingType = "Normal", FlingNearest = false, FlingAll = false,
    Invisible = false, GlitchSelf = false,
    ShowCodes = false, ShowKeys = false, ShowCheese = false, RatESP = false, AutoCheese = false,
    CoinFarm = false, TPMurderer = false, TPSheriff = false, GrabGun = false,
    CustomFOV = 70, Fullbright = false,
}

local RoleColors = {
    Murderer = Color3.fromRGB(255, 55, 55),
    Sheriff = Color3.fromRGB(55, 145, 255),
    Innocent = Color3.fromRGB(55, 230, 100),
}

local MapTeleports = {
    Lobby = Vector3.new(-110, 140, 40),
    Bank = Vector3.new(0, 5, 0),
    Hotel = Vector3.new(50, 5, 0),
    Hospital = Vector3.new(-50, 5, 0),
    Office = Vector3.new(0, 5, 50),
    House = Vector3.new(30, 5, -30),
}

local ESPObjects, ObjectESP, RatESPObject = {}, {}, nil
local BodyVel, BodyGyro = nil, nil
local lastFarm, lastKill, lastAnti, lastRole, lastFling, lastGlitch, lastJump, lastScan = 0,0,0,0,0,0,0,0
local currentMurderer, currentSheriff, currentRatModel, myRole = nil, nil, nil, "Unknown"
local PlayerList, originalTransparency = {}, {}
local originalAmbient, originalBrightness, originalClockTime = nil, nil, nil

local function DD(v)
    if type(v) == "table" then return v[1] or v.Value or tostring(v[1]) end
    return v
end

local function Notify(title, content)
    pcall(function()
        window:Notify({ title = title, content = content or "" })
    end)
end

local function ApplyFOV(v)
    Features.CustomFOV = v
    pcall(function() Camera.FieldOfView = v end)
end

local function ApplyFullbright(state)
    Features.Fullbright = state
    pcall(function()
        if state then
            if not originalAmbient then
                originalAmbient = Lighting.Ambient
                originalBrightness = Lighting.Brightness
                originalClockTime = Lighting.ClockTime
            end
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
        else
            if originalAmbient then
                Lighting.Ambient = originalAmbient
                Lighting.Brightness = originalBrightness
                Lighting.ClockTime = originalClockTime
            end
        end
    end)
end

local function TeleportTo(pos)
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
    end)
end

ApplyFOV(70)

-- Helpers (role, ESP, rat, movement, combat) — same logic as before
local function IsPlayerCharacter(model)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character == model then return true end
    end
    return false
end

local function FindRealRat()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not IsPlayerCharacter(obj) then
            local name = string.lower(obj.Name)
            if name == "rat" or name == "therat" or name:find("rat") then
                if obj:FindFirstChildWhichIsA("BasePart") or obj.PrimaryPart then return obj end
            end
        end
    end
    return nil
end

local function GetRatRoot(rat)
    if not rat then return nil end
    if rat:IsA("BasePart") then return rat end
    return rat.PrimaryPart or rat:FindFirstChild("HumanoidRootPart") or rat:FindFirstChild("Head") or rat:FindFirstChildWhichIsA("BasePart")
end

local function ClearRatESP()
    if RatESPObject then
        pcall(function()
            if RatESPObject.Highlight then RatESPObject.Highlight:Destroy() end
            if RatESPObject.Billboard then RatESPObject.Billboard:Destroy() end
            if RatESPObject.Box then RatESPObject.Box:Destroy() end
        end)
        RatESPObject = nil
    end
end

local function CreateRealRatESP(ratModel)
    ClearRatESP()
    if not ratModel then return end
    local root = GetRatRoot(ratModel)
    if not root then return end
    local head = ratModel:FindFirstChild("Head") or root
    local objects = {}

    local hl = Instance.new("Highlight")
    hl.Adornee = ratModel:IsA("Model") and ratModel or root
    hl.FillColor = Color3.fromRGB(255, 30, 30)
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    hl.FillTransparency = 0.2
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ratModel:IsA("Model") and ratModel or root
    objects.Highlight = hl

    local box = Instance.new("BoxHandleAdornment")
    box.Adornee = root
    box.Size = (root.Size or Vector3.new(2, 2, 2)) + Vector3.new(1.5, 1.5, 1.5)
    box.Color3 = Color3.fromRGB(255, 40, 40)
    box.Transparency = 0.35
    box.AlwaysOnTop = true
    box.Parent = root
    objects.Box = box

    local bb = Instance.new("BillboardGui")
    bb.Adornee = head
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.StudsOffset = Vector3.new(0, 3.5, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 20000
    bb.Parent = head

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = "REAL RAT"
    label.TextColor3 = Color3.fromRGB(255, 50, 50)
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.Parent = bb

    objects.Billboard = bb
    objects.Label = label
    objects.Root = root
    RatESPObject = objects
    currentRatModel = ratModel
end

local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local function check(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = string.lower(tool.Name)
        if n:find("knife") or n:find("dagger") or n:find("blade") then return "Murderer" end
        if n:find("gun") or n:find("revolver") or n:find("pistol") then return "Sheriff" end
        return nil
    end
    local ok, role = pcall(function()
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
    return ok and role or "Innocent"
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
        hl.FillTransparency = 0.4
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
        box.Transparency = 0.5
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
    bb.Size = UDim2.new(0, 140, 0, 32)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
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
            if Features.ShowCheese and (name:find("cheese") or name:find("cheddar")) then
                CreateObjectESP(part, "CHEESE", Color3.fromRGB(255, 220, 50))
            end
        end
    end
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
                else
                    if originalTransparency[part] then part.Transparency = originalTransparency[part] end
                end
            end
        end
        if not state then table.clear(originalTransparency) end
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
        else
            myRoot.CFrame = tRoot.CFrame * CFrame.new(2.7, 0.4, 0)
        end
    end)
end

local function OnCharacter()
    task.wait(0.5)
    ApplyStats()
    ApplyNoclip()
    if Features.FlyType ~= "None" then SetupFly() end
    if Features.HitboxExtender then ApplyHitbox() end
    if Features.Invisible then SetInvisible(true) end
    if Features.ESP then task.delay(0.4, RefreshESP) end
    ApplyFOV(Features.CustomFOV)
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
            if plr == LocalPlayer then myRole = role end
        end
        currentMurderer, currentSheriff = mur, sher
    end

    if (Features.ShowCodes or Features.ShowKeys or Features.ShowCheese) and tick() - lastScan > 3 then
        lastScan = tick()
        ScanObjects()
    end

    if Features.RatESP then
        if tick() - lastScan > 1.0 then
            lastScan = tick()
            local found = FindRealRat()
            if found then CreateRealRatESP(found) else ClearRatESP() currentRatModel = nil end
        end
        if RatESPObject and RatESPObject.Label and RatESPObject.Root and root then
            local dist = math.floor((root.Position - RatESPObject.Root.Position).Magnitude)
            RatESPObject.Label.Text = "REAL RAT  [" .. dist .. " studs]"
        end
    end

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

    if Features.AntiDie and hum and hum.Health < hum.MaxHealth * 0.2 then
        hum.Health = hum.MaxHealth
    end

    if Features.HitboxExtender then ApplyHitbox() end
    if Camera.FieldOfView ~= Features.CustomFOV then Camera.FieldOfView = Features.CustomFOV end

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

    if Features.AutoShoot and tick() - lastKill > 0.4 then
        lastKill = tick()
        local tool = char and char:FindFirstChildOfClass("Tool")
        if tool then
            local n = string.lower(tool.Name)
            if n:find("gun") or n:find("revolver") then pcall(function() tool:Activate() end) end
        end
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

    if Features.GrabGun and root then
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") or (obj:IsA("BasePart") and string.find(string.lower(obj.Name), "gun")) then
                local part = obj:IsA("BasePart") and obj or obj:FindFirstChild("Handle")
                if part and (root.Position - part.Position).Magnitude < 200 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                    break
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

-- ================= UI (Rayfield Gen2) =================
local Home = window:CreateTab({ name = "Home" })
Home:CreateSection({ name = "Welcome" })
Home:CreateButton({
    name = "Status",
    description = "Rank: " .. CurrentRank .. " | Gen2 UI",
    callback = function()
        Notify("Role", "You are: " .. myRole)
    end,
})
Home:CreateButton({
    name = "Unlock Beta",
    description = "Send request to owner",
    callback = function()
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
                Notify("Beta", "Request sent")
            end
        end)
    end,
})
Home:CreateButton({
    name = "Zuzify News",
    callback = function()
        local text = "Failed"
        pcall(function() text = game:HttpGet(NEWS_PASTEBIN) end)
        Notify("News", text)
    end,
})

-- MM2
local MM2 = window:CreateTab({ name = "MM2" })
MM2:CreateSection({ name = "Role" })
MM2:CreateButton({
    name = "Show My Role",
    callback = function()
        myRole = GetRole(LocalPlayer)
        Notify("Role", "You are: " .. myRole)
    end,
})
MM2:CreateDropdown({
    name = "Preferred Role (UI only)",
    options = {"None", "Murderer", "Sheriff", "Innocent"},
    callback = function(v)
        Notify("Preferred", tostring(DD(v)) .. " (server still assigns real role)")
    end,
})

MM2:CreateSection({ name = "Map Teleports" })
for mapName, pos in pairs(MapTeleports) do
    MM2:CreateButton({
        name = "TP → " .. mapName,
        callback = function()
            TeleportTo(pos)
            Notify("Teleport", mapName)
        end,
    })
end

MM2:CreateSection({ name = "Round Tools" })
MM2:CreateToggle({ name = "Coin Farm", callback = function(v) Features.CoinFarm = v end })
MM2:CreateToggle({ name = "Grab Gun", callback = function(v) Features.GrabGun = v end })
MM2:CreateToggle({ name = "TP to Murderer", callback = function(v) Features.TPMurderer = v end })
MM2:CreateToggle({ name = "TP to Sheriff", callback = function(v) Features.TPSheriff = v end })

MM2:CreateSection({ name = "Combat" })
MM2:CreateToggle({ name = "Auto Kill", callback = function(v) Features.AutoKill = v end })
MM2:CreateToggle({ name = "Auto Shoot", callback = function(v) Features.AutoShoot = v end })
MM2:CreateToggle({ name = "Knife Aura", callback = function(v) Features.KnifeAura = v end })
MM2:CreateSlider({ name = "Aura Range", range = {6, 40}, value = 15, callback = function(v) Features.AuraRange = v end })
MM2:CreateToggle({ name = "Aimbot", callback = function(v) Features.Aimbot = v end })
MM2:CreateToggle({ name = "Silent Aim", callback = function(v) Features.SilentAim = v end })
MM2:CreateSlider({ name = "Aimbot FOV", range = {50, 500}, value = 230, callback = function(v) Features.AimbotFOV = v end })

MM2:CreateSection({ name = "Target" })
MM2:CreateDropdown({
    name = "Select Player",
    options = (#PlayerList > 0 and PlayerList) or {"None"},
    callback = function(v) Features.SelectedTarget = DD(v) end,
})
MM2:CreateButton({
    name = "Refresh Players",
    callback = function()
        PlayerList = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then table.insert(PlayerList, plr.Name) end
        end
        Notify("Players", "List refreshed — reselect target")
    end,
})
MM2:CreateToggle({ name = "Kill Selected", callback = function(v) Features.KillTarget = v end })

-- Cheese Escape
local Cheese = window:CreateTab({ name = "Cheese Escape" })
Cheese:CreateSection({ name = "Object ESP" })
Cheese:CreateToggle({ name = "Show Codes", callback = function(v) Features.ShowCodes = v ScanObjects() end })
Cheese:CreateToggle({ name = "Show Keys", callback = function(v) Features.ShowKeys = v ScanObjects() end })
Cheese:CreateToggle({ name = "Show Cheese", callback = function(v) Features.ShowCheese = v ScanObjects() end })
Cheese:CreateButton({ name = "Refresh Objects", callback = function() ScanObjects() Notify("Scanned", "Updated") end })

Cheese:CreateSection({ name = "Real Rat" })
Cheese:CreateToggle({
    name = "Rat ESP (Real Rat)",
    callback = function(v)
        Features.RatESP = v
        if v then
            local found = FindRealRat()
            if found then CreateRealRatESP(found) Notify("Rat", "Found") else Notify("Rat", "Not found") end
        else
            ClearRatESP()
        end
    end,
})
Cheese:CreateButton({
    name = "Teleport to Rat",
    callback = function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local ratRoot = RatESPObject and RatESPObject.Root
        if root and ratRoot then root.CFrame = ratRoot.CFrame * CFrame.new(0, 3, 6) else Notify("Rat", "No Rat") end
    end,
})
Cheese:CreateToggle({ name = "Auto Cheese Farm", callback = function(v) Features.AutoCheese = v end })
Cheese:CreateToggle({ name = "Speed Boost", callback = function(v) Features.SpeedBoost = v ApplyStats() end })
Cheese:CreateToggle({ name = "Super Jump", callback = function(v) Features.SuperJump = v ApplyStats() end })

-- Visuals
local Visuals = window:CreateTab({ name = "Visuals" })
Visuals:CreateSection({ name = "Player ESP" })
Visuals:CreateToggle({ name = "Enable ESP", callback = function(v) Features.ESP = v if v then RefreshESP() else ClearAllESP() end end })
Visuals:CreateToggle({ name = "Names + Role", currentValue = true, callback = function(v) Features.ESP_Names = v RefreshESP() end })
Visuals:CreateToggle({ name = "Distance", currentValue = true, callback = function(v) Features.ESP_Distance = v end })
Visuals:CreateToggle({ name = "Chams", currentValue = true, callback = function(v) Features.ESP_Chams = v RefreshESP() end })
Visuals:CreateToggle({ name = "Boxes", callback = function(v) Features.ESP_Boxes = v RefreshESP() end })
Visuals:CreateButton({ name = "Refresh ESP", callback = RefreshESP })
Visuals:CreateButton({ name = "Clear ESP", callback = function() ClearAllESP() Features.ESP = false end })

Visuals:CreateSection({ name = "World" })
Visuals:CreateToggle({ name = "Fullbright", callback = function(v) ApplyFullbright(v) end })
Visuals:CreateSlider({ name = "FOV", range = {50, 120}, value = 70, callback = function(v) ApplyFOV(v) end })

-- Movement
local Movement = window:CreateTab({ name = "Movement" })
Movement:CreateSection({ name = "Movement" })
Movement:CreateDropdown({
    name = "Noclip",
    options = {"None", "Normal", "Full"},
    callback = function(v) Features.NoclipType = DD(v) ApplyNoclip() end,
})
Movement:CreateDropdown({
    name = "Fly",
    options = {"None", "BodyVelocity"},
    callback = function(v)
        Features.FlyType = DD(v)
        if Features.FlyType == "None" then CleanupFly() else SetupFly() end
    end,
})
Movement:CreateSlider({ name = "Fly Speed", range = {10, 250}, value = 60, callback = function(v) Features.FlySpeed = v end })
Movement:CreateToggle({ name = "Infinite Jump", callback = function(v) Features.InfiniteJump = v end })
Movement:CreateSlider({ name = "Walk Speed", range = {10, 150}, value = 16, callback = function(v) Features.WalkSpeed = v ApplyStats() end })
Movement:CreateSlider({ name = "Jump Power", range = {30, 200}, value = 50, callback = function(v) Features.JumpPower = v ApplyStats() end })
Movement:CreateToggle({ name = "Anti Fling", currentValue = true, callback = function(v) Features.AntiFling = v end })
Movement:CreateToggle({ name = "Anti Die", callback = function(v) Features.AntiDie = v end })
Movement:CreateToggle({ name = "Hitbox Extender", callback = function(v) Features.HitboxExtender = v ApplyHitbox() end })
Movement:CreateToggle({ name = "Anti AFK", currentValue = true, callback = function(v) Features.AntiAFK = v end })

Movement:CreateSection({ name = "Teleports" })
Movement:CreateButton({ name = "TP Lobby", callback = function() TeleportTo(MapTeleports.Lobby) end })
Movement:CreateButton({ name = "TP Bank", callback = function() TeleportTo(MapTeleports.Bank) end })
Movement:CreateButton({ name = "TP Hotel", callback = function() TeleportTo(MapTeleports.Hotel) end })
Movement:CreateButton({ name = "TP Hospital", callback = function() TeleportTo(MapTeleports.Hospital) end })
Movement:CreateButton({ name = "TP Murderer", callback = function()
    if currentMurderer and currentMurderer.Character then
        local t = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
        if t then TeleportTo(t.Position) end
    end
end })
Movement:CreateButton({ name = "TP Sheriff", callback = function()
    if currentSheriff and currentSheriff.Character then
        local t = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
        if t then TeleportTo(t.Position) end
    end
end })

-- Troll
local Troll = window:CreateTab({ name = "Troll" })
Troll:CreateSection({ name = "Fling" })
Troll:CreateDropdown({
    name = "Fling Type",
    options = {"Normal", "Strong", "Up"},
    callback = function(v) Features.FlingType = DD(v) end,
})
Troll:CreateToggle({ name = "Fling Nearest", callback = function(v) Features.FlingNearest = v end })
Troll:CreateToggle({ name = "Fling All", callback = function(v) Features.FlingAll = v end })

Troll:CreateSection({ name = "Carry" })
Troll:CreateToggle({ name = "Piggyback", callback = function(v) Features.Piggyback = v end })
Troll:CreateToggle({ name = "Front Carry", callback = function(v) Features.FrontCarry = v end })
Troll:CreateToggle({ name = "Side Carry", callback = function(v) Features.SideCarry = v end })

Troll:CreateSection({ name = "Self" })
Troll:CreateToggle({ name = "Invisible", callback = function(v) Features.Invisible = v SetInvisible(v) end })
Troll:CreateToggle({ name = "Glitch Self", callback = function(v) Features.GlitchSelf = v end })

-- Settings (working themes)
local Settings = window:CreateTab({ name = "Settings" })
Settings:CreateSection({ name = "Themes (working)" })
Settings:CreateDropdown({
    name = "Theme",
    options = {"OLED Dark", "Default", "Cobalt", "Ember", "Amethyst", "Frost", "Rose"},
    callback = function(v)
        local name = DD(v)
        if name == "OLED Dark" then
            window:ChangeTheme(OLEDTheme)
        else
            window:ChangeTheme(string.lower(name))
        end
        Notify("Theme", "Applied " .. name)
    end,
})

Settings:CreateSection({ name = "Camera" })
Settings:CreateSlider({ name = "FOV", range = {50, 120}, value = 70, callback = function(v) ApplyFOV(v) end })
Settings:CreateToggle({ name = "Fullbright", callback = function(v) ApplyFullbright(v) end })

Settings:CreateSection({ name = "Server" })
Settings:CreateButton({
    name = "Rejoin",
    callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end,
})
Settings:CreateButton({
    name = "Server Hop",
    callback = function()
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
    end,
})

Notify("ZuzifyRBX", "Rayfield Gen2 loaded | Rank: " .. CurrentRank)
print("ZuzifyRBX Rayfield Gen2 | Rank:", CurrentRank)
