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
local Format = string.format
local Lower = string.lower
local Upper = string.upper
local Find = string.find
local Sub = string.sub
local NewVector2 = Vector2.new
local NewColor3 = Color3.new
local FromRGB = Color3.fromRGB
local Spawn = task.spawn
local Wait = task.wait

if _G.Balls1Drawings then
    for Index = #_G.Balls1Drawings, 1, -1 do
        local Object = _G.Balls1Drawings[Index]
        if Object then
            Object:Remove()
        end
    end
end

_G.Balls1Drawings = {}
_G.Balls1Token = (_G.Balls1Token or 0) + 1

local Token = _G.Balls1Token
local Drawings = _G.Balls1Drawings

local Themes = {
    Indigo = {
        Background = FromRGB(10, 11, 16),
        Outline = FromRGB(0, 0, 0),
        Inline = FromRGB(26, 27, 36),
        Accent = FromRGB(86, 66, 235),
        Sidebar = FromRGB(15, 16, 23),
        Group = FromRGB(13, 14, 21),
        Text = FromRGB(255, 255, 255),
        Dim = FromRGB(138, 141, 158),
        Control = FromRGB(20, 21, 30),
        Hover = FromRGB(30, 31, 42)
    },
    Nightfall = {
        Background = FromRGB(10, 11, 16),
        Outline = FromRGB(0, 0, 0),
        Inline = FromRGB(26, 27, 36),
        Accent = FromRGB(167, 92, 255),
        Sidebar = FromRGB(15, 16, 23),
        Group = FromRGB(13, 14, 21),
        Text = FromRGB(255, 255, 255),
        Dim = FromRGB(138, 141, 158),
        Control = FromRGB(20, 21, 30),
        Hover = FromRGB(30, 31, 42)
    },
    Bloodmoon = {
        Background = FromRGB(18, 5, 5),
        Outline = FromRGB(0, 0, 0),
        Inline = FromRGB(36, 16, 16),
        Accent = FromRGB(255, 51, 51),
        Sidebar = FromRGB(23, 10, 10),
        Group = FromRGB(20, 7, 7),
        Text = FromRGB(255, 255, 255),
        Dim = FromRGB(158, 122, 122),
        Control = FromRGB(30, 18, 18),
        Hover = FromRGB(42, 22, 22)
    },
    Ocean = {
        Background = FromRGB(5, 10, 18),
        Outline = FromRGB(0, 0, 0),
        Inline = FromRGB(16, 26, 36),
        Accent = FromRGB(51, 167, 255),
        Sidebar = FromRGB(10, 16, 23),
        Group = FromRGB(7, 13, 20),
        Text = FromRGB(255, 255, 255),
        Dim = FromRGB(122, 141, 158),
        Control = FromRGB(18, 21, 30),
        Hover = FromRGB(22, 31, 42)
    },
    Mint = {
        Background = FromRGB(5, 18, 12),
        Outline = FromRGB(0, 0, 0),
        Inline = FromRGB(16, 36, 26),
        Accent = FromRGB(51, 255, 153),
        Sidebar = FromRGB(10, 23, 18),
        Group = FromRGB(7, 20, 15),
        Text = FromRGB(255, 255, 255),
        Dim = FromRGB(122, 158, 138),
        Control = FromRGB(18, 30, 23),
        Hover = FromRGB(22, 42, 31)
    }
}

local ThemeNames = {"Indigo", "Nightfall", "Bloodmoon", "Ocean", "Mint"}

