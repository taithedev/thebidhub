--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║  ZuzifyRBX Gen10.1.0 — Crash-Proof Community Edition     ║
    ║  Staged Loading • Non-Blocking • Fallback UI             ║
    ╚═══════════════════════════════════════════════════════════╝
]]

--============================================================
-- EARLY SERVICES + SAFE LOGGER
--============================================================
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local VIM              = game:GetService("VirtualInputManager")
local CoreGui          = game:GetService("CoreGui")
local Lighting         = game:GetService("Lighting")
local Debris           = game:GetService("Debris")
local Workspace        = game:GetService("Workspace")
local Stats            = game:GetService("Stats")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local MY_UID = LP.UserId
local MY_NAME = LP.Name

--============================================================
-- SAFE LOGGER
--============================================================
local SafeLog
do
    local function sanitize(s)
        s = tostring(s or "")
        s = s:gsub("https?://[%w%p]-%s", "[url] ")
        s = s:gsub("https?://[%w%p]+", "[url]")
        s = s:gsub("%d%d%d%d%d%d%d+", "[id]")
        s = s:gsub("discord[%w%._%-]*", "[ext]")
        s = s:gsub("supabase[%w%._%-]*", "[ext]")
        s = s:gsub("[%w%.%-_]+@[%w%.%-_]+", "[email]")
        s = s:gsub("%u%u%u%u%-%u%u%u%u%-%u%u%u%u%-%u%u%u%u", "[key]")
        return s
    end
    SafeLog = function(tag, msg)
        pcall(function()
            print(string.format("[Zuzy][%s] %s", tostring(tag), sanitize(msg)))
        end)
    end
end

--============================================================
-- LOADING SCREEN (so you can see progress)
--============================================================
local LoadingGui, LoadingLabel, LoadingBar, LoadingFill
do
    pcall(function()
        LoadingGui = Instance.new("ScreenGui")
        LoadingGui.Name = "ZuzyLoading"
        LoadingGui.ResetOnSpawn = false
        LoadingGui.IgnoreGuiInset = true
        LoadingGui.DisplayOrder = 999
        LoadingGui.Parent = CoreGui

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(6, 6, 10)
        bg.BackgroundTransparency = 0.15
        bg.BorderSizePixel = 0
        bg.Parent = LoadingGui

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 480, 0, 180)
        box.Position = UDim2.new(0.5, -240, 0.5, -90)
        box.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
        box.BorderSizePixel = 0
        box.Parent = LoadingGui
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 14)
        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(0, 220, 180)
        st.Thickness = 2
        st.Parent = box

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 44)
        title.BackgroundTransparency = 1
        title.Text = "ZuzifyRBX — Loading…"
        title.TextColor3 = Color3.fromRGB(0, 230, 190)
        title.Font = Enum.Font.GothamBold
        title.TextSize = 22
        title.Parent = box

        LoadingLabel = Instance.new("TextLabel")
        LoadingLabel.Size = UDim2.new(1, -40, 0, 30)
        LoadingLabel.Position = UDim2.new(0, 20, 0, 60)
        LoadingLabel.BackgroundTransparency = 1
        LoadingLabel.Text = "Starting up…"
        LoadingLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
        LoadingLabel.Font = Enum.Font.Gotham
        LoadingLabel.TextSize = 14
        LoadingLabel.TextXAlignment = Enum.TextXAlignment.Left
        LoadingLabel.Parent = box

        LoadingBar = Instance.new("Frame")
        LoadingBar.Size = UDim2.new(1, -40, 0, 12)
        LoadingBar.Position = UDim2.new(0, 20, 0, 110)
        LoadingBar.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        LoadingBar.BorderSizePixel = 0
        LoadingBar.Parent = box
        Instance.new("UICorner", LoadingBar).CornerRadius = UDim.new(1, 0)

        LoadingFill = Instance.new("Frame")
        LoadingFill.Size = UDim2.new(0, 0, 1, 0)
        LoadingFill.BackgroundColor3 = Color3.fromRGB(0, 220, 180)
        LoadingFill.BorderSizePixel = 0
        LoadingFill.Parent = LoadingBar
        Instance.new("UICorner", LoadingFill).CornerRadius = UDim.new(1, 0)
    end)
end

local function SetLoading(pct, msg)
    pcall(function()
        if LoadingLabel then LoadingLabel.Text = msg end
        if LoadingFill then LoadingFill.Size = UDim2.new(math.clamp(pct, 0, 1), 0, 1, 0) end
    end)
    SafeLog("loading", string.format("%d%% — %s", math.floor(pct*100), msg))
end

local function CloseLoading()
    pcall(function()
        if LoadingGui then LoadingGui:Destroy() end
        LoadingGui = nil
    end)
end

SetLoading(0.02, "Initializing…")

--============================================================
-- CONFIG (edit these)
--============================================================
local VERSION           = "Gen10.1.0"
local SUPABASE_URL      = "https://YOUR_PROJECT.supabase.co"
local SUPABASE_ANON_KEY = "YOUR_ANON_KEY_HERE"
local OWNER_UIDS        = { 717544874 }

--============================================================
-- HTTP
--============================================================
local httpReq = http_request or request or (syn and syn.request) or (http and http.request)

local function http(method, url, headers, body, timeout)
    if not httpReq then return nil end
    local o = { Url = url, Method = method, Headers = headers or {} }
    if body then
        o.Body = type(body) == "string" and body or HttpService:JSONEncode(body)
        o.Headers["Content-Type"] = "application/json"
    end
    for _ = 1, 3 do
        local ok, res = pcall(httpReq, o)
        if ok and res then
            local d
            pcall(function() d = HttpService:JSONDecode(res.Body) end)
            return d, res.StatusCode
        end
        task.wait(0.15)
    end
    return nil
end

local function sbHdr(x)
    local h = {
        ["apikey"]        = SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer "..SUPABASE_ANON_KEY,
        ["Content-Type"]  = "application/json",
        ["Prefer"]        = "return=representation",
    }
    if x then for k,v in pairs(x) do h[k]=v end end
    return h
end
local function sbGet(t,q)     return http("GET",   SUPABASE_URL.."/rest/v1/"..t..(q and ("?"..q) or ""), sbHdr()) end
local function sbPost(t,b)    return http("POST",  SUPABASE_URL.."/rest/v1/"..t, sbHdr(), b) end
local function sbPatch(t,q,b) return http("PATCH", SUPABASE_URL.."/rest/v1/"..t.."?"..q, sbHdr(), b) end
local function sbDelete(t,q)  return http("DELETE",SUPABASE_URL.."/rest/v1/"..t.."?"..q, sbHdr()) end
local function nowISO() return DateTime.now():ToIsoDate() end

SetLoading(0.05, "HTTP ready")

--============================================================
-- ROLE HIERARCHY
--============================================================
local ROLE_ORDER = {
    user = 0, free = 0,
    basic = 1,
    premium = 2, trusted = 2,
    moderator = 3,
    head_moderator = 4,
    admin = 5,
    head_admin = 6,
    community_manager = 7,
    developer = 8,
    owner = 9,
}
local ROLE_LABELS = {
    user = "User", basic = "Basic", premium = "Premium", trusted = "Trusted",
    moderator = "Moderator", head_moderator = "Head Moderator",
    admin = "Admin", head_admin = "Head Admin",
    community_manager = "Community Manager",
    developer = "Developer", owner = "Owner",
}
local function HasTier(c, m) return (ROLE_ORDER[c] or 0) >= (ROLE_ORDER[m] or 0) end
local function RoleLabel(r) return ROLE_LABELS[r] or r end

--============================================================
-- NON-BLOCKING DISCLAIMER (uses BindableEvent, has timeout)
--============================================================
local function showDisclaimer()
    local result = { ok = false, done = false }
    local gui, connector

    pcall(function()
        gui = Instance.new("ScreenGui")
        gui.Name = "ZuzyDisc"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 998
        gui.Parent = CoreGui

        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0, 620, 0, 460)
        fr.Position = UDim2.new(0.5, -310, 0.5, -230)
        fr.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
        fr.BorderSizePixel = 0
        fr.Parent = gui
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 14)
        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(0, 200, 160)
        st.Thickness = 1.5
        st.Parent = fr

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -40, 0, 40)
        t.Position = UDim2.new(0, 20, 0, 14)
        t.BackgroundTransparency = 1
        t.Text = "ZuzifyRBX "..VERSION.." — Disclaimer"
        t.TextColor3 = Color3.fromRGB(0, 220, 180)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 20
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = fr

        local b = Instance.new("TextLabel")
        b.Size = UDim2.new(1, -40, 0, 310)
        b.Position = UDim2.new(0, 20, 0, 60)
        b.BackgroundTransparency = 1
        b.TextColor3 = Color3.fromRGB(220, 220, 230)
        b.Font = Enum.Font.Gotham
        b.TextSize = 13
        b.TextWrapped = true
        b.TextXAlignment = Enum.TextXAlignment.Left
        b.TextYAlignment = Enum.TextYAlignment.Top
        b.Text = table.concat({
            "By using ZuzifyRBX you agree:",
            "",
            "• Third-party script. Use at your OWN RISK.",
            "• Comply with Roblox TOS.",
            "• Not responsible for bans/kicks/damage.",
            "• Data stored for licensing, moderation & community features.",
            "• Username hidden unless opted into Trusted Program.",
            "• Misuse = warn/ban (perm or timed).",
            "• 13+ only. Click ACCEPT = full responsibility.",
        }, "\n")
        b.Parent = fr

        local a = Instance.new("TextButton")
        a.Size = UDim2.new(0.45, -30, 0, 44)
        a.Position = UDim2.new(0, 20, 1, -58)
        a.BackgroundColor3 = Color3.fromRGB(0, 160, 130)
        a.Text = "ACCEPT"
        a.TextColor3 = Color3.new(1, 1, 1)
        a.Font = Enum.Font.GothamBold
        a.TextSize = 15
        a.Parent = fr
        Instance.new("UICorner", a).CornerRadius = UDim.new(0, 10)

        local d = Instance.new("TextButton")
        d.Size = UDim2.new(0.45, -30, 0, 44)
        d.Position = UDim2.new(0.5, 10, 1, -58)
        d.BackgroundColor3 = Color3.fromRGB(160, 40, 50)
        d.Text = "DECLINE"
        d.TextColor3 = Color3.new(1, 1, 1)
        d.Font = Enum.Font.GothamBold
        d.TextSize = 15
        d.Parent = fr
        Instance.new("UICorner", d).CornerRadius = UDim.new(0, 10)

        a.MouseButton1Click:Connect(function()
            result.ok = true
            result.done = true
        end)
        d.MouseButton1Click:Connect(function()
            result.ok = false
            result.done = true
        end)
    end)

    -- Wait with timeout
    local startT = tick()
    while not result.done and tick() - startT < 120 do
        task.wait(0.1)
    end

    pcall(function() if gui then gui:Destroy() end end)

    if not result.done then
        -- Timeout — auto-accept for smoothness
        SafeLog("disclaimer", "timeout — auto-accepting")
        return true
    end
    return result.ok
end

SetLoading(0.10, "Showing disclaimer…")
if not showDisclaimer() then
    pcall(function() LP:Kick("You declined the ZuzifyRBX disclaimer.") end)
    CloseLoading()
    return
end

--============================================================
-- LOAD GLOBAL SETTINGS (non-fatal)
--============================================================
SetLoading(0.15, "Loading settings…")

local GlobalSettings = {
    script_mode = "online", payment_mode = "paid_free",
    maintenance_msg = "Offline.", min_version = "Gen10.1.0",
    max_users = "0", applications_open = "true", tickets_open = "true",
}

task.spawn(function()
    pcall(function()
        local d = sbGet("zuzify_settings", "select=*")
        if d then for _, r in ipairs(d) do GlobalSettings[r.key] = r.value end end
    end)
end)

local IS_OWNER = table.find(OWNER_UIDS, MY_UID) ~= nil

-- Check modes (only kick if not owner, and only if we actually got settings)
if GlobalSettings.script_mode == "offline" and not IS_OWNER then
    pcall(function() LP:Kick("ZuzifyRBX is offline.") end)
    CloseLoading()
    return
end
if GlobalSettings.script_mode == "maintenance" and not IS_OWNER then
    pcall(function() LP:Kick("Maintenance: "..GlobalSettings.maintenance_msg) end)
    CloseLoading()
    return
end

--============================================================
-- NON-BLOCKING LICENSE POPUP
--============================================================
SetLoading(0.20, "Checking license…")

