local Http_Service = game:GetService("HttpService")
local Run_Service = game:GetService("RunService")
local Players_Service = game:GetService("Players")
local Workspace_Service = game:GetService("Workspace")
local User_Input_Service = game:GetService("UserInputService")
local Local_Player = Players_Service.LocalPlayer or Players_Service.PlayerAdded:Wait()
local Local_Mouse = Local_Player:GetMouse()
local Fast_Floor = math.floor
local Fast_Max = math.max
local Fast_Clamp = math.clamp
local Fast_Clock = os.clock
local Fast_Tick = tick
local Keys_Down = {}

if _G.NightfallSession then
    _G.NightfallSession.Active = false
    for _, Connection_Obj in ipairs(_G.NightfallSession.Connections or {}) do
        pcall(function() Connection_Obj:Disconnect() end)
    end
end
_G.MoonshadeActive = false
if _G.NightfallDrawings then
    for _, Drawing_Obj in ipairs(_G.NightfallDrawings) do
        pcall(function() Drawing_Obj:Remove() end)
    end
end
if _G.MoonshadeDrawings then
    for _, Drawing_Obj in pairs(_G.MoonshadeDrawings) do
        pcall(function() Drawing_Obj:Remove() end)
    end
    _G.MoonshadeDrawings = nil
end
local Session = {Active = true, Connections = {}}
_G.NightfallSession = Session
_G.NightfallDrawings = {}
_G.NightfallActive = true
local function Connect_Session(Event_Obj, Callback_Func)
    local Connection_Obj = Event_Obj:Connect(function(...)
        if Session.Active then Callback_Func(...) end
    end)
    table.insert(Session.Connections, Connection_Obj)
    return Connection_Obj
end

local Key_Codes = {
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

local Name_To_Code = {}
for Code_Val, Name_Val in pairs(Key_Codes) do
    Name_To_Code[Name_Val] = Code_Val
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
    RenderBallStats = false,
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
}

local function Normalize_Keybind_Value(Value_In)
    if type(Value_In) == "number" then
        return Key_Codes[Value_In] or tostring(Value_In)
    end
    if Value_In == nil or Value_In == "" then return "None" end
    return tostring(Value_In)
end

local function Normalize_Bind_Mode(Mode_In)
    Mode_In = tostring(Mode_In or "Toggle")
    if string.lower(Mode_In) == "hold" then return "Hold" end
    return "Toggle"
end

local function Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    if Bind_Flag == "ParryKeybind" then return "ParryBindMode"
    elseif Bind_Flag == "SpamKeybind" then return "SpamBindMode"
    elseif Bind_Flag == "TriggerKeybind" then return "TriggerBindMode"
    end
end

local function Get_Toggle_Flag_From_Bind_Flag(Bind_Flag)
    if Bind_Flag == "ParryKeybind" then return "AutoParry"
    elseif Bind_Flag == "SpamKeybind" then return "AutoSpam"
    elseif Bind_Flag == "TriggerKeybind" then return "TriggerBot"
    end
end

local Keybind_System
local Set_Bind_Target_State

local function Set_Bind_Mode(Bind_Flag, Mode_In)
    local Mode_Flag = Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    if Mode_Flag then
        Config[Mode_Flag] = Normalize_Bind_Mode(Mode_In)
        local Current_Bind = Keybind_System and Keybind_System.Binds[Bind_Flag]
        if Current_Bind then
            if Current_Bind.Mode == "Hold" then Set_Bind_Target_State(Bind_Flag, false) end
            Current_Bind.Mode = Config[Mode_Flag]
            Keybind_System.Last_Pressed[Bind_Flag] = iskeypressed(Current_Bind.Code) or false
        end
    end
end

local function Get_Bind_Mode(Bind_Flag)
    local Mode_Flag = Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    return Normalize_Bind_Mode(Mode_Flag and Config[Mode_Flag] or "Toggle")
end

Set_Bind_Target_State = function(Bind_Flag, State_In)
    local Toggle_Flag = Get_Toggle_Flag_From_Bind_Flag(Bind_Flag)
    if Toggle_Flag then Config[Toggle_Flag] = State_In and true or false end
end

Keybind_System = {
    Binds = {},
    Last_Pressed = {}
}

local function Register_Keybind(Flag_Name, Key_Name, Mode_In)
    local Code_Val = Name_To_Code[Normalize_Keybind_Value(Key_Name)]
    Keybind_System.Binds[Flag_Name] = Code_Val and {
        Code = Code_Val,
        Mode = Normalize_Bind_Mode(Mode_In or "Toggle")
    } or nil
    Keybind_System.Last_Pressed[Flag_Name] = Code_Val and iskeypressed(Code_Val) or false
end

local function Update_Keybinds()
    if not isrbxactive() then
        for Flag_Name, Data_Val in pairs(Keybind_System.Binds) do
            if Data_Val.Mode == "Hold" then Set_Bind_Target_State(Flag_Name, false) end
            Keybind_System.Last_Pressed[Flag_Name] = false
        end
        return
    end
    for Flag_Name, Data_Val in pairs(Keybind_System.Binds) do
        local Is_Pressed = iskeypressed(Data_Val.Code) or false
        local Was_Pressed = Keybind_System.Last_Pressed[Flag_Name] or false
        if Is_Pressed and not Was_Pressed then
            if Data_Val.Mode == "Hold" then
                Set_Bind_Target_State(Flag_Name, true)
            else
                local Toggle_Flag = Get_Toggle_Flag_From_Bind_Flag(Flag_Name)
                if Toggle_Flag then Config[Toggle_Flag] = not Config[Toggle_Flag] end
            end
        elseif not Is_Pressed and Was_Pressed and Data_Val.Mode == "Hold" then
            Set_Bind_Target_State(Flag_Name, false)
        end
        Keybind_System.Last_Pressed[Flag_Name] = Is_Pressed
    end
end

local Runtime_State = {
    Target_Speed = 0,
    Target_Distance = 0,
    Target_Dot = 0
}

local function Math_Clamp(Val_In, Min_Val, Max_Val)
    return Fast_Max(Min_Val, math.min(Max_Val, Val_In))
end

local function Math_Round(Num_Val)
    return Fast_Floor(Num_Val + 0.5)
end

local function Vector_2_Round(X_Val, Y_Val)
    return Vector2.new(Math_Round(X_Val), Math_Round(Y_Val))
end

local function Math_Lerp(A_Val, B_Val, T_Val)
    return A_Val + (B_Val - A_Val) * T_Val
end

local function Color_Lerp(C1_Val, C2_Val, T_Val)
    if not C1_Val or not C2_Val then return Color3.new(1, 1, 1) end
    return Color3.new(Math_Lerp(C1_Val.R, C2_Val.R, T_Val), Math_Lerp(C1_Val.G, C2_Val.G, T_Val), Math_Lerp(C1_Val.B, C2_Val.B, T_Val))
end

local function Snap_Value(Val_In, Step_Val)
    return Step_Val and Fast_Floor((Val_In / Step_Val) + 0.5) * Step_Val or Val_In
end

local function Hsv_To_Color3(H_Val, S_Val, V_Val)
    H_Val = ((H_Val or 0) % 1 + 1) % 1
    S_Val = Math_Clamp(S_Val or 0, 0, 1)
    V_Val = Math_Clamp(V_Val or 0, 0, 1)
    local C_Val = V_Val * S_Val
    local Hp_Val = H_Val * 6
    local X_Val = C_Val * (1 - math.abs((Hp_Val % 2) - 1))
    local R1_Val, G1_Val, B1_Val = 0, 0, 0
    if Hp_Val >= 0 and Hp_Val < 1 then R1_Val, G1_Val, B1_Val = C_Val, X_Val, 0
    elseif Hp_Val >= 1 and Hp_Val < 2 then R1_Val, G1_Val, B1_Val = X_Val, C_Val, 0
    elseif Hp_Val >= 2 and Hp_Val < 3 then R1_Val, G1_Val, B1_Val = 0, C_Val, X_Val
    elseif Hp_Val >= 3 and Hp_Val < 4 then R1_Val, G1_Val, B1_Val = 0, X_Val, C_Val
    elseif Hp_Val >= 4 and Hp_Val < 5 then R1_Val, G1_Val, B1_Val = X_Val, 0, C_Val
    else R1_Val, G1_Val, B1_Val = C_Val, 0, X_Val
    end
    local M_Val = V_Val - C_Val
    return Color3.new(R1_Val + M_Val, G1_Val + M_Val, B1_Val + M_Val)
end

local function Color3_To_Hsv(Color_Val)
    if not Color_Val then return 0, 0, 1 end
    local R_Val, G_Val, B_Val = Color_Val.R, Color_Val.G, Color_Val.B
    local Max_C = Fast_Max(R_Val, G_Val, B_Val)
    local Min_C = math.min(R_Val, G_Val, B_Val)
    local Delta_C = Max_C - Min_C
    local H2_Val = 0
    if Delta_C > 0 then
        if Max_C == R_Val then H2_Val = ((G_Val - B_Val) / Delta_C) % 6
        elseif Max_C == G_Val then H2_Val = ((B_Val - R_Val) / Delta_C) + 2
        else H2_Val = ((R_Val - G_Val) / Delta_C) + 4
        end
        H2_Val = H2_Val / 6
    end
    local S2_Val = Max_C == 0 and 0 or (Delta_C / Max_C)
    return H2_Val, S2_Val, Max_C
end

local function Color3_To_Hex(Color_Val)
    if not Color_Val then return "#FFFFFF" end
    return string.format("#%02X%02X%02X", Math_Clamp(Math_Round(Color_Val.R * 255), 0, 255), Math_Clamp(Math_Round(Color_Val.G * 255), 0, 255), Math_Clamp(Math_Round(Color_Val.B * 255), 0, 255))
end

local Create_Drawing
local function Create_Grid_Squares(Count_Val)
    local Grid_Array = {}
    for I_Idx = 1, Count_Val do
        Grid_Array[I_Idx] = Create_Drawing("Square", {Filled = true, Transparency = 1, Visible = false})
    end
    return Grid_Array
end

local function Update_Grid_Squares(Grid_Array, Cols_Val, Rows_Val, X_Val, Y_Val, W_Val, H_Val, Color_Func, Visible_State)
    if not Visible_State or W_Val <= 0 or H_Val <= 0 then
        for _, Sq_Val in ipairs(Grid_Array) do Sq_Val.Visible = false end
        return
    end
    local Cell_W = W_Val / Cols_Val
    local Cell_H = H_Val / Rows_Val
    local Idx_Val = 1
    for Row_Idx = 1, Rows_Val do
        for Col_Idx = 1, Cols_Val do
            local Sq_Val = Grid_Array[Idx_Val]
            Idx_Val = Idx_Val + 1
            local X0_Val = X_Val + ((Col_Idx - 1) * Cell_W)
            local Y0_Val = Y_Val + ((Row_Idx - 1) * Cell_H)
            local X1_Val = X_Val + (Col_Idx * Cell_W)
            local Y1_Val = Y_Val + (Row_Idx * Cell_H)
            Sq_Val.Visible = true
            Sq_Val.Position = Vector_2_Round(X0_Val, Y0_Val)
            Sq_Val.Size = Vector_2_Round(Fast_Max(1, Math_Round(X1_Val - X0_Val)), Fast_Max(1, Math_Round(Y1_Val - Y0_Val)))
            Sq_Val.Color = Color_Func(Col_Idx, Row_Idx, Cols_Val, Rows_Val)
            Sq_Val.Transparency = 1
        end
    end
end

local function Hide_Grid_Squares(Grid_Array)
    for _, Sq_Val in ipairs(Grid_Array) do Sq_Val.Visible = false end
end

local function Get_Step_Decimals(Step_Val)
    if type(Step_Val) ~= "number" then return 0 end
    local S_Val = string.format("%.10f", Step_Val):gsub("0+$", "")
    local Dot_Idx = S_Val:find("%.")
    return Dot_Idx and (#S_Val - Dot_Idx) or 0
end

local function Format_Slider_Value(Value_In, Step_Val)
    if type(Value_In) ~= "number" then return tostring(Value_In) end
    local Decimals_Val = Get_Step_Decimals(Step_Val)
    if Decimals_Val <= 0 then return tostring(Fast_Floor(Value_In + 0.5)) end
    local Formatted_Val = string.format("%." .. Decimals_Val .. "f", Value_In)
    Formatted_Val = Formatted_Val:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    return Formatted_Val
end

local function Parse_Slider_Input(Text_Value)
    local Cleaned_Val = tostring(Text_Value or ""):gsub(",", "."):gsub("[^%d%.%-]", "")
    if Cleaned_Val == "" or Cleaned_Val == "-" or Cleaned_Val == "." or Cleaned_Val == "-." then return nil end
    local Number_Val = tonumber(Cleaned_Val)
    if Number_Val == nil then return nil end
    return Number_Val
end

local function Clamp_Slider_Value(Value_In, Min_Val, Max_Val, Step_Val)
    local Clamped_Val = Math_Clamp(Value_In, Min_Val, Max_Val)
    local Snapped_Val = Snap_Value(Clamped_Val, Step_Val)
    return Math_Clamp(Snapped_Val, Min_Val, Max_Val)
end

local Queue_Save_Config
local Fire_Change

local function Commit_Slider_Input(Slider_Obj)
    if not Slider_Obj then return end
    local Parsed_Val = Parse_Slider_Input(Slider_Obj.InputBuffer)
    if Parsed_Val == nil then
        Slider_Obj.InputBuffer = Format_Slider_Value(Config[Slider_Obj.Flag], Slider_Obj.Step)
        return
    end
    local Final_Value = Clamp_Slider_Value(Parsed_Val, Slider_Obj.Min, Slider_Obj.Max, Slider_Obj.Step)
    if Config[Slider_Obj.Flag] ~= Final_Value then
        Config[Slider_Obj.Flag] = Final_Value
        if Queue_Save_Config then Queue_Save_Config() end
    end
    Slider_Obj.InputBuffer = Format_Slider_Value(Final_Value, Slider_Obj.Step)
    if Fire_Change then Fire_Change(Slider_Obj) end
end

local function Get_Context_Menu_Position(Item_Obj)
    local Camera_Obj = Workspace_Service.CurrentCamera
    local Viewport_Val = Camera_Obj and Camera_Obj.ViewportSize or Vector2.new(1920, 1080)
    local Menu_W, Menu_H = 128, 66
    if not Item_Obj or not Item_Obj.ButtonPos or not Item_Obj.ButtonSize then return Vector_2_Round(0, 0) end
    local Context_X = Item_Obj.ButtonPos.X
    local Context_Y = Item_Obj.ButtonPos.Y + Item_Obj.ButtonSize.Y + 6
    if Context_X + Menu_W > Viewport_Val.X then Context_X = Item_Obj.ButtonPos.X + Item_Obj.ButtonSize.X - Menu_W end
    if Context_Y + Menu_H > Viewport_Val.Y then Context_Y = Item_Obj.ButtonPos.Y - Menu_H - 6 end
    return Vector_2_Round(Math_Clamp(Context_X, 0, Viewport_Val.X - Menu_W), Math_Clamp(Context_Y, 0, Viewport_Val.Y - Menu_H))
end

local Text_Offsets = {
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
    ContextOption = {X = 0, Y = 0}
}

_G.NightfallTextOffsets = Text_Offsets

local function Position_Text(Text_Obj, X_Val, Y_Val, Style_Name)
    local Offset_Val = Text_Offsets[Style_Name]
    if Offset_Val then
        X_Val = X_Val + Offset_Val.X
        Y_Val = Y_Val + Offset_Val.Y
    end
    Text_Obj.Position = Vector_2_Round(X_Val, Y_Val)
end

local function Position_Text_Centered(Text_Obj, Rect_Pos, Rect_Size, Style_Name)
    Text_Obj.Center = true
    Position_Text(Text_Obj, Rect_Pos.X + Rect_Size.X / 2, Rect_Pos.Y + Rect_Size.Y / 2, Style_Name)
end

local function Is_Mouse_In_Bounds(Pos_In, Bounds_Pos, Bounds_Size)
    return Pos_In.X >= Bounds_Pos.X and Pos_In.X <= Bounds_Pos.X + Bounds_Size.X and Pos_In.Y >= Bounds_Pos.Y and Pos_In.Y <= Bounds_Pos.Y + Bounds_Size.Y
end

Create_Drawing = function(Class_Name, Properties_Table)
    local Drawing_Obj = Drawing.new(Class_Name)
    for Prop_Name, Prop_Value in pairs(Properties_Table) do
        if Class_Name == "Text" and Prop_Name == "Size" then
            Prop_Name = "FontSize"
        elseif Class_Name == "Text" and Prop_Name == "Font" and type(Prop_Value) == "number" then
            Prop_Value = Drawing.Fonts and Drawing.Fonts.SystemBold or Prop_Value
        end
        pcall(function() Drawing_Obj[Prop_Name] = Prop_Value end)
    end
    table.insert(_G.NightfallDrawings, Drawing_Obj)
    return Drawing_Obj
end

local function Create_Keybind_Image_Icon(Size_Val)
    Size_Val = Size_Val or 18
    local function Square_Func() return Create_Drawing("Square", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, Visible = false}) end
    local function Circle_Func() return Create_Drawing("Circle", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, NumSides = 18, Radius = 1, Visible = false}) end
    return {
        IsImage = false,
        Size = Size_Val,
        Parts = {
            Main = Square_Func(), Top = Square_Func(), Bottom = Square_Func(),
            Left = Square_Func(), Right = Square_Func(),
            TL = Circle_Func(), TR = Circle_Func(), BL = Circle_Func(), BR = Circle_Func(),
            Inner = Square_Func(), Dot1 = Circle_Func(), Dot2 = Circle_Func(), Dot3 = Circle_Func(),
            Keys = {Square_Func(), Square_Func(), Square_Func(), Square_Func(), Square_Func(), Square_Func()}
        }
    }
end

