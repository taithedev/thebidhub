--[[
═══════════════════════════════════════════════════════════════════════════════
    HAILEY BIDWELL HUB  •  SUPER UPGRADED
    Fully English • Heavy MM2 Features • Feeling Emote • Super Polished
    
    Authors     : Tai (vertexi8) & daviddabag
    Special     : Made with pure love for Hailey Bidwell 💖
    UI Library  : Modal (BloxCrypto)
    Compatible  : Xeno + most modern executors
═══════════════════════════════════════════════════════════════════════════════
]]

-- ─────────────────────────────────────────────────────────────────────────────
-- SERVICES
-- ─────────────────────────────────────────────────────────────────────────────
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TeleportService     = game:GetService("TeleportService")
local HttpService         = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera
local Mouse       = LocalPlayer:GetMouse()

-- ─────────────────────────────────────────────────────────────────────────────
-- LOAD MODAL
-- ─────────────────────────────────────────────────────────────────────────────
local Modal = loadstring(game:HttpGet("https://github.com/BloxCrypto/Modal/releases/download/v1.0-beta/main.lua"))()

local Window = Modal:CreateWindow({
    Title        = "Hailey Bidwell Hub",
    SubTitle     = "by Tai (vertexi8) & daviddabag  •  For Hailey Bidwell 💖",
    Size         = UDim2.fromOffset(560, 520),
    MinimumSize  = Vector2.new(360, 320),
    Transparency = 0,
    Icon         = "rbxassetid://68073547",
})

Window:SetTheme("Rose")

-- ─────────────────────────────────────────────────────────────────────────────
-- FEATURES TABLE
-- ─────────────────────────────────────────────────────────────────────────────
local Features = {
    -- Visuals
    ESP              = false,
    ShowName         = true,
    ShowDistance     = true,
    ESPTheme         = "Sakura Pink",

    -- Movement
    Noclip           = false,
    Fly              = false,
    FlySpeed         = 55,
    InfiniteJump     = false,
    WalkSpeed        = 16,
    JumpPower        = 50,
    AntiAFK          = false,

    -- MM2 Specific (heavily expanded)
    MM2_AutoExecute  = false,
    MM2_Aimbot       = false,
    MM2_AimbotFOV    = 120,
    MM2_AutoCoinFarm = false,
    MM2_GrabGun      = false,
    MM2_KnifeAura    = false,
    MM2_TeleportMurderer = false,
    MM2_TeleportSheriff  = false,
    MM2_RoleAlert    = true,
    MM2_AutoShoot    = false,

    -- Other Games
    AdoptMe_AutoFarm = false,
    Brookhaven_AutoCollect = false,

    -- Mode Flags
    Mode_MM2         = true,
    Mode_AdoptMe     = false,
    Mode_Brookhaven  = false,
    Mode_Hockey      = false,
    Mode_Duels       = false,
}

