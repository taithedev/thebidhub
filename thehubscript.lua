--[[
    ╔══════════════════════════════════════════════╗
    ║  ZuzifyRBX Gen6.1.0 — Fixed Edition          ║
    ║  Fixed: Notify API, SQL Errors, UI Crashes   ║
    ╚══════════════════════════════════════════════╝
]]

--------------------------- CONFIG ---------------------------
local VERSION        = "Gen6.1.0"
local CREDITS        = "Owner: mrcoptai (717544874) • UI: Rayfield • Backend: Supabase"

-- ⚠️ REPLACE THESE WITH YOUR SUPABASE PROJECT VALUES
local SUPABASE_URL       = "https://hfxpuqvishbfqlwxnnpe.supabase.co"
local SUPABASE_ANON_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmeHB1cXZpc2hiZnFsd3hubnBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkwNzkyMTUsImV4cCI6MjEwNDY1NTIxNX0.p8YyuvBhAw45YmKc-o-iMyvKKTPDEdKdnBfT2EUGx18"

local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1467436721951084792/KYX4LUdBw4K2i2Bpwc4UZRSF1JRNJ0Banw1KK1xrQzjPHXMh0DLIQ0Rs8giXVISjqwt0"

local OWNER_UID     = 717544874
local DEVELOPER_UIDS = {} -- Add numeric UIDs here: {123, 456}
local MASTER_PASSWORD = "sofia"

--------------------------- SERVICES ---------------------------
local Players              = game:GetService("Players")
local RunService           = game:GetService("RunService")
local UserInputService     = game:GetService("UserInputService")
local TeleportService      = game:GetService("TeleportService")
local HttpService          = game:GetService("HttpService")
local VirtualInputManager  = game:GetService("VirtualInputManager")
local CoreGui              = game:GetService("CoreGui")
local Lighting             = game:GetService("Lighting")
local TweenService         = game:GetService("TweenService")
local Debris               = game:GetService("Debris")
local Workspace            = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--------------------------- HTTP HELPERS ---------------------------
local httpReq = http_request or request or (syn and syn.request) or (http and http.request)

local function http(method, url, headers, body)
    if not httpReq then return nil end
    local opts = { Url = url, Method = method, Headers = headers or {} }
    if body then
        opts.Body = type(body) == "string" and body or HttpService:JSONEncode(body)
        opts.Headers["Content-Type"] = "application/json"
    end
    local ok, res = pcall(httpReq, opts)
    if not ok or not res then return nil end
    local decoded
    pcall(function() decoded = HttpService:JSONDecode(res.Body) end)
    return decoded, res.StatusCode
end

local function sbHeaders(extra)
    local h = {
        ["apikey"] = SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json",
        ["Prefer"] = "return=representation",
    }
    if extra then for k,v in pairs(extra) do h[k] = v end end
    return h
end

local function sbGet(table_, query) return http("GET", SUPABASE_URL .. "/rest/v1/" .. table_ .. (query and ("?"..query) or ""), sbHeaders()) end
local function sbPost(table_, body) return http("POST", SUPABASE_URL .. "/rest/v1/" .. table_, sbHeaders(), body) end
local function sbPatch(table_, query, body) return http("PATCH", SUPABASE_URL .. "/rest/v1/" .. table_ .. "?" .. query, sbHeaders(), body) end

--------------------------- UTIL ---------------------------
local function DD(v) if type(v) == "table" then return v[1] or tostring(v[1]) end return v end

--------------------------- SAFE NOTIFY WRAPPER ---------------------------
-- The previous error was caused by incorrect Rayfield Notify syntax.
-- This wrapper ensures we always use the correct capitalized arguments.
local function SendNotify(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title = title or "ZuzifyRBX",
            Content = content or "",
            Duration = duration or 8,
            Image = 4483362458,
        })
    end)
end

--------------------------- DISCLAIMER POPUP ---------------------------
local function showDisclaimer()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_Disclaimer"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0)
    overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.35
    overlay.BorderSizePixel = 0
    overlay.Parent = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 620, 0, 480)
    frame.Position = UDim2.new(0.5, -310, 0.5, -240)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 160)
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 44)
    title.Position = UDim2.new(0, 20, 0, 16)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX " .. VERSION .. " — Disclaimer"
    title.TextColor3 = Color3.fromRGB(0, 220, 180)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 22
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -40, 0, 300)
    body.Position = UDim2.new(0, 20, 0, 66)
    body.BackgroundTransparency = 1
    body.TextColor3 = Color3.fromRGB(220, 220, 230)
    body.Font = Enum.Font.Gotham
    body.TextSize = 14
    body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.Text = "Before you use ZuzifyRBX, please read and accept the following:\n\n• ZuzifyRBX is a third-party script. Use is at your OWN RISK.\n• You must comply with Roblox Terms of Service.\n• ZuzifyRBX is NOT responsible for any bans, kicks, or damages.\n• Data collected: we log your UserID + username to Supabase for licensing and anonymous statistics.\n• Your username is NOT publicly shown unless you enable 'Share Username' in Settings.\n• By clicking ACCEPT, you agree to these terms."
    body.Parent = frame

    local accept = Instance.new("TextButton")
    accept.Size = UDim2.new(0.45, -30, 0, 46)
    accept.Position = UDim2.new(0, 20, 1, -66)
    accept.BackgroundColor3 = Color3.fromRGB(0, 160, 130)
    accept.Text = "ACCEPT"
    accept.TextColor3 = Color3.fromRGB(255,255,255)
    accept.Font = Enum.Font.GothamBold
    accept.TextSize = 16
    accept.Parent = frame
    Instance.new("UICorner", accept).CornerRadius = UDim.new(0, 10)

    local decline = Instance.new("TextButton")
    decline.Size = UDim2.new(0.45, -30, 0, 46)
    decline.Position = UDim2.new(0.5, 10, 1, -66)
    decline.BackgroundColor3 = Color3.fromRGB(160, 40, 50)
    decline.Text = "DECLINE"
    decline.TextColor3 = Color3.fromRGB(255,255,255)
    decline.Font = Enum.Font.GothamBold
    decline.TextSize = 16
    decline.Parent = frame
    Instance.new("UICorner", decline).CornerRadius = UDim.new(0, 10)

    local accepted = false
    accept.MouseButton1Click:Connect(function() accepted = true; gui:Destroy() end)
    decline.MouseButton1Click:Connect(function() gui:Destroy(); LocalPlayer:Kick("You declined the ZuzifyRBX disclaimer.") end)

    while not accepted and gui.Parent do task.wait(0.1) end
    return accepted
end

if not showDisclaimer() then return end

