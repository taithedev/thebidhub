--[[
    ╔═══════════════════════════════════════════════════════╗
    ║   ZuzifyRBX Gen7.2.0 — Fixed Jump + ESP/Debug Upgrade ║
    ║   18+ ESP modes • Full Debug tab • No random jumping  ║
    ╚═══════════════════════════════════════════════════════╝
]]

local VERSION    = "Gen7.2.0"
local CREDITS    = "Owner: mrcoptai (717544874) • UI: Rayfield • DB: Supabase"
local CONFIG_FILE = "ZuzifyRBX_Gen7"

local SUPABASE_URL       = "https://YOUR_PROJECT.supabase.co"
local SUPABASE_ANON_KEY  = "YOUR_ANON_KEY_HERE"
local DISCORD_WEBHOOK    = "https://discord.com/api/webhooks/1467436721951084792/KYX4LUdBw4K2i2Bpwc4UZRSF1JRNJ0Banw1KK1xrQzjPHXMh0DLIQ0Rs8giXVISjqwt0"
local OWNER_UIDS         = { 717544874 }

--------------------------- SERVICES ---------------------------
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TeleportService     = game:GetService("TeleportService")
local HttpService         = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui             = game:GetService("CoreGui")
local Lighting            = game:GetService("Lighting")
local TweenService        = game:GetService("TweenService")
local Debris              = game:GetService("Debris")
local Workspace           = game:GetService("Workspace")
local Stats               = game:GetService("Stats")

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
    for _ = 1, 3 do
        local ok, res = pcall(httpReq, opts)
        if ok and res then
            local decoded; pcall(function() decoded = HttpService:JSONDecode(res.Body) end)
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
local function sbGet(t, q)      return http("GET",    SUPABASE_URL.."/rest/v1/"..t..(q and ("?"..q) or ""), sbHeaders()) end
local function sbPost(t, b)     return http("POST",   SUPABASE_URL.."/rest/v1/"..t, sbHeaders(), b) end
local function sbPatch(t, q, b) return http("PATCH",  SUPABASE_URL.."/rest/v1/"..t.."?"..q, sbHeaders(), b) end

local function nowISO() return DateTime.now():ToIsoDate() end
local function DD(v) if type(v) == "table" then return v[1] or tostring(v[1]) end return v end

local ROLE_ORDER = { user=0, free=0, basic=1, premium=2, trusted=2, mod=3, admin=4, developer=4, owner=5 }
local function HasTier(cur, min) return (ROLE_ORDER[cur] or 0) >= (ROLE_ORDER[min] or 0) end

--------------------------- DISCLAIMER ---------------------------
local function showDisclaimer()
    local gui = Instance.new("ScreenGui")
    gui.Name="ZuzifyRBX_Disc"; gui.ResetOnSpawn=false; gui.IgnoreGuiInset=true; gui.Parent=CoreGui

    local overlay = Instance.new("Frame")
    overlay.Size=UDim2.new(1,0,1,0); overlay.BackgroundColor3=Color3.fromRGB(0,0,0)
    overlay.BackgroundTransparency=0.4; overlay.BorderSizePixel=0; overlay.Parent=gui

    local frame = Instance.new("Frame")
    frame.Size=UDim2.new(0,640,0,500); frame.Position=UDim2.new(0.5,-320,0.5,-250)
    frame.BackgroundColor3=Color3.fromRGB(10,10,14); frame.BorderSizePixel=0; frame.Parent=gui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,14)
    local st=Instance.new("UIStroke"); st.Color=Color3.fromRGB(0,200,160); st.Thickness=1.5; st.Parent=frame

    local t = Instance.new("TextLabel")
    t.Size=UDim2.new(1,-40,0,44); t.Position=UDim2.new(0,20,0,16); t.BackgroundTransparency=1
    t.Text="ZuzifyRBX "..VERSION.." — Disclaimer"; t.TextColor3=Color3.fromRGB(0,220,180)
    t.Font=Enum.Font.GothamBold; t.TextSize=22; t.TextXAlignment=Enum.TextXAlignment.Left; t.Parent=frame

    local body = Instance.new("TextLabel")
    body.Size=UDim2.new(1,-40,0,320); body.Position=UDim2.new(0,20,0,66); body.BackgroundTransparency=1
    body.TextColor3=Color3.fromRGB(220,220,230); body.Font=Enum.Font.Gotham; body.TextSize=14
    body.TextWrapped=true; body.TextXAlignment=Enum.TextXAlignment.Left; body.TextYAlignment=Enum.TextYAlignment.Top
    body.Text=table.concat({
        "Before using ZuzifyRBX, please read and accept:",
        "",
        "• ZuzifyRBX is a third-party script. Use at your OWN RISK.",
        "• You must comply with the Roblox Terms of Service.",
        "• ZuzifyRBX is NOT responsible for any bans, kicks, or damages.",
        "• Data collected: UserID + username for licensing, moderation, and anonymous stats.",
        "• Username is NOT shown publicly unless you enable 'Share Username'.",
        "• Misuse may result in a ban (permanent or timed).",
        "• You must be 13+ to use this.",
        "• By clicking ACCEPT you take full responsibility.",
    },"\n")
    body.Parent=frame

    local acc = Instance.new("TextButton")
    acc.Size=UDim2.new(0.45,-30,0,46); acc.Position=UDim2.new(0,20,1,-66)
    acc.BackgroundColor3=Color3.fromRGB(0,160,130); acc.Text="ACCEPT"
    acc.TextColor3=Color3.fromRGB(255,255,255); acc.Font=Enum.Font.GothamBold; acc.TextSize=16; acc.Parent=frame
    Instance.new("UICorner",acc).CornerRadius=UDim.new(0,10)

    local dec = Instance.new("TextButton")
    dec.Size=UDim2.new(0.45,-30,0,46); dec.Position=UDim2.new(0.5,10,1,-66)
    dec.BackgroundColor3=Color3.fromRGB(160,40,50); dec.Text="DECLINE"
    dec.TextColor3=Color3.fromRGB(255,255,255); dec.Font=Enum.Font.GothamBold; dec.TextSize=16; dec.Parent=frame
    Instance.new("UICorner",dec).CornerRadius=UDim.new(0,10)

    local ok = false
    acc.MouseButton1Click:Connect(function() ok=true; gui:Destroy() end)
    dec.MouseButton1Click:Connect(function() gui:Destroy(); LocalPlayer:Kick("Declined disclaimer.") end)
    while not ok and gui.Parent do task.wait(0.1) end
    return ok
end
if not showDisclaimer() then return end

--------------------------- LICENSE POPUP ---------------------------
local function showLicensePopup()
    local gui = Instance.new("ScreenGui")
    gui.Name="ZuzifyRBX_Lic"; gui.ResetOnSpawn=false; gui.Parent=CoreGui

    local frame = Instance.new("Frame")
    frame.Size=UDim2.new(0,540,0,420); frame.Position=UDim2.new(0.5,-270,0.5,-210)
    frame.BackgroundColor3=Color3.fromRGB(8,8,12); frame.BorderSizePixel=0; frame.Parent=gui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,12)
    local st=Instance.new("UIStroke"); st.Color=Color3.fromRGB(0,200,160); st.Thickness=1.5; st.Parent=frame

    local t = Instance.new("TextLabel")
    t.Size=UDim2.new(1,0,0,44); t.BackgroundTransparency=1
    t.Text="ZuzifyRBX "..VERSION.." — Activation"; t.TextColor3=Color3.fromRGB(0,220,180)
    t.Font=Enum.Font.GothamBold; t.TextSize=20; t.Parent=frame

    local info = Instance.new("TextLabel")
    info.Size=UDim2.new(1,-40,0,80); info.Position=UDim2.new(0,20,0,50); info.BackgroundTransparency=1
    info.Text="Enter your license key (Format: ZUZIFY-XXXX-XXXX-XXXX)\nor click Continue for the FREE tier.\nFree tier: limited. Paid unlocks everything + staff tools."
    info.TextColor3=Color3.fromRGB(200,200,215); info.Font=Enum.Font.Gotham; info.TextSize=13
    info.TextWrapped=true; info.Parent=frame

    local box = Instance.new("TextBox")
    box.Size=UDim2.new(0.9,0,0,42); box.Position=UDim2.new(0.05,0,0.45,0)
    box.BackgroundColor3=Color3.fromRGB(16,16,20); box.TextColor3=Color3.fromRGB(255,255,255)
    box.PlaceholderText="ZUZIFY-0000-0000-0001"; box.Font=Enum.Font.Gotham
    box.TextSize=15; box.ClearTextOnFocus=false; box.Parent=frame
    Instance.new("UICorner",box).CornerRadius=UDim.new(0,8)

    local msg = Instance.new("TextLabel")
    msg.Size=UDim2.new(1,-40,0,22); msg.Position=UDim2.new(0,20,0.45,50); msg.BackgroundTransparency=1
    msg.Text=""; msg.TextColor3=Color3.fromRGB(255,120,120); msg.Font=Enum.Font.Gotham; msg.TextSize=13; msg.Parent=frame

    local act = Instance.new("TextButton")
    act.Size=UDim2.new(0.44,-20,0,46); act.Position=UDim2.new(0.05,0,0.80,0)
    act.BackgroundColor3=Color3.fromRGB(0,160,130); act.Text="Activate"
    act.TextColor3=Color3.fromRGB(255,255,255); act.Font=Enum.Font.GothamBold; act.TextSize=15; act.Parent=frame
    Instance.new("UICorner",act).CornerRadius=UDim.new(0,8)

    local skip = Instance.new("TextButton")
    skip.Size=UDim2.new(0.44,-20,0,46); skip.Position=UDim2.new(0.51,0,0.80,0)
    skip.BackgroundColor3=Color3.fromRGB(40,40,48); skip.Text="Continue Free"
    skip.TextColor3=Color3.fromRGB(230,230,240); skip.Font=Enum.Font.GothamBold; skip.TextSize=15; skip.Parent=frame
    Instance.new("UICorner",skip).CornerRadius=UDim.new(0,8)

    local r = { done=false, tier="free", key=nil, role="user" }

    act.MouseButton1Click:Connect(function()
        local key = string.upper((box.Text:gsub("%s","")))
        if #key < 10 then msg.Text="Format: ZUZIFY-XXXX-XXXX-XXXX" return end
        msg.Text="Checking…"; msg.TextColor3=Color3.fromRGB(200,200,100)
        task.spawn(function()
            local d = sbGet("zuzify_keys","license_key=eq."..HttpService:UrlEncode(key).."&select=*")
            if not d or #d==0 then msg.Text="Invalid key."; msg.TextColor3=Color3.fromRGB(255,120,120) return end
            local k = d[1]
            if not k.is_active then msg.Text="Key deactivated." return end
            if k.used_by and k.used_by ~= MY_UID then msg.Text="Key used." return end
            if k.expires_at then
                local ok2, exp = pcall(function() return DateTime.fromIsoDate(k.expires_at) end)
                if ok2 and exp and exp.UnixTimestamp < os.time() then msg.Text="Key expired." return end
            end
            local expISO = nil
            if k.duration_days and k.duration_days > 0 then
                expISO = DateTime.now():AddSeconds(k.duration_days*86400):ToIsoDate()
            end
            sbPatch("zuzify_keys","license_key=eq."..HttpService:UrlEncode(key),
                { used_by=MY_UID, used_at=nowISO(), expires_at=expISO })
            sbPost("zuzify_key_redemptions",{ license_key=key, user_id=MY_UID, username=MY_USERNAME, tier=k.tier })
            r.tier = k.tier or "basic"
            r.key  = key
            r.role = (k.tier=="owner" or k.tier=="developer") and k.tier or (k.tier=="mod" and "mod") or (k.tier=="admin" and "admin") or "user"
            r.done = true
            gui:Destroy()
        end)
    end)
    skip.MouseButton1Click:Connect(function() r.done=true; gui:Destroy() end)
    while not r.done do task.wait(0.1) end
    return r.tier, r.key, r.role
