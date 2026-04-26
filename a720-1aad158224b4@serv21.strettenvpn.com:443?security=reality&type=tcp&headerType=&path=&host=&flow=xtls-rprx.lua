--!native
--!strict
--!optimize 2
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StatsService = game:GetService("Stats")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local FastFloor = math.floor
local FastMax = math.max
local FastClamp = math.clamp
local FastClock = os.clock
local FastTick = tick


if _G.MoonshadeDrawings then
    for _, drawing in pairs(_G.MoonshadeDrawings) do
        pcall(function()
            drawing:Remove()
        end)
    end
end

_G.MoonshadeDrawings = {}
_G.MoonshadeActive = true

local KeyCodes = {
    [1] = "LMB",[2] = "RMB",[3] = "MMB",[4] = "MB4",[5] = "MB5",
    [8] = "Backspace",[9] = "Tab",[13] = "Enter",[16] = "Shift",[17] = "Ctrl",[18] = "Alt",[20] = "CapsLock",[27] = "Esc",[32] = "Space",
    [33] = "PageUp",[34] = "PageDown",[35] = "End",[36] = "Home",[37] = "Left",[38] = "Up",[39] = "Right",[40] = "Down",[45] = "Insert",[46] = "Delete",
    [48] = "0",[49] = "1",[50] = "2",[51] = "3",[52] = "4",[53] = "5",[54] = "6",[55] = "7",[56] = "8",[57] = "9",
    [65] = "A",[66] = "B",[67] = "C",[68] = "D",[69] = "E",[70] = "F",[71] = "G",[72] = "H",[73] = "I",[74] = "J",[75] = "K",[76] = "L",
    [77] = "M",[78] = "N",[79] = "O",[80] = "P",[81] = "Q",[82] = "R",[83] = "S",[84] = "T",[85] = "U",[86] = "V",[87] = "W",[88] = "X",[89] = "Y",[90] = "Z",
    [96] = "Num0",[97] = "Num1",[98] = "Num2",[99] = "Num3",[100] = "Num4",[101] = "Num5",[102] = "Num6",[103] = "Num7",[104] = "Num8",[105] = "Num9",
    [106] = "Multiply",[107] = "Add",[109] = "Subtract",[110] = "Decimal",[111] = "Divide",
    [112] = "F1",[113] = "F2",[114] = "F3",[115] = "F4",[116] = "F5",[117] = "F6",[118] = "F7",[119] = "F8",[120] = "F9",[121] = "F10",[122] = "F11",[123] = "F12",
    [160] = "LShift",[161] = "RShift",[162] = "LCtrl",[163] = "RCtrl",[164] = "LAlt",[165] = "RAlt",[186] = ";",[187] = "=",[188] = ",",[189] = "-",[190] = ".",[191] = "/",[192] = "`",[219] = "[",[220] = "\\",[221] = "]",[222] = "'"
}

local ShiftModifiers = {
    ["1"] = "!",["2"] = "@",["3"] = "#",["4"] = "$",["5"] = "%",["6"] = "^",["7"] = "&",["8"] = "*",["9"] = "(",["0"] = ")",
    ["-"] = "_",["="] = "+",["`"] = "~",["["] = "{",["]"] = "}",["\\"] = "|",[";"] = ":",["'"] = "\"",[","] = "<",["."] = ">",["/"] = "?"
}

local Config = {
    AutoParry = false,
    AutoSpam = false,
    LobbyParry = false,
    TriggerbotEnabled = false,
    NoClickOnBallSpawn = true,
    DotProtect = true,
    MinThreatSpeed = 5,
    ParryCooldown = 0,
    PingMultiplier = 1.0,
    SpeedDivisorBase = 2.4,
    SpeedDivisorMultiplier = 0.002,
    CappedSpeed = 9999,
    SpeedDivisionFactor = 1.1,
    PingSampleCount = 50,
    DotMinSpeed = 100.0,
    DotThreshold = 0.820,
    DotDistanceThreshold = 30.0,
    BaseMinParryAccuracy = 25.0,
    ParryKeybind = "None",
    SpamKeybind = "None",
    TriggerbotKeybind = "None",
    AutoCurveKeybind = "None",
    HideKeybind = "Esc",
    ParryMethod = "Click",
    RenderBallStats = false,
    AutoCurve = false,
    AutoCurveMode = "High",
    CameraSens = 0.50,
    ParryBindMode = "Toggle",
    SpamBindMode = "Toggle",
    TriggerbotBindMode = "Toggle",
    AutoCurveBindMode = "Toggle",
    ShowHotkeyList = true,
    AutoSave = true,
    AutoLoad = true,
    ThemePreset = "Nightfall",
    ConfigName = "default",
    SelectedConfig = "default",
    SaveConfigAction = false,
    LoadConfigAction = false
}

local RuntimeState = {
    LastParry = 0,
    Target = nil,
    TrajectoryCache = {},
    PingHistory = {},
    SpamExpiration = 0,
    SpamModeActive = false,
    ConsecutiveParries = 0,
    SpamCooldown = 0,
    ScheduledTrigger = 0,
    IsExecutingParry = false,
    AerodynamicActive = false,
    AerodynamicTime = 0,
    LastBallSpawn = 0,
    TargetSpeed = 0,
    TargetDistance = 0,
    TargetDot = 0
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

local function LerpColor(c1, c2, t)
    if not c1 or not c2 then
        return Color3.new(1, 1, 1)
    end
    return Color3.new(Lerp(c1.R, c2.R, t), Lerp(c1.G, c2.G, t), Lerp(c1.B, c2.B, t))
end

local function SnapValue(val, step)
    return step and math.floor((val / step) + 0.5) * step or val
end

local function HSVToColor3(h, s, v)
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

local function Color3ToHSV(color)
    if not color then
        return 0, 0, 1
    end
    local ok, h, s, v = pcall(function()
        return color:ToHSV()
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

local function Color3ToHex(color)
    if not color then
        return "#FFFFFF"
    end
    return string.format("#%02X%02X%02X", Clamp(Round(color.R * 255), 0, 255), Clamp(Round(color.G * 255), 0, 255), Clamp(Round(color.B * 255), 0, 255))
end

local CreateDrawing

local function CreateGridSquares(count)
    local grid = {}
    for i = 1, count do
        grid[i] = CreateDrawing("Square", {Filled = true, Transparency = 1, Visible = false})
    end
    return grid
end

local function UpdateGridSquares(grid, cols, rows, x, y, w, h, colorFunc, visible)
    if not visible or w <= 0 or h <= 0 then
        for _, sq in ipairs(grid) do
            sq.Visible = false
        end
        return
    end
    local cellW = w / cols
    local cellH = h / rows
    local idx = 1
    for row = 1, rows do
        for col = 1, cols do
            local sq = grid[idx]
            idx = idx + 1
            local x0 = x + ((col - 1) * cellW)
            local y0 = y + ((row - 1) * cellH)
            local x1 = x + (col * cellW)
            local y1 = y + (row * cellH)
            sq.Visible = true
            sq.Position = Vec2(x0, y0)
            sq.Size = Vec2(math.max(1, Round(x1 - x0)), math.max(1, Round(y1 - y0)))
            sq.Color = colorFunc(col, row, cols, rows)
            sq.Transparency = 1
        end
    end
end

local function HideGridSquares(grid)
    for _, sq in ipairs(grid) do
        sq.Visible = false
    end
end

local function GetStepDecimals(step)
    if type(step) ~= "number" then
        return 0
    end
    local s = string.format("%.10f", step):gsub("0+$", "")
    local dot = s:find("%.")
    return dot and (#s - dot) or 0
end

local function FormatSliderValue(value, step)
    if type(value) ~= "number" then
        return tostring(value)
    end
    local decimals = GetStepDecimals(step)
    if decimals <= 0 then
        return tostring(math.floor(value + 0.5))
    end
    local formatted = string.format("%." .. decimals .. "f", value)
    formatted = formatted:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    return formatted
end

local function ParseSliderInput(textValue)
    local cleaned = tostring(textValue or ""):gsub(",", "."):gsub("[^%d%.%-]", "")
    if cleaned == "" or cleaned == "-" or cleaned == "." or cleaned == "-." then
        return nil
    end
    local number = tonumber(cleaned)
    if number == nil then
        return nil
    end
    return number
end

local function ClampSliderValue(value, min, max, step)
    local clamped = Clamp(value, min, max)
    local snapped = SnapValue(clamped, step)
    return Clamp(snapped, min, max)
end

local function CommitSliderInput(slider)
    if not slider then
        return
    end
    local parsed = ParseSliderInput(slider.InputBuffer)
    if parsed == nil then
        slider.InputBuffer = FormatSliderValue(Config[slider.Flag], slider.Step)
        return
    end
    local finalValue = ClampSliderValue(parsed, slider.Min, slider.Max, slider.Step)
    Config[slider.Flag] = finalValue
    slider.InputBuffer = FormatSliderValue(finalValue, slider.Step)
    QueueSaveConfig()
end

local function NormalizeKeybindValue(value)
    if type(value) == "number" then
        return KeyCodes[value] or tostring(value)
    end
    if value == nil or value == "" then
        return "None"
    end
    return tostring(value)
end

local function NormalizeBindMode(mode)
    mode = tostring(mode or "Toggle")
    if string.lower(mode) == "hold" then
        return "Hold"
    end
    return "Toggle"
end

local function GetModeFlagFromBindFlag(bindFlag)
    if bindFlag == "ParryKeybind" then
        return "ParryBindMode"
    elseif bindFlag == "SpamKeybind" then
        return "SpamBindMode"
    elseif bindFlag == "TriggerbotKeybind" then
        return "TriggerbotBindMode"
    elseif bindFlag == "AutoCurveKeybind" then
        return "AutoCurveBindMode"
    end
end

local function GetToggleFlagFromBindFlag(bindFlag)
    if bindFlag == "ParryKeybind" then
        return "AutoParry"
    elseif bindFlag == "SpamKeybind" then
        return "AutoSpam"
    elseif bindFlag == "TriggerbotKeybind" then
        return "TriggerbotEnabled"
    elseif bindFlag == "AutoCurveKeybind" then
        return "AutoCurve"
    end
end

local function SetBindMode(bindFlag, mode)
    local modeFlag = GetModeFlagFromBindFlag(bindFlag)
    if modeFlag then
        Config[modeFlag] = NormalizeBindMode(mode)
    end
end

local function GetBindMode(bindFlag)
    local modeFlag = GetModeFlagFromBindFlag(bindFlag)
    return NormalizeBindMode(modeFlag and Config[modeFlag] or "Toggle")
end

local function SetBindTargetState(bindFlag, state)
    local toggleFlag = GetToggleFlagFromBindFlag(bindFlag)
    if toggleFlag then
        Config[toggleFlag] = state and true or false
    end
end

local function HandleBindPress(bindFlag)
    if NormalizeKeybindValue(Config[bindFlag]) == "None" then
        return
    end
    if GetBindMode(bindFlag) == "Hold" then
        SetBindTargetState(bindFlag, true)
    else
        local toggleFlag = GetToggleFlagFromBindFlag(bindFlag)
        if toggleFlag then
            Config[toggleFlag] = not Config[toggleFlag]
        end
    end
end

local function HandleBindRelease(bindFlag)
    if NormalizeKeybindValue(Config[bindFlag]) == "None" then
        return
    end
    if GetBindMode(bindFlag) == "Hold" then
        SetBindTargetState(bindFlag, false)
    end
end

local function IsMouseInBounds(pos, boundsPos, boundsSize)
    return pos.X >= boundsPos.X and pos.X <= boundsPos.X + boundsSize.X and pos.Y >= boundsPos.Y and pos.Y <= boundsPos.Y + boundsSize.Y
end

CreateDrawing = function(className, properties)
    local drawing = Drawing.new(className)
    for propName, propValue in pairs(properties) do
        pcall(function()
            drawing[propName] = propValue
        end)
    end
    table.insert(_G.MoonshadeDrawings, drawing)
    return drawing
end

local function CreateKeybindImageIcon(size)
    size = size or 18
    local function square()
        return CreateDrawing("Square", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, Visible = false})
    end
    local function circle()
        return CreateDrawing("Circle", {Filled = true, Color = Color3.new(1, 1, 1), Transparency = 1, NumSides = 18, Radius = 1, Visible = false})
    end

    return {
        IsImage = false,
        Size = size,
        Parts = {
            Main = square(),
            Top = square(),
            Bottom = square(),
            Left = square(),
            Right = square(),
            TL = circle(),
            TR = circle(),
            BL = circle(),
            BR = circle(),
            Inner = square(),
            Dot1 = circle(),
            Dot2 = circle(),
            Dot3 = circle(),
            Keys = {square(), square(), square(), square(), square(), square()}
        }
    }
end

local function UpdateKeybindImageIcon(icon, position, color, visible)
    if not icon then
        return
    end
    if icon.IsImage and icon.Image then
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
    local outline = {parts.Main, parts.Top, parts.Bottom, parts.Left, parts.Right, parts.TL, parts.TR, parts.BL, parts.BR}
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

        parts.TL.Position = Vec2(x + radius, y + radius)
        parts.TR.Position = Vec2(x + w - radius, y + radius)
        parts.BL.Position = Vec2(x + radius, y + h - radius)
        parts.BR.Position = Vec2(x + w - radius, y + h - radius)
        parts.TL.Radius = radius
        parts.TR.Radius = radius
        parts.BL.Radius = radius
        parts.BR.Radius = radius
    end

    local innerPad = stroke + 1
    parts.Inner.Visible = visible
    if visible then
        parts.Inner.Position = Vec2(x + innerPad, y + innerPad)
        parts.Inner.Size = Vec2(math.max(w - innerPad * 2, 1), math.max(h - innerPad * 2, 1))
        parts.Inner.Color = Color3.fromRGB(16, 20, 30)
        parts.Inner.Transparency = 1
    end

    local dotRadius = math.max(1, math.floor(size * 0.05 + 0.5))
    local dotGap = math.max(3, math.floor(size * 0.13 + 0.5))
    local dotStartX = x + innerPad + dotRadius + 1
    local dotY = y + innerPad + dotRadius + 1
    local dots = {parts.Dot1, parts.Dot2, parts.Dot3}
    for i, dot in ipairs(dots) do
        dot.Visible = visible
        if visible then
            dot.Position = Vec2(dotStartX + (i - 1) * dotGap, dotY)
            dot.Radius = dotRadius
            dot.Color = color
            dot.Transparency = 1
        end
    end

    local keyPadX = math.max(3, math.floor(size * 0.14 + 0.5))
    local keyPadY = math.max(5, math.floor(size * 0.24 + 0.5))
    local keyGap = math.max(1, math.floor(size * 0.06 + 0.5))
    local availableW = math.max(w - keyPadX * 2, 6)
    local availableH = math.max(h - keyPadY - innerPad - 1, 4)
    local keySize = math.max(2, math.floor(math.min((availableW - keyGap * 2) / 3, (availableH - keyGap) / 2) + 0.5))
    local totalKeysWidth = keySize * 3 + keyGap * 2
    local totalKeysHeight = keySize * 2 + keyGap
    local keysStartX = x + math.floor((w - totalKeysWidth) / 2 + 0.5)
    local keysStartY = y + h - innerPad - totalKeysHeight - 1

    for i, key in ipairs(parts.Keys) do
        key.Visible = visible
        if visible then
            local row = math.floor((i - 1) / 3)
            local col = (i - 1) % 3
            key.Position = Vec2(keysStartX + col * (keySize + keyGap), keysStartY + row * (keySize + keyGap))
            key.Size = Vec2(keySize, keySize)
            key.Color = color
            key.Transparency = 1
        end
    end
end

local function SetVisible(item, visible)
    if not item then
        return
    end
    if item.Main then
        item.Main.Visible = visible
        item.Top.Visible = visible
        item.Bottom.Visible = visible
        item.Left.Visible = visible
        item.Right.Visible = visible
        item.TL.Visible = visible
        item.TR.Visible = visible
        item.BL.Visible = visible
        item.BR.Visible = visible
    elseif item.IsImage or item.Fallback or item.Image then
        UpdateKeybindImageIcon(item, Vec2(-1000, -1000), Color3.new(1, 1, 1), visible)
    else
        item.Visible = visible
    end
end

local function SetRoundedColor(box, color, transparency)
    local list = {box.Main, box.Top, box.Bottom, box.Left, box.Right, box.TL, box.TR, box.BL, box.BR}
    for _, obj in ipairs(list) do
        obj.Color = color
        obj.Transparency = transparency or 1
    end
end

local function MakeRoundedBox(color, transparency)
    return {
        Main = CreateDrawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Top = CreateDrawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Bottom = CreateDrawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Left = CreateDrawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        Right = CreateDrawing("Square", {Filled = true, Color = color, Transparency = transparency or 1, Visible = false}),
        TL = CreateDrawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, NumSides = 18, Radius = 4, Visible = false}),
        TR = CreateDrawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, NumSides = 18, Radius = 4, Visible = false}),
        BL = CreateDrawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, NumSides = 18, Radius = 4, Visible = false}),
        BR = CreateDrawing("Circle", {Filled = true, Color = color, Transparency = transparency or 1, NumSides = 18, Radius = 4, Visible = false})
    }
end

