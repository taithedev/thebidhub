--[[
    ╔═══════════════════════════════════════════════════╗
    ║   ZuzifyRBX Gen7.0.0 — ULTIMATE EDITION           ║
    ║   60 Themes • Mod Menu • Audit Logs • Auto Config ║
    ║   Key format: ZUZIFY-XXXX-XXXX-XXXX               ║
    ╚═══════════════════════════════════════════════════╝
]]

--------------------------- CONFIG ---------------------------
local VERSION  = "Gen7.0.0"
local CREDITS  = "Owner: mrcoptai (717544874) • UI: Rayfield • Backend: Supabase"
local CONFIG_FILE = "ZuzifyRBX_Gen7"

-- ⚠️ REPLACE THESE
local SUPABASE_URL       = "https://hfxpuqvishbfqlwxnnpe.supabase.co"
local SUPABASE_ANON_KEY  = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhmeHB1cXZpc2hiZnFsd3hubnBlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkwNzkyMTUsImV4cCI6MjEwNDY1NTIxNX0.p8YyuvBhAw45YmKc-o-iMyvKKTPDEdKdnBfT2EUGx18"

local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1467436721951084792/KYX4LUdBw4K2i2Bpwc4UZRSF1JRNJ0Banw1KK1xrQzjPHXMh0DLIQ0Rs8giXVISjqwt0"

-- Owner UIDs (always full access)
local OWNER_UIDS = { 717544874 }

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
local MY_UID      = LocalPlayer.UserId
local MY_USERNAME = LocalPlayer.Name

--------------------------- HTTP ---------------------------
local httpReq = http_request or request or (syn and syn.request) or (http and http.request)

local function http(method, url, headers, body)
    if not httpReq then return nil end
    local opts = { Url = url, Method = method, Headers = headers or {} }
    if body then
        opts.Body = type(body) == "string" and body or HttpService:JSONEncode(body)
        opts.Headers["Content-Type"] = "application/json"
    end
    for attempt = 1, 3 do
        local ok, res = pcall(httpReq, opts)
        if ok and res then
            local decoded
            pcall(function() decoded = HttpService:JSONDecode(res.Body) end)
            return decoded, res.StatusCode
        end
        task.wait(0.3)
    end
    return nil
end

local function sbHeaders(extra)
    local h = {
        ["apikey"]        = SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. SUPABASE_ANON_KEY,
        ["Content-Type"]  = "application/json",
        ["Prefer"]        = "return=representation",
    }
    if extra then for k,v in pairs(extra) do h[k] = v end end
    return h
end

local function sbGet(t, q)     return http("GET",   SUPABASE_URL .. "/rest/v1/" .. t .. (q and ("?"..q) or ""), sbHeaders()) end
local function sbPost(t, b)    return http("POST",  SUPABASE_URL .. "/rest/v1/" .. t, sbHeaders(), b) end
local function sbPatch(t, q, b)return http("PATCH", SUPABASE_URL .. "/rest/v1/" .. t .. "?" .. q, sbHeaders(), b) end
local function sbDelete(t, q)  return http("DELETE",SUPABASE_URL .. "/rest/v1/" .. t .. "?" .. q, sbHeaders()) end

local function nowISO()
    return DateTime.now():ToIsoDate()
end

local function DD(v) if type(v) == "table" then return v[1] or tostring(v[1]) end return v end

--------------------------- ROLE HELPERS ---------------------------
local ROLE_ORDER = {
    user = 0, free = 0,
    basic = 1,
    premium = 2, trusted = 2,
    mod = 3,
    admin = 4, developer = 4,
    owner = 5,
}

local function HasTier(current, min)
    return (ROLE_ORDER[current] or 0) >= (ROLE_ORDER[min] or 0)
end

--------------------------- DISCLAIMER POPUP ---------------------------
local function showDisclaimer()
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZuzifyRBX_Disclaimer"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(1,0,1,0); overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency = 0.4; overlay.BorderSizePixel = 0; overlay.Parent = gui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 640, 0, 500)
    frame.Position = UDim2.new(0.5, -320, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(10,10,14); frame.BorderSizePixel = 0; frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(0,200,160); stroke.Thickness = 1.5; stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,-40,0,44); title.Position = UDim2.new(0,20,0,16)
    title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX "..VERSION.." — Disclaimer"
    title.TextColor3 = Color3.fromRGB(0,220,180); title.Font = Enum.Font.GothamBold
    title.TextSize = 22; title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = frame

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1,-40,0,320); body.Position = UDim2.new(0,20,0,66)
    body.BackgroundTransparency = 1; body.TextColor3 = Color3.fromRGB(220,220,230)
    body.Font = Enum.Font.Gotham; body.TextSize = 14; body.TextWrapped = true
    body.TextXAlignment = Enum.TextXAlignment.Left; body.TextYAlignment = Enum.TextYAlignment.Top
    body.Text = table.concat({
        "Before using ZuzifyRBX, please read and accept:",
        "",
        "• ZuzifyRBX is a third-party script. Use is at your OWN RISK.",
        "• You must comply with the Roblox Terms of Service.",
        "• ZuzifyRBX is NOT responsible for any bans, kicks, or damages.",
        "• Data collected: UserID + username (for licensing, moderation, anonymous stats).",
        "• Username is NOT publicly shown unless you enable 'Share Username' (Trusted Program).",
        "• You may be banned for misuse. Bans can be permanent or timed.",
        "• You must be 13+ to use this script.",
        "• By clicking ACCEPT you take full responsibility for your actions.",
    }, "\n")
    body.Parent = frame

    local accept = Instance.new("TextButton")
    accept.Size = UDim2.new(0.45, -30, 0, 46); accept.Position = UDim2.new(0, 20, 1, -66)
    accept.BackgroundColor3 = Color3.fromRGB(0,160,130); accept.Text = "ACCEPT"
    accept.TextColor3 = Color3.fromRGB(255,255,255); accept.Font = Enum.Font.GothamBold
    accept.TextSize = 16; accept.Parent = frame
    Instance.new("UICorner", accept).CornerRadius = UDim.new(0, 10)

    local decline = Instance.new("TextButton")
    decline.Size = UDim2.new(0.45, -30, 0, 46); decline.Position = UDim2.new(0.5, 10, 1, -66)
    decline.BackgroundColor3 = Color3.fromRGB(160,40,50); decline.Text = "DECLINE"
    decline.TextColor3 = Color3.fromRGB(255,255,255); decline.Font = Enum.Font.GothamBold
    decline.TextSize = 16; decline.Parent = frame
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
    gui.Name = "ZuzifyRBX_License"; gui.ResetOnSpawn = false; gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 540, 0, 400)
    frame.Position = UDim2.new(0.5, -270, 0.5, -200)
    frame.BackgroundColor3 = Color3.fromRGB(8,8,12); frame.BorderSizePixel = 0; frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke"); stroke.Color = Color3.fromRGB(0,200,160); stroke.Thickness = 1.5; stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1,0,0,44); title.BackgroundTransparency = 1
    title.Text = "ZuzifyRBX "..VERSION.." — Activation"
    title.TextColor3 = Color3.fromRGB(0,220,180); title.Font = Enum.Font.GothamBold
    title.TextSize = 20; title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1,-40,0,80); status.Position = UDim2.new(0,20,0,50)
    status.BackgroundTransparency = 1
    status.Text = "Enter your license key (Format: ZUZIFY-XXXX-XXXX-XXXX)\nor click Continue for the FREE tier.\n\nFree tier: limited features. Paid tiers unlock everything + mod tools."
    status.TextColor3 = Color3.fromRGB(200,200,215); status.Font = Enum.Font.Gotham
    status.TextSize = 13; status.TextWrapped = true; status.Parent = frame

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.9, 0, 0, 42); box.Position = UDim2.new(0.05, 0, 0.45, 0)
    box.BackgroundColor3 = Color3.fromRGB(16,16,20); box.TextColor3 = Color3.fromRGB(255,255,255)
    box.PlaceholderText = "ZUZIFY-0000-0000-0001"; box.Font = Enum.Font.Gotham
    box.TextSize = 15; box.ClearTextOnFocus = false; box.Parent = frame
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1,-40,0,22); msg.Position = UDim2.new(0,20,0.45,50)
    msg.BackgroundTransparency = 1; msg.Text = ""; msg.TextColor3 = Color3.fromRGB(255,120,120)
    msg.Font = Enum.Font.Gotham; msg.TextSize = 13; msg.Parent = frame

    local activate = Instance.new("TextButton")
    activate.Size = UDim2.new(0.44,-20,0,46); activate.Position = UDim2.new(0.05,0,0.80,0)
    activate.BackgroundColor3 = Color3.fromRGB(0,160,130); activate.Text = "Activate Key"
    activate.TextColor3 = Color3.fromRGB(255,255,255); activate.Font = Enum.Font.GothamBold
    activate.TextSize = 15; activate.Parent = frame
    Instance.new("UICorner", activate).CornerRadius = UDim.new(0,8)

    local skip = Instance.new("TextButton")
    skip.Size = UDim2.new(0.44,-20,0,46); skip.Position = UDim2.new(0.51,0,0.80,0)
    skip.BackgroundColor3 = Color3.fromRGB(40,40,48); skip.Text = "Continue Free"
    skip.TextColor3 = Color3.fromRGB(230,230,240); skip.Font = Enum.Font.GothamBold
    skip.TextSize = 15; skip.Parent = frame
    Instance.new("UICorner", skip).CornerRadius = UDim.new(0,8)

    local result = { done = false, tier = "free", key = nil, role = "user" }

    activate.MouseButton1Click:Connect(function()
        local key = string.upper((box.Text:gsub("%s","")))
        if not key:match("^ZUZIFY%-%w+%-%w+%-%w+$") and #key < 10 then
            msg.Text = "Format: ZUZIFY-XXXX-XXXX-XXXX"; return
        end
        msg.Text = "Checking…"; msg.TextColor3 = Color3.fromRGB(200,200,100)
        task.spawn(function()
            local data = sbGet("zuzify_keys", "license_key=eq."..HttpService:UrlEncode(key).."&select=*")
            if not data or #data == 0 then
                msg.Text = "Invalid license key."; msg.TextColor3 = Color3.fromRGB(255,120,120); return
            end
            local k = data[1]
            if not k.is_active then msg.Text = "Key deactivated."; return end
            if k.used_by and k.used_by ~= MY_UID then msg.Text = "Key already used."; return end
            if k.expires_at then
                local exp = DateTime.fromIsoDate(k.expires_at)
                if exp and exp.UnixTimestamp < os.time() then
                    msg.Text = "Key expired."; return
                end
            end
            -- Redeem
            local expISO = nil
            if k.duration_days and k.duration_days > 0 then
                expISO = DateTime.now():AddSeconds(k.duration_days * 86400):ToIsoDate()
            end
            sbPatch("zuzify_keys", "license_key=eq."..HttpService:UrlEncode(key),
                { used_by = MY_UID, used_at = nowISO(), expires_at = expISO })
            sbPost("zuzify_key_redemptions",
                { license_key = key, user_id = MY_UID, username = MY_USERNAME, tier = k.tier })
            result.tier  = k.tier or "basic"
            result.key   = key
            result.role  = (k.tier == "owner" or k.tier == "developer") and k.tier or
                           (k.tier == "mod" and "mod") or "user"
            result.done  = true
            gui:Destroy()
        end)
    end)

    skip.MouseButton1Click:Connect(function()
        result.done = true; gui:Destroy()
    end)

    while not result.done do task.wait(0.1) end
    return result.tier, result.key, result.role