local function Update_Keybind_Image_Icon(Icon_Obj, Position_Val, Color_Val, Visible_State)
    if not Icon_Obj then return end
    if Icon_Obj.IsImage and Icon_Obj.Image then
        local Image_Obj = Icon_Obj.Image
        Image_Obj.Visible = Visible_State
        pcall(function() Image_Obj.Position = Position_Val end)
        pcall(function() Image_Obj.Size = Vector_2_Round(Icon_Obj.Size, Icon_Obj.Size) end)
        pcall(function() Image_Obj.Color = Color_Val end)
        pcall(function() Image_Obj.Transparency = Visible_State and 1 or 0 end)
        return
    end
    if not Icon_Obj.Parts then
        if Icon_Obj.Fallback then
            Icon_Obj.Fallback.Visible = Visible_State
            if Visible_State then
                Icon_Obj.Fallback.Position = Position_Val
                Icon_Obj.Fallback.Color = Color_Val
            end
        end
        return
    end
    local Size_Val = Icon_Obj.Size or 18
    local Width_Val = Fast_Max(12, Fast_Floor(Size_Val * 0.9 + 0.5))
    local Height_Val = Fast_Max(10, Fast_Floor(Size_Val * 0.72 + 0.5))
    local Radius_Val = Fast_Max(2, Fast_Floor(Size_Val * 0.15 + 0.5))
    local Stroke_Val = Fast_Max(1, Fast_Floor(Size_Val * 0.07 + 0.5))
    local X_Val = Fast_Floor(Position_Val.X + 0.5)
    local Y_Val = Fast_Floor(Position_Val.Y + 0.5)
    local W_Val, H_Val = Width_Val, Height_Val
    local Parts_Obj = Icon_Obj.Parts
    local Outline_Array = {Parts_Obj.Main, Parts_Obj.Top, Parts_Obj.Bottom, Parts_Obj.Left, Parts_Obj.Right, Parts_Obj.TL, Parts_Obj.TR, Parts_Obj.BL, Parts_Obj.BR}
    for _, Obj_Item in ipairs(Outline_Array) do
        Obj_Item.Visible = Visible_State
        if Visible_State then Obj_Item.Color = Color_Val Obj_Item.Transparency = 1 end
    end
    if Visible_State then
        Parts_Obj.Main.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + Radius_Val)
        Parts_Obj.Main.Size = Vector_2_Round(Fast_Max(W_Val - Radius_Val * 2, 0), Fast_Max(H_Val - Radius_Val * 2, 0))
        Parts_Obj.Top.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val)
        Parts_Obj.Top.Size = Vector_2_Round(Fast_Max(W_Val - Radius_Val * 2, 0), Radius_Val)
        Parts_Obj.Bottom.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + H_Val - Radius_Val)
        Parts_Obj.Bottom.Size = Vector_2_Round(Fast_Max(W_Val - Radius_Val * 2, 0), Radius_Val)
        Parts_Obj.Left.Position = Vector_2_Round(X_Val, Y_Val + Radius_Val)
        Parts_Obj.Left.Size = Vector_2_Round(Radius_Val, Fast_Max(H_Val - Radius_Val * 2, 0))
        Parts_Obj.Right.Position = Vector_2_Round(X_Val + W_Val - Radius_Val, Y_Val + Radius_Val)
        Parts_Obj.Right.Size = Vector_2_Round(Radius_Val, Fast_Max(H_Val - Radius_Val * 2, 0))
        Parts_Obj.TL.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + Radius_Val)
        Parts_Obj.TR.Position = Vector_2_Round(X_Val + W_Val - Radius_Val, Y_Val + Radius_Val)
        Parts_Obj.BL.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + H_Val - Radius_Val)
        Parts_Obj.BR.Position = Vector_2_Round(X_Val + W_Val - Radius_Val, Y_Val + H_Val - Radius_Val)
        Parts_Obj.TL.Radius = Radius_Val
        Parts_Obj.TR.Radius = Radius_Val
        Parts_Obj.BL.Radius = Radius_Val
        Parts_Obj.BR.Radius = Radius_Val
    end
    local Inner_Pad = Stroke_Val + 1
    Parts_Obj.Inner.Visible = Visible_State
    if Visible_State then
        Parts_Obj.Inner.Position = Vector_2_Round(X_Val + Inner_Pad, Y_Val + Inner_Pad)
        Parts_Obj.Inner.Size = Vector_2_Round(Fast_Max(W_Val - Inner_Pad * 2, 1), Fast_Max(H_Val - Inner_Pad * 2, 1))
        Parts_Obj.Inner.Color = Color3.fromRGB(16, 20, 30)
        Parts_Obj.Inner.Transparency = 1
    end
    local Dot_Radius = Fast_Max(1, Fast_Floor(Size_Val * 0.05 + 0.5))
    local Dot_Gap = Fast_Max(3, Fast_Floor(Size_Val * 0.13 + 0.5))
    local Dot_Start_X = X_Val + Inner_Pad + Dot_Radius + 1
    local Dot_Y = Y_Val + Inner_Pad + Dot_Radius + 1
    local Dots_Array = {Parts_Obj.Dot1, Parts_Obj.Dot2, Parts_Obj.Dot3}
    for I_Idx, Dot_Obj in ipairs(Dots_Array) do
        Dot_Obj.Visible = Visible_State
        if Visible_State then
            Dot_Obj.Position = Vector_2_Round(Dot_Start_X + (I_Idx - 1) * Dot_Gap, Dot_Y)
            Dot_Obj.Radius = Dot_Radius
            Dot_Obj.Color = Color_Val
            Dot_Obj.Transparency = 1
        end
    end
    local Key_Pad_X = Fast_Max(3, Fast_Floor(Size_Val * 0.14 + 0.5))
    local Key_Pad_Y = Fast_Max(5, Fast_Floor(Size_Val * 0.24 + 0.5))
    local Key_Gap = Fast_Max(1, Fast_Floor(Size_Val * 0.06 + 0.5))
    local Available_W = Fast_Max(W_Val - Key_Pad_X * 2, 6)
    local Available_H = Fast_Max(H_Val - Key_Pad_Y - Inner_Pad - 1, 4)
    local Key_Size = Fast_Max(2, Fast_Floor(math.min((Available_W - Key_Gap * 2) / 3, (Available_H - Key_Gap) / 2) + 0.5))
    local Total_Keys_Width = Key_Size * 3 + Key_Gap * 2
    local Total_Keys_Height = Key_Size * 2 + Key_Gap
    local Keys_Start_X = X_Val + Fast_Floor((W_Val - Total_Keys_Width) / 2 + 0.5)
    local Keys_Start_Y = Y_Val + H_Val - Inner_Pad - Total_Keys_Height - 1
    for I_Idx, Key_Obj in ipairs(Parts_Obj.Keys) do
        Key_Obj.Visible = Visible_State
        if Visible_State then
            local Row_Val = Fast_Floor((I_Idx - 1) / 3)
            local Col_Val = (I_Idx - 1) % 3
            Key_Obj.Position = Vector_2_Round(Keys_Start_X + Col_Val * (Key_Size + Key_Gap), Keys_Start_Y + Row_Val * (Key_Size + Key_Gap))
            Key_Obj.Size = Vector_2_Round(Key_Size, Key_Size)
            Key_Obj.Color = Color_Val
            Key_Obj.Transparency = 1
        end
    end
end

local function Set_Visible(Item_Obj, Visible_State)
    if not Item_Obj then return end
    if Item_Obj.Single then
        Item_Obj.Single.Visible = Visible_State
    elseif Item_Obj.Main then
        Item_Obj.Main.Visible = Visible_State
        Item_Obj.Top.Visible = Visible_State
        Item_Obj.Bottom.Visible = Visible_State
        Item_Obj.Left.Visible = Visible_State
        Item_Obj.Right.Visible = Visible_State
        Item_Obj.TL.Visible = Visible_State
        Item_Obj.TR.Visible = Visible_State
        Item_Obj.BL.Visible = Visible_State
        Item_Obj.BR.Visible = Visible_State
    elseif Item_Obj.IsImage or Item_Obj.Fallback or Item_Obj.Image then
        Update_Keybind_Image_Icon(Item_Obj, Vector_2_Round(-1000, -1000), Color3.new(1, 1, 1), Visible_State)
    else
        Item_Obj.Visible = Visible_State
    end
end

local function Set_Rounded_Color(Box_Obj, Color_Val, Transparency_Val)
    if Box_Obj.Single then
        Box_Obj.Single.Color = Color_Val
        Box_Obj.Single.Transparency = Transparency_Val or 1
        return
    end
    local List_Array = {Box_Obj.Main, Box_Obj.Top, Box_Obj.Bottom, Box_Obj.Left, Box_Obj.Right, Box_Obj.TL, Box_Obj.TR, Box_Obj.BL, Box_Obj.BR}
    for _, Obj_Item in ipairs(List_Array) do
        Obj_Item.Color = Color_Val
        Obj_Item.Transparency = Transparency_Val or 1
    end
end

local function Set_Drawing_Layer(Item_Obj, Layer_Val)
    if not Item_Obj then return end
    if Item_Obj.Single then
        pcall(function() Item_Obj.Single.ZIndex = Layer_Val end)
    elseif Item_Obj.Main then
        for _, Draw_Obj in pairs(Item_Obj) do
            pcall(function() Draw_Obj.ZIndex = Layer_Val end)
        end
    else
        pcall(function() Item_Obj.ZIndex = Layer_Val end)
    end
end

local Rounded_Corner_Supported = nil
local function Make_Rounded_Box(Color_Val, Transparency_Val)
    if Rounded_Corner_Supported ~= false then
        local Square_Obj = Create_Drawing("Square", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, Visible = false})
        local Supported = pcall(function() Square_Obj.Corner = 4 end)
        Rounded_Corner_Supported = Supported
        if Supported then return {Single = Square_Obj} end
        pcall(function() Square_Obj:Remove() end)
    end
    return {
        Main = Create_Drawing("Square", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, Visible = false}),
        Top = Create_Drawing("Square", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, Visible = false}),
        Bottom = Create_Drawing("Square", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, Visible = false}),
        Left = Create_Drawing("Square", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, Visible = false}),
        Right = Create_Drawing("Square", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, Visible = false}),
        TL = Create_Drawing("Circle", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, NumSides = 18, Radius = 4, Visible = false}),
        TR = Create_Drawing("Circle", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, NumSides = 18, Radius = 4, Visible = false}),
        BL = Create_Drawing("Circle", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, NumSides = 18, Radius = 4, Visible = false}),
        BR = Create_Drawing("Circle", {Filled = true, Color = Color_Val, Transparency = Transparency_Val or 1, NumSides = 18, Radius = 4, Visible = false})
    }
end

local function Update_Rounded_Box(Box_Obj, Pos_Val, Size_Val, Radius_Val, Color_Val, Transparency_Val, Visible_State)
    Radius_Val = Math_Clamp(Radius_Val or 4, 0, Fast_Floor(math.min(Size_Val.X, Size_Val.Y) / 2))
    if Box_Obj.Single then
        local Square_Obj = Box_Obj.Single
        Square_Obj.Position = Pos_Val
        Square_Obj.Size = Vector_2_Round(Fast_Max(0, Size_Val.X), Fast_Max(0, Size_Val.Y))
        Square_Obj.Corner = Radius_Val
        Square_Obj.Color = Color_Val
        Square_Obj.Transparency = Transparency_Val or 1
        Square_Obj.Visible = Visible_State and Size_Val.X > 0 and Size_Val.Y > 0
        return
    end
    local X_Val, Y_Val = Pos_Val.X, Pos_Val.Y
    local W_Val, H_Val = Size_Val.X, Size_Val.Y
    Set_Rounded_Color(Box_Obj, Color_Val, Transparency_Val or 1)
    Set_Visible(Box_Obj, Visible_State)
    Box_Obj.Main.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + Radius_Val)
    Box_Obj.Main.Size = Vector_2_Round(Fast_Max(W_Val - Radius_Val * 2, 0), Fast_Max(H_Val - Radius_Val * 2, 0))
    Box_Obj.Top.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val)
    Box_Obj.Top.Size = Vector_2_Round(Fast_Max(W_Val - Radius_Val * 2, 0), Radius_Val)
    Box_Obj.Bottom.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + H_Val - Radius_Val)
    Box_Obj.Bottom.Size = Vector_2_Round(Fast_Max(W_Val - Radius_Val * 2, 0), Radius_Val)
    Box_Obj.Left.Position = Vector_2_Round(X_Val, Y_Val + Radius_Val)
    Box_Obj.Left.Size = Vector_2_Round(Radius_Val, Fast_Max(H_Val - Radius_Val * 2, 0))
    Box_Obj.Right.Position = Vector_2_Round(X_Val + W_Val - Radius_Val, Y_Val + Radius_Val)
    Box_Obj.Right.Size = Vector_2_Round(Radius_Val, Fast_Max(H_Val - Radius_Val * 2, 0))
    Box_Obj.TL.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + Radius_Val)
    Box_Obj.TR.Position = Vector_2_Round(X_Val + W_Val - Radius_Val, Y_Val + Radius_Val)
    Box_Obj.BL.Position = Vector_2_Round(X_Val + Radius_Val, Y_Val + H_Val - Radius_Val)
    Box_Obj.BR.Position = Vector_2_Round(X_Val + W_Val - Radius_Val, Y_Val + H_Val - Radius_Val)
    Box_Obj.TL.Radius = Radius_Val
    Box_Obj.TR.Radius = Radius_Val
    Box_Obj.BL.Radius = Radius_Val
    Box_Obj.BR.Radius = Radius_Val
end

local function Make_Gradient_Line(Count_Val)
    local Items_Array = {}
    for I_Idx = 1, Count_Val do
        Items_Array[I_Idx] = Create_Drawing("Square", {Filled = true, Visible = false})
    end
    return Items_Array
end

local function Update_Gradient_Line(Items_Array, Pos_Val, Size_Val, C1_Val, C2_Val, Visible_State)
    local Count_Val = #Items_Array
    local Width_Val = Fast_Max(0, Math_Round(Size_Val.X))
    local Height_Val = Fast_Max(0, Math_Round(Size_Val.Y))
    local Start_X = Math_Round(Pos_Val.X)
    local Start_Y = Math_Round(Pos_Val.Y)
    for I_Idx = 1, Count_Val do
        local X0_Val = Start_X + Math_Round((I_Idx - 1) * Width_Val / Count_Val)
        local X1_Val = Start_X + Math_Round(I_Idx * Width_Val / Count_Val)
        local It_Obj = Items_Array[I_Idx]
        It_Obj.Visible = Visible_State and X1_Val > X0_Val and Height_Val > 0
        if It_Obj.Visible then
            It_Obj.Color = Color_Lerp(C1_Val, C2_Val, (I_Idx - 0.5) / Count_Val)
            It_Obj.Position = Vector_2_Round(X0_Val, Start_Y)
            It_Obj.Size = Vector_2_Round(X1_Val - X0_Val, Height_Val)
        end
    end
end

local function Hide_Gradient_Line(Items_Array)
    for _, It_Obj in ipairs(Items_Array) do It_Obj.Visible = false end
end

local function Make_Rounded_Gradient_Caps()
    local Caps = {Left = {}, Right = {}}
    for I_Idx = 1, 5 do
        Caps.Left[I_Idx] = Create_Drawing("Square", {Filled = true, Visible = false})
        Caps.Right[I_Idx] = Create_Drawing("Square", {Filled = true, Visible = false})
    end
    return Caps
end

local function Update_Rounded_Gradient(Items_Array, Caps, Pos_Val, Size_Val, C1_Val, C2_Val, Visible_State)
    local W_Val = Math_Round(Size_Val.X)
    local H_Val = Math_Round(Size_Val.Y)
    if not Visible_State or W_Val < 18 or H_Val < 3 then
        Hide_Gradient_Line(Items_Array)
        for _, Cap_Val in ipairs(Caps.Left) do Cap_Val.Visible = false end
        for _, Cap_Val in ipairs(Caps.Right) do Cap_Val.Visible = false end
        return
    end
    local X_Val = Math_Round(Pos_Val.X)
    local Y_Val = Math_Round(Pos_Val.Y)
    Update_Gradient_Line(Items_Array, Vector_2_Round(X_Val + 7, Y_Val + 2), Vector_2_Round(W_Val - 14, 2), C1_Val, C2_Val, true)
    local Curve_Y = {3, 2, 1, 0, 0}
    for I_Idx = 1, 5 do
        local L_X = X_Val + I_Idx + 1
        local R_X = X_Val + W_Val - I_Idx - 2
        local L_Cap = Caps.Left[I_Idx]
        local R_Cap = Caps.Right[I_Idx]
        local Cap_Y = Y_Val + 2 + Curve_Y[I_Idx]
        L_Cap.Position = Vector_2_Round(L_X, Cap_Y)
        R_Cap.Position = Vector_2_Round(R_X, Cap_Y)
        L_Cap.Size = Vector_2_Round(1, 2)
        R_Cap.Size = Vector_2_Round(1, 2)
        L_Cap.Color = Color_Lerp(C1_Val, C2_Val, (L_X - X_Val + 0.5) / W_Val)
        R_Cap.Color = Color_Lerp(C1_Val, C2_Val, (R_X - X_Val + 0.5) / W_Val)
        L_Cap.Visible = true
        R_Cap.Visible = true
    end
end

local function Hide_Rounded_Gradient(Items_Array, Caps)
    Hide_Gradient_Line(Items_Array)
    for _, Cap_Val in ipairs(Caps.Left) do Cap_Val.Visible = false end
    for _, Cap_Val in ipairs(Caps.Right) do Cap_Val.Visible = false end
end

local function Make_Stripe_Pattern(Count_Val, Thickness_Val)
    local Items_Array = {}
    for I_Idx = 1, Count_Val do
        Items_Array[I_Idx] = Create_Drawing("Line", {Thickness = Thickness_Val or 10, Transparency = 0.08, Visible = false})
    end
    return Items_Array
end

local function Update_Stripe_Pattern(Items_Array, Rect_X, Rect_Y, Rect_W, Rect_H, Slant_Val, Spacing_Val, Color_Val, Visible_State)
    for _, Line_Obj in ipairs(Items_Array) do 
        Line_Obj.Visible = false 
    end
end

local function Hide_Stripe_Pattern(Items_Array)
    for _, Line_Obj in ipairs(Items_Array) do Line_Obj.Visible = false end
end

local function Clamp_Window_Position(Position_Val, Size_Val)
    local Camera_Obj = Workspace_Service.CurrentCamera
    local Viewport_Val = Camera_Obj and Camera_Obj.ViewportSize or Vector2.new(1920, 1080)
    local X_Val = Math_Clamp(Position_Val.X, 0, Fast_Max(0, Viewport_Val.X - Size_Val.X))
    local Y_Val = Math_Clamp(Position_Val.Y, 0, Fast_Max(0, Viewport_Val.Y - Size_Val.Y))
    return Vector_2_Round(X_Val, Y_Val)
end

local Library_Data = {
    Position = Vector2.new(200, 200),
    TargetPosition = Vector2.new(200, 200),
    Size = Vector2.new(720, 480),
    HotkeysPosition = Vector2.new(936, 240),
    StatsPosition = Vector2.new(936, 420),
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
        StatsDragging = false, StatsDragStart = Vector2.new(0, 0), StatsWindowStart = Vector2.new(0, 0),
        HotkeysContext = {Open = false, Position = Vector2.new(0, 0), Entry = nil},
        KeybindContext = {Open = false, Position = Vector2.new(0, 0), Entry = nil},
        BackspaceHeld = false, BackspaceNextRepeat = 0
    }
}

