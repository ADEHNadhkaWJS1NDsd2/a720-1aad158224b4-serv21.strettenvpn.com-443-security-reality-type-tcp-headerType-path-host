--!native
--!strict
--!optimize 2
local Http_Service = game:Get_Service("Http_Service")
local Run_Service = game:Get_Service("Run_Service")
local Players = game:Get_Service("Players")
local Workspace = game:Get_Service("Workspace")
local Stats_Service = game:Get_Service("Stats")
local Local_Player = Players.Local_Player
local Mouse = Local_Player:Get_Mouse()
local Fast_Floor = math.floor
local Fast_Max = math.max
local Fast_Clamp = math.clamp
local Fast_Clock = os.clock
local Fast_Tick = tick

if _G.Moonshade_Drawings then
    for _, drawing in pairs(_G.Moonshade_Drawings) do
        pcall(function()
            drawing:Remove()
        end)
    end
end

_G.Moonshade_Drawings = {}
_G.Moonshade_Active = true

local Key_Codes = {
    [1] = "Lmb",[2] = "Rmb",[3] = "Mmb",[4] = "Mb4",[5] = "Mb5",
    [8] = "Backspace",[9] = "Tab",[13] = "Enter",[16] = "Shift",[17] = "Ctrl",[18] = "Alt",[20] = "Caps_Lock",[27] = "Esc",[32] = "Space",
    [33] = "Page_Up",[34] = "Page_Down",[35] = "End",[36] = "Home",[37] = "Left",[38] = "Up",[39] = "Right",[40] = "Down",[45] = "Insert",[46] = "Delete",
    [48] = "0",[49] = "1",[50] = "2",[51] = "3",[52] = "4",[53] = "5",[54] = "6",[55] = "7",[56] = "8",[57] = "9",
    [65] = "A",[66] = "B",[67] = "C",[68] = "D",[69] = "E",[70] = "F",[71] = "G",[72] = "H",[73] = "I",[74] = "J",[75] = "K",[76] = "L",
    [77] = "M",[78] = "N",[79] = "O",[80] = "P",[81] = "Q",[82] = "R",[83] = "S",[84] = "T",[85] = "U",[86] = "V",[87] = "W",[88] = "X",[89] = "Y",[90] = "Z",
    [96] = "Num0",[97] = "Num1",[98] = "Num2",[99] = "Num3",[100] = "Num4",[101] = "Num5",[102] = "Num6",[103] = "Num7",[104] = "Num8",[105] = "Num9",
    [106] = "Multiply",[107] = "Add",[109] = "Subtract",[110] = "Decimal",[111] = "Divide",
    [112] = "F1",[113] = "F2",[114] = "F3",[115] = "F4",[116] = "F5",[117] = "F6",[118] = "F7",[119] = "F8",[120] = "F9",[121] = "F10",[122] = "F11",[123] = "F12",
    [160] = "L_Shift",[161] = "R_Shift",[162] = "L_Ctrl",[163] = "R_Ctrl",[164] = "L_Alt",[165] = "R_Alt",[186] = ";",[187] = "=",[188] = ",",[189] = "-",[190] = ".",[191] = "/",[192] = "`",[219] = "[",[220] = "\\",[221] = "]",[222] = "'"
}

local Shift_Modifiers = {
    ["1"] = "!",["2"] = "@",["3"] = "#",["4"] = "$",["5"] = "%",["6"] = "^",["7"] = "&",["8"] = "*",["9"] = "(",["0"] = ")",
    ["-"] = "_",["="] = "+",["`"] = "~",["["] = "{",["]"] = "}",["\\"] = "|",[";"] = ":",["'"] = "\"",[","] = "<",["."] = ">",["/"] = "?"
}

local Config = {
    Auto_Parry = false,
    Auto_Spam = false,
    Spam_Sensitivity = 50,
    Lobby_Parry = false,
    Triggerbot_Enabled = false,
    No_Click_On_Ball_Spawn = true,
    Dot_Protect = true,
    Min_Threat_Speed = 5,
    Parry_Cooldown = 0,
    Ping_Multiplier = 1.0,
    Speed_Divisor_Base = 2.4,
    Speed_Divisor_Multiplier = 0.002,
    Capped_Speed = 9999,
    Speed_Division_Factor = 1.1,
    Ping_Sample_Count = 50,
    Dot_Min_Speed = 100.0,
    Dot_Threshold = 0.820,
    Dot_Distance_Threshold = 30.0,
    Base_Min_Parry_Accuracy = 25.0,
    Parry_Keybind = "None",
    Spam_Keybind = "None",
    Triggerbot_Keybind = "None",
    Hide_Keybind = "Esc",
    Parry_Method = "Click",
    Render_Ball_Stats = false,
    Parry_Bind_Mode = "Toggle",
    Spam_Bind_Mode = "Toggle",
    Triggerbot_Bind_Mode = "Toggle",
    Show_Hotkey_List = true,
    Auto_Save = true,
    Auto_Load = true,
    Theme_Preset = "Nightfall",
    Config_Name = "default",
    Selected_Config = "default",
    Save_Config_Action = false,
    Load_Config_Action = false
}

local Runtime_State = {
    Last_Parry = 0,
    Target = nil,
    Trajectory_Cache = {},
    Ping_History = {},
    Spam_Expiration = 0,
    Spam_Mode_Active = false,
    Consecutive_Parries = 0,
    Spam_Cooldown = 0,
    Scheduled_Trigger = 0,
    Aerodynamic_Active = false,
    Aerodynamic_Time = 0,
    Last_Ball_Spawn = 0,
    Target_Speed = 0,
    Target_Distance = 0,
    Target_Dot = 0
}

local function Clamp(v, a, b)
    return math.max(a, math.min(b, v))
end

local function Round(n)
    return math.floor(n + 0.5)
end

local function Vec2(x, y)
    return Vector2.new(Round(x), Round(y))
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function Lerp_Color(c1, c2, t)
    if not c1 or not c2 then
        return Color3.new(1, 1, 1)
    end
    return Color3.new(Lerp(c1.R, c2.R, t), Lerp(c1.G, c2.G, t), Lerp(c1.B, c2.B, t))
end

local function Snap_Value(val, step)
    return step and math.floor((val / step) + 0.5) * step or val
end

local function Hsv_To_Color3(h, s, v)
    h = ((h or 0) % 1 + 1) % 1
    s = Clamp(s or 0, 0, 1)
    v = Clamp(v or 0, 0, 1)

    local c = v * s
    local hp = h * 6
    local x = c * (1 - math.abs((hp % 2) - 1))
    local r1, g1, b1 = 0, 0, 0

    if hp >= 0 and hp < 1 then
        r1, g1, b1 = c, x, 0
    elseif hp >= 1 and hp < 2 then
        r1, g1, b1 = x, c, 0
    elseif hp >= 2 and hp < 3 then
        r1, g1, b1 = 0, c, x
    elseif hp >= 3 and hp < 4 then
        r1, g1, b1 = 0, x, c
    elseif hp >= 4 and hp < 5 then
        r1, g1, b1 = x, 0, c
    else
        r1, g1, b1 = c, 0, x
    end

    local m = v - c
    return Color3.new(r1 + m, g1 + m, b1 + m)
end

local function Color3_To_Hsv(color)
    if not color then
        return 0, 0, 1
    end
    local ok, h, s, v = pcall(function()
        return color:To_Hsv()
    end)
    if ok then
        return h, s, v
    end
    local r, g, b = color.R, color.G, color.B
    local maxc = math.max(r, g, b)
    local minc = math.min(r, g, b)
    local delta = maxc - minc
    local h2 = 0
    if delta > 0 then
        if maxc == r then
            h2 = ((g - b) / delta) % 6
        elseif maxc == g then
            h2 = ((b - r) / delta) + 2
        else
            h2 = ((r - g) / delta) + 4
        end
        h2 = h2 / 6
    end
    local s2 = maxc == 0 and 0 or (delta / maxc)
    return h2, s2, maxc
end

local function Color3_To_Hex(color)
    if not color then
        return "#Ffffff"
    end
    return string.format("#%02X%02X%02X", Clamp(Round(color.R * 255), 0, 255), Clamp(Round(color.G * 255), 0, 255), Clamp(Round(color.B * 255), 0, 255))
end

local Create_Drawing

local function Create_Grid_Squares(count)
    local grid = {}
    for i = 1, count do
        grid[i] = Create_Drawing("Square", {Filled = true, Transparency = 1, Visible = false})
    end
    return grid
end

local function Update_Grid_Squares(grid, cols, rows, x, y, w, h, Color_Func, visible)
    if not visible or w <= 0 or h <= 0 then
        for _, sq in ipairs(grid) do
            sq.Visible = false
        end
        return
    end
    local Cell_W = w / cols
    local Cell_H = h / rows
    local idx = 1
    for row = 1, rows do
        for col = 1, cols do
            local sq = grid[idx]
            idx = idx + 1
            local x0 = x + ((col - 1) * Cell_W)
            local y0 = y + ((row - 1) * Cell_H)
            local x1 = x + (col * Cell_W)
            local y1 = y + (row * Cell_H)
            sq.Visible = true
            sq.Position = Vec2(x0, y0)
            sq.Size = Vec2(math.max(1, Round(x1 - x0)), math.max(1, Round(y1 - y0)))
            sq.Color = Color_Func(col, row, cols, rows)
            sq.Transparency = 1
        end
    end
end

local function Hide_Grid_Squares(grid)
    for _, sq in ipairs(grid) do
        sq.Visible = false
    end
end

local function Get_Step_Decimals(step)
    if type(step) ~= "number" then
        return 0
    end
    local s = string.format("%.10f", step):gsub("0+$", "")
    local dot = s:find("%.")
    return dot and (#s - dot) or 0
end

local function Format_Slider_Value(value, step)
    if type(value) ~= "number" then
        return tostring(value)
    end
    local decimals = Get_Step_Decimals(step)
    if decimals <= 0 then
        return tostring(math.floor(value + 0.5))
    end
    local formatted = string.format("%." .. decimals .. "f", value)
    formatted = formatted:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    return formatted
end

local function Parse_Slider_Input(Text_Value)
    local cleaned = tostring(Text_Value or ""):gsub(",", "."):gsub("[^%d%.%-]", "")
    if cleaned == "" or cleaned == "-" or cleaned == "." or cleaned == "-." then
        return nil
    end
    local number = tonumber(cleaned)
    if number == nil then
        return nil
    end
    return number
end

local function Clamp_Slider_Value(value, min, max, step)
    local clamped = Clamp(value, min, max)
    local snapped = Snap_Value(clamped, step)
    return Clamp(snapped, min, max)
end

local function Commit_Slider_Input(slider)
    if not slider then
        return
    end
    local parsed = Parse_Slider_Input(slider.Input_Buffer)
    if parsed == nil then
        slider.Input_Buffer = Format_Slider_Value(Config[slider.Flag], slider.Step)
        return
    end
    local Final_Value = Clamp_Slider_Value(parsed, slider.Min, slider.Max, slider.Step)
    Config[slider.Flag] = Final_Value
    slider.Input_Buffer = Format_Slider_Value(Final_Value, slider.Step)
    Queue_Save_Config()
end

local function Normalize_Keybind_Value(value)
    if type(value) == "number" then
        return Key_Codes[value] or tostring(value)
    end
    if value == nil or value == "" then
        return "None"
    end
    return tostring(value)
end

local function Normalize_Bind_Mode(mode)
    mode = tostring(mode or "Toggle")
    if string.lower(mode) == "hold" then
        return "Hold"
    end
    return "Toggle"
end

local function Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    if Bind_Flag == "Parry_Keybind" then
        return "Parry_Bind_Mode"
    elseif Bind_Flag == "Spam_Keybind" then
        return "Spam_Bind_Mode"
    elseif Bind_Flag == "Triggerbot_Keybind" then
        return "Triggerbot_Bind_Mode"
    end
end

local function Get_Toggle_Flag_From_Bind_Flag(Bind_Flag)
    if Bind_Flag == "Parry_Keybind" then
        return "Auto_Parry"
    elseif Bind_Flag == "Spam_Keybind" then
        return "Auto_Spam"
    elseif Bind_Flag == "Triggerbot_Keybind" then
        return "Triggerbot_Enabled"
    end
end

local function Set_Bind_Mode(Bind_Flag, mode)
    local Mode_Flag = Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    if Mode_Flag then
        Config[Mode_Flag] = Normalize_Bind_Mode(mode)
    end
end

local function Get_Bind_Mode(Bind_Flag)
    local Mode_Flag = Get_Mode_Flag_From_Bind_Flag(Bind_Flag)
    return Normalize_Bind_Mode(Mode_Flag and Config[Mode_Flag] or "Toggle")
end

local function Set_Bind_Target_State(Bind_Flag, state)
    local Toggle_Flag = Get_Toggle_Flag_From_Bind_Flag(Bind_Flag)
    if Toggle_Flag then
        Config[Toggle_Flag] = state and true or false
    end
end

local function Handle_Bind_Press(Bind_Flag)
    if Normalize_Keybind_Value(Config[Bind_Flag]) == "None" then
        return
    end
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
    if Normalize_Keybind_Value(Config[Bind_Flag]) == "None" then
        return
    end
    if Get_Bind_Mode(Bind_Flag) == "Hold" then
        Set_Bind_Target_State(Bind_Flag, false)
    end
end

local function Is_Mouse_In_Bounds(pos, Bounds_Pos, Bounds_Size)
    return pos.X >= Bounds_Pos.X and pos.X <= Bounds_Pos.X + Bounds_Size.X and pos.Y >= Bounds_Pos.Y and pos.Y <= Bounds_Pos.Y + Bounds_Size.Y
end

Create_Drawing = function(Class_Name, properties)
    local drawing = Drawing.new(Class_Name)
    for Prop_Name, Prop_Value in pairs(properties) do
        pcall(function()
            drawing[Prop_Name] = Prop_Value
        end)
    end
    table.insert(_G.Moonshade_Drawings, drawing)
    return drawing
end

local function Create_Keybind_Image_Icon(size)
    size = size or 18
    local function square()
        return Create_Drawing("Square", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, Visible = false})
    end
    local function circle()
        return Create_Drawing("Circle", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, Num_Sides = 18, Radius = 1, Visible = false})
    end

    return {
        Is_Image = false,
        Size = size,
        Parts = {
            Main = square(),
            Top = square(),
            Bottom = square(),
            Left = square(),
            Right = square(),
            Tl = circle(),
            Tr = circle(),
            Bl = circle(),
            Br = circle(),
            Inner = square(),
            Dot1 = circle(),
            Dot2 = circle(),
            Dot3 = circle(),
            Keys = {square(), square(), square(), square(), square(), square()}
        }
    }
end

local function Update_Keybind_Image_Icon(icon, position, color, visible)
    if not icon then
        return
    end
    if icon.Is_Image and icon.Image then
        local image = icon.Image
        image.Visible = visible
        pcall(function()
            image.Position = position
        end)
        pcall(function()
            image.Size = Vec2(icon.Size, icon.Size)
        end)
        pcall(function()
            image.Color = color
        end)
        pcall(function()
            image.Transparency = visible and 1 or 0
        end)
        return
    end
    if not icon.Parts then
        if icon.Fallback then
            icon.Fallback.Visible = visible
            if visible then
                icon.Fallback.Position = position
                icon.Fallback.Color = color
            end
        end
        return
    end

    local size = icon.Size or 18
    local width = math.max(12, math.floor(size * 0.9 + 0.5))
    local height = math.max(10, math.floor(size * 0.72 + 0.5))
    local radius = math.max(2, math.floor(size * 0.15 + 0.5))
    local stroke = math.max(1, math.floor(size * 0.07 + 0.5))
    local x = math.floor(position.X + 0.5)
    local y = math.floor(position.Y + 0.5)
    local w, h = width, height

    local parts = icon.Parts
    local outline = {parts.Main, parts.Top, parts.Bottom, parts.Left, parts.Right, parts.Tl, parts.Tr, parts.Bl, parts.Br}
    for _, obj in ipairs(outline) do
        obj.Visible = visible
        if visible then
            obj.Color = color
            obj.Transparency = 1
        end
    end

    if visible then
        parts.Main.Position = Vec2(x + radius, y + radius)
        parts.Main.Size = Vec2(math.max(w - radius * 2, 0), math.max(h - radius * 2, 0))
        parts.Top.Position = Vec2(x + radius, y)
        parts.Top.Size = Vec2(math.max(w - radius * 2, 0), radius)
        parts.Bottom.Position = Vec2(x + radius, y + h - radius)
        parts.Bottom.Size = Vec2(math.max(w - radius * 2, 0), radius)
        parts.Left.Position = Vec2(x, y + radius)
        parts.Left.Size = Vec2(radius, math.max(h - radius * 2, 0))
        parts.Right.Position = Vec2(x + w - radius, y + radius)
        parts.Right.Size = Vec2(radius, math.max(h - radius * 2, 0))

        parts.Tl.Position = Vec2(x + radius, y + radius)
        parts.Tr.Position = Vec2(x + w - radius, y + radius)
        parts.Bl.Position = Vec2(x + radius, y + h - radius)
        parts.Br.Position = Vec2(x + w - radius, y + h - radius)
        parts.Tl.Radius = radius
        parts.Tr.Radius = radius
        parts.Bl.Radius = radius
        parts.Br.Radius = radius
    end

    local Inner_Pad = stroke + 1
    parts.Inner.Visible = visible
    if visible then
        parts.Inner.Position = Vec2(x + Inner_Pad, y + Inner_Pad)
        parts.Inner.Size = Vec2(math.max(w - Inner_Pad * 2, 1), math.max(h - Inner_Pad * 2, 1))
        parts.Inner.Color = Color3.From_Rgb(16, 20, 30)
        parts.Inner.Transparency = 1
    end

    local Dot_Radius = math.max(1, math.floor(size * 0.05 + 0.5))
    local Dot_Gap = math.max(3, math.floor(size * 0.13 + 0.5))
    local Dot_Start_X = x + Inner_Pad + Dot_Radius + 1
    local Dot_Y = y + Inner_Pad + Dot_Radius + 1
    local dots = {parts.Dot1, parts.Dot2, parts.Dot3}
    for i, dot in ipairs(dots) do
        dot.Visible = visible
        if visible then
            dot.Position = Vec2(Dot_Start_X + (i - 1) * Dot_Gap, Dot_Y)
            dot.Radius = Dot_Radius
            dot.Color = color
            dot.Transparency = 1
        end
    end

    local Key_Pad_X = math.max(3, math.floor(size * 0.14 + 0.5))
    local Key_Pad_Y = math.max(5, math.floor(size * 0.24 + 0.5))
    local Key_Gap = math.max(1, math.floor(size * 0.06 + 0.5))
    local Available_W = math.max(w - Key_Pad_X * 2, 6)
    local Available_H = math.max(h - Key_Pad_Y - Inner_Pad - 1, 4)
    local Key_Size = math.max(2, math.floor(math.min((Available_W - Key_Gap * 2) / 3, (Available_H - Key_Gap) / 2) + 0.5))
    local Total_Keys_Width = Key_Size * 3 + Key_Gap * 2
    local Total_Keys_Height = Key_Size * 2 + Key_Gap
    local Keys_Start_X = x + math.floor((w - Total_Keys_Width) / 2 + 0.5)
    local Keys_Start_Y = y + h - Inner_Pad - Total_Keys_Height - 1

    for i, key in ipairs(parts.Keys) do
        key.Visible = visible
        if visible then
            local row = math.floor((i - 1) / 3)
            local col = (i - 1) % 3
            key.Position = Vec2(Keys_Start_X + col * (Key_Size + Key_Gap), Keys_Start_Y + row * (Key_Size + Key_Gap))
            key.Size = Vec2(Key_Size, Key_Size)
            key.Color = color
            key.Transparency = 1
        end
    end
