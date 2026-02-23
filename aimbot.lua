-- Universal Aimbot & ESP Script
-- Features: 2D Boxes, Tracers, Name Tags, Health Bars, Off-Screen Arrows, Aimbot (Camera/Mouse), FOV Circle

--[ Services ]--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")

--[ Local Player Setup ]--
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

--[ Pre-declare variables used across the script ]--
local CharacterCache = {}
local FriendCache = {}
local CurrentTarget = nil
local SoundESPIndicators = {}
local Aiming = false
local TriggerbotHeld = false
local TriggerbotToggled = false

--[ WindUI Initialization ]--
-- Updated URL to official source to fix "arithmetic on nil" error
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Universal Aimbot & ESP",
    Icon = "target",
    Theme = "Dark",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Blur = true,
})

--[ Configuration ]--
getgenv().AimbotESPSettings = {
    Aimbot = {
        Enabled = false,
        Keybind = Enum.UserInputType.MouseButton2,
        Method = "Camera",
        TargetPart = "Head",
        Priority = "FOV",
        FOV = {
            Enabled = true,
            Radius = 150,
            Dynamic = false,
            Color = Color3.fromRGB(255, 255, 255),
            Sides = 60,
            Thickness = 1,
            Transparency = 1,
        },
        Smoothness = {
            Enabled = true,
            Value = 0.5,
            Humanize = false,
        },
        Prediction = {
            Enabled = false,
            VelocityCompensation = 0.165,
            BulletDrop = 0,
            ShowDot = false,
        },
        Hitchance = 100,
        Triggerbot = {
            Enabled = false,
            Delay = 0,
            Keybind = Enum.UserInputType.MouseButton3,
            RequireKeybind = false,
            SpoofMethod = "firesignal",
            KeybindMode = "Hold",
            IgnoreWall = false,
            MultiRay = true,
            RaySpread = 3,
            TeamCheck = true,
        },
        SilentAim = {
            Enabled = false,
            Method = "Raycast",
        },
        RCS = {
            Enabled = false,
            Horizontal = 1,
            Vertical = 1,
            Smoothness = 0.5,
        },
        NoSpread = {
            Enabled = false,
            Strength = 1,
        },
        RageMode = false,
        WallCheck = true,
        TeamCheck = false,
        AliveCheck = true,
    },
    ESP = {
        Enabled = false,
        WallCheck = false,
        Boxes = {
            Enabled = false,
            Style = "2D",
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1,
            Transparency = 1,
            Filled = false,
            FillTransparency = 0.5,
            Outline = true,
            OutlineColor = Color3.fromRGB(0, 0, 0),
        },
        Skeleton = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1,
            Transparency = 1,
        },
        HeadDot = {
            Enabled = false,
            Color = Color3.fromRGB(255, 0, 0),
            Radius = 4,
            Filled = true,
            Transparency = 1,
        },
        Names = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 16,
            Font = 2,
            Outline = true,
        },
        Distance = {
            Enabled = false,
            Color = Color3.fromRGB(200, 200, 200),
            Size = 14,
            Font = 2,
            Outline = true,
        },
        Weapon = {
            Enabled = false,
            Color = Color3.fromRGB(150, 150, 255),
            Size = 14,
            Font = 2,
            Outline = true,
        },
        Flags = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 12,
            Font = 2,
            Outline = true,
        },
        Health = {
            Enabled = false,
            BarColor = Color3.fromRGB(0, 255, 0),
            BackgroundColor = Color3.fromRGB(255, 0, 0),
            Thickness = 2,
        },
        Shield = {
            Enabled = false,
            BarColor = Color3.fromRGB(0, 200, 255),
            Thickness = 2,
        },
        Tracers = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Thickness = 1,
            Transparency = 1,
            Origin = "Bottom",
        },
        Arrows = {
            Enabled = false,
            Color = Color3.fromRGB(255, 255, 255),
            Size = 25,
            Radius = 200,
            Filled = true,
            Transparency = 1,
        },
        Chams = {
            Enabled = false,
            FillColor = Color3.fromRGB(255, 0, 0),
            FillTransparency = 0.5,
            OutlineColor = Color3.fromRGB(255, 255, 255),
            OutlineTransparency = 0,
            VisibleOnly = false,
        },
        Items = {
            Enabled = false,
            Color = Color3.fromRGB(255, 215, 0),
            MaxDistance = 500,
            ShowDistance = true,
        },
        Sounds = {
            Enabled = false,
            Color = Color3.fromRGB(255, 100, 100),
            MaxDistance = 200,
            Duration = 2,
        },
        Radar = {
            Enabled = false,
            Position = Vector2.new(20, 50),
            Size = 150,
            Range = 500,
            BgColor = Color3.fromRGB(25, 25, 25),
            BgTransparency = 0.8,
            DotColor = Color3.fromRGB(255, 0, 0),
            DotSize = 3,
        },
        DormantCheck = false,
        MaxDistance = 1000,
        TeamCheck = false,
        TeamColors = false,
        UseVisibleColor = false,
        VisibleColor = Color3.fromRGB(0, 255, 0),
        EnemyColor = Color3.fromRGB(255, 0, 0),
        FriendlyColor = Color3.fromRGB(0, 255, 0),
        ToggleKey = Enum.KeyCode.F1,
        AliveCheck = true,
    },
    GUIToggleKey = Enum.KeyCode.RightShift,
}

local C = getgenv().AimbotESPSettings

--[ Persistence Functions ]--
local ConfigFile = "UniversalAimbotESP_Config.json"

local function SaveConfig()
    local function ColorToTable(color)
        return { r = color.R, g = color.G, b = color.B }
    end

    local function Serialize(t)
        local serialized = {}
        for k, v in pairs(t) do
            if typeof(v) == "table" then
                serialized[k] = Serialize(v)
            elseif typeof(v) == "Color3" then
                serialized[k] = { Type = "Color3", Value = ColorToTable(v) }
            elseif typeof(v) == "EnumItem" then
                serialized[k] = { Type = "EnumItem", Value = tostring(v) }
            elseif typeof(v) == "Vector2" then
                serialized[k] = { Type = "Vector2", X = v.X, Y = v.Y }
            else
                serialized[k] = v
            end
        end
        return serialized
    end

    local success, err = pcall(function()
        writefile(ConfigFile, HttpService:JSONEncode(Serialize(C)))
    end)
    if success then
        WindUI:Notify({ Title = "Config Saved", Content = "Saved to " .. ConfigFile })
    else
        warn("Failed to save config: " .. tostring(err))
    end
end

local function LoadConfig()
    if not isfile or not isfile(ConfigFile) then
        return
    end

    local function TableToColor(t)
        return Color3.new(t.r, t.g, t.b)
    end

    local function Deserialize(target, source)
        for k, v in pairs(source) do
            if typeof(v) == "table" then
                if v.Type == "Color3" then
                    target[k] = TableToColor(v.Value)
                elseif v.Type == "EnumItem" then
                    local s = v.Value:split(".")
                    if #s == 3 then
                        pcall(function()
                            target[k] = Enum[s[2]][s[3]]
                        end)
                    end
                elseif v.Type == "Vector2" then
                    target[k] = Vector2.new(v.X, v.Y)
                else
                    if typeof(target[k]) == "table" then
                        Deserialize(target[k], v)
                    else
                        target[k] = v
                    end
                end
            else
                target[k] = v
            end
        end
    end

    local success, err = pcall(function()
        local data = HttpService:JSONDecode(readfile(ConfigFile))
        Deserialize(C, data)
    end)
    if success then
        WindUI:Notify({ Title = "Config Loaded", Content = "Loaded from " .. ConfigFile })
    else
        warn("Failed to load config: " .. tostring(err))
    end
end

