local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Insert = table.insert
local Remove = table.remove
local Floor = math.floor
local Max = math.max
local Min = math.min
local Clamp = math.clamp
local Abs = math.abs
local Format = string.format
local Upper = string.upper
local Find = string.find
local NewVector2 = Vector2.new
local NewColor3 = Color3.new
local FromRGB = Color3.fromRGB
local FromHSV = Color3.fromHSV
local Spawn = task.spawn
local Wait = task.wait
local Type = type
local TypeOf = typeof

if _G.Balls1Drawings then
    for Index = #_G.Balls1Drawings, 1, -1 do
        local Object = _G.Balls1Drawings[Index]
        if Object then
            Object:Remove()
        end
    end
end

_G.Balls1Token = (_G.Balls1Token or 0) + 1
_G.Balls1Drawings = {}

local Token = _G.Balls1Token
local Drawings = _G.Balls1Drawings

local Themes = {
    Indigo = {
        Outline = FromRGB(0, 0, 0),
        Background = FromRGB(10, 11, 16),
        Inline = FromRGB(26, 27, 36),
        AccentColor = FromRGB(86, 66, 235),
        SidebarBackground = FromRGB(15, 16, 23),
        GroupBackground = FromRGB(13, 14, 21),
        PrimaryText = FromRGB(255, 255, 255),
        SecondaryText = FromRGB(138, 141, 158),
        ToggleBackground = FromRGB(20, 21, 30),
        HoverState = FromRGB(30, 31, 42)
    },
    Nightfall = {
        Outline = FromRGB(0, 0, 0),
        Background = FromRGB(10, 11, 16),
        Inline = FromRGB(26, 27, 36),
        AccentColor = FromRGB(167, 92, 255),
        SidebarBackground = FromRGB(15, 16, 23),
        GroupBackground = FromRGB(13, 14, 21),
        PrimaryText = FromRGB(255, 255, 255),
        SecondaryText = FromRGB(138, 141, 158),
        ToggleBackground = FromRGB(20, 21, 30),
        HoverState = FromRGB(30, 31, 42)
    },
    Bloodmoon = {
        Outline = FromRGB(0, 0, 0),
        Background = FromRGB(18, 5, 5),
        Inline = FromRGB(36, 16, 16),
        AccentColor = FromRGB(255, 51, 51),
        SidebarBackground = FromRGB(23, 10, 10),
        GroupBackground = FromRGB(20, 7, 7),
        PrimaryText = FromRGB(255, 255, 255),
        SecondaryText = FromRGB(158, 122, 122),
        ToggleBackground = FromRGB(30, 18, 18),
        HoverState = FromRGB(42, 22, 22)
    },
    Ocean = {
        Outline = FromRGB(0, 0, 0),
        Background = FromRGB(5, 10, 18),
        Inline = FromRGB(16, 26, 36),
        AccentColor = FromRGB(51, 167, 255),
        SidebarBackground = FromRGB(10, 16, 23),
        GroupBackground = FromRGB(7, 13, 20),
        PrimaryText = FromRGB(255, 255, 255),
        SecondaryText = FromRGB(122, 141, 158),
        ToggleBackground = FromRGB(18, 21, 30),
        HoverState = FromRGB(22, 31, 42)
    },
    Mint = {
        Outline = FromRGB(0, 0, 0),
        Background = FromRGB(5, 18, 12),
        Inline = FromRGB(16, 36, 26),
        AccentColor = FromRGB(51, 255, 153),
        SidebarBackground = FromRGB(10, 23, 18),
        GroupBackground = FromRGB(7, 20, 15),
        PrimaryText = FromRGB(255, 255, 255),
        SecondaryText = FromRGB(122, 158, 138),
        ToggleBackground = FromRGB(18, 30, 23),
        HoverState = FromRGB(22, 42, 31)
    }
}

local ThemeNames = {"Indigo", "Nightfall", "Bloodmoon", "Ocean", "Mint"}

local KeyNames = {
    [5] = "MOUSE4",
    [6] = "MOUSE5",
    [8] = "BACK",
    [9] = "TAB",
    [13] = "ENTER",
    [16] = "SHIFT",
    [17] = "CTRL",
    [18] = "ALT",
    [20] = "CAPS",
    [27] = "ESC",
    [32] = "SPACE",
    [33] = "PGUP",
    [34] = "PGDN",
    [35] = "END",
    [36] = "HOME",
    [37] = "LEFT",
    [38] = "UP",
    [39] = "RIGHT",
    [40] = "DOWN",
    [45] = "INS",
    [46] = "DEL",
    [96] = "NUM0",
    [97] = "NUM1",
    [98] = "NUM2",
    [99] = "NUM3",
    [100] = "NUM4",
    [101] = "NUM5",
    [102] = "NUM6",
    [103] = "NUM7",
    [104] = "NUM8",
    [105] = "NUM9",
    [106] = "NUM*",
    [107] = "NUM+",
    [109] = "NUM-",
    [110] = "NUM.",
    [111] = "NUM/",
    [160] = "LSHIFT",
    [161] = "RSHIFT",
    [162] = "LCTRL",
    [163] = "RCTRL",
    [164] = "LALT",
    [165] = "RALT"
}

local KeyCodes = {}

for Code, Name in pairs(KeyNames) do
    KeyCodes[Name] = Code
end

for Code = 48, 57 do
    KeyCodes[string.char(Code)] = Code
end

for Code = 65, 90 do
    KeyCodes[string.char(Code)] = Code
end

for Index = 1, 12 do
    KeyCodes["F" .. tostring(Index)] = 111 + Index
end

local function GetKeyName(Code)
    if Type(Code) ~= "number" or Code <= 0 then return "None" end
    if KeyNames[Code] then return KeyNames[Code] end
    if Code >= 48 and Code <= 57 then return string.char(Code) end
    if Code >= 65 and Code <= 90 then return string.char(Code) end
    if Code >= 112 and Code <= 123 then return "F" .. tostring(Code - 111) end
    return "K" .. tostring(Code)
end

local function GetKeyCode(Value)
    if Type(Value) == "number" then
        return Floor(Clamp(Value, 0, 255))
    end

    if Type(Value) ~= "string" then return 0 end

    local Name = Upper(Value)
    if Name == "NONE" or Name == "-" then return 0 end
    return KeyCodes[Name] or 0
end

local function NewDrawing(Class, Properties)
    local Object = Drawing.new(Class)

    for Name, Value in pairs(Properties) do
        Object[Name] = Value
    end

    Insert(Drawings, Object)
    return Object
end

local function RemoveDrawing(Object)
    if not Object then return end

    for Index = #Drawings, 1, -1 do
        if Drawings[Index] == Object then
            Remove(Drawings, Index)
            break
        end
    end

    Object:Remove()
end

local function RemoveList(List)
    for Index = #List, 1, -1 do
        RemoveDrawing(List[Index])
        List[Index] = nil
    end
end

local function LerpColor(Current, Target, Alpha)
    if TypeOf(Target) ~= "Color3" then
        return TypeOf(Current) == "Color3" and Current or FromRGB(255, 255, 255)
    end

    if TypeOf(Current) ~= "Color3" then
        return Target
    end

    return NewColor3(
        Current.R + (Target.R - Current.R) * Alpha,
        Current.G + (Target.G - Current.G) * Alpha,
        Current.B + (Target.B - Current.B) * Alpha
    )
end

local function ColorToHex(Color)
    if TypeOf(Color) ~= "Color3" then return "#FFFFFF" end

    return Format(
        "#%02X%02X%02X",
        Floor(Color.R * 255 + 0.5),
        Floor(Color.G * 255 + 0.5),
        Floor(Color.B * 255 + 0.5)
    )
end

local function RoundValue(Value, Step)
    if Type(Step) ~= "number" or Step <= 0 then return Value end
    return Floor(Value / Step + 0.5) * Step
end

local function PointIn(Position, Size, Point)
    if TypeOf(Position) ~= "Vector2" or TypeOf(Size) ~= "Vector2" or TypeOf(Point) ~= "Vector2" then
        return false
    end

    return
        Point.X >= Position.X
        and Point.X <= Position.X + Size.X
        and Point.Y >= Position.Y
        and Point.Y <= Position.Y + Size.Y
end

local function SafeName(Name)
    Name = tostring(Name or "Default")
    Name = string.gsub(Name, "[^%w%-%_ ]", "")
    Name = string.gsub(Name, "%s+", "_")
    if Name == "" then Name = "Default" end
    return Name
end

local Library = {
    Version = 6,
    Theme = "Indigo",
    Windows = {}
}