-- ─────────────────────────────────────────────────────────────────────────────
-- ESP THEMES (14 aesthetic ones)
-- ─────────────────────────────────────────────────────────────────────────────
local ESPThemes = {
    ["Sakura Pink"] = {
        Murderer = Color3.fromRGB(255, 105, 180),
        Sheriff  = Color3.fromRGB(255, 182, 193),
        Innocent = Color3.fromRGB(255, 228, 225),
    },
    ["Lavender Dream"] = {
        Murderer = Color3.fromRGB(186, 85, 211),
        Sheriff  = Color3.fromRGB(221, 160, 221),
        Innocent = Color3.fromRGB(230, 230, 250),
    },
    ["Midnight Galaxy"] = {
        Murderer = Color3.fromRGB(138, 43, 226),
        Sheriff  = Color3.fromRGB(75, 0, 130),
        Innocent = Color3.fromRGB(123, 104, 238),
    },
    ["Rainbow"] = {
        Murderer = Color3.fromRGB(255, 0, 127),
        Sheriff  = Color3.fromRGB(0, 255, 255),
        Innocent = Color3.fromRGB(255, 255, 0),
    },
    ["Ocean Breeze"] = {
        Murderer = Color3.fromRGB(0, 191, 255),
        Sheriff  = Color3.fromRGB(64, 224, 208),
        Innocent = Color3.fromRGB(175, 238, 238),
    },
    ["Forest Fairy"] = {
        Murderer = Color3.fromRGB(34, 139, 34),
        Sheriff  = Color3.fromRGB(144, 238, 144),
        Innocent = Color3.fromRGB(152, 251, 152),
    },
    ["Ember"] = {
        Murderer = Color3.fromRGB(255, 69, 0),
        Sheriff  = Color3.fromRGB(255, 140, 0),
        Innocent = Color3.fromRGB(255, 215, 0),
    },
    ["Frost Queen"] = {
        Murderer = Color3.fromRGB(135, 206, 250),
        Sheriff  = Color3.fromRGB(176, 224, 230),
        Innocent = Color3.fromRGB(240, 248, 255),
    },
    ["Crystal"] = {
        Murderer = Color3.fromRGB(0, 255, 255),
        Sheriff  = Color3.fromRGB(224, 255, 255),
        Innocent = Color3.fromRGB(240, 255, 255),
    },
    ["Candy Shop"] = {
        Murderer = Color3.fromRGB(255, 20, 147),
        Sheriff  = Color3.fromRGB(255, 105, 180),
        Innocent = Color3.fromRGB(255, 192, 203),
    },
    ["Sunset"] = {
        Murderer = Color3.fromRGB(255, 94, 77),
        Sheriff  = Color3.fromRGB(255, 160, 122),
        Innocent = Color3.fromRGB(255, 218, 185),
    },
    ["Mint"] = {
        Murderer = Color3.fromRGB(0, 206, 209),
        Sheriff  = Color3.fromRGB(127, 255, 212),
        Innocent = Color3.fromRGB(245, 255, 250),
    },
    ["Ghostly"] = {
        Murderer = Color3.fromRGB(192, 192, 192),
        Sheriff  = Color3.fromRGB(220, 220, 220),
        Innocent = Color3.fromRGB(245, 245, 245),
    },
    ["Pastel Dream"] = {
        Murderer = Color3.fromRGB(255, 182, 193),
        Sheriff  = Color3.fromRGB(221, 160, 221),
        Innocent = Color3.fromRGB(176, 224, 230),
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- INTERNAL STATE
-- ─────────────────────────────────────────────────────────────────────────────
local ESPObjects      = {}
local BodyVelocity    = nil
local BodyGyro        = nil
local lastAutoExec    = 0
local lastCoinFarm    = 0
local lastAntiAFK     = 0
local lastRoleCheck   = 0
local customCoordStr  = "0, 50, 0"
local currentMurderer = nil
local currentSheriff  = nil

-- ─────────────────────────────────────────────────────────────────────────────
-- UTILITY FUNCTIONS
-- ─────────────────────────────────────────────────────────────────────────────

local function getMM2Role(player)
    if not player or not player.Character then return "Innocent" end

    local function check(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = tool.Name:lower()
        if n:find("knife") or n:find("dagger") or n:find("blade") or n:find("sword") then
            return "Murderer"
        elseif n:find("gun") or n:find("revolver") or n:find("pistol") or n:find("sheriff") then
            return "Sheriff"
        end
        return nil
    end

    local equipped = player.Character:FindFirstChildOfClass("Tool")
    local role = check(equipped)
    if role then return role end

    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            role = check(item)
            if role then return role end
        end
    end
    return "Innocent"
end

local function createESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local theme = ESPThemes[Features.ESPTheme] or ESPThemes["Sakura Pink"]
    local role  = getMM2Role(player)
    local color = theme[role] or theme.Innocent

    local billboard = Instance.new("BillboardGui")
    billboard.Name        = "HaileyESP_" .. player.Name
    billboard.Adornee     = head
    billboard.Size        = UDim2.new(0, 230, 0, 75)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 2000
    billboard.Parent      = head

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0.55, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name .. "  [" .. role .. "]"
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 15
    nameLabel.Visible = Features.ShowName
    nameLabel.Parent = frame

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0.45, 0)
    distLabel.Position = UDim2.new(0, 0, 0.55, 0)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0 studs"
    distLabel.TextColor3 = color
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 13
    distLabel.Visible = Features.ShowDistance
    distLabel.Parent = frame

    ESPObjects[player] = {
        Billboard = billboard,
        NameLabel = nameLabel,
        DistLabel = distLabel,
    }
end

local function removeESP(player)
    if ESPObjects[player] then
        if ESPObjects[player].Billboard then
            ESPObjects[player].Billboard:Destroy()
        end
        ESPObjects[player] = nil
    end
end

local function clearAllESP()
    for p, _ in pairs(ESPObjects) do
        removeESP(p)
    end
    table.clear(ESPObjects)
end

local function refreshESP()
    clearAllESP()
    if Features.ESP then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                createESP(p)
            end
        end
    end
end

local function applyMovementStats()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Features.WalkSpeed
        hum.JumpPower = Features.JumpPower
        pcall(function() hum.JumpHeight = Features.JumpPower / 3.5 end)
    end
end

local function applyNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not Features.Noclip
        end
    end
end

local function setupFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    if BodyVelocity then BodyVelocity:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end

    BodyVelocity = Instance.new("BodyVelocity")
    BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    BodyVelocity.Velocity = Vector3.zero
    BodyVelocity.Parent = root

    BodyGyro = Instance.new("BodyGyro")
    BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    BodyGyro.P = 15000
    BodyGyro.Parent = root
end

local function cleanupFly()
    if BodyVelocity then BodyVelocity:Destroy() BodyVelocity = nil end
    if BodyGyro then BodyGyro:Destroy() BodyGyro = nil end
end

local function teleportTo(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        root.CFrame = CFrame.new(pos)
        Window:Notify({
            Title = "Teleport",
            Description = string.format("Teleported to %.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z),
            Duration = 2.2,
            Type = "Success"
        })
    end
end

local function playAnimation(id)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
        track:Stop(0.12)
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. tostring(id)
    local track = hum:LoadAnimation(anim)
    track:Play()
end

-- Find dropped gun in MM2
local function findDroppedGun()
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") or (obj:IsA("BasePart") and (obj.Name:lower():find("gun") or obj.Name:lower():find("revolver"))) then
            return obj
        end
    end
    return nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CHARACTER + PLAYER HANDLERS
-- ─────────────────────────────────────────────────────────────────────────────
local function onCharacterAdded(char)
    task.wait(0.65)
    applyMovementStats()
    if Features.Noclip then applyNoclip() end
    if Features.Fly then setupFly() end
    if Features.ESP then task.delay(0.4, refreshESP) end
end

if LocalPlayer.Character then onCharacterAdded(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.8)
        if Features.ESP then createESP(p) end
    end)
end)

Players.PlayerRemoving:Connect(removeESP)

-- ─────────────────────────────────────────────────────────────────────────────
-- MAIN LOOP
-- ─────────────────────────────────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")

    -- ESP update
    if Features.ESP and root then
        for player, data in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("Head") and data.Billboard then
                local tRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist = (root.Position - tRoot.Position).Magnitude
                    if data.DistLabel then
                        data.DistLabel.Text = string.format("%.0f studs", dist)
                        data.DistLabel.Visible = Features.ShowDistance
                    end
                    if data.NameLabel then
                        local role = getMM2Role(player)
                        local theme = ESPThemes[Features.ESPTheme] or ESPThemes["Sakura Pink"]
                        local color = theme[role] or theme.Innocent
                        data.NameLabel.Text = player.Name .. "  [" .. role .. "]"
                        data.NameLabel.TextColor3 = color
                        data.DistLabel.TextColor3 = color
                        data.NameLabel.Visible = Features.ShowName
                    end
                end
            else
                removeESP(player)
            end
        end
    end

    -- Noclip keep
    if Features.Noclip and char then applyNoclip() end

    -- Fly
    if Features.Fly and root and BodyVelocity and BodyGyro then
        local cam = Camera.CFrame
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit * Features.FlySpeed end
        BodyVelocity.Velocity = dir
        BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
    end

    -- Infinite Jump
    if Features.InfiniteJump and hum and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    -- ── MM2 FEATURES ──
    if Features.Mode_MM2 or true then  -- always check for MM2 features

        -- Role tracking + alert
        if tick() - lastRoleCheck > 2 then
            lastRoleCheck = tick()
            local newMur, newSher = nil, nil
            for _, p in ipairs(Players:GetPlayers()) do
                local r = getMM2Role(p)
                if r == "Murderer" then newMur = p end
                if r == "Sheriff" then newSher = p end
            end
            if Features.MM2_RoleAlert then
                if newMur and newMur ~= currentMurderer then
                    currentMurderer = newMur
                    Window:Notify({Title = "Role Alert", Description = "Murderer is: " .. newMur.Name, Duration = 3, Type = "Warning"})
                end
                if newSher and newSher ~= currentSheriff then
                    currentSheriff = newSher
                    Window:Notify({Title = "Role Alert", Description = "Sheriff is: " .. newSher.Name, Duration = 3, Type = "Info"})
                end
            end
            currentMurderer = newMur
            currentSheriff = newSher
        end

        -- Auto Execute / Kill when you are murderer-ish
        if Features.MM2_AutoExecute and tick() - lastAutoExec > 2.5 then
            lastAutoExec = tick()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and getMM2Role(p) == "Murderer" then
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then tool:Activate() end
                end
            end
        end

        -- Soft Aimbot
        if Features.MM2_Aimbot and root then
            local closest, closestDist = nil, Features.MM2_AimbotFOV
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        local dist = (root.Position - tRoot.Position).Magnitude
                        if dist < closestDist then
                            closestDist = dist
                            closest = tRoot
                        end
                    end
                end
            end
            if closest then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, closest.Position)
            end
        end

        -- Knife Aura (when close to someone)
        if Features.MM2_KnifeAura and root then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot and (root.Position - tRoot.Position).Magnitude < 12 then
                        local tool = char and char:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end

        -- Auto Coin Farm (simple path to coins)
        if Features.MM2_AutoCoinFarm and root and tick() - lastCoinFarm > 1.2 then
            lastCoinFarm = tick()
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and (obj.Name:lower():find("coin") or obj.Name:lower():find("money") or obj.Name:lower():find("cash")) then
                    if (root.Position - obj.Position).Magnitude < 120 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        break
                    end
                end
            end
        end

        -- Grab Gun
        if Features.MM2_GrabGun and root then
            local gun = findDroppedGun()
            if gun then
                local part = gun:IsA("BasePart") and gun or gun:FindFirstChild("Handle") or gun.PrimaryPart
                if part then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                end
            end
        end

        -- Teleport to Murderer
        if Features.MM2_TeleportMurderer and currentMurderer and currentMurderer.Character then
            local tRoot = currentMurderer.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and root then
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4)
            end
        end

        -- Teleport to Sheriff
        if Features.MM2_TeleportSheriff and currentSheriff and currentSheriff.Character then
            local tRoot = currentSheriff.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and root then
                root.CFrame = tRoot.CFrame * CFrame.new(0, 0, 4)
            end
        end
    end

    -- Adopt Me / Brookhaven (kept simple)
    if Features.AdoptMe_AutoFarm and root and tick() - lastCoinFarm > 1.5 then
        lastCoinFarm = tick()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") or obj:IsA("TouchInterest") then
                local part = obj.Parent
                if part and part:IsA("BasePart") and (root.Position - part.Position).Magnitude < 90 then
                    root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.5, 0))
                    break
                end
            end
        end
    end

    if Features.Brookhaven_AutoCollect and root and tick() - lastCoinFarm > 1.8 then
        lastCoinFarm = tick()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                local n = part.Name:lower()
                if n:find("collect") or n:find("money") or n:find("cash") or n:find("coin") then
                    if (root.Position - part.Position).Magnitude < 110 then
                        root.CFrame = CFrame.new(part.Position + Vector3.new(0, 3.5, 0))
                        break
                    end
                end
            end
        end
    end

    -- Anti AFK
    if Features.AntiAFK and tick() - lastAntiAFK > 32 then
        lastAntiAFK = tick()
        pcall(function()
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
            task.wait(0.07)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
        end)
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- UI TABS
-- ─────────────────────────────────────────────────────────────────────────────

