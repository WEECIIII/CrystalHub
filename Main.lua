local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
while not lp do task.wait(0.1) lp = Players.LocalPlayer end
local CoreGui = game:GetService("CoreGui")

local UI_COLOR = Color3.fromRGB(130, 90, 255)
local BG_COLOR = Color3.fromRGB(10, 10, 15)
local ELEM_COLOR = Color3.fromRGB(20, 20, 28)
local TEXT_COLOR = Color3.fromRGB(240, 240, 240)

local HttpService = game:GetService("HttpService")
local RbxAnalyticsService = game:GetService("RbxAnalyticsService")
local hwid = "Unknown"
pcall(function() hwid = RbxAnalyticsService:GetClientId() end)
if hwid == "Unknown" then
    pcall(function() hwid = game:GetService("Players").LocalPlayer.UserId .. "_fallback" end)
end

local BACKEND_URL = "https://admin.agentx1458.workers.dev"
local CONFIG_FOLDER = "CrystalHub"
local CONFIG_FILE = CONFIG_FOLDER .. "/KeyConfig.json"

local function SaveKey(key)
    if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end
    writefile(CONFIG_FILE, HttpService:JSONEncode({key = key}))
end

local function LoadKey()
    if isfolder(CONFIG_FOLDER) and isfile(CONFIG_FILE) then
        local s, res = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if s and res and res.key then return res.key end
    end
    return nil
end

local keyExpiryTime = nil

local function VerifyKeyRequest(key)
    local success, res = pcall(function()
        return request({
            Url = BACKEND_URL .. "/api/verify",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({ key = key, hwid = hwid })
        })
    end)
    
    if success and res then
        local data = {}
        pcall(function() data = HttpService:JSONDecode(res.Body) end)
        
        if res.StatusCode == 200 and data.success then
            if data.expiresAt then keyExpiryTime = data.expiresAt end
            return true, "Success"
        end
        
        local err = data.error or "Invalid Key"
        if string.find(err, "Script not uploaded yet") then
            if data.expiresAt then keyExpiryTime = data.expiresAt end
            return true, "Success"
        end
        
        return false, err
    end
    
    return false, "Network Error"
end

local isVerified = false
local savedKey = LoadKey()

if savedKey then
    local ok, _ = VerifyKeyRequest(savedKey)
    if ok then isVerified = true end
end

if not isVerified then
    local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/BocusLuke/UI/main/STX/Client.Lua"))()
    local function Notify(title, text)
        Notification:Notify(
            {Title = title, Description = text},
            {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "default"}
        )
    end
    
    pcall(function()
        for _, v in pairs(CoreGui:GetChildren()) do
            if v.Name == "CrystalHubKeySystem" then
                v:Destroy()
            end
        end
        for _, v in pairs(game.Lighting:GetChildren()) do
            if v.Name == "CrystalBlurEffect" then
                v:Destroy()
            end
        end
    end)

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CrystalHubKeySystem"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    
    if gethui then
        ScreenGui.Parent = gethui()
    else
        pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    end
    if not ScreenGui.Parent then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
    
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Blur = Instance.new("BlurEffect")
    Blur.Name = "CrystalBlurEffect"
    Blur.Size = 20
    Blur.Parent = game:GetService("Lighting")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -160)
    MainFrame.Size = UDim2.new(0, 450, 0, 310)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 6)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(120, 60, 200)
    UIStroke.Thickness = 2
    UIStroke.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TopBar.Position = UDim2.new(0, 0, 0, 0)
    TopBar.Size = UDim2.new(1, 0, 0, 50)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 6)
    TopCorner.Parent = TopBar
    
    local TopHider = Instance.new("Frame")
    TopHider.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TopHider.Position = UDim2.new(0, 0, 1, -10)
    TopHider.Size = UDim2.new(1, 0, 0, 10)
    TopHider.BorderSizePixel = 0
    TopHider.Parent = TopBar

    local TopStroke = Instance.new("Frame")
    TopStroke.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
    TopStroke.Position = UDim2.new(0, 0, 1, 0)
    TopStroke.Size = UDim2.new(1, 0, 0, 2)
    TopStroke.BorderSizePixel = 0
    TopStroke.Parent = TopBar

    local Logo = Instance.new("ImageLabel")
    Logo.BackgroundTransparency = 1
    Logo.Position = UDim2.new(0, 15, 0, 10)
    Logo.Size = UDim2.new(0, 100, 0, 30)
    Logo.ScaleType = Enum.ScaleType.Fit
    Logo.Parent = TopBar
    task.spawn(function()
        pcall(function() Logo.Image = getcustomasset("CrystalHub/logo.png") end)
        if Logo.Image == "" then
            pcall(function() Logo.Image = getcustomasset("CrystalHub/retouch_2026062920173928.png") end)
        end
        if Logo.Image == "" then
            local Fallback = Instance.new("TextLabel")
            Fallback.BackgroundTransparency = 1
            Fallback.Position = UDim2.new(0, 15, 0, 10)
            Fallback.Size = UDim2.new(0, 120, 0, 30)
            Fallback.Font = Enum.Font.SourceSansBold
            Fallback.Text = "CrystalHub"
            Fallback.TextColor3 = Color3.fromRGB(255, 255, 255)
            Fallback.TextSize = 16
            Fallback.TextXAlignment = Enum.TextXAlignment.Left
            Fallback.Parent = TopBar
        end
    end)

    local ProfileImage = Instance.new("ImageLabel")
    ProfileImage.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    ProfileImage.Position = UDim2.new(1, -45, 0, 7)
    ProfileImage.Size = UDim2.new(0, 36, 0, 36)
    ProfileImage.Parent = TopBar
    
    local userId = 1
    pcall(function() userId = lp.UserId or 1 end)
    ProfileImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(userId) .. "&w=150&h=150"
    
    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(1, 0)
    ProfileCorner.Parent = ProfileImage

    local ProfileName = Instance.new("TextLabel")
    ProfileName.BackgroundTransparency = 1
    ProfileName.Position = UDim2.new(1, -255, 0, 15)
    ProfileName.Size = UDim2.new(0, 200, 0, 20)
    ProfileName.Font = Enum.Font.SourceSans
    
    local dName = "User"
    pcall(function() dName = lp.DisplayName or lp.Name or "User" end)
    ProfileName.Text = "Welcome, " .. tostring(dName)
    ProfileName.TextColor3 = Color3.fromRGB(200, 200, 200)
    ProfileName.TextSize = 13
    ProfileName.TextXAlignment = Enum.TextXAlignment.Right
    ProfileName.Parent = TopBar

    local GameName = Instance.new("TextLabel")
    GameName.BackgroundTransparency = 1
    GameName.Position = UDim2.new(0, 0, 0, 70)
    GameName.Size = UDim2.new(1, 0, 0, 20)
    GameName.Font = Enum.Font.SourceSansBold
    GameName.Text = "Loading Game..."
    GameName.TextColor3 = Color3.fromRGB(180, 180, 180)
    GameName.TextSize = 14
    GameName.Parent = MainFrame
    
    task.spawn(function()
        local success, info = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
        end)
        if success and info and info.Name then
            GameName.Text = "Injecting: " .. info.Name
        else
            GameName.Text = "Injecting: Unknown"
        end
    end)

    local Subtitle = Instance.new("TextLabel")
    Subtitle.BackgroundTransparency = 1
    Subtitle.Position = UDim2.new(0, 0, 0, 95)
    Subtitle.Size = UDim2.new(1, 0, 0, 20)
    Subtitle.Font = Enum.Font.SourceSans
    Subtitle.Text = "Please enter your access key to continue"
    Subtitle.TextColor3 = Color3.fromRGB(130, 130, 130)
    Subtitle.TextSize = 13
    Subtitle.Parent = MainFrame

    local KeyInput = Instance.new("TextBox")
    KeyInput.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    KeyInput.Position = UDim2.new(0, 65, 0, 135)
    KeyInput.Size = UDim2.new(0, 320, 0, 40)
    KeyInput.Font = Enum.Font.SourceSans
    KeyInput.PlaceholderText = "Paste key here..."
    KeyInput.Text = ""
    KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    KeyInput.TextSize = 14
    KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    KeyInput.ClearTextOnFocus = false
    KeyInput.Parent = MainFrame
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = KeyInput
    
    local InputStroke = Instance.new("UIStroke")
    InputStroke.Color = Color3.fromRGB(120, 60, 200)
    InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    InputStroke.Parent = KeyInput

    local VerifyBtn = Instance.new("TextButton")
    VerifyBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
    VerifyBtn.Position = UDim2.new(0, 65, 0, 190)
    VerifyBtn.Size = UDim2.new(0, 320, 0, 40)
    VerifyBtn.AutoButtonColor = false
    VerifyBtn.Font = Enum.Font.SourceSansBold
    VerifyBtn.Text = "Verify & Load"
    VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    VerifyBtn.TextSize = 14
    VerifyBtn.Parent = MainFrame
    
    local VerifyCorner = Instance.new("UICorner")
    VerifyCorner.CornerRadius = UDim.new(0, 6)
    VerifyCorner.Parent = VerifyBtn

    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    GetKeyBtn.Position = UDim2.new(0, 65, 0, 240)
    GetKeyBtn.Size = UDim2.new(0, 320, 0, 40)
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.Font = Enum.Font.SourceSansBold
    GetKeyBtn.Text = "Get Key"
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyBtn.TextSize = 14
    GetKeyBtn.Parent = MainFrame
    
    local GetKeyCorner = Instance.new("UICorner")
    GetKeyCorner.CornerRadius = UDim.new(0, 6)
    GetKeyCorner.Parent = GetKeyBtn

    local TS = game:GetService("TweenService")
    local function AddBtnAnim(btn, defaultColor, hoverColor, clickColor)
        btn.MouseEnter:Connect(function() pcall(function() TS:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play() end) end)
        btn.MouseLeave:Connect(function() pcall(function() TS:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}):Play() end) end)
        btn.MouseButton1Down:Connect(function() pcall(function() TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = clickColor}):Play() end) end)
        btn.MouseButton1Up:Connect(function() pcall(function() TS:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = hoverColor}):Play() end) end)
    end
    
    AddBtnAnim(VerifyBtn, Color3.fromRGB(120, 60, 200), Color3.fromRGB(140, 70, 220), Color3.fromRGB(100, 50, 180))
    AddBtnAnim(GetKeyBtn, Color3.fromRGB(45, 45, 50), Color3.fromRGB(55, 55, 60), Color3.fromRGB(35, 35, 40))

    VerifyBtn.MouseButton1Click:Connect(function()
        local key = KeyInput.Text
        if key == "" then return end
        VerifyBtn.Text = "Verifying..."
        local ok, err = VerifyKeyRequest(key)
        if ok then
            SaveKey(key)
            ScreenGui:Destroy()
            Blur:Destroy()
            isVerified = true
        else
            VerifyBtn.Text = err or "Invalid Key"
            pcall(function() TS:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play() end)
            task.delay(2, function()
                VerifyBtn.Text = "Verify & Load"
                pcall(function() TS:Create(VerifyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(120, 60, 200)}):Play() end)
            end)
        end
    end)
    
    GetKeyBtn.MouseButton1Click:Connect(function()
        local link = "https://discord.gg/qkCRXBeEpB"
        local success = pcall(function()
            if setclipboard then
                setclipboard(link)
            elseif toclipboard then
                toclipboard(link)
            else
                error("Clipboard ei tuettu")
            end
        end)
        
        if success then
            GetKeyBtn.Text = "Link Copied To Clipboard"
            pcall(function() TS:Create(GetKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 200, 50)}):Play() end)
        else
            GetKeyBtn.Text = "No Clipboard Support!"
            pcall(function() TS:Create(GetKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play() end)
            KeyInput.Text = link
        end
        
        task.delay(5, function()
            GetKeyBtn.Text = "Get Key"
            pcall(function() TS:Create(GetKeyBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}):Play() end)
        end)
    end)

    while not isVerified do task.wait(0.5) end
end

if keyExpiryTime then
    print("[CrystalHub] Key expiry timer started! Expires at timestamp: " .. tostring(keyExpiryTime))
    task.spawn(function()
        while true do
            local currentMs = workspace:GetServerTimeNow() * 1000
            if currentMs >= keyExpiryTime then
                print("[CrystalHub] Key expired! Kicking player...")
                pcall(function() game.Players.LocalPlayer:Kick("CrystalHub: Your key has expired. Please generate a new one!") end)
                break
            end
            task.wait(2)
        end
    end)
else
    print("[CrystalHub] No expiry time set for this key. (Lifetime or Old Key)")
end


local gameName = "CrystalHub"
local isRivals = false
local isSellLemons = false
local isAnimalHospital = false
local isNewGame = false
local isKickLuckyBlock = false
local isMM2 = false
local isUniversal = false

if _G.CrystalHub_Unloaded ~= nil and _G.CrystalHub_Unloaded == false then
    _G.CrystalHub_Unloaded = true
    task.wait(0.5)
end
_G.CrystalHub_Unloaded = false

local Features = {}

local function CleanFeature(f)
    if not f then return end
    if f.cleanup then pcall(f.cleanup) end
    if f.connections then
        for _, c in pairs(f.connections) do pcall(function() c:Disconnect() end) end
        table.clear(f.connections)
    end
    if f.instances then
        for _, i in pairs(f.instances) do pcall(function() i:Destroy() end) end
        table.clear(f.instances)
    end
    if f.cache then
        for _, v in pairs(f.cache) do
            if type(v) == "table" then
                pcall(function() if v.hl then v.hl.Adornee = nil v.hl:Destroy() end end)
                pcall(function() if v.bb then v.bb.Adornee = nil v.bb:Destroy() end end)
                for _, inst in pairs(v) do
                    pcall(function() if type(inst) == "userdata" or typeof(inst) == "Instance" then inst:Destroy() end end)
                end
            elseif typeof(v) == "Instance" or type(v) == "userdata" then
                pcall(function() v.Adornee = nil end)
                pcall(function() v:Destroy() end)
            end
        end
        table.clear(f.cache)
    end
end

local function StopFeature(name)
    local f = Features[name]
    if f then
        f.active = false
        if f.thread then pcall(task.cancel, f.thread) end
        CleanFeature(f)
        Features[name] = nil
    end
end

local function StartFeature(name, func)
    StopFeature(name)
    local f = { active = true, connections = {}, instances = {}, cache = {} }
    Features[name] = f
    f.thread = task.spawn(function()
        local success, err = pcall(func, f)
        if not success then warn("Feature " .. name .. " failed: " .. tostring(err)) end
        if Features[name] == f then
            f.active = false
            CleanFeature(f)
            Features[name] = nil
        end
    end)
end

local pId = game.PlaceId
local gId = game.GameId

if pId == 79268393072444 or gId == 7395930870 then
    isSellLemons = true
    gameName = "Sell Lemons"
elseif pId == 142823246 or pId == 142823291 or gId == 536102540 then
    isMM2 = true
    gameName = "Murder Mystery 2"
elseif pId == 17625359962 or gId == 6035872082 then
    isRivals = true
    gameName = "Rivals"
else
    isUniversal = true
    gameName = "Universal"
    task.spawn(function()
        local gui = Instance.new("ScreenGui")
        gui.Name = "CrystalHubUniversalNotice"
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 320, 0, 110)
        frame.AnchorPoint = Vector2.new(1, 1)
        frame.Position = UDim2.new(1, -20, 1, -20)
        frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        frame.BorderSizePixel = 0
        frame.BackgroundTransparency = 1
        frame.Parent = gui
        
        local uicorner = Instance.new("UICorner")
        uicorner.CornerRadius = UDim.new(0, 8)
        uicorner.Parent = frame
        
        local uistroke = Instance.new("UIStroke")
        uistroke.Color = Color3.fromRGB(130, 90, 255)
        uistroke.Thickness = 2
        uistroke.Transparency = 1
        uistroke.Parent = frame
        
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.Position = UDim2.new(0, 0, 0, 10)
        title.BackgroundTransparency = 1
        title.Font = Enum.Font.GothamBold
        title.Text = "CrystalHub Universal"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 20
        title.TextTransparency = 1
        title.Parent = frame
        
        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -40, 1, -50)
        desc.Position = UDim2.new(0, 20, 0, 40)
        desc.BackgroundTransparency = 1
        desc.Font = Enum.Font.Gotham
        desc.Text = "We don't support this game yet, so here is a Universal script that fits all games!"
        desc.TextColor3 = Color3.fromRGB(200, 200, 200)
        desc.TextSize = 14
        desc.TextWrapped = true
        desc.TextTransparency = 1
        desc.Parent = frame
        
        local success = pcall(function() gui.Parent = game:GetService("CoreGui") end)
        if not success then gui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end
        
        local ts = game:GetService("TweenService")
        local ti = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        
        ts:Create(frame, ti, {BackgroundTransparency = 0.05}):Play()
        ts:Create(uistroke, ti, {Transparency = 0}):Play()
        ts:Create(title, ti, {TextTransparency = 0}):Play()
        ts:Create(desc, ti, {TextTransparency = 0}):Play()
        
        task.wait(6)
        
        local to = TweenInfo.new(1, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        ts:Create(frame, to, {BackgroundTransparency = 1}):Play()
        ts:Create(uistroke, to, {Transparency = 1}):Play()
        ts:Create(title, to, {TextTransparency = 1}):Play()
        ts:Create(desc, to, {TextTransparency = 1}):Play()
        
        task.wait(1)
        gui:Destroy()
    end)
end


local function Tween(obj, props, time, style, dir)
    time = time or 0.3
    style = style or Enum.EasingStyle.Cubic
    dir = dir or Enum.EasingDirection.Out
    local tw = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    tw:Play()
    return tw
end

local splashGui = Instance.new("ScreenGui")
splashGui.Name = "CrystalSplash"
splashGui.DisplayOrder = 999999
splashGui.IgnoreGuiInset = true
pcall(function() splashGui.Parent = gethui and gethui() or CoreGui end)
if not splashGui.Parent then splashGui.Parent = lp:WaitForChild("PlayerGui") end