local WindowMethods = {}
local TabMethods = {}
local SectionMethods = {}
local CloseDropdown
local ClosePicker
local ToggleMethods = {}
local SliderMethods = {}
local DropdownMethods = {}
local ColorMethods = {}
local KeybindMethods = {}

local function ControlHeight(Control)
    if Control.Type == "Slider" then return 40 end
    if Control.Type == "Dropdown" then return 30 end
    if Control.Type == "Button" then return 30 end
    if Control.Type == "Keybind" then return 30 end
    return 25
end

local function GetSectionHeight(Section)
    local Height = 20

    for _, Control in ipairs(Section.Controls) do
        Height = Height + ControlHeight(Control)
    end

    return Max(Height + 12, 52)
end

local function SetVisible(Object, State)
    if Object then
        Object.Visible = State
    end
end

local function SetControlVisible(Control, State)
    for _, Object in pairs(Control.Drawings) do
        if TypeOf(Object) == "Drawing" then
            Object.Visible = State
        end
    end

    if Control.Bind then
        SetVisible(Control.Bind.Outline, State)
        SetVisible(Control.Bind.Inline, State)
        SetVisible(Control.Bind.Text, State)
    end

    if Control.AttachedColor then
        SetVisible(Control.AttachedColor.Outline, State)
        SetVisible(Control.AttachedColor.Fill, State)
    end
end

local function SetSectionVisible(Section, State)
    SetVisible(Section.Outline, State)
    SetVisible(Section.Background, State)
    SetVisible(Section.TitleBackground, State)
    SetVisible(Section.TitleText, State)

    for _, Control in ipairs(Section.Controls) do
        SetControlVisible(Control, State and Control.Visible)
    end
end

local function SetTabVisible(Tab, State)
    for _, Section in ipairs(Tab.Sections) do
        SetSectionVisible(Section, State)
    end
end

local function RefreshStaticColors(Window)
    local Theme = Window.Theme

    Window.MainOutline.Color = Theme.Outline
    Window.MainBackground.Color = Theme.Background
    Window.Sidebar.Color = Theme.SidebarBackground
    Window.SidebarDivider.Color = Theme.Outline
    Window.AccentLine.Color = Theme.AccentColor
    Window.TitleText.Color = Theme.PrimaryText

    for _, Corner in pairs(Window.ResizeCorners) do
        Corner.Horizontal.Color = Theme.AccentColor
        Corner.Vertical.Color = Theme.AccentColor
    end

    for _, Tab in ipairs(Window.Tabs) do
        Tab.Text.Color = Tab == Window.ActiveTab and Theme.PrimaryText or Theme.SecondaryText
        Tab.Indicator.Color = Theme.AccentColor

        for _, Section in ipairs(Tab.Sections) do
            Section.Outline.Color = Theme.Outline
            Section.Background.Color = Theme.GroupBackground
            Section.TitleBackground.Color = Theme.Background
            Section.TitleText.Color = Theme.PrimaryText

            for _, Control in ipairs(Section.Controls) do
                if Control.Type == "Toggle" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Inline.Color = Theme.Inline
                    Control.Drawings.Label.Color = Control.Value and Theme.PrimaryText or Theme.SecondaryText
                    Control.CurrentFill = Control.Value and Theme.AccentColor or Theme.ToggleBackground
                    Control.Drawings.Fill.Color = Control.CurrentFill
                elseif Control.Type == "Slider" then
                    Control.Drawings.Label.Color = Theme.SecondaryText
                    Control.Drawings.Value.Color = Theme.PrimaryText
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Background.Color = Theme.ToggleBackground
                    Control.Drawings.Fill.Color = Theme.AccentColor
                    Control.Drawings.Thumb.Color = Theme.PrimaryText
                elseif Control.Type == "Dropdown" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.CurrentColor = Theme.ToggleBackground
                    Control.Drawings.Inline.Color = Control.CurrentColor
                    Control.Drawings.Label.Color = Theme.SecondaryText
                    Control.Drawings.State.Color = Theme.SecondaryText
                elseif Control.Type == "Colorpicker" then
                    Control.Drawings.Label.Color = Theme.SecondaryText
                    Control.Drawings.Outline.Color = Theme.Outline
                elseif Control.Type == "Button" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.CurrentColor = Theme.ToggleBackground
                    Control.Drawings.Inline.Color = Control.CurrentColor
                    Control.Drawings.Label.Color = Theme.PrimaryText
                elseif Control.Type == "Keybind" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.CurrentColor = Theme.ToggleBackground
                    Control.Drawings.Inline.Color = Control.CurrentColor
                    Control.Drawings.Label.Color = Theme.SecondaryText
                end

                if Control.Bind then
                    Control.Bind.Outline.Color = Theme.Outline
                    Control.Bind.CurrentColor = Theme.ToggleBackground
                    Control.Bind.Inline.Color = Control.Bind.CurrentColor
                    Control.Bind.Text.Color = Theme.SecondaryText
                end

                if Control.AttachedColor then
                    Control.AttachedColor.Outline.Color = Theme.Outline
                    Control.AttachedColor.Fill.Color = Control.AttachedColor.Value
                end
            end
        end
    end

    if Window.KeybindPanel then
        Window.KeybindPanel.Outline.Color = Theme.Outline
        Window.KeybindPanel.Inline.Color = Theme.Inline
        Window.KeybindPanel.Background.Color = Theme.GroupBackground
        Window.KeybindPanel.Accent.Color = Theme.AccentColor
        Window.KeybindPanel.Title.Color = Theme.PrimaryText
    end
end

