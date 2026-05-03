local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local listfiles = listfiles or function() return {} end
local delfile = delfile or function() end
local CoreGui
pcall(function() CoreGui = game:GetService("CoreGui") end)
local LocalPlayer = Players.LocalPlayer
local Library = {
    Flags = {},
    Signals = {},
    Defaults = {},
    Open = true,
    KeybindList = nil,
    ShowKeybinds = true,
    ScreenGui = nil,
    Connections = {},
    Elements = {},
    Unsaved = false,
    AutoSaveEnabled = true
}
local Config = {
    Name = "PHANTOM HUB",
    Keybind = Enum.KeyCode.LeftControl,
    Duration = 0.3,
    FontMain = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    ConfigFolder = "PhantomHub"
}
if not isfolder(Config.ConfigFolder) then makefolder(Config.ConfigFolder) end
local Theme = {
    Background = Color3.fromHex("#080505"),
    Sidebar = Color3.fromHex("#0c0707"),
    Container = Color3.fromHex("#140b0b"),
    Section = Color3.fromHex("#1a0e0e"),
    Accent = Color3.fromHex("#ff1a1a"),
    Text = Color3.fromHex("#ffffff"),
    TextDark = Color3.fromHex("#997373"),
    Stroke = Color3.fromHex("#2e1717"),
    Success = Color3.fromHex("#00ff88"),
    Danger = Color3.fromHex("#ff4444")
}
local ThemeRegistry = {}
setmetatable(ThemeRegistry, { __mode = "k" })
local function RegisterTheme(instance, propType)
    ThemeRegistry[instance] = propType
    return instance
end
function Library:UpdateTheme(newColor)
    Theme.Accent = newColor
    for instance, propType in pairs(ThemeRegistry) do
        if instance and instance.Parent then
            if propType == "TextColor" then instance.TextColor3 = newColor
            elseif propType == "BackgroundColor" then instance.BackgroundColor3 = newColor
            elseif propType == "BorderColor" then
                if instance:IsA("UIStroke") then instance.Color = newColor else instance.BorderColor3 = newColor end
            elseif propType == "ImageColor" then instance.ImageColor3 = newColor
            elseif propType == "ScrollBar" then instance.ScrollBarImageColor3 = newColor
            end
        end
    end
end
local function GetParent()
    if CoreGui then return CoreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local function Tween(obj, props, time, style, dir)
    time = time or Config.Duration
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local t = TweenService:Create(obj, TweenInfo.new(time, style, dir), props)
    t:Play()
    return t
end
local function Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end
local function Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end
local function RoundToIncrement(value, increment)
    if increment <= 0 then return value end
    return math.round(value / increment) * increment
end
local function FormatNumber(value, increment)
    if increment >= 1 then
        return tostring(math.round(value))
    end
    local str = tostring(increment)
    local dotPos = string.find(str, "%.")
    if dotPos then
        local decimals = #str - dotPos
        return string.format("%." .. decimals .. "f", value)
    end
    return tostring(value)
end
local function MakeDraggable(dragArea, frame, onDragCallback)
    local dragging = false
    local dragInput, dragStart, startPos
    local c1 = dragArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            local c2
            c2 = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if onDragCallback then onDragCallback(false) end
                    c2:Disconnect()
                end
            end)
        end
    end)
    local c3 = dragArea.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    local c4 = RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            if onDragCallback then onDragCallback(true) end
        end
    end)
    table.insert(Library.Connections, c1)
    table.insert(Library.Connections, c3)
    table.insert(Library.Connections, c4)
    return function() return dragging end
end
local function MakeResizable(resizeBtn, frame, minSize)
    local dragging = false
    local dragInput, dragStart, startSize, startPos, scaleMult
    local c1 = resizeBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startSize = frame.Size
            startPos = frame.Position
            local scaleObj = frame:FindFirstChildWhichIsA("UIScale")
            scaleMult = scaleObj and scaleObj.Scale or 1
            if scaleMult <= 0 then scaleMult = 1 end
            local c2
            c2 = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c2:Disconnect()
                end
            end)
        end
    end)
    local c3 = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    local c4 = RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local newX = math.max(minSize.X, startSize.X.Offset + (delta.X / scaleMult))
            local newY = math.max(minSize.Y, startSize.Y.Offset + (delta.Y / scaleMult))
            local diffX = (newX - startSize.X.Offset) * scaleMult
            local diffY = (newY - startSize.Y.Offset) * scaleMult
            frame.Size = UDim2.new(0, newX, 0, newY)
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (diffX / 2), startPos.Y.Scale, startPos.Y.Offset + (diffY / 2))
        end
    end)
    table.insert(Library.Connections, c1)
    table.insert(Library.Connections, c3)
    table.insert(Library.Connections, c4)
end
local function GetBaseScale()
    local vp = workspace.CurrentCamera.ViewportSize
    if vp.X < 1 or vp.Y < 1 then return 1 end
    local scaleX = vp.X / 800
    local scaleY = vp.Y / 500
    local scale = math.min(scaleX, scaleY)
    if scale < 1 then
        return math.clamp(scale * 0.95, 0.4, 1)
    end
    return 1
end
function Library:Unload()
    for _, conn in ipairs(Library.Connections) do pcall(function() conn:Disconnect() end) end
    Library.Connections = {}
    if Library.ScreenGui then pcall(function() Library.ScreenGui:Destroy() end) Library.ScreenGui = nil end
    if Library.KeybindList then pcall(function() Library.KeybindList.Screen:Destroy() end) Library.KeybindList = nil end
    for _, g in pairs(GetParent():GetChildren()) do
        if g.Name == "PrismaMini" or g.Name == Config.Name or g.Name == "PrismaKeybinds" or g.Name == "PrismaLoader" or g.Name == "PhantomNotifications" or g.Name == "PhantomWatermark" or g.Name == "PhantomTooltip" or g.Name == "PhantomMiniButton" then
            pcall(function() g:Destroy() end)
        end
    end
end
function Library:GetConfigs()
    local configs = {}
    if isfolder(Config.ConfigFolder) then
        local files = listfiles(Config.ConfigFolder)
        for _, file in ipairs(files) do
            if string.sub(file, -5) == ".json" then
                local name = string.match(string.gsub(file, "\\", "/"), "([^/]+)%.json$") or file
                if name ~= "_autosave" then
                    table.insert(configs, name)
                end
            end
        end
    end
    return configs
end
local IgnoredFlags = {
    ConfigSelectorFlag = true,
    MenuAccentColor = true,
    KeybindListToggle = true,
}
local function SerializeConfigValue(v)
    if typeof(v) == "Color3" then
        return {Type = "Color3", Hex = v:ToHex()}
    elseif typeof(v) == "EnumItem" then
        local enumName = tostring(v.EnumType):match("Enum%.(.+)") or tostring(v.EnumType)
        return {Type = "EnumItem", EnumType = enumName, Name = v.Name}
    elseif type(v) == "table" then
        local serialized = {}
        for tk, tv in pairs(v) do
            serialized[tk] = SerializeConfigValue(tv)
        end
        return {Type = "Table", Value = serialized}
    end
    return v
end
local function DeserializeConfigValue(value)
    if type(value) == "table" then
        if value.Type == "Color3" then
            local c = Color3.new(1, 1, 1)
            pcall(function() c = Color3.fromHex(value.Hex) end)
            return c
        elseif value.Type == "EnumItem" then
            local e
            pcall(function() e = Enum[value.EnumType][value.Name] end)
            return e
        elseif value.Type == "Table" then
            local deserialized = {}
            if type(value.Value) == "table" then
                for tk, tv in pairs(value.Value) do
                    deserialized[tk] = DeserializeConfigValue(tv)
                end
            end
            return deserialized
        end
    end
    return value
end
function Library:SaveConfig(name)
    if not name or name == "" then return false end
    local saveFlags = {}
    for k, v in pairs(Library.Flags) do
        if IgnoredFlags[k] then continue end
        saveFlags[k] = SerializeConfigValue(v)
    end
    local ok, json = pcall(HttpService.JSONEncode, HttpService, saveFlags)
    if ok then
        pcall(function()
            writefile(Config.ConfigFolder .. "/" .. name .. ".json", json)
        end)
        return true
    end
    return false
end
function Library:LoadConfig(name)
    if not name or name == "" then return false end
    local path = Config.ConfigFolder .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local content = readfile(path)
    local success, data = pcall(HttpService.JSONDecode, HttpService, content)
    if success and type(data) == "table" then
        for flag, value in pairs(data) do
            if IgnoredFlags[flag] then continue end
            Library.Flags[flag] = DeserializeConfigValue(value)
        end
        for flag, value in pairs(Library.Flags) do
            if IgnoredFlags[flag] then continue end
            if data[flag] ~= nil and Library.Signals[flag] then
                task.spawn(Library.Signals[flag], value)
            end
        end
        return true
    end
    return false
end
function Library:DeleteConfig(name)
    if not name or name == "" then return false end
    local path = Config.ConfigFolder .. "/" .. name .. ".json"
    if isfile(path) then
        pcall(function() delfile(path) end)
        return true
    end
    return false
end
function Library:ConfigExists(name)
    if not name or name == "" then return false end
    return isfile(Config.ConfigFolder .. "/" .. name .. ".json")
end
local TooltipGui = Instance.new("ScreenGui")
TooltipGui.Name = "PhantomTooltip"
TooltipGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TooltipGui.Parent = GetParent()
local TooltipLabel = Instance.new("TextLabel")
TooltipLabel.BackgroundTransparency = 0.05
TooltipLabel.BackgroundColor3 = Theme.Container
TooltipLabel.TextColor3 = Theme.Text
TooltipLabel.Font = Config.FontMain
TooltipLabel.TextSize = 12
TooltipLabel.Visible = false
TooltipLabel.Parent = TooltipGui
TooltipLabel.ZIndex = 1000
Corner(TooltipLabel, 4)
Stroke(TooltipLabel, Theme.Stroke, 1)
local function ApplyTooltip(guiObj, text)
    if not text or text == "" then return end
    local hovered = false
    local c1 = guiObj.MouseEnter:Connect(function()
        hovered = true
        task.delay(0.5, function()
            if hovered and Library.Open then
                TooltipLabel.Text = " " .. text .. " "
                TooltipLabel.Size = UDim2.new(0, TooltipLabel.TextBounds.X + 10, 0, 20)
                local mPos = UserInputService:GetMouseLocation()
                TooltipLabel.Position = UDim2.new(0, mPos.X + 10, 0, mPos.Y - 25)
                TooltipLabel.Visible = true
            end
        end)
    end)
    local c2 = guiObj.MouseMoved:Connect(function()
        if TooltipLabel.Visible then
            local mPos = UserInputService:GetMouseLocation()
            TooltipLabel.Position = UDim2.new(0, mPos.X + 10, 0, mPos.Y - 25)
        end
    end)
    local c3 = guiObj.MouseLeave:Connect(function()
        hovered = false
        TooltipLabel.Visible = false
    end)
    table.insert(Library.Connections, c1)
    table.insert(Library.Connections, c2)
    table.insert(Library.Connections, c3)
end
function Library:Notify(title, text, duration)
    local NotifGui = GetParent():FindFirstChild("PhantomNotifications")
    if not NotifGui then
        NotifGui = Instance.new("ScreenGui")
        NotifGui.Name = "PhantomNotifications"
        NotifGui.Parent = GetParent()
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.Size = UDim2.new(0, 250, 1, -20)
        Container.Position = UDim2.new(1, -270, 0, 10)
        Container.BackgroundTransparency = 1
        Container.Parent = NotifGui
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = Container
    end
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(1, 0, 0, 60)
    NotifFrame.BackgroundColor3 = Theme.Background
    NotifFrame.BackgroundTransparency = 0.1
    NotifFrame.Position = UDim2.new(1, 300, 0, 0)
    NotifFrame.Parent = NotifGui.Container
    Corner(NotifFrame, 6)
    Stroke(NotifFrame, Theme.Stroke, 1)
    local NNoise = Instance.new("ImageLabel")
    NNoise.Size = UDim2.new(1, 0, 1, 0)
    NNoise.BackgroundTransparency = 1
    NNoise.Image = "rbxassetid://9968344105"
    NNoise.ImageTransparency = 0.9
    NNoise.ScaleType = Enum.ScaleType.Tile
    NNoise.TileSize = UDim2.new(0, 100, 0, 100)
    NNoise.Parent = NotifFrame
    Corner(NNoise, 6)
    local NTitle = Instance.new("TextLabel")
    NTitle.Size = UDim2.new(1, -10, 0, 20)
    NTitle.Position = UDim2.new(0, 10, 0, 5)
    NTitle.BackgroundTransparency = 1
    NTitle.Text = title
    NTitle.TextColor3 = Theme.Accent
    NTitle.Font = Config.FontBold
    NTitle.TextSize = 13
    NTitle.TextXAlignment = Enum.TextXAlignment.Left
    NTitle.Parent = NotifFrame
    RegisterTheme(NTitle, "TextColor")
    local NText = Instance.new("TextLabel")
    NText.Size = UDim2.new(1, -20, 0, 20)
    NText.Position = UDim2.new(0, 10, 0, 25)
    NText.BackgroundTransparency = 1
    NText.Text = text
    NText.TextColor3 = Theme.Text
    NText.Font = Config.FontMain
    NText.TextSize = 12
    NText.TextXAlignment = Enum.TextXAlignment.Left
    NText.Parent = NotifFrame
    local TimebarBg = Instance.new("Frame")
    TimebarBg.Size = UDim2.new(1, 0, 0, 2)
    TimebarBg.Position = UDim2.new(0, 0, 1, -2)
    TimebarBg.BackgroundColor3 = Theme.Container
    TimebarBg.BorderSizePixel = 0
    TimebarBg.Parent = NotifFrame
    Corner(TimebarBg, 2)
    local Timebar = Instance.new("Frame")
    Timebar.Size = UDim2.new(1, 0, 1, 0)
    Timebar.BackgroundColor3 = Theme.Accent
    Timebar.BorderSizePixel = 0
    Timebar.Parent = TimebarBg
    Corner(Timebar, 2)
    RegisterTheme(Timebar, "BackgroundColor")
    Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    Tween(Timebar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        Tween(NotifFrame, {Position = UDim2.new(1, 300, 0, 0)}, 0.4).Completed:Wait()
        NotifFrame:Destroy()
    end)
