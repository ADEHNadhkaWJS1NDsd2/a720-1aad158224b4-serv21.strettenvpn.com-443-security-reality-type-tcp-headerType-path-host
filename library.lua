local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local textService = game:GetService("TextService")
local httpService = game:GetService("HttpService")
local workspaceService = game:GetService("Workspace")
local playersService = game:GetService("Players")

local LibraryApi = {
    Flags = {},
    FolderName = "Moonshade",
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
    notificationInfoColor = Color3.new(0.247058, 0.635294, 0.980392),
    notificationSuccessColor = Color3.new(0.247058, 0.980392, 0.490196),
    notificationWarningColor = Color3.new(0.980392, 0.819607, 0.247058),
    notificationErrorColor = Color3.new(0.980392, 0.247058, 0.247058)
}

local drawingObjects = {}
local function newDrawing(class, props)
    local obj = Drawing.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    table.insert(drawingObjects, obj)
    return obj
end

local function removeDrawing(obj)
    if obj then
        for i, v in ipairs(drawingObjects) do
            if v == obj then
                table.remove(drawingObjects, i)
                break
            end
        end
        obj:Remove()
    end
end

local function colorToDrawing(c3, alpha)
    return Color3.new(c3.R, c3.G, c3.B), alpha or 1
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function lerpColor(c1, c2, t)
    return Color3.new(
        lerp(c1.R, c2.R, t),
        lerp(c1.G, c2.G, t),
        lerp(c1.B, c2.B, t)
    )
end

local tweens = {}
local function animateDrawing(obj, props, duration)
    duration = duration or 0.35
    local startVals = {}
    for k, v in pairs(props) do
        startVals[k] = obj[k]
    end
    local startTime = tick()
    local conn
    conn = runService.RenderStepped:Connect(function()
        local elapsed = tick() - startTime
        local t = math.min(elapsed / duration, 1)
        local ease = 1 - (1 - t)^3
        for k, v in pairs(props) do
            if type(v) == "number" then
                obj[k] = lerp(startVals[k], v, ease)
            elseif typeof(v) == "Color3" then
                obj[k] = lerpColor(startVals[k], v, ease)
            elseif typeof(v) == "Vector2" then
                obj[k] = Vector2.new(
                    lerp(startVals[k].X, v.X, ease),
                    lerp(startVals[k].Y, v.Y, ease)
                )
            else
                obj[k] = v
            end
        end
        if t >= 1 then
            conn:Disconnect()
        end
    end)
    return conn
end

local function drawRect(x, y, w, h, color, alpha, zIndex, filled, thickness)
    local rect = newDrawing("Square", {
        Position = Vector2.new(x, y),
        Size = Vector2.new(w, h),
        Color = color,
        Transparency = alpha or 1,
        ZIndex = zIndex or 1,
        Filled = filled ~= false,
        Thickness = thickness or 1,
        Visible = true
    })
    return rect
end

local function drawText(text, x, y, size, color, alpha, zIndex, font, center, outline)
    local t = newDrawing("Text", {
        Text = text,
        Position = Vector2.new(x, y),
        Size = size or 12,
        Color = color,
        Transparency = alpha or 1,
        ZIndex = zIndex or 1,
        Font = font or Drawing.Fonts.UI,
        Center = center or false,
        Outline = outline or false,
        Visible = true
    })
    return t
end

local function drawLine(x1, y1, x2, y2, color, alpha, thickness, zIndex)
    local l = newDrawing("Line", {
        From = Vector2.new(x1, y1),
        To = Vector2.new(x2, y2),
        Color = color,
        Transparency = alpha or 1,
        Thickness = thickness or 1,
        ZIndex = zIndex or 1,
        Visible = true
    })
    return l
end

local function drawCircle(x, y, r, color, alpha, zIndex, filled, thickness)
    local c = newDrawing("Circle", {
        Position = Vector2.new(x, y),
        Radius = r,
        Color = color,
        Transparency = alpha or 1,
        ZIndex = zIndex or 1,
        Filled = filled ~= false,
        Thickness = thickness or 1,
        Visible = true
    })
    return c
end

local function shiftAnyDrawing(obj, dx, dy)
    if not obj then return end
    local ok, pos = pcall(function() return obj.Position end)
    if ok and typeof(pos) == "Vector2" then
        obj.Position = Vector2.new(pos.X + dx, pos.Y + dy)
        return
    end
    local okFrom, from = pcall(function() return obj.From end)
    local okTo, to = pcall(function() return obj.To end)
    if okFrom and okTo and typeof(from) == "Vector2" and typeof(to) == "Vector2" then
        obj.From = Vector2.new(from.X + dx, from.Y + dy)
        obj.To = Vector2.new(to.X + dx, to.Y + dy)
    end
end

local function getTextSize(text, size)
    local b = textService:GetTextSize(text, size or 12, Enum.Font.GothamMedium, Vector2.new(500, 500))
    return b.X, b.Y
end

local function isMouseOver(x, y, w, h)
    local mouse = userInputService:GetMouseLocation()
    return mouse.X >= x and mouse.X <= x + w and mouse.Y >= y and mouse.Y <= y + h
end

local function snapValue(value, step)
    if not step then return value end
    return math.floor((value / step) + 0.5) * step
end

local function formatValue(value, step)
    if step and step < 1 then
        local decimalPlaces = tostring(step):len() - 2
        return string.format("%."..decimalPlaces.."f", value)
    end
    return tostring(value)
end

local function saveConfiguration()
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(LibraryApi.FolderName) then makefolder(LibraryApi.FolderName) end
        local serializedData = {}
        for key, val in pairs(LibraryApi.Flags) do
            if typeof(val) == "Color3" then
                serializedData[key] = {Type = "Color3", R = val.R, G = val.G, B = val.B}
            elseif typeof(val) == "EnumItem" then
                serializedData[key] = {Type = "KeyCode", Name = val.Name}
            elseif type(val) == "table" and val.Min and val.Max then
                serializedData[key] = {Type = "Range", Min = val.Min, Max = val.Max}
            else
                serializedData[key] = val
            end
        end
        writefile(LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName, httpService:JSONEncode(serializedData))
    end)
end