local function RefreshLayout(Window)
    local Position = Window.Position
    local Size = Window.Size
    local Theme = Window.Theme
    local SidebarWidth = 130
    local Gap = 15
    local ContentMargin = 15
    local GroupWidth = (Size.X - SidebarWidth - 45) / 2

    Window.MainOutline.Position = Position - NewVector2(1, 1)
    Window.MainOutline.Size = Size + NewVector2(2, 2)

    Window.MainBackground.Position = Position
    Window.MainBackground.Size = Size

    Window.Sidebar.Position = Position
    Window.Sidebar.Size = NewVector2(SidebarWidth, Size.Y)

    Window.SidebarDivider.Position = Position + NewVector2(SidebarWidth, 0)
    Window.SidebarDivider.Size = NewVector2(1, Size.Y)

    Window.AccentLine.Position = Position
    Window.AccentLine.Size = NewVector2(Size.X, 2)

    Window.TitleText.Position = Position + NewVector2(20, 15)

    local Bounds = {
        TL = Position,
        TR = Position + NewVector2(Size.X - 15, 0),
        BL = Position + NewVector2(0, Size.Y - 15),
        BR = Position + NewVector2(Size.X - 15, Size.Y - 15)
    }

    for Name, Corner in pairs(Window.ResizeCorners) do
        local CornerPosition = Bounds[Name]

        if Name == "TL" then
            Corner.Horizontal.Position = CornerPosition - NewVector2(1, 1)
            Corner.Vertical.Position = CornerPosition - NewVector2(1, 1)
        elseif Name == "TR" then
            Corner.Horizontal.Position = CornerPosition + NewVector2(0, -1)
            Corner.Vertical.Position = CornerPosition + NewVector2(14, -1)
        elseif Name == "BL" then
            Corner.Horizontal.Position = CornerPosition + NewVector2(-1, 14)
            Corner.Vertical.Position = CornerPosition + NewVector2(-1, 0)
        else
            Corner.Horizontal.Position = CornerPosition + NewVector2(0, 14)
            Corner.Vertical.Position = CornerPosition + NewVector2(14, 0)
        end

        Corner.Horizontal.Size = NewVector2(15, 2)
        Corner.Vertical.Size = NewVector2(2, 15)
    end

    for Index, Tab in ipairs(Window.Tabs) do
        local Y = 50 + Index * 30
        Tab.Text.Position = Position + NewVector2(25, Y)
        Tab.Indicator.Position = Position + NewVector2(1, Y + 1)
        Tab.Indicator.Size = NewVector2(2, 12)
        Tab.HitPosition = Position + NewVector2(12, Y - 5)
        Tab.HitSize = NewVector2(112, 24)
    end

    if Window.ActiveTab then
        local LeftY = Position.Y + 20
        local RightY = Position.Y + 20

        for _, Section in ipairs(Window.ActiveTab.Sections) do
            local Side = Section.Side == "Right" and 2 or 1
            local X = Position.X + SidebarWidth + ContentMargin + (Side - 1) * (GroupWidth + Gap)
            local Y = Side == 1 and LeftY or RightY
            local Height = GetSectionHeight(Section)

            Section.Position = NewVector2(X, Y)
            Section.Size = NewVector2(GroupWidth, Height)

            Section.Outline.Position = Section.Position
            Section.Outline.Size = Section.Size
            Section.Background.Position = Section.Position + NewVector2(1, 1)
            Section.Background.Size = Section.Size - NewVector2(2, 2)

            local TitleWidth = Max(48, #Section.Name * 7 + 8)
            Section.TitleBackground.Position = Section.Position + NewVector2(10, -2)
            Section.TitleBackground.Size = NewVector2(TitleWidth, 4)
            Section.TitleText.Position = Section.Position + NewVector2(14, -6)

            local ControlY = Y + 20

            for _, Control in ipairs(Section.Controls) do
                local X0 = X + 15
                local Width = GroupWidth - 30

                if Control.Type == "Toggle" then
                    Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                    Control.Drawings.Outline.Size = NewVector2(12, 12)
                    Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                    Control.Drawings.Inline.Size = NewVector2(10, 10)
                    Control.Drawings.Fill.Position = NewVector2(X0 + 2, ControlY + 2)
                    Control.Drawings.Fill.Size = NewVector2(8, 8)
                    Control.Drawings.Label.Position = NewVector2(X0 + 20, ControlY - 1)

                    Control.HitPosition = NewVector2(X0, ControlY - 4)
                    Control.HitSize = NewVector2(Width, 20)

                    local Right = X0 + Width

                    if Control.Bind then
                        Control.Bind.HitPosition = NewVector2(Right - 45, ControlY - 2)
                        Control.Bind.HitSize = NewVector2(45, 16)
                        Control.Bind.Outline.Position = Control.Bind.HitPosition
                        Control.Bind.Outline.Size = Control.Bind.HitSize
                        Control.Bind.Inline.Position = Control.Bind.HitPosition + NewVector2(1, 1)
                        Control.Bind.Inline.Size = Control.Bind.HitSize - NewVector2(2, 2)
                        Control.Bind.Text.Position = Control.Bind.HitPosition + NewVector2(22.5, 5)
                        Right = Right - 52
                    end

                    if Control.AttachedColor then
                        Control.AttachedColor.HitPosition = NewVector2(Right - 24, ControlY - 1)
                        Control.AttachedColor.HitSize = NewVector2(24, 14)
                        Control.AttachedColor.Outline.Position = Control.AttachedColor.HitPosition
                        Control.AttachedColor.Outline.Size = Control.AttachedColor.HitSize
                        Control.AttachedColor.Fill.Position = Control.AttachedColor.HitPosition + NewVector2(1, 1)
                        Control.AttachedColor.Fill.Size = Control.AttachedColor.HitSize - NewVector2(2, 2)
                    end

                elseif Control.Type == "Slider" then
                    Control.Drawings.Label.Position = NewVector2(X0, ControlY)
                    Control.Drawings.Value.Position = NewVector2(X0 + Width - 60, ControlY)
                    Control.Drawings.Outline.Position = NewVector2(X0, ControlY + 18)
                    Control.Drawings.Outline.Size = NewVector2(Width, 8)
                    Control.Drawings.Background.Position = NewVector2(X0 + 1, ControlY + 19)
                    Control.Drawings.Background.Size = NewVector2(Width - 2, 6)

                    local Range = Control.Max - Control.Min
                    local Percent = Range > 0 and Clamp((Control.Value - Control.Min) / Range, 0, 1) or 0
                    local FillWidth = Max(2, (Width - 2) * Percent)

                    Control.Drawings.Fill.Position = NewVector2(X0 + 1, ControlY + 19)
                    Control.Drawings.Fill.Size = NewVector2(FillWidth, 6)
                    Control.Drawings.Thumb.Position = NewVector2(X0 + 1 + FillWidth, ControlY + 22)

                    Control.HitPosition = NewVector2(X0, ControlY + 12)
                    Control.HitSize = NewVector2(Width, 20)

                elseif Control.Type == "Dropdown" then
                    Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                    Control.Drawings.Outline.Size = NewVector2(Width, 22)
                    Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                    Control.Drawings.Inline.Size = NewVector2(Width - 2, 20)
                    Control.Drawings.Label.Position = NewVector2(X0 + 8, ControlY + 5)
                    Control.Drawings.State.Position = NewVector2(X0 + Width - 16, ControlY + 5)

                    Control.HitPosition = NewVector2(X0, ControlY)
                    Control.HitSize = NewVector2(Width, 22)

                elseif Control.Type == "Colorpicker" then
                    Control.Drawings.Label.Position = NewVector2(X0, ControlY + 2)
                    Control.Drawings.Outline.Position = NewVector2(X0 + Width - 46, ControlY)
                    Control.Drawings.Outline.Size = NewVector2(46, 18)
                    Control.Drawings.Fill.Position = NewVector2(X0 + Width - 45, ControlY + 1)
                    Control.Drawings.Fill.Size = NewVector2(44, 16)

                    Control.HitPosition = NewVector2(X0, ControlY - 2)
                    Control.HitSize = NewVector2(Width, 22)

                elseif Control.Type == "Button" then
                    Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                    Control.Drawings.Outline.Size = NewVector2(Width, 22)
                    Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                    Control.Drawings.Inline.Size = NewVector2(Width - 2, 20)
                    Control.Drawings.Label.Position = NewVector2(X0 + Width / 2, ControlY + 5)

                    Control.HitPosition = NewVector2(X0, ControlY)
                    Control.HitSize = NewVector2(Width, 22)

                elseif Control.Type == "Keybind" then
                    Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                    Control.Drawings.Outline.Size = NewVector2(Width, 22)
                    Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                    Control.Drawings.Inline.Size = NewVector2(Width - 2, 20)
                    Control.Drawings.Label.Position = NewVector2(X0 + Width / 2, ControlY + 5)

                    Control.HitPosition = NewVector2(X0, ControlY)
                    Control.HitSize = NewVector2(Width, 22)
                end

                ControlY = ControlY + ControlHeight(Control)
            end

            if Side == 1 then
                LeftY = Y + Height + 14
            else
                RightY = Y + Height + 14
            end
        end
    end

    if Window.KeybindPanel then
        local Panel = Window.KeybindPanel
        local Rows = Panel.Rows
        local Height = 28 + #Rows * 18

        Panel.Outline.Position = Panel.Position - NewVector2(1, 1)
        Panel.Outline.Size = NewVector2(182, Height + 2)
        Panel.Inline.Position = Panel.Position
        Panel.Inline.Size = NewVector2(180, Height)
        Panel.Background.Position = Panel.Position + NewVector2(1, 1)
        Panel.Background.Size = NewVector2(178, Height - 2)
        Panel.Accent.Position = Panel.Position + NewVector2(1, 1)
        Panel.Accent.Size = NewVector2(178, 2)
        Panel.Title.Position = Panel.Position + NewVector2(10, 6)

        for Index, Row in ipairs(Rows) do
            Row.Name.Position = Panel.Position + NewVector2(10, 10 + Index * 18)
            Row.State.Position = Panel.Position + NewVector2(140, 10 + Index * 18)
        end
    end

    RefreshStaticColors(Window)
end

local function ApplyVisibility(Window)
    local Visible = Window.Open

    Window.MainOutline.Visible = Visible
    Window.MainBackground.Visible = Visible
    Window.Sidebar.Visible = Visible
    Window.SidebarDivider.Visible = Visible
    Window.AccentLine.Visible = Visible
    Window.TitleText.Visible = Visible

    for _, Corner in pairs(Window.ResizeCorners) do
        Corner.Horizontal.Visible = Visible
        Corner.Vertical.Visible = Visible
    end

    for _, Tab in ipairs(Window.Tabs) do
        Tab.Text.Visible = Visible
        Tab.Indicator.Visible = Visible and Tab == Window.ActiveTab
        SetTabVisible(Tab, Visible and Tab == Window.ActiveTab)
    end

    if Window.KeybindPanel then
        local PanelVisible = Window.ShowKeybinds
        Window.KeybindPanel.Outline.Visible = PanelVisible
        Window.KeybindPanel.Inline.Visible = PanelVisible
        Window.KeybindPanel.Background.Visible = PanelVisible
        Window.KeybindPanel.Accent.Visible = PanelVisible
        Window.KeybindPanel.Title.Visible = PanelVisible

        for _, Row in ipairs(Window.KeybindPanel.Rows) do
            Row.Name.Visible = PanelVisible
            Row.State.Visible = PanelVisible
        end
    end
end

local function SetTab(Window, Tab)
    if not Tab or Window.ActiveTab == Tab then return end

    if Window.ActiveTab then
        SetTabVisible(Window.ActiveTab, false)
    end

    Window.ActiveTab = Tab
    CloseDropdown(Window)
    ClosePicker(Window)
    RefreshLayout(Window)
    ApplyVisibility(Window)
end

function Library:SetTheme(Name)
    if Type(Name) ~= "string" or not Themes[Name] then return end

    self.Theme = Name

    for _, Window in ipairs(self.Windows) do
        Window.ThemeName = Name
        Window.Theme = Themes[Name]
        RefreshLayout(Window)
        ApplyVisibility(Window)
    end
end

function Library:SetBackgroundImage()
end

local function MakeWindowDrawings(Window)
    local Theme = Window.Theme

    Window.MainOutline = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.3,
        Corner = 12,
        Color = Theme.Outline
    })

    Window.MainBackground = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.7,
        Corner = 12,
        Color = Theme.Background
    })

    Window.Sidebar = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.6,
        Corner = 12,
        Color = Theme.SidebarBackground
    })

    Window.SidebarDivider = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.2,
        Color = Theme.Outline
    })

    Window.AccentLine = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        Color = Theme.AccentColor
    })

    Window.TitleText = NewDrawing("Text", {
        Text = Upper(Window.Title),
        Size = 16,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = true,
        Transparency = 1,
        Color = Theme.PrimaryText
    })


    Window.ResizeCorners = {}

    for _, Name in ipairs({"TL", "TR", "BL", "BR"}) do
        Window.ResizeCorners[Name] = {
            Horizontal = NewDrawing("Square", {
                Filled = true,
                Visible = true,
                Transparency = 0.3,
                Color = Theme.AccentColor
            }),
            Vertical = NewDrawing("Square", {
                Filled = true,
                Visible = true,
                Transparency = 0.3,
                Color = Theme.AccentColor
            })
        }
    end
