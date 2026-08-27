local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Library = {Flags = {}, Setters = {}, Folders = {Root = "Atramenta.rip", Configs = "Atramenta.rip/Configs", Assets = "Atramenta.rip/Assets"}, MenuKeybind = Enum.KeyCode.Insert, Theme = {Accent = Color3.fromRGB(175, 100, 200)}, Connections = {}, Guis = {}, Keybinds = {}, Renderers = {}, ActiveWindow = nil, Capture = nil}

local function Call(Function, ...)
    if type(Function) ~= "function" then return false, nil end
    local Args = table.pack(...)
    local Results = table.pack(xpcall(function() return Function(table.unpack(Args, 1, Args.n)) end, function(Error) return tostring(Error) end))
    if Results[1] ~= true then return false, Results[2] end
    return true, table.unpack(Results, 2, Results.n)
end
Library.Call = Call

local function Bind(Connection)
    if Connection then Library.Connections[#Library.Connections + 1] = Connection end
    return Connection
end

local function Create(Class, Properties, Children)
    local Object = Instance.new(Class)
    for Key, Value in pairs(Properties or {}) do Object[Key] = Value end
    for _, Child in ipairs(Children or {}) do Child.Parent = Object end
    return Object
end

local function ParentGui()
    if type(gethui) == "function" then
        local Success, Result = Call(gethui)
        if Success and typeof(Result) == "Instance" then return Result end
    end
    return CoreGui
end

local function EnsureFolders()
    if type(makefolder) ~= "function" then return end
    if type(isfolder) ~= "function" or not isfolder(Library.Folders.Root) then Call(makefolder, Library.Folders.Root) end
    if type(isfolder) ~= "function" or not isfolder(Library.Folders.Configs) then Call(makefolder, Library.Folders.Configs) end
    if type(isfolder) ~= "function" or not isfolder(Library.Folders.Assets) then Call(makefolder, Library.Folders.Assets) end
end
EnsureFolders()

local Colors = {
    Bg = Color3.fromRGB(9, 9, 9),
    TitleBg = Color3.fromRGB(7, 7, 7),
    Text = Color3.fromRGB(168, 165, 178),
    TextBright = Color3.fromRGB(205, 202, 215),
    TextDim = Color3.fromRGB(82, 79, 95),
    TextBind = Color3.fromRGB(64, 61, 75),
    Section = Color3.fromRGB(78, 74, 90),
    CbBg = Color3.fromRGB(18, 16, 20),
    CbBorder = Color3.fromRGB(52, 49, 60),
    SliderTrack = Color3.fromRGB(26, 24, 30),
    DropdownBg = Color3.fromRGB(16, 14, 18),
    DropdownBord = Color3.fromRGB(50, 47, 58),
    Divider = Color3.fromRGB(46, 44, 55),
    TabBg = Color3.fromRGB(13, 13, 13),
    ColHdr = Color3.fromRGB(85, 82, 98),
    SectionBorder = Color3.fromRGB(22, 22, 22)
}

local function Accent() return Library.Theme.Accent or Color3.fromRGB(175, 100, 200) end
local function AccentDark()
    local H, S, V = Color3.toHSV(Accent())
    return Color3.fromHSV(H, S, V * 0.32)
end
local function AccentHover()
    local H, S, V = Color3.toHSV(Accent())
    return Color3.fromHSV(H, S, math.min(V * 1.09, 1))
end
local function AccentBorder()
    local H, S, V = Color3.toHSV(Accent())
    return Color3.fromHSV(H, S, V * 0.82)
end

function Library:ChangeTheme(Index, Color)
    local Name = tostring(Index or "")
    if typeof(Color) ~= "Color3" then return end
    self.Theme[Name] = Color
    if Name == "Accent" or Name == "accent" then self.Theme.Accent = Color end
    for Index = #self.Renderers, 1, -1 do
        local Renderer = self.Renderers[Index]
        if type(Renderer) == "function" then Call(Renderer) else table.remove(self.Renderers, Index) end
    end
end

local function RegisterRenderer(Renderer)
    Library.Renderers[#Library.Renderers + 1] = Renderer
    Call(Renderer)
    return Renderer
end

local function RegisterFlag(Flag, Default, Setter)
    if type(Flag) ~= "string" or Flag == "" then return end
    if Library.Flags[Flag] == nil then Library.Flags[Flag] = Default end
    if type(Setter) == "function" then Library.Setters[Flag] = Setter end
end

local function CloneValue(Value, Seen)
    if type(Value) ~= "table" then return Value end
    Seen = Seen or {}
    if Seen[Value] then return Seen[Value] end
    local Result = {}
    Seen[Value] = Result
    for Key, Item in pairs(Value) do Result[CloneValue(Key, Seen)] = CloneValue(Item, Seen) end
    return Result
end

local function GetGuiInset(ScreenGui)
    if ScreenGui and ScreenGui.IgnoreGuiInset then return Vector2.zero end
    local TopLeft = GuiService:GetGuiInset()
    return TopLeft
end

local function GuiPoint(ScreenGui, Point)
    return Point - GetGuiInset(ScreenGui)
end

local function MousePoint(ScreenGui)
    return GuiPoint(ScreenGui, UserInputService:GetMouseLocation())
end

local function MakeDraggable(Frame, Handle)
    local Dragging, DragInput, StartMouse, StartPosition
    Bind(Handle.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        Dragging = true
        StartMouse = Input.Position
        StartPosition = Frame.Position
        Bind(Input.Changed:Connect(function()
            if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
        end))
    end))
    Bind(Handle.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end
    end))
    Bind(UserInputService.InputChanged:Connect(function(Input)
        if not Dragging or Input ~= DragInput then return end
        local Delta = Input.Position - StartMouse
        Frame.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
    end))
end

local KeyAliases = {
    M1 = Enum.UserInputType.MouseButton1,
    M2 = Enum.UserInputType.MouseButton2,
    M3 = Enum.UserInputType.MouseButton3,
    MB1 = Enum.UserInputType.MouseButton1,
    MB2 = Enum.UserInputType.MouseButton2,
    MB3 = Enum.UserInputType.MouseButton3,
    INS = Enum.KeyCode.Insert,
    DEL = Enum.KeyCode.Delete,
    ALT = Enum.KeyCode.LeftAlt,
    CTRL = Enum.KeyCode.LeftControl,
    SHIFT = Enum.KeyCode.LeftShift,
    NONE = nil
}

local function KeyDisplay(Key)
    if Key == nil then return "none" end
    if typeof(Key) == "EnumItem" then
        local Name = Key.Name
        local Map = {MouseButton1 = "M1", MouseButton2 = "M2", MouseButton3 = "M3", Insert = "INS", Delete = "DEL", LeftAlt = "ALT", RightAlt = "ALT", LeftControl = "CTRL", RightControl = "CTRL", LeftShift = "SHIFT", RightShift = "SHIFT"}
        return Map[Name] or Name:upper()
    end
    return tostring(Key)
end

local function NormalizeKey(Value)
    if typeof(Value) == "EnumItem" then return Value end
    if type(Value) ~= "string" then return nil end
    local Upper = Value:upper()
    if KeyAliases[Upper] ~= nil then return KeyAliases[Upper] end
    if Upper == "NONE" or Upper == "..." then return nil end
    for _, Code in ipairs(Enum.KeyCode:GetEnumItems()) do if Code.Name:upper() == Upper then return Code end end
    for _, Code in ipairs(Enum.UserInputType:GetEnumItems()) do if Code.Name:upper() == Upper then return Code end end
    return nil
end

local function InputMatches(Input, Key)
    if typeof(Key) ~= "EnumItem" then return false end
    if tostring(Key.EnumType):find("UserInputType", 1, true) then return Input.UserInputType == Key end
    return Input.KeyCode == Key
end

local function RefreshKeybindList()
    local Controller = Library.KeybindListController
    if not Controller or type(Controller.Refresh) ~= "function" then return end
    Controller:Refresh()
end

local function FireKeybind(BindData, Pressed)
    if not BindData or BindData.Destroyed then return end
    local Mode = BindData.Mode
    if Mode == "Hold" then
        if BindData.Value == Pressed then return end
        BindData.Value = Pressed
    elseif Mode == "Toggle" then
        if not Pressed then return end
        BindData.Value = not BindData.Value
    elseif Mode == "Always" then
        BindData.Value = true
    else
        if not Pressed then return end
        BindData.Value = not BindData.Value
    end
    if BindData.Flag then Library.Flags[BindData.Flag] = BindData.Value end
    if type(BindData.Callback) == "function" then Call(BindData.Callback, BindData.Value) end
    if BindData.Render then Call(BindData.Render) end
    RefreshKeybindList()
end

