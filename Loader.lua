








local BASE = "https://seelie-auth.ojars9111.workers.dev" 
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
            Headers = {
                ["Content-Type"] = "application/json",
                ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36",
                ["Accept"] = "*/*",
            },
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


local LANGS = {
    { "en", "English" }, { "ru", "Русский" }, { "pt", "Português" },
    { "hi", "हिन्दी" }, { "es", "Español" }, { "id", "Indonesia" },
}
local TR = {
    en = { login = "Login", checking = "Checking...", enter_key = "enter your key",
        server_down = "server unavailable", code_err = "code error",
        discord = "No key? Get one on Discord", copied = "Link copied — open it in your browser",
        e_not_passed = "no key entered", e_not_found = "key not found", e_revoked = "key revoked",
        e_expired = "key expired", e_no_hwid = "couldn't detect device",
        e_bound = "key is bound to another device", e_internal = "server error" },
    ru = { login = "Войти", checking = "Проверка...", enter_key = "введите ключ",
        server_down = "сервер недоступен", code_err = "ошибка кода",
        discord = "Нет ключа? Получить в Discord", copied = "Ссылка скопирована — открой в браузере",
        e_not_passed = "не передан ключ", e_not_found = "ключ не найден", e_revoked = "ключ отозван",
        e_expired = "ключ просрочен", e_no_hwid = "не удалось определить HWID",
        e_bound = "ключ привязан к другому устройству", e_internal = "внутренняя ошибка сервера" },
    pt = { login = "Entrar", checking = "Verificando...", enter_key = "digite sua chave",
        server_down = "servidor indisponível", code_err = "erro de código",
        discord = "Sem chave? Pegue no Discord", copied = "Link copiado — abra no navegador",
        e_not_passed = "nenhuma chave informada", e_not_found = "chave não encontrada", e_revoked = "chave revogada",
        e_expired = "chave expirada", e_no_hwid = "não foi possível identificar o dispositivo",
        e_bound = "chave vinculada a outro dispositivo", e_internal = "erro no servidor" },
    hi = { login = "लॉग इन करें", checking = "जाँच हो रही है...", enter_key = "अपनी कुंजी दर्ज करें",
        server_down = "सर्वर उपलब्ध नहीं है", code_err = "कोड त्रुटि",
        discord = "कुंजी नहीं है? Discord पर पाएं", copied = "लिंक कॉपी हो गया — ब्राउज़र में खोलें",
        e_not_passed = "कोई कुंजी दर्ज नहीं की", e_not_found = "कुंजी नहीं मिली", e_revoked = "कुंजी रद्द कर दी गई",
        e_expired = "कुंजी की समय सीमा समाप्त", e_no_hwid = "डिवाइस की पहचान नहीं हुई",
        e_bound = "कुंजी दूसरे डिवाइस से जुड़ी है", e_internal = "सर्वर त्रुटि" },
    es = { login = "Entrar", checking = "Verificando...", enter_key = "ingresa tu clave",
        server_down = "servidor no disponible", code_err = "error de código",
        discord = "¿Sin clave? Consíguela en Discord", copied = "Enlace copiado — ábrelo en el navegador",
        e_not_passed = "no se ingresó ninguna clave", e_not_found = "clave no encontrada", e_revoked = "clave revocada",
        e_expired = "clave expirada", e_no_hwid = "no se pudo identificar el dispositivo",
        e_bound = "la clave está vinculada a otro dispositivo", e_internal = "error del servidor" },
    id = { login = "Masuk", checking = "Memeriksa...", enter_key = "masukkan kunci kamu",
        server_down = "server tidak tersedia", code_err = "kesalahan kode",
        discord = "Tidak punya kunci? Dapatkan di Discord", copied = "Tautan disalin — buka di browser",
        e_not_passed = "kunci belum dimasukkan", e_not_found = "kunci tidak ditemukan", e_revoked = "kunci dicabut",
        e_expired = "kunci kedaluwarsa", e_no_hwid = "tidak dapat mendeteksi perangkat",
        e_bound = "kunci terhubung ke perangkat lain", e_internal = "kesalahan server" },
}

local ERRMAP = {
    ["не передан ключ"] = "e_not_passed", ["ключ не найден"] = "e_not_found", ["ключ отозван"] = "e_revoked",
    ["ключ просрочен"] = "e_expired", ["не удалось определить HWID"] = "e_no_hwid",
    ["ключ привязан к другому устройству"] = "e_bound", ["внутренняя ошибка сервера"] = "e_internal",
}
local lang = "en"
pcall(function()
    if type(isfile) == "function" and isfile("s2lang.txt") then
        local v = tostring(readfile("s2lang.txt")):gsub("%s+", "")
        if TR[v] then lang = v end
    end
end)
local function tr(k)
    return (TR[lang] and TR[lang][k]) or TR.en[k] or k
end
local function tr_err(raw)
    local m = ERRMAP[raw or ""]
    return m and tr(m) or raw
end


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
main.Size = UDim2.fromOffset(360, 392)
main.Position = UDim2.new(0.5, -180, 0.5, -196)
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
btn.Text = tr("login"); btn.AutoButtonColor = true
btn.Parent = main
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(0, 316); status.Size = UDim2.new(1, 0, 0, 18)
status.Font = Enum.Font.Gotham; status.TextSize = 13
status.TextColor3 = Color3.fromRGB(235, 110, 110); status.Text = ""
status.Parent = main