--------------------------- LICENSE POPUP ---------------------------
local function showLicensePopup()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_License"
    gui.ResetOnSpawn = false
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 520, 0, 380)
    frame.Position = UDim2.new(0.5, -260, 0.5, -190)
    frame.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(0, 200, 160); stroke.Thickness = 1.5; stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 44)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX " .. VERSION .. " — Activation"
    title.TextColor3 = Color3.fromRGB(0, 220, 180)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -40, 0, 60)
    status.Position = UDim2.new(0, 20, 0, 50)
    status.BackgroundTransparency = 1
    status.Text = "Enter your license key, or click Continue for the FREE tier.\nFree tier has fewer features. Paid tiers unlock everything."
    status.TextColor3 = Color3.fromRGB(200, 200, 215)
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.TextWrapped = true
    status.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.9, 0, 0, 42)
    box.Position = UDim2.new(0.05, 0, 0.40, 0)
    box.BackgroundColor3 = Color3.fromRGB(16,16,20)
    box.TextColor3 = Color3.fromRGB(255,255,255)
    box.PlaceholderText = "License Key (e.g. ZUZ-PREM-0001)"
    box.Font = Enum.Font.Gotham
    box.TextSize = 15
    box.ClearTextOnFocus = false
    box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, -40, 0, 22)
    msg.Position = UDim2.new(0, 20, 0.40, 48)
    msg.BackgroundTransparency = 1
    msg.Text = ""
    msg.TextColor3 = Color3.fromRGB(255, 120, 120)
    msg.Font = Enum.Font.Gotham
    msg.TextSize = 13
    msg.Parent = frame

    local activate = Instance.new("TextButton")
    activate.Size = UDim2.new(0.44, -20, 0, 46)
    activate.Position = UDim2.new(0.05, 0, 0.75, 0)
    activate.BackgroundColor3 = Color3.fromRGB(0, 160, 130)
    activate.Text = "Activate Key"
    activate.TextColor3 = Color3.fromRGB(255,255,255)
    activate.Font = Enum.Font.GothamBold
    activate.TextSize = 15
    activate.Parent = frame
    Instance.new("UICorner", activate).CornerRadius = UDim.new(0,8)

    local skip = Instance.new("TextButton")
    skip.Size = UDim2.new(0.44, -20, 0, 46)
    skip.Position = UDim2.new(0.51, 0, 0.75, 0)
    skip.BackgroundColor3 = Color3.fromRGB(40,40,48)
    skip.Text = "Continue Free"
    skip.TextColor3 = Color3.fromRGB(230,230,240)
    skip.Font = Enum.Font.GothamBold
    skip.TextSize = 15
    skip.Parent = frame
    Instance.new("UICorner", skip).CornerRadius = UDim.new(0,8)

    local result = { done = false, tier = "free", key = nil }

    activate.MouseButton1Click:Connect(function()
        local key = box.Text:gsub("%s", "")
        if #key < 6 then msg.Text = "Key too short." return end
        msg.Text = "Checking…"
        task.spawn(function()
            local data, code = sbGet("zuzify_keys", "license_key=eq."..HttpService:UrlEncode(key).."&select=*")
            if not data or #data == 0 then
                msg.Text = "Invalid license key." return
            end
            local k = data[1]
            if not k.is_active then msg.Text = "Key is deactivated." return end
            if k.used_by and k.used_by ~= LocalPlayer.UserId then msg.Text = "Key already used." return end
            sbPatch("zuzify_keys", "license_key=eq."..HttpService:UrlEncode(key), { used_by = LocalPlayer.UserId, used_at = DateTime.now():ToIsoDate() })
            result.tier = k.tier or "basic"
            result.key  = key
            result.done = true
            gui:Destroy()
        end)
    end)

    skip.MouseButton1Click:Connect(function() result.done = true; gui:Destroy() end)
    while not result.done do task.wait(0.1) end
    return result.tier, result.key
end

local acquiredTier, acquiredKey = showLicensePopup()

--------------------------- REGISTER USER ---------------------------
local MY_UID      = LocalPlayer.UserId
local MY_USERNAME = LocalPlayer.Name
local IS_OWNER    = (MY_UID == OWNER_UID)
local IS_DEV      = table.find(DEVELOPER_UIDS, MY_UID) ~= nil

if IS_OWNER then acquiredTier = "owner" end
if IS_DEV   then acquiredTier = "developer" end

local function registerUser()
    local payload = {
        user_id = MY_UID,
        username = MY_USERNAME,
        license_key = acquiredKey,
        tier = acquiredTier,
        is_paid = acquiredTier ~= "free",
        last_seen = DateTime.now():ToIsoDate(),
    }
    local data = sbGet("zuzify_users", "user_id=eq."..MY_UID.."&select=*")
    if data and #data > 0 then
        sbPatch("zuzify_users", "user_id=eq."..MY_UID, payload)
        return data[1]
    else
        local created = sbPost("zuzify_users", payload)
        if created and #created > 0 then return created[1] end
    end
    return nil
end

local userRow = registerUser() or { tier = acquiredTier, is_trusted = false, show_username = false, is_banned = false }

if userRow.is_banned then
    LocalPlayer:Kick("ZuzifyRBX: Banned. Reason: " .. (userRow.ban_reason or "No reason"))
    return
end

--------------------------- TIER CHECK ---------------------------
local function HasTier(min)
    local order = { free = 0, basic = 1, premium = 2, trusted = 3, developer = 4, owner = 5 }
    return (order[acquiredTier] or 0) >= (order[min] or 0)
end

--------------------------- HEARTBEAT ---------------------------
local JOB_ID = game.JobId
local sessionId = nil
task.spawn(function()
    while true do
        pcall(function()
            if not sessionId then
                local created = sbPost("zuzify_sessions", {
                    user_id = MY_UID, username = userRow.show_username and MY_USERNAME or nil,
                    show_username = userRow.show_username or false, is_trusted = userRow.is_trusted or false,
                    tier = acquiredTier, job_id = JOB_ID,
                })
                if created and #created > 0 then sessionId = created[1].id end
            else
                sbPatch("zuzify_sessions", "id=eq."..sessionId, { last_ping = DateTime.now():ToIsoDate() })
            end

            local me = sbGet("zuzify_users", "user_id=eq."..MY_UID.."&select=is_banned,ban_reason,kick_signal,kick_reason")
            if me and #me > 0 then
                local m = me[1]
                if m.is_banned then LocalPlayer:Kick("ZuzifyRBX: Banned. Reason: " .. (m.ban_reason or "No reason")) end
                if m.kick_signal then
                    sbPatch("zuzify_users", "user_id=eq."..MY_UID, { kick_signal = false, kick_reason = "" })
                    LocalPlayer:Kick("ZuzifyRBX: " .. (m.kick_reason or "Kicked by staff."))
                end
            end
        end)
        task.wait(30)
    end
end)

--------------------------- 45 THEMES ---------------------------
local function Theme(accent, bg1, bg2)
    accent = accent or Color3.fromRGB(0,210,170)
    bg1 = bg1 or Color3.fromRGB(8,8,10)
    bg2 = bg2 or Color3.fromRGB(14,14,18)
    return {
        WindowColor=ColorSequence.new(bg1,bg2), ShadowColor=Color3.fromRGB(0,0,0),
        ContentColor=Color3.fromRGB(235,235,240), TitlingColor=Color3.fromRGB(250,250,255),
        AccentColor=accent, AccentStroke=accent, TabColor=Color3.fromRGB(220,220,230),
        TabBackground=ColorSequence.new(bg2,bg1), ElementGradient=ColorSequence.new(bg2,bg1),
        FieldBackground=bg2, SliderBackground=Color3.fromRGB(24,24,30),
        SliderProgress=ColorSequence.new(accent,accent), ToggleTrack=Color3.fromRGB(32,32,38),
    }