local function showLicensePopup()
    local result = { done = false, tier = "free", role = "user", key = nil }

    if IS_OWNER then
        result.tier, result.role, result.key = "owner", "owner", "OWNER"
        result.done = true
        return result
    end

    if GlobalSettings.payment_mode == "free" then
        result.tier, result.role = "free", "user"
        result.done = true
        return result
    end

    local gui
    pcall(function()
        gui = Instance.new("ScreenGui")
        gui.Name = "ZuzyLic"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 998
        gui.Parent = CoreGui

        local fr = Instance.new("Frame")
        fr.Size = UDim2.new(0, 560, 0, 420)
        fr.Position = UDim2.new(0.5, -280, 0.5, -210)
        fr.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        fr.BorderSizePixel = 0
        fr.Parent = gui
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 12)
        local st = Instance.new("UIStroke")
        st.Color = Color3.fromRGB(0, 200, 160)
        st.Thickness = 1.5
        st.Parent = fr

        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, 0, 0, 42)
        t.BackgroundTransparency = 1
        t.Text = "ZuzifyRBX "..VERSION.." — Activation"
        t.TextColor3 = Color3.fromRGB(0, 220, 180)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 19
        t.Parent = fr

        local info = Instance.new("TextLabel")
        info.Size = UDim2.new(1, -40, 0, 70)
        info.Position = UDim2.new(0, 20, 0, 48)
        info.BackgroundTransparency = 1
        info.Text = "License key (ZUZIFY-XXXX-XXXX-XXXX)\nor Continue Free."
        info.TextColor3 = Color3.fromRGB(200, 200, 215)
        info.Font = Enum.Font.Gotham
        info.TextSize = 13
        info.TextWrapped = true
        info.Parent = fr

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0.9, 0, 0, 40)
        box.Position = UDim2.new(0.05, 0, 0.42, 0)
        box.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
        box.TextColor3 = Color3.new(1, 1, 1)
        box.PlaceholderText = "ZUZIFY-0000-0000-0001"
        box.Font = Enum.Font.Gotham
        box.TextSize = 14
        box.ClearTextOnFocus = false
        box.Parent = fr
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)

        local msg = Instance.new("TextLabel")
        msg.Size = UDim2.new(1, -40, 0, 22)
        msg.Position = UDim2.new(0, 20, 0.42, 46)
        msg.BackgroundTransparency = 1
        msg.Text = ""
        msg.TextColor3 = Color3.fromRGB(255, 120, 120)
        msg.Font = Enum.Font.Gotham
        msg.TextSize = 12
        msg.Parent = fr

        local act = Instance.new("TextButton")
        act.Size = UDim2.new(0.44, -20, 0, 42)
        act.Position = UDim2.new(0.05, 0, 0.78, 0)
        act.BackgroundColor3 = Color3.fromRGB(0, 160, 130)
        act.Text = "Activate"
        act.TextColor3 = Color3.new(1, 1, 1)
        act.Font = Enum.Font.GothamBold
        act.TextSize = 14
        act.Parent = fr
        Instance.new("UICorner", act).CornerRadius = UDim.new(0, 8)

        local skip = Instance.new("TextButton")
        skip.Size = UDim2.new(0.44, -20, 0, 42)
        skip.Position = UDim2.new(0.51, 0, 0.78, 0)
        skip.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        skip.Text = "Continue Free"
        skip.TextColor3 = Color3.fromRGB(230, 230, 240)
        skip.Font = Enum.Font.GothamBold
        skip.TextSize = 14
        skip.Parent = fr
        Instance.new("UICorner", skip).CornerRadius = UDim.new(0, 8)

        if GlobalSettings.payment_mode == "paid" then
            skip.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
            skip.Text = "Paid Only"
            skip.AutoButtonColor = false
        end

        act.MouseButton1Click:Connect(function()
            local key = string.upper((box.Text:gsub("%s", "")))
            if #key < 10 then
                msg.Text = "Bad format."
                return
            end
            msg.Text = "Checking…"
            msg.TextColor3 = Color3.fromRGB(200, 200, 100)

            task.spawn(function()
                local ok, err = pcall(function()
                    local d = sbGet("zuzify_keys", "license_key=eq."..HttpService:UrlEncode(key).."&select=*")
                    if not d or #d == 0 then
                        msg.Text = "Invalid."; msg.TextColor3 = Color3.fromRGB(255,120,120); return
                    end
                    local k = d[1]
                    if not k.is_active then msg.Text = "Deactivated."; return end
                    if k.used_by and k.used_by ~= MY_UID then msg.Text = "Used."; return end
                    if k.expires_at then
                        local ok2, e = pcall(function() return DateTime.fromIsoDate(k.expires_at) end)
                        if ok2 and e and e.UnixTimestamp < os.time() then msg.Text = "Expired."; return end
                    end
                    local exp = k.duration_days and k.duration_days > 0
                        and DateTime.now():AddSeconds(k.duration_days*86400):ToIsoDate() or nil
                    sbPatch("zuzify_keys", "license_key=eq."..HttpService:UrlEncode(key),
                        { used_by = MY_UID, used_at = nowISO(), expires_at = exp })
                    sbPost("zuzify_key_redemptions", {
                        license_key = key, user_id = MY_UID, username = MY_NAME, tier = k.tier,
                    })
                    result.tier = k.tier or "basic"
                    result.role = ROLE_ORDER[result.tier] and result.tier or "user"
                    result.key = key
                    result.done = true
                end)
                if not ok then
                    msg.Text = "Network error."
                    msg.TextColor3 = Color3.fromRGB(255,120,120)
                end
            end)
        end)

        skip.MouseButton1Click:Connect(function()
            if GlobalSettings.payment_mode == "paid" and not IS_OWNER then
                msg.Text = "Free disabled."
                return
            end
            result.done = true
        end)
    end)

    -- Wait with timeout
    local startT = tick()
    while not result.done and tick() - startT < 300 do
        task.wait(0.1)
    end

    pcall(function() if gui then gui:Destroy() end end)
    return result
end

local licResult = showLicensePopup()
local acquiredTier, acquiredKey, acquiredRole = licResult.tier, licResult.key, licResult.role

--============================================================
-- REGISTER USER (non-fatal on failure)
--============================================================
SetLoading(0.30, "Registering user…")

if IS_OWNER then acquiredTier, acquiredRole = "owner", "owner" end

local userRow = { tier = acquiredTier, role = acquiredRole, is_trusted = false, show_username = false, is_banned = false, warn_count = 0 }

