-- [[ Spookie.UI — ULTIMATE STANDALONE ALL-IN-ONE RAGE SCRIPT ]] --
-- Engine Version: 1.1.0
-- Everything in 1 single file for immediate execution in Roblox Executor!

local RageLibrary = {
    Enabled = true,
    CurrentThemeName = "Crimson Rage",
    Themes = {
        ["Crimson Rage"] = {
            Background = Color3.fromRGB(10, 10, 10),      -- Pitch Black (#0A0A0A)
            Block = Color3.fromRGB(14, 14, 14),           -- Dark Charcoal (#0E0E0E)
            Header = Color3.fromRGB(18, 18, 18),          -- Dark Slate (#121212)
            Card = Color3.fromRGB(16, 16, 16),            -- Card Grey (#101010)
            CardHover = Color3.fromRGB(24, 24, 24),       -- Hover Card Slate (#181818)
            RowHover = Color3.fromRGB(20, 20, 20),        -- Soft Row Highlight (#141414)
            Accent = Color3.fromRGB(255, 45, 70),         -- Eye-Friendly Vivid Crimson Red (#FF2D46)
            AccentDim = Color3.fromRGB(180, 20, 35),
            Text = Color3.fromRGB(255, 255, 255),         -- Pure Crisp White (#FFFFFF)
            TextDim = Color3.fromRGB(180, 180, 180),      -- Light Silver White (#B4B4B4)
            TextHover = Color3.fromRGB(255, 255, 255),    -- Pure White Glow (#FFFFFF)
            Stroke = Color3.fromRGB(22, 22, 22),          -- Subtle Dark Border (#161616)
            StrokeActive = Color3.fromRGB(32, 32, 32),     -- Subtle Slate (#202020)
            StrokeHover = Color3.fromRGB(32, 32, 32),
        }
    },
    Theme = nil,
    Fonts = {
        Header = Enum.Font.GothamBold,
        Label = Enum.Font.GothamMedium,
        Badge = Enum.Font.GothamMedium,
    },
    Sounds = {
        Init = "rbxassetid://136440776569658",
        Click = "rbxassetid://139719503904449",
        ToggleOn = "rbxassetid://15675059323",
        ToggleOff = "rbxassetid://87437544236708",
        OpenMenu = "rbxassetid://127366656618533",
        CloseMenu = "rbxassetid://139295675611093",
        Notification = "rbxassetid://6895092003",
        Hitmark = "rbxassetid://160432334",
        Slider = "rbxassetid://136994329700115",
        Dropdown = "rbxassetid://103866342467024"
    },
    Icons = {
        Logo            = "rbxassetid://122540234795087",
        BackgroundImage = "rbxassetid://8372959577",
        Combat          = "rbxassetid://12614416478",      
        Movement        = "rbxassetid://136160678435000", 
        Visuals         = "rbxassetid://102976018150012", 
        Misc            = "rbxassetid://137382232901580", 
        World           = "rbxassetid://122563205713088",
        Auto            = "rbxassetid://102927017461693",
        Guns            = "rbxassetid://84647432170503",
        Skins           = "rbxassetid://101708694952341",
        Keybinds        = "rbxassetid://11738672671"
    },
    ToggleKey = Enum.KeyCode.RightShift,
    ListeningKeybind = false,
    Connections = {},
    Blocks = {},
    KeybindList = {},
    ConfigFolder = "Rage/Configs"
}

RageLibrary.Theme = RageLibrary.Themes["Crimson Rage"]

-- Services & Local Player
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Duration Constants
local DUR_FAST = 0.15
local DUR_NORMAL = 0.25

-- Cache TweenInfo objects (avoids creating new instances on every tween)
local _tweenCache = {}
local function smoothTween(inst, dur, props)
    if not inst or not inst.Parent then return end
    dur = dur or DUR_NORMAL
    local cached = _tweenCache[dur]
    if not cached then
        cached = TweenInfo.new(dur, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        _tweenCache[dur] = cached
    end
    local tween = TweenService:Create(inst, cached, props)
    tween:Play()
    return tween
end

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = parent
    return corner
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or RageLibrary.Theme.Stroke
    stroke.Thickness = thickness or 1
    stroke.Parent = parent
    return stroke
end

local function makeDraggable(frame, dragHandle)
    dragHandle = dragHandle or frame
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    -- Use InputChanged directly for minimal latency during drag (no tween overhead)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Sound System Engine (uses task.spawn for zero-latency async execution)
local SoundService = game:GetService("SoundService")
RageLibrary.IsMenuVisible = true

-- Automatic 5-Second Memory Cleaner & Garbage Collector Loop
task.spawn(function()
    while true do
        task.wait(5)
        pcall(function()
            if collectgarbage then
                collectgarbage("collect")
            end
        end)
    end
end)

function RageLibrary:PlaySound(soundName)
    local soundId = self.Sounds[soundName] or soundName
    if not soundId or soundId == "" then return end

    -- Mute toggle ON/OFF, click, and slider sounds when the menu is hidden
    if RageLibrary.IsMenuVisible == false and (soundName == "ToggleOn" or soundName == "ToggleOff" or soundName == "Click" or soundName == "Slider") then
        return
    end

    task.spawn(function()
        local s = Instance.new("Sound")
        s.SoundId = soundId
        s.Volume = 2.0
        s.PlaybackSpeed = 1.0
        s.Parent = SoundService
        s:Play()
        s.Ended:Wait()
        task.delay(0.2, function()
            if s and s.Parent then s:Destroy() end
        end)
    end)
end

-- Parent Container Resolution
local ParentContainer = nil
pcall(function()
    if gethui then ParentContainer = gethui() end
end)
if not ParentContainer then
    pcall(function() ParentContainer = CoreGui end)
end
if not ParentContainer and LocalPlayer then
    ParentContainer = LocalPlayer:WaitForChild("PlayerGui")
end

-- Clean old instances
pcall(function()
    if ParentContainer:FindFirstChild("RageLibraryGUI") then
        ParentContainer.RageLibraryGUI:Destroy()
    end
end)

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RageLibraryGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 99999999
ScreenGui.Parent = ParentContainer

-- =================================================================
-- CLEAN & ELEGANT WATERMARK WIDGET
-- =================================================================
local Watermark = Instance.new("Frame")
Watermark.Name = "RageWatermark"
Watermark.Size = UDim2.new(0, 350, 0, 22)
Watermark.Position = UDim2.new(1, -360, 0, 10)
Watermark.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Watermark.BorderSizePixel = 0
Watermark.ClipsDescendants = true
Watermark.Parent = ScreenGui
addCorner(Watermark, 8)
local WMarkStroke = addStroke(Watermark, RageLibrary.Theme.Stroke, 1)

local WMarkContent = Instance.new("Frame")
WMarkContent.Size = UDim2.new(1, -36, 1, 0)
WMarkContent.Position = UDim2.new(0, 14, 0, 0)
WMarkContent.BackgroundTransparency = 1
WMarkContent.Parent = Watermark

local WMarkLayout = Instance.new("UIListLayout")
WMarkLayout.FillDirection = Enum.FillDirection.Horizontal
WMarkLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
WMarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WMarkLayout.SortOrder = Enum.SortOrder.LayoutOrder
WMarkLayout.Padding = UDim.new(0, 10)
WMarkLayout.Parent = WMarkContent

-- 1. Logo Icon & Name
local LogoImg = Instance.new("ImageLabel")
LogoImg.Size = UDim2.new(0, 14, 0, 14)
LogoImg.BackgroundTransparency = 1
LogoImg.Image = RageLibrary.Icons.Logo
LogoImg.ImageColor3 = RageLibrary.Theme.Accent
LogoImg.LayoutOrder = 1
LogoImg.Parent = WMarkContent

local WMarkName = Instance.new("TextLabel")
WMarkName.Size = UDim2.new(0, 75, 1, 0)
WMarkName.BackgroundTransparency = 1
WMarkName.Font = Enum.Font.GothamBold
WMarkName.Text = "Spookie.UI"
WMarkName.TextColor3 = Color3.fromRGB(255, 255, 255)
WMarkName.TextSize = 10
WMarkName.TextXAlignment = Enum.TextXAlignment.Left
WMarkName.LayoutOrder = 2
WMarkName.Parent = WMarkContent

-- 2. Profile Avatar & Player Username (Avatar IMMEDIATELY to the left of Nickname!)
local AvatarHolder = Instance.new("Frame")
AvatarHolder.Size = UDim2.new(0, 14, 0, 14)
AvatarHolder.BackgroundTransparency = 1
AvatarHolder.LayoutOrder = 3
AvatarHolder.Parent = WMarkContent

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(1, 0, 1, 0)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = "rbxassetid://0"
AvatarImg.Parent = AvatarHolder
addCorner(AvatarImg, 7)

if LocalPlayer then
    pcall(function()
        local content = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size48x48
        )
        AvatarImg.Image = content
    end)
end

local UserLabel = Instance.new("TextLabel")
UserLabel.Size = UDim2.new(0, 85, 1, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Font = Enum.Font.GothamMedium
UserLabel.Text = LocalPlayer and LocalPlayer.Name or "User"
UserLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
UserLabel.TextSize = 9.5
UserLabel.TextTruncate = Enum.TextTruncate.AtEnd
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.LayoutOrder = 4
UserLabel.Parent = WMarkContent

-- 3. FPS Counter
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 44, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.Text = "144 fps"
FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FPSLabel.TextSize = 9.5
FPSLabel.LayoutOrder = 5
FPSLabel.Parent = WMarkContent

-- 4. Ping Counter
local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 42, 1, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = Enum.Font.GothamMedium
PingLabel.Text = "15 ms"
PingLabel.TextColor3 = RageLibrary.Theme.TextDim
PingLabel.TextSize = 9.5
PingLabel.LayoutOrder = 6
PingLabel.Parent = WMarkContent

-- 5. Real-Time Clock
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0, 48, 1, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Font = Enum.Font.GothamMedium
TimeLabel.Text = os.date("%H:%M:%S")
TimeLabel.TextColor3 = RageLibrary.Theme.TextDim
TimeLabel.TextSize = 9.5
TimeLabel.LayoutOrder = 7
TimeLabel.Parent = WMarkContent

makeDraggable(Watermark, Watermark)

-- =================================================================
-- PERSISTENT KEYBIND LIST WIDGET (Always visible, does NOT hide with main menu)
-- =================================================================
local KeybindWidget = Instance.new("Frame")
KeybindWidget.Name = "RageKeybindList"
KeybindWidget.Size = UDim2.new(0, 140, 0, 24)
KeybindWidget.Position = UDim2.new(0, 10, 0.4, 0)
KeybindWidget.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
KeybindWidget.BorderSizePixel = 0
KeybindWidget.ClipsDescendants = true
KeybindWidget.Parent = ScreenGui
addCorner(KeybindWidget, 8)
addStroke(KeybindWidget, RageLibrary.Theme.Stroke, 1)
makeDraggable(KeybindWidget, KeybindWidget)

local KBTitleBar = Instance.new("Frame")
KBTitleBar.Size = UDim2.new(1, 0, 0, 22)
KBTitleBar.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
KBTitleBar.BorderSizePixel = 0
KBTitleBar.Parent = KeybindWidget
addCorner(KBTitleBar, 8)

local KBIcon = Instance.new("ImageLabel")
KBIcon.Size = UDim2.new(0, 12, 0, 12)
KBIcon.Position = UDim2.new(0, 7, 0.5, -6)
KBIcon.BackgroundTransparency = 1
KBIcon.Image = RageLibrary.Icons.Keybinds
KBIcon.ImageColor3 = RageLibrary.Theme.Accent
KBIcon.Parent = KBTitleBar

local KBTitle = Instance.new("TextLabel")
KBTitle.Size = UDim2.new(1, -24, 1, 0)
KBTitle.Position = UDim2.new(0, 23, 0, 0)
KBTitle.BackgroundTransparency = 1
KBTitle.Font = Enum.Font.GothamBold
KBTitle.Text = "Keybinds"
KBTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KBTitle.TextSize = 9.5
KBTitle.TextXAlignment = Enum.TextXAlignment.Left
KBTitle.Parent = KBTitleBar

local KBContainer = Instance.new("Frame")
KBContainer.Size = UDim2.new(1, -12, 0, 0)
KBContainer.Position = UDim2.new(0, 6, 0, 24)
KBContainer.BackgroundTransparency = 1
KBContainer.Parent = KeybindWidget

local KBLayout = Instance.new("UIListLayout")
KBLayout.SortOrder = Enum.SortOrder.LayoutOrder
KBLayout.Padding = UDim.new(0, 3)
KBLayout.Parent = KBContainer

local registeredKeybinds = {}

-- =================================================================
-- GLOBAL KEYBIND DISPATCHER (single connection instead of N per toggle)
-- All registered keybinds are dispatched from here for zero overhead
-- =================================================================
local function _isPointerOverGui(inputPos)
    if not inputPos then return false end
    local screenGui = ScreenGui
    for _, child in ipairs(screenGui:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then
            local cPos  = child.AbsolutePosition
            local cSize = child.AbsoluteSize
            if inputPos.X >= cPos.X and inputPos.X <= cPos.X + cSize.X and
               inputPos.Y >= cPos.Y and inputPos.Y <= cPos.Y + cSize.Y then
                return true
            end
        end
    end
    return false
end

local _keybindHandlers = {}
local _anyRebindActive = false
local _rebindCallbacks = {}

UserInputService.InputBegan:Connect(function(input, gpe)
    if _anyRebindActive and #_rebindCallbacks > 0 then
        local cb = _rebindCallbacks[1]
        if cb then cb(input) end
        return
    end
    if gpe then return end
    for _, item in ipairs(registeredKeybinds) do
        if item.getBindKey and item.getBindKey() then
            local key = item.getBindKey()
            local isMatch = false
            if typeof(key) == "EnumItem" then
                if key.EnumType == Enum.KeyCode and input.KeyCode == key then
                    isMatch = true
                elseif key.EnumType == Enum.UserInputType and input.UserInputType == key then
                    isMatch = true
                end
            end
            if isMatch then
                item.onInputBegan()
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if _anyRebindActive then return end
    for _, item in ipairs(registeredKeybinds) do
        if item.getBindKey and item.getBindKey() then
            local key = item.getBindKey()
            local isMatch = false
            if typeof(key) == "EnumItem" then
                if key.EnumType == Enum.KeyCode and input.KeyCode == key then
                    isMatch = true
                elseif key.EnumType == Enum.UserInputType and input.UserInputType == key then
                    isMatch = true
                end
            end
            if isMatch then
                item.onInputEnded()
            end
        end
    end
end)

local function startRebindCapture(callback)
    _anyRebindActive = true
    _rebindCallbacks[1] = function(input)
        local done = callback(input)
        if done then
            _rebindCallbacks[1] = nil
            _anyRebindActive = false
        end
    end
end

local function cancelRebindCapture()
    _rebindCallbacks[1] = nil
    _anyRebindActive = false
end

local function registerKeybindHandler(onBegan, onEnded)
    table.insert(_keybindHandlers, { onBegan = onBegan, onEnded = onEnded or function() end })
end

-- Pool of reusable keybind rows to avoid creating/destroying instances every refresh
local _kbRowPool = {}

local function refreshKeybindWidget()
    for _, child in ipairs(KBContainer:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local count = 0
    for _, item in ipairs(registeredKeybinds) do
        local bKey = item.getBindKey and item.getBindKey()
        local keyName = item.getKeyName and item.getKeyName() or "None"
        if bKey ~= nil and keyName ~= "None" then
            count = count + 1
            local Row = Instance.new("Frame")
            Row.Size = UDim2.new(1, 0, 0, 16)
            Row.BackgroundTransparency = 1
            Row.Parent = KBContainer

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Size = UDim2.new(1, -55, 1, 0)
            NameLbl.Position = UDim2.new(0, 2, 0, 0)
            NameLbl.BackgroundTransparency = 1
            NameLbl.Font = Enum.Font.GothamMedium
            NameLbl.Text = item.name
            NameLbl.TextColor3 = item.getState() and RageLibrary.Theme.Text or RageLibrary.Theme.TextDim
            NameLbl.TextSize = 8.5
            NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            NameLbl.TextXAlignment = Enum.TextXAlignment.Left
            NameLbl.Parent = Row

            local KeyLbl = Instance.new("TextLabel")
            KeyLbl.Size = UDim2.new(0, 50, 1, 0)
            KeyLbl.Position = UDim2.new(1, -52, 0, 0)
            KeyLbl.BackgroundTransparency = 1
            KeyLbl.Font = Enum.Font.GothamBold
            KeyLbl.Text = "[" .. keyName .. "]"
            KeyLbl.TextColor3 = item.getState() and RageLibrary.Theme.Accent or RageLibrary.Theme.TextDim
            KeyLbl.TextSize = 8.5
            KeyLbl.TextXAlignment = Enum.TextXAlignment.Right
            KeyLbl.Parent = Row
        end
    end

    local targetHeight = math.max(24, 24 + count * 18)
    smoothTween(KeybindWidget, DUR_FAST, { Size = UDim2.new(0, 140, 0, targetHeight) })
end

-- Play Init Sound on first frame (Disabled per user request)
-- task.defer(function()
--     RageLibrary:PlaySound("Init")
-- end)

-- Live Metrics Updater
local frameCount = 0
local lastFpsCheck = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsCheck >= 1 then
        FPSLabel.Text = frameCount .. " fps"
        frameCount = 0
        lastFpsCheck = now

        local pingMs = 0
        pcall(function()
            local stats = game:GetService("Stats")
            local dataPing = stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            if dataPing then pingMs = math.floor(dataPing:GetValue()) end
        end)
        PingLabel.Text = pingMs .. " ms"
        TimeLabel.Text = os.date("%H:%M:%S")
    end
end)

-- Main Cheat Window Factory Function
function RageLibrary:CreateWindow(config)
    config = config or {}
    local winTitle = config.Title or "Spookie.UI"
    local winSubTitle = config.SubTitle or "ROBLOX RAGE CLIENT V1.1"
    local winSize = config.Size or UDim2.new(0, 430, 0, 280)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "RageMainFrame"
    MainFrame.Size = winSize
    MainFrame.Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2 + 30)
    MainFrame.BackgroundColor3 = RageLibrary.Theme.Background
    MainFrame.BackgroundTransparency = 1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    addCorner(MainFrame, 8)
    local MainStroke = addStroke(MainFrame, RageLibrary.Theme.Stroke, 1.2)

    -- Entrance animation: slide up + fade in
    TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2)
    }):Play()

    -- Left Sidebar Navigation
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 120, 1, 0)
    Sidebar.BackgroundColor3 = RageLibrary.Theme.Block
    Sidebar.BackgroundTransparency = 0
    Sidebar.BorderSizePixel = 0
    Sidebar.ClipsDescendants = false
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 8)

    local SidebarLogo = Instance.new("ImageLabel")
    SidebarLogo.Size = UDim2.new(0, 16, 0, 16)
    SidebarLogo.Position = UDim2.new(0, 10, 0, 8)
    SidebarLogo.BackgroundTransparency = 1
    SidebarLogo.Image = RageLibrary.Icons.Logo
    SidebarLogo.ImageColor3 = RageLibrary.Theme.Accent
    SidebarLogo.Parent = Sidebar

    local LogoTitle = Instance.new("TextLabel")
    LogoTitle.Size = UDim2.new(1, -34, 0, 16)
    LogoTitle.Position = UDim2.new(0, 30, 0, 7)
    LogoTitle.BackgroundTransparency = 1
    LogoTitle.Font = RageLibrary.Fonts.Header
    LogoTitle.Text = winTitle
    LogoTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoTitle.TextSize = 10.5
    LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
    LogoTitle.Parent = Sidebar

    local LogoSub = Instance.new("TextLabel")
    LogoSub.Size = UDim2.new(1, -34, 0, 12)
    LogoSub.Position = UDim2.new(0, 30, 0, 22)
    LogoSub.BackgroundTransparency = 1
    LogoSub.Font = RageLibrary.Fonts.Label
    LogoSub.Text = winSubTitle
    LogoSub.TextColor3 = RageLibrary.Theme.TextDim
    LogoSub.TextSize = 7
    LogoSub.TextXAlignment = Enum.TextXAlignment.Left
    LogoSub.Parent = Sidebar

    -- Scrollable Sidebar Navigation Holder
    local NavHolder = Instance.new("ScrollingFrame")
    NavHolder.Size = UDim2.new(1, -8, 1, -42)
    NavHolder.Position = UDim2.new(0, 4, 0, 38)
    NavHolder.BackgroundTransparency = 1
    NavHolder.BorderSizePixel = 0
    NavHolder.ClipsDescendants = false
    NavHolder.ScrollBarThickness = 2
    NavHolder.ScrollBarImageColor3 = RageLibrary.Theme.Accent
    NavHolder.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavHolder

    local NavPadding = Instance.new("UIPadding")
    NavPadding.PaddingBottom = UDim.new(0, 6)
    NavPadding.Parent = NavHolder

    NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NavHolder.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Content Area (Right Side)
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -128, 1, -12)
    ContentArea.Position = UDim2.new(0, 124, 0, 6)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    makeDraggable(MainFrame, Sidebar)

    local WindowObj = {
        Tabs = {},
        ActiveTab = nil,
        MainFrame = MainFrame
    }

    function WindowObj:AddTab(tabName, iconId)
        local resolvedIcon = iconId or RageLibrary.Icons[tabName]

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3 = RageLibrary.Theme.Card
        TabBtn.BackgroundTransparency = 0
        TabBtn.BorderSizePixel = 0
        TabBtn.AutoButtonColor = false
        TabBtn.Text = ""
        TabBtn.Parent = NavHolder
        addCorner(TabBtn, 6)

        local TabIconImg = nil
        if resolvedIcon then
            TabIconImg = Instance.new("ImageLabel")
            TabIconImg.Size = UDim2.new(0, 16, 0, 16)
            TabIconImg.Position = UDim2.new(0, 10, 0.5, -8)
            TabIconImg.BackgroundTransparency = 1
            TabIconImg.Image = resolvedIcon
            TabIconImg.ImageColor3 = RageLibrary.Theme.TextDim
            TabIconImg.Parent = TabBtn
        end

        local TabTextLbl = Instance.new("TextLabel")
        TabTextLbl.Size = UDim2.new(1, -34, 1, 0)
        TabTextLbl.Position = UDim2.new(0, 32, 0, 0)
        TabTextLbl.BackgroundTransparency = 1
        TabTextLbl.Font = RageLibrary.Fonts.Header
        TabTextLbl.Text = tabName
        TabTextLbl.TextColor3 = RageLibrary.Theme.TextDim
        TabTextLbl.TextSize = 10.5
        TabTextLbl.TextXAlignment = Enum.TextXAlignment.Left
        TabTextLbl.Parent = TabBtn

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0, 18)
        TabIndicator.Position = UDim2.new(0, 3, 0.5, -9)
        TabIndicator.BackgroundColor3 = RageLibrary.Theme.Accent
        TabIndicator.Visible = false
        TabIndicator.Parent = TabBtn
        addCorner(TabIndicator, 2)

        -- Tab Hover Animation
        TabBtn.MouseEnter:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                smoothTween(TabBtn, DUR_FAST, { BackgroundTransparency = 0, BackgroundColor3 = RageLibrary.Theme.CardHover })
                smoothTween(TabTextLbl, DUR_FAST, { TextColor3 = RageLibrary.Theme.TextHover })
                if TabIconImg then smoothTween(TabIconImg, DUR_FAST, { ImageColor3 = RageLibrary.Theme.TextHover }) end
            end
        end)

        TabBtn.MouseLeave:Connect(function()
            if WindowObj.ActiveTab ~= TabObj then
                smoothTween(TabBtn, DUR_FAST, { BackgroundTransparency = 0, BackgroundColor3 = RageLibrary.Theme.Card })
                smoothTween(TabTextLbl, DUR_FAST, { TextColor3 = RageLibrary.Theme.TextDim })
                if TabIconImg then smoothTween(TabIconImg, DUR_FAST, { ImageColor3 = RageLibrary.Theme.TextDim }) end
            end
        end)

        local TabPage = Instance.new("Frame")
        TabPage.Name = "TabPage_" .. tabName
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = ContentArea

        -- Dual Columns: Left & Right Cards
        local LeftCol = Instance.new("ScrollingFrame")
        LeftCol.Size = UDim2.new(0.49, 0, 1, 0)
        LeftCol.Position = UDim2.new(0, 0, 0, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.BorderSizePixel = 0
        LeftCol.ScrollBarThickness = 3
        LeftCol.ScrollBarImageColor3 = RageLibrary.Theme.Accent
        LeftCol.Parent = TabPage

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 8)
        LeftLayout.Parent = LeftCol

        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            LeftCol.CanvasSize = UDim2.new(0, 0, 0, LeftLayout.AbsoluteContentSize.Y + 15)
        end)

        local RightCol = Instance.new("ScrollingFrame")
        RightCol.Size = UDim2.new(0.49, 0, 1, 0)
        RightCol.Position = UDim2.new(0.51, 0, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.BorderSizePixel = 0
        RightCol.ScrollBarThickness = 3
        RightCol.ScrollBarImageColor3 = RageLibrary.Theme.Accent
        RightCol.Parent = TabPage

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 8)
        RightLayout.Parent = RightCol

        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            RightCol.CanvasSize = UDim2.new(0, 0, 0, RightLayout.AbsoluteContentSize.Y + 15)
        end)

        local TabObj = {
            Name = tabName,
            Page = TabPage,
            LeftCol = LeftCol,
            RightCol = RightCol,
            IconImg = TabIconImg,
            TextLbl = TabTextLbl
        }

        local function selectTab()
            for _, child in ipairs(ScreenGui:GetChildren()) do
                if child.Name:sub(1, 9) == "ModeMenu_" or child.Name:sub(1, 9) == "DropList_" or child.Name:sub(1, 14) == "MultiDropList_" or child.Name:sub(1, 12) == "ColorPicker_" then
                    child.Visible = false
                end
            end
            for _, t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                smoothTween(t.Btn, DUR_FAST, { BackgroundTransparency = 0, BackgroundColor3 = RageLibrary.Theme.Card })
                smoothTween(t.TextLbl, DUR_FAST, { TextColor3 = RageLibrary.Theme.TextDim })
                if t.IconImg then
                    smoothTween(t.IconImg, DUR_FAST, { ImageColor3 = RageLibrary.Theme.TextDim })
                end
                t.Indicator.Visible = false
            end
            -- Fade-in TabPage with slight upward slide
            TabPage.Position = UDim2.new(0, 0, 0, 10)
            TabPage.BackgroundTransparency = 1
            TabPage.Visible = true
            smoothTween(TabPage, 0.22, { Position = UDim2.new(0, 0, 0, 0) })
            TabIndicator.Visible = true
            smoothTween(TabBtn, DUR_FAST, { BackgroundTransparency = 0, BackgroundColor3 = RageLibrary.Theme.CardHover })
            smoothTween(TabTextLbl, DUR_FAST, { TextColor3 = RageLibrary.Theme.Accent })
            if TabIconImg then
                smoothTween(TabIconImg, DUR_FAST, { ImageColor3 = RageLibrary.Theme.Accent })
            end
            WindowObj.ActiveTab = TabObj
            RageLibrary:PlaySound("Click")
        end

        TabBtn.MouseButton1Click:Connect(selectTab)

        TabObj.Btn = TabBtn
        TabObj.Indicator = TabIndicator

        if #WindowObj.Tabs == 0 then
            -- First tab: switch without playing Click sound (Init already played)
            for _, t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                t.Indicator.Visible = false
            end
            TabPage.Visible = true
            TabIndicator.Visible = true
            smoothTween(TabBtn, DUR_FAST, { BackgroundTransparency = 0, BackgroundColor3 = RageLibrary.Theme.CardHover })
            smoothTween(TabTextLbl, DUR_FAST, { TextColor3 = RageLibrary.Theme.Accent })
            if TabIconImg then smoothTween(TabIconImg, DUR_FAST, { ImageColor3 = RageLibrary.Theme.Accent }) end
            WindowObj.ActiveTab = TabObj
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:AddSection(secName, columnSide)
            columnSide = (columnSide and columnSide:lower() == "right") and "right" or "left"
            local parentCol = (columnSide == "right") and RightCol or LeftCol

            local Card = Instance.new("Frame")
            Card.Name = "Section_" .. secName
            Card.Size = UDim2.new(1, -4, 0, 36)
            Card.BackgroundColor3 = RageLibrary.Theme.Card
            Card.BackgroundTransparency = 1
            Card.BorderSizePixel = 0
            Card.Parent = parentCol
            addCorner(Card, 6)
            addStroke(Card, RageLibrary.Theme.Stroke, 1)
            -- Card entrance animation
            local cardIdx = #parentCol:GetChildren()
            task.delay(cardIdx * 0.05, function()
                smoothTween(Card, 0.3, { BackgroundTransparency = 0 })
            end)

            local CardTitle = Instance.new("TextLabel")
            CardTitle.Size = UDim2.new(1, -20, 0, 24)
            CardTitle.Position = UDim2.new(0, 10, 0, 6)
            CardTitle.BackgroundTransparency = 1
            CardTitle.Font = RageLibrary.Fonts.Header
            CardTitle.Text = string.upper(secName)
            CardTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            CardTitle.TextSize = 10
            CardTitle.TextXAlignment = Enum.TextXAlignment.Left
            CardTitle.Parent = Card

            local ItemsHolder = Instance.new("Frame")
            ItemsHolder.Size = UDim2.new(1, -16, 0, 0)
            ItemsHolder.Position = UDim2.new(0, 8, 0, 30)
            ItemsHolder.BackgroundTransparency = 1
            ItemsHolder.Parent = Card

            local ItemsLayout = Instance.new("UIListLayout")
            ItemsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemsLayout.Padding = UDim.new(0, 6)
            ItemsLayout.Parent = ItemsHolder

            local SectionObj = {}

            local function updateCardSize()
                local h = ItemsLayout.AbsoluteContentSize.Y
                Card.Size = UDim2.new(1, -4, 0, 36 + h)
                parentCol.CanvasSize = UDim2.new(0, 0, 0, (columnSide == "right" and RightLayout or LeftLayout).AbsoluteContentSize.Y + 20)
            end

            -- TOGGLE WITH RIGHT-CLICK KEYBIND MODE CONTEXT MENU (Hold / Toggle / Always)
            function SectionObj:AddToggle(cfg, legacyDefault, legacyCb)
                local name = type(cfg) == "table" and cfg.Name or cfg
                local state = (type(cfg) == "table" and (cfg.Default == true)) or (type(cfg) ~= "table" and (legacyDefault == true)) or false
                local callback = (type(cfg) == "table" and cfg.Callback) or legacyCb
                local bindKey = type(cfg) == "table" and cfg.Keybind or nil
                local bindMode = type(cfg) == "table" and (cfg.Mode or "Toggle") or "Toggle"
                local cpColor = type(cfg) == "table" and (cfg.Colorpicker or cfg.ColorPicker or cfg.Color) or nil
                local cpCallback = type(cfg) == "table" and (cfg.ColorCallback or cfg.ColorpickerCallback) or nil

                local ToggleRow = Instance.new("Frame")
                ToggleRow.Size = UDim2.new(1, 0, 0, 30)
                ToggleRow.BackgroundColor3 = RageLibrary.Theme.Block
                ToggleRow.BackgroundTransparency = 1
                ToggleRow.BorderSizePixel = 0
                ToggleRow.Parent = ItemsHolder
                addCorner(ToggleRow, 6)
                local ToggleStroke = addStroke(ToggleRow, RageLibrary.Theme.Stroke, 1)
                -- Row entrance animation (fade in)
                local rowIdx = #ItemsHolder:GetChildren()
                task.delay(0.08 + rowIdx * 0.04, function()
                    smoothTween(ToggleRow, 0.25, { BackgroundTransparency = 0.12 })
                end)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -155, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleRow

                -- Controls Holder Container (Switch + Keybind Badge + Colorpicker)
                local ControlsHolder = Instance.new("Frame")
                ControlsHolder.Size = UDim2.new(0, 145, 1, 0)
                ControlsHolder.Position = UDim2.new(1, -150, 0, 0)
                ControlsHolder.BackgroundTransparency = 1
                ControlsHolder.Parent = ToggleRow

                local ControlsLayout = Instance.new("UIListLayout")
                ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
                ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                ControlsLayout.Padding = UDim.new(0, 6)
                ControlsLayout.Parent = ControlsHolder

                -- Inline Colorpicker (rendered to the left of switch and keybind)
                if cpColor then
                    local currentColor = typeof(cpColor) == "Color3" and cpColor or Color3.fromRGB(255, 45, 70)
                    local h, s, v = Color3.toHSV(currentColor)

                    local ColorBadge = Instance.new("TextButton")
                    ColorBadge.Size = UDim2.new(0, 26, 0, 15)
                    ColorBadge.BackgroundColor3 = currentColor
                    ColorBadge.BorderSizePixel = 0
                    ColorBadge.LayoutOrder = 1
                    ColorBadge.Text = ""
                    ColorBadge.Parent = ControlsHolder
                    addCorner(ColorBadge, 5)
                    addStroke(ColorBadge, RageLibrary.Theme.Stroke, 1)

                    local ColorPickerBox = Instance.new("Frame")
                    ColorPickerBox.Name = "ColorPicker_" .. name
                    ColorPickerBox.Size = UDim2.new(0, 160, 0, 150)
                    ColorPickerBox.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
                    ColorPickerBox.BorderSizePixel = 0
                    ColorPickerBox.Visible = false
                    ColorPickerBox.ZIndex = 25000
                    ColorPickerBox.Parent = ScreenGui
                    addCorner(ColorPickerBox, 6)
                    addStroke(ColorPickerBox, RageLibrary.Theme.Stroke, 1.2)

                    local SVBox = Instance.new("ImageLabel")
                    SVBox.Size = UDim2.new(0, 120, 0, 120)
                    SVBox.Position = UDim2.new(0, 10, 0, 10)
                    SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    SVBox.BorderSizePixel = 0
                    SVBox.Image = "rbxassetid://4155801252"
                    SVBox.ZIndex = 25001
                    SVBox.Parent = ColorPickerBox
                    addCorner(SVBox, 4)

                    local SVCursor = Instance.new("Frame")
                    SVCursor.Size = UDim2.new(0, 6, 0, 6)
                    SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
                    SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    SVCursor.BorderSizePixel = 0
                    SVCursor.ZIndex = 25002
                    SVCursor.Parent = SVBox
                    addCorner(SVCursor, 3)
                    addStroke(SVCursor, Color3.fromRGB(0, 0, 0), 1)

                    local HueBox = Instance.new("Frame")
                    HueBox.Size = UDim2.new(0, 14, 0, 120)
                    HueBox.Position = UDim2.new(0, 136, 0, 10)
                    HueBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    HueBox.BorderSizePixel = 0
                    HueBox.ZIndex = 25001
                    HueBox.Parent = ColorPickerBox
                    addCorner(HueBox, 4)

                    local HueGradient = Instance.new("UIGradient")
                    HueGradient.Rotation = 90
                    HueGradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                    })
                    HueGradient.Parent = HueBox

                    local HueCursor = Instance.new("Frame")
                    HueCursor.Size = UDim2.new(1, 4, 0, 3)
                    HueCursor.Position = UDim2.new(0, -2, h, -1)
                    HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    HueCursor.BorderSizePixel = 0
                    HueCursor.ZIndex = 25002
                    HueCursor.Parent = HueBox
                    addCorner(HueCursor, 2)

                    local HexLabel = Instance.new("TextLabel")
                    HexLabel.Size = UDim2.new(1, -20, 0, 14)
                    HexLabel.Position = UDim2.new(0, 10, 0, 132)
                    HexLabel.BackgroundTransparency = 1
                    HexLabel.Font = RageLibrary.Fonts.Badge
                    HexLabel.Text = "#" .. currentColor:ToHex()
                    HexLabel.TextColor3 = RageLibrary.Theme.TextDim
                    HexLabel.TextSize = 9
                    HexLabel.ZIndex = 25001
                    HexLabel.Parent = ColorPickerBox

                    local function updateColor()
                        currentColor = Color3.fromHSV(h, s, v)
                        SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        ColorBadge.BackgroundColor3 = currentColor
                        HexLabel.Text = "#" .. currentColor:ToHex()
                        if cpCallback then cpCallback(currentColor) end
                    end

                    local isDraggingSV = false
                    local function updateSV(inputPos)
                        local relX = math.clamp((inputPos.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                        local relY = math.clamp((inputPos.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                        s = relX
                        v = 1 - relY
                        SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
                        updateColor()
                    end

                    SVBox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDraggingSV = true
                            updateSV(input.Position)
                        end
                    end)

                    local isDraggingHue = false
                    local function updateHue(inputPos)
                        local relY = math.clamp((inputPos.Y - HueBox.AbsolutePosition.Y) / HueBox.AbsoluteSize.Y, 0, 1)
                        h = relY
                        HueCursor.Position = UDim2.new(0, -2, h, -1)
                        updateColor()
                    end

                    HueBox.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDraggingHue = true
                            updateHue(input.Position)
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if isDraggingSV then updateSV(input.Position) end
                            if isDraggingHue then updateHue(input.Position) end
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            isDraggingSV = false
                            isDraggingHue = false
                        end
                    end)

                    ColorBadge.MouseButton1Click:Connect(function()
                        ColorPickerBox.Visible = not ColorPickerBox.Visible
                        if ColorPickerBox.Visible then
                            ColorPickerBox.Position = UDim2.new(0, ColorBadge.AbsolutePosition.X - 120, 0, ColorBadge.AbsolutePosition.Y + ColorBadge.AbsoluteSize.Y + 4)
                            RageLibrary:PlaySound("Dropdown")
                        end
                    end)
                end

                -- Right Side Switch
                local SwitchBg = Instance.new("Frame")
                SwitchBg.Size = UDim2.new(0, 28, 0, 14)
                SwitchBg.BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header
                SwitchBg.BorderSizePixel = 0
                SwitchBg.LayoutOrder = 3
                SwitchBg.Parent = ControlsHolder
                addCorner(SwitchBg, 7)

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 10, 0, 10)
                Knob.Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
                Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Knob.BorderSizePixel = 0
                Knob.Parent = SwitchBg
                addCorner(Knob, 5)

                local hasKeybind = false
                if type(cfg) == "table" then
                    if cfg.Keybind ~= nil or cfg.HasKeybind == true or cfg.Keybindable == true or cfg.Bindable == true then
                        hasKeybind = true
                    end
                end

                local kbEntry = nil
                local updateBadgeText = function() end

                if hasKeybind then
                    local KeyBadge = Instance.new("TextButton")
                    KeyBadge.Size = UDim2.new(0, 64, 0, 18)
                    KeyBadge.BackgroundColor3 = RageLibrary.Theme.Header
                    KeyBadge.BorderSizePixel = 0
                    KeyBadge.AutoButtonColor = false
                    KeyBadge.Font = RageLibrary.Fonts.Badge
                    KeyBadge.LayoutOrder = 2
                    KeyBadge.TextColor3 = RageLibrary.Theme.Text
                    KeyBadge.TextSize = 8.5
                    KeyBadge.ZIndex = 10
                    KeyBadge.Parent = ControlsHolder
                    addCorner(KeyBadge, 5)

                    kbEntry = {
                        name = name,
                        getBindKey = function() return bindKey end,
                        getState = function() return state end,
                        bindKey = bindKey,
                        state = state,
                        getKeyName = function()
                            if typeof(bindKey) == "EnumItem" then
                                if bindKey.EnumType == Enum.KeyCode then
                                    return bindKey.Name
                                elseif bindKey.EnumType == Enum.UserInputType then
                                    if bindKey == Enum.UserInputType.MouseButton1 then return "M1"
                                    elseif bindKey == Enum.UserInputType.MouseButton2 then return "M2"
                                    elseif bindKey == Enum.UserInputType.MouseButton3 then return "M3"
                                    else return bindKey.Name end
                                end
                            end
                            return tostring(bindKey or "None")
                        end,
                        onInputBegan = function()
                            if not bindKey then return end
                            if bindMode == "Toggle" then
                                state = not state
                                refreshKeybindWidget()
                                smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header })
                                smoothTween(Knob, DUR_FAST, { Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5) })
                                RageLibrary:PlaySound(state and "ToggleOn" or "ToggleOff")
                                if callback then callback(state) end
                            elseif bindMode == "Hold" then
                                state = true
                                refreshKeybindWidget()
                                smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Accent })
                                smoothTween(Knob, DUR_FAST, { Position = UDim2.new(1, -12, 0.5, -5) })
                                if callback then callback(true) end
                            end
                        end,
                        onInputEnded = function()
                            if bindKey and bindMode == "Hold" then
                                state = false
                                refreshKeybindWidget()
                                smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Header })
                                smoothTween(Knob, DUR_FAST, { Position = UDim2.new(0, 2, 0.5, -5) })
                                if callback then callback(false) end
                            end
                        end
                    }
                    table.insert(registeredKeybinds, kbEntry)

                    updateBadgeText = function()
                        kbEntry.bindKey = bindKey
                        kbEntry.state = state
                        local kName = kbEntry.getKeyName()

                        if not bindKey then
                            if bindMode == "Always" then
                                KeyBadge.Text = "[ Always ]"
                                KeyBadge.TextColor3 = RageLibrary.Theme.Accent
                            else
                                KeyBadge.Text = "[ None ]"
                                KeyBadge.TextColor3 = RageLibrary.Theme.TextDim
                            end
                        elseif bindMode == "Always" then
                            KeyBadge.Text = "[" .. kName .. ":Always]"
                            KeyBadge.TextColor3 = RageLibrary.Theme.Accent
                        elseif bindMode == "Hold" then
                            KeyBadge.Text = "[" .. kName .. ":Hold]"
                            KeyBadge.TextColor3 = RageLibrary.Theme.Accent
                        else
                            KeyBadge.Text = "[" .. kName .. "]"
                            KeyBadge.TextColor3 = RageLibrary.Theme.Text
                        end

                        refreshKeybindWidget()
                    end
                    updateBadgeText()

                    KeyBadge.MouseEnter:Connect(function()
                        smoothTween(KeyBadge, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.CardHover })
                    end)
                    KeyBadge.MouseLeave:Connect(function()
                        smoothTween(KeyBadge, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Header })
                    end)

                    -- Right Click Context Menu for Mode Selection (Hold / Toggle / Always)
                    local ModeMenu = Instance.new("Frame")
                    ModeMenu.Name = "ModeMenu_" .. name
                    ModeMenu.Size = UDim2.new(0, 95, 0, 71)
                    ModeMenu.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
                    ModeMenu.BorderSizePixel = 0
                    ModeMenu.Visible = false
                    ModeMenu.ZIndex = 20000
                    ModeMenu.Parent = ScreenGui
                    addCorner(ModeMenu, 5)
                    addStroke(ModeMenu, RageLibrary.Theme.Stroke, 1)

                    local ModeLayout = Instance.new("UIListLayout")
                    ModeLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    ModeLayout.Padding = UDim.new(0, 2)
                    ModeLayout.Parent = ModeMenu

                    local modes = {"Toggle", "Hold", "Always"}
                    local modeBtns = {}

                    local function getIsSelected(mName)
                        return bindKey ~= nil and bindMode == mName
                    end

                    local function refreshModeBtns()
                        for mName, mBtn in pairs(modeBtns) do
                            local isSelected = getIsSelected(mName)
                            mBtn.BackgroundColor3 = isSelected and RageLibrary.Theme.CardHover or Color3.fromRGB(16, 16, 22)
                            mBtn.TextColor3 = isSelected and RageLibrary.Theme.Accent or RageLibrary.Theme.TextDim
                            mBtn.Text = (isSelected and "✓ " or "  ") .. mName
                        end
                    end

                    for _, m in ipairs(modes) do
                        local MBtn = Instance.new("TextButton")
                        MBtn.Size = UDim2.new(1, -4, 0, 21)
                        MBtn.Position = UDim2.new(0, 2, 0, 0)
                        MBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
                        MBtn.BorderSizePixel = 0
                        MBtn.AutoButtonColor = false
                        MBtn.Font = RageLibrary.Fonts.Label
                        MBtn.Text = "  " .. m
                        MBtn.TextColor3 = RageLibrary.Theme.TextDim
                        MBtn.TextSize = 9
                        MBtn.TextXAlignment = Enum.TextXAlignment.Left
                        MBtn.ZIndex = 20001
                        MBtn.Parent = ModeMenu
                        addCorner(MBtn, 4)
                        modeBtns[m] = MBtn

                        MBtn.MouseEnter:Connect(function()
                            if not getIsSelected(m) then
                                smoothTween(MBtn, 0.1, { BackgroundColor3 = RageLibrary.Theme.CardHover, TextColor3 = RageLibrary.Theme.TextHover })
                            end
                        end)
                        MBtn.MouseLeave:Connect(function()
                            if not getIsSelected(m) then
                                smoothTween(MBtn, 0.1, { BackgroundColor3 = Color3.fromRGB(16, 16, 22), TextColor3 = RageLibrary.Theme.TextDim })
                            end
                        end)

                        MBtn.MouseButton1Click:Connect(function()
                            bindMode = m
                            refreshModeBtns()
                            updateBadgeText()
                            ModeMenu.Visible = false
                            if bindMode == "Always" then
                                state = true
                                if kbEntry then kbEntry.state = true end
                                refreshKeybindWidget()
                                smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Accent })
                                smoothTween(Knob, DUR_FAST, { Position = UDim2.new(1, -12, 0.5, -5) })
                                if callback then callback(true) end
                            end
                        end)
                    end

                    refreshModeBtns()

                    local lastLeftClickTime = 0
                    local singleClickTask = nil

                    KeyBadge.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local now = tick()
                            if now - lastLeftClickTime < 0.32 then
                                -- DOUBLE CLICK: Unbind key!
                                if singleClickTask then
                                    task.cancel(singleClickTask)
                                    singleClickTask = nil
                                end
                                cancelRebindCapture()
                                isRebinding = false
                                bindKey = nil
                                refreshModeBtns()
                                updateBadgeText()
                                lastLeftClickTime = 0
                                return
                            end

                            lastLeftClickTime = now

                            -- SINGLE CLICK: Schedule rebind capture if no 2nd click follows
                            singleClickTask = task.delay(0.28, function()
                                singleClickTask = nil
                                if isRebinding then return end
                                isRebinding = true
                                KeyBadge.Text = "[...]"
                                KeyBadge.TextColor3 = RageLibrary.Theme.TextHover

                                startRebindCapture(function(rebindInput)
                                    local target = nil
                                    local isFinished = false

                                    if rebindInput.UserInputType == Enum.UserInputType.Keyboard then
                                        local kc = rebindInput.KeyCode
                                        if kc == Enum.KeyCode.Escape or kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then
                                            bindKey = nil
                                            isFinished = true
                                        elseif kc ~= Enum.KeyCode.Unknown then
                                            target = kc
                                            isFinished = true
                                        end
                                    elseif rebindInput.UserInputType == Enum.UserInputType.MouseButton2 or
                                           rebindInput.UserInputType == Enum.UserInputType.MouseButton3 then
                                        target = rebindInput.UserInputType
                                        isFinished = true
                                    end

                                    if isFinished then
                                        isRebinding = false
                                        if target then
                                            bindKey = target
                                            if bindMode == nil or bindMode == "" then
                                                bindMode = "Toggle"
                                            end
                                        else
                                            bindKey = nil
                                        end
                                        refreshModeBtns()
                                        updateBadgeText()
                                        return true
                                    end

                                    return false
                                end)
                            end)
                        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                            if not isRebinding then
                                ModeMenu.Position = UDim2.new(0, KeyBadge.AbsolutePosition.X, 0, KeyBadge.AbsolutePosition.Y + KeyBadge.AbsoluteSize.Y + 2)
                                ModeMenu.Visible = not ModeMenu.Visible
                                if ModeMenu.Visible then
                                    refreshModeBtns()
                                end
                            end
                        end
                    end)
                end

                -- Toggle Hover Animation
                ToggleRow.MouseEnter:Connect(function()
                    smoothTween(ToggleRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.RowHover })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(ToggleStroke, DUR_FAST, { Color = Color3.fromRGB(80, 18, 26) })
                end)
                ToggleRow.MouseLeave:Connect(function()
                    smoothTween(ToggleRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Block })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(ToggleStroke, DUR_FAST, { Color = RageLibrary.Theme.Stroke })
                end)

                local function toggleState()
                    if bindMode == "Always" then return end
                    state = not state
                    if kbEntry then
                        kbEntry.state = state
                        refreshKeybindWidget()
                    end
                    smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header })
                    smoothTween(Knob, DUR_FAST, { Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5) })
                    RageLibrary:PlaySound(state and "ToggleOn" or "ToggleOff")
                    if callback then callback(state) end
                end

                ToggleRow.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        -- Check if click was over ControlsHolder (KeyBadge / ColorBadge / Switch)
                        local mPos = input.Position
                        local cPos = ControlsHolder.AbsolutePosition
                        local cSize = ControlsHolder.AbsoluteSize
                        if mPos.X >= cPos.X and mPos.X <= cPos.X + cSize.X and
                           mPos.Y >= cPos.Y and mPos.Y <= cPos.Y + cSize.Y then
                            return -- Clicked inside ControlsHolder, KeyBadge handles it!
                        end
                        toggleState()
                    end
                end)

                SwitchBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        toggleState()
                    end
                end)

                updateCardSize()
                return {
                    SetState = function(val)
                        state = val
                        smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header })
                        smoothTween(Knob, DUR_FAST, { Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5) })
                    end
                }
            end

            function SectionObj:AddButton(cfg, legacyCb)
                local name = type(cfg) == "table" and cfg.Name or cfg
                local callback = (type(cfg) == "table" and cfg.Callback) or legacyCb

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 26)
                Btn.BackgroundColor3 = RageLibrary.Theme.Header
                Btn.BorderSizePixel = 0
                Btn.Font = RageLibrary.Fonts.Header
                Btn.Text = name
                Btn.TextColor3 = RageLibrary.Theme.Text
                Btn.TextSize = 9.5
                Btn.Parent = ItemsHolder
                addCorner(Btn, 5)
                local BtnStroke = addStroke(Btn, RageLibrary.Theme.Stroke, 1)

                Btn.MouseEnter:Connect(function()
                    smoothTween(Btn, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.CardHover, TextColor3 = RageLibrary.Theme.TextHover })
                end)
                Btn.MouseLeave:Connect(function()
                    smoothTween(Btn, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Header, TextColor3 = RageLibrary.Theme.Text })
                end)

                Btn.MouseButton1Click:Connect(function()
                    RageLibrary:PlaySound("Click")
                    local t = smoothTween(Btn, 0.1, { BackgroundColor3 = RageLibrary.Theme.Accent })
                    if t then
                        t.Completed:Connect(function()
                            smoothTween(Btn, 0.2, { BackgroundColor3 = RageLibrary.Theme.Header })
                        end)
                    end
                    if callback then callback() end
                end)

                updateCardSize()
            end

            -- REDESIGNED ULTRA-SLICK SLIDER WITH THUMB KNOB & CONTAINER
            function SectionObj:AddSlider(cfg, minVal, maxVal, defaultVal, callback)
                local name = type(cfg) == "table" and cfg.Name or cfg
                local min = (type(cfg) == "table" and cfg.Min) or minVal or 0
                local max = (type(cfg) == "table" and cfg.Max) or maxVal or 100
                local currentVal = (type(cfg) == "table" and cfg.Default) or defaultVal or min
                currentVal = math.clamp(currentVal, min, max)
                local suffix = (type(cfg) == "table" and cfg.Suffix) or ""
                local cb = (type(cfg) == "table" and cfg.Callback) or callback

                local SliderRow = Instance.new("Frame")
                SliderRow.Size = UDim2.new(1, 0, 0, 44)
                SliderRow.BackgroundColor3 = RageLibrary.Theme.Block
                SliderRow.BackgroundTransparency = 1
                SliderRow.BorderSizePixel = 0
                SliderRow.Parent = ItemsHolder
                addCorner(SliderRow, 6)
                local SliderStroke = addStroke(SliderRow, RageLibrary.Theme.Stroke, 1)
                local sliderRowIdx = #ItemsHolder:GetChildren()
                task.delay(0.08 + sliderRowIdx * 0.04, function()
                    smoothTween(SliderRow, 0.25, { BackgroundTransparency = 0.12 })
                end)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -65, 0, 18)
                Label.Position = UDim2.new(0, 10, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderRow

                -- Sleek Value Badge Container
                local ValBadgeHolder = Instance.new("Frame")
                ValBadgeHolder.Size = UDim2.new(0, 52, 0, 18)
                ValBadgeHolder.Position = UDim2.new(1, -60, 0, 4)
                ValBadgeHolder.BackgroundColor3 = RageLibrary.Theme.Header
                ValBadgeHolder.BorderSizePixel = 0
                ValBadgeHolder.Parent = SliderRow
                addCorner(ValBadgeHolder, 5)

                local ValBadge = Instance.new("TextLabel")
                ValBadge.Size = UDim2.new(1, 0, 1, 0)
                ValBadge.BackgroundTransparency = 1
                ValBadge.Font = RageLibrary.Fonts.Badge
                ValBadge.Text = tostring(currentVal) .. suffix
                ValBadge.TextColor3 = RageLibrary.Theme.Text
                ValBadge.TextSize = 9.5
                ValBadge.Parent = ValBadgeHolder

                -- Slider Track Bar
                local TrackBg = Instance.new("TextButton")
                TrackBg.Size = UDim2.new(1, -20, 0, 6)
                TrackBg.Position = UDim2.new(0, 10, 0, 27)
                TrackBg.BackgroundColor3 = RageLibrary.Theme.Header
                TrackBg.BorderSizePixel = 0
                TrackBg.AutoButtonColor = false
                TrackBg.Text = ""
                TrackBg.Parent = SliderRow
                addCorner(TrackBg, 3)

                local relX = (currentVal - min) / (max - min)
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(relX, 0, 1, 0)
                Fill.BackgroundColor3 = RageLibrary.Theme.Accent
                Fill.BorderSizePixel = 0
                Fill.Parent = TrackBg
                addCorner(Fill, 3)

                -- Thumb Knob Dot (Clean white, no stroke outline, compact size 8x8)
                local ThumbKnob = Instance.new("Frame")
                ThumbKnob.Size = UDim2.new(0, 8, 0, 8)
                ThumbKnob.Position = UDim2.new(relX, -4, 0.5, -4)
                ThumbKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ThumbKnob.BorderSizePixel = 0
                ThumbKnob.Parent = TrackBg
                addCorner(ThumbKnob, 4)

                SliderRow.MouseEnter:Connect(function()
                    smoothTween(SliderRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.RowHover })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(SliderStroke, DUR_FAST, { Color = Color3.fromRGB(80, 18, 26) })
                end)
                SliderRow.MouseLeave:Connect(function()
                    smoothTween(SliderRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Block })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(SliderStroke, DUR_FAST, { Color = RageLibrary.Theme.Stroke })
                end)

                local isDragging = false
                local function updateSlider(inputX)
                    local width = TrackBg.AbsoluteSize.X
                    if width <= 0 then return end
                    local r = math.clamp((inputX - TrackBg.AbsolutePosition.X) / width, 0, 1)
                    currentVal = math.floor(min + (max - min) * r + 0.5)
                    ValBadge.Text = tostring(currentVal) .. suffix
                    Fill.Size = UDim2.new(r, 0, 1, 0)
                    ThumbKnob.Position = UDim2.new(r, -4, 0.5, -4)
                    if cb then cb(currentVal) end
                end

                TrackBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDragging = true
                        RageLibrary:PlaySound("Slider")
                        updateSlider(input.Position.X)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        updateSlider(input.Position.X)
                    end
                end)

                updateCardSize()
            end

            -- INTERACTIVE DROPDOWN
            function SectionObj:AddDropdown(cfg)
                local name = type(cfg) == "table" and cfg.Name or "Dropdown"
                local options = type(cfg) == "table" and cfg.Options or {}
                local selected = type(cfg) == "table" and (cfg.Default or options[1]) or ""
                local cb = type(cfg) == "table" and cfg.Callback or nil

                local isOpen = false

                local DropRow = Instance.new("Frame")
                DropRow.Size = UDim2.new(1, 0, 0, 44)
                DropRow.BackgroundColor3 = RageLibrary.Theme.Block
                DropRow.BackgroundTransparency = 1
                DropRow.BorderSizePixel = 0
                DropRow.Parent = ItemsHolder
                addCorner(DropRow, 6)
                local DropRowStroke = addStroke(DropRow, RageLibrary.Theme.Stroke, 1)
                local dropRowIdx = #ItemsHolder:GetChildren()
                task.delay(0.08 + dropRowIdx * 0.04, function()
                    smoothTween(DropRow, 0.25, { BackgroundTransparency = 0.12 })
                end)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -16, 0, 16)
                Label.Position = UDim2.new(0, 10, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropRow

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, -20, 0, 20)
                DropBtn.Position = UDim2.new(0, 10, 0, 20)
                DropBtn.BackgroundColor3 = RageLibrary.Theme.Header
                DropBtn.BorderSizePixel = 0
                DropBtn.Font = RageLibrary.Fonts.Badge
                DropBtn.Text = "  " .. tostring(selected) .. "  ▼"
                DropBtn.TextColor3 = RageLibrary.Theme.TextHover
                DropBtn.TextSize = 9.5
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.ClipsDescendants = true
                DropBtn.TextTruncate = Enum.TextTruncate.AtEnd
                DropBtn.Parent = DropRow
                addCorner(DropBtn, 5)
                local DropBtnStroke = addStroke(DropBtn, RageLibrary.Theme.Stroke, 1)

                DropRow.MouseEnter:Connect(function()
                    smoothTween(DropRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.RowHover })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Accent })
                    smoothTween(DropBtn, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.CardHover })
                    smoothTween(DropRowStroke, DUR_FAST, { Color = Color3.fromRGB(80, 18, 26) })
                end)
                DropRow.MouseLeave:Connect(function()
                    smoothTween(DropRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Block })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(DropBtn, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Header })
                    smoothTween(DropRowStroke, DUR_FAST, { Color = RageLibrary.Theme.Stroke })
                end)

                -- Unclipped Floating Dropdown Menu Container
                local DropList = Instance.new("ScrollingFrame")
                DropList.Name = "DropList_" .. name
                DropList.Size = UDim2.new(0, 0, 0, 0)
                DropList.BackgroundColor3 = RageLibrary.Theme.Header
                DropList.BorderSizePixel = 0
                DropList.Visible = false
                DropList.ZIndex = 10000
                DropList.ScrollBarThickness = 2
                DropList.ScrollBarImageColor3 = RageLibrary.Theme.Accent
                DropList.Parent = ScreenGui
                addCorner(DropList, 5)
                addStroke(DropList, RageLibrary.Theme.Stroke, 1)

                local DropLayout = Instance.new("UIListLayout")
                DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DropLayout.Padding = UDim.new(0, 2)
                DropLayout.Parent = DropList

                local function rebuildOptions()
                    for _, child in ipairs(DropList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for idx, opt in ipairs(options) do
                        local isSel = (tostring(opt) == tostring(selected))
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, -4, 0, 20)
                        OptBtn.BackgroundColor3 = isSel and RageLibrary.Theme.CardHover or RageLibrary.Theme.Header
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Font = RageLibrary.Fonts.Label
                        OptBtn.Text = isSel and (" ✓ " .. tostring(opt)) or ("   " .. tostring(opt))
                        OptBtn.TextColor3 = RageLibrary.Theme.Text
                        OptBtn.TextSize = 9.5
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.ZIndex = 10001
                        OptBtn.Parent = DropList
                        addCorner(OptBtn, 3)

                        OptBtn.MouseEnter:Connect(function()
                            if not isSel then
                                smoothTween(OptBtn, 0.1, { BackgroundColor3 = RageLibrary.Theme.CardHover, TextColor3 = RageLibrary.Theme.TextHover })
                            end
                        end)
                        OptBtn.MouseLeave:Connect(function()
                            if not isSel then
                                smoothTween(OptBtn, 0.1, { BackgroundColor3 = RageLibrary.Theme.Header, TextColor3 = RageLibrary.Theme.Text })
                            end
                        end)

                        OptBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            DropBtn.Text = "  " .. tostring(selected) .. "  ▼"
                            isOpen = false
                            DropList.Visible = false
                            RageLibrary:PlaySound("Dropdown")
                            if cb then cb(selected) end
                        end)
                    end
                    local h = math.min(#options * 22 + 4, 120)
                    DropList.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
                    return h
                end

                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    RageLibrary:PlaySound("Dropdown")
                    if isOpen then
                        local h = rebuildOptions()
                        DropList.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, h)
                        DropList.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 2)
                        DropList.Visible = true
                    else
                        DropList.Visible = false
                    end
                end)

                updateCardSize()
                return {
                    SetOptions = function(newOpts) options = newOpts rebuildOptions() end,
                    SetValue = function(val) selected = val DropBtn.Text = "  " .. tostring(selected) .. "  ▼" end
                }
            end

            -- INTERACTIVE MULTI-SELECT
            function SectionObj:AddMultiSelect(cfg)
                local name = type(cfg) == "table" and cfg.Name or "MultiSelect"
                local options = type(cfg) == "table" and cfg.Options or {}
                local selectedList = type(cfg) == "table" and (cfg.Default or {}) or {}
                local cb = type(cfg) == "table" and cfg.Callback or nil

                local selectedMap = {}
                for _, item in ipairs(selectedList) do
                    selectedMap[item] = true
                end

                local isOpen = false

                local function getSummary()
                    local summary = {}
                    for _, opt in ipairs(options) do
                        if selectedMap[opt] then
                            table.insert(summary, opt)
                        end
                    end
                    if #summary == 0 then return "None" end
                    return table.concat(summary, ", ")
                end

                local DropRow = Instance.new("Frame")
                DropRow.Size = UDim2.new(1, 0, 0, 44)
                DropRow.BackgroundColor3 = RageLibrary.Theme.Block
                DropRow.BackgroundTransparency = 1
                DropRow.BorderSizePixel = 0
                DropRow.Parent = ItemsHolder
                addCorner(DropRow, 6)
                local DropRowStroke = addStroke(DropRow, RageLibrary.Theme.Stroke, 1)
                local msRowIdx = #ItemsHolder:GetChildren()
                task.delay(0.08 + msRowIdx * 0.04, function()
                    smoothTween(DropRow, 0.25, { BackgroundTransparency = 0.12 })
                end)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -16, 0, 16)
                Label.Position = UDim2.new(0, 10, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropRow

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, -20, 0, 20)
                DropBtn.Position = UDim2.new(0, 10, 0, 20)
                DropBtn.BackgroundColor3 = RageLibrary.Theme.Header
                DropBtn.BorderSizePixel = 0
                DropBtn.Font = RageLibrary.Fonts.Badge
                DropBtn.Text = "  " .. getSummary() .. "  ▼"
                DropBtn.TextColor3 = RageLibrary.Theme.TextHover
                DropBtn.TextSize = 9.5
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.ClipsDescendants = true
                DropBtn.TextTruncate = Enum.TextTruncate.AtEnd
                DropBtn.Parent = DropRow
                addCorner(DropBtn, 5)
                local DropBtnStroke = addStroke(DropBtn, RageLibrary.Theme.Stroke, 1)

                DropRow.MouseEnter:Connect(function()
                    smoothTween(DropRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.RowHover })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Accent })
                    smoothTween(DropBtn, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.CardHover })
                    smoothTween(DropRowStroke, DUR_FAST, { Color = Color3.fromRGB(80, 18, 26) })
                end)
                DropRow.MouseLeave:Connect(function()
                    smoothTween(DropRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Block })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(DropBtn, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Header })
                    smoothTween(DropRowStroke, DUR_FAST, { Color = RageLibrary.Theme.Stroke })
                end)

                -- Unclipped Floating MultiSelect Container
                local DropList = Instance.new("ScrollingFrame")
                DropList.Name = "MultiDropList_" .. name
                DropList.Size = UDim2.new(0, 0, 0, 0)
                DropList.BackgroundColor3 = RageLibrary.Theme.Header
                DropList.BorderSizePixel = 0
                DropList.Visible = false
                DropList.ZIndex = 10000
                DropList.ScrollBarThickness = 2
                DropList.ScrollBarImageColor3 = RageLibrary.Theme.Accent
                DropList.Parent = ScreenGui
                addCorner(DropList, 5)
                addStroke(DropList, RageLibrary.Theme.Stroke, 1)

                local DropLayout = Instance.new("UIListLayout")
                DropLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DropLayout.Padding = UDim.new(0, 2)
                DropLayout.Parent = DropList

                local function rebuildOptions()
                    for _, child in ipairs(DropList:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for idx, opt in ipairs(options) do
                        local isChecked = selectedMap[opt] or false
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, -4, 0, 20)
                        OptBtn.BackgroundColor3 = isChecked and RageLibrary.Theme.CardHover or RageLibrary.Theme.Header
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Font = RageLibrary.Fonts.Label
                        OptBtn.Text = isChecked and (" [✓] " .. tostring(opt)) or (" [  ] " .. tostring(opt))
                        OptBtn.TextColor3 = RageLibrary.Theme.Text
                        OptBtn.TextSize = 9.5
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.ZIndex = 10001
                        OptBtn.Parent = DropList
                        addCorner(OptBtn, 3)

                        OptBtn.MouseEnter:Connect(function()
                            if not isChecked then
                                smoothTween(OptBtn, 0.1, { BackgroundColor3 = RageLibrary.Theme.CardHover, TextColor3 = RageLibrary.Theme.TextHover })
                            end
                        end)
                        OptBtn.MouseLeave:Connect(function()
                            if not isChecked then
                                smoothTween(OptBtn, 0.1, { BackgroundColor3 = RageLibrary.Theme.Header, TextColor3 = RageLibrary.Theme.Text })
                            end
                        end)

                        OptBtn.MouseButton1Click:Connect(function()
                            selectedMap[opt] = not selectedMap[opt]
                            OptBtn.Text = selectedMap[opt] and (" [✓] " .. tostring(opt)) or (" [  ] " .. tostring(opt))
                            OptBtn.TextColor3 = RageLibrary.Theme.Text
                            OptBtn.BackgroundColor3 = selectedMap[opt] and RageLibrary.Theme.CardHover or RageLibrary.Theme.Header
                            DropBtn.Text = "  " .. getSummary() .. "  ▼"
                            RageLibrary:PlaySound("Dropdown")

                            local curTable = {}
                            for _, o in ipairs(options) do
                                if selectedMap[o] then table.insert(curTable, o) end
                            end
                            if cb then cb(curTable) end
                        end)
                    end
                    local h = math.min(#options * 22 + 4, 120)
                    DropList.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
                    return h
                end

                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    RageLibrary:PlaySound("Dropdown")
                    if isOpen then
                        local h = rebuildOptions()
                        DropList.Size = UDim2.new(0, DropBtn.AbsoluteSize.X, 0, h)
                        DropList.Position = UDim2.new(0, DropBtn.AbsolutePosition.X, 0, DropBtn.AbsolutePosition.Y + DropBtn.AbsoluteSize.Y + 2)
                        DropList.Visible = true
                        RageLibrary:PlaySound("Click")
                    else
                        DropList.Visible = false
                    end
                end)

                updateCardSize()
                return {
                    GetValues = function()
                        local curTable = {}
                        for _, o in ipairs(options) do
                            if selectedMap[o] then table.insert(curTable, o) end
                        end
                        return curTable
                    end
                }
            end

            -- INTERACTIVE COLORPICKER
            function SectionObj:AddColorpicker(cfg, legacyDefault, legacyCb)
                local name = (type(cfg) == "table" and cfg.Name) or cfg or "ColorPicker"
                local currentColor = (type(cfg) == "table" and cfg.Default) or legacyDefault or Color3.fromRGB(255, 45, 70)
                local cb = (type(cfg) == "table" and cfg.Callback) or legacyCb

                local h, s, v = Color3.toHSV(currentColor)

                local ColorRow = Instance.new("Frame")
                ColorRow.Size = UDim2.new(1, 0, 0, 30)
                ColorRow.BackgroundColor3 = RageLibrary.Theme.Block
                ColorRow.BackgroundTransparency = 1
                ColorRow.BorderSizePixel = 0
                ColorRow.Parent = ItemsHolder
                addCorner(ColorRow, 6)
                local ColorRowStroke = addStroke(ColorRow, RageLibrary.Theme.Stroke, 1)
                local cpRowIdx = #ItemsHolder:GetChildren()
                task.delay(0.08 + cpRowIdx * 0.04, function()
                    smoothTween(ColorRow, 0.25, { BackgroundTransparency = 0.12 })
                end)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -50, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ColorRow

                -- Color Badge Preview Button
                local ColorBadge = Instance.new("TextButton")
                ColorBadge.Size = UDim2.new(0, 34, 0, 18)
                ColorBadge.Position = UDim2.new(1, -42, 0.5, -9)
                ColorBadge.BackgroundColor3 = currentColor
                ColorBadge.BorderSizePixel = 0
                ColorBadge.Text = ""
                ColorBadge.Parent = ColorRow
                addCorner(ColorBadge, 4)
                addStroke(ColorBadge, RageLibrary.Theme.Stroke, 1)

                ColorRow.MouseEnter:Connect(function()
                    smoothTween(ColorRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.RowHover })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(ColorRowStroke, DUR_FAST, { Color = Color3.fromRGB(80, 18, 26) })
                end)
                ColorRow.MouseLeave:Connect(function()
                    smoothTween(ColorRow, DUR_FAST, { BackgroundColor3 = RageLibrary.Theme.Block })
                    smoothTween(Label, DUR_FAST, { TextColor3 = RageLibrary.Theme.Text })
                    smoothTween(ColorRowStroke, DUR_FAST, { Color = RageLibrary.Theme.Stroke })
                end)

                -- Unclipped Floating ColorPicker Popup Window
                local ColorPickerBox = Instance.new("Frame")
                ColorPickerBox.Name = "ColorPicker_" .. name
                ColorPickerBox.Size = UDim2.new(0, 160, 0, 150)
                ColorPickerBox.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
                ColorPickerBox.BorderSizePixel = 0
                ColorPickerBox.Visible = false
                ColorPickerBox.ZIndex = 25000
                ColorPickerBox.Parent = ScreenGui
                addCorner(ColorPickerBox, 6)
                addStroke(ColorPickerBox, RageLibrary.Theme.Stroke, 1.2)

                -- Saturation & Value Box (SV Map)
                local SVBox = Instance.new("ImageLabel")
                SVBox.Size = UDim2.new(0, 120, 0, 120)
                SVBox.Position = UDim2.new(0, 10, 0, 10)
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVBox.BorderSizePixel = 0
                SVBox.Image = "rbxassetid://4155801252"
                SVBox.ZIndex = 25001
                SVBox.Parent = ColorPickerBox
                addCorner(SVBox, 4)

                -- SV Cursor (Small white dot)
                local SVCursor = Instance.new("Frame")
                SVCursor.Size = UDim2.new(0, 6, 0, 6)
                SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
                SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SVCursor.BorderSizePixel = 0
                SVCursor.ZIndex = 25002
                SVCursor.Parent = SVBox
                addCorner(SVCursor, 3)
                addStroke(SVCursor, Color3.fromRGB(0, 0, 0), 1)

                -- Hue Slider (Rainbow Bar)
                local HueBox = Instance.new("Frame")
                HueBox.Size = UDim2.new(0, 14, 0, 120)
                HueBox.Position = UDim2.new(0, 136, 0, 10)
                HueBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueBox.BorderSizePixel = 0
                HueBox.ZIndex = 25001
                HueBox.Parent = ColorPickerBox
                addCorner(HueBox, 4)

                local HueGradient = Instance.new("UIGradient")
                HueGradient.Rotation = 90
                HueGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                })
                HueGradient.Parent = HueBox

                -- Hue Cursor (White bar line)
                local HueCursor = Instance.new("Frame")
                HueCursor.Size = UDim2.new(1, 4, 0, 3)
                HueCursor.Position = UDim2.new(0, -2, h, -1)
                HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueCursor.BorderSizePixel = 0
                HueCursor.ZIndex = 25002
                HueCursor.Parent = HueBox
                addCorner(HueCursor, 2)

                -- Hex Code Label at bottom
                local HexLabel = Instance.new("TextLabel")
                HexLabel.Size = UDim2.new(1, -20, 0, 14)
                HexLabel.Position = UDim2.new(0, 10, 0, 132)
                HexLabel.BackgroundTransparency = 1
                HexLabel.Font = RageLibrary.Fonts.Badge
                HexLabel.Text = "#" .. currentColor:ToHex()
                HexLabel.TextColor3 = RageLibrary.Theme.TextDim
                HexLabel.TextSize = 9
                HexLabel.ZIndex = 25001
                HexLabel.Parent = ColorPickerBox

                local function updateColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    ColorBadge.BackgroundColor3 = currentColor
                    HexLabel.Text = "#" .. currentColor:ToHex()
                    if cb then cb(currentColor) end
                end

                -- Drag SV Box Logic
                local isDraggingSV = false
                local function updateSV(inputPos)
                    local relX = math.clamp((inputPos.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((inputPos.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                    s = relX
                    v = 1 - relY
                    SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
                    updateColor()
                end

                SVBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDraggingSV = true
                        updateSV(input.Position)
                    end
                end)

                -- Drag Hue Bar Logic
                local isDraggingHue = false
                local function updateHue(inputPos)
                    local relY = math.clamp((inputPos.Y - HueBox.AbsolutePosition.Y) / HueBox.AbsoluteSize.Y, 0, 1)
                    h = relY
                    HueCursor.Position = UDim2.new(0, -2, h, -1)
                    updateColor()
                end

                HueBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDraggingHue = true
                        updateHue(input.Position)
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if isDraggingSV then updateSV(input.Position) end
                        if isDraggingHue then updateHue(input.Position) end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDraggingSV = false
                        isDraggingHue = false
                    end
                end)

                -- Toggle ColorPicker Window on Badge Click
                ColorBadge.MouseButton1Click:Connect(function()
                    ColorPickerBox.Visible = not ColorPickerBox.Visible
                    if ColorPickerBox.Visible then
                        ColorPickerBox.Position = UDim2.new(0, ColorBadge.AbsolutePosition.X - 120, 0, ColorBadge.AbsolutePosition.Y + ColorBadge.AbsoluteSize.Y + 4)
                        RageLibrary:PlaySound("Dropdown")
                    end
                end)

                updateCardSize()

                return {
                    SetValue = function(newCol)
                        currentColor = newCol
                        h, s, v = Color3.toHSV(currentColor)
                        SVCursor.Position = UDim2.new(s, -3, 1 - v, -3)
                        HueCursor.Position = UDim2.new(0, -2, h, -1)
                        updateColor()
                    end,
                    GetValue = function() return currentColor end
                }
            end

            SectionObj.AddColorPicker = SectionObj.AddColorpicker

            return SectionObj
        end

        return TabObj
    end

    -- ================================================================
    -- SHARD BREAK / ASSEMBLE ANIMATION
    -- ================================================================
    local toggleKey = config.ToggleKey or RageLibrary.ToggleKey or Enum.KeyCode.RightShift
    local menuVisible = true
    local shardsActive = false

    -- Shard layout definitions: each covers a slice of the menu
    -- {relX, relY, relW, relH, rotFly, flyDX, flyDY, delay}
    local shardDefs = {
        { rx=0,    ry=0,    rw=0.48, rh=0.52, rot=-28, dx=-260, dy=-180, d=0.00 },
        { rx=0.46, ry=0,    rw=0.54, rh=0.44, rot=22,  dx=280,  dy=-160, d=0.04 },
        { rx=0,    ry=0.50, rw=0.40, rh=0.50, rot=20,  dx=-240, dy=200,  d=0.02 },
        { rx=0.38, ry=0.42, rw=0.62, rh=0.58, rot=-24, dx=270,  dy=190,  d=0.06 },
        { rx=0.18, ry=0.20, rw=0.36, rh=0.45, rot=35,  dx=-60,  dy=-280, d=0.03 },
        { rx=0.54, ry=0.18, rw=0.32, rh=0.38, rot=-30, dx=120,  dy=-260, d=0.05 },
        { rx=0.10, ry=0.68, rw=0.30, rh=0.32, rot=-18, dx=-200, dy=240,  d=0.01 },
        { rx=0.58, ry=0.62, rw=0.28, rh=0.38, rot=26,  dx=220,  dy=220,  d=0.07 },
    }

    local shards = {}

    local function createShards()
        -- Remove old shards
        for _, s in ipairs(shards) do s:Destroy() end
        shards = {}

        local mPos  = MainFrame.AbsolutePosition
        local mSize = MainFrame.AbsoluteSize

        for i, def in ipairs(shardDefs) do
            local sx = mPos.X  + def.rx * mSize.X
            local sy = mPos.Y  + def.ry * mSize.Y
            local sw = def.rw  * mSize.X
            local sh = def.rh  * mSize.Y

            local shard = Instance.new("Frame")
            shard.Name  = "MenuShard_" .. i
            shard.Size  = UDim2.new(0, sw, 0, sh)
            shard.Position = UDim2.new(0, sx, 0, sy)
            shard.BackgroundColor3 = RageLibrary.Theme.Background
            shard.BackgroundTransparency = 0
            shard.BorderSizePixel = 0
            shard.ZIndex = 50000
            shard.Parent = ScreenGui
            -- Slight inner gradient overlay for realism
            local innerStroke = Instance.new("UIStroke")
            innerStroke.Color = RageLibrary.Theme.Accent
            innerStroke.Thickness = 1
            innerStroke.Transparency = 0.6
            innerStroke.Parent = shard
            -- Random edge rounding for crooked feel
            local corners = {3, 5, 8, 4, 6, 2, 7, 5}
            addCorner(shard, corners[(i % #corners) + 1])
            shards[i] = shard
        end
    end

    local function animateShardsOut(onDone)
        shardsActive = true
        createShards()

        local mPos  = MainFrame.AbsolutePosition
        local mSize = MainFrame.AbsoluteSize

        local done = 0
        local total = #shards

        for i, shard in ipairs(shards) do
            local def = shardDefs[i]
            local targetX = shard.AbsolutePosition.X + def.dx
            local targetY = shard.AbsolutePosition.Y + def.dy

            task.delay(def.d, function()
                -- Animate to exploded position with rotation
                TweenService:Create(shard,
                    TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.In),
                    {
                        Position = UDim2.new(0, targetX, 0, targetY),
                        Rotation = def.rot,
                        BackgroundTransparency = 0.85,
                    }
                ):Play()

                task.delay(0.55, function()
                    done = done + 1
                    if done >= total then
                        shardsActive = false
                        if onDone then onDone() end
                    end
                end)
            end)
        end
    end

    local function animateShardsIn(onDone)
        if #shards == 0 then
            createShards()
            local mPos  = MainFrame.AbsolutePosition
            local mSize = MainFrame.AbsoluteSize
            for i, shard in ipairs(shards) do
                local def = shardDefs[i]
                local originX = mPos.X + def.rx * mSize.X
                local originY = mPos.Y + def.ry * mSize.Y
                shard.Position = UDim2.new(0, originX + def.dx, 0, originY + def.dy)
                shard.Rotation = def.rot
                shard.BackgroundTransparency = 0.85
            end
        end

        shardsActive = true
        local mPos  = MainFrame.AbsolutePosition
        local mSize = MainFrame.AbsoluteSize

        local done = 0
        local total = #shards

        for i, shard in ipairs(shards) do
            local def = shardDefs[i]
            local targetX = mPos.X + def.rx * mSize.X
            local targetY = mPos.Y + def.ry * mSize.Y

            task.delay(def.d, function()
                -- Fly back into place
                TweenService:Create(shard,
                    TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    {
                        Position = UDim2.new(0, targetX, 0, targetY),
                        Rotation = 0,
                        BackgroundTransparency = 0,
                    }
                ):Play()

                task.delay(0.52, function()
                    done = done + 1
                    if done >= total then
                        shardsActive = false
                        -- Cleanup shards and show real frame
                        for _, s in ipairs(shards) do s:Destroy() end
                        shards = {}
                        if onDone then onDone() end
                    end
                end)
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == toggleKey then
            if shardsActive then return end
            menuVisible = not menuVisible
            RageLibrary.IsMenuVisible = menuVisible

            if menuVisible then
                -- OPEN: shards fly in → show menu
                RageLibrary:PlaySound("OpenMenu")
                MainFrame.Visible = false
                animateShardsIn(function()
                    MainFrame.Visible = true
                    MainFrame.BackgroundTransparency = 0
                end)
            else
                -- CLOSE: snapshot → shards fly out → hide menu
                RageLibrary:PlaySound("CloseMenu")
                -- Close any open drop lists / mode menus
                for _, child in ipairs(ScreenGui:GetChildren()) do
                    if child.Name:sub(1, 9) == "ModeMenu_" or child.Name:sub(1, 9) == "DropList_" or child.Name:sub(1, 14) == "MultiDropList_" or child.Name:sub(1, 12) == "ColorPicker_" then
                        child.Visible = false
                    end
                end
                animateShardsOut(function()
                    MainFrame.Visible = false
                    for _, s in ipairs(shards) do s:Destroy() end
                    shards = {}
                end)
                -- Hide real menu immediately so shards take over
                task.delay(0.05, function() MainFrame.Visible = false end)
            end
        end
    end)


    return WindowObj
end

return RageLibrary