local function CreateKeybind(Window, Row, Data, RightOffset)
    Data = Data or {}
    local Flag = tostring(Data.Flag or Data.Name or ("Keybind" .. tostring(#Library.Keybinds + 1)))
    local BindData = {
        Flag = Flag,
        Name = tostring(Data.Name or Flag),
        Key = NormalizeKey(Data.Default),
        Mode = tostring(Data.Mode or "Toggle"),
        Callback = Data.Callback,
        EnabledFlag = Data.EnabledFlag,
        Value = tostring(Data.Mode or "Toggle") == "Always",
        Destroyed = false
    }
    Library.Flags[Flag] = BindData.Value
    local Button = Create("TextButton", {
        Parent = Row,
        Size = UDim2.fromOffset(66, 16),
        Position = UDim2.new(1, -(RightOffset or 0) - 66, 0.5, -8),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 15
    })
    local Label = Create("TextLabel", {
        Parent = Button,
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.SourceSans,
        TextSize = 13,
        TextColor3 = Colors.TextBind,
        Text = ""
    })
    function BindData.Render()
        local Capturing = Library.Capture == BindData
        Label.Text = Capturing and "[press key]" or ("[" .. KeyDisplay(BindData.Key) .. "]")
        Label.TextColor3 = Capturing and Accent() or Colors.TextBind
    end
    function BindData:Set(Value)
        if type(Value) == "table" then
            if Value.Key ~= nil or Value.key ~= nil then BindData.Key = NormalizeKey(Value.Key or Value.key) end
            if Value.Mode ~= nil or Value.mode ~= nil then BindData.Mode = tostring(Value.Mode or Value.mode) end
        else
            BindData.Key = NormalizeKey(Value)
        end
        BindData.Render()
        RefreshKeybindList()
    end
    RegisterFlag(Flag, BindData.Value, function(Value)
        if type(Value) == "table" or typeof(Value) == "EnumItem" or type(Value) == "string" then BindData:Set(Value) return end
        BindData.Value = Value == true
        Library.Flags[Flag] = BindData.Value
        BindData.Render()
    end)
    Bind(Button.MouseButton1Click:Connect(function()
        Library.Capture = BindData
        BindData.Render()
    end))
    Library.Keybinds[#Library.Keybinds + 1] = BindData
    RegisterRenderer(BindData.Render)
    if BindData.Mode == "Always" then task.defer(function() FireKeybind(BindData, true) end) end
    return BindData
end

local function UpdateAll()
    for Index = #Library.Renderers, 1, -1 do
        local Renderer = Library.Renderers[Index]
        if type(Renderer) == "function" then Call(Renderer) else table.remove(Library.Renderers, Index) end
    end
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods
local PageMethods = {}
PageMethods.__index = PageMethods
local SubPageMethods = {}
SubPageMethods.__index = SubPageMethods
local SectionMethods = {}
SectionMethods.__index = SectionMethods

local function ReflowTabs(Window)
    local Count = #Window.PagesOrder
    if Count == 0 then return end
    for Index, Page in ipairs(Window.PagesOrder) do
        Page.Button.Size = UDim2.new(1 / Count, 0, 1, 0)
        Page.Button.Position = UDim2.new((Index - 1) / Count, 0, 0, 0)
        if Page.Divider then Page.Divider.Visible = Index < Count end
    end
end

local function SelectPage(Window, Page)
    Window.ActivePage = Page
    for _, Item in ipairs(Window.PagesOrder) do
        local Selected = Item == Page
        Item.Panel.Visible = Selected
        Item.Button.TextColor3 = Selected and Colors.TextBright or Colors.TextDim
    end
end

local function SelectSubPage(Page, SubPage)
    Page.ActiveSubPage = SubPage
    for _, Item in ipairs(Page.SubPagesOrder) do
        local Selected = Item == SubPage
        Item.Frame.Visible = Selected
        Item.Button.TextColor3 = Selected and Accent() or Colors.TextDim
    end
end

local function CreatePopupLayer(Window)
    local Dropdown = Create("Frame", {
        Parent = Window.ScreenGui,
        Size = UDim2.fromOffset(120, 100),
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 1000
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Create("UIStroke", {Color = Colors.DropdownBord, Thickness = 1})})
    local Scroll = Create("ScrollingFrame", {
        Parent = Dropdown,
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.fromOffset(1, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Color3.fromRGB(80, 80, 80),
        ZIndex = 1001
    }, {Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder})})
    Window.Dropdown = Dropdown
    Window.DropdownScroll = Scroll

    local Picker = Create("Frame", {
        Parent = Window.ScreenGui,
        Size = UDim2.fromOffset(220, 215),
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 2000
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1})})
    local SV = Create("Frame", {Parent = Picker, Size = UDim2.fromOffset(180, 180), Position = UDim2.fromOffset(10, 10), BackgroundColor3 = Color3.new(1, 0, 0), BorderSizePixel = 0, ZIndex = 2001})
    Create("Frame", {Parent = SV, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2002}, {Create("UIGradient", {Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})})})
    Create("Frame", {Parent = SV, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.new(0, 0, 0), BorderSizePixel = 0, ZIndex = 2003}, {Create("UIGradient", {Rotation = 90, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})})
    local SVCursor = Create("Frame", {Parent = SV, Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2004}, {Create("UICorner", {CornerRadius = UDim.new(1, 0)}), Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    local Hue = Create("Frame", {Parent = Picker, Size = UDim2.fromOffset(14, 180), Position = UDim2.fromOffset(198, 10), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2001}, {Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)), ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)), ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))})})})
    local HueCursor = Create("Frame", {Parent = Hue, Size = UDim2.new(1, 4, 0, 2), Position = UDim2.fromOffset(-2, 0), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2002}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    local Alpha = Create("Frame", {Parent = Picker, Size = UDim2.fromOffset(180, 11), Position = UDim2.fromOffset(10, 196), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2001})
    local AlphaGradient = Create("UIGradient", {Parent = Alpha, Rotation = 0, Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})})
    local AlphaCursor = Create("Frame", {Parent = Alpha, Size = UDim2.new(0, 2, 1, 4), Position = UDim2.new(1, 0, 0, -2), BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 2002}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    Window.Picker = Picker
    Window.PickerSV = SV
    Window.PickerSVCursor = SVCursor
    Window.PickerHue = Hue
    Window.PickerHueCursor = HueCursor
    Window.PickerAlpha = Alpha
    Window.PickerAlphaGradient = AlphaGradient
    Window.PickerAlphaCursor = AlphaCursor
    Window.PickerActive = nil
    Window.PickerDragging = nil

    local function ClampPopup(Size, Position)
        local Viewport = Window.ScreenGui.AbsoluteSize
        if Viewport.X <= 0 or Viewport.Y <= 0 then
            local Camera = workspace.CurrentCamera
            Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
        end
        return Vector2.new(math.clamp(Position.X, 4, math.max(4, Viewport.X - Size.X - 4)), math.clamp(Position.Y, 4, math.max(4, Viewport.Y - Size.Y - 4)))
    end
    Window.ClampPopup = ClampPopup

    local function UpdatePickerFromMouse(Mode)
        local Active = Window.PickerActive
        if not Active then return end
        local Mouse = MousePoint(Window.ScreenGui)
        local H, S, V = Color3.toHSV(Active.Color)
        if Mode == "SV" then
            local Pos, Size = GuiPoint(Window.ScreenGui, Window.PickerSV.AbsolutePosition), Window.PickerSV.AbsoluteSize
            if Size.X <= 0 or Size.Y <= 0 then return end
            S = math.clamp((Mouse.X - Pos.X) / Size.X, 0, 1)
            V = 1 - math.clamp((Mouse.Y - Pos.Y) / Size.Y, 0, 1)
        elseif Mode == "Hue" then
            local Pos, Size = GuiPoint(Window.ScreenGui, Window.PickerHue.AbsolutePosition), Window.PickerHue.AbsoluteSize
            if Size.Y <= 0 then return end
            H = math.clamp((Mouse.Y - Pos.Y) / Size.Y, 0, 1)
        elseif Mode == "Alpha" then
            local Pos, Size = GuiPoint(Window.ScreenGui, Window.PickerAlpha.AbsolutePosition), Window.PickerAlpha.AbsoluteSize
            if Size.X <= 0 then return end
            Active.Alpha = math.clamp((Mouse.X - Pos.X) / Size.X, 0, 1)
        end
        Active.Color = Color3.fromHSV(H, S, V)
        Window.PickerSV.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
        Window.PickerSVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
        Window.PickerHueCursor.Position = UDim2.new(0, -2, H, 0)
        Window.PickerAlphaCursor.Position = UDim2.new(Active.Alpha or 1, 0, 0, -2)
        Window.PickerAlphaGradient.Color = ColorSequence.new(Active.Color)
        Active:Set(Active.Color, Active.Alpha, true)
    end

    Bind(SV.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Window.PickerDragging = "SV" UpdatePickerFromMouse("SV") end end))
    Bind(Hue.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Window.PickerDragging = "Hue" UpdatePickerFromMouse("Hue") end end))
    Bind(Alpha.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Window.PickerDragging = "Alpha" UpdatePickerFromMouse("Alpha") end end))
    Bind(UserInputService.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement and Window.PickerDragging then UpdatePickerFromMouse(Window.PickerDragging) end
    end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Window.PickerDragging = nil end end))

    Bind(UserInputService.InputBegan:Connect(function(Input)
        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        if Window.Dropdown.Visible then
            local Mouse, Pos, Size = MousePoint(Window.ScreenGui), GuiPoint(Window.ScreenGui, Window.Dropdown.AbsolutePosition), Window.Dropdown.AbsoluteSize
            if not (Mouse.X >= Pos.X and Mouse.X <= Pos.X + Size.X and Mouse.Y >= Pos.Y and Mouse.Y <= Pos.Y + Size.Y) then Window:CloseDropdown() end
        end
        if Window.Picker.Visible then
            local Mouse, Pos, Size = MousePoint(Window.ScreenGui), GuiPoint(Window.ScreenGui, Window.Picker.AbsolutePosition), Window.Picker.AbsoluteSize
            if not (Mouse.X >= Pos.X and Mouse.X <= Pos.X + Size.X and Mouse.Y >= Pos.Y and Mouse.Y <= Pos.Y + Size.Y) then Window:ClosePicker() end
        end
    end))
end

function WindowMethods:CloseDropdown()
    self.Dropdown.Visible = false
    self.DropdownOwner = nil
end

function WindowMethods:ClosePicker()
    self.Picker.Visible = false
    self.PickerActive = nil
    self.PickerDragging = nil
end

