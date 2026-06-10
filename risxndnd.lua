local Http_Service = game:GetService("HttpService")
local Run_Service = game:GetService("RunService")
local Players_Service = game:GetService("Players")
local Workspace_Service = game:GetService("Workspace")
local Stats_Service = game:GetService("Stats")
local Local_Player = Players_Service.LocalPlayer or Players_Service.PlayerAdded:Wait()
local Local_Mouse = Local_Player:GetMouse()
local Fast_Floor = math.floor
local Fast_Max = math.max
local Fast_Clamp = math.clamp
local Fast_Clock = os.clock
local Fast_Tick = tick

if _G.MoonshadeDrawings then
    for _, Drawing_Obj in pairs(_G.MoonshadeDrawings) do
        pcall(function() Drawing_Obj:Remove() end)
    end
end

_G.MoonshadeDrawings = {}
_G.MoonshadeActive = true

local Key_Codes = {[1]="LMB",[2]="RMB",[3]="MMB",[4]="MB4",[5]="MB5",[8]="Backspace",[9]="Tab",[13]="Enter",[16]="Shift",[17]="Ctrl",[18]="Alt",[20]="CapsLock",[27]="Esc",[32]="Space",[33]="PageUp",[34]="PageDown",[35]="End",[36]="Home",[37]="Left",[38]="Up",[39]="Right",[40]="Down",[45]="Insert",[46]="Delete",[48]="0",[49]="1",[50]="2",[51]="3",[52]="4",[53]="5",[54]="6",[55]="7",[56]="8",[57]="9",[65]="A",[66]="B",[67]="C",[68]="D",[69]="E",[70]="F",[71]="G",[72]="H",[73]="I",[74]="J",[75]="K",[76]="L",[77]="M",[78]="N",[79]="O",[80]="P",[81]="Q",[82]="R",[83]="S",[84]="T",[85]="U",[86]="V",[87]="W",[88]="X",[89]="Y",[90]="Z",[96]="Num0",[97]="Num1",[98]="Num2",[99]="Num3",[100]="Num4",[101]="Num5",[102]="Num6",[103]="Num7",[104]="Num8",[105]="Num9",[106]="Multiply",[107]="Add",[109]="Subtract",[110]="Decimal",[111]="Divide",[112]="F1",[113]="F2",[114]="F3",[115]="F4",[116]="F5",[117]="F6",[118]="F7",[119]="F8",[120]="F9",[121]="F10",[122]="F11",[123]="F12",[144]="NumLock",[145]="ScrollLock",[160]="LShift",[161]="RShift",[162]="LCtrl",[163]="RCtrl",[164]="LAlt",[165]="RAlt",[186]=";",[187]="=",[188]=",",[189]="-",[190]=".",[191]="/",[192]="`",[219]="[",[220]="\\",[221]="]",[222]="'"}

local Shift_Modifiers = {["1"]="!",["2"]="@",["3"]="#",["4"]="$",["5"]="%",["6"]="^",["7"]="&",["8"]="*",["9"]="(",["0"]=")",["-"]="_",["="]="+",["`"]="~",["["]="{",["]"]="}",["\\"]="|",[";"]=":",["'"]="\"",[","]="<",["."]=">",["/"]="?"}

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
    HideKeybind = "Esc",
    RenderBallStats = false,
    ShowHotkeyList = true,
    ParryBindMode = "Toggle",
    SpamBindMode = "Toggle",
    TriggerBindMode = "Toggle",
    AutoSave = true,
    AutoLoad = true,
    ThemePreset = "Nightfall",
    ConfigName = "default",
    SelectedConfig = "default"
}

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
    if not C1_Val or not C2_Val then
        return Color3.new(1, 1, 1)
    end
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

    if Hp_Val >= 0 and Hp_Val < 1 then
        R1_Val, G1_Val, B1_Val = C_Val, X_Val, 0
    elseif Hp_Val >= 1 and Hp_Val < 2 then
        R1_Val, G1_Val, B1_Val = X_Val, C_Val, 0
    elseif Hp_Val >= 2 and Hp_Val < 3 then
        R1_Val, G1_Val, B1_Val = 0, C_Val, X_Val
    elseif Hp_Val >= 3 and Hp_Val < 4 then
        R1_Val, G1_Val, B1_Val = 0, X_Val, C_Val
    elseif Hp_Val >= 4 and Hp_Val < 5 then
        R1_Val, G1_Val, B1_Val = X_Val, 0, C_Val
    else
        R1_Val, G1_Val, B1_Val = C_Val, 0, X_Val
    end

    local M_Val = V_Val - C_Val
    return Color3.new(R1_Val + M_Val, G1_Val + M_Val, B1_Val + M_Val)
end

local function Color3_To_Hsv(Color_Val)
    if not Color_Val then
        return 0, 0, 1
    end
    local Ok_State, H_Val, S_Val, V_Val = pcall(function()
        return Color_Val:ToHSV()
    end)
    if Ok_State then
        return H_Val, S_Val, V_Val
    end
    local R_Val, G_Val, B_Val = Color_Val.R, Color_Val.G, Color_Val.B
    local Max_C = Fast_Max(R_Val, G_Val, B_Val)
    local Min_C = math.min(R_Val, G_Val, B_Val)
    local Delta_C = Max_C - Min_C
    local H2_Val = 0
    if Delta_C > 0 then
        if Max_C == R_Val then
            H2_Val = ((G_Val - B_Val) / Delta_C) % 6
        elseif Max_C == G_Val then
            H2_Val = ((B_Val - R_Val) / Delta_C) + 2
        else
            H2_Val = ((R_Val - G_Val) / Delta_C) + 4
        end
        H2_Val = H2_Val / 6
    end
    local S2_Val = Max_C == 0 and 0 or (Delta_C / Max_C)
    return H2_Val, S2_Val, Max_C
end

local function Color3_To_Hex(Color_Val)
    if not Color_Val then
        return "#FFFFFF"
    end
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
        for _, Sq_Val in ipairs(Grid_Array) do
            Sq_Val.Visible = false
        end
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
    for _, Sq_Val in ipairs(Grid_Array) do
        Sq_Val.Visible = false
    end
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
    if Decimals_Val <= 0 then
        return tostring(Fast_Floor(Value_In + 0.5))
    end
    local Formatted_Val = string.format("%." .. Decimals_Val .. "f", Value_In)
    Formatted_Val = Formatted_Val:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    return Formatted_Val
end

local function Parse_Slider_Input(Text_Value)
    local Cleaned_Val = tostring(Text_Value or ""):gsub(",", "."):gsub("[^%d%.%-]", "")
    if Cleaned_Val == "" or Cleaned_Val == "-" or Cleaned_Val == "." or Cleaned_Val == "-." then
        return nil
    end
    local Number_Val = tonumber(Cleaned_Val)
    if Number_Val == nil then return nil end
    return Number_Val
end

local function Clamp_Slider_Value(Value_In, Min_Val, Max_Val, Step_Val)
    local Clamped_Val = Math_Clamp(Value_In, Min_Val, Max_Val)
    local Snapped_Val = Snap_Value(Clamped_Val, Step_Val)
    return Math_Clamp(Snapped_Val, Min_Val, Max_Val)
end

local function Commit_Slider_Input(Slider_Obj)
    if not Slider_Obj then return end
    local Parsed_Val = Parse_Slider_Input(Slider_Obj.InputBuffer)
    if Parsed_Val == nil then
        Slider_Obj.InputBuffer = Format_Slider_Value(Config[Slider_Obj.Flag], Slider_Obj.Step)
        return
    end
    local Final_Value = Clamp_Slider_Value(Parsed_Val, Slider_Obj.Min, Slider_Obj.Max, Slider_Obj.Step)
    Config[Slider_Obj.Flag] = Final_Value
    Slider_Obj.InputBuffer = Format_Slider_Value(Final_Value, Slider_Obj.Step)
end

local function Normalize_Keybind_Value(Value_In)
    if type(Value_In) == "number" then
        return Key_Codes[Value_In] or tostring(Value_In)
    end
    if Value_In == nil or Value_In == "" then
        return "None"
    end
    return tostring(Value_In)
end

local function Normalize_Bind_Mode(Mode_In)
    Mode_In = tostring(Mode_In or "Toggle")
    if string.lower(Mode_In) == "hold" then
        return "Hold"
    end
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

local function Set_Bind_Mode(Bind_Flag, Mode_In)
    local Mode_Flag = Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    if Mode_Flag then
        Config[Mode_Flag] = Normalize_Bind_Mode(Mode_In)
    end
end

local function Get_Bind_Mode(Bind_Flag)
    local Mode_Flag = Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    return Normalize_Bind_Mode(Mode_Flag and Config[Mode_Flag] or "Toggle")
end

local function Set_Bind_Target_State(Bind_Flag, State_In)
    local Toggle_Flag = Get_Toggle_Flag_From_Bind_Flag(Bind_Flag)
    if Toggle_Flag then
        Config[Toggle_Flag] = State_In and true or false
    end
end

local function Handle_Bind_Press(Bind_Flag)
    if Normalize_Keybind_Value(Config[Bind_Flag]) == "None" then return end
    if Get_Bind_Mode(Bind_Flag) == "Hold" then
        Set_Bind_Target_State(Bind_Flag, true)
    else
        local Toggle_Flag = Get_Toggle_Flag_From_Bind_Flag(Bind_Flag)
        if Toggle_Flag then
            Config[Toggle_Flag] = not Config[Toggle_Flag]
        end
    end
end

local function Handle_Bind_Release(Bind_Flag)
    if Normalize_Keybind_Value(Config[Bind_Flag]) == "None" then return end
    if Get_Bind_Mode(Bind_Flag) == "Hold" then
        Set_Bind_Target_State(Bind_Flag, false)
    end
end

local function Get_Context_Menu_Position(Item_Obj)
    local Camera_Obj = Workspace_Service.CurrentCamera
    local Viewport_Val = Camera_Obj and Camera_Obj.ViewportSize or Vector2.new(1920, 1080)
    local Menu_W, Menu_H = 112, 56
    if not Item_Obj or not Item_Obj.ButtonPos or not Item_Obj.ButtonSize then return Vector_2_Round(0, 0) end
    local Context_X = Item_Obj.ButtonPos.X
    local Context_Y = Item_Obj.ButtonPos.Y + Item_Obj.ButtonSize.Y + 6
    if Context_X + Menu_W > Viewport_Val.X then
        Context_X = Item_Obj.ButtonPos.X + Item_Obj.ButtonSize.X - Menu_W
    end
    if Context_Y + Menu_H > Viewport_Val.Y then
        Context_Y = Item_Obj.ButtonPos.Y - Menu_H - 6
    end
    return Vector_2_Round(Math_Clamp(Context_X, 0, Viewport_Val.X - Menu_W), Math_Clamp(Context_Y, 0, Viewport_Val.Y - Menu_H))
end

local function Is_Mouse_In_Bounds(Pos_In, Bounds_Pos, Bounds_Size)
    return Pos_In.X >= Bounds_Pos.X and Pos_In.X <= Bounds_Pos.X + Bounds_Size.X and Pos_In.Y >= Bounds_Pos.Y and Pos_In.Y <= Bounds_Pos.Y + Bounds_Size.Y
end

Create_Drawing = function(Class_Name, Properties_Table)
    local Drawing_Obj = Drawing.new(Class_Name)
    for Prop_Name, Prop_Value in pairs(Properties_Table) do
        pcall(function() Drawing_Obj[Prop_Name] = Prop_Value end)
    end
    table.insert(_G.MoonshadeDrawings, Drawing_Obj)
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
            Main = Square_Func(),
            Top = Square_Func(),
            Bottom = Square_Func(),
            Left = Square_Func(),
            Right = Square_Func(),
            TL = Circle_Func(),
            TR = Circle_Func(),
            BL = Circle_Func(),
            BR = Circle_Func(),
            Inner = Square_Func(),
            Dot1 = Circle_Func(),
            Dot2 = Circle_Func(),
            Dot3 = Circle_Func(),
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
        if Visible_State then
            Obj_Item.Color = Color_Val
            Obj_Item.Transparency = 1
        end
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
    if Item_Obj.Main then
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
    local List_Array = {Box_Obj.Main, Box_Obj.Top, Box_Obj.Bottom, Box_Obj.Left, Box_Obj.Right, Box_Obj.TL, Box_Obj.TR, Box_Obj.BL, Box_Obj.BR}
    for _, Obj_Item in ipairs(List_Array) do
        Obj_Item.Color = Color_Val
        Obj_Item.Transparency = Transparency_Val or 1
    end
end

local function Make_Rounded_Box(Color_Val, Transparency_Val)
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
    local Seg_W = Size_Val.X / Fast_Max(Count_Val, 1)
    for I_Idx = 1, Count_Val do
        local T_Val = (I_Idx - 1) / Fast_Max(Count_Val - 1, 1)
        local It_Obj = Items_Array[I_Idx]
        It_Obj.Visible = Visible_State
        It_Obj.Color = Color_Lerp(C1_Val, C2_Val, T_Val)
        It_Obj.Position = Vector_2_Round(Pos_Val.X + (I_Idx - 1) * Seg_W, Pos_Val.Y)
        It_Obj.Size = Vector_2_Round(math.ceil(Seg_W + 1), Size_Val.Y)
    end
end