end

local acquiredTier, acquiredKey, acquiredRole = showLicensePopup()

--------------------------- REGISTER USER ---------------------------
local IS_OWNER = table.find(OWNER_UIDS, MY_UID) ~= nil
if IS_OWNER then acquiredTier, acquiredRole = "owner", "owner" end

local function registerUser()
    local payload = {
        user_id=MY_UID, username=MY_USERNAME, license_key=acquiredKey,
        tier=acquiredTier, role=acquiredRole, is_paid=(acquiredTier~="free"), last_seen=nowISO(),
    }
    local d = sbGet("zuzify_users","user_id=eq."..MY_UID.."&select=*")
    if d and #d>0 then
        local cur = d[1]
        if IS_OWNER then payload.tier, payload.role = "owner","owner"
        else
            if cur.role and (ROLE_ORDER[cur.role] or 0) > (ROLE_ORDER[payload.role] or 0) then payload.role = cur.role end
            if cur.tier and (ROLE_ORDER[cur.tier] or 0) > (ROLE_ORDER[payload.tier] or 0) then payload.tier = cur.tier end
        end
        sbPatch("zuzify_users","user_id=eq."..MY_UID, payload)
        return cur
    else
        local c = sbPost("zuzify_users", payload)
        if c and #c>0 then return c[1] end
    end
    return nil
end

local userRow = registerUser() or { tier=acquiredTier, role=acquiredRole, is_trusted=false, show_username=false, is_banned=false, warn_count=0 }
if userRow.is_banned then LocalPlayer:Kick("Banned. Reason: "..(userRow.ban_reason or "No reason")) return end

local MY_ROLE = userRow.role or acquiredRole or "user"
local MY_TIER = userRow.tier or acquiredTier or "free"
local function HasRole(r) return HasTier(MY_ROLE, r) or HasTier(MY_TIER, r) end
local function IsStaff() return HasRole("mod") end

--------------------------- ACTION LOG ---------------------------
local ActionLog = {}
local function Log(a, d)
    table.insert(ActionLog, { t=os.time(), a=a, d=d })
    if #ActionLog > 200 then table.remove(ActionLog, 1) end
end

--------------------------- HEARTBEAT ---------------------------
local JOB_ID   = game.JobId
local PLACE_ID = game.PlaceId
local sessionId, lastServerRole = nil, MY_ROLE

task.spawn(function()
    while true do
        pcall(function()
            if not sessionId then
                local c = sbPost("zuzify_sessions", {
                    user_id=MY_UID, username=userRow.show_username and MY_USERNAME or nil,
                    show_username=userRow.show_username or false, role=MY_ROLE, tier=MY_TIER,
                    place_id=PLACE_ID, job_id=JOB_ID, client_version=VERSION,
                })
                if c and #c>0 then sessionId = c[1].id end
            else
                sbPatch("zuzify_sessions","id=eq."..sessionId,{ last_ping=nowISO() })
            end
            local me = sbGet("zuzify_users","user_id=eq."..MY_UID.."&select=is_banned,ban_reason,kick_signal,kick_reason,role,tier,is_trusted,warn_count")
            if me and #me>0 then
                local m = me[1]
                if m.is_banned then LocalPlayer:Kick("Banned: "..(m.ban_reason or "No reason")) end
                if m.kick_signal then
                    sbPatch("zuzify_users","user_id=eq."..MY_UID,{ kick_signal=false, kick_reason="" })
                    LocalPlayer:Kick("Kicked: "..(m.kick_reason or "No reason"))
                end
                if m.role ~= lastServerRole then lastServerRole = m.role; MY_ROLE = m.role or MY_ROLE end
                if m.tier and m.tier ~= MY_TIER then MY_TIER = m.tier end
                if m.is_trusted ~= nil then userRow.is_trusted = m.is_trusted end
                if m.warn_count then userRow.warn_count = m.warn_count end
            end
        end)
        task.wait(30)
    end
end)

--------------------------- THEMES (60) ---------------------------
local function T(a,b1,b2)
    a = a or Color3.fromRGB(0,210,170); b1 = b1 or Color3.fromRGB(8,8,10); b2 = b2 or Color3.fromRGB(14,14,18)
    return {
        WindowColor=ColorSequence.new(b1,b2), ShadowColor=Color3.fromRGB(0,0,0),
        ContentColor=Color3.fromRGB(235,235,240), TitlingColor=Color3.fromRGB(250,250,255),
        AccentColor=a, AccentStroke=a, TabColor=Color3.fromRGB(220,220,230),
        TabBackground=ColorSequence.new(b2,b1), ElementGradient=ColorSequence.new(b2,b1),
        FieldBackground=b2, SliderBackground=Color3.fromRGB(24,24,30),
        SliderProgress=ColorSequence.new(a,a), ToggleTrack=Color3.fromRGB(32,32,38),
    }
end

local Themes = {
    ["OLED Dark"]=T(Color3.fromRGB(0,210,170)),
    ["Midnight"]=T(Color3.fromRGB(90,140,255),Color3.fromRGB(10,12,24),Color3.fromRGB(16,18,36)),
    ["Crimson"]=T(Color3.fromRGB(255,55,75),Color3.fromRGB(16,8,10),Color3.fromRGB(28,12,16)),
    ["Ocean"]=T(Color3.fromRGB(0,190,220),Color3.fromRGB(6,16,24),Color3.fromRGB(10,28,40)),
    ["Purple"]=T(Color3.fromRGB(160,80,255),Color3.fromRGB(14,8,24),Color3.fromRGB(24,14,40)),
    ["Gold"]=T(Color3.fromRGB(255,190,50),Color3.fromRGB(16,14,6),Color3.fromRGB(28,24,10)),
    ["Pink"]=T(Color3.fromRGB(255,105,180),Color3.fromRGB(18,10,16),Color3.fromRGB(32,16,28)),
    ["Matrix"]=T(Color3.fromRGB(0,255,70),Color3.fromRGB(2,8,2),Color3.fromRGB(4,16,4)),
    ["Abyss"]=T(Color3.fromRGB(40,80,255),Color3.fromRGB(2,4,12),Color3.fromRGB(6,10,24)),
    ["Mono"]=T(Color3.fromRGB(255,255,255),Color3.fromRGB(0,0,0),Color3.fromRGB(18,18,18)),
    ["Neon"]=T(Color3.fromRGB(255,0,200),Color3.fromRGB(10,0,20),Color3.fromRGB(20,0,40)),
    ["Cyberpunk"]=T(Color3.fromRGB(255,0,255),Color3.fromRGB(8,0,16),Color3.fromRGB(16,0,32)),
    ["Sunset"]=T(Color3.fromRGB(255,100,0),Color3.fromRGB(30,10,0),Color3.fromRGB(50,20,0)),
    ["Forest"]=T(Color3.fromRGB(0,200,100),Color3.fromRGB(2,16,8),Color3.fromRGB(4,24,12)),
    ["Pastel"]=T(Color3.fromRGB(200,150,255),Color3.fromRGB(30,20,40),Color3.fromRGB(50,35,60)),
    ["Galaxy"]=T(Color3.fromRGB(100,50,255),Color3.fromRGB(6,4,20),Color3.fromRGB(12,8,36)),
    ["Lava"]=T(Color3.fromRGB(255,80,0),Color3.fromRGB(20,4,0),Color3.fromRGB(40,8,0)),
    ["Ice"]=T(Color3.fromRGB(0,200,255),Color3.fromRGB(4,12,20),Color3.fromRGB(8,20,36)),
    ["Sand"]=T(Color3.fromRGB(200,170,120),Color3.fromRGB(20,16,12),Color3.fromRGB(36,28,20)),
    ["Rose"]=T(Color3.fromRGB(255,80,120),Color3.fromRGB(20,8,12),Color3.fromRGB(36,12,20)),
    ["Lime"]=T(Color3.fromRGB(150,255,50),Color3.fromRGB(8,16,4),Color3.fromRGB(16,28,8)),
    ["Candy"]=T(Color3.fromRGB(255,150,200),Color3.fromRGB(24,8,16),Color3.fromRGB(40,12,28)),
    ["Retro"]=T(Color3.fromRGB(255,200,50),Color3.fromRGB(16,12,8),Color3.fromRGB(28,20,12)),
    ["Vaporwave"]=T(Color3.fromRGB(255,0,150),Color3.fromRGB(12,0,24),Color3.fromRGB(24,0,48)),
    ["Synthwave"]=T(Color3.fromRGB(255,100,255),Color3.fromRGB(8,4,16),Color3.fromRGB(16,8,32)),
    ["Solar"]=T(Color3.fromRGB(255,150,0),Color3.fromRGB(20,12,0),Color3.fromRGB(36,20,0)),
    ["Lunar"]=T(Color3.fromRGB(150,150,200),Color3.fromRGB(12,12,16),Color3.fromRGB(20,20,28)),
    ["Inferno"]=T(Color3.fromRGB(255,50,0),Color3.fromRGB(20,4,0),Color3.fromRGB(40,8,0)),
    ["Arctic"]=T(Color3.fromRGB(100,200,255),Color3.fromRGB(6,12,20),Color3.fromRGB(10,20,36)),
    ["Mint"]=T(Color3.fromRGB(100,255,180),Color3.fromRGB(4,16,10),Color3.fromRGB(8,28,18)),
    ["Lavender"]=T(Color3.fromRGB(200,150,255),Color3.fromRGB(14,8,24),Color3.fromRGB(24,14,40)),
    ["Copper"]=T(Color3.fromRGB(200,120,50),Color3.fromRGB(16,12,8),Color3.fromRGB(28,20,12)),
    ["Silver"]=T(Color3.fromRGB(180,180,200),Color3.fromRGB(12,12,14),Color3.fromRGB(20,20,24)),
    ["Emerald"]=T(Color3.fromRGB(50,200,100),Color3.fromRGB(4,16,8),Color3.fromRGB(8,28,14)),
    ["Ruby"]=T(Color3.fromRGB(200,50,50),Color3.fromRGB(16,4,4),Color3.fromRGB(28,8,8)),
    ["Sapphire"]=T(Color3.fromRGB(50,100,255),Color3.fromRGB(4,8,20),Color3.fromRGB(8,14,36)),
    ["Amber"]=T(Color3.fromRGB(255,180,50),Color3.fromRGB(16,12,4),Color3.fromRGB(28,20,8)),
    ["Jade"]=T(Color3.fromRGB(100,255,150),Color3.fromRGB(4,16,8),Color3.fromRGB(8,28,14)),
    ["Pearl"]=T(Color3.fromRGB(255,240,220),Color3.fromRGB(16,14,12),Color3.fromRGB(28,24,20)),
    ["Obsidian"]=T(Color3.fromRGB(180,180,200),Color3.fromRGB(2,2,4),Color3.fromRGB(6,6,12)),
    ["Blood"]=T(Color3.fromRGB(180,20,30),Color3.fromRGB(14,2,4),Color3.fromRGB(28,4,8)),
    ["Toxic"]=T(Color3.fromRGB(120,255,40),Color3.fromRGB(6,14,2),Color3.fromRGB(12,26,4)),
    ["Nebula"]=T(Color3.fromRGB(200,100,255),Color3.fromRGB(10,4,26),Color3.fromRGB(20,8,44)),
    ["Storm"]=T(Color3.fromRGB(120,160,200),Color3.fromRGB(10,14,20),Color3.fromRGB(18,24,34)),
    ["Aurora"]=T(Color3.fromRGB(80,255,200),Color3.fromRGB(4,14,14),Color3.fromRGB(8,28,28)),
    ["Holographic"]=T(Color3.fromRGB(255,100,255),Color3.fromRGB(2,2,8),Color3.fromRGB(6,4,20)),
    ["Matcha"]=T(Color3.fromRGB(120,200,90),Color3.fromRGB(8,16,8),Color3.fromRGB(16,28,16)),
    ["Cherry"]=T(Color3.fromRGB(200,30,80),Color3.fromRGB(20,4,10),Color3.fromRGB(36,8,18)),
    ["Volcano"]=T(Color3.fromRGB(255,60,20),Color3.fromRGB(24,6,0),Color3.fromRGB(44,12,0)),
    ["Glacier"]=T(Color3.fromRGB(150,230,255),Color3.fromRGB(6,14,24),Color3.fromRGB(12,24,42)),
    ["Coral"]=T(Color3.fromRGB(255,120,130),Color3.fromRGB(20,8,10),Color3.fromRGB(36,16,20)),
    ["Steel"]=T(Color3.fromRGB(140,150,170),Color3.fromRGB(14,16,22),Color3.fromRGB(24,28,36)),
    ["Peach"]=T(Color3.fromRGB(255,180,140),Color3.fromRGB(22,14,10),Color3.fromRGB(38,24,18)),
    ["Taro"]=T(Color3.fromRGB(180,160,255),Color3.fromRGB(14,12,26),Color3.fromRGB(24,20,44)),
    ["Basil"]=T(Color3.fromRGB(60,180,60),Color3.fromRGB(6,14,6),Color3.fromRGB(12,26,12)),
    ["Firefly"]=T(Color3.fromRGB(255,230,60),Color3.fromRGB(14,14,4),Color3.fromRGB(26,26,8)),
    ["Deep Space"]=T(Color3.fromRGB(60,60,200),Color3.fromRGB(2,2,10),Color3.fromRGB(4,4,22)),
    ["Chrome"]=T(Color3.fromRGB(200,200,220),Color3.fromRGB(20,20,24),Color3.fromRGB(32,32,40)),
    ["Kawaii"]=T(Color3.fromRGB(255,180,220),Color3.fromRGB(22,10,18),Color3.fromRGB(38,18,30)),
    ["Zen"]=T(Color3.fromRGB(120,180,140),Color3.fromRGB(8,14,12),Color3.fromRGB(16,26,22)),
}
local ThemeNames = {}
for k in pairs(Themes) do table.insert(ThemeNames, k) end
table.sort(ThemeNames)