function WindowMethods:OpenDropdown(Owner, Anchor, Items, Selected, Multi, Callback)
    self:ClosePicker()
    self:CloseDropdown()
    self.DropdownOwner = Owner
    local Scroll = self.DropdownScroll
    for _, Child in ipairs(Scroll:GetChildren()) do if Child:IsA("TextButton") then Child:Destroy() end end
    local RowHeight = 18
    for Index, Value in ipairs(Items or {}) do
        local IsSelected = Multi and type(Selected) == "table" and table.find(Selected, Value) ~= nil or Selected == Value
        local Button = Create("TextButton", {
            Parent = Scroll,
            Size = UDim2.new(1, 0, 0, RowHeight),
            BackgroundTransparency = 1,
            BackgroundColor3 = Colors.DropdownBg,
            Text = tostring(Value),
            TextColor3 = IsSelected and Accent() or Colors.Text,
            Font = Enum.Font.SourceSans,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            LayoutOrder = Index,
            ZIndex = 1002
        }, {Create("UIPadding", {PaddingLeft = UDim.new(0, 7)})})
        Bind(Button.MouseEnter:Connect(function() Button.BackgroundTransparency = 0.9 Button.BackgroundColor3 = Accent() Button.TextColor3 = Colors.TextBright end))
        Bind(Button.MouseLeave:Connect(function()
            local ActiveSelected = Multi and type(Owner.Get) == "function" and table.find(Owner:Get(), Value) ~= nil or (type(Owner.Get) == "function" and Owner:Get() == Value)
            Button.BackgroundTransparency = 1
            Button.TextColor3 = ActiveSelected and Accent() or Colors.Text
        end))
        Bind(Button.MouseButton1Click:Connect(function()
            Callback(Value)
            if not Multi then self:CloseDropdown() else
                local ActiveSelected = type(Owner.Get) == "function" and table.find(Owner:Get(), Value) ~= nil
                Button.TextColor3 = ActiveSelected and Accent() or Colors.Text
            end
        end))
    end
    local Width = math.max(Anchor.AbsoluteSize.X, 120)
    local Height = math.min((#Items * RowHeight) + 4, 180)
    self.Dropdown.Size = UDim2.fromOffset(Width, math.max(22, Height))
    Scroll.CanvasPosition = Vector2.zero
    local AnchorPos = GuiPoint(self.ScreenGui, Anchor.AbsolutePosition)
    local Position = self.ClampPopup(Vector2.new(Width, math.max(22, Height)), Vector2.new(AnchorPos.X, AnchorPos.Y + Anchor.AbsoluteSize.Y + 2))
    self.Dropdown.Position = UDim2.fromOffset(Position.X, Position.Y)
    self.Dropdown.Visible = true
end

function WindowMethods:OpenPicker(Object, Anchor)
    self:CloseDropdown()
    self.PickerActive = Object
    local H, S, V = Color3.toHSV(Object.Color)
    self.PickerSV.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
    self.PickerSVCursor.Position = UDim2.new(S, 0, 1 - V, 0)
    self.PickerHueCursor.Position = UDim2.new(0, -2, H, 0)
    self.PickerAlphaCursor.Position = UDim2.new(Object.Alpha or 1, 0, 0, -2)
    self.PickerAlphaGradient.Color = ColorSequence.new(Object.Color)
    local AnchorPos = GuiPoint(self.ScreenGui, Anchor.AbsolutePosition)
    local PickerSize = Vector2.new(220, 215)
    local Viewport = self.ScreenGui.AbsoluteSize
    if Viewport.X <= 0 or Viewport.Y <= 0 then
        local Camera = workspace.CurrentCamera
        Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    end
    local RightX = AnchorPos.X + Anchor.AbsoluteSize.X + 6
    local LeftX = AnchorPos.X - PickerSize.X - 6
    local X = RightX + PickerSize.X <= Viewport.X - 4 and RightX or LeftX
    local Y = AnchorPos.Y - 10
    local Position = self.ClampPopup(PickerSize, Vector2.new(X, Y))
    self.Picker.Position = UDim2.fromOffset(Position.X, Position.Y)
    self.Picker.Visible = true
end

function Library:Window(Data)
    Data = Data or {}
    if self.ActiveWindow and type(self.ActiveWindow.Destroy) == "function" then self.ActiveWindow:Destroy() end
    local Parent = ParentGui()
    for _, Existing in ipairs(Parent:GetChildren()) do if Existing:IsA("ScreenGui") and Existing.Name == "AtramentaLibrary" then Existing:Destroy() end end
    local ScreenGui = Create("ScreenGui", {Name = "AtramentaLibrary", Parent = Parent, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global, DisplayOrder = 100, IgnoreGuiInset = false})
    self.Guis[#self.Guis + 1] = ScreenGui
    self.Holder = ScreenGui
    local Size = Data.Size
    local Width, Height = 680, 500
    if typeof(Size) == "UDim2" then Width = math.max(Size.X.Offset, 448) Height = math.max(Size.Y.Offset, 446) end
    local Main = Create("Frame", {
        Parent = ScreenGui,
        Size = UDim2.fromOffset(Width, Height),
        Position = UDim2.new(0.5, -math.floor(Width / 2), 0.5, -math.floor(Height / 2)),
        BackgroundColor3 = Colors.Bg,
        BorderSizePixel = 0,
        ClipsDescendants = false
    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1})})
    local TitleBar = Create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Colors.TitleBg, BorderSizePixel = 0}, {
        Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(7, 7, 7))})}),
        Create("TextLabel", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = tostring(Data.Name or "Atramenta.rip"), Font = Enum.Font.SourceSans, TextSize = 13, TextColor3 = Color3.fromRGB(185, 182, 196)}),
        Create("Frame", {Name = "AccentLine", Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Accent(), BorderSizePixel = 0}, {Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))})})})
    })
    local Content = Create("Frame", {Parent = Main, Position = UDim2.fromOffset(0, 22), Size = UDim2.new(1, 0, 1, -48), BackgroundTransparency = 1, ClipsDescendants = false})
    local TabBar = Create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 1, -26), BackgroundColor3 = Colors.TabBg, BorderSizePixel = 0}, {
        Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
        Create("Frame", {Name = "AccentLine", Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = Accent(), BorderSizePixel = 0}, {Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))})})}),
        Create("Frame", {Size = UDim2.new(1, 0, 0, 6), BackgroundColor3 = Colors.TabBg, BorderSizePixel = 0, ZIndex = 0})
    })
    local Window = setmetatable({Library = self, ScreenGui = ScreenGui, Main = Main, TitleBar = TitleBar, Content = Content, TabBar = TabBar, Pages = {}, PagesOrder = {}, ActivePage = nil, Visible = true, Destroyed = false}, WindowMethods)
    self.ActiveWindow = Window
    CreatePopupLayer(Window)
    MakeDraggable(Main, TitleBar)
    RegisterRenderer(function()
        local A = Accent()
        local TitleLine = TitleBar:FindFirstChild("AccentLine")
        local TabLine = TabBar:FindFirstChild("AccentLine")
        for _, Line in ipairs({TitleLine, TabLine}) do
            if Line then
                Line.BackgroundColor3 = A
                local Gradient = Line:FindFirstChildOfClass("UIGradient")
                if Gradient then Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.new(0, 0, 0)), ColorSequenceKeypoint.new(0.5, A), ColorSequenceKeypoint.new(1, Color3.new(0, 0, 0))}) end
            end
        end
    end)
    return Window
end

function WindowMethods:SetVisible(State)
    self.Visible = State == true
    self.Main.Visible = self.Visible
    if not self.Visible then self:CloseDropdown() self:ClosePicker() end
end

function WindowMethods:Toggle() self:SetVisible(not self.Visible) end
function WindowMethods:Destroy()
    if self.Destroyed then return end
    self.Destroyed = true
    if self.ScreenGui and self.ScreenGui.Parent then self.ScreenGui:Destroy() end
    if Library.ActiveWindow == self then Library.ActiveWindow = nil end
end