-- HOME
local HomeTab = Window:AddTab("Home")

HomeTab:New("Title")({ Title = "Welcome" })

HomeTab:New("Button")({
    Title = "Hello " .. LocalPlayer.Name .. "!",
    Description = "Welcome to the fully upgraded Hailey Bidwell Hub.\nScript loaded successfully. Enjoy the new MM2 power.",
    Callback = function()
        Window:Notify({
            Title = "Hailey Bidwell Hub",
            Description = "Hello " .. LocalPlayer.Name .. "! Super version is ready 💖",
            Duration = 4,
            Type = "Success"
        })
    end,
})

HomeTab:New("Title")({ Title = "Supported Games" })

HomeTab:New("Button")({
    Title = "Game List",
    Description = "• Murder Mystery 2 (heavily upgraded)\n• Adopt Me\n• Brookhaven\n• Hockey Legends\n• Duels",
    Callback = function() end,
})

HomeTab:New("Title")({ Title = "Credits" })

HomeTab:New("Button")({
    Title = "Special Thanks",
    Description = "Made with pure love for Hailey Bidwell 💖\nAuthors: Tai (vertexi8) & daviddabag\nUI: Modal by BloxCrypto\nThank you for using this!",
    Callback = function()
        Window:Notify({
            Title = "Credits",
            Description = "For Hailey Bidwell by Tai (vertexi8) & daviddabag",
            Duration = 5,
            Type = "Info"
        })
    end,
})

