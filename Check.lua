-- Seelie · executor compatibility check. Run on the target executor, ideally INSIDE Slayers 2.
-- Draws the result on screen (so it works on mobile where the console/clipboard are not visible).
-- Hosted on GitHub; users run: loadstring(game:HttpGet("<raw url>/Check.lua"))()
local function T(x) return type(x) == "function" end
local report
local ok, err = pcall(function()
    local out = {}; local function line(s) out[#out + 1] = s end
    local ex = "?"; pcall(function() if identifyexecutor then ex = tostring(identifyexecutor()) end end)
    local has = {
        getsenv = T(getsenv), getgc = T(getgc), firesignal = T(firesignal), getconnections = T(getconnections),
        dbg = (type(debug) == "table" and T(debug.getupvalues)),
        setid = T(setthreadidentity), getid = T(getthreadidentity),
        asset = (T(getcustomasset) or T(getsynasset)),
        writefile = T(writefile), readfile = T(readfile), isfile = T(isfile), makefolder = T(makefolder),
        setclip = T(setclipboard), loadstring = T(loadstring), getgenv = T(getgenv),
    }
    local http = T(request) or (syn and T(syn.request)) or T(http_request) or (http and T(http.request)) or (fluxus and T(fluxus.request))
    local atest = "skip"
    if has.writefile and has.asset then
        local ga = getcustomasset or getsynasset
        local a = pcall(writefile, "seelie_probe.txt", "x"); local b, id = pcall(ga, "seelie_probe.txt")
        atest = (a and b and id) and "OK" or "FAIL"; pcall(function() if delfile then delfile("seelie_probe.txt") end end)
    end
    local punch = "not in Slayers 2"
    if game.PlaceId == 136406881576517 or game.PlaceId == 75556147183481 then
        local lp = game:GetService("Players").LocalPlayer
        local cu = lp and lp:FindFirstChild("PlayerScripts") and lp.PlayerScripts:FindFirstChild("CU")
        local cb = cu and cu:FindFirstChild("Combat")
        if not cb then
            punch = "no Combat yet (wait for load)"
        elseif has.getsenv then
            local o, e = pcall(getsenv, cb)
            if o and type(e) == "table" and T(e.punch) then punch = "getsenv OK (punch)"
            elseif has.getgc then punch = "getsenv no punch, getgc fallback"
            else punch = "FAIL no punch" end
        elseif has.getgc then punch = "no getsenv, getgc fallback"
        else punch = "FAIL no getsenv/getgc" end
    end
    local core = has.loadstring and http and has.getgenv
    local farm = (has.getsenv or has.getgc) and has.setid and has.getid
    local events = has.firesignal and has.getconnections
    local files = has.writefile and has.readfile and has.isfile
    local verdict = core and farm and events and has.dbg and files and has.asset
    local function y(b) return b and "+" or "-" end
    line("== SEELIE EXEC CHECK ==")
    line("executor: " .. ex)
    line("VERDICT: " .. (verdict and "SUITABLE" or "NOT SUITABLE"))
    line("core (loadstring/http/getgenv): " .. y(core))
    line("farm: " .. y(farm) .. "  getsenv" .. y(has.getsenv) .. " getgc" .. y(has.getgc) .. " setid" .. y(has.setid) .. " getid" .. y(has.getid))
    line("events: " .. y(events) .. "  firesignal" .. y(has.firesignal) .. " getconnections" .. y(has.getconnections))
    line("internals debug.getupvalues: " .. y(has.dbg))
    line("files: " .. y(files) .. "  write" .. y(has.writefile) .. " read" .. y(has.readfile) .. " isfile" .. y(has.isfile) .. " makefolder" .. y(has.makefolder))
    line("assets getcustomasset: " .. y(has.asset) .. "  live:" .. atest)
    line("setclipboard (minor): " .. y(has.setclip))
    line("punch-test: " .. punch)
    report = table.concat(out, "\n")
end)
if not report then report = "CHECK ERROR:\n" .. tostring(err) end
pcall(function()
    local parent = (gethui and gethui()) or game:GetService("CoreGui")
    local old = parent:FindFirstChild("SeelieCheck"); if old then old:Destroy() end
    local gui = Instance.new("ScreenGui"); gui.Name = "SeelieCheck"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
    if not pcall(function() gui.Parent = parent end) then gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    local f = Instance.new("Frame"); f.Size = UDim2.fromOffset(540, 410); f.Position = UDim2.new(0.5, -270, 0.5, -205)
    f.BackgroundColor3 = Color3.fromRGB(12, 12, 15); f.BorderSizePixel = 0; f.Parent = gui
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)
    local st = Instance.new("UIStroke", f); st.Color = Color3.fromRGB(255, 255, 255); st.Thickness = 1; st.Transparency = 0.8
    local hdr = Instance.new("TextLabel"); hdr.BackgroundTransparency = 1; hdr.Position = UDim2.fromOffset(16, 10); hdr.Size = UDim2.new(1, -50, 0, 22)
    hdr.Font = Enum.Font.GothamBold; hdr.TextSize = 15; hdr.TextColor3 = Color3.fromRGB(240, 240, 245); hdr.TextXAlignment = Enum.TextXAlignment.Left
    hdr.Text = "Seelie check — screenshot & send"; hdr.Parent = f
    local box = Instance.new("TextLabel"); box.BackgroundTransparency = 1; box.Position = UDim2.fromOffset(16, 40); box.Size = UDim2.fromOffset(508, 360)
    box.Font = Enum.Font.Code; box.TextSize = 14; box.TextColor3 = Color3.fromRGB(220, 220, 228)
    box.TextXAlignment = Enum.TextXAlignment.Left; box.TextYAlignment = Enum.TextYAlignment.Top; box.TextWrapped = true; box.Text = report; box.Parent = f
    local x = Instance.new("TextButton"); x.Position = UDim2.new(1, -30, 0, 8); x.Size = UDim2.fromOffset(22, 22)
    x.BackgroundTransparency = 1; x.Font = Enum.Font.GothamBold; x.TextSize = 16; x.TextColor3 = Color3.fromRGB(150, 150, 160); x.Text = "X"; x.Parent = f
    x.MouseButton1Click:Connect(function() gui:Destroy() end)
end)
pcall(function() setclipboard(report) end)
