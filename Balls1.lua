local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = PlayersService.LocalPlayer or PlayersService.PlayerAdded:Wait()
local LocalMouse = LocalPlayer:GetMouse()
local FastFloor = math.floor
local FastMax = math.max
local FastClamp = math.clamp
local FastClock = os.clock
local FastTick = tick
local KeysDown = {}

if _G.NightfallSession then
    _G.NightfallSession.Active = false
    for _, ConnectionObj in ipairs(_G.NightfallSession.Connections or {}) do
        pcall(function() ConnectionObj:Disconnect() end)
    end
end
_G.MoonshadeActive = false
if _G.NightfallDrawings then
    for _, DrawingObj in ipairs(_G.NightfallDrawings) do
        pcall(function() DrawingObj:Remove() end)
    end
end
if _G.MoonshadeDrawings then
    for _, DrawingObj in pairs(_G.MoonshadeDrawings) do
        pcall(function() DrawingObj:Remove() end)
    end
    _G.MoonshadeDrawings = nil
end
local Session = {Active = true, Connections = {}}
_G.NightfallSession = Session
_G.NightfallDrawings = {}
_G.NightfallActive = true
local function ConnectSession(EventObj, CallbackFunc)
    local ConnectionObj = EventObj:Connect(function(...)
        if Session.Active then CallbackFunc(...) end
    end)
    table.insert(Session.Connections, ConnectionObj)
    return ConnectionObj
end

local KeyCodes = {
    [1]="LMB",[2]="RMB",[3]="MMB",[4]="MB4",[5]="MB5",
    [8]="Backspace",[9]="Tab",[13]="Enter",
    [16]="Shift",[17]="Ctrl",[18]="Alt",[19]="Pause",
    [20]="CapsLock",[27]="Esc",[32]="Space",
    [33]="PageUp",[34]="PageDown",[35]="End",[36]="Home",
    [37]="Left",[38]="Up",[39]="Right",[40]="Down",
    [44]="PrintScreen",[45]="Insert",[46]="Delete",
    [48]="0",[49]="1",[50]="2",[51]="3",[52]="4",
    [53]="5",[54]="6",[55]="7",[56]="8",[57]="9",
    [65]="A",[66]="B",[67]="C",[68]="D",[69]="E",
    [70]="F",[71]="G",[72]="H",[73]="I",[74]="J",
    [75]="K",[76]="L",[77]="M",[78]="N",[79]="O",
    [80]="P",[81]="Q",[82]="R",[83]="S",[84]="T",
    [85]="U",[86]="V",[87]="W",[88]="X",[89]="Y",[90]="Z",
    [91]="LWin",[92]="RWin",
    [96]="Num0",[97]="Num1",[98]="Num2",[99]="Num3",[100]="Num4",
    [101]="Num5",[102]="Num6",[103]="Num7",[104]="Num8",[105]="Num9",
    [106]="Multiply",[107]="Add",[108]="Separator",[109]="Subtract",
    [110]="Decimal",[111]="Divide",
    [112]="F1",[113]="F2",[114]="F3",[115]="F4",[116]="F5",
    [117]="F6",[118]="F7",[119]="F8",[120]="F9",[121]="F10",
    [122]="F11",[123]="F12",[124]="F13",[125]="F14",[126]="F15",
    [127]="F16",[128]="F17",[129]="F18",[130]="F19",[131]="F20",
    [132]="F21",[133]="F22",[134]="F23",[135]="F24",
    [144]="NumLock",[145]="ScrollLock",
    [160]="LShift",[161]="RShift",[162]="LCtrl",[163]="RCtrl",
    [164]="LAlt",[165]="RAlt",
    [166]="BrowserBack",[167]="BrowserForward",[168]="BrowserRefresh",
    [169]="BrowserStop",[170]="BrowserSearch",[171]="BrowserFavorites",
    [172]="BrowserHome",[173]="VolumeMute",[174]="VolumeDown",[175]="VolumeUp",
    [176]="MediaNext",[177]="MediaPrev",[178]="MediaStop",[179]="MediaPlay",
    [186]=";",[187]="=",[188]=",",[189]="-",[190]=".",[191]="/",
    [192]="`",[219]="[",[220]="\\",[221]="]",[222]="'",
    [6]="MB6",[7]="MB7",
}

local NameToCode = {}
for CodeVal, NameVal in pairs(KeyCodes) do
    NameToCode[NameVal] = CodeVal
end

local Config = {
    AutoParry = false,
    TrainingBallsSupport = false,
    AutoSpam = false,
    TriggerBot = false,
    ParryKeybind = "None",
    SpamKeybind = "None",
    TriggerKeybind = "None",
    ParryMethod = "Click",
    SpamRate = 100,
    TriggerDelay = 0,
    HideKeybind = "F2",
    ShowHotkeyList = true,
    ParryBindMode = "Toggle",
    SpamBindMode = "Toggle",
    TriggerBindMode = "Toggle",
    ThemePreset = "Nightfall",
    ConfigName = "default",
    SelectedConfig = "default",
    ParryRange = 10,
    DontClickOnSpawn = false,
    InfinityDetection = false,
    SlashesOfFuryDetection = false,
    AutoSaveConfig = false,
    AutoLoadConfig = false,
    ShowWatermark = false,
    ShowNotifications = true,
    NotificationDuration = 4,
    NotificationPosition = "Top Right",
    WatermarkText = "Nightfall | Matcha",
    WatermarkCompact = true,
}

local function NormalizeKeybindValue(ValueIn)
    if type(ValueIn) == "number" then
        return KeyCodes[ValueIn] or tostring(ValueIn)
    end
    if ValueIn == nil or ValueIn == "" then return "None" end
    return tostring(ValueIn)
end

local function NormalizeBindMode(ModeIn)
    ModeIn = tostring(ModeIn or "Toggle")
    if string.lower(ModeIn) == "hold" then return "Hold" end
    return "Toggle"
end

local function GetModeFlagFromBindFlag(BindFlag)
    if BindFlag == "ParryKeybind" then return "ParryBindMode"
    elseif BindFlag == "SpamKeybind" then return "SpamBindMode"
    elseif BindFlag == "TriggerKeybind" then return "TriggerBindMode"
    end
end

local function GetToggleFlagFromBindFlag(BindFlag)
    if BindFlag == "ParryKeybind" then return "AutoParry"
    elseif BindFlag == "SpamKeybind" then return "AutoSpam"
    elseif BindFlag == "TriggerKeybind" then return "TriggerBot"
    end
end

local KeybindSystem
local SetBindTargetState

local function SetBindMode(BindFlag, ModeIn)
    local ModeFlag = GetModeFlagFromBindFlag(BindFlag)
    if ModeFlag then
        Config[ModeFlag] = NormalizeBindMode(ModeIn)
        local CurrentBind = KeybindSystem and KeybindSystem.Binds[BindFlag]
        if CurrentBind then
            if CurrentBind.Mode == "Hold" then SetBindTargetState(BindFlag, false) end
            CurrentBind.Mode = Config[ModeFlag]
            KeybindSystem.LastPressed[BindFlag] = iskeypressed(CurrentBind.Code) or false
        end
    end
end

local function GetBindMode(BindFlag)
    local ModeFlag = GetModeFlagFromBindFlag(BindFlag)
    return NormalizeBindMode(ModeFlag and Config[ModeFlag] or "Toggle")
end

SetBindTargetState = function(BindFlag, StateIn)
    local ToggleFlag = GetToggleFlagFromBindFlag(BindFlag)
    if ToggleFlag then Config[ToggleFlag] = StateIn and true or false end
end

KeybindSystem = {
    Binds = {},
    LastPressed = {}
}

local function RegisterKeybind(FlagName, KeyName, ModeIn)
    local CodeVal = NameToCode[NormalizeKeybindValue(KeyName)]
    KeybindSystem.Binds[FlagName] = CodeVal and {
        Code = CodeVal,
        Mode = NormalizeBindMode(ModeIn or "Toggle")
    } or nil
    KeybindSystem.LastPressed[FlagName] = CodeVal and iskeypressed(CodeVal) or false
end

local function UpdateKeybinds()
    if not isrbxactive() then
        for FlagName, DataVal in pairs(KeybindSystem.Binds) do
            if DataVal.Mode == "Hold" then SetBindTargetState(FlagName, false) end
            KeybindSystem.LastPressed[FlagName] = false
        end
        return
    end
    for FlagName, DataVal in pairs(KeybindSystem.Binds) do
        local IsPressed = iskeypressed(DataVal.Code) or false
        local WasPressed = KeybindSystem.LastPressed[FlagName] or false
        if IsPressed and not WasPressed then
            if DataVal.Mode == "Hold" then
                SetBindTargetState(FlagName, true)
            else
                local ToggleFlag = GetToggleFlagFromBindFlag(FlagName)
                if ToggleFlag then Config[ToggleFlag] = not Config[ToggleFlag] end
            end
        elseif not IsPressed and WasPressed and DataVal.Mode == "Hold" then
            SetBindTargetState(FlagName, false)
        end
        KeybindSystem.LastPressed[FlagName] = IsPressed
    end
end

local RuntimeState = {
    TargetSpeed = 0,
    TargetDistance = 0,
    TargetDot = 0
}

local function MathClamp(ValIn, MinVal, MaxVal)
    return FastMax(MinVal, math.min(MaxVal, ValIn))
end

local function MathRound(NumVal)
    return FastFloor(NumVal + 0.5)
end

local function Vector2Round(XVal, YVal)
    return Vector2.new(MathRound(XVal), MathRound(YVal))
end

local function MathLerp(AVal, BVal, TVal)
    return AVal + (BVal - AVal) * TVal
end

local function ColorLerp(C1Val, C2Val, TVal)
    if not C1Val or not C2Val then return Color3.new(1, 1, 1) end
    return Color3.new(MathLerp(C1Val.R, C2Val.R, TVal), MathLerp(C1Val.G, C2Val.G, TVal), MathLerp(C1Val.B, C2Val.B, TVal))
end

local function SnapValue(ValIn, StepVal)
    return StepVal and FastFloor((ValIn / StepVal) + 0.5) * StepVal or ValIn
end

local function HsvToColor3(HVal, SVal, VVal)
    HVal = ((HVal or 0) % 1 + 1) % 1
    SVal = MathClamp(SVal or 0, 0, 1)
    VVal = MathClamp(VVal or 0, 0, 1)
    local CVal = VVal * SVal
    local HpVal = HVal * 6
    local XVal = CVal * (1 - math.abs((HpVal % 2) - 1))
    local R1Val, G1Val, B1Val = 0, 0, 0
    if HpVal >= 0 and HpVal < 1 then R1Val, G1Val, B1Val = CVal, XVal, 0
    elseif HpVal >= 1 and HpVal < 2 then R1Val, G1Val, B1Val = XVal, CVal, 0
    elseif HpVal >= 2 and HpVal < 3 then R1Val, G1Val, B1Val = 0, CVal, XVal
    elseif HpVal >= 3 and HpVal < 4 then R1Val, G1Val, B1Val = 0, XVal, CVal
    elseif HpVal >= 4 and HpVal < 5 then R1Val, G1Val, B1Val = XVal, 0, CVal
    else R1Val, G1Val, B1Val = CVal, 0, XVal
    end
    local MVal = VVal - CVal
    return Color3.new(R1Val + MVal, G1Val + MVal, B1Val + MVal)
end

local function Color3ToHsv(ColorVal)
    if not ColorVal then return 0, 0, 1 end
    local RVal, GVal, BVal = ColorVal.R, ColorVal.G, ColorVal.B
    local MaxC = FastMax(RVal, GVal, BVal)
    local MinC = math.min(RVal, GVal, BVal)
    local DeltaC = MaxC - MinC
    local H2Val = 0
    if DeltaC > 0 then
        if MaxC == RVal then H2Val = ((GVal - BVal) / DeltaC) % 6
        elseif MaxC == GVal then H2Val = ((BVal - RVal) / DeltaC) + 2
        else H2Val = ((RVal - GVal) / DeltaC) + 4
        end
        H2Val = H2Val / 6
    end
    local S2Val = MaxC == 0 and 0 or (DeltaC / MaxC)
    return H2Val, S2Val, MaxC
end

local function Color3ToHex(ColorVal)
    if not ColorVal then return "#FFFFFF" end
    return string.format("#%02X%02X%02X", MathClamp(MathRound(ColorVal.R * 255), 0, 255), MathClamp(MathRound(ColorVal.G * 255), 0, 255), MathClamp(MathRound(ColorVal.B * 255), 0, 255))
end

local CreateDrawing
local function CreateGridSquares(CountVal)
    local GridArray = {}
    for IIdx = 1, CountVal do
        GridArray[IIdx] = CreateDrawing("Square", {Filled = true, Transparency = 1, Visible = false})
    end
    return GridArray
end

local function UpdateGridSquares(GridArray, ColsVal, RowsVal, XVal, YVal, WVal, HVal, ColorFunc, VisibleState)
    if not VisibleState or WVal <= 0 or HVal <= 0 then
        for _, SqVal in ipairs(GridArray) do SqVal.Visible = false end
        return
    end
    local CellW = WVal / ColsVal
    local CellH = HVal / RowsVal
    local IdxVal = 1
    for RowIdx = 1, RowsVal do
        for ColIdx = 1, ColsVal do
            local SqVal = GridArray[IdxVal]
            IdxVal = IdxVal + 1
            local X0Val = XVal + ((ColIdx - 1) * CellW)
            local Y0Val = YVal + ((RowIdx - 1) * CellH)
            local X1Val = XVal + (ColIdx * CellW)
            local Y1Val = YVal + (RowIdx * CellH)
            SqVal.Visible = true
            SqVal.Position = Vector2Round(X0Val, Y0Val)
            SqVal.Size = Vector2Round(FastMax(1, MathRound(X1Val - X0Val)), FastMax(1, MathRound(Y1Val - Y0Val)))
            SqVal.Color = ColorFunc(ColIdx, RowIdx, ColsVal, RowsVal)
            SqVal.Transparency = 1
        end
    end
end

local function HideGridSquares(GridArray)
    for _, SqVal in ipairs(GridArray) do SqVal.Visible = false end
end

local function GetStepDecimals(StepVal)
    if type(StepVal) ~= "number" then return 0 end
    local SVal = string.format("%.10f", StepVal):gsub("0+$", "")
    local DotIdx = SVal:find("%.")
    return DotIdx and (#SVal - DotIdx) or 0
end

local function FormatSliderValue(ValueIn, StepVal)
    if type(ValueIn) ~= "number" then return tostring(ValueIn) end
    local DecimalsVal = GetStepDecimals(StepVal)
    if DecimalsVal <= 0 then return tostring(FastFloor(ValueIn + 0.5)) end
    local FormattedVal = string.format("%." .. DecimalsVal .. "f", ValueIn)
    FormattedVal = FormattedVal:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    return FormattedVal
end

local function ParseSliderInput(TextValue)
    local CleanedVal = tostring(TextValue or ""):gsub(",", "."):gsub("[^%d%.%-]", "")
    if CleanedVal == "" or CleanedVal == "-" or CleanedVal == "." or CleanedVal == "-." then return nil end
    local NumberVal = tonumber(CleanedVal)
    if NumberVal == nil then return nil end
    return NumberVal
end

local function ClampSliderValue(ValueIn, MinVal, MaxVal, StepVal)
    local ClampedVal = MathClamp(ValueIn, MinVal, MaxVal)
    local SnappedVal = SnapValue(ClampedVal, StepVal)
    return MathClamp(SnappedVal, MinVal, MaxVal)
end

local QueueSaveConfig
local FireChange

local function CommitSliderInput(SliderObj)
    if not SliderObj then return end
    local ParsedVal = ParseSliderInput(SliderObj.InputBuffer)
    if ParsedVal == nil then
        SliderObj.InputBuffer = FormatSliderValue(Config[SliderObj.Flag], SliderObj.Step)
        return
    end
    local FinalValue = ClampSliderValue(ParsedVal, SliderObj.Min, SliderObj.Max, SliderObj.Step)
    if Config[SliderObj.Flag] ~= FinalValue then
        Config[SliderObj.Flag] = FinalValue
        if QueueSaveConfig then QueueSaveConfig() end
    end
    SliderObj.InputBuffer = FormatSliderValue(FinalValue, SliderObj.Step)
    if FireChange then FireChange(SliderObj) end
end

local function GetContextMenuPosition(ItemObj)
    local CameraObj = WorkspaceService.CurrentCamera
    local ViewportVal = CameraObj and CameraObj.ViewportSize or Vector2.new(1920, 1080)
    local MenuW, MenuH = 128, 66
    if not ItemObj or not ItemObj.ButtonPos or not ItemObj.ButtonSize then return Vector2Round(0, 0) end
    local ContextX = ItemObj.ButtonPos.X
    local ContextY = ItemObj.ButtonPos.Y + ItemObj.ButtonSize.Y + 6
    if ContextX + MenuW > ViewportVal.X then ContextX = ItemObj.ButtonPos.X + ItemObj.ButtonSize.X - MenuW end
    if ContextY + MenuH > ViewportVal.Y then ContextY = ItemObj.ButtonPos.Y - MenuH - 6 end
    return Vector2Round(MathClamp(ContextX, 0, ViewportVal.X - MenuW), MathClamp(ContextY, 0, ViewportVal.Y - MenuH))
end

local TextOffsets = {
    WindowTitle = {X = 0, Y = 0},
    SectionTitle = {X = 0, Y = 0},
    SidebarTab = {X = 0, Y = 0},
    ToggleLabel = {X = 0, Y = 0},
    SliderLabel = {X = 0, Y = 0},
    SliderValue = {X = 0, Y = 0},
    DropdownLabel = {X = 0, Y = 0},
    DropdownValue = {X = 0, Y = 0},
    DropdownIcon = {X = 0, Y = 0},
    DropdownOption = {X = 0, Y = 0},
    ColorPickerLabel = {X = 0, Y = 0},
    ColorPickerValue = {X = 0, Y = 0},
    ColorPickerPopupHex = {X = 0, Y = 0},
    KeybindLabel = {X = 0, Y = 0},
    KeybindValue = {X = 0, Y = 0},
    ButtonLabel = {X = 0, Y = 0},
    TextboxLabel = {X = 0, Y = 0},
    TextboxValue = {X = 0, Y = 0},
    HotkeysTitle = {X = 0, Y = 0},
    HotkeysRow = {X = 0, Y = 0},
    StatsTitle = {X = 0, Y = 0},
    StatsRow = {X = 0, Y = 0},
    ContextOption = {X = 0, Y = 0},
    ProfileName = {X = 0, Y = 0},
    ProfileCaption = {X = 0, Y = 0},
    ProfilePopup = {X = 0, Y = 0},
    ProfileAction = {X = 0, Y = 0}
}

_G.NightfallTextOffsets = TextOffsets

local function PositionText(TextObj, XVal, YVal, StyleName)
    local OffsetVal = TextOffsets[StyleName]
    if OffsetVal then
        XVal = XVal + OffsetVal.X
        YVal = YVal + OffsetVal.Y
    end
    TextObj.Position = Vector2Round(XVal, YVal)
end

local function PositionTextCentered(TextObj, RectPos, RectSize, StyleName)
    TextObj.Center = true
    PositionText(TextObj, RectPos.X + RectSize.X / 2, RectPos.Y + RectSize.Y / 2, StyleName)
end

local function IsMouseInBounds(PosIn, BoundsPos, BoundsSize)
    return PosIn.X >= BoundsPos.X and PosIn.X <= BoundsPos.X + BoundsSize.X and PosIn.Y >= BoundsPos.Y and PosIn.Y <= BoundsPos.Y + BoundsSize.Y
end

CreateDrawing = function(ClassName, PropertiesTable)
    local DrawingObj = Drawing.new(ClassName)
    for PropName, PropValue in pairs(PropertiesTable) do
        if ClassName == "Text" and PropName == "Size" then
            PropName = "FontSize"
        elseif ClassName == "Text" and PropName == "Font" and type(PropValue) == "number" then
            PropValue = Drawing.Fonts and Drawing.Fonts.SystemBold or PropValue
        end
        pcall(function() DrawingObj[PropName] = PropValue end)
    end
    table.insert(_G.NightfallDrawings, DrawingObj)
    return DrawingObj
end

local function CreateKeybindImageIcon(SizeVal)
    SizeVal = SizeVal or 18
    local function SquareFunc() return CreateDrawing("Square", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, Visible = false}) end
    local function CircleFunc() return CreateDrawing("Circle", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, NumSides = 18, Radius = 1, Visible = false}) end
    return {
        IsImage = false,
        Size = SizeVal,
        Parts = {
            Main = SquareFunc(), Top = SquareFunc(), Bottom = SquareFunc(),
            Left = SquareFunc(), Right = SquareFunc(),
            TL = CircleFunc(), TR = CircleFunc(), BL = CircleFunc(), BR = CircleFunc(),
            Inner = SquareFunc(), Dot1 = CircleFunc(), Dot2 = CircleFunc(), Dot3 = CircleFunc(),
            Keys = {SquareFunc(), SquareFunc(), SquareFunc(), SquareFunc(), SquareFunc(), SquareFunc()}
        }
    }
end

local function UpdateKeybindImageIcon(IconObj, PositionVal, ColorVal, VisibleState)
    if not IconObj then return end
    if IconObj.IsImage and IconObj.Image then
        local ImageObj = IconObj.Image
        ImageObj.Visible = VisibleState
        pcall(function() ImageObj.Position = PositionVal end)
        pcall(function() ImageObj.Size = Vector2Round(IconObj.Size, IconObj.Size) end)
        pcall(function() ImageObj.Color = ColorVal end)
        pcall(function() ImageObj.Transparency = VisibleState and 1 or 0 end)
        return
    end
    if not IconObj.Parts then
        if IconObj.Fallback then
            IconObj.Fallback.Visible = VisibleState
            if VisibleState then
                IconObj.Fallback.Position = PositionVal
                IconObj.Fallback.Color = ColorVal
            end
        end
        return
    end
    local SizeVal = IconObj.Size or 18
    local WidthVal = FastMax(12, FastFloor(SizeVal * 0.9 + 0.5))
    local HeightVal = FastMax(10, FastFloor(SizeVal * 0.72 + 0.5))
    local RadiusVal = FastMax(2, FastFloor(SizeVal * 0.15 + 0.5))
    local StrokeVal = FastMax(1, FastFloor(SizeVal * 0.07 + 0.5))
    local XVal = FastFloor(PositionVal.X + 0.5)
    local YVal = FastFloor(PositionVal.Y + 0.5)
    local WVal, HVal = WidthVal, HeightVal
    local PartsObj = IconObj.Parts
    local OutlineArray = {PartsObj.Main, PartsObj.Top, PartsObj.Bottom, PartsObj.Left, PartsObj.Right, PartsObj.TL, PartsObj.TR, PartsObj.BL, PartsObj.BR}
    for _, ObjItem in ipairs(OutlineArray) do
        ObjItem.Visible = VisibleState
        if VisibleState then ObjItem.Color = ColorVal ObjItem.Transparency = 1 end
    end
    if VisibleState then
        PartsObj.Main.Position = Vector2Round(XVal + RadiusVal, YVal + RadiusVal)
        PartsObj.Main.Size = Vector2Round(FastMax(WVal - RadiusVal * 2, 0), FastMax(HVal - RadiusVal * 2, 0))
        PartsObj.Top.Position = Vector2Round(XVal + RadiusVal, YVal)
        PartsObj.Top.Size = Vector2Round(FastMax(WVal - RadiusVal * 2, 0), RadiusVal)
        PartsObj.Bottom.Position = Vector2Round(XVal + RadiusVal, YVal + HVal - RadiusVal)
        PartsObj.Bottom.Size = Vector2Round(FastMax(WVal - RadiusVal * 2, 0), RadiusVal)
        PartsObj.Left.Position = Vector2Round(XVal, YVal + RadiusVal)
        PartsObj.Left.Size = Vector2Round(RadiusVal, FastMax(HVal - RadiusVal * 2, 0))
        PartsObj.Right.Position = Vector2Round(XVal + WVal - RadiusVal, YVal + RadiusVal)
        PartsObj.Right.Size = Vector2Round(RadiusVal, FastMax(HVal - RadiusVal * 2, 0))
        PartsObj.TL.Position = Vector2Round(XVal + RadiusVal, YVal + RadiusVal)
        PartsObj.TR.Position = Vector2Round(XVal + WVal - RadiusVal, YVal + RadiusVal)
        PartsObj.BL.Position = Vector2Round(XVal + RadiusVal, YVal + HVal - RadiusVal)
        PartsObj.BR.Position = Vector2Round(XVal + WVal - RadiusVal, YVal + HVal - RadiusVal)
        PartsObj.TL.Radius = RadiusVal
        PartsObj.TR.Radius = RadiusVal
        PartsObj.BL.Radius = RadiusVal
        PartsObj.BR.Radius = RadiusVal
    end
    local InnerPad = StrokeVal + 1
    PartsObj.Inner.Visible = VisibleState
    if VisibleState then
        PartsObj.Inner.Position = Vector2Round(XVal + InnerPad, YVal + InnerPad)
        PartsObj.Inner.Size = Vector2Round(FastMax(WVal - InnerPad * 2, 1), FastMax(HVal - InnerPad * 2, 1))
        PartsObj.Inner.Color = Color3.fromRGB(16, 20, 30)
        PartsObj.Inner.Transparency = 1
    end
    local DotRadius = FastMax(1, FastFloor(SizeVal * 0.05 + 0.5))
    local DotGap = FastMax(3, FastFloor(SizeVal * 0.13 + 0.5))
    local DotStartX = XVal + InnerPad + DotRadius + 1
    local DotY = YVal + InnerPad + DotRadius + 1
    local DotsArray = {PartsObj.Dot1, PartsObj.Dot2, PartsObj.Dot3}
    for IIdx, DotObj in ipairs(DotsArray) do
        DotObj.Visible = VisibleState
        if VisibleState then
            DotObj.Position = Vector2Round(DotStartX + (IIdx - 1) * DotGap, DotY)
            DotObj.Radius = DotRadius
            DotObj.Color = ColorVal
            DotObj.Transparency = 1
        end
    end
    local KeyPadX = FastMax(3, FastFloor(SizeVal * 0.14 + 0.5))
    local KeyPadY = FastMax(5, FastFloor(SizeVal * 0.24 + 0.5))
    local KeyGap = FastMax(1, FastFloor(SizeVal * 0.06 + 0.5))
    local AvailableW = FastMax(WVal - KeyPadX * 2, 6)
    local AvailableH = FastMax(HVal - KeyPadY - InnerPad - 1, 4)
    local KeySize = FastMax(2, FastFloor(math.min((AvailableW - KeyGap * 2) / 3, (AvailableH - KeyGap) / 2) + 0.5))
    local TotalKeysWidth = KeySize * 3 + KeyGap * 2
    local TotalKeysHeight = KeySize * 2 + KeyGap
    local KeysStartX = XVal + FastFloor((WVal - TotalKeysWidth) / 2 + 0.5)
    local KeysStartY = YVal + HVal - InnerPad - TotalKeysHeight - 1
    for IIdx, KeyObj in ipairs(PartsObj.Keys) do
        KeyObj.Visible = VisibleState
        if VisibleState then
            local RowVal = FastFloor((IIdx - 1) / 3)
            local ColVal = (IIdx - 1) % 3
            KeyObj.Position = Vector2Round(KeysStartX + ColVal * (KeySize + KeyGap), KeysStartY + RowVal * (KeySize + KeyGap))
            KeyObj.Size = Vector2Round(KeySize, KeySize)
            KeyObj.Color = ColorVal
            KeyObj.Transparency = 1
        end
    end
end