local KeyNames = {
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
    KeyCodes[Upper(Name)] = Code
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
    if type(Code) ~= "number" or Code <= 0 then return "None" end
    if KeyNames[Code] then return KeyNames[Code] end
    if Code >= 48 and Code <= 57 then return string.char(Code) end
    if Code >= 65 and Code <= 90 then return string.char(Code) end
    if Code >= 112 and Code <= 123 then return "F" .. tostring(Code - 111) end
    return "Key" .. tostring(Code)
end

local function GetKeyCode(Value)
    if type(Value) == "number" then return Floor(Clamp(Value, 0, 255)) end
    if type(Value) ~= "string" then return 0 end
    local Name = Upper(Value)
    if Name == "NONE" or Name == "-" then return 0 end
    return KeyCodes[Name] or 0
end

local function NewDrawing(Class, Properties)
    local Object = Drawing.new(Class)
    for Name, Value in pairs(Properties or {}) do
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

local function LerpColor(A, B, Alpha)
    return NewColor3(
        A.R + (B.R - A.R) * Alpha,
        A.G + (B.G - A.G) * Alpha,
        A.B + (B.B - A.B) * Alpha
    )
end

local function RgbToHsv(Color)
    local R, G, B = Color.R, Color.G, Color.B
    local High = Max(R, G, B)
    local Low = Min(R, G, B)
    local Delta = High - Low
    local H = 0
    local S = High == 0 and 0 or Delta / High
    local V = High

    if Delta ~= 0 then
        if High == R then
            H = ((G - B) / Delta) % 6
        elseif High == G then
            H = ((B - R) / Delta) + 2
        else
            H = ((R - G) / Delta) + 4
        end
        H = H / 6
    end

    return H, S, V
end

local function HsvToRgb(H, S, V)
    H = H % 1
    S = Clamp(S, 0, 1)
    V = Clamp(V, 0, 1)

    local Index = Floor(H * 6)
    local Fraction = H * 6 - Index
    local P = V * (1 - S)
    local Q = V * (1 - Fraction * S)
    local T = V * (1 - (1 - Fraction) * S)
    Index = Index % 6

    if Index == 0 then return NewColor3(V, T, P) end
    if Index == 1 then return NewColor3(Q, V, P) end
    if Index == 2 then return NewColor3(P, V, T) end
    if Index == 3 then return NewColor3(P, Q, V) end
    if Index == 4 then return NewColor3(T, P, V) end
    return NewColor3(V, P, Q)
end

local function ColorToHex(Color)
    return Format("#%02X%02X%02X", Floor(Color.R * 255 + 0.5), Floor(Color.G * 255 + 0.5), Floor(Color.B * 255 + 0.5))
end

local function RoundStep(Value, Step)
    if type(Step) ~= "number" or Step <= 0 then return Value end
    return Floor(Value / Step + 0.5) * Step
end

local function PointIn(Position, Size, MousePosition)
    return MousePosition.X >= Position.X and MousePosition.X <= Position.X + Size.X and MousePosition.Y >= Position.Y and MousePosition.Y <= Position.Y + Size.Y
end

local function SanitizeName(Name)
    Name = tostring(Name or "Config")
    Name = string.gsub(Name, "[^%w%-%_ ]", "")
    Name = string.gsub(Name, "%s+", "_")
    if Name == "" then Name = "Config" end
    return Name
end

local Library = {
    Version = 5,
    Theme = "Indigo",
    Windows = {},
    Background = nil
}

local WindowMethods = {}
local TabMethods = {}
local SectionMethods = {}
local ControlMethods = {}
local BindMethods = {}

local function SetControlVisible(Control, Visible)
    Control.Visible = Visible
    for _, Object in pairs(Control.Drawings) do
        if Object then Object.Visible = Visible end
    end
    if Control.Bind then
        Control.Bind.Box.Visible = Visible
        Control.Bind.Inline.Visible = Visible
        Control.Bind.Text.Visible = Visible
    end
    if Control.AttachedColor then
        Control.AttachedColor.Outline.Visible = Visible
        Control.AttachedColor.Box.Visible = Visible
    end
end

local function SetSectionVisible(Section, Visible)
    Section.Visible = Visible
    Section.Outline.Visible = Visible
    Section.Background.Visible = Visible
    Section.Title.Visible = Visible
    for _, Control in ipairs(Section.Controls) do
        SetControlVisible(Control, Visible)
    end
end

local function CloseDropdown(Window)
    local Dropdown = Window.OpenDropdown
    if not Dropdown then return end
    RemoveList(Dropdown.Popup)
    Dropdown.Popup = {}
    Dropdown.PopupBounds = {}
    Window.OpenDropdown = nil
end

local function ClosePicker(Window)
    local Picker = Window.OpenPicker
    if not Picker then return end
    RemoveList(Picker.Popup)
    Picker.Popup = {}
    Window.OpenPicker = nil
end

local function RefreshTheme(Window)
    local Theme = Window.Theme
    Window.Outline.Color = Theme.Outline
    Window.Background.Color = Theme.Background
    Window.Sidebar.Color = Theme.Sidebar
    Window.Divider.Color = Theme.Outline
    Window.Accent.Color = Theme.Accent
    Window.Title.Color = Theme.Text
    Window.Subtitle.Color = Theme.Dim

    for _, Tab in ipairs(Window.Tabs) do
        Tab.Text.Color = Tab == Window.ActiveTab and Theme.Text or Theme.Dim
        Tab.Indicator.Color = Theme.Accent
        for _, Section in ipairs(Tab.Sections) do
            Section.Outline.Color = Theme.Outline
            Section.Background.Color = Theme.Group
            Section.Title.Color = Theme.Text
            for _, Control in ipairs(Section.Controls) do
                if Control.Type == "Toggle" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Box.Color = Control.Value and Theme.Accent or Theme.Control
                    Control.Drawings.Text.Color = Control.Value and Theme.Text or Theme.Dim
                elseif Control.Type == "Slider" then
                    Control.Drawings.Text.Color = Theme.Dim
                    Control.Drawings.Value.Color = Theme.Text
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Bar.Color = Theme.Control
                    Control.Drawings.Fill.Color = Theme.Accent
                    Control.Drawings.Thumb.Color = Theme.Text
                elseif Control.Type == "Dropdown" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Box.Color = Theme.Control
                    Control.Drawings.Text.Color = Theme.Dim
                    Control.Drawings.Arrow.Color = Theme.Dim
                elseif Control.Type == "Colorpicker" then
                    Control.Drawings.Text.Color = Theme.Dim
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Box.Color = Control.Value
                elseif Control.Type == "Button" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Box.Color = Theme.Control
                    Control.Drawings.Text.Color = Theme.Text
                elseif Control.Type == "Label" then
                    Control.Drawings.Text.Color = Theme.Dim
                elseif Control.Type == "Keybind" then
                    Control.Drawings.Outline.Color = Theme.Outline
                    Control.Drawings.Box.Color = Theme.Control
                    Control.Drawings.Text.Color = Theme.Dim
                end

                if Control.Bind then
                    Control.Bind.Box.Color = Theme.Control
                    Control.Bind.Inline.Color = Theme.Outline
                    Control.Bind.Text.Color = Theme.Dim
                end

                if Control.AttachedColor then
                    Control.AttachedColor.Outline.Color = Theme.Outline
                    Control.AttachedColor.Box.Color = Control.AttachedColor.Value
                end
            end
        end
    end

    if Window.KeybindPanel then
        Window.KeybindPanel.Outline.Color = Theme.Outline
        Window.KeybindPanel.Background.Color = Theme.Group
        Window.KeybindPanel.Accent.Color = Theme.Accent
        Window.KeybindPanel.Title.Color = Theme.Text
    end
end

local function GetSectionHeight(Section)
    local Height = 30
    for _, Control in ipairs(Section.Controls) do
        Height = Height + Control.Height
    end
    return Height + 6
end

local function GetDropdownText(Control)
    if Control.Multi then
        local Selected = {}
        for _, Option in ipairs(Control.Options) do
            if Control.Value[Option] then Insert(Selected, Option) end
        end
        if #Selected == 0 then return "None" end
        if #Selected <= 2 then return table.concat(Selected, ", ") end
        return tostring(#Selected) .. " selected"
    end
    return tostring(Control.Value or "None")
end

local function RefreshControl(Control, X, Y, Width)
    local Window = Control.Window
    local Theme = Window.Theme
    Control.Position = NewVector2(X, Y)
    Control.Width = Width

    if Control.Type == "Toggle" then
        local D = Control.Drawings
        D.Outline.Position = NewVector2(X, Y + 4)
        D.Outline.Size = NewVector2(14, 14)
        D.Box.Position = NewVector2(X + 1, Y + 5)
        D.Box.Size = NewVector2(12, 12)
        D.Text.Position = NewVector2(X + 22, Y + 4)
        D.Text.Text = Control.Name
        D.Box.Color = Control.Value and Theme.Accent or Theme.Control
        D.Text.Color = Control.Value and Theme.Text or Theme.Dim
        Control.HitPosition = NewVector2(X, Y)
        Control.HitSize = NewVector2(Width, 22)

        local Right = X + Width
        if Control.Bind then
            local Bind = Control.Bind
            Bind.Inline.Position = NewVector2(Right - 58, Y + 2)
            Bind.Inline.Size = NewVector2(58, 18)
            Bind.Box.Position = NewVector2(Right - 57, Y + 3)
            Bind.Box.Size = NewVector2(56, 16)
            Bind.Text.Position = NewVector2(Right - 29, Y + 5)
            Bind.HitPosition = NewVector2(Right - 58, Y + 2)
            Bind.HitSize = NewVector2(58, 18)
        end

        if Control.AttachedColor then
            local Color = Control.AttachedColor
            local Offset = Control.Bind and 68 or 0
            Color.Outline.Position = NewVector2(Right - 18 - Offset, Y + 3)
            Color.Outline.Size = NewVector2(18, 16)
            Color.Box.Position = NewVector2(Right - 17 - Offset, Y + 4)
            Color.Box.Size = NewVector2(16, 14)
            Color.Box.Color = Color.Value
            Color.HitPosition = Color.Outline.Position
            Color.HitSize = Color.Outline.Size
        end
    elseif Control.Type == "Slider" then
        local D = Control.Drawings
        local Percent = (Control.Value - Control.Min) / Max(Control.Max - Control.Min, 0.0001)
        Percent = Clamp(Percent, 0, 1)
        local FillWidth = Max((Width - 2) * Percent, 2)
        D.Text.Position = NewVector2(X, Y)
        D.Text.Text = Control.Name
        D.Value.Position = NewVector2(X + Width - 58, Y)
        D.Value.Text = Control:FormatValue()
        D.Outline.Position = NewVector2(X, Y + 17)
        D.Outline.Size = NewVector2(Width, 8)
        D.Bar.Position = NewVector2(X + 1, Y + 18)
        D.Bar.Size = NewVector2(Width - 2, 6)
        D.Fill.Position = NewVector2(X + 1, Y + 18)
        D.Fill.Size = NewVector2(FillWidth, 6)
        D.Thumb.Position = NewVector2(X + 1 + FillWidth, Y + 21)
        Control.HitPosition = NewVector2(X, Y + 13)
        Control.HitSize = NewVector2(Width, 16)
    elseif Control.Type == "Dropdown" then
        local D = Control.Drawings
        D.Outline.Position = NewVector2(X, Y)
        D.Outline.Size = NewVector2(Width, 24)
        D.Box.Position = NewVector2(X + 1, Y + 1)
        D.Box.Size = NewVector2(Width - 2, 22)
        D.Text.Position = NewVector2(X + 9, Y + 5)
        D.Text.Text = Control.Name .. ": " .. GetDropdownText(Control)
        D.Arrow.Position = NewVector2(X + Width - 13, Y + 5)
        D.Arrow.Text = Window.OpenDropdown == Control and "-" or "+"
        Control.HitPosition = NewVector2(X, Y)
        Control.HitSize = NewVector2(Width, 24)
    elseif Control.Type == "Colorpicker" then
        local D = Control.Drawings
        D.Text.Position = NewVector2(X, Y + 4)
        D.Text.Text = Control.Name
        D.Outline.Position = NewVector2(X + Width - 42, Y + 2)
        D.Outline.Size = NewVector2(42, 18)
        D.Box.Position = NewVector2(X + Width - 41, Y + 3)
        D.Box.Size = NewVector2(40, 16)
        D.Box.Color = Control.Value
        Control.HitPosition = D.Outline.Position
        Control.HitSize = D.Outline.Size
    elseif Control.Type == "Button" then
        local D = Control.Drawings
        D.Outline.Position = NewVector2(X, Y)
        D.Outline.Size = NewVector2(Width, 24)
        D.Box.Position = NewVector2(X + 1, Y + 1)
        D.Box.Size = NewVector2(Width - 2, 22)
        D.Text.Position = NewVector2(X + Width / 2, Y + 5)
        D.Text.Text = Control.Name
        Control.HitPosition = NewVector2(X, Y)
        Control.HitSize = NewVector2(Width, 24)
    elseif Control.Type == "Label" then
        Control.Drawings.Text.Position = NewVector2(X, Y + 2)
        Control.Drawings.Text.Text = Control.Name
        Control.HitPosition = NewVector2(X, Y)
        Control.HitSize = NewVector2(Width, 20)
    elseif Control.Type == "Keybind" then
        local D = Control.Drawings
        D.Outline.Position = NewVector2(X, Y)
        D.Outline.Size = NewVector2(Width, 24)
        D.Box.Position = NewVector2(X + 1, Y + 1)
        D.Box.Size = NewVector2(Width - 2, 22)
        D.Text.Position = NewVector2(X + Width / 2, Y + 5)
        D.Text.Text = Control.Name .. " [ " .. GetKeyName(Control.Value) .. " ]"
        Control.HitPosition = NewVector2(X, Y)
        Control.HitSize = NewVector2(Width, 24)
    end
end

local function RefreshLayout(Window)
    local Position = Window.Position
    local Size = Window.Size
    local SidebarWidth = 132

    Window.Outline.Position = Position - NewVector2(1, 1)
    Window.Outline.Size = Size + NewVector2(2, 2)
    Window.Background.Position = Position
    Window.Background.Size = Size
    Window.Sidebar.Position = Position
    Window.Sidebar.Size = NewVector2(SidebarWidth, Size.Y)
    Window.Divider.Position = Position + NewVector2(SidebarWidth, 0)
    Window.Divider.Size = NewVector2(1, Size.Y)
    Window.Accent.Position = Position
    Window.Accent.Size = NewVector2(Size.X, 2)
    Window.Title.Position = Position + NewVector2(18, 13)
    Window.Subtitle.Position = Position + NewVector2(18, 29)

    for Name, Corner in pairs(Window.Corners) do
        local X = Position.X
        local Y = Position.Y
        if Find(Name, "R") then X = Position.X + Size.X - 14 end
        if Find(Name, "B") then Y = Position.Y + Size.Y - 14 end
        Corner.H.Position = NewVector2(X, Y)
        Corner.V.Position = NewVector2(X, Y)
        Corner.H.Size = NewVector2(14, 2)
        Corner.V.Size = NewVector2(2, 14)
    end

    for Index, Tab in ipairs(Window.Tabs) do
        local Y = Position.Y + 58 + (Index - 1) * 29
        Tab.Text.Position = NewVector2(Position.X + 22, Y)
        Tab.Indicator.Position = NewVector2(Position.X + 1, Y + 1)
        Tab.Indicator.Size = NewVector2(2, 13)
        Tab.HitPosition = NewVector2(Position.X, Y - 4)
        Tab.HitSize = NewVector2(SidebarWidth, 25)
    end

    local BodyX = Position.X + SidebarWidth + 15
    local BodyY = Position.Y + 18
    local BodyWidth = Size.X - SidebarWidth - 45
    local ColumnWidth = (BodyWidth - 12) / 2

    for _, Tab in ipairs(Window.Tabs) do
        local LeftY = BodyY
        local RightY = BodyY
        for _, Section in ipairs(Tab.Sections) do
            local X = BodyX
            local Y = LeftY
            if Section.Side == "Right" then
                X = BodyX + ColumnWidth + 12
                Y = RightY
            end

            local Height = GetSectionHeight(Section)
            Section.Position = NewVector2(X, Y)
            Section.Size = NewVector2(ColumnWidth, Height)
            Section.Outline.Position = Section.Position
            Section.Outline.Size = Section.Size
            Section.Background.Position = Section.Position + NewVector2(1, 1)
            Section.Background.Size = Section.Size - NewVector2(2, 2)
            Section.Title.Position = Section.Position + NewVector2(10, 7)

            local ControlY = Y + 29
            for _, Control in ipairs(Section.Controls) do
                RefreshControl(Control, X + 10, ControlY, ColumnWidth - 20)
                ControlY = ControlY + Control.Height
            end

            if Section.Side == "Right" then
                RightY = Y + Height + 10
            else
                LeftY = Y + Height + 10
            end
        end
    end

    if Window.KeybindPanel then
        local Panel = Window.KeybindPanel
        Panel.Outline.Position = Panel.Position - NewVector2(1, 1)
        Panel.Background.Position = Panel.Position
        Panel.Accent.Position = Panel.Position
        Panel.Title.Position = Panel.Position + NewVector2(9, 6)
    end
end

local function SetTab(Window, Tab)
    CloseDropdown(Window)
    ClosePicker(Window)
    Window.ActiveTab = Tab
    for _, Entry in ipairs(Window.Tabs) do
        local Visible = Window.Open and Entry == Tab
        Entry.Text.Color = Entry == Tab and Window.Theme.Text or Window.Theme.Dim
        Entry.Indicator.Visible = Window.Open and Entry == Tab
        for _, Section in ipairs(Entry.Sections) do
            SetSectionVisible(Section, Visible)
        end
    end
end

local function SetOpen(Window, Open)
    Window.Open = Open == true
    CloseDropdown(Window)
    ClosePicker(Window)

    Window.Outline.Visible = Window.Open
    Window.Background.Visible = Window.Open
    Window.Sidebar.Visible = Window.Open
    Window.Divider.Visible = Window.Open
    Window.Accent.Visible = Window.Open
    Window.Title.Visible = Window.Open
    Window.Subtitle.Visible = Window.Open

    for _, Corner in pairs(Window.Corners) do
        Corner.H.Visible = Window.Open
        Corner.V.Visible = Window.Open
    end

    for _, Tab in ipairs(Window.Tabs) do
        Tab.Text.Visible = Window.Open
        Tab.Indicator.Visible = Window.Open and Tab == Window.ActiveTab
        for _, Section in ipairs(Tab.Sections) do
            SetSectionVisible(Section, Window.Open and Tab == Window.ActiveTab)
        end
    end
end

local function RegisterControl(Section, Control)
    Control.Section = Section
    Control.Window = Section.Window
    Control.Tab = Section.Tab
    Control.Flag = Control.Flag or (Section.Tab.Name .. "/" .. Section.Name .. "/" .. Control.Name)
    Control.Drawings = Control.Drawings or {}
    Control.Height = Control.Height or 24
    Control.Visible = false
    setmetatable(Control, {__index = ControlMethods})
    Insert(Section.Controls, Control)
    Insert(Section.Window.Controls, Control)
    Section.Window.ControlMap[Control.Flag] = Control
    RefreshLayout(Section.Window)
    SetTab(Section.Window, Section.Window.ActiveTab)
    return Control
end

function Library:SetTheme(Name)
    if type(Name) == "string" and Themes[Name] then
        self.Theme = Name
        for _, Window in ipairs(self.Windows) do
            Window.ThemeName = Name
            Window.Theme = Themes[Name]
            RefreshTheme(Window)
        end
    elseif type(Name) == "table" then
        Themes.Custom = Name
        self.Theme = "Custom"
        for _, Window in ipairs(self.Windows) do
            Window.ThemeName = "Custom"
            Window.Theme = Name
            RefreshTheme(Window)
        end
    end
    return self
end

function Library:SetBackgroundImage(Url, Opacity, Scale, Offset)
    self.Background = {
        Url = Url,
        Opacity = Opacity,
        Scale = Scale,
        Offset = Offset
    }
    return self
end

function Library:CreateWindow(Config)
    Config = type(Config) == "table" and Config or {}

    local Window = {
        TitleText = Config.title or Config.Title or "Balls1",
        SubtitleText = Config.subtitle or Config.Subtitle or "",
        Position = Config.position or Config.Position or NewVector2(180, 120),
        Size = Config.size or Config.Size or NewVector2(680, 520),
        MinimumSize = NewVector2(520, 360),
        MenuKey = GetKeyCode(Config.menuKey or Config.MenuKey or "F2"),
        ThemeName = self.Theme,
        Theme = Themes[self.Theme],
        Tabs = {},
        Controls = {},
        ControlMap = {},
        Binds = {},
        Active = true,
        Open = Config.startOpen ~= false,
        ShowKeybinds = true,
        ConfigName = SanitizeName(Config.configName or Config.ConfigName or "Balls1"),
        ConfigFolder = SanitizeName(Config.configFolder or Config.ConfigFolder or "Balls1Configs"),
        Opacity = Clamp((tonumber(Config.opacity) or 96) / 100, 0.2, 1),
        Capturing = nil,
        OpenDropdown = nil,
        OpenPicker = nil,
        Dragging = false,
        Resizing = nil,
        ActiveSlider = nil,
        KeyHeld = false,
        LastMouse = false,
        PositionStart = nil,
        MouseStart = nil,
        SizeStart = nil,
        KeybindPanel = nil
    }

    setmetatable(Window, {__index = WindowMethods})

    Window.Outline = NewDrawing("Square", {Filled = true, Corner = 10, Transparency = 0.35})
    Window.Background = NewDrawing("Square", {Filled = true, Corner = 9, Transparency = Window.Opacity})
    Window.Sidebar = NewDrawing("Square", {Filled = true, Corner = 9, Transparency = 0.98})
    Window.Divider = NewDrawing("Square", {Filled = true, Transparency = 0.35})
    Window.Accent = NewDrawing("Square", {Filled = true, Transparency = 1})
    Window.Title = NewDrawing("Text", {Text = Window.TitleText, Size = 16, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})
    Window.Subtitle = NewDrawing("Text", {Text = Window.SubtitleText, Size = 11, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})

    Window.Corners = {}
    for _, Name in ipairs({"TL", "TR", "BL", "BR"}) do
        Window.Corners[Name] = {
            H = NewDrawing("Square", {Filled = true, Transparency = 0.28}),
            V = NewDrawing("Square", {Filled = true, Transparency = 0.28})
        }
        Window.Corners[Name].H.Color = Window.Theme.Accent
        Window.Corners[Name].V.Color = Window.Theme.Accent
    end

    Insert(self.Windows, Window)
    RefreshTheme(Window)
    RefreshLayout(Window)
    SetOpen(Window, Window.Open)

    Spawn(function()
        Window:Run()
    end)

    return Window
end

function WindowMethods:Tab(Name, Icon)
    for _, Tab in ipairs(self.Tabs) do
        if Tab.Name == Name then return Tab end
    end

    local Tab = {
        Window = self,
        Name = tostring(Name or "Tab"),
        Icon = Icon,
        Sections = {}
    }
    setmetatable(Tab, {__index = TabMethods})

    Tab.Text = NewDrawing("Text", {
        Text = Tab.Name,
        Size = 14,
        Font = Drawing.Fonts.System,
        Outline = true,
        Transparency = 1
    })
    Tab.Indicator = NewDrawing("Square", {Filled = true, Transparency = 1})

    Insert(self.Tabs, Tab)
    if not self.ActiveTab then self.ActiveTab = Tab end
    RefreshLayout(self)
    RefreshTheme(self)
    SetTab(self, self.ActiveTab)
    return Tab
end

function WindowMethods:GetTab(Name)
    for _, Tab in ipairs(self.Tabs) do
        if Tab.Name == Name then return Tab end
    end
    return nil
end

function WindowMethods:SetOpen(State)
    SetOpen(self, State)
    return self
end

function WindowMethods:Toggle()
    SetOpen(self, not self.Open)
    return self.Open
end

function WindowMethods:SetMenuKey(Key)
    self.MenuKey = GetKeyCode(Key)
    return self
end

function WindowMethods:SetTheme(Name)
    if Themes[Name] then
        self.ThemeName = Name
        self.Theme = Themes[Name]
        RefreshTheme(self)
    end
    return self
end

function WindowMethods:GetValue(Flag)
    local Control = self.ControlMap[Flag]
    return Control and Control:GetValue() or nil
end

function WindowMethods:SetValue(Flag, Value)
    local Control = self.ControlMap[Flag]
    if Control then Control:SetValue(Value) end
    return self
end

function WindowMethods:GetConfigPath(Name)
    Name = SanitizeName(Name or self.ConfigName)
    local Folder = self.ConfigFolder

    if type(isfolder) == "function" then
        if isfolder(Folder) then return Folder .. "/" .. Name .. ".json" end
        if type(makefolder) == "function" then
            makefolder(Folder)
            if isfolder(Folder) then return Folder .. "/" .. Name .. ".json" end
        end
    end

    return Folder .. "_" .. Name .. ".json"
end

function WindowMethods:SaveConfig(Name)
    if type(writefile) ~= "function" then return false end

    local Data = {}
    for _, Control in ipairs(self.Controls) do
        local Value = Control:GetValue()
        if Control.Type == "Colorpicker" then
            Data[Control.Flag] = {Kind = "Color", R = Value.R, G = Value.G, B = Value.B}
        elseif Control.Type ~= "Button" and Control.Type ~= "Label" then
            Data[Control.Flag] = Value
        end

        if Control.Bind then
            Data[Control.Flag .. "/Bind"] = {
                Kind = "Bind",
                Key = Control.Bind.Key,
                Mode = Control.Bind.Mode
            }
        end

        if Control.AttachedColor then
            local Color = Control.AttachedColor.Value
            Data[Control.Flag .. "/Color"] = {Kind = "Color", R = Color.R, G = Color.G, B = Color.B}
        end
    end

    writefile(self:GetConfigPath(Name), HttpService:JSONEncode(Data))
    return true
end

function WindowMethods:LoadConfig(Name)
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return false end
    local Path = self:GetConfigPath(Name)
    if not isfile(Path) then return false end

    local Data = HttpService:JSONDecode(readfile(Path))
    if type(Data) ~= "table" then return false end

    for _, Control in ipairs(self.Controls) do
        local Value = Data[Control.Flag]
        if Value ~= nil and Control.Type ~= "Button" and Control.Type ~= "Label" then
            if type(Value) == "table" and Value.Kind == "Color" then
                Control:SetValue(NewColor3(Value.R or 0, Value.G or 0, Value.B or 0))
            else
                Control:SetValue(Value)
            end
        end

        if Control.Bind then
            local Bind = Data[Control.Flag .. "/Bind"]
            if type(Bind) == "table" and Bind.Kind == "Bind" then
                Control.Bind:SetKey(Bind.Key or 0)
                Control.Bind:SetMode(Bind.Mode or "Toggle")
            end
        end

        if Control.AttachedColor then
            local Color = Data[Control.Flag .. "/Color"]
            if type(Color) == "table" and Color.Kind == "Color" then
                Control.AttachedColor:SetValue(NewColor3(Color.R or 0, Color.G or 0, Color.B or 0))
            end
        end
    end

    RefreshLayout(self)
    return true
end

function WindowMethods:AddSettingsTab(Icon)
    local Existing = self:GetTab("Settings")
    if Existing then return Existing end

    local Settings = self:Tab("Settings", Icon)
    local Menu = Settings:Section("Menu", "Left", "")
    local Appearance = Settings:Section("Appearance", "Right", "")
    local Configs = Settings:Section("Configs", "Left", "")

    Menu:Toggle("Keybind List", true, function(Value)
        self.ShowKeybinds = Value
    end)

    Menu:Keybind("Menu Key", self.MenuKey, "Toggle", function(Key)
        self.MenuKey = Key
    end)

    Appearance:Dropdown("Theme", {self.ThemeName}, ThemeNames, false, function(Value)
        self:SetTheme(Value)
    end)

    Appearance:Colorpicker("Accent", self.Theme.Accent, function(Color)
        local Current = self.Theme
        local Custom = {
            Background = Current.Background,
            Outline = Current.Outline,
            Inline = Current.Inline,
            Accent = Color,
            Sidebar = Current.Sidebar,
            Group = Current.Group,
            Text = Current.Text,
            Dim = Current.Dim,
            Control = Current.Control,
            Hover = Current.Hover
        }
        self.ThemeName = "Custom"
        self.Theme = Custom
        RefreshTheme(self)
    end)

    Configs:Button("Save Config", function()
        self:SaveConfig(self.ConfigName)
    end)

    Configs:Button("Load Config", function()
        self:LoadConfig(self.ConfigName)
    end)

    Configs:Button("Unload", function()
        self:Unload()
    end)

    return Settings
end

function WindowMethods:Unload()
    self.Active = false
    CloseDropdown(self)
    ClosePicker(self)

    for _, Object in ipairs(self:GetDrawings()) do
        RemoveDrawing(Object)
    end

    for Index = #Library.Windows, 1, -1 do
        if Library.Windows[Index] == self then
            Remove(Library.Windows, Index)
            break
        end
    end
end

function WindowMethods:GetDrawings()
    local List = {
        self.Outline, self.Background, self.Sidebar, self.Divider, self.Accent, self.Title, self.Subtitle
    }

    for _, Corner in pairs(self.Corners) do
        Insert(List, Corner.H)
        Insert(List, Corner.V)
    end

    for _, Tab in ipairs(self.Tabs) do
        Insert(List, Tab.Text)
        Insert(List, Tab.Indicator)
        for _, Section in ipairs(Tab.Sections) do
            Insert(List, Section.Outline)
            Insert(List, Section.Background)
            Insert(List, Section.Title)
            for _, Control in ipairs(Section.Controls) do
                for _, Object in pairs(Control.Drawings) do
                    if Object then Insert(List, Object) end
                end
                if Control.Bind then
                    Insert(List, Control.Bind.Inline)
                    Insert(List, Control.Bind.Box)
                    Insert(List, Control.Bind.Text)
                end
                if Control.AttachedColor then
                    Insert(List, Control.AttachedColor.Outline)
                    Insert(List, Control.AttachedColor.Box)
                end
            end
        end
    end

    if self.KeybindPanel then
        Insert(List, self.KeybindPanel.Outline)
        Insert(List, self.KeybindPanel.Background)
        Insert(List, self.KeybindPanel.Accent)
        Insert(List, self.KeybindPanel.Title)
        for _, Row in ipairs(self.KeybindPanel.Rows) do
            Insert(List, Row.Name)
            Insert(List, Row.State)
        end
    end

    return List
end

function TabMethods:Section(Name, Side, Icon)
    local Section = {
        Window = self.Window,
        Tab = self,
        Name = tostring(Name or "Section"),
        Side = Lower(tostring(Side or "Left")) == "right" and "Right" or "Left",
        Icon = Icon,
        Controls = {},
        Visible = false
    }
    setmetatable(Section, {__index = SectionMethods})

    Section.Outline = NewDrawing("Square", {Filled = true, Corner = 8, Transparency = 0.35})
    Section.Background = NewDrawing("Square", {Filled = true, Corner = 7, Transparency = 0.96})
    Section.Title = NewDrawing("Text", {Text = Section.Name, Size = 13, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})

    Insert(self.Sections, Section)
    RefreshLayout(self.Window)
    RefreshTheme(self.Window)
    SetTab(self.Window, self.Window.ActiveTab)
    return Section
end

function SectionMethods:Toggle(Name, Default, Callback)
    local Control = {
        Type = "Toggle",
        Name = tostring(Name or "Toggle"),
        Value = Default == true,
        Callback = type(Callback) == "function" and Callback or nil,
        Height = 24
    }

    Control.Drawings = {
        Outline = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.4}),
        Box = NewDrawing("Square", {Filled = true, Corner = 3, Transparency = 1}),
        Text = NewDrawing("Text", {Text = Control.Name, Size = 13, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})
    }

    return RegisterControl(self, Control)