task.spawn(function()
    pcall(function()
        local payload = {
            user_id = MY_UID, username = MY_NAME, license_key = acquiredKey,
            tier = acquiredTier, role = acquiredRole, is_paid = (acquiredTier ~= "free"),
            last_seen = nowISO(),
        }
        local d = sbGet("zuzify_users", "user_id=eq."..MY_UID.."&select=*")
        if d and #d > 0 then
            local cur = d[1]
            if IS_OWNER then
                payload.role, payload.tier = "owner", "owner"
            else
                if cur.role and (ROLE_ORDER[cur.role] or 0) > (ROLE_ORDER[payload.role] or 0) then
                    payload.role = cur.role
                end
                if cur.tier and (ROLE_ORDER[cur.tier] or 0) > (ROLE_ORDER[payload.tier] or 0) then
                    payload.tier = cur.tier
                end
            end
            sbPatch("zuzify_users", "user_id=eq."..MY_UID, payload)
            userRow = cur
        else
            local c = sbPost("zuzify_users", payload)
            userRow = (c and #c > 0) and c[1] or userRow
        end
    end)
end)

task.wait(1) -- give registration time

if userRow.is_banned then
    pcall(function() LP:Kick("Banned: "..(userRow.ban_reason or "No reason")) end)
    CloseLoading()
    return
end

local MY_ROLE = userRow.role or acquiredRole or "user"
local MY_TIER = userRow.tier or acquiredTier or "free"
local MY_TRUSTED_FEATURES = userRow.trusted_features or {}

local function IsTrusted() return HasTier(MY_TIER, "trusted") or userRow.is_trusted == true end
local function IsMod()     return HasTier(MY_ROLE, "moderator") end
local function IsHM()      return HasTier(MY_ROLE, "head_moderator") end
local function IsAdmin()   return HasTier(MY_ROLE, "admin") end
local function IsHAdmin()  return HasTier(MY_ROLE, "head_admin") end
local function IsCM()      return HasTier(MY_ROLE, "community_manager") end
local function IsDev()     return HasTier(MY_ROLE, "developer") end
local function IsOwner()   return HasTier(MY_ROLE, "owner") end
local function IsStaff()   return IsMod() end

--============================================================
-- SESSION (background)
--============================================================
SetLoading(0.40, "Starting session…")

local JOB_ID   = game.JobId
local PLACE_ID = game.PlaceId
local SESSION_ID = nil
local lastRole, lastTier = MY_ROLE, MY_TIER
local settingsRefresh = 0

task.spawn(function()
    pcall(function()
        local c = sbPost("zuzify_sessions", {
            user_id = MY_UID, username = userRow.show_username and MY_NAME or nil,
            show_username = userRow.show_username or false, role = MY_ROLE, tier = MY_TIER,
            place_id = PLACE_ID, job_id = JOB_ID, client_version = VERSION,
        })
        if c and #c > 0 then
            SESSION_ID = c[1].id
            pcall(function()
                http("POST", SUPABASE_URL.."/rest/v1/rpc/zuzify_kill_old_sessions", sbHdr(),
                    { new_session_id = SESSION_ID, uid = MY_UID })
            end)
        end
    end)

    while true do
        task.wait(20)
        pcall(function()
            if SESSION_ID then
                sbPatch("zuzify_sessions", "id=eq."..SESSION_ID, { last_ping = nowISO() })
            end
            local me = sbGet("zuzify_users",
                "user_id=eq."..MY_UID..
                "&select=is_banned,ban_reason,kick_signal,kick_reason,role,tier,is_trusted,warn_count,trusted_features")
            if me and #me > 0 then
                local m = me[1]
                if m.is_banned then pcall(function() LP:Kick("Banned: "..(m.ban_reason or "")) end) end
                if m.kick_signal then
                    sbPatch("zuzify_users", "user_id=eq."..MY_UID, { kick_signal = false, kick_reason = "" })
                    pcall(function() LP:Kick("Kicked: "..(m.kick_reason or "")) end)
                end
                if m.role ~= lastRole or m.tier ~= lastTier then
                    lastRole, lastTier = m.role, m.tier
                    MY_ROLE = m.role or MY_ROLE
                    MY_TIER = m.tier or MY_TIER
                end
                userRow.warn_count = m.warn_count
                userRow.is_trusted = m.is_trusted
                MY_TRUSTED_FEATURES = m.trusted_features or MY_TRUSTED_FEATURES
            end
            if tick() - settingsRefresh > 60 then
                settingsRefresh = tick()
                local s = sbGet("zuzify_settings", "select=*")
                if s then for _, row in ipairs(s) do GlobalSettings[row.key] = row.value end end
            end
        end)
    end
end)

--============================================================
-- FEATURES TABLE
--============================================================
SetLoading(0.50, "Preparing features…")

local F = {
    ESP = false, ESP_Names = true, ESP_Distance = true, ESP_Health = true, ESP_Weapon = true,
    ESP_Chams = true, ESP_Boxes = true, ESP_Tracers = false, ESP_TracersMode = "Top",
    ESP_HeadDot = false,
    ESP_FillTransparency = 0.5, ESP_OutlineTransparency = 0.1,
    ESP_DeadCheck = true, ESP_MaxDistance = 1500, ESP_RefreshRate = 0.1,
    ESP_ColorMode = "Role", ESP_ShowOnlyMurderer = false, ESP_ShowOnlySheriff = false,
    ESP_FOVCircle = false, ESP_FOVRadius = 140, ESP_Through = true,
    ESP_TrustedColor = Color3.fromRGB(255, 215, 0),
    ESP_GoldESP = false,
    Fullbright = false, CustomFOV = 70,
    NoclipType = "None", FlyType = "None", FlySpeed = 60,
    InfiniteJump = false, WalkSpeed = 16, JumpPower = 50,
    SpeedBoost = false, SuperJump = false, BunnyHop = false, Wallclimb = false,
    Dash = false, DashPower = 30, TeleportToMouse = false,
    CFrameSpeed = false, CFrameSpeedValue = 2,
    Aimbot = false, SilentAim = false, AimbotFOV = 230,
    AutoKill = false, KnifeAura = false, AuraRange = 15, KillTarget = false, AutoShoot = false,
    SelectedTarget = nil,
    FlingType = "Normal", FlingNearest = false, FlingAll = false, FlingTarget = false,
    Invisible = false, RainbowSelf = false, Orbit = false, OrbitDist = 6, LoopBehind = false,
    FreezeTarget = false, InvisibleTarget = false, SpinTarget = false, PlatformTarget = false,
    DisableJumpTarget = false, DisableMoveTarget = false, SlowMotionTarget = false,
    FreezeAll = false, SpinAll = false,
    Piggyback = false, FrontCarry = false, SideCarry = false,
    AntiAFK = true, AntiFling = true, AntiDie = false, AntiVoid = false, AntiSit = false,
    AntiRagdoll = false,
    SelectedEmote = nil, ShareUsername = userRow.show_username or false,
    Debug_Overlay = false,
    TrustedRainbowTrail = false,
    TrustedCustomTitle = "",
}

--============================================================
-- EMOTES
--============================================================
SetLoading(0.55, "Loading emotes…")

local EmoteList = {}
local function E(n, i) table.insert(EmoteList, { Name = n, ID = i }) end
local eids = {"507770620","507771112","507771612","507771366","507771049","507771682","507771410","507771276","507771842","507771453","507771054","507771815","507771568","507771147","507771731","507771174","507771878","507771594","507771358","507771270","507771697","507771597","507771482","507771702","507771501","507771205","507771295","507771100","507771650","507771467","507771406","507771537","507771339","507771266","507771490","507771831","507771771","507771647","507771060","507771152","507771554","507771536","507771715","507771080","507771398","507771911","507771551","507771756","507771692","507771357","507771226","507771022","507771582","507771620","507771769","507771670","507771364","507771279","507771019","507771790","507771307","507771591","507771494","507771674","507771837","507771457","507771109","507771547","507771305","507771827","507771183","507771466","507771706","507771174","507771217","507771330","507771476","507771215","507771679","507771865","507771093","507771585","507771660","507771803","507771329","507771491","507771259","507771716","507771053","507771128","507771640","507771597","507771091","507771767","507771412"}
local enames = {"Dance","Robot","Floss","Twist","Whip","Wave","Point","Salute","Sit","Lay","Dab","Gangnam","Macarena","Harlem","Running Man","T-Pose","Cossack","Ballet","Sword","Karate","Boxing","Fencing","Taekwondo","Yoga","Breakdance","Moonwalk","Shuffle","Charleston","Tango","Waltz","Salsa","Mambo","Cha Cha","Rumba","Zumba","Hip Hop","Popping","Locking","Waacking","Voguing","Krumping","House","Industrial","Electro","Techno","Trance","Dubstep","Jazz","Tap","Modern","Contemporary","Lyrical","Musical","Ballroom","Swing","Lindy Hop","Jive","Boogie","Rock & Roll","Mosh","Circle Pit","Wall of Death","Clap","Cheer","Cry","Laugh","Shrug","Faint","Roar","Scream","Snap","Stomp","Thriller","Disco","Funky","Smooth","Cool","Attitude","Confused","Nervous","Shy","Sassy","Angry","Sad","Happy","Surprised","Disgusted","Fear","Pride","Love","Peace","Victory","Spin","Float","Kick","Punch","Jump","Slide","Backflip","Frontflip"}
local ei = 0
for k = 1, #enames do ei = ei + 1; E(enames[k].." "..ei, "rbxassetid://"..eids[((k-1)%#eids)+1]) end
for k = 1, 200 do ei = ei + 1; E("Extra "..ei, "rbxassetid://"..eids[((k-1)%#eids)+1]..math.random(10,99)) end

--============================================================
-- HELPERS
--============================================================
local RoleColors = { Murderer = Color3.fromRGB(255,55,55), Sheriff = Color3.fromRGB(55,145,255), Innocent = Color3.fromRGB(55,230,100) }
local MapTeleports = { Lobby=Vector3.new(-110,140,40), Bank=Vector3.new(0,5,0), Hotel=Vector3.new(50,5,0), Hospital=Vector3.new(-50,5,0), Office=Vector3.new(0,5,50), House=Vector3.new(30,5,-30), Museum=Vector3.new(20,5,40), Laboratory=Vector3.new(-40,5,-20) }
local CachedRoles = {}
local function GetRole(plr)
    if not plr then return "Innocent" end
    local c = CachedRoles[plr]
    if c and tick() - c.t < 0.75 then return c.r end
    local r = "Innocent"
    if plr.Character then
        local tool = plr.Character:FindFirstChildOfClass("Tool")
        if tool then
            local n = string.lower(tool.Name)
            if n:find("knife") or n:find("dagger") or n:find("blade") then r = "Murderer"
            elseif n:find("gun") or n:find("revolver") or n:find("pistol") then r = "Sheriff" end
        end
    end
    CachedRoles[plr] = { r = r, t = tick() }
    return r
end

local function GetMyRoot() return LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") end
local function GetMyHum() return LP.Character and LP.Character:FindFirstChildOfClass("Humanoid") end
local function GetTarget() if not F.SelectedTarget then return nil end return Players:FindFirstChild(F.SelectedTarget) end
local function GetTargetRoot() local t = GetTarget(); return t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") end
local function GetClosest(maxD)
    local r = GetMyRoot(); if not r then return nil end
    local best, bd = nil, maxD or 9999
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local tr = p.Character:FindFirstChild("HumanoidRootPart")
            local h = p.Character:FindFirstChildOfClass("Humanoid")
            if tr and h and h.Health > 0 then
                local d = (r.Position - tr.Position).Magnitude
                if d < bd then bd = d; best = p end
            end
        end
    end
    return best
end

local function FormatTime(isoStr)
    if not isoStr then return "N/A" end
    local ok, dt = pcall(function() return DateTime.fromIsoDate(isoStr) end)
    if not ok or not dt then return tostring(isoStr):sub(1, 19) end
    local diff = os.time() - dt.UnixTimestamp
    if diff < 60 then return diff.."s ago"
    elseif diff < 3600 then return math.floor(diff/60).."m ago"
    elseif diff < 86400 then return math.floor(diff/3600).."h ago"
    else return math.floor(diff/86400).."d ago" end
end

--============================================================
-- ESP
--============================================================
local ESPObjects = {}
local FOVCircleObj = nil
local function clearESP(plr)
    local o = ESPObjects[plr]
    if o then
        for _, x in pairs(o) do
            if type(x) == "table" then
                for _, y in ipairs(x) do if y.line then pcall(function() y.line:Destroy() end) end end
            elseif x and x.Destroy then pcall(function() x:Destroy() end) end
        end
        ESPObjects[plr] = nil
    end
end
local function clearAllESP() for p in pairs(ESPObjects) do clearESP(p) end end

local function getESPColor(plr, d)
    if F.ESP_GoldESP and IsTrusted() then return F.ESP_TrustedColor end
    if F.ESP_ColorMode == "Role" then return RoleColors[GetRole(plr)] or RoleColors.Innocent
    elseif F.ESP_ColorMode == "Distance" then
        local t = math.clamp(d/300, 0, 1); return Color3.fromRGB(255*(1-t), 255*t, 0)
    elseif F.ESP_ColorMode == "Health" then
        local h = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if h then local p = h.Health/math.max(h.MaxHealth, 1); return Color3.fromRGB(255*(1-p), 255*p, 0) end
        return Color3.fromRGB(0, 255, 0)
    end
    return Color3.fromRGB(0, 220, 180)
end

local function createESP(plr)
    if plr == LP or ESPObjects[plr] then return end
    local c = plr.Character; if not c then return end
    local head = c:FindFirstChild("Head"); local root = c:FindFirstChild("HumanoidRootPart")
    if not head or not root then return end
    local o = {}
    pcall(function()
        local bb = Instance.new("BillboardGui")
        bb.Name = "ZESP"; bb.Adornee = head
        bb.Size = UDim2.new(0, 320, 0, 140); bb.StudsOffset = Vector3.new(0, 3.6, 0)
        bb.AlwaysOnTop = F.ESP_Through; bb.Parent = head; o.Billboard = bb
        o.NameLabel = Instance.new("TextLabel"); o.NameLabel.Size = UDim2.new(1, 0, 0.28, 0); o.NameLabel.BackgroundTransparency = 1
        o.NameLabel.TextColor3 = Color3.new(1, 1, 1); o.NameLabel.Font = Enum.Font.GothamBold; o.NameLabel.TextSize = 15; o.NameLabel.Parent = bb
        o.DistLabel = Instance.new("TextLabel"); o.DistLabel.Size = UDim2.new(1, 0, 0.18, 0); o.DistLabel.Position = UDim2.new(0, 0, 0.28, 0)
        o.DistLabel.BackgroundTransparency = 1; o.DistLabel.Font = Enum.Font.Gotham; o.DistLabel.TextSize = 12; o.DistLabel.Parent = bb
        o.HealthLabel = Instance.new("TextLabel"); o.HealthLabel.Size = UDim2.new(1, 0, 0.18, 0); o.HealthLabel.Position = UDim2.new(0, 0, 0.46, 0)
        o.HealthLabel.BackgroundTransparency = 1; o.HealthLabel.Font = Enum.Font.Gotham; o.HealthLabel.TextSize = 12; o.HealthLabel.Parent = bb
        o.WeaponLabel = Instance.new("TextLabel"); o.WeaponLabel.Size = UDim2.new(1, 0, 0.18, 0); o.WeaponLabel.Position = UDim2.new(0, 0, 0.64, 0)
        o.WeaponLabel.BackgroundTransparency = 1; o.WeaponLabel.TextColor3 = Color3.new(1, 1, 1); o.WeaponLabel.Font = Enum.Font.Gotham; o.WeaponLabel.TextSize = 11; o.WeaponLabel.Parent = bb
        if F.ESP_Chams then
            local hl = Instance.new("Highlight"); hl.Name = "ZHL"; hl.Adornee = c
            hl.FillTransparency = F.ESP_FillTransparency; hl.OutlineTransparency = F.ESP_OutlineTransparency
            hl.DepthMode = F.ESP_Through and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
            hl.Parent = c; o.Highlight = hl
        end
        if F.ESP_Boxes then
            local bx = Instance.new("BoxHandleAdornment"); bx.Name = "ZBox"; bx.Adornee = root
            bx.Size = Vector3.new(4, 6, 2); bx.Transparency = 0.5; bx.AlwaysOnTop = F.ESP_Through; bx.Parent = root; o.Box = bx
        end
        if F.ESP_HeadDot then
            local dot = Instance.new("BillboardGui"); dot.Name = "ZDot"; dot.Adornee = head
            dot.Size = UDim2.new(0, 16, 0, 16); dot.AlwaysOnTop = F.ESP_Through; dot.Parent = head
            local circle = Instance.new("Frame"); circle.Size = UDim2.new(1, 0, 1, 0)
            circle.BackgroundColor3 = Color3.new(1, 1, 1); circle.BorderSizePixel = 0; circle.Parent = dot
            Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
            o.HeadDot = dot; o.HeadDotFrame = circle
        end
        if F.ESP_Tracers then
            local line = Instance.new("LineHandleAdornment"); line.Name = "ZTracer"; line.Adornee = root
            line.Length = 0; line.Thickness = 1; line.AlwaysOnTop = F.ESP_Through; line.Parent = root; o.Tracer = line
        end
    end)
    ESPObjects[plr] = o
end

local function refreshESP()
    clearAllESP()
    if not F.ESP then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then pcall(createESP, p) end
    end
end

local function updateFOVCircle()
    if not F.ESP_FOVCircle then
        if FOVCircleObj then pcall(function() FOVCircleObj:Destroy() end); FOVCircleObj = nil end
        return
    end
    if not FOVCircleObj or not FOVCircleObj.Parent then
        pcall(function()
            FOVCircleObj = Instance.new("ScreenGui"); FOVCircleObj.Name = "ZFOV"
            FOVCircleObj.ResetOnSpawn = false; FOVCircleObj.IgnoreGuiInset = true; FOVCircleObj.Parent = CoreGui
            local c = Instance.new("Frame"); c.Name = "Circle"; c.BackgroundTransparency = 1; c.Parent = FOVCircleObj
            local s = Instance.new("UIStroke"); s.Name = "Stroke"; s.Thickness = 1.5; s.Color = Color3.new(1, 1, 1); s.Transparency = 0.3; s.Parent = c
            Instance.new("UICorner", c).CornerRadius = UDim.new(1, 0)
        end)
    end
    local c = FOVCircleObj and FOVCircleObj:FindFirstChild("Circle")
    if c then
        local r = F.ESP_FOVRadius
        c.Size = UDim2.new(0, r*2, 0, r*2); c.Position = UDim2.new(0.5, -r, 0.5, -r)
    end
end

--============================================================
-- TROLL FUNCTIONS
--============================================================
local function Fling(plr)
    pcall(function()
        local c = plr and plr.Character; if not c then return end
        local r = c:FindFirstChild("HumanoidRootPart"); if not r then return end
        local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Parent = r
        if F.FlingType == "Strong" then bv.Velocity = Vector3.new(math.random(-250,250), math.random(150,250), math.random(-250,250))
        elseif F.FlingType == "Up" then bv.Velocity = Vector3.new(0, math.random(300,450), 0)
        else bv.Velocity = Vector3.new(math.random(-140,140), math.random(90,150), math.random(-140,140)) end
        Debris:AddItem(bv, 0.35)
    end)
end
local function Freeze(p, s) local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = s and 0 or 16; h.JumpPower = s and 0 or 50 end end
local function MakeInvis(p, s) if not p or not p.Character then return end; for _, x in ipairs(p.Character:GetDescendants()) do if x:IsA("BasePart") or x:IsA("Decal") then x.Transparency = s and 1 or 0 end end end
local function ForceSit(p) local h = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid"); if h then h.Sit = true end end
local function SpinT(p, s) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local av = r:FindFirstChild("ZSpin"); if s and not av then av = Instance.new("BodyAngularVelocity"); av.MaxTorque = Vector3.new(9e9,9e9,9e9); av.AngularVelocity = Vector3.new(0,20,0); av.Parent = r; av.Name = "ZSpin" elseif not s and av then av:Destroy() end end
local function Explode(p) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local e = Instance.new("Explosion"); e.BlastRadius = 10; e.BlastPressure = 0; e.Position = r.Position; e.Parent = Workspace end
local function PushPull(p, d) local r = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart"); if not r then return end; local bv = Instance.new("BodyVelocity"); bv.MaxForce = Vector3.new(9e9,9e9,9e9); bv.Velocity = d * 120; bv.Parent = r; Debris:AddItem(bv, 0.5) end

local EmoteTracks = {}
local function clearEmotes() for _, t in ipairs(EmoteTracks) do pcall(function() t:Stop(); t:Destroy() end) end EmoteTracks = {} end
local function PlayEmote(p, id)
    pcall(function()
        if not p or not p.Character then return end
        local a = p.Character:FindFirstChildOfClass("Animator")
        if not a then a = Instance.new("Animator"); local h = p.Character:FindFirstChildOfClass("Humanoid"); if h then a.Parent = h end end
        if not a then return end
        local tr = a:LoadAnimation(Instance.new("Animation")); tr.AnimationId = id; tr:Play(); table.insert(EmoteTracks, tr)
    end)
end

--============================================================
-- MOVEMENT
--============================================================
local function ApplyStats() local h = GetMyHum(); if h then h.WalkSpeed = F.SpeedBoost and 42 or F.WalkSpeed; h.JumpPower = F.SuperJump and 120 or F.JumpPower end end
local function ApplyNoclip() pcall(function() local c = LP.Character; if not c then return end; local cc = F.NoclipType == "None"; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = cc end end end) end
local BodyVel, BodyGyro
local function SetupFly() pcall(function() local r = GetMyRoot(); if not r then return end; if BodyVel then BodyVel:Destroy() end; if BodyGyro then BodyGyro:Destroy() end; if F.FlyType ~= "None" then BodyVel = Instance.new("BodyVelocity"); BodyVel.MaxForce = Vector3.new(9e9,9e9,9e9); BodyVel.Parent = r; BodyGyro = Instance.new("BodyGyro"); BodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9); BodyGyro.P = 20000; BodyGyro.Parent = r end end) end
local function CleanFly() pcall(function() if BodyVel then BodyVel:Destroy(); BodyVel = nil end; if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end end) end
local OT = {}
local function SetInvis(s) pcall(function() local c = LP.Character; if not c then return end; for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") or p:IsA("Decal") then if s then if not OT[p] then OT[p] = p.Transparency end; p.Transparency = 1 else if OT[p] then p.Transparency = OT[p] end end end end; if not s then table.clear(OT) end end) end

local function OnChar()
    task.wait(0.4); pcall(ApplyStats); pcall(ApplyNoclip)
    if F.FlyType ~= "None" then pcall(SetupFly) end
    if F.Invisible then pcall(SetInvis, true) end
    if F.ESP then task.delay(0.3, refreshESP) end
end
if LP.Character then task.spawn(OnChar) end
LP.CharacterAdded:Connect(function() task.spawn(OnChar) end)

--============================================================
-- DEBUG OVERLAY
--============================================================
local DebugGui, DL = nil, {}
local function setupDebugGui()
    if DebugGui then return end
    pcall(function()
        DebugGui = Instance.new("ScreenGui"); DebugGui.Name = "ZDebug"; DebugGui.ResetOnSpawn = false
        DebugGui.IgnoreGuiInset = true; DebugGui.Parent = CoreGui
        local fr = Instance.new("Frame"); fr.Size = UDim2.new(0, 260, 0, 200); fr.Position = UDim2.new(0, 10, 0.5, -100)
        fr.BackgroundColor3 = Color3.new(0, 0, 0); fr.BackgroundTransparency = 0.3; fr.BorderSizePixel = 0; fr.Parent = DebugGui
        Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 8)
        local t = Instance.new("TextLabel"); t.Size = UDim2.new(1, 0, 0, 24); t.BackgroundTransparency = 1
        t.Text = "ZUZIFY DEBUG"; t.TextColor3 = Color3.fromRGB(0, 220, 180); t.Font = Enum.Font.GothamBold; t.TextSize = 14; t.Parent = fr
        local function mk(y)
            local l = Instance.new("TextLabel"); l.Size = UDim2.new(1, -12, 0, 20); l.Position = UDim2.new(0, 6, 0, y)
            l.BackgroundTransparency = 1; l.TextColor3 = Color3.fromRGB(220, 220, 230); l.Font = Enum.Font.Code
            l.TextSize = 12; l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = fr; return l
        end
        DL.fps = mk(28); DL.ping = mk(48); DL.mem = mk(68); DL.players = mk(88); DL.pos = mk(108)
        DL.role = mk(128); DL.uptime = mk(148); DL.session = mk(168)
    end)
end
local function teardownDebugGui() if DebugGui then pcall(function() DebugGui:Destroy() end); DebugGui = nil; DL = {} end end
local boot = tick(); local fpsF, fpsL = 0, tick()

--============================================================
-- MAIN LOOP (wrapped in pcall to prevent crashes)
--============================================================
local lastHeavy, lastAnti = 0, 0
local lastSafe = Vector3.new(0, 10, 0)
local jumpDeb = 0

RunService.RenderStepped:Connect(function()
    local now = tick()
    local ok, err = pcall(function()
        local char = LP.Character
        local root = GetMyRoot()
        local hum = GetMyHum()
        if root and root.Position.Y > -50 then lastSafe = root.Position end

        if F.Debug_Overlay then
            if not DebugGui then setupDebugGui() end
            fpsF = fpsF + 1
            if now - fpsL >= 0.5 then
                local fps = fpsF / (now - fpsL); fpsF = 0; fpsL = now
                if DL.fps then DL.fps.Text = string.format("FPS: %.0f", fps) end
            end
            if now - (DL._p or 0) > 1 then
                DL._p = now
                pcall(function() DL.ping.Text = string.format("Ping: %d ms", math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())) end)
                pcall(function() DL.mem.Text = string.format("Mem: %.1f MB", Stats:GetTotalMemoryUsageMb()) end)
            end
            DL.players.Text = "Players: "..#Players:GetPlayers().."/"..Players.MaxPlayers
            if root then DL.pos.Text = string.format("Pos: %.0f,%.0f,%.0f", root.Position.X, root.Position.Y, root.Position.Z) end
            DL.role.Text = "Role: "..RoleLabel(MY_ROLE).." / "..RoleLabel(MY_TIER)
            DL.uptime.Text = "Uptime: "..os.date("!%H:%M:%S", math.floor(now - boot))
            DL.session.Text = "Session: "..tostring(SESSION_ID):sub(1, 8)
        elseif DebugGui then teardownDebugGui() end

        if now - lastHeavy > F.ESP_RefreshRate then
            lastHeavy = now
            if F.ESP and root then
                for plr, o in pairs(ESPObjects) do
                    local c = plr.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        local tr = c.HumanoidRootPart
                        local h = c:FindFirstChildOfClass("Humanoid")
                        local d = (root.Position - tr.Position).Magnitude
                        local role = GetRole(plr)
                        local vis = true
                        if d > F.ESP_MaxDistance then vis = false end
                        if F.ESP_DeadCheck and (not h or h.Health <= 0) then vis = false end
                        if F.ESP_ShowOnlyMurderer and role ~= "Murderer" then vis = false end
                        if F.ESP_ShowOnlySheriff and role ~= "Sheriff" then vis = false end
                        if o.Billboard then o.Billboard.Enabled = vis end
                        if o.Highlight then o.Highlight.Enabled = vis end
                        if o.Box then o.Box.Visible = vis end
                        if o.Tracer then o.Tracer.Visible = vis end
                        if o.HeadDot then o.HeadDot.Enabled = vis end
                        if vis then
                            local col = getESPColor(plr, d)
                            o.NameLabel.Text = plr.Name.." ["..role.."]"
                            o.NameLabel.TextColor3 = col; o.NameLabel.Visible = F.ESP_Names
                            o.DistLabel.Text = string.format("%d studs", math.floor(d))
                            o.DistLabel.TextColor3 = col; o.DistLabel.Visible = F.ESP_Distance
                            local hp = h and math.floor(h.Health) or 0
                            local mx = h and math.floor(h.MaxHealth) or 100
                            o.HealthLabel.Text = "HP: "..hp.."/"..mx
                            o.HealthLabel.TextColor3 = hp > mx*0.5 and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,50,50)
                            o.HealthLabel.Visible = F.ESP_Health
                            local tool = c:FindFirstChildOfClass("Tool")
                            o.WeaponLabel.Text = tool and ("Weapon: "..tool.Name) or ""
                            o.WeaponLabel.Visible = F.ESP_Weapon and tool ~= nil
                            if o.Highlight then o.Highlight.FillColor = col; o.Highlight.OutlineColor = col end
                            if o.Box then o.Box.Color3 = col end
                            if o.HeadDotFrame then o.HeadDotFrame.BackgroundColor3 = col end
                            if o.Tracer then
                                o.Tracer.Color3 = col
                                local org = F.ESP_TracersMode == "Bottom"
                                    and Vector3.new(Camera.CFrame.Position.X, Camera.CFrame.Position.Y - 5, Camera.CFrame.Position.Z)
                                    or (Camera.CFrame.Position + Camera.CFrame.UpVector * 2)
                                local dir = tr.Position - org
                                o.Tracer.Length = dir.Magnitude
                                o.Tracer.CFrame = CFrame.lookAt(org, tr.Position)
                            end
                        end
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
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0, 1, 0) end
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
            dir = Vector3.new(dir.X, 0, dir.Z)
            if dir.Magnitude > 0 then root.CFrame += dir.Unit * F.CFrameSpeedValue end
        end

        if F.InfiniteJump then
            local st = hum:GetState()
            local ok2 = st == Enum.HumanoidStateType.Freefall or st == Enum.HumanoidStateType.Running
                    or st == Enum.HumanoidStateType.RunningNoPhysics or st == Enum.HumanoidStateType.Landed
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) and ok2 and now - jumpDeb > 0.35 then
                hum:ChangeState(Enum.HumanoidStateType.Jumping); jumpDeb = now
            end
        end
        if F.BunnyHop and hum.MoveDirection.Magnitude > 0.1 and hum.FloorMaterial ~= Enum.Material.Air and now - jumpDeb > 0.25 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping); jumpDeb = now
        end
        if F.Wallclimb then
            local ray = Ray.new(root.Position, root.CFrame.LookVector * 2)
            local hit = Workspace:FindPartOnRay(ray, char)
            if hit and hum.FloorMaterial == Enum.Material.Air then root.CFrame += Vector3.new(0, 0.5, 0) end
        end
        if F.Dash and UserInputService:IsKeyDown(Enum.KeyCode.Space) and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and now - jumpDeb > 0.5 then
            jumpDeb = now; local d = Camera.CFrame.LookVector * F.DashPower
            root.AssemblyLinearVelocity = Vector3.new(d.X, 0, d.Z)
        end
        if F.TeleportToMouse and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            local m = UserInputService:GetMouseLocation()
            local r = Camera:ScreenPointToRay(m.X, m.Y)
            local _, pos = Workspace:FindPartOnRay(Ray.new(r.Origin, r.Direction * 1000), char)
            if pos then root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
        end

        if F.AntiFling and root.AssemblyLinearVelocity.Magnitude > 160 then
            root.AssemblyLinearVelocity = Vector3.zero; root.AssemblyAngularVelocity = Vector3.zero
        end
        if F.AntiDie and hum.Health < hum.MaxHealth * 0.2 then hum.Health = hum.MaxHealth end
        if F.AntiVoid and root.Position.Y < -50 then
            root.CFrame = CFrame.new(lastSafe + Vector3.new(0, 5, 0)); root.AssemblyLinearVelocity = Vector3.zero
        end
        if F.AntiSit and hum.Sit then hum.Sit = false end
        if F.AntiRagdoll and hum.PlatformStand then hum.PlatformStand = false end

        if F.AntiAFK and now - lastAnti > 60 then
            lastAnti = now
            pcall(function()
                local x, y = Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2
                VIM:SendMouseMoveEvent(x + 10, y + 10, false, game)
            end)
        end

        if Camera.FieldOfView ~= F.CustomFOV then Camera.FieldOfView = F.CustomFOV end

        if F.Orbit and F.SelectedTarget then
            local t = GetTarget()
            local tr = t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")
            if tr then
                local a = (now * 6) % (math.pi * 2)
                root.CFrame = CFrame.new(tr.Position) * CFrame.Angles(0, a, 0) * CFrame.new(0, 2, F.OrbitDist)
            end
        end
        if F.LoopBehind and F.SelectedTarget then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, 3.5) end end
        if F.Piggyback then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0, 3.1, 0.2) end end
        if F.FrontCarry then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, -3.1) end end
        if F.SideCarry then local tr = GetTargetRoot(); if tr then root.CFrame = tr.CFrame * CFrame.new(2.7, 0.4, 0) end end

        if F.KillTarget then
            local tr = GetTargetRoot()
            if tr then
                root.CFrame = tr.CFrame * CFrame.new(0, 0, 2.5)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end

        if F.Aimbot or F.SilentAim then
            local t = GetClosest(F.AimbotFOV)
            if t and t.Character then
                local part = t.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local goal = part.Position + part.AssemblyLinearVelocity * 0.14
                    if F.SilentAim then Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, goal)
                    else Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, goal), 0.13) end
                end
            end
        end

        if F.AutoKill and now - jumpDeb > 1.2 then
            jumpDeb = now; local t = char:FindFirstChildOfClass("Tool")
            if t then pcall(function() t:Activate() end) end
        end
        if F.AutoShoot and now - jumpDeb > 0.4 then
            jumpDeb = now; local t = char:FindFirstChildOfClass("Tool")
            if t then
                local n = string.lower(t.Name)
                if n:find("gun") or n:find("revolver") then pcall(function() t:Activate() end) end
            end
        end

        if F.KnifeAura then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    if tr and (root.Position - tr.Position).Magnitude < F.AuraRange then
                        local t = char:FindFirstChildOfClass("Tool")
                        if t then pcall(function() t:Activate() end) end
                    end
                end
            end
        end

        if F.FlingNearest and now - jumpDeb > 0.55 then jumpDeb = now; local c = GetClosest(55); if c then Fling(c) end end
        if F.FlingTarget and F.SelectedTarget and now - jumpDeb > 0.4 then jumpDeb = now; local t = GetTarget(); if t then Fling(t) end end
        if F.FlingAll and now - jumpDeb > 0.85 then jumpDeb = now; for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then Fling(p) end end end

        local t = GetTarget()
        if t and t.Character then
            if F.FreezeTarget then Freeze(t, true) else Freeze(t, false) end
            if F.InvisibleTarget then MakeInvis(t, true) else MakeInvis(t, false) end
            if F.SpinTarget then SpinT(t, true) else SpinT(t, false) end
            if F.PlatformTarget then
                local tr = t.Character:FindFirstChild("HumanoidRootPart")
                if tr and not tr:FindFirstChild("ZPlat") then
                    local p = Instance.new("Part"); p.Name = "ZPlat"; p.Size = Vector3.new(8, 1, 8)
                    p.Anchored = true; p.CanCollide = true; p.Material = Enum.Material.Neon
                    p.Color = Color3.fromRGB(0, 200, 160); p.CFrame = CFrame.new(tr.Position - Vector3.new(0, 3, 0)); p.Parent = tr
                end
            else
                for _, p in ipairs(Workspace:GetDescendants()) do if p.Name == "ZPlat" then pcall(function() p:Destroy() end) end end
            end
            if F.DisableJumpTarget then local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower = 0 end
            else local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.JumpPower = 50 end end
            if F.DisableMoveTarget then local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 0 end
            else local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 16 end end
            if F.SlowMotionTarget then local h = t.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 4 end end
        end

        if F.FreezeAll then for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then Freeze(p, true) end end
        else for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then Freeze(p, false) end end end
        if F.SpinAll then for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then SpinT(p, true) end end
        else for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then SpinT(p, false) end end end

        if F.RainbowSelf then
            local hue = now % 1; local c = Color3.fromHSV(hue, 1, 1)
            for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.Color = c end end
        end

        if F.TrustedRainbowTrail and IsTrusted() then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    local hue = (now + p.Position.X * 0.01 + p.Position.Z * 0.01) % 1
                    p.Color = Color3.fromHSV(hue, 1, 1)
                end
            end
        end
    end)
    if not ok and err then
        -- Silently swallow main loop errors (they shouldn't kill the script)
    end
end)

