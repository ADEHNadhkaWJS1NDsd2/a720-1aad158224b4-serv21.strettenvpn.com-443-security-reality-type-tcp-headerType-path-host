local Game = game
local Type = type
local TypeOf = typeof
local ToString = tostring
local ToNumber = tonumber

local Clock = os.clock
local Tick = Type(tick) == "function" and tick or Clock
local GetService = Game.GetService
local HttpGet = httpget

local NewVector2 = Vector2.new
local NewVector3 = Vector3.new
local NewRGB = Color3.fromRGB
local NewColor3 = Color3.new

local EmptyVector3 = Vector3.zero

local Clamp = math.clamp
local Max = math.max
local Min = math.min
local Floor = math.floor
local Ceil = math.ceil
local Pow = math.pow
local Sin = math.sin
local Pi = math.pi
local Random = math.random
local Infinite = math.huge

local Spawn = spawn
local Wait = task.wait

local Insert = table.insert
local Remove = table.remove
local Clear = table.clear

local StringFind = string.find
local Sub = string.sub

local GetPing = GetPingValue
local Project = WorldToScreen
local ReadMemory = memory_read
local WriteMemory = memory_write


local RunService = GetService(Game, "RunService")
local Players = GetService(Game, "Players")
local Workspace = GetService(Game, "Workspace")


local Stepped = RunService.Stepped
local Heartbeat = RunService.Heartbeat
local RenderStepped = RunService.RenderStepped

local LocalPlayer = Players.LocalPlayer

local Click = mouse1click
local KeyPress = keypress
local KeyRelease = keyrelease


if Game.GameId ~= 4777817887 then return end

if _G.NightfallDrawings then
    for _, Drawing in pairs(_G.NightfallDrawings) do
        if Drawing and Type(Drawing.Remove) == "function" then
            Drawing:Remove()
        end
    end
end

_G.NightfallDrawings = {}

if not LocalPlayer then
    for _ = 1, 200 do
        Wait(0.05)
        LocalPlayer = Players.LocalPlayer
        if LocalPlayer then break end
    end
end

if not LocalPlayer then return end


local Shared = {}
local Combat = {}
local Visuals = {
    RangeLines = {},
    TrailPoints = {},
    TrailLines = {},
    Esp = {}
}


function Shared.IsValidNumber(Number)
    return Type(Number) == "number" and Number == Number and Number ~= Infinite and Number ~= -Infinite
end

function Shared.IsValidVector3(Vector)
    return TypeOf(Vector) == "Vector3"
        and Shared.IsValidNumber(Vector.X)
        and Shared.IsValidNumber(Vector.Y)
        and Shared.IsValidNumber(Vector.Z)
end

function Shared.IsValidVector2(Vector)
    return TypeOf(Vector) == "Vector2"
        and Shared.IsValidNumber(Vector.X)
        and Shared.IsValidNumber(Vector.Y)
end

function Shared.IsInstance(Object)
    return Object ~= nil and TypeOf(Object) == "Instance"
end

function Shared.GetName(Object)
    if not Shared.IsInstance(Object) then return nil end
    local Name = Object.Name
    if Name == nil then return nil end
    return ToString(Name)
end

function Shared.GetParent(Object)
    if not Shared.IsInstance(Object) then return nil end
    local Parent = Object.Parent
    if not Shared.IsInstance(Parent) then return nil end
    return Parent
end

function Shared.GetCharacter(Player)
    if not Shared.IsInstance(Player) then return nil end
    local Character = Player.Character
    if not Shared.IsInstance(Character) then return nil end
    return Character
end


function Shared.GetAttribute(Object, Name)
    if not Shared.IsInstance(Object) or Name == nil then return nil end
    return Object:GetAttribute(ToString(Name))
end

function Shared.Disconnect(Connection)
    if Connection == nil then return end
    local Kind = Type(Connection)
    if Kind ~= "table" and Kind ~= "userdata" then return end
    local Disconnect = Connection.Disconnect
    if Type(Disconnect) == "function" then
        Connection:Disconnect()
    end
end

function Shared.GetPartPosition(Part)
    if not Part or TypeOf(Part) ~= "Instance" or not Part:IsA("BasePart") then
        return nil
    end

    local Position = Part.Position
    if not Shared.IsValidVector3(Position) then
        return nil
    end

    return Position
end

function Shared.GetPartSize(Part)
    if not Part or TypeOf(Part) ~= "Instance" or not Part:IsA("BasePart") then
        return nil
    end

    local Size = Part.Size
    if not Shared.IsValidVector3(Size) then
        return nil
    end

    return Size
end

local Library
local LibraryUrl = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/Balls1.lua"

local function ReplaceLibraryPart(Source, Old, New)
    local Start, Finish = string.find(Source, Old, 1, true)
    if not Start then return Source end
    return string.sub(Source, 1, Start - 1) .. New .. string.sub(Source, Finish + 1)
end

local function PatchLibrarySource(Source)
    Source = ReplaceLibraryPart(Source, [[local function RoundValue(Value, Step)
    if Type(Step) ~= "number" or Step <= 0 then return Value end
    return Floor(Value / Step + 0.5) * Step
end]], [[local function SliderDecimals(Step)
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
    return Floor(Rounded * Scale + 0.5) / Scale
end

local function FormatSliderValue(Value, Step)
    local Decimals = SliderDecimals(Step)

    if Decimals <= 0 then
        return tostring(Floor(Value + 0.5))
    end

    local Text = Format("%." .. tostring(Decimals) .. "f", Value)
    Text = string.gsub(Text, "0+$", "")
    Text = string.gsub(Text, "%.$", "")
    return Text
end]])

    Source = ReplaceLibraryPart(Source, [[local Layout = {
    SidebarWidth = 130,
    OuterPadding = 15,
    ColumnGap = 15,
    SectionGap = 14,
    ControlPadding = 15,
    TabTop = 80,
    TabHeight = 24,
    TabStep = 30,
    PanelWidth = 180
}]], [[local Layout = {
    SidebarWidth = 130,
    OuterPadding = 15,
    ColumnGap = 15,
    SectionGap = 14,
    ControlPadding = 15,
    TabTop = 80,
    TabHeight = 24,
    TabStep = 30,
    PanelWidth = 180
}

local function GetTabRequiredHeight(Window, Tab)
    if not Tab then
        return Max(Window.MinimumSize.Y, Window.BaseHeight or Window.Size.Y)
    end

    local LeftHeight = 20
    local RightHeight = 20
    local LeftCount = 0
    local RightCount = 0

    for _, Section in ipairs(Tab.Sections) do
        local Height = GetSectionHeight(Section)

        if Section.Side == "Right" then
            RightHeight = RightHeight + Height + Layout.SectionGap
            RightCount = RightCount + 1
        else
            LeftHeight = LeftHeight + Height + Layout.SectionGap
            LeftCount = LeftCount + 1
        end
    end

    if LeftCount > 0 then LeftHeight = LeftHeight - Layout.SectionGap end
    if RightCount > 0 then RightHeight = RightHeight - Layout.SectionGap end

    return Max(
        Window.MinimumSize.Y,
        Window.BaseHeight or Window.Size.Y,
        Max(LeftHeight, RightHeight) + 15
    )
end

local function FitWindowHeight(Window, Tab)
    if not Window.AutoHeight then return end
    Window.Size = NewVector2(Window.Size.X, GetTabRequiredHeight(Window, Tab))
end]])

    Source = ReplaceLibraryPart(
        Source,
        "Control.Drawings.Value.Position = NewVector2(X0 + ControlWidth - 28, ControlY)",
        [[local ValueWidth = Max(28, #Control.Drawings.Value.Text * 7)
                        Control.Drawings.Value.Position = NewVector2(X0 + ControlWidth - Floor(ValueWidth / 2), ControlY)]]
    )

    Source = ReplaceLibraryPart(
        Source,
        "Text = tostring(Control.Value) .. Control.Suffix,",
        "Text = FormatSliderValue(Control.Value, Control.Step) .. Control.Suffix,"
    )

    Source = ReplaceLibraryPart(
        Source,
        "self.Drawings.Value.Text = tostring(Value) .. self.Suffix",
        "self.Drawings.Value.Text = FormatSliderValue(Value, self.Step) .. self.Suffix"
    )

    Source = ReplaceLibraryPart(Source, [[    }, {__index = WindowMethods})

    if Window.Size.X < Window.MinimumSize.X then]], [[    }, {__index = WindowMethods})

    Window.BaseHeight = Window.Size.Y
    Window.AutoHeight = Options.autoHeight ~= false

    if Window.Size.X < Window.MinimumSize.X then]])

    Source = ReplaceLibraryPart(Source, [[    Window.ActiveTab = Tab
    CloseDropdown(Window)
    ClosePicker(Window)
    RefreshLayout(Window)]], [[    Window.ActiveTab = Tab
    CloseDropdown(Window)
    ClosePicker(Window)
    FitWindowHeight(Window, Tab)
    RefreshLayout(Window)]])

    Source = ReplaceLibraryPart(Source, [[    Insert(Section.Controls, Control)
    Insert(Section.Window.Controls, Control)
    RefreshLayout(Section.Window)]], [[    Insert(Section.Controls, Control)
    Insert(Section.Window.Controls, Control)

    if Section.Window.ActiveTab == Section.Tab then
        FitWindowHeight(Section.Window, Section.Tab)
    end

    RefreshLayout(Section.Window)]])

    Source = ReplaceLibraryPart(Source, [[local CloseDropdown
local ClosePicker
local ToggleMethods = {}]], [[local CloseDropdown
local ClosePicker
local CloseBindMenu
local ToggleMethods = {}]])

    Source = ReplaceLibraryPart(Source, [[local function FitWindowHeight(Window, Tab)
    if not Window.AutoHeight then return end
    Window.Size = NewVector2(Window.Size.X, GetTabRequiredHeight(Window, Tab))
end]], [[local function FitWindowHeight(Window, Tab)
    if not Window.AutoHeight then return end
    Window.Size = NewVector2(Window.Size.X, GetTabRequiredHeight(Window, Tab))
end

local function TextWidth(Text, Size)
    Text = tostring(Text or "")
    Size = Type(Size) == "number" and Size or 13

    local Width = 0

    for Index = 1, #Text do
        local Character = string.sub(Text, Index, Index)
        local Factor = 0.54

        if Character == " " then
            Factor = 0.30
        elseif string.find("ilI1|!.,:;'`", Character, 1, true) then
            Factor = 0.28
        elseif string.find("MW@%#QO", Character, 1, true) then
            Factor = 0.82
        elseif Character == "[" or Character == "]" or Character == "(" or Character == ")" then
            Factor = 0.36
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
    MinimumSize = Type(MinimumSize) == "number" and MinimumSize or Max(9, PreferredSize - 3)
    MaxWidth = Max(0, Type(MaxWidth) == "number" and MaxWidth or 0)

    local Size = PreferredSize

    while Size > MinimumSize and TextWidth(Text, Size) > MaxWidth do
        Size = Size - 1
    end

    Object.Size = Size
    Object.Text = FitText(Text, MaxWidth, Size)
end]])

    Source = ReplaceLibraryPart(Source, [[    for Index, Tab in ipairs(Window.Tabs) do
        local Y = Layout.TabTop + (Index - 1) * Layout.TabStep
        Tab.Text.Position = Position + NewVector2(25, Y)
        Tab.Indicator.Position = Position + NewVector2(1, Y + 1)
        Tab.Indicator.Size = NewVector2(2, 12)
        Tab.HitPosition = Position + NewVector2(12, Y - 5)
        Tab.HitSize = NewVector2(SidebarWidth - 18, Layout.TabHeight)
    end]], [[    for Index, Tab in ipairs(Window.Tabs) do
        local Y = Layout.TabTop + (Index - 1) * Layout.TabStep
        SetTextFit(Tab.Text, Tab.Name, SidebarWidth - 38, 14, 10)
        Tab.Text.Position = Position + NewVector2(25, Y)
        Tab.Indicator.Position = Position + NewVector2(1, Y + 1)
        Tab.Indicator.Size = NewVector2(2, 12)
        Tab.HitPosition = Position + NewVector2(12, Y - 5)
        Tab.HitSize = NewVector2(SidebarWidth - 18, Layout.TabHeight)
    end]])

    Source = ReplaceLibraryPart(Source, [[            local TitleWidth = Min(Width - 24, Max(48, #Section.Name * 7 + 10))
            Section.TitleBackground.Position = Section.Position + NewVector2(10, -2)
            Section.TitleBackground.Size = NewVector2(Max(1, TitleWidth), 4)
            Section.TitleText.Position = Section.Position + NewVector2(14, -6)]], [[            local TitleWidth = Min(Width - 24, Max(48, Pixel(TextWidth(Section.Name, 13) + 10)))
            Section.TitleBackground.Position = Section.Position + NewVector2(10, -2)
            Section.TitleBackground.Size = NewVector2(Max(1, TitleWidth), 4)
            SetTextFit(Section.TitleText, Section.Name, Max(1, Width - 30), 13, 10)
            Section.TitleText.Position = Section.Position + NewVector2(14, -6)]])

    Source = ReplaceLibraryPart(Source, [[                    if Control.Type == "Toggle" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(12, 12)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(10, 10)
                        Control.Drawings.Fill.Position = NewVector2(X0 + 2, ControlY + 2)
                        Control.Drawings.Fill.Size = NewVector2(8, 8)
                        Control.Drawings.Label.Position = NewVector2(X0 + 20, ControlY - 1)

                        Control.HitPosition = NewVector2(X0, ControlY - 4)
                        Control.HitSize = NewVector2(ControlWidth, 20)

                        local Right = X0 + ControlWidth

                        if Control.Bind then
                            local BindWidth = 46
                            Control.Bind.HitPosition = NewVector2(Right - BindWidth, ControlY - 2)
                            Control.Bind.HitSize = NewVector2(BindWidth, 16)
                            Control.Bind.Outline.Position = Control.Bind.HitPosition
                            Control.Bind.Outline.Size = Control.Bind.HitSize
                            Control.Bind.Inline.Position = Control.Bind.HitPosition + NewVector2(1, 1)
                            Control.Bind.Inline.Size = Control.Bind.HitSize - NewVector2(2, 2)
                            Control.Bind.Text.Position = Control.Bind.HitPosition + NewVector2(Floor(BindWidth / 2), 5)
                            Right = Right - BindWidth - 7
                        end

                        if Control.AttachedColor then
                            local PickerWidth = 24
                            Control.AttachedColor.HitPosition = NewVector2(Right - PickerWidth, ControlY - 1)
                            Control.AttachedColor.HitSize = NewVector2(PickerWidth, 14)
                            Control.AttachedColor.Outline.Position = Control.AttachedColor.HitPosition
                            Control.AttachedColor.Outline.Size = Control.AttachedColor.HitSize
                            Control.AttachedColor.Fill.Position = Control.AttachedColor.HitPosition + NewVector2(1, 1)
                            Control.AttachedColor.Fill.Size = Control.AttachedColor.HitSize - NewVector2(2, 2)
                        end]], [[                    if Control.Type == "Toggle" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(12, 12)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(10, 10)
                        Control.Drawings.Fill.Position = NewVector2(X0 + 2, ControlY + 2)
                        Control.Drawings.Fill.Size = NewVector2(8, 8)
                        Control.Drawings.Label.Position = NewVector2(X0 + 20, ControlY - 1)

                        Control.HitPosition = NewVector2(X0, ControlY - 4)
                        Control.HitSize = NewVector2(ControlWidth, 20)

                        local Right = X0 + ControlWidth

                        if Control.Bind then
                            local BindText = "[" .. GetKeyName(Control.Bind.Key) .. "]"
                            local BindWidth = Clamp(Pixel(TextWidth(BindText, 12) + 12), 42, Min(78, ControlWidth))
                            Control.Bind.HitPosition = NewVector2(Right - BindWidth, ControlY - 2)
                            Control.Bind.HitSize = NewVector2(BindWidth, 16)
                            Control.Bind.Outline.Position = Control.Bind.HitPosition
                            Control.Bind.Outline.Size = Control.Bind.HitSize
                            Control.Bind.Inline.Position = Control.Bind.HitPosition + NewVector2(1, 1)
                            Control.Bind.Inline.Size = Control.Bind.HitSize - NewVector2(2, 2)
                            SetTextFit(Control.Bind.Text, BindText, Max(1, BindWidth - 8), 12, 9)
                            Control.Bind.Text.Position = Control.Bind.HitPosition + NewVector2(Floor(BindWidth / 2), 3)
                            Right = Right - BindWidth - 7
                        end

                        if Control.AttachedColor then
                            local PickerWidth = 24
                            Control.AttachedColor.HitPosition = NewVector2(Right - PickerWidth, ControlY - 1)
                            Control.AttachedColor.HitSize = NewVector2(PickerWidth, 14)
                            Control.AttachedColor.Outline.Position = Control.AttachedColor.HitPosition
                            Control.AttachedColor.Outline.Size = Control.AttachedColor.HitSize
                            Control.AttachedColor.Fill.Position = Control.AttachedColor.HitPosition + NewVector2(1, 1)
                            Control.AttachedColor.Fill.Size = Control.AttachedColor.HitSize - NewVector2(2, 2)
                            Right = Right - PickerWidth - 7
                        end

                        SetTextFit(Control.Drawings.Label, Control.Name, Max(1, Right - (X0 + 20) - 4), 13, 10)]])

    Source = ReplaceLibraryPart(Source, [[                    elseif Control.Type == "Slider" then
                        Control.Drawings.Label.Position = NewVector2(X0, ControlY)
                        local ValueWidth = Max(28, #Control.Drawings.Value.Text * 7)
                        Control.Drawings.Value.Position = NewVector2(X0 + ControlWidth - Floor(ValueWidth / 2), ControlY)
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY + 18)]], [[                    elseif Control.Type == "Slider" then
                        local ValueText = FormatSliderValue(Control.Value, Control.Step) .. Control.Suffix
                        local ValueWidth = Min(Floor(ControlWidth * 0.46), Max(28, Pixel(TextWidth(ValueText, 13) + 6)))
                        local LabelWidth = Max(1, ControlWidth - ValueWidth - 8)

                        SetTextFit(Control.Drawings.Label, Control.Name, LabelWidth, 13, 10)
                        SetTextFit(Control.Drawings.Value, ValueText, Max(1, ValueWidth - 2), 13, 10)
                        Control.Drawings.Label.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Value.Position = NewVector2(X0 + ControlWidth - Floor(ValueWidth / 2), ControlY)
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY + 18)]])

    Source = ReplaceLibraryPart(Source, [[                    elseif Control.Type == "Dropdown" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, 22)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), 20)
                        Control.Drawings.Label.Position = NewVector2(X0 + 8, ControlY + 5)
                        Control.Drawings.State.Position = NewVector2(X0 + ControlWidth - 10, ControlY + 5)]], [[                    elseif Control.Type == "Dropdown" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, 22)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), 20)
                        SetTextFit(Control.Drawings.Label, DropdownText(Control), Max(1, ControlWidth - 30), 13, 10)
                        Control.Drawings.Label.Position = NewVector2(X0 + 8, ControlY + 4)
                        Control.Drawings.State.Position = NewVector2(X0 + ControlWidth - 10, ControlY + 4)]])

    Source = ReplaceLibraryPart(Source, [[                    elseif Control.Type == "Colorpicker" then
                        Control.Drawings.Label.Position = NewVector2(X0, ControlY + 2)
                        Control.Drawings.Outline.Position = NewVector2(X0 + ControlWidth - 46, ControlY)]], [[                    elseif Control.Type == "Colorpicker" then
                        SetTextFit(Control.Drawings.Label, Control.Name, Max(1, ControlWidth - 54), 13, 10)
                        Control.Drawings.Label.Position = NewVector2(X0, ControlY + 2)
                        Control.Drawings.Outline.Position = NewVector2(X0 + ControlWidth - 46, ControlY)]])

    Source = ReplaceLibraryPart(Source, [[                    elseif Control.Type == "Button" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, 22)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), 20)
                        Control.Drawings.Label.Position = NewVector2(X0 + Floor(ControlWidth / 2), ControlY + 5)]], [[                    elseif Control.Type == "Button" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, 22)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), 20)
                        SetTextFit(Control.Drawings.Label, Control.Name, Max(1, ControlWidth - 10), 13, 10)
                        Control.Drawings.Label.Position = NewVector2(X0 + Floor(ControlWidth / 2), ControlY + 4)]])

    Source = ReplaceLibraryPart(Source, [[                    elseif Control.Type == "Keybind" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, 22)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), 20)
                        Control.Drawings.Label.Position = NewVector2(X0 + Floor(ControlWidth / 2), ControlY + 5)]], [[                    elseif Control.Type == "Keybind" then
                        Control.Drawings.Outline.Position = NewVector2(X0, ControlY)
                        Control.Drawings.Outline.Size = NewVector2(ControlWidth, 22)
                        Control.Drawings.Inline.Position = NewVector2(X0 + 1, ControlY + 1)
                        Control.Drawings.Inline.Size = NewVector2(Max(1, ControlWidth - 2), 20)
                        local KeybindText = Control.Name .. " [ " .. GetKeyName(Control.Value) .. " ]"
                        SetTextFit(Control.Drawings.Label, KeybindText, Max(1, ControlWidth - 10), 13, 10)
                        Control.Drawings.Label.Position = NewVector2(X0 + Floor(ControlWidth / 2), ControlY + 4)]])

    Source = ReplaceLibraryPart(Source, [[        for Index, Row in ipairs(Rows) do
            local RowY = 10 + Index * 18
            Row.Name.Position = Panel.Position + NewVector2(10, RowY)
            Row.State.Position = Panel.Position + NewVector2(PanelWidth - 24, RowY)
        end]], [[        for Index, Row in ipairs(Rows) do
            local RowY = 10 + Index * 18
            SetTextFit(Row.Name, Row.Name.Text, Max(1, PanelWidth - 64), 13, 10)
            Row.Name.Position = Panel.Position + NewVector2(10, RowY)
            Row.State.Position = Panel.Position + NewVector2(PanelWidth - 24, RowY)
        end]])

    Source = ReplaceLibraryPart(Source, [[        local Text = NewDrawing("Text", {
            Text = tostring(Option),
            Size = 13,
            Font = Drawing.Fonts.System,
            Outline = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 24,
            Position = NewVector2(Position.X + 12, Y + 4),
            Color = Selected and Theme.PrimaryText or Theme.SecondaryText
        })]], [[        local Text = NewDrawing("Text", {
            Text = FitText(tostring(Option), Max(1, Width - 18), 13),
            Size = 13,
            Font = Drawing.Fonts.System,
            Outline = true,
            Visible = true,
            Transparency = 1,
            ZIndex = 24,
            Position = NewVector2(Position.X + 12, Y + 4),
            Color = Selected and Theme.PrimaryText or Theme.SecondaryText
        })]])

    Source = ReplaceLibraryPart(Source, [[function KeybindMethods:SetMode(Mode)
    if not self.Control then return end
    self.Mode = Mode == "Hold" and "Hold" or Mode == "Always" and "Always" or "Toggle"
end

CloseDropdown = function(Window)]], [[function KeybindMethods:SetMode(Mode)
    if not self.Control then return end
    self.Mode = Mode == "Hold" and "Hold" or Mode == "Always" and "Always" or "Toggle"
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
            Position = NewVector2(Position.X + 10, Y + 3),
            Color = Selected and Theme.PrimaryText or Theme.SecondaryText
        }))

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

