local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Library = {Flags = {}, Windows = {}}

local theme = {
    accent = Color3.fromRGB(108,147,252),
    bg = Color3.fromRGB(10,12,18),
    bg2 = Color3.fromRGB(14,16,24),
    panel = Color3.fromRGB(18,21,31),
    panel2 = Color3.fromRGB(22,25,37),
    panel3 = Color3.fromRGB(28,31,46),
    border = Color3.fromRGB(38,44,63),
    border2 = Color3.fromRGB(58,67,94),
    text = Color3.fromRGB(235,238,247),
    text2 = Color3.fromRGB(170,176,194),
    text3 = Color3.fromRGB(120,126,145),
    success = Color3.fromRGB(100,214,141),
    warning = Color3.fromRGB(255,199,93),
    danger = Color3.fromRGB(255,112,112)
}

local function mousePos()
    return UserInputService:GetMouseLocation()
end

local function clamp(v, a, b)
    if v < a then return a end
    if v > b then return b end
    return v
end

local function round(v, step)
    if not step or step == 0 then return v end
    return math.floor(v / step + 0.5) * step
end

local function formatValue(v, step)
    if typeof(v) == "number" then
        if step and step < 1 then
            local decimals = 0
            local s = tostring(step)
            local d = s:match("%.(%d+)")
            if d then decimals = #d end
            return string.format("%." .. tostring(decimals) .. "f", v)
        end
        return tostring(math.floor(v + 0.5) == v and math.floor(v) or v)
    end
    return tostring(v)
end

local function pointInRect(x, y, w, h, p)
    return p.X >= x and p.X <= x + w and p.Y >= y and p.Y <= y + h
end

local function draw(class)
    return Drawing.new(class)
end

local function makeText(size, center)
    local t = draw("Text")
    t.Size = size
    t.Center = center or false
    t.Outline = false
    t.Font = 2
    t.Visible = false
    return t
end

local function makeSquare(filled)
    local s = draw("Square")
    s.Filled = filled
    s.Visible = false
    return s
end

local function makeLine()
    local l = draw("Line")
    l.Visible = false
    return l
end

local function makeCircle(filled)
    local c = draw("Circle")
    c.Filled = filled
    c.NumSides = 24
    c.Visible = false
    return c
end

local notifications = {}

function Library:Notify(opts)
    local n = {
        Title = opts and opts.Title or "Notification",
        Text = opts and opts.Text or "",
        Duration = opts and opts.Duration or 3,
        Type = opts and opts.Type or "Info",
        Start = tick(),
        Drawings = {
            bg = makeSquare(true),
            border = makeSquare(false),
            accent = makeSquare(true),
            title = makeText(13, false),
            text = makeText(12, false)
        }
    }
    table.insert(notifications, n)
    return n
end

local function keyToChar(keyCode, shift)
    local name = keyCode.Name
    if #name == 1 then
        if shift then return name end
        return string.lower(name)
    end
    if name == "Space" then return " " end
    if name == "Period" then return shift and ">" or "." end
    if name == "Comma" then return shift and "<" or "," end
    if name == "Minus" then return shift and "_" or "-" end
    if name == "Equals" then return shift and "+" or "=" end
    if name == "Semicolon" then return shift and ":" or ";" end
    if name == "Quote" then return shift and '"' or "'" end
    if name == "Slash" then return shift and "?" or "/" end
    if name == "BackSlash" then return shift and "|" or "\\" end
    if name == "LeftBracket" then return shift and "{" or "[" end
    if name == "RightBracket" then return shift and "}" or "]" end
    if name == "Zero" then return shift and ")" or "0" end
    if name == "One" then return shift and "!" or "1" end
    if name == "Two" then return shift and "@" or "2" end
    if name == "Three" then return shift and "#" or "3" end
    if name == "Four" then return shift and "$" or "4" end
    if name == "Five" then return shift and "%" or "5" end
    if name == "Six" then return shift and "^" or "6" end
    if name == "Seven" then return shift and "&" or "7" end
    if name == "Eight" then return shift and "*" or "8" end
    if name == "Nine" then return shift and "(" or "9" end
    return nil
end

local UIState = {
    DragWindow = nil,
    DragOffset = Vector2.new(),
    ActiveTextbox = nil,
    ActiveKeybind = nil,
    ActiveSlider = nil,
    ActiveRangeSlider = nil,
    OpenDropdown = nil,
    OpenColor = nil,
    MouseDown = false,
    Visible = true
}

local function createBaseSectionDrawings()
    return {
        bg = makeSquare(true),
        border = makeSquare(false),
        title = makeText(13, false),
        separator = makeLine()
    }
end

local function createWindowDrawings()
    return {
        bg = makeSquare(true),
        border = makeSquare(false),
        top = makeSquare(true),
        accent = makeSquare(true),
        sidebar = makeSquare(true),
        sidebarLine = makeLine(),
        title = makeText(13, false)
    }
end

local function setVisible(list, visible)
    for _, d in pairs(list) do
        if typeof(d) == "table" then
            setVisible(d, visible)
        elseif d and d.Visible ~= nil then
            d.Visible = visible
        end
    end
end

local function removeDrawings(list)
    for _, d in pairs(list) do
        if typeof(d) == "table" then
            removeDrawings(d)
        elseif d and d.Remove then
            d:Remove()
        end
    end
end

local Window = {}
Window.__index = Window
local Tab = {}
Tab.__index = Tab
local Section = {}
Section.__index = Section
local Module = {}
Module.__index = Module

local function makeTabDrawings()
    return {
        btn = makeSquare(true),
        hover = makeSquare(true),
        indicator = makeSquare(true),
        text = makeText(12, false)
    }
end

function Library:CreateWindow(title)
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local self = setmetatable({}, Window)
    self.Title = title or "Window"
    self.X = math.floor(vp.X * 0.5 - 360)
    self.Y = math.floor(vp.Y * 0.5 - 240)
    self.W = 720
    self.H = 480
    self.TopH = 36
    self.SidebarW = 150
    self.Visible = true
    self.Tabs = {}
    self.ActiveTab = nil
    self.Drawings = createWindowDrawings()
    table.insert(Library.Windows, self)
    return self
end

