-- Atramenta compatibility layer for Matcha UI Binding.
-- Designed to keep the public API used by Nightfall while avoiding Roblox GUI APIs
-- that Matcha does not expose (Instance.new, GetPropertyChangedSignal, task.defer, etc.).

local Library = {
    Flags = {},
    Setters = {},
    Windows = {},
    RegisteredTabs = {},
    ActiveWindow = nil,
    MenuKeybind = nil,
    Theme = {
        Accent = Color3.fromRGB(122, 134, 255)
    }
}

local function SafeCall(Function, ...)
    if type(Function) ~= "function" then
        return false, nil
    end

    local Args = {...}
    local Success, ResultA, ResultB, ResultC = pcall(function()
        return Function(table.unpack(Args))
    end)

    if not Success then
        return false, ResultA
    end

    return true, ResultA, ResultB, ResultC
end

local function Notify(Message, Title, Duration)
    if type(notify) == "function" then
        SafeCall(notify, tostring(Message or ""), tostring(Title or "Atramenta"), tonumber(Duration) or 3)
    elseif type(print) == "function" then
        print("[Atramenta] " .. tostring(Message or ""))
    end
end

local function GetGlobalEnvironment()
    if type(getfenv) == "function" then
        local Success, Environment = pcall(getfenv, 0)
        if Success and type(Environment) == "table" then
            return Environment
        end
    end

    if type(_G) == "table" then
        return _G
    end

    return nil
end

local function SanitizeId(Value)
    local Text = tostring(Value or "control")
    Text = Text:gsub("[^%w_%-]", "_")
    Text = Text:gsub("_+", "_")
    if Text == "" then
        Text = "control"
    end
    return string.lower(Text)
end

local NextId = 0
local function MakeId(Prefix, Flag)
    NextId = NextId + 1
    return "atr_" .. SanitizeId(Prefix) .. "_" .. SanitizeId(Flag) .. "_" .. tostring(NextId)
end

local function SideName(Value)
    if Value == 2 or tostring(Value):lower() == "right" then
        return "Right"
    end
    return "Left"
end

local function NormalizeKeyMode(Value)
    local Mode = string.lower(tostring(Value or "toggle"))
    if Mode == "hold" or Mode == "always" or Mode == "click" then
        return Mode
    end
    return "toggle"
end

local function NormalizeKey(Value)
    if Value == nil then
        return 0
    end
    if type(Value) == "number" then
        return Value
    end
    if typeof(Value) == "EnumItem" then
        return Value
    end
    return 0
end

local function DecimalPlaces(Step)
    Step = tonumber(Step) or 1
    if Step >= 1 then
        return 0
    end

    local Places = 0
    local Test = Step
    while Places < 4 and math.abs(Test - math.floor(Test + 0.5)) > 0.000001 do
        Test = Test * 10
        Places = Places + 1
    end
    return Places
end

local function NativeGet(Id)
    if type(UI) == "table" and type(UI.GetValue) == "function" then
        local Success, Value = SafeCall(UI.GetValue, Id)
        if Success then
            return Value
        end
    end
    return nil
end

local function NativeSet(Id, Value)
    if type(UI) == "table" and type(UI.SetValue) == "function" then
        SafeCall(UI.SetValue, Id, Value)
    end
end

local BaseControl = {}
BaseControl.__index = BaseControl

function BaseControl:Get()
    return self.Value
end

function BaseControl:Set(Value, Silent)
    self.Value = Value
    if self.Flag then
        Library.Flags[self.Flag] = Value
    end
    if self.Id then
        NativeSet(self.Id, Value)
    end
    if not Silent and type(self.Callback) == "function" then
        SafeCall(self.Callback, Value)
    end
    return self.Value
end

function BaseControl:SetValue(Value)
    return self:Set(Value)
end

function BaseControl:GetValue()
    return self:Get()
end

local ToggleControl = setmetatable({}, BaseControl)
ToggleControl.__index = ToggleControl

