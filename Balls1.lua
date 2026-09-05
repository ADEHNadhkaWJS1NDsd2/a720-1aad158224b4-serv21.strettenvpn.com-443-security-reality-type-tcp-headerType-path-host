local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    for _ = 1, 200 do
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
        if LocalPlayer then break end
    end
end

if not LocalPlayer then return end

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

if _G.LibraryDrawings then
    for Index = #_G.LibraryDrawings, 1, -1 do
        local Object = _G.LibraryDrawings[Index]
        if Object then
            Object:Remove()
        end
    end
end

_G.LibraryToken = (_G.LibraryToken or 0) + 1
_G.LibraryDrawings = {}

local Token = _G.LibraryToken
local Drawings = _G.LibraryDrawings

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
    [3] = "BREAK",
    [4] = "MOUSE3",
    [5] = "MOUSE4",
    [6] = "MOUSE5",
    [8] = "BACKSPACE",
    [9] = "TAB",
    [12] = "CLEAR",
    [13] = "ENTER",
    [16] = "SHIFT",
    [17] = "CTRL",
    [18] = "ALT",
    [19] = "PAUSE",
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
    [41] = "SELECT",
    [42] = "PRINT",
    [43] = "EXECUTE",
    [44] = "PRTSC",
    [45] = "INSERT",
    [46] = "DELETE",
    [47] = "HELP",
    [91] = "LWIN",
    [92] = "RWIN",
    [93] = "MENU",
    [95] = "SLEEP",
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
    [108] = "NUMENTER",
    [109] = "NUM-",
    [110] = "NUM.",
    [111] = "NUM/",
    [144] = "NUMLOCK",
    [145] = "SCROLL",
    [160] = "LSHIFT",
    [161] = "RSHIFT",
    [162] = "LCTRL",
    [163] = "RCTRL",
    [164] = "LALT",
    [165] = "RALT",
    [166] = "BROWSERBACK",
    [167] = "BROWSERFORWARD",
    [168] = "REFRESH",
    [169] = "BROWSERSTOP",
    [170] = "SEARCH",
    [171] = "FAVORITES",
    [172] = "BROWSERHOME",
    [173] = "MUTE",
    [174] = "VOLDOWN",
    [175] = "VOLUP",
    [176] = "NEXTTRACK",
    [177] = "PREVTRACK",
    [178] = "MEDIASTOP",
    [179] = "PLAYPAUSE",
    [180] = "MAIL",
    [181] = "MEDIA",
    [182] = "APP1",
    [183] = "APP2",
    [186] = ";",
    [187] = "=",
    [188] = ",",
    [189] = "-",
    [190] = ".",
    [191] = "/",
    [192] = "`",
    [219] = "[",
    [220] = "\\",
    [221] = "]",
    [222] = "'",
    [226] = "\\<>"
}

local KeyCodes = {}

for Code, Name in pairs(KeyNames) do
    KeyCodes[Name] = Code
end

for Code = 48, 57 do
    local Name = string.char(Code)
    KeyCodes[Name] = Code
    KeyNames[Code] = Name
end

for Code = 65, 90 do
    local Name = string.char(Code)
    KeyCodes[Name] = Code
    KeyNames[Code] = Name
end

for Index = 1, 24 do
    local Code = 111 + Index
    local Name = "F" .. tostring(Index)
    KeyCodes[Name] = Code
    KeyNames[Code] = Name
end

local SymbolKeyCodes = {
    [":"] = 186,
    ["+"] = 187,
    ["<"] = 188,
    ["_"] = 189,
    [">"] = 190,
    ["?"] = 191,
    ["~"] = 192,
    ["{"] = 219,
    ["|"] = 220,
    ["}"] = 221,
    ['"'] = 222
}

for Name, Code in pairs(SymbolKeyCodes) do
    KeyCodes[Name] = Code
end

local ModifierKeys = {
    [16] = true,
    [17] = true,
    [18] = true,
    [160] = true,
    [161] = true,
    [162] = true,
    [163] = true,
    [164] = true,
    [165] = true
}

local function IsBindableKey(Code)
    return Type(Code) == "number"
        and Code >= 3
        and Code <= 255
        and Code ~= 7
end

local function GetKeyName(Code)
    if not IsBindableKey(Code) then return "-" end
    return KeyNames[Code] or ("VK" .. tostring(Code))
end

local function GetKeyCode(Value)
    if Type(Value) == "number" then
        local Code = Floor(Clamp(Value, 0, 255))
        return IsBindableKey(Code) and Code or 0
    end

    if Type(Value) ~= "string" then return 0 end

    local Name = Upper(Value)
    if Name == "NONE" or Name == "-" then return 0 end

    local Code = KeyCodes[Name] or KeyCodes[Value]
    return IsBindableKey(Code) and Code or 0
end

local function FindPressedBindKey()
    if iskeypressed(27) then
        return 0, true
    end

    for Code = 3, 255 do
        if IsBindableKey(Code) and not ModifierKeys[Code] and iskeypressed(Code) then
            return Code, true
        end
    end

    for Code = 3, 255 do
        if IsBindableKey(Code) and ModifierKeys[Code] and iskeypressed(Code) then
            return Code, true
        end
    end

    return 0, false
end

local TextSizes = {}
local CONTROL_TEXT_SIZE = 12
local CONTROL_ROW_HEIGHT = 22
local CONTROL_SLOT_HEIGHT = 30

local function SetTextSize(Object, Value)
    if not Object then return 13 end
    Value = Type(Value) == "number" and Max(1, Floor(Value + 0.5)) or 13
    TextSizes[Object] = Value

    pcall(function()
        Object.Size = Value
    end)

    pcall(function()
        Object.FontSize = Value
    end)

    return Value
end

local function GetTextSize(Object, Default)
    local Value = Object and TextSizes[Object] or nil
    if Type(Value) == "number" then return Value end
    return Type(Default) == "number" and Default or 13
end

local function NewDrawing(Class, Properties)
    local Object = Drawing.new(Class)

    for Name, Value in pairs(Properties) do
        if Class == "Text" and Name == "Size" and Type(Value) == "number" then
            SetTextSize(Object, Value)
        else
            Object[Name] = Value
        end
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

    TextSizes[Object] = nil
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

local function SliderDecimals(Step)
    if Type(Step) ~= "number" or Step <= 0 then return 0 end

    local Decimals = 0
    local Scaled = Step

    while Decimals < 6 and Abs(Scaled - Floor(Scaled + 0.5)) > 0.000001 do
        Decimals = Decimals + 1
        Scaled = Step * (10 ^ Decimals)
    end

    return Decimals
end

local function RoundValue(Value, Step)
    if Type(Step) ~= "number" or Step <= 0 then return Value end

    local Decimals = SliderDecimals(Step)
    local Rounded = Floor(Value / Step + 0.5) * Step

    if Decimals <= 0 then
        return Floor(Rounded + 0.5)
    end

    local Scale = 10 ^ Decimals
    Rounded = Floor(Rounded * Scale + 0.5) / Scale

    if Abs(Rounded) < 0.5 / Scale then
        Rounded = 0
    end

    return Rounded
end

local function FormatSliderValue(Value, Step)
    local Decimals = SliderDecimals(Step)
    local Rounded = RoundValue(Value, Step)

    if Decimals <= 0 then
        return tostring(Floor(Rounded + 0.5))
    end

    local Text = Format("%." .. tostring(Decimals) .. "f", Rounded)
    Text = string.gsub(Text, "0+$", "")
    Text = string.gsub(Text, "%.$", "")

    if Text == "-0" then
        Text = "0"
    end

    return Text
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
    Name = "Nightfall",
    Version = 27,
    ApiVersion = 2,
    Theme = "Nightfall",
    Windows = {}
}

Library.KeybindSettings = {
    ShowHeader = true,
    ShowInactive = true,
    AccentActive = true,
    CompactRows = true,
    LowercaseNames = false
}

local WindowMethods = {}
local TabMethods = {}
local SectionMethods = {}
local CloseDropdown
local ClosePicker
local CloseBindMenu
local DropdownText
local ToggleMethods = {}
local SliderMethods = {}
local DropdownMethods = {}
local ColorMethods = {}
local KeybindMethods = {}
local LabelMethods = {}

local function ControlHeight(Control, Scale)
    Scale = Type(Scale) == "number" and Scale or 1

    if Control.Type == "Slider" then
        return Max(36, Floor(40 * Scale + 0.5))
    end

    return Max(CONTROL_SLOT_HEIGHT, Floor(CONTROL_SLOT_HEIGHT * Scale + 0.5))
end

local function GetSectionHeight(Section, Scale)
    local Height = 18

    for _, Control in ipairs(Section.Controls) do
        if Control.Visible ~= false then
            Height = Height + ControlHeight(Control, Scale)
        end
    end

    return Max(48, Height + 8)
end

local Layout = {
    SidebarWidth = 130,
    OuterPadding = 15,
    ColumnGap = 15,
    SectionGap = 14,
    ControlPadding = 15,
    TabTop = 80,
    TabHeight = 24,
    TabStep = 30,
    PanelWidth = 196
}

local function GetTabContentHeight(Tab, Scale)
    if not Tab then return 0 end

    local Gap = Max(8, Floor(Layout.SectionGap * Scale + 0.5))
    local Left = 0
    local Right = 0
    local LeftCount = 0
    local RightCount = 0

    for _, Section in ipairs(Tab.Sections) do
        local Height = GetSectionHeight(Section, Scale)

        if Section.Side == "Right" then
            Right = Right + Height
            RightCount = RightCount + 1
        else
            Left = Left + Height
            LeftCount = LeftCount + 1
        end
    end

    if LeftCount > 1 then
        Left = Left + Gap * (LeftCount - 1)
    end

    if RightCount > 1 then
        Right = Right + Gap * (RightCount - 1)
    end

    return Max(Left, Right)
end

