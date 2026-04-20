local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local textService = game:GetService("TextService")
local httpService = game:GetService("HttpService")
local workspaceService = game:GetService("Workspace")
local playersService = game:GetService("Players")
local env = (getgenv and getgenv()) or (getfenv and getfenv()) or _G
local matchaIsMouse1Pressed = rawget(env, "ismouse1pressed")
local matchaIsMouse2Pressed = rawget(env, "ismouse2pressed")
local matchaIsKeyPressed = rawget(env, "iskeypressed")
local matchaSetClipboard = rawget(env, "setclipboard") or rawget(env, "toclipboard")
local matchaGetClipboard = rawget(env, "getclipboard") or rawget(env, "fromclipboard")

local LibraryApi = {
    Flags = {},
    FolderName = "Nightfall",
    ConfigName = "AutoSaveConfig.json"
}

local colors = {
    mainBackground = Color3.new(0.035294, 0.035294, 0.050980),
    sidebarBackground = Color3.new(0.050980, 0.050980, 0.066666),
    sectionBackground = Color3.new(0.066666, 0.066666, 0.082352),
    elementBackground = Color3.new(0.090196, 0.090196, 0.105882),
    elementHoverBackground = Color3.new(0.121568, 0.121568, 0.145098),
    borderColor = Color3.new(0.105882, 0.105882, 0.133333),
    borderLightColor = Color3.new(0.172549, 0.172549, 0.211764),
    accentColor = Color3.new(0.423529, 0.576470, 0.988235),
    accentGradientColor1 = Color3.new(0.423529, 0.576470, 0.988235),
    accentGradientColor2 = Color3.new(0.619607, 0.462745, 0.988235),
    textWhiteColor = Color3.new(0.952941, 0.952941, 0.972549),
    textDarkColor = Color3.new(0.541176, 0.541176, 0.580392),
    tooltipBackground = Color3.new(0.043137, 0.043137, 0.058823),
    shadowColor = Color3.new(0, 0, 0),
    notificationInfoColor = Color3.new(0.247058, 0.635294, 0.980392),
    notificationSuccessColor = Color3.new(0.247058, 0.980392, 0.490196),
    notificationWarningColor = Color3.new(0.980392, 0.819607, 0.247058),
    notificationErrorColor = Color3.new(0.980392, 0.247058, 0.247058)
}

local FONT_MAIN = Drawing.Fonts.System
local FONT_SUB = Drawing.Fonts.System

local hideGroup

local UI = {
    windows = {},
    drawables = {},
    initialized = false,
    mousePos = Vector2.zero,
    mouseDown = false,
    active = nil,
    hovered = nil,
    focusedTextbox = nil,
    bindingKey = nil,
    tooltip = nil,
    connections = {},
    blinkClock = 0,
    openDropdown = nil,
    openColorPicker = nil,
    notifications = {},
    backspaceHeld = false,
    deleteHeld = false,
    nextTextRepeat = 0
}

local function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpColor(a, b, t)
    return Color3.new(lerp(a.R, b.R, t), lerp(a.G, b.G, t), lerp(a.B, b.B, t))
end

local function round(n)
    return math.floor(n + 0.5)
end

local function pointInRect(p, x, y, w, h)
    return p.X >= x and p.X <= x + w and p.Y >= y and p.Y <= y + h
end

local function getMousePosition()
    local ok, value = pcall(function()
        return userInputService:GetMouseLocation()
    end)
    if ok and value then
        return value
    end
    local lp = playersService.LocalPlayer
    if lp then
        local mouse = lp:GetMouse()
        if mouse then
            return Vector2.new(mouse.X or 0, mouse.Y or 0)
        end
    end
    return UI and UI.mousePos or Vector2.zero
end

local function isMouse1Held()
    if type(matchaIsMouse1Pressed) == "function" then
        local ok, value = pcall(matchaIsMouse1Pressed)
        if ok then
            return not not value
        end
    end
    return UI and UI.mouseDown or false
end

local function isMouse2Held()
    if type(matchaIsMouse2Pressed) == "function" then
        local ok, value = pcall(matchaIsMouse2Pressed)
        if ok then
            return not not value
        end
    end
    return false
end

local function isShiftHeld()
    local okL, left = pcall(function() return userInputService:IsKeyDown(Enum.KeyCode.LeftShift) end)
    local okR, right = pcall(function() return userInputService:IsKeyDown(Enum.KeyCode.RightShift) end)
    if (okL and left) or (okR and right) then
        return true
    end
    if type(matchaIsKeyPressed) == "function" then
        local ok1, v1 = pcall(matchaIsKeyPressed, 160)
        local ok2, v2 = pcall(matchaIsKeyPressed, 161)
        return (ok1 and v1) or (ok2 and v2) or false
    end
    return false
end

local function setClipboardText(text)
    local fn = matchaSetClipboard or rawget(getfenv and getfenv() or _G, "setclipboard") or rawget(getfenv and getfenv() or _G, "toclipboard")
    if type(fn) == "function" then
        return pcall(fn, text)
    end
    return false
end

local function getClipboardText()
    local env = getfenv and getfenv() or _G
    local fn = matchaGetClipboard or rawget(env, "getclipboard") or rawget(env, "fromclipboard")
    if type(fn) == "function" then
        local ok, result = pcall(fn)
        if ok and type(result) == "string" then
            return result
        end
    end
    return nil
end



local keyCodeNameCache = nil

local function getKeyCodeName(key)
    if key == nil then
        return "None"
    end
    local okName, name = pcall(function()
        return key.Name
    end)
    if okName and type(name) == "string" and name ~= "" then
        return name
    end
    if type(key) == "string" then
        return key
    end
    if keyCodeNameCache == nil then
        keyCodeNameCache = {}
        local okEnum, enumTable = pcall(function()
            return Enum.KeyCode
        end)
        if okEnum and type(enumTable) == "table" then
            for enumName, enumValue in pairs(enumTable) do
                if keyCodeNameCache[enumValue] == nil then
                    keyCodeNameCache[enumValue] = tostring(enumName)
                end
            end
        end
    end
    return keyCodeNameCache[key] or tostring(key)
end

local function colorToHSV(color)
    local okMethod, h, s, v = pcall(function()
        return color:ToHSV()
    end)
    if okMethod then
        return h, s, v
    end
    local okStatic, sh, ss, sv = pcall(function()
        return Color3.toHSV(color)
    end)
    if okStatic then
        return sh, ss, sv
    end
    local r = tonumber(color and color.R) or 0
    local g = tonumber(color and color.G) or 0
    local b = tonumber(color and color.B) or 0
    local maxc = math.max(r, g, b)
    local minc = math.min(r, g, b)
    local delta = maxc - minc
    local hh = 0
    if delta > 0 then
        if maxc == r then
            hh = ((g - b) / delta) % 6
        elseif maxc == g then
            hh = ((b - r) / delta) + 2
        else
            hh = ((r - g) / delta) + 4
        end
        hh = hh / 6
    end
    local ss = maxc == 0 and 0 or (delta / maxc)
    local vv = maxc
    return hh, ss, vv
end


local function getViewportSize()
    local candidates = {}
    pcall(function()
        if workspaceService.CurrentCamera and workspaceService.CurrentCamera.ViewportSize then
            table.insert(candidates, workspaceService.CurrentCamera.ViewportSize)
        end
    end)
    pcall(function()
        local cam = workspaceService.Camera
        if cam and cam.ViewportSize then
            table.insert(candidates, cam.ViewportSize)
        end
    end)
    for _, v in ipairs(candidates) do
        local x = tonumber(v.X) or 0
        local y = tonumber(v.Y) or 0
        if x > 100 and y > 100 then
            return Vector2.new(x, y)
        end
    end
    return Vector2.new(1280, 720)
end

local function colorToHex(color)
    return string.format("#%02X%02X%02X", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
end

local function parseClipboardColor(text)
    if type(text) ~= "string" then
        return nil
    end
    local source = text:match("^%s*(.-)%s*$")
    if source == "" then
        return nil
    end
    local hex = source:match("^#?(%x%x%x%x%x%x)$")
    if hex then
        local r = tonumber(hex:sub(1, 2), 16)
        local g = tonumber(hex:sub(3, 4), 16)
        local b = tonumber(hex:sub(5, 6), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
    end
    local short = source:match("^#?(%x%x%x)$")
    if short then
        local r = tonumber(short:sub(1, 1) .. short:sub(1, 1), 16)
        local g = tonumber(short:sub(2, 2) .. short:sub(2, 2), 16)
        local b = tonumber(short:sub(3, 3) .. short:sub(3, 3), 16)
        if r and g and b then
            return Color3.fromRGB(r, g, b)
        end
    end
    local rgb = { source:match("^%s*(%d+)%s*[, ]%s*(%d+)%s*[, ]%s*(%d+)%s*$") }
    if #rgb == 3 then
        local r = clamp(tonumber(rgb[1]) or 0, 0, 255)
        local g = clamp(tonumber(rgb[2]) or 0, 0, 255)
        local b = clamp(tonumber(rgb[3]) or 0, 0, 255)
        return Color3.fromRGB(r, g, b)
    end
    return nil
end

local function getTextSize(text, size)
    local content = tostring(text or "")
    local textSize = tonumber(size) or 12
    local fontEnum = nil
    pcall(function()
        if Enum and Enum.Font then
            fontEnum = Enum.Font.GothamMedium or Enum.Font.SourceSans or Enum.Font.Legacy
        end
    end)
    if textService and textService.GetTextSize and fontEnum then
        local ok, bounds = pcall(function()
            return textService:GetTextSize(content, textSize, fontEnum, Vector2.new(1000, 1000))
        end)
        if ok and bounds then
            return tonumber(bounds.X) or 0, tonumber(bounds.Y) or textSize
        end
    end
    local width = math.floor(#content * (textSize * 0.55))
    local height = math.floor(textSize + 2)
    return width, height
end

local function getCenteredTextPosition(x, y, w, h, text, size)
    local tw, th = getTextSize(text, size)
    return Vector2.new(round(x + (w - tw) * 0.5), round(y + (h - th) * 0.5))
end

local function newDrawing(class, props)
    local object = Drawing.new(class)
    for k, v in pairs(props) do
        object[k] = v
    end
    table.insert(UI.drawables, object)
    return object
end

local function freeDrawing(object)
    if not object then return end
    pcall(function()
        object.Visible = false
        object:Remove()
    end)
end

local function trySetVisible(target, state)
    if not target then
        return
    end
    pcall(function()
        if target.Visible ~= nil then
            target.Visible = state
        end
    end)
end

local function setVisible(drawings, state)
    if type(drawings) ~= "table" then
        return
    end
    for key, drawing in pairs(drawings) do
        if key ~= "__isGroup" then
            if type(drawing) == "table" and rawget(drawing, "__isGroup") then
                setVisible(drawing, state)
            else
                trySetVisible(drawing, state)
            end
        end
    end
end

local function createGroup()
    return { __isGroup = true }
end

local function addToGroup(group, item)
    table.insert(group, item)
    return item
end

local function createRoundedPrimitive(z, color, transparency)
    local group = createGroup()
    group.mid = addToGroup(group, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = transparency or 1, Color = color, ZIndex = z, Visible = false }))
    group.left = addToGroup(group, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = transparency or 1, Color = color, ZIndex = z, Visible = false }))
    group.right = addToGroup(group, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = transparency or 1, Color = color, ZIndex = z, Visible = false }))
    group.tl = addToGroup(group, newDrawing("Circle", { Filled = true, Thickness = 1, NumSides = 28, Transparency = transparency or 1, Radius = 0, Color = color, ZIndex = z, Visible = false }))
    group.tr = addToGroup(group, newDrawing("Circle", { Filled = true, Thickness = 1, NumSides = 28, Transparency = transparency or 1, Radius = 0, Color = color, ZIndex = z, Visible = false }))
    group.bl = addToGroup(group, newDrawing("Circle", { Filled = true, Thickness = 1, NumSides = 28, Transparency = transparency or 1, Radius = 0, Color = color, ZIndex = z, Visible = false }))
    group.br = addToGroup(group, newDrawing("Circle", { Filled = true, Thickness = 1, NumSides = 28, Transparency = transparency or 1, Radius = 0, Color = color, ZIndex = z, Visible = false }))
    return group