-- VISUALS
local VisualsTab = Window:AddTab("Visuals")

VisualsTab:New("Title")({ Title = "ESP Settings" })

VisualsTab:New("Toggle")({
    Title = "ESP Enabled",
    Description = "Creates live BillboardGui boxes above every player with role + distance.",
    DefaultValue = false,
    Callback = function(v)
        Features.ESP = v
        if v then refreshESP() else clearAllESP() end
        Window:Notify({Title = "ESP", Description = v and "ESP Enabled" or "ESP Disabled", Duration = 2, Type = v and "Success" or "Info"})
    end,
})

VisualsTab:New("Toggle")({
    Title = "Show Name + Role",
    Description = "Shows player name and current role (Murderer / Sheriff / Innocent).",
    DefaultValue = true,
    Callback = function(v)
        Features.ShowName = v
        for _, d in pairs(ESPObjects) do if d.NameLabel then d.NameLabel.Visible = v end end
    end,
})

VisualsTab:New("Toggle")({
    Title = "Show Distance",
    Description = "Shows live distance in studs under the name.",
    DefaultValue = true,
    Callback = function(v)
        Features.ShowDistance = v
        for _, d in pairs(ESPObjects) do if d.DistLabel then d.DistLabel.Visible = v end end
    end,
})

VisualsTab:New("Dropdown")({
    Title = "ESP Color Theme",
    Description = "14 beautiful aesthetic themes for Murderer / Sheriff / Innocent colors.",
    Options = {"Sakura Pink","Lavender Dream","Midnight Galaxy","Rainbow","Ocean Breeze","Forest Fairy","Ember","Frost Queen","Crystal","Candy Shop","Sunset","Mint","Ghostly","Pastel Dream"},
    Default = "Sakura Pink",
    Callback = function(v)
        Features.ESPTheme = v
        refreshESP()
        Window:Notify({Title = "Theme", Description = "Switched to " .. v, Duration = 2, Type = "Success"})
    end,
})

