--[[
    ZuzifyRBX - Full Build v3
    - New rank system (NeedsPassword per rank)
    - Blacklist support
    - Game selector (MM2 / Cheese Escape / Other)
    - Better flings + movement
    - OLED style
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ================= LINKS =================
local RANK_PASTEBIN = "https://pastebin.com/raw/YOUR_NEW_RANK_PASTEBIN" -- << put new rank pastebin here
local PASSWORD_PASTEBIN = "https://pastebin.com/raw/YOUR_PASSWORD_PASTEBIN" -- << password only pastebin
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1467436721951084792/KYX4LUdBw4K2i2Bpwc4UZRSF1JRNJ0Banw1KK1xrQzjPHXMh0DLIQ0Rs8giXVISjqwt0"

-- ================= LOAD PASSWORD =================
local CORRECT_PASSWORD = "password"
pcall(function()
    local pw = game:HttpGet(PASSWORD_PASTEBIN)
    if pw and pw:match("%S") then
        CORRECT_PASSWORD = pw:match("^%s*(.-)%s*$")
    end
end)

-- ================= LOAD RANKS + BLACKLIST =================
local RankData = {}
local Blacklist = {}
local CurrentRank = "User"
local CurrentPerms = 1
local NeedsPassword = true

local function LoadRanks()
    local success, result = pcall(function()
        return game:HttpGet(RANK_PASTEBIN)
    end)
    if not success or not result then return end

    local inBlacklist = false
    for line in result:gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line == "" or line:match("^%-%-") then
            if line:lower():find("blacklist") then
                inBlacklist = true
            end
        elseif inBlacklist then
            if line:match("%S") then
                table.insert(Blacklist, line:lower())
            end
        else
            local rank, uid, username, perms, needpass = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)|([^|]+)")
            if rank and uid and username and perms and needpass then
                table.insert(RankData, {
                    Rank = rank,
                    UserId = tonumber(uid) or 0,
                    Username = username:lower(),
                    Perms = tonumber(perms) or 1,
                    NeedsPassword = needpass:lower() == "true"
                })
            end
        end
    end
end

LoadRanks()

-- Check blacklist
local function IsBlacklisted()
    local name = LocalPlayer.Name:lower()
    local uid = tostring(LocalPlayer.UserId)
    for _, v in ipairs(Blacklist) do
        if v == name or v == uid then
            return true
        end
    end
    return false
end

if IsBlacklisted() then
    LocalPlayer:Kick("You are blacklisted from ZuzifyRBX")
    return
end

local function GetPlayerRank()
    local name = LocalPlayer.Name:lower()
    local uid = LocalPlayer.UserId
    for _, data in ipairs(RankData) do
        if (data.UserId ~= 0 and data.UserId == uid) or data.Username == name then
            return data.Rank, data.Perms, data.NeedsPassword
        end
    end
    return "User", 1, true
end

CurrentRank, CurrentPerms, NeedsPassword = GetPlayerRank()

-- ================= PASSWORD (only if needed) =================
local passwordPassed = not NeedsPassword

if NeedsPassword then
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_Pass"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 420, 0, 250)
    frame.Position = UDim2.new(0.5, -210, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 160)
    stroke.Thickness = 1.4
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
    rankLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
    rankLabel.Font = Enum.Font.Gotham
    rankLabel.TextSize = 14
    rankLabel.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.84, 0, 0, 42)
    box.Position = UDim2.new(0.08, 0, 0.42, 0)
    box.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
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

-- ================= GAME SELECTOR =================
local SelectedGame = "MM2"