local function loadConfiguration()
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local fullPath = LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName
        if isfile(fullPath) then
            local decodedData = httpService:JSONDecode(readfile(fullPath))
            if type(decodedData) == "table" then
                for key, val in pairs(decodedData) do
                    if type(val) == "table" then
                        if val.Type == "Color3" then
                            LibraryApi.Flags[key] = Color3.new(val.R, val.G, val.B)
                        elseif val.Type == "KeyCode" then
                            LibraryApi.Flags[key] = Enum.KeyCode[val.Name] or Enum.KeyCode.Unknown
                        elseif val.Type == "Range" then
                            LibraryApi.Flags[key] = {Min = val.Min, Max = val.Max}
                        end
                    else
                        LibraryApi.Flags[key] = val
                    end
                end
            end
        end
    end)
end

loadConfiguration()

local tooltipDrawings = {}
local tooltipTargetText = ""
local tooltipAlpha = 0

do
    tooltipDrawings.bg = drawRect(0, 0, 0, 24, colors.tooltipBackground, 0, 200, true)
    tooltipDrawings.border = drawRect(0, 0, 0, 24, colors.borderLightColor, 0, 200, false, 1)
    tooltipDrawings.text = drawText("", 0, 0, 12, colors.textWhiteColor, 0, 201)
end

local function showTooltip(textString)
    tooltipTargetText = textString or ""
end

local notifications = {}

function LibraryApi:Notify(config)
    local title = config.Title or "Notification"
    local text = config.Text or ""
    local duration = config.Duration or 3
    local notificationType = config.Type or "Info"
    local accentColor = colors["notification" .. notificationType .. "Color"] or colors.accentColor

    local vp = workspaceService.CurrentCamera.ViewportSize
    local nw, nh = 280, 56
    local nx = vp.X - nw - 20
    local baseY = vp.Y - 20

    local notif = {
        alpha = 0,
        offsetX = nw + 20,
        y = baseY,
        drawings = {}
    }

    notif.drawings.bg = drawRect(nx + notif.offsetX, baseY - nh, nw, nh, colors.mainBackground, 0, 150, true)
    notif.drawings.border = drawRect(nx + notif.offsetX, baseY - nh, nw, nh, colors.borderLightColor, 0, 150, false, 1)
    notif.drawings.line = drawRect(nx + notif.offsetX + 6, baseY - nh + 6, 3, nh - 12, accentColor, 0, 151, true)
    notif.drawings.title = drawText(title, nx + notif.offsetX + 16, baseY - nh + 8, 13, colors.textWhiteColor, 0, 151)
    notif.drawings.text = drawText(text, nx + notif.offsetX + 16, baseY - nh + 24, 11, colors.textDarkColor, 0, 151)

    table.insert(notifications, notif)

    local slideIn = 0
    local life = 0
    local sliding = true
    local fadingOut = false

    local conn
    conn = runService.RenderStepped:Connect(function(dt)
        if sliding then
            slideIn = math.min(slideIn + dt * 3, 1)
            local ease = 1 - (1 - slideIn)^3
            notif.offsetX = (nw + 20) * (1 - ease)
            notif.alpha = ease
        else
            life = life + dt
            if life >= duration then
                fadingOut = true
                sliding = false
            end
        end

        if fadingOut then
            notif.alpha = math.max(notif.alpha - dt * 2, 0)
            notif.offsetX = notif.offsetX + dt * 300
            if notif.alpha <= 0 then
                for _, d in pairs(notif.drawings) do d:Remove() end
                conn:Disconnect()
                return
            end
        end

        if slideIn >= 1 and not fadingOut then
            sliding = false
            life = life + 0
        end

        local curX = nx + notif.offsetX
        notif.drawings.bg.Position = Vector2.new(curX, baseY - nh)
        notif.drawings.bg.Transparency = notif.alpha
        notif.drawings.border.Position = Vector2.new(curX, baseY - nh)
        notif.drawings.border.Transparency = notif.alpha * 0.5
        notif.drawings.line.Position = Vector2.new(curX + 6, baseY - nh + 6)
        notif.drawings.line.Transparency = notif.alpha
        notif.drawings.title.Position = Vector2.new(curX + 16, baseY - nh + 8)
        notif.drawings.title.Transparency = notif.alpha
        notif.drawings.text.Position = Vector2.new(curX + 16, baseY - nh + 24)
        notif.drawings.text.Transparency = notif.alpha * 0.7

        if slideIn >= 1 and not fadingOut then
            task.delay(duration, function()
                fadingOut = true
            end)
            sliding = false
            life = math.huge
        end
    end)
end

runService.RenderStepped:Connect(function()
    local mouse = userInputService:GetMouseLocation()
    if tooltipTargetText ~= "" then
        local tw, _ = getTextSize(tooltipTargetText, 12)
        local bw = tw + 16
        local bx = mouse.X + 15
        local by = mouse.Y + 15
        tooltipAlpha = math.min(tooltipAlpha + 0.15, 1)
        tooltipDrawings.bg.Position = Vector2.new(bx, by)
        tooltipDrawings.bg.Size = Vector2.new(bw, 22)
        tooltipDrawings.bg.Transparency = tooltipAlpha * 0.85
        tooltipDrawings.border.Position = Vector2.new(bx, by)
        tooltipDrawings.border.Size = Vector2.new(bw, 22)
        tooltipDrawings.border.Transparency = tooltipAlpha * 0.6
        tooltipDrawings.text.Text = tooltipTargetText
        tooltipDrawings.text.Position = Vector2.new(bx + 8, by + 5)
        tooltipDrawings.text.Transparency = tooltipAlpha
    else
        tooltipAlpha = math.max(tooltipAlpha - 0.15, 0)
        tooltipDrawings.bg.Transparency = tooltipAlpha * 0.85
        tooltipDrawings.border.Transparency = tooltipAlpha * 0.6
        tooltipDrawings.text.Transparency = tooltipAlpha
    end
end)

