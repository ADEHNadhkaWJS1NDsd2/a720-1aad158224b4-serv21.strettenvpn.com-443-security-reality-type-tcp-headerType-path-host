local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local playersService = game:GetService("Players")
local workspaceService = game:GetService("Workspace")

local LibraryApi = {
    Flags = {},
    FolderName = "Moonshade",
    ConfigName = "AutoSaveConfig.json"
}

local localPlayer = playersService.LocalPlayer
local mouse = localPlayer:GetMouse()

local colors = {
    mainBackground       = Color3.new(0.035294, 0.035294, 0.050980),
    sidebarBackground    = Color3.new(0.050980, 0.050980, 0.066666),
    sectionBackground    = Color3.new(0.066666, 0.066666, 0.082352),
    elementBackground    = Color3.new(0.090196, 0.090196, 0.105882),
    elementHover         = Color3.new(0.121568, 0.121568, 0.145098),
    borderColor          = Color3.new(0.105882, 0.105882, 0.133333),
    borderLight          = Color3.new(0.172549, 0.172549, 0.211764),
    accentColor          = Color3.new(0.423529, 0.576470, 0.988235),
    accentGrad1          = Color3.new(0.423529, 0.576470, 0.988235),
    accentGrad2          = Color3.new(0.619607, 0.462745, 0.988235),
    textWhite            = Color3.new(0.952941, 0.952941, 0.972549),
    textDark             = Color3.new(0.541176, 0.541176, 0.580392),
    tooltipBg            = Color3.new(0.043137, 0.043137, 0.058823),
    notifInfo            = Color3.new(0.247058, 0.635294, 0.980392),
    notifSuccess         = Color3.new(0.247058, 0.980392, 0.490196),
    notifWarning         = Color3.new(0.980392, 0.819607, 0.247058),
    notifError           = Color3.new(0.980392, 0.247058, 0.247058)
}

local screenW, screenH = 0, 0
local function updateScreen()
    local vp = workspaceService.CurrentCamera.ViewportSize
    screenW = vp.X
    screenH = vp.Y
end
updateScreen()
workspaceService.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScreen)

local drawObjects = {}
local function newDraw(drawType)
    local obj = Drawing.new(drawType)
    table.insert(drawObjects, obj)
    return obj
end

local function lerp(a, b, t) return a + (b - a) * t end
local function lerpColor(c1, c2, t)
    return Color3.new(
        lerp(c1.R, c2.R, t),
        lerp(c1.G, c2.G, t),
        lerp(c1.B, c2.B, t)
    )
end

local tweens = {}
local function animateProp(obj, props, duration)
    local id = tostring(obj) .. tostring(math.random())
    local startTime = tick()
    local startVals = {}
    for k, v in pairs(props) do
        if typeof(obj[k]) == "Color3" or typeof(v) == "Color3" then
            startVals[k] = obj[k]
        elseif typeof(obj[k]) == "Vector2" or typeof(v) == "Vector2" then
            startVals[k] = obj[k]
        elseif type(obj[k]) == "number" or type(v) == "number" then
            startVals[k] = obj[k] or 0
        end
    end
    tweens[id] = {obj = obj, props = props, startVals = startVals, startTime = startTime, duration = duration or 0.25}
    return id
end

runService.RenderStepped:Connect(function()
    local now = tick()
    for id, tw in pairs(tweens) do
        local elapsed = now - tw.startTime
        local t = math.min(elapsed / tw.duration, 1)
        local easedT = 1 - (1 - t)^3
        for k, targetVal in pairs(tw.props) do
            local startVal = tw.startVals[k]
            if typeof(targetVal) == "Color3" and typeof(startVal) == "Color3" then
                tw.obj[k] = lerpColor(startVal, targetVal, easedT)
            elseif typeof(targetVal) == "Vector2" and typeof(startVal) == "Vector2" then
                tw.obj[k] = Vector2.new(lerp(startVal.X, targetVal.X, easedT), lerp(startVal.Y, targetVal.Y, easedT))
            elseif type(targetVal) == "number" and type(startVal) == "number" then
                tw.obj[k] = lerp(startVal, targetVal, easedT)
            end
        end
        if t >= 1 then
            tweens[id] = nil
        end
    end
end)

local function snapValue(value, step)
    if not step then return value end
    return math.floor((value / step) + 0.5) * step
end

local function formatValue(value, step)
    if step and step < 1 then
        local dec = #tostring(step) - 2
        return string.format("%." .. dec .. "f", value)
    end
    return tostring(value)
end

local function saveConfiguration()
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(LibraryApi.FolderName) then makefolder(LibraryApi.FolderName) end
        local data = {}
        for k, v in pairs(LibraryApi.Flags) do
            if typeof(v) == "Color3" then
                data[k] = {Type = "Color3", R = v.R, G = v.G, B = v.B}
            elseif typeof(v) == "EnumItem" then
                data[k] = {Type = "KeyCode", Name = v.Name}
            elseif type(v) == "table" and v.Min and v.Max then
                data[k] = {Type = "Range", Min = v.Min, Max = v.Max}
            else
                data[k] = v
            end
        end
        writefile(LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName, httpService:JSONEncode(data))
    end)
end

local function loadConfiguration()
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local path = LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName
        if isfile(path) then
            local decoded = httpService:JSONDecode(readfile(path))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if type(v) == "table" then
                        if v.Type == "Color3" then
                            LibraryApi.Flags[k] = Color3.new(v.R, v.G, v.B)
                        elseif v.Type == "KeyCode" then
                            LibraryApi.Flags[k] = Enum.KeyCode[v.Name] or Enum.KeyCode.Unknown
                        elseif v.Type == "Range" then
                            LibraryApi.Flags[k] = {Min = v.Min, Max = v.Max}
                        end
                    else
                        LibraryApi.Flags[k] = v
                    end
                end
            end
        end
    end)
end

loadConfiguration()

local function drawRect(x, y, w, h, color, transparency, zindex, filled)
    local sq = newDraw("Square")
    sq.Position = Vector2.new(x, y)
    sq.Size = Vector2.new(w, h)
    sq.Color = color
    sq.Transparency = 1 - (transparency or 1)
    sq.ZIndex = zindex or 1
    sq.Filled = filled ~= false
    sq.Visible = true
    return sq
end

local function drawRectOutline(x, y, w, h, color, transparency, zindex, thickness)
    local sq = newDraw("Square")
    sq.Position = Vector2.new(x, y)
    sq.Size = Vector2.new(w, h)
    sq.Color = color
    sq.Transparency = 1 - (transparency or 1)
    sq.ZIndex = zindex or 1
    sq.Filled = false
    sq.Thickness = thickness or 1
    sq.Visible = true
    return sq
end

local function drawText(text, x, y, size, color, transparency, zindex, font, outline)
    local t = newDraw("Text")
    t.Text = text
    t.Position = Vector2.new(x, y)
    t.FontSize = size or 13
    t.Color = color
    t.Transparency = 1 - (transparency or 1)
    t.ZIndex = zindex or 1
    t.Font = font or Drawing.Fonts.System
    t.Outline = outline or false
    t.Visible = true
    return t
end

local function drawLine(x1, y1, x2, y2, color, transparency, zindex, thickness)
    local ln = newDraw("Line")
    ln.From = Vector2.new(x1, y1)
    ln.To = Vector2.new(x2, y2)
    ln.Color = color
    ln.Transparency = 1 - (transparency or 1)
    ln.ZIndex = zindex or 1
    ln.Thickness = thickness or 1
    ln.Visible = true
    return ln
end

local function isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

local function getMousePos()
    return mouse.X, mouse.Y
end

local tooltipObjs = {}
local tooltipText = ""
local tooltipVisible = false

local function initTooltip()
    local bg = newDraw("Square")
    bg.Filled = true
    bg.ZIndex = 200
    bg.Visible = false
    local border = newDraw("Square")
    border.Filled = false
    border.Thickness = 1
    border.ZIndex = 201
    border.Visible = false
    local label = newDraw("Text")
    label.ZIndex = 202
    label.Font = Drawing.Fonts.System
    label.FontSize = 12
    label.Visible = false
    tooltipObjs = {bg = bg, border = border, label = label}
end
initTooltip()

local function showTooltip(text)
    tooltipText = text or ""
end

