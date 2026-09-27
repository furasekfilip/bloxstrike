-- DeepHat: BloxStrike all-in-one with Linoria UI.
-- [INSERT] toggles menu. [END] unloads everything.

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local Lighting          = game:GetService("Lighting")
local SoundService      = game:GetService("SoundService")
local HttpService       = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- ══════════════════════════════════════════════════════════════════════════
-- LINORIA UI (minimal inline)
-- ══════════════════════════════════════════════════════════════════════════

local LinoriaLib = {}
do
    local Library = {Theme = {}}
    LinoriaLib.Library = Library

    Library.Theme.Accent = Color3.fromRGB(180, 130, 255)
    Library.Theme.Background = Color3.fromRGB(25, 25, 30)
    Library.Theme.Outline = Color3.fromRGB(50, 50, 60)
    Library.Theme.Text = Color3.fromRGB(240, 240, 245)
    Library.Theme.TextDim = Color3.fromRGB(160, 160, 170)
    Library.Theme.Font = Enum.Font.Gotham

    local UI = Instance.new("ScreenGui")
    UI.Name = "DeepHatLinoria"
    UI.ResetOnSpawn = false
    UI.IgnoreGuiInset = true
    UI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() UI.Parent = gethui and gethui() or game:GetService("CoreGui") end)

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 560, 0, 460)
    Main.Position = UDim2.new(0.5, -280, 0.5, -230)
    Main.BackgroundColor3 = Library.Theme.Background
    Main.BorderSizePixel = 0
    Main.Visible = false
    Main.Parent = UI
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Library.Theme.Outline
    MainStroke.Thickness = 1

    do
        local dragging, dragStart, startPos
        Main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        Main.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                          startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 34)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = Main
    Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 6)

    local Title = Instance.new("TextLabel")
    Title.Text = "deephat | bloxstrike"
    Title.Font = Library.Theme.Font
    Title.TextSize = 15
    Title.TextColor3 = Library.Theme.Text
    Title.BackgroundTransparency = 1
    Title.Size = UDim2.new(1, -70, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar

    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(0, 130, 1, -44)
    TabBar.Position = UDim2.new(0, 10, 0, 44)
    TabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
    TabBar.BorderSizePixel = 0
    TabBar.Parent = Main
    Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 4)

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 3)
    TabList.Parent = TabBar
    Instance.new("UIPadding", TabBar).PaddingTop = UDim.new(0, 6)

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -150, 1, -54)
    Content.Position = UDim2.new(0, 148, 0, 44)
    Content.BackgroundTransparency = 1
    Content.Parent = Main

    local Tabs = {}
    local ActiveTab = nil

    function Library:Tab(name)
        local Btn = Instance.new("TextButton")
        Btn.Text = name
        Btn.Font = Library.Theme.Font
        Btn.TextSize = 13
        Btn.TextColor3 = Library.Theme.TextDim
        Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        Btn.BackgroundTransparency = 1
        Btn.BorderSizePixel = 0
        Btn.Size = UDim2.new(1, -12, 0, 28)
        Btn.Position = UDim2.new(0, 6, 0, 0)
        Btn.Parent = TabBar
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

        local Scroll = Instance.new("ScrollingFrame")
        Scroll.Size = UDim2.new(1, 0, 1, 0)
        Scroll.BackgroundTransparency = 1
        Scroll.BorderSizePixel = 0
        Scroll.ScrollBarThickness = 3
        Scroll.ScrollBarImageColor3 = Library.Theme.Accent
        Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
        Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Scroll.Parent = Content
        Scroll.Visible = false

        local Layout = Instance.new("UIListLayout", Scroll)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 6)
        local Pad = Instance.new("UIPadding", Scroll)
        Pad.PaddingTop = UDim.new(0, 4)
        Pad.PaddingBottom = UDim.new(0, 4)
        Pad.PaddingLeft = UDim.new(0, 2)
        Pad.PaddingRight = UDim.new(0, 8)

        local tab = {Button = Btn, Page = Scroll, Name = name}
        Tabs[name] = tab

        Btn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Page.Visible = false
                t.Button.TextColor3 = Library.Theme.TextDim
                t.Button.BackgroundTransparency = 1
            end
            Scroll.Visible = true
            Btn.TextColor3 = Library.Theme.Text
            Btn.BackgroundTransparency = 0
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end)

        if not ActiveTab then
            ActiveTab = name
            Scroll.Visible = true
            Btn.TextColor3 = Library.Theme.Text
            Btn.BackgroundTransparency = 0
            Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        end

        return tab
    end

    function Library:Toggle(parent, text, default, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 26)
        Row.BackgroundTransparency = 1
        Row.Parent = parent.Page

        local Lbl = Instance.new("TextLabel")
        Lbl.Text = text
        Lbl.Font = Library.Theme.Font
        Lbl.TextSize = 13
        Lbl.TextColor3 = Library.Theme.Text
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(1, -50, 1, 0)
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local Box = Instance.new("TextButton")
        Box.Size = UDim2.new(0, 16, 0, 16)
        Box.Position = UDim2.new(1, -20, 0.5, -8)
        Box.BackgroundColor3 = default and Library.Theme.Accent or Color3.fromRGB(40, 40, 48)
        Box.BorderSizePixel = 0
        Box.Text = ""
        Box.Parent = Row
        Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)

        local state = {Value = default}
        Box.MouseButton1Click:Connect(function()
            state.Value = not state.Value
            Box.BackgroundColor3 = state.Value and Library.Theme.Accent or Color3.fromRGB(40, 40, 48)
            if callback then callback(state.Value) end
        end)
        return state
    end

    function Library:Slider(parent, text, min, max, default, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 40)
        Row.BackgroundTransparency = 1
        Row.Parent = parent.Page

        local Lbl = Instance.new("TextLabel")
        Lbl.Text = text .. ": " .. tostring(default)
        Lbl.Font = Library.Theme.Font
        Lbl.TextSize = 13
        Lbl.TextColor3 = Library.Theme.Text
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(1, 0, 0, 16)
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, 0, 0, 6)
        Bar.Position = UDim2.new(0, 0, 0, 24)
        Bar.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        Bar.BorderSizePixel = 0
        Bar.Parent = Row
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 3)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Library.Theme.Accent
        Fill.BorderSizePixel = 0
        Fill.Parent = Bar
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

        local dragging = false
        local function update(input)
            local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            local value = min + pos * (max - min)
            if max >= 10 then value = math.floor(value) else value = math.floor(value * 100) / 100 end
            Fill.Size = UDim2.new(pos, 0, 1, 0)
            Lbl.Text = text .. ": " .. tostring(value)
            if callback then callback(value) end
        end

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                update(input)
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        Row.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then update(input) end
        end)
        return {Value = default}
    end

    function Library:ColorPicker(parent, text, default, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 26)
        Row.BackgroundTransparency = 1
        Row.Parent = parent.Page

        local Lbl = Instance.new("TextLabel")
        Lbl.Text = text
        Lbl.Font = Library.Theme.Font
        Lbl.TextSize = 13
        Lbl.TextColor3 = Library.Theme.Text
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(1, -50, 1, 0)
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local swatch = Instance.new("TextButton")
        swatch.Size = UDim2.new(0, 24, 0, 16)
        swatch.Position = UDim2.new(1, -28, 0.5, -8)
        swatch.BackgroundColor3 = default
        swatch.BorderSizePixel = 0
        swatch.Text = ""
        swatch.Parent = Row
        Instance.new("UICorner", swatch).CornerRadius = UDim.new(0, 3)

        local state = {Value = default}
        local popup = Instance.new("Frame")
        popup.Size = UDim2.new(0, 160, 0, 50)
        popup.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        popup.BorderSizePixel = 0
        popup.Visible = false
        popup.ZIndex = 100
        popup.Parent = Main
        Instance.new("UICorner", popup).CornerRadius = UDim.new(0, 4)

        local hueBar = Instance.new("Frame")
        hueBar.Size = UDim2.new(1, -16, 0, 16)
        hueBar.Position = UDim2.new(0, 8, 0, 20)
        hueBar.Parent = popup
        Instance.new("UIGradient", hueBar).Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
        })

        local hueBtn = Instance.new("TextButton")
        hueBtn.Size = UDim2.new(1, 0, 1, 0)
        hueBtn.BackgroundTransparency = 1
        hueBtn.Text = ""
        hueBtn.Parent = hueBar

        local h, s, v = default:ToHSV()
        s, v = 1, 1

        local function applyHue(px)
            h = math.clamp((px - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
            state.Value = Color3.fromHSV(h, s, v)
            swatch.BackgroundColor3 = state.Value
            if callback then callback(state.Value) end
        end

        hueBtn.MouseButton1Down:Connect(function()
            local mv
            mv = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then applyHue(input.Position.X) end
            end)
            local endConn
            endConn = UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    mv:Disconnect(); endConn:Disconnect()
                end
            end)
        end)

        swatch.MouseButton1Click:Connect(function()
            popup.Visible = not popup.Visible
            if popup.Visible then
                local ap = swatch.AbsolutePosition
                local mp = Main.AbsolutePosition
                popup.Position = UDim2.new(0, ap.X - mp.X - 140, 0, ap.Y - mp.Y + 20)
            end
        end)

        return state
    end

    function Library:Dropdown(parent, text, options, default, callback)
        local Row = Instance.new("Frame")
        Row.Size = UDim2.new(1, 0, 0, 26)
        Row.BackgroundTransparency = 1
        Row.Parent = parent.Page

        local Lbl = Instance.new("TextLabel")
        Lbl.Text = text
        Lbl.Font = Library.Theme.Font
        Lbl.TextSize = 13
        Lbl.TextColor3 = Library.Theme.Text
        Lbl.BackgroundTransparency = 1
        Lbl.Size = UDim2.new(0.5, 0, 1, 0)
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = Row

        local Select = Instance.new("TextButton")
        Select.Size = UDim2.new(0.5, -8, 0, 20)
        Select.Position = UDim2.new(0.5, 4, 0.5, -10)
        Select.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        Select.TextColor3 = Library.Theme.Text
        Select.Font = Library.Theme.Font
        Select.TextSize = 12
        Select.Text = default or options[1]
        Select.BorderSizePixel = 0
        Select.Parent = Row
        Instance.new("UICorner", Select).CornerRadius = UDim.new(0, 3)

        local state = {Value = default or options[1]}
        local idx = 1

        Select.MouseButton1Click:Connect(function()
            for i, opt in ipairs(options) do
                if opt == state.Value then idx = i break end
            end
            idx = idx % #options + 1
            state.Value = options[idx]
            Select.Text = state.Value
            if callback then callback(state.Value) end
        end)

        return state
    end

    function Library:Unload() UI:Destroy() end

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Main.Visible = not Main.Visible
        end
    end)