function Window:Tab_Create(name)
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.Name = name
    tab.Sections = {}
    tab.Drawings = makeTabDrawings()
    tab.Layout = {x = 0, y = 0, w = 0, h = 30}
    table.insert(self.Tabs, tab)
    if not self.ActiveTab then self.ActiveTab = tab end
    return tab
end

function Tab:Section_Create(side, title)
    local section = setmetatable({}, Section)
    section.Tab = self
    section.Side = side == "Right" and "Right" or "Left"
    section.Title = title or "Section"
    section.Items = {}
    section.Drawings = createBaseSectionDrawings()
    section.Layout = {x = 0, y = 0, w = 0, h = 38}
    table.insert(self.Sections, section)
    return section
end

function Section:_push(item)
    item.Section = self
    table.insert(self.Items, item)
    return item
end

function Section:Subtext_Create(text)
    return self:_push({Type = "Subtext", Text = text, Height = 18, Drawings = {text = makeText(11, false)}})
end

function Section:Toggle_Create(name, flag, default, tooltip, callback)
    if Library.Flags[flag] == nil then Library.Flags[flag] = default or false end
    return self:_push({Type = "Toggle", Name = name, Flag = flag, Tooltip = tooltip, Callback = callback, Height = 22, Drawings = {box = makeSquare(true), border = makeSquare(false), text = makeText(12, false)}, Hitbox = {}})
end

function Section:Slider_Create(name, flag, min, max, default, step, tooltip, callback)
    if Library.Flags[flag] == nil then Library.Flags[flag] = round(default or min, step or 1) end
    return self:_push({Type = "Slider", Name = name, Flag = flag, Min = min, Max = max, Step = step or 1, Tooltip = tooltip, Callback = callback, Height = 38, Drawings = {text = makeText(12, false), value = makeText(12, false), track = makeSquare(true), fill = makeSquare(true), border = makeSquare(false), knob = makeCircle(true), knobBorder = makeCircle(false)}, Hitbox = {}})
end

function Section:RangeSlider_Create(name, flag, min, max, defaultMin, defaultMax, step, tooltip, callback)
    if Library.Flags[flag] == nil then
        Library.Flags[flag] = {Min = round(defaultMin or min, step or 1), Max = round(defaultMax or max, step or 1)}
    end
    return self:_push({Type = "RangeSlider", Name = name, Flag = flag, Min = min, Max = max, Step = step or 1, Tooltip = tooltip, Callback = callback, Height = 38, Drawings = {text = makeText(12, false), value = makeText(12, false), track = makeSquare(true), fill = makeSquare(true), border = makeSquare(false), knobMin = makeCircle(true), knobMax = makeCircle(true), knobMinBorder = makeCircle(false), knobMaxBorder = makeCircle(false)}, Hitbox = {}})
end

function Section:Textbox_Create(name, flag, default, tooltip, callback)
    if Library.Flags[flag] == nil then Library.Flags[flag] = default or "" end
    return self:_push({Type = "Textbox", Name = name, Flag = flag, Tooltip = tooltip, Callback = callback, Height = 42, Drawings = {label = makeText(12, false), box = makeSquare(true), border = makeSquare(false), text = makeText(12, false)}, Hitbox = {}})
end

function Section:Keybind_Create(name, flag, default, tooltip, callback)
    if Library.Flags[flag] == nil then Library.Flags[flag] = default or Enum.KeyCode.Unknown end
    return self:_push({Type = "Keybind", Name = name, Flag = flag, Tooltip = tooltip, Callback = callback, Height = 30, Drawings = {label = makeText(12, false), box = makeSquare(true), border = makeSquare(false), text = makeText(12, true)}, Hitbox = {}})
end

function Section:Dropdown_Create(name, flag, values, default, tooltip, callback)
    if Library.Flags[flag] == nil then Library.Flags[flag] = default or (values and values[1]) or "" end
    return self:_push({Type = "Dropdown", Name = name, Flag = flag, Values = values or {}, Tooltip = tooltip, Callback = callback, Height = 42, Open = false, Drawings = {label = makeText(12, false), box = makeSquare(true), border = makeSquare(false), text = makeText(12, false), arrow = makeText(12, true)}, Hitbox = {}, OptionDrawings = {}})
end

function Section:ColorPicker_Create(name, flag, default, tooltip, callback)
    if Library.Flags[flag] == nil then Library.Flags[flag] = default or theme.accent end
    return self:_push({Type = "ColorPicker", Name = name, Flag = flag, Tooltip = tooltip, Callback = callback, Height = 30, Open = false, HSV = {H = 0, S = 0, V = 1}, Drawings = {label = makeText(12, false), preview = makeSquare(true), previewBorder = makeSquare(false), popup = makeSquare(true), popupBorder = makeSquare(false), hue = makeSquare(true), hueBorder = makeSquare(false), value = makeSquare(true), valueBorder = makeSquare(false)}, Hitbox = {}})
end

function Section:Button_Create(name, tooltip, callback)
    return self:_push({Type = "Button", Name = name, Tooltip = tooltip, Callback = callback, Height = 32, Drawings = {box = makeSquare(true), border = makeSquare(false), text = makeText(12, true)}, Hitbox = {}})
end

function Section:Module_Create(name, flag, tooltip, default, tooltip2, callback)
    if Library.Flags[flag] == nil then Library.Flags[flag] = default or false end
    local module = setmetatable({Type = "Module", Name = name, Flag = flag, Tooltip = tooltip2 or tooltip, Callback = callback, Open = false, Children = {}, Height = 30, Drawings = {box = makeSquare(true), border = makeSquare(false), toggle = makeSquare(true), toggleBorder = makeSquare(false), text = makeText(12, false), arrow = makeText(12, true)}, Hitbox = {}}, Module)
    return self:_push(module)
end

function Module:_push(item)
    item.Module = self
    table.insert(self.Children, item)
    return item
end

function Module:Subtext_Create(text)
    return self:_push({Type = "Subtext", Text = text, Height = 18, Drawings = {text = makeText(11, false)}})
end

function Module:SubButton_Create(name, tooltip, callback)
    return self:_push({Type = "SubButton", Name = name, Tooltip = tooltip, Callback = callback, Height = 28, Drawings = {box = makeSquare(true), border = makeSquare(false), text = makeText(12, true)}, Hitbox = {}})
end