local function Hide_Gradient_Line(Items_Array)
    for _, It_Obj in ipairs(Items_Array) do
        It_Obj.Visible = false
    end
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
    if not Visible_State or Rect_W <= 0 or Rect_H <= 0 then
        return
    end

    local Left_Val = Rect_X
    local Right_Val = Rect_X + Rect_W
    local Top_Val = Rect_Y
    local Bottom_Val = Rect_Y + Rect_H
    local Start_X = Left_Val - Slant_Val
    local Total_Width = Rect_W + Slant_Val
    local Needed_Val = math.ceil(Total_Width / Spacing_Val) + 3

    for I_Idx, Line_Obj in ipairs(Items_Array) do
        if I_Idx > Needed_Val then break end

        local Base_X = Start_X + ((I_Idx - 1) * Spacing_Val)
        local From_X = Base_X
        local From_Y = Bottom_Val
        local To_X = Base_X + Slant_Val
        local To_Y = Top_Val

        if To_X < Left_Val or From_X > Right_Val then
            Line_Obj.Visible = false
        else
            if From_X < Left_Val then
                local T_Val = (Left_Val - From_X) / Fast_Max(To_X - From_X, 0.001)
                From_X = Left_Val
                From_Y = Bottom_Val + (Top_Val - Bottom_Val) * T_Val
            end

            if To_X > Right_Val then
                local T_Val = (Right_Val - From_X) / Fast_Max(To_X - From_X, 0.001)
                To_X = Right_Val
                To_Y = From_Y + (Top_Val - From_Y) * T_Val
            end

            if From_Y < Top_Val then
                From_Y = Top_Val
            elseif From_Y > Bottom_Val then
                From_Y = Bottom_Val
            end

            if To_Y < Top_Val then
                To_Y = Top_Val
            elseif To_Y > Bottom_Val then
                To_Y = Bottom_Val
            end

            if math.abs(To_X - From_X) >= 1 and math.abs(From_Y - To_Y) >= 1 then
                local T_Val = (I_Idx - 1) / Fast_Max(Needed_Val - 1, 1)
                Line_Obj.Visible = true
                Line_Obj.Color = Color_Val
                Line_Obj.Transparency = Fast_Max(0.05, 0.16 - (T_Val * 0.10))
                Line_Obj.From = Vector_2_Round(From_X, From_Y)
                Line_Obj.To = Vector_2_Round(To_X, To_Y)
            else
                Line_Obj.Visible = false
            end
        end
    end
end

local function Hide_Stripe_Pattern(Items_Array)
    for _, Line_Obj in ipairs(Items_Array) do
        Line_Obj.Visible = false
    end
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
        Mouse1Down = false,
        Mouse1Prev = false,
        Mouse1Clicked = false,
        Mouse1Released = false,
        Mouse2Down = false,
        Mouse2Prev = false,
        Mouse2Clicked = false,
        KeysDown = {}
    },
    State = {
        ActiveDropdown = nil,
        ActiveSlider = nil,
        ActiveSliderInput = nil,
        ActiveTextbox = nil,
        ActiveKeybind = nil,
        ActiveColorPicker = nil,
        ActiveColorDrag = nil,
        Dragging = false,
        DragStart = Vector2.new(0, 0),
        WindowStart = Vector2.new(0, 0),
        HotkeysDragging = false,
        HotkeysDragStart = Vector2.new(0, 0),
        HotkeysWindowStart = Vector2.new(0, 0),
        StatsDragging = false,
        StatsDragStart = Vector2.new(0, 0),
        StatsWindowStart = Vector2.new(0, 0),
        HotkeysContext = {
            Open = false,
            Position = Vector2.new(0, 0),
            Entry = nil
        },
        KeybindContext = {
            Open = false,
            Position = Vector2.new(0, 0),
            Entry = nil
        },
        BackspaceHeld = false,
        BackspaceNextRepeat = 0
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
        Background = Default_Nightfall_Palette.Background,
        Sidebar = Default_Nightfall_Palette.Sidebar,
        Section = Default_Nightfall_Palette.Section,
        Element = Default_Nightfall_Palette.Element,
        Hover = Default_Nightfall_Palette.Hover,
        Outline = Default_Nightfall_Palette.Outline,
        OutlineLight = Default_Nightfall_Palette.OutlineLight,
        Accent = Default_Nightfall_Palette.Accent,
        Accent2 = Default_Nightfall_Palette.Accent2,
        Text = Default_Nightfall_Palette.Text,
        SubText = Default_Nightfall_Palette.SubText
    },
    Bloodmoon = {
        Background = Color3.fromRGB(20, 8, 12),
        Sidebar = Color3.fromRGB(28, 10, 16),
        Section = Color3.fromRGB(36, 12, 20),
        Element = Color3.fromRGB(46, 14, 24),
        Hover = Color3.fromRGB(58, 18, 32),
        Outline = Color3.fromRGB(70, 28, 40),
        OutlineLight = Color3.fromRGB(96, 42, 56),
        Accent = Color3.fromRGB(235, 72, 96),
        Accent2 = Color3.fromRGB(255, 128, 164),
        Text = Color3.fromRGB(246, 238, 242),
        SubText = Color3.fromRGB(176, 150, 158)
    },
    Ocean = {
        Background = Color3.fromRGB(8, 14, 24),
        Sidebar = Color3.fromRGB(10, 18, 32),
        Section = Color3.fromRGB(12, 24, 40),
        Element = Color3.fromRGB(16, 30, 50),
        Hover = Color3.fromRGB(20, 40, 64),
        Outline = Color3.fromRGB(28, 52, 78),
        OutlineLight = Color3.fromRGB(42, 70, 100),
        Accent = Color3.fromRGB(74, 168, 255),
        Accent2 = Color3.fromRGB(98, 220, 255),
        Text = Color3.fromRGB(240, 246, 255),
        SubText = Color3.fromRGB(148, 170, 196)
    },
    Mint = {
        Background = Color3.fromRGB(10, 18, 16),
        Sidebar = Color3.fromRGB(12, 24, 20),
        Section = Color3.fromRGB(14, 30, 24),
        Element = Color3.fromRGB(18, 38, 30),
        Hover = Color3.fromRGB(24, 48, 38),
        Outline = Color3.fromRGB(38, 68, 56),
        OutlineLight = Color3.fromRGB(58, 96, 82),
        Accent = Color3.fromRGB(64, 224, 160),
        Accent2 = Color3.fromRGB(124, 255, 208),
        Text = Color3.fromRGB(238, 252, 246),
        SubText = Color3.fromRGB(146, 178, 164)
    }
}

local Palette_Keys = {"Background", "Sidebar", "Section", "Element", "Hover", "Outline", "OutlineLight", "Accent", "Accent2", "Text", "SubText"}
local Save_Config_Queued = false
local Is_Config_Loading = false
local Global_Settings_Path = "Moonshade_Settings.json"

local function Save_Global_Settings()
    if not writefile then return false end
    local Data_Val = {
        AutoSave = Config.AutoSave and true or false,
        AutoLoad = Config.AutoLoad and true or false,
        SelectedConfig = tostring(Config.SelectedConfig or Config.ConfigName or "default"),
        ConfigName = tostring(Config.ConfigName or Config.SelectedConfig or "default")
    }
    local Ok_State, Encoded_Val = pcall(function() return Http_Service:JSONEncode(Data_Val) end)
    if Ok_State then
        pcall(writefile, Global_Settings_Path, Encoded_Val)
        return true
    end
    return false
end

local function Load_Global_Settings()
    if not (isfile and readfile and isfile(Global_Settings_Path)) then return false end
    local Ok_State, Decoded_Val = pcall(function() return Http_Service:JSONDecode(readfile(Global_Settings_Path)) end)
    if Ok_State and type(Decoded_Val) == "table" then
        if Decoded_Val.AutoSave ~= nil then Config.AutoSave = Decoded_Val.AutoSave and true or false end
        if Decoded_Val.AutoLoad ~= nil then Config.AutoLoad = Decoded_Val.AutoLoad and true or false end
        if type(Decoded_Val.SelectedConfig) == "string" and Decoded_Val.SelectedConfig ~= "" then Config.SelectedConfig = Decoded_Val.SelectedConfig end
        if type(Decoded_Val.ConfigName) == "string" and Decoded_Val.ConfigName ~= "" then Config.ConfigName = Decoded_Val.ConfigName end
        return true
    end
    return false
end

local function Get_Config_Base_Name()
    local Name_Val = tostring(Config.ConfigName or "default")
    Name_Val = Name_Val:gsub("[^%w%-%._]", "_")
    if Name_Val == "" then Name_Val = "default" end
    return Name_Val
end

local function Get_Config_Path()
    return "Moonshade_" .. Get_Config_Base_Name() .. ".json"
end

local function Get_Layout_Path()
    return "Moonshade_" .. Get_Config_Base_Name() .. "_layout.json"
end

local function Get_Available_Configs()
    local Names_Array = {}
    local Seen_Table = {}
    local function Add_Val(Name_Val)
        Name_Val = tostring(Name_Val or ""):gsub("[^%w%-%._]", "_")
        if Name_Val == "" then return end
        if not Seen_Table[Name_Val] then
            Seen_Table[Name_Val] = true
            table.insert(Names_Array, Name_Val)
        end
    end
    Add_Val(Config.SelectedConfig or Config.ConfigName or "default")
    Add_Val(Config.ConfigName or "default")
    if listfiles then
        local Ok_State, Files_Array = pcall(listfiles, ".")
        if Ok_State and type(Files_Array) == "table" then
            for _, File_Path in ipairs(Files_Array) do
                local Name_Val = tostring(File_Path):match("Moonshade_(.-)%.json$")
                if Name_Val and not Name_Val:match("_layout$") then
                    Add_Val(Name_Val)
                end
            end
        end
    end
    if #Names_Array == 0 then Add_Val("default") end
    table.sort(Names_Array, function(A_Val, B_Val) return tostring(A_Val):lower() < tostring(B_Val):lower() end)
    return Names_Array
end

local function Apply_Palette(Palette_Table)
    if type(Palette_Table) ~= "table" then return end
    for _, Key_Val in ipairs(Palette_Keys) do
        if Palette_Table[Key_Val] then
            Library_Data.Palette[Key_Val] = Palette_Table[Key_Val]
        end
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

local function Queue_Save_Config()
    Save_Config_Queued = true
end

local function Apply_Theme_Preset(Theme_Name, Keep_Accent)
    local Preset_Val = Theme_Presets[Theme_Name]
    if not Preset_Val then
        Preset_Val = Theme_Presets.Nightfall
        Theme_Name = "Nightfall"
    end
    local Accent_Val = Library_Data.Palette.Accent
    local Accent_2_Val = Library_Data.Palette.Accent2
    local Accent_Alpha = type(Config.UiAccentColor) == "table" and Math_Clamp(Config.UiAccentColor.Alpha or 1, 0, 1) or 1
    local Accent_2_Alpha = type(Config.UiAccent2Color) == "table" and Math_Clamp(Config.UiAccent2Color.Alpha or 1, 0, 1) or 1
    Apply_Palette(Preset_Val)
    if Keep_Accent then
        Library_Data.Palette.Accent = Accent_Val
        Library_Data.Palette.Accent2 = Accent_2_Val
    end
    Config.ThemePreset = Theme_Name
    Config.UiAccentColor = {
        Color = Library_Data.Palette.Accent,
        Alpha = Accent_Alpha
    }
    Config.UiAccent2Color = {
        Color = Library_Data.Palette.Accent2,
        Alpha = Accent_2_Alpha
    }
    Sync_Theme_Editor_State()
    Queue_Save_Config()
end

local function Save_Current_Config()
    if not writefile then return false end
    local Data_Val = {}
    for Key_Val, Value_In in pairs(Config) do
        local T_Val = type(Value_In)
        if Key_Val ~= "AutoSave" and Key_Val ~= "AutoLoad" and Key_Val ~= "SelectedConfig" and (T_Val == "boolean" or T_Val == "number" or T_Val == "string") then
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
    local Layout_Val = {
        WindowX = Library_Data.TargetPosition.X,
        WindowY = Library_Data.TargetPosition.Y,
        HotkeysX = Library_Data.HotkeysPosition.X,
        HotkeysY = Library_Data.HotkeysPosition.Y,
        StatsX = Library_Data.StatsPosition.X,
        StatsY = Library_Data.StatsPosition.Y
    }
    local Ok2_State, Layout_Encoded = pcall(function() return Http_Service:JSONEncode(Layout_Val) end)
    if not Ok2_State then return false end
    writefile(Get_Config_Path(), Encoded_Val)
    writefile(Get_Layout_Path(), Layout_Encoded)
    Config.SelectedConfig = Config.ConfigName
    Save_Global_Settings()
    Save_Config_Queued = false
    Is_Config_Loading = false
    return true
end

local function Delete_Named_Config(Name_Val)
    local Target_Val = tostring(Name_Val or "")
    Target_Val = Target_Val:gsub("[^%w%-%._]", "_")
    if Target_Val == "" then return false end
    local Old_Config_Name = Config.ConfigName
    Config.ConfigName = Target_Val
    local Cfg_Path = Get_Config_Path()
    local Layout_Path = Get_Layout_Path()
    Config.ConfigName = Old_Config_Name
    local Deleted_Val = false
    if delfile then
        if isfile and isfile(Cfg_Path) then
            pcall(delfile, Cfg_Path)
            Deleted_Val = true
        end
        if isfile and isfile(Layout_Path) then
            pcall(delfile, Layout_Path)
        end
    end
    local Available_Val = Get_Available_Configs()
    local Fallback_Val = Available_Val[1] or "default"
    if Config.SelectedConfig == Target_Val then Config.SelectedConfig = Fallback_Val end
    if Config.ConfigName == Target_Val then Config.ConfigName = Fallback_Val end
    Save_Global_Settings()
    Save_Config_Queued = false
    return Deleted_Val
end

