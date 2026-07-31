-- [[ PROJECT AURORA — ULTIMATE STANDALONE ALL-IN-ONE RAGE SCRIPT ]] --
-- Engine Version: 1.1.0
-- Everything in 1 single file for immediate execution in Roblox Executor!

local RageLibrary = {
    Enabled = true,
    CurrentThemeName = "Crimson Rage",
    Themes = {
        ["Crimson Rage"] = {
            Background = Color3.fromRGB(10, 10, 12),      -- Pitch Black (#0A0A0C)
            Block = Color3.fromRGB(16, 16, 20),           -- Dark Charcoal (#101014)
            Header = Color3.fromRGB(22, 22, 28),          -- Deep Slate Grey (#16161C)
            Card = Color3.fromRGB(26, 26, 32),            -- Card Grey (#1A1A20)
            Accent = Color3.fromRGB(255, 35, 55),         -- Blood Crimson Red (#FF2337)
            AccentDim = Color3.fromRGB(180, 20, 35),
            Text = Color3.fromRGB(245, 245, 245),         -- Pure White
            TextDim = Color3.fromRGB(140, 140, 150),      -- Metallic Grey
            Stroke = Color3.fromRGB(40, 40, 48),          -- Dark Graphite
            StrokeActive = Color3.fromRGB(255, 35, 55),    -- Crimson Glow
            StrokeHover = Color3.fromRGB(255, 90, 110),
        }
    },
    Theme = nil,
    Fonts = {
        Header = Enum.Font.GothamBold,
        Label = Enum.Font.GothamMedium,
        Badge = Enum.Font.Code,
    },
    Sounds = {
        Init = "rbxassetid://85298897773513",
        Click = "rbxassetid://139719503904449",
        ToggleOn = "rbxassetid://15675059323",
        ToggleOff = "rbxassetid://87437544236708",
        OpenMenu = "rbxassetid://127366656618533",
        CloseMenu = "rbxassetid://139295675611093",
        Notification = "rbxassetid://6895092003",
        Hitmark = "rbxassetid://160432334"
    },
    Icons = {
        Logo            = "rbxassetid://122540234795087",
        BackgroundImage = "rbxassetid://134394687990758",
        Combat          = "rbxassetid://12614416478",      
        Movement        = "rbxassetid://136160678435000", 
        Visuals         = "rbxassetid://102976018150012", 
        Misc            = "rbxassetid://137382232901580", 
        World           = "rbxassetid://122563205713088",
        Auto            = "rbxassetid://102927017461693",
        Guns            = "rbxassetid://84647432170503",
        Skins           = "rbxassetid://101708694952341"
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

local function smoothTween(inst, dur, props)
    if not inst then return end
    local info = TweenInfo.new(dur or DUR_NORMAL, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    local tween = TweenService:Create(inst, info, props)
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

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            smoothTween(frame, DUR_FAST, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            })
        end
    end)
end

-- Sound System Engine
function RageLibrary:PlaySound(soundName)
    local soundId = self.Sounds[soundName] or soundName
    if not soundId or soundId == "" then return end
    pcall(function()
        local s = Instance.new("Sound")
        s.SoundId = soundId
        s.Volume = 0.5
        s.Parent = game:GetService("SoundService")
        s:Play()
        task.delay(2, function() s:Destroy() end)
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
-- NEW WATERMARK DESIGN (100% REWRITTEN FROM SCRATCH - ULTRA SLEEK)
-- =================================================================
local Watermark = Instance.new("Frame")
Watermark.Name = "RageWatermark"
Watermark.Size = UDim2.new(0, 410, 0, 26)
Watermark.Position = UDim2.new(1, -420, 0, 10)
Watermark.BackgroundColor3 = RageLibrary.Theme.Background
Watermark.BorderSizePixel = 0
Watermark.ClipsDescendants = false
Watermark.Parent = ScreenGui
addCorner(Watermark, 6)
addStroke(Watermark, RageLibrary.Theme.Accent, 1)

local WMarkContent = Instance.new("Frame")
WMarkContent.Size = UDim2.new(1, -8, 1, 0)
WMarkContent.Position = UDim2.new(0, 4, 0, 0)
WMarkContent.BackgroundTransparency = 1
WMarkContent.Parent = Watermark

local WMarkLayout = Instance.new("UIListLayout")
WMarkLayout.FillDirection = Enum.FillDirection.Horizontal
WMarkLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
WMarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WMarkLayout.Padding = UDim.new(0, 6)
WMarkLayout.Parent = WMarkContent

-- 1. Brand Tag Badge (Glowing Crimson)
local BrandBadge = Instance.new("TextLabel")
BrandBadge.Size = UDim2.new(0, 65, 0, 16)
BrandBadge.BackgroundColor3 = RageLibrary.Theme.Accent
BrandBadge.BorderSizePixel = 0
BrandBadge.Font = RageLibrary.Fonts.Header
BrandBadge.Text = "AURORA"
BrandBadge.TextColor3 = RageLibrary.Theme.Text
BrandBadge.TextSize = 9.5
BrandBadge.Parent = WMarkContent
addCorner(BrandBadge, 4)

local function addWMDivider()
    local div = Instance.new("Frame")
    div.Size = UDim2.new(0, 1, 0, 12)
    div.BackgroundColor3 = RageLibrary.Theme.Stroke
    div.BorderSizePixel = 0
    div.Parent = WMarkContent
end

addWMDivider()

-- 2. Player Avatar Headshot & Username
local AvatarHolder = Instance.new("Frame")
AvatarHolder.Size = UDim2.new(0, 16, 0, 16)
AvatarHolder.BackgroundTransparency = 1
AvatarHolder.Parent = WMarkContent

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(1, 0, 1, 0)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = "rbxassetid://0"
AvatarImg.Parent = AvatarHolder
addCorner(AvatarImg, 8)

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
UserLabel.Size = UDim2.new(0, 75, 1, 0)
UserLabel.BackgroundTransparency = 1
UserLabel.Font = RageLibrary.Fonts.Badge
UserLabel.Text = LocalPlayer and LocalPlayer.Name or "User"
UserLabel.TextColor3 = RageLibrary.Theme.Text
UserLabel.TextSize = 9
UserLabel.TextTruncate = Enum.TextTruncate.AtEnd
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = WMarkContent

addWMDivider()

-- 3. FPS Counter
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 52, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Font = RageLibrary.Fonts.Badge
FPSLabel.Text = "⚡ 144 FPS"
FPSLabel.TextColor3 = RageLibrary.Theme.Accent
FPSLabel.TextSize = 9
FPSLabel.Parent = WMarkContent

addWMDivider()

-- 4. Ping Counter
local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 45, 1, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = RageLibrary.Fonts.Badge
PingLabel.Text = "📶 15 ms"
PingLabel.TextColor3 = RageLibrary.Theme.TextDim
PingLabel.TextSize = 9
PingLabel.Parent = WMarkContent

addWMDivider()

-- 5. Real-Time Clock
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0, 60, 1, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Font = RageLibrary.Fonts.Badge
TimeLabel.Text = os.date("🕒 %H:%M:%S")
TimeLabel.TextColor3 = RageLibrary.Theme.TextDim
TimeLabel.TextSize = 9
TimeLabel.Parent = WMarkContent

makeDraggable(Watermark, Watermark)

-- Live Metrics Loop
local frameCount = 0
local lastFpsCheck = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsCheck >= 1 then
        FPSLabel.Text = "⚡ " .. frameCount .. " FPS"
        frameCount = 0
        lastFpsCheck = now

        local pingMs = 0
        pcall(function()
            local stats = game:GetService("Stats")
            local dataPing = stats.Network.ServerStatsItem:FindFirstChild("Data Ping")
            if dataPing then pingMs = math.floor(dataPing:GetValue()) end
        end)
        PingLabel.Text = "📶 " .. pingMs .. " ms"
        TimeLabel.Text = os.date("🕒 %H:%M:%S")
    end
end)

-- Main Cheat Window Factory Function
function RageLibrary:CreateWindow(config)
    config = config or {}
    local winTitle = config.Title or "PROJECT AURORA"
    local winSubTitle = config.SubTitle or "ROBLOX RAGE CLIENT V1.1"
    local winSize = config.Size or UDim2.new(0, 720, 0, 480)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "RageMainFrame"
    MainFrame.Size = winSize
    MainFrame.Position = UDim2.new(0.5, -winSize.X.Offset / 2, 0.5, -winSize.Y.Offset / 2)
    MainFrame.BackgroundColor3 = RageLibrary.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    addCorner(MainFrame, 8)
    local MainStroke = addStroke(MainFrame, RageLibrary.Theme.Stroke, 1.2)

    -- Background Wallpaper Image Layer (Inset & Scaled)
    local MenuBgImg = Instance.new("ImageLabel")
    MenuBgImg.Name = "MenuBgWallpaper"
    MenuBgImg.Size = UDim2.new(0.92, 0, 0.92, 0)
    MenuBgImg.Position = UDim2.new(0.04, 0, 0.04, 0)
    MenuBgImg.BackgroundTransparency = 1
    MenuBgImg.Image = config.BackgroundImage or RageLibrary.Icons.BackgroundImage
    MenuBgImg.ImageTransparency = 0.45
    MenuBgImg.ScaleType = Enum.ScaleType.Crop
    MenuBgImg.ZIndex = 0
    MenuBgImg.Parent = MainFrame
    addCorner(MenuBgImg, 8)

    -- Left Sidebar Navigation
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 165, 1, 0)
    Sidebar.BackgroundColor3 = RageLibrary.Theme.Block
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    addCorner(Sidebar, 8)

    local SidebarLogo = Instance.new("ImageLabel")
    SidebarLogo.Size = UDim2.new(0, 22, 0, 22)
    SidebarLogo.Position = UDim2.new(0, 10, 0, 12)
    SidebarLogo.BackgroundTransparency = 1
    SidebarLogo.Image = RageLibrary.Icons.Logo
    SidebarLogo.ImageColor3 = RageLibrary.Theme.Accent
    SidebarLogo.Parent = Sidebar

    local LogoTitle = Instance.new("TextLabel")
    LogoTitle.Size = UDim2.new(1, -40, 0, 24)
    LogoTitle.Position = UDim2.new(0, 36, 0, 11)
    LogoTitle.BackgroundTransparency = 1
    LogoTitle.Font = RageLibrary.Fonts.Header
    LogoTitle.Text = winTitle
    LogoTitle.TextColor3 = RageLibrary.Theme.Accent
    LogoTitle.TextSize = 13
    LogoTitle.TextXAlignment = Enum.TextXAlignment.Left
    LogoTitle.Parent = Sidebar

    local LogoSub = Instance.new("TextLabel")
    LogoSub.Size = UDim2.new(1, -40, 0, 16)
    LogoSub.Position = UDim2.new(0, 36, 0, 31)
    LogoSub.BackgroundTransparency = 1
    LogoSub.Font = RageLibrary.Fonts.Label
    LogoSub.Text = winSubTitle
    LogoSub.TextColor3 = RageLibrary.Theme.TextDim
    LogoSub.TextSize = 8.5
    LogoSub.TextXAlignment = Enum.TextXAlignment.Left
    LogoSub.Parent = Sidebar

    -- Scrollable Sidebar Navigation Holder
    local NavHolder = Instance.new("ScrollingFrame")
    NavHolder.Size = UDim2.new(1, -16, 1, -65)
    NavHolder.Position = UDim2.new(0, 8, 0, 56)
    NavHolder.BackgroundTransparency = 1
    NavHolder.BorderSizePixel = 0
    NavHolder.ScrollBarThickness = 2
    NavHolder.ScrollBarImageColor3 = RageLibrary.Theme.Accent
    NavHolder.Parent = Sidebar

    local NavLayout = Instance.new("UIListLayout")
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.Parent = NavHolder

    NavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        NavHolder.CanvasSize = UDim2.new(0, 0, 0, NavLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Content Area (Right Side)
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -175, 1, -16)
    ContentArea.Position = UDim2.new(0, 170, 0, 8)
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
        TabBtn.BackgroundTransparency = 0.5
        TabBtn.BorderSizePixel = 0
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
            for _, t in ipairs(WindowObj.Tabs) do
                t.Page.Visible = false
                smoothTween(t.Btn, DUR_FAST, { BackgroundTransparency = 0.5 })
                smoothTween(t.TextLbl, DUR_FAST, { TextColor3 = RageLibrary.Theme.TextDim })
                if t.IconImg then
                    smoothTween(t.IconImg, DUR_FAST, { ImageColor3 = RageLibrary.Theme.TextDim })
                end
                t.Indicator.Visible = false
            end
            TabPage.Visible = true
            TabIndicator.Visible = true
            smoothTween(TabBtn, DUR_FAST, { BackgroundTransparency = 0 })
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
            selectTab()
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:AddSection(secName, columnSide)
            columnSide = (columnSide and columnSide:lower() == "right") and "right" or "left"
            local parentCol = (columnSide == "right") and RightCol or LeftCol

            local Card = Instance.new("Frame")
            Card.Name = "Section_" .. secName
            Card.Size = UDim2.new(1, -4, 0, 36)
            Card.BackgroundColor3 = RageLibrary.Theme.Card
            Card.BorderSizePixel = 0
            Card.Parent = parentCol
            addCorner(Card, 6)
            addStroke(Card, RageLibrary.Theme.Stroke, 1)

            local CardTitle = Instance.new("TextLabel")
            CardTitle.Size = UDim2.new(1, -20, 0, 24)
            CardTitle.Position = UDim2.new(0, 10, 0, 6)
            CardTitle.BackgroundTransparency = 1
            CardTitle.Font = RageLibrary.Fonts.Header
            CardTitle.Text = string.upper(secName)
            CardTitle.TextColor3 = RageLibrary.Theme.Accent
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

            -- TOGGLE (KEYBIND ON THE LEFT SIDE)
            function SectionObj:AddToggle(cfg, legacyDefault, legacyCb)
                local name = type(cfg) == "table" and cfg.Name or cfg
                local state = (type(cfg) == "table" and cfg.Default) or (type(cfg) ~= "table" and legacyDefault) or false
                local callback = (type(cfg) == "table" and cfg.Callback) or legacyCb
                local bindKey = type(cfg) == "table" and cfg.Keybind or nil

                local ToggleRow = Instance.new("TextButton")
                ToggleRow.Size = UDim2.new(1, 0, 0, 28)
                ToggleRow.BackgroundColor3 = RageLibrary.Theme.Block
                ToggleRow.BorderSizePixel = 0
                ToggleRow.AutoButtonColor = false
                ToggleRow.Text = ""
                ToggleRow.Parent = ItemsHolder
                addCorner(ToggleRow, 5)

                local labelStartX = 8

                -- Left Side Keybind Badge
                local KeyBadge = nil
                if bindKey then
                    KeyBadge = Instance.new("TextButton")
                    KeyBadge.Size = UDim2.new(0, 32, 0, 16)
                    KeyBadge.Position = UDim2.new(0, 6, 0.5, -8)
                    KeyBadge.BackgroundColor3 = RageLibrary.Theme.Header
                    KeyBadge.BorderSizePixel = 0
                    KeyBadge.Font = RageLibrary.Fonts.Badge
                    KeyBadge.Text = "[" .. (typeof(bindKey) == "EnumItem" and bindKey.Name or tostring(bindKey)) .. "]"
                    KeyBadge.TextColor3 = RageLibrary.Theme.Accent
                    KeyBadge.TextSize = 8.5
                    KeyBadge.Parent = ToggleRow
                    addCorner(KeyBadge, 3)
                    addStroke(KeyBadge, RageLibrary.Theme.Accent, 1)

                    local isListening = false
                    KeyBadge.MouseButton1Click:Connect(function()
                        isListening = true
                        KeyBadge.Text = "[...]"
                        KeyBadge.TextColor3 = RageLibrary.Theme.Text
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                isListening = false
                                bindKey = input.KeyCode
                                KeyBadge.Text = "[" .. bindKey.Name .. "]"
                                KeyBadge.TextColor3 = RageLibrary.Theme.Accent
                                conn:Disconnect()
                            end
                        end)
                    end)
                    labelStartX = 44
                end

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -labelStartX - 40, 1, 0)
                Label.Position = UDim2.new(0, labelStartX, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleRow

                -- Right Side Switch
                local SwitchBg = Instance.new("Frame")
                SwitchBg.Size = UDim2.new(0, 28, 0, 14)
                SwitchBg.Position = UDim2.new(1, -34, 0.5, -7)
                SwitchBg.BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header
                SwitchBg.BorderSizePixel = 0
                SwitchBg.Parent = ToggleRow
                addCorner(SwitchBg, 7)

                local Knob = Instance.new("Frame")
                Knob.Size = UDim2.new(0, 10, 0, 10)
                Knob.Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
                Knob.BackgroundColor3 = state and RageLibrary.Theme.Background or RageLibrary.Theme.TextDim
                Knob.BorderSizePixel = 0
                Knob.Parent = SwitchBg
                addCorner(Knob, 5)

                ToggleRow.MouseButton1Click:Connect(function()
                    state = not state
                    smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header })
                    smoothTween(Knob, DUR_FAST, {
                        Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
                        BackgroundColor3 = state and RageLibrary.Theme.Background or RageLibrary.Theme.TextDim
                    })
                    RageLibrary:PlaySound(state and "ToggleOn" or "ToggleOff")
                    if callback then callback(state) end
                end)

                updateCardSize()
                return {
                    SetState = function(val)
                        state = val
                        smoothTween(SwitchBg, DUR_FAST, { BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header })
                        smoothTween(Knob, DUR_FAST, {
                            Position = state and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
                            BackgroundColor3 = state and RageLibrary.Theme.Background or RageLibrary.Theme.TextDim
                        })
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

            function SectionObj:AddSlider(cfg, minVal, maxVal, defaultVal, callback)
                local name = type(cfg) == "table" and cfg.Name or cfg
                local min = (type(cfg) == "table" and cfg.Min) or minVal or 0
                local max = (type(cfg) == "table" and cfg.Max) or maxVal or 100
                local currentVal = math.clamp((type(cfg) == "table" and cfg.Default) or defaultVal or min, min, max)
                local suffix = (type(cfg) == "table" and cfg.Suffix) or ""
                local cb = (type(cfg) == "table" and cfg.Callback) or callback

                local SliderRow = Instance.new("Frame")
                SliderRow.Size = UDim2.new(1, 0, 0, 42)
                SliderRow.BackgroundColor3 = RageLibrary.Theme.Block
                SliderRow.BorderSizePixel = 0
                SliderRow.Parent = ItemsHolder
                addCorner(SliderRow, 5)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -65, 0, 18)
                Label.Position = UDim2.new(0, 8, 0, 3)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = SliderRow

                local ValBadge = Instance.new("TextLabel")
                ValBadge.Size = UDim2.new(0, 55, 0, 16)
                ValBadge.Position = UDim2.new(1, -60, 0, 4)
                ValBadge.BackgroundTransparency = 1
                ValBadge.Font = RageLibrary.Fonts.Badge
                ValBadge.Text = tostring(currentVal) .. suffix
                ValBadge.TextColor3 = RageLibrary.Theme.Accent
                ValBadge.TextSize = 9.5
                ValBadge.TextXAlignment = Enum.TextXAlignment.Right
                ValBadge.Parent = SliderRow

                local TrackBg = Instance.new("TextButton")
                TrackBg.Size = UDim2.new(1, -16, 0, 6)
                TrackBg.Position = UDim2.new(0, 8, 0, 26)
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

                local isDragging = false
                local function updateSlider(inputX)
                    local width = TrackBg.AbsoluteSize.X
                    if width <= 0 then return end
                    local r = math.clamp((inputX - TrackBg.AbsolutePosition.X) / width, 0, 1)
                    currentVal = math.floor(min + (max - min) * r + 0.5)
                    ValBadge.Text = tostring(currentVal) .. suffix
                    Fill.Size = UDim2.new(r, 0, 1, 0)
                    if cb then cb(currentVal) end
                end

                TrackBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isDragging = true
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
                DropRow.BorderSizePixel = 0
                DropRow.Parent = ItemsHolder
                addCorner(DropRow, 5)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -16, 0, 16)
                Label.Position = UDim2.new(0, 8, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.TextDim
                Label.TextSize = 9.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropRow

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, -16, 0, 20)
                DropBtn.Position = UDim2.new(0, 8, 0, 20)
                DropBtn.BackgroundColor3 = RageLibrary.Theme.Header
                DropBtn.BorderSizePixel = 0
                DropBtn.Font = RageLibrary.Fonts.Badge
                DropBtn.Text = "  " .. tostring(selected) .. "  ▼"
                DropBtn.TextColor3 = RageLibrary.Theme.Accent
                DropBtn.TextSize = 9.5
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.Parent = DropRow
                addCorner(DropBtn, 4)

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
                addStroke(DropList, RageLibrary.Theme.Accent, 1)

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
                        OptBtn.BackgroundColor3 = isSel and RageLibrary.Theme.Card or RageLibrary.Theme.Header
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Font = RageLibrary.Fonts.Label
                        OptBtn.Text = isSel and (" ✓ " .. tostring(opt)) or ("   " .. tostring(opt))
                        OptBtn.TextColor3 = isSel and RageLibrary.Theme.Accent or RageLibrary.Theme.Text
                        OptBtn.TextSize = 9
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.ZIndex = 10001
                        OptBtn.Parent = DropList
                        addCorner(OptBtn, 3)

                        OptBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            DropBtn.Text = "  " .. tostring(selected) .. "  ▼"
                            isOpen = false
                            DropList.Visible = false
                            RageLibrary:PlaySound("Click")
                            if cb then cb(selected) end
                        end)
                    end
                    local h = math.min(#options * 22 + 4, 120)
                    DropList.CanvasSize = UDim2.new(0, 0, 0, #options * 22)
                    return h
                end

                DropBtn.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
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
                DropRow.BorderSizePixel = 0
                DropRow.Parent = ItemsHolder
                addCorner(DropRow, 5)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -16, 0, 16)
                Label.Position = UDim2.new(0, 8, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.TextDim
                Label.TextSize = 9.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = DropRow

                local DropBtn = Instance.new("TextButton")
                DropBtn.Size = UDim2.new(1, -16, 0, 20)
                DropBtn.Position = UDim2.new(0, 8, 0, 20)
                DropBtn.BackgroundColor3 = RageLibrary.Theme.Header
                DropBtn.BorderSizePixel = 0
                DropBtn.Font = RageLibrary.Fonts.Badge
                DropBtn.Text = "  " .. getSummary() .. "  ▼"
                DropBtn.TextColor3 = RageLibrary.Theme.Accent
                DropBtn.TextSize = 9.5
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.TextTruncate = Enum.TextTruncate.AtEnd
                DropBtn.Parent = DropRow
                addCorner(DropBtn, 4)

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
                addStroke(DropList, RageLibrary.Theme.Accent, 1)

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
                        OptBtn.BackgroundColor3 = isChecked and RageLibrary.Theme.Card or RageLibrary.Theme.Header
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Font = RageLibrary.Fonts.Label
                        OptBtn.Text = isChecked and (" [✓] " .. tostring(opt)) or (" [  ] " .. tostring(opt))
                        OptBtn.TextColor3 = isChecked and RageLibrary.Theme.Accent or RageLibrary.Theme.TextDim
                        OptBtn.TextSize = 9
                        OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptBtn.ZIndex = 10001
                        OptBtn.Parent = DropList
                        addCorner(OptBtn, 3)

                        OptBtn.MouseButton1Click:Connect(function()
                            selectedMap[opt] = not selectedMap[opt]
                            OptBtn.Text = selectedMap[opt] and (" [✓] " .. tostring(opt)) or (" [  ] " .. tostring(opt))
                            OptBtn.TextColor3 = selectedMap[opt] and RageLibrary.Theme.Accent or RageLibrary.Theme.TextDim
                            OptBtn.BackgroundColor3 = selectedMap[opt] and RageLibrary.Theme.Card or RageLibrary.Theme.Header
                            DropBtn.Text = "  " .. getSummary() .. "  ▼"
                            RageLibrary:PlaySound(selectedMap[opt] and "ToggleOn" or "ToggleOff")

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

            function SectionObj:AddTextBox(cfg)
                local name = type(cfg) == "table" and cfg.Name or "Input"
                local placeholder = type(cfg) == "table" and cfg.Placeholder or "Type here..."
                local defaultText = type(cfg) == "table" and cfg.Default or ""
                local cb = type(cfg) == "table" and cfg.Callback or nil

                local BoxRow = Instance.new("Frame")
                BoxRow.Size = UDim2.new(1, 0, 0, 44)
                BoxRow.BackgroundColor3 = RageLibrary.Theme.Block
                BoxRow.BorderSizePixel = 0
                BoxRow.Parent = ItemsHolder
                addCorner(BoxRow, 5)

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -16, 0, 16)
                Label.Position = UDim2.new(0, 8, 0, 4)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.TextDim
                Label.TextSize = 9.5
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = BoxRow

                local BoxBg = Instance.new("Frame")
                BoxBg.Size = UDim2.new(1, -16, 0, 20)
                BoxBg.Position = UDim2.new(0, 8, 0, 20)
                BoxBg.BackgroundColor3 = RageLibrary.Theme.Header
                BoxBg.BorderSizePixel = 0
                BoxBg.Parent = BoxRow
                addCorner(BoxBg, 4)

                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, -10, 1, 0)
                Input.Position = UDim2.new(0, 5, 0, 0)
                Input.BackgroundTransparency = 1
                Input.Font = RageLibrary.Fonts.Badge
                Input.PlaceholderText = placeholder
                Input.PlaceholderColor3 = RageLibrary.Theme.TextDim
                Input.Text = defaultText
                Input.TextColor3 = RageLibrary.Theme.Text
                Input.TextSize = 9.5
                Input.TextXAlignment = Enum.TextXAlignment.Left
                Input.Parent = BoxBg

                Input.FocusLost:Connect(function(enter)
                    if cb then cb(Input.Text) end
                end)

                updateCardSize()
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

-- Toggle Keybind Listener
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == RageLibrary.ToggleKey then
        ScreenGui.Enabled = not ScreenGui.Enabled
        RageLibrary:PlaySound(ScreenGui.Enabled and "OpenMenu" or "CloseMenu")
    end
end)