end

local function setRoundedPrimitive(group, x, y, w, h, radius, color, transparency, visible)
    local pieces = { group.mid, group.left, group.right, group.tl, group.tr, group.bl, group.br }
    if not visible or w <= 0 or h <= 0 then
        for _, piece in ipairs(pieces) do
            piece.Visible = false
        end
        return
    end

    local r = math.floor(math.max(0, math.min(radius or 0, w * 0.5, h * 0.5)))
    local function apply(piece)
        piece.Color = color
        piece.Transparency = transparency or 1
        piece.Visible = true
    end

    if r <= 0 then
        apply(group.mid)
        group.mid.Position = Vector2.new(x, y)
        group.mid.Size = Vector2.new(w, h)
        group.left.Visible = false
        group.right.Visible = false
        group.tl.Visible = false
        group.tr.Visible = false
        group.bl.Visible = false
        group.br.Visible = false
        return
    end

    apply(group.mid)
    group.mid.Position = Vector2.new(x + r, y)
    group.mid.Size = Vector2.new(math.max(1, w - r * 2), h)

    apply(group.left)
    group.left.Position = Vector2.new(x, y + r)
    group.left.Size = Vector2.new(r, math.max(1, h - r * 2))

    apply(group.right)
    group.right.Position = Vector2.new(x + w - r, y + r)
    group.right.Size = Vector2.new(r, math.max(1, h - r * 2))

    for _, circle in ipairs({ group.tl, group.tr, group.bl, group.br }) do
        apply(circle)
        circle.Radius = r
    end

    group.tl.Position = Vector2.new(x + r, y + r)
    group.tr.Position = Vector2.new(x + w - r, y + r)
    group.bl.Position = Vector2.new(x + r, y + h - r)
    group.br.Position = Vector2.new(x + w - r, y + h - r)
end

local function createSoftFrame(z)
    local group = createGroup()
    group.shadow = addToGroup(group, createRoundedPrimitive(z, colors.shadowColor or Color3.fromRGB(0, 0, 0), 0.16))
    group.border = addToGroup(group, createRoundedPrimitive(z + 1, colors.borderColor, 0.95))
    group.fill = addToGroup(group, createRoundedPrimitive(z + 2, colors.elementBackground, 0.92))
    return group
end

local function setSoftFrame(frame, x, y, w, h, radius, fillColor, fillTransparency, borderColor, borderTransparency, shadowOffset)
    local shadowY = shadowOffset or 2
    setRoundedPrimitive(frame.shadow, x, y + shadowY, w, h, radius + 1, colors.shadowColor or Color3.fromRGB(0, 0, 0), 0.12, true)
    setRoundedPrimitive(frame.border, x, y, w, h, radius, borderColor or colors.borderColor, borderTransparency or 1, true)
    setRoundedPrimitive(frame.fill, x + 1, y + 1, w - 2, h - 2, math.max(0, radius - 1), fillColor or colors.elementBackground, fillTransparency or 0.92, true)
end


local function normalizeStep(step)
    if type(step) == "number" then
        if step > 0 then
            return step
        end
        return nil
    end
    if type(step) == "string" then
        local n = tonumber(step)
        if n and n > 0 then
            return n
        end
    end
    return nil
end

local function snapValue(value, step)
    step = normalizeStep(step)
    if not step then
        return value
    end
    local snapped = math.floor((value / step) + 0.5) * step
    local precision = tostring(step):match("%.(%d+)")
    if precision then
        return tonumber(string.format("%." .. tostring(#precision) .. "f", snapped))
    end
    return snapped
end

local function formatValue(value, step)
    if type(value) ~= "number" then
        return tostring(value)
    end
    if math.abs(value) < 0.000001 then
        value = 0
    end
    local decimals = 2
    if step and type(step) == "number" and step > 0 then
        local precision = tostring(step):match("%.(%d+)")
        if precision then
            decimals = math.min(#precision, 2)
        else
            decimals = 0
        end
    else
        local frac = math.abs(value - math.floor(value))
        decimals = frac < 0.001 and 0 or 2
    end
    local formatted = string.format("%." .. tostring(decimals) .. "f", value)
    formatted = formatted:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
    if formatted == "-0" then
        formatted = "0"
    end
    return formatted
end

local function hsvToColor(h, s, v)
    return Color3.fromHSV(clamp(h, 0, 1), clamp(s, 0, 1), clamp(v, 0, 1))
end

local function saveConfiguration()
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(LibraryApi.FolderName) then
            makefolder(LibraryApi.FolderName)
        end
        local data = {}
        for key, value in pairs(LibraryApi.Flags) do
            if typeof(value) == "Color3" then
                data[key] = { Type = "Color3", R = value.R, G = value.G, B = value.B }
            elseif typeof(value) == "EnumItem" then
                data[key] = { Type = "KeyCode", Name = value.Name }
            elseif type(value) == "table" and value.Min ~= nil and value.Max ~= nil then
                data[key] = { Type = "Range", Min = value.Min, Max = value.Max }
            else
                data[key] = value
            end
        end
        writefile(LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName, httpService:JSONEncode(data))
    end)
end

local function loadConfiguration()
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local path = LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName
        if not isfile(path) then return end
        local decoded = httpService:JSONDecode(readfile(path))
        if type(decoded) ~= "table" then return end
        for key, value in pairs(decoded) do
            if type(value) == "table" and value.Type == "Color3" then
                LibraryApi.Flags[key] = Color3.new(value.R, value.G, value.B)
            elseif type(value) == "table" and value.Type == "KeyCode" then
                LibraryApi.Flags[key] = Enum.KeyCode[value.Name] or Enum.KeyCode.Unknown
            elseif type(value) == "table" and value.Type == "Range" then
                LibraryApi.Flags[key] = { Min = value.Min, Max = value.Max }
            else
                LibraryApi.Flags[key] = value
            end
        end
    end)
end

loadConfiguration()

local tooltip = createGroup()
tooltip.bg = addToGroup(tooltip, newDrawing("Square", { Visible = false, Filled = true, Thickness = 1, Transparency = 0.96, Color = colors.tooltipBackground, ZIndex = 500 }))
tooltip.border = addToGroup(tooltip, newDrawing("Square", { Visible = false, Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderLightColor, ZIndex = 501 }))
tooltip.text = addToGroup(tooltip, newDrawing("Text", { Visible = false, Size = 12, Font = FONT_MAIN, Outline = false, Center = false, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 502, Text = "" }))

local function hideTooltip()
    tooltip.bg.Visible = false
    tooltip.border.Visible = false
    tooltip.text.Visible = false
end

local function drawTooltip(text)
    if not text or text == "" then
        hideTooltip()
        return
    end
    local tw, th = getTextSize(text, 12)
    local x = UI.mousePos.X + 16
    local y = UI.mousePos.Y + 16
    tooltip.bg.Position = Vector2.new(x, y)
    tooltip.bg.Size = Vector2.new(tw + 14, th + 10)
    tooltip.border.Position = tooltip.bg.Position
    tooltip.border.Size = tooltip.bg.Size
    tooltip.text.Text = text
    tooltip.text.Position = Vector2.new(x + 7, y + 5)
    tooltip.bg.Visible = true
    tooltip.border.Visible = true
    tooltip.text.Visible = true
end

local function closeOpenDropdown(element)
    if UI.openDropdown and UI.openDropdown ~= element then
        UI.openDropdown.open = false
    end
    UI.openDropdown = element and element.open and element or nil
end

local function closeOpenColorPicker(element)
    if UI.openColorPicker and UI.openColorPicker ~= element then
        UI.openColorPicker.open = false
    end
    UI.openColorPicker = element and element.open and element or nil
end

local function focusTextbox(box)
    if UI.focusedTextbox and UI.focusedTextbox ~= box then
        UI.focusedTextbox.focused = false
    end
    UI.focusedTextbox = box
    if box then
        box.focused = true
        box.cursorBlink = 0
    end
end

local function deleteFocusedTextboxChar()
    if not UI.focusedTextbox then
        return
    end
    local text = tostring(UI.focusedTextbox.value or "")
    if #text <= 0 then
        return
    end
    UI.focusedTextbox.value = text:sub(1, #text - 1)
    LibraryApi.Flags[UI.focusedTextbox.flag] = UI.focusedTextbox.value
    saveConfiguration()
    if UI.focusedTextbox.callback then
        task.spawn(UI.focusedTextbox.callback, UI.focusedTextbox.value)
    end
end

local function beginKeybind(element)
    UI.bindingKey = element
end

local function endKeybind()
    UI.bindingKey = nil
end

local function addNotification(text, kind, duration)
    table.insert(UI.notifications, {
        text = tostring(text or ""),
        kind = kind or "info",
        duration = tonumber(duration) or 3,
        born = tick(),
        alpha = 0
    })
end

LibraryApi.Notify = addNotification

local function createBaseElement(section, kind, height)
    local element = {
        section = section,
        window = section.window,
        tab = section.tab,
        kind = kind,
        height = height or 18,
        relY = 0,
        rect = nil,
        drawings = createGroup(),
        visible = true,
        hovered = false,
        pressable = false,
        tooltip = nil,
        dynamicHeight = nil,
        parentModule = section.parentModule
    }
    table.insert(section.elements, element)
    return element
end

local function ensureFlag(flag, default)
    if LibraryApi.Flags[flag] == nil then
        LibraryApi.Flags[flag] = default
    end
    return LibraryApi.Flags[flag]
end

local function sanitizeFlagPart(value)
    value = tostring(value or "value"):lower()
    value = value:gsub("%s+", "_"):gsub("[^%w_]", "")
    if value == "" then
        value = "value"
    end
    return value
end

local function makeAutoFlag(section, name)
    local parts = {}
    if section and section.window and section.window.title then
        table.insert(parts, sanitizeFlagPart(section.window.title))
    end
    if section and section.tab and section.tab.title then
        table.insert(parts, sanitizeFlagPart(section.tab.title))
    end
    if section and section.title then
        table.insert(parts, sanitizeFlagPart(section.title))
    end
    table.insert(parts, sanitizeFlagPart(name))
    return table.concat(parts, ".")
end

local function normalizeSectionArgs(first, second)
    local side
    local title
    local firstText = tostring(first or "")
    local firstLower = string.lower(firstText)
    if firstLower == "left" or firstLower == "right" then
        side = firstText
        title = second
    else
        title = first
        side = second
    end
    side = tostring(side or "Left")
    if string.lower(side) == "right" then
        side = "Right"
    else
        side = "Left"
    end
    return side, tostring(title or "Section")
end

local function isElementVisibleInLayout(element)
    if not element then
        return false
    end
    if element.visible == false then
        return false
    end
    if element.parentModule then
        return LibraryApi.Flags[element.parentModule.flag] == true
    end
    return true
end

local function createWindowDrawings(window)
    local g = createGroup()
    g.body = addToGroup(g, createSoftFrame(20))
    g.top = addToGroup(g, createSoftFrame(26))
    g.sidebar = addToGroup(g, createSoftFrame(24))
    g.accentGlow = addToGroup(g, createRoundedPrimitive(33, colors.accentGradientColor2, 0.18))
    g.accent = addToGroup(g, createRoundedPrimitive(34, colors.accentColor, 1))
    g.topBorder = addToGroup(g, createRoundedPrimitive(28, colors.borderColor, 0.9))
    g.sidebarBorder = addToGroup(g, createRoundedPrimitive(28, colors.borderColor, 0.9))
    g.title = addToGroup(g, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Outline = true, Center = false, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 35, Visible = true, Text = window.title }))
    g.tabIndicatorGlow = addToGroup(g, createRoundedPrimitive(33, colors.accentColor, 0.14))
    g.tabIndicator = addToGroup(g, createRoundedPrimitive(34, colors.accentColor, 1))
    window.drawings = g
end

local function createTabDrawings(tab)
    local g = createGroup()
    g.button = addToGroup(g, createSoftFrame(30))
    g.indicatorGlow = addToGroup(g, createRoundedPrimitive(33, colors.accentColor, 0.22))
    g.indicator = addToGroup(g, createRoundedPrimitive(34, colors.accentColor, 1))
    g.icon = addToGroup(g, newDrawing("Text", { Size = 14, Font = FONT_MAIN, Outline = false, Center = false, Transparency = 1, Color = colors.textDarkColor, ZIndex = 35, Visible = true, Text = tostring(tab.icon or "•") }))
    g.text = addToGroup(g, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Outline = false, Center = false, Transparency = 1, Color = colors.textDarkColor, ZIndex = 35, Visible = true, Text = tab.title }))
    tab.drawings = g