SetLoading(0.70, "Loading UI…")

--============================================================
-- LOAD FLUENT UI (with fallback)
--============================================================
local Fluent, SaveManager, InterfaceManager

local function tryLoad(url)
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(url, true))()
    end)
    return ok and result or nil
end

Fluent = tryLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")

if not Fluent then
    -- Retry with alternative source
    Fluent = tryLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Source.lua")
end

if not Fluent then
    SafeLog("ui", "Fluent failed to load")
    pcall(function()
        Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    CloseLoading()
    pcall(function() LP:Kick("ZuzifyRBX: UI library failed to load. Try again.") end)
    return
end

SaveManager = tryLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
InterfaceManager = tryLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")

SetLoading(0.85, "Building UI…")

--============================================================
-- CREATE WINDOW + TABS
--============================================================
local Window = Fluent:CreateWindow({
    Title    = "ZuzifyRBX " .. VERSION,
    SubTitle = "by mrcoptai — " .. RoleLabel(MY_ROLE),
    TabWidth = 170,
    Size     = UDim2.fromOffset(600, 480),
    Acrylic  = true,
    Theme    = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl,
})

local Tabs = {
    Home     = Window:AddTab({ Title = "Home",      Icon = "house" }),
    Visuals  = Window:AddTab({ Title = "Visuals",   Icon = "eye" }),
    Movement = Window:AddTab({ Title = "Movement",  Icon = "move" }),
    Players  = Window:AddTab({ Title = "Players",   Icon = "users" }),
    Combat   = Window:AddTab({ Title = "Combat",    Icon = "crosshair" }),
    Troll    = Window:AddTab({ Title = "Troll",     Icon = "ghost" }),
    Emotes   = Window:AddTab({ Title = "Emotes",    Icon = "smile" }),
    Anti     = Window:AddTab({ Title = "Anti",      Icon = "shield" }),
    Report   = Window:AddTab({ Title = "Report",    Icon = "flag" }),
    Feedback = Window:AddTab({ Title = "Feedback",  Icon = "message-circle" }),
    Tickets  = Window:AddTab({ Title = "Tickets",   Icon = "ticket" }),
    Apply    = Window:AddTab({ Title = "Apply",     Icon = "file-text" }),
    Trusted  = nil,
    Debug    = Window:AddTab({ Title = "Debug",     Icon = "terminal" }),
    Settings = Window:AddTab({ Title = "Settings",  Icon = "settings" }),
    Staff    = nil,
}

if IsTrusted() then
    Tabs.Trusted = Window:AddTab({ Title = "★ Trusted", Icon = "star" })
end

local Options = Fluent.Options

SetLoading(0.92, "Populating tabs…")

--============================================================
-- HOME
--============================================================
Tabs.Home:AddParagraph({
    Title = "Welcome to ZuzifyRBX",
    Content = "Version: "..VERSION.."\nRole: "..RoleLabel(MY_ROLE)..
              "\nTier: "..RoleLabel(MY_TIER)..
              "\nWarnings: "..tostring(userRow.warn_count or 0)..
              "\nTrusted: "..tostring(IsTrusted())..
              "\nSession started: "..os.date("%H:%M:%S"),
})

Tabs.Home:AddButton({
    Title = "Show Status",
    Callback = function()
        pcall(function()
            Fluent:Notify({
                Title = "Account Status",
                Content = "User: "..MY_NAME..
                          "\nRole: "..RoleLabel(MY_ROLE)..
                          "\nTier: "..RoleLabel(MY_TIER)..
                          "\nTrusted: "..tostring(IsTrusted())..
                          "\nWarnings: "..tostring(userRow.warn_count or 0)..
                          "\nTime: "..os.date("%Y-%m-%d %H:%M:%S"),
                Duration = 10,
            })
        end)
    end,
})
Tabs.Home:AddButton({
    Title = "Copy User ID",
    Callback = function()
        if setclipboard then setclipboard(tostring(MY_UID)) end
        pcall(function() Fluent:Notify({ Title = "Copied", Content = "User ID copied.", Duration = 3 }) end)
    end,
})

--============================================================
-- VISUALS
--============================================================
Tabs.Visuals:AddToggle("ESP", { Title = "Enable ESP", Default = false, Callback = function(v) F.ESP = v; if v then refreshESP() else clearAllESP() end end })
Tabs.Visuals:AddToggle("ESP_Names", { Title = "Names + Role", Default = true, Callback = function(v) F.ESP_Names = v end })
Tabs.Visuals:AddToggle("ESP_Distance", { Title = "Distance", Default = true, Callback = function(v) F.ESP_Distance = v end })
Tabs.Visuals:AddToggle("ESP_Health", { Title = "Health", Default = true, Callback = function(v) F.ESP_Health = v end })
Tabs.Visuals:AddToggle("ESP_Weapon", { Title = "Weapon", Default = true, Callback = function(v) F.ESP_Weapon = v end })
Tabs.Visuals:AddToggle("ESP_Chams", { Title = "Chams", Default = true, Callback = function(v) F.ESP_Chams = v; refreshESP() end })
Tabs.Visuals:AddToggle("ESP_Boxes", { Title = "Boxes", Default = true, Callback = function(v) F.ESP_Boxes = v; refreshESP() end })
Tabs.Visuals:AddToggle("ESP_Tracers", { Title = "Tracers", Default = false, Callback = function(v) F.ESP_Tracers = v; refreshESP() end })
Tabs.Visuals:AddDropdown("TracerMode", { Title = "Tracer Mode", Values = {"Top", "Bottom"}, Default = 1, Callback = function(v) F.ESP_TracersMode = v end })
Tabs.Visuals:AddToggle("ESP_HeadDot", { Title = "Head Dot", Default = false, Callback = function(v) F.ESP_HeadDot = v; refreshESP() end })
Tabs.Visuals:AddSlider("ESPMaxDist", { Title = "Max Distance", Default = 1500, Min = 100, Max = 5000, Rounding = 100, Callback = function(v) F.ESP_MaxDistance = v end })
Tabs.Visuals:AddToggle("ESP_DeadCheck", { Title = "Hide Dead", Default = true, Callback = function(v) F.ESP_DeadCheck = v end })
Tabs.Visuals:AddToggle("ESP_MurdererOnly", { Title = "Only Murderer", Default = false, Callback = function(v) F.ESP_ShowOnlyMurderer = v end })
Tabs.Visuals:AddToggle("ESP_SheriffOnly", { Title = "Only Sheriff", Default = false, Callback = function(v) F.ESP_ShowOnlySheriff = v end })
Tabs.Visuals:AddToggle("ESP_Through", { Title = "Through Walls", Default = true, Callback = function(v) F.ESP_Through = v; refreshESP() end })
Tabs.Visuals:AddDropdown("ESPColorMode", { Title = "Color Mode", Values = {"Role", "Distance", "Health"}, Default = 1, Callback = function(v) F.ESP_ColorMode = v end })
Tabs.Visuals:AddSlider("ESPFill", { Title = "Fill Transparency", Default = 0.5, Min = 0, Max = 1, Rounding = 0.05, Callback = function(v) F.ESP_FillTransparency = v; refreshESP() end })
Tabs.Visuals:AddSlider("ESPOutline", { Title = "Outline Transparency", Default = 0.1, Min = 0, Max = 1, Rounding = 0.05, Callback = function(v) F.ESP_OutlineTransparency = v; refreshESP() end })
Tabs.Visuals:AddToggle("ESP_FOVCircle", { Title = "FOV Circle", Default = false, Callback = function(v) F.ESP_FOVCircle = v; updateFOVCircle() end })
Tabs.Visuals:AddSlider("FOVRadius", { Title = "FOV Radius", Default = 140, Min = 50, Max = 400, Rounding = 10, Callback = function(v) F.ESP_FOVRadius = v; updateFOVCircle() end })

--============================================================
-- MOVEMENT
--============================================================
Tabs.Movement:AddDropdown("Noclip", { Title = "Noclip", Values = {"None", "Normal", "Full"}, Default = 1, Callback = function(v) F.NoclipType = v; ApplyNoclip() end })
Tabs.Movement:AddDropdown("Fly", { Title = "Fly", Values = {"None", "BodyVelocity"}, Default = 1, Callback = function(v) F.FlyType = v; if F.FlyType == "None" then CleanFly() else SetupFly() end end })
Tabs.Movement:AddSlider("FlySpeed", { Title = "Fly Speed", Default = 60, Min = 10, Max = 250, Rounding = 5, Callback = function(v) F.FlySpeed = v end })
Tabs.Movement:AddSlider("WalkSpeed", { Title = "Walk Speed", Default = 16, Min = 10, Max = 150, Rounding = 1, Callback = function(v) F.WalkSpeed = v; ApplyStats() end })
Tabs.Movement:AddSlider("JumpPower", { Title = "Jump Power", Default = 50, Min = 30, Max = 200, Rounding = 1, Callback = function(v) F.JumpPower = v; ApplyStats() end })
Tabs.Movement:AddToggle("SpeedBoost", { Title = "Speed Boost", Default = false, Callback = function(v) F.SpeedBoost = v; ApplyStats() end })
Tabs.Movement:AddToggle("SuperJump", { Title = "Super Jump", Default = false, Callback = function(v) F.SuperJump = v; ApplyStats() end })
Tabs.Movement:AddToggle("InfiniteJump", { Title = "Infinite Jump", Default = false, Callback = function(v) F.InfiniteJump = v end })
Tabs.Movement:AddToggle("BunnyHop", { Title = "Bunny Hop", Default = false, Callback = function(v) F.BunnyHop = v end })
Tabs.Movement:AddToggle("Wallclimb", { Title = "Wallclimb", Default = false, Callback = function(v) F.Wallclimb = v end })
Tabs.Movement:AddToggle("Dash", { Title = "Dash (Space+Shift)", Default = false, Callback = function(v) F.Dash = v end })
Tabs.Movement:AddSlider("DashPower", { Title = "Dash Power", Default = 30, Min = 10, Max = 80, Rounding = 1, Callback = function(v) F.DashPower = v end })
Tabs.Movement:AddToggle("CFrameSpeed", { Title = "CFrame Speed", Default = false, Callback = function(v) F.CFrameSpeed = v end })
Tabs.Movement:AddSlider("CFrameMulti", { Title = "CFrame Multi", Default = 2, Min = 1, Max = 10, Rounding = 1, Callback = function(v) F.CFrameSpeedValue = v end })
Tabs.Movement:AddToggle("TeleportMouse", { Title = "Teleport to Mouse (RMB)", Default = false, Callback = function(v) F.TeleportToMouse = v end })
for name, pos in pairs(MapTeleports) do
    Tabs.Movement:AddButton({
        Title = "TP → "..name,
        Callback = function()
            pcall(function()
                local r = GetMyRoot(); if r then r.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0)) end
            end)
        end,
    })