end

function Library:CreateWindow(Options)
    Options = Type(Options) == "table" and Options or {}

    local Window = setmetatable({
        Title = tostring(Options.title or Options.Title or "Nightfall"),
        Subtitle = tostring(Options.subtitle or Options.Subtitle or ""),
        Position = TypeOf(Options.position) == "Vector2" and Options.position or NewVector2(200, 180),
        Size = TypeOf(Options.size) == "Vector2" and Options.size or NewVector2(550, 430),
        MinimumSize = NewVector2(520, 420),
        MenuKey = GetKeyCode(Options.menuKey or Options.MenuKey or "F2"),
        ConfigName = SafeName(Options.configName or Options.ConfigName or "Default"),
        ConfigFolder = SafeName(Options.configFolder or Options.ConfigFolder or "Balls1"),
        ThemeName = self.Theme,
        Theme = Themes[self.Theme],
        Tabs = {},
        Controls = {},
        Binds = {},
        ActiveTab = nil,
        Active = true,
        Open = Options.startOpen ~= false,
        LastMouse = false,
        KeyHeld = false,
        Capturing = nil,
        ActiveSlider = nil,
        OpenDropdown = nil,
        OpenPicker = nil,
        Dragging = false,
        Resizing = nil,
        ShowKeybinds = true
    }, {__index = WindowMethods})

    if Window.Size.X < Window.MinimumSize.X then
        Window.Size = NewVector2(Window.MinimumSize.X, Window.Size.Y)
    end

    if Window.Size.Y < Window.MinimumSize.Y then
        Window.Size = NewVector2(Window.Size.X, Window.MinimumSize.Y)
    end

    MakeWindowDrawings(Window)
    Insert(self.Windows, Window)

    RefreshLayout(Window)
    ApplyVisibility(Window)

    Spawn(function()
        Window:Run()
    end)

    return Window
end

function WindowMethods:Tab(Name)
    local Tab = setmetatable({
        Window = self,
        Name = tostring(Name or "Tab"),
        Sections = {},
        HitPosition = NewVector2(0, 0),
        HitSize = NewVector2(0, 0)
    }, {__index = TabMethods})

    Tab.Text = NewDrawing("Text", {
        Text = Tab.Name,
        Size = 14,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = self.Open,
        Transparency = 1,
        Color = self.Theme.SecondaryText
    })

    Tab.Indicator = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Color = self.Theme.AccentColor
    })

    Insert(self.Tabs, Tab)

    if not self.ActiveTab then
        self.ActiveTab = Tab
    end

    RefreshLayout(self)
    ApplyVisibility(self)
    return Tab
end

function TabMethods:Section(Name, Side)
    local Section = setmetatable({
        Tab = self,
        Window = self.Window,
        Name = tostring(Name or "Section"),
        Side = Side == "Right" and "Right" or "Left",
        Controls = {},
        Position = NewVector2(0, 0),
        Size = NewVector2(0, 0)
    }, {__index = SectionMethods})

    local Theme = self.Window.Theme

    Section.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.2,
        Corner = 8,
        Color = Theme.Outline
    })

    Section.Background = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.1,
        Corner = 8,
        Color = Theme.GroupBackground
    })

    Section.TitleBackground = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Corner = 6,
        Color = Theme.Background
    })

    Section.TitleText = NewDrawing("Text", {
        Text = Section.Name,
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })

    Insert(self.Sections, Section)
    RefreshLayout(self.Window)
    ApplyVisibility(self.Window)
    return Section
end

local function AddControl(Section, Control)
    Control.Section = Section
    Control.Window = Section.Window
    Control.Visible = true
    Insert(Section.Controls, Control)
    Insert(Section.Window.Controls, Control)
    RefreshLayout(Section.Window)
    ApplyVisibility(Section.Window)
    return Control
end

function SectionMethods:Toggle(Name, Default, Callback)
    local Theme = self.Window.Theme

    local Control = setmetatable({
        Type = "Toggle",
        Name = tostring(Name or "Toggle"),
        Value = Default == true,
        Callback = Type(Callback) == "function" and Callback or nil,
        Drawings = {},
        CurrentFill = Default == true and Theme.AccentColor or Theme.ToggleBackground
    }, {__index = ToggleMethods})

    Control.Drawings.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 5,
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.5,
        Corner = 5,
        Color = Theme.Inline
    })

    Control.Drawings.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Corner = 4,
        Color = Control.CurrentFill
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name,
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Control.Value and Theme.PrimaryText or Theme.SecondaryText
    })

    return AddControl(self, Control)
end

function ToggleMethods:GetValue()
    return self.Value
end

function ToggleMethods:SetValue(Value, Silent)
    Value = Value == true
    if self.Value == Value then return end

    self.Value = Value
    self.Drawings.Label.Color = Value and self.Window.Theme.PrimaryText or self.Window.Theme.SecondaryText
    self.CurrentFill = Value and self.Window.Theme.AccentColor or self.Window.Theme.ToggleBackground
    self.Drawings.Fill.Color = self.CurrentFill

    if not Silent and self.Callback then
        self.Callback(Value)
    end
end

function ToggleMethods:AddKeybind(Default, Mode)
    if self.Bind then return self.Bind end

    local Theme = self.Window.Theme
    local Bind = setmetatable({
        Control = self,
        Window = self.Window,
        Key = GetKeyCode(Default),
        Mode = Mode == "Hold" and "Hold" or Mode == "Always" and "Always" or "Toggle",
        Held = false,
        CurrentColor = Theme.ToggleBackground,
        HitPosition = NewVector2(0, 0),
        HitSize = NewVector2(0, 0)
    }, {__index = KeybindMethods})

    Bind.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 6,
        Color = Theme.Outline
    })

    Bind.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Corner = 5,
        Color = Theme.ToggleBackground
    })

    Bind.Text = NewDrawing("Text", {
        Text = "[" .. GetKeyName(Bind.Key) .. "]",
        Size = 12,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    self.Bind = Bind
    Insert(self.Window.Binds, Bind)
    RefreshLayout(self.Window)
    ApplyVisibility(self.Window)
    return Bind
end

function ToggleMethods:AddColorpicker(Name, Default, Callback)
    if self.AttachedColor then return self.AttachedColor end

    local Theme = self.Window.Theme
    local Color = TypeOf(Default) == "Color3" and Default or FromRGB(255, 255, 255)

    local Picker = setmetatable({
        Type = "AttachedColor",
        Name = tostring(Name or "Color"),
        Control = self,
        Window = self.Window,
        Value = Color,
        Callback = Type(Callback) == "function" and Callback or nil,
        HitPosition = NewVector2(0, 0),
        HitSize = NewVector2(0, 0)
    }, {__index = ColorMethods})

    Picker.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 4,
        Color = Theme.Outline
    })

    Picker.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Corner = 3,
        Color = Color
    })

    self.AttachedColor = Picker
    RefreshLayout(self.Window)
    ApplyVisibility(self.Window)
    return Picker