end

function SectionMethods:Slider(Name, Default, Step, Minimum, Maximum, Suffix, Callback)
    Minimum = tonumber(Minimum) or 0
    Maximum = tonumber(Maximum) or 100
    if Maximum < Minimum then Minimum, Maximum = Maximum, Minimum end

    local Control = {
        Type = "Slider",
        Name = tostring(Name or "Slider"),
        Min = Minimum,
        Max = Maximum,
        Step = tonumber(Step) or 1,
        Suffix = tostring(Suffix or ""),
        Value = Clamp(tonumber(Default) or Minimum, Minimum, Maximum),
        Callback = type(Callback) == "function" and Callback or nil,
        Height = 34
    }

    Control.Value = Clamp(RoundStep(Control.Value, Control.Step), Control.Min, Control.Max)
    Control.Drawings = {
        Text = NewDrawing("Text", {Text = Control.Name, Size = 12, Font = Drawing.Fonts.System, Outline = true, Transparency = 1}),
        Value = NewDrawing("Text", {Text = "", Size = 12, Font = Drawing.Fonts.System, Outline = true, Center = false, Transparency = 1}),
        Outline = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.35}),
        Bar = NewDrawing("Square", {Filled = true, Corner = 3, Transparency = 0.95}),
        Fill = NewDrawing("Square", {Filled = true, Corner = 3, Transparency = 1}),
        Thumb = NewDrawing("Circle", {Filled = true, Radius = 3, Transparency = 1})
    }
    Control.Drawings.Value.Center = false

    return RegisterControl(self, Control)