function WindowMethods:Page(Data)
    Data = Data or {}
    local Name = tostring(Data.Name or ("page" .. tostring(#self.PagesOrder + 1)))
    if self.Pages[Name] then return self.Pages[Name] end
    local Button = Create("TextButton", {Parent = self.TabBar, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = string.lower(Name), Font = Enum.Font.SourceSans, TextSize = 13, TextColor3 = Colors.TextDim, AutoButtonColor = false, ZIndex = 2})
    local Divider = Create("Frame", {Parent = Button, Size = UDim2.fromOffset(1, 14), Position = UDim2.new(1, -1, 0.5, -7), BackgroundColor3 = Color3.fromRGB(32, 30, 38), BorderSizePixel = 0, ZIndex = 3})
    local Panel = Create("Frame", {Parent = self.Content, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false})
    local SubBar = Create("Frame", {Parent = Panel, Size = UDim2.new(1, -20, 0, 22), Position = UDim2.fromOffset(10, 4), BackgroundTransparency = 1, Visible = false})
    local SubLayout = Create("UIListLayout", {Parent = SubBar, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 18)})
    local Holder = Create("Frame", {Parent = Panel, Size = UDim2.new(1, 0, 1, -32), Position = UDim2.fromOffset(0, 32), BackgroundTransparency = 1, ClipsDescendants = true})
    local Page = setmetatable({Window = self, Name = Name, Button = Button, Divider = Divider, Panel = Panel, SubBar = SubBar, SubLayout = SubLayout, Holder = Holder, SubPages = {}, SubPagesOrder = {}, ActiveSubPage = nil, DefaultSubPage = nil}, PageMethods)
    self.Pages[Name] = Page
    self.PagesOrder[#self.PagesOrder + 1] = Page
    ReflowTabs(self)
    Bind(Button.MouseButton1Click:Connect(function() SelectPage(self, Page) end))
    if not self.ActivePage then SelectPage(self, Page) end
    return Page
end

function PageMethods:SubPage(Data)
    Data = Data or {}
    local Name = tostring(Data.Name or ("sub" .. tostring(#self.SubPagesOrder + 1)))
    if self.SubPages[Name] then return self.SubPages[Name] end
    self.SubBar.Visible = true
    local Button = Create("TextButton", {Parent = self.SubBar, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 1, 0), BackgroundTransparency = 1, Text = string.lower(Name), Font = Enum.Font.SourceSans, TextSize = 13, TextColor3 = Colors.TextDim, AutoButtonColor = false, LayoutOrder = #self.SubPagesOrder + 1})
    local Frame = Create("Frame", {Parent = self.Holder, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false})
    local Left = Create("ScrollingFrame", {Parent = Frame, Position = UDim2.fromOffset(10, 8), Size = UDim2.new(0.5, -15, 1, -12), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(55, 52, 64), ScrollingDirection = Enum.ScrollingDirection.Y}, {Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)}), Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6)})})
    local Right = Create("ScrollingFrame", {Parent = Frame, Position = UDim2.new(0.5, 5, 0, 8), Size = UDim2.new(0.5, -15, 1, -12), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Color3.fromRGB(55, 52, 64), ScrollingDirection = Enum.ScrollingDirection.Y}, {Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10)}), Create("UIPadding", {PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 6)})})
    local SubPage = setmetatable({Page = self, Name = Name, Button = Button, Frame = Frame, Left = Left, Right = Right, Sections = {}, Order = 0}, SubPageMethods)
    self.SubPages[Name] = SubPage
    self.SubPagesOrder[#self.SubPagesOrder + 1] = SubPage
    Bind(Button.MouseButton1Click:Connect(function() SelectSubPage(self, SubPage) end))
    if not self.ActiveSubPage then SelectSubPage(self, SubPage) end
    return SubPage
end

function PageMethods:Section(Data)
    if not self.DefaultSubPage then
        self.DefaultSubPage = self:SubPage({Name = self.Name, Columns = 2})
        self.SubBar.Visible = false
        self.Holder.Position = UDim2.fromOffset(0, 0)
        self.Holder.Size = UDim2.fromScale(1, 1)
    end
    return self.DefaultSubPage:Section(Data)
end

local function CreateSectionRoot(SubPage, Data)
    Data = Data or {}
    local Side = tonumber(Data.Side) == 2 and 2 or 1
    local Parent = Side == 2 and SubPage.Right or SubPage.Left
    SubPage.Order = SubPage.Order + 1
    local Container = Create("Frame", {Parent = Parent, Size = UDim2.new(1, -2, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, LayoutOrder = SubPage.Order})
    local Outline = Create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, {
        Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1}),
        Create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 18), PaddingBottom = UDim.new(0, 8)}),
        Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    })
    local Header = Create("TextLabel", {Parent = Container, AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.new(0, 0, 0, 14), Position = UDim2.fromOffset(8, 2), AnchorPoint = Vector2.new(0, 0), BackgroundColor3 = Colors.Bg, BorderSizePixel = 0, Text = string.lower(tostring(Data.Name or "section")), TextColor3 = Colors.ColHdr, Font = Enum.Font.SourceSans, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, ZIndex = 10}, {Create("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})})
    return Container, Outline, Header
end

function SubPageMethods:Section(Data)
    local Container, Outline, Header = CreateSectionRoot(self, Data)
    local Section = setmetatable({SubPage = self, Window = self.Page.Window, Root = Container, Body = Outline, Header = Header, Controls = {}}, SectionMethods)
    self.Sections[#self.Sections + 1] = Section
    return Section
end

local function AddControl(Section, Object)
    Section.Controls[#Section.Controls + 1] = Object
    return Object
end

local function MakeColorpicker(Section, Row, Data, RightOffset)
    Data = Data or {}
    local Default = Data.Default
    local InitialColor, InitialAlpha = Color3.new(1, 1, 1), 1
    if typeof(Default) == "Color3" then InitialColor = Default
    elseif type(Default) == "table" and typeof(Default.Color) == "Color3" then InitialColor = Default.Color InitialAlpha = 1 - math.clamp(tonumber(Default.Transparency) or 0, 0, 1) end
    local Flag = tostring(Data.Flag or Data.Name or ("Color" .. tostring(#Section.Controls + 1)))
    if typeof(Library.Flags[Flag]) == "Color3" then InitialColor = Library.Flags[Flag] end
    local TallRow = Row.Size.Y.Offset > 20
    local ButtonPosition = TallRow and UDim2.new(1, -(RightOffset or 0) - 18, 0, 1) or UDim2.new(1, -(RightOffset or 0) - 18, 0.5, -6)
    local Button = Create("TextButton", {Parent = Row, Size = UDim2.fromOffset(18, 12), Position = ButtonPosition, BackgroundColor3 = InitialColor, AutoButtonColor = false, Text = "", ZIndex = 20}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Colors.CbBorder, Thickness = 1})})
    local Object = {Row = Row, Button = Button, Color = InitialColor, Alpha = InitialAlpha, Flag = Flag}
    function Object:Set(Color, Alpha, FromPicker)
        if type(Color) == "table" and typeof(Color.Color) == "Color3" then
            Alpha = 1 - math.clamp(tonumber(Color.Transparency) or 0, 0, 1)
            Color = Color.Color
        end
        if typeof(Color) ~= "Color3" then return end
        Object.Color = Color
        if Alpha ~= nil then Object.Alpha = math.clamp(tonumber(Alpha) or 1, 0, 1) end
        Library.Flags[Flag] = Object.Color
        Button.BackgroundColor3 = Object.Color
        if type(Data.Callback) == "function" then Call(Data.Callback, Object.Color, Object.Alpha) end
    end
    function Object:Get() return Object.Color end
    RegisterFlag(Flag, InitialColor, function(Value) Object:Set(Value) end)
    Bind(Button.MouseButton1Click:Connect(function() Section.Window:OpenPicker(Object, Button) end))
    return Object
end

local function AttachColorpicker(Section, Object, Row, BaseRightOffset)
    Object.Section = Section
    Object.Row = Object.Row or Row
    Object.RightOffset = tonumber(Object.RightOffset) or tonumber(BaseRightOffset) or 0
    if type(Object.Colorpicker) ~= "function" then
        function Object:Colorpicker(ColorData)
            local Offset = tonumber(self.RightOffset) or 0
            local Picker = MakeColorpicker(Section, Row, ColorData, Offset)
            self.RightOffset = Offset + 22
            return Picker
        end
    end
    return Object
end

function SectionMethods:Toggle(Data)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "toggle"), tostring(Data.Flag or Data.Name or "toggle")
    local Default = Data.Default == true
    if Library.Flags[Flag] ~= nil then Default = Library.Flags[Flag] == true end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    local Box = Create("Frame", {Parent = Row, Size = UDim2.fromOffset(9, 9), Position = UDim2.new(0, 0, 0.5, -4.5), BackgroundColor3 = Colors.CbBg}, {Create("UICorner", {CornerRadius = UDim.new(0, 1)}), Create("UIStroke", {Color = Colors.CbBorder, Thickness = 1})})
    local Label = Create("TextLabel", {Parent = Row, Position = UDim2.fromOffset(15, 0), Size = UDim2.new(1, -15, 1, 0), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Button = Create("TextButton", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 10})
    local Object = {Row = Row, Box = Box, Label = Label, Value = Default, Flag = Flag, RightOffset = 0}
    function Object:Render()
        Box.BackgroundColor3 = Object.Value and Accent() or Colors.CbBg
        Box:FindFirstChildOfClass("UIStroke").Color = Object.Value and Accent() or Colors.CbBorder
    end
    function Object:Set(Value, Silent)
        Object.Value = Value == true
        Library.Flags[Flag] = Object.Value
        Object:Render()
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Object.Value) end
    end
    function Object:Get() return Object.Value end
    function Object:Colorpicker(ColorData)
        local Offset = Object.RightOffset
        local Picker = MakeColorpicker(self.Section, Row, ColorData, Offset)
        Object.RightOffset = Offset + 22
        return Picker
    end
    function Object:Keybind(KeyData)
        Object.RightOffset = Object.RightOffset + 70
        return CreateKeybind(self.Section.Window, Row, KeyData, Object.RightOffset - 70)
    end
    Object.Section = self
    RegisterFlag(Flag, Default, function(Value) Object:Set(Value) end)
    RegisterRenderer(function() Object:Render() end)
    Bind(Button.MouseButton1Click:Connect(function() Object:Set(not Object.Value) end))
    Bind(Button.MouseEnter:Connect(function() Box:FindFirstChildOfClass("UIStroke").Color = Object.Value and Accent() or AccentBorder() Label.TextColor3 = Colors.TextBright end))
    Bind(Button.MouseLeave:Connect(function() Object:Render() Label.TextColor3 = Colors.Text end))
    AddControl(self, Object)
    return Object
end

function SectionMethods:Keybind(Data)
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, -75, 1, 0), BackgroundTransparency = 1, Text = tostring(Data.Name or "keybind"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Object = CreateKeybind(self.Window, Row, Data, 0)
    AttachColorpicker(self, Object, Row, 70)
    AddControl(self, Object)
    return Object
end

local function RoundStep(Value, Step)
    Step = tonumber(Step) or 0
    if Step <= 0 then return Value end
    return math.floor(Value / Step + 0.5) * Step
end

function SectionMethods:Slider(Data)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "slider"), tostring(Data.Flag or Data.Name or "slider")
    local Minimum, Maximum = tonumber(Data.Min) or 0, tonumber(Data.Max) or 100
    local Step = tonumber(Data.Step) or 1
    local Default = math.clamp(tonumber(Data.Default) or Minimum, Minimum, Maximum)
    if type(Library.Flags[Flag]) == "number" then Default = math.clamp(Library.Flags[Flag], Minimum, Maximum) end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Minus = Create("TextButton", {Parent = Row, Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(0, 13), BackgroundTransparency = 1, Text = "-", TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSansBold, TextSize = 14})
    local Plus = Create("TextButton", {Parent = Row, Size = UDim2.fromOffset(12, 12), Position = UDim2.new(1, -12, 0, 13), BackgroundTransparency = 1, Text = "+", TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSansBold, TextSize = 14})
    local Track = Create("Frame", {Parent = Row, Size = UDim2.new(1, -36, 0, 3), Position = UDim2.fromOffset(18, 17), BackgroundColor3 = Colors.SliderTrack, BorderSizePixel = 0})
    local Fill = Create("Frame", {Parent = Track, Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0}, {Create("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, AccentDark()), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, AccentDark())})})})
    local ValueLabel = Create("TextLabel", {Parent = Track, Size = UDim2.fromOffset(56, 12), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1, Text = "", TextColor3 = Colors.TextBright, Font = Enum.Font.SourceSans, TextSize = 12, ZIndex = 5}, {Create("UIStroke", {Color = Color3.new(0, 0, 0), Thickness = 1})})
    local Object = {Row = Row, Value = Default, Flag = Flag}
    function Object:Render()
        local Ratio = Maximum > Minimum and math.clamp((Object.Value - Minimum) / (Maximum - Minimum), 0, 1) or 0
        Fill.Size = UDim2.new(Ratio, 0, 1, 0)
        ValueLabel.Position = UDim2.new(Ratio, 0, 0.5, 0)
        local Decimals = Step < 1 and math.max(0, math.ceil(-math.log10(Step))) or 0
        ValueLabel.Text = string.format("%." .. tostring(math.min(Decimals, 4)) .. "f", Object.Value) .. tostring(Data.Suffix or "")
        local Gradient = Fill:FindFirstChildOfClass("UIGradient")
        if Gradient then Gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, AccentDark()), ColorSequenceKeypoint.new(0.5, Accent()), ColorSequenceKeypoint.new(1, AccentDark())}) end
    end
    function Object:Set(Value, Silent)
        Value = math.clamp(RoundStep(tonumber(Value) or Minimum, Step), Minimum, Maximum)
        Object.Value = Value
        Library.Flags[Flag] = Value
        Object:Render()
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Value) end
    end
    function Object:Get() return Object.Value end
    local Dragging = false
    local function FromMouse()
        local Width = Track.AbsoluteSize.X
        if Width <= 0 then return end
        local Mouse = MousePoint(self.Window.ScreenGui)
        local T = math.clamp((Mouse.X - GuiPoint(self.Window.ScreenGui, Track.AbsolutePosition).X) / Width, 0, 1)
        Object:Set(Minimum + (Maximum - Minimum) * T)
    end
    Bind(Track.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true FromMouse() end end))
    Bind(UserInputService.InputChanged:Connect(function(Input) if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then FromMouse() end end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end))
    Bind(Minus.MouseButton1Click:Connect(function() Object:Set(Object.Value - Step) end))
    Bind(Plus.MouseButton1Click:Connect(function() Object:Set(Object.Value + Step) end))
    RegisterFlag(Flag, Default, function(Value) Object:Set(Value) end)
    RegisterRenderer(function() Object:Render() end)
    AttachColorpicker(self, Object, Row, 0)
    AddControl(self, Object)
    return Object
end

function SectionMethods:RangeSlider(Data)
    Data = Data or {}
    local Minimum, Maximum = tonumber(Data.Min) or 0, tonumber(Data.Max) or 100
    local Step = tonumber(Data.Step) or 1
    local Default = type(Data.Default) == "table" and Data.Default or {Minimum, Maximum}
    local Low = math.clamp(tonumber(Default[1]) or Minimum, Minimum, Maximum)
    local High = math.clamp(tonumber(Default[2]) or Maximum, Minimum, Maximum)
    if Low > High then Low, High = High, Low end
    local Flag = tostring(Data.Flag or Data.Name or "range")
    local MinFlag = tostring(Data.MinFlag or (Flag .. " Minimum"))
    local MaxFlag = tostring(Data.MaxFlag or (Flag .. " Maximum"))
    if type(Library.Flags[MinFlag]) == "number" then Low = Library.Flags[MinFlag] end
    if type(Library.Flags[MaxFlag]) == "number" then High = Library.Flags[MaxFlag] end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 12), BackgroundTransparency = 1, Text = tostring(Data.Name or "range"), TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Track = Create("Frame", {Parent = Row, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.fromOffset(0, 20), BackgroundColor3 = Colors.SliderTrack, BorderSizePixel = 0})
    local Fill = Create("Frame", {Parent = Track, BackgroundColor3 = Accent(), BorderSizePixel = 0})
    local LowLabel = Create("TextLabel", {Parent = Row, Size = UDim2.fromOffset(60, 10), Position = UDim2.fromOffset(0, 24), BackgroundTransparency = 1, TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSans, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left})
    local HighLabel = Create("TextLabel", {Parent = Row, Size = UDim2.fromOffset(60, 10), Position = UDim2.new(1, -60, 0, 24), BackgroundTransparency = 1, TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSans, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Right})
    local Object = {Row = Row, Low = Low, High = High, Flag = Flag}
    function Object:Render()
        local A = Maximum > Minimum and (Object.Low - Minimum) / (Maximum - Minimum) or 0
        local B = Maximum > Minimum and (Object.High - Minimum) / (Maximum - Minimum) or 1
        Fill.Position = UDim2.new(A, 0, 0, 0)
        Fill.Size = UDim2.new(math.max(0, B - A), 0, 1, 0)
        Fill.BackgroundColor3 = Accent()
        LowLabel.Text = tostring(Object.Low) .. tostring(Data.Suffix or "")
        HighLabel.Text = tostring(Object.High) .. tostring(Data.Suffix or "")
    end
    function Object:Set(A, B, Silent)
        if type(A) == "table" then B = A[2] or A.Max or A.Maximum A = A[1] or A.Min or A.Minimum end
        A = math.clamp(RoundStep(tonumber(A) or Object.Low, Step), Minimum, Maximum)
        B = math.clamp(RoundStep(tonumber(B) or Object.High, Step), Minimum, Maximum)
        if A > B then A, B = B, A end
        Object.Low, Object.High = A, B
        Library.Flags[Flag] = {A, B}
        Library.Flags[MinFlag] = A
        Library.Flags[MaxFlag] = B
        Object:Render()
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, A, B) end
    end
    function Object:Get() return {Object.Low, Object.High} end
    local Dragging
    local function FromMouse()
        local Width = Track.AbsoluteSize.X
        if Width <= 0 then return end
        local Mouse = MousePoint(self.Window.ScreenGui)
        local T = math.clamp((Mouse.X - GuiPoint(self.Window.ScreenGui, Track.AbsolutePosition).X) / Width, 0, 1)
        local Value = RoundStep(Minimum + (Maximum - Minimum) * T, Step)
        if math.abs(Value - Object.Low) <= math.abs(Value - Object.High) then Object:Set(Value, Object.High) else Object:Set(Object.Low, Value) end
    end
    Bind(Track.InputBegan:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true FromMouse() end end))
    Bind(UserInputService.InputChanged:Connect(function(Input) if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then FromMouse() end end))
    Bind(UserInputService.InputEnded:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end))
    RegisterFlag(Flag, {Low, High}, function(Value) Object:Set(Value) end)
    RegisterFlag(MinFlag, Low, function(Value) Object:Set(Value, Object.High) end)
    RegisterFlag(MaxFlag, High, function(Value) Object:Set(Object.Low, Value) end)
    RegisterRenderer(function() Object:Render() end)
    AttachColorpicker(self, Object, Row, 0)
    AddControl(self, Object)
    return Object