do
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyGameSelect"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 380, 0, 280)
    frame.Position = UDim2.new(0.5, -190, 0.5, -140)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 160)
    stroke.Thickness = 1.4
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = "What game are you playing?"
    title.TextColor3 = Color3.fromRGB(240, 240, 245)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = frame

    local function makeBtn(text, y, gameName)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.8, 0, 0, 42)
        b.Position = UDim2.new(0.1, 0, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 15
        b.Parent = frame
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        b.MouseButton1Click:Connect(function()
            SelectedGame = gameName
            gui:Destroy()
        end)
    end

    makeBtn("Murder Mystery 2 (Main)", 70, "MM2")
    makeBtn("Cheese Escape", 125, "CheeseEscape")
    makeBtn("Other Game", 180, "Other")

    while gui.Parent do task.wait() end
end

-- ================= LOAD MODAL =================
local success, Modal = pcall(function()
    return loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()
end)
if not success or not Modal then return end

local Window = Modal:CreateWindow({
    Title = "ZuzifyRBX [" .. CurrentRank:upper() .. "]",
    SubTitle = SelectedGame .. " • OLED",
    Size = UDim2.fromOffset(620, 520),
    MinimumSize = Vector2.new(360, 320),
    Transparency = 0,
})

-- ================= FEATURES =================
local Features = {
    ESP = false,
    ESP_Names = true,
    ESP_Distance = true,
    ESP_Chams = true,
    ESP_Boxes = false,

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

    Piggyback = false,
    FrontCarry = false,
    SideCarry = false,

    FlingType = "Normal",
    FlingNearest = false,
    FlingTarget = false,
    FlingAll = false,

    Invisible = false,
    ServerInvisBypass = false,
    GlitchSelf = false,

    CoinFarm = false,
    GrabGun = false,
    TPMurderer = false,
    TPSheriff = false,
    AntiDie = false,

    -- Cheese Escape / General
    SpeedBoost = false,
    SuperJump = false,
    NoClipFriends = false,
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

-- ================= HELPERS (same as previous + improved) =================
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

    if Features.ESP_Boxes then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ZRBX_Box"
        box.Adornee = root
        box.Size = Vector3.new(4, 6, 2)
        box.Color3 = color
        box.Transparency = 0.55
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
            pcall(CreateESP, plr)
        end
    end
end

local function ApplyStats()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = Features.SpeedBoost and 40 or Features.WalkSpeed
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
            if part:IsA("BasePart") then
                part.CanCollide = canCollide
            end
        end
    end)
end

local function SetupFly()
    pcall(function()
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
    end)
end

local function SetInvisible(state)
    pcall(function()
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
    end)
end

local function ApplyServerInvisBypass()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 1
                part.Transparency = 1
            end
        end
    end)
end

local function Teleport(pos)
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
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
                if dist < closestDist then
                    closestDist = dist
                    closest = plr
                end
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

        if Features.FlingType == "Normal" then
            bv.Velocity = Vector3.new(math.random(-130, 130), math.random(90, 150), math.random(-130, 130))
        elseif Features.FlingType == "Strong" then
            bv.Velocity = Vector3.new(math.random(-250, 250), math.random(150, 250), math.random(-250, 250))
        elseif Features.FlingType == "Up" then
            bv.Velocity = Vector3.new(math.random(-30, 30), math.random(280, 420), math.random(-30, 30))
        elseif Features.FlingType == "Spin" then
            bv.Velocity = Vector3.new(math.random(-180, 180), 110, math.random(-180, 180))
            local bg = Instance.new("BodyAngularVelocity")
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.AngularVelocity = Vector3.new(0, 55, 0)
            bg.Parent = root
            task.delay(0.4, function() if bg then bg:Destroy() end end)
        elseif Features.FlingType == "Random" then
            bv.Velocity = Vector3.new(math.random(-320, 320), math.random(60, 320), math.random(-320, 320))
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

-- Character + Players
local function OnCharacter(char)
    task.wait(0.5)
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
        task.wait(0.7)
        if Features.ESP then pcall(CreateESP, plr) end
        if not table.find(PlayerList, plr.Name) then
            table.insert(PlayerList, plr.Name)
        end
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
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

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
    if Features.ServerInvisBypass then ApplyServerInvisBypass() end

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

    if Features.Piggyback then DoCarry("Piggyback") end
    if Features.FrontCarry then DoCarry("Front") end
    if Features.SideCarry then DoCarry("Side") end

    if Features.KnifeAura and root then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                if tRoot and (root.Position - tRoot.Position).Magnitude < Features.AuraRange then
                    local tool = char:FindFirstChildOfClass("Tool")
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
                local tool = char:FindFirstChildOfClass("Tool")
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
        task.delay(0.04, function()
            if Features.GlitchSelf then SetInvisible(Features.Invisible) end
        end)
    end

    if Features.CoinFarm and root and tick() - lastFarm > 0.8 then
        lastFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local n = string.lower(obj.Name)
                if string.find(n, "coin") or string.find(n, "money") or string.find(n, "cash") or string.find(n, "cheese") then
                    if (root.Position - obj.Position).Magnitude < 180 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3.4, 0))
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
                if part and (root.Position - part.Position).Magnitude < 240 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.1, 0))
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

-- ================= UI =================
local Home = Window:AddTab("Home")
Home:New("Title")({ Title = "Welcome" })
Home:New("Button")({
    Title = "ZuzifyRBX v3",
    Description = "Rank: " .. CurrentRank .. " | Game: " .. SelectedGame,
    Callback = function() end
})

