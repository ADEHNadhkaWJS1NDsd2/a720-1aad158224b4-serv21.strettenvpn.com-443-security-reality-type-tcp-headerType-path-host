local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local textService = game:GetService("TextService")
local httpService = game:GetService("HttpService")
local workspaceService = game:GetService("Workspace")

local LibraryApi = {
    Flags = {},
    FolderName = "Moonshade",
    ConfigName = "AutoSaveConfig.json"
}

local colors = {
    mainBackground = Color3.fromRGB(9, 9, 13),
    sidebarBackground = Color3.fromRGB(12, 12, 18),
    sectionBackground = Color3.fromRGB(17, 17, 24),
    elementBackground = Color3.fromRGB(23, 23, 31),
    elementHoverBackground = Color3.fromRGB(30, 30, 40),
    borderColor = Color3.fromRGB(28, 28, 38),
    borderLightColor = Color3.fromRGB(45, 45, 61),
    accentColor = Color3.fromRGB(108, 147, 252),
    accentGradientColor1 = Color3.fromRGB(108, 147, 252),
    accentGradientColor2 = Color3.fromRGB(158, 118, 252),
    textWhiteColor = Color3.fromRGB(243, 243, 248),
    textDarkColor = Color3.fromRGB(138, 138, 148),
    tooltipBackground = Color3.fromRGB(11, 11, 16),
    notificationInfoColor = Color3.fromRGB(63, 162, 250),
    notificationSuccessColor = Color3.fromRGB(63, 250, 125),
    notificationWarningColor = Color3.fromRGB(250, 209, 63),
    notificationErrorColor = Color3.fromRGB(250, 63, 63)
}

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
    notifications = {}
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

local function getTextSize(text, size)
    local bounds = textService:GetTextSize(text or "", size or 12, Enum.Font.GothamMedium, Vector2.new(1000, 1000))
    return bounds.X, bounds.Y
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

local function setVisible(drawings, state)
    for _, drawing in pairs(drawings) do
        if typeof(drawing) == "table" and drawing.__isGroup then
            setVisible(drawing, state)
        elseif type(drawing) == "userdata" or type(drawing) == "table" then
            if drawing.Visible ~= nil then
                drawing.Visible = state
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

local function snapValue(value, step)
    if not step or step <= 0 then
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
    if step and step < 1 then
        local decimals = tostring(step):match("%.(%d+)")
        if decimals then
            return string.format("%." .. tostring(#decimals) .. "f", value)
        end
    end
    if math.floor(value) == value then
        return tostring(math.floor(value))
    end
    return tostring(value)
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
tooltip.text = addToGroup(tooltip, newDrawing("Text", { Visible = false, Size = 12, Font = Drawing.Fonts.UI, Outline = false, Center = false, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 502, Text = "" }))

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
        duration = duration or 3,
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
        parentModule = section.ownerModule
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

local function createWindowDrawings(window)
    local g = createGroup()
    g.bg = addToGroup(g, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.mainBackground, ZIndex = 20, Visible = true }))
    g.border = addToGroup(g, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 21, Visible = true }))
    g.top = addToGroup(g, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.sidebarBackground, ZIndex = 22, Visible = true }))
    g.topLine = addToGroup(g, newDrawing("Line", { Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 23, Visible = true }))
    g.accent = addToGroup(g, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = colors.accentColor, ZIndex = 24, Visible = true }))
    g.title = addToGroup(g, newDrawing("Text", { Size = 13, Font = Drawing.Fonts.UI, Outline = false, Center = false, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 24, Visible = true, Text = window.title }))
    g.sidebar = addToGroup(g, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.sidebarBackground, ZIndex = 22, Visible = true }))
    g.sidebarLine = addToGroup(g, newDrawing("Line", { Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 23, Visible = true }))
    window.drawings = g
end

local function createTabDrawings(tab)
    local g = createGroup()
    g.button = addToGroup(g, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 30, Visible = true }))
    g.border = addToGroup(g, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 31, Visible = true }))
    g.indicator = addToGroup(g, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = colors.accentColor, ZIndex = 32, Visible = true }))
    g.text = addToGroup(g, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Outline = false, Center = false, Transparency = 1, Color = colors.textDarkColor, ZIndex = 32, Visible = true, Text = tab.title }))
    tab.drawings = g
end

local function createSectionDrawings(section)
    local g = createGroup()
    g.bg = addToGroup(g, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.sectionBackground, ZIndex = 40, Visible = true }))
    g.border = addToGroup(g, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 41, Visible = true }))
    g.title = addToGroup(g, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Outline = false, Center = false, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 42, Visible = true, Text = section.title }))
    g.sep = addToGroup(g, newDrawing("Line", { Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 42, Visible = true }))
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
            UI.openDropdown = nil
        end
        if UI.openColorPicker and UI.openColorPicker.window == window then
            UI.openColorPicker.open = false
            UI.openColorPicker = nil
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

local isElementVisibleInLayout