local function UpdateRoundedBox(box, pos, size, radius, color, transparency, visible)
    radius = Clamp(radius or 4, 0, math.floor(math.min(size.X, size.Y) / 2))
    local x, y = pos.X, pos.Y
    local w, h = size.X, size.Y

    SetRoundedColor(box, color, transparency or 1)
    SetVisible(box, visible)

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

    box.TL.Position = Vec2(x + radius, y + radius)
    box.TR.Position = Vec2(x + w - radius, y + radius)
    box.BL.Position = Vec2(x + radius, y + h - radius)
    box.BR.Position = Vec2(x + w - radius, y + h - radius)
    box.TL.Radius = radius
    box.TR.Radius = radius
    box.BL.Radius = radius
    box.BR.Radius = radius
end

local function MakeGradientLine(count)
    local items = {}
    for i = 1, count do
        items[i] = CreateDrawing("Square", {Filled = true, Visible = false})
    end
    return items
end

local function UpdateGradientLine(items, pos, size, c1, c2, visible)
    local count = #items
    local segW = size.X / math.max(count, 1)
    for i = 1, count do
        local t = (i - 1) / math.max(count - 1, 1)
        local it = items[i]
        it.Visible = visible
        it.Color = LerpColor(c1, c2, t)
        it.Position = Vec2(pos.X + (i - 1) * segW, pos.Y)
        it.Size = Vec2(math.ceil(segW + 1), size.Y)
    end
end

local function HideGradientLine(items)
    for _, it in ipairs(items) do
        it.Visible = false
    end
end

local function MakeStripePattern(count, thickness)
    local items = {}
    for i = 1, count do
        items[i] = CreateDrawing("Line", {Thickness = thickness or 10, Transparency = 0.08, Visible = false})
    end
    return items
end

local function UpdateStripePattern(items, rectX, rectY, rectW, rectH, slant, spacing, color, visible)
    for _, line in ipairs(items) do
        line.Visible = false
    end
    if not visible or rectW <= 0 or rectH <= 0 then
        return
    end

    local left = rectX
    local right = rectX + rectW
    local top = rectY
    local bottom = rectY + rectH
    local startX = left - slant
    local totalWidth = rectW + slant
    local needed = math.ceil(totalWidth / spacing) + 3

    for i, line in ipairs(items) do
        if i > needed then
            break
        end

        local baseX = startX + ((i - 1) * spacing)
        local fromX = baseX
        local fromY = bottom
        local toX = baseX + slant
        local toY = top

        if toX < left or fromX > right then
            line.Visible = false
        else
            if fromX < left then
                local t = (left - fromX) / math.max(toX - fromX, 0.001)
                fromX = left
                fromY = bottom + (top - bottom) * t
            end

            if toX > right then
                local t = (right - fromX) / math.max(toX - fromX, 0.001)
                toX = right
                toY = fromY + (top - fromY) * t
            end

            if fromY < top then
                fromY = top
            elseif fromY > bottom then
                fromY = bottom
            end

            if toY < top then
                toY = top
            elseif toY > bottom then
                toY = bottom
            end

            if math.abs(toX - fromX) >= 1 and math.abs(fromY - toY) >= 1 then
                local t = (i - 1) / math.max(needed - 1, 1)
                line.Visible = true
                line.Color = color
                line.Transparency = math.max(0.05, 0.16 - (t * 0.10))
                line.From = Vec2(fromX, fromY)
                line.To = Vec2(toX, toY)
            else
                line.Visible = false
            end
        end
    end
end

local function HideStripePattern(items)
    for _, line in ipairs(items) do
        line.Visible = false
    end
end

local function GetContextMenuPosition(item)
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local menuW, menuH = 112, 56
    if not item or not item.ButtonPos or not item.ButtonSize then
        return Vec2(0, 0)
    end
    local contextX = item.ButtonPos.X
    local contextY = item.ButtonPos.Y + item.ButtonSize.Y + 6
    if contextX + menuW > viewport.X then
        contextX = item.ButtonPos.X + item.ButtonSize.X - menuW
    end
    if contextY + menuH > viewport.Y then
        contextY = item.ButtonPos.Y - menuH - 6
    end
    return Vec2(math.clamp(contextX, 0, viewport.X - menuW), math.clamp(contextY, 0, viewport.Y - menuH))
end

local function ClampWindowPosition(position, size)
    local camera = Workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    local x = math.clamp(position.X, 0, math.max(0, viewport.X - size.X))
    local y = math.clamp(position.Y, 0, math.max(0, viewport.Y - size.Y))
    return Vec2(x, y)
end

local Library = {
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
        Background = DefaultNightfallPalette.Background,
        Sidebar = DefaultNightfallPalette.Sidebar,
        Section = DefaultNightfallPalette.Section,
        Element = DefaultNightfallPalette.Element,
        Hover = DefaultNightfallPalette.Hover,
        Outline = DefaultNightfallPalette.Outline,
        OutlineLight = DefaultNightfallPalette.OutlineLight,
        Accent = DefaultNightfallPalette.Accent,
        Accent2 = DefaultNightfallPalette.Accent2,
        Text = DefaultNightfallPalette.Text,
        SubText = DefaultNightfallPalette.SubText
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

local PaletteKeys = {"Background", "Sidebar", "Section", "Element", "Hover", "Outline", "OutlineLight", "Accent", "Accent2", "Text", "SubText"}
local SaveConfigQueued = false
local IsConfigLoading = false
local GlobalSettingsPath = "Moonshade_Settings.json"

local function SaveGlobalSettings()
    if not writefile then
        return false
    end
    local data = {
        AutoSave = Config.AutoSave and true or false,
        AutoLoad = Config.AutoLoad and true or false,
        SelectedConfig = tostring(Config.SelectedConfig or Config.ConfigName or "default"),
        ConfigName = tostring(Config.ConfigName or Config.SelectedConfig or "default")
    }
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if ok then
        pcall(writefile, GlobalSettingsPath, encoded)
        return true
    end
    return false
end

local function LoadGlobalSettings()
    if not (isfile and readfile and isfile(GlobalSettingsPath)) then
        return false
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(GlobalSettingsPath))
    end)
    if ok and type(decoded) == "table" then
        if decoded.AutoSave ~= nil then Config.AutoSave = decoded.AutoSave and true or false end
        if decoded.AutoLoad ~= nil then Config.AutoLoad = decoded.AutoLoad and true or false end
        if type(decoded.SelectedConfig) == "string" and decoded.SelectedConfig ~= "" then Config.SelectedConfig = decoded.SelectedConfig end
        if type(decoded.ConfigName) == "string" and decoded.ConfigName ~= "" then Config.ConfigName = decoded.ConfigName end
        return true
    end
    return false
end

local function GetConfigBaseName()
    local name = tostring(Config.ConfigName or "default")
    name = name:gsub("[^%w%-%._]", "_")
    if name == "" then
        name = "default"
    end
    return name
end

local function GetConfigPath()
    return "Moonshade_" .. GetConfigBaseName() .. ".json"
end

local function GetLayoutPath()
    return "Moonshade_" .. GetConfigBaseName() .. "_layout.json"
end

local function GetAvailableConfigs()
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
    add(Config.SelectedConfig or Config.ConfigName or "default")
    add(Config.ConfigName or "default")
    if listfiles then
        local ok, files = pcall(listfiles, ".")
        if ok and type(files) == "table" then
            for _, filePath in ipairs(files) do
                local name = tostring(filePath):match("Moonshade_(.-)%.json$")
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

local function GetStripeBackColor()
    return LerpColor(Library.Palette.Accent, Library.Palette.Background, 0.55)
end

local function GetStripeFrontColor()
    return LerpColor(Library.Palette.Accent2, Library.Palette.Background, 0.45)
end

local function ApplyPalette(palette)
    if type(palette) ~= "table" then
        return
    end
    for _, key in ipairs(PaletteKeys) do
        if palette[key] then
            Library.Palette[key] = palette[key]
        end
    end
end

local function SyncThemeEditorState()
    if not Library or not Library.Tabs then
        return
    end
    for _, tab in ipairs(Library.Tabs) do
        if tab and tab.Sections then
            for _, section in ipairs(tab.Sections) do
                if section and section.Items then
                    for _, item in ipairs(section.Items) do
                        if item and item.Type == "ColorPicker" and item.Flag and type(Config[item.Flag]) == "table" and Config[item.Flag].Color then
                            local h, s, v = Color3ToHSV(Config[item.Flag].Color)
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

local function ApplyThemePreset(themeName, keepAccent)
    local preset = ThemePresets[themeName]
    if not preset then
        preset = ThemePresets.Nightfall
        themeName = "Nightfall"
    end
    local accent = Library.Palette.Accent
    local accent2 = Library.Palette.Accent2
    local accentAlpha = type(Config.UiAccentColor) == "table" and Clamp(Config.UiAccentColor.Alpha or 1, 0, 1) or 1
    local accent2Alpha = type(Config.UiAccent2Color) == "table" and Clamp(Config.UiAccent2Color.Alpha or 1, 0, 1) or 1
    ApplyPalette(preset)
    if keepAccent then
        Library.Palette.Accent = accent
        Library.Palette.Accent2 = accent2
    end
    Config.ThemePreset = themeName
    Config.UiAccentColor = {
        Color = Library.Palette.Accent,
        Alpha = accentAlpha
    }
    Config.UiAccent2Color = {
        Color = Library.Palette.Accent2,
        Alpha = accent2Alpha
    }
    SyncThemeEditorState()
    QueueSaveConfig()
end

QueueSaveConfig = function()
    SaveConfigQueued = true
end

local function SaveCurrentConfig()
    if not writefile then
        return false
    end
    local data = {}
    for key, value in pairs(Config) do
        local t = type(value)
        if key ~= "AutoSave" and key ~= "AutoLoad" and key ~= "SelectedConfig" and (t == "boolean" or t == "number" or t == "string") then
            data[key] = value
        end
    end
    data.ThemePreset = tostring(Config.ThemePreset or "Nightfall")
    data.UiAccentColor = {Hex = Color3ToHex(Library.Palette.Accent), Alpha = type(Config.UiAccentColor) == "table" and (Config.UiAccentColor.Alpha or 1) or 1}
    data.UiAccent2Color = {Hex = Color3ToHex(Library.Palette.Accent2), Alpha = type(Config.UiAccent2Color) == "table" and (Config.UiAccent2Color.Alpha or 1) or 1}
    data.ParryBindMode = NormalizeBindMode(Config.ParryBindMode)
    data.SpamBindMode = NormalizeBindMode(Config.SpamBindMode)
    data.TriggerbotBindMode = NormalizeBindMode(Config.TriggerbotBindMode)
    data.AutoCurveBindMode = NormalizeBindMode(Config.AutoCurveBindMode)
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if not ok then
        return false
    end
    local layout = {
        WindowX = Library.TargetPosition.X,
        WindowY = Library.TargetPosition.Y,
        HotkeysX = Library.HotkeysPosition.X,
        HotkeysY = Library.HotkeysPosition.Y,
        StatsX = Library.StatsPosition.X,
        StatsY = Library.StatsPosition.Y
    }
    local ok2, layoutEncoded = pcall(function()
        return HttpService:JSONEncode(layout)
    end)
    if not ok2 then
        return false
    end
    writefile(GetConfigPath(), encoded)
    writefile(GetLayoutPath(), layoutEncoded)
    Config.SelectedConfig = Config.ConfigName
    SaveGlobalSettings()
    SaveConfigQueued = false
    IsConfigLoading = false
    return true
end

local function DeleteNamedConfig(name)
    local target = tostring(name or "")
    target = target:gsub("[^%w%-%._]", "_")
    if target == "" then
        return false
    end
    local oldConfigName = Config.ConfigName
    Config.ConfigName = target
    local cfgPath = GetConfigPath()
    local layoutPath = GetLayoutPath()
    Config.ConfigName = oldConfigName
    local deleted = false
    if delfile then
        if isfile and isfile(cfgPath) then
            pcall(delfile, cfgPath)
            deleted = true
        end
        if isfile and isfile(layoutPath) then
            pcall(delfile, layoutPath)
        end
    end
    local available = GetAvailableConfigs()
    local fallback = available[1] or "default"
    if Config.SelectedConfig == target then
        Config.SelectedConfig = fallback
    end
    if Config.ConfigName == target then
        Config.ConfigName = fallback
    end
    SaveGlobalSettings()
    SaveConfigQueued = false
    return deleted
end

local function LoadNamedConfig(name)
    local oldName = Config.ConfigName
    IsConfigLoading = true
    if name and name ~= "" then
        Config.ConfigName = tostring(name)
    end
    local path = GetConfigPath()
    if not (isfile and readfile and isfile(path)) then
        Config.ConfigName = oldName
        IsConfigLoading = false
        return false
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok or type(decoded) ~= "table" then
        Config.ConfigName = oldName
        IsConfigLoading = false
        return false
    end
    for key, value in pairs(decoded) do
        if key ~= "UiAccentColor" and key ~= "UiAccent2Color" and key ~= "SelectedConfig" and key ~= "AutoSave" and key ~= "AutoLoad" and Config[key] ~= nil and type(value) ~= "table" then
            Config[key] = value
        end
    end
    if decoded.AutoLoadConfig ~= nil and decoded.AutoLoad == nil then
        Config.AutoLoad = decoded.AutoLoadConfig and true or false
    end
    Config.ParryBindMode = NormalizeBindMode(decoded.ParryBindMode or Config.ParryBindMode)
    Config.SpamBindMode = NormalizeBindMode(decoded.SpamBindMode or Config.SpamBindMode)
    Config.TriggerbotBindMode = NormalizeBindMode(decoded.TriggerbotBindMode or Config.TriggerbotBindMode)
    Config.AutoCurveBindMode = NormalizeBindMode(decoded.AutoCurveBindMode or Config.AutoCurveBindMode)
    ApplyThemePreset(decoded.ThemePreset or Config.ThemePreset or "Nightfall", false)
    if type(decoded.UiAccentColor) == "table" and decoded.UiAccentColor.Hex then
        local okAccent, accent = pcall(Color3.fromHex, decoded.UiAccentColor.Hex)
        if okAccent and accent then
            Library.Palette.Accent = accent
        end
    end
    if type(decoded.UiAccent2Color) == "table" and decoded.UiAccent2Color.Hex then
        local okAccent2, accent2 = pcall(Color3.fromHex, decoded.UiAccent2Color.Hex)
        if okAccent2 and accent2 then
            Library.Palette.Accent2 = accent2
        end
    end
    Config.UiAccentColor = {Color = Library.Palette.Accent, Alpha = type(decoded.UiAccentColor) == "table" and (decoded.UiAccentColor.Alpha or 1) or 1}
    Config.UiAccent2Color = {Color = Library.Palette.Accent2, Alpha = type(decoded.UiAccent2Color) == "table" and (decoded.UiAccent2Color.Alpha or 1) or 1}
    SyncThemeEditorState()
    local layoutPath = GetLayoutPath()
    if isfile and readfile and isfile(layoutPath) then
        local okLayout, layout = pcall(function()
            return HttpService:JSONDecode(readfile(layoutPath))
        end)
        if okLayout and type(layout) == "table" then
            if layout.WindowX and layout.WindowY then
                Library.Position = Vector2.new(layout.WindowX, layout.WindowY)
                Library.TargetPosition = Vector2.new(layout.WindowX, layout.WindowY)
            end
            if layout.HotkeysX and layout.HotkeysY then
                Library.HotkeysPosition = Vector2.new(layout.HotkeysX, layout.HotkeysY)
            end
            if layout.StatsX and layout.StatsY then
                Library.StatsPosition = Vector2.new(layout.StatsX, layout.StatsY)
            end
        end
    end
    Config.SelectedConfig = Config.ConfigName
    SaveGlobalSettings()
    SaveConfigQueued = false
    IsConfigLoading = false
    return true
end

LoadGlobalSettings()
if Config.AutoLoad then
    LoadNamedConfig(Config.SelectedConfig or Config.ConfigName)
else
    ApplyThemePreset(Config.ThemePreset or "Nightfall", false)
end

local WindowDrawings = {
    Shadow = MakeRoundedBox(Color3.new(0, 0, 0), 0.18),
    Outline = MakeRoundedBox(Library.Palette.Outline, 1),
    Background = MakeRoundedBox(Library.Palette.Background, 1),
    Topbar = MakeRoundedBox(Library.Palette.Sidebar, 1),
    Sidebar = MakeRoundedBox(Library.Palette.Sidebar, 1),
    Topline = MakeGradientLine(56),
    PatternBack = MakeStripePattern(72, 11),
    PatternFront = MakeStripePattern(72, 7),
    SidebarLine = CreateDrawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    TopBorder = CreateDrawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    Title = CreateDrawing("Text", {Text = "Nightfall | Recode", Color = Library.Palette.Text, Size = 13, Font = 2, Outline = true, Visible = false})
}

