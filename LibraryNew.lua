print("wisps")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

local Library = {}
Library.__index = Library

local Icons
local IconsUrl = "https://raw.githubusercontent.com/isKuyo/WisperLib/main/Assets/Icons.lua"
local FallbackIcons = {
    ["search"] = "rbxassetid://10734943674",
    ["crosshair"] = "rbxassetid://10709818534",
    ["target"] = "rbxassetid://10734977012",
    ["eye"] = "rbxassetid://10723346959",
    ["settings"] = "rbxassetid://10734950309",
    ["folder"] = "rbxassetid://10723387563",
    ["palette"] = "rbxassetid://10734910430",
    ["chevron-right"] = "rbxassetid://10709791437",
    ["chevron-down"] = "rbxassetid://10709790948",
    ["check"] = "rbxassetid://10709790644",
}

local function LoadIcons()
    if Icons then return Icons end

    local Success, Result = pcall(function()
        return loadstring(game:HttpGet(IconsUrl, true))()
    end)

    if Success and type(Result) == "table" and type(Result.assets) == "table" then
        Icons = Result.assets
    else
        Icons = {}
    end

    return Icons
end

local function GetIcon(Name)
    if type(Name) ~= "string" or Name == "" then
        return "rbxassetid://7733960981"
    end

    local Assets = LoadIcons()
    return FallbackIcons[Name]
        or Assets["lucide-" .. Name]
        or Assets[Name]
        or "rbxassetid://7733960981"
end

Library.Themes = {
    Dark = {
        Accent = Color3.fromRGB(134, 134, 255),
        Surface = {
            Background = Color3.fromRGB(24, 24, 27),
        },
        Settings = {
            Background = Color3.fromRGB(23, 23, 25),
            Text = Color3.fromRGB(255, 255, 255),
            Username = Color3.fromRGB(255, 255, 255),
            Divider = Color3.fromRGB(38, 38, 42),
            SelectedBackground = Color3.fromRGB(27, 26, 30),
        },
        Groups = {
            Background = Color3.fromRGB(24, 24, 27),
            Title = Color3.fromRGB(255, 255, 255),
            ToggleBackground = Color3.fromRGB(30, 30, 37),
            SliderBackground = Color3.fromRGB(30, 30, 36),
            Divider = Color3.fromRGB(31, 31, 35),
        },
        Window = {
            Background = Color3.fromRGB(19, 19, 20),
        },
        Sidebar = {
            Background = Color3.fromRGB(20, 20, 20),
            Search = {
                Text = Color3.fromRGB(255, 255, 255),
            },
            Divider = {
                Background = Color3.fromRGB(29, 29, 37),
            },
            Tabs = {
                Text = Color3.fromRGB(255, 255, 255),
            },
        },
    },
    Crimson = {
        Accent = Color3.fromRGB(218, 70, 87),
        Surface = {
            Background = Color3.fromRGB(29, 22, 24),
        },
        Settings = {
            Background = Color3.fromRGB(27, 20, 22),
            Text = Color3.fromRGB(255, 245, 246),
            Username = Color3.fromRGB(245, 205, 209),
            Divider = Color3.fromRGB(51, 28, 33),
            SelectedBackground = Color3.fromRGB(45, 21, 26),
        },
        Groups = {
            Background = Color3.fromRGB(29, 22, 24),
            Title = Color3.fromRGB(255, 245, 246),
            ToggleBackground = Color3.fromRGB(43, 27, 31),
            SliderBackground = Color3.fromRGB(43, 26, 30),
            Divider = Color3.fromRGB(47, 27, 32),
        },
        Window = {
            Background = Color3.fromRGB(22, 16, 18),
        },
        Sidebar = {
            Background = Color3.fromRGB(24, 17, 19),
            Search = {
                Text = Color3.fromRGB(255, 245, 246),
            },
            Divider = {
                Background = Color3.fromRGB(43, 25, 30),
            },
            Tabs = {
                Text = Color3.fromRGB(255, 245, 246),
            },
        },
    },
    Emerald = {
        Accent = Color3.fromRGB(67, 184, 112),
        Surface = {
            Background = Color3.fromRGB(20, 24, 22),
        },
        Settings = {
            Background = Color3.fromRGB(15, 19, 17),
            Text = Color3.fromRGB(240, 255, 246),
            Username = Color3.fromRGB(190, 226, 204),
            Divider = Color3.fromRGB(27, 39, 31),
            SelectedBackground = Color3.fromRGB(22, 32, 26),
        },
        Groups = {
            Background = Color3.fromRGB(20, 24, 22),
            Title = Color3.fromRGB(240, 255, 246),
            ToggleBackground = Color3.fromRGB(24, 32, 27),
            SliderBackground = Color3.fromRGB(23, 31, 26),
            Divider = Color3.fromRGB(26, 38, 30),
        },
        Window = {
            Background = Color3.fromRGB(13, 17, 15),
        },
        Sidebar = {
            Background = Color3.fromRGB(15, 20, 17),
            Search = {
                Text = Color3.fromRGB(240, 255, 246),
            },
            Divider = {
                Background = Color3.fromRGB(23, 35, 28),
            },
            Tabs = {
                Text = Color3.fromRGB(240, 255, 246),
            },
        },
    },
}

local UI = {}

function UI.Create(ClassName, Properties, Parent)
    local Object = Instance.new(ClassName)

    for Property, Value in pairs(Properties or {}) do
        Object[Property] = Value
    end

    Object.Parent = Parent
    return Object
end

function UI.Corner(Parent, Radius)
    return UI.Create("UICorner", {
        CornerRadius = UDim.new(0, Radius),
    }, Parent)
end

function UI.Stroke(Parent, Color, Thickness)
    return UI.Create("UIStroke", {
        Color = Color,
        Thickness = Thickness or 1,
        Transparency = 0,
    }, Parent)
end

function UI.ResponsiveScale(Object, BaseWidth, BaseHeight)
    local Scale = UI.Create("UIScale", {}, Object)

    local function Update()
        local Camera = workspace.CurrentCamera
        if not Camera then return end

        local Viewport = Camera.ViewportSize
        local Padding = UserInputService.TouchEnabled and 24 or 48
        Scale.Scale = math.max(0.1, math.min(
            1,
            (Viewport.X - Padding) / BaseWidth,
            (Viewport.Y - Padding) / BaseHeight
        ))
    end

    local function BindCamera(Camera)
        if Camera then
            Camera:GetPropertyChangedSignal("ViewportSize"):Connect(Update)
        end
    end

    BindCamera(workspace.CurrentCamera)
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        BindCamera(workspace.CurrentCamera)
        Update()
    end)

    Update()
    return Scale
end

local GetGlobalEnvironment

local function GetGuiParent(PlayerGui)
    local Candidates = {}
    local Environment = GetGlobalEnvironment()
    local function AddGetter(Getter)
        if type(Getter) == "function" then
            table.insert(Candidates, Getter)
        end
    end

    AddGetter(rawget(Environment, "gethui"))
    AddGetter(rawget(Environment, "get_hidden_gui"))
    AddGetter(rawget(Environment, "gethiddengui"))

    local Syn = rawget(Environment, "syn")
    if type(Syn) == "table" then
        AddGetter(Syn.gethui)
    end

    for _, Getter in ipairs(Candidates) do
        local Success, Result = pcall(Getter)
        if Success and Result then
            return Result
        end
    end

    return CoreGui or PlayerGui
end

GetGlobalEnvironment = function()
    local GetGenv = rawget(_G, "getgenv")
    if type(GetGenv) == "function" then
        local Success, Environment = pcall(GetGenv)
        if Success and Environment then
            return Environment
        end
    end

    return _G
end

local function ProtectGui(Screen)
    local Environment = GetGlobalEnvironment()
    local ProtectFunction = rawget(Environment, "protect_gui")
    if type(ProtectFunction) == "function" then
        pcall(ProtectFunction, Screen)
        return
    end

    local Syn = rawget(Environment, "syn")
    if type(Syn) == "table" and type(Syn.protect_gui) == "function" then
        pcall(Syn.protect_gui, Screen)
    end
end

local function SerializeConfigInput(Input)
    if typeof(Input) ~= "EnumItem" then return nil end
    local EnumType, Name = tostring(Input):match("^Enum%.([^%.]+)%.(.+)$")
    if not EnumType or not Name then return nil end
    return {EnumType = EnumType, Name = Name}
end

local function DeserializeConfigInput(Data)
    if type(Data) ~= "table" then return nil end
    local Success, EnumType = pcall(function()
        return Enum[Data.EnumType]
    end)
    if not Success or not EnumType then return nil end
    return EnumType[Data.Name]
end

local function SerializeConfigColor(Color)
    if typeof(Color) ~= "Color3" then return nil end
    return {Color.R, Color.G, Color.B}
end

local function DeserializeConfigColor(Value)
    if type(Value) ~= "table" then return nil end
    return Color3.new(
        math.clamp(tonumber(Value[1]) or 0, 0, 1),
        math.clamp(tonumber(Value[2]) or 0, 0, 1),
        math.clamp(tonumber(Value[3]) or 0, 0, 1)
    )
end

local function GetExecutorFunction(Name)
    local Aliases = {
        makefolder = {"makefolder", "createfolder"},
        writefile = {"writefile"},
        readfile = {"readfile"},
        isfile = {"isfile"},
        isfolder = {"isfolder"},
        listfiles = {"listfiles"},
        delfile = {"delfile", "removefile"},
    }
    local Names = Aliases[Name] or {Name}
    local Environment = GetGlobalEnvironment()

    local SharedEnvironment
    if type(getgenv) == "function" then
        local Success, Result = pcall(getgenv)
        if Success and type(Result) == "table" then
            SharedEnvironment = Result
        end
    end
    SharedEnvironment = SharedEnvironment or Environment

    for _, Candidate in ipairs(Names) do
        local Function = rawget(_G, Candidate)
        if type(Function) == "function" then
            return Function
        end

        Function = rawget(SharedEnvironment, Candidate)
        if type(Function) == "function" then
            return Function
        end

        Function = rawget(Environment, Candidate)
        if type(Function) == "function" then
            return Function
        end

        local Syn = rawget(SharedEnvironment, "syn") or rawget(Environment, "syn")
        if type(Syn) == "table" and type(Syn[Candidate]) == "function" then
            return Syn[Candidate]
        end
        if type(syn) == "table" and type(syn[Candidate]) == "function" then
            return syn[Candidate]
        end
    end

    return nil
end

local function EnsureConfigFolders()
    local MakeFolder = GetExecutorFunction("makefolder")
    local IsFolder = GetExecutorFunction("isfolder")
    if type(MakeFolder) ~= "function" then return false end

    local function EnsureFolder(Path)
        if type(IsFolder) == "function" then
            local Success, Exists = pcall(IsFolder, Path)
            if Success and Exists then return true end
        end
        local Success = pcall(MakeFolder, Path)
        return Success
    end

    local RootReady = EnsureFolder("Wisper")
    local ConfigsReady = EnsureFolder("Wisper/Configs")
    if not ConfigsReady then
        ConfigsReady = EnsureFolder("Wisper\\Configs")
    end
    return RootReady and ConfigsReady
end

function Library:_ConfigPath()
    local GameId = tonumber(game.GameId) or 0
    if GameId == 0 then
        GameId = tonumber(game.PlaceId) or 0
    end
    return "Wisper/Configs/" .. tostring(GameId) .. ".json"
end

function Library:_WriteConfigStorage()
    EnsureConfigFolders()
    local WriteFile = GetExecutorFunction("writefile")
    if type(WriteFile) ~= "function" then return false end

    local Payload = {
        Version = 1,
        ConfigNames = self.ConfigNames or {},
        AutoLoad = self.AutoLoadConfigName,
        Configs = self.ConfigRecords or {},
    }
    local Success, Encoded = pcall(function()
        return HttpService:JSONEncode(Payload)
    end)
    if not Success then return false end
    local Path = self:_ConfigPath()
    local Written = pcall(WriteFile, Path, Encoded)
    if not Written then
        Written = pcall(WriteFile, Path:gsub("/", "\\"), Encoded)
    end
    return Written
end

function Library:_LoadConfigStorage()
    local ReadFile = GetExecutorFunction("readfile")
    local IsFile = GetExecutorFunction("isfile")
    if type(ReadFile) ~= "function" then return false end
    if type(IsFile) == "function" then
        local ExistsSuccess, Exists = pcall(IsFile, self:_ConfigPath())
        if not ExistsSuccess or not Exists then return false end
    end

    local Success, Content = pcall(ReadFile, self:_ConfigPath())
    if not Success or type(Content) ~= "string" then return false end
    local DecodedSuccess, Data = pcall(function()
        return HttpService:JSONDecode(Content)
    end)
    if not DecodedSuccess or type(Data) ~= "table" then return false end

    self.ConfigRecords = type(Data.Configs) == "table" and Data.Configs or {}
    self.AutoLoadConfigName = type(Data.AutoLoad) == "string" and Data.AutoLoad or nil
    for _, Name in ipairs(self.ConfigNames or {}) do
        self.ConfigRecords[Name] = self.ConfigRecords[Name]
    end
    table.clear(self.ConfigNames or {})
    for _, Name in ipairs(Data.ConfigNames or {}) do
        if type(Name) == "string" and Name ~= "" then
            table.insert(self.ConfigNames, Name)
        end
    end
    return true
end

function Library:CaptureConfig()
    local Snapshot = {Components = {}}
    local function SameColor(Left, Right)
        return typeof(Left) == "Color3" and typeof(Right) == "Color3"
            and math.abs(Left.R - Right.R) < 0.0001
            and math.abs(Left.G - Right.G) < 0.0001
            and math.abs(Left.B - Right.B) < 0.0001
    end
    local function SameValues(Left, Right)
        if type(Left) ~= "table" or type(Right) ~= "table" then return Left == Right end
        local Seen = {}
        for _, Value in ipairs(Left) do Seen[Value] = true end
        for _, Value in ipairs(Right) do
            if not Seen[Value] then return false end
            Seen[Value] = nil
        end
        return next(Seen) == nil
    end
    for TabIndex, Tab in ipairs(self.Tabs or {}) do
        for CategoryIndex, Category in ipairs(Tab.Categories or {}) do
            for GroupIndex, Group in ipairs(Category.Groups or {}) do
                for ElementIndex, Element in ipairs(Group.Elements or {}) do
                    local State = {
                        Name = Element.Name or (Element.Label and Element.Label.Text) or ("Element " .. tostring(ElementIndex)),
                        Type = Element.Type == "Toggle" and "Checkbox" or Element.Type,
                        TabName = Tab.Name,
                        CategoryName = Category.Name,
                        GroupName = Group.Name,
                    }
                    local Changed = false
                    if Element.Type == "Toggle" then
                        State.Value = Element.Value == true
                        Changed = State.Value ~= (Element.DefaultValue == true)
                        if Element.BoundInput then
                            State.BoundInput = SerializeConfigInput(Element.BoundInput)
                            Changed = true
                        end
                        if Element.ColorPicker then
                            local Picker = Element.ColorPicker
                            local ColorChanged = not SameColor(Picker.Value, Picker.DefaultValue)
                            local CheckboxChanged = Picker.CheckboxValue ~= (Picker.DefaultCheckboxValue == true)
                            if ColorChanged then State.Color = SerializeConfigColor(Picker.Value) end
                            if CheckboxChanged then State.ColorCheckboxValue = Picker.CheckboxValue == true end
                            Changed = Changed or ColorChanged or CheckboxChanged
                        end
                    elseif Element.Type == "Slider" then
                        State.Value = Element.Value
                        Changed = Element.Value ~= Element.DefaultValue
                    elseif Element.Type == "DoubleSlider" then
                        State.MinValue = Element.MinValue
                        State.MaxValue = Element.MaxValue
                        Changed = Element.MinValue ~= Element.DefaultMinValue or Element.MaxValue ~= Element.DefaultMaxValue
                    elseif Element.Type == "ColorPicker" then
                        Changed = not SameColor(Element.Value, Element.DefaultValue)
                            or Element.CheckboxValue ~= (Element.DefaultCheckboxValue == true)
                        if Changed then
                            State.Value = SerializeConfigColor(Element.Value)
                            State.CheckboxValue = Element.CheckboxValue == true
                        end
                    elseif Element.Type == "Textbox" then
                        State.Value = Element.Value or ""
                        Changed = State.Value ~= (Element.DefaultValue or "")
                    elseif Element.Type == "Dropdown" then
                        State.Value = Element.Value
                        Changed = State.Value ~= Element.DefaultValue
                    elseif Element.Type == "MultiDropdown" then
                        State.Value = {}
                        for _, Value in ipairs(Element:Get() or {}) do
                            table.insert(State.Value, Value)
                        end
                        Changed = not SameValues(State.Value, Element.DefaultValue or {})
                    end
                    if Changed then
                        table.insert(Snapshot.Components, State)
                    end
                end
            end
        end
    end
    return Snapshot
end

function Library:SaveConfig(Name, Snapshot)
    if type(Name) ~= "string" or Name == "" then return false end
    self.ConfigRecords = self.ConfigRecords or {}
    self.ConfigRecords[Name] = Snapshot or self:CaptureConfig()
    return self:_WriteConfigStorage()
end

-- Auto-save to a default config
function Library:AutoSave()
    if self._RestoringConfig or not self._AutoSaveReady then return false end
    local ConfigName = "__AutoSave__"
    local Snapshot = self:CaptureConfig()
    local Saved = self:SaveConfig(ConfigName, Snapshot)
    if Saved then
        local Ok, Signature = pcall(function()
            return HttpService:JSONEncode(Snapshot)
        end)
        if Ok then self._LastAutoSaveSignature = Signature end
    end
    return Saved
end

function Library:AutoLoad()
    local ConfigName = "__AutoSave__"
    if self.ConfigRecords and self.ConfigRecords[ConfigName] then
        return self:LoadConfig(ConfigName)
    end
    return false
end

function Library:LoadConfig(Name)
    local Snapshot = self.ConfigRecords and self.ConfigRecords[Name]
    if type(Snapshot) ~= "table" then return false end
    local WasRestoring = self._RestoringConfig
    self._RestoringConfig = true
    for _, State in ipairs(Snapshot.Components or {}) do
        local Element
        if State.TabName and State.CategoryName and State.GroupName and State.Name then
            for _, Tab in ipairs(self.Tabs or {}) do
                if Tab.Name == State.TabName then
                    for _, Category in ipairs(Tab.Categories or {}) do
                        if Category.Name == State.CategoryName then
                            for _, Group in ipairs(Category.Groups or {}) do
                                if Group.Name == State.GroupName then
                                    for _, Candidate in ipairs(Group.Elements or {}) do
                                        local CandidateName = Candidate.Name or (Candidate.Label and Candidate.Label.Text)
                                        if CandidateName == State.Name then
                                            Element = Candidate
                                            break
                                        end
                                    end
                                end
                                if Element then break end
                            end
                        end
                        if Element then break end
                    end
                end
                if Element then break end
            end
        else
            local Tab = self.Tabs and self.Tabs[State.Tab]
            local Category = Tab and Tab.Categories[State.Category]
            local Group = Category and Category.Groups[State.Group]
            Element = Group and Group.Elements[State.Element]
        end
        if Element then
            if Element.Type == "Toggle" then
                Element:Set(State.Value == true)
                if Element.SetKeybind then
                    Element:SetKeybind(DeserializeConfigInput(State.BoundInput))
                end
                if Element.ColorPicker then
                    local Color = DeserializeConfigColor(State.Color)
                    if Color then Element.ColorPicker:Set(Color) end
                    if Element.ColorPicker.SetCheckbox then
                        Element.ColorPicker:SetCheckbox(State.ColorCheckboxValue == true)
                    end
                end
            elseif Element.Type == "Slider" or Element.Type == "Dropdown" or Element.Type == "MultiDropdown" or Element.Type == "Textbox" then
                Element:Set(State.Value)
            elseif Element.Type == "DoubleSlider" then
                Element:Set(State.MinValue, State.MaxValue)
            elseif Element.Type == "ColorPicker" then
                local Color = DeserializeConfigColor(State.Value)
                if Color then Element:Set(Color) end
                if Element.SetCheckbox then
                    Element:SetCheckbox(State.CheckboxValue == true)
                end
            end
        end
    end
    self._RestoringConfig = WasRestoring
    self.ActiveConfigName = Name
    if self.UpdateKeybindList then self.UpdateKeybindList() end
    return true
end

function Library:DeleteConfig(Name)
    if type(self.ConfigRecords) == "table" then
        self.ConfigRecords[Name] = nil
    end
    if self.AutoLoadConfigName == Name then
        self.AutoLoadConfigName = nil
    end
    return self:_WriteConfigStorage()
end

local function GetLocalPlayer()
    local Player = Players.LocalPlayer
    while not Player do
        task.wait()
        Player = Players.LocalPlayer
    end
    return Player
end

function Library:_RemoveOldGui()
    local Environment = GetGlobalEnvironment()
    local PreviousScreen = Environment.__WisperLibraryNewInstance
    if PreviousScreen then
        pcall(function()
            PreviousScreen:Destroy()
        end)
        Environment.__WisperLibraryNewInstance = nil
    end

    local Player = GetLocalPlayer()
    local PlayerGui = Player:WaitForChild("PlayerGui")
    local GuiParent = GetGuiParent(PlayerGui)
    local Parents = {PlayerGui, CoreGui}

    if GuiParent ~= PlayerGui and GuiParent ~= CoreGui then
        table.insert(Parents, GuiParent)
    end

    for _, Parent in ipairs(Parents) do
        for _, Child in ipairs(Parent:GetChildren()) do
            if Child.Name == "WisperLibraryNew" then
                Child:Destroy()
            end
        end
    end

    return GuiParent
end