end
local Themes = {
    ["OLED Dark"]=Theme(Color3.fromRGB(0,210,170)), ["Midnight"]=Theme(Color3.fromRGB(90,140,255),Color3.fromRGB(10,12,24),Color3.fromRGB(16,18,36)),
    ["Crimson"]=Theme(Color3.fromRGB(255,55,75),Color3.fromRGB(16,8,10),Color3.fromRGB(28,12,16)), ["Ocean"]=Theme(Color3.fromRGB(0,190,220),Color3.fromRGB(6,16,24),Color3.fromRGB(10,28,40)),
    ["Purple"]=Theme(Color3.fromRGB(160,80,255),Color3.fromRGB(14,8,24),Color3.fromRGB(24,14,40)), ["Gold"]=Theme(Color3.fromRGB(255,190,50),Color3.fromRGB(16,14,6),Color3.fromRGB(28,24,10)),
    ["Pink"]=Theme(Color3.fromRGB(255,105,180),Color3.fromRGB(18,10,16),Color3.fromRGB(32,16,28)), ["Matrix"]=Theme(Color3.fromRGB(0,255,70),Color3.fromRGB(2,8,2),Color3.fromRGB(4,16,4)),
    ["Abyss"]=Theme(Color3.fromRGB(40,80,255),Color3.fromRGB(2,4,12),Color3.fromRGB(6,10,24)), ["Mono"]=Theme(Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0),Color3.fromRGB(18,18,18)),
    ["Neon"]=Theme(Color3.fromRGB(255,0,200),Color3.fromRGB(10,0,20),Color3.fromRGB(20,0,40)), ["Cyberpunk"]=Theme(Color3.fromRGB(255,0,255),Color3.fromRGB(8,0,16),Color3.fromRGB(16,0,32)),
    ["Sunset"]=Theme(Color3.fromRGB(255,100,0),Color3.fromRGB(30,10,0),Color3.fromRGB(50,20,0)), ["Forest"]=Theme(Color3.fromRGB(0,200,100),Color3.fromRGB(2,16,8),Color3.fromRGB(4,24,12)),
    ["Pastel"]=Theme(Color3.fromRGB(200,150,255),Color3.fromRGB(30,20,40),Color3.fromRGB(50,35,60)), ["Galaxy"]=Theme(Color3.fromRGB(100,50,255),Color3.fromRGB(6,4,20),Color3.fromRGB(12,8,36)),
    ["Lava"]=Theme(Color3.fromRGB(255,80,0),Color3.fromRGB(20,4,0),Color3.fromRGB(40,8,0)), ["Ice"]=Theme(Color3.fromRGB(0,200,255),Color3.fromRGB(4,12,20),Color3.fromRGB(8,20,36)),
    ["Sand"]=Theme(Color3.fromRGB(200,170,120),Color3.fromRGB(20,16,12),Color3.fromRGB(36,28,20)), ["Rose"]=Theme(Color3.fromRGB(255,80,120),Color3.fromRGB(20,8,12),Color3.fromRGB(36,12,20)),
    ["Lime"]=Theme(Color3.fromRGB(150,255,50),Color3.fromRGB(8,16,4),Color3.fromRGB(16,28,8)), ["Candy"]=Theme(Color3.fromRGB(255,150,200),Color3.fromRGB(24,8,16),Color3.fromRGB(40,12,28)),
    ["Retro"]=Theme(Color3.fromRGB(255,200,50),Color3.fromRGB(16,12,8),Color3.fromRGB(28,20,12)), ["Vaporwave"]=Theme(Color3.fromRGB(255,0,150),Color3.fromRGB(12,0,24),Color3.fromRGB(24,0,48)),
    ["Synthwave"]=Theme(Color3.fromRGB(255,100,255),Color3.fromRGB(8,4,16),Color3.fromRGB(16,8,32)), ["Solar"]=Theme(Color3.fromRGB(255,150,0),Color3.fromRGB(20,12,0),Color3.fromRGB(36,20,0)),
    ["Lunar"]=Theme(Color3.fromRGB(150,150,200),Color3.fromRGB(12,12,16),Color3.fromRGB(20,20,28)), ["Inferno"]=Theme(Color3.fromRGB(255,50,0),Color3.fromRGB(20,4,0),Color3.fromRGB(40,8,0)),
    ["Arctic"]=Theme(Color3.fromRGB(100,200,255),Color3.fromRGB(6,12,20),Color3.fromRGB(10,20,36)), ["Mint"]=Theme(Color3.fromRGB(100,255,180),Color3.fromRGB(4,16,10),Color3.fromRGB(8,28,18)),
    ["Lavender"]=Theme(Color3.fromRGB(200,150,255),Color3.fromRGB(14,8,24),Color3.fromRGB(24,14,40)), ["Copper"]=Theme(Color3.fromRGB(200,120,50),Color3.fromRGB(16,12,8),Color3.fromRGB(28,20,12)),
    ["Silver"]=Theme(Color3.fromRGB(180,180,200),Color3.fromRGB(12,12,14),Color3.fromRGB(20,20,24)), ["Emerald"]=Theme(Color3.fromRGB(50,200,100),Color3.fromRGB(4,16,8),Color3.fromRGB(8,28,14)),
    ["Ruby"]=Theme(Color3.fromRGB(200,50,50),Color3.fromRGB(16,4,4),Color3.fromRGB(28,8,8)), ["Sapphire"]=Theme(Color3.fromRGB(50,100,255),Color3.fromRGB(4,8,20),Color3.fromRGB(8,14,36)),
    ["Amber"]=Theme(Color3.fromRGB(255,180,50),Color3.fromRGB(16,12,4),Color3.fromRGB(28,20,8)), ["Jade"]=Theme(Color3.fromRGB(100,255,150),Color3.fromRGB(4,16,8),Color3.fromRGB(8,28,14)),
    ["Pearl"]=Theme(Color3.fromRGB(255,240,220),Color3.fromRGB(16,14,12),Color3.fromRGB(28,24,20)), ["Obsidian"]=Theme(Color3.fromRGB(180,180,200),Color3.fromRGB(2,2,4),Color3.fromRGB(6,6,12)),
    ["Blood"]=Theme(Color3.fromRGB(180,20,30),Color3.fromRGB(14,2,4),Color3.fromRGB(28,4,8)), ["Toxic"]=Theme(Color3.fromRGB(120,255,40),Color3.fromRGB(6,14,2),Color3.fromRGB(12,26,4)),
    ["Nebula"]=Theme(Color3.fromRGB(200,100,255),Color3.fromRGB(10,4,26),Color3.fromRGB(20,8,44)), ["Storm"]=Theme(Color3.fromRGB(120,160,200),Color3.fromRGB(10,14,20),Color3.fromRGB(18,24,34)),
    ["Aurora"]=Theme(Color3.fromRGB(80,255,200),Color3.fromRGB(4,14,14),Color3.fromRGB(8,28,28)),
}
local ThemeNames = {}
for k in pairs(Themes) do table.insert(ThemeNames, k) end
table.sort(ThemeNames)

--------------------------- RAYFIELD UI ---------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local window = Rayfield:CreateWindow({
    name = "ZuzifyRBX [" .. string.upper(acquiredTier) .. "]",
    subtitle = VERSION .. " • " .. CREDITS,
    theme = Themes["OLED Dark"],
    configuration = { autoSave = true, autoLoad = true, fileName = "ZuzifyRBX_Gen6" },
})

--------------------------- FEATURE FLAGS ---------------------------
local Features = {
    ESP=false, ESP_Names=true, ESP_Distance=true, ESP_Health=true, ESP_Weapon=true, ESP_Chams=true, ESP_Boxes=true,
    Fullbright=false, CustomFOV=70, NoclipType="None", FlyType="None", FlySpeed=60, InfiniteJump=false,
    WalkSpeed=16, JumpPower=50, SpeedBoost=false, SuperJump=false, HitboxExtender=false, HitboxSize=9,
    LowGravity=false, BunnyHop=false, CFrameSpeed=false, CFrameSpeedValue=2, Spin=false, Wallclimb=false,
    Dash=false, DashPower=30, TeleportToMouse=false, Aimbot=false, SilentAim=false, AimbotFOV=230,
    AimbotSmooth=0.13, AimbotPrediction=0.14, AimPart="HumanoidRootPart", AutoKill=false, KnifeAura=false,
    AuraRange=15, SelectedTarget=nil, KillTarget=false, AutoShoot=false, CoinFarm=false, GrabGun=false,
    GunESP=false, TPMurderer=false, TPSheriff=false, MurderWalk=false, FollowSheriff=false, Piggyback=false,
    FrontCarry=false, SideCarry=false, FlingType="Normal", FlingNearest=false, FlingAll=false, FlingTarget=false,
    Invisible=false, GlitchSelf=false, Orbit=false, OrbitSpeed=8, OrbitDist=6, LoopBehind=false,
    SkyPlatform=false, AnnoyAura=false, BounceTarget=false, FreezeTarget=false, InvisibleTarget=false,
    RainbowSelf=false, SpinTarget=false, PlatformTarget=false, DisableJumpTarget=false, DisableMoveTarget=false,
    FreezeAll=false, SpinAll=false, SlowMotionTarget=false, ShowCodes=false, ShowKeys=false, ShowCheese=false,
    ShowDoors=false, RatESP=false, AutoCheese=false, AntiAFK=true, AntiFling=true, AntiDie=false, AntiVoid=false,
    AntiSit=false, AntiRagdoll=false, AntiTrip=false, SelectedEmote=nil, DanceParty=false,
    ShareUsername = userRow.show_username or false,
}

local function pushUserUpdate(patch)
    sbPatch("zuzify_users", "user_id=eq."..MY_UID, patch)
    if sessionId then sbPatch("zuzify_sessions", "id=eq."..sessionId, patch) end
end