end

local function MakeDropdown(Section, Data, Multi)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "dropdown"), tostring(Data.Flag or Data.Name or "dropdown")
    local Items = type(Data.Items) == "table" and CloneValue(Data.Items) or {}
    local Default = Data.Default
    if Multi then
        Default = type(Default) == "table" and CloneValue(Default) or {}
        if type(Library.Flags[Flag]) == "table" then Default = CloneValue(Library.Flags[Flag]) end
    else
        if Default == nil then Default = Items[1] end
        if Library.Flags[Flag] ~= nil then Default = Library.Flags[Flag] end
    end
    local Row = Create("Frame", {Parent = Section.Body, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 13), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local DropFrame = Create("Frame", {Parent = Row, Size = UDim2.new(1, 0, 0, 17), Position = UDim2.fromOffset(0, 16), BackgroundColor3 = Colors.DropdownBg, BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Colors.DropdownBord, Thickness = 1}), Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 20)), ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 9, 9))})})})
    local Text = Create("TextLabel", {Parent = DropFrame, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(7, 0), BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, Text = "", TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd})
    local Arrow = Create("TextLabel", {Parent = DropFrame, Size = UDim2.fromOffset(14, 17), Position = UDim2.new(1, -14, 0, 0), BackgroundTransparency = 1, Text = "▼", TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSans, TextSize = 9})
    local Button = Create("TextButton", {Parent = DropFrame, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 5})
    local Object = {Section = Section, Row = Row, Frame = DropFrame, Items = Items, Value = Default, Flag = Flag, Multi = Multi}
    function Object:Get() return Multi and CloneValue(Object.Value) or Object.Value end
    function Object:Render()
        if Multi then
            Text.Text = #Object.Value > 0 and table.concat(Object.Value, ", ") or tostring(Data.Placeholder or "none")
        else Text.Text = tostring(Object.Value or "") end
        Arrow.TextColor3 = Section.Window.DropdownOwner == Object and Section.Window.Dropdown.Visible and Accent() or Colors.TextBind
    end
    function Object:Set(Value, Silent)
        if Multi then
            local Next = {}
            if type(Value) == "table" then
                for _, Item in ipairs(Value) do if table.find(Object.Items, Item) and not table.find(Next, Item) then Next[#Next + 1] = Item end end
            end
            if Data.AllowEmpty == false and #Next == 0 and Object.Items[1] then Next[1] = Object.Items[1] end
            local Maximum = tonumber(Data.Max) or #Object.Items
            while #Next > Maximum do table.remove(Next) end
            Object.Value = Next
            Library.Flags[Flag] = CloneValue(Next)
        else
            if table.find(Object.Items, Value) == nil and #Object.Items > 0 then Value = Object.Items[1] end
            Object.Value = Value
            Library.Flags[Flag] = Value
        end
        Object:Render()
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Object:Get()) end
    end
    function Object:SetItems(NewItems)
        Object.Items = type(NewItems) == "table" and CloneValue(NewItems) or {}
        if Multi then Object:Set(Object.Value, true) else if table.find(Object.Items, Object.Value) == nil then Object:Set(Object.Items[1], true) end end
    end
    local function Choose(Value)
        if Multi then
            local Next = Object:Get()
            local Index = table.find(Next, Value)
            if Index then
                if Data.AllowEmpty == false and #Next <= 1 then return end
                table.remove(Next, Index)
            else
                if #Next >= (tonumber(Data.Max) or #Object.Items) then return end
                Next[#Next + 1] = Value
            end
            Object:Set(Next)
        else Object:Set(Value) end
    end
    Bind(Button.MouseButton1Click:Connect(function()
        if Section.Window.DropdownOwner == Object and Section.Window.Dropdown.Visible then Section.Window:CloseDropdown() Object:Render() return end
        Section.Window:OpenDropdown(Object, DropFrame, Object.Items, Object.Value, Multi, Choose)
        Object:Render()
    end))
    RegisterFlag(Flag, CloneValue(Default), function(Value) Object:Set(Value) end)
    RegisterRenderer(function() Object:Render() end)
    AttachColorpicker(Section, Object, Row, 0)
    AddControl(Section, Object)
    return Object
end

function SectionMethods:Dropdown(Data) return MakeDropdown(self, Data, false) end
function SectionMethods:MultiDropdown(Data) return MakeDropdown(self, Data, true) end

function SectionMethods:Label(Data)
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    local Label = Create("TextLabel", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = tostring(Data.Name or "label"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = tostring(Data.Alignment or "Left") == "Center" and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left})
    local Object = {Section = self, Row = Row, Label = Label, RightOffset = 0}
    function Object:Set(Value) Label.Text = tostring(Value) end
    function Object:Colorpicker(ColorData) local Offset = Object.RightOffset local Picker = MakeColorpicker(self.Section, Row, ColorData, Offset) Object.RightOffset = Offset + 22 return Picker end
    function Object:Keybind(KeyData) Object.RightOffset = Object.RightOffset + 70 return CreateKeybind(self.Section.Window, Row, KeyData, Object.RightOffset - 70) end
    AddControl(self, Object)
    return Object
end

function SectionMethods:Button(Data, Callback)
    if type(Data) == "string" then Data = {Name = Data, Callback = Callback} end
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1})
    local Frame = Create("Frame", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(22, 20, 26), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Color3.fromRGB(42, 38, 50), Thickness = 1, Enabled = false}), Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 20, 26)), ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 9, 11))})})})
    local AccentLine = Create("Frame", {Parent = Frame, Size = UDim2.new(0, 2, 1, -6), Position = UDim2.new(0, 1, 0.5, -3), AnchorPoint = Vector2.new(0, 0.5), BackgroundColor3 = Accent(), Visible = false, BorderSizePixel = 0})
    local Label = Create("TextLabel", {Parent = Frame, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = tostring(Data.Name or "button"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13})
    local Button = Create("TextButton", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false})
    Bind(Button.MouseEnter:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Enabled = true AccentLine.Visible = true Label.TextColor3 = Colors.TextBright end))
    Bind(Button.MouseLeave:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Enabled = false AccentLine.Visible = false Label.TextColor3 = Colors.Text end))
    Bind(Button.MouseButton1Click:Connect(function() if type(Data.Callback) == "function" then Call(Data.Callback) end end))
    RegisterRenderer(function() AccentLine.BackgroundColor3 = Accent() end)
    local Object = {Section = self, Row = Row, Button = Button, Frame = Frame, Label = Label, RightOffset = 0}
    AttachColorpicker(self, Object, Row, 0)
    return AddControl(self, Object)
end