local function GetLayoutScale(Window, Tab)
    if not Tab then return 1 end

    local Available = Max(1, Window.Size.Y - 36)

    if GetTabContentHeight(Tab, 1) <= Available then
        return 1
    end

    local Low = 0.50
    local High = 1

    if GetTabContentHeight(Tab, Low) > Available then
        return Low
    end

    for _ = 1, 10 do
        local Mid = (Low + High) * 0.5

        if GetTabContentHeight(Tab, Mid) <= Available then
            Low = Mid
        else
            High = Mid
        end
    end

    return Low
end

local function FitWindowHeight(Window, Tab)
    Window.LayoutScale = GetLayoutScale(Window, Tab)
end

local function TextWidth(Text, Size)
    Text = tostring(Text or "")
    Size = Type(Size) == "number" and Size or 13

    local Width = 0

    for Index = 1, #Text do
        local Character = string.sub(Text, Index, Index)
        local Factor = 0.61

        if Character == " " then
            Factor = 0.34
        elseif string.find("ilI1|!.,:;'`", Character, 1, true) then
            Factor = 0.31
        elseif string.find("MW@%#QO", Character, 1, true) then
            Factor = 0.86
        elseif Character == "[" or Character == "]" or Character == "(" or Character == ")" then
            Factor = 0.42
        elseif string.find("0123456789", Character, 1, true) then
            Factor = 0.58
        elseif Character == Character:upper() and Character ~= Character:lower() then
            Factor = 0.66
        end

        Width = Width + Size * Factor
    end

    return Width
end

local function FitText(Text, MaxWidth, Size)
    Text = tostring(Text or "")
    MaxWidth = Max(0, Type(MaxWidth) == "number" and MaxWidth or 0)
    Size = Type(Size) == "number" and Size or 13

    if TextWidth(Text, Size) <= MaxWidth then
        return Text
    end

    local Dots = "..."
    local DotsWidth = TextWidth(Dots, Size)

    if MaxWidth <= DotsWidth then
        return ""
    end

    local Length = #Text

    while Length > 0 do
        local Result = string.sub(Text, 1, Length) .. Dots

        if TextWidth(Result, Size) <= MaxWidth then
            return Result
        end

        Length = Length - 1
    end

    return ""
end

local function SetTextFit(Object, Text, MaxWidth, PreferredSize, MinimumSize)
    if not Object then return end

    PreferredSize = Type(PreferredSize) == "number" and PreferredSize or 13
    MaxWidth = Max(0, Type(MaxWidth) == "number" and MaxWidth or 0)

    SetTextSize(Object, PreferredSize)
    Object.Text = FitText(Text, MaxWidth, PreferredSize)
end

local function Pixel(Value)
    return Floor(Value + 0.5)
end

local function PixelVector(X, Y)
    return NewVector2(Pixel(X), Pixel(Y))
end

local function TextTop(PositionY, Height, FontSize)
    FontSize = Type(FontSize) == "number" and FontSize or CONTROL_TEXT_SIZE
    return Floor(PositionY + (Height - FontSize) * 0.5 + 0.5)
end

local function TextVerticalPosition(PositionY, Height, FontSize)
    return TextTop(PositionY, Height, FontSize)
end

local function CenterTextInRect(Object, Text, Position, Size, PreferredSize, MinimumSize)
    if not Object or TypeOf(Position) ~= "Vector2" or TypeOf(Size) ~= "Vector2" then return end

    SetTextFit(Object, Text, Max(1, Size.X - 6), PreferredSize, MinimumSize)
    Object.Center = true

    local FontSize = GetTextSize(Object, PreferredSize or 13)
    Object.Position = NewVector2(
        Pixel(Position.X + Size.X * 0.5),
        TextVerticalPosition(Position.Y, Size.Y, FontSize)
    )
end

local function CenterBindTextInRect(Object, Text, Position, Size, PreferredSize, MinimumSize)
    CenterTextInRect(Object, Text, Position, Size, PreferredSize, MinimumSize)
    if Object and TypeOf(Object.Position) == "Vector2" then
        Object.Position = PixelVector(Object.Position.X, Object.Position.Y + 2)
    end
end

local function AlignTextLeftInRect(Object, Text, Position, Size, Padding, PreferredSize, MinimumSize)
    if not Object or TypeOf(Position) ~= "Vector2" or TypeOf(Size) ~= "Vector2" then return end

    Padding = Type(Padding) == "number" and Padding or 0
    SetTextFit(Object, Text, Max(1, Size.X - Padding * 2), PreferredSize, MinimumSize)
    Object.Center = false

    local FontSize = GetTextSize(Object, PreferredSize or 13)
    Object.Position = NewVector2(
        Pixel(Position.X + Padding),
        TextVerticalPosition(Position.Y, Size.Y, FontSize)
    )
end

local function AlignTextRightInRect(Object, Text, Position, Size, Padding, PreferredSize, MinimumSize)
    if not Object or TypeOf(Position) ~= "Vector2" or TypeOf(Size) ~= "Vector2" then return end

    Padding = Type(Padding) == "number" and Padding or 0
    SetTextFit(Object, Text, Max(1, Size.X - Padding * 2), PreferredSize, MinimumSize)
    Object.Center = false

    local FontSize = GetTextSize(Object, PreferredSize or CONTROL_TEXT_SIZE)
    local Width = Pixel(TextWidth(Object.Text, FontSize))
    Object.Position = NewVector2(
        Pixel(Position.X + Size.X - Padding - Width),
        TextVerticalPosition(Position.Y, Size.Y, FontSize)
    )
end

local function GetPopupPosition(Window, Control, Width, Height, Gap)
    Gap = Gap or 4

    local Left = Pixel(Window.Position.X + Layout.SidebarWidth + 4)
    local Right = Pixel(Window.Position.X + Window.Size.X - 4)
    local Top = Pixel(Window.Position.Y + 4)
    local Bottom = Pixel(Window.Position.Y + Window.Size.Y - 4)
    local X = Pixel(Control.HitPosition.X + Control.HitSize.X - Width)
    local Y = Pixel(Control.HitPosition.Y + Control.HitSize.Y + Gap)

    X = Clamp(X, Left, Max(Left, Right - Width))

    if Y + Height > Bottom then
        local Above = Pixel(Control.HitPosition.Y - Height - Gap)
        if Above >= Top then
            Y = Above
        else
            Y = Max(Top, Bottom - Height)
        end
    end

    return NewVector2(X, Y)
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
    local SectionVisible = State and Section.LayoutVisible ~= false
    local TitleVisible = SectionVisible and Section.TitleLayoutVisible ~= false

    SetVisible(Section.Outline, SectionVisible)
    SetVisible(Section.Background, SectionVisible)
    SetVisible(Section.TitleBackground, TitleVisible)
    SetVisible(Section.TitleText, TitleVisible)

    for _, Control in ipairs(Section.Controls) do
        SetControlVisible(Control, SectionVisible and Control.Visible and Control.LayoutVisible ~= false)
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
                elseif Control.Type == "Label" then
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
        local Panel = Window.KeybindPanel
        Panel.Outline.Color = Theme.Outline
        Panel.Inline.Color = Theme.Inline
        Panel.Background.Color = Theme.GroupBackground
        Panel.Accent.Color = Theme.AccentColor
        Panel.Title.Color = Theme.PrimaryText

        for _, Row in ipairs(Panel.Rows) do
            Row.Background.Color = Theme.AccentColor
            Row.ActiveBar.Color = Theme.AccentColor
            Row.Name.Color = Row.Active and Theme.PrimaryText or Theme.SecondaryText
            Row.Key.Color = Row.Active and Theme.PrimaryText or Theme.SecondaryText
            Row.Mode.Color = Row.Active and (Library.KeybindSettings.AccentActive ~= false and Theme.AccentColor or Theme.PrimaryText) or Theme.SecondaryText
        end
    end
end

