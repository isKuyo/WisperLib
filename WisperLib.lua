local WisperLib = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

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
    Background = Color3.fromRGB(30, 31, 35),
    Header = Color3.fromRGB(26, 27, 31),
    Sidebar = Color3.fromRGB(26, 27, 31),
    ContentBackground = Color3.fromRGB(42, 43, 48),
    ElementBackground = Color3.fromRGB(42, 43, 48),
    GroupBackground = Color3.fromRGB(42, 43, 48),
    Accent = Color3.fromRGB(74, 144, 217),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(150, 150, 150),
    Divider = Color3.fromRGB(50, 51, 56),
    TabHover = Color3.fromRGB(35, 36, 40),
    TabSelected = Color3.fromRGB(42, 43, 48),
    CheckboxEnabled = Color3.fromRGB(74, 144, 217),
    CheckboxDisabled = Color3.fromRGB(60, 61, 66),
    SliderBackground = Color3.fromRGB(60, 61, 66),
    SliderFill = Color3.fromRGB(74, 144, 217),
    InputBackground = Color3.fromRGB(50, 51, 56),
    Footer = Color3.fromRGB(26, 27, 31)
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
        ResetOnSpawn = false
    })

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
        Size = UDim2.new(1, 0, 0, 60)
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

    local AvatarContainer = Create("Frame", {
        Name = "AvatarContainer",
        Parent = Header,
        BackgroundColor3 = Color3.fromRGB(40, 41, 46),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0.5, -18),
        Size = UDim2.new(0, 36, 0, 36)
    })

    local AvatarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = AvatarContainer
    })

    local AvatarImage = Create("ImageLabel", {
        Name = "AvatarImage",
        Parent = AvatarContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. Player.UserId .. "&w=150&h=150",
        ScaleType = Enum.ScaleType.Crop
    })

    local AvatarImageCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = AvatarImage
    })

    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 12),
        Size = UDim2.new(0, 200, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = Config.Title,
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local SubtitleLabel = Create("TextLabel", {
        Name = "SubtitleLabel",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 60, 0, 32),
        Size = UDim2.new(0, 200, 0, 16),
        Font = Enum.Font.Gotham,
        Text = Config.Subtitle,
        TextColor3 = Theme.SubText,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local HeaderButtons = Create("Frame", {
        Name = "HeaderButtons",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -160, 0.5, -16),
        Size = UDim2.new(0, 145, 0, 32)
    })

    local HeaderButtonsLayout = Create("UIListLayout", {
        Parent = HeaderButtons,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    local function CreateHeaderButton(Icon, Order)
        local Button = Create("ImageButton", {
            Name = "HeaderButton",
            Parent = HeaderButtons,
            BackgroundColor3 = Color3.fromRGB(45, 46, 51),
            BorderSizePixel = 0,
            Size = UDim2.new(0, 32, 0, 32),
            Image = Icon,
            ImageColor3 = Theme.Text,
            LayoutOrder = Order,
            ScaleType = Enum.ScaleType.Fit
        })

        local ButtonCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = Button
        })

        Button.MouseEnter:Connect(function()
            Tween(Button, {BackgroundColor3 = Color3.fromRGB(55, 56, 61)}, 0.15)
        end)

        Button.MouseLeave:Connect(function()
            Tween(Button, {BackgroundColor3 = Color3.fromRGB(45, 46, 51)}, 0.15)
        end)

        return Button
    end

    local HomeButton = CreateHeaderButton("rbxassetid://7733960981", 1)
    HomeButton.BackgroundColor3 = Theme.Accent
    HomeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)

    local ExternalButton = CreateHeaderButton("rbxassetid://7743878857", 2)
    local MenuButton = CreateHeaderButton("rbxassetid://7743870210", 3)
    local SettingsButton = CreateHeaderButton("rbxassetid://7743871962", 4)

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 60),
        Size = UDim2.new(1, 0, 1, -110)
    })

    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = ContentContainer,
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(0, 170, 1, -20)
    })

    local SidebarCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = Sidebar
    })

    local TabContainer = Create("ScrollingFrame", {
        Name = "TabContainer",
        Parent = Sidebar,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 8, 0, 8),
        Size = UDim2.new(1, -16, 1, -16),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4)
    })

    local ContentFrame = Create("Frame", {
        Name = "ContentFrame",
        Parent = ContentContainer,
        BackgroundColor3 = Theme.ContentBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 200, 0, 10),
        Size = UDim2.new(1, -215, 1, -20)
    })

    local ContentCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = ContentFrame
    })

    local ContentScroll = Create("ScrollingFrame", {
        Name = "ContentScroll",
        Parent = ContentFrame,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y
    })

    local ContentLayout = Create("UIListLayout", {
        Parent = ContentScroll,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10)
    })

    local PageContainer = Create("Folder", {
        Name = "Pages",
        Parent = ContentScroll
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

    local FooterTitle = Create("TextLabel", {
        Name = "FooterTitle",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 10),
        Size = UDim2.new(0, 150, 0, 16),
        Font = Enum.Font.GothamBold,
        Text = "IceWare",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local VerifiedIcon = Create("ImageLabel", {
        Name = "VerifiedIcon",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 10),
        Size = UDim2.new(0, 16, 0, 16),
        Image = "rbxassetid://7743878857",
        ImageColor3 = Theme.Accent
    })

    local FooterSubtitle = Create("TextLabel", {
        Name = "FooterSubtitle",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 48, 0, 28),
        Size = UDim2.new(0, 200, 0, 14),
        Font = Enum.Font.Gotham,
        Text = "99 Nights In A Forest",
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

    local Tabs = {}
    local CurrentTab = nil
    local Window = {}

    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if not GameProcessed and Input.KeyCode == Config.KeyBind then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    function Window:CreateTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Icon = TabConfig.Icon or "rbxassetid://7733960981"

        local TabButton = Create("TextButton", {
            Name = "TabButton_" .. TabConfig.Name,
            Parent = TabContainer,
            BackgroundColor3 = Theme.TabHover,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 36),
            Font = Enum.Font.Gotham,
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = 13,
            AutoButtonColor = false
        })

        local TabCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = TabButton
        })

        local TabIcon = Create("ImageLabel", {
            Name = "TabIcon",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = TabConfig.Icon,
            ImageColor3 = Theme.SubText
        })

        local TabLabel = Create("TextLabel", {
            Name = "TabLabel",
            Parent = TabButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 34, 0, 0),
            Size = UDim2.new(1, -44, 1, 0),
            Font = Enum.Font.Gotham,
            Text = TabConfig.Name,
            TextColor3 = Theme.SubText,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        local TabPage = Create("Frame", {
            Name = "TabPage_" .. TabConfig.Name,
            Parent = PageContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        })

        local TabPageLayout = Create("UIListLayout", {
            Parent = TabPage,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })

        table.insert(Tabs, {Button = TabButton, Page = TabPage, Icon = TabIcon, Label = TabLabel})

        local function SelectTab()
            for _, Tab in pairs(Tabs) do
                Tab.Page.Visible = false
                Tween(Tab.Button, {BackgroundTransparency = 1}, 0.15)
                Tween(Tab.Icon, {ImageColor3 = Theme.SubText}, 0.15)
                Tween(Tab.Label, {TextColor3 = Theme.SubText}, 0.15)
            end

            TabPage.Visible = true
            Tween(TabButton, {BackgroundTransparency = 0, BackgroundColor3 = Theme.TabSelected}, 0.15)
            Tween(TabIcon, {ImageColor3 = Theme.Text}, 0.15)
            Tween(TabLabel, {TextColor3 = Theme.Text}, 0.15)
            CurrentTab = TabPage
        end

        TabButton.MouseButton1Click:Connect(SelectTab)

        TabButton.MouseEnter:Connect(function()
            if CurrentTab ~= TabPage then
                Tween(TabButton, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.TabHover}, 0.15)
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if CurrentTab ~= TabPage then
                Tween(TabButton, {BackgroundTransparency = 1}, 0.15)
            end
        end)

        if #Tabs == 1 then
            SelectTab()
        end

        local Tab = {}

        function Tab:CreateGroup(GroupConfig)
            GroupConfig = GroupConfig or {}
            GroupConfig.Name = GroupConfig.Name or "Group"
            GroupConfig.Icon = GroupConfig.Icon or "rbxassetid://7733960981"

            local GroupFrame = Create("Frame", {
                Name = "Group_" .. GroupConfig.Name,
                Parent = TabPage,
                BackgroundColor3 = Theme.GroupBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 40),
                AutomaticSize = Enum.AutomaticSize.Y
            })

            local GroupCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = GroupFrame
            })

            local GroupHeader = Create("Frame", {
                Name = "GroupHeader",
                Parent = GroupFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 40)
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
                AutomaticSize = Enum.AutomaticSize.Y
            })

            local GroupContentLayout = Create("UIListLayout", {
                Parent = GroupContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8)
            })

            local GroupContentPadding = Create("UIPadding", {
                Parent = GroupContent,
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingBottom = UDim.new(0, 12)
            })

            local Group = {}

            function Group:CreateToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Toggle"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                local Toggled = ToggleConfig.Default

                local ToggleFrame = Create("Frame", {
                    Name = "Toggle_" .. ToggleConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24)
                })

                local ToggleButton = Create("Frame", {
                    Name = "ToggleButton",
                    Parent = ToggleFrame,
                    BackgroundColor3 = Toggled and Theme.CheckboxEnabled or Theme.CheckboxDisabled,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 0, 0.5, -9)
                })

                local ToggleCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = ToggleButton
                })

                local ToggleCheck = Create("ImageLabel", {
                    Name = "ToggleCheck",
                    Parent = ToggleButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    Image = "rbxassetid://7743871962",
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    ImageTransparency = Toggled and 0 or 1
                })

                local ToggleLabel = Create("TextLabel", {
                    Name = "ToggleLabel",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 28, 0, 0),
                    Size = UDim2.new(1, -28, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = ToggleConfig.Name,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ToggleClickArea = Create("TextButton", {
                    Name = "ToggleClickArea",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false
                })

                local function UpdateToggle()
                    Tween(ToggleButton, {BackgroundColor3 = Toggled and Theme.CheckboxEnabled or Theme.CheckboxDisabled}, 0.15)
                    Tween(ToggleCheck, {ImageTransparency = Toggled and 0 or 1}, 0.15)
                    ToggleConfig.Callback(Toggled)
                end

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

                return ToggleAPI
            end

            function Group:CreateSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or SliderConfig.Min
                SliderConfig.Suffix = SliderConfig.Suffix or "%"
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local Value = SliderConfig.Default

                local SliderFrame = Create("Frame", {
                    Name = "Slider_" .. SliderConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 45)
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
                    TextSize = 12,
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
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })

                local SliderBackground = Create("Frame", {
                    Name = "SliderBackground",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.SliderBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 25),
                    Size = UDim2.new(1, 0, 0, 6)
                })

                local SliderBackgroundCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderBackground
                })

                local SliderFill = Create("Frame", {
                    Name = "SliderFill",
                    Parent = SliderBackground,
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel = 0,
                    Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0)
                })

                local SliderFillCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderFill
                })

                local SliderKnob = Create("Frame", {
                    Name = "SliderKnob",
                    Parent = SliderFill,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 12, 0, 12)
                })

                local SliderKnobCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderKnob
                })

                local SliderClickArea = Create("TextButton", {
                    Name = "SliderClickArea",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 20),
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

                local LabelFrame = Create("Frame", {
                    Name = "Label",
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })

                local Label = Create("TextLabel", {
                    Name = "LabelText",
                    Parent = LabelFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = LabelConfig.Text,
                    TextColor3 = Theme.SubText,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local LabelAPI = {}

                function LabelAPI:Set(Text)
                    Label.Text = Text
                end

                return LabelAPI
            end

            function Group:CreateInput(InputConfig)
                InputConfig = InputConfig or {}
                InputConfig.Name = InputConfig.Name or "Input"
                InputConfig.Placeholder = InputConfig.Placeholder or "Enter text..."
                InputConfig.Callback = InputConfig.Callback or function() end

                local InputFrame = Create("Frame", {
                    Name = "Input_" .. InputConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50)
                })

                local InputLabel = Create("TextLabel", {
                    Name = "InputLabel",
                    Parent = InputFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = InputConfig.Name,
                    TextColor3 = Theme.SubText,
                    TextSize = 12,
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

    return Window
end

return WisperLib