end

local Library = LinoriaLib.Library

-- ══════════════════════════════════════════════════════════════════════════
-- CONFIG
-- ══════════════════════════════════════════════════════════════════════════

local Config = {
    Enabled     = true,
    MaxDistance = 99999,

    ESP = {
        Enabled = true,
        Boxes = true, Names = true, GradientBoxes = true,
        TeamCheck = true, HealthCheck = true, TeamColorMode = true,
        BoxThickness = 1.5, NameOutline = true, NameSize = 14,
        BoxCornerDots = true, DotSize = 3,
        HealthBar = true, HealthBarWidth = 3, HealthBarOffset = 6,
        Colors = {
            BoxTop = Color3.fromRGB(255, 80, 80),
            BoxBot = Color3.fromRGB(80, 80, 255),
            CornerDot = Color3.fromRGB(255, 255, 255),
            Name = Color3.fromRGB(255, 255, 255),
            HealthLow = Color3.fromRGB(255, 60, 60),
            HealthHigh = Color3.fromRGB(60, 255, 60),
            HealthBack = Color3.fromRGB(30, 30, 30),
            Terrorists = Color3.fromRGB(255, 180, 60),
            CT = Color3.fromRGB(80, 140, 255),
            CounterTerrorists = Color3.fromRGB(80, 140, 255),
        },
    },

    World = { Enabled = true, KillGameEffects = true },

    SkinChanger = {
        Enabled = true,
        KnifeModel = "Karambit",
        KnifeSkin = "Fade",
        BaseKnives = { "CT Knife", "T Knife", "Knife" },
    },

    NoSpread = { Enabled = true, Whitelist = { "AWP" }, ScopedOnly = true },

    SpectatorList = { Enabled = true, Position = UDim2.new(1, -280, 0.35, 0), Width = 260 },

    Hitmarker = {
        Enabled = true, Size = 12, Thickness = 2,
        Color = Color3.fromRGB(255, 255, 255), Duration = 0.15,
        Outline = true, OutlineColor = Color3.fromRGB(0, 0, 0),
        KillColor = Color3.fromRGB(255, 40, 40), KillDuration = 0.4, KillSize = 18,
    },

    Hitsound = {
        Enabled = true, SoundId = "rbxassetid://18537680989",
        Volume = 0.6, PitchMin = 1.0, PitchMax = 1.0,
        KillPitch = 0.85, KillVolume = 0.85, MinInterval = 0.04,
    },

    Movement = {
        Bhop = {
            Enabled = true,
            Key = Enum.KeyCode.Space,
        },
        EdgeBug = {
            Enabled = true,
            Key = Enum.KeyCode.LeftShift,
            HoldFrames = 3,
            MinFallSpeed = 20,
            Cooldown = 0.15,
        },
    },
}

-- ══════════════════════════════════════════════════════════════════════════
-- STATE
-- ══════════════════════════════════════════════════════════════════════════

local ESP_Data         = {}
local Connections      = {}
local Drawing_Registry = {}

local WorldVisuals     = {}
local StolenEffects    = {}
local OriginalLighting = {}
local WorldInitialized = false
local CachedSky, CachedAtmos, CachedCC, CachedBloom = nil, nil, nil, nil
local Applied = {}
local CachedMyTeam = nil

local Hooks = {SkinsModule=nil, ViewmodelModule=nil, originalGetCamera=nil, originalGetChar=nil, originalVmNew=nil, installed=false}
local SpreadHooks = {InventoryController=nil, originalShootWeapon=nil, installed=false, lastShotTime=0, _lastAmmo=nil}
local SpectatorUI = {Root=nil, CountLabel=nil, ListContainer=nil, Rows={}, LastUpdate=0, LastRowKey=""}
local Hitmarker = {Lines={}, OutlineLines={}, ShowUntil=0, IsKill=false, Initialized=false}
local Hitsound = {Instances={}, NextIndex=1, PoolSize=6, LastPlayed=0}

local BhopState = {WasGrounded=true}
local EdgeBugState = {LastTrigger=0, FallFrames=0, WasAir=false}

-- ══════════════════════════════════════════════════════════════════════════
-- BUILD UI
-- ══════════════════════════════════════════════════════════════════════════

local RageTab    = Library:Tab("Rage")
local VisualsTab = Library:Tab("Visuals")
local WorldTab   = Library:Tab("World")
local MovementTab= Library:Tab("Movement")
local SkinTab    = Library:Tab("Skins")
local MiscTab    = Library:Tab("Misc")

Library:Toggle(RageTab, "No-Spread Enabled", Config.NoSpread.Enabled, function(v) Config.NoSpread.Enabled = v end)
Library:Toggle(RageTab, "Scoped Only (AWP)", Config.NoSpread.ScopedOnly, function(v) Config.NoSpread.ScopedOnly = v end)

Library:Toggle(VisualsTab, "ESP Enabled", Config.ESP.Enabled, function(v) Config.ESP.Enabled = v end)
Library:Toggle(VisualsTab, "Team Check", Config.ESP.TeamCheck, function(v) Config.ESP.TeamCheck = v end)
Library:Toggle(VisualsTab, "Health Check", Config.ESP.HealthCheck, function(v) Config.ESP.HealthCheck = v end)
Library:Toggle(VisualsTab, "Team Color Mode", Config.ESP.TeamColorMode, function(v) Config.ESP.TeamColorMode = v end)
Library:Toggle(VisualsTab, "Gradient Boxes", Config.ESP.GradientBoxes, function(v) Config.ESP.GradientBoxes = v end)
Library:Toggle(VisualsTab, "Corner Dots", Config.ESP.BoxCornerDots, function(v) Config.ESP.BoxCornerDots = v end)
Library:Toggle(VisualsTab, "Names", Config.ESP.Names, function(v) Config.ESP.Names = v end)
Library:Toggle(VisualsTab, "Health Bar", Config.ESP.HealthBar, function(v) Config.ESP.HealthBar = v end)
Library:Slider(VisualsTab, "Box Thickness", 0.5, 5, Config.ESP.BoxThickness, function(v) Config.ESP.BoxThickness = v end)
Library:Slider(VisualsTab, "Name Size", 8, 24, Config.ESP.NameSize, function(v) Config.ESP.NameSize = v end)
Library:Slider(VisualsTab, "Max Distance", 100, 5000, 2000, function(v) Config.MaxDistance = v end)
Library:ColorPicker(VisualsTab, "Box Top Color", Config.ESP.Colors.BoxTop, function(c) Config.ESP.Colors.BoxTop = c end)
Library:ColorPicker(VisualsTab, "Box Bottom Color", Config.ESP.Colors.BoxBot, function(c) Config.ESP.Colors.BoxBot = c end)
Library:ColorPicker(VisualsTab, "Corner Dot Color", Config.ESP.Colors.CornerDot, function(c) Config.ESP.Colors.CornerDot = c end)
Library:ColorPicker(VisualsTab, "Name Color", Config.ESP.Colors.Name, function(c) Config.ESP.Colors.Name = c end)
Library:ColorPicker(VisualsTab, "Team Terrorists", Config.ESP.Colors.Terrorists, function(c) Config.ESP.Colors.Terrorists = c end)
Library:ColorPicker(VisualsTab, "Team CT", Config.ESP.Colors.CT, function(c) Config.ESP.Colors.CT = c end)

Library:Toggle(WorldTab, "Custom Lighting", Config.World.Enabled, function(v) Config.World.Enabled = v end)
Library:Toggle(WorldTab, "Steal Game Effects", Config.World.KillGameEffects, function(v) Config.World.KillGameEffects = v end)
Library:Toggle(WorldTab, "Spectator List", Config.SpectatorList.Enabled, function(v) Config.SpectatorList.Enabled = v end)

Library:Toggle(MovementTab, "Bhop", Config.Movement.Bhop.Enabled, function(v) Config.Movement.Bhop.Enabled = v end)
Library:Toggle(MovementTab, "Edge Bug", Config.Movement.EdgeBug.Enabled, function(v) Config.Movement.EdgeBug.Enabled = v end)
Library:Slider(MovementTab, "EB Min Fall Speed", 5, 60, Config.Movement.EdgeBug.MinFallSpeed, function(v) Config.Movement.EdgeBug.MinFallSpeed = v end)
Library:Slider(MovementTab, "EB Cooldown", 0.05, 0.5, Config.Movement.EdgeBug.Cooldown, function(v) Config.Movement.EdgeBug.Cooldown = v end)

Library:Toggle(SkinTab, "Knife Changer", Config.SkinChanger.Enabled, function(v) Config.SkinChanger.Enabled = v end)
Library:Dropdown(SkinTab, "Knife Model",
    { "Karambit", "Butterfly Knife", "Flip Knife", "Gut Knife", "M9 Bayonet", "Skeleton Knife", "Stiletto Knife" },
    Config.SkinChanger.KnifeModel,
    function(v) Config.SkinChanger.KnifeModel = v end)