--------------------------- EMOTES (300+) ---------------------------
local EmoteList = {}
local function E(name, id) table.insert(EmoteList, {Name=name, ID=id}) end
local ids = {"507770620","507771112","507771612","507771366","507771049","507771682","507771410","507771276","507771842","507771453","507771054","507771815","507771568","507771147","507771731","507771174","507771878","507771594","507771358","507771270","507771697","507771597","507771482","507771702","507771501","507771205","507771295","507771100","507771650","507771467","507771406","507771537","507771339","507771266","507771490","507771831","507771771","507771647","507771060","507771152","507771554","507771536","507771715","507771080","507771398","507771911","507771551","507771756","507771692","507771357","507771226","507771022","507771582","507771620","507771769","507771670","507771364","507771279","507771019","507771790","507771307","507771591","507771494","507771674","507771837","507771457","507771109","507771547","507771305","507771827","507771183","507771466","507771706","507771174","507771217","507771330","507771476","507771215","507771679","507771865","507771093","507771585","507771660","507771803","507771329","507771491","507771259","507771716","507771053","507771128","507771640","507771597","507771091","507771767","507771412","507771010","507771210","507771315","507771505","507771605"}
local names = {"Dance","Robot","Floss","Twist","Whip","Wave","Point","Salute","Sit","Lay","Dab","Gangnam","Macarena","Harlem","Running Man","T-Pose","Cossack","Ballet","Sword","Karate","Boxing","Fencing","Taekwondo","Yoga","Breakdance","Moonwalk","Shuffle","Charleston","Tango","Waltz","Salsa","Mambo","Cha Cha","Rumba","Zumba","Hip Hop","Popping","Locking","Waacking","Voguing","Krumping","House","Industrial","Electro","Techno","Trance","Dubstep","Drum & Bass","Jazz","Tap","Modern","Contemporary","Lyrical","Musical","Ballroom","Swing","Lindy Hop","Jive","Boogie","Rock & Roll","Mosh","Circle Pit","Wall of Death","Clap","Cheer","Cry","Laugh","Shrug","Faint","Roar","Scream","Snap","Stomp","Thriller","Disco","Funky","Smooth","Cool","Attitude","Confused","Nervous","Shy","Sassy","Angry","Sad","Happy","Surprised","Disgusted","Fear","Pride","Love","Peace","Victory","Spin","Float","Kick","Punch","Jump","Slide","Backflip","Frontflip"}
local idx=0
for i=1,#names do idx=idx+1; E(names[i].." "..idx, "rbxassetid://"..ids[((i-1)%#ids)+1]) end
for i=1,200 do idx=idx+1; E("Extra Emote "..idx, "rbxassetid://"..ids[((i-1)%#ids)+1]..math.random(10,99)) end

--------------------------- HELPERS ---------------------------
local RoleColors = { Murderer=Color3.fromRGB(255,55,55), Sheriff=Color3.fromRGB(55,145,255), Innocent=Color3.fromRGB(55,230,100) }
local MapTeleports = { Lobby=Vector3.new(-110,140,40), Bank=Vector3.new(0,5,0), Hotel=Vector3.new(50,5,0), Hospital=Vector3.new(-50,5,0), Office=Vector3.new(0,5,50), House=Vector3.new(30,5,-30), Museum=Vector3.new(20,5,40), Laboratory=Vector3.new(-40,5,-20) }
local CachedRoles = {}

local function GetRole(plr)
    if not plr then return "Innocent" end
    local cached = CachedRoles[plr]
    if cached and tick()-cached.t < 0.5 then return cached.r end
    local r = "Innocent"
    pcall(function()
        if plr.Character then
            local tool = plr.Character:FindFirstChildOfClass("Tool")
            if tool then
                local n = string.lower(tool.Name)
                if n:find("knife") or n:find("dagger") or n:find("blade") then r="Murderer"
                elseif n:find("gun") or n:find("revolver") or n:find("pistol") then r="Sheriff" end
            end
        end
    end)
    CachedRoles[plr] = { r=r, t=tick() }
    return r
end

local function GetMyRoot() return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") end
local function GetMyHum()  return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") end
local function GetTarget() if not Features.SelectedTarget then return nil end return Players:FindFirstChild(Features.SelectedTarget) end
local function GetTargetRoot() local t = GetTarget(); if not t then return nil end return t.Character and t.Character:FindFirstChild("HumanoidRootPart") end
local function GetClosestPlayer(maxDist)
    local myRoot = GetMyRoot(); if not myRoot then return nil end
    local best, bd = nil, maxDist or 9999
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local d = (myRoot.Position - root.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
    end
    return best
end

--------------------------- ESP ---------------------------
local ESPObjects = {}
local function clearESP(plr) if ESPObjects[plr] then for _, o in pairs(ESPObjects[plr]) do pcall(function() if o and o.Parent then o:Destroy() end end) end ESPObjects[plr] = nil end end
local function clearAllESP() for p in pairs(ESPObjects) do clearESP(p) end end

local function createESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    local char = plr.Character; if not char then return end
    local head, root = char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
    if not head or not root then return end
    local role = GetRole(plr); local color = RoleColors[role] or RoleColors.Innocent; local o = {}
    local bb = Instance.new("BillboardGui"); bb.Adornee = head; bb.Size = UDim2.new(0,280,0,100); bb.StudsOffset = Vector3.new(0,3.2,0); bb.AlwaysOnTop = true; bb.Parent = head
    local nameL = Instance.new("TextLabel"); nameL.Size = UDim2.new(1,0,0.4,0); nameL.BackgroundTransparency = 1; nameL.Text = plr.Name.." ["..role.."]"; nameL.TextColor3 = color; nameL.TextStrokeTransparency = 0.1; nameL.Font = Enum.Font.GothamBold; nameL.TextSize = 14; nameL.Parent = bb
    local distL = Instance.new("TextLabel"); distL.Size = UDim2.new(1,0,0.25,0); distL.Position = UDim2.new(0,0,0.4,0); distL.BackgroundTransparency = 1; distL.Text = "0"; distL.TextColor3 = color; distL.Font = Enum.Font.Gotham; distL.TextSize = 12; distL.Parent = bb
    local hpL = Instance.new("TextLabel"); hpL.Size = UDim2.new(1,0,0.2,0); hpL.Position = UDim2.new(0,0,0.65,0); hpL.BackgroundTransparency = 1; hpL.Text = "HP: 100"; hpL.TextColor3 = Color3.fromRGB(0,255,0); hpL.Font = Enum.Font.Gotham; hpL.TextSize = 12; hpL.Parent = bb
    local wpL = Instance.new("TextLabel"); wpL.Size = UDim2.new(1,0,0.15,0); wpL.Position = UDim2.new(0,0,0.85,0); wpL.BackgroundTransparency = 1; wpL.Text = ""; wpL.TextColor3 = Color3.fromRGB(255,255,255); wpL.Font = Enum.Font.Gotham; wpL.TextSize = 11; wpL.Parent = bb
    o.Billboard, o.NameLabel, o.DistLabel, o.HealthLabel, o.WeaponLabel = bb, nameL, distL, hpL, wpL
    if Features.ESP_Chams then local hl = Instance.new("Highlight"); hl.Adornee = char; hl.FillColor = color; hl.OutlineColor = color; hl.FillTransparency = 0.4; hl.OutlineTransparency = 0; hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent = char; o.Highlight = hl end
    if Features.ESP_Boxes then local box = Instance.new("BoxHandleAdornment"); box.Adornee = root; box.Size = Vector3.new(4,6,2); box.Color3 = color; box.Transparency = 0.5; box.AlwaysOnTop = true; box.Parent = root; o.Box = box end
    ESPObjects[plr] = o
end

local function refreshESP() clearAllESP(); if not Features.ESP then return end; for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then pcall(createESP, plr) end end end

--------------------------- TROLLS ---------------------------
local function Fling(plr)
    pcall(function()
        if not plr or not plr.Character then return end
        local root = plr.Character:FindFirstChild("HumanoidRootPart"); if not root then return end
        local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Parent = root
        if Features.FlingType == "Strong" then bv.Velocity = Vector3.new(math.random(-250,250), math.random(150,250), math.random(-250,250))
        elseif Features.FlingType == "Up" then bv.Velocity = Vector3.new(0, math.random(300,450), 0)
        else bv.Velocity = Vector3.new(math.random(-140,140), math.random(90,150), math.random(-140,140)) end
        task.delay(0.35, function() if bv then bv:Destroy() end end)
    end)
end
local function Freeze(plr, s) local h = plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = s and 0 or 16; h.JumpPower = s and 0 or 50 end end
local function MakeInvis(plr, s) if not plr or not plr.Character then return end; for _, part in ipairs(plr.Character:GetDescendants()) do if part:IsA("BasePart") or part:IsA("Decal") then part.Transparency = s and 1 or 0 end end end
local function ForceSit(plr) local h = plr and plr.Character and plr.Character:FindFirstChildOfClass("Humanoid"); if h then h.Sit = true end end
local function SpinT(plr, s) local root = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart"); if not root then return end; local av = root:FindFirstChild("SpinAV"); if s and not av then av = Instance.new("BodyAngularVelocity"); av.MaxTorque = Vector3.new(9e9,9e9,9e9); av.AngularVelocity = Vector3.new(0,20,0); av.Parent = root; av.Name = "SpinAV" elseif not s and av then av:Destroy() end end
local function Explode(plr) local root = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart"); if not root then return end; local e = Instance.new("Explosion"); e.BlastRadius = 10; e.BlastPressure = 0; e.Position = root.Position; e.Parent = Workspace; Debris:AddItem(e, 0.5) end
local function PushPull(plr, dir) local root = plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart"); if not root then return end; local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = dir*120; bv.Parent = root; task.delay(0.5, function() if bv then bv:Destroy() end end) end
local function SwapPos(plr) local r1, r2 = GetMyRoot(), GetTargetRoot(); if not r1 or not r2 then return end; local a, b = r1.Position, r2.Position; r1.CFrame = CFrame.new(b); r2.CFrame = CFrame.new(a) end

local EmoteTracks = {}
local function clearEmotes() for _, t in ipairs(EmoteTracks) do pcall(function() t:Stop() t:Destroy() end) end EmoteTracks = {} end
local function PlayEmote(plr, id)
    if not plr or not plr.Character then return end
    local anim = plr.Character:FindFirstChildOfClass("Animator")
    if not anim then anim = Instance.new("Animator"); local h = plr.Character:FindFirstChildOfClass("Humanoid"); if h then anim.Parent = h end end
    if not anim then return end
    local track = anim:LoadAnimation(Instance.new("Animation")); track.AnimationId = id; track:Play(); table.insert(EmoteTracks, track)
end

--------------------------- MOVEMENT ---------------------------
local function ApplyStats() pcall(function() local h = GetMyHum(); if h then h.WalkSpeed = Features.SpeedBoost and 42 or Features.WalkSpeed; h.JumpPower = Features.SuperJump and 120 or Features.JumpPower end end) end
local function ApplyNoclip() pcall(function() local c = LocalPlayer.Character; if not c then return end; local cc = Features.NoclipType == "None"; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = cc end end end) end
local BodyVel, BodyGyro
local function SetupFly() local root = GetMyRoot(); if not root then return end; if BodyVel then BodyVel:Destroy() end; if BodyGyro then BodyGyro:Destroy() end; if Features.FlyType ~= "None" then BodyVel = Instance.new("BodyVelocity"); BodyVel.MaxForce = Vector3.new(9e9,9e9,9e9); BodyVel.Parent = root; BodyGyro = Instance.new("BodyGyro"); BodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9); BodyGyro.P = 20000; BodyGyro.Parent = root end end
local function CleanFly() if BodyVel then BodyVel:Destroy(); BodyVel = nil end; if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end end
local originalTransparency = {}
local function SetInvis(s) pcall(function() local c = LocalPlayer.Character; if not c then return end; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then if s then if not originalTransparency[p] then originalTransparency[p] = p.Transparency end; p.Transparency = 1 else if originalTransparency[p] then p.Transparency = originalTransparency[p] end end end end; if not s then table.clear(originalTransparency) end end) end

local function OnChar() task.wait(0.5); ApplyStats(); ApplyNoclip(); if Features.FlyType ~= "None" then SetupFly() end; if Features.Invisible then SetInvis(true) end; if Features.ESP then task.delay(0.4, refreshESP) end end
if LocalPlayer.Character then OnChar() end
LocalPlayer.CharacterAdded:Connect(OnChar)

--------------------------- MAIN LOOP ---------------------------
local lastHeavy, lastRole, lastAnti, lastJump = 0,0,0,0
local lastSafePos = Vector3.new(0,10,0)
local currentMurderer, currentSheriff = nil, nil

RunService.RenderStepped:Connect(function()
    local now = tick()
    local char = LocalPlayer.Character
    local root = GetMyRoot()
    local hum  = GetMyHum()
    if root and root.Position.Y > -50 then lastSafePos = root.Position end

    if now - lastHeavy > 0.5 then
        lastHeavy = now
        if now - lastRole > 1 then
            lastRole = now
            local mur, sher
            for _, plr in ipairs(Players:GetPlayers()) do
                local r = GetRole(plr)
                if r == "Murderer" then mur = plr end
                if r == "Sheriff"  then sher = plr end
            end
            currentMurderer, currentSheriff = mur, sher
        end
        if Features.ESP and root then
            for plr, o in pairs(ESPObjects) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local tr = plr.Character.HumanoidRootPart
                    local d = (root.Position - tr.Position).Magnitude
                    local role = GetRole(plr); local col = RoleColors[role] or RoleColors.Innocent
                    if o.NameLabel then o.NameLabel.Text = plr.Name.." ["..role.."]"; o.NameLabel.TextColor3 = col end
                    if o.DistLabel then o.DistLabel.Text = math.floor(d).." studs"; o.DistLabel.TextColor3 = col end
                    if o.HealthLabel then local h = plr.Character:FindFirstChildOfClass("Humanoid"); local hp = h and math.floor(h.Health) or 0; o.HealthLabel.Text = "HP: "..hp; o.HealthLabel.TextColor3 = hp > 50 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0) end
                    if o.WeaponLabel then local t = plr.Character:FindFirstChildOfClass("Tool"); o.WeaponLabel.Text = t and ("Weapon: "..t.Name) or "" end
                    if o.Highlight then o.Highlight.FillColor = col; o.Highlight.OutlineColor = col end
                else clearESP(plr) end
            end
        end
    end

    if not root or not hum then return end
    if Features.NoclipType ~= "None" then ApplyNoclip() end
    if Features.FlyType ~= "None" and BodyVel and BodyGyro then
        local cam = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit * Features.FlySpeed end
        BodyVel.Velocity = dir; BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
    end
    if Features.CFrameSpeed then
        local cam = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
        dir = Vector3.new(dir.X, 0, dir.Z); if dir.Magnitude > 0 then root.CFrame += dir.Unit * Features.CFrameSpeedValue end
    end
    if Features.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) and now-lastJump > 0.2 then lastJump = now; pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    if Features.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    if Features.Wallclimb then local ray = Ray.new(root.Position, root.CFrame.LookVector * 2); local hit = Workspace:FindPartOnRay(ray, char); if hit and hum.FloorMaterial == Enum.Material.Air then root.CFrame += Vector3.new(0, 0.5, 0) end end
    if Features.Dash and UserInputService:IsKeyDown(Enum.KeyCode.Space) and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and now-lastJump > 0.5 then lastJump = now; local dir = Camera.CFrame.LookVector * Features.DashPower; root.AssemblyLinearVelocity = Vector3.new(dir.X, 0, dir.Z) end
    if Features.TeleportToMouse and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then local m = UserInputService:GetMouseLocation(); local r = Camera:ScreenPointToRay(m.X, m.Y); local hit, pos = Workspace:FindPartOnRay(Ray.new(r.Origin, r.Direction*1000), char); if pos then root.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end end

    if Features.AntiFling and root.AssemblyLinearVelocity.Magnitude > 160 then root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero end
    if Features.AntiDie and hum.Health < hum.MaxHealth*0.2 then hum.Health = hum.MaxHealth end
    if Features.AntiVoid and root.Position.Y < -50 then root.CFrame = CFrame.new(lastSafePos + Vector3.new(0,5,0)); root.AssemblyLinearVelocity = Vector3.zero end
    if Features.AntiSit and hum.Sit then hum.Sit = false end
    if Features.AntiRagdoll then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running); hum.PlatformStand = false end) end
    if Features.AntiTrip then pcall(function() local s = hum:GetState(); if s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.Ragdoll then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end) end
    if Camera.FieldOfView ~= Features.CustomFOV then Camera.FieldOfView = Features.CustomFOV end

    if Features.Orbit and Features.SelectedTarget then local t = GetTarget(); local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart"); if tr then local a = (now * Features.OrbitSpeed) % (math.pi*2); root.CFrame = CFrame.new(tr.Position) * CFrame.Angles(0, a, 0) * CFrame.new(0, 2, Features.OrbitDist) end end
    if Features.LoopBehind and Features.SelectedTarget then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, 3.5) end end
    if Features.Piggyback then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0,3.1,0.2) end end
    if Features.FrontCarry then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0,0,-3.1) end end
    if Features.SideCarry then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(2.7,0.4,0) end end

    if Features.Aimbot or Features.SilentAim then
        local t = GetClosestPlayer(Features.AimbotFOV)
        if t and t.Character then
            local part = t.Character:FindFirstChild(Features.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local goal = part.Position + part.AssemblyLinearVelocity * Features.AimbotPrediction
                if Features.SilentAim then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, goal)
                else Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, goal), Features.AimbotSmooth) end
            end
        end
    end
    if Features.AutoKill and now-lastFling > 1.2 then lastFling = now; local tool = char and char:FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end end
    if Features.AutoShoot and now-lastFling > 0.4 then lastFling = now; local tool = char and char:FindFirstChildOfClass("Tool"); if tool then local n = string.lower(tool.Name); if n:find("gun") or n:find("revolver") then pcall(function() tool:Activate() end) end end end
    if Features.KnifeAura then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character then local tr = plr.Character:FindFirstChild("HumanoidRootPart"); if tr and (root.Position - tr.Position).Magnitude < Features.AuraRange then local tool = char and char:FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end end end end end
    if Features.FlingNearest and now-lastFling > 0.55 then lastFling = now; local c = GetClosestPlayer(55); if c then Fling(c) end end
    if Features.FlingTarget and Features.SelectedTarget and now-lastFling > 0.4 then lastFling = now; local t = GetTarget(); if t then Fling(t) end end
    if Features.FlingAll and now-lastFling > 0.85 then lastFling = now; for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then Fling(plr) end end end
    if Features.KillTarget and Features.SelectedTarget then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0,0,2.5); local tool = char and char:FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end end end

    local t = GetTarget()
    if t and t.Character then
        if Features.FreezeTarget then Freeze(t, true) else Freeze(t, false) end
        if Features.InvisibleTarget then MakeInvis(t, true) else MakeInvis(t, false) end
        if Features.SpinTarget then SpinT(t, true) else SpinT(t, false) end
        if Features.PlatformTarget then local tr = t.Character:FindFirstChild("HumanoidRootPart"); if tr then local existing = tr:FindFirstChild("ZuzyPlat"); if not existing then local p = Instance.new("Part"); p.Name = "ZuzyPlat"; p.Size = Vector3.new(8,1,8); p.Anchored = true; p.CanCollide = true; p.Material = Enum.Material.Neon; p.Color = Color3.fromRGB(0,200,160); p.CFrame = CFrame.new(tr.Position - Vector3.new(0,3,0)); p.Parent = tr end end else for _, pl in ipairs(Workspace:GetDescendants()) do if pl.Name == "ZuzyPlat" then pl:Destroy() end end end
        if Features.DisableJumpTarget then local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower = 0 end else local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower = 50 end end
        if Features.DisableMoveTarget then local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 0 end else local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 16 end end
        if Features.SlowMotionTarget then local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 4 end end
    end
    if Features.FreezeAll then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then Freeze(plr, true) end end else for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then Freeze(plr, false) end end end
    if Features.SpinAll then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then SpinT(plr, true) end end else for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then SpinT(plr, false) end end end
    if Features.RainbowSelf then local hue = now % 1; local c = Color3.fromHSV(hue, 1, 1); for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.Color = c end end end
    if Features.AntiAFK and now - lastAnti > 20 then lastAnti = now; pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game); task.wait(0.03); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end) end