end

--============================================================
-- PLAYERS
--============================================================
local function pNames() local l = {}; for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then table.insert(l, p.Name) end end; return l end
local playerDropdown
playerDropdown = Tabs.Players:AddDropdown("TargetDropdown", {
    Title = "Select Player",
    Values = (#pNames() > 0) and pNames() or {"None"},
    Default = 1,
    Callback = function(v) F.SelectedTarget = v end,
})
Tabs.Players:AddButton({
    Title = "Refresh Player List",
    Callback = function()
        pcall(function()
            local list = pNames(); if #list == 0 then list = {"None"} end
            playerDropdown:SetValues(list)
            Fluent:Notify({ Title = "Refreshed", Content = "Player list updated.", Duration = 3 })
        end)
    end,
})
Tabs.Players:AddToggle("Spectate", { Title = "Spectate", Default = false, Callback = function(v)
    pcall(function()
        if v then local t = GetTarget(); if t and t.Character then Camera.CameraSubject = t.Character:FindFirstChildOfClass("Humanoid") end
        else local h = GetMyHum(); if h then Camera.CameraSubject = h end end
    end)
end })
Tabs.Players:AddToggle("Orbit", { Title = "Orbit", Default = false, Callback = function(v) F.Orbit = v end })
Tabs.Players:AddSlider("OrbitDist", { Title = "Orbit Distance", Default = 6, Min = 3, Max = 20, Rounding = 1, Callback = function(v) F.OrbitDist = v end })
Tabs.Players:AddToggle("LoopBehind", { Title = "Loop Behind", Default = false, Callback = function(v) F.LoopBehind = v end })

--============================================================
-- COMBAT
--============================================================
Tabs.Combat:AddToggle("Aimbot", { Title = "Aimbot", Default = false, Callback = function(v) F.Aimbot = v end })
Tabs.Combat:AddToggle("SilentAim", { Title = "Silent Aim", Default = false, Callback = function(v) F.SilentAim = v end })
Tabs.Combat:AddSlider("AimbotFOV", { Title = "Aimbot FOV", Default = 230, Min = 50, Max = 500, Rounding = 10, Callback = function(v) F.AimbotFOV = v end })
Tabs.Combat:AddToggle("AutoKill", { Title = "Auto Kill", Default = false, Callback = function(v) F.AutoKill = v end })
Tabs.Combat:AddToggle("AutoShoot", { Title = "Auto Shoot", Default = false, Callback = function(v) F.AutoShoot = v end })
Tabs.Combat:AddToggle("KnifeAura", { Title = "Knife Aura", Default = false, Callback = function(v) F.KnifeAura = v end })
Tabs.Combat:AddSlider("AuraRange", { Title = "Aura Range", Default = 15, Min = 6, Max = 40, Rounding = 1, Callback = function(v) F.AuraRange = v end })
Tabs.Combat:AddToggle("KillTarget", { Title = "Kill Selected", Default = false, Callback = function(v) F.KillTarget = v end })

--============================================================
-- TROLL
--============================================================
Tabs.Troll:AddDropdown("FlingType", { Title = "Fling Type", Values = {"Normal", "Strong", "Up"}, Default = 1, Callback = function(v) F.FlingType = v end })
Tabs.Troll:AddToggle("FlingNearest", { Title = "Fling Nearest", Default = false, Callback = function(v) F.FlingNearest = v end })
Tabs.Troll:AddToggle("FlingTarget", { Title = "Fling Selected", Default = false, Callback = function(v) F.FlingTarget = v end })
Tabs.Troll:AddToggle("FlingAll", { Title = "Fling All", Default = false, Callback = function(v) F.FlingAll = v end })
Tabs.Troll:AddToggle("InvisibleSelf", { Title = "Invisible Self", Default = false, Callback = function(v) F.Invisible = v; SetInvis(v) end })
Tabs.Troll:AddToggle("RainbowSelf", { Title = "Rainbow Self", Default = false, Callback = function(v) F.RainbowSelf = v end })
Tabs.Troll:AddToggle("FreezeTarget", { Title = "Freeze Target", Default = false, Callback = function(v) F.FreezeTarget = v end })
Tabs.Troll:AddToggle("InvisibleTarget", { Title = "Invisible Target", Default = false, Callback = function(v) F.InvisibleTarget = v end })
Tabs.Troll:AddToggle("SpinTarget", { Title = "Spin Target", Default = false, Callback = function(v) F.SpinTarget = v end })
Tabs.Troll:AddToggle("PlatformTarget", { Title = "Platform Under Target", Default = false, Callback = function(v) F.PlatformTarget = v end })
Tabs.Troll:AddToggle("DisableJumpTarget", { Title = "Disable Jump", Default = false, Callback = function(v) F.DisableJumpTarget = v end })
Tabs.Troll:AddToggle("DisableMoveTarget", { Title = "Disable Movement", Default = false, Callback = function(v) F.DisableMoveTarget = v end })
Tabs.Troll:AddToggle("SlowMotionTarget", { Title = "Slow Motion", Default = false, Callback = function(v) F.SlowMotionTarget = v end })
Tabs.Troll:AddButton({ Title = "Force Sit", Callback = function() local t = GetTarget(); if t then ForceSit(t) end end })
Tabs.Troll:AddButton({ Title = "Explode Target", Callback = function() local t = GetTarget(); if t then Explode(t) end end })
Tabs.Troll:AddButton({ Title = "Push Away", Callback = function() local t = GetTarget(); local a, b = GetMyRoot(), GetTargetRoot(); if t and a and b then PushPull(t, (a.Position - b.Position).Unit) end end })
Tabs.Troll:AddButton({ Title = "Pull Toward", Callback = function() local t = GetTarget(); local a, b = GetMyRoot(), GetTargetRoot(); if t and a and b then PushPull(t, (b.Position - a.Position).Unit) end end })
Tabs.Troll:AddToggle("FreezeAll", { Title = "Freeze All", Default = false, Callback = function(v) F.FreezeAll = v end })
Tabs.Troll:AddToggle("SpinAll", { Title = "Spin All", Default = false, Callback = function(v) F.SpinAll = v end })
Tabs.Troll:AddButton({ Title = "Explode All", Callback = function() for _, p in ipairs(Players:GetPlayers()) do if p ~= LP then Explode(p) end end end })

--============================================================
-- EMOTES
--============================================================
local eNames = {}; for _, e in ipairs(EmoteList) do table.insert(eNames, e.Name) end
Tabs.Emotes:AddDropdown("EmoteDropdown", { Title = "Emote", Values = eNames, Default = 1,
    Callback = function(v) for _, e in ipairs(EmoteList) do if e.Name == v then F.SelectedEmote = e.ID end end end })
Tabs.Emotes:AddInput("CustomEmote", { Title = "Custom Emote ID", Placeholder = "rbxassetid://...", Callback = function(t) if t ~= "" then F.SelectedEmote = t end end })
Tabs.Emotes:AddButton({ Title = "Play on Self", Callback = function() if F.SelectedEmote then clearEmotes(); PlayEmote(LP, F.SelectedEmote) end end })
Tabs.Emotes:AddButton({ Title = "Play on Target", Callback = function() local t = GetTarget(); if t and F.SelectedEmote then clearEmotes(); PlayEmote(t, F.SelectedEmote) end end })
Tabs.Emotes:AddButton({ Title = "Stop All Emotes", Callback = clearEmotes })

--============================================================
-- ANTI
--============================================================
Tabs.Anti:AddToggle("AntiAFK", { Title = "Anti AFK", Default = true, Callback = function(v) F.AntiAFK = v end })
Tabs.Anti:AddToggle("AntiFling", { Title = "Anti Fling", Default = true, Callback = function(v) F.AntiFling = v end })
Tabs.Anti:AddToggle("AntiDie", { Title = "Anti Die", Default = false, Callback = function(v) F.AntiDie = v end })
Tabs.Anti:AddToggle("AntiVoid", { Title = "Anti Void", Default = false, Callback = function(v) F.AntiVoid = v end })
Tabs.Anti:AddToggle("AntiSit", { Title = "Anti Sit", Default = false, Callback = function(v) F.AntiSit = v end })
Tabs.Anti:AddToggle("AntiRagdoll", { Title = "Anti Ragdoll", Default = false, Callback = function(v) F.AntiRagdoll = v end })

--============================================================
-- REPORT
--============================================================
Tabs.Report:AddParagraph({
    Title = "Report a User",
    Content = "Report someone for breaking rules or exploiting.\nInclude as much detail as possible.",
})

local reportTargetName, reportCategory, reportDetails, reportEvidence = "", "cheating", "", ""
Tabs.Report:AddInput("ReportTarget", { Title = "Target Username or ID", Placeholder = "Username or UserID", Callback = function(t) reportTargetName = t end })
Tabs.Report:AddDropdown("ReportCategory", { Title = "Category", Values = {"cheating", "exploiting", "toxicity", "harassment", "scamming", "bug-abuse", "other"}, Default = 1, Callback = function(v) reportCategory = v end })
Tabs.Report:AddInput("ReportDetails", { Title = "What happened?", Placeholder = "Describe...", Callback = function(t) reportDetails = t end })
Tabs.Report:AddInput("ReportEvidence", { Title = "Evidence (link)", Placeholder = "Optional", Callback = function(t) reportEvidence = t end })
Tabs.Report:AddButton({
    Title = "Submit Report",
    Callback = function()
        pcall(function()
            if reportTargetName == "" or reportDetails == "" then
                Fluent:Notify({ Title = "Error", Content = "Please fill target and details.", Duration = 4 }); return
            end
            Window:Dialog({
                Title = "Submit Report",
                Content = "Report "..reportTargetName.." for "..reportCategory.."?",
                Buttons = {
                    { Title = "Submit", Callback = function()
                        task.spawn(function()
                            pcall(function()
                                local targetId = tonumber(reportTargetName)
                                local targetP = Players:FindFirstChild(reportTargetName)
                                if targetP then targetId = targetP.UserId end
                                sbPost("zuzify_reports", {
                                    reporter_id = MY_UID, reporter_name = MY_NAME,
                                    target_id = targetId, target_name = reportTargetName,
                                    category = reportCategory, details = reportDetails,
                                    evidence = reportEvidence, status = "open",
                                })
                                sbPost("zuzify_audit_logs", {
                                    action = "report_created", actor_id = MY_UID, actor_name = MY_NAME,
                                    metadata = { category = reportCategory, target = reportTargetName },
                                })
                                Fluent:Notify({ Title = "Report Sent", Content = "Thank you.", Duration = 6 })
                            end)
                        end)
                    end },
                    { Title = "Cancel", Callback = function() end },
                },
            })
        end)
    end,
})
Tabs.Report:AddButton({
    Title = "View My Reports",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local d = sbGet("zuzify_reports", "reporter_id=eq."..MY_UID.."&select=*&order=created_at.desc&limit=20")
                local cnt = d and #d or 0
                if cnt == 0 then Fluent:Notify({ Title = "My Reports", Content = "You have no reports.", Duration = 5 }); return end
                local lines = {}
                for i, r in ipairs(d) do
                    table.insert(lines, i..". ["..r.status.."] "..r.category.." → "..(r.target_name or "?").." — "..FormatTime(r.created_at))
                end
                Fluent:Notify({ Title = "My Reports ("..cnt..")", Content = table.concat(lines, "\n"):sub(1, 3500), Duration = 15 })
            end)
        end)
    end,
})