end

local function createSectionDrawings(section)
    local g = createGroup()
    g.frame = addToGroup(g, createSoftFrame(40))
    g.title = addToGroup(g, newDrawing("Text", { Size = 13, Font = FONT_MAIN, Outline = false, Center = false, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 43, Visible = true, Text = section.title }))
    g.sep = addToGroup(g, createRoundedPrimitive(42, colors.borderColor, 0.85))
    section.drawings = g
end

local function setWindowVisible(window, state)
    window.visible = state
    if not state then
        if UI.focusedTextbox and UI.focusedTextbox.window == window then
            focusTextbox(nil)
        end
        if UI.bindingKey and UI.bindingKey.window == window then
            endKeybind()
        end
        if UI.active and UI.active.window == window then
            UI.active = nil
        end
        if UI.openDropdown and UI.openDropdown.window == window then
            UI.openDropdown.open = false
            hideGroup(UI.openDropdown.popup)
            UI.openDropdown = nil
        end
        if UI.openColorPicker and UI.openColorPicker.window == window then
            UI.openColorPicker.open = false
            UI.openColorPicker.animOpen = 0
            hideGroup(UI.openColorPicker.popup)
            UI.openColorPicker = nil
        end
        setVisible(window.drawings, false)
        for _, tab in ipairs(window.tabs or {}) do
            setVisible(tab.drawings, false)
            for _, section in ipairs(tab.sections or {}) do
                setVisible(section.drawings, false)
                for _, element in ipairs(section.elements or {}) do
                    setElementBaseVisible(element, false)
                    if element.popup then
                        hideGroup(element.popup)
                    end
                end
            end
        end
    end
end

local function getVisibleWindows()
    local windows = {}
    for _, window in ipairs(UI.windows) do
        if window.visible then
            table.insert(windows, window)
        end
    end
    return windows
end

local function bringWindowToFront(window)
    for i, w in ipairs(UI.windows) do
        if w == window then
            table.remove(UI.windows, i)
            break
        end
    end
    table.insert(UI.windows, window)
end

local function layoutWindow(window)
    window.topHeight = 36
    window.sidebarWidth = 150
    window.contentPadding = 10
    window.tabButtonHeight = 32
    window.tabButtonGap = 4
    window.sectionTitleHeight = 24
    window.contentX = math.floor(window.x + 151 + window.contentPadding)
    window.contentY = math.floor(window.y + 37 + window.contentPadding)
    window.contentW = math.floor(window.w - 151 - (window.contentPadding * 2))
    window.contentH = math.floor(window.h - 37 - (window.contentPadding * 2))
    window.columnGap = 10
    window.columnWidth = math.floor((window.contentW - window.columnGap) / 2)

    local d = window.drawings
    setSoftFrame(d.body, window.x, window.y, window.w, window.h, 6, colors.mainBackground, 0.81626, colors.borderColor, 1, 2)
    setSoftFrame(d.top, window.x, window.y, window.w, 36, 6, colors.sidebarBackground, 0.78153, colors.borderColor, 0, 0)
    setSoftFrame(d.sidebar, window.x, window.y + 37, 150, window.h - 37, 6, colors.sidebarBackground, 0.78153, colors.borderColor, 0, 1)
    setRoundedPrimitive(d.accentGlow, window.x + 0, window.y + 0, window.w, 2, 1, colors.accentGradientColor2, 0.16, true)
    setRoundedPrimitive(d.accent, window.x + 0, window.y + 0, window.w, 2, 1, colors.accentColor, 1, true)
    setRoundedPrimitive(d.topBorder, window.x + 0, window.y + 36, window.w, 1, 0, colors.borderColor, 0.85, true)
    setRoundedPrimitive(d.sidebarBorder, window.x + 150, window.y + 37, 1, window.h - 37, 0, colors.borderColor, 0.85, true)
    d.title.Position = Vector2.new(window.x + 15, window.y + 11)

    for _, tab in ipairs(window.tabs) do
        if tab.drawings then
            hideGroup(tab.drawings.indicatorGlow)
            hideGroup(tab.drawings.indicator)
        end
    end

    local activeTabY = nil

    for index, tab in ipairs(window.tabs) do
        tab.x = window.x + 5
        tab.y = window.y + 42 + (index - 1) * (window.tabButtonHeight + window.tabButtonGap)
        tab.w = 140
        tab.h = window.tabButtonHeight
        local td = tab.drawings
        local active = tab == window.activeTab
        setSoftFrame(td.button, tab.x, tab.y, tab.w, tab.h, 4, active and colors.elementHoverBackground or colors.sidebarBackground, active and 0.78153 or 0.0, active and colors.borderLightColor or colors.borderColor, active and 0.18 or 0.0, 0)
        hideGroup(td.indicatorGlow)
        hideGroup(td.indicator)
        if active then
            activeTabY = tab.y
        end
        td.icon.Text = tostring(tab.icon or "•")
        td.icon.Position = Vector2.new(tab.x + 12, tab.y + 8)
        td.icon.Color = active and colors.accentColor or colors.textDarkColor
        td.text.Position = Vector2.new(tab.x + 34, tab.y + 9)
    end

    if activeTabY then
        setRoundedPrimitive(d.tabIndicatorGlow, window.x + 5, activeTabY + 7, 2, 18, 1, colors.accentColor, 0.14, true)
        setRoundedPrimitive(d.tabIndicator, window.x + 5, activeTabY + 7, 2, 18, 1, colors.accentColor, 1, true)
    else
        hideGroup(d.tabIndicatorGlow)
        hideGroup(d.tabIndicator)
    end

    if not window.activeTab then return end

    local leftY = window.contentY
    local rightY = window.contentY

    for _, section in ipairs(window.activeTab.sections) do
        local columnX = math.floor(section.side == "Left" and window.contentX or (window.contentX + window.columnWidth + window.columnGap))
        local contentWidth = math.floor(window.columnWidth)
        local startY = math.floor(section.side == "Left" and leftY or rightY)
        local currentY = startY + 32
        section.x = columnX
        section.y = startY
        section.w = contentWidth
        section.contentX = columnX + 10
        section.contentY = startY + 32
        section.contentW = contentWidth - 20
        section.viewportBottomPadding = 10

        for _, element in ipairs(section.elements) do
            local visibleInLayout = isElementVisibleInLayout(element)
            local indent = element.parentModule and 12 or 0
            if element.dynamicHeight then
                element.height = element:dynamicHeight()
            end
            element._indent = indent
            element._baseY = math.floor(currentY)
            if visibleInLayout then
                local extra = element.height or 0
                currentY = math.floor(currentY + extra + 8)
            end
        end

        local contentHeight = math.max(38, math.floor(currentY - startY + 8))
        local availableHeight = math.max(0, math.floor(window.contentY + window.contentH - startY))
        section.h = math.min(contentHeight, availableHeight)
        section.scrollMax = math.max(0, contentHeight - section.h)
        section.scroll = clamp(section.scroll or 0, 0, section.scrollMax)
        section.viewportTop = section.contentY
        section.viewportBottom = section.y + section.h - section.viewportBottomPadding

        for _, element in ipairs(section.elements) do
            element.x = math.floor(section.contentX + (element._indent or 0))
            element.y = math.floor((element._baseY or section.contentY) - (section.scroll or 0))
            element.w = math.floor(section.contentW - (element._indent or 0))
        end

        local sd = section.drawings
        if section.h > 0 then
            setSoftFrame(sd.frame, section.x, section.y, section.w, section.h, 6, colors.sectionBackground, 0.78153, colors.borderColor, 0.90, 1)
            sd.title.Position = Vector2.new(section.x + 12, section.y + 8)
            setRoundedPrimitive(sd.sep, section.x + 12, section.y + 28, section.w - 24, 1, 0, colors.borderColor, 0.42, true)
        else
            hideGroup(sd.frame)
            trySetVisible(sd.title, false)
            trySetVisible(sd.sep, false)
        end

        if section.side == "Left" then
            leftY = math.floor(section.y + section.h + 10)
        else
            rightY = math.floor(section.y + section.h + 10)
        end
    end
end

local function forEachElement(window, callback)
    if not window.activeTab then return end
    for _, section in ipairs(window.activeTab.sections) do
        callback(section)
        for _, element in ipairs(section.elements) do
            callback(element)
        end
    end
end

local setTooltipText

local function drawTab(tab)
    local active = tab.window.activeTab == tab
    local hovered = UI.hovered == tab
    tab.drawings.text.Color = active and colors.textWhiteColor or (hovered and Color3.fromRGB(188, 194, 208) or colors.textDarkColor)
    if hovered then
        setTooltipText(tab.title)
    end
end

hideGroup = function(group)
    if type(group) ~= "table" then
        return
    end
    for key, drawing in pairs(group) do
        if key ~= "__isGroup" then
            if type(drawing) == "table" and rawget(drawing, "__isGroup") then
                hideGroup(drawing)
            else
                trySetVisible(drawing, false)
            end
        end
    end
end

local function setElementBaseVisible(element, visible)
    if type(element) ~= "table" or type(element.drawings) ~= "table" then
        return
    end
    for key, drawing in pairs(element.drawings) do
        if key ~= "__isGroup" then
            if type(drawing) == "table" and rawget(drawing, "__isGroup") then
                if visible then
                    setVisible(drawing, true)
                else
                    hideGroup(drawing)
                end
            else
                trySetVisible(drawing, visible)
            end
        end
    end
end