local blur = Instance.new("BlurEffect", Lighting)
blur.Size = 0
Tween(blur, {Size = 25}, 1)

local splashBg = Instance.new("Frame", splashGui)
splashBg.Size = UDim2.new(1, 0, 1, 0)
splashBg.BackgroundTransparency = 1

local splashLogo = Instance.new("ImageLabel", splashBg)
splashLogo.Size = UDim2.new(0, 450, 0, 180)
splashLogo.AnchorPoint = Vector2.new(0.5, 0.5)
splashLogo.Position = UDim2.new(0.5, 0, 0.45, 0)
splashLogo.BackgroundTransparency = 1
splashLogo.ImageTransparency = 1
splashLogo.ScaleType = Enum.ScaleType.Fit

task.spawn(function()
    local ok, img = pcall(function() return getcustomasset("CrystalHub/logo.png") end)
    if not ok or type(img) ~= "string" or img == "" then
        ok, img = pcall(function() return getcustomasset("CrystalHub/retouch_2026062920173928.png") end)
    end
    if ok and type(img) == "string" and img ~= "" then
        splashLogo.Image = img
    end
end)

local loadingText = Instance.new("TextLabel", splashBg)
loadingText.Size = UDim2.new(0, 300, 0, 30)
loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
loadingText.Position = UDim2.new(0.5, 0, 0.55, 0)
loadingText.BackgroundTransparency = 1
loadingText.Text = "Loading Assets..."
loadingText.TextColor3 = UI_COLOR
loadingText.Font = Enum.Font.GothamMedium
loadingText.TextSize = 16
loadingText.TextTransparency = 1

Tween(splashLogo, {ImageTransparency = 0, Size = UDim2.new(0, 500, 0, 200)}, 1.5, Enum.EasingStyle.Quint)
task.wait(0.5)
Tween(loadingText, {TextTransparency = 0}, 0.5)
task.wait(1)
loadingText.Text = "Injecting to " .. gameName .. "..."
task.wait(1.5)