local function Load_Named_Config(Name_Val)
    local Old_Name = Config.ConfigName
    Is_Config_Loading = true
    if Name_Val and Name_Val ~= "" then Config.ConfigName = tostring(Name_Val) end
    local Path_Val = Get_Config_Path()
    if not (isfile and readfile and isfile(Path_Val)) then
        Config.ConfigName = Old_Name
        Is_Config_Loading = false
        return false
    end
    local Ok_State, Decoded_Val = pcall(function() return Http_Service:JSONDecode(readfile(Path_Val)) end)
    if not Ok_State or type(Decoded_Val) ~= "table" then
        Config.ConfigName = Old_Name
        Is_Config_Loading = false
        return false
    end
    for Key_Val, Value_In in pairs(Decoded_Val) do
        if Key_Val ~= "UiAccentColor" and Key_Val ~= "UiAccent2Color" and Key_Val ~= "SelectedConfig" and Key_Val ~= "AutoSave" and Key_Val ~= "AutoLoad" and type(Value_In) ~= "table" then
            Config[Key_Val] = Value_In
        end
    end
    if Decoded_Val.AutoLoadConfig ~= nil and Decoded_Val.AutoLoad == nil then
        Config.AutoLoad = Decoded_Val.AutoLoadConfig and true or false
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
    local Layout_Path = Get_Layout_Path()
    if isfile and readfile and isfile(Layout_Path) then
        local Ok_Layout, Layout_Val = pcall(function() return Http_Service:JSONDecode(readfile(Layout_Path)) end)
        if Ok_Layout and type(Layout_Val) == "table" then
            if Layout_Val.WindowX and Layout_Val.WindowY then
                Library_Data.Position = Vector2.new(Layout_Val.WindowX, Layout_Val.WindowY)
                Library_Data.TargetPosition = Vector2.new(Layout_Val.WindowX, Layout_Val.WindowY)
            end
            if Layout_Val.HotkeysX and Layout_Val.HotkeysY then
                Library_Data.HotkeysPosition = Vector2.new(Layout_Val.HotkeysX, Layout_Val.HotkeysY)
            end
            if Layout_Val.StatsX and Layout_Val.StatsY then
                Library_Data.StatsPosition = Vector2.new(Layout_Val.StatsX, Layout_Val.StatsY)
            end
        end
    end
    Config.SelectedConfig = Config.ConfigName
    Save_Global_Settings()
    Save_Config_Queued = false
    Is_Config_Loading = false
    return true
end

Load_Global_Settings()
if Config.AutoLoad then
    Load_Named_Config(Config.SelectedConfig or Config.ConfigName)
else
    Apply_Theme_Preset(Config.ThemePreset or "Nightfall", false)
end

local Window_Drawings = {
    Shadow = Make_Rounded_Box(Color3.new(0, 0, 0), 0.18),
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Topbar = Make_Rounded_Box(Library_Data.Palette.Sidebar, 1),
    Sidebar = Make_Rounded_Box(Library_Data.Palette.Sidebar, 1),
    Topline = Make_Gradient_Line(56),
    PatternBack = Make_Stripe_Pattern(72, 11),
    PatternFront = Make_Stripe_Pattern(72, 7),
    SidebarLine = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    TopBorder = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    Title = Create_Drawing("Text", {Text = "Nightfall | Recode", Color = Library_Data.Palette.Text, Size = 13, Font = 2, Outline = true, Visible = false})
}