end

function SectionMethods:Dropdown(Name, Default, Options, Multi, Callback)
    Options = type(Options) == "table" and Options or {}
    local Control = {
        Type = "Dropdown",
        Name = tostring(Name or "Dropdown"),
        Options = Options,
        Multi = Multi == true,
        Callback = type(Callback) == "function" and Callback or nil,
        Height = 30,
        Popup = {},
        PopupBounds = {}
    }

    if Control.Multi then
        Control.Value = {}
        if type(Default) == "table" then
            for _, Value in ipairs(Default) do Control.Value[tostring(Value)] = true end
        end
    else
        if type(Default) == "table" then Default = Default[1] end
        local Found = false
        for _, Option in ipairs(Options) do
            if Option == Default then Found = true break end
        end
        Control.Value = Found and Default or Options[1]
    end

    Control.Drawings = {
        Outline = NewDrawing("Square", {Filled = true, Corner = 5, Transparency = 0.35}),
        Box = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.96}),
        Text = NewDrawing("Text", {Text = "", Size = 12, Font = Drawing.Fonts.System, Outline = true, Transparency = 1}),
        Arrow = NewDrawing("Text", {Text = "+", Size = 12, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})
    }

    return RegisterControl(self, Control)
end

function SectionMethods:Colorpicker(Name, Default, Callback)
    local Control = {
        Type = "Colorpicker",
        Name = tostring(Name or "Color"),
        Value = typeof(Default) == "Color3" and Default or FromRGB(255, 255, 255),
        Callback = type(Callback) == "function" and Callback or nil,
        Height = 25,
        Popup = {}
    }

    Control.Drawings = {
        Text = NewDrawing("Text", {Text = Control.Name, Size = 12, Font = Drawing.Fonts.System, Outline = true, Transparency = 1}),
        Outline = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.4}),
        Box = NewDrawing("Square", {Filled = true, Corner = 3, Transparency = 1})
    }

    return RegisterControl(self, Control)
