








local BASE = "https://seelie.ssixsevenn.xyz:8443" 
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

local function get_hwid()
    local h = "unknown"
    pcall(function()
        if type(gethwid) == "function" then
            h = tostring(gethwid())
        else
            h = tostring(game:GetService("RbxAnalyticsService"):GetClientId())
        end
    end)
    return h
end

local function fetch(key, hwid)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
        or (fluxus and fluxus.request)
    if type(req) == "function" then
        local ok, r = pcall(req, {
            Url = BASE .. "/auth", Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = hwid, v = 1 }),
        })
        if ok and type(r) == "table" and (r.Body or r.body) then return r.Body or r.body end
    end
    local ok, r = pcall(function()
        return game:HttpGetAsync(BASE .. "/auth?key=" .. HttpService:UrlEncode(key)
            .. "&hwid=" .. HttpService:UrlEncode(hwid) .. "&v=1")
    end)
    if ok then return r end
    return nil
end





local function fnv1a(s)
    local h = 2166136261
    for i = 1, #s do
        h = bit32.band(bit32.bxor(h, string.byte(s, i)) * 16777619, 0xFFFFFFFF)
    end
    return string.format("%08x", h)
end


local function load_logo()
    local getasset = getcustomasset or getsynasset or (syn and syn.getcustomasset)
    if type(getasset) ~= "function" or type(writefile) ~= "function" then return nil end
    local ok, data = pcall(function() return game:HttpGetAsync(BASE .. "/logo.png") end)
    if not ok or type(data) ~= "string" or #data == 0 then return nil end
    local fname = "seelie_logo_" .. fnv1a(data) .. ".png"
    if not pcall(writefile, fname, data) then return nil end
    local oka, id = pcall(getasset, fname)
    if oka and id then return id end
    return nil
end


local prefill = ""
pcall(function()
    local g = (getgenv and getgenv()) or {}
    prefill = tostring(g.key or g.s2key or "")
    if prefill == "" and type(isfile) == "function" and isfile("s2key.txt") then
        prefill = tostring(readfile("s2key.txt"))
    end
    prefill = prefill:gsub("%s+", "")
end)


local parent
pcall(function() parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not parent then parent = lp:WaitForChild("PlayerGui") end
pcall(function()
    local old = parent:FindFirstChild("SeelieKey")
    if old then old:Destroy() end
end)


local gui = Instance.new("ScreenGui")
gui.Name = "SeelieKey"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if not pcall(function() gui.Parent = parent end) then
    gui.Parent = lp:WaitForChild("PlayerGui")
end

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(360, 340)
main.Position = UDim2.new(0.5, -180, 0.5, -170)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Thickness = 1; stroke.Transparency = 0.84


local logoId = load_logo()
if logoId then
    local logo = Instance.new("ImageLabel")
    logo.BackgroundTransparency = 1
    logo.Size = UDim2.fromOffset(300, 172)
    logo.Position = UDim2.new(0.5, -150, 0, 16)
    logo.Image = logoId
    logo.ScaleType = Enum.ScaleType.Fit
    logo.Parent = main
else
    local wm = Instance.new("TextLabel")
    wm.BackgroundTransparency = 1
    wm.Position = UDim2.fromOffset(0, 60); wm.Size = UDim2.new(1, 0, 0, 40)
    wm.Font = Enum.Font.GothamMedium; wm.TextSize = 30
    wm.TextColor3 = Color3.fromRGB(240, 240, 248); wm.Text = "S E E L I E"
    wm.Parent = main
end

local sub = Instance.new("TextLabel")
sub.BackgroundTransparency = 1
sub.Position = UDim2.fromOffset(0, 192); sub.Size = UDim2.new(1, 0, 0, 20)
sub.Font = Enum.Font.GothamMedium; sub.TextSize = 15
sub.TextColor3 = Color3.fromRGB(170, 170, 182); sub.Text = "Slayers 2"
sub.Parent = main

local box = Instance.new("TextBox")
box.Position = UDim2.new(0.5, -146, 0, 222); box.Size = UDim2.fromOffset(292, 38)
box.BackgroundColor3 = Color3.fromRGB(15, 15, 17); box.BorderSizePixel = 0
box.Font = Enum.Font.Gotham; box.TextSize = 15; box.TextColor3 = Color3.fromRGB(240, 240, 245)
box.PlaceholderText = "SEELIE-XXXX-XXXX-XXXX"; box.PlaceholderColor3 = Color3.fromRGB(105, 105, 115)
box.Text = prefill; box.ClearTextOnFocus = false
box.Parent = main
Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
local bstroke = Instance.new("UIStroke", box)
bstroke.Color = Color3.fromRGB(255, 255, 255); bstroke.Thickness = 1; bstroke.Transparency = 0.86
local bpad = Instance.new("UIPadding", box)
bpad.PaddingLeft = UDim.new(0, 12); bpad.PaddingRight = UDim.new(0, 12)

local btn = Instance.new("TextButton")
btn.Position = UDim2.new(0.5, -146, 0, 270); btn.Size = UDim2.fromOffset(292, 40)
btn.BackgroundColor3 = Color3.fromRGB(240, 240, 245); btn.BorderSizePixel = 0
btn.Font = Enum.Font.GothamBold; btn.TextSize = 15; btn.TextColor3 = Color3.fromRGB(16, 16, 20)
btn.Text = "Ð’Ð¾Ð¹Ñ‚Ð¸"; btn.AutoButtonColor = true
btn.Parent = main
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(0, 316); status.Size = UDim2.new(1, 0, 0, 18)
status.Font = Enum.Font.Gotham; status.TextSize = 13
status.TextColor3 = Color3.fromRGB(235, 110, 110); status.Text = ""
status.Parent = main

local close = Instance.new("TextButton")
close.Position = UDim2.new(1, -32, 0, 8); close.Size = UDim2.fromOffset(24, 24)
close.BackgroundTransparency = 1; close.Font = Enum.Font.GothamBold; close.TextSize = 16
close.TextColor3 = Color3.fromRGB(140, 140, 150); close.Text = "X"
close.Parent = main
close.MouseButton1Click:Connect(function() gui:Destroy() end)


do
    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = i.Position; startPos = main.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

local busy = false
local function submit()
    if busy then return end
    local key = (box.Text or ""):gsub("%s+", "")
    if key == "" then status.Text = "Ð²Ð²ÐµÐ´Ð¸Ñ‚Ðµ ÐºÐ»ÑŽÑ‡"; return end
    busy = true; btn.Text = "ÐŸÑ€Ð¾Ð²ÐµÑ€ÐºÐ°..."; status.Text = ""
    task.spawn(function()
        local body = fetch(key, get_hwid())
        busy = false; btn.Text = "Ð’Ð¾Ð¹Ñ‚Ð¸"
        if not body or body == "" then status.Text = "ÑÐµÑ€Ð²ÐµÑ€ Ð½ÐµÐ´Ð¾ÑÑ‚ÑƒÐ¿ÐµÐ½"; return end
        local err = body:match("^%-%-SEELIE%-ERR:([^\n]*)")
        if err then status.Text = err; return end
        local f = loadstring(body)
        if not f then status.Text = "Ð¾ÑˆÐ¸Ð±ÐºÐ° ÐºÐ¾Ð´Ð°"; return end
        pcall(function() if type(writefile) == "function" then writefile("s2key.txt", key) end end)
        gui:Destroy()
        pcall(f)
    end)
end
btn.MouseButton1Click:Connect(submit)
box.FocusLost:Connect(function(enter) if enter then submit() end end)

if getgenv and getgenv().s2_auto and prefill ~= "" then submit() end
