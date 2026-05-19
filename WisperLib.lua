local WisperLib = {}

local Development = false
local DevelopmentUserId = 944604813

local TweenService = game:GetService("TweenService");
local UserInputService = game:GetService("UserInputService");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local CoreGui = game:GetService("CoreGui");
local HttpService = game:GetService("HttpService");

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled;

local Player = Players.LocalPlayer

if _G.WisperLibInstance then
    _G.WisperLibInstance:Destroy()
    _G.WisperLibInstance = nil
end

--// Icon System //--
local Icons = nil;
local IconsUrl = "https://raw.githubusercontent.com/isKuyo/WisperLib/main/Assets/Icons.lua";

local function LoadIcons()
    if Icons then return Icons end;
    local Ok, Result = pcall(function()
        return loadstring(game:HttpGet(IconsUrl, true))();
    end);
    if Ok and type(Result) == "table" and type(Result.assets) == "table" then
        Icons = Result.assets;
    else
        Icons = {};
    end;
    return Icons;
end;

local function GetIcon(ShortName)
    if not ShortName or ShortName == "" then
        return "rbxassetid://7733960981";
    end;
    if tostring(ShortName):match("^rbxassetid://") then
        return ShortName;
    end;
    local Assets = LoadIcons();
    local LucideName = "lucide-" .. ShortName;
    if Assets[LucideName] then return Assets[LucideName] end;
    if Assets[ShortName] then return Assets[ShortName] end;
    return "rbxassetid://7733960981";
end;

local IconKeywords = {
    ["settings"] = {"settings", "config", "configuration", "opcoes", "options"},
    ["home"] = {"home", "main", "general", "principal"},
    ["eye"] = {"visual", "esp", "render", "display"},
    ["crosshair"] = {"aim", "aimbot", "combat", "pvp"},
    ["layers"] = {"misc", "other", "extra"},
    ["shield"] = {"player", "anti", "safe"},
    ["zap"] = {"speed", "movement", "fly"},
    ["package"] = {"item", "inventory", "loot"},
};

local GroupIconKeywords = {
    ["eye"]         = {"esp", "visual", "visuals", "entity", "render", "chams", "glow", "highlight"},
    ["crosshair"]   = {"aim", "aimbot", "combat", "pvp", "target", "hitbox", "fov"},
    ["user"]        = {"player", "players", "character", "local"},
    ["zap"]         = {"speed", "movement", "move", "fly", "flight", "velocity", "noclip"},
    ["map-pin"]     = {"teleport", "tp", "warp", "location"},
    ["map"]         = {"world", "map", "radar", "minimap"},
    ["palette"]     = {"color", "colors", "theme", "appearance", "ui"},
    ["bell"]        = {"notification", "notifications", "alert", "alerts"},
    ["keyboard"]    = {"keybind", "keybinds", "hotkey", "hotkeys", "key"},
    ["shield"]      = {"anti", "safe", "protection", "bypass", "spoof"},
    ["package"]     = {"item", "items", "inventory", "loot", "farm", "collect"},
    ["sword"]       = {"weapon", "weapons", "kill", "damage", "attack"},
    ["settings"]    = {"settings", "config", "configuration", "options"},
    ["info"]        = {"info", "debug", "log", "status"},
    ["layers"]      = {"misc", "other", "extra", "general"},
};

local function GetAutoGroupIcon(GroupName)
    local LowerName = string.lower(GroupName);
    for ShortName, Keywords in pairs(GroupIconKeywords) do
        for _, Keyword in ipairs(Keywords) do
            if string.find(LowerName, Keyword) then
                return GetIcon(ShortName);
            end;
        end;
    end;
    return GetIcon("layers");
end;

local function GetAutoIcon(TabName)
    local LowerName = string.lower(TabName);
    for ShortName, Keywords in pairs(IconKeywords) do
        for _, Keyword in ipairs(Keywords) do
            if string.find(LowerName, Keyword) then
                return GetIcon(ShortName);
            end;
        end;
    end;
    return GetIcon("layout-grid");
end;

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

local ThemePresets = {
    Default = {
        Background = Color3.fromRGB(13, 15, 18),
        Header = Color3.fromRGB(20, 23, 28),
        HeaderLine = Color3.fromRGB(26, 30, 36),
        GroupHeaderBase = Color3.fromRGB(255, 255, 255),
        GroupHeaderGradientTop = Color3.fromRGB(22, 25, 29),
        GroupHeaderGradientBottom = Color3.fromRGB(20, 23, 27),
        ContentBackground = Color3.fromRGB(13, 15, 18),
        GroupBackground = Color3.fromRGB(22, 25, 30),
        GroupStroke = Color3.fromRGB(26, 30, 36),
        ButtonInactive = Color3.fromRGB(13, 15, 18),
        ControlBackground = Color3.fromRGB(28, 32, 38),
        ControlHover = Color3.fromRGB(35, 40, 48),
        GradientColor1 = Color3.fromRGB(156, 125, 237),
        GradientColor2 = Color3.fromRGB(124, 91, 228),
        ToggleInactiveGradientTop = Color3.fromRGB(34, 39, 45),
        ToggleInactiveGradientBottom = Color3.fromRGB(29, 33, 38),
        AvatarStroke = Color3.fromRGB(26, 30, 36),
        Accent = Color3.fromRGB(124, 91, 228),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(150, 150, 150),
        Divider = Color3.fromRGB(26, 30, 36),
        SeparatorLine = Color3.fromRGB(60, 65, 75),
        SeparatorText = Color3.fromRGB(180, 185, 195),
        CheckboxEnabled = Color3.fromRGB(181, 208, 251),
        CheckboxDisabled = Color3.fromRGB(60, 61, 66),
        SliderBackground = Color3.fromRGB(35, 40, 50),
        SliderFill = Color3.fromRGB(100, 150, 200),
        InputBackground = Color3.fromRGB(22, 25, 30),
        Footer = Color3.fromRGB(20, 23, 28)
    },
    White = {
        Background = Color3.fromRGB(244, 246, 250),
        Header = Color3.fromRGB(235, 239, 246),
        HeaderLine = Color3.fromRGB(205, 212, 226),
        GroupHeaderBase = Color3.fromRGB(255, 255, 255),
        GroupHeaderGradientTop = Color3.fromRGB(237, 241, 249),
        GroupHeaderGradientBottom = Color3.fromRGB(237, 241, 249),
        ContentBackground = Color3.fromRGB(244, 246, 250),
        GroupBackground = Color3.fromRGB(255, 255, 255),
        GroupStroke = Color3.fromRGB(214, 221, 234),
        ButtonInactive = Color3.fromRGB(226, 232, 242),
        ControlBackground = Color3.fromRGB(236, 241, 249),
        ControlHover = Color3.fromRGB(226, 232, 242),
        GradientColor1 = Color3.fromRGB(169, 137, 244),
        GradientColor2 = Color3.fromRGB(124, 91, 228),
        ToggleInactiveGradientTop = Color3.fromRGB(236, 241, 249),
        ToggleInactiveGradientBottom = Color3.fromRGB(224, 231, 242),
        AvatarStroke = Color3.fromRGB(190, 199, 216),
        Accent = Color3.fromRGB(124, 91, 228),
        Text = Color3.fromRGB(27, 33, 44),
        SubText = Color3.fromRGB(96, 106, 124),
        Divider = Color3.fromRGB(205, 212, 226),
        SeparatorLine = Color3.fromRGB(205, 212, 226),
        SeparatorText = Color3.fromRGB(120, 128, 146),
        CheckboxEnabled = Color3.fromRGB(77, 126, 227),
        CheckboxDisabled = Color3.fromRGB(168, 176, 189),
        SliderBackground = Color3.fromRGB(224, 231, 242),
        SliderFill = Color3.fromRGB(92, 140, 235),
        InputBackground = Color3.fromRGB(236, 241, 249),
        Footer = Color3.fromRGB(235, 239, 246)
    }
}