function Library:_ApplyTheme()
    if not self.Main or not self.Theme then return end

    self.Main.BackgroundColor3 = self.Theme.Window.Background

    if self.Sidebar then
        self.Sidebar.BackgroundColor3 = self.Theme.Sidebar.Background
    end

    if self.BottomNavigation then
        self.BottomNavigation.BackgroundColor3 = self.Theme.Sidebar.Background
    end

    if self.Search then
        self.Search.BackgroundColor3 = self.Theme.Surface.Background
    end

    if self.Tabs then
        for _, Tab in ipairs(self.Tabs) do
            Tab.Button.BackgroundColor3 = self.NavigationType == 2 and (Tab.Selected and self.Theme.Accent or self.Theme.Surface.Background) or self.Theme.Surface.Background
            Tab.Label.TextColor3 = self.Theme.Sidebar.Tabs.Text
            if Tab.IconParts then
                for _, Part in ipairs(Tab.IconParts) do
                    Part.BackgroundColor3 = self.Theme.Sidebar.Tabs.Text
                end
            else
                Tab.Icon.ImageColor3 = self.Theme.Sidebar.Tabs.Text
            end
            Tab.Indicator.BackgroundColor3 = self.Theme.Accent
        end
    end

    if self.TopButtons then
        for _, TopButton in ipairs(self.TopButtons) do
            TopButton.Button.BackgroundColor3 = self.Theme.Surface.Background
        end
    end

    if self.ConfigMenu then
        self.ConfigMenu.BackgroundColor3 = self.Theme.Settings.Background
        self.ConfigMenuTitle.TextColor3 = self.Theme.Settings.Text
        self.ConfigMenuIcon.ImageColor3 = self.Theme.Settings.Text
        self.ConfigMenuSearch.BackgroundColor3 = self.Theme.Groups.ToggleBackground
        self.ConfigMenuSearchIcon.ImageColor3 = self.Theme.Settings.Text
        self.ConfigMenuDivider.BackgroundColor3 = self.Theme.Groups.Divider
        self.ConfigAddButton.BackgroundColor3 = self.Theme.Groups.ToggleBackground
        self.ConfigAddButton.TextColor3 = self.Theme.Settings.Text
        self.ConfigAddIcon.ImageColor3 = self.Theme.Settings.Text
        self.ConfigPresetsButton.BackgroundColor3 = self.Theme.Groups.ToggleBackground
        for _, Row in ipairs(self.ConfigRows or {}) do
            Row.Background.BackgroundColor3 = self.Theme.Groups.ToggleBackground
            Row.Label.TextColor3 = self.Theme.Settings.Text
        end
    end

    if self.ConfigAddMenu then
        self.ConfigAddMenu.BackgroundColor3 = self.Theme.Settings.Background
        self.ConfigAddMenuInput.BackgroundColor3 = self.Theme.Groups.ToggleBackground
        self.ConfigAddMenuInput.TextColor3 = self.Theme.Settings.Text
        self.ConfigAddMenuInput.PlaceholderColor3 = self.Theme.Settings.Text:Lerp(self.Theme.Groups.ToggleBackground, 0.6)
        self.ConfigCreateButton.BackgroundColor3 = self.Theme.Accent
    end

    if self.ConfigRowMenu then
        self.ConfigRowMenu.BackgroundColor3 = self.Theme.Settings.Background
        self.ConfigRowMenuLabel.TextColor3 = self.Theme.Settings.Text
        self.ConfigRowAutoLoadLabel.TextColor3 = self.Theme.Settings.Text
        self.ConfigRowAutoLoadButton.BackgroundTransparency = 1
        self.ConfigRowAutoLoadCheck.BackgroundColor3 = self.ConfigRowMenuTarget == self.AutoLoadConfigName and self.Theme.Accent or self.Theme.Groups.ToggleBackground
        self.ConfigRowAutoLoadCheckIcon.ImageColor3 = Color3.new(0, 0, 0)
        self.ConfigRowDeleteButton.BackgroundColor3 = self.Theme.Groups.ToggleBackground
        self.ConfigRowDeleteButton.BackgroundTransparency = 0
        self.ConfigRowDeleteLabel.TextColor3 = self.Theme.Settings.Text
    end

    if self.CategoryButton then
        self.CategoryButton.BackgroundColor3 = self.Theme.Surface.Background
        self.CategoryLabel.TextColor3 = self.Theme.Sidebar.Tabs.Text
        self.CategoryArrow.ImageColor3 = self.Theme.Sidebar.Tabs.Text
    end

    if self.CategoryDropdown then
        self.CategoryDropdown.BackgroundColor3 = self.Theme.Settings.Background
        for _, Item in ipairs(self.CategoryDropdownItems or {}) do
            Item.Button.BackgroundColor3 = self.Theme.Settings.SelectedBackground
            Item.Label.TextColor3 = self.Theme.Settings.Text
            Item.Check.ImageColor3 = self.Theme.Accent
        end
    end

    if self.Breadcrumb then
        self.BreadcrumbTabLabel.TextColor3 = self.Theme.Settings.Text
        self.BreadcrumbArrow.ImageColor3 = self.Theme.Settings.Text
        self.BreadcrumbCategoryLabel.TextColor3 = self.Theme.Settings.Text
    end

    if self.Tabs then
        for _, Tab in ipairs(self.Tabs) do
            for _, Category in ipairs(Tab.Categories or {}) do
                for _, Group in ipairs(Category.Groups or {}) do
                    Group.Frame.BackgroundColor3 = self.Theme.Groups.Background
                    Group.Title.TextColor3 = self.Theme.Groups.Title
                    for _, Divider in ipairs(Group.Dividers or {}) do
                        local DividerFrame = Divider:FindFirstChild("Divider") or Divider
                        DividerFrame.BackgroundColor3 = self.Theme.Groups.Divider
                    end
                    for _, Element in ipairs(Group.Elements or {}) do
                        if Element.Type == "Toggle" then
                            Element.Box.BackgroundColor3 = Element.Value and self.Theme.Accent or self.Theme.Groups.ToggleBackground
                            Element.Check.ImageColor3 = Color3.new(0, 0, 0)
                            Element.Label.TextColor3 = self.Theme.Groups.Title
                            if Element.KeybindButton then
                                Element.KeybindButton.ImageColor3 = self.Theme.Groups.Title
                            end
                            if Element.KeybindCapture then
                                Element.KeybindCapture.BackgroundColor3 = self.Theme.Groups.ToggleBackground
                                Element.KeybindCapture.TextColor3 = self.Theme.Settings.Text
                            end
                            if Element.KeybindPopup then
                                Element.KeybindPopup.BackgroundColor3 = self.Theme.Settings.Background
                            end
                        elseif Element.Type == "Slider" then
                            Element.Track.BackgroundColor3 = self.Theme.Groups.SliderBackground
                            Element.Fill.BackgroundColor3 = self.Theme.Accent
                            Element.ValueBubble.BackgroundColor3 = self.Theme.Settings.SelectedBackground
                            Element.Gradient.Color = ColorSequence.new(
                                Color3.new(1, 1, 1),
                                Color3.fromRGB(205, 205, 255)
                            )
                            Element.Label.TextColor3 = self.Theme.Groups.Title
                            Element.ValueLabel.TextColor3 = self.Theme.Groups.Title
                        elseif Element.Type == "DoubleSlider" then
                            Element.Track.BackgroundColor3 = self.Theme.Groups.SliderBackground
                            Element.Fill.BackgroundColor3 = self.Theme.Accent
                            Element.MinBubble.BackgroundColor3 = self.Theme.Settings.SelectedBackground
                            Element.MaxBubble.BackgroundColor3 = self.Theme.Settings.SelectedBackground
                            Element.Gradient.Color = ColorSequence.new(
                                Color3.new(1, 1, 1),
                                Color3.fromRGB(205, 205, 255)
                            )
                            Element.Label.TextColor3 = self.Theme.Groups.Title
                            Element.ValueLabel.TextColor3 = self.Theme.Groups.Title
                        elseif Element.Type == "ColorPicker" then
                            Element.Label.TextColor3 = self.Theme.Groups.Title
                            Element.Ring.BackgroundColor3 = Element.Value
                            Element.Preview.BackgroundColor3 = Element.Value
                            Element.Popup.BackgroundColor3 = self.Theme.Groups.Background
                            Element.HexInput.BackgroundColor3 = self.Theme.Groups.ToggleBackground
                            Element.AlphaBar.BackgroundColor3 = Element.Value
                            if Element.Checkbox then
                                Element.Checkbox.BackgroundColor3 = Element.CheckboxValue and self.Theme.Accent or self.Theme.Groups.ToggleBackground
                                Element.CheckboxCheck.ImageColor3 = Color3.new(0, 0, 0)
                            end
                        elseif Element.Type == "Textbox" then
                            Element.Label.TextColor3 = self.Theme.Groups.Title
                            Element.Input.BackgroundColor3 = self.Theme.Groups.ToggleBackground
                            Element.Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                            Element.Input.PlaceholderColor3 = self.Theme.Groups.Title:Lerp(self.Theme.Groups.ToggleBackground, 0.6)
                        elseif Element.Type == "Button" then
                            Element.Button.BackgroundColor3 = self.Theme.Groups.ToggleBackground
                            Element.Label.TextColor3 = self.Theme.Groups.Title
                        elseif Element.Type == "Dropdown" or Element.Type == "MultiDropdown" then
                            Element.Header.BackgroundColor3 = self.Theme.Groups.ToggleBackground
                            Element.Menu.BackgroundColor3 = self.Theme.Settings.Background
                            Element.Label.TextColor3 = self.Theme.Groups.Title
                            Element.ValueLabel.TextColor3 = self.Theme.Groups.Title
                            Element.Arrow.ImageColor3 = self.Theme.Groups.Title
                            for _, Option in ipairs(Element.Options) do
                                Option.Button.BackgroundColor3 = self.Theme.Settings.SelectedBackground
                                Option.Label.TextColor3 = self.Theme.Groups.Title
                                Option.Check.ImageColor3 = self.Theme.Accent
                            end
                        end
                    end
                end
                for _, ColumnFrame in pairs(Category.ColumnFrames or {}) do
                    ColumnFrame.ScrollBarImageColor3 = self.Theme.Settings.Text
                end
                if Category.ColumnBottomMask then
                    for _, Mask in pairs(Category.ColumnMasks or {}) do
                        Mask.BackgroundColor3 = self.Theme.Window.Background
                    end
                end
            end
        end
    end

    if self.SettingsMenu then
        self.SettingsMenu.BackgroundColor3 = self.Theme.Settings.Background
    end

    if self.SettingsProfile then
        self.SettingsProfile.Avatar.BackgroundColor3 = self.Theme.Surface.Background
        self.SettingsProfile.DisplayName.TextColor3 = self.Theme.Settings.Text
        self.SettingsProfile.Username.TextColor3 = self.Theme.Settings.Username
        self.SettingsProfile.Divider.BackgroundColor3 = self.Theme.Settings.Divider
    end

    if self.SettingsStyle then
        self.SettingsStyle.Label.TextColor3 = self.Theme.Settings.Text
        self.SettingsStyle.Icon.ImageColor3 = self.Theme.Settings.Text
        self.SettingsStyle.Arrow.ImageColor3 = self.Theme.Settings.Text
    end

    if self.SettingsKeybind then
        self.SettingsKeybind.Label.TextColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.Icon.ImageColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.SettingsButton.ImageColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.Arrow.ImageColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.Dropdown.BackgroundColor3 = self.Theme.Settings.Background
        self.SettingsKeybind.ToggleLabel.TextColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.Checkbox.BackgroundColor3 = self.KeybindListEnabled and self.Theme.Accent or self.Theme.Groups.ToggleBackground
        self.SettingsKeybind.CheckboxCheck.ImageColor3 = Color3.new(0, 0, 0)
        self.SettingsKeybind.ListScaleLabel.TextColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.ListScaleValue.TextColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.ListScaleArrow.ImageColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.ListScaleDropdown.BackgroundColor3 = self.Theme.Settings.Background
        self.SettingsKeybind.VisibilityLabel.TextColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.VisibilityArrow.ImageColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.VisibilityDropdown.BackgroundColor3 = self.Theme.Settings.Background
        self.SettingsKeybind.BoundOnlyLabel.TextColor3 = self.Theme.Settings.Text
        self.SettingsKeybind.BoundOnlyCheckbox.BackgroundColor3 = self.ShowBoundKeysOnly and self.Theme.Accent or self.Theme.Groups.ToggleBackground
        self.SettingsKeybind.BoundOnlyCheck.ImageColor3 = Color3.new(0, 0, 0)
        for ScaleValue, Item in pairs(self.SettingsListScaleItems or {}) do
            Item.Button.BackgroundColor3 = self.Theme.Settings.SelectedBackground
            Item.Label.TextColor3 = self.Theme.Settings.Text
            Item.Check.ImageColor3 = self.Theme.Accent
            Item.Button.BackgroundTransparency = Item.Selected and 0 or 1
            Item.Label.Position = UDim2.fromOffset(Item.Selected and 33 or 5, 0)
            Item.Label.TextTransparency = (Item.Selected or Item.Hovered) and 0 or 0.6
            Item.Check.Position = UDim2.fromOffset(Item.Selected and 9 or 5, 7)
            Item.Check.ImageTransparency = Item.Selected and 0 or 1
        end
        for _, Item in pairs(self.SettingsVisibilityItems or {}) do
            Item.Button.BackgroundColor3 = self.Theme.Settings.SelectedBackground
            Item.Label.TextColor3 = self.Theme.Settings.Text
            Item.Check.ImageColor3 = self.Theme.Accent
            Item.Button.BackgroundTransparency = Item.Selected and 0 or 1
            Item.Label.Position = UDim2.fromOffset(Item.Selected and 33 or 5, 0)
            Item.Label.TextTransparency = (Item.Selected or Item.Hovered) and 0 or 0.6
            Item.Check.Position = UDim2.fromOffset(Item.Selected and 9 or 5, 7)
            Item.Check.ImageTransparency = Item.Selected and 0 or 1
        end
    end

    if self.KeybindList then
        self.KeybindList.BackgroundColor3 = self.Theme.Settings.Background
        if self.KeybindListSurface then
            self.KeybindListSurface.BackgroundColor3 = self.Theme.Settings.Background
        end
        self.KeybindListTitle.TextColor3 = self.Theme.Settings.Text
        self.KeybindListFunctionColumn.TextColor3 = self.Theme.Settings.Text
        self.KeybindListHotkeyColumn.TextColor3 = self.Theme.Settings.Text
        self.KeybindListStatusColumn.TextColor3 = self.Theme.Settings.Text
        self.KeybindListColumns.BackgroundColor3 = self.Theme.Surface.Background
        self.KeybindListDividerLine.BackgroundColor3 = self.Theme.Groups.Divider
        if self.KeybindList.Visible and self.UpdateKeybindList then
            self.UpdateKeybindList()
        end
    end

    if self.ThemeDropdown then
        self.ThemeDropdown.BackgroundColor3 = self.Theme.Settings.Background
        for _, Item in pairs(self.ThemeDropdownItems or {}) do
            Item.Button.BackgroundColor3 = self.Theme.Settings.SelectedBackground
            Item.Button.BackgroundTransparency = Item.Selected and 0 or 1
            Item.Check.Position = UDim2.fromOffset(Item.Selected and 9 or 5, 7)
            Item.Check.ImageTransparency = Item.Selected and 0 or 1
            Item.Label.TextColor3 = self.Theme.Settings.Text
            Item.Label.Position = UDim2.fromOffset(Item.Selected and 33 or 5, 0)
            Item.Label.TextTransparency = (Item.Selected or Item.Hovered) and 0 or 0.6
            Item.Check.ImageColor3 = self.Theme.Accent
        end
    end
end

function Library:SetTheme(Name)
    local Theme = self.Themes[Name]
    if not Theme then
        return false
    end

    self.ThemeName = Name
    self.Theme = Theme
    self:_ApplyTheme()
    return true
end

function Library:Destroy()
    if self._MouseUnlockConnection then
        self._MouseUnlockConnection:Disconnect()
        self._MouseUnlockConnection = nil
    end
    if self._MouseUnlockActive then
        self._MouseUnlockActive = false
        if self._PreviousMouseBehavior then
            UserInputService.MouseBehavior = self._PreviousMouseBehavior
        end
        if self._PreviousMouseIconEnabled ~= nil then
            UserInputService.MouseIconEnabled = self._PreviousMouseIconEnabled
        end
    end
    self._PreviousMouseBehavior = nil
    self._PreviousMouseIconEnabled = nil
    self._MouseUnlockChecked = false
    if self.Screen and self._AutoSaveReady and not self._RestoringConfig then
        self:AutoSave()
    end
    self._AutoSaveReady = false
    if self.Screen then
        self.Screen:Destroy()
        self.Screen = nil
        self.Main = nil
        self.NavigationType = nil
        if self.NavigationPositionConnection then
            self.NavigationPositionConnection:Disconnect()
            self.NavigationPositionConnection = nil
        end
        for _, Connection in ipairs(self.DragConnections or {}) do
            Connection:Disconnect()
        end
        self.DragConnections = nil
        self.Sidebar = nil
        self.BottomNavigation = nil
        self.Search = nil
        self.SearchInput = nil
        self.Tabs = nil
        self.ActiveTab = nil
        self.TopButtons = nil
        self.ConfigMenu = nil
        self.ConfigDimmer = nil
        self.ConfigAddMenu = nil
        self.ConfigAddButton = nil
        self.ConfigAddIcon = nil
        self.ConfigPresetsButton = nil
        self.ConfigRowMenu = nil
        self.ConfigRowAutoLoadCheckIcon = nil
        self.ConfigRowMenuTarget = nil
        self.AutoLoadConfigName = nil
        self.ConfigNames = nil
        self.ConfigRows = nil
        self.ConfigRecords = nil
        self.ActiveConfigName = nil
        self.SettingsMenu = nil
        self.SettingsDimmer = nil
        self.SettingsOverlay = nil
        self.SettingsOpen = nil
        self.SettingsProfile = nil
        self.SettingsStyle = nil
        self.SettingsKeybind = nil
        self.KeybindListEnabled = nil
        self.SettingsListScale = nil
        self.SettingsListScaleItems = nil
        self.SettingsVisibilityItems = nil
        self.KeybindListVisibility = nil
        self.GuiVisible = nil
        self.ShowBoundKeysOnly = nil
        self.KeybindItems = nil
        self.KeybindList = nil
        self.KeybindListSurface = nil
        self.KeybindListSurfaceScale = nil
        self.KeybindListScale = nil
        self.UpdateKeybindList = nil
        self.KeybindListRows = nil
        self.KeybindListTitle = nil
        self.KeybindListColumns = nil
        self.KeybindListFunctionColumn = nil
        self.KeybindListHotkeyColumn = nil
        self.KeybindListStatusColumn = nil
        self.KeybindListDivider = nil
        self.KeybindListDividerLine = nil
        self.ThemeDropdown = nil
        self.ThemeDropdownContent = nil
        self.ThemeDropdownItems = nil
        self.CategoryButton = nil
        self.CategoryLabel = nil
        self.CategoryArrow = nil
        self.CategoryDropdown = nil
        self.CategoryDropdownContent = nil
        self.CategoryDropdownItems = nil
        self.CategoryDimmer = nil
        self.CategoryOverlay = nil
        self.Breadcrumb = nil
        self.BreadcrumbTabLabel = nil
        self.BreadcrumbArrow = nil
        self.BreadcrumbCategoryLabel = nil
        self.GroupArea = nil
        self.CreateTab = nil
        self.MainStroke = nil
    end
end