function ToggleControl:Get()
    local Value = NativeGet(self.Id)
    if type(Value) == "boolean" then
        self.Value = Value
        Library.Flags[self.Flag] = Value
    end
    return self.Value == true
end

function ToggleControl:Set(Value, Silent)
    Value = Value == true
    local Changed = self.Value ~= Value
    self.Value = Value
    Library.Flags[self.Flag] = Value
    NativeSet(self.Id, Value)

    if Changed and not Silent and type(self.Callback) == "function" then
        SafeCall(self.Callback, Value)
    end
    return Value
end

function ToggleControl:Keybind(Data)
    Data = Data or {}

    local Object = {
        Type = "Keybind",
        Id = MakeId("keybind", Data.Flag or Data.Name or self.Flag),
        Flag = tostring(Data.Flag or Data.Name or (self.Flag .. " Keybind")),
        Name = tostring(Data.Name or self.Name or "Keybind"),
        Key = NormalizeKey(Data.Default),
        Mode = NormalizeKeyMode(Data.Mode),
        Native = nil,
        ParentToggle = self
    }

    function Object:Get()
        if self.Native and type(self.Native.IsEnabled) == "function" then
            local Success, Value = SafeCall(self.Native.IsEnabled, self.Native)
            if Success then
                Library.Flags[self.Flag] = Value == true
                return Value == true
            end
        end
        return Library.Flags[self.Flag] == true
    end

    function Object:Set(Value)
        Library.Flags[self.Flag] = Value == true
        return Library.Flags[self.Flag]
    end

    function Object:GetKey()
        if self.Native and type(self.Native.GetKey) == "function" then
            local Success, Value = SafeCall(self.Native.GetKey, self.Native)
            if Success then
                self.Key = Value
            end
        end
        return self.Key
    end

    function Object:SetKey(Value)
        self.Key = NormalizeKey(Value)
        if self.Native and type(self.Native.SetKey) == "function" then
            SafeCall(self.Native.SetKey, self.Native, self.Key)
        end
    end

    function Object:GetType()
        if self.Native and type(self.Native.GetType) == "function" then
            local Success, Value = SafeCall(self.Native.GetType, self.Native)
            if Success and type(Value) == "string" then
                self.Mode = Value
            end
        end
        return self.Mode
    end

    function Object:SetType(Value)
        self.Mode = NormalizeKeyMode(Value)
        if self.Native and type(self.Native.SetType) == "function" then
            SafeCall(self.Native.SetType, self.Native, self.Mode)
        end
    end

    function Object:AddToHotkey(Label)
        self.HotkeyLabel = tostring(Label or self.Name)
        self.ShowHotkey = true
    end

    function Object:RemoveFromHotkey()
        self.ShowHotkey = false
    end

    Library.Flags[Object.Flag] = false
    self.KeybindObject = Object
    return Object
end

function ToggleControl:Colorpicker(Data)
    Data = Data or {}

    local Default = Data.Default
    local Color = Color3.new(1, 1, 1)
    local Alpha = 1

    if typeof(Default) == "Color3" then
        Color = Default
    elseif type(Default) == "table" and typeof(Default.Color) == "Color3" then
        Color = Default.Color
        Alpha = 1 - math.clamp(tonumber(Default.Transparency) or 0, 0, 1)
    end

    local Object = {
        Type = "Colorpicker",
        Id = MakeId("color", Data.Flag or Data.Name or self.Flag),
        Flag = tostring(Data.Flag or Data.Name or (self.Flag .. " Color")),
        Color = Color,
        Alpha = Alpha,
        Callback = Data.Callback
    }

    function Object:Get()
        return self.Color
    end

    function Object:Set(NewColor, NewAlpha, Silent)
        if typeof(NewColor) ~= "Color3" then
            return self.Color
        end
        self.Color = NewColor
        if NewAlpha ~= nil then
            self.Alpha = math.clamp(tonumber(NewAlpha) or 1, 0, 1)
        end
        Library.Flags[self.Flag] = self.Color
        if not Silent and type(self.Callback) == "function" then
            SafeCall(self.Callback, self.Color, self.Alpha)
        end
        return self.Color
    end

    Library.Flags[Object.Flag] = Color
    self.ColorpickerObject = Object
    return Object