local function isElementInsideViewport(element)
    local section = element.section
    if not section then
        return true
    end
    local top = tonumber(section.viewportTop) or tonumber(section.contentY) or tonumber(section.y) or 0
    local sectionY = tonumber(section.y) or top
    local sectionH = tonumber(section.h) or 0
    local bottom = tonumber(section.viewportBottom) or (sectionY + sectionH)
    local elemTop = tonumber(element.y) or 0
    local elemBottom = elemTop + (tonumber(element.height) or 0)
    return elemBottom >= top and elemTop <= bottom
end

local function renderElement(element)
    if not element.window.visible or element.window.activeTab ~= element.tab or not isElementVisibleInLayout(element) or not isElementInsideViewport(element) then
        setElementBaseVisible(element, false)
        return
    end
    element:draw()
end

local function renderWindow(window)
    local visible = window.visible
    setVisible(window.drawings, visible)
    if not visible then
        for _, tab in ipairs(window.tabs) do
            setVisible(tab.drawings, false)
            for _, section in ipairs(tab.sections) do
                setVisible(section.drawings, false)
                for _, element in ipairs(section.elements) do
                    setElementBaseVisible(element, false)
                end
            end
        end
        return
    end

    for _, tab in ipairs(window.tabs) do
        setVisible(tab.drawings, true)
        drawTab(tab)
        local active = window.activeTab == tab
        for _, section in ipairs(tab.sections) do
            setVisible(section.drawings, active)
            if active then
                for _, element in ipairs(section.elements) do
                    renderElement(element)
                end
            else
                for _, element in ipairs(section.elements) do
                    setElementBaseVisible(element, false)
                end
            end
        end
    end
end

local function getTopWindowAtMouse()
    for i = #UI.windows, 1, -1 do
        local window = UI.windows[i]
        if window.visible and pointInRect(UI.mousePos, window.x, window.y, window.w, window.h) then
            return window
        end
    end
end

local function hitTestElement(window)
    if not window or not window.visible then return nil end

    if UI.openColorPicker and UI.openColorPicker.window == window and UI.openColorPicker.open then
        local cp = UI.openColorPicker
        if pointInRect(UI.mousePos, cp.popupX, cp.popupY, cp.popupW, cp.popupH) then
            return cp
        end
    end

    if UI.openDropdown and UI.openDropdown.window == window and UI.openDropdown.open then
        local dd = UI.openDropdown
        if pointInRect(UI.mousePos, dd.popupX, dd.popupY, dd.popupW, dd.popupH) then
            return dd
        end
    end

    if window.activeTab then
        for si = #window.activeTab.sections, 1, -1 do
            local section = window.activeTab.sections[si]
            for ei = #section.elements, 1, -1 do
                local element = section.elements[ei]
                if isElementVisibleInLayout(element) and isElementInsideViewport(element) and element.hitTest and element:hitTest(UI.mousePos) then
                    return element
                end
            end
        end
    end

    for i = #window.tabs, 1, -1 do
        local tab = window.tabs[i]
        if pointInRect(UI.mousePos, tab.x, tab.y, tab.w, tab.h) then
            return tab
        end
    end

    if pointInRect(UI.mousePos, window.x, window.y, window.w, window.topHeight) then
        return window
    end

    return nil
end

setTooltipText = function(text)
    UI.tooltip = text
end


local function initialize()
    if UI.initialized then return end
    UI.initialized = true

    local keyWatch = {
        Enum.KeyCode.Delete,
        Enum.KeyCode.Backspace,
        Enum.KeyCode.Return,
        Enum.KeyCode.Space,
        Enum.KeyCode.A, Enum.KeyCode.B, Enum.KeyCode.C, Enum.KeyCode.D, Enum.KeyCode.E, Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.I, Enum.KeyCode.J, Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.M,
        Enum.KeyCode.N, Enum.KeyCode.O, Enum.KeyCode.P, Enum.KeyCode.Q, Enum.KeyCode.R, Enum.KeyCode.S, Enum.KeyCode.T, Enum.KeyCode.U, Enum.KeyCode.V, Enum.KeyCode.W, Enum.KeyCode.X, Enum.KeyCode.Y, Enum.KeyCode.Z,
        Enum.KeyCode.Zero, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six, Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine,
        Enum.KeyCode.Minus, Enum.KeyCode.Equals, Enum.KeyCode.LeftBracket, Enum.KeyCode.RightBracket, Enum.KeyCode.Semicolon, Enum.KeyCode.Quote, Enum.KeyCode.Comma, Enum.KeyCode.Period, Enum.KeyCode.Slash, Enum.KeyCode.Backquote, Enum.KeyCode.BackSlash
    }

    UI.keyState = UI.keyState or {}
    UI.prevMouse1 = false
    UI.prevMouse2 = false

    local function pollKeyDown(keyCode)
        local ok, value = pcall(function()
            return userInputService:IsKeyDown(keyCode)
        end)
        if ok then
            return not not value
        end
        return false
    end

    local function onDeleteToggle()
        local targetState = true
        for _, window in ipairs(UI.windows) do
            if window.visible then
                targetState = false
                break
            end
        end
        UI.mouseDown = false
        UI.active = nil
        if UI.openDropdown then
            UI.openDropdown.open = false
            hideGroup(UI.openDropdown.popup)
            UI.openDropdown = nil
        end
        if UI.openColorPicker then
            UI.openColorPicker.open = false
            UI.openColorPicker.animOpen = 0
            hideGroup(UI.openColorPicker.popup)
            UI.openColorPicker = nil
        end
        for _, window in ipairs(UI.windows) do
            setWindowVisible(window, targetState)
        end
    end

    local function appendFocusedTextboxChar(char)
        if not (UI.focusedTextbox and char and char ~= "") then return end
        local shifted = isShiftHeld()
        if shifted then
            local shiftMap = {
                ["1"] = "!", ["2"] = "@", ["3"] = "#", ["4"] = "$", ["5"] = "%", ["6"] = "^", ["7"] = "&", ["8"] = "*", ["9"] = "(", ["0"] = ")",
                ["-"] = "_", ["="] = "+", ["["] = "{", ["]"] = "}", [";"] = ":", ["'"] = '"', [","] = "<", ["."] = ">", ["/"] = "?", ["\\"] = "|", ["`"] = "~"
            }
            char = shiftMap[char] or string.upper(char)
        end
        UI.focusedTextbox.value = UI.focusedTextbox.value .. char
        LibraryApi.Flags[UI.focusedTextbox.flag] = UI.focusedTextbox.value
        saveConfiguration()
        if UI.focusedTextbox.callback then
            task.spawn(UI.focusedTextbox.callback, UI.focusedTextbox.value)
        end
    end

    local function onMouse1Pressed()
        UI.mouseDown = true
        UI.mousePos = getMousePosition()
        local topWindow = getTopWindowAtMouse()
        if topWindow then
            bringWindowToFront(topWindow)
            local hit = hitTestElement(topWindow)
            UI.hovered = hit
            if UI.openDropdown and UI.openDropdown.window == topWindow and UI.openDropdown.open and hit ~= UI.openDropdown then
                if not pointInRect(UI.mousePos, UI.openDropdown.popupX, UI.openDropdown.popupY, UI.openDropdown.popupW, UI.openDropdown.popupH) then
                    UI.openDropdown.open = false
                    hideGroup(UI.openDropdown.popup)
                    UI.openDropdown = nil
                end
            end
            if UI.openColorPicker and UI.openColorPicker.window == topWindow and UI.openColorPicker.open and hit ~= UI.openColorPicker then
                if not pointInRect(UI.mousePos, UI.openColorPicker.popupX, UI.openColorPicker.popupY, UI.openColorPicker.popupW, UI.openColorPicker.popupH) then
                    UI.openColorPicker.open = false
                    UI.openColorPicker.animOpen = 0
                    hideGroup(UI.openColorPicker.popup)
                    UI.openColorPicker = nil
                end
            end
            if hit == topWindow then
                UI.active = { type = "windowdrag", window = topWindow, offX = UI.mousePos.X - topWindow.x, offY = UI.mousePos.Y - topWindow.y }
                focusTextbox(nil)
            elseif hit and hit.kind == "textbox" then
                focusTextbox(hit)
                hit:onMouseDown(UI.mousePos)
            elseif hit and hit.onMouseDown then
                focusTextbox(nil)
                hit:onMouseDown(UI.mousePos)
            elseif hit and hit.title then
                focusTextbox(nil)
                topWindow.activeTab = hit
                if UI.openDropdown then UI.openDropdown.open = false hideGroup(UI.openDropdown.popup) UI.openDropdown = nil end
                if UI.openColorPicker then UI.openColorPicker.open = false UI.openColorPicker.animOpen = 0 hideGroup(UI.openColorPicker.popup) UI.openColorPicker = nil end
            else
                focusTextbox(nil)
            end
        else
            focusTextbox(nil)
            if UI.openDropdown then UI.openDropdown.open = false hideGroup(UI.openDropdown.popup) UI.openDropdown = nil end
            if UI.openColorPicker then UI.openColorPicker.open = false UI.openColorPicker.animOpen = 0 hideGroup(UI.openColorPicker.popup) UI.openColorPicker = nil end
        end
    end

    local function onMouse2Pressed()
        UI.mousePos = getMousePosition()
        local topWindow = getTopWindowAtMouse()
        if topWindow then
            bringWindowToFront(topWindow)
            local hit = hitTestElement(topWindow)
            if hit and hit.onMouse2Down then
                hit:onMouse2Down(UI.mousePos)
            end
        end
    end

    local function onMouse1Released()
        UI.mouseDown = false
        if UI.active then
            if UI.active.type == "slider" and UI.active.element.onMouseUp then
                UI.active.element:onMouseUp(UI.mousePos)
            elseif UI.active.type == "rangeslider" and UI.active.element.onMouseUp then
                UI.active.element:onMouseUp(UI.mousePos)
            elseif UI.active.type == "colorpicker" and UI.active.element.onMouseUp then
                UI.active.element:onMouseUp(UI.mousePos)
            end
        end
        UI.active = nil
    end

    UI.connections.render = runService.RenderStepped:Connect(function(dt)
        UI.mousePos = getMousePosition()
        UI.blinkClock = UI.blinkClock + dt
        UI.tooltip = nil

        local mouse1 = isMouse1Held()
        local mouse2 = isMouse2Held()

        if mouse1 and not UI.prevMouse1 then
            onMouse1Pressed()
        elseif (not mouse1) and UI.prevMouse1 then
            onMouse1Released()
        end

        if mouse2 and not UI.prevMouse2 then
            onMouse2Pressed()
        end

        UI.prevMouse1 = mouse1
        UI.prevMouse2 = mouse2

        for _, keyCode in ipairs(keyWatch) do
            local down = pollKeyDown(keyCode)
            local wasDown = UI.keyState[keyCode]
            if down and not wasDown then
                if UI.bindingKey then
                    if keyCode == Enum.KeyCode.Backspace or keyCode == Enum.KeyCode.Delete then
                        LibraryApi.Flags[UI.bindingKey.flag] = Enum.KeyCode.Unknown
                    elseif keyCode ~= Enum.KeyCode.Unknown then
                        LibraryApi.Flags[UI.bindingKey.flag] = keyCode
                    end
                    if UI.bindingKey.callback then
                        task.spawn(UI.bindingKey.callback, LibraryApi.Flags[UI.bindingKey.flag])
                    end
                    saveConfiguration()
                    UI.bindingKey.waiting = false
                    endKeybind()
                elseif keyCode == Enum.KeyCode.Delete then
                    onDeleteToggle()
                elseif keyCode == Enum.KeyCode.Backspace then
                    UI.backspaceHeld = true
                    UI.nextTextRepeat = tick() + 0.38
                    deleteFocusedTextboxChar()
                elseif keyCode == Enum.KeyCode.Return then
                    if UI.focusedTextbox then
                        UI.focusedTextbox.focused = false
                        UI.focusedTextbox = nil
                    end
                elseif UI.focusedTextbox and keyCode == Enum.KeyCode.Space then
                    appendFocusedTextboxChar(" ")
                elseif UI.focusedTextbox then
                    local ok, char = pcall(function()
                        return userInputService:GetStringForKeyCode(keyCode)
                    end)
                    if ok and char and char ~= "" then
                        appendFocusedTextboxChar(char)
                    end
                end
            elseif (not down) and wasDown then
                if keyCode == Enum.KeyCode.Backspace then
                    UI.backspaceHeld = false
                elseif keyCode == Enum.KeyCode.Delete then
                    UI.deleteHeld = false
                end
            end
            UI.keyState[keyCode] = down
        end

        local deleteDown = pollKeyDown(Enum.KeyCode.Delete)
        if deleteDown and not UI.bindingKey then
            UI.deleteHeld = true
        elseif not deleteDown then
            UI.deleteHeld = false
        end

        if UI.mouseDown and not mouse1 then
            UI.mouseDown = false
            if UI.active and UI.active.element and UI.active.element.onMouseUp then
                UI.active.element:onMouseUp(UI.mousePos)
            end
            UI.active = nil
        end

        if UI.focusedTextbox and (UI.backspaceHeld or UI.deleteHeld) and tick() >= (UI.nextTextRepeat or 0) then
            deleteFocusedTextboxChar()
            UI.nextTextRepeat = tick() + 0.045
        end

        if UI.active and UI.active.type == "windowdrag" then
            local window = UI.active.window
            local viewport = getViewportSize()
            window.x = clamp(UI.mousePos.X - UI.active.offX, 0, math.max(0, viewport.X - window.w))
            window.y = clamp(UI.mousePos.Y - UI.active.offY, 0, math.max(0, viewport.Y - window.h))
        elseif UI.active and UI.active.element and UI.active.element.onDrag then
            UI.active.element:onDrag(UI.mousePos)
        end

        for _, window in ipairs(UI.windows) do
            layoutWindow(window)
        end

        local topWindow = getTopWindowAtMouse()
        UI.hovered = hitTestElement(topWindow)

        for _, window in ipairs(UI.windows) do
            renderWindow(window)
        end

        for _, notification in ipairs(UI.notifications) do
            local age = tick() - notification.born
            notification.alpha = clamp(1 - math.max(0, age - notification.duration + 0.25) / 0.25, 0, 1)
        end
        for i = #UI.notifications, 1, -1 do
            if UI.notifications[i].alpha <= 0 then
                table.remove(UI.notifications, i)
            end
        end

        drawTooltip(UI.tooltip)
    end)