VisualsTab:New("Button")({
    Title = "Refresh ESP",
    Description = "Force rebuilds every ESP object.",
    Callback = function()
        refreshESP()
        Window:Notify({Title = "ESP", Description = "Refreshed", Duration = 2, Type = "Info"})
    end,
})

-- MOVEMENT
local MovementTab = Window:AddTab("Movement")

MovementTab:New("Title")({ Title = "Movement Controls" })

MovementTab:New("Toggle")({
    Title = "Noclip",
    Description = "Walk through walls and objects.",
    DefaultValue = false,
    Callback = function(v)
        Features.Noclip = v
        applyNoclip()
        Window:Notify({Title = "Noclip", Description = v and "Enabled" or "Disabled", Duration = 2, Type = v and "Success" or "Info"})
    end,
})

MovementTab:New("Toggle")({
    Title = "Fly",
    Description = "Free fly with WASD + Space/Shift. Speed controlled below.",
    DefaultValue = false,
    Callback = function(v)
        Features.Fly = v
        if v then setupFly() else cleanupFly() end
        Window:Notify({Title = "Fly", Description = v and "Enabled" or "Disabled", Duration = 2, Type = v and "Success" or "Info"})
    end,
})

MovementTab:New("Slider")({
    Title = "Fly Speed",
    Description = "How fast you fly (10-200).",
    Default = 55,
    Minimum = 10,
    Maximum = 200,
    DecimalCount = 0,
    Callback = function(v) Features.FlySpeed = v end,
})

