-- [[ RAGE.LIBRARY — NEVERLOSE / GAMESENSE / PROJECT AURORA STYLE RAGE CHEAT UI ENGINE ]] --
-- Engine Version: 1.0.0
-- Architecture: Dual-Column Card Layout with Vertical Sidebar & Integrated Widgets

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
        },
        ["Neverlose Cyan"] = {
            Background = Color3.fromRGB(11, 14, 20),
            Block = Color3.fromRGB(16, 20, 29),
            Header = Color3.fromRGB(22, 27, 39),
            Card = Color3.fromRGB(26, 32, 46),
            Accent = Color3.fromRGB(0, 148, 255),
            AccentDim = Color3.fromRGB(0, 105, 185),
            Text = Color3.fromRGB(240, 244, 250),
            TextDim = Color3.fromRGB(145, 158, 178),
            Stroke = Color3.fromRGB(36, 44, 62),
            StrokeActive = Color3.fromRGB(0, 148, 255),
            StrokeHover = Color3.fromRGB(200, 220, 255),
        },
        ["Gamesense Mint"] = {
            Background = Color3.fromRGB(12, 14, 18),
            Block = Color3.fromRGB(17, 20, 26),
            Header = Color3.fromRGB(23, 27, 35),
            Card = Color3.fromRGB(28, 33, 43),
            Accent = Color3.fromRGB(162, 216, 61),
            AccentDim = Color3.fromRGB(115, 155, 40),
            Text = Color3.fromRGB(240, 245, 250),
            TextDim = Color3.fromRGB(145, 155, 170),
            Stroke = Color3.fromRGB(36, 42, 54),
            StrokeActive = Color3.fromRGB(162, 216, 61),
            StrokeHover = Color3.fromRGB(210, 240, 160),
        }
    },
    Theme = nil, -- Assigned below
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
        World           = "rbxassetid://122563205713088", -- earth white
        Auto            = "rbxassetid://102927017461693", -- loading v2
        Guns            = "rbxassetid://84647432170503",  -- iconarma
        Skins           = "rbxassetid://101708694952341"  -- Pencil Icon
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

-- Top Watermark Widget (Red-Black-Grey High Tech Design)
local Watermark = Instance.new("Frame")
Watermark.Name = "RageWatermark"
Watermark.Size = UDim2.new(0, 480, 0, 30)
Watermark.Position = UDim2.new(0.5, -240, 0, 10)
Watermark.BackgroundColor3 = RageLibrary.Theme.Block
Watermark.BorderSizePixel = 0
Watermark.ClipsDescendants = false
Watermark.Parent = ScreenGui
addCorner(Watermark, 6)
local WMarkStroke = addStroke(Watermark, RageLibrary.Theme.Accent, 1.2)

-- Left Edge Crimson Accent Bar
local WMarkEdge = Instance.new("Frame")
WMarkEdge.Size = UDim2.new(0, 3, 1, 0)
WMarkEdge.Position = UDim2.new(0, 0, 0, 0)
WMarkEdge.BackgroundColor3 = RageLibrary.Theme.Accent
WMarkEdge.BorderSizePixel = 0
WMarkEdge.Parent = Watermark
addCorner(WMarkEdge, 3)

local WMarkContent = Instance.new("Frame")
WMarkContent.Size = UDim2.new(1, -6, 1, 0)
WMarkContent.Position = UDim2.new(0, 6, 0, 0)
WMarkContent.BackgroundTransparency = 1
WMarkContent.Parent = Watermark

local WMarkLayout = Instance.new("UIListLayout")
WMarkLayout.FillDirection = Enum.FillDirection.Horizontal
WMarkLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
WMarkLayout.VerticalAlignment = Enum.VerticalAlignment.Center
WMarkLayout.Padding = UDim.new(0, 8)
WMarkLayout.Parent = WMarkContent