local Default_Nightfall_Palette = {
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

local Theme_Presets = {
    Nightfall = {
        Background = Default_Nightfall_Palette.Background, Sidebar = Default_Nightfall_Palette.Sidebar,
        Section = Default_Nightfall_Palette.Section, Element = Default_Nightfall_Palette.Element,
        Hover = Default_Nightfall_Palette.Hover, Outline = Default_Nightfall_Palette.Outline,
        OutlineLight = Default_Nightfall_Palette.OutlineLight, Accent = Default_Nightfall_Palette.Accent,
        Accent2 = Default_Nightfall_Palette.Accent2, Text = Default_Nightfall_Palette.Text,
        SubText = Default_Nightfall_Palette.SubText
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

local Palette_Keys = {"Background", "Sidebar", "Section", "Element", "Hover", "Outline", "OutlineLight", "Accent", "Accent2", "Text", "SubText"}
local Config_Dirty = false
local Save_Queue_Tick = 0
local Is_Config_Loading = false
local Config_Loaded = false
local Config_Directory = "NightfallConfigs"
local Global_Settings_Path = Config_Directory .. "/Settings.json"

local function Ensure_Config_Directory()
    if makefolder and isfolder and not isfolder(Config_Directory) then
        return pcall(makefolder, Config_Directory)
    end
    return true
end

local function Save_Global_Settings()
    if not writefile then return false end
    local Data_Val = {
        SelectedConfig = tostring(Config.SelectedConfig or Config.ConfigName or "default"),
        ConfigName = tostring(Config.ConfigName or Config.SelectedConfig or "default"),
        AutoSaveConfig = Config.AutoSaveConfig == true,
        AutoLoadConfig = Config.AutoLoadConfig == true
    }
    local Ok_State, Encoded_Val = pcall(function() return Http_Service:JSONEncode(Data_Val) end)
    if not Ok_State or not Ensure_Config_Directory() then return false end
    local Written_Val = pcall(writefile, Global_Settings_Path, Encoded_Val)
    return Written_Val
end

local function Load_Global_Settings()
    if not (isfile and readfile) then return false end
    local Path_Val = Global_Settings_Path
    if not isfile(Path_Val) then
        if isfile("Moonshade_Settings.json") then
            Path_Val = "Moonshade_Settings.json"
        elseif isfile("Nightfall_Settings.json") then
            Path_Val = "Nightfall_Settings.json"
        else
            return false
        end
    end
    local Ok_State, Decoded_Val = pcall(function() return Http_Service:JSONDecode(readfile(Path_Val)) end)
    if Ok_State and type(Decoded_Val) == "table" then
        if type(Decoded_Val.SelectedConfig) == "string" and Decoded_Val.SelectedConfig ~= "" then Config.SelectedConfig = Decoded_Val.SelectedConfig end
        if type(Decoded_Val.ConfigName) == "string" and Decoded_Val.ConfigName ~= "" then Config.ConfigName = Decoded_Val.ConfigName end
        Config.AutoSaveConfig = Decoded_Val.AutoSaveConfig == true
        Config.AutoLoadConfig = Decoded_Val.AutoLoadConfig == true
        if Path_Val ~= Global_Settings_Path then Save_Global_Settings() end
        return true
    end
    return false
end

local function Get_Config_Base_Name()
    local Name_Val = tostring(Config.ConfigName or "default")
    Name_Val = Name_Val:gsub("[^%w%-_]", "_"):sub(1, 48)
    if Name_Val == "" then Name_Val = "default" end
    return Name_Val
end

local function Get_Config_Path()
    return "NightfallConfigs/" .. Get_Config_Base_Name() .. ".json"
end

local function Get_Layout_Path()
    return "NightfallConfigs/" .. Get_Config_Base_Name() .. "_layout.json"
end

local function Get_Available_Configs()
    local Names_Array = {}
    local Seen_Table = {}
    if listfiles and isfolder and isfolder(Config_Directory) then
        local Ok_State, Files_Array = pcall(listfiles, Config_Directory)
        if Ok_State and type(Files_Array) == "table" then
            for _, File_Path in ipairs(Files_Array) do
                local File_Name = tostring(File_Path):gsub("\\", "/"):match("([^/]+)$")
                local Name_Val = File_Name and File_Name:match("^(.-)%.json$")
                if Name_Val and Name_Val ~= "Settings" and not Name_Val:match("_layout$") then
                    if not Seen_Table[Name_Val] then
                        Seen_Table[Name_Val] = true
                        table.insert(Names_Array, Name_Val)
                    end
                end
            end
        end
    end
    if #Names_Array == 0 then table.insert(Names_Array, "default") end
    table.sort(Names_Array, function(A_Val, B_Val) return tostring(A_Val):lower() < tostring(B_Val):lower() end)
    return Names_Array
end

local function Apply_Palette(Palette_Table)
    if type(Palette_Table) ~= "table" then return end
    for _, Key_Val in ipairs(Palette_Keys) do
        if Palette_Table[Key_Val] then Library_Data.Palette[Key_Val] = Palette_Table[Key_Val] end
    end
end

local function Sync_Theme_Editor_State()
    if not Library_Data or not Library_Data.Tabs then return end
    for _, Tab_Obj in ipairs(Library_Data.Tabs) do
        if Tab_Obj and Tab_Obj.Sections then
            for _, Section_Obj in ipairs(Tab_Obj.Sections) do
                if Section_Obj and Section_Obj.Items then
                    for _, Item_Obj in ipairs(Section_Obj.Items) do
                        if Item_Obj and Item_Obj.Type == "ColorPicker" and Item_Obj.Flag and type(Config[Item_Obj.Flag]) == "table" and Config[Item_Obj.Flag].Color then
                            local H_Val, S_Val, V_Val = Color3_To_Hsv(Config[Item_Obj.Flag].Color)
                            Item_Obj.Hue = H_Val
                            Item_Obj.Sat = S_Val
                            Item_Obj.Val = V_Val
                            Item_Obj.Alpha = Math_Clamp(Config[Item_Obj.Flag].Alpha or 1, 0, 1)
                        end
                    end
                end
            end
        end
    end
end

Queue_Save_Config = function()
    if Config.AutoSaveConfig and not Is_Config_Loading then
        Config_Dirty = true
        Save_Queue_Tick = Fast_Tick()
    end
end

local function Apply_Theme_Preset(Theme_Name, Keep_Accent)
    local Preset_Val = Theme_Presets[Theme_Name]
    if not Preset_Val then Preset_Val = Theme_Presets.Nightfall Theme_Name = "Nightfall" end
    local Accent_Val = Library_Data.Palette.Accent
    local Accent_2_Val = Library_Data.Palette.Accent2
    local Accent_Alpha = type(Config.UiAccentColor) == "table" and Math_Clamp(Config.UiAccentColor.Alpha or 1, 0, 1) or 1
    local Accent_2_Alpha = type(Config.UiAccent2Color) == "table" and Math_Clamp(Config.UiAccent2Color.Alpha or 1, 0, 1) or 1
    Apply_Palette(Preset_Val)
    if Keep_Accent then Library_Data.Palette.Accent = Accent_Val Library_Data.Palette.Accent2 = Accent_2_Val end
    Config.ThemePreset = Theme_Name
    Config.UiAccentColor = {Color = Library_Data.Palette.Accent, Alpha = Accent_Alpha}
    Config.UiAccent2Color = {Color = Library_Data.Palette.Accent2, Alpha = Accent_2_Alpha}
    Sync_Theme_Editor_State()
    Queue_Save_Config()
end

local function Save_Layout()
    if not writefile or not Ensure_Config_Directory() then return false end
    local Layout_Val = {
        WindowX = Library_Data.TargetPosition.X,
        WindowY = Library_Data.TargetPosition.Y,
        HotkeysX = Library_Data.HotkeysPosition.X,
        HotkeysY = Library_Data.HotkeysPosition.Y,
        StatsX = Library_Data.StatsPosition.X,
        StatsY = Library_Data.StatsPosition.Y
    }
    local Ok_State, Layout_Encoded = pcall(function() return Http_Service:JSONEncode(Layout_Val) end)
    if not Ok_State then return false end
    return pcall(writefile, Get_Layout_Path(), Layout_Encoded)
end

local function Load_Layout()
    local Layout_Path = Get_Layout_Path()
    if not (isfile and readfile and isfile(Layout_Path)) then return false end
    local Ok_State, Layout_Val = pcall(function() return Http_Service:JSONDecode(readfile(Layout_Path)) end)
    if not Ok_State or type(Layout_Val) ~= "table" then return false end
    if type(Layout_Val.WindowX) == "number" and type(Layout_Val.WindowY) == "number" then
        Library_Data.TargetPosition = Clamp_Window_Position(Vector2.new(Layout_Val.WindowX, Layout_Val.WindowY), Library_Data.Size)
        Library_Data.Position = Library_Data.TargetPosition
    end
    if type(Layout_Val.HotkeysX) == "number" and type(Layout_Val.HotkeysY) == "number" then
        Library_Data.HotkeysPosition = Clamp_Window_Position(Vector2.new(Layout_Val.HotkeysX, Layout_Val.HotkeysY), Vector2.new(220, 120))
    end
    if type(Layout_Val.StatsX) == "number" and type(Layout_Val.StatsY) == "number" then
        Library_Data.StatsPosition = Clamp_Window_Position(Vector2.new(Layout_Val.StatsX, Layout_Val.StatsY), Vector2.new(276, 166))
    end
    return true
end

local function Save_Current_Config()
    if not writefile or not Ensure_Config_Directory() then return false end
    local Data_Val = {}
    for Key_Val, Value_In in pairs(Config) do
        local T_Val = type(Value_In)
        if Key_Val ~= "SelectedConfig" and (T_Val == "boolean" or T_Val == "number" or T_Val == "string") then
            Data_Val[Key_Val] = Value_In
        end
    end
    Data_Val.ShowHotkeyList = Config.ShowHotkeyList and true or false
    Data_Val.ThemePreset = tostring(Config.ThemePreset or "Nightfall")
    Data_Val.UiAccentColor = {Hex = Color3_To_Hex(Library_Data.Palette.Accent), Alpha = type(Config.UiAccentColor) == "table" and (Config.UiAccentColor.Alpha or 1) or 1}
    Data_Val.UiAccent2Color = {Hex = Color3_To_Hex(Library_Data.Palette.Accent2), Alpha = type(Config.UiAccent2Color) == "table" and (Config.UiAccent2Color.Alpha or 1) or 1}
    Data_Val.ParryBindMode = Normalize_Bind_Mode(Config.ParryBindMode)
    Data_Val.SpamBindMode = Normalize_Bind_Mode(Config.SpamBindMode)
    Data_Val.TriggerBindMode = Normalize_Bind_Mode(Config.TriggerBindMode)
    local Ok_State, Encoded_Val = pcall(function() return Http_Service:JSONEncode(Data_Val) end)
    if not Ok_State then return false end
    local Saved_State = pcall(writefile, Get_Config_Path(), Encoded_Val)
    if not Saved_State then return false end
    Config.SelectedConfig = Get_Config_Base_Name()
    Config.ConfigName = Config.SelectedConfig
    local Layout_State = Save_Layout()
    Save_Global_Settings()
    Config_Dirty = false
    return Layout_State
end

local function Delete_Named_Config(Name_Val)
    local Target_Val = tostring(Name_Val or "")
    Target_Val = Target_Val:gsub("[^%w%-_]", "_"):sub(1, 48)
    if Target_Val == "" then return false end
    local Old_Config_Name = Config.ConfigName
    Config.ConfigName = Target_Val
    local Cfg_Path = Get_Config_Path()
    local Layout_Path = Get_Layout_Path()
    Config.ConfigName = Old_Config_Name
    local Deleted_Val = false
    if delfile then
        if isfile and isfile(Cfg_Path) then Deleted_Val = pcall(delfile, Cfg_Path) end
        if isfile and isfile(Layout_Path) then pcall(delfile, Layout_Path) end
    end
    local Available_Val = Get_Available_Configs()
    local Fallback_Val = Available_Val[1] or "default"
    if Config.SelectedConfig == Target_Val then Config.SelectedConfig = Fallback_Val end
    if Config.ConfigName == Target_Val then Config.ConfigName = Fallback_Val end
    Save_Global_Settings()
    return Deleted_Val
end

local function Load_Named_Config(Name_Val)
    local Old_Name = Config.ConfigName
    Is_Config_Loading = true
    if Name_Val and Name_Val ~= "" then Config.ConfigName = tostring(Name_Val) end
    local Path_Val = Get_Config_Path()
    if not (isfile and readfile and isfile(Path_Val)) then Config.ConfigName = Old_Name Is_Config_Loading = false return false end
    local Ok_State, Decoded_Val = pcall(function() return Http_Service:JSONDecode(readfile(Path_Val)) end)
    if not Ok_State or type(Decoded_Val) ~= "table" then Config.ConfigName = Old_Name Is_Config_Loading = false return false end
    for Key_Val, Value_In in pairs(Decoded_Val) do
        if Key_Val ~= "UiAccentColor" and Key_Val ~= "UiAccent2Color" and Key_Val ~= "SelectedConfig" and Key_Val ~= "ConfigName" and Key_Val ~= "AutoSaveConfig" and Key_Val ~= "AutoLoadConfig" and Config[Key_Val] ~= nil and type(Config[Key_Val]) == type(Value_In) then
            Config[Key_Val] = Value_In
        end
    end
    Config.ParryBindMode = Normalize_Bind_Mode(Decoded_Val.ParryBindMode or Config.ParryBindMode)
    Config.SpamBindMode = Normalize_Bind_Mode(Decoded_Val.SpamBindMode or Config.SpamBindMode)
    Config.TriggerBindMode = Normalize_Bind_Mode(Decoded_Val.TriggerBindMode or Config.TriggerBindMode)
    Apply_Theme_Preset(Decoded_Val.ThemePreset or Config.ThemePreset or "Nightfall", false)
    if type(Decoded_Val.UiAccentColor) == "table" and Decoded_Val.UiAccentColor.Hex then
        local Ok_Accent, Accent_Val = pcall(Color3.fromHex, Decoded_Val.UiAccentColor.Hex)
        if Ok_Accent and Accent_Val then Library_Data.Palette.Accent = Accent_Val end
    end
    if type(Decoded_Val.UiAccent2Color) == "table" and Decoded_Val.UiAccent2Color.Hex then
        local Ok_Accent2, Accent2_Val = pcall(Color3.fromHex, Decoded_Val.UiAccent2Color.Hex)
        if Ok_Accent2 and Accent2_Val then Library_Data.Palette.Accent2 = Accent2_Val end
    end
    Config.UiAccentColor = {Color = Library_Data.Palette.Accent, Alpha = type(Decoded_Val.UiAccentColor) == "table" and (Decoded_Val.UiAccentColor.Alpha or 1) or 1}
    Config.UiAccent2Color = {Color = Library_Data.Palette.Accent2, Alpha = type(Decoded_Val.UiAccent2Color) == "table" and (Decoded_Val.UiAccent2Color.Alpha or 1) or 1}
    Sync_Theme_Editor_State()
    Load_Layout()
    Register_Keybind("ParryKeybind", Config.ParryKeybind, Config.ParryBindMode)
    Register_Keybind("SpamKeybind", Config.SpamKeybind, Config.SpamBindMode)
    Register_Keybind("TriggerKeybind", Config.TriggerKeybind, Config.TriggerBindMode)
    Config.ConfigName = Get_Config_Base_Name()
    Config.SelectedConfig = Config.ConfigName
    Save_Global_Settings()
    Is_Config_Loading = false
    return true
end

Load_Global_Settings()
Apply_Theme_Preset(Config.ThemePreset or "Nightfall", false)
if Config.AutoLoadConfig then
    Load_Named_Config(Config.SelectedConfig or Config.ConfigName)
else
    Config.ConfigName = tostring(Config.SelectedConfig or Config.ConfigName or "default")
    Load_Layout()
end
Config_Loaded = true

Register_Keybind("ParryKeybind", Config.ParryKeybind, Config.ParryBindMode)
Register_Keybind("SpamKeybind", Config.SpamKeybind, Config.SpamBindMode)
Register_Keybind("TriggerKeybind", Config.TriggerKeybind, Config.TriggerBindMode)
Register_Keybind("HideKeybind", Config.HideKeybind, "Toggle")

local Window_Drawings = {
    Shadow = Make_Rounded_Box(Color3.new(0, 0, 0), 0.18),
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Topbar = Make_Rounded_Box(Library_Data.Palette.Sidebar, 1),
    Sidebar = Make_Rounded_Box(Library_Data.Palette.Sidebar, 1),
    Topline = Make_Gradient_Line(24),
    PatternBack = Make_Stripe_Pattern(28, 11),
    PatternFront = Make_Stripe_Pattern(28, 7),
    SidebarLine = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    TopBorder = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    Title = Create_Drawing("Text", {Text = "Nightfall | Recode", Color = Library_Data.Palette.Text, Size = 13, Font = 2, Outline = true, Visible = false})
}

local Stats_Drawings = {
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Topline = Make_Gradient_Line(20),
    HeaderLine = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    Row1 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row3 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Title = Create_Drawing("Text", {Text = "BALL STATS", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Speed = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Distance = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Dot = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local Tab_Style = {X = 9, Y = 47, W = 132, H = 34, Gap = 5}

local function Get_Tab_Bounds(X_Val, Y_Val, Index_Val)
    return Vector_2_Round(X_Val + Tab_Style.X, Y_Val + Tab_Style.Y + (Index_Val - 1) * (Tab_Style.H + Tab_Style.Gap)), Vector_2_Round(Tab_Style.W, Tab_Style.H)
end

local Keybinds_Drawings = {
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Topline = Make_Gradient_Line(20),
    ToplineCaps = Make_Rounded_Gradient_Caps(),
    HeaderLine = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    TitleIcon = Create_Keybind_Image_Icon(18),
    Title = Create_Drawing("Text", {Text = "HOTKEYS", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Subtitle = Create_Drawing("Text", {Text = "", Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Row1 = Make_Rounded_Box(Library_Data.Palette.Element, 1), Row2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row3 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Bind1 = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind2 = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind3 = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State1 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State2 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State3 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Mode1 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode2 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode3 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    MenuOutline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    MenuBackground = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    MenuOption1 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    MenuOption2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    MenuOption1Text = Create_Drawing("Text", {Text = "Hold", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    MenuOption2Text = Create_Drawing("Text", {Text = "Toggle", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

function Library_Data:CreateTab(Tab_Name, Tab_Icon)
    local Tab_Obj = {
        Name = Tab_Name, Icon = "", Sections = {},
        Border = Make_Rounded_Box(self.Palette.Outline, 1),
        Background = Make_Rounded_Box(self.Palette.Hover, 1),
        RailGlow = Make_Rounded_Box(self.Palette.Accent, 0.15),
        Indicator = Make_Rounded_Box(self.Palette.Accent, 1),
        Detail = Make_Rounded_Box(self.Palette.Accent2, 1),
        Label = Create_Drawing("Text", {Text = Tab_Name, Size = 13, Font = 2, Outline = true, Visible = false}),
        IconDraw = Create_Drawing("Text", {Text = "", Size = 12, Font = 2, Outline = true, Visible = false}),
        CurrentColor = self.Palette.SubText, CurrentIconColor = self.Palette.SubText, BgAlpha = 0
    }
    function Tab_Obj:CreateSection(Section_Name, Section_Side)
        local Section_Obj = {
            Name = Section_Name, Side = Section_Side, Items = {},
            Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
            Background = Make_Rounded_Box(Library_Data.Palette.Section, 1),
            PatternBack = Make_Stripe_Pattern(20, 9), PatternFront = Make_Stripe_Pattern(20, 5),
            Title = Create_Drawing("Text", {Text = Section_Name, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
            Line = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false})
        }
        function Section_Obj:UpdateContainer(X_Val, Y_Val, W_Val, H_Val)
            Update_Rounded_Box(self.Outline, Vector_2_Round(X_Val, Y_Val), Vector_2_Round(W_Val, H_Val), 6, Library_Data.Palette.Outline, 1, true)
            Update_Rounded_Box(self.Background, Vector_2_Round(X_Val + 1, Y_Val + 1), Vector_2_Round(W_Val - 2, H_Val - 2), 6, Library_Data.Palette.Section, 1, true)
            Update_Stripe_Pattern(self.PatternBack, 0, 0, 0, 0, 0, 0, Library_Data.Palette.Background, false)
            Update_Stripe_Pattern(self.PatternFront, 0, 0, 0, 0, 0, 0, Library_Data.Palette.Background, false)
            self.Title.Visible = true
            Position_Text(self.Title, X_Val + 10, Y_Val + 6, "SectionTitle")
            self.Line.Visible = true
            self.Line.Position = Vector_2_Round(X_Val + 10, Y_Val + 25)
            self.Line.Size = Vector_2_Round(W_Val - 20, 1)
            self.Line.Color = Library_Data.Palette.Outline
        end
        function Section_Obj:CreateToggle(Name_Val, Flag_Val, Default_Val)
            Config[Flag_Val] = Config[Flag_Val] ~= nil and Config[Flag_Val] or (Default_Val or false)
            local Toggle_Obj = {
                Type = "Toggle", Height = 24, Flag = Flag_Val,
                BoxStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Box = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                Fill = Make_Rounded_Box(Library_Data.Palette.Accent, 1),
                Label = Create_Drawing("Text", {Text = Name_Val, Size = 12, Font = 2, Outline = true, Visible = false}),
                CurrentColor = Library_Data.Palette.SubText,
                Alpha = Config[Flag_Val] and 1 or 0,
                HitboxPos = Vector2.new(), HitboxSize = Vector2.new()
            }
            function Toggle_Obj:Update(X_Val, Y_Val, W_Val)
                self.HitboxPos = Vector_2_Round(X_Val, Y_Val)
                self.HitboxSize = Vector_2_Round(W_Val, 20)
                Update_Rounded_Box(self.BoxStroke, Vector_2_Round(X_Val + 2, Y_Val + 3), Vector_2_Round(16, 16), 4, Color_Lerp(Library_Data.Palette.Outline, Library_Data.Palette.Accent, self.Alpha), 1, true)
                Update_Rounded_Box(self.Box, Vector_2_Round(X_Val + 3, Y_Val + 4), Vector_2_Round(14, 14), 4, Library_Data.Palette.Element, 1, true)
                self.Label.Visible = true
                Position_Text(self.Label, X_Val + 26, Y_Val + 4, "ToggleLabel")
                local Hovered_Val = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, self.HitboxPos, self.HitboxSize)
                self.CurrentColor = Color_Lerp(self.CurrentColor, Config[self.Flag] and Library_Data.Palette.Text or (Hovered_Val and Library_Data.Palette.Text or Library_Data.Palette.SubText), 0.15)
                self.Label.Color = self.CurrentColor
                self.Alpha = Math_Lerp(self.Alpha, Config[self.Flag] and 1 or 0, 0.2)
                Update_Rounded_Box(self.Fill, Vector_2_Round(X_Val + 5, Y_Val + 6), Vector_2_Round(10, 10), 3, Library_Data.Palette.Accent, self.Alpha, self.Alpha > 0.02)
            end
            table.insert(self.Items, Toggle_Obj)
            return Toggle_Obj
        end
        function Section_Obj:CreateSlider(Name_Val, Flag_Val, Min_Val, Max_Val, Default_Val, Step_Val)
            Config[Flag_Val] = Config[Flag_Val] ~= nil and Config[Flag_Val] or Clamp_Slider_Value(Default_Val or Min_Val, Min_Val, Max_Val, Step_Val)
            local Slider_Obj = {
                Type = "Slider", Height = 44, Min = Min_Val, Max = Max_Val, Step = Step_Val, Flag = Flag_Val,
                InputBuffer = Format_Slider_Value(Config[Flag_Val], Step_Val),
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                Fill = Make_Rounded_Box(Library_Data.Palette.Accent, 1),
                Knob = Make_Rounded_Box(Library_Data.Palette.Text, 1),
                ValuePos = Vector2.new(), ValueSize = Vector2.new(), BarPos = Vector2.new(), BarSize = Vector2.new()
            }
            function Slider_Obj:Update(X_Val, Y_Val, W_Val)
                local Is_Editing = Library_Data.State.ActiveSliderInput == self
                self.Label.Visible = true
                Position_Text(self.Label, X_Val + 2, Y_Val, "SliderLabel")
                local Display_Text = Is_Editing and (((Fast_Tick() % 1) < 0.5) and (self.InputBuffer .. "_") or self.InputBuffer) or Format_Slider_Value(Config[self.Flag], self.Step)
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = Display_Text
                self.ValueLabel.Color = Is_Editing and Library_Data.Palette.Accent or Library_Data.Palette.SubText
                self.ValueSize = Vector_2_Round(Fast_Max(34, math.min(70, #Display_Text * 7 + 10)), 18)
                self.ValuePos = Vector_2_Round(X_Val + W_Val - self.ValueSize.X - 2, Y_Val)
                Position_Text_Centered(self.ValueLabel, self.ValuePos, self.ValueSize, "SliderValue")
                if not Is_Editing then self.InputBuffer = Format_Slider_Value(Config[self.Flag], self.Step) end
                local Bar_Y = Y_Val + 26
                local Bar_Width = Fast_Max(W_Val - 4, 30)
                self.BarPos = Vector_2_Round(X_Val + 2, Bar_Y)
                self.BarSize = Vector_2_Round(Bar_Width, 6)
                Update_Rounded_Box(self.Stroke, self.BarPos, self.BarSize, 3, Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vector_2_Round(X_Val + 3, Bar_Y + 1), Vector_2_Round(Bar_Width - 2, 4), 3, Library_Data.Palette.Element, 1, true)
                local Range_Val = Fast_Max(self.Max - self.Min, 0.0001)
                local Pct_Val = Math_Clamp((Config[self.Flag] - self.Min) / Range_Val, 0, 1)
                local Fill_W = Fast_Max((Bar_Width - 2) * Pct_Val, 0)
                Update_Rounded_Box(self.Fill, Vector_2_Round(X_Val + 3, Bar_Y + 1), Vector_2_Round(Fill_W, 4), 3, Library_Data.Palette.Accent, 1, Fill_W > 0)
                Update_Rounded_Box(self.Knob, Vector_2_Round(X_Val + 3 + Fill_W - 4, Bar_Y - 1), Vector_2_Round(8, 8), 4, Library_Data.Palette.Text, 1, true)
            end
            table.insert(self.Items, Slider_Obj)
            return Slider_Obj
        end
        function Section_Obj:CreateDropdown(Name_Val, Flag_Val, Options_Array, Default_Val)
            Config[Flag_Val] = Config[Flag_Val] ~= nil and Config[Flag_Val] or (Default_Val or Options_Array[1])
            local Dropdown_Obj = {
                Type = "Dropdown", Height = 46, Options = Options_Array or {}, Flag = Flag_Val,
                IsOpen = false, ListHeight = 0, TargetListHeight = 0, OpenAlpha = 0, HoveredIndex = nil,
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                Icon = Create_Drawing("Text", {Text = "+", Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                ListStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                ListBackground = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                OptionDrawings = {}, OptionBounds = {},
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new(), ListPos = Vector2.new(), ListSize = Vector2.new()
            }
            Set_Drawing_Layer(Dropdown_Obj.ListStroke, 12)
            Set_Drawing_Layer(Dropdown_Obj.ListBackground, 13)
            function Dropdown_Obj:SetOptions(New_Options, Preserve_Value)
                self.Options = New_Options or {}
                if not Preserve_Value then
                    if #self.Options > 0 then Config[self.Flag] = self.Options[1] else Config[self.Flag] = nil end
                else
                    local Found_Val = false
                    for _, Option_Val in ipairs(self.Options) do
                        if tostring(Option_Val) == tostring(Config[self.Flag]) then Found_Val = true break end
                    end
                    if not Found_Val then
                        if #self.Options > 0 then Config[self.Flag] = self.Options[1] else Config[self.Flag] = nil end
                    end
                end
                self.OptionBounds = {}
                self.HoveredIndex = nil
            end
            function Dropdown_Obj:GetVisibleOptionBounds()
                local Result_Array = {}
                for Index_Val, Bounds_Val in ipairs(self.OptionBounds) do
                    if Bounds_Val and Bounds_Val.Visible then Result_Array[Index_Val] = Bounds_Val end
                end
                return Result_Array
            end
            function Dropdown_Obj:Update(X_Val, Y_Val, W_Val)
                self.Label.Visible = true
                Position_Text(self.Label, X_Val + 2, Y_Val, "DropdownLabel")
                local Bar_Y = Y_Val + 20
                self.ButtonPos = Vector_2_Round(X_Val + 2, Bar_Y)
                self.ButtonSize = Vector_2_Round(W_Val - 4, 24)
                local Button_Outline_Color = self.IsOpen and Library_Data.Palette.Accent or Library_Data.Palette.Outline
                local Button_Text_Color = self.IsOpen and Library_Data.Palette.Text or Library_Data.Palette.SubText
                Update_Rounded_Box(self.Stroke, self.ButtonPos, self.ButtonSize, 4, Button_Outline_Color, 1, true)
                Update_Rounded_Box(self.Background, Vector_2_Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector_2_Round(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, Library_Data.Palette.Element, 1, true)
                local Current_Value = Config[self.Flag]
                local Selected_Index = nil
                for Idx_Val, Option_Val in ipairs(self.Options) do
                    if tostring(Option_Val) == tostring(Current_Value) then Selected_Index = Idx_Val Current_Value = Option_Val break end
                end
                if Selected_Index == nil and #self.Options > 0 then Current_Value = self.Options[1] Config[self.Flag] = Current_Value Selected_Index = 1 end
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = tostring(Current_Value or "")
                Position_Text(self.ValueLabel, self.ButtonPos.X + 6, self.ButtonPos.Y + 5, "DropdownValue")
                self.ValueLabel.Color = Button_Text_Color
                self.Icon.Visible = true
                self.Icon.Text = self.IsOpen and "-" or "+"
                Position_Text_Centered(self.Icon, Vector_2_Round(self.ButtonPos.X + self.ButtonSize.X - 23, self.ButtonPos.Y), Vector_2_Round(20, self.ButtonSize.Y), "DropdownIcon")
                self.Icon.Color = Button_Text_Color
                self.TargetListHeight = self.IsOpen and (#self.Options * 24 + (#self.Options > 0 and 2 or 0)) or 0
                if not self.IsOpen then
                    self.ListHeight = 0
                    self.OpenAlpha = 0
                end
                self.ListHeight = Math_Lerp(self.ListHeight, self.TargetListHeight, 0.3)
                if math.abs(self.ListHeight - self.TargetListHeight) < 0.5 then self.ListHeight = self.TargetListHeight end
                self.OpenAlpha = Math_Lerp(self.OpenAlpha, self.IsOpen and 1 or 0, 0.3)
                if math.abs(self.OpenAlpha - (self.IsOpen and 1 or 0)) < 0.02 then self.OpenAlpha = self.IsOpen and 1 or 0 end
                local Draw_List_Height = Fast_Max(0, Math_Round(self.ListHeight))
                local List_Visible = Draw_List_Height > 1 and self.OpenAlpha > 0.02
                self.ListPos = Vector_2_Round(self.ButtonPos.X, self.ButtonPos.Y + self.ButtonSize.Y + 2)
                self.ListSize = Vector_2_Round(self.ButtonSize.X, Draw_List_Height)
                Update_Rounded_Box(self.ListStroke, self.ListPos, self.ListSize, 4, Library_Data.Palette.Outline, self.OpenAlpha, List_Visible)
                Update_Rounded_Box(self.ListBackground, Vector_2_Round(self.ListPos.X + 1, self.ListPos.Y + 1), Vector_2_Round(Fast_Max(self.ListSize.X - 2, 0), Fast_Max(self.ListSize.Y - 2, 0)), 4, Library_Data.Palette.Element, self.OpenAlpha, List_Visible)
                self.OptionBounds = {}
                self.HoveredIndex = nil
                for I_Idx, Option_Str in ipairs(self.Options) do
                    if not self.OptionDrawings[I_Idx] then
                        self.OptionDrawings[I_Idx] = Create_Drawing("Text", {Text = tostring(Option_Str), Size = 12, Font = 2, Outline = true, Visible = false, ZIndex = 14})
                    end
                    local Txt_Draw = self.OptionDrawings[I_Idx]
                    local Option_Pos = Vector_2_Round(self.ListPos.X + 6, self.ListPos.Y + 3 + ((I_Idx - 1) * 24))
                    local Option_Size = Vector_2_Round(self.ListSize.X - 12, 20)
                    local Option_Bottom = Option_Pos.Y + Option_Size.Y
                    local Clip_Bottom = self.ListPos.Y + Draw_List_Height - 2
                    local Option_Visible = List_Visible and Option_Pos.Y >= self.ListPos.Y + 1 and Option_Bottom <= Clip_Bottom + 1
                    self.OptionBounds[I_Idx] = {Pos = Option_Pos, Size = Option_Size, Visible = Option_Visible}
                    if Option_Visible and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Option_Pos, Option_Size) then self.HoveredIndex = I_Idx end
                    Txt_Draw.Visible = Option_Visible
                    if Option_Visible then
                        Txt_Draw.Text = tostring(Option_Str)
                        Position_Text(Txt_Draw, Option_Pos.X, Option_Pos.Y + 3, "DropdownOption")
                        if Selected_Index == I_Idx then Txt_Draw.Color = Library_Data.Palette.Accent
                        elseif self.HoveredIndex == I_Idx then Txt_Draw.Color = Library_Data.Palette.Text
                        else Txt_Draw.Color = Library_Data.Palette.SubText
                        end
                        Txt_Draw.Transparency = Fast_Max(self.OpenAlpha, 0.08)
                    end
                end
                for I_Idx = #self.Options + 1, #self.OptionDrawings do self.OptionDrawings[I_Idx].Visible = false end
                self.Height = 46 + (List_Visible and (Draw_List_Height + 4) or 0)
            end
            table.insert(self.Items, Dropdown_Obj)
            return Dropdown_Obj
        end
        function Section_Obj:CreateColorPicker(Name_Val, Flag_Val, Default_Color, Default_Alpha, Callback_Func)
            local Initial_Color = Default_Color or Library_Data.Palette.Accent
            local Initial_Alpha = Default_Alpha == nil and 1 or Default_Alpha
            if type(Config[Flag_Val]) ~= "table" or not Config[Flag_Val].Color then
                Config[Flag_Val] = {Color = Initial_Color, Alpha = Math_Clamp(Initial_Alpha, 0, 1)}
            end
            local H_Val, S_Val, V_Val = Color3_To_Hsv(Config[Flag_Val].Color)
            local Color_Picker = {
                Type = "ColorPicker", Height = 36, Flag = Flag_Val, Callback = Callback_Func,
                IsOpen = false, Hue = H_Val, Sat = S_Val, Val = V_Val,
                Alpha = Math_Clamp(Config[Flag_Val].Alpha or 1, 0, 1),
                HexEditing = false, HexBuffer = "",
                GridCols = 22, GridRows = 12, HueSteps = 30, AlphaSteps = 30,
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                PreviewStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Preview = Make_Rounded_Box(Config[Flag_Val].Color, 1),
                PreviewText = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                PopupShadow = Make_Rounded_Box(Color3.new(0, 0, 0), 0.36),
                PopupStroke = Make_Rounded_Box(Library_Data.Palette.OutlineLight, 1),
                PopupBackground = Make_Rounded_Box(Library_Data.Palette.Background, 1),
                PopupTitle = Create_Drawing("Text", {Text = "COLOR PICKER", Color = Library_Data.Palette.Text, Size = 12, Outline = true, Visible = false}),
                PopupHint = Create_Drawing("Text", {Text = "HSV  /  ALPHA", Color = Library_Data.Palette.SubText, Size = 10, Visible = false}),
                PopupRule = Create_Drawing("Square", {Filled = true, Visible = false}),
                PopupSwatchStroke = Make_Rounded_Box(Library_Data.Palette.OutlineLight, 1),
                PopupSwatch = Make_Rounded_Box(Config[Flag_Val].Color, 1),
                PopupHex = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 11, Outline = true, Visible = false}),
                HexStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                HexBackground = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                SVStroke = Make_Rounded_Box(Library_Data.Palette.OutlineLight, 1),
                HueStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                AlphaStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                SVGrid = Create_Grid_Squares(22 * 12),
                HueGrid = Create_Grid_Squares(30),
                AlphaGrid = Create_Grid_Squares(30),
                CursorOuter = Create_Drawing("Circle", {Filled = false, Thickness = 2, NumSides = 28, Radius = 6, Visible = false}),
                CursorInner = Create_Drawing("Circle", {Filled = false, Thickness = 1, NumSides = 28, Radius = 4, Visible = false}),
                HueCursor = Create_Drawing("Square", {Filled = true, Visible = false}),
                AlphaCursor = Create_Drawing("Square", {Filled = true, Visible = false}),
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new(),
                PopupPos = Vector2.new(), PopupSize = Vector2.new(),
                SVPos = Vector2.new(), SVSize = Vector2.new(),
                HuePos = Vector2.new(), HueSize = Vector2.new(),
                AlphaPos = Vector2.new(), AlphaSize = Vector2.new(),
                HexPos = Vector2.new(), HexSize = Vector2.new()
            }
            local Rounded_Parts = {"PopupShadow", "PopupStroke", "PopupBackground", "PopupSwatchStroke", "PopupSwatch", "HexStroke", "HexBackground", "SVStroke", "HueStroke", "AlphaStroke"}
            local Text_Parts = {"PopupTitle", "PopupHint", "PopupHex", "PopupRule"}
            for _, Part_Name in ipairs(Rounded_Parts) do Set_Drawing_Layer(Color_Picker[Part_Name], 45) end
            for _, Part_Name in ipairs(Text_Parts) do Set_Drawing_Layer(Color_Picker[Part_Name], 48) end
            for _, Item_Draw in ipairs(Color_Picker.SVGrid) do Set_Drawing_Layer(Item_Draw, 46) end
            for _, Item_Draw in ipairs(Color_Picker.HueGrid) do Set_Drawing_Layer(Item_Draw, 46) end
            for _, Item_Draw in ipairs(Color_Picker.AlphaGrid) do Set_Drawing_Layer(Item_Draw, 46) end
            for _, Part_Name in ipairs({"CursorOuter", "CursorInner", "HueCursor", "AlphaCursor"}) do
                Set_Drawing_Layer(Color_Picker[Part_Name], 47)
            end
            function Color_Picker:SyncColor()
                local State_Val = Config[self.Flag]
                if type(State_Val) ~= "table" then State_Val = {} Config[self.Flag] = State_Val end
                State_Val.Color = Hsv_To_Color3(self.Hue, self.Sat, self.Val)
                State_Val.Alpha = Math_Clamp(self.Alpha, 0, 1)
                if self.Callback then self.Callback(State_Val) end
                Queue_Save_Config()
            end
            function Color_Picker:CommitHex()
                local Cleaned = tostring(self.HexBuffer or ""):gsub("#", "")
                if #Cleaned == 6 and Cleaned:match("^%x%x%x%x%x%x$") then
                    local R = tonumber(Cleaned:sub(1, 2), 16)
                    local G = tonumber(Cleaned:sub(3, 4), 16)
                    local B = tonumber(Cleaned:sub(5, 6), 16)
                    if R and G and B then
                        self.Hue, self.Sat, self.Val = Color3_To_Hsv(Color3.fromRGB(R, G, B))
                        self:SyncColor()
                    end
                end
                self.HexEditing = false
                self.HexBuffer = ""
            end
            function Color_Picker:HidePopup()
                if not self._PopupDrawn then return end
                self._PopupDrawn = false
                self._SVGridHue = nil
                self._SVGridPos = nil
                self._HueGridPos = nil
                self._AlphaGridPos = nil
                for _, Part_Name in ipairs(Rounded_Parts) do
                    local Obj = self[Part_Name]
                    Update_Rounded_Box(Obj, Vector2.new(), Vector2.new(), 0, Library_Data.Palette.Background, 1, false)
                end
                for _, Part_Name in ipairs(Text_Parts) do self[Part_Name].Visible = false end
                for _, Part_Name in ipairs({"CursorOuter", "CursorInner", "HueCursor", "AlphaCursor"}) do self[Part_Name].Visible = false end
                Hide_Grid_Squares(self.SVGrid)
                Hide_Grid_Squares(self.HueGrid)
                Hide_Grid_Squares(self.AlphaGrid)
            end
            function Color_Picker:Update(X_Val, Y_Val, W_Val)
                local State_Val = Config[self.Flag]
                local Current_Color = State_Val and State_Val.Color or Hsv_To_Color3(self.Hue, self.Sat, self.Val)
                local Current_Hex = Color3_To_Hex(Current_Color)
                self.Height = 36
                self.Label.Visible = true
                Position_Text(self.Label, X_Val + 2, Y_Val + 4, "ColorPickerLabel")
                self.ButtonPos = Vector_2_Round(X_Val + W_Val - 91, Y_Val + 4)
                self.ButtonSize = Vector2.new(87, 24)
                Update_Rounded_Box(self.Stroke, self.ButtonPos, self.ButtonSize, 5, self.IsOpen and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, self.ButtonPos + Vector2.new(1, 1), self.ButtonSize - Vector2.new(2, 2), 4, Library_Data.Palette.Element, 1, true)
                Update_Rounded_Box(self.PreviewStroke, self.ButtonPos + Vector2.new(5, 5), Vector2.new(16, 14), 3, Library_Data.Palette.OutlineLight, 1, true)
                Update_Rounded_Box(self.Preview, self.ButtonPos + Vector2.new(6, 6), Vector2.new(14, 12), 2, Current_Color, 1, true)
                self.PreviewText.Text = Current_Hex
                self.PreviewText.Color = Library_Data.Palette.SubText
                self.PreviewText.Visible = true
                Position_Text(self.PreviewText, self.ButtonPos.X + 25, self.ButtonPos.Y + 7, "ColorPickerValue")
                if not self.IsOpen then self:HidePopup() return end
                local Width, Height = 264, 251
                local Popup_X = self.ButtonPos.X + self.ButtonSize.X - Width
                local Popup_Y = self.ButtonPos.Y + self.ButtonSize.Y + 7
                local Camera_Val = Workspace_Service.CurrentCamera
                local View = Camera_Val and Camera_Val.ViewportSize or Vector2.new(1920, 1080)
                if Popup_X + Width > View.X - 6 then Popup_X = View.X - Width - 6 end
                if Popup_X < 6 then Popup_X = 6 end
                if Popup_Y + Height > View.Y - 6 then Popup_Y = self.ButtonPos.Y - Height - 7 end
                Popup_Y = Math_Clamp(Popup_Y, 6, Fast_Max(6, View.Y - Height - 6))
                self.PopupPos = Vector_2_Round(Popup_X, Popup_Y)
                self.PopupSize = Vector2.new(Width, Height)
                self._PopupDrawn = true
                local PX, PY = self.PopupPos.X, self.PopupPos.Y
                Update_Rounded_Box(self.PopupShadow, Vector2.new(PX - 3, PY - 3), Vector2.new(Width + 6, Height + 6), 8, Color3.new(0, 0, 0), 0.38, true)
                Update_Rounded_Box(self.PopupStroke, self.PopupPos, self.PopupSize, 7, Library_Data.Palette.OutlineLight, 1, true)
                Update_Rounded_Box(self.PopupBackground, self.PopupPos + Vector2.new(1, 1), self.PopupSize - Vector2.new(2, 2), 7, Library_Data.Palette.Background, 1, true)
                self.PopupTitle.Visible = true
                Position_Text(self.PopupTitle, PX + 13, PY + 12)
                self.PopupHint.Visible = true
                Position_Text(self.PopupHint, PX + 173, PY + 14)
                self.PopupRule.Visible = true
                self.PopupRule.Color = Library_Data.Palette.Outline
                self.PopupRule.Position = Vector2.new(PX + 10, PY + 33)
                self.PopupRule.Size = Vector2.new(Width - 20, 1)
                self.SVPos = Vector2.new(PX + 12, PY + 44)
                self.SVSize = Vector2.new(240, 116)
                Update_Rounded_Box(self.SVStroke, self.SVPos - Vector2.new(1, 1), self.SVSize + Vector2.new(2, 2), 3, Library_Data.Palette.OutlineLight, 1, true)
                if self._SVGridHue ~= self.Hue or self._SVGridPos ~= tostring(PX) .. ":" .. tostring(PY) then
                    Update_Grid_Squares(self.SVGrid, self.GridCols, self.GridRows, self.SVPos.X, self.SVPos.Y, self.SVSize.X, self.SVSize.Y, function(Col, Row, Cols, Rows)
                        local S = (Col - 0.5) / Cols
                        local V = 1 - (Row - 0.5) / Rows
                        return Hsv_To_Color3(self.Hue, S, V)
                    end, true)
                    self._SVGridHue = self.Hue
                    self._SVGridPos = tostring(PX) .. ":" .. tostring(PY)
                end
                self.HuePos = Vector2.new(PX + 12, PY + 173)
                self.HueSize = Vector2.new(240, 12)
                Update_Rounded_Box(self.HueStroke, self.HuePos - Vector2.new(1, 1), self.HueSize + Vector2.new(2, 2), 3, Library_Data.Palette.Outline, 1, true)
                if self._HueGridPos ~= tostring(PX) .. ":" .. tostring(PY) then
                    Update_Grid_Squares(self.HueGrid, self.HueSteps, 1, self.HuePos.X, self.HuePos.Y, self.HueSize.X, self.HueSize.Y, function(Col, _, Cols)
                        return Hsv_To_Color3((Col - 0.5) / Cols, 1, 1)
                    end, true)
                    self._HueGridPos = tostring(PX) .. ":" .. tostring(PY)
                end
                self.AlphaPos = Vector2.new(PX + 12, PY + 195)
                self.AlphaSize = Vector2.new(240, 12)
                Update_Rounded_Box(self.AlphaStroke, self.AlphaPos - Vector2.new(1, 1), self.AlphaSize + Vector2.new(2, 2), 3, Library_Data.Palette.Outline, 1, true)
                if self._AlphaGridPos ~= tostring(PX) .. ":" .. tostring(PY) or self._AlphaGridHex ~= Current_Hex then
                    Update_Grid_Squares(self.AlphaGrid, self.AlphaSteps, 1, self.AlphaPos.X, self.AlphaPos.Y, self.AlphaSize.X, self.AlphaSize.Y, function(Col, _, Cols)
                        local A = (Col - 0.5) / Cols
                        return Color_Lerp(Library_Data.Palette.Element, Current_Color, A)
                    end, true)
                    self._AlphaGridPos = tostring(PX) .. ":" .. tostring(PY)
                    self._AlphaGridHex = Current_Hex
                end
                self.CursorOuter.Visible = true
                self.CursorOuter.Color = Color3.new(0, 0, 0)
                self.CursorOuter.Position = Vector_2_Round(self.SVPos.X + self.Sat * self.SVSize.X, self.SVPos.Y + (1 - self.Val) * self.SVSize.Y)
                self.CursorOuter.Radius = 6
                self.CursorInner.Visible = true
                self.CursorInner.Color = Color3.new(1, 1, 1)
                self.CursorInner.Position = self.CursorOuter.Position
                self.CursorInner.Radius = 4
                local HX = Math_Clamp(self.Hue, 0, 1) * (self.HueSize.X - 2)
                local AX = Math_Clamp(self.Alpha, 0, 1) * (self.AlphaSize.X - 2)
                self.HueCursor.Visible = true
                self.HueCursor.Position = Vector_2_Round(self.HuePos.X + HX, self.HuePos.Y - 3)
                self.HueCursor.Size = Vector2.new(3, 18)
                self.HueCursor.Color = Library_Data.Palette.Text
                self.AlphaCursor.Visible = true
                self.AlphaCursor.Position = Vector_2_Round(self.AlphaPos.X + AX, self.AlphaPos.Y - 3)
                self.AlphaCursor.Size = Vector2.new(3, 18)
                self.AlphaCursor.Color = Library_Data.Palette.Text
                self.HexPos = Vector2.new(PX + 12, PY + 219)
                self.HexSize = Vector2.new(171, 24)
                Update_Rounded_Box(self.HexStroke, self.HexPos, self.HexSize, 4, self.HexEditing and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.HexBackground, self.HexPos + Vector2.new(1, 1), self.HexSize - Vector2.new(2, 2), 4, Library_Data.Palette.Element, 1, true)
                self.PopupHex.Visible = true
                self.PopupHex.Text = self.HexEditing and ("#" .. tostring(self.HexBuffer) .. "_") or Current_Hex
                self.PopupHex.Color = self.HexEditing and Library_Data.Palette.Text or Library_Data.Palette.SubText
                Position_Text(self.PopupHex, self.HexPos.X + 9, self.HexPos.Y + 6)
                Update_Rounded_Box(self.PopupSwatchStroke, Vector2.new(PX + 193, PY + 219), Vector2.new(59, 24), 4, Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.PopupSwatch, Vector2.new(PX + 194, PY + 220), Vector2.new(57, 22), 4, Current_Color, Math_Clamp(self.Alpha, 0.12, 1), true)
            end
            table.insert(self.Items, Color_Picker)
            return Color_Picker
        end
        function Section_Obj:CreateKeybind(Name_Val, Flag_Val, Default_Val)
            Config[Flag_Val] = Normalize_Keybind_Value(Config[Flag_Val] ~= nil and Config[Flag_Val] or (Default_Val or "None"))
            local Keybind_Obj = {
                Type = "Keybind", Height = 30, Flag = Flag_Val,
                Icon = Create_Keybind_Image_Icon(18),
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                ButtonBox = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new()
            }
            function Keybind_Obj:Update(X_Val, Y_Val, W_Val)
                Update_Keybind_Image_Icon(self.Icon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false)
                self.Label.Visible = true
                Position_Text(self.Label, X_Val + 2, Y_Val + 8, "KeybindLabel")
                local Bind_Value = Normalize_Keybind_Value(Config[self.Flag]) or "None"
                local Bind_Text = Library_Data.State.ActiveKeybind == self and "[...]" or ("[" .. Bind_Value .. "]")
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = Bind_Text
                local Btn_Width = Math_Clamp(#Bind_Text * 7 + 20, 74, 108)
                self.ButtonPos = Vector_2_Round(X_Val + W_Val - Btn_Width - 2, Y_Val + 4)
                self.ButtonSize = Vector_2_Round(Btn_Width, 22)
                local Is_Active = Library_Data.State.ActiveKeybind == self
                Update_Keybind_Image_Icon(self.Icon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false)
                Update_Rounded_Box(self.ButtonStroke, self.ButtonPos, self.ButtonSize, 4, Is_Active and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.ButtonBox, Vector_2_Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector_2_Round(Btn_Width - 2, 20), 4, Is_Active and Library_Data.Palette.Hover or Library_Data.Palette.Element, 1, true)
                self.ValueLabel.Color = Is_Active and Library_Data.Palette.Text or Library_Data.Palette.SubText
                Position_Text_Centered(self.ValueLabel, self.ButtonPos, self.ButtonSize, "KeybindValue")
            end
            table.insert(self.Items, Keybind_Obj)
            return Keybind_Obj
        end
        function Section_Obj:CreateButton(Name_Val, Callback_Func)
            local Button_Obj = {
                Type = "Button", Height = 34, Callback = Callback_Func,
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(), ButtonSize = Vector2.new()
            }
            function Button_Obj:Update(X_Val, Y_Val, W_Val)
                self.ButtonPos = Vector_2_Round(X_Val + 2, Y_Val + 4)
                self.ButtonSize = Vector_2_Round(W_Val - 4, 24)
                local Hovered_Val = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, self.ButtonPos, self.ButtonSize)
                Update_Rounded_Box(self.Stroke, self.ButtonPos, self.ButtonSize, 4, Hovered_Val and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vector_2_Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector_2_Round(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, Hovered_Val and Library_Data.Palette.Hover or Library_Data.Palette.Element, 1, true)
                self.Label.Visible = true
                self.Label.Color = Library_Data.Palette.Text
                Position_Text_Centered(self.Label, self.ButtonPos, self.ButtonSize, "ButtonLabel")
            end
            table.insert(self.Items, Button_Obj)
            return Button_Obj
        end
        function Section_Obj:CreateTextbox(Name_Val, Flag_Val, Default_Val)
            Config[Flag_Val] = Config[Flag_Val] ~= nil and Config[Flag_Val] or (Default_Val or "")
            local Textbox_Obj = {
                Type = "Textbox", Height = 36, Flag = Flag_Val,
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                BoxPos = Vector2.new(), BoxSize = Vector2.new()
            }
            function Textbox_Obj:Update(X_Val, Y_Val, W_Val)
                self.Label.Visible = true
                Position_Text(self.Label, X_Val + 2, Y_Val + 4, "TextboxLabel")
                local Box_Width = 110
                self.BoxPos = Vector_2_Round(X_Val + W_Val - Box_Width - 2, Y_Val + 6)
                self.BoxSize = Vector_2_Round(Box_Width, 24)
                local Is_Active = Library_Data.State.ActiveTextbox == self
                Update_Rounded_Box(self.Stroke, self.BoxPos, self.BoxSize, 4, Is_Active and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vector_2_Round(self.BoxPos.X + 1, self.BoxPos.Y + 1), Vector_2_Round(Box_Width - 2, 22), 4, Library_Data.Palette.Element, 1, true)
                local Display_Str = tostring(Config[self.Flag] or "")
                if #Display_Str > 15 then Display_Str = string.sub(Display_Str, -15) end
                if Is_Active and Fast_Tick() % 1 < 0.5 then Display_Str = Display_Str .. "_" end
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = Display_Str
                self.ValueLabel.Color = Is_Active and Library_Data.Palette.Text or Library_Data.Palette.SubText
                Position_Text(self.ValueLabel, X_Val + W_Val - Box_Width + 3, Y_Val + 11, "TextboxValue")
            end
            table.insert(self.Items, Textbox_Obj)
            return Textbox_Obj
        end
        table.insert(Tab_Obj.Sections, Section_Obj)
        return Section_Obj
    end
    table.insert(Library_Data.Tabs, Tab_Obj)
    if not Library_Data.CurrentTab then Library_Data.CurrentTab = Tab_Obj end
    return Tab_Obj
end


local Overlay_Menu_Drawings = {
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Option1 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Option2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Option1Text = Create_Drawing("Text", {Text = "Hold", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Option2Text = Create_Drawing("Text", {Text = "Toggle", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

for _, Overlay_Obj in pairs(Overlay_Menu_Drawings) do Set_Drawing_Layer(Overlay_Obj, 30) end

local function Close_Transient_Ui()
    if Library_Data.State.ActiveDropdown then Library_Data.State.ActiveDropdown.IsOpen = false end
    if Library_Data.State.ActiveColorPicker then Library_Data.State.ActiveColorPicker.IsOpen = false Library_Data.State.ActiveColorPicker.HexEditing = false end
    Library_Data.State.ActiveDropdown = nil
    Library_Data.State.ActiveSlider = nil
    if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) end
    Library_Data.State.ActiveSliderInput = nil
    Library_Data.State.ActiveTextbox = nil
    Library_Data.State.ActiveKeybind = nil
    Library_Data.State.ActiveColorPicker = nil
    Library_Data.State.ActiveColorDrag = nil
    Library_Data.State.Dragging = false
    Library_Data._captureLast = nil
    Library_Data.State.HotkeysContext.Open = false
    Library_Data.State.HotkeysContext.Entry = nil
    Library_Data.State.KeybindContext.Open = false
    Library_Data.State.KeybindContext.Entry = nil
end

local function Hide_Stats_Drawings()
    Update_Rounded_Box(Stats_Drawings.Outline, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Stats_Drawings.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Gradient_Line(Stats_Drawings.Topline, Vector_2_Round(0, 0), Vector_2_Round(0, 0), Color3.new(0, 0, 0), Color3.new(0, 0, 0), false)
    Stats_Drawings.HeaderLine.Visible = false
    Update_Rounded_Box(Stats_Drawings.Row1, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Stats_Drawings.Row2, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Stats_Drawings.Row3, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Stats_Drawings.Title.Visible = false
    Stats_Drawings.Speed.Visible = false
    Stats_Drawings.Distance.Visible = false
    Stats_Drawings.Dot.Visible = false
end

local function Hide_Hotkeys_Drawings()
    Update_Rounded_Box(Keybinds_Drawings.Outline, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Keybinds_Drawings.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Hide_Rounded_Gradient(Keybinds_Drawings.Topline, Keybinds_Drawings.ToplineCaps)
    Keybinds_Drawings.HeaderLine.Visible = false
    Update_Keybind_Image_Icon(Keybinds_Drawings.TitleIcon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false)
    Keybinds_Drawings.Title.Visible = false
    Keybinds_Drawings.Subtitle.Visible = false
    for _, Row_Obj in ipairs({Keybinds_Drawings.Row1, Keybinds_Drawings.Row2, Keybinds_Drawings.Row3, Keybinds_Drawings.MenuOutline, Keybinds_Drawings.MenuBackground, Keybinds_Drawings.MenuOption1, Keybinds_Drawings.MenuOption2}) do
        Update_Rounded_Box(Row_Obj, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end
    for _, Txt_Obj in ipairs({
        Keybinds_Drawings.Bind1, Keybinds_Drawings.Bind2, Keybinds_Drawings.Bind3,
        Keybinds_Drawings.State1, Keybinds_Drawings.State2, Keybinds_Drawings.State3,
        Keybinds_Drawings.Mode1, Keybinds_Drawings.Mode2, Keybinds_Drawings.Mode3,
        Keybinds_Drawings.MenuOption1Text, Keybinds_Drawings.MenuOption2Text
    }) do
        Txt_Obj.Visible = false
    end
end

local function Safe_Hide_Drawing(Draw_Obj)
    if Draw_Obj then Draw_Obj.Visible = false end
end

local function Hide_Item(Item_Obj)
    if not Item_Obj then return end
    if Item_Obj.Type == "Toggle" then
        if Item_Obj.BoxStroke then Update_Rounded_Box(Item_Obj.BoxStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Box then Update_Rounded_Box(Item_Obj.Box, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Fill then Update_Rounded_Box(Item_Obj.Fill, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        Safe_Hide_Drawing(Item_Obj.Label)
    elseif Item_Obj.Type == "Slider" then
        if Item_Obj.Stroke then Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Background then Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Fill then Update_Rounded_Box(Item_Obj.Fill, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Knob then Update_Rounded_Box(Item_Obj.Knob, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        Safe_Hide_Drawing(Item_Obj.Label) Safe_Hide_Drawing(Item_Obj.ValueLabel)
    elseif Item_Obj.Type == "Dropdown" then
        Item_Obj.IsOpen = false Item_Obj.ListHeight = 0 Item_Obj.TargetListHeight = 0 Item_Obj.OpenAlpha = 0
        Safe_Hide_Drawing(Item_Obj.Label) Safe_Hide_Drawing(Item_Obj.ValueLabel) Safe_Hide_Drawing(Item_Obj.Icon)
        if Item_Obj.Stroke then Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Background then Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.ListStroke then Update_Rounded_Box(Item_Obj.ListStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.ListBackground then Update_Rounded_Box(Item_Obj.ListBackground, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        for _, Draw_Obj in ipairs(Item_Obj.OptionDrawings or {}) do Safe_Hide_Drawing(Draw_Obj) end
    elseif Item_Obj.Type == "ColorPicker" then
        Item_Obj.IsOpen = false
        Item_Obj.HexEditing = false
        if Item_Obj.HidePopup then Item_Obj:HidePopup() end
        Safe_Hide_Drawing(Item_Obj.Label)
        Safe_Hide_Drawing(Item_Obj.PreviewText)
        for _, Name in ipairs({"Stroke", "Background", "PreviewStroke", "Preview"}) do
            if Item_Obj[Name] then Update_Rounded_Box(Item_Obj[Name], Vector2.new(), Vector2.new(), 0, Library_Data.Palette.Background, 1, false) end
        end
    elseif Item_Obj.Type == "Keybind" then
        if Item_Obj.Icon then Update_Keybind_Image_Icon(Item_Obj.Icon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false) end
        Safe_Hide_Drawing(Item_Obj.Label) Safe_Hide_Drawing(Item_Obj.ValueLabel)
        if Item_Obj.ButtonStroke then Update_Rounded_Box(Item_Obj.ButtonStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.ButtonBox then Update_Rounded_Box(Item_Obj.ButtonBox, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
    elseif Item_Obj.Type == "Textbox" then
        Safe_Hide_Drawing(Item_Obj.Label) Safe_Hide_Drawing(Item_Obj.ValueLabel)
        if Item_Obj.Stroke then Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Background then Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
    elseif Item_Obj.Type == "Button" then
        Safe_Hide_Drawing(Item_Obj.Label)
        if Item_Obj.Stroke then Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
        if Item_Obj.Background then Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false) end
    end
end

local function Hide_Tab_Content(Tab_Obj)
    if not Tab_Obj then return end
    for _, Section_Obj in ipairs(Tab_Obj.Sections) do
        Update_Rounded_Box(Section_Obj.Outline, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Section_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Hide_Stripe_Pattern(Section_Obj.PatternBack)
        Hide_Stripe_Pattern(Section_Obj.PatternFront)
        Section_Obj.Title.Visible = false
        Section_Obj.Line.Visible = false
        for _, Item_Obj in ipairs(Section_Obj.Items) do Hide_Item(Item_Obj) end
    end
end

local Hide_Window_Drawings
local function Apply_Held_Backspace()
    local Target_Slider = Library_Data.State.ActiveSliderInput
    local Target_Textbox = Library_Data.State.ActiveTextbox
    if not Target_Slider and not Target_Textbox then
        Library_Data.State.BackspaceHeld = false
        Library_Data.State.BackspaceNextRepeat = 0
        return
    end
    local Is_Backspace_Down = Keys_Down[Enum.KeyCode.Backspace] or false
    if not Is_Backspace_Down then
        Library_Data.State.BackspaceHeld = false
        Library_Data.State.BackspaceNextRepeat = 0
        return
    end
    local Now_Val = Fast_Tick()
    if not Library_Data.State.BackspaceHeld then
        Library_Data.State.BackspaceHeld = true
        Library_Data.State.BackspaceNextRepeat = Now_Val + 0.42
        return
    end
    if Now_Val < (Library_Data.State.BackspaceNextRepeat or 0) then return end
    Library_Data.State.BackspaceNextRepeat = Now_Val + 0.035
    if Target_Slider then
        local Current_Text = tostring(Target_Slider.InputBuffer or "")
        Target_Slider.InputBuffer = string.sub(Current_Text, 1, -2)
    elseif Target_Textbox then
        local Current_Text = tostring(Config[Target_Textbox.Flag] or "")
        Config[Target_Textbox.Flag] = string.sub(Current_Text, 1, -2)
        if Target_Textbox.Flag ~= "ConfigName" then Queue_Save_Config() end
    end
end

Hide_Window_Drawings = function()
    Update_Rounded_Box(Window_Drawings.Shadow, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Outline, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Topbar, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Sidebar, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Hide_Gradient_Line(Window_Drawings.Topline)
    Hide_Stripe_Pattern(Window_Drawings.PatternBack)
    Hide_Stripe_Pattern(Window_Drawings.PatternFront)
    Window_Drawings.SidebarLine.Visible = false
    Window_Drawings.TopBorder.Visible = false
    Window_Drawings.Title.Visible = false
    for _, Obj_Val in pairs(Overlay_Menu_Drawings) do Set_Visible(Obj_Val, false) end
    for _, Tab_Obj in ipairs(Library_Data.Tabs) do
        for _, Draw_Obj in ipairs({Tab_Obj.Border, Tab_Obj.Background, Tab_Obj.RailGlow, Tab_Obj.Indicator, Tab_Obj.Detail}) do
            Update_Rounded_Box(Draw_Obj, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        Tab_Obj.Label.Visible = false
        Tab_Obj.IconDraw.Visible = false
        Hide_Tab_Content(Tab_Obj)
    end
end

local function Is_Mouse_Button_Pressed(Code_Val)
    if Code_Val == 4 then
        return iskeypressed and iskeypressed(4) or false
    elseif Code_Val == 5 then
        return iskeypressed and iskeypressed(5) or false
    elseif Code_Val == 6 then
        return iskeypressed and iskeypressed(6) or false
    elseif Code_Val == 7 then
        return iskeypressed and iskeypressed(7) or false
    end
    return false
end

local Text_Key_Digits = {
    Zero = "0", One = "1", Two = "2", Three = "3", Four = "4",
    Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
    KeypadZero = "0", KeypadOne = "1", KeypadTwo = "2", KeypadThree = "3",
    KeypadFour = "4", KeypadFive = "5", KeypadSix = "6", KeypadSeven = "7",
    KeypadEight = "8", KeypadNine = "9", KeypadPeriod = ".",
    KeypadMinus = "-", Minus = "-", Period = ".", Underscore = "_"
}

local function Get_Typed_Character(Key_Code)
    local Key_Name = tostring(Key_Code.Name or "")
    local Key_Value = Key_Code.Value or 0
    local Shift_State = Keys_Down[Enum.KeyCode.LeftShift] or Keys_Down[Enum.KeyCode.RightShift]
    if Key_Value >= 65 and Key_Value <= 90 then
        return Shift_State and string.upper(Key_Name) or string.lower(Key_Name)
    end
    local Digit_Val = Text_Key_Digits[Key_Name]
    if Digit_Val then
        if Digit_Val == "-" and Shift_State then return "_" end
        return Digit_Val
    end
    if Key_Value >= 48 and Key_Value <= 57 then return tostring(Key_Value - 48) end
    if Key_Value >= 96 and Key_Value <= 105 then return tostring(Key_Value - 96) end
    if Key_Name == "Space" then return " " end
    return nil
end

Connect_Session(User_Input_Service.InputBegan, function(Input_Object, Game_Processed)
    local Key_Code = Input_Object and Input_Object.KeyCode
    if not Key_Code then return end
    if Enum.KeyCode.MouseButton1 and Key_Code == Enum.KeyCode.MouseButton1 then
        Library_Data.Input.Mouse1EventDown = true
        Library_Data.Input.Mouse1ClickQueued = true
        return
    end
    Keys_Down[Key_Code] = true
    local EditingPicker = Library_Data.State.ActiveColorPicker
    if EditingPicker and EditingPicker.IsOpen and EditingPicker.HexEditing then
        if Key_Code == Enum.KeyCode.Return or Key_Code == Enum.KeyCode.KeypadEnter then
            EditingPicker:CommitHex()
        elseif Key_Code == Enum.KeyCode.Escape then
            EditingPicker.HexEditing = false
            EditingPicker.HexBuffer = ""
        elseif Key_Code == Enum.KeyCode.Backspace then
            EditingPicker.HexBuffer = tostring(EditingPicker.HexBuffer or ""):sub(1, -2)
        else
            local Char = tostring(Key_Code.Name or "")
            if #Char == 1 and Char:match("^[a-fA-F]$") then
                if #EditingPicker.HexBuffer < 6 then EditingPicker.HexBuffer = EditingPicker.HexBuffer .. Char:upper() end
            elseif #Char == 1 and Char:match("^%d$") then
                if #EditingPicker.HexBuffer < 6 then EditingPicker.HexBuffer = EditingPicker.HexBuffer .. Char end
            else
                local D = {Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9", KeypadZero = "0", KeypadOne = "1", KeypadTwo = "2", KeypadThree = "3", KeypadFour = "4", KeypadFive = "5", KeypadSix = "6", KeypadSeven = "7", KeypadEight = "8", KeypadNine = "9"}
                local Ch = D[Char]
                if Ch and #EditingPicker.HexBuffer < 6 then EditingPicker.HexBuffer = EditingPicker.HexBuffer .. Ch end
            end
        end
        return
    end
    if Game_Processed or not Library_Data.Visible then return end
    local Active_Slider = Library_Data.State.ActiveSliderInput
    local Active_Box = Library_Data.State.ActiveTextbox
    if Active_Slider or Active_Box then
        local Current_Text = Active_Slider and tostring(Active_Slider.InputBuffer or "") or tostring(Config[Active_Box.Flag] or "")
        if Key_Code == Enum.KeyCode.Backspace then
            Current_Text = string.sub(Current_Text, 1, -2)
        elseif Key_Code == Enum.KeyCode.Return or Key_Code == Enum.KeyCode.KeypadEnter or Key_Code == Enum.KeyCode.Escape then
            if Active_Slider then
                Commit_Slider_Input(Active_Slider)
                Library_Data.State.ActiveSliderInput = nil
            else
                Library_Data.State.ActiveTextbox = nil
                if Active_Box.Flag == "ConfigName" then Save_Global_Settings() end
            end
            Library_Data.State.BackspaceHeld = false
            return
        else
            local Character_Val = Get_Typed_Character(Key_Code)
            if not Character_Val then return end
            if Active_Slider and not Character_Val:match("[%d%.%-]") then return end
            if #Current_Text >= 48 then return end
            Current_Text = Current_Text .. Character_Val
        end
        if Active_Slider then
            Active_Slider.InputBuffer = Current_Text
        else
            Config[Active_Box.Flag] = Current_Text
            if Active_Box.Flag ~= "ConfigName" then Queue_Save_Config() end
        end
        return
    end
    if Library_Data.State.ActiveKeybind then return end
    if Key_Code == Enum.KeyCode.Escape then Close_Transient_Ui() end
end)

Connect_Session(User_Input_Service.InputEnded, function(Input_Object)
    local Key_Code = Input_Object and Input_Object.KeyCode
    if Enum.KeyCode.MouseButton1 and Key_Code == Enum.KeyCode.MouseButton1 then
        Library_Data.Input.Mouse1EventDown = false
        Library_Data.Input.Mouse1ReleaseQueued = true
    end
    if Key_Code then Keys_Down[Key_Code] = false end
end)

local Frame_Counter = 0

Connect_Session(Run_Service.Heartbeat, function()
    if Config_Dirty and Config.AutoSaveConfig and (Fast_Tick() - Save_Queue_Tick > 1.5) then
        Save_Current_Config()
    end
end)

Connect_Session(Run_Service.RenderStepped, function()
    if isrbxactive and not isrbxactive() then
        Library_Data.State.Dragging = false
        Library_Data.State.HotkeysDragging = false
        Library_Data.State.StatsDragging = false
        Library_Data.State.ActiveSlider = nil
        Library_Data.State.ActiveColorDrag = nil
        Library_Data.Input.Mouse1Prev = false
        Library_Data.Input.Mouse1EventDown = false
        Library_Data.Input.Mouse1ClickQueued = false
        Library_Data.Input.Mouse1ReleaseQueued = false
        Library_Data.Input.Mouse2Prev = false
        Update_Keybinds()
        return
    end

    local Mouse_Pos = Vector2.new(Local_Mouse.X, Local_Mouse.Y)
    Library_Data.Input.MousePos = Mouse_Pos
    local PolledMouse1 = ismouse1pressed and ismouse1pressed() or false
    local Mouse1_Down = (PolledMouse1 or Library_Data.Input.Mouse1EventDown) and not Library_Data.Input.Mouse1ReleaseQueued
    Library_Data.Input.Mouse1Down = Mouse1_Down
    Library_Data.Input.Mouse1Clicked = (Mouse1_Down and not Library_Data.Input.Mouse1Prev) or Library_Data.Input.Mouse1ClickQueued
    Library_Data.Input.Mouse1Released = (not Mouse1_Down and Library_Data.Input.Mouse1Prev) or Library_Data.Input.Mouse1ReleaseQueued
    Library_Data.Input.Mouse1Prev = Mouse1_Down
    Library_Data.Input.Mouse1ClickQueued = false
    Library_Data.Input.Mouse1ReleaseQueued = false

    Library_Data.Input.Mouse2Down = ismouse2pressed and ismouse2pressed() or false
    Library_Data.Input.Mouse2Clicked = Library_Data.Input.Mouse2Down and not Library_Data.Input.Mouse2Prev
    Library_Data.Input.Mouse2Prev = Library_Data.Input.Mouse2Down

    local Mouse4_Down = Is_Mouse_Button_Pressed(4)
    Library_Data.Input.Mouse4Clicked = Mouse4_Down and not Library_Data.Input.Mouse4Prev
    Library_Data.Input.Mouse4Released = not Mouse4_Down and Library_Data.Input.Mouse4Prev
    Library_Data.Input.Mouse4Prev = Mouse4_Down

    local Mouse5_Down = Is_Mouse_Button_Pressed(5)
    Library_Data.Input.Mouse5Clicked = Mouse5_Down and not Library_Data.Input.Mouse5Prev
    Library_Data.Input.Mouse5Released = not Mouse5_Down and Library_Data.Input.Mouse5Prev
    Library_Data.Input.Mouse5Prev = Mouse5_Down
    Library_Data.Input.Mouse5Down = Mouse5_Down

    Update_Keybinds()

    do
        local Hide_Code = Name_To_Code[Normalize_Keybind_Value(Config.HideKeybind)]
        local Pressed_State = Hide_Code and iskeypressed(Hide_Code) or false
        if Library_Data._suppressHideUntilRelease then
            if not Pressed_State then Library_Data._suppressHideUntilRelease = nil end
            Pressed_State = false
        end
        if Library_Data.State.ActiveKeybind or Library_Data.State.ActiveTextbox or Library_Data.State.ActiveSliderInput then
            Pressed_State = false
        end
        local Was_Pressed = Library_Data._lastHidePressed or false

        if Pressed_State and not Was_Pressed then
            if not Library_Data.BindPressed then
                Library_Data.Visible = not Library_Data.Visible
                Library_Data.BindPressed = true
                if not Library_Data.Visible then
                    Close_Transient_Ui()
                    Hide_Window_Drawings()
                end
            end
        end
        if not Pressed_State then
            Library_Data.BindPressed = false
        end
        Library_Data._lastHidePressed = Pressed_State
    end

    Apply_Held_Backspace()

    if Library_Data.State.ActiveKeybind then
        if not Library_Data._captureLast then
            Library_Data._captureLast = {}
            for Code_Val in pairs(Key_Codes) do
                Library_Data._captureLast[Code_Val] = iskeypressed(Code_Val) or false
            end
        end
        local Capture_Code
        for Code_Val in pairs(Key_Codes) do
            local Is_Pressed = iskeypressed(Code_Val) or false
            if Is_Pressed and not Library_Data._captureLast[Code_Val] and not Capture_Code then Capture_Code = Code_Val end
            Library_Data._captureLast[Code_Val] = Is_Pressed
        end
        if Capture_Code then
            local Flag_Name = Library_Data.State.ActiveKeybind.Flag
            if Capture_Code == 27 then
                Library_Data.State.ActiveKeybind = nil
            else
                local Name_Val = Capture_Code == 8 and "None" or Key_Codes[Capture_Code]
                Config[Flag_Name] = Name_Val
                Register_Keybind(Flag_Name, Name_Val, Get_Bind_Mode(Flag_Name))
                if Flag_Name == "HideKeybind" then Library_Data._suppressHideUntilRelease = true end
                Queue_Save_Config()
                Library_Data.State.ActiveKeybind = nil
            end
            Library_Data._captureLast = nil
        end
    else
        Library_Data._captureLast = nil
    end

    local Hotkeys_Size = Vector2.new(220, 120)
    local Stats_Size = Vector_2_Round(276, 166)
    local Should_Show_Hotkeys = Config.ShowHotkeyList
    local Show_Stats = Config.RenderBallStats
    
    local Player_Character = Local_Player.Character
    local Is_Dead = false
    if Workspace_Service:FindFirstChild("Dead") and Player_Character and Player_Character.Parent == Workspace_Service.Dead then Is_Dead = true end
    if Player_Character and Player_Character:FindFirstChild("SingularityCape") then Is_Dead = true end
    if Player_Character and Player_Character.PrimaryPart and Player_Character.PrimaryPart:FindFirstChild("SingularityCape") then Is_Dead = true end
    if Is_Dead then Show_Stats = false end

    if Should_Show_Hotkeys then
        Library_Data.HotkeysPosition = Clamp_Window_Position(Library_Data.HotkeysPosition, Hotkeys_Size)
        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Library_Data.HotkeysPosition, Vector2.new(Hotkeys_Size.X, 28)) then
            Library_Data.State.HotkeysDragging = true
            Library_Data.State.HotkeysDragStart = Library_Data.Input.MousePos
            Library_Data.State.HotkeysWindowStart = Library_Data.HotkeysPosition
            Close_Transient_Ui()
        end
        if Library_Data.Input.Mouse1Released and Library_Data.State.HotkeysDragging then
        Library_Data.State.HotkeysDragging = false
        Save_Layout()
    end
        if Library_Data.State.HotkeysDragging then
            Library_Data.HotkeysPosition = Clamp_Window_Position(Library_Data.State.HotkeysWindowStart + (Library_Data.Input.MousePos - Library_Data.State.HotkeysDragStart), Hotkeys_Size)
        end
        local Binds_Size = Vector_2_Round(Hotkeys_Size.X, Hotkeys_Size.Y)
        local Binds_Pos = Clamp_Window_Position(Vector_2_Round(Library_Data.HotkeysPosition.X, Library_Data.HotkeysPosition.Y), Binds_Size)
        Library_Data.HotkeysPosition = Binds_Pos
        Update_Rounded_Box(Keybinds_Drawings.Outline, Binds_Pos, Binds_Size, 8, Library_Data.Palette.Outline, 1, true)
        Update_Rounded_Box(Keybinds_Drawings.Background, Vector_2_Round(Binds_Pos.X + 1, Binds_Pos.Y + 1), Vector_2_Round(Binds_Size.X - 2, Binds_Size.Y - 2), 8, Library_Data.Palette.Background, 1, true)
        Update_Rounded_Gradient(Keybinds_Drawings.Topline, Keybinds_Drawings.ToplineCaps, Binds_Pos, Binds_Size, Library_Data.Palette.Accent, Library_Data.Palette.Accent2, true)
        Keybinds_Drawings.HeaderLine.Visible = true
        Keybinds_Drawings.HeaderLine.Position = Vector_2_Round(Binds_Pos.X + 8, Binds_Pos.Y + 30)
        Keybinds_Drawings.HeaderLine.Size = Vector_2_Round(Binds_Size.X - 16, 1)
        Keybinds_Drawings.HeaderLine.Color = Library_Data.Palette.Outline
        Update_Keybind_Image_Icon(Keybinds_Drawings.TitleIcon, Vector_2_Round(Binds_Pos.X + 8, Binds_Pos.Y + 6), Library_Data.Palette.Accent, false)
        Keybinds_Drawings.Title.Visible = true
        Position_Text(Keybinds_Drawings.Title, Binds_Pos.X + 8, Binds_Pos.Y + 6, "HotkeysTitle")
        Keybinds_Drawings.Subtitle.Visible = false
        
        local Hotkey_Entries = {
            {BindFlag = "ParryKeybind", ToggleFlag = "AutoParry", Label = "Parry"},
            {BindFlag = "SpamKeybind", ToggleFlag = "AutoSpam", Label = "Spam"},
            {BindFlag = "TriggerKeybind", ToggleFlag = "TriggerBot", Label = "Trigger"}
        }
        local Row_X = Binds_Pos.X + 8
        local Row_W = Binds_Size.X - 16
        local Row_H = 20
        local Row_Start_Y = Binds_Pos.Y + 36
        local Row_Gap = 4
        local Hotkey_Rows = {
            {X = Row_X, Y = Row_Start_Y, W = Row_W, H = Row_H, Entry = Hotkey_Entries[1]},
            {X = Row_X, Y = Row_Start_Y + (Row_H + Row_Gap) * 1, W = Row_W, H = Row_H, Entry = Hotkey_Entries[2]},
            {X = Row_X, Y = Row_Start_Y + (Row_H + Row_Gap) * 2, W = Row_W, H = Row_H, Entry = Hotkey_Entries[3]}
        }
        local Row_Boxes = {Keybinds_Drawings.Row1, Keybinds_Drawings.Row2, Keybinds_Drawings.Row3}
        local Bind_Texts = {Keybinds_Drawings.Bind1, Keybinds_Drawings.Bind2, Keybinds_Drawings.Bind3}
        local State_Texts = {Keybinds_Drawings.State1, Keybinds_Drawings.State2, Keybinds_Drawings.State3}
        local Mode_Texts = {Keybinds_Drawings.Mode1, Keybinds_Drawings.Mode2, Keybinds_Drawings.Mode3}
        for I_Idx, Row_Val in ipairs(Hotkey_Rows) do
            local Row_Box = Row_Boxes[I_Idx]
            local Bind_Draw = Bind_Texts[I_Idx]
            local State_Draw = State_Texts[I_Idx]
            local Mode_Draw = Mode_Texts[I_Idx]
            local Bind_Value = Normalize_Keybind_Value(Config[Row_Val.Entry.BindFlag])
            local Bind_Mode = Get_Bind_Mode(Row_Val.Entry.BindFlag)
            local Is_Enabled = Config[Row_Val.Entry.ToggleFlag] and true or false
            local Row_Hovered = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Vector_2_Round(Row_Val.X, Row_Val.Y), Vector_2_Round(Row_Val.W, Row_Val.H))
            local Row_Color = Is_Enabled and Library_Data.Palette.Hover or (Row_Hovered and Library_Data.Palette.Hover or Library_Data.Palette.Element)
            Update_Rounded_Box(Row_Box, Vector_2_Round(Row_Val.X, Row_Val.Y), Vector_2_Round(Row_Val.W, Row_Val.H), 4, Row_Color, 1, true)
            Bind_Draw.Visible = true
            Bind_Draw.Text = "[" .. string.upper(Bind_Value) .. "]  " .. Row_Val.Entry.Label
            Bind_Draw.Color = Is_Enabled and Library_Data.Palette.Text or Color_Lerp(Library_Data.Palette.SubText, Library_Data.Palette.Text, Row_Hovered and 0.35 or 0)
            Position_Text(Bind_Draw, Row_Val.X + 8, Row_Val.Y + 3, "HotkeysRow")
            local State_Column_W = 30
            local Mode_Column_W = 48
            local State_Text_X = Row_Val.X + Row_Val.W - State_Column_W - 6
            local Mode_Text_X = State_Text_X - Mode_Column_W - 6
            State_Draw.Visible = true
            State_Draw.Text = Is_Enabled and "ON" or "OFF"
            State_Draw.Color = Is_Enabled and Library_Data.Palette.Text or Library_Data.Palette.SubText
            Position_Text(State_Draw, State_Text_X, Row_Val.Y + 3, "HotkeysRow")
            Mode_Draw.Visible = true
            Mode_Draw.Text = string.upper(Bind_Mode)
            Mode_Draw.Color = Bind_Mode == "Hold" and Library_Data.Palette.Accent2 or Library_Data.Palette.Accent
            Position_Text(Mode_Draw, Mode_Text_X, Row_Val.Y + 3, "HotkeysRow")
            if Library_Data.Visible and Library_Data.Input.Mouse2Clicked and Row_Hovered then
                local Bind_Context = {ButtonPos = Vector2.new(Row_Val.X, Row_Val.Y), ButtonSize = Vector2.new(Row_Val.W, Row_Val.H)}
                Library_Data.State.KeybindContext.Open = true
                Library_Data.State.KeybindContext.Entry = Row_Val.Entry
                Library_Data.State.KeybindContext.Position = Get_Context_Menu_Position(Bind_Context)
            end
        end
    else
        Hide_Hotkeys_Drawings()
        Library_Data.State.HotkeysDragging = false
        Library_Data.State.HotkeysContext.Open = false
        Library_Data.State.HotkeysContext.Entry = nil
    end

    Library_Data.StatsPosition = Clamp_Window_Position(Library_Data.StatsPosition, Stats_Size)
    local Stats_Pos = Vector_2_Round(Library_Data.StatsPosition.X, Library_Data.StatsPosition.Y)

    if Show_Stats then
        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Library_Data.StatsPosition, Vector2.new(Stats_Size.X, 36)) then
            Library_Data.State.StatsDragging = true
            Library_Data.State.StatsDragStart = Library_Data.Input.MousePos
            Library_Data.State.StatsWindowStart = Library_Data.StatsPosition
            Close_Transient_Ui()
        end
        if Library_Data.Input.Mouse1Released and Library_Data.State.StatsDragging then
            Library_Data.State.StatsDragging = false
            Save_Layout()
        end
        if Library_Data.State.StatsDragging then
            Library_Data.StatsPosition = Clamp_Window_Position(Library_Data.State.StatsWindowStart + (Library_Data.Input.MousePos - Library_Data.State.StatsDragStart), Stats_Size)
            Stats_Pos = Vector_2_Round(Library_Data.StatsPosition.X, Library_Data.StatsPosition.Y)
        end
        
        Update_Rounded_Box(Stats_Drawings.Outline, Stats_Pos, Stats_Size, 8, Library_Data.Palette.Outline, 1, true)
        Update_Rounded_Box(Stats_Drawings.Background, Vector_2_Round(Stats_Pos.X + 1, Stats_Pos.Y + 1), Vector_2_Round(Stats_Size.X - 2, Stats_Size.Y - 2), 8, Library_Data.Palette.Background, 1, true)
        Update_Gradient_Line(Stats_Drawings.Topline, Vector_2_Round(Stats_Pos.X + 1, Stats_Pos.Y + 1), Vector_2_Round(Stats_Size.X - 2, 2), Library_Data.Palette.Accent, Library_Data.Palette.Accent2, true)
        Stats_Drawings.HeaderLine.Visible = true
        Stats_Drawings.Title.Visible = true
        Stats_Drawings.Speed.Visible = true
        Stats_Drawings.Distance.Visible = true
        Stats_Drawings.Dot.Visible = true
        
        Stats_Drawings.HeaderLine.Position = Vector_2_Round(Stats_Pos.X + 12, Stats_Pos.Y + 40)
        Stats_Drawings.HeaderLine.Size = Vector_2_Round(Stats_Size.X - 24, 1)
        Stats_Drawings.HeaderLine.Color = Library_Data.Palette.Outline
        local Row_X = Stats_Pos.X + 12
        local Row_W = Stats_Size.X - 24
        local Row_H = 30
        local Row_1_Y = Stats_Pos.Y + 50
        local Row_2_Y = Row_1_Y + 36
        local Row_3_Y = Row_2_Y + 36
        Update_Rounded_Box(Stats_Drawings.Row1, Vector_2_Round(Row_X, Row_1_Y), Vector_2_Round(Row_W, Row_H), 6, Library_Data.Palette.Element, 1, true)
        Update_Rounded_Box(Stats_Drawings.Row2, Vector_2_Round(Row_X, Row_2_Y), Vector_2_Round(Row_W, Row_H), 6, Library_Data.Palette.Element, 1, true)
        Update_Rounded_Box(Stats_Drawings.Row3, Vector_2_Round(Row_X, Row_3_Y), Vector_2_Round(Row_W, Row_H), 6, Library_Data.Palette.Element, 1, true)
        local Speed_Value = Fast_Max(0, Fast_Floor(tonumber(Runtime_State.Target_Speed) or 0))
        local Distance_Value = Fast_Max(0, Fast_Floor(tonumber(Runtime_State.Target_Distance) or 0))
        local Dot_Value = tonumber(Runtime_State.Target_Dot) or 0
        Position_Text(Stats_Drawings.Title, Stats_Pos.X + 12, Stats_Pos.Y + 8, "StatsTitle")
        Stats_Drawings.Title.Text = "BALL STATS"
        Position_Text(Stats_Drawings.Speed, Stats_Pos.X + 20, Row_1_Y + 8, "StatsRow")
        Stats_Drawings.Speed.Text = "Ball Speed : " .. tostring(Speed_Value)
        Stats_Drawings.Speed.Color = Library_Data.Palette.Text
        Position_Text(Stats_Drawings.Distance, Stats_Pos.X + 20, Row_2_Y + 8, "StatsRow")
        Stats_Drawings.Distance.Text = "Ball Dist  : " .. tostring(Distance_Value)
        Stats_Drawings.Distance.Color = Library_Data.Palette.Text
        Position_Text(Stats_Drawings.Dot, Stats_Pos.X + 20, Row_3_Y + 8, "StatsRow")
        Stats_Drawings.Dot.Text = "Ball Dot   : " .. string.format("%.2f", Dot_Value)
        Stats_Drawings.Dot.Color = Library_Data.Palette.Text
    else
        Library_Data.State.StatsDragging = false
        Hide_Stats_Drawings()
    end

    if not Library_Data.Visible then
        if Library_Data.wasVisible ~= false then
            Close_Transient_Ui()
            Hide_Window_Drawings()
            Library_Data.wasVisible = false
        end
        return
    else
        Library_Data.wasVisible = true
    end

    Frame_Counter = (Frame_Counter or 0) + 1
    local Is_Interacting = Library_Data.State.Dragging or 
                           Library_Data.State.HotkeysDragging or 
                           Library_Data.State.StatsDragging or 
                           Library_Data.State.ActiveSlider or 
                           Library_Data.State.ActiveColorDrag or 
                           Library_Data.State.ActiveColorPicker or 
                           Library_Data.State.ActiveDropdown or 
                           Library_Data.State.ActiveKeybind or 
                           Library_Data.State.ActiveTextbox

    local Skip_Heavy_Update = (Frame_Counter % 2 == 0) and not Is_Interacting
    local Size_X, Size_Y = Library_Data.Size.X, Library_Data.Size.Y
    
    Library_Data.TargetPosition = Clamp_Window_Position(Library_Data.TargetPosition, Library_Data.Size)
    if not Library_Data.State.Dragging then
        Library_Data.Position = Clamp_Window_Position(Library_Data.Position, Library_Data.Size)
    end
    local OverHotkeys = Config.ShowHotkeyList and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Library_Data.HotkeysPosition, Vector2.new(Hotkeys_Size.X, 28))
    local OverStats = Show_Stats and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Library_Data.StatsPosition, Vector2.new(Stats_Size.X, 36))
    if Library_Data.Input.Mouse1Clicked and not Library_Data.State.ActiveColorPicker and not OverHotkeys and not OverStats and not Library_Data.State.HotkeysDragging and not Library_Data.State.StatsDragging and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Library_Data.Position, Vector2.new(Size_X, 36)) then
        Close_Transient_Ui()
        Library_Data.State.Dragging = true
        Library_Data.State.DragStart = Library_Data.Input.MousePos
        Library_Data.State.WindowStart = Library_Data.TargetPosition
    end
    if Library_Data.Input.Mouse1Released then
        if Library_Data.State.Dragging then Save_Layout() end
        Library_Data.State.Dragging = false
        Library_Data.State.ActiveSlider = nil
    end
    if Library_Data.State.Dragging then
        Library_Data.TargetPosition = Clamp_Window_Position(Library_Data.State.WindowStart + (Library_Data.Input.MousePos - Library_Data.State.DragStart), Library_Data.Size)
        Library_Data.Position = Library_Data.TargetPosition
    else
        Library_Data.Position = Vector2.new(Math_Lerp(Library_Data.Position.X, Library_Data.TargetPosition.X, 0.25), Math_Lerp(Library_Data.Position.Y, Library_Data.TargetPosition.Y, 0.25))
    end
    
    local Pos_X, Pos_Y = Library_Data.Position.X, Library_Data.Position.Y
    Update_Rounded_Box(Window_Drawings.Shadow, Vector_2_Round(Pos_X - 3, Pos_Y - 3), Vector_2_Round(Size_X + 6, Size_Y + 6), 6, Color3.new(0, 0, 0), 0.18, true)
    Update_Rounded_Box(Window_Drawings.Outline, Vector_2_Round(Pos_X - 1, Pos_Y - 1), Vector_2_Round(Size_X + 2, Size_Y + 2), 6, Library_Data.Palette.Outline, 1, true)
    Update_Rounded_Box(Window_Drawings.Background, Vector_2_Round(Pos_X, Pos_Y), Vector_2_Round(Size_X, Size_Y), 6, Library_Data.Palette.Background, 1, true)
    Update_Rounded_Box(Window_Drawings.Topbar, Vector_2_Round(Pos_X, Pos_Y), Vector_2_Round(Size_X, 36), 6, Library_Data.Palette.Sidebar, 1, true)
    Update_Rounded_Box(Window_Drawings.Sidebar, Vector_2_Round(Pos_X, Pos_Y + 37), Vector_2_Round(150, Size_Y - 37), 6, Library_Data.Palette.Sidebar, 1, true)
    Update_Gradient_Line(Window_Drawings.Topline, Vector_2_Round(Pos_X + 1, Pos_Y + 1), Vector_2_Round(Size_X - 2, 2), Library_Data.Palette.Accent, Library_Data.Palette.Accent2, true)
    Update_Stripe_Pattern(Window_Drawings.PatternBack, 0, 0, 0, 0, 0, 0, Library_Data.Palette.Background, false)
    Update_Stripe_Pattern(Window_Drawings.PatternFront, 0, 0, 0, 0, 0, 0, Library_Data.Palette.Background, false)
    Window_Drawings.TopBorder.Visible = true
    Window_Drawings.TopBorder.Position = Vector_2_Round(Pos_X, Pos_Y + 36)
    Window_Drawings.TopBorder.Size = Vector_2_Round(Size_X, 1)
    Window_Drawings.TopBorder.Color = Library_Data.Palette.Outline
    Window_Drawings.SidebarLine.Visible = true
    Window_Drawings.SidebarLine.Position = Vector_2_Round(Pos_X + 150, Pos_Y + 37)
    Window_Drawings.SidebarLine.Size = Vector_2_Round(1, Size_Y - 37)
    Window_Drawings.SidebarLine.Color = Library_Data.Palette.Outline
    Window_Drawings.Title.Visible = true
    Position_Text(Window_Drawings.Title, Pos_X + 15, Pos_Y + 11, "WindowTitle")
    
    if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Vector2.new(Pos_X, Pos_Y + 37), Vector2.new(150, Size_Y - 37)) then
        for Tab_Index, Tab_Obj in ipairs(Library_Data.Tabs) do
            local Tab_Pos, Tab_Size = Get_Tab_Bounds(Pos_X, Pos_Y, Tab_Index)
            if Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Tab_Pos, Tab_Size) then
                if Library_Data.CurrentTab ~= Tab_Obj then
                    Library_Data.CurrentTab = Tab_Obj
                    Close_Transient_Ui()
                    for _, T_Obj in ipairs(Library_Data.Tabs) do Hide_Tab_Content(T_Obj) end
                end
                break
            end
        end
    end
    
    if Library_Data.State.KeybindContext.Open and Library_Data.State.KeybindContext.Entry and Library_Data.Visible then
        local Menu_Pos = Library_Data.State.KeybindContext.Position
        local Menu_Size = Vector2.new(128, 66)
        local Option_Size = Vector2.new(118, 24)
        local Hold_Pos = Vector_2_Round(Menu_Pos.X + 5, Menu_Pos.Y + 6)
        local Toggle_Pos = Vector_2_Round(Menu_Pos.X + 5, Menu_Pos.Y + 35)
        local Current_Mode = Get_Bind_Mode(Library_Data.State.KeybindContext.Entry.BindFlag)
        local Hold_Hovered = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Hold_Pos, Option_Size)
        local Toggle_Hovered = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Toggle_Pos, Option_Size)
        local Hold_Selected = Current_Mode == "Hold"
        local Toggle_Selected = Current_Mode == "Toggle"
        if Library_Data.Input.Mouse1Clicked then
            if Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Hold_Pos, Option_Size) then
                Set_Bind_Mode(Library_Data.State.KeybindContext.Entry.BindFlag, "Hold")
                Queue_Save_Config()
                Library_Data.State.KeybindContext.Open = false
                Library_Data.State.KeybindContext.Entry = nil
            elseif Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Toggle_Pos, Option_Size) then
                Set_Bind_Mode(Library_Data.State.KeybindContext.Entry.BindFlag, "Toggle")
                Queue_Save_Config()
                Library_Data.State.KeybindContext.Open = false
                Library_Data.State.KeybindContext.Entry = nil
            elseif not Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Menu_Pos, Menu_Size) then
                Library_Data.State.KeybindContext.Open = false
                Library_Data.State.KeybindContext.Entry = nil
            end
        elseif Library_Data.Input.Mouse2Clicked and not Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Menu_Pos, Menu_Size) then
            Library_Data.State.KeybindContext.Open = false
            Library_Data.State.KeybindContext.Entry = nil
        end
        local Context_Visible = Library_Data.State.KeybindContext.Open
        Update_Rounded_Box(Overlay_Menu_Drawings.Outline, Menu_Pos, Menu_Size, 6, Library_Data.Palette.Outline, 1, Context_Visible)
        Update_Rounded_Box(Overlay_Menu_Drawings.Background, Vector_2_Round(Menu_Pos.X + 1, Menu_Pos.Y + 1), Vector_2_Round(Menu_Size.X - 2, Menu_Size.Y - 2), 6, Library_Data.Palette.Background, 1, Context_Visible)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option1, Hold_Pos, Option_Size, 5, Hold_Selected and Library_Data.Palette.Accent or (Hold_Hovered and Library_Data.Palette.Hover or Library_Data.Palette.Element), 1, Context_Visible)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option2, Toggle_Pos, Option_Size, 5, Toggle_Selected and Library_Data.Palette.Accent or (Toggle_Hovered and Library_Data.Palette.Hover or Library_Data.Palette.Element), 1, Context_Visible)
        Overlay_Menu_Drawings.Option1Text.Visible = Context_Visible
        Overlay_Menu_Drawings.Option1Text.Text = "Hold"
        Overlay_Menu_Drawings.Option1Text.Color = Hold_Selected and Library_Data.Palette.Text or (Hold_Hovered and Library_Data.Palette.Text or Library_Data.Palette.SubText)
        Position_Text(Overlay_Menu_Drawings.Option1Text, Hold_Pos.X + 42, Hold_Pos.Y + 5, "ContextOption")
        Overlay_Menu_Drawings.Option2Text.Visible = Context_Visible
        Overlay_Menu_Drawings.Option2Text.Text = "Toggle"
        Overlay_Menu_Drawings.Option2Text.Color = Toggle_Selected and Library_Data.Palette.Text or (Toggle_Hovered and Library_Data.Palette.Text or Library_Data.Palette.SubText)
        Position_Text(Overlay_Menu_Drawings.Option2Text, Toggle_Pos.X + 34, Toggle_Pos.Y + 5, "ContextOption")
    else
        Update_Rounded_Box(Overlay_Menu_Drawings.Outline, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Overlay_Menu_Drawings.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option1, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option2, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Overlay_Menu_Drawings.Option1Text.Visible = false
        Overlay_Menu_Drawings.Option2Text.Visible = false
    end
    
    if Library_Data.CurrentTab then
        local Block_Input = Library_Data.State.Dragging or Library_Data.State.StatsDragging or Library_Data.State.KeybindContext.Open
        if Library_Data.State.ActiveDropdown then
            local Dropdown_Obj = Library_Data.State.ActiveDropdown
            if Library_Data.Input.Mouse1Clicked then
                local Mouse_Pos = Library_Data.Input.MousePos
                local Inside_Current_Button = Is_Mouse_In_Bounds(Mouse_Pos, Dropdown_Obj.ButtonPos, Dropdown_Obj.ButtonSize)
                local Clicked_Dropdown = nil
                for _, Section_Obj in ipairs(Library_Data.CurrentTab.Sections) do
                    for _, Candidate_Obj in ipairs(Section_Obj.Items) do
                        if Candidate_Obj.Type == "Dropdown" and Is_Mouse_In_Bounds(Mouse_Pos, Candidate_Obj.ButtonPos, Candidate_Obj.ButtonSize) then
                            Clicked_Dropdown = Candidate_Obj break
                        end
                    end
                    if Clicked_Dropdown then break end
                end
                if Clicked_Dropdown then
                    if Clicked_Dropdown == Dropdown_Obj then
                        Dropdown_Obj.IsOpen = false
                        Library_Data.State.ActiveDropdown = nil
                    else
                        Dropdown_Obj.IsOpen = false
                        Clicked_Dropdown.IsOpen = true
                        Clicked_Dropdown.OpenAlpha = 0
                        Clicked_Dropdown.ListHeight = 0
                        Clicked_Dropdown.TargetListHeight = 0
                        Library_Data.State.ActiveDropdown = Clicked_Dropdown
                    end
                    Block_Input = true
                else
                    local Picked_Option = nil
                    for Index_Val, Bounds_Val in ipairs(Dropdown_Obj.OptionBounds or {}) do
                        if Bounds_Val and Bounds_Val.Visible and Is_Mouse_In_Bounds(Mouse_Pos, Bounds_Val.Pos, Bounds_Val.Size) then
                            Picked_Option = Index_Val break
                        end
                    end
                    if Picked_Option and Dropdown_Obj.Options[Picked_Option] ~= nil then
                        Config[Dropdown_Obj.Flag] = Dropdown_Obj.Options[Picked_Option]
                        if Dropdown_Obj.Flag == "ThemePreset" then
                            Apply_Theme_Preset(Config[Dropdown_Obj.Flag], false)
                        elseif Dropdown_Obj.Flag == "SelectedConfig" then
                            Config.SelectedConfig = tostring(Config[Dropdown_Obj.Flag])
                            Config.ConfigName = Config.SelectedConfig
                            Load_Named_Config(Config.SelectedConfig)
                        else
                            Queue_Save_Config()
                        end
                        Dropdown_Obj.IsOpen = false
                        Library_Data.State.ActiveDropdown = nil
                        Block_Input = true
                    else
                        local Inside_List = Dropdown_Obj.IsOpen and Is_Mouse_In_Bounds(Mouse_Pos, Dropdown_Obj.ListPos, Dropdown_Obj.ListSize)
                        if not Inside_Current_Button and not Inside_List then
                            Dropdown_Obj.IsOpen = false
                            Library_Data.State.ActiveDropdown = nil
                            Block_Input = true
                        elseif Inside_Current_Button then
                            Dropdown_Obj.IsOpen = false
                            Library_Data.State.ActiveDropdown = nil
                            Block_Input = true
                        end
                    end
                end
            elseif Library_Data.Input.Mouse2Clicked then
                Dropdown_Obj.IsOpen = false
                Library_Data.State.ActiveDropdown = nil
                Block_Input = true
            end
        end
        if Library_Data.State.ActiveColorPicker then
            local Picker_Obj = Library_Data.State.ActiveColorPicker
            if Library_Data.Input.Mouse1Clicked then
                local MP = Library_Data.Input.MousePos
                local Inside_Button = Is_Mouse_In_Bounds(MP, Picker_Obj.ButtonPos, Picker_Obj.ButtonSize)
                local Inside_Popup = Picker_Obj.IsOpen and Is_Mouse_In_Bounds(MP, Picker_Obj.PopupPos, Picker_Obj.PopupSize)
                if Inside_Button then
                    Picker_Obj.IsOpen = false
                    Picker_Obj.HexEditing = false
                    Picker_Obj:HidePopup()
                    Library_Data.State.ActiveColorPicker = nil
                    Library_Data.State.ActiveColorDrag = nil
                    Block_Input = true
                elseif Inside_Popup then
                    if Is_Mouse_In_Bounds(MP, Picker_Obj.SVPos, Picker_Obj.SVSize) then
                        Library_Data.State.ActiveColorDrag = "SV"
                    elseif Is_Mouse_In_Bounds(MP, Picker_Obj.HuePos, Picker_Obj.HueSize) then
                        Library_Data.State.ActiveColorDrag = "Hue"
                    elseif Is_Mouse_In_Bounds(MP, Picker_Obj.AlphaPos, Picker_Obj.AlphaSize) then
                        Library_Data.State.ActiveColorDrag = "Alpha"
                    elseif Is_Mouse_In_Bounds(MP, Picker_Obj.HexPos, Picker_Obj.HexSize) then
                        Picker_Obj.HexEditing = true
                        Picker_Obj.HexBuffer = Color3_To_Hex(Config[Picker_Obj.Flag].Color):sub(2)
                    elseif Picker_Obj.HexEditing then
                        Picker_Obj:CommitHex()
                    end
                    Block_Input = true
                else
                    if Picker_Obj.HexEditing then Picker_Obj:CommitHex() end
                    Picker_Obj.IsOpen = false
                    Picker_Obj:HidePopup()
                    Library_Data.State.ActiveColorPicker = nil
                    Library_Data.State.ActiveColorDrag = nil
                end
            end
            if Picker_Obj.IsOpen and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Picker_Obj.PopupPos, Picker_Obj.PopupSize) then
                Block_Input = true
            end
        end
        if Library_Data.State.ActiveSliderInput and Library_Data.Input.Mouse1Clicked then
            local Active_Input = Library_Data.State.ActiveSliderInput
            local Clicked_Value = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Active_Input.ValuePos, Active_Input.ValueSize)
            if not Clicked_Value then
                Commit_Slider_Input(Active_Input)
                Library_Data.State.ActiveSliderInput = nil
            end
        end
        if not Block_Input then
            for _, Section_Obj in ipairs(Library_Data.CurrentTab.Sections) do
                for _, Item_Obj in ipairs(Section_Obj.Items) do
                    if Item_Obj.Type == "Toggle" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.HitboxPos, Item_Obj.HitboxSize) then
                            if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) Library_Data.State.ActiveSliderInput = nil end
                            Config[Item_Obj.Flag] = not Config[Item_Obj.Flag]
                            if Fire_Change then Fire_Change(Item_Obj) end
                            if Item_Obj.Flag == "AutoSaveConfig" or Item_Obj.Flag == "AutoLoadConfig" then
                                Save_Global_Settings()
                                if Config.AutoSaveConfig then Save_Current_Config() end
                            else
                                Queue_Save_Config()
                            end
                        end
                    elseif Item_Obj.Type == "Slider" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ValuePos, Item_Obj.ValueSize) then
                            if Library_Data.State.ActiveSliderInput and Library_Data.State.ActiveSliderInput ~= Item_Obj then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) end
                            Library_Data.State.ActiveSliderInput = Item_Obj
                            Item_Obj.InputBuffer = Format_Slider_Value(Config[Item_Obj.Flag], Item_Obj.Step)
                            Library_Data.State.ActiveSlider = nil
                            Library_Data.State.ActiveTextbox = nil
                            Library_Data.State.ActiveKeybind = nil
                        elseif Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.BarPos - Vector2.new(0, 4), Item_Obj.BarSize + Vector2.new(0, 8)) then
                            if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) Library_Data.State.ActiveSliderInput = nil end
                            Library_Data.State.ActiveSlider = Item_Obj
                        end
                    elseif Item_Obj.Type == "Dropdown" then
                        if Library_Data.Input.Mouse1Clicked and not Library_Data.State.ActiveDropdown and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) Library_Data.State.ActiveSliderInput = nil end
                            if Library_Data.State.ActiveColorPicker then Library_Data.State.ActiveColorPicker.IsOpen = false Library_Data.State.ActiveColorPicker = nil end
                            Item_Obj.IsOpen = true Item_Obj.OpenAlpha = 0 Item_Obj.ListHeight = 0 Item_Obj.TargetListHeight = 0
                            Library_Data.State.ActiveDropdown = Item_Obj
                            Block_Input = true
                        end
                    elseif Item_Obj.Type == "ColorPicker" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            if Library_Data.State.ActiveColorPicker and Library_Data.State.ActiveColorPicker ~= Item_Obj then
                                Library_Data.State.ActiveColorPicker.IsOpen = false
                                Library_Data.State.ActiveColorPicker.HexEditing = false
                            end
                            if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) Library_Data.State.ActiveSliderInput = nil end
                            Item_Obj.IsOpen = true
                            Item_Obj.HexEditing = false
                            Library_Data.State.ActiveColorPicker = Item_Obj
                            Library_Data.State.ActiveColorDrag = nil
                            Library_Data.State.ActiveKeybind = nil
                            Library_Data.State.ActiveTextbox = nil
                            Library_Data.State.ActiveDropdown = nil
                            Block_Input = true
                        end
                    elseif Item_Obj.Type == "Keybind" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            Library_Data.State.ActiveKeybind = Item_Obj
                            Library_Data._captureLast = {}
                            for Code_Val in pairs(Key_Codes) do
                                Library_Data._captureLast[Code_Val] = iskeypressed(Code_Val) or false
                            end
                        if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) Library_Data.State.ActiveSliderInput = nil end
                            Library_Data.State.ActiveTextbox = nil
                            if Library_Data.State.ActiveColorPicker then Library_Data.State.ActiveColorPicker.IsOpen = false Library_Data.State.ActiveColorPicker = nil end
                            Library_Data.State.HotkeysContext.Open = false Library_Data.State.HotkeysContext.Entry = nil
                            Library_Data.State.KeybindContext.Open = false Library_Data.State.KeybindContext.Entry = nil
                        elseif Library_Data.Input.Mouse2Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            Library_Data.State.ActiveKeybind = nil
                            if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) Library_Data.State.ActiveSliderInput = nil end
                            Library_Data.State.ActiveTextbox = nil
                            Library_Data.State.KeybindContext.Open = true
                            Library_Data.State.KeybindContext.Entry = {BindFlag = Item_Obj.Flag, Label = Item_Obj.Label and Item_Obj.Label.Text or "Bind", Item = Item_Obj}
                            local Context_Pos = Get_Context_Menu_Position(Item_Obj)
                            Library_Data.State.KeybindContext.Position = Vector2.new(Context_Pos.X, Context_Pos.Y)
                        end
                    elseif Item_Obj.Type == "Button" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            if Item_Obj.Callback then Item_Obj.Callback() end
                        end
                    elseif Item_Obj.Type == "Textbox" then
                        if Library_Data.Input.Mouse1Clicked then
                            if Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.BoxPos, Item_Obj.BoxSize) then
                                Library_Data.State.ActiveTextbox = Item_Obj
                                Library_Data.State.ActiveKeybind = nil
                                if Library_Data.State.ActiveSliderInput then Commit_Slider_Input(Library_Data.State.ActiveSliderInput) Library_Data.State.ActiveSliderInput = nil end
                                if Library_Data.State.ActiveColorPicker then Library_Data.State.ActiveColorPicker.IsOpen = false Library_Data.State.ActiveColorPicker = nil end
                                Library_Data.State.KeybindContext.Open = false Library_Data.State.KeybindContext.Entry = nil
                            elseif Library_Data.State.ActiveTextbox == Item_Obj then
                                Library_Data.State.ActiveTextbox = nil
                            end
                        end
                    end
                end
            end
        end
    end
    
    if not Library_Data.Input.Mouse1Down then Library_Data.State.ActiveColorDrag = nil end
    if Library_Data.State.ActiveColorPicker and Library_Data.State.ActiveColorDrag then
        local Picker_Obj = Library_Data.State.ActiveColorPicker
        if Library_Data.State.ActiveColorDrag == "SV" and Picker_Obj.SVPos and Picker_Obj.SVSize then
            Picker_Obj.Sat = Math_Clamp((Library_Data.Input.MousePos.X - Picker_Obj.SVPos.X) / Picker_Obj.SVSize.X, 0, 1)
            Picker_Obj.Val = 1 - Math_Clamp((Library_Data.Input.MousePos.Y - Picker_Obj.SVPos.Y) / Picker_Obj.SVSize.Y, 0, 1)
            Picker_Obj:SyncColor()
        elseif Library_Data.State.ActiveColorDrag == "Hue" and Picker_Obj.HuePos and Picker_Obj.HueSize then
            Picker_Obj.Hue = Math_Clamp((Library_Data.Input.MousePos.X - Picker_Obj.HuePos.X) / Picker_Obj.HueSize.X, 0, 1)
            Picker_Obj:SyncColor()
        elseif Library_Data.State.ActiveColorDrag == "Alpha" and Picker_Obj.AlphaPos and Picker_Obj.AlphaSize then
            Picker_Obj.Alpha = Math_Clamp((Library_Data.Input.MousePos.X - Picker_Obj.AlphaPos.X) / Picker_Obj.AlphaSize.X, 0, 1)
            Picker_Obj:SyncColor()
        end
    end
    
    if Library_Data.State.ActiveSlider and Library_Data.State.ActiveSlider.BarSize then
        local Slider_Obj = Library_Data.State.ActiveSlider
        if Library_Data.Input.Mouse1Down then
            local Left_Val = Slider_Obj.BarPos.X
            local Width_Val = Fast_Max(Slider_Obj.BarSize.X, 1)
            local Percentage_Val = Math_Clamp((Library_Data.Input.MousePos.X - Left_Val) / Width_Val, 0, 1)
            Config[Slider_Obj.Flag] = Clamp_Slider_Value(Slider_Obj.Min + (Percentage_Val * (Slider_Obj.Max - Slider_Obj.Min)), Slider_Obj.Min, Slider_Obj.Max, Slider_Obj.Step)
            Queue_Save_Config()
        else
            Library_Data.State.ActiveSlider = nil
        end
    end
    
    for Tab_Index, Tab_Obj in ipairs(Library_Data.Tabs) do
        local Is_Current = Tab_Obj == Library_Data.CurrentTab
        local Tab_Pos, Tab_Size = Get_Tab_Bounds(Pos_X, Pos_Y, Tab_Index)
        local Is_Hovered = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Tab_Pos, Tab_Size)
        local Alpha_Target = Is_Current and 1 or (Is_Hovered and 0.38 or 0)
        Tab_Obj.BgAlpha = Math_Lerp(Tab_Obj.BgAlpha, Alpha_Target, 0.20)
        local Card_Color = Color_Lerp(Library_Data.Palette.Sidebar, Library_Data.Palette.Hover, Tab_Obj.BgAlpha * 0.57)
        local Border_Color = Library_Data.Palette.Outline
        Update_Rounded_Box(Tab_Obj.Border, Tab_Pos, Tab_Size, 6, Border_Color, Is_Current and 0.44 or (Is_Hovered and 0.22 or 0), Is_Current or Is_Hovered)
        Update_Rounded_Box(Tab_Obj.Background, Vector_2_Round(Tab_Pos.X + 1, Tab_Pos.Y + 1), Vector_2_Round(Tab_Size.X - 2, Tab_Size.Y - 2), 5, Card_Color, 1, true)
        Update_Rounded_Box(Tab_Obj.RailGlow, Tab_Pos, Vector_2_Round(0, 0), 0, Library_Data.Palette.Accent, 0, false)
        Update_Rounded_Box(Tab_Obj.Indicator, Vector_2_Round(Tab_Pos.X + 3, Tab_Pos.Y + 9), Vector_2_Round(2, Tab_Size.Y - 18), 1, Library_Data.Palette.Accent, 1, Is_Current)
        Update_Rounded_Box(Tab_Obj.Detail, Tab_Pos, Vector_2_Round(0, 0), 0, Library_Data.Palette.Accent2, 0, false)
        Tab_Obj.CurrentColor = Color_Lerp(Tab_Obj.CurrentColor, Is_Current and Library_Data.Palette.Text or (Is_Hovered and Color_Lerp(Library_Data.Palette.SubText, Library_Data.Palette.Text, 0.65) or Library_Data.Palette.SubText), 0.23)
        Tab_Obj.IconDraw.Visible = false
        Tab_Obj.Label.Visible = true
        Position_Text(Tab_Obj.Label, Tab_Pos.X + 15, Tab_Pos.Y + 10, "SidebarTab")
        Tab_Obj.Label.Color = Tab_Obj.CurrentColor
        if not Is_Current then
            Hide_Tab_Content(Tab_Obj)
        end
        if Is_Current and not Skip_Heavy_Update then
            local Col_Width = (Size_X - 150 - 30) / 2
            local Left_Y, Right_Y = Pos_Y + 46, Pos_Y + 46
            for _, Section_Obj in ipairs(Tab_Obj.Sections) do
                local Section_X = Section_Obj.Side == "Left" and (Pos_X + 160) or (Pos_X + 160 + Col_Width + 10)
                local Section_Y = Section_Obj.Side == "Left" and Left_Y or Right_Y
                local Item_Y = Section_Y + 32
                for _, Item_Obj in ipairs(Section_Obj.Items) do
                    Item_Obj:Update(Section_X + 8, Item_Y, Col_Width - 16)
                    Item_Y = Item_Y + Item_Obj.Height
                end
                Section_Obj:UpdateContainer(Section_X, Section_Y, Col_Width, Item_Y - Section_Y + 6)
                if Section_Obj.Side == "Left" then Left_Y = Item_Y + 16 else Right_Y = Item_Y + 16 end
            end
        end

        if not Is_Current then
            for _, Section_Obj in ipairs(Tab_Obj.Sections) do
                Set_Visible(Section_Obj.Outline, false)
                Set_Visible(Section_Obj.Background, false)
                Hide_Stripe_Pattern(Section_Obj.PatternBack)
                Hide_Stripe_Pattern(Section_Obj.PatternFront)
                Section_Obj.Title.Visible = false
                Section_Obj.Line.Visible = false
                for _, Item_Obj in ipairs(Section_Obj.Items) do
                    if Item_Obj.Label then Item_Obj.Label.Visible = false end
                    if Item_Obj.ValueLabel then Item_Obj.ValueLabel.Visible = false end
                    if Item_Obj.Icon then Update_Keybind_Image_Icon(Item_Obj.Icon, Vector_2_Round(-1000, -1000), Library_Data.Palette.Text, false) end
                    if Item_Obj.IconDraw then Item_Obj.IconDraw.Visible = false end
                    if Item_Obj.BoxStroke then Set_Visible(Item_Obj.BoxStroke, false) end
                    if Item_Obj.Box then Set_Visible(Item_Obj.Box, false) end
                    if Item_Obj.Fill then Set_Visible(Item_Obj.Fill, false) end
                    if Item_Obj.Stroke then Set_Visible(Item_Obj.Stroke, false) end
                    if Item_Obj.Background then Set_Visible(Item_Obj.Background, false) end
                    if Item_Obj.Knob then Set_Visible(Item_Obj.Knob, false) end
                    if Item_Obj.ListStroke then Set_Visible(Item_Obj.ListStroke, false) end
                    if Item_Obj.ListBackground then Set_Visible(Item_Obj.ListBackground, false) end
                    if Item_Obj.ButtonStroke then Set_Visible(Item_Obj.ButtonStroke, false) end
                    if Item_Obj.ButtonBox then Set_Visible(Item_Obj.ButtonBox, false) end
                    if Item_Obj.OptionDrawings then
                        for _, Option_Drawing in pairs(Item_Obj.OptionDrawings) do Option_Drawing.Visible = false end
                    end
                    if Item_Obj.PreviewStroke then Set_Visible(Item_Obj.PreviewStroke, false) end
                    if Item_Obj.Preview then Set_Visible(Item_Obj.Preview, false) end
                    if Item_Obj.PopupStroke then Set_Visible(Item_Obj.PopupStroke, false) end
                    if Item_Obj.PopupBackground then Set_Visible(Item_Obj.PopupBackground, false) end
                    if Item_Obj.PopupSwatchStroke then Set_Visible(Item_Obj.PopupSwatchStroke, false) end
                    if Item_Obj.PopupSwatch then Set_Visible(Item_Obj.PopupSwatch, false) end
                    if Item_Obj.SVStroke then Set_Visible(Item_Obj.SVStroke, false) end
                    if Item_Obj.HueStroke then Set_Visible(Item_Obj.HueStroke, false) end
                    if Item_Obj.SVGrid then Hide_Grid_Squares(Item_Obj.SVGrid) end
                    if Item_Obj.HueGrid then Hide_Grid_Squares(Item_Obj.HueGrid) end
                    if Item_Obj.CursorOuter then Item_Obj.CursorOuter.Visible = false end
                    if Item_Obj.CursorInner then Item_Obj.CursorInner.Visible = false end
                    if Item_Obj.HueLine then Item_Obj.HueLine.Visible = false end
                    if Item_Obj.HueCapTop then Item_Obj.HueCapTop.Visible = false end
                    if Item_Obj.HueCapBottom then Item_Obj.HueCapBottom.Visible = false end
                    if Item_Obj.PopupHex then Item_Obj.PopupHex.Visible = false end
                end
            end
        end
    end
end)



Fire_Change = function(Item_Obj)
    if Item_Obj and type(Item_Obj.OnChanged) == "function" then
        pcall(Item_Obj.OnChanged, Config[Item_Obj.Flag])
    end
end

local NightfallLibrary = {
    Name = "Nightfall",
    Version = "1.0.0",
    Config = Config,
    Flags = Config,
    State = Library_Data,
    Runtime = Runtime_State,
    Session = Session,
    TextOffsets = Text_Offsets,
    Palette = Library_Data.Palette,
    Connect = Connect_Session,
    SaveConfig = Save_Current_Config,
    LoadConfig = Load_Named_Config,
    DeleteConfig = Delete_Named_Config,
    ListConfigs = Get_Available_Configs,
    SaveLayout = Save_Layout,
    LoadLayout = Load_Layout,
    ApplyTheme = Apply_Theme_Preset,
    RegisterKeybind = Register_Keybind,
    SetBindMode = Set_Bind_Mode,
    GetBindMode = Get_Bind_Mode
}

function NightfallLibrary:Size(Width, Height)
    if type(Width) == "table" or typeof(Width) == "Vector2" then
        Height = Width.Y or Width.Height or Width[2]
        Width = Width.X or Width.Width or Width[1]
    end
    Width = tonumber(Width) or Library_Data.Size.X
    Height = tonumber(Height) or Library_Data.Size.Y
    Width = math.max(560, math.floor(Width + 0.5))
    Height = math.max(380, math.floor(Height + 0.5))
    Library_Data.Size = Vector2.new(Width, Height)
    Library_Data.Position = Clamp_Window_Position(Library_Data.Position, Library_Data.Size)
    Library_Data.TargetPosition = Clamp_Window_Position(Library_Data.TargetPosition, Library_Data.Size)
    return self
end
NightfallLibrary.size = NightfallLibrary.Size

function NightfallLibrary:Visible(Value)
    if Value == nil then return Library_Data.Visible end
    Library_Data.Visible = Value and true or false
    if not Library_Data.Visible then
        Close_Transient_Ui()
        Hide_Window_Drawings()
    end
    return self
end

function NightfallLibrary:Set(Flag, Value)
    Config[Flag] = Value
    if Flag == "HideKeybind" or Flag == "ParryKeybind" or Flag == "SpamKeybind" or Flag == "TriggerKeybind" then
        Register_Keybind(Flag, Value, Get_Bind_Mode(Flag))
    end
    Queue_Save_Config()
    return self
end

function NightfallLibrary:Get(Flag)
    return Config[Flag]
end

local function Wrap_Control(Control_Obj, Flag, Callback)
    if not Control_Obj then return nil end
    Control_Obj.OnChanged = Callback
    function Control_Obj:Get()
        return Config[Flag]
    end
    function Control_Obj:Set(Value, Silent)
        if self.Type == "Slider" then
            Value = Clamp_Slider_Value(tonumber(Value) or self.Min, self.Min, self.Max, self.Step)
            self.InputBuffer = Format_Slider_Value(Value, self.Step)
        elseif self.Type == "Keybind" then
            Value = Normalize_Keybind_Value(Value)
            Register_Keybind(Flag, Value, Get_Bind_Mode(Flag))
        elseif self.Type == "ColorPicker" and type(Value) == "table" and Value.Color then
            self.Hue, self.Sat, self.Val = Color3_To_Hsv(Value.Color)
            self.Alpha = Math_Clamp(Value.Alpha or 1, 0, 1)
        end
        Config[Flag] = Value
        if not Silent then
            Fire_Change(self)
            Queue_Save_Config()
        end
        return self
    end
    if Control_Obj.Type == "Keybind" then
        function Control_Obj:SetMode(Mode)
            Set_Bind_Mode(Flag, Mode)
            return self
        end
        function Control_Obj:GetMode()
            return Get_Bind_Mode(Flag)
        end
    end
    return Control_Obj
end

local function Wrap_Section(Section_Obj)
    function Section_Obj:Toggle(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return Wrap_Control(self:CreateToggle(Options.Name or F, F, Options.Default), F, Options.Callback)
    end
    function Section_Obj:Slider(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return Wrap_Control(self:CreateSlider(Options.Name or F, F, Options.Min or 0, Options.Max or 100, Options.Default, Options.Step or 1), F, Options.Callback)
    end
    function Section_Obj:Dropdown(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return Wrap_Control(self:CreateDropdown(Options.Name or F, F, Options.Options or {}, Options.Default), F, Options.Callback)
    end
    function Section_Obj:Keybind(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return Wrap_Control(self:CreateKeybind(Options.Name or F, F, Options.Default or "None"), F, Options.Callback)
    end
    function Section_Obj:Textbox(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        return Wrap_Control(self:CreateTextbox(Options.Name or F, F, Options.Default or ""), F, Options.Callback)
    end
    function Section_Obj:Colorpicker(Options)
        Options = Options or {}
        local F = Options.Flag or Options.Name
        local Callback = Options.Callback
        local C = self:CreateColorPicker(Options.Name or F, F, Options.Default or Library_Data.Palette.Accent, Options.Alpha or 1, Callback)
        return Wrap_Control(C, F, Callback)
    end
    Section_Obj.ColorPicker = Section_Obj.Colorpicker
    function Section_Obj:Button(Options)
        Options = Options or {}
        return self:CreateButton(Options.Name or "Button", Options.Callback)
    end
    return Section_Obj
end

function NightfallLibrary:Window(Options)
    Options = Options or {}
    if Options.Size then self:Size(Options.Size) end
    if Options.Name then Window_Drawings.Title.Text = Options.Name end
    local Window_Obj = {Name = Options.Name or "Nightfall", State = Library_Data}
    function Window_Obj:Tab(Tab_Options)
        if type(Tab_Options) == "string" then Tab_Options = {Name = Tab_Options} end
        Tab_Options = Tab_Options or {}
        local Tab_Obj = Library_Data:CreateTab(Tab_Options.Name or "Tab", Tab_Options.Icon)
        function Tab_Obj:Section(Section_Options)
            if type(Section_Options) == "string" then Section_Options = {Name = Section_Options} end
            Section_Options = Section_Options or {}
            return Wrap_Section(self:CreateSection(Section_Options.Name or "Section", Section_Options.Side or "Left"))
        end
        return Tab_Obj
    end
    return Window_Obj
end

function NightfallLibrary:Unload()
    Session.Active = false
    _G.NightfallActive = false
    for _, Connection_Obj in ipairs(Session.Connections) do
        pcall(function() Connection_Obj:Disconnect() end)
    end
    for _, Drawing_Obj in ipairs(_G.NightfallDrawings or {}) do
        pcall(function() Drawing_Obj:Remove() end)
    end
    if _G.NightfallSession == Session then _G.NightfallSession = nil end
    if _G.NightfallLibrary == self then _G.NightfallLibrary = nil end
end

_G.NightfallLibrary = NightfallLibrary