-- =================================================================
-- BUILD ALL 8 TABS & FULL DEMO FEATURES INSIDE THIS SCRIPT!
-- =================================================================
local Window = RageLibrary:CreateWindow({
    Title = "PROJECT AURORA",
    SubTitle = "ROBLOX RAGE CLIENT V1.1",
    Size = UDim2.new(0, 720, 0, 480)
})

-- 1. COMBAT
local CombatTab = Window:AddTab("Combat")
local MainCombatSec = CombatTab:AddSection("Aimbot Main", "Left")
MainCombatSec:AddToggle({ Name = "Enable Silent Aimbot", Default = true, Keybind = Enum.KeyCode.E, Callback = function(s) end })
MainCombatSec:AddToggle({ Name = "Automatic Fire / AutoShoot", Default = true, Keybind = Enum.KeyCode.Q, Callback = function(s) end })
MainCombatSec:AddSlider({ Name = "Hit Chance", Min = 0, Max = 100, Default = 85, Suffix = "%", Callback = function(v) end })
MainCombatSec:AddSlider({ Name = "Minimum Damage", Min = 1, Max = 100, Default = 35, Suffix = " HP", Callback = function(v) end })
MainCombatSec:AddDropdown({ Name = "Hitbox Target", Options = {"Head", "HumanoidRootPart", "Torso", "Smart Random"}, Default = "Head", Callback = function(s) end })
MainCombatSec:AddMultiSelect({ Name = "Target Verification Filters", Options = {"Wallcheck", "Teamcheck", "Visible Only", "Forcefield Check"}, Default = {"Wallcheck", "Visible Only"}, Callback = function(l) end })