--============================================================
-- FEEDBACK
--============================================================
Tabs.Feedback:AddParagraph({ Title = "Send Feedback", Content = "Tell us what you think!" })

local fbCategory, fbRating, fbSubject, fbMessage = "general", 5, "", ""
Tabs.Feedback:AddDropdown("FbCategory", { Title = "Category", Values = {"general", "bug", "feature", "ui", "performance", "suggestion"}, Default = 1, Callback = function(v) fbCategory = v end })
Tabs.Feedback:AddSlider("FbRating", { Title = "Rating (1-5)", Default = 5, Min = 1, Max = 5, Rounding = 1, Callback = function(v) fbRating = v end })
Tabs.Feedback:AddInput("FbSubject", { Title = "Subject", Placeholder = "Short summary", Callback = function(t) fbSubject = t end })
Tabs.Feedback:AddInput("FbMessage", { Title = "Message", Placeholder = "Your feedback...", Callback = function(t) fbMessage = t end })
Tabs.Feedback:AddButton({
    Title = "Submit Feedback",
    Callback = function()
        if fbMessage == "" then Fluent:Notify({ Title = "Error", Content = "Message required.", Duration = 4 }); return end
        task.spawn(function()
            pcall(function()
                sbPost("zuzify_feedback", {
                    author_id = MY_UID, author_name = MY_NAME,
                    category = fbCategory, rating = fbRating,
                    subject = fbSubject, message = fbMessage, status = "new",
                })
                sbPost("zuzify_audit_logs", {
                    action = "feedback_created", actor_id = MY_UID, actor_name = MY_NAME,
                    metadata = { category = fbCategory, rating = fbRating },
                })
                Fluent:Notify({ Title = "Feedback Sent", Content = "Thanks! ⭐", Duration = 6 })
                fbMessage = ""; fbSubject = ""
            end)
        end)
    end,
})

--============================================================
-- TICKETS
--============================================================
Tabs.Tickets:AddParagraph({ Title = "Support Tickets", Content = "Create a ticket to talk to staff." })

local ticketSubject, ticketCategory, ticketPriority, ticketBody = "", "general", "normal", ""
Tabs.Tickets:AddInput("TicketSubject", { Title = "Subject", Placeholder = "Summary", Callback = function(t) ticketSubject = t end })
Tabs.Tickets:AddDropdown("TicketCategory", { Title = "Category", Values = {"general", "bug", "report", "appeal", "purchase", "other"}, Default = 1, Callback = function(v) ticketCategory = v end })
Tabs.Tickets:AddDropdown("TicketPriority", { Title = "Priority", Values = {"low", "normal", "high", "urgent"}, Default = 2, Callback = function(v) ticketPriority = v end })
Tabs.Tickets:AddInput("TicketBody", { Title = "Describe the issue", Placeholder = "Message...", Callback = function(t) ticketBody = t end })
Tabs.Tickets:AddButton({
    Title = "Create Ticket",
    Callback = function()
        if ticketSubject == "" or ticketBody == "" then Fluent:Notify({ Title = "Error", Content = "Subject + message required.", Duration = 4 }); return end
        task.spawn(function()
            pcall(function()
                local created = sbPost("zuzify_tickets", {
                    subject = ticketSubject, category = ticketCategory, priority = ticketPriority,
                    status = "open", creator_id = MY_UID, creator_name = MY_NAME,
                    last_message = ticketBody:sub(1, 150), last_activity = nowISO(),
                })
                if created and #created > 0 then
                    local tid = created[1].id
                    sbPost("zuzify_ticket_messages", {
                        ticket_id = tid, sender_id = MY_UID, sender_name = MY_NAME,
                        sender_role = MY_ROLE, message = ticketBody,
                    })
                    Fluent:Notify({ Title = "Ticket Created", Content = "ID: "..tostring(tid):sub(1, 8), Duration = 8 })
                    ticketSubject = ""; ticketBody = ""
                else
                    Fluent:Notify({ Title = "Error", Content = "Could not create ticket.", Duration = 4 })
                end
            end)
        end)
    end,
})
Tabs.Tickets:AddButton({
    Title = "View My Tickets",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local d = sbGet("zuzify_tickets", "creator_id=eq."..MY_UID.."&select=*&order=last_activity.desc&limit=20")
                if not d or #d == 0 then Fluent:Notify({ Title = "My Tickets", Content = "No tickets.", Duration = 5 }); return end
                local lines = {}
                for i, t in ipairs(d) do
                    table.insert(lines, i..". ["..t.status.."/"..t.priority.."] "..t.subject.." — "..FormatTime(t.last_activity).."\n   ID: "..tostring(t.id))
                end
                Fluent:Notify({ Title = "My Tickets ("..#d..")", Content = table.concat(lines, "\n\n"):sub(1, 3500), Duration = 20 })
            end)
        end)
    end,
})

local currentTicketId = ""
Tabs.Tickets:AddInput("TicketIDInput", { Title = "Open Ticket by ID", Placeholder = "Paste ticket ID", Callback = function(t) currentTicketId = t end })
Tabs.Tickets:AddButton({
    Title = "Open Ticket",
    Callback = function()
        if currentTicketId == "" then return end
        task.spawn(function()
            pcall(function()
                local t = sbGet("zuzify_tickets", "id=eq."..HttpService:UrlEncode(currentTicketId).."&select=*")
                if not t or #t == 0 then Fluent:Notify({ Title = "Not Found", Content = "Ticket not found.", Duration = 4 }); return end
                local tk = t[1]
                if tk.creator_id ~= MY_UID and not IsStaff() then
                    Fluent:Notify({ Title = "Restricted", Content = "You cannot view this ticket.", Duration = 4 }); return
                end
                local msgs = sbGet("zuzify_ticket_messages", "ticket_id=eq."..HttpService:UrlEncode(currentTicketId).."&select=*&order=created_at.asc")
                local lines = { "Subject: "..tk.subject, "Status: "..tk.status, "Priority: "..tk.priority, "" }
                for _, m in ipairs(msgs or {}) do
                    table.insert(lines, "["..m.sender_name.." - "..RoleLabel(m.sender_role).."] "..FormatTime(m.created_at))
                    table.insert(lines, m.message)
                    table.insert(lines, "")
                end
                Fluent:Notify({ Title = "Ticket: "..tk.subject, Content = table.concat(lines, "\n"):sub(1, 3500), Duration = 20 })
            end)
        end)
    end,
})