end

function ToggleControl:Render(NativeSection)
    local Object = self
    local NativeToggle = NativeSection:Toggle(self.Id, self.Name, self.Value == true, function(State)
        State = State == true
        if Object.Value ~= State then
            Object.Value = State
            Library.Flags[Object.Flag] = State
            if type(Object.Callback) == "function" then
                SafeCall(Object.Callback, State)
            end
        end
    end)
    self.Native = NativeToggle

    if self.KeybindObject then
        local Keybind = self.KeybindObject
        local NativeKeybind = NativeSection:Keybind(Keybind.Id, Keybind.Key, Keybind.Mode)
        Keybind.Native = NativeKeybind

        if Keybind.ShowHotkey and NativeKeybind and type(NativeKeybind.AddToHotkey) == "function" then
            SafeCall(NativeKeybind.AddToHotkey, NativeKeybind, Keybind.HotkeyLabel or Keybind.Name, self.Id)
        end
    end

    if self.ColorpickerObject then
        local Picker = self.ColorpickerObject
        local Color = Picker.Color
        local NativePicker = NativeSection:ColorPicker(
            Picker.Id,
            Color.R,
            Color.G,
            Color.B,
            Picker.Alpha,
            function(NewColor, NewAlpha)
                if typeof(NewColor) == "Color3" then
                    Picker.Color = NewColor
                    Picker.Alpha = tonumber(NewAlpha) or Picker.Alpha
                    Library.Flags[Picker.Flag] = NewColor
                    if type(Picker.Callback) == "function" then
                        SafeCall(Picker.Callback, NewColor, Picker.Alpha)
                    end
                end
            end
        )
        Picker.Native = NativePicker
    end
end

local SliderControl = setmetatable({}, BaseControl)
SliderControl.__index = SliderControl

function SliderControl:Get()
    local Value = NativeGet(self.Id)
    if type(Value) == "number" then
        self.Value = Value
        Library.Flags[self.Flag] = Value
    end
    return self.Value
end

function SliderControl:Set(Value, Silent)
    Value = tonumber(Value) or self.Min
    Value = math.clamp(Value, self.Min, self.Max)
    local Changed = self.Value ~= Value
    self.Value = Value
    Library.Flags[self.Flag] = Value
    NativeSet(self.Id, Value)
    if Changed and not Silent and type(self.Callback) == "function" then
        SafeCall(self.Callback, Value)
    end
    return Value
end

function SliderControl:Render(NativeSection)
    local Object = self
    local Label = self.Name
    local Suffix = tostring(self.Suffix or "")

    if self.IsFloat then
        local Places = DecimalPlaces(self.Step)
        local Format = "%." .. tostring(Places) .. "f" .. Suffix
        self.Native = NativeSection:SliderFloat(
            self.Id,
            Label,
            self.Min,
            self.Max,
            self.Value,
            Format,
            function(Value)
                if type(Value) == "number" and Object.Value ~= Value then
                    Object.Value = Value
                    Library.Flags[Object.Flag] = Value
                    if type(Object.Callback) == "function" then
                        SafeCall(Object.Callback, Value)
                    end
                end
            end
        )
    else
        self.Native = NativeSection:SliderInt(
            self.Id,
            Label,
            self.Min,
            self.Max,
            self.Value,
            function(Value)
                if type(Value) == "number" and Object.Value ~= Value then
                    Object.Value = Value
                    Library.Flags[Object.Flag] = Value
                    if type(Object.Callback) == "function" then
                        SafeCall(Object.Callback, Value)
                    end
                end
            end
        )
    end
end

local LabelControl = setmetatable({}, BaseControl)
LabelControl.__index = LabelControl

function LabelControl:Set(Value)
    self.Value = tostring(Value or "")
    return self.Value
end