--------------------------- RAYFIELD ---------------------------
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()

local function N(title, content, duration)
    pcall(function()
        Rayfield:Notify({
            Title=tostring(title or "ZuzifyRBX"),
            Content=tostring(content or ""),
            Duration=tonumber(duration) or 6,
            Image=4483362458,
        })
    end)
    Log("notify", tostring(title))
end

local window = Rayfield:CreateWindow({
    name = "ZuzifyRBX ["..string.upper(MY_TIER).."]",
    subtitle = VERSION.." • "..CREDITS,
    theme = Themes["OLED Dark"],
    configuration = { autoSave=false, autoLoad=false, fileName=CONFIG_FILE },
})

local ConfigState = { AutoSave=true, AutoLoad=true }
if ConfigState.AutoLoad then pcall(function() Rayfield:LoadConfiguration() end) end

--------------------------- FEATURES ---------------------------
local F = {
    -- ESP
    ESP=false, ESP_Names=true, ESP_Distance=true, ESP_Health=true, ESP_Weapon=true,
    ESP_Chams=true, ESP_Boxes=true,
    ESP_Tracers=false, ESP_TracersMode="Top",        -- "Top" or "Bottom"
    ESP_Skeleton=false, ESP_SkeletonThickness=1,
    ESP_HeadDot=false, ESP_HeadDotSize=8,
    ESP_Facing=false,
    ESP_FillTransparency=0.5, ESP_OutlineTransparency=0.1,
    ESP_TeamCheck=true, ESP_DeadCheck=true, ESP_MaxDistance=1500,
    ESP_RefreshRate=0.1,
    ESP_ColorMode="Role",                             -- Role | Distance | Health | Static
    ESP_StaticColor=Color3.fromRGB(0,220,180),
    ESP_ShowOnlyMurderer=false, ESP_ShowOnlySheriff=false,
    ESP_FOVCircle=false, ESP_FOVRadius=140,
    ESP_Through = true,                               -- AlwaysOnTop
    -- Visual
    Fullbright=false, CustomFOV=70,
    -- Movement
    NoclipType="None", FlyType="None", FlySpeed=60,
    InfiniteJump=false, InfiniteJumpCooldown=0.35,
    WalkSpeed=16, JumpPower=50, SpeedBoost=false, SuperJump=false,
    HitboxExtender=false, HitboxSize=9, LowGravity=false,
    BunnyHop=false, BunnyHopRequireMove=true, BunnyHopCooldown=0.25,
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
    AntiAFK=true, AntiAFKInterval=60,
    AntiFling=true, AntiDie=false, AntiVoid=false, AntiSit=false,
    AntiRagdoll=false, AntiTrip=false,
    -- Emotes
    SelectedEmote=nil, DanceParty=false,
    -- Privacy
    ShareUsername = userRow.show_username or false,
    -- Debug
    Debug_Overlay=false,
}

local function pushUserUpdate(patch)
    sbPatch("zuzify_users","user_id=eq."..MY_UID, patch)
    if sessionId then sbPatch("zuzify_sessions","id=eq."..sessionId, patch) end
end