Home:New("Title")({ Title = "Beta Request" })
Home:New("Button")({
    Title = "Unlock Beta",
    Description = "Sends your username for review",
    Callback = function()
        if DISCORD_WEBHOOK == "YOUR_WEBHOOK_HERE" then
            Window:Notify({Title = "Webhook", Description = "Not set", Duration = 3, Type = "Error"})
            return
        end
        pcall(function()
            local req = http_request or request or (syn and syn.request)
            if req then
                req({
                    Url = DISCORD_WEBHOOK,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode({
                        content = "**Beta Request**\nUser: `" .. LocalPlayer.Name .. "`\nID: `" .. LocalPlayer.UserId .. "`\nRank: `" .. CurrentRank .. "`\nGame: `" .. SelectedGame .. "`"
                    })
                })
                Window:Notify({Title = "Beta", Description = "Request sent", Duration = 4, Type = "Success"})
            end
        end)
    end
})

local Visuals = Window:AddTab("Visuals")
Visuals:New("Title")({ Title = "ESP" })
Visuals:New("Toggle")({ Title = "Enable ESP", DefaultValue = false, Callback = function(v) Features.ESP = v if v then RefreshESP() else ClearAllESP() end end })
Visuals:New("Toggle")({ Title = "Names + Role", DefaultValue = true, Callback = function(v) Features.ESP_Names = v RefreshESP() end })
Visuals:New("Toggle")({ Title = "Distance", DefaultValue = true, Callback = function(v) Features.ESP_Distance = v end })
Visuals:New("Toggle")({ Title = "Chams", DefaultValue = true, Callback = function(v) Features.ESP_Chams = v RefreshESP() end })
Visuals:New("Toggle")({ Title = "Boxes", DefaultValue = false, Callback = function(v) Features.ESP_Boxes = v RefreshESP() end })
Visuals:New("Button")({ Title = "Refresh ESP", Callback = RefreshESP })
Visuals:New("Button")({ Title = "Clear ESP", Callback = function() ClearAllESP() Features.ESP = false end })

local Movement = Window:AddTab("Movement")
Movement:New("Title")({ Title = "Movement" })
Movement:New("Dropdown")({ Title = "Noclip Type", Options = {"None", "Normal", "Smooth", "Full", "MM2"}, Default = "None", Callback = function(v) Features.NoclipType = v ApplyNoclip() end })
Movement:New("Dropdown")({ Title = "Fly Type", Options = {"None", "BodyVelocity", "Smooth"}, Default = "None", Callback = function(v) Features.FlyType = v if v == "None" then CleanupFly() else SetupFly() end end })
Movement:New("Slider")({ Title = "Fly Speed", Default = 60, Minimum = 10, Maximum = 300, Callback = function(v) Features.FlySpeed = v end })
Movement:New("Toggle")({ Title = "Infinite Jump", DefaultValue = false, Callback = function(v) Features.InfiniteJump = v end })
Movement:New("Slider")({ Title = "Walk Speed", Default = 16, Minimum = 10, Maximum = 300, Callback = function(v) Features.WalkSpeed = v ApplyStats() end })
Movement:New("Slider")({ Title = "Jump Power", Default = 50, Minimum = 30, Maximum = 300, Callback = function(v) Features.JumpPower = v ApplyStats() end })
Movement:New("Toggle")({ Title = "Speed Boost (Cheese)", DefaultValue = false, Callback = function(v) Features.SpeedBoost = v ApplyStats() end })
Movement:New("Toggle")({ Title = "Super Jump (Cheese)", DefaultValue = false, Callback = function(v) Features.SuperJump = v ApplyStats() end })
Movement:New("Toggle")({ Title = "Anti Fling", DefaultValue = true, Callback = function(v) Features.AntiFling = v end })
Movement:New("Toggle")({ Title = "Anti Die", DefaultValue = false, Callback = function(v) Features.AntiDie = v end })
Movement:New("Toggle")({ Title = "Hitbox Extender", DefaultValue = false, Callback = function(v) Features.HitboxExtender = v ApplyHitbox() end })
Movement:New("Slider")({ Title = "Hitbox Size", Default = 9, Minimum = 3, Maximum = 30, Callback = function(v) Features.HitboxSize = v if Features.HitboxExtender then ApplyHitbox() end end })
Movement:New("Toggle")({ Title = "Anti AFK", DefaultValue = true, Callback = function(v) Features.AntiAFK = v end })