end

function SectionMethods:Button(Name, Callback)
    local Control = {
        Type = "Button",
        Name = tostring(Name or "Button"),
        Callback = type(Callback) == "function" and Callback or nil,
        Height = 30
    }

    Control.Drawings = {
        Outline = NewDrawing("Square", {Filled = true, Corner = 5, Transparency = 0.35}),
        Box = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.96}),
        Text = NewDrawing("Text", {Text = Control.Name, Size = 12, Font = Drawing.Fonts.System, Outline = true, Center = true, Transparency = 1})
    }

    return RegisterControl(self, Control)
end

function SectionMethods:Label(Text)
    local Control = {
        Type = "Label",
        Name = tostring(Text or ""),
        Height = 22
    }

    Control.Drawings = {
        Text = NewDrawing("Text", {Text = Control.Name, Size = 12, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})
    }

    return RegisterControl(self, Control)
end

function SectionMethods:Keybind(Name, Default, Mode, Callback)
    local Control = {
        Type = "Keybind",
        Name = tostring(Name or "Keybind"),
        Value = GetKeyCode(Default),
        Mode = Mode or "Toggle",
        Callback = type(Callback) == "function" and Callback or nil,
        Height = 30
    }

    Control.Drawings = {
        Outline = NewDrawing("Square", {Filled = true, Corner = 5, Transparency = 0.35}),
        Box = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.96}),
        Text = NewDrawing("Text", {Text = "", Size = 12, Font = Drawing.Fonts.System, Outline = true, Center = true, Transparency = 1})
    }

    return RegisterControl(self, Control)