--------------------------- EMOTES ---------------------------
local EmoteList = {}
local function E(n,i) table.insert(EmoteList,{Name=n,ID=i}) end
local eids = {"507770620","507771112","507771612","507771366","507771049","507771682","507771410","507771276","507771842","507771453","507771054","507771815","507771568","507771147","507771731","507771174","507771878","507771594","507771358","507771270","507771697","507771597","507771482","507771702","507771501","507771205","507771295","507771100","507771650","507771467","507771406","507771537","507771339","507771266","507771490","507771831","507771771","507771647","507771060","507771152","507771554","507771536","507771715","507771080","507771398","507771911","507771551","507771756","507771692","507771357","507771226","507771022","507771582","507771620","507771769","507771670","507771364","507771279","507771019","507771790","507771307","507771591","507771494","507771674","507771837","507771457","507771109","507771547","507771305","507771827","507771183","507771466","507771706","507771174","507771217","507771330","507771476","507771215","507771679","507771865","507771093","507771585","507771660","507771803","507771329","507771491","507771259","507771716","507771053","507771128","507771640","507771597","507771091","507771767","507771412"}
local enames = {"Dance","Robot","Floss","Twist","Whip","Wave","Point","Salute","Sit","Lay","Dab","Gangnam","Macarena","Harlem","Running Man","T-Pose","Cossack","Ballet","Sword","Karate","Boxing","Fencing","Taekwondo","Yoga","Breakdance","Moonwalk","Shuffle","Charleston","Tango","Waltz","Salsa","Mambo","Cha Cha","Rumba","Zumba","Hip Hop","Popping","Locking","Waacking","Voguing","Krumping","House","Industrial","Electro","Techno","Trance","Dubstep","Drum & Bass","Jazz","Tap","Modern","Contemporary","Lyrical","Musical","Ballroom","Swing","Lindy Hop","Jive","Boogie","Rock & Roll","Mosh","Circle Pit","Wall of Death","Clap","Cheer","Cry","Laugh","Shrug","Faint","Roar","Scream","Snap","Stomp","Thriller","Disco","Funky","Smooth","Cool","Attitude","Confused","Nervous","Shy","Sassy","Angry","Sad","Happy","Surprised","Disgusted","Fear","Pride","Love","Peace","Victory","Spin","Float","Kick","Punch","Jump","Slide","Backflip","Frontflip"}
local ei=0
for k=1,#enames do ei=ei+1; E(enames[k].." "..ei, "rbxassetid://"..eids[((k-1)%#eids)+1]) end
for k=1,200 do ei=ei+1; E("Extra "..ei, "rbxassetid://"..eids[((k-1)%#eids)+1]..math.random(10,99)) end

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

--------------------------- ESP v2 ---------------------------
local ESPObjects = {}
local FOVCircleObj = nil

local function safeDestroy(o) pcall(function() if o and o.Parent then o:Destroy() end end) end

local function clearESP(plr)
    if ESPObjects[plr] then
        for _, o in pairs(ESPObjects[plr]) do
            if type(o) == "table" then
                for _, x in ipairs(o) do safeDestroy(x) end
            else
                safeDestroy(o)
            end
        end
        ESPObjects[plr] = nil
    end
end
local function clearAllESP() for p in pairs(ESPObjects) do clearESP(p) end end

local function getESPColor(plr, distance)
    if F.ESP_ColorMode == "Role" then
        return RoleColors[GetRole(plr)] or RoleColors.Innocent
    elseif F.ESP_ColorMode == "Distance" then
        local t = math.clamp(distance / 300, 0, 1)
        return Color3.fromRGB(255*(1-t), 255*t, 0)
    elseif F.ESP_ColorMode == "Health" then
        local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if h then
            local p = h.Health / math.max(h.MaxHealth, 1)
            return Color3.fromRGB(255*(1-p), 255*p, 0)
        end
        return Color3.fromRGB(0,255,0)
    end
    return F.ESP_StaticColor
end

local function createESP(plr)
    if plr == LocalPlayer or ESPObjects[plr] then return end
    local char = plr.Character; if not char then return end
    local head = char:FindFirstChild("Head")
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not head or not root or not hum then return end

    local o = {}

    -- Billboard
    local bb = Instance.new("BillboardGui")
    bb.Name="ZuzyESP"; bb.Adornee=head
    bb.Size=UDim2.new(0,320,0,140); bb.StudsOffset=Vector3.new(0,3.6,0)
    bb.AlwaysOnTop = F.ESP_Through
    bb.Parent=head; o.Billboard = bb

    local nameL = Instance.new("TextLabel")
    nameL.Size=UDim2.new(1,0,0.28,0); nameL.BackgroundTransparency=1
    nameL.TextColor3=Color3.fromRGB(255,255,255); nameL.TextStrokeTransparency=0.1
    nameL.Font=Enum.Font.GothamBold; nameL.TextSize=15; nameL.Parent=bb; o.NameLabel=nameL

    local distL = Instance.new("TextLabel")
    distL.Size=UDim2.new(1,0,0.18,0); distL.Position=UDim2.new(0,0,0.28,0)
    distL.BackgroundTransparency=1; distL.Font=Enum.Font.Gotham; distL.TextSize=12
    distL.Parent=bb; o.DistLabel=distL

    local hpL = Instance.new("TextLabel")
    hpL.Size=UDim2.new(1,0,0.18,0); hpL.Position=UDim2.new(0,0,0.46,0)
    hpL.BackgroundTransparency=1; hpL.Font=Enum.Font.Gotham; hpL.TextSize=12
    hpL.Parent=bb; o.HealthLabel=hpL

    local wpL = Instance.new("TextLabel")
    wpL.Size=UDim2.new(1,0,0.18,0); wpL.Position=UDim2.new(0,0,0.64,0)
    wpL.BackgroundTransparency=1; wpL.TextColor3=Color3.fromRGB(255,255,255)
    wpL.Font=Enum.Font.Gotham; wpL.TextSize=11; wpL.Parent=bb; o.WeaponLabel=wpL

    if F.ESP_Chams then
        local hl = Instance.new("Highlight")
        hl.Name="ZuzyHL"; hl.Adornee=char
        hl.FillTransparency=F.ESP_FillTransparency; hl.OutlineTransparency=F.ESP_OutlineTransparency
        hl.DepthMode = F.ESP_Through and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        hl.Parent=char; o.Highlight=hl
    end

    if F.ESP_Boxes then
        local bx = Instance.new("BoxHandleAdornment")
        bx.Name="ZuzyBox"; bx.Adornee=root; bx.Size=Vector3.new(4,6,2)
        bx.Transparency=0.5; bx.AlwaysOnTop=F.ESP_Through; bx.Parent=root; o.Box=bx
    end

    if F.ESP_HeadDot then
        local dot = Instance.new("BillboardGui")
        dot.Name="ZuzyDot"; dot.Adornee=head
        dot.Size=UDim2.new(0,F.ESP_HeadDotSize*2,0,F.ESP_HeadDotSize*2)
        dot.AlwaysOnTop=F.ESP_Through; dot.Parent=head
        local circle = Instance.new("Frame")
        circle.Size=UDim2.new(1,0,1,0); circle.BackgroundColor3=Color3.fromRGB(255,255,255)
        circle.BorderSizePixel=0; circle.Parent=dot
        Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
        o.HeadDot=dot; o.HeadDotFrame=circle
    end

    if F.ESP_Tracers then
        local line = Instance.new("LineHandleAdornment")
        line.Name="ZuzyTracer"; line.Adornee=root; line.Length=0
        line.Thickness=1; line.AlwaysOnTop=F.ESP_Through; line.Parent=root
        o.Tracer=line
    end

    if F.ESP_Skeleton then
        local folder = Instance.new("Folder"); folder.Name="ZuzySkel"; folder.Parent=char
        o.Skeleton = {}
        local function mkLine(a, b)
            if not a or not b then return end
            local l = Instance.new("LineHandleAdornment")
            l.Adornee=a; l.Length=(a.Position-b.Position).Magnitude
            l.Thickness=F.ESP_SkeletonThickness; l.AlwaysOnTop=F.ESP_Through
            l.Color3=Color3.fromRGB(255,255,255); l.Parent=folder
            table.insert(o.Skeleton, { line=l, a=a, b=b })
        end
        local torso = char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
        local lArm  = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local rArm  = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        local lLeg  = char:FindFirstChild("Left Leg") or char:FindFirstChild("LeftUpperLeg")
        local rLeg  = char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg")
        if head and torso then mkLine(head, torso) end
        if torso then
            mkLine(torso, lArm); mkLine(torso, rArm); mkLine(torso, lLeg); mkLine(torso, rLeg)
        end
    end

    if F.ESP_Facing then
        local f = Instance.new("BillboardGui")
        f.Name="ZuzyFace"; f.Adornee=head
        f.Size=UDim2.new(0,40,0,40); f.StudsOffset=Vector3.new(0,-1,0)
        f.AlwaysOnTop=F.ESP_Through; f.Parent=head
        local arrow = Instance.new("TextLabel")
        arrow.Size=UDim2.new(1,0,1,0); arrow.BackgroundTransparency=1
        arrow.Text="▲"; arrow.TextColor3=Color3.fromRGB(255,255,255)
        arrow.TextStrokeTransparency=0; arrow.Font=Enum.Font.GothamBold
        arrow.TextSize=24; arrow.Parent=f
        o.Facing=f; o.FacingArrow=arrow
    end

    ESPObjects[plr] = o
end

local function refreshESP()
    clearAllESP()
    if not F.ESP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then pcall(createESP, plr) end
    end
end

--------------------------- FOV CIRCLE ---------------------------
local function updateFOVCircle()
    if not F.ESP_FOVCircle then
        if FOVCircleObj then FOVCircleObj:Destroy(); FOVCircleObj = nil end
        return
    end
    if not FOVCircleObj or not FOVCircleObj.Parent then
        FOVCircleObj = Instance.new("ScreenGui")
        FOVCircleObj.Name="ZuzyFOV"; FOVCircleObj.ResetOnSpawn=false
        FOVCircleObj.IgnoreGuiInset=true; FOVCircleObj.Parent=CoreGui
        local circle = Instance.new("Frame")
        circle.Name="Circle"; circle.BackgroundTransparency=1
        circle.Parent=FOVCircleObj
        local stroke = Instance.new("UIStroke")
        stroke.Name="Stroke"; stroke.Thickness=1.5
        stroke.Color=Color3.fromRGB(255,255,255); stroke.Transparency=0.3
        stroke.Parent=circle
        Instance.new("UICorner",circle).CornerRadius=UDim.new(1,0)
    end
    local circle = FOVCircleObj:FindFirstChild("Circle")
    if circle then
        local r = F.ESP_FOVRadius
        circle.Size = UDim2.new(0, r*2, 0, r*2)
        circle.Position = UDim2.new(0.5, -r, 0.5, -r)
    end
end

--------------------------- TROLLS ---------------------------
local function Fling(plr)
    pcall(function()
        if not plr or not plr.Character then return end
        local r = plr.Character:FindFirstChild("HumanoidRootPart"); if not r then return end
        local bv = Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Parent=r
        if F.FlingType=="Strong" then bv.Velocity=Vector3.new(math.random(-250,250),math.random(150,250),math.random(-250,250))
        elseif F.FlingType=="Up" then bv.Velocity=Vector3.new(0,math.random(300,450),0)
        else bv.Velocity=Vector3.new(math.random(-140,140),math.random(90,150),math.random(-140,140)) end
        task.delay(0.35, function() if bv then bv:Destroy() end end)
    end)
end
local function Freeze(p,s) local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=s and 0 or 16; h.JumpPower=s and 0 or 50 end end
local function MakeInvis(p,s) if not p or not p.Character then return end; for _, x in ipairs(p.Character:GetDescendants()) do if x:IsA("BasePart") or x:IsA("Decal") then x.Transparency=s and 1 or 0 end end end
local function ForceSit(p) local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then h.Sit=true end end
local function SpinT(p,s) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local av = r:FindFirstChild("SpinAV"); if s and not av then av=Instance.new("BodyAngularVelocity"); av.MaxTorque=Vector3.new(9e9,9e9,9e9); av.AngularVelocity=Vector3.new(0,20,0); av.Parent=r; av.Name="SpinAV" elseif not s and av then av:Destroy() end end
local function Explode(p) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local e=Instance.new("Explosion"); e.BlastRadius=10; e.BlastPressure=0; e.Position=r.Position; e.Parent=Workspace; Debris:AddItem(e,0.5) end
local function PushPull(p,d) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local bv=Instance.new("BodyVelocity"); bv.MaxForce=Vector3.new(9e9,9e9,9e9); bv.Velocity=d*120; bv.Parent=r; task.delay(0.5,function() if bv then bv:Destroy() end end) end
local function SwapPos() local a,b = GetMyRoot(), GetTargetRoot(); if not a or not b then return end; local pa,pb = a.Position, b.Position; a.CFrame=CFrame.new(pb); b.CFrame=CFrame.new(pa) end

local EmoteTracks = {}
local function clearEmotes() for _, t in ipairs(EmoteTracks) do pcall(function() t:Stop(); t:Destroy() end) end EmoteTracks = {} end
local function PlayEmote(p, id)
    if not p or not p.Character then return end
    local anim = p.Character:FindFirstChildOfClass("Animator")
    if not anim then anim=Instance.new("Animator"); local h=p.Character:FindFirstChildOfClass("Humanoid"); if h then anim.Parent=h end end
    if not anim then return end
    local track = anim:LoadAnimation(Instance.new("Animation"))
    track.AnimationId=id; track:Play(); table.insert(EmoteTracks, track)
end

--------------------------- MOVEMENT ---------------------------
local function ApplyStats() pcall(function() local h = GetMyHum(); if h then h.WalkSpeed=F.SpeedBoost and 42 or F.WalkSpeed; h.JumpPower=F.SuperJump and 120 or F.JumpPower end end) end
local function ApplyNoclip() pcall(function() local c = LocalPlayer.Character; if not c then return end; local cc = F.NoclipType=="None"; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=cc end end end) end
local BodyVel, BodyGyro
local function SetupFly() local r = GetMyRoot(); if not r then return end; if BodyVel then BodyVel:Destroy() end; if BodyGyro then BodyGyro:Destroy() end; if F.FlyType ~= "None" then BodyVel=Instance.new("BodyVelocity"); BodyVel.MaxForce=Vector3.new(9e9,9e9,9e9); BodyVel.Parent=r; BodyGyro=Instance.new("BodyGyro"); BodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9); BodyGyro.P=20000; BodyGyro.Parent=r end end
local function CleanFly() if BodyVel then BodyVel:Destroy(); BodyVel=nil end; if BodyGyro then BodyGyro:Destroy(); BodyGyro=nil end end
local OT = {}
local function SetInvis(s) pcall(function() local c = LocalPlayer.Character; if not c then return end; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then if s then if not OT[p] then OT[p]=p.Transparency end; p.Transparency=1 else if OT[p] then p.Transparency=OT[p] end end end end; if not s then table.clear(OT) end end) end

local function OnChar()
    task.wait(0.5); ApplyStats(); ApplyNoclip()
    if F.FlyType ~= "None" then SetupFly() end
    if F.Invisible then SetInvis(true) end
    if F.ESP then task.delay(0.4, refreshESP) end
    if F.ESP_FOVCircle then updateFOVCircle() end
end
if LocalPlayer.Character then OnChar() end
LocalPlayer.CharacterAdded:Connect(OnChar)

--------------------------- DEBUG OVERLAY ---------------------------
local DebugGui, DebugLabels, DebugConnections = nil, {}, {}
local function setupDebugGui()
    if DebugGui then return end
    DebugGui = Instance.new("ScreenGui")
    DebugGui.Name="ZuzyDebug"; DebugGui.ResetOnSpawn=false
    DebugGui.IgnoreGuiInset=true; DebugGui.Parent=CoreGui
    local frame = Instance.new("Frame")
    frame.Size=UDim2.new(0,240,0,180); frame.Position=UDim2.new(0,10,0.5,-90)
    frame.BackgroundColor3=Color3.fromRGB(0,0,0); frame.BackgroundTransparency=0.3
    frame.BorderSizePixel=0; frame.Parent=DebugGui
    Instance.new("UICorner",frame).CornerRadius=UDim.new(0,8)
    local title = Instance.new("TextLabel")
    title.Size=UDim2.new(1,0,0,24); title.BackgroundTransparency=1
    title.Text="ZUZIFY DEBUG"; title.TextColor3=Color3.fromRGB(0,220,180)
    title.Font=Enum.Font.GothamBold; title.TextSize=14; title.Parent=frame
    local function mkLabel(y)
        local l = Instance.new("TextLabel")
        l.Size=UDim2.new(1,-12,0,20); l.Position=UDim2.new(0,6,0,y)
        l.BackgroundTransparency=1; l.TextColor3=Color3.fromRGB(220,220,230)
        l.Font=Enum.Font.Code; l.TextSize=12
        l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=frame
        return l
    end
    DebugLabels.fps      = mkLabel(28)
    DebugLabels.ping     = mkLabel(48)
    DebugLabels.memory   = mkLabel(68)
    DebugLabels.players  = mkLabel(88)
    DebugLabels.selfinfo = mkLabel(108)
    DebugLabels.role     = mkLabel(128)
    DebugLabels.uptime   = mkLabel(148)
end
local function teardownDebugGui()
    if DebugGui then DebugGui:Destroy(); DebugGui=nil; DebugLabels={} end
end

local bootTime = tick()
local fpsAccum, fpsFrames, fpsLast = 0, 0, tick()

--------------------------- MAIN LOOP ---------------------------
local lastHeavy, lastAnti = 0, 0
local lastSafe = Vector3.new(0,10,0)
local jumpDebounce = 0

RunService.RenderStepped:Connect(function()
    local now = tick()
    local char = LocalPlayer.Character
    local root = GetMyRoot()
    local hum  = GetMyHum()
    if root and root.Position.Y > -50 then lastSafe = root.Position end

    -----------------------------------------------------------
    -- DEBUG OVERLAY UPDATE
    -----------------------------------------------------------
    if F.Debug_Overlay then
        if not DebugGui then setupDebugGui() end
        fpsFrames = fpsFrames + 1
        if now - fpsLast >= 0.5 then
            local fps = fpsFrames / (now - fpsLast)
            fpsFrames = 0; fpsLast = now
            if DebugLabels.fps then DebugLabels.fps.Text = string.format("FPS: %.0f", fps) end
        end
        if now - (DebugLabels._lastPingUpdate or 0) > 1 then
            DebugLabels._lastPingUpdate = now
            pcall(function()
                local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                if DebugLabels.ping then DebugLabels.ping.Text = string.format("Ping: %d ms", math.floor(ping)) end
            end)
            pcall(function()
                local mem = Stats:GetTotalMemoryUsageMb()
                if DebugLabels.memory then DebugLabels.memory.Text = string.format("Memory: %.1f MB", mem) end
            end)
        end
        if DebugLabels.players then DebugLabels.players.Text = "Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers end
        if DebugLabels.selfinfo then
            DebugLabels.selfinfo.Text = string.format("Pos: %.0f, %.0f, %.0f", root and root.Position.X or 0, root and root.Position.Y or 0, root and root.Position.Z or 0)
        end
        if DebugLabels.role then DebugLabels.role.Text = "Role: "..myRole.." | Rank: "..MY_ROLE end
        if DebugLabels.uptime then
            local up = os.date("!%H:%M:%S", math.floor(now - bootTime))
            DebugLabels.uptime.Text = "Uptime: "..up
        end
    elseif DebugGui then
        teardownDebugGui()
    end

    -----------------------------------------------------------
    -- HEAVY TASKS (throttled)
    -----------------------------------------------------------
    if now - lastHeavy > F.ESP_RefreshRate then
        lastHeavy = now
        if F.ESP and root then
            for plr, o in pairs(ESPObjects) do
                local c = plr.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    local tr = c.HumanoidRootPart
                    local h  = c:FindFirstChildOfClass("Humanoid")
                    local dead = not h or h.Health <= 0
                    local d = (root.Position - tr.Position).Magnitude
                    local role = GetRole(plr)

                    -- Visibility filters
                    local visible = true
                    if d > F.ESP_MaxDistance then visible = false end
                    if F.ESP_DeadCheck and dead then visible = false end
                    if F.ESP_ShowOnlyMurderer and role ~= "Murderer" then visible = false end
                    if F.ESP_ShowOnlySheriff and role ~= "Sheriff" then visible = false end

                    -- Apply visibility
                    if o.Billboard then o.Billboard.Enabled = visible and (F.ESP_Names or F.ESP_Distance or F.ESP_Health or F.ESP_Weapon) end
                    if o.Highlight then o.Highlight.Enabled = visible end
                    if o.Box then o.Box.Visible = visible end
                    if o.Tracer then o.Tracer.Visible = visible end
                    if o.HeadDot then o.HeadDot.Enabled = visible end
                    if o.Facing then o.Facing.Enabled = visible end
                    if o.Skeleton then for _, s in ipairs(o.Skeleton) do s.line.Visible = visible end end

                    if visible then
                        local col = getESPColor(plr, d)

                        if o.NameLabel then
                            o.NameLabel.Text = plr.Name.." ["..role.."]"
                            o.NameLabel.TextColor3 = col
                            o.NameLabel.Visible = F.ESP_Names
                        end
                        if o.DistLabel then
                            o.DistLabel.Text = string.format("%d studs", math.floor(d))
                            o.DistLabel.TextColor3 = col
                            o.DistLabel.Visible = F.ESP_Distance
                        end
                        if o.HealthLabel then
                            local hp = h and math.floor(h.Health) or 0
                            local mx = h and math.floor(h.MaxHealth) or 100
                            o.HealthLabel.Text = "HP: "..hp.."/"..mx
                            o.HealthLabel.TextColor3 = hp > mx*0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
                            o.HealthLabel.Visible = F.ESP_Health
                        end
                        if o.WeaponLabel then
                            local tool = c:FindFirstChildOfClass("Tool")
                            o.WeaponLabel.Text = tool and ("Weapon: "..tool.Name) or ""
                            o.WeaponLabel.Visible = F.ESP_Weapon and tool ~= nil
                        end

                        if o.Highlight then o.Highlight.FillColor = col; o.Highlight.OutlineColor = col end
                        if o.Box then o.Box.Color3 = col end
                        if o.HeadDotFrame then o.HeadDotFrame.BackgroundColor3 = col end
                        if o.FacingArrow then
                            o.FacingArrow.TextColor3 = col
                            local lv = tr.CFrame.LookVector
                            local yaw = math.deg(math.atan2(-lv.X, -lv.Z))
                            o.FacingArrow.Rotation = yaw
                        end
                        if o.Skeleton then
                            for _, s in ipairs(o.Skeleton) do
                                s.line.Color3 = col
                                pcall(function()
                                    s.line.Length = (s.a.Position - s.b.Position).Magnitude
                                end)
                            end
                        end
                        if o.Tracer then
                            o.Tracer.Color3 = col
                            local targetPos = tr.Position
                            local origin
                            if F.ESP_TracersMode == "Bottom" then
                                origin = Vector3.new(Camera.CFrame.Position.X, Camera.CFrame.Position.Y - 5, Camera.CFrame.Position.Z)
                            else
                                origin = Camera.CFrame.Position + Camera.CFrame.UpVector * 2
                            end
                            local dir = (targetPos - origin)
                            o.Tracer.Length = dir.Magnitude
                            o.Tracer.CFrame = CFrame.lookAt(origin, targetPos)
                        end
                    end
                else
                    clearESP(plr)
                end
            end
        end
    end

    if not root or not hum then return end

    -----------------------------------------------------------
    -- MOVEMENT
    -----------------------------------------------------------
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
        BodyVel.Velocity = dir
        BodyGyro.CFrame = CFrame.new(root.Position, root.Position + cam.LookVector)
    end

    if F.CFrameSpeed then
        local cam = Camera.CFrame; local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
        dir = Vector3.new(dir.X,0,dir.Z)
        if dir.Magnitude > 0 then root.CFrame += dir.Unit * F.CFrameSpeedValue end
    end

    -----------------------------------------------------------
    -- INFINITE JUMP (FIXED — proper state gating & cooldown)
    -----------------------------------------------------------
    if F.InfiniteJump then
        local state = hum:GetState()
        local canJump = (now - jumpDebounce) > F.InfiniteJumpCooldown
        local validState = state == Enum.HumanoidStateType.Freefall
                       or state == Enum.HumanoidStateType.Running
                       or state == Enum.HumanoidStateType.RunningNoPhysics
                       or state == Enum.HumanoidStateType.Landed
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) and canJump and validState then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            jumpDebounce = now
        end
    end

    -----------------------------------------------------------
    -- BUNNY HOP (FIXED — requires movement input)
    -----------------------------------------------------------
    if F.BunnyHop then
        local moving = not F.BunnyHopRequireMove or hum.MoveDirection.Magnitude > 0.1
        if moving and hum.FloorMaterial ~= Enum.Material.Air and (now - jumpDebounce) > F.BunnyHopCooldown then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            jumpDebounce = now
        end
    end

    if F.Wallclimb then
        local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
        local hit = Workspace:FindPartOnRay(ray, char)
        if hit and hum.FloorMaterial == Enum.Material.Air then root.CFrame += Vector3.new(0,0.5,0) end
    end
    if F.Dash and UserInputService:IsKeyDown(Enum.KeyCode.Space) and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and (now - jumpDebounce) > 0.5 then
        jumpDebounce = now
        local d = Camera.CFrame.LookVector * F.DashPower
        root.AssemblyLinearVelocity = Vector3.new(d.X, 0, d.Z)
    end
    if F.TeleportToMouse and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local m = UserInputService:GetMouseLocation()
        local r = Camera:ScreenPointToRay(m.X, m.Y)
        local _, pos = Workspace:FindPartOnRay(Ray.new(r.Origin, r.Direction*1000), char)
        if pos then root.CFrame = CFrame.new(pos + Vector3.new(0,3,0)) end
    end

    -----------------------------------------------------------
    -- ANTI
    -----------------------------------------------------------
    if F.AntiFling and root.AssemblyLinearVelocity.Magnitude > 160 then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    if F.AntiDie and hum.Health < hum.MaxHealth*0.2 then hum.Health = hum.MaxHealth end
    if F.AntiVoid and root.Position.Y < -50 then
        root.CFrame = CFrame.new(lastSafe + Vector3.new(0,5,0))
        root.AssemblyLinearVelocity = Vector3.zero
    end
    if F.AntiSit and hum.Sit then hum.Sit = false end
    if F.AntiRagdoll then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running); hum.PlatformStand = false end) end
    if F.AntiTrip then
        pcall(function()
            local s = hum:GetState()
            if s == Enum.HumanoidStateType.FallingDown or s == Enum.HumanoidStateType.Ragdoll then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end)
    end

    -----------------------------------------------------------
    -- ANTI AFK (FIXED — uses mouse, not keyboard)
    -----------------------------------------------------------
    if F.AntiAFK and (now - lastAnti) > F.AntiAFKInterval then
        lastAnti = now
        pcall(function()
            local x, y = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
            VirtualInputManager:SendMouseMoveEvent(x + math.random(-30,30), y + math.random(-30,30), false, game)
        end)
    end

    if Camera.FieldOfView ~= F.CustomFOV then Camera.FieldOfView = F.CustomFOV end

    -----------------------------------------------------------
    -- ORBIT / CARRIES / TARGET
    -----------------------------------------------------------
    if F.Orbit and F.SelectedTarget then
        local t = GetTarget()
        local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
        if tr then
            local a = (now * F.OrbitSpeed) % (math.pi * 2)
            root.CFrame = CFrame.new(tr.Position) * CFrame.Angles(0, a, 0) * CFrame.new(0, 2, F.OrbitDist)
        end
    end
    if F.LoopBehind and F.SelectedTarget then local tr=GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0,0,3.5) end end
    if F.Piggyback then local tr=GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0,3.1,0.2) end end
    if F.FrontCarry then local tr=GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0,0,-3.1) end end
    if F.SideCarry then local tr=GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(2.7,0.4,0) end end
    if F.KillTarget then
        local tr = GetTargetRoot()
        if tr then
            root.CFrame = tr.CFrame * CFrame.new(0,0,2.5)
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then pcall(function() tool:Activate() end) end
        end
    end

    -----------------------------------------------------------
    -- COMBAT
    -----------------------------------------------------------
    if F.Aimbot or F.SilentAim then
        local t = GetClosest(F.AimbotFOV)
        if t and t.Character then
            local part = t.Character:FindFirstChild(F.AimPart) or t.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local goal = part.Position + part.AssemblyLinearVelocity * F.AimbotPrediction
                if F.SilentAim then
                    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, goal)
                else
                    Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, goal), F.AimbotSmooth)
                end
            end
        end
    end
    if F.AutoKill and (now - jumpDebounce) > 1.2 then
        jumpDebounce = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
    end
    if F.AutoShoot and (now - jumpDebounce) > 0.4 then
        jumpDebounce = now
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            local n = string.lower(tool.Name)
            if n:find("gun") or n:find("revolver") then pcall(function() tool:Activate() end) end
        end
    end
    if F.KnifeAura then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                if tr and (root.Position - tr.Position).Magnitude < F.AuraRange then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
        end
    end
    if F.FlingNearest and (now - jumpDebounce) > 0.55 then
        jumpDebounce = now
        local c = GetClosest(55); if c then Fling(c) end
    end
    if F.FlingTarget and F.SelectedTarget and (now - jumpDebounce) > 0.4 then
        jumpDebounce = now; local t=GetTarget(); if t then Fling(t) end
    end
    if F.FlingAll and (now - jumpDebounce) > 0.85 then
        jumpDebounce = now
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Fling(p) end end
    end

    -----------------------------------------------------------
    -- TARGET TROLLS
    -----------------------------------------------------------
    local t = GetTarget()
    if t and t.Character then
        if F.FreezeTarget then Freeze(t,true) else Freeze(t,false) end
        if F.InvisibleTarget then MakeInvis(t,true) else MakeInvis(t,false) end
        if F.SpinTarget then SpinT(t,true) else SpinT(t,false) end
        if F.PlatformTarget then
            local tr = t.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                if not tr:FindFirstChild("ZuzyPlat") then
                    local p = Instance.new("Part"); p.Name="ZuzyPlat"
                    p.Size=Vector3.new(8,1,8); p.Anchored=true; p.CanCollide=true
                    p.Material=Enum.Material.Neon; p.Color=Color3.fromRGB(0,200,160)
                    p.CFrame=CFrame.new(tr.Position-Vector3.new(0,3,0)); p.Parent=tr
                end
            end
        else
            for _, pl in ipairs(Workspace:GetDescendants()) do
                if pl.Name == "ZuzyPlat" then pl:Destroy() end
            end
        end
        if F.DisableJumpTarget then
            local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=0 end
        else
            local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower=50 end
        end
        if F.DisableMoveTarget then
            local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=0 end
        else
            local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=16 end
        end
        if F.SlowMotionTarget then
            local h=t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed=4 end
        end
    end
    if F.FreezeAll then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Freeze(p,true) end end
    else for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Freeze(p,false) end end end
    if F.SpinAll then for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then SpinT(p,true) end end
    else for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then SpinT(p,false) end end end

    if F.RainbowSelf then
        local hue = now % 1; local c = Color3.fromHSV(hue,1,1)
        for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.Color = c end end
    end