function LibraryApi:CreateWindow(windowName)
    local vp = workspaceService.CurrentCamera.ViewportSize
    local WW, WH = 720, 480
    local WX = math.floor(vp.X / 2 - WW / 2)
    local WY = math.floor(vp.Y / 2 - WH / 2)

    local isDragging = false
    local dragOffsetX, dragOffsetY = 0, 0

    local windowVisible = true

    local winDrawings = {}

    winDrawings.bg = drawRect(WX, WY, WW, WH, colors.mainBackground, 0.82, 1, true)
    winDrawings.bgBorder = drawRect(WX, WY, WW, WH, colors.borderColor, 1, 1, false, 1)

    local topH = 36
    winDrawings.topBar = drawRect(WX, WY, WW, topH, colors.sidebarBackground, 0.78, 2, true)
    winDrawings.topBorder = drawLine(WX, WY + topH, WX + WW, WY + topH, colors.borderColor, 1, 1, 2)
    winDrawings.accentLine = drawRect(WX, WY, WW, 2, colors.accentColor, 1, 3, true)
    winDrawings.title = drawText(windowName, WX + 15, WY + 11, 13, colors.textWhiteColor, 1, 3)

    local sideW = 150
    winDrawings.sidebar = drawRect(WX, WY + topH, sideW, WH - topH, colors.sidebarBackground, 0.78, 2, true)
    winDrawings.sidebarBorder = drawLine(WX + sideW, WY + topH, WX + sideW, WY + WH, colors.borderColor, 1, 1, 2)

    local function redrawWindow()
        winDrawings.bg.Position = Vector2.new(WX, WY)
        winDrawings.bgBorder.Position = Vector2.new(WX, WY)
        winDrawings.topBar.Position = Vector2.new(WX, WY)
        winDrawings.topBorder.From = Vector2.new(WX, WY + topH)
        winDrawings.topBorder.To = Vector2.new(WX + WW, WY + topH)
        winDrawings.accentLine.Position = Vector2.new(WX, WY)
        winDrawings.title.Position = Vector2.new(WX + 15, WY + 11)
        winDrawings.sidebar.Position = Vector2.new(WX, WY + topH)
        winDrawings.sidebarBorder.From = Vector2.new(WX + sideW, WY + topH)
        winDrawings.sidebarBorder.To = Vector2.new(WX + sideW, WY + WH)
    end

    local function setWindowVisible(v)
        windowVisible = v
        for _, d in pairs(winDrawings) do d.Visible = v end
        if windowContext then
            for _, td in ipairs(windowContext.Tabs) do
                if td._drawings then
                    for _, d in pairs(td._drawings) do
                        if d.Visible ~= nil then
                            if d == td._drawings.hover then
                                d.Visible = false
                            else
                                d.Visible = v
                            end
                        end
                    end
                end
                for _, eg in ipairs(td._elements or {}) do
                    for _, d in pairs(eg) do
                        if d.Visible ~= nil then
                            d.Visible = v and windowContext.Active_Tab == td
                        end
                    end
                end
            end
        end
    end

    userInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.Delete then
            setWindowVisible(not windowVisible)
        end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = userInputService:GetMouseLocation()
            if isMouseOver(WX, WY, WW, topH) then
                isDragging = true
                dragOffsetX = mouse.X - WX
                dragOffsetY = mouse.Y - WY
            end
        end
    end)

    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    runService.RenderStepped:Connect(function()
        if isDragging then
            local mouse = userInputService:GetMouseLocation()
            local viewport = workspaceService.CurrentCamera.ViewportSize
            WX = math.clamp(mouse.X - dragOffsetX, 0, math.max(0, viewport.X - WW))
            WY = math.clamp(mouse.Y - dragOffsetY, 0, math.max(0, viewport.Y - WH))
            redrawWindow()
            if windowContext then
                windowContext:_RedrawAll()
            end
        end
    end)

    local windowContext = { Tabs = {}, Active_Tab = nil, _RedrawAll = function() end }
    local lastRedrawWX, lastRedrawWY = WX, WY

    local tabYStart = WY + topH + 8
    local tabX = WX + 6
    local tabButtonDrawings = {}

    local contentX = WX + sideW + 10
    local contentY = WY + topH + 10
    local contentW = WW - sideW - 20
    local contentH = WH - topH - 20

    local scrollOffsets = {}

    local allTabDrawings = {}
    local allElementDrawings = {}

    local function getContentBounds()
        return WX + sideW + 10, WY + topH + 10, WW - sideW - 20, WH - topH - 20
    end

    function windowContext:_RedrawAll()
        local dx = WX - lastRedrawWX
        local dy = WY - lastRedrawWY
        redrawWindow()
        tabYStart = WY + topH + 8
        for i, td in ipairs(self.Tabs) do
            local ty = tabYStart + (i - 1) * 36
            if td._drawings then
                td._drawings.btn.Position = Vector2.new(WX + 6, ty)
                td._drawings.label.Position = Vector2.new(WX + 12 + (td._iconOffset or 0), ty + 9)
                td._drawings.indicator.Position = Vector2.new(WX + 6, ty + 8)
                if td._drawings.hover then
                    td._drawings.hover.Position = Vector2.new(WX + 6, ty)
                end
            end
            if td._tabPositionUpdater then
                td._tabPositionUpdater(dx, dy, ty)
            end
            if dx ~= 0 or dy ~= 0 then
                for _, updater in ipairs(td._positionUpdaters or {}) do
                    updater(dx, dy)
                end
                for _, eg in ipairs(td._elements or {}) do
                    for _, d in pairs(eg) do
                        shiftAnyDrawing(d, dx, dy)
                    end
                end
            end
        end
        lastRedrawWX, lastRedrawWY = WX, WY
    end

    function windowContext:Tab_Create(tabName, iconId)
        local tabIndex = #self.Tabs + 1
        local ty = tabYStart + (tabIndex - 1) * 36

        local tabData = {
            _elements = {},
            _iconOffset = 0,
            _scrollOffset = 0,
            _positionUpdaters = {}
        }

        local td = {}
        td.hover = drawRect(WX + 6, ty, sideW - 12, 30, colors.elementHoverBackground, 1, 3, true)
        td.btn = drawRect(WX + 6, ty, sideW - 12, 30, colors.elementHoverBackground, 1, 3, true)
        td.hover.Visible = false
        td.btn.Visible = true
        td.label = drawText(tabName, WX + 12, ty + 9, 12, colors.textDarkColor, 1, 4)
        td.indicator = drawRect(WX + 6, ty + 8, 2, 0, colors.accentColor, 1, 4, true)

        tabData._drawings = td

        local function registerPositionUpdater(fn)
            table.insert(tabData._positionUpdaters, fn)
        end

        local localTY = ty
        tabData._tabPositionUpdater = function(dx, dy, newTy)
            localTY = newTy or (localTY + dy)
        end

        local function activate()
            if windowContext.Active_Tab == tabData then return end
            if windowContext.Active_Tab then
                local old = windowContext.Active_Tab
                old._drawings.btn.Transparency = 1
                old._drawings.label.Color = colors.textDarkColor
                old._drawings.indicator.Size = Vector2.new(2, 0)
                for _, ed in ipairs(old._elements) do
                    for _, d in pairs(ed) do
                        if d.Visible ~= nil then d.Visible = false end
                    end
                end
            end
            windowContext.Active_Tab = tabData
            td.btn.Transparency = 0.88
            td.label.Color = colors.textWhiteColor
            td.indicator.Size = Vector2.new(2, 14)
            td.indicator.Position = Vector2.new(WX + 6, localTY + 8)
            for _, ed in ipairs(tabData._elements) do
                for _, d in pairs(ed) do
                    if d.Visible ~= nil then d.Visible = true end
                end
            end
        end

        userInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if isMouseOver(WX + 6, localTY, sideW - 12, 30) and windowVisible then
                    activate()
                end
            end
        end)

        runService.RenderStepped:Connect(function()
            if not windowVisible then return end
            if isMouseOver(WX + 6, localTY, sideW - 12, 30) then
                td.hover.Visible = true
            else
                td.hover.Visible = false
            end
        end)

        table.insert(self.Tabs, tabData)
        if #self.Tabs == 1 then activate() end

        local columnLeftX = WX + sideW + 10
        local columnRightX = WX + sideW + 10 + math.floor((WW - sideW - 20) / 2) + 6
        local columnWidth = math.floor((WW - sideW - 20) / 2) - 16

        local leftCursorY = WY + topH + 10
        local rightCursorY = WY + topH + 10

        local function elementInjector(side)
            local cursorY = side == "Left" and leftCursorY or rightCursorY
            local colX = side == "Left" and columnLeftX or columnRightX

            local elements = {}
            local elementGroup = {}
            table.insert(tabData._elements, elementGroup)

            local function isVisible()
                return windowContext.Active_Tab == tabData and windowVisible
            end

            local function nextY(side2)
                if side2 == "Left" then
                    return leftCursorY
                else
                    return rightCursorY
                end
            end

            local function advanceCursor(side2, amount)
                if side2 == "Left" then
                    leftCursorY = leftCursorY + amount
                else
                    rightCursorY = rightCursorY + amount
                end
            end

            function elements:Subtext_Create(text, elSide)
                local s = elSide or side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local d = {}
                d.text = drawText(text, cx + 4, cy + 2, 11, colors.textDarkColor, 1, 10)
                d.text.Visible = isVisible()
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, 18)
            end

            function elements:Toggle_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or false)
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 18

                local d = {}
                d.checkbox = drawRect(cx + 2, cy + 2, 13, 13, LibraryApi.Flags[flag] and colors.accentColor or colors.elementBackground, 0.78, 10, true)
                d.checkboxBorder = drawRect(cx + 2, cy + 2, 13, 13, LibraryApi.Flags[flag] and colors.accentColor or colors.borderColor, 1, 10, false, 1)
                d.label = drawText(name, cx + 22, cy + 3, 12, LibraryApi.Flags[flag] and colors.textWhiteColor or colors.textDarkColor, 1, 10)
                for _, v in pairs(d) do v.Visible = isVisible() end

                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 6)

                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)
                userInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and windowVisible and windowContext.Active_Tab == tabData then
                        if isMouseOver(cx, localCY, columnWidth, h) then
                            LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                            local ns = LibraryApi.Flags[flag]
                            d.checkbox.Color = ns and colors.accentColor or colors.elementBackground
                            d.checkboxBorder.Color = ns and colors.accentColor or colors.borderColor
                            d.label.Color = ns and colors.textWhiteColor or colors.textDarkColor
                            saveConfiguration()
                            if callback then task.spawn(callback, ns) end
                        end
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx, localCY, columnWidth, h) then
                        showTooltip(tooltip)
                    end
                end)
            end

            function elements:Slider_Create(name, flag, min, max, default, step, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or snapValue(default or min, step)
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 36
                local sw = columnWidth - 4

                local d = {}
                d.label = drawText(name, cx + 2, cy + 1, 12, colors.textWhiteColor, 1, 10)
                d.value = drawText(formatValue(LibraryApi.Flags[flag], step), cx + sw - 2, cy + 1, 12, colors.textWhiteColor, 1, 10)
                d.track = drawRect(cx + 2, cy + 18, sw - 4, 6, colors.elementBackground, 0.78, 10, true)
                d.trackBorder = drawRect(cx + 2, cy + 18, sw - 4, 6, colors.borderColor, 1, 10, false, 1)

                local pct = (LibraryApi.Flags[flag] - min) / (max - min)
                d.fill = drawRect(cx + 2, cy + 18, math.max(1, (sw - 4) * pct), 6, colors.accentColor, 1, 11, true)
                d.knob = drawCircle(cx + 2 + (sw - 4) * pct, cy + 21, 5, colors.textWhiteColor, 1, 12, true)
                d.knobBorder = drawCircle(cx + 2 + (sw - 4) * pct, cy + 21, 5, colors.borderColor, 1, 12, false, 1)

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 4)

                local isSliding = false
                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)

                local function setVal(newVal)
                    local clamped = math.clamp(newVal, min, max)
                    local snapped = snapValue(clamped, step)
                    LibraryApi.Flags[flag] = snapped
                    local p = (snapped - min) / (max - min)
                    d.fill.Size = Vector2.new(math.max(1, (sw - 4) * p), 6)
                    d.knob.Position = Vector2.new(cx + 2 + (sw - 4) * p, localCY + 21)
                    d.knobBorder.Position = Vector2.new(cx + 2 + (sw - 4) * p, localCY + 21)
                    d.value.Text = formatValue(snapped, step)
                    saveConfiguration()
                    if callback then task.spawn(callback, snapped) end
                end

                userInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and windowVisible and windowContext.Active_Tab == tabData then
                        local mouse = userInputService:GetMouseLocation()
                        if isMouseOver(cx + 2, localCY + 15, sw - 4, 12) then
                            isSliding = true
                            local p = math.clamp((mouse.X - (cx + 2)) / (sw - 4), 0, 1)
                            setVal(min + (max - min) * p)
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local mouse = userInputService:GetMouseLocation()
                        local p = math.clamp((mouse.X - (cx + 2)) / (sw - 4), 0, 1)
                        setVal(min + (max - min) * p)
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + 2, localCY + 15, sw - 4, 12) then
                        showTooltip(tooltip)
                        d.trackBorder.Color = colors.borderLightColor
                    else
                        d.trackBorder.Color = colors.borderColor
                    end
                end)
            end

            function elements:RangeSlider_Create(name, flag, min, max, defaultMin, defaultMax, step, tooltip, callback)
                if not LibraryApi.Flags[flag] then
                    LibraryApi.Flags[flag] = {Min = snapValue(defaultMin or min, step), Max = snapValue(defaultMax or max, step)}
                end
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 36
                local sw = columnWidth - 4

                local d = {}
                d.label = drawText(name, cx + 2, cy + 1, 12, colors.textWhiteColor, 1, 10)
                d.value = drawText(formatValue(LibraryApi.Flags[flag].Min, step) .. " - " .. formatValue(LibraryApi.Flags[flag].Max, step), cx + sw - 2, cy + 1, 12, colors.textWhiteColor, 1, 10)
                d.track = drawRect(cx + 2, cy + 18, sw - 4, 6, colors.elementBackground, 0.78, 10, true)
                d.trackBorder = drawRect(cx + 2, cy + 18, sw - 4, 6, colors.borderColor, 1, 10, false, 1)

                local minP = (LibraryApi.Flags[flag].Min - min) / (max - min)
                local maxP = (LibraryApi.Flags[flag].Max - min) / (max - min)
                d.fill = drawRect(cx + 2 + (sw - 4) * minP, cy + 18, (sw - 4) * (maxP - minP), 6, colors.accentColor, 1, 11, true)
                d.minKnob = drawCircle(cx + 2 + (sw - 4) * minP, cy + 21, 5, colors.textWhiteColor, 1, 12, true)
                d.maxKnob = drawCircle(cx + 2 + (sw - 4) * maxP, cy + 21, 5, colors.textWhiteColor, 1, 12, true)
                d.minKnobBorder = drawCircle(cx + 2 + (sw - 4) * minP, cy + 21, 5, colors.borderColor, 1, 12, false, 1)
                d.maxKnobBorder = drawCircle(cx + 2 + (sw - 4) * maxP, cy + 21, 5, colors.borderColor, 1, 12, false, 1)

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 4)

                local isSlidingMin = false
                local isSlidingMax = false
                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)

                local function updateVisuals()
                    local mnP = (LibraryApi.Flags[flag].Min - min) / (max - min)
                    local mxP = (LibraryApi.Flags[flag].Max - min) / (max - min)
                    d.fill.Position = Vector2.new(cx + 2 + (sw - 4) * mnP, localCY + 18)
                    d.fill.Size = Vector2.new(math.max(1, (sw - 4) * (mxP - mnP)), 6)
                    d.minKnob.Position = Vector2.new(cx + 2 + (sw - 4) * mnP, localCY + 21)
                    d.minKnobBorder.Position = d.minKnob.Position
                    d.maxKnob.Position = Vector2.new(cx + 2 + (sw - 4) * mxP, localCY + 21)
                    d.maxKnobBorder.Position = d.maxKnob.Position
                    d.value.Text = formatValue(LibraryApi.Flags[flag].Min, step) .. " - " .. formatValue(LibraryApi.Flags[flag].Max, step)
                end

                userInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and windowVisible and windowContext.Active_Tab == tabData then
                        local mouse = userInputService:GetMouseLocation()
                        if isMouseOver(cx + 2, localCY + 15, sw - 4, 12) then
                            local p = math.clamp((mouse.X - (cx + 2)) / (sw - 4), 0, 1)
                            local mnP = (LibraryApi.Flags[flag].Min - min) / (max - min)
                            local mxP = (LibraryApi.Flags[flag].Max - min) / (max - min)
                            if math.abs(p - mnP) < math.abs(p - mxP) then
                                isSlidingMin = true
                            else
                                isSlidingMax = true
                            end
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isSlidingMin = false
                        isSlidingMax = false
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if (isSlidingMin or isSlidingMax) and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local mouse = userInputService:GetMouseLocation()
                        local p = math.clamp((mouse.X - (cx + 2)) / (sw - 4), 0, 1)
                        local v2 = snapValue(min + (max - min) * p, step)
                        if isSlidingMin then
                            LibraryApi.Flags[flag].Min = math.min(v2, LibraryApi.Flags[flag].Max)
                        else
                            LibraryApi.Flags[flag].Max = math.max(v2, LibraryApi.Flags[flag].Min)
                        end
                        updateVisuals()
                        saveConfiguration()
                        if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                    end
                end)
            end

            function elements:Textbox_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or "")
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 36
                local sw = columnWidth - 4

                local inputText = LibraryApi.Flags[flag]
                local isFocused = false
                local cursorVisible = true
                local cursorTimer = 0

                local d = {}
                d.label = drawText(name, cx + 2, cy + 1, 12, colors.textWhiteColor, 1, 10)
                d.inputBg = drawRect(cx + 2, cy + 18, sw - 4, 20, colors.elementBackground, 0.78, 10, true)
                d.inputBorder = drawRect(cx + 2, cy + 18, sw - 4, 20, colors.borderColor, 1, 10, false, 1)
                d.inputText = drawText(inputText, cx + 6, cy + 22, 11, colors.textDarkColor, 1, 11)
                d.cursor = drawRect(cx + 6 + getTextSize(inputText, 11), cy + 20, 1, 14, colors.textWhiteColor, 0, 11, true)

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 4)

                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isMouseOver(cx + 2, localCY + 18, sw - 4, 20) then
                            isFocused = true
                            d.inputBorder.Color = colors.accentColor
                            d.inputText.Color = colors.textWhiteColor
                        else
                            if isFocused then
                                isFocused = false
                                d.inputBorder.Color = colors.borderColor
                                d.inputText.Color = colors.textDarkColor
                                d.cursor.Transparency = 0
                                LibraryApi.Flags[flag] = inputText
                                saveConfiguration()
                                if callback then task.spawn(callback, inputText) end
                            end
                        end
                    end
                    if isFocused and input.UserInputType == Enum.UserInputType.Keyboard then
                        local kc = input.KeyCode
                        if kc == Enum.KeyCode.BackSpace then
                            inputText = inputText:sub(1, -2)
                        elseif kc == Enum.KeyCode.Return then
                            isFocused = false
                            d.inputBorder.Color = colors.borderColor
                            d.inputText.Color = colors.textDarkColor
                            d.cursor.Transparency = 0
                            LibraryApi.Flags[flag] = inputText
                            saveConfiguration()
                            if callback then task.spawn(callback, inputText) end
                        end
                        d.inputText.Text = inputText
                        local tw = getTextSize(inputText, 11)
                        d.cursor.Position = Vector2.new(cx + 6 + tw, localCY + 20)
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if isFocused and input.UserInputType == Enum.UserInputType.TextInput then
                        local char = input.Position.Z
                        if char >= 32 and char < 127 then
                            inputText = inputText .. string.char(char)
                            d.inputText.Text = inputText
                            local tw = getTextSize(inputText, 11)
                            d.cursor.Position = Vector2.new(cx + 6 + tw, localCY + 20)
                        end
                    end
                end)

                runService.RenderStepped:Connect(function(dt)
                    if isFocused then
                        cursorTimer = cursorTimer + dt
                        if cursorTimer >= 0.5 then
                            cursorTimer = 0
                            cursorVisible = not cursorVisible
                            d.cursor.Transparency = cursorVisible and 1 or 0
                        end
                    end
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + 2, localCY + 18, sw - 4, 20) then
                        showTooltip(tooltip)
                        if not isFocused then d.inputBorder.Color = colors.borderLightColor end
                    else
                        if not isFocused then d.inputBorder.Color = colors.borderColor end
                    end
                end)
            end

            function elements:Keybind_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or Enum.KeyCode.Unknown)
                local isListening = false
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 28
                local sw = columnWidth - 4

                local function getKeyText()
                    return LibraryApi.Flags[flag] == Enum.KeyCode.Unknown and "[ None ]" or "[ " .. LibraryApi.Flags[flag].Name .. " ]"
                end

                local d = {}
                d.label = drawText(name, cx + 2, cy + 7, 12, colors.textWhiteColor, 1, 10)
                d.btnBg = drawRect(cx + sw - 72, cy + 3, 70, 22, colors.elementBackground, 0.78, 10, true)
                d.btnBorder = drawRect(cx + sw - 72, cy + 3, 70, 22, colors.borderColor, 1, 10, false, 1)
                d.btnText = drawText(getKeyText(), cx + sw - 72 + 35, cy + 8, 11, colors.textDarkColor, 1, 11)
                d.btnText.Center = true

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 4)

                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isMouseOver(cx + sw - 72, localCY + 3, 70, 22) then
                            isListening = true
                            d.btnText.Text = "[ ... ]"
                            d.btnBorder.Color = colors.accentColor
                            d.btnText.Color = colors.textWhiteColor
                        end
                    end
                    if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = input.KeyCode
                        elseif input.KeyCode == Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = Enum.KeyCode.Unknown
                        end
                        isListening = false
                        d.btnText.Text = getKeyText()
                        d.btnBorder.Color = colors.borderColor
                        d.btnText.Color = colors.textDarkColor
                        saveConfiguration()
                        if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                    elseif not isListening and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == LibraryApi.Flags[flag] and input.KeyCode ~= Enum.KeyCode.Unknown then
                            if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                        end
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + sw - 72, localCY + 3, 70, 22) then
                        showTooltip(tooltip)
                        if not isListening then d.btnBorder.Color = colors.borderLightColor end
                    else
                        if not isListening then d.btnBorder.Color = colors.borderColor end
                    end
                end)
            end

            function elements:Dropdown_Create(name, flag, options, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or options[1])
                local isOpen = false
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local baseH = 44
                local sw = columnWidth - 4
                local optH = 22
                local maxVisible = 5

                local d = {}
                d.label = drawText(name, cx + 2, cy + 1, 12, colors.textWhiteColor, 1, 10)
                d.btnBg = drawRect(cx + 2, cy + 16, sw - 4, 22, colors.elementBackground, 0.78, 10, true)
                d.btnBorder = drawRect(cx + 2, cy + 16, sw - 4, 22, colors.borderColor, 1, 10, false, 1)
                d.selected = drawText(LibraryApi.Flags[flag], cx + 8, cy + 21, 12, colors.textDarkColor, 1, 11)
                d.arrow = drawText("v", cx + sw - 12, cy + 21, 11, colors.textDarkColor, 1, 11)

                local optionDrawings = {}
                for i, opt in ipairs(options) do
                    local oy = cy + baseH + (i - 1) * optH
                    local od = {}
                    od.bg = drawRect(cx + 2, oy, sw - 4, optH, colors.elementBackground, 0, 12, true)
                    od.border = drawRect(cx + 2, oy, sw - 4, optH, colors.borderColor, 0, 12, false, 1)
                    od.text = drawText(opt, cx + 8, oy + 5, 12, LibraryApi.Flags[flag] == opt and colors.accentColor or colors.textDarkColor, 0, 13)
                    od.text.Visible = false
                    od.bg.Visible = false
                    od.border.Visible = false
                    optionDrawings[i] = od
                    table.insert(elementGroup, od.bg)
                    table.insert(elementGroup, od.border)
                    table.insert(elementGroup, od.text)
                end

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, baseH + 4)

                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)

                local function toggleOpen()
                    isOpen = not isOpen
                    d.btnBorder.Color = isOpen and colors.accentColor or colors.borderColor
                    d.arrow.Text = isOpen and "^" or "v"
                    for i, od in ipairs(optionDrawings) do
                        local show = isOpen and isVisible()
                        od.bg.Visible = show
                        od.border.Visible = show
                        od.text.Visible = show
                        od.bg.Transparency = show and 0.78 or 0
                        od.border.Transparency = show and 1 or 0
                        od.text.Transparency = show and 1 or 0
                    end
                end

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isMouseOver(cx + 2, localCY + 16, sw - 4, 22) then
                            toggleOpen()
                        elseif isOpen then
                            for i, opt in ipairs(options) do
                                local oy = localCY + baseH + (i - 1) * optH
                                if isMouseOver(cx + 2, oy, sw - 4, optH) then
                                    LibraryApi.Flags[flag] = opt
                                    d.selected.Text = opt
                                    for j, od in ipairs(optionDrawings) do
                                        od.text.Color = j == i and colors.accentColor or colors.textDarkColor
                                    end
                                    toggleOpen()
                                    saveConfiguration()
                                    if callback then task.spawn(callback, opt) end
                                    break
                                end
                            end
                        end
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + 2, localCY + 16, sw - 4, 22) then
                        showTooltip(tooltip)
                        if not isOpen then d.btnBorder.Color = colors.borderLightColor end
                    else
                        if not isOpen then d.btnBorder.Color = colors.borderColor end
                    end
                    if isOpen then
                        for i, od in ipairs(optionDrawings) do
                            local oy = localCY + baseH + (i - 1) * optH
                            if isMouseOver(cx + 2, oy, sw - 4, optH) then
                                od.bg.Transparency = 0.55
                                if LibraryApi.Flags[flag] ~= options[i] then
                                    od.text.Color = colors.textWhiteColor
                                end
                            else
                                od.bg.Transparency = 0.78
                                if LibraryApi.Flags[flag] ~= options[i] then
                                    od.text.Color = colors.textDarkColor
                                end
                            end
                        end
                    end
                end)
            end

            function elements:ColorPicker_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or Color3.new(1, 1, 1))
                local isOpen = false
                local hue, sat, val = LibraryApi.Flags[flag]:ToHSV()
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local sw = columnWidth - 4

                local pickerW = sw - 4
                local pickerH = 120
                local hueBarH = 12

                local d = {}
                d.label = drawText(name, cx + 2, cy + 4, 12, colors.textWhiteColor, 1, 10)
                d.preview = drawRect(cx + sw - 28, cy, 24, 16, LibraryApi.Flags[flag], 1, 10, true)
                d.previewBorder = drawRect(cx + sw - 28, cy, 24, 16, colors.borderColor, 1, 10, false, 1)

                local expandY = cy + 22

                d.pickerBg = drawRect(cx + 2, expandY, pickerW, pickerH, colors.elementBackground, 0, 10, true)
                d.pickerBorder = drawRect(cx + 2, expandY, pickerW, pickerH, colors.borderColor, 0, 10, false, 1)

                d.satValBg = drawRect(cx + 4, expandY + 4, pickerW - 8, pickerH - 24, Color3.fromHSV(hue, 1, 1), 0, 11, true)
                d.satValWhite = drawRect(cx + 4, expandY + 4, pickerW - 8, pickerH - 24, Color3.new(1,1,1), 0, 12, true)
                d.satValBlack = drawRect(cx + 4, expandY + 4, pickerW - 8, pickerH - 24, Color3.new(0,0,0), 0, 13, true)

                local svW = pickerW - 8
                local svH = pickerH - 24
                d.svCursor = drawCircle(cx + 4 + svW * sat, expandY + 4 + svH * (1 - val), 4, Color3.new(1,1,1), 0, 14, true)
                d.svCursorBorder = drawCircle(cx + 4 + svW * sat, expandY + 4 + svH * (1 - val), 4, Color3.new(0,0,0), 0, 14, false, 1)

                local hueY = expandY + pickerH - 16
                d.hueBar = drawRect(cx + 4, hueY, pickerW - 8, hueBarH, Color3.new(1,1,1), 0, 11, true)
                d.hueBorder = drawRect(cx + 4, hueY, pickerW - 8, hueBarH, colors.borderColor, 0, 11, false, 1)
                d.hueCursor = drawRect(cx + 4 + (pickerW - 8) * hue - 2, hueY - 2, 4, hueBarH + 4, Color3.new(1,1,1), 0, 12, true)
                d.hueCursorBorder = drawRect(cx + 4 + (pickerW - 8) * hue - 2, hueY - 2, 4, hueBarH + 4, Color3.new(0,0,0), 0, 12, false, 1)

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, 24)

                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                    expandY = expandY + dy
                    hueY = hueY + dy
                end)
                local isSlidingSV = false
                local isSlidingHue = false

                local function updateColor()
                    local c = Color3.fromHSV(hue, sat, val)
                    LibraryApi.Flags[flag] = c
                    d.preview.Color = c
                    d.satValBg.Color = Color3.fromHSV(hue, 1, 1)
                    d.svCursor.Position = Vector2.new(cx + 4 + svW * sat, expandY + 4 + svH * (1 - val))
                    d.svCursorBorder.Position = d.svCursor.Position
                    d.hueCursor.Position = Vector2.new(cx + 4 + (pickerW - 8) * hue - 2, hueY - 2)
                    d.hueCursorBorder.Position = d.hueCursor.Position
                    saveConfiguration()
                    if callback then task.spawn(callback, c) end
                end

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isMouseOver(cx + sw - 28, localCY, 24, 16) then
                            isOpen = not isOpen
                            local a = isOpen and 1 or 0
                            d.pickerBg.Transparency = a * 0.78
                            d.pickerBorder.Transparency = a
                            d.satValBg.Transparency = a
                            d.satValWhite.Transparency = a * 0.5
                            d.satValBlack.Transparency = a * 0.5
                            d.svCursor.Transparency = a
                            d.svCursorBorder.Transparency = a
                            d.hueBar.Transparency = a
                            d.hueBorder.Transparency = a
                            d.hueCursor.Transparency = a
                            d.hueCursorBorder.Transparency = a
                            d.previewBorder.Color = isOpen and colors.accentColor or colors.borderColor
                        elseif isOpen then
                            local mx = input.Position.X
                            local my = input.Position.Y
                            if isMouseOver(cx + 4, expandY + 4, svW, svH) then
                                isSlidingSV = true
                                sat = math.clamp((mx - (cx + 4)) / svW, 0, 1)
                                val = 1 - math.clamp((my - (expandY + 4)) / svH, 0, 1)
                                updateColor()
                            elseif isMouseOver(cx + 4, hueY, pickerW - 8, hueBarH) then
                                isSlidingHue = true
                                hue = math.clamp((mx - (cx + 4)) / (pickerW - 8), 0, 1)
                                updateColor()
                            end
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        isSlidingSV = false
                        isSlidingHue = false
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        local mx = input.Position.X
                        local my = input.Position.Y
                        if isSlidingSV then
                            sat = math.clamp((mx - (cx + 4)) / svW, 0, 1)
                            val = 1 - math.clamp((my - (expandY + 4)) / svH, 0, 1)
                            updateColor()
                        elseif isSlidingHue then
                            hue = math.clamp((mx - (cx + 4)) / (pickerW - 8), 0, 1)
                            updateColor()
                        end
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + sw - 28, localCY, 24, 16) then
                        showTooltip(tooltip)
                        if not isOpen then d.previewBorder.Color = colors.borderLightColor end
                    else
                        if not isOpen then d.previewBorder.Color = colors.borderColor end
                    end
                end)
            end

            function elements:Button_Create(name, tooltip, callback)
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 28
                local sw = columnWidth - 4

                local d = {}
                d.bg = drawRect(cx + 2, cy, sw - 4, h, colors.elementBackground, 0.78, 10, true)
                d.border = drawRect(cx + 2, cy, sw - 4, h, colors.borderColor, 1, 10, false, 1)
                d.text = drawText(name, cx + 2 + (sw - 4) / 2, cy + 8, 12, colors.textWhiteColor, 1, 11)
                d.text.Center = true

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 6)

                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)
                local isDown = false

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isMouseOver(cx + 2, localCY, sw - 4, h) then
                            isDown = true
                            d.bg.Size = Vector2.new((sw - 4) * 0.96, h * 0.85)
                            d.bg.Position = Vector2.new(cx + 2 + (sw - 4) * 0.02, localCY + h * 0.075)
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isDown then
                        isDown = false
                        d.bg.Size = Vector2.new(sw - 4, h)
                        d.bg.Position = Vector2.new(cx + 2, localCY)
                        if isMouseOver(cx + 2, localCY, sw - 4, h) and callback then
                            task.spawn(callback)
                        end
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + 2, localCY, sw - 4, h) then
                        showTooltip(tooltip)
                        d.bg.Color = colors.elementHoverBackground
                        d.border.Color = colors.accentColor
                        d.text.Color = colors.accentColor
                    else
                        d.bg.Color = colors.elementBackground
                        d.border.Color = colors.borderColor
                        d.text.Color = colors.textWhiteColor
                    end
                end)
            end

            function elements:SubButton_Create(name, tooltip, callback)
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 20
                local sw = columnWidth - 20

                local d = {}
                d.bg = drawRect(cx + 8, cy, sw, h, colors.sectionBackground, 0.78, 10, true)
                d.border = drawRect(cx + 8, cy, sw, h, colors.borderColor, 1, 10, false, 1)
                d.text = drawText(name, cx + 8 + sw / 2, cy + 4, 11, colors.textDarkColor, 1, 11)
                d.text.Center = true

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 4)

                local localCY = cy
                local isDown = false

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isMouseOver(cx + 8, localCY, sw, h) then
                            isDown = true
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and isDown then
                        isDown = false
                        if isMouseOver(cx + 8, localCY, sw, h) and callback then
                            task.spawn(callback)
                        end
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + 8, localCY, sw, h) then
                        showTooltip(tooltip)
                        d.bg.Color = colors.elementBackground
                        d.border.Color = colors.borderLightColor
                        d.text.Color = colors.textWhiteColor
                    else
                        d.bg.Color = colors.sectionBackground
                        d.border.Color = colors.borderColor
                        d.text.Color = colors.textDarkColor
                    end
                end)
            end

            function elements:Module_Create(name, flag, descriptionText, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or false)
                local s = side
                local cx = s == "Left" and columnLeftX or columnRightX
                local cy = nextY(s)
                local h = 44
                local sw = columnWidth - 4

                local d = {}
                d.bg = drawRect(cx + 2, cy, sw - 4, h, colors.elementBackground, 0.78, 10, true)
                d.border = drawRect(cx + 2, cy, sw - 4, h, LibraryApi.Flags[flag] and colors.accentColor or colors.borderColor, 1, 10, false, 1)
                d.checkbox = drawRect(cx + 14, cy + 14, 16, 16, LibraryApi.Flags[flag] and colors.accentColor or colors.sectionBackground, 0.78, 11, true)
                d.checkboxBorder = drawRect(cx + 14, cy + 14, 16, 16, colors.borderColor, 1, 11, false, 1)
                d.name = drawText(name, cx + 38, cy + 8, 13, LibraryApi.Flags[flag] and colors.textWhiteColor or colors.textDarkColor, 1, 11)
                d.desc = drawText(descriptionText or "", cx + 38, cy + 24, 11, colors.textDarkColor, 1, 11)
                d.arrow = drawText(LibraryApi.Flags[flag] and "^" or "v", cx + sw - 24, cy + 15, 11, LibraryApi.Flags[flag] and colors.accentColor or colors.textDarkColor, 1, 11)

                for _, v in pairs(d) do v.Visible = isVisible() end
                for _, v in pairs(d) do table.insert(elementGroup, v) end
                advanceCursor(s, h + 6)

                local localCY = cy
                registerPositionUpdater(function(dx, dy)
                    cx = cx + dx
                    localCY = localCY + dy
                end)

                local subElements = {}
                local subElementGroup = {}
                table.insert(tabData._elements, subElementGroup)

                local subInjector = elementInjector(s)

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if isMouseOver(cx + 2, localCY, sw - 4, h) then
                            LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                            local ns = LibraryApi.Flags[flag]
                            d.border.Color = ns and colors.accentColor or colors.borderColor
                            d.checkbox.Color = ns and colors.accentColor or colors.sectionBackground
                            d.name.Color = ns and colors.textWhiteColor or colors.textDarkColor
                            d.arrow.Text = ns and "^" or "v"
                            d.arrow.Color = ns and colors.accentColor or colors.textDarkColor
                            saveConfiguration()
                            if callback then task.spawn(callback, ns) end
                        end
                    end
                end)

                runService.RenderStepped:Connect(function()
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isMouseOver(cx + 2, localCY, sw - 4, h) then
                        showTooltip(tooltip)
                        if not LibraryApi.Flags[flag] then d.border.Color = colors.borderLightColor end
                    else
                        if not LibraryApi.Flags[flag] then d.border.Color = colors.borderColor end
                    end
                end)

                return subInjector
            end

            return elements
        end

        local sectionApi = {}

        function sectionApi:Section_Create(columnSide, sectionTitle)
            local cx = columnSide == "Left" and columnLeftX or columnRightX
            local cy = columnSide == "Left" and leftCursorY or rightCursorY
            local sw = columnWidth

            local titleH = 24
            local d = {}
            d.bg = drawRect(cx, cy, sw, titleH + 8, colors.sectionBackground, 0.78, 8, true)
            d.border = drawRect(cx, cy, sw, titleH + 8, colors.borderColor, 1, 8, false, 1)
            d.title = drawText(sectionTitle, cx + 10, cy + 6, 12, colors.textWhiteColor, 1, 9)
            d.separator = drawLine(cx + 10, cy + titleH, cx + sw - 10, cy + titleH, colors.borderColor, 1, 1, 9)

            for _, v in pairs(d) do v.Visible = isVisible() end
            for _, v in pairs(d) do table.insert(elementGroup, v) end

            if columnSide == "Left" then
                leftCursorY = leftCursorY + titleH + 12
            else
                rightCursorY = rightCursorY + titleH + 12
            end

            local sectionStartCY = columnSide == "Left" and leftCursorY or rightCursorY
            local sectionElements = elementInjector(columnSide)

            runService.RenderStepped:Connect(function()
                local endCY = columnSide == "Left" and leftCursorY or rightCursorY
                local totalH = titleH + 8 + math.max(0, endCY - sectionStartCY)
                d.bg.Size = Vector2.new(sw, totalH)
                d.border.Size = Vector2.new(sw, totalH)
            end)

            return sectionElements
        end

        return sectionApi
    end


    return windowContext
end

return LibraryApi