end

local acquiredTier, acquiredKey, acquiredRole = showLicensePopup()

--------------------------- USER REGISTRATION ---------------------------
local IS_OWNER = table.find(OWNER_UIDS, MY_UID) ~= nil
if IS_OWNER then acquiredTier, acquiredRole = "owner", "owner" end

local function registerUser()
    local payload = {
        user_id = MY_UID,
        username = MY_USERNAME,
        license_key = acquiredKey,
        tier = acquiredTier,
        role = acquiredRole,
        is_paid = acquiredTier ~= "free",
        last_seen = nowISO(),
    }
    local data = sbGet("zuzify_users", "user_id=eq."..MY_UID.."&select=*")
    if data and #data > 0 then
        local cur = data[1]
        -- Owner/dev override always wins
        if IS_OWNER then
            payload.tier, payload.role = "owner", "owner"
        else
            -- Preserve higher role if server has it
            if cur.role and (ROLE_ORDER[cur.role] or 0) > (ROLE_ORDER[payload.role] or 0) then
                payload.role = cur.role
            end
            if cur.tier and (ROLE_ORDER[cur.tier] or 0) > (ROLE_ORDER[payload.tier] or 0) then
                payload.tier = cur.tier
            end
        end
        sbPatch("zuzify_users", "user_id=eq."..MY_UID, payload)
        return cur
    else
        local created = sbPost("zuzify_users", payload)
        if created and #created > 0 then return created[1] end
    end
    return nil
end

local userRow = registerUser() or {
    tier = acquiredTier, role = acquiredRole,
    is_trusted = false, show_username = false, is_banned = false, warn_count = 0,
}

if userRow.is_banned then
    LocalPlayer:Kick("ZuzifyRBX: Banned. Reason: "..(userRow.ban_reason or "No reason"))
    return
end

local MY_ROLE = userRow.role or acquiredRole or "user"
local MY_TIER = userRow.tier or acquiredTier or "free"

local function HasRole(r) return HasTier(MY_ROLE, r) or HasTier(MY_TIER, r) end
local function IsStaff() return HasRole("mod") end

--------------------------- ACTION LOG (client) ---------------------------
local ActionLog = {}
local function LogAction(action, detail)
    table.insert(ActionLog, { t = os.time(), a = action, d = detail })
    if #ActionLog > 200 then table.remove(ActionLog, 1) end
    print("[ZuzifyRBX]["..action.."]", detail or "")
end

--------------------------- HEARTBEAT ---------------------------
local JOB_ID = game.JobId
local PLACE_ID = game.PlaceId
local sessionId = nil
local lastServerRole = MY_ROLE

task.spawn(function()
    while true do
        pcall(function()
            if not sessionId then
                local created = sbPost("zuzify_sessions", {
                    user_id = MY_UID,
                    username = userRow.show_username and MY_USERNAME or nil,
                    show_username = userRow.show_username or false,
                    role = MY_ROLE, tier = MY_TIER,
                    place_id = PLACE_ID, job_id = JOB_ID, client_version = VERSION,
                })
                if created and #created > 0 then sessionId = created[1].id end
            else
                sbPatch("zuzify_sessions", "id=eq."..sessionId, { last_ping = nowISO() })
            end

            local me = sbGet("zuzify_users",
                "user_id=eq."..MY_UID.."&select=is_banned,ban_reason,kick_signal,kick_reason,role,tier,is_trusted,warn_count")
            if me and #me > 0 then
                local m = me[1]
                if m.is_banned then
                    LocalPlayer:Kick("ZuzifyRBX: Banned. Reason: "..(m.ban_reason or "No reason"))
                end
                if m.kick_signal then
                    sbPatch("zuzify_users", "user_id=eq."..MY_UID, { kick_signal = false, kick_reason = "" })
                    LocalPlayer:Kick("ZuzifyRBX: "..(m.kick_reason or "Kicked by staff."))
                end
                if m.role ~= lastServerRole then
                    lastServerRole = m.role
                    MY_ROLE = m.role or MY_ROLE
                end
                if m.tier and m.tier ~= MY_TIER then MY_TIER = m.tier end
                if m.is_trusted ~= nil then userRow.is_trusted = m.is_trusted end
                if m.warn_count then userRow.warn_count = m.warn_count end
            end
        end)
        task.wait(30)
    end
end)