-- 1. Logo
local WMarkLogo = Instance.new("ImageLabel")
WMarkLogo.Size = UDim2.new(0, 16, 0, 16)
WMarkLogo.BackgroundTransparency = 1
WMarkLogo.Image = RageLibrary.Icons.Logo
WMarkLogo.ImageColor3 = RageLibrary.Theme.Accent
WMarkLogo.Parent = WMarkContent

-- 2. Cheat Title
local WMarkTitle = Instance.new("TextLabel")
WMarkTitle.Size = UDim2.new(0, 95, 1, 0)
WMarkTitle.BackgroundTransparency = 1
WMarkTitle.Font = RageLibrary.Fonts.Header
WMarkTitle.Text = "PROJECT AURORA"
WMarkTitle.TextColor3 = RageLibrary.Theme.Text
WMarkTitle.TextSize = 10.5
WMarkTitle.TextXAlignment = Enum.TextXAlignment.Left
WMarkTitle.Parent = WMarkContent

local function addWMDivider()
    local div = Instance.new("Frame")
    div.Size = UDim2.new(0, 1, 0, 14)
    div.BackgroundColor3 = RageLibrary.Theme.Stroke
    div.BorderSizePixel = 0
    div.Parent = WMarkContent
end

addWMDivider()

-- 3. Player Avatar & Username
local AvatarHolder = Instance.new("Frame")
AvatarHolder.Size = UDim2.new(0, 18, 0, 18)
AvatarHolder.BackgroundTransparency = 1
AvatarHolder.Parent = WMarkContent

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.new(1, 0, 1, 0)
AvatarImg.BackgroundTransparency = 1
AvatarImg.Image = "rbxassetid://0"
AvatarImg.Parent = AvatarHolder
addCorner(AvatarImg, 9)

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
UserLabel.TextSize = 9.5
UserLabel.TextTruncate = Enum.TextTruncate.AtEnd
UserLabel.TextXAlignment = Enum.TextXAlignment.Left
UserLabel.Parent = WMarkContent

addWMDivider()

-- 4. FPS Counter
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 52, 1, 0)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Font = RageLibrary.Fonts.Badge
FPSLabel.Text = "144 FPS"
FPSLabel.TextColor3 = RageLibrary.Theme.Accent
FPSLabel.TextSize = 9.5
FPSLabel.Parent = WMarkContent

addWMDivider()

-- 5. Ping Counter
local PingLabel = Instance.new("TextLabel")
PingLabel.Size = UDim2.new(0, 42, 1, 0)
PingLabel.BackgroundTransparency = 1
PingLabel.Font = RageLibrary.Fonts.Badge
PingLabel.Text = "15 ms"
PingLabel.TextColor3 = RageLibrary.Theme.TextDim
PingLabel.TextSize = 9.5
PingLabel.Parent = WMarkContent

addWMDivider()

-- 6. Clock Time
local TimeLabel = Instance.new("TextLabel")
TimeLabel.Size = UDim2.new(0, 55, 1, 0)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Font = RageLibrary.Fonts.Badge
TimeLabel.Text = os.date("%H:%M:%S")
TimeLabel.TextColor3 = RageLibrary.Theme.TextDim
TimeLabel.TextSize = 9.5
TimeLabel.Parent = WMarkContent

makeDraggable(Watermark, Watermark)