end
function Library:InitWatermark()
    local WatermarkGui = Instance.new("ScreenGui")
    WatermarkGui.Name = "PhantomWatermark"
    WatermarkGui.Parent = GetParent()
    WatermarkGui.IgnoreGuiInset = true
    WatermarkGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 0, 0, 26)
    Frame.Position = UDim2.new(1, -20, 0, 10)
    Frame.AnchorPoint = Vector2.new(1, 0)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BackgroundTransparency = 0.05
    Frame.Parent = WatermarkGui
    Corner(Frame, 4)
    Stroke(Frame, Theme.Stroke, 1)
    local Glow = Stroke(Frame, Theme.Accent, 2, 0.8)
    RegisterTheme(Glow, "BorderColor")
    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.Position = UDim2.new(0, 0, 0, 0)
    AccentLine.BackgroundColor3 = Theme.Accent
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = Frame
    Corner(AccentLine, 2)
    RegisterTheme(AccentLine, "BackgroundColor")
    local WNoise = Instance.new("ImageLabel")
    WNoise.Size = UDim2.new(1, 0, 1, 0)
    WNoise.BackgroundTransparency = 1
    WNoise.Image = "rbxassetid://9968344105"
    WNoise.ImageTransparency = 0.95
    WNoise.ScaleType = Enum.ScaleType.Tile
    WNoise.TileSize = UDim2.new(0, 100, 0, 100)
    WNoise.Parent = Frame
    Corner(WNoise, 4)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Config.FontBold
    Label.TextSize = 12
    Label.TextColor3 = Theme.Text
    Label.RichText = true
    Label.Parent = Frame
    local lastUpdate = 0
    local frames = 0
    local conn
    conn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()
        if now - lastUpdate >= 1 then
            local fps = frames
            frames = 0
            lastUpdate = now
            local ping = "0"
            pcall(function()
                local s = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
                ping = s:match("%d+") or "0"
            end)
            local timeStr = os.date("%H:%M:%S")
            local text = string.format(" <font color='#%s'>%s</font> | FPS: %d | Ping: %sms | %s ", Theme.Accent:ToHex(), Config.Name, fps, ping, timeStr)
            Label.Text = text
            local bounds = Label.TextBounds.X + 20
            Tween(Frame, {Size = UDim2.new(0, bounds, 0, 26)}, 0.1)
        end
    end)
    table.insert(Library.Connections, conn)
end
function Library:CreateKeybindList()
    if Library.KeybindList then return end
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "PrismaKeybinds"
    Screen.Parent = GetParent()
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 180, 0, 30)
    Frame.Position = UDim2.new(0.01, 0, 0.4, 0)
    Frame.BackgroundColor3 = Theme.Background
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = Screen
    Frame.Active = true
    Frame.ClipsDescendants = true
    Corner(Frame, 4)
    Stroke(Frame, Theme.Stroke, 1, 0)
    MakeDraggable(Frame, Frame)
    local KNoise = Instance.new("ImageLabel")
    KNoise.Size = UDim2.new(1, 0, 1, 0)
    KNoise.BackgroundTransparency = 1
    KNoise.Image = "rbxassetid://9968344105"
    KNoise.ImageTransparency = 0.9
    KNoise.ScaleType = Enum.ScaleType.Tile
    KNoise.TileSize = UDim2.new(0, 100, 0, 100)
    KNoise.Parent = Frame
    Corner(KNoise, 4)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 24)
    Header.BackgroundColor3 = Theme.Sidebar
    Header.Parent = Frame
    Corner(Header, 4)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Keybinds"
    Title.TextColor3 = Theme.Accent
    Title.Font = Config.FontBold
    Title.TextSize = 12
    Title.Parent = Header
    RegisterTheme(Title, "TextColor")
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 26)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame
    local List = Instance.new("UIListLayout")
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Container
    local c1 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Frame.Size = UDim2.new(0, 180, 0, List.AbsoluteContentSize.Y + 30)
    end)
    table.insert(Library.Connections, c1)
    Library.KeybindList = {Frame = Frame, Container = Container, Screen = Screen}
    Frame.Visible = false