--------------------------- 60 THEMES ---------------------------
local function T(accent, bg1, bg2)
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
    ["OLED Dark"]   = T(Color3.fromRGB(0,210,170)),
    ["Midnight"]    = T(Color3.fromRGB(90,140,255), Color3.fromRGB(10,12,24), Color3.fromRGB(16,18,36)),
    ["Crimson"]     = T(Color3.fromRGB(255,55,75),  Color3.fromRGB(16,8,10),  Color3.fromRGB(28,12,16)),
    ["Ocean"]       = T(Color3.fromRGB(0,190,220),  Color3.fromRGB(6,16,24),  Color3.fromRGB(10,28,40)),
    ["Purple"]      = T(Color3.fromRGB(160,80,255), Color3.fromRGB(14,8,24),  Color3.fromRGB(24,14,40)),
    ["Gold"]        = T(Color3.fromRGB(255,190,50), Color3.fromRGB(16,14,6),  Color3.fromRGB(28,24,10)),
    ["Pink"]        = T(Color3.fromRGB(255,105,180),Color3.fromRGB(18,10,16), Color3.fromRGB(32,16,28)),
    ["Matrix"]      = T(Color3.fromRGB(0,255,70),   Color3.fromRGB(2,8,2),    Color3.fromRGB(4,16,4)),
    ["Abyss"]       = T(Color3.fromRGB(40,80,255),  Color3.fromRGB(2,4,12),   Color3.fromRGB(6,10,24)),
    ["Mono"]        = T(Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0),    Color3.fromRGB(18,18,18)),
    ["Neon"]        = T(Color3.fromRGB(255,0,200),  Color3.fromRGB(10,0,20),  Color3.fromRGB(20,0,40)),
    ["Cyberpunk"]   = T(Color3.fromRGB(255,0,255),  Color3.fromRGB(8,0,16),   Color3.fromRGB(16,0,32)),
    ["Sunset"]      = T(Color3.fromRGB(255,100,0),  Color3.fromRGB(30,10,0),  Color3.fromRGB(50,20,0)),
    ["Forest"]      = T(Color3.fromRGB(0,200,100),  Color3.fromRGB(2,16,8),   Color3.fromRGB(4,24,12)),
    ["Pastel"]      = T(Color3.fromRGB(200,150,255),Color3.fromRGB(30,20,40), Color3.fromRGB(50,35,60)),
    ["Galaxy"]      = T(Color3.fromRGB(100,50,255), Color3.fromRGB(6,4,20),   Color3.fromRGB(12,8,36)),
    ["Lava"]        = T(Color3.fromRGB(255,80,0),   Color3.fromRGB(20,4,0),   Color3.fromRGB(40,8,0)),
    ["Ice"]         = T(Color3.fromRGB(0,200,255),  Color3.fromRGB(4,12,20),  Color3.fromRGB(8,20,36)),
    ["Sand"]        = T(Color3.fromRGB(200,170,120),Color3.fromRGB(20,16,12), Color3.fromRGB(36,28,20)),
    ["Rose"]        = T(Color3.fromRGB(255,80,120), Color3.fromRGB(20,8,12),  Color3.fromRGB(36,12,20)),
    ["Lime"]        = T(Color3.fromRGB(150,255,50), Color3.fromRGB(8,16,4),   Color3.fromRGB(16,28,8)),
    ["Candy"]       = T(Color3.fromRGB(255,150,200),Color3.fromRGB(24,8,16),  Color3.fromRGB(40,12,28)),
    ["Retro"]       = T(Color3.fromRGB(255,200,50), Color3.fromRGB(16,12,8),  Color3.fromRGB(28,20,12)),
    ["Vaporwave"]   = T(Color3.fromRGB(255,0,150),  Color3.fromRGB(12,0,24),  Color3.fromRGB(24,0,48)),
    ["Synthwave"]   = T(Color3.fromRGB(255,100,255),Color3.fromRGB(8,4,16),   Color3.fromRGB(16,8,32)),
    ["Solar"]       = T(Color3.fromRGB(255,150,0),  Color3.fromRGB(20,12,0),  Color3.fromRGB(36,20,0)),
    ["Lunar"]       = T(Color3.fromRGB(150,150,200),Color3.fromRGB(12,12,16), Color3.fromRGB(20,20,28)),
    ["Inferno"]     = T(Color3.fromRGB(255,50,0),   Color3.fromRGB(20,4,0),   Color3.fromRGB(40,8,0)),
    ["Arctic"]      = T(Color3.fromRGB(100,200,255),Color3.fromRGB(6,12,20),  Color3.fromRGB(10,20,36)),
    ["Mint"]        = T(Color3.fromRGB(100,255,180),Color3.fromRGB(4,16,10),  Color3.fromRGB(8,28,18)),
    ["Lavender"]    = T(Color3.fromRGB(200,150,255),Color3.fromRGB(14,8,24),  Color3.fromRGB(24,14,40)),
    ["Copper"]      = T(Color3.fromRGB(200,120,50), Color3.fromRGB(16,12,8),  Color3.fromRGB(28,20,12)),
    ["Silver"]      = T(Color3.fromRGB(180,180,200),Color3.fromRGB(12,12,14), Color3.fromRGB(20,20,24)),
    ["Emerald"]     = T(Color3.fromRGB(50,200,100), Color3.fromRGB(4,16,8),   Color3.fromRGB(8,28,14)),
    ["Ruby"]        = T(Color3.fromRGB(200,50,50),  Color3.fromRGB(16,4,4),   Color3.fromRGB(28,8,8)),
    ["Sapphire"]    = T(Color3.fromRGB(50,100,255), Color3.fromRGB(4,8,20),   Color3.fromRGB(8,14,36)),
    ["Amber"]       = T(Color3.fromRGB(255,180,50), Color3.fromRGB(16,12,4),  Color3.fromRGB(28,20,8)),
    ["Jade"]        = T(Color3.fromRGB(100,255,150),Color3.fromRGB(4,16,8),   Color3.fromRGB(8,28,14)),
    ["Pearl"]       = T(Color3.fromRGB(255,240,220),Color3.fromRGB(16,14,12), Color3.fromRGB(28,24,20)),
    ["Obsidian"]    = T(Color3.fromRGB(180,180,200),Color3.fromRGB(2,2,4),    Color3.fromRGB(6,6,12)),
    ["Blood"]       = T(Color3.fromRGB(180,20,30),  Color3.fromRGB(14,2,4),   Color3.fromRGB(28,4,8)),
    ["Toxic"]       = T(Color3.fromRGB(120,255,40), Color3.fromRGB(6,14,2),   Color3.fromRGB(12,26,4)),
    ["Nebula"]      = T(Color3.fromRGB(200,100,255),Color3.fromRGB(10,4,26),  Color3.fromRGB(20,8,44)),
    ["Storm"]       = T(Color3.fromRGB(120,160,200),Color3.fromRGB(10,14,20), Color3.fromRGB(18,24,34)),
    ["Aurora"]      = T(Color3.fromRGB(80,255,200), Color3.fromRGB(4,14,14),  Color3.fromRGB(8,28,28)),
    ["Holographic"] = T(Color3.fromRGB(255,100,255),Color3.fromRGB(2,2,8),    Color3.fromRGB(6,4,20)),
    ["Matcha"]      = T(Color3.fromRGB(120,200,90), Color3.fromRGB(8,16,8),   Color3.fromRGB(16,28,16)),
    ["Cherry"]      = T(Color3.fromRGB(200,30,80),  Color3.fromRGB(20,4,10),  Color3.fromRGB(36,8,18)),
    ["Volcano"]     = T(Color3.fromRGB(255,60,20),  Color3.fromRGB(24,6,0),   Color3.fromRGB(44,12,0)),
    ["Glacier"]     = T(Color3.fromRGB(150,230,255),Color3.fromRGB(6,14,24),  Color3.fromRGB(12,24,42)),
    ["Coral"]       = T(Color3.fromRGB(255,120,130),Color3.fromRGB(20,8,10),  Color3.fromRGB(36,16,20)),
    ["Steel"]       = T(Color3.fromRGB(140,150,170),Color3.fromRGB(14,16,22), Color3.fromRGB(24,28,36)),
    ["Peach"]       = T(Color3.fromRGB(255,180,140),Color3.fromRGB(22,14,10), Color3.fromRGB(38,24,18)),
    ["Taro"]        = T(Color3.fromRGB(180,160,255),Color3.fromRGB(14,12,26), Color3.fromRGB(24,20,44)),
    ["Basil"]       = T(Color3.fromRGB(60,180,60),  Color3.fromRGB(6,14,6),   Color3.fromRGB(12,26,12)),
    ["Firefly"]     = T(Color3.fromRGB(255,230,60), Color3.fromRGB(14,14,4),  Color3.fromRGB(26,26,8)),
    ["Deep Space"]  = T(Color3.fromRGB(60,60,200),  Color3.fromRGB(2,2,10),   Color3.fromRGB(4,4,22)),
    ["Chrome"]      = T(Color3.fromRGB(200,200,220),Color3.fromRGB(20,20,24), Color3.fromRGB(32,32,40)),
    ["Kawaii"]      = T(Color3.fromRGB(255,180,220),Color3.fromRGB(22,10,18), Color3.fromRGB(38,18,30)),
    ["Zen"]         = T(Color3.fromRGB(120,180,140),Color3.fromRGB(8,14,12),  Color3.fromRGB(16,26,22)),
}
local ThemeNames = {}
for k in pairs(Themes) do table.insert(ThemeNames, k) end
table.sort(ThemeNames)

--------------------------- RAYFIELD UI ---------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

--------------------------- NOTIFY WRAPPER ---------------------------
-- Rayfield requires capitalized keys: Title, Content, Duration, Image
local function N(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title    = tostring(title or "ZuzifyRBX"),
            Content  = tostring(content or ""),
            Duration = tonumber(duration) or 6,
            Image    = 4483362458,
        })
    end)
    LogAction("notify", tostring(title).." — "..tostring(content))
end

--------------------------- CONFIGURATION ---------------------------
local ConfigState = {
    AutoSave = true,
    AutoLoad = true,
}

-- Auto-load at boot
if ConfigState.AutoLoad then
    pcall(function() Rayfield:LoadConfiguration() end)
end

--------------------------- WINDOW ---------------------------
local window = Rayfield:CreateWindow({
    name = "ZuzifyRBX ["..string.upper(MY_TIER).."]",
    subtitle = VERSION.." • "..CREDITS,
    theme = Themes["OLED Dark"],
    configuration = { autoSave = false, autoLoad = false, fileName = CONFIG_FILE },
})

local function SaveConfig()
    pcall(function() Rayfield:SaveConfiguration(CONFIG_FILE) end)
    N("Config", "Configuration saved.", 5)
end
local function LoadConfig()
    pcall(function() Rayfield:LoadConfiguration(CONFIG_FILE) end)
    N("Config", "Configuration loaded.", 5)
end
local function ResetConfig()
    pcall(function() Rayfield:ResetConfiguration() end)
    N("Config", "Configuration reset. Rejoin to fully apply.", 6)
end

--------------------------- FEATURES TABLE ---------------------------
local F = {
    -- ESP
    ESP=false, ESP_Names=true, ESP_Distance=true, ESP_Health=true, ESP_Weapon=true,
    ESP_Chams=true, ESP_Boxes=true, ESP_Tracers=false, ESP_Skeleton=false, ESP_Team=true,
    -- Visual
    Fullbright=false, CustomFOV=70,
    -- Movement
    NoclipType="None", FlyType="None", FlySpeed=60, InfiniteJump=false,
    WalkSpeed=16, JumpPower=50, SpeedBoost=false, SuperJump=false,
    HitboxExtender=false, HitboxSize=9, LowGravity=false, BunnyHop=false,
    CFrameSpeed=false, CFrameSpeedValue=2, Spin=false, Wallclimb=false,
    Dash=false, DashPower=30, TeleportToMouse=false,
    -- Combat
    Aimbot=false, SilentAim=false, AimbotFOV=230, AimbotSmooth=0.13, AimbotPrediction=0.14,
    AimPart="HumanoidRootPart", AutoKill=false, KnifeAura=false, AuraRange=15,
    SelectedTarget=nil, KillTarget=false, AutoShoot=false,
    -- Game
    CoinFarm=false, GrabGun=false, GunESP=false, TPMurderer=false, TPSheriff=false,
    MurderWalk=false, FollowSheriff=false,
    -- Troll
    Piggyback=false, FrontCarry=false, SideCarry=false,
    FlingType="Normal", FlingNearest=false, FlingAll=false, FlingTarget=false,
    Invisible=false, GlitchSelf=false, Orbit=false, OrbitSpeed=8, OrbitDist=6,
    LoopBehind=false, SkyPlatform=false, AnnoyAura=false, BounceTarget=false,
    FreezeTarget=false, InvisibleTarget=false, RainbowSelf=false,
    SpinTarget=false, PlatformTarget=false, DisableJumpTarget=false, DisableMoveTarget=false,
    FreezeAll=false, SpinAll=false, SlowMotionTarget=false,
    -- Cheese
    ShowCodes=false, ShowKeys=false, ShowCheese=false, ShowDoors=false,
    RatESP=false, AutoCheese=false,
    -- Anti
    AntiAFK=true, AntiFling=true, AntiDie=false, AntiVoid=false, AntiSit=false,
    AntiRagdoll=false, AntiTrip=false,
    -- Emotes
    SelectedEmote=nil, DanceParty=false,
    -- Privacy
    ShareUsername = userRow.show_username or false,
}