Tween(splashLogo, {ImageTransparency = 1, Size = UDim2.new(0, 550, 0, 220)}, 0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
Tween(loadingText, {TextTransparency = 1}, 0.5)
Tween(blur, {Size = 0}, 1)
task.wait(1)
splashGui:Destroy()
pcall(function() blur:Destroy() end)

local CrystalUI = {}
CrystalUI.ToggleKey = Enum.KeyCode.RightShift

function CrystalUI.MakeWindow(title)
    local sg = Instance.new("ScreenGui")
    sg.Name = "CrystalUltraModern"
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 100000
    pcall(function() sg.Parent = gethui and gethui() or CoreGui end)
    if not sg.Parent then sg.Parent = lp:WaitForChild("PlayerGui") end
    
    _G.CrystalHubGui = sg
    
    _G.CrystalHub_Unloaded = false
    local DropShadow = Instance.new("ImageLabel", sg)
    DropShadow.Size = UDim2.new(0, 650, 0, 450)
    DropShadow.Position = UDim2.new(0.5, -325, 0.5, -225)
    DropShadow.BackgroundTransparency = 1
    DropShadow.Image = "rbxassetid://6015897843"
    DropShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    DropShadow.ImageTransparency = 1
    DropShadow.ScaleType = Enum.ScaleType.Slice
    DropShadow.SliceCenter = Rect.new(47, 47, 450, 450)
    
    local Main = Instance.new("CanvasGroup", DropShadow)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Size = UDim2.new(1, -50, 1, -50)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.BackgroundColor3 = BG_COLOR
    Main.BackgroundTransparency = 0.1
    Main.GroupTransparency = 0
    Main.BorderSizePixel = 0
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    Tween(DropShadow, {ImageTransparency = 0.2}, 0.5)
    
    local stroke = Instance.new("UIStroke", Main)
    stroke.Color = UI_COLOR
    stroke.Thickness = 1
    stroke.Transparency = 0.6
    
    local DragBox = Instance.new("TextButton", Main)
    DragBox.Size = UDim2.new(1, 0, 1, 0)
    DragBox.BackgroundTransparency = 1
    DragBox.Text = ""
    DragBox.ZIndex = 0
    
    local dragging, dragInput, dragStart, startPos
    DragBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = DropShadow.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    DragBox.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            DropShadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = ELEM_COLOR
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    
    local Sep = Instance.new("Frame", Sidebar)
    Sep.Size = UDim2.new(0, 1, 1, 0)
    Sep.Position = UDim2.new(1, 0, 0, 0)
    Sep.BackgroundColor3 = UI_COLOR
    Sep.BackgroundTransparency = 0.8
    Sep.BorderSizePixel = 0
    
    local Logo = Instance.new("ImageLabel", Sidebar)
    Logo.Size = UDim2.new(0, 120, 0, 45)
    Logo.Position = UDim2.new(0.5, -60, 0, 15)
    Logo.BackgroundTransparency = 1
    Logo.ScaleType = Enum.ScaleType.Fit
    task.spawn(function()
        local ok, img = pcall(function() return getcustomasset("CrystalHub/logo.png") end)
        if not ok then ok, img = pcall(function() return getcustomasset("CrystalHub/retouch_2026062920173928.png") end) end
        if ok and type(img) == "string" then Logo.Image = img end
    end)
    
    local TabCont = Instance.new("ScrollingFrame", Sidebar)
    TabCont.Size = UDim2.new(1, 0, 1, -110)
    TabCont.Position = UDim2.new(0, 0, 0, 70)
    TabCont.BackgroundTransparency = 1
    TabCont.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabCont)
    TabList.Padding = UDim.new(0, 2)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
        local card = Instance.new("Frame", Sidebar)
    card.Size = UDim2.new(1, -20, 0, 64)
    card.Position = UDim2.new(0, 10, 1, -84)
    card.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", card)
    stroke.Color = UI_COLOR
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    
    local av = Instance.new("ImageLabel", card)
    av.Size = UDim2.new(0, 32, 0, 32)
    av.Position = UDim2.new(0, 10, 0.5, -16)
    av.BackgroundTransparency = 1
    av.Image = "rbxthumb://type=AvatarHeadShot&id=" .. lp.UserId .. "&w=150&h=150"
    Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
    
    local nm = Instance.new("TextLabel", card)
    nm.Size = UDim2.new(1, -55, 0, 16)
    nm.Position = UDim2.new(0, 50, 0, 10)
    nm.BackgroundTransparency = 1
    nm.Text = lp.DisplayName
    nm.TextColor3 = TEXT_COLOR
    nm.Font = Enum.Font.GothamBold
    nm.TextSize = 12
    nm.TextXAlignment = Enum.TextXAlignment.Left
    
    local timeLbl = Instance.new("TextLabel", card)
    timeLbl.Size = UDim2.new(1, -55, 0, 14)
    timeLbl.Position = UDim2.new(0, 50, 0, 26)
    timeLbl.BackgroundTransparency = 1
    timeLbl.Text = "00:00:00"
    timeLbl.TextColor3 = UI_COLOR
    timeLbl.Font = Enum.Font.Code
    timeLbl.TextSize = 11
    timeLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local t0 = os.time()
    task.spawn(function()
        while not _G.CrystalHub_Unloaded do
            local e = os.difftime(os.time(), t0)
            local h = math.floor(e / 3600)
            local m = math.floor((e % 3600) / 60)
            local s = math.floor(e % 60)
            timeLbl.Text = string.format("%02d:%02d:%02d", h, m, s)
            task.wait(1)
        end
    end)

    local injectedLbl = Instance.new("TextLabel", Sidebar)
    injectedLbl.Size = UDim2.new(1, 0, 0, 15)
    injectedLbl.Position = UDim2.new(0, 0, 1, -18)
    injectedLbl.BackgroundTransparency = 1
    injectedLbl.Text = "Injected: " .. gameName
    injectedLbl.TextColor3 = Color3.fromRGB(100, 220, 120)
    injectedLbl.Font = Enum.Font.Code
    injectedLbl.TextSize = 10
    injectedLbl.TextXAlignment = Enum.TextXAlignment.Center
    
    local PageCont = Instance.new("Frame", Main)
    PageCont.Size = UDim2.new(1, -150, 1, 0)
    PageCont.Position = UDim2.new(0, 150, 0, 0)
    PageCont.BackgroundTransparency = 1
    
    local UI_Visible = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if _G.CrystalHub_Unloaded then return end
        if not gpe and input.KeyCode == CrystalUI.ToggleKey then
            UI_Visible = not UI_Visible
            if UI_Visible then
                sg.Enabled = true
                Main.Size = UDim2.new(0.95, -50, 0.95, -50)
                DropShadow.Position = UDim2.new(DropShadow.Position.X.Scale, DropShadow.Position.X.Offset, DropShadow.Position.Y.Scale, DropShadow.Position.Y.Offset + 25)
                Tween(DropShadow, {Position = UDim2.new(DropShadow.Position.X.Scale, DropShadow.Position.X.Offset, DropShadow.Position.Y.Scale, DropShadow.Position.Y.Offset - 25), ImageTransparency = 0.2}, 0.5, Enum.EasingStyle.Quint)
                Tween(Main, {Size = UDim2.new(1, -50, 1, -50), GroupTransparency = 0}, 0.5, Enum.EasingStyle.Quint)
                Tween(stroke, {Transparency = 0.6}, 0.5, Enum.EasingStyle.Quint)
            else
                Tween(DropShadow, {Position = UDim2.new(DropShadow.Position.X.Scale, DropShadow.Position.X.Offset, DropShadow.Position.Y.Scale, DropShadow.Position.Y.Offset + 15), ImageTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                Tween(Main, {Size = UDim2.new(0.95, -50, 0.95, -50), GroupTransparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                Tween(stroke, {Transparency = 1}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                
                task.delay(0.3, function()
                    if not UI_Visible then sg.Enabled = false end
                end)
            end
        end
    end)
    
    local winObj = {Tabs = {}, Pages = {}}
    
    function winObj:MakeTab(name, iconId)
        local TabBtn = Instance.new("TextButton", TabCont)
        TabBtn.Size = UDim2.new(1, -16, 0, 30)
        TabBtn.BackgroundColor3 = UI_COLOR
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.AutoButtonColor = false
        TabBtn.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        if iconId then
            local Icon = Instance.new("ImageLabel", TabBtn)
            Icon.Size = UDim2.new(0, 16, 0, 16)
            Icon.Position = UDim2.new(0, 10, 0.5, -8)
            Icon.BackgroundTransparency = 1
            Icon.Image = iconId
            Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
        end
        
        local Page = Instance.new("ScrollingFrame", PageCont)
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = UI_COLOR
        Page.Visible = false
        Page.CanvasSize = UDim2.new(0, 0, 0, 0)
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)
        local UIPadding = Instance.new("UIPadding", Page)
        UIPadding.PaddingTop = UDim.new(0, 15)
        UIPadding.PaddingLeft = UDim.new(0, 15)
        UIPadding.PaddingRight = UDim.new(0, 15)
        UIPadding.PaddingBottom = UDim.new(0, 15)
        
        table.insert(winObj.Tabs, TabBtn)
        table.insert(winObj.Pages, Page)
        
        TabBtn.MouseEnter:Connect(function()
            if not Page.Visible then
                Tween(TabBtn, {TextColor3 = Color3.fromRGB(200, 200, 200)}, 0.2)
                if TabBtn:FindFirstChildOfClass("ImageLabel") then Tween(TabBtn:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = Color3.fromRGB(200, 200, 200)}, 0.2) end
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if not Page.Visible then
                Tween(TabBtn, {TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
                if TabBtn:FindFirstChildOfClass("ImageLabel") then Tween(TabBtn:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = Color3.fromRGB(150, 150, 150)}, 0.2) end
            end
        end)
        
        local function selectTab()
            for _, t in pairs(winObj.Tabs) do
                Tween(t, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150, 150, 150)}, 0.2)
                if t:FindFirstChildOfClass("ImageLabel") then Tween(t:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = Color3.fromRGB(150, 150, 150)}, 0.2) end
            end
            for _, p in pairs(winObj.Pages) do
                p.Visible = false
            end
            
            Tween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = TEXT_COLOR}, 0.2)
            if TabBtn:FindFirstChildOfClass("ImageLabel") then Tween(TabBtn:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = TEXT_COLOR}, 0.2) end
            
            Page.Position = UDim2.new(0, -20, 0, 0)
            Page.Visible = true
            Tween(Page, {Position = UDim2.new(0, 0, 0, 0)}, 0.2)
        end
        
        TabBtn.MouseButton1Click:Connect(selectTab)
        if #winObj.Tabs == 1 then
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.TextColor3 = TEXT_COLOR
            if TabBtn:FindFirstChildOfClass("ImageLabel") then TabBtn:FindFirstChildOfClass("ImageLabel").ImageColor3 = TEXT_COLOR end
            Page.Visible = true
            Page.Position = UDim2.new(0,0,0,0)
        end
        
        local tabObj = {}
        
        function tabObj:AddToggle(text, default, callback)
            local TFrame = Instance.new("Frame", Page)
            TFrame.Size = UDim2.new(1, 0, 0, 40)
            TFrame.BackgroundColor3 = ELEM_COLOR
            Instance.new("UICorner", TFrame).CornerRadius = UDim.new(0, 6)
            
            local Lbl = Instance.new("TextLabel", TFrame)
            Lbl.Size = UDim2.new(1, -60, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = TEXT_COLOR
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local Btn = Instance.new("TextButton", TFrame)
            Btn.Size = UDim2.new(0, 36, 0, 18)
            Btn.Position = UDim2.new(1, -50, 0.5, -9)
            Btn.BackgroundColor3 = default and UI_COLOR or Color3.fromRGB(40, 40, 50)
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(1, 0)
            
            local Circ = Instance.new("Frame", Btn)
            Circ.Size = UDim2.new(0, 14, 0, 14)
            Circ.Position = default and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)
            Circ.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Circ).CornerRadius = UDim.new(1, 0)
            
            local state = default
            if state then callback(state) end
            
            local function setState(v)
                state = (v == true)
                Tween(Btn, {BackgroundColor3 = state and UI_COLOR or Color3.fromRGB(40, 40, 50)}, 0.2)
                Tween(Circ, {Position = state and UDim2.new(1, -16, 0, 2) or UDim2.new(0, 2, 0, 2)}, 0.25, Enum.EasingStyle.Back)
                callback(state)
            end
            
            Btn.MouseButton1Click:Connect(function()
                setState(not state)
            end)
            
            return {Set = setState}
        end
        
        function tabObj:AddSlider(text, min, max, default, callback)
            local SFrame = Instance.new("Frame", Page)
            SFrame.Size = UDim2.new(1, 0, 0, 50)
            SFrame.BackgroundColor3 = ELEM_COLOR
            Instance.new("UICorner", SFrame).CornerRadius = UDim.new(0, 6)
            
            local Lbl = Instance.new("TextLabel", SFrame)
            Lbl.Size = UDim2.new(1, -30, 0, 20)
            Lbl.Position = UDim2.new(0, 15, 0, 5)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text .. " : <font color='#825AFF'><b>" .. default .. "</b></font>"
            Lbl.TextColor3 = TEXT_COLOR
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 13
            Lbl.RichText = true
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local BgBar = Instance.new("Frame", SFrame)
            BgBar.Size = UDim2.new(1, -30, 0, 4)
            BgBar.Position = UDim2.new(0, 15, 0, 35)
            BgBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            Instance.new("UICorner", BgBar).CornerRadius = UDim.new(1, 0)
            
            local Fill = Instance.new("Frame", BgBar)
            Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
            Fill.BackgroundColor3 = UI_COLOR
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            
            local Knob = Instance.new("Frame", Fill)
            Knob.Size = UDim2.new(0, 10, 0, 10)
            Knob.Position = UDim2.new(1, -5, 0.5, -5)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)
            
            local Btn = Instance.new("TextButton", BgBar)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            
            local dragging = false
            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            
            local function setSlider(val)
                val = tonumber(val) or default
                val = math.clamp(val, min, max)
                local pct = (val - min) / (max - min)
                Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1, Enum.EasingStyle.Linear)
                Lbl.Text = text .. " : <font color='#825AFF'><b>" .. val .. "</b></font>"
                callback(val)
            end
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((input.Position.X - BgBar.AbsolutePosition.X) / BgBar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max - min) * pct)
                    setSlider(val)
                end
            end)
            callback(default)
            return {Set = setSlider}
        end
        
        function tabObj:AddDropdown(text, options, default, callback)
            local DFrame = Instance.new("Frame", Page)
            DFrame.Size = UDim2.new(1, 0, 0, 40)
            DFrame.BackgroundColor3 = ELEM_COLOR
            Instance.new("UICorner", DFrame).CornerRadius = UDim.new(0, 6)
            DFrame.ClipsDescendants = true
            
            local Lbl = Instance.new("TextLabel", DFrame)
            Lbl.Size = UDim2.new(1, -60, 0, 40)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text .. " : <font color='#825AFF'><b>" .. default .. "</b></font>"
            Lbl.TextColor3 = TEXT_COLOR
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 13
            Lbl.RichText = true
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local Icon = Instance.new("TextLabel", DFrame)
            Icon.Size = UDim2.new(0, 20, 0, 40)
            Icon.Position = UDim2.new(1, -30, 0, 0)
            Icon.BackgroundTransparency = 1
            Icon.Text = "+"
            Icon.TextColor3 = Color3.fromRGB(150, 150, 150)
            Icon.Font = Enum.Font.GothamBold
            Icon.TextSize = 16
            
            local Btn = Instance.new("TextButton", DFrame)
            Btn.Size = UDim2.new(1, 0, 0, 40)
            Btn.BackgroundTransparency = 1
            Btn.Text = ""
            
            local open = false
            local optionButtons = {}
            local currentOptions = options
            
            Btn.MouseButton1Click:Connect(function()
                open = not open
                Tween(DFrame, {Size = UDim2.new(1, 0, 0, open and (40 + #currentOptions * 30 + 5) or 40)}, 0.3, Enum.EasingStyle.Quint)
                Tween(Icon, {Rotation = open and 45 or 0}, 0.3)
            end)
            
            local function populate(opts)
                currentOptions = opts
                for _, b in ipairs(optionButtons) do b:Destroy() end
                table.clear(optionButtons)
                
                local yOff = 40
                for _, opt in ipairs(opts) do
                    local obtn = Instance.new("TextButton", DFrame)
                    obtn.Size = UDim2.new(1, -20, 0, 26)
                    obtn.Position = UDim2.new(0, 10, 0, yOff)
                    obtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                    obtn.BackgroundTransparency = 1
                    obtn.Text = opt
                    obtn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    obtn.Font = Enum.Font.Gotham
                    obtn.TextSize = 12
                    obtn.TextXAlignment = Enum.TextXAlignment.Left
                    Instance.new("UICorner", obtn).CornerRadius = UDim.new(0, 4)
                    
                    obtn.MouseEnter:Connect(function() Tween(obtn, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255,255,255)}, 0.2) end)
                    obtn.MouseLeave:Connect(function() Tween(obtn, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180,180,180)}, 0.2) end)
                    
                    obtn.MouseButton1Click:Connect(function()
                        Lbl.Text = text .. " : <font color='#825AFF'><b>" .. opt .. "</b></font>"
                        open = false
                        Tween(DFrame, {Size = UDim2.new(1, 0, 0, 40)}, 0.3, Enum.EasingStyle.Quint)
                        Tween(Icon, {Rotation = 0}, 0.3)
                        callback(opt)
                    end)
                    table.insert(optionButtons, obtn)
                    yOff = yOff + 30
                end
                if open then
                    Tween(DFrame, {Size = UDim2.new(1, 0, 0, 40 + #opts * 30 + 5)}, 0.3, Enum.EasingStyle.Quint)
                end
            end
            
            populate(options)
            callback(default)
            
            return {
                Refresh = function(self, newOpts) populate(newOpts) end,
                Set = function(self, val)
                    val = val or default
                    Lbl.Text = text .. " : <font color='#825AFF'><b>" .. tostring(val) .. "</b></font>"
                    callback(val)
                end
            }
        end
        
        function tabObj:AddBind(text, default, callback)
            local BFrame = Instance.new("Frame", Page)
            BFrame.Size = UDim2.new(1, 0, 0, 40)
            BFrame.BackgroundColor3 = ELEM_COLOR
            Instance.new("UICorner", BFrame).CornerRadius = UDim.new(0, 6)
            
            local Lbl = Instance.new("TextLabel", BFrame)
            Lbl.Size = UDim2.new(1, -100, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = TEXT_COLOR
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local Btn = Instance.new("TextButton", BFrame)
            Btn.Size = UDim2.new(0, 80, 0, 24)
            Btn.Position = UDim2.new(1, -95, 0.5, -12)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            Btn.Text = default.Name
            Btn.TextColor3 = UI_COLOR
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 12
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
            
            local binding = false
            Btn.MouseButton1Click:Connect(function()
                binding = true
                Btn.Text = "..."
                Tween(Btn, {BackgroundColor3 = UI_COLOR, TextColor3 = Color3.fromRGB(255,255,255)}, 0.2)
            end)
            
            UserInputService.InputBegan:Connect(function(input)
                if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                    binding = false
                    Btn.Text = input.KeyCode.Name
                    Tween(Btn, {BackgroundColor3 = Color3.fromRGB(30, 30, 40), TextColor3 = UI_COLOR}, 0.2)
                    callback(input.KeyCode)
                end
            end)
        end
        
        function tabObj:AddTextBox(text, default, callback)
            local TBoxFrame = Instance.new("Frame", Page)
            TBoxFrame.Size = UDim2.new(1, 0, 0, 40)
            TBoxFrame.BackgroundColor3 = ELEM_COLOR
            Instance.new("UICorner", TBoxFrame).CornerRadius = UDim.new(0, 6)
            
            local Lbl = Instance.new("TextLabel", TBoxFrame)
            Lbl.Size = UDim2.new(1, -160, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = TEXT_COLOR
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local TBox = Instance.new("TextBox", TBoxFrame)
            TBox.Size = UDim2.new(0, 140, 0, 24)
            TBox.Position = UDim2.new(1, -155, 0.5, -12)
            TBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            TBox.Text = default
            TBox.TextColor3 = TEXT_COLOR
            TBox.Font = Enum.Font.Gotham
            TBox.TextSize = 12
            TBox.ClearTextOnFocus = false
            Instance.new("UICorner", TBox).CornerRadius = UDim.new(0, 4)
            local boxStroke = Instance.new("UIStroke", TBox)
            boxStroke.Color = UI_COLOR
            boxStroke.Transparency = 0.5
            boxStroke.Thickness = 1
            
            TBox.FocusLost:Connect(function()
                callback(TBox.Text)
            end)
            callback(default)
        end
        
        function tabObj:AddColorPicker(text, defaultColor, callback)
            local CFrame = Instance.new("Frame", Page)
            CFrame.Size = UDim2.new(1, 0, 0, 40)
            CFrame.BackgroundColor3 = ELEM_COLOR
            Instance.new("UICorner", CFrame).CornerRadius = UDim.new(0, 6)
            CFrame.ClipsDescendants = true
            
            local Lbl = Instance.new("TextLabel", CFrame)
            Lbl.Size = UDim2.new(1, -60, 0, 40)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = TEXT_COLOR
            Lbl.Font = Enum.Font.Gotham
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local HeaderBtn = Instance.new("TextButton", CFrame)
            HeaderBtn.Size = UDim2.new(1, -50, 0, 40)
            HeaderBtn.BackgroundTransparency = 1
            HeaderBtn.Text = ""
            
            local ColorBtn = Instance.new("TextButton", CFrame)
            ColorBtn.Size = UDim2.new(0, 30, 0, 18)
            ColorBtn.Position = UDim2.new(1, -45, 0, 11)
            ColorBtn.BackgroundColor3 = defaultColor
            ColorBtn.Text = ""
            ColorBtn.AutoButtonColor = false
            Instance.new("UICorner", ColorBtn).CornerRadius = UDim.new(0, 4)
            local stroke = Instance.new("UIStroke", ColorBtn)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Thickness = 1
            stroke.Transparency = 0.5
            
            local PickerArea = Instance.new("ImageButton", CFrame)
            PickerArea.Size = UDim2.new(1, -95, 0, 60)
            PickerArea.Position = UDim2.new(0, 15, 0, 45)
            PickerArea.Image = "rbxassetid://1433361550"
            PickerArea.AutoButtonColor = false
            Instance.new("UICorner", PickerArea).CornerRadius = UDim.new(0, 6)
            
            local Cursor = Instance.new("Frame", PickerArea)
            Cursor.Size = UDim2.new(0, 8, 0, 8)
            Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            Cursor.Position = UDim2.new(0, 0, 0.5, 0)
            Cursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Cursor).CornerRadius = UDim.new(1, 0)
            local cstroke = Instance.new("UIStroke", Cursor)
            cstroke.Color = Color3.fromRGB(0, 0, 0)
            cstroke.Thickness = 1
            
            local HexBox = Instance.new("TextBox", CFrame)
            HexBox.Size = UDim2.new(0, 65, 0, 20)
            HexBox.Position = UDim2.new(1, -75, 0, 65)
            HexBox.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            HexBox.Text = "#FFFFFF"
            HexBox.TextColor3 = TEXT_COLOR
            HexBox.Font = Enum.Font.Code
            HexBox.TextSize = 12
            Instance.new("UICorner", HexBox).CornerRadius = UDim.new(0, 4)
            local hexStroke = Instance.new("UIStroke", HexBox)
            hexStroke.Color = Color3.fromRGB(255, 255, 255)
            hexStroke.Transparency = 0.8
            hexStroke.Thickness = 1
            
            local open = false
            local function togglePicker()
                open = not open
                Tween(CFrame, {Size = UDim2.new(1, 0, 0, open and 115 or 40)}, 0.3, Enum.EasingStyle.Quint)
            end
            ColorBtn.MouseButton1Click:Connect(togglePicker)
            HeaderBtn.MouseButton1Click:Connect(togglePicker)
            
            local dragging = false
            local function updateColor(input)
                local pctX = math.clamp((input.Position.X - PickerArea.AbsolutePosition.X) / PickerArea.AbsoluteSize.X, 0, 1)
                local pctY = math.clamp((input.Position.Y - PickerArea.AbsolutePosition.Y) / PickerArea.AbsoluteSize.Y, 0, 1)
                Cursor.Position = UDim2.new(pctX, 0, pctY, 0)
                local newColor = Color3.fromHSV(1 - pctX, 1 - pctY, 1)
                ColorBtn.BackgroundColor3 = newColor
                HexBox.Text = string.format("#%02X%02X%02X", math.round(newColor.R*255), math.round(newColor.G*255), math.round(newColor.B*255))
                callback(newColor)
            end
            
            PickerArea.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    updateColor(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    updateColor(input)
                end
            end)
            
            HexBox.FocusLost:Connect(function()
                local hex = HexBox.Text:gsub("#", "")
                if #hex == 6 then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    if r and g and b then
                        local newColor = Color3.fromRGB(r, g, b)
                        ColorBtn.BackgroundColor3 = newColor
                        callback(newColor)
                        local h, s, v = Color3.toHSV(newColor)
                        Cursor.Position = UDim2.new(1 - h, 0, 1 - s, 0)
                        HexBox.Text = "#" .. string.upper(hex)
                    end
                else
                    HexBox.Text = string.format("#%02X%02X%02X", math.round(ColorBtn.BackgroundColor3.R*255), math.round(ColorBtn.BackgroundColor3.G*255), math.round(ColorBtn.BackgroundColor3.B*255))
                end
            end)
            
            local ih, is, iv = Color3.toHSV(defaultColor)
            Cursor.Position = UDim2.new(1 - ih, 0, 1 - is, 0)
            HexBox.Text = string.format("#%02X%02X%02X", math.round(defaultColor.R*255), math.round(defaultColor.G*255), math.round(defaultColor.B*255))
            callback(defaultColor)
        end
        
        function tabObj:AddDisabledButton(text)
            local BFrame = Instance.new("Frame", Page)
            BFrame.Size = UDim2.new(1, 0, 0, 40)
            BFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Instance.new("UICorner", BFrame).CornerRadius = UDim.new(0, 6)
            
            local Btn = Instance.new("TextButton", BFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(80, 80, 80)
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            Btn.AutoButtonColor = false
        end
        
        function tabObj:AddButton(text, callback)
            local BFrame = Instance.new("Frame", Page)
            BFrame.Size = UDim2.new(1, 0, 0, 40)
            BFrame.BackgroundColor3 = ELEM_COLOR
            Instance.new("UICorner", BFrame).CornerRadius = UDim.new(0, 6)
            
            local Btn = Instance.new("TextButton", BFrame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.TextColor3 = UI_COLOR
            Btn.Font = Enum.Font.GothamBold
            Btn.TextSize = 13
            
            Btn.MouseButton1Click:Connect(function()
                Tween(BFrame, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}, 0.1)
                task.delay(0.1, function() Tween(BFrame, {BackgroundColor3 = Color3.fromRGB(22, 22, 27)}, 0.1) end)
                callback()
            end)
            Btn.MouseEnter:Connect(function() 
                Tween(BFrame, {BackgroundColor3 = Color3.fromRGB(22, 22, 27)}, 0.2)
                Tween(Btn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2) 
            end)
            Btn.MouseLeave:Connect(function() 
                Tween(BFrame, {BackgroundColor3 = ELEM_COLOR}, 0.2)
                Tween(Btn, {TextColor3 = UI_COLOR}, 0.2) 
            end)
        end
        
        return tabObj
    end
    return winObj
end

local ESP
local espOk = false
task.spawn(function()
    local ok, libCode = pcall(function()
        local _r = string.reverse("aul.yrarbil/niam/yrarbil-pse/2retsamenil/moc.tnetnocresubuhtig.war//:sptth")
        return game:HttpGet(_r)
    end)
    if ok and type(libCode) == "string" then
        libCode = libCode:gsub(
            "local isBehindWall = ESP_SETTINGS%.WallCheck and isPlayerBehindWall%(player%)",
            "local distLimit = (camera.CFrame.Position - rootPart.Position).Magnitude < 5000\n            local isBehindWall = ESP_SETTINGS.WallCheck and isPlayerBehindWall(player)"
        )
        libCode = libCode:gsub(
            "local shouldShow = not isBehindWall and ESP_SETTINGS%.Enabled",
            "local shouldShow = not isBehindWall and ESP_SETTINGS.Enabled and distLimit"
        )
        
        local func, err = loadstring(libCode)
        if func then
            local lib = func()
            if type(lib) == "table" then
                ESP      = lib
                espOk    = true
                ESP.Enabled      = false
                ESP.TeamCheck    = true
                ESP.ShowBox      = false
                ESP.ShowName     = false
                ESP.ShowHealth   = false
                ESP.ShowTracer   = false
                ESP.ShowDistance = false
                ESP.ShowSkeletons = false
            end
        end
    end
end)

local Window = CrystalUI.MakeWindow()
local UIEls = {}

local CombatTab, VisualsTab, MovementTab, SpooferTab, FunTab, SettingsTab

if isRivals or isUniversal then
    CombatTab = Window:MakeTab("Combat", "rbxassetid://4483345998")
    VisualsTab = Window:MakeTab("Visuals", "rbxassetid://6034287515")
    MovementTab = Window:MakeTab("Movement", "rbxassetid://109718589733073")
    if isUniversal then
        FunTab = Window:MakeTab("Fun", "rbxassetid://6022668875")
    end
    if isRivals then
        SpooferTab = Window:MakeTab("Spoofer", "rbxassetid://7743868000")
    end
end

local aimbotEnabled = false
local aimAtPart     = "Head"
local aimbotFOV     = 200
_G.OnetapTeamCheck  = true

if isRivals or isUniversal then
        local fovCircle = nil
        
        task.spawn(function()
            pcall(function()
                if Drawing then
                    fovCircle           = Drawing.new("Circle")
                    fovCircle.Visible   = false
                    fovCircle.Thickness = 1
                    fovCircle.Color     = Color3.fromRGB(255, 255, 255)
                    fovCircle.Filled    = false
                end
            end)
        end)

        game:GetService("RunService").RenderStepped:Connect(function()
            if _G.CrystalHub_Unloaded then return end
            pcall(function()
                local mouseLoc = game:GetService("UserInputService"):GetMouseLocation()
                if fovCircle then
                    fovCircle.Visible  = aimbotEnabled
                    fovCircle.Position = mouseLoc
                    fovCircle.Radius   = aimbotFOV
                end
            end)
        end)

local function getClosestTarget()
    local Cam = workspace.CurrentCamera
    local Players = game:GetService("Players")
    local localPlayer = Players.LocalPlayer
    
    local nearestTarget = nil
    local shortestDistance = aimbotFOV
    local mouseLoc = game:GetService("UserInputService"):GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 and player.Character:FindFirstChild(aimAtPart) then
            local isTeammate = false
            if _G.OnetapTeamCheck then
                if localPlayer.Team and player.Team and localPlayer.Team == player.Team then isTeammate = true end
                local myAttr = localPlayer:GetAttribute("Team")
                local theirAttr = player:GetAttribute("Team")
                if myAttr and theirAttr and myAttr == theirAttr then isTeammate = true end
            end
            
            if not isTeammate and not player.Character:FindFirstChildOfClass("ForceField") then
                local targetRoot = player.Character[aimAtPart]
                local pos, vis = Cam:WorldToViewportPoint(targetRoot.Position)
                
                if vis then
                    local distance = (Vector2.new(pos.X, pos.Y) - mouseLoc).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestTarget = player.Character
                    end
                end
            end
        end
    end

    return nearestTarget
end

local function lookAt(targetPos)
    local Cam = workspace.CurrentCamera
    if not targetPos then return end
    
    if mousemoverel then
        local tPos, onScreen = Cam:WorldToViewportPoint(targetPos)
        if onScreen then
            local mouseLoc = game:GetService("UserInputService"):GetMouseLocation()
            local dx = (tPos.X - mouseLoc.X)
            local dy = (tPos.Y - mouseLoc.Y)
            
                        if math.abs(dx) > 0.5 or math.abs(dy) > 0.5 then
                mousemoverel(dx * 0.4, dy * 0.4)
            end
        end
    else
        Cam.CFrame = CFrame.new(Cam.CFrame.Position, targetPos)
    end
end

local aimbotConnection = nil
local function updateAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    
    aimbotConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if _G.CrystalHub_Unloaded then 
            aimbotConnection:Disconnect()
            return 
        end
        if not aimbotEnabled then return end
        
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            return
        end

        local closestTarget = getClosestTarget()
        if closestTarget and closestTarget:FindFirstChild(aimAtPart) then
            local targetRoot = closestTarget[aimAtPart]
            if closestTarget:FindFirstChild("Humanoid") and closestTarget.Humanoid.Health > 0 then
                lookAt(targetRoot.Position)
            end
        end
    end)
end
updateAimbot()

local triggerBotEnabled = false
local autoDodgeKatana = false

local mouse = lp:GetMouse()
local isShooting = false

game:GetService("RunService").RenderStepped:Connect(function()
    if _G.CrystalHub_Unloaded then 
        if isShooting and mouse1release then mouse1release(); isShooting = false end
        return 
    end
    
    if not triggerBotEnabled then 
        if isShooting and mouse1release then mouse1release(); isShooting = false end
        return 
    end
    
    local target = mouse.Target
    local shouldShoot = false
    
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
        local player = game:GetService("Players"):GetPlayerFromCharacter(target.Parent)
        if player and player ~= lp then
            local isTeammate = false
            if _G.OnetapTeamCheck then
                if lp.Team and player.Team and lp.Team == player.Team then isTeammate = true end
                local myAttr = lp:GetAttribute("Team")
                local theirAttr = player:GetAttribute("Team")
                if myAttr and theirAttr and myAttr == theirAttr then isTeammate = true end
            end
            
            if not isTeammate then
                shouldShoot = true
                
                                if autoDodgeKatana then
                    local tool = player.Character:FindFirstChildOfClass("Tool")
                    if tool and string.find(string.lower(tool.Name), "katana") then
                        shouldShoot = false
                    end
                end
            end
        end
    end
    
    if shouldShoot and not isShooting then
        isShooting = true
        if mouse1press then mouse1press() end
    elseif not shouldShoot and isShooting then
        isShooting = false
        if mouse1release then mouse1release() end
    end
end)

UIEls.Aimlock = CombatTab:AddToggle("Aimlock (Right-Click)", false, function(v) 
    aimbotEnabled = v 
    if aimbotEnabled then updateAimbot() end
end)
UIEls.AimPart = CombatTab:AddDropdown("Aim Part", {"Head", "Body"}, "Head", function(v) 
    if v == "Body" then
        aimAtPart = "HumanoidRootPart"
    else
        aimAtPart = "Head"
    end
end)
if isRivals then
    UIEls.AimFOV = CombatTab:AddSlider("Aim FOV", 50, 600, 200, function(v) aimbotFOV = v end)

    UIEls.Triggerbot = CombatTab:AddToggle("Triggerbot", false, function(v) triggerBotEnabled = v end)
    UIEls.DodgeKatana = CombatTab:AddToggle("Auto Dodge Katana (Triggerbot)", false, function(v) autoDodgeKatana = v end)
end

UIEls.ESPBox = VisualsTab:AddToggle("Enable ESP Boxes", false, function(v) if espOk then ESP.Enabled = true; ESP.ShowBox = v end end)
UIEls.ESPName = VisualsTab:AddToggle("Enable ESP Names", false, function(v) if espOk then ESP.ShowName = v end end)
UIEls.ESPHealth = VisualsTab:AddToggle("Enable ESP Health", false, function(v) if espOk then ESP.ShowHealth = v end end)
UIEls.ESPDist = VisualsTab:AddToggle("Enable ESP Distance", false, function(v) if espOk then ESP.ShowDistance = v end end)
UIEls.ESPTracer = VisualsTab:AddToggle("Enable ESP Tracers", false, function(v) if espOk then ESP.ShowTracer = v end end)
VisualsTab:AddColorPicker("ESP Master Color", Color3.fromRGB(255,255,255), function(color)
    if espOk then 
        ESP.Color = color
        ESP.BoxColor = color
        ESP.NameColor = color
        ESP.TeamColor = false
    end
end)
UIEls.ESPTeam = VisualsTab:AddToggle("Team Check (Ignore Teammates)", true, function(v) 
    if espOk then ESP.TeamCheck = v end
    _G.OnetapTeamCheck = v
end)
end


if isRivals or isUniversal then
local walkSpeedEnabled = false
local targetWalkSpeed = 16
local jumpPowerEnabled = false
local targetJumpPower = 50
local infJumpEnabled = false

local wsConnection = nil
local jpConnection = nil

local function updateMovement()
    if wsConnection then wsConnection:Disconnect() wsConnection = nil end
    if jpConnection then jpConnection:Disconnect() jpConnection = nil end
    
    if walkSpeedEnabled then
        wsConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            if _G.CrystalHub_Unloaded then 
                if wsConnection then wsConnection:Disconnect() end 
                return 
            end
            if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character:FindFirstChild("HumanoidRootPart") then
                local humanoid = lp.Character.Humanoid
                local rootPart = lp.Character.HumanoidRootPart
                
                                if humanoid.MoveDirection.Magnitude > 0 then
                                        local speedBoost = math.max(0, targetWalkSpeed - 16)
                    local translation = humanoid.MoveDirection * (speedBoost * deltaTime)
                    rootPart.CFrame = rootPart.CFrame + translation
                end
            end
        end)
    end
    
    if jumpPowerEnabled then
        jpConnection = game:GetService("RunService").Stepped:Connect(function()
            if _G.CrystalHub_Unloaded then 
                if jpConnection then jpConnection:Disconnect() end 
                return 
            end
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid.UseJumpPower = true
                lp.Character.Humanoid.JumpPower = targetJumpPower
            end
        end)
    end
end

local infJumpConnection = nil
infJumpConnection = UserInputService.JumpRequest:Connect(function()
    if _G.CrystalHub_Unloaded then 
        if infJumpConnection then infJumpConnection:Disconnect() end 
        return 
    end
    if infJumpEnabled and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

UIEls.WS = MovementTab:AddToggle("Enable Custom WalkSpeed", false, function(v) 
    walkSpeedEnabled = v 
    updateMovement()
end)
UIEls.WSVal = MovementTab:AddSlider("WalkSpeed Value", 16, 250, 16, function(v) 
    targetWalkSpeed = v 
    if walkSpeedEnabled then updateMovement() end
end)

UIEls.JP = MovementTab:AddToggle("Enable Custom JumpPower", false, function(v) 
    jumpPowerEnabled = v 
    updateMovement()
end)
UIEls.JPVal = MovementTab:AddSlider("JumpPower Value", 50, 300, 50, function(v) 
    targetJumpPower = v 
    if jumpPowerEnabled then updateMovement() end
end)

UIEls.InfJump = MovementTab:AddToggle("Infinite Jump (Fly by Jumping)", false, function(v) infJumpEnabled = v end)
end

if isUniversal then
    local rainbowEnabled = false
    task.spawn(function()
        while task.wait(0.1) do
            if _G.CrystalHub_Unloaded then break end
            if rainbowEnabled and lp.Character then
                local hue = tick() % 5 / 5
                local color = Color3.fromHSV(hue, 1, 1)
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("MeshPart") then
                        pcall(function() part.Color = color end)
                    end
                end
            end
        end
    end)
    FunTab:AddToggle("Rainbow Character (Client)", false, function(v)
        rainbowEnabled = v
    end)

    FunTab:AddSlider("Camera FOV", 20, 120, 70, function(v)
        workspace.CurrentCamera.FieldOfView = v
    end)

    FunTab:AddToggle("BTools (Client)", false, function(v)
        if v then
            local tool1 = Instance.new("HopperBin")
            tool1.Name = "Destroy"
            tool1.BinType = Enum.BinType.Hammer
            tool1.Parent = lp.Backpack
            
            local tool2 = Instance.new("HopperBin")
            tool2.Name = "Clone"
            tool2.BinType = Enum.BinType.Clone
            tool2.Parent = lp.Backpack
        else
            if lp.Backpack:FindFirstChild("Destroy") then
                lp.Backpack.Destroy:Destroy()
            end
            if lp.Backpack:FindFirstChild("Clone") then
                lp.Backpack.Clone:Destroy()
            end
        end
    end)
    
    FunTab:AddSlider("Gravity (Client)", 0, 500, workspace.Gravity, function(v)
        workspace.Gravity = v
    end)
end

if isRivals then

local spoofLevelEnabled = false
local spoofedLevel = 100
local spoofStreakEnabled = false
local spoofedStreak = 50

task.spawn(function()
    while task.wait(0.5) do
        if _G.CrystalHub_Unloaded then break end
        
        if not spoofLevelEnabled and not spoofStreakEnabled then continue end
        
        if spoofLevelEnabled then
            local ls = lp:FindFirstChild("leaderstats")
            if ls and ls:FindFirstChild("Level") then
                ls.Level.Value = spoofedLevel
            end
            
            local cls = lp:FindFirstChild("CustomLeaderstats")
            if cls and cls:FindFirstChild("Level") then
                cls.Level.Value = spoofedLevel
            end
            
            lp:SetAttribute("Level", spoofedLevel)
        end
        
        if spoofStreakEnabled then
            local ls = lp:FindFirstChild("leaderstats")
            if ls and ls:FindFirstChild("Streak") then
                ls.Streak.Value = spoofedStreak
            end
            
            local cls = lp:FindFirstChild("CustomLeaderstats")
            if cls and cls:FindFirstChild("Win Streak") then
                cls["Win Streak"].Value = spoofedStreak
            end
            
            lp:SetAttribute("StatisticDuelsWinStreak", spoofedStreak)
            lp:SetAttribute("Streak", spoofedStreak)
        end
    end
end)

UIEls.SpoofLevel = SpooferTab:AddToggle("Enable Level Spoofer", false, function(v) spoofLevelEnabled = v end)
UIEls.SpoofedLevel = SpooferTab:AddSlider("Spoofed Level", 1, 10000, 100, function(v) spoofedLevel = v end)

UIEls.SpoofStreak = SpooferTab:AddToggle("Enable Streak Spoofer", false, function(v) spoofStreakEnabled = v end)
UIEls.SpoofedStreak = SpooferTab:AddSlider("Spoofed Streak", 0, 1000, 50, function(v) spoofedStreak = v end)
end

if isSellLemons then
    local FarmTab = Window:MakeTab("Auto Farm", "rbxassetid://10734950309")
    local MiscTab = Window:MakeTab("Misc", "rbxassetid://6022668875")
    
    local autoCollectCash = false
    local autoUpgradeStand = false
    local autoUpgradeSpeed = "Fast"
    local autoBuyTycoon = false
    local autoAcceptOffers = false

    local function getTycoon()
        for _, t in pairs(workspace:GetChildren()) do
            if t.Name:match("Tycoon") and t:FindFirstChild("Owner") and t.Owner.Value == lp then
                return t
            end
        end
        return nil
    end

    local function SilentTouch(targetPart)
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not targetPart then return end
        
        if firetouchinterest then
            firetouchinterest(root, targetPart, 0)
            firetouchinterest(root, targetPart, 1)
        end
        
        local oldCF = targetPart.CFrame
        local oldCanCollide = targetPart.CanCollide
        targetPart.CanCollide = false
        targetPart.CFrame = root.CFrame
        
        task.defer(function()
            if targetPart and targetPart.Parent then
                targetPart.CFrame = oldCF
                targetPart.CanCollide = oldCanCollide
            end
        end)
    end

    local cachedCashDrops = {}
    local lastCashDropCacheTime = 0
    task.spawn(function()
        while true do
            task.wait()
            if _G.CrystalHub_Unloaded then break end
            if not autoCollectCash then
                task.wait(0.5)
                continue
            end
            pcall(function()
                local now = os.clock()
                if now - lastCashDropCacheTime > 3 then
                    lastCashDropCacheTime = now
                    local newCache = {}
                    local tOwner = getTycoon()
                    local scanRoot = tOwner or workspace
                    for _, drop in ipairs(scanRoot:GetDescendants()) do
                        if drop:IsA("BasePart") and drop:FindFirstChildWhichIsA("TouchTransmitter") then
                            local lowerName = string.lower(drop.Name)
                            if (string.find(lowerName, "cash") or string.find(lowerName, "money") or string.find(lowerName, "drop") or string.find(lowerName, "collect") or string.find(lowerName, "lemon")) and not string.find(lowerName, "alien investor") then
                                table.insert(newCache, drop)
                            end
                        end
                    end
                    cachedCashDrops = newCache
                end

                for i, drop in ipairs(cachedCashDrops) do
                    if not autoCollectCash then break end
                    if drop and drop.Parent then
                        SilentTouch(drop)
                    end
                    if i % 3 == 0 then task.wait() end
                end
            end)
        end
    end)


    local cachedUpgrades = {}
    local lastUpgradeCacheTime = 0
    task.spawn(function()
        while true do
            if _G.CrystalHub_Unloaded then break end
            if not autoUpgradeStand then 
                task.wait(0.5)
                continue 
            end
            pcall(function()
                local tOwner = getTycoon()
                if not tOwner then 
                    task.wait(0.5)
                    return 
                end

                local now = os.clock()
                if now - lastUpgradeCacheTime > 2 then
                    lastUpgradeCacheTime = now
                    local newCache = {}
                    for _, child in ipairs(tOwner:GetDescendants()) do
                        if child:IsA("RemoteFunction") and child.Name == "Upgrade" then
                            table.insert(newCache, child)
                        end
                    end
                    cachedUpgrades = newCache
                end
                
                if #cachedUpgrades == 0 then
                    task.wait(0.5)
                    return
                end

                for _, child in ipairs(cachedUpgrades) do
                    if not autoUpgradeStand or _G.CrystalHub_Unloaded then break end
                    if child and child.Parent then
                        task.spawn(function()
                            pcall(function() child:InvokeServer(1) end)
                        end)
                        if autoUpgradeSpeed == "Fast" then
                            task.wait()
                        else
                            task.wait(2.0)
                        end
                    end
                end
            end)
        end
    end)

    local cachedPurchases = {}
    local lastPurchaseCacheTime = 0
    task.spawn(function()
        while true do
            if _G.CrystalHub_Unloaded then break end
            if not autoBuyTycoon then 
                task.wait(0.5)
                continue 
            end
            pcall(function()
                local tOwner = getTycoon()
                if not tOwner then 
                    task.wait(0.5)
                    return 
                end

                local now = os.clock()
                if now - lastPurchaseCacheTime > 2 then
                    lastPurchaseCacheTime = now
                    local newCache = {}
                    local purchasesFolder = tOwner:FindFirstChild("Purchases")
                    if purchasesFolder then
                        for _, child in ipairs(purchasesFolder:GetDescendants()) do
                            if child:IsA("RemoteFunction") and child.Name == "Purchase" then
                                table.insert(newCache, child)
                            end
                        end
                    end
                    cachedPurchases = newCache
                end
                
                if #cachedPurchases == 0 then
                    task.wait(0.5)
                    return
                end

                for i, child in ipairs(cachedPurchases) do
                    if not autoBuyTycoon or _G.CrystalHub_Unloaded then break end
                    if child and child.Parent then
                        task.spawn(function()
                            pcall(function() child:InvokeServer() end)
                        end)
                        if i % 2 == 0 then task.wait() end
                    end
                end
            end)
        end
    end)

    task.spawn(function()
        while task.wait(3) do
            if _G.CrystalHub_Unloaded then break end
            if not autoAcceptOffers then continue end
            local tOwner = getTycoon()
            if not tOwner then continue end
            pcall(function()
                local rem = tOwner.Remotes:FindFirstChild("PhoneOffer")
                if rem then rem:FireServer("Accept") end
            end)
        end
    end)

    UIEls.AutoCollect = FarmTab:AddToggle("Auto Collect Cash", false, function(v) autoCollectCash = v end)
    UIEls.AutoUpgradeStand = FarmTab:AddToggle("Auto Upgrade Stand", false, function(v) autoUpgradeStand = v end)
    UIEls.AutoUpgradeSpeed = FarmTab:AddDropdown("Upgrade Speed", {"Fast", "Slow"}, "Fast", function(v) autoUpgradeSpeed = v end)
    UIEls.AutoBuyTycoon = FarmTab:AddToggle("Auto Buy Tycoon (Base)", false, function(v) autoBuyTycoon = v end)

    UIEls.AutoAccept = MiscTab:AddToggle("Auto Accept Phone Offers", false, function(v) autoAcceptOffers = v end)

    local flyEnabled = false
    local flyBV, flyAngV
    local flyConn = nil
    local flySpeed = 40
    MiscTab:AddToggle("Fly", false, function(v)
        flyEnabled = v
        local char = lp.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if v and root then
            local hum = char:FindFirstChild("Humanoid")
            if hum then hum.PlatformStand = true end
            flyBV = Instance.new("BodyVelocity", root)
            flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
            flyBV.Velocity = Vector3.zero
            flyAngV = Instance.new("BodyAngularVelocity", root)
            flyAngV.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
            flyAngV.AngularVelocity = Vector3.zero
            flyConn = game:GetService("RunService").Heartbeat:Connect(function()
                if _G.CrystalHub_Unloaded or not flyEnabled then
                    if flyConn then flyConn:Disconnect() flyConn = nil end
                    return
                end
                local cam = workspace.CurrentCamera
                local move = Vector3.zero
                local UIS2 = game:GetService("UserInputService")
                if UIS2:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
                if UIS2:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
                if UIS2:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
                if UIS2:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
                if UIS2:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
                if UIS2:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
                if flyBV and flyBV.Parent then
                    flyBV.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
                end
            end)
        else
            flyEnabled = false
            if flyConn then flyConn:Disconnect() flyConn = nil end
            if flyBV and flyBV.Parent then flyBV:Destroy() end
            if flyAngV and flyAngV.Parent then flyAngV:Destroy() end
            local char2 = lp.Character
            if char2 then
                local hum2 = char2:FindFirstChild("Humanoid")
                if hum2 then hum2.PlatformStand = false end
            end
        end
    end)
    MiscTab:AddSlider("Fly Speed", 10, 200, 40, function(v) flySpeed = v end)


    local SLMovementTab = Window:MakeTab("Movement", "rbxassetid://109718589733073")
    
    local slWalkSpeedEnabled = false
    local slTargetWalkSpeed = 16
    local slJumpPowerEnabled = false
    local slTargetJumpPower = 50
    local slInfJumpEnabled = false
    
    local slWsConnection = nil
    local slJpConnection = nil
    
    local function slUpdateMovement()
        if slWsConnection then slWsConnection:Disconnect() slWsConnection = nil end
        if slJpConnection then slJpConnection:Disconnect() slJpConnection = nil end
        
        if slWalkSpeedEnabled then
            slWsConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
                if _G.CrystalHub_Unloaded then 
                    if slWsConnection then slWsConnection:Disconnect() end 
                    return 
                end
                if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = lp.Character.Humanoid
                    local rootPart = lp.Character.HumanoidRootPart
                    
                    if humanoid.MoveDirection.Magnitude > 0 then
                        local speedBoost = math.max(0, slTargetWalkSpeed - 16)
                        local translation = humanoid.MoveDirection * (speedBoost * deltaTime)
                        rootPart.CFrame = rootPart.CFrame + translation
                    end
                end
            end)
        end
        
        if slJumpPowerEnabled then
            slJpConnection = game:GetService("RunService").Stepped:Connect(function()
                if _G.CrystalHub_Unloaded then 
                    if slJpConnection then slJpConnection:Disconnect() end 
                    return 
                end
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.UseJumpPower = true
                    lp.Character.Humanoid.JumpPower = slTargetJumpPower
                end
            end)
        end
    end
    
    local slInfJumpConnection = nil
    slInfJumpConnection = UserInputService.JumpRequest:Connect(function()
        if _G.CrystalHub_Unloaded then 
            if slInfJumpConnection then slInfJumpConnection:Disconnect() end 
            return 
        end
        if slInfJumpEnabled and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    
    UIEls.SLWS = SLMovementTab:AddToggle("Enable Custom WalkSpeed", false, function(v) 
        slWalkSpeedEnabled = v 
        slUpdateMovement()
    end)
    UIEls.SLWSVal = SLMovementTab:AddSlider("WalkSpeed Value", 16, 250, 16, function(v) 
        slTargetWalkSpeed = v 
        if slWalkSpeedEnabled then slUpdateMovement() end
    end)
    
    UIEls.SLJP = SLMovementTab:AddToggle("Enable Custom JumpPower", false, function(v) 
        slJumpPowerEnabled = v 
        slUpdateMovement()
    end)
    UIEls.SLJPVal = SLMovementTab:AddSlider("JumpPower Value", 50, 300, 50, function(v) 
        slTargetJumpPower = v 
        if slJumpPowerEnabled then slUpdateMovement() end
    end)
    
    UIEls.SLInfJump = SLMovementTab:AddToggle("Infinite Jump (Fly by Jumping)", false, function(v) slInfJumpEnabled = v end)
end

if isAnimalHospital then
    local MainTab = Window:MakeTab("Automation", "rbxassetid://10734950309")
    local TasksTab = Window:MakeTab("Tasks & Management", "rbxassetid://6023565651")
    local CombatTab = Window:MakeTab("Combat & Entities", "rbxassetid://4483345998")
    local MiscTab = Window:MakeTab("Misc & Upgrades", "rbxassetid://6022668875")
    local MovementTab = Window:MakeTab("Movement", "rbxassetid://109718589733073")

    local autoWork = false
    local autoHeal = false
    local fullHospitalLoop = false
    local shiftAutomation = false
    local sanityManagement = false
    
    local receptionTasks = false
    local machineOps = false
    local autoCure = false
    local hospitalManagement = false

    local entityDetection = false
    local zombieAura = false

    local autoBuyUpgrades = false
    local autoShopTools = false

    local ahNoclip = false

    MainTab:AddToggle("Auto Work (Check-in, Diagnose, Machines)", false, function(v) autoWork = v end)
    MainTab:AddToggle("Auto Heal Patients", false, function(v) autoHeal = v end)
    MainTab:AddToggle("Full Hospital Loop", false, function(v) fullHospitalLoop = v end)
    MainTab:AddToggle("Full Shift Automation", false, function(v) shiftAutomation = v end)
    MainTab:AddToggle("Auto Sanity (Use Coffee/Chocolate)", false, function(v) sanityManagement = v end)
    
    MainTab:AddButton("Load komtolmmek2 Script (Fallback)", function()
        if isfile and isfile("animal_hospital.lua") then
            loadstring(readfile("animal_hospital.lua"))()
        else
            warn("animal_hospital.lua not found in executor workspace")
        end
    end)

    TasksTab:AddToggle("Full Reception Tasks (Talk, Scan, Register, Print)", false, function(v) receptionTasks = v end)
    TasksTab:AddToggle("Full Machine Operations (Inspect, Process)", false, function(v) machineOps = v end)
    TasksTab:AddToggle("Full Curing (Match Illness & Treat)", false, function(v) autoCure = v end)
    TasksTab:AddToggle("Full Hospital Management (Talk, Prepare)", false, function(v) hospitalManagement = v end)

    CombatTab:AddToggle("Entity Detection ESP (Dangerous/Disguised)", false, function(v) entityDetection = v end)
    CombatTab:AddToggle("Zombie Hit Aura (During Events)", false, function(v) zombieAura = v end)

    MiscTab:AddToggle("Auto Buy Machine Upgrades", false, function(v) autoBuyUpgrades = v end)
    MiscTab:AddToggle("Auto Shop Tools", false, function(v) autoShopTools = v end)

    local ahWalkSpeedEnabled = false
    local ahTargetWalkSpeed = 16
    local ahJumpPowerEnabled = false
    local ahTargetJumpPower = 50
    local ahInfJumpEnabled = false
    
    local ahWsConnection = nil
    local ahJpConnection = nil
    
    local function ahUpdateMovement()
        if ahWsConnection then ahWsConnection:Disconnect() ahWsConnection = nil end
        if ahJpConnection then ahJpConnection:Disconnect() ahJpConnection = nil end
        
        if ahWalkSpeedEnabled then
            ahWsConnection = game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
                if _G.CrystalHub_Unloaded then 
                    if ahWsConnection then ahWsConnection:Disconnect() end 
                    return 
                end
                if lp.Character and lp.Character:FindFirstChild("Humanoid") and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = lp.Character.Humanoid
                    local rootPart = lp.Character.HumanoidRootPart
                    if humanoid.MoveDirection.Magnitude > 0 then
                        local speedBoost = math.max(0, ahTargetWalkSpeed - 16)
                        local translation = humanoid.MoveDirection * (speedBoost * deltaTime)
                        rootPart.CFrame = rootPart.CFrame + translation
                    end
                end
            end)
        end
        
        if ahJumpPowerEnabled then
            ahJpConnection = game:GetService("RunService").Stepped:Connect(function()
                if _G.CrystalHub_Unloaded then 
                    if ahJpConnection then ahJpConnection:Disconnect() end 
                    return 
                end
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.UseJumpPower = true
                    lp.Character.Humanoid.JumpPower = ahTargetJumpPower
                end
            end)
        end
    end
    
    local ahInfJumpConnection = nil
    ahInfJumpConnection = UserInputService.JumpRequest:Connect(function()
        if _G.CrystalHub_Unloaded then 
            if ahInfJumpConnection then ahInfJumpConnection:Disconnect() end 
            return 
        end
        if ahInfJumpEnabled and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
    
    MovementTab:AddToggle("Enable Custom WalkSpeed", false, function(v) 
        ahWalkSpeedEnabled = v 
        ahUpdateMovement()
    end)
    MovementTab:AddSlider("WalkSpeed Value", 16, 250, 16, function(v) 
        ahTargetWalkSpeed = v 
        if ahWalkSpeedEnabled then ahUpdateMovement() end
    end)
    
    MovementTab:AddToggle("Enable Custom JumpPower", false, function(v) 
        ahJumpPowerEnabled = v 
        ahUpdateMovement()
    end)
    MovementTab:AddSlider("JumpPower Value", 50, 300, 50, function(v) 
        ahTargetJumpPower = v 
        if ahJumpPowerEnabled then ahUpdateMovement() end
    end)
    
    MovementTab:AddToggle("Infinite Jump (Fly by Jumping)", false, function(v) ahInfJumpEnabled = v end)

    local ahNoclipConnection = nil
    MovementTab:AddToggle("Noclip", false, function(v)
        ahNoclip = v
        if ahNoclip then
            ahNoclipConnection = game:GetService("RunService").Stepped:Connect(function()
                if _G.CrystalHub_Unloaded or not ahNoclip then
                    if ahNoclipConnection then ahNoclipConnection:Disconnect() ahNoclipConnection = nil end
                    return
                end
                if lp.Character then
                    for _, part in pairs(lp.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if ahNoclipConnection then ahNoclipConnection:Disconnect() ahNoclipConnection = nil end
        end
    end)
end

if isNewGame then
    local FarmTab = Window:MakeTab("Auto Farm", "rbxassetid://10734950309")
    local TreadmillTab = Window:MakeTab("Treadmill", "rbxassetid://109718589733073")
    local PlayerTab = Window:MakeTab("Player", "rbxassetid://109718589733073")

    local liveStatusGui = Instance.new("ScreenGui")
    liveStatusGui.Name = "CrystalStatusGui"
    pcall(function() liveStatusGui.Parent = gethui and gethui() or CoreGui end)
    if not liveStatusGui.Parent then liveStatusGui.Parent = lp:WaitForChild("PlayerGui") end
    local liveStatusLabel = Instance.new("TextLabel", liveStatusGui)
    liveStatusLabel.Size = UDim2.new(0, 300, 0, 30)
    liveStatusLabel.Position = UDim2.new(0.5, -150, 0, 0)
    liveStatusLabel.BackgroundTransparency = 0.5
    liveStatusLabel.BackgroundColor3 = Color3.new(0,0,0)
    liveStatusLabel.TextColor3 = Color3.new(1,1,1)
    liveStatusLabel.Text = "Status: Idle"
    liveStatusLabel.TextScaled = true
    liveStatusLabel.Visible = false

    local function setStatus(txt)
        liveStatusLabel.Text = "Status: " .. txt
    end

    local stages = {}
    if workspace:FindFirstChild("Structure") then
        for _, v in pairs(workspace.Structure:GetChildren()) do
            if v.Name:match("Stage%d+") then
                local sNum = tonumber(v.Name:match("%d+"))
                if sNum and sNum <= 13 then
                    table.insert(stages, v.Name)
                end
            end
        end
    end
    table.sort(stages, function(a, b)
        local numA = tonumber(a:match("%d+")) or 0
        local numB = tonumber(b:match("%d+")) or 0
        return numA < numB
    end)
    if #stages == 0 then table.insert(stages, "Stage1") end

    local autoFarmStages = false
    local showLiveStatus = true
    local stageWait = 0.5
    local loopDelay = 1.0
    local maxLoops = 0

    local autoFarmSpeed = false
    local autoEquipBest = false

    local circleAngle = 0
    local speedCircleConn = nil
    
    local function toggleCircleRun(state)
        autoFarmSpeed = state
        if autoFarmSpeed then
            if not speedCircleConn then
                speedCircleConn = game:GetService("RunService").Heartbeat:Connect(function()
                    if _G.CrystalHub_Unloaded or not autoFarmSpeed then
                        if speedCircleConn then speedCircleConn:Disconnect() speedCircleConn = nil end
                        return
                    end
                    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                        circleAngle = circleAngle + 0.1
                        if circleAngle >= math.pi * 2 then circleAngle = 0 end
                        local dir = Vector3.new(math.cos(circleAngle), 0, math.sin(circleAngle))
                        lp.Character.Humanoid:Move(dir, false)
                    end
                end)
            end
        else
            if speedCircleConn then speedCircleConn:Disconnect() speedCircleConn = nil end
            if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                lp.Character.Humanoid:Move(Vector3.zero, false)
            end
        end
    end

    task.spawn(function()
        while task.wait(3) do
            if _G.CrystalHub_Unloaded then break end
            if not autoEquipBest then continue end
            pcall(function()
                local rs = game:GetService("ReplicatedStorage")
                if rs:FindFirstChild("EquipBest") then rs.EquipBest:FireServer() end
                if rs:FindFirstChild("EquipBestTrails") then rs.EquipBestTrails:FireServer() end
                if rs:FindFirstChild("EquipBestPets") then rs.EquipBestPets:FireServer() end
                if rs:FindFirstChild("RemoteEvents") and rs.RemoteEvents:FindFirstChild("EquipBest") then rs.RemoteEvents.EquipBest:FireServer() end
            end)
        end
    end)

    local selectedStagesForFarm = {}
    local stageToggles = {}

    local function updateFarmList()
        selectedStagesForFarm = {}
        for stageName, toggleState in pairs(stageToggles) do
            if toggleState then
                table.insert(selectedStagesForFarm, stageName)
            end
        end
        table.sort(selectedStagesForFarm, function(a, b)
            local numA = tonumber(a:match("%d+")) or 0
            local numB = tonumber(b:match("%d+")) or 0
            return numA < numB
        end)
    end

    local currentFarmMoveConn
    local farmSpeedConn
    local farmNoclipConn

    local function applyGodMode()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("BasePart") and v:FindFirstChildWhichIsA("TouchTransmitter") then
                local n = v.Name:lower()
                if n:match("kill") or n:match("lava") or n:match("damage") or n:match("hitbox") then
                    v:FindFirstChildWhichIsA("TouchTransmitter"):Destroy()
                    v.CanCollide = false
                end
            end
        end
    end

    local stageEndPositions = {
        ["Stage1"] = Vector3.new(-13.7, 13.0, 77.2),
        ["Stage2"] = Vector3.new(15.0, 12.4, 301.2),
        ["Stage3"] = Vector3.new(13.9, 13.4, 531.2),
        ["Stage4"] = Vector3.new(14.6, 81.4, 798.3),
        ["Stage5"] = Vector3.new(14.0, 80.6, 1132.3),
        ["Stage6"] = Vector3.new(14.7, 80.6, 1424.3),
        ["Stage7"] = Vector3.new(-572.0, 58.8, 1480.2),
        ["Stage8"] = Vector3.new(-1039.0, 59.0, 1479.5),
        ["Stage9"] = Vector3.new(-1149.0, 300.8, 1479.4)
    }

    FarmTab:AddToggle("Auto Gain Speed", false, function(v) toggleCircleRun(v) end)
    FarmTab:AddToggle("Auto Equip Best (Trails/Pets)", false, function(v) autoEquipBest = v end)
    
    task.spawn(function()
        while not _G.CrystalHub_Unloaded do
            if autoEquipBest then
                pcall(function()
                    local btn = game:GetService("Players").LocalPlayer.PlayerGui.SpeedGameUI.Modals.InventoryModal.ModalsFrame.Items.Equipped.EquipButtons.EquipBestItems
                    for _, conn in ipairs(getconnections(btn.MouseButton1Click)) do
                        if type(conn.Function) == "function" then task.spawn(conn.Function) end
                    end
                    for _, conn in ipairs(getconnections(btn.Activated)) do
                        if type(conn.Function) == "function" then task.spawn(conn.Function) end
                    end
                end)
            end
            task.wait(5)
        end
    end)
    
    for _, sName in ipairs(stages) do
        FarmTab:AddButton("Walk & Win " .. sName, function()
            local targetPos = stageEndPositions[sName]
            if not targetPos then
                local sNum = tonumber(sName:match("%d+"))
                local wb = workspace.Structure:FindFirstChild(sName)
                local targetPart
                if wb then
                    targetPart = wb:FindFirstChild("WinBlock" .. (sNum and (sNum - 1) or "")) or wb:FindFirstChildWhichIsA("BasePart", true)
                end
                if not targetPart and sNum then
                    targetPart = workspace.Checkpoints:FindFirstChild("SkipToStage" .. tostring(sNum + 1))
                end
                if targetPart then targetPos = targetPart.Position end
            end
            if targetPos and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and lp.Character:FindFirstChild("Humanoid") then
                task.spawn(function()
                    applyGodMode()
                    
                    for _, p in pairs(lp.Character:GetDescendants()) do
                        if p:IsA("BasePart") then p.CanTouch = true end
                    end
                    
                    local hrp = lp.Character.HumanoidRootPart
                    local hum = lp.Character.Humanoid
                    
                    local sNum = tonumber(sName:match("%d+"))
                    local prevTargetPos = Vector3.new(0, 0, 0)
                    if sNum and sNum > 1 and stageEndPositions["Stage"..(sNum-1)] then
                        prevTargetPos = stageEndPositions["Stage"..(sNum-1)]
                    end
                    
                    local dir = Vector3.new(0, 0, -1)
                    if prevTargetPos then
                        local diff = prevTargetPos - targetPos
                        dir = Vector3.new(diff.X, 0, diff.Z)
                        if dir.Magnitude > 0 then dir = dir.Unit end
                    end
                    
                    local offsetPos = targetPos + (dir * 8) + Vector3.new(0, 3, 0)
                    local dist = (hrp.Position - offsetPos).Magnitude
                    local safeSpeed = math.max(hum.WalkSpeed, 80)
                    local tweenTime = dist / safeSpeed
                    
                    local nc
                    nc = game:GetService("RunService").Stepped:Connect(function()
                        if lp.Character then
                            for _, part in pairs(lp.Character:GetDescendants()) do
                                if part:IsA("BasePart") and part.CanCollide then
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                    
                    local ts = game:GetService("TweenService")
                    local tw = ts:Create(hrp, TweenInfo.new(tweenTime, Enum.EasingStyle.Linear), {CFrame = CFrame.new(offsetPos)})
                    tw:Play()
                    tw.Completed:Wait()
                    
                    if nc then nc:Disconnect() end
                    
                    local oldSpeed = hum.WalkSpeed
                    hum.WalkSpeed = 50
                    hum:MoveTo(targetPos)
                    
                    local timeout = 2
                    local start = tick()
                    while tick() - start < timeout do
                        if (hrp.Position - targetPos).Magnitude < 4 then break end
                        task.wait(0.1)
                    end
                    
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    if not walkSpeedEnabled then
                        hum.WalkSpeed = oldSpeed
                    end
                end)
            end
        end)
    end

    local autoTreadmill = false
    local treadmillIndex = "Treadmill"
    local offsetX = 0
    local offsetY = -3
    local offsetZ = 0
    local runTick = 0

    local allTreadmills = {}
    for _, v in pairs(workspace:GetChildren()) do
        if v.Name:match("Treadmill") and (v:IsA("Model") or v:IsA("Folder")) then
            table.insert(allTreadmills, v.Name)
        end
    end
    if #allTreadmills == 0 then table.insert(allTreadmills, "Treadmill") end
    
    local treadmillConn
    local originalTreadmillCFrame

    TreadmillTab:AddToggle("Auto Run", false, function(v)
        autoTreadmill = v
        if autoTreadmill then
            task.spawn(function()
                while autoTreadmill and not _G.CrystalHub_Unloaded do
                    local tModel = workspace:FindFirstChild(treadmillIndex)
                    if tModel then
                        local conveyor = tModel:FindFirstChild("Conveyor", true)
                        if conveyor and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                            if not originalTreadmillCFrame then originalTreadmillCFrame = conveyor.CFrame end
                            conveyor.CanCollide = false
                            conveyor.CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.new(offsetX, offsetY, offsetZ)
                        end
                    end
                    if runTick > 0 then
                        task.wait(runTick)
                    else
                        game:GetService("RunService").Heartbeat:Wait()
                    end
                end
                
                local tModel = workspace:FindFirstChild(treadmillIndex)
                if tModel then
                    local conveyor = tModel:FindFirstChild("Conveyor", true)
                    if conveyor and originalTreadmillCFrame then
                        conveyor.CFrame = originalTreadmillCFrame
                        conveyor.CanCollide = true
                    end
                end
                originalTreadmillCFrame = nil
            end)
        else
            local tModel = workspace:FindFirstChild(treadmillIndex)
            if tModel then
                local conveyor = tModel:FindFirstChild("Conveyor", true)
                if conveyor and originalTreadmillCFrame then
                    conveyor.CFrame = originalTreadmillCFrame
                    conveyor.CanCollide = true
                end
            end
            originalTreadmillCFrame = nil
        end
    end)
    
    TreadmillTab:AddDropdown("Treadmill Index", allTreadmills, allTreadmills[1], function(v) treadmillIndex = v end)
    TreadmillTab:AddSlider("Offset X", -20, 20, 0, function(v) offsetX = v end)
    TreadmillTab:AddSlider("Offset Y", -20, 20, -3, function(v) offsetY = v end)
    TreadmillTab:AddSlider("Offset Z", -20, 20, 0, function(v) offsetZ = v end)
    TreadmillTab:AddSlider("Run Tick Delay (s)", 0, 5, 0, function(v) runTick = v end)

    local walkSpeedEnabled = false
    local targetWalkSpeed = 16
    local jumpPowerEnabled = false
    local targetJumpPower = 50
    local infJumpEnabled = false
    local flyEnabled = false
    local noclipEnabled = false
    local flySpeed = 50

    local wsConn, jpConn, infJumpConn, flyConn, noclipConn
    local flyBodyVelocity, flyBodyGyro

    local function updateMovement()
        if wsConn then wsConn:Disconnect() wsConn = nil end
        if jpConn then jpConn:Disconnect() jpConn = nil end
        
        if walkSpeedEnabled then
            wsConn = game:GetService("RunService").Heartbeat:Connect(function()
                if _G.CrystalHub_Unloaded then if wsConn then wsConn:Disconnect() end return end
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.WalkSpeed = targetWalkSpeed
                end
            end)
        end
        
        if jumpPowerEnabled then
            jpConn = game:GetService("RunService").Stepped:Connect(function()
                if _G.CrystalHub_Unloaded then if jpConn then jpConn:Disconnect() end return end
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.UseJumpPower = true
                    lp.Character.Humanoid.JumpPower = targetJumpPower
                end
            end)
        end
    end

    PlayerTab:AddToggle("Custom WalkSpeed", false, function(v) 
        walkSpeedEnabled = v; updateMovement() 
    end)
    PlayerTab:AddSlider("WalkSpeed Value", 16, 500, 16, function(v) 
        targetWalkSpeed = v; if walkSpeedEnabled then updateMovement() end 
    end)
    
    PlayerTab:AddToggle("Custom JumpPower", false, function(v) 
        jumpPowerEnabled = v; updateMovement() 
    end)
    PlayerTab:AddSlider("JumpPower Value", 50, 500, 50, function(v) 
        targetJumpPower = v; if jumpPowerEnabled then updateMovement() end 
    end)
    
    PlayerTab:AddToggle("Infinite Jump", false, function(v) infJumpEnabled = v end)
    infJumpConn = game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.CrystalHub_Unloaded then if infJumpConn then infJumpConn:Disconnect() end return end
        if infJumpEnabled and lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    PlayerTab:AddToggle("Noclip", false, function(v)
        noclipEnabled = v
        if noclipEnabled then
            if not noclipConn then
                noclipConn = game:GetService("RunService").Stepped:Connect(function()
                    if _G.CrystalHub_Unloaded or not noclipEnabled then
                        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
                        return
                    end
                    if lp.Character then
                        for _, part in pairs(lp.Character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end)
            end
        else
            if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        end
    end)

    PlayerTab:AddToggle("Fly", false, function(v)
        flyEnabled = v
        if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = lp.Character.HumanoidRootPart
        if flyEnabled then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            flyBodyVelocity.Parent = hrp
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            flyBodyGyro.P = 9e4
            flyBodyGyro.Parent = hrp
        else
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        end
    end)
    
    PlayerTab:AddSlider("Fly Speed", 10, 200, 50, function(v) flySpeed = v end)

    flyConn = game:GetService("RunService").RenderStepped:Connect(function()
        if _G.CrystalHub_Unloaded then if flyConn then flyConn:Disconnect() end return end
        if flyEnabled and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = lp.Character.HumanoidRootPart
            local cam = workspace.CurrentCamera
            local dir = Vector3.new()
            local uis = game:GetService("UserInputService")
            if uis:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
            if uis:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
            if uis:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
            
            if flyBodyVelocity and flyBodyGyro then
                flyBodyVelocity.Velocity = dir * flySpeed
                flyBodyGyro.CFrame = cam.CFrame
            end
        end
    end)
end

if isKickLuckyBlock then
    local FarmTab = Window:MakeTab("Auto Farm", "rbxassetid://10734950309")
    local UpgradesTab = Window:MakeTab("Upgrades", "rbxassetid://109718589733073")
    local PlayerTab = Window:MakeTab("Player", "rbxassetid://109718589733073")

    local autoFarm = false
    local autoCollect = false
    local autoTrain = false
    local perfectKick = false
    local autoRebirth = false
    local autoUpgrade = false
    local godMode = false
    local infinitePotion = false

    FarmTab:AddToggle("Auto Train (Kick Ball)", false, function(v)
        autoTrain = v
        if autoTrain then
            task.spawn(function()
                while autoTrain and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_ballKick:FireServer()
                    end)
                    task.wait(0.1)
                end
            end)
        end
    end)
    
    FarmTab:AddToggle("Auto Farm (Open Blocks)", false, function(v)
        autoFarm = v
        if autoFarm then
            task.spawn(function()
                while autoFarm and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_LB_OpenRequest:FireServer()
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end)

    FarmTab:AddToggle("Auto Collect", false, function(v)
        autoCollect = v
        if autoCollect then
            task.spawn(function()
                while autoCollect and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_B_Collect:FireServer()
                    end)
                    task.wait(1)
                end
            end)
        end
    end)

    FarmTab:AddToggle("Perfect Kick", false, function(v)
        perfectKick = v
        if perfectKick then
            task.spawn(function()
                while perfectKick and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_KickEvent:FireServer()
                        task.wait(0.1)
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_KickCollect:FireServer()
                        task.wait(0.1)
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_KickEventEnded:FireServer()
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end)

    UpgradesTab:AddToggle("Auto Upgrade Stats", false, function(v)
        autoUpgrade = v
        if autoUpgrade then
            task.spawn(function()
                while autoUpgrade and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_B_Upgrade:FireServer()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_SPEED_UPGRADE:FireServer()
                    end)
                    task.wait(2)
                end
            end)
        end
    end)

    UpgradesTab:AddToggle("Auto Rebirth", false, function(v)
        autoRebirth = v
        if autoRebirth then
            task.spawn(function()
                while autoRebirth and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_RebirthRequest:FireServer()
                    end)
                    task.wait(5)
                end
            end)
        end
    end)
    
    PlayerTab:AddToggle("God Mode (Remove Hazards)", false, function(v)
        godMode = v
        if godMode then
            task.spawn(function()
                while godMode and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        local descendants = workspace:GetDescendants()
                        for i, part in ipairs(descendants) do
                            if i % 1000 == 0 then task.wait() end
                            if part:IsA("BasePart") and part:FindFirstChildWhichIsA("TouchTransmitter") then
                                local name = part.Name:lower()
                                if name:match("kill") or name:match("lava") or name:match("damage") then
                                    part:FindFirstChildWhichIsA("TouchTransmitter"):Destroy()
                                    part.CanCollide = false
                                end
                            end
                        end
                    end)
                    task.wait(10)
                end
            end)
        end
    end)
    
    PlayerTab:AddToggle("Infinite Potion (Volcanic)", false, function(v)
        infinitePotion = v
        if infinitePotion then
            task.spawn(function()
                while infinitePotion and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        game:GetService("ReplicatedStorage").Shared.Packages.Network.rev_VolcanicShop_UsePotion:FireServer()
                    end)
                    task.wait(5)
                end
            end)
        end
    end)
end

if isMM2 then
    local FarmTab = Window:MakeTab("Farm", "rbxassetid://10734950309")
    local CombatTab = Window:MakeTab("Combat", "rbxassetid://4483345998")
    local VisualsTab = Window:MakeTab("Visuals", "rbxassetid://6034287515")
    local MovementTab = Window:MakeTab("Movement", "rbxassetid://4483362458")
    local TeleportsTab = Window:MakeTab("Teleport", "rbxassetid://109718589733073")
    local MiscTab = Window:MakeTab("Misc", "rbxassetid://6022668875")
    
    local Roles = { Murderer = nil, Sheriff = nil, Hero = nil }
    local avoidMurderer = false
    local _cachedMap = nil
    local _mapCacheTime = 0

    local function GetMM2Map()
        if _cachedMap and _cachedMap.Parent and (tick() - _mapCacheTime) < 3 then
            return _cachedMap
        end
        _cachedMap = nil
        for _, v in pairs(workspace:GetChildren()) do
            if v:IsA("Model") and v.Name ~= "Lobby" and v.Name ~= "Normal" and v.Name ~= "RegularLobby"
               and (v:FindFirstChild("CoinContainer") or v:FindFirstChild("Spawns")) then
                _cachedMap = v
                _mapCacheTime = tick()
                return v
            end
        end
        local normal = workspace:FindFirstChild("Normal")
        if normal and (normal:FindFirstChild("CoinContainer") or normal:FindFirstChild("Spawns")) then
            _cachedMap = normal
            _mapCacheTime = tick()
            return normal
        end
        return nil
    end

    local _rolesLastUpdate = 0
    local function UpdateRoles()
        if (tick() - _rolesLastUpdate) < 0.5 then return end
        _rolesLastUpdate = tick()
        Roles.Murderer = nil
        Roles.Sheriff  = nil
        Roles.Hero     = nil
        for _, p in pairs(Players:GetPlayers()) do
            local bp   = p:FindFirstChild("Backpack")
            local char = p.Character
            
            local hasKnife = false
            local hasGun = false
            local hasRevolver = false
            
            local function checkCont(c)
                if not c then return end
                for _, t in pairs(c:GetChildren()) do
                    if t:IsA("Tool") then
                        if t.Name == "Knife" or t:FindFirstChild("KnifeServer") or t:FindFirstChild("KnifeClient") then
                            if t.Name ~= "Snowball" and t.Name ~= "WaterBalloon" then
                                hasKnife = true
                            end
                        elseif t.Name == "Gun" or t:FindFirstChild("GunServer") or t:FindFirstChild("GunClient") then
                            if t.Name ~= "Snowball" and t.Name ~= "WaterBalloon" then
                                hasGun = true
                            end
                        elseif t.Name == "Revolver" then
                            hasRevolver = true
                        end
                    end
                end
            end
            
            checkCont(bp)
            checkCont(char)
            
            if hasKnife then Roles.Murderer = p
            elseif hasRevolver then Roles.Hero = p
            elseif hasGun then Roles.Sheriff = p
            end
        end
    end
    local function GetRoles() UpdateRoles() end

    task.spawn(function()
        while task.wait(0.5) and not _G.CrystalHub_Unloaded do
            pcall(function()
                for _, effect in pairs(game:GetService("Lighting"):GetChildren()) do
                    if effect:IsA("BlurEffect") or effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
                        effect.Enabled = false
                    end
                end
                
                local mainGui = lp.PlayerGui:FindFirstChild("MainGUI")
                if mainGui then
                    local blind = mainGui:FindFirstChild("Blind")
                    if blind then blind.Visible = false end
                end
                local transition = lp.PlayerGui:FindFirstChild("Transition")
                if transition then transition.Enabled = false end

                if IsAlive(lp) then
                    local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Anchored then hrp.Anchored = false end
                    local hum = lp.Character:FindFirstChild("Humanoid")
                    if hum then
                        if hum.WalkSpeed == 0 then hum.WalkSpeed = 16 end
                        if hum.JumpPower == 0 then hum.JumpPower = 50 end
                    end
                    local cam = workspace.CurrentCamera
                    if cam and cam.CameraType == Enum.CameraType.Scriptable then
                        cam.CameraType = Enum.CameraType.Custom
                    end
                end
            end)
        end
    end)


    local function GetCoins()
        local coins = {}
        local map = GetMM2Map()
        if map and map:FindFirstChild("CoinContainer") then
            for _, c in pairs(map.CoinContainer:GetChildren()) do
                if not c.Parent or c:IsA("Folder") then continue end
                
                local isVisible = false
                
                if c:IsA("BasePart") and c.Transparency < 1 then
                    isVisible = true
                else
                    for _, p in pairs(c:GetDescendants()) do
                        if p:IsA("BasePart") and p.Transparency < 1 then
                            isVisible = true
                            break
                        end
                    end
                end
                
                if isVisible then
                    table.insert(coins, c)
                end
            end
        end
        return coins
    end

    local function GetCoinTargetPart(coin)
        local coinServer = coin:FindFirstChild("Coin_Server")
        if coinServer and coinServer:IsA("BasePart") then return coinServer end
        
        if coin:IsA("BasePart") then return coin end
        if coin:IsA("Model") and coin.PrimaryPart then return coin.PrimaryPart end
        
        local c = coin:FindFirstChild("Coin")
        if c and c:IsA("BasePart") then return c end
        
        if coin:FindFirstChild("CoinVisual") then
            local vis = coin.CoinVisual
            if vis:IsA("BasePart") then return vis end
            local p = vis:FindFirstChildWhichIsA("BasePart", true)
            if p then return p end
        end
        return coin:FindFirstChildWhichIsA("BasePart", true) or coin
    end

    local function GetGunDrop()
        local map = GetMM2Map()
        if map then
            local gun = map:FindFirstChild("GunDrop")
            if gun then return gun end
        end
        local gunDrop = workspace:FindFirstChild("GunDrop")
        if gunDrop then return gunDrop end
        return nil
    end

    local function IsAlive(p)
        return p and p.Character and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 and p.Character:FindFirstChild("HumanoidRootPart")
    end

    local function IsTargetable(p)
        if not IsAlive(p) then return false end
        if p.Character:FindFirstChildOfClass("ForceField") then return false end
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        
        local lobbyCenter = Vector3.new(-109, 140, 18)
        if (hrp.Position - lobbyCenter).Magnitude < 400 then
            return false
        end
        
        local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("RegularLobby") or workspace:FindFirstChild("Normal")
        if lobby then
            local lobbyPos = lobby:GetPivot().Position
            if (hrp.Position - lobbyPos).Magnitude < 400 then
                return false
            end
        end
        return true
    end

    VisualsTab:AddToggle("Role ESP", false, function(v)
        if v then
            StartFeature("RoleESP", function(data)
                local espContainer = Instance.new("Folder")
                espContainer.Name = game:GetService("HttpService"):GenerateGUID(false)
                pcall(function() espContainer.Parent = gethui and gethui() or CoreGui end)
                if not espContainer.Parent then pcall(function() espContainer.Parent = lp:WaitForChild("PlayerGui") end) end
                table.insert(data.instances, espContainer)
                
                data.cleanup = function()
                    for _, objs in pairs(data.cache) do
                        pcall(function() objs.hl.Adornee = nil objs.hl:Destroy() end)
                        pcall(function() objs.bb.Adornee = nil objs.bb:Destroy() end)
                    end
                    pcall(function() espContainer:Destroy() end)
                end
                
                while data.active and not _G.CrystalHub_Unloaded do
                    GetRoles()
                    local seen = {}
                    
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= lp and IsAlive(p) then
                            local char = p.Character
                            local hrp = char:FindFirstChild("HumanoidRootPart")
                            local head = char:FindFirstChild("Head") or hrp
                            
                            local pName = p.Name
                            seen[pName] = true
                            
                            if not data.cache[pName] then
                                local hl = Instance.new("Highlight")
                                hl.FillTransparency = 0.5
                                hl.OutlineTransparency = 0.1
                                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                hl.Parent = espContainer
                                
                                local bb = Instance.new("BillboardGui")
                                bb.AlwaysOnTop = true
                                bb.Size = UDim2.new(0, 200, 0, 50)
                                bb.ExtentsOffset = Vector3.new(0, 3, 0)
                                bb.Parent = espContainer
                                
                                local txt = Instance.new("TextLabel", bb)
                                txt.TextSize = 14
                                txt.Font = Enum.Font.GothamBold
                                txt.BackgroundTransparency = 1
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.TextStrokeTransparency = 0
                                
                                data.cache[pName] = { hl = hl, bb = bb, txt = txt }
                            end
                            
                            local objs = data.cache[pName]
                            objs.hl.Adornee = char
                            objs.bb.Adornee = head
                            
                            local dist = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") and math.floor((hrp.Position - lp.Character.HumanoidRootPart.Position).Magnitude) or 0
                            
                            if p == Roles.Murderer then
                                objs.hl.FillColor = Color3.new(1, 0, 0)
                                objs.hl.OutlineColor = Color3.new(1, 0.5, 0.5)
                                objs.txt.TextColor3 = Color3.new(1, 0, 0)
                                objs.txt.Text = p.Name .. "\nMURDERER | " .. dist .. "s"
                            elseif p == Roles.Sheriff or p == Roles.Hero then
                                objs.hl.FillColor = Color3.new(0, 0.5, 1)
                                objs.hl.OutlineColor = Color3.new(0.5, 0.8, 1)
                                objs.txt.TextColor3 = Color3.new(0, 0.5, 1)
                                objs.txt.Text = p.Name .. "\nSHERIFF | " .. dist .. "s"
                            else
                                objs.hl.FillColor = Color3.new(0, 1, 0)
                                objs.hl.OutlineColor = Color3.new(0.5, 1, 0.5)
                                objs.txt.TextColor3 = Color3.new(0, 1, 0)
                                objs.txt.Text = p.Name .. "\nINNOCENT | " .. dist .. "s"
                            end
                        end
                    end
                    
                    for name, objs in pairs(data.cache) do
                        if not seen[name] then
                            pcall(function() objs.hl:Destroy() objs.bb:Destroy() end)
                            data.cache[name] = nil
                        end
                    end
                    
                    task.wait(0.5)
                end
            end)
        else
            StopFeature("RoleESP")
        end
    end)
    
    local coinESPToggle
    coinESPToggle = VisualsTab:AddToggle("Coin ESP", false, function(v)
        if v then
            StartFeature("CoinESP", function(data)
                local ESPFolder = Instance.new("Folder")
                ESPFolder.Name = game:GetService("HttpService"):GenerateGUID(false)
                pcall(function() ESPFolder.Parent = gethui and gethui() or CoreGui end)
                if not ESPFolder.Parent then pcall(function() ESPFolder.Parent = lp:WaitForChild("PlayerGui") end) end
                table.insert(data.instances, ESPFolder)
                
                data.cleanup = function()
                    for _, objs in pairs(data.cache) do
                        pcall(function() objs.bb.Adornee = nil objs.bb:Destroy() end)
                    end
                    pcall(function() ESPFolder:Destroy() end)
                end
                
                while data.active and not _G.CrystalHub_Unloaded do
                    local activeCoins = {}
                    for _, obj in pairs(GetCoins()) do
                        if obj.Parent then
                            activeCoins[obj] = true
                            
                            if not data.cache[obj] then
                                local bb = Instance.new("BillboardGui")
                                bb.AlwaysOnTop = true
                                bb.Size = UDim2.new(0, 50, 0, 50)
                                bb.Parent = ESPFolder
                                
                                local txt = Instance.new("TextLabel", bb)
                                txt.TextSize = 12
                                txt.Font = Enum.Font.GothamBold
                                txt.BackgroundTransparency = 1
                                txt.Size = UDim2.new(1, 0, 1, 0)
                                txt.TextColor3 = Color3.fromRGB(255, 255, 0)
                                txt.TextStrokeTransparency = 0
                                txt.Text = "Coin"
                                
                                data.cache[obj] = { bb = bb }
                                
                                data.cache[obj].conn1 = obj.AncestryChanged:Connect(function(_, parent)
                                    if not parent then pcall(function() data.cache[obj].bb:Destroy() data.cache[obj] = nil end) end
                                end)
                            end
                            if data.cache[obj] and data.cache[obj].bb then
                                data.cache[obj].bb.Adornee = GetCoinTargetPart(obj)
                            end
                        end
                    end
                    
                    for obj, cData in pairs(data.cache) do
                        if not activeCoins[obj] or not obj.Parent then
                            pcall(function() cData.bb:Destroy() end)
                            if cData.conn1 then cData.conn1:Disconnect() end
                            data.cache[obj] = nil
                        end
                    end
                    
                    task.wait(0.05)
                end
            end)
        else
            StopFeature("CoinESP")
        end
    end)
    
    VisualsTab:AddToggle("Gun Drop ESP", false, function(v)
        if v then
            StartFeature("GunDropESP", function(data)
                local ESPFolder = Instance.new("Folder")
                ESPFolder.Name = game:GetService("HttpService"):GenerateGUID(false)
                pcall(function() ESPFolder.Parent = gethui and gethui() or CoreGui end)
                if not ESPFolder.Parent then pcall(function() ESPFolder.Parent = lp:WaitForChild("PlayerGui") end) end
                table.insert(data.instances, ESPFolder)
                
                data.cleanup = function()
                    if data.cache.gun then
                        pcall(function() data.cache.gun.bb.Adornee = nil data.cache.gun.bb:Destroy() end)
                    end
                    pcall(function() ESPFolder:Destroy() end)
                end
                
                while data.active and not _G.CrystalHub_Unloaded do
                    local gunDrop = GetGunDrop()
                    if gunDrop then
                        if not data.cache.gun then
                            local bb = Instance.new("BillboardGui")
                            bb.AlwaysOnTop = true
                            bb.Size = UDim2.new(0, 100, 0, 50)
                            bb.ExtentsOffset = Vector3.new(0, 1, 0)
                            bb.Parent = ESPFolder
                            
                            local txt = Instance.new("TextLabel", bb)
                            txt.TextSize = 16
                            txt.Font = Enum.Font.GothamBold
                            txt.BackgroundTransparency = 1
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                            txt.TextStrokeTransparency = 0
                            txt.Text = "Gun Drop"
                            
                            data.cache.gun = { bb = bb }
                        end
                        data.cache.gun.bb.Adornee = gunDrop
                    else
                        if data.cache.gun then
                            pcall(function() data.cache.gun.bb:Destroy() end)
                            data.cache.gun = nil
                        end
                    end
                    task.wait(0.5)
                end
            end)
        else
            StopFeature("GunDropESP")
        end
    end)
    

    CombatTab:AddToggle("Auto Shoot Murderer", false, function(v)
        if v then
            StartFeature("AutoShoot", function(data)
                while data.active and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        UpdateRoles()
                        if not IsAlive(lp) then return end

                        local char = lp.Character
                        local gun = lp.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
                        if not gun then return end

                        local murderer = Roles.Murderer
                        if not IsAlive(murderer) then return end
                        if murderer.Character:FindFirstChildOfClass("ForceField") then return end

                        if gun.Parent ~= char then
                            char.Humanoid:EquipTool(gun)
                            task.wait(0.1)
                        end

                        local mHRP = murderer.Character:FindFirstChild("HumanoidRootPart")
                        if mHRP then
                            local cam = workspace.CurrentCamera
                            if cam then
                                local oldCam = cam.CFrame
                                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, mHRP.Position)
                                task.wait(0.05)
                                local vim = game:GetService("VirtualInputManager")
                                vim:SendMouseMoveEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, game)
                                task.wait(0.05)
                                pcall(function() gun:Activate() end)
                                task.wait(0.05)
                                vim:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, true, game, 1)
                                task.wait(0.05)
                                vim:SendMouseButtonEvent(cam.ViewportSize.X/2, cam.ViewportSize.Y/2, 0, false, game, 1)
                                cam.CFrame = oldCam
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        else
            StopFeature("AutoShoot")
        end
    end)
    
    local function FlingTarget(targetPlayer)
        if not IsAlive(targetPlayer) or not IsAlive(lp) then return end
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        local hum = lp.Character:FindFirstChild("Humanoid")
        if not (hrp and hum) then return end
        
        local oldPos = hrp.CFrame
        
        local noclipLoop = game:GetService("RunService").Stepped:Connect(function()
            for _, p in pairs(lp.Character:GetDescendants()) do
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then 
                    p.CanCollide = false 
                end
            end
        end)
        
        local bv = Instance.new("BodyAngularVelocity")
        bv.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bv.AngularVelocity = Vector3.new(0, 999999, 0)
        bv.Parent = hrp

        hum:ChangeState(Enum.HumanoidStateType.Physics)
        
        local startTime = tick()
        local flingLoop = game:GetService("RunService").Stepped:Connect(function()
            if IsAlive(targetPlayer) and IsAlive(lp) then
                local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                if targetHRP then
                    hrp.CFrame = targetHRP.CFrame
                    hrp.Velocity = Vector3.zero
                    hrp.RotVelocity = Vector3.new(0, 500000, 0)
                end
            end
        end)
        
        while IsAlive(targetPlayer) and IsAlive(lp) and tick() - startTime < 1.5 do
            local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP and (targetHRP.Velocity.Magnitude > 150 or targetHRP.Position.Y < -40) then
                break 
            end
            task.wait(0.05)
        end
        
        pcall(function() flingLoop:Disconnect() end)
        pcall(function() noclipLoop:Disconnect() end)
        pcall(function() bv:Destroy() end)
        
        for _, p in pairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = true
            end
        end
        
        hrp.Velocity = Vector3.zero
        hrp.RotVelocity = Vector3.zero
        hrp.CFrame = oldPos
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    CombatTab:AddDisabledButton("Fling Murderer (Will be added soon)")

    CombatTab:AddDisabledButton("Fling Sheriff (Will be added soon)")
    
    CombatTab:AddToggle("Auto Kill All (Murderer)", false, function(v)
        if v then
            StartFeature("AutoKillAll", function(data)
                while data.active and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        if IsAlive(lp) and IsTargetable(lp) then
                            UpdateRoles()
                            if Roles.Murderer == lp then
                                local knife = lp.Character:FindFirstChild("Knife") or lp.Backpack:FindFirstChild("Knife")
                                if knife then
                                    if knife.Parent ~= lp.Character then
                                        lp.Character.Humanoid:EquipTool(knife)
                                        task.wait(0.1)
                                    end
                                    local handle = knife:FindFirstChild("Handle")
                                    local myHrp = lp.Character:FindFirstChild("HumanoidRootPart")
                                    if handle and myHrp then
                                        for _, p in pairs(Players:GetPlayers()) do
                                            if not data.active then break end
                                            if p ~= lp and IsTargetable(p) then
                                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                                local head = p.Character:FindFirstChild("Head")
                                                if hrp then
                                                    myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
                                                    myHrp.Velocity = Vector3.zero
                                                    pcall(function() knife:Activate() end)
                                                    task.wait(0.1)
                                                    for i = 1, 3 do
                                                        if not IsTargetable(p) or not data.active then break end
                                                        myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
                                                        myHrp.Velocity = Vector3.zero
                                                        firetouchinterest(handle, hrp, 0)
                                                        if head then firetouchinterest(handle, head, 0) end
                                                        firetouchinterest(handle, hrp, 1)
                                                        if head then firetouchinterest(handle, head, 1) end
                                                        task.wait(0.05)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        else
            StopFeature("AutoKillAll")
        end
    end)

    CombatTab:AddButton("Kill All Now (Murderer)", function()
        pcall(function()
            if IsAlive(lp) and IsTargetable(lp) then
                UpdateRoles()
                local knife = lp.Character:FindFirstChild("Knife") or lp.Backpack:FindFirstChild("Knife")
                if knife then
                    if knife.Parent ~= lp.Character then
                        lp.Character.Humanoid:EquipTool(knife)
                        task.wait(0.1)
                    end
                    local handle = knife:FindFirstChild("Handle")
                    local myHrp = lp.Character:FindFirstChild("HumanoidRootPart")
                    if handle and myHrp then
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= lp and IsTargetable(p) then
                                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                                local head = p.Character:FindFirstChild("Head")
                                if hrp then
                                    myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
                                    myHrp.Velocity = Vector3.zero
                                    pcall(function() knife:Activate() end)
                                    task.wait(0.1)
                                    for i = 1, 3 do
                                        if not IsTargetable(p) then break end
                                        myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 2)
                                        myHrp.Velocity = Vector3.zero
                                        firetouchinterest(handle, hrp, 0)
                                        if head then firetouchinterest(handle, head, 0) end
                                        firetouchinterest(handle, hrp, 1)
                                        if head then firetouchinterest(handle, head, 1) end
                                        task.wait(0.05)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end)
    
    CombatTab:AddToggle("Aimlock Murderer (Right Click)", false, function(v)
        if v then
            StartFeature("AimlockMurderer", function(data)
                local uis = game:GetService("UserInputService")
                local rightClicking = false
                
                local inputBegan = uis.InputBegan:Connect(function(input, gpe)
                    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
                        rightClicking = true
                    end
                end)
                local inputEnded = uis.InputEnded:Connect(function(input, gpe)
                    if input.UserInputType == Enum.UserInputType.MouseButton2 then
                        rightClicking = false
                    end
                end)
                table.insert(data.connections, inputBegan)
                table.insert(data.connections, inputEnded)
                
                local rs = game:GetService("RunService")
                local loop = rs.RenderStepped:Connect(function()
                    if rightClicking and IsAlive(lp) then
                        UpdateRoles()
                        local hasGun = lp.Character:FindFirstChild("Gun") or lp.Backpack:FindFirstChild("Gun")
                        if (hasGun or Roles.Sheriff == lp or Roles.Hero == lp) and Roles.Murderer and IsAlive(Roles.Murderer) then
                            local cam = workspace.CurrentCamera
                            local mHRP = Roles.Murderer.Character:FindFirstChild("HumanoidRootPart")
                            local mHead = Roles.Murderer.Character:FindFirstChild("Head") or mHRP
                            if mHead then
                                local targetCFrame = CFrame.lookAt(cam.CFrame.Position, mHead.Position)
                                cam.CFrame = cam.CFrame:Lerp(targetCFrame, 0.5)
                            end
                        end
                    end
                end)
                table.insert(data.connections, loop)
                while data.active and not _G.CrystalHub_Unloaded do task.wait(1) end
            end)
        else
            StopFeature("AimlockMurderer")
        end
    end)
    
    local function TeleportToLobby()
        if IsAlive(lp) then
            local lobby = workspace:FindFirstChild("Lobby") or workspace:FindFirstChild("RegularLobby") or workspace:FindFirstChild("Normal")
            local teleported = false
            if lobby then
                local spawns = lobby:FindFirstChild("Spawns")
                if spawns and #spawns:GetChildren() > 0 then
                    local spawnList = spawns:GetChildren()
                    lp.Character:PivotTo(spawnList[math.random(1, #spawnList)].CFrame + Vector3.new(0, 3, 0))
                    teleported = true
                elseif lobby:FindFirstChild("SpawnLocation") then
                    lp.Character:PivotTo(lobby.SpawnLocation.CFrame + Vector3.new(0, 3, 0))
                    teleported = true
                end
            end
            if not teleported then
                lp.Character:PivotTo(CFrame.new(-109.56, 140, 18.28))
            end
        end
    end
    local teleportToLobbyOnFull = false
    FarmTab:AddToggle("Auto Lobby (Bag Full)", false, function(v)
        teleportToLobbyOnFull = v
    end)

    FarmTab:AddToggle("Avoid Murderer (Auto Farm)", false, function(v)
        avoidMurderer = v
    end)

    FarmTab:AddToggle("Auto Farm Coins", false, function(v)
        if v and coinESPToggle then
            pcall(function() coinESPToggle:Set(true) end)
            pcall(function() coinESPToggle.Set(true) end)
        end
        if v then
            StartFeature("AutoFarmCoins", function(data)
                local isFarming = false
                local ts = game:GetService("TweenService")
                local currentTween = nil
                data.cache.disableNoclip = false
                
                data.cleanup = function()
                    isFarming = false
                    if currentTween then currentTween:Cancel() end
                    pcall(function()
                        if IsAlive(lp) then
                            lp.Character.HumanoidRootPart.Anchored = false
                        end
                    end)
                end
                
                local noclipCon = game:GetService("RunService").Stepped:Connect(function()
                    if isFarming and IsAlive(lp) and not data.cache.disableNoclip then
                        for _, p in pairs(lp.Character:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end
                end)
                table.insert(data.connections, noclipCon)
                
                local function IsBagFull()
                    local gui = lp.PlayerGui:FindFirstChild("MainGUI")
                    if gui and gui:FindFirstChild("Game") then
                        for _, d in pairs(gui.Game:GetDescendants()) do
                            if d:IsA("TextLabel") and (d.Name == "CoinText" or d.Name == "Coins") then
                                local txt = tostring(d.Text)
                                if txt == "40" or txt == "50" or txt:match("Max") or txt:match("Full") then
                                    return true
                                end
                            end
                        end
                    end
                    return false
                end
                
                local ignoredCoins = {}
                while data.active and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        if not IsAlive(lp) or not IsTargetable(lp) then
                            isFarming = false
                            data.cache.originalPos = nil
                            ignoredCoins = {}
                            task.wait(1)
                            return
                        end
                        
                        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                        if not hrp then task.wait(0.5) return end
                        
                        if not isFarming and not data.cache.originalPos then
                            data.cache.originalPos = hrp.CFrame
                        end
                        
                        if IsBagFull() then
                            if isFarming and data.cache.originalPos and IsAlive(lp) then
                                local bp = hrp:FindFirstChild("SmoothFlyBP")
                                if bp then bp:Destroy() end
                                local bg = hrp:FindFirstChild("SmoothFlyBG")
                                if bg then bg:Destroy() end
                                lp.Character.Humanoid.PlatformStand = false
                                hrp.Anchored = false
                                if teleportToLobbyOnFull then
                                    TeleportToLobby()
                                else
                                    lp.Character:PivotTo(data.cache.originalPos)
                                end
                            end
                            isFarming = false
                            data.cache.originalPos = nil
                            ignoredCoins = {}
                            task.wait(2)
                            return
                        end
                        
                        if avoidMurderer then UpdateRoles() end
                        
                        local coins = GetCoins()
                        if #coins == 0 then
                            if isFarming and data.cache.originalPos and IsAlive(lp) then
                                hrp.Anchored = false
                                lp.Character:PivotTo(data.cache.originalPos)
                            end
                            isFarming = false
                            data.cache.originalPos = nil
                            task.wait(1)
                            return
                        end
                        
                        isFarming = true
                        
                        local coin = nil
                        local bestDist = math.huge
                        for _, obj in pairs(coins) do
                            if not ignoredCoins[obj] then
                                local avoid = false
                                local tPart = GetCoinTargetPart(obj)
                                local tPos = (tPart and tPart:IsA("BasePart")) and tPart.Position or obj:GetPivot().Position
                                
                                if avoidMurderer and Roles.Murderer and IsAlive(Roles.Murderer) then
                                    local mHRP = Roles.Murderer.Character:FindFirstChild("HumanoidRootPart")
                                    if mHRP and (tPos - mHRP.Position).Magnitude < 45 then
                                        avoid = true
                                    end
                                end
                                
                                if not avoid then
                                    local d = (hrp.Position - tPos).Magnitude
                                    if d < bestDist then
                                        bestDist = d
                                        coin = obj
                                    end
                                end
                            end
                        end
                        
                        if not coin then
                            local evaded = false
                            if avoidMurderer and Roles.Murderer and IsAlive(Roles.Murderer) then
                                local mHRP = Roles.Murderer.Character:FindFirstChild("HumanoidRootPart")
                                if mHRP and (hrp.Position - mHRP.Position).Magnitude < 40 then
                                    evaded = true
                                    isFarming = true
                                    lp.Character.Humanoid.PlatformStand = true
                                    data.cache.disableNoclip = false
                                    
                                    local bp = hrp:FindFirstChild("SmoothFlyBP") or Instance.new("BodyPosition", hrp)
                                    bp.Name = "SmoothFlyBP"
                                    bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                    bp.P = 3000
                                    bp.D = 400
                                    
                                    local bg = hrp:FindFirstChild("SmoothFlyBG") or Instance.new("BodyGyro", hrp)
                                    bg.Name = "SmoothFlyBG"
                                    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                                    bg.P = 3000
                                    bg.D = 400
                                    
                                    local escapeDir = (hrp.Position - mHRP.Position)
                                    escapeDir = Vector3.new(escapeDir.X, 0, escapeDir.Z).Unit
                                    if escapeDir.Magnitude ~= escapeDir.Magnitude then escapeDir = Vector3.new(1,0,0) end
                                    bp.Position = hrp.Position + (escapeDir * 20) + Vector3.new(0, 20, 0)
                                    bg.CFrame = CFrame.new(hrp.Position, hrp.Position + escapeDir)
                                    task.wait(0.2)
                                end
                            end
                            
                            if next(ignoredCoins) then
                                ignoredCoins = {}
                                if not evaded then task.wait(0.5) end
                                return
                            end
                            
                            if not evaded then
                                if isFarming and data.cache.originalPos and IsAlive(lp) then
                                    local bp = hrp:FindFirstChild("SmoothFlyBP")
                                    if bp then bp:Destroy() end
                                    local bg = hrp:FindFirstChild("SmoothFlyBG")
                                    if bg then bg:Destroy() end
                                    lp.Character.Humanoid.PlatformStand = false
                                    
                                    hrp.Anchored = false
                                    lp.Character:PivotTo(data.cache.originalPos)
                                end
                                isFarming = false
                                data.cache.originalPos = nil
                                task.wait(1)
                            end
                            return
                        end
                        
                        if coin and coin.Parent then
                            local tPart = GetCoinTargetPart(coin)
                            local targetPos = (tPart and tPart:IsA("BasePart")) and tPart.Position or coin:GetPivot().Position
                            
                            hrp.Anchored = false
                            lp.Character.Humanoid.PlatformStand = true
                            
                            local bp = hrp:FindFirstChild("SmoothFlyBP")
                            if not bp then
                                bp = Instance.new("BodyPosition")
                                bp.Name = "SmoothFlyBP"
                                bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                                bp.P = 3000
                                bp.D = 400
                                bp.Parent = hrp
                            end
                            
                            local bg = hrp:FindFirstChild("SmoothFlyBG")
                            if not bg then
                                bg = Instance.new("BodyGyro")
                                bg.Name = "SmoothFlyBG"
                                bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                                bg.P = 3000
                                bg.D = 400
                                bg.Parent = hrp
                            end
                            
                            local stuckTime = 0
                            local totalTime = 0
                            while data.active and coin and coin.Parent and IsAlive(lp) do
                                if avoidMurderer then UpdateRoles() end
                                if avoidMurderer and Roles.Murderer and IsAlive(Roles.Murderer) then
                                    local mHRP = Roles.Murderer.Character:FindFirstChild("HumanoidRootPart")
                                    if mHRP then
                                        local distToCoin = (targetPos - mHRP.Position).Magnitude
                                        local distToPlayer = (hrp.Position - mHRP.Position).Magnitude
                                        
                                        if distToPlayer < 40 then
                                            data.cache.disableNoclip = false
                                            local escapeDir = (hrp.Position - mHRP.Position)
                                            escapeDir = Vector3.new(escapeDir.X, 0, escapeDir.Z).Unit
                                            if escapeDir.Magnitude ~= escapeDir.Magnitude then escapeDir = Vector3.new(1,0,0) end
                                            bp.Position = hrp.Position + (escapeDir * 20) + Vector3.new(0, 20, 0)
                                            bg.CFrame = CFrame.new(hrp.Position, hrp.Position + escapeDir)
                                            task.wait(0.1)
                                            continue
                                        end
                                        
                                        if distToCoin < 45 then
                                            ignoredCoins[coin] = true
                                            break
                                        end
                                    end
                                end
                                
                                local tPart = GetCoinTargetPart(coin)
                                local realTargetPos = (tPart and tPart:IsA("BasePart")) and tPart.Position or coin:GetPivot().Position
                                
                                bp.Position = realTargetPos
                                
                                local lookPos = Vector3.new(realTargetPos.X, hrp.Position.Y, realTargetPos.Z)
                                if (lookPos - hrp.Position).Magnitude > 0.1 then
                                    bg.CFrame = CFrame.new(hrp.Position, lookPos)
                                end
                                
                                local currentDist = (hrp.Position - realTargetPos).Magnitude
                                
                                if currentDist > 4 then
                                    data.cache.disableNoclip = false
                                else
                                    data.cache.disableNoclip = true
                                    stuckTime = stuckTime + 0.05
                                end
                                
                                if tPart and tPart:IsA("BasePart") then
                                    pcall(function()
                                        firetouchinterest(hrp, tPart, 0)
                                        task.wait()
                                        firetouchinterest(hrp, tPart, 1)
                                    end)
                                end
                                
                                for _, d in ipairs(coin:GetDescendants()) do
                                    if d:IsA("BasePart") then
                                        pcall(function()
                                            firetouchinterest(hrp, d, 0)
                                            task.wait()
                                            firetouchinterest(hrp, d, 1)
                                        end)
                                    end
                                end
                                
                                if stuckTime > 1.5 then
                                    ignoredCoins[coin] = true
                                    break
                                end
                                
                                totalTime = totalTime + 0.05
                                if totalTime > 3 then
                                    ignoredCoins[coin] = true
                                    break
                                end
                                
                                task.wait(0.05)
                            end
                            
                            if IsAlive(lp) then
                                hrp.Velocity = Vector3.zero
                                data.cache.disableNoclip = false
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        else
            StopFeature("AutoFarmCoins")
            if IsAlive(lp) then
                local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bp = hrp:FindFirstChild("SmoothFlyBP")
                    if bp then bp:Destroy() end
                    local bg = hrp:FindFirstChild("SmoothFlyBG")
                    if bg then bg:Destroy() end
                end
                lp.Character.Humanoid.PlatformStand = false
            end
        end
    end)
    
    
    FarmTab:AddToggle("Auto Pick Gun Drop", false, function(v)
        if v then
            StartFeature("AutoPickGunDrop", function(data)
                while data.active and not _G.CrystalHub_Unloaded do
                    pcall(function()
                        if IsAlive(lp) then
                            local hrp = lp.Character.HumanoidRootPart
                            local gunDrop = GetGunDrop()
                            if gunDrop then
                                local targetPos = gunDrop:IsA("Model") and gunDrop:GetPivot() or gunDrop.CFrame
                                local oldPos = hrp.CFrame
                                hrp.CFrame = targetPos
                                task.wait(0.2)
                                
                                local touchPart = gunDrop:IsA("Model") and gunDrop.PrimaryPart or gunDrop
                                if touchPart then
                                    firetouchinterest(hrp, touchPart, 0)
                                    task.wait(0.05)
                                    firetouchinterest(hrp, touchPart, 1)
                                end
                                
                                task.wait(0.2)
                                if IsAlive(lp) then
                                    hrp.CFrame = oldPos
                                end
                                task.wait(1)
                            end
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        else
            StopFeature("AutoPickGunDrop")
        end
    end)
    
    TeleportsTab:AddButton("Teleport to Lobby", function()
        TeleportToLobby()
    end)
    
    TeleportsTab:AddButton("Teleport to Map", function()
        if IsAlive(lp) then
            local map = GetMM2Map()
            if map then
                local spawns = map:FindFirstChild("Spawns")
                if spawns and #spawns:GetChildren() > 0 then
                    local spawnList = spawns:GetChildren()
                    lp.Character:PivotTo(spawnList[math.random(1, #spawnList)].CFrame + Vector3.new(0, 5, 0))
                else
                    local coins = map:FindFirstChild("CoinContainer")
                    if coins and #coins:GetChildren() > 0 then
                        lp.Character:PivotTo(coins:GetChildren()[1].CFrame + Vector3.new(0, 5, 0))
                    else
                        lp.Character:PivotTo(map:GetModelCFrame() + Vector3.new(0, 5, 0))
                    end
                end
            end
        end
    end)
    
    TeleportsTab:AddButton("Teleport to Murderer", function()
        GetRoles()
        if IsAlive(Roles.Murderer) and IsAlive(lp) then
            lp.Character:PivotTo(Roles.Murderer.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end)
    
    TeleportsTab:AddButton("Teleport to Sheriff", function()
        GetRoles()
        if IsAlive(Roles.Sheriff) and IsAlive(lp) then
            lp.Character:PivotTo(Roles.Sheriff.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3))
        end
    end)

    TeleportsTab:AddButton("Instant Teleport to Gun Drop", function()
        local gunDrop = GetGunDrop()
        if gunDrop and IsAlive(lp) then
            local targetPos = gunDrop:IsA("Model") and gunDrop:GetPivot() or gunDrop.CFrame
            lp.Character:PivotTo(targetPos + Vector3.new(0, 5, 0))
        end
    end)

    local flying = false
    _G.FlySpeed = 50
    _G.WalkSpeed = 16
    _G.JumpPower = 50

    MovementTab:AddToggle("Fly", false, function(v)
        flying = v
        if flying then
            StartFeature("FlyFeature", function(data)
                local uis = game:GetService("UserInputService")
                local rs = game:GetService("RunService")
                
                local bv = Instance.new("BodyVelocity")
                local bg = Instance.new("BodyGyro")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.zero
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                
                table.insert(data.instances, bv)
                table.insert(data.instances, bg)
                
                local loop = rs.RenderStepped:Connect(function()
                    if not IsAlive(lp) then return end
                    local char = lp.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end
                    
                    if bv.Parent ~= hrp then bv.Parent = hrp end
                    if bg.Parent ~= hrp then bg.Parent = hrp end
                    
                    local cam = workspace.CurrentCamera
                    local moveDir = Vector3.zero
                    
                    if uis:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                    if uis:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                    if uis:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                    
                    if moveDir.Magnitude > 0 then
                        moveDir = moveDir.Unit
                    end
                    
                    bv.Velocity = moveDir * (_G.FlySpeed or 50)
                    bg.CFrame = cam.CFrame
                end)
                table.insert(data.connections, loop)
                while data.active and not _G.CrystalHub_Unloaded do task.wait(1) end
            end)
        else
            StopFeature("FlyFeature")
        end
    end)
    
    MovementTab:AddSlider("Fly Speed", 0, 200, 50, function(v)
        _G.FlySpeed = v
    end)
    
    MovementTab:AddToggle("Enable Walk Speed", false, function(v)
        if v then
            StartFeature("WalkSpeedMod", function(data)
                local rs = game:GetService("RunService")
                local loop = rs.Stepped:Connect(function()
                    if IsAlive(lp) then
                        lp.Character.Humanoid.WalkSpeed = _G.WalkSpeed or 16
                    end
                end)
                table.insert(data.connections, loop)
                while data.active and not _G.CrystalHub_Unloaded do task.wait(1) end
            end)
        else
            StopFeature("WalkSpeedMod")
            if IsAlive(lp) then
                lp.Character.Humanoid.WalkSpeed = 16
            end
        end
    end)
    
    MovementTab:AddSlider("Walk Speed", 0, 200, 16, function(v)
        _G.WalkSpeed = v
    end)
    
    MovementTab:AddToggle("Enable Jump Power", false, function(v)
        if v then
            StartFeature("JumpPowerMod", function(data)
                local rs = game:GetService("RunService")
                local loop = rs.Stepped:Connect(function()
                    if IsAlive(lp) then
                        lp.Character.Humanoid.UseJumpPower = true
                        lp.Character.Humanoid.JumpPower = _G.JumpPower or 50
                    end
                end)
                table.insert(data.connections, loop)
                while data.active and not _G.CrystalHub_Unloaded do task.wait(1) end
            end)
        else
            StopFeature("JumpPowerMod")
            if IsAlive(lp) then
                lp.Character.Humanoid.JumpPower = 50
            end
        end
    end)
    
    MovementTab:AddSlider("Jump Power", 0, 300, 50, function(v)
        _G.JumpPower = v
    end)
    
    MovementTab:AddToggle("Noclip", false, function(v)
        if v then
            StartFeature("NoclipMod", function(data)
                local rs = game:GetService("RunService")
                local loop = rs.Stepped:Connect(function()
                    if IsAlive(lp) then
                        for _, p in pairs(lp.Character:GetDescendants()) do
                            if p:IsA("BasePart") then
                                p.CanCollide = false
                            end
                        end
                    end
                end)
                table.insert(data.connections, loop)
                while data.active and not _G.CrystalHub_Unloaded do task.wait(1) end
            end)
        else
            StopFeature("NoclipMod")
        end
    end)

    MiscTab:AddButton("Unlock All Emotes", function()
        pcall(function()
            for _, v in pairs(getloadedmodules and getloadedmodules() or {}) do
                if v:IsA("ModuleScript") and (v.Name == "PlayerData" or v.Name == "ProfileData" or v.Name == "ClientData" or v.Name == "Emotes") then
                    pcall(function()
                        local data = require(v)
                        if type(data) == "table" and data.Emotes and type(data.Emotes) == "table" then
                            if data.Emotes.Owned then
                                for _, emote in pairs({"ninja", "floss", "dab", "sit", "wave", "cheer", "laugh", "dance1", "dance2", "dance3", "zen", "zombie", "headless"}) do
                                    if not table.find(data.Emotes.Owned, emote) then
                                        table.insert(data.Emotes.Owned, emote)
                                    end
                                end
                            end
                        end
                    end)
                end
            end
        end)
        pcall(function()
            local invEvent = game:GetService("ReplicatedStorage").Remotes.Inventory:FindFirstChild("InventoryDataChanged")
            if invEvent then
                local allEmotes = {"ninja", "floss", "dab", "sit", "wave", "cheer", "laugh", "dance1", "dance2", "dance3", "zen", "zombie", "headless"}
                invEvent:Fire("Emotes", allEmotes, {})
            end
            local forceUpdate = game:GetService("ReplicatedStorage").Remotes.Inventory:FindFirstChild("ForceUpdate")
            if forceUpdate then forceUpdate:Fire() end
        end)
    end)

    MiscTab:AddDropdown("Play Emote", {"headless", "zombie", "zen", "ninja", "floss", "dab", "sit", "wave", "cheer", "laugh", "dance1", "dance2", "dance3"}, "ninja", function(v)
        pcall(function()
            local remote = game:GetService("ReplicatedStorage").Remotes.Misc:FindFirstChild("PlayEmote")
            if remote then
                if remote:IsA("BindableEvent") then
                    remote:Fire(v)
                elseif remote:IsA("RemoteEvent") then
                    remote:FireServer(v)
                elseif remote:IsA("RemoteFunction") then
                    remote:InvokeServer(v)
                end
            end
        end)
    end)
end

SettingsTab = Window:MakeTab("Settings", "rbxassetid://6031280882")

SettingsTab:AddBind("Toggle UI Keybind", CrystalUI.ToggleKey, function(key)
    CrystalUI.ToggleKey = key
end)

local antiAfkConnection
SettingsTab:AddToggle('Anti-AFK', false, function(v)
    if v then
        local vu = game:GetService('VirtualUser')
        antiAfkConnection = lp.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        end)
    else
        if antiAfkConnection then antiAfkConnection:Disconnect() end
    end
end)

SettingsTab:AddButton('Rejoin Server', function()
    game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
end)

SettingsTab:AddButton('Copy Discord Link', function()
    if setclipboard then setclipboard('https://discord.gg/F8U3JA8tnp') end
end)

SettingsTab:AddButton("Unload Script", function()
    _G.CrystalHub_Unloaded = true
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    if espOk then ESP.Enabled = false end
    if aimbotConnection then aimbotConnection:Disconnect() end
    local sgUI = (gethui and gethui():FindFirstChild("CrystalUltraModern")) or CoreGui:FindFirstChild("CrystalUltraModern") or lp:WaitForChild("PlayerGui"):FindFirstChild("CrystalUltraModern")
    if sgUI then sgUI:Destroy() end
    local splashUI = (gethui and gethui():FindFirstChild("CrystalSplash")) or CoreGui:FindFirstChild("CrystalSplash") or lp:WaitForChild("PlayerGui"):FindFirstChild("CrystalSplash")
    if splashUI then splashUI:Destroy() end
end)