local function SetVisible(ItemObj, VisibleState)
    if not ItemObj then return end
    if ItemObj.Single then
        ItemObj.Single.Visible = VisibleState
    elseif ItemObj.Main then
        ItemObj.Main.Visible = VisibleState
        ItemObj.Top.Visible = VisibleState
        ItemObj.Bottom.Visible = VisibleState
        ItemObj.Left.Visible = VisibleState
        ItemObj.Right.Visible = VisibleState
        ItemObj.TL.Visible = VisibleState
        ItemObj.TR.Visible = VisibleState
        ItemObj.BL.Visible = VisibleState
        ItemObj.BR.Visible = VisibleState
    elseif ItemObj.IsImage or ItemObj.Fallback or ItemObj.Image then
        UpdateKeybindImageIcon(ItemObj, Vector2Round(-1000, -1000), Color3.new(1, 1, 1), VisibleState)
    else
        ItemObj.Visible = VisibleState
    end
end

local function SetRoundedColor(BoxObj, ColorVal, TransparencyVal)
    if BoxObj.Single then
        BoxObj.Single.Color = ColorVal
        BoxObj.Single.Transparency = TransparencyVal or 1
        return
    end
    local ListArray = {BoxObj.Main, BoxObj.Top, BoxObj.Bottom, BoxObj.Left, BoxObj.Right, BoxObj.TL, BoxObj.TR, BoxObj.BL, BoxObj.BR}
    for _, ObjItem in ipairs(ListArray) do
        ObjItem.Color = ColorVal
        ObjItem.Transparency = TransparencyVal or 1
    end
end

local function SetDrawingLayer(ItemObj, LayerVal)
    if not ItemObj then return end
    if ItemObj.Single then
        pcall(function() ItemObj.Single.ZIndex = LayerVal end)
    elseif ItemObj.Main then
        for _, DrawObj in pairs(ItemObj) do
            pcall(function() DrawObj.ZIndex = LayerVal end)
        end
    else
        pcall(function() ItemObj.ZIndex = LayerVal end)
    end
end

local RoundedCornerSupported = nil
local function MakeRoundedBox(ColorVal, TransparencyVal)
    if RoundedCornerSupported ~= false then
        local SquareObj = CreateDrawing("Square", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, Visible = false})
        local Supported = pcall(function() SquareObj.Corner = 4 end)
        RoundedCornerSupported = Supported
        if Supported then return {Single = SquareObj} end
        pcall(function() SquareObj:Remove() end)
    end
    return {
        Main = CreateDrawing("Square", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, Visible = false}),
        Top = CreateDrawing("Square", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, Visible = false}),
        Bottom = CreateDrawing("Square", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, Visible = false}),
        Left = CreateDrawing("Square", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, Visible = false}),
        Right = CreateDrawing("Square", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, Visible = false}),
        TL = CreateDrawing("Circle", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, NumSides = 18, Radius = 4, Visible = false}),
        TR = CreateDrawing("Circle", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, NumSides = 18, Radius = 4, Visible = false}),
        BL = CreateDrawing("Circle", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, NumSides = 18, Radius = 4, Visible = false}),
        BR = CreateDrawing("Circle", {Filled = true, Color = ColorVal, Transparency = TransparencyVal or 1, NumSides = 18, Radius = 4, Visible = false})
    }
end

local function UpdateRoundedBox(BoxObj, PosVal, SizeVal, RadiusVal, ColorVal, TransparencyVal, VisibleState)
    RadiusVal = MathClamp(RadiusVal or 4, 0, FastFloor(math.min(SizeVal.X, SizeVal.Y) / 2))
    if BoxObj.Single then
        local SquareObj = BoxObj.Single
        SquareObj.Position = PosVal
        SquareObj.Size = Vector2Round(FastMax(0, SizeVal.X), FastMax(0, SizeVal.Y))
        SquareObj.Corner = RadiusVal
        SquareObj.Color = ColorVal
        SquareObj.Transparency = TransparencyVal or 1
        SquareObj.Visible = VisibleState and SizeVal.X > 0 and SizeVal.Y > 0
        return
    end
    local XVal, YVal = PosVal.X, PosVal.Y
    local WVal, HVal = SizeVal.X, SizeVal.Y
    SetRoundedColor(BoxObj, ColorVal, TransparencyVal or 1)
    SetVisible(BoxObj, VisibleState)
    BoxObj.Main.Position = Vector2Round(XVal + RadiusVal, YVal + RadiusVal)
    BoxObj.Main.Size = Vector2Round(FastMax(WVal - RadiusVal * 2, 0), FastMax(HVal - RadiusVal * 2, 0))
    BoxObj.Top.Position = Vector2Round(XVal + RadiusVal, YVal)
    BoxObj.Top.Size = Vector2Round(FastMax(WVal - RadiusVal * 2, 0), RadiusVal)
    BoxObj.Bottom.Position = Vector2Round(XVal + RadiusVal, YVal + HVal - RadiusVal)
    BoxObj.Bottom.Size = Vector2Round(FastMax(WVal - RadiusVal * 2, 0), RadiusVal)
    BoxObj.Left.Position = Vector2Round(XVal, YVal + RadiusVal)
    BoxObj.Left.Size = Vector2Round(RadiusVal, FastMax(HVal - RadiusVal * 2, 0))
    BoxObj.Right.Position = Vector2Round(XVal + WVal - RadiusVal, YVal + RadiusVal)
    BoxObj.Right.Size = Vector2Round(RadiusVal, FastMax(HVal - RadiusVal * 2, 0))
    BoxObj.TL.Position = Vector2Round(XVal + RadiusVal, YVal + RadiusVal)
    BoxObj.TR.Position = Vector2Round(XVal + WVal - RadiusVal, YVal + RadiusVal)
    BoxObj.BL.Position = Vector2Round(XVal + RadiusVal, YVal + HVal - RadiusVal)
    BoxObj.BR.Position = Vector2Round(XVal + WVal - RadiusVal, YVal + HVal - RadiusVal)
    BoxObj.TL.Radius = RadiusVal
    BoxObj.TR.Radius = RadiusVal
    BoxObj.BL.Radius = RadiusVal
    BoxObj.BR.Radius = RadiusVal
end

local function MakeGradientLine(CountVal)
    local ItemsArray = {}
    for IIdx = 1, CountVal do
        ItemsArray[IIdx] = CreateDrawing("Square", {Filled = true, Visible = false})
    end
    return ItemsArray
end

local function UpdateGradientLine(ItemsArray, PosVal, SizeVal, C1Val, C2Val, VisibleState)
    local CountVal = #ItemsArray
    local WidthVal = FastMax(0, MathRound(SizeVal.X))
    local HeightVal = FastMax(0, MathRound(SizeVal.Y))
    local StartX = MathRound(PosVal.X)
    local StartY = MathRound(PosVal.Y)
    for IIdx = 1, CountVal do
        local X0Val = StartX + MathRound((IIdx - 1) * WidthVal / CountVal)
        local X1Val = StartX + MathRound(IIdx * WidthVal / CountVal)
        local ItObj = ItemsArray[IIdx]
        ItObj.Visible = VisibleState and X1Val > X0Val and HeightVal > 0
        if ItObj.Visible then
            ItObj.Color = ColorLerp(C1Val, C2Val, (IIdx - 0.5) / CountVal)
            ItObj.Position = Vector2Round(X0Val, StartY)
            ItObj.Size = Vector2Round(X1Val - X0Val, HeightVal)
        end
    end
end

local function HideGradientLine(ItemsArray)
    for _, ItObj in ipairs(ItemsArray) do ItObj.Visible = false end
end

local function MakeRoundedGradientCaps()
    local Caps = {Left = {}, Right = {}}
    for IIdx = 1, 5 do
        Caps.Left[IIdx] = CreateDrawing("Square", {Filled = true, Visible = false})
        Caps.Right[IIdx] = CreateDrawing("Square", {Filled = true, Visible = false})
    end
    return Caps
end

local function UpdateRoundedGradient(ItemsArray, Caps, PosVal, SizeVal, C1Val, C2Val, VisibleState)
    local WVal = MathRound(SizeVal.X)
    local HVal = MathRound(SizeVal.Y)
    if not VisibleState or WVal < 18 or HVal < 3 then
        HideGradientLine(ItemsArray)
        for _, CapVal in ipairs(Caps.Left) do CapVal.Visible = false end
        for _, CapVal in ipairs(Caps.Right) do CapVal.Visible = false end
        return
    end
    local XVal = MathRound(PosVal.X)
    local YVal = MathRound(PosVal.Y)
    UpdateGradientLine(ItemsArray, Vector2Round(XVal + 7, YVal + 2), Vector2Round(WVal - 14, 2), C1Val, C2Val, true)
    local CurveY = {3, 2, 1, 0, 0}
    for IIdx = 1, 5 do
        local LX = XVal + IIdx + 1
        local RX = XVal + WVal - IIdx - 2
        local LCap = Caps.Left[IIdx]
        local RCap = Caps.Right[IIdx]
        local CapY = YVal + 2 + CurveY[IIdx]
        LCap.Position = Vector2Round(LX, CapY)
        RCap.Position = Vector2Round(RX, CapY)
        LCap.Size = Vector2Round(1, 2)
        RCap.Size = Vector2Round(1, 2)
        LCap.Color = ColorLerp(C1Val, C2Val, (LX - XVal + 0.5) / WVal)
        RCap.Color = ColorLerp(C1Val, C2Val, (RX - XVal + 0.5) / WVal)
        LCap.Visible = true
        RCap.Visible = true
    end
end

local function HideRoundedGradient(ItemsArray, Caps)
    HideGradientLine(ItemsArray)
    for _, CapVal in ipairs(Caps.Left) do CapVal.Visible = false end
    for _, CapVal in ipairs(Caps.Right) do CapVal.Visible = false end
end

local function MakeStripePattern(CountVal, ThicknessVal)
    local ItemsArray = {}
    for IIdx = 1, CountVal do
        ItemsArray[IIdx] = CreateDrawing("Line", {Thickness = ThicknessVal or 10, Transparency = 0.08, Visible = false})
    end
    return ItemsArray
end

local function UpdateStripePattern(ItemsArray, RectX, RectY, RectW, RectH, SlantVal, SpacingVal, ColorVal, VisibleState)
    for _, LineObj in ipairs(ItemsArray) do 
        LineObj.Visible = false 
    end
end

local function HideStripePattern(ItemsArray)
    for _, LineObj in ipairs(ItemsArray) do LineObj.Visible = false end
end

local function ClampWindowPosition(PositionVal, SizeVal)
    local CameraObj = WorkspaceService.CurrentCamera
    local ViewportVal = CameraObj and CameraObj.ViewportSize or Vector2.new(1920, 1080)
    local XVal = MathClamp(PositionVal.X, 0, FastMax(0, ViewportVal.X - SizeVal.X))
    local YVal = MathClamp(PositionVal.Y, 0, FastMax(0, ViewportVal.Y - SizeVal.Y))
    return Vector2Round(XVal, YVal)
end

local LibraryData = {
    Position = Vector2.new(200, 200),
    TargetPosition = Vector2.new(200, 200),
    Size = Vector2.new(720, 480),
    HotkeysPosition = Vector2.new(936, 240),
    Visible = true,
    BindPressed = false,
    Tabs = {},
    CurrentTab = nil,
    Palette = {
        Background = Color3.new(0.035294, 0.035294, 0.050980),
        Sidebar = Color3.new(0.050980, 0.050980, 0.066666),
        Section = Color3.new(0.066666, 0.066666, 0.082352),
        Element = Color3.new(0.090196, 0.090196, 0.105882),
        Hover = Color3.new(0.121568, 0.121568, 0.145098),
        Outline = Color3.new(0.105882, 0.105882, 0.133333),
        OutlineLight = Color3.new(0.172549, 0.172549, 0.211764),
        Accent = Color3.new(0.423529, 0.576470, 0.988235),
        Accent2 = Color3.new(0.619607, 0.462745, 0.988235),
        Text = Color3.new(0.952941, 0.952941, 0.972549),
        SubText = Color3.new(0.541176, 0.541176, 0.580392)
    },
    Input = {
        MousePos = Vector2.new(0, 0),
        Mouse1Down = false, Mouse1Prev = false, Mouse1Clicked = false, Mouse1Released = false,
        Mouse1EventDown = false, Mouse1ClickQueued = false, Mouse1ReleaseQueued = false,
        Mouse2Down = false, Mouse2Prev = false, Mouse2Clicked = false,
        Mouse4Down = false, Mouse4Prev = false, Mouse4Clicked = false, Mouse4Released = false,
        Mouse5Down = false, Mouse5Prev = false, Mouse5Clicked = false, Mouse5Released = false,
    },
    State = {
        ActiveDropdown = nil, ActiveSlider = nil, ActiveSliderInput = nil,
        ActiveTextbox = nil, ActiveKeybind = nil, ActiveColorPicker = nil, ActiveColorDrag = nil,
        Dragging = false, DragStart = Vector2.new(0, 0), WindowStart = Vector2.new(0, 0),
        HotkeysDragging = false, HotkeysDragStart = Vector2.new(0, 0), HotkeysWindowStart = Vector2.new(0, 0),
        HotkeysContext = {Open = false, Position = Vector2.new(0, 0), Entry = nil},
        KeybindContext = {Open = false, Position = Vector2.new(0, 0), Entry = nil},
        BackspaceHeld = false, BackspaceNextRepeat = 0,
        ProfileOpen = false, ProfileCopiedUntil = 0
    }
}

local DefaultNightfallPalette = {
    Background = Color3.new(0.035294, 0.035294, 0.050980),
    Sidebar = Color3.new(0.050980, 0.050980, 0.066666),
    Section = Color3.new(0.066666, 0.066666, 0.082352),
    Element = Color3.new(0.090196, 0.090196, 0.105882),
    Hover = Color3.new(0.121568, 0.121568, 0.145098),
    Outline = Color3.new(0.105882, 0.105882, 0.133333),
    OutlineLight = Color3.new(0.172549, 0.172549, 0.211764),
    Accent = Color3.new(0.423529, 0.576470, 0.988235),
    Accent2 = Color3.new(0.619607, 0.462745, 0.988235),
    Text = Color3.new(0.952941, 0.952941, 0.972549),
    SubText = Color3.new(0.541176, 0.541176, 0.580392)
}

local ThemePresets = {
    Nightfall = {
        Background = DefaultNightfallPalette.Background, Sidebar = DefaultNightfallPalette.Sidebar,
        Section = DefaultNightfallPalette.Section, Element = DefaultNightfallPalette.Element,
        Hover = DefaultNightfallPalette.Hover, Outline = DefaultNightfallPalette.Outline,
        OutlineLight = DefaultNightfallPalette.OutlineLight, Accent = DefaultNightfallPalette.Accent,
        Accent2 = DefaultNightfallPalette.Accent2, Text = DefaultNightfallPalette.Text,
        SubText = DefaultNightfallPalette.SubText
    },
    Bloodmoon = {
        Background = Color3.fromRGB(20, 8, 12), Sidebar = Color3.fromRGB(28, 10, 16),
        Section = Color3.fromRGB(36, 12, 20), Element = Color3.fromRGB(46, 14, 24),
        Hover = Color3.fromRGB(58, 18, 32), Outline = Color3.fromRGB(70, 28, 40),
        OutlineLight = Color3.fromRGB(96, 42, 56), Accent = Color3.fromRGB(235, 72, 96),
        Accent2 = Color3.fromRGB(255, 128, 164), Text = Color3.fromRGB(246, 238, 242),
        SubText = Color3.fromRGB(176, 150, 158)
    },
    Ocean = {
        Background = Color3.fromRGB(8, 14, 24), Sidebar = Color3.fromRGB(10, 18, 32),
        Section = Color3.fromRGB(12, 24, 40), Element = Color3.fromRGB(16, 30, 50),
        Hover = Color3.fromRGB(20, 40, 64), Outline = Color3.fromRGB(28, 52, 78),
        OutlineLight = Color3.fromRGB(42, 70, 100), Accent = Color3.fromRGB(74, 168, 255),
        Accent2 = Color3.fromRGB(98, 220, 255), Text = Color3.fromRGB(240, 246, 255),
        SubText = Color3.fromRGB(148, 170, 196)
    },
    Mint = {
        Background = Color3.fromRGB(10, 18, 16), Sidebar = Color3.fromRGB(12, 24, 20),
        Section = Color3.fromRGB(14, 30, 24), Element = Color3.fromRGB(18, 38, 30),
        Hover = Color3.fromRGB(24, 48, 38), Outline = Color3.fromRGB(38, 68, 56),
        OutlineLight = Color3.fromRGB(58, 96, 82), Accent = Color3.fromRGB(64, 224, 160),
        Accent2 = Color3.fromRGB(124, 255, 208), Text = Color3.fromRGB(238, 252, 246),
        SubText = Color3.fromRGB(146, 178, 164)
    }
}

local PaletteKeys = {"Background", "Sidebar", "Section", "Element", "Hover", "Outline", "OutlineLight", "Accent", "Accent2", "Text", "SubText"}
local ConfigDirty = false
local SettingsDirty = false
local SaveQueueTick = 0
local SettingsQueueTick = 0
local IsConfigLoading = false
local ConfigLoaded = false
local ConfigDirectory = "NightfallConfigs"
local PendingWatermarkPosition = nil
local WatermarkSettings
local GlobalSettingsPath = ConfigDirectory .. "/Settings.json"

local function EnsureConfigDirectory()
    if makefolder and isfolder and not isfolder(ConfigDirectory) then
        return pcall(makefolder, ConfigDirectory)
    end
    return true
end

local PersistentSettings = {
    "SelectedConfig", "ConfigName", "AutoSaveConfig", "AutoLoadConfig", "ThemePreset",
    "HideKeybind", "ShowHotkeyList", "ShowWatermark", "ShowNotifications",
    "NotificationDuration", "NotificationPosition", "WatermarkText", "WatermarkCompact"
}

local function ReadJsonFile(Path)
    if not (isfile and readfile) or not isfile(Path) then return nil end
    local Success, Result = pcall(function() return HttpService:JSONDecode(readfile(Path)) end)
    return Success and type(Result) == "table" and Result or nil
end

local function WriteJsonFile(Path, Data)
    if not writefile or not EnsureConfigDirectory() then return false end
    local Success, Payload = pcall(function() return HttpService:JSONEncode(Data) end)
    if not Success or type(Payload) ~= "string" or #Payload == 0 then return false end
    if isfile and readfile and isfile(Path) then
        local ReadSuccess, OldContent = pcall(readfile, Path)
        if ReadSuccess and type(OldContent) == "string" and #OldContent > 0 then
            pcall(writefile, Path:gsub("%.json$", ".backup.json"), OldContent)
        end
    end
    return pcall(writefile, Path, Payload)
end

local function SaveGlobalSettings()
    local Data = {Version = 2}
    for _, Key in ipairs(PersistentSettings) do
        Data[Key] = Config[Key]
    end
    local Saved = WriteJsonFile(GlobalSettingsPath, Data)
    if Saved then SettingsDirty = false end
    return Saved
end

local function LoadGlobalSettings()
    local Data = ReadJsonFile(GlobalSettingsPath)
    if not Data then Data = ReadJsonFile("Nightfall_Settings.json") end
    if not Data then return false end
    for _, Key in ipairs(PersistentSettings) do
        if Config[Key] ~= nil and type(Data[Key]) == type(Config[Key]) then
            Config[Key] = Data[Key]
        end
    end
    Config.NotificationDuration = MathClamp(Config.NotificationDuration, 1, 15)
    return true
end

local function GetConfigBaseName()
    local NameVal = tostring(Config.ConfigName or "default")
    NameVal = NameVal:gsub("[^%w%-_]", "_"):sub(1, 48)
    if NameVal == "" then NameVal = "default" end
    return NameVal
end

local function GetConfigPath()
    return "NightfallConfigs/" .. GetConfigBaseName() .. ".json"
end

local function GetLayoutPath()
    return "NightfallConfigs/" .. GetConfigBaseName() .. "_layout.json"
end

local function GetAvailableConfigs()
    local NamesArray = {}
    local SeenTable = {}
    if listfiles and isfolder and isfolder(ConfigDirectory) then
        local OkState, FilesArray = pcall(listfiles, ConfigDirectory)
        if OkState and type(FilesArray) == "table" then
            for _, FilePath in ipairs(FilesArray) do
                local FileName = tostring(FilePath):gsub("\\", "/"):match("([^/]+)$")
                local NameVal = FileName and FileName:match("^(.-)%.json$")
                if NameVal and NameVal ~= "Settings" and not NameVal:match("_layout$") and not NameVal:match("%.backup$") then
                    if not SeenTable[NameVal] then
                        SeenTable[NameVal] = true
                        table.insert(NamesArray, NameVal)
                    end
                end
            end
        end
    end
    if #NamesArray == 0 then table.insert(NamesArray, "default") end
    table.sort(NamesArray, function(AVal, BVal) return tostring(AVal):lower() < tostring(BVal):lower() end)
    return NamesArray
end

local function ApplyPalette(PaletteTable)
    if type(PaletteTable) ~= "table" then return end
    for _, KeyVal in ipairs(PaletteKeys) do
        if PaletteTable[KeyVal] then LibraryData.Palette[KeyVal] = PaletteTable[KeyVal] end
    end
end

local function SyncThemeEditorState()
    if not LibraryData or not LibraryData.Tabs then return end
    for _, TabObj in ipairs(LibraryData.Tabs) do
        if TabObj and TabObj.Sections then
            for _, SectionObj in ipairs(TabObj.Sections) do
                if SectionObj and SectionObj.Items then
                    for _, ItemObj in ipairs(SectionObj.Items) do
                        if ItemObj and ItemObj.Type == "ColorPicker" and ItemObj.Flag and type(Config[ItemObj.Flag]) == "table" and Config[ItemObj.Flag].Color then
                            local HVal, SVal, VVal = Color3ToHsv(Config[ItemObj.Flag].Color)
                            ItemObj.Hue = HVal
                            ItemObj.Sat = SVal
                            ItemObj.Val = VVal
                            ItemObj.Alpha = MathClamp(Config[ItemObj.Flag].Alpha or 1, 0, 1)
                        end
                    end
                end
            end
        end
    end
end

QueueSaveConfig = function()
    if IsConfigLoading then return end
    SettingsDirty = true
    SettingsQueueTick = FastTick()
    if Config.AutoSaveConfig then
        ConfigDirty = true
        SaveQueueTick = FastTick()
    end
end

local function ApplyThemePreset(ThemeName, KeepAccent)
    local PresetVal = ThemePresets[ThemeName]
    if not PresetVal then PresetVal = ThemePresets.Nightfall ThemeName = "Nightfall" end
    local AccentVal = LibraryData.Palette.Accent
    local Accent2Val = LibraryData.Palette.Accent2
    local AccentAlpha = type(Config.UiAccentColor) == "table" and MathClamp(Config.UiAccentColor.Alpha or 1, 0, 1) or 1
    local Accent2Alpha = type(Config.UiAccent2Color) == "table" and MathClamp(Config.UiAccent2Color.Alpha or 1, 0, 1) or 1
    ApplyPalette(PresetVal)
    if KeepAccent then LibraryData.Palette.Accent = AccentVal LibraryData.Palette.Accent2 = Accent2Val end
    Config.ThemePreset = ThemeName
    Config.UiAccentColor = {Color = LibraryData.Palette.Accent, Alpha = AccentAlpha}
    Config.UiAccent2Color = {Color = LibraryData.Palette.Accent2, Alpha = Accent2Alpha}
    SyncThemeEditorState()
    QueueSaveConfig()
end

local function SaveLayout()
    local Position = WatermarkSettings and WatermarkSettings.Position or PendingWatermarkPosition
    local Layout = {
        Version = 2,
        Window = {X = LibraryData.TargetPosition.X, Y = LibraryData.TargetPosition.Y},
        Hotkeys = {X = LibraryData.HotkeysPosition.X, Y = LibraryData.HotkeysPosition.Y},
        Watermark = Position and {X = Position.X, Y = Position.Y} or nil
    }
    return WriteJsonFile(GetLayoutPath(), Layout)
end

local function LoadLayout()
    local Layout = ReadJsonFile(GetLayoutPath())
    if not Layout then return false end
    local Window = Layout.Window or {X = Layout.WindowX, Y = Layout.WindowY}
    local Hotkeys = Layout.Hotkeys or {X = Layout.HotkeysX, Y = Layout.HotkeysY}
    if type(Window.X) == "number" and type(Window.Y) == "number" then
        LibraryData.TargetPosition = ClampWindowPosition(Vector2.new(Window.X, Window.Y), LibraryData.Size)
        LibraryData.Position = LibraryData.TargetPosition
    end
    if type(Hotkeys.X) == "number" and type(Hotkeys.Y) == "number" then
        LibraryData.HotkeysPosition = ClampWindowPosition(Vector2.new(Hotkeys.X, Hotkeys.Y), Vector2.new(220, 120))
    end
    if type(Layout.Watermark) == "table" and type(Layout.Watermark.X) == "number" and type(Layout.Watermark.Y) == "number" then
        PendingWatermarkPosition = Vector2.new(Layout.Watermark.X, Layout.Watermark.Y)
        if WatermarkSettings then WatermarkSettings.Position = PendingWatermarkPosition end
    end
    return true
end

local function SerializeConfigValue(Value)
    if type(Value) == "boolean" or type(Value) == "number" or type(Value) == "string" then
        return Value
    end
    if type(Value) == "table" and Value.Color and typeof(Value.Color) == "Color3" then
        return {Hex = Color3ToHex(Value.Color), Alpha = MathClamp(tonumber(Value.Alpha) or 1, 0, 1)}
    end
    return nil
end

local function DeserializeConfigColor(Value)
    if type(Value) ~= "table" or type(Value.Hex) ~= "string" then return nil end
    local Hex = Value.Hex:match("^#?(%x%x%x%x%x%x)$")
    if not Hex then return nil end
    return {Color = Color3.fromRGB(tonumber(Hex:sub(1, 2), 16), tonumber(Hex:sub(3, 4), 16), tonumber(Hex:sub(5, 6), 16)), Alpha = MathClamp(tonumber(Value.Alpha) or 1, 0, 1)}
end

local function SaveCurrentConfig()
    local Flags = {}
    local Excluded = {ConfigName = true, SelectedConfig = true, AutoSaveConfig = true, AutoLoadConfig = true, RenderBallStats = true}
    for Key, Value in pairs(Config) do
        if not Excluded[Key] then
            local Encoded = SerializeConfigValue(Value)
            if Encoded ~= nil then Flags[Key] = Encoded end
        end
    end
    local Name = GetConfigBaseName()
    local Data = {
        Version = 2,
        Name = Name,
        Flags = Flags,
        Palette = {
            Accent = Color3ToHex(LibraryData.Palette.Accent),
            Accent2 = Color3ToHex(LibraryData.Palette.Accent2)
        }
    }
    if not WriteJsonFile(GetConfigPath(), Data) then return false end
    Config.ConfigName = Name
    Config.SelectedConfig = Name
    SaveLayout()
    SaveGlobalSettings()
    ConfigDirty = false
    return true
end

local function DeleteNamedConfig(Name)
    local SafeName = tostring(Name or ""):gsub("[^%w%-_]", "_"):sub(1, 48)
    if SafeName == "" or SafeName == "Settings" then return false end
    if not delfile then return false end
    local Base = ConfigDirectory .. "/" .. SafeName
    local Deleted = false
    for _, Suffix in ipairs({".json", "_layout.json", ".backup.json", "_layout.backup.json"}) do
        local Path = Base .. Suffix
        if isfile and isfile(Path) then
            local Success = pcall(delfile, Path)
            if Suffix == ".json" and Success then Deleted = true end
        end
    end
    if Config.SelectedConfig == SafeName then Config.SelectedConfig = "default" end
    if Config.ConfigName == SafeName then Config.ConfigName = "default" end
    SaveGlobalSettings()
    return Deleted
end