-- FPS, Ping & Time Loop
local frameCount = 0
local lastFpsCheck = tick()
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFpsCheck >= 1 then
        FPSLabel.Text = frameCount .. " FPS"
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
    local winTitle = config.Title or "PROJECT AURORA"
    local winSubTitle = config.SubTitle or "ROBLOX RAGE CLIENT V1.0"
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

    -- Background Wallpaper Image Layer
    local MenuBgImg = Instance.new("ImageLabel")
    MenuBgImg.Name = "MenuBgWallpaper"
    MenuBgImg.Size = UDim2.new(1, 0, 1, 0)
    MenuBgImg.Position = UDim2.new(0, 0, 0, 0)
    MenuBgImg.BackgroundTransparency = 1
    MenuBgImg.Image = config.BackgroundImage or RageLibrary.Icons.BackgroundImage
    MenuBgImg.ImageTransparency = 0.35
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

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -90, 1, 0)
                Label.Position = UDim2.new(0, 8, 0, 0)
                Label.BackgroundTransparency = 1
                Label.Font = RageLibrary.Fonts.Label
                Label.Text = name
                Label.TextColor3 = RageLibrary.Theme.Text
                Label.TextSize = 10
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.Parent = ToggleRow

                -- Right Side Container (Switch + Optional Keybind)
                local RightControls = Instance.new("Frame")
                RightControls.Size = UDim2.new(0, 80, 1, 0)
                RightControls.Position = UDim2.new(1, -84, 0, 0)
                RightControls.BackgroundTransparency = 1
                RightControls.Parent = ToggleRow

                local ControlsLayout = Instance.new("UIListLayout")
                ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
                ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                ControlsLayout.Padding = UDim.new(0, 5)
                ControlsLayout.Parent = RightControls

                -- Optional Inline Keybind Badge
                local KeyBadge = nil
                if bindKey then
                    KeyBadge = Instance.new("TextButton")
                    KeyBadge.Size = UDim2.new(0, 36, 0, 16)
                    KeyBadge.BackgroundColor3 = RageLibrary.Theme.Header
                    KeyBadge.BorderSizePixel = 0
                    KeyBadge.Font = RageLibrary.Fonts.Badge
                    KeyBadge.Text = "[" .. (typeof(bindKey) == "EnumItem" and bindKey.Name or tostring(bindKey)) .. "]"
                    KeyBadge.TextColor3 = RageLibrary.Theme.TextDim
                    KeyBadge.TextSize = 8.5
                    KeyBadge.Parent = RightControls
                    addCorner(KeyBadge, 3)

                    local isListening = false
                    KeyBadge.MouseButton1Click:Connect(function()
                        isListening = true
                        KeyBadge.Text = "[...]"
                        KeyBadge.TextColor3 = RageLibrary.Theme.Accent
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                isListening = false
                                bindKey = input.KeyCode
                                KeyBadge.Text = "[" .. bindKey.Name .. "]"
                                KeyBadge.TextColor3 = RageLibrary.Theme.TextDim
                                conn:Disconnect()
                            end
                        end)
                    end)
                end

                -- Toggle Switch
                local SwitchBg = Instance.new("Frame")
                SwitchBg.Size = UDim2.new(0, 28, 0, 14)
                SwitchBg.BackgroundColor3 = state and RageLibrary.Theme.Accent or RageLibrary.Theme.Header
                SwitchBg.BorderSizePixel = 0
                SwitchBg.Parent = RightControls
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
                    smoothTween(Btn, 0.1, { BackgroundColor3 = RageLibrary.Theme.Accent }):Completed:Connect(function()
                        smoothTween(Btn, 0.2, { BackgroundColor3 = RageLibrary.Theme.Header })
                    end)
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

            function SectionObj:AddDropdown(cfg)
                local name = type(cfg) == "table" and cfg.Name or "Dropdown"
                local options = type(cfg) == "table" and cfg.Options or {}
                local selected = type(cfg) == "table" and (cfg.Default or options[1]) or ""
                local cb = type(cfg) == "table" and cfg.Callback or nil

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
                DropBtn.Text = "  " .. tostring(selected) .. " v"
                DropBtn.TextColor3 = RageLibrary.Theme.Accent
                DropBtn.TextSize = 9.5
                DropBtn.TextXAlignment = Enum.TextXAlignment.Left
                DropBtn.Parent = DropRow
                addCorner(DropBtn, 4)

                updateCardSize()
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

pcall(function()
    task.defer(function()
        RageLibrary:PlaySound("Init")
    end)
end)

print("[RageLibrary] ✅ Neverlose / Gamesense / Aurora UI Library ready with custom audio!")
return RageLibrary