function Library:CreateWindow(Options)
    Options = Options or {}
    self:Destroy()

    local NavigationType = tonumber(Options.NavigationType or Options.Navigation or Options.Type) or 1
    NavigationType = NavigationType == 2 and 2 or 1
    self.NavigationType = NavigationType
    self.KeybindItems = {}
    self.GuiVisible = true
    self.KeybindListVisibility = "With menu"
    self.ShowBoundKeysOnly = true

    local GuiParent = self:_RemoveOldGui()
    local ThemeName = Options.Theme or "Dark"

    self.ThemeName = self.Themes[ThemeName] and ThemeName or "Dark"
    self.Theme = self.Themes[self.ThemeName]

    local Screen = UI.Create("ScreenGui", {
        Name = "WisperLibraryNew",
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = Options.DisplayOrder or -100,
    }, nil)
    ProtectGui(Screen)
    Screen.Parent = GuiParent

    local Main = UI.Create("Frame", {
        Name = "Main",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Window.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(710, 470),
        ZIndex = 1,
    }, Screen)
    UI.Corner(Main, 14)
    UI.Create("UIShadow", {
        BlurRadius = UDim.new(0, 14),
        Color = Color3.fromRGB(0, 0, 0),
        Transparency = 0.55,
        Offset = UDim2.fromOffset(0, 0),
        Spread = UDim2.fromOffset(5, 5),
        ZIndex = -1,
    }, Main)
    local MainScale = UI.ResponsiveScale(Main, 710, 470)

    Main.Active = true
    local MainDragging = false
    local MainDragStart
    local MainStartPosition
    local MainTargetPosition = Main.Position
    local DragConnections = {}

    table.insert(DragConnections, Main.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        MainDragging = true
        MainDragStart = Input.Position
        MainStartPosition = MainTargetPosition
    end))

    table.insert(DragConnections, UserInputService.InputChanged:Connect(function(Input)
        if not MainDragging then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local Scale = math.max(MainScale.Scale, 0.1)
        local Delta = Input.Position - MainDragStart
        MainTargetPosition = UDim2.new(
            MainStartPosition.X.Scale,
            MainStartPosition.X.Offset + Delta.X / Scale,
            MainStartPosition.Y.Scale,
            MainStartPosition.Y.Offset + Delta.Y / Scale
        )
    end))

    table.insert(DragConnections, UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            MainDragging = false
        end
    end))

    table.insert(DragConnections, RunService.RenderStepped:Connect(function(DeltaTime)
        local Alpha = math.clamp(DeltaTime * 14, 0, 1)
        Main.Position = Main.Position:Lerp(MainTargetPosition, Alpha)
    end))
    self.DragConnections = DragConnections

    local Sidebar = UI.Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = self.Theme.Sidebar.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(220, 470),
        Visible = NavigationType == 1,
    }, Main)
    UI.Corner(Sidebar, 14)

    local BottomNavigation = UI.Create("Frame", {
        Name = "BottomNavigation",
        BackgroundColor3 = self.Theme.Sidebar.Background,
        BorderSizePixel = 0,
        AnchorPoint = NavigationType == 2 and Vector2.new(0.5, 0) or Vector2.new(0, 0),
        Position = UDim2.fromOffset(0, NavigationType == 2 and 0 or 410),
        Size = NavigationType == 2 and UDim2.fromOffset(0, 44) or UDim2.fromOffset(710, 60),
        AutomaticSize = NavigationType == 2 and Enum.AutomaticSize.X or Enum.AutomaticSize.None,
        Visible = NavigationType == 2,
        ZIndex = 5,
    }, NavigationType == 2 and Screen or Main)
    UI.Corner(BottomNavigation, NavigationType == 2 and 22 or 14)
    UI.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = NavigationType == 2 and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, BottomNavigation)
    UI.Create("UIPadding", {
        PaddingLeft = UDim.new(0, 6),
        PaddingRight = UDim.new(0, 6),
        PaddingTop = UDim.new(0, NavigationType == 2 and 6 or 0),
        PaddingBottom = UDim.new(0, NavigationType == 2 and 6 or 0),
    }, BottomNavigation)

    UI.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 8),
        Size = UDim2.fromOffset(220, 38),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Text = "Evanesce",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 26,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, Sidebar)

    local Search = UI.Create("Frame", {
        Name = "Search",
        BackgroundColor3 = self.Theme.Surface.Background,
        BorderSizePixel = 0,
        AnchorPoint = NavigationType == 2 and Vector2.new(0.5, 1) or Vector2.new(0, 0),
        Position = NavigationType == 2 and UDim2.fromOffset(0, 0) or UDim2.fromOffset(14, 58),
        Size = UDim2.fromOffset(192, 32),
        ZIndex = 6,
    }, NavigationType == 2 and Screen or Main)
    UI.Corner(Search, NavigationType == 2 and 16 or 8)

    local SearchIcon = UI.Create("ImageLabel", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        Rotation = -270,
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 0.74,
    }, Search)

    local SearchInput = UI.Create("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(34, 0),
        Size = UDim2.fromOffset(150, 32),
        ClearTextOnFocus = false,
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        PlaceholderText = "Search",
        PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
        Text = "",
        TextColor3 = self.Theme.Sidebar.Search.Text,
        TextSize = 15,
        TextTransparency = 0.74,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, Search)

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        SearchInput.TextTransparency = SearchInput.Text == "" and 0.74 or 0
    end)

    SearchInput.Focused:Connect(function()
        TweenService:Create(SearchIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            ImageTransparency = 0,
            ImageColor3 = Color3.fromRGB(255, 255, 255),
        }):Play()
    end)

    SearchInput.FocusLost:Connect(function()
        TweenService:Create(SearchIcon, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            ImageTransparency = 0.74,
            ImageColor3 = self.Theme.Sidebar.Search.Text,
        }):Play()
    end)

    if NavigationType == 2 then
        local function UpdateExternalNavigationPosition()
            local MainPosition = Main.AbsolutePosition
            local MainSize = Main.AbsoluteSize
            Search.Position = UDim2.fromOffset(
                MainPosition.X + MainSize.X / 2,
                MainPosition.Y + 48
            )
            BottomNavigation.Position = UDim2.fromOffset(
                MainPosition.X + MainSize.X / 2,
                MainPosition.Y + MainSize.Y + 66
            )
        end

        Main:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateExternalNavigationPosition)
        Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateExternalNavigationPosition)
        self.NavigationPositionConnection = RunService.RenderStepped:Connect(UpdateExternalNavigationPosition)
        task.defer(UpdateExternalNavigationPosition)
    end

    UI.Create("Frame", {
        Name = "Divider",
        BackgroundColor3 = self.Theme.Sidebar.Divider.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(14, 104),
        Size = UDim2.fromOffset(192, 1),
        Visible = NavigationType == 1,
    }, Sidebar)

    local Tabs = {}
    local SearchUpdating = false
    local ActiveTab
    local CategoryButton
    local CategoryLabel
    local CategoryArrow
    local UpdateCategoryButton
    local CategoryDropdown
    local CategoryDropdownContent
    local CategoryDropdownItems = {}
    local CategoryDropdownOpen = false
    local CategoryDropdownTweenId = 0
    local CloseCategoryDropdown
    local CategoryDimmer
    local CategoryOverlay
    local Breadcrumb
    local BreadcrumbTabLabel
    local BreadcrumbArrow
    local BreadcrumbCategoryLabel
    local UpdateBreadcrumb
    local BreadcrumbTweenId = 0
    local GroupArea
    local UpdateCategoryContent
    local TabTweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local function SetTabState(Tab, Selected, Hovered)
        local StateTweenInfo = SearchUpdating and TweenInfo.new(0) or TabTweenInfo

        if NavigationType == 2 then
            local LabelWidth = math.max(Tab.Label.TextBounds.X, string.len(Tab.Name) * 7)
            local TargetWidth = Selected and LabelWidth + 38 or 32

            if Selected then
                Tab.Label.Visible = true
            end

            TweenService:Create(Tab.Button, StateTweenInfo, {
                Size = UDim2.fromOffset(TargetWidth, 32),
                BackgroundTransparency = Selected and 0 or 1,
                BackgroundColor3 = Selected and self.Theme.Accent or self.Theme.Surface.Background,
            }):Play()
            TweenService:Create(Tab.Label, StateTweenInfo, {
                Size = UDim2.fromOffset(math.max(TargetWidth - 30, 1), 32),
            }):Play()
            TweenService:Create(Tab.Icon, StateTweenInfo, {
                Position = UDim2.fromOffset(8, 8),
                ImageTransparency = Selected and 0 or 0.6,
                ImageColor3 = self.Theme.Sidebar.Tabs.Text,
            }):Play()
            TweenService:Create(Tab.Label, StateTweenInfo, {
                Position = UDim2.fromOffset(30, 0),
                TextTransparency = Selected and 0 or 1,
                TextColor3 = self.Theme.Sidebar.Tabs.Text,
            }):Play()
            TweenService:Create(Tab.Indicator, StateTweenInfo, {
                BackgroundTransparency = 1,
                BackgroundColor3 = self.Theme.Accent,
            }):Play()

            if not Selected then
                task.delay(StateTweenInfo.Time, function()
                    if not Tab.Selected then
                        Tab.Label.Visible = false
                    end
                end)
            end
            return
        end

        local BackgroundTransparency = Selected and 0 or 1
        local ContentTransparency = Selected and 0 or 0.6
        local IconX = Selected and 16 or 12
        local LabelX = Selected and 44 or 40

        TweenService:Create(Tab.Button, StateTweenInfo, {
            BackgroundTransparency = BackgroundTransparency,
            BackgroundColor3 = Color3.fromRGB(175, 55, 68),
        }):Play()
        TweenService:Create(Tab.Label, StateTweenInfo, {
            TextTransparency = ContentTransparency,
            TextColor3 = self.Theme.Sidebar.Tabs.Text,
        }):Play()
        TweenService:Create(Tab.Icon, StateTweenInfo, {
            Position = UDim2.fromOffset(IconX, 10),
        }):Play()
        if Tab.IconParts then
            for _, Part in ipairs(Tab.IconParts) do
                TweenService:Create(Part, StateTweenInfo, {
                    BackgroundTransparency = Selected and 0 or 0.74,
                    BackgroundColor3 = self.Theme.Sidebar.Tabs.Text,
                }):Play()
            end
        else
            TweenService:Create(Tab.Icon, StateTweenInfo, {
                ImageTransparency = Selected and 0 or 0.74,
                ImageColor3 = self.Theme.Sidebar.Tabs.Text,
            }):Play()
        end
        TweenService:Create(Tab.Label, StateTweenInfo, {
            Position = UDim2.fromOffset(LabelX, 0),
        }):Play()
        TweenService:Create(Tab.Indicator, StateTweenInfo, {
            BackgroundTransparency = Selected and 0 or 1,
            BackgroundColor3 = self.Theme.Accent,
        }):Play()
    end

    local function CreateTab(Name, IconName, YPosition, Selected)
        local TabParent = NavigationType == 2 and BottomNavigation or Sidebar
        local Button = UI.Create("TextButton", {
            Name = Name,
            AutoButtonColor = false,
            BackgroundColor3 = NavigationType == 2 and (Selected and self.Theme.Accent or self.Theme.Surface.Background) or self.Theme.Surface.Background,
            BackgroundTransparency = Selected and 0 or 1,
            BorderSizePixel = 0,
            ClipsDescendants = NavigationType == 2,
            LayoutOrder = #Tabs + 1,
            Position = NavigationType == 2 and UDim2.fromOffset(0, 0) or UDim2.fromOffset(14, YPosition),
            Size = NavigationType == 2 and UDim2.fromOffset(150, 32) or UDim2.fromOffset(192, 36),
            Text = "",
        }, TabParent)
        UI.Corner(Button, NavigationType == 2 and 16 or 8)

        local Indicator = UI.Create("Frame", {
            Name = "Indicator",
            BackgroundColor3 = self.Theme.Accent,
            BackgroundTransparency = NavigationType == 2 and 1 or (Selected and 0 or 1),
            BorderSizePixel = 0,
            AnchorPoint = NavigationType == 2 and Vector2.new(0.5, 1) or Vector2.new(0, 0),
            Position = NavigationType == 2 and UDim2.new(0.5, 0, 1, -2) or UDim2.fromOffset(0, 9),
            Size = NavigationType == 2 and UDim2.fromOffset(18, 3) or UDim2.fromOffset(3, 18),
        }, Button)
        UI.Corner(Indicator, 100)

        local Icon
        local IconParts = nil
        Icon = UI.Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = NavigationType == 2 and UDim2.fromOffset(10, 8) or UDim2.fromOffset(12, 10),
            Size = UDim2.fromOffset(16, 16),
            Image = FallbackIcons[IconName] or GetIcon(IconName),
            ImageColor3 = self.Theme.Sidebar.Tabs.Text,
            ImageTransparency = Selected and 0 or 0.74,
            Visible = true,
            ClipsDescendants = true,
            ZIndex = 2,
        }, Button)

        local Label = UI.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(40, 0),
            Size = NavigationType == 2 and UDim2.fromOffset(105, 32) or UDim2.fromOffset(140, 36),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Name,
            TextColor3 = self.Theme.Sidebar.Tabs.Text,
            TextSize = 14,
            TextTransparency = Selected and 0 or 0.6,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, Button)

        local Tab = {
            Name = Name,
            Button = Button,
            Indicator = Indicator,
            Icon = Icon,
            IconParts = IconParts,
            Label = Label,
            Selected = Selected,
            Hovered = false,
            Categories = {},
            ActiveCategoryIndex = 1,
        }
        table.insert(Tabs, Tab)

        Button.Activated:Connect(function()
            local TabChanged = not Tab.Selected
            for _, OtherTab in ipairs(Tabs) do
                OtherTab.Selected = OtherTab == Tab
                SetTabState(OtherTab, OtherTab.Selected, false)
            end
            ActiveTab = Name
            self.ActiveTab = Name
            if TabChanged and UpdateCategoryButton then
                UpdateCategoryButton(Tab)
            end
            if UpdateCategoryContent then
                UpdateCategoryContent(Tab)
            end
        end)

        SetTabState(Tab, Selected, false)

        if Selected then
            ActiveTab = Name
            self.ActiveTab = Name
        end

        return Tab
    end

    local TopButtons = {}
    local ConfigButton
    local ConfigMenu
    local ConfigDimmer
    local ConfigAddMenu
    local ConfigRowMenu
    local ConfigMenuOpen = false
    local ConfigAddMenuOpen = false
    local ConfigRowMenuOpen = false
    local ConfigRowMenuTarget
    local AutoLoadConfigName
    local ActiveConfigName
    local DeleteConfirmName
    local DeleteConfirmToken = 0
    local ConfigNames = {}
    local ConfigMenuBasePosition
    local ConfigAddMenuBasePosition
    local CloseConfigMenu
    local CloseConfigAddMenu
    local CloseConfigRowMenu
    local OpenConfigRowMenu
    local SettingsMenu
    local SettingsDimmer
    local SettingsOverlay
    local ThemeDropdown
    local ThemeDropdownContent
    local ThemeDropdownOpen = false
    local ThemeDropdownTweenId = 0
    local CloseThemeDropdown
    local KeybindDropdown
    local KeybindDropdownContent
    local KeybindDropdownOpen = false
    local KeybindDropdownTweenId = 0
    local KeybindDropdownBasePosition
    local CloseKeybindDropdown
    local VisibilityDropdown
    local VisibilityDropdownContent
    local VisibilityDropdownOpen = false
    local VisibilityDropdownTweenId = 0
    local CloseVisibilityDropdown
    local SettingsOpen = false
    local SettingsTweenId = 0
    local SettingsTweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local ThemeHoverTweenInfo = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local ThemeSelectionTweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local function TweenSettingsProfile(Opening)
        local Profile = self.SettingsProfile
        if not Profile then return end

        TweenService:Create(Profile.Avatar, SettingsTweenInfo, {
            BackgroundTransparency = Opening and 0 or 1,
            ImageTransparency = Opening and 0 or 1,
        }):Play()
        TweenService:Create(Profile.DisplayName, SettingsTweenInfo, {
            TextTransparency = Opening and 0 or 1,
        }):Play()
        TweenService:Create(Profile.Username, SettingsTweenInfo, {
            TextTransparency = Opening and 0.6 or 1,
        }):Play()
        TweenService:Create(Profile.Divider, SettingsTweenInfo, {
            BackgroundTransparency = Opening and 0 or 1,
        }):Play()

        local Style = self.SettingsStyle
        if Style then
            TweenService:Create(Style.Icon, SettingsTweenInfo, {
                ImageTransparency = Opening and 0.74 or 1,
            }):Play()
            TweenService:Create(Style.Arrow, SettingsTweenInfo, {
                ImageTransparency = Opening and 0.74 or 1,
            }):Play()
            TweenService:Create(Style.Label, SettingsTweenInfo, {
                TextTransparency = Opening and 0 or 1,
            }):Play()
        end

        local Keybind = self.SettingsKeybind
        if Keybind then
            TweenService:Create(Keybind.Icon, SettingsTweenInfo, {
                ImageTransparency = Opening and 0.74 or 1,
            }):Play()
            TweenService:Create(Keybind.Arrow, SettingsTweenInfo, {
                ImageTransparency = Opening and 0.74 or 1,
            }):Play()
            TweenService:Create(Keybind.Label, SettingsTweenInfo, {
                TextTransparency = Opening and 0 or 1,
            }):Play()
            TweenService:Create(Keybind.Checkbox, SettingsTweenInfo, {
                BackgroundTransparency = Opening and 0 or 1,
            }):Play()
            TweenService:Create(Keybind.CheckboxCheck, SettingsTweenInfo, {
                ImageTransparency = Opening and (self.KeybindListEnabled and 0 or 1) or 1,
            }):Play()
        end
    end

    local function TweenThemeDropdown(Opening)
        if not self.ThemeDropdownItems or not ThemeDropdownContent then return end

        for _, Item in pairs(self.ThemeDropdownItems) do
            Item.Button.BackgroundTransparency = Item.Selected and 0 or 1
            Item.Button.BackgroundColor3 = self.Theme.Settings.SelectedBackground
            Item.Check.Position = UDim2.fromOffset(Item.Selected and 9 or 5, 7)
            Item.Check.ImageTransparency = Item.Selected and 0 or 1
            Item.Label.Position = UDim2.fromOffset(Item.Selected and 33 or 5, 0)
            Item.Label.TextTransparency = (Item.Selected or Item.Hovered) and 0 or 0.6
        end

        ThemeDropdownContent.GroupTransparency = Opening and 1 or 0
        TweenService:Create(ThemeDropdownContent, SettingsTweenInfo, {
            GroupTransparency = Opening and 0 or 1,
        }):Play()
    end

    local function OpenThemeDropdown()
        if KeybindDropdownOpen and CloseKeybindDropdown then
            CloseKeybindDropdown()
        end
        ThemeDropdownOpen = true
        ThemeDropdownTweenId += 1

        ThemeDropdown.BackgroundTransparency = 1
        ThemeDropdown.Position = UDim2.new(1, -8, 0, 128)
        ThemeDropdownContent.GroupTransparency = 1
        for _, Item in pairs(self.ThemeDropdownItems or {}) do
            Item.Button.BackgroundTransparency = Item.Selected and 0 or 1
            Item.Check.ImageTransparency = Item.Selected and 0 or 1
            Item.Label.TextTransparency = (Item.Selected or Item.Hovered) and 0 or 0.6
        end
        ThemeDropdown.Visible = true
        if self.SettingsStyle then
            TweenService:Create(self.SettingsStyle.Arrow, SettingsTweenInfo, {
                Rotation = 180,
            }):Play()
        end
        TweenThemeDropdown(true)

        TweenService:Create(ThemeDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            Position = UDim2.new(1, -8, 0, 132),
        }):Play()
    end

    CloseThemeDropdown = function()
        if not ThemeDropdownOpen then return end

        ThemeDropdownOpen = false
        ThemeDropdownTweenId += 1
        local TweenId = ThemeDropdownTweenId

        if self.SettingsStyle then
            TweenService:Create(self.SettingsStyle.Arrow, SettingsTweenInfo, {
                Rotation = 0,
            }):Play()
        end
        TweenThemeDropdown(false)
        TweenService:Create(ThemeDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -8, 0, 128),
        }):Play()

        task.delay(SettingsTweenInfo.Time, function()
            if ThemeDropdownTweenId == TweenId and not ThemeDropdownOpen then
                ThemeDropdown.Visible = false
            end
        end)
    end

    local function ToggleThemeDropdown()
        if ThemeDropdownOpen then
            CloseThemeDropdown()
        else
            OpenThemeDropdown()
        end
    end

    local function OpenKeybindDropdown()
        if not KeybindDropdown or not self.SettingsKeybind then return end
        if ThemeDropdownOpen then
            CloseThemeDropdown()
        end
        if VisibilityDropdownOpen then
            CloseVisibilityDropdown()
        end
        KeybindDropdownOpen = true
        KeybindDropdownTweenId += 1
        local Scale = self.MainScale.Scale
        local SettingsButton = self.SettingsKeybind.SettingsButton
        local MainPosition = self.Main.AbsolutePosition
        local KeybindListPosition = self.KeybindList.AbsolutePosition
        local ButtonPosition = SettingsButton.AbsolutePosition
        local ButtonSize = SettingsButton.AbsoluteSize
        local MenuX = (ButtonPosition.X - MainPosition.X + ButtonSize.X + 16 * Scale) / Scale
        local MenuY = (KeybindListPosition.Y - MainPosition.Y) / Scale
        KeybindDropdownBasePosition = UDim2.fromOffset(MenuX, MenuY)
        KeybindDropdown.BackgroundTransparency = 1
        KeybindDropdown.Position = KeybindDropdownBasePosition
        KeybindDropdownContent.GroupTransparency = 1
        KeybindDropdown.Visible = true
        TweenService:Create(self.SettingsKeybind.Arrow, SettingsTweenInfo, {
            Rotation = 180,
        }):Play()
        TweenService:Create(KeybindDropdownContent, SettingsTweenInfo, {
            GroupTransparency = 0,
        }):Play()
        TweenService:Create(KeybindDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(160, 106),
            Position = UDim2.fromOffset(MenuX, MenuY),
        }):Play()
    end

    CloseKeybindDropdown = function()
        if not KeybindDropdownOpen or not KeybindDropdown then return end
        KeybindDropdownOpen = false
        KeybindDropdownTweenId += 1
        local TweenId = KeybindDropdownTweenId
        TweenService:Create(self.SettingsKeybind.Arrow, SettingsTweenInfo, {
            Rotation = 0,
        }):Play()
        TweenService:Create(KeybindDropdownContent, SettingsTweenInfo, {
            GroupTransparency = 1,
        }):Play()
        TweenService:Create(KeybindDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(160, 0),
            Position = KeybindDropdownBasePosition or KeybindDropdown.Position,
        }):Play()
        task.delay(SettingsTweenInfo.Time, function()
            if KeybindDropdownTweenId == TweenId and not KeybindDropdownOpen then
                KeybindDropdown.Visible = false
            end
        end)
    end

    local function ToggleKeybindDropdown()
        if KeybindDropdownOpen then
            CloseKeybindDropdown()
        else
            OpenKeybindDropdown()
        end
    end

    local ListScaleDropdownOpen = false
    local ListScaleDropdownTweenId = 0
    local function OpenListScaleDropdown()
        if not self.SettingsKeybind or not self.SettingsKeybind.ListScaleDropdown then return end
        if VisibilityDropdownOpen then
            CloseVisibilityDropdown()
        end
        ListScaleDropdownOpen = true
        ListScaleDropdownTweenId += 1
        local Dropdown = self.SettingsKeybind.ListScaleDropdown
        local Content = self.SettingsKeybind.ListScaleDropdownContent
        local Scale = self.MainScale.Scale
        local KeybindMenuPosition = KeybindDropdown.AbsolutePosition
        local KeybindMenuSize = KeybindDropdown.AbsoluteSize
        local MenuX = KeybindMenuPosition.X + KeybindMenuSize.X + 8 * Scale
        local MenuY = KeybindMenuPosition.Y + 56 * Scale
        Dropdown.BackgroundTransparency = 1
        Dropdown.Position = UDim2.fromOffset(MenuX, MenuY)
        Content.GroupTransparency = 1
        Dropdown.Visible = true
        TweenService:Create(self.SettingsKeybind.ListScaleArrow, SettingsTweenInfo, {
            Rotation = 180,
        }):Play()
        TweenService:Create(Content, SettingsTweenInfo, {GroupTransparency = 0}):Play()
        TweenService:Create(Dropdown, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(160 * Scale, 182 * Scale),
            Position = UDim2.fromOffset(MenuX, MenuY),
        }):Play()
    end

    local function CloseListScaleDropdown()
        if not ListScaleDropdownOpen or not self.SettingsKeybind then return end
        ListScaleDropdownOpen = false
        ListScaleDropdownTweenId += 1
        local TweenId = ListScaleDropdownTweenId
        local Dropdown = self.SettingsKeybind.ListScaleDropdown
        local Content = self.SettingsKeybind.ListScaleDropdownContent
        TweenService:Create(self.SettingsKeybind.ListScaleArrow, SettingsTweenInfo, {
            Rotation = 0,
        }):Play()
        TweenService:Create(Content, SettingsTweenInfo, {GroupTransparency = 1}):Play()
        TweenService:Create(Dropdown, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(Dropdown.AbsoluteSize.X, 0),
        }):Play()
        task.delay(SettingsTweenInfo.Time, function()
            if ListScaleDropdownTweenId == TweenId and not ListScaleDropdownOpen then
                Dropdown.Visible = false
            end
        end)
    end

    local function ToggleListScaleDropdown()
        if ListScaleDropdownOpen then
            CloseListScaleDropdown()
        else
            OpenListScaleDropdown()
        end
    end

    local function OpenVisibilityDropdown()
        if not VisibilityDropdown then return end
        if ListScaleDropdownOpen then
            CloseListScaleDropdown()
        end
        VisibilityDropdownOpen = true
        VisibilityDropdownTweenId += 1
        local Scale = self.MainScale.Scale
        local ParentPosition = KeybindDropdown.AbsolutePosition
        local ParentSize = KeybindDropdown.AbsoluteSize
        local MenuX = ParentPosition.X + ParentSize.X + 8 * Scale
        local MenuY = ParentPosition.Y + 94 * Scale
        VisibilityDropdown.BackgroundTransparency = 1
        VisibilityDropdown.Position = UDim2.fromOffset(MenuX, MenuY)
        VisibilityDropdownContent.GroupTransparency = 1
        VisibilityDropdown.Visible = true
        TweenService:Create(VisibilityDropdownContent, SettingsTweenInfo, {
            GroupTransparency = 0,
        }):Play()
        TweenService:Create(VisibilityDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            Size = UDim2.fromOffset(160 * Scale, 76 * Scale),
            Position = UDim2.fromOffset(MenuX, MenuY),
        }):Play()
    end

    CloseVisibilityDropdown = function()
        if not VisibilityDropdownOpen or not VisibilityDropdown then return end
        VisibilityDropdownOpen = false
        VisibilityDropdownTweenId += 1
        local TweenId = VisibilityDropdownTweenId
        TweenService:Create(VisibilityDropdownContent, SettingsTweenInfo, {
            GroupTransparency = 1,
        }):Play()
        TweenService:Create(VisibilityDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(VisibilityDropdown.AbsoluteSize.X, 0),
        }):Play()
        task.delay(SettingsTweenInfo.Time, function()
            if VisibilityDropdownTweenId == TweenId and not VisibilityDropdownOpen then
                VisibilityDropdown.Visible = false
            end
        end)
    end

    local function ToggleVisibilityDropdown()
        if VisibilityDropdownOpen then
            CloseVisibilityDropdown()
        else
            OpenVisibilityDropdown()
        end
    end

    local function SetCategoryItemState(Item, Selected, Instant)
        local TweenInfoValue = Instant and TweenInfo.new(0) or ThemeHoverTweenInfo
        TweenService:Create(Item.Button, TweenInfoValue, {
            BackgroundTransparency = Selected and 0 or 1,
            BackgroundColor3 = self.Theme.Settings.SelectedBackground,
        }):Play()
        TweenService:Create(Item.Check, TweenInfoValue, {
            Position = UDim2.fromOffset(Selected and 9 or 5, 7),
            ImageTransparency = Selected and 0 or 1,
            ImageColor3 = self.Theme.Accent,
        }):Play()
        TweenService:Create(Item.Label, TweenInfoValue, {
            Position = UDim2.fromOffset(Selected and 33 or 5, 0),
            TextTransparency = Selected and 0 or 0.6,
            TextColor3 = self.Theme.Settings.Text,
        }):Play()
        Item.Selected = Selected
    end

    local function TweenCategoryDropdown(Opening)
        if not CategoryDropdownContent then return end

        if Opening then
            for _, Item in pairs(CategoryDropdownItems) do
                SetCategoryItemState(Item, Item.Selected, true)
            end
        end

        CategoryDropdownContent.GroupTransparency = Opening and 1 or 0
        TweenService:Create(CategoryDropdownContent, SettingsTweenInfo, {
            GroupTransparency = Opening and 0 or 1,
        }):Play()
    end

    local function OpenCategoryDropdown()
        if not CategoryButton.Visible or #CategoryDropdownItems == 0 then return end

        CategoryDropdownOpen = true
        CategoryDropdownTweenId += 1
        CategoryDropdown.BackgroundTransparency = 1
        CategoryDropdown.Position = UDim2.fromOffset(NavigationType == 2 and 64 or 284, 58)
        CategoryDropdownContent.GroupTransparency = 1
        CategoryDimmer.BackgroundTransparency = 1
        CategoryDimmer.Visible = true
        CategoryOverlay.Visible = true
        CategoryDropdown.Visible = true

        TweenService:Create(CategoryDimmer, SettingsTweenInfo, {
            BackgroundTransparency = 0.75,
        }):Play()
        TweenService:Create(CategoryArrow, SettingsTweenInfo, {
            Rotation = 180,
        }):Play()
        TweenCategoryDropdown(true)
        TweenService:Create(CategoryDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            Position = UDim2.fromOffset(NavigationType == 2 and 64 or 284, 62),
        }):Play()
    end

    CloseCategoryDropdown = function()
        if not CategoryDropdownOpen then return end

        CategoryDropdownOpen = false
        CategoryDropdownTweenId += 1
        local TweenId = CategoryDropdownTweenId

        TweenService:Create(CategoryArrow, SettingsTweenInfo, {
            Rotation = 0,
        }):Play()
        TweenCategoryDropdown(false)
        TweenService:Create(CategoryDropdown, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(NavigationType == 2 and 64 or 284, 58),
        }):Play()
        TweenService:Create(CategoryDimmer, SettingsTweenInfo, {
            BackgroundTransparency = 1,
        }):Play()

        task.delay(SettingsTweenInfo.Time, function()
            if CategoryDropdownTweenId == TweenId and not CategoryDropdownOpen then
                CategoryDropdown.Visible = false
                CategoryDimmer.Visible = false
                CategoryOverlay.Visible = false
            end
        end)
    end

    local function ToggleCategoryDropdown()
        if CategoryDropdownOpen then
            CloseCategoryDropdown()
        else
            OpenCategoryDropdown()
        end
    end

    local function IsInside(Object, Point)
        if not Object or not Object.Visible then return false end

        local Position = Object.AbsolutePosition
        local Size = Object.AbsoluteSize
        return Point.X >= Position.X
            and Point.X <= Position.X + Size.X
            and Point.Y >= Position.Y
            and Point.Y <= Position.Y + Size.Y
    end

    local function CloseSettings()
        if not SettingsOpen then return end

        SettingsOpen = false
        SettingsTweenId += 1
        local TweenId = SettingsTweenId

        CloseThemeDropdown()
        if CloseKeybindDropdown then
            CloseKeybindDropdown()
        end
        CloseListScaleDropdown()
        CloseVisibilityDropdown()
        TweenSettingsProfile(false)
        TweenService:Create(SettingsDimmer, SettingsTweenInfo, {
            BackgroundTransparency = 1,
        }):Play()
        TweenService:Create(SettingsMenu, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -16, 0, 58),
        }):Play()

        task.delay(SettingsTweenInfo.Time, function()
            if SettingsTweenId == TweenId and not SettingsOpen then
                SettingsDimmer.Visible = false
                SettingsOverlay.Visible = false
                SettingsMenu.Visible = false
            end
        end)
    end

    local function OpenSettings()
        SettingsOpen = true
        SettingsTweenId += 1

        SettingsDimmer.Visible = true
        SettingsOverlay.Visible = true
        SettingsMenu.Visible = true
        SettingsDimmer.BackgroundTransparency = 1
        SettingsMenu.BackgroundTransparency = 1
        SettingsMenu.Position = UDim2.new(1, -16, 0, 58)
        TweenSettingsProfile(true)

        TweenService:Create(SettingsDimmer, SettingsTweenInfo, {
            BackgroundTransparency = 0.75,
        }):Play()
        TweenService:Create(SettingsMenu, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            Position = UDim2.new(1, -16, 0, 62),
        }):Play()
    end

    local function ToggleSettings()
        if SettingsOpen then
            CloseSettings()
        else
            OpenSettings()
        end
    end

    SettingsDimmer = UI.Create("Frame", {
        Name = "SettingsDimmer",
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 40,
    }, Main)
    UI.Corner(SettingsDimmer, 14)

    SettingsOverlay = UI.Create("TextButton", {
        Name = "SettingsOverlay",
        Active = true,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        Visible = false,
        ZIndex = 41,
    }, Main)
    UI.Corner(SettingsOverlay, 14)

    SettingsMenu = UI.Create("Frame", {
        Name = "SettingsMenu",
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = self.Theme.Settings.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, -16, 0, 58),
        Size = UDim2.fromOffset(220, 0),
        Visible = false,
        ZIndex = 50,
    }, Main)
    UI.Corner(SettingsMenu, 10)
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
    }, SettingsMenu)

    local ProfileContent = UI.Create("Frame", {
        Name = "Profile",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 44),
    }, SettingsMenu)

    local ProfileAvatar = UI.Create("ImageLabel", {
        Name = "Avatar",
        BackgroundColor3 = self.Theme.Surface.Background,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(44, 44),
        Image = "",
        ImageTransparency = 1,
        ScaleType = Enum.ScaleType.Crop,
    }, ProfileContent)
    UI.Corner(ProfileAvatar, 100)

    local ProfilePlayer = Players.LocalPlayer or GetLocalPlayer()
    local ProfileDisplayName = UI.Create("TextLabel", {
        Name = "DisplayName",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(56, 1),
        Size = UDim2.new(1, -56, 0, 21),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = ProfilePlayer.DisplayName,
        TextColor3 = self.Theme.Settings.Text,
        TextSize = 14,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, ProfileContent)

    UI.Create("TextLabel", {
        Name = "Username",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(56, 20),
        Size = UDim2.new(1, -56, 0, 18),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "@" .. ProfilePlayer.Name,
        TextColor3 = self.Theme.Settings.Username,
        TextSize = 12,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, ProfileContent)

    local ProfileDivider = UI.Create("Frame", {
        Name = "Divider",
        BackgroundColor3 = self.Theme.Settings.Divider,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 58),
        Size = UDim2.new(1, 0, 0, 1),
    }, SettingsMenu)

    local StyleButton = UI.Create("TextButton", {
        Name = "Style",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 70),
        Size = UDim2.new(1, 0, 0, 34),
        Text = "",
    }, SettingsMenu)

    local StyleIcon = UI.Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(4, 8),
        Size = UDim2.fromOffset(17, 17),
        Image = GetIcon("palette"),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
    }, StyleButton)

    local StyleArrow = UI.Create("ImageLabel", {
        Name = "Arrow",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -4, 0, 9),
        Size = UDim2.fromOffset(16, 16),
        Image = GetIcon("chevron-right"),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
    }, StyleButton)

    local StyleLabel = UI.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(29, 8),
        Size = UDim2.new(1, -55, 0, 17),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "Style",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, StyleButton)

    local KeybindButton = UI.Create("TextButton", {
        Name = "KeybindList",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 108),
        Size = UDim2.new(1, 0, 0, 34),
        Text = "",
    }, SettingsMenu)

    local KeybindIcon = UI.Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(4, 8),
        Size = UDim2.fromOffset(17, 17),
        Image = GetIcon("keyboard") or GetIcon("key"),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
        Visible = true,
    }, KeybindButton)

    local KeybindArrow = UI.Create("ImageLabel", {
        Name = "Arrow",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -4, 0, 9),
        Size = UDim2.fromOffset(16, 16),
        Image = GetIcon("chevron-right"),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
        Visible = false,
    }, KeybindButton)

    local KeybindLabel = UI.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(29, 8),
        Size = UDim2.new(1, -55, 0, 17),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "Keybind List",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, KeybindButton)

    local KeybindSettingsButton = UI.Create("ImageButton", {
        Name = "Settings",
        Active = true,
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = FallbackIcons.settings or GetIcon("settings"),
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ImageTransparency = 1,
        Position = UDim2.new(1, -20, 0, 8),
        Size = UDim2.fromOffset(18, 18),
    }, KeybindButton)

    KeybindDropdown = UI.Create("Frame", {
        Name = "KeybindDropdown",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Settings.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, -8, 0, 166),
        Size = UDim2.fromOffset(160, 0),
        Visible = false,
        ZIndex = 55,
    }, Main)
    UI.Corner(KeybindDropdown, 10)
    KeybindDropdownContent = UI.Create("CanvasGroup", {
        Name = "Content",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 56,
    }, KeybindDropdown)
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, KeybindDropdownContent)
    UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, KeybindDropdownContent)

    local KeybindToggleButton = UI.Create("TextButton", {
        Name = "Toggle",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        Visible = false,
        ZIndex = 56,
    }, KeybindDropdownContent)
    local KeybindToggleLabel = UI.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(29, 0),
        Size = UDim2.new(1, -45, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "Show list",
        TextColor3 = self.Theme.Settings.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 57,
    }, KeybindToggleButton)
    local KeybindToggle = UI.Create("Frame", {
        Name = "Switch",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(30, 17),
        Visible = false,
        ZIndex = 57,
    }, KeybindToggleButton)
    UI.Corner(KeybindToggle, 9)
    local KeybindToggleKnob = UI.Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(1, -3, 0.5, 0),
        Size = UDim2.fromOffset(11, 11),
        Visible = false,
        ZIndex = 58,
    }, KeybindToggle)
    UI.Corner(KeybindToggleKnob, 6)

    local KeybindCheckbox = UI.Create("Frame", {
        Name = "Checkbox",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = self.Theme.Groups.ToggleBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 57,
    }, KeybindToggleButton)
    UI.Corner(KeybindCheckbox, 5)
    KeybindCheckbox.Parent = KeybindButton
    local KeybindCheckboxCheck = UI.Create("ImageLabel", {
        Name = "Check",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = GetIcon("check"),
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        ZIndex = 58,
    }, KeybindCheckbox)
    self.KeybindListEnabled = false
    self.SettingsListScale = 100

    local ListScaleButton = UI.Create("TextButton", {
        Name = "ListScale",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        ZIndex = 56,
    }, KeybindDropdownContent)
    local ListScaleLabel = UI.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -45, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "List Scale",
        TextColor3 = self.Theme.Settings.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 57,
    }, ListScaleButton)
    local ListScaleValue = UI.Create("TextLabel", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -22, 0, 0),
        Size = UDim2.fromOffset(38, 30),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "100%",
        TextColor3 = self.Theme.Settings.Text,
        TextSize = 13,
        TextTransparency = 0.6,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Visible = false,
        ZIndex = 57,
    }, ListScaleButton)
    local ListScaleArrow = UI.Create("ImageLabel", {
        Name = "Arrow",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Image = GetIcon("chevron-right"),
        ImageColor3 = self.Theme.Settings.Text,
        ImageTransparency = 0.6,
        ZIndex = 57,
    }, ListScaleButton)

    local VisibilityButton = UI.Create("TextButton", {
        Name = "Visibility",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        ZIndex = 56,
    }, KeybindDropdownContent)
    local VisibilityLabel = UI.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -20, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "Visibility",
        TextColor3 = self.Theme.Settings.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 57,
    }, VisibilityButton)
    local VisibilityArrow = UI.Create("ImageLabel", {
        Name = "Arrow",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        Image = GetIcon("chevron-right"),
        ImageColor3 = self.Theme.Settings.Text,
        ImageTransparency = 0.6,
        ZIndex = 57,
    }, VisibilityButton)

    local BoundOnlyButton = UI.Create("TextButton", {
        Name = "BoundOnly",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 30),
        Text = "",
        ZIndex = 56,
    }, KeybindDropdownContent)
    local BoundOnlyLabel = UI.Create("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.new(1, -28, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        Text = "Bound keys only",
        TextColor3 = self.Theme.Settings.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 57,
    }, BoundOnlyButton)
    local BoundOnlyCheckbox = UI.Create("Frame", {
        Name = "Checkbox",
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(1, 0, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        ZIndex = 57,
    }, BoundOnlyButton)
    UI.Corner(BoundOnlyCheckbox, 5)
    local BoundOnlyCheck = UI.Create("ImageLabel", {
        Name = "Check",
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = GetIcon("check"),
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        ZIndex = 58,
    }, BoundOnlyCheckbox)

    local ListScaleDropdown = UI.Create("Frame", {
        Name = "ListScaleDropdown",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Settings.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, 156, 0, 174),
        Size = UDim2.fromOffset(160, 0),
        Visible = false,
        ZIndex = 1000,
    }, Main)
    ListScaleDropdown.Parent = Screen
    UI.Corner(ListScaleDropdown, 10)

    VisibilityDropdown = UI.Create("Frame", {
        Name = "VisibilityDropdown",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Settings.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.fromOffset(0, 0),
        Size = UDim2.fromOffset(160, 0),
        Visible = false,
        ZIndex = 1000,
    }, Screen)
    UI.Corner(VisibilityDropdown, 10)
    VisibilityDropdownContent = UI.Create("CanvasGroup", {
        Name = "Content",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 1001,
    }, VisibilityDropdown)
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, VisibilityDropdownContent)
    UI.Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, VisibilityDropdownContent)
    local ListScaleDropdownContent = UI.Create("CanvasGroup", {
        Name = "Content",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 1001,
    }, ListScaleDropdown)
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, ListScaleDropdownContent)
    UI.Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, ListScaleDropdownContent)

    self.SettingsKeybind = {
        Button = KeybindButton,
        Icon = KeybindIcon,
        SettingsButton = KeybindSettingsButton,
        Arrow = KeybindArrow,
        Label = KeybindLabel,
        Dropdown = KeybindDropdown,
        Toggle = KeybindToggle,
        ToggleKnob = KeybindToggleKnob,
        Checkbox = KeybindCheckbox,
        CheckboxCheck = KeybindCheckboxCheck,
        ToggleLabel = KeybindToggleLabel,
        ListScaleButton = ListScaleButton,
        ListScaleLabel = ListScaleLabel,
        ListScaleValue = ListScaleValue,
        ListScaleArrow = ListScaleArrow,
        ListScaleDropdown = ListScaleDropdown,
        ListScaleDropdownContent = ListScaleDropdownContent,
        VisibilityButton = VisibilityButton,
        VisibilityLabel = VisibilityLabel,
        VisibilityArrow = VisibilityArrow,
        VisibilityDropdown = VisibilityDropdown,
        VisibilityDropdownContent = VisibilityDropdownContent,
        BoundOnlyButton = BoundOnlyButton,
        BoundOnlyLabel = BoundOnlyLabel,
        BoundOnlyCheckbox = BoundOnlyCheckbox,
        BoundOnlyCheck = BoundOnlyCheck,
    }

    self.SettingsListScaleItems = {}
    local ListScaleOptions = {70, 80, 90, 100, 110}
    for Index, ScaleValue in ipairs(ListScaleOptions) do
        local Selected = ScaleValue == self.SettingsListScale
        local ScaleButton = UI.Create("TextButton", {
            Name = tostring(ScaleValue),
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Settings.SelectedBackground,
            BackgroundTransparency = Selected and 0 or 1,
            BorderSizePixel = 0,
            LayoutOrder = Index,
            Size = UDim2.new(1, 0, 0, 30),
            Text = "",
            ZIndex = 1002,
        }, ListScaleDropdownContent)
        UI.Corner(ScaleButton, 7)
        local ScaleCheck = UI.Create("ImageLabel", {
            Name = "Check",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Selected and 9 or 5, 7),
            Size = UDim2.fromOffset(17, 17),
            Image = GetIcon("check"),
            ImageColor3 = self.Theme.Accent,
            ImageTransparency = Selected and 0 or 1,
            ZIndex = 1003,
        }, ScaleButton)
        local ScaleLabel = UI.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Selected and 33 or 5, 0),
            Size = UDim2.new(1, -29, 1, 0),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = tostring(ScaleValue) .. "%",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextTransparency = Selected and 0 or 0.6,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 1003,
        }, ScaleButton)
        local ScaleItem = {
            Button = ScaleButton,
            Check = ScaleCheck,
            Label = ScaleLabel,
            Value = ScaleValue,
            Selected = Selected,
            Hovered = false,
        }
        self.SettingsListScaleItems[ScaleValue] = ScaleItem

        ScaleButton.MouseEnter:Connect(function()
            ScaleItem.Hovered = true
            TweenService:Create(ScaleItem.Label, ThemeHoverTweenInfo, {TextTransparency = 0}):Play()
        end)
        ScaleButton.MouseLeave:Connect(function()
            ScaleItem.Hovered = false
            TweenService:Create(ScaleItem.Label, ThemeHoverTweenInfo, {
                TextTransparency = ScaleItem.Selected and 0 or 0.6,
            }):Play()
        end)
        ScaleButton.Activated:Connect(function()
            self.SettingsListScale = ScaleValue
            if self.KeybindListScale then
                TweenService:Create(self.KeybindListScale, SettingsTweenInfo, {
                    Scale = (ScaleValue / 100) * 1.1,
                }):Play()
            end
            ListScaleValue.Text = tostring(ScaleValue) .. "%"
            for OtherValue, OtherItem in pairs(self.SettingsListScaleItems) do
                local IsSelected = OtherValue == ScaleValue
                OtherItem.Selected = IsSelected
                TweenService:Create(OtherItem.Button, ThemeSelectionTweenInfo, {
                    BackgroundTransparency = IsSelected and 0 or 1,
                    BackgroundColor3 = self.Theme.Settings.SelectedBackground,
                }):Play()
                TweenService:Create(OtherItem.Check, ThemeSelectionTweenInfo, {
                    Position = UDim2.fromOffset(IsSelected and 9 or 5, 7),
                    ImageTransparency = IsSelected and 0 or 1,
                    ImageColor3 = self.Theme.Accent,
                }):Play()
                TweenService:Create(OtherItem.Label, ThemeSelectionTweenInfo, {
                    Position = UDim2.fromOffset(IsSelected and 33 or 5, 0),
                    TextTransparency = (IsSelected or OtherItem.Hovered) and 0 or 0.6,
                    TextColor3 = self.Theme.Settings.Text,
                }):Play()
            end
        end)
    end

    self.SettingsVisibilityItems = {}
    local VisibilityOptions = {"With menu", "Always"}
    for Index, VisibilityName in ipairs(VisibilityOptions) do
        local Selected = VisibilityName == self.KeybindListVisibility
        local VisibilityButtonItem = UI.Create("TextButton", {
            Name = VisibilityName:gsub("%s+", ""),
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Settings.SelectedBackground,
            BackgroundTransparency = Selected and 0 or 1,
            BorderSizePixel = 0,
            LayoutOrder = Index,
            Size = UDim2.new(1, 0, 0, 30),
            Text = "",
            ZIndex = 1002,
        }, VisibilityDropdownContent)
        UI.Corner(VisibilityButtonItem, 7)
        local VisibilityCheck = UI.Create("ImageLabel", {
            Name = "Check",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Selected and 9 or 5, 7),
            Size = UDim2.fromOffset(17, 17),
            Image = GetIcon("check"),
            ImageColor3 = self.Theme.Accent,
            ImageTransparency = Selected and 0 or 1,
            ZIndex = 1003,
        }, VisibilityButtonItem)
        local VisibilityItemLabel = UI.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Selected and 33 or 5, 0),
            Size = UDim2.new(1, -29, 1, 0),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = VisibilityName,
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextTransparency = Selected and 0 or 0.6,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 1003,
        }, VisibilityButtonItem)
        local VisibilityItem = {
            Button = VisibilityButtonItem,
            Check = VisibilityCheck,
            Label = VisibilityItemLabel,
            Selected = Selected,
            Hovered = false,
        }
        self.SettingsVisibilityItems[VisibilityName] = VisibilityItem
        VisibilityButtonItem.MouseEnter:Connect(function()
            VisibilityItem.Hovered = true
            TweenService:Create(VisibilityItemLabel, ThemeHoverTweenInfo, {TextTransparency = 0}):Play()
        end)
        VisibilityButtonItem.MouseLeave:Connect(function()
            VisibilityItem.Hovered = false
            TweenService:Create(VisibilityItemLabel, ThemeHoverTweenInfo, {
                TextTransparency = VisibilityItem.Selected and 0 or 0.6,
            }):Play()
        end)
        VisibilityButtonItem.Activated:Connect(function()
            self.KeybindListVisibility = VisibilityName
            for OtherName, OtherItem in pairs(self.SettingsVisibilityItems) do
                local IsSelected = OtherName == VisibilityName
                OtherItem.Selected = IsSelected
                TweenService:Create(OtherItem.Button, ThemeSelectionTweenInfo, {
                    BackgroundTransparency = IsSelected and 0 or 1,
                    BackgroundColor3 = self.Theme.Settings.SelectedBackground,
                }):Play()
                TweenService:Create(OtherItem.Check, ThemeSelectionTweenInfo, {
                    Position = UDim2.fromOffset(IsSelected and 9 or 5, 7),
                    ImageTransparency = IsSelected and 0 or 1,
                    ImageColor3 = self.Theme.Accent,
                }):Play()
                TweenService:Create(OtherItem.Label, ThemeSelectionTweenInfo, {
                    Position = UDim2.fromOffset(IsSelected and 33 or 5, 0),
                    TextTransparency = (IsSelected or OtherItem.Hovered) and 0 or 0.6,
                    TextColor3 = self.Theme.Settings.Text,
                }):Play()
            end
            if self.KeybindList then
                self.KeybindList.Visible = self.KeybindListEnabled and (self.KeybindListVisibility == "Always" or self.GuiVisible)
            end
        end)
    end

    local KeybindList = UI.Create("Frame", {
        Name = "KeybindList",
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme.Settings.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(0, 16, 0.5, 0),
        Size = UDim2.fromOffset(360, 0),
        Visible = false,
        ZIndex = 80,
    }, Screen)
    UI.Corner(KeybindList, 10)
    UI.Create("UIShadow", {
        BlurRadius = UDim.new(0, 12),
        Color = Color3.new(0, 0, 0),
        Transparency = 0.55,
        Offset = UDim2.fromOffset(0, 2),
        Spread = UDim2.fromOffset(3, 3),
        ZIndex = -1,
    }, KeybindList)
    local KeybindListScale = UI.Create("UIScale", {
        Scale = (self.SettingsListScale / 100) * 1.1,
    }, KeybindList)
    local KeybindListHeader = UI.Create("Frame", {
        Name = "Header",
        Active = true,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        Size = UDim2.new(1, 0, 0, 34),
    }, KeybindList)
    KeybindSettingsButton.Parent = KeybindListHeader
    KeybindSettingsButton.AnchorPoint = Vector2.new(1, 0.5)
    KeybindSettingsButton.Position = UDim2.new(1, -12, 0.5, 0)
    KeybindSettingsButton.ImageTransparency = 0.6
    KeybindSettingsButton.ZIndex = 82
    UI.Create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(12, 9),
        Size = UDim2.fromOffset(16, 16),
        Image = GetIcon("keyboard") or GetIcon("key"),
        ImageColor3 = self.Theme.Accent,
    }, KeybindListHeader)
    local KeybindListTitle = UI.Create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(36, 0),
        Size = UDim2.new(1, -48, 1, 0),
        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        Text = "Keybind List",
        TextColor3 = self.Theme.Settings.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, KeybindListHeader)
    local KeybindListDivider = UI.Create("Frame", {
        Name = "Divider",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        Size = UDim2.new(1, 0, 0, 1),
    }, KeybindList)
    local KeybindListDividerLine = UI.Create("Frame", {
        Name = "Line",
        BackgroundColor3 = self.Theme.Groups.Divider,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -20, 0, 1),
    }, KeybindListDivider)
    local KeybindListColumns = UI.Create("Frame", {
        Name = "Columns",
        BackgroundColor3 = self.Theme.Surface.Background,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        Size = UDim2.new(1, 0, 0, 24),
    }, KeybindList)
    local KeybindListRows = UI.Create("Frame", {
        Name = "Rows",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        LayoutOrder = 4,
        Size = UDim2.new(1, 0, 0, 0),
    }, KeybindList)
    UI.Corner(KeybindListRows, 10)
    local KeybindListLayout = UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, KeybindList)
    UI.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, KeybindListRows)

    local function CreateKeybindListColumn(Text, Position, Width)
        return UI.Create("TextLabel", {
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Position, 0),
            Size = UDim2.fromOffset(Width, 24),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = Text,
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 12,
            TextTransparency = 0.55,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, KeybindListColumns)
    end
    local KeybindListFunctionColumn = CreateKeybindListColumn("Function", 10, 130)
    local KeybindListHotkeyColumn = CreateKeybindListColumn("Hotkey", 140, 100)
    local KeybindListStatusColumn = CreateKeybindListColumn("Status", 270, 70)

    local function GetKeybindText(Item)
        if not Item.BoundInput then return "—" end
        if typeof(Item.BoundInput) == "EnumItem" then
            return Item.BoundInput.Name:gsub("MouseButton", "Mouse ")
        end
        return tostring(Item.BoundInput)
    end

    local function ResizeKeybindList(Animate)
        task.defer(function()
            local Scale = math.max(KeybindListScale.Scale, 0.1)
            local TargetHeight = KeybindListLayout.AbsoluteContentSize.Y / Scale
            KeybindList.AutomaticSize = Enum.AutomaticSize.None
            local TargetSize = UDim2.fromOffset(360, TargetHeight)
            if Animate then
                TweenService:Create(KeybindList, TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                    Size = TargetSize,
                }):Play()
            else
                KeybindList.Size = TargetSize
            end
        end)
    end

    local function UpdateKeybindList(Animate)
        for _, Child in ipairs(KeybindListRows:GetChildren()) do
            if not Child:IsA("UIListLayout") then
                Child:Destroy()
            end
        end

        local RowIndex = 0
        local LastRow
        for _, Item in ipairs(self.KeybindItems) do
            if not self.ShowBoundKeysOnly or Item.BoundInput then
                RowIndex += 1
                local Row = UI.Create("Frame", {
                Name = Item.Name or ("Keybind" .. RowIndex),
                BackgroundColor3 = Item.Value
                    and self.Theme.Settings.SelectedBackground
                    or (RowIndex % 2 == 0 and self.Theme.Surface.Background or self.Theme.Groups.Background),
                BorderSizePixel = 0,
                LayoutOrder = RowIndex,
                Size = UDim2.new(1, 0, 0, 32),
            }, KeybindListRows)
                LastRow = Row
                local FunctionLabel = UI.Create("TextLabel", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(10, 0),
                Size = UDim2.fromOffset(130, 32),
                FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Text = (Item.Name or "Toggle"):gsub("^Enable%s+", ""),
                TextColor3 = self.Theme.Settings.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
            }, Row)
                local HotkeyLabel = UI.Create("TextLabel", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(140, 0),
                Size = UDim2.fromOffset(100, 32),
                FontFace = FunctionLabel.FontFace,
                Text = GetKeybindText(Item),
                TextColor3 = self.Theme.Settings.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
            }, Row)
                local StatusLabel = UI.Create("TextLabel", {
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.fromOffset(270, 0),
                Size = UDim2.fromOffset(62, 32),
                FontFace = FunctionLabel.FontFace,
                Text = Item.Value and "On" or "Off",
                TextColor3 = Item.Value and self.Theme.Accent or self.Theme.Settings.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextYAlignment = Enum.TextYAlignment.Center,
            }, Row)
            end
        end
        if LastRow then
            LastRow.ClipsDescendants = true
            UI.Corner(LastRow, 10)
        end
        ResizeKeybindList(Animate)
    end

    self.KeybindList = KeybindList
    self.KeybindListScale = KeybindListScale
    self.UpdateKeybindList = UpdateKeybindList
    self.KeybindListRows = KeybindListRows
    self.KeybindListTitle = KeybindListTitle
    self.KeybindListColumns = KeybindListColumns
    self.KeybindListFunctionColumn = KeybindListFunctionColumn
    self.KeybindListHotkeyColumn = KeybindListHotkeyColumn
    self.KeybindListStatusColumn = KeybindListStatusColumn
    self.KeybindListDivider = KeybindListDivider
    self.KeybindListDividerLine = KeybindListDividerLine
    local KeybindListDragging = false
    local KeybindListDragStart
    local KeybindListStartPosition
    local KeybindListTargetPosition = KeybindList.Position

    KeybindListHeader.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        KeybindListDragging = true
        KeybindListDragStart = Input.Position
        KeybindListStartPosition = KeybindListTargetPosition
    end)
    table.insert(DragConnections, UserInputService.InputChanged:Connect(function(Input)
        if not KeybindListDragging then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseMovement
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local Delta = Input.Position - KeybindListDragStart
        KeybindListTargetPosition = UDim2.new(
            KeybindListStartPosition.X.Scale,
            KeybindListStartPosition.X.Offset + Delta.X,
            KeybindListStartPosition.Y.Scale,
            KeybindListStartPosition.Y.Offset + Delta.Y
        )
    end))
    table.insert(DragConnections, UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1
            or Input.UserInputType == Enum.UserInputType.Touch then
            KeybindListDragging = false
        end
    end))
    table.insert(DragConnections, RunService.RenderStepped:Connect(function(DeltaTime)
        local Alpha = math.clamp(DeltaTime * 14, 0, 1)
        KeybindList.Position = KeybindList.Position:Lerp(KeybindListTargetPosition, Alpha)
    end))
    local KeybindListRefreshElapsed = 0
    table.insert(DragConnections, RunService.RenderStepped:Connect(function(DeltaTime)
        if not KeybindList.Visible then return end
        KeybindListRefreshElapsed += DeltaTime
        if KeybindListRefreshElapsed >= 0.2 then
            KeybindListRefreshElapsed = 0
            UpdateKeybindList()
        end
    end))

    ThemeDropdown = UI.Create("Frame", {
        Name = "ThemeDropdown",
        AutomaticSize = Enum.AutomaticSize.Y,
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = self.Theme.Settings.Background,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Position = UDim2.new(1, -8, 0, 128),
        Size = UDim2.fromOffset(160, 0),
        Visible = false,
        ZIndex = 55,
    }, Main)
    UI.Corner(ThemeDropdown, 10)
    ThemeDropdownContent = UI.Create("CanvasGroup", {
        Name = "Content",
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        GroupTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        ZIndex = 56,
    }, ThemeDropdown)
    UI.Create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
    }, ThemeDropdownContent)
    UI.Create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, ThemeDropdownContent)

    self.ThemeDropdownItems = {}
    for Index, ThemeName in ipairs({"Dark", "Crimson", "Emerald"}) do
        local Selected = self.ThemeName == ThemeName
        local ThemeButton = UI.Create("TextButton", {
            Name = ThemeName,
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Settings.SelectedBackground,
            BackgroundTransparency = Selected and 0 or 1,
            BorderSizePixel = 0,
            LayoutOrder = Index,
            Size = UDim2.new(1, 0, 0, 30),
            Text = "",
            ZIndex = 56,
        }, ThemeDropdownContent)

        local ThemeCheck = UI.Create("ImageLabel", {
            Name = "Check",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Selected and 9 or 5, 7),
            Size = UDim2.fromOffset(17, 17),
            Image = GetIcon("check"),
            ImageColor3 = self.Theme.Accent,
            ImageTransparency = Selected and 0 or 1,
            ZIndex = 57,
        }, ThemeButton)
        UI.Corner(ThemeButton, 7)

        local ThemeLabel = UI.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(Selected and 33 or 5, 0),
            Size = UDim2.new(1, -29, 1, 0),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = ThemeName,
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextTransparency = Selected and 0 or 0.6,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 57,
        }, ThemeButton)

        local Item = {
            Button = ThemeButton,
            Check = ThemeCheck,
            Label = ThemeLabel,
            Name = ThemeName,
            Selected = Selected,
            Hovered = false,
        }
        self.ThemeDropdownItems[ThemeName] = Item

        ThemeButton.MouseEnter:Connect(function()
            Item.Hovered = true
            TweenService:Create(Item.Label, ThemeHoverTweenInfo, {
                TextTransparency = 0,
            }):Play()
        end)

        ThemeButton.MouseLeave:Connect(function()
            Item.Hovered = false
            TweenService:Create(Item.Label, ThemeHoverTweenInfo, {
                TextTransparency = Item.Selected and 0 or 0.6,
            }):Play()
        end)

        ThemeButton.Activated:Connect(function()
            self:SetTheme(ThemeName)
            for OtherName, OtherItem in pairs(self.ThemeDropdownItems) do
                local IsSelected = OtherName == ThemeName
                local WasSelected = OtherItem.Selected
                OtherItem.Button.BackgroundTransparency = WasSelected and 0 or 1
                OtherItem.Check.Position = UDim2.fromOffset(WasSelected and 9 or 5, 7)
                OtherItem.Check.ImageTransparency = WasSelected and 0 or 1
                OtherItem.Label.Position = UDim2.fromOffset(WasSelected and 33 or 5, 0)
                OtherItem.Label.TextTransparency = (WasSelected or OtherItem.Hovered) and 0 or 0.6

                TweenService:Create(OtherItem.Button, ThemeSelectionTweenInfo, {
                    BackgroundTransparency = IsSelected and 0 or 1,
                    BackgroundColor3 = self.Theme.Settings.SelectedBackground,
                }):Play()
                TweenService:Create(OtherItem.Check, ThemeSelectionTweenInfo, {
                    Position = UDim2.fromOffset(IsSelected and 9 or 5, 7),
                    ImageTransparency = IsSelected and 0 or 1,
                    ImageColor3 = self.Theme.Accent,
                }):Play()
                TweenService:Create(OtherItem.Label, ThemeSelectionTweenInfo, {
                    Position = UDim2.fromOffset(IsSelected and 33 or 5, 0),
                    TextTransparency = (IsSelected or OtherItem.Hovered) and 0 or 0.6,
                    TextColor3 = self.Theme.Settings.Text,
                }):Play()
                OtherItem.Selected = IsSelected
            end
        end)
    end

    local function ToggleKeybindList()
        self.KeybindListEnabled = not self.KeybindListEnabled
        local CheckboxTweenInfo = TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local CheckPosition = UDim2.fromScale(0.5, 0.5)
        if self.KeybindListEnabled then
            KeybindCheckboxCheck.Position = UDim2.new(0.5, 0, 0.5, 4)
        else
            CheckPosition = UDim2.new(0.5, 0, 0.5, 4)
        end
        TweenService:Create(KeybindCheckbox, CheckboxTweenInfo, {
            BackgroundColor3 = self.KeybindListEnabled and self.Theme.Accent or self.Theme.Groups.ToggleBackground,
        }):Play()
        TweenService:Create(KeybindCheckboxCheck, CheckboxTweenInfo, {
            ImageTransparency = self.KeybindListEnabled and 0 or 1,
            Position = CheckPosition,
        }):Play()
        if self.KeybindList then
            self.UpdateKeybindList()
            self.KeybindList.Visible = self.KeybindListEnabled
                and (self.KeybindListVisibility == "Always" or self.GuiVisible)
        end
    end

    local function ToggleBoundOnly()
        self.ShowBoundKeysOnly = not self.ShowBoundKeysOnly
        local CheckboxTweenInfo = TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local CheckPosition = UDim2.fromScale(0.5, 0.5)
        if self.ShowBoundKeysOnly then
            BoundOnlyCheck.Position = UDim2.new(0.5, 0, 0.5, 4)
        else
            CheckPosition = UDim2.new(0.5, 0, 0.5, 4)
        end
        TweenService:Create(BoundOnlyCheckbox, CheckboxTweenInfo, {
            BackgroundColor3 = self.ShowBoundKeysOnly and self.Theme.Accent or self.Theme.Groups.ToggleBackground,
        }):Play()
        TweenService:Create(BoundOnlyCheck, CheckboxTweenInfo, {
            ImageTransparency = self.ShowBoundKeysOnly and 0 or 1,
            Position = CheckPosition,
        }):Play()
        if self.KeybindList then
            self.UpdateKeybindList(true)
        end
    end

    -- Only override cursor behavior if the game had locked the mouse.
    -- If the mouse is already free, leave the game's input handling untouched.
    local function UpdateMouseUnlock()
        if self.GuiVisible and Screen.Parent then
            if not self._MouseUnlockActive and not self._MouseUnlockChecked then
                self._MouseUnlockChecked = true
                local CurrentBehavior = UserInputService.MouseBehavior
                if CurrentBehavior == Enum.MouseBehavior.LockCenter
                    or CurrentBehavior == Enum.MouseBehavior.LockCurrentPosition then
                    self._PreviousMouseBehavior = CurrentBehavior
                    self._PreviousMouseIconEnabled = UserInputService.MouseIconEnabled
                    self._MouseUnlockActive = true
                end
            end
            if self._MouseUnlockActive then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            end
        else
            if self._MouseUnlockActive then
                self._MouseUnlockActive = false
                if self._PreviousMouseBehavior then
                    UserInputService.MouseBehavior = self._PreviousMouseBehavior
                end
                if self._PreviousMouseIconEnabled ~= nil then
                    UserInputService.MouseIconEnabled = self._PreviousMouseIconEnabled
                end
            end
            self._PreviousMouseBehavior = nil
            self._PreviousMouseIconEnabled = nil
            self._MouseUnlockChecked = false
        end
    end

    self._MouseUnlockConnection = RunService.RenderStepped:Connect(UpdateMouseUnlock)
    UpdateMouseUnlock()

    local function ApplyGuiVisibility()
        Main.Visible = self.GuiVisible
        Search.Visible = self.GuiVisible
        BottomNavigation.Visible = self.GuiVisible and NavigationType == 2
        if self.KeybindList then
            self.KeybindList.Visible = self.KeybindListEnabled
                and (self.KeybindListVisibility == "Always" or self.GuiVisible)
        end
    end

    local function ToggleGuiVisibility()
        self.GuiVisible = not self.GuiVisible
        if not self.GuiVisible then
            CloseSettings()
            CloseListScaleDropdown()
            CloseVisibilityDropdown()
        end
        ApplyGuiVisibility()
        UpdateMouseUnlock()
    end

    UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.Keyboard
            and Input.KeyCode == Enum.KeyCode.RightControl then
            ToggleGuiVisibility()
        end
    end)

    StyleButton.Activated:Connect(ToggleThemeDropdown)
    KeybindButton.Activated:Connect(ToggleKeybindList)
    KeybindSettingsButton.Activated:Connect(ToggleKeybindDropdown)
    ListScaleButton.Activated:Connect(ToggleListScaleDropdown)
    VisibilityButton.Activated:Connect(ToggleVisibilityDropdown)
    BoundOnlyButton.Activated:Connect(ToggleBoundOnly)

    self.SettingsProfile = {
        Avatar = ProfileAvatar,
        DisplayName = ProfileDisplayName,
        Username = ProfileContent:FindFirstChild("Username"),
        Divider = ProfileDivider,
    }
    self.SettingsStyle = {
        Button = StyleButton,
        Icon = StyleIcon,
        Arrow = StyleArrow,
        Label = StyleLabel,
    }

    task.spawn(function()
        local Success, Content = pcall(function()
            return Players:GetUserThumbnailAsync(
                ProfilePlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end)

        if Success and Content and ProfileAvatar.Parent then
            ProfileAvatar.Image = Content
        end
    end)

    SettingsOverlay.Activated:Connect(CloseSettings)

    UserInputService.InputBegan:Connect(function(Input)
        local KeybindMenusOpen = KeybindDropdownOpen or ListScaleDropdownOpen or VisibilityDropdownOpen
        local KeybindListVisible = self.KeybindList and self.KeybindList.Visible
        if not SettingsOpen and not CategoryDropdownOpen and not KeybindMenusOpen and not KeybindListVisible
            and not ConfigMenuOpen and not ConfigAddMenuOpen and not ConfigRowMenuOpen then return end
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
            and Input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end

        local Point = Vector2.new(Input.Position.X, Input.Position.Y)

        if ConfigAddMenuOpen
            and not IsInside(ConfigAddMenu, Point)
            and not IsInside(ConfigMenu, Point) then
            CloseConfigAddMenu()
        end

        if ConfigRowMenuOpen
            and not IsInside(ConfigRowMenu, Point)
            and not IsInside(ConfigMenu, Point) then
            CloseConfigRowMenu()
        end

        if ConfigMenuOpen
            and not IsInside(ConfigMenu, Point)
            and not IsInside(ConfigAddMenu, Point)
            and not IsInside(ConfigRowMenu, Point)
            and not IsInside(ConfigButton, Point) then
            CloseConfigMenu()
        end

        if not SettingsOpen and not CategoryDropdownOpen and not KeybindMenusOpen and not KeybindListVisible then
            return
        end

        if CategoryDropdownOpen
            and not IsInside(CategoryDropdown, Point)
            and not IsInside(CategoryButton, Point) then
            CloseCategoryDropdown()
        end

        if ThemeDropdownOpen
            and not IsInside(ThemeDropdown, Point)
            and not (self.SettingsStyle and IsInside(self.SettingsStyle.Button, Point)) then
            CloseThemeDropdown()
        end

        if KeybindDropdownOpen
            and not IsInside(KeybindDropdown, Point)
            and not IsInside(self.SettingsKeybind and self.SettingsKeybind.ListScaleDropdown, Point)
            and not IsInside(VisibilityDropdown, Point)
            and not (self.SettingsKeybind and IsInside(self.SettingsKeybind.Button, Point))
            and not (self.SettingsKeybind and IsInside(self.SettingsKeybind.SettingsButton, Point)) then
            CloseKeybindDropdown()
        end

        if ListScaleDropdownOpen
            and not IsInside(self.SettingsKeybind and self.SettingsKeybind.ListScaleDropdown, Point)
            and not (self.SettingsKeybind and IsInside(self.SettingsKeybind.ListScaleButton, Point)) then
            CloseListScaleDropdown()
        end

        if VisibilityDropdownOpen
            and not IsInside(VisibilityDropdown, Point)
            and not (self.SettingsKeybind and IsInside(self.SettingsKeybind.VisibilityButton, Point)) then
            CloseVisibilityDropdown()
        end

        if not IsInside(SettingsMenu, Point)
            and not IsInside(ThemeDropdown, Point)
            and not IsInside(KeybindDropdown, Point)
            and not IsInside(self.SettingsKeybind and self.SettingsKeybind.ListScaleDropdown, Point)
            and not IsInside(VisibilityDropdown, Point)
            and not IsInside(self.KeybindList, Point)
            and not IsInside(Main, Point) then
            CloseSettings()
        end
    end)

    local function CreateSettingsButton()
        local Button = UI.Create("TextButton", {
            Name = "Settings",
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 0),
            BackgroundColor3 = self.Theme.Surface.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -16, 0, 16),
            Size = UDim2.fromOffset(40, 40),
            Text = "",
            ZIndex = 60,
        }, Main)
        UI.Corner(Button, 10)

        local Icon = UI.Create("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 18),
            Image = GetIcon("settings"),
            ImageColor3 = self.Theme.Sidebar.Tabs.Text,
            ImageTransparency = 0.74,
        }, Button)

        Button.Activated:Connect(ToggleSettings)

        local TopButton = {Button = Button, Icon = Icon}
        table.insert(TopButtons, TopButton)
        return TopButton
    end

    local function CreateConfigButton()
        local Button = UI.Create("TextButton", {
            Name = "Config",
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Surface.Background,
            BorderSizePixel = 0,
            Position = NavigationType == 2 and UDim2.fromOffset(16, 16) or UDim2.fromOffset(236, 16),
            Size = UDim2.fromOffset(40, 40),
            Text = "",
            ZIndex = 60,
        }, Main)
        UI.Corner(Button, 10)

        local Icon = UI.Create("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 18),
            Image = FallbackIcons.folder or GetIcon("folder"),
            ImageColor3 = self.Theme.Sidebar.Tabs.Text,
            ImageTransparency = 0.74,
        }, Button)

        ConfigButton = Button
        local TopButton = {Button = Button, Icon = Icon}
        table.insert(TopButtons, TopButton)
        return TopButton
    end

    local function RenderConfigList()
        if not self.ConfigList or not self.ConfigMenu then return end

        for _, Child in ipairs(self.ConfigList:GetChildren()) do
            if not Child:IsA("UIListLayout") then
                Child:Destroy()
            end
        end

        self.ConfigRows = {}
        local Query = self.ConfigSearchInput and string.lower(self.ConfigSearchInput.Text or "") or ""
        local VisibleCount = 0
        for _, Name in ipairs(ConfigNames) do
            if Query == "" or string.find(string.lower(Name), Query, 1, true) then
                VisibleCount += 1
                local Row = UI.Create("TextButton", {
                    Name = "ConfigRow",
                    AutoButtonColor = false,
                    BackgroundColor3 = self.Theme.Groups.ToggleBackground,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Text = "",
                    ZIndex = 83,
                }, self.ConfigList)
                UI.Corner(Row, 7)

                local Label = UI.Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(10, 0),
                    Size = UDim2.new(1, -48, 1, 0),
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Text = Name,
                    TextColor3 = self.Theme.Settings.Text,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 84,
                }, Row)

                local OptionsButton = UI.Create("ImageButton", {
                    Name = "Options",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    Image = GetIcon("more-horizontal"),
                    ImageColor3 = self.Theme.Settings.Text,
                    ImageTransparency = 0.45,
                    ZIndex = 84,
                }, Row)

                OptionsButton.Activated:Connect(function()
                    if ConfigRowMenuOpen and ConfigRowMenuTarget == Name then
                        CloseConfigRowMenu()
                    else
                        OpenConfigRowMenu(Name, Row)
                    end
                end)

                Row.Activated:Connect(function()
                    if self:LoadConfig(Name) then
                        ActiveConfigName = Name
                    end
                end)

                table.insert(self.ConfigRows, {Background = Row, Label = Label})
            end
        end

        self.ConfigList.Size = UDim2.new(1, -20, 0, math.max(0, math.min(VisibleCount, 4) * 34))
        self.ConfigMenu.Size = UDim2.fromOffset(220, 102 + self.ConfigList.Size.Y.Offset)
    end

    local function OpenConfigAddMenu()
        if not self.ConfigAddMenu then return end
        ConfigAddMenuOpen = true
        self.ConfigAddMenu.Visible = true
        self.ConfigAddMenu.BackgroundTransparency = 1
        self.ConfigAddMenu.GroupTransparency = 1
        self.ConfigAddMenu.Position = UDim2.new(ConfigAddMenuBasePosition.X.Scale, ConfigAddMenuBasePosition.X.Offset + 8, ConfigAddMenuBasePosition.Y.Scale, ConfigAddMenuBasePosition.Y.Offset)
        TweenService:Create(self.ConfigAddMenu, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            GroupTransparency = 0,
            Position = ConfigAddMenuBasePosition,
        }):Play()
        if self.ConfigAddMenuInput then
            self.ConfigAddMenuInput:CaptureFocus()
        end
    end

    CloseConfigAddMenu = function()
        if not ConfigAddMenuOpen or not self.ConfigAddMenu then return end
        ConfigAddMenuOpen = false
        TweenService:Create(self.ConfigAddMenu, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            Position = UDim2.new(ConfigAddMenuBasePosition.X.Scale, ConfigAddMenuBasePosition.X.Offset + 8, ConfigAddMenuBasePosition.Y.Scale, ConfigAddMenuBasePosition.Y.Offset),
        }):Play()
        task.delay(SettingsTweenInfo.Time, function()
            if not ConfigAddMenuOpen and self.ConfigAddMenu then
                self.ConfigAddMenu.Visible = false
            end
        end)
    end

    local function OpenConfigMenu()
        if not self.ConfigMenu then return end
        ConfigMenuOpen = true
        self.ConfigMenu.Visible = true
        self.ConfigDimmer.Visible = true
        self.ConfigDimmer.BackgroundTransparency = 1
        self.ConfigMenu.BackgroundTransparency = 1
        self.ConfigMenu.GroupTransparency = 1
        self.ConfigMenu.Position = UDim2.new(ConfigMenuBasePosition.X.Scale, ConfigMenuBasePosition.X.Offset, ConfigMenuBasePosition.Y.Scale, ConfigMenuBasePosition.Y.Offset - 6)
        TweenService:Create(self.ConfigMenu, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            GroupTransparency = 0,
            Position = ConfigMenuBasePosition,
        }):Play()
        TweenService:Create(ConfigDimmer, SettingsTweenInfo, {
            BackgroundTransparency = 0.78,
        }):Play()
    end

    CloseConfigMenu = function()
        if not ConfigMenuOpen or not self.ConfigMenu then return end
        ConfigMenuOpen = false
        CloseConfigAddMenu()
        CloseConfigRowMenu()
        TweenService:Create(self.ConfigMenu, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            Position = UDim2.new(ConfigMenuBasePosition.X.Scale, ConfigMenuBasePosition.X.Offset, ConfigMenuBasePosition.Y.Scale, ConfigMenuBasePosition.Y.Offset - 6),
        }):Play()
        TweenService:Create(ConfigDimmer, SettingsTweenInfo, {
            BackgroundTransparency = 1,
        }):Play()
        task.delay(SettingsTweenInfo.Time, function()
            if not ConfigMenuOpen and self.ConfigMenu then
                self.ConfigMenu.Visible = false
                ConfigDimmer.Visible = false
            end
        end)
    end

    local function ToggleConfigMenu()
        if ConfigMenuOpen then
            CloseConfigMenu()
        else
            OpenConfigMenu()
        end
    end

    local function UpdateConfigRowMenuState(Animated)
        if not ConfigRowMenuTarget then return end
        local Selected = ConfigRowMenuTarget == AutoLoadConfigName
        local TweenInfoValue = TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        local CheckPosition = Selected and UDim2.fromScale(0.5, 0.5) or UDim2.new(0.5, 0, 0.5, 4)
        if not Animated then
            self.ConfigRowAutoLoadCheck.BackgroundColor3 = Selected and self.Theme.Accent or self.Theme.Groups.ToggleBackground
            self.ConfigRowAutoLoadCheckIcon.ImageTransparency = Selected and 0 or 1
            self.ConfigRowAutoLoadCheckIcon.Position = CheckPosition
            return
        end
        TweenService:Create(self.ConfigRowAutoLoadCheck, TweenInfoValue, {
            BackgroundColor3 = Selected and self.Theme.Accent or self.Theme.Groups.ToggleBackground,
        }):Play()
        TweenService:Create(self.ConfigRowAutoLoadCheckIcon, TweenInfoValue, {
            ImageTransparency = Selected and 0 or 1,
            Position = CheckPosition,
        }):Play()
    end

    OpenConfigRowMenu = function(Name, Row)
        if not self.ConfigRowMenu then return end
        ConfigRowMenuTarget = Name
        self.ConfigRowMenuTarget = Name
        self.ConfigRowMenu.BackgroundColor3 = self.Theme.Settings.Background
        DeleteConfirmName = nil
        DeleteConfirmToken += 1
        self.ConfigRowDeleteLabel.Text = "Delete"
        ConfigRowMenuOpen = true
        local MainPosition = Main.AbsolutePosition
        local Scale = math.max(MainScale.Scale, 0.1)
        local RowPosition = Row.AbsolutePosition
        local RowSize = Row.AbsoluteSize
        local X = (RowPosition.X - MainPosition.X + RowSize.X + 8 * Scale) / Scale
        local Y = (RowPosition.Y - MainPosition.Y) / Scale
        self.ConfigRowMenu.Position = UDim2.fromOffset(X, Y)
        self.ConfigRowMenu.Visible = true
        self.ConfigRowMenu.BackgroundTransparency = 1
        self.ConfigRowMenu.GroupTransparency = 1
        TweenService:Create(self.ConfigRowMenu, SettingsTweenInfo, {
            BackgroundTransparency = 0,
            GroupTransparency = 0,
        }):Play()
        UpdateConfigRowMenuState()
    end

    CloseConfigRowMenu = function()
        if not ConfigRowMenuOpen or not self.ConfigRowMenu then return end
        ConfigRowMenuOpen = false
        ConfigRowMenuTarget = nil
        self.ConfigRowMenuTarget = nil
        DeleteConfirmName = nil
        DeleteConfirmToken += 1
        self.ConfigRowDeleteLabel.Text = "Delete"
        TweenService:Create(self.ConfigRowMenu, SettingsTweenInfo, {
            BackgroundTransparency = 1,
            GroupTransparency = 1,
        }):Play()
        task.delay(SettingsTweenInfo.Time, function()
            if not ConfigRowMenuOpen and self.ConfigRowMenu then
                self.ConfigRowMenu.Visible = false
            end
        end)
    end

    local function CreateConfigMenus()
        local ConfigList
        local ConfigSearchInput
        local ConfigMenuIcon
        local ConfigMenuTitle
        local ConfigMenuSearch
        local ConfigMenuSearchIcon
        local ConfigMenuDivider
        local ConfigAddButton
        local ConfigAddIcon
        local ConfigPresetsButton
        local ConfigAddMenuInput
        local ConfigCreateButton
        local ConfigRowMenuLabel
        local ConfigRowAutoLoadButton
        local ConfigRowAutoLoadCheck
        local ConfigRowAutoLoadCheckIcon
        local ConfigRowAutoLoadLabel
        local ConfigRowDeleteButton
        local ConfigRowDeleteLabel
        local ConfigDeleteRipple
        local ConfigDeleteRippleX
        local MenuX = NavigationType == 2 and 16 or 236
        local MenuY = 62

        ConfigMenuBasePosition = UDim2.fromOffset(MenuX, MenuY)
        ConfigAddMenuBasePosition = UDim2.fromOffset(MenuX + 228, MenuY)

        ConfigMenu = UI.Create("CanvasGroup", {
            Name = "ConfigMenu",
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundColor3 = self.Theme.Settings.Background,
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = ConfigMenuBasePosition,
            Size = UDim2.fromOffset(220, 102),
            Visible = false,
            ZIndex = 80,
        }, Main)
        UI.Corner(ConfigMenu, 10)
        self.ConfigMenu = ConfigMenu

        ConfigDimmer = UI.Create("Frame", {
            Name = "ConfigDimmer",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            ZIndex = 70,
        }, Main)
        UI.Corner(ConfigDimmer, 14)
        self.ConfigDimmer = ConfigDimmer

        local Header = UI.Create("Frame", {
            Name = "Header",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 8),
            Size = UDim2.new(1, -20, 0, 28),
            ZIndex = 81,
        }, ConfigMenu)
        ConfigPresetsButton = UI.Create("TextButton", {
            Name = "Presets",
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Groups.ToggleBackground,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, -1),
            Size = UDim2.fromOffset(100, 30),
            Text = "",
            ZIndex = 81,
        }, Header)
        UI.Corner(ConfigPresetsButton, 7)
        ConfigMenuIcon = UI.Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 5),
            Size = UDim2.fromOffset(16, 16),
            Image = GetIcon("cloud"),
            ImageColor3 = self.Theme.Settings.Text,
            ImageTransparency = 0.35,
            ZIndex = 82,
        }, Header)
        ConfigMenuTitle = UI.Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(24, 0),
            Size = UDim2.new(1, -62, 1, 0),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Presets",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 82,
        }, Header)
        ConfigMenuIcon.Parent = ConfigPresetsButton
        ConfigMenuIcon.Position = UDim2.fromOffset(8, 7)
        ConfigMenuTitle.Parent = ConfigPresetsButton
        ConfigMenuTitle.Position = UDim2.fromOffset(30, 0)
        ConfigMenuTitle.Size = UDim2.new(1, -36, 1, 0)
        ConfigAddButton = UI.Create("TextButton", {
            Name = "Add",
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Groups.ToggleBackground,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -30, 0, -1),
            Size = UDim2.fromOffset(30, 30),
            Text = "",
            ZIndex = 82,
        }, Header)
        UI.Corner(ConfigAddButton, 7)
        ConfigAddIcon = UI.Create("ImageLabel", {
            Name = "Icon",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(17, 17),
            Image = GetIcon("plus"),
            ImageColor3 = self.Theme.Settings.Text,
            ImageTransparency = 0.2,
            ZIndex = 83,
        }, ConfigAddButton)

        ConfigMenuSearch = UI.Create("Frame", {
            Name = "SearchBackground",
            BackgroundColor3 = self.Theme.Groups.ToggleBackground,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 52),
            Size = UDim2.new(1, -20, 0, 30),
            ZIndex = 81,
        }, ConfigMenu)
        UI.Corner(ConfigMenuSearch, 7)
        ConfigMenuSearchIcon = UI.Create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 7),
            Size = UDim2.fromOffset(15, 15),
            Image = FallbackIcons.search or GetIcon("search"),
            ImageColor3 = self.Theme.Settings.Text,
            ImageTransparency = 0.65,
            ZIndex = 82,
        }, ConfigMenuSearch)
        ConfigSearchInput = UI.Create("TextBox", {
            Name = "Input",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Position = UDim2.fromOffset(29, 0),
            Size = UDim2.new(1, -35, 1, 0),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            PlaceholderText = "Search",
            PlaceholderColor3 = self.Theme.Settings.Text:Lerp(self.Theme.Groups.ToggleBackground, 0.6),
            Text = "",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 82,
        }, ConfigMenuSearch)

        ConfigMenuDivider = UI.Create("Frame", {
            Name = "Divider",
            BackgroundColor3 = self.Theme.Groups.Divider,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 44),
            Size = UDim2.new(1, -20, 0, 1),
            ZIndex = 81,
        }, ConfigMenu)
        ConfigList = UI.Create("Frame", {
            Name = "List",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 90),
            Size = UDim2.new(1, -20, 0, 0),
            ZIndex = 81,
        }, ConfigMenu)
        UI.Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, ConfigList)

        ConfigAddMenu = UI.Create("CanvasGroup", {
            Name = "ConfigAddMenu",
            BackgroundColor3 = self.Theme.Settings.Background,
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            BorderSizePixel = 0,
            Position = ConfigAddMenuBasePosition,
            Size = UDim2.fromOffset(190, 106),
            Visible = false,
            ZIndex = 90,
        }, Main)
        UI.Corner(ConfigAddMenu, 10)
        self.ConfigAddMenu = ConfigAddMenu
        ConfigAddMenuInput = UI.Create("TextBox", {
            Name = "Input",
            BackgroundColor3 = self.Theme.Groups.ToggleBackground,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Position = UDim2.fromOffset(10, 10),
            Size = UDim2.new(1, -20, 0, 34),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            PlaceholderText = "Create a new config...",
            PlaceholderColor3 = self.Theme.Settings.Text:Lerp(self.Theme.Groups.ToggleBackground, 0.6),
            Text = "",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 91,
        }, ConfigAddMenu)
        UI.Corner(ConfigAddMenuInput, 7)
        ConfigCreateButton = UI.Create("TextButton", {
            Name = "Create",
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Accent,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 54),
            Size = UDim2.new(1, -20, 0, 38),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Create",
            TextColor3 = Color3.new(0, 0, 0),
            TextSize = 14,
            ZIndex = 91,
        }, ConfigAddMenu)
        UI.Corner(ConfigCreateButton, 7)

        ConfigRowMenu = UI.Create("CanvasGroup", {
            Name = "ConfigRowMenu",
            AutomaticSize = Enum.AutomaticSize.None,
            BackgroundColor3 = self.Theme.Settings.Background,
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Size = UDim2.fromOffset(160, 76),
            Visible = false,
            ZIndex = 95,
        }, Main)
        UI.Corner(ConfigRowMenu, 10)
        self.ConfigRowMenu = ConfigRowMenu
        ConfigRowMenuLabel = UI.Create("TextLabel", {
            Name = "Title",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(10, 7),
            Size = UDim2.new(1, -20, 0, 20),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Options",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 96,
        }, ConfigRowMenu)
        ConfigRowMenuLabel.Visible = false
        ConfigRowAutoLoadButton = UI.Create("TextButton", {
            Name = "AutoLoad",
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 8),
            Size = UDim2.new(1, -16, 0, 30),
            Text = "",
            ZIndex = 96,
        }, ConfigRowMenu)
        ConfigRowAutoLoadCheck = UI.Create("Frame", {
            Name = "CheckBox",
            BackgroundColor3 = self.Theme.Groups.ToggleBackground,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, 0, 0.5, 0),
            Size = UDim2.fromOffset(20, 20),
            ZIndex = 97,
        }, ConfigRowAutoLoadButton)
        UI.Corner(ConfigRowAutoLoadCheck, 5)
        ConfigRowAutoLoadCheckIcon = UI.Create("ImageLabel", {
            Name = "Check",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(14, 14),
            Image = FallbackIcons.check or GetIcon("check"),
            ImageColor3 = Color3.new(0, 0, 0),
            ImageTransparency = 1,
            ZIndex = 98,
        }, ConfigRowAutoLoadCheck)
        ConfigRowAutoLoadLabel = UI.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.new(1, -28, 1, 0),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Auto Load",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 97,
        }, ConfigRowAutoLoadButton)
        ConfigRowDeleteButton = UI.Create("TextButton", {
            Name = "Delete",
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Groups.ToggleBackground,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(8, 38),
            Size = UDim2.new(1, -16, 0, 30),
            Text = "",
            BackgroundTransparency = 0,
            ZIndex = 96,
        }, ConfigRowMenu)
        UI.Corner(ConfigRowDeleteButton, 6)
        ConfigRowDeleteButton.ClipsDescendants = true
        ConfigDeleteRipple = UI.Create("Frame", {
            Name = "Ripple",
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = self.Theme.Accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(0, 0),
            ZIndex = 96,
        }, ConfigRowDeleteButton)
        UI.Corner(ConfigDeleteRipple, 6)
        ConfigRowDeleteLabel = UI.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(0, 0),
            Size = UDim2.fromScale(1, 1),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "Delete",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 97,
        }, ConfigRowDeleteButton)

        self.ConfigList = ConfigList
        self.ConfigSearchInput = ConfigSearchInput
        self.ConfigMenuIcon = ConfigMenuIcon
        self.ConfigMenuTitle = ConfigMenuTitle
        self.ConfigMenuSearch = ConfigMenuSearch
        self.ConfigMenuSearchIcon = ConfigMenuSearchIcon
        self.ConfigMenuDivider = ConfigMenuDivider
        self.ConfigAddButton = ConfigAddButton
        self.ConfigAddIcon = ConfigAddIcon
        self.ConfigPresetsButton = ConfigPresetsButton
        self.ConfigAddMenuInput = ConfigAddMenuInput
        self.ConfigCreateButton = ConfigCreateButton
        self.ConfigRowMenuLabel = ConfigRowMenuLabel
        self.ConfigRowAutoLoadButton = ConfigRowAutoLoadButton
        self.ConfigRowAutoLoadCheck = ConfigRowAutoLoadCheck
        self.ConfigRowAutoLoadCheckIcon = ConfigRowAutoLoadCheckIcon
        self.ConfigRowAutoLoadLabel = ConfigRowAutoLoadLabel
        self.ConfigRowDeleteButton = ConfigRowDeleteButton
        self.ConfigRowDeleteLabel = ConfigRowDeleteLabel

        ConfigRowDeleteButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1
                or Input.UserInputType == Enum.UserInputType.Touch then
                local ButtonPosition = ConfigRowDeleteButton.AbsolutePosition
                ConfigDeleteRippleX = math.clamp(Input.Position.X - ButtonPosition.X, 0, ConfigRowDeleteButton.AbsoluteSize.X)
            end
        end)

        ConfigSearchInput:GetPropertyChangedSignal("Text"):Connect(RenderConfigList)
        ConfigAddButton.Activated:Connect(function()
            if ConfigAddMenuOpen then
                CloseConfigAddMenu()
            else
                OpenConfigAddMenu()
            end
        end)
        ConfigCreateButton.Activated:Connect(function()
            EnsureConfigFolders()
            local Name = string.gsub(ConfigAddMenuInput.Text or "", "^%s*(.-)%s*$", "%1")
            if Name ~= "" then
                local Exists = false
                for _, Existing in ipairs(ConfigNames) do
                    if string.lower(Existing) == string.lower(Name) then
                        Exists = true
                        break
                    end
                end
                if not Exists then
                    table.insert(ConfigNames, Name)
                    ActiveConfigName = Name
                    self.ActiveConfigName = Name
                    self:SaveConfig(Name, self:CaptureConfig())
                    ConfigAddMenuInput.Text = ""
                    RenderConfigList()
                    CloseConfigAddMenu()
                end
            end
        end)

        ConfigRowAutoLoadButton.Activated:Connect(function()
            if not ConfigRowMenuTarget then return end
            if AutoLoadConfigName == ConfigRowMenuTarget then
                AutoLoadConfigName = nil
            else
                AutoLoadConfigName = ConfigRowMenuTarget
            end
            self.AutoLoadConfigName = AutoLoadConfigName
            self:_WriteConfigStorage()
            UpdateConfigRowMenuState(true)
        end)

        ConfigRowDeleteButton.Activated:Connect(function()
            if not ConfigRowMenuTarget then return end
            local ButtonWidth = ConfigRowDeleteButton.AbsoluteSize.X
            local ButtonHeight = ConfigRowDeleteButton.AbsoluteSize.Y
            local ClickX = ConfigDeleteRippleX or ButtonWidth * 0.5
            local TargetWidth = math.max(ClickX, ButtonWidth - ClickX) * 2 + 20
            ConfigDeleteRipple.Position = UDim2.fromOffset(ClickX, ButtonHeight * 0.5)
            ConfigDeleteRipple.BackgroundColor3 = self.Theme.Accent
            ConfigDeleteRipple.BackgroundTransparency = 0.18
            ConfigDeleteRipple.Size = UDim2.new(0, 0, 1, 0)
            TweenService:Create(ConfigDeleteRipple, TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1,
                Size = UDim2.new(0, TargetWidth, 1, 0),
            }):Play()
            local DeletedName = ConfigRowMenuTarget
            if DeleteConfirmName ~= DeletedName then
                DeleteConfirmName = DeletedName
                DeleteConfirmToken += 1
                local Token = DeleteConfirmToken
                ConfigRowDeleteLabel.Text = "Confirm?"
                task.delay(3, function()
                    if DeleteConfirmToken == Token and DeleteConfirmName == DeletedName and ConfigRowMenu then
                        DeleteConfirmName = nil
                        ConfigRowDeleteLabel.Text = "Delete"
                    end
                end)
                return
            end
            for Index, Existing in ipairs(ConfigNames) do
                if Existing == DeletedName then
                    table.remove(ConfigNames, Index)
                    break
                end
            end
            if AutoLoadConfigName == DeletedName then
                AutoLoadConfigName = nil
                self.AutoLoadConfigName = nil
            end
            self:DeleteConfig(DeletedName)
            CloseConfigRowMenu()
            RenderConfigList()
        end)

        ConfigButton.Activated:Connect(ToggleConfigMenu)
        RenderConfigList()
    end

    local function CreateCategoryButton()
        CategoryButton = UI.Create("TextButton", {
            Name = "Category",
            AutoButtonColor = false,
            BackgroundColor3 = self.Theme.Surface.Background,
            BorderSizePixel = 0,
            Position = NavigationType == 2 and UDim2.fromOffset(64, 16) or UDim2.fromOffset(284, 16),
            Size = UDim2.fromOffset(180, 40),
            Text = "",
            Visible = false,
            ZIndex = 60,
        }, Main)
        UI.Corner(CategoryButton, 10)

        CategoryLabel = UI.Create("TextLabel", {
            Name = "Label",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -44, 1, 0),
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Text = "",
            TextColor3 = self.Theme.Sidebar.Tabs.Text,
            TextSize = 14,
            TextTransparency = 0.6,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, CategoryButton)

        CategoryArrow = UI.Create("ImageLabel", {
            Name = "Arrow",
            AnchorPoint = Vector2.new(1, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            Image = FallbackIcons["chevron-down"] or GetIcon("chevron-down"),
            ImageColor3 = self.Theme.Sidebar.Tabs.Text,
            ImageTransparency = 0.74,
        }, CategoryButton)

        CategoryDimmer = UI.Create("Frame", {
            Name = "CategoryDimmer",
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            ZIndex = 40,
        }, Main)
        UI.Corner(CategoryDimmer, 14)

        CategoryOverlay = UI.Create("TextButton", {
            Name = "CategoryOverlay",
            Active = true,
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            Text = "",
            Visible = false,
            ZIndex = 41,
        }, Main)
        UI.Corner(CategoryOverlay, 14)
        CategoryOverlay.Activated:Connect(CloseCategoryDropdown)

        CategoryDropdown = UI.Create("Frame", {
            Name = "CategoryDropdown",
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = self.Theme.Settings.Background,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Position = NavigationType == 2 and UDim2.fromOffset(64, 58) or UDim2.fromOffset(284, 58),
            Size = UDim2.fromOffset(180, 0),
            Visible = false,
            ZIndex = 55,
        }, Main)
        UI.Corner(CategoryDropdown, 10)

        CategoryDropdownContent = UI.Create("CanvasGroup", {
            Name = "Content",
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            GroupTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            ZIndex = 56,
        }, CategoryDropdown)
        UI.Create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }, CategoryDropdownContent)
        UI.Create("UIListLayout", {
            Padding = UDim.new(0, 4),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, CategoryDropdownContent)

        local function RebuildCategoryDropdown(Tab)
            for _, Child in ipairs(CategoryDropdownContent:GetChildren()) do
                if Child:IsA("TextButton") then
                    Child:Destroy()
                end
            end
            CategoryDropdownItems = {}
            self.CategoryDropdownItems = CategoryDropdownItems

            local ActiveIndex = Tab.ActiveCategoryIndex or 1
            for Index, Category in ipairs(Tab.Categories) do
                local Selected = Index == ActiveIndex
                local CategoryButtonItem = UI.Create("TextButton", {
                    Name = Category.Name,
                    AutoButtonColor = false,
                    BackgroundColor3 = self.Theme.Settings.SelectedBackground,
                    BackgroundTransparency = Selected and 0 or 1,
                    BorderSizePixel = 0,
                    LayoutOrder = Index,
                    Size = UDim2.new(1, 0, 0, 30),
                    Text = "",
                    ZIndex = 57,
                }, CategoryDropdownContent)
                UI.Corner(CategoryButtonItem, 7)

                local Check = UI.Create("ImageLabel", {
                    Name = "Check",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(Selected and 9 or 5, 7),
                    Size = UDim2.fromOffset(17, 17),
                    Image = FallbackIcons.check or GetIcon("check"),
                    ImageColor3 = self.Theme.Accent,
                    ImageTransparency = Selected and 0 or 1,
                    ZIndex = 58,
                }, CategoryButtonItem)

                local Label = UI.Create("TextLabel", {
                    Name = "Label",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(Selected and 33 or 5, 0),
                    Size = UDim2.new(1, -29, 1, 0),
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Text = Category.Name,
                    TextColor3 = self.Theme.Settings.Text,
                    TextSize = 14,
                    TextTransparency = Selected and 0 or 0.6,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    ZIndex = 58,
                }, CategoryButtonItem)

                local Item = {
                    Button = CategoryButtonItem,
                    Check = Check,
                    Label = Label,
                    Selected = Selected,
                }
                table.insert(CategoryDropdownItems, Item)

                CategoryButtonItem.MouseEnter:Connect(function()
                    TweenService:Create(Label, ThemeHoverTweenInfo, {
                        TextTransparency = 0,
                    }):Play()
                end)
                CategoryButtonItem.MouseLeave:Connect(function()
                    TweenService:Create(Label, ThemeHoverTweenInfo, {
                        TextTransparency = Item.Selected and 0 or 0.6,
                    }):Play()
                end)
                CategoryButtonItem.Activated:Connect(function()
                    local CategoryChanged = Tab.ActiveCategoryIndex ~= Index
                    Tab.ActiveCategoryIndex = Index
                    CategoryLabel.Text = Category.Name
                    if CategoryChanged then
                        if UpdateBreadcrumb then
                            UpdateBreadcrumb(Tab, Category.Name)
                        end
                        if UpdateCategoryContent then
                            UpdateCategoryContent(Tab)
                        end
                    end
                    for ItemIndex, OtherItem in ipairs(CategoryDropdownItems) do
                        SetCategoryItemState(OtherItem, ItemIndex == Index, false)
                    end
                    CloseCategoryDropdown()
                end)
            end
        end

        UpdateCategoryButton = function(Tab)
            local FirstCategory = Tab and Tab.Categories and Tab.Categories[1]
            CategoryButton.Visible = Tab ~= nil and FirstCategory ~= nil
            if not CategoryButton.Visible then
                CloseCategoryDropdown()
                if UpdateBreadcrumb then
                    UpdateBreadcrumb(Tab, nil)
                end
                if UpdateCategoryContent then
                    UpdateCategoryContent(nil)
                end
                return
            end

            RebuildCategoryDropdown(Tab)
            if FirstCategory then
                local ActiveCategory = Tab.Categories[Tab.ActiveCategoryIndex or 1] or FirstCategory
                CategoryLabel.Text = ActiveCategory.Name
                if UpdateBreadcrumb then
                    UpdateBreadcrumb(Tab, ActiveCategory.Name)
                end
                if UpdateCategoryContent then
                    UpdateCategoryContent(Tab)
                end
            else
                CategoryLabel.Text = ""
            end
        end

        CategoryButton.Activated:Connect(ToggleCategoryDropdown)
    end

    local function CreateBreadcrumb()
        Breadcrumb = UI.Create("Frame", {
            Name = "Breadcrumb",
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = NavigationType == 2 and UDim2.fromOffset(16, 64) or UDim2.fromOffset(236, 64),
            Size = UDim2.fromOffset(0, 24),
            Visible = false,
            ZIndex = 2,
        }, Main)
        UI.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Padding = UDim.new(0, 9),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, Breadcrumb)

        BreadcrumbTabLabel = UI.Create("TextLabel", {
            Name = "Tab",
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            LayoutOrder = 1,
            Size = UDim2.fromOffset(0, 24),
            Text = "",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, Breadcrumb)

        BreadcrumbArrow = UI.Create("ImageLabel", {
            Name = "Arrow",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            LayoutOrder = 2,
            Size = UDim2.fromOffset(14, 14),
            Image = FallbackIcons["chevron-right"] or GetIcon("chevron-right"),
            ImageColor3 = self.Theme.Settings.Text,
            ImageTransparency = 0.74,
        }, Breadcrumb)

        BreadcrumbCategoryLabel = UI.Create("TextLabel", {
            Name = "Category",
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            LayoutOrder = 3,
            Size = UDim2.fromOffset(0, 24),
            Text = "",
            TextColor3 = self.Theme.Settings.Text,
            TextSize = 14,
            TextTransparency = 0.6,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
        }, Breadcrumb)

        UpdateBreadcrumb = function(Tab, CategoryName)
            local Visible = Tab ~= nil and CategoryName ~= nil
            Breadcrumb.Visible = Visible
            if not Visible then return end

            BreadcrumbTweenId += 1
            local BreadcrumbTweenInfo = SearchUpdating and TweenInfo.new(0) or TabTweenInfo
            BreadcrumbTabLabel.Text = Tab.Name
            BreadcrumbCategoryLabel.Text = CategoryName

            local BreadcrumbX = NavigationType == 2 and 16 or 236
            local TargetPosition = UDim2.fromOffset(BreadcrumbX, 64)
            Breadcrumb.Position = UDim2.fromOffset(BreadcrumbX - 12, 64)
            BreadcrumbTabLabel.TextTransparency = 1
            BreadcrumbArrow.ImageTransparency = 1
            BreadcrumbCategoryLabel.TextTransparency = 1

            TweenService:Create(Breadcrumb, BreadcrumbTweenInfo, {
                Position = TargetPosition,
            }):Play()
            TweenService:Create(BreadcrumbTabLabel, BreadcrumbTweenInfo, {
                TextTransparency = 0,
            }):Play()
            TweenService:Create(BreadcrumbArrow, BreadcrumbTweenInfo, {
                ImageTransparency = 0.74,
            }):Play()
            TweenService:Create(BreadcrumbCategoryLabel, BreadcrumbTweenInfo, {
                TextTransparency = 0.6,
            }):Play()
        end
    end

    local function CreateGroupArea()
        GroupArea = UI.Create("Frame", {
            Name = "GroupArea",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = NavigationType == 2 and UDim2.fromOffset(16, 98) or UDim2.fromOffset(236, 98),
            Size = NavigationType == 2 and UDim2.new(1, -32, 1, -114) or UDim2.new(1, -252, 1, -114),
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 2,
        }, Main)
        UI.Create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }, GroupArea)
        local ContentTweenId = 0

        UpdateCategoryContent = function(Tab)
            ContentTweenId += 1
            local TweenId = ContentTweenId
            local ShouldAnimate = not SearchUpdating
            local ActiveCategory = Tab and Tab.Categories[Tab.ActiveCategoryIndex or 1]
            GroupArea.Visible = ActiveCategory ~= nil and #ActiveCategory.Groups > 0

            for _, OtherTab in ipairs(Tabs) do
                for _, Category in ipairs(OtherTab.Categories) do
                    local IsActiveCategory = OtherTab == Tab and Category == ActiveCategory
                    if Category.ColumnRow then
                        Category.ColumnRow.Visible = IsActiveCategory
                    end
                    if Category.ColumnBottomMask then
                        Category.ColumnBottomMask.Visible = IsActiveCategory
                    end
                    for _, Group in ipairs(Category.Groups) do
                        Group.Wrapper.Visible = IsActiveCategory
                    end
                end
            end

            if ActiveCategory and ActiveCategory.ColumnMaskUpdates then
                for _, UpdateMask in ipairs(ActiveCategory.ColumnMaskUpdates) do
                    UpdateMask()
                end
            end

            if ActiveCategory then
                task.defer(function()
                    if TweenId ~= ContentTweenId then return end
                    for _, Group in ipairs(ActiveCategory.Groups) do
                        local function AnimateElement(Object, Delay)
                            if not Object then return end
                            local ElementTarget = Object.Position
                            Object.Position = UDim2.new(
                                ElementTarget.X.Scale,
                                ElementTarget.X.Offset - 12,
                                ElementTarget.Y.Scale,
                                ElementTarget.Y.Offset
                            )
                            if not ShouldAnimate then
                                Object.Position = ElementTarget
                                return
                            end
                            task.delay(Delay, function()
                                if TweenId == ContentTweenId and Object.Parent then
                                    TweenService:Create(Object, TweenInfo.new(
                                        0.22,
                                        Enum.EasingStyle.Sine,
                                        Enum.EasingDirection.Out
                                    ), {
                                        Position = ElementTarget,
                                    }):Play()
                                end
                            end)
                        end

                        for ElementIndex, Element in ipairs(Group.Elements) do
                            if ElementIndex > 1 then
                                AnimateElement(Group.Dividers[ElementIndex - 1], math.min((ElementIndex - 1) * 0.012, 0.06))
                            end
                            AnimateElement(Element.Motion, math.min((ElementIndex - 1) * 0.012 + 0.01, 0.07))
                        end
                    end
                end)
            end
        end
    end

    self.ConfigNames = ConfigNames
    self.ConfigRecords = {}
    self.AutoLoadConfigName = AutoLoadConfigName
    EnsureConfigFolders()
    self:_LoadConfigStorage()
    AutoLoadConfigName = self.AutoLoadConfigName

    CreateSettingsButton()
    CreateConfigButton()
    CreateConfigMenus()
    CreateCategoryButton()
    CreateBreadcrumb()
    CreateGroupArea()

    local function SearchMatches(Query, Tab, Category, Group)
        if Query == "" then return true end
        local CompactQuery = Query:gsub("%s+", "")

        local function EditDistance(Left, Right)
            local Previous = {}
            for Index = 0, #Right do
                Previous[Index] = Index
            end

            for Row = 1, #Left do
                local Current = {[0] = Row}
                for Column = 1, #Right do
                    local Cost = Left:sub(Row, Row) == Right:sub(Column, Column) and 0 or 1
                    Current[Column] = math.min(
                        Current[Column - 1] + 1,
                        Previous[Column] + 1,
                        Previous[Column - 1] + Cost
                    )
                end
                Previous = Current
            end

            return Previous[#Right]
        end

        local function Contains(Value)
            if type(Value) ~= "string" then return false end
            local CompactValue = string.lower(Value):gsub("%s+", "")
            if string.find(CompactValue, CompactQuery, 1, true) then
                return true
            end
            if #CompactQuery < 4 then return false end

            local AllowedDistance = #CompactQuery >= 8 and 2 or 1
            for Start = 1, math.max(1, #CompactValue - #CompactQuery + 1) do
                local Candidate = CompactValue:sub(Start, Start + #CompactQuery - 1)
                if #Candidate == #CompactQuery and EditDistance(Candidate, CompactQuery) <= AllowedDistance then
                    return true
                end
            end

            return #CompactValue < #CompactQuery
                and EditDistance(CompactValue, CompactQuery) <= AllowedDistance
        end

        if Contains(Tab.Name) or Contains(Category.Name) or Contains(Group.Name) then
            return true
        end

        for _, Element in ipairs(Group.Elements) do
            if Contains(Element.Type) or (Element.Label and Contains(Element.Label.Text)) then
                return true
            end
        end

        return false
    end

    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local Query = string.lower(SearchInput.Text:gsub("^%s+", ""):gsub("%s+$", ""))
        local FirstTab
        local FirstCategory
        SearchUpdating = true

        for _, Tab in ipairs(Tabs) do
            for _, Category in ipairs(Tab.Categories) do
                for _, Group in ipairs(Category.Groups) do
                    if not FirstTab and SearchMatches(Query, Tab, Category, Group) then
                        FirstTab = Tab
                        FirstCategory = Category
                    end
                end
            end
        end

        if Query ~= "" and FirstTab then
            for _, Tab in ipairs(Tabs) do
                Tab.Selected = Tab == FirstTab
                SetTabState(Tab, Tab.Selected, false)
            end
            ActiveTab = FirstTab.Name
            self.ActiveTab = FirstTab.Name
            FirstTab.ActiveCategoryIndex = FirstCategory.Index
            if UpdateCategoryButton then
                UpdateCategoryButton(FirstTab)
            end
        elseif Query == "" then
            local CurrentTab
            for _, Tab in ipairs(Tabs) do
                if Tab.Selected then
                    CurrentTab = Tab
                    break
                end
            end
            if CurrentTab and UpdateCategoryButton then
                UpdateCategoryButton(CurrentTab)
            end
        end

        local HasVisibleGroup = false
        for _, Tab in ipairs(Tabs) do
            for _, Category in ipairs(Tab.Categories) do
                local CategoryVisible = false
                for _, Group in ipairs(Category.Groups) do
                    local Visible = Query == ""
                        and Tab.Selected
                        and Category == Tab.Categories[Tab.ActiveCategoryIndex or 1]
                        or Query ~= ""
                        and Tab == FirstTab
                        and Category == FirstCategory
                        and SearchMatches(Query, Tab, Category, Group)
                    Group.Wrapper.Visible = Visible
                    CategoryVisible = CategoryVisible or Visible
                    HasVisibleGroup = HasVisibleGroup or Visible
                end
                if Category.ColumnRow then
                    Category.ColumnRow.Visible = CategoryVisible
                end
            end
        end

        if Query ~= "" and not FirstTab then
            GroupArea.Visible = false
        else
            GroupArea.Visible = HasVisibleGroup
        end

        SearchUpdating = false
    end)

    self.CreateTab = function(Window, Options, IconName)
        if type(Options) == "table" then
            IconName = Options.Icon
            Options = Options.Name
        end

        local Name = Options or "Tab"
        local TabIndex = #Tabs
        local Tab = CreateTab(Name, IconName, 119 + (TabIndex * 42), TabIndex == 0)
        Tab.Library = Window

        function Tab:CreateCategory(CategoryName)
            local Category = {
                Name = CategoryName or "Category",
                Tab = self,
                Index = #self.Categories + 1,
                Groups = {},
                ColumnRow = nil,
                ColumnFrames = nil,
                ColumnBottomMask = nil,
                ColumnMasks = nil,
                ColumnMaskUpdates = nil,
            }
            table.insert(self.Categories, Category)

            function Category:CreateGroup(Options)
                if type(Options) == "string" then
                    Options = {Name = Options}
                end
                Options = Options or {}

                local GroupName = Options.Name or "Group"
                local Column = Options.Column or "Full"
                local GroupParent = GroupArea
                local GroupSize = UDim2.new(1, 0, 0, 0)
                local ColumnRow = nil
                local ColumnFrames = nil

                if Column == "Left" or Column == "Right" then
                    ColumnRow = self.ColumnRow
                    if not ColumnRow then
                        ColumnRow = UI.Create("Frame", {
                            Name = "Columns",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            LayoutOrder = #self.Groups + 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            Visible = false,
                            ZIndex = 2,
                        }, GroupArea)
                        UI.Create("UIListLayout", {
                            FillDirection = Enum.FillDirection.Horizontal,
                            HorizontalAlignment = Enum.HorizontalAlignment.Left,
                            Padding = UDim.new(0, 8),
                            SortOrder = Enum.SortOrder.LayoutOrder,
                        }, ColumnRow)
                        self.ColumnRow = ColumnRow
                        self.ColumnFrames = {}
                        self.ColumnMasks = {}
                        self.ColumnMaskUpdates = {}
                        self.ColumnBottomMask = UI.Create("Frame", {
                            Name = "ColumnBottomMask",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = GroupArea.Position,
                            Size = GroupArea.Size,
                            Visible = false,
                            ZIndex = 4,
                        }, Main)
                        for _, ColumnName in ipairs({"Left", "Right"}) do
                            local ColumnFrame = UI.Create("ScrollingFrame", {
                                Name = ColumnName .. "Column",
                                Active = true,
                                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                CanvasSize = UDim2.new(0, 0, 0, 0),
                                ClipsDescendants = true,
                                ScrollingDirection = Enum.ScrollingDirection.Y,
                                ScrollBarImageColor3 = self.Tab.Library.Theme.Settings.Text,
                                ScrollBarImageTransparency = 0.7,
                                ScrollBarThickness = 3,
                                Size = UDim2.new(0.5, -4, 1, 0),
                                ZIndex = 2,
                            }, ColumnRow)
                            UI.Create("UIPadding", {
                                PaddingRight = UDim.new(0, 10),
                            }, ColumnFrame)
                            UI.Create("UIListLayout", {
                                Padding = UDim.new(0, 10),
                                SortOrder = Enum.SortOrder.LayoutOrder,
                            }, ColumnFrame)
                            self.ColumnFrames[ColumnName] = ColumnFrame

                            local ColumnMask = UI.Create("Frame", {
                                Name = ColumnName .. "Mask",
                                AnchorPoint = Vector2.new(0, 1),
                                BackgroundColor3 = self.Tab.Library.Theme.Window.Background,
                                BackgroundTransparency = 0,
                                BorderSizePixel = 0,
                                Position = UDim2.new(ColumnName == "Right" and 0.5 or 0, 0, 1, 0),
                                Size = UDim2.new(0.5, 0, 0, 0),
                                ZIndex = 4,
                            }, self.ColumnBottomMask)
                            self.ColumnMasks[ColumnName] = ColumnMask

                            local ColumnMaskTweenInfo = TweenInfo.new(
                                0.08,
                                Enum.EasingStyle.Sine,
                                Enum.EasingDirection.Out
                            )
                            local ColumnMaskTargetHeight = 0
                            local function UpdateColumnMask()
                                local MaximumScroll = math.max(
                                    0,
                                    ColumnFrame.AbsoluteCanvasSize.Y - ColumnFrame.AbsoluteWindowSize.Y
                                )
                                local ShouldShow = MaximumScroll > 0
                                    and ColumnFrame.CanvasPosition.Y < MaximumScroll - 8
                                local TargetHeight = ShouldShow and 14 or 0
                                if TargetHeight == ColumnMaskTargetHeight then
                                    return
                                end
                                ColumnMaskTargetHeight = TargetHeight
                                TweenService:Create(ColumnMask, ColumnMaskTweenInfo, {
                                    Size = UDim2.new(0.5, 0, 0, TargetHeight),
                                }):Play()
                            end
                            table.insert(self.ColumnMaskUpdates, UpdateColumnMask)
                            ColumnFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateColumnMask)
                            ColumnFrame:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(UpdateColumnMask)
                            ColumnFrame:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(UpdateColumnMask)
                        end
                    end
                    ColumnFrames = self.ColumnFrames
                    GroupParent = ColumnFrames[Column]
                    GroupSize = UDim2.new(1, 0, 0, 0)
                    self.ColumnFrames = ColumnFrames
                end

                local GroupWrapper = UI.Create("Frame", {
                    Name = GroupName .. "Wrapper",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = #self.Groups + 1,
                    Size = GroupSize,
                    Visible = false,
                    ZIndex = 2,
                }, GroupParent)
                local GroupMotion = UI.Create("Frame", {
                    Name = "Motion",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.new(1, 0, 0, 0),
                }, GroupWrapper)
                UI.Create("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, GroupMotion)

                local GroupTitle = UI.Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    Text = GroupName,
                    TextColor3 = self.Tab.Library.Theme.Groups.Title,
                    TextSize = 14,
                    TextTransparency = 0.6,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Center,
                }, GroupMotion)

                local GroupFrame = UI.Create("Frame", {
                    Name = "Panel",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundColor3 = self.Tab.Library.Theme.Groups.Background,
                    BorderSizePixel = 0,
                    LayoutOrder = 2,
                    Size = UDim2.new(1, 0, 0, 0),
                    ZIndex = 2,
                }, GroupMotion)
                UI.Corner(GroupFrame, 10)
                UI.Create("UIPadding", {
                    PaddingTop = UDim.new(0, 12),
                    PaddingBottom = UDim.new(0, 12),
                    PaddingLeft = UDim.new(0, 14),
                    PaddingRight = UDim.new(0, 14),
                }, GroupFrame)
                UI.Create("UIListLayout", {
                    Padding = UDim.new(0, 10),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, GroupFrame)

                local GroupContent = UI.Create("Frame", {
                    Name = "Content",
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    LayoutOrder = 2,
                    Size = UDim2.new(1, 0, 0, 0),
                }, GroupFrame)
                UI.Create("UIListLayout", {
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                }, GroupContent)
                local Group = {
                    Name = GroupName,
                    Column = Column,
                    Tab = self.Tab,
                    ColumnRow = ColumnRow,
                    Wrapper = GroupWrapper,
                    Motion = GroupMotion,
                    Frame = GroupFrame,
                    Title = GroupTitle,
                    Content = GroupContent,
                    Elements = {},
                    Dividers = {},
                }

                function Group:CreateMotionContainer(Name, LayoutOrder)
                    return UI.Create("Frame", {
                        Name = Name,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = LayoutOrder,
                        Size = UDim2.new(1, 0, 0, 0),
                    }, self.Content)
                end

                function Group:CreateDivider(LayoutOrder)
                    local Motion = self:CreateMotionContainer("DividerMotion", LayoutOrder)
                    local Divider = UI.Create("Frame", {
                        Name = "Divider",
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.Divider,
                        BorderSizePixel = 0,
                        LayoutOrder = LayoutOrder or (#self.Elements * 2),
                        Size = UDim2.new(1, 0, 0, 1),
                    }, Motion)
                    table.insert(self.Dividers, Divider)
                    return Divider
                end

                function Group:CreateToggle(Options)
                    if type(Options) == "string" then
                        Options = {Name = Options}
                    end
                    Options = Options or {}

                    if #self.Elements > 0 then
                        self:CreateDivider(#self.Elements * 2)
                    end

                    local ToggleName = Options.Name or "Toggle"
                    local Motion = self:CreateMotionContainer(ToggleName .. "Motion", #self.Elements * 2 + 1)
                    local Toggle = UI.Create("TextButton", {
                        Name = ToggleName,
                        Active = true,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        Text = "",
                    }, Motion)

                    local Box = UI.Create("Frame", {
                        Name = "Box",
                        BackgroundColor3 = Options.Default and self.Tab.Library.Theme.Accent or self.Tab.Library.Theme.Groups.ToggleBackground,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(0, 4),
                        Size = UDim2.fromOffset(20, 20),
                    }, Toggle)
                    UI.Corner(Box, 5)

                    local Check = UI.Create("ImageLabel", {
                        Name = "Check",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Image = FallbackIcons.check or GetIcon("check"),
                        ImageColor3 = Color3.new(0, 0, 0),
                        ImageTransparency = Options.Default and 0 or 1,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromOffset(14, 14),
                    }, Box)

                    local Label = UI.Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(30, 0),
                        Size = UDim2.new(1, Options.Keybind and -50 or -30, 1, 0),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = ToggleName,
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextTransparency = Options.Default and 0 or 0.6,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Toggle)

                    local KeybindButton
                    local KeybindPopup
                    local KeybindPopupContent
                    local KeybindDimmer
                    local CaptureButton
                    local KeybindOpen = false
                    local CapturingKey = false
                    local SuppressNextBoundInput = false
                    local BoundInput
                    local KeybindTitle = ToggleName:gsub("^Enable%s+", "") .. " Keybind"
                    local function StopKeyCapture()
                        CapturingKey = false
                    end

                    if Options.Keybind == true then
                        KeybindButton = UI.Create("ImageButton", {
                            Name = "Keybind",
                            Active = true,
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Image = FallbackIcons.settings or GetIcon("settings"),
                            ImageColor3 = self.Tab.Library.Theme.Groups.Title,
                            ImageTransparency = 0.6,
                            Position = UDim2.new(1, -20, 0, 5),
                            Size = UDim2.fromOffset(18, 18),
                        }, Toggle)

                        KeybindPopup = UI.Create("Frame", {
                            Name = "KeybindPopup",
                            BackgroundColor3 = self.Tab.Library.Theme.Settings.Background,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            Position = UDim2.fromOffset(0, 0),
                            Size = UDim2.fromOffset(176, 82),
                            Visible = false,
                            ZIndex = 70,
                        }, self.Tab.Library.Main)
                        UI.Corner(KeybindPopup, 8)

                        KeybindDimmer = UI.Create("Frame", {
                            Name = "KeybindDimmer",
                            BackgroundColor3 = Color3.new(0, 0, 0),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 1),
                            Visible = false,
                            ZIndex = 40,
                        }, self.Tab.Library.Main)
                        UI.Corner(KeybindDimmer, 14)

                        KeybindPopupContent = UI.Create("CanvasGroup", {
                            Name = "Content",
                            BackgroundTransparency = 1,
                            GroupTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 71,
                        }, KeybindPopup)

                        UI.Create("TextLabel", {
                            Name = "Title",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(10, 8),
                            Size = UDim2.new(1, -20, 0, 20),
                            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            Text = KeybindTitle,
                            TextColor3 = self.Tab.Library.Theme.Settings.Text,
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            ZIndex = 72,
                        }, KeybindPopupContent)

                        CaptureButton = UI.Create("TextButton", {
                            Name = "Capture",
                            Active = true,
                            AutoButtonColor = false,
                            BackgroundColor3 = self.Tab.Library.Theme.Groups.ToggleBackground,
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(10, 38),
                            Size = UDim2.new(1, -20, 0, 30),
                            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            Text = "Click to set key",
                            TextColor3 = self.Tab.Library.Theme.Settings.Text,
                            TextSize = 12,
                            ZIndex = 72,
                        }, KeybindPopupContent)
                        UI.Corner(CaptureButton, 5)
                    end

                    local Item = {
                        Type = "Toggle",
                        Name = ToggleName,
                        DefaultValue = Options.Default == true,
                        Motion = Toggle,
                        Button = Toggle,
                        Box = Box,
                        Check = Check,
                        Label = Label,
                        Value = Options.Default == true,
                        KeybindButton = KeybindButton,
                        KeybindPopup = KeybindPopup,
                        KeybindDimmer = KeybindDimmer,
                        CaptureButton = CaptureButton,
                        KeybindCapture = CaptureButton,
                        BoundInput = nil,
                    }
                    table.insert(self.Elements, Item)
                    if KeybindButton then
                        table.insert(self.Tab.Library.KeybindItems, Item)
                    end

                    local SetValue
                    local function SetKeybindPopup(Open)
                        if not KeybindPopup or KeybindOpen == Open then return end
                        KeybindOpen = Open
                        local MainFrame = self.Tab.Library.Main
                        local MainScale = MainFrame:FindFirstChildOfClass("UIScale")
                        local Scale = MainScale and MainScale.Scale or 1

                        if Open then
                            local ButtonPosition = KeybindButton.AbsolutePosition
                            local MainPosition = MainFrame.AbsolutePosition
                            local ButtonSize = KeybindButton.AbsoluteSize
                            local X = (ButtonPosition.X - MainPosition.X + ButtonSize.X + 8 * Scale) / Scale
                            local Y = (ButtonPosition.Y - MainPosition.Y + ButtonSize.Y + 6 * Scale) / Scale
                            KeybindPopup.Position = UDim2.fromOffset(X, Y)
                            KeybindPopup.BackgroundTransparency = 1
                            KeybindPopupContent.GroupTransparency = 1
                            KeybindPopup.Visible = true
                            KeybindDimmer.BackgroundTransparency = 1
                            KeybindDimmer.Visible = true
                            TweenService:Create(KeybindDimmer, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0.78,
                            }):Play()
                            TweenService:Create(KeybindPopup, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0,
                            }):Play()
                            TweenService:Create(KeybindPopupContent, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                GroupTransparency = 0,
                            }):Play()
                        else
                            StopKeyCapture()
                            TweenService:Create(KeybindPopup, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 1,
                            }):Play()
                            TweenService:Create(KeybindPopupContent, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                GroupTransparency = 1,
                            }):Play()
                            TweenService:Create(KeybindDimmer, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 1,
                            }):Play()
                            task.delay(0.16, function()
                                if not KeybindOpen then
                                    KeybindPopup.Visible = false
                                    KeybindDimmer.Visible = false
                                end
                            end)
                        end
                    end

                    local function GetBoundInputName(Input)
                        if Input.UserInputType == Enum.UserInputType.Keyboard then
                            return Input.KeyCode.Name
                        end
                        return Input.UserInputType.Name:gsub("MouseButton", "Mouse ")
                    end

                    if KeybindButton then
                        KeybindButton.Activated:Connect(function()
                            SetKeybindPopup(not KeybindOpen)
                        end)

                        CaptureButton.Activated:Connect(function()
                            CapturingKey = true
                            CaptureButton.Text = "..."
                        end)

                        UserInputService.InputBegan:Connect(function(Input)
                            if not KeybindOpen or not CapturingKey then return end
                            if Input.UserInputType ~= Enum.UserInputType.Keyboard
                                and Input.UserInputType ~= Enum.UserInputType.MouseButton1
                                and Input.UserInputType ~= Enum.UserInputType.MouseButton2
                                and Input.UserInputType ~= Enum.UserInputType.MouseButton3 then
                                return
                            end

                            if Input.UserInputType == Enum.UserInputType.Keyboard
                                and (Input.KeyCode == Enum.KeyCode.Escape or Input.KeyCode == Enum.KeyCode.Backspace) then
                                BoundInput = nil
                                Item.BoundInput = nil
                                StopKeyCapture()
                                SuppressNextBoundInput = false
                                CaptureButton.Text = "Click to set key"
                                return
                            end

                            BoundInput = Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode or Input.UserInputType
                            Item.BoundInput = BoundInput
                            StopKeyCapture()
                            SuppressNextBoundInput = true
                            CaptureButton.Text = GetBoundInputName(Input)
                        end)

                        UserInputService.InputBegan:Connect(function(Input)
                            if not KeybindOpen or CapturingKey then return end
                            local Position = Input.Position
                            local PopupPosition = KeybindPopup.AbsolutePosition
                            local PopupSize = KeybindPopup.AbsoluteSize
                            local Inside = Position.X >= PopupPosition.X
                                and Position.X <= PopupPosition.X + PopupSize.X
                                and Position.Y >= PopupPosition.Y
                                and Position.Y <= PopupPosition.Y + PopupSize.Y
                            local ButtonPosition = KeybindButton.AbsolutePosition
                            local ButtonSize = KeybindButton.AbsoluteSize
                            local OnButton = Position.X >= ButtonPosition.X
                                and Position.X <= ButtonPosition.X + ButtonSize.X
                                and Position.Y >= ButtonPosition.Y
                                and Position.Y <= ButtonPosition.Y + ButtonSize.Y
                            if not Inside and not OnButton and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                                SetKeybindPopup(false)
                            end
                        end)
                    end

                    SetValue = function(Value, Animated)
                        Item.Value = Value == true
                        local TweenInfoValue = Animated and TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) or TweenInfo.new(0)
                        local Theme = self.Tab.Library.Theme
                        local CheckPosition = UDim2.fromScale(0.5, 0.5)

                        if Item.Value then
                            Check.Position = UDim2.new(0.5, 0, 0.5, Animated and 4 or 0)
                        elseif Animated then
                            CheckPosition = UDim2.new(0.5, 0, 0.5, 4)
                        end

                        TweenService:Create(Box, TweenInfoValue, {
                            BackgroundColor3 = Item.Value and Theme.Accent or Theme.Groups.ToggleBackground,
                        }):Play()
                        TweenService:Create(Check, TweenInfoValue, {
                            ImageTransparency = Item.Value and 0 or 1,
                            Position = CheckPosition,
                        }):Play()
                        TweenService:Create(Label, TweenInfoValue, {
                            TextTransparency = Item.Value and 0 or 0.6,
                        }):Play()

                        if self.Tab.Library.UpdateKeybindList then
                            self.Tab.Library.UpdateKeybindList()
                        end

                        if type(Options.Callback) == "function" then
                            Options.Callback(Item.Value)
                        end
                        
                        -- Auto-save after callback
                        if self.Tab and self.Tab.Library and self.Tab.Library.AutoSave then
                            task.defer(function()
                                self.Tab.Library:AutoSave()
                            end)
                        end
                    end

                    if KeybindButton then
                        UserInputService.InputBegan:Connect(function(Input)
                            if not BoundInput or CapturingKey then return end
                            local CurrentInput = Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode or Input.UserInputType
                            if SuppressNextBoundInput then
                                SuppressNextBoundInput = false
                                return
                            end
                            if CurrentInput == BoundInput then
                                SetValue(not Item.Value, false)
                            end
                        end)
                    end

                    function Item:Set(Value)
                        SetValue(Value, true)
                    end

                    function Item:Get()
                        return Item.Value
                    end

                    function Item:SetKeybind(Value)
                        BoundInput = Value
                        Item.BoundInput = Value
                        if CaptureButton then
                            CaptureButton.Text = Value and Value.Name:gsub("MouseButton", "Mouse ") or "Click to set key"
                        end
                    end

                    Toggle.Activated:Connect(function()
                        SetValue(not Item.Value, true)
                    end)

                    if Options.ColorPicker == true then
                        local ColorItem = self:CreateColorPicker({
                            Name = ToggleName .. " Color",
                            Default = Options.ColorDefault,
                            Callback = Options.ColorCallback,
                        })
                        local PickerButton = ColorItem.Button
                        local PickerMotion = PickerButton.Parent
                        local LastDivider = self.Dividers[#self.Dividers]
                        PickerMotion.Visible = false
                        if LastDivider and LastDivider.Parent then
                            LastDivider.Parent.Visible = false
                        end
                        for Index, Element in ipairs(self.Elements) do
                            if Element == ColorItem then
                                table.remove(self.Elements, Index)
                                break
                            end
                        end

                        Box.AnchorPoint = Vector2.new(0, 0)
                        Box.Position = UDim2.fromOffset(0, 4)
                        Label.Size = UDim2.new(1, -70, 1, 0)
                        PickerButton.Parent = Toggle
                        PickerButton.AnchorPoint = Vector2.new(1, 0)
                        PickerButton.Position = UDim2.new(1, 0, 0, 0)
                        PickerButton.Size = UDim2.fromOffset(28, 28)
                        PickerButton.ZIndex = 3
                        ColorItem.Label.Visible = false
                        ColorItem.Ring.Position = UDim2.new(1, -14, 0.5, 0)
                        ColorItem.Preview.Position = UDim2.new(1, -14, 0.5, 0)
                        Item.ColorPicker = ColorItem
                    end

                    return Item
                end

                function Group:CreateSlider(Options)
                    Options = Options or {}
                    if #self.Elements > 0 then
                        self:CreateDivider(#self.Elements * 2)
                    end

                    local SliderName = Options.Name or "Slider"
                    local Minimum = tonumber(Options.Min) or 0
                    local Maximum = tonumber(Options.Max) or 100
                    local Step = tonumber(Options.Step) or 1
                    local Suffix = Options.Suffix or ""
                    local InitialValue = math.clamp(tonumber(Options.Default) or Minimum, Minimum, Maximum)
                    local Motion = self:CreateMotionContainer(SliderName .. "Motion", #self.Elements * 2 + 1)
                    local Slider = UI.Create("TextButton", {
                        Name = SliderName,
                        Active = true,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 42),
                        Text = "",
                    }, Motion)

                    local Label = UI.Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.new(1, -48, 0, 20),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = SliderName,
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextTransparency = 0.6,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Slider)

                    local ValueLabel = UI.Create("TextLabel", {
                        Name = "Value",
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.fromOffset(48, 20),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Slider)

                    local Track = UI.Create("Frame", {
                        Name = "Track",
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.SliderBackground,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 29),
                        Size = UDim2.new(1, 0, 0, 7),
                    }, Slider)
                    UI.Corner(Track, 3)

                    local Fill = UI.Create("Frame", {
                        Name = "Fill",
                        BackgroundColor3 = self.Tab.Library.Theme.Accent,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 0, 1, 0),
                    }, Track)
                    UI.Corner(Fill, 3)
                    local Gradient = UI.Create("UIGradient", {
                        Color = ColorSequence.new(
                            Color3.new(1, 1, 1),
                            Color3.fromRGB(205, 205, 255)
                        ),
                        Rotation = 0,
                    }, Fill)

                    local ValueBubble = UI.Create("TextLabel", {
                        Name = "ValueBubble",
                        AnchorPoint = Vector2.new(0.5, 1),
                        BackgroundColor3 = Color3.fromRGB(27, 26, 31),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, -8),
                        Size = UDim2.fromOffset(28, 22),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = "",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextTransparency = 1,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        ZIndex = 3,
                    }, Track)
                    UI.Corner(ValueBubble, 7)

                    local Knob = UI.Create("Frame", {
                        Name = "Knob",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.fromOffset(10, 10),
                        ZIndex = 2,
                    }, Track)
                    UI.Corner(Knob, 5)

                    local Item = {
                        Type = "Slider",
                        Name = SliderName,
                        Motion = Slider,
                        Button = Slider,
                        Track = Track,
                        Fill = Fill,
                        Gradient = Gradient,
                        ValueBubble = ValueBubble,
                        Knob = Knob,
                        Label = Label,
                        ValueLabel = ValueLabel,
                        Value = InitialValue,
                        DefaultValue = InitialValue,
                    }
                    table.insert(self.Elements, Item)

                    local function FormatValue(Value)
                        if Step >= 1 then
                            return tostring(math.floor(Value + 0.5)) .. Suffix
                        end
                        return string.format("%.2f", Value):gsub("0+$", ""):gsub("%.$", "") .. Suffix
                    end

                    local function FormatRawValue(Value)
                        if Step >= 1 then
                            return tostring(math.floor(Value + 0.5))
                        end
                        return string.format("%.2f", Value):gsub("0+$", ""):gsub("%.$", "")
                    end

                    local function SetValue(Value, Animated)
                        local Range = Maximum - Minimum
                        local Ratio = Range == 0 and 0 or math.clamp((Value - Minimum) / Range, 0, 1)
                        Item.Value = Minimum + (Maximum - Minimum) * Ratio
                        if Step > 0 then
                            Item.Value = math.clamp(math.floor(Item.Value / Step + 0.5) * Step, Minimum, Maximum)
                            Ratio = Range == 0 and 0 or (Item.Value - Minimum) / Range
                        end

                        local VisualRatio = math.max(Ratio, 0.025)
                        local TweenInfoValue = Animated and TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) or TweenInfo.new(0)
                        TweenService:Create(Fill, TweenInfoValue, {
                            Size = UDim2.new(VisualRatio, 0, 1, 0),
                        }):Play()
                        TweenService:Create(Knob, TweenInfoValue, {
                            Position = UDim2.new(VisualRatio, 0, 0.5, 0),
                        }):Play()
                        TweenService:Create(ValueBubble, TweenInfoValue, {
                            Position = UDim2.new(VisualRatio, 0, 0, -8),
                        }):Play()
                        ValueLabel.Text = FormatValue(Item.Value)
                        ValueBubble.Text = FormatRawValue(Item.Value)

                        if Animated and type(Options.Callback) == "function" then
                            Options.Callback(Item.Value)
                            -- Auto-save after slider change
                            task.defer(function()
                                self.Tab.Library:AutoSave()
                            end)
                        end
                    end

                    SetValue(InitialValue, false)

                    local function UpdateFromInput(Input)
                        local Ratio = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        SetValue(Minimum + (Maximum - Minimum) * Ratio, true)
                    end

                    function Item:Set(Value)
                        SetValue(tonumber(Value) or Minimum, true)
                    end

                    function Item:Get()
                        return Item.Value
                    end

                    ValueLabel.Text = FormatValue(Item.Value)
                    local Dragging = false
                    Slider.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Dragging = true
                            TweenService:Create(Knob, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0,
                            }):Play()
                            TweenService:Create(ValueBubble, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0,
                                TextTransparency = 0,
                            }):Play()
                            UpdateFromInput(Input)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(Input)
                        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateFromInput(Input)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Dragging = false
                            TweenService:Create(Knob, TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 1,
                            }):Play()
                            TweenService:Create(ValueBubble, TweenInfo.new(0.14, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 1,
                                TextTransparency = 1,
                            }):Play()
                        end
                    end)

                    return Item
                end

                function Group:CreateColorPicker(Options)
                    Options = Options or {}
                    local InitialColor = typeof(Options.Default) == "Color3"
                        and Options.Default
                        or self.Tab.Library.Theme.Accent
                    if #self.Elements > 0 then
                        self:CreateDivider(#self.Elements * 2)
                    end

                    local PickerName = Options.Name or "Color"
                    local HasCheckbox = Options.Checkbox == true or Options.WithCheckbox == true
                    local CheckboxValue = Options.CheckboxDefault ~= false
                    local Motion = self:CreateMotionContainer(PickerName .. "Motion", #self.Elements * 2 + 1)
                    local Button = UI.Create("TextButton", {
                        Name = PickerName,
                        Active = true,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 28),
                        Text = "",
                    }, Motion)
                    local Label = UI.Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, HasCheckbox and -60 or -32, 1, 0),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = PickerName,
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Button)
                    local Ring = UI.Create("Frame", {
                        Name = "Ring",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = InitialColor,
                        BackgroundTransparency = 0.7,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, HasCheckbox and -42 or -13, 0.5, 0),
                        Size = UDim2.fromOffset(26, 26),
                    }, Button)
                    UI.Corner(Ring, 13)

                    local Preview = UI.Create("Frame", {
                        Name = "Preview",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = InitialColor,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, HasCheckbox and -42 or -13, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                    }, Button)
                    UI.Corner(Preview, 10)

                    local PickerCheckboxButton
                    local PickerCheckbox
                    local PickerCheckboxCheck
                    if HasCheckbox then
                        PickerCheckboxButton = UI.Create("TextButton", {
                            Name = "CheckboxButton",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.new(1, -24, 0, 0),
                            Size = UDim2.fromOffset(24, 28),
                            Text = "",
                            ZIndex = 4,
                        }, Button)
                        PickerCheckbox = UI.Create("Frame", {
                            Name = "Checkbox",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = CheckboxValue and self.Tab.Library.Theme.Accent or self.Tab.Library.Theme.Groups.ToggleBackground,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.fromOffset(20, 20),
                            ZIndex = 5,
                        }, PickerCheckboxButton)
                        UI.Corner(PickerCheckbox, 5)
                        PickerCheckboxCheck = UI.Create("ImageLabel", {
                            Name = "Check",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Image = GetIcon("check"),
                            ImageColor3 = Color3.new(0, 0, 0),
                            ImageTransparency = CheckboxValue and 0 or 1,
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(14, 14),
                            ZIndex = 6,
                        }, PickerCheckbox)
                    end

                    local Popup = UI.Create("Frame", {
                        Name = "ColorPopup",
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.Background,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.fromOffset(188, 220),
                        Visible = false,
                        ZIndex = 55,
                    }, self.Tab.Library.Main)
                    UI.Corner(Popup, 8)
                    local PopupContent = UI.Create("CanvasGroup", {
                        Name = "Content",
                        BackgroundTransparency = 1,
                        GroupTransparency = 1,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 56,
                    }, Popup)

                    local ColorSquare = UI.Create("Frame", {
                        Name = "ColorSquare",
                        Active = true,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Position = UDim2.fromOffset(12, 12),
                        Size = UDim2.fromOffset(140, 140),
                        ZIndex = 57,
                    }, PopupContent)
                    UI.Corner(ColorSquare, 6)
                    local ColorSquareGradient = UI.Create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(1, 1, 1), self.Tab.Library.Theme.Accent),
                    }, ColorSquare)
                    local ValueOverlay = UI.Create("Frame", {
                        Active = true,
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        BackgroundTransparency = 0,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Size = UDim2.fromScale(1, 1),
                        ZIndex = 58,
                    }, ColorSquare)
                    UI.Corner(ValueOverlay, 6)
                    UI.Create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 1),
                            NumberSequenceKeypoint.new(1, 0),
                        }),
                        Rotation = 90,
                    }, ValueOverlay)
                    local ColorCursor = UI.Create("Frame", {
                        Name = "Cursor",
                        Active = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0),
                        Size = UDim2.fromOffset(12, 12),
                        ZIndex = 60,
                    }, ColorSquare)
                    UI.Corner(ColorCursor, 6)
                    local ColorCursorShadow = UI.Stroke(ColorCursor, Color3.new(0, 0, 0), 1)
                    ColorCursorShadow.Transparency = 0.35

                    local HueBar = UI.Create("Frame", {
                        Name = "HueBar",
                        Active = true,
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(160, 12),
                        Size = UDim2.fromOffset(12, 140),
                        ZIndex = 57,
                    }, PopupContent)
                    UI.Corner(HueBar, 6)
                    UI.Create("UIGradient", {
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                            ColorSequenceKeypoint.new(1 / 6, Color3.fromRGB(255, 255, 0)),
                            ColorSequenceKeypoint.new(2 / 6, Color3.fromRGB(0, 255, 0)),
                            ColorSequenceKeypoint.new(3 / 6, Color3.fromRGB(0, 255, 255)),
                            ColorSequenceKeypoint.new(4 / 6, Color3.fromRGB(0, 0, 255)),
                            ColorSequenceKeypoint.new(5 / 6, Color3.fromRGB(255, 0, 255)),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
                        }),
                        Rotation = 90,
                    }, HueBar)
                    local HueCursor = UI.Create("Frame", {
                        Name = "Cursor",
                        Active = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.fromOffset(10, 10),
                        ZIndex = 60,
                    }, HueBar)
                    UI.Corner(HueCursor, 6)
                    local HueCursorShadow = UI.Stroke(HueCursor, Color3.new(0, 0, 0), 1)
                    HueCursorShadow.Transparency = 0.35

                    local AlphaBar = UI.Create("Frame", {
                        Name = "AlphaBar",
                        Active = true,
                        BackgroundColor3 = self.Tab.Library.Theme.Accent,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(12, 164),
                        Size = UDim2.fromOffset(160, 11),
                        ZIndex = 57,
                    }, PopupContent)
                    UI.Corner(AlphaBar, 4)
                    local AlphaGradient = UI.Create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
                        Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, 0),
                            NumberSequenceKeypoint.new(1, 1),
                        }),
                    }, AlphaBar)
                    local AlphaCursor = UI.Create("Frame", {
                        Name = "Cursor",
                        Active = true,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.fromOffset(10, 10),
                        ZIndex = 60,
                    }, AlphaBar)
                    UI.Corner(AlphaCursor, 6)
                    local AlphaCursorShadow = UI.Stroke(AlphaCursor, Color3.new(0, 0, 0), 1)
                    AlphaCursorShadow.Transparency = 0.35

                    local HexInput = UI.Create("TextBox", {
                        Name = "HexInput",
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.ToggleBackground,
                        BorderSizePixel = 0,
                        ClearTextOnFocus = false,
                        Position = UDim2.fromOffset(12, 184),
                        Size = UDim2.fromOffset(160, 25),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = "#8686FF",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        ZIndex = 57,
                    }, PopupContent)
                    UI.Corner(HexInput, 6)
                    UI.Create("UIPadding", {
                        PaddingLeft = UDim.new(0, 8),
                    }, HexInput)

                    local PickerDimmer = UI.Create("Frame", {
                        Name = "ColorPickerDimmer",
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        ZIndex = 40,
                    }, self.Tab.Library.Main)
                    UI.Corner(PickerDimmer, 14)

                    local PickerOverlay = UI.Create("TextButton", {
                        Name = "ColorPickerOverlay",
                        Active = false,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Text = "",
                        Visible = false,
                        ZIndex = 41,
                    }, self.Tab.Library.Main)
                    UI.Corner(PickerOverlay, 14)

                    local PickerOpen = false
                    local function SetPickerOpen(Open)
                        if PickerOpen == Open then return end
                        PickerOpen = Open
                        local MainFrame = self.Tab.Library.Main
                        local Scale = self.Tab.Library.MainScale.Scale
                        if Open then
                            MainFrame.ZIndex = 10
                            local ButtonPosition = Button.AbsolutePosition
                            local MainPosition = MainFrame.AbsolutePosition
                            local ButtonSize = Button.AbsoluteSize
                            local X = (ButtonPosition.X - MainPosition.X + ButtonSize.X + 8 * Scale) / Scale
                            local Y = (ButtonPosition.Y - MainPosition.Y - 8 * Scale) / Scale
                            Popup.Position = UDim2.fromOffset(X, Y)
                            Popup.BackgroundTransparency = 1
                            PopupContent.GroupTransparency = 1
                            Popup.Visible = true
                            PickerDimmer.BackgroundTransparency = 1
                            PickerDimmer.Visible = true
                            PickerOverlay.Visible = true
                            TweenService:Create(PickerDimmer, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0.78,
                            }):Play()
                            TweenService:Create(Popup, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 0,
                            }):Play()
                            TweenService:Create(PopupContent, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                GroupTransparency = 0,
                            }):Play()
                        else
                            TweenService:Create(Popup, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 1,
                            }):Play()
                            TweenService:Create(PopupContent, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                GroupTransparency = 1,
                            }):Play()
                            TweenService:Create(PickerDimmer, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                                BackgroundTransparency = 1,
                            }):Play()
                            task.delay(0.18, function()
                                if not PickerOpen then
                                    MainFrame.ZIndex = 1
                                    Popup.Visible = false
                                    PickerDimmer.Visible = false
                                    PickerOverlay.Visible = false
                                end
                            end)
                        end
                    end
                    Button.Activated:Connect(function()
                        SetPickerOpen(not PickerOpen)
                    end)
                    UserInputService.InputBegan:Connect(function(Input)
                        if not PickerOpen then return end
                        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end

                        local Position = Input.Position
                        local PopupPosition = Popup.AbsolutePosition
                        local PopupSize = Popup.AbsoluteSize
                        local Inside = Position.X >= PopupPosition.X
                            and Position.X <= PopupPosition.X + PopupSize.X
                            and Position.Y >= PopupPosition.Y
                            and Position.Y <= PopupPosition.Y + PopupSize.Y
                        if not Inside then
                            SetPickerOpen(false)
                        end
                    end)

                    local Item = {
                        Type = "ColorPicker",
                        Name = PickerName,
                        Motion = Button,
                        Button = Button,
                        Label = Label,
                        Ring = Ring,
                        Preview = Preview,
                        CheckboxButton = PickerCheckboxButton,
                        Checkbox = PickerCheckbox,
                        CheckboxCheck = PickerCheckboxCheck,
                        CheckboxValue = CheckboxValue,
                        Popup = Popup,
                        AlphaBar = AlphaBar,
                        HexInput = HexInput,
                        Value = InitialColor,
                        DefaultValue = InitialColor,
                        DefaultCheckboxValue = CheckboxValue,
                    }
                    table.insert(self.Elements, Item)

                    local function SetCheckboxValue(Value, Animated)
                        if not PickerCheckbox then return end
                        Item.CheckboxValue = Value == true
                        local TweenInfoValue = Animated and TweenInfo.new(0.17, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) or TweenInfo.new(0)
                        local CheckPosition = UDim2.fromScale(0.5, 0.5)
                        if Item.CheckboxValue then
                            PickerCheckboxCheck.Position = UDim2.new(0.5, 0, 0.5, Animated and 4 or 0)
                        elseif Animated then
                            CheckPosition = UDim2.new(0.5, 0, 0.5, 4)
                        end
                        TweenService:Create(PickerCheckbox, TweenInfoValue, {
                            BackgroundColor3 = Item.CheckboxValue and self.Tab.Library.Theme.Accent or self.Tab.Library.Theme.Groups.ToggleBackground,
                        }):Play()
                        TweenService:Create(PickerCheckboxCheck, TweenInfoValue, {
                            ImageTransparency = Item.CheckboxValue and 0 or 1,
                            Position = CheckPosition,
                        }):Play()
                        if type(Options.CheckboxCallback) == "function" then
                            Options.CheckboxCallback(Item.CheckboxValue)
                            -- Auto-save after color picker checkbox change
                            task.defer(function()
                                self.Tab.Library:AutoSave()
                            end)
                        end
                    end
                    function Item:SetCheckbox(Value)
                        SetCheckboxValue(Value, true)
                    end
                    function Item:GetCheckbox()
                        return Item.CheckboxValue
                    end
                    if PickerCheckboxButton then
                        PickerCheckboxButton.Activated:Connect(function()
                            SetCheckboxValue(not Item.CheckboxValue, true)
                        end)
                    end

                    local Hue, Saturation, Brightness = Color3.toHSV(Item.Value)
                    local AlphaValue = 0
                    local PickerDragging
                    local UpdatingHex = false

                    local function ToHex(Color)
                        return string.format(
                            "#%02X%02X%02X",
                            math.floor(Color.R * 255 + 0.5),
                            math.floor(Color.G * 255 + 0.5),
                            math.floor(Color.B * 255 + 0.5)
                        )
                    end

                    local function UpdatePickerGradients()
                        local HueColor = Color3.fromHSV(Hue, 1, 1)
                        ColorSquareGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), HueColor)
                        AlphaGradient.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1))
                    end

                    local function ApplyColor(Color, FireCallback)
                        Item.Value = Color
                        local NewHue, NewSaturation, NewBrightness = Color3.toHSV(Color)
                        if NewSaturation > 0.001 and NewBrightness > 0.001 then
                            Hue = NewHue
                        end
                        Saturation = NewSaturation
                        Brightness = NewBrightness
                        UpdatePickerGradients()
                        Ring.BackgroundColor3 = Color
                        Preview.BackgroundColor3 = Color
                        Preview.BackgroundTransparency = AlphaValue
                        AlphaBar.BackgroundColor3 = Color
                        UpdatingHex = true
                        HexInput.Text = ToHex(Color)
                        UpdatingHex = false
                        local CursorTweenInfo = PickerDragging and TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) or TweenInfo.new(0)
                        TweenService:Create(ColorCursor, CursorTweenInfo, {
                            Position = UDim2.fromScale(Saturation, 1 - Brightness),
                        }):Play()
                        TweenService:Create(HueCursor, CursorTweenInfo, {
                            Position = UDim2.new(0.5, 0, Hue, 0),
                        }):Play()
                        TweenService:Create(AlphaCursor, CursorTweenInfo, {
                            Position = UDim2.new(AlphaValue, 0, 0.5, 0),
                        }):Play()
                        if FireCallback and type(Options.Callback) == "function" then
                            Options.Callback(Color)
                            -- Auto-save after color change
                            task.defer(function()
                                self.Tab.Library:AutoSave()
                            end)
                        end
                    end

                    local function UpdateFromPicker(Input, Source)
                        if Source == "Hue" then
                            Hue = math.clamp((Input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                        elseif Source == "Alpha" then
                            AlphaValue = math.clamp((Input.Position.X - AlphaBar.AbsolutePosition.X) / AlphaBar.AbsoluteSize.X, 0, 1)
                            ApplyColor(Item.Value, true)
                            return
                        else
                            Saturation = math.clamp((Input.Position.X - ColorSquare.AbsolutePosition.X) / ColorSquare.AbsoluteSize.X, 0, 1)
                            Brightness = 1 - math.clamp((Input.Position.Y - ColorSquare.AbsolutePosition.Y) / ColorSquare.AbsoluteSize.Y, 0, 1)
                        end
                        ApplyColor(Color3.fromHSV(Hue, Saturation, Brightness), true)
                    end

                    local function BeginPickerDrag(Input, Source)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            PickerDragging = Source
                            UpdateFromPicker(Input, Source)
                        end
                    end

                    ColorSquare.InputBegan:Connect(function(Input)
                        BeginPickerDrag(Input, "Color")
                    end)
                    ValueOverlay.InputBegan:Connect(function(Input)
                        BeginPickerDrag(Input, "Color")
                    end)
                    ColorCursor.InputBegan:Connect(function(Input)
                        BeginPickerDrag(Input, "Color")
                    end)
                    HueBar.InputBegan:Connect(function(Input)
                        BeginPickerDrag(Input, "Hue")
                    end)
                    HueCursor.InputBegan:Connect(function(Input)
                        BeginPickerDrag(Input, "Hue")
                    end)
                    AlphaBar.InputBegan:Connect(function(Input)
                        BeginPickerDrag(Input, "Alpha")
                    end)
                    AlphaCursor.InputBegan:Connect(function(Input)
                        BeginPickerDrag(Input, "Alpha")
                    end)
                    UserInputService.InputChanged:Connect(function(Input)
                        if PickerDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateFromPicker(Input, PickerDragging)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            PickerDragging = nil
                        end
                    end)

                    local function ApplyHexText()
                        if UpdatingHex then return end
                        local Hex = HexInput.Text:gsub("#", "")
                        if #Hex == 6 then
                            local Red = tonumber(Hex:sub(1, 2), 16)
                            local Green = tonumber(Hex:sub(3, 4), 16)
                            local Blue = tonumber(Hex:sub(5, 6), 16)
                            if Red and Green and Blue then
                                ApplyColor(Color3.fromRGB(Red, Green, Blue), true)
                            end
                        end
                    end

                    HexInput:GetPropertyChangedSignal("Text"):Connect(ApplyHexText)
                    HexInput.FocusLost:Connect(function()
                        if #HexInput.Text:gsub("#", "") ~= 6
                            or not tonumber(HexInput.Text:gsub("#", ""):sub(1, 2), 16)
                            or not tonumber(HexInput.Text:gsub("#", ""):sub(3, 4), 16)
                            or not tonumber(HexInput.Text:gsub("#", ""):sub(5, 6), 16) then
                            UpdatingHex = true
                            HexInput.Text = ToHex(Item.Value)
                            UpdatingHex = false
                        end
                    end)

                    ApplyColor(Item.Value, false)

                    function Item:Set(Color)
                        if typeof(Color) == "Color3" then
                            ApplyColor(Color, false)
                        end
                    end

                    function Item:Get()
                        return Item.Value
                    end

                    return Item
                end

                function Group:CreateDoubleSlider(Options)
                    Options = Options or {}
                    if #self.Elements > 0 then
                        self:CreateDivider(#self.Elements * 2)
                    end

                    local SliderName = Options.Name or "Range"
                    local Minimum = tonumber(Options.Min) or 0
                    local Maximum = tonumber(Options.Max) or 500
                    local Step = tonumber(Options.Step) or 1
                    local Suffix = Options.Suffix or ""
                    local InitialMin = math.clamp(tonumber(Options.DefaultMin) or Minimum, Minimum, Maximum)
                    local InitialMax = math.clamp(tonumber(Options.DefaultMax) or Maximum, Minimum, Maximum)
                    local Motion = self:CreateMotionContainer(SliderName .. "Motion", #self.Elements * 2 + 1)
                    local Slider = UI.Create("TextButton", {
                        Name = SliderName,
                        Active = true,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 42),
                        Text = "",
                    }, Motion)

                    local Label = UI.Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, -100, 0, 20),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = SliderName,
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextTransparency = 0.6,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Slider)

                    local ValueLabel = UI.Create("TextLabel", {
                        Name = "Value",
                        AnchorPoint = Vector2.new(1, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, 0, 0, 0),
                        Size = UDim2.fromOffset(100, 20),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Slider)

                    local Track = UI.Create("Frame", {
                        Name = "Track",
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.SliderBackground,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 29),
                        Size = UDim2.new(1, 0, 0, 7),
                    }, Slider)
                    UI.Corner(Track, 3)
                    local Fill = UI.Create("Frame", {
                        Name = "Fill",
                        BackgroundColor3 = self.Tab.Library.Theme.Accent,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 0, 1, 0),
                    }, Track)
                    UI.Corner(Fill, 3)
                    local Gradient = UI.Create("UIGradient", {
                        Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(205, 205, 255)),
                    }, Fill)

                    local function CreateValueBubble(Name)
                        local Bubble = UI.Create("TextLabel", {
                            Name = Name,
                            AnchorPoint = Vector2.new(0.5, 1),
                            BackgroundColor3 = Color3.fromRGB(27, 26, 31),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 0, -8),
                            Size = UDim2.fromOffset(30, 22),
                            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            TextColor3 = Color3.fromRGB(255, 255, 255),
                            TextSize = 12,
                            TextTransparency = 1,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            ZIndex = 3,
                        }, Track)
                        UI.Corner(Bubble, 7)
                        return Bubble
                    end

                    local MinBubble = CreateValueBubble("MinValue")
                    local MaxBubble = CreateValueBubble("MaxValue")

                    local function CreateKnob(Name)
                        local Knob = UI.Create("Frame", {
                            Name = Name,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.new(0, 0, 0.5, 0),
                            Size = UDim2.fromOffset(10, 10),
                            ZIndex = 2,
                        }, Track)
                        UI.Corner(Knob, 5)
                        return Knob
                    end

                    local MinKnob = CreateKnob("MinKnob")
                    local MaxKnob = CreateKnob("MaxKnob")
                    local Item = {
                        Type = "DoubleSlider",
                        Name = SliderName,
                        Motion = Slider,
                        Button = Slider,
                        Track = Track,
                        Fill = Fill,
                        Gradient = Gradient,
                        MinBubble = MinBubble,
                        MaxBubble = MaxBubble,
                        MinKnob = MinKnob,
                        MaxKnob = MaxKnob,
                        Label = Label,
                        ValueLabel = ValueLabel,
                        MinValue = math.min(InitialMin, InitialMax),
                        MaxValue = math.max(InitialMin, InitialMax),
                        DefaultMinValue = math.min(InitialMin, InitialMax),
                        DefaultMaxValue = math.max(InitialMin, InitialMax),
                    }
                    table.insert(self.Elements, Item)
                    local Dragging

                    local function FormatValue(Value)
                        if Step >= 1 then
                            return tostring(math.floor(Value + 0.5)) .. Suffix
                        end
                        return string.format("%.2f", Value):gsub("0+$", ""):gsub("%.$", "") .. Suffix
                    end

                    local function FormatRawValue(Value)
                        if Step >= 1 then
                            return tostring(math.floor(Value + 0.5))
                        end
                        return string.format("%.2f", Value):gsub("0+$", ""):gsub("%.$", "")
                    end

                    local function SetValues(NewMin, NewMax, Animated)
                        Item.MinValue = math.clamp(NewMin, Minimum, Maximum)
                        Item.MaxValue = math.clamp(NewMax, Minimum, Maximum)
                        if Step > 0 then
                            Item.MinValue = math.floor(Item.MinValue / Step + 0.5) * Step
                            Item.MaxValue = math.floor(Item.MaxValue / Step + 0.5) * Step
                        end
                        if Item.MinValue > Item.MaxValue then
                            Item.MinValue, Item.MaxValue = Item.MaxValue, Item.MinValue
                        end
                        local Range = Maximum - Minimum
                        local MinimumGap = math.min(math.max(Step, Range * 0.04), Range)
                        if MinimumGap > 0 and Item.MinValue > Item.MaxValue - MinimumGap then
                            if Dragging == "Min" then
                                Item.MinValue = Item.MaxValue - MinimumGap
                            else
                                Item.MaxValue = Item.MinValue + MinimumGap
                            end
                        end

                        local MinRatio = Range == 0 and 0 or (Item.MinValue - Minimum) / Range
                        local MaxRatio = Range == 0 and 0 or (Item.MaxValue - Minimum) / Range
                        local TweenInfoValue = Animated and TweenInfo.new(0.18, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) or TweenInfo.new(0)
                        TweenService:Create(Fill, TweenInfoValue, {
                            Position = UDim2.new(MinRatio, 0, 0, 0),
                            Size = UDim2.new(MaxRatio - MinRatio, 0, 1, 0),
                        }):Play()
                        TweenService:Create(MinKnob, TweenInfoValue, {
                            Position = UDim2.new(MinRatio, 0, 0.5, 0),
                        }):Play()
                        TweenService:Create(MaxKnob, TweenInfoValue, {
                            Position = UDim2.new(MaxRatio, 0, 0.5, 0),
                        }):Play()
                        TweenService:Create(MinBubble, TweenInfoValue, {
                            Position = UDim2.new(MinRatio, 0, 0, -8),
                        }):Play()
                        TweenService:Create(MaxBubble, TweenInfoValue, {
                            Position = UDim2.new(MaxRatio, 0, 0, -8),
                        }):Play()
                        ValueLabel.Text = FormatValue(Item.MinValue) .. " - " .. FormatValue(Item.MaxValue)
                        MinBubble.Text = FormatRawValue(Item.MinValue)
                        MaxBubble.Text = FormatRawValue(Item.MaxValue)

                        if Animated and type(Options.Callback) == "function" then
                            Options.Callback(Item.MinValue, Item.MaxValue)
                            -- Auto-save after double slider change
                            task.defer(function()
                                self.Tab.Library:AutoSave()
                            end)
                        end
                    end

                    local function UpdateFromInput(Input)
                        local Ratio = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                        local Value = Minimum + (Maximum - Minimum) * Ratio
                        if Dragging == "Min" then
                            SetValues(math.min(Value, Item.MaxValue), Item.MaxValue, true)
                        else
                            SetValues(Item.MinValue, math.max(Value, Item.MinValue), true)
                        end
                    end

                    SetValues(Item.MinValue, Item.MaxValue, false)
                    Slider.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            local Ratio = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                            local MinRatio = (Item.MinValue - Minimum) / (Maximum - Minimum)
                            local MaxRatio = (Item.MaxValue - Minimum) / (Maximum - Minimum)
                            Dragging = math.abs(Ratio - MinRatio) <= math.abs(Ratio - MaxRatio) and "Min" or "Max"
                            TweenService:Create(MinKnob, TweenInfo.new(0.12), {
                                BackgroundTransparency = Dragging == "Min" and 0 or 1,
                            }):Play()
                            TweenService:Create(MaxKnob, TweenInfo.new(0.12), {
                                BackgroundTransparency = Dragging == "Max" and 0 or 1,
                            }):Play()
                            TweenService:Create(MinBubble, TweenInfo.new(0.12), {
                                BackgroundTransparency = Dragging == "Min" and 0 or 1,
                                TextTransparency = Dragging == "Min" and 0 or 1,
                            }):Play()
                            TweenService:Create(MaxBubble, TweenInfo.new(0.12), {
                                BackgroundTransparency = Dragging == "Max" and 0 or 1,
                                TextTransparency = Dragging == "Max" and 0 or 1,
                            }):Play()
                            UpdateFromInput(Input)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(Input)
                        if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                            UpdateFromInput(Input)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                            Dragging = nil
                            TweenService:Create(MinKnob, TweenInfo.new(0.14), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(MaxKnob, TweenInfo.new(0.14), {BackgroundTransparency = 1}):Play()
                            TweenService:Create(MinBubble, TweenInfo.new(0.14), {
                                BackgroundTransparency = 1,
                                TextTransparency = 1,
                            }):Play()
                            TweenService:Create(MaxBubble, TweenInfo.new(0.14), {
                                BackgroundTransparency = 1,
                                TextTransparency = 1,
                            }):Play()
                        end
                    end)

                    function Item:Set(NewMin, NewMax)
                        SetValues(tonumber(NewMin) or Minimum, tonumber(NewMax) or Maximum, true)
                    end

                    function Item:Get()
                        return Item.MinValue, Item.MaxValue
                    end

                    return Item
                end

                function Group:CreateTextbox(Options)
                    Options = Options or {}
                    if #self.Elements > 0 then
                        self:CreateDivider(#self.Elements * 2)
                    end

                    local TextboxName = Options.Name or "Textbox"
                    local InitialText = tostring(Options.Default or Options.Text or "")
                    local Placeholder = tostring(Options.Placeholder or "Enter text")
                    local Motion = self:CreateMotionContainer(TextboxName .. "Motion", #self.Elements * 2 + 1)
                    local Container = UI.Create("Frame", {
                        Name = TextboxName,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                    }, Motion)
                    UI.Create("UIListLayout", {
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }, Container)

                    local Label = UI.Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = TextboxName,
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextTransparency = 0.6,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Container)

                    local Input = UI.Create("TextBox", {
                        Name = "Input",
                        Active = true,
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.ToggleBackground,
                        BorderSizePixel = 0,
                        ClearTextOnFocus = Options.ClearTextOnFocus == true,
                        LayoutOrder = 2,
                        MultiLine = Options.MultiLine == true,
                        PlaceholderText = Placeholder,
                        PlaceholderColor3 = self.Tab.Library.Theme.Groups.Title:Lerp(self.Tab.Library.Theme.Groups.ToggleBackground, 0.6),
                        Text = InitialText,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 14,
                        TextTransparency = 0,
                        TextWrapped = Options.MultiLine == true,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Size = UDim2.new(1, 0, 0, Options.MultiLine and 54 or 30),
                    }, Container)
                    UI.Corner(Input, 7)

                    local Item = {
                        Type = "Textbox",
                        Name = TextboxName,
                        Motion = Container,
                        Container = Container,
                        Label = Label,
                        Input = Input,
                        Value = InitialText,
                        DefaultValue = InitialText,
                    }
                    table.insert(self.Elements, Item)

                    local function UpdateTextAppearance()
                        Input.TextColor3 = Color3.fromRGB(255, 255, 255)
                        Input.PlaceholderColor3 = self.Tab.Library.Theme.Groups.Title:Lerp(self.Tab.Library.Theme.Groups.ToggleBackground, 0.6)
                    end

                    Input:GetPropertyChangedSignal("Text"):Connect(function()
                        Item.Value = Input.Text
                        UpdateTextAppearance()
                    end)

                    UpdateTextAppearance()

                    Input.FocusLost:Connect(function(EnterPressed)
                        if type(Options.Callback) == "function" then
                            Options.Callback(Input.Text, EnterPressed)
                            -- Auto-save after textbox change
                            task.defer(function()
                                self.Tab.Library:AutoSave()
                            end)
                        end
                    end)

                    function Item:Set(Value)
                        Input.Text = tostring(Value or "")
                        Item.Value = Input.Text
                    end

                    function Item:Get()
                        return Item.Value
                    end

                    return Item
                end

                function Group:CreateButton(Options)
                    Options = Options or {}
                    if #self.Elements > 0 and Options.NoDivider ~= true then
                        self:CreateDivider(#self.Elements * 2)
                    end

                    local ButtonName = Options.Name or Options.Text or "Button"
                    local Motion = self:CreateMotionContainer(ButtonName .. "Motion", #self.Elements * 2 + 1)
                    local Button = UI.Create("TextButton", {
                        Name = ButtonName,
                        Active = true,
                        AutoButtonColor = false,
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.ToggleBackground,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 30),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = "",
                    }, Motion)
                    UI.Corner(Button, 7)

                    local Ripple = UI.Create("Frame", {
                        Name = "Ripple",
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BackgroundColor3 = self.Tab.Library.Theme.Accent,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.fromOffset(0, 0),
                        ZIndex = 2,
                    }, Button)
                    UI.Corner(Ripple, 7)

                    local ButtonLabel = UI.Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = ButtonName,
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Center,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        ZIndex = 3,
                    }, Button)

                    local Item = {
                        Type = "Button",
                        Name = ButtonName,
                        Motion = Button,
                        Button = Button,
                        Label = ButtonLabel,
                        Ripple = Ripple,
                    }
                    table.insert(self.Elements, Item)

                    local RippleX = nil
                    Button.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1
                            or Input.UserInputType == Enum.UserInputType.Touch then
                            local ButtonPosition = Button.AbsolutePosition
                            RippleX = math.clamp(Input.Position.X - ButtonPosition.X, 0, Button.AbsoluteSize.X)
                        end
                    end)

                    Button.Activated:Connect(function()
                        local ButtonWidth = Button.AbsoluteSize.X
                        local ButtonHeight = Button.AbsoluteSize.Y
                        local ClickX = RippleX or ButtonWidth * 0.5
                        local TargetWidth = math.max(ClickX, ButtonWidth - ClickX) * 2 + 20
                        Ripple.Position = UDim2.fromOffset(ClickX, ButtonHeight * 0.5)
                        Ripple.BackgroundColor3 = self.Tab.Library.Theme.Accent
                        Ripple.BackgroundTransparency = 0.18
                        Ripple.Size = UDim2.new(0, 0, 1, 0)
                        local RippleTween = TweenService:Create(Ripple, TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, TargetWidth, 1, 0),
                        })
                        RippleTween:Play()
                        if type(Options.Callback) == "function" then
                            Options.Callback()
                        end
                    end)

                    function Item:SetText(Text)
                        ButtonLabel.Text = tostring(Text or "")
                    end

                    return Item
                end

                function Group:CreateDropdown(Options)
                    Options = Options or {}
                    if #self.Elements > 0 then
                        self:CreateDivider(#self.Elements * 2)
                    end

                    local DropdownName = Options.Name or "Dropdown"
                    local Values = Options.Values or Options.Options or {"Default"}
                    local Multiple = Options.Multiple == true
                    local Motion = self:CreateMotionContainer(DropdownName .. "Motion", #self.Elements * 2 + 1)
                    local Container = UI.Create("Frame", {
                        Name = DropdownName,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                    }, Motion)
                    UI.Create("UIListLayout", {
                        Padding = UDim.new(0, 5),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }, Container)

                    local Header = UI.Create("TextButton", {
                        Name = "Header",
                        AutoButtonColor = false,
                        BackgroundColor3 = self.Tab.Library.Theme.Groups.ToggleBackground,
                        BorderSizePixel = 0,
                        LayoutOrder = 2,
                        Size = UDim2.new(1, 0, 0, 30),
                        Text = "",
                    }, Container)
                    UI.Corner(Header, 7)

                    local Label = UI.Create("TextLabel", {
                        Name = "Label",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(0, 0),
                        LayoutOrder = 1,
                        Size = UDim2.new(1, 0, 0, 20),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        Text = DropdownName,
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextTransparency = 0.6,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Container)

                    local ValueLabel = UI.Create("TextLabel", {
                        Name = "Value",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(10, 0),
                        Size = UDim2.new(1, -40, 1, 0),
                        FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                        TextColor3 = self.Tab.Library.Theme.Groups.Title,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Center,
                    }, Header)

                    local Arrow = UI.Create("ImageLabel", {
                        Name = "Arrow",
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -10, 0.5, 0),
                        Size = UDim2.fromOffset(14, 14),
                        Image = FallbackIcons["chevron-down"] or GetIcon("chevron-down"),
                        ImageColor3 = self.Tab.Library.Theme.Groups.Title,
                        ImageTransparency = 0.6,
                    }, Header)

                    local OptionsFrame = UI.Create("Frame", {
                        Name = "Options",
                        Active = true,
                        BackgroundTransparency = 1,
                        BackgroundColor3 = self.Tab.Library.Theme.Settings.Background,
                        BorderSizePixel = 0,
                        ClipsDescendants = true,
                        Position = UDim2.fromOffset(0, 0),
                        Size = UDim2.fromOffset(0, 0),
                        Visible = false,
                        ZIndex = 55,
                    }, Container)
                    OptionsFrame.Parent = self.Tab.Library.Main
                    UI.Corner(OptionsFrame, 8)
                    local OptionsContent = UI.Create("CanvasGroup", {
                        Name = "Content",
                        Active = true,
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        GroupTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        ZIndex = 56,
                    }, OptionsFrame)
                    UI.Create("UIListLayout", {
                        Padding = UDim.new(0, 3),
                        SortOrder = Enum.SortOrder.LayoutOrder,
                    }, OptionsContent)
                    UI.Create("UIPadding", {
                        PaddingTop = UDim.new(0, 8),
                        PaddingBottom = UDim.new(0, 8),
                        PaddingLeft = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 8),
                    }, OptionsContent)
                    UI.Create("TextButton", {
                        Name = "MenuHitbox",
                        Active = true,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Text = "",
                        ZIndex = 55,
                    }, OptionsFrame)

                    local DropdownDimmer = UI.Create("Frame", {
                        Name = "DropdownDimmer",
                        BackgroundColor3 = Color3.new(0, 0, 0),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Visible = false,
                        ZIndex = 40,
                    }, self.Tab.Library.Main)
                    UI.Corner(DropdownDimmer, 14)
                    local DropdownOverlay = UI.Create("TextButton", {
                        Name = "DropdownOverlay",
                        Active = true,
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromScale(1, 1),
                        Text = "",
                        Visible = false,
                        ZIndex = 41,
                    }, self.Tab.Library.Main)
                    UI.Corner(DropdownOverlay, 14)

                    local SelectedIndex = math.clamp(tonumber(Options.DefaultIndex) or 1, 1, #Values)
                    local SelectedValues = {}
                    if Multiple then
                        local Defaults = Options.Defaults or Options.DefaultValues or Options.Default or {}
                        if type(Defaults) == "table" then
                            for _, Value in ipairs(Defaults) do
                                SelectedValues[Value] = true
                            end
                        end
                    end
                    local Item = {
                        Type = Multiple and "MultiDropdown" or "Dropdown",
                        Name = DropdownName,
                        Motion = Container,
                        Container = Container,
                        Header = Header,
                        Label = Label,
                        ValueLabel = ValueLabel,
                        Arrow = Arrow,
                        OptionsFrame = OptionsFrame,
                        OptionsContent = OptionsContent,
                        Menu = OptionsFrame,
                        Dimmer = DropdownDimmer,
                        Overlay = DropdownOverlay,
                        Options = {},
                        Value = Multiple and SelectedValues or Values[SelectedIndex],
                        Values = Multiple and SelectedValues or nil,
                        Open = false,
                        DefaultValue = Multiple and (function()
                            local Result = {}
                            local Defaults = Options.Defaults or Options.DefaultValues or Options.Default or {}
                            if type(Defaults) == "table" then
                                for _, Value in ipairs(Defaults) do table.insert(Result, Value) end
                            end
                            return Result
                        end)() or Values[SelectedIndex],
                    }
                    table.insert(self.Elements, Item)

                    local function GetSelectedValues()
                        local Result = {}
                        for _, Value in ipairs(Values) do
                            if SelectedValues[Value] then
                                table.insert(Result, Value)
                            end
                        end
                        return Result
                    end

                    local function UpdateValueLabel()
                        if Multiple then
                            local Selected = GetSelectedValues()
                            Item.Value = SelectedValues
                            ValueLabel.Text = #Selected > 0 and table.concat(Selected, ", ") or "None"
                        else
                            ValueLabel.Text = tostring(Item.Value)
                        end
                    end

                    local function SetOptionState(Option, Selected, Animated)
                        local TweenInfoValue = Animated and TweenInfo.new(0.16, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) or TweenInfo.new(0)
                        TweenService:Create(Option.Button, TweenInfoValue, {
                            BackgroundTransparency = Selected and 0 or 1,
                            BackgroundColor3 = self.Tab.Library.Theme.Settings.SelectedBackground,
                        }):Play()
                        TweenService:Create(Option.Label, TweenInfoValue, {
                            TextTransparency = Selected and 0 or 0.6,
                            Position = UDim2.fromOffset(Selected and 30 or 8, 0),
                        }):Play()
                        TweenService:Create(Option.Check, TweenInfoValue, {
                            ImageTransparency = Selected and 0 or 1,
                            Position = UDim2.fromOffset(Selected and 8 or 3, 6),
                        }):Play()
                    end

                    local function SetOpen(Open)
                        if Item.Open == Open then return end
                        Item.Open = Open
                        local MainFrame = self.Tab.Library.Main
                        local TweenInfoValue = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                        TweenService:Create(Arrow, TweenInfoValue, {
                            Rotation = Open and 180 or 0,
                        }):Play()

                        if Open then
                            MainFrame.ZIndex = 10
                            local Scale = self.Tab.Library.MainScale.Scale
                            local HeaderPosition = Header.AbsolutePosition
                            local MainPosition = MainFrame.AbsolutePosition
                            local HeaderSize = Header.AbsoluteSize
                            local MenuPosition = UDim2.fromOffset(
                                (HeaderPosition.X - MainPosition.X) / Scale,
                                (HeaderPosition.Y - MainPosition.Y + HeaderSize.Y + 5 * Scale) / Scale
                            )
                            local MenuWidth = HeaderSize.X / Scale

                            OptionsFrame.Position = MenuPosition
                            OptionsFrame.Size = UDim2.fromOffset(MenuWidth, 0)
                            OptionsFrame.BackgroundTransparency = 1
                            OptionsFrame.Visible = true
                            OptionsContent.GroupTransparency = 1
                            DropdownDimmer.BackgroundTransparency = 1
                            DropdownDimmer.Visible = true
                            DropdownOverlay.Visible = true
                            TweenService:Create(DropdownDimmer, TweenInfoValue, {
                                BackgroundTransparency = 0.78,
                            }):Play()
                            task.defer(function()
                                local Height = OptionsContent.AbsoluteSize.Y
                                TweenService:Create(OptionsFrame, TweenInfoValue, {
                                    Size = UDim2.fromOffset(MenuWidth, Height),
                                    BackgroundTransparency = 0,
                                }):Play()
                                TweenService:Create(OptionsContent, TweenInfoValue, {
                                    GroupTransparency = 0,
                                }):Play()
                            end)
                        else
                            TweenService:Create(OptionsFrame, TweenInfoValue, {
                                Size = UDim2.new(OptionsFrame.Size.X.Scale, OptionsFrame.Size.X.Offset, 0, 0),
                                BackgroundTransparency = 1,
                            }):Play()
                            TweenService:Create(OptionsContent, TweenInfoValue, {
                                GroupTransparency = 1,
                            }):Play()
                            TweenService:Create(DropdownDimmer, TweenInfoValue, {
                                BackgroundTransparency = 1,
                            }):Play()
                            task.delay(TweenInfoValue.Time, function()
                                if not Item.Open then
                                    MainFrame.ZIndex = 1
                                    OptionsFrame.Visible = false
                                    DropdownDimmer.Visible = false
                                    DropdownOverlay.Visible = false
                                end
                            end)
                        end
                    end

                    DropdownOverlay.Activated:Connect(function()
                        SetOpen(false)
                    end)

                    UserInputService.InputBegan:Connect(function(Input)
                        if not Item.Open then return end
                        if Input.UserInputType ~= Enum.UserInputType.MouseButton1
                            and Input.UserInputType ~= Enum.UserInputType.Touch then
                            return
                        end

                        local Position = Input.Position
                        if not IsInside(OptionsFrame, Position) and not IsInside(Header, Position) then
                            SetOpen(false)
                        end
                    end)

                    for Index, Value in ipairs(Values) do
                        local Selected = Multiple and SelectedValues[Value] == true or Index == SelectedIndex
                        local OptionButton = UI.Create("TextButton", {
                            Name = tostring(Value),
                            AutoButtonColor = false,
                            BackgroundColor3 = self.Tab.Library.Theme.Settings.SelectedBackground,
                            BackgroundTransparency = Selected and 0 or 1,
                            BorderSizePixel = 0,
                            LayoutOrder = Index,
                            Size = UDim2.new(1, 0, 0, 28),
                            Text = "",
                            ZIndex = 57,
                        }, OptionsContent)
                        UI.Corner(OptionButton, 6)
                        local Check = UI.Create("ImageLabel", {
                            Name = "Check",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Image = FallbackIcons.check or GetIcon("check"),
                            ImageColor3 = self.Tab.Library.Theme.Accent,
                            ImageTransparency = Selected and 0 or 1,
                            Position = UDim2.fromOffset(Selected and 8 or 3, 6),
                            Size = UDim2.fromOffset(16, 16),
                            ZIndex = 58,
                        }, OptionButton)
                        local OptionLabel = UI.Create("TextLabel", {
                            Name = "Label",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(Selected and 30 or 8, 0),
                            Size = UDim2.new(1, -34, 1, 0),
                            FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                            Text = tostring(Value),
                            TextColor3 = self.Tab.Library.Theme.Groups.Title,
                            TextSize = 14,
                            TextTransparency = Selected and 0 or 0.6,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            ZIndex = 58,
                        }, OptionButton)
                        local Option = {
                            Button = OptionButton,
                            Check = Check,
                            Label = OptionLabel,
                            Index = Index,
                            Value = Value,
                        }
                        table.insert(Item.Options, Option)

                        OptionButton.Activated:Connect(function()
                            if Multiple then
                                SelectedValues[Value] = not SelectedValues[Value]
                                SetOptionState(Option, SelectedValues[Value] == true, true)
                                UpdateValueLabel()
                            else
                                SelectedIndex = Index
                                Item.Value = Value
                                ValueLabel.Text = tostring(Value)
                                for OptionIndex, OtherOption in ipairs(Item.Options) do
                                    SetOptionState(OtherOption, OptionIndex == SelectedIndex, true)
                                end
                            end
                            if type(Options.Callback) == "function" then
                                if Multiple then
                                    Options.Callback(GetSelectedValues(), Value, SelectedValues[Value] == true)
                                else
                                    Options.Callback(Value)
                                end
                                -- Auto-save after dropdown change
                                task.defer(function()
                                    self.Tab.Library:AutoSave()
                                end)
                            end
                        end)
                    end

                    UpdateValueLabel()
                    Header.Activated:Connect(function()
                        SetOpen(not Item.Open)
                    end)

                    function Item:Set(Value)
                        if Multiple then
                            local NewValues = type(Value) == "table" and Value or {Value}
                            SelectedValues = {}
                            for _, NewValue in ipairs(NewValues) do
                                SelectedValues[NewValue] = true
                            end
                            Item.Values = SelectedValues
                            for _, Option in ipairs(Item.Options) do
                                SetOptionState(Option, SelectedValues[Option.Value] == true, true)
                            end
                            UpdateValueLabel()
                            return
                        end
                        for Index, OptionValue in ipairs(Values) do
                            if OptionValue == Value then
                                SelectedIndex = Index
                                Item.Value = Value
                                ValueLabel.Text = tostring(Value)
                                for OptionIndex, OtherOption in ipairs(Item.Options) do
                                    SetOptionState(OtherOption, OptionIndex == SelectedIndex, true)
                                end
                                return
                            end
                        end
                    end

                    function Item:Get()
                        return Multiple and GetSelectedValues() or Item.Value
                    end

                    return Item
                end

                function Group:CreateMultiDropdown(Options)
                    Options = Options or {}
                    Options.Multiple = true
                    return self:CreateDropdown(Options)
                end

                table.insert(self.Groups, Group)

                if self.Tab.Selected and UpdateCategoryContent then
                    UpdateCategoryContent(self.Tab)
                end

                return Group
            end

            if self.Selected and UpdateCategoryButton then
                UpdateCategoryButton(self)
            end

            return Category
        end

        return Tab
    end

    self.Screen = Screen
    self.Main = Main
    self.Sidebar = Sidebar
    self.BottomNavigation = BottomNavigation
    self.Search = Search
    self.SearchInput = SearchInput
    self.Tabs = Tabs
    self.ActiveTab = ActiveTab
    self.TopButtons = TopButtons
    self.ConfigMenu = ConfigMenu
    self.ConfigDimmer = ConfigDimmer
    self.ConfigAddMenu = ConfigAddMenu
    self.ConfigNames = ConfigNames
    self.ConfigRows = self.ConfigRows or {}
    self.ConfigRowMenu = ConfigRowMenu
    self.AutoLoadConfigName = AutoLoadConfigName
    self.SettingsMenu = SettingsMenu
    self.SettingsDimmer = SettingsDimmer
    self.SettingsOverlay = SettingsOverlay
    self.ThemeDropdown = ThemeDropdown
    self.ThemeDropdownContent = ThemeDropdownContent
    self.CategoryButton = CategoryButton
    self.CategoryLabel = CategoryLabel
    self.CategoryArrow = CategoryArrow
    self.CategoryDropdown = CategoryDropdown
    self.CategoryDropdownContent = CategoryDropdownContent
    self.CategoryDropdownItems = CategoryDropdownItems
    self.CategoryDimmer = CategoryDimmer
    self.CategoryOverlay = CategoryOverlay
    self.Breadcrumb = Breadcrumb
    self.BreadcrumbTabLabel = BreadcrumbTabLabel
    self.BreadcrumbArrow = BreadcrumbArrow
    self.BreadcrumbCategoryLabel = BreadcrumbCategoryLabel
    self.GroupArea = GroupArea
    self.MainScale = MainScale
    -- Restore once the caller has finished creating its tabs and controls.
    self._AutoSaveReady = false
    self._RestoringConfig = true
    task.defer(function()
        if not Screen.Parent then return end
        if AutoLoadConfigName and self.ConfigRecords and self.ConfigRecords[AutoLoadConfigName] then
            self:LoadConfig(AutoLoadConfigName)
        end
        -- The automatic snapshot takes precedence over an optional named preset.
        self:AutoLoad()
        self._RestoringConfig = false
        self._AutoSaveReady = true
        local Ok, Signature = pcall(function()
            return HttpService:JSONEncode(self:CaptureConfig())
        end)
        self._LastAutoSaveSignature = Ok and Signature or nil
    end)
    task.spawn(function()
        while Screen.Parent do
            task.wait(0.3)
            if self._AutoSaveReady and not self._RestoringConfig then
                local Snapshot = self:CaptureConfig()
                local Ok, Signature = pcall(function()
                    return HttpService:JSONEncode(Snapshot)
                end)
                if Ok and Signature ~= self._LastAutoSaveSignature then
                    if self:SaveConfig("__AutoSave__", Snapshot) then
                        self._LastAutoSaveSignature = Signature
                    end
                end
            end
        end
    end)
    GetGlobalEnvironment().__WisperLibraryNewInstance = Screen

    return self
end

return Library