local function LoadNamedConfig(Name)
    local SelectedName = tostring(Name or Config.SelectedConfig or "default"):gsub("[^%w%-_]", "_"):sub(1, 48)
    if SelectedName == "" then SelectedName = "default" end
    local ConfigPath = ConfigDirectory .. "/" .. SelectedName .. ".json"
    local Data = ReadJsonFile(ConfigPath)
    if not Data then Data = ReadJsonFile(ConfigPath:gsub("%.json$", ".backup.json")) end
    if not Data then return false end
    local Flags = type(Data.Flags) == "table" and Data.Flags or Data
    IsConfigLoading = true
    for Key, Value in pairs(Flags) do
        if Key ~= "ConfigName" and Key ~= "SelectedConfig" and Key ~= "AutoLoadConfig" and Key ~= "AutoSaveConfig" and Key ~= "RenderBallStats" then
            if type(Config[Key]) == "table" then
                local ColorValue = DeserializeConfigColor(Value)
                if ColorValue then Config[Key] = ColorValue end
            elseif Config[Key] ~= nil and type(Value) == type(Config[Key]) then
                Config[Key] = Value
            end
        end
    end
    for _, Key in ipairs({"Parry", "Spam", "Trigger"}) do
        Config[Key .. "BindMode"] = NormalizeBindMode(Config[Key .. "BindMode"])
        RegisterKeybind(Key .. "Keybind", Config[Key .. "Keybind"], Config[Key .. "BindMode"])
    end
    ApplyThemePreset(Config.ThemePreset or "Nightfall", false)
    local Colors = type(Data.Palette) == "table" and Data.Palette or {}
    for PaletteKey, FlagKey in pairs({Accent = "UiAccentColor", Accent2 = "UiAccent2Color"}) do
        local Saved = Colors[PaletteKey]
        if not Saved and type(Flags[FlagKey]) == "table" then Saved = Flags[FlagKey].Hex end
        local Parsed = DeserializeConfigColor({Hex = Saved})
        if Parsed then LibraryData.Palette[PaletteKey] = Parsed.Color end
    end
    Config.UiAccentColor = {Color = LibraryData.Palette.Accent, Alpha = 1}
    Config.UiAccent2Color = {Color = LibraryData.Palette.Accent2, Alpha = 1}
    SyncThemeEditorState()
    Config.ConfigName = SelectedName
    Config.SelectedConfig = SelectedName
    LoadLayout()
    SaveGlobalSettings()
    IsConfigLoading = false
    ConfigDirty = false
    return true
end

LoadGlobalSettings()
ApplyThemePreset(Config.ThemePreset or "Nightfall", false)
if Config.AutoLoadConfig then
    LoadNamedConfig(Config.SelectedConfig or Config.ConfigName)
else
    Config.ConfigName = tostring(Config.SelectedConfig or Config.ConfigName or "default")
    LoadLayout()
end
ConfigLoaded = true
Config.RenderBallStats = nil
if Config.ShowWatermark == nil then Config.ShowWatermark = false end
if Config.ShowNotifications == nil then Config.ShowNotifications = true end
Config.NotificationDuration = MathClamp(tonumber(Config.NotificationDuration) or 4, 1, 15)

RegisterKeybind("ParryKeybind", Config.ParryKeybind, Config.ParryBindMode)
RegisterKeybind("SpamKeybind", Config.SpamKeybind, Config.SpamBindMode)
RegisterKeybind("TriggerKeybind", Config.TriggerKeybind, Config.TriggerBindMode)
RegisterKeybind("HideKeybind", Config.HideKeybind, "Toggle")

local WindowDrawings = {
    Shadow = MakeRoundedBox(Color3.new(0, 0, 0), 0.18),
    Outline = MakeRoundedBox(LibraryData.Palette.Outline, 1),
    Background = MakeRoundedBox(LibraryData.Palette.Background, 1),
    Topbar = MakeRoundedBox(LibraryData.Palette.Sidebar, 1),
    Sidebar = MakeRoundedBox(LibraryData.Palette.Sidebar, 1),
    Topline = MakeGradientLine(24),
    PatternBack = MakeStripePattern(28, 11),
    PatternFront = MakeStripePattern(28, 7),
    SidebarLine = CreateDrawing("Square", {Color = LibraryData.Palette.Outline, Filled = true, Visible = false}),
    TopBorder = CreateDrawing("Square", {Color = LibraryData.Palette.Outline, Filled = true, Visible = false}),
    Title = CreateDrawing("Text", {Text = "Nightfall | Recode", Color = LibraryData.Palette.Text, Size = 13, Font = 2, Outline = true, Visible = false}),
    GearOutline = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
    GearBackground = MakeRoundedBox(LibraryData.Palette.Element, 1),
    GearCenter = CreateDrawing("Circle", {Filled = false, Thickness = 2, Radius = 5, NumSides = 24, Color = LibraryData.Palette.Text, Visible = false}),
    GearDot = CreateDrawing("Circle", {Filled = true, Radius = 1.5, NumSides = 12, Color = LibraryData.Palette.Text, Visible = false}),
    GearTeeth = {},
    GearImage = nil
}
for I = 1, 8 do
    WindowDrawings.GearTeeth[I] = CreateDrawing("Line", {Thickness = 2, Color = LibraryData.Palette.Text, Visible = false})
end
local GearIconBase64 = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAYAAABXAvmHAAABCklEQVR42u1Yyw6EMAi0xJuX/v9X9uLZPZlsjKsFphSyzM0YKcNQHi5LIpFIJBQoSGOt7cfT+1q3giZA0RWYTuBNtSEEpIdevzufW9sPqc2iceCa0z1O1LoV5F0hrfzcyGlTRqwA+uAepcJWIXgKWUaf2ytohFG3nZijxB3pEZ16tUyB8x0yJdmMnw7nRFCrpqgKoZxH3qvVU+2fNsxJo4lQIcQ4/ZQJuQ/M7s7hFSgWtZpr32wf8DDMFWRVQHXiaQr0ppzbWUg7jUpUGEbA6j5QZOdZBLwOdoSOSK+tnsXHvApJdgJtYCB94NuJ3r9zdzYlZFTsfx1q+ZudLFPmb8dpt9tUIpFIxMcH8Rigah7ey0AAAAAASUVORK5CYII="
if type(base64decode) == "function" then
    local Ok, Image = pcall(function()
        local Obj = CreateDrawing("Image", {Visible = false, Size = Vector2.new(17, 17), ZIndex = 12})
        Obj.Data = base64decode(GearIconBase64)
        return Obj
    end)
    if Ok then WindowDrawings.GearImage = Image end
end
local RenderDecorations = function() end
local SettingsTab = nil
local PreviousMainTab = nil
local TabStyle = {X = 9, Y = 47, W = 132, H = 34, Gap = 5}
local function GetTabBounds(XVal, YVal, IndexVal)
    local Shown = 0
    for I = 1, IndexVal do
        if LibraryData.Tabs[I] and not LibraryData.Tabs[I].Hidden then Shown = Shown + 1 end
    end
    return Vector2Round(XVal + TabStyle.X, YVal + TabStyle.Y + FastMax(0, Shown - 1) * (TabStyle.H + TabStyle.Gap)), Vector2Round(TabStyle.W, TabStyle.H)
end