end)

--------------------------- UI TABS ---------------------------
-- HOME
local Home = window:CreateTab({ name="Home" })
Home:CreateSection({ name="Account" })
Home:CreateButton({ name="Status", callback=function()
    N("Status",
      "User: "..MY_USERNAME.." ("..MY_UID..")\n"..
      "Role: "..string.upper(MY_ROLE).."\n"..
      "Tier: "..string.upper(MY_TIER).."\n"..
      "Trusted: "..tostring(userRow.is_trusted or false).."\n"..
      "Warnings: "..tostring(userRow.warn_count or 0).."\n"..
      "Version: "..VERSION, 10)
end })

-- SETTINGS
local Settings = window:CreateTab({ name="Settings" })
Settings:CreateSection({ name="Config" })
Settings:CreateToggle({ name="Auto Save", default=ConfigState.AutoSave, callback=function(v) ConfigState.AutoSave=v end })
Settings:CreateToggle({ name="Auto Load", default=ConfigState.AutoLoad, callback=function(v) ConfigState.AutoLoad=v end })
Settings:CreateButton({ name="Save Config", callback=function()
    pcall(function() Rayfield:SaveConfiguration(CONFIG_FILE) end); N("Config","Saved.",4)
end })
Settings:CreateButton({ name="Load Config", callback=function()
    pcall(function() Rayfield:LoadConfiguration(CONFIG_FILE) end); N("Config","Loaded.",4)
end })
Settings:CreateButton({ name="Reset Config", callback=function()
    pcall(function() Rayfield:ResetConfiguration() end); N("Config","Reset. Rejoin to apply.",4)
end })

