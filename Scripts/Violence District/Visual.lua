--[[
    -- rwque --
]]
local Wisper = _G.Wisper

local Visual = {
    Connections = {},
    ESP = {
        lastUpdate = 0,
        UPDATE_INTERVAL = 0.2,
        settings = {
            Survivors  = {Enabled=false, Color=Color3.fromRGB(100,255,100), Colorpicker = nil},
            Killers    = {Enabled=false, Color=Color3.fromRGB(255,100,100), Colorpicker = nil},
            Generators = {Enabled=false, Color=Color3.fromRGB(100,170,255), Colorpicker = nil},
            Pallets    = {Enabled=false, Color=Color3.fromRGB(120,80,40), Colorpicker = nil},
            ExitGates  = {Enabled=false, Color=Color3.fromRGB(200,200,100), Colorpicker = nil},
            Windows    = {Enabled=false, Color=Color3.fromRGB(100,200,200), Colorpicker = nil},
            Hooks      = {Enabled=false, Color=Color3.fromRGB(100, 50, 150), Colorpicker = nil},
            Gifts      = {Enabled=false, Color=Color3.fromRGB(255, 182, 193), Colorpicker = nil}  -- Добавлен Gift ESP
        },
        trackedObjects = {},
        espConnections = {},
        espLoopRunning = false,
        showGeneratorPercent = true,
        autoFarmGiftEnabled = false,  
        autoFarmRunning = false,
        currentGiftIndex = 1
    },
    AdvancedESP = {
        settings = {
            enabled = false,
            name = true,
            distance = true,
            healthbar = true,
            box = true,
            boxType = "full",
            bones = true,
            boneColorName = "White",
            tracers = true,
            tracerColorName = "White",
            scale = 1.5,
            healthBarTopColorName = "DarkGreen",
            healthBarMidColorName = "DarkOrange",
            healthBarBottomColorName = "DarkRed",
            stateColorName = "Orange",
            boxOutline = true,
            boxOutlineColorName = "Black",
            boxOutlineThickness = 0.4,
            boxColorName = "White",
            boxFill = true,
            boxFillColorName = "White",
            boxFillTransparency = 0.9,
            healthBarLeftOffset = 10,
            updateInterval = 0.05,
            healthStripes = 24
        },
        colorMap = {
            Red = Color3.fromRGB(255,0,0),
            DarkRed = Color3.fromRGB(100,0,0),
            Green = Color3.fromRGB(0,255,0),
            DarkGreen = Color3.fromRGB(0,80,0),
            Blue = Color3.fromRGB(0,0,255),
            LightBlue = Color3.fromRGB(200,200,255),
            Yellow = Color3.fromRGB(255,255,0),
            Orange = Color3.fromRGB(255,165,0),
            DarkOrange = Color3.fromRGB(140,70,0),
            Purple = Color3.fromRGB(128,0,128),
            White = Color3.fromRGB(255,255,255),
            Black = Color3.fromRGB(0,0,0)
        },
        connections = {},
        espObjects = {},
        playerConnections = {}
    },
    Effects = {
        noShadowEnabled = false,
        noFogEnabled = false,
        fullbrightEnabled = false,
        timeChangerEnabled = false,
        originalFogEnd = nil,
        originalFogStart = nil,
        originalFogColor = nil,
        fogCache = nil,
        originalClockTime = nil        
    }
}

function Visual.GetGeneratorProgress(gen)
    local progress = 0
    if gen:GetAttribute("Progress") then
        progress = gen:GetAttribute("Progress")
    elseif gen:GetAttribute("RepairProgress") then
        progress = gen:GetAttribute("RepairProgress")
    else
        for _, child in ipairs(gen:GetDescendants()) do
            if child:IsA("NumberValue") or child:IsA("IntValue") then
                local n = child.Name:lower()
                if n:find("progress") or n:find("repair") or n:find("percent") then
                    progress = child.Value
                    break