local Theme = ThemePresets.Default;

--// File System Helpers //--
local WisperFolderName = "Wisper";
local WisperConfigsFolderName = "Wisper/configs";
local WisperAutoloadFileName = "Wisper/autoload.txt";

local function GetFsFunc(FnName)
    local Aliases = {
        makefolder = {"makefolder", "createfolder"},
        writefile = {"writefile"},
        readfile = {"readfile"},
        isfile = {"isfile"},
        isfolder = {"isfolder"},
        listfiles = {"listfiles"},
        delfile = {"delfile", "removefile"},
    };
    local List = Aliases[FnName] or {FnName};
    for _, Candidate in ipairs(List) do
        if type(_G[Candidate]) == "function" then
            return _G[Candidate];
        end;
        if type(getgenv) == "function" then
            local Ok, Env = pcall(getgenv);
            if Ok and type(Env) == "table" and type(Env[Candidate]) == "function" then
                return Env[Candidate];
            end;
        end;
    end;
    return nil;
end;

local function FsEnsureFolders()
    local MakeFolder = GetFsFunc("makefolder");
    local IsFolder = GetFsFunc("isfolder");
    if not MakeFolder then return end;
    local function EnsureDir(Path)
        if IsFolder then
            local Ok, Exists = pcall(IsFolder, Path);
            if Ok and Exists then return end;
        end;
        pcall(MakeFolder, Path);
    end;
    EnsureDir(WisperFolderName);
    EnsureDir(WisperConfigsFolderName);
end;

local function FsWriteFile(Path, Content)
    local Fn = GetFsFunc("writefile");
    if not Fn then return false end;
    local Ok = pcall(Fn, Path, Content);
    return Ok;
end;