Settings:CreateSection({ name="Info" })
Settings:CreateButton({ name="Version: "..VERSION, callback=function() N("Version", VERSION.."\n"..CREDITS, 8) end })
Settings:CreateButton({ name="Credits", callback=function() N("Credits", CREDITS, 8) end })

Settings:CreateSection({ name="Privacy" })
Settings:CreateToggle({ name="Share Username", default=F.ShareUsername, callback=function(v)
    F.ShareUsername = v; pushUserUpdate({ show_username=v })
    if v then
        if HasTier(MY_TIER,"basic") then
            sbPatch("zuzify_users","user_id=eq."..MY_UID,{ is_trusted=true })
            userRow.is_trusted = true; N("Trusted","You are now Trusted!",6)
        else
            N("Trusted","Opted in. Buy a key to become Trusted.",6)
        end
    end
end })

Settings:CreateSection({ name="Theme" })
Settings:CreateDropdown({ name="Theme", options=ThemeNames, callback=function(v)
    local n=DD(v); if Themes[n] then window:ChangeTheme(Themes[n]); N("Theme",n,3) end
end })
Settings:CreateSlider({ name="FOV", range={50,120}, value=70, callback=function(v) F.CustomFOV=v end })
Settings:CreateToggle({ name="Fullbright", callback=function(v)
    F.Fullbright=v
    pcall(function()
        if v then Lighting.Ambient=Color3.fromRGB(255,255,255); Lighting.Brightness=2; Lighting.ClockTime=14
        else Lighting.Ambient=Color3.fromRGB(70,70,70); Lighting.Brightness=1; Lighting.ClockTime=14 end
    end)
end })

-- VISUALS
local Visuals = window:CreateTab({ name="Visuals" })
Visuals:CreateSection({ name="ESP Core" })
Visuals:CreateToggle({ name="Enable ESP", callback=function(v) F.ESP=v; if v then refreshESP() else clearAllESP() end end })
Visuals:CreateToggle({ name="Names + Role", callback=function(v) F.ESP_Names=v end })
Visuals:CreateToggle({ name="Distance", callback=function(v) F.ESP_Distance=v end })
Visuals:CreateToggle({ name="Health", callback=function(v) F.ESP_Health=v end })
Visuals:CreateToggle({ name="Weapon", callback=function(v) F.ESP_Weapon=v end })
Visuals:CreateToggle({ name="Chams", callback=function(v) F.ESP_Chams=v; refreshESP() end })
Visuals:CreateToggle({ name="Boxes", callback=function(v) F.ESP_Boxes=v; refreshESP() end })
Visuals:CreateToggle({ name="Tracers", callback=function(v) F.ESP_Tracers=v; refreshESP() end })
Visuals:CreateDropdown({ name="Tracer Mode", options={"Top","Bottom"}, callback=function(v) F.ESP_TracersMode=DD(v) end })
Visuals:CreateToggle({ name="Head Dot", callback=function(v) F.ESP_HeadDot=v; refreshESP() end })
Visuals:CreateToggle({ name="Facing Arrow", callback=function(v) F.ESP_Facing=v; refreshESP() end })
Visuals:CreateToggle({ name="Skeleton", callback=function(v) F.ESP_Skeleton=v; refreshESP() end })
Visuals:CreateSlider({ name="Skeleton Thickness", range={1,4}, value=1, callback=function(v) F.ESP_SkeletonThickness=v end })