Library:Dropdown(SkinTab, "Knife Skin",
    { "Fade", "Vanilla", "Safari", "Midnight", "Violet", "Woodland", "Slaughter", "Doppler" },
    Config.SkinChanger.KnifeSkin,
    function(v) Config.SkinChanger.KnifeSkin = v end)

Library:Toggle(MiscTab, "Hitmarker", Config.Hitmarker.Enabled, function(v) Config.Hitmarker.Enabled = v end)
Library:Slider(MiscTab, "Hitmarker Size", 4, 30, Config.Hitmarker.Size, function(v) Config.Hitmarker.Size = v end)
Library:Slider(MiscTab, "Hitmarker Duration", 0.05, 0.5, Config.Hitmarker.Duration, function(v) Config.Hitmarker.Duration = v end)
Library:ColorPicker(MiscTab, "Hitmarker Color", Config.Hitmarker.Color, function(c) Config.Hitmarker.Color = c end)
Library:ColorPicker(MiscTab, "Kill Marker Color", Config.Hitmarker.KillColor, function(c) Config.Hitmarker.KillColor = c end)
Library:Toggle(MiscTab, "Hitsound", Config.Hitsound.Enabled, function(v) Config.Hitsound.Enabled = v end)
Library:Slider(MiscTab, "Hitsound Volume", 0, 1, Config.Hitsound.Volume, function(v) Config.Hitsound.Volume = v end)
Library:Slider(MiscTab, "Hitsound MinInterval", 0, 0.5, Config.Hitsound.MinInterval, function(v) Config.Hitsound.MinInterval = v end)

print("[DeepHat] Linoria UI loaded. Press INSERT to toggle.")

-- ══════════════════════════════════════════════════════════════════════════
-- WORLD VISUALS
-- ══════════════════════════════════════════════════════════════════════════

local GALAXY_SKYBOX = {
    SkyboxBk = "rbxassetid://159454299", SkyboxDn = "rbxassetid://159454296",
    SkyboxFt = "rbxassetid://159454293", SkyboxLf = "rbxassetid://159454293",
    SkyboxRt = "rbxassetid://159454293", SkyboxUp = "rbxassetid://159454299",
}

local function stealGameEffects()
    if not Config.World.KillGameEffects then return end
    for _, child in ipairs(Lighting:GetChildren()) do
        if child:IsA("Sky") or child:IsA("Atmosphere")
           or child:IsA("ColorCorrectionEffect") or child:IsA("BloomEffect")
           or child:IsA("BlurEffect") or child:IsA("SunRaysEffect")
           or child:IsA("DepthOfFieldEffect")
        then
            if not child.Name:match("^DeepHat") then
                local known = false
                for _, entry in ipairs(StolenEffects) do
                    if entry.inst == child then known = true; break end
                end
                if not known then
                    table.insert(StolenEffects, {inst = child, parent = Lighting})
                    child.Parent = nil
                end
            end
        end
    end
end

local function restoreGameEffects()
    for _, entry in ipairs(StolenEffects) do
        pcall(function()
            if entry.inst and entry.inst.Parent == nil then
                entry.inst.Parent = entry.parent
            end
        end)
    end
    table.clear(StolenEffects)
end

local function forceWorldVisuals(force)
    if not CachedSky then return end
    if not CachedSky.Parent then
        WorldInitialized = false
        for _, obj in ipairs(WorldVisuals) do pcall(function() obj:Destroy() end) end
        table.clear(WorldVisuals)
        CachedSky, CachedAtmos, CachedCC, CachedBloom = nil, nil, nil, nil
        table.clear(Applied)
        return
    end
    local function set(target, key, value)
        if force or Applied[key] ~= value then target[key] = value; Applied[key] = value end
    end
    set(CachedSky, "SkyboxBk", GALAXY_SKYBOX.SkyboxBk)
    set(CachedSky, "SkyboxDn", GALAXY_SKYBOX.SkyboxDn)
    set(CachedSky, "SkyboxFt", GALAXY_SKYBOX.SkyboxFt)
    set(CachedSky, "SkyboxLf", GALAXY_SKYBOX.SkyboxLf)
    set(CachedSky, "SkyboxRt", GALAXY_SKYBOX.SkyboxRt)
    set(CachedSky, "SkyboxUp", GALAXY_SKYBOX.SkyboxUp)
    set(CachedSky, "CelestialBodiesShown", false)
    set(CachedAtmos, "Density", 0.05)
    set(CachedAtmos, "Offset", 0.1)
    set(CachedAtmos, "Color", Color3.fromRGB(160, 150, 200))
    set(CachedAtmos, "Decay", Color3.fromRGB(120, 110, 160))
    set(CachedAtmos, "Glare", 0.0)
    set(CachedAtmos, "Haze", 0.3)
    set(Lighting, "Ambient", Color3.fromRGB(140, 130, 180))
    set(Lighting, "OutdoorAmbient", Color3.fromRGB(160, 150, 200))
    set(Lighting, "Brightness", 2.5)
    set(Lighting, "ClockTime", 14)
    set(Lighting, "ExposureCompensation", 0.35)
    set(Lighting, "EnvironmentDiffuseScale", 0.6)
    set(Lighting, "EnvironmentSpecularScale", 0.6)
    set(CachedCC, "Brightness", 0.0)
    set(CachedCC, "Contrast", 0.05)
    set(CachedCC, "Saturation", 0.0)
    set(CachedCC, "TintColor", Color3.fromRGB(240, 235, 255))
    set(CachedBloom, "Intensity", 0.15)
    set(CachedBloom, "Size", 16)
    set(CachedBloom, "Threshold", 1.2)
end

local function initWorldVisuals()
    if WorldInitialized then return end
    OriginalLighting.Ambient = Lighting.Ambient
    OriginalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
    OriginalLighting.Brightness = Lighting.Brightness
    OriginalLighting.ClockTime = Lighting.ClockTime
    OriginalLighting.EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale
    OriginalLighting.EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale
    OriginalLighting.ExposureCompensation = Lighting.ExposureCompensation
    OriginalLighting.Technology = Lighting.Technology
    stealGameEffects()
    CachedSky = Instance.new("Sky"); CachedSky.Name = "DeepHatSky"; CachedSky.Parent = Lighting
    CachedAtmos = Instance.new("Atmosphere"); CachedAtmos.Name = "DeepHatAtmos"; CachedAtmos.Parent = Lighting
    CachedCC = Instance.new("ColorCorrectionEffect"); CachedCC.Name = "DeepHatColorGrade"; CachedCC.Parent = Lighting
    CachedBloom = Instance.new("BloomEffect"); CachedBloom.Name = "DeepHatBloom"; CachedBloom.Parent = Lighting
    table.insert(WorldVisuals, CachedSky)
    table.insert(WorldVisuals, CachedAtmos)
    table.insert(WorldVisuals, CachedCC)
    table.insert(WorldVisuals, CachedBloom)
    forceWorldVisuals(true)
    WorldInitialized = true
end

local function revertWorldVisuals()
    for _, obj in ipairs(WorldVisuals) do pcall(function() obj:Destroy() end) end
    table.clear(WorldVisuals)
    if OriginalLighting.Ambient ~= nil then
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ClockTime = OriginalLighting.ClockTime
        Lighting.EnvironmentDiffuseScale = OriginalLighting.EnvironmentDiffuseScale
        Lighting.EnvironmentSpecularScale = OriginalLighting.EnvironmentSpecularScale
        Lighting.ExposureCompensation = OriginalLighting.ExposureCompensation
        Lighting.Technology = OriginalLighting.Technology
    end
    restoreGameEffects()
    CachedSky, CachedAtmos, CachedCC, CachedBloom = nil, nil, nil, nil
    WorldInitialized = false
    table.clear(Applied)
end

-- ══════════════════════════════════════════════════════════════════════════
-- HELPERS
-- ══════════════════════════════════════════════════════════════════════════

