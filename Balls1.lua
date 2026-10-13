
local Previous = _G.MatchaTallin
if Previous and Previous.Unload then pcall(function() Previous:Unload() end) end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local function Clamp(V, A, B)
    return math.max(A, math.min(B, V))
end

local function Round(V)
    return math.floor(V + 0.5)
end

local function V2(X, Y)
    return Vector2.new(Round(X), Round(Y))
end

local function RGB(R, G, B)
    return Color3.fromRGB(R, G, B)
end

local function InBox(X, Y, A, B, W, H)
    return X >= A and X <= A + W and Y >= B and Y <= B + H
end

local function CopyArray(A)
    local B = {}
    for I, V in ipairs(A or {}) do B[I] = V end
    return B
end

local function HSV(H, S, V)
    H = (H % 1 + 1) % 1
    S = Clamp(S, 0, 1)
    V = Clamp(V, 0, 1)
    local C = V * S
    local Q = H * 6
    local X = C * (1 - math.abs(Q % 2 - 1))
    local R, G, B
    if Q < 1 then R, G, B = C, X, 0
    elseif Q < 2 then R, G, B = X, C, 0
    elseif Q < 3 then R, G, B = 0, C, X
    elseif Q < 4 then R, G, B = 0, X, C
    elseif Q < 5 then R, G, B = X, 0, C
    else R, G, B = C, 0, X end
    local M = V - C
    return Color3.new(R + M, G + M, B + M)
end

local function ToHSV(Color)
    if not Color then return 0, 0, 1 end
    local R, G, B = Color.R, Color.G, Color.B
    local Max = math.max(R, G, B)
    local Min = math.min(R, G, B)
    local Delta = Max - Min
    local H = 0
    if Delta > 0 then
        if Max == R then H = ((G - B) / Delta) % 6
        elseif Max == G then H = (B - R) / Delta + 2
        else H = (R - G) / Delta + 4 end
        H = H / 6
    end
    return H, Max == 0 and 0 or Delta / Max, Max
end

local Themes = {
    Default = {
        Background = RGB(21, 21, 23),
        Header = RGB(29, 29, 32),
        Section = RGB(25, 25, 27),
        SectionHeader = RGB(35, 35, 38),
        Control = RGB(37, 37, 41),
        ControlHover = RGB(49, 49, 54),
        Border = RGB(61, 61, 66),
        Text = RGB(241, 240, 243),
        Muted = RGB(153, 152, 160),
        Accent = RGB(191, 190, 238),
        AccentDark = RGB(109, 109, 136),
        ToggleOff = RGB(65, 65, 71)
    }
}
Themes.Current = {}
for K, V in pairs(Themes.Default) do Themes.Current[K] = V end

local KeyNames = {
    [1] = "LMB", [2] = "RMB", [4] = "MMB", [5] = "MB4", [6] = "MB5",
    [8] = "Backspace", [9] = "Tab", [13] = "Enter", [16] = "Shift", [17] = "Ctrl", [18] = "Alt",
    [20] = "CapsLock", [27] = "Esc", [32] = "Space", [33] = "PageUp", [34] = "PageDown",
    [35] = "End", [36] = "Home", [37] = "Left", [38] = "Up", [39] = "Right", [40] = "Down",
    [45] = "Insert", [46] = "Delete", [186] = ";", [187] = "=", [188] = ",", [189] = "-",
    [190] = ".", [191] = "/", [192] = "`", [219] = "[", [220] = "\\", [221] = "]", [222] = "'"
}
for I = 48, 57 do KeyNames[I] = string.char(I) end
for I = 65, 90 do KeyNames[I] = string.char(I) end
for I = 96, 105 do KeyNames[I] = "Num" .. tostring(I - 96) end
for I = 112, 123 do KeyNames[I] = "F" .. tostring(I - 111) end
local Codes = {}
for Code, Name in pairs(KeyNames) do Codes[string.lower(Name)] = Code end
Codes.none = 0
Codes.rightshift = 161
Codes.leftshift = 160
Codes.mouse1 = 1
Codes.mouse2 = 2

local function GetCode(V)
    if type(V) == "number" then return V end
    return Codes[string.lower(tostring(V or "None"))] or 0
end

local function GetKeyName(Code)
    return KeyNames[GetCode(Code)] or (GetCode(Code) == 0 and "None" or tostring(Code))
end

local function Pressed(Code)
    if Code == 0 then return false end
    if Code == 1 and type(ismouse1pressed) == "function" then return ismouse1pressed() or false end
    if Code == 2 and type(ismouse2pressed) == "function" then return ismouse2pressed() or false end
    return type(iskeypressed) == "function" and (iskeypressed(Code) or false) or false
end

local Library = {
    Name = "Tallin Matcha",
    Version = "1.0.0",
    Flags = {},
    Elements = {},
    Windows = {},
    Drawings = {},
    Connections = {},
    Unloaded = false,
    Open = true,
    MenuKeybind = 113,
    SizeValue = V2(516, 610),
    TextY = 0,
    Settings = { MenuKeybind = "F2" },
    _id = 0,
    _frame = 0,
    _lastKeys = {},
    _mouseDown = false,
    _rightDown = false,
    _mx = 0,
    _my = 0,
    _click = false,
    _rightClick = false,
    _popup = nil,
    _editing = nil,
    _capture = nil,
    _drag = nil,
    _sliding = nil,
    _pickerDrag = nil,
    _notifications = {},
    _configDirty = false,
    ConfigFolder = "MatchaTallinConfigs"
}

local function NewId()
    Library._id = Library._id + 1
    return tostring(Library._id)
end