CloseDropdown = function(Window)]])

    Source = ReplaceLibraryPart(Source, [[local function CreateDropdown(Window, Control)
    CloseDropdown(Window)
    ClosePicker(Window)]], [[local function CreateDropdown(Window, Control)
    CloseDropdown(Window)
    ClosePicker(Window)
    CloseBindMenu(Window)]])

    Source = ReplaceLibraryPart(Source, [[local function MakePicker(Window, Control)
    ClosePicker(Window)
    CloseDropdown(Window)]], [[local function MakePicker(Window, Control)
    ClosePicker(Window)
    CloseDropdown(Window)
    CloseBindMenu(Window)]])

    Source = ReplaceLibraryPart(Source, [[        OpenDropdown = nil,
        OpenPicker = nil,
        Dragging = false,]], [[        OpenDropdown = nil,
        OpenPicker = nil,
        OpenBindMenu = nil,
        LastMouse2 = false,
        Dragging = false,]])

    Source = ReplaceLibraryPart(Source, [[    Window.ActiveTab = Tab
    CloseDropdown(Window)
    ClosePicker(Window)
    FitWindowHeight(Window, Tab)]], [[    Window.ActiveTab = Tab
    CloseDropdown(Window)
    ClosePicker(Window)
    CloseBindMenu(Window)
    FitWindowHeight(Window, Tab)]])

    Source = ReplaceLibraryPart(Source, [[function WindowMethods:Toggle()
    self.Open = not self.Open
    CloseDropdown(self)
    ClosePicker(self)
    self.ActiveSlider = nil]], [[function WindowMethods:Toggle()
    self.Open = not self.Open
    CloseDropdown(self)
    ClosePicker(self)
    CloseBindMenu(self)
    self.ActiveSlider = nil]])

    Source = ReplaceLibraryPart(Source, [[function WindowMethods:SetOpen(State)
    self.Open = State == true
    CloseDropdown(self)
    ClosePicker(self)
    self.ActiveSlider = nil]], [[function WindowMethods:SetOpen(State)
    self.Open = State == true
    CloseDropdown(self)
    ClosePicker(self)
    CloseBindMenu(self)
    self.ActiveSlider = nil]])

    Source = ReplaceLibraryPart(Source, [[function WindowMethods:Unload()
    self.Active = false
    CloseDropdown(self)
    ClosePicker(self)]], [[function WindowMethods:Unload()
    self.Active = false
    CloseDropdown(self)
    ClosePicker(self)
    CloseBindMenu(self)]])

    Source = ReplaceLibraryPart(Source, [[        local MousePosition = NewVector2(Mouse.X, Mouse.Y)
        local MousePressed = ismouse1pressed()
        local MouseDown = MousePressed and not self.LastMouse]], [[        local MousePosition = NewVector2(Mouse.X, Mouse.Y)
        local MousePressed = ismouse1pressed()
        local MouseDown = MousePressed and not self.LastMouse
        local Mouse2Pressed = Type(ismouse2pressed) == "function" and ismouse2pressed() or false
        local Mouse2Down = Mouse2Pressed and not self.LastMouse2]])

    Source = ReplaceLibraryPart(Source, [[        if self.OpenPicker and MousePressed then
            UpdatePicker(self, MousePosition)
        end

        if MouseDown then]], [[        if self.OpenPicker and MousePressed then
            UpdatePicker(self, MousePosition)
        end

        if Mouse2Down then
            local BindFound = nil

            if self.Open and self.ActiveTab then
                for _, Section in ipairs(self.ActiveTab.Sections) do
                    for _, Control in ipairs(Section.Controls) do
                        if Control.Visible and Control.Bind and PointIn(Control.Bind.HitPosition, Control.Bind.HitSize, MousePosition) then
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

        if MouseDown then]])

    Source = ReplaceLibraryPart(Source, [[        if MouseDown then
            local Used = false

            if self.ShowKeybinds and self.KeybindPanel then]], [[        if MouseDown then
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

            if not Used and self.ShowKeybinds and self.KeybindPanel then]])

    Source = ReplaceLibraryPart(Source, [[                            Dropdown.Value[Entry.Option] = not Dropdown.Value[Entry.Option]
                            Dropdown.Drawings.Label.Text = DropdownText(Dropdown)]], [[                            Dropdown.Value[Entry.Option] = not Dropdown.Value[Entry.Option]
                            SetTextFit(Dropdown.Drawings.Label, DropdownText(Dropdown), Max(1, Dropdown.HitSize.X - 30), 13, 10)]])

    Source = ReplaceLibraryPart(Source, [[                            Dropdown.Value = Entry.Option
                            Dropdown.Drawings.Label.Text = DropdownText(Dropdown)]], [[                            Dropdown.Value = Entry.Option
                            SetTextFit(Dropdown.Drawings.Label, DropdownText(Dropdown), Max(1, Dropdown.HitSize.X - 30), 13, 10)]])

    Source = ReplaceLibraryPart(Source, [[                        if Control.Bind then
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
                        end]], [[                        if Control.Bind then
                            local BindHover = PointIn(Control.Bind.HitPosition, Control.Bind.HitSize, MousePosition)
                            local Target = BindHover and Theme.HoverState or Theme.ToggleBackground
                            Control.Bind.CurrentColor = LerpColor(Control.Bind.CurrentColor, Target, 0.15)
                            Control.Bind.Inline.Color = Control.Bind.CurrentColor

                            local BindText = self.Capturing == Control.Bind and "[..]" or "[" .. GetKeyName(Control.Bind.Key) .. "]"
                            SetTextFit(Control.Bind.Text, BindText, Max(1, Control.Bind.HitSize.X - 8), 12, 9)
                        end
                        if Control.Type == "Dropdown" then
                            Control.Drawings.State.Text = self.OpenDropdown == Control and "-" or "+"
                            SetTextFit(Control.Drawings.Label, DropdownText(Control), Max(1, Control.HitSize.X - 30), 13, 10)
                        elseif Control.Type == "Keybind" then
                            local KeybindText = self.Capturing == Control and Control.Name .. " [ ... ]" or Control.Name .. " [ " .. GetKeyName(Control.Value) .. " ]"
                            SetTextFit(Control.Drawings.Label, KeybindText, Max(1, Control.HitSize.X - 10), 13, 10)
                        end]])

    Source = ReplaceLibraryPart(Source, [[        Row.Name.Text = "[" .. GetKeyName(Bind.Key) .. "] " .. Control.Name

        if Bind.Mode == "Hold" then]], [[        SetTextFit(Row.Name, "[" .. GetKeyName(Bind.Key) .. "] " .. Control.Name, Max(1, Layout.PanelWidth - 64), 13, 10)

        if Bind.Mode == "Hold" then]])

    Source = ReplaceLibraryPart(Source, [[        RefreshKeybindPanel(self)
        self.LastMouse = MousePressed]], [[        RefreshKeybindPanel(self)
        self.LastMouse = MousePressed
        self.LastMouse2 = Mouse2Pressed]])

    return Source
end