local Combat = Window:AddTab("Combat")
Combat:New("Title")({ Title = "Combat" })
Combat:New("Toggle")({ Title = "Aimbot", DefaultValue = false, Callback = function(v) Features.Aimbot = v end })
Combat:New("Toggle")({ Title = "Silent Aim", DefaultValue = false, Callback = function(v) Features.SilentAim = v end })
Combat:New("Slider")({ Title = "FOV", Default = 230, Minimum = 50, Maximum = 500, Callback = function(v) Features.AimbotFOV = v end })
Combat:New("Slider")({ Title = "Smoothness", Default = 13, Minimum = 5, Maximum = 50, Callback = function(v) Features.AimbotSmooth = v / 100 end })
Combat:New("Dropdown")({ Title = "Aim Part", Options = {"HumanoidRootPart", "Head", "UpperTorso"}, Default = "HumanoidRootPart", Callback = function(v) Features.AimPart = v end })
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
    Window:Notify({Title = "Players", Description = "Refreshed", Duration = 3, Type = "Success"})
end })
Combat:New("Toggle")({ Title = "Kill Selected", DefaultValue = false, Callback = function(v) Features.KillTarget = v end })

local Carry = Window:AddTab("Carry")
Carry:New("Title")({ Title = "Carry" })
Carry:New("Toggle")({ Title = "Piggyback", DefaultValue = false, Callback = function(v) Features.Piggyback = v end })
Carry:New("Toggle")({ Title = "Front Carry", DefaultValue = false, Callback = function(v) Features.FrontCarry = v end })
Carry:New("Toggle")({ Title = "Side Carry", DefaultValue = false, Callback = function(v) Features.SideCarry = v end })

local Troll = Window:AddTab("Troll")
Troll:New("Title")({ Title = "Fling" })
Troll:New("Dropdown")({
    Title = "Fling Type",
    Options = {"Normal", "Strong", "Up", "Spin", "Random"},
    Default = "Normal",
    Callback = function(v) Features.FlingType = v end
})
Troll:New("Toggle")({ Title = "Fling Nearest", DefaultValue = false, Callback = function(v) Features.FlingNearest = v end })
Troll:New("Toggle")({ Title = "Fling Selected", DefaultValue = false, Callback = function(v) Features.FlingTarget = v end })
Troll:New("Toggle")({ Title = "Fling All", DefaultValue = false, Callback = function(v) Features.FlingAll = v end })

local Self = Window:AddTab("Self")
Self:New("Title")({ Title = "Self" })
Self:New("Toggle")({ Title = "Invisible", DefaultValue = false, Callback = function(v) Features.Invisible = v SetInvisible(v) end })
Self:New("Toggle")({ Title = "Server Invis Bypass", DefaultValue = false, Callback = function(v) Features.ServerInvisBypass = v if v then ApplyServerInvisBypass() end end })
Self:New("Toggle")({ Title = "Glitch Self", DefaultValue = false, Callback = function(v) Features.GlitchSelf = v end })

local Utility = Window:AddTab("Utility")
Utility:New("Title")({ Title = "Utility" })
Utility:New("Toggle")({ Title = "Coin / Cheese Farm", DefaultValue = false, Callback = function(v) Features.CoinFarm = v end })
Utility:New("Toggle")({ Title = "Grab Gun", DefaultValue = false, Callback = function(v) Features.GrabGun = v end })
Utility:New("Toggle")({ Title = "TP to Murderer", DefaultValue = false, Callback = function(v) Features.TPMurderer = v end })
Utility:New("Toggle")({ Title = "TP to Sheriff", DefaultValue = false, Callback = function(v) Features.TPSheriff = v end })

local Teleports = Window:AddTab("Teleports")
Teleports:New("Title")({ Title = "Teleports" })
Teleports:New("Button")({ Title = "Lobby", Callback = function() Teleport(Vector3.new(0, 10, 0)) end })
Teleports:New("Button")({ Title = "Arena", Callback = function() Teleport(Vector3.new(0, 5, 50)) end })
Teleports:New("Button")({ Title = "Bank", Callback = function() Teleport(Vector3.new(0, 5, 0)) end })
Teleports:New("Button")({ Title = "Hotel", Callback = function() Teleport(Vector3.new(50, 5, 0)) end })
Teleports:New("Button")({ Title = "Hospital", Callback = function() Teleport(Vector3.new(-50, 5, 0)) end })

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
    Description = "v3 loaded | " .. SelectedGame .. " | Rank: " .. CurrentRank,
    Duration = 5,
    Type = "Success"
})

print("ZuzifyRBX v3 | Rank:", CurrentRank, "| Game:", SelectedGame)