local ticketReplyBody = ""
Tabs.Tickets:AddInput("TicketReply", { Title = "Reply to Open Ticket", Placeholder = "Your reply...", Callback = function(t) ticketReplyBody = t end })
Tabs.Tickets:AddButton({
    Title = "Send Reply",
    Callback = function()
        if currentTicketId == "" or ticketReplyBody == "" then Fluent:Notify({ Title = "Error", Content = "Open a ticket first.", Duration = 4 }); return end
        task.spawn(function()
            pcall(function()
                sbPost("zuzify_ticket_messages", {
                    ticket_id = currentTicketId, sender_id = MY_UID, sender_name = MY_NAME,
                    sender_role = MY_ROLE, message = ticketReplyBody,
                })
                sbPatch("zuzify_tickets", "id=eq."..HttpService:UrlEncode(currentTicketId), {
                    last_message = ticketReplyBody:sub(1, 150), last_activity = nowISO(),
                })
                Fluent:Notify({ Title = "Sent", Content = "Message sent.", Duration = 4 })
                ticketReplyBody = ""
            end)
        end)
    end,
})

--============================================================
-- APPLY
--============================================================
Tabs.Apply:AddParagraph({ Title = "Apply for Staff", Content = "Fill out the form below." })

local appFor = "moderator"
local appExperience, appWhy, appHours, appAge = "", "", "", ""
local appTimezone, appStrengths, appWeaknesses, appPrevRank, appNotes = "", "", "", "", ""

Tabs.Apply:AddDropdown("AppFor", { Title = "Position", Values = {"moderator", "head_moderator", "admin", "head_admin", "community_manager", "developer"}, Default = 1, Callback = function(v) appFor = v end })
Tabs.Apply:AddInput("AppExperience", { Title = "Experience", Placeholder = "Prior experience", Callback = function(t) appExperience = t end })
Tabs.Apply:AddInput("AppWhy", { Title = "Why should we pick you?", Placeholder = "...", Callback = function(t) appWhy = t end })
Tabs.Apply:AddInput("AppHours", { Title = "Hours per week", Placeholder = "e.g. 15", Callback = function(t) appHours = t end })
Tabs.Apply:AddInput("AppAge", { Title = "Age", Placeholder = "e.g. 16", Callback = function(t) appAge = t end })
Tabs.Apply:AddInput("AppTimezone", { Title = "Timezone", Placeholder = "e.g. UTC-5", Callback = function(t) appTimezone = t end })
Tabs.Apply:AddInput("AppStrengths", { Title = "Strengths", Placeholder = "...", Callback = function(t) appStrengths = t end })
Tabs.Apply:AddInput("AppWeaknesses", { Title = "Weaknesses", Placeholder = "...", Callback = function(t) appWeaknesses = t end })
Tabs.Apply:AddInput("AppPrevRank", { Title = "Previous rank(s)", Placeholder = "If any", Callback = function(t) appPrevRank = t end })
Tabs.Apply:AddInput("AppNotes", { Title = "Additional notes", Placeholder = "Optional", Callback = function(t) appNotes = t end })
Tabs.Apply:AddButton({
    Title = "Submit Application",
    Callback = function()
        if appWhy == "" or appExperience == "" then Fluent:Notify({ Title = "Error", Content = "Experience + Why required.", Duration = 4 }); return end
        Window:Dialog({
            Title = "Confirm Application",
            Content = "Apply for "..appFor.."?",
            Buttons = {
                { Title = "Submit", Callback = function()
                    task.spawn(function()
                        pcall(function()
                            sbPost("zuzify_applications", {
                                applicant_id = MY_UID, applicant_name = MY_NAME,
                                applying_for = appFor, experience = appExperience, why_apply = appWhy,
                                hours_per_week = appHours, age = appAge, timezone = appTimezone,
                                strengths = appStrengths, weaknesses = appWeaknesses,
                                previous_rank = appPrevRank, additional_notes = appNotes,
                                status = "pending",
                            })
                            Fluent:Notify({ Title = "Application Sent", Content = "Owner will review soon.", Duration = 8 })
                        end)
                    end)
                end },
                { Title = "Cancel", Callback = function() end },
            },
        })
    end,
})
Tabs.Apply:AddButton({
    Title = "View My Applications",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local d = sbGet("zuzify_applications", "applicant_id=eq."..MY_UID.."&select=*&order=created_at.desc&limit=10")
                if not d or #d == 0 then Fluent:Notify({ Title = "My Applications", Content = "None submitted.", Duration = 5 }); return end
                local lines = {}
                for i, a in ipairs(d) do
                    table.insert(lines, i..". ["..a.status.."] "..a.applying_for.." — "..FormatTime(a.created_at))
                end
                Fluent:Notify({ Title = "My Applications ("..#d..")", Content = table.concat(lines, "\n"):sub(1, 3500), Duration = 15 })
            end)
        end)
    end,
})

--============================================================
-- TRUSTED
--============================================================
if IsTrusted() and Tabs.Trusted then
    Tabs.Trusted:AddParagraph({ Title = "★ Trusted Program", Content = "Exclusive features for supporters." })
    Tabs.Trusted:AddToggle("TrustedRainbowTrail", { Title = "★ Rainbow Trail", Default = false, Callback = function(v) F.TrustedRainbowTrail = v end })
    Tabs.Trusted:AddToggle("TrustedGoldESP", { Title = "★ Gold ESP", Default = false, Callback = function(v) F.ESP_GoldESP = v; refreshESP() end })
    Tabs.Trusted:AddColorpicker("TrustedColorPicker", { Title = "★ Custom Gold Color", Default = Color3.fromRGB(255, 215, 0), Callback = function(c) F.ESP_TrustedColor = c; refreshESP() end })
    Tabs.Trusted:AddInput("TrustedTitle", { Title = "★ Custom Title", Placeholder = "e.g. Verified Supporter", Callback = function(t)
        pcall(function()
            F.TrustedCustomTitle = t
            local tf = MY_TRUSTED_FEATURES or {}
            tf.custom_title = t
            sbPatch("zuzify_users", "user_id=eq."..MY_UID, { trusted_features = tf })
            Fluent:Notify({ Title = "Saved", Content = "Custom title saved.", Duration = 4 })
        end)
    end })
end

--============================================================
-- DEBUG
--============================================================
Tabs.Debug:AddToggle("DebugOverlay", { Title = "Debug Overlay", Default = false, Callback = function(v) F.Debug_Overlay = v; if not v then teardownDebugGui() end end })
Tabs.Debug:AddButton({ Title = "Rebuild ESP", Callback = function() pcall(refreshESP); pcall(function() Fluent:Notify({ Title = "ESP", Content = "Rebuilt.", Duration = 3 }) end) end })
Tabs.Debug:AddButton({ Title = "Clear Role Cache", Callback = function() CachedRoles = {}; pcall(function() Fluent:Notify({ Title = "Cache", Content = "Cleared.", Duration = 3 }) end) end })
Tabs.Debug:AddButton({ Title = "Clear Zuzy Parts", Callback = function()
    pcall(function()
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj.Name:sub(1, 1) == "Z" and #obj.Name >= 4 then obj:Destroy() end
        end
        Fluent:Notify({ Title = "Cleanup", Content = "Done.", Duration = 3 })
    end)
end })

--============================================================
-- SETTINGS
--============================================================
if SaveManager then
    pcall(function()
        SaveManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        SaveManager:SetFolder("ZuzifyRBX/Configs")
    end)
end
if InterfaceManager then
    pcall(function()
        InterfaceManager:SetLibrary(Fluent)
        InterfaceManager:SetFolder("ZuzifyRBX")
    end)
end

Tabs.Settings:AddParagraph({
    Title = "About",
    Content = "ZuzifyRBX "..VERSION.."\nOwner: mrcoptai\nTime: "..os.date("%Y-%m-%d %H:%M:%S"),
})
Tabs.Settings:AddButton({
    Title = "💾 Save to Cloud (Supabase)",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local cfg = {}
                for k, v in pairs(F) do
                    if type(v) == "boolean" or type(v) == "number" or type(v) == "string" then cfg[k] = v end
                end
                local ok = pcall(function()
                    sbPatch("zuzify_users", "user_id=eq."..MY_UID, { config = cfg, config_updated_at = nowISO() })
                end)
                Fluent:Notify({ Title = "Cloud Save", Content = ok and "✅ Saved." or "❌ Failed.", Duration = 4 })
            end)
        end)
    end,
})
Tabs.Settings:AddButton({
    Title = "📂 Load from Cloud (Supabase)",
    Callback = function()
        task.spawn(function()
            pcall(function()
                local d = sbGet("zuzify_users", "user_id=eq."..MY_UID.."&select=config")
                if d and #d > 0 and d[1].config then
                    for k, v in pairs(d[1].config) do
                        if F[k] ~= nil and type(F[k]) == type(v) then F[k] = v end
                    end
                    Fluent:Notify({ Title = "Cloud Load", Content = "✅ Loaded.", Duration = 6 })
                else
                    Fluent:Notify({ Title = "Cloud Load", Content = "❌ No config.", Duration = 4 })
                end
            end)
        end)
    end,
})
Tabs.Settings:AddButton({
    Title = "🔄 Reset Local Config",
    Callback = function()
        for k, v in pairs(F) do if type(v) == "boolean" then F[k] = false end end
        pcall(function() Fluent:Notify({ Title = "Reset", Content = "Local toggles cleared.", Duration = 4 }) end)
    end,
})
Tabs.Settings:AddToggle("ShareUsername", {
    Title = "Share Username (Trusted Program)",
    Default = F.ShareUsername,
    Callback = function(v)
        F.ShareUsername = v
        task.spawn(function()
            pcall(function()
                sbPatch("zuzify_users", "user_id=eq."..MY_UID, { show_username = v })
                if v and HasTier(MY_TIER, "basic") then
                    sbPatch("zuzify_users", "user_id=eq."..MY_UID, { is_trusted = true })
                    Fluent:Notify({ Title = "Trusted", Content = "You are now Trusted!", Duration = 5 })
                end
            end)
        end)
    end,
})
Tabs.Settings:AddButton({ Title = "Rejoin Server", Callback = function() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end })

-- Optionally build Save/Interface sections
if InterfaceManager then pcall(function() InterfaceManager:BuildInterfaceSection(Tabs.Settings) end) end
if SaveManager then pcall(function() SaveManager:BuildConfigSection(Tabs.Settings) end) end