local function makeDrawing(kind, props)
    local d = Drawing.new(kind)
    for k, v in pairs(props) do d[k] = v end
    Drawing_Registry[#Drawing_Registry + 1] = d
    return d
end

local function lerpColor(a, b, t)
    return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function getTeamName(player)
    local t = player.Team
    if type(t) == "string" then return t end
    if type(t) == "table" and t.Name then return t.Name end
    local attr = player:GetAttribute("Team")
    if attr then return attr end
    return nil
end

local function isTeammate(player)
    local myTeam = CachedMyTeam or getTeamName(LocalPlayer)
    if not myTeam then return false end
    local theirTeam = getTeamName(player)
    if not theirTeam then return false end
    return myTeam == theirTeam
end

local function getTeamColor(player)
    local name = getTeamName(player)
    if not name then return nil end
    local colors = Config.ESP.Colors
    if colors[name] then return colors[name] end
    local lower = name:lower()
    if lower:find("terror") or lower == "t" then return colors.Terrorists end
    if lower:find("counter") or lower:find("ct") then return colors.CT end
    return nil
end

local function getHealth(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health, hum.MaxHealth end
    local hp = char:FindFirstChild("Health")
    if hp and hp:IsA("NumberValue") then
        local max = char:FindFirstChild("MaxHealth")
        return hp.Value, (max and max.Value or 100)
    end
    local a = char:GetAttribute("Health")
    local b = char:GetAttribute("MaxHealth")
    if a then return a, (b or 100) end
    return nil, nil
end

local function isAlive(char)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then return hum.Health > 0 end
    local hp = char:FindFirstChild("Health")
    if hp and hp:IsA("NumberValue") then return hp.Value > 0 end
    local attr = char:GetAttribute("Health")
    if attr then return attr > 0 end
    local dead = char:GetAttribute("Dead")
    if dead ~= nil then return not dead end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            for _, tag in ipairs(part:GetTags()) do
                if tag:lower():find("ragdoll") or tag:lower():find("dead") then return false end
            end
        end
    end
    return true
end

-- ══════════════════════════════════════════════════════════════════════════
-- HITMARKER / HITSOUND
-- ══════════════════════════════════════════════════════════════════════════

local function initHitmarker()
    if Hitmarker.Initialized then return end
    Hitmarker.Initialized = true
    for i = 1, 4 do
        Hitmarker.Lines[i] = makeDrawing("Line", {Thickness = Config.Hitmarker.Thickness, Color = Config.Hitmarker.Color, Visible = false})
        if Config.Hitmarker.Outline then
            Hitmarker.OutlineLines[i] = makeDrawing("Line", {Thickness = Config.Hitmarker.Thickness + 2, Color = Config.Hitmarker.OutlineColor, Visible = false})
        end
    end
end

local function triggerHitmarker(isKill)
    if not Config.Hitmarker.Enabled then return end
    initHitmarker()
    local duration = isKill and Config.Hitmarker.KillDuration or Config.Hitmarker.Duration
    Hitmarker.ShowUntil = os.clock() + duration
    Hitmarker.IsKill = isKill and true or false
end

local function updateHitmarker()
    if not Hitmarker.Initialized then return end
    local visible = os.clock() < Hitmarker.ShowUntil
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    local isKill = Hitmarker.IsKill
    local size = isKill and Config.Hitmarker.KillSize or Config.Hitmarker.Size
    local color = isKill and Config.Hitmarker.KillColor or Config.Hitmarker.Color
    local gap = 4
    local corners = {
        {Vector2.new(cx - gap - size, cy - gap - size), Vector2.new(cx - gap, cy - gap)},
        {Vector2.new(cx + gap, cy - gap - size), Vector2.new(cx + gap + size, cy - gap)},
        {Vector2.new(cx - gap - size, cy + gap), Vector2.new(cx - gap, cy + gap + size)},
        {Vector2.new(cx + gap, cy + gap), Vector2.new(cx + gap + size, cy + gap + size)},
    }
    for i = 1, 4 do
        local line = Hitmarker.Lines[i]
        local outline = Hitmarker.OutlineLines[i]
        local c = corners[i]
        if line then
            line.From = c[1]; line.To = c[2]; line.Color = color
            line.Thickness = Config.Hitmarker.Thickness; line.Visible = visible
        end
        if outline then
            outline.From = c[1]; outline.To = c[2]; outline.Color = Config.Hitmarker.OutlineColor
            outline.Thickness = Config.Hitmarker.Thickness + 2
            outline.Visible = visible and Config.Hitmarker.Outline
        end
    end
end

local function initHitsound()
    if #Hitsound.Instances > 0 then return end
    local group = Instance.new("SoundGroup")
    group.Name = "DeepHatHitGroup"
    group.Volume = Config.Hitsound.Volume
    group.Parent = SoundService
    for i = 1, Hitsound.PoolSize do
        local sound = Instance.new("Sound")
        sound.Name = "DeepHatHitSound" .. i
        sound.SoundId = Config.Hitsound.SoundId
        sound.Volume = Config.Hitsound.Volume
        sound.SoundGroup = group
        sound.Parent = SoundService
        Hitsound.Instances[i] = sound
    end
end

local function playHitsound(isKill)
    if not Config.Hitsound.Enabled then return end
    local now = os.clock()
    if now - Hitsound.LastPlayed < Config.Hitsound.MinInterval then return end
    Hitsound.LastPlayed = now
    initHitsound()
    local sound = Hitsound.Instances[Hitsound.NextIndex]
    Hitsound.NextIndex = (Hitsound.NextIndex % #Hitsound.Instances) + 1
    if sound then
        if isKill then
            sound.PlaybackSpeed = Config.Hitsound.KillPitch
            sound.Volume = Config.Hitsound.KillVolume
        else
            sound.PlaybackSpeed = Config.Hitsound.PitchMin + math.random() * (Config.Hitsound.PitchMax - Config.Hitsound.PitchMin)
            sound.Volume = Config.Hitsound.Volume
        end
        pcall(function() sound:Stop() end)
        pcall(function() sound:Play() end)
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- KNIFE CHANGER
-- ══════════════════════════════════════════════════════════════════════════

local function isBaseKnife(w)
    if not w then return false end
    for _, k in ipairs(Config.SkinChanger.BaseKnives) do
        if w == k then return true end
    end
    return false
end

local function resolveModule(path)
    local node = ReplicatedStorage
    for _, name in ipairs(path) do
        node = node:FindFirstChild(name)
        if not node then return nil end
    end
    return node
end

local function installKnifeHooks()
    if Hooks.installed then return true end
    local skinsScript = resolveModule({"Database", "Components", "Libraries", "Skins"})
    local vmScript    = resolveModule({"Classes", "WeaponComponent", "Classes", "Viewmodel"})
    if not skinsScript or not vmScript then
        warn("[DeepHat] knife changer modules missing")
        return false
    end
    local ok1, Sk = pcall(require, skinsScript)
    local ok2, Vm = pcall(require, vmScript)
    if not ok1 or type(Sk) ~= "table" or not ok2 or type(Vm) ~= "table" then
        warn("[DeepHat] knife changer require failed")
        return false
    end
    if type(Sk.GetCameraModel) == "function" then
        Hooks.originalGetCamera = Sk.GetCameraModel
        Sk.GetCameraModel = function(w, sk, ...)
            if Config.SkinChanger.Enabled and isBaseKnife(w) then
                local ok, result = pcall(Hooks.originalGetCamera, Config.SkinChanger.KnifeModel, Config.SkinChanger.KnifeSkin, ...)
                if ok and result then return result end
            end
            local ok, result = pcall(Hooks.originalGetCamera, w, sk, ...)
            if ok then return result end
            return nil
        end
    end
    if type(Sk.GetCharacterModel) == "function" then
        Hooks.originalGetChar = Sk.GetCharacterModel
        Sk.GetCharacterModel = function(w, sk, ...)
            if Config.SkinChanger.Enabled and isBaseKnife(w) then
                local ok, result = pcall(Hooks.originalGetChar, Config.SkinChanger.KnifeModel, Config.SkinChanger.KnifeSkin, ...)
                if ok and result then return result end
            end
            local ok, result = pcall(Hooks.originalGetChar, w, sk, ...)
            if ok then return result end
            return nil
        end
    end
    if type(Vm.new) == "function" then
        Hooks.originalVmNew = Vm.new
        Vm.new = function(vc, w, sk, ...)
            if Config.SkinChanger.Enabled and isBaseKnife(w) then
                local ok, result = pcall(Hooks.originalVmNew, vc, Config.SkinChanger.KnifeModel, Config.SkinChanger.KnifeSkin, ...)
                if ok and result then return result end
            end
            local ok, result = pcall(Hooks.originalVmNew, vc, w, sk, ...)
            if ok then return result end
            return nil
        end
    end
    Hooks.SkinsModule = Sk
    Hooks.ViewmodelModule = Vm
    Hooks.installed = true
    print("[DeepHat] knife changer installed")
    return true
end

local function uninstallKnifeHooks()
    if not Hooks.installed then return end
    pcall(function() if Hooks.SkinsModule and Hooks.originalGetCamera then Hooks.SkinsModule.GetCameraModel = Hooks.originalGetCamera end end)
    pcall(function() if Hooks.SkinsModule and Hooks.originalGetChar then Hooks.SkinsModule.GetCharacterModel = Hooks.originalGetChar end end)
    pcall(function() if Hooks.ViewmodelModule and Hooks.originalVmNew then Hooks.ViewmodelModule.new = Hooks.originalVmNew end end)
    Hooks.installed = false
end

-- ══════════════════════════════════════════════════════════════════════════
-- NO-SPREAD
-- ══════════════════════════════════════════════════════════════════════════

local function getCurrentWeaponName()
    for _, child in ipairs(Camera:GetChildren()) do
        if child:IsA("Model") and child:FindFirstChild("Weapon") then return child.Name end
    end
    return nil
end

local function isScoped()
    local char = LocalPlayer.Character
    if not char then return false end
    local scoped = char:GetAttribute("Scoped")
    if scoped ~= nil then return scoped end
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if pg then
        for _, gui in ipairs(pg:GetChildren()) do
            if gui.Name:lower():find("scope") and gui.Enabled then return true end
        end
    end
    return false
end

local function installSpreadHooks()
    if SpreadHooks.installed then return true end
    if not Config.NoSpread.Enabled then return false end
    local invScript = resolveModule({"Controllers", "InventoryController"})
    if not invScript then return false end
    local ok, IC = pcall(require, invScript)
    if not ok or type(IC) ~= "table" then return false end
    if type(IC.ShootWeapon) ~= "function" then return false end
    SpreadHooks.InventoryController = IC
    SpreadHooks.originalShootWeapon = IC.ShootWeapon
    IC.ShootWeapon = function(Self, Data)
        SpreadHooks.lastShotTime = os.clock()
        if Config.NoSpread.Enabled then
            local weapon = getCurrentWeaponName()
            if weapon then
                local lower = weapon:lower()
                local whitelisted = false
                for _, w in ipairs(Config.NoSpread.Whitelist) do
                    if lower:find(w:lower(), 1, true) then whitelisted = true; break end
                end
                if whitelisted then
                    if not Config.NoSpread.ScopedOnly or isScoped() then
                        if Data and Data.Bullets then
                            local LookVector = workspace.CurrentCamera.CFrame.LookVector
                            for _, Bullet in ipairs(Data.Bullets) do
                                pcall(function() Bullet.Direction = LookVector end)
                            end
                        end
                    end
                end
            end
        end
        return SpreadHooks.originalShootWeapon(Self, Data)
    end
    SpreadHooks.installed = true
    print("[DeepHat] no-spread installed")
    return true
end

local function uninstallSpreadHooks()
    if not SpreadHooks.installed then return end
    pcall(function()
        if SpreadHooks.InventoryController and SpreadHooks.originalShootWeapon then
            SpreadHooks.InventoryController.ShootWeapon = SpreadHooks.originalShootWeapon
        end
    end)
    SpreadHooks.installed = false
end

-- ══════════════════════════════════════════════════════════════════════════
-- HIT DETECTION
-- ══════════════════════════════════════════════════════════════════════════

local function installHitDetection()
    local candidates = {}
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("RemoteEvent") then
            local lower = d.Name:lower()
            if lower:find("damage") or lower:find("hit") or lower:find("dmg")
               or lower:find("kill") or lower:find("hitmark") or lower:find("hitsound")
               or lower:find("hitconfirm") then
                table.insert(candidates, d)
            end
        end
    end
    for _, d in ipairs(ReplicatedStorage:GetDescendants()) do
        if d:IsA("UnreliableRemoteEvent") then
            local lower = d.Name:lower()
            if lower:find("hit") or lower:find("damage") or lower:find("shot") then
                table.insert(candidates, d)
            end
        end
    end

    task.spawn(function()
        while Config.Enabled do
            task.wait(0.03)
            pcall(function()
                local ammo = LocalPlayer:GetAttribute("Ammo")
                if ammo ~= nil then
                    if SpreadHooks._lastAmmo ~= nil and ammo < SpreadHooks._lastAmmo then
                        SpreadHooks.lastShotTime = os.clock()
                    end
                    SpreadHooks._lastAmmo = ammo
                end
            end)
        end
    end)

    local myCharacter = LocalPlayer.Character
    local attached = 0
    for _, remote in ipairs(candidates) do
        pcall(function()
            remote.OnClientEvent:Connect(function(...)
                local args = {...}
                local myPlayer = LocalPlayer
                local isMine = false
                local victimIsDead = false
                for _, arg in ipairs(args) do
                    if arg == myPlayer then
                        isMine = true
                    elseif typeof(arg) == "Instance" then
                        if arg == myPlayer or arg == myCharacter then
                            isMine = true
                        elseif arg:IsA("Player") and arg == myPlayer then
                            isMine = true
                        end
                        local argPlayer = nil
                        if arg:IsA("Player") then argPlayer = arg
                        elseif arg:IsA("Model") then argPlayer = Players:GetPlayerFromCharacter(arg) end
                        if argPlayer and argPlayer ~= myPlayer then
                            local vChar = argPlayer.Character
                            if vChar then
                                local hp = vChar:GetAttribute("Health")
                                if hp == nil then
                                    local hum = vChar:FindFirstChildOfClass("Humanoid")
                                    if hum then hp = hum.Health end
                                end
                                if hp == 0 then victimIsDead = true end
                            end
                        end
                    end
                end
                if not isMine then
                    local now = os.clock()
                    if now - (SpreadHooks.lastShotTime or 0) < 0.12 then
                        isMine = true
                    end
                end
                if isMine then
                    triggerHitmarker(victimIsDead)
                    playHitsound(victimIsDead)
                end
            end)
            attached = attached + 1
        end)
    end
    print(string.format("[DeepHat] hit detection installed on %d remote(s)", attached))
    return attached > 0
end

-- ══════════════════════════════════════════════════════════════════════════
-- BHOP + EDGEBUG
-- ══════════════════════════════════════════════════════════════════════════

local BhopRayParams = RaycastParams.new()
BhopRayParams.FilterType = Enum.RaycastFilterType.Exclude
BhopRayParams.IgnoreWater = true

local function getLocalParts()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return nil end
    return char, hum, hrp
end

local function isNearLedge(hrp, char)
    BhopRayParams.FilterDescendantsInstances = {char, Camera}
    local origin = hrp.Position
    local down = workspace:Raycast(origin, Vector3.new(0, -4, 0), BhopRayParams)
    if not down then return false end
    local offsets = {
        Vector3.new(1.5, 0, 0), Vector3.new(-1.5, 0, 0),
        Vector3.new(0, 0, 1.5), Vector3.new(0, 0, -1.5),
    }
    for _, off in ipairs(offsets) do
        local ahead = workspace:Raycast(origin + off, Vector3.new(0, -4, 0), BhopRayParams)
        if not ahead then
            return true
        end
    end
    return false
end

local function bhopStep(dt)
    if not Config.Movement.Bhop.Enabled then return end
    if not UserInputService:IsKeyDown(Config.Movement.Bhop.Key) then return end

    local char, hum, hrp = getLocalParts()
    if not char or not hum or not hrp then return end
    if hum.Health <= 0 then return end

    local grounded = hum.FloorMaterial ~= Enum.Material.Air
    BhopState.WasGrounded = grounded

    if grounded then
        hum.Jump = true
    end
end

local function edgeBugStep(dt)
    if not Config.Movement.EdgeBug.Enabled then return end
    if not UserInputService:IsKeyDown(Config.Movement.EdgeBug.Key) then return end

    local char, hum, hrp = getLocalParts()
    if not char or not hum or not hrp then return end
    if hum.Health <= 0 then return end

    local now = os.clock()
    if now - EdgeBugState.LastTrigger < Config.Movement.EdgeBug.Cooldown then
        return
    end

    local vel = hrp.AssemblyLinearVelocity
    local grounded = hum.FloorMaterial ~= Enum.Material.Air

    if grounded then
        EdgeBugState.WasAir = false
        EdgeBugState.FallFrames = 0
        return
    end

    if vel.Y < -Config.Movement.EdgeBug.MinFallSpeed then
        if isNearLedge(hrp, char) then
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
            EdgeBugState.LastTrigger = now
            EdgeBugState.FallFrames = 0
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- SPECTATOR LIST (Win95)
-- ══════════════════════════════════════════════════════════════════════════

local WIN95 = {
    BG = Color3.fromRGB(192, 192, 192), LightEdge = Color3.fromRGB(255, 255, 255),
    MidEdge = Color3.fromRGB(128, 128, 128), DarkEdge = Color3.fromRGB(0, 0, 0),
    TitleBar1 = Color3.fromRGB(0, 0, 128), TitleBar2 = Color3.fromRGB(16, 132, 208),
    TitleText = Color3.fromRGB(255, 255, 255), Text = Color3.fromRGB(0, 0, 0),
    TextDim = Color3.fromRGB(128, 128, 128),
}

local function applyRaisedBorder(frame)
    local top = Instance.new("Frame", frame)
    top.BorderSizePixel = 0; top.BackgroundColor3 = WIN95.LightEdge
    top.Size = UDim2.new(1, 0, 0, 1); top.Position = UDim2.new(0, 0, 0, 0); top.ZIndex = frame.ZIndex + 1
    local left = Instance.new("Frame", frame)
    left.BorderSizePixel = 0; left.BackgroundColor3 = WIN95.LightEdge
    left.Size = UDim2.new(0, 1, 1, 0); left.Position = UDim2.new(0, 0, 0, 0); left.ZIndex = frame.ZIndex + 1
    local bot = Instance.new("Frame", frame)
    bot.BorderSizePixel = 0; bot.BackgroundColor3 = WIN95.DarkEdge
    bot.Size = UDim2.new(1, 0, 0, 1); bot.Position = UDim2.new(0, 0, 1, -1); bot.ZIndex = frame.ZIndex + 1
    local right = Instance.new("Frame", frame)
    right.BorderSizePixel = 0; right.BackgroundColor3 = WIN95.DarkEdge
    right.Size = UDim2.new(0, 1, 1, 0); right.Position = UDim2.new(1, -1, 0, 0); right.ZIndex = frame.ZIndex + 1
    local mtop = Instance.new("Frame", frame)
    mtop.BorderSizePixel = 0; mtop.BackgroundColor3 = WIN95.LightEdge
    mtop.Size = UDim2.new(1, -2, 0, 1); mtop.Position = UDim2.new(0, 1, 0, 1); mtop.ZIndex = frame.ZIndex + 1
    local mleft = Instance.new("Frame", frame)
    mleft.BorderSizePixel = 0; mleft.BackgroundColor3 = WIN95.LightEdge
    mleft.Size = UDim2.new(0, 1, 1, -2); mleft.Position = UDim2.new(0, 1, 0, 1); mleft.ZIndex = frame.ZIndex + 1
    local mbot = Instance.new("Frame", frame)
    mbot.BorderSizePixel = 0; mbot.BackgroundColor3 = WIN95.MidEdge
    mbot.Size = UDim2.new(1, -2, 0, 1); mbot.Position = UDim2.new(0, 1, 1, -2); mbot.ZIndex = frame.ZIndex + 1
    local mright = Instance.new("Frame", frame)
    mright.BorderSizePixel = 0; mright.BackgroundColor3 = WIN95.MidEdge
    mright.Size = UDim2.new(0, 1, 1, -2); mright.Position = UDim2.new(1, -2, 0, 1); mright.ZIndex = frame.ZIndex + 1
end

local function applySunkenBorder(frame)
    local top = Instance.new("Frame", frame)
    top.BorderSizePixel = 0; top.BackgroundColor3 = WIN95.MidEdge
    top.Size = UDim2.new(1, 0, 0, 1); top.Position = UDim2.new(0, 0, 0, 0); top.ZIndex = frame.ZIndex + 1
    local left = Instance.new("Frame", frame)
    left.BorderSizePixel = 0; left.BackgroundColor3 = WIN95.MidEdge
    left.Size = UDim2.new(0, 1, 1, 0); left.Position = UDim2.new(0, 0, 0, 0); left.ZIndex = frame.ZIndex + 1
    local bot = Instance.new("Frame", frame)
    bot.BorderSizePixel = 0; bot.BackgroundColor3 = WIN95.LightEdge
    bot.Size = UDim2.new(1, 0, 0, 1); bot.Position = UDim2.new(0, 0, 1, -1); bot.ZIndex = frame.ZIndex + 1
    local right = Instance.new("Frame", frame)
    right.BorderSizePixel = 0; right.BackgroundColor3 = WIN95.LightEdge
    right.Size = UDim2.new(0, 1, 1, 0); right.Position = UDim2.new(1, -1, 0, 0); right.ZIndex = frame.ZIndex + 1
end

local function getUIParent()
    if gethui then return gethui() end
    return game:GetService("CoreGui")
end

local function createWin95SpectatorList()
    if SpectatorUI.Root then return SpectatorUI.Root end
    local parent = getUIParent()
    local root = Instance.new("Frame")
    root.Name = "DeepHatSpectatorList"
    root.Size = UDim2.new(0, Config.SpectatorList.Width, 0, 62)
    root.Position = Config.SpectatorList.Position
    root.BackgroundColor3 = WIN95.BG
    root.BorderSizePixel = 0
    root.ZIndex = 10
    root.Parent = parent
    applyRaisedBorder(root)

    local dragging, dragStart, startPos
    root.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = root.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    root.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, -8, 0, 22); title.Position = UDim2.new(0, 4, 0, 4)
    title.BackgroundColor3 = WIN95.TitleBar1; title.BorderSizePixel = 0
    title.ZIndex = 12; title.Parent = root
    Instance.new("UIGradient", title).Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, WIN95.TitleBar1),
        ColorSequenceKeypoint.new(1, WIN95.TitleBar2),
    })

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -32, 1, 0); titleText.Position = UDim2.new(0, 4, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Spectators"; titleText.TextColor3 = WIN95.TitleText
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Font = Enum.Font.SourceSansBold; titleText.TextSize = 15
    titleText.TextStrokeTransparency = 1; titleText.ZIndex = 13; titleText.Parent = title

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 20, 0, 16); closeBtn.Position = UDim2.new(1, -22, 0, 3)
    closeBtn.BackgroundColor3 = WIN95.BG; closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"; closeBtn.TextColor3 = WIN95.Text
    closeBtn.Font = Enum.Font.SourceSansBold; closeBtn.TextSize = 13
    closeBtn.TextStrokeTransparency = 1; closeBtn.ZIndex = 14; closeBtn.Parent = title
    applyRaisedBorder(closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        Config.SpectatorList.Enabled = false
        root.Visible = false
    end)

    local countLabel = Instance.new("TextLabel")
    countLabel.Size = UDim2.new(1, -16, 0, 22); countLabel.Position = UDim2.new(0, 8, 0, 30)
    countLabel.BackgroundTransparency = 1
    countLabel.Text = "Nobody is watching you"; countLabel.TextColor3 = WIN95.Text
    countLabel.TextXAlignment = Enum.TextXAlignment.Left
    countLabel.Font = Enum.Font.SourceSansBold; countLabel.TextSize = 14
    countLabel.TextStrokeTransparency = 1; countLabel.ZIndex = 12; countLabel.Parent = root

    local listContainer = Instance.new("Frame")
    listContainer.Size = UDim2.new(1, -16, 0, 0); listContainer.Position = UDim2.new(0, 8, 0, 56)
    listContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255); listContainer.BorderSizePixel = 0
    listContainer.ZIndex = 12; listContainer.Visible = false; listContainer.Parent = root
    applySunkenBorder(listContainer)
    local ll = Instance.new("UIListLayout", listContainer)
    ll.FillDirection = Enum.FillDirection.Vertical
    ll.SortOrder = Enum.SortOrder.LayoutOrder
    ll.Padding = UDim.new(0, 0)

    SpectatorUI.Root = root
    SpectatorUI.CountLabel = countLabel
    SpectatorUI.ListContainer = listContainer
    return root