function SectionMethods:Textbox(Data)
    Data = Data or {}
    local Name, Flag = tostring(Data.Name or "textbox"), tostring(Data.Flag or Data.Name or "textbox")
    local Default = tostring(Data.Default or "")
    if type(Library.Flags[Flag]) == "string" then Default = Library.Flags[Flag] end
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, 0, 0, 13), BackgroundTransparency = 1, Text = Name, TextColor3 = Colors.TextDim, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Frame = Create("Frame", {Parent = Row, Size = UDim2.new(1, 0, 0, 17), Position = UDim2.fromOffset(0, 16), BackgroundColor3 = Color3.fromRGB(9, 8, 10), BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 2)}), Create("UIStroke", {Color = Colors.CbBorder, Thickness = 1}), Create("UIGradient", {Rotation = 90, Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 18, 23)), ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 8, 10))})})})
    local Box = Create("TextBox", {Parent = Frame, Size = UDim2.new(1, -12, 1, 0), Position = UDim2.fromOffset(6, 0), BackgroundTransparency = 1, Text = Default, PlaceholderText = tostring(Data.Placeholder or "..."), PlaceholderColor3 = Colors.TextDim, TextColor3 = Colors.TextBright, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false})
    local Object = {Section = self, Row = Row, Box = Box, Value = Default, Flag = Flag, RightOffset = 0}
    function Object:Set(Value, Silent)
        Object.Value = tostring(Value or "")
        Library.Flags[Flag] = Object.Value
        if Box.Text ~= Object.Value then Box.Text = Object.Value end
        if not Silent and type(Data.Callback) == "function" then Call(Data.Callback, Object.Value) end
    end
    function Object:Get() return Object.Value end
    RegisterFlag(Flag, Default, function(Value) Object:Set(Value) end)
    Bind(Box:GetPropertyChangedSignal("Text"):Connect(function() Object:Set(Box.Text) end))
    Bind(Box.Focused:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Color = Accent() end))
    Bind(Box.FocusLost:Connect(function() Frame:FindFirstChildOfClass("UIStroke").Color = Colors.CbBorder end))
    AttachColorpicker(self, Object, Row, 0)
    AddControl(self, Object)
    return Object
end