end

function ControlMethods:GetValue()
    if self.Type == "Dropdown" and self.Multi then
        local Values = {}
        for _, Option in ipairs(self.Options) do
            if self.Value[Option] then Insert(Values, Option) end
        end
        return Values
    end
    return self.Value
end

function ControlMethods:SetValue(Value, Silent)
    if self.Type == "Toggle" then
        Value = Value == true
        if self.Value == Value then return self end
        self.Value = Value
    elseif self.Type == "Slider" then
        Value = tonumber(Value) or self.Value
        Value = Clamp(RoundStep(Value, self.Step), self.Min, self.Max)
        if self.Value == Value then return self end
        self.Value = Value
    elseif self.Type == "Dropdown" then
        if self.Multi then
            local New = {}
            if type(Value) == "table" then
                for _, Entry in ipairs(Value) do New[tostring(Entry)] = true end
            end
            self.Value = New
        else
            if type(Value) == "table" then Value = Value[1] end
            local Found = false
            for _, Option in ipairs(self.Options) do
                if Option == Value then Found = true break end
            end
            if not Found then return self end
            if self.Value == Value then return self end
            self.Value = Value
        end
    elseif self.Type == "Colorpicker" then
        if typeof(Value) ~= "Color3" then return self end
        self.Value = Value
    elseif self.Type == "Keybind" then
        Value = GetKeyCode(Value)
        if self.Value == Value then return self end
        self.Value = Value
    else
        return self
    end

    RefreshLayout(self.Window)
    RefreshTheme(self.Window)
    if not Silent and self.Callback then self.Callback(self:GetValue()) end
    return self
end

function ControlMethods:FormatValue()
    if self.Type ~= "Slider" then return tostring(self:GetValue()) end

    local Step = self.Step
    local Decimals = 0
    if Step < 1 then
        local Text = tostring(Step)
        local Dot = Find(Text, ".", 1, true)
        if Dot then Decimals = Min(#Text - Dot, 4) end
    end

    if Decimals > 0 then
        return Format("%." .. tostring(Decimals) .. "f%s", self.Value, self.Suffix)
    end
    return tostring(Floor(self.Value + 0.5)) .. self.Suffix
end

function ControlMethods:AddKeybind(Default, Mode)
    if self.Bind then return self.Bind end

    local Bind = {
        Control = self,
        Window = self.Window,
        Key = GetKeyCode(Default),
        Mode = Mode == "Hold" and "Hold" or Mode == "Always" and "Always" or "Toggle",
        Held = false
    }
    setmetatable(Bind, {__index = BindMethods})

    Bind.Inline = NewDrawing("Square", {Filled = true, Corner = 5, Transparency = 0.35})
    Bind.Box = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.96})
    Bind.Text = NewDrawing("Text", {Text = "", Size = 11, Font = Drawing.Fonts.System, Outline = true, Center = true, Transparency = 1})

    self.Bind = Bind
    Insert(self.Window.Binds, Bind)
    RefreshLayout(self.Window)
    RefreshTheme(self.Window)
    SetTab(self.Window, self.Window.ActiveTab)
    return Bind
end

function ControlMethods:AddColorpicker(Name, Default, Callback)
    if self.AttachedColor then return self.AttachedColor end

    local Color = {
        Control = self,
        Window = self.Window,
        Name = tostring(Name or "Color"),
        Value = typeof(Default) == "Color3" and Default or FromRGB(255, 255, 255),
        Callback = type(Callback) == "function" and Callback or nil,
        Popup = {}
    }

    Color.Outline = NewDrawing("Square", {Filled = true, Corner = 4, Transparency = 0.4})
    Color.Box = NewDrawing("Square", {Filled = true, Corner = 3, Transparency = 1})

    function Color:SetValue(Value, Silent)
        if typeof(Value) ~= "Color3" then return self end
        self.Value = Value
        self.Box.Color = Value
        if not Silent and self.Callback then self.Callback(Value) end
        return self
    end

    function Color:GetValue()
        return self.Value
    end

    self.AttachedColor = Color
    RefreshLayout(self.Window)
    RefreshTheme(self.Window)
    SetTab(self.Window, self.Window.ActiveTab)
    return Color
end

function BindMethods:SetKey(Key)
    self.Key = GetKeyCode(Key)
    self.Held = false
    RefreshLayout(self.Window)
    return self
end

function BindMethods:GetKey()
    return self.Key
end

function BindMethods:SetMode(Mode)
    if Mode == "Hold" or Mode == "Always" then
        self.Mode = Mode
    else
        self.Mode = "Toggle"
    end
    return self
end

function BindMethods:GetMode()
    return self.Mode
end

local function CreateDropdownPopup(Control)
    local Window = Control.Window
    CloseDropdown(Window)
    ClosePicker(Window)
    Window.OpenDropdown = Control

    local X = Control.HitPosition.X
    local Y = Control.HitPosition.Y + Control.HitSize.Y + 3
    local Width = Control.HitSize.X
    local Height = #Control.Options * 21 + 2
    local Theme = Window.Theme

    local Outline = NewDrawing("Square", {Position = NewVector2(X, Y), Size = NewVector2(Width, Height), Filled = true, Corner = 6, Color = Theme.Outline, Transparency = 0.55})
    local Background = NewDrawing("Square", {Position = NewVector2(X + 1, Y + 1), Size = NewVector2(Width - 2, Height - 2), Filled = true, Corner = 5, Color = Theme.Group, Transparency = 0.99})
    Insert(Control.Popup, Outline)
    Insert(Control.Popup, Background)

    Control.PopupBounds = {}
    for Index, Option in ipairs(Control.Options) do
        local RowY = Y + 2 + (Index - 1) * 21
        local Row = NewDrawing("Square", {Position = NewVector2(X + 3, RowY), Size = NewVector2(Width - 6, 19), Filled = true, Corner = 4, Color = Theme.Group, Transparency = 1})
        local Text = NewDrawing("Text", {Position = NewVector2(X + 10, RowY + 3), Text = tostring(Option), Size = 12, Font = Drawing.Fonts.System, Outline = true, Color = Theme.Dim, Transparency = 1})
        local Mark = NewDrawing("Square", {Position = NewVector2(X + 4, RowY + 4), Size = NewVector2(2, 11), Filled = true, Color = Theme.Accent, Transparency = 0})
        Insert(Control.Popup, Row)
        Insert(Control.Popup, Text)
        Insert(Control.Popup, Mark)
        Insert(Control.PopupBounds, {Option = Option, Position = NewVector2(X + 3, RowY), Size = NewVector2(Width - 6, 19), Row = Row, Text = Text, Mark = Mark})
    end
end