local Stats_Drawings = {
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Topline = Make_Gradient_Line(44),
    HeaderLine = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    Row1 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row3 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Title = Create_Drawing("Text", {Text = "BALL STATS", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Speed = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Distance = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Dot = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local Keybinds_Drawings = {
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Topline = Make_Gradient_Line(44),
    HeaderLine = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false}),
    TitleIcon = Create_Keybind_Image_Icon(18),
    Title = Create_Drawing("Text", {Text = "HOTKEYS", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Subtitle = Create_Drawing("Text", {Text = "", Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Row1 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row3 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Row4 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Bind1 = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind2 = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind3 = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind4 = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State1 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State2 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State3 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State4 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Mode1 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode2 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode3 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode4 = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    MenuOutline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    MenuBackground = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    MenuOption1 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    MenuOption2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    MenuOption1Text = Create_Drawing("Text", {Text = "Hold", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    MenuOption2Text = Create_Drawing("Text", {Text = "Toggle", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

function Library_Data:CreateTab(Tab_Name, Tab_Icon)
    local Tab_Obj = {
        Name = Tab_Name,
        Icon = "",
        Sections = {},
        Background = Make_Rounded_Box(self.Palette.Hover, 0.88),
        Label = Create_Drawing("Text", {Text = Tab_Name, Size = 12, Font = 2, Outline = true, Visible = false}),
        IconDraw = Create_Drawing("Text", {Text = "", Size = 12, Font = 2, Outline = true, Visible = false}),
        Indicator = Make_Rounded_Box(self.Palette.Accent, 1),
        CurrentColor = self.Palette.SubText,
        CurrentIconColor = self.Palette.SubText,
        BgAlpha = 0
    }

    function Tab_Obj:CreateSection(Section_Name, Section_Side)
        local Section_Obj = {
            Name = Section_Name,
            Side = Section_Side,
            Items = {},
            Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
            Background = Make_Rounded_Box(Library_Data.Palette.Section, 1),
            PatternBack = Make_Stripe_Pattern(40, 9),
            PatternFront = Make_Stripe_Pattern(40, 5),
            Title = Create_Drawing("Text", {Text = Section_Name, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
            Line = Create_Drawing("Square", {Color = Library_Data.Palette.Outline, Filled = true, Visible = false})
        }

        function Section_Obj:UpdateContainer(X_Val, Y_Val, W_Val, H_Val)
            Update_Rounded_Box(self.Outline, Vector_2_Round(X_Val, Y_Val), Vector_2_Round(W_Val, H_Val), 6, Library_Data.Palette.Outline, 1, true)
            Update_Rounded_Box(self.Background, Vector_2_Round(X_Val + 1, Y_Val + 1), Vector_2_Round(W_Val - 2, H_Val - 2), 6, Library_Data.Palette.Section, 1, true)
            Update_Stripe_Pattern(self.PatternBack, 0, 0, 0, 0, 0, 0, Library_Data.Palette.Background, false)
            Update_Stripe_Pattern(self.PatternFront, 0, 0, 0, 0, 0, 0, Library_Data.Palette.Background, false)
            self.Title.Visible = true
            self.Title.Position = Vector_2_Round(X_Val + 10, Y_Val + 6)
            self.Line.Visible = true
            self.Line.Position = Vector_2_Round(X_Val + 10, Y_Val + 25)
            self.Line.Size = Vector_2_Round(W_Val - 20, 1)
            self.Line.Color = Library_Data.Palette.Outline
        end

        function Section_Obj:CreateToggle(Name_Val, Flag_Val, Default_Val)
            Config[Flag_Val] = Config[Flag_Val] ~= nil and Config[Flag_Val] or (Default_Val or false)
            local Toggle_Obj = {
                Type = "Toggle",
                Height = 24,
                Flag = Flag_Val,
                BoxStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Box = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                Fill = Make_Rounded_Box(Library_Data.Palette.Accent, 1),
                Label = Create_Drawing("Text", {Text = Name_Val, Size = 12, Font = 2, Outline = true, Visible = false}),
                CurrentColor = Library_Data.Palette.SubText,
                Alpha = Config[Flag_Val] and 1 or 0,
                HitboxPos = Vector2.new(),
                HitboxSize = Vector2.new()
            }

            function Toggle_Obj:Update(X_Val, Y_Val, W_Val)
                self.HitboxPos = Vector_2_Round(X_Val, Y_Val)
                self.HitboxSize = Vector_2_Round(W_Val, 20)
                Update_Rounded_Box(self.BoxStroke, Vector_2_Round(X_Val + 2, Y_Val + 3), Vector_2_Round(16, 16), 4, Color_Lerp(Library_Data.Palette.Outline, Library_Data.Palette.Accent, self.Alpha), 1, true)
                Update_Rounded_Box(self.Box, Vector_2_Round(X_Val + 3, Y_Val + 4), Vector_2_Round(14, 14), 4, Library_Data.Palette.Element, 1, true)

                self.Label.Visible = true
                self.Label.Position = Vector_2_Round(X_Val + 26, Y_Val + 4)

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
                Type = "Slider",
                Height = 44,
                Min = Min_Val,
                Max = Max_Val,
                Step = Step_Val,
                Flag = Flag_Val,
                InputBuffer = Format_Slider_Value(Config[Flag_Val], Step_Val),
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                Fill = Make_Rounded_Box(Library_Data.Palette.Accent, 1),
                Knob = Make_Rounded_Box(Library_Data.Palette.Text, 1),
                ValuePos = Vector2.new(),
                ValueSize = Vector2.new(),
                BarPos = Vector2.new(),
                BarSize = Vector2.new()
            }

            function Slider_Obj:Update(X_Val, Y_Val, W_Val)
                local Is_Editing = Library_Data.State.ActiveSliderInput == self
                self.Label.Visible = true
                self.Label.Position = Vector_2_Round(X_Val + 2, Y_Val)

                local Display_Text = Is_Editing and (((Fast_Tick() % 1) < 0.5) and (self.InputBuffer .. "_") or self.InputBuffer) or Format_Slider_Value(Config[self.Flag], self.Step)
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = Display_Text
                self.ValueLabel.Color = Is_Editing and Library_Data.Palette.Accent or Library_Data.Palette.SubText
                self.ValuePos = Vector_2_Round(X_Val + W_Val - self.ValueLabel.TextBounds.X - 4, Y_Val)
                self.ValueSize = Vector_2_Round(Fast_Max(self.ValueLabel.TextBounds.X + 8, 24), 16)
                self.ValueLabel.Position = Vector_2_Round(self.ValuePos.X + 4, Y_Val)

                if not Is_Editing then
                    self.InputBuffer = Format_Slider_Value(Config[self.Flag], self.Step)
                end

                local Bar_Y = Y_Val + 26
                local Bar_Width = W_Val - self.ValueSize.X - 12
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
                Type = "Dropdown",
                Height = 46,
                Options = Options_Array or {},
                Flag = Flag_Val,
                IsOpen = false,
                ListHeight = 0,
                TargetListHeight = 0,
                OpenAlpha = 0,
                HoveredIndex = nil,
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                Icon = Create_Drawing("Text", {Text = "+", Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                ListStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                ListBackground = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                OptionDrawings = {},
                OptionBounds = {},
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new(),
                ListPos = Vector2.new(),
                ListSize = Vector2.new()
            }

            function Dropdown_Obj:SetOptions(New_Options, Preserve_Value)
                self.Options = New_Options or {}
                if not Preserve_Value then
                    if #self.Options > 0 then
                        Config[self.Flag] = self.Options[1]
                    else
                        Config[self.Flag] = nil
                    end
                else
                    local Found_Val = false
                    for _, Option_Val in ipairs(self.Options) do
                        if tostring(Option_Val) == tostring(Config[self.Flag]) then
                            Found_Val = true
                            break
                        end
                    end
                    if not Found_Val then
                        if #self.Options > 0 then
                            Config[self.Flag] = self.Options[1]
                        else
                            Config[self.Flag] = nil
                        end
                    end
                end
                self.OptionBounds = {}
                self.HoveredIndex = nil
            end

            function Dropdown_Obj:GetVisibleOptionBounds()
                local Result_Array = {}
                for Index_Val, Bounds_Val in ipairs(self.OptionBounds) do
                    if Bounds_Val and Bounds_Val.Visible then
                        Result_Array[Index_Val] = Bounds_Val
                    end
                end
                return Result_Array
            end

            function Dropdown_Obj:Update(X_Val, Y_Val, W_Val)
                self.Label.Visible = true
                self.Label.Position = Vector_2_Round(X_Val + 2, Y_Val)

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
                    if tostring(Option_Val) == tostring(Current_Value) then
                        Selected_Index = Idx_Val
                        Current_Value = Option_Val
                        break
                    end
                end
                if Selected_Index == nil and #self.Options > 0 then
                    Current_Value = self.Options[1]
                    Config[self.Flag] = Current_Value
                    Selected_Index = 1
                end

                self.ValueLabel.Visible = true
                self.ValueLabel.Text = tostring(Current_Value or "")
                self.ValueLabel.Position = Vector_2_Round(self.ButtonPos.X + 6, self.ButtonPos.Y + 5)
                self.ValueLabel.Color = Button_Text_Color

                self.Icon.Visible = true
                self.Icon.Text = self.IsOpen and "-" or "+"
                self.Icon.Position = Vector_2_Round(self.ButtonPos.X + self.ButtonSize.X - 14, self.ButtonPos.Y + 5)
                self.Icon.Color = Button_Text_Color

                self.TargetListHeight = self.IsOpen and (#self.Options * 24 + (#self.Options > 0 and 2 or 0)) or 0
                self.ListHeight = Math_Lerp(self.ListHeight, self.TargetListHeight, 0.3)
                if math.abs(self.ListHeight - self.TargetListHeight) < 0.5 then
                    self.ListHeight = self.TargetListHeight
                end

                self.OpenAlpha = Math_Lerp(self.OpenAlpha, self.IsOpen and 1 or 0, 0.3)
                if math.abs(self.OpenAlpha - (self.IsOpen and 1 or 0)) < 0.02 then
                    self.OpenAlpha = self.IsOpen and 1 or 0
                end

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
                        self.OptionDrawings[I_Idx] = Create_Drawing("Text", {Text = tostring(Option_Str), Size = 12, Font = 2, Outline = true, Visible = false})
                    end

                    local Txt_Draw = self.OptionDrawings[I_Idx]
                    local Option_Pos = Vector_2_Round(self.ListPos.X + 6, self.ListPos.Y + 3 + ((I_Idx - 1) * 24))
                    local Option_Size = Vector_2_Round(self.ListSize.X - 12, 20)
                    local Option_Bottom = Option_Pos.Y + Option_Size.Y
                    local Clip_Bottom = self.ListPos.Y + Draw_List_Height - 2
                    local Option_Visible = List_Visible and Option_Pos.Y >= self.ListPos.Y + 1 and Option_Bottom <= Clip_Bottom + 1

                    self.OptionBounds[I_Idx] = {
                        Pos = Option_Pos,
                        Size = Option_Size,
                        Visible = Option_Visible
                    }

                    if Option_Visible and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Option_Pos, Option_Size) then
                        self.HoveredIndex = I_Idx
                    end

                    Txt_Draw.Visible = Option_Visible
                    if Option_Visible then
                        Txt_Draw.Text = tostring(Option_Str)
                        Txt_Draw.Position = Vector_2_Round(Option_Pos.X, Option_Pos.Y + 3)
                        if Selected_Index == I_Idx then
                            Txt_Draw.Color = Library_Data.Palette.Accent
                        elseif self.HoveredIndex == I_Idx then
                            Txt_Draw.Color = Library_Data.Palette.Text
                        else
                            Txt_Draw.Color = Library_Data.Palette.SubText
                        end
                        Txt_Draw.Transparency = Fast_Max(self.OpenAlpha, 0.08)
                    end
                end

                for I_Idx = #self.Options + 1, #self.OptionDrawings do
                    self.OptionDrawings[I_Idx].Visible = false
                end

                self.Height = 46 + (List_Visible and (Draw_List_Height + 4) or 0)
            end

            table.insert(self.Items, Dropdown_Obj)
            return Dropdown_Obj
        end

        function Section_Obj:CreateColorPicker(Name_Val, Flag_Val, Default_Color, Default_Alpha, Callback_Func)
            local Initial_Color = Default_Color or Library_Data.Palette.Accent
            local Initial_Alpha = Default_Alpha
            if Initial_Alpha == nil then
                Initial_Alpha = 1
            end
            if type(Config[Flag_Val]) ~= "table" or not Config[Flag_Val].Color then
                Config[Flag_Val] = {
                    Color = Initial_Color,
                    Alpha = Math_Clamp(Initial_Alpha, 0, 1)
                }
            end

            local H_Val, S_Val, V_Val = Color3_To_Hsv(Config[Flag_Val].Color)

            local Color_Picker = {
                Type = "ColorPicker",
                Height = 36,
                Flag = Flag_Val,
                Callback = Callback_Func,
                IsOpen = false,
                Hue = H_Val,
                Sat = S_Val,
                Val = V_Val,
                Alpha = Math_Clamp(Config[Flag_Val].Alpha or 1, 0, 1),
                GridCols = 32,
                GridRows = 18,
                HueSteps = 32,
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                PreviewStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Preview = Make_Rounded_Box(Config[Flag_Val].Color, 1),
                PreviewText = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                PopupStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                PopupBackground = Make_Rounded_Box(Library_Data.Palette.Background, 1),
                PopupSwatchStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                PopupSwatch = Make_Rounded_Box(Config[Flag_Val].Color, 1),
                PopupHex = Create_Drawing("Text", {Color = Library_Data.Palette.Text, Size = 11, Font = 2, Outline = true, Visible = false}),
                SVStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                HueStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                SVGrid = Create_Grid_Squares(32 * 18),
                HueGrid = Create_Grid_Squares(32),
                CursorOuter = Create_Drawing("Circle", {Filled = false, Thickness = 2, Transparency = 1, NumSides = 24, Radius = 6, Visible = false}),
                CursorInner = Create_Drawing("Circle", {Filled = false, Thickness = 1, Transparency = 1, NumSides = 24, Radius = 4, Visible = false}),
                HueLine = Create_Drawing("Line", {Thickness = 2, Transparency = 1, Visible = false}),
                HueCapTop = Create_Drawing("Circle", {Filled = true, Transparency = 1, NumSides = 20, Radius = 3, Visible = false}),
                HueCapBottom = Create_Drawing("Circle", {Filled = true, Transparency = 1, NumSides = 20, Radius = 3, Visible = false}),
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new(),
                PopupPos = Vector2.new(),
                PopupSize = Vector2.new(),
                SVPos = Vector2.new(),
                SVSize = Vector2.new(),
                HuePos = Vector2.new(),
                HueSize = Vector2.new()
            }

            function Color_Picker:SyncColor()
                local State_Val = Config[self.Flag]
                if type(State_Val) ~= "table" then
                    State_Val = {}
                    Config[self.Flag] = State_Val
                end
                State_Val.Color = Hsv_To_Color3(self.Hue, self.Sat, self.Val)
                State_Val.Alpha = Math_Clamp(self.Alpha, 0, 1)
                if self.Callback then
                    self.Callback(State_Val)
                end
            end

            function Color_Picker:Update(X_Val, Y_Val, W_Val)
                self:SyncColor()

                local State_Val = Config[self.Flag]
                local Current_Color = State_Val and State_Val.Color or Hsv_To_Color3(self.Hue, self.Sat, self.Val)
                local Current_Hex = Color3_To_Hex(Current_Color)

                self.Label.Visible = true
                self.Label.Position = Vector_2_Round(X_Val + 2, Y_Val + 4)

                self.ButtonPos = Vector_2_Round(X_Val + W_Val - 84, Y_Val + 4)
                self.ButtonSize = Vector_2_Round(80, 24)

                Update_Rounded_Box(self.Stroke, self.ButtonPos, self.ButtonSize, 4, self.IsOpen and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vector_2_Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector_2_Round(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, Library_Data.Palette.Element, 1, true)
                Update_Rounded_Box(self.PreviewStroke, Vector_2_Round(self.ButtonPos.X + 5, self.ButtonPos.Y + 5), Vector_2_Round(14, 14), 3, Library_Data.Palette.OutlineLight, 1, true)
                Update_Rounded_Box(self.Preview, Vector_2_Round(self.ButtonPos.X + 6, self.ButtonPos.Y + 6), Vector_2_Round(12, 12), 2, Current_Color, Fast_Max(State_Val and State_Val.Alpha or 1, 0.15), true)

                self.PreviewText.Visible = true
                self.PreviewText.Text = Current_Hex
                self.PreviewText.Color = self.IsOpen and Library_Data.Palette.Text or Library_Data.Palette.SubText
                self.PreviewText.Position = Vector_2_Round(self.ButtonPos.X + 24, self.ButtonPos.Y + 7)

                if self.IsOpen then
                    local Popup_W = 246
                    local Popup_H = 160
                    self.PopupPos = Vector_2_Round(X_Val + W_Val - Popup_W - 4, Y_Val + 32)
                    self.PopupSize = Vector_2_Round(Popup_W, Popup_H)
                    self.Height = 196

                    Update_Rounded_Box(self.PopupStroke, self.PopupPos, self.PopupSize, 5, Library_Data.Palette.Outline, 1, true)
                    Update_Rounded_Box(self.PopupBackground, Vector_2_Round(self.PopupPos.X + 1, self.PopupPos.Y + 1), Vector_2_Round(self.PopupSize.X - 2, self.PopupSize.Y - 2), 5, Library_Data.Palette.Background, 1, true)

                    self.SVPos = Vector_2_Round(self.PopupPos.X + 10, self.PopupPos.Y + 10)
                    self.SVSize = Vector_2_Round(226, 104)
                    self.HuePos = Vector_2_Round(self.PopupPos.X + 10, self.PopupPos.Y + 124)
                    self.HueSize = Vector_2_Round(226, 16)

                    Update_Rounded_Box(self.SVStroke, Vector_2_Round(self.SVPos.X - 1, self.SVPos.Y - 1), Vector_2_Round(self.SVSize.X + 2, self.SVSize.Y + 2), 3, Library_Data.Palette.Outline, 1, true)
                    Update_Rounded_Box(self.HueStroke, Vector_2_Round(self.HuePos.X - 1, self.HuePos.Y - 1), Vector_2_Round(self.HueSize.X + 2, self.HueSize.Y + 2), 3, Library_Data.Palette.Outline, 1, true)

                    Update_Grid_Squares(self.SVGrid, self.GridCols, self.GridRows, self.SVPos.X, self.SVPos.Y, self.SVSize.X, self.SVSize.Y, function(Col_Val, Row_Val, Cols_Val, Rows_Val)
                        local Sat_Val = (Col_Val - 1) / Fast_Max(Cols_Val - 1, 1)
                        local Val_Val = 1 - ((Row_Val - 1) / Fast_Max(Rows_Val - 1, 1))
                        return Hsv_To_Color3(self.Hue, Sat_Val, Val_Val)
                    end, true)

                    Update_Grid_Squares(self.HueGrid, self.HueSteps, 1, self.HuePos.X, self.HuePos.Y, self.HueSize.X, self.HueSize.Y, function(Col_Val, _, Cols_Val)
                        local Hh_Val = (Col_Val - 1) / Fast_Max(Cols_Val - 1, 1)
                        return Hsv_To_Color3(Hh_Val, 1, 1)
                    end, true)

                    local Cursor_X = self.SVPos.X + (self.Sat * self.SVSize.X)
                    local Cursor_Y = self.SVPos.Y + ((1 - self.Val) * self.SVSize.Y)
                    self.CursorOuter.Visible = true
                    self.CursorOuter.Color = Color3.new(0, 0, 0)
                    self.CursorOuter.Position = Vector_2_Round(Cursor_X, Cursor_Y)
                    self.CursorOuter.Radius = 6
                    self.CursorInner.Visible = true
                    self.CursorInner.Color = Color3.new(1, 1, 1)
                    self.CursorInner.Position = Vector_2_Round(Cursor_X, Cursor_Y)
                    self.CursorInner.Radius = 4

                    local Hue_X = self.HuePos.X + (self.Hue * self.HueSize.X)
                    self.HueLine.Visible = true
                    self.HueLine.Color = Library_Data.Palette.Text
                    self.HueLine.From = Vector_2_Round(Hue_X, self.HuePos.Y - 3)
                    self.HueLine.To = Vector_2_Round(Hue_X, self.HuePos.Y + self.HueSize.Y + 3)

                    self.HueCapTop.Visible = true
                    self.HueCapTop.Color = Library_Data.Palette.Text
                    self.HueCapTop.Position = Vector_2_Round(Hue_X, self.HuePos.Y - 3)
                    self.HueCapTop.Radius = 3
                    self.HueCapBottom.Visible = true
                    self.HueCapBottom.Color = Library_Data.Palette.Text
                    self.HueCapBottom.Position = Vector_2_Round(Hue_X, self.HuePos.Y + self.HueSize.Y + 3)
                    self.HueCapBottom.Radius = 3

                    Update_Rounded_Box(self.PopupSwatchStroke, Vector_2_Round(self.PopupPos.X + 10, self.PopupPos.Y + 146), Vector_2_Round(22, 8), 2, Library_Data.Palette.OutlineLight, 1, true)
                    Update_Rounded_Box(self.PopupSwatch, Vector_2_Round(self.PopupPos.X + 11, self.PopupPos.Y + 147), Vector_2_Round(20, 6), 2, Current_Color, Fast_Max(State_Val and State_Val.Alpha or 1, 0.15), true)

                    self.PopupHex.Visible = true
                    self.PopupHex.Text = Current_Hex
                    self.PopupHex.Position = Vector_2_Round(self.PopupPos.X + 38, self.PopupPos.Y + 144)
                else
                    self.Height = 36
                    Update_Rounded_Box(self.PopupStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.PopupBackground, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.PopupSwatchStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.PopupSwatch, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.SVStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.HueStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Hide_Grid_Squares(self.SVGrid or {})
                    Hide_Grid_Squares(self.HueGrid or {})
                    self.CursorOuter.Visible = false
                    self.CursorInner.Visible = false
                    self.HueLine.Visible = false
                    self.HueCapTop.Visible = false
                    self.HueCapBottom.Visible = false
                    self.PopupHex.Visible = false
                end
            end

            table.insert(self.Items, Color_Picker)
            return Color_Picker
        end

        function Section_Obj:CreateKeybind(Name_Val, Flag_Val, Default_Val)
            Config[Flag_Val] = Normalize_Keybind_Value(Config[Flag_Val] ~= nil and Config[Flag_Val] or (Default_Val or "None"))
            local Keybind_Obj = {
                Type = "Keybind",
                Height = 30,
                Flag = Flag_Val,
                Icon = Create_Keybind_Image_Icon(18),
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonStroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                ButtonBox = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new()
            }

            function Keybind_Obj:Update(X_Val, Y_Val, W_Val)
                Update_Keybind_Image_Icon(self.Icon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false)

                self.Label.Visible = true
                self.Label.Position = Vector_2_Round(X_Val + 2, Y_Val + 8)

                local Bind_Value = Normalize_Keybind_Value(Config[self.Flag])
                local Bind_Text = Library_Data.State.ActiveKeybind == self and "[...]" or ("[" .. Bind_Value .. "]")
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = Bind_Text

                local Btn_Width = Fast_Max(74, self.ValueLabel.TextBounds.X + 20)
                self.ButtonPos = Vector_2_Round(X_Val + W_Val - Btn_Width - 2, Y_Val + 4)
                self.ButtonSize = Vector_2_Round(Btn_Width, 22)

                local Is_Active = Library_Data.State.ActiveKeybind == self
                Update_Keybind_Image_Icon(self.Icon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false)
                Update_Rounded_Box(self.ButtonStroke, self.ButtonPos, self.ButtonSize, 4, Is_Active and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.ButtonBox, Vector_2_Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector_2_Round(Btn_Width - 2, 20), 4, Is_Active and Library_Data.Palette.Hover or Library_Data.Palette.Element, 1, true)

                self.ValueLabel.Color = Is_Active and Library_Data.Palette.Text or Library_Data.Palette.SubText
                self.ValueLabel.Position = Vector_2_Round(
                    self.ButtonPos.X + Fast_Floor((Btn_Width - self.ValueLabel.TextBounds.X) / 2 + 0.5),
                    self.ButtonPos.Y + Fast_Floor((self.ButtonSize.Y - self.ValueLabel.TextBounds.Y) / 2 + 0.5) - 1
                )
            end

            table.insert(self.Items, Keybind_Obj)
            return Keybind_Obj
        end


        function Section_Obj:CreateButton(Name_Val, Callback_Func)
            local Button_Obj = {
                Type = "Button",
                Height = 34,
                Callback = Callback_Func,
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new()
            }

            function Button_Obj:Update(X_Val, Y_Val, W_Val)
                self.ButtonPos = Vector_2_Round(X_Val + 2, Y_Val + 4)
                self.ButtonSize = Vector_2_Round(W_Val - 4, 24)
                local Hovered_Val = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, self.ButtonPos, self.ButtonSize)
                Update_Rounded_Box(self.Stroke, self.ButtonPos, self.ButtonSize, 4, Hovered_Val and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vector_2_Round(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vector_2_Round(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, Hovered_Val and Library_Data.Palette.Hover or Library_Data.Palette.Element, 1, true)
                self.Label.Visible = true
                self.Label.Color = Library_Data.Palette.Text
                self.Label.Position = Vector_2_Round(self.ButtonPos.X + Fast_Floor((self.ButtonSize.X - self.Label.TextBounds.X) / 2 + 0.5), self.ButtonPos.Y + 6)
            end

            table.insert(self.Items, Button_Obj)
            return Button_Obj
        end

        function Section_Obj:CreateTextbox(Name_Val, Flag_Val, Default_Val)
            Config[Flag_Val] = Config[Flag_Val] ~= nil and Config[Flag_Val] or (Default_Val or "")
            local Textbox_Obj = {
                Type = "Textbox",
                Height = 36,
                Flag = Flag_Val,
                Label = Create_Drawing("Text", {Text = Name_Val, Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library_Data.Palette.Element, 1),
                ValueLabel = Create_Drawing("Text", {Color = Library_Data.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                BoxPos = Vector2.new(),
                BoxSize = Vector2.new()
            }

            function Textbox_Obj:Update(X_Val, Y_Val, W_Val)
                self.Label.Visible = true
                self.Label.Position = Vector_2_Round(X_Val + 2, Y_Val + 4)
                local Box_Width = 110
                self.BoxPos = Vector_2_Round(X_Val + W_Val - Box_Width - 2, Y_Val + 6)
                self.BoxSize = Vector_2_Round(Box_Width, 24)

                local Is_Active = Library_Data.State.ActiveTextbox == self
                Update_Rounded_Box(self.Stroke, self.BoxPos, self.BoxSize, 4, Is_Active and Library_Data.Palette.Accent or Library_Data.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vector_2_Round(self.BoxPos.X + 1, self.BoxPos.Y + 1), Vector_2_Round(Box_Width - 2, 22), 4, Library_Data.Palette.Element, 1, true)

                local Display_Str = tostring(Config[self.Flag])
                if Is_Active and Fast_Tick() % 1 < 0.5 then
                    Display_Str = Display_Str .. "_"
                end

                self.ValueLabel.Visible = true
                self.ValueLabel.Text = Display_Str
                self.ValueLabel.Color = Is_Active and Library_Data.Palette.Text or Library_Data.Palette.SubText
                self.ValueLabel.Position = Vector_2_Round(X_Val + W_Val - Box_Width + 3, Y_Val + 11)
            end

            table.insert(self.Items, Textbox_Obj)
            return Textbox_Obj
        end

        table.insert(Tab_Obj.Sections, Section_Obj)
        return Section_Obj
    end

    table.insert(Library_Data.Tabs, Tab_Obj)
    if not Library_Data.CurrentTab then
        Library_Data.CurrentTab = Tab_Obj
    end
    return Tab_Obj
end

local Tab_Combat = Library_Data:CreateTab("Combat")

local Sec_Combat_Parry = Tab_Combat:CreateSection("Auto Parry", "Left")
Sec_Combat_Parry:CreateToggle("Auto Parry", "AutoParry", false)
Sec_Combat_Parry:CreateDropdown("Parry Method", "ParryMethod", {"Click", "Key"}, "Click")
Sec_Combat_Parry:CreateKeybind("Parry Bind", "ParryKeybind", "None")
Sec_Combat_Parry:CreateToggle("Training Balls", "TrainingBallsSupport", false)

local Sec_Combat_Spam = Tab_Combat:CreateSection("Auto Spam", "Right")
Sec_Combat_Spam:CreateToggle("Auto Spam", "AutoSpam", false)
Sec_Combat_Spam:CreateKeybind("Spam Bind", "SpamKeybind", "None")
Sec_Combat_Spam:CreateSlider("Spam Rate", "SpamRate", 10, 200, 100, 1)

local Sec_Combat_Trigger = Tab_Combat:CreateSection("Trigger Bot", "Right")
Sec_Combat_Trigger:CreateToggle("Trigger Bot", "TriggerBot", false)
Sec_Combat_Trigger:CreateKeybind("Trigger Bind", "TriggerKeybind", "None")
Sec_Combat_Trigger:CreateSlider("Delay (ms)", "TriggerDelay", 0, 10, 0, 1)

local Tab_Visuals = Library_Data:CreateTab("Visuals")

local Sec_Vis_Main = Tab_Visuals:CreateSection("Visual Settings", "Left")
Sec_Vis_Main:CreateToggle("Ball Stats", "RenderBallStats", false)
Sec_Vis_Main:CreateToggle("Hotkey List", "ShowHotkeyList", true)

local Tab_Settings = Library_Data:CreateTab("Settings")

local Sec_Settings_Config = Tab_Settings:CreateSection("Configuration", "Left")
Sec_Settings_Config:CreateKeybind("Menu Bind", "HideKeybind", 27)
Sec_Settings_Config:CreateToggle("Auto Save", "AutoSave", Config.AutoSave)
Sec_Settings_Config:CreateToggle("Auto Load", "AutoLoad", Config.AutoLoad)

local Sec_Themes_Main = Tab_Settings:CreateSection("Theme Presets", "Right")
Sec_Themes_Main:CreateDropdown("Preset", "ThemePreset", {"Nightfall", "Bloodmoon", "Ocean", "Mint"}, Config.ThemePreset or "Nightfall")
Sec_Themes_Main:CreateColorPicker("Accent", "UiAccentColor", Library_Data.Palette.Accent, 1, function(State_Val) Library_Data.Palette.Accent = State_Val.Color end)
Sec_Themes_Main:CreateColorPicker("Accent 2", "UiAccent2Color", Library_Data.Palette.Accent2, 1, function(State_Val) Library_Data.Palette.Accent2 = State_Val.Color end)

local Overlay_Menu_Drawings = {
    Outline = Make_Rounded_Box(Library_Data.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library_Data.Palette.Background, 1),
    Option1 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Option2 = Make_Rounded_Box(Library_Data.Palette.Element, 1),
    Option1Text = Create_Drawing("Text", {Text = "Hold", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Option2Text = Create_Drawing("Text", {Text = "Toggle", Color = Library_Data.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local function Close_Transient_Ui()
    if Library_Data.State.ActiveDropdown then
        Library_Data.State.ActiveDropdown.IsOpen = false
    end
    if Library_Data.State.ActiveColorPicker then
        Library_Data.State.ActiveColorPicker.IsOpen = false
    end
    Library_Data.State.ActiveDropdown = nil
    Library_Data.State.ActiveSlider = nil
    if Library_Data.State.ActiveSliderInput then
        Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
    end
    Library_Data.State.ActiveSliderInput = nil
    Library_Data.State.ActiveTextbox = nil
    Library_Data.State.ActiveKeybind = nil
    Library_Data.State.ActiveColorPicker = nil
    Library_Data.State.ActiveColorDrag = nil
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
    Hide_Gradient_Line(Keybinds_Drawings.Topline)
    Keybinds_Drawings.HeaderLine.Visible = false
    Update_Keybind_Image_Icon(Keybinds_Drawings.TitleIcon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false)
    Keybinds_Drawings.Title.Visible = false
    Keybinds_Drawings.Subtitle.Visible = false
    for _, Row_Obj in ipairs({Keybinds_Drawings.Row1, Keybinds_Drawings.Row2, Keybinds_Drawings.Row3, Keybinds_Drawings.Row4, Keybinds_Drawings.MenuOutline, Keybinds_Drawings.MenuBackground, Keybinds_Drawings.MenuOption1, Keybinds_Drawings.MenuOption2}) do
        Update_Rounded_Box(Row_Obj, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end
    for _, Txt_Obj in ipairs({
        Keybinds_Drawings.Bind1, Keybinds_Drawings.Bind2, Keybinds_Drawings.Bind3, Keybinds_Drawings.Bind4,
        Keybinds_Drawings.State1, Keybinds_Drawings.State2, Keybinds_Drawings.State3, Keybinds_Drawings.State4,
        Keybinds_Drawings.Mode1, Keybinds_Drawings.Mode2, Keybinds_Drawings.Mode3, Keybinds_Drawings.Mode4,
        Keybinds_Drawings.MenuOption1Text, Keybinds_Drawings.MenuOption2Text
    }) do
        Txt_Obj.Visible = false
    end
end

local function Safe_Hide_Drawing(Draw_Obj)
    if Draw_Obj then
        Draw_Obj.Visible = false
    end
end

local function Hide_Item(Item_Obj)
    if not Item_Obj then
        return
    end

    if Item_Obj.Type == "Toggle" then
        if Item_Obj.BoxStroke then
            Update_Rounded_Box(Item_Obj.BoxStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Box then
            Update_Rounded_Box(Item_Obj.Box, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Fill then
            Update_Rounded_Box(Item_Obj.Fill, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        Safe_Hide_Drawing(Item_Obj.Label)
    elseif Item_Obj.Type == "Slider" then
        if Item_Obj.Stroke then
            Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Background then
            Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Fill then
            Update_Rounded_Box(Item_Obj.Fill, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.ValueStroke then
            Update_Rounded_Box(Item_Obj.ValueStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.ValueBackground then
            Update_Rounded_Box(Item_Obj.ValueBackground, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.KnobOuter then
            Update_Rounded_Box(Item_Obj.KnobOuter, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Knob then
            Update_Rounded_Box(Item_Obj.Knob, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        Safe_Hide_Drawing(Item_Obj.Label)
        Safe_Hide_Drawing(Item_Obj.ValueLabel)
        Safe_Hide_Drawing(Item_Obj.Dot)
    elseif Item_Obj.Type == "Dropdown" then
        Item_Obj.IsOpen = false
        Item_Obj.ListHeight = 0
        Item_Obj.TargetListHeight = 0
        Item_Obj.OpenAlpha = 0
        Safe_Hide_Drawing(Item_Obj.Label)
        Safe_Hide_Drawing(Item_Obj.ValueLabel)
        Safe_Hide_Drawing(Item_Obj.Icon)
        if Item_Obj.Stroke then
            Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Background then
            Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.ListStroke then
            Update_Rounded_Box(Item_Obj.ListStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.ListBackground then
            Update_Rounded_Box(Item_Obj.ListBackground, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        for _, Draw_Obj in ipairs(Item_Obj.OptionDrawings or {}) do
            Safe_Hide_Drawing(Draw_Obj)
        end
    elseif Item_Obj.Type == "ColorPicker" then
        Safe_Hide_Drawing(Item_Obj.Label)
        Safe_Hide_Drawing(Item_Obj.PreviewText)
        Safe_Hide_Drawing(Item_Obj.PopupHex)
        if Item_Obj.Stroke then
            Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Background then
            Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.PreviewStroke then
            Update_Rounded_Box(Item_Obj.PreviewStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Preview then
            Update_Rounded_Box(Item_Obj.Preview, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.PopupStroke then
            Update_Rounded_Box(Item_Obj.PopupStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.PopupBackground then
            Update_Rounded_Box(Item_Obj.PopupBackground, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.PopupSwatchStroke then
            Update_Rounded_Box(Item_Obj.PopupSwatchStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.PopupSwatch then
            Update_Rounded_Box(Item_Obj.PopupSwatch, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.SVStroke then
            Update_Rounded_Box(Item_Obj.SVStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.HueStroke then
            Update_Rounded_Box(Item_Obj.HueStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        Hide_Grid_Squares(Item_Obj.SVGrid or {})
        Hide_Grid_Squares(Item_Obj.HueGrid or {})
        Safe_Hide_Drawing(Item_Obj.CursorOuter)
        Safe_Hide_Drawing(Item_Obj.CursorInner)
        Safe_Hide_Drawing(Item_Obj.HueLine)
        Safe_Hide_Drawing(Item_Obj.HueCapTop)
        Safe_Hide_Drawing(Item_Obj.HueCapBottom)
    elseif Item_Obj.Type == "Keybind" then
        if Item_Obj.Icon then
            Update_Keybind_Image_Icon(Item_Obj.Icon, Vector_2_Round(0, 0), Library_Data.Palette.Accent, false)
        end
        Safe_Hide_Drawing(Item_Obj.Label)
        Safe_Hide_Drawing(Item_Obj.ValueLabel)
        if Item_Obj.ButtonStroke then
            Update_Rounded_Box(Item_Obj.ButtonStroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.ButtonBox then
            Update_Rounded_Box(Item_Obj.ButtonBox, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
    elseif Item_Obj.Type == "Textbox" then
        Safe_Hide_Drawing(Item_Obj.Label)
        Safe_Hide_Drawing(Item_Obj.ValueLabel)
        if Item_Obj.Stroke then
            Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Background then
            Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
    elseif Item_Obj.Type == "Button" then
        Safe_Hide_Drawing(Item_Obj.Label)
        if Item_Obj.Stroke then
            Update_Rounded_Box(Item_Obj.Stroke, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if Item_Obj.Background then
            Update_Rounded_Box(Item_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
    end
end

local function Hide_Tab_Content(Tab_Obj)
    if not Tab_Obj then
        return
    end
    for _, Section_Obj in ipairs(Tab_Obj.Sections) do
        Update_Rounded_Box(Section_Obj.Outline, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Section_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Hide_Stripe_Pattern(Section_Obj.PatternBack)
        Hide_Stripe_Pattern(Section_Obj.PatternFront)
        Section_Obj.Title.Visible = false
        Section_Obj.Line.Visible = false
        for _, Item_Obj in ipairs(Section_Obj.Items) do
            Hide_Item(Item_Obj)
        end
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

    local Is_Backspace_Down = iskeypressed and iskeypressed(8) or false
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

    if Now_Val < (Library_Data.State.BackspaceNextRepeat or 0) then
        return
    end

    Library_Data.State.BackspaceNextRepeat = Now_Val + 0.035

    if Target_Slider then
        local Current_Text = tostring(Target_Slider.InputBuffer or "")
        Target_Slider.InputBuffer = string.sub(Current_Text, 1, -2)
    elseif Target_Textbox then
        local Current_Text = tostring(Config[Target_Textbox.Flag] or "")
        Config[Target_Textbox.Flag] = string.sub(Current_Text, 1, -2)
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
    for _, Tab_Obj in ipairs(Library_Data.Tabs) do
        Update_Rounded_Box(Tab_Obj.Background, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Tab_Obj.Indicator, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Tab_Obj.Label.Visible = false
        Tab_Obj.IconDraw.Visible = false
        Hide_Tab_Content(Tab_Obj)
    end
end

Run_Service.RenderStepped:Connect(function()
    if not (isrbxactive and isrbxactive()) then
        return
    end
    Library_Data.Input.MousePos = Vector2.new(Local_Mouse.X, Local_Mouse.Y)
    Library_Data.Input.Mouse1Down = ismouse1pressed and ismouse1pressed() or false
    Library_Data.Input.Mouse1Clicked = Library_Data.Input.Mouse1Down and not Library_Data.Input.Mouse1Prev
    Library_Data.Input.Mouse1Released = not Library_Data.Input.Mouse1Down and Library_Data.Input.Mouse1Prev
    Library_Data.Input.Mouse1Prev = Library_Data.Input.Mouse1Down
    Library_Data.Input.Mouse2Down = ismouse2pressed and ismouse2pressed() or false
    Library_Data.Input.Mouse2Clicked = Library_Data.Input.Mouse2Down and not Library_Data.Input.Mouse2Prev
    Library_Data.Input.Mouse2Prev = Library_Data.Input.Mouse2Down

    local Is_Shift_Down = (iskeypressed and (iskeypressed(160) or iskeypressed(161) or iskeypressed(16))) or false

    for Key_Code, Key_Name in pairs(Key_Codes) do
        local Is_Pressed = iskeypressed and iskeypressed(Key_Code) or false
        if Key_Code == 1 then
            Is_Pressed = Library_Data.Input.Mouse1Down
        elseif Key_Code == 2 then
            Is_Pressed = Library_Data.Input.Mouse2Down
        end

        if Is_Pressed and not Library_Data.Input.KeysDown[Key_Code] then
            Library_Data.Input.KeysDown[Key_Code] = true

            if Library_Data.State.ActiveKeybind then
                Config[Library_Data.State.ActiveKeybind.Flag] = Normalize_Keybind_Value(Key_Code == 27 and "None" or Key_Name)
                Library_Data.State.ActiveKeybind = nil
            elseif Library_Data.State.ActiveSliderInput then
                local Slider_Obj = Library_Data.State.ActiveSliderInput
                local Current_Text = tostring(Slider_Obj.InputBuffer or "")
                if Key_Code == 8 then
                    Slider_Obj.InputBuffer = string.sub(Current_Text, 1, -2)
                elseif Key_Code == 13 then
                    Commit_Slider_Input(Slider_Obj)
                    Library_Data.State.ActiveSliderInput = nil
                elseif Key_Code == 27 then
                    Slider_Obj.InputBuffer = Format_Slider_Value(Config[Slider_Obj.Flag], Slider_Obj.Step)
                    Library_Data.State.ActiveSliderInput = nil
                else
                    local Char_Val = Key_Name
                    if Key_Code >= 48 and Key_Code <= 57 then
                        Slider_Obj.InputBuffer = Current_Text .. Char_Val
                    elseif Key_Code >= 96 and Key_Code <= 105 then
                        Slider_Obj.InputBuffer = Current_Text .. tostring(Key_Code - 96)
                    elseif Key_Code == 109 then
                        if not string.find(Current_Text, "%-") then
                            Slider_Obj.InputBuffer = "-" .. Current_Text
                        end
                    elseif Key_Code == 189 then
                        if not string.find(Current_Text, "%-") then
                            Slider_Obj.InputBuffer = "-" .. Current_Text
                        end
                    elseif Key_Code == 110 or Key_Code == 190 then
                        if not string.find(Current_Text, "%.") then
                            Slider_Obj.InputBuffer = Current_Text .. "."
                        end
                    end
                end
            elseif Library_Data.State.ActiveTextbox then
                local Tbox_Obj = Library_Data.State.ActiveTextbox
                local Current_Text = tostring(Config[Tbox_Obj.Flag])
                if Key_Code == 8 then
                    Config[Tbox_Obj.Flag] = string.sub(Current_Text, 1, -2)
                elseif Key_Code == 13 or Key_Code == 27 then
                    Library_Data.State.ActiveTextbox = nil
                    Queue_Save_Config()
                elseif Key_Code == 32 then
                    Config[Tbox_Obj.Flag] = Current_Text .. " "
                else
                    local Char_Val = Key_Name
                    if Key_Code >= 65 and Key_Code <= 90 then
                        Config[Tbox_Obj.Flag] = Current_Text .. (Is_Shift_Down and Char_Val or string.lower(Char_Val))
                    elseif Key_Code >= 48 and Key_Code <= 57 then
                        Config[Tbox_Obj.Flag] = Current_Text .. (Is_Shift_Down and (Shift_Modifiers[Char_Val] or Char_Val) or Char_Val)
                    end
                end
            else
                if Key_Name == Normalize_Keybind_Value(Config.HideKeybind) then
                    if not Library_Data.BindPressed then
                        Library_Data.Visible = not Library_Data.Visible
                        Library_Data.BindPressed = true
                        if not Library_Data.Visible then
                            Close_Transient_Ui()
                            Hide_Window_Drawings()
                            if not Config.ShowHotkeyList then
                                Hide_Hotkeys_Drawings()
                            end
                        end
                    end
                elseif Key_Name == Normalize_Keybind_Value(Config.ParryKeybind) then
                    Handle_Bind_Press("ParryKeybind")
                elseif Key_Name == Normalize_Keybind_Value(Config.SpamKeybind) then
                    Handle_Bind_Press("SpamKeybind")
                elseif Key_Name == Normalize_Keybind_Value(Config.TriggerKeybind) then
                    Handle_Bind_Press("TriggerKeybind")
                end
            end
        elseif not Is_Pressed then
            Library_Data.Input.KeysDown[Key_Code] = false
            if Key_Name == Normalize_Keybind_Value(Config.HideKeybind) then
                Library_Data.BindPressed = false
            elseif Key_Name == Normalize_Keybind_Value(Config.ParryKeybind) then
                Handle_Bind_Release("ParryKeybind")
            elseif Key_Name == Normalize_Keybind_Value(Config.SpamKeybind) then
                Handle_Bind_Release("SpamKeybind")
            elseif Key_Name == Normalize_Keybind_Value(Config.TriggerKeybind) then
                Handle_Bind_Release("TriggerKeybind")
            end
        end
    end

    Apply_Held_Backspace()

    local Hotkeys_Size = Vector2.new(220, 120)
    local Should_Show_Hotkeys = Config.ShowHotkeyList

    if not Library_Data.Visible then
        Close_Transient_Ui()
        for _, Tab_Obj in ipairs(Library_Data.Tabs) do
            Hide_Tab_Content(Tab_Obj)
        end
        Hide_Window_Drawings()
        if not Should_Show_Hotkeys then
            Hide_Hotkeys_Drawings()
        end
    end

    local Hotkey_Entries = {
        {BindFlag = "ParryKeybind", ToggleFlag = "AutoParry", Label = "Parry"},
        {BindFlag = "SpamKeybind", ToggleFlag = "AutoSpam", Label = "Spam"},
        {BindFlag = "TriggerKeybind", ToggleFlag = "TriggerBot", Label = "Trigger"}
    }

    local Stats_Size = Vector_2_Round(276, 166)
    local Accent_Color = Library_Data.Palette.Accent

    if Should_Show_Hotkeys then
        Library_Data.HotkeysPosition = Clamp_Window_Position(Library_Data.HotkeysPosition, Hotkeys_Size)

        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Library_Data.HotkeysPosition, Vector2.new(Hotkeys_Size.X, 28)) then
            Library_Data.State.HotkeysDragging = true
            Library_Data.State.HotkeysDragStart = Library_Data.Input.MousePos
            Library_Data.State.HotkeysWindowStart = Library_Data.HotkeysPosition
            Close_Transient_Ui()
        end

        if Library_Data.Input.Mouse1Released then
            Library_Data.State.HotkeysDragging = false
        end

        if Library_Data.State.HotkeysDragging then
            Library_Data.HotkeysPosition = Clamp_Window_Position(Library_Data.State.HotkeysWindowStart + (Library_Data.Input.MousePos - Library_Data.State.HotkeysDragStart), Hotkeys_Size)
        end

        local Binds_Size = Vector_2_Round(Hotkeys_Size.X, Hotkeys_Size.Y)
        local Binds_Pos = Clamp_Window_Position(Vector_2_Round(Library_Data.HotkeysPosition.X, Library_Data.HotkeysPosition.Y), Binds_Size)
        Library_Data.HotkeysPosition = Binds_Pos

        Update_Rounded_Box(Keybinds_Drawings.Outline, Binds_Pos, Binds_Size, 8, Library_Data.Palette.Outline, 1, true)
        Update_Rounded_Box(Keybinds_Drawings.Background, Vector_2_Round(Binds_Pos.X + 1, Binds_Pos.Y + 1), Vector_2_Round(Binds_Size.X - 2, Binds_Size.Y - 2), 8, Library_Data.Palette.Background, 1, true)
        Update_Gradient_Line(Keybinds_Drawings.Topline, Vector_2_Round(Binds_Pos.X + 1, Binds_Pos.Y + 1), Vector_2_Round(Binds_Size.X - 2, 2), Library_Data.Palette.Accent, Library_Data.Palette.Accent2, true)
        Keybinds_Drawings.HeaderLine.Visible = true
        Keybinds_Drawings.HeaderLine.Position = Vector_2_Round(Binds_Pos.X + 8, Binds_Pos.Y + 30)
        Keybinds_Drawings.HeaderLine.Size = Vector_2_Round(Binds_Size.X - 16, 1)
        Keybinds_Drawings.HeaderLine.Color = Library_Data.Palette.Outline
        Update_Keybind_Image_Icon(Keybinds_Drawings.TitleIcon, Vector_2_Round(Binds_Pos.X + 8, Binds_Pos.Y + 6), Accent_Color, false)
        Keybinds_Drawings.Title.Visible = true
        Keybinds_Drawings.Title.Position = Vector_2_Round(Binds_Pos.X + 8, Binds_Pos.Y + 6)
        Keybinds_Drawings.Subtitle.Visible = false

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

        if Library_Data.Input.Mouse2Clicked and Library_Data.State.HotkeysContext.Open then
            local Menu_Pos = Library_Data.State.HotkeysContext.Position
            if not Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Menu_Pos, Vector2.new(112, 56)) then
                Library_Data.State.HotkeysContext.Open = false
                Library_Data.State.HotkeysContext.Entry = nil
            end
        end

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
            Bind_Draw.Position = Vector_2_Round(Row_Val.X + 8, Row_Val.Y + 3)

            local State_Column_W = 30
            local Mode_Column_W = 48
            local State_Text_X = Row_Val.X + Row_Val.W - State_Column_W - 6
            local Mode_Text_X = State_Text_X - Mode_Column_W - 6

            State_Draw.Visible = true
            State_Draw.Text = Is_Enabled and "ON" or "OFF"
            State_Draw.Color = Is_Enabled and Library_Data.Palette.Text or Library_Data.Palette.SubText
            State_Draw.Position = Vector_2_Round(State_Text_X, Row_Val.Y + 3)

            Mode_Draw.Visible = true
            Mode_Draw.Text = string.upper(Bind_Mode)
            Mode_Draw.Color = Bind_Mode == "Hold" and Library_Data.Palette.Accent2 or Library_Data.Palette.Accent
            Mode_Draw.Position = Vector_2_Round(Mode_Text_X, Row_Val.Y + 3)

        end
    else
        Hide_Hotkeys_Drawings()
        Library_Data.State.HotkeysDragging = false
        Library_Data.State.HotkeysContext.Open = false
        Library_Data.State.HotkeysContext.Entry = nil
    end

    local Show_Stats = Config.RenderBallStats
    
    local Player_Character = Local_Player.Character
    local Is_Dead = false
    if Workspace_Service:FindFirstChild("Dead") and Player_Character and Player_Character.Parent == Workspace_Service.Dead then
        Is_Dead = true
    end
    if Player_Character and Player_Character:FindFirstChild("SingularityCape") then
        Is_Dead = true
    end
    if Player_Character and Player_Character.PrimaryPart and Player_Character.PrimaryPart:FindFirstChild("SingularityCape") then
        Is_Dead = true
    end

    if Is_Dead then
        Show_Stats = false
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

        if Library_Data.Input.Mouse1Released then
            Library_Data.State.StatsDragging = false
        end

        if Library_Data.State.StatsDragging then
            Library_Data.StatsPosition = Clamp_Window_Position(Library_Data.State.StatsWindowStart + (Library_Data.Input.MousePos - Library_Data.State.StatsDragStart), Stats_Size)
            Stats_Pos = Vector_2_Round(Library_Data.StatsPosition.X, Library_Data.StatsPosition.Y)
        end
    else
        Library_Data.State.StatsDragging = false
    end

    Update_Rounded_Box(Stats_Drawings.Outline, Stats_Pos, Stats_Size, 8, Library_Data.Palette.Outline, 1, Show_Stats)
    Update_Rounded_Box(Stats_Drawings.Background, Vector_2_Round(Stats_Pos.X + 1, Stats_Pos.Y + 1), Vector_2_Round(Stats_Size.X - 2, Stats_Size.Y - 2), 8, Library_Data.Palette.Background, 1, Show_Stats)
    Update_Gradient_Line(Stats_Drawings.Topline, Vector_2_Round(Stats_Pos.X + 1, Stats_Pos.Y + 1), Vector_2_Round(Stats_Size.X - 2, 2), Library_Data.Palette.Accent, Library_Data.Palette.Accent2, Show_Stats)
    Stats_Drawings.HeaderLine.Visible = Show_Stats
    Stats_Drawings.Title.Visible = Show_Stats
    Stats_Drawings.Speed.Visible = Show_Stats
    Stats_Drawings.Distance.Visible = Show_Stats
    Stats_Drawings.Dot.Visible = Show_Stats

    if Show_Stats then
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

        Stats_Drawings.Title.Position = Vector_2_Round(Stats_Pos.X + 12, Stats_Pos.Y + 8)
        Stats_Drawings.Title.Text = "BALL STATS"

        Stats_Drawings.Speed.Position = Vector_2_Round(Stats_Pos.X + 20, Row_1_Y + 8)
        Stats_Drawings.Speed.Text = "Ball Speed : " .. tostring(Speed_Value)
        Stats_Drawings.Speed.Color = Library_Data.Palette.Text

        Stats_Drawings.Distance.Position = Vector_2_Round(Stats_Pos.X + 20, Row_2_Y + 8)
        Stats_Drawings.Distance.Text = "Ball Dist  : " .. tostring(Distance_Value)
        Stats_Drawings.Distance.Color = Library_Data.Palette.Text

        Stats_Drawings.Dot.Position = Vector_2_Round(Stats_Pos.X + 20, Row_3_Y + 8)
        Stats_Drawings.Dot.Text = "Ball Dot   : " .. string.format("%.2f", Dot_Value)
        Stats_Drawings.Dot.Color = Library_Data.Palette.Text
    else
        Update_Rounded_Box(Stats_Drawings.Row1, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Stats_Drawings.Row2, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Stats_Drawings.Row3, Vector_2_Round(0, 0), Vector_2_Round(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end

    if Save_Config_Queued and not Is_Config_Loading and not Library_Data.State.ActiveDropdown and not Library_Data.State.ActiveColorDrag and not Library_Data.State.ActiveSlider and not Library_Data.State.ActiveSliderInput and not Library_Data.State.ActiveTextbox and not Library_Data.State.ActiveKeybind then
        Save_Global_Settings()
        if Config.AutoSave then
            Save_Current_Config()
        else
            Save_Config_Queued = false
        end
    end

    if not Library_Data.Visible then
        return
    end

    local Size_X, Size_Y = Library_Data.Size.X, Library_Data.Size.Y

    if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Library_Data.Position, Vector2.new(Size_X, 36)) then
        Library_Data.State.Dragging = true
        Library_Data.State.DragStart = Library_Data.Input.MousePos
        Library_Data.State.WindowStart = Library_Data.TargetPosition
        Close_Transient_Ui()
    end

    if Library_Data.Input.Mouse1Released then
        Library_Data.State.Dragging = false
        Library_Data.State.ActiveSlider = nil
    end

    if Library_Data.State.Dragging then
        Library_Data.TargetPosition = Library_Data.State.WindowStart + (Library_Data.Input.MousePos - Library_Data.State.DragStart)
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
    Window_Drawings.Title.Position = Vector_2_Round(Pos_X + 15, Pos_Y + 11)

    if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Vector2.new(Pos_X, Pos_Y + 37), Vector2.new(150, Size_Y - 37)) then
        local Y_Offset = Pos_Y + 42
        for _, Tab_Obj in ipairs(Library_Data.Tabs) do
            if Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Vector2.new(Pos_X + 5, Y_Offset), Vector2.new(140, 32)) then
                Library_Data.CurrentTab = Tab_Obj
                Close_Transient_Ui()
                for _, T_Obj in ipairs(Library_Data.Tabs) do
                    Hide_Tab_Content(T_Obj)
                end
            end
            Y_Offset = Y_Offset + 36
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

        Update_Rounded_Box(Overlay_Menu_Drawings.Outline, Menu_Pos, Menu_Size, 6, Library_Data.Palette.Outline, 1, true)
        Update_Rounded_Box(Overlay_Menu_Drawings.Background, Vector_2_Round(Menu_Pos.X + 1, Menu_Pos.Y + 1), Vector_2_Round(Menu_Size.X - 2, Menu_Size.Y - 2), 6, Library_Data.Palette.Background, 1, true)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option1, Hold_Pos, Option_Size, 5, Hold_Selected and Library_Data.Palette.Accent or (Hold_Hovered and Library_Data.Palette.Hover or Library_Data.Palette.Element), 1, true)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option2, Toggle_Pos, Option_Size, 5, Toggle_Selected and Library_Data.Palette.Accent or (Toggle_Hovered and Library_Data.Palette.Hover or Library_Data.Palette.Element), 1, true)

        Overlay_Menu_Drawings.Option1Text.Visible = true
        Overlay_Menu_Drawings.Option1Text.Text = "Hold"
        Overlay_Menu_Drawings.Option1Text.Color = Hold_Selected and Library_Data.Palette.Text or (Hold_Hovered and Library_Data.Palette.Text or Library_Data.Palette.SubText)
        Overlay_Menu_Drawings.Option1Text.Position = Vector_2_Round(Hold_Pos.X + 42, Hold_Pos.Y + 5)

        Overlay_Menu_Drawings.Option2Text.Visible = true
        Overlay_Menu_Drawings.Option2Text.Text = "Toggle"
        Overlay_Menu_Drawings.Option2Text.Color = Toggle_Selected and Library_Data.Palette.Text or (Toggle_Hovered and Library_Data.Palette.Text or Library_Data.Palette.SubText)
        Overlay_Menu_Drawings.Option2Text.Position = Vector_2_Round(Toggle_Pos.X + 34, Toggle_Pos.Y + 5)
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
                            Clicked_Dropdown = Candidate_Obj
                            break
                        end
                    end
                    if Clicked_Dropdown then
                        break
                    end
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
                            Picked_Option = Index_Val
                            break
                        end
                    end

                    if Picked_Option and Dropdown_Obj.Options[Picked_Option] ~= nil then
                        Config[Dropdown_Obj.Flag] = Dropdown_Obj.Options[Picked_Option]
                        if Dropdown_Obj.Flag == "ThemePreset" then
                            Apply_Theme_Preset(Config[Dropdown_Obj.Flag], false)
                            Queue_Save_Config()
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
            if Library_Data.Input.Mouse1Clicked and not Library_Data.State.ActiveColorDrag then
                local Inside_Button = Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Picker_Obj.ButtonPos, Picker_Obj.ButtonSize)
                local Inside_Popup = Picker_Obj.IsOpen and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Picker_Obj.PopupPos, Picker_Obj.PopupSize)
                if not Inside_Button and not Inside_Popup then
                    Picker_Obj.IsOpen = false
                    Library_Data.State.ActiveColorPicker = nil
                end
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
                            if Library_Data.State.ActiveSliderInput then
                                Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                                Library_Data.State.ActiveSliderInput = nil
                            end
                            Config[Item_Obj.Flag] = not Config[Item_Obj.Flag]
                            Queue_Save_Config()
                        end
                    elseif Item_Obj.Type == "Slider" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ValuePos, Item_Obj.ValueSize) then
                            if Library_Data.State.ActiveSliderInput and Library_Data.State.ActiveSliderInput ~= Item_Obj then
                                Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                            end
                            Library_Data.State.ActiveSliderInput = Item_Obj
                            Item_Obj.InputBuffer = Format_Slider_Value(Config[Item_Obj.Flag], Item_Obj.Step)
                            Library_Data.State.ActiveSlider = nil
                            Library_Data.State.ActiveTextbox = nil
                            Library_Data.State.ActiveKeybind = nil
                        elseif Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.BarPos - Vector2.new(0, 4), Item_Obj.BarSize + Vector2.new(0, 8)) then
                            if Library_Data.State.ActiveSliderInput then
                                Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                                Library_Data.State.ActiveSliderInput = nil
                            end
                            Library_Data.State.ActiveSlider = Item_Obj
                        end
                    elseif Item_Obj.Type == "Dropdown" then
                        if Library_Data.Input.Mouse1Clicked and not Library_Data.State.ActiveDropdown and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            if Library_Data.State.ActiveSliderInput then
                                Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                                Library_Data.State.ActiveSliderInput = nil
                            end
                            if Library_Data.State.ActiveColorPicker then
                                Library_Data.State.ActiveColorPicker.IsOpen = false
                                Library_Data.State.ActiveColorPicker = nil
                            end
                            Item_Obj.IsOpen = true
                            Item_Obj.OpenAlpha = 0
                            Item_Obj.ListHeight = 0
                            Item_Obj.TargetListHeight = 0
                            Library_Data.State.ActiveDropdown = Item_Obj
                            Block_Input = true
                        end
                    elseif Item_Obj.Type == "ColorPicker" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            if Library_Data.State.ActiveColorPicker and Library_Data.State.ActiveColorPicker ~= Item_Obj then
                                Library_Data.State.ActiveColorPicker.IsOpen = false
                            end
                            if Library_Data.State.ActiveSliderInput then
                                Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                                Library_Data.State.ActiveSliderInput = nil
                            end
                            Item_Obj.IsOpen = not Item_Obj.IsOpen
                            Library_Data.State.ActiveColorPicker = Item_Obj.IsOpen and Item_Obj or nil
                            Library_Data.State.ActiveKeybind = nil
                            Library_Data.State.ActiveTextbox = nil
                            Library_Data.State.ActiveDropdown = nil
                        elseif Item_Obj.IsOpen and Library_Data.Input.Mouse1Clicked then
                            if Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.SVPos, Item_Obj.SVSize) then
                                Library_Data.State.ActiveColorPicker = Item_Obj
                                Library_Data.State.ActiveColorDrag = "SV"
                            elseif Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.HuePos, Item_Obj.HueSize) then
                                Library_Data.State.ActiveColorPicker = Item_Obj
                                Library_Data.State.ActiveColorDrag = "Hue"
                            end
                        end
                    elseif Item_Obj.Type == "Keybind" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            Library_Data.State.ActiveKeybind = Item_Obj
                            if Library_Data.State.ActiveSliderInput then
                                Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                                Library_Data.State.ActiveSliderInput = nil
                            end
                            Library_Data.State.ActiveTextbox = nil
                            if Library_Data.State.ActiveColorPicker then
                                Library_Data.State.ActiveColorPicker.IsOpen = false
                                Library_Data.State.ActiveColorPicker = nil
                            end
                            Library_Data.State.HotkeysContext.Open = false
                            Library_Data.State.HotkeysContext.Entry = nil
                            Library_Data.State.KeybindContext.Open = false
                            Library_Data.State.KeybindContext.Entry = nil
                        elseif Library_Data.Input.Mouse2Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            Library_Data.State.ActiveKeybind = nil
                            if Library_Data.State.ActiveSliderInput then
                                Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                                Library_Data.State.ActiveSliderInput = nil
                            end
                            Library_Data.State.ActiveTextbox = nil
                            Library_Data.State.KeybindContext.Open = true
                            Library_Data.State.KeybindContext.Entry = {
                                BindFlag = Item_Obj.Flag,
                                Label = Item_Obj.Label and Item_Obj.Label.Text or "Bind",
                                Item = Item_Obj
                            }
                            local Context_Pos = Get_Context_Menu_Position(Item_Obj)
                            Library_Data.State.KeybindContext.Position = Vector2.new(Context_Pos.X, Context_Pos.Y)
                        end
                    elseif Item_Obj.Type == "Button" then
                        if Library_Data.Input.Mouse1Clicked and Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.ButtonPos, Item_Obj.ButtonSize) then
                            if Item_Obj.Callback then
                                Item_Obj.Callback()
                            end
                        end
                    elseif Item_Obj.Type == "Textbox" then
                        if Library_Data.Input.Mouse1Clicked then
                            if Is_Mouse_In_Bounds(Library_Data.Input.MousePos, Item_Obj.BoxPos, Item_Obj.BoxSize) then
                                Library_Data.State.ActiveTextbox = Item_Obj
                                Library_Data.State.ActiveKeybind = nil
                                if Library_Data.State.ActiveSliderInput then
                                    Commit_Slider_Input(Library_Data.State.ActiveSliderInput)
                                    Library_Data.State.ActiveSliderInput = nil
                                end
                                if Library_Data.State.ActiveColorPicker then
                                    Library_Data.State.ActiveColorPicker.IsOpen = false
                                    Library_Data.State.ActiveColorPicker = nil
                                end
                                Library_Data.State.KeybindContext.Open = false
                                Library_Data.State.KeybindContext.Entry = nil
                            elseif Library_Data.State.ActiveTextbox == Item_Obj then
                                Library_Data.State.ActiveTextbox = nil
                            end
                        end
                    end
                end
            end
        end
    end

    if not Library_Data.Input.Mouse1Down then
        Library_Data.State.ActiveColorDrag = nil
    end

    if Library_Data.State.ActiveColorPicker and Library_Data.State.ActiveColorDrag then
        local Picker_Obj = Library_Data.State.ActiveColorPicker
        if Library_Data.State.ActiveColorDrag == "SV" and Picker_Obj.SVPos and Picker_Obj.SVSize then
            Picker_Obj.Sat = Math_Clamp((Library_Data.Input.MousePos.X - Picker_Obj.SVPos.X) / Picker_Obj.SVSize.X, 0, 1)
            Picker_Obj.Val = 1 - Math_Clamp((Library_Data.Input.MousePos.Y - Picker_Obj.SVPos.Y) / Picker_Obj.SVSize.Y, 0, 1)
            Queue_Save_Config()
        elseif Library_Data.State.ActiveColorDrag == "Hue" and Picker_Obj.HuePos and Picker_Obj.HueSize then
            Picker_Obj.Hue = Math_Clamp((Library_Data.Input.MousePos.X - Picker_Obj.HuePos.X) / Picker_Obj.HueSize.X, 0, 1)
            Queue_Save_Config()
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

    local Tab_Y_Offset = Pos_Y + 42
    for _, Tab_Obj in ipairs(Library_Data.Tabs) do
        local Is_Current = Tab_Obj == Library_Data.CurrentTab
        local Tab_Pos = Vector_2_Round(Pos_X + 5, Tab_Y_Offset)
        local Tab_Size = Vector_2_Round(140, 32)

        Tab_Obj.BgAlpha = Math_Lerp(Tab_Obj.BgAlpha, Is_Current and 1 or 0, 0.18)
        Update_Rounded_Box(Tab_Obj.Background, Tab_Pos, Tab_Size, 4, Library_Data.Palette.Hover, 0.88 * Tab_Obj.BgAlpha, Is_Current or Tab_Obj.BgAlpha > 0.02)
        Update_Rounded_Box(Tab_Obj.Indicator, Vector_2_Round(Pos_X, Tab_Y_Offset + 8), Vector_2_Round(2, 16), 2, Library_Data.Palette.Accent, 1, Is_Current)

        Tab_Obj.CurrentColor = Color_Lerp(Tab_Obj.CurrentColor, Is_Current and Library_Data.Palette.Text or Library_Data.Palette.SubText, 0.15)
        Tab_Obj.CurrentIconColor = Color_Lerp(Tab_Obj.CurrentIconColor, Is_Current and Library_Data.Palette.Accent or Library_Data.Palette.SubText, 0.15)
        Tab_Obj.IconDraw.Visible = false
        Tab_Obj.Label.Visible = true
        Tab_Obj.Label.Position = Vector_2_Round(Pos_X + 17, Tab_Y_Offset + 8)

        Tab_Obj.Label.Color = Tab_Obj.CurrentColor
        Tab_Y_Offset = Tab_Y_Offset + 36

        if not Is_Current then
            Hide_Tab_Content(Tab_Obj)
        end

        if Is_Current then
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

                if Section_Obj.Side == "Left" then
                    Left_Y = Item_Y + 16
                else
                    Right_Y = Item_Y + 16
                end
            end
        else
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
                        for _, Option_Drawing in pairs(Item_Obj.OptionDrawings) do
                            Option_Drawing.Visible = false
                        end
                    end
                    if Item_Obj.PreviewStroke then Set_Visible(Item_Obj.PreviewStroke, false) end
                    if Item_Obj.Preview then Set_Visible(Item_Obj.Preview, false) end
                    if Item_Obj.PopupStroke then Set_Visible(Item_Obj.PopupStroke, false) end
                    if Item_Obj.PopupBackground then Set_Visible(Item_Obj.PopupBackground, false) end
                    if Item_Obj.SVStroke then Set_Visible(Item_Obj.SVStroke, false) end
                    if Item_Obj.HueStroke then Set_Visible(Item_Obj.HueStroke, false) end
                    if Item_Obj.AlphaStroke then Set_Visible(Item_Obj.AlphaStroke, false) end
                    if Item_Obj.SVGrid then Hide_Grid_Squares(Item_Obj.SVGrid) end
                    if Item_Obj.HueGrid then Hide_Grid_Squares(Item_Obj.HueGrid) end
                    if Item_Obj.AlphaGrid then Hide_Grid_Squares(Item_Obj.AlphaGrid) end
                    if Item_Obj.InfoHex then Item_Obj.InfoHex.Visible = false end
                    if Item_Obj.InfoRgb then Item_Obj.InfoRgb.Visible = false end
                    if Item_Obj.InfoAlpha then Item_Obj.InfoAlpha.Visible = false end
                    if Item_Obj.CursorOuter then Item_Obj.CursorOuter.Visible = false end
                    if Item_Obj.CursorInner then Item_Obj.CursorInner.Visible = false end
                    if Item_Obj.HueLine then Item_Obj.HueLine.Visible = false end
                    if Item_Obj.AlphaLine then Item_Obj.AlphaLine.Visible = false end
                end
            end
        end
    end
end)

local Is_Parried = false
local Trigger_Fired = false
local Accumulated_Spam_Time = 0
local Target_Changes = {}
local Last_Target = nil
local Parry_Accuracy = 100
local Parry_Range = 10
local Aero_Active = false
local Aero_Start_Time = 0
local Last_Speed = 0
local Last_Ball_Position = nil
local Last_Ball_Instance = nil
local Last_Distance = 9999
local Last_Velocity = nil

local Balls_Folder = Workspace_Service:WaitForChild("Balls", 9e9)

local function Get_Real_Ball()
    local Target_Folder = Balls_Folder

    if Config.TrainingBallsSupport then
        local Dead_Folder = Workspace_Service:FindFirstChild("Dead")
        if Dead_Folder and Dead_Folder:FindFirstChild(Local_Player.Name) then
            local Training_Balls_Folder = Workspace_Service:FindFirstChild("TrainingBalls")
            if Training_Balls_Folder then
                Target_Folder = Training_Balls_Folder
            end
        end
    end

    for _, Current_Ball in ipairs(Target_Folder:GetChildren()) do
        if typeof(Current_Ball) == "Instance" and Current_Ball:IsA("BasePart") and Current_Ball:GetAttribute("realBall") == true then
            return Current_Ball
        end
    end
    return nil
end

local function Get_Memory_Ping()
    local Success_State, Ping_Result = pcall(function() return memory_read("double", Stats_Service.Network.ServerStatsItem["Data Ping"].Address + 0xC8) end)
    return Success_State and Ping_Result or 50
end

local function Execute_Parry()
    if Config.ParryMethod == "Click" then
        if mouse1click then mouse1click() else mouse1press() mouse1release() end
    else
        if keypress and keyrelease then
            task.spawn(function()
                keypress(0x46)
                task.wait(0.01)
                keyrelease(0x46)
            end)
        end
    end
end

Run_Service.Heartbeat:Connect(function(Delta_Time)
    if not _G.MoonshadeActive then return end

    local Real_Ball = Get_Real_Ball()
    local Current_Time = os.clock()

    if not Real_Ball then
        Is_Parried = false
        Aero_Active = false
        Last_Speed = 0
        Last_Ball_Position = nil
        Last_Ball_Instance = nil
        Last_Distance = 9999
        Last_Velocity = nil
        Trigger_Fired = false
        Accumulated_Spam_Time = 0
        Runtime_State.Target_Speed = 0
        Runtime_State.Target_Distance = 0
        Runtime_State.Target_Dot = 0
        return
    end

    if Real_Ball ~= Last_Ball_Instance then
        Last_Ball_Position = nil
        Last_Ball_Instance = Real_Ball
        Last_Distance = 9999
        Last_Velocity = nil
    end

    local Current_Target = Real_Ball:GetAttribute("target")
    if Current_Target ~= Last_Target then
        if Current_Target ~= nil then
            table.insert(Target_Changes, Current_Time)
        end
        Last_Target = Current_Target
    end
    for Index = #Target_Changes, 1, -1 do
        if Current_Time - Target_Changes[Index] > 0.45 then
            table.remove(Target_Changes, Index)
        end
    end

    local Player_Character = Local_Player.Character
    if not Player_Character or not Player_Character.PrimaryPart then return end
    local Root_Part = Player_Character.PrimaryPart

    local Root_Position = Root_Part.Position
    local Ball_Position = Real_Ball.Position
    local Delta_Vector = Root_Position - Ball_Position
    local Current_Distance = Delta_Vector.Magnitude

    Runtime_State.Target_Distance = Current_Distance

    if Current_Distance == 0 then return end

    local Ball_Velocity_Vector = Real_Ball.AssemblyLinearVelocity
    local Current_Speed = Ball_Velocity_Vector.Magnitude

    Current_Speed = Last_Speed + (Current_Speed - Last_Speed) * 0.25
    Last_Speed = Current_Speed
    Runtime_State.Target_Speed = Current_Speed

    local To_Player = Vector3.new(Root_Position.X - Ball_Position.X, 0, Root_Position.Z - Ball_Position.Z)
    local Vel_Flat = Vector3.new(Ball_Velocity_Vector.X, 0, Ball_Velocity_Vector.Z)
    local Dir_To_Player_Mag = math.sqrt(To_Player.X^2 + To_Player.Y^2 + To_Player.Z^2)
    local Vel_Dir_Mag = math.sqrt(Vel_Flat.X^2 + Vel_Flat.Y^2 + Vel_Flat.Z^2)
    if Dir_To_Player_Mag > 0 and Vel_Dir_Mag > 0 then
        local Dir_X = To_Player.X / Dir_To_Player_Mag
        local Dir_Z = To_Player.Z / Dir_To_Player_Mag
        local Vel_X = Vel_Flat.X / Vel_Dir_Mag
        local Vel_Z = Vel_Flat.Z / Vel_Dir_Mag
        Runtime_State.Target_Dot = (Dir_X * Vel_X) + (Dir_Z * Vel_Z)
    else
        Runtime_State.Target_Dot = 0
    end

    if Player_Character:FindFirstChild("SingularityCape") or Root_Part:FindFirstChild("SingularityCape") then
        Is_Parried = false
        Trigger_Fired = false
        Accumulated_Spam_Time = 0
        return
    end

    if Current_Speed < 0.1 then
        Last_Ball_Position = Ball_Position
        return
    end

    local Aero_Visual_Effect = Real_Ball:FindFirstChild("AeroDynamicSlashVFX")
    local Is_Aero_Wait = false
    if Aero_Visual_Effect then
        if not Aero_Active then
            Aero_Active = true
            Aero_Start_Time = Current_Time
        end
        local Aero_Time_Diff = Current_Time - Aero_Start_Time
        if Aero_Time_Diff < 0.2 then
            Is_Aero_Wait = true
        elseif Ball_Velocity_Vector.Y > 10 then
            Is_Aero_Wait = true
        end
    else
        Aero_Active = false
    end

    if Is_Aero_Wait then
        Last_Ball_Position = Ball_Position
        Accumulated_Spam_Time = 0
        return
    end

    if Config.TriggerBot and Current_Target == Local_Player.Name and not Trigger_Fired then
        Trigger_Fired = true
        if Config.TriggerDelay > 0 then
            task.spawn(function()
                task.wait(Config.TriggerDelay / 1000)
                local Check_Ball = Get_Real_Ball()
                if Check_Ball and Check_Ball:GetAttribute("target") == Local_Player.Name then
                    Execute_Parry()
                end
            end)
        else
            Execute_Parry()
        end
    end

    local Network_Ping = Get_Memory_Ping()
    local Adjusted_Ping = Network_Ping / 10
    local Spam_Distance_Threshold = math.clamp((Current_Speed / 3) + Adjusted_Ping + 25, 40, 100)
    local Is_Player_Nearby = false

    for _, Player in ipairs(Players_Service:GetPlayers()) do
        if Player ~= Local_Player then
            local Char = Player.Character
            if Char and Char.PrimaryPart then
                if (Char.PrimaryPart.Position - Root_Position).Magnitude <= Spam_Distance_Threshold then
                    Is_Player_Nearby = true
                    break
                end
            end
        end
    end

    local Is_Ball_Nearby = Current_Distance <= Spam_Distance_Threshold
    if Config.AutoSpam and #Target_Changes >= 4 and Is_Player_Nearby and Is_Ball_Nearby then
        local Spam_Interval = 1 / (Config.SpamRate or 100)
        Accumulated_Spam_Time = Accumulated_Spam_Time + Delta_Time
        if Accumulated_Spam_Time >= Spam_Interval then
            local Click_Count = math.floor(Accumulated_Spam_Time / Spam_Interval)
            Accumulated_Spam_Time = Accumulated_Spam_Time - (Click_Count * Spam_Interval)
            for I_Idx = 1, math.min(Click_Count, 15) do Execute_Parry() end
        end
        Last_Ball_Position = Ball_Position
        return
    else
        Accumulated_Spam_Time = 0
    end

    if Current_Target ~= Local_Player.Name then
        Is_Parried = false
        Trigger_Fired = false
        Last_Ball_Position = Ball_Position
        Last_Distance = Current_Distance
        Last_Velocity = Ball_Velocity_Vector
        return
    end

    if Is_Parried then
        Last_Ball_Position = Ball_Position
        Last_Distance = Current_Distance
        Last_Velocity = Ball_Velocity_Vector
        return 
    end

    local Passed_Through_Close_Range = false
    if Last_Ball_Position then
        local Segment_Vector = Ball_Position - Last_Ball_Position
        local Segment_Length = Segment_Vector.Magnitude
        if Segment_Length > 0.01 then
            local Segment_Direction = Segment_Vector.Unit
            local Vector_To_Player = Root_Position - Last_Ball_Position
            local Projection_Length = math.clamp(Vector_To_Player:Dot(Segment_Direction), 0, Segment_Length)
            local Closest_Point_On_Segment = Last_Ball_Position + (Segment_Direction * Projection_Length)
            local Distance_To_Closest_Point = (Root_Position - Closest_Point_On_Segment).Magnitude
            if Distance_To_Closest_Point <= (Parry_Range * 0.85) then
                local To_Player_Dir = (Root_Position - Ball_Position).Unit
                local Velocity_Dir = Ball_Velocity_Vector.Unit
                if Velocity_Dir:Dot(To_Player_Dir) > -0.15 then
                    Passed_Through_Close_Range = true
                end
            end
        end
    end

    local Is_Moving_Away = false
    if Current_Distance > Last_Distance + 0.55 then
        Is_Moving_Away = true
    end

    local Speed_Difference = math.max(Current_Speed - 9.5, 0)
    local Speed_Divisor_Multiplier = 0.7 + (Parry_Accuracy - 1) * (0.35 / 99)
    local Final_Regular_Speed_Divisor = (2.4 + (Speed_Difference * 0.002)) * Speed_Divisor_Multiplier

    local Dynamic_Calculated_Distance = Adjusted_Ping + math.max(Current_Speed / Final_Regular_Speed_Divisor, 9.5)
    local Frame_Compensation = Current_Speed * Delta_Time
    local Final_Threshold = math.max(Dynamic_Calculated_Distance + Frame_Compensation, Parry_Range)

    local Can_Execute_Parry = (Current_Distance <= Final_Threshold) and not Is_Moving_Away

    if Config.AutoParry then
        if Can_Execute_Parry or Passed_Through_Close_Range then
            Is_Parried = true
            Execute_Parry()
        end
    end

    Last_Ball_Position = Ball_Position
    Last_Distance = Current_Distance
    Last_Velocity = Ball_Velocity_Vector
end)