local function RefreshLayout(Window)
    local Position = PixelVector(Window.Position.X, Window.Position.Y)
    local Size = PixelVector(Window.Size.X, Window.Size.Y)
    local Theme = Window.Theme
    local SidebarWidth = Layout.SidebarWidth
    local OuterPadding = Layout.OuterPadding
    local ColumnGap = Layout.ColumnGap
    local ContentLeft = Position.X + SidebarWidth + OuterPadding
    local ContentRight = Position.X + Size.X - OuterPadding
    local ContentWidth = Max(0, ContentRight - ContentLeft)
    local LeftWidth = Floor((ContentWidth - ColumnGap) / 2)
    local RightWidth = Max(0, ContentWidth - ColumnGap - LeftWidth)
    local LeftX = ContentLeft
    local RightX = ContentLeft + LeftWidth + ColumnGap

    Window.Position = Position
    Window.Size = Size

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

    AlignTextLeftInRect(
        Window.TitleText,
        Upper(Window.Title),
        Position,
        NewVector2(Size.X, 30),
        20,
        16,
        16
    )

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
        local Y = Layout.TabTop + (Index - 1) * Layout.TabStep
        SetTextFit(Tab.Text, Tab.Name, SidebarWidth - 38, 14, 10)
        Tab.Text.Position = NewVector2(Position.X + 25, TextVerticalPosition(Position.Y + Y - 5, Layout.TabHeight, GetTextSize(Tab.Text, 14)))
        Tab.Indicator.Position = Position + NewVector2(1, Y + 1)
        Tab.Indicator.Size = NewVector2(2, 12)
        Tab.HitPosition = Position + NewVector2(12, Y - 5)
        Tab.HitSize = NewVector2(SidebarWidth - 18, Layout.TabHeight)
    end

    if Window.ActiveTab then
        local Scale = GetLayoutScale(Window, Window.ActiveTab)
        local SectionGap = Max(8, Pixel(Layout.SectionGap * Scale))
        local ContentTop = Position.Y + 18
        local ContentBottom = Position.Y + Size.Y - 12
        local LeftY = ContentTop
        local RightY = ContentTop

        Window.LayoutScale = Scale

        for _, Section in ipairs(Window.ActiveTab.Sections) do
            local IsRight = Section.Side == "Right"
            local X = IsRight and RightX or LeftX
            local Width = IsRight and RightWidth or LeftWidth
            local Y = IsRight and RightY or LeftY
            local Height = GetSectionHeight(Section, Scale)

            Section.Position = NewVector2(X, Y)
            Section.Size = NewVector2(Width, Height)

            local VisibleTop = Max(Y, ContentTop)
            local VisibleBottom = Min(Y + Height, ContentBottom)
            local VisibleHeight = Max(0, VisibleBottom - VisibleTop)

            Section.LayoutVisible = VisibleHeight > 0
            Section.TitleLayoutVisible = Y >= ContentTop and Y + 12 <= ContentBottom

            Section.Outline.Position = NewVector2(X, VisibleTop)
            Section.Outline.Size = NewVector2(Width, VisibleHeight)
            Section.Background.Position = NewVector2(X + 1, VisibleTop + 1)
            Section.Background.Size = NewVector2(Max(1, Width - 2), Max(1, VisibleHeight - 2))

            local TitleWidth = Min(Width - 24, Max(48, Pixel(TextWidth(Section.Name, 13) + 10)))
            Section.TitleBackground.Position = Section.Position + NewVector2(10, -2)
            Section.TitleBackground.Size = NewVector2(Max(1, TitleWidth), 4)
            AlignTextLeftInRect(
                Section.TitleText,
                Section.Name,
                NewVector2(Section.Position.X + 10, Section.Position.Y - 9),
                NewVector2(Max(1, Width - 20), 18),
                4,
                13,
                13
            )

            local ControlY = Y + 18

            for _, Control in ipairs(Section.Controls) do
                if Control.Visible ~= false then
                    local RowHeight = ControlHeight(Control, Scale)
                    local RowTop = Pixel(ControlY)
                    local RowCenterY = Pixel(RowTop + RowHeight * 0.5)
                    local X0 = X + Layout.ControlPadding
                    local ControlWidth = Max(1, Width - Layout.ControlPadding * 2)
                    local BoxY = Pixel(RowCenterY - CONTROL_ROW_HEIGHT * 0.5)

                    if Control.Type == "Toggle" then
                        local ToggleSize = 12
                        local ToggleY = Pixel(RowCenterY - ToggleSize * 0.5)

                        Control.Drawings.Outline.Position = NewVector2(X0, ToggleY)
                        Control.Drawings.Outline.Size = NewVector2(ToggleSize, ToggleSize)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ToggleY + 1)
                        Control.Drawings.Inline.Size = NewVector2(ToggleSize - 2, ToggleSize - 2)
                        Control.Drawings.Fill.Position = NewVector2(X0 + 2, ToggleY + 2)
                        Control.Drawings.Fill.Size = NewVector2(ToggleSize - 4, ToggleSize - 4)

                        Control.HitPosition = NewVector2(X0, RowTop)
                        Control.HitSize = NewVector2(ControlWidth, RowHeight)

                        local Right = X0 + ControlWidth

                        if Control.Bind then
                            local BindText = "[" .. GetKeyName(Control.Bind.Key) .. "]"
                            local BindWidth = Clamp(Pixel(TextWidth(BindText, CONTROL_TEXT_SIZE) + 16), 48, Min(92, ControlWidth))
                            local BindHeight = 16
                            local BindY = Pixel(RowCenterY - BindHeight * 0.5)
                            Control.Bind.HitPosition = NewVector2(Right - BindWidth, BindY)
                            Control.Bind.HitSize = NewVector2(BindWidth, BindHeight)
                            Control.Bind.Outline.Position = Control.Bind.HitPosition
                            Control.Bind.Outline.Size = Control.Bind.HitSize
                            Control.Bind.Inline.Position = Control.Bind.HitPosition + NewVector2(1, 1)
                            Control.Bind.Inline.Size = Control.Bind.HitSize - NewVector2(2, 2)
                            CenterBindTextInRect(
                                Control.Bind.Text,
                                BindText,
                                Control.Bind.Inline.Position,
                                Control.Bind.Inline.Size,
                                CONTROL_TEXT_SIZE,
                                CONTROL_TEXT_SIZE
                            )
                            Right = Right - BindWidth - 7
                        end

                        if Control.AttachedColor then
                            local PickerWidth = 28
                            local PickerHeight = 12
                            local PickerY = Pixel(RowCenterY - PickerHeight * 0.5)
                            Control.AttachedColor.HitPosition = NewVector2(Right - PickerWidth, PickerY)
                            Control.AttachedColor.HitSize = NewVector2(PickerWidth, PickerHeight)
                            Control.AttachedColor.Outline.Position = Control.AttachedColor.HitPosition
                            Control.AttachedColor.Outline.Size = Control.AttachedColor.HitSize
                            Control.AttachedColor.Fill.Position = Control.AttachedColor.HitPosition + NewVector2(1, 1)
                            Control.AttachedColor.Fill.Size = Control.AttachedColor.HitSize - NewVector2(2, 2)
                            Right = Right - PickerWidth - 7
                        end

                        AlignTextLeftInRect(
                            Control.Drawings.Label,
                            Control.Name,
                            NewVector2(X0 + 20, RowTop),
                            NewVector2(Max(1, Right - (X0 + 20) - 4), RowHeight),
                            0,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )

                    elseif Control.Type == "Slider" then
                        local LabelHeight = 16
                        local LabelY = RowTop + 1
                        local TrackY = RowTop + 24
                        local ValueText = FormatSliderValue(Control.Value, Control.Step) .. Control.Suffix
                        local ValueWidth = Min(Floor(ControlWidth * 0.48), Max(34, Pixel(TextWidth(ValueText, CONTROL_TEXT_SIZE) + 8)))
                        local LabelWidth = Max(1, ControlWidth - ValueWidth - 8)

                        AlignTextLeftInRect(
                            Control.Drawings.Label,
                            Control.Name,
                            NewVector2(X0, LabelY),
                            NewVector2(LabelWidth, LabelHeight),
                            0,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )

                        AlignTextRightInRect(
                            Control.Drawings.Value,
                            ValueText,
                            NewVector2(X0 + LabelWidth + 8, LabelY),
                            NewVector2(ValueWidth, LabelHeight),
                            0,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )

                        Control.Drawings.Outline.Position = NewVector2(X0, TrackY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, 8)
                        Control.Drawings.Background.Position = NewVector2(X0 + 1, TrackY + 1)
                        Control.Drawings.Background.Size = NewVector2(Max(1, ControlWidth - 2), 6)

                        local Range = Control.Max - Control.Min
                        local Percent = Range > 0 and Clamp((Control.Value - Control.Min) / Range, 0, 1) or 0
                        local TrackWidth = Max(1, ControlWidth - 2)
                        local FillWidth = Clamp(Pixel(TrackWidth * Percent), 1, TrackWidth)

                        Control.Drawings.Fill.Position = NewVector2(X0 + 1, TrackY + 1)
                        Control.Drawings.Fill.Size = NewVector2(FillWidth, 6)

                        local ThumbX = Clamp(
                            X0 + 1 + Pixel((TrackWidth - 1) * Percent),
                            X0 + 1,
                            X0 + ControlWidth - 2
                        )

                        Control.Drawings.Thumb.Position = NewVector2(ThumbX, TrackY + 4)
                        Control.HitPosition = NewVector2(X0, RowTop)
                        Control.HitSize = NewVector2(ControlWidth, RowHeight)

                    elseif Control.Type == "Dropdown" then
                        Control.Drawings.Outline.Position = NewVector2(X0, BoxY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, CONTROL_ROW_HEIGHT)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, BoxY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), CONTROL_ROW_HEIGHT - 2)
                        Control.HitPosition = NewVector2(X0, RowTop)
                        Control.HitSize = NewVector2(ControlWidth, RowHeight)

                        local TextRectPosition = Control.Drawings.Inline.Position
                        local TextRectSize = Control.Drawings.Inline.Size

                        AlignTextLeftInRect(
                            Control.Drawings.Label,
                            DropdownText(Control),
                            TextRectPosition,
                            NewVector2(Max(1, TextRectSize.X - 24), TextRectSize.Y),
                            7,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )

                        AlignTextRightInRect(
                            Control.Drawings.State,
                            Control.Drawings.State.Text,
                            TextRectPosition,
                            TextRectSize,
                            8,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )

                    elseif Control.Type == "Colorpicker" then
                        local PickerWidth = 28
                        local PickerHeight = 12
                        local PickerY = Pixel(RowCenterY - PickerHeight * 0.5)
                        local PickerPosition = NewVector2(X0 + ControlWidth - PickerWidth, PickerY)

                        AlignTextLeftInRect(
                            Control.Drawings.Label,
                            Control.Name,
                            NewVector2(X0, RowTop),
                            NewVector2(Max(1, ControlWidth - PickerWidth - 8), RowHeight),
                            0,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )
                        Control.Drawings.Outline.Position = PickerPosition
                        Control.Drawings.Outline.Size = NewVector2(PickerWidth, PickerHeight)
                        Control.Drawings.Fill.Position = PickerPosition + NewVector2(1, 1)
                        Control.Drawings.Fill.Size = NewVector2(PickerWidth - 2, PickerHeight - 2)

                        Control.HitPosition = NewVector2(X0, RowTop)
                        Control.HitSize = NewVector2(ControlWidth, RowHeight)

                    elseif Control.Type == "Label" then
                        Control.HitPosition = NewVector2(-1000000, -1000000)
                        Control.HitSize = NewVector2(1, 1)
                        AlignTextLeftInRect(
                            Control.Drawings.Label,
                            Control.Value,
                            NewVector2(X0, RowTop),
                            NewVector2(ControlWidth, RowHeight),
                            0,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )

                    elseif Control.Type == "Button" then
                        Control.Drawings.Outline.Position = NewVector2(X0, BoxY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, CONTROL_ROW_HEIGHT)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, BoxY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), CONTROL_ROW_HEIGHT - 2)
                        Control.HitPosition = NewVector2(X0, RowTop)
                        Control.HitSize = NewVector2(ControlWidth, RowHeight)

                        CenterTextInRect(
                            Control.Drawings.Label,
                            Control.Name,
                            Control.Drawings.Inline.Position,
                            Control.Drawings.Inline.Size,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )

                    elseif Control.Type == "Keybind" then
                        local KeybindBoxY = BoxY
                        Control.Drawings.Outline.Position = NewVector2(X0, KeybindBoxY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, CONTROL_ROW_HEIGHT)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, KeybindBoxY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), CONTROL_ROW_HEIGHT - 2)
                        local KeybindText = Control.Name .. " [" .. GetKeyName(Control.Value) .. "]"

                        Control.HitPosition = NewVector2(X0, RowTop)
                        Control.HitSize = NewVector2(ControlWidth, RowHeight)

                        CenterBindTextInRect(
                            Control.Drawings.Label,
                            KeybindText,
                            Control.Drawings.Inline.Position,
                            Control.Drawings.Inline.Size,
                            CONTROL_TEXT_SIZE,
                            CONTROL_TEXT_SIZE
                        )
                    end

                    Control.LayoutVisible = RowTop + RowHeight > ContentTop and RowTop < ContentBottom
                    ControlY = ControlY + RowHeight
                else
                    Control.LayoutVisible = false
                end
            end

            if IsRight then
                RightY = Y + Height + SectionGap
            else
                LeftY = Y + Height + SectionGap
            end
        end
    end

    if LayoutKeybindPanel then
        LayoutKeybindPanel(Window)
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
        local Panel = Window.KeybindPanel
        local PanelVisible = Window.ShowKeybinds == true
        local HeaderVisible = Library.KeybindSettings.ShowHeader ~= false
        Panel.Outline.Visible = PanelVisible
        Panel.Inline.Visible = PanelVisible
        Panel.Background.Visible = PanelVisible
        Panel.Accent.Visible = false
        Panel.Title.Visible = PanelVisible and HeaderVisible

        for _, Row in ipairs(Panel.Rows) do
            Row.Name.Visible = PanelVisible
            Row.Key.Visible = PanelVisible
            Row.Mode.Visible = PanelVisible
            Row.Background.Visible = PanelVisible and Row.Active and Library.KeybindSettings.AccentActive ~= false
            Row.ActiveBar.Visible = false
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
    CloseBindMenu(Window)
    FitWindowHeight(Window, Tab)
    RefreshLayout(Window)
    ApplyVisibility(Window)
