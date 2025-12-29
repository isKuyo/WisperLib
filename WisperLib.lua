print("a")
local WisperLib = {}

local Development = true
local DevelopmentUserId = 944604813

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

if _G.WisperLibInstance then
    _G.WisperLibInstance:Destroy()
    _G.WisperLibInstance = nil
end

local IconKeywords = {
    Home = {"home", "main", "general", "principal"},
    Visual = {"visual", "esp", "render", "display"},
    Settings = {"settings", "config", "configuration", "opcoes", "options"}
}

local IconAssets = {
    Home = "rbxassetid://80485236798991",
    Visual = "rbxassetid://134539162713658",
    Settings = "rbxassetid://77861834748434",
    Default = "rbxassetid://7733960981"
}

local function GetAutoIcon(TabName)
    local LowerName = string.lower(TabName)
    
    for Category, Keywords in pairs(IconKeywords) do
        for _, Keyword in ipairs(Keywords) do
            if string.find(LowerName, Keyword) then
                return IconAssets[Category]
            end
        end
    end
    
    return IconAssets.Default
end

local function GetExecutor()
    if Development then
        return "Roblox"
    end
    
    local Success, Name, Version = pcall(function()
        return identifyexecutor()
    end)
    
    if Success and Name then
        if Version then
            return Name .. " " .. Version
        end
        return Name
    end
    
    return "Unknown"
end

local ExecutorName = GetExecutor()

local function GetGameName()
    local Success, Result = pcall(function()
        local MarketplaceService = game:GetService("MarketplaceService")
        local Info = MarketplaceService:GetProductInfo(game.PlaceId)
        return Info.Name
    end)
    
    if Success and Result then
        return Result
    end
    
    return "Unknown Game"
end

local GameName = GetGameName()

local function Create(ClassName, Properties)
    local Instance_ = Instance.new(ClassName)
    for Property, Value in pairs(Properties) do
        Instance_[Property] = Value
    end
    return Instance_
end

local function Tween(Object, Properties, Duration, EasingStyle, EasingDirection)
    EasingStyle = EasingStyle or Enum.EasingStyle.Quad
    EasingDirection = EasingDirection or Enum.EasingDirection.Out
    Duration = Duration or 0.2
    TweenService:Create(Object, TweenInfo.new(Duration, EasingStyle, EasingDirection), Properties):Play()
end

local function MakeDraggable(Frame, DragFrame)
    DragFrame = DragFrame or Frame
    local Dragging = false
    local DragInput, MousePos, FramePos

    DragFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            MousePos = Input.Position
            FramePos = Frame.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    DragFrame.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - MousePos
            Frame.Position = UDim2.new(
                FramePos.X.Scale,
                FramePos.X.Offset + Delta.X,
                FramePos.Y.Scale,
                FramePos.Y.Offset + Delta.Y
            )
        end
    end)
end

local Theme = {
    Background = Color3.fromRGB(13, 15, 18),
    Header = Color3.fromRGB(20, 23, 28),
    HeaderLine = Color3.fromRGB(26, 30, 36),
    ContentBackground = Color3.fromRGB(13, 15, 18),
    GroupBackground = Color3.fromRGB(22, 25, 30),
    GroupStroke = Color3.fromRGB(26, 30, 36),
    ButtonInactive = Color3.fromRGB(13, 15, 18),
    GradientColor1 = Color3.fromRGB(179, 206, 248),
    GradientColor2 = Color3.fromRGB(125, 143, 172),
    AvatarStroke = Color3.fromRGB(26, 30, 36),
    Accent = Color3.fromRGB(181, 208, 251),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 150),
    Divider = Color3.fromRGB(26, 30, 36),
    CheckboxEnabled = Color3.fromRGB(181, 208, 251),
    CheckboxDisabled = Color3.fromRGB(60, 61, 66),
    SliderBackground = Color3.fromRGB(35, 40, 50),
    SliderFill = Color3.fromRGB(100, 150, 200),
    InputBackground = Color3.fromRGB(22, 25, 30),
    Footer = Color3.fromRGB(20, 23, 28)
}

local ScreenGuiName = "WisperLib_" .. tostring(math.random(100000, 999999))