local function FsReadFile(Path)
    local IsFile = GetFsFunc("isfile");
    local ReadFn = GetFsFunc("readfile");
    if not ReadFn then return nil end;
    if IsFile then
        local Ok, Exists = pcall(IsFile, Path);
        if not Ok or not Exists then return nil end;
    end;
    local Ok, Data = pcall(ReadFn, Path);
    return (Ok and type(Data) == "string" and #Data > 0) and Data or nil;
end;

local function FsDeleteFile(Path)
    local Fn = GetFsFunc("delfile");
    if not Fn then return end;
    pcall(Fn, Path);
end;

local function FsListFiles(FolderPath)
    local Fn = GetFsFunc("listfiles");
    if not Fn then return {} end;
    local Ok, Files = pcall(Fn, FolderPath);
    if not Ok or type(Files) ~= "table" then return {} end;
    return Files;
end;

local ScreenGuiName = "WisperLib_" .. tostring(math.random(100000, 999999))

function WisperLib:CreateWindow(Config)
    Config = Config or {}
    Config.Title = Config.Title or "WisperLib"
    Config.Subtitle = Config.Subtitle or ""
    Config.Size = Config.Size or UDim2.new(0, 635, 0, 510)
    Config.Position = Config.Position or UDim2.new(0.5, -317, 0.5, -255)
    Config.KeyBind = Config.KeyBind or Enum.KeyCode.RightControl

    local GuiParent = (typeof(gethui) == "function" and pcall(gethui) and gethui()) or CoreGui;
    -- ScreenGui criado sem parent primeiro; será parentado após os hooks de proteção
    local ScreenGui = Create("ScreenGui", {
        Name = ScreenGuiName,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = -1
    })

    _G.WisperLibInstance = ScreenGui;

    do
        --// Camada 1: syn.protect_gui / protect_gui (C-level, mais forte) //--
        if syn and type(syn) == "table" and syn.protect_gui then
            pcall(syn.protect_gui, ScreenGui);
        elseif typeof(protect_gui) == "function" then
            pcall(protect_gui, ScreenGui);
        end;

        -- Parenta APÓS os hooks estarem prontos, minimizando a janela de detecção
        ScreenGui.Parent = GuiParent;

        local NewCC = typeof(newcclosure) == "function" and newcclosure or function(F) return F end;

        -- Helpers compartilhados
        local function IsGuiRelated(Inst)
            if Inst == ScreenGui then return true end;
            local Ok, Result = pcall(function() return Inst:IsDescendantOf(ScreenGui) end);
            return Ok and Result;
        end;

        local function FilterList(List)
            local Out = {};
            for _, Inst in ipairs(List) do
                if not IsGuiRelated(Inst) then
                    Out[#Out + 1] = Inst;
                end;
            end;
            return Out;
        end;

        local function IsAncestorOfGui(Self)
            if Self == GuiParent then return true end;
            local Ok, Result = pcall(function() return GuiParent:IsDescendantOf(Self) end);
            return Ok and Result;
        end;

        --// Camada 2: hookfunction — bloqueia referências diretas (ex: Dex++ salva game.GetDescendants) //--
        if typeof(hookfunction) == "function" then
            pcall(function()
                local Orig; Orig = hookfunction(game.GetDescendants, NewCC(function(Self, ...)
                    local Ok, Results = pcall(Orig, Self, ...);
                    if not Ok then return {} end;
                    if not IsAncestorOfGui(Self) then return Results end;
                    return FilterList(Results);
                end));
            end);

            pcall(function()
                local Orig; Orig = hookfunction(game.GetChildren, NewCC(function(Self, ...)
                    local Ok, Results = pcall(Orig, Self, ...);
                    if not Ok then return {} end;
                    if Self ~= GuiParent then return Results end;
                    return FilterList(Results);
                end));
            end);

            pcall(function()
                local Orig; Orig = hookfunction(game.FindFirstChild, NewCC(function(Self, ...)
                    local Ok, Result = pcall(Orig, Self, ...);
                    if not Ok then return nil end;
                    if Result == ScreenGui then return nil end;
                    return Result;
                end));
            end);
        end;

        --// Camada 3: hookmetamethod __index — intercepta quando scripts buscam o método como referência //--
        if typeof(hookmetamethod) == "function" then
            pcall(function()
                local OrigIndex; OrigIndex = hookmetamethod(game, "__index", NewCC(function(Self, Key)
                    local Val = OrigIndex(Self, Key);
                    if typeof(Val) ~= "function" then return Val end;
                    if Key == "GetDescendants" then
                        return NewCC(function(S, ...)
                            local Ok, Results = pcall(Val, S, ...);
                            if not Ok then return {} end;
                            if not IsAncestorOfGui(S) then return Results end;
                            return FilterList(Results);
                        end);
                    elseif Key == "GetChildren" then
                        return NewCC(function(S, ...)
                            local Ok, Results = pcall(Val, S, ...);
                            if not Ok then return {} end;
                            if S ~= GuiParent then return Results end;
                            return FilterList(Results);
                        end);
                    elseif Key == "FindFirstChild" or Key == "FindFirstChildOfClass" or Key == "FindFirstChildWhichIsA" then
                        return NewCC(function(S, ...)
                            local Ok, Result = pcall(Val, S, ...);
                            if not Ok then return nil end;
                            if Result == ScreenGui then return nil end;
                            return Result;
                        end);
                    end;
                    return Val;
                end));
            end);
        end;

        --// Camada 4: hookmetamethod __namecall — bloqueia chamadas via :Método() normal //--
        if typeof(hookmetamethod) == "function" and typeof(getnamecallmethod) == "function" then
            pcall(function()
                local OrigNamecall; OrigNamecall = hookmetamethod(game, "__namecall", NewCC(function(Self, ...)
                    local Method = getnamecallmethod();
                    if Method == "GetChildren" or Method == "GetDescendants" then
                        local Ok, Results = pcall(OrigNamecall, Self, ...);
                        if not Ok then return {} end;
                        if Method == "GetChildren" and Self ~= GuiParent then return Results end;
                        if Method == "GetDescendants" and not IsAncestorOfGui(Self) then return Results end;
                        return FilterList(Results);
                    elseif Method == "FindFirstChild" or Method == "FindFirstChildOfClass" or Method == "FindFirstChildWhichIsA" then
                        local Ok, Result = pcall(OrigNamecall, Self, ...);
                        if not Ok then return nil end;
                        if Result == ScreenGui then return nil end;
                        return Result;
                    end;
                    return OrigNamecall(Self, ...);
                end));
            end);
        end;
    end;

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
    local DisplayName = Player.Name
    local MaskedDisplayName = "******"

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

    local TitleContainer = Create("Frame", {
        Name = "TitleContainer",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 54, 0, 8),
        Size = UDim2.new(0, 200, 0, 18),
        ClipsDescendants = true
    })

    local TitleMaskedLabel = Create("TextLabel", {
        Name = "TitleMaskedLabel",
        Parent = TitleContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = MaskedDisplayName,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
    })

    local TitleRealLabel = Create("TextLabel", {
        Name = "TitleRealLabel",
        Parent = TitleContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = DisplayName,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1,
        Position = UDim2.new(0, 6, 0, 0)
    })

    local IsShowingRealName = false
    local function SetTitleNameVisibility(ShowRealName)
        if IsShowingRealName == ShowRealName then
            return
        end

        IsShowingRealName = ShowRealName
        if ShowRealName then
            Tween(TitleMaskedLabel, {TextTransparency = 1, Position = UDim2.new(0, -6, 0, 0)}, 0.12)
            Tween(TitleRealLabel, {TextTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}, 0.12)
        else
            Tween(TitleMaskedLabel, {TextTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}, 0.12)
            Tween(TitleRealLabel, {TextTransparency = 1, Position = UDim2.new(0, 6, 0, 0)}, 0.12)
        end
    end

    AvatarContainer.MouseEnter:Connect(function()
        SetTitleNameVisibility(true)
    end)

    AvatarContainer.MouseLeave:Connect(function()
        SetTitleNameVisibility(false)
    end)

    TitleContainer.MouseEnter:Connect(function()
        SetTitleNameVisibility(true)
    end)

    TitleContainer.MouseLeave:Connect(function()
        SetTitleNameVisibility(false)
    end)

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
    local ConfigStateRegistry = {};
    local ActiveAutoloadConfig = nil;
    local KeybindRegistry = {}; -- {Name, GetKey, GetActive (nil = não é toggle)}

    local function GetConfigNames()
        local Files = FsListFiles(WisperConfigsFolderName);
        local Names = {};
        for _, FilePath in ipairs(Files) do
            local Name = tostring(FilePath):match("([^/\\]+)%.json$");
            if Name then
                table.insert(Names, Name);
            end;
        end;
        table.sort(Names);
        return Names;
    end;

    local function SerializeConfig()
        local Data = {};
        for Name, Entry in pairs(ConfigStateRegistry) do
            if Entry.Type == "Toggle" then
                Data[Name] = {Type = "Toggle", Value = Entry.Get()};
            elseif Entry.Type == "Slider" then
                Data[Name] = {Type = "Slider", Value = Entry.Get()};
            elseif Entry.Type == "Combobox" then
                Data[Name] = {Type = "Combobox", Value = Entry.Get()};
            elseif Entry.Type == "Input" then
                Data[Name] = {Type = "Input", Value = Entry.Get()};
            end;
        end;
        local Ok, Json = pcall(function() return HttpService:JSONEncode(Data) end);
        return Ok and Json or "{}";
    end;

    local function ApplyConfigData(JsonStr)
        local Ok, Data = pcall(function() return HttpService:JSONDecode(JsonStr) end);
        if not Ok or type(Data) ~= "table" then return false end;
        for Name, Entry in pairs(Data) do
            local Reg = ConfigStateRegistry[Name];
            if Reg and Entry.Value ~= nil then
                pcall(function() Reg.Set(Entry.Value) end);
            end;
        end;
        return true;
    end;

    local function SaveConfig(ConfigName)
        FsEnsureFolders();
        local Json = SerializeConfig();
        return FsWriteFile(WisperConfigsFolderName .. "/" .. ConfigName .. ".json", Json);
    end;

    local function LoadConfig(ConfigName)
        local Json = FsReadFile(WisperConfigsFolderName .. "/" .. ConfigName .. ".json");
        if not Json then return false end;
        return ApplyConfigData(Json);
    end;

    local function DeleteConfig(ConfigName)
        FsDeleteFile(WisperConfigsFolderName .. "/" .. ConfigName .. ".json");
    end;

    local function GetAutoloadConfigName()
        local Data = FsReadFile(WisperAutoloadFileName);
        if not Data then return nil end;
        return Data:match("^%s*(.-)%s*$");
    end;

    local function SetAutoloadConfig(ConfigName)
        FsEnsureFolders();
        FsWriteFile(WisperAutoloadFileName, ConfigName);
        ActiveAutoloadConfig = ConfigName;
    end;

    local function ClearAutoloadConfig()
        FsDeleteFile(WisperAutoloadFileName);
        ActiveAutoloadConfig = nil;
    end;

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
        Image = "rbxassetid://77341506028972",
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

    local FooterTitle = Create("TextLabel", {
        Name = "FooterTitle",
        Parent = FooterTitleContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 0, 16),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = "Wisper Hub",
        TextColor3 = Theme.Text,
        TextSize = 13
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
        Position = UDim2.new(1, -40, 0.5, -12),
        Size = UDim2.new(0, 24, 0, 24)
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

    local DiscordButton = CreateFooterButton("rbxassetid://18505728250", 1)

    MakeDraggable(MainFrame, Header)

    local Window = {}
    local NotificationsEnabled = true

    local ContextActionService = game:GetService("ContextActionService");
    local ShiftLockBlocked = false;

    local function ManageShiftLock()
        if ScreenGui.Enabled and not ShiftLockBlocked then
            ShiftLockBlocked = true;
            ContextActionService:BindAction("WisperBlockShiftLock", function(Name, InputState, Input)
                if Input.KeyCode == Enum.KeyCode.LeftShift or Input.KeyCode == Enum.KeyCode.RightShift then
                    return Enum.ContextActionResult.Sink;
                end;
                return Enum.ContextActionResult.Pass;
            end, false, Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift);
        elseif not ScreenGui.Enabled and ShiftLockBlocked then
            ShiftLockBlocked = false;
            pcall(function() ContextActionService:UnbindAction("WisperBlockShiftLock") end);
        end;
    end;

    local ShiftLockCorrectionLoop = RunService.RenderStepped:Connect(function()
        if ScreenGui.Enabled and workspace.CurrentCamera then
            local CameraSubject = workspace.CurrentCamera.CameraSubject;
            if CameraSubject and CameraSubject:IsA("Humanoid") then
                local RootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart");
                if RootPart then
                    local DistanceToHuman = (workspace.CurrentCamera.CFrame.Position - RootPart.Position).Magnitude;
                    if DistanceToHuman < 2 then
                        workspace.CurrentCamera.CFrame = RootPart.CFrame * CFrame.new(0, 0, 5);
                    end;
                end;
            end;
        end;
    end);

    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if not GameProcessed and Input.KeyCode == Config.KeyBind then
            ScreenGui.Enabled = not ScreenGui.Enabled
            NavContainer.Visible = ScreenGui.Enabled
            SearchContainer.Visible = ScreenGui.Enabled
            ManageShiftLock();
        end
    end)

    function Window:CreateTab(TabConfig)
        TabConfig = TabConfig or {}
        TabConfig.Name = TabConfig.Name or "Tab"
        TabConfig.Order = TabConfig.Order or (#Tabs + 1)
        
        local TabIcon = TabConfig.Icon and GetIcon(TabConfig.Icon) or GetAutoIcon(TabConfig.Name)

        local TabButtonData = CreateTabButton(TabIcon, TabConfig.Order, TabConfig.Name)

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

        table.insert(Tabs, {ButtonData = TabButtonData, Page = TabPage, Name = TabConfig.Name, Internal = TabConfig.Internal})
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

        if not TabConfig.Internal then
            local UserTabCount = 0;
            for _, T in pairs(Tabs) do
                if not T.Internal then
                    UserTabCount = UserTabCount + 1;
                end;
            end;
            if UserTabCount == 1 then
                SelectTab();
            end;
        end;

        local Tab = {}

        local CurrentTabIndex = #Tabs

        function Tab:CreateGroup(GroupConfig)
            GroupConfig = GroupConfig or {}
            GroupConfig.Name = GroupConfig.Name or "Group"
            GroupConfig.Icon = GroupConfig.Icon and GetIcon(GroupConfig.Icon) or GetAutoGroupIcon(GroupConfig.Name)
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
                BackgroundColor3 = Theme.GroupHeaderBase,
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
                BackgroundColor3 = Theme.GroupHeaderGradientBottom,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, -8),
                Size = UDim2.new(1, 0, 0, 8)
            })

            local GroupHeaderGradient = Create("UIGradient", {
                Name = "GroupHeaderGradient",
                Parent = GroupHeader,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.GroupHeaderGradientTop),
                    ColorSequenceKeypoint.new(1, Theme.GroupHeaderGradientBottom)
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
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
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
                        ColorSequenceKeypoint.new(0, Theme.ToggleInactiveGradientTop),
                        ColorSequenceKeypoint.new(1, Theme.ToggleInactiveGradientBottom)
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

                local HasColorPicker = ToggleConfig.Color ~= nil or ToggleConfig.ColorCallback ~= nil;
                local LabelRightOffset = HasColorPicker and 100 or 30;

                local ToggleLabel = Create("TextLabel", {
                    Name = "ToggleLabel",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 28, 0, 0),
                    Size = UDim2.new(1, -LabelRightOffset, 1, 0),
                    Font = Enum.Font.GothamMedium,
                    Text = ToggleConfig.Name,
                    TextColor3 = Toggled and Theme.Text or Theme.SubText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local CurrentColor = ToggleConfig.Color or Color3.fromRGB(255, 255, 255);
                local ColorPickerOpen = false;

                local ColorFrame = Create("Frame", {
                    Name = "ColorFrame",
                    Parent = ToggleFrame,
                    BackgroundColor3 = CurrentColor,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -50, 0.5, 0),
                    Size = UDim2.new(0, 20, 0, 20),
                    Visible = HasColorPicker
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
                    ZIndex = 100,
                    ClipsDescendants = true,
                    AnchorPoint = Vector2.new(0.5, 0.5)
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
                    ColorPickerPopup.Position = UDim2.new(0, MainFramePos.X + MainFrameSize.X + 97, 0, MainFramePos.Y + 125)
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
                local ColorPickerAnimToken = 0

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
                    ColorPickerAnimToken = ColorPickerAnimToken + 1
                    local CurrentToken = ColorPickerAnimToken

                    if ColorPickerOpen then
                        UpdatePickerPosition()
                        ColorPickerPopup.Size = UDim2.new(0, 0, 0, 0)
                        ColorPickerPopup.BackgroundTransparency = 1
                        ColorPickerPopup.Visible = true
                        Tween(ColorPickerPopup, {Size = UDim2.new(0, 174, 0, 150)}, 0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        Tween(ColorPickerPopup, {BackgroundTransparency = 0}, 0.2)
                    else
                        Tween(ColorPickerPopup, {Size = UDim2.new(0, 0, 0, 0)}, 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                        Tween(ColorPickerPopup, {BackgroundTransparency = 1}, 0.2)
                        task.delay(0.2, function()
                            if not ColorPickerOpen and CurrentToken == ColorPickerAnimToken then
                                ColorPickerPopup.Visible = false
                            end
                        end)
                    end
                end)

                local KeybindFrame = Create("Frame", {
                    Name = "KeybindFrame",
                    Parent = ToggleFrame,
                    BackgroundColor3 = Theme.ControlBackground,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 45, 0, 20),
                    Visible = HasColorPicker
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
                    if IsMobile then return end;
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
                    Size = UDim2.new(1, HasColorPicker and -75 or 0, 1, 0),
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

                ConfigStateRegistry[ToggleConfig.Name] = {
                    Type = "Toggle",
                    Get = function() return Toggled end,
                    Set = function(V) Toggled = V; UpdateToggle() end,
                };

                if HasColorPicker then
                    KeybindRegistry[ToggleConfig.Name] = {
                        GetKey = function() return CurrentKeybind end,
                        GetActive = function() return Toggled end,
                    };
                end;
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
                        ColorSequenceKeypoint.new(0, Theme.GradientColor1),
                        ColorSequenceKeypoint.new(1, Theme.GradientColor2)
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
                local SliderCallbackDelay = 0.08
                local SliderCallbackToken = 0
                local TargetPercent = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                local DisplayPercent = TargetPercent
                local LastDispatchedValue = Value

                local function DispatchSliderCallback(NewValue)
                    SliderCallbackToken = SliderCallbackToken + 1
                    local CurrentToken = SliderCallbackToken

                    task.delay(SliderCallbackDelay, function()
                        if CurrentToken == SliderCallbackToken then
                            SliderConfig.Callback(NewValue)
                        end
                    end)
                end

                local function SetSliderTargetFromInput(Input)
                    TargetPercent = math.clamp((Input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                end

                SliderClickArea.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                        SetSliderTargetFromInput(Input)
                    end
                end)

                SliderClickArea.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        SetSliderTargetFromInput(Input)
                    end
                end)

                RunService.RenderStepped:Connect(function()
                    local SmoothFactor = Dragging and 0.26 or 0.18
                    DisplayPercent = DisplayPercent + (TargetPercent - DisplayPercent) * SmoothFactor

                    if math.abs(TargetPercent - DisplayPercent) < 0.001 then
                        DisplayPercent = TargetPercent
                    end

                    Value = math.floor(SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * DisplayPercent)
                    SliderValue.Text = tostring(Value) .. SliderConfig.Suffix
                    SliderFill.Size = UDim2.new(DisplayPercent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(DisplayPercent, 0, 0.5, 0)

                    if Value ~= LastDispatchedValue then
                        LastDispatchedValue = Value
                        DispatchSliderCallback(Value)
                    end
                end)

                DispatchSliderCallback(Value)

                local SliderAPI = {}

                function SliderAPI:Set(NewValue)
                    Value = math.clamp(NewValue, SliderConfig.Min, SliderConfig.Max)
                    local Percent = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    TargetPercent = Percent
                    DisplayPercent = Percent
                    LastDispatchedValue = Value
                    SliderValue.Text = tostring(Value) .. SliderConfig.Suffix
                    SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(Percent, 0, 0.5, 0)
                    DispatchSliderCallback(Value)
                end

                function SliderAPI:Get()
                    return Value
                end

                ConfigStateRegistry[SliderConfig.Name] = {
                    Type = "Slider",
                    Get = function() return Value end,
                    Set = function(V) SliderAPI:Set(V) end,
                };

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
                    BackgroundColor3 = Theme.SeparatorLine,
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
                    TextColor3 = Theme.SeparatorText,
                    TextSize = 13,
                    AutomaticSize = Enum.AutomaticSize.X
                })

                local RightLine = Create("Frame", {
                    Name = "RightLine",
                    Parent = SeparatorFrame,
                    BackgroundColor3 = Theme.SeparatorLine,
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
                    BackgroundColor3 = Theme.ControlBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 30)
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

                ConfigStateRegistry[InputConfig.Name] = {
                    Type = "Input",
                    Get = function() return InputTextBox.Text end,
                    Set = function(V) InputTextBox.Text = tostring(V or "") end,
                };

                return InputAPI
            end

            function Group:CreateCombobox(ComboboxConfig)
                ComboboxConfig = ComboboxConfig or {}
                ComboboxConfig.Name = ComboboxConfig.Name or "Combobox"
                ComboboxConfig.Options = ComboboxConfig.Options or {}
                ComboboxConfig.Default = ComboboxConfig.Default or {}
                ComboboxConfig.SingleSelect = ComboboxConfig.SingleSelect or false
                ComboboxConfig.Callback = ComboboxConfig.Callback or function() end

                ShowContentIfNeeded()

                local Selected = {}
                for _, v in ipairs(ComboboxConfig.Default) do
                    Selected[v] = true
                    if ComboboxConfig.SingleSelect then
                        break
                    end
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
                    BackgroundColor3 = Theme.ControlBackground,
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
                    if ComboboxConfig.SingleSelect then
                        return Items[1]
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
                    BackgroundColor3 = Theme.ControlBackground,
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
                        if ComboboxConfig.SingleSelect then
                            for _, Opt in ipairs(ComboboxConfig.Options) do
                                local IsCurrent = Opt == Option
                                Selected[Opt] = IsCurrent

                                local Data = OptionButtons[Opt]
                                if Data then
                                    if IsCurrent then
                                        Tween(Data.Fill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15)
                                        Data.Label.TextColor3 = Color3.fromRGB(0, 0, 0)
                                    else
                                        Tween(Data.Fill, {Size = UDim2.new(0, 0, 1, 0)}, 0.15)
                                        Data.Label.TextColor3 = Theme.SubText
                                    end
                                end
                            end

                            IsOpen = false
                            Tween(ComboboxDropdown, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
                            task.delay(0.15, function()
                                if not IsOpen then
                                    ComboboxDropdown.Visible = false
                                end
                            end)
                            Tween(ComboboxIcon, {Rotation = 0}, 0.15)
                        else
                            Selected[Option] = not Selected[Option]
                            if Selected[Option] then
                                Tween(OptionFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15)
                                OptionLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
                            else
                                Tween(OptionFill, {Size = UDim2.new(0, 0, 1, 0)}, 0.15)
                                OptionLabel.TextColor3 = Theme.SubText
                            end
                        end

                        ComboboxText.Text = GetSelectedText()

                        local SelectedItems = {}
                        for _, Opt in ipairs(ComboboxConfig.Options) do
                            if Selected[Opt] then
                                table.insert(SelectedItems, Opt)
                            end
                        end

                        if ComboboxConfig.SingleSelect then
                            ComboboxConfig.Callback(SelectedItems[1])
                        else
                            ComboboxConfig.Callback(SelectedItems)
                        end
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
                    if ComboboxConfig.SingleSelect then
                        local SelectedItem = typeof(Items) == "table" and Items[1] or Items
                        if SelectedItem then
                            Selected[SelectedItem] = true
                        end
                    else
                        for _, Item in ipairs(Items) do
                            Selected[Item] = true
                        end
                    end

                    ComboboxText.Text = GetSelectedText()
                    for Option, Data in pairs(OptionButtons) do
                        if Selected[Option] then
                            Data.Fill.Size = UDim2.new(1, 0, 1, 0)
                        else
                            Data.Fill.Size = UDim2.new(0, 0, 1, 0)
                        end
                        Data.Label.TextColor3 = Selected[Option] and Color3.fromRGB(0, 0, 0) or Theme.SubText
                    end

                    if ComboboxConfig.SingleSelect then
                        local SelectedValue = nil
                        for _, Option in ipairs(ComboboxConfig.Options) do
                            if Selected[Option] then
                                SelectedValue = Option
                                break
                            end
                        end
                        ComboboxConfig.Callback(SelectedValue)
                    else
                        ComboboxConfig.Callback(Items)
                    end
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

                function ComboboxAPI:Refresh(NewOptions)
                    for _, Data in pairs(OptionButtons) do
                        Data.Button:Destroy();
                    end;
                    OptionButtons = {};
                    Selected = {};
                    ComboboxConfig.Options = NewOptions;
                    ComboboxText.Text = GetSelectedText();
                    for i, Option in ipairs(NewOptions) do
                        local OptionButton = Create("TextButton", {
                            Name = "Option_" .. Option, Parent = ComboboxDropdown,
                            BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 28),
                            Font = Enum.Font.Gotham, Text = "", AutoButtonColor = false,
                            LayoutOrder = i, ZIndex = 11
                        });
                        local OptionFillContainer = Create("Frame", {
                            Name = "FillContainer", Parent = OptionButton,
                            BackgroundTransparency = 1, Position = UDim2.new(0, 4, 0, 2),
                            Size = UDim2.new(1, -8, 1, -4), ZIndex = 11, ClipsDescendants = true
                        });
                        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionFillContainer});
                        local OptionFill = Create("Frame", {
                            Name = "Fill", Parent = OptionFillContainer,
                            BackgroundColor3 = Color3.fromRGB(255, 255, 255), BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(0, 0, 1, 0), ZIndex = 11
                        });
                        Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = OptionFill});
                        Create("UIGradient", {Parent = OptionFill,
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Theme.GradientColor1),
                                ColorSequenceKeypoint.new(1, Theme.GradientColor2)
                            }), Rotation = 0});
                        local OptionLabel = Create("TextLabel", {
                            Name = "OptionLabel", Parent = OptionButton,
                            BackgroundTransparency = 1, Position = UDim2.new(0, 12, 0, 0),
                            Size = UDim2.new(1, -24, 1, 0), Font = Enum.Font.Gotham, Text = Option,
                            TextColor3 = Theme.SubText, TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 12
                        });
                        OptionButton.MouseEnter:Connect(function()
                            if not Selected[Option] then Tween(OptionLabel, {TextColor3 = Theme.Text}, 0.1) end;
                        end);
                        OptionButton.MouseLeave:Connect(function()
                            if not Selected[Option] then Tween(OptionLabel, {TextColor3 = Theme.SubText}, 0.1) end;
                        end);
                        OptionButton.MouseButton1Click:Connect(function()
                            if ComboboxConfig.SingleSelect then
                                for _, Opt in ipairs(ComboboxConfig.Options) do
                                    local IsCurrent = Opt == Option;
                                    Selected[Opt] = IsCurrent;
                                    local BData = OptionButtons[Opt];
                                    if BData then
                                        if IsCurrent then
                                            Tween(BData.Fill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15);
                                            BData.Label.TextColor3 = Color3.fromRGB(0, 0, 0);
                                        else
                                            Tween(BData.Fill, {Size = UDim2.new(0, 0, 1, 0)}, 0.15);
                                            BData.Label.TextColor3 = Theme.SubText;
                                        end;
                                    end;
                                end;
                                IsOpen = false;
                                Tween(ComboboxDropdown, {Size = UDim2.new(1, 0, 0, 0)}, 0.15);
                                task.delay(0.15, function() if not IsOpen then ComboboxDropdown.Visible = false end end);
                                Tween(ComboboxIcon, {Rotation = 0}, 0.15);
                            else
                                Selected[Option] = not Selected[Option];
                                if Selected[Option] then
                                    Tween(OptionFill, {Size = UDim2.new(1, 0, 1, 0)}, 0.15);
                                    OptionLabel.TextColor3 = Color3.fromRGB(0, 0, 0);
                                else
                                    Tween(OptionFill, {Size = UDim2.new(0, 0, 1, 0)}, 0.15);
                                    OptionLabel.TextColor3 = Theme.SubText;
                                end;
                            end;
                            ComboboxText.Text = GetSelectedText();
                            local SelectedItems = {};
                            for _, Opt in ipairs(ComboboxConfig.Options) do
                                if Selected[Opt] then table.insert(SelectedItems, Opt) end;
                            end;
                            if ComboboxConfig.SingleSelect then
                                ComboboxConfig.Callback(SelectedItems[1]);
                            else
                                ComboboxConfig.Callback(SelectedItems);
                            end;
                        end);
                        OptionButtons[Option] = {Button = OptionButton, Fill = OptionFill, Label = OptionLabel};
                    end;
                    DropdownHeight = #NewOptions * 28 + 8;
                    if IsOpen then
                        ComboboxDropdown.Size = UDim2.new(1, 0, 0, DropdownHeight);
                    end;
                end;

                ConfigStateRegistry[ComboboxConfig.Name] = {
                    Type = "Combobox",
                    Get = function() return ComboboxAPI:Get() end,
                    Set = function(V) ComboboxAPI:Set(V) end,
                };

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
                    BackgroundColor3 = Theme.ControlBackground,
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
                    Tween(ButtonContainer, {BackgroundColor3 = Theme.ControlHover}, 0.15)
                end)

                ButtonClickArea.MouseLeave:Connect(function()
                    Tween(ButtonText, {TextColor3 = Theme.SubText}, 0.15)
                    Tween(ButtonContainer, {BackgroundColor3 = Theme.ControlBackground}, 0.15)
                end)

                ButtonClickArea.MouseButton1Click:Connect(function()
                    ButtonConfig.Callback()
                end)

                return ButtonFrame
            end

            function Group:CreateKeybind(KeybindConfig)
                KeybindConfig = KeybindConfig or {};
                KeybindConfig.Name = KeybindConfig.Name or "Keybind";
                KeybindConfig.Default = KeybindConfig.Default or nil;
                KeybindConfig.Callback = KeybindConfig.Callback or function() end;

                ShowContentIfNeeded();

                local CurrentKey = KeybindConfig.Default;
                local WaitingForKey = false;

                local KeybindRowFrame = Create("Frame", {
                    Name = "Keybind_" .. KeybindConfig.Name,
                    Parent = GroupContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24)
                });

                local KeybindNameLabel = Create("TextLabel", {
                    Name = "KeybindLabel",
                    Parent = KeybindRowFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -72, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = KeybindConfig.Name,
                    TextColor3 = Theme.SubText,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                });

                local KeybindBox = Create("Frame", {
                    Name = "KeybindFrame",
                    Parent = KeybindRowFrame,
                    BackgroundColor3 = Theme.ControlBackground,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 68, 0, 20)
                });

                Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KeybindBox});

                local KeybindLabel = Create("TextLabel", {
                    Name = "KeybindText",
                    Parent = KeybindBox,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = CurrentKey and CurrentKey.Name or "None",
                    TextColor3 = Theme.SubText,
                    TextSize = 11
                });

                local KeybindClickArea = Create("TextButton", {
                    Parent = KeybindBox,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 2
                });

                KeybindBox.MouseEnter:Connect(function()
                    if not WaitingForKey then
                        Tween(KeybindLabel, {TextColor3 = Theme.Text}, 0.15);
                    end;
                end);

                KeybindBox.MouseLeave:Connect(function()
                    if not WaitingForKey then
                        Tween(KeybindLabel, {TextColor3 = Theme.SubText}, 0.15);
                    end;
                end);

                KeybindClickArea.MouseButton1Click:Connect(function()
                    if IsMobile then return end;
                    WaitingForKey = true;
                    KeybindLabel.Text = "...";
                    KeybindLabel.TextColor3 = Theme.Text;
                end);

                UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                    if WaitingForKey and Input.UserInputType == Enum.UserInputType.Keyboard then
                        CurrentKey = Input.KeyCode;
                        KeybindLabel.Text = Input.KeyCode.Name;
                        KeybindLabel.TextColor3 = Theme.SubText;
                        WaitingForKey = false;
                        KeybindConfig.Callback(CurrentKey);
                    end;
                end);

                local KeybindAPI = {};

                function KeybindAPI:Set(Key)
                    CurrentKey = Key;
                    KeybindLabel.Text = Key and Key.Name or "None";
                    KeybindConfig.Callback(CurrentKey);
                end;

                function KeybindAPI:Get()
                    return CurrentKey;
                end;

                if KeybindConfig.Name ~= "Open / Close Menu" then
                    KeybindRegistry[KeybindConfig.Name] = {
                        GetKey = function() return CurrentKey end,
                        GetActive = nil,
                    };
                end;

                return KeybindAPI;
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

    local function CopyTextToClipboard(Text)
        local Success = pcall(function()
            if setclipboard then
                setclipboard(Text)
                return
            end

            if toclipboard then
                toclipboard(Text)
                return
            end

            error("Clipboard function is unavailable")
        end)

        return Success
    end

    local function ApplyThemePreset(PresetName)
        local Preset = ThemePresets[PresetName]
        if not Preset then
            return false
        end

        Theme = Preset

        MainFrame.BackgroundColor3 = Theme.Background
        Header.BackgroundColor3 = Theme.Header
        HeaderCoverBottom.BackgroundColor3 = Theme.Header
        HeaderLine.BackgroundColor3 = Theme.HeaderLine
        AvatarStroke.Color = Theme.AvatarStroke
        TitleMaskedLabel.TextColor3 = Theme.Text
        TitleRealLabel.TextColor3 = Theme.Text
        SubtitleLabel.TextColor3 = Theme.SubText
        NavContainer.BackgroundColor3 = Theme.ButtonInactive
        SearchContainer.BackgroundColor3 = Theme.ButtonInactive
        SearchIcon.ImageColor3 = Theme.SubText
        SearchInput.TextColor3 = Theme.Text
        SearchInput.PlaceholderColor3 = Theme.SubText
        ContentContainer.BackgroundColor3 = Theme.ContentBackground
        Footer.BackgroundColor3 = Theme.Footer
        FooterCoverTop.BackgroundColor3 = Theme.Footer
        FooterIcon.ImageColor3 = Theme.Accent
        FooterTitle.TextColor3 = Theme.Text
        FooterSubtitle.TextColor3 = Theme.SubText
        DiscordButton.ImageColor3 = Theme.SubText

        for _, Descendant in ipairs(ScreenGui:GetDescendants()) do
            if Descendant:IsA("Frame") then
                if string.sub(Descendant.Name, 1, 6) == "Group_" then
                    Descendant.BackgroundColor3 = Theme.GroupBackground
                elseif Descendant.Name == "GroupHeader" then
                    Descendant.BackgroundColor3 = Theme.GroupHeaderBase
                elseif Descendant.Name == "BottomFix" and Descendant.Parent and Descendant.Parent.Name == "GroupHeader" then
                    Descendant.BackgroundColor3 = Theme.GroupHeaderGradientBottom
                elseif Descendant.Name == "HeaderLine" and Descendant.Parent and Descendant.Parent.Name == "GroupHeader" then
                    Descendant.BackgroundColor3 = Theme.GroupStroke
                elseif Descendant.Name == "InputBox" then
                    Descendant.BackgroundColor3 = Theme.ControlBackground
                elseif Descendant.Name == "ComboboxButton" or Descendant.Name == "ComboboxDropdown" or Descendant.Name == "ButtonContainer" or Descendant.Name == "KeybindFrame" then
                    Descendant.BackgroundColor3 = Theme.ControlBackground
                elseif Descendant.Name == "SliderBackground" then
                    Descendant.BackgroundColor3 = Theme.SliderBackground
                elseif Descendant.Name == "LeftLine" or Descendant.Name == "RightLine" then
                    Descendant.BackgroundColor3 = Theme.SeparatorLine
                end
            elseif Descendant:IsA("TextLabel") then
                if Descendant.Name == "InputLabel" or Descendant.Name == "ComboboxLabel" or Descendant.Name == "ToggleLabel" or Descendant.Name == "ButtonText" or Descendant.Name == "SliderLabel" or Descendant.Name == "LabelText" or Descendant.Name == "ComboboxText" or Descendant.Name == "KeybindText" then
                    Descendant.TextColor3 = Theme.SubText
                elseif Descendant.Name == "SliderValue" then
                    Descendant.TextColor3 = Theme.Text
                elseif Descendant.Name == "GroupLabel" then
                    Descendant.TextColor3 = Theme.Text
                elseif Descendant.Name == "SeparatorText" then
                    Descendant.TextColor3 = Theme.SeparatorText
                end
            elseif Descendant:IsA("TextBox") then
                if Descendant.Name == "InputTextBox" then
                    Descendant.TextColor3 = Theme.Text
                    Descendant.PlaceholderColor3 = Theme.SubText
                end
            elseif Descendant:IsA("UIStroke") then
                if Descendant.Parent and (Descendant.Parent.Name == "ColorPickerPopup" or string.sub(Descendant.Parent.Name, 1, 6) == "Group_") then
                    Descendant.Color = Theme.GroupStroke
                end
            elseif Descendant:IsA("UIGradient") then
                if Descendant.Name == "GroupHeaderGradient" then
                    Descendant.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.GroupHeaderGradientTop),
                        ColorSequenceKeypoint.new(1, Theme.GroupHeaderGradientBottom)
                    })
                elseif Descendant.Name == "InactiveGradient" then
                    Descendant.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.ToggleInactiveGradientTop),
                        ColorSequenceKeypoint.new(1, Theme.ToggleInactiveGradientBottom)
                    })
                elseif Descendant.Parent and (Descendant.Parent.Name == "Fill" or Descendant.Parent.Name == "SliderFill" or Descendant.Parent.Name == "CheckContainer") then
                    Descendant.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Theme.GradientColor1),
                        ColorSequenceKeypoint.new(1, Theme.GradientColor2)
                    })
                end
            elseif Descendant:IsA("ImageLabel") then
                if Descendant.Name == "InputIcon" or Descendant.Name == "ComboboxIcon" or Descendant.Name == "GroupIcon" then
                    Descendant.ImageColor3 = Theme.SubText
                end
            end
        end

        return true
    end

    function Window:SetNotificationsEnabled(Value)
        NotificationsEnabled = Value and true or false
    end

    function Window:GetNotificationsEnabled()
        return NotificationsEnabled
    end

    function Window:SetTheme(ThemeName)
        return ApplyThemePreset(ThemeName)
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

        if not NotificationsEnabled then
            return nil
        end

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
            BackgroundColor3 = Theme.InputBackground,
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

    DiscordButton.MouseButton1Click:Connect(function()
        local InviteLink = "https://discord.gg/BWcBPbWpkP"
        local Copied = CopyTextToClipboard(InviteLink)

        if Copied then
            Window:Notify({
                Title = "Discord",
                Description = "Link copiado para o clipboard!",
                Duration = 3
            })
        else
            Window:Notify({
                Title = "Discord",
                Description = "Nao foi possivel copiar automaticamente.",
                Duration = 3
            })
        end
    end)

    local SettingsTab = Window:CreateTab({
        Name = "Settings",
        Icon = "settings",
        Order = 999999,
        Internal = true
    });

    local InterfaceGroup = SettingsTab:CreateGroup({
        Name = "Interface",
        Column = "Left"
    });

    InterfaceGroup:CreateCombobox({
        Name = "Theme",
        Options = {"Default", "White"},
        Default = {"Default"},
        SingleSelect = true,
        Callback = function(ThemeName)
            if ThemeName then
                Window:SetTheme(ThemeName);
            end;
        end
    });

    InterfaceGroup:CreateToggle({
        Name = "Notifications",
        Default = true,
        Callback = function(Value)
            Window:SetNotificationsEnabled(Value);
        end
    });

    --// Floating Keybind Panel //--
    local KeybindPanel = Create("Frame", {
        Name = "KeybindPanel",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.GroupBackground,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -20, 0.5, 0),
        Size = UDim2.new(0, 200, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 200,
        ClipsDescendants = false,
    });

    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeybindPanel});
    Create("UIStroke", {Parent = KeybindPanel, Color = Theme.GroupStroke, Thickness = 1});

    local KeybindPanelHeader = Create("Frame", {
        Name = "Header",
        Parent = KeybindPanel,
        BackgroundColor3 = Theme.GroupHeaderBase,
        Size = UDim2.new(1, 0, 0, 36),
        ClipsDescendants = true,
        ZIndex = 201,
    });
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = KeybindPanelHeader});
    Create("Frame", {
        Parent = KeybindPanelHeader,
        BackgroundColor3 = Theme.GroupHeaderGradientBottom,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
    });
    Create("UIGradient", {
        Parent = KeybindPanelHeader,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.GroupHeaderGradientTop),
            ColorSequenceKeypoint.new(1, Theme.GroupHeaderGradientBottom),
        }),
        Rotation = 90,
    });
    Create("Frame", {
        Parent = KeybindPanelHeader,
        BackgroundColor3 = Theme.GroupStroke,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
    });

    local KeybindPanelIcon = Create("ImageLabel", {
        Name = "PanelIcon",
        Parent = KeybindPanelHeader,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0.5, -8),
        Size = UDim2.new(0, 16, 0, 16),
        Image = GetIcon("keyboard"),
        ImageColor3 = Theme.SubText,
        ZIndex = 202,
    });

    Create("TextLabel", {
        Parent = KeybindPanelHeader,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 34, 0, 0),
        Size = UDim2.new(1, -44, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "Keybinds",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 202,
    });

    local KeybindPanelContent = Create("Frame", {
        Name = "Content",
        Parent = KeybindPanel,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 201,
    });

    Create("UIListLayout", {Parent = KeybindPanelContent, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)});
    Create("UIPadding", {
        Parent = KeybindPanelContent,
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 8),
    });

    local KeybindPanelRows = {};

    local function RefreshKeybindPanel()
        for _, Row in pairs(KeybindPanelRows) do
            Row:Destroy();
        end;
        table.clear(KeybindPanelRows);

        local HasAny = false;
        for Name, Entry in pairs(KeybindRegistry) do
            if Name == "Open / Close Menu" then continue end;
            local Key = Entry.GetKey();
            if Key == nil then continue end;
            HasAny = true;
            local IsActive = Entry.GetActive and Entry.GetActive() or false;
            local KeyText = Key.Name;

            local Row = Create("Frame", {
                Name = "Row_" .. Name,
                Parent = KeybindPanelContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                ZIndex = 202,
            });

            Create("TextLabel", {
                Parent = Row,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -56, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = Name,
                TextColor3 = Entry.GetActive ~= nil and (IsActive and Theme.Accent or Theme.SubText) or Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 202,
            });

            local KeyBox = Create("Frame", {
                Name = "KeyBox",
                Parent = Row,
                BackgroundColor3 = Theme.ControlBackground,
                BorderSizePixel = 0,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, 0, 0.5, 0),
                Size = UDim2.new(0, 52, 0, 18),
                ZIndex = 202,
            });
            Create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = KeyBox});

            Create("TextLabel", {
                Parent = KeyBox,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.Gotham,
                Text = KeyText,
                TextColor3 = Entry.GetActive ~= nil and (IsActive and Theme.Accent or Theme.SubText) or Theme.SubText,
                TextSize = 10,
                ZIndex = 203,
            });

            table.insert(KeybindPanelRows, Row);
        end;

        if not HasAny then
            local Empty = Create("TextLabel", {
                Name = "EmptyLabel",
                Parent = KeybindPanelContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = "No keybinds registered.",
                TextColor3 = Theme.SubText,
                TextSize = 11,
                ZIndex = 202,
            });
            table.insert(KeybindPanelRows, Empty);
        end;
    end;

    -- Drag logic for the floating panel
    MakeDraggable(KeybindPanel, KeybindPanelHeader);

    -- Periodically refresh the panel while visible so active states update
    RunService.RenderStepped:Connect(function()
        if KeybindPanel.Visible then
            for _, Row in ipairs(KeybindPanelRows) do
                if Row.Parent == KeybindPanelContent then
                    local NameLabel = Row:FindFirstChildOfClass("TextLabel");
                    local KeyBoxLabel = Row:FindFirstChild("KeyBox") and Row.KeyBox:FindFirstChildOfClass("TextLabel");
                    local Name = Row.Name:gsub("^Row_", "");
                    local Entry = KeybindRegistry[Name];
                    if Entry then
                        local IsActive = Entry.GetActive and Entry.GetActive() or false;
                        local Key = Entry.GetKey();
                        local Color = Entry.GetActive ~= nil and (IsActive and Theme.Accent or Theme.SubText) or Theme.SubText;
                        if NameLabel then NameLabel.TextColor3 = Color end;
                        if KeyBoxLabel then
                            KeyBoxLabel.TextColor3 = Color;
                            KeyBoxLabel.Text = Key and Key.Name or "None";
                        end;
                    end;
                end;
            end;
        end;
    end);

    InterfaceGroup:CreateToggle({
        Name = "Show Keybinds",
        Default = false,
        Callback = function(Value)
            if Value then
                RefreshKeybindPanel();
                KeybindPanel.Visible = true;
            else
                KeybindPanel.Visible = false;
            end;
        end
    });

    local MenuGroup = SettingsTab:CreateGroup({
        Name = "Menu",
        Column = "Left"
    });

    MenuGroup:CreateKeybind({
        Name = "Open / Close Menu",
        Default = Config.KeyBind,
        Callback = function(Key)
            Config.KeyBind = Key;
        end
    });

    MenuGroup:CreateButton({
        Name = "Unload",
        Callback = function()
            ScreenGui:Destroy();
        end
    });

    --// Configuration Group //--
    local ConfigGroup = SettingsTab:CreateGroup({
        Name = "Configuration",
        Column = "Right"
    });

    ConfigGroup:CreateSeparator({Text = "Create"});

    local ConfigNameInput = ConfigGroup:CreateInput({
        Name = "Config Name",
        Placeholder = "Enter name...",
        Callback = function() end
    });

    ConfigGroup:CreateButton({
        Name = "Create Config",
        Callback = function()
            local RawName = ConfigNameInput:Get();
            local SafeName = RawName:gsub("[^%w_%-%s]", ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", "_");
            if #SafeName == 0 then
                Window:Notify({Title = "Config", Description = "Enter a config name first.", Duration = 3});
                return;
            end;
            local Ok = SaveConfig(SafeName);
            if Ok then
                ConfigDropdown:Refresh(GetConfigNames());
                Window:Notify({Title = "Config", Description = "Config \"" .. SafeName .. "\" created.", Duration = 3});
            else
                Window:Notify({Title = "Config", Description = "Failed to save config (no filesystem access?).", Duration = 4});
            end;
        end
    });

    ConfigGroup:CreateSeparator({Text = "Manage"});

    local ConfigDropdown = ConfigGroup:CreateCombobox({
        Name = "Saved Configs",
        Options = GetConfigNames(),
        Default = {},
        SingleSelect = true,
        Callback = function() end
    });

    ConfigGroup:CreateButton({
        Name = "Load Config",
        Callback = function()
            local Selected = ConfigDropdown:Get();
            if #Selected == 0 then
                Window:Notify({Title = "Config", Description = "Select a config from the dropdown first.", Duration = 3});
                return;
            end;
            local Ok = LoadConfig(Selected[1]);
            if Ok then
                Window:Notify({Title = "Config", Description = "Config \"" .. Selected[1] .. "\" loaded.", Duration = 3});
            else
                Window:Notify({Title = "Config", Description = "Config not found or corrupted.", Duration = 3});
            end;
        end
    });

    ConfigGroup:CreateButton({
        Name = "Overwrite Config",
        Callback = function()
            local Selected = ConfigDropdown:Get();
            if #Selected == 0 then
                Window:Notify({Title = "Config", Description = "Select a config to overwrite.", Duration = 3});
                return;
            end;
            local Ok = SaveConfig(Selected[1]);
            if Ok then
                Window:Notify({Title = "Config", Description = "Config \"" .. Selected[1] .. "\" overwritten.", Duration = 3});
            else
                Window:Notify({Title = "Config", Description = "Failed to overwrite config.", Duration = 3});
            end;
        end
    });

    ConfigGroup:CreateButton({
        Name = "Delete Config",
        Callback = function()
            local Selected = ConfigDropdown:Get();
            if #Selected == 0 then
                Window:Notify({Title = "Config", Description = "Select a config to delete.", Duration = 3});
                return;
            end;
            local Name = Selected[1];
            DeleteConfig(Name);
            if ActiveAutoloadConfig == Name then
                ClearAutoloadConfig();
            end;
            ConfigDropdown:Refresh(GetConfigNames());
            Window:Notify({Title = "Config", Description = "Config \"" .. Name .. "\" deleted.", Duration = 3});
        end
    });

    ConfigGroup:CreateButton({
        Name = "Refresh List",
        Callback = function()
            ConfigDropdown:Refresh(GetConfigNames());
            Window:Notify({Title = "Config", Description = "Config list refreshed.", Duration = 2});
        end
    });

    ConfigGroup:CreateButton({
        Name = "Set Autoload",
        Callback = function()
            local Selected = ConfigDropdown:Get();
            if #Selected == 0 then
                Window:Notify({Title = "Autoload", Description = "Select a config to set as autoload.", Duration = 3});
                return;
            end;
            SetAutoloadConfig(Selected[1]);
            AutoloadLabel:Set("Autoload: " .. Selected[1]);
            Window:Notify({Title = "Autoload", Description = "Autoload set to \"" .. Selected[1] .. "\".", Duration = 3});
        end
    });

    ConfigGroup:CreateButton({
        Name = "Reset Autoload",
        Callback = function()
            ClearAutoloadConfig();
            AutoloadLabel:Set("Autoload: none");
            Window:Notify({Title = "Autoload", Description = "Autoload cleared.", Duration = 3});
        end
    });

    local InitialAutoload = GetAutoloadConfigName();
    ActiveAutoloadConfig = InitialAutoload;
    local AutoloadLabel = ConfigGroup:CreateLabel({
        Text = "Autoload: " .. (InitialAutoload or "none")
    });

    if InitialAutoload then
        task.defer(function()
            LoadConfig(InitialAutoload);
        end);
    end;

    return Window
end

return WisperLib