end
function Library:UpdateKeybindList(name, key, active, mode)
    if not Library.KeybindList then Library:CreateKeybindList() end
    local existing = Library.KeybindList.Container:FindFirstChild(name)
    if active and key ~= "None" and key ~= "Unknown" and mode ~= "Always" then
        if not existing then
            local Item = Instance.new("Frame")
            Item.Name = name
            Item.Size = UDim2.new(1, 0, 0, 20)
            Item.BackgroundTransparency = 1
            Item.Parent = Library.KeybindList.Container
            local LName = Instance.new("TextLabel")
            LName.Name = "LName"
            LName.Size = UDim2.new(0.6, 0, 1, 0)
            LName.Position = UDim2.new(0, 5, 0, 0)
            LName.BackgroundTransparency = 1
            LName.Text = name
            LName.TextColor3 = Theme.Text
            LName.Font = Config.FontMain
            LName.TextSize = 12
            LName.TextXAlignment = Enum.TextXAlignment.Left
            LName.Parent = Item
            local LKey = Instance.new("TextLabel")
            LKey.Name = "LKey"
            LKey.Size = UDim2.new(0.4, -5, 1, 0)
            LKey.Position = UDim2.new(0.6, 0, 0, 0)
            LKey.BackgroundTransparency = 1
            LKey.Text = "[" .. tostring(key) .. "]"
            LKey.TextColor3 = Theme.TextDark
            LKey.Font = Config.FontMain
            LKey.TextSize = 12
            LKey.TextXAlignment = Enum.TextXAlignment.Right
            LKey.Parent = Item
        else
            local lkey = existing:FindFirstChild("LKey")
            if lkey then lkey.Text = "[" .. tostring(key) .. "]" end
        end
    else
        if existing then existing:Destroy() end
    end
    if Library.ShowKeybinds then
        Library.KeybindList.Frame.Visible = (#Library.KeybindList.Container:GetChildren() > 1)
    else
        Library.KeybindList.Frame.Visible = false
    end
end
local function CreateDropdownElement(text, flag, options, default, tooltipText, callback, parentFrame, sectionRef, isMulti, customParent)
    local selected = Library.Flags[flag]
    if selected == nil then
        if isMulti then
            if type(default) ~= "table" then selected = {default} else selected = default end
        else
            selected = default or options[1]
        end
    end
    Library.Defaults[flag] = selected
    Library.Flags[flag] = selected
    local isDropped = false
    local parent = customParent or parentFrame
    local DropFrame = Instance.new("Frame")
    DropFrame.Size = UDim2.new(1, customParent and -20 or 0, 0, 46)
    if customParent then DropFrame.Position = UDim2.new(0, 20, 0, 0) end
    DropFrame.BackgroundTransparency = 1
    DropFrame.Parent = parent
    DropFrame.ZIndex = 5
    local DLabel = Instance.new("TextLabel")
    DLabel.Text = text
    DLabel.Font = Config.FontMain
    DLabel.TextSize = 13
    DLabel.TextColor3 = customParent and Theme.TextDark or Theme.Text
    DLabel.Size = UDim2.new(1, 0, 0, 16)
    DLabel.Position = UDim2.new(0, 5, 0, 0)
    DLabel.TextXAlignment = Enum.TextXAlignment.Left
    DLabel.BackgroundTransparency = 1
    DLabel.Parent = DropFrame
    local Interactive = Instance.new("TextButton")
    Interactive.Size = UDim2.new(1, 0, 0, 26)
    Interactive.Position = UDim2.new(0, 0, 0, 20)
    Interactive.BackgroundColor3 = Theme.Container
    Interactive.Text = ""
    Interactive.AutoButtonColor = false
    Interactive.Parent = DropFrame
    Interactive.ZIndex = 5
    Corner(Interactive, 4)
    Stroke(Interactive, Theme.Stroke, 1, 0.5)
    local SelectedText = Instance.new("TextLabel")
    SelectedText.Font = Config.FontMain
    SelectedText.TextSize = 13
    SelectedText.TextColor3 = Theme.Text
    SelectedText.Size = UDim2.new(1, -25, 1, 0)
    SelectedText.Position = UDim2.new(0, 8, 0, 0)
    SelectedText.TextXAlignment = Enum.TextXAlignment.Left
    SelectedText.BackgroundTransparency = 1
    SelectedText.ZIndex = 6
    SelectedText.ClipsDescendants = false
    SelectedText.TextTruncate = Enum.TextTruncate.AtEnd
    SelectedText.Parent = Interactive
    local Arrow = Instance.new("ImageLabel")
    Arrow.Image = "rbxassetid://10709790948"
    Arrow.Size = UDim2.new(0, 18, 0, 18)
    Arrow.Position = UDim2.new(1, -20, 0.5, 0)
    Arrow.AnchorPoint = Vector2.new(0, 0.5)
    Arrow.BackgroundTransparency = 1
    Arrow.ImageColor3 = Theme.TextDark
    Arrow.Parent = Interactive
    Arrow.ZIndex = 6
    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, 0, 0, 0)
    ListFrame.Position = UDim2.new(0, 0, 1, 5)
    ListFrame.BackgroundColor3 = Theme.Container
    ListFrame.BorderSizePixel = 0
    ListFrame.Parent = Interactive
    ListFrame.ZIndex = 10
    ListFrame.Visible = false
    ListFrame.Active = true
    ListFrame.ScrollBarThickness = 2
    ListFrame.ScrollBarImageColor3 = Theme.Accent
    ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Corner(ListFrame, 4)
    Stroke(ListFrame, Theme.Stroke, 1, 0.5)
    local IList = Instance.new("UIListLayout")
    IList.SortOrder = Enum.SortOrder.LayoutOrder
    IList.Parent = ListFrame
    local function CloseDropdown()
        isDropped = false
        if sectionRef and sectionRef.Container then sectionRef.Container.ZIndex = 1 end
        DropFrame.ZIndex = 5
        if customParent then customParent.ZIndex = 1 end
        Tween(DropFrame, {Size = UDim2.new(1, customParent and -20 or 0, 0, 46)}, 0.2)
        local t = Tween(ListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        Tween(Arrow, {Rotation = 0}, 0.2)
        local c2
        c2 = t.Completed:Connect(function()
            if not isDropped then ListFrame.Visible = false end
            c2:Disconnect()
        end)
    end
    local optionBtns = {}
    local function IsSelected(opt)
        if isMulti then
            for _, v in ipairs(selected) do
                if v == opt then return true end
            end
            return false
        else
            return selected == opt
        end
    end
    local function UpdateVisuals()
        if isMulti then
            SelectedText.Text = (#selected > 0 and table.concat(selected, ", ") or "None")
        else
            SelectedText.Text = tostring(selected)
        end
        for opt, btn in pairs(optionBtns) do
            if IsSelected(opt) then
                btn.TextColor3 = Theme.Accent
            else
                btn.TextColor3 = Theme.TextDark
            end
        end
    end
    local function BuildOptions(newOptions)
        for _, btn in pairs(optionBtns) do btn:Destroy() end
        table.clear(optionBtns)
        options = newOptions
        for _, opt in ipairs(options) do
            local OptBtn = Instance.new("TextButton")
            OptBtn.Size = UDim2.new(1, 0, 0, 24)
            OptBtn.BackgroundColor3 = Theme.Container
            OptBtn.BackgroundTransparency = 1
            OptBtn.Text = opt
            OptBtn.Font = Config.FontMain
            OptBtn.TextSize = 12
            OptBtn.Parent = ListFrame
            OptBtn.ZIndex = 11
            if IsSelected(opt) then
                OptBtn.TextColor3 = Theme.Accent
            else
                OptBtn.TextColor3 = Theme.TextDark
            end
            optionBtns[opt] = OptBtn
            local c3 = OptBtn.MouseEnter:Connect(function()
                if not IsSelected(opt) then
                    Tween(OptBtn, {BackgroundTransparency = 0.8, TextColor3 = Theme.Accent})
                end
            end)
            local c4 = OptBtn.MouseLeave:Connect(function()
                if not IsSelected(opt) then
                    Tween(OptBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark})
                end
            end)
            local c5 = OptBtn.MouseButton1Click:Connect(function()
                if isMulti then
                    local found = table.find(selected, opt)
                    if found then table.remove(selected, found) else table.insert(selected, opt) end
                    UpdateVisuals()
                    Library.Flags[flag] = selected
                    Library.Unsaved = true
                    callback(selected)
                else
                    selected = opt
                    UpdateVisuals()
                    Library.Flags[flag] = selected
                    Library.Unsaved = true
                    callback(selected)
                    CloseDropdown()
                end
            end)
            table.insert(Library.Connections, c3)
            table.insert(Library.Connections, c4)
            table.insert(Library.Connections, c5)
        end
    end
    BuildOptions(options)
    UpdateVisuals()
    Library.Signals[flag] = function(val)
        if isMulti then
            if type(val) == "table" then
                selected = val
            else
                selected = {val}
            end
        else
            selected = val
        end
        UpdateVisuals()
        Library.Unsaved = true
        callback(selected)
    end
    local c6 = Interactive.MouseButton1Click:Connect(function()
        isDropped = not isDropped
        if sectionRef and sectionRef.Container then sectionRef.Container.ZIndex = isDropped and 10 or 1 end
        DropFrame.ZIndex = isDropped and 10 or 5
        if customParent then customParent.ZIndex = isDropped and 10 or 1 customParent.ClipsDescendants = false end
        if isDropped then
            ListFrame.Visible = true
            local listH = math.min(#options * 24, 200)
            local totalH = 46 + listH + 5
            Tween(DropFrame, {Size = UDim2.new(1, customParent and -20 or 0, 0, totalH)}, 0.2)
            Tween(ListFrame, {Size = UDim2.new(1, 0, 0, listH)}, 0.2)
            Tween(Arrow, {Rotation = 180}, 0.2)
        else
            CloseDropdown()
        end
    end)
    table.insert(Library.Connections, c6)
    ApplyTooltip(DropFrame, tooltipText)
    task.spawn(callback, selected)
    local DropdownObj = {}
    DropdownObj.Frame = DropFrame
    function DropdownObj:Refresh(newOptions, newDefault)
        if isMulti then
            if type(newDefault) ~= "table" then selected = {newDefault} else selected = newDefault end
        else
            selected = newDefault or (newOptions[1] or "")
        end
        Library.Flags[flag] = selected
        BuildOptions(newOptions)
        UpdateVisuals()
    end
    function DropdownObj:GetSelected()
        return selected
    end
    function DropdownObj:Set(val)
        if isMulti then
            if type(val) == "table" then selected = val else selected = {val} end
        else
            selected = val
        end
        Library.Flags[flag] = selected
        UpdateVisuals()
        callback(selected)
    end
    return DropdownObj
end
local function CreateSliderElement(text, flag, min, max, default, increment, tooltipText, callback, parentFrame, secData)
    increment = increment or 1
    local val = Library.Flags[flag]
    if val == nil then
        val = default or min
    end
    val = RoundToIncrement(val, increment)
    Library.Defaults[flag] = val
    Library.Flags[flag] = val
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.BackgroundTransparency = 1
    Frame.Parent = parentFrame
    if secData then table.insert(secData.Items, {Name = text, Instance = Frame}) end
    local Label = Instance.new("TextLabel")
    Label.Text = text
    Label.Font = Config.FontMain
    Label.TextSize = 13
    Label.TextColor3 = Theme.Text
    Label.Size = UDim2.new(0.6, 0, 0, 16)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    local ValLabel = Instance.new("TextBox")
    ValLabel.Text = FormatNumber(val, increment)
    ValLabel.Font = Config.FontMain
    ValLabel.TextSize = 13
    ValLabel.TextColor3 = Theme.Text
    ValLabel.Size = UDim2.new(0.4, -5, 0, 16)
    ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValLabel.BackgroundTransparency = 1
    ValLabel.ClearTextOnFocus = true
    ValLabel.Parent = Frame
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.Position = UDim2.new(0, 0, 0, 24)
    Bar.BackgroundColor3 = Theme.Container
    Bar.Parent = Frame
    Corner(Bar, 3)
    Stroke(Bar, Theme.Stroke, 1, 0.5)
    local Fill = Instance.new("Frame")
    local range = max - min
    local ratio = range > 0 and (val - min) / range or 0
    Fill.Size = UDim2.new(ratio, 0, 1, 0)
    Fill.BackgroundColor3 = Theme.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Corner(Fill, 3)
    RegisterTheme(Fill, "BackgroundColor")
    local dragging = false
    local dragInput
    local function SetFromInput(input)
        local r = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * r
        val = RoundToIncrement(raw, increment)
        val = math.clamp(val, min, max)
        local displayRatio = range > 0 and (val - min) / range or 0
        ValLabel.Text = FormatNumber(val, increment)
        Tween(Fill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
        Library.Flags[flag] = val
        Library.Unsaved = true
        callback(val)
    end
    local c1 = Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            SetFromInput(input)
            local c2
            c2 = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    c2:Disconnect()
                end
            end)
        end
    end)
    local c3 = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    local c4 = RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            SetFromInput(dragInput)
        end
    end)
    table.insert(Library.Connections, c1)
    table.insert(Library.Connections, c3)
    table.insert(Library.Connections, c4)
    local c5 = ValLabel.FocusLost:Connect(function(enter)
        if enter then
            local cleanText = string.gsub(ValLabel.Text, "[^%d.-]", "")
            local num = tonumber(cleanText)
            if num then
                num = RoundToIncrement(num, increment)
                num = math.clamp(num, min, max)
                val = num
                local displayRatio = range > 0 and (val - min) / range or 0
                ValLabel.Text = FormatNumber(val, increment)
                Tween(Fill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                Library.Flags[flag] = val
                Library.Unsaved = true
                callback(val)
            else
                ValLabel.Text = FormatNumber(val, increment)
            end
        else
            ValLabel.Text = FormatNumber(val, increment)
        end
    end)
    table.insert(Library.Connections, c5)
    Library.Signals[flag] = function(loadedVal)
        val = RoundToIncrement(loadedVal, increment)
        val = math.clamp(val, min, max)
        local displayRatio = range > 0 and (val - min) / range or 0
        ValLabel.Text = FormatNumber(val, increment)
        Tween(Fill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
        Library.Unsaved = true
        callback(val)
    end
    ApplyTooltip(Frame, tooltipText)
    task.spawn(callback, val)
    return Frame
end
function Library:CreateWindow(options)
    if options and options.Name then Config.Name = options.Name end
    if options and options.ConfigFolder then Config.ConfigFolder = options.ConfigFolder end
    if not isfolder(Config.ConfigFolder) then makefolder(Config.ConfigFolder) end
    Library:Unload()
    Library:InitWatermark()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = Config.Name
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = GetParent()
    Library.ScreenGui = ScreenGui
    local MiniGui = Instance.new("ScreenGui")
    MiniGui.Name = "PhantomMiniButton"
    MiniGui.Parent = GetParent()
    MiniGui.Enabled = true
    MiniGui.IgnoreGuiInset = true
    local MiniButton = Instance.new("ImageButton")
    MiniButton.Size = UDim2.new(0, 46, 0, 46)
    MiniButton.Position = UDim2.new(0, 20, 0.5, -23)
    MiniButton.BackgroundColor3 = Theme.Background
    MiniButton.BackgroundTransparency = 0.1
    MiniButton.Image = "rbxassetid://112964043447417"
    MiniButton.ImageColor3 = Theme.Accent
    MiniButton.ScaleType = Enum.ScaleType.Fit
    MiniButton.AutoButtonColor = false
    MiniButton.Active = true
    MiniButton.Parent = MiniGui
    Corner(MiniButton, 23)
    Stroke(MiniButton, Theme.Accent, 2, 0.3)
    RegisterTheme(MiniButton, "ImageColor")
    local miniWasDragged = false
    MakeDraggable(MiniButton, MiniButton, function(wasDrag)
        miniWasDragged = wasDrag
    end)
    local c1 = MiniButton.MouseButton1Click:Connect(function()
        if miniWasDragged then
            miniWasDragged = false
            return
        end
        if Library.Open then
            Library.Open = false
            if Library._IsSettings then
                Tween(Library._SetScale, {Scale = GetBaseScale() * 0.8}, 0.2).Completed:Wait()
            else
                Tween(Library._MainScale, {Scale = GetBaseScale() * 0.8}, 0.2).Completed:Wait()
            end
            Library._MainWindow.Visible = false
            Library._SettingsWindow.Visible = false
            TooltipLabel.Visible = false
        else
            Library.Open = true
            if Library._IsSettings then
                Library._SettingsWindow.Visible = true
                Library._SettingsWindow.BackgroundTransparency = 0.1
                Library._SetScale.Scale = GetBaseScale() * 0.8
                Tween(Library._SetScale, {Scale = GetBaseScale()}, 0.3)
            else
                Library._MainWindow.Visible = true
                Library._MainWindow.BackgroundTransparency = 0.1
                Library._MainScale.Scale = GetBaseScale() * 0.8
                Tween(Library._MainScale, {Scale = GetBaseScale()}, 0.3)
            end
        end
    end)
    table.insert(Library.Connections, c1)
    local function CreateBaseFrame(name)
        local Frame = Instance.new("Frame")
        Frame.Name = name
        Frame.Size = UDim2.new(0, 650, 0, 400)
        Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        Frame.BackgroundColor3 = Theme.Background
        Frame.BackgroundTransparency = 0.1
        Frame.BorderSizePixel = 0
        Frame.ClipsDescendants = false
        Frame.Visible = false
        Frame.Parent = ScreenGui
        Frame.Active = true
        local SizeConstraint = Instance.new("UISizeConstraint")
        SizeConstraint.MaxSize = Vector2.new(1400, 900)
        SizeConstraint.MinSize = Vector2.new(450, 300)
        SizeConstraint.Parent = Frame
        Corner(Frame, 6)
        Stroke(Frame, Theme.Stroke, 1, 0)
        local BgNoise = Instance.new("ImageLabel")
        BgNoise.Size = UDim2.new(1, 0, 1, 0)
        BgNoise.BackgroundTransparency = 1
        BgNoise.Image = "rbxassetid://9968344105"
        BgNoise.ImageTransparency = 0.9
        BgNoise.ScaleType = Enum.ScaleType.Tile
        BgNoise.TileSize = UDim2.new(0, 100, 0, 100)
        BgNoise.Parent = Frame
        Corner(BgNoise, 6)
        local DragHeader = Instance.new("Frame")
        DragHeader.Name = "DragHeader"
        DragHeader.Size = UDim2.new(0, 180, 0, 60)
        DragHeader.BackgroundTransparency = 1
        DragHeader.Parent = Frame
        local Scale = Instance.new("UIScale")
        Scale.Scale = 1
        Scale.Parent = Frame
        MakeDraggable(DragHeader, Frame)
        return Frame, Scale
    end
    local MainWindow, MainScale = CreateBaseFrame("MainWindow")
    local SettingsWindow, SetScale = CreateBaseFrame("SettingsWindow")
    Library._MainWindow = MainWindow
    Library._MainScale = MainScale
    Library._SettingsWindow = SettingsWindow
    Library._SetScale = SetScale
    Library._IsSettings = false
    local Resizer = Instance.new("Frame")
    Resizer.Size = UDim2.new(0, 20, 0, 20)
    Resizer.Position = UDim2.new(1, 0, 1, 0)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.BackgroundTransparency = 1
    Resizer.Parent = MainWindow
    Resizer.ZIndex = 20
    Resizer.Active = true
    local ResizerIcon = Instance.new("TextLabel")
    ResizerIcon.Size = UDim2.new(1, 0, 1, 0)
    ResizerIcon.BackgroundTransparency = 1
    ResizerIcon.Text = "◢"
    ResizerIcon.TextColor3 = Theme.TextDark
    ResizerIcon.TextSize = 16
    ResizerIcon.Parent = Resizer
    local c2 = Resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ResizerIcon, {TextColor3 = Theme.Accent}) end
    end)
    local c3 = Resizer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then Tween(ResizerIcon, {TextColor3 = Theme.TextDark}) end
    end)
    table.insert(Library.Connections, c2)
    table.insert(Library.Connections, c3)
    MakeResizable(Resizer, MainWindow, Vector2.new(450, 300))
    local function CreateSidebar(parent, isSettings)
        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 180, 1, 0)
        Bar.BackgroundColor3 = Theme.Sidebar
        Bar.BorderSizePixel = 0
        Bar.Parent = parent
        Bar.Active = true
        Corner(Bar, 6)
        local Div = Instance.new("Frame")
        Div.Size = UDim2.new(0, 1, 1, 0)
        Div.Position = UDim2.new(1, 0, 0, 0)
        Div.BackgroundColor3 = Theme.Stroke
        Div.BorderSizePixel = 0
        Div.Parent = Bar
        if isSettings then
            local BackBtn = Instance.new("TextButton")
            BackBtn.Size = UDim2.new(1, -20, 0, 30)
            BackBtn.Position = UDim2.new(0, 10, 0, 15)
            BackBtn.BackgroundColor3 = Theme.Container
            BackBtn.Text = " < Back to Menu"
            BackBtn.Font = Config.FontBold
            BackBtn.TextSize = 13
            BackBtn.TextColor3 = Theme.TextDark
            BackBtn.TextXAlignment = Enum.TextXAlignment.Left
            BackBtn.AutoButtonColor = false
            BackBtn.Parent = Bar
            Corner(BackBtn, 4)
            Stroke(BackBtn, Theme.Stroke, 1, 0.5)
            local c4 = BackBtn.MouseEnter:Connect(function() Tween(BackBtn, {TextColor3 = Theme.Accent}) end)
            local c5 = BackBtn.MouseLeave:Connect(function() Tween(BackBtn, {TextColor3 = Theme.TextDark}) end)
            table.insert(Library.Connections, c4)
            table.insert(Library.Connections, c5)
            local Title = Instance.new("TextLabel")
            Title.Text = "Settings"
            Title.Size = UDim2.new(1, 0, 0, 30)
            Title.Position = UDim2.new(0, 0, 0, 55)
            Title.Font = Config.FontBold
            Title.TextSize = 22
            Title.TextColor3 = Theme.Text
            Title.BackgroundTransparency = 1
            Title.Parent = Bar
            return Bar, nil, BackBtn
        else
            local Logo = Instance.new("TextLabel")
            Logo.Text = Config.Name
            Logo.RichText = true
            Logo.Position = UDim2.new(0, 15, 0, 20)
            Logo.Size = UDim2.new(1, -30, 0, 30)
            Logo.Font = Config.FontBold
            Logo.TextSize = 20
            Logo.TextColor3 = Theme.Accent
            Logo.TextXAlignment = Enum.TextXAlignment.Left
            Logo.BackgroundTransparency = 1
            Logo.Parent = Bar
            RegisterTheme(Logo, "TextColor")
            local Container = Instance.new("ScrollingFrame")
            Container.Size = UDim2.new(1, 0, 1, -130)
            Container.Position = UDim2.new(0, 0, 0, 60)
            Container.BackgroundTransparency = 1
            Container.BorderSizePixel = 0
            Container.ScrollBarThickness = 2
            Container.ScrollBarImageColor3 = Theme.Accent
            Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Container.ClipsDescendants = true
            Container.Parent = Bar
            RegisterTheme(Container, "ScrollBar")
            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 6)
            List.HorizontalAlignment = Enum.HorizontalAlignment.Center
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Container
            return Bar, Container, nil
        end
    end
    local MainBar, TabContainer, _ = CreateSidebar(MainWindow, false)
    local SetBar, SetContainer, BackBtn = CreateSidebar(SettingsWindow, true)
    local ProfileBtn = Instance.new("TextButton")
    ProfileBtn.Size = UDim2.new(1, 0, 0, 60)
    ProfileBtn.Position = UDim2.new(0, 0, 1, 0)
    ProfileBtn.AnchorPoint = Vector2.new(0, 1)
    ProfileBtn.BackgroundColor3 = Theme.Sidebar
    ProfileBtn.BorderSizePixel = 0
    ProfileBtn.Text = ""
    ProfileBtn.AutoButtonColor = false
    ProfileBtn.Parent = MainBar
    local SideAvatar = Instance.new("ImageLabel")
    SideAvatar.Size = UDim2.new(0, 36, 0, 36)
    SideAvatar.Position = UDim2.new(0, 15, 0.5, 0)
    SideAvatar.AnchorPoint = Vector2.new(0, 0.5)
    SideAvatar.BackgroundColor3 = Theme.Container
    local s2, av2 = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    SideAvatar.Image = s2 and av2 or "rbxassetid://0"
    SideAvatar.Parent = ProfileBtn
    Corner(SideAvatar, 18)
    local AvS = Stroke(SideAvatar, Theme.Accent, 1)
    RegisterTheme(AvS, "BorderColor")
    local SideName = Instance.new("TextLabel")
    SideName.Size = UDim2.new(0, 100, 0, 16)
    SideName.Position = UDim2.new(0, 60, 0.5, -9)
    SideName.AnchorPoint = Vector2.new(0, 0.5)
    SideName.BackgroundTransparency = 1
    SideName.Text = LocalPlayer.Name
    SideName.TextColor3 = Theme.Text
    SideName.Font = Config.FontBold
    SideName.TextSize = 13
    SideName.TextXAlignment = Enum.TextXAlignment.Left
    SideName.Parent = ProfileBtn
    local SideSub = Instance.new("TextLabel")
    SideSub.Size = UDim2.new(0, 100, 0, 14)
    SideSub.Position = UDim2.new(0, 60, 0.5, 9)
    SideSub.AnchorPoint = Vector2.new(0, 0.5)
    SideSub.BackgroundTransparency = 1
    SideSub.Text = "Settings"
    SideSub.TextColor3 = Theme.TextDark
    SideSub.Font = Config.FontMain
    SideSub.TextSize = 11
    SideSub.TextXAlignment = Enum.TextXAlignment.Left
    SideSub.Parent = ProfileBtn
    local IsSettings = false
    local animating = false
    local function ToggleMain()
        if animating then return end
        animating = true
        Library.Open = not Library.Open
        if Library.Open then
            if IsSettings then
                SettingsWindow.Visible = true
                SettingsWindow.BackgroundTransparency = 0.1
                SetScale.Scale = GetBaseScale() * 0.8
                Tween(SetScale, {Scale = GetBaseScale()}, 0.3).Completed:Wait()
            else
                MainWindow.Visible = true
                MainWindow.BackgroundTransparency = 0.1
                MainScale.Scale = GetBaseScale() * 0.8
                Tween(MainScale, {Scale = GetBaseScale()}, 0.3).Completed:Wait()
            end
        else
            if IsSettings then
                Tween(SetScale, {Scale = GetBaseScale() * 0.8}, 0.2).Completed:Wait()
            else
                Tween(MainScale, {Scale = GetBaseScale() * 0.8}, 0.2).Completed:Wait()
            end
            MainWindow.Visible = false
            SettingsWindow.Visible = false
            TooltipLabel.Visible = false
        end
        animating = false
    end
    local function SwitchToSettings()
        if animating then return end
        animating = true
        SettingsWindow.Position = MainWindow.Position
        SettingsWindow.Size = MainWindow.Size
        Tween(MainScale, {Scale = GetBaseScale() * 0.9}, 0.15).Completed:Wait()
        MainWindow.Visible = false
        SettingsWindow.Visible = true
        SettingsWindow.BackgroundTransparency = 0.1
        SetScale.Scale = GetBaseScale() * 0.9
        Tween(SetScale, {Scale = GetBaseScale()}, 0.2).Completed:Wait()
        IsSettings = true
        Library._IsSettings = true
        animating = false
    end
    local function SwitchToMain()
        if animating then return end
        animating = true
        MainWindow.Position = SettingsWindow.Position
        MainWindow.Size = SettingsWindow.Size
        Tween(SetScale, {Scale = GetBaseScale() * 0.9}, 0.15).Completed:Wait()
        SettingsWindow.Visible = false
        MainWindow.Visible = true
        MainWindow.BackgroundTransparency = 0.1
        MainScale.Scale = GetBaseScale() * 0.9
        Tween(MainScale, {Scale = GetBaseScale()}, 0.2).Completed:Wait()
        IsSettings = false
        Library._IsSettings = false
        animating = false
    end
    local c6 = ProfileBtn.MouseButton1Click:Connect(function() task.spawn(SwitchToSettings) end)
    local c7 = BackBtn.MouseButton1Click:Connect(function() task.spawn(SwitchToMain) end)
    table.insert(Library.Connections, c6)
    table.insert(Library.Connections, c7)
    local c8 = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if Library.Open then
            if IsSettings and SettingsWindow.Visible then
                SetScale.Scale = GetBaseScale()
            elseif not IsSettings and MainWindow.Visible then
                MainScale.Scale = GetBaseScale()
            end
        end
    end)
    table.insert(Library.Connections, c8)
    local MenuBindConnection = UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Config.Keybind then
            task.spawn(ToggleMain)
        end
    end)
    table.insert(Library.Connections, MenuBindConnection)
    local WindowObj = {}
    local MainPages = Instance.new("Frame")
    MainPages.Size = UDim2.new(1, -181, 1, 0)
    MainPages.Position = UDim2.new(0, 181, 0, 0)
    MainPages.BackgroundTransparency = 1
    MainPages.Parent = MainWindow
    function WindowObj:CreateRawSection(text, parent)
        local Section = {}
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.BackgroundColor3 = Theme.Section
        Container.Parent = parent
        Container.ZIndex = 1
        Corner(Container, 6)
        Stroke(Container, Theme.Stroke, 1, 0.5)
        Section.Container = Container
        local Title = Instance.new("TextLabel")
        Title.Text = text
        Title.Font = Config.FontBold
        Title.TextSize = 12
        Title.TextColor3 = Theme.TextDark
        Title.Size = UDim2.new(1, -20, 0, 30)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Container
        local Content = Instance.new("Frame")
        Content.Name = "Content"
        Content.Size = UDim2.new(1, -10, 0, 0)
        Content.Position = UDim2.new(0, 5, 0, 30)
        Content.BackgroundTransparency = 1
        Content.Parent = Container
        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 6)
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Content
        local lc1 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 40)
        end)
        table.insert(Library.Connections, lc1)
        function Section:Label(ltext, options)
            options = options or {}
            local LabelObj = {}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 26)
            Frame.BackgroundColor3 = Theme.Container
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Content
            Corner(Frame, 4)
            Stroke(Frame, Theme.Stroke, 1, 0.5)
            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -10, 1, -10)
            Lbl.Position = UDim2.new(0, 5, 0, 5)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = tostring(ltext)
            Lbl.Font = Config.FontMain
            Lbl.TextSize = 13
            Lbl.TextColor3 = options.Color or Theme.Text
            Lbl.TextXAlignment = options.Alignment or Enum.TextXAlignment.Left
            Lbl.TextYAlignment = Enum.TextYAlignment.Top
            Lbl.RichText = true
            Lbl.TextWrapped = true
            Lbl.Parent = Frame
            local function UpdateHeight()
                local textHeight = Lbl.TextBounds.Y
                if textHeight > 16 then Frame.Size = UDim2.new(1, 0, 0, textHeight + 10) else Frame.Size = UDim2.new(1, 0, 0, 26) end
            end
            local boundsConn = Lbl:GetPropertyChangedSignal("TextBounds"):Connect(UpdateHeight)
            table.insert(Library.Connections, boundsConn)
            UpdateHeight()
            function LabelObj:Set(newText) Lbl.Text = tostring(newText) end
            function LabelObj:SetColor(newColor) Lbl.TextColor3 = newColor end
            return LabelObj
        end
        function Section:Button(text, tooltipText, callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Theme.Container
            Btn.Text = text
            Btn.Font = Config.FontMain
            Btn.TextSize = 13
            Btn.TextColor3 = Theme.Text
            Btn.AutoButtonColor = false
            Btn.Parent = Content
            Corner(Btn, 4)
            local s = Stroke(Btn, Theme.Stroke, 1, 0.5)
            local bc1 = Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Stroke}) Tween(s, {Color = Theme.Accent}) end)
            local bc2 = Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Container}) Tween(s, {Color = Theme.Stroke}) end)
            local bc3 = Btn.MouseButton1Click:Connect(callback)
            table.insert(Library.Connections, bc1)
            table.insert(Library.Connections, bc2)
            table.insert(Library.Connections, bc3)
            ApplyTooltip(Btn, tooltipText)
            return Btn
        end
        function Section:Toggle(text, flag, default, tooltipText, callback)
            Library.Defaults[flag] = default or false
            local toggled = Library.Flags[flag]
            if toggled == nil then
                toggled = default or false
                Library.Flags[flag] = toggled
            end
            local ToggleObj = {}
            Library.Signals[flag] = function(val)
                if toggled ~= val then
                    toggled = val
                    if ToggleObj.UpdateAnim then ToggleObj.UpdateAnim() end
                    Library.Unsaved = true
                    callback(val)
                end
            end
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Theme.Container
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = Content
            Corner(Btn, 4)
            Stroke(Btn, Theme.Stroke, 1, 0.5)
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Config.FontMain
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Btn
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 18, 0, 18)
            Box.Position = UDim2.new(1, -10, 0.5, 0)
            Box.AnchorPoint = Vector2.new(1, 0.5)
            Box.BackgroundColor3 = Theme.Background
            Box.Parent = Btn
            Corner(Box, 4)
            Stroke(Box, Theme.Stroke, 1, 0.5)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(1, -4, 1, -4)
            Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
            Fill.AnchorPoint = Vector2.new(0.5, 0.5)
            Fill.BackgroundColor3 = Theme.Accent
            Fill.BackgroundTransparency = toggled and 0 or 1
            Fill.Parent = Box
            Corner(Fill, 3)
            RegisterTheme(Fill, "BackgroundColor")
            local SubContainer = Instance.new("Frame")
            SubContainer.Name = "Sub_" .. text
            SubContainer.Size = UDim2.new(1, 0, 0, 0)
            SubContainer.BackgroundTransparency = 1
            SubContainer.ClipsDescendants = true
            SubContainer.Visible = false
            SubContainer.Parent = Content
            local SubList = Instance.new("UIListLayout")
            SubList.Padding = UDim.new(0, 6)
            SubList.SortOrder = Enum.SortOrder.LayoutOrder
            SubList.Parent = SubContainer
            local currentTween = nil
            local function ToggleAnim()
                if currentTween then currentTween:Cancel() end
                Tween(Fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                Library.Flags[flag] = toggled
                if ToggleObj.KeybindValue then
                    Library:UpdateKeybindList(text, ToggleObj.KeybindValue.Name, toggled, ToggleObj.KeybindMode)
                end
                if toggled then
                    SubContainer.Visible = true
                    SubContainer.ClipsDescendants = true
                    local h = SubList.AbsoluteContentSize.Y
                    if h > 0 then h = h + 6 end
                    currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, h)})
                    currentTween:Play()
                    local tc
                    tc = currentTween.Completed:Connect(function(state)
                        if state == Enum.PlaybackState.Completed and toggled then SubContainer.ClipsDescendants = false end
                        tc:Disconnect()
                    end)
                else
                    SubContainer.ClipsDescendants = true
                    currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                    currentTween:Play()
                    local expectedToggle = toggled
                    local tc
                    tc = currentTween.Completed:Connect(function(playbackState)
                        if playbackState == Enum.PlaybackState.Completed and expectedToggle == toggled and not toggled then SubContainer.Visible = false end
                        tc:Disconnect()
                    end)
                end
            end
            ToggleObj.UpdateAnim = ToggleAnim
            local tlc1 = SubList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if toggled then
                    local h = SubList.AbsoluteContentSize.Y
                    if h > 0 then h = h + 6 end
                    SubContainer.Size = UDim2.new(1, 0, 0, h)
                end
            end)
            table.insert(Library.Connections, tlc1)
            local tlc2 = Btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                Library.Unsaved = true
                ToggleAnim()
                callback(toggled)
            end)
            table.insert(Library.Connections, tlc2)
            if toggled then ToggleAnim() end
            ApplyTooltip(Btn, tooltipText)
            task.spawn(callback, toggled)
            return ToggleObj
        end
        function Section:TextBox(text, flag, placeholder, tooltipText, callback)
            Library.Defaults[flag] = ""
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 50)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Content
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Config.FontMain
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Frame
            local BoxCont = Instance.new("Frame")
            BoxCont.Size = UDim2.new(1, 0, 0, 28)
            BoxCont.Position = UDim2.new(0, 0, 0, 22)
            BoxCont.BackgroundColor3 = Theme.Container
            BoxCont.Parent = Frame
            Corner(BoxCont, 4)
            Stroke(BoxCont, Theme.Stroke, 1, 0.5)
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -10, 1, 0)
            Input.Position = UDim2.new(0, 5, 0, 0)
            Input.BackgroundTransparency = 1
            Input.TextColor3 = Theme.Text
            Input.PlaceholderText = placeholder
            Input.PlaceholderColor3 = Theme.TextDark
            Input.Font = Config.FontMain
            Input.TextSize = 13
            Input.TextXAlignment = Enum.TextXAlignment.Left
            local currentText = Library.Flags[flag] or ""
            Input.Text = currentText
            Input.ClearTextOnFocus = false
            Input.Parent = BoxCont
            local ic1 = Input.FocusLost:Connect(function(enter)
                if enter then
                    Library.Flags[flag] = Input.Text
                    Library.Unsaved = true
                    callback(Input.Text)
                end
            end)
            local ic2 = Input.Changed:Connect(function(prop)
                if prop == "Text" then Library.Flags[flag] = Input.Text end
            end)
            table.insert(Library.Connections, ic1)
            table.insert(Library.Connections, ic2)
            Library.Flags[flag] = currentText
            Library.Signals[flag] = function(val)
                Input.Text = val
                Library.Unsaved = true
                callback(val)
            end
            ApplyTooltip(Frame, tooltipText)
            task.spawn(callback, currentText)
            return Input
        end
        function Section:Dropdown(text, flag, options, default, tooltipText, callback, customParent, isMulti)
            return CreateDropdownElement(text, flag, options, default, tooltipText, callback, Content, Section, isMulti, customParent)
        end
        function Section:ColorPicker(text, flag, default, tooltipText, callback)
            local color = Library.Flags[flag] or default or Color3.fromRGB(255, 255, 255)
            Library.Defaults[flag] = default or Color3.fromRGB(255, 255, 255)
            Library.Flags[flag] = color
            local h, s, v = color:ToHSV()
            local isOpen = false
            local ContainerFrame = Instance.new("Frame")
            ContainerFrame.Size = UDim2.new(1, 0, 0, 30)
            ContainerFrame.BackgroundTransparency = 1
            ContainerFrame.Parent = Content
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 30)
            Frame.BackgroundTransparency = 1
            Frame.Parent = ContainerFrame
            Frame.ZIndex = 5
            local Label = Instance.new("TextLabel")
            Label.Text = text
            Label.Font = Config.FontMain
            Label.TextSize = 13
            Label.TextColor3 = Theme.Text
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Frame
            local Preview = Instance.new("TextButton")
            Preview.Size = UDim2.new(0, 40, 0, 20)
            Preview.Position = UDim2.new(1, -5, 0.5, 0)
            Preview.AnchorPoint = Vector2.new(1, 0.5)
            Preview.BackgroundColor3 = color
            Preview.AutoButtonColor = false
            Preview.Text = ""
            Preview.Parent = Frame
            Corner(Preview, 4)
            Stroke(Preview, Theme.Stroke, 1, 0.5)
            local PickerCont = Instance.new("Frame")
            PickerCont.Size = UDim2.new(1, 0, 0, 0)
            PickerCont.Position = UDim2.new(0, 0, 0, 30)
            PickerCont.BackgroundColor3 = Theme.Background
            PickerCont.Parent = ContainerFrame
            PickerCont.ClipsDescendants = true
            PickerCont.Visible = false
            PickerCont.ZIndex = 10
            Corner(PickerCont, 4)
            local SVMap = Instance.new("ImageLabel")
            SVMap.Size = UDim2.new(0, 140, 0, 120)
            SVMap.Position = UDim2.new(0, 10, 0, 10)
            SVMap.Image = "rbxassetid://4155801252"
            SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVMap.Parent = PickerCont
            SVMap.ZIndex = 11
            SVMap.Active = true
            Corner(SVMap, 4)
            local SVCursor = Instance.new("Frame")
            SVCursor.Size = UDim2.new(0, 8, 0, 8)
            SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
            SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            SVCursor.Parent = SVMap
            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
            SVCursor.ZIndex = 12
            Corner(SVCursor, 4)
            local HueBar = Instance.new("ImageLabel")
            HueBar.Size = UDim2.new(0, 20, 0, 120)
            HueBar.Position = UDim2.new(0, 160, 0, 10)
            HueBar.Image = "rbxassetid://4155801252"
            HueBar.Parent = PickerCont
            HueBar.ZIndex = 11
            HueBar.Active = true
            Corner(HueBar, 4)
            local UIGradient = Instance.new("UIGradient")
            UIGradient.Rotation = 90
            UIGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            UIGradient.Parent = HueBar
            local HCursor = Instance.new("Frame")
            HCursor.Size = UDim2.new(1, 0, 0, 2)
            HCursor.BackgroundColor3 = Color3.new(1, 1, 1)
            HCursor.Parent = HueBar
            HCursor.Position = UDim2.new(0, 0, h, 0)
            HCursor.ZIndex = 12
            local HexInput = Instance.new("TextBox")
            HexInput.Size = UDim2.new(0, 170, 0, 20)
            HexInput.Position = UDim2.new(0, 10, 0, 140)
            HexInput.BackgroundColor3 = Theme.Container
            HexInput.TextColor3 = Theme.Text
            HexInput.Font = Config.FontMain
            HexInput.TextSize = 12
            HexInput.Text = "#" .. color:ToHex()
            HexInput.Parent = PickerCont
            HexInput.ZIndex = 11
            Corner(HexInput, 4)
            Stroke(HexInput, Theme.Stroke, 1)
            local function Update()
                color = Color3.fromHSV(h, s, v)
                Preview.BackgroundColor3 = color
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                HexInput.Text = "#" .. color:ToHex()
                Library.Flags[flag] = color
                Library.Unsaved = true
                callback(color)
            end
            local hc1 = HexInput.FocusLost:Connect(function()
                local t = HexInput.Text:gsub("#", "")
                if t:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                    pcall(function()
                        local nc = Color3.fromHex(t)
                        h, s, v = nc:ToHSV()
                        HCursor.Position = UDim2.new(0, 0, h, 0)
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        Update()
                    end)
                else
                    HexInput.Text = "#" .. color:ToHex()
                end
            end)
            table.insert(Library.Connections, hc1)
            Library.Signals[flag] = function(val)
                if typeof(val) == "Color3" then
                    color = val
                    h, s, v = color:ToHSV()
                    HCursor.Position = UDim2.new(0, 0, h, 0)
                    SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    Update()
                end
            end
            local function SetSV(input)
                local rX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                local rY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                s = rX
                v = 1 - rY
                SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                Update()
            end
            local function SetH(input)
                local rY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                h = rY
                HCursor.Position = UDim2.new(0, 0, h, 0)
                Update()
            end
            local dragSV = false
            local dragInputSV
            local sv1 = SVMap.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragSV = true
                    dragInputSV = input
                    SetSV(input)
                    local sc2
                    sc2 = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragSV = false
                            sc2:Disconnect()
                        end
                    end)
                end
            end)
            local sv3 = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if dragSV then dragInputSV = input end
                end
            end)
            local sv4 = RunService.RenderStepped:Connect(function()
                if dragSV and dragInputSV then SetSV(dragInputSV) end
            end)
            table.insert(Library.Connections, sv1)
            table.insert(Library.Connections, sv3)
            table.insert(Library.Connections, sv4)
            local dragH = false
            local dragInputH
            local h1 = HueBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragH = true
                    dragInputH = input
                    SetH(input)
                    local hc2
                    hc2 = input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragH = false
                            hc2:Disconnect()
                        end
                    end)
                end
            end)
            local h3 = UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                    if dragH then dragInputH = input end
                end
            end)
            local h4 = RunService.RenderStepped:Connect(function()
                if dragH and dragInputH then SetH(dragInputH) end
            end)
            table.insert(Library.Connections, h1)
            table.insert(Library.Connections, h3)
            table.insert(Library.Connections, h4)
            local pc1 = Preview.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                Section.Container.ZIndex = isOpen and 10 or 1
                ContainerFrame.ZIndex = isOpen and 10 or 5
                if isOpen then
                    PickerCont.Visible = true
                    Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                    Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                else
                    Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                    local t = Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    local pc2
                    pc2 = t.Completed:Connect(function()
                        if not isOpen then PickerCont.Visible = false end
                        pc2:Disconnect()
                    end)
                end
            end)
            table.insert(Library.Connections, pc1)
            ApplyTooltip(ContainerFrame, tooltipText)
            task.spawn(callback, color)
        end
        return Section
    end
    local function PopulateSettings()
        local SetPage = Instance.new("ScrollingFrame")
        SetPage.Size = UDim2.new(1, -200, 1, -20)
        SetPage.Position = UDim2.new(0, 190, 0, 10)
        SetPage.BackgroundTransparency = 1
        SetPage.ScrollBarThickness = 2
        SetPage.ScrollBarImageColor3 = Theme.Accent
        SetPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        SetPage.Active = true
        SetPage.Parent = SettingsWindow
        RegisterTheme(SetPage, "ScrollBar")
        local ListLayout = Instance.new("UIListLayout")
        ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ListLayout.Padding = UDim.new(0, 10)
        ListLayout.Parent = SetPage
        local MenuSec = WindowObj:CreateRawSection("Menu Settings", SetPage)
        MenuSec:Button("Unload UI", "Destroys the Hub", function()
            Library:Unload()
        end)
        local keybindBtn
        keybindBtn = MenuSec:Button("Menu Keybind: " .. tostring(Config.Keybind.Name), "Change the open/close key", function()
            keybindBtn.Text = "Press any key..."
            local conn
            conn = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                        Config.Keybind = Enum.KeyCode.LeftControl
                    elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                        Config.Keybind = input.KeyCode
                    end
                    keybindBtn.Text = "Menu Keybind: " .. tostring(Config.Keybind.Name)
                    Library:Notify("Settings", "Menu keybind set to " .. tostring(Config.Keybind.Name), 2)
                    conn:Disconnect()
                end
            end)
        end)
        MenuSec:Toggle("Show Keybind List", "KeybindListToggle", true, "Show the active keybinds widget", function(state)
            Library.ShowKeybinds = state
            if Library.KeybindList then
                Library.KeybindList.Frame.Visible = state and (#Library.KeybindList.Container:GetChildren() > 1)
            end
        end)
        MenuSec:ColorPicker("Accent Color", "MenuAccentColor", Theme.Accent, "Change the theme color", function(col)
            Library:UpdateTheme(col)
        end)
        local ConfigSec = WindowObj:CreateRawSection("Configuration", SetPage)
        local ConfigContent = ConfigSec.Container:FindFirstChild("Content")
        local configNameInput = ""
        local selectedConfigName = ""
        local ConfigList = Library:GetConfigs()
        local CNameFrame = Instance.new("Frame")
        CNameFrame.Size = UDim2.new(1, 0, 0, 50)
        CNameFrame.BackgroundTransparency = 1
        CNameFrame.LayoutOrder = 1
        CNameFrame.Parent = ConfigContent
        local CNameLabel = Instance.new("TextLabel")
        CNameLabel.Text = "Config Name"
        CNameLabel.Font = Config.FontMain
        CNameLabel.TextSize = 13
        CNameLabel.TextColor3 = Theme.Text
        CNameLabel.Size = UDim2.new(1, 0, 0, 20)
        CNameLabel.Position = UDim2.new(0, 5, 0, 0)
        CNameLabel.TextXAlignment = Enum.TextXAlignment.Left
        CNameLabel.BackgroundTransparency = 1
        CNameLabel.Parent = CNameFrame
        local CNameBoxCont = Instance.new("Frame")
        CNameBoxCont.Size = UDim2.new(1, 0, 0, 28)
        CNameBoxCont.Position = UDim2.new(0, 0, 0, 22)
        CNameBoxCont.BackgroundColor3 = Theme.Container
        CNameBoxCont.Parent = CNameFrame
        Corner(CNameBoxCont, 4)
        Stroke(CNameBoxCont, Theme.Stroke, 1, 0.5)
        local CNameInput = Instance.new("TextBox")
        CNameInput.Size = UDim2.new(1, -10, 1, 0)
        CNameInput.Position = UDim2.new(0, 5, 0, 0)
        CNameInput.BackgroundTransparency = 1
        CNameInput.TextColor3 = Theme.Text
        CNameInput.PlaceholderText = "Type config name..."
        CNameInput.PlaceholderColor3 = Theme.TextDark
        CNameInput.Font = Config.FontMain
        CNameInput.TextSize = 13
        CNameInput.TextXAlignment = Enum.TextXAlignment.Left
        CNameInput.Text = ""
        CNameInput.ClearTextOnFocus = false
        CNameInput.Parent = CNameBoxCont
        local c2 = CNameInput:GetPropertyChangedSignal("Text"):Connect(function()
            configNameInput = CNameInput.Text
        end)
        table.insert(Library.Connections, c2)
        local ConfigDropdownFrame = Instance.new("Frame")
        ConfigDropdownFrame.Size = UDim2.new(1, 0, 0, 46)
        ConfigDropdownFrame.BackgroundTransparency = 1
        ConfigDropdownFrame.LayoutOrder = 2
        ConfigDropdownFrame.Parent = ConfigContent
        local CDLabel = Instance.new("TextLabel")
        CDLabel.Text = "Select Config"
        CDLabel.Font = Config.FontMain
        CDLabel.TextSize = 13
        CDLabel.TextColor3 = Theme.Text
        CDLabel.Size = UDim2.new(1, 0, 0, 16)
        CDLabel.Position = UDim2.new(0, 5, 0, 0)
        CDLabel.TextXAlignment = Enum.TextXAlignment.Left
        CDLabel.BackgroundTransparency = 1
        CDLabel.Parent = ConfigDropdownFrame
        local CDInteractive = Instance.new("TextButton")
        CDInteractive.Size = UDim2.new(1, 0, 0, 26)
        CDInteractive.Position = UDim2.new(0, 0, 0, 20)
        CDInteractive.BackgroundColor3 = Theme.Container
        CDInteractive.Text = ""
        CDInteractive.AutoButtonColor = false
        CDInteractive.Parent = ConfigDropdownFrame
        CDInteractive.ZIndex = 5
        Corner(CDInteractive, 4)
        Stroke(CDInteractive, Theme.Stroke, 1, 0.5)
        local CDSelectedText = Instance.new("TextLabel")
        CDSelectedText.Font = Config.FontMain
        CDSelectedText.TextSize = 13
        CDSelectedText.TextColor3 = Theme.Text
        CDSelectedText.Size = UDim2.new(1, -25, 1, 0)
        CDSelectedText.Position = UDim2.new(0, 8, 0, 0)
        CDSelectedText.TextXAlignment = Enum.TextXAlignment.Left
        CDSelectedText.BackgroundTransparency = 1
        CDSelectedText.ZIndex = 6
        CDSelectedText.ClipsDescendants = false
        CDSelectedText.TextTruncate = Enum.TextTruncate.AtEnd
        CDSelectedText.Parent = CDInteractive
        local CDArrow = Instance.new("ImageLabel")
        CDArrow.Image = "rbxassetid://10709790948"
        CDArrow.Size = UDim2.new(0, 18, 0, 18)
        CDArrow.Position = UDim2.new(1, -20, 0.5, 0)
        CDArrow.AnchorPoint = Vector2.new(0, 0.5)
        CDArrow.BackgroundTransparency = 1
        CDArrow.ImageColor3 = Theme.TextDark
        CDArrow.Parent = CDInteractive
        CDArrow.ZIndex = 6
        local CDListFrame = Instance.new("ScrollingFrame")
        CDListFrame.Size = UDim2.new(1, 0, 0, 0)
        CDListFrame.Position = UDim2.new(0, 0, 1, 5)
        CDListFrame.BackgroundColor3 = Theme.Container
        CDListFrame.BorderSizePixel = 0
        CDListFrame.Parent = CDInteractive
        CDListFrame.ZIndex = 10
        CDListFrame.Visible = false
        CDListFrame.Active = true
        CDListFrame.ScrollBarThickness = 2
        CDListFrame.ScrollBarImageColor3 = Theme.Accent
        CDListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Corner(CDListFrame, 4)
        Stroke(CDListFrame, Theme.Stroke, 1, 0.5)
        local CDIList = Instance.new("UIListLayout")
        CDIList.SortOrder = Enum.SortOrder.LayoutOrder
        CDIList.Parent = CDListFrame
        local cdIsDropped = false
        local cdOptionBtns = {}
        selectedConfigName = #ConfigList > 0 and ConfigList[1] or ""
        CDSelectedText.Text = selectedConfigName ~= "" and selectedConfigName or "No configs"
        local function CDCloseDropdown()
            cdIsDropped = false
            ConfigSec.Container.ZIndex = 1
            ConfigDropdownFrame.ZIndex = 5
            Tween(ConfigDropdownFrame, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
            local t = Tween(CDListFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Tween(CDArrow, {Rotation = 0}, 0.2)
            local c4
            c4 = t.Completed:Connect(function()
                if not cdIsDropped then CDListFrame.Visible = false end
                c4:Disconnect()
            end)
        end
        local function CDBuildOptions(opts)
            for _, btn in pairs(cdOptionBtns) do btn:Destroy() end
            table.clear(cdOptionBtns)
            for _, opt in ipairs(opts) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundColor3 = Theme.Container
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = opt
                OptBtn.Font = Config.FontMain
                OptBtn.TextSize = 12
                OptBtn.Parent = CDListFrame
                OptBtn.ZIndex = 11
                OptBtn.TextColor3 = (selectedConfigName == opt) and Theme.Accent or Theme.TextDark
                cdOptionBtns[opt] = OptBtn
                local c5 = OptBtn.MouseEnter:Connect(function()
                    if selectedConfigName ~= opt then Tween(OptBtn, {BackgroundTransparency = 0.8, TextColor3 = Theme.Accent}) end
                end)
                local c6 = OptBtn.MouseLeave:Connect(function()
                    if selectedConfigName ~= opt then Tween(OptBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDark}) end
                end)
                local c7 = OptBtn.MouseButton1Click:Connect(function()
                    selectedConfigName = opt
                    CDSelectedText.Text = opt
                    for o, b in pairs(cdOptionBtns) do b.TextColor3 = (o == opt) and Theme.Accent or Theme.TextDark end
                    CDCloseDropdown()
                end)
                table.insert(Library.Connections, c5)
                table.insert(Library.Connections, c6)
                table.insert(Library.Connections, c7)
            end
        end
        CDBuildOptions(ConfigList)
        local c8 = CDInteractive.MouseButton1Click:Connect(function()
            cdIsDropped = not cdIsDropped
            ConfigSec.Container.ZIndex = cdIsDropped and 10 or 1
            ConfigDropdownFrame.ZIndex = cdIsDropped and 10 or 5
            if cdIsDropped then
                CDListFrame.Visible = true
                local currentList = Library:GetConfigs()
                CDBuildOptions(currentList)
                local listH = math.min(#currentList * 24, 200)
                if listH < 24 then listH = 24 end
                local totalH = 46 + listH + 5
                Tween(ConfigDropdownFrame, {Size = UDim2.new(1, 0, 0, totalH)}, 0.2)
                Tween(CDListFrame, {Size = UDim2.new(1, 0, 0, listH)}, 0.2)
                Tween(CDArrow, {Rotation = 180}, 0.2)
            else
                CDCloseDropdown()
            end
        end)
        table.insert(Library.Connections, c8)
        local function RefreshConfigDropdown()
            local newList = Library:GetConfigs()
            ConfigList = newList
            if not table.find(newList, selectedConfigName) then
                selectedConfigName = #newList > 0 and newList[1] or ""
            end
            CDSelectedText.Text = selectedConfigName ~= "" and selectedConfigName or "No configs"
            CDBuildOptions(newList)
        end
        local CreateBtn = Instance.new("TextButton")
        CreateBtn.Size = UDim2.new(1, 0, 0, 32)
        CreateBtn.BackgroundColor3 = Theme.Container
        CreateBtn.Text = "Create New Config"
        CreateBtn.Font = Config.FontMain
        CreateBtn.TextSize = 13
        CreateBtn.TextColor3 = Theme.Text
        CreateBtn.AutoButtonColor = false
        CreateBtn.LayoutOrder = 3
        CreateBtn.Parent = ConfigContent
        Corner(CreateBtn, 4)
        local cs1 = Stroke(CreateBtn, Theme.Stroke, 1, 0.5)
        local c9 = CreateBtn.MouseEnter:Connect(function() Tween(CreateBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs1, {Color = Theme.Accent}) end)
        local c10 = CreateBtn.MouseLeave:Connect(function() Tween(CreateBtn, {BackgroundColor3 = Theme.Container}) Tween(cs1, {Color = Theme.Stroke}) end)
        local c11 = CreateBtn.MouseButton1Click:Connect(function()
            local name = configNameInput
            if not name or name == "" or string.match(name, "^%s*$") then
                Library:Notify("Error", "Please type a config name first", 3)
                return
            end
            name = string.gsub(name, "^%s+", "")
            name = string.gsub(name, "%s+$", "")
            if name == "" then
                Library:Notify("Error", "Please type a config name first", 3)
                return
            end
            if Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' already exists", 3)
                return
            end
            if Library:SaveConfig(name) then
                selectedConfigName = name
                CNameInput.Text = ""
                configNameInput = ""
                RefreshConfigDropdown()
                Library:Notify("Config", "Created: " .. name, 3)
            else
                Library:Notify("Error", "Failed to create config", 3)
            end
        end)
        table.insert(Library.Connections, c9)
        table.insert(Library.Connections, c10)
        table.insert(Library.Connections, c11)
        local LoadBtn = Instance.new("TextButton")
        LoadBtn.Size = UDim2.new(1, 0, 0, 32)
        LoadBtn.BackgroundColor3 = Theme.Container
        LoadBtn.Text = "Load Config"
        LoadBtn.Font = Config.FontMain
        LoadBtn.TextSize = 13
        LoadBtn.TextColor3 = Theme.Text
        LoadBtn.AutoButtonColor = false
        LoadBtn.LayoutOrder = 4
        LoadBtn.Parent = ConfigContent
        Corner(LoadBtn, 4)
        local cs2 = Stroke(LoadBtn, Theme.Stroke, 1, 0.5)
        local c12 = LoadBtn.MouseEnter:Connect(function() Tween(LoadBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs2, {Color = Theme.Accent}) end)
        local c13 = LoadBtn.MouseLeave:Connect(function() Tween(LoadBtn, {BackgroundColor3 = Theme.Container}) Tween(cs2, {Color = Theme.Stroke}) end)
        local c14 = LoadBtn.MouseButton1Click:Connect(function()
            local name = selectedConfigName
            if not name or name == "" then
                Library:Notify("Error", "No config selected", 3)
                return
            end
            if not Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if Library:LoadConfig(name) then
                Library:Notify("Config", "Loaded: " .. name, 3)
            else
                Library:Notify("Error", "Failed to load config", 3)
            end
        end)
        table.insert(Library.Connections, c12)
        table.insert(Library.Connections, c13)
        table.insert(Library.Connections, c14)
        local RewriteBtn = Instance.new("TextButton")
        RewriteBtn.Size = UDim2.new(1, 0, 0, 32)
        RewriteBtn.BackgroundColor3 = Theme.Container
        RewriteBtn.Text = "Rewrite Config"
        RewriteBtn.Font = Config.FontMain
        RewriteBtn.TextSize = 13
        RewriteBtn.TextColor3 = Theme.Text
        RewriteBtn.AutoButtonColor = false
        RewriteBtn.LayoutOrder = 5
        RewriteBtn.Parent = ConfigContent
        Corner(RewriteBtn, 4)
        local cs3 = Stroke(RewriteBtn, Theme.Stroke, 1, 0.5)
        local c15 = RewriteBtn.MouseEnter:Connect(function() Tween(RewriteBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs3, {Color = Theme.Accent}) end)
        local c16 = RewriteBtn.MouseLeave:Connect(function() Tween(RewriteBtn, {BackgroundColor3 = Theme.Container}) Tween(cs3, {Color = Theme.Stroke}) end)
        local c17 = RewriteBtn.MouseButton1Click:Connect(function()
            local name = selectedConfigName
            if not name or name == "" then
                Library:Notify("Error", "No config selected", 3)
                return
            end
            if not Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if Library:SaveConfig(name) then
                Library:Notify("Config", "Rewritten: " .. name, 3)
            else
                Library:Notify("Error", "Failed to rewrite config", 3)
            end
        end)
        table.insert(Library.Connections, c15)
        table.insert(Library.Connections, c16)
        table.insert(Library.Connections, c17)
        local DeleteBtn = Instance.new("TextButton")
        DeleteBtn.Size = UDim2.new(1, 0, 0, 32)
        DeleteBtn.BackgroundColor3 = Theme.Container
        DeleteBtn.Text = "Delete Config"
        DeleteBtn.Font = Config.FontMain
        DeleteBtn.TextSize = 13
        DeleteBtn.TextColor3 = Theme.Text
        DeleteBtn.AutoButtonColor = false
        DeleteBtn.LayoutOrder = 6
        DeleteBtn.Parent = ConfigContent
        Corner(DeleteBtn, 4)
        local cs4 = Stroke(DeleteBtn, Theme.Stroke, 1, 0.5)
        local c18 = DeleteBtn.MouseEnter:Connect(function() Tween(DeleteBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs4, {Color = Theme.Accent}) end)
        local c19 = DeleteBtn.MouseLeave:Connect(function() Tween(DeleteBtn, {BackgroundColor3 = Theme.Container}) Tween(cs4, {Color = Theme.Stroke}) end)
        local c20 = DeleteBtn.MouseButton1Click:Connect(function()
            local name = selectedConfigName
            if not name or name == "" then
                Library:Notify("Error", "No config selected", 3)
                return
            end
            if not Library:ConfigExists(name) then
                Library:Notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if Library:DeleteConfig(name) then
                RefreshConfigDropdown()
                Library:Notify("Config", "Deleted: " .. name, 3)
            else
                Library:Notify("Error", "Failed to delete config", 3)
            end
        end)
        table.insert(Library.Connections, c18)
        table.insert(Library.Connections, c19)
        table.insert(Library.Connections, c20)
        local RefreshBtn = Instance.new("TextButton")
        RefreshBtn.Size = UDim2.new(1, 0, 0, 32)
        RefreshBtn.BackgroundColor3 = Theme.Container
        RefreshBtn.Text = "Refresh Config List"
        RefreshBtn.Font = Config.FontMain
        RefreshBtn.TextSize = 13
        RefreshBtn.TextColor3 = Theme.Text
        RefreshBtn.AutoButtonColor = false
        RefreshBtn.LayoutOrder = 7
        RefreshBtn.Parent = ConfigContent
        Corner(RefreshBtn, 4)
        local cs5 = Stroke(RefreshBtn, Theme.Stroke, 1, 0.5)
        local c21 = RefreshBtn.MouseEnter:Connect(function() Tween(RefreshBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs5, {Color = Theme.Accent}) end)
        local c22 = RefreshBtn.MouseLeave:Connect(function() Tween(RefreshBtn, {BackgroundColor3 = Theme.Container}) Tween(cs5, {Color = Theme.Stroke}) end)
        local c23 = RefreshBtn.MouseButton1Click:Connect(function()
            RefreshConfigDropdown()
            Library:Notify("Config", "List Refreshed", 2)
        end)
        table.insert(Library.Connections, c21)
        table.insert(Library.Connections, c22)
        table.insert(Library.Connections, c23)
        local ResetBtn = Instance.new("TextButton")
        ResetBtn.Size = UDim2.new(1, 0, 0, 32)
        ResetBtn.BackgroundColor3 = Theme.Container
        ResetBtn.Text = "Reset to Defaults"
        ResetBtn.Font = Config.FontMain
        ResetBtn.TextSize = 13
        ResetBtn.TextColor3 = Theme.Text
        ResetBtn.AutoButtonColor = false
        ResetBtn.LayoutOrder = 8
        ResetBtn.Parent = ConfigContent
        Corner(ResetBtn, 4)
        local cs6 = Stroke(ResetBtn, Theme.Stroke, 1, 0.5)
        local c24 = ResetBtn.MouseEnter:Connect(function() Tween(ResetBtn, {BackgroundColor3 = Theme.Stroke}) Tween(cs6, {Color = Theme.Accent}) end)
        local c25 = ResetBtn.MouseLeave:Connect(function() Tween(ResetBtn, {BackgroundColor3 = Theme.Container}) Tween(cs6, {Color = Theme.Stroke}) end)
        local c26 = ResetBtn.MouseButton1Click:Connect(function()
            for flag, val in pairs(Library.Defaults) do
                if IgnoredFlags[flag] then continue end
                Library.Flags[flag] = val
                if Library.Signals[flag] then
                    task.spawn(Library.Signals[flag], val)
                end
            end
            Library:Notify("Settings", "Reset to defaults", 3)
        end)
        table.insert(Library.Connections, c24)
        table.insert(Library.Connections, c25)
        table.insert(Library.Connections, c26)
    end
    PopulateSettings()
    function WindowObj:Tab(name, iconId)
        local Tab = {}
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.Active = true
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = MainPages
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 36)
        TabBtn.BackgroundColor3 = Theme.Background
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.Parent = TabContainer
        Corner(TabBtn, 6)
        local Title = Instance.new("TextLabel")
        Title.Text = name
        Title.Font = Config.FontMain
        Title.TextSize = 14
        Title.TextColor3 = Theme.TextDark
        Title.Size = UDim2.new(1, -20, 1, 0)
        Title.Position = UDim2.new(0, iconId and 35 or 15, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1
        Title.Parent = TabBtn
        if iconId then
            local Ico = Instance.new("ImageLabel")
            Ico.Size = UDim2.new(0, 20, 0, 20)
            Ico.Position = UDim2.new(0, 8, 0.5, 0)
            Ico.AnchorPoint = Vector2.new(0, 0.5)
            Ico.BackgroundTransparency = 1
            if tonumber(iconId) then Ico.Image = "rbxassetid://" .. iconId else Ico.Image = iconId end
            Ico.ImageColor3 = Theme.TextDark
            Ico.Parent = TabBtn
            local c1 = TabBtn.MouseEnter:Connect(function() if TabBtn.BackgroundTransparency > 0.5 then Tween(Ico, {ImageColor3 = Theme.Text}) end end)
            local c2 = TabBtn.MouseLeave:Connect(function() if TabBtn.BackgroundTransparency > 0.5 then Tween(Ico, {ImageColor3 = Theme.TextDark}) end end)
            table.insert(Library.Connections, c1)
            table.insert(Library.Connections, c2)
        end
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 16)
        Indicator.Position = UDim2.new(0, 0, 0.5, -8)
        Indicator.BackgroundColor3 = Theme.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Parent = TabBtn
        Corner(Indicator, 2)
        RegisterTheme(Indicator, "BackgroundColor")
        local c3 = TabBtn.MouseButton1Click:Connect(function()
            for _, p in pairs(MainPages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, t in pairs(TabContainer:GetChildren()) do
                if t:IsA("TextButton") then
                    Tween(t.TextLabel, {TextColor3 = Theme.TextDark})
                    Tween(t, {BackgroundTransparency = 1, BackgroundColor3 = Theme.Background})
                    if t:FindFirstChild("ImageLabel") then Tween(t.ImageLabel, {ImageColor3 = Theme.TextDark}) end
                    Tween(t.Frame, {BackgroundTransparency = 1})
                end
            end
            Page.Visible = true
            Tween(Title, {TextColor3 = Theme.Text})
            Tween(TabBtn, {BackgroundTransparency = 0.95, BackgroundColor3 = Theme.Text})
            if TabBtn:FindFirstChild("ImageLabel") then Tween(TabBtn.ImageLabel, {ImageColor3 = Theme.Text}) end
            Tween(Indicator, {BackgroundTransparency = 0})
        end)
        table.insert(Library.Connections, c3)
        local tabCount = 0
        for _, c in pairs(TabContainer:GetChildren()) do
            if c:IsA("TextButton") then tabCount = tabCount + 1 end
        end
        if tabCount <= 1 then
            Page.Visible = true
            Title.TextColor3 = Theme.Text
            TabBtn.BackgroundTransparency = 0.95
            TabBtn.BackgroundColor3 = Theme.Text
            if TabBtn:FindFirstChild("ImageLabel") then TabBtn.ImageLabel.ImageColor3 = Theme.Text end
            Indicator.BackgroundTransparency = 0
        end
        local LeftCol = Instance.new("Frame")
        LeftCol.Size = UDim2.new(0.5, -5, 0, 0)
        LeftCol.Position = UDim2.new(0, 0, 0, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.AutomaticSize = Enum.AutomaticSize.Y
        LeftCol.Parent = Page
        local LeftList = Instance.new("UIListLayout")
        LeftList.SortOrder = Enum.SortOrder.LayoutOrder
        LeftList.Padding = UDim.new(0, 10)
        LeftList.Parent = LeftCol
        local RightCol = Instance.new("Frame")
        RightCol.Size = UDim2.new(0.5, -5, 0, 0)
        RightCol.Position = UDim2.new(0.5, 5, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.AutomaticSize = Enum.AutomaticSize.Y
        RightCol.Parent = Page
        local RightList = Instance.new("UIListLayout")
        RightList.SortOrder = Enum.SortOrder.LayoutOrder
        RightList.Padding = UDim.new(0, 10)
        RightList.Parent = RightCol
        function Tab:Section(text, side)
            local Section = {}
            local ParentCol = (side == "Right" and RightCol or LeftCol)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.BackgroundColor3 = Theme.Section
            Container.Parent = ParentCol
            Container.ZIndex = 1
            Corner(Container, 6)
            Stroke(Container, Theme.Stroke, 1, 0.5)
            Section.Container = Container
            local secData = {Instance = Container, Items = {}}
            table.insert(Library.Elements, secData)
            local STitle = Instance.new("TextLabel")
            STitle.Text = text
            STitle.Font = Config.FontBold
            STitle.TextSize = 12
            STitle.TextColor3 = Theme.TextDark
            STitle.Size = UDim2.new(1, -20, 0, 25)
            STitle.Position = UDim2.new(0, 10, 0, 0)
            STitle.BackgroundTransparency = 1
            STitle.TextXAlignment = Enum.TextXAlignment.Left
            STitle.Parent = Container
            local Content = Instance.new("Frame")
            Content.Size = UDim2.new(1, -10, 0, 0)
            Content.Position = UDim2.new(0, 5, 0, 25)
            Content.BackgroundTransparency = 1
            Content.Parent = Container
            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 6)
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Content
            local function UpdateSize()
                Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 35)
                Page.CanvasSize = UDim2.new(0, 0, 0, math.max(LeftList.AbsoluteContentSize.Y, RightList.AbsoluteContentSize.Y) + 20)
            end
            local c4 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateSize)
            table.insert(Library.Connections, c4)
            function Section:Label(ltext, options)
                options = options or {}
                local LabelObj = {}
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 26)
                Frame.BackgroundColor3 = Theme.Container
                Frame.BackgroundTransparency = 0.5
                Frame.Parent = Content
                table.insert(secData.Items, {Name = ltext, Instance = Frame})
                Corner(Frame, 4)
                Stroke(Frame, Theme.Stroke, 1, 0.5)
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -10, 1, -10)
                Lbl.Position = UDim2.new(0, 5, 0, 5)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = tostring(ltext)
                Lbl.Font = Config.FontMain
                Lbl.TextSize = 13
                Lbl.TextColor3 = options.Color or Theme.Text
                Lbl.TextXAlignment = options.Alignment or Enum.TextXAlignment.Left
                Lbl.TextYAlignment = Enum.TextYAlignment.Top
                Lbl.RichText = true
                Lbl.TextWrapped = true
                Lbl.Parent = Frame
                local function UpdateHeight()
                    local textHeight = Lbl.TextBounds.Y
                    if textHeight > 16 then Frame.Size = UDim2.new(1, 0, 0, textHeight + 10) else Frame.Size = UDim2.new(1, 0, 0, 26) end
                end
                local boundsConn = Lbl:GetPropertyChangedSignal("TextBounds"):Connect(UpdateHeight)
                table.insert(Library.Connections, boundsConn)
                UpdateHeight()
                function LabelObj:Set(newText) Lbl.Text = tostring(newText) end
                function LabelObj:SetColor(newColor) Lbl.TextColor3 = newColor end
                return LabelObj
            end
            function Section:Toggle(text, flag, default, tooltipText, callback)
                Library.Defaults[flag] = default or false
                local toggled = Library.Flags[flag]
                if toggled == nil then
                    toggled = default or false
                    Library.Flags[flag] = toggled
                end
                local ToggleObj = {}
                Library.Signals[flag] = function(val)
                    if toggled ~= val then
                        toggled = val
                        if ToggleObj.UpdateAnim then ToggleObj.UpdateAnim() end
                        Library.Unsaved = true
                        callback(val)
                    end
                end
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Theme.Container
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = Btn})
                Corner(Btn, 4)
                Stroke(Btn, Theme.Stroke, 1, 0.5)
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Btn
                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 18, 0, 18)
                Box.Position = UDim2.new(1, -10, 0.5, 0)
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundColor3 = Theme.Background
                Box.Parent = Btn
                Corner(Box, 4)
                Stroke(Box, Theme.Stroke, 1, 0.5)
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(1, -4, 1, -4)
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundColor3 = Theme.Accent
                Fill.BackgroundTransparency = toggled and 0 or 1
                Fill.Parent = Box
                Corner(Fill, 3)
                RegisterTheme(Fill, "BackgroundColor")
                local SubContainer = Instance.new("Frame")
                SubContainer.Name = "Sub_" .. text
                SubContainer.Size = UDim2.new(1, 0, 0, 0)
                SubContainer.BackgroundTransparency = 1
                SubContainer.ClipsDescendants = true
                SubContainer.Visible = false
                SubContainer.Parent = Content
                local SubList = Instance.new("UIListLayout")
                SubList.Padding = UDim.new(0, 6)
                SubList.SortOrder = Enum.SortOrder.LayoutOrder
                SubList.Parent = SubContainer
                local currentTween = nil
                local function ToggleAnim()
                    if currentTween then currentTween:Cancel() end
                    Tween(Fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                    Library.Flags[flag] = toggled
                    if ToggleObj.KeybindValue then
                        Library:UpdateKeybindList(text, ToggleObj.KeybindValue.Name, toggled, ToggleObj.KeybindMode)
                    end
                    if toggled then
                        SubContainer.Visible = true
                        SubContainer.ClipsDescendants = true
                        local h = SubList.AbsoluteContentSize.Y
                        if h > 0 then h = h + 6 end
                        currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, h)})
                        currentTween:Play()
                        local tc
                        tc = currentTween.Completed:Connect(function(state)
                            if state == Enum.PlaybackState.Completed and toggled then SubContainer.ClipsDescendants = false end
                            tc:Disconnect()
                        end)
                    else
                        SubContainer.ClipsDescendants = true
                        currentTween = TweenService:Create(SubContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                        currentTween:Play()
                        local expectedToggle = toggled
                        local tc
                        tc = currentTween.Completed:Connect(function(playbackState)
                            if playbackState == Enum.PlaybackState.Completed and expectedToggle == toggled and not toggled then SubContainer.Visible = false end
                            tc:Disconnect()
                        end)
                    end
                end
                ToggleObj.UpdateAnim = ToggleAnim
                local c5 = SubList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if toggled then
                        local h = SubList.AbsoluteContentSize.Y
                        if h > 0 then h = h + 6 end
                        SubContainer.Size = UDim2.new(1, 0, 0, h)
                    end
                end)
                table.insert(Library.Connections, c5)
                local c6 = Btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    Library.Unsaved = true
                    ToggleAnim()
                    callback(toggled)
                end)
                table.insert(Library.Connections, c6)
                if toggled then ToggleAnim() end
                ApplyTooltip(Btn, tooltipText)
                task.spawn(callback, toggled)
                function ToggleObj:AddButton(txt, cb)
                    local SBtn = Instance.new("TextButton")
                    SBtn.Size = UDim2.new(1, -20, 0, 26)
                    SBtn.Position = UDim2.new(0, 20, 0, 0)
                    SBtn.BackgroundColor3 = Theme.Container
                    SBtn.Text = txt
                    SBtn.Font = Config.FontMain
                    SBtn.TextSize = 12
                    SBtn.TextColor3 = Theme.Text
                    SBtn.AutoButtonColor = false
                    SBtn.Parent = SubContainer
                    Corner(SBtn, 4)
                    local s = Stroke(SBtn, Theme.Stroke, 1, 0.5)
                    local tbc1 = SBtn.MouseEnter:Connect(function() Tween(SBtn, {BackgroundColor3 = Theme.Stroke}) Tween(s, {Color = Theme.Accent}) end)
                    local tbc2 = SBtn.MouseLeave:Connect(function() Tween(SBtn, {BackgroundColor3 = Theme.Container}) Tween(s, {Color = Theme.Stroke}) end)
                    local tbc3 = SBtn.MouseButton1Click:Connect(cb)
                    table.insert(Library.Connections, tbc1)
                    table.insert(Library.Connections, tbc2)
                    table.insert(Library.Connections, tbc3)
                end
                function ToggleObj:AddSlider(txt, sflag, min, max, def, cb, inc)
                    inc = inc or 1
                    local val = Library.Flags[sflag]
                    if val == nil then val = def or min end
                    val = RoundToIncrement(val, inc)
                    Library.Defaults[sflag] = val
                    Library.Flags[sflag] = val
                    local range = max - min
                    local SFrame = Instance.new("Frame")
                    SFrame.Size = UDim2.new(1, -20, 0, 36)
                    SFrame.Position = UDim2.new(0, 20, 0, 0)
                    SFrame.BackgroundTransparency = 1
                    SFrame.Parent = SubContainer
                    local SLabel = Instance.new("TextLabel")
                    SLabel.Text = txt
                    SLabel.Font = Config.FontMain
                    SLabel.TextSize = 12
                    SLabel.TextColor3 = Theme.TextDark
                    SLabel.Size = UDim2.new(1, 0, 0, 16)
                    SLabel.TextXAlignment = Enum.TextXAlignment.Left
                    SLabel.BackgroundTransparency = 1
                    SLabel.Parent = SFrame
                    local SValue = Instance.new("TextBox")
                    SValue.Text = FormatNumber(val, inc)
                    SValue.Font = Config.FontMain
                    SValue.TextSize = 12
                    SValue.TextColor3 = Theme.Text
                    SValue.Size = UDim2.new(1, 0, 0, 16)
                    SValue.TextXAlignment = Enum.TextXAlignment.Right
                    SValue.BackgroundTransparency = 1
                    SValue.ClearTextOnFocus = true
                    SValue.Parent = SFrame
                    local SlideBg = Instance.new("Frame")
                    SlideBg.Size = UDim2.new(1, 0, 0, 6)
                    SlideBg.Position = UDim2.new(0, 0, 0, 22)
                    SlideBg.BackgroundColor3 = Theme.Background
                    SlideBg.Parent = SFrame
                    Corner(SlideBg, 3)
                    local SlideFill = Instance.new("Frame")
                    local ratio = range > 0 and (val - min) / range or 0
                    SlideFill.Size = UDim2.new(ratio, 0, 1, 0)
                    SlideFill.BackgroundColor3 = Theme.Accent
                    SlideFill.BorderSizePixel = 0
                    SlideFill.Parent = SlideBg
                    Corner(SlideFill, 3)
                    RegisterTheme(SlideFill, "BackgroundColor")
                    local dragging = false
                    local dragInput
                    local function Set(input)
                        local r = math.clamp((input.Position.X - SlideBg.AbsolutePosition.X) / SlideBg.AbsoluteSize.X, 0, 1)
                        local raw = min + (max - min) * r
                        val = RoundToIncrement(raw, inc)
                        val = math.clamp(val, min, max)
                        local displayRatio = range > 0 and (val - min) / range or 0
                        SValue.Text = FormatNumber(val, inc)
                        Tween(SlideFill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                        Library.Flags[sflag] = val
                        Library.Unsaved = true
                        cb(val)
                    end
                    local ts1 = SlideBg.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            dragInput = i
                            Set(i)
                            local tsc
                            tsc = i.Changed:Connect(function()
                                if i.UserInputState == Enum.UserInputState.End then
                                    dragging = false
                                    tsc:Disconnect()
                                end
                            end)
                        end
                    end)
                    local ts2 = UserInputService.InputChanged:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                            if dragging then dragInput = input end
                        end
                    end)
                    local ts3 = RunService.RenderStepped:Connect(function()
                        if dragging and dragInput then Set(dragInput) end
                    end)
                    table.insert(Library.Connections, ts1)
                    table.insert(Library.Connections, ts2)
                    table.insert(Library.Connections, ts3)
                    local ts4 = SValue.FocusLost:Connect(function(enter)
                        if enter then
                            local cleanText = string.gsub(SValue.Text, "[^%d.-]", "")
                            local num = tonumber(cleanText)
                            if num then
                                num = RoundToIncrement(num, inc)
                                num = math.clamp(num, min, max)
                                val = num
                                local displayRatio = range > 0 and (val - min) / range or 0
                                SValue.Text = FormatNumber(val, inc)
                                Tween(SlideFill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                                Library.Flags[sflag] = val
                                Library.Unsaved = true
                                cb(val)
                            else
                                SValue.Text = FormatNumber(val, inc)
                            end
                        else
                            SValue.Text = FormatNumber(val, inc)
                        end
                    end)
                    table.insert(Library.Connections, ts4)
                    Library.Signals[sflag] = function(loadedVal)
                        val = RoundToIncrement(loadedVal, inc)
                        val = math.clamp(val, min, max)
                        local displayRatio = range > 0 and (val - min) / range or 0
                        SValue.Text = FormatNumber(val, inc)
                        Tween(SlideFill, {Size = UDim2.new(displayRatio, 0, 1, 0)}, 0.05)
                        Library.Unsaved = true
                        cb(val)
                    end
                    task.spawn(cb, val)
                end
                function ToggleObj:AddDropdown(txt, dflag, opts, def, cb, isMulti)
                    CreateDropdownElement(txt, dflag, opts, def, nil, cb, Content, Section, isMulti, SubContainer)
                end
                function ToggleObj:Keybind(defaultKey, mode)
                    ToggleObj.KeybindValue = defaultKey or Enum.KeyCode.Unknown
                    ToggleObj.KeybindMode = mode or "Toggle"
                    local KeyBtn = Instance.new("TextButton")
                    KeyBtn.Size = UDim2.new(0, 60, 0, 18)
                    KeyBtn.Position = UDim2.new(1, -30, 0.5, 0)
                    KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
                    KeyBtn.BackgroundTransparency = 1
                    KeyBtn.Text = "[" .. (ToggleObj.KeybindValue.Name) .. "]"
                    KeyBtn.TextColor3 = Theme.TextDark
                    KeyBtn.Font = Config.FontMain
                    KeyBtn.TextSize = 11
                    KeyBtn.TextXAlignment = Enum.TextXAlignment.Right
                    KeyBtn.Parent = Btn
                    local binding = false
                    local kb1 = KeyBtn.MouseButton1Click:Connect(function()
                        if binding then return end
                        binding = true
                        KeyBtn.Text = "[...]"
                        KeyBtn.TextColor3 = Theme.Accent
                        local conn
                        conn = UserInputService.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then ToggleObj.KeybindValue = Enum.KeyCode.Unknown
                                elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then ToggleObj.KeybindValue = input.KeyCode end
                                KeyBtn.Text = "[" .. (ToggleObj.KeybindValue.Name) .. "]"
                                KeyBtn.TextColor3 = Theme.TextDark
                                binding = false
                                Library.Unsaved = true
                                conn:Disconnect()
                                if toggled then Library:UpdateKeybindList(text, ToggleObj.KeybindValue.Name, toggled, ToggleObj.KeybindMode) end
                            end
                        end)
                    end)
                    table.insert(Library.Connections, kb1)
                    local ModeGui = Instance.new("Frame")
                    ModeGui.Size = UDim2.new(0, 80, 0, 60)
                    ModeGui.BackgroundColor3 = Theme.Sidebar
                    ModeGui.Visible = false
                    ModeGui.ZIndex = 100
                    ModeGui.Parent = Btn
                    Corner(ModeGui, 4)
                    Stroke(ModeGui, Theme.Stroke, 1)
                    local ModeList = Instance.new("UIListLayout")
                    ModeList.Parent = ModeGui
                    local modes = {"Toggle", "Hold", "Always"}
                    for _, md in ipairs(modes) do
                        local mBtn = Instance.new("TextButton")
                        mBtn.Size = UDim2.new(1, 0, 0, 20)
                        mBtn.BackgroundTransparency = 1
                        mBtn.Text = md
                        mBtn.TextColor3 = Theme.TextDark
                        mBtn.Font = Config.FontMain
                        mBtn.TextSize = 11
                        mBtn.Parent = ModeGui
                        mBtn.ZIndex = 101
                        local mb1 = mBtn.MouseButton1Click:Connect(function()
                            ToggleObj.KeybindMode = md
                            ModeGui.Visible = false
                            Library.Unsaved = true
                            if md == "Always" and not toggled then
                                toggled = true
                                ToggleAnim()
                                callback(toggled)
                            end
                            if toggled then Library:UpdateKeybindList(text, ToggleObj.KeybindValue.Name, toggled, md) end
                        end)
                        table.insert(Library.Connections, mb1)
                    end
                    local kb2 = KeyBtn.MouseButton2Click:Connect(function()
                        ModeGui.Position = UDim2.new(1, -110, 0, 20)
                        ModeGui.Visible = not ModeGui.Visible
                        if ModeGui.Visible then SubContainer.ClipsDescendants = false end
                    end)
                    table.insert(Library.Connections, kb2)
                    if ToggleObj.BindConnection then ToggleObj.BindConnection:Disconnect() end
                    if ToggleObj.BindConnectionEnded then ToggleObj.BindConnectionEnded:Disconnect() end
                    ToggleObj.BindConnection = UserInputService.InputBegan:Connect(function(input, gp)
                        if not gp and input.KeyCode == ToggleObj.KeybindValue and ToggleObj.KeybindValue ~= Enum.KeyCode.Unknown then
                            if ToggleObj.KeybindMode == "Toggle" then
                                toggled = not toggled
                                ToggleAnim()
                                callback(toggled)
                            elseif ToggleObj.KeybindMode == "Hold" then
                                toggled = true
                                ToggleAnim()
                                callback(toggled)
                            end
                        end
                    end)
                    ToggleObj.BindConnectionEnded = UserInputService.InputEnded:Connect(function(input, gp)
                        if not gp and input.KeyCode == ToggleObj.KeybindValue and ToggleObj.KeybindValue ~= Enum.KeyCode.Unknown then
                            if ToggleObj.KeybindMode == "Hold" then
                                toggled = false
                                ToggleAnim()
                                callback(toggled)
                            end
                        end
                    end)
                    table.insert(Library.Connections, ToggleObj.BindConnection)
                    table.insert(Library.Connections, ToggleObj.BindConnectionEnded)
                    if toggled then Library:UpdateKeybindList(text, ToggleObj.KeybindValue.Name, toggled, ToggleObj.KeybindMode) end
                    return ToggleObj
                end
                return ToggleObj
            end
            function Section:Keybind(text, flag, defaultKey, mode, tooltipText, callback)
                local defObj = Library.Flags[flag]
                local key = defObj and defObj.Key or (defaultKey or Enum.KeyCode.Unknown)
                local kMode = defObj and defObj.Mode or (mode or "Toggle")
                Library.Defaults[flag] = {Key = defaultKey or Enum.KeyCode.Unknown, Mode = mode or "Toggle"}
                Library.Flags[flag] = {Key = key, Mode = kMode}
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 30)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Content
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(0.6, 0, 1, 0)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local KeyBtn = Instance.new("TextButton")
                KeyBtn.Size = UDim2.new(0, 80, 0, 20)
                KeyBtn.Position = UDim2.new(1, -5, 0.5, 0)
                KeyBtn.AnchorPoint = Vector2.new(1, 0.5)
                KeyBtn.BackgroundColor3 = Theme.Container
                KeyBtn.Text = "[" .. key.Name .. "]"
                KeyBtn.Font = Config.FontMain
                KeyBtn.TextSize = 12
                KeyBtn.TextColor3 = Theme.TextDark
                KeyBtn.AutoButtonColor = false
                KeyBtn.Parent = Frame
                Corner(KeyBtn, 4)
                Stroke(KeyBtn, Theme.Stroke, 1, 0.5)
                local toggled = (kMode == "Always")
                Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                local binding = false
                local c1 = KeyBtn.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true
                    KeyBtn.Text = "[...]"
                    KeyBtn.TextColor3 = Theme.Accent
                    local conn
                    conn = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                                key = Enum.KeyCode.Unknown
                            elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                                key = input.KeyCode
                            end
                            KeyBtn.Text = "[" .. key.Name .. "]"
                            KeyBtn.TextColor3 = Theme.TextDark
                            Library.Flags[flag] = {Key = key, Mode = kMode}
                            binding = false
                            Library.Unsaved = true
                            conn:Disconnect()
                            Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                        end
                    end)
                end)
                table.insert(Library.Connections, c1)
                local ModeGui = Instance.new("Frame")
                ModeGui.Size = UDim2.new(0, 80, 0, 60)
                ModeGui.Position = UDim2.new(1, -90, 0, 25)
                ModeGui.BackgroundColor3 = Theme.Sidebar
                ModeGui.Visible = false
                ModeGui.ZIndex = 100
                ModeGui.Parent = Frame
                Corner(ModeGui, 4)
                Stroke(ModeGui, Theme.Stroke, 1)
                local ModeList = Instance.new("UIListLayout")
                ModeList.Parent = ModeGui
                local modes = {"Toggle", "Hold", "Always"}
                for _, md in ipairs(modes) do
                    local mBtn = Instance.new("TextButton")
                    mBtn.Size = UDim2.new(1, 0, 0, 20)
                    mBtn.BackgroundTransparency = 1
                    mBtn.Text = md
                    mBtn.TextColor3 = Theme.TextDark
                    mBtn.Font = Config.FontMain
                    mBtn.TextSize = 11
                    mBtn.Parent = ModeGui
                    mBtn.ZIndex = 101
                    local c2 = mBtn.MouseButton1Click:Connect(function()
                        kMode = md
                        Library.Flags[flag] = {Key = key, Mode = kMode}
                        ModeGui.Visible = false
                        Library.Unsaved = true
                        if kMode == "Always" then
                            toggled = true
                            callback(true)
                        end
                        Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                    end)
                    table.insert(Library.Connections, c2)
                end
                local c3 = KeyBtn.MouseButton2Click:Connect(function()
                    ModeGui.Visible = not ModeGui.Visible
                    if ModeGui.Visible then Content.ClipsDescendants = false end
                end)
                table.insert(Library.Connections, c3)
                local BindConnection = UserInputService.InputBegan:Connect(function(input, gp)
                    if not gp and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        if kMode == "Toggle" then
                            toggled = not toggled
                            Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                            callback(toggled)
                        elseif kMode == "Hold" then
                            toggled = true
                            Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                            callback(toggled)
                        end
                    end
                end)
                local BindConnectionEnded = UserInputService.InputEnded:Connect(function(input, gp)
                    if not gp and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        if kMode == "Hold" then
                            toggled = false
                            Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                            callback(toggled)
                        end
                    end
                end)
                table.insert(Library.Connections, BindConnection)
                table.insert(Library.Connections, BindConnectionEnded)
                ApplyTooltip(Frame, tooltipText)
                Library.Signals[flag] = function(val)
                    if type(val) == "table" and val.Key then
                        key = val.Key
                        kMode = val.Mode or "Toggle"
                        KeyBtn.Text = "[" .. key.Name .. "]"
                        if kMode == "Always" then
                            toggled = true
                            callback(true)
                        end
                        Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                    end
                end
                local BindObj = {}
                function BindObj:SetKey(newKey)
                    key = newKey
                    KeyBtn.Text = "[" .. key.Name .. "]"
                    Library.Flags[flag] = {Key = key, Mode = kMode}
                    Library.Unsaved = true
                    Library:UpdateKeybindList(text, key.Name, toggled, kMode)
                end
                return BindObj
            end
            function Section:Button(text, tooltipText, callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.BackgroundColor3 = Theme.Container
                Btn.Text = text
                Btn.Font = Config.FontMain
                Btn.TextSize = 13
                Btn.TextColor3 = Theme.Text
                Btn.AutoButtonColor = false
                Btn.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = Btn})
                Corner(Btn, 4)
                local s = Stroke(Btn, Theme.Stroke, 1, 0.5)
                local c1 = Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Stroke}) Tween(s, {Color = Theme.Accent}) end)
                local c2 = Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Container}) Tween(s, {Color = Theme.Stroke}) end)
                local c3 = Btn.MouseButton1Click:Connect(callback)
                table.insert(Library.Connections, c1)
                table.insert(Library.Connections, c2)
                table.insert(Library.Connections, c3)
                ApplyTooltip(Btn, tooltipText)
            end
            function Section:Slider(text, flag, min, max, default, increment, tooltipText, callback)
                CreateSliderElement(text, flag, min, max, default, increment, tooltipText, callback, Content, secData)
            end
            function Section:TextBox(text, flag, placeholder, tooltipText, callback)
                Library.Defaults[flag] = ""
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 46)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = Frame})
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local BoxCont = Instance.new("Frame")
                BoxCont.Size = UDim2.new(1, 0, 0, 26)
                BoxCont.Position = UDim2.new(0, 0, 0, 20)
                BoxCont.BackgroundColor3 = Theme.Container
                BoxCont.Parent = Frame
                Corner(BoxCont, 4)
                local s = Stroke(BoxCont, Theme.Stroke, 1, 0.5)
                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, -10, 1, 0)
                Input.Position = UDim2.new(0, 5, 0, 0)
                Input.BackgroundTransparency = 1
                Input.TextColor3 = Theme.Text
                Input.PlaceholderText = placeholder or "Type here..."
                Input.PlaceholderColor3 = Theme.TextDark
                Input.Font = Config.FontMain
                Input.TextSize = 13
                Input.TextXAlignment = Enum.TextXAlignment.Left
                local currentText = Library.Flags[flag] or ""
                Input.Text = currentText
                Input.ClearTextOnFocus = false
                Input.Parent = BoxCont
                local c1 = Input.Focused:Connect(function() Tween(s, {Color = Theme.Accent}) end)
                local c2 = Input.FocusLost:Connect(function(enter)
                    Tween(s, {Color = Theme.Stroke})
                    if enter then
                        Library.Flags[flag] = Input.Text
                        Library.Unsaved = true
                        callback(Input.Text)
                    end
                end)
                table.insert(Library.Connections, c1)
                table.insert(Library.Connections, c2)
                Library.Flags[flag] = currentText
                Library.Signals[flag] = function(val)
                    Input.Text = val
                    Library.Unsaved = true
                    callback(val)
                end
                ApplyTooltip(Frame, tooltipText)
                task.spawn(callback, currentText)
            end
            function Section:Dropdown(text, flag, options, default, tooltipText, callback, customParent, isMulti)
                local obj = CreateDropdownElement(text, flag, options, default, tooltipText, callback, Content, Section, isMulti, customParent)
                if not customParent then table.insert(secData.Items, {Name = text, Instance = obj.Frame}) end
                return obj
            end
            function Section:ColorPicker(text, flag, default, tooltipText, callback)
                local color = Library.Flags[flag] or default or Color3.fromRGB(255, 255, 255)
                Library.Defaults[flag] = default or Color3.fromRGB(255, 255, 255)
                Library.Flags[flag] = color
                local h, s, v = color:ToHSV()
                local isOpen = false
                local ContainerFrame = Instance.new("Frame")
                ContainerFrame.Size = UDim2.new(1, 0, 0, 30)
                ContainerFrame.BackgroundTransparency = 1
                ContainerFrame.Parent = Content
                table.insert(secData.Items, {Name = text, Instance = ContainerFrame})
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 30)
                Frame.BackgroundTransparency = 1
                Frame.Parent = ContainerFrame
                Frame.ZIndex = 5
                local Label = Instance.new("TextLabel")
                Label.Text = text
                Label.Font = Config.FontMain
                Label.TextSize = 13
                Label.TextColor3 = Theme.Text
                Label.Size = UDim2.new(0.6, 0, 1, 0)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local Preview = Instance.new("TextButton")
                Preview.Size = UDim2.new(0, 40, 0, 20)
                Preview.Position = UDim2.new(1, -5, 0.5, 0)
                Preview.AnchorPoint = Vector2.new(1, 0.5)
                Preview.BackgroundColor3 = color
                Preview.AutoButtonColor = false
                Preview.Text = ""
                Preview.Parent = Frame
                Corner(Preview, 4)
                Stroke(Preview, Theme.Stroke, 1, 0.5)
                local PickerCont = Instance.new("Frame")
                PickerCont.Size = UDim2.new(1, 0, 0, 0)
                PickerCont.Position = UDim2.new(0, 0, 0, 30)
                PickerCont.BackgroundColor3 = Theme.Background
                PickerCont.Parent = ContainerFrame
                PickerCont.ClipsDescendants = true
                PickerCont.Visible = false
                PickerCont.ZIndex = 10
                Corner(PickerCont, 4)
                local SVMap = Instance.new("ImageLabel")
                SVMap.Size = UDim2.new(0, 140, 0, 120)
                SVMap.Position = UDim2.new(0, 10, 0, 10)
                SVMap.Image = "rbxassetid://4155801252"
                SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVMap.Parent = PickerCont
                SVMap.ZIndex = 11
                Corner(SVMap, 4)
                local SVCursor = Instance.new("Frame")
                SVCursor.Size = UDim2.new(0, 8, 0, 8)
                SVCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SVCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SVCursor.Parent = SVMap
                SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                SVCursor.ZIndex = 12
                Corner(SVCursor, 4)
                local HueBar = Instance.new("ImageLabel")
                HueBar.Size = UDim2.new(0, 20, 0, 120)
                HueBar.Position = UDim2.new(0, 160, 0, 10)
                HueBar.Image = "rbxassetid://4155801252"
                HueBar.Parent = PickerCont
                HueBar.ZIndex = 11
                Corner(HueBar, 4)
                local UIGradient = Instance.new("UIGradient")
                UIGradient.Rotation = 90
                UIGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                UIGradient.Parent = HueBar
                local HCursor = Instance.new("Frame")
                HCursor.Size = UDim2.new(1, 0, 0, 2)
                HCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                HCursor.Parent = HueBar
                HCursor.Position = UDim2.new(0, 0, h, 0)
                HCursor.ZIndex = 12
                local HexInput = Instance.new("TextBox")
                HexInput.Size = UDim2.new(0, 170, 0, 20)
                HexInput.Position = UDim2.new(0, 10, 0, 140)
                HexInput.BackgroundColor3 = Theme.Container
                HexInput.TextColor3 = Theme.Text
                HexInput.Font = Config.FontMain
                HexInput.TextSize = 12
                HexInput.Text = "#" .. color:ToHex()
                HexInput.Parent = PickerCont
                HexInput.ZIndex = 11
                Corner(HexInput, 4)
                Stroke(HexInput, Theme.Stroke, 1)
                local function Update()
                    color = Color3.fromHSV(h, s, v)
                    Preview.BackgroundColor3 = color
                    SVMap.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    HexInput.Text = "#" .. color:ToHex()
                    Library.Flags[flag] = color
                    Library.Unsaved = true
                    callback(color)
                end
                local hc1 = HexInput.FocusLost:Connect(function()
                    local t = HexInput.Text:gsub("#", "")
                    if t:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                        pcall(function()
                            local nc = Color3.fromHex(t)
                            h, s, v = nc:ToHSV()
                            HCursor.Position = UDim2.new(0, 0, h, 0)
                            SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                            Update()
                        end)
                    else
                        HexInput.Text = "#" .. color:ToHex()
                    end
                end)
                table.insert(Library.Connections, hc1)
                Library.Signals[flag] = function(val)
                    if typeof(val) == "Color3" then
                        color = val
                        h, s, v = color:ToHSV()
                        HCursor.Position = UDim2.new(0, 0, h, 0)
                        SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        Update()
                    end
                end
                local function SetSV(input)
                    local rX = math.clamp((input.Position.X - SVMap.AbsolutePosition.X) / SVMap.AbsoluteSize.X, 0, 1)
                    local rY = math.clamp((input.Position.Y - SVMap.AbsolutePosition.Y) / SVMap.AbsoluteSize.Y, 0, 1)
                    s = rX
                    v = 1 - rY
                    SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    Update()
                end
                local function SetH(input)
                    local rY = math.clamp((input.Position.Y - HueBar.AbsolutePosition.Y) / HueBar.AbsoluteSize.Y, 0, 1)
                    h = rY
                    HCursor.Position = UDim2.new(0, 0, h, 0)
                    Update()
                end
                local dragSV = false
                local dragInputSV
                local sv1 = SVMap.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragSV = true
                        dragInputSV = input
                        SetSV(input)
                        local sc2
                        sc2 = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragSV = false
                                sc2:Disconnect()
                            end
                        end)
                    end
                end)
                local sv3 = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if dragSV then dragInputSV = input end
                    end
                end)
                local sv4 = RunService.RenderStepped:Connect(function()
                    if dragSV and dragInputSV then SetSV(dragInputSV) end
                end)
                table.insert(Library.Connections, sv1)
                table.insert(Library.Connections, sv3)
                table.insert(Library.Connections, sv4)
                local dragH = false
                local dragInputH
                local h1 = HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragH = true
                        dragInputH = input
                        SetH(input)
                        local hc2
                        hc2 = input.Changed:Connect(function()
                            if input.UserInputState == Enum.UserInputState.End then
                                dragH = false
                                hc2:Disconnect()
                            end
                        end)
                    end
                end)
                local h3 = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if dragH then dragInputH = input end
                    end
                end)
                local h4 = RunService.RenderStepped:Connect(function()
                    if dragH and dragInputH then SetH(dragInputH) end
                end)
                table.insert(Library.Connections, h1)
                table.insert(Library.Connections, h3)
                table.insert(Library.Connections, h4)
                local pc1 = Preview.MouseButton1Click:Connect(function()
                    isOpen = not isOpen
                    Section.Container.ZIndex = isOpen and 10 or 1
                    ContainerFrame.ZIndex = isOpen and 10 or 5
                    if isOpen then
                        PickerCont.Visible = true
                        Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                        Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                    else
                        Tween(ContainerFrame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                        local t = Tween(PickerCont, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        local pc2
                        pc2 = t.Completed:Connect(function()
                            if not isOpen then PickerCont.Visible = false end
                            pc2:Disconnect()
                        end)
                    end
                end)
                table.insert(Library.Connections, pc1)
                ApplyTooltip(ContainerFrame, tooltipText)
                task.spawn(callback, color)
            end
            return Section
        end
        return Tab
    end
    local Auto_Save_Timer = 0
    local Auto_Save_Conn = RunService.Heartbeat:Connect(function(dt)
        if Library.AutoSaveEnabled and Library.Unsaved then
            Auto_Save_Timer = Auto_Save_Timer + dt
            if Auto_Save_Timer >= 3 then
                Auto_Save_Timer = 0
                Library.Unsaved = false
                Library:SaveConfig("_autosave")
            end
        end
    end)
    table.insert(Library.Connections, Auto_Save_Conn)
    task.defer(function()
        Library:LoadConfig("_autosave")
    end)
    MainScale.Scale = GetBaseScale()
    MainWindow.Visible = true
    return WindowObj
end
return Library