local function CreatePickerPopup(Picker, HitPosition, HitSize)
    local Window = Picker.Window
    CloseDropdown(Window)
    ClosePicker(Window)
    Window.OpenPicker = Picker

    local Color = Picker.Value
    local H, S, V = RgbToHsv(Color)
    Picker.Hue = H
    Picker.Saturation = S
    Picker.ValueLevel = V
    Picker.Popup = {}

    local X = HitPosition.X + HitSize.X - 154
    local Y = HitPosition.Y + HitSize.Y + 4
    local Theme = Window.Theme
    local Width = 154
    local Height = 142

    local Outline = NewDrawing("Square", {Position = NewVector2(X, Y), Size = NewVector2(Width, Height), Filled = true, Corner = 7, Color = Theme.Outline, Transparency = 0.6})
    local Background = NewDrawing("Square", {Position = NewVector2(X + 1, Y + 1), Size = NewVector2(Width - 2, Height - 2), Filled = true, Corner = 6, Color = Theme.Group, Transparency = 0.99})
    Insert(Picker.Popup, Outline)
    Insert(Picker.Popup, Background)

    Picker.PopupPosition = NewVector2(X, Y)
    Picker.PopupSize = NewVector2(Width, Height)
    Picker.SvPosition = NewVector2(X + 8, Y + 8)
    Picker.SvSize = NewVector2(110, 110)
    Picker.HuePosition = NewVector2(X + 126, Y + 8)
    Picker.HueSize = NewVector2(12, 110)

    local Grid = 11
    local Cell = Picker.SvSize.X / Grid
    Picker.SvCells = {}
    for Row = 0, Grid - 1 do
        for Column = 0, Grid - 1 do
            local Sat = Column / (Grid - 1)
            local Val = 1 - Row / (Grid - 1)
            local Square = NewDrawing("Square", {
                Position = Picker.SvPosition + NewVector2(Column * Cell, Row * Cell),
                Size = NewVector2(math.ceil(Cell) + 1, math.ceil(Cell) + 1),
                Filled = true,
                Color = HsvToRgb(Picker.Hue, Sat, Val),
                Transparency = 1
            })
            Insert(Picker.SvCells, {Object = Square, Saturation = Sat, Value = Val})
            Insert(Picker.Popup, Square)
        end
    end

    local HueRows = 24
    local HueHeight = Picker.HueSize.Y / HueRows
    for Index = 0, HueRows - 1 do
        local Hue = 1 - Index / (HueRows - 1)
        local Square = NewDrawing("Square", {
            Position = Picker.HuePosition + NewVector2(0, Index * HueHeight),
            Size = NewVector2(Picker.HueSize.X, math.ceil(HueHeight) + 1),
            Filled = true,
            Color = HsvToRgb(Hue, 1, 1),
            Transparency = 1
        })
        Insert(Picker.Popup, Square)
    end

    Picker.SvCursor = NewDrawing("Circle", {Position = Picker.SvPosition + NewVector2(Picker.Saturation * Picker.SvSize.X, (1 - Picker.ValueLevel) * Picker.SvSize.Y), Radius = 4, Filled = false, Thickness = 1.5, Color = Theme.Text, Transparency = 1})
    Picker.HueCursor = NewDrawing("Square", {Position = Picker.HuePosition + NewVector2(-2, (1 - Picker.Hue) * Picker.HueSize.Y - 1), Size = NewVector2(16, 3), Filled = false, Thickness = 1, Color = Theme.Text, Transparency = 1})
    Picker.Hex = NewDrawing("Text", {Position = NewVector2(X + 8, Y + 122), Text = ColorToHex(Picker.Value), Size = 11, Font = Drawing.Fonts.System, Outline = true, Color = Theme.Dim, Transparency = 1})
    Insert(Picker.Popup, Picker.SvCursor)
    Insert(Picker.Popup, Picker.HueCursor)
    Insert(Picker.Popup, Picker.Hex)
end

local function UpdatePicker(Picker, MousePosition)
    local Changed = false

    if PointIn(Picker.SvPosition, Picker.SvSize, MousePosition) then
        Picker.Saturation = Clamp((MousePosition.X - Picker.SvPosition.X) / Picker.SvSize.X, 0, 1)
        Picker.ValueLevel = 1 - Clamp((MousePosition.Y - Picker.SvPosition.Y) / Picker.SvSize.Y, 0, 1)
        Changed = true
    elseif PointIn(Picker.HuePosition - NewVector2(3, 0), Picker.HueSize + NewVector2(6, 0), MousePosition) then
        Picker.Hue = 1 - Clamp((MousePosition.Y - Picker.HuePosition.Y) / Picker.HueSize.Y, 0, 1)
        Changed = true
    end

    if not Changed then return end

    if Picker.SvCells then
        for _, Cell in ipairs(Picker.SvCells) do
            Cell.Object.Color = HsvToRgb(Picker.Hue, Cell.Saturation, Cell.Value)
        end
    end

    local Color = HsvToRgb(Picker.Hue, Picker.Saturation, Picker.ValueLevel)
    Picker.Value = Color
    Picker.SvCursor.Position = Picker.SvPosition + NewVector2(Picker.Saturation * Picker.SvSize.X, (1 - Picker.ValueLevel) * Picker.SvSize.Y)
    Picker.HueCursor.Position = Picker.HuePosition + NewVector2(-2, (1 - Picker.Hue) * Picker.HueSize.Y - 1)
    Picker.Hex.Text = ColorToHex(Color)

    if Picker.Type == "Colorpicker" then
        Picker.Drawings.Box.Color = Color
        if Picker.Callback then Picker.Callback(Color) end
    else
        Picker.Box.Color = Color
        if Picker.Callback then Picker.Callback(Color) end
    end
end

local function RefreshDropdownPopup(Control, MousePosition)
    local Theme = Control.Window.Theme
    for _, Entry in ipairs(Control.PopupBounds) do
        local Hover = PointIn(Entry.Position, Entry.Size, MousePosition)
        Entry.Row.Color = Hover and Theme.Hover or Theme.Group
        Entry.Text.Color = Hover and Theme.Text or Theme.Dim
        local Selected = Control.Multi and Control.Value[Entry.Option] == true or Control.Value == Entry.Option
        Entry.Mark.Transparency = Selected and 1 or 0
    end
end

local function EnsureKeybindPanel(Window)
    if Window.KeybindPanel then return end

    local Panel = {
        Position = NewVector2(35, 380),
        Rows = {},
        Dragging = false
    }

    Panel.Outline = NewDrawing("Square", {Filled = true, Corner = 6, Transparency = 0.45})
    Panel.Background = NewDrawing("Square", {Filled = true, Corner = 5, Transparency = 0.96})
    Panel.Accent = NewDrawing("Square", {Filled = true, Transparency = 1})
    Panel.Title = NewDrawing("Text", {Text = "keybinds", Size = 12, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})
    Window.KeybindPanel = Panel
    RefreshTheme(Window)
    RefreshLayout(Window)
end

local function RefreshKeybindPanel(Window)
    EnsureKeybindPanel(Window)
    local Panel = Window.KeybindPanel
    local VisibleBinds = {}

    for _, Bind in ipairs(Window.Binds) do
        if Bind.Key > 0 then Insert(VisibleBinds, Bind) end
    end

    while #Panel.Rows < #VisibleBinds do
        local Row = {
            Name = NewDrawing("Text", {Text = "", Size = 11, Font = Drawing.Fonts.System, Outline = true, Transparency = 1}),
            State = NewDrawing("Text", {Text = "", Size = 11, Font = Drawing.Fonts.System, Outline = true, Transparency = 1})
        }
        Insert(Panel.Rows, Row)
    end

    local Height = 25 + #VisibleBinds * 18
    local Width = 180
    Panel.Outline.Size = NewVector2(Width + 2, Height + 2)
    Panel.Background.Size = NewVector2(Width, Height)
    Panel.Accent.Size = NewVector2(Width, 2)

    local Show = Window.ShowKeybinds
    Panel.Outline.Visible = Show
    Panel.Background.Visible = Show
    Panel.Accent.Visible = Show
    Panel.Title.Visible = Show

    for Index, Row in ipairs(Panel.Rows) do
        local Bind = VisibleBinds[Index]
        local Visible = Show and Bind ~= nil
        Row.Name.Visible = Visible
        Row.State.Visible = Visible

        if Bind then
            local Control = Bind.Control
            Row.Name.Text = "[" .. GetKeyName(Bind.Key) .. "] " .. Control.Name
            Row.Name.Position = Panel.Position + NewVector2(8, 22 + (Index - 1) * 18)
            Row.Name.Color = Window.Theme.Text
            Row.State.Position = Panel.Position + NewVector2(137, 22 + (Index - 1) * 18)
            Row.State.Text = Bind.Mode == "Hold" and "hold" or Bind.Mode == "Always" and "always" or Control.Value and "on" or "off"
            Row.State.Color = Control.Value and Window.Theme.Accent or Window.Theme.Dim
        end
    end
end