end)

--------------------------- UI TABS ---------------------------
-- HOME
local Home = window:CreateTab({ name = "Home" })
Home:CreateSection({ name = "Account" })
Home:CreateButton({ name = "Status", callback = function()
    SendNotify("Status", "User: "..MY_USERNAME.." ("..MY_UID..")\nTier: "..string.upper(acquiredTier).."\nTrusted: "..tostring(userRow.is_trusted or false).."\nVersion: "..VERSION, 8)
end })
Home:CreateSection({ name = "Requests" })
local DevReason = ""
Home:CreateInput({ name = "Developer Reason", placeholder = "Why do you want Developer?", callback = function(t) DevReason = t end })
Home:CreateButton({ name = "Request Developer", callback = function()
    if #DevReason < 3 then SendNotify("Error", "Please type a reason.", 5) return end
    http("POST", DISCORD_WEBHOOK, { ["Content-Type"]="application/json" }, { content = "**Developer Request**\nUser: "..MY_USERNAME.." ("..MY_UID..")\nReason: "..DevReason })
    SendNotify("Sent", "Request sent to Discord.", 5)
end })

-- SETTINGS
local Settings = window:CreateTab({ name = "Settings" })
Settings:CreateSection({ name = "Information" })
Settings:CreateButton({ name = "Version: "..VERSION, callback = function() SendNotify("Version", VERSION.."\n"..CREDITS, 8) end })
Settings:CreateButton({ name = "Credits", callback = function() SendNotify("Credits", CREDITS, 10) end })
Settings:CreateButton({ name = "My Tier: "..string.upper(acquiredTier), callback = function() end })
Settings:CreateSection({ name = "Privacy / Trusted Program" })
Settings:CreateToggle({
    name = "Share Username (Trusted Program)", default = Features.ShareUsername,
    callback = function(v)
        Features.ShareUsername = v
        pushUserUpdate({ show_username = v })
        if v then
            if HasTier("basic") then
                sbPatch("zuzify_users", "user_id=eq."..MY_UID, { is_trusted = true })
                userRow.is_trusted = true
                SendNotify("Trusted", "You are now a Trusted User! Extra features unlocked.", 8)
            else
                SendNotify("Trusted", "Opted in. Buy a key to become officially Trusted.", 8)
            end
        end
    end,
})
Settings:CreateSection({ name = "Themes" })
Settings:CreateDropdown({ name = "Theme", options = ThemeNames, callback = function(v) local n = DD(v); if Themes[n] then window:ChangeTheme(Themes[n]) end end })
Settings:CreateSlider({ name = "FOV", range = {50,120}, value = 70, callback = function(v) Features.CustomFOV = v end })
Settings:CreateToggle({ name = "Fullbright", callback = function(v)
    Features.Fullbright = v
    pcall(function()
        if v then Lighting.Ambient = Color3.fromRGB(255,255,255); Lighting.Brightness = 2; Lighting.ClockTime = 14
        else Lighting.Ambient = Color3.fromRGB(70,70,70); Lighting.Brightness = 1; Lighting.ClockTime = 14 end
    end)
end })
Settings:CreateButton({ name = "Rejoin", callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
Settings:CreateButton({ name = "Server Hop", callback = function()
    pcall(function()
        local d = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        local list = {}
        for _, s in ipairs(d.data or {}) do if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(list, s.id) end end
        if #list > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, list[math.random(1,#list)], LocalPlayer) end
    end)
end })

-- VISUALS
local Visuals = window:CreateTab({ name = "Visuals" })
Visuals:CreateSection({ name = "ESP" })
Visuals:CreateToggle({ name = "Enable ESP", callback = function(v) Features.ESP = v; if v then refreshESP() else clearAllESP() end end })
Visuals:CreateToggle({ name = "Names + Role", callback = function(v) Features.ESP_Names = v; refreshESP() end })
Visuals:CreateToggle({ name = "Distance", callback = function(v) Features.ESP_Distance = v end })
Visuals:CreateToggle({ name = "Health", callback = function(v) Features.ESP_Health = v end })
Visuals:CreateToggle({ name = "Weapon", callback = function(v) Features.ESP_Weapon = v end })
Visuals:CreateToggle({ name = "Chams", callback = function(v) Features.ESP_Chams = v; refreshESP() end })
Visuals:CreateToggle({ name = "Boxes", callback = function(v) Features.ESP_Boxes = v; refreshESP() end })

-- MOVEMENT
local Movement = window:CreateTab({ name = "Movement" })
Movement:CreateSection({ name = "Basic" })
Movement:CreateDropdown({ name = "Noclip", options = {"None","Normal","Full"}, callback = function(v) Features.NoclipType = DD(v); ApplyNoclip() end })
Movement:CreateDropdown({ name = "Fly", options = {"None","BodyVelocity"}, callback = function(v) Features.FlyType = DD(v); if Features.FlyType == "None" then CleanFly() else SetupFly() end end })
Movement:CreateSlider({ name = "Fly Speed", range = {10,250}, value = 60, callback = function(v) Features.FlySpeed = v end })
Movement:CreateToggle({ name = "Infinite Jump", callback = function(v) Features.InfiniteJump = v end })
Movement:CreateSlider({ name = "Walk Speed", range = {10,150}, value = 16, callback = function(v) Features.WalkSpeed = v; ApplyStats() end })
Movement:CreateSlider({ name = "Jump Power", range = {30,200}, value = 50, callback = function(v) Features.JumpPower = v; ApplyStats() end })
Movement:CreateToggle({ name = "Speed Boost", callback = function(v) Features.SpeedBoost = v; ApplyStats() end })
Movement:CreateToggle({ name = "Super Jump", callback = function(v) Features.SuperJump = v; ApplyStats() end })
Movement:CreateToggle({ name = "Bunny Hop", callback = function(v) Features.BunnyHop = v end })
Movement:CreateToggle({ name = "Wallclimb", callback = function(v) Features.Wallclimb = v end })
Movement:CreateToggle({ name = "Dash (Space+Shift)", callback = function(v) Features.Dash = v end })
Movement:CreateSlider({ name = "Dash Power", range = {10,80}, value = 30, callback = function(v) Features.DashPower = v end })
Movement:CreateToggle({ name = "CFrame Speed", callback = function(v) Features.CFrameSpeed = v end })
Movement:CreateSlider({ name = "CFrame Multi", range = {1,10}, value = 2, callback = function(v) Features.CFrameSpeedValue = v end })
Movement:CreateToggle({ name = "Teleport To Mouse (RMB)", callback = function(v) Features.TeleportToMouse = v end })
Movement:CreateSection({ name = "Teleports" })
for name, pos in pairs(MapTeleports) do
    Movement:CreateButton({ name = "TP → "..name, callback = function() local r = GetMyRoot(); if r then r.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end end })
end

-- PLAYERS
local PlayersTab = window:CreateTab({ name = "Players" })
local function getPlayerNames() local t = {} for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p.Name) end end return t end
PlayersTab:CreateSection({ name = "Target" })
PlayersTab:CreateDropdown({ name = "Select Player", options = (#getPlayerNames()>0) and getPlayerNames() or {"None"}, callback = function(v) Features.SelectedTarget = DD(v) end })
PlayersTab:CreateToggle({ name = "Spectate", callback = function(v)
    if v then local t = GetTarget(); if t and t.Character then Camera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid") end
    else local h = GetMyHum(); if h then Camera.CameraSubject = h end end
end })
PlayersTab:CreateToggle({ name = "Orbit", callback = function(v) Features.Orbit = v end })
PlayersTab:CreateSlider({ name = "Orbit Distance", range = {3,20}, value = 6, callback = function(v) Features.OrbitDist = v end })
PlayersTab:CreateToggle({ name = "Loop Behind", callback = function(v) Features.LoopBehind = v end })

-- COMBAT
local Combat = window:CreateTab({ name = "Combat" })
Combat:CreateSection({ name = "Aim" })
Combat:CreateToggle({ name = "Aimbot", callback = function(v) Features.Aimbot = v end })
Combat:CreateToggle({ name = "Silent Aim", callback = function(v) Features.SilentAim = v end })
Combat:CreateSlider({ name = "Aimbot FOV", range = {50,500}, value = 230, callback = function(v) Features.AimbotFOV = v end })
Combat:CreateSection({ name = "Kill" })
Combat:CreateToggle({ name = "Auto Kill", callback = function(v) Features.AutoKill = v end })
Combat:CreateToggle({ name = "Auto Shoot", callback = function(v) Features.AutoShoot = v end })
Combat:CreateToggle({ name = "Knife Aura", callback = function(v) Features.KnifeAura = v end })
Combat:CreateSlider({ name = "Aura Range", range = {6,40}, value = 15, callback = function(v) Features.AuraRange = v end })
Combat:CreateToggle({ name = "Kill Selected", callback = function(v) Features.KillTarget = v end })

-- TROLL
local Troll = window:CreateTab({ name = "Troll" })
Troll:CreateSection({ name = "Fling" })
Troll:CreateDropdown({ name = "Fling Type", options = {"Normal","Strong","Up"}, callback = function(v) Features.FlingType = DD(v) end })
Troll:CreateToggle({ name = "Fling Nearest", callback = function(v) Features.FlingNearest = v end })
Troll:CreateToggle({ name = "Fling Selected", callback = function(v) Features.FlingTarget = v end })
Troll:CreateToggle({ name = "Fling All", callback = function(v) Features.FlingAll = v end })
Troll:CreateSection({ name = "Carry" })
Troll:CreateToggle({ name = "Piggyback", callback = function(v) Features.Piggyback = v end })
Troll:CreateToggle({ name = "Front Carry", callback = function(v) Features.FrontCarry = v end })
Troll:CreateToggle({ name = "Side Carry", callback = function(v) Features.SideCarry = v end })
Troll:CreateSection({ name = "Self" })
Troll:CreateToggle({ name = "Invisible Self", callback = function(v) Features.Invisible = v; SetInvis(v) end })
Troll:CreateToggle({ name = "Rainbow Self", callback = function(v) Features.RainbowSelf = v end })
Troll:CreateSection({ name = "Target" })
Troll:CreateToggle({ name = "Freeze Target", callback = function(v) Features.FreezeTarget = v end })
Troll:CreateToggle({ name = "Invisible Target", callback = function(v) Features.InvisibleTarget = v end })
Troll:CreateToggle({ name = "Spin Target", callback = function(v) Features.SpinTarget = v end })
Troll:CreateToggle({ name = "Platform Under Target", callback = function(v) Features.PlatformTarget = v end })
Troll:CreateToggle({ name = "Disable Jump (Target)", callback = function(v) Features.DisableJumpTarget = v end })
Troll:CreateToggle({ name = "Disable Movement (Target)", callback = function(v) Features.DisableMoveTarget = v end })
Troll:CreateToggle({ name = "Slow Motion (Target)", callback = function(v) Features.SlowMotionTarget = v end })
Troll:CreateButton({ name = "Force Sit", callback = function() local t = GetTarget(); if t then ForceSit(t) end end })
Troll:CreateButton({ name = "Explode", callback = function() local t = GetTarget(); if t then Explode(t) end end })
Troll:CreateButton({ name = "Push Away", callback = function() local t = GetTarget(); local r1, r2 = GetMyRoot(), GetTargetRoot(); if t and r1 and r2 then PushPull(t, (r1.Position - r2.Position).Unit) end end })
Troll:CreateButton({ name = "Pull Toward", callback = function() local t = GetTarget(); local r1, r2 = GetMyRoot(), GetTargetRoot(); if t and r1 and r2 then PushPull(t, (r2.Position - r1.Position).Unit) end end })
Troll:CreateButton({ name = "Swap Positions", callback = function() local t = GetTarget(); if t then SwapPos(t) end end })
Troll:CreateSection({ name = "Mass" })
Troll:CreateToggle({ name = "Freeze All", callback = function(v) Features.FreezeAll = v end })
Troll:CreateToggle({ name = "Spin All", callback = function(v) Features.SpinAll = v end })
Troll:CreateButton({ name = "Explode All", callback = function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Explode(p) end end end })
Troll:CreateButton({ name = "Fling All", callback = function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Fling(p) end end end })

-- EMOTES
local EmoteTab = window:CreateTab({ name = "Emotes" })
EmoteTab:CreateSection({ name = "Play" })
local emoteNames = {} for _, e in ipairs(EmoteList) do table.insert(emoteNames, e.Name) end
EmoteTab:CreateDropdown({ name = "Emote", options = emoteNames, callback = function(v) local n = DD(v); for _, e in ipairs(EmoteList) do if e.Name == n then Features.SelectedEmote = e.ID end end end })
EmoteTab:CreateInput({ name = "Custom ID", placeholder = "rbxassetid://...", callback = function(t) if t ~= "" then Features.SelectedEmote = t end end })
EmoteTab:CreateButton({ name = "Play on Self", callback = function() if Features.SelectedEmote then clearEmotes(); PlayEmote(LocalPlayer, Features.SelectedEmote) end end })
EmoteTab:CreateButton({ name = "Play on Target", callback = function() local t = GetTarget(); if t and Features.SelectedEmote then clearEmotes(); PlayEmote(t, Features.SelectedEmote) end end })
EmoteTab:CreateButton({ name = "Stop Emotes", callback = clearEmotes })
EmoteTab:CreateButton({ name = "Random Emote", callback = function() if #EmoteList > 0 then local e = EmoteList[math.random(1, #EmoteList)]; clearEmotes(); PlayEmote(LocalPlayer, e.ID) end end })

-- ANTI
local Anti = window:CreateTab({ name = "Anti" })
Anti:CreateToggle({ name = "Anti AFK", callback = function(v) Features.AntiAFK = v end })
Anti:CreateToggle({ name = "Anti Fling", callback = function(v) Features.AntiFling = v end })
Anti:CreateToggle({ name = "Anti Die", callback = function(v) Features.AntiDie = v end })
Anti:CreateToggle({ name = "Anti Void", callback = function(v) Features.AntiVoid = v end })
Anti:CreateToggle({ name = "Anti Sit", callback = function(v) Features.AntiSit = v end })
Anti:CreateToggle({ name = "Anti Ragdoll", callback = function(v) Features.AntiRagdoll = v end })
Anti:CreateToggle({ name = "Anti Trip", callback = function(v) Features.AntiTrip = v end })

--------------------------- OWNER MENU (Fixed Notify) ---------------------------
if IS_OWNER or IS_DEV then
    local OwnerTab = window:CreateTab({ name = "Owner Menu" })

    OwnerTab:CreateSection({ name = "Live Stats" })
    OwnerTab:CreateButton({ name = "Refresh Online Users", callback = function()
        pcall(function()
            local data = sbGet("zuzify_sessions", "last_ping=gt."..HttpService:UrlEncode(DateTime.now():ToIsoDate()).."&select=*")
            local cnt = data and #data or 0
            local lines = {}
            for _, s in ipairs(data or {}) do
                if s.show_username and s.username then table.insert(lines, s.username .. " ("..s.user_id..")")
                else table.insert(lines, "Anonymous #"..tostring(s.user_id):sub(-4)) end
            end
            SendNotify("Online: "..cnt, table.concat(lines, "\n"), 10)
        end)
    end })

    OwnerTab:CreateButton({ name = "Full User Stats", callback = function()
        pcall(function()
            local users = sbGet("zuzify_users", "select=*")
            local total = users and #users or 0
            local paid, trusted, banned = 0,0,0
            for _, u in ipairs(users or {}) do
                if u.is_paid then paid = paid + 1 end
                if u.is_trusted then trusted = trusted + 1 end
                if u.is_banned then banned = banned + 1 end
            end
            SendNotify("Stats", "Total: "..total.."\nPaid: "..paid.."\nTrusted: "..trusted.."\nBanned: "..banned, 10)
        end)
    end })

    OwnerTab:CreateSection({ name = "License Keys" })
    local newTier = "premium"
    local newDays = 30
    OwnerTab:CreateDropdown({ name = "Tier", options = {"basic","premium","trusted","developer"}, callback = function(v) newTier = DD(v) end })
    OwnerTab:CreateSlider({ name = "Duration (days)", range = {1, 3650}, value = 30, callback = function(v) newDays = v end })
    OwnerTab:CreateButton({ name = "Generate Key", callback = function()
        pcall(function()
            local key = "ZUZ-"..string.upper(newTier).."-"..string.upper(HttpService:GenerateGUID(false):sub(1,8))
            sbPost("zuzify_keys", { license_key = key, tier = newTier, created_by = MY_UID, duration_days = newDays, is_active = true })
            SendNotify("Key Created", key, 12)
            if setclipboard then setclipboard(key) end
        end)
    end })
    OwnerTab:CreateButton({ name = "List Active Keys", callback = function()
        pcall(function()
            local d = sbGet("zuzify_keys", "is_active=eq.true&select=license_key,tier,used_by")
            local s = {}
            for _, k in ipairs(d or {}) do table.insert(s, k.license_key.." ["..k.tier.."] "..(k.used_by and ("used by "..k.used_by) or "unused")) end
            SendNotify("Keys", table.concat(s, "\n"), 12)
        end)
    end })

    OwnerTab:CreateSection({ name = "Moderation" })
    local modTarget = ""
    OwnerTab:CreateInput({ name = "Target UserID or Username", placeholder = "1234567 or Username", callback = function(t) modTarget = t end })
    local modReason = ""
    OwnerTab:CreateInput({ name = "Reason", placeholder = "Reason", callback = function(t) modReason = t end })
    OwnerTab:CreateButton({ name = "Kick User", callback = function()
        if modTarget == "" then return end
        pcall(function()
            local q = tonumber(modTarget) and ("user_id=eq."..modTarget) or ("username=eq."..HttpService:UrlEncode(modTarget))
            sbPatch("zuzify_users", q, { kick_signal = true, kick_reason = modReason })
            sbPost("zuzify_mod_log", { action = "kick", target_username = modTarget, moderator_id = MY_UID, reason = modReason })
            SendNotify("Kick Queued", "User will be kicked within 30s.", 6)
        end)
    end })
    local banMins = 60
    OwnerTab:CreateSlider({ name = "Ban Duration (minutes, 0 = perm)", range = {0, 43200}, value = 60, callback = function(v) banMins = v end })
    OwnerTab:CreateButton({ name = "Ban User", callback = function()
        if modTarget == "" then return end
        pcall(function()
            local until_ = banMins > 0 and DateTime.now():AddSeconds(banMins*60):ToIsoDate() or nil
            local q = tonumber(modTarget) and ("user_id=eq."..modTarget) or ("username=eq."..HttpService:UrlEncode(modTarget))
            sbPatch("zuzify_users", q, { is_banned = true, ban_reason = modReason, ban_until = until_ })
            sbPost("zuzify_mod_log", { action = "ban", target_username = modTarget, moderator_id = MY_UID, reason = modReason, duration_minutes = banMins })
            SendNotify("Ban Applied", "User banned.", 6)
        end)
    end })
    OwnerTab:CreateButton({ name = "Unban User", callback = function()
        if modTarget == "" then return end
        pcall(function()
            local q = tonumber(modTarget) and ("user_id=eq."..modTarget) or ("username=eq."..HttpService:UrlEncode(modTarget))
            sbPatch("zuzify_users", q, { is_banned = false, ban_reason = nil, ban_until = nil })
            sbPost("zuzify_mod_log", { action = "unban", target_username = modTarget, moderator_id = MY_UID })
            SendNotify("Unbanned", "User unbanned.", 6)
        end)
    end })
end

--------------------------- BOOT NOTIFY ---------------------------
SendNotify("ZuzifyRBX "..VERSION, "Welcome "..MY_USERNAME.."! Tier: "..string.upper(acquiredTier)..
    (IS_OWNER and " • OWNER" or "")..
    (IS_DEV and " • DEV" or ""), 10)

print("[ZuzifyRBX] Loaded", VERSION, "| Tier:", acquiredTier)