Visuals:CreateSection({ name="ESP Filters" })
Visuals:CreateSlider({ name="Max Distance", range={100,5000}, value=1500, callback=function(v) F.ESP_MaxDistance=v end })
Visuals:CreateToggle({ name="Team Check", default=true, callback=function(v) F.ESP_TeamCheck=v end })
Visuals:CreateToggle({ name="Hide Dead", default=true, callback=function(v) F.ESP_DeadCheck=v end })
Visuals:CreateToggle({ name="Only Murderer", callback=function(v) F.ESP_ShowOnlyMurderer=v end })
Visuals:CreateToggle({ name="Only Sheriff", callback=function(v) F.ESP_ShowOnlySheriff=v end })
Visuals:CreateToggle({ name="Through Walls (AlwaysOnTop)", default=true, callback=function(v) F.ESP_Through=v; refreshESP() end })

Visuals:CreateSection({ name="ESP Colors" })
Visuals:CreateDropdown({ name="Color Mode", options={"Role","Distance","Health","Static"}, callback=function(v) F.ESP_ColorMode=DD(v) end })
Visuals:CreateSlider({ name="Fill Transparency", range={0,1}, value=0.5, callback=function(v) F.ESP_FillTransparency=v; refreshESP() end })
Visuals:CreateSlider({ name="Outline Transparency", range={0,1}, value=0.1, callback=function(v) F.ESP_OutlineTransparency=v; refreshESP() end })

Visuals:CreateSection({ name="Aim Assist Visuals" })
Visuals:CreateToggle({ name="FOV Circle", callback=function(v) F.ESP_FOVCircle=v; updateFOVCircle() end })
Visuals:CreateSlider({ name="FOV Radius", range={50,400}, value=140, callback=function(v) F.ESP_FOVRadius=v; updateFOVCircle() end })

-- MOVEMENT
local Movement = window:CreateTab({ name="Movement" })
Movement:CreateSection({ name="Basic" })
Movement:CreateDropdown({ name="Noclip", options={"None","Normal","Full"}, callback=function(v) F.NoclipType=DD(v); ApplyNoclip() end })
Movement:CreateDropdown({ name="Fly", options={"None","BodyVelocity"}, callback=function(v) F.FlyType=DD(v); if F.FlyType=="None" then CleanFly() else SetupFly() end end })
Movement:CreateSlider({ name="Fly Speed", range={10,250}, value=60, callback=function(v) F.FlySpeed=v end })
Movement:CreateToggle({ name="Infinite Jump", callback=function(v) F.InfiniteJump=v end })
Movement:CreateSlider({ name="Infinite Jump Cooldown", range={0.1,1}, value=0.35, callback=function(v) F.InfiniteJumpCooldown=v end })
Movement:CreateSlider({ name="Walk Speed", range={10,150}, value=16, callback=function(v) F.WalkSpeed=v; ApplyStats() end })
Movement:CreateSlider({ name="Jump Power", range={30,200}, value=50, callback=function(v) F.JumpPower=v; ApplyStats() end })
Movement:CreateToggle({ name="Speed Boost", callback=function(v) F.SpeedBoost=v; ApplyStats() end })
Movement:CreateToggle({ name="Super Jump", callback=function(v) F.SuperJump=v; ApplyStats() end })
Movement:CreateToggle({ name="Bunny Hop", callback=function(v) F.BunnyHop=v end })
Movement:CreateToggle({ name="Bunny Hop Require Move", default=true, callback=function(v) F.BunnyHopRequireMove=v end })
Movement:CreateSlider({ name="Bunny Hop Cooldown", range={0.1,0.5}, value=0.25, callback=function(v) F.BunnyHopCooldown=v end })
Movement:CreateToggle({ name="Wallclimb", callback=function(v) F.Wallclimb=v end })
Movement:CreateToggle({ name="Dash (Space+Shift)", callback=function(v) F.Dash=v end })
Movement:CreateSlider({ name="Dash Power", range={10,80}, value=30, callback=function(v) F.DashPower=v end })
Movement:CreateToggle({ name="CFrame Speed", callback=function(v) F.CFrameSpeed=v end })
Movement:CreateSlider({ name="CFrame Multi", range={1,10}, value=2, callback=function(v) F.CFrameSpeedValue=v end })
Movement:CreateToggle({ name="Teleport To Mouse (RMB)", callback=function(v) F.TeleportToMouse=v end })

Movement:CreateSection({ name="Teleports" })
for name, pos in pairs(MapTeleports) do
    Movement:CreateButton({ name="TP → "..name, callback=function()
        local r = GetMyRoot(); if r then r.CFrame = CFrame.new(pos+Vector3.new(0,3,0)) end
    end })
end