local INVITE = "https://discord.gg/Gmz6WcXWrr"
local discord = Instance.new("TextButton")
discord.Position = UDim2.new(0.5, -146, 0, 344); discord.Size = UDim2.fromOffset(292, 36)
discord.BackgroundColor3 = Color3.fromRGB(18, 18, 22); discord.BorderSizePixel = 0
discord.Font = Enum.Font.GothamMedium; discord.TextSize = 14; discord.TextColor3 = Color3.fromRGB(140, 150, 245)
discord.Text = tr("discord"); discord.AutoButtonColor = true
discord.Parent = main
Instance.new("UICorner", discord).CornerRadius = UDim.new(0, 9)
local dstroke = Instance.new("UIStroke", discord)
dstroke.Color = Color3.fromRGB(88, 101, 242); dstroke.Thickness = 1; dstroke.Transparency = 0.4
discord.MouseButton1Click:Connect(function()
    pcall(function() if type(setclipboard) == "function" then setclipboard(INVITE) end end)
    pcall(function() game:GetService("GuiService"):OpenBrowserWindow(INVITE) end)
    status.TextColor3 = Color3.fromRGB(120, 200, 140)
    status.Text = tr("copied")
end)

local close = Instance.new("TextButton")
close.Position = UDim2.new(1, -32, 0, 8); close.Size = UDim2.fromOffset(24, 24)
close.BackgroundTransparency = 1; close.Font = Enum.Font.GothamBold; close.TextSize = 16
close.TextColor3 = Color3.fromRGB(140, 140, 150); close.Text = "X"
close.Parent = main
close.MouseButton1Click:Connect(function() gui:Destroy() end)


local langBtn = Instance.new("TextButton")
langBtn.Position = UDim2.fromOffset(12, 8); langBtn.Size = UDim2.fromOffset(62, 24)
langBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 22); langBtn.BorderSizePixel = 0
langBtn.Font = Enum.Font.GothamMedium; langBtn.TextSize = 13; langBtn.TextColor3 = Color3.fromRGB(205, 205, 214)
langBtn.Text = "EN"; langBtn.AutoButtonColor = true; langBtn.Parent = main
Instance.new("UICorner", langBtn).CornerRadius = UDim.new(0, 7)
local lstroke = Instance.new("UIStroke", langBtn)
lstroke.Color = Color3.fromRGB(255, 255, 255); lstroke.Thickness = 1; lstroke.Transparency = 0.85

local langList = Instance.new("Frame")
langList.Position = UDim2.fromOffset(12, 36); langList.Size = UDim2.fromOffset(140, #LANGS * 30 + 8)
langList.BackgroundColor3 = Color3.fromRGB(13, 13, 16); langList.BorderSizePixel = 0
langList.Visible = false; langList.ZIndex = 20; langList.Parent = main
Instance.new("UICorner", langList).CornerRadius = UDim.new(0, 8)
local llstroke = Instance.new("UIStroke", langList)
llstroke.Color = Color3.fromRGB(255, 255, 255); llstroke.Thickness = 1; llstroke.Transparency = 0.8
local llpad = Instance.new("UIPadding", langList)
llpad.PaddingTop = UDim.new(0, 4); llpad.PaddingBottom = UDim.new(0, 4)
local lllayout = Instance.new("UIListLayout", langList); lllayout.SortOrder = Enum.SortOrder.LayoutOrder

local function applyLang()
    langBtn.Text = lang:upper()
    btn.Text = tr("login")
    discord.Text = tr("discord")
    status.Text = ""
end

for idx, entry in ipairs(LANGS) do
    local code, label = entry[1], entry[2]
    local opt = Instance.new("TextButton")
    opt.Size = UDim2.new(1, 0, 0, 30); opt.BackgroundTransparency = 1; opt.LayoutOrder = idx
    opt.Font = Enum.Font.Gotham; opt.TextSize = 14; opt.ZIndex = 21
    opt.TextXAlignment = Enum.TextXAlignment.Left; opt.TextColor3 = Color3.fromRGB(228, 228, 235)
    opt.Text = "   " .. label; opt.AutoButtonColor = true; opt.Parent = langList
    opt.MouseButton1Click:Connect(function()
        lang = code
        pcall(function() if type(writefile) == "function" then writefile("s2lang.txt", code) end end)
        langList.Visible = false
        applyLang()
    end)
end

langBtn.MouseButton1Click:Connect(function() langList.Visible = not langList.Visible end)
applyLang()


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
    status.TextColor3 = Color3.fromRGB(235, 110, 110)
    if key == "" then status.Text = tr("enter_key"); return end
    busy = true; btn.Text = tr("checking"); status.Text = ""
    task.spawn(function()
        local body = fetch(key, get_hwid())
        busy = false; btn.Text = tr("login")
        if not body or body == "" then status.Text = tr("server_down"); return end
        local err = body:match("^%-%-SEELIE%-ERR:([^\n]*)")
        if err then status.Text = tr_err(err); return end
        local f = loadstring(body)
        if not f then status.Text = tr("code_err"); return end
        pcall(function() if type(writefile) == "function" then writefile("s2key.txt", key) end end)
        gui:Destroy()
        pcall(f)
    end)
end
btn.MouseButton1Click:Connect(submit)
box.FocusLost:Connect(function(enter) if enter then submit() end end)

if getgenv and getgenv().s2_auto and prefill ~= "" then submit() end