runService.RenderStepped:Connect(function()
    if tooltipText ~= "" then
        local mx, my = getMousePos()
        local tw = #tooltipText * 7 + 16
        tooltipObjs.bg.Position = Vector2.new(mx + 15, my + 15)
        tooltipObjs.bg.Size = Vector2.new(tw, 22)
        tooltipObjs.bg.Color = colors.tooltipBg
        tooltipObjs.bg.Transparency = 0.85
        tooltipObjs.bg.Visible = true
        tooltipObjs.border.Position = Vector2.new(mx + 15, my + 15)
        tooltipObjs.border.Size = Vector2.new(tw, 22)
        tooltipObjs.border.Color = colors.borderLight
        tooltipObjs.border.Transparency = 1
        tooltipObjs.border.Visible = true
        tooltipObjs.label.Text = tooltipText
        tooltipObjs.label.Position = Vector2.new(mx + 23, my + 18)
        tooltipObjs.label.Color = colors.textWhite
        tooltipObjs.label.Transparency = 1
        tooltipObjs.label.Visible = true
    else
        tooltipObjs.bg.Visible = false
        tooltipObjs.border.Visible = false
        tooltipObjs.label.Visible = false
    end
end)

local notifList = {}

function LibraryApi:Notify(config)
    local title = config.Title or "Notification"
    local text = config.Text or ""
    local duration = config.Duration or 3
    local ntype = config.Type or "Info"
    local accent = colors["notif" .. ntype] or colors.accentColor

    local nx = screenW - 320
    local baseY = screenH - 80
    for _, n in ipairs(notifList) do
        baseY = baseY - n.height - 10
    end

    local nHeight = 62
    local notif = {}
    notif.height = nHeight

    local bg = newDraw("Square")
    bg.Filled = true
    bg.Color = colors.mainBackground
    bg.Transparency = 0.78
    bg.ZIndex = 150
    bg.Position = Vector2.new(nx, baseY)
    bg.Size = Vector2.new(300, nHeight)
    bg.Visible = true

    local border = newDraw("Square")
    border.Filled = false
    border.Color = colors.borderLight
    border.Transparency = 1
    border.ZIndex = 151
    border.Thickness = 1
    border.Position = Vector2.new(nx, baseY)
    border.Size = Vector2.new(300, nHeight)
    border.Visible = true

    local line = newDraw("Square")
    line.Filled = true
    line.Color = accent
    line.Transparency = 1
    line.ZIndex = 152
    line.Position = Vector2.new(nx + 6, baseY + 6)
    line.Size = Vector2.new(3, nHeight - 12)
    line.Visible = true

    local titleDraw = newDraw("Text")
    titleDraw.Text = title
    titleDraw.Color = colors.textWhite
    titleDraw.Transparency = 1
    titleDraw.FontSize = 14
    titleDraw.Font = Drawing.Fonts.SystemBold
    titleDraw.ZIndex = 153
    titleDraw.Position = Vector2.new(nx + 16, baseY + 10)
    titleDraw.Visible = true

    local textDraw = newDraw("Text")
    textDraw.Text = text
    textDraw.Color = colors.textDark
    textDraw.Transparency = 1
    textDraw.FontSize = 12
    textDraw.Font = Drawing.Fonts.System
    textDraw.ZIndex = 153
    textDraw.Position = Vector2.new(nx + 16, baseY + 30)
    textDraw.Visible = true

    notif.objs = {bg, border, line, titleDraw, textDraw}
    table.insert(notifList, notif)

    task.delay(duration, function()
        animateProp(bg, {Transparency = 0}, 0.4)
        animateProp(border, {Transparency = 0}, 0.4)
        animateProp(line, {Transparency = 0}, 0.4)
        animateProp(titleDraw, {Transparency = 0}, 0.4)
        animateProp(textDraw, {Transparency = 0}, 0.4)
        task.wait(0.45)
        for _, obj in ipairs(notif.objs) do
            obj:Remove()
        end
        for i, n in ipairs(notifList) do
            if n == notif then
                table.remove(notifList, i)
                break
            end
        end
    end)
end