MovementTab:New("Toggle")({
    Title = "Infinite Jump",
    Description = "Jump endlessly in the air.",
    DefaultValue = false,
    Callback = function(v) Features.InfiniteJump = v end,
})

MovementTab:New("Slider")({
    Title = "Walk Speed",
    Description = "Ground speed (10-200). Re-applies after respawn.",
    Default = 16,
    Minimum = 10,
    Maximum = 200,
    DecimalCount = 0,
    Callback = function(v)
        Features.WalkSpeed = v
        applyMovementStats()
    end,
})

MovementTab:New("Slider")({
    Title = "Jump Power",
    Description = "Jump height (30-200). Re-applies after respawn.",
    Default = 50,
    Minimum = 30,
    Maximum = 200,
    DecimalCount = 0,
    Callback = function(v)
        Features.JumpPower = v
        applyMovementStats()
    end,
})

MovementTab:New("Toggle")({
    Title = "Anti-AFK",
    Description = "Prevents being kicked for inactivity.",
    DefaultValue = false,
    Callback = function(v)
        Features.AntiAFK = v
        Window:Notify({Title = "Anti-AFK", Description = v and "Enabled" or "Disabled", Duration = 2, Type = v and "Success" or "Info"})
    end,
})

-- GAMES (HEAVY MM2 FOCUS)
local GamesTab = Window:AddTab("Games")

GamesTab:New("Title")({ Title = "Murder Mystery 2  —  Core" })

GamesTab:New("Toggle")({
    Title = "Role Alert",
    Description = "Notifies you the moment a new Murderer or Sheriff is detected.",
    DefaultValue = true,
    Callback = function(v) Features.MM2_RoleAlert = v end,
})

GamesTab:New("Toggle")({
    Title = "Auto Execute / Kill",
    Description = "When a Murderer is found, automatically activates your tool every few seconds.",
    DefaultValue = false,
    Callback = function(v) Features.MM2_AutoExecute = v end,
})

GamesTab:New("Toggle")({
    Title = "Knife Aura",
    Description = "Automatically activates your knife when any player is within ~12 studs.",
    DefaultValue = false,
    Callback = function(v) Features.MM2_KnifeAura = v end,
})

GamesTab:New("Toggle")({
    Title = "Soft Aimbot",
    Description = "Locks camera onto the closest player within FOV. Great for both Murderer and Sheriff.",
    DefaultValue = false,
    Callback = function(v) Features.MM2_Aimbot = v end,
})

GamesTab:New("Slider")({
    Title = "Aimbot FOV / Range",
    Description = "Maximum distance the aimbot will lock onto someone.",
    Default = 120,
    Minimum = 40,
    Maximum = 250,
    DecimalCount = 0,
    Callback = function(v) Features.MM2_AimbotFOV = v end,
})

GamesTab:New("Title")({ Title = "Murder Mystery 2  —  Farming & Utility" })

GamesTab:New("Toggle")({
    Title = "Auto Coin Farm",
    Description = "Automatically moves you to nearby coins / money parts so you can farm passively.",
    DefaultValue = false,
    Callback = function(v) Features.MM2_AutoCoinFarm = v end,
})

GamesTab:New("Toggle")({
    Title = "Grab Gun",
    Description = "Automatically teleports you to any dropped gun on the map.",
    DefaultValue = false,
    Callback = function(v) Features.MM2_GrabGun = v end,
})

GamesTab:New("Toggle")({
    Title = "Teleport to Murderer",
    Description = "Keeps you right next to the current Murderer (useful for Sheriff or trolling).",
    DefaultValue = false,
    Callback = function(v) Features.MM2_TeleportMurderer = v end,
})

GamesTab:New("Toggle")({
    Title = "Teleport to Sheriff",
    Description = "Keeps you right next to the current Sheriff.",
    DefaultValue = false,
    Callback = function(v) Features.MM2_TeleportSheriff = v end,
})

GamesTab:New("Title")({ Title = "Other Games" })

GamesTab:New("Toggle")({
    Title = "Adopt Me Auto Farm",
    Description = "Moves to nearby TouchInterest parts (item collection).",
    DefaultValue = false,
    Callback = function(v) Features.AdoptMe_AutoFarm = v end,
})