end

local function Set_Visible(item, visible)
    if not item then
        return
    end
    if item.Main then
        item.Main.Visible = visible
        item.Top.Visible = visible
        item.Bottom.Visible = visible
        item.Left.Visible = visible
        item.Right.Visible = visible
        item.Tl.Visible = visible
        item.Tr.Visible = visible
        item.Bl.Visible = visible
        item.Br.Visible = visible
    elseif item.Is_Image or item.Fallback or item.Image then
        Update_Keybind_Image_Icon(item, Vec2(-1000, -1000), Color3.new(1, 1, 1), visible)
    else
        item.Visible = visible
    end
end

local function Set_Rounded_Color(box, color, transparency)
    local list = {box.Main, box.Top, box.Bottom, box.Left, box.Right, box.Tl, box.Tr, box.Bl, box.Br}
    for _, obj in ipairs(list) do
        obj.Color = color
        obj.Transparency = transparency or 1
    end
end

local function Make_Rounded_Box(color, transparency)
    return {
        Main = Create_Drawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Top = Create_Drawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Bottom = Create_Drawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Left = Create_Drawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Right = Create_Drawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Tl = Create_Drawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, Num_Sides = 18, Radius = 4, Visible = false}),
        Tr = Create_Drawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, Num_Sides = 18, Radius = 4, Visible = false}),
        Bl = Create_Drawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, Num_Sides = 18, Radius = 4, Visible = false}),
        Br = Create_Drawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, Num_Sides = 18, Radius = 4, Visible = false})
    }
end

local function Update_Rounded_Box(box, pos, size, radius, color, transparency, visible)
    radius = Clamp(radius or 4, 0, math.floor(math.min(size.X, size.Y) / 2))
    local x, y = pos.X, pos.Y
    local w, h = size.X, size.Y

    Set_Rounded_Color(box, color, transparency or 1)
    Set_Visible(box, visible)

    box.Main.Position = Vec2(x + radius, y + radius)
    box.Main.Size = Vec2(math.max(w - radius * 2, 0), math.max(h - radius * 2, 0))
    box.Top.Position = Vec2(x + radius, y)
    box.Top.Size = Vec2(math.max(w - radius * 2, 0), radius)
    box.Bottom.Position = Vec2(x + radius, y + h - radius)
    box.Bottom.Size = Vec2(math.max(w - radius * 2, 0), radius)
    box.Left.Position = Vec2(x, y + radius)
    box.Left.Size = Vec2(radius, math.max(h - radius * 2, 0))
    box.Right.Position = Vec2(x + w - radius, y + radius)
    box.Right.Size = Vec2(radius, math.max(h - radius * 2, 0))

    box.Tl.Position = Vec2(x + radius, y + radius)
    box.Tr.Position = Vec2(x + w - radius, y + radius)
    box.Bl.Position = Vec2(x + radius, y + h - radius)
    box.Br.Position = Vec2(x + w - radius, y + h - radius)
    box.Tl.Radius = radius
    box.Tr.Radius = radius
    box.Bl.Radius = radius
    box.Br.Radius = radius
end

local function Make_Gradient_Line(count)
    local items = {}
    for i = 1, count do
        items[i] = Create_Drawing("Square", {Filled = true, Visible = false})
    end
    return items
end

local function Update_Gradient_Line(items, pos, size, c1, c2, visible)
    local count = #items
    local Seg_W = size.X / math.max(count, 1)
    for i = 1, count do
        local t = (i - 1) / math.max(count - 1, 1)
        local it = items[i]
        it.Visible = visible
        it.Color = Lerp_Color(c1, c2, t)
        it.Position = Vec2(pos.X + (i - 1) * Seg_W, pos.Y)
        it.Size = Vec2(math.ceil(Seg_W + 1), size.Y)
    end
end

local function Hide_Gradient_Line(items)
    for _, it in ipairs(items) do
        it.Visible = false
    end
end

local function Make_Stripe_Pattern(count, thickness)
    local items = {}
    for i = 1, count do
        items[i] = Create_Drawing("Line", {Thickness = thickness or 10, Transparency = 0.08, Visible = false})
    end
    return items
end

local function Update_Stripe_Pattern(items, Rect_X, Rect_Y, Rect_W, Rect_H, slant, spacing, color, visible)
    for _, line in ipairs(items) do
        line.Visible = false
    end
    if not visible or Rect_W <= 0 or Rect_H <= 0 then
        return
    end

    local left = Rect_X
    local right = Rect_X + Rect_W
    local top = Rect_Y
    local bottom = Rect_Y + Rect_H
    local Start_X = left - slant
    local Total_Width = Rect_W + slant
    local needed = math.ceil(Total_Width / spacing) + 3

    for i, line in ipairs(items) do
        if i > needed then
            break
        end

        local Base_X = Start_X + ((i - 1) * spacing)
        local From_X = Base_X
        local From_Y = bottom
        local To_X = Base_X + slant
        local To_Y = top

        if To_X < left or From_X > right then
            line.Visible = false
        else
            if From_X < left then
                local t = (left - From_X) / math.max(To_X - From_X, 0.001)
                From_X = left
                From_Y = bottom + (top - bottom) * t
            end

            if To_X > right then
                local t = (right - From_X) / math.max(To_X - From_X, 0.001)
                To_X = right
                To_Y = From_Y + (top - From_Y) * t
            end

            if From_Y < top then
                From_Y = top
            elseif From_Y > bottom then
                From_Y = bottom
            end

            if To_Y < top then
                To_Y = top
            elseif To_Y > bottom then
                To_Y = bottom
            end

            if math.abs(To_X - From_X) >= 1 and math.abs(From_Y - To_Y) >= 1 then
                local t = (i - 1) / math.max(needed - 1, 1)
                line.Visible = true
                line.Color = color
                line.Transparency = math.max(0.05, 0.16 - (t * 0.10))
                line.From = Vec2(From_X, From_Y)
                line.To = Vec2(To_X, To_Y)
            else
                line.Visible = false
            end
        end
    end
end

local function Hide_Stripe_Pattern(items)
    for _, line in ipairs(items) do
        line.Visible = false
    end
end

local function Get_Context_Menu_Position(item)
    local camera = Workspace.Current_Camera
    local viewport = camera and camera.Viewport_Size or Vector2.new(1920, 1080)
    local Menu_W, Menu_H = 112, 56
    if not item or not item.Button_Pos or not item.Button_Size then
        return Vec2(0, 0)
    end
    local Context_X = item.Button_Pos.X
    local Context_Y = item.Button_Pos.Y + item.Button_Size.Y + 6
    if Context_X + Menu_W > viewport.X then
        Context_X = item.Button_Pos.X + item.Button_Size.X - Menu_W
    end
    if Context_Y + Menu_H > viewport.Y then
        Context_Y = item.Button_Pos.Y - Menu_H - 6
    end
    return Vec2(math.clamp(Context_X, 0, viewport.X - Menu_W), math.clamp(Context_Y, 0, viewport.Y - Menu_H))
end

local function Clamp_Window_Position(position, size)
    local camera = Workspace.Current_Camera
    local viewport = camera and camera.Viewport_Size or Vector2.new(1920, 1080)
    local x = math.clamp(position.X, 0, math.max(0, viewport.X - size.X))
    local y = math.clamp(position.Y, 0, math.max(0, viewport.Y - size.Y))
    return Vec2(x, y)
end

local Library = {
    Position = Vector2.new(200, 200),
    Target_Position = Vector2.new(200, 200),
    Size = Vector2.new(720, 480),
    Hotkeys_Position = Vector2.new(936, 240),
    Stats_Position = Vector2.new(936, 420),
    Visible = true,
    Bind_Pressed = false,
    Tabs = {},
    Current_Tab = nil,
    Palette = {
        Background = Color3.new(0.035294, 0.035294, 0.050980),
        Sidebar = Color3.new(0.050980, 0.050980, 0.066666),
        Section = Color3.new(0.066666, 0.066666, 0.082352),
        Element = Color3.new(0.090196, 0.090196, 0.105882),
        Hover = Color3.new(0.121568, 0.121568, 0.145098),
        Outline = Color3.new(0.105882, 0.105882, 0.133333),
        Outline_Light = Color3.new(0.172549, 0.172549, 0.211764),
        Accent = Color3.new(0.423529, 0.576470, 0.988235),
        Accent2 = Color3.new(0.619607, 0.462745, 0.988235),
        Text = Color3.new(0.952941, 0.952941, 0.972549),
        Sub_Text = Color3.new(0.541176, 0.541176, 0.580392)
    },
    Input = {
        Mouse_Pos = Vector2.new(0, 0),
        Mouse1_Down = false,
        Mouse1_Prev = false,
        Mouse1_Clicked = false,
        Mouse1_Released = false,
        Mouse2_Down = false,
        Mouse2_Prev = false,
        Mouse2_Clicked = false,
        Keys_Down = {}
    },
    State = {
        Active_Dropdown = nil,
        Active_Slider = nil,
        Active_Slider_Input = nil,
        Active_Textbox = nil,
        Active_Keybind = nil,
        Active_Color_Picker = nil,
        Active_Color_Drag = nil,
        Dragging = false,
        Drag_Start = Vector2.new(0, 0),
        Window_Start = Vector2.new(0, 0),
        Hotkeys_Dragging = false,
        Hotkeys_Drag_Start = Vector2.new(0, 0),
        Hotkeys_Window_Start = Vector2.new(0, 0),
        Stats_Dragging = false,
        Stats_Drag_Start = Vector2.new(0, 0),
        Stats_Window_Start = Vector2.new(0, 0),
        Hotkeys_Context = {
            Open = false,
            Position = Vector2.new(0, 0),
            Entry = nil
        },
        Keybind_Context = {
            Open = false,
            Position = Vector2.new(0, 0),
            Entry = nil
        },
        Backspace_Held = false,
        Backspace_Next_Repeat = 0
    }
}

local Default_Nightfall_Palette = {
    Background = Color3.new(0.035294, 0.035294, 0.050980),
    Sidebar = Color3.new(0.050980, 0.050980, 0.066666),
    Section = Color3.new(0.066666, 0.066666, 0.082352),
    Element = Color3.new(0.090196, 0.090196, 0.105882),
    Hover = Color3.new(0.121568, 0.121568, 0.145098),
    Outline = Color3.new(0.105882, 0.105882, 0.133333),
    Outline_Light = Color3.new(0.172549, 0.172549, 0.211764),
    Accent = Color3.new(0.423529, 0.576470, 0.988235),
    Accent2 = Color3.new(0.619607, 0.462745, 0.988235),
    Text = Color3.new(0.952941, 0.952941, 0.972549),
    Sub_Text = Color3.new(0.541176, 0.541176, 0.580392)
}

local Theme_Presets = {
    Nightfall = {
        Background = Default_Nightfall_Palette.Background,
        Sidebar = Default_Nightfall_Palette.Sidebar,
        Section = Default_Nightfall_Palette.Section,
        Element = Default_Nightfall_Palette.Element,
        Hover = Default_Nightfall_Palette.Hover,
        Outline = Default_Nightfall_Palette.Outline,
        Outline_Light = Default_Nightfall_Palette.Outline_Light,
        Accent = Default_Nightfall_Palette.Accent,
        Accent2 = Default_Nightfall_Palette.Accent2,
        Text = Default_Nightfall_Palette.Text,
        Sub_Text = Default_Nightfall_Palette.Sub_Text
    },
    Bloodmoon = {
        Background = Color3.From_Rgb(20, 8, 12),
        Sidebar = Color3.From_Rgb(28, 10, 16),
        Section = Color3.From_Rgb(36, 12, 20),
        Element = Color3.From_Rgb(46, 14, 24),
        Hover = Color3.From_Rgb(58, 18, 32),
        Outline = Color3.From_Rgb(70, 28, 40),
        Outline_Light = Color3.From_Rgb(96, 42, 56),
        Accent = Color3.From_Rgb(235, 72, 96),
        Accent2 = Color3.From_Rgb(255, 128, 164),
        Text = Color3.From_Rgb(246, 238, 242),
        Sub_Text = Color3.From_Rgb(176, 150, 158)
    },
    Ocean = {
        Background = Color3.From_Rgb(8, 14, 24),
        Sidebar = Color3.From_Rgb(10, 18, 32),
        Section = Color3.From_Rgb(12, 24, 40),
        Element = Color3.From_Rgb(16, 30, 50),
        Hover = Color3.From_Rgb(20, 40, 64),
        Outline = Color3.From_Rgb(28, 52, 78),
        Outline_Light = Color3.From_Rgb(42, 70, 100),
        Accent = Color3.From_Rgb(74, 168, 255),
        Accent2 = Color3.From_Rgb(98, 220, 255),
        Text = Color3.From_Rgb(240, 246, 255),
        Sub_Text = Color3.From_Rgb(148, 170, 196)
    },
    Mint = {
        Background = Color3.From_Rgb(10, 18, 16),
        Sidebar = Color3.From_Rgb(12, 24, 20),
        Section = Color3.From_Rgb(14, 30, 24),
        Element = Color3.From_Rgb(18, 38, 30),
        Hover = Color3.From_Rgb(24, 48, 38),
        Outline = Color3.From_Rgb(38, 68, 56),
        Outline_Light = Color3.From_Rgb(58, 96, 82),
        Accent = Color3.From_Rgb(64, 224, 160),
        Accent2 = Color3.From_Rgb(124, 255, 208),
        Text = Color3.From_Rgb(238, 252, 246),
        Sub_Text = Color3.From_Rgb(146, 178, 164)
    }
}

local Palette_Keys = {"Background", "Sidebar", "Section", "Element", "Hover", "Outline", "Outline_Light", "Accent", "Accent2", "Text", "Sub_Text"}
local Save_Config_Queued = false
local Is_Config_Loading = false
local Global_Settings_Path = "Moonshade_Settings.json"

local function Save_Global_Settings()
    if not writefile then
        return false
    end
    local data = {
        Auto_Save = Config.Auto_Save and true or false,
        Auto_Load = Config.Auto_Load and true or false,
        Selected_Config = tostring(Config.Selected_Config or Config.Config_Name or "default"),
        Config_Name = tostring(Config.Config_Name or Config.Selected_Config or "default")
    }
    local ok, encoded = pcall(function()
        return Http_Service:Json_Encode(data)
    end)
    if ok then
        pcall(writefile, Global_Settings_Path, encoded)
        return true
    end
    return false
end

local function Load_Global_Settings()
    if not (isfile and readfile and isfile(Global_Settings_Path)) then
        return false
    end
    local ok, decoded = pcall(function()
        return Http_Service:Json_Decode(readfile(Global_Settings_Path))
    end)
    if ok and type(decoded) == "table" then
        if decoded.Auto_Save ~= nil then Config.Auto_Save = decoded.Auto_Save and true or false end
        if decoded.Auto_Load ~= nil then Config.Auto_Load = decoded.Auto_Load and true or false end
        if type(decoded.Selected_Config) == "string" and decoded.Selected_Config ~= "" then Config.Selected_Config = decoded.Selected_Config end
        if type(decoded.Config_Name) == "string" and decoded.Config_Name ~= "" then Config.Config_Name = decoded.Config_Name end
        return true
    end
    return false
end

local function Get_Config_Base_Name()
    local name = tostring(Config.Config_Name or "default")
    name = name:gsub("[^%w%-%._]", "_")
    if name == "" then
        name = "default"
    end
    return name
end

local function Get_Config_Path()
    return "Moonshade_" .. Get_Config_Base_Name() .. ".json"
end

local function Get_Layout_Path()
    return "Moonshade_" .. Get_Config_Base_Name() .. "_layout.json"
end

local function Get_Available_Configs()
    local names = {}
    local seen = {}
    local function add(name)
        name = tostring(name or ""):gsub("[^%w%-%._]", "_")
        if name == "" then
            return
        end
        if not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end
    add(Config.Selected_Config or Config.Config_Name or "default")
    add(Config.Config_Name or "default")
    if listfiles then
        local ok, files = pcall(listfiles, ".")
        if ok and type(files) == "table" then
            for _, File_Path in ipairs(files) do
                local name = tostring(File_Path):match("Moonshade_(.-)%.json$")
                if name and not name:match("_layout$") then
                    add(name)
                end
            end
        end
    end
    if #names == 0 then
        add("default")
    end
    table.sort(names, function(a, b)
        return tostring(a):lower() < tostring(b):lower()
    end)
    return names
end

local function Get_Stripe_Back_Color()
    return Lerp_Color(Library.Palette.Accent, Library.Palette.Background, 0.55)
end

local function Get_Stripe_Front_Color()
    return Lerp_Color(Library.Palette.Accent2, Library.Palette.Background, 0.45)
end

local function Apply_Palette(palette)
    if type(palette) ~= "table" then
        return
    end
    for _, key in ipairs(Palette_Keys) do
        if palette[key] then
            Library.Palette[key] = palette[key]
        end
    end
end

local function Sync_Theme_Editor_State()
    if not Library or not Library.Tabs then
        return
    end
    for _, tab in ipairs(Library.Tabs) do
        if tab and tab.Sections then
            for _, section in ipairs(tab.Sections) do
                if section and section.Items then
                    for _, item in ipairs(section.Items) do
                        if item and item.Type == "Color_Picker" and item.Flag and type(Config[item.Flag]) == "table" and Config[item.Flag].Color then
                            local h, s, v = Color3_To_Hsv(Config[item.Flag].Color)
                            item.Hue = h
                            item.Sat = s
                            item.Val = v
                            item.Alpha = Clamp(Config[item.Flag].Alpha or 1, 0, 1)
                        end
                    end
                end
            end
        end
    end
end

local function Apply_Theme_Preset(Theme_Name, Keep_Accent)
    local preset = Theme_Presets[Theme_Name]
    if not preset then
        preset = Theme_Presets.Nightfall
        Theme_Name = "Nightfall"
    end
    local accent = Library.Palette.Accent
    local accent2 = Library.Palette.Accent2
    local Accent_Alpha = type(Config.Ui_Accent_Color) == "table" and Clamp(Config.Ui_Accent_Color.Alpha or 1, 0, 1) or 1
    local accent2Alpha = type(Config.Ui_Accent2_Color) == "table" and Clamp(Config.Ui_Accent2_Color.Alpha or 1, 0, 1) or 1
    Apply_Palette(preset)
    if Keep_Accent then
        Library.Palette.Accent = accent
        Library.Palette.Accent2 = accent2
    end
    Config.Theme_Preset = Theme_Name
    Config.Ui_Accent_Color = {
        Color = Library.Palette.Accent,
        Alpha = Accent_Alpha
    }
    Config.Ui_Accent2_Color = {
        Color = Library.Palette.Accent2,
        Alpha = accent2Alpha
    }
    Sync_Theme_Editor_State()
    Queue_Save_Config()
end

Queue_Save_Config = function()
    Save_Config_Queued = true
end