function LibraryApi:CreateWindow(windowName)
    local WIN_W = 720
    local WIN_H = 480
    local TOPBAR_H = 36
    local SIDEBAR_W = 150
    local winX = math.floor(screenW / 2 - WIN_W / 2)
    local winY = math.floor(screenH / 2 - WIN_H / 2)

    local allWindowObjs = {}
    local function regObj(o) table.insert(allWindowObjs, o) return o end

    local function wDraw(drawType) return regObj(newDraw(drawType)) end
    local function wRect(x, y, w, h, color, trans, z)
        local o = wDraw("Square")
        o.Filled = true; o.Position = Vector2.new(x,y); o.Size = Vector2.new(w,h)
        o.Color = color; o.Transparency = 1-(trans or 1); o.ZIndex = z or 1; o.Visible = true
        return o
    end
    local function wRectBorder(x, y, w, h, color, trans, z, thick)
        local o = wDraw("Square")
        o.Filled = false; o.Position = Vector2.new(x,y); o.Size = Vector2.new(w,h)
        o.Color = color; o.Transparency = 1-(trans or 1); o.ZIndex = z or 1
        o.Thickness = thick or 1; o.Visible = true
        return o
    end
    local function wText(text, x, y, size, color, trans, z, font)
        local o = wDraw("Text")
        o.Text = text; o.Position = Vector2.new(x,y); o.FontSize = size or 13
        o.Color = color; o.Transparency = 1-(trans or 1); o.ZIndex = z or 1
        o.Font = font or Drawing.Fonts.System; o.Visible = true
        return o
    end
    local function wLine(x1, y1, x2, y2, color, trans, z, thick)
        local o = wDraw("Line")
        o.From = Vector2.new(x1,y1); o.To = Vector2.new(x2,y2)
        o.Color = color; o.Transparency = 1-(trans or 1); o.ZIndex = z or 1
        o.Thickness = thick or 1; o.Visible = true
        return o
    end

    local windowVisible = true
    local Z_BASE = 10
    local Z_TOP  = 15
    local Z_UI   = 20
    local Z_OVER = 50

    local mainBg    = wRect(winX, winY, WIN_W, WIN_H, colors.mainBackground, 0.82, Z_BASE)
    local mainBord  = wRectBorder(winX, winY, WIN_W, WIN_H, colors.borderColor, 1, Z_BASE+1)
    local topbarBg  = wRect(winX, winY, WIN_W, TOPBAR_H, colors.sidebarBackground, 0.82, Z_TOP)
    local topBordLn = wLine(winX, winY+TOPBAR_H, winX+WIN_W, winY+TOPBAR_H, colors.borderColor, 1, Z_TOP+1)
    local accentL1  = wLine(winX, winY, winX + math.floor(WIN_W/2), winY, colors.accentGrad1, 1, Z_TOP+2, 2)
    local accentL2  = wLine(winX + math.floor(WIN_W/2), winY, winX+WIN_W, winY, colors.accentGrad2, 1, Z_TOP+2, 2)
    local titleLbl  = wText(windowName, winX+15, winY+10, 14, colors.textWhite, 1, Z_TOP+3, Drawing.Fonts.SystemBold)
    local sidebarBg = wRect(winX, winY+TOPBAR_H, SIDEBAR_W, WIN_H-TOPBAR_H, colors.sidebarBackground, 0.82, Z_BASE+1)
    local sidebarBd = wLine(winX+SIDEBAR_W, winY+TOPBAR_H, winX+SIDEBAR_W, winY+WIN_H, colors.borderColor, 1, Z_BASE+2)

    local function setWindowVisible(v)
        windowVisible = v
        for _, obj in ipairs(allWindowObjs) do
            pcall(function() obj.Visible = v end)
        end
        if not v then
            tooltipObjs.bg.Visible = false
            tooltipObjs.border.Visible = false
            tooltipObjs.label.Visible = false
            tooltipText = ""
        end
    end

    local isDragging = false
    local dragOffX, dragOffY = 0, 0

    local function updateWindowPos()
        mainBg.Position    = Vector2.new(winX, winY)
        mainBord.Position  = Vector2.new(winX, winY)
        topbarBg.Position  = Vector2.new(winX, winY)
        topBordLn.From     = Vector2.new(winX, winY+TOPBAR_H)
        topBordLn.To       = Vector2.new(winX+WIN_W, winY+TOPBAR_H)
        accentL1.From      = Vector2.new(winX, winY)
        accentL1.To        = Vector2.new(winX + math.floor(WIN_W/2), winY)
        accentL2.From      = Vector2.new(winX + math.floor(WIN_W/2), winY)
        accentL2.To        = Vector2.new(winX+WIN_W, winY)
        titleLbl.Position  = Vector2.new(winX+15, winY+11)
        sidebarBg.Position = Vector2.new(winX, winY+TOPBAR_H)
        sidebarBd.From     = Vector2.new(winX+SIDEBAR_W, winY+TOPBAR_H)
        sidebarBd.To       = Vector2.new(winX+SIDEBAR_W, winY+WIN_H)
    end

    userInputService.InputBegan:Connect(function(input, gpe)
        if not windowVisible then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mx, my = getMousePos()
            if isPointInRect(mx, my, winX, winY, WIN_W, TOPBAR_H) then
                isDragging = true
                dragOffX = mx - winX
                dragOffY = my - winY
            end
        end
        if not gpe and input.KeyCode == Enum.KeyCode.Delete then
            setWindowVisible(not windowVisible)
        end
    end)

    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)

    runService.RenderStepped:Connect(function()
        if isDragging then
            local mx, my = getMousePos()
            winX = mx - dragOffX
            winY = my - dragOffY
            winX = math.clamp(winX, 0, screenW - WIN_W)
            winY = math.clamp(winY, 0, screenH - WIN_H)
            updateWindowPos()
            if windowContext and windowContext.Active_Tab then
                windowContext.Active_Tab:_repositionAll()
            end
        end
    end)

    local windowContext = { Tabs = {}, Active_Tab = nil }

    local tabButtonList = {}
    local TAB_BTN_H = 32
    local TAB_PADDING = 4
    local tabScrollOffset = 0
    local maxTabScroll = 0
    local TAB_AREA_Y = winY + TOPBAR_H + 5
    local TAB_AREA_H = WIN_H - TOPBAR_H - 10

    local function getTabBtnY(index)
        return winY + TOPBAR_H + 5 + (index - 1) * (TAB_BTN_H + TAB_PADDING) - tabScrollOffset
    end

    local function repositionTabButtons()
        local totalH = #tabButtonList * (TAB_BTN_H + TAB_PADDING)
        maxTabScroll = math.max(0, totalH - (WIN_H - TOPBAR_H - 10))
        for i, tb in ipairs(tabButtonList) do
            local ty = getTabBtnY(i)
            tb.bg.Position    = Vector2.new(winX + 5, ty)
            tb.ind.From       = Vector2.new(winX + 5, ty + math.floor(TAB_BTN_H/2) - 8)
            tb.ind.To         = Vector2.new(winX + 5, ty + math.floor(TAB_BTN_H/2) + 8)
            tb.label.Position = Vector2.new(winX + 16, ty + 9)
            local inBounds = ty >= winY + TOPBAR_H and ty + TAB_BTN_H <= winY + WIN_H
            tb.bg.Visible    = windowVisible and inBounds
            tb.ind.Visible   = windowVisible and inBounds and tb.active
            tb.label.Visible = windowVisible and inBounds
        end
    end

    userInputService.InputChanged:Connect(function(input)
        if not windowVisible then return end
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            local mx, my = getMousePos()
            if isPointInRect(mx, my, winX, winY + TOPBAR_H, SIDEBAR_W, WIN_H - TOPBAR_H) then
                tabScrollOffset = math.clamp(tabScrollOffset - input.Position.Z * 20, 0, maxTabScroll)
                repositionTabButtons()
            end
        end
    end)

    function windowContext:Tab_Create(tabName, _iconId)
        local tabIndex = #self.Tabs + 1
        local tabData = {}
        tabData.active = false
        tabData.elements = {}
        tabData.sections = {}

        local ty = getTabBtnY(tabIndex)

        local tbBg = wRect(winX+5, ty, SIDEBAR_W-10, TAB_BTN_H, colors.elementHover, 0, Z_UI)
        local tbInd = wLine(winX+5, ty + TAB_BTN_H/2 - 8, winX+5, ty + TAB_BTN_H/2 + 8, colors.accentColor, 0, Z_UI+1, 2)
        tbInd.Visible = false
        local tbLbl = wText(tabName, winX+16, ty+9, 12, colors.textDark, 1, Z_UI+1)

        local tbEntry = {bg = tbBg, ind = tbInd, label = tbLbl, active = false}
        table.insert(tabButtonList, tbEntry)

        local CONTENT_X = winX + SIDEBAR_W + 8
        local CONTENT_Y = winY + TOPBAR_H + 8
        local CONTENT_W = WIN_W - SIDEBAR_W - 16
        local CONTENT_H = WIN_H - TOPBAR_H - 16

        local COL_W = math.floor((CONTENT_W - 10) / 2)
        local LEFT_X = CONTENT_X
        local RIGHT_X = CONTENT_X + COL_W + 10

        local contentObjs = {}
        local function regContent(o)
            table.insert(contentObjs, o)
            return o
        end

        local leftColY = CONTENT_Y
        local rightColY = CONTENT_Y
        local scrollOffsetLeft = 0
        local scrollOffsetRight = 0
        local totalLeftH = 0
        local totalRightH = 0

        local contentClipTop    = wRect(winX + SIDEBAR_W, winY + TOPBAR_H, WIN_W - SIDEBAR_W, 0, colors.mainBackground, 0, Z_BASE)
        local contentClipBottom = wRect(winX + SIDEBAR_W, winY + WIN_H, WIN_W - SIDEBAR_W, 8, colors.mainBackground, 0, Z_BASE)
        regContent(contentClipTop)
        regContent(contentClipBottom)

        local function setContentVisible(v)
            for _, obj in ipairs(contentObjs) do
                pcall(function() obj.Visible = v end)
            end
        end

        function tabData:_repositionAll()
            CONTENT_X = winX + SIDEBAR_W + 8
            CONTENT_Y = winY + TOPBAR_H + 8
            LEFT_X    = CONTENT_X
            RIGHT_X   = CONTENT_X + COL_W + 10
            contentClipBottom.Position = Vector2.new(winX + SIDEBAR_W, winY + WIN_H)
            contentClipTop.Position    = Vector2.new(winX + SIDEBAR_W, winY + TOPBAR_H)
            for _, sec in ipairs(tabData.sections) do
                if sec._reposition then sec:_reposition() end
            end
        end

        function tabData:Activate()
            if windowContext.Active_Tab == tabData then return end
            if windowContext.Active_Tab then
                local prevIdx = nil
                for i, t in ipairs(windowContext.Tabs) do if t == windowContext.Active_Tab then prevIdx = i break end end
                if prevIdx then
                    local tb = tabButtonList[prevIdx]
                    animateProp(tb.bg, {Transparency = 0}, 0.25)
                    animateProp(tb.label, {Color = colors.textDark}, 0.25)
                    tb.ind.Visible = false
                    tb.active = false
                end
                windowContext.Active_Tab:_setVisible(false)
            end
            windowContext.Active_Tab = tabData
            local myIdx = nil
            for i, t in ipairs(windowContext.Tabs) do if t == tabData then myIdx = i break end end
            if myIdx then
                local tb = tabButtonList[myIdx]
                animateProp(tb.bg, {Transparency = 0.85}, 0.25)
                animateProp(tb.label, {Color = colors.textWhite}, 0.25)
                tb.ind.Visible = true
                tb.active = true
            end
            setContentVisible(true)
        end

        function tabData:_setVisible(v)
            setContentVisible(v)
        end

        userInputService.InputBegan:Connect(function(input)
            if not windowVisible then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mx, my = getMousePos()
                for i, tb in ipairs(tabButtonList) do
                    if tabButtonList[i] == tbEntry then
                        local ty2 = getTabBtnY(i)
                        if isPointInRect(mx, my, winX+5, ty2, SIDEBAR_W-10, TAB_BTN_H) then
                            windowContext.Tabs[i]:Activate()
                        end
                        break
                    end
                end
            end
        end)

        userInputService.InputChanged:Connect(function(input)
            if not windowVisible then return end
            if windowContext.Active_Tab ~= tabData then return end
            if input.UserInputType == Enum.UserInputType.MouseWheel then
                local mx, my = getMousePos()
                if isPointInRect(mx, my, winX + SIDEBAR_W, winY + TOPBAR_H, WIN_W - SIDEBAR_W, WIN_H - TOPBAR_H) then
                    local delta = -input.Position.Z * 18
                    if mx < winX + SIDEBAR_W + COL_W + 5 then
                        scrollOffsetLeft = math.max(0, scrollOffsetLeft + delta)
                    else
                        scrollOffsetRight = math.max(0, scrollOffsetRight + delta)
                    end
                    for _, sec in ipairs(tabData.sections) do
                        if sec._reposition then sec:_reposition() end
                    end
                end
            end
        end)

        table.insert(self.Tabs, tabData)
        setContentVisible(false)
        if #self.Tabs == 1 then tabData:Activate() end

        local function elementInjector(targetSec, getSectionBaseY, getSectionH, isLeft)
            local elemObjs = {}
            local elemHeights = {}
            local elemPositions = {}
            local totalElemH = 0

            local function regElem(o) table.insert(elemObjs, o) return o end
            local function getScrollOff() return isLeft and scrollOffsetLeft or scrollOffsetRight end

            local function elemBaseX() return isLeft and LEFT_X + 8 or RIGHT_X + 8 end
            local function elemWidth() return COL_W - 16 end

            local function getElemY(localY)
                local secY = getSectionBaseY()
                return secY + 32 + localY - getScrollOff()
            end

            local function isInBounds(ey, eh)
                local top = winY + TOPBAR_H
                local bot = winY + WIN_H
                return ey + eh > top and ey < bot
            end

            local function clipObj(obj, ey, eh)
                obj.Visible = windowVisible and isInBounds(ey, eh)
            end

            local function refreshAllElems()
                local accumY = 0
                for i, eList in ipairs(elemPositions) do
                    local ey = getElemY(accumY)
                    local eh = elemHeights[i]
                    for _, od in ipairs(eList) do
                        if od.obj and od.relY ~= nil then
                            local ney = ey + od.relY
                            if od.isLine then
                                od.obj.From = Vector2.new(od.fromX or od.obj.From.X, ney + (od.fromYOff or 0))
                                od.obj.To   = Vector2.new(od.toX   or od.obj.To.X,   ney + (od.toYOff   or 0))
                            else
                                od.obj.Position = Vector2.new(od.xPos or elemBaseX() + (od.xOff or 0), ney)
                            end
                            clipObj(od.obj, ey, eh)
                        end
                    end
                    accumY = accumY + eh + 8
                end
                if isLeft then
                    totalLeftH = accumY
                else
                    totalRightH = accumY
                end
            end

            local elements = {}
            elements._regElem = function(h, objDataList)
                table.insert(elemHeights, h)
                table.insert(elemPositions, objDataList)
                table.insert(elemObjs, objDataList)
                for _, od in ipairs(objDataList) do
                    if od.obj then regContent(od.obj) end
                end
                refreshAllElems()
            end
            elements._refresh = refreshAllElems

            function elements:Subtext_Create(text)
                local o = wText(text, elemBaseX(), getElemY(0), 11, colors.textDark, 1, Z_UI)
                local od = {obj = o, relY = 0, xPos = elemBaseX()}
                elements._regElem(14, {od})
            end

            function elements:Toggle_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or false)
                local bx = elemBaseX()
                local ew = elemWidth()
                local curY = getElemY(totalElemH)

                local cbBg   = wRect(bx+2, curY+1, 12, 12, LibraryApi.Flags[flag] and colors.accentColor or colors.elementBackground, 0.82, Z_UI)
                local cbBord = wRectBorder(bx+2, curY+1, 12, 12, LibraryApi.Flags[flag] and colors.accentColor or colors.borderColor, 1, Z_UI+1)
                local lbl    = wText(name, bx+20, curY+1, 12, LibraryApi.Flags[flag] and colors.textWhite or colors.textDark, 1, Z_UI+1)

                local odList = {
                    {obj = cbBg,   relY = 1,  xPos = bx+2},
                    {obj = cbBord, relY = 1,  xPos = bx+2},
                    {obj = lbl,    relY = 1,  xPos = bx+20},
                }
                elements._regElem(16, odList)

                local function doRefresh() refreshAllElems() end

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        local realY = cbBg.Position.Y - 1
                        if isPointInRect(mx, my, bx, realY - 2, ew, 18) then
                            LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                            local st = LibraryApi.Flags[flag]
                            animateProp(cbBg,   {Color = st and colors.accentColor or colors.elementBackground}, 0.2)
                            animateProp(cbBord, {Color = st and colors.accentColor or colors.borderColor}, 0.2)
                            animateProp(lbl,    {Color = st and colors.textWhite or colors.textDark}, 0.2)
                            saveConfiguration()
                            if callback then task.spawn(callback, st) end
                        end
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mx, my = getMousePos()
                        local realY = cbBg.Position.Y - 1
                        if isPointInRect(mx, my, bx, realY - 2, ew, 18) then
                            showTooltip(tooltip or "")
                            if not LibraryApi.Flags[flag] then
                                cbBord.Color = colors.borderLight
                            end
                        else
                            if tooltipText == (tooltip or "") then showTooltip("") end
                            if not LibraryApi.Flags[flag] then
                                cbBord.Color = colors.borderColor
                            end
                        end
                    end
                end)
            end

            function elements:Slider_Create(name, flag, minV, maxV, default, step, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or snapValue(default or minV, step)
                local bx = elemBaseX()
                local ew = elemWidth()
                local curY = getElemY(0)

                local nameLbl  = wText(name, bx+2, curY, 12, colors.textWhite, 1, Z_UI)
                local valLbl   = wText(formatValue(LibraryApi.Flags[flag], step), bx+ew-38, curY, 12, colors.textWhite, 1, Z_UI)
                local trackBg  = wRect(bx+2, curY+18, ew-4, 6, colors.elementBackground, 0.82, Z_UI)
                local trackBd  = wRectBorder(bx+2, curY+18, ew-4, 6, colors.borderColor, 1, Z_UI+1)
                local pct = (LibraryApi.Flags[flag] - minV) / (maxV - minV)
                local fillW = math.max(1, math.floor((ew-4)*pct))
                local fillBar  = wRect(bx+2, curY+18, fillW, 6, colors.accentColor, 1, Z_UI+1)
                local knobX    = bx+2 + math.floor((ew-4)*pct)
                local knob     = wRect(knobX-5, curY+14, 10, 10, colors.textWhite, 1, Z_UI+2)
                local knobBd   = wRectBorder(knobX-5, curY+14, 10, 10, colors.borderColor, 1, Z_UI+3)

                local odList = {
                    {obj = nameLbl,  relY = 0,   xPos = bx+2},
                    {obj = valLbl,   relY = 0,   xPos = bx+ew-38},
                    {obj = trackBg,  relY = 18,  xPos = bx+2},
                    {obj = trackBd,  relY = 18,  xPos = bx+2},
                    {obj = fillBar,  relY = 18,  xPos = bx+2},
                    {obj = knob,     relY = 14,  xPos = bx+2},
                    {obj = knobBd,   relY = 14,  xPos = bx+2},
                }
                elements._regElem(36, odList)

                local isSliding = false

                local function setVal(v)
                    local clamped = math.clamp(v, minV, maxV)
                    local snapped = snapValue(clamped, step)
                    if LibraryApi.Flags[flag] ~= snapped then
                        LibraryApi.Flags[flag] = snapped
                        local np = (snapped - minV) / (maxV - minV)
                        local trackY = trackBg.Position.Y
                        local trackX = trackBg.Position.X
                        local fw = math.max(1, math.floor((ew-4)*np))
                        fillBar.Size = Vector2.new(fw, 6)
                        knob.Position  = Vector2.new(trackX + math.floor((ew-4)*np) - 5, trackY - 4)
                        knobBd.Position = knob.Position
                        valLbl.Text = formatValue(snapped, step)
                        saveConfiguration()
                        if callback then task.spawn(callback, snapped) end
                    end
                end

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        local ty2 = trackBg.Position.Y
                        if isPointInRect(mx, my, trackBg.Position.X, ty2-4, ew-4, 14) then
                            isSliding = true
                            local np = math.clamp((mx - trackBg.Position.X) / (ew-4), 0, 1)
                            setVal(minV + (maxV - minV) * np)
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then isSliding = false end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if isSliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mx = getMousePos()
                        local np = math.clamp((mx - trackBg.Position.X) / (ew-4), 0, 1)
                        setVal(minV + (maxV - minV) * np)
                    end
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mx, my = getMousePos()
                        if isPointInRect(mx, my, trackBg.Position.X, trackBg.Position.Y-4, ew-4, 14) then
                            showTooltip(tooltip or "")
                            trackBd.Color = colors.borderLight
                        else
                            if tooltipText == (tooltip or "") then showTooltip("") end
                            trackBd.Color = colors.borderColor
                        end
                    end
                end)
            end

            function elements:RangeSlider_Create(name, flag, minV, maxV, defaultMin, defaultMax, step, tooltip, callback)
                if not LibraryApi.Flags[flag] then
                    LibraryApi.Flags[flag] = {Min = snapValue(defaultMin or minV, step), Max = snapValue(defaultMax or maxV, step)}
                end
                local bx = elemBaseX()
                local ew = elemWidth()

                local nameLbl = wText(name, bx+2, 0, 12, colors.textWhite, 1, Z_UI)
                local valLbl  = wText("", bx+ew-80, 0, 12, colors.textWhite, 1, Z_UI)
                local trackBg = wRect(bx+2, 0, ew-4, 6, colors.elementBackground, 0.82, Z_UI)
                local trackBd = wRectBorder(bx+2, 0, ew-4, 6, colors.borderColor, 1, Z_UI+1)
                local fillBar = wRect(bx+2, 0, 1, 6, colors.accentColor, 1, Z_UI+1)
                local minKnob = wRect(0, 0, 10, 10, colors.textWhite, 1, Z_UI+2)
                local minKnobBd = wRectBorder(0, 0, 10, 10, colors.borderColor, 1, Z_UI+3)
                local maxKnob = wRect(0, 0, 10, 10, colors.textWhite, 1, Z_UI+2)
                local maxKnobBd = wRectBorder(0, 0, 10, 10, colors.borderColor, 1, Z_UI+3)

                local odList = {
                    {obj = nameLbl,   relY = 0,  xPos = bx+2},
                    {obj = valLbl,    relY = 0,  xPos = bx+ew-80},
                    {obj = trackBg,   relY = 18, xPos = bx+2},
                    {obj = trackBd,   relY = 18, xPos = bx+2},
                    {obj = fillBar,   relY = 18, xPos = bx+2},
                    {obj = minKnob,   relY = 14, xPos = bx+2},
                    {obj = minKnobBd, relY = 14, xPos = bx+2},
                    {obj = maxKnob,   relY = 14, xPos = bx+2},
                    {obj = maxKnobBd, relY = 14, xPos = bx+2},
                }
                elements._regElem(36, odList)

                local function updateVisuals()
                    local fl = LibraryApi.Flags[flag]
                    local minP = (fl.Min - minV) / (maxV - minV)
                    local maxP = (fl.Max - minV) / (maxV - minV)
                    local tx = trackBg.Position.X
                    local ty2 = trackBg.Position.Y
                    local tw = ew - 4
                    fillBar.Position = Vector2.new(tx + math.floor(tw*minP), ty2)
                    fillBar.Size = Vector2.new(math.max(1, math.floor(tw*(maxP-minP))), 6)
                    local mkx = tx + math.floor(tw*minP) - 5
                    local mxkx = tx + math.floor(tw*maxP) - 5
                    minKnob.Position   = Vector2.new(mkx,  ty2-4)
                    minKnobBd.Position = Vector2.new(mkx,  ty2-4)
                    maxKnob.Position   = Vector2.new(mxkx, ty2-4)
                    maxKnobBd.Position = Vector2.new(mxkx, ty2-4)
                    valLbl.Text = formatValue(fl.Min, step) .. " - " .. formatValue(fl.Max, step)
                end
                updateVisuals()

                local slidingMin = false
                local slidingMax = false

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        local ty2 = trackBg.Position.Y
                        if isPointInRect(mx, my, trackBg.Position.X, ty2-4, ew-4, 14) then
                            local fl = LibraryApi.Flags[flag]
                            local minP = (fl.Min - minV) / (maxV - minV)
                            local maxP = (fl.Max - minV) / (maxV - minV)
                            local tx = trackBg.Position.X
                            local tw = ew-4
                            local minKX = tx + tw*minP
                            local maxKX = tx + tw*maxP
                            if math.abs(mx - minKX) <= math.abs(mx - maxKX) then
                                slidingMin = true
                            else
                                slidingMax = true
                            end
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        slidingMin = false; slidingMax = false
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if (slidingMin or slidingMax) and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mx = getMousePos()
                        local tx = trackBg.Position.X
                        local tw = ew-4
                        local p = math.clamp((mx - tx) / tw, 0, 1)
                        local v = snapValue(minV + (maxV - minV) * p, step)
                        local fl = LibraryApi.Flags[flag]
                        if slidingMin then
                            fl.Min = math.min(v, fl.Max)
                        else
                            fl.Max = math.max(v, fl.Min)
                        end
                        updateVisuals()
                        saveConfiguration()
                        if callback then task.spawn(callback, fl) end
                    end
                end)
            end

            function elements:Textbox_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or "")
                local bx = elemBaseX()
                local ew = elemWidth()

                local nameLbl = wText(name, bx+2, 0, 12, colors.textWhite, 1, Z_UI)
                local inputBg = wRect(bx+ew-112, 0, 110, 20, colors.elementBackground, 0.82, Z_UI)
                local inputBd = wRectBorder(bx+ew-112, 0, 110, 20, colors.borderColor, 1, Z_UI+1)
                local inputLbl = wText(LibraryApi.Flags[flag], bx+ew-108, 0, 12, colors.textDark, 1, Z_UI+2)

                local odList = {
                    {obj = nameLbl,  relY = 6,  xPos = bx+2},
                    {obj = inputBg,  relY = 0,  xPos = bx+ew-112},
                    {obj = inputBd,  relY = 0,  xPos = bx+ew-112},
                    {obj = inputLbl, relY = 4,  xPos = bx+ew-108},
                }
                elements._regElem(24, odList)

                local focused = false
                local inputBuffer = LibraryApi.Flags[flag]

                userInputService.InputBegan:Connect(function(input, gpe)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        local iy = inputBg.Position.Y
                        if isPointInRect(mx, my, inputBg.Position.X, iy, 110, 20) then
                            focused = true
                            animateProp(inputBd, {Color = colors.accentColor}, 0.2)
                            animateProp(inputLbl, {Color = colors.textWhite}, 0.2)
                            showTooltip(tooltip or "")
                        else
                            if focused then
                                focused = false
                                animateProp(inputBd, {Color = colors.borderColor}, 0.2)
                                animateProp(inputLbl, {Color = colors.textDark}, 0.2)
                                LibraryApi.Flags[flag] = inputBuffer
                                inputLbl.Text = inputBuffer
                                saveConfiguration()
                                if callback then task.spawn(callback, inputBuffer) end
                                showTooltip("")
                            end
                        end
                    end
                    if focused and not gpe then
                        if input.KeyCode == Enum.KeyCode.Backspace then
                            inputBuffer = inputBuffer:sub(1, -2)
                            inputLbl.Text = inputBuffer
                        elseif input.KeyCode == Enum.KeyCode.Return then
                            focused = false
                            animateProp(inputBd, {Color = colors.borderColor}, 0.2)
                            animateProp(inputLbl, {Color = colors.textDark}, 0.2)
                            LibraryApi.Flags[flag] = inputBuffer
                            saveConfiguration()
                            if callback then task.spawn(callback, inputBuffer) end
                            showTooltip("")
                        end
                    end
                end)

                userInputService.TextBoxFocused:Connect(function() end)
            end

            function elements:Keybind_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or Enum.KeyCode.Unknown)
                local bx = elemBaseX()
                local ew = elemWidth()
                local isListening = false

                local nameLbl = wText(name, bx+2, 0, 12, colors.textWhite, 1, Z_UI)
                local btnBg   = wRect(bx+ew-74, 0, 72, 20, colors.elementBackground, 0.82, Z_UI)
                local btnBd   = wRectBorder(bx+ew-74, 0, 72, 20, colors.borderColor, 1, Z_UI+1)
                local function getKeyText()
                    return LibraryApi.Flags[flag] == Enum.KeyCode.Unknown and "[ None ]" or ("[ " .. LibraryApi.Flags[flag].Name .. " ]")
                end
                local btnLbl  = wText(getKeyText(), bx+ew-70, 0, 11, colors.textDark, 1, Z_UI+2, Drawing.Fonts.SystemBold)

                local odList = {
                    {obj = nameLbl, relY = 5,  xPos = bx+2},
                    {obj = btnBg,   relY = 0,  xPos = bx+ew-74},
                    {obj = btnBd,   relY = 0,  xPos = bx+ew-74},
                    {obj = btnLbl,  relY = 4,  xPos = bx+ew-70},
                }
                elements._regElem(24, odList)

                userInputService.InputBegan:Connect(function(input, gpe)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        local by2 = btnBg.Position.Y
                        if isPointInRect(mx, my, btnBg.Position.X, by2, 72, 20) then
                            isListening = true
                            btnLbl.Text = "[ ... ]"
                            animateProp(btnBd, {Color = colors.accentColor}, 0.2)
                            animateProp(btnLbl, {Color = colors.textWhite}, 0.2)
                            showTooltip(tooltip or "")
                        end
                    end
                    if isListening and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = input.KeyCode
                        elseif input.KeyCode == Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = Enum.KeyCode.Unknown
                        end
                        isListening = false
                        btnLbl.Text = getKeyText()
                        animateProp(btnBd, {Color = colors.borderColor}, 0.2)
                        animateProp(btnLbl, {Color = colors.textDark}, 0.2)
                        saveConfiguration()
                        if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                        showTooltip("")
                    elseif not isListening and input.UserInputType == Enum.UserInputType.Keyboard then
                        if input.KeyCode == LibraryApi.Flags[flag] and input.KeyCode ~= Enum.KeyCode.Unknown then
                            if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                        end
                    end
                end)
            end

            function elements:Dropdown_Create(name, flag, options, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or options[1])
                local bx = elemBaseX()
                local ew = elemWidth()
                local isOpen = false
                local ITEM_H = 20
                local maxVisible = 5
                local dropScrollOff = 0

                local nameLbl   = wText(name, bx+2, 0, 12, colors.textWhite, 1, Z_UI)
                local mainBtnBg = wRect(bx+2, 0, ew-4, 22, colors.elementBackground, 0.82, Z_UI)
                local mainBtnBd = wRectBorder(bx+2, 0, ew-4, 22, colors.borderColor, 1, Z_UI+1)
                local selLbl    = wText(LibraryApi.Flags[flag], bx+8, 0, 12, colors.textDark, 1, Z_UI+2)
                local arrowL    = wLine(0, 0, 0, 0, colors.textDark, 1, Z_UI+2, 1)
                local arrowR    = wLine(0, 0, 0, 0, colors.textDark, 1, Z_UI+2, 1)

                local function updateArrow()
                    local ax = mainBtnBg.Position.X + ew - 18
                    local ay = mainBtnBg.Position.Y + 11
                    if isOpen then
                        arrowL.From = Vector2.new(ax, ay+3); arrowL.To = Vector2.new(ax+5, ay-2)
                        arrowR.From = Vector2.new(ax+5, ay-2); arrowR.To = Vector2.new(ax+10, ay+3)
                    else
                        arrowL.From = Vector2.new(ax, ay-2); arrowL.To = Vector2.new(ax+5, ay+3)
                        arrowR.From = Vector2.new(ax+5, ay+3); arrowR.To = Vector2.new(ax+10, ay-2)
                    end
                end

                local optionObjs = {}
                local function buildOptionObjs()
                    for _, od in ipairs(optionObjs) do
                        od.bg:Remove(); od.lbl:Remove()
                    end
                    optionObjs = {}
                    local dropY = mainBtnBg.Position.Y + 24
                    local visCount = math.min(#options, maxVisible)
                    for i, opt in ipairs(options) do
                        local relIdx = i - 1 - math.floor(dropScrollOff / ITEM_H)
                        if relIdx >= 0 and relIdx < visCount then
                            local oy = dropY + relIdx * ITEM_H
                            local obg = wRect(bx+2, oy, ew-4, ITEM_H, colors.elementHover, 0, Z_OVER)
                            local olbl = wText(opt, bx+8, oy+3, 12, LibraryApi.Flags[flag] == opt and colors.accentColor or colors.textDark, 1, Z_OVER+1)
                            obg.Visible = isOpen and windowVisible
                            olbl.Visible = isOpen and windowVisible
                            table.insert(optionObjs, {bg = obg, lbl = olbl, opt = opt, oy = oy})
                            regContent(obg); regContent(olbl)
                        end
                    end
                end

                local dropBg    = wRect(bx+2, 0, ew-4, 0, colors.elementBackground, 0.9, Z_OVER-1)
                local dropBd    = wRectBorder(bx+2, 0, ew-4, 0, colors.borderColor, 1, Z_OVER)
                dropBg.Visible = false
                dropBd.Visible = false

                local closedH = 14 + 4 + 22
                local odList = {
                    {obj = nameLbl,   relY = 0,  xPos = bx+2},
                    {obj = mainBtnBg, relY = 16, xPos = bx+2},
                    {obj = mainBtnBd, relY = 16, xPos = bx+2},
                    {obj = selLbl,    relY = 20, xPos = bx+8},
                    {obj = arrowL,    isLine = true, relY = 16, fromX = nil, fromYOff = 11, toX = nil, toYOff = 11},
                    {obj = arrowR,    isLine = true, relY = 16, fromX = nil, fromYOff = 11, toX = nil, toYOff = 11},
                    {obj = dropBg,    relY = 40, xPos = bx+2},
                    {obj = dropBd,    relY = 40, xPos = bx+2},
                }
                elements._regElem(closedH, odList)
                updateArrow()

                local function openDrop()
                    isOpen = true
                    animateProp(mainBtnBd, {Color = colors.accentColor}, 0.2)
                    local visCount = math.min(#options, maxVisible)
                    local dropH = visCount * ITEM_H + 2
                    dropBg.Position = Vector2.new(bx+2, mainBtnBg.Position.Y + 24)
                    dropBg.Size = Vector2.new(ew-4, dropH)
                    dropBg.Visible = true
                    dropBd.Position = Vector2.new(bx+2, mainBtnBg.Position.Y + 24)
                    dropBd.Size = Vector2.new(ew-4, dropH)
                    dropBd.Visible = true
                    buildOptionObjs()
                    updateArrow()
                end

                local function closeDrop()
                    isOpen = false
                    animateProp(mainBtnBd, {Color = colors.borderColor}, 0.2)
                    dropBg.Visible = false
                    dropBd.Visible = false
                    for _, od in ipairs(optionObjs) do
                        od.bg.Visible = false
                        od.lbl.Visible = false
                    end
                    updateArrow()
                end

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        local mby = mainBtnBg.Position.Y
                        if isPointInRect(mx, my, mainBtnBg.Position.X, mby, ew-4, 22) then
                            if isOpen then closeDrop() else openDrop() end
                            showTooltip(tooltip or "")
                            return
                        end
                        if isOpen then
                            local hit = false
                            for _, od in ipairs(optionObjs) do
                                if isPointInRect(mx, my, od.bg.Position.X, od.bg.Position.Y, ew-4, ITEM_H) then
                                    LibraryApi.Flags[flag] = od.opt
                                    selLbl.Text = od.opt
                                    closeDrop()
                                    saveConfiguration()
                                    if callback then task.spawn(callback, od.opt) end
                                    hit = true
                                    break
                                end
                            end
                            if not hit then closeDrop() end
                        end
                    end
                    if isOpen and input.UserInputType == Enum.UserInputType.MouseWheel then
                        local mx, my = getMousePos()
                        if isPointInRect(mx, my, dropBg.Position.X, dropBg.Position.Y, ew-4, dropBg.Size.Y) then
                            dropScrollOff = math.clamp(dropScrollOff - input.Position.Z * ITEM_H, 0, math.max(0, (#options - maxVisible) * ITEM_H))
                            buildOptionObjs()
                        end
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseMovement and isOpen then
                        local mx, my = getMousePos()
                        for _, od in ipairs(optionObjs) do
                            if isPointInRect(mx, my, od.bg.Position.X, od.bg.Position.Y, ew-4, ITEM_H) then
                                animateProp(od.bg, {Transparency = 0.82}, 0.15)
                                if LibraryApi.Flags[flag] ~= od.opt then
                                    animateProp(od.lbl, {Color = colors.textWhite}, 0.15)
                                end
                            else
                                animateProp(od.bg, {Transparency = 0}, 0.15)
                                if LibraryApi.Flags[flag] ~= od.opt then
                                    animateProp(od.lbl, {Color = colors.textDark}, 0.15)
                                end
                            end
                        end
                    end
                end)
            end

            function elements:ColorPicker_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or Color3.new(1,1,1))
                local bx = elemBaseX()
                local ew = elemWidth()
                local isOpen = false
                local hue, sat, val = LibraryApi.Flags[flag]:ToHSV()

                local nameLbl   = wText(name, bx+2, 0, 12, colors.textWhite, 1, Z_UI)
                local prevBg    = wRect(bx+ew-28, 0, 24, 14, LibraryApi.Flags[flag], 1, Z_UI+1)
                local prevBd    = wRectBorder(bx+ew-28, 0, 24, 14, colors.borderColor, 1, Z_UI+2)

                local PW = ew - 16
                local PH = 130
                local HH = 12
                local pickerBg = wRect(bx+2, 0, ew-4, PH+HH+28, colors.elementBackground, 0.9, Z_OVER-1)
                local pickerBd = wRectBorder(bx+2, 0, ew-4, PH+HH+28, colors.borderColor, 1, Z_OVER)
                pickerBg.Visible = false
                pickerBd.Visible = false

                local SV_X = bx+8
                local SV_Y = 0
                local svBg = wRect(SV_X, SV_Y, PW, PH, Color3.fromHSV(hue,1,1), 1, Z_OVER)
                local svWhite = wRect(SV_X, SV_Y, PW, PH, Color3.new(1,1,1), 0, Z_OVER+1)
                local svBlack = wRect(SV_X, SV_Y, PW, PH, Color3.new(0,0,0), 0, Z_OVER+2)
                local svBd = wRectBorder(SV_X, SV_Y, PW, PH, colors.borderColor, 1, Z_OVER+3)
                local svCursor = wRect(0, 0, 8, 8, Color3.new(1,1,1), 1, Z_OVER+4)
                local svCursorBd = wRectBorder(0, 0, 8, 8, Color3.new(0,0,0), 1, Z_OVER+5)

                local HUE_X = bx+8
                local HUE_Y = 0
                local hueBarBg = wRect(HUE_X, HUE_Y, PW, HH, Color3.new(1,1,1), 1, Z_OVER)
                local hueBd = wRectBorder(HUE_X, HUE_Y, PW, HH, colors.borderColor, 1, Z_OVER+1)

                local HUE_SEGS = 12
                local hueSegs = {}
                for i = 1, HUE_SEGS do
                    local seg = wRect(0, 0, 0, HH, Color3.fromHSV((i-1)/HUE_SEGS, 1, 1), 1, Z_OVER)
                    seg.Visible = false
                    regContent(seg)
                    table.insert(hueSegs, seg)
                end

                local hueCursor = wRect(0, 0, 4, HH+4, Color3.new(1,1,1), 1, Z_OVER+4)
                local hueCursorBd = wRectBorder(0, 0, 4, HH+4, Color3.new(0,0,0), 1, Z_OVER+5)

                svBg.Visible = false; svWhite.Visible = false; svBlack.Visible = false
                svBd.Visible = false; svCursor.Visible = false; svCursorBd.Visible = false
                hueBarBg.Visible = false; hueBd.Visible = false
                hueCursor.Visible = false; hueCursorBd.Visible = false

                regContent(svBg); regContent(svWhite); regContent(svBlack); regContent(svBd)
                regContent(svCursor); regContent(svCursorBd)
                regContent(hueBarBg); regContent(hueBd)
                regContent(hueCursor); regContent(hueCursorBd)
                regContent(pickerBg); regContent(pickerBd)

                local closedH = 22
                local openH = 22 + PH + 8 + HH + 16

                local odList = {
                    {obj = nameLbl, relY = 4,  xPos = bx+2},
                    {obj = prevBg,  relY = 4,  xPos = bx+ew-28},
                    {obj = prevBd,  relY = 4,  xPos = bx+ew-28},
                }
                elements._regElem(closedH, odList)

                local function updatePickerPositions()
                    local baseY = prevBg.Position.Y + 18
                    SV_Y = baseY + 8
                    HUE_Y = SV_Y + PH + 8

                    svBg.Position  = Vector2.new(SV_X, SV_Y)
                    svWhite.Position = Vector2.new(SV_X, SV_Y)
                    svBlack.Position = Vector2.new(SV_X, SV_Y)
                    svBd.Position  = Vector2.new(SV_X, SV_Y)

                    hueBarBg.Position = Vector2.new(HUE_X, HUE_Y)
                    hueBd.Position    = Vector2.new(HUE_X, HUE_Y)
                    for i, seg in ipairs(hueSegs) do
                        local sw = math.ceil(PW / HUE_SEGS)
                        seg.Position = Vector2.new(HUE_X + (i-1)*sw, HUE_Y)
                        seg.Size = Vector2.new(sw, HH)
                    end

                    pickerBg.Position = Vector2.new(bx+2, baseY + 4)
                    pickerBd.Position = Vector2.new(bx+2, baseY + 4)
                    pickerBg.Size = Vector2.new(ew-4, PH + HH + 28)
                    pickerBd.Size = Vector2.new(ew-4, PH + HH + 28)

                    local cx = SV_X + math.floor(sat * PW) - 4
                    local cy = SV_Y + math.floor((1-val) * PH) - 4
                    svCursor.Position   = Vector2.new(cx, cy)
                    svCursorBd.Position = Vector2.new(cx, cy)

                    local hx = HUE_X + math.floor(hue * PW) - 2
                    hueCursor.Position   = Vector2.new(hx, HUE_Y - 2)
                    hueCursorBd.Position = Vector2.new(hx, HUE_Y - 2)
                end

                local function updateColor()
                    local c = Color3.fromHSV(hue, sat, val)
                    LibraryApi.Flags[flag] = c
                    prevBg.Color = c
                    svBg.Color = Color3.fromHSV(hue, 1, 1)

                    local svW_start = Vector2.new(1,1,1)
                    local svB_start = Vector2.new(0,0,0)
                    svWhite.Transparency = 0
                    svBlack.Transparency = 1 - val

                    local cx = SV_X + math.floor(sat * PW) - 4
                    local cy = SV_Y + math.floor((1-val) * PH) - 4
                    svCursor.Position   = Vector2.new(cx, cy)
                    svCursorBd.Position = Vector2.new(cx, cy)

                    local hx = HUE_X + math.floor(hue * PW) - 2
                    hueCursor.Position   = Vector2.new(hx, HUE_Y - 2)
                    hueCursorBd.Position = Vector2.new(hx, HUE_Y - 2)

                    saveConfiguration()
                    if callback then task.spawn(callback, c) end
                end

                local function openPicker()
                    isOpen = true
                    updatePickerPositions()
                    pickerBg.Visible = true; pickerBd.Visible = true
                    svBg.Visible = true; svWhite.Visible = true; svBlack.Visible = true
                    svBd.Visible = true; svCursor.Visible = true; svCursorBd.Visible = true
                    hueBarBg.Visible = true; hueBd.Visible = true
                    for _, seg in ipairs(hueSegs) do seg.Visible = true end
                    hueCursor.Visible = true; hueCursorBd.Visible = true
                    animateProp(prevBd, {Color = colors.accentColor}, 0.2)
                end

                local function closePicker()
                    isOpen = false
                    pickerBg.Visible = false; pickerBd.Visible = false
                    svBg.Visible = false; svWhite.Visible = false; svBlack.Visible = false
                    svBd.Visible = false; svCursor.Visible = false; svCursorBd.Visible = false
                    hueBarBg.Visible = false; hueBd.Visible = false
                    for _, seg in ipairs(hueSegs) do seg.Visible = false end
                    hueCursor.Visible = false; hueCursorBd.Visible = false
                    animateProp(prevBd, {Color = colors.borderColor}, 0.2)
                end

                local slidingSV = false
                local slidingHue = false

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        local pby = prevBg.Position.Y
                        if isPointInRect(mx, my, prevBg.Position.X, pby, 24, 14) then
                            if isOpen then closePicker() else openPicker() end
                            showTooltip(tooltip or "")
                            return
                        end
                        if isOpen then
                            if isPointInRect(mx, my, SV_X, SV_Y, PW, PH) then
                                slidingSV = true
                                sat = math.clamp((mx - SV_X) / PW, 0, 1)
                                val = 1 - math.clamp((my - SV_Y) / PH, 0, 1)
                                updateColor()
                            elseif isPointInRect(mx, my, HUE_X, HUE_Y, PW, HH) then
                                slidingHue = true
                                hue = math.clamp((mx - HUE_X) / PW, 0, 1)
                                updateColor()
                            else
                                closePicker()
                                showTooltip("")
                            end
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        slidingSV = false; slidingHue = false
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local mx, my = getMousePos()
                        if slidingSV then
                            sat = math.clamp((mx - SV_X) / PW, 0, 1)
                            val = 1 - math.clamp((my - SV_Y) / PH, 0, 1)
                            updateColor()
                        elseif slidingHue then
                            hue = math.clamp((mx - HUE_X) / PW, 0, 1)
                            updateColor()
                        end
                    end
                end)
            end

            function elements:Button_Create(name, tooltip, callback)
                local bx = elemBaseX()
                local ew = elemWidth()

                local btnBg = wRect(bx+2, 0, ew-4, 26, colors.elementBackground, 0.82, Z_UI)
                local btnBd = wRectBorder(bx+2, 0, ew-4, 26, colors.borderColor, 1, Z_UI+1)
                local btnLbl = wText(name, bx+2+math.floor((ew-4)/2) - math.floor(#name*3.5), 0, 12, colors.textWhite, 1, Z_UI+2, Drawing.Fonts.SystemBold)

                local odList = {
                    {obj = btnBg,  relY = 0, xPos = bx+2},
                    {obj = btnBd,  relY = 0, xPos = bx+2},
                    {obj = btnLbl, relY = 7, xPos = bx+2+math.floor((ew-4)/2) - math.floor(#name*3.5)},
                }
                elements._regElem(30, odList)

                local pressing = false

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        if isPointInRect(mx, my, btnBg.Position.X, btnBg.Position.Y, ew-4, 26) then
                            pressing = true
                            animateProp(btnBg, {Color = colors.accentColor, Transparency = 0.6}, 0.15)
                            animateProp(btnBd, {Color = colors.accentColor}, 0.15)
                            animateProp(btnLbl, {Color = colors.textWhite}, 0.15)
                            showTooltip(tooltip or "")
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and pressing then
                        pressing = false
                        animateProp(btnBg, {Color = colors.elementBackground, Transparency = 0.82}, 0.15)
                        animateProp(btnBd, {Color = colors.borderColor}, 0.15)
                        local mx, my = getMousePos()
                        if isPointInRect(mx, my, btnBg.Position.X, btnBg.Position.Y, ew-4, 26) then
                            if callback then task.spawn(callback) end
                        end
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseMovement and not pressing then
                        local mx, my = getMousePos()
                        if isPointInRect(mx, my, btnBg.Position.X, btnBg.Position.Y, ew-4, 26) then
                            animateProp(btnBg, {Color = colors.elementHover}, 0.2)
                            animateProp(btnBd, {Color = colors.accentColor}, 0.2)
                            animateProp(btnLbl, {Color = colors.accentColor}, 0.2)
                            showTooltip(tooltip or "")
                        else
                            animateProp(btnBg, {Color = colors.elementBackground}, 0.2)
                            animateProp(btnBd, {Color = colors.borderColor}, 0.2)
                            animateProp(btnLbl, {Color = colors.textWhite}, 0.2)
                            if tooltipText == (tooltip or "") then showTooltip("") end
                        end
                    end
                end)
            end

            function elements:SubButton_Create(name, tooltip, callback)
                local bx = elemBaseX()
                local ew = elemWidth()

                local btnBg  = wRect(bx+8, 0, ew-16, 20, colors.sectionBackground, 0.82, Z_UI)
                local btnBd  = wRectBorder(bx+8, 0, ew-16, 20, colors.borderColor, 1, Z_UI+1)
                local btnLbl = wText(name, bx+8 + math.floor((ew-16)/2) - math.floor(#name*3), 0, 11, colors.textDark, 1, Z_UI+2)

                local odList = {
                    {obj = btnBg,  relY = 0, xPos = bx+8},
                    {obj = btnBd,  relY = 0, xPos = bx+8},
                    {obj = btnLbl, relY = 4, xPos = bx+8+math.floor((ew-16)/2)-math.floor(#name*3)},
                }
                elements._regElem(22, odList)

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        if isPointInRect(mx, my, btnBg.Position.X, btnBg.Position.Y, ew-16, 20) then
                            animateProp(btnBg, {Color = colors.elementBackground}, 0.15)
                            animateProp(btnBd, {Color = colors.borderLight}, 0.15)
                            animateProp(btnLbl, {Color = colors.textWhite}, 0.15)
                            showTooltip(tooltip or "")
                            task.wait(0.1)
                            animateProp(btnBg, {Color = colors.sectionBackground}, 0.15)
                            animateProp(btnBd, {Color = colors.borderColor}, 0.15)
                            animateProp(btnLbl, {Color = colors.textDark}, 0.15)
                            if callback then task.spawn(callback) end
                        end
                    end
                end)
            end

            function elements:Module_Create(name, flag, descriptionText, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or false)
                local bx = elemBaseX()
                local ew = elemWidth()

                local modBg    = wRect(bx+2, 0, ew-4, 44, colors.elementBackground, 0.82, Z_UI)
                local modBd    = wRectBorder(bx+2, 0, ew-4, 44, LibraryApi.Flags[flag] and colors.accentColor or colors.borderColor, 1, Z_UI+1)
                local cbBg     = wRect(bx+14, 0, 14, 14, LibraryApi.Flags[flag] and colors.accentColor or colors.sectionBackground, 0.82, Z_UI+2)
                local cbBd     = wRectBorder(bx+14, 0, 14, 14, colors.borderColor, 1, Z_UI+3)
                local modLbl   = wText(name, bx+36, 0, 13, LibraryApi.Flags[flag] and colors.textWhite or colors.textDark, 1, Z_UI+2, Drawing.Fonts.SystemBold)
                local descLbl  = wText(descriptionText, bx+36, 0, 11, colors.textDark, 1, Z_UI+2)
                local arrL     = wLine(0,0,0,0, LibraryApi.Flags[flag] and colors.accentColor or colors.textDark, 1, Z_UI+2, 1)
                local arrR     = wLine(0,0,0,0, LibraryApi.Flags[flag] and colors.accentColor or colors.textDark, 1, Z_UI+2, 1)

                local closedH = 46
                local odList = {
                    {obj = modBg,   relY = 0,  xPos = bx+2},
                    {obj = modBd,   relY = 0,  xPos = bx+2},
                    {obj = cbBg,    relY = 14, xPos = bx+14},
                    {obj = cbBd,    relY = 14, xPos = bx+14},
                    {obj = modLbl,  relY = 6,  xPos = bx+36},
                    {obj = descLbl, relY = 22, xPos = bx+36},
                    {obj = arrL,    isLine = true, relY = 14, fromYOff = 14, toYOff = 14},
                    {obj = arrR,    isLine = true, relY = 14, fromYOff = 14, toYOff = 14},
                }
                elements._regElem(closedH, odList)

                local function updateArrows(open)
                    local ax = modBg.Position.X + ew - 24
                    local ay = modBg.Position.Y + 22
                    if open then
                        arrL.From = Vector2.new(ax, ay+3);   arrL.To = Vector2.new(ax+5, ay-2)
                        arrR.From = Vector2.new(ax+5, ay-2); arrR.To = Vector2.new(ax+10, ay+3)
                    else
                        arrL.From = Vector2.new(ax, ay-2);   arrL.To = Vector2.new(ax+5, ay+3)
                        arrR.From = Vector2.new(ax+5, ay+3); arrR.To = Vector2.new(ax+10, ay-2)
                    end
                end
                updateArrows(LibraryApi.Flags[flag])

                local moduleContentInjector = nil
                local moduleContentH = 0
                local moduleContentObjs = {}

                local function getModuleBaseY() return modBg.Position.Y + 48 end
                local function getModuleH() return moduleContentH end

                local function getModuleIsLeft() return isLeft end
                moduleContentInjector = elementInjector({
                    _getBaseY = getModuleBaseY,
                    _isLeft = isLeft,
                }, getModuleBaseY, getModuleH, isLeft)

                userInputService.InputBegan:Connect(function(input)
                    if not windowVisible or windowContext.Active_Tab ~= tabData then return end
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mx, my = getMousePos()
                        if isPointInRect(mx, my, modBg.Position.X, modBg.Position.Y, ew-4, 44) then
                            LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                            local st = LibraryApi.Flags[flag]
                            animateProp(cbBg, {Color = st and colors.accentColor or colors.sectionBackground}, 0.2)
                            animateProp(modBd, {Color = st and colors.accentColor or colors.borderColor}, 0.2)
                            animateProp(modLbl, {Color = st and colors.textWhite or colors.textDark}, 0.2)
                            updateArrows(st)
                            saveConfiguration()
                            if callback then task.spawn(callback, st) end
                        end
                    end
                end)

                return moduleContentInjector
            end

            return elements
        end

        local sectionApi = {}

        function sectionApi:Section_Create(columnSide, sectionTitle)
            local isLeft = columnSide == "Left"
            local colX = isLeft and LEFT_X or RIGHT_X
            local colY = isLeft and leftColY or rightColY
            local colW = COL_W

            local SEC_H_BASE = 44
            local secFrame = {}
            secFrame.x = colX
            secFrame.y = colY
            secFrame.w = colW
            secFrame.h = SEC_H_BASE
            secFrame.contentH = 0

            local secBg   = wRect(colX, colY, colW, SEC_H_BASE, colors.sectionBackground, 0.82, Z_BASE+2)
            local secBd   = wRectBorder(colX, colY, colW, SEC_H_BASE, colors.borderColor, 1, Z_BASE+3)
            local titleLb = wText(sectionTitle, colX+10, colY+8, 12, colors.textWhite, 1, Z_UI, Drawing.Fonts.SystemBold)
            local sepLine = wLine(colX+10, colY+26, colX+colW-10, colY+26, colors.borderColor, 1, Z_UI)

            local sectionContentH = 0

            local function getSectionBaseY() return secBg.Position.Y end
            local function getSectionH() return sectionContentH end

            local injected = elementInjector(nil, getSectionBaseY, getSectionH, isLeft)

            local origRegElem = injected._regElem
            injected._regElem = function(h, odList)
                origRegElem(h, odList)
                sectionContentH = sectionContentH + h + 8
                local newSecH = SEC_H_BASE + sectionContentH
                secBg.Size = Vector2.new(colW, newSecH)
                secBd.Size = Vector2.new(colW, newSecH)
                if isLeft then
                    leftColY = secBg.Position.Y + newSecH + 10
                else
                    rightColY = secBg.Position.Y + newSecH + 10
                end
            end

            secFrame.secBg = secBg
            secFrame.secBd = secBd
            secFrame.titleLb = titleLb
            secFrame.sepLine = sepLine

            function secFrame:_reposition()
                secBg.Position   = Vector2.new(winX + (isLeft and SIDEBAR_W+8 or SIDEBAR_W+8+COL_W+10), secBg.Position.Y)
                secBd.Position   = secBg.Position
                titleLb.Position = Vector2.new(secBg.Position.X+10, secBg.Position.Y+8)
                sepLine.From     = Vector2.new(secBg.Position.X+10, secBg.Position.Y+26)
                sepLine.To       = Vector2.new(secBg.Position.X+colW-10, secBg.Position.Y+26)
                if injected._refresh then injected._refresh() end
            end

            table.insert(tabData.sections, secFrame)
            return injected
        end

        return sectionApi
    end

    return windowContext
end

return LibraryApi