end

local function makeSectionApi(section)
    local api = {}

    function api:Subtext_Create(text)
        local element = createBaseElement(section, "subtext", 16)
        element.text = tostring(text or "")
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Outline = false, Center = false, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = element.text }))
        function element:hitTest() return false end
        function element:draw()
            self.label.Position = Vector2.new(self.x + 2, self.y + 2)
            self.label.Text = self.text
            self.label.Visible = true
        end
        return element
    end

    function api:Toggle_Create(name, flag, default, tooltipText, callback)
        if type(flag) ~= "string" then
            callback = tooltipText
            tooltipText = default
            default = flag
            flag = makeAutoFlag(section, name)
        end
        local value = ensureFlag(flag, default or false)
        local element = createBaseElement(section, "toggle", tooltipText and tooltipText ~= "" and 30 or 18)
        element.name = tostring(name or "Toggle")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.pressable = true
        element.box = addToGroup(element.drawings, createSoftFrame(60))
        element.knob = addToGroup(element.drawings, createRoundedPrimitive(63, colors.textWhiteColor, 1))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Outline = false, Center = false, Transparency = 1, Color = value and colors.textWhiteColor or colors.textDarkColor, ZIndex = 64, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Outline = false, Center = false, Transparency = 1, Color = colors.textDarkColor, ZIndex = 64, Visible = false, Text = tostring(tooltipText or "") }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x, self.y, self.w, math.max(self.height or 0, 48))
        end
        function element:onMouseDown()
            local state = not LibraryApi.Flags[self.flag]
            LibraryApi.Flags[self.flag] = state
            saveConfiguration()
            if self.callback then task.spawn(self.callback, state) end
        end
        function element:draw()
            local state = LibraryApi.Flags[self.flag]
            local hovered = UI.hovered == self
            setSoftFrame(self.box, self.x + 2, self.y + 1, 30, 16, 4, state and colors.accentColor or colors.elementBackground, 0.98, state and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor), 0.95, 1)
            setRoundedPrimitive(self.knob, self.x + (state and 17 or 4), self.y + 4, 8, 8, 3, colors.textWhiteColor, 1, true)
            local titleY = self.tooltip and self.tooltip ~= "" and (self.y + 1) or (self.y + 3)
            self.label.Position = Vector2.new(self.x + 40, titleY)
            self.label.Text = self.name
            self.label.Color = state and colors.textWhiteColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.label.Visible = true
            self.desc.Position = Vector2.new(self.x + 40, self.y + 15)
            self.desc.Text = tostring(self.tooltip or "")
            self.desc.Visible = self.tooltip ~= nil and self.tooltip ~= ""
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Slider_Create(name, flag, min, max, default, step, tooltipText, callback)
        if type(flag) ~= "string" then
            local args = { flag, min, max, default, step, tooltipText, callback }
            flag = makeAutoFlag(section, name)
            min = tonumber(args[1]) or 0
            max = tonumber(args[2]) or 100
            default = args[3]
            if type(args[4]) == "number" or type(args[4]) == "string" then
                step = args[4]
                tooltipText = args[5]
                callback = args[6]
            else
                step = nil
                tooltipText = args[4]
                callback = args[5]
            end
        end
        step = normalizeStep(step)
        local value = ensureFlag(flag, snapValue(default or min, step))
        local element = createBaseElement(section, "slider", tooltipText and tooltipText ~= "" and 40 or 28)
        element.name = tostring(name or "Slider")
        element.flag = flag
        element.min = tonumber(min) or 0
        element.max = tonumber(max) or 100
        if element.max < element.min then element.min, element.max = element.max, element.min end
        element.step = step
        element.tooltip = tooltipText
        element.callback = callback
        LibraryApi.Flags[flag] = clamp(tonumber(value) or element.min, element.min, element.max)
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = tostring(tooltipText or "") }))
        element.valueText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = formatValue(LibraryApi.Flags[flag], step) }))
        element.track = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.trackBorder = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.fill = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = colors.accentColor, ZIndex = 62, Visible = false }))
        element.knob = addToGroup(element.drawings, newDrawing("Circle", { Filled = true, Thickness = 1, Transparency = 1, Radius = 4, Color = colors.textWhiteColor, ZIndex = 63, Visible = false }))
        element.knobBorder = addToGroup(element.drawings, newDrawing("Circle", { Filled = false, Thickness = 1, Transparency = 1, Radius = 4, Color = colors.borderColor, ZIndex = 64, Visible = false }))
        function element:setFromMouse(pos)
            local sx = self.x + 2
            local width = math.max(1, self.w - 8)
            local alpha = clamp((pos.X - sx) / width, 0, 1)
            local newValue = snapValue(self.min + (self.max - self.min) * alpha, self.step)
            newValue = clamp(tonumber(newValue) or self.min, self.min, self.max)
            if LibraryApi.Flags[self.flag] ~= newValue then
                LibraryApi.Flags[self.flag] = newValue
                saveConfiguration()
                if self.callback then task.spawn(self.callback, newValue) end
            end
        end
        function element:hitTest(pos)
            return pointInRect(pos, self.x, self.y, self.w, self.height)
        end
        function element:onMouseDown(pos)
            UI.active = { type = "slider", element = self, window = self.window }
            self:setFromMouse(pos)
        end
        function element:onDrag(pos)
            self:setFromMouse(pos)
        end
        function element:onMouseUp(pos)
            self:setFromMouse(pos)
        end
        function element:draw()
            local valueNow = clamp(tonumber(LibraryApi.Flags[self.flag]) or self.min, self.min, self.max)
            local trackW = math.max(1, self.w - 8)
            local pct = (valueNow - self.min) / math.max(1e-9, (self.max - self.min))
            local fillW = math.max(1, trackW * pct)
            local hovered = UI.hovered == self or (UI.active and UI.active.element == self)
            local labelY = self.y + 1
            local trackY = self.tooltip and self.tooltip ~= "" and (self.y + 31) or (self.y + 19)
            self.label.Position = Vector2.new(self.x + 2, labelY)
            self.label.Text = self.name
            self.desc.Position = Vector2.new(self.x + 2, self.y + 15)
            self.desc.Text = tostring(self.tooltip or "")
            self.desc.Visible = self.tooltip ~= nil and self.tooltip ~= ""
            self.valueText.Text = formatValue(valueNow, self.step or 1)
            self.valueText.Position = Vector2.new(self.x + self.w - getTextSize(self.valueText.Text, 12) - 2, labelY)
            self.track.Position = Vector2.new(self.x + 2, trackY)
            self.track.Size = Vector2.new(trackW, 5)
            self.trackBorder.Position = self.track.Position
            self.trackBorder.Size = self.track.Size
            self.trackBorder.Color = hovered and colors.borderLightColor or colors.borderColor
            self.fill.Position = self.track.Position
            self.fill.Size = Vector2.new(fillW, 5)
            self.knob.Position = Vector2.new(self.x + 2 + trackW * pct, self.track.Position.Y + 1.5)
            self.knobBorder.Position = self.knob.Position
            self.knobBorder.Color = hovered and colors.accentColor or colors.borderColor
            self.label.Visible = true
            self.valueText.Visible = true
            self.track.Visible = true
            self.trackBorder.Visible = true
            self.fill.Visible = true
            self.knob.Visible = true
            self.knobBorder.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:RangeSlider_Create(name, flag, min, max, defaultMin, defaultMax, step, tooltipText, callback)
        if type(flag) ~= "string" then
            local args = { flag, min, max, defaultMin, defaultMax, step, tooltipText, callback }
            flag = makeAutoFlag(section, name)
            min = tonumber(args[1]) or 0
            max = tonumber(args[2]) or 100
            defaultMin = args[3]
            defaultMax = args[4]
            if type(args[5]) == "number" or type(args[5]) == "string" then
                step = args[5]
                tooltipText = args[6]
                callback = args[7]
            else
                step = nil
                tooltipText = args[5]
                callback = args[6]
            end
        end
        step = normalizeStep(step)
        local value = ensureFlag(flag, { Min = snapValue(defaultMin or min, step), Max = snapValue(defaultMax or max, step) })
        value.Min = clamp(value.Min, min, max)
        value.Max = clamp(value.Max, min, max)
        if value.Min > value.Max then value.Min, value.Max = value.Max, value.Min end
        local element = createBaseElement(section, "rangeslider", tooltipText and tooltipText ~= "" and 40 or 28)
        element.name = tostring(name or "Range")
        element.flag = flag
        element.min = min
        element.max = max
        element.step = step
        element.tooltip = tooltipText
        element.callback = callback
        element.dragging = nil
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = tostring(tooltipText or "") }))
        element.valueText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = "" }))
        element.track = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.trackBorder = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.fill = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = colors.accentColor, ZIndex = 62, Visible = false }))
        element.knobMin = addToGroup(element.drawings, newDrawing("Circle", { Filled = true, Thickness = 1, Transparency = 1, Radius = 4, Color = colors.textWhiteColor, ZIndex = 63, Visible = false }))
        element.knobMax = addToGroup(element.drawings, newDrawing("Circle", { Filled = true, Thickness = 1, Transparency = 1, Radius = 4, Color = colors.textWhiteColor, ZIndex = 63, Visible = false }))
        function element:valueToPct(v)
            return (v - self.min) / math.max(1e-9, (self.max - self.min))
        end
        function element:setFromMouse(pos)
            local trackX = self.x + 2
            local trackW = self.w - 8
            local alpha = clamp((pos.X - trackX) / trackW, 0, 1)
            local newValue = snapValue(self.min + (self.max - self.min) * alpha, self.step)
            newValue = clamp(newValue, self.min, self.max)
            local range = LibraryApi.Flags[self.flag]
            if self.dragging == "min" then
                range.Min = math.min(newValue, range.Max)
            else
                range.Max = math.max(newValue, range.Min)
            end
            saveConfiguration()
            if self.callback then task.spawn(self.callback, { Min = range.Min, Max = range.Max }) end
        end
        function element:hitTest(pos)
            return pointInRect(pos, self.x, self.y, self.w, self.height)
        end
        function element:onMouseDown(pos)
            local range = LibraryApi.Flags[self.flag]
            local trackX = self.x + 2
            local trackW = self.w - 8
            local minX = trackX + trackW * self:valueToPct(range.Min)
            local maxX = trackX + trackW * self:valueToPct(range.Max)
            self.dragging = math.abs(pos.X - minX) < math.abs(pos.X - maxX) and "min" or "max"
            UI.active = { type = "rangeslider", element = self, window = self.window }
            self:setFromMouse(pos)
        end
        function element:onDrag(pos)
            self:setFromMouse(pos)
        end
        function element:onMouseUp(pos)
            self:setFromMouse(pos)
            self.dragging = nil
        end
        function element:draw()
            local range = LibraryApi.Flags[self.flag]
            local trackW = self.w - 8
            local minPct = self:valueToPct(range.Min)
            local maxPct = self:valueToPct(range.Max)
            local startX = self.x + 2 + trackW * minPct
            local endX = self.x + 2 + trackW * maxPct
            local hovered = UI.hovered == self or (UI.active and UI.active.element == self)
            self.label.Position = Vector2.new(self.x + 2, self.y + 1)
            self.label.Text = self.name
            self.valueText.Text = formatValue(range.Min, self.step or 1) .. " - " .. formatValue(range.Max, self.step or 1)
            self.valueText.Position = Vector2.new(self.x + self.w - getTextSize(self.valueText.Text, 12) - 2, self.y + 1)
            self.track.Position = Vector2.new(self.x + 2, self.y + 19)
            self.track.Size = Vector2.new(trackW, 5)
            self.trackBorder.Position = self.track.Position
            self.trackBorder.Size = self.track.Size
            self.trackBorder.Color = hovered and colors.borderLightColor or colors.borderColor
            self.fill.Position = Vector2.new(startX, self.y + 18)
            self.fill.Size = Vector2.new(math.max(1, endX - startX), 6)
            self.knobMin.Position = Vector2.new(startX, self.y + 21)
            self.knobMax.Position = Vector2.new(endX, self.y + 21)
            self.label.Visible = true
            self.valueText.Visible = true
            self.track.Visible = true
            self.trackBorder.Visible = true
            self.fill.Visible = true
            self.knobMin.Visible = true
            self.knobMax.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Textbox_Create(name, flag, default, tooltipText, callback)
        if type(flag) ~= "string" then
            callback = tooltipText
            tooltipText = default
            default = flag
            flag = makeAutoFlag(section, name)
        end
        local value = ensureFlag(flag, tostring(default or ""))
        local element = createBaseElement(section, "textbox", 48)
        element.name = tostring(name or "Textbox")
        element.flag = flag
        element.value = tostring(value)
        element.tooltip = tooltipText
        element.callback = callback
        element.focused = false
        element.cursorBlink = 0
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = tostring(tooltipText or "") }))
        element.box = addToGroup(element.drawings, createSoftFrame(60))
        element.text = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = element.value }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x, self.y, self.w, self.height)
        end
        function element:onMouseDown(pos)
            if pointInRect(pos, self.x + 2, self.y + 14, self.w - 4, 14) then
                focusTextbox(self)
            else
                focusTextbox(nil)
            end
        end
        function element:draw()
            self.focused = UI.focusedTextbox == self
            self.value = tostring(LibraryApi.Flags[self.flag] or "")
            local hovered = UI.hovered == self
            local showText = self.value
            if self.focused and math.floor(UI.blinkClock * 2) % 2 == 0 then
                showText = showText .. "|"
            end
            self.label.Position = Vector2.new(self.x + 2, self.y + 1)
            setSoftFrame(self.box, self.x + 2, self.y + 20, self.w - 4, 24, 4, self.focused and colors.elementHoverBackground or colors.elementBackground, 0.82, self.focused and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor), 0.92, 1)
            self.text.Position = Vector2.new(self.x + 10, self.y + 27)
            self.text.Text = showText
            self.text.Color = (#self.value > 0 or self.focused) and colors.textWhiteColor or colors.textDarkColor
            self.label.Text = self.name
            self.label.Visible = true
            self.box.Visible = true
            self.text.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Keybind_Create(name, flag, default, tooltipText, callback)
        if type(flag) ~= "string" then
            callback = tooltipText
            tooltipText = default
            default = flag
            flag = makeAutoFlag(section, name)
        end
        local value = ensureFlag(flag, default or Enum.KeyCode.Unknown)
        local element = createBaseElement(section, "keybind", tooltipText and tooltipText ~= "" and 30 or 18)
        element.name = tostring(name or "Keybind")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.waiting = false
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = tostring(tooltipText or "") }))
        element.box = addToGroup(element.drawings, createSoftFrame(60))
        element.bindText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textDarkColor, ZIndex = 63, Visible = false, Text = "", Center = true }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x, self.y, self.w, self.height)
        end
        function element:onMouseDown()
            self.waiting = true
            beginKeybind(self)
        end
        function element:getText()
            if self.waiting then return "[ ... ]" end
            local key = LibraryApi.Flags[self.flag]
            local name = getKeyCodeName(key)
            if name == "Unknown" or name == "None" then return "[ None ]" end
            return "[ " .. name .. " ]"
        end
        function element:draw()
            local hovered = UI.hovered == self
            local boxText = self:getText()
            local bindW = math.max(72, getTextSize(boxText, 12) + 18)
            local labelH = select(2, getTextSize(self.name, 12))
            self.label.Position = Vector2.new(self.x + 2, round(self.y + (16 - labelH) * 0.5))
            local boxX = self.x + self.w - bindW
            local boxY = self.y - 1
            setSoftFrame(self.box, boxX, boxY, bindW, 20, 4, self.waiting and colors.elementHoverBackground or colors.elementBackground, 0.82, self.waiting and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor), 0.92, 1)
            self.bindText.Text = boxText
            self.bindText.Position = getCenteredTextPosition(boxX, boxY, bindW, 20, boxText, 12)
            self.label.Text = self.name
            self.label.Color = hovered and colors.textWhiteColor or colors.textWhiteColor
            self.bindText.Color = self.waiting and colors.accentColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.label.Visible = true
            self.bindText.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Dropdown_Create(name, flag, options, default, tooltipText, callback)
        if type(flag) ~= "string" then
            callback = tooltipText
            tooltipText = default
            default = options
            options = flag
            flag = makeAutoFlag(section, name)
        end
        local opts = options or {}
        local fallback = default or opts[1] or ""
        local value = ensureFlag(flag, fallback)
        local element = createBaseElement(section, "dropdown", 48)
        element.name = tostring(name or "Dropdown")
        element.flag = flag
        element.options = opts
        element.tooltip = tooltipText
        element.callback = callback
        element.open = false
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = tostring(tooltipText or "") }))
        element.box = addToGroup(element.drawings, createSoftFrame(60))
        element.valueText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = tostring(value) }))
        element.arrow = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = "v" }))
        element.popup = createGroup()
        element.popup.frame = addToGroup(element.popup, createSoftFrame(120))
        element.popupItems = {}
        for i = 1, math.max(1, #opts) do
            element.popupItems[i] = {
                bg = addToGroup(element.popup, createRoundedPrimitive(122, colors.sectionBackground, 0.92)),
                text = addToGroup(element.popup, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textDarkColor, ZIndex = 123, Visible = false, Text = tostring(opts[i] or "") }))
            }
        end
        function element:hitTest(pos)
            if pointInRect(pos, self.x, self.y, self.w, self.height) then
                return true
            end
            if self.open and pointInRect(pos, self.popupX, self.popupY, self.popupW, self.popupH) then
                return true
            end
            return false
        end
        function element:onMouseDown(pos)
            local buttonRectY = self.y + 20
            if pointInRect(pos, self.x + 2, buttonRectY, self.w - 4, 24) then
                self.open = not self.open
                closeOpenDropdown(self.open and self or nil)
            elseif self.open and pointInRect(pos, self.popupX, self.popupY, self.popupW, self.popupH) then
                local itemH = 24
                local index = clamp(math.floor((pos.Y - self.popupY) / itemH) + 1, 1, #self.options)
                local chosen = self.options[index]
                LibraryApi.Flags[self.flag] = chosen
                self.open = false
                UI.openDropdown = nil
                saveConfiguration()
                if self.callback then task.spawn(self.callback, chosen) end
            else
                self.open = false
                if UI.openDropdown == self then UI.openDropdown = nil end
            end
        end
        function element:dynamicHeight()
            if self.open then
                local popupH = math.max(24, #self.options * 24)
                return 46 + popupH + 4
            end
            return 48
        end
        function element:draw()
            local hovered = UI.hovered == self
            self.label.Position = Vector2.new(self.x + 2, self.y + 1)
            setSoftFrame(self.box, self.x + 2, self.y + 20, self.w - 4, 24, 4, self.open and colors.elementHoverBackground or colors.elementBackground, 0.82, self.open and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor), 0.92, 1)
            self.valueText.Text = tostring(LibraryApi.Flags[self.flag])
            self.valueText.Position = Vector2.new(self.x + 10, self.y + 27)
            self.valueText.Color = hovered and colors.textWhiteColor or colors.textDarkColor
            self.arrow.Text = self.open and "^" or "v"
            self.arrow.Position = Vector2.new(self.x + self.w - 16, self.y + 25)
            self.arrow.Color = self.open and colors.accentColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.label.Visible = true
            self.box.Visible = true
            self.valueText.Visible = true
            self.arrow.Visible = true
            if hovered then setTooltipText(self.tooltip) end
            self.popupX = self.x + 2
            self.popupY = self.y + 48
            self.popupW = self.w - 4
            self.popupH = math.max(24, #self.options * 24)
            if self.open then
                setSoftFrame(self.popup.frame, self.popupX, self.popupY, self.popupW, self.popupH, 5, colors.sectionBackground, 0.97, colors.borderColor, 0.95, 1)
                for index, option in ipairs(self.options) do
                    local item = self.popupItems[index]
                    local y = self.popupY + (index - 1) * 24
                    local hovering = pointInRect(UI.mousePos, self.popupX, y, self.popupW, 24)
                    setRoundedPrimitive(item.bg, self.popupX + 2, y + 2, self.popupW - 4, 20, 4, hovering and colors.elementHoverBackground or colors.sectionBackground, 0.96, true)
                    item.text.Text = tostring(option)
                    item.text.Position = Vector2.new(self.popupX + 8, y + 6)
                    item.text.Color = tostring(option) == tostring(LibraryApi.Flags[self.flag]) and colors.textWhiteColor or (hovering and colors.textWhiteColor or colors.textDarkColor)
                    item.text.Visible = true
                end
            else
                hideGroup(self.popup)
            end
        end
        return element
    end

    function api:ColorPicker_Create(name, flag, default, tooltipText, callback)
        if type(flag) ~= "string" then
            callback = tooltipText
            tooltipText = default
            default = flag
            flag = makeAutoFlag(section, name)
        end
        local value = ensureFlag(flag, default or colors.accentColor)
        local h, sVal, vVal = colorToHSV(value)
        local element = createBaseElement(section, "colorpicker", 28)
        element.name = tostring(name or "Color")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.h = h
        element.s = sVal
        element.v = vVal
        element.open = false
        element.dragMode = nil
        element.animOpen = 0
        element.gridCols = 40
        element.gridRows = 28
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.previewFrame = addToGroup(element.drawings, createSoftFrame(60))
        element.preview = addToGroup(element.drawings, createRoundedPrimitive(62, value, 1))
        element.popup = createGroup()
        element.popup.frame = addToGroup(element.popup, createSoftFrame(130))
        element.popup.grid = {}
        for gy = 1, element.gridRows do
            element.popup.grid[gy] = {}
            for gx = 1, element.gridCols do
                element.popup.grid[gy][gx] = addToGroup(element.popup, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = value, ZIndex = 132, Visible = false }))
            end
        end
        element.popup.gridBorder = addToGroup(element.popup, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderLightColor, ZIndex = 133, Visible = false }))
        element.popup.cursorOuter = addToGroup(element.popup, newDrawing("Circle", { Filled = false, Thickness = 1, Transparency = 1, Radius = 5, Color = colors.textWhiteColor, ZIndex = 135, Visible = false }))
        element.popup.cursorInner = addToGroup(element.popup, newDrawing("Circle", { Filled = false, Thickness = 1, Transparency = 1, Radius = 3, Color = colors.mainBackground, ZIndex = 136, Visible = false }))
        element.popup.hueCells = {}
        for i = 1, 80 do
            element.popup.hueCells[i] = addToGroup(element.popup, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = value, ZIndex = 132, Visible = false }))
        end
        element.popup.hueBorder = addToGroup(element.popup, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderLightColor, ZIndex = 133, Visible = false }))
        element.popup.hueLine = addToGroup(element.popup, newDrawing("Line", { Thickness = 2, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 135, Visible = false }))
        element.popup.currentFrame = addToGroup(element.popup, createSoftFrame(134))
        element.popup.currentFill = addToGroup(element.popup, createRoundedPrimitive(137, value, 1))
        element.popup.copyButton = addToGroup(element.popup, createSoftFrame(134))
        element.popup.copyLabel = addToGroup(element.popup, newDrawing("Text", { Size = 11, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 138, Visible = false, Text = "COPY", Center = true }))
        element.popup.pasteButton = addToGroup(element.popup, createSoftFrame(134))
        element.popup.pasteLabel = addToGroup(element.popup, newDrawing("Text", { Size = 11, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 138, Visible = false, Text = "PASTE", Center = true }))
        element.popup.rgbLabel = addToGroup(element.popup, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 136, Visible = false, Text = "RGB" }))
        element.popup.rgbValue = addToGroup(element.popup, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 136, Visible = false, Text = "" }))
        element.popup.hexLabel = addToGroup(element.popup, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 136, Visible = false, Text = "HEX" }))
        element.popup.hexValue = addToGroup(element.popup, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 136, Visible = false, Text = "" }))
        function element:updateColor(fireCallback)
            local color = hsvToColor(self.h, self.s, self.v)
            LibraryApi.Flags[self.flag] = color
            if fireCallback ~= false then
                saveConfiguration()
                if self.callback then task.spawn(self.callback, color) end
            end
        end
        function element:applyColor(color, fireCallback)
            if not color then
                return false
            end
            self.h, self.s, self.v = colorToHSV(color)
            self:updateColor(fireCallback)
            return true
        end
        function element:copyColor()
            local ok = setClipboardText(colorToHex(LibraryApi.Flags[self.flag]))
            if ok then
                LibraryApi:Notify("Copied color", "success", 1.2)
            else
                LibraryApi:Notify("Clipboard unavailable", "warning", 1.2)
            end
        end
        function element:pasteColor()
            local raw = getClipboardText()
            local color = parseClipboardColor(raw)
            if color then
                self:applyColor(color, true)
                LibraryApi:Notify("Pasted color", "success", 1.2)
            else
                LibraryApi:Notify("Clipboard has no valid color", "warning", 1.3)
            end
        end
        function element:hitTest(pos)
            if pointInRect(pos, self.x, self.y, self.w, self.height) then return true end
            if (self.open or (self.animOpen or 0) > 0.01) and pointInRect(pos, self.popupX, self.popupY, self.popupW, self.popupH) then return true end
            return false
        end
        function element:applySVFromMouse(pos)
            self.s = clamp((pos.X - self.svX) / self.svW, 0, 1)
            self.v = 1 - clamp((pos.Y - self.svY) / self.svH, 0, 1)
            self:updateColor(true)
        end
        function element:applyHueFromMouse(pos)
            self.h = clamp((pos.X - self.hueX) / self.hueW, 0, 1)
            self:updateColor(true)
        end
        function element:onMouseDown(pos)
            local previewX = self.x + self.w - 24
            if pointInRect(pos, previewX, self.y + 5, 20, 14) then
                self.open = not self.open
                closeOpenColorPicker(self.open and self or nil)
                return
            end
            if self.open then
                if pointInRect(pos, self.svX, self.svY, self.svW, self.svH) then
                    self.dragMode = "sv"
                    UI.active = { type = "colorpicker", element = self, window = self.window }
                    self:applySVFromMouse(pos)
                elseif pointInRect(pos, self.hueX, self.hueY, self.hueW, self.hueH) then
                    self.dragMode = "hue"
                    UI.active = { type = "colorpicker", element = self, window = self.window }
                    self:applyHueFromMouse(pos)
                elseif pointInRect(pos, self.copyX, self.copyY, self.copyW, self.actionH) then
                    self:copyColor()
                elseif pointInRect(pos, self.pasteX, self.pasteY, self.pasteW, self.actionH) then
                    self:pasteColor()
                else
                    self.open = false
                    if UI.openColorPicker == self then UI.openColorPicker = nil end
                end
            end
        end
        function element:onMouse2Down(pos)
            local previewX = self.x + self.w - 24
            if pointInRect(pos, previewX, self.y + 5, 20, 14) then
                self:copyColor()
                return
            end
            if self.open and pointInRect(pos, self.popupX, self.popupY, self.popupW, self.popupH) then
                self:pasteColor()
            end
        end
        function element:onDrag(pos)
            if self.dragMode == "sv" then
                self:applySVFromMouse(pos)
            elseif self.dragMode == "hue" then
                self:applyHueFromMouse(pos)
            end
        end
        function element:onMouseUp()
            self.dragMode = nil
        end
        function element:dynamicHeight()
            if self.open then
                return 40 + 216 + 10
            end
            return 28
        end
        function element:draw()
            local hovered = UI.hovered == self
            if not self.window.visible then
                self.animOpen = 0
                hideGroup(self.popup)
                return
            end
            local color = LibraryApi.Flags[self.flag]
            self.animOpen = lerp(self.animOpen or 0, self.open and 1 or 0, 0.24)
            if self.animOpen < 0.001 and not self.open then
                self.animOpen = 0
            end
            self.label.Position = Vector2.new(self.x + 2, self.y + 3)
            setSoftFrame(self.previewFrame, self.x + self.w - 28, self.y + 5, 24, 14, 3, colors.elementBackground, 0.82, self.open and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor), 0.92, 1)
            setRoundedPrimitive(self.preview, self.x + self.w - 24, self.y + 8, 16, 8, 2, color, 1, true)
            self.label.Visible = true
            if hovered then setTooltipText(self.tooltip) end
            self.popupW = 236
            self.popupH = 216
            self.popupX = self.x + self.w - self.popupW
            self.popupY = self.y + 28 + (1 - self.animOpen) * -6
            self.svX = self.popupX + 10
            self.svY = self.popupY + 10
            self.svW = self.popupW - 20
            self.svH = 122
            self.hueX = self.popupX + 10
            self.hueY = self.svY + self.svH + 8
            self.hueW = self.popupW - 20
            self.hueH = 12
            self.actionY = self.hueY + self.hueH + 8
            self.copyX = self.popupX + 10
            self.copyY = self.actionY
            self.copyW = 54
            self.pasteX = self.copyX + self.copyW + 8
            self.pasteY = self.actionY
            self.pasteW = 54
            self.actionH = 20
            self.swatchX = self.popupX + self.popupW - 42
            self.swatchY = self.actionY
            self.swatchW = 32
            self.swatchH = 20
            self.infoY = self.actionY + self.actionH + 8
            if self.animOpen > 0.01 then
                local alpha = self.animOpen
                setSoftFrame(self.popup.frame, self.popupX, self.popupY, self.popupW, self.popupH, 4, colors.sectionBackground, 0.985 * alpha, colors.borderColor, 0.95 * alpha, 2)
                local cellW = self.svW / self.gridCols
                local cellH = self.svH / self.gridRows
                for gy = 1, self.gridRows do
                    for gx = 1, self.gridCols do
                        local sSample = (gx - 1) / (self.gridCols - 1)
                        local vSample = 1 - ((gy - 1) / (self.gridRows - 1))
                        local cell = self.popup.grid[gy][gx]
                        cell.Position = Vector2.new(self.svX + (gx - 1) * cellW, self.svY + (gy - 1) * cellH)
                        cell.Size = Vector2.new(math.ceil(cellW + 0.35), math.ceil(cellH + 0.35))
                        cell.Color = hsvToColor(self.h, sSample, vSample)
                        cell.Transparency = alpha
                        cell.Visible = true
                    end
                end
                self.popup.gridBorder.Position = Vector2.new(self.svX, self.svY)
                self.popup.gridBorder.Size = Vector2.new(self.svW, self.svH)
                self.popup.gridBorder.Transparency = alpha
                self.popup.gridBorder.Visible = true
                local cursorX = self.svX + self.s * self.svW
                local cursorY = self.svY + (1 - self.v) * self.svH
                self.popup.cursorOuter.Position = Vector2.new(cursorX, cursorY)
                self.popup.cursorInner.Position = Vector2.new(cursorX, cursorY)
                self.popup.cursorOuter.Transparency = alpha
                self.popup.cursorInner.Transparency = alpha
                self.popup.cursorOuter.Visible = true
                self.popup.cursorInner.Visible = true
                local hueCellW = self.hueW / #self.popup.hueCells
                for i, cell in ipairs(self.popup.hueCells) do
                    local hSample = (i - 1) / (#self.popup.hueCells - 1)
                    cell.Position = Vector2.new(self.hueX + (i - 1) * hueCellW, self.hueY)
                    cell.Size = Vector2.new(math.ceil(hueCellW + 0.35), self.hueH)
                    cell.Color = hsvToColor(hSample, 1, 1)
                    cell.Transparency = alpha
                    cell.Visible = true
                end
                self.popup.hueBorder.Position = Vector2.new(self.hueX, self.hueY)
                self.popup.hueBorder.Size = Vector2.new(self.hueW, self.hueH)
                self.popup.hueBorder.Transparency = alpha
                self.popup.hueBorder.Visible = true
                local hx = self.hueX + self.h * self.hueW
                self.popup.hueLine.From = Vector2.new(hx, self.hueY - 2)
                self.popup.hueLine.To = Vector2.new(hx, self.hueY + self.hueH + 2)
                self.popup.hueLine.Transparency = alpha
                self.popup.hueLine.Visible = true
                setSoftFrame(self.popup.currentFrame, self.swatchX, self.swatchY, self.swatchW, self.swatchH, 3, colors.elementBackground, 0.96 * alpha, colors.borderLightColor, 0.95 * alpha, 1)
                setRoundedPrimitive(self.popup.currentFill, self.swatchX + 2, self.swatchY + 2, self.swatchW - 4, self.swatchH - 4, 2, color, alpha, true)
                local copyHovered = pointInRect(UI.mousePos, self.copyX, self.copyY, self.copyW, self.actionH)
                local pasteHovered = pointInRect(UI.mousePos, self.pasteX, self.pasteY, self.pasteW, self.actionH)
                setSoftFrame(self.popup.copyButton, self.copyX, self.copyY, self.copyW, self.actionH, 3, copyHovered and colors.elementHoverBackground or colors.elementBackground, 0.97 * alpha, copyHovered and colors.borderLightColor or colors.borderColor, 0.95 * alpha, 1)
                setSoftFrame(self.popup.pasteButton, self.pasteX, self.pasteY, self.pasteW, self.actionH, 3, pasteHovered and colors.elementHoverBackground or colors.elementBackground, 0.97 * alpha, pasteHovered and colors.accentColor or colors.borderColor, 0.95 * alpha, 1)
                self.popup.copyLabel.Position = Vector2.new(self.copyX + self.copyW * 0.5, self.copyY + 5)
                self.popup.copyLabel.Color = copyHovered and colors.textWhiteColor or colors.textDarkColor
                self.popup.copyLabel.Transparency = alpha
                self.popup.copyLabel.Visible = true
                self.popup.pasteLabel.Position = Vector2.new(self.pasteX + self.pasteW * 0.5, self.pasteY + 5)
                self.popup.pasteLabel.Color = pasteHovered and colors.textWhiteColor or colors.textDarkColor
                self.popup.pasteLabel.Transparency = alpha
                self.popup.pasteLabel.Visible = true
                local rgbText = string.format("%d, %d, %d", math.floor(color.R * 255 + 0.5), math.floor(color.G * 255 + 0.5), math.floor(color.B * 255 + 0.5))
                local hexText = colorToHex(color)
                self.popup.rgbLabel.Text = "RGB"
                self.popup.rgbLabel.Position = Vector2.new(self.popupX + 10, self.infoY)
                self.popup.rgbLabel.Size = 10
                self.popup.rgbLabel.Transparency = alpha
                self.popup.rgbLabel.Visible = true
                self.popup.rgbValue.Text = rgbText
                self.popup.rgbValue.Position = Vector2.new(self.popupX + 10, self.infoY + 12)
                self.popup.rgbValue.Size = 11
                self.popup.rgbValue.Transparency = alpha
                self.popup.rgbValue.Visible = true
                self.popup.hexLabel.Text = "HEX"
                self.popup.hexLabel.Position = Vector2.new(self.popupX + 118, self.infoY)
                self.popup.hexLabel.Size = 10
                self.popup.hexLabel.Transparency = alpha
                self.popup.hexLabel.Visible = true
                self.popup.hexValue.Text = hexText
                self.popup.hexValue.Position = Vector2.new(self.popupX + 118, self.infoY + 12)
                self.popup.hexValue.Size = 11
                self.popup.hexValue.Color = colors.textWhiteColor
                self.popup.hexValue.Transparency = alpha
                self.popup.hexValue.Visible = true
            else
                hideGroup(self.popup)
            end
        end
        return element
    end

    api.Input_Create = api.Textbox_Create

    function api:Button_Create(name, tooltipText, callback)
        local element = createBaseElement(section, "button", tooltipText and tooltipText ~= "" and 40 or 28)
        element.name = tostring(name or "Button")
        element.tooltip = tooltipText
        element.callback = callback
        element.box = addToGroup(element.drawings, createSoftFrame(60))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 62, Visible = false, Text = element.name, Center = true }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = tostring(tooltipText or ""), Center = true }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x + 2, self.y, self.w - 4, self.height)
        end
        function element:onMouseDown()
            if self.callback then task.spawn(self.callback) end
        end
        function element:draw()
            local hovered = UI.hovered == self
            setSoftFrame(self.box, self.x + 2, self.y, self.w - 4, self.height, 4, hovered and colors.elementHoverBackground or colors.elementBackground, 0.78153, hovered and colors.accentColor or colors.borderColor, 0.95, 1)
            self.label.Text = self.name
            self.label.Position = Vector2.new(self.x + self.w / 2, self.tooltip and self.tooltip ~= "" and (self.y + 4) or (self.y + 8))
            self.label.Color = hovered and colors.accentColor or colors.textWhiteColor
            self.desc.Position = Vector2.new(self.x + self.w / 2, self.y + 18)
            self.desc.Text = tostring(self.tooltip or "")
            self.desc.Visible = self.tooltip ~= nil and self.tooltip ~= ""
            self.box.Visible = true
            self.label.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:SubButton_Create(name, tooltipText, callback)
        local element = createBaseElement(section, "subbutton", tooltipText and tooltipText ~= "" and 32 or 20)
        element.name = tostring(name or "SubButton")
        element.tooltip = tooltipText
        element.callback = callback
        element.box = addToGroup(element.drawings, createSoftFrame(60))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_MAIN, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = element.name, Center = true }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 10, Font = FONT_SUB, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = tostring(tooltipText or ""), Center = true }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x + 8, self.y, self.w - 16, self.height)
        end
        function element:onMouseDown()
            if self.callback then task.spawn(self.callback) end
        end
        function element:draw()
            local hovered = UI.hovered == self
            setSoftFrame(self.box, self.x + 8, self.y, self.w - 16, self.height, 3, hovered and colors.elementBackground or colors.sectionBackground, 0.95, hovered and colors.borderLightColor or colors.borderColor, 0.9, 1)
            self.label.Text = self.name
            self.label.Position = Vector2.new(self.x + self.w / 2, self.tooltip and self.tooltip ~= "" and (self.y + 2) or (self.y + 4))
            self.label.Color = hovered and colors.textWhiteColor or colors.textDarkColor
            self.desc.Position = Vector2.new(self.x + self.w / 2, self.y + 14)
            self.desc.Text = tostring(self.tooltip or "")
            self.desc.Visible = self.tooltip ~= nil and self.tooltip ~= ""
            self.box.Visible = true
            self.label.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Module_Create(name, flag, descriptionText, default, tooltipText, callback)
        local state = ensureFlag(flag, default or false)
        local element = createBaseElement(section, "module", 46)
        element.name = tostring(name or "Module")
        element.descriptionText = tostring(descriptionText or "")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.bg = addToGroup(element.drawings, createSoftFrame(60))
        element.check = addToGroup(element.drawings, createSoftFrame(64))
        element.dot = addToGroup(element.drawings, createRoundedPrimitive(67, colors.textWhiteColor, 1))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = FONT_MAIN, Transparency = 1, Color = state and colors.textWhiteColor or colors.textDarkColor, ZIndex = 68, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_MAIN, Transparency = 1, Color = colors.textDarkColor, ZIndex = 68, Visible = false, Text = element.descriptionText }))
        element.arrow = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = FONT_MAIN, Transparency = 1, Color = state and colors.accentColor or colors.textDarkColor, ZIndex = 68, Visible = false, Text = ">" }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x + 2, self.y, self.w - 4, self.height)
        end
        function element:onMouseDown()
            local newState = not LibraryApi.Flags[self.flag]
            LibraryApi.Flags[self.flag] = newState
            saveConfiguration()
            if self.callback then task.spawn(self.callback, newState) end
        end
        function element:draw()
            local stateNow = LibraryApi.Flags[self.flag]
            local hovered = UI.hovered == self
            setSoftFrame(self.bg, self.x + 2, self.y, self.w - 4, self.height, 4, stateNow and colors.elementHoverBackground or colors.elementBackground, 0.78153, stateNow and colors.borderLightColor or (hovered and colors.borderLightColor or colors.borderColor), 0.92, 1)
            setSoftFrame(self.check, self.x + 12, self.y + 14, 16, 16, 4, stateNow and colors.accentColor or colors.sectionBackground, 0.78153, stateNow and colors.accentColor or colors.borderColor, 0.92, 1)
            setRoundedPrimitive(self.dot, self.x + 16, self.y + 18, 8, 8, 3, colors.textWhiteColor, stateNow and 1 or 0, stateNow)
            self.label.Position = Vector2.new(self.x + 40, self.y + 7)
            self.label.Text = self.name
            self.label.Color = stateNow and colors.textWhiteColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.desc.Position = Vector2.new(self.x + 40, self.y + 22)
            self.desc.Text = self.descriptionText
            self.desc.Color = colors.textDarkColor
            self.arrow.Text = stateNow and "v" or ">"
            self.arrow.Position = Vector2.new(self.x + self.w - 16, self.y + 15)
            self.arrow.Color = stateNow and colors.accentColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.bg.Visible = true
            self.check.Visible = true
            self.label.Visible = true
            self.desc.Visible = self.descriptionText ~= ""
            self.arrow.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end

        local moduleSection = {
            title = section.title,
            side = section.side,
            elements = section.elements,
            window = section.window,
            tab = section.tab,
            parentModule = element
        }
        return makeSectionApi(moduleSection)
    end

    return api