local function pushUserUpdate(patch)
    sbPatch("zuzify_users", "user_id=eq."..MY_UID, patch)
    if sessionId then sbPatch("zuzify_sessions", "id=eq."..sessionId, patch) end
end

--------------------------- EMOTES ---------------------------
local EmoteList = {}
local function E(n, i) table.insert(EmoteList, {Name=n, ID=i}) end
local ids = {"507770620","507771112","507771612","507771366","507771049","507771682","507771410","507771276","507771842","507771453","507771054","507771815","507771568","507771147","507771731","507771174","507771878","507771594","507771358","507771270","507771697","507771597","507771482","507771702","507771501","507771205","507771295","507771100","507771650","507771467","507771406","507771537","507771339","507771266","507771490","507771831","507771771","507771647","507771060","507771152","507771554","507771536","507771715","507771080","507771398","507771911","507771551","507771756","507771692","507771357","507771226","507771022","507771582","507771620","507771769","507771670","507771364","507771279","507771019","507771790","507771307","507771591","507771494","507771674","507771837","507771457","507771109","507771547","507771305","507771827","507771183","507771466","507771706","507771174","507771217","507771330","507771476","507771215","507771679","507771865","507771093","507771585","507771660","507771803","507771329","507771491","507771259","507771716","507771053","507771128","507771640","507771597","507771091","507771767","507771412","507771010","507771210","507771315","507771505","507771605"}
local names = {"Dance","Robot","Floss","Twist","Whip","Wave","Point","Salute","Sit","Lay","Dab","Gangnam","Macarena","Harlem","Running Man","T-Pose","Cossack","Ballet","Sword","Karate","Boxing","Fencing","Taekwondo","Yoga","Breakdance","Moonwalk","Shuffle","Charleston","Tango","Waltz","Salsa","Mambo","Cha Cha","Rumba","Zumba","Hip Hop","Popping","Locking","Waacking","Voguing","Krumping","House","Industrial","Electro","Techno","Trance","Dubstep","Drum & Bass","Jazz","Tap","Modern","Contemporary","Lyrical","Musical","Ballroom","Swing","Lindy Hop","Jive","Boogie","Rock & Roll","Mosh","Circle Pit","Wall of Death","Clap","Cheer","Cry","Laugh","Shrug","Faint","Roar","Scream","Snap","Stomp","Thriller","Disco","Funky","Smooth","Cool","Attitude","Confused","Nervous","Shy","Sassy","Angry","Sad","Happy","Surprised","Disgusted","Fear","Pride","Love","Peace","Victory","Spin","Float","Kick","Punch","Jump","Slide","Backflip","Frontflip"}
local i=0
for k=1,#names do i=i+1; E(names[k].." "..i, "rbxassetid://"..ids[((k-1)%#ids)+1]) end
for k=1,200 do i=i+1; E("Extra Emote "..i, "rbxassetid://"..ids[((k-1)%#ids)+1]..math.random(10,99)) end

--------------------------- HELPERS ---------------------------
local RoleColors = { Murderer=Color3.fromRGB(255,55,55), Sheriff=Color3.fromRGB(55,145,255), Innocent=Color3.fromRGB(55,230,100) }
local MapTeleports = { Lobby=Vector3.new(-110,140,40), Bank=Vector3.new(0,5,0), Hotel=Vector3.new(50,5,0), Hospital=Vector3.new(-50,5,0), Office=Vector3.new(0,5,50), House=Vector3.new(30,5,-30), Museum=Vector3.new(20,5,40), Laboratory=Vector3.new(-40,5,-20) }
local CachedRoles = {}

local function GetRole(plr)
    if not plr then return "Innocent" end
    local c = CachedRoles[plr]; if c and tick()-c.t < 0.5 then return c.r end
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
local function GetTarget() if not F.SelectedTarget then return nil end return Players:FindFirstChild(F.SelectedTarget) end
local function GetTargetRoot() local t=GetTarget(); if not t then return nil end return t.Character and t.Character:FindFirstChild("HumanoidRootPart") end
local function GetClosest(maxD)
    local r = GetMyRoot(); if not r then return nil end
    local best, bd = nil, maxD or 9999
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local h  = p.Character:FindFirstChildOfClass("Humanoid")
            if tr and h and h.Health > 0 then
                local d = (r.Position - tr.Position).Magnitude
                if d < bd then bd=d; best=p end
            end
        end
    end
    return best
end

--------------------------- ESP ---------------------------
local ESPObjects = {}
local function clearESP(plr) if ESPObjects[plr] then for _, o in pairs(ESPObjects[plr]) do pcall(function() if o and o.Parent then o:Destroy() end end) end ESPObjects[plr]=nil end end
local function clearAllESP() for p in pairs(ESPObjects) do clearESP(p) end end

local function createESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    local char = plr.Character; if not char then return end
    local head, root = char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
    if not head or not root then return end
    local role = GetRole(plr); local color = RoleColors[role] or RoleColors.Innocent; local o={}
    local bb = Instance.new("BillboardGui"); bb.Adornee=head; bb.Size=UDim2.new(0,280,0,110); bb.StudsOffset=Vector3.new(0,3.2,0); bb.AlwaysOnTop=true; bb.Parent=head
    local nameL = Instance.new("TextLabel"); nameL.Size=UDim2.new(1,0,0.35,0); nameL.BackgroundTransparency=1; nameL.Text=plr.Name.." ["..role.."]"; nameL.TextColor3=color; nameL.TextStrokeTransparency=0.1; nameL.Font=Enum.Font.GothamBold; nameL.TextSize=14; nameL.Parent=bb
    local distL = Instance.new("TextLabel"); distL.Size=UDim2.new(1,0,0.2,0); distL.Position=UDim2.new(0,0,0.35,0); distL.BackgroundTransparency=1; distL.Text="0"; distL.TextColor3=color; distL.Font=Enum.Font.Gotham; distL.TextSize=12; distL.Parent=bb
    local hpL   = Instance.new("TextLabel"); hpL.Size=UDim2.new(1,0,0.2,0); hpL.Position=UDim2.new(0,0,0.55,0); hpL.BackgroundTransparency=1; hpL.Text="HP: 100"; hpL.TextColor3=Color3.fromRGB(0,255,0); hpL.Font=Enum.Font.Gotham; hpL.TextSize=12; hpL.Parent=bb
    local wpL   = Instance.new("TextLabel"); wpL.Size=UDim2.new(1,0,0.25,0); wpL.Position=UDim2.new(0,0,0.75,0); wpL.BackgroundTransparency=1; wpL.Text=""; wpL.TextColor3=Color3.fromRGB(255,255,255); wpL.Font=Enum.Font.Gotham; wpL.TextSize=11; wpL.Parent=bb
    o.Billboard, o.NameLabel, o.DistLabel, o.HealthLabel, o.WeaponLabel = bb, nameL, distL, hpL, wpL
    if F.ESP_Chams then local hl=Instance.new("Highlight"); hl.Adornee=char; hl.FillColor=color; hl.OutlineColor=color; hl.FillTransparency=0.4; hl.OutlineTransparency=0; hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char; o.Highlight=hl end
    if F.ESP_Boxes then local bx=Instance.new("BoxHandleAdornment"); bx.Adornee=root; bx.Size=Vector3.new(4,6,2); bx.Color3=color; bx.Transparency=0.5; bx.AlwaysOnTop=true; bx.Parent=root; o.Box=bx end
    ESPObjects[plr]=o
end

local function refreshESP()
    clearAllESP()
    if not F.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer then pcall(createESP, plr) end end
end

--------------------------- TROLLS ---------------------------
local function Fling(plr)
    pcall(function()
        if not plr or not plr.Character then return end
        local r = plr.Character:FindFirstChild("HumanoidRootPart"); if not r then return end
        local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Parent = r
        if F.FlingType == "Strong" then bv.Velocity = Vector3.new(math.random(-250,250),math.random(150,250),math.random(-250,250))
        elseif F.FlingType == "Up" then bv.Velocity = Vector3.new(0, math.random(300,450), 0)
        else bv.Velocity = Vector3.new(math.random(-140,140), math.random(90,150), math.random(-140,140)) end
        task.delay(0.35, function() if bv then bv:Destroy() end end)
    end)
end
local function Freeze(p, s) local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = s and 0 or 16; h.JumpPower = s and 0 or 50 end end
local function MakeInvis(p, s) if not p or not p.Character then return end; for _, x in ipairs(p.Character:GetDescendants()) do if x:IsA("BasePart") or x:IsA("Decal") then x.Transparency = s and 1 or 0 end end end
local function ForceSit(p) local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then h.Sit = true end end
local function SpinT(p, s) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local av = r:FindFirstChild("SpinAV"); if s and not av then av=Instance.new("BodyAngularVelocity"); av.MaxTorque=Vector3.new(9e9,9e9,9e9); av.AngularVelocity=Vector3.new(0,20,0); av.Parent=r; av.Name="SpinAV" elseif not s and av then av:Destroy() end end
local function Explode(p) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local e = Instance.new("Explosion"); e.BlastRadius=10; e.BlastPressure=0; e.Position=r.Position; e.Parent=Workspace; Debris:AddItem(e,0.5) end
local function PushPull(p, d) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local bv = Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=d*120; bv.Parent=r; task.delay(0.5, function() if bv then bv:Destroy() end end) end
local function SwapPos(p) local a, b = GetMyRoot(), GetTargetRoot(); if not a or not b then return end; local pa, pb = a.Position, b.Position; a.CFrame = CFrame.new(pb); b.CFrame = CFrame.new(pa) end

local EmoteTracks = {}
local function clearEmotes() for _, t in ipairs(EmoteTracks) do pcall(function() t:Stop() t:Destroy() end) end EmoteTracks = {} end
local function PlayEmote(p, id)
    if not p or not p.Character then return end
    local anim = p.Character:FindFirstChildOfClass("Animator")
    if not anim then anim = Instance.new("Animator"); local h = p.Character:FindFirstChildOfClass("Humanoid"); if h then anim.Parent = h end end
    if not anim then return end
    local track = anim:LoadAnimation(Instance.new("Animation")); track.AnimationId = id; track:Play(); table.insert(EmoteTracks, track)
end

--------------------------- MOVEMENT ---------------------------
local function ApplyStats() pcall(function() local h = GetMyHum(); if h then h.WalkSpeed = F.SpeedBoost and 42 or F.WalkSpeed; h.JumpPower = F.SuperJump and 120 or F.JumpPower end end) end
local function ApplyNoclip() pcall(function() local c = LocalPlayer.Character; if not c then return end; local cc = F.NoclipType == "None"; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = cc end end end) end
local BodyVel, BodyGyro
local function SetupFly() local r = GetMyRoot(); if not r then return end; if BodyVel then BodyVel:Destroy() end; if BodyGyro then BodyGyro:Destroy() end; if F.FlyType ~= "None" then BodyVel=Instance.new("BodyVelocity"); BodyVel.MaxForce=Vector3.new(9e9,9e9,9e9); BodyVel.Parent=r; BodyGyro=Instance.new("BodyGyro"); BodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9); BodyGyro.P=20000; BodyGyro.Parent=r end end
local function CleanFly() if BodyVel then BodyVel:Destroy(); BodyVel=nil end; if BodyGyro then BodyGyro:Destroy(); BodyGyro=nil end end
local OT = {}
local function SetInvis(s) pcall(function() local c = LocalPlayer.Character; if not c then return end; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then if s then if not OT[p] then OT[p] = p.Transparency end; p.Transparency = 1 else if OT[p] then p.Transparency = OT[p] end end end end; if not s then table.clear(OT) end end) end

local function OnChar()
    task.wait(0.5); ApplyStats(); ApplyNoclip()
    if F.FlyType ~= "None" then SetupFly() end
    if F.Invisible then SetInvis(true) end
    if F.ESP then task.delay(0.4, refreshESP) end
end
if LocalPlayer.Character then OnChar() end
LocalPlayer.CharacterAdded:Connect(OnChar)

--------------------------- MAIN LOOP ---------------------------
local lastHeavy, lastRole, lastAnti, lastJump = 0,0,0,0
local lastSafe = Vector3.new(0,10,0)
RunService.RenderStepped:Connect(function()
    local now = tick()
    local char = LocalPlayer.Character
    local root = GetMyRoot()
    local hum  = GetMyHum()
    if root and root.Position.Y > -50 then lastSafe = root.Position end

    if now - lastHeavy > 0.5 then
        lastHeavy = now
        if now - lastRole > 1 then
            lastRole = now
        end
        if F.ESP and root then
            for plr, o in pairs(ESPObjects) do
                if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local tr = plr.Character.HumanoidRootPart
                    local d = (root.Position - tr.Position).Magnitude
                    local role = GetRole(plr); local col = RoleColors[role] or RoleColors.Innocent
                    if o.NameLabel then o.NameLabel.Text = plr.Name.." ["..role.."]"; o.NameLabel.TextColor3=col end
                    if o.DistLabel then o.DistLabel.Text = math.floor(d).." studs"; o.DistLabel.TextColor3=col end
                    if o.HealthLabel then local h = plr.Character:FindFirstChildOfClass("Humanoid"); local hp = h and math.floor(h.Health) or 0; o.HealthLabel.Text="HP: "..hp; o.HealthLabel.TextColor3 = hp>50 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0) end
                    if o.WeaponLabel then local t = plr.Character:FindFirstChildOfClass("Tool"); o.WeaponLabel.Text = t and ("Weapon: "..t.Name) or "" end
                    if o.Highlight then o.Highlight.FillColor = col; o.Highlight.OutlineColor = col end
                else clearESP(plr) end
            end
        end
    end

    if not root or not hum then return end
    if F.NoclipType ~= "None" then ApplyNoclip() end
    if F.FlyType ~= "None" and BodyVel and BodyGyro then
        local cam = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit * F.FlySpeed end
        BodyVel.Velocity = dir; BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
    end
    if F.CFrameSpeed then
        local cam = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
        dir = Vector3.new(dir.X,0,dir.Z); if dir.Magnitude > 0 then root.CFrame += dir.Unit * F.CFrameSpeedValue end
    end
    if F.InfiniteJump and UserInputService:IsKeyDown(Enum.KeyCode.Space) and now-lastJump > 0.2 then lastJump = now; pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    if F.BunnyHop and hum.FloorMaterial ~= Enum.Material.Air then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    if F.Wallclimb then local ray=Ray.new(root.Position, root.CFrame.LookVector*2); local hit=Workspace:FindPartOnRay(ray, char); if hit and hum.FloorMaterial==Enum.Material.Air then root.CFrame += Vector3.new(0,0.5,0) end end
    if F.Dash and UserInputService:IsKeyDown(Enum.KeyCode.Space) and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and now-lastJump > 0.5 then lastJump=now; local d=Camera.CFrame.LookVector * F.DashPower; root.AssemblyLinearVelocity=Vector3.new(d.X,0,d.Z) end
    if F.TeleportToMouse and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then local m=UserInputService:GetMouseLocation(); local r=Camera:ScreenPointToRay(m.X,m.Y); local _,pos=Workspace:FindPartOnRay(Ray.new(r.Origin,r.Direction*1000), char); if pos then root.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) end end

    if F.AntiFling and root.AssemblyLinearVelocity.Magnitude > 160 then root.AssemblyLinearVelocity=Vector3.zero; root.AssemblyAngularVelocity=Vector3.zero end
    if F.AntiDie and hum.Health < hum.MaxHealth*0.2 then hum.Health = hum.MaxHealth end
    if F.AntiVoid and root.Position.Y < -50 then root.CFrame = CFrame.new(lastSafe+Vector3.new(0,5,0)); root.AssemblyLinearVelocity=Vector3.zero end
    if F.AntiSit and hum.Sit then hum.Sit = false end
    if F.AntiRagdoll then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running); hum.PlatformStand=false end) end
    if F.AntiTrip then pcall(function() local s=hum:GetState(); if s==Enum.HumanoidStateType.FallingDown or s==Enum.HumanoidStateType.Ragdoll then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end end) end
    if Camera.FieldOfView ~= F.CustomFOV then Camera.FieldOfView = F.CustomFOV end

    if F.Orbit and F.SelectedTarget then local t=GetTarget(); local tr=t and t.Character and t.Character:FindFirstChild("HumanoidRootPart"); if tr then local a=(now*F.OrbitSpeed)%(math.pi*2); root.CFrame=CFrame.new(tr.Position)*CFrame.Angles(0,a,0)*CFrame.new(0,2,F.OrbitDist) end end
    if F.LoopBehind and F.SelectedTarget then local tr=GetTargetRoot(); if tr then root.CFrame=tr.CFrame*CFrame.new(0,0,3.5) end end
    if F.Piggyback then local tr=GetTargetRoot(); if tr then root.CFrame=tr.CFrame*CFrame.new(0,3.1,0.2) end end
    if F.FrontCarry then local tr=GetTargetRoot(); if tr then root.CFrame=tr.CFrame*CFrame.new(0,0,-3.1) end end
    if F.SideCarry then local tr=GetTargetRoot(); if tr then root.CFrame=tr.CFrame*CFrame.new(2.7,0.4,0) end end
    if F.KillTarget then local tr=GetTargetRoot(); if tr then root.CFrame=tr.CFrame*CFrame.new(0,0,2.5); local tool=char:FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end end end

    if F.Aimbot or F.SilentAim then local t=GetClosest(F.AimbotFOV); if t and t.Character then local part=t.Character:FindFirstChild(F.AimPart) or t.Character:FindFirstChild("HumanoidRootPart"); if part then local goal=part.Position+part.AssemblyLinearVelocity*F.AimbotPrediction; if F.SilentAim then Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position, goal) else Camera.CFrame=Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, goal), F.AimbotSmooth) end end end end
    if F.AutoKill and now-lastJump > 1.2 then lastJump=now; local tool=char:FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end end
    if F.AutoShoot and now-lastJump > 0.4 then lastJump=now; local tool=char:FindFirstChildOfClass("Tool"); if tool then local n=string.lower(tool.Name); if n:find("gun") or n:find("revolver") then pcall(function() tool:Activate() end) end end end
    if F.KnifeAura then for _, plr in ipairs(Players:GetPlayers()) do if plr ~= LocalPlayer and plr.Character then local tr=plr.Character:FindFirstChild("HumanoidRootPart"); if tr and (root.Position-tr.Position).Magnitude < F.AuraRange then local tool=char:FindFirstChildOfClass("Tool"); if tool then pcall(function() tool:Activate() end) end end end end end
    if F.FlingNearest and now-lastJump > 0.55 then lastJump=now; local c=GetClosest(55); if c then Fling(c) end end
    if F.FlingTarget and F.SelectedTarget and now-lastJump > 0.4 then lastJump=now; local t=GetTarget(); if t then Fling(t) end end
    if F.FlingAll and now-lastJump > 0.85 then lastJump=now; for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Fling(p) end end end

    local t = GetTarget()
    if t and t.Character then
        if F.FreezeTarget then Freeze(t,true) else Freeze(t,false) end
        if F.InvisibleTarget then MakeInvis(t,true) else MakeInvis(t,false) end
        if F.SpinTarget then SpinT(t,true) else SpinT(t,false) end
        if F.PlatformTarget then local tr=t.Character:FindFirstChild("HumanoidRootPart"); if tr then local ex=tr:FindFirstChild("ZuzyPlat"); if not ex then local p=Instance.new("Part"); p.Name="ZuzyPlat"; p.Size=Vector3.new(8,1,8); p.Anchored=true; p.CanCollide=true; p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(0,200,160); p.CFrame=CFrame.new(tr.Position-Vector3.new(0,3,0)); p.Parent=tr end end else for _, pl in ipairs(Workspace:GetDescendants()) do if pl.Name=="ZuzyPlat" then pl:Destroy() end end end
        if F.DisableJumpTarget then local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=0 end else local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=50 end end
        if F.DisableMoveTarget then local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=0 end else local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=16 end end
        if F.SlowMotionTarget then local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=4 end end
    end
    if F.FreezeAll then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Freeze(p,true) end end else for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Freeze(p,false) end end end
    if F.SpinAll then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then SpinT(p,true) end end else for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then SpinT(p,false) end end end
    if F.RainbowSelf then local hue=now%1; local c=Color3.fromHSV(hue,1,1); for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.Color=c end end end
    if F.AntiAFK and now-lastAnti > 20 then lastAnti=now; pcall(function() VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game); task.wait(0.03); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end) end