for Index = 1, 6 do
    local Cache = "?cb=" .. ToString((Floor(Clock() * 1000) + Index * 7919) % 2000000000)
    local Source = HttpGet(LibraryUrl .. Cache)

    if Type(Source) == "string" and #Source > 1000 then
        Source = PatchLibrarySource(Source)
        _G.Balls1 = nil
        local Chunk = loadstring(Source)

        if Type(Chunk) == "function" then
            Chunk()

            if Type(_G.Balls1) == "table" and Type(_G.Balls1.CreateWindow) == "function" then
                Library = _G.Balls1
                break
            end
        end
    end

    Wait(0.35)
end

if Type(Library) ~= "table" then return end

Library:SetTheme("Nightfall")

local Window = Library:CreateWindow({
    title = "Nightfall",
    subtitle = "Blade Ball",
    size = NewVector2(560, 460),
    autoHeight = true,
    configName = "Nightfall",
    configFolder = "BladeballConfigs",
    menuKey = "F2",
    startOpen = true
})

local Settings = {
    AutoParry = false,
    CooldownProtection = false,
    AutoAbility = false,
    TrainingBalls = false,
    ParryAccuracy = 100,
    AutoSpam = false,
    ParryThreshold = 2.5,
    ManualSpam = false,
    SpamRate = 200,
    TriggerBot = false,
    TriggerDelay = 0,
    TriggerIgnoreSpawn = false,
    ParryRangeEnabled = false,
    ParryRangeColor = NewRGB(220, 30, 30),
    RangeThickness = 2.0,
    RangeTransparency = 1.0,
    RangeSegments = 40,
    AbilityEsp = false,
    EspColor = NewRGB(220, 30, 30),
    EspTextSize = 18,
    EspOffset = 2.0,
    BallTrail = false,
    TrailColor = NewRGB(220, 30, 30),
    TrailLength = 60,
    TrailThickness = 2.0,
    Rainbow = false,
    Wings = false,
    WingsColor = NewRGB(120, 60, 220),
    WingsOutlineColor = NewRGB(185, 125, 255),
    WingsScale = 1.12,
    WingsHeight = 0,
    WingsBackOffset = 0.72,
    WingsSpeed = 1.45,
    WingsFlapStrength = 1,
    WingsSpread = 1,
    WingsFps = 144,
    ChinaHat = false,
    ChinaHatColor = NewRGB(112, 64, 225),
    ChinaHatOutlineColor = NewRGB(190, 135, 255),
    ChinaHatScale = 1,
    ChinaHatHeight = 0,
    ChinaHatRadius = 1.55,
    ChinaHatConeHeight = 1.30,
    ChinaHatGlow = 0.45,
    ChinaHatThickness = 2,
    ChinaHatFps = 144,
    DemonHorns = false,
    DemonHornsColor = NewRGB(120, 60, 220),
    DemonHornsOutlineColor = NewRGB(190, 135, 255),
    DemonHornsScale = 1,
    DemonHornsHeight = 0,
    DemonHornsSpread = 1,
    DemonTail = false,
    DemonTailColor = NewRGB(120, 60, 220),
    DemonTailOutlineColor = NewRGB(190, 135, 255),
    DemonTailScale = 1,
    DemonTailLength = 4.8,
    DemonTailSpeed = 2.4,
    DemonTailStrength = 1,
    InfinityDetection = false,
    FuryDetection = false,
    ParryMethod = "Click",
    Headless = false,
    Korblox = false,
    InfinityDisabledParry = false,
    InfinityDisabledTrigger = false,
    FuryDisabledParry = false,
    FuryDisabledTrigger = false,
    FuryActive = false,
    Orbit = false,
    OrbitRadius = 25,
    OrbitSpeed = 50,
    OrbitHeight = 5
}


local WingsUrl = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/main/wings.luau"
local ChinaHatUrl = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/main/china.luau"
local DemonUrl = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/demon.luau"

local WingsController, ChinaHatController, DemonController
local WingsLoading, ChinaHatLoading, DemonLoading = false, false, false

function Visuals.FetchSource(Url)
    if Type(Url) ~= "string" or Url == "" then return nil end
    local Cache = ToString(Floor(Clock() * 1000000)) .. ToString(Random(100000, 999999))
    local Source = HttpGet(Url .. "?cb=" .. Cache)
    return Type(Source) == "string" and #Source >= 1000 and Source or nil
end

function Visuals.LoadController(Source, Name)
    if Type(Source) ~= "string" or Type(Name) ~= "string" or Type(loadstring) ~= "function" then return nil end

    _G.NightfallExternalController = nil
    local Wrapped = "_G.NightfallExternalController = (function()\n" .. Source .. "\nend)()"
    local Chunk = loadstring(Wrapped)
    if Type(Chunk) ~= "function" then return nil end
    Chunk()

    local Controller = _G.NightfallExternalController or _G[Name]
    _G.NightfallExternalController = nil
    if Type(Controller) ~= "table" then return nil end

    _G[Name] = Controller
    return Controller
end

function Visuals.GetWingsController()
    local Controller = WingsController or _G.NightfallWingsController
    if Type(Controller) ~= "table" or Controller.Running == false or Controller.Version ~= 4 then WingsController = nil return nil end

    local Methods = {"SetEnabled", "SetColor", "SetOutlineColor", "SetScale", "SetHeight", "SetBackOffset", "SetSwingSpeed", "SetFlapStrength", "SetSpread", "SetFps"}
    for Index = 1, #Methods do
        if Type(Controller[Methods[Index]]) ~= "function" then WingsController = nil return nil end
    end

    WingsController = Controller
    return Controller
end

function Visuals.ApplyWings()
    local Controller = Visuals.GetWingsController()
    if not Controller then return end

    Controller:SetColor(Settings.WingsColor)
    Controller:SetOutlineColor(Settings.WingsOutlineColor)
    Controller:SetScale(Settings.WingsScale)
    Controller:SetHeight(Settings.WingsHeight)
    Controller:SetBackOffset(Settings.WingsBackOffset)
    Controller:SetSwingSpeed(Settings.WingsSpeed)
    Controller:SetFlapStrength(Settings.WingsFlapStrength)
    Controller:SetSpread(Settings.WingsSpread)
    Controller:SetFps(Settings.WingsFps)
    Controller:SetEnabled(Settings.Wings)
end

function Visuals.LoadWings()
    local Controller = Visuals.GetWingsController()
    if Controller then return Controller end
    if WingsLoading then return nil end

    WingsLoading = true
    local Source = Visuals.FetchSource(WingsUrl)
    if Source then Controller = Visuals.LoadController(Source, "NightfallWingsController") end
    WingsLoading = false
    WingsController = Controller
    return Visuals.GetWingsController()
end

function Visuals.SetWings(State)
    Settings.Wings = State == true
    local Controller = Visuals.GetWingsController()

    if not Settings.Wings then
        if Controller then Controller:SetEnabled(false) end
        return
    end

    if Controller then Visuals.ApplyWings() return end
    Spawn(function()
        local Loaded = Visuals.LoadWings()
        if Loaded then Visuals.ApplyWings() end
    end)
end

function Visuals.SetWingsColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.WingsColor = Value
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetColor(Value) end
end

function Visuals.SetWingsOutlineColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.WingsOutlineColor = Value
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetOutlineColor(Value) end
end

function Visuals.SetWingsScale(Value)
    if Type(Value) ~= "number" then return end
    Settings.WingsScale = Clamp(Value, 0.55, 2.25)
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetScale(Settings.WingsScale) end
end

function Visuals.SetWingsHeight(Value)
    if Type(Value) ~= "number" then return end
    Settings.WingsHeight = Clamp(Value, -2, 2.5)
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetHeight(Settings.WingsHeight) end
end

function Visuals.SetWingsBackOffset(Value)
    if Type(Value) ~= "number" then return end
    Settings.WingsBackOffset = Clamp(Value, 0, 2)
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetBackOffset(Settings.WingsBackOffset) end
end

function Visuals.SetWingsSpeed(Value)
    if Type(Value) ~= "number" then return end
    Settings.WingsSpeed = Clamp(Value, 0.1, 6)
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetSwingSpeed(Settings.WingsSpeed) end
end

function Visuals.SetWingsFlapStrength(Value)
    if Type(Value) ~= "number" then return end
    Settings.WingsFlapStrength = Clamp(Value, 0.2, 2)
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetFlapStrength(Settings.WingsFlapStrength) end
end

function Visuals.SetWingsSpread(Value)
    if Type(Value) ~= "number" then return end
    Settings.WingsSpread = Clamp(Value, 0.6, 1.6)
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetSpread(Settings.WingsSpread) end
end

function Visuals.SetWingsFps(Value)
    if Type(Value) ~= "number" then return end
    Settings.WingsFps = Clamp(Floor(Value + 0.5), 30, 240)
    local Controller = Visuals.GetWingsController()
    if Controller then Controller:SetFps(Settings.WingsFps) end
end

function Visuals.GetChinaHatController()
    local Controller = ChinaHatController or _G.NightfallChinaHatController
    if Type(Controller) ~= "table" or Controller.Running == false or Controller.Version ~= 4 then ChinaHatController = nil return nil end

    local Methods = {"SetEnabled", "SetColor", "SetOutlineColor", "SetScale", "SetHeight", "SetRadius", "SetConeHeight", "SetGlow", "SetThickness", "SetFps"}
    for Index = 1, #Methods do
        if Type(Controller[Methods[Index]]) ~= "function" then ChinaHatController = nil return nil end
    end

    ChinaHatController = Controller
    return Controller
end

function Visuals.ApplyChinaHat()
    local Controller = Visuals.GetChinaHatController()
    if not Controller then return end

    Controller:SetColor(Settings.ChinaHatColor)
    Controller:SetOutlineColor(Settings.ChinaHatOutlineColor)
    Controller:SetScale(Settings.ChinaHatScale)
    Controller:SetHeight(Settings.ChinaHatHeight)
    Controller:SetRadius(Settings.ChinaHatRadius)
    Controller:SetConeHeight(Settings.ChinaHatConeHeight)
    Controller:SetGlow(Settings.ChinaHatGlow)
    Controller:SetThickness(Settings.ChinaHatThickness)
    Controller:SetFps(Settings.ChinaHatFps)
    Controller:SetEnabled(Settings.ChinaHat)
end

function Visuals.LoadChinaHat()
    local Controller = Visuals.GetChinaHatController()
    if Controller then return Controller end
    if ChinaHatLoading then return nil end

    ChinaHatLoading = true
    local Source = Visuals.FetchSource(ChinaHatUrl)
    if Source then Controller = Visuals.LoadController(Source, "NightfallChinaHatController") end
    ChinaHatLoading = false
    ChinaHatController = Controller
    return Visuals.GetChinaHatController()
end

function Visuals.SetChinaHat(State)
    Settings.ChinaHat = State == true
    local Controller = Visuals.GetChinaHatController()

    if not Settings.ChinaHat then
        if Controller then Controller:SetEnabled(false) end
        return
    end

    if Controller then Visuals.ApplyChinaHat() return end
    Spawn(function()
        local Loaded = Visuals.LoadChinaHat()
        if Loaded then Visuals.ApplyChinaHat() end
    end)
end

function Visuals.SetChinaHatColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.ChinaHatColor = Value
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetColor(Value) end
end

function Visuals.SetChinaHatOutlineColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.ChinaHatOutlineColor = Value
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetOutlineColor(Value) end
end

function Visuals.SetChinaHatScale(Value)
    if Type(Value) ~= "number" then return end
    Settings.ChinaHatScale = Clamp(Value, 0.55, 1.8)
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetScale(Settings.ChinaHatScale) end
end

function Visuals.SetChinaHatHeight(Value)
    if Type(Value) ~= "number" then return end
    Settings.ChinaHatHeight = Clamp(Value, -1.25, 2.5)
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetHeight(Settings.ChinaHatHeight) end
end

function Visuals.SetChinaHatRadius(Value)
    if Type(Value) ~= "number" then return end
    Settings.ChinaHatRadius = Clamp(Value, 0.75, 3.25)
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetRadius(Settings.ChinaHatRadius) end
end

function Visuals.SetChinaHatConeHeight(Value)
    if Type(Value) ~= "number" then return end
    Settings.ChinaHatConeHeight = Clamp(Value, 0.7, 3.5)
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetConeHeight(Settings.ChinaHatConeHeight) end
end

function Visuals.SetChinaHatGlow(Value)
    if Type(Value) ~= "number" then return end
    Settings.ChinaHatGlow = Clamp(Value, 0, 1)
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetGlow(Settings.ChinaHatGlow) end
end

function Visuals.SetChinaHatThickness(Value)
    if Type(Value) ~= "number" then return end
    Settings.ChinaHatThickness = Clamp(Value, 1, 4)
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetThickness(Settings.ChinaHatThickness) end
end

function Visuals.SetChinaHatFps(Value)
    if Type(Value) ~= "number" then return end
    Settings.ChinaHatFps = Clamp(Floor(Value + 0.5), 30, 240)
    local Controller = Visuals.GetChinaHatController()
    if Controller then Controller:SetFps(Settings.ChinaHatFps) end
end

function Visuals.GetDemonController()
    local Controller = DemonController or _G.NightfallDemonController
    if Type(Controller) ~= "table" or Controller.Running == false or Controller.Version ~= 1 then DemonController = nil return nil end

    local Methods = {
        "SetEnabled", "SetHorns", "SetTail",
        "SetHornsColor", "SetHornsOutline", "SetHornsScale", "SetHornsHeight", "SetHornsSpread",
        "SetTailColor", "SetTailOutline", "SetTailScale", "SetTailLength", "SetTailSpeed", "SetTailStrength",
        "SetThickness", "SetFps"
    }

    for Index = 1, #Methods do
        if Type(Controller[Methods[Index]]) ~= "function" then DemonController = nil return nil end
    end

    DemonController = Controller
    return Controller
end

function Visuals.ApplyDemon()
    local Controller = Visuals.GetDemonController()
    if not Controller then return end

    Controller:SetHornsColor(Settings.DemonHornsColor)
    Controller:SetHornsOutline(Settings.DemonHornsOutlineColor)
    Controller:SetHornsScale(Settings.DemonHornsScale)
    Controller:SetHornsHeight(Settings.DemonHornsHeight)
    Controller:SetHornsSpread(Settings.DemonHornsSpread)
    Controller:SetTailColor(Settings.DemonTailColor)
    Controller:SetTailOutline(Settings.DemonTailOutlineColor)
    Controller:SetTailScale(Settings.DemonTailScale)
    Controller:SetTailLength(Settings.DemonTailLength)
    Controller:SetTailSpeed(Settings.DemonTailSpeed)
    Controller:SetTailStrength(Settings.DemonTailStrength)
    Controller:SetThickness(1)
    Controller:SetFps(144)
    Controller:SetHorns(Settings.DemonHorns)
    Controller:SetTail(Settings.DemonTail)
    Controller:SetEnabled(Settings.DemonHorns or Settings.DemonTail)
end

function Visuals.LoadDemon()
    local Controller = Visuals.GetDemonController()
    if Controller then return Controller end
    if DemonLoading then return nil end

    DemonLoading = true
    local Source = Visuals.FetchSource(DemonUrl)
    if Source then Controller = Visuals.LoadController(Source, "NightfallDemonController") end
    DemonLoading = false
    DemonController = Controller
    return Visuals.GetDemonController()
end