end

function SectionMethods:Slider(Name, Default, Step, Minimum, Maximum, Suffix, Callback)
    local Theme = self.Window.Theme
    Minimum = Type(Minimum) == "number" and Minimum or 0
    Maximum = Type(Maximum) == "number" and Maximum or 100

    if Maximum < Minimum then
        Minimum, Maximum = Maximum, Minimum
    end

    local Value = Type(Default) == "number" and Default or Minimum
    Value = Clamp(RoundValue(Value, Step), Minimum, Maximum)

    local Control = setmetatable({
        Type = "Slider",
        Name = tostring(Name or "Slider"),
        Value = Value,
        Step = Type(Step) == "number" and Step or 1,
        Min = Minimum,
        Max = Maximum,
        Suffix = tostring(Suffix or ""),
        Callback = Type(Callback) == "function" and Callback or nil,
        Drawings = {}
    }, {__index = SliderMethods})

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name,
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    Control.Drawings.Value = NewDrawing("Text", {
        Text = tostring(Control.Value) .. Control.Suffix,
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })

    Control.Drawings.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 6,
        Color = Theme.Outline
    })

    Control.Drawings.Background = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.5,
        Corner = 6,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.9,
        Corner = 6,
        Color = Theme.AccentColor
    })

    Control.Drawings.Thumb = NewDrawing("Circle", {
        Filled = true,
        Radius = 4,
        NumSides = 24,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })

    return AddControl(self, Control)
end

function SliderMethods:GetValue()
    return self.Value
end

function SliderMethods:SetValue(Value, Silent)
    if Type(Value) ~= "number" then return end

    Value = Clamp(RoundValue(Value, self.Step), self.Min, self.Max)

    if Abs(Value - self.Value) < 0.000001 then return end

    self.Value = Value
    self.Drawings.Value.Text = tostring(Value) .. self.Suffix
    RefreshLayout(self.Window)

    if not Silent and self.Callback then
        self.Callback(Value)
    end
end

local function DropdownText(Control)
    if not Control.Multi then
        return Control.Name .. ": " .. tostring(Control.Value or "-")
    end

    local Selected = {}

    for _, Option in ipairs(Control.Options) do
        if Control.Value[Option] then
            Insert(Selected, tostring(Option))
        end
    end

    return Control.Name .. ": " .. (#Selected > 0 and table.concat(Selected, ", ") or "-")
end

function SectionMethods:Dropdown(Name, Default, Options, Multi, Callback)
    local Theme = self.Window.Theme
    Options = Type(Options) == "table" and Options or {}

    local Value

    if Multi then
        Value = {}

        if Type(Default) == "table" then
            for _, Entry in ipairs(Default) do
                Value[Entry] = true
            end

            for Key, Entry in pairs(Default) do
                if Type(Key) == "string" and Entry == true then
                    Value[Key] = true
                end
            end
        end
    else
        if Type(Default) == "table" then
            Value = Default[1]
        else
            Value = Default
        end

        if Value == nil then
            Value = Options[1]
        end
    end

    local Control = setmetatable({
        Type = "Dropdown",
        Name = tostring(Name or "Dropdown"),
        Value = Value,
        Options = Options,
        Multi = Multi == true,
        Callback = Type(Callback) == "function" and Callback or nil,
        Drawings = {},
        CurrentColor = Theme.ToggleBackground
    }, {__index = DropdownMethods})

    Control.Drawings.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 6,
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Corner = 6,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = DropdownText(Control),
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    Control.Drawings.State = NewDrawing("Text", {
        Text = "+",
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    return AddControl(self, Control)
end

function DropdownMethods:GetValue()
    if not self.Multi then return self.Value end

    local Result = {}

    for _, Option in ipairs(self.Options) do
        if self.Value[Option] then
            Insert(Result, Option)
        end
    end

    return Result
end

function DropdownMethods:SetValue(Value, Silent)
    if self.Multi then
        local Selected = {}

        if Type(Value) == "table" then
            for _, Entry in ipairs(Value) do
                Selected[Entry] = true
            end

            for Key, Entry in pairs(Value) do
                if Type(Key) == "string" and Entry == true then
                    Selected[Key] = true
                end
            end
        end

        self.Value = Selected
    else
        self.Value = Value
    end

    self.Drawings.Label.Text = DropdownText(self)

    if not Silent and self.Callback then
        self.Callback(self:GetValue())
    end
end

function SectionMethods:Colorpicker(Name, Default, Callback)
    local Theme = self.Window.Theme
    local Color = TypeOf(Default) == "Color3" and Default or FromRGB(255, 255, 255)

    local Control = setmetatable({
        Type = "Colorpicker",
        Name = tostring(Name or "Color"),
        Value = Color,
        Callback = Type(Callback) == "function" and Callback or nil,
        Drawings = {}
    }, {__index = ColorMethods})

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name,
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    Control.Drawings.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 4,
        Color = Theme.Outline
    })

    Control.Drawings.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Corner = 3,
        Color = Color
    })

    return AddControl(self, Control)
end

function ColorMethods:GetValue()
    return self.Value
end

function ColorMethods:SetValue(Value, Silent)
    if TypeOf(Value) ~= "Color3" then return end

    self.Value = Value

    if self.Fill then
        self.Fill.Color = Value
    elseif self.Drawings and self.Drawings.Fill then
        self.Drawings.Fill.Color = Value
    end

    if not Silent and self.Callback then
        self.Callback(Value)
    end
end

function SectionMethods:Button(Name, Callback)
    local Theme = self.Window.Theme

    local Control = {
        Type = "Button",
        Name = tostring(Name or "Button"),
        Callback = Type(Callback) == "function" and Callback or nil,
        Drawings = {},
        CurrentColor = Theme.ToggleBackground
    }

    Control.Drawings.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 6,
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Corner = 6,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name,
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })

    return AddControl(self, Control)
end

function SectionMethods:Keybind(Name, Default, Callback)
    local Theme = self.Window.Theme

    local Control = setmetatable({
        Type = "Keybind",
        Name = tostring(Name or "Keybind"),
        Value = GetKeyCode(Default),
        Callback = Type(Callback) == "function" and Callback or nil,
        Drawings = {},
        CurrentColor = Theme.ToggleBackground
    }, {__index = KeybindMethods})

    Control.Drawings.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Corner = 6,
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Corner = 6,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name .. " [ " .. GetKeyName(Control.Value) .. " ]",
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    return AddControl(self, Control)
end

function KeybindMethods:GetValue()
    return self.Control and self.Key or self.Value
end

function KeybindMethods:SetKey(Value)
    if not self.Control then
        return self:SetValue(Value)
    end

    self.Key = GetKeyCode(Value)
    self.Text.Text = "[" .. GetKeyName(self.Key) .. "]"
end

function KeybindMethods:SetValue(Value, Silent)
    local Code = GetKeyCode(Value)

    if self.Control then
        self.Key = Code
        self.Text.Text = "[" .. GetKeyName(Code) .. "]"
        return
    end

    self.Value = Code
    self.Drawings.Label.Text = self.Name .. " [ " .. GetKeyName(Code) .. " ]"

    if not Silent and self.Callback then
        self.Callback(Code)
    end
end

function KeybindMethods:SetMode(Mode)
    if not self.Control then return end
    self.Mode = Mode == "Hold" and "Hold" or Mode == "Always" and "Always" or "Toggle"
end

CloseDropdown = function(Window)
    local Dropdown = Window.OpenDropdown
    if not Dropdown then return end

    RemoveList(Dropdown.Popup)
    Dropdown.Popup = nil
    Dropdown.PopupBounds = nil
    Dropdown.Drawings.State.Text = "+"
    Window.OpenDropdown = nil
end