local TargetStrafeSec = CombatTab:AddSection("Target Strafe & Movement", "Right")
TargetStrafeSec:AddToggle({ Name = "Enable Target Strafe", Default = true, Keybind = Enum.KeyCode.V, Callback = function(s) end })
TargetStrafeSec:AddSlider({ Name = "Strafe Radius", Min = 2, Max = 25, Default = 12, Suffix = " studs", Callback = function(v) end })
TargetStrafeSec:AddSlider({ Name = "Strafe Speed", Min = 10, Max = 100, Default = 45, Callback = function(v) end })
TargetStrafeSec:AddDropdown({ Name = "Target Selection Logic", Options = {"Lowest Distance", "Lowest Health", "Highest Health", "FOV Center"}, Default = "Lowest Distance", Callback = function(s) end })

-- 2. MOVEMENT
local MoveTab = Window:AddTab("Movement")
local MoveSec = MoveTab:AddSection("Speed & Jump Mods", "Left")
MoveSec:AddToggle({ Name = "BunnyHop / Auto Hop", Default = true, Keybind = Enum.KeyCode.Space, Callback = function(s) end })
MoveSec:AddToggle({ Name = "Enable Speed Hack", Default = false, Keybind = Enum.KeyCode.Z, Callback = function(s) end })
MoveSec:AddSlider({ Name = "Speed Multiplier", Min = 1, Max = 10, Default = 3, Suffix = "x", Callback = function(v) end })
MoveSec:AddToggle({ Name = "Infinite Jump", Default = false, Keybind = Enum.KeyCode.C, Callback = function(s) end })