end)

--------------------------- UI TABS ---------------------------
-- HOME
local Home = window:CreateTab({ name = "Home" })
Home:CreateSection({ name = "Account" })
Home:CreateButton({ name = "Status", callback = function()
    N("Status",
      "User: "..MY_USERNAME.." ("..MY_UID..")\n"..
      "Role: "..string.upper(MY_ROLE).."\n"..
      "Tier: "..string.upper(MY_TIER).."\n"..
      "Trusted: "..tostring(userRow.is_trusted or false).."\n"..
      "Warnings: "..tostring(userRow.warn_count or 0).."\n"..
      "Version: "..VERSION, 10)
end })
Home:CreateSection({ name = "Requests" })
local DevReason = ""
Home:CreateInput({ name = "Developer Reason", placeholder = "Why?", callback = function(t) DevReason = t end })
Home:CreateButton({ name = "Request Developer", callback = function()
    if #DevReason < 3 then N("Error", "Type a reason.", 5) return end
    http("POST", DISCORD_WEBHOOK, { ["Content-Type"]="application/json" }, { content="**Developer Request**\nUser: "..MY_USERNAME.." ("..MY_UID..")\nReason: "..DevReason })
    N("Sent", "Request sent.", 5)
end })

-- SETTINGS
local Settings = window:CreateTab({ name = "Settings" })
Settings:CreateSection({ name = "Information" })
Settings:CreateButton({ name = "Version: "..VERSION, callback = function() N("Version", VERSION.."\n"..CREDITS, 8) end })
Settings:CreateButton({ name = "Credits", callback = function() N("Credits", CREDITS, 10) end })