--[ WindUI Tabs ]--
local AimbotTab = Window:Tab({ Title = "Aimbot", Icon = "crosshair" })
local ESPTab = Window:Tab({ Title = "ESP", Icon = "eye" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

--===================--
--   AIMBOT TAB UI   --
--===================--

local AimbotMainSection = AimbotTab:Section({ Title = "Main" })

AimbotMainSection:Toggle({
    Title = "Enable Aimbot",
    Default = C.Aimbot.Enabled,
    Callback = function(v)
        C.Aimbot.Enabled = v
    end,
})

AimbotMainSection:Dropdown({
    Title = "Aim Method",
    Values = { "Camera", "Mouse" },
    Value = C.Aimbot.Method,
    Callback = function(v)
        C.Aimbot.Method = v
    end,
})

AimbotMainSection:Dropdown({
    Title = "Target Part",
    Values = { "Head", "Neck", "Chest", "Pelvis", "Feet" },
    Value = C.Aimbot.TargetPart,
    Callback = function(v)
        C.Aimbot.TargetPart = v
    end,
})

AimbotMainSection:Dropdown({
    Title = "Target Priority",
    Values = { "FOV", "Distance", "Lowest HP", "Visible" },
    Value = C.Aimbot.Priority,
    Callback = function(v)
        C.Aimbot.Priority = v
    end,
})

AimbotMainSection:Toggle({
    Title = "Rage Mode (Override Checks)",
    Default = C.Aimbot.RageMode,
    Callback = function(v)
        C.Aimbot.RageMode = v
    end,
})

AimbotMainSection:Toggle({
    Title = "Wall Check",
    Default = C.Aimbot.WallCheck,
    Callback = function(v)
        C.Aimbot.WallCheck = v
    end,
})

AimbotMainSection:Toggle({
    Title = "Team Check",
    Default = C.Aimbot.TeamCheck,
    Callback = function(v)
        C.Aimbot.TeamCheck = v
    end,
})

AimbotMainSection:Toggle({
    Title = "Alive Check",
    Default = C.Aimbot.AliveCheck,
    Callback = function(v)
        C.Aimbot.AliveCheck = v
    end,
})

-- FOV Section
local FOVSection = AimbotTab:Section({ Title = "FOV Settings" })

FOVSection:Toggle({
    Title = "Show FOV Circle",
    Default = C.Aimbot.FOV.Enabled,
    Callback = function(v)
        C.Aimbot.FOV.Enabled = v
    end,
})

FOVSection:Toggle({
    Title = "Dynamic FOV (Scales w/ Zoom)",
    Default = C.Aimbot.FOV.Dynamic,
    Callback = function(v)
        C.Aimbot.FOV.Dynamic = v
    end,
})

FOVSection:Slider({
    Title = "FOV Radius",
    Value = { Min = 10, Max = 800, Default = C.Aimbot.FOV.Radius },
    Callback = function(v)
        C.Aimbot.FOV.Radius = v
    end,
})

FOVSection:Colorpicker({
    Title = "FOV Color",
    Default = C.Aimbot.FOV.Color,
    Callback = function(v)
        C.Aimbot.FOV.Color = v
    end,
})

-- Aim Mechanics Section
local MechanicsSection = AimbotTab:Section({ Title = "Aim Mechanics" })

MechanicsSection:Slider({
    Title = "Hitchance (%)",
    Value = { Min = 1, Max = 100, Default = C.Aimbot.Hitchance },
    Callback = function(v)
        C.Aimbot.Hitchance = v
    end,
})

MechanicsSection:Toggle({
    Title = "Enable Smoothness",
    Default = C.Aimbot.Smoothness.Enabled,
    Callback = function(v)
        C.Aimbot.Smoothness.Enabled = v
    end,
})

MechanicsSection:Slider({
    Title = "Smoothness Value",
    Value = { Min = 1, Max = 100, Default = math.floor(C.Aimbot.Smoothness.Value * 100) },
    Callback = function(v)
        C.Aimbot.Smoothness.Value = v / 100
    end,
})

MechanicsSection:Toggle({
    Title = "Humanize Aim (Randomized Path)",
    Default = C.Aimbot.Smoothness.Humanize,
    Callback = function(v)
        C.Aimbot.Smoothness.Humanize = v
    end,
})

-- Prediction & Triggerbot Section
local PredSection = AimbotTab:Section({ Title = "Prediction & Triggerbot" })

PredSection:Toggle({
    Title = "Enable Prediction",
    Default = C.Aimbot.Prediction.Enabled,
    Callback = function(v)
        C.Aimbot.Prediction.Enabled = v
    end,
})

PredSection:Toggle({
    Title = "Show Predicted Dot",
    Default = C.Aimbot.Prediction.ShowDot,
    Callback = function(v)
        C.Aimbot.Prediction.ShowDot = v
    end,
})

PredSection:Toggle({
    Title = "Enable Triggerbot (Auto-Shoot)",
    Default = C.Aimbot.Triggerbot.Enabled,
    Callback = function(v)
        C.Aimbot.Triggerbot.Enabled = v
    end,
})

PredSection:Slider({
    Title = "Triggerbot Delay (ms)",
    Value = { Min = 0, Max = 1000, Default = math.floor(C.Aimbot.Triggerbot.Delay * 1000) },
    Callback = function(v)
        C.Aimbot.Triggerbot.Delay = v / 1000
    end,
})

PredSection:Toggle({
    Title = "Require Keybind (Hold to Shoot)",
    Default = C.Aimbot.Triggerbot.RequireKeybind,
    Callback = function(v)
        C.Aimbot.Triggerbot.RequireKeybind = v
    end,
})

PredSection:Dropdown({
    Title = "Spoofing Method",
    Values = { "firesignal", "VirtualInputManager", "mouse1click" },
    Value = C.Aimbot.Triggerbot.SpoofMethod,
    Callback = function(v)
        C.Aimbot.Triggerbot.SpoofMethod = v
    end,
})

PredSection:Dropdown({
    Title = "Keybind Mode",
    Values = { "Hold", "Toggle" },
    Value = C.Aimbot.Triggerbot.KeybindMode,
    Callback = function(v)
        C.Aimbot.Triggerbot.KeybindMode = v
    end,
})

PredSection:Toggle({
    Title = "Ignore Wall (Rage)",
    Default = C.Aimbot.Triggerbot.IgnoreWall,
    Callback = function(v)
        C.Aimbot.Triggerbot.IgnoreWall = v
    end,
})

PredSection:Toggle({
    Title = "Multi-Ray (Gap Detection)",
    Default = C.Aimbot.Triggerbot.MultiRay,
    Callback = function(v)
        C.Aimbot.Triggerbot.MultiRay = v
    end,
})

PredSection:Toggle({
    Title = "Team Check",
    Default = C.Aimbot.Triggerbot.TeamCheck,
    Callback = function(v)
        C.Aimbot.Triggerbot.TeamCheck = v
    end,
})

-- Advanced Section
local AdvancedSection = AimbotTab:Section({ Title = "Advanced (Generic Hooks)" })

AdvancedSection:Toggle({
    Title = "Enable Silent Aim (Experimental)",
    Default = C.Aimbot.SilentAim.Enabled,
    Callback = function(v)
        C.Aimbot.SilentAim.Enabled = v
    end,
})

AdvancedSection:Toggle({
    Title = "Enable No Spread (Experimental)",
    Default = C.Aimbot.NoSpread.Enabled,
    Callback = function(v)
        C.Aimbot.NoSpread.Enabled = v
    end,
})

-- RCS Section
local RCSSection = AimbotTab:Section({ Title = "RCS (Recoil Control)" })

RCSSection:Toggle({
    Title = "Enable RCS",
    Default = C.Aimbot.RCS.Enabled,
    Callback = function(v)
        C.Aimbot.RCS.Enabled = v
    end,
})

RCSSection:Slider({
    Title = "Horizontal Strength",
    Value = { Min = 0, Max = 200, Default = math.floor(C.Aimbot.RCS.Horizontal * 100) },
    Callback = function(v)
        C.Aimbot.RCS.Horizontal = v / 100
    end,
})

RCSSection:Slider({
    Title = "Vertical Strength",
    Value = { Min = 0, Max = 200, Default = math.floor(C.Aimbot.RCS.Vertical * 100) },
    Callback = function(v)
        C.Aimbot.RCS.Vertical = v / 100
    end,
})

--================--
--   ESP TAB UI   --
--================--

local ESPMainSection = ESPTab:Section({ Title = "Main" })

ESPMainSection:Toggle({
    Title = "Enable ESP",
    Default = C.ESP.Enabled,
    Callback = function(v)
        C.ESP.Enabled = v
    end,
})

ESPMainSection:Toggle({
    Title = "Team Check",
    Default = C.ESP.TeamCheck,
    Callback = function(v)
        C.ESP.TeamCheck = v
    end,
})

ESPMainSection:Toggle({
    Title = "Alive Check",
    Default = C.ESP.AliveCheck,
    Callback = function(v)
        C.ESP.AliveCheck = v
    end,
})

ESPMainSection:Toggle({
    Title = "Use Team Colors",
    Default = C.ESP.TeamColors,
    Callback = function(v)
        C.ESP.TeamColors = v
    end,
})

ESPMainSection:Slider({
    Title = "Max Distance",
    Value = { Min = 100, Max = 5000, Default = C.ESP.MaxDistance },
    Callback = function(v)
        C.ESP.MaxDistance = v
    end,
})

ESPMainSection:Toggle({
    Title = "Dormant Check (Far Players)",
    Default = C.ESP.DormantCheck,
    Callback = function(v)
        C.ESP.DormantCheck = v
    end,
})

ESPMainSection:Toggle({
    Title = "ESP Wall Check (Vis Color)",
    Default = C.ESP.WallCheck,
    Callback = function(v)
        C.ESP.WallCheck = v
    end,
})

-- Visuals Section
local VisualsSection = ESPTab:Section({ Title = "Visuals" })

VisualsSection:Toggle({
    Title = "Show Boxes",
    Default = C.ESP.Boxes.Enabled,
    Callback = function(v)
        C.ESP.Boxes.Enabled = v
    end,
})

VisualsSection:Dropdown({
    Title = "Box Style",
    Values = { "2D", "Corner", "3D" },
    Value = C.ESP.Boxes.Style,
    Callback = function(v)
        C.ESP.Boxes.Style = v
    end,
})

VisualsSection:Toggle({
    Title = "Box Outline",
    Default = C.ESP.Boxes.Outline,
    Callback = function(v)
        C.ESP.Boxes.Outline = v
    end,
})

VisualsSection:Toggle({
    Title = "Box Filled",
    Default = C.ESP.Boxes.Filled,
    Callback = function(v)
        C.ESP.Boxes.Filled = v
    end,
})

VisualsSection:Slider({
    Title = "Box Fill Transparency",
    Value = { Min = 0, Max = 100, Default = math.floor(C.ESP.Boxes.FillTransparency * 100) },
    Callback = function(v)
        C.ESP.Boxes.FillTransparency = v / 100
    end,
})

VisualsSection:Toggle({
    Title = "Show Skeleton",
    Default = C.ESP.Skeleton.Enabled,
    Callback = function(v)
        C.ESP.Skeleton.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Head Dot",
    Default = C.ESP.HeadDot.Enabled,
    Callback = function(v)
        C.ESP.HeadDot.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Names",
    Default = C.ESP.Names.Enabled,
    Callback = function(v)
        C.ESP.Names.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Distance",
    Default = C.ESP.Distance.Enabled,
    Callback = function(v)
        C.ESP.Distance.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Weapon",
    Default = C.ESP.Weapon.Enabled,
    Callback = function(v)
        C.ESP.Weapon.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Flags",
    Default = C.ESP.Flags.Enabled,
    Callback = function(v)
        C.ESP.Flags.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Health Bars",
    Default = C.ESP.Health.Enabled,
    Callback = function(v)
        C.ESP.Health.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Shield/Armor Bars",
    Default = C.ESP.Shield.Enabled,
    Callback = function(v)
        C.ESP.Shield.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Tracers",
    Default = C.ESP.Tracers.Enabled,
    Callback = function(v)
        C.ESP.Tracers.Enabled = v
    end,
})

VisualsSection:Dropdown({
    Title = "Tracer Origin",
    Values = { "Bottom", "Mouse", "Center" },
    Value = C.ESP.Tracers.Origin,
    Callback = function(v)
        C.ESP.Tracers.Origin = v
    end,
})

VisualsSection:Toggle({
    Title = "Show Off-Screen Arrows",
    Default = C.ESP.Arrows.Enabled,
    Callback = function(v)
        C.ESP.Arrows.Enabled = v
    end,
})

VisualsSection:Toggle({
    Title = "Enable Chams (Highlights)",
    Default = C.ESP.Chams.Enabled,
    Callback = function(v)
        C.ESP.Chams.Enabled = v
    end,
})

-- Sound ESP Section
local SoundSection = ESPTab:Section({ Title = "Sound ESP" })

SoundSection:Toggle({
    Title = "Enable Sound ESP",
    Default = C.ESP.Sounds.Enabled,
    Callback = function(v)
        C.ESP.Sounds.Enabled = v
    end,
})

SoundSection:Slider({
    Title = "Indicator Duration (s)",
    Value = { Min = 1, Max = 10, Default = C.ESP.Sounds.Duration },
    Callback = function(v)
        C.ESP.Sounds.Duration = v
    end,
})

SoundSection:Colorpicker({
    Title = "Sound Color",
    Default = C.ESP.Sounds.Color,
    Callback = function(v)
        C.ESP.Sounds.Color = v
    end,
})

-- Radar Section
local RadarSection = ESPTab:Section({ Title = "2D Radar" })

RadarSection:Toggle({
    Title = "Enable Radar",
    Default = C.ESP.Radar.Enabled,
    Callback = function(v)
        C.ESP.Radar.Enabled = v
    end,
})

RadarSection:Slider({
    Title = "Radar Size",
    Value = { Min = 50, Max = 400, Default = C.ESP.Radar.Size },
    Callback = function(v)
        C.ESP.Radar.Size = v
    end,
})

RadarSection:Slider({
    Title = "Radar Range",
    Value = { Min = 100, Max = 2000, Default = C.ESP.Radar.Range },
    Callback = function(v)
        C.ESP.Radar.Range = v
    end,
})

RadarSection:Slider({
    Title = "Radar Transparency",
    Value = { Min = 0, Max = 100, Default = math.floor(C.ESP.Radar.BgTransparency * 100) },
    Callback = function(v)
        C.ESP.Radar.BgTransparency = v / 100
    end,
})

RadarSection:Slider({
    Title = "Dot Size",
    Value = { Min = 1, Max = 10, Default = C.ESP.Radar.DotSize },
    Callback = function(v)
        C.ESP.Radar.DotSize = v
    end,
})

-- Items Section
local ItemsSection = ESPTab:Section({ Title = "Generic Items/Loot ESP" })

ItemsSection:Toggle({
    Title = "Enable Item ESP",
    Default = C.ESP.Items.Enabled,
    Callback = function(v)
        C.ESP.Items.Enabled = v
    end,
})

ItemsSection:Toggle({
    Title = "Show Item Distance",
    Default = C.ESP.Items.ShowDistance,
    Callback = function(v)
        C.ESP.Items.ShowDistance = v
    end,
})

ItemsSection:Slider({
    Title = "Item Max Distance",
    Value = { Min = 100, Max = 5000, Default = C.ESP.Items.MaxDistance },
    Callback = function(v)
        C.ESP.Items.MaxDistance = v
    end,
})

-- Colors Section
local ColorsSection = ESPTab:Section({ Title = "Colors" })

ColorsSection:Toggle({
    Title = "Use Visible Color",
    Default = C.ESP.UseVisibleColor,
    Callback = function(v)
        C.ESP.UseVisibleColor = v
    end,
})

ColorsSection:Colorpicker({
    Title = "Visible Color",
    Default = C.ESP.VisibleColor,
    Callback = function(v)
        C.ESP.VisibleColor = v
    end,
})

ColorsSection:Colorpicker({
    Title = "Box Outline Color",
    Default = C.ESP.Boxes.OutlineColor,
    Callback = function(v)
        C.ESP.Boxes.OutlineColor = v
    end,
})

ColorsSection:Colorpicker({
    Title = "Shield Bar Color",
    Default = C.ESP.Shield.BarColor,
    Callback = function(v)
        C.ESP.Shield.BarColor = v
    end,
})

ColorsSection:Colorpicker({
    Title = "Radar Background Color",
    Default = C.ESP.Radar.BgColor,
    Callback = function(v)
        C.ESP.Radar.BgColor = v
    end,
})

ColorsSection:Colorpicker({
    Title = "Radar Dot Color",
    Default = C.ESP.Radar.DotColor,
    Callback = function(v)
        C.ESP.Radar.DotColor = v
    end,
})

ColorsSection:Colorpicker({
    Title = "Enemy Color",
    Default = C.ESP.EnemyColor,
    Callback = function(v)
        C.ESP.EnemyColor = v
    end,
})

ColorsSection:Colorpicker({
    Title = "Friendly Color",
    Default = C.ESP.FriendlyColor,
    Callback = function(v)
        C.ESP.FriendlyColor = v
    end,
})

--=====================--
--   SETTINGS TAB UI   --
--=====================--

local SettingsSection = SettingsTab:Section({ Title = "Configuration" })

SettingsSection:Button({
    Title = "Save Configuration",
    Callback = function()
        SaveConfig()
    end,
})

SettingsSection:Button({
    Title = "Load Configuration",
    Callback = function()
        LoadConfig()
    end,
})

local PresetsSection = SettingsTab:Section({ Title = "Presets" })

PresetsSection:Button({
    Title = "Load Legit Preset",
    Callback = function()
        C.Aimbot.Enabled = true
        C.Aimbot.Method = "Camera"
        C.Aimbot.Smoothness.Enabled = true
        C.Aimbot.Smoothness.Value = 0.2
        C.Aimbot.Smoothness.Humanize = true
        C.Aimbot.Hitchance = 85
        C.Aimbot.FOV.Radius = 100
        C.Aimbot.SilentAim.Enabled = false
        C.Aimbot.RCS.Enabled = true
        C.ESP.Enabled = true
        C.ESP.Boxes.Enabled = true
        C.ESP.Boxes.Style = "2D"
        C.ESP.Chams.Enabled = false
        WindUI:Notify({ Title = "Preset Loaded", Content = "Legit configuration applied." })
    end,
})

PresetsSection:Button({
    Title = "Load Rage Preset",
    Callback = function()
        C.Aimbot.Enabled = true
        C.Aimbot.Method = "Camera"
        C.Aimbot.Smoothness.Enabled = false
        C.Aimbot.Hitchance = 100
        C.Aimbot.FOV.Radius = 800
        C.Aimbot.SilentAim.Enabled = true
        C.Aimbot.RCS.Enabled = false
        C.Aimbot.Prediction.Enabled = true
        C.ESP.Enabled = true
        C.ESP.Boxes.Enabled = true
        C.ESP.Boxes.Style = "Corner"
        C.ESP.Chams.Enabled = true
        WindUI:Notify({ Title = "Preset Loaded", Content = "Rage configuration applied." })
    end,
})

local KeybindsSection = SettingsTab:Section({ Title = "Keybinds" })

KeybindsSection:Keybind({
    Title = "Aimbot Activation",
    Value = "MouseButton2",
    Callback = function(k)
        if k and k ~= "" then
            local key = tostring(k)
            if Enum.UserInputType[key] then
                C.Aimbot.Keybind = Enum.UserInputType[key]
            elseif Enum.KeyCode[key] then
                C.Aimbot.Keybind = Enum.KeyCode[key]
            end
        end
    end,
})

KeybindsSection:Keybind({
    Title = "Triggerbot Key",
    Value = "MouseButton3",
    Callback = function(k)
        if k and k ~= "" then
            local key = tostring(k)
            if Enum.UserInputType[key] then
                C.Aimbot.Triggerbot.Keybind = Enum.UserInputType[key]
            elseif Enum.KeyCode[key] then
                C.Aimbot.Triggerbot.Keybind = Enum.KeyCode[key]
            end
        end
    end,
})

KeybindsSection:Keybind({
    Title = "Toggle ESP",
    Value = "F1",
    Callback = function(k)
        if Enum.KeyCode[k] then
            C.ESP.ToggleKey = Enum.KeyCode[k]
        end
    end,
})

KeybindsSection:Keybind({
    Title = "Toggle GUI",
    Value = "RightShift",
    Callback = function(k)
        if Enum.KeyCode[k] then
            C.GUIToggleKey = Enum.KeyCode[k]
            Window:SetToggleKey(Enum.KeyCode[k])
        end
    end,
})

local DangerSection = SettingsTab:Section({ Title = "Script Control" })

DangerSection:Button({
    Title = "Unload Script",
    Callback = function()
        if getgenv().UniversalAimbotESPConnections then
            for _, conn in pairs(getgenv().UniversalAimbotESPConnections) do
                pcall(function()
                    conn:Disconnect()
                end)
            end
        end
        if getgenv().UniversalAimbotESPDrawings then
            for _, obj in pairs(getgenv().UniversalAimbotESPDrawings) do
                pcall(function()
                    obj:Remove()
                end)
            end
        end
        if getgenv().UniversalItemESPDrawings then
            for _, obj in pairs(getgenv().UniversalItemESPDrawings) do
                pcall(function()
                    obj:Remove()
                end)
            end
        end
        for _, obj in pairs(SoundESPIndicators) do
            pcall(function()
                obj:Remove()
            end)
        end
        pcall(function()
            if ChamsFolder then
                ChamsFolder:Destroy()
            end
        end)
        Window:Destroy()
        print("Universal Aimbot & ESP unloaded!")
    end,
})

--[ Cleanup / Unload Previous Execution ]--
if getgenv().UniversalAimbotESPConnections then
    for _, conn in pairs(getgenv().UniversalAimbotESPConnections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
end
if getgenv().UniversalAimbotESPDrawings then
    for _, obj in pairs(getgenv().UniversalAimbotESPDrawings) do
        pcall(function()
            obj:Remove()
        end)
    end
end
if getgenv().UniversalItemESPDrawings then
    for _, obj in pairs(getgenv().UniversalItemESPDrawings) do
        pcall(function()
            obj:Remove()
        end)
    end
end

getgenv().UniversalAimbotESPConnections = {}
getgenv().UniversalAimbotESPDrawings = {}
getgenv().UniversalItemESPDrawings = {}
local Drawings = getgenv().UniversalAimbotESPDrawings
local ItemDrawings = getgenv().UniversalItemESPDrawings

--[ Utility Functions ]--
local Utils = {}

function Utils.CreateDrawing(drawType, props)
    local obj = Drawing.new(drawType)
    for i, v in pairs(props) do
        obj[i] = v
    end
    table.insert(Drawings, obj)
    return obj
end

function Utils.CreateItemDrawing(drawType, props)
    local obj = Drawing.new(drawType)
    for i, v in pairs(props) do
        obj[i] = v
    end
    table.insert(ItemDrawings, obj)
    return obj
end

function Utils.IsFriend(player)
    if FriendCache[player.UserId] ~= nil then
        return FriendCache[player.UserId]
    end
    local success, isFriend = pcall(function()
        return LocalPlayer:IsFriendsWith(player.UserId)
    end)
    if success then
        FriendCache[player.UserId] = isFriend
        return isFriend
    end
    return false
end

function Utils.GetCharacterInfo(player)
    if CharacterCache[player] and CharacterCache[player].Character == player.Character then
        local cached = CharacterCache[player]
        if cached.Humanoid and cached.Humanoid.Parent and cached.Humanoid.Health > 0 and cached.RootPart and cached.RootPart.Parent then
            return cached.Character, cached.Humanoid, cached.RootPart
        end
    end

    local character = player.Character
    if not character then
        return nil
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart or humanoid.Health <= 0 then
        return nil
    end

    CharacterCache[player] = {
        Character = character,
        Humanoid = humanoid,
        RootPart = rootPart,
    }

    return character, humanoid, rootPart
end

function Utils.IsTeammate(player)
    if not LocalPlayer.Team then
        return false
    end
    return player.Team == LocalPlayer.Team
end

function Utils.IsAlive(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    return humanoid.Health > 0
end

function Utils.WallCheck(origin, destination, ignoreList)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = ignoreList
    params.IgnoreWater = true
    local ray = Workspace:Raycast(origin, destination - origin, params)
    return ray == nil
end

function Utils.GetColor(player, isVisible)
    if C.ESP.TeamColors and player.Team then
        return player.TeamColor.Color
    end
    if C.ESP.UseVisibleColor and isVisible then
        return C.ESP.VisibleColor
    end
    if C.ESP.TeamCheck and Utils.IsTeammate(player) then
        return C.ESP.FriendlyColor
    end
    return C.ESP.EnemyColor
end

function Utils.GetShield(character)
    local shield = character:GetAttribute("Shield") or character:GetAttribute("Armor")
    if not shield then
        local sv = character:FindFirstChild("Shield") or character:FindFirstChild("Armor")
        if sv and (sv:IsA("NumberValue") or sv:IsA("IntValue")) then
            shield = sv.Value
        end
    end
    return shield or 0
end

function Utils.GetMaxShield(character)
    local maxShield = character:GetAttribute("MaxShield") or character:GetAttribute("MaxArmor")
    if not maxShield then
        local msv = character:FindFirstChild("MaxShield") or character:FindFirstChild("MaxArmor")
        if msv and (msv:IsA("NumberValue") or msv:IsA("IntValue")) then
            maxShield = msv.Value
        end
    end
    return maxShield or 100
end

function Utils.GetWeapon(character)
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        return tool.Name
    end
    return "None"
end

function Utils.GetDynamicFOV()
    if not C.Aimbot.FOV.Dynamic then
        return C.Aimbot.FOV.Radius
    end
    local zoom = (Camera.CFrame.Position - Camera.Focus.Position).Magnitude
    local fov = Camera.FieldOfView
    local scaled = (C.Aimbot.FOV.Radius * 70 / fov) * (10 / math.max(1, zoom))
    return math.clamp(scaled, 10, C.Aimbot.FOV.Radius * 2)
end

function Utils.GetTargetPart(character, targetName)
    local isR15 = character:FindFirstChild("UpperTorso") ~= nil

    if targetName == "Head" then
        return character:FindFirstChild("Head")
    elseif targetName == "Neck" then
        return character:FindFirstChild(isR15 and "UpperTorso" or "Head")
    elseif targetName == "Chest" then
        return character:FindFirstChild(isR15 and "UpperTorso" or "Torso")
    elseif targetName == "Pelvis" then
        return character:FindFirstChild(isR15 and "LowerTorso" or "Torso")
    elseif targetName == "Feet" then
        return character:FindFirstChild(isR15 and "LeftFoot" or "Left Leg")
    end

    return character:FindFirstChild(targetName) or character:FindFirstChild("HumanoidRootPart")
end

function Utils.PredictPosition(part, velocity, distance)
    if not C.Aimbot.Prediction.Enabled then
        return part.Position
    end
    local timeToHit = distance * C.Aimbot.Prediction.VelocityCompensation
    local drop = Vector3.new(0, C.Aimbot.Prediction.BulletDrop * (timeToHit ^ 2), 0)
    return part.Position + (velocity * timeToHit) + drop
end

function Utils.Get3DBoxCorners(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local size = Vector3.new(4, 5, 1)
    local cframe = root.CFrame

    local corners = {
        cframe * CFrame.new(-size.X / 2, size.Y / 2, -size.Z / 2),
        cframe * CFrame.new(size.X / 2, size.Y / 2, -size.Z / 2),
        cframe * CFrame.new(-size.X / 2, -size.Y / 2, -size.Z / 2),
        cframe * CFrame.new(size.X / 2, -size.Y / 2, -size.Z / 2),
        cframe * CFrame.new(-size.X / 2, size.Y / 2, size.Z / 2),
        cframe * CFrame.new(size.X / 2, size.Y / 2, size.Z / 2),
        cframe * CFrame.new(-size.X / 2, -size.Y / 2, size.Z / 2),
        cframe * CFrame.new(size.X / 2, -size.Y / 2, size.Z / 2),
    }

    local screenCorners = {}
    for i, corner in ipairs(corners) do
        local p, on = Camera:WorldToViewportPoint(corner.Position)
        if not on then
            return nil
        end
        screenCorners[i] = Vector2.new(p.X, p.Y)
    end
    return screenCorners
end

function Utils.GetSkeletonJoints(character)
    local joints = {}
    local isR15 = character:FindFirstChild("UpperTorso") ~= nil

    local partNames = isR15
            and {
                "Head",
                "UpperTorso",
                "LowerTorso",
                "LeftUpperArm",
                "LeftLowerArm",
                "LeftHand",
                "RightUpperArm",
                "RightLowerArm",
                "RightHand",
                "LeftUpperLeg",
                "LeftLowerLeg",
                "LeftFoot",
                "RightUpperLeg",
                "RightLowerLeg",
                "RightFoot",
            }
        or {
            "Head",
            "Torso",
            "Left Arm",
            "Right Arm",
            "Left Leg",
            "Right Leg",
        }

    for _, name in ipairs(partNames) do
        local part = character:FindFirstChild(name)
        if part then
            local p, on = Camera:WorldToViewportPoint(part.Position)
            if on then
                joints[name] = Vector2.new(p.X, p.Y)
            end
        end
    end
    return joints, isR15
end

--[ ESP System ]--
local ESPObjects = {}
local ItemESPObjects = {}
local ChamsFolder = Instance.new("Folder")
ChamsFolder.Name = "UniversalChams"
ChamsFolder.Parent = CoreGui

local RadarBg = Utils.CreateDrawing("Square", {
    Filled = true,
    Visible = false,
    ZIndex = 0,
})

local FOVCircle = Utils.CreateDrawing("Circle", {
    Visible = false,
    ZIndex = 0,
})

local PredictDot = Utils.CreateDrawing("Circle", {
    Filled = true,
    Radius = 4,
    ZIndex = 5,
    Visible = false,
    Color = Color3.fromRGB(255, 255, 0),
})

--[ Input Handling ]--
Window:SetToggleKey(C.GUIToggleKey)

table.insert(getgenv().UniversalAimbotESPConnections, UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if input.UserInputType == C.Aimbot.Keybind or input.KeyCode == C.Aimbot.Keybind then
        Aiming = true
    end
    if input.UserInputType == C.Aimbot.Triggerbot.Keybind or input.KeyCode == C.Aimbot.Triggerbot.Keybind then
        print("Triggerbot key pressed:", tostring(input.UserInputType), "==", tostring(C.Aimbot.Triggerbot.Keybind))
        if C.Aimbot.Triggerbot.KeybindMode == "Toggle" then
            TriggerbotToggled = not TriggerbotToggled
            print("Triggerbot toggled:", TriggerbotToggled)
        else
            TriggerbotHeld = true
            print("Triggerbot held: true")
        end
    end
    if input.KeyCode == C.ESP.ToggleKey then
        C.ESP.Enabled = not C.ESP.Enabled
        WindUI:Notify({ Title = "ESP", Content = C.ESP.Enabled and "Enabled" or "Disabled" })
    end
end))

table.insert(getgenv().UniversalAimbotESPConnections, UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == C.Aimbot.Keybind or input.KeyCode == C.Aimbot.Keybind then
        Aiming = false
    end
    if input.UserInputType == C.Aimbot.Triggerbot.Keybind or input.KeyCode == C.Aimbot.Triggerbot.Keybind then
        print("Triggerbot key released:", tostring(input.UserInputType))
        if C.Aimbot.Triggerbot.KeybindMode == "Hold" then
            TriggerbotHeld = false
            print("Triggerbot held: false")
        end
    end
end))

--[ ESP Drawing Creation & Removal ]--
local CornerNames = { "CornerTL1", "CornerTL2", "CornerTR1", "CornerTR2", "CornerBL1", "CornerBL2", "CornerBR1", "CornerBR2" }
local Box3DNames = {}
for i = 1, 12 do
    table.insert(Box3DNames, "Box3DLine" .. i)
end
local SkelNames = {
    "SkelSpine",
    "SkelShoulders",
    "SkelLArm1",
    "SkelLArm2",
    "SkelLArm3",
    "SkelRArm1",
    "SkelRArm2",
    "SkelRArm3",
    "SkelLLeg1",
    "SkelLLeg2",
    "SkelLLeg3",
    "SkelRLeg1",
    "SkelRLeg2",
    "SkelRLeg3",
}

local function CreateESP(player)
    if ESPObjects[player] then
        return
    end

    local esp = {}

    -- Box
    esp.Box = Utils.CreateDrawing("Square", { Thickness = C.ESP.Boxes.Thickness, Filled = false, ZIndex = 2, Visible = false })
    esp.BoxOutline = Utils.CreateDrawing("Square", { Thickness = C.ESP.Boxes.Thickness + 2, Filled = false, ZIndex = 1, Visible = false })
    esp.BoxFill = Utils.CreateDrawing("Square", { Thickness = 1, Filled = true, ZIndex = 0, Visible = false })

    -- Corner Lines
    for _, name in ipairs(CornerNames) do
        esp[name] = Utils.CreateDrawing("Line", { Thickness = C.ESP.Boxes.Thickness, ZIndex = 2, Visible = false })
    end

    -- 3D Box Lines
    for _, name in ipairs(Box3DNames) do
        esp[name] = Utils.CreateDrawing("Line", { Thickness = C.ESP.Boxes.Thickness, ZIndex = 2, Visible = false })
    end

    -- Skeleton Lines
    for _, name in ipairs(SkelNames) do
        esp[name] = Utils.CreateDrawing("Line", { Thickness = C.ESP.Skeleton.Thickness, ZIndex = 2, Visible = false })
    end

    esp.HeadDot = Utils.CreateDrawing("Circle", { Filled = C.ESP.HeadDot.Filled, ZIndex = 3, Visible = false })
    esp.Name = Utils.CreateDrawing("Text", { Center = true, Outline = true, ZIndex = 3, Visible = false, Size = C.ESP.Names.Size })
    esp.Distance = Utils.CreateDrawing("Text", { Center = true, Outline = true, ZIndex = 3, Visible = false, Size = C.ESP.Distance.Size })
    esp.Weapon = Utils.CreateDrawing("Text", { Center = true, Outline = true, ZIndex = 3, Visible = false, Size = C.ESP.Weapon.Size })
    esp.Flags = Utils.CreateDrawing("Text", { Center = false, Outline = true, ZIndex = 3, Visible = false, Size = C.ESP.Flags.Size })
    esp.HealthBarBg = Utils.CreateDrawing("Square", { Thickness = 1, Filled = true, ZIndex = 1, Visible = false, Color = C.ESP.Health.BackgroundColor })
    esp.HealthBar = Utils.CreateDrawing("Square", { Thickness = 1, Filled = true, ZIndex = 2, Visible = false })
    esp.ShieldBar = Utils.CreateDrawing("Square", { Thickness = 1, Filled = true, ZIndex = 2, Visible = false })
    esp.Tracer = Utils.CreateDrawing("Line", { Thickness = C.ESP.Tracers.Thickness, ZIndex = 1, Visible = false })
    esp.Arrow = Utils.CreateDrawing("Triangle", { Filled = C.ESP.Arrows.Filled, Thickness = 1, ZIndex = 4, Visible = false })

    -- Chams
    esp.Highlight = Instance.new("Highlight")
    esp.Highlight.Enabled = false
    esp.Highlight.Parent = ChamsFolder

    -- Radar
    esp.RadarDot = Utils.CreateDrawing("Circle", { Filled = true, ZIndex = 1, Radius = C.ESP.Radar.DotSize, Visible = false, Color = C.ESP.Radar.DotColor })

    ESPObjects[player] = esp
end

local function HideAllESP(esp)
    for k, obj in pairs(esp) do
        if k == "Highlight" then
            obj.Enabled = false
        else
            obj.Visible = false
        end
    end
end

local function HideOnscreenESP(esp)
    -- Hide all except Arrow, Highlight, RadarDot
    for k, obj in pairs(esp) do
        if k ~= "Arrow" and k ~= "Highlight" and k ~= "RadarDot" then
            obj.Visible = false
        end
    end
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for k, obj in pairs(ESPObjects[player]) do
            if k == "Highlight" then
                pcall(function()
                    obj:Destroy()
                end)
            else
                pcall(function()
                    obj:Remove()
                end)
            end
        end
        ESPObjects[player] = nil
    end
    CharacterCache[player] = nil
end

--[ Item ESP Functions ]--
local function GetItemPos(item)
    if item:IsA("Model") and item.PrimaryPart then
        return item.PrimaryPart.Position
    elseif item:IsA("Model") and item:FindFirstChildWhichIsA("BasePart") then
        return item:FindFirstChildWhichIsA("BasePart").Position
    elseif item:IsA("BasePart") then
        return item.Position
    elseif item:IsA("Tool") and item:FindFirstChild("Handle") then
        return item.Handle.Position
    end
    return nil
end

local function CreateItemESP(item)
    if ItemESPObjects[item] then
        return
    end
    ItemESPObjects[item] = {
        Text = Utils.CreateItemDrawing("Text", {
            Center = true,
            Outline = true,
            ZIndex = 3,
            Color = C.ESP.Items.Color,
            Size = 14,
            Visible = false,
        }),
    }
end

local function RemoveItemESP(item)
    if ItemESPObjects[item] then
        for _, obj in pairs(ItemESPObjects[item]) do
            pcall(function()
                obj:Remove()
            end)
        end
        ItemESPObjects[item] = nil
    end
end

local function ScanForItems()
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item:IsA("Tool") and not item.Parent:FindFirstChildOfClass("Humanoid") then
            CreateItemESP(item)
        end
    end
end

task.spawn(function()
    while task.wait(5) do
        if C.ESP.Items.Enabled then
            ScanForItems()
        end
    end
end)

table.insert(getgenv().UniversalAimbotESPConnections, Workspace.DescendantAdded:Connect(function(item)
    if C.ESP.Items.Enabled and item:IsA("Tool") and not item.Parent:FindFirstChildOfClass("Humanoid") then
        CreateItemESP(item)
    end
end))

table.insert(getgenv().UniversalAimbotESPConnections, Workspace.DescendantRemoving:Connect(function(item)
    RemoveItemESP(item)
end))

--[ Sound ESP Functions ]--
local function CreateSoundIndicator(pos)
    local indicator = Utils.CreateItemDrawing("Circle", {
        Radius = 5,
        Filled = true,
        Color = C.ESP.Sounds.Color,
        Transparency = 1,
        Visible = false,
        ZIndex = 5,
    })
    table.insert(SoundESPIndicators, indicator)

    task.spawn(function()
        local startTime = tick()
        while tick() - startTime < C.ESP.Sounds.Duration do
            local elapsed = tick() - startTime
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if onScreen then
                indicator.Position = Vector2.new(screenPos.X, screenPos.Y)
                indicator.Transparency = 1 - (elapsed / C.ESP.Sounds.Duration)
                indicator.Radius = 5 + (elapsed * 10)
                indicator.Visible = true
            else
                indicator.Visible = false
            end
            task.wait()
        end
        for i, v in ipairs(SoundESPIndicators) do
            if v == indicator then
                table.remove(SoundESPIndicators, i)
                break
            end
        end
        pcall(function()
            indicator:Remove()
        end)
    end)
end

local function HookSounds(root)
    root.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") and C.ESP.Sounds.Enabled then
            desc.Played:Connect(function()
                if not C.ESP.Sounds.Enabled then
                    return
                end
                local parent = desc.Parent
                if parent and parent:IsA("BasePart") then
                    local dist = (Camera.CFrame.Position - parent.Position).Magnitude
                    if dist <= C.ESP.Sounds.MaxDistance then
                        CreateSoundIndicator(parent.Position)
                    end
                end
            end)
        end
    end)
end

local function SetupPlayer(player)
    player.CharacterAdded:Connect(function(char)
        CharacterCache[player] = nil
        HookSounds(char)
    end)
    if player.Character then
        HookSounds(player.Character)
    end
end

-- Initialization
for _, player in ipairs(Players:GetPlayers()) do
    SetupPlayer(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

table.insert(getgenv().UniversalAimbotESPConnections, Players.PlayerAdded:Connect(function(player)
    SetupPlayer(player)
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end))

table.insert(getgenv().UniversalAimbotESPConnections, Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end))

--[ Main Render Loop ]--
table.insert(getgenv().UniversalAimbotESPConnections, RunService.RenderStepped:Connect(function()
    local now = tick()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local aimOrigin = (C.Aimbot.Method == "Mouse" and UserInputService:GetMouseLocation()) or screenCenter
    local currentFovRadius = Utils.GetDynamicFOV()

    CurrentTarget = nil
    local bestScore = math.huge

    -- FOV Circle
    if C.Aimbot.FOV.Enabled and C.Aimbot.Enabled then
        FOVCircle.Position = aimOrigin
        FOVCircle.Radius = currentFovRadius
        FOVCircle.Color = C.Aimbot.FOV.Color
        FOVCircle.Thickness = C.Aimbot.FOV.Thickness
        FOVCircle.Transparency = C.Aimbot.FOV.Transparency
        FOVCircle.NumSides = C.Aimbot.FOV.Sides
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    -- Radar Background
    if C.ESP.Radar.Enabled and C.ESP.Enabled then
        RadarBg.Position = C.ESP.Radar.Position
        RadarBg.Size = Vector2.new(C.ESP.Radar.Size, C.ESP.Radar.Size)
        RadarBg.Color = C.ESP.Radar.BgColor
        RadarBg.Transparency = C.ESP.Radar.BgTransparency
        RadarBg.Visible = true
    else
        RadarBg.Visible = false
    end

    -- Global Toggle Check
    if not C.ESP.Enabled and not C.Aimbot.Enabled then
        for _, esp in pairs(ESPObjects) do
            HideAllESP(esp)
        end
        for _, objs in pairs(ItemESPObjects) do
            for _, obj in pairs(objs) do
                obj.Visible = false
            end
        end
        PredictDot.Visible = false
        return
    end

    -- Main Player Loop
    for player, esp in pairs(ESPObjects) do
        local char, hum, root = Utils.GetCharacterInfo(player)
        local isActuallyVisible = false
        local distance = 0

        if char and root and hum then
            distance = (Camera.CFrame.Position - root.Position).Magnitude

            -- Alive Check
            if C.ESP.AliveCheck and hum.Health <= 0 then
                HideAllESP(esp)
                continue
            end

            -- Dormant Check
            if C.ESP.DormantCheck and distance > 500 and hum.MoveDirection.Magnitude == 0 then
                HideAllESP(esp)
                continue
            end

            -- ==================
            -- ESP RENDERING
            -- ==================
            if C.ESP.Enabled and distance <= C.ESP.MaxDistance and (not C.ESP.TeamCheck or not Utils.IsTeammate(player)) then
                local rootScreenPos, onScreen = Camera:WorldToViewportPoint(root.Position)

                if C.ESP.WallCheck then
                    isActuallyVisible = Utils.WallCheck(Camera.CFrame.Position, root.Position, { LocalPlayer.Character, char })
                else
                    isActuallyVisible = true
                end

                local color = Utils.GetColor(player, isActuallyVisible)

                if onScreen then
                    -- Hide arrow when on screen
                    esp.Arrow.Visible = false

                    -- Calculate bounding box
                    local head = char:FindFirstChild("Head")
                    local topPos = Camera:WorldToViewportPoint((head and head.Position or root.Position) + Vector3.new(0, 1.5, 0))
                    local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local boxHeight = math.abs(topPos.Y - bottomPos.Y)
                    local boxWidth = boxHeight * 0.6
                    local bPos = Vector2.new(topPos.X - boxWidth / 2, topPos.Y)
                    local bSize = Vector2.new(boxWidth, boxHeight)

                    -- ======== BOXES ========
                    if C.ESP.Boxes.Enabled then
                        if C.ESP.Boxes.Style == "2D" then
                            -- Show 2D box
                            esp.Box.Size = bSize
                            esp.Box.Position = bPos
                            esp.Box.Color = color
                            esp.Box.Thickness = C.ESP.Boxes.Thickness
                            esp.Box.Visible = true

                            if C.ESP.Boxes.Outline then
                                esp.BoxOutline.Size = bSize
                                esp.BoxOutline.Position = bPos
                                esp.BoxOutline.Color = C.ESP.Boxes.OutlineColor
                                esp.BoxOutline.Thickness = C.ESP.Boxes.Thickness + 2
                                esp.BoxOutline.Visible = true
                            else
                                esp.BoxOutline.Visible = false
                            end

                            if C.ESP.Boxes.Filled then
                                esp.BoxFill.Size = bSize
                                esp.BoxFill.Position = bPos
                                esp.BoxFill.Color = color
                                esp.BoxFill.Transparency = C.ESP.Boxes.FillTransparency
                                esp.BoxFill.Visible = true
                            else
                                esp.BoxFill.Visible = false
                            end

                            -- Hide corner & 3D
                            for _, name in ipairs(CornerNames) do
                                esp[name].Visible = false
                            end
                            for _, name in ipairs(Box3DNames) do
                                esp[name].Visible = false
                            end

                        elseif C.ESP.Boxes.Style == "Corner" then
                            -- Hide 2D & 3D
                            esp.Box.Visible = false
                            esp.BoxOutline.Visible = false
                            esp.BoxFill.Visible = false
                            for _, name in ipairs(Box3DNames) do
                                esp[name].Visible = false
                            end

                            local lineW = boxWidth / 4
                            local lineH = boxHeight / 4

                            -- Top-Left
                            esp.CornerTL1.From = bPos
                            esp.CornerTL1.To = bPos + Vector2.new(lineW, 0)
                            esp.CornerTL2.From = bPos
                            esp.CornerTL2.To = bPos + Vector2.new(0, lineH)

                            -- Top-Right
                            local tr = bPos + Vector2.new(boxWidth, 0)
                            esp.CornerTR1.From = tr
                            esp.CornerTR1.To = tr + Vector2.new(-lineW, 0)
                            esp.CornerTR2.From = tr
                            esp.CornerTR2.To = tr + Vector2.new(0, lineH)

                            -- Bottom-Left
                            local bl = bPos + Vector2.new(0, boxHeight)
                            esp.CornerBL1.From = bl
                            esp.CornerBL1.To = bl + Vector2.new(lineW, 0)
                            esp.CornerBL2.From = bl
                            esp.CornerBL2.To = bl + Vector2.new(0, -lineH)

                            -- Bottom-Right
                            local br = bPos + bSize
                            esp.CornerBR1.From = br
                            esp.CornerBR1.To = br + Vector2.new(-lineW, 0)
                            esp.CornerBR2.From = br
                            esp.CornerBR2.To = br + Vector2.new(0, -lineH)

                            for _, name in ipairs(CornerNames) do
                                esp[name].Color = color
                                esp[name].Transparency = C.ESP.Boxes.Transparency
                                esp[name].Thickness = C.ESP.Boxes.Thickness
                                esp[name].Visible = true
                            end

                        elseif C.ESP.Boxes.Style == "3D" then
                            -- Hide 2D & Corner
                            esp.Box.Visible = false
                            esp.BoxOutline.Visible = false
                            esp.BoxFill.Visible = false
                            for _, name in ipairs(CornerNames) do
                                esp[name].Visible = false
                            end

                            local corners = Utils.Get3DBoxCorners(char)
                            if corners then
                                local lineConnections = {
                                    { 1, 2 }, { 2, 4 }, { 4, 3 }, { 3, 1 }, -- Front
                                    { 5, 6 }, { 6, 8 }, { 8, 7 }, { 7, 5 }, -- Back
                                    { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 }, -- Connections
                                }
                                for i, indices in ipairs(lineConnections) do
                                    local line = esp[Box3DNames[i]]
                                    line.From = corners[indices[1]]
                                    line.To = corners[indices[2]]
                                    line.Color = color
                                    line.Thickness = C.ESP.Boxes.Thickness
                                    line.Visible = true
                                end
                            else
                                for _, name in ipairs(Box3DNames) do
                                    esp[name].Visible = false
                                end
                            end
                        end
                    else
                        -- Boxes disabled
                        esp.Box.Visible = false
                        esp.BoxOutline.Visible = false
                        esp.BoxFill.Visible = false
                        for _, name in ipairs(CornerNames) do
                            esp[name].Visible = false
                        end
                        for _, name in ipairs(Box3DNames) do
                            esp[name].Visible = false
                        end
                    end

                    -- ======== SKELETON ========
                    if C.ESP.Skeleton.Enabled then
                        local joints, isR15 = Utils.GetSkeletonJoints(char)
                        local connections = isR15
                                and {
                                    { "Head", "UpperTorso" },
                                    { "UpperTorso", "LowerTorso" },
                                    { "UpperTorso", "LeftUpperArm" },
                                    { "LeftUpperArm", "LeftLowerArm" },
                                    { "LeftLowerArm", "LeftHand" },
                                    { "UpperTorso", "RightUpperArm" },
                                    { "RightUpperArm", "RightLowerArm" },
                                    { "RightLowerArm", "RightHand" },
                                    { "LowerTorso", "LeftUpperLeg" },
                                    { "LeftUpperLeg", "LeftLowerLeg" },
                                    { "LeftLowerLeg", "LeftFoot" },
                                    { "LowerTorso", "RightUpperLeg" },
                                    { "RightUpperLeg", "RightLowerLeg" },
                                    { "RightLowerLeg", "RightFoot" },
                                }
                            or {
                                { "Head", "Torso" },
                                { "Torso", "Left Arm" },
                                { "Torso", "Right Arm" },
                                { "Torso", "Left Leg" },
                                { "Torso", "Right Leg" },
                            }

                        local lineIdx = 1
                        for _, pair in ipairs(connections) do
                            local p1, p2 = joints[pair[1]], joints[pair[2]]
                            if p1 and p2 and SkelNames[lineIdx] then
                                esp[SkelNames[lineIdx]].From = p1
                                esp[SkelNames[lineIdx]].To = p2
                                esp[SkelNames[lineIdx]].Color = C.ESP.Skeleton.Color
                                esp[SkelNames[lineIdx]].Thickness = C.ESP.Skeleton.Thickness
                                esp[SkelNames[lineIdx]].Visible = true
                            elseif SkelNames[lineIdx] then
                                esp[SkelNames[lineIdx]].Visible = false
                            end
                            lineIdx = lineIdx + 1
                        end
                        -- Hide unused skeleton lines
                        for i = lineIdx, #SkelNames do
                            esp[SkelNames[i]].Visible = false
                        end
                    else
                        for _, name in ipairs(SkelNames) do
                            esp[name].Visible = false
                        end
                    end

                    -- ======== HEAD DOT ========
                    if C.ESP.HeadDot.Enabled then
                        local headPart = char:FindFirstChild("Head")
                        if headPart then
                            local p, on = Camera:WorldToViewportPoint(headPart.Position)
                            if on then
                                esp.HeadDot.Position = Vector2.new(p.X, p.Y)
                                esp.HeadDot.Radius = C.ESP.HeadDot.Radius
                                esp.HeadDot.Color = C.ESP.HeadDot.Color
                                esp.HeadDot.Filled = C.ESP.HeadDot.Filled
                                esp.HeadDot.Visible = true
                            else
                                esp.HeadDot.Visible = false
                            end
                        else
                            esp.HeadDot.Visible = false
                        end
                    else
                        esp.HeadDot.Visible = false
                    end

                    -- ======== NAME ========
                    if C.ESP.Names.Enabled then
                        esp.Name.Text = player.Name
                        esp.Name.Position = Vector2.new(topPos.X, topPos.Y - 15)
                        esp.Name.Color = color
                        esp.Name.Size = C.ESP.Names.Size
                        esp.Name.Visible = true
                    else
                        esp.Name.Visible = false
                    end

                    -- ======== DISTANCE ========
                    if C.ESP.Distance.Enabled then
                        esp.Distance.Text = "[" .. math.floor(distance) .. "s]"
                        esp.Distance.Position = Vector2.new(topPos.X, topPos.Y - 30)
                        esp.Distance.Color = C.ESP.Distance.Color
                        esp.Distance.Size = C.ESP.Distance.Size
                        esp.Distance.Visible = true
                    else
                        esp.Distance.Visible = false
                    end

                    -- ======== WEAPON ========
                    if C.ESP.Weapon.Enabled then
                        local weapon = Utils.GetWeapon(char)
                        esp.Weapon.Text = weapon
                        esp.Weapon.Position = Vector2.new(bottomPos.X, bottomPos.Y + 5)
                        esp.Weapon.Color = C.ESP.Weapon.Color
                        esp.Weapon.Size = C.ESP.Weapon.Size
                        esp.Weapon.Visible = true
                    else
                        esp.Weapon.Visible = false
                    end

                    -- ======== FLAGS ========
                    if C.ESP.Flags.Enabled then
                        local flags = {}
                        if Utils.IsTeammate(player) then
                            table.insert(flags, "TEAM")
                        end
                        if Utils.IsFriend(player) then
                            table.insert(flags, "FRIEND")
                        end
                        if hum.MoveDirection.Magnitude > 0 then
                            table.insert(flags, "MOVING")
                        end

                        esp.Flags.Text = table.concat(flags, "\n")
                        esp.Flags.Position = Vector2.new(bPos.X + boxWidth + 5, bPos.Y)
                        esp.Flags.Color = C.ESP.Flags.Color
                        esp.Flags.Size = C.ESP.Flags.Size
                        esp.Flags.Visible = #flags > 0
                    else
                        esp.Flags.Visible = false
                    end

                    -- ======== HEALTH BAR ========
                    if C.ESP.Health.Enabled then
                        local hPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        esp.HealthBarBg.Size = Vector2.new(C.ESP.Health.Thickness, boxHeight)
                        esp.HealthBarBg.Position = Vector2.new(bPos.X - 5, bPos.Y)
                        esp.HealthBarBg.Color = C.ESP.Health.BackgroundColor
                        esp.HealthBarBg.Visible = true

                        esp.HealthBar.Size = Vector2.new(C.ESP.Health.Thickness, boxHeight * hPct)
                        esp.HealthBar.Position = Vector2.new(bPos.X - 5, bPos.Y + (boxHeight - (boxHeight * hPct)))
                        esp.HealthBar.Color = C.ESP.Health.BarColor
                        esp.HealthBar.Visible = true
                    else
                        esp.HealthBarBg.Visible = false
                        esp.HealthBar.Visible = false
                    end

                    -- ======== SHIELD BAR ========
                    if C.ESP.Shield.Enabled then
                        local shield = Utils.GetShield(char)
                        local maxShield = Utils.GetMaxShield(char)
                        local sPct = math.clamp(shield / maxShield, 0, 1)
                        esp.ShieldBar.Size = Vector2.new(C.ESP.Shield.Thickness, boxHeight * sPct)
                        esp.ShieldBar.Position = Vector2.new(bPos.X - 8 - C.ESP.Health.Thickness, bPos.Y + (boxHeight - (boxHeight * sPct)))
                        esp.ShieldBar.Color = C.ESP.Shield.BarColor
                        esp.ShieldBar.Visible = true
                    else
                        esp.ShieldBar.Visible = false
                    end

                    -- ======== TRACERS ========
                    if C.ESP.Tracers.Enabled then
                        local origin
                        if C.ESP.Tracers.Origin == "Bottom" then
                            origin = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                        elseif C.ESP.Tracers.Origin == "Mouse" then
                            origin = UserInputService:GetMouseLocation()
                        else
                            origin = screenCenter
                        end
                        esp.Tracer.From = origin
                        esp.Tracer.To = Vector2.new(rootScreenPos.X, rootScreenPos.Y)
                        esp.Tracer.Color = C.ESP.Tracers.Color
                        esp.Tracer.Thickness = C.ESP.Tracers.Thickness
                        esp.Tracer.Visible = true
                    else
                        esp.Tracer.Visible = false
                    end

                else
                    -- OFF SCREEN
                    if C.ESP.Arrows.Enabled then
                        local rootP = Camera:WorldToViewportPoint(root.Position)
                        local offset = Vector2.new(rootP.X, rootP.Y) - screenCenter
                        local angle = math.atan2(offset.Y, offset.X)
                        local radius = C.ESP.Arrows.Radius
                        local pX = screenCenter.X + math.cos(angle) * radius
                        local pY = screenCenter.Y + math.sin(angle) * radius
                        local arrowSize = C.ESP.Arrows.Size

                        esp.Arrow.PointA = Vector2.new(pX, pY)
                        esp.Arrow.PointB = screenCenter + Vector2.new(math.cos(angle - 0.2) * (radius - arrowSize), math.sin(angle - 0.2) * (radius - arrowSize))
                        esp.Arrow.PointC = screenCenter + Vector2.new(math.cos(angle + 0.2) * (radius - arrowSize), math.sin(angle + 0.2) * (radius - arrowSize))
                        esp.Arrow.Color = color
                        esp.Arrow.Filled = C.ESP.Arrows.Filled
                        esp.Arrow.Visible = true
                    else
                        esp.Arrow.Visible = false
                    end

                    -- Hide all on-screen drawings
                    HideOnscreenESP(esp)
                end
            else
                -- ESP disabled or out of distance or teammate
                -- Still hide visuals but allow aimbot pass
                esp.Arrow.Visible = false
                HideOnscreenESP(esp)
            end

            -- ======== CHAMS ========
            if C.ESP.Enabled and C.ESP.Chams.Enabled and (not C.ESP.Chams.VisibleOnly or isActuallyVisible) and distance <= C.ESP.MaxDistance then
                esp.Highlight.Adornee = char
                esp.Highlight.FillColor = C.ESP.Chams.FillColor
                esp.Highlight.FillTransparency = C.ESP.Chams.FillTransparency
                esp.Highlight.OutlineColor = C.ESP.Chams.OutlineColor
                esp.Highlight.OutlineTransparency = C.ESP.Chams.OutlineTransparency
                esp.Highlight.Enabled = true
            else
                esp.Highlight.Enabled = false
            end

            -- ======== RADAR ========
            if C.ESP.Enabled and C.ESP.Radar.Enabled and distance <= C.ESP.Radar.Range then
                local relPos = root.Position - Camera.CFrame.Position
                local look = Camera.CFrame.LookVector
                local angle = math.atan2(relPos.Z, relPos.X) - math.atan2(look.Z, look.X)
                local distScaled = (distance / C.ESP.Radar.Range) * (C.ESP.Radar.Size / 2)
                local radarCenter = C.ESP.Radar.Position + Vector2.new(C.ESP.Radar.Size / 2, C.ESP.Radar.Size / 2)
                esp.RadarDot.Position = radarCenter + Vector2.new(math.cos(angle) * distScaled, math.sin(angle) * distScaled)
                esp.RadarDot.Color = C.ESP.Radar.DotColor
                esp.RadarDot.Radius = C.ESP.Radar.DotSize
                esp.RadarDot.Visible = true
            else
                esp.RadarDot.Visible = false
            end

            -- ==================
            -- AIMBOT TARGET SELECTION
            -- ==================
            if C.Aimbot.Enabled and Aiming then
                if not C.Aimbot.TeamCheck or not Utils.IsTeammate(player) then
                    if not C.Aimbot.AliveCheck or Utils.IsAlive(char) then
                        local targetPart = Utils.GetTargetPart(char, C.Aimbot.TargetPart) or root
                        if targetPart then
                        local predictedPos = Utils.PredictPosition(targetPart, targetPart.AssemblyLinearVelocity, distance)
                        local sPos, onS = Camera:WorldToViewportPoint(predictedPos)
                        local distToMouse = (Vector2.new(sPos.X, sPos.Y) - aimOrigin).Magnitude

                        if onS and (C.Aimbot.RageMode or distToMouse < currentFovRadius) then
                            local vis = true
                            if C.Aimbot.WallCheck and not C.Aimbot.RageMode then
                                vis = Utils.WallCheck(Camera.CFrame.Position, targetPart.Position, { LocalPlayer.Character, char })
                            end

                            if vis then
                                if C.Aimbot.Hitchance >= 100 or math.random(1, 100) <= C.Aimbot.Hitchance then
                                    local score = distToMouse
                                    if C.Aimbot.Priority == "Distance" then
                                        score = distance
                                    elseif C.Aimbot.Priority == "Lowest HP" then
                                        score = hum.Health
                                    elseif C.Aimbot.Priority == "Visible" then
                                        score = distance
                                    end

                                    if score < bestScore then
                                        bestScore = score
                                        CurrentTarget = targetPart
                                    end
                                end
                            end
                        end
                    end
                    end
                end
            end
        else
            -- Character invalid / dead
            HideAllESP(esp)
        end
    end

    -- ==================
    -- AIM EXECUTION
    -- ==================
    if CurrentTarget and CurrentTarget.Parent then
        local distance = (Camera.CFrame.Position - CurrentTarget.Position).Magnitude
        local targetPos = Utils.PredictPosition(CurrentTarget, CurrentTarget.AssemblyLinearVelocity, distance)

        -- Predict Dot
        if C.Aimbot.Prediction.ShowDot then
            local sP, onS = Camera:WorldToViewportPoint(targetPos)
            if onS then
                PredictDot.Position = Vector2.new(sP.X, sP.Y)
                PredictDot.Visible = true
            else
                PredictDot.Visible = false
            end
        else
            PredictDot.Visible = false
        end

        -- Aim
        if C.Aimbot.Method == "Camera" then
            local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            if C.Aimbot.RCS.Enabled then
                targetCFrame = targetCFrame * CFrame.Angles(
                    math.rad((math.random() * C.Aimbot.RCS.Vertical) / 10),
                    math.rad((math.random(-100, 100) / 100 * C.Aimbot.RCS.Horizontal) / 10),
                    0
                )
            end
            local smooth = 1
            if C.Aimbot.Smoothness.Enabled then
                smooth = C.Aimbot.Smoothness.Value
                if C.Aimbot.Smoothness.Humanize then
                    smooth = smooth * (math.random(80, 120) / 100)
                end
            end
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smooth)
        elseif C.Aimbot.Method == "Mouse" then
            local sP, onS = Camera:WorldToViewportPoint(targetPos)
            if onS then
                local delta = Vector2.new(sP.X, sP.Y) - UserInputService:GetMouseLocation()
                local smooth = 1
                if C.Aimbot.Smoothness.Enabled then
                    smooth = C.Aimbot.Smoothness.Value
                    if C.Aimbot.Smoothness.Humanize then
                        smooth = smooth * (math.random(80, 120) / 100)
                    end
                end
                if mousemoverel then
                    mousemoverel(delta.X * smooth, delta.Y * smooth)
                end
            end
        end
    else
        PredictDot.Visible = false
    end

    -- ==================
    -- TRIGGERBOT
    -- ==================
    if C.Aimbot.Triggerbot.Enabled then
        local shouldTrigger = false
        
        if C.Aimbot.Triggerbot.RequireKeybind then
            if C.Aimbot.Triggerbot.KeybindMode == "Toggle" then
                shouldTrigger = TriggerbotToggled
            else
                shouldTrigger = TriggerbotHeld
            end
        else
            shouldTrigger = true
        end
        
        if shouldTrigger then
            if not getgenv().LastTriggerTime or now - getgenv().LastTriggerTime >= C.Aimbot.Triggerbot.Delay then
                local mouseLoc = UserInputService:GetMouseLocation()
                local enemyPos = nil
                
                local targetCharacters = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        if not C.Aimbot.Triggerbot.TeamCheck or not Utils.IsTeammate(p) then
                            local hum = p.Character:FindFirstChildOfClass("Humanoid")
                            if not C.Aimbot.AliveCheck or (hum and hum.Health > 0) then
                                table.insert(targetCharacters, p.Character)
                            end
                        end
                    end
                end

                local function CheckHit(mouseX, mouseY)
                    if #targetCharacters == 0 then return nil end
                    local ray = Camera:ViewportPointToRay(mouseX, mouseY)

                    -- Step 1: Cari apakah ada pemain di arah kursor (Whitelist)
                    -- Ini akan "menembus" pagar/jendela/pintu untuk mendeteksi musuh
                    local includeParams = RaycastParams.new()
                    includeParams.FilterType = Enum.RaycastFilterType.Include
                    includeParams.FilterDescendantsInstances = targetCharacters
                    local playerHit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, includeParams)

                    if playerHit and playerHit.Instance then
                        -- Jika IgnoreWall aktif, langsung tembak (Rage Mode)
                        if C.Aimbot.Triggerbot.IgnoreWall then
                            return playerHit.Position
                        end

                        -- Step 2: Cek apakah ada tembok padat di depannya (Legit Check)
                        local excludeParams = RaycastParams.new()
                        excludeParams.FilterType = Enum.RaycastFilterType.Exclude
                        excludeParams.FilterDescendantsInstances = { LocalPlayer.Character }
                        local wallHit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, excludeParams)

                        if wallHit and wallHit.Instance then
                            local hitModel = wallHit.Instance:FindFirstAncestorOfClass("Model")
                            local hitPlayer = hitModel and Players:GetPlayerFromCharacter(hitModel)

                            -- Jika yang kena Raycast normal adalah pemain, berarti tidak ada tembok penghalang
                            -- Ini akan bekerja pada celah pagar karena Raycast normal akan mengenai pemain lewat lubang tersebut
                            if hitPlayer and (not C.Aimbot.Triggerbot.TeamCheck or not Utils.IsTeammate(hitPlayer)) then
                                return wallHit.Position
                            end
                        end
                    end
                    return nil
                end
                
                if C.Aimbot.Triggerbot.MultiRay then
                    local spread = C.Aimbot.Triggerbot.RaySpread or 3
                    local offsets = {
                        Vector2.new(0, 0),
                        Vector2.new(-spread, 0),
                        Vector2.new(spread, 0),
                        Vector2.new(0, -spread),
                        Vector2.new(0, spread),
                        Vector2.new(-spread, -spread),
                        Vector2.new(spread, -spread),
                        Vector2.new(-spread, spread),
                        Vector2.new(spread, spread),
                    }
                    
                    for _, offset in ipairs(offsets) do
                        local testPos = mouseLoc + offset
                        local result = CheckHit(testPos.X, testPos.Y)
                        if result then
                            enemyPos = result
                            mouseLoc = testPos
                            break
                        end
                    end
                else
                    enemyPos = CheckHit(mouseLoc.X, mouseLoc.Y)
                end
                
                if enemyPos then
                    getgenv().LastTriggerTime = now
                    task.spawn(function()
                        local method = C.Aimbot.Triggerbot.SpoofMethod
                        
                        if method == "firesignal" then
                            local InputObject = Instance.new("InputObject")
                            InputObject.KeyCode = Enum.KeyCode.Unknown
                            InputObject.UserInputType = Enum.UserInputType.MouseButton1
                            InputObject.UserInputState = Enum.UserInputState.Begin
                            InputObject.Position = Vector3.new(mouseLoc.X, mouseLoc.Y, 0)
                            firesignal(UserInputService.InputBegan, InputObject, false)
                            task.wait(0.08)
                            InputObject.UserInputState = Enum.UserInputState.End
                            firesignal(UserInputService.InputEnded, InputObject, false)
                            
                        elseif method == "VirtualInputManager" then
                            VirtualInputManager:SendMouseButtonEvent(mouseLoc.X, mouseLoc.Y, 0, true, nil, 1)
                            task.wait(0.08)
                            VirtualInputManager:SendMouseButtonEvent(mouseLoc.X, mouseLoc.Y, 0, false, nil, 1)
                            
                        elseif method == "mouse1click" and mouse1click then
                            mouse1click()
                            
                        else
                            if mouse1click then
                                mouse1click()
                            else
                                VirtualInputManager:SendMouseButtonEvent(mouseLoc.X, mouseLoc.Y, 0, true, game, 0)
                                task.wait(0.05)
                                VirtualInputManager:SendMouseButtonEvent(mouseLoc.X, mouseLoc.Y, 0, false, game, 0)
                            end
                        end
                    end)
                end
            end
        end
    end

    -- ==================
    -- ITEM ESP
    -- ==================
    if C.ESP.Enabled and C.ESP.Items.Enabled then
        for item, objs in pairs(ItemESPObjects) do
            local pos = GetItemPos(item)
            if pos then
                local dist = (Camera.CFrame.Position - pos).Magnitude
                if dist <= C.ESP.Items.MaxDistance then
                    local sP, onS = Camera:WorldToViewportPoint(pos)
                    if onS then
                        local label = item.Name
                        if C.ESP.Items.ShowDistance then
                            label = label .. " [" .. math.floor(dist) .. "s]"
                        end
                        objs.Text.Text = label
                        objs.Text.Position = Vector2.new(sP.X, sP.Y)
                        objs.Text.Color = C.ESP.Items.Color
                        objs.Text.Visible = true
                    else
                        objs.Text.Visible = false
                    end
                else
                    objs.Text.Visible = false
                end
            else
                RemoveItemESP(item)
            end
        end
    else
        for _, objs in pairs(ItemESPObjects) do
            for _, obj in pairs(objs) do
                obj.Visible = false
            end
        end
    end
end))