end

local function ReadOption(Options, Lower, Upper, Default)
    if Type(Options) ~= "table" then return Default end

    local Value = Options[Lower]
    if Value == nil and Upper then Value = Options[Upper] end
    if Value == nil then return Default end
    return Value
end

function Library:GetVersion()
    return self.Version, self.ApiVersion
end

function Library:GetTheme()
    return self.Theme
end

function Library:GetThemes()
    local Result = {}
    for Index, Name in ipairs(ThemeNames) do Result[Index] = Name end
    return Result
end

function Library:GetKeyName(Value)
    return GetKeyName(GetKeyCode(Value))
end

function Library:GetKeyCode(Value)
    return GetKeyCode(Value)
end

function Library:SetTheme(Name)
    if Type(Name) == "table" then
        Name = ReadOption(Name, "name", "Name", ReadOption(Name, "theme", "Theme", nil))
    end

    if Type(Name) ~= "string" or not Themes[Name] then return self end

    self.Theme = Name

    for _, Window in ipairs(self.Windows) do
        Window.ThemeName = Name
        Window.Theme = Themes[Name]
        RefreshLayout(Window)
        ApplyVisibility(Window)
    end

    return self
end

function Library:SetBackgroundImage()
end

local function MakeWindowDrawings(Window)
    local Theme = Window.Theme

    Window.MainOutline = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.3,
        Color = Theme.Outline
    })

    Window.MainBackground = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.7,
        Color = Theme.Background
    })

    Window.Sidebar = NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.6,
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
        Title = tostring(ReadOption(Options, "title", "Title", "Nightfall")),
        Subtitle = tostring(ReadOption(Options, "subtitle", "Subtitle", "")),
        Position = TypeOf(ReadOption(Options, "position", "Position", nil)) == "Vector2" and ReadOption(Options, "position", "Position", nil) or NewVector2(200, 180),
        Size = TypeOf(ReadOption(Options, "size", "Size", nil)) == "Vector2" and ReadOption(Options, "size", "Size", nil) or NewVector2(550, 430),
        MinimumSize = TypeOf(ReadOption(Options, "minimumSize", "MinimumSize", nil)) == "Vector2" and ReadOption(Options, "minimumSize", "MinimumSize", nil) or NewVector2(520, 420),
        MenuKey = GetKeyCode(ReadOption(Options, "menuKey", "MenuKey", "F2")),
        ConfigName = SafeName(ReadOption(Options, "configName", "ConfigName", "Default")),
        ConfigFolder = SafeName(ReadOption(Options, "configFolder", "ConfigFolder", "NightfallConfigs")),
        ThemeName = Themes[ReadOption(Options, "theme", "Theme", self.Theme)] and ReadOption(Options, "theme", "Theme", self.Theme) or self.Theme,
        Theme = Themes[Themes[ReadOption(Options, "theme", "Theme", self.Theme)] and ReadOption(Options, "theme", "Theme", self.Theme) or self.Theme],
        Tabs = {},
        Controls = {},
        Binds = {},
        ActiveTab = nil,
        Active = true,
        Open = ReadOption(Options, "startOpen", "StartOpen", true) ~= false,
        LastMouse = false,
        KeyHeld = false,
        Capturing = nil,
        ActiveSlider = nil,
        OpenDropdown = nil,
        OpenPicker = nil,
        OpenBindMenu = nil,
        LastMouse2 = false,
        Dragging = false,
        Resizing = nil,
        ShowKeybinds = ReadOption(Options, "keybindList", "KeybindList", true) ~= false
    }, {__index = WindowMethods})

    Window.BaseHeight = Window.Size.Y
    Window.AutoHeight = ReadOption(Options, "autoHeight", "AutoHeight", true) ~= false
    Window.LayoutScale = 1

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

function WindowMethods:Tab(Name, Icon)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Tab")
        Icon = ReadOption(Options, "icon", "Icon", "")
    end

    local Tab = setmetatable({
        Window = self,
        Name = tostring(Name or "Tab"),
        Icon = tostring(Icon or ""),
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

function TabMethods:Section(Name, Side, Icon)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Section")
        Side = ReadOption(Options, "side", "Side", "Left")
        Icon = ReadOption(Options, "icon", "Icon", "")
    end

    local Section = setmetatable({
        Tab = self,
        Window = self.Window,
        Name = tostring(Name or "Section"),
        Icon = tostring(Icon or ""),
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
        Color = Theme.Outline
    })

    Section.Background = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.1,
        Color = Theme.GroupBackground
    })

    Section.TitleBackground = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
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

    if Section.Window.ActiveTab == Section.Tab then
        FitWindowHeight(Section.Window, Section.Tab)
    end

    RefreshLayout(Section.Window)
    ApplyVisibility(Section.Window)
    return Control
end

function SectionMethods:Label(Name)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", ReadOption(Options, "value", "Value", "Label"))
    end

    local Control = setmetatable({
        Type = "Label",
        Name = tostring(Name or "Label"),
        Value = tostring(Name or "Label"),
        Drawings = {},
        HitPosition = NewVector2(-1000000, -1000000),
        HitSize = NewVector2(1, 1)
    }, {__index = LabelMethods})

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Value,
        Size = CONTROL_TEXT_SIZE,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = self.Window.Theme.SecondaryText
    })

    return AddControl(self, Control)
end

function LabelMethods:GetValue()
    return self.Value
end

function LabelMethods:SetValue(Value)
    self.Value = tostring(Value or "")
    self.Name = self.Value
    self.Drawings.Label.Text = self.Value
    RefreshLayout(self.Window)
    return self
end

LabelMethods.Set = LabelMethods.SetValue

function SectionMethods:Toggle(Name, Default, Callback)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Toggle")
        Default = ReadOption(Options, "default", "Default", false)
        Callback = ReadOption(Options, "callback", "Callback", nil)
    end

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
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.5,
        Color = Theme.Inline
    })

    Control.Drawings.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Color = Control.CurrentFill
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name,
        Size = CONTROL_TEXT_SIZE,
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

    return self
end

function ToggleMethods:AddKeybind(Default, Mode)
    if self.Bind then return self.Bind end

    if Type(Default) == "table" then
        local Options = Default
        Default = ReadOption(Options, "key", "Key", ReadOption(Options, "default", "Default", "-"))
        Mode = ReadOption(Options, "mode", "Mode", "Toggle")
    end

    local Theme = self.Window.Theme
    local Bind = setmetatable({
        Control = self,
        Window = self.Window,
        Key = GetKeyCode(Default),
        Mode = Mode == "Hold" and "Hold" or Mode == "Always" and "Always" or "Toggle",
        Held = false,
        WasPressed = false,
        CurrentColor = Theme.ToggleBackground,
        HitPosition = NewVector2(0, 0),
        HitSize = NewVector2(0, 0)
    }, {__index = KeybindMethods})

    Bind.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Color = Theme.Outline
    })

    Bind.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Color = Theme.ToggleBackground
    })

    Bind.Text = NewDrawing("Text", {
        Text = "[" .. GetKeyName(Bind.Key) .. "]",
        Size = 12,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = false,
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

    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Color")
        Default = ReadOption(Options, "default", "Default", FromRGB(255, 255, 255))
        Callback = ReadOption(Options, "callback", "Callback", nil)
    end

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
        Color = Theme.Outline
    })

    Picker.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Color = Color
    })

    self.AttachedColor = Picker
    RefreshLayout(self.Window)
    ApplyVisibility(self.Window)
    return Picker
end