GamesTab:New("Toggle")({
    Title = "Brookhaven Auto Collect",
    Description = "Moves to parts named collect / money / cash / coin.",
    DefaultValue = false,
    Callback = function(v) Features.Brookhaven_AutoCollect = v end,
})

GamesTab:New("Title")({ Title = "Mode Markers" })

GamesTab:New("Toggle")({
    Title = "MM2 Mode",
    Description = "Marks that you are playing Murder Mystery 2.",
    DefaultValue = true,
    Callback = function(v) Features.Mode_MM2 = v end,
})

GamesTab:New("Toggle")({
    Title = "Adopt Me Mode",
    Description = "Marks that you are playing Adopt Me.",
    DefaultValue = false,
    Callback = function(v) Features.Mode_AdoptMe = v end,
})

GamesTab:New("Toggle")({
    Title = "Brookhaven Mode",
    Description = "Marks that you are playing Brookhaven.",
    DefaultValue = false,
    Callback = function(v) Features.Mode_Brookhaven = v end,
})

-- TELEPORTS
local TeleportsTab = Window:AddTab("Teleports")

TeleportsTab:New("Title")({ Title = "Preset Locations" })

local function addTP(name, desc, pos)
    TeleportsTab:New("Button")({
        Title = name,
        Description = desc,
        Callback = function() teleportTo(pos) end,
    })
end

addTP("MM2 Lobby", "Teleport to MM2 Lobby (0, 10, 0)", Vector3.new(0, 10, 0))
addTP("MM2 Arena", "Teleport to MM2 Arena (0, 5, 50)", Vector3.new(0, 5, 50))
addTP("Adopt Me Home", "Teleport to Adopt Me Home (0, 10, 0)", Vector3.new(0, 10, 0))
addTP("Adopt Me Shop", "Teleport to Adopt Me Shop (100, 10, 0)", Vector3.new(100, 10, 0))
addTP("Brookhaven House", "Teleport to Brookhaven House (0, 5, 0)", Vector3.new(0, 5, 0))
addTP("Brookhaven Store", "Teleport to Brookhaven Store (50, 5, 0)", Vector3.new(50, 5, 0))
addTP("Hockey Rink", "Teleport to Hockey Rink (0, 5, 0)", Vector3.new(0, 5, 0))
addTP("Duel Arena", "Teleport to Duel Arena (0, 5, 0)", Vector3.new(0, 5, 0))
addTP("Hailey's Spot 💖", "Custom Hailey spot (0, 50, 0)", Vector3.new(0, 50, 0))

TeleportsTab:New("Title")({ Title = "Custom Teleport" })

TeleportsTab:New("Input")({
    Title = "Custom Coordinates",
    Description = "Type X, Y, Z then click the button below.",
    DefaultText = "0, 50, 0",
    Placeholder = "X, Y, Z",
    Callback = function(v) customCoordStr = v end,
})

TeleportsTab:New("Button")({
    Title = "Teleport to Custom Coords",
    Description = "Reads the input and teleports you there.",
    Callback = function()
        local ok, err = pcall(function()
            local nums = {}
            for n in string.gmatch(customCoordStr, "[-%d%.]+") do
                table.insert(nums, tonumber(n))
            end
            if #nums >= 3 then
                teleportTo(Vector3.new(nums[1], nums[2], nums[3]))
            else
                error("bad format")
            end
        end)
        if not ok then
            Window:Notify({Title = "Teleport Failed", Description = "Use correct X, Y, Z format", Duration = 3, Type = "Error"})
        end
    end,
})

-- EMOTES (with Feeling)
local EmotesTab = Window:AddTab("Emotes")

EmotesTab:New("Title")({ Title = "Emote Animations" })

EmotesTab:New("Button")({
    Title = "Feeling 💖",
    Description = "Plays the Feeling emote (cute / aesthetic vibe).",
    Callback = function() playAnimation(118235501642203) end, -- Feeling cute style
})

EmotesTab:New("Button")({
    Title = "Dance 💃",
    Description = "Classic dance animation.",
    Callback = function() playAnimation(507770017) end,
})

EmotesTab:New("Button")({
    Title = "Floss",
    Description = "The famous Floss dance.",
    Callback = function() playAnimation(507771019) end,
})