local function CreateDropdown(Window, Control)
    CloseDropdown(Window)
    ClosePicker(Window)

    local Theme = Window.Theme
    local Popup = {}
    local Bounds = {}
    local Position = Control.HitPosition + NewVector2(0, 21)
    local Width = Control.HitSize.X
    local Height = #Control.Options * 20 + 2

    Insert(Popup, NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.35,
        Corner = 8,
        ZIndex = 20,
        Position = Position,
        Size = NewVector2(Width, Height),
        Color = Theme.Outline
    }))

    Insert(Popup, NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.97,
        Corner = 7,
        ZIndex = 21,
        Position = Position + NewVector2(1, 1),
        Size = NewVector2(Width - 2, Height - 2),
        Color = Theme.GroupBackground
    }))

    for Index, Option in ipairs(Control.Options) do
        local Y = Position.Y + 1 + (Index - 1) * 20
        local Selected = Control.Multi and Control.Value[Option] == true or not Control.Multi and Control.Value == Option

        local Background = NewDrawing("Square", {
            Filled = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 22,
            Position = NewVector2(Position.X + 1, Y),
            Size = NewVector2(Width - 2, 20),
            Color = Theme.GroupBackground
        })

        local Indicator = NewDrawing("Square", {
            Filled = true,
            Visible = Selected,
            Transparency = 1,
            ZIndex = 23,
            Position = NewVector2(Position.X + 1, Y + 4),
            Size = NewVector2(2, 12),
            Color = Theme.AccentColor
        })

        local Text = NewDrawing("Text", {
            Text = tostring(Option),
            Size = 13,
            Font = Drawing.Fonts.System,
            Outline = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 24,
            Position = NewVector2(Position.X + 12, Y + 4),
            Color = Selected and Theme.PrimaryText or Theme.SecondaryText
        })

        Insert(Popup, Background)
        Insert(Popup, Indicator)
        Insert(Popup, Text)

        Insert(Bounds, {
            Option = Option,
            Position = NewVector2(Position.X + 1, Y),
            Size = NewVector2(Width - 2, 20),
            Background = Background,
            Indicator = Indicator,
            Text = Text
        })
    end

    Control.Popup = Popup
    Control.PopupBounds = Bounds
    Control.Drawings.State.Text = "-"
    Window.OpenDropdown = Control
end

ClosePicker = function(Window)
    local Picker = Window.OpenPicker
    if not Picker then return end

    RemoveList(Picker.Drawings)
    Window.OpenPicker = nil
end

local function MakePicker(Window, Control)
    ClosePicker(Window)
    CloseDropdown(Window)

    local Current = Control.Value
    local H, S, V = 0, 0, 1

    if TypeOf(Current) == "Color3" then
        local MaxValue = Max(Current.R, Current.G, Current.B)
        local MinValue = Min(Current.R, Current.G, Current.B)
        local Delta = MaxValue - MinValue

        V = MaxValue
        S = MaxValue == 0 and 0 or Delta / MaxValue

        if Delta ~= 0 then
            if MaxValue == Current.R then
                H = ((Current.G - Current.B) / Delta) % 6
            elseif MaxValue == Current.G then
                H = ((Current.B - Current.R) / Delta) + 2
            else
                H = ((Current.R - Current.G) / Delta) + 4
            end

            H = H / 6
        end
    end

    local PopupWidth = 176
    local PopupHeight = 150
    local X = Clamp(Control.HitPosition.X + Control.HitSize.X - PopupWidth, 5, 5000)
    local Y = Control.HitPosition.Y + Control.HitSize.Y + 4
    local Position = NewVector2(X, Y)
    local Theme = Window.Theme
    local Objects = {}

    local function Add(Object)
        Insert(Objects, Object)
        return Object
    end

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.35,
        Corner = 8,
        ZIndex = 30,
        Position = Position,
        Size = NewVector2(PopupWidth, PopupHeight),
        Color = Theme.Outline
    }))

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.98,
        Corner = 7,
        ZIndex = 31,
        Position = Position + NewVector2(1, 1),
        Size = NewVector2(PopupWidth - 2, PopupHeight - 2),
        Color = Theme.GroupBackground
    }))

    local SvPosition = Position + NewVector2(10, 10)
    local SvSize = 110
    local Grid = 10
    local Cell = SvSize / Grid
    local SvCells = {}

    for Row = 0, Grid - 1 do
        for Column = 0, Grid - 1 do
            local Sat = Column / (Grid - 1)
            local Val = 1 - Row / (Grid - 1)
            local CellDrawing = Add(NewDrawing("Square", {
                Filled = true,
                Visible = true,
                Transparency = 1,
                ZIndex = 32,
                Position = SvPosition + NewVector2(Column * Cell, Row * Cell),
                Size = NewVector2(Cell + 1, Cell + 1),
                Color = FromHSV(H, Sat, Val)
            }))

            Insert(SvCells, {Drawing = CellDrawing, S = Sat, V = Val})
        end
    end

    local HuePosition = Position + NewVector2(130, 10)
    local HueBars = {}

    for Index = 0, 29 do
        local Hue = 1 - Index / 29
        local Bar = Add(NewDrawing("Square", {
            Filled = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 32,
            Position = HuePosition + NewVector2(0, Index * (110 / 30)),
            Size = NewVector2(12, 5),
            Color = FromHSV(Hue, 1, 1)
        }))

        Insert(HueBars, Bar)
    end

    local Preview = Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        Corner = 4,
        ZIndex = 32,
        Position = Position + NewVector2(150, 10),
        Size = NewVector2(16, 110),
        Color = Current
    }))

    local Hex = Add(NewDrawing("Text", {
        Text = ColorToHex(Current),
        Size = 12,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 33,
        Position = Position + NewVector2(10, 128),
        Color = Theme.PrimaryText
    }))

    Window.OpenPicker = {
        Control = Control,
        Position = Position,
        Size = NewVector2(PopupWidth, PopupHeight),
        Drawings = Objects,
        SvCells = SvCells,
        HueBars = HueBars,
        SvPosition = SvPosition,
        SvSize = SvSize,
        HuePosition = HuePosition,
        Hue = H,
        Saturation = S,
        Value = V,
        Preview = Preview,
        Hex = Hex
    }
end

local function UpdatePicker(Window, Point)
    local Picker = Window.OpenPicker
    if not Picker then return end

    local Changed = false

    if PointIn(Picker.SvPosition, NewVector2(Picker.SvSize, Picker.SvSize), Point) then
        Picker.Saturation = Clamp((Point.X - Picker.SvPosition.X) / Picker.SvSize, 0, 1)
        Picker.Value = 1 - Clamp((Point.Y - Picker.SvPosition.Y) / Picker.SvSize, 0, 1)
        Changed = true
    elseif PointIn(Picker.HuePosition, NewVector2(12, 110), Point) then
        Picker.Hue = 1 - Clamp((Point.Y - Picker.HuePosition.Y) / 110, 0, 1)
        Changed = true

        for _, Cell in ipairs(Picker.SvCells) do
            Cell.Drawing.Color = FromHSV(Picker.Hue, Cell.S, Cell.V)
        end
    end

    if not Changed then return end

    local Color = FromHSV(Picker.Hue, Picker.Saturation, Picker.Value)
    Picker.Preview.Color = Color
    Picker.Hex.Text = ColorToHex(Color)
    Picker.Control:SetValue(Color)
end

local function EnsureKeybindPanel(Window)
    if Window.KeybindPanel then return end

    local Theme = Window.Theme

    Window.KeybindPanel = {
        Position = NewVector2(50, 400),
        Rows = {},
        Dragging = false
    }

    local Panel = Window.KeybindPanel

    Panel.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.5,
        Corner = 4,
        Color = Theme.Outline
    })

    Panel.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.7,
        Corner = 4,
        Color = Theme.Inline
    })

    Panel.Background = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.9,
        Corner = 4,
        Color = Theme.GroupBackground
    })

    Panel.Accent = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.AccentColor
    })

    Panel.Title = NewDrawing("Text", {
        Text = "keybinds",
        Size = 13,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })
end