end

local function updateWin95SpectatorList()
    if not Config.SpectatorList.Enabled then
        if SpectatorUI.Root then SpectatorUI.Root.Visible = false end
        return
    end
    local root = createWin95SpectatorList()
    root.Visible = true
    local now = os.clock()
    if now - SpectatorUI.LastUpdate < 0.5 then return end
    SpectatorUI.LastUpdate = now
    local count = 0
    pcall(function() count = LocalPlayer:GetAttribute("Spectators") or 0 end)
    if SpectatorUI.CountLabel then
        if count == 0 then
            SpectatorUI.CountLabel.Text = "Nobody is watching you"
            SpectatorUI.CountLabel.TextColor3 = WIN95.TextDim
        elseif count == 1 then
            SpectatorUI.CountLabel.Text = "1 spectator is watching"
            SpectatorUI.CountLabel.TextColor3 = WIN95.Text
        else
            SpectatorUI.CountLabel.Text = count .. " spectators are watching"
            SpectatorUI.CountLabel.TextColor3 = WIN95.Text
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- ESP
-- ══════════════════════════════════════════════════════════════════════════

local function setupESP(player)
    if player == LocalPlayer or ESP_Data[player] then return end
    ESP_Data[player] = {
        Box = makeDrawing("Square", {Filled = false, Thickness = Config.ESP.BoxThickness, Visible = false}),
        BoxTop = makeDrawing("Line", {Thickness = Config.ESP.BoxThickness, Visible = false}),
        BoxBottom = makeDrawing("Line", {Thickness = Config.ESP.BoxThickness, Visible = false}),
        BoxLeft = makeDrawing("Line", {Thickness = Config.ESP.BoxThickness, Visible = false}),
        BoxRight = makeDrawing("Line", {Thickness = Config.ESP.BoxThickness, Visible = false}),
        DotTL = makeDrawing("Square", {Filled = true, Thickness = 0, Visible = false}),
        DotTR = makeDrawing("Square", {Filled = true, Thickness = 0, Visible = false}),
        DotBL = makeDrawing("Square", {Filled = true, Thickness = 0, Visible = false}),
        DotBR = makeDrawing("Square", {Filled = true, Thickness = 0, Visible = false}),
        HealthBar = makeDrawing("Line", {Thickness = Config.ESP.HealthBarWidth, Visible = false}),
        HealthBarBack = makeDrawing("Line", {Thickness = Config.ESP.HealthBarWidth, Visible = false}),
        Name = makeDrawing("Text", {Size = Config.ESP.NameSize, Center = true, Outline = Config.ESP.NameOutline, Font = 2, Visible = false}),
    }