function SectionMethods:Slider(Name, Default, Step, Minimum, Maximum, Suffix, Callback)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Slider")
        Default = ReadOption(Options, "default", "Default", 0)
        Step = ReadOption(Options, "step", "Step", 1)
        Minimum = ReadOption(Options, "min", "Min", ReadOption(Options, "minimum", "Minimum", 0))
        Maximum = ReadOption(Options, "max", "Max", ReadOption(Options, "maximum", "Maximum", 100))
        Suffix = ReadOption(Options, "suffix", "Suffix", "")
        Callback = ReadOption(Options, "callback", "Callback", nil)
    end

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
        Size = CONTROL_TEXT_SIZE,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    Control.Drawings.Value = NewDrawing("Text", {
        Text = FormatSliderValue(Control.Value, Control.Step) .. Control.Suffix,
        Size = CONTROL_TEXT_SIZE,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = false,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })

    Control.Drawings.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.3,
        Color = Theme.Outline
    })

    Control.Drawings.Background = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.5,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.9,
        Color = Theme.AccentColor
    })

    Control.Drawings.Thumb = NewDrawing("Circle", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Radius = 4,
        NumSides = 24,
        Thickness = 1,
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
    self.Drawings.Value.Text = FormatSliderValue(Value, self.Step) .. self.Suffix
    RefreshLayout(self.Window)

    if not Silent and self.Callback then
        self.Callback(Value)
    end

    return self
end

DropdownText = function(Control)
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
    if Type(Name) == "table" then
        local Config = Name
        Name = ReadOption(Config, "name", "Name", "Dropdown")
        Default = ReadOption(Config, "default", "Default", nil)
        Options = ReadOption(Config, "options", "Options", {})
        Multi = ReadOption(Config, "multi", "Multi", false)
        Callback = ReadOption(Config, "callback", "Callback", nil)
    end

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
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = DropdownText(Control),
        Size = CONTROL_TEXT_SIZE,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.SecondaryText
    })

    Control.Drawings.State = NewDrawing("Text", {
        Text = "+",
        Size = CONTROL_TEXT_SIZE,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = false,
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

    return self
end

function SectionMethods:Colorpicker(Name, Default, Callback)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Color")
        Default = ReadOption(Options, "default", "Default", FromRGB(255, 255, 255))
        Callback = ReadOption(Options, "callback", "Callback", nil)
    end

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
        Size = CONTROL_TEXT_SIZE,
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
        Color = Theme.Outline
    })

    Control.Drawings.Fill = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
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

    return self
end

function SectionMethods:Button(Name, Callback)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Button")
        Callback = ReadOption(Options, "callback", "Callback", nil)
    end

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
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name,
        Size = CONTROL_TEXT_SIZE,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = false,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })

    return AddControl(self, Control)
end

function SectionMethods:Keybind(Name, Default, Callback)
    if Type(Name) == "table" then
        local Options = Name
        Name = ReadOption(Options, "name", "Name", "Keybind")
        Default = ReadOption(Options, "key", "Key", ReadOption(Options, "default", "Default", "-"))
        Callback = ReadOption(Options, "callback", "Callback", nil)
    end

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
        Color = Theme.Outline
    })

    Control.Drawings.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.6,
        Color = Theme.ToggleBackground
    })

    Control.Drawings.Label = NewDrawing("Text", {
        Text = Control.Name .. " [" .. GetKeyName(Control.Value) .. "]",
        Size = CONTROL_TEXT_SIZE,
        Font = Drawing.Fonts.System,
        Outline = true,
        Center = false,
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
    self.Held = false
    self.WasPressed = self.Key > 0 and iskeypressed(self.Key) or false
    RefreshLayout(self.Window)
    return self
end

function KeybindMethods:SetValue(Value, Silent)
    local Code = GetKeyCode(Value)

    if self.Control then
        self.Key = Code
        self.Text.Text = "[" .. GetKeyName(Code) .. "]"
        self.Held = false
        self.WasPressed = Code > 0 and iskeypressed(Code) or false
        RefreshLayout(self.Window)
        return self
    end

    self.Value = Code
    self.Drawings.Label.Text = self.Name .. " [" .. GetKeyName(Code) .. "]"
    RefreshLayout(self.Window)

    if not Silent and self.Callback then
        self.Callback(Code)
    end

    return self
end

function KeybindMethods:SetMode(Mode)
    if not self.Control then return end

    self.Mode = Mode == "Hold" and "Hold" or Mode == "Always" and "Always" or "Toggle"
    self.Held = false
    self.WasPressed = self.Key > 0 and iskeypressed(self.Key) or false

    if self.Mode == "Always" and self.Control.Type == "Toggle" then
        self.Control:SetValue(true)
    elseif self.Mode == "Hold" and self.Control.Type == "Toggle" then
        self.Control:SetValue(self.WasPressed)
        self.Held = self.WasPressed
    end

    return self
end

CloseBindMenu = function(Window)
    local Menu = Window.OpenBindMenu
    if not Menu then return end

    RemoveList(Menu.Drawings)
    Window.OpenBindMenu = nil
end

local function CreateBindMenu(Window, Bind)
    if not Bind or not Bind.Control then return end

    CloseBindMenu(Window)
    CloseDropdown(Window)
    ClosePicker(Window)

    local Theme = Window.Theme
    local Width = 88
    local RowHeight = 20
    local Modes = {"Toggle", "Hold", "Always"}
    local Height = #Modes * RowHeight + 2
    local Position = GetPopupPosition(Window, Bind, Width, Height, 3)
    local Drawings = {}
    local Entries = {}

    local function Add(Object)
        Insert(Drawings, Object)
        return Object
    end

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.35,
        ZIndex = 40,
        Position = Position,
        Size = NewVector2(Width, Height),
        Color = Theme.Outline
    }))

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.97,
        ZIndex = 41,
        Position = Position + NewVector2(1, 1),
        Size = NewVector2(Width - 2, Height - 2),
        Color = Theme.GroupBackground
    }))

    for Index, Mode in ipairs(Modes) do
        local Y = Position.Y + 1 + (Index - 1) * RowHeight
        local Selected = Bind.Mode == Mode
        local Background = Add(NewDrawing("Square", {
            Filled = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 42,
            Position = NewVector2(Position.X + 1, Y),
            Size = NewVector2(Width - 2, RowHeight),
            Color = Theme.GroupBackground
        }))
        local Indicator = Add(NewDrawing("Square", {
            Filled = true,
            Visible = Selected,
            Transparency = 1,
            ZIndex = 43,
            Position = NewVector2(Position.X + 1, Y + 3),
            Size = NewVector2(2, RowHeight - 6),
            Color = Theme.AccentColor
        }))
        local Text = Add(NewDrawing("Text", {
            Text = Mode,
            Size = 12,
            Font = Drawing.Fonts.System,
            Outline = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 44,
            Color = Selected and Theme.PrimaryText or Theme.SecondaryText
        }))
        AlignTextLeftInRect(
            Text,
            Mode,
            NewVector2(Position.X + 1, Y),
            NewVector2(Width - 2, RowHeight),
            9,
            12,
            12
        )

        Insert(Entries, {
            Mode = Mode,
            Position = NewVector2(Position.X + 1, Y),
            Size = NewVector2(Width - 2, RowHeight),
            Background = Background,
            Indicator = Indicator,
            Text = Text
        })
    end

    Window.OpenBindMenu = {
        Bind = Bind,
        Position = Position,
        Size = NewVector2(Width, Height),
        Drawings = Drawings,
        Entries = Entries
    }
end

CloseDropdown = function(Window)
    local Dropdown = Window.OpenDropdown
    if not Dropdown then return end

    RemoveList(Dropdown.Popup)
    Dropdown.Popup = nil
    Dropdown.PopupBounds = nil
    Dropdown.PopupPosition = nil
    Dropdown.PopupSize = nil
    Dropdown.Drawings.State.Text = "+"
    Window.OpenDropdown = nil
end

local function CreateDropdown(Window, Control)
    CloseDropdown(Window)
    ClosePicker(Window)
    CloseBindMenu(Window)

    local Theme = Window.Theme
    local Popup = {}
    local Bounds = {}
    local Width = Pixel(Control.HitSize.X)
    local Height = Max(2, #Control.Options * 20 + 2)
    local Position = GetPopupPosition(Window, Control, Width, Height, 2)

    Insert(Popup, NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.35,
        ZIndex = 20,
        Position = Position,
        Size = NewVector2(Width, Height),
        Color = Theme.Outline
    }))

    Insert(Popup, NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.97,
        ZIndex = 21,
        Position = Position + NewVector2(1, 1),
        Size = NewVector2(Max(1, Width - 2), Max(1, Height - 2)),
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
            Size = NewVector2(Max(1, Width - 2), 20),
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
            Text = FitText(tostring(Option), Max(1, Width - 18), CONTROL_TEXT_SIZE),
            Size = CONTROL_TEXT_SIZE,
            Font = Drawing.Fonts.System,
            Outline = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 24,
            Color = Selected and Theme.PrimaryText or Theme.SecondaryText
        })
        AlignTextLeftInRect(
            Text,
            tostring(Option),
            NewVector2(Position.X + 1, Y),
            NewVector2(Max(1, Width - 2), 20),
            11,
            13,
            13
        )

        Insert(Popup, Background)
        Insert(Popup, Indicator)
        Insert(Popup, Text)

        Insert(Bounds, {
            Option = Option,
            Position = NewVector2(Position.X + 1, Y),
            Size = NewVector2(Max(1, Width - 2), 20),
            Background = Background,
            Indicator = Indicator,
            Text = Text
        })
    end

    Control.Popup = Popup
    Control.PopupBounds = Bounds
    Control.PopupPosition = Position
    Control.PopupSize = NewVector2(Width, Height)
    Control.Drawings.State.Text = "-"
    Window.OpenDropdown = Control
end

ClosePicker = function(Window)
    local Picker = Window.OpenPicker
    if not Picker then return end

    RemoveList(Picker.Drawings)
    Window.OpenPicker = nil
end

local PickerWhiteGradientData = base64decode("iVBORw0KGgoAAAANSUhEUgAAAGAAAAABCAYAAAAhMKvHAAAAIElEQVR42mP8////fwYGhr8MDAz/oDQ+NrHqRs0iUh0AYiph/0LW3kIAAAAASUVORK5CYII=")
local PickerBlackGradientData = base64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAABgCAYAAADcvRh2AAAAIklEQVR42mNggAJmJgYGBiYmGIsILuk6Ro2np/EMDAwM/wGcXwK2FR5ogAAAAABJRU5ErkJggg==")
local PickerHueGradientData = base64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAABgCAIAAABT348hAAAAV0lEQVR42o3KOwrEMBQDwOFBqjT2/Q8ZkyZNQFtslY+XLQaBJKFoN/2lexC7U2owtc03q7CkNKX75i/XD0fIUYyb7aV7fMhijWrm+nxzhuzKpow/XH/CB9K/PIZSSRpyAAAAAElFTkSuQmCC")