function LabelControl:Render(NativeSection)
    NativeSection:Text(tostring(self.Value or ""))
end

local ButtonControl = setmetatable({}, BaseControl)
ButtonControl.__index = ButtonControl

function ButtonControl:Render(NativeSection)
    local Callback = self.Callback
    NativeSection:Button(self.Name, function()
        if type(Callback) == "function" then
            SafeCall(Callback)
        end
    end)
end

local TextboxControl = setmetatable({}, BaseControl)
TextboxControl.__index = TextboxControl

function TextboxControl:Get()
    local Value = NativeGet(self.Id)
    if type(Value) == "string" then
        self.Value = Value
        Library.Flags[self.Flag] = Value
    end
    return self.Value
end

function TextboxControl:Set(Value, Silent)
    Value = tostring(Value or "")
    local Changed = self.Value ~= Value
    self.Value = Value
    Library.Flags[self.Flag] = Value
    NativeSet(self.Id, Value)
    if Changed and not Silent and type(self.Callback) == "function" then
        SafeCall(self.Callback, Value)
    end
    return Value
end

function TextboxControl:Render(NativeSection)
    local Object = self
    self.Native = NativeSection:InputText(self.Id, self.Name, self.Value, function(Value)
        Value = tostring(Value or "")
        if Object.Value ~= Value then
            Object.Value = Value
            Library.Flags[Object.Flag] = Value
            if type(Object.Callback) == "function" then
                SafeCall(Object.Callback, Value)
            end
        end
    end)
end

local DropdownControl = setmetatable({}, BaseControl)
DropdownControl.__index = DropdownControl

function DropdownControl:Get()
    local Index = NativeGet(self.Id)
    if type(Index) == "number" then
        local Item = self.Items[Index + 1]
        if Item ~= nil then
            self.Value = Item
            self.Index = Index
            Library.Flags[self.Flag] = Item
        end
    end
    return self.Value
end