local StatsDrawings = {
    Outline = MakeRoundedBox(Library.Palette.Outline, 1),
    Background = MakeRoundedBox(Library.Palette.Background, 1),
    Topline = MakeGradientLine(44),
    HeaderLine = CreateDrawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    Row1 = MakeRoundedBox(Library.Palette.Element, 1),
    Row2 = MakeRoundedBox(Library.Palette.Element, 1),
    Row3 = MakeRoundedBox(Library.Palette.Element, 1),
    Title = CreateDrawing("Text", {Text = "BALL STATS", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Speed = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Distance = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Dot = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local KeybindsDrawings = {
    Outline = MakeRoundedBox(Library.Palette.Outline, 1),
    Background = MakeRoundedBox(Library.Palette.Background, 1),
    Topline = MakeGradientLine(44),
    HeaderLine = CreateDrawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false}),
    TitleIcon = CreateKeybindImageIcon(18),
    Title = CreateDrawing("Text", {Text = "HOTKEYS", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Subtitle = CreateDrawing("Text", {Text = "", Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Row1 = MakeRoundedBox(Library.Palette.Element, 1),
    Row2 = MakeRoundedBox(Library.Palette.Element, 1),
    Row3 = MakeRoundedBox(Library.Palette.Element, 1),
    Row4 = MakeRoundedBox(Library.Palette.Element, 1),
    Bind1 = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind2 = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind3 = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Bind4 = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    State1 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State2 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State3 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    State4 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
    Mode1 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode2 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode3 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    Mode4 = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
    MenuOutline = MakeRoundedBox(Library.Palette.Outline, 1),
    MenuBackground = MakeRoundedBox(Library.Palette.Background, 1),
    MenuOption1 = MakeRoundedBox(Library.Palette.Element, 1),
    MenuOption2 = MakeRoundedBox(Library.Palette.Element, 1),
    MenuOption1Text = CreateDrawing("Text", {Text = "Hold", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    MenuOption2Text = CreateDrawing("Text", {Text = "Toggle", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

function Library:CreateTab(tabName, tabIcon)
    local Tab = {
        Name = tabName,
        Icon = "",
        Sections = {},
        Background = MakeRoundedBox(self.Palette.Hover, 0.88),
        Label = CreateDrawing("Text", {Text = tabName, Size = 12, Font = 2, Outline = true, Visible = false}),
        IconDraw = CreateDrawing("Text", {Text = "", Size = 12, Font = 2, Outline = true, Visible = false}),
        Indicator = MakeRoundedBox(self.Palette.Accent, 1),
        CurrentColor = self.Palette.SubText,
        CurrentIconColor = self.Palette.SubText,
        BgAlpha = 0
    }

    function Tab:CreateSection(sectionName, sectionSide)
        local Section = {
            Name = sectionName,
            Side = sectionSide,
            Items = {},
            Outline = MakeRoundedBox(Library.Palette.Outline, 1),
            Background = MakeRoundedBox(Library.Palette.Section, 1),
            PatternBack = MakeStripePattern(40, 9),
            PatternFront = MakeStripePattern(40, 5),
            Title = CreateDrawing("Text", {Text = sectionName, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
            Line = CreateDrawing("Square", {Color = Library.Palette.Outline, Filled = true, Visible = false})
        }

        function Section:UpdateContainer(x, y, w, h)
            UpdateRoundedBox(self.Outline, Vec2(x, y), Vec2(w, h), 6, Library.Palette.Outline, 1, true)
            UpdateRoundedBox(self.Background, Vec2(x + 1, y + 1), Vec2(w - 2, h - 2), 6, Library.Palette.Section, 1, true)
            UpdateStripePattern(self.PatternBack, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
            UpdateStripePattern(self.PatternFront, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
            self.Title.Visible = true
            self.Title.Position = Vec2(x + 10, y + 6)
            self.Line.Visible = true
            self.Line.Position = Vec2(x + 10, y + 25)
            self.Line.Size = Vec2(w - 20, 1)
            self.Line.Color = Library.Palette.Outline
        end

        function Section:CreateToggle(name, flag, default)
            Config[flag] = Config[flag] ~= nil and Config[flag] or (default or false)
            local Toggle = {
                Type = "Toggle",
                Height = 24,
                Flag = flag,
                BoxStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                Box = MakeRoundedBox(Library.Palette.Element, 1),
                Fill = MakeRoundedBox(Library.Palette.Accent, 1),
                Label = CreateDrawing("Text", {Text = name, Size = 12, Font = 2, Outline = true, Visible = false}),
                CurrentColor = Library.Palette.SubText,
                Alpha = Config[flag] and 1 or 0,
                HitboxPos = Vector2.new(),
                HitboxSize = Vector2.new()
            }

            function Toggle:Update(x, y, w)
                self.HitboxPos = Vec2(x, y)
                self.HitboxSize = Vec2(w, 20)
                UpdateRoundedBox(self.BoxStroke, Vec2(x + 2, y + 3), Vec2(16, 16), 4, LerpColor(Library.Palette.Outline, Library.Palette.Accent, self.Alpha), 1, true)
                UpdateRoundedBox(self.Box, Vec2(x + 3, y + 4), Vec2(14, 14), 4, Library.Palette.Element, 1, true)

                self.Label.Visible = true
                self.Label.Position = Vec2(x + 26, y + 4)

                local hovered = IsMouseInBounds(Library.Input.MousePos, self.HitboxPos, self.HitboxSize)
                self.CurrentColor = LerpColor(self.CurrentColor, Config[self.Flag] and Library.Palette.Text or (hovered and Library.Palette.Text or Library.Palette.SubText), 0.15)
                self.Label.Color = self.CurrentColor

                self.Alpha = Lerp(self.Alpha, Config[self.Flag] and 1 or 0, 0.2)
                UpdateRoundedBox(self.Fill, Vec2(x + 5, y + 6), Vec2(10, 10), 3, Library.Palette.Accent, self.Alpha, self.Alpha > 0.02)
            end

            table.insert(self.Items, Toggle)
            return Toggle
        end

        function Section:CreateSlider(name, flag, min, max, default, step)
            Config[flag] = Config[flag] ~= nil and Config[flag] or ClampSliderValue(default or min, min, max, step)
            local Slider = {
                Type = "Slider",
                Height = 44,
                Min = min,
                Max = max,
                Step = step,
                Flag = flag,
                InputBuffer = FormatSliderValue(Config[flag], step),
                Label = CreateDrawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ValueLabel = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(Library.Palette.Outline, 1),
                Background = MakeRoundedBox(Library.Palette.Element, 1),
                Fill = MakeRoundedBox(Library.Palette.Accent, 1),
                Knob = MakeRoundedBox(Library.Palette.Text, 1),
                ValuePos = Vector2.new(),
                ValueSize = Vector2.new(),
                BarPos = Vector2.new(),
                BarSize = Vector2.new()
            }

            function Slider:Update(x, y, w)
                local isEditing = Library.State.ActiveSliderInput == self
                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y)

                local displayText = isEditing and (((tick() % 1) < 0.5) and (self.InputBuffer .. "_") or self.InputBuffer) or FormatSliderValue(Config[self.Flag], self.Step)
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = displayText
                self.ValueLabel.Color = isEditing and Library.Palette.Accent or Library.Palette.SubText
                self.ValuePos = Vec2(x + w - self.ValueLabel.TextBounds.X - 4, y)
                self.ValueSize = Vec2(math.max(self.ValueLabel.TextBounds.X + 8, 24), 16)
                self.ValueLabel.Position = Vec2(self.ValuePos.X + 4, y)

                if not isEditing then
                    self.InputBuffer = FormatSliderValue(Config[self.Flag], self.Step)
                end

                local barY = y + 26
                local barWidth = w - self.ValueSize.X - 12
                self.BarPos = Vec2(x + 2, barY)
                self.BarSize = Vec2(barWidth, 6)
                UpdateRoundedBox(self.Stroke, self.BarPos, self.BarSize, 3, Library.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, Vec2(x + 3, barY + 1), Vec2(barWidth - 2, 4), 3, Library.Palette.Element, 1, true)

                local range = math.max(self.Max - self.Min, 0.0001)
                local pct = Clamp((Config[self.Flag] - self.Min) / range, 0, 1)
                local fillW = math.max((barWidth - 2) * pct, 0)
                UpdateRoundedBox(self.Fill, Vec2(x + 3, barY + 1), Vec2(fillW, 4), 3, Library.Palette.Accent, 1, fillW > 0)
                UpdateRoundedBox(self.Knob, Vec2(x + 3 + fillW - 4, barY - 1), Vec2(8, 8), 4, Library.Palette.Text, 1, true)
            end

            table.insert(self.Items, Slider)
            return Slider
        end

        function Section:CreateDropdown(name, flag, options, default)
            Config[flag] = Config[flag] ~= nil and Config[flag] or (default or options[1])
            local Dropdown = {
                Type = "Dropdown",
                Height = 46,
                Options = options or {},
                Flag = flag,
                IsOpen = false,
                ListHeight = 0,
                TargetListHeight = 0,
                OpenAlpha = 0,
                HoveredIndex = nil,
                Label = CreateDrawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(Library.Palette.Outline, 1),
                Background = MakeRoundedBox(Library.Palette.Element, 1),
                ValueLabel = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                Icon = CreateDrawing("Text", {Text = "+", Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                ListStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                ListBackground = MakeRoundedBox(Library.Palette.Element, 1),
                OptionDrawings = {},
                OptionBounds = {},
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new(),
                ListPos = Vector2.new(),
                ListSize = Vector2.new()
            }

            function Dropdown:SetOptions(newOptions, preserveValue)
                self.Options = newOptions or {}
                if not preserveValue then
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
                self.OptionBounds = {}
                self.HoveredIndex = nil
            end

            function Dropdown:GetVisibleOptionBounds()
                local result = {}
                for index, bounds in ipairs(self.OptionBounds) do
                    if bounds and bounds.Visible then
                        result[index] = bounds
                    end
                end
                return result
            end

            function Dropdown:Update(x, y, w)
                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y)

                local barY = y + 20
                self.ButtonPos = Vec2(x + 2, barY)
                self.ButtonSize = Vec2(w - 4, 24)

                local buttonOutlineColor = self.IsOpen and Library.Palette.Accent or Library.Palette.Outline
                local buttonTextColor = self.IsOpen and Library.Palette.Text or Library.Palette.SubText

                UpdateRoundedBox(self.Stroke, self.ButtonPos, self.ButtonSize, 4, buttonOutlineColor, 1, true)
                UpdateRoundedBox(self.Background, Vec2(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vec2(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, Library.Palette.Element, 1, true)

                local currentValue = Config[self.Flag]
                local selectedIndex = nil
                for idx, option in ipairs(self.Options) do
                    if tostring(option) == tostring(currentValue) then
                        selectedIndex = idx
                        currentValue = option
                        break
                    end
                end
                if selectedIndex == nil and #self.Options > 0 then
                    currentValue = self.Options[1]
                    Config[self.Flag] = currentValue
                    selectedIndex = 1
                end

                self.ValueLabel.Visible = true
                self.ValueLabel.Text = tostring(currentValue or "")
                self.ValueLabel.Position = Vec2(self.ButtonPos.X + 6, self.ButtonPos.Y + 5)
                self.ValueLabel.Color = buttonTextColor

                self.Icon.Visible = true
                self.Icon.Text = self.IsOpen and "-" or "+"
                self.Icon.Position = Vec2(self.ButtonPos.X + self.ButtonSize.X - 14, self.ButtonPos.Y + 5)
                self.Icon.Color = buttonTextColor

                self.TargetListHeight = self.IsOpen and (#self.Options * 24 + (#self.Options > 0 and 2 or 0)) or 0
                self.ListHeight = Lerp(self.ListHeight, self.TargetListHeight, 0.3)
                if math.abs(self.ListHeight - self.TargetListHeight) < 0.5 then
                    self.ListHeight = self.TargetListHeight
                end

                self.OpenAlpha = Lerp(self.OpenAlpha, self.IsOpen and 1 or 0, 0.3)
                if math.abs(self.OpenAlpha - (self.IsOpen and 1 or 0)) < 0.02 then
                    self.OpenAlpha = self.IsOpen and 1 or 0
                end

                local drawListHeight = math.max(0, Round(self.ListHeight))
                local listVisible = drawListHeight > 1 and self.OpenAlpha > 0.02

                self.ListPos = Vec2(self.ButtonPos.X, self.ButtonPos.Y + self.ButtonSize.Y + 2)
                self.ListSize = Vec2(self.ButtonSize.X, drawListHeight)

                UpdateRoundedBox(self.ListStroke, self.ListPos, self.ListSize, 4, Library.Palette.Outline, self.OpenAlpha, listVisible)
                UpdateRoundedBox(self.ListBackground, Vec2(self.ListPos.X + 1, self.ListPos.Y + 1), Vec2(math.max(self.ListSize.X - 2, 0), math.max(self.ListSize.Y - 2, 0)), 4, Library.Palette.Element, self.OpenAlpha, listVisible)

                self.OptionBounds = {}
                self.HoveredIndex = nil

                for i, optionStr in ipairs(self.Options) do
                    if not self.OptionDrawings[i] then
                        self.OptionDrawings[i] = CreateDrawing("Text", {Text = tostring(optionStr), Size = 12, Font = 2, Outline = true, Visible = false})
                    end

                    local txtDraw = self.OptionDrawings[i]
                    local optionPos = Vec2(self.ListPos.X + 6, self.ListPos.Y + 3 + ((i - 1) * 24))
                    local optionSize = Vec2(self.ListSize.X - 12, 20)
                    local optionBottom = optionPos.Y + optionSize.Y
                    local clipBottom = self.ListPos.Y + drawListHeight - 2
                    local optionVisible = listVisible and optionPos.Y >= self.ListPos.Y + 1 and optionBottom <= clipBottom + 1

                    self.OptionBounds[i] = {
                        Pos = optionPos,
                        Size = optionSize,
                        Visible = optionVisible
                    }

                    if optionVisible and IsMouseInBounds(Library.Input.MousePos, optionPos, optionSize) then
                        self.HoveredIndex = i
                    end

                    txtDraw.Visible = optionVisible
                    if optionVisible then
                        txtDraw.Text = tostring(optionStr)
                        txtDraw.Position = Vec2(optionPos.X, optionPos.Y + 3)
                        if selectedIndex == i then
                            txtDraw.Color = Library.Palette.Accent
                        elseif self.HoveredIndex == i then
                            txtDraw.Color = Library.Palette.Text
                        else
                            txtDraw.Color = Library.Palette.SubText
                        end
                        txtDraw.Transparency = math.max(self.OpenAlpha, 0.08)
                    end
                end

                for i = #self.Options + 1, #self.OptionDrawings do
                    self.OptionDrawings[i].Visible = false
                end

                self.Height = 46 + (listVisible and (drawListHeight + 4) or 0)
            end

            table.insert(self.Items, Dropdown)
            return Dropdown
        end

        function Section:CreateColorPicker(name, flag, defaultColor, defaultAlpha, callback)
            local initialColor = defaultColor or Library.Palette.Accent
            local initialAlpha = defaultAlpha
            if initialAlpha == nil then
                initialAlpha = 1
            end
            if type(Config[flag]) ~= "table" or not Config[flag].Color then
                Config[flag] = {
                    Color = initialColor,
                    Alpha = Clamp(initialAlpha, 0, 1)
                }
            end

            local h, s, v = Color3ToHSV(Config[flag].Color)

            local ColorPicker = {
                Type = "ColorPicker",
                Height = 36,
                Flag = flag,
                Callback = callback,
                IsOpen = false,
                Hue = h,
                Sat = s,
                Val = v,
                Alpha = Clamp(Config[flag].Alpha or 1, 0, 1),
                GridCols = 32,
                GridRows = 18,
                HueSteps = 32,
                Label = CreateDrawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(Library.Palette.Outline, 1),
                Background = MakeRoundedBox(Library.Palette.Element, 1),
                PreviewStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                Preview = MakeRoundedBox(Config[flag].Color, 1),
                PreviewText = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                PopupStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                PopupBackground = MakeRoundedBox(Library.Palette.Background, 1),
                PopupSwatchStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                PopupSwatch = MakeRoundedBox(Config[flag].Color, 1),
                PopupHex = CreateDrawing("Text", {Color = Library.Palette.Text, Size = 11, Font = 2, Outline = true, Visible = false}),
                SVStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                HueStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                SVGrid = CreateGridSquares(32 * 18),
                HueGrid = CreateGridSquares(32),
                CursorOuter = CreateDrawing("Circle", {Filled = false, Thickness = 2, Transparency = 1, NumSides = 24, Radius = 6, Visible = false}),
                CursorInner = CreateDrawing("Circle", {Filled = false, Thickness = 1, Transparency = 1, NumSides = 24, Radius = 4, Visible = false}),
                HueLine = CreateDrawing("Line", {Thickness = 2, Transparency = 1, Visible = false}),
                HueCapTop = CreateDrawing("Circle", {Filled = true, Transparency = 1, NumSides = 20, Radius = 3, Visible = false}),
                HueCapBottom = CreateDrawing("Circle", {Filled = true, Transparency = 1, NumSides = 20, Radius = 3, Visible = false}),
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new(),
                PopupPos = Vector2.new(),
                PopupSize = Vector2.new(),
                SVPos = Vector2.new(),
                SVSize = Vector2.new(),
                HuePos = Vector2.new(),
                HueSize = Vector2.new()
            }

            function ColorPicker:SyncColor()
                local state = Config[self.Flag]
                if type(state) ~= "table" then
                    state = {}
                    Config[self.Flag] = state
                end
                state.Color = HSVToColor3(self.Hue, self.Sat, self.Val)
                state.Alpha = Clamp(self.Alpha, 0, 1)
                if self.Callback then
                    self.Callback(state)
                end
            end

            function ColorPicker:Update(x, y, w)
                self:SyncColor()

                local state = Config[self.Flag]
                local currentColor = state and state.Color or HSVToColor3(self.Hue, self.Sat, self.Val)
                local currentHex = Color3ToHex(currentColor)

                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y + 8)

                self.ButtonPos = Vec2(x + w - 84, y + 4)
                self.ButtonSize = Vec2(80, 24)

                UpdateRoundedBox(self.Stroke, self.ButtonPos, self.ButtonSize, 4, self.IsOpen and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, Vec2(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vec2(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, Library.Palette.Element, 1, true)
                UpdateRoundedBox(self.PreviewStroke, Vec2(self.ButtonPos.X + 5, self.ButtonPos.Y + 5), Vec2(14, 14), 3, Library.Palette.OutlineLight, 1, true)
                UpdateRoundedBox(self.Preview, Vec2(self.ButtonPos.X + 6, self.ButtonPos.Y + 6), Vec2(12, 12), 2, currentColor, math.max(state and state.Alpha or 1, 0.15), true)

                self.PreviewText.Visible = true
                self.PreviewText.Text = currentHex
                self.PreviewText.Color = self.IsOpen and Library.Palette.Text or Library.Palette.SubText
                self.PreviewText.Position = Vec2(self.ButtonPos.X + 24, self.ButtonPos.Y + 7)

                if self.IsOpen then
                    local popupW = 246
                    local popupH = 160
                    self.PopupPos = Vec2(x + w - popupW - 4, y + 32)
                    self.PopupSize = Vec2(popupW, popupH)
                    self.Height = 196

                    UpdateRoundedBox(self.PopupStroke, self.PopupPos, self.PopupSize, 5, Library.Palette.Outline, 1, true)
                    UpdateRoundedBox(self.PopupBackground, Vec2(self.PopupPos.X + 1, self.PopupPos.Y + 1), Vec2(self.PopupSize.X - 2, self.PopupSize.Y - 2), 5, Library.Palette.Background, 1, true)

                    self.SVPos = Vec2(self.PopupPos.X + 10, self.PopupPos.Y + 10)
                    self.SVSize = Vec2(226, 104)
                    self.HuePos = Vec2(self.PopupPos.X + 10, self.PopupPos.Y + 124)
                    self.HueSize = Vec2(226, 16)

                    UpdateRoundedBox(self.SVStroke, Vec2(self.SVPos.X - 1, self.SVPos.Y - 1), Vec2(self.SVSize.X + 2, self.SVSize.Y + 2), 3, Library.Palette.Outline, 1, true)
                    UpdateRoundedBox(self.HueStroke, Vec2(self.HuePos.X - 1, self.HuePos.Y - 1), Vec2(self.HueSize.X + 2, self.HueSize.Y + 2), 3, Library.Palette.Outline, 1, true)

                    UpdateGridSquares(self.SVGrid, self.GridCols, self.GridRows, self.SVPos.X, self.SVPos.Y, self.SVSize.X, self.SVSize.Y, function(col, row, cols, rows)
                        local sat = (col - 1) / math.max(cols - 1, 1)
                        local val = 1 - ((row - 1) / math.max(rows - 1, 1))
                        return HSVToColor3(self.Hue, sat, val)
                    end, true)

                    UpdateGridSquares(self.HueGrid, self.HueSteps, 1, self.HuePos.X, self.HuePos.Y, self.HueSize.X, self.HueSize.Y, function(col, _, cols)
                        local hh = (col - 1) / math.max(cols - 1, 1)
                        return HSVToColor3(hh, 1, 1)
                    end, true)

                    local cursorX = self.SVPos.X + (self.Sat * self.SVSize.X)
                    local cursorY = self.SVPos.Y + ((1 - self.Val) * self.SVSize.Y)
                    self.CursorOuter.Visible = true
                    self.CursorOuter.Color = Color3.new(0, 0, 0)
                    self.CursorOuter.Position = Vec2(cursorX, cursorY)
                    self.CursorOuter.Radius = 6
                    self.CursorInner.Visible = true
                    self.CursorInner.Color = Color3.new(1, 1, 1)
                    self.CursorInner.Position = Vec2(cursorX, cursorY)
                    self.CursorInner.Radius = 4

                    local hueX = self.HuePos.X + (self.Hue * self.HueSize.X)
                    self.HueLine.Visible = true
                    self.HueLine.Color = Library.Palette.Text
                    self.HueLine.From = Vec2(hueX, self.HuePos.Y - 3)
                    self.HueLine.To = Vec2(hueX, self.HuePos.Y + self.HueSize.Y + 3)

                    self.HueCapTop.Visible = true
                    self.HueCapTop.Color = Library.Palette.Text
                    self.HueCapTop.Position = Vec2(hueX, self.HuePos.Y - 3)
                    self.HueCapTop.Radius = 3
                    self.HueCapBottom.Visible = true
                    self.HueCapBottom.Color = Library.Palette.Text
                    self.HueCapBottom.Position = Vec2(hueX, self.HuePos.Y + self.HueSize.Y + 3)
                    self.HueCapBottom.Radius = 3

                    UpdateRoundedBox(self.PopupSwatchStroke, Vec2(self.PopupPos.X + 10, self.PopupPos.Y + 146), Vec2(22, 8), 2, Library.Palette.OutlineLight, 1, true)
                    UpdateRoundedBox(self.PopupSwatch, Vec2(self.PopupPos.X + 11, self.PopupPos.Y + 147), Vec2(20, 6), 2, currentColor, math.max(state and state.Alpha or 1, 0.15), true)

                    self.PopupHex.Visible = true
                    self.PopupHex.Text = currentHex
                    self.PopupHex.Position = Vec2(self.PopupPos.X + 38, self.PopupPos.Y + 144)
                else
                    self.Height = 36
                    UpdateRoundedBox(self.PopupStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    UpdateRoundedBox(self.PopupBackground, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    UpdateRoundedBox(self.PopupSwatchStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    UpdateRoundedBox(self.PopupSwatch, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    UpdateRoundedBox(self.SVStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    UpdateRoundedBox(self.HueStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
                    HideGridSquares(self.SVGrid)
                    HideGridSquares(self.HueGrid)
                    self.CursorOuter.Visible = false
                    self.CursorInner.Visible = false
                    self.HueLine.Visible = false
                    self.HueCapTop.Visible = false
                    self.HueCapBottom.Visible = false
                    self.PopupHex.Visible = false
                end
            end

            table.insert(self.Items, ColorPicker)
            return ColorPicker
        end

        function Section:CreateKeybind(name, flag, default)
            Config[flag] = NormalizeKeybindValue(Config[flag] ~= nil and Config[flag] or (default or "None"))
            local Keybind = {
                Type = "Keybind",
                Height = 30,
                Flag = flag,
                Icon = CreateKeybindImageIcon(18),
                Label = CreateDrawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonStroke = MakeRoundedBox(Library.Palette.Outline, 1),
                ButtonBox = MakeRoundedBox(Library.Palette.Element, 1),
                ValueLabel = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 11, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new()
            }

            function Keybind:Update(x, y, w)
                UpdateKeybindImageIcon(self.Icon, Vec2(0, 0), Library.Palette.Accent, false)

                self.Label.Visible = true
                self.Label.Position = Vec2(x + 6, y + 8)

                local bindValue = NormalizeKeybindValue(Config[self.Flag])
                local bindText = Library.State.ActiveKeybind == self and "[...]" or ("[" .. bindValue .. "]")
                self.ValueLabel.Visible = true
                self.ValueLabel.Text = bindText

                local btnWidth = math.max(74, self.ValueLabel.TextBounds.X + 20)
                self.ButtonPos = Vec2(x + w - btnWidth - 2, y + 4)
                self.ButtonSize = Vec2(btnWidth, 22)

                local isActive = Library.State.ActiveKeybind == self
                UpdateKeybindImageIcon(self.Icon, Vec2(0, 0), Library.Palette.Accent, false)
                UpdateRoundedBox(self.ButtonStroke, self.ButtonPos, self.ButtonSize, 4, isActive and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                UpdateRoundedBox(self.ButtonBox, Vec2(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vec2(btnWidth - 2, 20), 4, isActive and Library.Palette.Hover or Library.Palette.Element, 1, true)

                self.ValueLabel.Color = isActive and Library.Palette.Text or Library.Palette.SubText
                self.ValueLabel.Position = Vec2(
                    self.ButtonPos.X + math.floor((btnWidth - self.ValueLabel.TextBounds.X) / 2 + 0.5),
                    self.ButtonPos.Y + math.floor((self.ButtonSize.Y - self.ValueLabel.TextBounds.Y) / 2 + 0.5) - 1
                )
            end

            table.insert(self.Items, Keybind)
            return Keybind
        end


        function Section:CreateButton(name, callback)
            local Button = {
                Type = "Button",
                Height = 34,
                Callback = callback,
                Stroke = MakeRoundedBox(Library.Palette.Outline, 1),
                Background = MakeRoundedBox(Library.Palette.Element, 1),
                Label = CreateDrawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                ButtonPos = Vector2.new(),
                ButtonSize = Vector2.new()
            }

            function Button:Update(x, y, w)
                self.ButtonPos = Vec2(x + 2, y + 4)
                self.ButtonSize = Vec2(w - 4, 24)
                local hovered = IsMouseInBounds(Library.Input.MousePos, self.ButtonPos, self.ButtonSize)
                UpdateRoundedBox(self.Stroke, self.ButtonPos, self.ButtonSize, 4, hovered and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, Vec2(self.ButtonPos.X + 1, self.ButtonPos.Y + 1), Vec2(self.ButtonSize.X - 2, self.ButtonSize.Y - 2), 4, hovered and Library.Palette.Hover or Library.Palette.Element, 1, true)
                self.Label.Visible = true
                self.Label.Color = Library.Palette.Text
                self.Label.Position = Vec2(self.ButtonPos.X + math.floor((self.ButtonSize.X - self.Label.TextBounds.X) / 2 + 0.5), self.ButtonPos.Y + 6)
            end

            table.insert(self.Items, Button)
            return Button
        end

        function Section:CreateTextbox(name, flag, default)
            Config[flag] = Config[flag] ~= nil and Config[flag] or (default or "")
            local Textbox = {
                Type = "Textbox",
                Height = 36,
                Flag = flag,
                Label = CreateDrawing("Text", {Text = name, Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
                Stroke = MakeRoundedBox(Library.Palette.Outline, 1),
                Background = MakeRoundedBox(Library.Palette.Element, 1),
                ValueLabel = CreateDrawing("Text", {Color = Library.Palette.SubText, Size = 12, Font = 2, Outline = true, Visible = false}),
                BoxPos = Vector2.new(),
                BoxSize = Vector2.new()
            }

            function Textbox:Update(x, y, w)
                self.Label.Visible = true
                self.Label.Position = Vec2(x + 2, y + 8)
                local boxWidth = 110
                self.BoxPos = Vec2(x + w - boxWidth - 2, y + 6)
                self.BoxSize = Vec2(boxWidth, 24)

                local isActive = Library.State.ActiveTextbox == self
                UpdateRoundedBox(self.Stroke, self.BoxPos, self.BoxSize, 4, isActive and Library.Palette.Accent or Library.Palette.Outline, 1, true)
                UpdateRoundedBox(self.Background, Vec2(self.BoxPos.X + 1, self.BoxPos.Y + 1), Vec2(boxWidth - 2, 22), 4, Library.Palette.Element, 1, true)

                local displayStr = tostring(Config[self.Flag])
                if isActive and tick() % 1 < 0.5 then
                    displayStr = displayStr .. "_"
                end

                self.ValueLabel.Visible = true
                self.ValueLabel.Text = displayStr
                self.ValueLabel.Color = isActive and Library.Palette.Text or Library.Palette.SubText
                self.ValueLabel.Position = Vec2(x + w - boxWidth + 3, y + 11)
            end

            table.insert(self.Items, Textbox)
            return Textbox
        end

        table.insert(Tab.Sections, Section)
        return Section
    end

    table.insert(Library.Tabs, Tab)
    if not Library.CurrentTab then
        Library.CurrentTab = Tab
    end
    return Tab
end

Config.ParryBindMode = NormalizeBindMode(Config.ParryBindMode)
Config.SpamBindMode = NormalizeBindMode(Config.SpamBindMode)
Config.TriggerbotBindMode = NormalizeBindMode(Config.TriggerbotBindMode)
Config.AutoCurveBindMode = NormalizeBindMode(Config.AutoCurveBindMode)
Config.DotProtect = true

local TabCombat = Library:CreateTab("Combat")
local SecCombatMain = TabCombat:CreateSection("Main Settings", "Left")
SecCombatMain:CreateToggle("Auto Parry", "AutoParry", false)
SecCombatMain:CreateToggle("Training balls support", "LobbyParry", false)
SecCombatMain:CreateDropdown("Parry Method", "ParryMethod", {"Click", "Key"}, "Click")
SecCombatMain:CreateKeybind("Parry Bind", "ParryKeybind", "None")

local SecCombatOffense = TabCombat:CreateSection("Offensive Options", "Right")
SecCombatOffense:CreateToggle("Auto Spam", "AutoSpam", false)
SecCombatOffense:CreateKeybind("Spam Bind", "SpamKeybind", "None")
SecCombatOffense:CreateToggle("Triggerbot", "TriggerbotEnabled", false)
SecCombatOffense:CreateToggle("No Click On Ball Spawn", "NoClickOnBallSpawn", true)
SecCombatOffense:CreateKeybind("Trigger Bind", "TriggerbotKeybind", "None")
SecCombatOffense:CreateToggle("Auto Curve", "AutoCurve", false)
SecCombatOffense:CreateDropdown("Curve Mode", "AutoCurveMode", {"High", "Backwards"}, "High")
SecCombatOffense:CreateKeybind("Curve Bind", "AutoCurveKeybind", "None")
SecCombatOffense:CreateSlider("Camera Sens", "CameraSens", 0.1, 1.0, 0.50, 0.01)

local TabSettings = Library:CreateTab("Settings")
local SecSettingsConfig = TabSettings:CreateSection("Configuration", "Left")
SecSettingsConfig:CreateToggle("Ball Stats", "RenderBallStats", false)
SecSettingsConfig:CreateKeybind("Menu Bind", "HideKeybind", 27)
SecSettingsConfig:CreateToggle("Hotkey List", "ShowHotkeyList", true)

local TabThemes = Library:CreateTab("Themes")
local SecThemesMain = TabThemes:CreateSection("Theme Presets", "Left")
SecThemesMain:CreateDropdown("Preset", "ThemePreset", {"Nightfall", "Bloodmoon", "Ocean", "Mint"}, Config.ThemePreset or "Nightfall")
local SecThemesAccent = TabThemes:CreateSection("Accent", "Right")
SecThemesAccent:CreateColorPicker("Accent", "UiAccentColor", Library.Palette.Accent, 1, function(state) Library.Palette.Accent = state.Color end)
SecThemesAccent:CreateColorPicker("Accent 2", "UiAccent2Color", Library.Palette.Accent2, 1, function(state) Library.Palette.Accent2 = state.Color end)

local TabConfigs = Library:CreateTab("Configs")
local SecConfigsMain = TabConfigs:CreateSection("Config Manager", "Left")
local ConfigListDropdown = SecConfigsMain:CreateDropdown("Config", "SelectedConfig", GetAvailableConfigs(), Config.SelectedConfig or Config.ConfigName or "default")
SecConfigsMain:CreateTextbox("Config Name", "ConfigName", Config.ConfigName or "default")
SecConfigsMain:CreateToggle("Auto Save", "AutoSave", Config.AutoSave)
SecConfigsMain:CreateToggle("Auto Load", "AutoLoad", Config.AutoLoad)
SecConfigsMain:CreateButton("Save Config", function()
    Config.SelectedConfig = Config.ConfigName
    SaveCurrentConfig()
    if ConfigListDropdown then
        ConfigListDropdown:SetOptions(GetAvailableConfigs(), true)
    end
end)
SecConfigsMain:CreateButton("Load Config", function()
    LoadNamedConfig(Config.SelectedConfig or Config.ConfigName)
    SaveGlobalSettings()
    if ConfigListDropdown then
        ConfigListDropdown:SetOptions(GetAvailableConfigs(), true)
    end
end)
SecConfigsMain:CreateButton("Delete Config", function()
    local target = Config.SelectedConfig or Config.ConfigName or "default"
    DeleteNamedConfig(target)
    if ConfigListDropdown then
        ConfigListDropdown:SetOptions(GetAvailableConfigs(), true)
    end
end)

local OverlayMenuDrawings = {
    Outline = MakeRoundedBox(Library.Palette.Outline, 1),
    Background = MakeRoundedBox(Library.Palette.Background, 1),
    Option1 = MakeRoundedBox(Library.Palette.Element, 1),
    Option2 = MakeRoundedBox(Library.Palette.Element, 1),
    Option1Text = CreateDrawing("Text", {Text = "Hold", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false}),
    Option2Text = CreateDrawing("Text", {Text = "Toggle", Color = Library.Palette.Text, Size = 12, Font = 2, Outline = true, Visible = false})
}

local function CloseTransientUi()
    if Library.State.ActiveDropdown then
        Library.State.ActiveDropdown.IsOpen = false
    end
    if Library.State.ActiveColorPicker then
        Library.State.ActiveColorPicker.IsOpen = false
    end
    Library.State.ActiveDropdown = nil
    Library.State.ActiveSlider = nil
    if Library.State.ActiveSliderInput then
        CommitSliderInput(Library.State.ActiveSliderInput)
    end
    Library.State.ActiveSliderInput = nil
    Library.State.ActiveTextbox = nil
    Library.State.ActiveKeybind = nil
    Library.State.ActiveColorPicker = nil
    Library.State.ActiveColorDrag = nil
    Library.State.HotkeysContext.Open = false
    Library.State.HotkeysContext.Entry = nil
    Library.State.KeybindContext.Open = false
    Library.State.KeybindContext.Entry = nil
end

local function HideStatsDrawings()
    UpdateRoundedBox(StatsDrawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(StatsDrawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateGradientLine(StatsDrawings.Topline, Vec2(0, 0), Vec2(0, 0), Color3.new(0, 0, 0), Color3.new(0, 0, 0), false)
    StatsDrawings.HeaderLine.Visible = false
    UpdateRoundedBox(StatsDrawings.Row1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(StatsDrawings.Row2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(StatsDrawings.Row3, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    StatsDrawings.Title.Visible = false
    StatsDrawings.Speed.Visible = false
    StatsDrawings.Distance.Visible = false
    StatsDrawings.Dot.Visible = false
end

local function HideHotkeysDrawings()
    UpdateRoundedBox(KeybindsDrawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(KeybindsDrawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    HideGradientLine(KeybindsDrawings.Topline)
    KeybindsDrawings.HeaderLine.Visible = false
    UpdateKeybindImageIcon(KeybindsDrawings.TitleIcon, Vec2(0, 0), Library.Palette.Accent, false)
    KeybindsDrawings.Title.Visible = false
    KeybindsDrawings.Subtitle.Visible = false
    for _, row in ipairs({KeybindsDrawings.Row1, KeybindsDrawings.Row2, KeybindsDrawings.Row3, KeybindsDrawings.Row4, KeybindsDrawings.MenuOutline, KeybindsDrawings.MenuBackground, KeybindsDrawings.MenuOption1, KeybindsDrawings.MenuOption2}) do
        UpdateRoundedBox(row, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end
    for _, txt in ipairs({
        KeybindsDrawings.Bind1, KeybindsDrawings.Bind2, KeybindsDrawings.Bind3, KeybindsDrawings.Bind4,
        KeybindsDrawings.State1, KeybindsDrawings.State2, KeybindsDrawings.State3, KeybindsDrawings.State4,
        KeybindsDrawings.Mode1, KeybindsDrawings.Mode2, KeybindsDrawings.Mode3, KeybindsDrawings.Mode4,
        KeybindsDrawings.MenuOption1Text, KeybindsDrawings.MenuOption2Text
    }) do
        txt.Visible = false
    end
end

local function SafeHideDrawing(draw)
    if draw then
        draw.Visible = false
    end
end

local function HideItem(item)
    if not item then
        return
    end

    if item.Type == "Toggle" then
        if item.BoxStroke then
            UpdateRoundedBox(item.BoxStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Box then
            UpdateRoundedBox(item.Box, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Fill then
            UpdateRoundedBox(item.Fill, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        SafeHideDrawing(item.Label)
    elseif item.Type == "Slider" then
        if item.Stroke then
            UpdateRoundedBox(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            UpdateRoundedBox(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Fill then
            UpdateRoundedBox(item.Fill, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.ValueStroke then
            UpdateRoundedBox(item.ValueStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.ValueBackground then
            UpdateRoundedBox(item.ValueBackground, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.KnobOuter then
            UpdateRoundedBox(item.KnobOuter, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Knob then
            UpdateRoundedBox(item.Knob, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        SafeHideDrawing(item.Label)
        SafeHideDrawing(item.ValueLabel)
        SafeHideDrawing(item.Dot)
    elseif item.Type == "Dropdown" then
        item.IsOpen = false
        item.ListHeight = 0
        item.TargetListHeight = 0
        item.OpenAlpha = 0
        SafeHideDrawing(item.Label)
        SafeHideDrawing(item.ValueLabel)
        SafeHideDrawing(item.Icon)
        if item.Stroke then
            UpdateRoundedBox(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            UpdateRoundedBox(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.ListStroke then
            UpdateRoundedBox(item.ListStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.ListBackground then
            UpdateRoundedBox(item.ListBackground, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        for _, draw in ipairs(item.OptionDrawings or {}) do
            SafeHideDrawing(draw)
        end
    elseif item.Type == "ColorPicker" then
        SafeHideDrawing(item.Label)
        SafeHideDrawing(item.PreviewText)
        SafeHideDrawing(item.PopupHex)
        if item.Stroke then
            UpdateRoundedBox(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            UpdateRoundedBox(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.PreviewStroke then
            UpdateRoundedBox(item.PreviewStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Preview then
            UpdateRoundedBox(item.Preview, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.PopupStroke then
            UpdateRoundedBox(item.PopupStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.PopupBackground then
            UpdateRoundedBox(item.PopupBackground, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.PopupSwatchStroke then
            UpdateRoundedBox(item.PopupSwatchStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.PopupSwatch then
            UpdateRoundedBox(item.PopupSwatch, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.SVStroke then
            UpdateRoundedBox(item.SVStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.HueStroke then
            UpdateRoundedBox(item.HueStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        HideGridSquares(item.SVGrid or {})
        HideGridSquares(item.HueGrid or {})
        SafeHideDrawing(item.CursorOuter)
        SafeHideDrawing(item.CursorInner)
        SafeHideDrawing(item.HueLine)
        SafeHideDrawing(item.HueCapTop)
        SafeHideDrawing(item.HueCapBottom)
    elseif item.Type == "Keybind" then
        if item.Icon then
            UpdateKeybindImageIcon(item.Icon, Vec2(0, 0), Library.Palette.Accent, false)
        end
        SafeHideDrawing(item.Label)
        SafeHideDrawing(item.ValueLabel)
        if item.ButtonStroke then
            UpdateRoundedBox(item.ButtonStroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.ButtonBox then
            UpdateRoundedBox(item.ButtonBox, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
    elseif item.Type == "Textbox" then
        SafeHideDrawing(item.Label)
        SafeHideDrawing(item.ValueLabel)
        if item.Stroke then
            UpdateRoundedBox(item.Stroke, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
        if item.Background then
            UpdateRoundedBox(item.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        end
    end
end

local function HideTabContent(tab)
    if not tab then
        return
    end
    for _, section in ipairs(tab.Sections) do
        UpdateRoundedBox(section.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(section.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        HideStripePattern(section.PatternBack)
        HideStripePattern(section.PatternFront)
        section.Title.Visible = false
        section.Line.Visible = false
        for _, item in ipairs(section.Items) do
            HideItem(item)
        end
    end
end

local HideWindowDrawings

local function ForceHideMainUi()
    HideWindowDrawings()
    HideStatsDrawings()

    for _, tab in ipairs(Library.Tabs) do
        HideTabContent(tab)
    end

    if Library.State.ActiveDropdown then
        Library.State.ActiveDropdown.IsOpen = false
        Library.State.ActiveDropdown.ListHeight = 0
        Library.State.ActiveDropdown.TargetListHeight = 0
        Library.State.ActiveDropdown.OpenAlpha = 0
    end

    local menuVisible = false
    UpdateRoundedBox(KeybindsDrawings.MenuOutline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(KeybindsDrawings.MenuBackground, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(KeybindsDrawings.MenuOption1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(KeybindsDrawings.MenuOption2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    KeybindsDrawings.MenuOption1Text.Visible = false
    KeybindsDrawings.MenuOption2Text.Visible = false

    UpdateRoundedBox(OverlayMenuDrawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(OverlayMenuDrawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(OverlayMenuDrawings.Option1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(OverlayMenuDrawings.Option2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    OverlayMenuDrawings.Option1Text.Visible = false
    OverlayMenuDrawings.Option2Text.Visible = false
    Library.State.KeybindContext.Open = false
    Library.State.KeybindContext.Entry = nil
    if Library.State.ActiveSliderInput then
        CommitSliderInput(Library.State.ActiveSliderInput)
    end
    Library.State.ActiveSliderInput = nil
end

local function ApplyHeldBackspace()
    local targetSlider = Library.State.ActiveSliderInput
    local targetTextbox = Library.State.ActiveTextbox
    if not targetSlider and not targetTextbox then
        Library.State.BackspaceHeld = false
        Library.State.BackspaceNextRepeat = 0
        return
    end

    local isBackspaceDown = iskeypressed and iskeypressed(8) or false
    if not isBackspaceDown then
        Library.State.BackspaceHeld = false
        Library.State.BackspaceNextRepeat = 0
        return
    end

    local now = tick()
    if not Library.State.BackspaceHeld then
        Library.State.BackspaceHeld = true
        Library.State.BackspaceNextRepeat = now + 0.42
        return
    end

    if now < (Library.State.BackspaceNextRepeat or 0) then
        return
    end

    Library.State.BackspaceNextRepeat = now + 0.035

    if targetSlider then
        local currentText = tostring(targetSlider.InputBuffer or "")
        targetSlider.InputBuffer = string.sub(currentText, 1, -2)
    elseif targetTextbox then
        local currentText = tostring(Config[targetTextbox.Flag] or "")
        Config[targetTextbox.Flag] = string.sub(currentText, 1, -2)
        QueueSaveConfig()
    end
end

HideWindowDrawings = function()
    UpdateRoundedBox(WindowDrawings.Shadow, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Topbar, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    UpdateRoundedBox(WindowDrawings.Sidebar, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    HideGradientLine(WindowDrawings.Topline)
    HideStripePattern(WindowDrawings.PatternBack)
    HideStripePattern(WindowDrawings.PatternFront)
    WindowDrawings.SidebarLine.Visible = false
    WindowDrawings.TopBorder.Visible = false
    WindowDrawings.Title.Visible = false
    for _, tab in ipairs(Library.Tabs) do
        UpdateRoundedBox(tab.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(tab.Indicator, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        tab.Label.Visible = false
        tab.IconDraw.Visible = false
        HideTabContent(tab)
    end
end

local function DoClick()
    if not isrbxactive or not isrbxactive() then
        return
    end
    if Config.ParryMethod == "Click" then
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

local AutoRuntime = {
    Ball = nil,
    LastBall = nil,
    LastBallPos = Vector3.zero,
    LastBallVel = Vector3.zero,
    LastBallSpeed = 0,
    LastTarget = nil,
    LastTargetChange = 0,
    Parries = 0,
    AutoSpam = false,
    Cooldown = false,
    WarpDetectedAt = -999,
    PingHistory = {},
    SmoothedAccel = 0,
    CurveHistory = {},
    LastAlive = false,
    Parried = false,
    TriggerParried = false,
    LastParryAt = 0,
    LastSpamAt = 0,
    LastManualClickAt = 0,
    TriggerScheduledAt = 0
}

local AutoSpamBatch = {
    ClicksPerSecond = 1000000,
    PendingClicks = 0,
    FractionalClicks = 0,
    TimeSinceLastSend = 0,
    SendInterval = 0.01,
    TotalClicks = 0,
    LastBatch = 0
}

local function IsAutoSpamBatchActive()
    if not _G.MoonshadeActive then
        return false
    end
    if not AutoRuntime then
        return false
    end
    if not Config.AutoSpam or not AutoRuntime.AutoSpam then
        return false
    end
    if isrbxactive and not isrbxactive() then
        return false
    end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function ResetAutoSpamBatch()
    AutoSpamBatch.PendingClicks = 0
    AutoSpamBatch.FractionalClicks = 0
    AutoSpamBatch.TimeSinceLastSend = 0
    AutoSpamBatch.LastBatch = 0
end

RunService.Heartbeat:Connect(function(dt)
    dt = FastClamp and FastClamp(dt or 0.016, 0, 0.05) or math.clamp(dt or 0.016, 0, 0.05)

    if not IsAutoSpamBatchActive() then
        ResetAutoSpamBatch()
        return
    end

    local clicksThisFrame = AutoSpamBatch.ClicksPerSecond * dt
    AutoSpamBatch.FractionalClicks = AutoSpamBatch.FractionalClicks + clicksThisFrame

    local actualClicks = FastFloor and FastFloor(AutoSpamBatch.FractionalClicks) or math.floor(AutoSpamBatch.FractionalClicks)
    if actualClicks > 0 then
        AutoSpamBatch.PendingClicks = AutoSpamBatch.PendingClicks + actualClicks
        AutoSpamBatch.FractionalClicks = AutoSpamBatch.FractionalClicks - actualClicks
    end

    AutoSpamBatch.TimeSinceLastSend = AutoSpamBatch.TimeSinceLastSend + dt
    if AutoSpamBatch.TimeSinceLastSend >= AutoSpamBatch.SendInterval then
        if AutoSpamBatch.PendingClicks > 0 then
            AutoSpamBatch.LastBatch = AutoSpamBatch.PendingClicks
            AutoSpamBatch.TotalClicks = AutoSpamBatch.TotalClicks + AutoSpamBatch.PendingClicks
            AutoRuntime.SpamBatch = AutoSpamBatch.LastBatch
            AutoRuntime.SpamTotal = AutoSpamBatch.TotalClicks
            AutoRuntime.LastSpamAt = FastTick and FastTick() or tick()
            AutoSpamBatch.PendingClicks = 0
        else
            AutoSpamBatch.LastBatch = 0
        end
        AutoSpamBatch.TimeSinceLastSend = 0
    end
end)

RunService.RenderStepped:Connect(function()
    if not (isrbxactive and isrbxactive()) then
        return
    end
    Library.Input.MousePos = Vector2.new(Mouse.X, Mouse.Y)
    Library.Input.Mouse1Down = ismouse1pressed and ismouse1pressed() or false
    Library.Input.Mouse1Clicked = Library.Input.Mouse1Down and not Library.Input.Mouse1Prev
    Library.Input.Mouse1Released = not Library.Input.Mouse1Down and Library.Input.Mouse1Prev
    Library.Input.Mouse1Prev = Library.Input.Mouse1Down
    Library.Input.Mouse2Down = ismouse2pressed and ismouse2pressed() or false
    Library.Input.Mouse2Clicked = Library.Input.Mouse2Down and not Library.Input.Mouse2Prev
    Library.Input.Mouse2Prev = Library.Input.Mouse2Down

    local isShiftDown = (iskeypressed and (iskeypressed(160) or iskeypressed(161) or iskeypressed(16))) or false

    for keyCode, keyName in pairs(KeyCodes) do
        local isPressed = iskeypressed and iskeypressed(keyCode) or false
        if keyCode == 1 then
            isPressed = Library.Input.Mouse1Down
        elseif keyCode == 2 then
            isPressed = Library.Input.Mouse2Down
        end

        if isPressed and not Library.Input.KeysDown[keyCode] then
            Library.Input.KeysDown[keyCode] = true

            if Library.State.ActiveKeybind then
                Config[Library.State.ActiveKeybind.Flag] = NormalizeKeybindValue(keyCode == 27 and "None" or keyName)
                Library.State.ActiveKeybind = nil
            elseif Library.State.ActiveSliderInput then
                local slider = Library.State.ActiveSliderInput
                local currentText = tostring(slider.InputBuffer or "")
                if keyCode == 8 then
                    slider.InputBuffer = string.sub(currentText, 1, -2)
                elseif keyCode == 13 then
                    CommitSliderInput(slider)
                    Library.State.ActiveSliderInput = nil
                elseif keyCode == 27 then
                    slider.InputBuffer = FormatSliderValue(Config[slider.Flag], slider.Step)
                    Library.State.ActiveSliderInput = nil
                else
                    local char = keyName
                    if keyCode >= 48 and keyCode <= 57 then
                        slider.InputBuffer = currentText .. char
                    elseif keyCode >= 96 and keyCode <= 105 then
                        slider.InputBuffer = currentText .. tostring(keyCode - 96)
                    elseif keyCode == 109 then
                        if not string.find(currentText, "%-") then
                            slider.InputBuffer = "-" .. currentText
                        end
                    elseif keyCode == 189 then
                        if not string.find(currentText, "%-") then
                            slider.InputBuffer = "-" .. currentText
                        end
                    elseif keyCode == 110 or keyCode == 190 then
                        if not string.find(currentText, "%.") then
                            slider.InputBuffer = currentText .. "."
                        end
                    end
                end
            elseif Library.State.ActiveTextbox then
                local tbox = Library.State.ActiveTextbox
                local currentText = tostring(Config[tbox.Flag])
                if keyCode == 8 then
                    Config[tbox.Flag] = string.sub(currentText, 1, -2)
                elseif keyCode == 13 or keyCode == 27 then
                    Library.State.ActiveTextbox = nil
                elseif keyCode == 32 then
                    Config[tbox.Flag] = currentText .. " "
                    QueueSaveConfig()
                else
                    local char = keyName
                    if keyCode >= 65 and keyCode <= 90 then
                        Config[tbox.Flag] = currentText .. (isShiftDown and char or string.lower(char))
                        QueueSaveConfig()
                    elseif keyCode >= 48 and keyCode <= 57 then
                        Config[tbox.Flag] = currentText .. (isShiftDown and (ShiftModifiers[char] or char) or char)
                        QueueSaveConfig()
                    end
                end
            else
                if keyName == NormalizeKeybindValue(Config.HideKeybind) then
                    if not Library.BindPressed then
                        Library.Visible = not Library.Visible
                        Library.BindPressed = true
                        if not Library.Visible then
                            CloseTransientUi()
                            HideWindowDrawings()
                            if not Config.ShowHotkeyList then
                                HideHotkeysDrawings()
                            end
                        end
                    end
                elseif keyName == NormalizeKeybindValue(Config.ParryKeybind) then
                    HandleBindPress("ParryKeybind")
                elseif keyName == NormalizeKeybindValue(Config.SpamKeybind) then
                    HandleBindPress("SpamKeybind")
                elseif keyName == NormalizeKeybindValue(Config.TriggerbotKeybind) then
                    HandleBindPress("TriggerbotKeybind")
                elseif keyName == NormalizeKeybindValue(Config.AutoCurveKeybind) then
                    HandleBindPress("AutoCurveKeybind")
                end
            end
        elseif not isPressed then
            Library.Input.KeysDown[keyCode] = false
            if keyName == NormalizeKeybindValue(Config.HideKeybind) then
                Library.BindPressed = false
            elseif keyName == NormalizeKeybindValue(Config.ParryKeybind) then
                HandleBindRelease("ParryKeybind")
            elseif keyName == NormalizeKeybindValue(Config.SpamKeybind) then
                HandleBindRelease("SpamKeybind")
            elseif keyName == NormalizeKeybindValue(Config.TriggerbotKeybind) then
                HandleBindRelease("TriggerbotKeybind")
            elseif keyName == NormalizeKeybindValue(Config.AutoCurveKeybind) then
                HandleBindRelease("AutoCurveKeybind")
            end
        end
    end

    ApplyHeldBackspace()

    local hotkeysSize = Vector2.new(286, 196)
    local shouldShowHotkeys = Config.ShowHotkeyList

    if not Library.Visible then
        CloseTransientUi()
        for _, tab in ipairs(Library.Tabs) do
            HideTabContent(tab)
        end
        HideWindowDrawings()
        if not shouldShowHotkeys then
            HideHotkeysDrawings()
        end
    end

    local hotkeyEntries = {
        {BindFlag = "ParryKeybind", ToggleFlag = "AutoParry", Label = "Parry"},
        {BindFlag = "SpamKeybind", ToggleFlag = "AutoSpam", Label = "Spam"},
        {BindFlag = "TriggerbotKeybind", ToggleFlag = "TriggerbotEnabled", Label = "Trigger"},
        {BindFlag = "AutoCurveKeybind", ToggleFlag = "AutoCurve", Label = "Curve"}
    }

    local statsSize = Vec2(276, 166)
    local accentColor = Library.Palette.Accent

    if shouldShowHotkeys then
        Library.HotkeysPosition = ClampWindowPosition(Library.HotkeysPosition, hotkeysSize)

        if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, Library.HotkeysPosition, Vector2.new(hotkeysSize.X, 36)) then
            Library.State.HotkeysDragging = true
            Library.State.HotkeysDragStart = Library.Input.MousePos
            Library.State.HotkeysWindowStart = Library.HotkeysPosition
            CloseTransientUi()
        end

        if Library.Input.Mouse1Released then
            Library.State.HotkeysDragging = false
        end

        if Library.State.HotkeysDragging then
            Library.HotkeysPosition = ClampWindowPosition(Library.State.HotkeysWindowStart + (Library.Input.MousePos - Library.State.HotkeysDragStart), hotkeysSize)
        end

        local bindsSize = Vec2(hotkeysSize.X, hotkeysSize.Y)
        local bindsPos = ClampWindowPosition(Vec2(Library.HotkeysPosition.X, Library.HotkeysPosition.Y), bindsSize)
        Library.HotkeysPosition = bindsPos

        UpdateRoundedBox(KeybindsDrawings.Outline, bindsPos, bindsSize, 8, Library.Palette.Outline, 1, true)
        UpdateRoundedBox(KeybindsDrawings.Background, Vec2(bindsPos.X + 1, bindsPos.Y + 1), Vec2(bindsSize.X - 2, bindsSize.Y - 2), 8, Library.Palette.Background, 1, true)
        UpdateGradientLine(KeybindsDrawings.Topline, Vec2(bindsPos.X + 1, bindsPos.Y + 1), Vec2(bindsSize.X - 2, 2), Library.Palette.Accent, Library.Palette.Accent2, true)
        KeybindsDrawings.HeaderLine.Visible = true
        KeybindsDrawings.HeaderLine.Position = Vec2(bindsPos.X + 12, bindsPos.Y + 40)
        KeybindsDrawings.HeaderLine.Size = Vec2(bindsSize.X - 24, 1)
        KeybindsDrawings.HeaderLine.Color = Library.Palette.Outline
        UpdateKeybindImageIcon(KeybindsDrawings.TitleIcon, Vec2(bindsPos.X + 12, bindsPos.Y + 10), accentColor, false)
        KeybindsDrawings.Title.Visible = true
        KeybindsDrawings.Title.Position = Vec2(bindsPos.X + 12, bindsPos.Y + 8)
        KeybindsDrawings.Subtitle.Visible = false

        local rowX = bindsPos.X + 12
        local rowW = bindsSize.X - 24
        local rowH = 28
        local rowStartY = bindsPos.Y + 48
        local rowGap = 8
        local hotkeyRows = {
            {X = rowX, Y = rowStartY, W = rowW, H = rowH, Entry = hotkeyEntries[1]},
            {X = rowX, Y = rowStartY + (rowH + rowGap) * 1, W = rowW, H = rowH, Entry = hotkeyEntries[2]},
            {X = rowX, Y = rowStartY + (rowH + rowGap) * 2, W = rowW, H = rowH, Entry = hotkeyEntries[3]},
            {X = rowX, Y = rowStartY + (rowH + rowGap) * 3, W = rowW, H = rowH, Entry = hotkeyEntries[4]}
        }

        if Library.Input.Mouse2Clicked and Library.State.HotkeysContext.Open then
            local menuPos = Library.State.HotkeysContext.Position
            if not IsMouseInBounds(Library.Input.MousePos, menuPos, Vector2.new(112, 56)) then
                Library.State.HotkeysContext.Open = false
                Library.State.HotkeysContext.Entry = nil
            end
        end

        local rowBoxes = {KeybindsDrawings.Row1, KeybindsDrawings.Row2, KeybindsDrawings.Row3, KeybindsDrawings.Row4}
        local bindTexts = {KeybindsDrawings.Bind1, KeybindsDrawings.Bind2, KeybindsDrawings.Bind3, KeybindsDrawings.Bind4}
        local stateTexts = {KeybindsDrawings.State1, KeybindsDrawings.State2, KeybindsDrawings.State3, KeybindsDrawings.State4}
        local modeTexts = {KeybindsDrawings.Mode1, KeybindsDrawings.Mode2, KeybindsDrawings.Mode3, KeybindsDrawings.Mode4}

        for i, row in ipairs(hotkeyRows) do
            local rowBox = rowBoxes[i]
            local bindDraw = bindTexts[i]
            local stateDraw = stateTexts[i]
            local modeDraw = modeTexts[i]
            local bindValue = NormalizeKeybindValue(Config[row.Entry.BindFlag])
            local bindMode = GetBindMode(row.Entry.BindFlag)
            local isEnabled = Config[row.Entry.ToggleFlag] and true or false
            local rowHovered = IsMouseInBounds(Library.Input.MousePos, Vec2(row.X, row.Y), Vec2(row.W, row.H))
            local rowColor = isEnabled and Library.Palette.Hover or (rowHovered and Library.Palette.Hover or Library.Palette.Element)

            UpdateRoundedBox(rowBox, Vec2(row.X, row.Y), Vec2(row.W, row.H), 6, rowColor, 1, true)

            bindDraw.Visible = true
            bindDraw.Text = "[" .. string.upper(bindValue) .. "]  " .. row.Entry.Label
            bindDraw.Color = isEnabled and Library.Palette.Text or LerpColor(Library.Palette.SubText, Library.Palette.Text, rowHovered and 0.35 or 0)
            bindDraw.Position = Vec2(row.X + 10, row.Y + 7)

            local stateColumnW = 36
            local modeColumnW = 58
            local stateTextX = row.X + row.W - stateColumnW - 10
            local modeTextX = stateTextX - modeColumnW - 10

            stateDraw.Visible = true
            stateDraw.Text = isEnabled and "ON" or "OFF"
            stateDraw.Color = isEnabled and Library.Palette.Text or Library.Palette.SubText
            stateDraw.Position = Vec2(stateTextX, row.Y + 8)

            modeDraw.Visible = true
            modeDraw.Text = string.upper(bindMode)
            modeDraw.Color = bindMode == "Hold" and Library.Palette.Accent2 or Library.Palette.Accent
            modeDraw.Position = Vec2(modeTextX, row.Y + 8)

        end
    else
        HideHotkeysDrawings()
        Library.State.HotkeysDragging = false
        Library.State.StatsDragging = false
        Library.State.HotkeysContext.Open = false
        Library.State.HotkeysContext.Entry = nil
    end

    local showStats = Config.RenderBallStats
    Library.StatsPosition = ClampWindowPosition(Library.StatsPosition, statsSize)
    local statsPos = Vec2(Library.StatsPosition.X, Library.StatsPosition.Y)

    if showStats then
        if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, Library.StatsPosition, Vector2.new(statsSize.X, 36)) then
            Library.State.StatsDragging = true
            Library.State.StatsDragStart = Library.Input.MousePos
            Library.State.StatsWindowStart = Library.StatsPosition
            CloseTransientUi()
        end

        if Library.Input.Mouse1Released then
            Library.State.StatsDragging = false
        end

        if Library.State.StatsDragging then
            Library.StatsPosition = ClampWindowPosition(Library.State.StatsWindowStart + (Library.Input.MousePos - Library.State.StatsDragStart), statsSize)
            statsPos = Vec2(Library.StatsPosition.X, Library.StatsPosition.Y)
        end
    else
        Library.State.StatsDragging = false
    end

    UpdateRoundedBox(StatsDrawings.Outline, statsPos, statsSize, 8, Library.Palette.Outline, 1, showStats)
    UpdateRoundedBox(StatsDrawings.Background, Vec2(statsPos.X + 1, statsPos.Y + 1), Vec2(statsSize.X - 2, statsSize.Y - 2), 8, Library.Palette.Background, 1, showStats)
    UpdateGradientLine(StatsDrawings.Topline, Vec2(statsPos.X + 1, statsPos.Y + 1), Vec2(statsSize.X - 2, 2), Library.Palette.Accent, Library.Palette.Accent2, showStats)
    StatsDrawings.HeaderLine.Visible = showStats
    StatsDrawings.Title.Visible = showStats
    StatsDrawings.Speed.Visible = showStats
    StatsDrawings.Distance.Visible = showStats
    StatsDrawings.Dot.Visible = showStats

    if showStats then
        StatsDrawings.HeaderLine.Position = Vec2(statsPos.X + 12, statsPos.Y + 40)
        StatsDrawings.HeaderLine.Size = Vec2(statsSize.X - 24, 1)
        StatsDrawings.HeaderLine.Color = Library.Palette.Outline

        local rowX = statsPos.X + 12
        local rowW = statsSize.X - 24
        local rowH = 30
        local row1Y = statsPos.Y + 50
        local row2Y = row1Y + 36
        local row3Y = row2Y + 36
        UpdateRoundedBox(StatsDrawings.Row1, Vec2(rowX, row1Y), Vec2(rowW, rowH), 6, Library.Palette.Element, 1, true)
        UpdateRoundedBox(StatsDrawings.Row2, Vec2(rowX, row2Y), Vec2(rowW, rowH), 6, Library.Palette.Element, 1, true)
        UpdateRoundedBox(StatsDrawings.Row3, Vec2(rowX, row3Y), Vec2(rowW, rowH), 6, Library.Palette.Element, 1, true)

        local speedValue = math.max(0, math.floor(tonumber(RuntimeState.TargetSpeed) or 0))
        local distanceValue = math.max(0, math.floor(tonumber(RuntimeState.TargetDistance) or 0))
        local dotValue = tonumber(RuntimeState.TargetDot) or 0

        StatsDrawings.Title.Position = Vec2(statsPos.X + 12, statsPos.Y + 8)
        StatsDrawings.Title.Text = "BALL STATS"

        StatsDrawings.Speed.Position = Vec2(statsPos.X + 20, row1Y + 8)
        StatsDrawings.Speed.Text = "Ball Speed : " .. tostring(speedValue)
        StatsDrawings.Speed.Color = Library.Palette.Text

        StatsDrawings.Distance.Position = Vec2(statsPos.X + 20, row2Y + 8)
        StatsDrawings.Distance.Text = "Ball Dist  : " .. tostring(distanceValue)
        StatsDrawings.Distance.Color = Library.Palette.Text

        StatsDrawings.Dot.Position = Vec2(statsPos.X + 20, row3Y + 8)
        StatsDrawings.Dot.Text = "Ball Dot   : " .. string.format("%.2f", dotValue)
        StatsDrawings.Dot.Color = Library.Palette.Text
    else
        UpdateRoundedBox(StatsDrawings.Row1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(StatsDrawings.Row2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(StatsDrawings.Row3, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
    end

    if SaveConfigQueued and not IsConfigLoading and not Library.State.ActiveDropdown and not Library.State.ActiveColorDrag and not Library.State.ActiveSlider and not Library.State.ActiveSliderInput and not Library.State.ActiveTextbox and not Library.State.ActiveKeybind then
        SaveGlobalSettings()
        if Config.AutoSave then
            SaveCurrentConfig()
            if ConfigListDropdown then
                ConfigListDropdown:SetOptions(GetAvailableConfigs(), true)
            end
        else
            SaveConfigQueued = false
        end
    end

    if not Library.Visible then
        return
    end

    local sizeX, sizeY = Library.Size.X, Library.Size.Y

    if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, Library.Position, Vector2.new(sizeX, 36)) then
        Library.State.Dragging = true
        Library.State.DragStart = Library.Input.MousePos
        Library.State.WindowStart = Library.TargetPosition
        CloseTransientUi()
    end

    if Library.Input.Mouse1Released then
        Library.State.Dragging = false
        Library.State.ActiveSlider = nil
    end

    if Library.State.Dragging then
        Library.TargetPosition = Library.State.WindowStart + (Library.Input.MousePos - Library.State.DragStart)
        Library.Position = Library.TargetPosition
    else
        Library.Position = Vector2.new(Lerp(Library.Position.X, Library.TargetPosition.X, 0.25), Lerp(Library.Position.Y, Library.TargetPosition.Y, 0.25))
    end

    local posX, posY = Library.Position.X, Library.Position.Y

    UpdateRoundedBox(WindowDrawings.Shadow, Vec2(posX - 3, posY - 3), Vec2(sizeX + 6, sizeY + 6), 6, Color3.new(0, 0, 0), 0.18, true)
    UpdateRoundedBox(WindowDrawings.Outline, Vec2(posX - 1, posY - 1), Vec2(sizeX + 2, sizeY + 2), 6, Library.Palette.Outline, 1, true)
    UpdateRoundedBox(WindowDrawings.Background, Vec2(posX, posY), Vec2(sizeX, sizeY), 6, Library.Palette.Background, 1, true)
    UpdateRoundedBox(WindowDrawings.Topbar, Vec2(posX, posY), Vec2(sizeX, 36), 6, Library.Palette.Sidebar, 1, true)
    UpdateRoundedBox(WindowDrawings.Sidebar, Vec2(posX, posY + 37), Vec2(150, sizeY - 37), 6, Library.Palette.Sidebar, 1, true)
    UpdateGradientLine(WindowDrawings.Topline, Vec2(posX + 1, posY + 1), Vec2(sizeX - 2, 2), Library.Palette.Accent, Library.Palette.Accent2, true)
    UpdateStripePattern(WindowDrawings.PatternBack, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
    UpdateStripePattern(WindowDrawings.PatternFront, 0, 0, 0, 0, 0, 0, Library.Palette.Background, false)
    WindowDrawings.TopBorder.Visible = true
    WindowDrawings.TopBorder.Position = Vec2(posX, posY + 36)
    WindowDrawings.TopBorder.Size = Vec2(sizeX, 1)
    WindowDrawings.TopBorder.Color = Library.Palette.Outline
    WindowDrawings.SidebarLine.Visible = true
    WindowDrawings.SidebarLine.Position = Vec2(posX + 150, posY + 37)
    WindowDrawings.SidebarLine.Size = Vec2(1, sizeY - 37)
    WindowDrawings.SidebarLine.Color = Library.Palette.Outline
    WindowDrawings.Title.Visible = true
    WindowDrawings.Title.Position = Vec2(posX + 15, posY + 11)

    if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, Vector2.new(posX, posY + 37), Vector2.new(150, sizeY - 37)) then
        local yOffset = posY + 42
        for _, tab in ipairs(Library.Tabs) do
            if IsMouseInBounds(Library.Input.MousePos, Vector2.new(posX + 5, yOffset), Vector2.new(140, 32)) then
                Library.CurrentTab = tab
                CloseTransientUi()
                for _, t in ipairs(Library.Tabs) do
                    HideTabContent(t)
                end
            end
            yOffset = yOffset + 36
        end
    end

    if Library.State.KeybindContext.Open and Library.State.KeybindContext.Entry and Library.Visible then
        local menuPos = Library.State.KeybindContext.Position
        local menuSize = Vector2.new(128, 66)
        local optionSize = Vector2.new(118, 24)
        local holdPos = Vec2(menuPos.X + 5, menuPos.Y + 6)
        local togglePos = Vec2(menuPos.X + 5, menuPos.Y + 35)
        local currentMode = GetBindMode(Library.State.KeybindContext.Entry.BindFlag)
        local holdHovered = IsMouseInBounds(Library.Input.MousePos, holdPos, optionSize)
        local toggleHovered = IsMouseInBounds(Library.Input.MousePos, togglePos, optionSize)
        local holdSelected = currentMode == "Hold"
        local toggleSelected = currentMode == "Toggle"

        if Library.Input.Mouse1Clicked then
            if IsMouseInBounds(Library.Input.MousePos, holdPos, optionSize) then
                SetBindMode(Library.State.KeybindContext.Entry.BindFlag, "Hold")
                QueueSaveConfig()
                Library.State.KeybindContext.Open = false
                Library.State.KeybindContext.Entry = nil
            elseif IsMouseInBounds(Library.Input.MousePos, togglePos, optionSize) then
                SetBindMode(Library.State.KeybindContext.Entry.BindFlag, "Toggle")
                QueueSaveConfig()
                Library.State.KeybindContext.Open = false
                Library.State.KeybindContext.Entry = nil
            elseif not IsMouseInBounds(Library.Input.MousePos, menuPos, menuSize) then
                Library.State.KeybindContext.Open = false
                Library.State.KeybindContext.Entry = nil
            end
        elseif Library.Input.Mouse2Clicked and not IsMouseInBounds(Library.Input.MousePos, menuPos, menuSize) then
            Library.State.KeybindContext.Open = false
            Library.State.KeybindContext.Entry = nil
        end

        UpdateRoundedBox(OverlayMenuDrawings.Outline, menuPos, menuSize, 6, Library.Palette.Outline, 1, true)
        UpdateRoundedBox(OverlayMenuDrawings.Background, Vec2(menuPos.X + 1, menuPos.Y + 1), Vec2(menuSize.X - 2, menuSize.Y - 2), 6, Library.Palette.Background, 1, true)
        UpdateRoundedBox(OverlayMenuDrawings.Option1, holdPos, optionSize, 5, holdSelected and Library.Palette.Accent or (holdHovered and Library.Palette.Hover or Library.Palette.Element), 1, true)
        UpdateRoundedBox(OverlayMenuDrawings.Option2, togglePos, optionSize, 5, toggleSelected and Library.Palette.Accent or (toggleHovered and Library.Palette.Hover or Library.Palette.Element), 1, true)

        OverlayMenuDrawings.Option1Text.Visible = true
        OverlayMenuDrawings.Option1Text.Text = "Hold"
        OverlayMenuDrawings.Option1Text.Color = holdSelected and Library.Palette.Text or (holdHovered and Library.Palette.Text or Library.Palette.SubText)
        OverlayMenuDrawings.Option1Text.Position = Vec2(holdPos.X + 42, holdPos.Y + 5)

        OverlayMenuDrawings.Option2Text.Visible = true
        OverlayMenuDrawings.Option2Text.Text = "Toggle"
        OverlayMenuDrawings.Option2Text.Color = toggleSelected and Library.Palette.Text or (toggleHovered and Library.Palette.Text or Library.Palette.SubText)
        OverlayMenuDrawings.Option2Text.Position = Vec2(togglePos.X + 34, togglePos.Y + 5)
    else
        UpdateRoundedBox(OverlayMenuDrawings.Outline, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(OverlayMenuDrawings.Background, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(OverlayMenuDrawings.Option1, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        UpdateRoundedBox(OverlayMenuDrawings.Option2, Vec2(0, 0), Vec2(0, 0), 0, Color3.new(0, 0, 0), 1, false)
        OverlayMenuDrawings.Option1Text.Visible = false
        OverlayMenuDrawings.Option2Text.Visible = false
    end

    if Library.CurrentTab then
        local blockInput = Library.State.Dragging or Library.State.StatsDragging or Library.State.KeybindContext.Open

        if Library.State.ActiveDropdown then
            local dropdown = Library.State.ActiveDropdown
            if Library.Input.Mouse1Clicked then
                local mousePos = Library.Input.MousePos
                local insideCurrentButton = IsMouseInBounds(mousePos, dropdown.ButtonPos, dropdown.ButtonSize)
                local clickedDropdown = nil

                for _, section in ipairs(Library.CurrentTab.Sections) do
                    for _, candidate in ipairs(section.Items) do
                        if candidate.Type == "Dropdown" and IsMouseInBounds(mousePos, candidate.ButtonPos, candidate.ButtonSize) then
                            clickedDropdown = candidate
                            break
                        end
                    end
                    if clickedDropdown then
                        break
                    end
                end

                if clickedDropdown then
                    if clickedDropdown == dropdown then
                        dropdown.IsOpen = false
                        Library.State.ActiveDropdown = nil
                    else
                        dropdown.IsOpen = false
                        clickedDropdown.IsOpen = true
                        clickedDropdown.OpenAlpha = 0
                        clickedDropdown.ListHeight = 0
                        clickedDropdown.TargetListHeight = 0
                        Library.State.ActiveDropdown = clickedDropdown
                    end
                    blockInput = true
                else
                    local pickedOption = nil
                    for index, bounds in ipairs(dropdown.OptionBounds or {}) do
                        if bounds and bounds.Visible and IsMouseInBounds(mousePos, bounds.Pos, bounds.Size) then
                            pickedOption = index
                            break
                        end
                    end

                    if pickedOption and dropdown.Options[pickedOption] ~= nil then
                        Config[dropdown.Flag] = dropdown.Options[pickedOption]
                        if dropdown.Flag == "ThemePreset" then
                            ApplyThemePreset(Config[dropdown.Flag], false)
                            QueueSaveConfig()
                        elseif dropdown.Flag == "SelectedConfig" then
                            Config.SelectedConfig = tostring(Config[dropdown.Flag])
                        else
                            QueueSaveConfig()
                        end
                        dropdown.IsOpen = false
                        Library.State.ActiveDropdown = nil
                        blockInput = true
                    else
                        local insideList = dropdown.IsOpen and IsMouseInBounds(mousePos, dropdown.ListPos, dropdown.ListSize)
                        if not insideCurrentButton and not insideList then
                            dropdown.IsOpen = false
                            Library.State.ActiveDropdown = nil
                            blockInput = true
                        elseif insideCurrentButton then
                            dropdown.IsOpen = false
                            Library.State.ActiveDropdown = nil
                            blockInput = true
                        end
                    end
                end
            elseif Library.Input.Mouse2Clicked then
                dropdown.IsOpen = false
                Library.State.ActiveDropdown = nil
                blockInput = true
            end
        end

        if Library.State.ActiveColorPicker then
            local picker = Library.State.ActiveColorPicker
            if Library.Input.Mouse1Clicked and not Library.State.ActiveColorDrag then
                local insideButton = IsMouseInBounds(Library.Input.MousePos, picker.ButtonPos, picker.ButtonSize)
                local insidePopup = picker.IsOpen and IsMouseInBounds(Library.Input.MousePos, picker.PopupPos, picker.PopupSize)
                if not insideButton and not insidePopup then
                    picker.IsOpen = false
                    Library.State.ActiveColorPicker = nil
                end
            end
        end

        if Library.State.ActiveSliderInput and Library.Input.Mouse1Clicked then
            local activeInput = Library.State.ActiveSliderInput
            local clickedValue = IsMouseInBounds(Library.Input.MousePos, activeInput.ValuePos, activeInput.ValueSize)
            if not clickedValue then
                CommitSliderInput(activeInput)
                Library.State.ActiveSliderInput = nil
            end
        end

        if not blockInput then
            for _, section in ipairs(Library.CurrentTab.Sections) do
                for _, item in ipairs(section.Items) do
                    if item.Type == "Toggle" then
                        if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, item.HitboxPos, item.HitboxSize) then
                            if Library.State.ActiveSliderInput then
                                CommitSliderInput(Library.State.ActiveSliderInput)
                                Library.State.ActiveSliderInput = nil
                            end
                            Config[item.Flag] = not Config[item.Flag]
                            QueueSaveConfig()
                        end
                    elseif item.Type == "Slider" then
                        if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, item.ValuePos, item.ValueSize) then
                            if Library.State.ActiveSliderInput and Library.State.ActiveSliderInput ~= item then
                                CommitSliderInput(Library.State.ActiveSliderInput)
                            end
                            Library.State.ActiveSliderInput = item
                            item.InputBuffer = FormatSliderValue(Config[item.Flag], item.Step)
                            Library.State.ActiveSlider = nil
                            Library.State.ActiveTextbox = nil
                            Library.State.ActiveKeybind = nil
                        elseif Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, item.BarPos - Vector2.new(0, 4), item.BarSize + Vector2.new(0, 8)) then
                            if Library.State.ActiveSliderInput then
                                CommitSliderInput(Library.State.ActiveSliderInput)
                                Library.State.ActiveSliderInput = nil
                            end
                            Library.State.ActiveSlider = item
                        end
                    elseif item.Type == "Dropdown" then
                        if Library.Input.Mouse1Clicked and not Library.State.ActiveDropdown and IsMouseInBounds(Library.Input.MousePos, item.ButtonPos, item.ButtonSize) then
                            if Library.State.ActiveSliderInput then
                                CommitSliderInput(Library.State.ActiveSliderInput)
                                Library.State.ActiveSliderInput = nil
                            end
                            if Library.State.ActiveColorPicker then
                                Library.State.ActiveColorPicker.IsOpen = false
                                Library.State.ActiveColorPicker = nil
                            end
                            item.IsOpen = true
                            item.OpenAlpha = 0
                            item.ListHeight = 0
                            item.TargetListHeight = 0
                            Library.State.ActiveDropdown = item
                            blockInput = true
                        end
                    elseif item.Type == "ColorPicker" then
                        if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, item.ButtonPos, item.ButtonSize) then
                            if Library.State.ActiveColorPicker and Library.State.ActiveColorPicker ~= item then
                                Library.State.ActiveColorPicker.IsOpen = false
                            end
                            if Library.State.ActiveSliderInput then
                                CommitSliderInput(Library.State.ActiveSliderInput)
                                Library.State.ActiveSliderInput = nil
                            end
                            item.IsOpen = not item.IsOpen
                            Library.State.ActiveColorPicker = item.IsOpen and item or nil
                            Library.State.ActiveKeybind = nil
                            Library.State.ActiveTextbox = nil
                            Library.State.ActiveDropdown = nil
                        elseif item.IsOpen and Library.Input.Mouse1Clicked then
                            if IsMouseInBounds(Library.Input.MousePos, item.SVPos, item.SVSize) then
                                Library.State.ActiveColorPicker = item
                                Library.State.ActiveColorDrag = "SV"
                            elseif IsMouseInBounds(Library.Input.MousePos, item.HuePos, item.HueSize) then
                                Library.State.ActiveColorPicker = item
                                Library.State.ActiveColorDrag = "Hue"
                            end
                        end
                    elseif item.Type == "Keybind" then
                        if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, item.ButtonPos, item.ButtonSize) then
                            Library.State.ActiveKeybind = item
                            if Library.State.ActiveSliderInput then
                                CommitSliderInput(Library.State.ActiveSliderInput)
                                Library.State.ActiveSliderInput = nil
                            end
                            Library.State.ActiveTextbox = nil
                            if Library.State.ActiveColorPicker then
                                Library.State.ActiveColorPicker.IsOpen = false
                                Library.State.ActiveColorPicker = nil
                            end
                            Library.State.HotkeysContext.Open = false
                            Library.State.HotkeysContext.Entry = nil
                            Library.State.KeybindContext.Open = false
                            Library.State.KeybindContext.Entry = nil
                        elseif Library.Input.Mouse2Clicked and IsMouseInBounds(Library.Input.MousePos, item.ButtonPos, item.ButtonSize) then
                            Library.State.ActiveKeybind = nil
                            if Library.State.ActiveSliderInput then
                                CommitSliderInput(Library.State.ActiveSliderInput)
                                Library.State.ActiveSliderInput = nil
                            end
                            Library.State.ActiveTextbox = nil
                            Library.State.KeybindContext.Open = true
                            Library.State.KeybindContext.Entry = {
                                BindFlag = item.Flag,
                                ToggleFlag = GetToggleFlagFromBindFlag(item.Flag),
                                Label = item.Label and item.Label.Text or "Bind",
                                Item = item
                            }
                            local contextPos = GetContextMenuPosition(item)
                            Library.State.KeybindContext.Position = Vector2.new(contextPos.X, contextPos.Y)
                        end
                    elseif item.Type == "Button" then
                        if Library.Input.Mouse1Clicked and IsMouseInBounds(Library.Input.MousePos, item.ButtonPos, item.ButtonSize) then
                            if item.Callback then
                                item.Callback()
                            end
                        end
                    elseif item.Type == "Textbox" then
                        if Library.Input.Mouse1Clicked then
                            if IsMouseInBounds(Library.Input.MousePos, item.BoxPos, item.BoxSize) then
                                Library.State.ActiveTextbox = item
                                Library.State.ActiveKeybind = nil
                                if Library.State.ActiveSliderInput then
                                    CommitSliderInput(Library.State.ActiveSliderInput)
                                    Library.State.ActiveSliderInput = nil
                                end
                                if Library.State.ActiveColorPicker then
                                    Library.State.ActiveColorPicker.IsOpen = false
                                    Library.State.ActiveColorPicker = nil
                                end
                                Library.State.KeybindContext.Open = false
                                Library.State.KeybindContext.Entry = nil
                            elseif Library.State.ActiveTextbox == item then
                                Library.State.ActiveTextbox = nil
                            end
                        end
                    end
                end
            end
        end
    end

    if not Library.Input.Mouse1Down then
        Library.State.ActiveColorDrag = nil
    end

    if Library.State.ActiveColorPicker and Library.State.ActiveColorDrag then
        local picker = Library.State.ActiveColorPicker
        if Library.State.ActiveColorDrag == "SV" and picker.SVPos and picker.SVSize then
            picker.Sat = Clamp((Library.Input.MousePos.X - picker.SVPos.X) / picker.SVSize.X, 0, 1)
            picker.Val = 1 - Clamp((Library.Input.MousePos.Y - picker.SVPos.Y) / picker.SVSize.Y, 0, 1)
            QueueSaveConfig()
        elseif Library.State.ActiveColorDrag == "Hue" and picker.HuePos and picker.HueSize then
            picker.Hue = Clamp((Library.Input.MousePos.X - picker.HuePos.X) / picker.HueSize.X, 0, 1)
            QueueSaveConfig()
        end
    end

    if Library.State.ActiveSlider and Library.State.ActiveSlider.BarSize then
        local slider = Library.State.ActiveSlider
        if Library.Input.Mouse1Down then
            local left = slider.BarPos.X
            local width = math.max(slider.BarSize.X, 1)
            local percentage = Clamp((Library.Input.MousePos.X - left) / width, 0, 1)
            Config[slider.Flag] = ClampSliderValue(slider.Min + (percentage * (slider.Max - slider.Min)), slider.Min, slider.Max, slider.Step)
            QueueSaveConfig()
        else
            Library.State.ActiveSlider = nil
        end
    end

    local tabYOffset = posY + 42
    for _, tab in ipairs(Library.Tabs) do
        local isCurrent = tab == Library.CurrentTab
        local tabPos = Vec2(posX + 5, tabYOffset)
        local tabSize = Vec2(140, 32)

        tab.BgAlpha = Lerp(tab.BgAlpha, isCurrent and 1 or 0, 0.18)
        UpdateRoundedBox(tab.Background, tabPos, tabSize, 4, Library.Palette.Hover, 0.88 * tab.BgAlpha, isCurrent or tab.BgAlpha > 0.02)
        UpdateRoundedBox(tab.Indicator, Vec2(posX, tabYOffset + 8), Vec2(2, 16), 2, Library.Palette.Accent, 1, isCurrent)

        tab.CurrentColor = LerpColor(tab.CurrentColor, isCurrent and Library.Palette.Text or Library.Palette.SubText, 0.15)
        tab.CurrentIconColor = LerpColor(tab.CurrentIconColor, isCurrent and Library.Palette.Accent or Library.Palette.SubText, 0.15)
        tab.IconDraw.Visible = false
        tab.Label.Visible = true
        tab.Label.Position = Vec2(posX + 17, tabYOffset + 8)

        tab.Label.Color = tab.CurrentColor
        tabYOffset = tabYOffset + 36

        if not isCurrent then
            HideTabContent(tab)
        end

        if isCurrent then
            local colWidth = (sizeX - 150 - 30) / 2
            local leftY, rightY = posY + 46, posY + 46

            for _, section in ipairs(tab.Sections) do
                local sectionX = section.Side == "Left" and (posX + 160) or (posX + 160 + colWidth + 10)
                local sectionY = section.Side == "Left" and leftY or rightY
                local itemY = sectionY + 32

                for _, item in ipairs(section.Items) do
                    item:Update(sectionX + 8, itemY, colWidth - 16)
                    itemY = itemY + item.Height
                end

                section:UpdateContainer(sectionX, sectionY, colWidth, itemY - sectionY + 6)

                if section.Side == "Left" then
                    leftY = itemY + 16
                else
                    rightY = itemY + 16
                end
            end
        else
            for _, section in ipairs(tab.Sections) do
                SetVisible(section.Outline, false)
                SetVisible(section.Background, false)
                HideStripePattern(section.PatternBack)
                HideStripePattern(section.PatternFront)
                section.Title.Visible = false
                section.Line.Visible = false
                for _, item in ipairs(section.Items) do
                    if item.Label then item.Label.Visible = false end
                    if item.ValueLabel then item.ValueLabel.Visible = false end
                    if item.Icon then UpdateKeybindImageIcon(item.Icon, Vec2(-1000, -1000), Library.Palette.Text, false) end
                    if item.IconDraw then item.IconDraw.Visible = false end
                    if item.BoxStroke then SetVisible(item.BoxStroke, false) end
                    if item.Box then SetVisible(item.Box, false) end
                    if item.Fill then SetVisible(item.Fill, false) end
                    if item.Stroke then SetVisible(item.Stroke, false) end
                    if item.Background then SetVisible(item.Background, false) end
                    if item.Knob then SetVisible(item.Knob, false) end
                    if item.ListStroke then SetVisible(item.ListStroke, false) end
                    if item.ListBackground then SetVisible(item.ListBackground, false) end
                    if item.ButtonStroke then SetVisible(item.ButtonStroke, false) end
                    if item.ButtonBox then SetVisible(item.ButtonBox, false) end
                    if item.OptionDrawings then
                        for _, optionDrawing in pairs(item.OptionDrawings) do
                            optionDrawing.Visible = false
                        end
                    end
                    if item.PreviewStroke then SetVisible(item.PreviewStroke, false) end
                    if item.Preview then SetVisible(item.Preview, false) end
                    if item.PopupStroke then SetVisible(item.PopupStroke, false) end
                    if item.PopupBackground then SetVisible(item.PopupBackground, false) end
                    if item.SVStroke then SetVisible(item.SVStroke, false) end
                    if item.HueStroke then SetVisible(item.HueStroke, false) end
                    if item.AlphaStroke then SetVisible(item.AlphaStroke, false) end
                    if item.SVGrid then HideGridSquares(item.SVGrid) end
                    if item.HueGrid then HideGridSquares(item.HueGrid) end
                    if item.AlphaGrid then HideGridSquares(item.AlphaGrid) end
                    if item.InfoHex then item.InfoHex.Visible = false end
                    if item.InfoRgb then item.InfoRgb.Visible = false end
                    if item.InfoAlpha then item.InfoAlpha.Visible = false end
                    if item.CursorOuter then item.CursorOuter.Visible = false end
                    if item.CursorInner then item.CursorInner.Visible = false end
                    if item.HueLine then item.HueLine.Visible = false end
                    if item.AlphaLine then item.AlphaLine.Visible = false end
                end
            end
        end
    end
end)

local function ResetRuntimeState()
    RuntimeState.LastParry = 0
    RuntimeState.Target = nil
    RuntimeState.TrajectoryCache = {}
    RuntimeState.PingHistory = {}
    RuntimeState.SpamExpiration = 0
    RuntimeState.SpamModeActive = false
    RuntimeState.ConsecutiveParries = 0
    RuntimeState.SpamCooldown = 0
    RuntimeState.ScheduledTrigger = 0
    RuntimeState.IsExecutingParry = false
    RuntimeState.AerodynamicActive = false
    RuntimeState.AerodynamicTime = 0
    RuntimeState.LastBallSpawn = 0
    RuntimeState.TargetSpeed = 0
    RuntimeState.TargetDistance = 0
    RuntimeState.TargetDot = 0
end

ResetRuntimeState()


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

local function GetRawPing()
    local currentPing = 60
    pcall(function()
        local network = StatsService:FindFirstChild("Network")
        local stats = network and network:FindFirstChild("ServerStatsItem")
        local pingObj = stats and stats:FindFirstChild("Data Ping")
        if pingObj then
            if memory_read and pingObj.Address then
                local ok, value = pcall(function()
                    return memory_read("double", pingObj.Address + 0xC8)
                end)
                if ok and type(value) == "number" and value > 0 then
                    currentPing = value
                else
                    currentPing = tonumber(pingObj.Value) or currentPing
                end
            else
                currentPing = tonumber(pingObj.Value) or currentPing
            end
        end
    end)
    return math.min(currentPing, 650)
end

local function IsTargetingMe(targetName)
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Highlight") then
        return true
    end
    if not targetName then
        return false
    end
    local myName = string.lower(LocalPlayer.Name or "")
    local myDisplay = string.lower(LocalPlayer.DisplayName or LocalPlayer.Name or "")
    local target = string.lower(tostring(targetName))
    if target == myName or target == myDisplay then
        return true
    end
    local clean = string.gsub(target, '%.%.%.$', '')
    if #clean >= 3 then
        if string.sub(myName, 1, #clean) == clean or string.sub(myDisplay, 1, #clean) == clean then
            return true
        end
        if string.find(myName, clean, 1, true) or string.find(myDisplay, clean, 1, true) then
            return true
        end
    end
    return false
end

local function ScanNearestEntity(playerPosition)
    local nearest, nearestDistance = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart") or plr.Character.PrimaryPart
            local humanoid = plr.Character:FindFirstChild("Humanoid")
            if root and humanoid and humanoid.Health > 0 then
                local dist = Distance(playerPosition, root.Position)
                if dist < nearestDistance then
                    nearestDistance = dist
                    nearest = plr
                end
            end
        end
    end
    return nearest, nearestDistance
end

local function CheckIsSpam(params)
    local pingScaled = params.Ping / 10
    local range = pingScaled + math.min(params.Speed / 6.5, 95)
    if params.EntityDistance > range then
        return false, params.Parries
    end
    if params.BallDistance > range then
        return false, params.Parries
    end
    local maxSpeed = 5.0 - math.min(params.Speed / 5.0, 5.0)
    local maxDot = math.clamp(params.Dot or 0, -1, 0) * maxSpeed
    local accuracy = math.min(range - maxDot, 30)
    if params.BallDistance <= accuracy and params.Parries >= 5 then
        return true, params.Parries
    end
    return false, params.Parries
end

local function AnalyzeTrajectory(ballPosition, ballVelocity, playerPosition)
    local toPlayer = Flatten(playerPosition - ballPosition)
    local velFlat = Flatten(ballVelocity)
    local dirToPlayer = Normalize(toPlayer)
    local velDir = Normalize(velFlat)
    local currentDot = Dot(dirToPlayer, velDir)
    if currentDot ~= currentDot then
        currentDot = 1
    end
    table.insert(AutoRuntime.CurveHistory, velFlat)
    if #AutoRuntime.CurveHistory > 8 then
        table.remove(AutoRuntime.CurveHistory, 1)
    end
    local angularDeviation = 0
    if #AutoRuntime.CurveHistory >= 4 then
        for i = 2, #AutoRuntime.CurveHistory do
            local prev = Normalize(AutoRuntime.CurveHistory[i - 1])
            local curr = Normalize(AutoRuntime.CurveHistory[i])
            local velocityDot = math.clamp(Dot(prev, curr), -1, 1)
            local angle = math.deg(math.acos(velocityDot))
            if angle ~= angle then
                angle = 0
            end
            local dynamicThreshold = math.clamp(40 / math.max(Magnitude(ballVelocity), 1), 1.0, 3.0)
            if angle > dynamicThreshold then
                angularDeviation = angularDeviation + (angle / dynamicThreshold)
            end
        end
    end
    local isCurving = angularDeviation > 3 and currentDot < 0.5
    return currentDot, isCurving
end

local function DetectWarp(ballPosition, dt)
    if dt <= 0 then
        return false
    end
    if AutoRuntime.LastBallPos == Vector3.zero then
        return false
    end
    local velMag = Magnitude(AutoRuntime.LastBallVel)
    if velMag < 3 then
        return false
    end
    local expected = AutoRuntime.LastBallPos + (AutoRuntime.LastBallVel * dt)
    local deviation = Distance(ballPosition, expected)
    return deviation > 3.0
end

local function GetParryThreshold(ballPosition, ballVelocity, ballSpeed, playerPosition, ping, dt)
    local cappedSpeed = math.min(ballSpeed, Config.CappedSpeed)
    local dotValue, isCurving = AnalyzeTrajectory(ballPosition, ballVelocity, playerPosition)
    RuntimeState.TargetDot = dotValue
    local speedDiff = math.min(math.max(cappedSpeed - 9.5, 0), Config.CappedSpeed)
    local divisor = (Config.SpeedDivisorBase + (speedDiff * Config.SpeedDivisorMultiplier)) * Config.SpeedDivisionFactor
    local speedContribution = math.max(cappedSpeed / math.max(divisor, 0.01), 9.5)
    
    local Ping_Max = ping
    local Ping_Min = ping
    for _, p in ipairs(AutoRuntime.PingHistory) do
        if p > Ping_Max then Ping_Max = p end
        if p < Ping_Min then Ping_Min = p end
    end
    
    local Ping_Jitter = Ping_Max - Ping_Min
    local Jitter_Buffer = 0
    if Ping_Jitter > 20 then
        Jitter_Buffer = (Ping_Jitter / 10) * Config.PingMultiplier * 1.5
    end

    local Frame_Lag_Buffer = 0
    if dt > 0.03 then
        Frame_Lag_Buffer = ballSpeed * dt * 0.8
    end

    local baseThreshold = (ping / 10) * Config.PingMultiplier + speedContribution + Jitter_Buffer + Frame_Lag_Buffer

    baseThreshold = math.max(baseThreshold, Config.BaseMinParryAccuracy)
    if DetectWarp(ballPosition, dt) then
        AutoRuntime.WarpDetectedAt = tick()
    end
    local timeSinceWarp = tick() - AutoRuntime.WarpDetectedAt
    if timeSinceWarp < 0.55 then
        baseThreshold = baseThreshold + (6.0 * (1 - (timeSinceWarp / 0.55)))
    end
    local ballDistance = Distance(playerPosition, ballPosition)
    if Config.DotProtect and dotValue <= Config.DotThreshold and cappedSpeed >= Config.DotMinSpeed and ballDistance <= Config.DotDistanceThreshold then
        local angleFactor = 1 - (dotValue / math.max(Config.DotThreshold, 0.001))
        local dotLimit = (ping / 10) + ballDistance * 0.8 + angleFactor * 10
        baseThreshold = math.min(baseThreshold, math.max(dotLimit, 55))
    end
    if isCurving then
        local distanceSlice = math.clamp(ballDistance * 0.5, 15, 35)
        baseThreshold = math.max(baseThreshold - distanceSlice, 10)
    end
    return baseThreshold, dotValue, isCurving
end

local function ExecuteParryAction(isLobby, ballDot, isCurving)
    if RuntimeState.IsExecutingParry then
        return
    end
    RuntimeState.IsExecutingParry = true
    local curved = false
    if not isLobby and Config.AutoCurve then
        if Config.AutoCurveMode == "Backwards" or (ballDot and ballDot < -0.1) or isCurving then
            local deltaX = math.floor(8000 * Config.CameraSens)
            curved = true
            task.spawn(function()
                if mousemoverel then
                    mousemoverel(deltaX, 0)
                end
                DoClick()
                if mousemoverel then
                    mousemoverel(-deltaX, 0)
                end
                RuntimeState.IsExecutingParry = false
            end)
        elseif Config.AutoCurveMode == "High" then
            local deltaY = -(600 * Config.CameraSens)
            curved = true
            task.spawn(function()
                if mousemoverel then
                    mousemoverel(0, deltaY)
                end
                DoClick()
                if mousemoverel then
                    mousemoverel(0, -deltaY)
                end
                RuntimeState.IsExecutingParry = false
            end)
        end
    end
    if not curved then
        task.spawn(function()
            DoClick()
            RuntimeState.IsExecutingParry = false
        end)
    end
end

local function GetBestBall()
    local bestBall = nil
    local folders = {Workspace:FindFirstChild("Balls"), Workspace:FindFirstChild("TrainingBalls")}
    for fIdx, folder in ipairs(folders) do
        if folder then
            for _, ball in ipairs(folder:GetChildren()) do
                if ball:GetAttribute("realBall") or fIdx == 2 then
                    bestBall = ball
                    break
                end
            end
        end
        if bestBall then
            break
        end
    end
    return bestBall
end

RunService.Heartbeat:Connect(function(dt)
    dt = dt or 0.016
    local character = LocalPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    if not root or not humanoid or humanoid.Health <= 0 then
        AutoRuntime.AutoSpam = false
        AutoRuntime.CurveHistory = {}
        AutoRuntime.Parried = false
        AutoRuntime.TriggerParried = false
        RuntimeState.TargetSpeed = 0
        RuntimeState.TargetDistance = 0
        RuntimeState.TargetDot = 0
        return
    end

    local ball = GetBestBall()
    AutoRuntime.Ball = ball
    if not ball then
        AutoRuntime.AutoSpam = false
        AutoRuntime.Parries = 0
        AutoRuntime.Cooldown = false
        AutoRuntime.LastTarget = nil
        AutoRuntime.CurveHistory = {}
        RuntimeState.TargetSpeed = 0
        RuntimeState.TargetDistance = 0
        RuntimeState.TargetDot = 0
        return
    end

    local playerPos = root.Position
    local predictedPlayerPos = playerPos
    local ballPos = ball.Position
    local ballVel = ball.AssemblyLinearVelocity
    local ballSpeed = Magnitude(ballVel)
    local targetName = ball:GetAttribute("target")
    local targetingMe = IsTargetingMe(targetName)
    local isTrainingBall = ball:IsDescendantOf(Workspace:FindFirstChild("TrainingBalls"))
    
    local ping = GetRawPing()
    table.insert(AutoRuntime.PingHistory, ping)
    while #AutoRuntime.PingHistory > math.max(5, math.floor(Config.PingSampleCount)) do
        table.remove(AutoRuntime.PingHistory, 1)
    end

    RuntimeState.TargetSpeed = ballSpeed
    RuntimeState.TargetDistance = Distance(predictedPlayerPos, ballPos)

    if targetName ~= AutoRuntime.LastTarget then
        AutoRuntime.Cooldown = false
        local deltaChange = tick() - (AutoRuntime.LastTargetChange or 0)
        if deltaChange <= 0.35 then
            AutoRuntime.Parries = AutoRuntime.Parries + 1
        else
            AutoRuntime.Parries = 1
            AutoRuntime.AutoSpam = false
        end
        AutoRuntime.LastTarget = targetName
        AutoRuntime.LastTargetChange = tick()
        AutoRuntime.CurveHistory = {}
    end

    local _, nearestDistance = ScanNearestEntity(predictedPlayerPos)
    local threshold, dotValue, isCurving = GetParryThreshold(ballPos, ballVel, ballSpeed, predictedPlayerPos, ping, dt)
    RuntimeState.TargetDot = dotValue

    local spamParams = {
        Speed = ballSpeed,
        Parries = AutoRuntime.Parries,
        BallDistance = RuntimeState.TargetDistance,
        EntityDistance = nearestDistance,
        Dot = dotValue,
        Ping = ping
    }
    
    if targetingMe and Config.AutoSpam then
        AutoRuntime.AutoSpam = CheckIsSpam(spamParams)
    else
        AutoRuntime.AutoSpam = false
    end

    local validTarget = targetingMe or (Config.LobbyParry and isTrainingBall)
    local canAutoParry = Config.AutoParry or Config.LobbyParry
    
    if canAutoParry then
        if validTarget then
            local sinceSpawn = tick() - RuntimeState.LastBallSpawn
            if not Config.NoClickOnBallSpawn or sinceSpawn > 0.12 then
                if RuntimeState.TargetDistance <= threshold and ballSpeed >= Config.MinThreatSpeed then
                    if not AutoRuntime.Parried then
                        AutoRuntime.Parried = true
                        ExecuteParryAction(Config.LobbyParry and isTrainingBall and not Config.AutoParry, dotValue, isCurving)
                    end
                end
            end
        else
            AutoRuntime.Parried = false
        end
    end

    if Config.TriggerbotEnabled then
        if targetingMe then
            if RuntimeState.TargetDistance <= math.max(8, threshold * 0.35) then
                if not AutoRuntime.TriggerParried then
                    if tick() - AutoRuntime.LastParryAt >= math.max(0.02, Config.ParryCooldown) then
                        AutoRuntime.TriggerParried = true
                        AutoRuntime.LastParryAt = tick()
                        ExecuteParryAction(false, dotValue, isCurving)
                    end
                end
            end
        else
            AutoRuntime.TriggerParried = false
        end
    end

    AutoRuntime.LastBallPos = ballPos
    AutoRuntime.LastBallVel = ballVel
    AutoRuntime.LastBallSpeed = ballSpeed
end)

RunService.Heartbeat:Connect(function()
    local folders = {Workspace:FindFirstChild("Balls"), Workspace:FindFirstChild("TrainingBalls")}
    local realBallFound = false
    for fIdx, folder in ipairs(folders) do
        if folder then
            for _, ball in ipairs(folder:GetChildren()) do
                if ball:GetAttribute("realBall") or fIdx == 2 then
                    realBallFound = true
                    break
                end
            end
        end
        if realBallFound then
            break
        end
    end
    if realBallFound and RuntimeState.LastBallSpawn <= 0 then
        RuntimeState.LastBallSpawn = tick()
    elseif not realBallFound then
        RuntimeState.LastBallSpawn = tick()
    end
end)