local function MakePicker(Window, Control)
    ClosePicker(Window)
    CloseDropdown(Window)
    CloseBindMenu(Window)

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

    local PopupWidth = 148
    local PopupHeight = 128
    local Position = GetPopupPosition(Window, Control, PopupWidth, PopupHeight, 4)
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
        ZIndex = 30,
        Position = Position,
        Size = NewVector2(PopupWidth, PopupHeight),
        Color = Theme.Outline
    }))

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 0.98,
        ZIndex = 31,
        Position = Position + NewVector2(1, 1),
        Size = NewVector2(PopupWidth - 2, PopupHeight - 2),
        Color = Theme.GroupBackground
    }))

    local SvSize = 96
    local SvPosition = Position + NewVector2(8, 8)

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 32,
        Position = SvPosition - NewVector2(1, 1),
        Size = NewVector2(SvSize + 2, SvSize + 2),
        Color = Theme.Outline
    }))

    local SvBase = Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 33,
        Position = SvPosition,
        Size = NewVector2(SvSize, SvSize),
        Color = FromHSV(H, 1, 1)
    }))

    Add(NewDrawing("Image", {
        Data = PickerWhiteGradientData,
        Visible = true,
        Transparency = 1,
        ZIndex = 34,
        Position = SvPosition,
        Size = NewVector2(SvSize, SvSize),
        Color = FromRGB(255, 255, 255)
    }))

    Add(NewDrawing("Image", {
        Data = PickerBlackGradientData,
        Visible = true,
        Transparency = 1,
        ZIndex = 35,
        Position = SvPosition,
        Size = NewVector2(SvSize, SvSize),
        Color = FromRGB(255, 255, 255)
    }))

    local HuePosition = Position + NewVector2(110, 8)
    local HueSize = NewVector2(8, 96)

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 32,
        Position = HuePosition - NewVector2(1, 1),
        Size = HueSize + NewVector2(2, 2),
        Color = Theme.Outline
    }))

    Add(NewDrawing("Image", {
        Data = PickerHueGradientData,
        Visible = true,
        Transparency = 1,
        ZIndex = 33,
        Position = HuePosition,
        Size = HueSize,
        Color = FromRGB(255, 255, 255)
    }))

    local PreviewPosition = Position + NewVector2(124, 8)

    Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 32,
        Position = PreviewPosition,
        Size = NewVector2(18, 18),
        Color = Theme.Outline
    }))

    local Preview = Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 33,
        Position = PreviewPosition + NewVector2(1, 1),
        Size = NewVector2(16, 16),
        Color = Current
    }))

    local SvMarker = Add(NewDrawing("Circle", {
        Filled = false,
        Visible = true,
        Transparency = 1,
        ZIndex = 38,
        Radius = 3,
        NumSides = 20,
        Thickness = 1,
        Position = SvPosition,
        Color = Theme.PrimaryText
    }))

    local HueMarkerShadow = Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 37,
        Position = HuePosition,
        Size = NewVector2(HueSize.X + 4, 3),
        Color = Theme.Outline
    }))

    local HueMarker = Add(NewDrawing("Square", {
        Filled = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 38,
        Position = HuePosition,
        Size = NewVector2(HueSize.X + 2, 1),
        Color = Theme.PrimaryText
    }))

    local Hex = Add(NewDrawing("Text", {
        Text = ColorToHex(Current),
        Size = 12,
        Font = Drawing.Fonts.System,
        Outline = true,
        Visible = true,
        Transparency = 1,
        ZIndex = 38,
        Color = Theme.PrimaryText
    }))
    AlignTextLeftInRect(
        Hex,
        ColorToHex(Current),
        NewVector2(Position.X, Position.Y + 102),
        NewVector2(PopupWidth, 22),
        8,
        12,
        12
    )

    local Picker = {
        Control = Control,
        Position = Position,
        Size = NewVector2(PopupWidth, PopupHeight),
        Drawings = Objects,
        SvPosition = SvPosition,
        SvSize = SvSize,
        SvBase = SvBase,
        HuePosition = HuePosition,
        HueSize = HueSize,
        Hue = H,
        Saturation = S,
        Value = V,
        Preview = Preview,
        Hex = Hex,
        SvMarker = SvMarker,
        HueMarker = HueMarker,
        HueMarkerShadow = HueMarkerShadow
    }

    local function UpdateMarkers()
        local MarkerX = Picker.SvPosition.X + Picker.Saturation * (Picker.SvSize - 1)
        local MarkerY = Picker.SvPosition.Y + (1 - Picker.Value) * (Picker.SvSize - 1)
        Picker.SvMarker.Position = NewVector2(Pixel(MarkerX), Pixel(MarkerY))

        local HueY = Clamp(
            Picker.HuePosition.Y + (1 - Picker.Hue) * (Picker.HueSize.Y - 1),
            Picker.HuePosition.Y,
            Picker.HuePosition.Y + Picker.HueSize.Y - 1
        )

        Picker.HueMarkerShadow.Position = NewVector2(Picker.HuePosition.X - 2, Pixel(HueY) - 1)
        Picker.HueMarker.Position = NewVector2(Picker.HuePosition.X - 1, Pixel(HueY))
    end

    Picker.UpdateMarkers = UpdateMarkers
    Window.OpenPicker = Picker
    UpdateMarkers()
end

local function UpdatePicker(Window, Point)
    local Picker = Window.OpenPicker
    if not Picker then return end

    local Changed = false

    if PointIn(Picker.SvPosition, NewVector2(Picker.SvSize, Picker.SvSize), Point) then
        Picker.Saturation = Clamp((Point.X - Picker.SvPosition.X) / Max(Picker.SvSize - 1, 1), 0, 1)
        Picker.Value = 1 - Clamp((Point.Y - Picker.SvPosition.Y) / Max(Picker.SvSize - 1, 1), 0, 1)
        Changed = true
    elseif PointIn(Picker.HuePosition, Picker.HueSize, Point) then
        Picker.Hue = 1 - Clamp((Point.Y - Picker.HuePosition.Y) / Max(Picker.HueSize.Y - 1, 1), 0, 1)
        Picker.SvBase.Color = FromHSV(Picker.Hue, 1, 1)
        Changed = true
    end

    if not Changed then return end

    local Color = FromHSV(Picker.Hue, Picker.Saturation, Picker.Value)
    Picker.Preview.Color = Color
    Picker.Hex.Text = ColorToHex(Color)

    if Picker.UpdateMarkers then
        Picker.UpdateMarkers()
    end

    Picker.Control:SetValue(Color)
end

local function CleanKeybindDisplayName(Value)
    local Text = tostring(Value or ""):gsub("^%s+", ""):gsub("%s+$", "")
    Text = Text:gsub("[%s_%-]+[Kk][Ee][Yy][Bb][Ii][Nn][Dd]%s*$", "")
    Text = Text:gsub("[%s_%-]+[Bb][Ii][Nn][Dd]%s*$", "")
    Text = Text:gsub("^%s+", ""):gsub("%s+$", "")
    if Text == "" then Text = "Keybind" end
    Text = Text:gsub("(%a)([%w]*)", function(First, Rest)
        return string.upper(First) .. Rest
    end)
    return Text
end

local function EnsureKeybindPanel(Window)
    if Window.KeybindPanel then return end

    local Theme = Window.Theme

    Window.KeybindPanel = {
        Position = NewVector2(50, 400),
        Width = 180,
        Rows = {},
        Dragging = false
    }

    local Panel = Window.KeybindPanel

    Panel.Outline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.5,
        Color = Theme.Outline
    })

    Panel.Inline = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.7,
        Color = Theme.Inline
    })

    Panel.Background = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 0.9,
        Color = Theme.GroupBackground
    })

    Panel.Accent = NewDrawing("Square", {
        Filled = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.AccentColor
    })

    Panel.Title = NewDrawing("Text", {
        Text = "Keybinds",
        Size = 12,
        Font = Drawing.Fonts.SystemBold,
        Outline = true,
        Center = true,
        Visible = false,
        Transparency = 1,
        Color = Theme.PrimaryText
    })
end