-- PLAYERS
local PlayersTab = window:CreateTab({ name="Players" })
local function playerNames() local l={} for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(l, p.Name) end end return l end
PlayersTab:CreateSection({ name="Target" })
PlayersTab:CreateDropdown({ name="Select Player", options=(#playerNames()>0) and playerNames() or {"None"}, callback=function(v) F.SelectedTarget=DD(v) end })
PlayersTab:CreateToggle({ name="Spectate", callback=function(v)
    if v then local t=GetTarget(); if t and t.Character then Camera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid") end
    else local h=GetMyHum(); if h then Camera.CameraSubject = h end end
end })
PlayersTab:CreateToggle({ name="Orbit", callback=function(v) F.Orbit=v end })
PlayersTab:CreateSlider({ name="Orbit Distance", range={3,20}, value=6, callback=function(v) F.OrbitDist=v end })
PlayersTab:CreateToggle({ name="Loop Behind", callback=function(v) F.LoopBehind=v end })

-- COMBAT
local Combat = window:CreateTab({ name="Combat" })
Combat:CreateSection({ name="Aim" })
Combat:CreateToggle({ name="Aimbot", callback=function(v) F.Aimbot=v end })
Combat:CreateToggle({ name="Silent Aim", callback=function(v) F.SilentAim=v end })
Combat:CreateSlider({ name="Aimbot FOV", range={50,500}, value=230, callback=function(v) F.AimbotFOV=v end })
Combat:CreateSection({ name="Kill" })
Combat:CreateToggle({ name="Auto Kill", callback=function(v) F.AutoKill=v end })
Combat:CreateToggle({ name="Auto Shoot", callback=function(v) F.AutoShoot=v end })
Combat:CreateToggle({ name="Knife Aura", callback=function(v) F.KnifeAura=v end })
Combat:CreateSlider({ name="Aura Range", range={6,40}, value=15, callback=function(v) F.AuraRange=v end })
Combat:CreateToggle({ name="Kill Selected", callback=function(v) F.KillTarget=v end })

-- TROLL
local Troll = window:CreateTab({ name="Troll" })
Troll:CreateSection({ name="Fling" })
Troll:CreateDropdown({ name="Fling Type", options={"Normal","Strong","Up"}, callback=function(v) F.FlingType=DD(v) end })
Troll:CreateToggle({ name="Fling Nearest", callback=function(v) F.FlingNearest=v end })
Troll:CreateToggle({ name="Fling Selected", callback=function(v) F.FlingTarget=v end })
Troll:CreateToggle({ name="Fling All", callback=function(v) F.FlingAll=v end })
Troll:CreateSection({ name="Carry" })
Troll:CreateToggle({ name="Piggyback", callback=function(v) F.Piggyback=v end })
Troll:CreateToggle({ name="Front Carry", callback=function(v) F.FrontCarry=v end })
Troll:CreateToggle({ name="Side Carry", callback=function(v) F.SideCarry=v end })
Troll:CreateSection({ name="Self" })
Troll:CreateToggle({ name="Invisible Self", callback=function(v) F.Invisible=v; SetInvis(v) end })
Troll:CreateToggle({ name="Rainbow Self", callback=function(v) F.RainbowSelf=v end })
Troll:CreateSection({ name="Target" })
Troll:CreateToggle({ name="Freeze Target", callback=function(v) F.FreezeTarget=v end })
Troll:CreateToggle({ name="Invisible Target", callback=function(v) F.InvisibleTarget=v end })
Troll:CreateToggle({ name="Spin Target", callback=function(v) F.SpinTarget=v end })
Troll:CreateToggle({ name="Platform Under Target", callback=function(v) F.PlatformTarget=v end })
Troll:CreateToggle({ name="Disable Jump (Target)", callback=function(v) F.DisableJumpTarget=v end })
Troll:CreateToggle({ name="Disable Movement (Target)", callback=function(v) F.DisableMoveTarget=v end })
Troll:CreateToggle({ name="Slow Motion (Target)", callback=function(v) F.SlowMotionTarget=v end })
Troll:CreateButton({ name="Force Sit", callback=function() local t=GetTarget(); if t then ForceSit(t) end end })
Troll:CreateButton({ name="Explode", callback=function() local t=GetTarget(); if t then Explode(t) end end })
Troll:CreateButton({ name="Push Away", callback=function() local t=GetTarget(); local r1,r2=GetMyRoot(),GetTargetRoot(); if t and r1 and r2 then PushPull(t,(r1.Position-r2.Position).Unit) end end })
Troll:CreateButton({ name="Pull Toward", callback=function() local t=GetTarget(); local r1,r2=GetMyRoot(),GetTargetRoot(); if t and r1 and r2 then PushPull(t,(r2.Position-r1.Position).Unit) end end })
Troll:CreateButton({ name="Swap Positions", callback=function() local t=GetTarget(); if t then SwapPos() end end })
Troll:CreateSection({ name="Mass" })
Troll:CreateToggle({ name="Freeze All", callback=function(v) F.FreezeAll=v end })
Troll:CreateToggle({ name="Spin All", callback=function(v) F.SpinAll=v end })
Troll:CreateButton({ name="Explode All", callback=function() for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Explode(p) end end end })
Troll:CreateButton({ name="Fling All (Instant)", callback=function() for _,p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then Fling(p) end end end })

-- EMOTES
local EmoteTab = window:CreateTab({ name="Emotes" })
EmoteTab:CreateSection({ name="Play" })
local eNames = {} for _,e in ipairs(EmoteList) do table.insert(eNames, e.Name) end
EmoteTab:CreateDropdown({ name="Emote", options=eNames, callback=function(v)
    local n=DD(v); for _,e in ipairs(EmoteList) do if e.Name==n then F.SelectedEmote=e.ID end end
end })
EmoteTab:CreateInput({ name="Custom ID", placeholder="rbxassetid://...", callback=function(t) if t~="" then F.SelectedEmote=t end end })
EmoteTab:CreateButton({ name="Play on Self", callback=function() if F.SelectedEmote then clearEmotes(); PlayEmote(LocalPlayer, F.SelectedEmote) end end })
EmoteTab:CreateButton({ name="Play on Target", callback=function() local t=GetTarget(); if t and F.SelectedEmote then clearEmotes(); PlayEmote(t, F.SelectedEmote) end end })
EmoteTab:CreateButton({ name="Stop Emotes", callback=clearEmotes })
EmoteTab:CreateButton({ name="Random Emote", callback=function() if #EmoteList>0 then local e=EmoteList[math.random(1,#EmoteList)]; clearEmotes(); PlayEmote(LocalPlayer, e.ID) end end })

-- ANTI
local Anti = window:CreateTab({ name="Anti" })
Anti:CreateToggle({ name="Anti AFK", default=true, callback=function(v) F.AntiAFK=v end })
Anti:CreateSlider({ name="Anti AFK Interval", range={20,300}, value=60, callback=function(v) F.AntiAFKInterval=v end })
Anti:CreateToggle({ name="Anti Fling", default=true, callback=function(v) F.AntiFling=v end })
Anti:CreateToggle({ name="Anti Die", callback=function(v) F.AntiDie=v end })
Anti:CreateToggle({ name="Anti Void", callback=function(v) F.AntiVoid=v end })
Anti:CreateToggle({ name="Anti Sit", callback=function(v) F.AntiSit=v end })
Anti:CreateToggle({ name="Anti Ragdoll", callback=function(v) F.AntiRagdoll=v end })
Anti:CreateToggle({ name="Anti Trip", callback=function(v) F.AntiTrip=v end })

-- DEBUG
local DebugTab = window:CreateTab({ name="Debug" })
DebugTab:CreateSection({ name="Overlay" })
DebugTab:CreateToggle({ name="Enable Debug Overlay", callback=function(v) F.Debug_Overlay=v; if not v then teardownDebugGui() end end })
DebugTab:CreateSection({ name="Info" })
DebugTab:CreateButton({ name="Print FPS/Ping/Mem", callback=function()
    local fps = math.floor(1/math.max(RunService.RenderStepped:Wait(), 0.0001))
    local ping, mem = "N/A", "N/A"
    pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()).." ms" end)
    pcall(function() mem = string.format("%.1f MB", Stats:GetTotalMemoryUsageMb()) end)
    N("Debug", "FPS: "..fps.."\nPing: "..ping.."\nMemory: "..mem, 8)
end })
DebugTab:CreateButton({ name="Dump Session Log", callback=function()
    local lines = {}
    for _, l in ipairs(ActionLog) do table.insert(lines, "["..os.date("%H:%M:%S", l.t).."] "..l.a) end
    N("Log ("..#ActionLog..")", table.concat(lines, "\n"):sub(1,3500), 12)
end })
DebugTab:CreateButton({ name="Clear Log", callback=function() ActionLog = {}; N("Log","Cleared.",3) end })
DebugTab:CreateButton({ name="Rebuild ESP", callback=function() refreshESP(); N("ESP","Rebuilt.",3) end })
DebugTab:CreateButton({ name="Refresh Player Cache", callback=function() CachedRoles = {}; N("Cache","Cleared.",3) end })
DebugTab:CreateButton({ name="Clear All Zuzy Parts", callback=function()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:sub(1,4) == "Zuzy" then pcall(function() obj:Destroy() end) end
    end
    N("Cleanup","Cleared.",3)
end })

-- MOD/ADMIN/OWNER MENU
if IsStaff() then
    local isAdmin = HasRole("admin") or HasRole("developer") or HasRole("owner")
    local isOwner = HasRole("owner")
    local StaffTab = window:CreateTab({ name = isOwner and "Owner Menu" or (isAdmin and "Admin Menu" or "Mod Menu") })

    StaffTab:CreateSection({ name="Live Stats" })
    StaffTab:CreateButton({ name="Online Users", callback=function()
        pcall(function()
            local d = sbGet("zuzify_sessions","last_ping=gt."..HttpService:UrlEncode(DateTime.now():AddSeconds(-180):ToIsoDate()).."&select=*")
            local cnt = d and #d or 0
            local lines = {}
            for _, s in ipairs(d or {}) do
                local label = (s.show_username and s.username) and (s.username.." ("..s.user_id..")") or ("Anon #"..tostring(s.user_id):sub(-4))
                table.insert(lines, label.." ["..s.role.."/"..s.tier.."]")
            end
            N("Online: "..cnt, table.concat(lines,"\n"):sub(1,3500), 12)
        end)
    end })
    StaffTab:CreateButton({ name="Full Stats", callback=function()
        pcall(function()
            local s = sbGet("zuzify_stats","select=*")
            if s and #s>0 then
                local r=s[1]
                N("Stats","Total Users: "..r.total_users.."\nOnline Now: "..r.online_now..
                  "\nPaid: "..r.paid_users.."\nTrusted: "..r.trusted_users..
                  "\nStaff: "..r.staff_users.."\nBanned: "..r.banned_users..
                  "\nUnused Keys: "..r.unused_keys.."\nWarnings: "..r.total_warnings..
                  "\nOpen Reports: "..r.open_reports, 12)
            end
        end)
    end })

    StaffTab:CreateSection({ name="Moderation" })
    local modTarget, modReason = "", ""
    StaffTab:CreateInput({ name="Target UserID", placeholder="1234567", callback=function(t) modTarget=t end })
    StaffTab:CreateInput({ name="Reason", placeholder="Reason", callback=function(t) modReason=t end })
    StaffTab:CreateButton({ name="Warn User", callback=function()
        if modTarget=="" or modReason=="" then N("Error","Fill fields.",4) return end
        pcall(function()
            sbPost("zuzify_warnings",{ user_id=tonumber(modTarget), moderator_id=MY_UID, moderator_name=MY_USERNAME, reason=modReason, severity=1 })
            sbPost("zuzify_audit_logs",{ action="warn", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget), reason=modReason })
            N("Warned","Issued.",4)
        end)
    end })
    StaffTab:CreateButton({ name="Kick User", callback=function()
        if modTarget=="" then return end
        pcall(function()
            sbPatch("zuzify_users","user_id=eq."..modTarget,{ kick_signal=true, kick_reason=modReason })
            sbPost("zuzify_audit_logs",{ action="kick", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget), reason=modReason })
            N("Kicked","Queued.",4)
        end)
    end })
    if isAdmin then
        local banMins = 60
        StaffTab:CreateSlider({ name="Ban Minutes (0=perm)", range={0,43200}, value=60, callback=function(v) banMins=v end })
        StaffTab:CreateButton({ name="Ban User", callback=function()
            if modTarget=="" then return end
            pcall(function()
                local until_ = banMins>0 and DateTime.now():AddSeconds(banMins*60):ToIsoDate() or nil
                sbPatch("zuzify_users","user_id=eq."..modTarget,{ is_banned=true, ban_reason=modReason, ban_until=until_, ban_by=MY_UID })
                sbPost("zuzify_audit_logs",{ action="ban", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget), reason=modReason, metadata={ duration_minutes=banMins } })
                N("Banned","Applied.",4)
            end)
        end })
        StaffTab:CreateButton({ name="Unban User", callback=function()
            if modTarget=="" then return end
            pcall(function()
                sbPatch("zuzify_users","user_id=eq."..modTarget,{ is_banned=false, ban_reason=nil, ban_until=nil })
                sbPost("zuzify_audit_logs",{ action="unban", actor_id=MY_UID, actor_name=MY_USERNAME, target_id=tonumber(modTarget) })
                N("Unbanned","Done.",4)
            end)
        end })
        StaffTab:CreateButton({ name="Add Note", callback=function()
            if modTarget=="" or modReason=="" then return end
            pcall(function()
                sbPost("zuzify_user_notes",{ user_id=tonumber(modTarget), author_id=MY_UID, author_name=MY_USERNAME, note=modReason })
                N("Note","Saved.",4)
            end)
        end })

        StaffTab:CreateSection({ name="License Keys" })
        local newTier, newDays = "premium", 30
        StaffTab:CreateDropdown({ name="Tier", options={"basic","premium","trusted","mod","developer"}, callback=function(v) newTier=DD(v) end })
        StaffTab:CreateSlider({ name="Days", range={1,3650}, value=30, callback=function(v) newDays=v end })
        StaffTab:CreateButton({ name="Generate Key", callback=function()
            pcall(function()
                local function blk() local s=""; local ch="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"; for _=1,4 do s=s..ch:sub(math.random(1,#ch),math.random(1,#ch)) end; return s end
                local key = "ZUZIFY-"..blk().."-"..blk().."-"..blk()
                sbPost("zuzify_keys",{ license_key=key, tier=newTier, created_by=MY_UID, duration_days=newDays, is_active=true })
                sbPost("zuzify_audit_logs",{ action="key_create", actor_id=MY_UID, actor_name=MY_USERNAME, metadata={ key=key, tier=newTier } })
                N("Key Created", key, 12)
                if setclipboard then setclipboard(key) end
            end)
        end })
        StaffTab:CreateButton({ name="List Keys", callback=function()
            pcall(function()
                local d = sbGet("zuzify_keys","is_active=eq.true&select=license_key,tier,used_by")
                local s = {}
                for _, k in ipairs(d or {}) do table.insert(s, k.license_key.." ["..k.tier.."] "..(k.used_by and "used" or "unused")) end
                N("Keys", table.concat(s,"\n"):sub(1,3500), 12)
            end)
        end })
    end
    if isOwner then
        StaffTab:CreateSection({ name="Owner Tools" })
        StaffTab:CreateButton({ name="Audit Logs (30)", callback=function()
            pcall(function()
                local d = sbGet("zuzify_audit_logs","select=*&order=created_at.desc&limit=30")
                local s = {}
                for _, a in ipairs(d or {}) do
                    table.insert(s, "["..(a.actor_name or a.actor_id).."] "..a.action..(a.target_id and (" → "..a.target_id) or "")..(a.reason and (": "..a.reason) or ""))
                end
                N("Audit", table.concat(s,"\n"):sub(1,3500), 15)
            end)
        end })
        StaffTab:CreateButton({ name="Set My Role → Owner", callback=function()
            sbPatch("zuzify_users","user_id=eq."..MY_UID,{ role="owner", tier="owner" })
            N("Role","Set. Rejoin.",5)
        end })
        StaffTab:CreateButton({ name="Broadcast Kick All", callback=function()
            pcall(function()
                local all = sbGet("zuzify_sessions","user_id=neq."..MY_UID.."&select=user_id")
                for _, s in ipairs(all or {}) do sbPatch("zuzify_users","user_id=eq."..s.user_id,{ kick_signal=true, kick_reason="Maintenance" }) end
                N("Broadcast","Kicked all.",5)
            end)
        end })
    end
end

--------------------------- BOOT ---------------------------
N("ZuzifyRBX "..VERSION,
  "Welcome "..MY_USERNAME.."!\nRole: "..string.upper(MY_ROLE).."\nTier: "..string.upper(MY_TIER)..
  (IsStaff() and "\n★ Staff Access" or ""), 12)
print("[ZuzifyRBX] Loaded "..VERSION.." | Role: "..MY_ROLE.." | Tier: "..MY_TIER)