local function NewDrawing(Kind)
    local Obj = Drawing.new(Kind)
    Obj.Visible = false
    Obj.Transparency = 1
    Library.Drawings[#Library.Drawings + 1] = Obj
    return Obj
end

local function GetDrawing(Id, Kind)
    local Item = Library._canvas[Id]
    if Item then return Item.Object end
    local Obj = NewDrawing(Kind)
    Item = { Object = Obj, Frame = -1 }
    Library._canvas[Id] = Item
    return Obj
end
Library._canvas = {}

local function Mark(Id)
    Library._canvas[Id].Frame = Library._frame
end

local function Square(Id, X, Y, W, H, Color, Z)
    if W <= 0 or H <= 0 then return end
    local Obj = GetDrawing(Id, "Square")
    Obj.Position = V2(X, Y)
    Obj.Size = V2(W, H)
    Obj.Color = Color
    Obj.Filled = true
    Obj.Transparency = 1
    Obj.ZIndex = Z or 1
    Obj.Visible = true
    Mark(Id)
end

local function Text(Id, S, X, Y, Color, Size, Center, Z)
    local Obj = GetDrawing(Id, "Text")
    Obj.Text = tostring(S or "")
    Obj.Position = V2(X, Y + Library.TextY)
    Obj.Color = Color
    Obj.FontSize = Size or 13
    if Drawing.Fonts then Obj.Font = Drawing.Fonts.System or Drawing.Fonts.UI end
    Obj.Center = Center or false
    Obj.Outline = false
    Obj.Transparency = 1
    Obj.ZIndex = Z or 2
    Obj.Visible = true
    Mark(Id)
end

local function Line(Id, X, Y, X2, Y2, Color, Z)
    local Obj = GetDrawing(Id, "Line")
    Obj.From = V2(X, Y)
    Obj.To = V2(X2, Y2)
    Obj.Color = Color
    Obj.Thickness = 1
    Obj.Transparency = 1
    Obj.ZIndex = Z or 2
    Obj.Visible = true
    Mark(Id)
end

local function Call(Callback, Value)
    if type(Callback) == "function" then
        local Ok, Err = pcall(Callback, Value)
        if not Ok and type(warn) == "function" then warn("Tallin callback: " .. tostring(Err)) end
    end
end

local function NormalizeOptions(Options, Name)
    if type(Options) == "string" then return { Name = Options } end
    if type(Options) == "table" then return Options end
    return { Name = Name or "" }
end

local function GetDefault(Options, Fallback)
    local V = Options.Default
    if V == nil then V = Options.Value end
    if V == nil then V = Fallback end
    return V
end

local Element = {}
Element.__index = Element

function Element:Get()
    return self.Value
end

function Element:GetValue()
    return self.Value
end

function Element:Set(Value, Silent)
    if self.Type == "Toggle" then Value = Value and true or false
    elseif self.Type == "Slider" then
        local Min, Max = self.Min or 0, self.Max or 100
        local Step = self.Step or 1
        Value = Clamp(tonumber(Value) or Min, Min, Max)
        if Step > 0 then Value = Clamp(Min + Round((Value - Min) / Step) * Step, Min, Max) end
        Value = tonumber(string.format("%.6f", Value))
    elseif self.Type == "Dropdown" then
        if self.Multi then
            local Selected = {}
            if type(Value) == "table" then
                if #Value > 0 then
                    for _, V in ipairs(Value) do Selected[tostring(V)] = true end
                else
                    for K, V in pairs(Value) do if V then Selected[tostring(K)] = true end end
                end
            end
            Value = Selected
        else
            local Allowed = false
            for _, Item in ipairs(self.Options) do if Item == Value then Allowed = true break end end
            if not Allowed then Value = self.Options[1] end
        end
    elseif self.Type == "Keybind" then
        Value = GetCode(Value)
    elseif self.Type == "Colorpicker" then
        if type(Value) == "table" and Value.Color then Value = Value.Color end
        if typeof(Value) ~= "Color3" then Value = RGB(191, 190, 238) end
        self.Hue, self.Sat, self.Val = ToHSV(Value)
    elseif self.Type == "Textbox" then Value = tostring(Value or "") end
    self.Value = Value
    if self.Flag then Library.Flags[self.Flag] = Value end
    if not Silent then Call(self.Callback, Value) end
    return self
end

function Element:SetValue(V, Silent) return self:Set(V, Silent) end
function Element:SetText(V) self.Name = tostring(V or "") return self end
function Element:SetKey(V) return self:Set(V) end
function Element:GetKeyName() return GetKeyName(self.Value) end
function Element:SetType(Mode) self.Mode = string.lower(tostring(Mode or "toggle")) return self end
function Element:GetType() return self.Mode or "toggle" end
function Element:IsEnabled() return self.Active or false end
function Element:GetText() return tostring(self.Value or "") end
function Element:GetItems() return CopyArray(self.Options or {}) end
function Element:Add(V)
    if self.Type == "Dropdown" then self.Options[#self.Options + 1] = V end
    return self
end
function Element:Remove(V)
    if self.Type == "Dropdown" then
        for I, Item in ipairs(self.Options) do if Item == V then table.remove(self.Options, I) break end end
        if not self.Multi then self:Set(self.Value, true) end
    end
    return self
end

local Container = {}
Container.__index = Container

local function AddElement(Self, Kind, Options, Value)
    Options = NormalizeOptions(Options)
    local Obj = setmetatable({
        Id = NewId(), Type = Kind, Container = Self,
        Name = tostring(Options.Name or Kind),
        Flag = Options.Flag,
        Callback = Options.Callback,
        Value = Value,
        Min = tonumber(Options.Min) or 0,
        Max = tonumber(Options.Max) or 100,
        Step = tonumber(Options.Step or Options.Increment) or 1,
        Enabled = Options.Enabled ~= false,
        Options = CopyArray(Options.Options or Options.Values or {}),
        Multi = Options.Multi == true,
        Height = 25,
        Mode = string.lower(tostring(Options.Mode or "toggle")),
        Active = false
    }, Element)
    Self.Items[#Self.Items + 1] = Obj
    if Obj.Flag then
        Library.Elements[Obj.Flag] = Obj
        if Library.Flags[Obj.Flag] ~= nil then Obj:Set(Library.Flags[Obj.Flag], true)
        else Obj:Set(Value, true) end
    end
    return Obj
end

function Container:Toggle(Options)
    Options = NormalizeOptions(Options)
    local Obj = AddElement(self, "Toggle", Options, GetDefault(Options, false))
    Obj.Height = 26
    if Options.Folding then Obj.Folding = true Obj.Expanded = Options.Expanded == true end
    function Obj:Keybind(Opts)
        local Child = self.Container:Keybind(Opts)
        for I, Item in ipairs(self.Container.Items) do
            if Item == Child then table.remove(self.Container.Items, I) break end
        end
        self.Dock = self.Dock or {}
        self.Dock[#self.Dock + 1] = Child
        return Child
    end
    function Obj:Colorpicker(Opts)
        local Child = self.Container:Colorpicker(Opts)
        for I, Item in ipairs(self.Container.Items) do
            if Item == Child then table.remove(self.Container.Items, I) break end
        end
        self.Dock = self.Dock or {}
        self.Dock[#self.Dock + 1] = Child
        return Child
    end
    return Obj
end

function Container:Slider(Options)
    Options = NormalizeOptions(Options)
    local Min = tonumber(Options.Min) or 0
    local Max = tonumber(Options.Max) or 100
    if Max < Min then Min, Max = Max, Min end
    local Obj = AddElement(self, "Slider", Options, GetDefault(Options, Min))
    Obj.Min, Obj.Max = Min, Max
    Obj.Step = math.max(0, tonumber(Options.Step or Options.Increment or Options.Decimals and (10 ^ -Options.Decimals)) or 1)
    Obj.Height = 46
    Obj:Set(Obj.Value, true)
    return Obj
end

function Container:Dropdown(Options)
    Options = NormalizeOptions(Options)
    local Items = Options.Options or Options.Values or {}
    local Default = GetDefault(Options, Items[1])
    if Options.Multi and type(Default) ~= "table" then Default = {} end
    local Obj = AddElement(self, "Dropdown", Options, Default)
    Obj.Height = 48
    Obj:Set(Obj.Value, true)
    return Obj
end

function Container:Keybind(Options)
    Options = NormalizeOptions(Options)
    local Obj = AddElement(self, "Keybind", Options, GetCode(GetDefault(Options, "None")))
    Obj.Height = 27
    Obj:Set(Obj.Value, true)
    Obj.Mode = string.lower(tostring(Options.Mode or Options.Type or "toggle"))
    return Obj
end

function Container:Textbox(Options)
    Options = NormalizeOptions(Options)
    local Obj = AddElement(self, "Textbox", Options, GetDefault(Options, ""))
    Obj.Height = 48
    Obj.Placeholder = tostring(Options.Placeholder or "")
    Obj.MaxLength = tonumber(Options.MaxLength) or 128
    return Obj
end
Container.Input = Container.Textbox

function Container:Colorpicker(Options)
    Options = NormalizeOptions(Options)
    local Obj = AddElement(self, "Colorpicker", Options, GetDefault(Options, RGB(191, 190, 238)))
    Obj.Height = 29
    Obj:Set(Obj.Value, true)
    return Obj
end
Container.ColorPicker = Container.Colorpicker

function Container:Label(Options)
    local Obj = AddElement(self, "Label", Options, nil)
    Obj.Height = 24
    return Obj
end

function Container:Button(Options)
    local Obj = AddElement(self, "Button", Options, nil)
    Obj.Height = 30
    return Obj
end

function Container:Buttons(List)
    local Row = AddElement(self, "Buttons", { Name = "" }, nil)
    Row.Buttons = {}
    Row.Height = 31
    for _, Options in ipairs(List or {}) do
        local O = NormalizeOptions(Options)
        Row.Buttons[#Row.Buttons + 1] = { Name = tostring(O.Name or "Button"), Callback = O.Callback }
    end
    return Row
end

function Container:Divider()
    local Obj = AddElement(self, "Divider", { Name = "" }, nil)
    Obj.Height = 13
    return Obj
end

function Container:Row(Height)
    return { Height = Height or 24, Container = self }
end

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab

function Library:Size(Width, Height)
    if typeof(Width) == "Vector2" then Width, Height = Width.X, Width.Y end
    local W = tonumber(Width) or self.SizeValue.X
    local H = tonumber(Height) or self.SizeValue.Y
    self.SizeValue = V2(Clamp(W, 340, 1300), Clamp(H, 300, 1000))
    for _, Win in ipairs(self.Windows) do
        Win.Size = self.SizeValue
        Win.X = nil
        Win.Y = nil
    end
    return self
end

function Library:Window(Options)
    Options = NormalizeOptions(Options, "Tallin")
    local Sz = Options.Size or self.SizeValue
    if typeof(Sz) ~= "Vector2" then Sz = self.SizeValue end
    local Win = setmetatable({
        Id = NewId(), Name = tostring(Options.Name or self.Name),
        Size = V2(Clamp(Sz.X, 340, 1300), Clamp(Sz.Y, 300, 1000)),
        X = Options.X, Y = Options.Y,
        Tabs = {}, Selected = nil, Visible = true,
        _scroll = { ["Left"] = 0, ["Right"] = 0 }
    }, Window)
    self.Windows[#self.Windows + 1] = Win
    return Win
end

function Window:Tab(Options)
    Options = NormalizeOptions(Options)
    local Obj = setmetatable({ Id = NewId(), Name = tostring(Options.Name or "Tab"), Sections = {}, Window = self }, Tab)
    self.Tabs[#self.Tabs + 1] = Obj
    if not self.Selected then self.Selected = Obj end
    return Obj
end

function Window:SetVisible(State)
    self.Visible = State and true or false
    if not self.Visible then Library._popup = nil end
    return self
end

function Window:Toggle() return self:SetVisible(not self.Visible) end
function Window:SetSize(W, H)
    if typeof(W) == "Vector2" then W, H = W.X, W.Y end
    self.Size = V2(Clamp(tonumber(W) or self.Size.X, 340, 1300), Clamp(tonumber(H) or self.Size.Y, 300, 1000))
    return self
end

function Window:SelectTab(Name)
    for _, T in ipairs(self.Tabs) do if T.Name == Name or T == Name then self.Selected = T Library._popup = nil break end end
    return self
end

function Tab:Section(Options)
    Options = NormalizeOptions(Options)
    local Side = tostring(Options.Side or "Left")
    if string.lower(Side) == "right" then Side = "Right" else Side = "Left" end
    local Sec = setmetatable({ Id = NewId(), Name = tostring(Options.Name or "Section"), Side = Side, Items = {}, Tab = self }, Container)
    self.Sections[#self.Sections + 1] = Sec
    return Sec
end

function Library:SetFlag(Flag, Value)
    local Item = self.Elements[Flag]
    if Item then Item:Set(Value) else self.Flags[Flag] = Value end
    return self
end
function Library:GetFlag(Flag) return self.Flags[Flag] end
function Library:SetMenuKeybind(V)
    self.MenuKeybind = GetCode(V)
    self.Settings.MenuKeybind = GetKeyName(self.MenuKeybind)
    return self
end
function Library:SetTextOffset(Y) self.TextY = tonumber(Y) or 0 return self end
function Library:SetTheme(Table)
    for K, V in pairs(Table or {}) do if Themes.Current[K] ~= nil and typeof(V) == "Color3" then Themes.Current[K] = V end end
    return self
end

local function ValueLabel(Obj)
    if Obj.Type == "Keybind" then return "[" .. GetKeyName(Obj.Value) .. "]" end
    if Obj.Type == "Dropdown" then
        if not Obj.Multi then return tostring(Obj.Value or "None") end
        local Parts = {}
        for _, V in ipairs(Obj.Options) do if Obj.Value and Obj.Value[tostring(V)] then Parts[#Parts + 1] = tostring(V) end end
        return #Parts > 0 and table.concat(Parts, ", ") or "None"
    end
    if Obj.Type == "Slider" then
        if Obj.Step > 0 and Obj.Step >= 1 then return tostring(Round(Obj.Value)) end
        return tostring(tonumber(string.format("%.3f", Obj.Value or 0)))
    end
    return tostring(Obj.Value or "")
end

local function Hover(X, Y, W, H, ContentTop, ContentBottom)
    if ContentTop and (Library._my < ContentTop or Library._my > ContentBottom) then return false end
    return InBox(Library._mx, Library._my, X, Y, W, H)
end

local function Click(X, Y, W, H, Top, Bottom)
    return Library._click and not Library._popup and Hover(X, Y, W, H, Top, Bottom)
end

local function RowClick(X, Y, W, H, Top, Bottom)
    return Click(X, Y, W, H, Top, Bottom)
end

local function RenderDock(Host, X, Y, W, Top, Bottom)
    local T = Themes.Current
    local Cursor = X + W - 4
    for I = #Host.Dock, 1, -1 do
        local Obj = Host.Dock[I]
        local P = Obj.Id
        if Obj.Type == "Keybind" then
            local BW, BH = 66, 20
            local BX, BY = Cursor - BW, Y + 3
            Square(P .. ":dockBorder", BX, BY, BW, BH, T.Border, 6)
            Square(P .. ":dockBG", BX + 1, BY + 1, BW - 2, BH - 2, T.Control, 7)
            Text(P .. ":dockLabel", Library._capture == Obj and "[...]" or ValueLabel(Obj), BX + BW / 2, BY + 3, T.Text, 11, true, 8)
            if Library._click and Hover(BX, BY, BW, BH, Top, Bottom) and not Library._popup then
                Library._capture = Obj
                Library._editing = nil
                Library._click = false
            end
            if Library._rightClick and Hover(BX, BY, BW, BH, Top, Bottom) then
                Library._popup = {Type = "BindMenu", Host = Obj, _rect = {BX, BY, BW, BH}, Id = P .. ":dockMode"}
                Library._rightClick = false
            end
            Cursor = BX - 5
        elseif Obj.Type == "Colorpicker" then
            local BW, BH = 27, 20
            local BX, BY = Cursor - BW, Y + 3
            Square(P .. ":dockBorder", BX, BY, BW, BH, T.Border, 6)
            Square(P .. ":dockFill", BX + 2, BY + 2, BW - 4, BH - 4, Obj.Value, 7)
            Obj._rect = {BX, BY, BW, BH}
            if Library._click and Hover(BX, BY, BW, BH, Top, Bottom) and not Library._popup then
                Library._popup = Obj
                Library._editing = nil
                Library._click = false
            end
            Cursor = BX - 5
        end
    end
end

local function DrawElement(Obj, X, Y, W, Top, Bottom)
    local P = Obj.Id
    local T = Themes.Current
    local Type = Obj.Type
    local H = Obj.Height
    if Y + H < Top or Y > Bottom then return end
    if Type == "Divider" then
        if Y + 5 >= Top and Y + 5 <= Bottom then Line(P .. ":div", X + 5, Y + 5, X + W - 5, Y + 5, T.Border, 3) end
        return
    end
    if Y < Top or Y + H > Bottom then return end
    local MouseOver = Hover(X, Y, W, H, Top, Bottom)
    if Type == "Toggle" then
        local BX, BY = X + 5, Y + 5
        Square(P .. ":toggleBorder", BX, BY, 16, 16, T.Border, 4)
        Square(P .. ":toggleFill", BX + 2, BY + 2, 12, 12, Obj.Value and T.Accent or T.ToggleOff, 5)
        Text(P .. ":label", Obj.Name, X + 28, Y + 5, MouseOver and T.Text or T.Muted, 13, false, 5)
        if Obj.Dock then RenderDock(Obj, X, Y, W, Top, Bottom) end
        if RowClick(X, Y, W, H, Top, Bottom) then Obj:Set(not Obj.Value) end
    elseif Type == "Slider" then
        Text(P .. ":title", Obj.Name, X + 5, Y + 1, T.Muted, 12, false, 5)
        Text(P .. ":value", ValueLabel(Obj), X + W - 8, Y + 1, T.Text, 12, true, 5)
        local BarX, BarY, BarW, BarH = X + 5, Y + 24, W - 10, 14
        Square(P .. ":barBorder", BarX, BarY, BarW, BarH, T.Border, 4)
        Square(P .. ":bar", BarX + 1, BarY + 1, BarW - 2, BarH - 2, T.Control, 5)
        local Fraction = Obj.Max == Obj.Min and 0 or Clamp((Obj.Value - Obj.Min) / (Obj.Max - Obj.Min), 0, 1)
        Square(P .. ":barFill", BarX + 1, BarY + 1, math.max(1, (BarW - 2) * Fraction), BarH - 2, T.Accent, 6)
        Obj._bar = {BarX, BarW}
        if RowClick(BarX, BarY - 4, BarW, BarH + 8, Top, Bottom) then Library._sliding = Obj end
    elseif Type == "Dropdown" then
        Text(P .. ":title", Obj.Name, X + 5, Y + 1, T.Muted, 12, false, 5)
        local BX, BY, BW, BH = X + 4, Y + 20, W - 8, 23
        Square(P .. ":dropBorder", BX, BY, BW, BH, T.Border, 4)
        Square(P .. ":dropBG", BX + 1, BY + 1, BW - 2, BH - 2, MouseOver and T.ControlHover or T.Control, 5)
        local Value = ValueLabel(Obj)
        if #Value > 32 then Value = string.sub(Value, 1, 29) .. "..." end
        Text(P .. ":dropLabel", Value, BX + 8, BY + 4, T.Text, 12, false, 6)
        Text(P .. ":dropArrow", Library._popup == Obj and "-" or "+", BX + BW - 14, BY + 3, T.Accent, 15, true, 6)
        Obj._rect = {BX, BY, BW, BH}
        if Library._click and (not Library._popup or Library._popup == Obj) and Hover(BX, BY, BW, BH, Top, Bottom) then
            if Library._popup == Obj then Library._popup = nil
            elseif not Library._popup then Library._popup = Obj end
            Library._click = false
        end
    elseif Type == "Keybind" then
        Text(P .. ":label", Obj.Name, X + 5, Y + 5, T.Muted, 13, false, 5)
        local BX, BY, BW, BH = X + W - 99, Y + 2, 94, 23
        Square(P .. ":keyBorder", BX, BY, BW, BH, T.Border, 4)
        Square(P .. ":keyBG", BX + 1, BY + 1, BW - 2, BH - 2, Library._capture == Obj and T.AccentDark or T.Control, 5)
        Text(P .. ":keyValue", Library._capture == Obj and "[...]" or ValueLabel(Obj), BX + BW / 2, BY + 4, T.Text, 12, true, 6)
        if RowClick(BX, BY, BW, BH, Top, Bottom) then
            Library._capture = Obj
            Library._editing = nil
            Library._popup = nil
            Library._captureWait = true
            Library._click = false
        end
        if Library._rightClick and Hover(BX, BY, BW, BH, Top, Bottom) then
            Library._popup = {Type = "BindMenu", Host = Obj, _rect = {BX, BY, BW, BH}, Id = P .. ":mode"}
            Library._rightClick = false
        end
    elseif Type == "Textbox" then
        Text(P .. ":title", Obj.Name, X + 5, Y + 1, T.Muted, 12, false, 5)
        local BX, BY, BW, BH = X + 4, Y + 20, W - 8, 23
        Obj._rect = {BX, BY, BW, BH}
        Square(P .. ":textBorder", BX, BY, BW, BH, Library._editing == Obj and T.Accent or T.Border, 4)
        Square(P .. ":textBG", BX + 1, BY + 1, BW - 2, BH - 2, T.Control, 5)
        local S = Library._editing == Obj and Library._editBuffer or Obj.Value
        if S == "" then S = Obj.Placeholder end
        if #S > 41 then S = string.sub(S, #S - 40) end
        if Library._editing == Obj and math.floor(os.clock() * 2) % 2 == 0 then S = S .. "_" end
        Text(P .. ":input", S, BX + 7, BY + 4, Library._editing == Obj and T.Text or T.Muted, 12, false, 6)
        if RowClick(BX, BY, BW, BH, Top, Bottom) then
            if Library._editing and Library._editing ~= Obj then Library._editing:Set(Library._editBuffer) end
            Library._editing, Library._editBuffer = Obj, Obj.Value
            Library._capture = nil
        end
    elseif Type == "Colorpicker" then
        Text(P .. ":label", Obj.Name, X + 5, Y + 6, T.Muted, 13, false, 5)
        local BX, BY, BW, BH = X + W - 59, Y + 3, 54, 22
        Square(P .. ":colorBorder", BX, BY, BW, BH, T.Border, 4)
        Square(P .. ":colorFill", BX + 2, BY + 2, BW - 4, BH - 4, Obj.Value, 5)
        Obj._rect = {BX, BY, BW, BH}
        if RowClick(BX, BY, BW, BH, Top, Bottom) then
            Library._popup = Obj
            Library._editing = nil
            Library._click = false
        end
    elseif Type == "Button" then
        local BX, BY, BW, BH = X + 4, Y + 2, W - 8, H - 5
        Square(P .. ":buttonBorder", BX, BY, BW, BH, T.Border, 4)
        Square(P .. ":buttonBG", BX + 1, BY + 1, BW - 2, BH - 2, MouseOver and T.AccentDark or T.Control, 5)
        Text(P .. ":button", Obj.Name, BX + BW / 2, BY + 6, T.Text, 13, true, 6)
        if RowClick(BX, BY, BW, BH, Top, Bottom) then Call(Obj.Callback) end
    elseif Type == "Buttons" then
        local C = #Obj.Buttons
        if C == 0 then return end
        local Gap = 4
        local BW = (W - 8 - (C - 1) * Gap) / C
        for I, B in ipairs(Obj.Buttons) do
            local BX, BY, BH = X + 4 + (I - 1) * (BW + Gap), Y + 2, H - 5
            Square(P .. ":b:" .. I, BX, BY, BW, BH, T.Control, 4)
            Text(P .. ":btext:" .. I, B.Name, BX + BW / 2, BY + 5, T.Text, 12, true, 5)
            if RowClick(BX, BY, BW, BH, Top, Bottom) then Call(B.Callback) end
        end
    elseif Type == "Label" then
        Text(P .. ":label", Obj.Name, X + 5, Y + 4, T.Text, 13, false, 4)
    end
end

local function DrawSection(Sec, X, Y, W, H, Top, Bottom)
    local T = Themes.Current
    local Prefix = Sec.Id
    if Y > Bottom or Y + H < Top then return end
    local SecTop = math.max(Y, Top)
    local SecBottom = math.min(Y + H, Bottom)
    Square(Prefix .. ":border", X, SecTop, W, SecBottom - SecTop, T.Border, 2)
    Square(Prefix .. ":body", X + 1, SecTop + 1, W - 2, SecBottom - SecTop - 2, T.Section, 3)
    if Y >= Top and Y + 27 <= Bottom then
        Square(Prefix .. ":header", X + 1, Y + 1, W - 2, 26, T.SectionHeader, 4)
        Text(Prefix .. ":name", Sec.Name, X + 10, Y + 6, T.Muted, 13, false, 5)
        Line(Prefix .. ":headerLine", X + 1, Y + 27, X + W - 1, Y + 27, T.Border, 5)
    end
    local YY = Y + 32
    for _, Obj in ipairs(Sec.Items) do
        DrawElement(Obj, X + 7, YY, W - 14, Top, Bottom)
        YY = YY + Obj.Height
    end
end

local function SectionHeight(Sec)
    local H = 37
    for _, Obj in ipairs(Sec.Items) do H = H + Obj.Height end
    return math.max(65, H)
end

local function RenderWindow(Win)
    if not Win.Visible then return end
    local W, H = Win.Size.X, Win.Size.Y
    local Camera = Workspace.CurrentCamera
    local Viewport = Camera and Camera.ViewportSize or V2(1920, 1080)
    if not Win.X then Win.X = Round((Viewport.X - W) * 0.5) end
    if not Win.Y then Win.Y = Round((Viewport.Y - H) * 0.5) end
    Win.X = Clamp(Win.X, 0, math.max(0, Viewport.X - W))
    Win.Y = Clamp(Win.Y, 0, math.max(0, Viewport.Y - H))
    local X, Y = Win.X, Win.Y
    local T = Themes.Current
    local P = Win.Id
    Square(P .. ":shadow", X + 5, Y + 6, W, H, RGB(7, 7, 8), 0)
    Square(P .. ":border", X, Y, W, H, T.Border, 1)
    Square(P .. ":main", X + 1, Y + 1, W - 2, H - 2, T.Background, 2)
    Square(P .. ":header", X + 2, Y + 2, W - 4, 34, T.Header, 3)
    Text(P .. ":title", Win.Name, X + W / 2, Y + 10, T.Text, 15, true, 5)
    Square(P .. ":accent", X + 2, Y + 36, W - 4, 2, T.Accent, 4)
    if Library._click and not Library._popup and Hover(X, Y, W, 36) then
        Library._drag = { Window = Win, DX = Library._mx - X, DY = Library._my - Y }
    end
    local TabY = Y + 45
    local TabCount = #Win.Tabs
    local TabWidth = TabCount > 0 and (W - 18) / TabCount or 0
    for I, TabObj in ipairs(Win.Tabs) do
        local TX = X + 9 + (I - 1) * TabWidth
        Square(TabObj.Id .. ":tab", TX, TabY, TabWidth - 3, 27, Win.Selected == TabObj and T.AccentDark or T.Control, 4)
        Text(TabObj.Id .. ":label", TabObj.Name, TX + (TabWidth - 3) / 2, TabY + 6, Win.Selected == TabObj and T.Text or T.Muted, 12, true, 5)
        if Click(TX, TabY, TabWidth - 3, 27) then
            Win.Selected = TabObj
            Library._popup = nil
            Library._editing = nil
        end
    end
    if not Win.Selected then return end
    local Top = Y + 83
    local Bottom = Y + H - 12
    local Available = math.max(0, Bottom - Top)
    local Gap = 9
    local ColumnW = (W - 27) / 2
    for ColumnIndex, Side in ipairs({"Left", "Right"}) do
        local CX = X + 9 + (ColumnIndex - 1) * (ColumnW + Gap)
        local TotalH = 0
        for _, Sec in ipairs(Win.Selected.Sections) do
            if Sec.Side == Side then TotalH = TotalH + SectionHeight(Sec) + 10 end
        end
        local MaxScroll = math.max(0, TotalH - Available)
        Win._scroll[Side] = Clamp(Win._scroll[Side] or 0, 0, MaxScroll)
        local Scroll = Win._scroll[Side]
        if MaxScroll > 0 and not Library._popup and Hover(CX, Top, ColumnW, Available) then
            if Library._scrollDelta ~= 0 then
                Win._scroll[Side] = Clamp(Scroll + Library._scrollDelta, 0, MaxScroll)
                Scroll = Win._scroll[Side]
                Library._scrollDelta = 0
            end
        end
        local CY = Top - Scroll
        for _, Sec in ipairs(Win.Selected.Sections) do
            if Sec.Side == Side then
                local SH = SectionHeight(Sec)
                DrawSection(Sec, CX, CY, ColumnW, SH, Top, Bottom)
                CY = CY + SH + 10
            end
        end
        if MaxScroll > 0 then
            local TrackH = Available
            local ThumbH = math.max(25, Available * Available / (Available + MaxScroll))
            local ThumbY = Top + Scroll / MaxScroll * (TrackH - ThumbH)
            Square(P .. ":scrollTrack" .. Side, CX + ColumnW - 3, Top, 3, TrackH, T.Control, 7)
            Square(P .. ":scrollThumb" .. Side, CX + ColumnW - 3, ThumbY, 3, ThumbH, T.Accent, 8)
        end
    end
end

local function RenderPopup()
    local Obj = Library._popup
    if not Obj then return end
    local T = Themes.Current
    local Viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or V2(1920, 1080)
    local Type = Obj.Type
    if Type == "Dropdown" then
        if not Obj._rect then Library._popup = nil return end
        local R = Obj._rect
        local Count = #Obj.Options
        local VisibleCount = math.min(Count, 8)
        local HH = math.max(24, VisibleCount * 24 + 4)
        local BX = Clamp(R[1], 2, math.max(2, Viewport.X - R[3] - 2))
        local BY = R[2] + R[4] + 3
        if BY + HH > Viewport.Y - 5 then BY = R[2] - HH - 3 end
        local BW = R[3]
        if Obj._optionScroll == nil then Obj._optionScroll = 0 end
        local MaxScroll = math.max(0, Count - VisibleCount)
        Obj._optionScroll = Clamp(Obj._optionScroll, 0, MaxScroll)
        if Library._scrollDelta ~= 0 and Hover(BX, BY, BW, HH) then
            Obj._optionScroll = Clamp(Obj._optionScroll + (Library._scrollDelta > 0 and 1 or -1), 0, MaxScroll)
            Library._scrollDelta = 0
        end
        Square(Obj.Id .. ":listBorder", BX, BY, BW, HH, T.Border, 20)
        Square(Obj.Id .. ":listBG", BX + 1, BY + 1, BW - 2, HH - 2, T.Header, 21)
        for I = 1, VisibleCount do
            local Index = I + Obj._optionScroll
            local Option = Obj.Options[Index]
            local OY = BY + 2 + (I - 1) * 24
            local Selected = Obj.Multi and Obj.Value[tostring(Option)] or (Obj.Value == Option)
            local Over = Hover(BX + 2, OY, BW - 4, 23)
            if Over or Selected then Square(Obj.Id .. ":listSel" .. I, BX + 2, OY, BW - 4, 23, Over and T.ControlHover or T.AccentDark, 22) end
            Text(Obj.Id .. ":listOption" .. I, tostring(Option), BX + 8, OY + 4, Selected and T.Accent or T.Text, 12, false, 23)
            if Library._click and Over then
                if Obj.Multi then
                    local Next = {}
                    for K, V in pairs(Obj.Value) do Next[K] = V end
                    Next[tostring(Option)] = not Next[tostring(Option)] or nil
                    Obj.Value = Next
                    if Obj.Flag then Library.Flags[Obj.Flag] = Next end
                    Call(Obj.Callback, Next)
                else
                    Obj:Set(Option)
                    Library._popup = nil
                end
                Library._click = false
            end
        end
        if Library._click then
            if not Hover(BX, BY, BW, HH) and not Hover(R[1], R[2], R[3], R[4]) then Library._popup = nil end
        end
    elseif Type == "BindMenu" then
        local R = Obj._rect
        local PX = Clamp(R[1], 2, math.max(2, Viewport.X - 110))
        local PY = R[2] + R[4] + 3
        if PY + 53 > Viewport.Y then PY = R[2] - 56 end
        Square(Obj.Id .. ":border", PX, PY, 110, 53, T.Border, 20)
        Square(Obj.Id .. ":bg", PX + 1, PY + 1, 108, 51, T.Header, 21)
        for I, Mode in ipairs({"Toggle", "Hold"}) do
            local OY = PY + 2 + (I - 1) * 24
            if Obj.Host.Mode == string.lower(Mode) then Square(Obj.Id .. ":selected" .. I, PX + 2, OY, 106, 23, T.AccentDark, 22) end
            Text(Obj.Id .. ":mode" .. I, Mode, PX + 8, OY + 4, T.Text, 12, false, 23)
            if Library._click and Hover(PX, OY, 110, 24) then
                Obj.Host:SetType(Mode)
                Library._popup = nil
                Library._click = false
                break
            end
        end
        if Library._click and not Hover(PX, PY, 110, 53) then Library._popup = nil end
    elseif Type == "Colorpicker" then
        if not Obj._rect then Library._popup = nil return end
        local R = Obj._rect
        local PW, PH = 206, 202
        local PX = Clamp(R[1] + R[3] - PW, 3, math.max(3, Viewport.X - PW - 3))
        local PY = R[2] + R[4] + 4
        if PY + PH > Viewport.Y then PY = R[2] - PH - 4 end
        PX = Round(PX)
        PY = Round(PY)
        Square(Obj.Id .. ":cpBorder", PX, PY, PW, PH, T.Border, 20)
        Square(Obj.Id .. ":cpBG", PX + 1, PY + 1, PW - 2, PH - 2, T.Header, 21)
        Text(Obj.Id .. ":cpName", Obj.Name, PX + 9, PY + 8, T.Text, 13, false, 22)
        local SX, SY, SW, SH = PX + 10, PY + 32, 155, 130
        for I = 1, 13 do
            for J = 1, 13 do
                local Sat = (I - 0.5) / 13
                local Val = 1 - (J - 0.5) / 13
                Square(Obj.Id .. ":sv:" .. I .. ":" .. J, SX + (I - 1) * SW / 13, SY + (J - 1) * SH / 13, SW / 13 + 1, SH / 13 + 1, HSV(Obj.Hue, Sat, Val), 22)
            end
        end
        local HX, HY, HW, HH = PX + 174, SY, 20, SH
        for I = 1, 20 do Square(Obj.Id .. ":hue:" .. I, HX, HY + (I - 1) * HH / 20, HW, HH / 20 + 1, HSV((I - 1) / 20, 1, 1), 22) end
        Square(Obj.Id .. ":cursor", SX + Obj.Sat * SW - 3, SY + (1 - Obj.Val) * SH - 3, 7, 7, RGB(0, 0, 0), 24)
        Square(Obj.Id .. ":cursorIn", SX + Obj.Sat * SW - 2, SY + (1 - Obj.Val) * SH - 2, 5, 5, T.Text, 25)
        Square(Obj.Id .. ":hueCursor", HX - 2, HY + Obj.Hue * HH - 2, HW + 4, 4, T.Text, 24)
        Square(Obj.Id .. ":preview", PX + 10, PY + 173, 185, 18, Obj.Value, 22)
        Obj._picker = {SX, SY, SW, SH, HX, HY, HW, HH}
        if Library._click then
            if Hover(SX, SY, SW, SH) then Library._pickerDrag = {Obj, "sv"} Library._click = false
            elseif Hover(HX, HY, HW, HH) then Library._pickerDrag = {Obj, "hue"} Library._click = false
            elseif not Hover(PX, PY, PW, PH) and not Hover(R[1], R[2], R[3], R[4]) then Library._popup = nil end
        end
    end
end

local function EditCharacter(Code, Shift)
    if Code >= 65 and Code <= 90 then
        local C = string.char(Code)
        return Shift and C or string.lower(C)
    end
    if Code >= 48 and Code <= 57 then
        if Shift then
            local Punct = {[48] = ")", [49] = "!", [50] = "@", [51] = "#", [52] = "$", [53] = "%", [54] = "^", [55] = "&", [56] = "*", [57] = "("}
            return Punct[Code]
        end
        return string.char(Code)
    end
    if Code >= 96 and Code <= 105 then return tostring(Code - 96) end
    if Code == 32 then return " " end
    local Normal = { [186] = ";", [187] = "=", [188] = ",", [189] = "-", [190] = ".", [191] = "/", [192] = "`", [219] = "[", [220] = "\\", [221] = "]", [222] = "'" }
    local Shifted = { [186] = ":", [187] = "+", [188] = "<", [189] = "_", [190] = ">", [191] = "?", [192] = "~", [219] = "{", [220] = "|", [221] = "}", [222] = "\"" }
    return Shift and Shifted[Code] or Normal[Code]
end

local function ProcessKeys()
    local Shift = Pressed(16) or Pressed(160) or Pressed(161)
    local InputTarget = Library._editing
    local CaptureTarget = Library._capture
    if not InputTarget and not CaptureTarget then return end
    for Code = 8, 222 do
        local Current = Pressed(Code)
        local PreviousKey = Library._lastKeys[Code] or false
        Library._lastKeys[Code] = Current
        if Current and not PreviousKey and Code ~= 16 and Code ~= 160 and Code ~= 161 and Code ~= 17 and Code ~= 18 then
            if CaptureTarget then
                if Code == 27 then
                    Library._capture = nil
                elseif Code == 8 or Code == 46 then
                    CaptureTarget:Set(0)
                    Library._capture = nil
                else
                    CaptureTarget:Set(Code)
                    Library._capture = nil
                end
                return
            elseif InputTarget then
                if Code == 13 then
                    InputTarget:Set(Library._editBuffer)
                    Library._editing = nil
                    return
                elseif Code == 27 then
                    Library._editing = nil
                    return
                elseif Code == 8 then
                    Library._editBuffer = string.sub(Library._editBuffer, 1, -2)
                else
                    local C = EditCharacter(Code, Shift)
                    if C and #Library._editBuffer < InputTarget.MaxLength then Library._editBuffer = Library._editBuffer .. C end
                end
            end
        end
    end
end

local function GetFrameTime()
    return os.clock()
end

local function ProcessBinds()
    for _, Obj in pairs(Library.Elements) do
        if Obj.Type == "Keybind" then
            local Down = Pressed(Obj.Value)
            if Library._capture ~= Obj and Library._editing == nil then
                if Obj.Mode == "hold" then
                    if Down ~= Obj.Active then Obj.Active = Down Call(Obj.Callback, Obj.Active) end
                elseif Down and not Obj._wasDown then
                    Obj.Active = not Obj.Active
                    Call(Obj.Callback, Obj.Active)
                end
            end
            Obj._wasDown = Down
        end
    end
end

function Library:Render()
    if self.Unloaded then return end
    self._frame = self._frame + 1
    local LiveMouse = Mouse
    self._mx, self._my = tonumber(LiveMouse.X) or 0, tonumber(LiveMouse.Y) or 0
    local LeftDown = Pressed(1)
    local RightDown = Pressed(2)
    self._click = LeftDown and not self._mouseDown
    self._rightClick = RightDown and not self._rightDown
    self._mouseDown, self._rightDown = LeftDown, RightDown
    local MenuDown = Pressed(self.MenuKeybind)
    if MenuDown and not self._menuDown and not self._capture and not self._editing then
        self.Open = not self.Open
        self._popup = nil
        self._drag = nil
        self._sliding = nil
        self._pickerDrag = nil
    end
    self._menuDown = MenuDown
    ProcessKeys()
    ProcessBinds()
    if self._drag then
        if LeftDown and self.Open then
            local W = self._drag.Window
            local Viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or V2(1920, 1080)
            W.X = Clamp(self._mx - self._drag.DX, 0, math.max(0, Viewport.X - W.Size.X))
            W.Y = Clamp(self._my - self._drag.DY, 0, math.max(0, Viewport.Y - W.Size.Y))
        else self._drag = nil end
    end
    if self._sliding then
        local Obj = self._sliding
        if LeftDown and Obj._bar then
            local BarX, BarW = Obj._bar[1], Obj._bar[2]
            local Ratio = Clamp((self._mx - BarX) / BarW, 0, 1)
            local Value = Obj.Min + (Obj.Max - Obj.Min) * Ratio
            if Obj.Step > 0 then Value = Obj.Min + Round((Value - Obj.Min) / Obj.Step) * Obj.Step end
            if Obj.Value ~= Value then Obj:Set(Value) end
        else self._sliding = nil end
    end
    if self._pickerDrag then
        local Item, Kind = self._pickerDrag[1], self._pickerDrag[2]
        if LeftDown and Item._picker then
            local R = Item._picker
            if Kind == "sv" then
                Item.Sat = Clamp((self._mx - R[1]) / R[3], 0, 1)
                Item.Val = 1 - Clamp((self._my - R[2]) / R[4], 0, 1)
            else
                Item.Hue = Clamp((self._my - R[6]) / R[8], 0, 1)
            end
            local NewColor = HSV(Item.Hue, Item.Sat, Item.Val)
            if not Item.Value or math.abs(Item.Value.R - NewColor.R) + math.abs(Item.Value.G - NewColor.G) + math.abs(Item.Value.B - NewColor.B) > 0.00001 then Item:Set(NewColor) end
        else self._pickerDrag = nil end
    end
    local Scroll = 0
    if Pressed(34) and not self._pgDown then Scroll = 76 end
    if Pressed(33) and not self._pgUp then Scroll = -76 end
    self._pgDown, self._pgUp = Pressed(34), Pressed(33)
    self._scrollDelta = Scroll
    if self.Open then
        for _, Win in ipairs(self.Windows) do RenderWindow(Win) end
        RenderPopup()
        if self._click and self._editing and self._editing._rect then
            local R = self._editing._rect
            if not Hover(R[1], R[2], R[3], R[4]) then
                self._editing:Set(self._editBuffer)
                self._editing = nil
            end
        end
    end
    for _, Item in pairs(self._canvas) do
        if Item.Frame ~= self._frame then Item.Object.Visible = false end
    end
    if self.AutoSave and self._configDirty and self._dirtyAt and GetFrameTime() - self._dirtyAt > 1 then
        self._configDirty = false
        self:SaveConfig(self.ConfigName or "default")
    end
end

function Library:Start()
    if self._connection or self.Unloaded then return self end
    self._connection = RunService.RenderStepped:Connect(function()
        if not self.Unloaded then
            local Ok, Err = pcall(function() self:Render() end)
            if not Ok then
                local Now = GetFrameTime()
                if not self._lastError or Now - self._lastError > 4 then
                    self._lastError = Now
                    if type(warn) == "function" then warn("MatchaTallin render: " .. tostring(Err)) end
                end
            end
        end
    end)
    self.Connections[#self.Connections + 1] = self._connection
    return self
end

function Library:Unload()
    if self.Unloaded then return end
    self.Unloaded = true
    for _, Connection in ipairs(self.Connections) do pcall(function() Connection:Disconnect() end) end
    for _, Obj in ipairs(self.Drawings) do pcall(function() Obj:Remove() end) end
    self.Connections = {}
    self.Drawings = {}
    self._canvas = {}
    self._popup = nil
    self._capture = nil
    self._editing = nil
    self._sliding = nil
    self._drag = nil
    self._pickerDrag = nil
    if _G.MatchaTallin == self then _G.MatchaTallin = nil end
end

function Library:Toggle()
    self.Open = not self.Open
    if not self.Open then self._popup = nil end
    return self
end

function Library:SetVisible(State)
    self.Open = State and true or false
    if not self.Open then self._popup = nil end
    return self
end

local function ConfigValue(Obj)
    local V = Obj.Value
    if Obj.Type == "Colorpicker" then
        return {__type = "Color3", R = V.R, G = V.G, B = V.B}
    end
    if Obj.Type == "Dropdown" and Obj.Multi then
        local Selected = {}
        for Key, Value in pairs(V) do if Value then Selected[#Selected + 1] = Key end end
        return {__type = "Multi", Items = Selected}
    end
    return V
end

local function DecodeValue(V)
    if type(V) == "table" then
        if V.__type == "Color3" then return Color3.new(V.R, V.G, V.B) end
        if V.__type == "Multi" then return V.Items end
    end
    return V
end

function Library:SaveConfig(Name)
    Name = tostring(Name or "default"):gsub("[^%w_%-.]", "_")
    local Data = { Flags = {}, WindowPositions = {}, Size = {X = self.SizeValue.X, Y = self.SizeValue.Y} }
    for Flag, Obj in pairs(self.Elements) do Data.Flags[Flag] = ConfigValue(Obj) end
    for _, Win in ipairs(self.Windows) do
        Data.WindowPositions[Win.Name] = {X = Win.X, Y = Win.Y, W = Win.Size.X, H = Win.Size.Y}
    end
    local Ok, Payload = pcall(function() return HttpService:JSONEncode(Data) end)
    if not Ok then return false end
    local Path = self.ConfigFolder .. "/" .. Name .. ".json"
    if type(writefile) ~= "function" then return false end
    local Result = pcall(function()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
        writefile(Path, Payload)
    end)
    return Result
end

function Library:LoadConfig(Name)
    Name = tostring(Name or "default"):gsub("[^%w_%-.]", "_")
    local Path = self.ConfigFolder .. "/" .. Name .. ".json"
    if type(isfile) ~= "function" or type(readfile) ~= "function" or not isfile(Path) then return false end
    local Ok, Data = pcall(function() return HttpService:JSONDecode(readfile(Path)) end)
    if not Ok or type(Data) ~= "table" then return false end
    if type(Data.Flags) == "table" then
        for Flag, Value in pairs(Data.Flags) do
            self.Flags[Flag] = DecodeValue(Value)
            if self.Elements[Flag] then self.Elements[Flag]:Set(self.Flags[Flag], true) end
        end
    end
    if type(Data.WindowPositions) == "table" then
        for _, Win in ipairs(self.Windows) do
            local P = Data.WindowPositions[Win.Name]
            if type(P) == "table" then
                Win.X, Win.Y = tonumber(P.X), tonumber(P.Y)
                if type(P.W) == "number" and type(P.H) == "number" then Win:SetSize(P.W, P.H) end
            end
        end
    end
    return true
end

function Library:SetAutoSave(State, Name)
    self.AutoSave = State and true or false
    self.ConfigName = tostring(Name or "default")
    return self
end

function Library:SetConfigFolder(Path)
    self.ConfigFolder = tostring(Path or "MatchaTallinConfigs")
    return self
end

function Library:GetConfigs()
    local Names = {}
    if type(listfiles) ~= "function" then return Names end
    local Ok, Files = pcall(listfiles, self.ConfigFolder)
    if not Ok or type(Files) ~= "table" then return Names end
    for _, Path in ipairs(Files) do
        local Name = tostring(Path):match("([^/\\]+)%.json$")
        if Name then Names[#Names + 1] = Name end
    end
    table.sort(Names)
    return Names
end

local BaseSet = Element.Set
function Element:Set(Value, Silent)
    local OldValue = self.Value
    local Result = BaseSet(self, Value, Silent)
    if self.Flag and OldValue ~= self.Value and Library.AutoSave then
        Library._configDirty = true
        Library._dirtyAt = GetFrameTime()
    end
    return Result
end

local Notifications = {}
function Notifications:Notify(Message, Title, Duration)
    local Msg = tostring(Message or "")
    if type(notify) == "function" then pcall(notify, Msg, tostring(Title or "Tallin"), tonumber(Duration) or 4) end
end
function Library:Notify(Message, Title, Duration) Notifications:Notify(Message, Title, Duration) end

Library.size = Library.Size
Library.window = Library.Window
Window.tab = Window.Tab
Tab.section = Tab.Section
Container.toggle = Container.Toggle
Container.slider = Container.Slider
Container.dropdown = Container.Dropdown
Container.keybind = Container.Keybind
Container.textbox = Container.Textbox
Container.colorpicker = Container.Colorpicker
Container.button = Container.Button
Container.label = Container.Label

_G.MatchaTallin = Library
Library:Start()
return Library, Notifications, Themes