function WisperLib:CreateWindow(Config)
    Config = Config or {}
    Config.Title = Config.Title or "WisperLib"
    Config.Subtitle = Config.Subtitle or ""
    Config.Size = Config.Size or UDim2.new(0, 635, 0, 510)
    Config.Position = Config.Position or UDim2.new(0.5, -317, 0.5, -255)
    Config.KeyBind = Config.KeyBind or Enum.KeyCode.RightControl

    local ScreenGui = Create("ScreenGui", {
        Name = ScreenGuiName,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = -1
    })

    _G.WisperLibInstance = ScreenGui

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = Config.Position,
        Size = Config.Size,
        ClipsDescendants = true
    })

    local MainCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = MainFrame
    })

    local MainStroke = Create("UIStroke", {
        Parent = MainFrame,
        Color = Color3.fromRGB(50, 51, 56),
        Thickness = 1
    })

    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50)
    })

    local HeaderCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = Header
    })

    local HeaderCoverBottom = Create("Frame", {
        Name = "HeaderCoverBottom",
        Parent = Header,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8)
    })

    local HeaderLine = Create("Frame", {
        Name = "HeaderLine",
        Parent = Header,
        BackgroundColor3 = Theme.HeaderLine,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, 0),
        Size = UDim2.new(1, 0, 0, 1)
    })

    local AvatarContainer = Create("Frame", {
        Name = "AvatarContainer",
        Parent = Header,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 0.5, -17),
        Size = UDim2.new(0, 34, 0, 34)
    })

    local AvatarCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = AvatarContainer
    })

    local AvatarStroke = Create("UIStroke", {
        Parent = AvatarContainer,
        Color = Theme.AvatarStroke,
        Thickness = 1
    })

    local DisplayUserId = Development and DevelopmentUserId or Player.UserId
    local DisplayName = Development and "Development" or Player.Name

    local AvatarImage = Create("ImageLabel", {
        Name = "AvatarImage",
        Parent = AvatarContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. DisplayUserId .. "&w=150&h=150",
        ScaleType = Enum.ScaleType.Crop
    })

    local AvatarImageCorner = Create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = AvatarImage
    })

    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 8),
        Size = UDim2.new(0, 200, 0, 18),
        Font = Enum.Font.GothamBold,
        Text = DisplayName,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local SubtitleLabel = Create("TextLabel", {
        Name = "SubtitleLabel",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 26),
        Size = UDim2.new(0, 200, 0, 14),
        Font = Enum.Font.Gotham,
        Text = ExecutorName,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local NavContainer = Create("Frame", {
        Name = "NavContainer",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.ButtonInactive,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.X
    })

    local function UpdateNavPosition()
        local MainPos = MainFrame.AbsolutePosition
        local MainSize = MainFrame.AbsoluteSize
        NavContainer.Position = UDim2.new(0, MainPos.X + MainSize.X / 2, 0, MainPos.Y + MainSize.Y + 10)
    end

    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateNavPosition)
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateNavPosition)
    RunService.RenderStepped:Connect(UpdateNavPosition)

    local NavContainerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 18),
        Parent = NavContainer
    })

    local NavContainerPadding = Create("UIPadding", {
        Parent = NavContainer,
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6)
    })

    local NavButtonsHolder = Create("Frame", {
        Name = "NavButtonsHolder",
        Parent = NavContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X
    })

    local NavButtonsLayout = Create("UIListLayout", {
        Parent = NavButtonsHolder,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })

    local Tabs = {}
    local TabButtons = {}
    local CurrentTab = nil
    local PageContainer
    local RegisteredElements = {}

    local SearchContainer = Create("Frame", {
        Name = "SearchContainer",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.ButtonInactive,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 100, 0, 36),
        ClipsDescendants = true
    })

    local SearchContainerCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 18),
        Parent = SearchContainer
    })

    local SearchIcon = Create("ImageLabel", {
        Name = "SearchIcon",
        Parent = SearchContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 9, 0.5, -9),
        Size = UDim2.new(0, 18, 0, 18),
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Theme.SubText,
        Rotation = -270
    })

    local SearchInput = Create("TextBox", {
        Name = "SearchInput",
        Parent = SearchContainer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 36, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = "Search",
        PlaceholderColor3 = Theme.SubText,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    })

    local function UpdateSearchPosition()
        local MainPos = MainFrame.AbsolutePosition
        local MainSize = MainFrame.AbsoluteSize
        SearchContainer.Position = UDim2.new(0, MainPos.X + MainSize.X / 2, 0, MainPos.Y - 10)
    end

    RunService.RenderStepped:Connect(UpdateSearchPosition)

    local SearchTween = nil
    local function UpdateSearchSize()
        local TextWidth = SearchInput.TextBounds.X
        local MinWidth = 100
        local Padding = 50
        local TargetWidth = math.max(MinWidth, TextWidth + Padding)
        
        if SearchTween then
            SearchTween:Cancel()
        end
        
        if SearchInput.Text == "" then
            SearchTween = Tween(SearchContainer, {Size = UDim2.new(0, MinWidth, 0, 36)}, 0.2)
            Tween(SearchIcon, {ImageColor3 = Theme.SubText}, 0.15)
        else
            SearchContainer.Size = UDim2.new(0, TargetWidth, 0, 36)
            Tween(SearchIcon, {ImageColor3 = Theme.Text}, 0.15)
        end
    end

    local function SetTabActive(TabButtonData, IsActive, TabName)
        if IsActive then
            TabButtonData.Icon.ImageTransparency = 0
            TabButtonData.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
            TabButtonData.Label.Visible = true
            Tween(TabButtonData.Fill, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
            Tween(TabButtonData.Container, {Size = UDim2.new(0, 24 + TabButtonData.LabelWidth + 12, 0, 24)}, 0.2)
        else
            TabButtonData.Icon.ImageTransparency = 0
            TabButtonData.Icon.ImageColor3 = Theme.SubText
            TabButtonData.Label.Visible = false
            Tween(TabButtonData.Fill, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
            Tween(TabButtonData.Container, {Size = UDim2.new(0, 32, 0, 24)}, 0.2)
        end
    end

    local function SelectTabByIndex(TabIndex)
        if not TabIndex or not Tabs[TabIndex] then
            return
        end
        for i, Tab in pairs(Tabs) do
            Tab.Page.Visible = false
            SetTabActive(Tab.ButtonData, false, Tab.Name)
        end
        Tabs[TabIndex].Page.Visible = true
        SetTabActive(Tabs[TabIndex].ButtonData, true, Tabs[TabIndex].Name)
        CurrentTab = Tabs[TabIndex].Page
    end

    local function PerformSearch(Query)
        Query = string.lower(Query)
        
        if Query == "" then
            for _, Element in pairs(RegisteredElements) do
                Element.GroupFrame.Visible = true
                if Element.Frame then
                    Element.Frame.Visible = true
                end
            end
            return
        end

        local FoundTabIndex = nil
        local FoundGroups = {}

        for _, Element in pairs(RegisteredElements) do
            Element.GroupFrame.Visible = false
            if Element.Frame then
                Element.Frame.Visible = false
            end
        end

        for _, Element in pairs(RegisteredElements) do
            if string.find(string.lower(Element.Name), Query) then
                Element.GroupFrame.Visible = true
                if Element.Frame then
                    Element.Frame.Visible = true
                end
                FoundGroups[Element.GroupFrame] = true
                if not FoundTabIndex then
                    FoundTabIndex = Element.TabIndex
                end
            end
        end

        if FoundTabIndex then
            SelectTabByIndex(FoundTabIndex)
        end
    end

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        UpdateSearchSize()
        PerformSearch(SearchInput.Text)
    end)

    local function CreateTabButton(Icon, Order, TabName)
        local ButtonContainer = Create("Frame", {
            Name = "TabButtonContainer",
            Parent = NavButtonsHolder,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 32, 0, 24),
            LayoutOrder = Order,
            ClipsDescendants = true
        })

        local ButtonFill = Create("Frame", {
            Name = "Fill",
            Parent = ButtonContainer,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0)
        })

        local ButtonFillCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 12),
            Parent = ButtonFill
        })

        local ButtonFillGradient = Create("UIGradient", {
            Name = "Gradient",
            Parent = ButtonFill,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.GradientColor1),
                ColorSequenceKeypoint.new(1, Theme.GradientColor2)
            }),
            Rotation = 0
        })

        local ButtonIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = ButtonContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 8, 0.5, -7),
            Size = UDim2.new(0, 14, 0, 14),
            Image = Icon,
            ImageColor3 = Theme.SubText,
            ImageTransparency = 0,
            ZIndex = 2
        })

        local ButtonLabel = Create("TextLabel", {
            Name = "Label",
            Parent = ButtonContainer,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 24, 0, 0),
            Size = UDim2.new(0, 50, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = TabName,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Visible = false,
            ZIndex = 2
        })

        local LabelWidth = ButtonLabel.TextBounds.X

        local Button = Create("TextButton", {
            Name = "ClickArea",
            Parent = ButtonContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 3
        })

        local TabButtonData = {
            Container = ButtonContainer,
            Fill = ButtonFill,
            Icon = ButtonIcon,
            Label = ButtonLabel,
            LabelWidth = LabelWidth,
            ClickArea = Button
        }

        return TabButtonData
    end

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.ContentBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 51),
        Size = UDim2.new(1, 0, 1, -101)
    })

    local ContentArea = Create("Frame", {
        Name = "ContentArea",
        Parent = ContentContainer,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 15),
        Size = UDim2.new(1, -30, 1, -30)
    })

    PageContainer = Create("Folder", {
        Name = "Pages",
        Parent = ContentArea
    })

    local Footer = Create("Frame", {
        Name = "Footer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Footer,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -50),
        Size = UDim2.new(1, 0, 0, 50)
    })

    local FooterCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = Footer
    })

    local FooterCoverTop = Create("Frame", {
        Name = "FooterCoverTop",
        Parent = Footer,
        BackgroundColor3 = Theme.Footer,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 8)
    })

    local FooterIcon = Create("ImageLabel", {
        Name = "FooterIcon",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24),
        Image = "rbxassetid://7733960981",
        ImageColor3 = Theme.Accent
    })

    local FooterTitleContainer = Create("Frame", {
        Name = "FooterTitleContainer",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 10),
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X
    })

    local FooterTitleLayout = Create("UIListLayout", {
        Parent = FooterTitleContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6)
    })

    local FooterTitle = Create("TextLabel", {
        Name = "FooterTitle",
        Parent = FooterTitleContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = "Wisper Hub",
        TextColor3 = Theme.Text,
        TextSize = 13,
        LayoutOrder = 1
    })

    local VerifiedIcon = Create("ImageLabel", {
        Name = "VerifiedIcon",
        Parent = FooterTitleContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 14, 0, 14),
        Image = "rbxassetid://7743878857",
        ImageColor3 = Theme.Accent,
        LayoutOrder = 2
    })

    local FooterSubtitle = Create("TextLabel", {
        Name = "FooterSubtitle",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 28),
        Size = UDim2.new(0, 200, 0, 14),
        Font = Enum.Font.Gotham,
        Text = GameName,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local FooterButtons = Create("Frame", {
        Name = "FooterButtons",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -130, 0.5, -12),
        Size = UDim2.new(0, 115, 0, 24)
    })

    local FooterButtonsLayout = Create("UIListLayout", {
        Parent = FooterButtons,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12)
    })

    local function CreateFooterButton(Icon, Order)
        local Button = Create("ImageButton", {
            Name = "FooterButton",
            Parent = FooterButtons,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 24, 0, 24),
            Image = Icon,
            ImageColor3 = Theme.SubText,
            LayoutOrder = Order
        })

        Button.MouseEnter:Connect(function()
            Tween(Button, {ImageColor3 = Theme.Text}, 0.15)
        end)

        Button.MouseLeave:Connect(function()
            Tween(Button, {ImageColor3 = Theme.SubText}, 0.15)
        end)

        return Button
    end

    local SearchButton = CreateFooterButton("rbxassetid://7743871962", 1)
    local ExpandButton = CreateFooterButton("rbxassetid://7743870210", 2)
    local DiscordButton = CreateFooterButton("rbxassetid://7743878857", 3)

    MakeDraggable(MainFrame, Header)

    local Window = {}

    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if not GameProcessed and Input.KeyCode == Config.KeyBind then
            ScreenGui.Enabled = not ScreenGui.Enabled
            NavContainer.Visible = ScreenGui.Enabled
            SearchContainer.Visible = ScreenGui.Enabled
        end
    end)

    function Window:CreateTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        
        local TabIcon = TabConfig.Icon or GetAutoIcon(TabConfig.Name)

        local TabButtonData = CreateTabButton(TabIcon, #Tabs + 1, TabConfig.Name)

        local TabPage = Create("Frame", {
            Name = "TabPage_" .. TabConfig.Name,
            Parent = PageContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        })

        local TabPageLayout = Create("UIListLayout", {
            Parent = TabPage,
            FillDirection = Enum.FillDirection.Horizontal,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local LeftColumn = Create("ScrollingFrame", {
            Name = "LeftColumn",
            Parent = TabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            LayoutOrder = 1
        })

        local LeftColumnLayout = Create("UIListLayout", {
            Parent = LeftColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local RightColumn = Create("ScrollingFrame", {
            Name = "RightColumn",
            Parent = TabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -5, 1, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            BorderSizePixel = 0,
            LayoutOrder = 2
        })

        local RightColumnLayout = Create("UIListLayout", {
            Parent = RightColumn,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        local GroupCount = 0

        table.insert(Tabs, {ButtonData = TabButtonData, Page = TabPage, Name = TabConfig.Name})
        table.insert(TabButtons, TabButtonData)

        local function SelectTab()
            for _, Tab in pairs(Tabs) do
                Tab.Page.Visible = false
                SetTabActive(Tab.ButtonData, false, Tab.Name)
            end

            TabPage.Visible = true
            SetTabActive(TabButtonData, true, TabConfig.Name)
            CurrentTab = TabPage
        end

        TabButtonData.ClickArea.MouseButton1Click:Connect(SelectTab)

        if #Tabs == 1 then
            SelectTab()
        end

        local Tab = {}

        local CurrentTabIndex = #Tabs

        function Tab:CreateGroup(GroupConfig)
            GroupConfig = GroupConfig or {}
            GroupConfig.Name = GroupConfig.Name or "Group"
            GroupConfig.Icon = GroupConfig.Icon or "rbxassetid://7733960981"
            GroupConfig.Column = GroupConfig.Column or "Left"

            GroupCount = GroupCount + 1
            local TargetColumn = GroupConfig.Column == "Right" and RightColumn or LeftColumn

            local GroupFrame = Create("Frame", {
                Name = "Group_" .. GroupConfig.Name,
                Parent = TargetColumn,
                BackgroundColor3 = Theme.GroupBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = GroupCount,
                ClipsDescendants = true
            })

            local GroupCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = GroupFrame
            })

            local GroupStroke = Create("UIStroke", {
                Parent = GroupFrame,
                Color = Theme.GroupStroke,
                Thickness = 1
            })

            local GroupHeader = Create("Frame", {
                Name = "GroupHeader",
                Parent = GroupFrame,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, 0, 0, 40),
                ClipsDescendants = true
            })

            local GroupHeaderCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 8),
                Parent = GroupHeader
            })

            local GroupHeaderBottomFix = Create("Frame", {
                Name = "BottomFix",
                Parent = GroupHeader,
                BackgroundColor3 = Color3.fromRGB(20, 23, 27),
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -8),
                Size = UDim2.new(1, 0, 0, 8)
            })

            local GroupHeaderGradient = Create("UIGradient", {
                Parent = GroupHeader,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 25, 29)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 23, 27))
                }),
                Rotation = 90
            })

            local GroupHeaderLine = Create("Frame", {
                Name = "HeaderLine",
                Parent = GroupHeader,
                BackgroundColor3 = Theme.GroupStroke,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1)
            })

            local GroupIcon = Create("ImageLabel", {
                Name = "GroupIcon",
                Parent = GroupHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = GroupConfig.Icon,
                ImageColor3 = Theme.SubText
            })

            local GroupLabel = Create("TextLabel", {
                Name = "GroupLabel",
                Parent = GroupHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 36, 0, 0),
                Size = UDim2.new(1, -46, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = GroupConfig.Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local GroupContent = Create("Frame", {
                Name = "GroupContent",
                Parent = GroupFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Visible = false
            })

            local GroupContentLayout = Create("UIListLayout", {
                Parent = GroupContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })

            local GroupContentPadding = Create("UIPadding", {
                Parent = GroupContent,
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 2),
                PaddingBottom = UDim.new(0, 10)
            })

            local function ShowContentIfNeeded()
                if not GroupContent.Visible then
                    GroupContent.Visible = true
                end
            end

            local Group = {}

            function Group:CreateToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                ShowContentIfNeeded()

                local Toggled = ToggleConfig.Default

                local ToggleFrame = Create("Frame", {
                    Name = "Toggle_" .. ToggleConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24)
                })

                table.insert(RegisteredElements, {
                    Name = ToggleConfig.Name,
                    Frame = ToggleFrame,
                    GroupFrame = GroupFrame,
                    TabIndex = CurrentTabIndex
                })

                local ToggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    Parent = ToggleFrame,
                    BackgroundColor3 = Color3.fromRGB(34, 39, 45),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 0, 0.5, -9),
                    ClipsDescendants = true
                })

                local ToggleCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ToggleButton
                })

                local ToggleButtonGradient = Create("UIGradient", {
                    Name = "InactiveGradient",
                    Parent = ToggleButton,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 39, 45)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(29, 33, 38))
                    }),
                    Rotation = 0
                })

                local ToggleFill = Create("Frame", {
                    Name = "Fill",
                    Parent = ToggleButton,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = Toggled and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 0, 0)
                })

                local ToggleFillCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ToggleFill
                })

                local ToggleFillGradient = Create("UIGradient", {
                    Name = "Gradient",
                    Parent = ToggleFill,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.GradientColor1),
                        ColorSequenceKeypoint.new(1, Theme.GradientColor2)
                    }),
                    Rotation = 0
                })

                local ToggleCheck = Create("ImageLabel", {
                    Name = "ToggleCheck",
                    Parent = ToggleButton,
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 14, 0, 14),
                    Image = "rbxassetid://3926305904",
                    ImageRectOffset = Vector2.new(312, 4),
                    ImageRectSize = Vector2.new(24, 24),
                    ImageColor3 = Toggled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255),
                    ImageTransparency = Toggled and 0 or 1,
                    ZIndex = 2
                })

                local ToggleLabel = Create("TextLabel", {
                    Name = "ToggleLabel",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 28, 0, 0),
                    Size = UDim2.new(1, -100, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = ToggleConfig.Name,
                    TextColor3 = Toggled and Theme.Text or Theme.SubText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local CurrentColor = ToggleConfig.Color or Color3.fromRGB(255, 255, 255)
                local ColorPickerOpen = false

                local ColorFrame = Create("Frame", {
                    Name = "ColorFrame",
                    Parent = ToggleFrame,
                    BackgroundColor3 = CurrentColor,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -50, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20)
                })

                local ColorFrameCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = ColorFrame
                })

                local ColorFrameButton = Create("TextButton", {
                    Name = "ColorFrameButton",
                    Parent = ColorFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 2
                })

                local ColorPickerPopup = Create("Frame", {
                    Name = "ColorPickerPopup",
                    Parent = ScreenGui,
                    BackgroundColor3 = Color3.fromRGB(28, 32, 38),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 174, 0, 150),
                    Visible = false,
                    ZIndex = 100
                })

                local ColorPickerCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 8),
                    Parent = ColorPickerPopup
                })

                local ColorPickerStroke = Create("UIStroke", {
                    Parent = ColorPickerPopup,
                    Color = Theme.GroupStroke,
                    Thickness = 1
                })

                local ColorPickerHue = 0
                local ColorPickerSat = 1
                local ColorPickerVal = 1

                local SatValBox = Create("Frame", {
                    Name = "SatValBox",
                    Parent = ColorPickerPopup,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(0, 130, 0, 130),
                    ZIndex = 101,
                    ClipsDescendants = true
                })

                local SatValCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = SatValBox
                })

                local SaturationOverlay = Create("Frame", {
                    Name = "SaturationOverlay",
                    Parent = SatValBox,
                    BackgroundColor3 = Color3.fromHSV(ColorPickerHue, 1, 1),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 102
                })

                local SaturationGradient = Create("UIGradient", {
                    Parent = SaturationOverlay,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 0
                })

                local ValueGradient = Create("Frame", {
                    Name = "ValueGradient",
                    Parent = SatValBox,
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 103
                })

                local ValueGradientCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ValueGradient
                })

                local ValueGradientUI = Create("UIGradient", {
                    Parent = ValueGradient,
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 90
                })

                local SatValCursor = Create("Frame", {
                    Name = "SatValCursor",
                    Parent = SatValBox,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 104
                })

                local SatValCursorCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SatValCursor
                })

                local SatValCursorStroke = Create("UIStroke", {
                    Parent = SatValCursor,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 1.5
                })

                local HueBar = Create("Frame", {
                    Name = "HueBar",
                    Parent = ColorPickerPopup,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 150, 0, 10),
                    Size = UDim2.new(0, 14, 0, 130),
                    ZIndex = 101
                })

                local HueBarCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = HueBar
                })

                local HueGradient = Create("UIGradient", {
                    Parent = HueBar,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                    }),
                    Rotation = 90
                })

                local HueCursor = Create("Frame", {
                    Name = "HueCursor",
                    Parent = HueBar,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0, 0),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 104
                })

                local HueCursorCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = HueCursor
                })

                local HueCursorStroke = Create("UIStroke", {
                    Parent = HueCursor,
                    Color = Color3.fromRGB(255, 255, 255),
                    Thickness = 1.5
                })

                local function UpdateColorFromHSV()
                    CurrentColor = Color3.fromHSV(ColorPickerHue, ColorPickerSat, ColorPickerVal)
                    ColorFrame.BackgroundColor3 = CurrentColor
                    SaturationOverlay.BackgroundColor3 = Color3.fromHSV(ColorPickerHue, 1, 1)
                    if ToggleConfig.ColorCallback then
                        ToggleConfig.ColorCallback(CurrentColor)
                    end
                end

                local function UpdatePickerPosition()
                    local MainFramePos = MainFrame.AbsolutePosition
                    local MainFrameSize = MainFrame.AbsoluteSize
                    ColorPickerPopup.Position = UDim2.new(0, MainFramePos.X + MainFrameSize.X + 10, 0, MainFramePos.Y + 50)
                end

                local DraggingSatVal = false
                local DraggingHue = false

                SatValBox.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingSatVal = true
                    end
                end)

                SatValBox.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingSatVal = false
                    end
                end)

                HueBar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingHue = true
                    end
                end)

                HueBar.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingHue = false
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingSatVal = false
                        DraggingHue = false
                    end
                end)

                local SatValTargetX = 1
                local SatValTargetY = 0
                local HueTargetY = 0

                local GuiInset = game:GetService("GuiService"):GetGuiInset()

                RunService.RenderStepped:Connect(function()
                    if DraggingSatVal then
                        local MousePos = UserInputService:GetMouseLocation()
                        local BoxPos = SatValBox.AbsolutePosition
                        local BoxSize = SatValBox.AbsoluteSize

                        local RelX = math.clamp((MousePos.X - BoxPos.X) / BoxSize.X, 0, 1)
                        local RelY = math.clamp((MousePos.Y - BoxPos.Y - GuiInset.Y) / BoxSize.Y, 0, 1)

                        ColorPickerSat = RelX
                        ColorPickerVal = 1 - RelY

                        SatValTargetX = RelX
                        SatValTargetY = RelY
                        UpdateColorFromHSV()
                    end

                    if DraggingHue then
                        local MousePos = UserInputService:GetMouseLocation()
                        local BarPos = HueBar.AbsolutePosition
                        local BarSize = HueBar.AbsoluteSize

                        local RelY = math.clamp((MousePos.Y - BarPos.Y - GuiInset.Y) / BarSize.Y, 0, 1)

                        ColorPickerHue = RelY
                        HueTargetY = RelY
                        UpdateColorFromHSV()
                    end

                    local CurrentSatValPos = SatValCursor.Position
                    local NewSatValX = CurrentSatValPos.X.Scale + (SatValTargetX - CurrentSatValPos.X.Scale) * 0.15
                    local NewSatValY = CurrentSatValPos.Y.Scale + (SatValTargetY - CurrentSatValPos.Y.Scale) * 0.15
                    SatValCursor.Position = UDim2.new(NewSatValX, 0, NewSatValY, 0)

                    local CurrentHuePos = HueCursor.Position
                    local NewHueY = CurrentHuePos.Y.Scale + (HueTargetY - CurrentHuePos.Y.Scale) * 0.15
                    HueCursor.Position = UDim2.new(0.5, 0, NewHueY, 0)

                    if ColorPickerOpen then
                        UpdatePickerPosition()
                    end
                end)

                ColorFrameButton.MouseButton1Click:Connect(function()
                    ColorPickerOpen = not ColorPickerOpen
                    if ColorPickerOpen then
                        UpdatePickerPosition()
                        ColorPickerPopup.Visible = true
                        ColorPickerPopup.BackgroundTransparency = 1
                        Tween(ColorPickerPopup, {BackgroundTransparency = 0}, 0.2)
                    else
                        Tween(ColorPickerPopup, {BackgroundTransparency = 1}, 0.2)
                        task.delay(0.2, function()
                            if not ColorPickerOpen then
                                ColorPickerPopup.Visible = false
                            end
                        end)
                    end
                end)

                local KeybindFrame = Create("Frame", {
                    Name = "KeybindFrame",
                    Parent = ToggleFrame,
                    BackgroundColor3 = Theme.InputBackground,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 45, 0, 20)
                })

                local KeybindCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = KeybindFrame
                })

                local KeybindText = Create("TextLabel", {
                    Name = "KeybindText",
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = "None",
                    TextColor3 = Theme.SubText,
                    TextSize = 11
                })

                local KeybindButton = Create("TextButton", {
                    Name = "KeybindButton",
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 2
                })

                local CurrentKeybind = nil
                local WaitingForKey = false

                local function UpdateToggle()
                    if Toggled then
                        Tween(ToggleFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15)
                        ToggleCheck.ImageColor3 = Color3.fromRGB(0, 0, 0)
                        ToggleLabel.TextColor3 = Theme.Text
                    else
                        Tween(ToggleFill, {Size = UDim2.new(0, 0, 0, 0)}, 0.15)
                        ToggleCheck.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        ToggleLabel.TextColor3 = Theme.SubText
                    end
                    Tween(ToggleCheck, {ImageTransparency = Toggled and 0 or 1}, 0.1)
                    ToggleConfig.Callback(Toggled)
                end

                KeybindButton.MouseButton1Click:Connect(function()
                    WaitingForKey = true
                    KeybindText.Text = "..."
                    KeybindText.TextColor3 = Theme.Text
                end)

                KeybindFrame.MouseEnter:Connect(function()
                    if not WaitingForKey then
                        Tween(KeybindText, {TextColor3 = Theme.Text}, 0.15)
                    end
                end)

                KeybindFrame.MouseLeave:Connect(function()
                    if not WaitingForKey then
                        Tween(KeybindText, {TextColor3 = Theme.SubText}, 0.15)
                    end
                end)

                local KeybindConnection
                KeybindConnection = UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                    if WaitingForKey then
                        if Input.UserInputType == Enum.UserInputType.Keyboard then
                            CurrentKeybind = Input.KeyCode
                            KeybindText.Text = Input.KeyCode.Name
                            KeybindText.TextColor3 = Theme.SubText
                            WaitingForKey = false
                        end
                    elseif CurrentKeybind and Input.KeyCode == CurrentKeybind then
                        Toggled = not Toggled
                        UpdateToggle()
                    end
                end)

                local ToggleClickArea = Create("TextButton", {
                    Name = "ToggleClickArea",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -75, 1, 0),
                    Text = "",
                    AutoButtonColor = false
                })

                ToggleClickArea.MouseEnter:Connect(function()
                    if not Toggled then
                        Tween(ToggleLabel, {TextColor3 = Theme.Text}, 0.15)
                    end
                end)

                ToggleClickArea.MouseLeave:Connect(function()
                    if not Toggled then
                        Tween(ToggleLabel, {TextColor3 = Theme.SubText}, 0.15)
                    end
                end)

                ToggleClickArea.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    UpdateToggle()
                end)

                if Toggled then
                    ToggleConfig.Callback(true)
                end

                local ToggleAPI = {}

                function ToggleAPI:Set(Value)
                    Toggled = Value
                    UpdateToggle()
                end

                function ToggleAPI:Get()
                    return Toggled
                end

                function ToggleAPI:SetKeybind(Key)
                    CurrentKeybind = Key
                    KeybindText.Text = Key and Key.Name or "None"
                end

                function ToggleAPI:GetKeybind()
                    return CurrentKeybind
                end

                function ToggleAPI:SetColor(Color)
                    CurrentColor = Color
                    ColorFrame.BackgroundColor3 = Color
                    local H, S, V = Color:ToHSV()
                    ColorPickerHue = H
                    ColorPickerSat = S
                    ColorPickerVal = V
                    SatValCursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    HueCursor.Position = UDim2.new(0.5, 0, H, 0)
                    SaturationOverlay.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                end

                function ToggleAPI:GetColor()
                    return CurrentColor
                end

                return ToggleAPI
            end

            function Group:CreateSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100

                ShowContentIfNeeded()
                SliderConfig.Default = SliderConfig.Default or SliderConfig.Min
                SliderConfig.Suffix = SliderConfig.Suffix or "%"
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local Value = SliderConfig.Default

                local SliderFrame = Create("Frame", {
                    Name = "Slider_" .. SliderConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
                })

                table.insert(RegisteredElements, {
                    Name = SliderConfig.Name,
                    Frame = SliderFrame,
                    GroupFrame = GroupFrame,
                    TabIndex = CurrentTabIndex
                })

                local SliderLabel = Create("TextLabel", {
                    Name = "SliderLabel",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -50, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = SliderConfig.Name,
                    TextColor3 = Theme.SubText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local SliderValue = Create("TextLabel", {
                    Name = "SliderValue",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -50, 0, 0),
                    Size = UDim2.new(0, 50, 0, 18),
                    Font = Enum.Font.GothamBold,
                    Text = tostring(Value) .. SliderConfig.Suffix,
                    TextColor3 = Theme.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBackground = Create("Frame", {
                    Name = "SliderBackground",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.SliderBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 12)
                })

                local SliderBackgroundCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = SliderBackground
                })

                local SliderFill = Create("Frame", {
                    Name = "SliderFill",
                    Parent = SliderBackground,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0),
                    ClipsDescendants = true
                })

                local SliderFillCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 6),
                    Parent = SliderFill
                })

                local SliderFillGradient = Create("UIGradient", {
                    Parent = SliderFill,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(184, 212, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(126, 144, 174))
                    }),
                    Rotation = 0
                })

                local KnobSize = 12
                local InitialPercent = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)

                local SliderKnob = Create("Frame", {
                    Name = "SliderKnob",
                    Parent = SliderBackground,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(InitialPercent, 0, 0.5, 0),
                    Size = UDim2.new(0, KnobSize, 0, KnobSize),
                    ZIndex = 2
                })

                local SliderKnobCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderKnob
                })

                local SliderClickArea = Create("TextButton", {
                    Name = "SliderClickArea",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 20),
                    Text = "",
                    AutoButtonColor = false
                })

                local Dragging = false

                local function UpdateSlider(Input)
                    local Percent = math.clamp((Input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                    Value = math.floor(SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * Percent)
                    SliderValue.Text = tostring(Value) .. SliderConfig.Suffix
                    Tween(SliderFill, {Size = UDim2.new(Percent, 0, 1, 0)}, 0.05)
                    Tween(SliderKnob, {Position = UDim2.new(Percent, 0, 0.5, 0)}, 0.05)
                    SliderConfig.Callback(Value)
                end

                SliderClickArea.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        UpdateSlider(Input)
                    end
                end)

                SliderClickArea.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(Input)
                    end
                end)

                SliderConfig.Callback(Value)

                local SliderAPI = {}

                function SliderAPI:Set(NewValue)
                    Value = math.clamp(NewValue, SliderConfig.Min, SliderConfig.Max)
                    local Percent = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    SliderValue.Text = tostring(Value) .. SliderConfig.Suffix
                    Tween(SliderFill, {Size = UDim2.new(Percent, 0, 1, 0)}, 0.15)
                    Tween(SliderKnob, {Position = UDim2.new(Percent, 0, 0.5, 0)}, 0.15)
                    SliderConfig.Callback(Value)
                end

                function SliderAPI:Get()
                    return Value
                end

                return SliderAPI
            end

            function Group:CreateLabel(LabelConfig)
                LabelConfig = LabelConfig or {}
                LabelConfig.Text = LabelConfig.Text or "Label"

                ShowContentIfNeeded()

                local LabelFrame = Create("Frame", {
                    Name = "Label",
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })

                table.insert(RegisteredElements, {
                    Name = LabelConfig.Text,
                    Frame = LabelFrame,
                    GroupFrame = GroupFrame,
                    TabIndex = CurrentTabIndex
                })

                local Label = Create("TextLabel", {
                    Name = "LabelText",
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = LabelConfig.Text,
                    TextColor3 = Theme.SubText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                LabelFrame.MouseEnter:Connect(function()
                    Tween(Label, {TextColor3 = Theme.Text}, 0.15)
                end)

                LabelFrame.MouseLeave:Connect(function()
                    Tween(Label, {TextColor3 = Theme.SubText}, 0.15)
                end)

                local LabelAPI = {}

                function LabelAPI:Set(Text)
                    Label.Text = Text
                end

                return LabelAPI
            end

            function Group:CreateSeparator(SeparatorConfig)
                SeparatorConfig = SeparatorConfig or {}
                SeparatorConfig.Text = SeparatorConfig.Text or "Separator"

                ShowContentIfNeeded()

                local SeparatorFrame = Create("Frame", {
                    Name = "Separator_" .. SeparatorConfig.Text,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24)
                })

                local LeftLine = Create("Frame", {
                    Name = "LeftLine",
                    Parent = SeparatorFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 65, 75),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, -1),
                    Size = UDim2.new(0, 0, 0, 2)
                })

                local SeparatorText = Create("TextLabel", {
                    Name = "SeparatorText",
                    Parent = SeparatorFrame,
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    Size = UDim2.new(0, 60, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = SeparatorConfig.Text,
                    TextColor3 = Color3.fromRGB(180, 185, 195),
                    TextSize = 13,
                    AutomaticSize = Enum.AutomaticSize.X
                })

                local RightLine = Create("Frame", {
                    Name = "RightLine",
                    Parent = SeparatorFrame,
                    BackgroundColor3 = Color3.fromRGB(60, 65, 75),
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0.5, -1),
                    Size = UDim2.new(0, 0, 0, 2)
                })

                local function UpdateSeparatorLines()
                    local halfFrameWidth = SeparatorFrame.AbsoluteSize.X / 2
                    if halfFrameWidth <= 0 then
                        return
                    end

                    local halfTextWidth = SeparatorText.TextBounds.X / 2
                    local gap = 12
                    local lineLength = math.max(halfFrameWidth - halfTextWidth - gap, 0)

                    LeftLine.Size = UDim2.new(0, lineLength, 0, 2)
                    RightLine.Size = UDim2.new(0, lineLength, 0, 2)
                end

                UpdateSeparatorLines()
                SeparatorText:GetPropertyChangedSignal("TextBounds"):Connect(UpdateSeparatorLines)
                SeparatorFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSeparatorLines)

                return SeparatorFrame
            end

            function Group:CreateInput(InputConfig)
                InputConfig = InputConfig or {}
                InputConfig.Name = InputConfig.Name or "Input"
                InputConfig.Placeholder = InputConfig.Placeholder or "Enter text..."
                InputConfig.Callback = InputConfig.Callback or function() end

                ShowContentIfNeeded()

                local InputFrame = Create("Frame", {
                    Name = "Input_" .. InputConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })

                table.insert(RegisteredElements, {
                    Name = InputConfig.Name,
                    Frame = InputFrame,
                    GroupFrame = GroupFrame,
                    TabIndex = CurrentTabIndex
                })

                local InputLabel = Create("TextLabel", {
                    Name = "InputLabel",
                    Parent = InputFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = InputConfig.Name,
                    TextColor3 = Theme.SubText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local InputBox = Create("Frame", {
                    Name = "InputBox",
                    Parent = InputFrame,
                    BackgroundColor3 = Theme.InputBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 28)
                })

                local InputBoxCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = InputBox
                })

                local InputTextBox = Create("TextBox", {
                    Name = "InputTextBox",
                    Parent = InputBox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    PlaceholderText = InputConfig.Placeholder,
                    PlaceholderColor3 = Theme.SubText,
                    Text = "",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false
                })

                local InputIcon = Create("ImageLabel", {
                    Name = "InputIcon",
                    Parent = InputBox,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -28, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://7743870210",
                    ImageColor3 = Theme.SubText
                })

                InputFrame.MouseEnter:Connect(function()
                    Tween(InputLabel, {TextColor3 = Theme.Text}, 0.15)
                end)

                InputFrame.MouseLeave:Connect(function()
                    Tween(InputLabel, {TextColor3 = Theme.SubText}, 0.15)
                end)

                InputTextBox.FocusLost:Connect(function(EnterPressed)
                    if EnterPressed then
                        InputConfig.Callback(InputTextBox.Text)
                    end
                end)

                local InputAPI = {}

                function InputAPI:Set(Text)
                    InputTextBox.Text = Text
                end

                function InputAPI:Get()
                    return InputTextBox.Text
                end

                return InputAPI
            end

            function Group:CreateCombobox(ComboboxConfig)
                ComboboxConfig = ComboboxConfig or {}
                ComboboxConfig.Name = ComboboxConfig.Name or "Combobox"
                ComboboxConfig.Options = ComboboxConfig.Options or {}
                ComboboxConfig.Default = ComboboxConfig.Default or {}
                ComboboxConfig.Callback = ComboboxConfig.Callback or function() end

                ShowContentIfNeeded()

                local Selected = {}
                for _, v in ipairs(ComboboxConfig.Default) do
                    Selected[v] = true
                end

                local IsOpen = false

                local ComboboxFrame = Create("Frame", {
                    Name = "Combobox_" .. ComboboxConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ClipsDescendants = false
                })

                table.insert(RegisteredElements, {
                    Name = ComboboxConfig.Name,
                    Frame = ComboboxFrame,
                    GroupFrame = GroupFrame,
                    TabIndex = CurrentTabIndex
                })

                local ComboboxLabel = Create("TextLabel", {
                    Name = "ComboboxLabel",
                    Parent = ComboboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = ComboboxConfig.Name,
                    TextColor3 = Theme.SubText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ComboboxButton = Create("Frame", {
                    Name = "ComboboxButton",
                    Parent = ComboboxFrame,
                    BackgroundColor3 = Color3.fromRGB(28, 32, 38),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 30)
                })

                local ComboboxButtonCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ComboboxButton
                })

                local function GetSelectedText()
                    local Items = {}
                    for _, Option in ipairs(ComboboxConfig.Options) do
                        if Selected[Option] then
                            table.insert(Items, Option)
                        end
                    end
                    if #Items == 0 then
                        return "None selected..."
                    end
                    return table.concat(Items, ", ")
                end

                local ComboboxText = Create("TextLabel", {
                    Name = "ComboboxText",
                    Parent = ComboboxButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = GetSelectedText(),
                    TextColor3 = Theme.SubText,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd
                })

                local ComboboxIcon = Create("ImageLabel", {
                    Name = "ComboboxIcon",
                    Parent = ComboboxButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -24, 0.5, -9),
                    Size = UDim2.new(0, 18, 0, 18),
                    Image = "rbxassetid://3926307971",
                    ImageRectOffset = Vector2.new(564, 364),
                    ImageRectSize = Vector2.new(36, 36),
                    ImageColor3 = Theme.SubText
                })

                local ComboboxDropdown = Create("Frame", {
                    Name = "ComboboxDropdown",
                    Parent = ComboboxFrame,
                    BackgroundColor3 = Color3.fromRGB(28, 32, 38),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 54),
                    Size = UDim2.new(1, 0, 0, 0),
                    Visible = false,
                    ZIndex = 10,
                    ClipsDescendants = true
                })

                local ComboboxDropdownCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ComboboxDropdown
                })

                local ComboboxDropdownLayout = Create("UIListLayout", {
                    Parent = ComboboxDropdown,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 0)
                })

                local ComboboxDropdownPadding = Create("UIPadding", {
                    Parent = ComboboxDropdown,
                    PaddingTop = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4)
                })

                local OptionButtons = {}

                for i, Option in ipairs(ComboboxConfig.Options) do
                    local OptionButton = Create("TextButton", {
                        Name = "Option_" .. Option,
                        Parent = ComboboxDropdown,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        Font = Enum.Font.Gotham,
                        Text = "",
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        ZIndex = 11
                    })

                    local OptionFillContainer = Create("Frame", {
                        Name = "FillContainer",
                        Parent = OptionButton,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 4, 0, 2),
                        Size = UDim2.new(1, -8, 1, -4),
                        ZIndex = 11,
                        ClipsDescendants = true
                    })

                    local OptionFillContainerCorner = Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = OptionFillContainer
                    })

                    local OptionFill = Create("Frame", {
                        Name = "Fill",
                        Parent = OptionFillContainer,
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, 0.5, 0),
                        Size = Selected[Option] and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 0, 1, 0),
                        ZIndex = 11
                    })

                    local OptionFillCorner = Create("UICorner", {
                        CornerRadius = UDim.new(0, 4),
                        Parent = OptionFill
                    })

                    local OptionFillGradient = Create("UIGradient", {
                        Parent = OptionFill,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Theme.GradientColor1),
                            ColorSequenceKeypoint.new(1, Theme.GradientColor2)
                        }),
                        Rotation = 0
                    })

                    local OptionLabel = Create("TextLabel", {
                        Name = "OptionLabel",
                        Parent = OptionButton,
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -24, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = Option,
                        TextColor3 = Selected[Option] and Color3.fromRGB(0, 0, 0) or Theme.SubText,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 12
                    })

                    OptionButton.MouseEnter:Connect(function()
                        if not Selected[Option] then
                            Tween(OptionLabel, {TextColor3 = Theme.Text}, 0.1)
                        end
                    end)

                    OptionButton.MouseLeave:Connect(function()
                        if not Selected[Option] then
                            Tween(OptionLabel, {TextColor3 = Theme.SubText}, 0.1)
                        end
                    end)

                    OptionButton.MouseButton1Click:Connect(function()
                        Selected[Option] = not Selected[Option]
                        if Selected[Option] then
                            Tween(OptionFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15)
                            OptionLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                        else
                            Tween(OptionFill, {Size = UDim2.new(0, 0, 1, 0)}, 0.15)
                            OptionLabel.TextColor3 = Theme.SubText
                        end
                        ComboboxText.Text = GetSelectedText()

                        local SelectedItems = {}
                        for _, Opt in ipairs(ComboboxConfig.Options) do
                            if Selected[Opt] then
                                table.insert(SelectedItems, Opt)
                            end
                        end
                        ComboboxConfig.Callback(SelectedItems)
                    end)

                    OptionButtons[Option] = {Button = OptionButton, Fill = OptionFill, Label = OptionLabel}
                end

                local ComboboxClickArea = Create("TextButton", {
                    Name = "ComboboxClickArea",
                    Parent = ComboboxButton,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false
                })

                ComboboxButton.MouseEnter:Connect(function()
                    Tween(ComboboxLabel, {TextColor3 = Theme.Text}, 0.15)
                    Tween(ComboboxText, {TextColor3 = Theme.Text}, 0.15)
                end)

                ComboboxButton.MouseLeave:Connect(function()
                    if not IsOpen then
                        Tween(ComboboxLabel, {TextColor3 = Theme.SubText}, 0.15)
                        Tween(ComboboxText, {TextColor3 = Theme.SubText}, 0.15)
                    end
                end)

                local DropdownHeight = #ComboboxConfig.Options * 28 + 8

                ComboboxClickArea.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    if IsOpen then
                        ComboboxDropdown.Visible = true
                        ComboboxDropdown.Size = UDim2.new(1, 0, 0, 0)
                        Tween(ComboboxDropdown, {Size = UDim2.new(1, 0, 0, DropdownHeight)}, 0.15)
                    else
                        Tween(ComboboxDropdown, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                        task.delay(0.15, function()
                            if not IsOpen then
                                ComboboxDropdown.Visible = false
                            end
                        end)
                    end
                    Tween(ComboboxIcon, {Rotation = IsOpen and 180 or 0}, 0.15)
                end)

                local ComboboxAPI = {}

                function ComboboxAPI:Set(Items)
                    Selected = {}
                    for _, Item in ipairs(Items) do
                        Selected[Item] = true
                    end
                    ComboboxText.Text = GetSelectedText()
                    for Option, Data in pairs(OptionButtons) do
                        Data.Fill.Visible = Selected[Option] or false
                        Data.Label.TextColor3 = Selected[Option] and Color3.fromRGB(0, 0, 0) or Theme.Text
                    end
                    ComboboxConfig.Callback(Items)
                end

                function ComboboxAPI:Get()
                    local Items = {}
                    for _, Option in ipairs(ComboboxConfig.Options) do
                        if Selected[Option] then
                            table.insert(Items, Option)
                        end
                    end
                    return Items
                end

                return ComboboxAPI
            end

            function Group:CreateButton(ButtonConfig)
                ButtonConfig = ButtonConfig or {}
                ButtonConfig.Name = ButtonConfig.Name or "Button"
                ButtonConfig.Callback = ButtonConfig.Callback or function() end

                ShowContentIfNeeded()

                local ButtonFrame = Create("Frame", {
                    Name = "Button_" .. ButtonConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })

                table.insert(RegisteredElements, {
                    Name = ButtonConfig.Name,
                    Frame = ButtonFrame,
                    GroupFrame = GroupFrame,
                    TabIndex = CurrentTabIndex
                })

                local ButtonContainer = Create("Frame", {
                    Name = "ButtonContainer",
                    Parent = ButtonFrame,
                    BackgroundColor3 = Color3.fromRGB(28, 32, 38),
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30)
                })

                local ButtonContainerCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ButtonContainer
                })

                local ButtonText = Create("TextLabel", {
                    Name = "ButtonText",
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = ButtonConfig.Name,
                    TextColor3 = Theme.SubText,
                    TextSize = 13
                })

                local ButtonClickArea = Create("TextButton", {
                    Name = "ButtonClickArea",
                    Parent = ButtonContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 2
                })

                ButtonClickArea.MouseEnter:Connect(function()
                    Tween(ButtonText, {TextColor3 = Theme.Text}, 0.15)
                    Tween(ButtonContainer, {BackgroundColor3 = Color3.fromRGB(35, 40, 48)}, 0.15)
                end)

                ButtonClickArea.MouseLeave:Connect(function()
                    Tween(ButtonText, {TextColor3 = Theme.SubText}, 0.15)
                    Tween(ButtonContainer, {BackgroundColor3 = Color3.fromRGB(28, 32, 38)}, 0.15)
                end)

                ButtonClickArea.MouseButton1Click:Connect(function()
                    ButtonConfig.Callback()
                end)

                return ButtonFrame
            end

            return Group
        end

        return Tab
    end

    function Window:SetFooterInfo(Config)
        Config = Config or {}
        if Config.Title then
            FooterTitle.Text = Config.Title
        end
        if Config.Subtitle then
            FooterSubtitle.Text = Config.Subtitle
        end
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:Toggle()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end

    local NotificationContainer = Create("Frame", {
        Name = "NotificationContainer",
        Parent = ScreenGui,
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -20, 1, -20),
        Size = UDim2.new(0, 350, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    local NotificationLayout = Create("UIListLayout", {
        Parent = NotificationContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10)
    })

    local NotificationCount = 0

    function Window:Notify(NotifyConfig)
        NotifyConfig = NotifyConfig or {}
        NotifyConfig.Title = NotifyConfig.Title or "Notification"
        NotifyConfig.Description = NotifyConfig.Description or ""
        NotifyConfig.Duration = NotifyConfig.Duration or 4
        NotifyConfig.Callback = NotifyConfig.Callback or function() end

        NotificationCount = NotificationCount + 1

        local TitleWidth = game:GetService("TextService"):GetTextSize(NotifyConfig.Title, 13, Enum.Font.GothamBold, Vector2.new(math.huge, 16)).X
        local DescWidth = game:GetService("TextService"):GetTextSize(NotifyConfig.Description, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16)).X
        local ContentWidth = math.max(TitleWidth, DescWidth)
        local NotificationWidth = 50 + ContentWidth + 15

        local NotificationHolder = Create("Frame", {
            Name = "NotificationHolder_" .. NotificationCount,
            Parent = NotificationContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, NotificationWidth, 0, 50),
            LayoutOrder = -NotificationCount,
            ClipsDescendants = true
        })

        local NotificationFrame = Create("Frame", {
            Name = "Notification",
            Parent = NotificationHolder,
            BackgroundColor3 = Color3.fromRGB(28, 32, 38),
            BorderSizePixel = 0,
            Position = UDim2.new(1, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0)
        })

        local NotificationCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = NotificationFrame
        })

        local NotificationStroke = Create("UIStroke", {
            Parent = NotificationFrame,
            Color = Theme.GroupStroke,
            Thickness = 1
        })

        local CheckContainer = Create("Frame", {
            Name = "CheckContainer",
            Parent = NotificationFrame,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 10, 0.5, -15),
            Size = UDim2.new(0, 30, 0, 30),
            ClipsDescendants = true
        })

        local CheckCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = CheckContainer
        })

        local CheckGradient = Create("UIGradient", {
            Parent = CheckContainer,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.GradientColor1),
                ColorSequenceKeypoint.new(1, Theme.GradientColor2)
            }),
            Rotation = 0
        })

        local CheckIcon = Create("ImageLabel", {
            Name = "CheckIcon",
            Parent = CheckContainer,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            Image = "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(312, 4),
            ImageRectSize = Vector2.new(24, 24),
            ImageColor3 = Color3.fromRGB(0, 0, 0)
        })

        local CheckButton = Create("TextButton", {
            Name = "CheckButton",
            Parent = CheckContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 2
        })

        local NotificationTitle = Create("TextLabel", {
            Name = "Title",
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 8),
            Size = UDim2.new(1, -60, 0, 16),
            Font = Enum.Font.GothamBold,
            Text = NotifyConfig.Title,
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local NotificationDescription = Create("TextLabel", {
            Name = "Description",
            Parent = NotificationFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 50, 0, 26),
            Size = UDim2.new(1, -60, 0, 16),
            Font = Enum.Font.Gotham,
            Text = NotifyConfig.Description,
            TextColor3 = Theme.SubText,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Tween(NotificationFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3)

        local function CloseNotification()
            Tween(NotificationFrame, {Position = UDim2.new(1, 0, 0, 0)}, 0.3)
            task.delay(0.3, function()
                NotificationHolder:Destroy()
            end)
        end

        CheckButton.MouseButton1Click:Connect(function()
            NotifyConfig.Callback()
            CloseNotification()
        end)

        task.delay(NotifyConfig.Duration, function()
            if NotificationFrame and NotificationFrame.Parent then
                CloseNotification()
            end
        end)

        return {
            Close = CloseNotification
        }
    end

    return Window
end

return WisperLib