local function Save_Current_Config()
    if not writefile then
        return false
    end
    local data = {}
    for key, value in pairs(Config) do
        local t = type(value)
        if key ~= "Auto_Save" and key ~= "Auto_Load" and key ~= "Selected_Config" and (t == "boolean" or t == "number" or t == "string") then
            data[key] = value
        end
    end
    data.Theme_Preset = tostring(Config.Theme_Preset or "Nightfall")
    data.Ui_Accent_Color = {Hex = Color3_To_Hex(Library.Palette.Accent), Alpha = type(Config.Ui_Accent_Color) == "table" and (Config.Ui_Accent_Color.Alpha or 1) or 1}
    data.Ui_Accent2_Color = {Hex = Color3_To_Hex(Library.Palette.Accent2), Alpha = type(Config.Ui_Accent2_Color) == "table" and (Config.Ui_Accent2_Color.Alpha or 1) or 1}
    data.Parry_Bind_Mode = Normalize_Bind_Mode(Config.Parry_Bind_Mode)
    data.Spam_Bind_Mode = Normalize_Bind_Mode(Config.Spam_Bind_Mode)
    data.Triggerbot_Bind_Mode = Normalize_Bind_Mode(Config.Triggerbot_Bind_Mode)
    local ok, encoded = pcall(function()
        return Http_Service:Json_Encode(data)
    end)
    if not ok then
        return false
    end
    local layout = {
        Window_X = Library.Target_Position.X,
        Window_Y = Library.Target_Position.Y,
        Hotkeys_X = Library.Hotkeys_Position.X,
        Hotkeys_Y = Library.Hotkeys_Position.Y,
        Stats_X = Library.Stats_Position.X,
        Stats_Y = Library.Stats_Position.Y
    }
    local ok2, Layout_Encoded = pcall(function()
        return Http_Service:Json_Encode(layout)
    end)
    if not ok2 then
        return false
    end
    writefile(Get_Config_Path(), encoded)
    writefile(Get_Layout_Path(), Layout_Encoded)
    Config.Selected_Config = Config.Config_Name
    Save_Global_Settings()
    Save_Config_Queued = false
    Is_Config_Loading = false
    return true
end

local function Delete_Named_Config(name)
    local target = tostring(name or "")
    target = target:gsub("[^%w%-%._]", "_")
    if target == "" then
        return false
    end
    local Old_Config_Name = Config.Config_Name
    Config.Config_Name = target
    local Cfg_Path = Get_Config_Path()
    local Layout_Path = Get_Layout_Path()
    Config.Config_Name = Old_Config_Name
    local deleted = false
    if delfile then
        if isfile and isfile(Cfg_Path) then
            pcall(delfile, Cfg_Path)
            deleted = true
        end
        if isfile and isfile(Layout_Path) then
            pcall(delfile, Layout_Path)
        end
    end
    local available = Get_Available_Configs()
    local fallback = available[1] or "default"
    if Config.Selected_Config == target then
        Config.Selected_Config = fallback
    end
    if Config.Config_Name == target then
        Config.Config_Name = fallback
    end
    Save_Global_Settings()
    Save_Config_Queued = false
    return deleted
end

local function Load_Named_Config(name)
    local Old_Name = Config.Config_Name
    Is_Config_Loading = true
    if name and name ~= "" then
        Config.Config_Name = tostring(name)
    end
    local path = Get_Config_Path()
    if not (isfile and readfile and isfile(path)) then
        Config.Config_Name = Old_Name
        Is_Config_Loading = false
        return false
    end
    local ok, decoded = pcall(function()
        return Http_Service:Json_Decode(readfile(path))
    end)
    if not ok or type(decoded) ~= "table" then
        Config.Config_Name = Old_Name
        Is_Config_Loading = false
        return false
    end
    for key, value in pairs(decoded) do
        if key ~= "Ui_Accent_Color" and key ~= "Ui_Accent2_Color" and key ~= "Selected_Config" and key ~= "Auto_Save" and key ~= "Auto_Load" and Config[key] ~= nil and type(value) ~= "table" then
            Config[key] = value
        end
    end
    if decoded.Auto_Load_Config ~= nil and decoded.Auto_Load == nil then
        Config.Auto_Load = decoded.Auto_Load_Config and true or false
    end
    Config.Parry_Bind_Mode = Normalize_Bind_Mode(decoded.Parry_Bind_Mode or Config.Parry_Bind_Mode)
    Config.Spam_Bind_Mode = Normalize_Bind_Mode(decoded.Spam_Bind_Mode or Config.Spam_Bind_Mode)
    Config.Triggerbot_Bind_Mode = Normalize_Bind_Mode(decoded.Triggerbot_Bind_Mode or Config.Triggerbot_Bind_Mode)
    Apply_Theme_Preset(decoded.Theme_Preset or Config.Theme_Preset or "Nightfall", false)
    if type(decoded.Ui_Accent_Color) == "table" and decoded.Ui_Accent_Color.Hex then
        local Ok_Accent, accent = pcall(Color3.From_Hex, decoded.Ui_Accent_Color.Hex)
        if Ok_Accent and accent then
            Library.Palette.Accent = accent
        end
    end
    if type(decoded.Ui_Accent2_Color) == "table" and decoded.Ui_Accent2_Color.Hex then
        local Ok_Accent2, accent2 = pcall(Color3.From_Hex, decoded.Ui_Accent2_Color.Hex)
        if Ok_Accent2 and accent2 then
            Library.Palette.Accent2 = accent2
        end
    end
    Config.Ui_Accent_Color = {Color = Library.Palette.Accent, Alpha = type(decoded.Ui_Accent_Color) == "table" and (decoded.Ui_Accent_Color.Alpha or 1) or 1}
    Config.Ui_Accent2_Color = {Color = Library.Palette.Accent2, Alpha = type(decoded.Ui_Accent2_Color) == "table" and (decoded.Ui_Accent2_Color.Alpha or 1) or 1}
    Sync_Theme_Editor_State()
    local Layout_Path = Get_Layout_Path()
    if isfile and readfile and isfile(Layout_Path) then
        local Ok_Layout, layout = pcall(function()
            return Http_Service:Json_Decode(readfile(Layout_Path))
        end)
        if Ok_Layout and type(layout) == "table" then
            if layout.Window_X and layout.Window_Y then
                Library.Position = Vector2.new(layout.Window_X, layout.Window_Y)
                Library.Target_Position = Vector2.new(layout.Window_X, layout.Window_Y)
            end
            if layout.Hotkeys_X and layout.Hotkeys_Y then
                Library.Hotkeys_Position = Vector2.new(layout.Hotkeys_X, layout.Hotkeys_Y)
            end
            if layout.Stats_X and layout.Stats_Y then
                Library.Stats_Position = Vector2.new(layout.Stats_X, layout.Stats_Y)
            end
        end
    end
    Config.Selected_Config = Config.Config_Name
    Save_Global_Settings()
    Save_Config_Queued = false
    Is_Config_Loading = false
    return true
end

Load_Global_Settings()
if Config.Auto_Load then
    Load_Named_Config(Config.Selected_Config or Config.Config_Name)
else
    Apply_Theme_Preset(Config.Theme_Preset or "Nightfall", false)
end

local Window_Drawings = {
    Shadow = Make_Rounded_Box(Color3.new(0, 0, 0), 0.18),
    Outline = Make_Rounded_Box(Library.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library.Palette.Background, 1),
    Topbar = Make_Rounded_Box(Library.Palette.Sidebar, 1),
    Sidebar = Make_Rounded_Box(Library.Palette.Sidebar, 1),
    Topline = Make_Gradient_Line(56),
    Pattern_Back = Make_Stripe_Pattern(72, 11),
    Pattern_Front = Make_Stripe_Pattern(72, 7),
    Sidebar_Line = Create_Drawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    Top_Border = Create_Drawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    Title = Create_Drawing("Text", {Text = "Nightfall | Recode", Color = Library.Palette.Text, Size = 13, Font = 2, Outline = true, Visible = false})
}