end

function LibraryApi:CreateWindow(windowName)
    initialize()
    local viewport = getViewportSize()
    local window = {
        title = tostring(windowName or "Window"),
        x = round(viewport.X / 2 - 360),
        y = round(viewport.Y / 2 - 240),
        w = 720,
        h = 480,
        visible = true,
        tabs = {},
        activeTab = nil
    }
    createWindowDrawings(window)
    table.insert(UI.windows, window)

    local api = {}

    function api:_RedrawAll()
        layoutWindow(window)
        renderWindow(window)
    end

    function api:Tab_Create(tabName, tabIcon)
        local tab = {
            title = tostring(tabName or "Tab"),
            icon = tostring(tabIcon or "•"),
            sections = {},
            window = window
        }
        createTabDrawings(tab)
        table.insert(window.tabs, tab)
        if not window.activeTab then
            window.activeTab = tab
        end

        local tabApi = {}

        function tabApi:SetIcon(iconText)
            tab.icon = tostring(iconText or "•")
            return self
        end

        function tabApi:Section_Create(columnSide, sectionTitle)
            columnSide, sectionTitle = normalizeSectionArgs(columnSide, sectionTitle)
            local section = {
                title = tostring(sectionTitle or "Section"),
                side = columnSide == "Right" and "Right" or "Left",
                elements = {},
                window = window,
                tab = tab,
                scroll = 0,
                scrollMax = 0
            }
            createSectionDrawings(section)
            table.insert(tab.sections, section)
            return makeSectionApi(section)
        end

        return tabApi
    end

    return api
end



return LibraryApi