Settings:CreateSection({ name = "Config Management" })
Settings:CreateToggle({ name = "Auto Save", default = ConfigState.AutoSave, callback = function(v)
    ConfigState.AutoSave = v
end })
Settings:CreateToggle({ name = "Auto Load", default = ConfigState.AutoLoad, callback = function(v)
    ConfigState.AutoLoad = v
end })
Settings:CreateButton({ name = "Save Config", callback = SaveConfig })
Settings:CreateButton({ name = "Load Config", callback = LoadConfig })
Settings:CreateButton({ name = "Reset Config", callback = ResetConfig })

Settings:CreateSection({ name = "Privacy / Trusted Program" })
Settings:CreateToggle({
    name = "Share Username (Trusted Program)", default = F.ShareUsername,
    callback = function(v)
        F.ShareUsername = v
        pushUserUpdate({ show_username = v })
        if v then
            if HasTier(MY_TIER, "basic") then
                sbPatch("zuzify_users", "user_id=eq."..MY_UID, { is_trusted = true })
                userRow.is_trusted = true
                N("Trusted", "You are now a Trusted User! Extra features unlocked.", 8)
            else
                N("Trusted", "Opted in. Buy a key to become officially Trusted.", 8)
            end
        end
    end,
})

Settings:CreateSection({ name = "Themes" })
Settings:CreateDropdown({ name = "Theme", options = ThemeNames, callback = function(v)
    local n = DD(v); if Themes[n] then window:ChangeTheme(Themes[n]); N("Theme", n, 3) end
end })
Settings:CreateSlider({ name = "FOV", range = {50,120}, value = 70, callback = function(v) F.CustomFOV = v end })
Settings:CreateToggle({ name = "Fullbright", callback = function(v)
    F.Fullbright = v
    pcall(function()
        if v then Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.Brightness=2; Lighting.ClockTime=14
        else Lighting.Ambient=Color3.fromRGB(70,70,70); Lighting.Brightness=1; Lighting.ClockTime=14 end
    end)
end })
Settings:CreateSection({ name = "Session" })
Settings:CreateButton({ name = "Rejoin", callback = function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end })
Settings:CreateButton({ name = "Server Hop", callback = function()
    pcall(function()
        local d = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        local l = {}
        for _, s in ipairs(d.data or {}) do if s.playing < s.maxPlayers and s.id ~= game.JobId then table.insert(l, s.id) end end
        if #l > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, l[math.random(1,#l)], LocalPlayer) end
    end)
end })

-- VISUALS
local Visuals = window:CreateTab({ name = "Visuals" })
Visuals:CreateSection({ name = "ESP" })
Visuals:CreateToggle({ name = "Enable ESP", callback = function(v) F.ESP = v; if v then refreshESP() else clearAllESP() end end })
Visuals:CreateToggle({ name = "Names + Role", callback = function(v) F.ESP_Names = v; refreshESP() end })
Visuals:CreateToggle({ name = "Distance", callback = function(v) F.ESP_Distance = v end })
Visuals:CreateToggle({ name = "Health", callback = function(v) F.ESP_Health = v end })
Visuals:CreateToggle({ name = "Weapon", callback = function(v) F.ESP_Weapon = v end })
Visuals:CreateToggle({ name = "Chams", callback = function(v) F.ESP_Chams = v; refreshESP() end })
Visuals:CreateToggle({ name = "Boxes", callback = function(v) F.ESP_Boxes = v; refreshESP() end })

-- MOVEMENT
local Movement = window:CreateTab({ name = "Movement" })
Movement:CreateSection({ name = "Basic" })
Movement:CreateDropdown({ name = "Noclip", options = {"None","Normal","Full"}, callback = function(v) F.NoclipType = DD(v); ApplyNoclip() end })
Movement:CreateDropdown({ name = "Fly", options = {"None","BodyVelocity"}, callback = function(v) F.FlyType = DD(v); if F.FlyType == "None" then CleanFly() else SetupFly() end end })
Movement:CreateSlider({ name = "Fly Speed", range = {10,250}, value = 60, callback = function(v) F.FlySpeed = v end })
Movement:CreateToggle({ name = "Infinite Jump", callback = function(v) F.InfiniteJump = v end })
Movement:CreateSlider({ name = "Walk Speed", range = {10,150}, value = 16, callback = function(v) F.WalkSpeed = v; ApplyStats() end })
Movement:CreateSlider({ name = "Jump Power", range = {30,200}, value = 50, callback = function(v) F.JumpPower = v; ApplyStats() end })
Movement:CreateToggle({ name = "Speed Boost", callback = function(v) F.SpeedBoost = v; ApplyStats() end })
Movement:CreateToggle({ name = "Super Jump", callback = function(v) F.SuperJump = v; ApplyStats() end })
Movement:CreateToggle({ name = "Bunny Hop", callback = function(v) F.BunnyHop = v end })
Movement:CreateToggle({ name = "Wallclimb", callback = function(v) F.Wallclimb = v end })
Movement:CreateToggle({ name = "Dash (Space+Shift)", callback = function(v) F.Dash = v end })
Movement:CreateSlider({ name = "Dash Power", range = {10,80}, value = 30, callback = function(v) F.DashPower = v end })
Movement:CreateToggle({ name = "CFrame Speed", callback = function(v) F.CFrameSpeed = v end })
Movement:CreateSlider({ name = "CFrame Multi", range = {1,10}, value = 2, callback = function(v) F.CFrameSpeedValue = v end })
Movement:CreateToggle({ name = "Teleport To Mouse (RMB)", callback = function(v) F.TeleportToMouse = v end })
Movement:CreateSection({ name = "Teleports" })
for name, pos in pairs(MapTeleports) do
    Movement:CreateButton({ name = "TP → "..name, callback = function() local r = GetMyRoot(); if r then r.CFrame = CFrame.new(pos+Vector3.new(0,3,0)) end end })
end