local function layoutWindow(window)
    window.topHeight = 36
    window.sidebarWidth = 150
    window.contentPadding = 10
    window.tabButtonHeight = 30
    window.tabButtonGap = 6
    window.sectionTitleHeight = 24
    window.contentX = window.x + window.sidebarWidth + 10
    window.contentY = window.y + window.topHeight + 10
    window.contentW = window.w - window.sidebarWidth - 20
    window.contentH = window.h - window.topHeight - 20
    window.columnGap = 12
    window.columnWidth = math.floor((window.contentW - window.columnGap) / 2)

    local d = window.drawings
    d.bg.Position = Vector2.new(window.x, window.y)
    d.bg.Size = Vector2.new(window.w, window.h)
    d.border.Position = d.bg.Position
    d.border.Size = d.bg.Size
    d.top.Position = Vector2.new(window.x, window.y)
    d.top.Size = Vector2.new(window.w, window.topHeight)
    d.topLine.From = Vector2.new(window.x, window.y + window.topHeight)
    d.topLine.To = Vector2.new(window.x + window.w, window.y + window.topHeight)
    d.accent.Position = Vector2.new(window.x, window.y)
    d.accent.Size = Vector2.new(window.w, 2)
    d.title.Position = Vector2.new(window.x + 14, window.y + 11)
    d.sidebar.Position = Vector2.new(window.x, window.y + window.topHeight)
    d.sidebar.Size = Vector2.new(window.sidebarWidth, window.h - window.topHeight)
    d.sidebarLine.From = Vector2.new(window.x + window.sidebarWidth, window.y + window.topHeight)
    d.sidebarLine.To = Vector2.new(window.x + window.sidebarWidth, window.y + window.h)

    for index, tab in ipairs(window.tabs) do
        tab.x = window.x + 6
        tab.y = window.y + window.topHeight + 8 + (index - 1) * (window.tabButtonHeight + window.tabButtonGap)
        tab.w = window.sidebarWidth - 12
        tab.h = window.tabButtonHeight
        local td = tab.drawings
        td.button.Position = Vector2.new(tab.x, tab.y)
        td.button.Size = Vector2.new(tab.w, tab.h)
        td.border.Position = td.button.Position
        td.border.Size = td.button.Size
        td.indicator.Position = Vector2.new(tab.x, tab.y + 8)
        td.indicator.Size = Vector2.new(2, tab == window.activeTab and 14 or 0)
        td.text.Position = Vector2.new(tab.x + 12, tab.y + 9)
    end

    if not window.activeTab then return end

    local leftY = window.contentY
    local rightY = window.contentY

    for _, section in ipairs(window.activeTab.sections) do
        local columnX = section.side == "Left" and window.contentX or (window.contentX + window.columnWidth + window.columnGap)
        local contentWidth = window.columnWidth
        local startY = section.side == "Left" and leftY or rightY
        local currentY = startY + 32
        section.x = columnX
        section.y = startY
        section.w = contentWidth
        section.contentX = columnX + 8
        section.contentY = startY + 30
        section.contentW = contentWidth - 16

        for _, element in ipairs(section.elements) do
            local visibleInLayout = isElementVisibleInLayout(element)
            element.layoutVisible = visibleInLayout
            element.x = section.contentX + (element.parentModule and 10 or 0)
            element.y = currentY
            element.w = section.contentW - (element.parentModule and 10 or 0)
            if visibleInLayout then
                if element.dynamicHeight then
                    element.height = element:dynamicHeight()
                end
                currentY = currentY + element.height + 6
            end
        end

        section.h = math.max(32, currentY - startY + 6)

        local sd = section.drawings
        sd.bg.Position = Vector2.new(section.x, section.y)
        sd.bg.Size = Vector2.new(section.w, section.h)
        sd.border.Position = sd.bg.Position
        sd.border.Size = sd.bg.Size
        sd.title.Position = Vector2.new(section.x + 10, section.y + 6)
        sd.sep.From = Vector2.new(section.x + 10, section.y + 24)
        sd.sep.To = Vector2.new(section.x + section.w - 10, section.y + 24)

        if section.side == "Left" then
            leftY = currentY + 6
        else
            rightY = currentY + 6
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

isElementVisibleInLayout = function(element)
    if element.visible == false then
        return false
    end
    local parentModule = element.parentModule
    while parentModule do
        if not LibraryApi.Flags[parentModule.flag] then
            return false
        end
        parentModule = parentModule.parentModule
    end
    return true
end


local function drawTab(tab)
    local active = tab.window.activeTab == tab
    local hovered = UI.hovered == tab
    tab.drawings.button.Color = active and colors.elementHoverBackground or (hovered and colors.elementHoverBackground or colors.elementBackground)
    tab.drawings.border.Color = active and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor)
    tab.drawings.text.Color = active and colors.textWhiteColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
end