local function ProcessBind(Window, Bind)
    local Control = Bind.Control

    if Bind.Mode == "Always" then
        if Control.Type == "Toggle" and not Control.Value then Control:SetValue(true) end
        return
    end

    if Bind.Key <= 0 then
        Bind.Held = false
        return
    end

    local Pressed = iskeypressed(Bind.Key)

    if Bind.Mode == "Hold" then
        if Control.Type == "Toggle" and Control.Value ~= Pressed then
            Control:SetValue(Pressed)
        end
        Bind.Held = Pressed
        return
    end

    if Pressed and not Bind.Held then
        if Control.Type == "Toggle" then Control:SetValue(not Control.Value) end
        Bind.Held = true
    elseif not Pressed then
        Bind.Held = false
    end
end

function WindowMethods:Run()
    EnsureKeybindPanel(self)

    while self.Active and _G.Balls1Token == Token do
        Wait()

        local MousePosition = NewVector2(Mouse.X, Mouse.Y)
        local MousePressed = ismouse1pressed()
        local MouseDown = MousePressed and not self.LastMouse

        RefreshKeybindPanel(self)

        if self.Capturing then
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
                    break
                end
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
                ProcessBind(self, Bind)
            end
        end

        if self.OpenDropdown then RefreshDropdownPopup(self.OpenDropdown, MousePosition) end

        if MousePressed and self.OpenPicker then
            UpdatePicker(self.OpenPicker, MousePosition)
        end

        if MouseDown then
            local Consumed = false

            if self.ShowKeybinds and self.KeybindPanel then
                local Panel = self.KeybindPanel
                if PointIn(Panel.Position, NewVector2(180, 22), MousePosition) then
                    Panel.Dragging = true
                    Panel.MouseStart = MousePosition
                    Panel.PositionStart = Panel.Position
                    Consumed = true
                end
            end

            if not Consumed and self.OpenDropdown then
                local Dropdown = self.OpenDropdown
                for _, Entry in ipairs(Dropdown.PopupBounds) do
                    if PointIn(Entry.Position, Entry.Size, MousePosition) then
                        if Dropdown.Multi then
                            Dropdown.Value[Entry.Option] = not Dropdown.Value[Entry.Option]
                            if Dropdown.Callback then Dropdown.Callback(Dropdown:GetValue()) end
                            RefreshDropdownPopup(Dropdown, MousePosition)
                            RefreshLayout(self)
                        else
                            Dropdown.Value = Entry.Option
                            if Dropdown.Callback then Dropdown.Callback(Entry.Option) end
                            CloseDropdown(self)
                            RefreshLayout(self)
                        end
                        Consumed = true
                        break
                    end
                end

                if not Consumed then
                    local Popup = Dropdown.Popup[1]
                    if not Popup or not PointIn(Popup.Position, Popup.Size, MousePosition) then
                        CloseDropdown(self)
                    end
                end
            end

            if not Consumed and self.OpenPicker then
                local Picker = self.OpenPicker
                if PointIn(Picker.PopupPosition, Picker.PopupSize, MousePosition) then
                    Consumed = true
                else
                    ClosePicker(self)
                end
            end

            if self.Open and not Consumed then
                local Resize = {
                    TL = {self.Position - NewVector2(5, 5), NewVector2(20, 20)},
                    TR = {self.Position + NewVector2(self.Size.X - 15, -5), NewVector2(20, 20)},
                    BL = {self.Position + NewVector2(-5, self.Size.Y - 15), NewVector2(20, 20)},
                    BR = {self.Position + NewVector2(self.Size.X - 15, self.Size.Y - 15), NewVector2(20, 20)}
                }

                for Name, Bounds in pairs(Resize) do
                    if PointIn(Bounds[1], Bounds[2], MousePosition) then
                        self.Resizing = Name
                        self.MouseStart = MousePosition
                        self.PositionStart = self.Position
                        self.SizeStart = self.Size
                        Consumed = true
                        break
                    end
                end

                if not Consumed and PointIn(self.Position, NewVector2(self.Size.X, 38), MousePosition) then
                    self.Dragging = true
                    self.MouseStart = MousePosition
                    self.PositionStart = self.Position
                    Consumed = true
                end

                if not Consumed then
                    for _, Tab in ipairs(self.Tabs) do
                        if PointIn(Tab.HitPosition, Tab.HitSize, MousePosition) then
                            SetTab(self, Tab)
                            Consumed = true
                            break
                        end
                    end
                end

                if not Consumed and self.ActiveTab then
                    for _, Section in ipairs(self.ActiveTab.Sections) do
                        for _, Control in ipairs(Section.Controls) do
                            if Control.Visible then
                                if Control.Bind and PointIn(Control.Bind.HitPosition, Control.Bind.HitSize, MousePosition) then
                                    self.Capturing = Control.Bind
                                    Consumed = true
                                    break
                                end

                                if Control.AttachedColor and PointIn(Control.AttachedColor.HitPosition, Control.AttachedColor.HitSize, MousePosition) then
                                    Control.AttachedColor.Type = "AttachedColor"
                                    CreatePickerPopup(Control.AttachedColor, Control.AttachedColor.HitPosition, Control.AttachedColor.HitSize)
                                    Consumed = true
                                    break
                                end

                                if PointIn(Control.HitPosition, Control.HitSize, MousePosition) then
                                    if Control.Type == "Toggle" then
                                        Control:SetValue(not Control.Value)
                                    elseif Control.Type == "Slider" then
                                        self.ActiveSlider = Control
                                    elseif Control.Type == "Dropdown" then
                                        if self.OpenDropdown == Control then CloseDropdown(self) else CreateDropdownPopup(Control) end
                                    elseif Control.Type == "Colorpicker" then
                                        CreatePickerPopup(Control, Control.HitPosition, Control.HitSize)
                                    elseif Control.Type == "Button" then
                                        if Control.Callback then Control.Callback() end
                                    elseif Control.Type == "Keybind" then
                                        self.Capturing = Control
                                    end
                                    Consumed = true
                                    break
                                end
                            end
                        end
                        if Consumed then break end
                    end
                end
            end
        end

        if MousePressed and self.ActiveSlider then
            local Slider = self.ActiveSlider
            local Percent = Clamp((MousePosition.X - Slider.HitPosition.X) / Max(Slider.HitSize.X, 1), 0, 1)
            local Value = Slider.Min + (Slider.Max - Slider.Min) * Percent
            Slider:SetValue(Value)
        end

        if not MousePressed then
            self.ActiveSlider = nil
            self.Dragging = false
            self.Resizing = nil
            if self.KeybindPanel then self.KeybindPanel.Dragging = false end
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

            if Find(self.Resizing, "R") then Width = Max(self.MinimumSize.X, self.SizeStart.X + Delta.X) end
            if Find(self.Resizing, "B") then Height = Max(self.MinimumSize.Y, self.SizeStart.Y + Delta.Y) end
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

        if self.Open and self.ActiveTab then
            local Theme = self.Theme
            for _, Section in ipairs(self.ActiveTab.Sections) do
                for _, Control in ipairs(Section.Controls) do
                    if Control.Visible then
                        local Hover = PointIn(Control.HitPosition, Control.HitSize, MousePosition)
                        if Control.Type == "Toggle" then
                            local Target = Control.Value and Theme.Accent or Hover and Theme.Hover or Theme.Control
                            Control.Drawings.Box.Color = LerpColor(Control.Drawings.Box.Color, Target, 0.22)
                        elseif Control.Type == "Dropdown" or Control.Type == "Button" or Control.Type == "Keybind" then
                            local Target = Hover and Theme.Hover or Theme.Control
                            Control.Drawings.Box.Color = LerpColor(Control.Drawings.Box.Color, Target, 0.22)
                        end

                        if Control.Bind then
                            local BindHover = PointIn(Control.Bind.HitPosition, Control.Bind.HitSize, MousePosition)
                            Control.Bind.Box.Color = LerpColor(Control.Bind.Box.Color, BindHover and Theme.Hover or Theme.Control, 0.22)
                            Control.Bind.Text.Text = self.Capturing == Control.Bind and "[...]" or "[" .. GetKeyName(Control.Bind.Key) .. "]"
                        end
                    end
                end
            end
        end

        self.LastMouse = MousePressed
    end
end

_G.INSui = Library
_G.Balls1 = Library
return Library