local KeybindsDrawings = {
    Outline = MakeRoundedBox(LibraryData.Palette.Outline, 1),
    Background = MakeRoundedBox(LibraryData.Palette.Background, 1),
    Topline = MakeGradientLine(20),
    ToplineCaps = MakeRoundedGradientCaps(),
    HeaderLine = CreateDrawing("Square", {Color = LibraryData.Palette.Outline, Filled = true, Visible = false}),
    TitleIcon = CreateKeybindImageIcon(18),
    Title = CreateDrawing("Text", {Text = "HOTKEYS", Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Subtitle = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Row1 = MakeRoundedBox(LibraryData.Palette.Element, 1), Row2 = MakeRoundedBox(LibraryData.Palette.Element, 1),
    Row3 = MakeRoundedBox(LibraryData.Palette.Element, 1),
    Bind1 = CreateDrawing("Text", {Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind2 = CreateDrawing("Text", {Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind3 = CreateDrawing("Text", {Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State1 = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State2 = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State3 = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Mode1 = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode2 = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode3 = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    MenuOutline = MakeRoundedBox(LibraryData.Palette.Outline, 1),
    MenuBackground = MakeRoundedBox(LibraryData.Palette.Background, 1),
    MenuOption1 = MakeRoundedBox(LibraryData.Palette.Element, 1),
    MenuOption2 = MakeRoundedBox(LibraryData.Palette.Element, 1),
    MenuOption1Text = CreateDrawing("Text", {Text = "Hold", Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    MenuOption2Text = CreateDrawing("Text", {Text = "Toggle", Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local ProfileName = "Player"
local ProfileDisplayName = "Player"
local ProfileUserId = 0
pcall(function()
    ProfileName = tostring(LocalPlayer.Name or "Player")
    ProfileDisplayName = tostring(LocalPlayer.DisplayName or ProfileName)
    ProfileUserId = tonumber(LocalPlayer.UserId) or 0
end)

local function ProfileScrollingName(TextVal, MaxLength)
    local Value = tostring(TextVal or "Player")
    if #Value <= MaxLength then return Value end
    local MaxShift = #Value - MaxLength
    local Period = MaxShift + 10
    local Position = math.floor(FastTick() * 2.3) % Period
    if Position < 4 then return Value:sub(1, MaxLength - 2) .. ".." end
    local Offset = math.min(MaxShift, Position - 4)
    return Value:sub(Offset + 1, Offset + MaxLength)
end

local ProfileDrawings = {
    Divider = CreateDrawing("Square", {Filled = true, Color = LibraryData.Palette.Outline, Visible = false}),
    Border = MakeRoundedBox(LibraryData.Palette.Outline, 1),
    Background = MakeRoundedBox(LibraryData.Palette.Element, 1),
    AvatarBorder = MakeRoundedBox(LibraryData.Palette.Accent, 1),
    AvatarBase = MakeRoundedBox(LibraryData.Palette.Sidebar, 1),
    AvatarFallback = CreateDrawing("Text", {Text = string.upper(string.sub(ProfileName, 1, 1)), Color = LibraryData.Palette.Text, Size = 18, Font = 2, Center = true, Visible = false}),
    Username = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.Text, Size = 11, Font = 2, Visible = false}),
    Caption = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.SubText, Size = 10, Font = 2, Visible = false}),
    Chevron = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Visible = false}),
    PopupBorder = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
    PopupBackground = MakeRoundedBox(LibraryData.Palette.Section, 1),
    PopupAvatarBorder = MakeRoundedBox(LibraryData.Palette.Accent, 1),
    PopupAvatarBase = MakeRoundedBox(LibraryData.Palette.Sidebar, 1),
    PopupFallback = CreateDrawing("Text", {Text = string.upper(string.sub(ProfileName, 1, 1)), Color = LibraryData.Palette.Text, Size = 20, Font = 2, Center = true, Visible = false}),
    PopupName = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.Text, Size = 13, Font = 2, Visible = false}),
    PopupUsername = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Visible = false}),
    PopupID = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Visible = false}),
    HeaderRule = CreateDrawing("Square", {Filled = true, Color = LibraryData.Palette.Outline, Visible = false}),
    CopyBorder = MakeRoundedBox(LibraryData.Palette.Outline, 1),
    CopyBackground = MakeRoundedBox(LibraryData.Palette.Element, 1),
    CopyAccent = CreateDrawing("Square", {Filled = true, Color = LibraryData.Palette.Accent, Visible = false}),
    CopyText = CreateDrawing("Text", {Text = "Copy username", Color = LibraryData.Palette.Text, Size = 11, Font = 2, Center = true, Visible = false}),
    CopyIdBorder = MakeRoundedBox(LibraryData.Palette.Outline, 1),
    CopyIdBackground = MakeRoundedBox(LibraryData.Palette.Element, 1),
    CopyIdAccent = CreateDrawing("Square", {Filled = true, Color = LibraryData.Palette.Accent, Visible = false}),
    CopyIdText = CreateDrawing("Text", {Text = "Copy User ID", Color = LibraryData.Palette.Text, Size = 11, Font = 2, Center = true, Visible = false})
}

local ProfileImage, ProfilePopupImage
local ProfileImageOk, ProfileImageResult = pcall(CreateDrawing, "Image", {Visible = false, Size = Vector2.new(32, 32), Rounding = 5})
if ProfileImageOk then ProfileImage = ProfileImageResult end
local ProfilePopupOk, ProfilePopupResult = pcall(CreateDrawing, "Image", {Visible = false, Size = Vector2.new(44, 44), Rounding = 6})
if ProfilePopupOk then ProfilePopupImage = ProfilePopupResult end
local ProfileHasAvatar = false
local ProfileLayout = {
    CardPos = Vector2.new(0, 0), CardSize = Vector2.new(134, 58),
    PopupPos = Vector2.new(0, 0), PopupSize = Vector2.new(312, 146),
    CopyPos = Vector2.new(0, 0), CopySize = Vector2.new(142, 30),
    CopyIdPos = Vector2.new(0, 0), CopyIdSize = Vector2.new(142, 30)
}

for _, ProfileDraw in pairs(ProfileDrawings) do SetDrawingLayer(ProfileDraw, 45) end
for _, K in ipairs({"Border", "Background", "AvatarBorder", "AvatarBase"}) do
    SetDrawingLayer(ProfileDrawings[K], 45)
end
for _, K in ipairs({"AvatarFallback", "Username", "Caption", "Chevron"}) do
    SetDrawingLayer(ProfileDrawings[K], 47)
end
if ProfileImage then SetDrawingLayer(ProfileImage, 48) end
SetDrawingLayer(ProfileDrawings.PopupBorder, 70)
SetDrawingLayer(ProfileDrawings.PopupBackground, 71)
SetDrawingLayer(ProfileDrawings.PopupAvatarBorder, 72)
SetDrawingLayer(ProfileDrawings.PopupAvatarBase, 73)
SetDrawingLayer(ProfileDrawings.HeaderRule, 74)
for _, K in ipairs({"CopyBorder", "CopyIdBorder"}) do
    SetDrawingLayer(ProfileDrawings[K], 75)
end
for _, K in ipairs({"CopyBackground", "CopyIdBackground"}) do
    SetDrawingLayer(ProfileDrawings[K], 76)
end
for _, K in ipairs({"CopyAccent", "CopyIdAccent"}) do
    SetDrawingLayer(ProfileDrawings[K], 77)
end
for _, K in ipairs({"PopupFallback", "PopupName", "PopupUsername", "PopupID"}) do
    SetDrawingLayer(ProfileDrawings[K], 80)
end
if ProfilePopupImage then SetDrawingLayer(ProfilePopupImage, 81) end
for _, K in ipairs({"CopyText", "CopyIdText"}) do
    SetDrawingLayer(ProfileDrawings[K], 82)
end

local function HideProfileDrawings()
    for _, Obj in pairs(ProfileDrawings) do SetVisible(Obj, false) end
    if ProfileImage then ProfileImage.Visible = false end
    if ProfilePopupImage then ProfilePopupImage.Visible = false end
end

local function UpdateProfileImage(ImageObj, XVal, YVal, SizeVal, RadiusVal, IsVisible)
    if not ImageObj then return end
    ImageObj.Visible = IsVisible and ProfileHasAvatar
    if ImageObj.Visible then
        ImageObj.Position = Vector2Round(XVal, YVal)
        ImageObj.Size = Vector2Round(SizeVal, SizeVal)
        ImageObj.Rounding = RadiusVal
    end
end

local function FetchProfileAvatar()
    if ProfileUserId <= 0 then return end
    if not httpget and not game.HttpGet then return end
    local Cache = _G.NightfallAvatarCache
    if type(Cache) == "table" and Cache.UserId == ProfileUserId and type(Cache.Data) == "string" then
        if ProfileImage and ProfilePopupImage then
            local Success = pcall(function()
                ProfileImage.Data = Cache.Data
                ProfilePopupImage.Data = Cache.Data
            end)
            if Success then ProfileHasAvatar = true return end
        end
    end
    if not task or not task.spawn then return end
    task.spawn(function()
        if task.wait then task.wait(0.15) end
        if not Session.Active then return end
        local Ok, RawImage = pcall(function()
            local RequestURL = "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds=" .. tostring(ProfileUserId) .. "&size=150x150&format=Png&isCircular=false"
            local Response = httpget and httpget(RequestURL) or game:HttpGet(RequestURL)
            if type(Response) ~= "string" or Response == "" then return nil end
            local Result = HttpService:JSONDecode(Response)
            local Item = type(Result) == "table" and type(Result.data) == "table" and Result.data[1] or nil
            local ImageURL = Item and Item.imageUrl
            if type(ImageURL) ~= "string" or not ImageURL:match("^https://[%w%.%-]*rbxcdn%.com/") then return nil end
            return httpget and httpget(ImageURL) or game:HttpGet(ImageURL)
        end)
        if not Ok or type(RawImage) ~= "string" or #RawImage < 128 or not Session.Active then return end
        if not ProfileImage or not ProfilePopupImage then return end
        local ImageOk = pcall(function()
            ProfileImage.Data = RawImage
            ProfilePopupImage.Data = RawImage
        end)
        if ImageOk and Session.Active then
            ProfileHasAvatar = true
            _G.NightfallAvatarCache = {UserId = ProfileUserId, Data = RawImage}
        end
    end)
end

local function DrawProfileCard(PosX, PosY, Width, Height)
    local CardX, CardY, CardW, CardH = PosX + 8, PosY + Height - 70, 134, 58
    local CardPos = Vector2Round(CardX, CardY)
    local CardSize = Vector2Round(CardW, CardH)
    ProfileLayout.CardPos, ProfileLayout.CardSize = CardPos, CardSize
    local Hovered = IsMouseInBounds(LibraryData.Input.MousePos, CardPos, CardSize)
    local Selected = LibraryData.State.ProfileOpen
    ProfileDrawings.Divider.Visible = true
    ProfileDrawings.Divider.Position = Vector2Round(PosX + 10, CardY - 10)
    ProfileDrawings.Divider.Size = Vector2Round(130, 1)
    ProfileDrawings.Divider.Color = LibraryData.Palette.Outline
    UpdateRoundedBox(ProfileDrawings.Border, CardPos, CardSize, 7, (Selected or Hovered) and LibraryData.Palette.OutlineLight or LibraryData.Palette.Outline, 1, true)
    UpdateRoundedBox(ProfileDrawings.Background, Vector2Round(CardX + 1, CardY + 1), Vector2Round(CardW - 2, CardH - 2), 6, Selected and LibraryData.Palette.Hover or LibraryData.Palette.Element, 1, true)
    UpdateRoundedBox(ProfileDrawings.AvatarBorder, Vector2Round(CardX + 8, CardY + 11), Vector2Round(36, 36), 6, LibraryData.Palette.OutlineLight, 1, true)
    UpdateRoundedBox(ProfileDrawings.AvatarBase, Vector2Round(CardX + 9, CardY + 12), Vector2Round(34, 34), 5, LibraryData.Palette.Sidebar, 1, true)
    UpdateProfileImage(ProfileImage, CardX + 10, CardY + 13, 32, 5, true)
    ProfileDrawings.AvatarFallback.Visible = not ProfileHasAvatar
    ProfileDrawings.AvatarFallback.Color = LibraryData.Palette.Text
    PositionText(ProfileDrawings.AvatarFallback, CardX + 26, CardY + 17, "ProfileName")
    ProfileDrawings.Username.Text = ProfileScrollingName(ProfileDisplayName, 11)
    ProfileDrawings.Username.Visible = true
    ProfileDrawings.Username.Color = LibraryData.Palette.Text
    PositionText(ProfileDrawings.Username, CardX + 51, CardY + 13, "ProfileName")
    ProfileDrawings.Caption.Text = ProfileScrollingName("@" .. ProfileName, 11)
    ProfileDrawings.Caption.Visible = true
    ProfileDrawings.Caption.Color = LibraryData.Palette.SubText
    PositionText(ProfileDrawings.Caption, CardX + 51, CardY + 31, "ProfileCaption")
    ProfileDrawings.Chevron.Visible = false

    if not Selected then
        for _, PopupKey in ipairs({"PopupBorder", "PopupBackground", "PopupAvatarBorder", "PopupAvatarBase", "PopupFallback", "PopupName", "PopupUsername", "PopupID", "HeaderRule", "CopyBorder", "CopyBackground", "CopyAccent", "CopyText", "CopyIdBorder", "CopyIdBackground", "CopyIdAccent", "CopyIdText"}) do
            SetVisible(ProfileDrawings[PopupKey], false)
        end
        if ProfilePopupImage then ProfilePopupImage.Visible = false end
        return
    end

    local CameraObj = WorkspaceService.CurrentCamera
    local Viewport = CameraObj and CameraObj.ViewportSize or Vector2.new(1920, 1080)
    local PopupW, PopupH = 312, 149
    local PopupX = MathClamp(PosX + 156, 0, FastMax(0, Viewport.X - PopupW - 4))
    local PopupY = MathClamp(CardY + CardH - PopupH, 4, FastMax(4, Viewport.Y - PopupH - 4))
    ProfileLayout.PopupPos = Vector2Round(PopupX, PopupY)
    ProfileLayout.PopupSize = Vector2Round(PopupW, PopupH)
    UpdateRoundedBox(ProfileDrawings.PopupBorder, ProfileLayout.PopupPos, ProfileLayout.PopupSize, 8, LibraryData.Palette.OutlineLight, 1, true)
    UpdateRoundedBox(ProfileDrawings.PopupBackground, Vector2Round(PopupX + 1, PopupY + 1), Vector2Round(PopupW - 2, PopupH - 2), 7, LibraryData.Palette.Section, 1, true)
    UpdateRoundedBox(ProfileDrawings.PopupAvatarBorder, Vector2Round(PopupX + 13, PopupY + 12), Vector2Round(46, 46), 7, LibraryData.Palette.OutlineLight, 1, true)
    UpdateRoundedBox(ProfileDrawings.PopupAvatarBase, Vector2Round(PopupX + 14, PopupY + 13), Vector2Round(44, 44), 6, LibraryData.Palette.Sidebar, 1, true)
    UpdateProfileImage(ProfilePopupImage, PopupX + 15, PopupY + 14, 42, 6, true)
    ProfileDrawings.PopupFallback.Visible = not ProfileHasAvatar
    ProfileDrawings.PopupFallback.Color = LibraryData.Palette.Text
    PositionText(ProfileDrawings.PopupFallback, PopupX + 36, PopupY + 22, "ProfilePopup")
    ProfileDrawings.PopupName.Text = ProfileDisplayName
    ProfileDrawings.PopupName.Visible = true
    ProfileDrawings.PopupName.Color = LibraryData.Palette.Text
    PositionText(ProfileDrawings.PopupName, PopupX + 72, PopupY + 13, "ProfilePopup")
    ProfileDrawings.PopupUsername.Text = "@" .. ProfileName
    ProfileDrawings.PopupUsername.Visible = true
    ProfileDrawings.PopupUsername.Color = LibraryData.Palette.SubText
    PositionText(ProfileDrawings.PopupUsername, PopupX + 72, PopupY + 33, "ProfilePopup")
    ProfileDrawings.HeaderRule.Visible = true
    ProfileDrawings.HeaderRule.Position = Vector2Round(PopupX + 12, PopupY + 67)
    ProfileDrawings.HeaderRule.Size = Vector2Round(PopupW - 24, 1)
    ProfileDrawings.HeaderRule.Color = LibraryData.Palette.Outline
    ProfileDrawings.PopupID.Text = "User ID  " .. tostring(ProfileUserId)
    ProfileDrawings.PopupID.Visible = true
    ProfileDrawings.PopupID.Color = LibraryData.Palette.SubText
    PositionText(ProfileDrawings.PopupID, PopupX + 14, PopupY + 78, "ProfilePopup")

    local ButtonY, ButtonW, ButtonH = PopupY + 105, 138, 32
    local CopyPos = Vector2Round(PopupX + 12, ButtonY)
    local CopyIdPos = Vector2Round(PopupX + 161, ButtonY)
    local ButtonSize = Vector2Round(ButtonW, ButtonH)
    ProfileLayout.CopyPos, ProfileLayout.CopySize = CopyPos, ButtonSize
    ProfileLayout.CopyIdPos, ProfileLayout.CopyIdSize = CopyIdPos, ButtonSize
    local HoverCopy = IsMouseInBounds(LibraryData.Input.MousePos, CopyPos, ButtonSize)
    local HoverId = IsMouseInBounds(LibraryData.Input.MousePos, CopyIdPos, ButtonSize)
    local ButtonFill = ColorLerp(LibraryData.Palette.Element, LibraryData.Palette.Text, 0.09)
    local ButtonHover = ColorLerp(LibraryData.Palette.Hover, LibraryData.Palette.Accent, 0.16)
    local ButtonOutline = ColorLerp(LibraryData.Palette.OutlineLight, LibraryData.Palette.Text, 0.10)
    local ButtonHoverOutline = ColorLerp(LibraryData.Palette.OutlineLight, LibraryData.Palette.Accent, 0.42)
    UpdateRoundedBox(ProfileDrawings.CopyBorder, CopyPos, ButtonSize, 6, HoverCopy and ButtonHoverOutline or ButtonOutline, 1, true)
    UpdateRoundedBox(ProfileDrawings.CopyBackground, Vector2Round(CopyPos.X + 1, CopyPos.Y + 1), Vector2Round(ButtonW - 2, ButtonH - 2), 5, HoverCopy and ButtonHover or ButtonFill, 1, true)
    UpdateRoundedBox(ProfileDrawings.CopyIdBorder, CopyIdPos, ButtonSize, 6, HoverId and ButtonHoverOutline or ButtonOutline, 1, true)
    UpdateRoundedBox(ProfileDrawings.CopyIdBackground, Vector2Round(CopyIdPos.X + 1, CopyIdPos.Y + 1), Vector2Round(ButtonW - 2, ButtonH - 2), 5, HoverId and ButtonHover or ButtonFill, 1, true)
    ProfileDrawings.CopyAccent.Visible = false
    ProfileDrawings.CopyAccent.Position = Vector2Round(CopyPos.X + 9, CopyPos.Y + 11)
    ProfileDrawings.CopyAccent.Size = Vector2Round(2, 10)
    ProfileDrawings.CopyAccent.Color = LibraryData.Palette.Accent
    ProfileDrawings.CopyIdAccent.Visible = false
    ProfileDrawings.CopyIdAccent.Position = Vector2Round(CopyIdPos.X + 9, CopyIdPos.Y + 11)
    ProfileDrawings.CopyIdAccent.Size = Vector2Round(2, 10)
    ProfileDrawings.CopyIdAccent.Color = LibraryData.Palette.Accent
    ProfileDrawings.CopyText.Text = FastTick() < LibraryData.State.ProfileCopiedUntil and "Copied" or "Copy username"
    ProfileDrawings.CopyText.Visible = true
    ProfileDrawings.CopyText.Color = LibraryData.Palette.Text
    ProfileDrawings.CopyText.Center = true
    PositionTextCentered(ProfileDrawings.CopyText, CopyPos, ButtonSize, "ProfileAction")
    ProfileDrawings.CopyIdText.Text = FastTick() < (LibraryData.State.ProfileIdCopiedUntil or 0) and "Copied" or "Copy User ID"
    ProfileDrawings.CopyIdText.Visible = true
    ProfileDrawings.CopyIdText.Color = LibraryData.Palette.Text
    ProfileDrawings.CopyIdText.Center = true
    PositionTextCentered(ProfileDrawings.CopyIdText, CopyIdPos, ButtonSize, "ProfileAction")
end

function LibraryData:CreateTab(TabName, TabIcon)
    local TabObj = {
        Name = TabName, Icon = "", Sections = {},
        Border = MakeRoundedBox(self.Palette.Outline, 1),
        Background = MakeRoundedBox(self.Palette.Hover, 1),
        RailGlow = MakeRoundedBox(self.Palette.Accent, 0.15),
        Indicator = MakeRoundedBox(self.Palette.Accent, 1),
        Detail = MakeRoundedBox(self.Palette.Accent2, 1),
        Label = CreateDrawing("Text", {Text = TabName, Size = 13, Font = 2, Outline = true, Visible = false}),
        IconDraw = CreateDrawing("Text", {Text = "", Size = 12, Font = 2, Outline = true, Visible = false}),
        CurrentColor = self.Palette.SubText, CurrentIconColor = self.Palette.SubText, BgAlpha = 0
    }
    function TabObj:CreateSection(SectionName, SectionSide)
        local SectionObj = {
            Name = SectionName, Side = SectionSide, Items = {},
            Outline = MakeRoundedBox(LibraryData.Palette.Outline, 1),
            Background = MakeRoundedBox(LibraryData.Palette.Section, 1),
            PatternBack = MakeStripePattern(20, 9), PatternFront = MakeStripePattern(20, 5),
            Title = CreateDrawing("Text", {Text = SectionName, Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
            Line = CreateDrawing("Square", {Color = LibraryData.Palette.Outline, Filled = true, Visible = false})
        }
        function SectionObj:UpdateContainer(XVal, YVal, WVal, HVal)
            UpdateRoundedBox(self.Outline, Vector2Round(XVal, YVal), Vector2Round(WVal, HVal), 6, LibraryData.Palette.Outline, 1, true)
            UpdateRoundedBox(self.Background, Vector2Round(XVal + 1, YVal + 1), Vector2Round(WVal - 2, HVal - 2), 6, LibraryData.Palette.Section, 1, true)
            UpdateStripePattern(self.PatternBack, 0, 0, 0, 0, 0, 0, LibraryData.Palette.Background, false)
            UpdateStripePattern(self.PatternFront, 0, 0, 0, 0, 0, 0, LibraryData.Palette.Background, false)
            self.Title.Visible = true
            PositionText(self.Title, XVal + 10, YVal + 6, "SectionTitle")
            self.Line.Visible = true
            self.Line.Position = Vector2Round(XVal + 10, YVal + 25)
            self.Line.Size = Vector2Round(WVal - 20, 1)
            self.Line.Color = LibraryData.Palette.Outline
        end
        function SectionObj:CreateToggle(NameVal, FlagVal, DefaultVal)
            Config[FlagVal] = Config[FlagVal] ~= nil and Config[FlagVal] or (DefaultVal or false)
            local ToggleObj = {
                Type = "Toggle", Height = 24, Flag = FlagVal,
                BoxStroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                Box = MakeRoundedBox(LibraryData.Palette.Element, 1),
                Fill = MakeRoundedBox(LibraryData.Palette.Accent, 1),
                Label = CreateDrawing("Text", {Text = NameVal, Size = 12, Font = 2, Outline = true, Visible = false}),
                CurrentColor = LibraryData.Palette.SubText,
                Alpha = Config[FlagVal] and 1 or 0,
                HitboxPos = Vector2.new(), HitboxSize = Vector2.new()
            }
            function ToggleObj:Update(XVal, YVal, WVal)
                self.HitboxPos = Vector2Round(XVal, YVal)
                self.HitboxSize = Vector2Round(WVal, 20)
                UpdateRoundedBox(self.BoxStroke, Vector2Round(XVal + 2, YVal + 3), Vector2Round(16, 16), 4, ColorLerp(LibraryData.Palette.Outline, LibraryData.Palette.Accent, self.Alpha), 1, true)
                UpdateRoundedBox(self.Box, Vector2Round(XVal + 3, YVal + 4), Vector2Round(14, 14), 4, LibraryData.Palette.Element, 1, true)
                self.Label.Visible = true
                PositionText(self.Label, XVal + 26, YVal + 4, "ToggleLabel")
                local HoveredVal = IsMouseInBounds(LibraryData.Input.MousePos, self.HitboxPos, self.HitboxSize)
                self.CurrentColor = ColorLerp(self.CurrentColor, Config[self.Flag] and LibraryData.Palette.Text or (HoveredVal and LibraryData.Palette.Text or LibraryData.Palette.SubText), 0.15)
                self.Label.Color = self.CurrentColor
                self.Alpha = MathLerp(self.Alpha, Config[self.Flag] and 1 or 0, 0.2)
                UpdateRoundedBox(self.Fill, Vector2Round(XVal + 5, YVal + 6), Vector2Round(10, 10), 3, LibraryData.Palette.Accent, self.Alpha, self.Alpha > 0.02)
            end
            table.insert(self.Items, ToggleObj)
            return ToggleObj
        end
        function SectionObj:CreateSlider(NameVal, FlagVal, MinVal, MaxVal, DefaultVal, StepVal)
            Config[FlagVal] = Config[FlagVal] ~= nil and Config[FlagVal] or ClampSliderValue(DefaultVal or MinVal, MinVal, MaxVal, StepVal)
            local SliderObj = {
                Type = "Slider", Height = 44, Min = MinVal, Max = MaxVal, Step = StepVal, Flag = FlagVal,
                InputBuffer = FormatSliderValue(Config[FlagVal], StepVal),
                Label = CreateDrawing("Text", {Text = NameVal, Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ValueLabel = CreateDrawing("Text", {Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                Background = MakeRoundedBox(LibraryData.Palette.Element, 1),
                Fill = MakeRoundedBox(LibraryData.Palette.Accent, 1),
                Knob = MakeRoundedBox(LibraryData.Palette.Text, 1),
                ValuePos = Vector2.new(), ValueSize = Vector2.new(), BarPos = Vector2.new(), BarSize = Vector2.new()
            }
            function SliderObj:Update(XVal, YVal, WVal)
                local IsEditing = LibraryData.State.ActiveSliderInput == self
                self.Label.Visible = true
                PositionText(self.Label, XVal + 2, YVal, "SliderLabel")
                local DisplayText = IsEditing and (((FastTick() % 1) < 0.5) and (self.InputBuffer .. "_") or self.InputBuffer) or FormatSliderValue(Config[self.Flag], self.Step)
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = DisplayText
                self.ValueLabel.Color = IsEditing and LibraryData.Palette.Accent or LibraryData.Palette.SubText
                self.ValueSize = Vector2Round(FastMax(34, math.min(70, #DisplayText * 7 + 10)), 18)
                self.ValuePos = Vector2Round(XVal + WVal - self.ValueSize.X - 2, YVal)
                PositionTextCentered(self.ValueLabel, self.ValuePos, self.ValueSize, "SliderValue")
                if not IsEditing then self.InputBuffer = FormatSliderValue(Config[self.Flag], self.Step) end
                local BarY = YVal + 26
                local BarWidth = FastMax(WVal - 4, 30)
                self.BarPos = Vector2Round(XVal + 2, BarY)
                self.BarSize = Vector2Round(BarWidth, 6)
                UpdateRoundedBox(self.Stroke, self.BarPos, self.BarSize, 3, LibraryData.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, Vector2Round(XVal + 3, BarY + 1), Vector2Round(BarWidth - 2, 4), 3, LibraryData.Palette.Element, 1, true)
                local RangeVal = FastMax(self.Max - self.Min, 0.0001)
                local PctVal = MathClamp((Config[self.Flag] - self.Min) / RangeVal, 0, 1)
                local FillW = FastMax((BarWidth - 2) * PctVal, 0)
                UpdateRoundedBox(self.Fill, Vector2Round(XVal + 3, BarY + 1), Vector2Round(FillW, 4), 3, LibraryData.Palette.Accent, 1, FillW > 0)
                UpdateRoundedBox(self.Knob, Vector2Round(XVal + 3 + FillW - 4, BarY - 1), Vector2Round(8, 8), 4, LibraryData.Palette.Text, 1, true)
            end
            table.insert(self.Items, SliderObj)
            return SliderObj
        end
        function SectionObj:CreateDropdown(NameVal, FlagVal, OptionsArray, DefaultVal)
            Config[FlagVal] = Config[FlagVal] ~= nil and Config[FlagVal] or (DefaultVal or OptionsArray[1])
            local DropdownObj = {
                Type = "Dropdown", Height = 46, Options = OptionsArray or {}, Flag = FlagVal,
                IsOpen = false, ListHeight = 0, TargetListHeight = 0, OpenAlpha = 0, HoveredIndex = nil,
                Label = CreateDrawing("Text", {Text = NameVal, Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                Background = MakeRoundedBox(LibraryData.Palette.Element, 1),
                ValueLabel = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                Icon = CreateDrawing("Text", {Text = "+", Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                ListStroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                ListBackground = MakeRoundedBox(LibraryData.Palette.Element, 1),
                OptionDrawings = {}, OptionBounds = {},
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new(), ListPos = Vector2.new(), ListSize = Vector2.new()
            }
            SetDrawingLayer(DropdownObj.ListStroke, 12)
            SetDrawingLayer(DropdownObj.ListBackground, 13)
            function DropdownObj:SetOptions(NewOptions, PreserveValue)
                self.Options = NewOptions or {}
                if not PreserveValue then
                    if #self.Options > 0 then Config[self.Flag] = self.Options[1] else Config[self.Flag] = nil end
                else
                    local FoundVal = false
                    for _, OptionVal in ipairs(self.Options) do
                        if tostring(OptionVal) == tostring(Config[self.Flag]) then FoundVal = true break end
                    end
                    if not FoundVal then
                        if #self.Options > 0 then Config[self.Flag] = self.Options[1] else Config[self.Flag] = nil end
                    end
                end
                self.OptionBounds = {}
                self.HoveredIndex = nil
            end
            function DropdownObj:GetVisibleOptionBounds()
                local ResultArray = {}
                for IndexVal, BoundsVal in ipairs(self.OptionBounds) do
                    if BoundsVal and BoundsVal.Visible then ResultArray[IndexVal] = BoundsVal end
                end
                return ResultArray
            end
            function DropdownObj:Update(XVal, YVal, WVal)
                self.Label.Visible = true
                PositionText(self.Label, XVal + 2, YVal, "DropdownLabel")
                local BarY = YVal + 20
                self.ButtonPos = Vector2Round(XVal + 2, BarY)
                self.ButtonSize = Vector2Round(WVal - 4, 24)
                local ButtonOutlineColor = self.IsOpen and LibraryData.Palette.Accent or LibraryData.Palette.Outline
                local ButtonTextColor = self.IsOpen and LibraryData.Palette.Text or LibraryData.Palette.SubText
                UpdateRoundedBox(self.Stroke, self.ButtonPos, self.ButtonSize, 4, ButtonOutlineColor, 1, true)
                UpdateRoundedBox(self.Background, Vector2Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector2Round(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, LibraryData.Palette.Element, 1, true)
                local CurrentValue = Config[self.Flag]
                local SelectedIndex = nil
                for IdxVal, OptionVal in ipairs(self.Options) do
                    if tostring(OptionVal) == tostring(CurrentValue) then SelectedIndex = IdxVal CurrentValue = OptionVal break end
                end
                if SelectedIndex == nil and #self.Options > 0 then CurrentValue = self.Options[1] Config[self.Flag] = CurrentValue SelectedIndex = 1 end
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = tostring(CurrentValue or "")
                PositionText(self.ValueLabel, self.ButtonPos.X + 6, self.ButtonPos.Y + 5, "DropdownValue")
                self.ValueLabel.Color = ButtonTextColor
                self.Icon.Visible = true
                self.Icon.Text = self.IsOpen and "-" or "+"
                PositionTextCentered(self.Icon, Vector2Round(self.ButtonPos.X + self.ButtonSize.X - 23, self.ButtonPos.Y), Vector2Round(20, self.ButtonSize.Y), "DropdownIcon")
                self.Icon.Color = ButtonTextColor
                self.TargetListHeight = self.IsOpen and (#self.Options * 24 + (#self.Options > 0 and 2 or 0)) or 0
                if not self.IsOpen then
                    self.ListHeight = 0
                    self.OpenAlpha = 0
                end
                self.ListHeight = MathLerp(self.ListHeight, self.TargetListHeight, 0.3)
                if math.abs(self.ListHeight - self.TargetListHeight) < 0.5 then self.ListHeight = self.TargetListHeight end
                self.OpenAlpha = MathLerp(self.OpenAlpha, self.IsOpen and 1 or 0, 0.3)
                if math.abs(self.OpenAlpha - (self.IsOpen and 1 or 0)) < 0.02 then self.OpenAlpha = self.IsOpen and 1 or 0 end
                local DrawListHeight = FastMax(0, MathRound(self.ListHeight))
                local ListVisible = DrawListHeight > 1 and self.OpenAlpha > 0.02
                self.ListPos = Vector2Round(self.ButtonPos.X, self.ButtonPos.Y + self.ButtonSize.Y + 2)
                self.ListSize = Vector2Round(self.ButtonSize.X, DrawListHeight)
                UpdateRoundedBox(self.ListStroke, self.ListPos, self.ListSize, 4, LibraryData.Palette.Outline, self.OpenAlpha, ListVisible)
                UpdateRoundedBox(self.ListBackground, Vector2Round(self.ListPos.X + 1, self.ListPos.Y + 1), Vector2Round(FastMax(self.ListSize.X - 2, 0), FastMax(self.ListSize.Y - 2, 0)), 4, LibraryData.Palette.Element, self.OpenAlpha, ListVisible)
                self.OptionBounds = {}
                self.HoveredIndex = nil
                for IIdx, OptionStr in ipairs(self.Options) do
                    if not self.OptionDrawings[IIdx] then
                        self.OptionDrawings[IIdx] = CreateDrawing("Text", {Text = tostring(OptionStr), Size = 12, Font = 2, Outline = true, Visible = false, ZIndex = 14})
                    end
                    local TxtDraw = self.OptionDrawings[IIdx]
                    local OptionPos = Vector2Round(self.ListPos.X + 6, self.ListPos.Y + 3 + ((IIdx - 1) * 24))
                    local OptionSize = Vector2Round(self.ListSize.X - 12, 20)
                    local OptionBottom = OptionPos.Y + OptionSize.Y
                    local ClipBottom = self.ListPos.Y + DrawListHeight - 2
                    local OptionVisible = ListVisible and OptionPos.Y >= self.ListPos.Y + 1 and OptionBottom <= ClipBottom + 1
                    self.OptionBounds[IIdx] = {Pos = OptionPos, Size = OptionSize, Visible = OptionVisible}
                    if OptionVisible and IsMouseInBounds(LibraryData.Input.MousePos, OptionPos, OptionSize) then self.HoveredIndex = IIdx end
                    TxtDraw.Visible = OptionVisible
                    if OptionVisible then
                        TxtDraw.Text = tostring(OptionStr)
                        PositionText(TxtDraw, OptionPos.X, OptionPos.Y + 3, "DropdownOption")
                        if SelectedIndex == IIdx then TxtDraw.Color = LibraryData.Palette.Accent
                        elseif self.HoveredIndex == IIdx then TxtDraw.Color = LibraryData.Palette.Text
                        else TxtDraw.Color = LibraryData.Palette.SubText
                        end
                        TxtDraw.Transparency = FastMax(self.OpenAlpha, 0.08)
                    end
                end
                for IIdx = #self.Options + 1, #self.OptionDrawings do self.OptionDrawings[IIdx].Visible = false end
                self.Height = 46 + (ListVisible and (DrawListHeight + 4) or 0)
            end
            table.insert(self.Items, DropdownObj)
            return DropdownObj
        end
local PickerImageData = {
    SV = "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",
    Hue = "iVBORw0KGgoAAAANSUhEUgAAAQAAAAABCAYAAAAxWXB3AAAALElEQVR42u3QwQkAIAwEsEjB/ecVSl3Cz4GPLJA1jE2CLo4MfupzIaNKS0m9MSSDAPe+1dgAAAAASUVORK5CYII=",
    Alpha = "iVBORw0KGgoAAAANSUhEUgAAAQAAAAABCAYAAAAxWXB3AAAAGElEQVR42mP8//8/AwMDA+MoHsWjeORhAPTLA/4vSTB6AAAAAElFTkSuQmCC",
    Check = "iVBORw0KGgoAAAANSUhEUgAAAPAAAAAMCAYAAABcBTDwAAAAU0lEQVR42u3YQQ0AIQxFwe5mNVRE/auqCTBQAZCdOZJ/fYHwVNWKQWZOx9HdYW9vf8b+DeBaAgYBAwIGBAx/8fnNs7e/d+8GBk9oQMCAgEHAwPE2wJx22Uh9lVMAAAAASUVORK5CYII=",
}
local PickerImagesCache = {}
local function GetPickerImageData(Name)
    if PickerImagesCache[Name] then return PickerImagesCache[Name] end
    if type(base64decode) ~= "function" then return nil end
    local Success, Data = pcall(base64decode, PickerImageData[Name])
    if not Success or type(Data) ~= "string" or #Data < 40 then return nil end
    PickerImagesCache[Name] = Data
    return Data
end
local function MakePickerImage(Name)
    local Data = GetPickerImageData(Name)
    if not Data then return nil end
    local Success, Obj = pcall(function()
        local Image = CreateDrawing("Image", {Visible = false, ZIndex = 46, Color = Color3.new(1, 1, 1), Transparency = 1, Rounding = Name == "SV" and 3 or 4})
        Image.Data = Data
        return Image
    end)
    if Success then return Obj end
    return nil
end
local function PlacePickerImage(Image, Position, Size, Visible, Tint)
    if not Image then return end
    Image.Visible = Visible and true or false
    if Image.Visible then
        Image.Position = Vector2Round(Position.X, Position.Y)
        Image.Size = Vector2Round(Size.X, Size.Y)
        if Tint then Image.Color = Tint end
        Image.Transparency = 1
    end
end

        function SectionObj:CreateColorPicker(NameVal, FlagVal, DefaultColor, DefaultAlpha, CallbackFunc)
            local InitialColor = DefaultColor or LibraryData.Palette.Accent
            local InitialAlpha = DefaultAlpha == nil and 1 or DefaultAlpha
            if type(Config[FlagVal]) ~= "table" or not Config[FlagVal].Color then
                Config[FlagVal] = {Color = InitialColor, Alpha = MathClamp(InitialAlpha, 0, 1)}
            end
            local HVal, SVal, VVal = Color3ToHsv(Config[FlagVal].Color)
            local ColorPicker = {
                Type = "ColorPicker", Height = 36, Flag = FlagVal, Callback = CallbackFunc,
                IsOpen = false, Hue = HVal, Sat = SVal, Val = VVal,
                Alpha = MathClamp(Config[FlagVal].Alpha or 1, 0, 1),
                HexEditing = false, HexBuffer = "", HexCursor = 0, HexSelectionAll = false,
                SavedColors = {}, SavedBounds = {}, SavedCells = {},
                GridCols = 80, GridRows = 36, HueSteps = 100, AlphaSteps = 64,
                Label = CreateDrawing("Text", {Text = NameVal, Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                Background = MakeRoundedBox(LibraryData.Palette.Element, 1),
                PreviewStroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                Preview = MakeRoundedBox(Config[FlagVal].Color, 1),
                PreviewText = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                PopupShadow = MakeRoundedBox(Color3.new(0, 0, 0), 0.36),
                PopupStroke = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
                PopupBackground = MakeRoundedBox(LibraryData.Palette.Background, 1),
                PopupTitle = CreateDrawing("Text", {Text = "Color", Color = LibraryData.Palette.Text, Font = 2, Size = 13, Outline = true, Visible = false}),
                PopupHint = CreateDrawing("Text", {Text = "", Color = LibraryData.Palette.SubText, Font = 2, Size = 11, Visible = false}),
                PopupRule = CreateDrawing("Square", {Filled = true, Visible = false}),
                PopupSwatchStroke = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
                PopupSwatch = MakeRoundedBox(Config[FlagVal].Color, 1),
                PopupHex = CreateDrawing("Text", {Color = LibraryData.Palette.Text, Size = 11, Outline = true, Visible = false}),
                HexStroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                HexBackground = MakeRoundedBox(LibraryData.Palette.Element, 1),
                SVStroke = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
                HueStroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                AlphaStroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                SVGrid = {}, HueGrid = {}, AlphaGrid = {},
                SVBackground = MakeRoundedBox(Color3.fromRGB(255, 0, 0), 1),
                SVOverlay = MakePickerImage("SV"),
                HueOverlay = MakePickerImage("Hue"),
                AlphaChecker = MakePickerImage("Check"),
                AlphaOverlay = MakePickerImage("Alpha"),
                HueBackground = MakeRoundedBox(LibraryData.Palette.Element, 1),
                AlphaBackground = MakeRoundedBox(LibraryData.Palette.Element, 1),
                CursorOuter = CreateDrawing("Circle", {Filled = false, Thickness = 2, NumSides = 28, Radius = 6, Visible = false}),
                CursorInner = CreateDrawing("Circle", {Filled = false, Thickness = 1, NumSides = 28, Radius = 4, Visible = false}),
                HueCursor = CreateDrawing("Circle", {Filled = true, NumSides = 26, Radius = 5, Visible = false}),
                AlphaCursor = CreateDrawing("Circle", {Filled = true, NumSides = 26, Radius = 5, Visible = false}),
                SavedLabel = CreateDrawing("Text", {Text = "Recent colors", Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Visible = false}),
                SaveButtonBorder = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
                SaveButton = MakeRoundedBox(LibraryData.Palette.Element, 1),
                SaveButtonText = CreateDrawing("Text", {Text = "+", Color = LibraryData.Palette.Text, Size = 15, Font = 2, Center = true, Visible = false}),
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new(),
                PopupPos = Vector2.new(), PopupSize = Vector2.new(),
                SVPos = Vector2.new(), SVSize = Vector2.new(),
                HuePos = Vector2.new(), HueSize = Vector2.new(),
                AlphaPos = Vector2.new(), AlphaSize = Vector2.new(),
                HexPos = Vector2.new(), HexSize = Vector2.new()
            }
            for Index = 1, 6 do
                ColorPicker.SavedCells[Index] = {
                    Outline = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
                    Background = MakeRoundedBox(LibraryData.Palette.Element, 1)
                }
            end
            local RoundedParts = {"PopupShadow", "PopupStroke", "PopupBackground", "PopupSwatchStroke", "PopupSwatch", "HexStroke", "HexBackground", "SVStroke", "HueStroke", "AlphaStroke", "SaveButtonBorder", "SaveButton"}
            local TextParts = {"PopupTitle", "PopupHint", "PopupHex", "PopupRule", "SavedLabel", "SaveButtonText"}
            for _, PartName in ipairs(RoundedParts) do SetDrawingLayer(ColorPicker[PartName], 46) end
            SetDrawingLayer(ColorPicker.PopupShadow, 42)
            SetDrawingLayer(ColorPicker.PopupStroke, 43)
            SetDrawingLayer(ColorPicker.PopupBackground, 44)
            SetDrawingLayer(ColorPicker.SVStroke, 45)
            SetDrawingLayer(ColorPicker.HueStroke, 45)
            SetDrawingLayer(ColorPicker.AlphaStroke, 45)
            for _, PartName in ipairs(TextParts) do SetDrawingLayer(ColorPicker[PartName], 48) end
            for _, PartName in ipairs({"SVBackground", "HueBackground", "AlphaBackground"}) do SetDrawingLayer(ColorPicker[PartName], 46) end
            for _, PartName in ipairs({"SVOverlay", "HueOverlay", "AlphaChecker", "AlphaOverlay"}) do SetDrawingLayer(ColorPicker[PartName], 47) end
            for _, ItemDraw in ipairs(ColorPicker.SVGrid) do SetDrawingLayer(ItemDraw, 46) end
            for _, ItemDraw in ipairs(ColorPicker.HueGrid) do SetDrawingLayer(ItemDraw, 46) end
            for _, ItemDraw in ipairs(ColorPicker.AlphaGrid) do SetDrawingLayer(ItemDraw, 46) end
            for _, SavedCell in ipairs(ColorPicker.SavedCells) do
                SetDrawingLayer(SavedCell.Outline, 47)
                SetDrawingLayer(SavedCell.Background, 48)
            end
            for _, PartName in ipairs({"CursorOuter", "CursorInner", "HueCursor", "AlphaCursor"}) do
                SetDrawingLayer(ColorPicker[PartName], 50)
            end
            function ColorPicker:SyncColor()
                local StateVal = Config[self.Flag]
                if type(StateVal) ~= "table" then StateVal = {} Config[self.Flag] = StateVal end
                StateVal.Color = HsvToColor3(self.Hue, self.Sat, self.Val)
                StateVal.Alpha = MathClamp(self.Alpha, 0, 1)
                if self.Callback then self.Callback(StateVal) end
                QueueSaveConfig()
            end
            function ColorPicker:CommitHex()
                local Cleaned = tostring(self.HexBuffer or ""):upper():gsub("#", ""):gsub("[^0-9A-F]", "")
                if #Cleaned == 0 then
                    self.HexEditing = false
                    self.HexBuffer = ""
                    self.HexCursor = 0
                    self.HexSelectionAll = false
                    return
                end
                if #Cleaned == 6 and Cleaned:match("^%x%x%x%x%x%x$") then
                    local R = tonumber(Cleaned:sub(1, 2), 16)
                    local G = tonumber(Cleaned:sub(3, 4), 16)
                    local B = tonumber(Cleaned:sub(5, 6), 16)
                    if R and G and B then
                        self.Hue, self.Sat, self.Val = Color3ToHsv(Color3.fromRGB(R, G, B))
                        self:SyncColor()
                        self.HexEditing = false
                        self.HexBuffer = ""
                        self.HexCursor = 0
                        self.HexSelectionAll = false
                        return
                    end
                end
                self.HexBuffer = Cleaned:sub(1, 6)
                self.HexCursor = #self.HexBuffer
                self.HexSelectionAll = false
            end
            function ColorPicker:HidePopup()
                if not self.PopupDrawn then return end
                for _, SavedCell in ipairs(self.SavedCells) do
                    SetVisible(SavedCell.Outline, false)
                    SetVisible(SavedCell.Background, false)
                end
                SetVisible(self.SaveButtonBorder, false)
                SetVisible(self.SaveButton, false)
                self.SaveButtonText.Visible = false
                self.SavedLabel.Visible = false
                self.PopupDrawn = false
                self.SVGridHue = nil
                self.SVGridPos = nil
                self.HueGridPos = nil
                self.AlphaGridPos = nil
                for _, PartName in ipairs(RoundedParts) do
                    local Obj = self[PartName]
                    UpdateRoundedBox(Obj, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.Background, 1, false)
                end
                for _, PartName in ipairs(TextParts) do self[PartName].Visible = false end
            for _, PartName in ipairs({"CursorOuter", "CursorInner", "HueCursor", "AlphaCursor"}) do self[PartName].Visible = false end
                HideGridSquares(self.SVGrid)
                HideGridSquares(self.HueGrid)
                HideGridSquares(self.AlphaGrid)
                for _, PartName in ipairs({"SVOverlay", "HueOverlay", "AlphaChecker", "AlphaOverlay"}) do
                    if self[PartName] then self[PartName].Visible = false end
                end
                for _, PartName in ipairs({"SVBackground", "HueBackground", "AlphaBackground"}) do SetVisible(self[PartName], false) end
            end
            function ColorPicker:Update(XVal, YVal, WVal)
                local StateVal = Config[self.Flag]
                local CurrentColor = StateVal and StateVal.Color or HsvToColor3(self.Hue, self.Sat, self.Val)
                local CurrentHex = Color3ToHex(CurrentColor)
                self.Height = 36
                self.Label.Visible = true
                PositionText(self.Label, XVal + 2, YVal + 4, "ColorPickerLabel")
                self.ButtonPos = Vector2Round(XVal + WVal - 91, YVal + 4)
                self.ButtonSize = Vector2.new(87, 24)
                UpdateRoundedBox(self.Stroke, self.ButtonPos, self.ButtonSize, 5, self.IsOpen and LibraryData.Palette.Accent or LibraryData.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, self.ButtonPos + Vector2.new(1, 1), self.ButtonSize - Vector2.new(2, 2), 4, LibraryData.Palette.Element, 1, true)
                UpdateRoundedBox(self.PreviewStroke, self.ButtonPos + Vector2.new(5, 5), Vector2.new(16, 14), 7, LibraryData.Palette.OutlineLight, 1, true)
                UpdateRoundedBox(self.Preview, self.ButtonPos + Vector2.new(6, 6), Vector2.new(14, 12), 6, CurrentColor, 1, true)
                self.PreviewText.Text = CurrentHex
                self.PreviewText.Color = LibraryData.Palette.SubText
                self.PreviewText.Visible = true
                PositionText(self.PreviewText, self.ButtonPos.X + 25, self.ButtonPos.Y + 7, "ColorPickerValue")
                if not self.IsOpen then self:HidePopup() return end
                local Width, Height = 276, 222
                local PopupX = self.ButtonPos.X + self.ButtonSize.X - Width
                local PopupY = self.ButtonPos.Y + self.ButtonSize.Y + 7
                local CameraVal = WorkspaceService.CurrentCamera
                local View = CameraVal and CameraVal.ViewportSize or Vector2.new(1920, 1080)
                if PopupX + Width > View.X - 6 then PopupX = View.X - Width - 6 end
                if PopupX < 6 then PopupX = 6 end
                if PopupY + Height > View.Y - 6 then PopupY = self.ButtonPos.Y - Height - 7 end
                PopupY = MathClamp(PopupY, 6, FastMax(6, View.Y - Height - 6))
                self.PopupPos = Vector2Round(PopupX, PopupY)
                self.PopupSize = Vector2.new(Width, Height)
                self.PopupDrawn = true
                local PX, PY = self.PopupPos.X, self.PopupPos.Y
                UpdateRoundedBox(self.PopupShadow, Vector2.new(PX - 3, PY - 3), Vector2.new(Width + 6, Height + 6), 8, Color3.new(0, 0, 0), 0.26, true)
                UpdateRoundedBox(self.PopupStroke, self.PopupPos, self.PopupSize, 8, LibraryData.Palette.OutlineLight, 1, true)
                UpdateRoundedBox(self.PopupBackground, self.PopupPos + Vector2.new(1, 1), self.PopupSize - Vector2.new(2, 2), 8, ColorLerp(LibraryData.Palette.Background, LibraryData.Palette.Element, 0.28), 1, true)
                self.PopupTitle.Visible = true
                PositionText(self.PopupTitle, PX + 13, PY + 12)
                self.PopupHint.Visible = false
                self.PopupRule.Visible = true
                self.PopupRule.Color = LibraryData.Palette.Outline
                self.PopupRule.Position = Vector2.new(PX + 10, PY + 33)
                self.PopupRule.Size = Vector2.new(Width - 20, 1)
                self.SVPos = Vector2.new(PX + 12, PY + 44)
                self.SVSize = Vector2.new(252, 120)
                UpdateRoundedBox(self.SVStroke, self.SVPos - Vector2.new(1, 1), self.SVSize + Vector2.new(2, 2), 4, LibraryData.Palette.OutlineLight, 1, true)
                UpdateRoundedBox(self.SVBackground, self.SVPos, self.SVSize, 2, HsvToColor3(self.Hue, 1, 1), 1, true)
                PlacePickerImage(self.SVOverlay, self.SVPos, self.SVSize, true)
                if not self.SVOverlay then
                    if #self.SVGrid == 0 then self.SVGrid = CreateGridSquares(self.GridCols * self.GridRows) end
                    if self.SVGridHue ~= self.Hue or self.SVGridPos ~= tostring(PX) .. ":" .. tostring(PY) then
                        UpdateGridSquares(self.SVGrid, self.GridCols, self.GridRows, self.SVPos.X, self.SVPos.Y, self.SVSize.X, self.SVSize.Y, function(Col, Row, Cols, Rows)
                            return HsvToColor3(self.Hue, (Col - 0.5) / Cols, 1 - (Row - 0.5) / Rows)
                        end, true)
                        self.SVGridHue = self.Hue
                        self.SVGridPos = tostring(PX) .. ":" .. tostring(PY)
                    end
                end
                self.HuePos = Vector2.new(PX + 12, PY + 178)
                self.HueSize = Vector2.new(252, 10)
                UpdateRoundedBox(self.HueStroke, self.HuePos - Vector2.new(1, 1), self.HueSize + Vector2.new(2, 2), 3, LibraryData.Palette.Outline, 1, true)
                UpdateRoundedBox(self.HueBackground, self.HuePos, self.HueSize, 2, LibraryData.Palette.Element, 1, true)
                PlacePickerImage(self.HueOverlay, self.HuePos, self.HueSize, true)
                if not self.HueOverlay then
                    if #self.HueGrid == 0 then self.HueGrid = CreateGridSquares(self.HueSteps) end
                    if self.HueGridPos ~= tostring(PX) .. ":" .. tostring(PY) then
                        UpdateGridSquares(self.HueGrid, self.HueSteps, 1, self.HuePos.X, self.HuePos.Y, self.HueSize.X, self.HueSize.Y, function(Col, _, Cols)
                            return HsvToColor3((Col - 0.5) / Cols, 1, 1)
                        end, true)
                        self.HueGridPos = tostring(PX) .. ":" .. tostring(PY)
                    end
                end
                self.AlphaPos = Vector2.new(PX + 12, PY + 200)
                self.AlphaSize = Vector2.new(252, 10)
                UpdateRoundedBox(self.AlphaStroke, self.AlphaPos - Vector2.new(1, 1), self.AlphaSize + Vector2.new(2, 2), 3, LibraryData.Palette.Outline, 1, true)
                UpdateRoundedBox(self.AlphaBackground, self.AlphaPos, self.AlphaSize, 2, LibraryData.Palette.Element, 1, true)
                PlacePickerImage(self.AlphaChecker, self.AlphaPos, self.AlphaSize, true)
                PlacePickerImage(self.AlphaOverlay, self.AlphaPos, self.AlphaSize, true, CurrentColor)
                if not self.AlphaOverlay then
                    if #self.AlphaGrid == 0 then self.AlphaGrid = CreateGridSquares(self.AlphaSteps) end
                    if self.AlphaGridPos ~= tostring(PX) .. ":" .. tostring(PY) or self.AlphaGridHex ~= CurrentHex then
                        UpdateGridSquares(self.AlphaGrid, self.AlphaSteps, 1, self.AlphaPos.X, self.AlphaPos.Y, self.AlphaSize.X, self.AlphaSize.Y, function(Col, _, Cols)
                            return ColorLerp(LibraryData.Palette.Element, CurrentColor, (Col - 0.5) / Cols)
                        end, true)
                        self.AlphaGridPos = tostring(PX) .. ":" .. tostring(PY)
                        self.AlphaGridHex = CurrentHex
                    end
                end
                self.CursorOuter.Visible = true
                self.CursorOuter.Color = Color3.new(0, 0, 0)
                self.CursorOuter.Position = Vector2Round(self.SVPos.X + self.Sat * self.SVSize.X, self.SVPos.Y + (1 - self.Val) * self.SVSize.Y)
                self.CursorOuter.Radius = 6
                self.CursorInner.Visible = true
                self.CursorInner.Color = Color3.new(1, 1, 1)
                self.CursorInner.Position = self.CursorOuter.Position
                self.CursorInner.Radius = 4
                local HX = MathClamp(self.Hue, 0, 1) * (self.HueSize.X - 2)
                local AX = MathClamp(self.Alpha, 0, 1) * (self.AlphaSize.X - 2)
                self.HueCursor.Visible = true
                self.HueCursor.Position = Vector2Round(self.HuePos.X + HX, self.HuePos.Y + self.HueSize.Y / 2)
                self.HueCursor.Radius = 5
                self.HueCursor.Color = LibraryData.Palette.Text
                self.AlphaCursor.Visible = true
                self.AlphaCursor.Position = Vector2Round(self.AlphaPos.X + AX, self.AlphaPos.Y + self.AlphaSize.Y / 2)
                self.AlphaCursor.Radius = 5
                self.AlphaCursor.Color = LibraryData.Palette.Text
                self.HexPos = Vector2.new()
                self.HexSize = Vector2.new()
                self.SavePos, self.SaveSize = nil, nil
                self.PopupHex.Visible = false
                self.SavedLabel.Visible = false
                UpdateRoundedBox(self.HexStroke, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.Outline, 1, false)
                UpdateRoundedBox(self.HexBackground, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.Element, 1, false)
                UpdateRoundedBox(self.PopupSwatchStroke, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.Outline, 1, false)
                UpdateRoundedBox(self.PopupSwatch, Vector2.new(), Vector2.new(), 0, CurrentColor, 1, false)
                UpdateRoundedBox(self.SaveButtonBorder, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.OutlineLight, 1, false)
                UpdateRoundedBox(self.SaveButton, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.Element, 1, false)
                self.SaveButtonText.Visible = false
                for I, SavedCell in ipairs(self.SavedCells) do
                    self.SavedBounds[I] = nil
                    UpdateRoundedBox(SavedCell.Outline, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.OutlineLight, 1, false)
                    UpdateRoundedBox(SavedCell.Background, Vector2.new(), Vector2.new(), 0, LibraryData.Palette.Element, 1, false)
                end
            end
            table.insert(self.Items, ColorPicker)
            return ColorPicker
        end
        function SectionObj:CreateKeybind(NameVal, FlagVal, DefaultVal)
            Config[FlagVal] = NormalizeKeybindValue(Config[FlagVal] ~= nil and Config[FlagVal] or (DefaultVal or "None"))
            local KeybindObj = {
                Type = "Keybind", Height = 30, Flag = FlagVal,
                Icon = CreateKeybindImageIcon(18),
                Label = CreateDrawing("Text", {Text = NameVal, Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonStroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                ButtonBox = MakeRoundedBox(LibraryData.Palette.Element, 1),
                ValueLabel = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new()
            }
            function KeybindObj:Update(XVal, YVal, WVal)
                UpdateKeybindImageIcon(self.Icon, Vector2Round(0, 0), LibraryData.Palette.Accent, false)
                self.Label.Visible = true
                PositionText(self.Label, XVal + 2, YVal + 8, "KeybindLabel")
                local BindValue = NormalizeKeybindValue(Config[self.Flag]) or "None"
                local BindText = LibraryData.State.ActiveKeybind == self and "[...]" or ("[" .. BindValue .. "]")
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = BindText
                local BtnWidth = MathClamp(#BindText * 7 + 20, 74, 108)
                self.ButtonPos = Vector2Round(XVal + WVal - BtnWidth - 2, YVal + 4)
                self.ButtonSize = Vector2Round(BtnWidth, 22)
                local IsActive = LibraryData.State.ActiveKeybind == self
                UpdateKeybindImageIcon(self.Icon, Vector2Round(0, 0), LibraryData.Palette.Accent, false)
                UpdateRoundedBox(self.ButtonStroke, self.ButtonPos, self.ButtonSize, 4, IsActive and LibraryData.Palette.Accent or LibraryData.Palette.Outline, 1, true)
                UpdateRoundedBox(self.ButtonBox, Vector2Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector2Round(BtnWidth - 2, 20), 4, IsActive and LibraryData.Palette.Hover or LibraryData.Palette.Element, 1, true)
                self.ValueLabel.Color = IsActive and LibraryData.Palette.Text or LibraryData.Palette.SubText
                PositionTextCentered(self.ValueLabel, self.ButtonPos, self.ButtonSize, "KeybindValue")
            end
            table.insert(self.Items, KeybindObj)
            return KeybindObj
        end
        function SectionObj:CreateButton(NameVal, CallbackFunc)
            local ButtonObj = {
                Type = "Button", Height = 34, Callback = CallbackFunc,
                Stroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                Background = MakeRoundedBox(LibraryData.Palette.Element, 1),
                Fill = MakeRoundedBox(LibraryData.Palette.Accent, 1),
                HoverMix = 0,
                Accent = CreateDrawing("Square", {Filled = true, Color = LibraryData.Palette.Accent, Visible = false}),
                Label = CreateDrawing("Text", {Text = NameVal, Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new()
            }
            function ButtonObj:Update(XVal, YVal, WVal)
                self.ButtonPos = Vector2Round(XVal + 2, YVal + 4)
                self.ButtonSize = Vector2Round(WVal - 4, 24)
                local HoveredVal = IsMouseInBounds(LibraryData.Input.MousePos, self.ButtonPos, self.ButtonSize)
                UpdateRoundedBox(self.Stroke, self.ButtonPos, self.ButtonSize, 5, HoveredVal and ColorLerp(LibraryData.Palette.OutlineLight, LibraryData.Palette.Accent, 0.36) or LibraryData.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, Vector2Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector2Round(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, HoveredVal and ColorLerp(LibraryData.Palette.Element, LibraryData.Palette.Hover, 0.80) or ColorLerp(LibraryData.Palette.Element, LibraryData.Palette.Background, 0.12), 1, true)
                self.Accent.Visible = false
                self.HoverMix = MathLerp(self.HoverMix, HoveredVal and 1 or 0, 0.23)
                SetVisible(self.Fill, false)
                self.Label.Visible = true
                self.Label.Color = HoveredVal and LibraryData.Palette.Text or ColorLerp(LibraryData.Palette.SubText, LibraryData.Palette.Text, 0.70)
                SetDrawingLayer(self.Label, 7)
                PositionTextCentered(self.Label, self.ButtonPos, self.ButtonSize, "ButtonLabel")
            end
            table.insert(self.Items, ButtonObj)
            return ButtonObj
        end
        function SectionObj:CreateTextbox(NameVal, FlagVal, DefaultVal)
            Config[FlagVal] = Config[FlagVal] ~= nil and Config[FlagVal] or (DefaultVal or "")
            local TextboxObj = {
                Type = "Textbox", Height = 36, Flag = FlagVal, InputBuffer = tostring(Config[FlagVal] or ""), Cursor = 0, SelectionAll = false,
                Label = CreateDrawing("Text", {Text = NameVal, Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(LibraryData.Palette.Outline, 1),
                Background = MakeRoundedBox(LibraryData.Palette.Element, 1),
                ValueLabel = CreateDrawing("Text", {Color = LibraryData.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                BoxPos = Vector2.new(), BoxSize = Vector2.new()
            }
            function TextboxObj:Update(XVal, YVal, WVal)
                self.Label.Visible = true
                PositionText(self.Label, XVal + 2, YVal + 4, "TextboxLabel")
                local BoxWidth = 110
                self.BoxPos = Vector2Round(XVal + WVal - BoxWidth - 2, YVal + 6)
                self.BoxSize = Vector2Round(BoxWidth, 24)
                local IsActive = LibraryData.State.ActiveTextbox == self
                UpdateRoundedBox(self.Stroke, self.BoxPos, self.BoxSize, 4, IsActive and LibraryData.Palette.Accent or LibraryData.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, Vector2Round(self.BoxPos.X + 1, self.BoxPos.Y + 1), Vector2Round(BoxWidth - 2, 22), 4, LibraryData.Palette.Element, 1, true)
                local DisplayStr = IsActive and tostring(self.InputBuffer or "") or tostring(Config[self.Flag] or "")
                local MaxVisible = 15
                if IsActive then
                    local Cursor = MathClamp(self.Cursor or #DisplayStr, 0, #DisplayStr)
                    local Scroll = math.max(0, Cursor - MaxVisible + 1)
                    DisplayStr = DisplayStr:sub(Scroll + 1, Scroll + MaxVisible)
                    if FastTick() % 1 < 0.55 then
                        local Relative = math.min(Cursor - Scroll, #DisplayStr)
                        DisplayStr = DisplayStr:sub(1, Relative) .. "|" .. DisplayStr:sub(Relative + 1)
                    end
                elseif #DisplayStr > MaxVisible then
                    DisplayStr = DisplayStr:sub(1, MaxVisible - 2) .. ".."
                end
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = DisplayStr
                self.ValueLabel.Color = IsActive and LibraryData.Palette.Text or LibraryData.Palette.SubText
                PositionText(self.ValueLabel, XVal + WVal - BoxWidth + 3, YVal + 11, "TextboxValue")
            end
            table.insert(self.Items, TextboxObj)
            return TextboxObj
        end
        table.insert(TabObj.Sections, SectionObj)
        return SectionObj
    end
    table.insert(LibraryData.Tabs, TabObj)
    if not LibraryData.CurrentTab then LibraryData.CurrentTab = TabObj end
    return TabObj
end


local OverlayMenuDrawings = {
    Outline = MakeRoundedBox(LibraryData.Palette.Outline, 1),
    Background = MakeRoundedBox(LibraryData.Palette.Background, 1),
    Option1 = MakeRoundedBox(LibraryData.Palette.Element, 1),
    Option2 = MakeRoundedBox(LibraryData.Palette.Element, 1),
    Option1Mark = CreateDrawing("Square", {Filled = true, Color = LibraryData.Palette.Accent, Visible = false}),
    Option2Mark = CreateDrawing("Square", {Filled = true, Color = LibraryData.Palette.Accent, Visible = false}),
    Option1Text = CreateDrawing("Text", {Text = "Hold", Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = false, Visible = false}),
    Option2Text = CreateDrawing("Text", {Text = "Toggle", Color = LibraryData.Palette.Text, Size = 12, Font = 2, Outline = false, Visible = false})
}

SetDrawingLayer(OverlayMenuDrawings.Outline, 110)
SetDrawingLayer(OverlayMenuDrawings.Background, 111)
SetDrawingLayer(OverlayMenuDrawings.Option1, 112)
SetDrawingLayer(OverlayMenuDrawings.Option2, 112)
SetDrawingLayer(OverlayMenuDrawings.Option1Mark, 113)
SetDrawingLayer(OverlayMenuDrawings.Option2Mark, 113)
SetDrawingLayer(OverlayMenuDrawings.Option1Text, 114)
SetDrawingLayer(OverlayMenuDrawings.Option2Text, 114)

local function CloseTransientUi()
    if LibraryData.State.ActiveDropdown then LibraryData.State.ActiveDropdown.IsOpen = false end
    if LibraryData.State.ActiveColorPicker then LibraryData.State.ActiveColorPicker.IsOpen = false LibraryData.State.ActiveColorPicker.HexEditing = false end
    LibraryData.State.ActiveDropdown = nil
    LibraryData.State.ActiveSlider = nil
    if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) end
    LibraryData.State.ActiveSliderInput = nil
    LibraryData.State.ActiveTextbox = nil
    LibraryData.State.ActiveKeybind = nil
    LibraryData.State.ActiveColorPicker = nil
    LibraryData.State.ActiveColorDrag = nil
    LibraryData.State.Dragging = false
    LibraryData.CaptureLast = nil
    LibraryData.State.HotkeysContext.Open = false
    LibraryData.State.HotkeysContext.Entry = nil
    LibraryData.State.KeybindContext.Open = false
    LibraryData.State.KeybindContext.Entry = nil
    LibraryData.State.ProfileOpen = false
end

local function HideHotkeysDrawings()
    UpdateRoundedBox(KeybindsDrawings.Outline, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(KeybindsDrawings.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    HideRoundedGradient(KeybindsDrawings.Topline, KeybindsDrawings.ToplineCaps)
    KeybindsDrawings.HeaderLine.Visible = false
    UpdateKeybindImageIcon(KeybindsDrawings.TitleIcon, Vector2Round(0, 0), LibraryData.Palette.Accent, false)
    KeybindsDrawings.Title.Visible = false
    KeybindsDrawings.Subtitle.Visible = false
    for _, RowObj in ipairs({KeybindsDrawings.Row1, KeybindsDrawings.Row2, KeybindsDrawings.Row3, KeybindsDrawings.MenuOutline, KeybindsDrawings.MenuBackground, KeybindsDrawings.MenuOption1, KeybindsDrawings.MenuOption2}) do
        UpdateRoundedBox(RowObj, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end
    for _, TxtObj in ipairs({
        KeybindsDrawings.Bind1, KeybindsDrawings.Bind2, KeybindsDrawings.Bind3,
        KeybindsDrawings.State1, KeybindsDrawings.State2, KeybindsDrawings.State3,
        KeybindsDrawings.Mode1, KeybindsDrawings.Mode2, KeybindsDrawings.Mode3,
        KeybindsDrawings.MenuOption1Text, KeybindsDrawings.MenuOption2Text
    }) do
        TxtObj.Visible = false
    end
end

local function SafeHideDrawing(DrawObj)
    if DrawObj then DrawObj.Visible = false end
end

local function HideItem(ItemObj)
    if not ItemObj then return end
    if ItemObj.Type == "Toggle" then
        if ItemObj.BoxStroke then UpdateRoundedBox(ItemObj.BoxStroke, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Box then UpdateRoundedBox(ItemObj.Box, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Fill then UpdateRoundedBox(ItemObj.Fill, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        SafeHideDrawing(ItemObj.Label)
    elseif ItemObj.Type == "Slider" then
        if ItemObj.Stroke then UpdateRoundedBox(ItemObj.Stroke, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Background then UpdateRoundedBox(ItemObj.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Fill then UpdateRoundedBox(ItemObj.Fill, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Knob then UpdateRoundedBox(ItemObj.Knob, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        SafeHideDrawing(ItemObj.Label) SafeHideDrawing(ItemObj.ValueLabel)
    elseif ItemObj.Type == "Dropdown" then
        ItemObj.IsOpen = false ItemObj.ListHeight = 0 ItemObj.TargetListHeight = 0 ItemObj.OpenAlpha = 0
        SafeHideDrawing(ItemObj.Label) SafeHideDrawing(ItemObj.ValueLabel) SafeHideDrawing(ItemObj.Icon)
        if ItemObj.Stroke then UpdateRoundedBox(ItemObj.Stroke, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Background then UpdateRoundedBox(ItemObj.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.ListStroke then UpdateRoundedBox(ItemObj.ListStroke, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.ListBackground then UpdateRoundedBox(ItemObj.ListBackground, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        for _, DrawObj in ipairs(ItemObj.OptionDrawings or {}) do SafeHideDrawing(DrawObj) end
    elseif ItemObj.Type == "ColorPicker" then
        ItemObj.IsOpen = false
        ItemObj.HexEditing = false
        if ItemObj.HidePopup then ItemObj:HidePopup() end
        SafeHideDrawing(ItemObj.Label)
        SafeHideDrawing(ItemObj.PreviewText)
        for _, Name in ipairs({"Stroke", "Background", "PreviewStroke", "Preview"}) do
            if ItemObj[Name] then UpdateRoundedBox(ItemObj[Name], Vector2.new(), Vector2.new(), 0, LibraryData.Palette.Background, 1, false) end
        end
    elseif ItemObj.Type == "Keybind" then
        if ItemObj.Icon then UpdateKeybindImageIcon(ItemObj.Icon, Vector2Round(0, 0), LibraryData.Palette.Accent, false) end
        SafeHideDrawing(ItemObj.Label) SafeHideDrawing(ItemObj.ValueLabel)
        if ItemObj.ButtonStroke then UpdateRoundedBox(ItemObj.ButtonStroke, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.ButtonBox then UpdateRoundedBox(ItemObj.ButtonBox, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
    elseif ItemObj.Type == "Textbox" then
        SafeHideDrawing(ItemObj.Label) SafeHideDrawing(ItemObj.ValueLabel)
        if ItemObj.Stroke then UpdateRoundedBox(ItemObj.Stroke, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Background then UpdateRoundedBox(ItemObj.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
    elseif ItemObj.Type == "Button" then
        SafeHideDrawing(ItemObj.Label)
        SafeHideDrawing(ItemObj.Accent)
        if ItemObj.Stroke then UpdateRoundedBox(ItemObj.Stroke, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if ItemObj.Background then UpdateRoundedBox(ItemObj.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
    end
end

local function HideTabContent(TabObj)
    if not TabObj then return end
    for _, SectionObj in ipairs(TabObj.Sections) do
        UpdateRoundedBox(SectionObj.Outline, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(SectionObj.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        HideStripePattern(SectionObj.PatternBack)
        HideStripePattern(SectionObj.PatternFront)
        SectionObj.Title.Visible = false
        SectionObj.Line.Visible = false
        for _, ItemObj in ipairs(SectionObj.Items) do HideItem(ItemObj) end
    end
end

local HideWindowDrawings
local function ApplyHeldBackspace() end

HideWindowDrawings = function()
    UpdateRoundedBox(WindowDrawings.Shadow, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Outline, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Topbar, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Sidebar, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    HideGradientLine(WindowDrawings.Topline)
    HideStripePattern(WindowDrawings.PatternBack)
    HideStripePattern(WindowDrawings.PatternFront)
    WindowDrawings.SidebarLine.Visible = false
    WindowDrawings.TopBorder.Visible = false
    WindowDrawings.Title.Visible = false
    SetVisible(WindowDrawings.GearOutline, false)
    SetVisible(WindowDrawings.GearBackground, false)
    WindowDrawings.GearCenter.Visible = false
    WindowDrawings.GearDot.Visible = false
    for _, Tooth in ipairs(WindowDrawings.GearTeeth) do Tooth.Visible = false end
    if WindowDrawings.GearImage then WindowDrawings.GearImage.Visible = false end
    HideProfileDrawings()
    for _, ObjVal in pairs(OverlayMenuDrawings) do SetVisible(ObjVal, false) end
    for _, TabObj in ipairs(LibraryData.Tabs) do
        for _, DrawObj in ipairs({TabObj.Border, TabObj.Background, TabObj.RailGlow, TabObj.Indicator, TabObj.Detail}) do
            UpdateRoundedBox(DrawObj, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        TabObj.Label.Visible = false
        TabObj.IconDraw.Visible = false
        HideTabContent(TabObj)
    end
end

local function IsMouseButtonPressed(CodeVal)
    if CodeVal == 4 then
        return iskeypressed and iskeypressed(4) or false
    elseif CodeVal == 5 then
        return iskeypressed and iskeypressed(5) or false
    elseif CodeVal == 6 then
        return iskeypressed and iskeypressed(6) or false
    elseif CodeVal == 7 then
        return iskeypressed and iskeypressed(7) or false
    end
    return false
end

local TextKeyDigits = {
    Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
    Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
    KeypadZero = "0", KeypadOne = "1", KeypadTwo = "2", KeypadThree = "3",
    KeypadFour = "4", KeypadFive = "5", KeypadSix = "6", KeypadSeven = "7",
    KeypadEight = "8", KeypadNine = "9", KeypadPeriod = ".",
    KeypadMinus = "-", Minus = "-", Period = ".", Underscore = "_"
}

local function GetTypedCharacter(KeyCode)
    local KeyName = NormalizeEditKeyName(tostring(KeyCode.Name or ""))
    local KeyValue = KeyCode.Value or 0
    local ShiftState = KeysDown[Enum.KeyCode.LeftShift] or KeysDown[Enum.KeyCode.RightShift]
    if KeyValue >= 65 and KeyValue <= 90 then
        return ShiftState and string.upper(KeyName) or string.lower(KeyName)
    end
    local DigitVal = TextKeyDigits[KeyName]
    if DigitVal then
        if DigitVal == "-" and ShiftState then return "_" end
        return DigitVal
    end
    if KeyValue >= 48 and KeyValue <= 57 then return tostring(KeyValue - 48) end
    if KeyValue >= 96 and KeyValue <= 105 then return tostring(KeyValue - 96) end
    if KeyName == "Space" then return " " end
    return nil
end

local function NormalizeEditKeyName(KeyName)
    KeyName = tostring(KeyName or "")
    if KeyName == "Back" or KeyName == "BackSpace" then return "Backspace" end
    if KeyName == "Del" then return "Delete" end
    if KeyName == "Enter" then return "Return" end
    return KeyName
end

local function CommitTextbox(Box, Cancel)
    if not Box then return end
    if not Cancel then
        local NewText = tostring(Box.InputBuffer or ""):sub(1, 128)
        if Config[Box.Flag] ~= NewText then
            Config[Box.Flag] = NewText
            if Box.OnChanged then pcall(Box.OnChanged, NewText) end
            if Box.Flag == "ConfigName" or Box.Flag == "WatermarkText" then SaveGlobalSettings() else QueueSaveConfig() end
        end
    end
    Box.InputBuffer = tostring(Config[Box.Flag] or "")
    Box.Cursor = #Box.InputBuffer
    Box.SelectionAll = false
    if LibraryData.State.ActiveTextbox == Box then LibraryData.State.ActiveTextbox = nil end
end

local function EditText(Buffer, Cursor, SelectionAll, Key, Character)
    Buffer = tostring(Buffer or "")
    Cursor = MathClamp(tonumber(Cursor) or #Buffer, 0, #Buffer)
    if Key == "Left" then return Buffer, MathClamp(Cursor - 1, 0, #Buffer), false end
    if Key == "Right" then return Buffer, MathClamp(Cursor + 1, 0, #Buffer), false end
    if Key == "Home" then return Buffer, 0, false end
    if Key == "End" then return Buffer, #Buffer, false end
    if Key == "Backspace" or Key == "Delete" then
        if SelectionAll then return "", 0, false end
        if Key == "Backspace" and Cursor > 0 then
            return Buffer:sub(1, Cursor - 1) .. Buffer:sub(Cursor + 1), Cursor - 1, false
        elseif Key == "Delete" and Cursor < #Buffer then
            return Buffer:sub(1, Cursor) .. Buffer:sub(Cursor + 2), Cursor, false
        end
    elseif Character and #Character > 0 then
        if SelectionAll then Buffer = "" Cursor = 0 end
        if #Buffer + #Character <= 128 then
            return Buffer:sub(1, Cursor) .. Character .. Buffer:sub(Cursor + 1), Cursor + #Character, false
        end
    end
    return Buffer, Cursor, false
end

ConnectSession(UserInputService.InputBegan, function(InputObject, GameProcessed)
    local KeyCode = InputObject and InputObject.KeyCode
    if not KeyCode then return end
    if Enum.KeyCode.MouseButton1 and KeyCode == Enum.KeyCode.MouseButton1 then
        LibraryData.Input.Mouse1EventDown = true
        LibraryData.Input.Mouse1ClickQueued = true
        return
    end
    KeysDown[KeyCode] = true
    local EditingPicker = LibraryData.State.ActiveColorPicker
    local ActiveSlider = LibraryData.State.ActiveSliderInput
    local ActiveBox = LibraryData.State.ActiveTextbox
    local EditingHex = EditingPicker and EditingPicker.IsOpen and EditingPicker.HexEditing
    if EditingHex or ActiveSlider or ActiveBox then
        local KeyName = tostring(KeyCode.Name or "")
        local Ctrl = KeysDown[Enum.KeyCode.LeftControl] or KeysDown[Enum.KeyCode.RightControl]
        if KeyCode == Enum.KeyCode.Return or KeyCode == Enum.KeyCode.KeypadEnter then
            if EditingHex then EditingPicker:CommitHex()
            elseif ActiveSlider then CommitSliderInput(ActiveSlider) LibraryData.State.ActiveSliderInput = nil
            else CommitTextbox(ActiveBox, false) end
            return
        elseif KeyCode == Enum.KeyCode.Escape then
            if EditingHex then EditingPicker.HexEditing = false EditingPicker.HexBuffer = ""
            elseif ActiveSlider then LibraryData.State.ActiveSliderInput = nil
            else CommitTextbox(ActiveBox, true) end
            return
        end
        if not LibraryData.Visible then return end
        if Ctrl and KeyName == "A" then
            if ActiveBox then ActiveBox.SelectionAll = true
            elseif EditingHex then EditingPicker.HexSelectionAll = true EditingPicker.HexCursor = #tostring(EditingPicker.HexBuffer or "") end
            return
        end
        if Ctrl and KeyName == "C" and type(setclipboard) == "function" then
            if ActiveBox then pcall(setclipboard, tostring(ActiveBox.InputBuffer or "")) end
            if EditingHex then pcall(setclipboard, tostring(EditingPicker.HexBuffer or "")) end
            return
        end
        if Ctrl and KeyName == "V" then
            local ClipboardReader = type(getclipboard) == "function" and getclipboard or nil
            if ClipboardReader then
                local Success, TextValue = pcall(ClipboardReader)
                if Success and type(TextValue) == "string" then
                    if EditingHex then
                        local CleanHex = TextValue:upper():gsub("#", ""):gsub("[^0-9A-F]", ""):sub(1, 6)
                        if #CleanHex > 0 then
                            EditingPicker.HexBuffer = CleanHex
                            EditingPicker.HexCursor = #CleanHex
                            EditingPicker.HexSelectionAll = false
                        end
                    elseif ActiveBox then
                        local Current = ActiveBox.InputBuffer or ""
                        local Cursor = ActiveBox.Cursor or #Current
                        if ActiveBox.SelectionAll then Current, Cursor = "", 0 end
                        ActiveBox.InputBuffer = Current:sub(1, Cursor) .. TextValue:sub(1, math.max(0, 128 - #Current)) .. Current:sub(Cursor + 1)
                        ActiveBox.Cursor = math.min(128, Cursor + #TextValue)
                        ActiveBox.SelectionAll = false
                    elseif ActiveSlider then
                        ActiveSlider.InputBuffer = TextValue:gsub("[^%d%.%-]", ""):sub(1, 24)
                    end
                end
            end
            return
        end
        if Ctrl then return end
        local CharacterVal = GetTypedCharacter(KeyCode)
        if EditingHex then
            local Buffer = tostring(EditingPicker.HexBuffer or "")
            local Cursor = MathClamp(EditingPicker.HexCursor or #Buffer, 0, #Buffer)
            local SelectAll = EditingPicker.HexSelectionAll == true
            if KeyName == "Left" then
                Cursor = MathClamp(Cursor - 1, 0, #Buffer)
            elseif KeyName == "Right" then
                Cursor = MathClamp(Cursor + 1, 0, #Buffer)
            elseif KeyName == "Home" then
                Cursor = 0
            elseif KeyName == "End" then
                Cursor = #Buffer
            elseif KeyName == "Backspace" or KeyName == "Delete" then
                if SelectAll then
                    Buffer, Cursor = "", 0
                elseif KeyName == "Backspace" and Cursor > 0 then
                    Buffer = Buffer:sub(1, Cursor - 1) .. Buffer:sub(Cursor + 1)
                    Cursor = Cursor - 1
                elseif KeyName == "Delete" and Cursor < #Buffer then
                    Buffer = Buffer:sub(1, Cursor) .. Buffer:sub(Cursor + 2)
                end
            else
                local Character = CharacterVal and CharacterVal:upper() or nil
                if Character and Character:match("^[0-9A-F]$") then
                    if SelectAll then Buffer, Cursor = "", 0 end
                    if #Buffer < 6 then
                        Buffer = Buffer:sub(1, Cursor) .. Character .. Buffer:sub(Cursor + 1)
                        Cursor = Cursor + 1
                    end
                end
            end
            EditingPicker.HexBuffer = Buffer
            EditingPicker.HexCursor = Cursor
            EditingPicker.HexSelectionAll = false
            return
        end
        if ActiveSlider then
            local Buffer = tostring(ActiveSlider.InputBuffer or "")
            if KeyName == "Backspace" then Buffer = Buffer:sub(1, -2)
            elseif CharacterVal and CharacterVal:match("^[0-9%.%-]$") and #Buffer < 24 then Buffer = Buffer .. CharacterVal end
            ActiveSlider.InputBuffer = Buffer
            return
        end
        if ActiveBox then
            ActiveBox.InputBuffer, ActiveBox.Cursor, ActiveBox.SelectionAll = EditText(ActiveBox.InputBuffer, ActiveBox.Cursor, ActiveBox.SelectionAll, KeyName, CharacterVal)
            return
        end
    end
    if GameProcessed or not LibraryData.Visible then return end
    if LibraryData.State.ActiveKeybind then return end
    if KeyCode == Enum.KeyCode.Escape then CloseTransientUi() end
end)

ConnectSession(UserInputService.InputEnded, function(InputObject)
    local KeyCode = InputObject and InputObject.KeyCode
    if Enum.KeyCode.MouseButton1 and KeyCode == Enum.KeyCode.MouseButton1 then
        LibraryData.Input.Mouse1EventDown = false
        LibraryData.Input.Mouse1ReleaseQueued = true
    end
    if KeyCode then KeysDown[KeyCode] = false end
end)

local FrameCounter = 0

ConnectSession(RunService.Heartbeat, function()
    local Now = FastTick()
    if ConfigDirty and Config.AutoSaveConfig and Now - SaveQueueTick > 1.5 then
        SaveCurrentConfig()
    elseif SettingsDirty and Now - SettingsQueueTick > 1.5 then
        SaveGlobalSettings()
    end
end)

ConnectSession(RunService.RenderStepped, function()
    if isrbxactive and not isrbxactive() then
        LibraryData.State.Dragging = false
        LibraryData.State.HotkeysDragging = false
        LibraryData.State.ActiveSlider = nil
        LibraryData.State.ActiveColorDrag = nil
        LibraryData.Input.Mouse1Prev = false
        LibraryData.Input.Mouse1EventDown = false
        LibraryData.Input.Mouse1ClickQueued = false
        LibraryData.Input.Mouse1ReleaseQueued = false
        LibraryData.Input.Mouse2Prev = false
        UpdateKeybinds()
        return
    end

    local MousePos = Vector2.new(LocalMouse.X, LocalMouse.Y)
    LibraryData.Input.MousePos = MousePos
    local PolledMouse1 = ismouse1pressed and ismouse1pressed() or false
    local Mouse1Down = (PolledMouse1 or LibraryData.Input.Mouse1EventDown) and not LibraryData.Input.Mouse1ReleaseQueued
    LibraryData.Input.Mouse1Down = Mouse1Down
    LibraryData.Input.Mouse1Clicked = (Mouse1Down and not LibraryData.Input.Mouse1Prev) or LibraryData.Input.Mouse1ClickQueued
    LibraryData.Input.Mouse1Released = (not Mouse1Down and LibraryData.Input.Mouse1Prev) or LibraryData.Input.Mouse1ReleaseQueued
    LibraryData.Input.Mouse1Prev = Mouse1Down
    LibraryData.Input.Mouse1ClickQueued = false
    LibraryData.Input.Mouse1ReleaseQueued = false
    if LibraryData.Input.Mouse1Clicked and LibraryData.State.ActiveTextbox then
        local Box = LibraryData.State.ActiveTextbox
        if not IsMouseInBounds(LibraryData.Input.MousePos, Box.BoxPos, Box.BoxSize) then
            CommitTextbox(Box, false)
        end
    end

    LibraryData.Input.Mouse2Down = ismouse2pressed and ismouse2pressed() or false
    LibraryData.Input.Mouse2Clicked = LibraryData.Input.Mouse2Down and not LibraryData.Input.Mouse2Prev
    LibraryData.Input.Mouse2Prev = LibraryData.Input.Mouse2Down

    local Mouse4Down = IsMouseButtonPressed(4)
    LibraryData.Input.Mouse4Clicked = Mouse4Down and not LibraryData.Input.Mouse4Prev
    LibraryData.Input.Mouse4Released = not Mouse4Down and LibraryData.Input.Mouse4Prev
    LibraryData.Input.Mouse4Prev = Mouse4Down

    local Mouse5Down = IsMouseButtonPressed(5)
    LibraryData.Input.Mouse5Clicked = Mouse5Down and not LibraryData.Input.Mouse5Prev
    LibraryData.Input.Mouse5Released = not Mouse5Down and LibraryData.Input.Mouse5Prev
    LibraryData.Input.Mouse5Prev = Mouse5Down
    LibraryData.Input.Mouse5Down = Mouse5Down

    UpdateKeybinds()

    do
        local HideCode = NameToCode[NormalizeKeybindValue(Config.HideKeybind)]
        local PressedState = HideCode and iskeypressed(HideCode) or false
        if LibraryData.SuppressHideUntilRelease then
            if not PressedState then LibraryData.SuppressHideUntilRelease = nil end
            PressedState = false
        end
        if LibraryData.State.ActiveKeybind or LibraryData.State.ActiveTextbox or LibraryData.State.ActiveSliderInput then
            PressedState = false
        end
        local WasPressed = LibraryData.LastHidePressed or false

        if PressedState and not WasPressed then
            if not LibraryData.BindPressed then
                LibraryData.Visible = not LibraryData.Visible
                LibraryData.BindPressed = true
                if not LibraryData.Visible then
                    CloseTransientUi()
                    HideWindowDrawings()
                end
            end
        end
        if not PressedState then
            LibraryData.BindPressed = false
        end
        LibraryData.LastHidePressed = PressedState
    end

    ApplyHeldBackspace()

    if LibraryData.State.ActiveKeybind then
        if not LibraryData.CaptureLast then
            LibraryData.CaptureLast = {}
            for CodeVal in pairs(KeyCodes) do
                LibraryData.CaptureLast[CodeVal] = iskeypressed(CodeVal) or false
            end
        end
        local CaptureCode
        for CodeVal in pairs(KeyCodes) do
            local IsPressed = iskeypressed(CodeVal) or false
            if IsPressed and not LibraryData.CaptureLast[CodeVal] and not CaptureCode then CaptureCode = CodeVal end
            LibraryData.CaptureLast[CodeVal] = IsPressed
        end
        if CaptureCode then
            local FlagName = LibraryData.State.ActiveKeybind.Flag
            if CaptureCode == 27 then
                LibraryData.State.ActiveKeybind = nil
            else
                local NameVal = CaptureCode == 8 and "None" or KeyCodes[CaptureCode]
                Config[FlagName] = NameVal
                RegisterKeybind(FlagName, NameVal, GetBindMode(FlagName))
                if FlagName == "HideKeybind" then LibraryData.SuppressHideUntilRelease = true end
                QueueSaveConfig()
                LibraryData.State.ActiveKeybind = nil
            end
            LibraryData.CaptureLast = nil
        end
    else
        LibraryData.CaptureLast = nil
    end

    local HotkeysSize = Vector2.new(220, 120)
    local ShouldShowHotkeys = Config.ShowHotkeyList

    if ShouldShowHotkeys then
        LibraryData.HotkeysPosition = ClampWindowPosition(LibraryData.HotkeysPosition, HotkeysSize)
        if LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, LibraryData.HotkeysPosition, Vector2.new(HotkeysSize.X, 28)) then
            LibraryData.State.HotkeysDragging = true
            LibraryData.State.HotkeysDragStart = LibraryData.Input.MousePos
            LibraryData.State.HotkeysWindowStart = LibraryData.HotkeysPosition
            CloseTransientUi()
        end
        if LibraryData.Input.Mouse1Released and LibraryData.State.HotkeysDragging then
        LibraryData.State.HotkeysDragging = false
        SaveLayout()
    end
        if LibraryData.State.HotkeysDragging then
            LibraryData.HotkeysPosition = ClampWindowPosition(LibraryData.State.HotkeysWindowStart + (LibraryData.Input.MousePos - LibraryData.State.HotkeysDragStart), HotkeysSize)
        end
        local BindsSize = Vector2Round(HotkeysSize.X, HotkeysSize.Y)
        local BindsPos = ClampWindowPosition(Vector2Round(LibraryData.HotkeysPosition.X, LibraryData.HotkeysPosition.Y), BindsSize)
        LibraryData.HotkeysPosition = BindsPos
        UpdateRoundedBox(KeybindsDrawings.Outline, BindsPos, BindsSize, 8, LibraryData.Palette.Outline, 1, true)
        UpdateRoundedBox(KeybindsDrawings.Background, Vector2Round(BindsPos.X + 1, BindsPos.Y + 1), Vector2Round(BindsSize.X - 2, BindsSize.Y - 2), 8, LibraryData.Palette.Background, 1, true)
        UpdateRoundedGradient(KeybindsDrawings.Topline, KeybindsDrawings.ToplineCaps, BindsPos, BindsSize, LibraryData.Palette.Accent, LibraryData.Palette.Accent2, true)
        KeybindsDrawings.HeaderLine.Visible = true
        KeybindsDrawings.HeaderLine.Position = Vector2Round(BindsPos.X + 8, BindsPos.Y + 30)
        KeybindsDrawings.HeaderLine.Size = Vector2Round(BindsSize.X - 16, 1)
        KeybindsDrawings.HeaderLine.Color = LibraryData.Palette.Outline
        UpdateKeybindImageIcon(KeybindsDrawings.TitleIcon, Vector2Round(BindsPos.X + 8, BindsPos.Y + 6), LibraryData.Palette.Accent, false)
        KeybindsDrawings.Title.Visible = true
        PositionText(KeybindsDrawings.Title, BindsPos.X + 8, BindsPos.Y + 6, "HotkeysTitle")
        KeybindsDrawings.Subtitle.Visible = false
        
        local HotkeyEntries = {
            {BindFlag = "ParryKeybind", ToggleFlag = "AutoParry", Label = "Parry"},
            {BindFlag = "SpamKeybind", ToggleFlag = "AutoSpam", Label = "Spam"},
            {BindFlag = "TriggerKeybind", ToggleFlag = "TriggerBot", Label = "Trigger"}
        }
        local RowX = BindsPos.X + 8
        local RowW = BindsSize.X - 16
        local RowH = 20
        local RowStartY = BindsPos.Y + 36
        local RowGap = 4
        local HotkeyRows = {
            {X = RowX, Y = RowStartY, W = RowW, H = RowH, Entry = HotkeyEntries[1]},
            {X = RowX, Y = RowStartY + (RowH + RowGap) * 1, W = RowW, H = RowH, Entry = HotkeyEntries[2]},
            {X = RowX, Y = RowStartY + (RowH + RowGap) * 2, W = RowW, H = RowH, Entry = HotkeyEntries[3]}
        }
        local RowBoxes = {KeybindsDrawings.Row1, KeybindsDrawings.Row2, KeybindsDrawings.Row3}
        local BindTexts = {KeybindsDrawings.Bind1, KeybindsDrawings.Bind2, KeybindsDrawings.Bind3}
        local StateTexts = {KeybindsDrawings.State1, KeybindsDrawings.State2, KeybindsDrawings.State3}
        local ModeTexts = {KeybindsDrawings.Mode1, KeybindsDrawings.Mode2, KeybindsDrawings.Mode3}
        for IIdx, RowVal in ipairs(HotkeyRows) do
            local RowBox = RowBoxes[IIdx]
            local BindDraw = BindTexts[IIdx]
            local StateDraw = StateTexts[IIdx]
            local ModeDraw = ModeTexts[IIdx]
            local BindValue = NormalizeKeybindValue(Config[RowVal.Entry.BindFlag])
            local BindMode = GetBindMode(RowVal.Entry.BindFlag)
            local IsEnabled = Config[RowVal.Entry.ToggleFlag] and true or false
            local RowHovered = IsMouseInBounds(LibraryData.Input.MousePos, Vector2Round(RowVal.X, RowVal.Y), Vector2Round(RowVal.W, RowVal.H))
            local RowColor = IsEnabled and LibraryData.Palette.Hover or (RowHovered and LibraryData.Palette.Hover or LibraryData.Palette.Element)
            UpdateRoundedBox(RowBox, Vector2Round(RowVal.X, RowVal.Y), Vector2Round(RowVal.W, RowVal.H), 4, RowColor, 1, true)
            BindDraw.Visible = true
            BindDraw.Text = "[" .. string.upper(BindValue) .. "]  " .. RowVal.Entry.Label
            BindDraw.Color = IsEnabled and LibraryData.Palette.Text or ColorLerp(LibraryData.Palette.SubText, LibraryData.Palette.Text, RowHovered and 0.35 or 0)
            PositionText(BindDraw, RowVal.X + 8, RowVal.Y + 3, "HotkeysRow")
            local StateColumnW = 30
            local ModeColumnW = 48
            local StateTextX = RowVal.X + RowVal.W - StateColumnW - 6
            local ModeTextX = StateTextX - ModeColumnW - 6
            StateDraw.Visible = true
            StateDraw.Text = IsEnabled and "ON" or "OFF"
            StateDraw.Color = IsEnabled and LibraryData.Palette.Text or LibraryData.Palette.SubText
            PositionText(StateDraw, StateTextX, RowVal.Y + 3, "HotkeysRow")
            ModeDraw.Visible = true
            ModeDraw.Text = string.upper(BindMode)
            ModeDraw.Color = BindMode == "Hold" and LibraryData.Palette.Accent2 or LibraryData.Palette.Accent
            PositionText(ModeDraw, ModeTextX, RowVal.Y + 3, "HotkeysRow")
            if LibraryData.Visible and LibraryData.Input.Mouse2Clicked and RowHovered then
                local BindContext = {ButtonPos = Vector2.new(RowVal.X, RowVal.Y), ButtonSize = Vector2.new(RowVal.W, RowVal.H)}
                LibraryData.State.KeybindContext.Open = true
                LibraryData.State.KeybindContext.Entry = RowVal.Entry
                LibraryData.State.KeybindContext.Position = GetContextMenuPosition(BindContext)
            end
        end
    else
        HideHotkeysDrawings()
        LibraryData.State.HotkeysDragging = false
        LibraryData.State.HotkeysContext.Open = false
        LibraryData.State.HotkeysContext.Entry = nil
    end

    RenderDecorations()
    if not LibraryData.Visible then
        if LibraryData.wasVisible ~= false then
            CloseTransientUi()
            HideWindowDrawings()
            LibraryData.wasVisible = false
        end
        return
    else
        LibraryData.wasVisible = true
    end

    FrameCounter = (FrameCounter or 0) + 1
    local IsInteracting = LibraryData.State.Dragging or 
                           LibraryData.State.HotkeysDragging or 
                           LibraryData.State.ActiveSlider or 
                           LibraryData.State.ActiveColorDrag or 
                           LibraryData.State.ActiveColorPicker or 
                           LibraryData.State.ActiveDropdown or 
                           LibraryData.State.ActiveKeybind or 
                           LibraryData.State.ActiveTextbox

    local SkipHeavyUpdate = (FrameCounter % 2 == 0) and not IsInteracting
    local SizeX, SizeY = LibraryData.Size.X, LibraryData.Size.Y
    
    LibraryData.TargetPosition = ClampWindowPosition(LibraryData.TargetPosition, LibraryData.Size)
    if not LibraryData.State.Dragging then
        LibraryData.Position = ClampWindowPosition(LibraryData.Position, LibraryData.Size)
    end
    local OverHotkeys = Config.ShowHotkeyList and IsMouseInBounds(LibraryData.Input.MousePos, LibraryData.HotkeysPosition, Vector2.new(HotkeysSize.X, 28))
    local GearPos = Vector2Round(LibraryData.Position.X + SizeX - 42, LibraryData.Position.Y + 7)
    local GearSize = Vector2.new(30, 26)
    if LibraryData.Input.Mouse1Clicked and not LibraryData.State.OverlayHit and IsMouseInBounds(LibraryData.Input.MousePos, GearPos, GearSize) then
        CloseTransientUi()
        if SettingsTab and LibraryData.CurrentTab == SettingsTab then
            local Restore = PreviousMainTab
            if not Restore then
                for _, Tab in ipairs(LibraryData.Tabs) do
                    if not Tab.Hidden then Restore = Tab break end
                end
            end
            LibraryData.CurrentTab = Restore
        elseif SettingsTab then
            PreviousMainTab = LibraryData.CurrentTab
            LibraryData.CurrentTab = SettingsTab
        end
        for _, TObj in ipairs(LibraryData.Tabs) do HideTabContent(TObj) end
        LibraryData.Input.Mouse1Clicked = false
    end
    if LibraryData.Input.Mouse1Clicked and not LibraryData.State.ActiveColorPicker and not OverHotkeys and not LibraryData.State.OverlayHit and not LibraryData.State.HotkeysDragging and IsMouseInBounds(LibraryData.Input.MousePos, LibraryData.Position, Vector2.new(SizeX, 36)) then
        CloseTransientUi()
        LibraryData.State.Dragging = true
        LibraryData.State.DragStart = LibraryData.Input.MousePos
        LibraryData.State.WindowStart = LibraryData.TargetPosition
    end
    if LibraryData.Input.Mouse1Released then
        if LibraryData.State.Dragging then SaveLayout() end
        LibraryData.State.Dragging = false
        LibraryData.State.ActiveSlider = nil
    end
    if LibraryData.State.Dragging then
        LibraryData.TargetPosition = ClampWindowPosition(LibraryData.State.WindowStart + (LibraryData.Input.MousePos - LibraryData.State.DragStart), LibraryData.Size)
        LibraryData.Position = LibraryData.TargetPosition
    else
        LibraryData.Position = Vector2.new(MathLerp(LibraryData.Position.X, LibraryData.TargetPosition.X, 0.25), MathLerp(LibraryData.Position.Y, LibraryData.TargetPosition.Y, 0.25))
    end
    
    local PosX, PosY = LibraryData.Position.X, LibraryData.Position.Y
    UpdateRoundedBox(WindowDrawings.Shadow, Vector2Round(PosX - 3, PosY - 3), Vector2Round(SizeX + 6, SizeY + 6), 6, Color3.new(0, 0, 0), 0.18, true)
    UpdateRoundedBox(WindowDrawings.Outline, Vector2Round(PosX - 1, PosY - 1), Vector2Round(SizeX + 2, SizeY + 2), 6, LibraryData.Palette.Outline, 1, true)
    UpdateRoundedBox(WindowDrawings.Background, Vector2Round(PosX, PosY), Vector2Round(SizeX, SizeY), 6, LibraryData.Palette.Background, 1, true)
    UpdateRoundedBox(WindowDrawings.Topbar, Vector2Round(PosX, PosY), Vector2Round(SizeX, 36), 6, LibraryData.Palette.Sidebar, 1, true)
    UpdateRoundedBox(WindowDrawings.Sidebar, Vector2Round(PosX, PosY + 37), Vector2Round(150, SizeY - 37), 6, LibraryData.Palette.Sidebar, 1, true)
    UpdateGradientLine(WindowDrawings.Topline, Vector2Round(PosX + 1, PosY + 1), Vector2Round(SizeX - 2, 2), LibraryData.Palette.Accent, LibraryData.Palette.Accent2, true)
    UpdateStripePattern(WindowDrawings.PatternBack, 0, 0, 0, 0, 0, 0, LibraryData.Palette.Background, false)
    UpdateStripePattern(WindowDrawings.PatternFront, 0, 0, 0, 0, 0, 0, LibraryData.Palette.Background, false)
    WindowDrawings.TopBorder.Visible = true
    WindowDrawings.TopBorder.Position = Vector2Round(PosX, PosY + 36)
    WindowDrawings.TopBorder.Size = Vector2Round(SizeX, 1)
    WindowDrawings.TopBorder.Color = LibraryData.Palette.Outline
    WindowDrawings.SidebarLine.Visible = true
    WindowDrawings.SidebarLine.Position = Vector2Round(PosX + 150, PosY + 37)
    WindowDrawings.SidebarLine.Size = Vector2Round(1, SizeY - 37)
    WindowDrawings.SidebarLine.Color = LibraryData.Palette.Outline
    WindowDrawings.Title.Visible = true
    PositionText(WindowDrawings.Title, PosX + 15, PosY + 11, "WindowTitle")
    local GearPos = Vector2Round(PosX + SizeX - 42, PosY + 7)
    local GearSize = Vector2.new(30, 26)
    local GearHover = IsMouseInBounds(LibraryData.Input.MousePos, GearPos, GearSize)
    local GearSelected = SettingsTab and LibraryData.CurrentTab == SettingsTab
    UpdateRoundedBox(WindowDrawings.GearOutline, GearPos, GearSize, 6, GearSelected and LibraryData.Palette.Accent or (GearHover and LibraryData.Palette.OutlineLight or LibraryData.Palette.Outline), 1, true)
    UpdateRoundedBox(WindowDrawings.GearBackground, GearPos + Vector2.new(1, 1), GearSize - Vector2.new(2, 2), 5, GearSelected and ColorLerp(LibraryData.Palette.Hover, LibraryData.Palette.Accent, 0.12) or (GearHover and LibraryData.Palette.Hover or LibraryData.Palette.Element), 1, true)
    local GX, GY = GearPos.X + 15, GearPos.Y + 13
    local GearColor = GearSelected and LibraryData.Palette.Accent or LibraryData.Palette.Text
    if WindowDrawings.GearImage then
        local Img = WindowDrawings.GearImage
        Img.Visible = true
        Img.Position = Vector2Round(GX - 9, GY - 9)
        Img.Size = Vector2.new(18, 18)
        Img.Color = GearColor
        Img.Transparency = 1
        WindowDrawings.GearCenter.Visible = false
        WindowDrawings.GearDot.Visible = false
        for _, Tooth in ipairs(WindowDrawings.GearTeeth) do Tooth.Visible = false end
    else
        WindowDrawings.GearCenter.Visible = true
        WindowDrawings.GearCenter.Position = Vector2Round(GX, GY)
        WindowDrawings.GearCenter.Color = GearColor
        WindowDrawings.GearDot.Visible = true
        WindowDrawings.GearDot.Position = Vector2Round(GX, GY)
        WindowDrawings.GearDot.Color = GearColor
        for I, Tooth in ipairs(WindowDrawings.GearTeeth) do
            local A = (I - 1) * math.pi / 4
            Tooth.From = Vector2Round(GX + math.cos(A) * 7, GY + math.sin(A) * 7)
            Tooth.To = Vector2Round(GX + math.cos(A) * 9, GY + math.sin(A) * 9)
            Tooth.Color = GearColor
            Tooth.Visible = true
        end
    end

    local ProfileClickUsed = false
    if LibraryData.Input.Mouse1Clicked and not LibraryData.State.OverlayHit then
        local ProfileCardPos = Vector2Round(PosX + 8, PosY + SizeY - 70)
        local ProfileCardSize = Vector2Round(134, 58)
        if IsMouseInBounds(LibraryData.Input.MousePos, ProfileCardPos, ProfileCardSize) then
            local WillOpen = not LibraryData.State.ProfileOpen
            CloseTransientUi()
            LibraryData.State.ProfileOpen = WillOpen
            ProfileClickUsed = true
        elseif LibraryData.State.ProfileOpen and IsMouseInBounds(LibraryData.Input.MousePos, ProfileLayout.PopupPos, ProfileLayout.PopupSize) then
            if IsMouseInBounds(LibraryData.Input.MousePos, ProfileLayout.CopyPos, ProfileLayout.CopySize) then
                local Copied = pcall(function() setclipboard(ProfileName) end)
                if Copied then LibraryData.State.ProfileCopiedUntil = FastTick() + 1.5 end
            elseif IsMouseInBounds(LibraryData.Input.MousePos, ProfileLayout.CopyIdPos, ProfileLayout.CopyIdSize) then
                local Copied = pcall(function() setclipboard(tostring(ProfileUserId)) end)
                if Copied then LibraryData.State.ProfileIdCopiedUntil = FastTick() + 1.5 end
            end
            ProfileClickUsed = true
        elseif LibraryData.State.ProfileOpen then
            LibraryData.State.ProfileOpen = false
        end
    end
    if ProfileClickUsed then LibraryData.Input.Mouse1Clicked = false end

    if LibraryData.Input.Mouse1Clicked and not LibraryData.State.OverlayHit and IsMouseInBounds(LibraryData.Input.MousePos, Vector2.new(PosX, PosY + 37), Vector2.new(150, SizeY - 37)) then
        for TabIndex, TabObj in ipairs(LibraryData.Tabs) do
            local TabPos, TabSize = GetTabBounds(PosX, PosY, TabIndex)
            if not TabObj.Hidden and IsMouseInBounds(LibraryData.Input.MousePos, TabPos, TabSize) then
                if LibraryData.CurrentTab ~= TabObj then
                    LibraryData.CurrentTab = TabObj
                    CloseTransientUi()
                    for _, TObj in ipairs(LibraryData.Tabs) do HideTabContent(TObj) end
                end
                break
            end
        end
    end
    
    local ContextClickConsumed = false
    if LibraryData.State.KeybindContext.Open and LibraryData.State.KeybindContext.Entry and LibraryData.Visible then
        ContextClickConsumed = LibraryData.Input.Mouse1Clicked or LibraryData.Input.Mouse2Clicked
        local MenuPos = LibraryData.State.KeybindContext.Position
        local MenuSize = Vector2.new(128, 66)
        local OptionSize = Vector2.new(118, 24)
        local HoldPos = Vector2Round(MenuPos.X + 5, MenuPos.Y + 6)
        local TogglePos = Vector2Round(MenuPos.X + 5, MenuPos.Y + 35)
        local CurrentMode = GetBindMode(LibraryData.State.KeybindContext.Entry.BindFlag)
        local HoldHovered = IsMouseInBounds(LibraryData.Input.MousePos, HoldPos, OptionSize)
        local ToggleHovered = IsMouseInBounds(LibraryData.Input.MousePos, TogglePos, OptionSize)
        local HoldSelected = CurrentMode == "Hold"
        local ToggleSelected = CurrentMode == "Toggle"
        if LibraryData.Input.Mouse1Clicked then
            if IsMouseInBounds(LibraryData.Input.MousePos, HoldPos, OptionSize) then
                SetBindMode(LibraryData.State.KeybindContext.Entry.BindFlag, "Hold")
                QueueSaveConfig()
                LibraryData.State.KeybindContext.Open = false
                LibraryData.State.KeybindContext.Entry = nil
            elseif IsMouseInBounds(LibraryData.Input.MousePos, TogglePos, OptionSize) then
                SetBindMode(LibraryData.State.KeybindContext.Entry.BindFlag, "Toggle")
                QueueSaveConfig()
                LibraryData.State.KeybindContext.Open = false
                LibraryData.State.KeybindContext.Entry = nil
            elseif not IsMouseInBounds(LibraryData.Input.MousePos, MenuPos, MenuSize) then
                LibraryData.State.KeybindContext.Open = false
                LibraryData.State.KeybindContext.Entry = nil
            end
        elseif LibraryData.Input.Mouse2Clicked and not IsMouseInBounds(LibraryData.Input.MousePos, MenuPos, MenuSize) then
            LibraryData.State.KeybindContext.Open = false
            LibraryData.State.KeybindContext.Entry = nil
        end
        local ContextVisible = LibraryData.State.KeybindContext.Open
        UpdateRoundedBox(OverlayMenuDrawings.Outline, MenuPos, MenuSize, 6, LibraryData.Palette.Outline, 1, ContextVisible)
        UpdateRoundedBox(OverlayMenuDrawings.Background, Vector2Round(MenuPos.X + 1, MenuPos.Y + 1), Vector2Round(MenuSize.X - 2, MenuSize.Y - 2), 6, LibraryData.Palette.Background, 1, ContextVisible)
        UpdateRoundedBox(OverlayMenuDrawings.Option1, HoldPos, OptionSize, 5, HoldSelected and ColorLerp(LibraryData.Palette.Element, LibraryData.Palette.Accent, 0.22) or (HoldHovered and LibraryData.Palette.Hover or LibraryData.Palette.Element), 1, ContextVisible)
        UpdateRoundedBox(OverlayMenuDrawings.Option2, TogglePos, OptionSize, 5, ToggleSelected and ColorLerp(LibraryData.Palette.Element, LibraryData.Palette.Accent, 0.22) or (ToggleHovered and LibraryData.Palette.Hover or LibraryData.Palette.Element), 1, ContextVisible)
        OverlayMenuDrawings.Option1Mark.Visible = ContextVisible and HoldSelected
        OverlayMenuDrawings.Option1Mark.Position = Vector2Round(HoldPos.X + 5, HoldPos.Y + 7)
        OverlayMenuDrawings.Option1Mark.Size = Vector2Round(2, 10)
        OverlayMenuDrawings.Option1Mark.Color = LibraryData.Palette.Accent
        OverlayMenuDrawings.Option2Mark.Visible = ContextVisible and ToggleSelected
        OverlayMenuDrawings.Option2Mark.Position = Vector2Round(TogglePos.X + 5, TogglePos.Y + 7)
        OverlayMenuDrawings.Option2Mark.Size = Vector2Round(2, 10)
        OverlayMenuDrawings.Option2Mark.Color = LibraryData.Palette.Accent
        OverlayMenuDrawings.Option1Text.Visible = ContextVisible
        OverlayMenuDrawings.Option1Text.Text = "Hold"
        OverlayMenuDrawings.Option1Text.Color = (HoldSelected or HoldHovered) and LibraryData.Palette.Text or LibraryData.Palette.SubText
        PositionText(OverlayMenuDrawings.Option1Text, HoldPos.X + 14, HoldPos.Y + 5, "ContextOption")
        OverlayMenuDrawings.Option2Text.Visible = ContextVisible
        OverlayMenuDrawings.Option2Text.Text = "Toggle"
        OverlayMenuDrawings.Option2Text.Color = (ToggleSelected or ToggleHovered) and LibraryData.Palette.Text or LibraryData.Palette.SubText
        PositionText(OverlayMenuDrawings.Option2Text, TogglePos.X + 14, TogglePos.Y + 5, "ContextOption")
    else
        UpdateRoundedBox(OverlayMenuDrawings.Outline, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(OverlayMenuDrawings.Background, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(OverlayMenuDrawings.Option1, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(OverlayMenuDrawings.Option2, Vector2Round(0, 0), Vector2Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        OverlayMenuDrawings.Option1Text.Visible = false
        OverlayMenuDrawings.Option2Text.Visible = false
        OverlayMenuDrawings.Option1Mark.Visible = false
        OverlayMenuDrawings.Option2Mark.Visible = false
    end
    
    if LibraryData.CurrentTab then
        local BlockInput = LibraryData.State.Dragging or LibraryData.State.KeybindContext.Open or ContextClickConsumed
        if LibraryData.State.ActiveDropdown then
            local DropdownObj = LibraryData.State.ActiveDropdown
            if LibraryData.Input.Mouse1Clicked then
                local MousePos = LibraryData.Input.MousePos
                local InsideCurrentButton = IsMouseInBounds(MousePos, DropdownObj.ButtonPos, DropdownObj.ButtonSize)
                local ClickedDropdown = nil
                for _, SectionObj in ipairs(LibraryData.CurrentTab.Sections) do
                    for _, CandidateObj in ipairs(SectionObj.Items) do
                        if CandidateObj.Type == "Dropdown" and IsMouseInBounds(MousePos, CandidateObj.ButtonPos, CandidateObj.ButtonSize) then
                            ClickedDropdown = CandidateObj break
                        end
                    end
                    if ClickedDropdown then break end
                end
                if ClickedDropdown then
                    if ClickedDropdown == DropdownObj then
                        DropdownObj.IsOpen = false
                        LibraryData.State.ActiveDropdown = nil
                    else
                        DropdownObj.IsOpen = false
                        ClickedDropdown.IsOpen = true
                        ClickedDropdown.OpenAlpha = 0
                        ClickedDropdown.ListHeight = 0
                        ClickedDropdown.TargetListHeight = 0
                        LibraryData.State.ActiveDropdown = ClickedDropdown
                    end
                    BlockInput = true
                else
                    local PickedOption = nil
                    for IndexVal, BoundsVal in ipairs(DropdownObj.OptionBounds or {}) do
                        if BoundsVal and BoundsVal.Visible and IsMouseInBounds(MousePos, BoundsVal.Pos, BoundsVal.Size) then
                            PickedOption = IndexVal break
                        end
                    end
                    if PickedOption and DropdownObj.Options[PickedOption] ~= nil then
                        Config[DropdownObj.Flag] = DropdownObj.Options[PickedOption]
                        if DropdownObj.Flag == "ThemePreset" then
                            ApplyThemePreset(Config[DropdownObj.Flag], false)
                        elseif DropdownObj.Flag == "SelectedConfig" then
                            Config.SelectedConfig = tostring(Config[DropdownObj.Flag])
                            Config.ConfigName = Config.SelectedConfig
                            LoadNamedConfig(Config.SelectedConfig)
                        else
                            QueueSaveConfig()
                        end
                        DropdownObj.IsOpen = false
                        LibraryData.State.ActiveDropdown = nil
                        BlockInput = true
                    else
                        local InsideList = DropdownObj.IsOpen and IsMouseInBounds(MousePos, DropdownObj.ListPos, DropdownObj.ListSize)
                        if not InsideCurrentButton and not InsideList then
                            DropdownObj.IsOpen = false
                            LibraryData.State.ActiveDropdown = nil
                            BlockInput = true
                        elseif InsideCurrentButton then
                            DropdownObj.IsOpen = false
                            LibraryData.State.ActiveDropdown = nil
                            BlockInput = true
                        end
                    end
                end
            elseif LibraryData.Input.Mouse2Clicked then
                DropdownObj.IsOpen = false
                LibraryData.State.ActiveDropdown = nil
                BlockInput = true
            end
        end
        if LibraryData.State.ActiveColorPicker then
            local PickerObj = LibraryData.State.ActiveColorPicker
            if LibraryData.Input.Mouse1Clicked then
                local MP = LibraryData.Input.MousePos
                local InsideButton = IsMouseInBounds(MP, PickerObj.ButtonPos, PickerObj.ButtonSize)
                local InsidePopup = PickerObj.IsOpen and IsMouseInBounds(MP, PickerObj.PopupPos, PickerObj.PopupSize)
                if InsideButton then
                    PickerObj.IsOpen = false
                    PickerObj.HexEditing = false
                    PickerObj:HidePopup()
                    LibraryData.State.ActiveColorPicker = nil
                    LibraryData.State.ActiveColorDrag = nil
                    BlockInput = true
                elseif InsidePopup then
                    if IsMouseInBounds(MP, PickerObj.SVPos, PickerObj.SVSize) then
                        LibraryData.State.ActiveColorDrag = "SV"
                    elseif IsMouseInBounds(MP, PickerObj.HuePos, PickerObj.HueSize) then
                        LibraryData.State.ActiveColorDrag = "Hue"
                    elseif IsMouseInBounds(MP, PickerObj.AlphaPos, PickerObj.AlphaSize) then
                        LibraryData.State.ActiveColorDrag = "Alpha"
                    end
                    BlockInput = true
                else
                    PickerObj.HexEditing = false
                    PickerObj.IsOpen = false
                    PickerObj:HidePopup()
                    LibraryData.State.ActiveColorPicker = nil
                    LibraryData.State.ActiveColorDrag = nil
                end
            end
            if PickerObj.IsOpen and IsMouseInBounds(LibraryData.Input.MousePos, PickerObj.PopupPos, PickerObj.PopupSize) then
                BlockInput = true
            end
        end
        if LibraryData.State.ActiveSliderInput and LibraryData.Input.Mouse1Clicked then
            local ActiveInput = LibraryData.State.ActiveSliderInput
            local ClickedValue = IsMouseInBounds(LibraryData.Input.MousePos, ActiveInput.ValuePos, ActiveInput.ValueSize)
            if not ClickedValue then
                CommitSliderInput(ActiveInput)
                LibraryData.State.ActiveSliderInput = nil
            end
        end
        if not BlockInput then
            for _, SectionObj in ipairs(LibraryData.CurrentTab.Sections) do
                for _, ItemObj in ipairs(SectionObj.Items) do
                    if ItemObj.Type == "Toggle" then
                        if LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.HitboxPos, ItemObj.HitboxSize) then
                            if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) LibraryData.State.ActiveSliderInput = nil end
                            Config[ItemObj.Flag] = not Config[ItemObj.Flag]
                            if FireChange then FireChange(ItemObj) end
                            if ItemObj.Flag == "AutoSaveConfig" or ItemObj.Flag == "AutoLoadConfig" or ItemObj.Flag == "ShowWatermark" or ItemObj.Flag == "ShowNotifications" or ItemObj.Flag == "WatermarkCompact" then
                                SaveGlobalSettings()
                                if Config.AutoSaveConfig then SaveCurrentConfig() end
                            else
                                QueueSaveConfig()
                            end
                        end
                    elseif ItemObj.Type == "Slider" then
                        if LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.ValuePos, ItemObj.ValueSize) then
                            if LibraryData.State.ActiveSliderInput and LibraryData.State.ActiveSliderInput ~= ItemObj then CommitSliderInput(LibraryData.State.ActiveSliderInput) end
                            LibraryData.State.ActiveSliderInput = ItemObj
                            ItemObj.InputBuffer = FormatSliderValue(Config[ItemObj.Flag], ItemObj.Step)
                            LibraryData.State.ActiveSlider = nil
                            LibraryData.State.ActiveTextbox = nil
                            LibraryData.State.ActiveKeybind = nil
                        elseif LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.BarPos - Vector2.new(0, 4), ItemObj.BarSize + Vector2.new(0, 8)) then
                            if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) LibraryData.State.ActiveSliderInput = nil end
                            LibraryData.State.ActiveSlider = ItemObj
                        end
                    elseif ItemObj.Type == "Dropdown" then
                        if LibraryData.Input.Mouse1Clicked and not LibraryData.State.ActiveDropdown and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.ButtonPos, ItemObj.ButtonSize) then
                            if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) LibraryData.State.ActiveSliderInput = nil end
                            if LibraryData.State.ActiveColorPicker then LibraryData.State.ActiveColorPicker.IsOpen = false LibraryData.State.ActiveColorPicker = nil end
                            ItemObj.IsOpen = true ItemObj.OpenAlpha = 0 ItemObj.ListHeight = 0 ItemObj.TargetListHeight = 0
                            LibraryData.State.ActiveDropdown = ItemObj
                            BlockInput = true
                        end
                    elseif ItemObj.Type == "ColorPicker" then
                        if LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.ButtonPos, ItemObj.ButtonSize) then
                            if LibraryData.State.ActiveColorPicker and LibraryData.State.ActiveColorPicker ~= ItemObj then
                                LibraryData.State.ActiveColorPicker.IsOpen = false
                                LibraryData.State.ActiveColorPicker.HexEditing = false
                            end
                            if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) LibraryData.State.ActiveSliderInput = nil end
                            ItemObj.IsOpen = true
                            ItemObj.HexEditing = false
                            LibraryData.State.ActiveColorPicker = ItemObj
                            LibraryData.State.ActiveColorDrag = nil
                            LibraryData.State.ActiveKeybind = nil
                            LibraryData.State.ActiveTextbox = nil
                            LibraryData.State.ActiveDropdown = nil
                            BlockInput = true
                        end
                    elseif ItemObj.Type == "Keybind" then
                        if LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.ButtonPos, ItemObj.ButtonSize) then
                            LibraryData.State.ActiveKeybind = ItemObj
                            LibraryData.CaptureLast = {}
                            for CodeVal in pairs(KeyCodes) do
                                LibraryData.CaptureLast[CodeVal] = iskeypressed(CodeVal) or false
                            end
                        if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) LibraryData.State.ActiveSliderInput = nil end
                            LibraryData.State.ActiveTextbox = nil
                            if LibraryData.State.ActiveColorPicker then LibraryData.State.ActiveColorPicker.IsOpen = false LibraryData.State.ActiveColorPicker = nil end
                            LibraryData.State.HotkeysContext.Open = false LibraryData.State.HotkeysContext.Entry = nil
                            LibraryData.State.KeybindContext.Open = false LibraryData.State.KeybindContext.Entry = nil
                        elseif LibraryData.Input.Mouse2Clicked and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.ButtonPos, ItemObj.ButtonSize) then
                            LibraryData.State.ActiveKeybind = nil
                            if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) LibraryData.State.ActiveSliderInput = nil end
                            LibraryData.State.ActiveTextbox = nil
                            LibraryData.State.KeybindContext.Open = true
                            LibraryData.State.KeybindContext.Entry = {BindFlag = ItemObj.Flag, Label = ItemObj.Label and ItemObj.Label.Text or "Bind", Item = ItemObj}
                            local ContextPos = GetContextMenuPosition(ItemObj)
                            LibraryData.State.KeybindContext.Position = Vector2.new(ContextPos.X, ContextPos.Y)
                        end
                    elseif ItemObj.Type == "Button" then
                        if LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.ButtonPos, ItemObj.ButtonSize) then
                            if ItemObj.Callback then ItemObj.Callback() end
                        end
                    elseif ItemObj.Type == "Textbox" then
                        if LibraryData.Input.Mouse1Clicked then
                            if IsMouseInBounds(LibraryData.Input.MousePos, ItemObj.BoxPos, ItemObj.BoxSize) then
                                if LibraryData.State.ActiveTextbox and LibraryData.State.ActiveTextbox ~= ItemObj then CommitTextbox(LibraryData.State.ActiveTextbox, false) end
                            LibraryData.State.ActiveTextbox = ItemObj
                                ItemObj.InputBuffer = tostring(Config[ItemObj.Flag] or "")
                                ItemObj.Cursor = #ItemObj.InputBuffer
                                ItemObj.SelectionAll = false
                                LibraryData.State.ActiveKeybind = nil
                                if LibraryData.State.ActiveSliderInput then CommitSliderInput(LibraryData.State.ActiveSliderInput) LibraryData.State.ActiveSliderInput = nil end
                                if LibraryData.State.ActiveColorPicker then LibraryData.State.ActiveColorPicker.IsOpen = false LibraryData.State.ActiveColorPicker = nil end
                                LibraryData.State.KeybindContext.Open = false LibraryData.State.KeybindContext.Entry = nil
                            elseif LibraryData.State.ActiveTextbox == ItemObj then
                                CommitTextbox(ItemObj, false)
                            end
                        end
                    end
                end
            end
        end
    end
    
    if not LibraryData.Input.Mouse1Down then LibraryData.State.ActiveColorDrag = nil end
    if LibraryData.State.ActiveColorPicker and LibraryData.State.ActiveColorDrag then
        local PickerObj = LibraryData.State.ActiveColorPicker
        if LibraryData.State.ActiveColorDrag == "SV" and PickerObj.SVPos and PickerObj.SVSize then
            PickerObj.Sat = MathClamp((LibraryData.Input.MousePos.X - PickerObj.SVPos.X) / PickerObj.SVSize.X, 0, 1)
            PickerObj.Val = 1 - MathClamp((LibraryData.Input.MousePos.Y - PickerObj.SVPos.Y) / PickerObj.SVSize.Y, 0, 1)
            PickerObj:SyncColor()
        elseif LibraryData.State.ActiveColorDrag == "Hue" and PickerObj.HuePos and PickerObj.HueSize then
            PickerObj.Hue = MathClamp((LibraryData.Input.MousePos.X - PickerObj.HuePos.X) / PickerObj.HueSize.X, 0, 1)
            PickerObj:SyncColor()
        elseif LibraryData.State.ActiveColorDrag == "Alpha" and PickerObj.AlphaPos and PickerObj.AlphaSize then
            PickerObj.Alpha = MathClamp((LibraryData.Input.MousePos.X - PickerObj.AlphaPos.X) / PickerObj.AlphaSize.X, 0, 1)
            PickerObj:SyncColor()
        end
    end
    
    if LibraryData.State.ActiveSlider and LibraryData.State.ActiveSlider.BarSize then
        local SliderObj = LibraryData.State.ActiveSlider
        if LibraryData.Input.Mouse1Down then
            local LeftVal = SliderObj.BarPos.X
            local WidthVal = FastMax(SliderObj.BarSize.X, 1)
            local PercentageVal = MathClamp((LibraryData.Input.MousePos.X - LeftVal) / WidthVal, 0, 1)
            Config[SliderObj.Flag] = ClampSliderValue(SliderObj.Min + (PercentageVal * (SliderObj.Max - SliderObj.Min)), SliderObj.Min, SliderObj.Max, SliderObj.Step)
            QueueSaveConfig()
        else
            LibraryData.State.ActiveSlider = nil
        end
    end
    
    for TabIndex, TabObj in ipairs(LibraryData.Tabs) do
        local IsCurrent = TabObj == LibraryData.CurrentTab
        local TabPos, TabSize = GetTabBounds(PosX, PosY, TabIndex)
        local IsHovered = not TabObj.Hidden and IsMouseInBounds(LibraryData.Input.MousePos, TabPos, TabSize)
        if TabObj.Hidden then
            for _, DrawObj in ipairs({TabObj.Border, TabObj.Background, TabObj.RailGlow, TabObj.Indicator, TabObj.Detail}) do SetVisible(DrawObj, false) end
            TabObj.Label.Visible = false
            TabObj.IconDraw.Visible = false
        end
        local AlphaTarget = IsCurrent and 1 or (IsHovered and 0.38 or 0)
        TabObj.BgAlpha = MathLerp(TabObj.BgAlpha, AlphaTarget, 0.20)
        local CardColor = ColorLerp(LibraryData.Palette.Sidebar, LibraryData.Palette.Hover, TabObj.BgAlpha * 0.57)
        local BorderColor = LibraryData.Palette.Outline
        UpdateRoundedBox(TabObj.Border, TabPos, TabSize, 6, BorderColor, IsCurrent and 0.44 or (IsHovered and 0.22 or 0), not TabObj.Hidden and (IsCurrent or IsHovered))
        UpdateRoundedBox(TabObj.Background, Vector2Round(TabPos.X + 1, TabPos.Y + 1), Vector2Round(TabSize.X - 2, TabSize.Y - 2), 5, CardColor, 1, not TabObj.Hidden)
        UpdateRoundedBox(TabObj.RailGlow, TabPos, Vector2Round(0, 0), 0, LibraryData.Palette.Accent, 0, false)
        UpdateRoundedBox(TabObj.Indicator, Vector2Round(TabPos.X + 3, TabPos.Y + 9), Vector2Round(2, TabSize.Y - 18), 1, LibraryData.Palette.Accent, 1, IsCurrent and not TabObj.Hidden)
        UpdateRoundedBox(TabObj.Detail, TabPos, Vector2Round(0, 0), 0, LibraryData.Palette.Accent2, 0, false)
        TabObj.CurrentColor = ColorLerp(TabObj.CurrentColor, IsCurrent and LibraryData.Palette.Text or (IsHovered and ColorLerp(LibraryData.Palette.SubText, LibraryData.Palette.Text, 0.65) or LibraryData.Palette.SubText), 0.23)
        TabObj.IconDraw.Visible = false
        TabObj.Label.Visible = not TabObj.Hidden
        if not TabObj.Hidden then PositionText(TabObj.Label, TabPos.X + 15, TabPos.Y + 10, "SidebarTab") end
        TabObj.Label.Color = TabObj.CurrentColor
        if not IsCurrent then
            HideTabContent(TabObj)
        end
        if IsCurrent and not SkipHeavyUpdate then
            local ColWidth = (SizeX - 150 - 30) / 2
            local LeftY, RightY = PosY + 46, PosY + 46
            for _, SectionObj in ipairs(TabObj.Sections) do
                local SectionX = SectionObj.Side == "Left" and (PosX + 160) or (PosX + 160 + ColWidth + 10)
                local SectionY = SectionObj.Side == "Left" and LeftY or RightY
                local ItemY = SectionY + 32
                for _, ItemObj in ipairs(SectionObj.Items) do
                    ItemObj:Update(SectionX + 8, ItemY, ColWidth - 16)
                    ItemY = ItemY + ItemObj.Height
                end
                SectionObj:UpdateContainer(SectionX, SectionY, ColWidth, ItemY - SectionY + 6)
                if SectionObj.Side == "Left" then LeftY = ItemY + 16 else RightY = ItemY + 16 end
            end
        end

        if not IsCurrent then
            for _, SectionObj in ipairs(TabObj.Sections) do
                SetVisible(SectionObj.Outline, false)
                SetVisible(SectionObj.Background, false)
                HideStripePattern(SectionObj.PatternBack)
                HideStripePattern(SectionObj.PatternFront)
                SectionObj.Title.Visible = false
                SectionObj.Line.Visible = false
                for _, ItemObj in ipairs(SectionObj.Items) do
                    if ItemObj.Label then ItemObj.Label.Visible = false end
                    if ItemObj.ValueLabel then ItemObj.ValueLabel.Visible = false end
                    if ItemObj.Icon then UpdateKeybindImageIcon(ItemObj.Icon, Vector2Round(-1000, -1000), LibraryData.Palette.Text, false) end
                    if ItemObj.IconDraw then ItemObj.IconDraw.Visible = false end
                    if ItemObj.BoxStroke then SetVisible(ItemObj.BoxStroke, false) end
                    if ItemObj.Box then SetVisible(ItemObj.Box, false) end
                    if ItemObj.Fill then SetVisible(ItemObj.Fill, false) end
                    if ItemObj.Stroke then SetVisible(ItemObj.Stroke, false) end
                    if ItemObj.Background then SetVisible(ItemObj.Background, false) end
                    if ItemObj.Knob then SetVisible(ItemObj.Knob, false) end
                    if ItemObj.Accent then ItemObj.Accent.Visible = false end
                    if ItemObj.ListStroke then SetVisible(ItemObj.ListStroke, false) end
                    if ItemObj.ListBackground then SetVisible(ItemObj.ListBackground, false) end
                    if ItemObj.ButtonStroke then SetVisible(ItemObj.ButtonStroke, false) end
                    if ItemObj.ButtonBox then SetVisible(ItemObj.ButtonBox, false) end
                    if ItemObj.OptionDrawings then
                        for _, OptionDrawing in pairs(ItemObj.OptionDrawings) do OptionDrawing.Visible = false end
                    end
                    if ItemObj.PreviewStroke then SetVisible(ItemObj.PreviewStroke, false) end
                    if ItemObj.Preview then SetVisible(ItemObj.Preview, false) end
                    if ItemObj.PopupStroke then SetVisible(ItemObj.PopupStroke, false) end
                    if ItemObj.SavedCells then
                        for _, Cell in ipairs(ItemObj.SavedCells) do SetVisible(Cell.Outline, false) SetVisible(Cell.Background, false) end
                    end
                    if ItemObj.SaveButton then SetVisible(ItemObj.SaveButton, false) end
                    if ItemObj.SaveButtonBorder then SetVisible(ItemObj.SaveButtonBorder, false) end
                    if ItemObj.SaveButtonText then ItemObj.SaveButtonText.Visible = false end
                    if ItemObj.SavedLabel then ItemObj.SavedLabel.Visible = false end
                    if ItemObj.PopupBackground then SetVisible(ItemObj.PopupBackground, false) end
                    if ItemObj.PopupSwatchStroke then SetVisible(ItemObj.PopupSwatchStroke, false) end
                    if ItemObj.PopupSwatch then SetVisible(ItemObj.PopupSwatch, false) end
                    if ItemObj.SVStroke then SetVisible(ItemObj.SVStroke, false) end
                    if ItemObj.HueStroke then SetVisible(ItemObj.HueStroke, false) end
                    if ItemObj.SVGrid then HideGridSquares(ItemObj.SVGrid) end
                    for _, PickerImage in ipairs({"SVOverlay", "HueOverlay", "AlphaChecker", "AlphaOverlay"}) do
                        if ItemObj[PickerImage] then ItemObj[PickerImage].Visible = false end
                    end
                    for _, PickerBox in ipairs({"SVBackground", "HueBackground", "AlphaBackground"}) do
                        if ItemObj[PickerBox] then SetVisible(ItemObj[PickerBox], false) end
                    end
                    if ItemObj.HueGrid then HideGridSquares(ItemObj.HueGrid) end
                    if ItemObj.CursorOuter then ItemObj.CursorOuter.Visible = false end
                    if ItemObj.CursorInner then ItemObj.CursorInner.Visible = false end
                    if ItemObj.HueLine then ItemObj.HueLine.Visible = false end
                    if ItemObj.HueCapTop then ItemObj.HueCapTop.Visible = false end
                    if ItemObj.HueCapBottom then ItemObj.HueCapBottom.Visible = false end
                    if ItemObj.PopupHex then ItemObj.PopupHex.Visible = false end
                end
            end
        end
    end
    DrawProfileCard(PosX, PosY, SizeX, SizeY)
end)


FireChange = function(ItemObj)
    if ItemObj and type(ItemObj.OnChanged) == "function" then
        pcall(ItemObj.OnChanged, Config[ItemObj.Flag])
    end
end

local NightfallLibrary = {
    Name = "Nightfall",
    Version = "1.0.16",
    Config = Config,
    Flags = Config,
    State = LibraryData,
    Runtime = RuntimeState,
    Session = Session,
    TextOffsets = TextOffsets,
    Palette = LibraryData.Palette,
    Connect = ConnectSession,
    SaveConfig = SaveCurrentConfig,
    LoadConfig = LoadNamedConfig,
    DeleteConfig = DeleteNamedConfig,
    ListConfigs = GetAvailableConfigs,
    SaveLayout = SaveLayout,
    LoadLayout = LoadLayout,
    ApplyTheme = ApplyThemePreset,
    RegisterKeybind = RegisterKeybind,
    SetBindMode = SetBindMode,
    GetBindMode = GetBindMode
}

function NightfallLibrary:SaveConfig()
    return SaveCurrentConfig()
end

function NightfallLibrary:LoadConfig(Name)
    return LoadNamedConfig(Name)
end

function NightfallLibrary:DeleteConfig(Name)
    return DeleteNamedConfig(Name)
end

function NightfallLibrary:ListConfigs()
    return GetAvailableConfigs()
end

function NightfallLibrary:SaveLayout()
    return SaveLayout()
end

function NightfallLibrary:LoadLayout()
    return LoadLayout()
end

function NightfallLibrary:ApplyTheme(Name, KeepAccent)
    ApplyThemePreset(Name, KeepAccent)
    return self
end

function NightfallLibrary:RegisterKeybind(Flag, Key, Mode)
    return RegisterKeybind(Flag, Key, Mode)
end

function NightfallLibrary:SetBindMode(Flag, Mode)
    return SetBindMode(Flag, Mode)
end

function NightfallLibrary:GetBindMode(Flag)
    return GetBindMode(Flag)
end

function NightfallLibrary:SaveSettings()
    return SaveGlobalSettings()
end

function NightfallLibrary:LoadSettings()
    return LoadGlobalSettings()
end

NightfallLibrary.Modules = {
    Configuration = {
        Save = SaveCurrentConfig,
        Load = LoadNamedConfig,
        Delete = DeleteNamedConfig,
        List = GetAvailableConfigs,
        SaveSettings = SaveGlobalSettings,
        LoadSettings = LoadGlobalSettings
    },
    Layout = {Save = SaveLayout, Load = LoadLayout, ClampPosition = ClampWindowPosition},
    Drawing = {Create = CreateDrawing, RoundedBox = MakeRoundedBox, UpdateRoundedBox = UpdateRoundedBox},
    Colors = {FromHsv = HsvToColor3, ToHsv = Color3ToHsv, ToHex = Color3ToHex},
    Keybinds = {Register = RegisterKeybind, SetMode = SetBindMode, GetMode = GetBindMode}
}

local UiNotifications = {}
WatermarkSettings = {Segments = {"Nightfall", "Matcha"}, Position = PendingWatermarkPosition or Vector2.new(18, 18), Visible = Config.ShowWatermark == true}
local WatermarkDraw = {
    Border = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
    Background = MakeRoundedBox(LibraryData.Palette.Background, 1),
    Labels = {},
    Dividers = {}
}
SetDrawingLayer(WatermarkDraw.Border, 140)
SetDrawingLayer(WatermarkDraw.Background, 141)
for Index = 1, 5 do
    local Label = CreateDrawing("Text", {
        Text = "", FontSize = 12, Font = Drawing.Fonts and Drawing.Fonts.System or 2,
        Color = LibraryData.Palette.Text, Outline = false, Visible = false
    })
    SetDrawingLayer(Label, 143)
    WatermarkDraw.Labels[Index] = Label
end
for Index = 1, 4 do
    local Divider = CreateDrawing("Square", {Filled = true, Transparency = 1, Visible = false})
    SetDrawingLayer(Divider, 142)
    WatermarkDraw.Dividers[Index] = Divider
end

local function MeasureWatermarkText(Value)
    local Width = 0
    for Index = 1, #Value do
        local Character = Value:sub(Index, Index)
        if Character == " " then
            Width = Width + 3.4
        elseif Character:find("[ilI1|!%.,:;']") then
            Width = Width + 3.5
        elseif Character:find("[MW@#%%]") then
            Width = Width + 9
        elseif Character:find("[A-Z0-9]") then
            Width = Width + 7
        else
            Width = Width + 6.1
        end
    end
    return math.floor(Width + 0.5)
end

local function ParseWatermarkSegments()
    local Caption = tostring(Config.WatermarkText or "")
    if Caption == "" then Caption = table.concat(WatermarkSettings.Segments, " | ") end
    local Segments = {}
    for Part in Caption:gmatch("[^|/]+") do
        local Clean = Part:match("^%s*(.-)%s*$")
        if Clean ~= "" then
            table.insert(Segments, Clean:sub(1, 32))
            if #Segments == 5 then break end
        end
    end
    if #Segments == 0 then Segments[1] = "Nightfall" end
    return Segments
end

local WatermarkDrag = {Active = false, StartMouse = Vector2.new(0, 0), StartPosition = Vector2.new(0, 0)}

local function HideNotification(Entry)
    SetVisible(Entry.Border, false)
    SetVisible(Entry.Background, false)
    SetVisible(Entry.Progress, false)
    Entry.Title.Visible = false
    Entry.Description.Visible = false
end

local function DeleteNotification(Entry)
    HideNotification(Entry)
    for _, Shape in ipairs({Entry.Border, Entry.Background, Entry.Progress}) do
        for _, Part in pairs(Shape) do
            if Part then pcall(function() Part:Remove() end) end
        end
    end
    pcall(function() Entry.Title:Remove() end)
    pcall(function() Entry.Description:Remove() end)
end

function NightfallLibrary:Notification(Options)
    if Config.ShowNotifications == false then return nil end
    if type(Options) == "string" then Options = {Title = "Nightfall", Description = Options} end
    Options = Options or {}
    if #UiNotifications >= 5 then
        DeleteNotification(table.remove(UiNotifications, 1))
    end
    local Entry = {
        TitleText = tostring(Options.Title or "Nightfall"):sub(1, 42),
        MessageText = tostring(Options.Description or Options.Message or ""):sub(1, 64),
        Time = FastTick(), Duration = MathClamp(tonumber(Options.Duration) or Config.NotificationDuration or 4, 0.5, 20),
        Border = MakeRoundedBox(LibraryData.Palette.OutlineLight, 1),
        Background = MakeRoundedBox(LibraryData.Palette.Section, 1),
        Progress = MakeRoundedBox(LibraryData.Palette.Accent, 1),
        Title = CreateDrawing("Text", {Size = 13, Font = 2, Outline = true, Visible = false}),
        Description = CreateDrawing("Text", {Size = 12, Font = 2, Visible = false})
    }
    for _, Shape in ipairs({Entry.Border, Entry.Background}) do SetDrawingLayer(Shape, 151) end
    SetDrawingLayer(Entry.Progress, 152)
    SetDrawingLayer(Entry.Title, 154)
    SetDrawingLayer(Entry.Description, 154)
    table.insert(UiNotifications, Entry)
    return Entry
end
NightfallLibrary.Notify = NightfallLibrary.Notification

function NightfallLibrary:Watermark(Options)
    if Options == false then
        WatermarkSettings.Visible = false
        Config.ShowWatermark = false
        SaveGlobalSettings()
        return self
    end
    if Options == nil then Options = WatermarkSettings.Segments end
    if type(Options) == "string" then Options = {Options} end
    if type(Options) == "table" then
        if Options.Position and typeof(Options.Position) == "Vector2" then WatermarkSettings.Position = Options.Position end
        local Data = Options.Segments or Options
        if #Data > 0 then
            WatermarkSettings.Segments = {}
            for Index = 1, math.min(5, #Data) do
                table.insert(WatermarkSettings.Segments, tostring(Data[Index]):sub(1, 28))
            end
            Config.WatermarkText = table.concat(WatermarkSettings.Segments, " | ")
        elseif type(Options.Text) == "string" then
            Config.WatermarkText = Options.Text
        end
    end
    WatermarkSettings.Visible = true
    Config.ShowWatermark = true
    if type(Options) == "string" then Config.WatermarkText = Options end
    SaveGlobalSettings()
    return self
end

local function UpdateNotifications()
    if Config.ShowNotifications == false then
        for _, Entry in ipairs(UiNotifications) do HideNotification(Entry) end
        return
    end
    local Now = FastTick()
    local Camera = WorkspaceService.CurrentCamera
    local View = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    for I = #UiNotifications, 1, -1 do
        if Now - UiNotifications[I].Time > UiNotifications[I].Duration + 0.3 then
            DeleteNotification(UiNotifications[I])
            table.remove(UiNotifications, I)
        end
    end
    local Width, Height, Gap = 258, 63, 9
    for I, Entry in ipairs(UiNotifications) do
        local Elapsed = Now - Entry.Time
        local Remaining = MathClamp(1 - Elapsed / Entry.Duration, 0, 1)
        local Enter = MathClamp(Elapsed / 0.20, 0, 1)
        local Exit = MathClamp((Entry.Duration + 0.3 - Elapsed) / 0.30, 0, 1)
        local Alpha = math.min(Enter, Exit)
        local OnLeft = Config.NotificationPosition == "Top Left"
        local X = OnLeft and math.floor(16 - (1 - Alpha) * (Width + 20)) or math.floor(View.X - Width - 16 + (1 - Alpha) * (Width + 20))
        local Y = 18 + (I - 1) * (Height + Gap)
        UpdateRoundedBox(Entry.Border, Vector2.new(X, Y), Vector2.new(Width, Height), 7, LibraryData.Palette.OutlineLight, Alpha, true)
        UpdateRoundedBox(Entry.Background, Vector2.new(X + 1, Y + 1), Vector2.new(Width - 2, Height - 2), 6, LibraryData.Palette.Section, Alpha, true)
        UpdateRoundedBox(Entry.Progress, Vector2.new(X + 8, Y + Height - 6), Vector2.new(math.max(0, (Width - 16) * Remaining), 2), 1, LibraryData.Palette.Accent, Alpha, Remaining > 0.005)
        Entry.Title.Text = Entry.TitleText
        Entry.Title.Color = LibraryData.Palette.Text
        Entry.Title.Visible = true
        PositionText(Entry.Title, X + 13, Y + 10)
        Entry.Title.Transparency = Alpha
        Entry.Description.Text = Entry.MessageText
        Entry.Description.Color = LibraryData.Palette.SubText
        Entry.Description.Visible = Entry.MessageText ~= ""
        PositionText(Entry.Description, X + 13, Y + 31)
        Entry.Description.Transparency = Alpha
    end
end

local function UpdateWatermark()
    local Enabled = Config.ShowWatermark and WatermarkSettings.Visible
    if not Enabled then
        SetVisible(WatermarkDraw.Border, false)
        SetVisible(WatermarkDraw.Background, false)
        for _, Label in ipairs(WatermarkDraw.Labels) do Label.Visible = false end
        for _, Divider in ipairs(WatermarkDraw.Dividers) do Divider.Visible = false end
        WatermarkDrag.Active = false
        return
    end

    local Camera = WorkspaceService.CurrentCamera
    local Viewport = Camera and Camera.ViewportSize or Vector2.new(1920, 1080)
    local Segments = ParseWatermarkSegments()
    local Height = Config.WatermarkCompact and 29 or 35
    local InnerPadding = 13
    local DividerGap = 12
    local MaxWidth = math.max(100, Viewport.X - 20)
    local Width = InnerPadding * 2
    local SegmentWidths = {}

    for Index, Text in ipairs(Segments) do
        SegmentWidths[Index] = MeasureWatermarkText(Text)
        Width = Width + SegmentWidths[Index]
        if Index > 1 then Width = Width + DividerGap * 2 + 1 end
    end

    while Width > MaxWidth do
        local Changed = false
        for Index = #Segments, 1, -1 do
            if #Segments[Index] > 4 then
                local Previous = SegmentWidths[Index]
                Segments[Index] = Segments[Index]:sub(1, -2)
                SegmentWidths[Index] = MeasureWatermarkText(Segments[Index])
                Width = Width - (Previous - SegmentWidths[Index])
                Changed = true
                if Width <= MaxWidth then break end
            end
        end
        if not Changed then break end
    end

    local Size = Vector2.new(math.min(Width, MaxWidth), Height)
    WatermarkSettings.Position = ClampWindowPosition(WatermarkSettings.Position, Size)
    local Position = WatermarkSettings.Position

    if LibraryData.Input.Mouse1Clicked and IsMouseInBounds(LibraryData.Input.MousePos, Position, Size) then
        WatermarkDrag.Active = true
        WatermarkDrag.StartMouse = LibraryData.Input.MousePos
        WatermarkDrag.StartPosition = Position
        LibraryData.Input.Mouse1Clicked = false
    end
    if LibraryData.Input.Mouse1Released or not LibraryData.Input.Mouse1Down then
        if WatermarkDrag.Active then SaveLayout() end
        WatermarkDrag.Active = false
    end
    if WatermarkDrag.Active then
        Position = ClampWindowPosition(WatermarkDrag.StartPosition + (LibraryData.Input.MousePos - WatermarkDrag.StartMouse), Size)
        WatermarkSettings.Position = Position
    end

    UpdateRoundedBox(WatermarkDraw.Border, Position, Size, 6, LibraryData.Palette.OutlineLight, 1, true)
    UpdateRoundedBox(WatermarkDraw.Background, Position + Vector2.new(1, 1), Size - Vector2.new(2, 2), 5, LibraryData.Palette.Background, 1, true)

    local Cursor = Position.X + InnerPadding
    for Index, Label in ipairs(WatermarkDraw.Labels) do
        local Text = Segments[Index]
        Label.Visible = Text ~= nil
        if Text then
            Label.Text = Text
            Label.Color = Index == 1 and LibraryData.Palette.Text or LibraryData.Palette.SubText
            Label.Transparency = 1
            PositionText(Label, Cursor, Position.Y + (Height - 12) / 2 - 1)
            Cursor = Cursor + SegmentWidths[Index]
            if Index < #Segments then
                local Divider = WatermarkDraw.Dividers[Index]
                Divider.Position = Vector2Round(Cursor + DividerGap, Position.Y + (Height - 12) / 2)
                Divider.Size = Vector2.new(1, 12)
                Divider.Color = LibraryData.Palette.OutlineLight
                Divider.Transparency = 1
                Divider.Visible = true
                Cursor = Cursor + DividerGap * 2 + 1
            end
        end
    end
    for Index = #Segments, #WatermarkDraw.Dividers do
        WatermarkDraw.Dividers[Index].Visible = false
    end
end

RenderDecorations = function()
    UpdateNotifications()
    UpdateWatermark()
end

function NightfallLibrary:Size(Width, Height)
    if type(Width) == "table" or typeof(Width) == "Vector2" then
        Height = Width.Y or Width.Height or Width[2]
        Width = Width.X or Width.Width or Width[1]
    end
    Width = tonumber(Width) or LibraryData.Size.X
    Height = tonumber(Height) or LibraryData.Size.Y
    Width = math.max(560, math.floor(Width + 0.5))
    Height = math.max(380, math.floor(Height + 0.5))
    LibraryData.Size = Vector2.new(Width, Height)
    LibraryData.Position = ClampWindowPosition(LibraryData.Position, LibraryData.Size)
    LibraryData.TargetPosition = ClampWindowPosition(LibraryData.TargetPosition, LibraryData.Size)
    return self
end
NightfallLibrary.size = NightfallLibrary.Size

function NightfallLibrary:Visible(Value)
    if Value == nil then return LibraryData.Visible end
    LibraryData.Visible = Value and true or false
    if not LibraryData.Visible then
        CloseTransientUi()
        HideWindowDrawings()
    end
    return self
end

function NightfallLibrary:Set(Flag, Value)
    Config[Flag] = Value
    if Flag == "ShowWatermark" and WatermarkSettings then WatermarkSettings.Visible = Value == true end
    if Flag == "ThemePreset" then ApplyThemePreset(Value, false) end
    if Flag == "WatermarkText" and type(Value) ~= "string" then Config.WatermarkText = tostring(Value) end
    if Flag == "HideKeybind" or Flag == "ParryKeybind" or Flag == "SpamKeybind" or Flag == "TriggerKeybind" then
        RegisterKeybind(Flag, Value, GetBindMode(Flag))
    end
    QueueSaveConfig()
    SaveGlobalSettings()
    return self
end

function NightfallLibrary:Get(Flag)
    return Config[Flag]
end

local function WrapControl(ControlObj, Flag, Callback)
    if not ControlObj then return nil end
    ControlObj.OnChanged = Callback
    function ControlObj:Get()
        return Config[Flag]
    end
    function ControlObj:Set(Value, Silent)
        if self.Type == "Slider" then
            Value = ClampSliderValue(tonumber(Value) or self.Min, self.Min, self.Max, self.Step)
            self.InputBuffer = FormatSliderValue(Value, self.Step)
        elseif self.Type == "Keybind" then
            Value = NormalizeKeybindValue(Value)
            RegisterKeybind(Flag, Value, GetBindMode(Flag))
        elseif self.Type == "ColorPicker" and type(Value) == "table" and Value.Color then
            self.Hue, self.Sat, self.Val = Color3ToHsv(Value.Color)
            self.Alpha = MathClamp(Value.Alpha or 1, 0, 1)
        end
        Config[Flag] = Value
        if not Silent then
            FireChange(self)
            QueueSaveConfig()
        end
        return self
    end
    if ControlObj.Type == "Keybind" then
        function ControlObj:SetMode(Mode)
            SetBindMode(Flag, Mode)
            return self
        end
        function ControlObj:GetMode()
            return GetBindMode(Flag)
        end
    end
    return ControlObj
end

local function WrapSection(SectionObj)
    function SectionObj:Toggle(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return WrapControl(self:CreateToggle(Options.Name or F, F, Options.Default), F, Options.Callback)
    end
    function SectionObj:Slider(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return WrapControl(self:CreateSlider(Options.Name or F, F, Options.Min or 0, Options.Max or 100, Options.Default, Options.Step or 1), F, Options.Callback)
    end
    function SectionObj:Dropdown(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return WrapControl(self:CreateDropdown(Options.Name or F, F, Options.Options or {}, Options.Default), F, Options.Callback)
    end
    function SectionObj:Keybind(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return WrapControl(self:CreateKeybind(Options.Name or F, F, Options.Default or "None"), F, Options.Callback)
    end
    function SectionObj:Textbox(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return WrapControl(self:CreateTextbox(Options.Name or F, F, Options.Default or ""), F, Options.Callback)
    end
    function SectionObj:Colorpicker(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        local Callback = Options.Callback
        local C = self:CreateColorPicker(Options.Name or F, F, Options.Default or LibraryData.Palette.Accent, Options.Alpha or 1, Callback)
        return WrapControl(C, F, Callback)
    end
    SectionObj.ColorPicker = SectionObj.Colorpicker
    function SectionObj:Button(Options)
        Options = Options or {}
        return self:CreateButton(Options.Name or "Button", Options.Callback)
    end
    return SectionObj
end

function NightfallLibrary:Window(Options)
    Options = Options or {}
    if Options.Size then self:Size(Options.Size) end
    if Options.Name then WindowDrawings.Title.Text = Options.Name end
    local WindowObj = {Name = Options.Name or "Nightfall", State = LibraryData}
    function WindowObj:Tab(TabOptions)
        if type(TabOptions) == "string" then TabOptions = {Name = TabOptions} end
        TabOptions = TabOptions or {}
        local TabObj = LibraryData:CreateTab(TabOptions.Name or "Tab", TabOptions.Icon)
        TabObj.Hidden = TabOptions.Hidden == true
        function TabObj:Section(SectionOptions)
            if type(SectionOptions) == "string" then SectionOptions = {Name = SectionOptions} end
            SectionOptions = SectionOptions or {}
            return WrapSection(self:CreateSection(SectionOptions.Name or "Section", SectionOptions.Side or "Left"))
        end
        return TabObj
    end
    return WindowObj
end

local SettingWindow = NightfallLibrary:Window({})
SettingsTab = SettingWindow:Tab({Name = "Library Settings", Hidden = true})
local Appearance = SettingsTab:Section({Name = "Appearance", Side = "Left"})
Appearance:Keybind({Name = "Menu Bind", Flag = "HideKeybind", Default = "F2"})
Appearance:Toggle({Name = "Hotkey List", Flag = "ShowHotkeyList", Default = true})
Appearance:Toggle({Name = "Watermark", Flag = "ShowWatermark", Default = false, Callback = function(Value)
    WatermarkSettings.Visible = Value
    SaveGlobalSettings()
end})
Appearance:Textbox({Name = "Watermark Text", Flag = "WatermarkText", Default = "Nightfall | Matcha"})
Appearance:Toggle({Name = "Compact Watermark", Flag = "WatermarkCompact", Default = true})
Appearance:Toggle({Name = "Notifications", Flag = "ShowNotifications", Default = true})
Appearance:Slider({Name = "Notification Time", Flag = "NotificationDuration", Min = 1, Max = 15, Default = 4, Step = 1})
Appearance:Dropdown({Name = "Notification Position", Flag = "NotificationPosition", Options = {"Top Right", "Top Left"}, Default = "Top Right"})
Appearance:Dropdown({Name = "Theme", Flag = "ThemePreset", Options = {"Nightfall", "Bloodmoon", "Ocean", "Mint"}, Default = "Nightfall", Callback = function(Value)
    ApplyThemePreset(Value, false)
end})
Appearance:Colorpicker({Name = "Accent Color", Flag = "LibraryAccent", Default = LibraryData.Palette.Accent, Callback = function(Value)
    if Value and Value.Color then
        LibraryData.Palette.Accent = Value.Color
        Config.UiAccentColor = {Color = Value.Color, Alpha = Value.Alpha or 1}
        QueueSaveConfig()
    end
end})
local Files = SettingsTab:Section({Name = "Configuration", Side = "Right"})
Files:Textbox({Name = "Config Name", Flag = "ConfigName", Default = "default"})
Files:Toggle({Name = "Auto Save", Flag = "AutoSaveConfig", Default = false})
Files:Toggle({Name = "Auto Load", Flag = "AutoLoadConfig", Default = false})
Files:Button({Name = "Save Config", Callback = function() SaveCurrentConfig() end})
Files:Button({Name = "Load Config", Callback = function() LoadNamedConfig(Config.ConfigName) end})
Files:Button({Name = "Delete Config", Callback = function() DeleteNamedConfig(Config.ConfigName) end})
Files:Button({Name = "Save Window Layout", Callback = function() SaveLayout() end})
LibraryData.CurrentTab = nil

function NightfallLibrary:Unload()
    Session.Active = false
    _G.NightfallActive = false
    for _, Entry in ipairs(UiNotifications) do DeleteNotification(Entry) end
    UiNotifications = {}
    for _, ConnectionObj in ipairs(Session.Connections) do
        pcall(function() ConnectionObj:Disconnect() end)
    end
    for _, DrawingObj in ipairs(_G.NightfallDrawings or {}) do
        pcall(function() DrawingObj:Remove() end)
    end
    if _G.NightfallSession == Session then _G.NightfallSession = nil end
    if _G.NightfallLibrary == self then _G.NightfallLibrary = nil end
end

_G.NightfallLibrary = NightfallLibrary
FetchProfileAvatar()