local FlySec = MoveTab:AddSection("Flight & Teleport", "Right")
FlySec:AddToggle({ Name = "Flight Mode", Default = false, Keybind = Enum.KeyCode.F, Callback = function(s) end })
FlySec:AddSlider({ Name = "Flight Speed", Min = 10, Max = 150, Default = 50, Suffix = " studs/s", Callback = function(v) end })
FlySec:AddToggle({ Name = "Noclip Collision Disabler", Default = false, Keybind = Enum.KeyCode.N, Callback = function(s) end })

-- 3. VISUALS
local VisTab = Window:AddTab("Visuals")
local ESP = VisTab:AddSection("Player ESP", "Left")
ESP:AddToggle({ Name = "Bounding Box ESP", Default = true, Callback = function(s) end })
ESP:AddToggle({ Name = "Name & Level ESP", Default = true, Callback = function(s) end })
ESP:AddToggle({ Name = "Health Bar ESP", Default = true, Callback = function(s) end })
ESP:AddToggle({ Name = "Weapon ESP", Default = true, Callback = function(s) end })
ESP:AddMultiSelect({ Name = "Active ESP Components", Options = {"Box", "Name", "Health", "Armor", "Chams", "Tracers"}, Default = {"Box", "Name", "Health"}, Callback = function(l) end })