EmotesTab:New("Button")({
    Title = "Wave 👋",
    Description = "Friendly wave.",
    Callback = function() playAnimation(507770239) end,
})

EmotesTab:New("Button")({
    Title = "Flex 💪",
    Description = "Show off those muscles.",
    Callback = function() playAnimation(507776043) end,
})

EmotesTab:New("Button")({
    Title = "Sit 🪑",
    Description = "Sit down animation.",
    Callback = function() playAnimation(507768133) end,
})

EmotesTab:New("Button")({
    Title = "Cartwheel",
    Description = "Cartwheel animation.",
    Callback = function() playAnimation(507777268) end,
})

EmotesTab:New("Button")({
    Title = "Shrug",
    Description = "Confused shrug.",
    Callback = function() playAnimation(3576686456) end,
})

-- SETTINGS
local SettingsTab = Window:AddTab("Settings")

SettingsTab:New("Title")({ Title = "Server Actions" })

SettingsTab:New("Button")({
    Title = "Rejoin",
    Description = "Rejoins the current place.",
    Callback = function()
        Window:Notify({Title = "Rejoin", Description = "Rejoining...", Duration = 2, Type = "Info"})
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

SettingsTab:New("Button")({
    Title = "Server Hop",
    Description = "Jumps to a random public server of the same game.",
    Callback = function()
        Window:Notify({Title = "Server Hop", Description = "Looking for servers...", Duration = 3, Type = "Info"})
        local ok, err = pcall(function()
            local data = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
            local list = {}
            if data and data.data then
                for _, s in ipairs(data.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        table.insert(list, s.id)
                    end
                end
            end
            if #list > 0 then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1, #list)], LocalPlayer)
            else
                Window:Notify({Title = "Server Hop", Description = "No good servers found", Duration = 3, Type = "Warning"})
            end
        end)
        if not ok then
            Window:Notify({Title = "Server Hop Failed", Description = tostring(err), Duration = 4, Type = "Error"})
        end
    end,
})

SettingsTab:New("Button")({
    Title = "Clear ESP",
    Description = "Destroys all ESP objects instantly.",
    Callback = function()
        clearAllESP()
        Features.ESP = false
        Window:Notify({Title = "ESP", Description = "Cleared", Duration = 2, Type = "Info"})
    end,
})

SettingsTab:New("Title")({ Title = "UI Theme" })

SettingsTab:New("Dropdown")({
    Title = "Change Theme",
    Description = "Light / Dark / Midnight / Rose / Emerald",
    Options = {"Light", "Dark", "Midnight", "Rose", "Emerald"},
    Default = "Rose",
    Callback = function(v)
        Window:SetTheme(v)
        Window:Notify({Title = "Theme", Description = "Changed to " .. v, Duration = 2, Type = "Success"})
    end,
})

SettingsTab:New("Title")({ Title = "About" })

SettingsTab:New("Button")({
    Title = "Credits",
    Description = "Made with love for Hailey Bidwell 💖\nAuthors: Tai (vertexi8) & daviddabag\nUI: Modal Library",
    Callback = function()
        Window:Notify({
            Title = "Hailey Bidwell Hub",
            Description = "For Hailey Bidwell by Tai (vertexi8) & daviddabag 💖",
            Duration = 5,
            Type = "Success"
        })
    end,
})

SettingsTab:New("Button")({
    Title = "Destroy UI",
    Description = "Closes the hub and cleans up ESP + fly objects.",
    Callback = function()
        clearAllESP()
        cleanupFly()
        Features.ESP = false
        Features.Fly = false
        Features.Noclip = false
        Window:Destroy()
    end,
})

-- FINAL
Window:SetTab("Home")

Window:Notify({
    Title = "Hailey Bidwell Hub",
    Description = "Super upgraded version loaded!\nHello " .. LocalPlayer.Name .. " 💖\nMade by Tai (vertexi8) & daviddabag",
    Duration = 5,
    Type = "Success"
})

print("════════════════════════════════════════════════════")
print("  Hailey Bidwell Hub — SUPER UPGRADED")
print("  Authors : Tai (vertexi8) & daviddabag")
print("  For     : Hailey Bidwell 💖")
print("════════════════════════════════════════════════════")