end

local function hideESP(data)
    for _, key in ipairs({"Box", "BoxTop", "BoxBottom", "BoxLeft", "BoxRight", "DotTL", "DotTR", "DotBL", "DotBR", "HealthBar", "HealthBarBack", "Name"}) do
        if data[key] then data[key].Visible = false end
    end
end

local function removeESP(player)
    local d = ESP_Data[player]; if not d then return end
    for _, obj in pairs(d) do obj.Visible = false; obj:Remove() end
    ESP_Data[player] = nil
end

local function drawGradientBox(data, pos, width, height, player)
    local x1, y1 = pos.X - width * 0.5, pos.Y - height * 0.5
    local x2, y2 = pos.X + width * 0.5, pos.Y + height * 0.5
    local colors = Config.ESP.Colors
    local topC, botC = colors.BoxTop, colors.BoxBot
    if Config.ESP.TeamColorMode then
        local tc = getTeamColor(player)
        if tc then topC = tc; botC = lerpColor(tc, Color3.new(0, 0, 0), 0.5) end
    end
    data.Box.Visible = false
    data.BoxTop.From = Vector2.new(x1, y1); data.BoxTop.To = Vector2.new(x2, y1)
    data.BoxTop.Color = topC; data.BoxTop.Visible = true
    data.BoxBottom.From = Vector2.new(x1, y2); data.BoxBottom.To = Vector2.new(x2, y2)
    data.BoxBottom.Color = botC; data.BoxBottom.Visible = true
    local midC = lerpColor(topC, botC, 0.5)
    data.BoxLeft.From = Vector2.new(x1, y1); data.BoxLeft.To = Vector2.new(x1, y2)
    data.BoxLeft.Color = midC; data.BoxLeft.Visible = true
    data.BoxRight.From = Vector2.new(x2, y1); data.BoxRight.To = Vector2.new(x2, y2)
    data.BoxRight.Color = midC; data.BoxRight.Visible = true
    if Config.ESP.BoxCornerDots then
        local s = Config.ESP.DotSize
        local dc = colors.CornerDot
        local function place(dot, cx, cy)
            dot.Size = Vector2.new(s, s); dot.Position = Vector2.new(cx - s * 0.5, cy - s * 0.5)
            dot.Color = dc; dot.Visible = true
        end
        place(data.DotTL, x1, y1); place(data.DotTR, x2, y1)
        place(data.DotBL, x1, y2); place(data.DotBR, x2, y2)
    else
        data.DotTL.Visible = false; data.DotTR.Visible = false
        data.DotBL.Visible = false; data.DotBR.Visible = false
    end
end

local function drawHealthBar(data, pos, width, height, cur, max)
    if not Config.ESP.HealthBar or not cur or not max or max <= 0 then
        data.HealthBar.Visible = false; data.HealthBarBack.Visible = false; return
    end
    local pct = math.clamp(cur / max, 0, 1)
    local x = pos.X - width * 0.5 - Config.ESP.HealthBarOffset
    local y1, y2 = pos.Y - height * 0.5, pos.Y + height * 0.5
    data.HealthBarBack.From = Vector2.new(x, y1); data.HealthBarBack.To = Vector2.new(x, y2)
    data.HealthBarBack.Color = Config.ESP.Colors.HealthBack; data.HealthBarBack.Visible = true
    data.HealthBar.From = Vector2.new(x, y1); data.HealthBar.To = Vector2.new(x, y1 + height * pct)
    data.HealthBar.Color = lerpColor(Config.ESP.Colors.HealthLow, Config.ESP.Colors.HealthHigh, pct)
    data.HealthBar.Visible = true
end

-- ══════════════════════════════════════════════════════════════════════════
-- UNLOAD
-- ══════════════════════════════════════════════════════════════════════════