local Stats_Drawings = {
    Outline = Make_Rounded_Box(Library.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library.Palette.Background, 1),
    Topline = Make_Gradient_Line(44),
    Header_Line = Create_Drawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    Row1 = Make_Rounded_Box(Library.Palette.Element, 1),
    Row2 = Make_Rounded_Box(Library.Palette.Element, 1),
    Row3 = Make_Rounded_Box(Library.Palette.Element, 1),
    Title = Create_Drawing("Text", {Text = "Ball Stats", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Speed = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Distance = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Dot = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local Keybinds_Drawings = {
    Outline = Make_Rounded_Box(Library.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library.Palette.Background, 1),
    Topline = Make_Gradient_Line(44),
    Header_Line = Create_Drawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    Title_Icon = Create_Keybind_Image_Icon(18),
    Title = Create_Drawing("Text", {Text = "Hotkeys", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Subtitle = Create_Drawing("Text", {Text = "", Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Row1 = Make_Rounded_Box(Library.Palette.Element, 1),
    Row2 = Make_Rounded_Box(Library.Palette.Element, 1),
    Row3 = Make_Rounded_Box(Library.Palette.Element, 1),
    Row4 = Make_Rounded_Box(Library.Palette.Element, 1),
    Bind1 = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind2 = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind3 = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind4 = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State1 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State2 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State3 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State4 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Mode1 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode2 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode3 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode4 = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 11, Font = 2, Outline = true, Visible = false}),
    Menu_Outline = Make_Rounded_Box(Library.Palette.Outline, 1),
    Menu_Background = Make_Rounded_Box(Library.Palette.Background, 1),
    Menu_Option1 = Make_Rounded_Box(Library.Palette.Element, 1),
    Menu_Option2 = Make_Rounded_Box(Library.Palette.Element, 1),
    Menu_Option1_Text = Create_Drawing("Text", {Text = "Hold", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Menu_Option2_Text = Create_Drawing("Text", {Text = "Toggle", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

function Library:Create_Tab(Tab_Name, Tab_Icon)
    local Tab = {
        Name = Tab_Name,
        Icon = "",
        Sections = {},
        Background = Make_Rounded_Box(self.Palette.Hover, 0.88),
        Label = Create_Drawing("Text", {Text = Tab_Name, Size = 12, Font = 2, Outline = true, Visible = false}),
        Icon_Draw = Create_Drawing("Text", {Text = "", Size = 12, Font = 2, Outline = true, Visible = false}),
        Indicator = Make_Rounded_Box(self.Palette.Accent, 1),
        Current_Color = self.Palette.Sub_Text,
        Current_Icon_Color = self.Palette.Sub_Text,
        Bg_Alpha = 0
    }

    function Tab:Create_Section(Section_Name, Section_Side)
        local Section = {
            Name = Section_Name,
            Side = Section_Side,
            Items = {},
            Outline = Make_Rounded_Box(Library.Palette.Outline, 1),
            Background = Make_Rounded_Box(Library.Palette.Section, 1),
            Pattern_Back = Make_Stripe_Pattern(40, 9),
            Pattern_Front = Make_Stripe_Pattern(40, 5),
            Title = Create_Drawing("Text", {Text = Section_Name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
            Line = Create_Drawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false})
        }

        function Section:Update_Container(x, y, w, h)
            Update_Rounded_Box(self.Outline, Vec2(x, y), Vec2(w, h), 6, Library.Palette.Outline, 1, true)
            Update_Rounded_Box(self.Background, Vec2(x + 1, y + 1), Vec2(w - 2, h - 2), 6, Library.Palette.Section, 1, true)
            Update_Stripe_Pattern(self.Pattern_Back, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
            Update_Stripe_Pattern(self.Pattern_Front, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
            self.Title.Visible = true
            self.Title.Position = Vec2(x + 10, y + 6)
            self.Line.Visible = true
            self.Line.Position = Vec2(x + 10, y + 25)
            self.Line.Size = Vec2(w - 20, 1)
            self.Line.Color = Library.Palette.Outline
        end

        function Section:Create_Toggle(name, flag, default)
            Config[flag] = Config[flag] ~= nil and Config[flag] or (default or false)
            local Toggle = {
                Type = "Toggle",
                Height = 24,
                Flag = flag,
                Box_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Box = Make_Rounded_Box(Library.Palette.Element, 1),
                Fill = Make_Rounded_Box(Library.Palette.Accent, 1),
                Label = Create_Drawing("Text", {Text = name, Size = 12, Font = 2, Outline = true, Visible = false}),
                Current_Color = Library.Palette.Sub_Text,
                Alpha = Config[flag] and 1 or 0,
                Hitbox_Pos = Vector2.new(),
                Hitbox_Size = Vector2.new()
            }

            function Toggle:Update(x, y, w)
                self.Hitbox_Pos = Vec2(x, y)
                self.Hitbox_Size = Vec2(w, 20)
                Update_Rounded_Box(self.Box_Stroke, Vec2(x + 2, y + 3), Vec2(16, 16), 4, Lerp_Color(Library.Palette.Outline, Library.Palette.Accent, self.Alpha), 1, true)
                Update_Rounded_Box(self.Box, Vec2(x + 3, y + 4), Vec2(14, 14), 4, Library.Palette.Element, 1, true)

                self.Label.Visible = true
                self.Label.Position = Vec2(x + 26, y + 4)

                local hovered = Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, self.Hitbox_Pos, self.Hitbox_Size)
                self.Current_Color = Lerp_Color(self.Current_Color, Config[self.Flag] and Library.Palette.Text or (hovered and Library.Palette.Text or Library.Palette.Sub_Text), 0.15)
                self.Label.Color = self.Current_Color

                self.Alpha = Lerp(self.Alpha, Config[self.Flag] and 1 or 0, 0.2)
                Update_Rounded_Box(self.Fill, Vec2(x + 5, y + 6), Vec2(10, 10), 3, Library.Palette.Accent, self.Alpha, self.Alpha > 0.02)
            end

            table.insert(self.Items, Toggle)
            return Toggle
        end

        function Section:Create_Slider(name, flag, min, max, default, step)
            Config[flag] = Config[flag] ~= nil and Config[flag] or Clamp_Slider_Value(default or min, min, max, step)
            local Slider = {
                Type = "Slider",
                Height = 44,
                Min = min,
                Max = max,
                Step = step,
                Flag = flag,
                Input_Buffer = Format_Slider_Value(Config[flag], step),
                Label = Create_Drawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Value_Label = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library.Palette.Element, 1),
                Fill = Make_Rounded_Box(Library.Palette.Accent, 1),
                Knob = Make_Rounded_Box(Library.Palette.Text, 1),
                Value_Pos = Vector2.new(),
                Value_Size = Vector2.new(),
                Bar_Pos = Vector2.new(),
                Bar_Size = Vector2.new()
            }

            function Slider:Update(x, y, w)
                local Is_Editing = Library.State.Active_Slider_Input == self
                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y)

                local Display_Text = Is_Editing and (((tick() % 1) < 0.5) and (self.Input_Buffer .. "_") or self.Input_Buffer) or Format_Slider_Value(Config[self.Flag], self.Step)
                self.Value_Label.Visible = true
                self.Value_Label.Text = Display_Text
                self.Value_Label.Color = Is_Editing and Library.Palette.Accent or Library.Palette.Sub_Text
                self.Value_Pos = Vec2(x + w - self.Value_Label.Text_Bounds.X - 4, y)
                self.Value_Size = Vec2(math.max(self.Value_Label.Text_Bounds.X + 8, 24), 16)
                self.Value_Label.Position = Vec2(self.Value_Pos.X + 4, y)

                if not Is_Editing then
                    self.Input_Buffer = Format_Slider_Value(Config[self.Flag], self.Step)
                end

                local Bar_Y = y + 26
                local Bar_Width = w - self.Value_Size.X - 12
                self.Bar_Pos = Vec2(x + 2, Bar_Y)
                self.Bar_Size = Vec2(Bar_Width, 6)
                Update_Rounded_Box(self.Stroke, self.Bar_Pos, self.Bar_Size, 3, Library.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vec2(x + 3, Bar_Y + 1), Vec2(Bar_Width - 2, 4), 3, Library.Palette.Element, 1, true)

                local range = math.max(self.Max - self.Min, 0.0001)
                local pct = Clamp((Config[self.Flag] - self.Min) / range, 0, 1)
                local Fill_W = math.max((Bar_Width - 2) * pct, 0)
                Update_Rounded_Box(self.Fill, Vec2(x + 3, Bar_Y + 1), Vec2(Fill_W, 4), 3, Library.Palette.Accent, 1, Fill_W > 0)
                Update_Rounded_Box(self.Knob, Vec2(x + 3 + Fill_W - 4, Bar_Y - 1), Vec2(8, 8), 4, Library.Palette.Text, 1, true)
            end

            table.insert(self.Items, Slider)
            return Slider
        end

        function Section:Create_Dropdown(name, flag, options, default)
            Config[flag] = Config[flag] ~= nil and Config[flag] or (default or options[1])
            local Dropdown = {
                Type = "Dropdown",
                Height = 46,
                Options = options or {},
                Flag = flag,
                Is_Open = false,
                List_Height = 0,
                Target_List_Height = 0,
                Open_Alpha = 0,
                Hovered_Index = nil,
                Label = Create_Drawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library.Palette.Element, 1),
                Value_Label = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Icon = Create_Drawing("Text", {Text = "+", Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                List_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                List_Background = Make_Rounded_Box(Library.Palette.Element, 1),
                Option_Drawings = {},
                Option_Bounds = {},
                Button_Pos = Vector2.new(),
                Button_Size = Vector2.new(),
                List_Pos = Vector2.new(),
                List_Size = Vector2.new()
            }

            function Dropdown:Set_Options(New_Options, Preserve_Value)
                self.Options = New_Options or {}
                if not Preserve_Value then
                    if #self.Options > 0 then
                        Config[self.Flag] = self.Options[1]
                    else
                        Config[self.Flag] = nil
                    end
                else
                    local found = false
                    for _, option in ipairs(self.Options) do
                        if tostring(option) == tostring(Config[self.Flag]) then
                            found = true
                            break
                        end
                    end
                    if not found then
                        if #self.Options > 0 then
                            Config[self.Flag] = self.Options[1]
                        else
                            Config[self.Flag] = nil
                        end
                    end
                end
                self.Option_Bounds = {}
                self.Hovered_Index = nil
            end

            function Dropdown:Get_Visible_Option_Bounds()
                local result = {}
                for index, bounds in ipairs(self.Option_Bounds) do
                    if bounds and bounds.Visible then
                        result[index] = bounds
                    end
                end
                return result
            end

            function Dropdown:Update(x, y, w)
                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y)

                local Bar_Y = y + 20
                self.Button_Pos = Vec2(x + 2, Bar_Y)
                self.Button_Size = Vec2(w - 4, 24)

                local Button_Outline_Color = self.Is_Open and Library.Palette.Accent or Library.Palette.Outline
                local Button_Text_Color = self.Is_Open and Library.Palette.Text or Library.Palette.Sub_Text

                Update_Rounded_Box(self.Stroke, self.Button_Pos, self.Button_Size, 4, Button_Outline_Color, 1, true)
                Update_Rounded_Box(self.Background, Vec2(self.Button_Pos.X + 1, self.Button_Pos.Y + 1), Vec2(self.Button_Size.X - 2, self.Button_Size.Y - 2), 4, Library.Palette.Element, 1, true)

                local Current_Value = Config[self.Flag]
                local Selected_Index = nil
                for idx, option in ipairs(self.Options) do
                    if tostring(option) == tostring(Current_Value) then
                        Selected_Index = idx
                        Current_Value = option
                        break
                    end
                end
                if Selected_Index == nil and #self.Options > 0 then
                    Current_Value = self.Options[1]
                    Config[self.Flag] = Current_Value
                    Selected_Index = 1
                end

                self.Value_Label.Visible = true
                self.Value_Label.Text = tostring(Current_Value or "")
                self.Value_Label.Position = Vec2(self.Button_Pos.X + 6, self.Button_Pos.Y + 5)
                self.Value_Label.Color = Button_Text_Color

                self.Icon.Visible = true
                self.Icon.Text = self.Is_Open and "-" or "+"
                self.Icon.Position = Vec2(self.Button_Pos.X + self.Button_Size.X - 14, self.Button_Pos.Y + 5)
                self.Icon.Color = Button_Text_Color

                self.Target_List_Height = self.Is_Open and (#self.Options * 24 + (#self.Options > 0 and 2 or 0)) or 0
                self.List_Height = Lerp(self.List_Height, self.Target_List_Height, 0.3)
                if math.abs(self.List_Height - self.Target_List_Height) < 0.5 then
                    self.List_Height = self.Target_List_Height
                end

                self.Open_Alpha = Lerp(self.Open_Alpha, self.Is_Open and 1 or 0, 0.3)
                if math.abs(self.Open_Alpha - (self.Is_Open and 1 or 0)) < 0.02 then
                    self.Open_Alpha = self.Is_Open and 1 or 0
                end

                local Draw_List_Height = math.max(0, Round(self.List_Height))
                local List_Visible = Draw_List_Height > 1 and self.Open_Alpha > 0.02

                self.List_Pos = Vec2(self.Button_Pos.X, self.Button_Pos.Y + self.Button_Size.Y + 2)
                self.List_Size = Vec2(self.Button_Size.X, Draw_List_Height)

                Update_Rounded_Box(self.List_Stroke, self.List_Pos, self.List_Size, 4, Library.Palette.Outline, self.Open_Alpha, List_Visible)
                Update_Rounded_Box(self.List_Background, Vec2(self.List_Pos.X + 1, self.List_Pos.Y + 1), Vec2(math.max(self.List_Size.X - 2, 0), math.max(self.List_Size.Y - 2, 0)), 4, Library.Palette.Element, self.Open_Alpha, List_Visible)

                self.Option_Bounds = {}
                self.Hovered_Index = nil

                for i, Option_Str in ipairs(self.Options) do
                    if not self.Option_Drawings[i] then
                        self.Option_Drawings[i] = Create_Drawing("Text", {Text = tostring(Option_Str), Size = 12, Font = 2, Outline = true, Visible = false})
                    end

                    local Txt_Draw = self.Option_Drawings[i]
                    local Option_Pos = Vec2(self.List_Pos.X + 6, self.List_Pos.Y + 3 + ((i - 1) * 24))
                    local Option_Size = Vec2(self.List_Size.X - 12, 20)
                    local Option_Bottom = Option_Pos.Y + Option_Size.Y
                    local Clip_Bottom = self.List_Pos.Y + Draw_List_Height - 2
                    local Option_Visible = List_Visible and Option_Pos.Y >= self.List_Pos.Y + 1 and Option_Bottom <= Clip_Bottom + 1

                    self.Option_Bounds[i] = {
                        Pos = Option_Pos,
                        Size = Option_Size,
                        Visible = Option_Visible
                    }

                    if Option_Visible and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Option_Pos, Option_Size) then
                        self.Hovered_Index = i
                    end

                    Txt_Draw.Visible = Option_Visible
                    if Option_Visible then
                        Txt_Draw.Text = tostring(Option_Str)
                        Txt_Draw.Position = Vec2(Option_Pos.X, Option_Pos.Y + 3)
                        if Selected_Index == i then
                            Txt_Draw.Color = Library.Palette.Accent
                        elseif self.Hovered_Index == i then
                            Txt_Draw.Color = Library.Palette.Text
                        else
                            Txt_Draw.Color = Library.Palette.Sub_Text
                        end
                        Txt_Draw.Transparency = math.max(self.Open_Alpha, 0.08)
                    end
                end

                for i = #self.Options + 1, #self.Option_Drawings do
                    self.Option_Drawings[i].Visible = false
                end

                self.Height = 46 + (List_Visible and (Draw_List_Height + 4) or 0)
            end

            table.insert(self.Items, Dropdown)
            return Dropdown
        end

        function Section:Create_Color_Picker(name, flag, Default_Color, Default_Alpha, callback)
            local Initial_Color = Default_Color or Library.Palette.Accent
            local Initial_Alpha = Default_Alpha
            if Initial_Alpha == nil then
                Initial_Alpha = 1
            end
            if type(Config[flag]) ~= "table" or not Config[flag].Color then
                Config[flag] = {
                    Color = Initial_Color,
                    Alpha = Clamp(Initial_Alpha, 0, 1)
                }
            end

            local h, s, v = Color3_To_Hsv(Config[flag].Color)

            local Color_Picker = {
                Type = "Color_Picker",
                Height = 36,
                Flag = flag,
                Callback = callback,
                Is_Open = false,
                Hue = h,
                Sat = s,
                Val = v,
                Alpha = Clamp(Config[flag].Alpha or 1, 0, 1),
                Grid_Cols = 32,
                Grid_Rows = 18,
                Hue_Steps = 32,
                Label = Create_Drawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library.Palette.Element, 1),
                Preview_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Preview = Make_Rounded_Box(Config[flag].Color, 1),
                Preview_Text = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 11, Font = 2, Outline = true, Visible = false}),
                Popup_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Popup_Background = Make_Rounded_Box(Library.Palette.Background, 1),
                Popup_Swatch_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Popup_Swatch = Make_Rounded_Box(Config[flag].Color, 1),
                Popup_Hex = Create_Drawing("Text", {Color = Library.Palette.Text, Size = 11, Font = 2, Outline = true, Visible = false}),
                Sv_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Hue_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Sv_Grid = Create_Grid_Squares(32 * 18),
                Hue_Grid = Create_Grid_Squares(32),
                Cursor_Outer = Create_Drawing("Circle", {Filled = false, Thickness = 2, Transparency = 1, Num_Sides = 24, Radius = 6, Visible = false}),
                Cursor_Inner = Create_Drawing("Circle", {Filled = false, Thickness = 1, Transparency = 1, Num_Sides = 24, Radius = 4, Visible = false}),
                Hue_Line = Create_Drawing("Line", {Thickness = 2, Transparency = 1, Visible = false}),
                Hue_Cap_Top = Create_Drawing("Circle", {Filled = true, Transparency = 1, Num_Sides = 20, Radius = 3, Visible = false}),
                Hue_Cap_Bottom = Create_Drawing("Circle", {Filled = true, Transparency = 1, Num_Sides = 20, Radius = 3, Visible = false}),
                Button_Pos = Vector2.new(),
                Button_Size = Vector2.new(),
                Popup_Pos = Vector2.new(),
                Popup_Size = Vector2.new(),
                Sv_Pos = Vector2.new(),
                Sv_Size = Vector2.new(),
                Hue_Pos = Vector2.new(),
                Hue_Size = Vector2.new()
            }

            function Color_Picker:Sync_Color()
                local state = Config[self.Flag]
                if type(state) ~= "table" then
                    state = {}
                    Config[self.Flag] = state
                end
                state.Color = Hsv_To_Color3(self.Hue, self.Sat, self.Val)
                state.Alpha = Clamp(self.Alpha, 0, 1)
                if self.Callback then
                    self.Callback(state)
                end
            end

            function Color_Picker:Update(x, y, w)
                self:Sync_Color()

                local state = Config[self.Flag]
                local Current_Color = state and state.Color or Hsv_To_Color3(self.Hue, self.Sat, self.Val)
                local Current_Hex = Color3_To_Hex(Current_Color)

                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y + 8)

                self.Button_Pos = Vec2(x + w - 84, y + 4)
                self.Button_Size = Vec2(80, 24)

                Update_Rounded_Box(self.Stroke, self.Button_Pos, self.Button_Size, 4, self.Is_Open and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vec2(self.Button_Pos.X + 1, self.Button_Pos.Y + 1), Vec2(self.Button_Size.X - 2, self.Button_Size.Y - 2), 4, Library.Palette.Element, 1, true)
                Update_Rounded_Box(self.Preview_Stroke, Vec2(self.Button_Pos.X + 5, self.Button_Pos.Y + 5), Vec2(14, 14), 3, Library.Palette.Outline_Light, 1, true)
                Update_Rounded_Box(self.Preview, Vec2(self.Button_Pos.X + 6, self.Button_Pos.Y + 6), Vec2(12, 12), 2, Current_Color, math.max(state and state.Alpha or 1, 0.15), true)

                self.Preview_Text.Visible = true
                self.Preview_Text.Text = Current_Hex
                self.Preview_Text.Color = self.Is_Open and Library.Palette.Text or Library.Palette.Sub_Text
                self.Preview_Text.Position = Vec2(self.Button_Pos.X + 24, self.Button_Pos.Y + 7)

                if self.Is_Open then
                    local Popup_W = 246
                    local Popup_H = 160
                    self.Popup_Pos = Vec2(x + w - Popup_W - 4, y + 32)
                    self.Popup_Size = Vec2(Popup_W, Popup_H)
                    self.Height = 196

                    Update_Rounded_Box(self.Popup_Stroke, self.Popup_Pos, self.Popup_Size, 5, Library.Palette.Outline, 1, true)
                    Update_Rounded_Box(self.Popup_Background, Vec2(self.Popup_Pos.X + 1, self.Popup_Pos.Y + 1), Vec2(self.Popup_Size.X - 2, self.Popup_Size.Y - 2), 5, Library.Palette.Background, 1, true)

                    self.Sv_Pos = Vec2(self.Popup_Pos.X + 10, self.Popup_Pos.Y + 10)
                    self.Sv_Size = Vec2(226, 104)
                    self.Hue_Pos = Vec2(self.Popup_Pos.X + 10, self.Popup_Pos.Y + 124)
                    self.Hue_Size = Vec2(226, 16)

                    Update_Rounded_Box(self.Sv_Stroke, Vec2(self.Sv_Pos.X - 1, self.Sv_Pos.Y - 1), Vec2(self.Sv_Size.X + 2, self.Sv_Size.Y + 2), 3, Library.Palette.Outline, 1, true)
                    Update_Rounded_Box(self.Hue_Stroke, Vec2(self.Hue_Pos.X - 1, self.Hue_Pos.Y - 1), Vec2(self.Hue_Size.X + 2, self.Hue_Size.Y + 2), 3, Library.Palette.Outline, 1, true)

                    Update_Grid_Squares(self.Sv_Grid, self.Grid_Cols, self.Grid_Rows, self.Sv_Pos.X, self.Sv_Pos.Y, self.Sv_Size.X, self.Sv_Size.Y, function(col, row, cols, rows)
                        local sat = (col - 1) / math.max(cols - 1, 1)
                        local val = 1 - ((row - 1) / math.max(rows - 1, 1))
                        return Hsv_To_Color3(self.Hue, sat, val)
                    end, true)

                    Update_Grid_Squares(self.Hue_Grid, self.Hue_Steps, 1, self.Hue_Pos.X, self.Hue_Pos.Y, self.Hue_Size.X, self.Hue_Size.Y, function(col, _, cols)
                        local hh = (col - 1) / math.max(cols - 1, 1)
                        return Hsv_To_Color3(hh, 1, 1)
                    end, true)

                    local Cursor_X = self.Sv_Pos.X + (self.Sat * self.Sv_Size.X)
                    local Cursor_Y = self.Sv_Pos.Y + ((1 - self.Val) * self.Sv_Size.Y)
                    self.Cursor_Outer.Visible = true
                    self.Cursor_Outer.Color = Color3.new(0, 0, 0)
                    self.Cursor_Outer.Position = Vec2(Cursor_X, Cursor_Y)
                    self.Cursor_Outer.Radius = 6
                    self.Cursor_Inner.Visible = true
                    self.Cursor_Inner.Color = Color3.new(1, 1, 1)
                    self.Cursor_Inner.Position = Vec2(Cursor_X, Cursor_Y)
                    self.Cursor_Inner.Radius = 4

                    local Hue_X = self.Hue_Pos.X + (self.Hue * self.Hue_Size.X)
                    self.Hue_Line.Visible = true
                    self.Hue_Line.Color = Library.Palette.Text
                    self.Hue_Line.From = Vec2(Hue_X, self.Hue_Pos.Y - 3)
                    self.Hue_Line.To = Vec2(Hue_X, self.Hue_Pos.Y + self.Hue_Size.Y + 3)

                    self.Hue_Cap_Top.Visible = true
                    self.Hue_Cap_Top.Color = Library.Palette.Text
                    self.Hue_Cap_Top.Position = Vec2(Hue_X, self.Hue_Pos.Y - 3)
                    self.Hue_Cap_Top.Radius = 3
                    self.Hue_Cap_Bottom.Visible = true
                    self.Hue_Cap_Bottom.Color = Library.Palette.Text
                    self.Hue_Cap_Bottom.Position = Vec2(Hue_X, self.Hue_Pos.Y + self.Hue_Size.Y + 3)
                    self.Hue_Cap_Bottom.Radius = 3

                    Update_Rounded_Box(self.Popup_Swatch_Stroke, Vec2(self.Popup_Pos.X + 10, self.Popup_Pos.Y + 146), Vec2(22, 8), 2, Library.Palette.Outline_Light, 1, true)
                    Update_Rounded_Box(self.Popup_Swatch, Vec2(self.Popup_Pos.X + 11, self.Popup_Pos.Y + 147), Vec2(20, 6), 2, Current_Color, math.max(state and state.Alpha or 1, 0.15), true)

                    self.Popup_Hex.Visible = true
                    self.Popup_Hex.Text = Current_Hex
                    self.Popup_Hex.Position = Vec2(self.Popup_Pos.X + 38, self.Popup_Pos.Y + 144)
                else
                    self.Height = 36
                    Update_Rounded_Box(self.Popup_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.Popup_Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.Popup_Swatch_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.Popup_Swatch, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.Sv_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Update_Rounded_Box(self.Hue_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    Hide_Grid_Squares(self.Sv_Grid)
                    Hide_Grid_Squares(self.Hue_Grid)
                    self.Cursor_Outer.Visible = false
                    self.Cursor_Inner.Visible = false
                    self.Hue_Line.Visible = false
                    self.Hue_Cap_Top.Visible = false
                    self.Hue_Cap_Bottom.Visible = false
                    self.Popup_Hex.Visible = false
                end
            end

            table.insert(self.Items, Color_Picker)
            return Color_Picker
        end

        function Section:Create_Keybind(name, flag, default)
            Config[flag] = Normalize_Keybind_Value(Config[flag] ~= nil and Config[flag] or (default or "None"))
            local Keybind = {
                Type = "Keybind",
                Height = 30,
                Flag = flag,
                Icon = Create_Keybind_Image_Icon(18),
                Label = Create_Drawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Button_Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Button_Box = Make_Rounded_Box(Library.Palette.Element, 1),
                Value_Label = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 11, Font = 2, Outline = true, Visible = false}),
                Button_Pos = Vector2.new(),
                Button_Size = Vector2.new()
            }

            function Keybind:Update(x, y, w)
                Update_Keybind_Image_Icon(self.Icon, Vec2(0, 0), Library.Palette.Accent, false)

                self.Label.Visible = true
                self.Label.Position = Vec2(x + 6, y + 8)

                local Bind_Value = Normalize_Keybind_Value(Config[self.Flag])
                local Bind_Text = Library.State.Active_Keybind == self and "[...]" or ("[" .. Bind_Value .. "]")
                self.Value_Label.Visible = true
                self.Value_Label.Text = Bind_Text

                local Btn_Width = math.max(74, self.Value_Label.Text_Bounds.X + 20)
                self.Button_Pos = Vec2(x + w - Btn_Width - 2, y + 4)
                self.Button_Size = Vec2(Btn_Width, 22)

                local Is_Active = Library.State.Active_Keybind == self
                Update_Keybind_Image_Icon(self.Icon, Vec2(0, 0), Library.Palette.Accent, false)
                Update_Rounded_Box(self.Button_Stroke, self.Button_Pos, self.Button_Size, 4, Is_Active and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Button_Box, Vec2(self.Button_Pos.X + 1, self.Button_Pos.Y + 1), Vec2(Btn_Width - 2, 20), 4, Is_Active and Library.Palette.Hover or Library.Palette.Element, 1, true)

                self.Value_Label.Color = Is_Active and Library.Palette.Text or Library.Palette.Sub_Text
                self.Value_Label.Position = Vec2(
                    self.Button_Pos.X + math.floor((Btn_Width - self.Value_Label.Text_Bounds.X) / 2 + 0.5),
                    self.Button_Pos.Y + math.floor((self.Button_Size.Y - self.Value_Label.Text_Bounds.Y) / 2 + 0.5) - 1
                )
            end

            table.insert(self.Items, Keybind)
            return Keybind
        end

        function Section:Create_Button(name, callback)
            local Button = {
                Type = "Button",
                Height = 34,
                Callback = callback,
                Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library.Palette.Element, 1),
                Label = Create_Drawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Button_Pos = Vector2.new(),
                Button_Size = Vector2.new()
            }

            function Button:Update(x, y, w)
                self.Button_Pos = Vec2(x + 2, y + 4)
                self.Button_Size = Vec2(w - 4, 24)
                local hovered = Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, self.Button_Pos, self.Button_Size)
                Update_Rounded_Box(self.Stroke, self.Button_Pos, self.Button_Size, 4, hovered and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vec2(self.Button_Pos.X + 1, self.Button_Pos.Y + 1), Vec2(self.Button_Size.X - 2, self.Button_Size.Y - 2), 4, hovered and Library.Palette.Hover or Library.Palette.Element, 1, true)
                self.Label.Visible = true
                self.Label.Color = Library.Palette.Text
                self.Label.Position = Vec2(self.Button_Pos.X + math.floor((self.Button_Size.X - self.Label.Text_Bounds.X) / 2 + 0.5), self.Button_Pos.Y + 6)
            end

            table.insert(self.Items, Button)
            return Button
        end

        function Section:Create_Textbox(name, flag, default)
            Config[flag] = Config[flag] ~= nil and Config[flag] or (default or "")
            local Textbox = {
                Type = "Textbox",
                Height = 36,
                Flag = flag,
                Label = Create_Drawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = Make_Rounded_Box(Library.Palette.Outline, 1),
                Background = Make_Rounded_Box(Library.Palette.Element, 1),
                Value_Label = Create_Drawing("Text", {Color = Library.Palette.Sub_Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Box_Pos = Vector2.new(),
                Box_Size = Vector2.new()
            }

            function Textbox:Update(x, y, w)
                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y + 8)
                local Box_Width = 110
                self.Box_Pos = Vec2(x + w - Box_Width - 2, y + 6)
                self.Box_Size = Vec2(Box_Width, 24)

                local Is_Active = Library.State.Active_Textbox == self
                Update_Rounded_Box(self.Stroke, self.Box_Pos, self.Box_Size, 4, Is_Active and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                Update_Rounded_Box(self.Background, Vec2(self.Box_Pos.X + 1, self.Box_Pos.Y + 1), Vec2(Box_Width - 2, 22), 4, Library.Palette.Element, 1, true)

                local Display_Str = tostring(Config[self.Flag])
                if Is_Active and tick() % 1 < 0.5 then
                    Display_Str = Display_Str .. "_"
                end

                self.Value_Label.Visible = true
                self.Value_Label.Text = Display_Str
                self.Value_Label.Color = Is_Active and Library.Palette.Text or Library.Palette.Sub_Text
                self.Value_Label.Position = Vec2(x + w - Box_Width + 3, y + 11)
            end

            table.insert(self.Items, Textbox)
            return Textbox
        end

        table.insert(Tab.Sections, Section)
        return Section
    end

    table.insert(Library.Tabs, Tab)
    if not Library.Current_Tab then
        Library.Current_Tab = Tab
    end
    return Tab
end

Config.Parry_Bind_Mode = Normalize_Bind_Mode(Config.Parry_Bind_Mode)
Config.Spam_Bind_Mode = Normalize_Bind_Mode(Config.Spam_Bind_Mode)
Config.Triggerbot_Bind_Mode = Normalize_Bind_Mode(Config.Triggerbot_Bind_Mode)
Config.Dot_Protect = true

local Tab_Combat = Library:Create_Tab("Combat")
local Sec_Combat_Main = Tab_Combat:Create_Section("Main Settings", "Left")
Sec_Combat_Main:Create_Toggle("Auto Parry", "Auto_Parry", false)
Sec_Combat_Main:Create_Toggle("Training balls support", "Lobby_Parry", false)
Sec_Combat_Main:Create_Dropdown("Parry Method", "Parry_Method", {"Click", "Key"}, "Click")
Sec_Combat_Main:Create_Keybind("Parry Bind", "Parry_Keybind", "None")

local Sec_Combat_Offense = Tab_Combat:Create_Section("Offensive Options", "Right")
Sec_Combat_Offense:Create_Toggle("Auto Spam", "Auto_Spam", false)
Sec_Combat_Offense:Create_Slider("Spam Sensitivity", "Spam_Sensitivity", 1, 100, 50, 1, "")
Sec_Combat_Offense:Create_Keybind("Spam Bind", "Spam_Keybind", "None")
Sec_Combat_Offense:Create_Toggle("Triggerbot", "Triggerbot_Enabled", false)
Sec_Combat_Offense:Create_Toggle("No Click On Ball Spawn", "No_Click_On_Ball_Spawn", true)
Sec_Combat_Offense:Create_Keybind("Trigger Bind", "Triggerbot_Keybind", "None")

local Tab_Settings = Library:Create_Tab("Settings")
local Sec_Settings_Config = Tab_Settings:Create_Section("Configuration", "Left")
Sec_Settings_Config:Create_Toggle("Ball Stats", "Render_Ball_Stats", false)
Sec_Settings_Config:Create_Keybind("Menu Bind", "Hide_Keybind", 27)
Sec_Settings_Config:Create_Toggle("Hotkey List", "Show_Hotkey_List", true)

local Tab_Themes = Library:Create_Tab("Themes")
local Sec_Themes_Main = Tab_Themes:Create_Section("Theme Presets", "Left")
Sec_Themes_Main:Create_Dropdown("Preset", "Theme_Preset", {"Nightfall", "Bloodmoon", "Ocean", "Mint"}, Config.Theme_Preset or "Nightfall")
local Sec_Themes_Accent = Tab_Themes:Create_Section("Accent", "Right")
Sec_Themes_Accent:Create_Color_Picker("Accent", "Ui_Accent_Color", Library.Palette.Accent, 1, function(state) Library.Palette.Accent = state.Color end)
Sec_Themes_Accent:Create_Color_Picker("Accent 2", "Ui_Accent2_Color", Library.Palette.Accent2, 1, function(state) Library.Palette.Accent2 = state.Color end)

local Tab_Configs = Library:Create_Tab("Configs")
local Sec_Configs_Main = Tab_Configs:Create_Section("Config Manager", "Left")
local Config_List_Dropdown = Sec_Configs_Main:Create_Dropdown("Config", "Selected_Config", Get_Available_Configs(), Config.Selected_Config or Config.Config_Name or "default")
Sec_Configs_Main:Create_Textbox("Config Name", "Config_Name", Config.Config_Name or "default")
Sec_Configs_Main:Create_Toggle("Auto Save", "Auto_Save", Config.Auto_Save)
Sec_Configs_Main:Create_Toggle("Auto Load", "Auto_Load", Config.Auto_Load)
Sec_Configs_Main:Create_Button("Save Config", function()
    Config.Selected_Config = Config.Config_Name
    Save_Current_Config()
    if Config_List_Dropdown then
        Config_List_Dropdown:Set_Options(Get_Available_Configs(), true)
    end
end)
Sec_Configs_Main:Create_Button("Load Config", function()
    Load_Named_Config(Config.Selected_Config or Config.Config_Name)
    Save_Global_Settings()
    if Config_List_Dropdown then
        Config_List_Dropdown:Set_Options(Get_Available_Configs(), true)
    end
end)
Sec_Configs_Main:Create_Button("Delete Config", function()
    local target = Config.Selected_Config or Config.Config_Name or "default"
    Delete_Named_Config(target)
    if Config_List_Dropdown then
        Config_List_Dropdown:Set_Options(Get_Available_Configs(), true)
    end
end)

local Overlay_Menu_Drawings = {
    Outline = Make_Rounded_Box(Library.Palette.Outline, 1),
    Background = Make_Rounded_Box(Library.Palette.Background, 1),
    Option1 = Make_Rounded_Box(Library.Palette.Element, 1),
    Option2 = Make_Rounded_Box(Library.Palette.Element, 1),
    Option1_Text = Create_Drawing("Text", {Text = "Hold", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Option2_Text = Create_Drawing("Text", {Text = "Toggle", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local function Close_Transient_Ui()
    if Library.State.Active_Dropdown then
        Library.State.Active_Dropdown.Is_Open = false
    end
    if Library.State.Active_Color_Picker then
        Library.State.Active_Color_Picker.Is_Open = false
    end
    Library.State.Active_Dropdown = nil
    Library.State.Active_Slider = nil
    if Library.State.Active_Slider_Input then
        Commit_Slider_Input(Library.State.Active_Slider_Input)
    end
    Library.State.Active_Slider_Input = nil
    Library.State.Active_Textbox = nil
    Library.State.Active_Keybind = nil
    Library.State.Active_Color_Picker = nil
    Library.State.Active_Color_Drag = nil
    Library.State.Hotkeys_Context.Open = false
    Library.State.Hotkeys_Context.Entry = nil
    Library.State.Keybind_Context.Open = false
    Library.State.Keybind_Context.Entry = nil
end

local function Hide_Stats_Drawings()
    Update_Rounded_Box(Stats_Drawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Stats_Drawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Gradient_Line(Stats_Drawings.Topline, Vec2(0, 0), Vec2(0, 0), Color3.new(0, 0, 0), Color3.new(0, 0, 0), false)
    Stats_Drawings.Header_Line.Visible = false
    Update_Rounded_Box(Stats_Drawings.Row1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Stats_Drawings.Row2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Stats_Drawings.Row3, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Stats_Drawings.Title.Visible = false
    Stats_Drawings.Speed.Visible = false
    Stats_Drawings.Distance.Visible = false
    Stats_Drawings.Dot.Visible = false
end

local function Hide_Hotkeys_Drawings()
    Update_Rounded_Box(Keybinds_Drawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Keybinds_Drawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Hide_Gradient_Line(Keybinds_Drawings.Topline)
    Keybinds_Drawings.Header_Line.Visible = false
    Update_Keybind_Image_Icon(Keybinds_Drawings.Title_Icon, Vec2(0, 0), Library.Palette.Accent, false)
    Keybinds_Drawings.Title.Visible = false
    Keybinds_Drawings.Subtitle.Visible = false
    for _, row in ipairs({Keybinds_Drawings.Row1, Keybinds_Drawings.Row2, Keybinds_Drawings.Row3, Keybinds_Drawings.Row4, Keybinds_Drawings.Menu_Outline, Keybinds_Drawings.Menu_Background, Keybinds_Drawings.Menu_Option1, Keybinds_Drawings.Menu_Option2}) do
        Update_Rounded_Box(row, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end
    for _, txt in ipairs({
        Keybinds_Drawings.Bind1, Keybinds_Drawings.Bind2, Keybinds_Drawings.Bind3, Keybinds_Drawings.Bind4,
        Keybinds_Drawings.State1, Keybinds_Drawings.State2, Keybinds_Drawings.State3, Keybinds_Drawings.State4,
        Keybinds_Drawings.Mode1, Keybinds_Drawings.Mode2, Keybinds_Drawings.Mode3, Keybinds_Drawings.Mode4,
        Keybinds_Drawings.Menu_Option1_Text, Keybinds_Drawings.Menu_Option2_Text
    }) do
        txt.Visible = false
    end
end

local function Safe_Hide_Drawing(draw)
    if draw then
        draw.Visible = false
    end
end

local function Hide_Item(item)
    if not item then
        return
    end

    if item.Type == "Toggle" then
        if item.Box_Stroke then
            Update_Rounded_Box(item.Box_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Box then
            Update_Rounded_Box(item.Box, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Fill then
            Update_Rounded_Box(item.Fill, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        Safe_Hide_Drawing(item.Label)
    elseif item.Type == "Slider" then
        if item.Stroke then
            Update_Rounded_Box(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            Update_Rounded_Box(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Fill then
            Update_Rounded_Box(item.Fill, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Value_Stroke then
            Update_Rounded_Box(item.Value_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Value_Background then
            Update_Rounded_Box(item.Value_Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Knob_Outer then
            Update_Rounded_Box(item.Knob_Outer, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Knob then
            Update_Rounded_Box(item.Knob, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        Safe_Hide_Drawing(item.Label)
        Safe_Hide_Drawing(item.Value_Label)
        Safe_Hide_Drawing(item.Dot)
    elseif item.Type == "Dropdown" then
        item.Is_Open = false
        item.List_Height = 0
        item.Target_List_Height = 0
        item.Open_Alpha = 0
        Safe_Hide_Drawing(item.Label)
        Safe_Hide_Drawing(item.Value_Label)
        Safe_Hide_Drawing(item.Icon)
        if item.Stroke then
            Update_Rounded_Box(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            Update_Rounded_Box(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.List_Stroke then
            Update_Rounded_Box(item.List_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.List_Background then
            Update_Rounded_Box(item.List_Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        for _, draw in ipairs(item.Option_Drawings or {}) do
            Safe_Hide_Drawing(draw)
        end
    elseif item.Type == "Color_Picker" then
        Safe_Hide_Drawing(item.Label)
        Safe_Hide_Drawing(item.Preview_Text)
        Safe_Hide_Drawing(item.Popup_Hex)
        if item.Stroke then
            Update_Rounded_Box(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            Update_Rounded_Box(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Preview_Stroke then
            Update_Rounded_Box(item.Preview_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Preview then
            Update_Rounded_Box(item.Preview, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Popup_Stroke then
            Update_Rounded_Box(item.Popup_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Popup_Background then
            Update_Rounded_Box(item.Popup_Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Popup_Swatch_Stroke then
            Update_Rounded_Box(item.Popup_Swatch_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Popup_Swatch then
            Update_Rounded_Box(item.Popup_Swatch, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Sv_Stroke then
            Update_Rounded_Box(item.Sv_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Hue_Stroke then
            Update_Rounded_Box(item.Hue_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        Hide_Grid_Squares(item.Sv_Grid or {})
        Hide_Grid_Squares(item.Hue_Grid or {})
        Safe_Hide_Drawing(item.Cursor_Outer)
        Safe_Hide_Drawing(item.Cursor_Inner)
        Safe_Hide_Drawing(item.Hue_Line)
        Safe_Hide_Drawing(item.Hue_Cap_Top)
        Safe_Hide_Drawing(item.Hue_Cap_Bottom)
    elseif item.Type == "Keybind" then
        if item.Icon then
            Update_Keybind_Image_Icon(item.Icon, Vec2(0, 0), Library.Palette.Accent, false)
        end
        Safe_Hide_Drawing(item.Label)
        Safe_Hide_Drawing(item.Value_Label)
        if item.Button_Stroke then
            Update_Rounded_Box(item.Button_Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Button_Box then
            Update_Rounded_Box(item.Button_Box, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
    elseif item.Type == "Textbox" then
        Safe_Hide_Drawing(item.Label)
        Safe_Hide_Drawing(item.Value_Label)
        if item.Stroke then
            Update_Rounded_Box(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            Update_Rounded_Box(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
    end
end

local function Hide_Tab_Content(tab)
    if not tab then
        return
    end
    for _, section in ipairs(tab.Sections) do
        Update_Rounded_Box(section.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(section.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Hide_Stripe_Pattern(section.Pattern_Back)
        Hide_Stripe_Pattern(section.Pattern_Front)
        section.Title.Visible = false
        section.Line.Visible = false
        for _, item in ipairs(section.Items) do
            Hide_Item(item)
        end
    end
end

local Hide_Window_Drawings

local function Force_Hide_Main_Ui()
    Hide_Window_Drawings()
    Hide_Stats_Drawings()

    for _, tab in ipairs(Library.Tabs) do
        Hide_Tab_Content(tab)
    end

    if Library.State.Active_Dropdown then
        Library.State.Active_Dropdown.Is_Open = false
        Library.State.Active_Dropdown.List_Height = 0
        Library.State.Active_Dropdown.Target_List_Height = 0
        Library.State.Active_Dropdown.Open_Alpha = 0
    end

    local Menu_Visible = false
    Update_Rounded_Box(Keybinds_Drawings.Menu_Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Keybinds_Drawings.Menu_Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Keybinds_Drawings.Menu_Option1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Keybinds_Drawings.Menu_Option2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Keybinds_Drawings.Menu_Option1_Text.Visible = false
    Keybinds_Drawings.Menu_Option2_Text.Visible = false

    Update_Rounded_Box(Overlay_Menu_Drawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Overlay_Menu_Drawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Overlay_Menu_Drawings.Option1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Overlay_Menu_Drawings.Option2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Overlay_Menu_Drawings.Option1_Text.Visible = false
    Overlay_Menu_Drawings.Option2_Text.Visible = false
    Library.State.Keybind_Context.Open = false
    Library.State.Keybind_Context.Entry = nil
    if Library.State.Active_Slider_Input then
        Commit_Slider_Input(Library.State.Active_Slider_Input)
    end
    Library.State.Active_Slider_Input = nil
end

local function Apply_Held_Backspace()
    local Target_Slider = Library.State.Active_Slider_Input
    local Target_Textbox = Library.State.Active_Textbox
    if not Target_Slider and not Target_Textbox then
        Library.State.Backspace_Held = false
        Library.State.Backspace_Next_Repeat = 0
        return
    end

    local Is_Backspace_Down = iskeypressed and iskeypressed(8) or false
    if not Is_Backspace_Down then
        Library.State.Backspace_Held = false
        Library.State.Backspace_Next_Repeat = 0
        return
    end

    local now = tick()
    if not Library.State.Backspace_Held then
        Library.State.Backspace_Held = true
        Library.State.Backspace_Next_Repeat = now + 0.42
        return
    end

    if now < (Library.State.Backspace_Next_Repeat or 0) then
        return
    end

    Library.State.Backspace_Next_Repeat = now + 0.035

    if Target_Slider then
        local Current_Text = tostring(Target_Slider.Input_Buffer or "")
        Target_Slider.Input_Buffer = string.sub(Current_Text, 1, -2)
    elseif Target_Textbox then
        local Current_Text = tostring(Config[Target_Textbox.Flag] or "")
        Config[Target_Textbox.Flag] = string.sub(Current_Text, 1, -2)
        Queue_Save_Config()
    end
end

Hide_Window_Drawings = function()
    Update_Rounded_Box(Window_Drawings.Shadow, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Topbar, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Update_Rounded_Box(Window_Drawings.Sidebar, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    Hide_Gradient_Line(Window_Drawings.Topline)
    Hide_Stripe_Pattern(Window_Drawings.Pattern_Back)
    Hide_Stripe_Pattern(Window_Drawings.Pattern_Front)
    Window_Drawings.Sidebar_Line.Visible = false
    Window_Drawings.Top_Border.Visible = false
    Window_Drawings.Title.Visible = false
    for _, tab in ipairs(Library.Tabs) do
        Update_Rounded_Box(tab.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(tab.Indicator, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        tab.Label.Visible = false
        tab.Icon_Draw.Visible = false
        Hide_Tab_Content(tab)
    end
end

local function Do_Click()
    if not isrbxactive or not isrbxactive() then
        return
    end
    if Config.Parry_Method == "Click" then
        if mouse1press and mouse1release then
            mouse1press()
            mouse1release()
        end
    else
        if keypress and keyrelease then
            keypress(0x46)
            keyrelease(0x46)
        end
    end
end

local Auto_Runtime = {
    Ball = nil,
    Last_Ball = nil,
    Last_Ball_Pos = Vector3.zero,
    Last_Ball_Vel = Vector3.zero,
    Last_Ball_Speed = 0,
    Last_Target = nil,
    Last_Target_Change = 0,
    Parries = 0,
    Auto_Spam = false,
    Cooldown = false,
    Warp_Detected_At = -999,
    Ping_History = {},
    Smoothed_Accel = 0,
    Curve_History = {},
    Last_Alive = false,
    Parried = false,
    Trigger_Parried = false,
    Last_Parry_At = 0,
    Last_Spam_At = 0,
    Last_Manual_Click_At = 0,
    Trigger_Scheduled_At = 0
}

local Auto_Spam_Batch = {
    Accumulator = 0,
    Last_Batch = 0,
    Total_Clicks = 0
}

local function Is_Auto_Spam_Batch_Active()
    if not _G.Moonshade_Active then
        return false
    end
    if not Auto_Runtime then
        return false
    end
    if not Config.Auto_Spam or not Auto_Runtime.Auto_Spam then
        return false
    end
    if isrbxactive and not isrbxactive() then
        return false
    end
    local character = Local_Player.Character
    local humanoid = character and character:Find_First_Child("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function Reset_Auto_Spam_Batch()
    Auto_Spam_Batch.Accumulator = 0
    Auto_Spam_Batch.Last_Batch = 0
end

Run_Service.Heartbeat:Connect(function(dt)
    dt = Fast_Clamp and Fast_Clamp(dt or 0.016, 0, 0.05) or math.clamp(dt or 0.016, 0, 0.05)

    if not Is_Auto_Spam_Batch_Active() then
        Reset_Auto_Spam_Batch()
        return
    end

    local sensitivity = math.clamp(tonumber(Config.Spam_Sensitivity) or 50, 1, 100)
    local Clicks_Per_Second = sensitivity * 12

    Auto_Spam_Batch.Accumulator = Auto_Spam_Batch.Accumulator + (Clicks_Per_Second * dt)
    local clicks = math.floor(Auto_Spam_Batch.Accumulator)

    if clicks <= 0 then
        Auto_Spam_Batch.Last_Batch = 0
        return
    end

    Auto_Spam_Batch.Accumulator = Auto_Spam_Batch.Accumulator - clicks
    Auto_Spam_Batch.Last_Batch = clicks
    Auto_Spam_Batch.Total_Clicks = Auto_Spam_Batch.Total_Clicks + clicks
    Auto_Runtime.Spam_Batch = Auto_Spam_Batch.Last_Batch
    Auto_Runtime.Spam_Total = Auto_Spam_Batch.Total_Clicks
    Auto_Runtime.Last_Spam_At = Fast_Tick and Fast_Tick() or tick()

    for _ = 1, clicks do
        Do_Click()
    end
end)

Run_Service.Render_Stepped:Connect(function()
    if not (isrbxactive and isrbxactive()) then
        return
    end
    Library.Input.Mouse_Pos = Vector2.new(Mouse.X, Mouse.Y)
    Library.Input.Mouse1_Down = ismouse1pressed and ismouse1pressed() or false
    Library.Input.Mouse1_Clicked = Library.Input.Mouse1_Down and not Library.Input.Mouse1_Prev
    Library.Input.Mouse1_Released = not Library.Input.Mouse1_Down and Library.Input.Mouse1_Prev
    Library.Input.Mouse1_Prev = Library.Input.Mouse1_Down
    Library.Input.Mouse2_Down = ismouse2pressed and ismouse2pressed() or false
    Library.Input.Mouse2_Clicked = Library.Input.Mouse2_Down and not Library.Input.Mouse2_Prev
    Library.Input.Mouse2_Prev = Library.Input.Mouse2_Down

    local Is_Shift_Down = (iskeypressed and (iskeypressed(160) or iskeypressed(161) or iskeypressed(16))) or false

    for Key_Code, Key_Name in pairs(Key_Codes) do
        local Is_Pressed = iskeypressed and iskeypressed(Key_Code) or false
        if Key_Code == 1 then
            Is_Pressed = Library.Input.Mouse1_Down
        elseif Key_Code == 2 then
            Is_Pressed = Library.Input.Mouse2_Down
        end

        if Is_Pressed and not Library.Input.Keys_Down[Key_Code] then
            Library.Input.Keys_Down[Key_Code] = true

            if Library.State.Active_Keybind then
                Config[Library.State.Active_Keybind.Flag] = Normalize_Keybind_Value(Key_Code == 27 and "None" or Key_Name)
                Library.State.Active_Keybind = nil
            elseif Library.State.Active_Slider_Input then
                local slider = Library.State.Active_Slider_Input
                local Current_Text = tostring(slider.Input_Buffer or "")
                if Key_Code == 8 then
                    slider.Input_Buffer = string.sub(Current_Text, 1, -2)
                elseif Key_Code == 13 then
                    Commit_Slider_Input(slider)
                    Library.State.Active_Slider_Input = nil
                elseif Key_Code == 27 then
                    slider.Input_Buffer = Format_Slider_Value(Config[slider.Flag], slider.Step)
                    Library.State.Active_Slider_Input = nil
                else
                    local char = Key_Name
                    if Key_Code >= 48 and Key_Code <= 57 then
                        slider.Input_Buffer = Current_Text .. char
                    elseif Key_Code >= 96 and Key_Code <= 105 then
                        slider.Input_Buffer = Current_Text .. tostring(Key_Code - 96)
                    elseif Key_Code == 109 then
                        if not string.find(Current_Text, "%-") then
                            slider.Input_Buffer = "-" .. Current_Text
                        end
                    elseif Key_Code == 189 then
                        if not string.find(Current_Text, "%-") then
                            slider.Input_Buffer = "-" .. Current_Text
                        end
                    elseif Key_Code == 110 or Key_Code == 190 then
                        if not string.find(Current_Text, "%.") then
                            slider.Input_Buffer = Current_Text .. "."
                        end
                    end
                end
            elseif Library.State.Active_Textbox then
                local tbox = Library.State.Active_Textbox
                local Current_Text = tostring(Config[tbox.Flag])
                if Key_Code == 8 then
                    Config[tbox.Flag] = string.sub(Current_Text, 1, -2)
                elseif Key_Code == 13 or Key_Code == 27 then
                    Library.State.Active_Textbox = nil
                elseif Key_Code == 32 then
                    Config[tbox.Flag] = Current_Text .. " "
                    Queue_Save_Config()
                else
                    local char = Key_Name
                    if Key_Code >= 65 and Key_Code <= 90 then
                        Config[tbox.Flag] = Current_Text .. (Is_Shift_Down and char or string.lower(char))
                        Queue_Save_Config()
                    elseif Key_Code >= 48 and Key_Code <= 57 then
                        Config[tbox.Flag] = Current_Text .. (Is_Shift_Down and (Shift_Modifiers[char] or char) or char)
                        Queue_Save_Config()
                    end
                end
            else
                if Key_Name == Normalize_Keybind_Value(Config.Hide_Keybind) then
                    if not Library.Bind_Pressed then
                        Library.Visible = not Library.Visible
                        Library.Bind_Pressed = true
                        if not Library.Visible then
                            Close_Transient_Ui()
                            Hide_Window_Drawings()
                            if not Config.Show_Hotkey_List then
                                Hide_Hotkeys_Drawings()
                            end
                        end
                    end
                elseif Key_Name == Normalize_Keybind_Value(Config.Parry_Keybind) then
                    Handle_Bind_Press("Parry_Keybind")
                elseif Key_Name == Normalize_Keybind_Value(Config.Spam_Keybind) then
                    Handle_Bind_Press("Spam_Keybind")
                elseif Key_Name == Normalize_Keybind_Value(Config.Triggerbot_Keybind) then
                    Handle_Bind_Press("Triggerbot_Keybind")
                end
            end
        elseif not Is_Pressed then
            Library.Input.Keys_Down[Key_Code] = false
            if Key_Name == Normalize_Keybind_Value(Config.Hide_Keybind) then
                Library.Bind_Pressed = false
            elseif Key_Name == Normalize_Keybind_Value(Config.Parry_Keybind) then
                Handle_Bind_Release("Parry_Keybind")
            elseif Key_Name == Normalize_Keybind_Value(Config.Spam_Keybind) then
                Handle_Bind_Release("Spam_Keybind")
            elseif Key_Name == Normalize_Keybind_Value(Config.Triggerbot_Keybind) then
                Handle_Bind_Release("Triggerbot_Keybind")
            end
        end
    end

    Apply_Held_Backspace()

    local Hotkeys_Size = Vector2.new(286, 196)
    local Should_Show_Hotkeys = Config.Show_Hotkey_List

    if not Library.Visible then
        Close_Transient_Ui()
        for _, tab in ipairs(Library.Tabs) do
            Hide_Tab_Content(tab)
        end
        Hide_Window_Drawings()
        if not Should_Show_Hotkeys then
            Hide_Hotkeys_Drawings()
        end
    end

    local Hotkey_Entries = {
        {Bind_Flag = "Parry_Keybind", Toggle_Flag = "Auto_Parry", Label = "Parry"},
        {Bind_Flag = "Spam_Keybind", Toggle_Flag = "Auto_Spam", Label = "Spam"},
        {Bind_Flag = "Triggerbot_Keybind", Toggle_Flag = "Triggerbot_Enabled", Label = "Trigger"}
    }

    local Stats_Size = Vec2(276, 166)
    local Accent_Color = Library.Palette.Accent

    if Should_Show_Hotkeys then
        Library.Hotkeys_Position = Clamp_Window_Position(Library.Hotkeys_Position, Hotkeys_Size)

        if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Library.Hotkeys_Position, Vector2.new(Hotkeys_Size.X, 36)) then
            Library.State.Hotkeys_Dragging = true
            Library.State.Hotkeys_Drag_Start = Library.Input.Mouse_Pos
            Library.State.Hotkeys_Window_Start = Library.Hotkeys_Position
            Close_Transient_Ui()
        end

        if Library.Input.Mouse1_Released then
            Library.State.Hotkeys_Dragging = false
        end

        if Library.State.Hotkeys_Dragging then
            Library.Hotkeys_Position = Clamp_Window_Position(Library.State.Hotkeys_Window_Start + (Library.Input.Mouse_Pos - Library.State.Hotkeys_Drag_Start), Hotkeys_Size)
        end

        local Binds_Size = Vec2(Hotkeys_Size.X, Hotkeys_Size.Y)
        local Binds_Pos = Clamp_Window_Position(Vec2(Library.Hotkeys_Position.X, Library.Hotkeys_Position.Y), Binds_Size)
        Library.Hotkeys_Position = Binds_Pos

        Update_Rounded_Box(Keybinds_Drawings.Outline, Binds_Pos, Binds_Size, 8, Library.Palette.Outline, 1, true)
        Update_Rounded_Box(Keybinds_Drawings.Background, Vec2(Binds_Pos.X + 1, Binds_Pos.Y + 1), Vec2(Binds_Size.X - 2, Binds_Size.Y - 2), 8, Library.Palette.Background, 1, true)
        Update_Gradient_Line(Keybinds_Drawings.Topline, Vec2(Binds_Pos.X + 1, Binds_Pos.Y + 1), Vec2(Binds_Size.X - 2, 2), Library.Palette.Accent, Library.Palette.Accent2, true)
        Keybinds_Drawings.Header_Line.Visible = true
        Keybinds_Drawings.Header_Line.Position = Vec2(Binds_Pos.X + 12, Binds_Pos.Y + 40)
        Keybinds_Drawings.Header_Line.Size = Vec2(Binds_Size.X - 24, 1)
        Keybinds_Drawings.Header_Line.Color = Library.Palette.Outline
        Update_Keybind_Image_Icon(Keybinds_Drawings.Title_Icon, Vec2(Binds_Pos.X + 12, Binds_Pos.Y + 10), Accent_Color, false)
        Keybinds_Drawings.Title.Visible = true
        Keybinds_Drawings.Title.Position = Vec2(Binds_Pos.X + 12, Binds_Pos.Y + 8)
        Keybinds_Drawings.Subtitle.Visible = false

        local Row_X = Binds_Pos.X + 12
        local Row_W = Binds_Size.X - 24
        local Row_H = 28
        local Row_Start_Y = Binds_Pos.Y + 48
        local Row_Gap = 8
        local Hotkey_Rows = {
            {X = Row_X, Y = Row_Start_Y, W = Row_W, H = Row_H, Entry = Hotkey_Entries[1]},
            {X = Row_X, Y = Row_Start_Y + (Row_H + Row_Gap) * 1, W = Row_W, H = Row_H, Entry = Hotkey_Entries[2]},
            {X = Row_X, Y = Row_Start_Y + (Row_H + Row_Gap) * 2, W = Row_W, H = Row_H, Entry = Hotkey_Entries[3]},
            {X = Row_X, Y = Row_Start_Y + (Row_H + Row_Gap) * 3, W = Row_W, H = Row_H, Entry = Hotkey_Entries[4]}
        }

        if Library.Input.Mouse2_Clicked and Library.State.Hotkeys_Context.Open then
            local Menu_Pos = Library.State.Hotkeys_Context.Position
            if not Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Menu_Pos, Vector2.new(112, 56)) then
                Library.State.Hotkeys_Context.Open = false
                Library.State.Hotkeys_Context.Entry = nil
            end
        end

        local Row_Boxes = {Keybinds_Drawings.Row1, Keybinds_Drawings.Row2, Keybinds_Drawings.Row3, Keybinds_Drawings.Row4}
        local Bind_Texts = {Keybinds_Drawings.Bind1, Keybinds_Drawings.Bind2, Keybinds_Drawings.Bind3, Keybinds_Drawings.Bind4}
        local State_Texts = {Keybinds_Drawings.State1, Keybinds_Drawings.State2, Keybinds_Drawings.State3, Keybinds_Drawings.State4}
        local Mode_Texts = {Keybinds_Drawings.Mode1, Keybinds_Drawings.Mode2, Keybinds_Drawings.Mode3, Keybinds_Drawings.Mode4}

        for i, row in ipairs(Hotkey_Rows) do
            local Row_Box = Row_Boxes[i]
            local Bind_Draw = Bind_Texts[i]
            local State_Draw = State_Texts[i]
            local Mode_Draw = Mode_Texts[i]
            local Bind_Value = Normalize_Keybind_Value(Config[row.Entry.Bind_Flag])
            local Bind_Mode = Get_Bind_Mode(row.Entry.Bind_Flag)
            local Is_Enabled = Config[row.Entry.Toggle_Flag] and true or false
            local Row_Hovered = Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Vec2(row.X, row.Y), Vec2(row.W, row.H))
            local Row_Color = Is_Enabled and Library.Palette.Hover or (Row_Hovered and Library.Palette.Hover or Library.Palette.Element)

            Update_Rounded_Box(Row_Box, Vec2(row.X, row.Y), Vec2(row.W, row.H), 6, Row_Color, 1, true)

            Bind_Draw.Visible = true
            Bind_Draw.Text = "[" .. string.upper(Bind_Value) .. "]  " .. row.Entry.Label
            Bind_Draw.Color = Is_Enabled and Library.Palette.Text or Lerp_Color(Library.Palette.Sub_Text, Library.Palette.Text, Row_Hovered and 0.35 or 0)
            Bind_Draw.Position = Vec2(row.X + 10, row.Y + 7)

            local State_Column_W = 36
            local Mode_Column_W = 58
            local State_Text_X = row.X + row.W - State_Column_W - 10
            local Mode_Text_X = State_Text_X - Mode_Column_W - 10

            State_Draw.Visible = true
            State_Draw.Text = Is_Enabled and "On" or "Off"
            State_Draw.Color = Is_Enabled and Library.Palette.Text or Library.Palette.Sub_Text
            State_Draw.Position = Vec2(State_Text_X, row.Y + 8)

            Mode_Draw.Visible = true
            Mode_Draw.Text = string.upper(Bind_Mode)
            Mode_Draw.Color = Bind_Mode == "Hold" and Library.Palette.Accent2 or Library.Palette.Accent
            Mode_Draw.Position = Vec2(Mode_Text_X, row.Y + 8)

        end
    else
        Hide_Hotkeys_Drawings()
        Library.State.Hotkeys_Dragging = false
        Library.State.Stats_Dragging = false
        Library.State.Hotkeys_Context.Open = false
        Library.State.Hotkeys_Context.Entry = nil
    end

    local Show_Stats = Config.Render_Ball_Stats
    Library.Stats_Position = Clamp_Window_Position(Library.Stats_Position, Stats_Size)
    local Stats_Pos = Vec2(Library.Stats_Position.X, Library.Stats_Position.Y)

    if Show_Stats then
        if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Library.Stats_Position, Vector2.new(Stats_Size.X, 36)) then
            Library.State.Stats_Dragging = true
            Library.State.Stats_Drag_Start = Library.Input.Mouse_Pos
            Library.State.Stats_Window_Start = Library.Stats_Position
            Close_Transient_Ui()
        end

        if Library.Input.Mouse1_Released then
            Library.State.Stats_Dragging = false
        end

        if Library.State.Stats_Dragging then
            Library.Stats_Position = Clamp_Window_Position(Library.State.Stats_Window_Start + (Library.Input.Mouse_Pos - Library.State.Stats_Drag_Start), Stats_Size)
            Stats_Pos = Vec2(Library.Stats_Position.X, Library.Stats_Position.Y)
        end
    else
        Library.State.Stats_Dragging = false
    end

    Update_Rounded_Box(Stats_Drawings.Outline, Stats_Pos, Stats_Size, 8, Library.Palette.Outline, 1, Show_Stats)
    Update_Rounded_Box(Stats_Drawings.Background, Vec2(Stats_Pos.X + 1, Stats_Pos.Y + 1), Vec2(Stats_Size.X - 2, Stats_Size.Y - 2), 8, Library.Palette.Background, 1, Show_Stats)
    Update_Gradient_Line(Stats_Drawings.Topline, Vec2(Stats_Pos.X + 1, Stats_Pos.Y + 1), Vec2(Stats_Size.X - 2, 2), Library.Palette.Accent, Library.Palette.Accent2, Show_Stats)
    Stats_Drawings.Header_Line.Visible = Show_Stats
    Stats_Drawings.Title.Visible = Show_Stats
    Stats_Drawings.Speed.Visible = Show_Stats
    Stats_Drawings.Distance.Visible = Show_Stats
    Stats_Drawings.Dot.Visible = Show_Stats

    if Show_Stats then
        Stats_Drawings.Header_Line.Position = Vec2(Stats_Pos.X + 12, Stats_Pos.Y + 40)
        Stats_Drawings.Header_Line.Size = Vec2(Stats_Size.X - 24, 1)
        Stats_Drawings.Header_Line.Color = Library.Palette.Outline

        local Row_X = Stats_Pos.X + 12
        local Row_W = Stats_Size.X - 24
        local Row_H = 30
        local row1Y = Stats_Pos.Y + 50
        local row2Y = row1Y + 36
        local row3Y = row2Y + 36
        Update_Rounded_Box(Stats_Drawings.Row1, Vec2(Row_X, row1Y), Vec2(Row_W, Row_H), 6, Library.Palette.Element, 1, true)
        Update_Rounded_Box(Stats_Drawings.Row2, Vec2(Row_X, row2Y), Vec2(Row_W, Row_H), 6, Library.Palette.Element, 1, true)
        Update_Rounded_Box(Stats_Drawings.Row3, Vec2(Row_X, row3Y), Vec2(Row_W, Row_H), 6, Library.Palette.Element, 1, true)

        local Speed_Value = math.max(0, math.floor(tonumber(Runtime_State.Target_Speed) or 0))
        local Distance_Value = math.max(0, math.floor(tonumber(Runtime_State.Target_Distance) or 0))
        local Dot_Value = tonumber(Runtime_State.Target_Dot) or 0

        Stats_Drawings.Title.Position = Vec2(Stats_Pos.X + 12, Stats_Pos.Y + 8)
        Stats_Drawings.Title.Text = "Ball Stats"

        Stats_Drawings.Speed.Position = Vec2(Stats_Pos.X + 20, row1Y + 8)
        Stats_Drawings.Speed.Text = "Ball Speed : " .. tostring(Speed_Value)
        Stats_Drawings.Speed.Color = Library.Palette.Text

        Stats_Drawings.Distance.Position = Vec2(Stats_Pos.X + 20, row2Y + 8)
        Stats_Drawings.Distance.Text = "Ball Dist  : " .. tostring(Distance_Value)
        Stats_Drawings.Distance.Color = Library.Palette.Text

        Stats_Drawings.Dot.Position = Vec2(Stats_Pos.X + 20, row3Y + 8)
        Stats_Drawings.Dot.Text = "Ball Dot   : " .. string.format("%.2f", Dot_Value)
        Stats_Drawings.Dot.Color = Library.Palette.Text
    else
        Update_Rounded_Box(Stats_Drawings.Row1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Stats_Drawings.Row2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Stats_Drawings.Row3, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end

    if Save_Config_Queued and not Is_Config_Loading and not Library.State.Active_Dropdown and not Library.State.Active_Color_Drag and not Library.State.Active_Slider and not Library.State.Active_Slider_Input and not Library.State.Active_Textbox and not Library.State.Active_Keybind then
        Save_Global_Settings()
        if Config.Auto_Save then
            Save_Current_Config()
            if Config_List_Dropdown then
                Config_List_Dropdown:Set_Options(Get_Available_Configs(), true)
            end
        else
            Save_Config_Queued = false
        end
    end

    if not Library.Visible then
        return
    end

    local Size_X, Size_Y = Library.Size.X, Library.Size.Y

    if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Library.Position, Vector2.new(Size_X, 36)) then
        Library.State.Dragging = true
        Library.State.Drag_Start = Library.Input.Mouse_Pos
        Library.State.Window_Start = Library.Target_Position
        Close_Transient_Ui()
    end

    if Library.Input.Mouse1_Released then
        Library.State.Dragging = false
        Library.State.Active_Slider = nil
    end

    if Library.State.Dragging then
        Library.Target_Position = Library.State.Window_Start + (Library.Input.Mouse_Pos - Library.State.Drag_Start)
        Library.Position = Library.Target_Position
    else
        Library.Position = Vector2.new(Lerp(Library.Position.X, Library.Target_Position.X, 0.25), Lerp(Library.Position.Y, Library.Target_Position.Y, 0.25))
    end

    local Pos_X, Pos_Y = Library.Position.X, Library.Position.Y

    Update_Rounded_Box(Window_Drawings.Shadow, Vec2(Pos_X - 3, Pos_Y - 3), Vec2(Size_X + 6, Size_Y + 6), 6, Color3.new(0, 0, 0), 0.18, true)
    Update_Rounded_Box(Window_Drawings.Outline, Vec2(Pos_X - 1, Pos_Y - 1), Vec2(Size_X + 2, Size_Y + 2), 6, Library.Palette.Outline, 1, true)
    Update_Rounded_Box(Window_Drawings.Background, Vec2(Pos_X, Pos_Y), Vec2(Size_X, Size_Y), 6, Library.Palette.Background, 1, true)
    Update_Rounded_Box(Window_Drawings.Topbar, Vec2(Pos_X, Pos_Y), Vec2(Size_X, 36), 6, Library.Palette.Sidebar, 1, true)
    Update_Rounded_Box(Window_Drawings.Sidebar, Vec2(Pos_X, Pos_Y + 37), Vec2(150, Size_Y - 37), 6, Library.Palette.Sidebar, 1, true)
    Update_Gradient_Line(Window_Drawings.Topline, Vec2(Pos_X + 1, Pos_Y + 1), Vec2(Size_X - 2, 2), Library.Palette.Accent, Library.Palette.Accent2, true)
    Update_Stripe_Pattern(Window_Drawings.Pattern_Back, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
    Update_Stripe_Pattern(Window_Drawings.Pattern_Front, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
    Window_Drawings.Top_Border.Visible = true
    Window_Drawings.Top_Border.Position = Vec2(Pos_X, Pos_Y + 36)
    Window_Drawings.Top_Border.Size = Vec2(Size_X, 1)
    Window_Drawings.Top_Border.Color = Library.Palette.Outline
    Window_Drawings.Sidebar_Line.Visible = true
    Window_Drawings.Sidebar_Line.Position = Vec2(Pos_X + 150, Pos_Y + 37)
    Window_Drawings.Sidebar_Line.Size = Vec2(1, Size_Y - 37)
    Window_Drawings.Sidebar_Line.Color = Library.Palette.Outline
    Window_Drawings.Title.Visible = true
    Window_Drawings.Title.Position = Vec2(Pos_X + 15, Pos_Y + 11)

    if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Vector2.new(Pos_X, Pos_Y + 37), Vector2.new(150, Size_Y - 37)) then
        local Y_Offset = Pos_Y + 42
        for _, tab in ipairs(Library.Tabs) do
            if Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Vector2.new(Pos_X + 5, Y_Offset), Vector2.new(140, 32)) then
                Library.Current_Tab = tab
                Close_Transient_Ui()
                for _, t in ipairs(Library.Tabs) do
                    Hide_Tab_Content(t)
                end
            end
            Y_Offset = Y_Offset + 36
        end
    end

    if Library.State.Keybind_Context.Open and Library.State.Keybind_Context.Entry and Library.Visible then
        local Menu_Pos = Library.State.Keybind_Context.Position
        local Menu_Size = Vector2.new(128, 66)
        local Option_Size = Vector2.new(118, 24)
        local Hold_Pos = Vec2(Menu_Pos.X + 5, Menu_Pos.Y + 6)
        local Toggle_Pos = Vec2(Menu_Pos.X + 5, Menu_Pos.Y + 35)
        local Current_Mode = Get_Bind_Mode(Library.State.Keybind_Context.Entry.Bind_Flag)
        local Hold_Hovered = Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Hold_Pos, Option_Size)
        local Toggle_Hovered = Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Toggle_Pos, Option_Size)
        local Hold_Selected = Current_Mode == "Hold"
        local Toggle_Selected = Current_Mode == "Toggle"

        if Library.Input.Mouse1_Clicked then
            if Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Hold_Pos, Option_Size) then
                Set_Bind_Mode(Library.State.Keybind_Context.Entry.Bind_Flag, "Hold")
                Queue_Save_Config()
                Library.State.Keybind_Context.Open = false
                Library.State.Keybind_Context.Entry = nil
            elseif Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Toggle_Pos, Option_Size) then
                Set_Bind_Mode(Library.State.Keybind_Context.Entry.Bind_Flag, "Toggle")
                Queue_Save_Config()
                Library.State.Keybind_Context.Open = false
                Library.State.Keybind_Context.Entry = nil
            elseif not Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Menu_Pos, Menu_Size) then
                Library.State.Keybind_Context.Open = false
                Library.State.Keybind_Context.Entry = nil
            end
        elseif Library.Input.Mouse2_Clicked and not Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Menu_Pos, Menu_Size) then
            Library.State.Keybind_Context.Open = false
            Library.State.Keybind_Context.Entry = nil
        end

        Update_Rounded_Box(Overlay_Menu_Drawings.Outline, Menu_Pos, Menu_Size, 6, Library.Palette.Outline, 1, true)
        Update_Rounded_Box(Overlay_Menu_Drawings.Background, Vec2(Menu_Pos.X + 1, Menu_Pos.Y + 1), Vec2(Menu_Size.X - 2, Menu_Size.Y - 2), 6, Library.Palette.Background, 1, true)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option1, Hold_Pos, Option_Size, 5, Hold_Selected and Library.Palette.Accent or (Hold_Hovered and Library.Palette.Hover or Library.Palette.Element), 1, true)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option2, Toggle_Pos, Option_Size, 5, Toggle_Selected and Library.Palette.Accent or (Toggle_Hovered and Library.Palette.Hover or Library.Palette.Element), 1, true)

        Overlay_Menu_Drawings.Option1_Text.Visible = true
        Overlay_Menu_Drawings.Option1_Text.Text = "Hold"
        Overlay_Menu_Drawings.Option1_Text.Color = Hold_Selected and Library.Palette.Text or (Hold_Hovered and Library.Palette.Text or Library.Palette.Sub_Text)
        Overlay_Menu_Drawings.Option1_Text.Position = Vec2(Hold_Pos.X + 42, Hold_Pos.Y + 5)

        Overlay_Menu_Drawings.Option2_Text.Visible = true
        Overlay_Menu_Drawings.Option2_Text.Text = "Toggle"
        Overlay_Menu_Drawings.Option2_Text.Color = Toggle_Selected and Library.Palette.Text or (Toggle_Hovered and Library.Palette.Text or Library.Palette.Sub_Text)
        Overlay_Menu_Drawings.Option2_Text.Position = Vec2(Toggle_Pos.X + 34, Toggle_Pos.Y + 5)
    else
        Update_Rounded_Box(Overlay_Menu_Drawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Overlay_Menu_Drawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Update_Rounded_Box(Overlay_Menu_Drawings.Option2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        Overlay_Menu_Drawings.Option1_Text.Visible = false
        Overlay_Menu_Drawings.Option2_Text.Visible = false
    end

    if Library.Current_Tab then
        local Block_Input = Library.State.Dragging or Library.State.Stats_Dragging or Library.State.Keybind_Context.Open

        if Library.State.Active_Dropdown then
            local dropdown = Library.State.Active_Dropdown
            if Library.Input.Mouse1_Clicked then
                local Mouse_Pos = Library.Input.Mouse_Pos
                local Inside_Current_Button = Is_Mouse_In_Bounds(Mouse_Pos, dropdown.Button_Pos, dropdown.Button_Size)
                local Clicked_Dropdown = nil

                for _, section in ipairs(Library.Current_Tab.Sections) do
                    for _, candidate in ipairs(section.Items) do
                        if candidate.Type == "Dropdown" and Is_Mouse_In_Bounds(Mouse_Pos, candidate.Button_Pos, candidate.Button_Size) then
                            Clicked_Dropdown = candidate
                            break
                        end
                    end
                    if Clicked_Dropdown then
                        break
                    end
                end

                if Clicked_Dropdown then
                    if Clicked_Dropdown == dropdown then
                        dropdown.Is_Open = false
                        Library.State.Active_Dropdown = nil
                    else
                        dropdown.Is_Open = false
                        Clicked_Dropdown.Is_Open = true
                        Clicked_Dropdown.Open_Alpha = 0
                        Clicked_Dropdown.List_Height = 0
                        Clicked_Dropdown.Target_List_Height = 0
                        Library.State.Active_Dropdown = Clicked_Dropdown
                    end
                    Block_Input = true
                else
                    local Picked_Option = nil
                    for index, bounds in ipairs(dropdown.Option_Bounds or {}) do
                        if bounds and bounds.Visible and Is_Mouse_In_Bounds(Mouse_Pos, bounds.Pos, bounds.Size) then
                            Picked_Option = index
                            break
                        end
                    end

                    if Picked_Option and dropdown.Options[Picked_Option] ~= nil then
                        Config[dropdown.Flag] = dropdown.Options[Picked_Option]
                        if dropdown.Flag == "Theme_Preset" then
                            Apply_Theme_Preset(Config[dropdown.Flag], false)
                            Queue_Save_Config()
                        elseif dropdown.Flag == "Selected_Config" then
                            Config.Selected_Config = tostring(Config[dropdown.Flag])
                        else
                            Queue_Save_Config()
                        end
                        dropdown.Is_Open = false
                        Library.State.Active_Dropdown = nil
                        Block_Input = true
                    else
                        local Inside_List = dropdown.Is_Open and Is_Mouse_In_Bounds(Mouse_Pos, dropdown.List_Pos, dropdown.List_Size)
                        if not Inside_Current_Button and not Inside_List then
                            dropdown.Is_Open = false
                            Library.State.Active_Dropdown = nil
                            Block_Input = true
                        elseif Inside_Current_Button then
                            dropdown.Is_Open = false
                            Library.State.Active_Dropdown = nil
                            Block_Input = true
                        end
                    end
                end
            elseif Library.Input.Mouse2_Clicked then
                dropdown.Is_Open = false
                Library.State.Active_Dropdown = nil
                Block_Input = true
            end
        end

        if Library.State.Active_Color_Picker then
            local picker = Library.State.Active_Color_Picker
            if Library.Input.Mouse1_Clicked and not Library.State.Active_Color_Drag then
                local Inside_Button = Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, picker.Button_Pos, picker.Button_Size)
                local Inside_Popup = picker.Is_Open and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, picker.Popup_Pos, picker.Popup_Size)
                if not Inside_Button and not Inside_Popup then
                    picker.Is_Open = false
                    Library.State.Active_Color_Picker = nil
                end
            end
        end

        if Library.State.Active_Slider_Input and Library.Input.Mouse1_Clicked then
            local Active_Input = Library.State.Active_Slider_Input
            local Clicked_Value = Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, Active_Input.Value_Pos, Active_Input.Value_Size)
            if not Clicked_Value then
                Commit_Slider_Input(Active_Input)
                Library.State.Active_Slider_Input = nil
            end
        end

        if not Block_Input then
            for _, section in ipairs(Library.Current_Tab.Sections) do
                for _, item in ipairs(section.Items) do
                    if item.Type == "Toggle" then
                        if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Hitbox_Pos, item.Hitbox_Size) then
                            if Library.State.Active_Slider_Input then
                                Commit_Slider_Input(Library.State.Active_Slider_Input)
                                Library.State.Active_Slider_Input = nil
                            end
                            Config[item.Flag] = not Config[item.Flag]
                            Queue_Save_Config()
                        end
                    elseif item.Type == "Slider" then
                        if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Value_Pos, item.Value_Size) then
                            if Library.State.Active_Slider_Input and Library.State.Active_Slider_Input ~= item then
                                Commit_Slider_Input(Library.State.Active_Slider_Input)
                            end
                            Library.State.Active_Slider_Input = item
                            item.Input_Buffer = Format_Slider_Value(Config[item.Flag], item.Step)
                            Library.State.Active_Slider = nil
                            Library.State.Active_Textbox = nil
                            Library.State.Active_Keybind = nil
                        elseif Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Bar_Pos - Vector2.new(0, 4), item.Bar_Size + Vector2.new(0, 8)) then
                            if Library.State.Active_Slider_Input then
                                Commit_Slider_Input(Library.State.Active_Slider_Input)
                                Library.State.Active_Slider_Input = nil
                            end
                            Library.State.Active_Slider = item
                        end
                    elseif item.Type == "Dropdown" then
                        if Library.Input.Mouse1_Clicked and not Library.State.Active_Dropdown and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Button_Pos, item.Button_Size) then
                            if Library.State.Active_Slider_Input then
                                Commit_Slider_Input(Library.State.Active_Slider_Input)
                                Library.State.Active_Slider_Input = nil
                            end
                            if Library.State.Active_Color_Picker then
                                Library.State.Active_Color_Picker.Is_Open = false
                                Library.State.Active_Color_Picker = nil
                            end
                            item.Is_Open = true
                            item.Open_Alpha = 0
                            item.List_Height = 0
                            item.Target_List_Height = 0
                            Library.State.Active_Dropdown = item
                            Block_Input = true
                        end
                    elseif item.Type == "Color_Picker" then
                        if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Button_Pos, item.Button_Size) then
                            if Library.State.Active_Color_Picker and Library.State.Active_Color_Picker ~= item then
                                Library.State.Active_Color_Picker.Is_Open = false
                            end
                            if Library.State.Active_Slider_Input then
                                Commit_Slider_Input(Library.State.Active_Slider_Input)
                                Library.State.Active_Slider_Input = nil
                            end
                            item.Is_Open = not item.Is_Open
                            Library.State.Active_Color_Picker = item.Is_Open and item or nil
                            Library.State.Active_Keybind = nil
                            Library.State.Active_Textbox = nil
                            Library.State.Active_Dropdown = nil
                        elseif item.Is_Open and Library.Input.Mouse1_Clicked then
                            if Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Sv_Pos, item.Sv_Size) then
                                Library.State.Active_Color_Picker = item
                                Library.State.Active_Color_Drag = "Sv"
                            elseif Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Hue_Pos, item.Hue_Size) then
                                Library.State.Active_Color_Picker = item
                                Library.State.Active_Color_Drag = "Hue"
                            end
                        end
                    elseif item.Type == "Keybind" then
                        if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Button_Pos, item.Button_Size) then
                            Library.State.Active_Keybind = item
                            if Library.State.Active_Slider_Input then
                                Commit_Slider_Input(Library.State.Active_Slider_Input)
                                Library.State.Active_Slider_Input = nil
                            end
                            Library.State.Active_Textbox = nil
                            if Library.State.Active_Color_Picker then
                                Library.State.Active_Color_Picker.Is_Open = false
                                Library.State.Active_Color_Picker = nil
                            end
                            Library.State.Hotkeys_Context.Open = false
                            Library.State.Hotkeys_Context.Entry = nil
                            Library.State.Keybind_Context.Open = false
                            Library.State.Keybind_Context.Entry = nil
                        elseif Library.Input.Mouse2_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Button_Pos, item.Button_Size) then
                            Library.State.Active_Keybind = nil
                            if Library.State.Active_Slider_Input then
                                Commit_Slider_Input(Library.State.Active_Slider_Input)
                                Library.State.Active_Slider_Input = nil
                            end
                            Library.State.Active_Textbox = nil
                            Library.State.Keybind_Context.Open = true
                            Library.State.Keybind_Context.Entry = {
                                Bind_Flag = item.Flag,
                                Toggle_Flag = Get_Toggle_Flag_From_Bind_Flag(item.Flag),
                                Label = item.Label and item.Label.Text or "Bind",
                                Item = item
                            }
                            local Context_Pos = Get_Context_Menu_Position(item)
                            Library.State.Keybind_Context.Position = Vector2.new(Context_Pos.X, Context_Pos.Y)
                        end
                    elseif item.Type == "Button" then
                        if Library.Input.Mouse1_Clicked and Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Button_Pos, item.Button_Size) then
                            if item.Callback then
                                item.Callback()
                            end
                        end
                    elseif item.Type == "Textbox" then
                        if Library.Input.Mouse1_Clicked then
                            if Is_Mouse_In_Bounds(Library.Input.Mouse_Pos, item.Box_Pos, item.Box_Size) then
                                Library.State.Active_Textbox = item
                                Library.State.Active_Keybind = nil
                                if Library.State.Active_Slider_Input then
                                    Commit_Slider_Input(Library.State.Active_Slider_Input)
                                    Library.State.Active_Slider_Input = nil
                                end
                                if Library.State.Active_Color_Picker then
                                    Library.State.Active_Color_Picker.Is_Open = false
                                    Library.State.Active_Color_Picker = nil
                                end
                                Library.State.Keybind_Context.Open = false
                                Library.State.Keybind_Context.Entry = nil
                            elseif Library.State.Active_Textbox == item then
                                Library.State.Active_Textbox = nil
                            end
                        end
                    end
                end
            end
        end
    end

    if not Library.Input.Mouse1_Down then
        Library.State.Active_Color_Drag = nil
    end

    if Library.State.Active_Color_Picker and Library.State.Active_Color_Drag then
        local picker = Library.State.Active_Color_Picker
        if Library.State.Active_Color_Drag == "Sv" and picker.Sv_Pos and picker.Sv_Size then
            picker.Sat = Clamp((Library.Input.Mouse_Pos.X - picker.Sv_Pos.X) / picker.Sv_Size.X, 0, 1)
            picker.Val = 1 - Clamp((Library.Input.Mouse_Pos.Y - picker.Sv_Pos.Y) / picker.Sv_Size.Y, 0, 1)
            Queue_Save_Config()
        elseif Library.State.Active_Color_Drag == "Hue" and picker.Hue_Pos and picker.Hue_Size then
            picker.Hue = Clamp((Library.Input.Mouse_Pos.X - picker.Hue_Pos.X) / picker.Hue_Size.X, 0, 1)
            Queue_Save_Config()
        end
    end

    if Library.State.Active_Slider and Library.State.Active_Slider.Bar_Size then
        local slider = Library.State.Active_Slider
        if Library.Input.Mouse1_Down then
            local left = slider.Bar_Pos.X
            local width = math.max(slider.Bar_Size.X, 1)
            local percentage = Clamp((Library.Input.Mouse_Pos.X - left) / width, 0, 1)
            Config[slider.Flag] = Clamp_Slider_Value(slider.Min + (percentage * (slider.Max - slider.Min)), slider.Min, slider.Max, slider.Step)
            Queue_Save_Config()
        else
            Library.State.Active_Slider = nil
        end
    end

    local Tab_Y_Offset = Pos_Y + 42
    for _, tab in ipairs(Library.Tabs) do
        local Is_Current = tab == Library.Current_Tab
        local Tab_Pos = Vec2(Pos_X + 5, Tab_Y_Offset)
        local Tab_Size = Vec2(140, 32)

        tab.Bg_Alpha = Lerp(tab.Bg_Alpha, Is_Current and 1 or 0, 0.18)
        Update_Rounded_Box(tab.Background, Tab_Pos, Tab_Size, 4, Library.Palette.Hover, 0.88 * tab.Bg_Alpha, Is_Current or tab.Bg_Alpha > 0.02)
        Update_Rounded_Box(tab.Indicator, Vec2(Pos_X, Tab_Y_Offset + 8), Vec2(2, 16), 2, Library.Palette.Accent, 1, Is_Current)

        tab.Current_Color = Lerp_Color(tab.Current_Color, Is_Current and Library.Palette.Text or Library.Palette.Sub_Text, 0.15)
        tab.Current_Icon_Color = Lerp_Color(tab.Current_Icon_Color, Is_Current and Library.Palette.Accent or Library.Palette.Sub_Text, 0.15)
        tab.Icon_Draw.Visible = false
        tab.Label.Visible = true
        tab.Label.Position = Vec2(Pos_X + 17, Tab_Y_Offset + 8)

        tab.Label.Color = tab.Current_Color
        Tab_Y_Offset = Tab_Y_Offset + 36

        if not Is_Current then
            Hide_Tab_Content(tab)
        end

        if Is_Current then
            local Col_Width = (Size_X - 150 - 30) / 2
            local Left_Y, Right_Y = Pos_Y + 46, Pos_Y + 46

            for _, section in ipairs(tab.Sections) do
                local Section_X = section.Side == "Left" and (Pos_X + 160) or (Pos_X + 160 + Col_Width + 10)
                local Section_Y = section.Side == "Left" and Left_Y or Right_Y
                local Item_Y = Section_Y + 32

                for _, item in ipairs(section.Items) do
                    item:Update(Section_X + 8, Item_Y, Col_Width - 16)
                    Item_Y = Item_Y + item.Height
                end

                section:Update_Container(Section_X, Section_Y, Col_Width, Item_Y - Section_Y + 6)

                if section.Side == "Left" then
                    Left_Y = Item_Y + 16
                else
                    Right_Y = Item_Y + 16
                end
            end
        else
            for _, section in ipairs(tab.Sections) do
                Set_Visible(section.Outline, false)
                Set_Visible(section.Background, false)
                Hide_Stripe_Pattern(section.Pattern_Back)
                Hide_Stripe_Pattern(section.Pattern_Front)
                section.Title.Visible = false
                section.Line.Visible = false
                for _, item in ipairs(section.Items) do
                    if item.Label then item.Label.Visible = false end
                    if item.Value_Label then item.Value_Label.Visible = false end
                    if item.Icon then Update_Keybind_Image_Icon(item.Icon, Vec2(-1000, -1000), Library.Palette.Text, false) end
                    if item.Icon_Draw then item.Icon_Draw.Visible = false end
                    if item.Box_Stroke then Set_Visible(item.Box_Stroke, false) end
                    if item.Box then Set_Visible(item.Box, false) end
                    if item.Fill then Set_Visible(item.Fill, false) end
                    if item.Stroke then Set_Visible(item.Stroke, false) end
                    if item.Background then Set_Visible(item.Background, false) end
                    if item.Knob then Set_Visible(item.Knob, false) end
                    if item.List_Stroke then Set_Visible(item.List_Stroke, false) end
                    if item.List_Background then Set_Visible(item.List_Background, false) end
                    if item.Button_Stroke then Set_Visible(item.Button_Stroke, false) end
                    if item.Button_Box then Set_Visible(item.Button_Box, false) end
                    if item.Option_Drawings then
                        for _, Option_Drawing in pairs(item.Option_Drawings) do
                            Option_Drawing.Visible = false
                        end
                    end
                    if item.Preview_Stroke then Set_Visible(item.Preview_Stroke, false) end
                    if item.Preview then Set_Visible(item.Preview, false) end
                    if item.Popup_Stroke then Set_Visible(item.Popup_Stroke, false) end
                    if item.Popup_Background then Set_Visible(item.Popup_Background, false) end
                    if item.Sv_Stroke then Set_Visible(item.Sv_Stroke, false) end
                    if item.Hue_Stroke then Set_Visible(item.Hue_Stroke, false) end
                    if item.Alpha_Stroke then Set_Visible(item.Alpha_Stroke, false) end
                    if item.Sv_Grid then Hide_Grid_Squares(item.Sv_Grid) end
                    if item.Hue_Grid then Hide_Grid_Squares(item.Hue_Grid) end
                    if item.Alpha_Grid then Hide_Grid_Squares(item.Alpha_Grid) end
                    if item.Info_Hex then item.Info_Hex.Visible = false end
                    if item.Info_Rgb then item.Info_Rgb.Visible = false end
                    if item.Info_Alpha then item.Info_Alpha.Visible = false end
                    if item.Cursor_Outer then item.Cursor_Outer.Visible = false end
                    if item.Cursor_Inner then item.Cursor_Inner.Visible = false end
                    if item.Hue_Line then item.Hue_Line.Visible = false end
                    if item.Alpha_Line then item.Alpha_Line.Visible = false end
                end
            end
        end
    end
end)

local function Reset_Runtime_State()
    Runtime_State.Last_Parry = 0
    Runtime_State.Target = nil
    Runtime_State.Trajectory_Cache = {}
    Runtime_State.Ping_History = {}
    Runtime_State.Spam_Expiration = 0
    Runtime_State.Spam_Mode_Active = false
    Runtime_State.Consecutive_Parries = 0
    Runtime_State.Spam_Cooldown = 0
    Runtime_State.Scheduled_Trigger = 0
    Runtime_State.Aerodynamic_Active = false
    Runtime_State.Aerodynamic_Time = 0
    Runtime_State.Last_Ball_Spawn = 0
    Runtime_State.Target_Speed = 0
    Runtime_State.Target_Distance = 0
    Runtime_State.Target_Dot = 0
end

Reset_Runtime_State()

local function Magnitude(v)
    return v and math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z) or 0
end

local function Distance(a, b)
    return a and b and Magnitude(a - b) or 0
end

local function Normalize(v)
    local m = Magnitude(v)
    if m <= 0 then
        return Vector3.zero
    end
    return Vector3.new(v.X / m, v.Y / m, v.Z / m)
end

local function Dot(a, b)
    return a and b and (a.X * b.X + a.Y * b.Y + a.Z * b.Z) or 0
end

local function Flatten(v)
    return v and Vector3.new(v.X, 0, v.Z) or Vector3.zero
end

local function Get_Raw_Ping()
    local Current_Ping = 60
    pcall(function()
        local network = Stats_Service:Find_First_Child("Network")
        local stats = network and network:Find_First_Child("Server_Stats_Item")
        local Ping_Obj = stats and stats:Find_First_Child("Data Ping")
        if Ping_Obj then
            if memory_read and Ping_Obj.Address then
                local ok, value = pcall(function()
                    return memory_read("double", Ping_Obj.Address + 0xC8)
                end)
                if ok and type(value) == "number" and value > 0 then
                    Current_Ping = value
                else
                    Current_Ping = tonumber(Ping_Obj.Value) or Current_Ping
                end
            else
                Current_Ping = tonumber(Ping_Obj.Value) or Current_Ping
            end
        end
    end)
    return math.min(Current_Ping, 650)
end

local function Is_Targeting_Me(Target_Name)
    local character = Local_Player.Character
    if character and character:Find_First_Child("Highlight") then
        return true
    end
    if not Target_Name then
        return false
    end
    local My_Name = string.lower(Local_Player.Name or "")
    local My_Display = string.lower(Local_Player.Display_Name or Local_Player.Name or "")
    local target = string.lower(tostring(Target_Name))
    if target == My_Name or target == My_Display then
        return true
    end
    local clean = string.gsub(target, '%.%.%.$', '')
    if #clean >= 3 then
        if string.sub(My_Name, 1, #clean) == clean or string.sub(My_Display, 1, #clean) == clean then
            return true
        end
        if string.find(My_Name, clean, 1, true) or string.find(My_Display, clean, 1, true) then
            return true
        end
    end
    return false
end

local function Scan_Nearest_Entity(Player_Position)
    local nearest, Nearest_Distance = nil, math.huge
    for _, plr in ipairs(Players:Get_Players()) do
        if plr ~= Local_Player and plr.Character then
            local root = plr.Character:Find_First_Child("Humanoid_Root_Part") or plr.Character.Primary_Part
            local humanoid = plr.Character:Find_First_Child("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local dist = Distance(Player_Position, root.Position)
                if dist < Nearest_Distance then
                    Nearest_Distance = dist
                    nearest = plr
                end
            end
        end
    end
    return nearest, Nearest_Distance
end

local function Check_Is_Spam(params)
    local Ping_Scaled = params.Ping / 10
    local range = Ping_Scaled + math.min(params.Speed / 6.5, 95)
    if params.Entity_Distance > range then
        return false, params.Parries
    end
    if params.Ball_Distance > range then
        return false, params.Parries
    end
    local Max_Speed = 5.0 - math.min(params.Speed / 5.0, 5.0)
    local Max_Dot = math.clamp(params.Dot or 0, -1, 0) * Max_Speed
    local accuracy = math.min(range - Max_Dot, 30)
    if params.Ball_Distance <= accuracy and params.Parries >= 5 then
        return true, params.Parries
    end
    return false, params.Parries
end

local function Analyze_Trajectory(Ball_Position, Ball_Velocity, Player_Position)
    local To_Player = Flatten(Player_Position - Ball_Position)
    local Vel_Flat = Flatten(Ball_Velocity)
    local Dir_To_Player = Normalize(To_Player)
    local Vel_Dir = Normalize(Vel_Flat)
    local Current_Dot = Dot(Dir_To_Player, Vel_Dir)
    if Current_Dot ~= Current_Dot then
        Current_Dot = 1
    end
    table.insert(Auto_Runtime.Curve_History, Vel_Flat)
    if #Auto_Runtime.Curve_History > 8 then
        table.remove(Auto_Runtime.Curve_History, 1)
    end
    local Angular_Deviation = 0
    if #Auto_Runtime.Curve_History >= 4 then
        for i = 2, #Auto_Runtime.Curve_History do
            local prev = Normalize(Auto_Runtime.Curve_History[i - 1])
            local curr = Normalize(Auto_Runtime.Curve_History[i])
            local Velocity_Dot = math.clamp(Dot(prev, curr), -1, 1)
            local angle = math.deg(math.acos(Velocity_Dot))
            if angle ~= angle then
                angle = 0
            end
            local Dynamic_Threshold = math.clamp(40 / math.max(Magnitude(Ball_Velocity), 1), 1.0, 3.0)
            if angle > Dynamic_Threshold then
                Angular_Deviation = Angular_Deviation + (angle / Dynamic_Threshold)
            end
        end
    end
    local Is_Curving = Angular_Deviation > 3 and Current_Dot < 0.5
    if Current_Dot < -0.1 then
        Is_Curving = true
    end
    return Current_Dot, Is_Curving
end

local function Detect_Warp(Ball_Position, dt)
    if dt <= 0 then
        return false
    end
    if Auto_Runtime.Last_Ball_Pos == Vector3.zero then
        return false
    end
    local Vel_Mag = Magnitude(Auto_Runtime.Last_Ball_Vel)
    if Vel_Mag < 3 then
        return false
    end
    local expected = Auto_Runtime.Last_Ball_Pos + (Auto_Runtime.Last_Ball_Vel * dt)
    local deviation = Distance(Ball_Position, expected)
    return deviation > 3.0
end

local function Get_Parry_Threshold(Ball_Position, Ball_Velocity, Ball_Speed, Player_Position, ping, dt)
    local Capped_Speed = math.min(Ball_Speed, Config.Capped_Speed)
    local Dot_Value, Is_Curving = Analyze_Trajectory(Ball_Position, Ball_Velocity, Player_Position)
    Runtime_State.Target_Dot = Dot_Value
    local Speed_Diff = math.min(math.max(Capped_Speed - 9.5, 0), Config.Capped_Speed)
    local divisor = (Config.Speed_Divisor_Base + (Speed_Diff * Config.Speed_Divisor_Multiplier)) * Config.Speed_Division_Factor
    local Speed_Contribution = math.max(Capped_Speed / math.max(divisor, 0.01), 9.5)
    
    local Ping_Max = ping
    local Ping_Min = ping
    for _, p in ipairs(Auto_Runtime.Ping_History) do
        if p > Ping_Max then Ping_Max = p end
        if p < Ping_Min then Ping_Min = p end
    end
    
    local Ping_Jitter = Ping_Max - Ping_Min
    local Jitter_Buffer = 0
    if Ping_Jitter > 20 then
        Jitter_Buffer = (Ping_Jitter / 10) * Config.Ping_Multiplier * 1.5
    end

    local Frame_Lag_Buffer = 0
    if dt > 0.03 then
        Frame_Lag_Buffer = Ball_Speed * dt * 0.8
    end

    local Base_Threshold = (ping / 10) * Config.Ping_Multiplier + Speed_Contribution + Jitter_Buffer + Frame_Lag_Buffer

    Base_Threshold = math.max(Base_Threshold, Config.Base_Min_Parry_Accuracy)
    if Detect_Warp(Ball_Position, dt) then
        Auto_Runtime.Warp_Detected_At = tick()
    end
    local Time_Since_Warp = tick() - Auto_Runtime.Warp_Detected_At
    if Time_Since_Warp < 0.55 then
        Base_Threshold = Base_Threshold + (6.0 * (1 - (Time_Since_Warp / 0.55)))
    end
    local Ball_Distance = Distance(Player_Position, Ball_Position)
    if Config.Dot_Protect and Dot_Value <= Config.Dot_Threshold and Capped_Speed >= Config.Dot_Min_Speed and Ball_Distance <= Config.Dot_Distance_Threshold then
        local Angle_Factor = 1 - (Dot_Value / math.max(Config.Dot_Threshold, 0.001))
        local Dot_Limit = (ping / 10) + Ball_Distance * 0.8 + Angle_Factor * 10
        Base_Threshold = math.min(Base_Threshold, math.max(Dot_Limit, 55))
    end
    if Is_Curving then
        local Distance_Slice = math.clamp(Ball_Distance * 0.5, 15, 35)
        Base_Threshold = math.max(Base_Threshold - Distance_Slice, 10)
        if Dot_Value < -0.1 then
            Base_Threshold = Base_Threshold + 15
        end
    end
    return Base_Threshold, Dot_Value, Is_Curving
end

local function Execute_Parry_Action(Is_Lobby, Ball_Dot, Is_Curving)
    Do_Click()
end

local function Get_Best_Ball()
    local Best_Ball = nil
    local folders = {Workspace:Find_First_Child("Balls"), Workspace:Find_First_Child("Training_Balls")}
    for F_Idx, folder in ipairs(folders) do
        if folder then
            for _, ball in ipairs(folder:Get_Children()) do
                if ball:Get_Attribute("Real_Ball") or F_Idx == 2 then
                    Best_Ball = ball
                    break
                end
            end
        end
        if Best_Ball then
            break
        end
    end
    return Best_Ball
end

Run_Service.Heartbeat:Connect(function(dt)
    dt = dt or 0.016
    local character = Local_Player.Character
    local root = character and character:Find_First_Child("Humanoid_Root_Part")
    local humanoid = character and character:Find_First_Child("Humanoid")
    
    if not root or not humanoid or humanoid.Health <= 0 then
        Auto_Runtime.Auto_Spam = false
        Auto_Runtime.Curve_History = {}
        Auto_Runtime.Parried = false
        Auto_Runtime.Trigger_Parried = false
        Runtime_State.Target_Speed = 0
        Runtime_State.Target_Distance = 0
        Runtime_State.Target_Dot = 0
        return
    end

    local ball = Get_Best_Ball()
    Auto_Runtime.Ball = ball
    if not ball then
        Auto_Runtime.Auto_Spam = false
        Auto_Runtime.Parries = 0
        Auto_Runtime.Cooldown = false
        Auto_Runtime.Last_Target = nil
        Auto_Runtime.Curve_History = {}
        Runtime_State.Target_Speed = 0
        Runtime_State.Target_Distance = 0
        Runtime_State.Target_Dot = 0
        return
    end

    local Player_Pos = root.Position
    local Predicted_Player_Pos = Player_Pos
    local Ball_Pos = ball.Position
    local Ball_Vel = ball.Assembly_Linear_Velocity
    local Ball_Speed = Magnitude(Ball_Vel)
    local Target_Name = ball:Get_Attribute("target")
    local Targeting_Me = Is_Targeting_Me(Target_Name)
    local Is_Training_Ball = ball:Is_Descendant_Of(Workspace:Find_First_Child("Training_Balls"))
    
    local ping = Get_Raw_Ping()
    table.insert(Auto_Runtime.Ping_History, ping)
    while #Auto_Runtime.Ping_History > math.max(5, math.floor(Config.Ping_Sample_Count)) do
        table.remove(Auto_Runtime.Ping_History, 1)
    end

    Runtime_State.Target_Speed = Ball_Speed
    Runtime_State.Target_Distance = Distance(Predicted_Player_Pos, Ball_Pos)

    if Target_Name ~= Auto_Runtime.Last_Target then
        Auto_Runtime.Cooldown = false
        local Delta_Change = tick() - (Auto_Runtime.Last_Target_Change or 0)
        if Delta_Change <= 0.35 then
            Auto_Runtime.Parries = Auto_Runtime.Parries + 1
        else
            Auto_Runtime.Parries = 1
            Auto_Runtime.Auto_Spam = false
        end
        Auto_Runtime.Last_Target = Target_Name
        Auto_Runtime.Last_Target_Change = tick()
        Auto_Runtime.Curve_History = {}
    end

    local _, Nearest_Distance = Scan_Nearest_Entity(Predicted_Player_Pos)
    local threshold, Dot_Value, Is_Curving = Get_Parry_Threshold(Ball_Pos, Ball_Vel, Ball_Speed, Predicted_Player_Pos, ping, dt)
    Runtime_State.Target_Dot = Dot_Value

    local Spam_Params = {
        Speed = Ball_Speed,
        Parries = Auto_Runtime.Parries,
        Ball_Distance = Runtime_State.Target_Distance,
        Entity_Distance = Nearest_Distance,
        Dot = Dot_Value,
        Ping = ping
    }
    
    if Targeting_Me and Config.Auto_Spam then
        Auto_Runtime.Auto_Spam = Check_Is_Spam(Spam_Params)
    else
        Auto_Runtime.Auto_Spam = false
    end

    local Valid_Target = Targeting_Me or (Config.Lobby_Parry and Is_Training_Ball)
    local Can_Auto_Parry = Config.Auto_Parry or Config.Lobby_Parry
    
    if Can_Auto_Parry then
        if Valid_Target then
            local Since_Spawn = tick() - Runtime_State.Last_Ball_Spawn
            if not Config.No_Click_On_Ball_Spawn or Since_Spawn > 0.12 then
                if Runtime_State.Target_Distance <= threshold and Ball_Speed >= Config.Min_Threat_Speed then
                    if not Auto_Runtime.Parried then
                        Auto_Runtime.Parried = true
                        Execute_Parry_Action(Config.Lobby_Parry and Is_Training_Ball and not Config.Auto_Parry, Dot_Value, Is_Curving)
                    end
                end
            end
        else
            Auto_Runtime.Parried = false
        end
    end

    if Config.Triggerbot_Enabled then
        if Targeting_Me then
            if Runtime_State.Target_Distance <= math.max(8, threshold * 0.35) then
                if not Auto_Runtime.Trigger_Parried then
                    if tick() - Auto_Runtime.Last_Parry_At >= math.max(0.02, Config.Parry_Cooldown) then
                        Auto_Runtime.Trigger_Parried = true
                        Auto_Runtime.Last_Parry_At = tick()
                        Execute_Parry_Action(false, Dot_Value, Is_Curving)
                    end
                end
            end
        else
            Auto_Runtime.Trigger_Parried = false
        end
    end

    Auto_Runtime.Last_Ball_Pos = Ball_Pos
    Auto_Runtime.Last_Ball_Vel = Ball_Vel
    Auto_Runtime.Last_Ball_Speed = Ball_Speed
end)

Run_Service.Heartbeat:Connect(function()
    local folders = {Workspace:Find_First_Child("Balls"), Workspace:Find_First_Child("Training_Balls")}
    local Real_Ball_Found = false
    for F_Idx, folder in ipairs(folders) do
        if folder then
            for _, ball in ipairs(folder:Get_Children()) do
                if ball:Get_Attribute("Real_Ball") or F_Idx == 2 then
                    Real_Ball_Found = true
                    break
                end
            end
        end
        if Real_Ball_Found then
            break
        end
    end
    if Real_Ball_Found and Runtime_State.Last_Ball_Spawn <= 0 then
        Runtime_State.Last_Ball_Spawn = tick()
    elseif not Real_Ball_Found then
        Runtime_State.Last_Ball_Spawn = tick()
    end
end)