LayoutKeybindPanel = function(Window)
    local Panel = Window.KeybindPanel
    if not Panel then return end

    local PanelWidth = Panel.Width or 194
    local HeaderVisible = Library.KeybindSettings.ShowHeader ~= false
    local RowHeight = Library.KeybindSettings.CompactRows ~= false and 18 or 21
    local HeaderHeight = HeaderVisible and 22 or 4
    local BottomPadding = 4
    local PanelHeight = HeaderHeight + #Panel.Rows * RowHeight + BottomPadding
    local LeftPadding = 8
    local RightPadding = 8
    local KeyWidth = 42
    local ModeWidth = 66
    local MetaGap = 4

    Panel.Outline.Position = PixelVector(Panel.Position.X - 1, Panel.Position.Y - 1)
    Panel.Outline.Size = PixelVector(PanelWidth + 2, PanelHeight + 2)
    Panel.Inline.Position = PixelVector(Panel.Position.X, Panel.Position.Y)
    Panel.Inline.Size = PixelVector(PanelWidth, PanelHeight)
    Panel.Background.Position = PixelVector(Panel.Position.X + 1, Panel.Position.Y + 1)
    Panel.Background.Size = PixelVector(PanelWidth - 2, PanelHeight - 2)
    Panel.Accent.Position = PixelVector(Panel.Position.X + 1, Panel.Position.Y + 1)
    Panel.Accent.Size = PixelVector(PanelWidth - 2, 1)

    SetTextSize(Panel.Title, 12)
    Panel.Title.Center = true
    Panel.Title.Position = PixelVector(
        Panel.Position.X + PanelWidth * 0.5,
        TextTop(Panel.Position.Y, 22, 12)
    )

    for Index, Row in ipairs(Panel.Rows) do
        local RowTop = Pixel(Panel.Position.Y + HeaderHeight + (Index - 1) * RowHeight)
        local RowLeft = Pixel(Panel.Position.X + 4)
        local RowWidth = Pixel(PanelWidth - 8)
        local TextY = TextTop(RowTop, RowHeight, 12) + 2
        local ModeLeft = Pixel(Panel.Position.X + PanelWidth - RightPadding - ModeWidth)
        local KeyLeft = Pixel(ModeLeft - MetaGap - KeyWidth)
        local NameLeft = Pixel(Panel.Position.X + LeftPadding)
        local NameWidth = Max(1, KeyLeft - MetaGap - NameLeft)

        Row.Background.Position = PixelVector(RowLeft, RowTop)
        Row.Background.Size = PixelVector(RowWidth, RowHeight)
        Row.ActiveBar.Position = PixelVector(RowLeft, RowTop + 2)
        Row.ActiveBar.Size = PixelVector(2, Max(1, RowHeight - 4))

        SetTextFit(Row.Name, Row.Name.Text, NameWidth, 12, 12)
        SetTextFit(Row.Key, Row.Key.Text, KeyWidth, 12, 12)
        SetTextFit(Row.Mode, Row.Mode.Text, ModeWidth, 12, 12)

        Row.Name.Center = false
        Row.Key.Center = true
        Row.Mode.Center = true

        Row.Name.Position = PixelVector(NameLeft, TextY)
        Row.Key.Position = PixelVector(KeyLeft + KeyWidth * 0.5, TextY)
        Row.Mode.Position = PixelVector(ModeLeft + ModeWidth * 0.5, TextY)
    end
end