local function unload()
    print("[DeepHat] Unloading...")
    uninstallKnifeHooks()
    uninstallSpreadHooks()
    if SpectatorUI.Root then pcall(function() SpectatorUI.Root:Destroy() end); SpectatorUI.Root = nil end
    for _, sound in ipairs(Hitsound.Instances) do pcall(function() sound:Destroy() end) end
    Hitsound.Instances = {}
    for _, conn in ipairs(Connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    table.clear(Connections)
    for player in pairs(ESP_Data) do removeESP(player) end
    for _, obj in ipairs(Drawing_Registry) do obj.Visible = false; obj:Remove() end
    table.clear(Drawing_Registry)
    if WorldInitialized then revertWorldVisuals() end
    pcall(function() Library:Unload() end)
    print("[DeepHat] Unload complete.")
end

-- ══════════════════════════════════════════════════════════════════════════
-- MAIN LOOP
-- ══════════════════════════════════════════════════════════════════════════

local function mainLoop()
    if not Config.Enabled then
        for _, data in pairs(ESP_Data) do hideESP(data) end
        return
    end
    if Config.World.Enabled then
        if Config.World.KillGameEffects then stealGameEffects() end
        pcall(forceWorldVisuals, false)
    end
    pcall(updateWin95SpectatorList)
    pcall(updateHitmarker)

    if not Config.ESP.Enabled then
        for _, data in pairs(ESP_Data) do hideESP(data) end
        return
    end

    local camPos = Camera.CFrame.Position
    for player, data in pairs(ESP_Data) do
        if Config.ESP.TeamCheck and isTeammate(player) then
            hideESP(data)
        else
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local alive = char and isAlive(char)
            if char and hrp and (alive or not Config.ESP.HealthCheck) then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                local dx, dy, dz = hrp.Position.X - camPos.X, hrp.Position.Y - camPos.Y, hrp.Position.Z - camPos.Z
                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)
                if onScreen and distance <= Config.MaxDistance then
                    local head = char:FindFirstChild("Head")
                    local headPos = Camera:WorldToViewportPoint((head and head.Position or hrp.Position + Vector3.new(0, 2, 0)) + Vector3.new(0, 0.5, 0))
                    local legPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 1.6
                    if Config.ESP.GradientBoxes then
                        drawGradientBox(data, pos, width, height, player)
                    else
                        hideESP(data)
                    end
                    local cur, max = getHealth(char)
                    drawHealthBar(data, pos, width, height, cur, max)
                    if Config.ESP.Names then
                        data.Name.Position = Vector2.new(pos.X, pos.Y - height * 0.5 - 15)
                        data.Name.Text = string.format("%s [%d]", player.DisplayName or player.Name, math.floor(distance))
                        data.Name.Color = Config.ESP.Colors.Name
                        data.Name.Visible = true
                    elseif data.Name.Visible then
                        data.Name.Visible = false
                    end
                else
                    hideESP(data)
                end
            else
                hideESP(data)
            end
        end
    end
end

-- ══════════════════════════════════════════════════════════════════════════
-- INIT
-- ══════════════════════════════════════════════════════════════════════════

local function initialize()
    CachedMyTeam = getTeamName(LocalPlayer)

    if Config.World.Enabled then initWorldVisuals() end
    if Config.Hitmarker.Enabled then initHitmarker() end
    if Config.Hitsound.Enabled then initHitsound() end

    if Config.SkinChanger.Enabled then
        task.spawn(function() task.wait(0.5) installKnifeHooks() end)
    end
    if Config.NoSpread.Enabled then
        task.spawn(function() task.wait(1) installSpreadHooks() end)
    end
    if Config.SpectatorList.Enabled then
        task.spawn(function() task.wait(1) createWin95SpectatorList() end)
    end
    task.spawn(function() task.wait(1.5) installHitDetection() end)

    RunService:BindToRenderStep("DeepHatBhop", Enum.RenderPriority.Character.Value + 1, function(dt)
        pcall(bhopStep, dt)
    end)
    RunService:BindToRenderStep("DeepHatEdgeBug", Enum.RenderPriority.Character.Value + 2, function(dt)
        pcall(edgeBugStep, dt)
    end)

    table.insert(Connections, Players.PlayerAdded:Connect(setupESP))
    table.insert(Connections, Players.PlayerRemoving:Connect(removeESP))
    for _, player in ipairs(Players:GetPlayers()) do task.spawn(setupESP, player) end

    table.insert(Connections, LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        CachedMyTeam = getTeamName(LocalPlayer)
        BhopState.WasGrounded = true
        EdgeBugState.WasAir = false
        EdgeBugState.FallFrames = 0
    end))

    table.insert(Connections, RunService.RenderStepped:Connect(mainLoop))

    table.insert(Connections, UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.End then unload() end
    end))

    print("[DeepHat] Online. [INSERT] menu  [END] unload.")
end

task.spawn(function()
    task.wait(1)
    initialize()
end)



-- DeepHat DEBUG: bhop + auto edgebug + pixel surf + wall glide + u/s counter.
-- [END] to unload.

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local RS               = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local CharacterController = require(RS.Controllers.CharacterController)

-- ── config ────────────────────────────────────────────────────────────────

local Config = {
    Bhop = {
        Enabled  = true,
        Key      = Enum.KeyCode.Space,
        MinDelay = 0.03,
    },
    EdgeBug = {
        Enabled      = true,
        MinFallSpeed = 15,
        Cooldown     = 0.1,
    },
    -- pixel surf: preserve velocity while moving along a wall at an angle
    PixelSurf = {
        Enabled       = true,
        -- surface normal must be more horizontal than this (0=up, 1=side)
        MinNormalY    = 0.6,
        -- how much velocity to keep per frame while in contact (1.0 = none lost)
        Retention     = 0.98,
        -- minimum horizontal speed to bother
        MinSpeed      = 8,
        -- fire only when a wall/floor is under this many studs away
        ContactDist   = 1.2,
    },
    -- wall glide: cancel vertical fall while pressed against a vertical surface
    WallGlide = {
        Enabled       = true,
        -- how much to reduce downward velocity (0=none, 1=full cancel)
        CancelFactor  = 0.9,
        -- how much horizontal speed to add per frame for the glide
        PushSpeed     = 0.15,
        -- only glide if moving faster than this
        MinSpeed      = 5,
        -- distance to wall to trigger
        ContactDist   = 1.2,
    },
    Counter = {
        Enabled = true,
        X = 20, Y = 20, Size = 20,
    },
    Debug = {
        PrintBhopFires = false,
        PrintEdgebug   = true,
        PrintSurf      = false,
        PrintGlide     = false,
    },
}

-- ── state ─────────────────────────────────────────────────────────────────

local Connections = {}
local Drawings    = {}

local BhopState      = {FireCount = 0, LastFire = 0}
local EdgeBugState   = {LastTrigger = 0, Active = false, TriggerCount = 0}
local SurfState      = {Active = false, Frames = 0}
local GlideState     = {Active = false, Frames = 0, LastPush = 0}
local VelHistory     = {LastPos = nil, LastTime = 0, Smoothed = 0, Peak = 0, PeakTime = 0}

-- ── drawing ───────────────────────────────────────────────────────────────

local function makeDrawing(kind, props)
    local d = Drawing.new(kind)
    for k, v in pairs(props) do d[k] = v end
    Drawings[#Drawings + 1] = d
    return d
end

local VelText   = makeDrawing("Text", {Size = 20, Center = false, Outline = true, Font = 2, Color = Color3.fromRGB(255,255,255), Visible = false})
local PeakText  = makeDrawing("Text", {Size = 18, Center = false, Outline = true, Font = 2, Color = Color3.fromRGB(180,180,255), Visible = false})
local StateText = makeDrawing("Text", {Size = 16, Center = false, Outline = true, Font = 2, Color = Color3.fromRGB(180,255,180), Visible = false})

-- ── helpers ───────────────────────────────────────────────────────────────

local function getLocalParts()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return char, hrp
end

local groundParams = RaycastParams.new()
groundParams.FilterType = Enum.RaycastFilterType.Exclude
groundParams.IgnoreWater = true

local function isGrounded(char, hrp)
    groundParams.FilterDescendantsInstances = {char, Camera}
    local r = workspace:Raycast(hrp.Position - Vector3.new(0, 1.5, 0),
                                 Vector3.new(0, -2.5, 0), groundParams)
    return r ~= nil
end

local function isOverLedge(char, hrp)
    groundParams.FilterDescendantsInstances = {char, Camera}
    if workspace:Raycast(hrp.Position, Vector3.new(0, -6, 0), groundParams) then
        return false
    end
    local hits = 0
    for _, off in ipairs({Vector3.new(1.2,0,0), Vector3.new(-1.2,0,0), Vector3.new(0,0,1.2), Vector3.new(0,0,-1.2)}) do
        if workspace:Raycast(hrp.Position + off, Vector3.new(0, -8, 0), groundParams) then
            hits = hits + 1
        end
    end
    return hits >= 2
end

-- scan 8 directions around the HRP for a nearby surface hit
local function scanSurfaces(char, hrp, dist)
    groundParams.FilterDescendantsInstances = {char, Camera}
    local dirs = {
        Vector3.new(1,0,0), Vector3.new(-1,0,0),
        Vector3.new(0,0,1), Vector3.new(0,0,-1),
        Vector3.new(1,0,1).Unit, Vector3.new(-1,0,1).Unit,
        Vector3.new(1,0,-1).Unit, Vector3.new(-1,0,-1).Unit,
    }
    local results = {}
    for _, dir in ipairs(dirs) do
        local r = workspace:Raycast(hrp.Position, dir * dist, groundParams)
        if r then
            results[#results+1] = {
                normal = r.Normal,
                position = r.Position,
                instance = r.Instance,
                direction = dir,
            }
        end
    end
    return results
end

-- ── bhop ──────────────────────────────────────────────────────────────────

local function bhopStep()
    if not Config.Bhop.Enabled then return end
    if not UserInputService:IsKeyDown(Config.Bhop.Key) then return end

    local char, hrp = getLocalParts()
    if not char or not hrp then return end
    if char:GetAttribute("Dead") then return end

    local now = os.clock()
    if now - BhopState.LastFire < Config.Bhop.MinDelay then return end
    if not isGrounded(char, hrp) then return end

    local ok, err = pcall(function() CharacterController.jump() end)
    if not ok then
        warn("[bhop] jump() error:", err)
        return
    end
    BhopState.LastFire = now
    BhopState.FireCount = BhopState.FireCount + 1
    if Config.Debug.PrintBhopFires then
        print(string.format("[bhop] fired #%d", BhopState.FireCount))
    end
end

-- ── auto edgebug ─────────────────────────────────────────────────────────

local function edgeBugStep()
    if not Config.EdgeBug.Enabled then return end

    local char, hrp = getLocalParts()
    if not char or not hrp then return end
    if char:GetAttribute("Dead") then return end

    if isGrounded(char, hrp) then
        EdgeBugState.Active = false
        return
    end

    local vel = hrp.AssemblyLinearVelocity
    if vel.Y > -Config.EdgeBug.MinFallSpeed then return end

    local now = os.clock()
    if now - EdgeBugState.LastTrigger < Config.EdgeBug.Cooldown then return end
    if not isOverLedge(char, hrp) then return end

    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, 0, vel.Z)
    EdgeBugState.LastTrigger = now
    EdgeBugState.Active = true
    EdgeBugState.TriggerCount = EdgeBugState.TriggerCount + 1
    if Config.Debug.PrintEdgebug then
        print(string.format("[edgebug] #%d vy=%.2f", EdgeBugState.TriggerCount, vel.Y))
    end