function Visuals.SetDemonHorns(State)
    Settings.DemonHorns = State == true
    local Controller = Visuals.GetDemonController()

    if Controller then
        Controller:SetHorns(Settings.DemonHorns)
        Controller:SetEnabled(Settings.DemonHorns or Settings.DemonTail)
        return
    end

    if not Settings.DemonHorns and not Settings.DemonTail then return end

    Spawn(function()
        local Loaded = Visuals.LoadDemon()
        if Loaded then Visuals.ApplyDemon() end
    end)
end

function Visuals.SetDemonTail(State)
    Settings.DemonTail = State == true
    local Controller = Visuals.GetDemonController()

    if Controller then
        Controller:SetTail(Settings.DemonTail)
        Controller:SetEnabled(Settings.DemonHorns or Settings.DemonTail)
        return
    end

    if not Settings.DemonHorns and not Settings.DemonTail then return end

    Spawn(function()
        local Loaded = Visuals.LoadDemon()
        if Loaded then Visuals.ApplyDemon() end
    end)
end

function Visuals.SetDemonHornsColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.DemonHornsColor = Value
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetHornsColor(Value) end
end

function Visuals.SetDemonHornsOutline(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.DemonHornsOutlineColor = Value
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetHornsOutline(Value) end
end

function Visuals.SetDemonHornsScale(Value)
    if Type(Value) ~= "number" then return end
    Settings.DemonHornsScale = Clamp(Value, 0.4, 2.5)
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetHornsScale(Settings.DemonHornsScale) end
end

function Visuals.SetDemonHornsHeight(Value)
    if Type(Value) ~= "number" then return end
    Settings.DemonHornsHeight = Clamp(Value, -1.5, 2)
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetHornsHeight(Settings.DemonHornsHeight) end
end

function Visuals.SetDemonHornsSpread(Value)
    if Type(Value) ~= "number" then return end
    Settings.DemonHornsSpread = Clamp(Value, 0.5, 1.8)
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetHornsSpread(Settings.DemonHornsSpread) end
end

function Visuals.SetDemonTailColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.DemonTailColor = Value
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetTailColor(Value) end
end

function Visuals.SetDemonTailOutline(Value)
    if TypeOf(Value) ~= "Color3" then return end
    Settings.DemonTailOutlineColor = Value
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetTailOutline(Value) end
end

function Visuals.SetDemonTailScale(Value)
    if Type(Value) ~= "number" then return end
    Settings.DemonTailScale = Clamp(Value, 0.4, 2.5)
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetTailScale(Settings.DemonTailScale) end
end

function Visuals.SetDemonTailLength(Value)
    if Type(Value) ~= "number" then return end
    Settings.DemonTailLength = Clamp(Value, 2.5, 8)
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetTailLength(Settings.DemonTailLength) end
end

function Visuals.SetDemonTailSpeed(Value)
    if Type(Value) ~= "number" then return end
    Settings.DemonTailSpeed = Clamp(Value, 0.2, 6)
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetTailSpeed(Settings.DemonTailSpeed) end
end

function Visuals.SetDemonTailStrength(Value)
    if Type(Value) ~= "number" then return end
    Settings.DemonTailStrength = Clamp(Value, 0.1, 2.5)
    local Controller = Visuals.GetDemonController()
    if Controller then Controller:SetTailStrength(Settings.DemonTailStrength) end
end

do
    local Wings = Visuals.GetWingsController()
    if Wings then Wings:SetEnabled(false) end

    local Hat = Visuals.GetChinaHatController()
    if Hat then Hat:SetEnabled(false) end

    local Demon = Visuals.GetDemonController()
    if Demon then Demon:SetEnabled(false) end
end

local Runtime = {
    TargetSpeed = 0,
    TargetDistance = 0,
    TargetDot = 0,
    ParryRange = 10,
    ServerDistance = 0,
    ServerTickLead = 0
}

local ParryBase = 15
local ParryDivisor = 2.2
local ParryMaxDivisor = 7.5
local EffectiveMultiplier = 1.1
local ExtrapolationLimit = 0.25
local ExtrapolationMinTicks = 0.5
local ExtrapolationMaxTicks = 6
local SimulationInterval = 1 / 60
local SimulationResponse = 0.15
local ServerTickInterval = 1 / 60

local GetServerTimeNow = Workspace.GetServerTimeNow

function Combat.GetServerClock()
    if Type(GetServerTimeNow) == "function" then
        local Time = GetServerTimeNow(Workspace)
        if Shared.IsValidNumber(Time) then return Time end
    end

    return Clock()
end

function Combat.GetServerTickLead()
    local Time = Combat.GetServerClock()
    local Interval = ServerTickInterval
    local NextTick = Ceil(Time / Interval) * Interval
    local Lead = NextTick - Time

    if Lead < 0 then Lead = 0 end
    if Lead > Interval then Lead = Interval end
    return Lead + Interval * 0.5
end


local CombatTab = Window:Tab("Combat", "swords")

local AutoParrySection = CombatTab:Section("Auto Parry", "Left", "")
local AutoParryToggle = AutoParrySection:Toggle("Enabled", false, function(State)
    Settings.AutoParry = State
end)
AutoParryToggle:AddKeybind("None", "Toggle")
AutoParrySection:Toggle("Cooldown Protection", false, function(State)
    Settings.CooldownProtection = State
end)
AutoParrySection:Toggle("Auto Ability", false, function(State)
    Settings.AutoAbility = State
end)
AutoParrySection:Dropdown("Input Method", "Click", {"Click", "Key"}, false, function(Value)
    Settings.ParryMethod = Value
end)
AutoParrySection:Toggle("Training Ball Support", false, function(State)
    Settings.TrainingBalls = State
end)
AutoParrySection:Slider("Accuracy", Settings.ParryAccuracy, 1, 1, 100, "%", function(Value)
    Settings.ParryAccuracy = Value
end)

local SpamSection = CombatTab:Section("Spam", "Right", "")
SpamSection:Toggle("Auto Spam", false, function(State)
    Settings.AutoSpam = State
end):AddKeybind("None", "Toggle")
SpamSection:Slider("Parry Threshold", Settings.ParryThreshold, 0.1, 1, 3, "", function(Value)
    Settings.ParryThreshold = Value
end)
SpamSection:Toggle("Manual Spam", false, function(State)
    Settings.ManualSpam = State
end):AddKeybind("None", "Toggle")
SpamSection:Slider("Spam Rate", Settings.SpamRate, 25, 200, 1000, " CPS", function(Value)
    Settings.SpamRate = Value
end)

local OrbitSection = CombatTab:Section("Orbit", "Left", "")
OrbitSection:Toggle("Enabled", false, function(State)
    Settings.Orbit = State
end):AddKeybind("None", "Toggle")
OrbitSection:Slider("Radius", 25, 1, 5, 100, " studs", function(Value)
    Settings.OrbitRadius = Value
end)
OrbitSection:Slider("Speed", 50, 1, 10, 200, "", function(Value)
    Settings.OrbitSpeed = Value
end)
OrbitSection:Slider("Height", 5, 0.5, -30, 50, " studs", function(Value)
    Settings.OrbitHeight = Value
end)

local TriggerSection = CombatTab:Section("Trigger Parry", "Right", "")
TriggerSection:Toggle("Enabled", false, function(State)
    Settings.TriggerBot = State
end):AddKeybind("None", "Toggle")
TriggerSection:Slider("Delay", 0, 1, 0, 100, " ms", function(Value)
    Settings.TriggerDelay = Value
end)
TriggerSection:Toggle("Ignore Spawn", false, function(State)
    Settings.TriggerIgnoreSpawn = State
end)

local VisualsTab = Window:Tab("Visuals", "eye")

local ParryRangeSection = VisualsTab:Section("Parry Range", "Left", "")
ParryRangeSection:Toggle("Enabled", false, function(State)
    Settings.ParryRangeEnabled = State
end):AddColorpicker("Color", NewRGB(220, 30, 30), function(Color)
    Settings.ParryRangeColor = Color
end)
ParryRangeSection:Slider("Thickness", 2.0, 0.1, 1.0, 10.0, " px", function(Value)
    Settings.RangeThickness = Value
end)
ParryRangeSection:Slider("Transparency", 1.0, 0.1, 0.1, 1.0, "", function(Value)
    Settings.RangeTransparency = Value
end)
ParryRangeSection:Slider("Segments", 40, 1, 10, 100, " seg", function(Value)
    Settings.RangeSegments = Value
end)

local BallTrailSection = VisualsTab:Section("Ball Trail", "Right", "")
BallTrailSection:Toggle("Enabled", false, function(State)
    Settings.BallTrail = State
end):AddColorpicker("Color", NewRGB(220, 30, 30), function(Color)
    Settings.TrailColor = Color
end)
BallTrailSection:Slider("Length", 60, 1, 3, 100, " pts", function(Value)
    Settings.TrailLength = Value
end)
BallTrailSection:Slider("Thickness", 2.0, 0.1, 1.0, 10.0, " px", function(Value)
    Settings.TrailThickness = Value
end)

local AbilityEspSection = VisualsTab:Section("Ability ESP", "Left", "")
AbilityEspSection:Toggle("Enabled", false, function(State)
    Settings.AbilityEsp = State
end)
AbilityEspSection:Colorpicker("Color", NewRGB(220, 30, 30), function(Color)
    Settings.EspColor = Color or NewRGB(220, 30, 30)
end)
AbilityEspSection:Slider("Text Size", 18, 1, 10, 40, " px", function(Value)
    Settings.EspTextSize = Value
end)
AbilityEspSection:Slider("Vertical Offset", 2.0, 0.5, 0.0, 10.0, " studs", function(Value)
    Settings.EspOffset = Value
end)

local EffectsSection = VisualsTab:Section("Effects", "Right", "")
EffectsSection:Toggle("Rainbow", false, function(State)
    Settings.Rainbow = State
end)

local CosmeticsTab = Window:Tab("Cosmetics", "star")

local WingsSection = CosmeticsTab:Section("Wings", "Left", "")
local WingsToggle = WingsSection:Toggle("Enabled", false, function(State)
    Visuals.SetWings(State)
end)
WingsToggle:AddColorpicker("Color", Settings.WingsColor, function(Color)
    Visuals.SetWingsColor(Color)
end)
WingsSection:Colorpicker("Outline", Settings.WingsOutlineColor, function(Color)
    Visuals.SetWingsOutlineColor(Color)
end)
WingsSection:Slider("Scale", Settings.WingsScale, 0.05, 0.55, 2.25, "x", function(Value)
    Visuals.SetWingsScale(Value)
end)
WingsSection:Slider("Height", Settings.WingsHeight, 0.05, -2, 2.5, " studs", function(Value)
    Visuals.SetWingsHeight(Value)
end)
WingsSection:Slider("Back Offset", Settings.WingsBackOffset, 0.05, 0, 2, " studs", function(Value)
    Visuals.SetWingsBackOffset(Value)
end)
WingsSection:Slider("Spread", Settings.WingsSpread, 0.05, 0.6, 1.6, "x", function(Value)
    Visuals.SetWingsSpread(Value)
end)
WingsSection:Slider("Animation Speed", Settings.WingsSpeed, 0.05, 0.1, 6, "x", function(Value)
    Visuals.SetWingsSpeed(Value)
end)
WingsSection:Slider("Flap Strength", Settings.WingsFlapStrength, 0.05, 0.2, 2, "x", function(Value)
    Visuals.SetWingsFlapStrength(Value)
end)
WingsSection:Slider("Render FPS", Settings.WingsFps, 1, 30, 240, " FPS", function(Value)
    Visuals.SetWingsFps(Value)
end)

local ChinaHatSection = CosmeticsTab:Section("China Hat", "Right", "")
local ChinaHatToggle = ChinaHatSection:Toggle("Enabled", false, function(State)
    Visuals.SetChinaHat(State)
end)
ChinaHatToggle:AddColorpicker("Color", Settings.ChinaHatColor, function(Color)
    Visuals.SetChinaHatColor(Color)
end)
ChinaHatSection:Colorpicker("Outline", Settings.ChinaHatOutlineColor, function(Color)
    Visuals.SetChinaHatOutlineColor(Color)
end)
ChinaHatSection:Slider("Scale", Settings.ChinaHatScale, 0.05, 0.55, 1.8, "x", function(Value)
    Visuals.SetChinaHatScale(Value)
end)
ChinaHatSection:Slider("Height", Settings.ChinaHatHeight, 0.05, -1.25, 2.5, " studs", function(Value)
    Visuals.SetChinaHatHeight(Value)
end)
ChinaHatSection:Slider("Radius", Settings.ChinaHatRadius, 0.05, 0.75, 3.25, " studs", function(Value)
    Visuals.SetChinaHatRadius(Value)
end)
ChinaHatSection:Slider("Cone Height", Settings.ChinaHatConeHeight, 0.05, 0.7, 3.5, " studs", function(Value)
    Visuals.SetChinaHatConeHeight(Value)
end)
ChinaHatSection:Slider("Glow", Settings.ChinaHatGlow, 0.05, 0, 1, "", function(Value)
    Visuals.SetChinaHatGlow(Value)
end)
ChinaHatSection:Slider("Thickness", Settings.ChinaHatThickness, 0.1, 1, 4, " px", function(Value)
    Visuals.SetChinaHatThickness(Value)
end)
ChinaHatSection:Slider("Render FPS", Settings.ChinaHatFps, 1, 30, 240, " FPS", function(Value)
    Visuals.SetChinaHatFps(Value)
end)

local DemonHornsSection = CosmeticsTab:Section("Demon Horns", "Left", "")
local DemonHornsToggle = DemonHornsSection:Toggle("Enabled", false, function(State)
    Visuals.SetDemonHorns(State)
end)
DemonHornsToggle:AddColorpicker("Color", Settings.DemonHornsColor, function(Color)
    Visuals.SetDemonHornsColor(Color)
end)
DemonHornsSection:Colorpicker("Outline", Settings.DemonHornsOutlineColor, function(Color)
    Visuals.SetDemonHornsOutline(Color)
end)
DemonHornsSection:Slider("Scale", Settings.DemonHornsScale, 0.05, 0.4, 2.5, "x", function(Value)
    Visuals.SetDemonHornsScale(Value)
end)
DemonHornsSection:Slider("Height", Settings.DemonHornsHeight, 0.05, -1.5, 2, " studs", function(Value)
    Visuals.SetDemonHornsHeight(Value)
end)
DemonHornsSection:Slider("Spread", Settings.DemonHornsSpread, 0.05, 0.5, 1.8, "x", function(Value)
    Visuals.SetDemonHornsSpread(Value)
end)

local DemonTailSection = CosmeticsTab:Section("Demon Tail", "Right", "")
local DemonTailToggle = DemonTailSection:Toggle("Enabled", false, function(State)
    Visuals.SetDemonTail(State)
end)
DemonTailToggle:AddColorpicker("Color", Settings.DemonTailColor, function(Color)
    Visuals.SetDemonTailColor(Color)
end)
DemonTailSection:Colorpicker("Outline", Settings.DemonTailOutlineColor, function(Color)
    Visuals.SetDemonTailOutline(Color)
end)
DemonTailSection:Slider("Scale", Settings.DemonTailScale, 0.05, 0.4, 2.5, "x", function(Value)
    Visuals.SetDemonTailScale(Value)
end)
DemonTailSection:Slider("Length", Settings.DemonTailLength, 0.1, 2.5, 8, " studs", function(Value)
    Visuals.SetDemonTailLength(Value)
end)
DemonTailSection:Slider("Sway Speed", Settings.DemonTailSpeed, 0.05, 0.2, 6, "x", function(Value)
    Visuals.SetDemonTailSpeed(Value)
end)
DemonTailSection:Slider("Sway Strength", Settings.DemonTailStrength, 0.05, 0.1, 2.5, "x", function(Value)
    Visuals.SetDemonTailStrength(Value)
end)

local BasePartTransparencyOffset = 0x130
local SpecialMeshScaleOffset = 0xC4
local MinimumMemoryAddress = 0x100000000

local CharacterVisualState = {
    HeadlessParts = {},
    KorbloxParts = {},
    Meshes = {}
}

local function GetMemoryAddress(Instance)
    if not Shared.IsInstance(Instance) then return nil end

    local Address = Instance.Address
    if Type(Address) ~= "number" or Address < MinimumMemoryAddress then return nil end
    return Address
end

local function ReadSafeFloat(Address)
    if Type(Address) ~= "number" or Address < MinimumMemoryAddress then return nil end

    local Value = ReadMemory("float", Address)
    if not Shared.IsValidNumber(Value) then return nil end
    return Value
end

local function ReadPartTransparency(Part)
    if not Shared.IsInstance(Part) or not Part:IsA("BasePart") then return nil end

    local Address = GetMemoryAddress(Part)
    if not Address then return nil end

    local Value = ReadSafeFloat(Address + BasePartTransparencyOffset)
    if Value == nil or Value < -0.001 or Value > 1.001 then return nil end
    return Clamp(Value, 0, 1)
end

local function WritePartTransparency(Part, Value)
    if not Shared.IsInstance(Part) or not Part:IsA("BasePart") or not Shared.IsValidNumber(Value) then return false end

    local Address = GetMemoryAddress(Part)
    if not Address then return false end

    local MemoryAddress = Address + BasePartTransparencyOffset
    local Current = ReadSafeFloat(MemoryAddress)
    if Current == nil or Current < -0.001 or Current > 1.001 then return false end

    WriteMemory("float", MemoryAddress, Clamp(Value, 0, 1))
    return true
end

local function ReadMeshScale(Mesh)
    if not Shared.IsInstance(Mesh) or not Mesh:IsA("SpecialMesh") then return nil end

    local Address = GetMemoryAddress(Mesh)
    if not Address then return nil end

    local ScaleAddress = Address + SpecialMeshScaleOffset
    local X = ReadSafeFloat(ScaleAddress)
    local Y = ReadSafeFloat(ScaleAddress + 0x4)
    local Z = ReadSafeFloat(ScaleAddress + 0x8)

    if X == nil or Y == nil or Z == nil then return nil end
    if math.abs(X) > 10000 or math.abs(Y) > 10000 or math.abs(Z) > 10000 then return nil end
    return NewVector3(X, Y, Z)
end

local function WriteMeshScale(Mesh, Scale)
    if not Shared.IsInstance(Mesh) or not Mesh:IsA("SpecialMesh") or not Shared.IsValidVector3(Scale) then return false end

    local Address = GetMemoryAddress(Mesh)
    if not Address then return false end

    local Current = ReadMeshScale(Mesh)
    if not Current then return false end

    local ScaleAddress = Address + SpecialMeshScaleOffset
    WriteMemory("float", ScaleAddress, Scale.X)
    WriteMemory("float", ScaleAddress + 0x4, Scale.Y)
    WriteMemory("float", ScaleAddress + 0x8, Scale.Z)
    return true
end

local function SaveMeshState(Mesh)
    if CharacterVisualState.Meshes[Mesh] then return end

    local Scale = ReadMeshScale(Mesh)
    if Scale then CharacterVisualState.Meshes[Mesh] = Scale end
end

local function SetMeshHidden(Mesh, Hidden)
    if not Shared.IsInstance(Mesh) or not Mesh:IsA("SpecialMesh") then return end

    if Hidden then
        SaveMeshState(Mesh)
        if CharacterVisualState.Meshes[Mesh] then WriteMeshScale(Mesh, EmptyVector3) end
        return
    end

    local Scale = CharacterVisualState.Meshes[Mesh]
    if Scale then WriteMeshScale(Mesh, Scale) end
    CharacterVisualState.Meshes[Mesh] = nil
end

local function SavePartState(Cache, Part)
    local State = Cache[Part]
    if State then return State end
    if not Shared.IsInstance(Part) or not Part:IsA("BasePart") then return nil end

    local Size = Part.Size
    if not Shared.IsValidVector3(Size) then return nil end

    State = {
        Size = Size,
        Transparency = ReadPartTransparency(Part)
    }

    Cache[Part] = State
    return State
end

local function SetPartHidden(Cache, Part, Hidden)
    if not Shared.IsInstance(Part) or not Part:IsA("BasePart") then return end

    if Hidden then
        local State = SavePartState(Cache, Part)
        if not State then return end

        Part.Size = NewVector3(0.01, 0.01, 0.01)
        if State.Transparency ~= nil then WritePartTransparency(Part, 1) end

        for _, Child in ipairs(Part:GetChildren()) do
            if Shared.IsInstance(Child) and Child:IsA("SpecialMesh") then SetMeshHidden(Child, true) end
        end

        return
    end

    local State = Cache[Part]
    if not State then return end

    if Shared.IsValidVector3(State.Size) then Part.Size = State.Size end
    if State.Transparency ~= nil then WritePartTransparency(Part, State.Transparency) end

    for _, Child in ipairs(Part:GetChildren()) do
        if Shared.IsInstance(Child) and Child:IsA("SpecialMesh") then SetMeshHidden(Child, false) end
    end

    Cache[Part] = nil
end

local HeadAttachments = {
    HatAttachment = true,
    HairAttachment = true,
    FaceFrontAttachment = true,
    FaceCenterAttachment = true
}

local function IsHeadAccessory(Accessory)
    if not Shared.IsInstance(Accessory) or not Accessory:IsA("Accessory") then return false end

    local Handle = Accessory:FindFirstChild("Handle")
    if not Shared.IsInstance(Handle) or not Handle:IsA("BasePart") then return false end

    for _, Child in ipairs(Handle:GetChildren()) do
        if Shared.IsInstance(Child) and Child:IsA("Attachment") then
            local Name = Shared.GetName(Child)
            if Name and HeadAttachments[Name] then return true end
        end
    end

    return false
end

local function RestoreCache(Cache)
    local Parts = {}
    for Part in pairs(Cache) do Parts[#Parts + 1] = Part end
    for Index = 1, #Parts do SetPartHidden(Cache, Parts[Index], false) end
end

local function RestoreHeadless()
    RestoreCache(CharacterVisualState.HeadlessParts)
end

function Visuals.ApplyHeadless(State)
    local Character = Shared.GetCharacter(LocalPlayer)
    if not Character then
        if not State then RestoreHeadless() end
        return
    end

    if not State then
        RestoreHeadless()
        return
    end

    local Head = Character:FindFirstChild("Head")
    if Shared.IsInstance(Head) and Head:IsA("BasePart") then
        SetPartHidden(CharacterVisualState.HeadlessParts, Head, true)
    end

    for _, Accessory in ipairs(Character:GetChildren()) do
        if IsHeadAccessory(Accessory) then
            local Handle = Accessory:FindFirstChild("Handle")
            if Shared.IsInstance(Handle) and Handle:IsA("BasePart") then
                SetPartHidden(CharacterVisualState.HeadlessParts, Handle, true)
            end
        end
    end
end

function Visuals.ApplyKorblox(State)
    local Character = Shared.GetCharacter(LocalPlayer)
    if not Character then
        if not State then RestoreCache(CharacterVisualState.KorbloxParts) end
        return
    end

    if not State then
        RestoreCache(CharacterVisualState.KorbloxParts)
        return
    end

    local RightLegs = {
        RightUpperLeg = true,
        RightLowerLeg = true,
        RightFoot = true,
        ["Right Leg"] = true
    }

    for _, Part in ipairs(Character:GetChildren()) do
        if Shared.IsInstance(Part) and Part:IsA("BasePart") then
            local Name = Shared.GetName(Part)
            if Name and RightLegs[Name] then SetPartHidden(CharacterVisualState.KorbloxParts, Part, true) end
        end
    end
end

local CharacterSection = VisualsTab:Section("Character", "Left", "")
CharacterSection:Toggle("Headless", false, function(State)
    Settings.Headless = State
    Visuals.ApplyHeadless(State)
end)
CharacterSection:Toggle("Korblox", false, function(State)
    Settings.Korblox = State
    Visuals.ApplyKorblox(State)
end)

local DetectionsTab = Window:Tab("Detections", "shield")
local DetectionSection = DetectionsTab:Section("Detections", "Left", "")
DetectionSection:Toggle("Infinity", false, function(State)
    Settings.InfinityDetection = State
end)
DetectionSection:Toggle("Slashes of Fury", false, function(State)
    Settings.FuryDetection = State
end)

Window:AddSettingsTab("cog")

_G.NightfallActive = true

if _G.NightfallSpamConnection then
    Shared.Disconnect(_G.NightfallSpamConnection)
    _G.NightfallSpamConnection = nil
end

local MaxTrailLines = 100

function Visuals.CreateEspText()
    if Type(Drawing) ~= "table" or Type(Drawing.new) ~= "function" then return nil end
    local Text = Drawing.new("Text")
    if not Text then return nil end
    Text.Center = true
    Text.Outline = true
    Text.Font = Type(Drawing.Fonts) == "table" and Drawing.Fonts.System or 2
    Text.Transparency = 0
    Text.ZIndex = 2
    Text.Color = TypeOf(Settings.EspColor) == "Color3" and Settings.EspColor or NewRGB(220, 30, 30)
    Text.Visible = false
    Insert(_G.NightfallDrawings, Text)
    return Text
end

if Type(Drawing) == "table" and Type(Drawing.new) == "function" then
    for Index = 1, 100 do
        local Line = Drawing.new("Line")
        if Line then
            Line.Visible = false
            Visuals.RangeLines[Index] = Line
            Insert(_G.NightfallDrawings, Line)
        end
    end

    for Index = 1, MaxTrailLines do
        local Line = Drawing.new("Line")
        if Line then
            Line.Visible = false
            Visuals.TrailLines[Index] = Line
            Insert(_G.NightfallDrawings, Line)
        end
    end
end

local SmoothParryRadius = ParryBase


function Combat.GetBallFolder()
    local AliveFolder = Workspace:FindFirstChild("Alive")
    local DeadFolder = Workspace:FindFirstChild("Dead")
    local LocalName = Shared.GetName(LocalPlayer)

    if LocalName and Shared.IsInstance(AliveFolder) and AliveFolder:FindFirstChild(LocalName) then
        return Workspace:FindFirstChild("Balls")
    end

    if LocalName and Shared.IsInstance(DeadFolder) and DeadFolder:FindFirstChild(LocalName) and Settings.TrainingBalls then
        return Workspace:FindFirstChild("TrainingBalls")
    end

    return Workspace:FindFirstChild("Balls")
end

function Combat.GetBalls()
    local TargetFolder = Combat.GetBallFolder()
    local Balls = {}

    if not TargetFolder or TypeOf(TargetFolder) ~= "Instance" then
        return Balls
    end

    for _, Ball in ipairs(TargetFolder:GetChildren()) do
        if Shared.IsInstance(Ball) and Ball:IsA("BasePart") and Shared.GetParent(Ball) then
            Insert(Balls, Ball)
        end
    end

    return Balls
end

function Combat.GetBall()
    local Balls = Combat.GetBalls()
    return Balls[1]
end

function Combat.GetPing()
    if Type(GetPing) ~= "function" then return 50 end
    local Ping = GetPing()
    if not Shared.IsValidNumber(Ping) or Ping < 0 then return 50 end
    return Ping
end

local PullWind = "rbxassetid://224339308"
local MaxPullWind = "rbxassetid://2780197456"
local PullDos = "rbxassetid://8925097078"

function Combat.GetEffectPart(Object)
    if not Shared.IsInstance(Object) then return nil end
    if Object:IsA("BasePart") then return Object end

    if Object:IsA("Model") then
        local PrimaryPart = Object.PrimaryPart
        if Shared.IsInstance(PrimaryPart) and PrimaryPart:IsA("BasePart") then
            return PrimaryPart
        end
    end

    local Queue = Object:GetChildren()
    local Index = 1

    while Index <= #Queue do
        local Child = Queue[Index]
        Index = Index + 1

        if Shared.IsInstance(Child) then
            if Child:IsA("BasePart") then
                return Child
            end

            local Children = Child:GetChildren()
            for ChildIndex = 1, #Children do
                Insert(Queue, Children[ChildIndex])
            end
        end
    end

    return nil
end

function Combat.GetPullSounds(Object)
    if not Shared.IsInstance(Object) then return nil, nil end

    local Wind = nil
    local Dos = nil
    local Queue = Object:GetChildren()
    local Index = 1

    while Index <= #Queue and (not Wind or not Dos) do
        local Child = Queue[Index]
        Index = Index + 1

        if Shared.IsInstance(Child) then
            local Name = Shared.GetName(Child)

            if Child:IsA("Sound") then
                if Name == "Wind" then
                    Wind = Child
                elseif Name == "dos" then
                    Dos = Child
                end
            end

            local Children = Child:GetChildren()
            for ChildIndex = 1, #Children do
                Insert(Queue, Children[ChildIndex])
            end
        end
    end

    return Wind, Dos
end

function Combat.GetNearestPlayer(Position)
    if not Shared.IsValidVector3(Position) then return nil end

    local Nearest = nil
    local NearestDistance = Infinite
    local PlayerList = Players:GetPlayers()

    for Index = 1, #PlayerList do
        local Player = PlayerList[Index]
        local Character = Shared.GetCharacter(Player)

        if Character then
            local RootPart = Character.PrimaryPart
            if not Shared.IsInstance(RootPart) then
                RootPart = Character:FindFirstChild("HumanoidRootPart")
            end

            local RootPosition = Shared.GetPartPosition(RootPart)
            if RootPosition then
                local Distance = (RootPosition - Position).Magnitude
                if Distance < NearestDistance then
                    NearestDistance = Distance
                    Nearest = Player
                end
            end
        end
    end

    return Nearest
end

function Combat.GetPullUser()
    local RuntimeFolder = Workspace:FindFirstChild("Runtime")
    if not Shared.IsInstance(RuntimeFolder) then return nil end

    local Children = RuntimeFolder:GetChildren()

    for Index = 1, #Children do
        local Object = Children[Index]
        local Name = Shared.GetName(Object)

        if Shared.IsInstance(Object) and (Name == "Pull" or Name == "MaxPull") then
            local Wind, Dos = Combat.GetPullSounds(Object)
            local WindId = Name == "MaxPull" and MaxPullWind or PullWind
            local ValidWind = Shared.IsInstance(Wind) and Wind.SoundId == WindId
            local ValidDos = Shared.IsInstance(Dos) and Dos.SoundId == PullDos

            if ValidWind and ValidDos then
                local Part = Combat.GetEffectPart(Object)
                local Position = Shared.GetPartPosition(Part)
                local Player = Combat.GetNearestPlayer(Position)

                if Player then
                    return Player, Object
                end
            end
        end
    end

    return nil
end

function Combat.IsTarget(Target)
    if Target == nil or not LocalPlayer then return false end

    if TypeOf(Target) == "Instance" then
        if Target == LocalPlayer then return true end
        Target = Shared.GetName(Target)
        if Target == nil then return false end
    end

    local Name = string.lower(Shared.GetName(LocalPlayer) or "")
    local Display = Name
    local UserId = ToString(LocalPlayer.UserId or "")
    local TargetText = string.lower(ToString(Target))
    local TargetName = string.gsub(TargetText, '%.%.%.$', '')

    if TargetName == Name or TargetName == Display or TargetName == UserId then
        return true
    end

    if #TargetName >= 3 then
        if Sub(Name, 1, #TargetName) == TargetName then return true end
        if Sub(Display, 1, #TargetName) == TargetName then return true end
    end

    return false
end

function Combat.GetFuryState()
    local Combo = 0
    local HasTargetBall = false
    local BallsFolder = Workspace:FindFirstChild("Balls")

    if Shared.IsInstance(BallsFolder) then
        for _, Ball in ipairs(BallsFolder:GetChildren()) do
            if Shared.IsInstance(Ball) then
                local Target = Shared.GetAttribute(Ball, "target") or Shared.GetAttribute(Ball, "Target")
                if Combat.IsTarget(Target) then
                    HasTargetBall = true

                    local Counter = Ball:FindFirstChild("ComboCounter")
                    if Shared.IsInstance(Counter) then
                        local Label = Counter:FindFirstChild("TextLabel")
                        if Shared.IsInstance(Label) and (Label:IsA("TextLabel") or Label:IsA("TextButton")) then
                            Combo = ToNumber(Label.Text) or 0
                        end
                        return true, Combo
                    end
                end
            end
        end
    end

    local Character = Shared.GetCharacter(LocalPlayer)
    if HasTargetBall and Shared.IsInstance(Character) and Shared.GetAttribute(Character, "FuryCatch") == true then
        return true, Combo
    end

    return false, Combo
end

local RecordSpamParry = nil

function Combat.Parry()
    local Fired = false

    if Settings.ParryMethod == "Click" then
        if TypeOf(Click) == "function" then
            Click()
            Fired = true
        end
    elseif Settings.ParryMethod == "Key" then
        if TypeOf(KeyPress) == "function" and TypeOf(KeyRelease) == "function" then
            KeyPress(0x46)
            KeyRelease(0x46)
            Fired = true
        end
    end

    if Fired and TypeOf(RecordSpamParry) == "function" then
        RecordSpamParry()
    end
end

function Combat.ParryAsync()
    Spawn(Combat.Parry)
end

local IsParried = false
local ParryLockTime = 0
local ParriedBall = nil
local ParriedTarget = nil
local BallSpeeds = {}
local AerodynamicStates = {}

function Combat.IsAerodynamicSlash(Ball, Velocity)
    if not Shared.IsInstance(Ball) then return false end

    local Effect = Ball:FindFirstChild("AeroDynamicSlashVFX")
    local State = AerodynamicStates[Ball]

    if not Shared.IsInstance(Effect) then
        if State then AerodynamicStates[Ball] = nil end
        return false
    end

    if not State then
        State = {
            StartedAt = Clock()
        }
        AerodynamicStates[Ball] = State
    end

    local VerticalSpeed = Shared.IsValidVector3(Velocity) and Velocity.Y or 0
    return Clock() - State.StartedAt < 0.2 or VerticalSpeed > 10
end

if _G.NightfallSimpleParryConnection then
    Shared.Disconnect(_G.NightfallSimpleParryConnection)
    _G.NightfallSimpleParryConnection = nil
end

if _G.NightfallParryPreConnection then
    Shared.Disconnect(_G.NightfallParryPreConnection)
    _G.NightfallParryPreConnection = nil
end

if _G.NightfallParryPostConnection then
    Shared.Disconnect(_G.NightfallParryPostConnection)
    _G.NightfallParryPostConnection = nil
end

local ProtectionAbilities = {
    ["Freeze"] = true,
    ["Invisibility"] = true,
    ["Forcefield"] = true,
    ["Raging Deflect"] = true,
    ["Raging Deflection"] = true,
    ["Aerodynamic Slash"] = true,
    ["Infinity"] = true,
    ["Rapture"] = true
}

local AutoAbilityNames = {
    "Raging Deflection",
    "Rapture",
    "Calming Deflection",
    "Aerodynamic Slash",
    "Fracture",
    "Death Slash"
}

local ParryCooldownOffset = 0x144
local CooldownProtectionUsed = false

local CooldownGuard = {
    Active = false,
    SawCooldown = false,
    StartedAt = 0
}

function Combat.GetEquippedAbility()
    local Ability = Shared.GetAttribute(LocalPlayer, "CurrentlyEquippedAbility")
    if Type(Ability) ~= "string" or Ability == "" then return nil end
    return Ability
end

function Combat.CanCooldownProtect()
    if not Settings.CooldownProtection then return false end
    local Ability = Combat.GetEquippedAbility()
    return Ability ~= nil and ProtectionAbilities[Ability] == true
end

function Combat.GetAbilityFolder()
    local Character = Shared.GetCharacter(LocalPlayer)
    if not Character then return nil end

    local Abilities = Character:FindFirstChild("Abilities")
    if not Shared.IsInstance(Abilities) then return nil end
    return Abilities
end

function Combat.GetAutoAbility()
    local Abilities = Combat.GetAbilityFolder()
    if not Abilities then return nil end

    for Index = 1, #AutoAbilityNames do
        local Name = AutoAbilityNames[Index]
        local Ability = Abilities:FindFirstChild(Name)

        if Shared.IsInstance(Ability) and Ability.Enabled == true then
            return Name
        end
    end

    return nil
end

function Combat.GetAbilityCooldownGradient()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not Shared.IsInstance(PlayerGui) then return nil end

    local Hotbar = PlayerGui:FindFirstChild("Hotbar")
    if not Shared.IsInstance(Hotbar) then return nil end

    local Ability = Hotbar:FindFirstChild("Ability")
    if not Shared.IsInstance(Ability) then return nil end

    local Gradient = Ability:FindFirstChild("UIGradient")
    if not Shared.IsInstance(Gradient) or not Gradient:IsA("UIGradient") then return nil end
    return Gradient
end

function Combat.GetAbilityCooldownValue()
    local Gradient = Combat.GetAbilityCooldownGradient()
    if not Gradient then return nil end

    local Address = GetMemoryAddress(Gradient)
    if not Address then return nil end

    local Value = ReadSafeFloat(Address + ParryCooldownOffset)
    if Value == nil or Value <= -2 or Value >= 2 then return nil end
    return Value
end

function Combat.IsAbilityReady()
    local Value = Combat.GetAbilityCooldownValue()
    return Value ~= nil and Value == 0.5
end

function Combat.AutoAbility(Ball, Target)
    if not Settings.AutoAbility or not Combat.IsTarget(Target) then return false end
    if not Combat.IsAbilityReady() or not Combat.GetAutoAbility() then return false end
    if TypeOf(KeyPress) ~= "function" or TypeOf(KeyRelease) ~= "function" then return false end

    KeyPress(0x51)
    KeyRelease(0x51)
    return true
end

function Combat.GetParryCooldownGradient()
    local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not Shared.IsInstance(PlayerGui) then return nil end

    local Hotbar = PlayerGui:FindFirstChild("Hotbar")
    if not Shared.IsInstance(Hotbar) then return nil end

    local Block = Hotbar:FindFirstChild("Block")
    if not Shared.IsInstance(Block) then return nil end

    local Gradient = Block:FindFirstChild("UIGradient")
    if not Shared.IsInstance(Gradient) or not Gradient:IsA("UIGradient") then return nil end
    return Gradient
end

function Combat.GetParryCooldownValue()
    local Gradient = Combat.GetParryCooldownGradient()
    if not Gradient then return nil end

    local Address = GetMemoryAddress(Gradient)
    if not Address then return nil end

    local Value = ReadSafeFloat(Address + ParryCooldownOffset)
    if Value == nil or Value <= -2 or Value >= 2 then return nil end
    return Value
end

function Combat.IsParryCooldown()
    local Value = Combat.GetParryCooldownValue()
    return Value ~= nil and Value < 0.4
end

local function ResetCooldownGuard()
    CooldownGuard.Active = false
    CooldownGuard.SawCooldown = false
    CooldownGuard.StartedAt = 0
    CooldownProtectionUsed = false
end

local function BeginCooldownGuard()
    CooldownGuard.Active = true
    CooldownGuard.SawCooldown = false
    CooldownGuard.StartedAt = Clock()
    CooldownProtectionUsed = false
end

function Combat.UpdateCooldownGuard()
    if not CooldownGuard.Active then return false end

    if not Combat.CanCooldownProtect() then
        ResetCooldownGuard()
        return false
    end

    local Value = Combat.GetParryCooldownValue()

    if Value ~= nil then
        if Value < 0.4 then
            CooldownGuard.SawCooldown = true
            return true
        end

        if CooldownGuard.SawCooldown then
            ResetCooldownGuard()
            return false
        end
    end

    if Clock() - CooldownGuard.StartedAt >= 1.35 then
        ResetCooldownGuard()
        return false
    end

    return true
end

function Combat.CooldownProtection(Ball, Target)
    if CooldownProtectionUsed or not Combat.CanCooldownProtect() then return false end
    if not Combat.IsTarget(Target) or not Combat.IsParryCooldown() then return false end
    if TypeOf(KeyPress) ~= "function" or TypeOf(KeyRelease) ~= "function" then return false end

    CooldownProtectionUsed = true
    KeyPress(0x51)
    KeyRelease(0x51)
    return true
end

local function CommitParry(Ball, Target)
    if Combat.AutoAbility(Ball, Target) then
        ParryLockTime = Clock()
        ParriedBall = Ball
        ParriedTarget = Target
        IsParried = true
        ResetCooldownGuard()
        return
    end

    if Combat.UpdateCooldownGuard() then
        Combat.CooldownProtection(Ball, Target)
        return
    end

    local SameLock =
        IsParried
        and ParriedBall == Ball
        and ParriedTarget == Target
        and ParryLockTime > 0
        and Clock() - ParryLockTime < 1

    if SameLock then return end

    ParryLockTime = Clock()
    ParriedBall = Ball
    ParriedTarget = Target
    IsParried = true

    if Combat.CanCooldownProtect() then
        BeginCooldownGuard()
    else
        ResetCooldownGuard()
    end

    Combat.Parry()
end

local function CheckParry()
    if not _G.NightfallActive or not Settings.AutoParry then
        IsParried = false
        ParryLockTime = 0
        ParriedBall = nil
        ParriedTarget = nil
        ResetCooldownGuard()
        BallSpeeds = {}
        AerodynamicStates = {}
        Runtime.TargetSpeed = 0
        Runtime.TargetDistance = 0
        Runtime.TargetDot = 0
        Runtime.ParryRange = ParryBase
        Runtime.ServerDistance = 0
        Runtime.ServerTickLead = 0
        return
    end

    Combat.UpdateCooldownGuard()

    if IsParried then
        if not ParriedBall or not Shared.IsInstance(ParriedBall) or not Shared.GetParent(ParriedBall) then
            IsParried = false
            ParryLockTime = 0
            ParriedBall = nil
            ParriedTarget = nil
        else
            local Target = Shared.GetAttribute(ParriedBall, "target") or Shared.GetAttribute(ParriedBall, "Target")
            if Target ~= ParriedTarget or ParryLockTime > 0 and Clock() - ParryLockTime >= 1 then
                IsParried = false
                ParryLockTime = 0
                ParriedBall = nil
                ParriedTarget = nil
            elseif not CooldownGuard.Active then
                return
            end
        end
    end

    local Character = Shared.GetCharacter(LocalPlayer)
    if not Character then
        IsParried = false
        ParriedBall = nil
        ParriedTarget = nil
        BallSpeeds = {}
        AerodynamicStates = {}
        return
    end

    local RootPart = Character.PrimaryPart
    if not Shared.IsInstance(RootPart) then
        RootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    if not RootPart or TypeOf(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") then
        IsParried = false
        ParriedBall = nil
        ParriedTarget = nil
        BallSpeeds = {}
        AerodynamicStates = {}
        return
    end

    local RootPosition = Shared.GetPartPosition(RootPart)
    if not RootPosition then return end
    local Balls = Combat.GetBalls()

    if #Balls == 0 then
        IsParried = false
        ParriedBall = nil
        ParriedTarget = nil
        BallSpeeds = {}
        AerodynamicStates = {}
        Runtime.TargetSpeed = 0
        Runtime.TargetDistance = 0
        Runtime.TargetDot = 0
        Runtime.ParryRange = ParryBase
        Runtime.ServerDistance = 0
        Runtime.ServerTickLead = 0
        return
    end

    for _, Ball in ipairs(Balls) do
        if Ball and Shared.IsInstance(Ball) and Ball:IsA("BasePart") then
            local Parent = Shared.GetParent(Ball)
            local Velocity = Parent and Ball.AssemblyLinearVelocity or nil
            if Velocity then
                local Position = Shared.GetPartPosition(Ball)
                if not Position then continue end

                local Distance = (RootPosition - Position).Magnitude
                local Speed = Velocity.Magnitude * EffectiveMultiplier
                local MaximumSpeed = Max(BallSpeeds[Ball] or 0, Speed)
                BallSpeeds[Ball] = MaximumSpeed
                local Target = Shared.GetAttribute(Ball, "target") or Shared.GetAttribute(Ball, "Target")

                if not Combat.IsTarget(Target) then
                    continue
                end

                if Combat.IsAerodynamicSlash(Ball, Velocity) then
                    continue
                end

                local BallDirection = Speed > 0.001 and Velocity.Unit or EmptyVector3
                local TargetDirection = Distance > 0.001 and (RootPosition - Position).Unit or EmptyVector3
                local Dot = Speed > 0.001 and Clamp(TargetDirection:Dot(BallDirection), -1, 1) or 1
                local ClosingSpeed = Speed > 0.001 and Max(Velocity:Dot(TargetDirection) * EffectiveMultiplier, 0) or 0
                local TickLead = Combat.GetServerTickLead()
                local ServerDistance = Max(Distance - ClosingSpeed * TickLead, 0)

                Runtime.TargetSpeed = Speed
                Runtime.TargetDistance = Distance
                Runtime.TargetDot = Dot
                Runtime.ServerDistance = ServerDistance
                Runtime.ServerTickLead = TickLead

                local AccuracyMultiplier = 0.9 + (Settings.ParryAccuracy - 1) * (0.35 / 99)
                local BaseDivisor = ParryDivisor * AccuracyMultiplier
                local MinimumTrajectory = BaseDivisor / ParryMaxDivisor
                local Trajectory = Clamp(Dot, MinimumTrajectory, 1)
                local Ping = Combat.GetPing()
                local OneWayLatency = Min(Ping / 2000, ExtrapolationLimit)
                local ReachTime = MaximumSpeed > 0.001 and Max(Distance / MaximumSpeed - OneWayLatency, 0) or Infinite
                local ResolverWindow = SimulationInterval * 6
                local ResolverTime = Clamp(ReachTime / ResolverWindow, 0, 1)
                local ResolvedTrajectory = 1 - (1 - Trajectory) * ResolverTime
                local Divisor = Clamp(BaseDivisor / ResolvedTrajectory, BaseDivisor, ParryMaxDivisor)
                local ExtrapolationTicks = Clamp((Ping / 1000) * 30, ExtrapolationMinTicks, ExtrapolationMaxTicks)
                local ExtrapolationTime = ExtrapolationTicks / 60
                local ResolvedSpeed = Speed * ResolvedTrajectory
                local Travel = ResolvedSpeed * ExtrapolationTime
                local FinalThreshold = ParryBase + Speed / Divisor + Travel
                local CloseRangeThreshold = math.max(10, FinalThreshold * 0.5)

                if ServerDistance <= CloseRangeThreshold then
                    Runtime.ParryRange = CloseRangeThreshold
                    CommitParry(Ball, Target)
                    return
                end

                local PullUser = Combat.GetPullUser()
                if PullUser and PullUser ~= LocalPlayer then
                    IsParried = false
                    ParryLockTime = 0
                    ParriedBall = nil
                    ParriedTarget = nil
                    Runtime.ParryRange = ParryBase
                    return
                end

                Runtime.ParryRange = FinalThreshold

                if ServerDistance <= FinalThreshold then
                    CommitParry(Ball, Target)
                    return
                end
            end
        end
    end
end



_G.NightfallParryPreConnection = Stepped:Connect(CheckParry)
_G.NightfallParryPostConnection = Heartbeat:Connect(function(DeltaTime)
    if Shared.IsValidNumber(DeltaTime) and DeltaTime > 0 then
        local Step = Clamp(DeltaTime, 1 / 240, 1 / 20)
        SimulationInterval = SimulationInterval + (Step - SimulationInterval) * SimulationResponse
    end

    CheckParry()
end)

local SpamCredit = 0
local AutoSpamActive = false
local WindowActive = true
local NextWindowCheck = 0
local SpamInputBudget = 0.00125
local SpamClickBurst = 8
local SpamKeyBurst = 4

function Combat.IsWindowActive()
    local Time = Clock()
    if Time < NextWindowCheck then return WindowActive end
    NextWindowCheck = Time + 0.25

    if Type(isrbxactive) ~= "function" then
        WindowActive = true
        return true
    end

    WindowActive = isrbxactive() ~= false
    return WindowActive
end

function Combat.ParryBatch(Count, Track, Budget)
    Count = Floor(ToNumber(Count) or 0)
    if Count <= 0 then return 0 end

    local Method = Settings.ParryMethod
    local Limit = Method == "Key" and SpamKeyBurst or SpamClickBurst
    Count = Min(Count, Limit)

    local Fired = 0
    local Started = Clock()
    Budget = ToNumber(Budget) or SpamInputBudget

    if Method == "Click" then
        if TypeOf(Click) ~= "function" then return 0 end

        for _ = 1, Count do
            Click()
            Fired = Fired + 1
            if Fired >= 2 and Clock() - Started >= Budget then break end
        end
    elseif Method == "Key" then
        if TypeOf(KeyPress) ~= "function" or TypeOf(KeyRelease) ~= "function" then return 0 end

        for _ = 1, Count do
            KeyPress(0x46)
            KeyRelease(0x46)
            Fired = Fired + 1
            if Fired >= 2 and Clock() - Started >= Budget then break end
        end
    end

    if Track and Fired > 0 and TypeOf(RecordSpamParry) == "function" then
        RecordSpamParry(Fired)
    end

    return Fired
end

local SpamParries = {}
local SpamBall = nil
local SpamParryLife = 0.5
local SpamDivisor = 8.5
local SpamMinRange = 30
local SpamMaxRange = 65

local function UpdateSpamParries(Now)
    while #SpamParries > 0 and Now - SpamParries[1] >= SpamParryLife do
        Remove(SpamParries, 1)
    end
end

local function ResetSpamParries(Ball)
    Clear(SpamParries)
    SpamBall = Ball
end

RecordSpamParry = function(Count)
    local Now = Clock()
    UpdateSpamParries(Now)

    local Available = Max(8 - #SpamParries, 0)
    local Add = Min(Floor(ToNumber(Count) or 1), Available)
    if Add <= 0 then return false end

    for _ = 1, Add do
        Insert(SpamParries, Now)
    end

    return true
end

local function GetSpamBall()
    local BallsFolder = Workspace:FindFirstChild("Balls")
    if not Shared.IsInstance(BallsFolder) then return nil end

    for _, Ball in ipairs(BallsFolder:GetChildren()) do
        if Shared.IsInstance(Ball) and Ball:IsA("BasePart") and Shared.GetAttribute(Ball, "realBall") then
            return Ball
        end
    end

    return nil
end

local function GetClosestEntity(RootPosition)
    local AliveFolder = Workspace:FindFirstChild("Alive")
    local Character = Shared.GetCharacter(LocalPlayer)
    if not Shared.IsInstance(AliveFolder) or not Character then return nil, Infinite end

    local Closest = nil
    local ClosestDistance = Infinite

    for _, Entity in ipairs(AliveFolder:GetChildren()) do
        if Shared.IsInstance(Entity) and Entity ~= Character then
            local PrimaryPart = Entity.PrimaryPart
            if not Shared.IsInstance(PrimaryPart) then
                PrimaryPart = Entity:FindFirstChild("HumanoidRootPart")
            end

            local Position = Shared.GetPartPosition(PrimaryPart)
            if Position then
                local Distance = (RootPosition - Position).Magnitude
                if Distance < ClosestDistance then
                    Closest = Entity
                    ClosestDistance = Distance
                end
            end
        end
    end

    return Closest, ClosestDistance
end

local function GetSpamRange(Ball, RootPosition, EntityDistance, PingMs)
    if not Ball then return 0 end

    local Entity = GetClosestEntity(RootPosition)
    if not Entity then return 0 end

    local EntityPart = Entity.PrimaryPart
    if not Shared.IsInstance(EntityPart) then
        EntityPart = Entity:FindFirstChild("HumanoidRootPart")
    end

    local EntityPosition = Shared.GetPartPosition(EntityPart)
    local BallPosition = Shared.GetPartPosition(Ball)
    local Velocity = Ball.AssemblyLinearVelocity

    if not EntityPosition or not BallPosition or not Velocity then return 0 end

    local BallDistance = (RootPosition - BallPosition).Magnitude
    local Speed = Velocity.Magnitude
    local EffectiveSpeed = Speed * EffectiveMultiplier
    local Direction = BallDistance > 0.001 and (RootPosition - BallPosition).Unit or EmptyVector3
    local Dot = Speed > 0.001 and Clamp(Direction:Dot(Velocity.Unit), -1, 1) or 0
    local TargetDistance = (RootPosition - EntityPosition).Magnitude
    local ExtrapolationTicks = Clamp((PingMs / 1000) * 30, ExtrapolationMinTicks, ExtrapolationMaxTicks)
    local ExtrapolationTime = ExtrapolationTicks / 60
    local MaximumSpamDistance = Clamp(EffectiveSpeed / SpamDivisor + EffectiveSpeed * ExtrapolationTime, SpamMinRange, SpamMaxRange)

    if EntityDistance > MaximumSpamDistance then return 0 end
    if BallDistance > MaximumSpamDistance then return 0 end
    if TargetDistance > MaximumSpamDistance then return 0 end

    local MaximumSpeed = 5 - Min(Speed / 5, 5)
    local MaximumDot = Clamp(Dot, -1, 0) * MaximumSpeed

    return Clamp(MaximumSpamDistance - MaximumDot, SpamMinRange, SpamMaxRange)
end

local function CheckAutoSpam()
    AutoSpamActive = false

    local Ball = GetSpamBall()
    if Ball ~= SpamBall then
        ResetSpamParries(Ball)
    end

    UpdateSpamParries(Clock())

    if not _G.NightfallActive or not Settings.AutoSpam then
        return
    end

    if not Ball then
        return
    end

    local Zoomies = Ball:FindFirstChild("zoomies")
    if not Shared.IsInstance(Zoomies) then
        return
    end

    local Character = Shared.GetCharacter(LocalPlayer)
    if not Character then return end

    local RootPart = Character.PrimaryPart
    if not Shared.IsInstance(RootPart) then
        RootPart = Character:FindFirstChild("HumanoidRootPart")
    end

    local RootPosition = Shared.GetPartPosition(RootPart)
    local BallPosition = Shared.GetPartPosition(Ball)
    if not RootPosition or not BallPosition then return end

    local Entity, EntityDistance = GetClosestEntity(RootPosition)
    if not Entity then return end

    local EntityPart = Entity.PrimaryPart
    if not Shared.IsInstance(EntityPart) then
        EntityPart = Entity:FindFirstChild("HumanoidRootPart")
    end

    local TargetPosition = Shared.GetPartPosition(EntityPart)
    if not TargetPosition then return end

    local Ping = Combat.GetPing()
    local Target = Shared.GetAttribute(Ball, "target") or Shared.GetAttribute(Ball, "Target")
    local SpamAccuracy = GetSpamRange(Ball, RootPosition, EntityDistance, Ping)
    local TargetDistance = (RootPosition - TargetPosition).Magnitude
    local Distance = (RootPosition - BallPosition).Magnitude

    if Target == nil then return end
    if TargetDistance > SpamAccuracy or Distance > SpamAccuracy then return end

    local Pulsed = Shared.GetAttribute(Character, "Pulsed")
    if Pulsed then return end

    if Combat.IsTarget(Target) and TargetDistance > 30 and Distance > 30 then
        return
    end

    if Distance <= SpamAccuracy and #SpamParries > (ToNumber(Settings.ParryThreshold) or 2.5) then
        AutoSpamActive = true
    end
end

if _G.NightfallAutoSpamPreConnection then
    Shared.Disconnect(_G.NightfallAutoSpamPreConnection)
    _G.NightfallAutoSpamPreConnection = nil
end

if _G.NightfallAutoSpamPostConnection then
    Shared.Disconnect(_G.NightfallAutoSpamPostConnection)
    _G.NightfallAutoSpamPostConnection = nil
end

_G.NightfallAutoSpamPreConnection = Stepped:Connect(CheckAutoSpam)

if _G.NightfallSpamConnection then
    Shared.Disconnect(_G.NightfallSpamConnection)
    _G.NightfallSpamConnection = nil
end

_G.NightfallSpamConnection = Heartbeat:Connect(function(DeltaTime)
    if not _G.NightfallActive then
        SpamCredit = 0
        return
    end

    local ManualActive = Settings.ManualSpam and Combat.IsWindowActive()
    local AutomaticActive = Settings.AutoSpam and AutoSpamActive

    if not ManualActive and not AutomaticActive then
        SpamCredit = 0
        return
    end

    local Delta = Type(DeltaTime) == "number" and Clamp(DeltaTime, 0.001, 0.05) or (1 / 60)
    local Rate = Clamp(ToNumber(Settings.SpamRate) or 200, 200, 1000)
    local Credit = SpamCredit + Rate * Delta
    local Count = Floor(Credit)

    SpamCredit = Credit - Count
    if Count <= 0 then return end

    local Budget = Min(SpamInputBudget, Delta * 0.12)
    Combat.ParryBatch(Count, AutomaticActive, Budget)
end)

function Visuals.GetTrailColor(Offset, Index, Total)
    local Alpha = 1.0 - Pow(Index / Total, 1.5)
    local Opacity = Max(Alpha * Alpha * Alpha, 0.05)
    if not Settings.Rainbow then
        return Settings.TrailColor, Opacity
    end
    local Time = Clock() * 2.5 + Offset + Index * 0.1
    local R = (Sin(Time) * 0.5 + 0.5) * 0.95 + 0.05
    local G = (Sin(Time + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
    local B = (Sin(Time + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
    return NewColor3(R, G, B), Opacity
end

function Visuals.RenderTrail(Position)
    if not Settings.BallTrail or not Shared.IsValidVector3(Position) then
        for _, Line in ipairs(Visuals.TrailLines) do
            if Line then Line.Visible = false end
        end
        Clear(Visuals.TrailPoints)
        return
    end

    local LastPosition = Visuals.TrailPoints[1]
    if not Shared.IsValidVector3(LastPosition) or (LastPosition - Position).Magnitude > 0.05 then
        Insert(Visuals.TrailPoints, 1, Position)
    end

    local TrailLength = Clamp(ToNumber(Settings.TrailLength) or 60, 3, MaxTrailLines)
    while #Visuals.TrailPoints > TrailLength do
        Remove(Visuals.TrailPoints)
    end

    local Count = #Visuals.TrailPoints
    if Count < 2 then
        for _, Line in ipairs(Visuals.TrailLines) do
            if Line then Line.Visible = false end
        end
        return
    end

    local BaseOffset = Clock() * 1.5
    for Index = 2, Count do
        local Line = Visuals.TrailLines[Index - 1]
        if not Line then break end

        local From = Visuals.TrailPoints[Index - 1]
        local To = Visuals.TrailPoints[Index]
        if Shared.IsValidVector3(From) and Shared.IsValidVector3(To) then
            local FromScreen, Visible1 = Project(From)
            local ToScreen, Visible2 = Project(To)

            if Visible1 and Visible2 and Shared.IsValidVector2(FromScreen) and Shared.IsValidVector2(ToScreen) then
                local Color, Opacity = Visuals.GetTrailColor(BaseOffset, Index, Count)
                Line.From = FromScreen
                Line.To = ToScreen
                Line.Color = Color
                Line.Transparency = Opacity
                Line.Thickness = (ToNumber(Settings.TrailThickness) or 2) * (1 - Pow(Index / Count, 1.5))
                Line.Visible = true
            else
                Line.Visible = false
            end
        else
            Line.Visible = false
        end
    end

    for Index = Count, #Visuals.TrailLines do
        local Line = Visuals.TrailLines[Index]
        if Line then Line.Visible = false end
    end
end

local TriggerParried = false
local TriggerLockTime = 0
local TriggerParriedBall = nil
local TriggerParriedTarget = nil
local TriggerStates = {}
local VisualRoot = nil
local EspPositions = {}
local CachedCharacter = nil
local CharacterLoaded = false

if _G.NightfallTriggerPreConnection then
    Shared.Disconnect(_G.NightfallTriggerPreConnection)
    _G.NightfallTriggerPreConnection = nil
end

if _G.NightfallTriggerPostConnection then
    Shared.Disconnect(_G.NightfallTriggerPostConnection)
    _G.NightfallTriggerPostConnection = nil
end

local function ResetTrigger()
    TriggerParried = false
    TriggerLockTime = 0
    TriggerParriedBall = nil
    TriggerParriedTarget = nil
    TriggerStates = {}
end

local function CheckTrigger()
    if not _G.NightfallActive or not Settings.TriggerBot then
        ResetTrigger()
        return
    end

    local Character = Shared.GetCharacter(LocalPlayer)
    if not Character then return end

    local RootPart = Character.PrimaryPart
    if not Shared.IsInstance(RootPart) then RootPart = Character:FindFirstChild("HumanoidRootPart") end
    if not RootPart or not Shared.IsInstance(RootPart) or not RootPart:IsA("BasePart") or not Shared.GetParent(RootPart) then return end
    if Character:FindFirstChild("SingularityCape") or RootPart:FindFirstChild("SingularityCape") then return end

    local DeadFolder = Workspace:FindFirstChild("Dead")
    local LocalName = Shared.GetName(LocalPlayer)
    if LocalName and Shared.IsInstance(DeadFolder) and DeadFolder:FindFirstChild(LocalName) then return end

    local Now = Clock()

    if TriggerParried then
        if not TriggerParriedBall or not Shared.IsInstance(TriggerParriedBall) or not Shared.GetParent(TriggerParriedBall) then
            TriggerParried = false
            TriggerLockTime = 0
            TriggerParriedBall = nil
            TriggerParriedTarget = nil
        else
            local CurrentTarget = Shared.GetAttribute(TriggerParriedBall, "target") or Shared.GetAttribute(TriggerParriedBall, "Target")
            if CurrentTarget ~= TriggerParriedTarget or TriggerLockTime > 0 and Now - TriggerLockTime >= 1 then
                TriggerParried = false
                TriggerLockTime = 0
                TriggerParriedBall = nil
                TriggerParriedTarget = nil
            end
        end
    end

    for Ball in pairs(TriggerStates) do
        if not Shared.IsInstance(Ball) or not Shared.GetParent(Ball) then
            TriggerStates[Ball] = nil
        end
    end

    local Balls = Combat.GetBalls()
    if #Balls == 0 then return end

    for _, Ball in ipairs(Balls) do
        if not Ball or not Shared.IsInstance(Ball) or not Ball:IsA("BasePart") then continue end

        local Parent = Shared.GetParent(Ball)
        if not Parent or Shared.GetName(Parent) == "TrainingBalls" then continue end

        local Target = Shared.GetAttribute(Ball, "target") or Shared.GetAttribute(Ball, "Target")
        local State = TriggerStates[Ball]

        if not State then
            State = {
                Target = Target,
                SeenTarget = Target ~= nil,
                Redirected = false,
                TargetTime = Now,
                FireTime = 0
            }
            TriggerStates[Ball] = State
        elseif Target ~= State.Target then
            if not State.SeenTarget and Target ~= nil then
                State.SeenTarget = true
            elseif State.SeenTarget then
                State.Redirected = true
            end

            State.Target = Target
            State.TargetTime = Now
            State.FireTime = 0
        end

        if not Combat.IsTarget(Target) then
            State.FireTime = 0
            continue
        end

        if Settings.TriggerIgnoreSpawn and not State.Redirected then
            State.FireTime = 0
            continue
        end

        if TriggerParried and TriggerParriedBall == Ball and TriggerParriedTarget == Target then
            State.FireTime = 0
            continue
        end

        if IsParried and ParriedBall == Ball and ParriedTarget == Target then
            State.FireTime = 0
            continue
        end

        if State.FireTime == 0 then
            State.FireTime = State.TargetTime + Max(Settings.TriggerDelay or 0, 0) / 1000
        end

        if Now >= State.FireTime then
            TriggerParried = true
            TriggerLockTime = Now
            TriggerParriedBall = Ball
            TriggerParriedTarget = Target
            State.FireTime = 0

            IsParried = true
            ParryLockTime = Now
            ParriedBall = Ball
            ParriedTarget = Target

            Combat.Parry()
            return
        end
    end
end

_G.NightfallTriggerPreConnection = Stepped:Connect(CheckTrigger)
_G.NightfallTriggerPostConnection = Heartbeat:Connect(CheckTrigger)

RenderStepped:Connect(function(DeltaTime)
    if not Shared.IsValidNumber(DeltaTime) then DeltaTime = 0.016 end
    local Time = Clock()
    local Ball = Combat.GetBall()
    local BallPosition = Shared.GetPartPosition(Ball)
    Visuals.RenderTrail(BallPosition)

    if Settings.AbilityEsp then
        local PlayerList = Players:GetPlayers()
        for Index = 1, #PlayerList do
            local Player = PlayerList[Index]
            if Shared.IsInstance(Player) and Player ~= LocalPlayer then
                local Name = Shared.GetName(Player)
                if not Name or Name == "" then continue end
                local Character = Shared.GetCharacter(Player)
                local Humanoid = Shared.IsInstance(Character) and Character:FindFirstChildWhichIsA("Humanoid") or nil
                local Head = Shared.IsInstance(Character) and Character:FindFirstChild("Head") or nil
                local Ability = Shared.GetAttribute(Player, "CurrentlyEquippedAbility")
                local HeadPosition = Shared.GetPartPosition(Head)

                local Health = Humanoid and ToNumber(Humanoid.Health) or 0
                if Humanoid and Health > 0 and HeadPosition and Ability and ToString(Ability) ~= "" then
                    local WorldPosition = HeadPosition + NewVector3(0, ToNumber(Settings.EspOffset) or 2, 0)
                    local ScreenPosition, IsOnScreen = Project(WorldPosition)
                    local Text = Visuals.Esp[Name]

                    if IsOnScreen and Shared.IsValidVector2(ScreenPosition) and ScreenPosition.X > 0 and ScreenPosition.Y > 0 then
                        if not Text then
                            Text = Visuals.CreateEspText()
                            Visuals.Esp[Name] = Text
                        end

                        if Text then
                            local Color = TypeOf(Settings.EspColor) == "Color3" and Settings.EspColor or NewRGB(220, 30, 30)
                            local DrawPosition = ScreenPosition
                            local Previous = EspPositions[Name]
                            if Shared.IsValidVector2(Previous) then
                                local Alpha = Clamp(DeltaTime * 32, 0, 1)
                                DrawPosition = NewVector2(
                                    Previous.X + (ScreenPosition.X - Previous.X) * Alpha,
                                    Previous.Y + (ScreenPosition.Y - Previous.Y) * Alpha
                                )
                            end

                            EspPositions[Name] = DrawPosition
                            Text.Position = DrawPosition
                            Text.FontSize = ToNumber(Settings.EspTextSize) or 18
                            Text.Text = ToString(Ability)

                            if Settings.Rainbow then
                                local Hue = Time * 2.5
                                Text.Color = NewColor3(
                                    (Sin(Hue) * 0.5 + 0.5) * 0.95 + 0.05,
                                    (Sin(Hue + 2.094) * 0.5 + 0.5) * 0.95 + 0.05,
                                    (Sin(Hue + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                                )
                            else
                                Text.Color = Color
                            end
                            Text.Visible = true
                        end
                    elseif Text then
                        Text.Visible = false
                    end
                else
                    local Text = Visuals.Esp[Name]
                    if Text then Text.Visible = false end
                end
            end
        end

        for Name, Text in pairs(Visuals.Esp) do
            if not Players:FindFirstChild(Name) then
                if Text and Type(Text.Remove) == "function" then Text:Remove() end
                Visuals.Esp[Name] = nil
                EspPositions[Name] = nil
            end
        end
    else
        for _, Text in pairs(Visuals.Esp) do
            if Text then Text.Visible = false end
        end
    end

    local Character = Shared.GetCharacter(LocalPlayer)
    local RootPart = Shared.IsInstance(Character) and Character:FindFirstChild("HumanoidRootPart") or nil
    local RootPosition = Shared.GetPartPosition(RootPart)

    if Settings.ParryRangeEnabled and RootPosition then
        local VisualPosition = RootPosition - NewVector3(0, 3, 0)
        if not Shared.IsValidVector3(VisualRoot) then
            VisualRoot = VisualPosition
        else
            VisualRoot = VisualRoot:Lerp(VisualPosition, Clamp(DeltaTime * 18, 0, 1))
        end

        local Center = VisualRoot
        local Radius = Shared.IsValidNumber(Runtime.ParryRange) and Runtime.ParryRange or ParryBase
        SmoothParryRadius = SmoothParryRadius + (Radius - SmoothParryRadius) * Clamp(DeltaTime * 20, 0, 1)
        local DrawRadius = Max(SmoothParryRadius, 5)
        local Segments = Clamp(ToNumber(Settings.RangeSegments) or 40, 10, 100)
        local Step = math.pi * 2 / Segments

        for Index = 1, 100 do
            local Line = Visuals.RangeLines[Index]
            if Line then
                if Index <= Segments then
                    local Angle1 = (Index - 1) * Step
                    local Angle2 = Index * Step
                    local WorldA = Center + NewVector3(math.cos(Angle1) * DrawRadius, 0, Sin(Angle1) * DrawRadius)
                    local WorldB = Center + NewVector3(math.cos(Angle2) * DrawRadius, 0, Sin(Angle2) * DrawRadius)
                    local ScreenA, VisibleA = Project(WorldA)
                    local ScreenB, VisibleB = Project(WorldB)

                    if VisibleA and VisibleB and Shared.IsValidVector2(ScreenA) and Shared.IsValidVector2(ScreenB) then
                        Line.From = ScreenA
                        Line.To = ScreenB
                        Line.Thickness = ToNumber(Settings.RangeThickness) or 2
                        Line.Transparency = ToNumber(Settings.RangeTransparency) or 1

                        if Settings.Rainbow then
                            local Offset = Time * 2.5 + Index / Segments * math.pi * 2
                            Line.Color = NewColor3(
                                (Sin(Offset) * 0.5 + 0.5) * 0.95 + 0.05,
                                (Sin(Offset + 2.094) * 0.5 + 0.5) * 0.95 + 0.05,
                                (Sin(Offset + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                            )
                        else
                            Line.Color = TypeOf(Settings.ParryRangeColor) == "Color3" and Settings.ParryRangeColor or NewRGB(220, 30, 30)
                        end
                        Line.Visible = true
                    else
                        Line.Visible = false
                    end
                else
                    Line.Visible = false
                end
            end
        end
    else
        VisualRoot = nil
        for Index = 1, 100 do
            local Line = Visuals.RangeLines[Index]
            if Line then Line.Visible = false end
        end
    end
end)

Heartbeat:Connect(function()
    local Character = Shared.GetCharacter(LocalPlayer)

    if Character ~= CachedCharacter then
        if CachedCharacter then
            RestoreHeadless()
            RestoreCache(CharacterVisualState.KorbloxParts)
            CharacterVisualState.Meshes = {}
        end
        CachedCharacter = Character
        CharacterLoaded = false
    end

    if Shared.IsInstance(Character) and not CharacterLoaded then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if Shared.IsInstance(RootPart) then
            CharacterLoaded = true
            Spawn(function()
                Wait(0.5)
                if Settings.Headless then Visuals.ApplyHeadless(true) end
                if Settings.Korblox then Visuals.ApplyKorblox(true) end
            end)
        end
    end

    if Shared.IsInstance(Character) and CharacterLoaded then
        if Settings.Headless then
            local Head = Character:FindFirstChild("Head")
            local HeadSize = Shared.GetPartSize(Head)
            if HeadSize and HeadSize.X > 0.1 then Visuals.ApplyHeadless(true) end
        end
        if Settings.Korblox then
            local RightLeg = Character:FindFirstChild("RightUpperLeg") or Character:FindFirstChild("Right Leg")
            local RightLegSize = Shared.GetPartSize(RightLeg)
            if RightLegSize and RightLegSize.X > 0.1 then Visuals.ApplyKorblox(true) end
        end
    end


    if Settings.InfinityDetection then
        local Detected = false
        local InfinityFolder = Workspace:FindFirstChild("Runtime")
        if Shared.IsInstance(InfinityFolder) then
            if InfinityFolder:FindFirstChild("InfinityFX") or InfinityFolder:FindFirstChild("TrueInfinityFX") then
                Detected = true
            end
        end
        local BallsFolder = Workspace:FindFirstChild("Balls")
        if Shared.IsInstance(BallsFolder) then
            for _, Ball in ipairs(BallsFolder:GetChildren()) do
                if Shared.IsInstance(Ball) and Ball:IsA("BasePart") then
                    local BodyPart = Ball:FindFirstChild("Body")
                    if Shared.IsInstance(BodyPart) and BodyPart:FindFirstChild("WEMAZOOKIEGO") then
                        Detected = true
                        break
                    end
                end
            end
        end
        if Character and Character:FindFirstChild("Parry") then
            Detected = true
        end

        if Detected then
            if Settings.AutoParry then
                Settings.AutoParry = false
                Settings.InfinityDisabledParry = true
            end
            if Settings.TriggerBot then
                Settings.TriggerBot = false
                Settings.InfinityDisabledTrigger = true
            end
        else
            if Settings.InfinityDisabledParry then
                Settings.AutoParry = true
                Settings.InfinityDisabledParry = false
            end
            if Settings.InfinityDisabledTrigger then
                Settings.TriggerBot = true
                Settings.InfinityDisabledTrigger = false
            end
        end
    end

    if Settings.FuryDetection then
        local Fury, Combo = Combat.GetFuryState()

        if Fury and Combo < 34 and not Settings.FuryActive then
            Settings.FuryActive = true

            if Settings.AutoParry then
                Settings.AutoParry = false
                Settings.FuryDisabledParry = true
            end

            if Settings.TriggerBot then
                Settings.TriggerBot = false
                Settings.FuryDisabledTrigger = true
            end

            Spawn(function()
                while Settings.FuryDetection do
                    local Active, Combo = Combat.GetFuryState()

                    if not Active or Combo >= 34 then
                        break
                    end

                    Combat.Parry()
                    Wait(0.15)
                end

                if Settings.FuryDisabledParry then
                    Settings.AutoParry = true
                    Settings.FuryDisabledParry = false
                end

                if Settings.FuryDisabledTrigger then
                    Settings.TriggerBot = true
                    Settings.FuryDisabledTrigger = false
                end

                Settings.FuryActive = false
            end)
        end
    else
        if Settings.FuryDisabledParry then
            Settings.AutoParry = true
            Settings.FuryDisabledParry = false
        end

        if Settings.FuryDisabledTrigger then
            Settings.TriggerBot = true
            Settings.FuryDisabledTrigger = false
        end

        Settings.FuryActive = false
    end

end)

RenderStepped:Connect(function(DeltaTime)
    if not Settings.Orbit then return end
    if not Shared.IsValidNumber(DeltaTime) then DeltaTime = 0.016 end

    local AliveFolder = Workspace:FindFirstChild("Alive")
    local LocalName = Shared.GetName(LocalPlayer)
    if not LocalName or not Shared.IsInstance(AliveFolder) or not AliveFolder:FindFirstChild(LocalName) then return end

    local Ball = Combat.GetBall()
    local BallPosition = Shared.GetPartPosition(Ball)
    if not BallPosition then return end

    local Character = Shared.GetCharacter(LocalPlayer)
    if not Character then return end

    local RootPart = Character.PrimaryPart
    if not RootPart or TypeOf(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") then
        RootPart = Character:FindFirstChild("HumanoidRootPart")
    end

    local RootPosition = Shared.GetPartPosition(RootPart)
    if not RootPosition then return end

    local OrbitRadius = ToNumber(Settings.OrbitRadius) or 25
    local OrbitHeight = ToNumber(Settings.OrbitHeight) or 5
    local OrbitSpeed = ToNumber(Settings.OrbitSpeed) or 50
    local Time = Clock() * OrbitSpeed / 50
    local Destination = NewVector3(
        BallPosition.X + math.cos(Time) * OrbitRadius,
        BallPosition.Y + OrbitHeight,
        BallPosition.Z + Sin(Time) * OrbitRadius
    )

    if Shared.GetParent(RootPart) then
        RootPart.Position = RootPosition:Lerp(Destination, Clamp(DeltaTime * 35, 0, 0.65))
    end
end)