local function hideGroup(group)
    for _, drawing in pairs(group) do
        if type(drawing) == "table" and drawing.__isGroup then
            hideGroup(drawing)
        elseif type(drawing) == "userdata" or type(drawing) == "table" then
            if drawing.Visible ~= nil then
                drawing.Visible = false
            end
        end
    end
end

local function setElementBaseVisible(element, visible)
    for _, drawing in pairs(element.drawings) do
        if type(drawing) == "table" and drawing.__isGroup then
            hideGroup(drawing)
        elseif type(drawing) == "userdata" or type(drawing) == "table" then
            if drawing.Visible ~= nil then
                drawing.Visible = visible
            end
        end
    end
end

local function renderElement(element)
    if not element.window.visible or element.window.activeTab ~= element.tab or not isElementVisibleInLayout(element) then
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
                if isElementVisibleInLayout(element) and element.hitTest and element:hitTest(UI.mousePos) then
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

local function setTooltipText(text)
    UI.tooltip = text
end

local function initialize()
    if UI.initialized then return end
    UI.initialized = true

    UI.connections.mouseMove = userInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            UI.mousePos = userInputService:GetMouseLocation()
        end
    end)

    UI.connections.inputBegan = userInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.Delete then
            for _, window in ipairs(UI.windows) do
                setWindowVisible(window, not window.visible)
            end
            return
        end

        if UI.bindingKey then
            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                LibraryApi.Flags[UI.bindingKey.flag] = Enum.KeyCode.Unknown
            elseif input.KeyCode ~= Enum.KeyCode.Unknown then
                LibraryApi.Flags[UI.bindingKey.flag] = input.KeyCode
            end
            if UI.bindingKey.callback then
                task.spawn(UI.bindingKey.callback, LibraryApi.Flags[UI.bindingKey.flag])
            end
            saveConfiguration()
            UI.bindingKey.waiting = false
            endKeybind()
            return
        end

        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            UI.mouseDown = true
            UI.mousePos = userInputService:GetMouseLocation()
            local topWindow = getTopWindowAtMouse()
            if topWindow then
                bringWindowToFront(topWindow)
                local hit = hitTestElement(topWindow)
                UI.hovered = hit
                if UI.openDropdown and UI.openDropdown.window == topWindow and UI.openDropdown.open and hit ~= UI.openDropdown then
                    if not pointInRect(UI.mousePos, UI.openDropdown.popupX, UI.openDropdown.popupY, UI.openDropdown.popupW, UI.openDropdown.popupH) then
                        UI.openDropdown.open = false
                        UI.openDropdown = nil
                    end
                end
                if UI.openColorPicker and UI.openColorPicker.window == topWindow and UI.openColorPicker.open and hit ~= UI.openColorPicker then
                    if not pointInRect(UI.mousePos, UI.openColorPicker.popupX, UI.openColorPicker.popupY, UI.openColorPicker.popupW, UI.openColorPicker.popupH) then
                        UI.openColorPicker.open = false
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
                else
                    focusTextbox(nil)
                end
            else
                focusTextbox(nil)
                if UI.openDropdown then UI.openDropdown.open = false UI.openDropdown = nil end
                if UI.openColorPicker then UI.openColorPicker.open = false UI.openColorPicker = nil end
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            UI.mousePos = userInputService:GetMouseLocation()
            local topWindow = getTopWindowAtMouse()
            if topWindow then
                bringWindowToFront(topWindow)
                local hit = hitTestElement(topWindow)
                if hit and hit.onMouse2Down then
                    hit:onMouse2Down(UI.mousePos)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.Backspace then
            if UI.focusedTextbox then
                local text = UI.focusedTextbox.value
                UI.focusedTextbox.value = text:sub(1, math.max(0, #text - 1))
                LibraryApi.Flags[UI.focusedTextbox.flag] = UI.focusedTextbox.value
                saveConfiguration()
                if UI.focusedTextbox.callback then
                    task.spawn(UI.focusedTextbox.callback, UI.focusedTextbox.value)
                end
            end
        elseif input.KeyCode == Enum.KeyCode.Return then
            if UI.focusedTextbox then
                UI.focusedTextbox.focused = false
                UI.focusedTextbox = nil
            end
        elseif UI.focusedTextbox and input.KeyCode == Enum.KeyCode.Space then
            UI.focusedTextbox.value = UI.focusedTextbox.value .. " "
            LibraryApi.Flags[UI.focusedTextbox.flag] = UI.focusedTextbox.value
            saveConfiguration()
            if UI.focusedTextbox.callback then
                task.spawn(UI.focusedTextbox.callback, UI.focusedTextbox.value)
            end
        elseif UI.focusedTextbox and input.UserInputType == Enum.UserInputType.Keyboard then
            local ok, keyString = pcall(function()
                return userInputService:GetStringForKeyCode(input.KeyCode)
            end)
            if ok and keyString and keyString ~= "" then
                local isShiftDown = userInputService:IsKeyDown(Enum.KeyCode.LeftShift) or userInputService:IsKeyDown(Enum.KeyCode.RightShift)
                if #keyString == 1 then
                    if isShiftDown then
                        keyString = string.upper(keyString)
                    else
                        keyString = string.lower(keyString)
                    end
                end
                UI.focusedTextbox.value = UI.focusedTextbox.value .. keyString
                LibraryApi.Flags[UI.focusedTextbox.flag] = UI.focusedTextbox.value
                saveConfiguration()
                if UI.focusedTextbox.callback then
                    task.spawn(UI.focusedTextbox.callback, UI.focusedTextbox.value)
                end
            end
        end
    end)

    UI.connections.inputEnded = userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
    end)

    UI.connections.render = runService.RenderStepped:Connect(function(dt)
        UI.mousePos = userInputService:GetMouseLocation()
        UI.blinkClock = UI.blinkClock + dt
        UI.tooltip = nil

        if UI.active and UI.active.type == "windowdrag" then
            local window = UI.active.window
            local viewport = workspaceService.CurrentCamera and workspaceService.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
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
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = Drawing.Fonts.UI, Outline = false, Center = false, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = element.text }))
        function element:hitTest() return false end
        function element:draw()
            self.label.Position = Vector2.new(self.x + 2, self.y + 2)
            self.label.Text = self.text
            self.label.Visible = true
        end
        return element
    end

    function api:Toggle_Create(name, flag, default, tooltipText, callback)
        local value = ensureFlag(flag, default or false)
        local element = createBaseElement(section, "toggle", 18)
        element.name = tostring(name or "Toggle")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.pressable = true
        element.box = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = value and colors.accentColor or colors.elementBackground, ZIndex = 60, Visible = false }))
        element.boxBorder = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = value and colors.accentColor or colors.borderColor, ZIndex = 61, Visible = false }))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Outline = false, Center = false, Transparency = 1, Color = value and colors.textWhiteColor or colors.textDarkColor, ZIndex = 62, Visible = false, Text = element.name }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x, self.y, self.w, self.height)
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
            self.box.Position = Vector2.new(self.x + 2, self.y + 2)
            self.box.Size = Vector2.new(13, 13)
            self.box.Color = state and colors.accentColor or colors.elementBackground
            self.boxBorder.Position = self.box.Position
            self.boxBorder.Size = self.box.Size
            self.boxBorder.Color = state and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor)
            self.label.Position = Vector2.new(self.x + 22, self.y + 3)
            self.label.Text = self.name
            self.label.Color = state and colors.textWhiteColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.box.Visible = true
            self.boxBorder.Visible = true
            self.label.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Slider_Create(name, flag, min, max, default, step, tooltipText, callback)
        local value = ensureFlag(flag, snapValue(default or min, step))
        local element = createBaseElement(section, "slider", 28)
        element.name = tostring(name or "Slider")
        element.flag = flag
        element.min = min
        element.max = max
        element.step = step
        element.tooltip = tooltipText
        element.callback = callback
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.valueText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = formatValue(value, step) }))
        element.track = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.trackBorder = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.fill = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = colors.accentColor, ZIndex = 62, Visible = false }))
        element.knob = addToGroup(element.drawings, newDrawing("Circle", { Filled = true, Thickness = 1, Transparency = 1, Radius = 5, Color = colors.textWhiteColor, ZIndex = 63, Visible = false }))
        element.knobBorder = addToGroup(element.drawings, newDrawing("Circle", { Filled = false, Thickness = 1, Transparency = 1, Radius = 5, Color = colors.borderColor, ZIndex = 64, Visible = false }))
        function element:setFromMouse(pos)
            local sx = self.x + 2
            local width = self.w - 8
            local alpha = clamp((pos.X - sx) / width, 0, 1)
            local newValue = snapValue(self.min + (self.max - self.min) * alpha, self.step)
            newValue = clamp(newValue, self.min, self.max)
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
            local valueNow = clamp(LibraryApi.Flags[self.flag], self.min, self.max)
            local trackW = self.w - 8
            local pct = (valueNow - self.min) / (self.max - self.min)
            local fillW = math.max(1, trackW * pct)
            local hovered = UI.hovered == self or (UI.active and UI.active.element == self)
            self.label.Position = Vector2.new(self.x + 2, self.y + 1)
            self.label.Text = self.name
            self.valueText.Text = formatValue(valueNow, self.step)
            self.valueText.Position = Vector2.new(self.x + self.w - getTextSize(self.valueText.Text, 12) - 2, self.y + 1)
            self.track.Position = Vector2.new(self.x + 2, self.y + 18)
            self.track.Size = Vector2.new(trackW, 6)
            self.trackBorder.Position = self.track.Position
            self.trackBorder.Size = self.track.Size
            self.trackBorder.Color = hovered and colors.borderLightColor or colors.borderColor
            self.fill.Position = self.track.Position
            self.fill.Size = Vector2.new(fillW, 6)
            self.knob.Position = Vector2.new(self.x + 2 + trackW * pct, self.y + 21)
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
        local value = ensureFlag(flag, { Min = snapValue(defaultMin or min, step), Max = snapValue(defaultMax or max, step) })
        value.Min = clamp(value.Min, min, max)
        value.Max = clamp(value.Max, min, max)
        if value.Min > value.Max then value.Min, value.Max = value.Max, value.Min end
        local element = createBaseElement(section, "rangeslider", 28)
        element.name = tostring(name or "Range")
        element.flag = flag
        element.min = min
        element.max = max
        element.step = step
        element.tooltip = tooltipText
        element.callback = callback
        element.dragging = nil
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.valueText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = "" }))
        element.track = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.trackBorder = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.fill = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = colors.accentColor, ZIndex = 62, Visible = false }))
        element.knobMin = addToGroup(element.drawings, newDrawing("Circle", { Filled = true, Thickness = 1, Transparency = 1, Radius = 5, Color = colors.textWhiteColor, ZIndex = 63, Visible = false }))
        element.knobMax = addToGroup(element.drawings, newDrawing("Circle", { Filled = true, Thickness = 1, Transparency = 1, Radius = 5, Color = colors.textWhiteColor, ZIndex = 63, Visible = false }))
        function element:valueToPct(v)
            return (v - self.min) / (self.max - self.min)
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
            self.valueText.Text = formatValue(range.Min, self.step) .. " - " .. formatValue(range.Max, self.step)
            self.valueText.Position = Vector2.new(self.x + self.w - getTextSize(self.valueText.Text, 12) - 2, self.y + 1)
            self.track.Position = Vector2.new(self.x + 2, self.y + 18)
            self.track.Size = Vector2.new(trackW, 6)
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
        local value = ensureFlag(flag, tostring(default or ""))
        local element = createBaseElement(section, "textbox", 28)
        element.name = tostring(name or "Textbox")
        element.flag = flag
        element.value = tostring(value)
        element.tooltip = tooltipText
        element.callback = callback
        element.focused = false
        element.cursorBlink = 0
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.box = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.border = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.text = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = element.value }))
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
            self.box.Position = Vector2.new(self.x + 2, self.y + 14)
            self.box.Size = Vector2.new(self.w - 4, 14)
            self.border.Position = self.box.Position
            self.border.Size = self.box.Size
            self.border.Color = self.focused and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor)
            self.text.Position = Vector2.new(self.x + 6, self.y + 15)
            self.text.Text = showText
            self.text.Color = (#self.value > 0 or self.focused) and colors.textWhiteColor or colors.textDarkColor
            self.label.Text = self.name
            self.label.Visible = true
            self.box.Visible = true
            self.border.Visible = true
            self.text.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Keybind_Create(name, flag, default, tooltipText, callback)
        local value = ensureFlag(flag, default or Enum.KeyCode.Unknown)
        local element = createBaseElement(section, "keybind", 18)
        element.name = tostring(name or "Keybind")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.waiting = false
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.bindText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textDarkColor, ZIndex = 60, Visible = false, Text = "" }))
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
            return key == Enum.KeyCode.Unknown and "[ None ]" or ("[ " .. key.Name .. " ]")
        end
        function element:draw()
            local hovered = UI.hovered == self
            self.label.Position = Vector2.new(self.x + 2, self.y + 2)
            self.bindText.Text = self:getText()
            self.bindText.Position = Vector2.new(self.x + self.w - getTextSize(self.bindText.Text, 12) - 2, self.y + 2)
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
        local opts = options or {}
        local fallback = default or opts[1] or ""
        local value = ensureFlag(flag, fallback)
        local element = createBaseElement(section, "dropdown", 28)
        element.name = tostring(name or "Dropdown")
        element.flag = flag
        element.options = opts
        element.tooltip = tooltipText
        element.callback = callback
        element.open = false
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.box = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.border = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.valueText = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = tostring(value) }))
        element.arrow = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = "v" }))
        element.popup = createGroup()
        element.popup.bg = addToGroup(element.popup, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.96, Color = colors.sectionBackground, ZIndex = 120, Visible = false }))
        element.popup.border = addToGroup(element.popup, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 121, Visible = false }))
        element.popupItems = {}
        for i = 1, math.max(1, #opts) do
            element.popupItems[i] = {
                bg = addToGroup(element.popup, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.sectionBackground, ZIndex = 122, Visible = false })),
                text = addToGroup(element.popup, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textDarkColor, ZIndex = 123, Visible = false, Text = tostring(opts[i] or "") }))
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
            local buttonRectY = self.y + 14
            if pointInRect(pos, self.x + 2, buttonRectY, self.w - 4, 14) then
                self.open = not self.open
                closeOpenDropdown(self.open and self or nil)
            elseif self.open and pointInRect(pos, self.popupX, self.popupY, self.popupW, self.popupH) then
                local itemH = 18
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
            return 28
        end
        function element:draw()
            local hovered = UI.hovered == self
            self.label.Position = Vector2.new(self.x + 2, self.y + 1)
            self.box.Position = Vector2.new(self.x + 2, self.y + 14)
            self.box.Size = Vector2.new(self.w - 4, 14)
            self.border.Position = self.box.Position
            self.border.Size = self.box.Size
            self.border.Color = self.open and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor)
            self.valueText.Text = tostring(LibraryApi.Flags[self.flag])
            self.valueText.Position = Vector2.new(self.x + 6, self.y + 15)
            self.valueText.Color = hovered and colors.textWhiteColor or colors.textDarkColor
            self.arrow.Text = self.open and "^" or "v"
            self.arrow.Position = Vector2.new(self.x + self.w - 14, self.y + 15)
            self.arrow.Color = self.open and colors.accentColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.label.Visible = true
            self.box.Visible = true
            self.border.Visible = true
            self.valueText.Visible = true
            self.arrow.Visible = true
            if hovered then setTooltipText(self.tooltip) end
            self.popupX = self.x + 2
            self.popupY = self.y + 30
            self.popupW = self.w - 4
            self.popupH = math.max(18, #self.options * 18)
            if self.open then
                self.popup.bg.Position = Vector2.new(self.popupX, self.popupY)
                self.popup.bg.Size = Vector2.new(self.popupW, self.popupH)
                self.popup.border.Position = self.popup.bg.Position
                self.popup.border.Size = self.popup.bg.Size
                self.popup.bg.Visible = true
                self.popup.border.Visible = true
                for index, option in ipairs(self.options) do
                    local item = self.popupItems[index]
                    local y = self.popupY + (index - 1) * 18
                    local hovering = pointInRect(UI.mousePos, self.popupX, y, self.popupW, 18)
                    item.bg.Position = Vector2.new(self.popupX, y)
                    item.bg.Size = Vector2.new(self.popupW, 18)
                    item.bg.Color = hovering and colors.elementHoverBackground or colors.sectionBackground
                    item.bg.Visible = true
                    item.text.Text = tostring(option)
                    item.text.Position = Vector2.new(self.popupX + 6, y + 3)
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
        local value = ensureFlag(flag, default or colors.accentColor)
        local h, s, v = value:ToHSV()
        local element = createBaseElement(section, "colorpicker", 28)
        element.name = tostring(name or "Color")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.h = h
        element.s = s
        element.v = v
        element.open = false
        element.dragMode = nil
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 60, Visible = false, Text = element.name }))
        element.preview = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = value, ZIndex = 60, Visible = false }))
        element.previewBorder = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.popup = createGroup()
        element.popup.bg = addToGroup(element.popup, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.96, Color = colors.sectionBackground, ZIndex = 130, Visible = false }))
        element.popup.border = addToGroup(element.popup, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 131, Visible = false }))
        element.popup.sv = addToGroup(element.popup, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = hsvToColor(element.h, 1, 1), ZIndex = 132, Visible = false }))
        element.popup.svBorder = addToGroup(element.popup, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderLightColor, ZIndex = 133, Visible = false }))
        element.popup.hue = addToGroup(element.popup, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 1, Color = colors.accentColor, ZIndex = 132, Visible = false }))
        element.popup.hueBorder = addToGroup(element.popup, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderLightColor, ZIndex = 133, Visible = false }))
        element.popup.cursor = addToGroup(element.popup, newDrawing("Circle", { Filled = false, Thickness = 1, Transparency = 1, Radius = 4, Color = colors.textWhiteColor, ZIndex = 134, Visible = false }))
        element.popup.hueCursor = addToGroup(element.popup, newDrawing("Line", { Thickness = 2, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 134, Visible = false }))
        function element:updateColor()
            local color = hsvToColor(self.h, self.s, self.v)
            LibraryApi.Flags[self.flag] = color
            saveConfiguration()
            if self.callback then task.spawn(self.callback, color) end
        end
        function element:hitTest(pos)
            if pointInRect(pos, self.x, self.y, self.w, self.height) then return true end
            if self.open and pointInRect(pos, self.popupX, self.popupY, self.popupW, self.popupH) then return true end
            return false
        end
        function element:onMouseDown(pos)
            local previewX = self.x + self.w - 24
            if pointInRect(pos, previewX, self.y + 2, 20, 20) then
                self.open = not self.open
                closeOpenColorPicker(self.open and self or nil)
                return
            end
            if self.open then
                if pointInRect(pos, self.svX, self.svY, self.svW, self.svH) then
                    self.dragMode = "sv"
                    UI.active = { type = "colorpicker", element = self, window = self.window }
                    self:onDrag(pos)
                elseif pointInRect(pos, self.hueX, self.hueY, self.hueW, self.hueH) then
                    self.dragMode = "hue"
                    UI.active = { type = "colorpicker", element = self, window = self.window }
                    self:onDrag(pos)
                else
                    self.open = false
                    if UI.openColorPicker == self then UI.openColorPicker = nil end
                end
            end
        end
        function element:onDrag(pos)
            if self.dragMode == "sv" then
                self.s = clamp((pos.X - self.svX) / self.svW, 0, 1)
                self.v = 1 - clamp((pos.Y - self.svY) / self.svH, 0, 1)
                self:updateColor()
            elseif self.dragMode == "hue" then
                self.h = clamp((pos.Y - self.hueY) / self.hueH, 0, 1)
                self:updateColor()
            end
        end
        function element:onMouseUp()
            self.dragMode = nil
        end
        function element:draw()
            local hovered = UI.hovered == self
            local color = LibraryApi.Flags[self.flag]
            self.label.Position = Vector2.new(self.x + 2, self.y + 3)
            self.preview.Position = Vector2.new(self.x + self.w - 24, self.y + 2)
            self.preview.Size = Vector2.new(20, 20)
            self.preview.Color = color
            self.previewBorder.Position = self.preview.Position
            self.previewBorder.Size = self.preview.Size
            self.previewBorder.Color = self.open and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor)
            self.label.Visible = true
            self.preview.Visible = true
            self.previewBorder.Visible = true
            if hovered then setTooltipText(self.tooltip) end
            self.popupX = self.x + self.w - 150
            self.popupY = self.y + 28
            self.popupW = 146
            self.popupH = 116
            self.svX = self.popupX + 8
            self.svY = self.popupY + 8
            self.svW = 96
            self.svH = 96
            self.hueX = self.popupX + 112
            self.hueY = self.popupY + 8
            self.hueW = 16
            self.hueH = 96
            if self.open then
                self.popup.bg.Position = Vector2.new(self.popupX, self.popupY)
                self.popup.bg.Size = Vector2.new(self.popupW, self.popupH)
                self.popup.border.Position = self.popup.bg.Position
                self.popup.border.Size = self.popup.bg.Size
                self.popup.sv.Position = Vector2.new(self.svX, self.svY)
                self.popup.sv.Size = Vector2.new(self.svW, self.svH)
                self.popup.sv.Color = hsvToColor(self.h, 1, 1)
                self.popup.svBorder.Position = self.popup.sv.Position
                self.popup.svBorder.Size = self.popup.sv.Size
                self.popup.hue.Position = Vector2.new(self.hueX, self.hueY)
                self.popup.hue.Size = Vector2.new(self.hueW, self.hueH)
                self.popup.hue.Color = hsvToColor(self.h, 1, 1)
                self.popup.hueBorder.Position = self.popup.hue.Position
                self.popup.hueBorder.Size = self.popup.hue.Size
                self.popup.cursor.Position = Vector2.new(self.svX + self.s * self.svW, self.svY + (1 - self.v) * self.svH)
                self.popup.hueCursor.From = Vector2.new(self.hueX, self.hueY + self.h * self.hueH)
                self.popup.hueCursor.To = Vector2.new(self.hueX + self.hueW, self.hueY + self.h * self.hueH)
                self.popup.bg.Visible = true
                self.popup.border.Visible = true
                self.popup.sv.Visible = true
                self.popup.svBorder.Visible = true
                self.popup.hue.Visible = true
                self.popup.hueBorder.Visible = true
                self.popup.cursor.Visible = true
                self.popup.hueCursor.Visible = true
            else
                hideGroup(self.popup)
            end
        end
        return element
    end

    function api:Button_Create(name, tooltipText, callback)
        local element = createBaseElement(section, "button", 28)
        element.name = tostring(name or "Button")
        element.tooltip = tooltipText
        element.callback = callback
        element.box = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.border = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 12, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textWhiteColor, ZIndex = 62, Visible = false, Text = element.name, Center = true }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x + 2, self.y, self.w - 4, self.height)
        end
        function element:onMouseDown()
            if self.callback then task.spawn(self.callback) end
        end
        function element:draw()
            local hovered = UI.hovered == self
            self.box.Position = Vector2.new(self.x + 2, self.y)
            self.box.Size = Vector2.new(self.w - 4, self.height)
            self.box.Color = hovered and colors.elementHoverBackground or colors.elementBackground
            self.border.Position = self.box.Position
            self.border.Size = self.box.Size
            self.border.Color = hovered and colors.accentColor or colors.borderColor
            self.label.Text = self.name
            self.label.Position = Vector2.new(self.x + self.w / 2, self.y + 8)
            self.label.Color = hovered and colors.accentColor or colors.textWhiteColor
            self.box.Visible = true
            self.border.Visible = true
            self.label.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:SubButton_Create(name, tooltipText, callback)
        local element = createBaseElement(section, "subbutton", 20)
        element.name = tostring(name or "SubButton")
        element.tooltip = tooltipText
        element.callback = callback
        element.box = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.sectionBackground, ZIndex = 60, Visible = false }))
        element.border = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 61, Visible = false }))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textDarkColor, ZIndex = 62, Visible = false, Text = element.name, Center = true }))
        function element:hitTest(pos)
            return pointInRect(pos, self.x + 8, self.y, self.w - 16, self.height)
        end
        function element:onMouseDown()
            if self.callback then task.spawn(self.callback) end
        end
        function element:draw()
            local hovered = UI.hovered == self
            self.box.Position = Vector2.new(self.x + 8, self.y)
            self.box.Size = Vector2.new(self.w - 16, self.height)
            self.box.Color = hovered and colors.elementBackground or colors.sectionBackground
            self.border.Position = self.box.Position
            self.border.Size = self.box.Size
            self.border.Color = hovered and colors.borderLightColor or colors.borderColor
            self.label.Text = self.name
            self.label.Position = Vector2.new(self.x + self.w / 2, self.y + 4)
            self.label.Color = hovered and colors.textWhiteColor or colors.textDarkColor
            self.box.Visible = true
            self.border.Visible = true
            self.label.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        return element
    end

    function api:Module_Create(name, flag, descriptionText, default, tooltipText, callback)
        local state = ensureFlag(flag, default or false)
        local element = createBaseElement(section, "module", 44)
        element.name = tostring(name or "Module")
        element.descriptionText = tostring(descriptionText or "")
        element.flag = flag
        element.tooltip = tooltipText
        element.callback = callback
        element.bg = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = colors.elementBackground, ZIndex = 60, Visible = false }))
        element.border = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = state and colors.accentColor or colors.borderColor, ZIndex = 61, Visible = false }))
        element.check = addToGroup(element.drawings, newDrawing("Square", { Filled = true, Thickness = 1, Transparency = 0.84, Color = state and colors.accentColor or colors.sectionBackground, ZIndex = 62, Visible = false }))
        element.checkBorder = addToGroup(element.drawings, newDrawing("Square", { Filled = false, Thickness = 1, Transparency = 1, Color = colors.borderColor, ZIndex = 63, Visible = false }))
        element.label = addToGroup(element.drawings, newDrawing("Text", { Size = 13, Font = Drawing.Fonts.UI, Transparency = 1, Color = state and colors.textWhiteColor or colors.textDarkColor, ZIndex = 64, Visible = false, Text = element.name }))
        element.desc = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = Drawing.Fonts.UI, Transparency = 1, Color = colors.textDarkColor, ZIndex = 64, Visible = false, Text = element.descriptionText }))
        element.arrow = addToGroup(element.drawings, newDrawing("Text", { Size = 11, Font = Drawing.Fonts.UI, Transparency = 1, Color = state and colors.accentColor or colors.textDarkColor, ZIndex = 64, Visible = false, Text = state and "^" or "v" }))
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
            self.bg.Position = Vector2.new(self.x + 2, self.y)
            self.bg.Size = Vector2.new(self.w - 4, self.height)
            self.border.Position = self.bg.Position
            self.border.Size = self.bg.Size
            self.border.Color = stateNow and colors.accentColor or (hovered and colors.borderLightColor or colors.borderColor)
            self.check.Position = Vector2.new(self.x + 14, self.y + 14)
            self.check.Size = Vector2.new(16, 16)
            self.check.Color = stateNow and colors.accentColor or colors.sectionBackground
            self.checkBorder.Position = self.check.Position
            self.checkBorder.Size = self.check.Size
            self.label.Position = Vector2.new(self.x + 38, self.y + 8)
            self.label.Text = self.name
            self.label.Color = stateNow and colors.textWhiteColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.desc.Position = Vector2.new(self.x + 38, self.y + 24)
            self.desc.Text = self.descriptionText
            self.desc.Color = hovered and colors.textWhiteColor or colors.textDarkColor
            self.arrow.Text = stateNow and "^" or "v"
            self.arrow.Position = Vector2.new(self.x + self.w - 22, self.y + 15)
            self.arrow.Color = stateNow and colors.accentColor or (hovered and colors.textWhiteColor or colors.textDarkColor)
            self.bg.Visible = true
            self.border.Visible = true
            self.check.Visible = true
            self.checkBorder.Visible = true
            self.label.Visible = true
            self.desc.Visible = true
            self.arrow.Visible = true
            if hovered then setTooltipText(self.tooltip) end
        end
        local subSectionApi = makeSectionApi({
            window = section.window,
            tab = section.tab,
            elements = section.elements,
            ownerModule = element
        })
        return subSectionApi
    end

    return api
end

function LibraryApi:CreateWindow(windowName)
    initialize()
    local viewport = workspaceService.CurrentCamera and workspaceService.CurrentCamera.ViewportSize or Vector2.new(1920, 1080)
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

    function api:Tab_Create(tabName)
        local tab = {
            title = tostring(tabName or "Tab"),
            sections = {},
            window = window
        }
        createTabDrawings(tab)
        table.insert(window.tabs, tab)
        if not window.activeTab then
            window.activeTab = tab
        end

        local tabApi = {}

        function tabApi:Section_Create(columnSide, sectionTitle)
            local section = {
                title = tostring(sectionTitle or "Section"),
                side = columnSide == "Right" and "Right" or "Left",
                elements = {},
                window = window,
                tab = tab
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