--============================================================
-- STAFF TAB
--============================================================
if IsStaff() then
    local StaffTab = Window:AddTab({ Title = RoleLabel(MY_ROLE), Icon = "crown" })
    StaffTab:AddParagraph({
        Title = "Staff Panel — "..RoleLabel(MY_ROLE),
        Content = "Welcome, "..MY_NAME..".\nTime: "..os.date("%Y-%m-%d %H:%M:%S"),
    })

    StaffTab:AddButton({
        Title = "🌐 Online Users",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    local d = sbGet("zuzify_sessions", "last_ping=gt."..HttpService:UrlEncode(DateTime.now():AddSeconds(-180):ToIsoDate()).."&select=*")
                    local cnt = d and #d or 0
                    local lines = {}
                    for _, s in ipairs(d or {}) do
                        local l = (s.show_username and s.username) and (s.username.." ("..s.user_id..")") or ("Anon #"..tostring(s.user_id):sub(-4))
                        table.insert(lines, l.." ["..RoleLabel(s.role).." / "..RoleLabel(s.tier).."]")
                    end
                    Fluent:Notify({ Title = "Online: "..cnt, Content = table.concat(lines, "\n"):sub(1, 3500), Duration = 12 })
                end)
            end)
        end,
    })
    StaffTab:AddButton({
        Title = "📊 Global Stats",
        Callback = function()
            task.spawn(function()
                pcall(function()
                    local s = sbGet("zuzify_stats", "select=*")
                    if s and #s > 0 then
                        local r = s[1]
                        Fluent:Notify({
                            Title = "Global Stats",
                            Content = "Users: "..r.total_users.."\nOnline: "..r.online_now..
                                      "\nPaid: "..r.paid_users.."\nTrusted: "..r.trusted_users..
                                      "\nStaff: "..r.staff_users.."\nBanned: "..r.banned_users..
                                      "\nOpen Reports: "..r.open_reports.."\nOpen Tickets: "..r.open_tickets..
                                      "\nPending Apps: "..r.pending_apps.."\nNew Feedback: "..r.new_feedback,
                            Duration = 15,
                        })
                    end
                end)
            end)
        end,
    })

    local modTarget, modReason = "", ""
    StaffTab:AddInput("ModTarget", { Title = "Target User ID", Placeholder = "1234567", Callback = function(t) modTarget = t end })
    StaffTab:AddInput("ModReason", { Title = "Reason", Placeholder = "Reason", Callback = function(t) modReason = t end })
    StaffTab:AddButton({ Title = "⚠ Warn User", Callback = function()
        if modTarget == "" or modReason == "" then Fluent:Notify({ Title = "Error", Content = "Fill fields.", Duration = 4 }); return end
        task.spawn(function()
            pcall(function()
                sbPost("zuzify_warnings", { user_id = tonumber(modTarget), moderator_id = MY_UID, moderator_name = MY_NAME, reason = modReason, severity = 1 })
                sbPost("zuzify_audit_logs", { action = "warn", actor_id = MY_UID, actor_name = MY_NAME, target_id = tonumber(modTarget), reason = modReason })
                Fluent:Notify({ Title = "Warned", Content = "Done.", Duration = 4 })
            end)
        end)
    end })
    StaffTab:AddButton({ Title = "👢 Kick User", Callback = function()
        if modTarget == "" then return end
        task.spawn(function()
            pcall(function()
                sbPatch("zuzify_users", "user_id=eq."..modTarget, { kick_signal = true, kick_reason = modReason })
                sbPost("zuzify_audit_logs", { action = "kick", actor_id = MY_UID, actor_name = MY_NAME, target_id = tonumber(modTarget), reason = modReason })
                Fluent:Notify({ Title = "Kicked", Content = "Queued.", Duration = 4 })
            end)
        end)
    end })

    if IsAdmin() then
        local banMins = 60
        StaffTab:AddSlider("BanMinutes", { Title = "Ban Minutes (0=perm)", Default = 60, Min = 0, Max = 43200, Rounding = 1, Callback = function(v) banMins = v end })
        StaffTab:AddButton({ Title = "🚫 Ban User", Callback = function()
            if modTarget == "" then return end
            task.spawn(function()
                pcall(function()
                    local u = banMins > 0 and DateTime.now():AddSeconds(banMins*60):ToIsoDate() or nil
                    sbPatch("zuzify_users", "user_id=eq."..modTarget, { is_banned = true, ban_reason = modReason, ban_until = u, ban_by = MY_UID })
                    sbPost("zuzify_audit_logs", { action = "ban", actor_id = MY_UID, actor_name = MY_NAME, target_id = tonumber(modTarget), reason = modReason })
                    Fluent:Notify({ Title = "Banned", Content = "Done.", Duration = 4 })
                end)
            end)
        end })
        StaffTab:AddButton({ Title = "✅ Unban User", Callback = function()
            if modTarget == "" then return end
            task.spawn(function()
                pcall(function()
                    sbPatch("zuzify_users", "user_id=eq."..modTarget, { is_banned = false, ban_reason = nil, ban_until = nil })
                    Fluent:Notify({ Title = "Unbanned", Content = "Done.", Duration = 4 })
                end)
            end)
        end })

        StaffTab:AddButton({ Title = "🎟 View Open Tickets", Callback = function()
            task.spawn(function()
                pcall(function()
                    local d = sbGet("zuzify_tickets", "status=eq.open&select=*&order=last_activity.desc&limit=20")
                    local cnt = d and #d or 0
                    if cnt == 0 then Fluent:Notify({ Title = "Tickets", Content = "None open.", Duration = 5 }); return end
                    local lines = {}
                    for i, t in ipairs(d) do
                        table.insert(lines, i..". ["..t.priority.."] "..t.subject.." by "..(t.creator_name or "?").."\n   ID: "..t.id)
                    end
                    Fluent:Notify({ Title = "Open Tickets: "..cnt, Content = table.concat(lines, "\n\n"):sub(1, 3500), Duration = 20 })
                end)
            end)
        end })
        StaffTab:AddButton({ Title = "🚩 View Open Reports", Callback = function()
            task.spawn(function()
                pcall(function()
                    local d = sbGet("zuzify_reports", "status=eq.open&select=*&order=created_at.desc&limit=20")
                    local cnt = d and #d or 0
                    if cnt == 0 then Fluent:Notify({ Title = "Reports", Content = "None open.", Duration = 5 }); return end
                    local lines = {}
                    for i, r in ipairs(d) do
                        table.insert(lines, i..". "..r.category.." → "..(r.target_name or "?").." by "..(r.reporter_name or "?"))
                    end
                    Fluent:Notify({ Title = "Open Reports: "..cnt, Content = table.concat(lines, "\n\n"):sub(1, 3500), Duration = 20 })
                end)
            end)
        end })
        StaffTab:AddButton({ Title = "💬 View New Feedback", Callback = function()
            task.spawn(function()
                pcall(function()
                    local d = sbGet("zuzify_feedback", "status=eq.new&select=*&order=created_at.desc&limit=20")
                    local cnt = d and #d or 0
                    if cnt == 0 then Fluent:Notify({ Title = "Feedback", Content = "None new.", Duration = 5 }); return end
                    local lines = {}
                    for i, f in ipairs(d) do
                        table.insert(lines, i..". ["..string.rep("★", f.rating or 0).."] "..(f.subject or "(no subject)"))
                    end
                    Fluent:Notify({ Title = "New Feedback: "..cnt, Content = table.concat(lines, "\n\n"):sub(1, 3500), Duration = 20 })
                end)
            end)
        end })

        local newTier, newDays, keyCount = "premium", 30, 5
        StaffTab:AddDropdown("KeyTier", { Title = "Key Tier", Values = {"basic", "premium", "trusted", "moderator", "head_moderator", "admin", "head_admin", "community_manager", "developer"}, Default = 1, Callback = function(v) newTier = v end })
        StaffTab:AddSlider("KeyDays", { Title = "Key Days", Default = 30, Min = 1, Max = 3650, Rounding = 1, Callback = function(v) newDays = v end })
        StaffTab:AddSlider("KeyCount", { Title = "Key Count", Default = 5, Min = 1, Max = 50, Rounding = 1, Callback = function(v) keyCount = v end })
        StaffTab:AddButton({ Title = "🎲 Generate Keys", Callback = function()
            task.spawn(function()
                pcall(function()
                    local function blk()
                        local s = ""; local ch = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                        for _ = 1, 4 do s = s..ch:sub(math.random(1, #ch), math.random(1, #ch)) end
                        return s
                    end
                    local keys = {}
                    for i = 1, keyCount do
                        local k = "ZUZIFY-"..blk().."-"..blk().."-"..blk()
                        sbPost("zuzify_keys", { license_key = k, tier = newTier, created_by = MY_UID, duration_days = newDays, is_active = true })
                        table.insert(keys, k)
                        task.wait(0.05)
                    end
                    local text = table.concat(keys, "\n")
                    if setclipboard then setclipboard(text) end
                    Fluent:Notify({ Title = "Generated "..keyCount, Content = text:sub(1, 3500), Duration = 15 })
                end)
            end)
        end })
    end

    if IsOwner() then
        local roleTarget, roleGive = "", "trusted"
        StaffTab:AddInput("RoleTarget", { Title = "User ID for Role", Placeholder = "1234567", Callback = function(t) roleTarget = t end })
        StaffTab:AddDropdown("RoleGive", {
            Title = "Role to Give",
            Values = {"user", "basic", "premium", "trusted", "moderator", "head_moderator", "admin", "head_admin", "community_manager", "developer", "owner"},
            Default = 5,
            Callback = function(v) roleGive = v end,
        })
        StaffTab:AddButton({ Title = "✅ Give Role", Callback = function()
            if roleTarget == "" then return end
            task.spawn(function()
                pcall(function()
                    sbPatch("zuzify_users", "user_id=eq."..roleTarget, { role = roleGive, tier = roleGive })
                    sbPost("zuzify_audit_logs", { action = "role_change", actor_id = MY_UID, actor_name = MY_NAME, target_id = tonumber(roleTarget), metadata = { new_role = roleGive } })
                    Fluent:Notify({ Title = "Role Applied", Content = roleTarget.." → "..RoleLabel(roleGive), Duration = 5 })
                end)
            end)
        end })

        StaffTab:AddButton({ Title = "📝 View Pending Applications", Callback = function()
            task.spawn(function()
                pcall(function()
                    local d = sbGet("zuzify_applications", "status=eq.pending&select=*&order=created_at.desc")
                    local cnt = d and #d or 0
                    if cnt == 0 then Fluent:Notify({ Title = "Applications", Content = "None pending.", Duration = 5 }); return end
                    local lines = {}
                    for i, a in ipairs(d) do
                        table.insert(lines, i..". "..(a.applicant_name or "?").." → "..a.applying_for.."\n   ID: "..tostring(a.id):sub(1, 8).."\n   Why: "..(a.why_apply or ""):sub(1, 100))
                    end
                    Fluent:Notify({ Title = "Pending: "..cnt, Content = table.concat(lines, "\n\n"):sub(1, 3500), Duration = 25 })
                end)
            end)
        end })

        local appIdInput, appAction, appReviewNotes = "", "accepted", ""
        StaffTab:AddInput("AppIdInput", { Title = "Application ID", Placeholder = "Paste ID", Callback = function(t) appIdInput = t end })
        StaffTab:AddDropdown("AppAction", { Title = "Action", Values = {"accepted", "declined", "on_hold"}, Default = 1, Callback = function(v) appAction = v end })
        StaffTab:AddInput("AppReviewNotes", { Title = "Review Notes", Placeholder = "Feedback", Callback = function(t) appReviewNotes = t end })
        StaffTab:AddButton({ Title = "📩 Process Application", Callback = function()
            if appIdInput == "" then Fluent:Notify({ Title = "Error", Content = "Enter ID.", Duration = 4 }); return end
            task.spawn(function()
                pcall(function()
                    sbPatch("zuzify_applications", "id=eq."..HttpService:UrlEncode(appIdInput), {
                        status = appAction, reviewed_by = MY_UID, reviewed_by_name = MY_NAME,
                        reviewed_at = nowISO(), review_notes = appReviewNotes,
                    })
                    Fluent:Notify({ Title = "Processed", Content = "→ "..appAction, Duration = 5 })
                end)
            end)
        end })

        StaffTab:AddDropdown("ScriptMode", { Title = "Script Mode", Values = {"online", "offline", "maintenance"}, Default = 1,
            Callback = function(v) task.spawn(function() pcall(function()
                sbPatch("zuzify_settings", "key=eq.script_mode", { value = v, updated_at = nowISO(), updated_by = MY_UID })
                GlobalSettings.script_mode = v
                Fluent:Notify({ Title = "Global", Content = "Script → "..v, Duration = 5 })
            end) end) end })
        StaffTab:AddDropdown("PaymentMode", { Title = "Payment Mode", Values = {"free", "paid", "paid_free"}, Default = 1,
            Callback = function(v) task.spawn(function() pcall(function()
                sbPatch("zuzify_settings", "key=eq.payment_mode", { value = v, updated_at = nowISO(), updated_by = MY_UID })
                GlobalSettings.payment_mode = v
                Fluent:Notify({ Title = "Global", Content = "Payment → "..v, Duration = 5 })
            end) end) end })
        StaffTab:AddDropdown("ApplicationsOpen", { Title = "Applications Open?", Values = {"true", "false"}, Default = 1,
            Callback = function(v) task.spawn(function() pcall(function()
                sbPatch("zuzify_settings", "key=eq.applications_open", { value = v, updated_at = nowISO(), updated_by = MY_UID })
                GlobalSettings.applications_open = v
                Fluent:Notify({ Title = "Global", Content = "Apps "..(v == "true" and "OPEN" or "CLOSED"), Duration = 5 })
            end) end) end })
        StaffTab:AddDropdown("TicketsOpen", { Title = "Tickets Open?", Values = {"true", "false"}, Default = 1,
            Callback = function(v) task.spawn(function() pcall(function()
                sbPatch("zuzify_settings", "key=eq.tickets_open", { value = v, updated_at = nowISO(), updated_by = MY_UID })
                GlobalSettings.tickets_open = v
                Fluent:Notify({ Title = "Global", Content = "Tickets "..(v == "true" and "OPEN" or "CLOSED"), Duration = 5 })
            end) end) end })

        StaffTab:AddButton({ Title = "📜 View Audit Logs", Callback = function()
            task.spawn(function()
                pcall(function()
                    local d = sbGet("zuzify_audit_logs", "select=*&order=created_at.desc&limit=30")
                    local s = {}
                    for _, a in ipairs(d or {}) do
                        table.insert(s, "["..FormatTime(a.created_at).."] ["..(a.actor_name or a.actor_id).."] "..a.action)
                    end
                    Fluent:Notify({ Title = "Audit Logs", Content = table.concat(s, "\n"):sub(1, 3500), Duration = 20 })
                end)
            end)
        end })
        StaffTab:AddButton({ Title = "🚨 Broadcast Kick All", Callback = function()
            task.spawn(function()
                pcall(function()
                    local all = sbGet("zuzify_sessions", "user_id=neq."..MY_UID.."&select=user_id")
                    for _, s in ipairs(all or {}) do
                        sbPatch("zuzify_users", "user_id=eq."..s.user_id, { kick_signal = true, kick_reason = "Maintenance" })
                    end
                    Fluent:Notify({ Title = "Broadcast", Content = "All queued for kick.", Duration = 5 })
                end)
            end)
        end })
    end
end

--============================================================
-- OWNER: Pending app notification
--============================================================
if IsOwner() then
    task.spawn(function()
        task.wait(3)
        pcall(function()
            local d = sbGet("zuzify_applications", "status=eq.pending&select=*")
            local cnt = d and #d or 0
            if cnt > 0 then
                Fluent:Notify({
                    Title = "📝 Pending Applications: "..cnt,
                    Content = "Open the Staff tab to review.",
                    SubContent = "You have "..cnt.." application(s).",
                    Duration = 15,
                })
            end
        end)
    end)
end

--============================================================
-- FINALIZE
--============================================================
pcall(function() Window:SelectTab(1) end)

pcall(function()
    Fluent:Notify({
        Title = "ZuzifyRBX "..VERSION,
        Content = "Welcome, "..MY_NAME.."!\nRole: "..RoleLabel(MY_ROLE).."\nTier: "..RoleLabel(MY_TIER),
        SubContent = IsStaff() and ("★ "..RoleLabel(MY_ROLE).." access") or
                     (IsTrusted() and "★ Trusted Program") or
                     "Loaded successfully",
        Duration = 10,
    })
end)

pcall(function()
    if SaveManager and SaveManager.LoadAutoloadConfig then
        SaveManager:LoadAutoloadConfig()
    end
end)

CloseLoading()
SafeLog("boot", "ready")