function DropdownControl:Set(Value, Silent)
    local Index
    local Item

    if type(Value) == "number" then
        Index = math.clamp(math.floor(Value), 0, math.max(#self.Items - 1, 0))
        Item = self.Items[Index + 1]
    else
        for ItemIndex, Candidate in ipairs(self.Items) do
            if tostring(Candidate) == tostring(Value) then
                Index = ItemIndex - 1
                Item = Candidate
                break
            end
        end
    end

    if Index == nil then
        return self.Value
    end

    local Changed = self.Index ~= Index
    self.Index = Index
    self.Value = Item
    Library.Flags[self.Flag] = Item
    NativeSet(self.Id, Index)

    if Changed and not Silent and type(self.Callback) == "function" then
        SafeCall(self.Callback, Item)
    end
    return Item
end

function DropdownControl:SetItems(Items)
    if type(Items) == "table" then
        self.Items = Items
        if #self.Items > 0 and self.Value == nil then
            self.Index = 0
            self.Value = self.Items[1]
        end
    end
end

function DropdownControl:Render(NativeSection)
    local Object = self
    self.Native = NativeSection:Combo(self.Id, self.Name, self.Items, self.Index or 0, function(Index, Text)
        if type(Index) == "number" then
            Object.Index = Index
            Object.Value = Text or Object.Items[Index + 1]
            Library.Flags[Object.Flag] = Object.Value
            if type(Object.Callback) == "function" then
                SafeCall(Object.Callback, Object.Value)
            end
        end
    end)
end

local RangeControl = setmetatable({}, BaseControl)
RangeControl.__index = RangeControl

function RangeControl:Get()
    return {self.Low, self.High}
end

function RangeControl:Set(A, B, Silent)
    if type(A) == "table" then
        B = A[2] or A.Max or A.Maximum
        A = A[1] or A.Min or A.Minimum
    end
    A = math.clamp(tonumber(A) or self.Low, self.Min, self.Max)
    B = math.clamp(tonumber(B) or self.High, self.Min, self.Max)
    if A > B then
        A, B = B, A
    end
    self.Low, self.High = A, B
    Library.Flags[self.Flag] = {A, B}
    NativeSet(self.LowId, A)
    NativeSet(self.HighId, B)
    if not Silent and type(self.Callback) == "function" then
        SafeCall(self.Callback, A, B)
    end
    return {A, B}
end

function RangeControl:Render(NativeSection)
    local Object = self
    local Places = DecimalPlaces(self.Step)
    local Format = "%." .. tostring(Places) .. "f" .. tostring(self.Suffix or "")

    NativeSection:SliderFloat(self.LowId, self.Name .. " Min", self.Min, self.Max, self.Low, Format, function(Value)
        if type(Value) == "number" then
            Object:Set(Value, Object.High)
        end
    end)

    NativeSection:SliderFloat(self.HighId, self.Name .. " Max", self.Min, self.Max, self.High, Format, function(Value)
        if type(Value) == "number" then
            Object:Set(Object.Low, Value)
        end
    end)
end

local SectionMethods = {}
SectionMethods.__index = SectionMethods

function SectionMethods:AddControl(Control)
    self.Controls[#self.Controls + 1] = Control
    return Control
end

function SectionMethods:Toggle(Data)
    Data = Data or {}
    local Flag = tostring(Data.Flag or Data.Name or "toggle")
    local Default = Data.Default == true
    if type(Library.Flags[Flag]) == "boolean" then
        Default = Library.Flags[Flag]
    end

    local Object = setmetatable({
        Type = "Toggle",
        Id = MakeId(self.Page.Name, Flag),
        Flag = Flag,
        Name = tostring(Data.Name or Flag),
        Value = Default,
        Callback = Data.Callback,
        Native = nil
    }, ToggleControl)

    Library.Flags[Flag] = Default
    Library.Setters[Flag] = function(Value)
        return Object:Set(Value)
    end

    return self:AddControl(Object)
end

function SectionMethods:Slider(Data)
    Data = Data or {}
    local Flag = tostring(Data.Flag or Data.Name or "slider")
    local Minimum = tonumber(Data.Min) or 0
    local Maximum = tonumber(Data.Max) or 100
    local Step = tonumber(Data.Step) or 1
    local Default = math.clamp(tonumber(Data.Default) or Minimum, Minimum, Maximum)
    if type(Library.Flags[Flag]) == "number" then
        Default = math.clamp(Library.Flags[Flag], Minimum, Maximum)
    end

    local IsFloat = Step < 1 or Minimum % 1 ~= 0 or Maximum % 1 ~= 0 or Default % 1 ~= 0
    local Object = setmetatable({
        Type = "Slider",
        Id = MakeId(self.Page.Name, Flag),
        Flag = Flag,
        Name = tostring(Data.Name or Flag),
        Min = Minimum,
        Max = Maximum,
        Step = Step,
        Value = Default,
        Suffix = Data.Suffix,
        IsFloat = IsFloat,
        Callback = Data.Callback,
        Native = nil
    }, SliderControl)

    Library.Flags[Flag] = Default
    Library.Setters[Flag] = function(Value)
        return Object:Set(Value)
    end

    return self:AddControl(Object)
end

function SectionMethods:RangeSlider(Data)
    Data = Data or {}
    local Flag = tostring(Data.Flag or Data.Name or "range")
    local Minimum = tonumber(Data.Min) or 0
    local Maximum = tonumber(Data.Max) or 100
    local Default = type(Data.Default) == "table" and Data.Default or {Minimum, Maximum}
    local Low = math.clamp(tonumber(Default[1]) or Minimum, Minimum, Maximum)
    local High = math.clamp(tonumber(Default[2]) or Maximum, Minimum, Maximum)
    if Low > High then
        Low, High = High, Low
    end

    local Object = setmetatable({
        Type = "RangeSlider",
        Flag = Flag,
        Name = tostring(Data.Name or Flag),
        Min = Minimum,
        Max = Maximum,
        Step = tonumber(Data.Step) or 1,
        Low = Low,
        High = High,
        Suffix = Data.Suffix,
        Callback = Data.Callback,
        LowId = MakeId(self.Page.Name, Flag .. "_min"),
        HighId = MakeId(self.Page.Name, Flag .. "_max")
    }, RangeControl)

    Library.Flags[Flag] = {Low, High}
    Library.Setters[Flag] = function(Value)
        return Object:Set(Value)
    end

    return self:AddControl(Object)
end

function SectionMethods:Dropdown(Data)
    Data = Data or {}
    local Flag = tostring(Data.Flag or Data.Name or "dropdown")
    local Items = type(Data.Items) == "table" and Data.Items or {}
    local Default = Data.Default
    local Index = 0

    if Default == nil then
        Default = Items[1]
    end

    for ItemIndex, Item in ipairs(Items) do
        if tostring(Item) == tostring(Default) then
            Index = ItemIndex - 1
            Default = Item
            break
        end
    end

    local Object = setmetatable({
        Type = "Dropdown",
        Id = MakeId(self.Page.Name, Flag),
        Flag = Flag,
        Name = tostring(Data.Name or Flag),
        Items = Items,
        Value = Default,
        Index = Index,
        Callback = Data.Callback,
        Native = nil
    }, DropdownControl)

    Library.Flags[Flag] = Default
    Library.Setters[Flag] = function(Value)
        return Object:Set(Value)
    end

    return self:AddControl(Object)
end

function SectionMethods:MultiDropdown(Data)
    -- Native Matcha UI Binding has no multi-select combo. Keep API compatibility
    -- by rendering one toggle per item and exposing a table of selected values.
    Data = Data or {}
    local Flag = tostring(Data.Flag or Data.Name or "multi")
    local Items = type(Data.Items) == "table" and Data.Items or {}
    local Selected = type(Data.Default) == "table" and Data.Default or {}
    local Object = {
        Type = "MultiDropdown",
        Flag = Flag,
        Name = tostring(Data.Name or Flag),
        Items = Items,
        Selected = {},
        Callback = Data.Callback,
        ToggleIds = {}
    }

    for _, Item in ipairs(Selected) do
        Object.Selected[tostring(Item)] = true
    end

    function Object:Get()
        local Result = {}
        for _, Item in ipairs(self.Items) do
            if self.Selected[tostring(Item)] then
                Result[#Result + 1] = Item
            end
        end
        return Result
    end

    function Object:Set(Values, Silent)
        self.Selected = {}
        if type(Values) == "table" then
            for _, Item in ipairs(Values) do
                self.Selected[tostring(Item)] = true
            end
        end
        Library.Flags[self.Flag] = self:Get()
        if not Silent and type(self.Callback) == "function" then
            SafeCall(self.Callback, Library.Flags[self.Flag])
        end
        return Library.Flags[self.Flag]
    end

    function Object:Render(NativeSection)
        NativeSection:Text(self.Name)
        for Index, Item in ipairs(self.Items) do
            local Key = tostring(Item)
            local Id = self.ToggleIds[Index]
            if not Id then
                Id = MakeId(self.Flag, Key)
                self.ToggleIds[Index] = Id
            end
            NativeSection:Toggle(Id, Key, self.Selected[Key] == true, function(State)
                self.Selected[Key] = State == true
                Library.Flags[self.Flag] = self:Get()
                if type(self.Callback) == "function" then
                    SafeCall(self.Callback, Library.Flags[self.Flag])
                end
            end)
        end
    end

    Library.Flags[Flag] = Object:Get()
    Library.Setters[Flag] = function(Value)
        return Object:Set(Value)
    end
    return self:AddControl(Object)
end

function SectionMethods:Textbox(Data)
    Data = Data or {}
    local Flag = tostring(Data.Flag or Data.Name or "textbox")
    local Default = tostring(Data.Default or "")
    if type(Library.Flags[Flag]) == "string" then
        Default = Library.Flags[Flag]
    end

    local Object = setmetatable({
        Type = "Textbox",
        Id = MakeId(self.Page.Name, Flag),
        Flag = Flag,
        Name = tostring(Data.Name or Flag),
        Value = Default,
        Callback = Data.Callback,
        Native = nil
    }, TextboxControl)

    Library.Flags[Flag] = Default
    Library.Setters[Flag] = function(Value)
        return Object:Set(Value)
    end

    return self:AddControl(Object)
end

function SectionMethods:Label(Data)
    if type(Data) ~= "table" then
        Data = {Name = tostring(Data or "")}
    end

    local Object = setmetatable({
        Type = "Label",
        Value = tostring(Data.Name or "")
    }, LabelControl)

    return self:AddControl(Object)
end

function SectionMethods:Button(Data, Callback)
    if type(Data) == "string" then
        Data = {Name = Data, Callback = Callback}
    end
    Data = Data or {}

    local Object = setmetatable({
        Type = "Button",
        Name = tostring(Data.Name or "Button"),
        Callback = Data.Callback
    }, ButtonControl)

    return self:AddControl(Object)
end

function SectionMethods:Keybind(Data)
    -- Matcha requires a keybind to immediately follow a toggle. For standalone
    -- keybind requests we create a visible compatibility toggle.
    Data = Data or {}
    local Toggle = self:Toggle({
        Name = tostring(Data.Name or "Keybind"),
        Flag = tostring(Data.EnabledFlag or (Data.Flag or Data.Name or "Keybind") .. " Enabled"),
        Default = false
    })
    return Toggle:Keybind(Data)
end

function SectionMethods:Text(Data)
    return self:Label(type(Data) == "table" and Data or {Name = tostring(Data or "")})
end

function SectionMethods:Info(Text)
    return self:Label({Name = tostring(Text or "")})
end

local PageMethods = {}
PageMethods.__index = PageMethods

function PageMethods:Section(Data)
    Data = Data or {}
    local Section = setmetatable({
        Page = self,
        Name = tostring(Data.Name or "Section"),
        Side = SideName(Data.Side),
        Controls = {}
    }, SectionMethods)

    self.Sections[#self.Sections + 1] = Section
    return Section
end

function PageMethods:Render(Tab)
    for _, Section in ipairs(self.Sections) do
        local Success, NativeSection = SafeCall(Tab.Section, Tab, Section.Name, Section.Side)
        if Success and NativeSection then
            for _, Control in ipairs(Section.Controls) do
                if Control and type(Control.Render) == "function" then
                    SafeCall(Control.Render, Control, NativeSection)
                end
            end
        end
    end
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods

function WindowMethods:Page(Data)
    Data = Data or {}
    local Name = tostring(Data.Name or ("Page " .. tostring(#self.Pages + 1)))
    local Page = setmetatable({
        Window = self,
        Name = Name,
        Sections = {},
        Removed = false
    }, PageMethods)

    self.Pages[#self.Pages + 1] = Page

    local TabName = self.Name
    if Name ~= "" then
        TabName = self.Name .. " - " .. Name
    end
    Page.TabName = TabName

    if type(UI) == "table" and type(UI.AddTab) == "function" then
        UI.AddTab(TabName, function(Tab)
            if not Page.Removed then
                Page:Render(Tab)
            end
        end)
        Library.RegisteredTabs[TabName] = true
    else
        Notify("Matcha UI Binding global 'UI' is unavailable", "Atramenta", 5)
    end

    return Page
end

function WindowMethods:Destroy()
    for _, Page in ipairs(self.Pages) do
        Page.Removed = true
        if Page.TabName and Library.RegisteredTabs[Page.TabName] and type(UI) == "table" and type(UI.RemoveTab) == "function" then
            SafeCall(UI.RemoveTab, Page.TabName)
            Library.RegisteredTabs[Page.TabName] = nil
        end
    end
    self.Destroyed = true
    if Library.ActiveWindow == self then
        Library.ActiveWindow = nil
    end
end

function WindowMethods:SetVisible(State)
    self.Visible = State == true
end

function WindowMethods:Toggle()
    self.Visible = not self.Visible
end

function WindowMethods:IsVisible()
    return self.Visible ~= false
end

function Library:Window(Data)
    Data = Data or {}

    if self.ActiveWindow and type(self.ActiveWindow.Destroy) == "function" then
        self.ActiveWindow:Destroy()
    end

    local Window = setmetatable({
        Library = self,
        Name = tostring(Data.Name or "Atramenta"),
        Pages = {},
        Visible = true,
        Destroyed = false
    }, WindowMethods)

    self.ActiveWindow = Window
    self.Windows[#self.Windows + 1] = Window
    return Window
end

function Library:ChangeTheme(Name, Color)
    if tostring(Name):lower() == "accent" and typeof(Color) == "Color3" then
        self.Theme.Accent = Color
    end
    -- Matcha owns the native overlay theme, so this is intentionally metadata-only.
    return true
end

function Library:ApplyThemePreset(Preset)
    if type(Preset) == "table" and typeof(Preset.Accent) == "Color3" then
        self.Theme.Accent = Preset.Accent
    end
    return true
end

function Library:GetFlag(Name)
    return self.Flags[tostring(Name)]
end

function Library:SetFlag(Name, Value)
    Name = tostring(Name)
    local Setter = self.Setters[Name]
    if type(Setter) == "function" then
        return Setter(Value)
    end
    self.Flags[Name] = Value
    return true
end

function Library:ThemePanel()
    Notify("Theme is controlled by Matcha's native menu.", "Nightfall", 3)
    return nil
end

function Library:ConfigurationPanel()
    Notify("Use script flags or Matcha's native UI values for configuration.", "Nightfall", 3)
    return nil
end

function Library:KeybindList()
    Notify("Matcha keybinds use the native hotkey overlay.", "Nightfall", 3)
    return nil
end

function Library:Notification(Message, Duration, Title)
    Notify(Message, Title or "Nightfall", Duration or 3)
end

function Library:SetVisible(State)
    if self.ActiveWindow and type(self.ActiveWindow.SetVisible) == "function" then
        self.ActiveWindow:SetVisible(State)
    end
end

function Library:Toggle()
    if self.ActiveWindow and type(self.ActiveWindow.Toggle) == "function" then
        self.ActiveWindow:Toggle()
    end
end

function Library:Unload()
    for TabName in pairs(self.RegisteredTabs) do
        if type(UI) == "table" and type(UI.RemoveTab) == "function" then
            SafeCall(UI.RemoveTab, TabName)
        end
        self.RegisteredTabs[TabName] = nil
    end

    for _, Window in ipairs(self.Windows) do
        Window.Destroyed = true
        for _, Page in ipairs(Window.Pages or {}) do
            Page.Removed = true
        end
    end

    self.ActiveWindow = nil
end

Library.Destroy = Library.Unload
Library.window = Library.Window
Library.getflag = Library.GetFlag
Library.setflag = Library.SetFlag
Library.toggle = Library.Toggle
Library.setvisible = Library.SetVisible
Library.notification = Library.Notification
Library.destroy = Library.Destroy

local GlobalEnvironment = GetGlobalEnvironment()
if type(GlobalEnvironment) == "table" then
    local Atramenta = GlobalEnvironment.Atramenta
    if type(Atramenta) ~= "table" then
        Atramenta = {}
        GlobalEnvironment.Atramenta = Atramenta
    end
    Atramenta.Library = Library
    GlobalEnvironment.MatchaAtramentaLibrary = Library
end

if type(_G) == "table" then
    local Atramenta = _G.Atramenta
    if type(Atramenta) ~= "table" then
        Atramenta = {}
        _G.Atramenta = Atramenta
    end
    Atramenta.Library = Library
    _G.MatchaAtramentaLibrary = Library
end

-- Kept for normal Luau/executors. Matcha drops top-level return values from loadstring,
-- so Matcha consumers should read MatchaAtramentaLibrary / Atramenta.Library instead.
return Library