end

-- ── pixel surf ────────────────────────────────────────────────────────────
-- when a wall/slanted surface is nearby, project velocity onto the surface
-- plane and keep the magnitude. gives the slide feel.

local function pixelSurfStep()
    if not Config.PixelSurf.Enabled then return end

    local char, hrp = getLocalParts()
    if not char or not hrp then return end
    if char:GetAttribute("Dead") then return end

    local vel = hrp.AssemblyLinearVelocity
    local horizSpeed = math.sqrt(vel.X * vel.X + vel.Z * vel.Z)
    if horizSpeed < Config.PixelSurf.MinSpeed then
        SurfState.Active = false
        return
    end

    local surfaces = scanSurfaces(char, hrp, Config.PixelSurf.ContactDist)
    if #surfaces == 0 then
        SurfState.Active = false
        return
    end

    -- combine all surfaces into one averaged plane
    local n = Vector3.new(0, 0, 0)
    for _, s in ipairs(surfaces) do
        -- ignore surfaces too flat to be walls (dot with up < threshold)
        if math.abs(s.normal.Y) <= Config.PixelSurf.MinNormalY then
            n = n + s.normal
        end
    end
    if n.Magnitude < 0.01 then
        SurfState.Active = false
        return
    end
    n = n.Unit

    -- project velocity onto the surface plane (remove component into wall)
    local into = vel:Dot(n)
    local projected = vel - (n * into)

    -- keep horizontal magnitude, preserve vertical a bit
    local newVel = projected * Config.PixelSurf.Retention
    newVel = Vector3.new(newVel.X, math.min(newVel.Y, vel.Y * 0.9), newVel.Z)

    hrp.AssemblyLinearVelocity = newVel
    SurfState.Active = true
    SurfState.Frames = SurfState.Frames + 1
    if Config.Debug.PrintSurf and SurfState.Frames % 10 == 0 then
        print(string.format("[surf] frames=%d  hspeed=%.1f", SurfState.Frames, horizSpeed))
    end
end

-- ── wall glide ────────────────────────────────────────────────────────────
-- when pressed against a vertical surface while airborne, cancel most of
-- vertical velocity and push horizontally along the wall.

local function wallGlideStep()
    if not Config.WallGlide.Enabled then return end

    local char, hrp = getLocalParts()
    if not char or not hrp then return end
    if char:GetAttribute("Dead") then return end
    if isGrounded(char, hrp) then
        GlideState.Active = false
        return
    end

    local vel = hrp.AssemblyLinearVelocity
    local horizSpeed = math.sqrt(vel.X * vel.X + vel.Z * vel.Z)
    if horizSpeed < Config.WallGlide.MinSpeed then
        GlideState.Active = false
        return
    end

    local surfaces = scanSurfaces(char, hrp, Config.WallGlide.ContactDist)
    -- find the most "wall-like" surface: normal is mostly horizontal
    local best = nil
    local bestDot = 0.5
    for _, s in ipairs(surfaces) do
        local walliness = 1 - math.abs(s.normal.Y)
        if walliness > bestDot then
            bestDot = walliness
            best = s
        end
    end
    if not best then
        GlideState.Active = false
        return
    end

    -- cancel part of the vertical fall
    local newY = vel.Y * (1 - Config.WallGlide.CancelFactor)
    -- push horizontally along the wall (perpendicular to normal, in the
    -- direction of current horizontal velocity)
    local horizDir = Vector3.new(vel.X, 0, vel.Z)
    if horizDir.Magnitude > 0.01 then
        horizDir = horizDir.Unit
        -- remove any component that pushes into the wall
        local into = horizDir:Dot(best.normal)
        horizDir = (horizDir - best.normal * into)
        if horizDir.Magnitude > 0.01 then
            horizDir = horizDir.Unit
            local push = horizDir * Config.WallGlide.PushSpeed
            hrp.AssemblyLinearVelocity = Vector3.new(vel.X + push.X, newY, vel.Z + push.Z)
            GlideState.Active = true
            GlideState.Frames = GlideState.Frames + 1
            if Config.Debug.PrintGlide and GlideState.Frames % 10 == 0 then
                print(string.format("[glide] frames=%d  vy=%.2f", GlideState.Frames, newY))
            end
            return
        end
    end

    hrp.AssemblyLinearVelocity = Vector3.new(vel.X, newY, vel.Z)
    GlideState.Active = true
    GlideState.Frames = GlideState.Frames + 1
end

-- ── counter ───────────────────────────────────────────────────────────────

local function updateCounter()
    local char, hrp = getLocalParts()
    if not hrp then
        VelText.Visible = false
        PeakText.Visible = false
        StateText.Visible = false
        return
    end

    local now = os.clock()
    if VelHistory.LastPos and VelHistory.LastTime > 0 then
        local dt = now - VelHistory.LastTime
        if dt > 0 then
            local dx = hrp.Position.X - VelHistory.LastPos.X
            local dz = hrp.Position.Z - VelHistory.LastPos.Z
            local raw = math.sqrt(dx*dx + dz*dz) / dt
            VelHistory.Smoothed = VelHistory.Smoothed + (raw - VelHistory.Smoothed) * 0.35
        end
    end
    VelHistory.LastPos = hrp.Position
    VelHistory.LastTime = now

    if VelHistory.Smoothed > VelHistory.Peak then
        VelHistory.Peak = VelHistory.Smoothed
        VelHistory.PeakTime = now
    end
    if now - VelHistory.PeakTime > 4 then
        VelHistory.Peak = VelHistory.Smoothed
        VelHistory.PeakTime = now
    end

    VelText.Text = string.format("%.1f u/s", VelHistory.Smoothed)
    VelText.Position = Vector2.new(Config.Counter.X, Config.Counter.Y)
    VelText.Visible = true

    PeakText.Text = string.format("peak: %.1f", VelHistory.Peak)
    PeakText.Position = Vector2.new(Config.Counter.X, Config.Counter.Y + Config.Counter.Size + 2)
    PeakText.Visible = true

    local bits = {}
    if char then
        bits[#bits+1] = isGrounded(char, hrp) and "GROUND" or "AIR"
    end
    if BhopState.FireCount > 0 then bits[#bits+1] = "bh=" .. BhopState.FireCount end
    if EdgeBugState.TriggerCount > 0 then bits[#bits+1] = "eb=" .. EdgeBugState.TriggerCount end
    if SurfState.Active then bits[#bits+1] = "SURF" end
    if GlideState.Active then bits[#bits+1] = "GLIDE" end

    StateText.Text = table.concat(bits, "  ")
    StateText.Position = Vector2.new(Config.Counter.X, Config.Counter.Y + Config.Counter.Size * 2 + 4)
    if GlideState.Active then
        StateText.Color = Color3.fromRGB(100, 200, 255)
    elseif SurfState.Active then
        StateText.Color = Color3.fromRGB(255, 220, 100)
    elseif EdgeBugState.Active then
        StateText.Color = Color3.fromRGB(255, 180, 80)
    else
        StateText.Color = Color3.fromRGB(180, 255, 180)
    end
    StateText.Visible = true
end

-- ── unload ────────────────────────────────────────────────────────────────

local function unload()
    print("[DeepHat-Debug] Unloading...")
    RunService:UnbindFromRenderStep("DeepHatBhop")
    RunService:UnbindFromRenderStep("DeepHatCounter")
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Connections)
    for _, d in ipairs(Drawings) do pcall(function() d.Visible = false; d:Remove() end) end
    table.clear(Drawings)
    print("[DeepHat-Debug] Unloaded.")
end

-- ── init ──────────────────────────────────────────────────────────────────

local function initialize()
    print("[DeepHat-Debug] init")

    if Config.Bhop.Enabled then
        RunService:BindToRenderStep("DeepHatBhop",
            Enum.RenderPriority.Last.Value, bhopStep)
    end

    if Config.Counter.Enabled then
        RunService:BindToRenderStep("DeepHatCounter",
            Enum.RenderPriority.Last.Value + 1, updateCounter)
    end

    -- surface features run on Heartbeat so they see the post-physics state
    Connections[#Connections + 1] = RunService.Heartbeat:Connect(function(dt)
        pcall(edgeBugStep, dt)
        pcall(pixelSurfStep, dt)
        pcall(wallGlideStep, dt)
    end)

    Connections[#Connections + 1] = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.End then unload() end
    end)

    print("[DeepHat-Debug] ready.")
    print("  hold SPACE to bhop")
    print("  edgebug, pixel surf, and wall glide are automatic")
end

task.spawn(function()
    task.wait(0.5)
    initialize()
end)