--[ Generic Silent Aim Hook ]--
local OldNamecall
if hookmetamethod then
    OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = { ... }

        if C.Aimbot.SilentAim.Enabled and C.Aimbot.Enabled and CurrentTarget and CurrentTarget.Parent then
            local targetPos = Utils.PredictPosition(CurrentTarget, CurrentTarget.AssemblyLinearVelocity, (Camera.CFrame.Position - CurrentTarget.Position).Magnitude)

            if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                local origin = args[1].Origin
                args[1] = Ray.new(origin, (targetPos - origin).Unit * 1000)
                return OldNamecall(self, unpack(args))
            elseif method == "Raycast" then
                if typeof(args[1]) == "Vector3" then
                    local origin = args[1]
                    args[2] = (targetPos - origin).Unit * 1000
                    return OldNamecall(self, unpack(args))
                end
            elseif method == "FireServer" then
                for i, v in pairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = targetPos
                    end
                end
                return OldNamecall(self, unpack(args))
            end
        end

        if C.Aimbot.NoSpread.Enabled and method == "FireServer" then
            for i, v in pairs(args) do
                if typeof(v) == "Vector3" then
                    if v.Magnitude > 0.99 and v.Magnitude < 1.01 then
                        args[i] = Camera.CFrame.LookVector
                    end
                end
            end
            return OldNamecall(self, unpack(args))
        end

        return OldNamecall(self, ...)
    end)
end

print("Universal Aimbot & ESP initialized successfully!")

-- Load config on startup
task.spawn(LoadConfig)