function SectionMethods:Listbox(Data)
    Data = Data or {}
    local Height = tonumber(Data.Height) or 110
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, Height), BackgroundTransparency = 1})
    local List = Create("ScrollingFrame", {Parent = Row, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Color3.fromRGB(6, 5, 7), BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.TextBind}, {Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1}), Create("UIListLayout", {FillDirection = Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder})})
    local Object = {Section = self, Row = Row, List = List, Items = {}, Selected = nil, Buttons = {}, RightOffset = 0}
    function Object:SetItems(Items)
        Object.Items = type(Items) == "table" and CloneValue(Items) or {}
        for _, Button in ipairs(Object.Buttons) do if Button and Button.Parent then Button:Destroy() end end
        table.clear(Object.Buttons)
        if Object.Selected and not table.find(Object.Items, Object.Selected) then Object.Selected = nil end
        for Index, Item in ipairs(Object.Items) do
            local Button = Create("TextButton", {Parent = List, Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Text = tostring(Item), TextColor3 = Item == Object.Selected and Accent() or Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = false, LayoutOrder = Index}, {Create("UIPadding", {PaddingLeft = UDim.new(0, 6)})})
            Object.Buttons[#Object.Buttons + 1] = Button
            Bind(Button.MouseButton1Click:Connect(function()
                Object.Selected = Item
                for I, Other in ipairs(Object.Buttons) do Other.TextColor3 = Object.Items[I] == Object.Selected and Accent() or Colors.Text end
                if type(Data.Callback) == "function" then Call(Data.Callback, Item) end
            end))
        end
    end
    function Object:Get() return Object.Selected end
    function Object:Set(Value)
        if table.find(Object.Items, Value) then
            Object.Selected = Value
            for I, Other in ipairs(Object.Buttons) do Other.TextColor3 = Object.Items[I] == Object.Selected and Accent() or Colors.Text end
        end
    end
    Object:SetItems(Data.Items or {})
    AttachColorpicker(self, Object, Row, 0)
    return AddControl(self, Object)
end

function SectionMethods:Colorpicker(Data)
    Data = Data or {}
    local Row = Create("Frame", {Parent = self.Body, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1})
    Create("TextLabel", {Parent = Row, Size = UDim2.new(1, -26, 1, 0), BackgroundTransparency = 1, Text = tostring(Data.Name or "color"), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left})
    local Picker = MakeColorpicker(self, Row, Data, 0)
    return AddControl(self, Picker)
end

local function EncodeValue(Value, Seen, Depth)
    Depth = Depth or 0
    if Depth > 10 then return nil end
    local ValueType = typeof(Value)
    if ValueType == "Color3" then return {__type = "Color3", R = Value.R, G = Value.G, B = Value.B} end
    if ValueType == "EnumItem" then return {__type = "EnumItem", EnumType = tostring(Value.EnumType), Name = Value.Name} end
    if ValueType == "Vector2" then return {__type = "Vector2", X = Value.X, Y = Value.Y} end
    if ValueType == "Vector3" then return {__type = "Vector3", X = Value.X, Y = Value.Y, Z = Value.Z} end
    if ValueType == "UDim2" then return {__type = "UDim2", XScale = Value.X.Scale, XOffset = Value.X.Offset, YScale = Value.Y.Scale, YOffset = Value.Y.Offset} end
    if type(Value) == "boolean" or type(Value) == "string" then return Value end
    if type(Value) == "number" then if Value == Value and Value > -math.huge and Value < math.huge then return Value end return nil end
    if type(Value) ~= "table" then return nil end
    Seen = Seen or {}
    if Seen[Value] then return nil end
    Seen[Value] = true
    local Result, Count, MaxIndex, Array = {}, 0, 0, true
    for Key in pairs(Value) do
        Count = Count + 1
        if type(Key) ~= "number" or Key < 1 or Key % 1 ~= 0 then Array = false break end
        MaxIndex = math.max(MaxIndex, Key)
    end
    Array = Array and Count == MaxIndex
    if Array then
        for Index = 1, MaxIndex do
            local Encoded = EncodeValue(Value[Index], Seen, Depth + 1)
            if Encoded ~= nil then Result[#Result + 1] = Encoded end
        end
    else
        for Key, Item in pairs(Value) do
            if type(Key) == "string" or type(Key) == "number" then
                local Encoded = EncodeValue(Item, Seen, Depth + 1)
                if Encoded ~= nil then Result[tostring(Key)] = Encoded end
            end
        end
    end
    Seen[Value] = nil
    return Result
end

local function DecodeValue(Value, Depth)
    Depth = Depth or 0
    if Depth > 10 or type(Value) ~= "table" then return Value end
    if Value.__type == "Color3" then return Color3.new(tonumber(Value.R) or 0, tonumber(Value.G) or 0, tonumber(Value.B) or 0) end
    if Value.__type == "EnumItem" then
        local EnumName = tostring(Value.EnumType or ""):match("Enum%.(.+)")
        local EnumType = EnumName and Enum[EnumName]
        return EnumType and EnumType[Value.Name] or Value.Name
    end
    if Value.__type == "Vector2" then return Vector2.new(tonumber(Value.X) or 0, tonumber(Value.Y) or 0) end
    if Value.__type == "Vector3" then return Vector3.new(tonumber(Value.X) or 0, tonumber(Value.Y) or 0, tonumber(Value.Z) or 0) end
    if Value.__type == "UDim2" then return UDim2.new(tonumber(Value.XScale) or 0, tonumber(Value.XOffset) or 0, tonumber(Value.YScale) or 0, tonumber(Value.YOffset) or 0) end
    if Value.Color ~= nil and Value.Transparency ~= nil then
        local ColorValue = DecodeValue(Value.Color, Depth + 1)
        if type(ColorValue) == "string" then
            local Clean = ColorValue:gsub("#", "")
            if #Clean >= 6 then local Success, Parsed = Call(Color3.fromHex, Clean:sub(1, 6)) if Success then ColorValue = Parsed end end
        end
        return {Color = ColorValue, Transparency = math.clamp(tonumber(Value.Transparency) or 0, 0, 1)}
    end
    local Result = {}
    for Key, Item in pairs(Value) do Result[Key] = DecodeValue(Item, Depth + 1) end
    return Result
end

function Library:GetConfig()
    local Payload = {}
    for Name, Value in pairs(self.Flags or {}) do
        local Success, Encoded = Call(EncodeValue, Value, {}, 0)
        if Success and Encoded ~= nil then Payload[tostring(Name)] = Encoded end
    end
    local ControlBinds = {}
    for _, BindData in ipairs(self.Keybinds or {}) do
        if BindData and type(BindData.Flag) == "string" then
            ControlBinds[BindData.Flag] = {Key = BindData.Key, Mode = BindData.Mode}
        end
    end
    local BindSuccess, EncodedBinds = Call(EncodeValue, ControlBinds, {}, 0)
    if BindSuccess and EncodedBinds ~= nil then Payload.__AtramentaControlBinds = EncodedBinds end
    local Interface = {}
    if self.ActiveWindow and self.ActiveWindow.Main then Interface.MainPosition = self.ActiveWindow.Main.Position end
    Interface.Accent = self.Theme.Accent
    local SuccessInterface, EncodedInterface = Call(EncodeValue, Interface, {}, 0)
    if SuccessInterface and EncodedInterface then Payload.__AtramentaInterface = EncodedInterface end
    local Success, Source = Call(HttpService.JSONEncode, HttpService, Payload)
    return Success and Source or "{}"
end

function Library:LoadConfig(Source)
    local Success, Decoded = Call(HttpService.JSONDecode, HttpService, tostring(Source or "{}"))
    if not Success or type(Decoded) ~= "table" then return false end
    local FlagsSource = type(Decoded.Flags) == "table" and Decoded.Flags or Decoded
    local Flags, Names = {}, {}
    for Name, Value in pairs(FlagsSource) do
        local FlagName = tostring(Name)
        if not FlagName:match("^__Atramenta") and FlagName ~= "Flags" and FlagName ~= "AccentAlpha" then
            Flags[FlagName] = DecodeValue(Value, 0)
            Names[#Names + 1] = FlagName
        end
    end
    table.sort(Names)
    local Applied, Failed = 0, 0
    local function Apply(Name)
        local Value = CloneValue(Flags[Name])
        local Setter = self.Setters[Name]
        if type(Setter) == "function" then
            local Ok = Call(Setter, Value)
            if Ok then Applied = Applied + 1 else Failed = Failed + 1 end
        else
            self.Flags[Name] = Value
            Applied = Applied + 1
        end
    end
    for _, Name in ipairs(Names) do if type(Flags[Name]) ~= "boolean" then Apply(Name) end end
    for _, Name in ipairs(Names) do if Flags[Name] == false then Apply(Name) end end
    for _, Name in ipairs(Names) do if Flags[Name] == true then Apply(Name) end end
    local LoadedBinds = Decoded.__AtramentaControlBinds and DecodeValue(Decoded.__AtramentaControlBinds, 0) or nil
    if type(LoadedBinds) == "table" then
        for _, BindData in ipairs(self.Keybinds or {}) do
            local Stored = LoadedBinds[BindData.Flag]
            if type(Stored) == "table" and Stored[1] ~= nil and Stored.Key == nil and Stored.key == nil then Stored = Stored[1] end
            if type(Stored) == "table" then BindData:Set(Stored) end
        end
    end
    local Interface = Decoded.__AtramentaInterface and DecodeValue(Decoded.__AtramentaInterface, 0) or nil
    if type(Interface) == "table" then
        if typeof(Interface.Accent) == "Color3" then self.Theme.Accent = Interface.Accent end
        if self.ActiveWindow and self.ActiveWindow.Main and typeof(Interface.MainPosition) == "UDim2" then self.ActiveWindow.Main.Position = Interface.MainPosition end
    end
    UpdateAll()
    self.LastConfigLoadResult = {Applied = Applied, Failed = Failed}
    return Failed == 0 or Applied > 0
end

local function NormalizeConfigName(Name)
    Name = tostring(Name or ""):gsub("[%c%?%*%:%\"%<%>%|/\\]", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return Name:sub(1, 64)
end

local function ConfigPath(Name) return Library.Folders.Configs .. "/" .. NormalizeConfigName(Name) .. ".json" end
local LegacyFolders = {"Atramenta.rip/Configs", "Atramenta.rip/configs", "obels/configs"}

function Library:ListConfigs()
    EnsureFolders()
    local Seen, Items = {}, {}
    if type(listfiles) == "function" then
        for _, Folder in ipairs(LegacyFolders) do
            if type(isfolder) ~= "function" or isfolder(Folder) then
                local Success, Files = Call(listfiles, Folder)
                if Success and type(Files) == "table" then
                    for _, File in ipairs(Files) do
                        local Name = tostring(File):match("([^/\\]+)%.json$") or tostring(File):match("([^/\\]+)%.cfg$")
                        if Name and not Seen[Name:lower()] and Name ~= "Atramenta" and Name ~= "AtramentaConfigs" then
                            Seen[Name:lower()] = true
                            Items[#Items + 1] = Name
                        end
                    end
                end
            end
        end
    end
    table.sort(Items, function(A, B) return A:lower() < B:lower() end)
    return Items
end

function Library:SaveConfig(Name)
    Name = NormalizeConfigName(Name)
    if Name == "" or type(writefile) ~= "function" then return false end
    EnsureFolders()
    local Source = self:GetConfig()
    if type(Source) ~= "string" then return false end
    return Call(writefile, ConfigPath(Name), Source) == true
end

function Library:LoadConfigFile(Name)
    Name = NormalizeConfigName(Name)
    if Name == "" or type(readfile) ~= "function" then return false end
    local Paths, Seen = {}, {}
    local function Push(Path)
        if not Seen[Path] then Seen[Path] = true Paths[#Paths + 1] = Path end
    end
    Push(ConfigPath(Name))
    for _, Folder in ipairs(LegacyFolders) do
        Push(Folder .. "/" .. Name .. ".json")
        Push(Folder .. "/" .. Name .. ".cfg")
    end
    for _, Path in ipairs(Paths) do
        local Exists = type(isfile) ~= "function" or isfile(Path)
        if Exists then
            local Success, Source = Call(readfile, Path)
            if Success and type(Source) == "string" and self:LoadConfig(Source) then return true end
        end
    end
    return false
end

function Library:DeleteConfig(Name)
    Name = NormalizeConfigName(Name)
    if Name == "" or type(delfile) ~= "function" then return false end
    local Deleted, Paths, Seen = false, {}, {}
    local function Push(Path)
        if not Seen[Path] then Seen[Path] = true Paths[#Paths + 1] = Path end
    end
    Push(ConfigPath(Name))
    for _, Folder in ipairs(LegacyFolders) do
        Push(Folder .. "/" .. Name .. ".json")
        Push(Folder .. "/" .. Name .. ".cfg")
    end
    for _, Path in ipairs(Paths) do
        if type(isfile) ~= "function" or isfile(Path) then
            local Success = Call(delfile, Path)
            Deleted = Success == true or Deleted
        end
    end
    return Deleted
end

function Library:RefreshConfigsList(Listbox)
    local Items = self:ListConfigs()
    if type(Listbox) == "table" and type(Listbox.SetItems) == "function" then Listbox:SetItems(Items) end
    return Items
end

function WindowMethods:ConfigSystem()
    if self.ConfigPage then return self.ConfigPage end
    local Page = self:Page({Name = "config"})
    local Sub = Page:SubPage({Name = "configs"})
    local ListSection = Sub:Section({Name = "configs", Side = 1})
    local ActionSection = Sub:Section({Name = "actions", Side = 2})
    local Selected
    local Listbox = ListSection:Listbox({Items = Library:ListConfigs(), Height = 120, Callback = function(Value) Selected = Value end})
    local NameBox = ActionSection:Textbox({Name = "config name", Flag = "__ConfigName", Default = "", Placeholder = "name"})
    local function Refresh()
        local Items = Library:ListConfigs()
        Listbox:SetItems(Items)
        if Selected and table.find(Items, Selected) then Listbox:Set(Selected) else Selected = nil end
    end
    ActionSection:Button({Name = "create", Callback = function()
        local Name = NormalizeConfigName(NameBox:Get())
        if Name ~= "" and Library:SaveConfig(Name) then Selected = Name Refresh() Listbox:Set(Name) Library:Notification({Title = "configs", Description = Name .. " created", Duration = 2, Mode = "Success"}) end
    end})
    ActionSection:Button({Name = "save", Callback = function()
        local Name = NormalizeConfigName(NameBox:Get())
        if Name == "" then Name = Selected or "" end
        if Name ~= "" and Library:SaveConfig(Name) then Selected = Name Refresh() Listbox:Set(Name) Library:Notification({Title = "configs", Description = Name .. " saved", Duration = 2, Mode = "Success"}) end
    end})
    ActionSection:Button({Name = "load", Callback = function()
        local Name = Selected or NormalizeConfigName(NameBox:Get())
        if Name ~= "" and Library:LoadConfigFile(Name) then Library:Notification({Title = "configs", Description = Name .. " loaded", Duration = 2, Mode = "Success"}) end
    end})
    ActionSection:Button({Name = "delete", Callback = function()
        local Name = Selected or NormalizeConfigName(NameBox:Get())
        if Name ~= "" and Library:DeleteConfig(Name) then Selected = nil Refresh() Library:Notification({Title = "configs", Description = Name .. " deleted", Duration = 2, Mode = "Warn"}) end
    end})
    ActionSection:Button({Name = "refresh", Callback = Refresh})
    self.ConfigPage = Page
    self.ConfigListbox = Listbox
    self.RefreshConfigs = Refresh
    return Page
end

function Library:Watermark(Text)
    local Parent = ParentGui()
    local Gui = Create("ScreenGui", {Name = "AtramentaWatermark", Parent = Parent, ResetOnSpawn = false, DisplayOrder = 101, ZIndexBehavior = Enum.ZIndexBehavior.Global, IgnoreGuiInset = false})
    self.Guis[#self.Guis + 1] = Gui
    local Frame = Create("Frame", {Parent = Gui, Position = UDim2.fromOffset(12, 12), Size = UDim2.fromOffset(230, 22), BackgroundColor3 = Colors.TitleBg, BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1})})
    local Label = Create("TextLabel", {Parent = Frame, Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.SourceSans, TextSize = 13, TextColor3 = Colors.TextBright, TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(Text or "Atramenta.rip")})
    local Line = Create("Frame", {Parent = Frame, Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Accent(), BorderSizePixel = 0})
    local Scale = Create("UIScale", {Parent = Frame, Scale = 1})
    MakeDraggable(Frame, Frame)
    local Object = {Gui = Gui, Frame = Frame, Label = Label, Scale = Scale}
    function Object:SetVisibility(State) Frame.Visible = State == true end
    function Object:SetScale(Value) Scale.Scale = math.clamp((tonumber(Value) or 100) / 100, 0.5, 2) end
    function Object:SetText(Value) Label.Text = tostring(Value or "") end
    RegisterRenderer(function() Line.BackgroundColor3 = Accent() end)
    return Object
end

function Library:KeybindList()
    if self.KeybindListController then return self.KeybindListController end
    local Parent = ParentGui()
    local Gui = Create("ScreenGui", {Name = "AtramentaKeybinds", Parent = Parent, ResetOnSpawn = false, DisplayOrder = 101, ZIndexBehavior = Enum.ZIndexBehavior.Global, IgnoreGuiInset = false})
    self.Guis[#self.Guis + 1] = Gui
    local Frame = Create("Frame", {Parent = Gui, Position = UDim2.fromOffset(12, 42), Size = UDim2.fromOffset(180, 24), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Colors.Bg, BorderSizePixel = 0, Visible = false}, {Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1}), Create("UIPadding", {PaddingBottom = UDim.new(0, 5)})})
    local Header = Create("TextLabel", {Parent = Frame, Size = UDim2.new(1, 0, 0, 20), BackgroundColor3 = Colors.TitleBg, BorderSizePixel = 0, Text = "keybinds", TextColor3 = Colors.TextBright, Font = Enum.Font.SourceSans, TextSize = 13})
    local Holder = Create("Frame", {Parent = Frame, Position = UDim2.fromOffset(6, 22), Size = UDim2.new(1, -12, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, {Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})})
    local Scale = Create("UIScale", {Parent = Frame, Scale = 1})
    MakeDraggable(Frame, Header)
    local Object = {Gui = Gui, Frame = Frame, Holder = Holder, Scale = Scale, Rows = {}}
    function Object:SetVisibility(State) Frame.Visible = State == true end
    function Object:SetScale(Value) Scale.Scale = math.clamp((tonumber(Value) or 100) / 100, 0.5, 2) end
    function Object:Refresh()
        for _, Row in ipairs(Object.Rows) do if Row and Row.Parent then Row:Destroy() end end
        table.clear(Object.Rows)
        for _, BindData in ipairs(Library.Keybinds) do
            if not BindData.Destroyed and (BindData.Value == true or BindData.Mode == "Always") then
                local Row = Create("Frame", {Parent = Holder, Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1})
                Create("TextLabel", {Parent = Row, Size = UDim2.new(0.65, 0, 1, 0), BackgroundTransparency = 1, Text = BindData.Name, TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
                Create("TextLabel", {Parent = Row, Position = UDim2.new(0.65, 0, 0, 0), Size = UDim2.new(0.35, 0, 1, 0), BackgroundTransparency = 1, Text = KeyDisplay(BindData.Key), TextColor3 = Accent(), Font = Enum.Font.SourceSans, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right})
                Object.Rows[#Object.Rows + 1] = Row
            end
        end
    end
    self.KeybindListController = Object
    return Object
end

function Library:PlayerList(Data)
    Data = Data or {}
    if self.PlayerListController then return self.PlayerListController end
    local Parent = ParentGui()
    local Gui = Create("ScreenGui", {Name = "AtramentaPlayerList", Parent = Parent, ResetOnSpawn = false, DisplayOrder = 101, ZIndexBehavior = Enum.ZIndexBehavior.Global, IgnoreGuiInset = false})
    self.Guis[#self.Guis + 1] = Gui
    local Frame = Create("Frame", {Parent = Gui, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(260, 300), BackgroundColor3 = Colors.Bg, BorderSizePixel = 0, Visible = Data.Visible == true}, {Create("UICorner", {CornerRadius = UDim.new(0, 4)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1})})
    local Header = Create("Frame", {Parent = Frame, Size = UDim2.new(1, 0, 0, 22), BackgroundColor3 = Colors.TitleBg, BorderSizePixel = 0})
    Create("TextLabel", {Parent = Header, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = string.lower(tostring(Data.Brand or "players")), TextColor3 = Colors.TextBright, Font = Enum.Font.SourceSans, TextSize = 13})
    local List = Create("ScrollingFrame", {Parent = Frame, Position = UDim2.fromOffset(8, 30), Size = UDim2.new(1, -16, 1, -38), BackgroundTransparency = 1, BorderSizePixel = 0, CanvasSize = UDim2.fromOffset(0, 0), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2, ScrollBarImageColor3 = Colors.TextBind}, {Create("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})})
    local Scale = Create("UIScale", {Parent = Frame, Scale = math.clamp((tonumber(Data.Scale) or 100) / 100, 0.5, 2)})
    MakeDraggable(Frame, Header)
    local Object = {Gui = Gui, Frame = Frame, List = List, Scale = Scale, Rows = {}, Status = setmetatable({}, {__mode = "k"}), Data = Data}
    function Object:SetVisibility(State) Frame.Visible = State == true end
    function Object:SetScale(Value) Scale.Scale = math.clamp((tonumber(Value) or 100) / 100, 0.5, 2) end
    function Object:Refresh()
        for _, Row in ipairs(Object.Rows) do if Row and Row.Parent then Row:Destroy() end end
        table.clear(Object.Rows)
        local PlayersList = Players:GetPlayers()
        table.sort(PlayersList, function(A, B) return A.Name:lower() < B.Name:lower() end)
        for Index, Player in ipairs(PlayersList) do
            if Player ~= Players.LocalPlayer then
                local Row = Create("Frame", {Parent = List, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = Index})
                local Name = Create("TextLabel", {Parent = Row, Size = UDim2.new(0.62, 0, 1, 0), BackgroundTransparency = 1, Text = Player.Name, TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
                local StatusButton = Create("TextButton", {Parent = Row, Position = UDim2.new(0.62, 0, 0, 0), Size = UDim2.new(0.38, 0, 1, 0), BackgroundTransparency = 1, Text = Object.Status[Player] or "None", TextColor3 = Colors.TextBind, Font = Enum.Font.SourceSans, TextSize = 12, AutoButtonColor = false})
                Bind(StatusButton.MouseButton1Click:Connect(function()
                    local Current = Object.Status[Player] or "None"
                    local Next = Current == "None" and "Whitelist" or Current == "Whitelist" and "Enemy" or "None"
                    Object.Status[Player] = Next
                    StatusButton.Text = Next
                    StatusButton.TextColor3 = Next == "Enemy" and Accent() or Colors.TextBind
                    if type(Data.StatusChanged) == "function" then Call(Data.StatusChanged, Player, Next) end
                end))
                Object.Rows[#Object.Rows + 1] = Row
            end
        end
    end
    Bind(Players.PlayerAdded:Connect(function() task.defer(function() Object:Refresh() end) end))
    Bind(Players.PlayerRemoving:Connect(function() task.defer(function() Object:Refresh() end) end))
    Object:Refresh()
    self.PlayerListController = Object
    return Object
end

function Library:SetNotificationLayout(Position, Scale)
    self.NotificationPosition = tostring(Position or self.NotificationPosition or "Top Right")
    self.NotificationScaleValue = math.clamp(tonumber(Scale) or self.NotificationScaleValue or 1, 0.5, 2)
    local Holder = self.NotificationHolder
    if not Holder or not Holder.Parent then return end
    local Map = {
        ["Top Left"] = {Vector2.new(0, 0), UDim2.fromOffset(12, 12), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top},
        ["Top Center"] = {Vector2.new(0.5, 0), UDim2.new(0.5, 0, 0, 12), Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top},
        ["Top Right"] = {Vector2.new(1, 0), UDim2.new(1, -12, 0, 12), Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Top},
        ["Middle Left"] = {Vector2.new(0, 0.5), UDim2.new(0, 12, 0.5, 0), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center},
        ["Middle Center"] = {Vector2.new(0.5, 0.5), UDim2.fromScale(0.5, 0.5), Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Center},
        ["Middle Right"] = {Vector2.new(1, 0.5), UDim2.new(1, -12, 0.5, 0), Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center},
        ["Bottom Left"] = {Vector2.new(0, 1), UDim2.new(0, 12, 1, -12), Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Bottom},
        ["Bottom Center"] = {Vector2.new(0.5, 1), UDim2.new(0.5, 0, 1, -12), Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Bottom},
        ["Bottom Right"] = {Vector2.new(1, 1), UDim2.new(1, -12, 1, -12), Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Bottom}
    }
    local Data = Map[self.NotificationPosition] or Map["Top Right"]
    Holder.AnchorPoint = Data[1]
    Holder.Position = Data[2]
    local Layout = Holder:FindFirstChildOfClass("UIListLayout")
    if Layout then Layout.HorizontalAlignment = Data[3] Layout.VerticalAlignment = Data[4] end
    if not self.NotificationScale or not self.NotificationScale.Parent then self.NotificationScale = Create("UIScale", {Parent = Holder, Scale = self.NotificationScaleValue}) else self.NotificationScale.Scale = self.NotificationScaleValue end
end

function Library:Notification(Data)
    if type(Data) == "string" then Data = {Description = Data} end
    Data = Data or {}
    local Parent = ParentGui()
    local Gui = self.NotificationGui
    if not Gui or not Gui.Parent then
        Gui = Create("ScreenGui", {Name = "AtramentaNotifications", Parent = Parent, ResetOnSpawn = false, DisplayOrder = 200, ZIndexBehavior = Enum.ZIndexBehavior.Global, IgnoreGuiInset = false})
        self.Guis[#self.Guis + 1] = Gui
        self.NotificationGui = Gui
        self.NotificationHolder = Create("Frame", {Parent = Gui, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -12, 0, 12), Size = UDim2.fromOffset(280, 500), BackgroundTransparency = 1}, {Create("UIListLayout", {Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Top, SortOrder = Enum.SortOrder.LayoutOrder})})
        self:SetNotificationLayout(self.NotificationPosition or "Top Right", self.NotificationScaleValue or 1)
    end
    local Frame = Create("Frame", {Parent = self.NotificationHolder, Size = UDim2.fromOffset(270, 42), BackgroundColor3 = Colors.Bg, BackgroundTransparency = 0.05, BorderSizePixel = 0}, {Create("UICorner", {CornerRadius = UDim.new(0, 3)}), Create("UIStroke", {Color = Colors.SectionBorder, Thickness = 1})})
    Create("Frame", {Parent = Frame, Size = UDim2.fromOffset(2, 32), Position = UDim2.fromOffset(4, 5), BackgroundColor3 = Accent(), BorderSizePixel = 0})
    Create("TextLabel", {Parent = Frame, Position = UDim2.fromOffset(12, 3), Size = UDim2.new(1, -18, 0, 14), BackgroundTransparency = 1, Text = tostring(Data.Title or "Atramenta.rip"), TextColor3 = Colors.TextBright, Font = Enum.Font.SourceSansBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left})
    Create("TextLabel", {Parent = Frame, Position = UDim2.fromOffset(12, 18), Size = UDim2.new(1, -18, 0, 18), BackgroundTransparency = 1, Text = tostring(Data.Description or ""), TextColor3 = Colors.Text, Font = Enum.Font.SourceSans, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
    task.delay(math.max(tonumber(Data.Duration) or 3, 0.2), function() if Frame and Frame.Parent then Frame:Destroy() end end)
    return Frame
end

Bind(UserInputService.InputBegan:Connect(function(Input, Processed)
    if Library.Capture then
        local Capture = Library.Capture
        if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode.Escape then Capture.Key = nil else Capture.Key = Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode or Input.UserInputType end
        Library.Capture = nil
        Capture.Render()
        RefreshKeybindList()
        return
    end
    if not Processed and Library.ActiveWindow and InputMatches(Input, Library.MenuKeybind) then Library.ActiveWindow:Toggle() return end
    if Processed then return end
    for _, BindData in ipairs(Library.Keybinds) do if InputMatches(Input, BindData.Key) then FireKeybind(BindData, true) end end
end))

Bind(UserInputService.InputEnded:Connect(function(Input)
    for _, BindData in ipairs(Library.Keybinds) do if BindData.Mode == "Hold" and InputMatches(Input, BindData.Key) then FireKeybind(BindData, false) end end
end))

function Library.Unload(...)
    for _, BindData in ipairs(Library.Keybinds) do BindData.Destroyed = true end
    table.clear(Library.Keybinds)
    for Index = #Library.Connections, 1, -1 do local Connection = Library.Connections[Index] if Connection then Call(function() Connection:Disconnect() end) end Library.Connections[Index] = nil end
    for Index = #Library.Guis, 1, -1 do local Gui = Library.Guis[Index] if Gui and Gui.Parent then Call(function() Gui:Destroy() end) end Library.Guis[Index] = nil end
    Library.ActiveWindow = nil
    Library.PlayerListController = nil
    Library.KeybindListController = nil
    Library.NotificationGui = nil
    Library.NotificationHolder = nil
    Library.NotificationScale = nil
    Library.Holder = nil
    table.clear(Library.Renderers)
end
Library.Destroy = Library.Unload

function Library:GetFlag(Name)
    return self.Flags[Name]
end

function Library:SetFlag(Name, Value)
    local Setter = self.Setters[Name]
    if type(Setter) == "function" then
        local Success = Call(Setter, Value)
        return Success == true
    end
    self.Flags[Name] = Value
    UpdateAll()
    return true
end

function Library:SetVisible(State)
    if self.ActiveWindow then self.ActiveWindow:SetVisible(State) end
end

function Library:Toggle()
    if self.ActiveWindow then self.ActiveWindow:Toggle() end
end

Library.window = Library.Window
Library.setvisible = Library.SetVisible
Library.toggle = Library.Toggle
Library.getflag = Library.GetFlag
Library.setflag = Library.SetFlag
Library.notification = Library.Notification
Library.setnotificationlayout = Library.SetNotificationLayout
Library.watermark = Library.Watermark
Library.keybindlist = Library.KeybindList
Library.playerlist = Library.PlayerList
Library.getconfig = Library.GetConfig
Library.loadconfig = Library.LoadConfig
Library.saveconfig = Library.SaveConfig
Library.loadconfigfile = Library.LoadConfigFile
Library.deleteconfig = Library.DeleteConfig
Library.refreshconfigslist = Library.RefreshConfigsList
Library.destroy = Library.Destroy

return Library