local WorldVis = VisTab:AddSection("World & FOV", "Right")
WorldVis:AddToggle({ Name = "Custom FOV Circle", Default = true, Callback = function(s) end })
WorldVis:AddSlider({ Name = "FOV Radius", Min = 30, Max = 500, Default = 150, Suffix = " px", Callback = function(v) end })
WorldVis:AddToggle({ Name = "Fullbright / No Shadows", Default = true, Callback = function(s) end })

-- 4. MISC
local MiscTab = Window:AddTab("Misc")
local MiscSec = MiscTab:AddSection("General Utilities", "Left")
MiscSec:AddToggle({ Name = "Anti-AFK Disabler", Default = true, Callback = function(s) end })
MiscSec:AddToggle({ Name = "Auto Rejoin on Kick", Default = true, Callback = function(s) end })
MiscSec:AddButton({ Name = "Rejoin Server", Callback = function() end })

local TargetSec = MiscTab:AddSection("Target Focus & Chat", "Right")
TargetSec:AddTextBox({ Name = "Custom Target Username", Placeholder = "Type player username...", Callback = function(t) end })

-- 5. WORLD
local WorldTab = Window:AddTab("World")
local WorldSec = WorldTab:AddSection("Atmosphere & Skybox", "Left")
WorldSec:AddToggle({ Name = "Custom Skybox Changer", Default = true, Callback = function(s) end })
WorldSec:AddDropdown({ Name = "Skybox Preset", Options = {"Purple Nebula", "Cyberpunk City", "Midnight Blue"}, Default = "Purple Nebula", Callback = function(s) end })