local function RefreshKeybindPanel(Window)
    EnsureKeybindPanel(Window)

    local Panel = Window.KeybindPanel
    local Desired = {}

    for Order, Bind in ipairs(Window.Binds) do
        if Bind.Key > 0 and Bind.Control then
            local Active = Bind.Mode == "Always" or Bind.Control.Value == true
            if Library.KeybindSettings.ShowInactive ~= false or Active then
                Insert(Desired, {
                    Bind = Bind,
                    Active = Active,
                    Order = Order
                })
            end
        end
    end

    while #Panel.Rows < #Desired do
        local Row = {
            Active = false,
            Background = NewDrawing("Square", {
                Filled = true,
                Visible = false,
                Transparency = 0.10,
                Color = Window.Theme.AccentColor
            }),
            ActiveBar = NewDrawing("Square", {
                Filled = true,
                Visible = false,
                Transparency = 1,
                Color = Window.Theme.AccentColor
            }),
            Name = NewDrawing("Text", {
                Text = "",
                Size = 12,
                Font = Drawing.Fonts.SystemBold,
                Outline = true,
                Center = false,
                Visible = false,
                Transparency = 1,
                Color = Window.Theme.SecondaryText
            }),
            Key = NewDrawing("Text", {
                Text = "",
                Size = 12,
                Font = Drawing.Fonts.System,
                Outline = true,
                Center = true,
                Visible = false,
                Transparency = 1,
                Color = Window.Theme.SecondaryText
            }),
            Mode = NewDrawing("Text", {
                Text = "",
                Size = 12,
                Font = Drawing.Fonts.System,
                Outline = true,
                Center = true,
                Visible = false,
                Transparency = 1,
                Color = Window.Theme.SecondaryText
            })
        }

        Insert(Panel.Rows, Row)
    end

    while #Panel.Rows > #Desired do
        local Row = Panel.Rows[#Panel.Rows]
        RemoveDrawing(Row.Background)
        RemoveDrawing(Row.ActiveBar)
        RemoveDrawing(Row.Name)
        RemoveDrawing(Row.Key)
        RemoveDrawing(Row.Mode)
        Remove(Panel.Rows, #Panel.Rows)
    end

    local DesiredWidth = 194
    local FixedMetaWidth = 8 + 42 + 4 + 66 + 8

    for Index, Entry in ipairs(Desired) do
        local Bind = Entry.Bind
        local Row = Panel.Rows[Index]
        local Active = Entry.Active
        local ModeText

        if Bind.Mode == "Always" then
            ModeText = "Always"
        elseif Bind.Mode == "Hold" then
            ModeText = Active and "Holded" or "Hold"
        else
            ModeText = Active and "Toggled" or "Toggle"
        end

        local NameText = CleanKeybindDisplayName(Bind.Control.Name)
        local NameWidth = TextWidth(NameText, 12)

        DesiredWidth = Max(DesiredWidth, Pixel(NameWidth + FixedMetaWidth + 12))

        Row.Active = Active
        Row.Order = Entry.Order
        Row.Name.Text = NameText
        Row.Key.Text = "[" .. GetKeyName(Bind.Key) .. "]"
        Row.Mode.Text = "[" .. ModeText .. "]"
        Row.Background.Color = Window.Theme.AccentColor
        Row.Background.Transparency = 0.10
        Row.ActiveBar.Color = Window.Theme.AccentColor
        Row.Name.Color = Active and Window.Theme.PrimaryText or Window.Theme.SecondaryText
        Row.Key.Color = Active and Window.Theme.PrimaryText or Window.Theme.SecondaryText
        Row.Mode.Color = Active and (Library.KeybindSettings.AccentActive ~= false and Window.Theme.AccentColor or Window.Theme.PrimaryText) or Window.Theme.SecondaryText
    end

    Panel.Width = Clamp(DesiredWidth, 194, 360)
    LayoutKeybindPanel(Window)

    local Visible = Window.ShowKeybinds == true
    local HeaderVisible = Library.KeybindSettings.ShowHeader ~= false
    Panel.Outline.Visible = Visible
    Panel.Inline.Visible = Visible
    Panel.Background.Visible = Visible
    Panel.Accent.Visible = false
    Panel.Title.Visible = Visible and HeaderVisible

    for _, Row in ipairs(Panel.Rows) do
        Row.Name.Visible = Visible
        Row.Key.Visible = Visible
        Row.Mode.Visible = Visible
        Row.Background.Visible = Visible and Row.Active and Library.KeybindSettings.AccentActive ~= false
        Row.ActiveBar.Visible = false
    end
end

local function ProcessBind(Bind)
    local Control = Bind.Control

    if not Control or Control.Type ~= "Toggle" then
        return
    end

    if Bind.Mode == "Always" then
        if not Control.Value then
            Control:SetValue(true)
        end

        Bind.Held = true
        Bind.WasPressed = Bind.Key > 0 and iskeypressed(Bind.Key) or false
        return
    end

    if Bind.Key <= 0 then
        Bind.Held = false
        Bind.WasPressed = false
        return
    end

    local Pressed = iskeypressed(Bind.Key)

    if Bind.Mode == "Hold" then
        if Control.Value ~= Pressed then
            Control:SetValue(Pressed)
        end

        Bind.Held = Pressed
        Bind.WasPressed = Pressed
        return
    end

    if Pressed and not Bind.WasPressed then
        Control:SetValue(not Control.Value)
    end

    Bind.Held = Pressed
    Bind.WasPressed = Pressed
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

function WindowMethods:GetPosition()
    return self.Position
end

function WindowMethods:SetPosition(Value)
    if TypeOf(Value) ~= "Vector2" then return self end
    self.Position = PixelVector(Value.X, Value.Y)
    RefreshLayout(self)
    return self
end

function WindowMethods:GetSize()
    return self.Size
end

function WindowMethods:SetSize(Value)
    if TypeOf(Value) ~= "Vector2" then return self end

    self.Size = NewVector2(
        Max(self.MinimumSize.X, Pixel(Value.X)),
        Max(self.MinimumSize.Y, Pixel(Value.Y))
    )

    FitWindowHeight(self, self.ActiveTab)
    RefreshLayout(self)
    ApplyVisibility(self)
    return self
end

function WindowMethods:GetMenuKey()
    return self.MenuKey
end

function WindowMethods:SetMenuKey(Value)
    self.MenuKey = GetKeyCode(Value)
    return self
end

function WindowMethods:GetKeybindListVisible()
    return self.ShowKeybinds
end

function WindowMethods:SetKeybindListVisible(State)
    self.ShowKeybinds = State == true
    ApplyVisibility(self)
    return self
end

function WindowMethods:GetTitle()
    return self.Title
end

function WindowMethods:SetTitle(Value)
    self.Title = tostring(Value or "")
    self.TitleText.Text = Upper(self.Title)
    RefreshLayout(self)
    return self
end

function WindowMethods:GetTab(Name)
    Name = tostring(Name or "")
    for _, Tab in ipairs(self.Tabs) do
        if Tab.Name == Name then return Tab end
    end
    return nil
end

function WindowMethods:Refresh()
    FitWindowHeight(self, self.ActiveTab)
    RefreshLayout(self)
    ApplyVisibility(self)
    return self
end

function TabMethods:GetSection(Name)
    Name = tostring(Name or "")
    for _, Section in ipairs(self.Sections) do
        if Section.Name == Name then return Section end
    end
    return nil
end

function SectionMethods:GetControl(Name)
    Name = tostring(Name or "")
    for _, Control in ipairs(self.Controls) do
        if Control.Name == Name then return Control end
    end
    return nil
end

local function SetApiControlVisible(Control, State)
    Control.Visible = State ~= false
    FitWindowHeight(Control.Window, Control.Window.ActiveTab)
    RefreshLayout(Control.Window)
    ApplyVisibility(Control.Window)
    return Control
end

ToggleMethods.SetVisible = SetApiControlVisible
SliderMethods.SetVisible = SetApiControlVisible
DropdownMethods.SetVisible = SetApiControlVisible
ColorMethods.SetVisible = SetApiControlVisible
KeybindMethods.SetVisible = SetApiControlVisible
LabelMethods.SetVisible = SetApiControlVisible

function WindowMethods:SaveConfig(Name)
    if Type(writefile) ~= "function" then return false end

    local Data = {
        Theme = self.ThemeName,
        Controls = {},
        Binds = {}
    }

    for Index, Control in ipairs(self.Controls) do
        if Control.Type ~= "Button" and Control.Type ~= "Label" then
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

    local EncodeOk, Encoded = pcall(function()
        return HttpService:JSONEncode(Data)
    end)

    if not EncodeOk or Type(Encoded) ~= "string" then return false end

    local WriteOk = pcall(function()
        writefile(Path, Encoded)
    end)

    return WriteOk == true
end

function WindowMethods:LoadConfig(Name)
    if Type(isfile) ~= "function" or Type(readfile) ~= "function" then return false end

    local ConfigName = SafeName(Name or self.ConfigName)
    local Path = self.ConfigFolder .. "/" .. ConfigName .. ".json"
    if not isfile(Path) then return false end

    local ReadOk, Raw = pcall(function()
        return readfile(Path)
    end)

    if not ReadOk or Type(Raw) ~= "string" then return false end

    local DecodeOk, Data = pcall(function()
        return HttpService:JSONDecode(Raw)
    end)

    if not DecodeOk or Type(Data) ~= "table" then return false end

    if Type(Data.Theme) == "string" and Themes[Data.Theme] then
        Library:SetTheme(Data.Theme)
    end

    if Type(Data.Controls) == "table" then
        for Index, Control in ipairs(self.Controls) do
            local Value = Data.Controls[tostring(Index)]

            if Value ~= nil and Control.Type ~= "Button" and Control.Type ~= "Label" then
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
    CloseBindMenu(self)
    self.ActiveSlider = nil
    ApplyVisibility(self)
end

function WindowMethods:SetOpen(State)
    self.Open = State == true
    CloseDropdown(self)
    ClosePicker(self)
    CloseBindMenu(self)
    self.ActiveSlider = nil
    ApplyVisibility(self)
end

function WindowMethods:Unload()
    if not self.Active then return end

    self.Active = false
    CloseDropdown(self)
    ClosePicker(self)
    CloseBindMenu(self)

    for Index = #Library.Windows, 1, -1 do
        if Library.Windows[Index] == self then
            Remove(Library.Windows, Index)
            break
        end
    end

    local function Drop(Object)
        if Object then
            RemoveDrawing(Object)
        end
    end

    Drop(self.MainOutline)
    Drop(self.MainBackground)
    Drop(self.Sidebar)
    Drop(self.SidebarDivider)
    Drop(self.AccentLine)
    Drop(self.TitleText)

    for _, Corner in pairs(self.ResizeCorners or {}) do
        Drop(Corner.Horizontal)
        Drop(Corner.Vertical)
    end

    for _, Tab in ipairs(self.Tabs or {}) do
        Drop(Tab.Text)
        Drop(Tab.Indicator)

        for _, Section in ipairs(Tab.Sections or {}) do
            Drop(Section.Outline)
            Drop(Section.Background)
            Drop(Section.TitleBackground)
            Drop(Section.TitleText)

            for _, Control in ipairs(Section.Controls or {}) do
                for _, Object in pairs(Control.Drawings or {}) do
                    if TypeOf(Object) == "Drawing" then
                        Drop(Object)
                    end
                end

                if Control.Bind then
                    Drop(Control.Bind.Outline)
                    Drop(Control.Bind.Inline)
                    Drop(Control.Bind.Text)
                end

                if Control.AttachedColor then
                    Drop(Control.AttachedColor.Outline)
                    Drop(Control.AttachedColor.Fill)
                end
            end
        end
    end

    local Panel = self.KeybindPanel
    if Panel then
        Drop(Panel.Outline)
        Drop(Panel.Inline)
        Drop(Panel.Background)
        Drop(Panel.Accent)
        Drop(Panel.Title)

        for _, Row in ipairs(Panel.Rows or {}) do
            Drop(Row.Background)
            Drop(Row.ActiveBar)
            Drop(Row.Name)
            Drop(Row.Key)
            Drop(Row.Mode)
        end
    end

    if #Library.Windows == 0 then
        _G.LibraryToken = (_G.LibraryToken or 0) + 1

        while #Drawings > 0 do
            Drop(Drawings[#Drawings])
        end
    end
end

function WindowMethods:AddSettingsTab()
    if self.SettingsTab then return self.SettingsTab end

    local Tab = self:Tab("Settings")
    self.SettingsTab = Tab

    local Appearance = Tab:Section("Menu", "Left")
    Appearance:Dropdown("Theme", self.ThemeName, ThemeNames, false, function(Value)
        Library:SetTheme(Value)
    end)

    Appearance:Toggle("Keybinds", self.ShowKeybinds, function(State)
        self.ShowKeybinds = State
        ApplyVisibility(self)
    end)

    Appearance:Keybind("Menu Key", self.MenuKey, function(Code)
        self.MenuKey = Code
    end)

    local Config = Tab:Section("Configs", "Right")

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

    while self.Active and _G.LibraryToken == Token do
        Wait()

        local MousePosition = NewVector2(Mouse.X, Mouse.Y)
        local MousePressed = ismouse1pressed()
        local MouseDown = MousePressed and not self.LastMouse
        local Mouse2Pressed = Type(ismouse2pressed) == "function" and ismouse2pressed() or false
        local Mouse2Down = Mouse2Pressed and not self.LastMouse2

        if self.Capturing then
            local Code, Captured = FindPressedBindKey()

            if Captured then
                if self.Capturing.Control then
                    self.Capturing:SetKey(Code)
                else
                    self.Capturing:SetValue(Code)
                end

                self.Capturing = nil
                self.KeyHeld = Code > 0 and iskeypressed(Code) or false
            else
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

        if Mouse2Down then
            local BindFound = nil

            if self.Open and self.ActiveTab then
                for _, Section in ipairs(self.ActiveTab.Sections) do
                    for _, Control in ipairs(Section.Controls) do
                        if Control.Visible and Control.LayoutVisible ~= false and Control.Bind and PointIn(Control.Bind.HitPosition, Control.Bind.HitSize, MousePosition) then
                            BindFound = Control.Bind
                            break
                        end
                    end

                    if BindFound then break end
                end
            end

            if BindFound then
                if self.OpenBindMenu and self.OpenBindMenu.Bind == BindFound then
                    CloseBindMenu(self)
                else
                    CreateBindMenu(self, BindFound)
                end
            else
                CloseBindMenu(self)
            end
        end

        if MouseDown then
            local Used = false

            if self.OpenBindMenu then
                local Menu = self.OpenBindMenu

                for _, Entry in ipairs(Menu.Entries) do
                    if PointIn(Entry.Position, Entry.Size, MousePosition) then
                        Menu.Bind:SetMode(Entry.Mode)
                        CloseBindMenu(self)
                        Used = true
                        break
                    end
                end

                if not Used and self.OpenBindMenu then
                    if PointIn(Menu.Position, Menu.Size, MousePosition) then
                        Used = true
                    elseif not PointIn(Menu.Bind.HitPosition, Menu.Bind.HitSize, MousePosition) then
                        CloseBindMenu(self)
                    end
                end
            end

            if not Used and self.ShowKeybinds and self.KeybindPanel then
                local Panel = self.KeybindPanel

                if PointIn(Panel.Position, NewVector2(Panel.Width or Layout.PanelWidth, Library.KeybindSettings.ShowHeader ~= false and 23 or 12), MousePosition) then
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
                            SetTextFit(Dropdown.Drawings.Label, DropdownText(Dropdown), Max(1, Dropdown.HitSize.X - 30), 13, 10)

                            if Dropdown.Callback then
                                Dropdown.Callback(Dropdown:GetValue())
                            end

                            CreateDropdown(self, Dropdown)
                        else
                            Dropdown.Value = Entry.Option
                            SetTextFit(Dropdown.Drawings.Label, DropdownText(Dropdown), Max(1, Dropdown.HitSize.X - 30), 13, 10)

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
                    local Position = self.OpenDropdown.PopupPosition
                    local Size = self.OpenDropdown.PopupSize

                    if Position and Size and not PointIn(Position, Size, MousePosition) and not PointIn(self.OpenDropdown.HitPosition, self.OpenDropdown.HitSize, MousePosition) then
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
                            if Control.Visible and Control.LayoutVisible ~= false then
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

            if self.ActiveTab then
                FitWindowHeight(self, self.ActiveTab)
            end

            RefreshLayout(self)
            ApplyVisibility(self)
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
                    if Control.Visible and Control.LayoutVisible ~= false then
                        local Hover = PointIn(Control.HitPosition, Control.HitSize, MousePosition)

                        if Control.Type == "Toggle" then
                            local Target = Control.Value and Theme.AccentColor or Theme.ToggleBackground
                            Control.CurrentFill = LerpColor(Control.CurrentFill, Target, 0.22)
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

                            local BindText = self.Capturing == Control.Bind and "[..]" or "[" .. GetKeyName(Control.Bind.Key) .. "]"
                            SetTextFit(Control.Bind.Text, BindText, Max(1, (Control.Bind.HitSize and Control.Bind.HitSize.X or 8) - 8), CONTROL_TEXT_SIZE, CONTROL_TEXT_SIZE)
                        end
                        if Control.Type == "Dropdown" then
                            Control.Drawings.State.Text = self.OpenDropdown == Control and "-" or "+"
                            SetTextFit(Control.Drawings.Label, DropdownText(Control), Max(1, (Control.HitSize and Control.HitSize.X or 30) - 30), CONTROL_TEXT_SIZE, CONTROL_TEXT_SIZE)
                        elseif Control.Type == "Keybind" then
                            local KeybindText = self.Capturing == Control and Control.Name .. " [ ... ]" or Control.Name .. " [" .. GetKeyName(Control.Value) .. "]"
                            SetTextFit(Control.Drawings.Label, KeybindText, Max(1, (Control.HitSize and Control.HitSize.X or 10) - 10), CONTROL_TEXT_SIZE, CONTROL_TEXT_SIZE)
                        end
                    end
                end
            end
        end

        RefreshKeybindPanel(self)
        self.LastMouse = MousePressed
        self.LastMouse2 = Mouse2Pressed
    end
end

_G.NightfallLibrary = Library
_G.Library = Library
return Library