local function RefreshKeybindPanel(Window)
    EnsureKeybindPanel(Window)

    local Panel = Window.KeybindPanel
    local Desired = {}
    local OldCount = #Panel.Rows

    for _, Bind in ipairs(Window.Binds) do
        if Bind.Key > 0 and Bind.Control then
            Insert(Desired, Bind)
        end
    end

    while #Panel.Rows < #Desired do
        local Row = {
            Name = NewDrawing("Text", {
                Text = "",
                Size = 13,
                Font = Drawing.Fonts.System,
                Outline = true,
                Visible = false,
                Transparency = 1,
                Color = Window.Theme.PrimaryText
            }),
            State = NewDrawing("Text", {
                Text = "",
                Size = 13,
                Font = Drawing.Fonts.System,
                Outline = true,
                Visible = false,
                Transparency = 1,
                Color = Window.Theme.SecondaryText
            })
        }

        Insert(Panel.Rows, Row)
    end

    while #Panel.Rows > #Desired do
        local Row = Panel.Rows[#Panel.Rows]
        RemoveDrawing(Row.Name)
        RemoveDrawing(Row.State)
        Remove(Panel.Rows, #Panel.Rows)
    end

    for Index, Bind in ipairs(Desired) do
        local Row = Panel.Rows[Index]
        local Control = Bind.Control
        Row.Name.Text = "[" .. GetKeyName(Bind.Key) .. "] " .. Control.Name

        if Bind.Mode == "Hold" then
            Row.State.Text = Bind.Held and "[ON]" or "[OFF]"
            Row.State.Color = Bind.Held and Window.Theme.AccentColor or Window.Theme.SecondaryText
        elseif Bind.Mode == "Always" then
            Row.State.Text = "[ON]"
            Row.State.Color = Window.Theme.AccentColor
        else
            Row.State.Text = Control.Value and "[ON]" or "[OFF]"
            Row.State.Color = Control.Value and Window.Theme.AccentColor or Window.Theme.SecondaryText
        end
    end

    if OldCount ~= #Panel.Rows then
        RefreshLayout(Window)
        ApplyVisibility(Window)
    end
end

local function ProcessBind(Bind)
    local Control = Bind.Control

    if Bind.Mode == "Always" then
        if Control and Control.Type == "Toggle" and not Control.Value then
            Control:SetValue(true)
        end

        Bind.Held = true
        return
    end

    if Bind.Key <= 0 then
        Bind.Held = false
        return
    end

    local Pressed = iskeypressed(Bind.Key)

    if Bind.Mode == "Hold" then
        if Control and Control.Type == "Toggle" and Control.Value ~= Pressed then
            Control:SetValue(Pressed)
        end

        Bind.Held = Pressed
        return
    end

    if Pressed and not Bind.Held then
        if Control and Control.Type == "Toggle" then
            Control:SetValue(not Control.Value)
        end

        Bind.Held = true
    elseif not Pressed then
        Bind.Held = false
    end
end

local function EncodeValue(Control)
    if Control.Type == "Colorpicker" then
        return {
            Type = "Color3",
            R = Control.Value.R,
            G = Control.Value.G,
            B = Control.Value.B
        }
    end

    if Control.Type == "Dropdown" and Control.Multi then
        return Control:GetValue()
    end

    if Type(Control.GetValue) == "function" then
        return Control:GetValue()
    end

    return Control.Value
end

local function DecodeValue(Control, Value)
    if Control.Type == "Colorpicker" and Type(Value) == "table" and Value.Type == "Color3" then
        if Type(Value.R) == "number" and Type(Value.G) == "number" and Type(Value.B) == "number" then
            return NewColor3(Value.R, Value.G, Value.B)
        end
    end

    return Value
end

function WindowMethods:SaveConfig(Name)
    if Type(writefile) ~= "function" then return false end

    local Data = {
        Theme = self.ThemeName,
        Controls = {},
        Binds = {}
    }

    for Index, Control in ipairs(self.Controls) do
        if Control.Type ~= "Button" then
            Data.Controls[tostring(Index)] = EncodeValue(Control)
        end
    end

    for Index, Bind in ipairs(self.Binds) do
        Data.Binds[tostring(Index)] = {
            Key = Bind.Key,
            Mode = Bind.Mode
        }
    end

    local ConfigName = SafeName(Name or self.ConfigName)
    local Path = self.ConfigFolder .. "/" .. ConfigName .. ".json"
    writefile(Path, HttpService:JSONEncode(Data))
    return true
end

function WindowMethods:LoadConfig(Name)
    if Type(isfile) ~= "function" or Type(readfile) ~= "function" then return false end

    local ConfigName = SafeName(Name or self.ConfigName)
    local Path = self.ConfigFolder .. "/" .. ConfigName .. ".json"
    if not isfile(Path) then return false end

    local Data = HttpService:JSONDecode(readfile(Path))
    if Type(Data) ~= "table" then return false end

    if Type(Data.Theme) == "string" and Themes[Data.Theme] then
        Library:SetTheme(Data.Theme)
    end

    if Type(Data.Controls) == "table" then
        for Index, Control in ipairs(self.Controls) do
            local Value = Data.Controls[tostring(Index)]

            if Value ~= nil and Control.Type ~= "Button" then
                Value = DecodeValue(Control, Value)

                if Control.SetValue then
                    Control:SetValue(Value)
                end
            end
        end
    end

    if Type(Data.Binds) == "table" then
        for Index, Bind in ipairs(self.Binds) do
            local Value = Data.Binds[tostring(Index)]

            if Type(Value) == "table" then
                Bind:SetKey(Value.Key or 0)
                Bind:SetMode(Value.Mode or "Toggle")
            end
        end
    end

    RefreshLayout(self)
    ApplyVisibility(self)
    return true
end

function WindowMethods:Toggle()
    self.Open = not self.Open
    CloseDropdown(self)
    ClosePicker(self)
    self.ActiveSlider = nil
    ApplyVisibility(self)
end

function WindowMethods:SetOpen(State)
    self.Open = State == true
    CloseDropdown(self)
    ClosePicker(self)
    self.ActiveSlider = nil
    ApplyVisibility(self)
end

function WindowMethods:Unload()
    self.Active = false
    CloseDropdown(self)
    ClosePicker(self)

    for Index = #Library.Windows, 1, -1 do
        if Library.Windows[Index] == self then
            Remove(Library.Windows, Index)
            break
        end
    end

    if #Library.Windows == 0 then
        _G.Balls1Token = _G.Balls1Token + 1

        for Index = #Drawings, 1, -1 do
            local Object = Drawings[Index]
            if Object then Object:Remove() end
            Drawings[Index] = nil
        end
    else
        for _, Tab in ipairs(self.Tabs) do
            Tab.Text:Remove()
            Tab.Indicator:Remove()

            for _, Section in ipairs(Tab.Sections) do
                Section.Outline:Remove()
                Section.Background:Remove()
                Section.TitleBackground:Remove()
                Section.TitleText:Remove()

                for _, Control in ipairs(Section.Controls) do
                    for _, Object in pairs(Control.Drawings) do
                        if TypeOf(Object) == "Drawing" then Object:Remove() end
                    end
                end
            end
        end
    end
end

function WindowMethods:AddSettingsTab()
    if self.SettingsTab then return self.SettingsTab end

    local Tab = self:Tab("Settings")
    self.SettingsTab = Tab

    local Appearance = Tab:Section("Appearance", "Left")
    Appearance:Dropdown("Theme", self.ThemeName, ThemeNames, false, function(Value)
        Library:SetTheme(Value)
    end)

    Appearance:Toggle("Keybind List", true, function(State)
        self.ShowKeybinds = State
        ApplyVisibility(self)
    end)

    Appearance:Keybind("Menu Bind", self.MenuKey, function(Code)
        self.MenuKey = Code
    end)

    local Config = Tab:Section("Config Manager", "Right")

    Config:Button("Save Config", function()
        self:SaveConfig(self.ConfigName)
    end)

    Config:Button("Load Config", function()
        self:LoadConfig(self.ConfigName)
    end)

    Config:Button("Unload", function()
        self:Unload()
    end)

    return Tab
end

function WindowMethods:Run()
    EnsureKeybindPanel(self)
    RefreshLayout(self)
    ApplyVisibility(self)

    while self.Active and _G.Balls1Token == Token do
        Wait()

        local MousePosition = NewVector2(Mouse.X, Mouse.Y)
        local MousePressed = ismouse1pressed()
        local MouseDown = MousePressed and not self.LastMouse

        if self.Capturing then
            local Captured = false

            for Code = 3, 255 do
                if iskeypressed(Code) then
                    if Code == 27 then Code = 0 end

                    if self.Capturing.Control then
                        self.Capturing:SetKey(Code)
                    else
                        self.Capturing:SetValue(Code)
                    end

                    self.Capturing = nil
                    self.KeyHeld = true
                    Captured = true
                    break
                end
            end

            if not Captured then
                self.KeyHeld = false
            end
        else
            if self.MenuKey > 0 and iskeypressed(self.MenuKey) then
                if not self.KeyHeld then
                    self:Toggle()
                    self.KeyHeld = true
                end
            else
                self.KeyHeld = false
            end

            for _, Bind in ipairs(self.Binds) do
                ProcessBind(Bind)
            end
        end

        if self.OpenPicker and MousePressed then
            UpdatePicker(self, MousePosition)
        end

        if MouseDown then
            local Used = false

            if self.ShowKeybinds and self.KeybindPanel then
                local Panel = self.KeybindPanel

                if PointIn(Panel.Position, NewVector2(180, 24), MousePosition) then
                    Panel.Dragging = true
                    Panel.MouseStart = MousePosition
                    Panel.PositionStart = Panel.Position
                    Used = true
                end
            end

            if not Used and self.OpenDropdown then
                local Dropdown = self.OpenDropdown

                for _, Entry in ipairs(Dropdown.PopupBounds) do
                    if PointIn(Entry.Position, Entry.Size, MousePosition) then
                        if Dropdown.Multi then
                            Dropdown.Value[Entry.Option] = not Dropdown.Value[Entry.Option]
                            Dropdown.Drawings.Label.Text = DropdownText(Dropdown)

                            if Dropdown.Callback then
                                Dropdown.Callback(Dropdown:GetValue())
                            end

                            CreateDropdown(self, Dropdown)
                        else
                            Dropdown.Value = Entry.Option
                            Dropdown.Drawings.Label.Text = DropdownText(Dropdown)

                            if Dropdown.Callback then
                                Dropdown.Callback(Entry.Option)
                            end

                            CloseDropdown(self)
                        end

                        Used = true
                        break
                    end
                end

                if not Used and self.OpenDropdown then
                    local Position = self.OpenDropdown.HitPosition + NewVector2(0, 21)
                    local Size = NewVector2(self.OpenDropdown.HitSize.X, #self.OpenDropdown.Options * 20 + 2)

                    if not PointIn(Position, Size, MousePosition) and not PointIn(self.OpenDropdown.HitPosition, self.OpenDropdown.HitSize, MousePosition) then
                        CloseDropdown(self)
                    end
                end
            end

            if not Used and self.OpenPicker then
                local Picker = self.OpenPicker

                if PointIn(Picker.Position, Picker.Size, MousePosition) then
                    Used = true
                elseif not PointIn(Picker.Control.HitPosition, Picker.Control.HitSize, MousePosition) then
                    ClosePicker(self)
                end
            end

            if self.Open and not Used then
                local ResizeBounds = {
                    TL = {self.Position - NewVector2(5, 5), NewVector2(24, 24)},
                    TR = {self.Position + NewVector2(self.Size.X - 19, -5), NewVector2(24, 24)},
                    BL = {self.Position + NewVector2(-5, self.Size.Y - 19), NewVector2(24, 24)},
                    BR = {self.Position + NewVector2(self.Size.X - 19, self.Size.Y - 19), NewVector2(24, 24)}
                }

                for Name, Bounds in pairs(ResizeBounds) do
                    if PointIn(Bounds[1], Bounds[2], MousePosition) then
                        self.Resizing = Name
                        self.MouseStart = MousePosition
                        self.PositionStart = self.Position
                        self.SizeStart = self.Size
                        Used = true
                        break
                    end
                end

                if not Used and PointIn(self.Position, NewVector2(self.Size.X, 30), MousePosition) then
                    self.Dragging = true
                    self.MouseStart = MousePosition
                    self.PositionStart = self.Position
                    Used = true
                end

                if not Used then
                    for _, Tab in ipairs(self.Tabs) do
                        if PointIn(Tab.HitPosition, Tab.HitSize, MousePosition) then
                            SetTab(self, Tab)
                            Used = true
                            break
                        end
                    end
                end

                if not Used and self.ActiveTab then
                    for _, Section in ipairs(self.ActiveTab.Sections) do
                        for _, Control in ipairs(Section.Controls) do
                            if Control.Visible then
                                if Control.Bind and PointIn(Control.Bind.HitPosition, Control.Bind.HitSize, MousePosition) then
                                    self.Capturing = Control.Bind
                                    Used = true
                                    break
                                end

                                if Control.AttachedColor and PointIn(Control.AttachedColor.HitPosition, Control.AttachedColor.HitSize, MousePosition) then
                                    MakePicker(self, Control.AttachedColor)
                                    Used = true
                                    break
                                end

                                if PointIn(Control.HitPosition, Control.HitSize, MousePosition) then
                                    if Control.Type == "Toggle" then
                                        Control:SetValue(not Control.Value)
                                    elseif Control.Type == "Slider" then
                                        self.ActiveSlider = Control
                                    elseif Control.Type == "Dropdown" then
                                        if self.OpenDropdown == Control then
                                            CloseDropdown(self)
                                        else
                                            CreateDropdown(self, Control)
                                        end
                                    elseif Control.Type == "Colorpicker" then
                                        MakePicker(self, Control)
                                    elseif Control.Type == "Button" then
                                        if Control.Callback then Control.Callback() end
                                    elseif Control.Type == "Keybind" then
                                        self.Capturing = Control
                                    end

                                    Used = true
                                    break
                                end
                            end
                        end

                        if Used then break end
                    end
                end
            end
        end

        if MousePressed and self.ActiveSlider then
            local Slider = self.ActiveSlider
            local Percent = Clamp((MousePosition.X - Slider.HitPosition.X) / Max(Slider.HitSize.X, 1), 0, 1)
            Slider:SetValue(Slider.Min + (Slider.Max - Slider.Min) * Percent)
        end

        if MousePressed and self.Dragging then
            self.Position = self.PositionStart + (MousePosition - self.MouseStart)
            RefreshLayout(self)
        end

        if MousePressed and self.Resizing then
            local Delta = MousePosition - self.MouseStart
            local X = self.PositionStart.X
            local Y = self.PositionStart.Y
            local Width = self.SizeStart.X
            local Height = self.SizeStart.Y

            if Find(self.Resizing, "R") then
                Width = Max(self.MinimumSize.X, self.SizeStart.X + Delta.X)
            end

            if Find(self.Resizing, "B") then
                Height = Max(self.MinimumSize.Y, self.SizeStart.Y + Delta.Y)
            end

            if Find(self.Resizing, "L") then
                Width = Max(self.MinimumSize.X, self.SizeStart.X - Delta.X)
                X = self.PositionStart.X + self.SizeStart.X - Width
            end

            if Find(self.Resizing, "T") then
                Height = Max(self.MinimumSize.Y, self.SizeStart.Y - Delta.Y)
                Y = self.PositionStart.Y + self.SizeStart.Y - Height
            end

            self.Position = NewVector2(X, Y)
            self.Size = NewVector2(Width, Height)
            RefreshLayout(self)
        end

        if MousePressed and self.KeybindPanel and self.KeybindPanel.Dragging then
            self.KeybindPanel.Position = self.KeybindPanel.PositionStart + (MousePosition - self.KeybindPanel.MouseStart)
            RefreshLayout(self)
        end

        if not MousePressed then
            self.ActiveSlider = nil
            self.Dragging = false
            self.Resizing = nil

            if self.KeybindPanel then
                self.KeybindPanel.Dragging = false
            end
        end

        if self.Open and self.ActiveTab then
            local Theme = self.Theme

            for _, Section in ipairs(self.ActiveTab.Sections) do
                for _, Control in ipairs(Section.Controls) do
                    if Control.Visible then
                        local Hover = PointIn(Control.HitPosition, Control.HitSize, MousePosition)

                        if Control.Type == "Toggle" then
                            local Target = Control.Value and Theme.AccentColor or Hover and Theme.SecondaryText or Theme.ToggleBackground
                            Control.CurrentFill = LerpColor(Control.CurrentFill, Target, 0.15)
                            Control.Drawings.Fill.Color = Control.CurrentFill
                        elseif Control.Type == "Dropdown" or Control.Type == "Button" or Control.Type == "Keybind" then
                            local Target = Hover and Theme.HoverState or Theme.ToggleBackground
                            Control.CurrentColor = LerpColor(Control.CurrentColor, Target, 0.15)
                            Control.Drawings.Inline.Color = Control.CurrentColor
                        end

                        if Control.Bind then
                            local BindHover = PointIn(Control.Bind.HitPosition, Control.Bind.HitSize, MousePosition)
                            local Target = BindHover and Theme.HoverState or Theme.ToggleBackground
                            Control.Bind.CurrentColor = LerpColor(Control.Bind.CurrentColor, Target, 0.15)
                            Control.Bind.Inline.Color = Control.Bind.CurrentColor
                            Control.Bind.Text.Text = self.Capturing == Control.Bind and "[..]" or "[" .. GetKeyName(Control.Bind.Key) .. "]"
                        end

                        if Control.Type == "Dropdown" then
                            Control.Drawings.State.Text = self.OpenDropdown == Control and "-" or "+"
                        elseif Control.Type == "Keybind" then
                            Control.Drawings.Label.Text = self.Capturing == Control and Control.Name .. " [ ... ]" or Control.Name .. " [ " .. GetKeyName(Control.Value) .. " ]"
                        end
                    end
                end
            end
        end

        RefreshKeybindPanel(self)
        self.LastMouse = MousePressed
    end
end

_G.Balls1 = Library
_G.INSui = Library