-- 6. AUTO
local AutoTab = Window:AddTab("Auto")
local AutoSec = AutoTab:AddSection("Auto Farming", "Left")
AutoSec:AddToggle({ Name = "Auto Farm Mobs", Default = false, Keybind = Enum.KeyCode.X, Callback = function(s) end })
AutoSec:AddToggle({ Name = "Auto Collect Drops", Default = true, Callback = function(s) end })

-- 7. GUNS
local GunsTab = Window:AddTab("Guns")
local GunsSec = GunsTab:AddSection("Weapon Tuning", "Left")
GunsSec:AddToggle({ Name = "No Recoil", Default = true, Callback = function(s) end })
GunsSec:AddToggle({ Name = "No Spread", Default = true, Callback = function(s) end })
GunsSec:AddToggle({ Name = "Instant Reload", Default = true, Callback = function(s) end })

-- 8. SKINS
local SkinsTab = Window:AddTab("Skins")
local SkinsSec = SkinsTab:AddSection("Skin Changer", "Left")
SkinsSec:AddToggle({ Name = "Enable Custom Weapon Skins", Default = true, Callback = function(s) end })
SkinsSec:AddDropdown({ Name = "Selected Skin Theme", Options = {"Gold Dragon", "Asimov White", "Cyber Neon"}, Default = "Gold Dragon", Callback = function(s) end })
SkinsSec:AddMultiSelect({ Name = "Active Weapon Effects", Options = {"Glow Effect", "Flame Particles", "Electric Aura"}, Default = {"Glow Effect"}, Callback = function(l) end })

print("[RageLibrary] ✅ Standalone script with all 8 tabs loaded successfully!")
return RageLibrary