local function getColorHSV(c)
    local h, s, v = Color3.toHSV(c)
    return {H = h, S = s, V = v}
end

local function getTabContentBounds(win)
    local x = win.X + win.SidebarW + 10
    local y = win.Y + win.TopH + 10
    local w = win.W - win.SidebarW - 20
    local h = win.H - win.TopH - 20
    return x, y, w, h
end

local function currentTab(win)
    return win.Visible and UIState.Visible and win.ActiveTab or nil
end

local function sectionHeight(section)
    local h = 36
    for _, item in ipairs(section.Items) do
        h = h + item.Height + 6
        if item.Type == "Module" and item.Open then
            for _, child in ipairs(item.Children) do
                h = h + child.Height + 4
            end
        end
    end
    return h + 4
end

local function updateWindowLayout(win)
    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    win.X = clamp(win.X, 0, math.max(0, vp.X - win.W))
    win.Y = clamp(win.Y, 0, math.max(0, vp.Y - win.H))

    local d = win.Drawings
    d.bg.Position = Vector2.new(win.X, win.Y)
    d.bg.Size = Vector2.new(win.W, win.H)
    d.bg.Color = theme.bg
    d.bg.Transparency = 0.18
    d.bg.Visible = win.Visible and UIState.Visible

    d.border.Position = Vector2.new(win.X, win.Y)
    d.border.Size = Vector2.new(win.W, win.H)
    d.border.Color = theme.border2
    d.border.Thickness = 1
    d.border.Visible = d.bg.Visible

    d.top.Position = Vector2.new(win.X, win.Y)
    d.top.Size = Vector2.new(win.W, win.TopH)
    d.top.Color = theme.bg2
    d.top.Transparency = 0.05
    d.top.Visible = d.bg.Visible

    d.accent.Position = Vector2.new(win.X, win.Y)
    d.accent.Size = Vector2.new(win.W, 2)
    d.accent.Color = theme.accent
    d.accent.Transparency = 0
    d.accent.Visible = d.bg.Visible

    d.sidebar.Position = Vector2.new(win.X, win.Y + win.TopH)
    d.sidebar.Size = Vector2.new(win.SidebarW, win.H - win.TopH)
    d.sidebar.Color = theme.bg2
    d.sidebar.Transparency = 0.1
    d.sidebar.Visible = d.bg.Visible

    d.sidebarLine.From = Vector2.new(win.X + win.SidebarW, win.Y + win.TopH)
    d.sidebarLine.To = Vector2.new(win.X + win.SidebarW, win.Y + win.H)
    d.sidebarLine.Color = theme.border
    d.sidebarLine.Thickness = 1
    d.sidebarLine.Visible = d.bg.Visible

    d.title.Text = win.Title
    d.title.Position = Vector2.new(win.X + 16, win.Y + 11)
    d.title.Color = theme.text2
    d.title.Visible = d.bg.Visible

    for i, tab in ipairs(win.Tabs) do
        local td = tab.Drawings
        local tx = win.X + 6
        local ty = win.Y + win.TopH + 8 + (i - 1) * 36
        tab.Layout.x, tab.Layout.y, tab.Layout.w, tab.Layout.h = tx, ty, win.SidebarW - 12, 30
        local active = win.ActiveTab == tab
        local hover = pointInRect(tx, ty, tab.Layout.w, tab.Layout.h, mousePos())
        td.btn.Position = Vector2.new(tx, ty)
        td.btn.Size = Vector2.new(tab.Layout.w, tab.Layout.h)
        td.btn.Color = theme.panel2
        td.btn.Transparency = active and 0.12 or 1
        td.btn.Visible = d.bg.Visible
        td.hover.Position = Vector2.new(tx, ty)
        td.hover.Size = Vector2.new(tab.Layout.w, tab.Layout.h)
        td.hover.Color = theme.panel2
        td.hover.Transparency = hover and not active and 0.6 or 1
        td.hover.Visible = d.bg.Visible
        td.indicator.Position = Vector2.new(tx, ty + 8)
        td.indicator.Size = Vector2.new(2, active and 14 or 0)
        td.indicator.Color = theme.accent
        td.indicator.Transparency = 0
        td.indicator.Visible = d.bg.Visible
        td.text.Text = tab.Name
        td.text.Position = Vector2.new(tx + 12, ty + 9)
        td.text.Color = active and theme.text or theme.text3
        td.text.Visible = d.bg.Visible
    end

    local tab = currentTab(win)
    for _, t in ipairs(win.Tabs) do
        for _, section in ipairs(t.Sections) do
            local show = tab == t
            setVisible(section.Drawings, show)
            for _, item in ipairs(section.Items) do
                setVisible(item.Drawings, show)
                if item.OptionDrawings then setVisible(item.OptionDrawings, show and item.Open) end
                if item.Type == "Module" then
                    for _, child in ipairs(item.Children) do
                        setVisible(child.Drawings, show and item.Open)
                    end
                end
            end
        end
    end
    if not tab then return end

    local cx, cy, cw = getTabContentBounds(win)
    local gutter = 12
    local colW = math.floor((cw - gutter) / 2)
    local leftX = cx
    local rightX = cx + colW + gutter
    local leftY = cy
    local rightY = cy

    for _, section in ipairs(tab.Sections) do
        local sx = section.Side == "Right" and rightX or leftX
        local sy = section.Side == "Right" and rightY or leftY
        local sh = sectionHeight(section)
        section.Layout.x, section.Layout.y, section.Layout.w, section.Layout.h = sx, sy, colW, sh

        local sd = section.Drawings
        sd.bg.Position = Vector2.new(sx, sy)
        sd.bg.Size = Vector2.new(colW, sh)
        sd.bg.Color = theme.panel
        sd.bg.Transparency = 0.22
        sd.bg.Visible = true
        sd.border.Position = Vector2.new(sx, sy)
        sd.border.Size = Vector2.new(colW, sh)
        sd.border.Color = theme.border
        sd.border.Thickness = 1
        sd.border.Visible = true
        sd.title.Text = section.Title
        sd.title.Position = Vector2.new(sx + 8, sy + 7)
        sd.title.Color = theme.text
        sd.title.Visible = true
        sd.separator.From = Vector2.new(sx, sy + 24)
        sd.separator.To = Vector2.new(sx + colW, sy + 24)
        sd.separator.Color = theme.border
        sd.separator.Thickness = 1
        sd.separator.Visible = true

        local iy = sy + 32
        for _, item in ipairs(section.Items) do
            item.Abs = {x = sx + 8, y = iy, w = colW - 16, h = item.Height}
            local ix, iyy, iw, ih = item.Abs.x, item.Abs.y, item.Abs.w, item.Abs.h
            local hover = pointInRect(ix, iyy, iw, ih, mousePos())
            if item.Type == "Subtext" then
                item.Drawings.text.Text = item.Text
                item.Drawings.text.Position = Vector2.new(ix, iyy + 1)
                item.Drawings.text.Color = theme.text3
                item.Drawings.text.Visible = true
            elseif item.Type == "Toggle" then
                local val = Library.Flags[item.Flag]
                item.Hitbox = {x = ix, y = iyy, w = iw, h = ih}
                item.Drawings.box.Position = Vector2.new(ix, iyy + 2)
                item.Drawings.box.Size = Vector2.new(13, 13)
                item.Drawings.box.Color = val and theme.accent or theme.panel3
                item.Drawings.box.Transparency = 0.05
                item.Drawings.box.Visible = true
                item.Drawings.border.Position = Vector2.new(ix, iyy + 2)
                item.Drawings.border.Size = Vector2.new(13, 13)
                item.Drawings.border.Color = val and theme.accent or (hover and theme.border2 or theme.border)
                item.Drawings.border.Thickness = 1
                item.Drawings.border.Visible = true
                item.Drawings.text.Text = item.Name
                item.Drawings.text.Position = Vector2.new(ix + 20, iyy + 2)
                item.Drawings.text.Color = val and theme.text or theme.text2
                item.Drawings.text.Visible = true
            elseif item.Type == "Slider" then
                local val = Library.Flags[item.Flag]
                local p = clamp((val - item.Min) / (item.Max - item.Min), 0, 1)
                item.Hitbox = {x = ix + 2, y = iyy + 16, w = iw - 4, h = 14}
                item.Drawings.text.Text = item.Name
                item.Drawings.text.Position = Vector2.new(ix, iyy)
                item.Drawings.text.Color = theme.text
                item.Drawings.text.Visible = true
                item.Drawings.value.Text = formatValue(val, item.Step)
                item.Drawings.value.Position = Vector2.new(ix + iw - 4 - #item.Drawings.value.Text * 6, iyy)
                item.Drawings.value.Color = theme.text2
                item.Drawings.value.Visible = true
                item.Drawings.track.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.track.Size = Vector2.new(iw, 6)
                item.Drawings.track.Color = theme.panel3
                item.Drawings.track.Transparency = 0.05
                item.Drawings.track.Visible = true
                item.Drawings.fill.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.fill.Size = Vector2.new(math.max(1, math.floor(iw * p)), 6)
                item.Drawings.fill.Color = theme.accent
                item.Drawings.fill.Transparency = 0
                item.Drawings.fill.Visible = true
                item.Drawings.border.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.border.Size = Vector2.new(iw, 6)
                item.Drawings.border.Color = hover and theme.border2 or theme.border
                item.Drawings.border.Thickness = 1
                item.Drawings.border.Visible = true
                item.Drawings.knob.Position = Vector2.new(ix + iw * p, iyy + 21)
                item.Drawings.knob.Radius = 5
                item.Drawings.knob.Color = theme.text
                item.Drawings.knob.Transparency = 0
                item.Drawings.knob.Visible = true
                item.Drawings.knobBorder.Position = item.Drawings.knob.Position
                item.Drawings.knobBorder.Radius = 5
                item.Drawings.knobBorder.Color = theme.border
                item.Drawings.knobBorder.Thickness = 1
                item.Drawings.knobBorder.Visible = true
            elseif item.Type == "RangeSlider" then
                local val = Library.Flags[item.Flag]
                local p1 = clamp((val.Min - item.Min) / (item.Max - item.Min), 0, 1)
                local p2 = clamp((val.Max - item.Min) / (item.Max - item.Min), 0, 1)
                item.Hitbox = {x = ix + 2, y = iyy + 16, w = iw - 4, h = 14}
                item.Drawings.text.Text = item.Name
                item.Drawings.text.Position = Vector2.new(ix, iyy)
                item.Drawings.text.Color = theme.text
                item.Drawings.text.Visible = true
                item.Drawings.value.Text = formatValue(val.Min, item.Step) .. " - " .. formatValue(val.Max, item.Step)
                item.Drawings.value.Position = Vector2.new(ix + iw - 4 - #item.Drawings.value.Text * 6, iyy)
                item.Drawings.value.Color = theme.text2
                item.Drawings.value.Visible = true
                item.Drawings.track.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.track.Size = Vector2.new(iw, 6)
                item.Drawings.track.Color = theme.panel3
                item.Drawings.track.Visible = true
                item.Drawings.border.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.border.Size = Vector2.new(iw, 6)
                item.Drawings.border.Color = hover and theme.border2 or theme.border
                item.Drawings.border.Visible = true
                item.Drawings.fill.Position = Vector2.new(ix + iw * p1, iyy + 18)
                item.Drawings.fill.Size = Vector2.new(math.max(1, iw * (p2 - p1)), 6)
                item.Drawings.fill.Color = theme.accent
                item.Drawings.fill.Visible = true
                item.Drawings.knobMin.Position = Vector2.new(ix + iw * p1, iyy + 21)
                item.Drawings.knobMin.Radius = 5
                item.Drawings.knobMin.Color = theme.text
                item.Drawings.knobMin.Visible = true
                item.Drawings.knobMinBorder.Position = item.Drawings.knobMin.Position
                item.Drawings.knobMinBorder.Radius = 5
                item.Drawings.knobMinBorder.Color = theme.border
                item.Drawings.knobMinBorder.Visible = true
                item.Drawings.knobMax.Position = Vector2.new(ix + iw * p2, iyy + 21)
                item.Drawings.knobMax.Radius = 5
                item.Drawings.knobMax.Color = theme.text
                item.Drawings.knobMax.Visible = true
                item.Drawings.knobMaxBorder.Position = item.Drawings.knobMax.Position
                item.Drawings.knobMaxBorder.Radius = 5
                item.Drawings.knobMaxBorder.Color = theme.border
                item.Drawings.knobMaxBorder.Visible = true
            elseif item.Type == "Textbox" then
                item.Hitbox = {x = ix, y = iyy + 16, w = iw, h = 20}
                item.Drawings.label.Text = item.Name
                item.Drawings.label.Position = Vector2.new(ix, iyy)
                item.Drawings.label.Color = theme.text
                item.Drawings.label.Visible = true
                item.Drawings.box.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.box.Size = Vector2.new(iw, 20)
                item.Drawings.box.Color = theme.panel3
                item.Drawings.box.Visible = true
                item.Drawings.border.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.border.Size = Vector2.new(iw, 20)
                item.Drawings.border.Color = UIState.ActiveTextbox == item and theme.accent or (hover and theme.border2 or theme.border)
                item.Drawings.border.Visible = true
                local txt = tostring(Library.Flags[item.Flag] or "")
                if txt == "" then txt = UIState.ActiveTextbox == item and "" or "..." end
                item.Drawings.text.Text = txt
                item.Drawings.text.Position = Vector2.new(ix + 6, iyy + 21)
                item.Drawings.text.Color = (Library.Flags[item.Flag] == "" and UIState.ActiveTextbox ~= item) and theme.text3 or theme.text2
                item.Drawings.text.Visible = true
            elseif item.Type == "Keybind" then
                item.Hitbox = {x = ix + iw - 76, y = iyy + 1, w = 76, h = 18}
                item.Drawings.label.Text = item.Name
                item.Drawings.label.Position = Vector2.new(ix, iyy + 1)
                item.Drawings.label.Color = theme.text
                item.Drawings.label.Visible = true
                item.Drawings.box.Position = Vector2.new(ix + iw - 76, iyy)
                item.Drawings.box.Size = Vector2.new(76, 20)
                item.Drawings.box.Color = theme.panel3
                item.Drawings.box.Visible = true
                item.Drawings.border.Position = Vector2.new(ix + iw - 76, iyy)
                item.Drawings.border.Size = Vector2.new(76, 20)
                item.Drawings.border.Color = UIState.ActiveKeybind == item and theme.accent or (hover and theme.border2 or theme.border)
                item.Drawings.border.Visible = true
                local key = Library.Flags[item.Flag]
                local text = UIState.ActiveKeybind == item and "[...]" or "[ " .. ((key and key ~= Enum.KeyCode.Unknown) and key.Name or "None") .. " ]"
                item.Drawings.text.Text = text
                item.Drawings.text.Position = Vector2.new(ix + iw - 38, iyy + 3)
                item.Drawings.text.Color = theme.text2
                item.Drawings.text.Visible = true
            elseif item.Type == "Dropdown" then
                item.Hitbox = {x = ix, y = iyy + 18, w = iw, h = 20}
                item.Drawings.label.Text = item.Name
                item.Drawings.label.Position = Vector2.new(ix, iyy)
                item.Drawings.label.Color = theme.text
                item.Drawings.label.Visible = true
                item.Drawings.box.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.box.Size = Vector2.new(iw, 20)
                item.Drawings.box.Color = theme.panel3
                item.Drawings.box.Visible = true
                item.Drawings.border.Position = Vector2.new(ix, iyy + 18)
                item.Drawings.border.Size = Vector2.new(iw, 20)
                item.Drawings.border.Color = item.Open and theme.accent or (hover and theme.border2 or theme.border)
                item.Drawings.border.Visible = true
                item.Drawings.text.Text = tostring(Library.Flags[item.Flag])
                item.Drawings.text.Position = Vector2.new(ix + 6, iyy + 21)
                item.Drawings.text.Color = theme.text2
                item.Drawings.text.Visible = true
                item.Drawings.arrow.Text = item.Open and "^" or "v"
                item.Drawings.arrow.Position = Vector2.new(ix + iw - 12, iyy + 21)
                item.Drawings.arrow.Color = theme.text2
                item.Drawings.arrow.Visible = true
                if item.Open then
                    for idx, option in ipairs(item.Values) do
                        local od = item.OptionDrawings[idx]
                        if not od then
                            od = {box = makeSquare(true), border = makeSquare(false), text = makeText(12, false)}
                            item.OptionDrawings[idx] = od
                        end
                        local oy = iyy + 40 + (idx - 1) * 20
                        local oh = 20
                        local ohover = pointInRect(ix, oy, iw, oh, mousePos())
                        od.box.Position = Vector2.new(ix, oy)
                        od.box.Size = Vector2.new(iw, oh)
                        od.box.Color = theme.panel3
                        od.box.Transparency = ohover and 0.25 or 0.05
                        od.box.Visible = true
                        od.border.Position = Vector2.new(ix, oy)
                        od.border.Size = Vector2.new(iw, oh)
                        od.border.Color = tostring(Library.Flags[item.Flag]) == tostring(option) and theme.accent or theme.border
                        od.border.Visible = true
                        od.text.Text = tostring(option)
                        od.text.Position = Vector2.new(ix + 6, oy + 3)
                        od.text.Color = theme.text2
                        od.text.Visible = true
                        od.Hitbox = {x = ix, y = oy, w = iw, h = oh, value = option}
                    end
                    for idx = #item.Values + 1, #item.OptionDrawings do
                        setVisible(item.OptionDrawings[idx], false)
                    end
                else
                    for _, od in ipairs(item.OptionDrawings) do
                        setVisible(od, false)
                    end
                end
            elseif item.Type == "ColorPicker" then
                if not item.HSV or item.Drawings.preview.Color ~= Library.Flags[item.Flag] then
                    item.HSV = getColorHSV(Library.Flags[item.Flag])
                end
                item.Hitbox = {x = ix + iw - 22, y = iyy + 2, w = 22, h = 14}
                item.Drawings.label.Text = item.Name
                item.Drawings.label.Position = Vector2.new(ix, iyy + 1)
                item.Drawings.label.Color = theme.text
                item.Drawings.label.Visible = true
                item.Drawings.preview.Position = Vector2.new(ix + iw - 22, iyy + 2)
                item.Drawings.preview.Size = Vector2.new(22, 14)
                item.Drawings.preview.Color = Library.Flags[item.Flag]
                item.Drawings.preview.Visible = true
                item.Drawings.previewBorder.Position = Vector2.new(ix + iw - 22, iyy + 2)
                item.Drawings.previewBorder.Size = Vector2.new(22, 14)
                item.Drawings.previewBorder.Color = item.Open and theme.accent or theme.border
                item.Drawings.previewBorder.Visible = true
                local popupW, popupH = 120, 94
                local px = ix + iw - popupW
                local py = iyy + 22
                item.Popup = {x = px, y = py, w = popupW, h = popupH, sv = {x = px + 8, y = py + 8, w = 80, h = 60}, hue = {x = px + 94, y = py + 8, w = 14, h = 60}}
                if item.Open then
                    item.Drawings.popup.Position = Vector2.new(px, py)
                    item.Drawings.popup.Size = Vector2.new(popupW, popupH)
                    item.Drawings.popup.Color = theme.panel2
                    item.Drawings.popup.Visible = true
                    item.Drawings.popupBorder.Position = Vector2.new(px, py)
                    item.Drawings.popupBorder.Size = Vector2.new(popupW, popupH)
                    item.Drawings.popupBorder.Color = theme.border2
                    item.Drawings.popupBorder.Visible = true
                    item.Drawings.value.Position = Vector2.new(px + 8, py + 8)
                    item.Drawings.value.Size = Vector2.new(80, 60)
                    item.Drawings.value.Color = Color3.fromHSV(item.HSV.H, 1, 1)
                    item.Drawings.value.Visible = true
                    item.Drawings.valueBorder.Position = Vector2.new(px + 8, py + 8)
                    item.Drawings.valueBorder.Size = Vector2.new(80, 60)
                    item.Drawings.valueBorder.Color = theme.border
                    item.Drawings.valueBorder.Visible = true
                    item.Drawings.hue.Position = Vector2.new(px + 94, py + 8)
                    item.Drawings.hue.Size = Vector2.new(14, 60)
                    item.Drawings.hue.Color = Color3.fromHSV(item.HSV.H, 1, 1)
                    item.Drawings.hue.Visible = true
                    item.Drawings.hueBorder.Position = Vector2.new(px + 94, py + 8)
                    item.Drawings.hueBorder.Size = Vector2.new(14, 60)
                    item.Drawings.hueBorder.Color = theme.border
                    item.Drawings.hueBorder.Visible = true
                else
                    item.Drawings.popup.Visible = false
                    item.Drawings.popupBorder.Visible = false
                    item.Drawings.value.Visible = false
                    item.Drawings.valueBorder.Visible = false
                    item.Drawings.hue.Visible = false
                    item.Drawings.hueBorder.Visible = false
                end
            elseif item.Type == "Button" then
                item.Hitbox = {x = ix, y = iyy, w = iw, h = 24}
                item.Drawings.box.Position = Vector2.new(ix, iyy)
                item.Drawings.box.Size = Vector2.new(iw, 24)
                item.Drawings.box.Color = theme.panel3
                item.Drawings.box.Transparency = hover and 0.2 or 0.05
                item.Drawings.box.Visible = true
                item.Drawings.border.Position = Vector2.new(ix, iyy)
                item.Drawings.border.Size = Vector2.new(iw, 24)
                item.Drawings.border.Color = hover and theme.border2 or theme.border
                item.Drawings.border.Visible = true
                item.Drawings.text.Text = item.Name
                item.Drawings.text.Position = Vector2.new(ix + iw / 2, iyy + 4)
                item.Drawings.text.Color = theme.text
                item.Drawings.text.Visible = true
            elseif item.Type == "Module" then
                item.Hitbox = {x = ix, y = iyy, w = iw, h = 24, toggle = {x = ix + 4, y = iyy + 5, w = 12, h = 12}, arrow = {x = ix + iw - 22, y = iyy, w = 22, h = 24}}
                local val = Library.Flags[item.Flag]
                item.Drawings.box.Position = Vector2.new(ix, iyy)
                item.Drawings.box.Size = Vector2.new(iw, 24)
                item.Drawings.box.Color = theme.panel3
                item.Drawings.box.Transparency = hover and 0.2 or 0.05
                item.Drawings.box.Visible = true
                item.Drawings.border.Position = Vector2.new(ix, iyy)
                item.Drawings.border.Size = Vector2.new(iw, 24)
                item.Drawings.border.Color = hover and theme.border2 or theme.border
                item.Drawings.border.Visible = true
                item.Drawings.toggle.Position = Vector2.new(ix + 4, iyy + 5)
                item.Drawings.toggle.Size = Vector2.new(12, 12)
                item.Drawings.toggle.Color = val and theme.accent or theme.panel2
                item.Drawings.toggle.Visible = true
                item.Drawings.toggleBorder.Position = Vector2.new(ix + 4, iyy + 5)
                item.Drawings.toggleBorder.Size = Vector2.new(12, 12)
                item.Drawings.toggleBorder.Color = val and theme.accent or theme.border
                item.Drawings.toggleBorder.Visible = true
                item.Drawings.text.Text = item.Name
                item.Drawings.text.Position = Vector2.new(ix + 22, iyy + 4)
                item.Drawings.text.Color = theme.text
                item.Drawings.text.Visible = true
                item.Drawings.arrow.Text = item.Open and "^" or "v"
                item.Drawings.arrow.Position = Vector2.new(ix + iw - 12, iyy + 4)
                item.Drawings.arrow.Color = theme.text2
                item.Drawings.arrow.Visible = true
                if item.Open then
                    local cy2 = iyy + 30
                    for _, child in ipairs(item.Children) do
                        child.Abs = {x = ix + 8, y = cy2, w = iw - 8, h = child.Height}
                        local cix, ciy, ciw = child.Abs.x, child.Abs.y, child.Abs.w
                        local chover = pointInRect(cix, ciy, ciw, child.Height, mousePos())
                        if child.Type == "Subtext" then
                            child.Drawings.text.Text = child.Text
                            child.Drawings.text.Position = Vector2.new(cix, ciy + 1)
                            child.Drawings.text.Color = theme.text3
                            child.Drawings.text.Visible = true
                        elseif child.Type == "SubButton" then
                            child.Hitbox = {x = cix, y = ciy, w = ciw - 8, h = 22}
                            child.Drawings.box.Position = Vector2.new(cix, ciy)
                            child.Drawings.box.Size = Vector2.new(ciw - 8, 22)
                            child.Drawings.box.Color = theme.panel2
                            child.Drawings.box.Transparency = chover and 0.2 or 0.05
                            child.Drawings.box.Visible = true
                            child.Drawings.border.Position = Vector2.new(cix, ciy)
                            child.Drawings.border.Size = Vector2.new(ciw - 8, 22)
                            child.Drawings.border.Color = chover and theme.border2 or theme.border
                            child.Drawings.border.Visible = true
                            child.Drawings.text.Text = child.Name
                            child.Drawings.text.Position = Vector2.new(cix + (ciw - 8) / 2, ciy + 3)
                            child.Drawings.text.Color = theme.text2
                            child.Drawings.text.Visible = true
                        end
                        cy2 = cy2 + child.Height + 4
                    end
                else
                    for _, child in ipairs(item.Children) do
                        setVisible(child.Drawings, false)
                    end
                end
            end
            iy = iy + item.Height + 6
            if item.Type == "Module" and item.Open then
                for _, child in ipairs(item.Children) do
                    iy = iy + child.Height + 4
                end
            end
        end

        if section.Side == "Right" then rightY = sy + sh + 10 else leftY = sy + sh + 10 end
    end
end

local function clickWindow(win, p)
    if not (win.Visible and UIState.Visible) then return false end
    if pointInRect(win.X, win.Y, win.W, win.TopH, p) then
        UIState.DragWindow = win
        UIState.DragOffset = Vector2.new(p.X - win.X, p.Y - win.Y)
        return true
    end
    for _, tab in ipairs(win.Tabs) do
        if pointInRect(tab.Layout.x, tab.Layout.y, tab.Layout.w, tab.Layout.h, p) then
            win.ActiveTab = tab
            UIState.OpenDropdown = nil
            UIState.OpenColor = nil
            return true
        end
    end
    local tab = currentTab(win)
    if not tab then return false end
    for _, section in ipairs(tab.Sections) do
        for _, item in ipairs(section.Items) do
            if item.Type == "Toggle" and pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                Library.Flags[item.Flag] = not Library.Flags[item.Flag]
                if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
                return true
            elseif item.Type == "Slider" and pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                UIState.ActiveSlider = item
                return true
            elseif item.Type == "RangeSlider" and pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                local val = Library.Flags[item.Flag]
                local width = item.Hitbox.w
                local x = p.X - item.Hitbox.x
                local pcur = clamp(x / width, 0, 1)
                local p1 = clamp((val.Min - item.Min) / (item.Max - item.Min), 0, 1)
                local p2 = clamp((val.Max - item.Min) / (item.Max - item.Min), 0, 1)
                UIState.ActiveRangeSlider = {Item = item, Handle = math.abs(pcur - p1) <= math.abs(pcur - p2) and "Min" or "Max"}
                return true
            elseif item.Type == "Textbox" and pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                UIState.ActiveTextbox = item
                UIState.ActiveKeybind = nil
                return true
            elseif item.Type == "Keybind" and pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                UIState.ActiveKeybind = item
                UIState.ActiveTextbox = nil
                return true
            elseif item.Type == "Dropdown" then
                if pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                    item.Open = not item.Open
                    UIState.OpenDropdown = item.Open and item or nil
                    if UIState.OpenDropdown ~= item then item.Open = false end
                    return true
                end
                if item.Open then
                    for _, od in ipairs(item.OptionDrawings) do
                        if od.Hitbox and pointInRect(od.Hitbox.x, od.Hitbox.y, od.Hitbox.w, od.Hitbox.h, p) then
                            Library.Flags[item.Flag] = od.Hitbox.value
                            item.Open = false
                            UIState.OpenDropdown = nil
                            if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
                            return true
                        end
                    end
                end
            elseif item.Type == "ColorPicker" then
                if pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                    item.Open = not item.Open
                    UIState.OpenColor = item.Open and item or nil
                    return true
                end
                if item.Open and item.Popup then
                    if pointInRect(item.Popup.hue.x, item.Popup.hue.y, item.Popup.hue.w, item.Popup.hue.h, p) then
                        item.HSV.H = clamp((p.Y - item.Popup.hue.y) / item.Popup.hue.h, 0, 1)
                        Library.Flags[item.Flag] = Color3.fromHSV(item.HSV.H, item.HSV.S, item.HSV.V)
                        if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
                        UIState.OpenColor = item
                        UIState.ActiveSlider = {Color = item, Mode = "Hue"}
                        return true
                    elseif pointInRect(item.Popup.sv.x, item.Popup.sv.y, item.Popup.sv.w, item.Popup.sv.h, p) then
                        item.HSV.S = clamp((p.X - item.Popup.sv.x) / item.Popup.sv.w, 0, 1)
                        item.HSV.V = 1 - clamp((p.Y - item.Popup.sv.y) / item.Popup.sv.h, 0, 1)
                        Library.Flags[item.Flag] = Color3.fromHSV(item.HSV.H, item.HSV.S, item.HSV.V)
                        if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
                        UIState.ActiveSlider = {Color = item, Mode = "SV"}
                        return true
                    end
                end
            elseif item.Type == "Button" and pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                if item.Callback then task.spawn(item.Callback) end
                return true
            elseif item.Type == "Module" then
                if pointInRect(item.Hitbox.toggle.x, item.Hitbox.toggle.y, item.Hitbox.toggle.w, item.Hitbox.toggle.h, p) then
                    Library.Flags[item.Flag] = not Library.Flags[item.Flag]
                    if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
                    return true
                elseif pointInRect(item.Hitbox.arrow.x, item.Hitbox.arrow.y, item.Hitbox.arrow.w, item.Hitbox.arrow.h, p) then
                    item.Open = not item.Open
                    return true
                elseif pointInRect(item.Hitbox.x, item.Hitbox.y, item.Hitbox.w, item.Hitbox.h, p) then
                    item.Open = not item.Open
                    return true
                end
                if item.Open then
                    for _, child in ipairs(item.Children) do
                        if child.Type == "SubButton" and child.Hitbox and pointInRect(child.Hitbox.x, child.Hitbox.y, child.Hitbox.w, child.Hitbox.h, p) then
                            if child.Callback then task.spawn(child.Callback) end
                            return true
                        end
                    end
                end
            end
        end
    end
    return pointInRect(win.X, win.Y, win.W, win.H, p)
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.Delete then
        UIState.Visible = not UIState.Visible
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UIState.MouseDown = true
        local p = mousePos()
        UIState.ActiveTextbox = nil
        UIState.ActiveKeybind = nil
        for i = #Library.Windows, 1, -1 do
            if clickWindow(Library.Windows[i], p) then
                break
            end
        end
    elseif UIState.ActiveTextbox and input.UserInputType == Enum.UserInputType.Keyboard then
        local item = UIState.ActiveTextbox
        if input.KeyCode == Enum.KeyCode.Backspace then
            local s = tostring(Library.Flags[item.Flag] or "")
            Library.Flags[item.Flag] = s:sub(1, math.max(0, #s - 1))
            if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
        elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.KeypadEnter or input.KeyCode == Enum.KeyCode.Escape then
            UIState.ActiveTextbox = nil
        else
            local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            local ch = keyToChar(input.KeyCode, shift)
            if ch then
                Library.Flags[item.Flag] = tostring(Library.Flags[item.Flag] or "") .. ch
                if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
            end
        end
    elseif UIState.ActiveKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
        local item = UIState.ActiveKeybind
        if input.KeyCode == Enum.KeyCode.Escape then
            Library.Flags[item.Flag] = Enum.KeyCode.Unknown
        else
            Library.Flags[item.Flag] = input.KeyCode
        end
        UIState.ActiveKeybind = nil
        if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
    else
        for _, win in ipairs(Library.Windows) do
            local tab = currentTab(win)
            if tab then
                for _, section in ipairs(tab.Sections) do
                    for _, item in ipairs(section.Items) do
                        if item.Type == "Keybind" and Library.Flags[item.Flag] == input.KeyCode and item.Callback then
                            task.spawn(item.Callback, input.KeyCode)
                        end
                    end
                end
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        UIState.MouseDown = false
        UIState.DragWindow = nil
        UIState.ActiveSlider = nil
        UIState.ActiveRangeSlider = nil
    end
end)

RunService.RenderStepped:Connect(function()
    local p = mousePos()
    if UIState.DragWindow then
        local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
        UIState.DragWindow.X = clamp(p.X - UIState.DragOffset.X, 0, math.max(0, vp.X - UIState.DragWindow.W))
        UIState.DragWindow.Y = clamp(p.Y - UIState.DragOffset.Y, 0, math.max(0, vp.Y - UIState.DragWindow.H))
    end
    if UIState.ActiveSlider then
        if UIState.ActiveSlider.Color then
            local item = UIState.ActiveSlider.Color
            if UIState.ActiveSlider.Mode == "Hue" then
                item.HSV.H = clamp((p.Y - item.Popup.hue.y) / item.Popup.hue.h, 0, 1)
            else
                item.HSV.S = clamp((p.X - item.Popup.sv.x) / item.Popup.sv.w, 0, 1)
                item.HSV.V = 1 - clamp((p.Y - item.Popup.sv.y) / item.Popup.sv.h, 0, 1)
            end
            Library.Flags[item.Flag] = Color3.fromHSV(item.HSV.H, item.HSV.S, item.HSV.V)
            if item.Callback then task.spawn(item.Callback, Library.Flags[item.Flag]) end
        else
            local item = UIState.ActiveSlider
            local hb = item.Hitbox
            local pr = clamp((p.X - hb.x) / hb.w, 0, 1)
            local val = round(item.Min + (item.Max - item.Min) * pr, item.Step)
            val = clamp(val, item.Min, item.Max)
            if Library.Flags[item.Flag] ~= val then
                Library.Flags[item.Flag] = val
                if item.Callback then task.spawn(item.Callback, val) end
            end
        end
    end
    if UIState.ActiveRangeSlider then
        local item = UIState.ActiveRangeSlider.Item
        local hb = item.Hitbox
        local pr = clamp((p.X - hb.x) / hb.w, 0, 1)
        local val = round(item.Min + (item.Max - item.Min) * pr, item.Step)
        val = clamp(val, item.Min, item.Max)
        local ref = Library.Flags[item.Flag]
        if UIState.ActiveRangeSlider.Handle == "Min" then
            ref.Min = math.min(val, ref.Max)
        else
            ref.Max = math.max(val, ref.Min)
        end
        if item.Callback then task.spawn(item.Callback, ref) end
    end

    for _, win in ipairs(Library.Windows) do
        updateWindowLayout(win)
    end

    local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
    for i, n in ipairs(notifications) do
        local age = tick() - n.Start
        local alive = age <= n.Duration
        if alive and UIState.Visible then
            local y = vp.Y - 70 - (i - 1) * 56
            local d = n.Drawings
            local color = theme.accent
            if n.Type == "Success" then color = theme.success elseif n.Type == "Warning" then color = theme.warning elseif n.Type == "Error" then color = theme.danger end
            d.bg.Position = Vector2.new(vp.X - 290, y)
            d.bg.Size = Vector2.new(260, 46)
            d.bg.Color = theme.bg2
            d.bg.Transparency = 0.1
            d.bg.Visible = true
            d.border.Position = Vector2.new(vp.X - 290, y)
            d.border.Size = Vector2.new(260, 46)
            d.border.Color = theme.border2
            d.border.Visible = true
            d.accent.Position = Vector2.new(vp.X - 290, y)
            d.accent.Size = Vector2.new(2, 46)
            d.accent.Color = color
            d.accent.Visible = true
            d.title.Text = n.Title
            d.title.Position = Vector2.new(vp.X - 278, y + 7)
            d.title.Color = theme.text
            d.title.Visible = true
            d.text.Text = n.Text
            d.text.Position = Vector2.new(vp.X - 278, y + 23)
            d.text.Color = theme.text2
            d.text.Visible = true
        else
            setVisible(n.Drawings, false)
        end
    end
    for i = #notifications, 1, -1 do
        if tick() - notifications[i].Start > notifications[i].Duration then
            removeDrawings(notifications[i].Drawings)
            table.remove(notifications, i)
        end
    end
end)

return Library