-- PLAYERS
local PlayersTab = window:CreateTab({ name = "Players" })
local function playerNames() local l={} for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(l, p.Name) end end return l end
PlayersTab:CreateSection({ name = "Target" })
PlayersTab:CreateDropdown({ name = "Select Player", options = (#playerNames()>0) and playerNames() or {"None"}, callback = function(v) F.SelectedTarget = DD(v) end })
PlayersTab:CreateToggle({ name = "Spectate", callback = function(v)
    if v then local t = GetTarget(); if t and t.Character then Camera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid") end
    else local h = GetMyHum(); if h then Camera.CameraSubject = h end end
end })
PlayersTab:CreateToggle({ name = "Orbit", callback = function(v) F.Orbit = v end })
PlayersTab:CreateSlider({ name = "Orbit Distance", range = {3,20}, value = 6, callback = function(v) F.OrbitDist = v end })
PlayersTab:CreateToggle({ name = "Loop Behind", callback = function(v) F.LoopBehind = v end })

-- COMBAT
local Combat = window:CreateTab({ name = "Combat" })
Combat:CreateSection({ name = "Aim" })
Combat:CreateToggle({ name = "Aimbot", callback = function(v) F.Aimbot = v end })
Combat:CreateToggle({ name = "Silent Aim", callback = function(v) F.SilentAim = v end })
Combat:CreateSlider({ name = "Aimbot FOV", range = {50,500}, value = 230, callback = function(v) F.AimbotFOV = v end })
Combat:CreateSection({ name = "Kill" })
Combat:CreateToggle({ name = "Auto Kill", callback = function(v) F.AutoKill = v end })
Combat:CreateToggle({ name = "Auto Shoot", callback = function(v) F.AutoShoot = v end })
Combat:CreateToggle({ name = "Knife Aura", callback = function(v) F.KnifeAura = v end })
Combat:CreateSlider({ name = "Aura Range", range = {6,40}, value = 15, callback = function(v) F.AuraRange = v end })
Combat:CreateToggle({ name = "Kill Selected", callback = function(v) F.KillTarget = v end })

-- TROLL
local Troll = window:CreateTab({ name = "Troll" })
Troll:CreateSection({ name = "Fling" })
Troll:CreateDropdown({ name = "Fling Type", options = {"Normal","Strong","Up"}, callback = function(v) F.FlingType = DD(v) end })
Troll:CreateToggle({ name = "Fling Nearest", callback = function(v) F.FlingNearest = v end })
Troll:CreateToggle({ name = "Fling Selected", callback = function(v) F.FlingTarget = v end })
Troll:CreateToggle({ name = "Fling All", callback = function(v) F.FlingAll = v end })
Troll:CreateSection({ name = "Carry" })
Troll:CreateToggle({ name = "Piggyback", callback = function(v) F.Piggyback = v end })
Troll:CreateToggle({ name = "Front Carry", callback = function(v) F.FrontCarry = v end })
Troll:CreateToggle({ name = "Side Carry", callback = function(v) F.SideCarry = v end })
Troll:CreateSection({ name = "Self" })
Troll:CreateToggle({ name = "Invisible Self", callback = function(v) F.Invisible = v; SetInvis(v) end })
Troll:CreateToggle({ name = "Rainbow Self", callback = function(v) F.RainbowSelf = v end })
Troll:CreateSection({ name = "Target" })
Troll:CreateToggle({ name = "Freeze Target", callback = function(v) F.FreezeTarget = v end })
Troll:CreateToggle({ name = "Invisible Target", callback = function(v) F.InvisibleTarget = v end })
Troll:CreateToggle({ name = "Spin Target", callback = function(v) F.SpinTarget = v end })
Troll:CreateToggle({ name = "Platform Under Target", callback = function(v) F.PlatformTarget = v end })
Troll:CreateToggle({ name = "Disable Jump (Target)", callback = function(v) F.DisableJumpTarget = v end })
Troll:CreateToggle({ name = "Disable Movement (Target)", callback = function(v) F.DisableMoveTarget = v end })
Troll:CreateToggle({ name = "Slow Motion (Target)", callback = function(v) F.SlowMotionTarget = v end })
Troll:CreateButton({ name = "Force Sit", callback = function() local t = GetTarget(); if t then ForceSit(t) end end })
Troll:CreateButton({ name = "Explode", callback = function() local t = GetTarget(); if t then Explode(t) end end })
Troll:CreateButton({ name = "Push Away", callback = function() local t=GetTarget(); local r1,r2=GetMyRoot(),GetTargetRoot(); if t and r1 and r2 then PushPull(t,(r1.Position-r2.Position).Unit) end end })
Troll:CreateButton({ name = "Pull Toward", callback = function() local t=GetTarget(); local r1,r2=GetMyRoot(),GetTargetRoot(); if t and r1 and r2 then PushPull(t,(r2.Position-r1.Position).Unit) end end })
Troll:CreateButton({ name = "Swap Positions", callback = function() local t = GetTarget(); if t then SwapPos(t) end end })
Troll:CreateSection({ name = "Mass" })
Troll:CreateToggle({ name = "Freeze All", callback = function(v) F.FreezeAll = v end })
Troll:CreateToggle({ name = "Spin All", callback = function(v) F.SpinAll = v end })
Troll:CreateButton({ name = "Explode All", callback = function() for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Explode(p) end end end })
Troll:CreateButton({ name = "Fling All (Instant)", callback = function() for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Fling(p) end end end })

-- EMOTES
local EmoteTab = window:CreateTab({ name = "Emotes" })
EmoteTab:CreateSection({ name = "Play" })
local eNames = {} for _, e in ipairs(EmoteList) do table.insert(eNames, e.Name) end
EmoteTab:CreateDropdown({ name = "Emote", options = eNames, callback = function(v)
    local n = DD(v); for _, e in ipairs(EmoteList) do if e.Name == n then F.SelectedEmote = e.ID end end
end })
EmoteTab:CreateInput({ name = "Custom ID", placeholder = "rbxassetid://...", callback = function(t) if t ~= "" then F.SelectedEmote = t end end })
EmoteTab:CreateButton({ name = "Play on Self", callback = function() if F.SelectedEmote then clearEmotes(); PlayEmote(LocalPlayer, F.SelectedEmote) end end })
EmoteTab:CreateButton({ name = "Play on Target", callback = function() local t=GetTarget(); if t and F.SelectedEmote then clearEmotes(); PlayEmote(t, F.SelectedEmote) end end })
EmoteTab:CreateButton({ name = "Stop Emotes", callback = clearEmotes })
EmoteTab:CreateButton({ name = "Random Emote", callback = function() if #EmoteList>0 then local e=EmoteList[math.random(1,#EmoteList)]; clearEmotes(); PlayEmote(LocalPlayer, e.ID) end end })

-- ANTI
local Anti = window:CreateTab({ name = "Anti" })
Anti:CreateToggle({ name = "Anti AFK", callback = function(v) F.AntiAFK = v end })
Anti:CreateToggle({ name = "Anti Fling", callback = function(v) F.AntiFling = v end })
Anti:CreateToggle({ name = "Anti Die", callback = function(v) F.AntiDie = v end })
Anti:CreateToggle({ name = "Anti Void", callback = function(v) F.AntiVoid = v end })
Anti:CreateToggle({ name = "Anti Sit", callback = function(v) F.AntiSit = v end })
Anti:CreateToggle({ name = "Anti Ragdoll", callback = function(v) F.AntiRagdoll = v end })
Anti:CreateToggle({ name = "Anti Trip", callback = function(v) F.AntiTrip = v end })

-- LOGS
local LogTab = window:CreateTab({ name = "Logs" })
LogTab:CreateSection({ name = "Session Logs" })
LogTab:CreateButton({ name = "View My Logs", callback = function()
    local lines = {}
    for _, l in ipairs(ActionLog) do
        table.insert(lines, "["..os.date("%H:%M:%S", l.t).."] "..l.a..": "..tostring(l.d))
    end
    N("Session Logs ("..#ActionLog..")", table.concat(lines, "\n"):sub(1, 4000), 12)
end })
LogTab:CreateButton({ name = "Clear Logs", callback = function() ActionLog = {}; N("Logs", "Cleared.", 3) end })

--------------------------- MOD / ADMIN / OWNER MENU ---------------------------
if IsStaff() then
    local isMod = HasRole("mod")
    local isAdmin = HasRole("admin") or HasRole("developer") or HasRole("owner")
    local isOwner = HasRole("owner")

    local ModTab = window:CreateTab({ name = isOwner and "Owner Menu" or (isAdmin and "Admin Menu" or "Mod Menu") })

    -- LIVE STATS
    ModTab:CreateSection({ name = "Live Stats" })
    ModTab:CreateButton({ name = "Refresh Online Users", callback = function()
        pcall(function()
            local data = sbGet("zuzify_sessions", "last_ping=gt."..HttpService:UrlEncode(DateTime.now():AddSeconds(-180):ToIsoDate()).."&select=*")
            local cnt = data and #data or 0
            local lines = {}
            for _, s in ipairs(data or {}) do
                if s.show_username and s.username then table.insert(lines, s.username.." ("..s.user_id..") ["..s.role.."/"..s.tier.."]")
                else table.insert(lines, "Anon #"..tostring(s.user_id):sub(-4).." ["..s.role.."/"..s.tier.."]") end
            end
            N("Online: "..cnt, table.concat(lines, "\n"):sub(1,4000), 12)
        end)
    end })
    ModTab:CreateButton({ name = "Full Stats (View)", callback = function()
        pcall(function()
            local s = sbGet("zuzify_stats", "select=*")
            if s and #s > 0 then
                local r = s[1]
                N("Stats",
                  "Total Users: "..r.total_users.."\n"..
                  "Online Now: "..r.online_now.."\n"..
                  "Paid: "..r.paid_users.."\n"..
                  "Trusted: "..r.trusted_users.."\n"..
                  "Staff: "..r.staff_users.."\n"..
                  "Banned: "..r.banned_users.."\n"..
                  "Unused Keys: "..r.unused_keys.."\n"..
                  "Warnings: "..r.total_warnings.."\n"..
                  "Open Reports: "..r.open_reports, 12)
            end
        end)
    end })

    -- USER LOOKUP
    ModTab:CreateSection({ name = "User Lookup" })
    local lookupId = ""
    ModTab:CreateInput({ name = "UserID to view", placeholder = "1234567", callback = function(t) lookupId = t end })
    ModTab:CreateButton({ name = "View User", callback = function()
        if lookupId == "" then return end
        pcall(function()
            local d = sbGet("zuzify_users", "user_id=eq."..lookupId.."&select=*")
            if not d or #d == 0 then N("Lookup", "Not found.", 5) return end
            local u = d[1]
            local warns = sbGet("zuzify_warnings", "user_id=eq."..lookupId.."&select=*")
            N("User: "..(u.username or u.user_id),
              "ID: "..u.user_id.."\n"..
              "Role: "..(u.role or "user").."\n"..
              "Tier: "..(u.tier or "free").."\n"..
              "Paid: "..tostring(u.is_paid).."\n"..
              "Trusted: "..tostring(u.is_trusted).."\n"..
              "Banned: "..tostring(u.is_banned).."\n"..
              "Warnings: "..#(warns or {}), 12)
        end)
    end })

    -- MODERATION
    ModTab:CreateSection({ name = "Moderation" })
    local modTarget, modReason = "", ""
    ModTab:CreateInput({ name = "Target UserID", placeholder = "1234567", callback = function(t) modTarget = t end })
    ModTab:CreateInput({ name = "Reason", placeholder = "Reason", callback = function(t) modReason = t end })

    ModTab:CreateButton({ name = "Warn User", callback = function()
        if modTarget == "" or modReason == "" then return end
        pcall(function()
            local d = sbGet("zuzify_users", "user_id=eq."..modTarget.."&select=warn_count,username")
            local prev = (d and #d>0 and d[1].warn_count) or 0
            sbPost("zuzify_warnings", { user_id = tonumber(modTarget), username = d and d[1].username, moderator_id = MY_UID, moderator_name = MY_USERNAME, reason = modReason, severity = 1 })
            sbPatch("zuzify_users", "user_id=eq."..modTarget, { warn_count = prev + 1 })
            sbPost("zuzify_audit_logs", { action="warn", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget), target_name=d and d[1].username, reason=modReason })
            N("Warned", "Warning issued.", 5)
        end)
    end })

    ModTab:CreateButton({ name = "Kick User", callback = function()
        if modTarget == "" then return end
        pcall(function()
            sbPatch("zuzify_users", "user_id=eq."..modTarget, { kick_signal = true, kick_reason = modReason })
            sbPost("zuzify_audit_logs", { action="kick", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget), reason=modReason })
            sbPost("zuzify_mod_log", { action="kick", target_user_id=tonumber(modTarget), moderator_id=MY_UID, moderator_name=MY_USERNAME, reason=modReason })
            N("Kick Queued", "User kicked within 30s.", 6)
        end)
    end })

    if isAdmin then
        local banMins = 60
        ModTab:CreateSlider({ name = "Ban Minutes (0 = perm)", range = {0, 43200}, value = 60, callback = function(v) banMins = v end })
        ModTab:CreateButton({ name = "Ban User", callback = function()
            if modTarget == "" then return end
            pcall(function()
                local until_ = banMins > 0 and DateTime.now():AddSeconds(banMins*60):ToIsoDate() or nil
                sbPatch("zuzify_users", "user_id=eq."..modTarget, { is_banned=true, ban_reason=modReason, ban_until=until_, ban_by=MY_UID })
                sbPost("zuzify_audit_logs", { action="ban", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget), reason=modReason, metadata={ duration_minutes = banMins } })
                sbPost("zuzify_mod_log", { action="ban", target_user_id=tonumber(modTarget), moderator_id=MY_UID, moderator_name=MY_USERNAME, reason=modReason, duration_minutes=banMins })
                N("Banned", "User banned.", 6)
            end)
        end })
        ModTab:CreateButton({ name = "Unban User", callback = function()
            if modTarget == "" then return end
            pcall(function()
                sbPatch("zuzify_users", "user_id=eq."..modTarget, { is_banned=false, ban_reason=nil, ban_until=nil })
                sbPost("zuzify_audit_logs", { action="unban", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget) })
                N("Unbanned", "User unbanned.", 5)
            end)
        end })
        ModTab:CreateButton({ name = "Add Note to User", callback = function()
            if modTarget == "" or modReason == "" then return end
            pcall(function()
                sbPost("zuzify_user_notes", { user_id=tonumber(modTarget), author_id=MY_UID, author_name=MY_USERNAME, note=modReason })
                N("Note Added", "Saved.", 5)
            end)
        end })
    end

    -- KEY GENERATION (only dev/owner)
    if isAdmin then
        ModTab:CreateSection({ name = "License Keys" })
        local newTier, newDays = "premium", 30
        ModTab:CreateDropdown({ name = "Tier", options = {"basic","premium","trusted","mod","developer"}, callback = function(v) newTier = DD(v) end })
        ModTab:CreateSlider({ name = "Duration (days)", range = {1, 3650}, value = 30, callback = function(v) newDays = v end })
        ModTab:CreateButton({ name = "Generate Key", callback = function()
            pcall(function()
                -- Generate ZUZIFY-XXXX-XXXX-XXXX
                local function block()
                    local s = ""
                    for i = 1, 4 do
                        local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                        s = s .. chars:sub(math.random(1,#chars), math.random(1,#chars))
                    end
                    return s
                end
                local key = "ZUZIFY-"..block().."-"..block().."-"..block()
                sbPost("zuzify_keys", { license_key=key, tier=newTier, created_by=MY_UID, duration_days=newDays, is_active=true })
                sbPost("zuzify_audit_logs", { action="key_create", actor_id=MY_UID, actor_name=MY_USERNAME, metadata = { key=key, tier=newTier, days=newDays } })
                N("Key Created", key, 12)
                if setclipboard then setclipboard(key) end
            end)
        end })
        ModTab:CreateButton({ name = "List Active Keys", callback = function()
            pcall(function()
                local d = sbGet("zuzify_keys", "is_active=eq.true&select=license_key,tier,used_by")
                local s = {}
                for _, k in ipairs(d or {}) do table.insert(s, k.license_key.." ["..k.tier.."] "..(k.used_by and ("used by "..k.used_by) or "unused")) end
                N("Active Keys", table.concat(s, "\n"):sub(1,4000), 12)
            end)
        end })
    end

    -- OWNER-ONLY
    if isOwner then
        ModTab:CreateSection({ name = "Owner Tools" })
        ModTab:CreateButton({ name = "View Audit Logs (Last 30)", callback = function()
            pcall(function()
                local d = sbGet("zuzify_audit_logs", "select=*&order=created_at.desc&limit=30")
                local s = {}
                for _, a in ipairs(d or {}) do
                    table.insert(s, "["..(a.actor_name or a.actor_id).."] "..a.action..(a.target_id and (" → "..a.target_id) or "")..(a.reason and (": "..a.reason) or ""))
                end
                N("Audit Logs", table.concat(s, "\n"):sub(1,4000), 15)
            end)
        end })
        ModTab:CreateButton({ name = "View Open Reports", callback = function()
            pcall(function()
                local d = sbGet("zuzify_reports", "status=eq.open&select=*")
                local s = {}
                for _, r in ipairs(d or {}) do table.insert(s, "["..r.category.."] "..(r.reporter_name or r.reporter_id).." → "..(r.target_name or r.target_id)..": "..(r.details or "")) end
                N("Reports ("..#(d or {})..")", table.concat(s, "\n"):sub(1,4000), 15)
            end)
        end })
        ModTab:CreateButton({ name = "Set My Role → Developer", callback = function()
            sbPatch("zuzify_users", "user_id=eq."..MY_UID, { role = "developer" })
            N("Role", "Set to developer. Rejoin to apply.", 6)
        end })
        ModTab:CreateButton({ name = "Set My Role → Owner", callback = function()
            sbPatch("zuzify_users", "user_id=eq."..MY_UID, { role = "owner", tier = "owner" })
            N("Role", "Set to owner. Rejoin to apply.", 6)
        end })
        ModTab:CreateButton({ name = "Broadcast Kick All (except me)", callback = function()
            pcall(function()
                local all = sbGet("zuzify_sessions", "user_id=neq."..MY_UID.."&select=user_id")
                for _, s in ipairs(all or {}) do
                    sbPatch("zuzify_users", "user_id=eq."..s.user_id, { kick_signal=true, kick_reason="Server maintenance" })
                end
                N("Broadcast", "Kick signal sent to all.", 6)
            end)
        end })
    end
end

--------------------------- USER REPORTS ---------------------------
local ReportTab = window:CreateTab({ name = "Report" })
ReportTab:CreateSection({ name = "Submit Report" })
local repTarget, repReason, repCat = "", "", "exploit"
ReportTab:CreateInput({ name = "Target Username", placeholder = "Username", callback = function(t) repTarget = t end })
ReportTab:CreateDropdown({ name = "Category", options = {"exploit","toxicity","cheating","bug","other"}, callback = function(v) repCat = DD(v) end })
ReportTab:CreateInput({ name = "Details", placeholder = "What happened?", callback = function(t) repReason = t end })
ReportTab:CreateButton({ name = "Submit Report", callback = function()
    if repTarget == "" or repReason == "" then N("Error", "Fill all fields.", 4) return end
    pcall(function()
        sbPost("zuzify_reports", {
            reporter_id = MY_UID, reporter_name = MY_USERNAME,
            target_name = repTarget, category = repCat, details = repReason, status = "open",
        })
        N("Report Sent", "Thank you. Staff will review.", 6)
    end)
end })

--------------------------- BOOT NOTIFY ---------------------------
N("ZuzifyRBX "..VERSION,
  "Welcome "..MY_USERNAME.."!\n"..
  "Role: "..string.upper(MY_ROLE).."\n"..
  "Tier: "..string.upper(MY_TIER)..
  (IsStaff() and "\n★ Staff Access Enabled" or ""), 12)

print("[ZuzifyRBX] Loaded "..VERSION.." | Role: "..MY_ROLE.." | Tier: "..MY_TIER)
