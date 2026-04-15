local user_input_service = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")
local run_service = game:GetService("RunService")
local players = game:GetService("Players")
local http_service = game:GetService("HttpService")
local stats = game:GetService("Stats")
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local writefile = writefile or function() end
local listfiles = listfiles or function() return {} end
local delfile = delfile or function() end
local core_gui
pcall(function() core_gui = game:GetService("CoreGui") end)
local local_player = players.LocalPlayer

local library = {
    flags = {},
    signals = {},
    defaults = {},
    open = true,
    keybind_list = nil,
    show_keybinds = true,
    screen_gui = nil,
    connections = {},
    elements = {},
    unsaved = false,
    auto_save_enabled = true,
    _menu_bind_connection = nil
}

local config = {
    name = "PHANTOM HUB",
    keybind = Enum.KeyCode.LeftControl,
    duration = 0.3,
    font_main = Enum.Font.GothamMedium,
    font_bold = Enum.Font.GothamBold,
    config_folder = "PhantomHub"
}

if not isfolder(config.config_folder) then makefolder(config.config_folder) end

local theme = {
    background = Color3.fromHex("#080505"),
    sidebar = Color3.fromHex("#0c0707"),
    container = Color3.fromHex("#140b0b"),
    section = Color3.fromHex("#1a0e0e"),
    accent = Color3.fromHex("#ff1a1a"),
    text = Color3.fromHex("#ffffff"),
    text_dark = Color3.fromHex("#997373"),
    stroke = Color3.fromHex("#2e1717"),
    success = Color3.fromHex("#00ff88"),
    danger = Color3.fromHex("#ff4444")
}

local theme_registry = {}
setmetatable(theme_registry, { __mode = "k" })

local function register_theme(instance, prop_type)
    theme_registry[instance] = prop_type
    return instance
end

function library:update_theme(new_color)
    theme.accent = new_color
    for instance, prop_type in pairs(theme_registry) do
        if instance and instance.Parent then
            if prop_type == "TextColor" then instance.TextColor3 = new_color
            elseif prop_type == "BackgroundColor" then instance.BackgroundColor3 = new_color
            elseif prop_type == "BorderColor" then
                if instance:IsA("UIStroke") then instance.Color = new_color else instance.BorderColor3 = new_color end
            elseif prop_type == "ImageColor" then instance.ImageColor3 = new_color
            elseif prop_type == "ScrollBar" then instance.ScrollBarImageColor3 = new_color
            end
        end
    end
end

local function get_parent()
    if core_gui then return core_gui end
    return local_player:WaitForChild("PlayerGui")
end

local function create_tween(obj, props, time_val, style, dir)
    time_val = time_val or config.duration
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local t = tween_service:Create(obj, TweenInfo.new(time_val, style, dir), props)
    t:Play()
    return t
end

local function create_corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function create_stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or theme.stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function round_to_increment(value, increment)
    if increment <= 0 then return value end
    return math.round(value / increment) * increment
end

local function format_number(value, increment)
    if increment >= 1 then
        return tostring(math.round(value))
    end
    local str = tostring(increment)
    local dot_pos = string.find(str, "%.")
    if dot_pos then
        local decimals = #str - dot_pos
        return string.format("%." .. decimals .. "f", value)
    end
    return tostring(value)
end

local function make_draggable(drag_obj, move_obj, on_drag_callback)
    local dragging = false
    local drag_start
    local start_pos
    local input_changed_conn
    local input_ended_conn

    local input_began_conn = drag_obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
            drag_start = input.Position
            start_pos = move_obj.Position
            if input_changed_conn then input_changed_conn:Disconnect() end
            if input_ended_conn then input_ended_conn:Disconnect() end
            input_changed_conn = user_input_service.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local scale_obj = move_obj:FindFirstChildWhichIsA("UIScale")
                    local scale_mult = scale_obj and scale_obj.Scale or 1
                    local delta = (inp.Position - drag_start) / scale_mult
                    if not dragging and delta.Magnitude > 5 then
                        dragging = true
                    end
                    if dragging then
                        move_obj.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + delta.X, start_pos.Y.Scale, start_pos.Y.Offset + delta.Y)
                    end
                end
            end)
            input_ended_conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if input_changed_conn then input_changed_conn:Disconnect() end
                    if input_ended_conn then input_ended_conn:Disconnect() end
                    if on_drag_callback then
                        on_drag_callback(dragging)
                    end
                    dragging = false
                end
            end)
            table.insert(library.connections, input_changed_conn)
            table.insert(library.connections, input_ended_conn)
        end
    end)
    table.insert(library.connections, input_began_conn)
    return function() return dragging end
end

local function make_resizable(resize_btn, frame, min_size)
    local resize_conn = resize_btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local drag_start = input.Position
            local start_size_offset = frame.Size
            local start_pos = frame.Position
            local scale_obj = frame:FindFirstChildWhichIsA("UIScale")
            local scale_mult = scale_obj and scale_obj.Scale or 1
            if scale_mult <= 0 then scale_mult = 1 end
            local input_changed_conn
            local input_ended_conn
            input_changed_conn = user_input_service.InputChanged:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                    local delta = inp.Position - drag_start
                    local new_x = math.max(min_size.X, start_size_offset.X.Offset + (delta.X / scale_mult))
                    local new_y = math.max(min_size.Y, start_size_offset.Y.Offset + (delta.Y / scale_mult))
                    local diff_x_visual = (new_x - start_size_offset.X.Offset) * scale_mult
                    local diff_y_visual = (new_y - start_size_offset.Y.Offset) * scale_mult
                    frame.Size = UDim2.new(0, new_x, 0, new_y)
                    frame.Position = UDim2.new(start_pos.X.Scale, start_pos.X.Offset + (diff_x_visual / 2), start_pos.Y.Scale, start_pos.Y.Offset + (diff_y_visual / 2))
                end
            end)
            input_ended_conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    if input_changed_conn then input_changed_conn:Disconnect() end
                    if input_ended_conn then input_ended_conn:Disconnect() end
                end
            end)
            table.insert(library.connections, input_changed_conn)
            table.insert(library.connections, input_ended_conn)
        end
    end)
    table.insert(library.connections, resize_conn)
end

local function get_base_scale()
    local vp = workspace.CurrentCamera.ViewportSize
    if vp.X < 1 or vp.Y < 1 then return 1 end
    local scale_x = vp.X / 800
    local scale_y = vp.Y / 500
    local scale = math.min(scale_x, scale_y)
    if scale < 1 then
        return math.clamp(scale * 0.95, 0.4, 1)
    end
    return 1
end

function library:unload()
    for _, conn in ipairs(library.connections) do pcall(function() conn:Disconnect() end) end
    library.connections = {}
    if library.screen_gui then pcall(function() library.screen_gui:Destroy() end) library.screen_gui = nil end
    if library.keybind_list then pcall(function() library.keybind_list.screen:Destroy() end) library.keybind_list = nil end
    for _, g in pairs(get_parent():GetChildren()) do
        if g.Name == "PrismaMini" or g.Name == config.name or g.Name == "PrismaKeybinds" or g.Name == "PrismaLoader" or g.Name == "PhantomNotifications" or g.Name == "PhantomWatermark" or g.Name == "PhantomTooltip" or g.Name == "PhantomMiniButton" then
            pcall(function() g:Destroy() end)
        end
    end
end

function library:get_configs()
    local configs = {}
    if isfolder(config.config_folder) then
        local files = listfiles(config.config_folder)
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

local ignored_flags = {
    ConfigSelectorFlag = true,
    MenuAccentColor = true,
    KeybindListToggle = true,
}

function library:save_config(name)
    if not name or name == "" then return false end
    local save_flags = {}
    for k, v in pairs(library.flags) do
        if ignored_flags[k] then continue end
        if typeof(v) == "Color3" then
            save_flags[k] = {Type = "Color3", Hex = v:ToHex()}
        elseif typeof(v) == "EnumItem" then
            save_flags[k] = {Type = "EnumItem", EnumType = tostring(v.EnumType), Name = v.Name}
        elseif type(v) == "table" then
            local serialized = {}
            for tk, tv in pairs(v) do
                if typeof(tv) == "EnumItem" then
                    serialized[tk] = {Type = "EnumItem", EnumType = tostring(tv.EnumType), Name = tv.Name}
                elseif typeof(tv) == "Color3" then
                    serialized[tk] = {Type = "Color3", Hex = tv:ToHex()}
                else
                    serialized[tk] = tv
                end
            end
            save_flags[k] = {Type = "Table", Value = serialized}
        else
            save_flags[k] = v
        end
    end
    local ok, json = pcall(http_service.JSONEncode, http_service, save_flags)
    if ok then
        pcall(function()
            writefile(config.config_folder .. "/" .. name .. ".json", json)
        end)
        return true
    end
    return false
end

function library:load_config(name)
    if not name or name == "" then return false end
    local path = config.config_folder .. "/" .. name .. ".json"
    if not isfile(path) then return false end
    local content = readfile(path)
    local success, data = pcall(http_service.JSONDecode, http_service, content)
    if success and type(data) == "table" then
        for flag, value in pairs(data) do
            if ignored_flags[flag] then continue end
            local parsed_value = value
            if type(value) == "table" and value.Type then
                if value.Type == "Color3" then
                    pcall(function() parsed_value = Color3.fromHex(value.Hex) end)
                elseif value.Type == "EnumItem" then
                    pcall(function() 
                        if Enum[tostring(value.EnumType)] and Enum[tostring(value.EnumType)][value.Name] then
                            parsed_value = Enum[tostring(value.EnumType)][value.Name] 
                        end
                    end)
                elseif value.Type == "Table" then
                    local deserialized = {}
                    if type(value.Value) == "table" then
                        for tk, tv in pairs(value.Value) do
                            if type(tv) == "table" and tv.Type then
                                if tv.Type == "EnumItem" then
                                    pcall(function() 
                                        if Enum[tostring(tv.EnumType)] and Enum[tostring(tv.EnumType)][tv.Name] then
                                            deserialized[tk] = Enum[tostring(tv.EnumType)][tv.Name] 
                                        end
                                    end)
                                elseif tv.Type == "Color3" then
                                    pcall(function() deserialized[tk] = Color3.fromHex(tv.Hex) end)
                                else
                                    deserialized[tk] = tv
                                end
                            else
                                deserialized[tk] = tv
                            end
                        end
                    end
                    parsed_value = deserialized
                end
            end
            library.flags[flag] = parsed_value
        end
        for flag, value in pairs(library.flags) do
            if ignored_flags[flag] then continue end
            if data[flag] ~= nil and library.signals[flag] then
                task.spawn(library.signals[flag], value)
            end
        end
        return true
    end
    return false
end

function library:delete_config(name)
    if not name or name == "" then return false end
    local path = config.config_folder .. "/" .. name .. ".json"
    if isfile(path) then
        pcall(function() delfile(path) end)
        return true
    end
    return false
end

function library:config_exists(name)
    if not name or name == "" then return false end
    return isfile(config.config_folder .. "/" .. name .. ".json")
end

local tooltip_gui = Instance.new("ScreenGui")
tooltip_gui.Name = "PhantomTooltip"
tooltip_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
tooltip_gui.Parent = get_parent()

local tooltip_label = Instance.new("TextLabel")
tooltip_label.BackgroundTransparency = 0.05
tooltip_label.BackgroundColor3 = theme.container
tooltip_label.TextColor3 = theme.text
tooltip_label.Font = config.font_main
tooltip_label.TextSize = 12
tooltip_label.Visible = false
tooltip_label.Parent = tooltip_gui
tooltip_label.ZIndex = 1000
tooltip_label.RichText = true
create_corner(tooltip_label, 4)
create_stroke(tooltip_label, theme.stroke, 1)

local function apply_tooltip(gui_obj, text)
    if not text or text == "" then return end
    local hovered = false
    local enter_conn = gui_obj.MouseEnter:Connect(function()
        hovered = true
        task.delay(0.5, function()
            if hovered and library.open then
                tooltip_label.Text = " " .. text .. " "
                tooltip_label.Size = UDim2.new(0, tooltip_label.TextBounds.X + 10, 0, 20)
                local m_pos = user_input_service:GetMouseLocation()
                tooltip_label.Position = UDim2.new(0, m_pos.X + 10, 0, m_pos.Y - 25)
                tooltip_label.Visible = true
            end
        end)
    end)
    local move_conn = gui_obj.MouseMoved:Connect(function()
        if tooltip_label.Visible then
            local m_pos = user_input_service:GetMouseLocation()
            tooltip_label.Position = UDim2.new(0, m_pos.X + 10, 0, m_pos.Y - 25)
        end
    end)
    local leave_conn = gui_obj.MouseLeave:Connect(function()
        hovered = false
        tooltip_label.Visible = false
    end)
    table.insert(library.connections, enter_conn)
    table.insert(library.connections, move_conn)
    table.insert(library.connections, leave_conn)
end

function library:notify(title, text, duration)
    local notif_gui = get_parent():FindFirstChild("PhantomNotifications")
    if not notif_gui then
        notif_gui = Instance.new("ScreenGui")
        notif_gui.Name = "PhantomNotifications"
        notif_gui.Parent = get_parent()
        local container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(0, 250, 1, -20)
        container.Position = UDim2.new(1, -270, 0, 10)
        container.BackgroundTransparency = 1
        container.Parent = notif_gui
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        layout.Padding = UDim.new(0, 10)
        layout.Parent = container
    end
    local notif_frame = Instance.new("Frame")
    notif_frame.Size = UDim2.new(1, 0, 0, 60)
    notif_frame.BackgroundColor3 = theme.background
    notif_frame.BackgroundTransparency = 0.1
    notif_frame.Position = UDim2.new(1, 300, 0, 0)
    notif_frame.Parent = notif_gui.Container
    create_corner(notif_frame, 6)
    create_stroke(notif_frame, theme.stroke, 1)
    local n_noise = Instance.new("ImageLabel")
    n_noise.Size = UDim2.new(1, 0, 1, 0)
    n_noise.BackgroundTransparency = 1
    n_noise.Image = "rbxassetid://9968344105"
    n_noise.ImageTransparency = 0.9
    n_noise.ScaleType = Enum.ScaleType.Tile
    n_noise.TileSize = UDim2.new(0, 100, 0, 100)
    n_noise.Parent = notif_frame
    create_corner(n_noise, 6)
    local n_title = Instance.new("TextLabel")
    n_title.Size = UDim2.new(1, -10, 0, 20)
    n_title.Position = UDim2.new(0, 10, 0, 5)
    n_title.BackgroundTransparency = 1
    n_title.Text = title
    n_title.TextColor3 = theme.accent
    n_title.Font = config.font_bold
    n_title.TextSize = 13
    n_title.TextXAlignment = Enum.TextXAlignment.Left
    n_title.RichText = true
    n_title.Parent = notif_frame
    register_theme(n_title, "TextColor")
    local n_text = Instance.new("TextLabel")
    n_text.Size = UDim2.new(1, -20, 0, 20)
    n_text.Position = UDim2.new(0, 10, 0, 25)
    n_text.BackgroundTransparency = 1
    n_text.Text = text
    n_text.TextColor3 = theme.text
    n_text.Font = config.font_main
    n_text.TextSize = 12
    n_text.TextXAlignment = Enum.TextXAlignment.Left
    n_text.RichText = true
    n_text.Parent = notif_frame
    local timebar_bg = Instance.new("Frame")
    timebar_bg.Size = UDim2.new(1, 0, 0, 2)
    timebar_bg.Position = UDim2.new(0, 0, 1, -2)
    timebar_bg.BackgroundColor3 = theme.container
    timebar_bg.BorderSizePixel = 0
    timebar_bg.Parent = notif_frame
    create_corner(timebar_bg, 2)
    local timebar = Instance.new("Frame")
    timebar.Size = UDim2.new(1, 0, 1, 0)
    timebar.BackgroundColor3 = theme.accent
    timebar.BorderSizePixel = 0
    timebar.Parent = timebar_bg
    create_corner(timebar, 2)
    register_theme(timebar, "BackgroundColor")
    create_tween(notif_frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    create_tween(timebar, {Size = UDim2.new(0, 0, 1, 0)}, duration, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        create_tween(notif_frame, {Position = UDim2.new(1, 300, 0, 0)}, 0.4).Completed:Wait()
        notif_frame:Destroy()
    end)
end

function library:init_watermark()
    local watermark_gui = Instance.new("ScreenGui")
    watermark_gui.Name = "PhantomWatermark"
    watermark_gui.Parent = get_parent()
    watermark_gui.IgnoreGuiInset = true
    watermark_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 0, 0, 26)
    frame.Position = UDim2.new(1, -20, 0, 10)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundColor3 = theme.background
    frame.BackgroundTransparency = 0.05
    frame.Parent = watermark_gui
    create_corner(frame, 4)
    create_stroke(frame, theme.stroke, 1)
    local glow = create_stroke(frame, theme.accent, 2, 0.8)
    register_theme(glow, "BorderColor")
    local accent_line = Instance.new("Frame")
    accent_line.Size = UDim2.new(1, 0, 0, 2)
    accent_line.Position = UDim2.new(0, 0, 0, 0)
    accent_line.BackgroundColor3 = theme.accent
    accent_line.BorderSizePixel = 0
    accent_line.Parent = frame
    create_corner(accent_line, 2)
    register_theme(accent_line, "BackgroundColor")
    local w_noise = Instance.new("ImageLabel")
    w_noise.Size = UDim2.new(1, 0, 1, 0)
    w_noise.BackgroundTransparency = 1
    w_noise.Image = "rbxassetid://9968344105"
    w_noise.ImageTransparency = 0.95
    w_noise.ScaleType = Enum.ScaleType.Tile
    w_noise.TileSize = UDim2.new(0, 100, 0, 100)
    w_noise.Parent = frame
    create_corner(w_noise, 4)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = config.font_bold
    label.TextSize = 12
    label.TextColor3 = theme.text
    label.RichText = true
    label.Parent = frame
    local last_update = 0
    local frames = 0
    local conn
    conn = run_service.Heartbeat:Connect(function(dt)
        frames = frames + 1
        local now = tick()
        if now - last_update >= 1 then
            local fps = frames
            frames = 0
            last_update = now
            local ping = "0"
            pcall(function()
                local s = stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
                ping = s:match("%d+") or "0"
            end)
            local time_str = os.date("%H:%M:%S")
            local text = string.format(" <font color='#%s'>%s</font> | FPS: %d | Ping: %sms | %s ", theme.accent:ToHex(), config.name, fps, ping, time_str)
            label.Text = text
            local bounds = label.TextBounds.X + 20
            create_tween(frame, {Size = UDim2.new(0, bounds, 0, 26)}, 0.1)
        end
    end)
    table.insert(library.connections, conn)
end

function library:create_keybind_list()
    if library.keybind_list then return end
    local screen = Instance.new("ScreenGui")
    screen.Name = "PrismaKeybinds"
    screen.Parent = get_parent()
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 30)
    frame.Position = UDim2.new(0.01, 0, 0.4, 0)
    frame.BackgroundColor3 = theme.background
    frame.BackgroundTransparency = 0.1
    frame.Parent = screen
    frame.Active = true
    create_corner(frame, 4)
    create_stroke(frame, theme.stroke, 1, 0)
    make_draggable(frame, frame)
    local k_noise = Instance.new("ImageLabel")
    k_noise.Size = UDim2.new(1, 0, 1, 0)
    k_noise.BackgroundTransparency = 1
    k_noise.Image = "rbxassetid://9968344105"
    k_noise.ImageTransparency = 0.9
    k_noise.ScaleType = Enum.ScaleType.Tile
    k_noise.TileSize = UDim2.new(0, 100, 0, 100)
    k_noise.Parent = frame
    create_corner(k_noise, 4)
    local header = Instance.new("Frame")
    frame.ClipsDescendants = true
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundColor3 = theme.sidebar
    header.Parent = frame
    create_corner(header, 4)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Keybinds"
    title.TextColor3 = theme.accent
    title.Font = config.font_bold
    title.TextSize = 12
    title.RichText = true
    title.Parent = header
    register_theme(title, "TextColor")
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 26)
    container.BackgroundTransparency = 1
    container.Parent = frame
    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = container
    local size_conn = list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.Size = UDim2.new(0, 180, 0, list.AbsoluteContentSize.Y + 30)
    end)
    table.insert(library.connections, size_conn)
    library.keybind_list = {frame = frame, container = container, screen = screen}
    frame.Visible = false
end

function library:update_keybind_list(name, key, active, mode)
    if not library.keybind_list then library:create_keybind_list() end
    local existing = library.keybind_list.container:FindFirstChild(name)
    if not library.show_keybinds then
        library.keybind_list.frame.Visible = false
        return
    end
    if active and key ~= "None" and key ~= "Unknown" and mode ~= "Always" then
        library.keybind_list.frame.Visible = true
        if not existing then
            local item = Instance.new("Frame")
            item.Name = name
            item.Size = UDim2.new(1, 0, 0, 20)
            item.BackgroundTransparency = 1
            item.Parent = library.keybind_list.container
            local l_name = Instance.new("TextLabel")
            l_name.Size = UDim2.new(0.6, 0, 1, 0)
            l_name.Position = UDim2.new(0, 5, 0, 0)
            l_name.BackgroundTransparency = 1
            l_name.Text = name
            l_name.TextColor3 = theme.text
            l_name.Font = config.font_main
            l_name.TextSize = 12
            l_name.TextXAlignment = Enum.TextXAlignment.Left
            l_name.RichText = true
            l_name.Parent = item
            local l_key = Instance.new("TextLabel")
            l_key.Size = UDim2.new(0.4, -5, 1, 0)
            l_key.Position = UDim2.new(0.6, 0, 0, 0)
            l_key.BackgroundTransparency = 1
            l_key.Text = "[" .. key .. "]"
            l_key.TextColor3 = theme.text_dark
            l_key.Font = config.font_main
            l_key.TextSize = 12
            l_key.TextXAlignment = Enum.TextXAlignment.Right
            l_key.RichText = true
            l_key.Parent = item
        else
            local l_key = existing:FindFirstChildWhichIsA("TextLabel", true)
            if l_key then l_key.Text = "[" .. key .. "]" end
        end
    else
        if existing then existing:Destroy() end
        if #library.keybind_list.container:GetChildren() <= 1 then
            library.keybind_list.frame.Visible = false
        end
    end
end

local function toggle_clips_descendants(gui_obj, state)
    local current = gui_obj
    while current and current ~= game and not current:IsA("ScreenGui") do
        if current:IsA("ScrollingFrame") or current:IsA("CanvasGroup") then
            current.ClipsDescendants = state
        end
        current = current.Parent
    end
end

local function create_dropdown_element(text, flag, options, default, tooltip_text, callback, parent_frame, section_ref, is_multi, custom_parent)
    local selected
    if library.flags[flag] ~= nil then
        selected = library.flags[flag]
    else
        if is_multi then
            if type(default) ~= "table" then selected = {default} else selected = default end
        else
            selected = default or options[1]
        end
    end
    library.defaults[flag] = selected
    library.flags[flag] = selected
    local is_dropped = false
    local parent = custom_parent or parent_frame
    local drop_frame = Instance.new("Frame")
    drop_frame.Size = UDim2.new(1, custom_parent and -20 or 0, 0, 46)
    if custom_parent then drop_frame.Position = UDim2.new(0, 20, 0, 0) end
    drop_frame.BackgroundTransparency = 1
    drop_frame.Parent = parent
    drop_frame.ZIndex = 5
    local d_label = Instance.new("TextLabel")
    d_label.Text = text
    d_label.Font = config.font_main
    d_label.TextSize = 13
    d_label.TextColor3 = custom_parent and theme.text_dark or theme.text
    d_label.Size = UDim2.new(1, 0, 0, 16)
    d_label.Position = UDim2.new(0, 5, 0, 0)
    d_label.TextXAlignment = Enum.TextXAlignment.Left
    d_label.BackgroundTransparency = 1
    d_label.RichText = true
    d_label.Parent = drop_frame
    local interactive = Instance.new("TextButton")
    interactive.Size = UDim2.new(1, 0, 0, 26)
    interactive.Position = UDim2.new(0, 0, 0, 20)
    interactive.BackgroundColor3 = theme.container
    interactive.Text = ""
    interactive.AutoButtonColor = false
    interactive.Parent = drop_frame
    interactive.ZIndex = 5
    create_corner(interactive, 4)
    create_stroke(interactive, theme.stroke, 1, 0.5)
    local selected_text = Instance.new("TextLabel")
    selected_text.Font = config.font_main
    selected_text.TextSize = 13
    selected_text.TextColor3 = theme.text
    selected_text.Size = UDim2.new(1, -25, 1, 0)
    selected_text.Position = UDim2.new(0, 8, 0, 0)
    selected_text.TextXAlignment = Enum.TextXAlignment.Left
    selected_text.BackgroundTransparency = 1
    selected_text.ZIndex = 6
    selected_text.ClipsDescendants = true
    selected_text.RichText = true
    selected_text.Parent = interactive
    local arrow = Instance.new("ImageLabel")
    arrow.Image = "rbxassetid://10709790948"
    arrow.Size = UDim2.new(0, 18, 0, 18)
    arrow.Position = UDim2.new(1, -20, 0.5, 0)
    arrow.AnchorPoint = Vector2.new(0, 0.5)
    arrow.BackgroundTransparency = 1
    arrow.ImageColor3 = theme.text_dark
    arrow.Parent = interactive
    arrow.ZIndex = 6
    local list_frame = Instance.new("ScrollingFrame")
    list_frame.Size = UDim2.new(1, 0, 0, 0)
    list_frame.Position = UDim2.new(0, 0, 1, 5)
    list_frame.BackgroundColor3 = theme.container
    list_frame.BorderSizePixel = 0
    list_frame.Parent = interactive
    list_frame.ZIndex = 100
    list_frame.Visible = false
    list_frame.Active = true
    list_frame.ScrollBarThickness = 2
    list_frame.ScrollBarImageColor3 = theme.accent
    create_corner(list_frame, 4)
    create_stroke(list_frame, theme.stroke, 1, 0.5)
    local i_list = Instance.new("UIListLayout")
    i_list.SortOrder = Enum.SortOrder.LayoutOrder
    i_list.Parent = list_frame
    local list_conn = i_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        list_frame.CanvasSize = UDim2.new(0, 0, 0, i_list.AbsoluteContentSize.Y)
    end)
    table.insert(library.connections, list_conn)
    local function close_dropdown()
        is_dropped = false
        if section_ref and section_ref.container then section_ref.container.ZIndex = 1 end
        drop_frame.ZIndex = 5
        if custom_parent then custom_parent.ZIndex = 1 end
        create_tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, 46)}, 0.2)
        local t = create_tween(list_frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        create_tween(arrow, {Rotation = 0}, 0.2)
        t.Completed:Connect(function()
            if not is_dropped then 
                list_frame.Visible = false 
                toggle_clips_descendants(drop_frame, true)
            end
        end)
    end
    local option_btns = {}
    local function is_selected_opt(opt)
        if is_multi then
            for _, v in ipairs(selected) do
                if v == opt then return true end
            end
            return false
        else
            return selected == opt
        end
    end
    local function update_visuals()
        if is_multi then
            selected_text.Text = (#selected > 0 and table.concat(selected, ", ") or "None")
        else
            selected_text.Text = tostring(selected)
        end
        for opt, btn in pairs(option_btns) do
            if is_selected_opt(opt) then
                btn.TextColor3 = theme.accent
            else
                btn.TextColor3 = theme.text_dark
            end
        end
    end
    local function build_options(new_options)
        for _, btn in pairs(option_btns) do btn:Destroy() end
        table.clear(option_btns)
        options = new_options
        for _, opt in ipairs(options) do
            local opt_btn = Instance.new("TextButton")
            opt_btn.Size = UDim2.new(1, 0, 0, 24)
            opt_btn.BackgroundColor3 = theme.container
            opt_btn.BackgroundTransparency = 1
            opt_btn.Text = opt
            opt_btn.Font = config.font_main
            opt_btn.TextSize = 12
            opt_btn.RichText = true
            opt_btn.Parent = list_frame
            opt_btn.ZIndex = 101
            if is_selected_opt(opt) then
                opt_btn.TextColor3 = theme.accent
            else
                opt_btn.TextColor3 = theme.text_dark
            end
            option_btns[opt] = opt_btn
            local opt_enter = opt_btn.MouseEnter:Connect(function()
                if not is_selected_opt(opt) then
                    create_tween(opt_btn, {BackgroundTransparency = 0.8, TextColor3 = theme.accent})
                end
            end)
            local opt_leave = opt_btn.MouseLeave:Connect(function()
                if not is_selected_opt(opt) then
                    create_tween(opt_btn, {BackgroundTransparency = 1, TextColor3 = theme.text_dark})
                end
            end)
            local opt_click = opt_btn.MouseButton1Click:Connect(function()
                if is_multi then
                    local found = table.find(selected, opt)
                    if found then table.remove(selected, found) else table.insert(selected, opt) end
                    update_visuals()
                    library.flags[flag] = selected
                    library.unsaved = true
                    callback(selected)
                else
                    selected = opt
                    update_visuals()
                    library.flags[flag] = selected
                    library.unsaved = true
                    callback(selected)
                    close_dropdown()
                end
            end)
            table.insert(library.connections, opt_enter)
            table.insert(library.connections, opt_leave)
            table.insert(library.connections, opt_click)
        end
    end
    build_options(options)
    update_visuals()
    library.signals[flag] = function(val)
        if is_multi then
            if type(val) == "table" then
                selected = val
            else
                selected = {val}
            end
        else
            selected = val
        end
        update_visuals()
        library.unsaved = true
        callback(selected)
    end
    local inter_click = interactive.MouseButton1Click:Connect(function()
        is_dropped = not is_dropped
        if section_ref and section_ref.container then section_ref.container.ZIndex = is_dropped and 10 or 1 end
        drop_frame.ZIndex = is_dropped and 10 or 5
        if custom_parent then custom_parent.ZIndex = is_dropped and 10 or 1 custom_parent.ClipsDescendants = false end
        if is_dropped then
            toggle_clips_descendants(drop_frame, false)
            list_frame.Visible = true
            local list_h = math.min(#options * 24, 200)
            local total_h = 46 + list_h + 5
            create_tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, total_h)}, 0.2)
            create_tween(list_frame, {Size = UDim2.new(1, 0, 0, list_h)}, 0.2)
            create_tween(arrow, {Rotation = 180}, 0.2)
        else
            close_dropdown()
        end
    end)
    table.insert(library.connections, inter_click)
    apply_tooltip(drop_frame, tooltip_text)
    task.spawn(callback, selected)
    local dropdown_obj = {}
    dropdown_obj.frame = drop_frame
    function dropdown_obj:refresh(new_options, new_default)
        if is_multi then
            if type(new_default) ~= "table" then selected = {new_default} else selected = new_default end
        else
            selected = new_default or (new_options[1] or "")
        end
        library.flags[flag] = selected
        build_options(new_options)
        update_visuals()
    end
    function dropdown_obj:get_selected()
        return selected
    end
    function dropdown_obj:set(val)
        if is_multi then
            if type(val) == "table" then selected = val else selected = {val} end
        else
            selected = val
        end
        library.flags[flag] = selected
        update_visuals()
        callback(selected)
    end
    return dropdown_obj
end

local function create_slider_element(text, flag, min, max, default, increment, tooltip_text, callback, parent_frame, sec_data)
    increment = increment or 1
    local val = library.flags[flag] or round_to_increment(default or min, increment)
    library.defaults[flag] = round_to_increment(default or min, increment)
    library.flags[flag] = val
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 42)
    frame.BackgroundTransparency = 1
    frame.Parent = parent_frame
    if sec_data then table.insert(sec_data.items, {name = text, instance = frame}) end
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Font = config.font_main
    label.TextSize = 13
    label.TextColor3 = theme.text
    label.Size = UDim2.new(0.6, 0, 0, 16)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.RichText = true
    label.Parent = frame
    local val_label = Instance.new("TextBox")
    val_label.Text = format_number(val, increment)
    val_label.Font = config.font_main
    val_label.TextSize = 13
    val_label.TextColor3 = theme.text
    val_label.Size = UDim2.new(0.4, -5, 0, 16)
    val_label.Position = UDim2.new(0.6, 0, 0, 0)
    val_label.TextXAlignment = Enum.TextXAlignment.Right
    val_label.BackgroundTransparency = 1
    val_label.ClearTextOnFocus = true
    val_label.Parent = frame
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 6)
    bar.Position = UDim2.new(0, 0, 0, 24)
    bar.BackgroundColor3 = theme.container
    bar.Parent = frame
    bar.Active = true
    create_corner(bar, 3)
    create_stroke(bar, theme.stroke, 1, 0.5)
    local fill = Instance.new("Frame")
    local range = max - min
    local init_ratio = range > 0 and (val - min) / range or 0
    fill.Size = UDim2.new(init_ratio, 0, 1, 0)
    fill.BackgroundColor3 = theme.accent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    create_corner(fill, 3)
    register_theme(fill, "BackgroundColor")
    local dragging = false
    local input_changed_conn = nil
    local function set_from_input(input)
        local r = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local raw = min + (max - min) * r
        val = round_to_increment(raw, increment)
        val = math.clamp(val, min, max)
        local display_ratio = range > 0 and (val - min) / range or 0
        val_label.Text = format_number(val, increment)
        create_tween(fill, {Size = UDim2.new(display_ratio, 0, 1, 0)}, 0.05)
        library.flags[flag] = val
        library.unsaved = true
        callback(val)
    end
    local bar_input_conn = bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            set_from_input(i)
            input_changed_conn = user_input_service.InputChanged:Connect(function(inp)
                if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and dragging then set_from_input(inp) end
            end)
            local input_ended_conn
            input_ended_conn = user_input_service.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                    if input_changed_conn then input_changed_conn:Disconnect() input_changed_conn = nil end
                    if input_ended_conn then input_ended_conn:Disconnect() input_ended_conn = nil end
                end
            end)
            table.insert(library.connections, input_changed_conn)
            table.insert(library.connections, input_ended_conn)
        end
    end)
    table.insert(library.connections, bar_input_conn)
    local val_focus_conn = val_label.FocusLost:Connect(function(enter)
        if enter then
            local num = tonumber(val_label.Text)
            if num then
                num = round_to_increment(num, increment)
                num = math.clamp(num, min, max)
                val = num
                local display_ratio = range > 0 and (val - min) / range or 0
                val_label.Text = format_number(val, increment)
                create_tween(fill, {Size = UDim2.new(display_ratio, 0, 1, 0)}, 0.05)
                library.flags[flag] = val
                library.unsaved = true
                callback(val)
            else
                val_label.Text = format_number(val, increment)
            end
        else
            val_label.Text = format_number(val, increment)
        end
    end)
    table.insert(library.connections, val_focus_conn)
    library.signals[flag] = function(loaded_val)
        val = round_to_increment(loaded_val, increment)
        val = math.clamp(val, min, max)
        local display_ratio = range > 0 and (val - min) / range or 0
        val_label.Text = format_number(val, increment)
        create_tween(fill, {Size = UDim2.new(display_ratio, 0, 1, 0)}, 0.05)
        library.unsaved = true
        callback(val)
    end
    apply_tooltip(frame, tooltip_text)
    task.spawn(callback, val)
    return frame
end

function library:create_window(options)
    if options and options.name then config.name = options.name end
    if options and options.config_folder then config.config_folder = options.config_folder end
    if not isfolder(config.config_folder) then makefolder(config.config_folder) end
    library:unload()
    library:init_watermark()
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = config.name
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen_gui.IgnoreGuiInset = true
    screen_gui.ResetOnSpawn = false
    screen_gui.Parent = get_parent()
    library.screen_gui = screen_gui
    local mini_gui = Instance.new("ScreenGui")
    mini_gui.Name = "PhantomMiniButton"
    mini_gui.Parent = get_parent()
    mini_gui.Enabled = true
    mini_gui.IgnoreGuiInset = true
    local mini_button = Instance.new("ImageButton")
    mini_button.Size = UDim2.new(0, 46, 0, 46)
    mini_button.Position = UDim2.new(0, 20, 0.5, -23)
    mini_button.BackgroundColor3 = theme.background
    mini_button.BackgroundTransparency = 0.1
    mini_button.Image = "rbxassetid://112964043447417"
    mini_button.ImageColor3 = theme.accent
    mini_button.ScaleType = Enum.ScaleType.Fit
    mini_button.AutoButtonColor = false
    mini_button.Active = true
    mini_button.Parent = mini_gui
    create_corner(mini_button, 23)
    create_stroke(mini_button, theme.accent, 2, 0.3)
    register_theme(mini_button, "ImageColor")
    local mini_was_dragged = false
    make_draggable(mini_button, mini_button, function(was_drag)
        mini_was_dragged = was_drag
    end)
    local last_mini_click = 0
    local mini_click_conn = mini_button.MouseButton1Click:Connect(function()
        if tick() - last_mini_click < 0.2 then return end
        last_mini_click = tick()
        if mini_was_dragged then
            mini_was_dragged = false
            return
        end
        if library.open then
            library.open = false
            if library._is_settings then
                create_tween(library._set_scale, {Scale = get_base_scale() * 0.8}, 0.2).Completed:Wait()
            else
                create_tween(library._main_scale, {Scale = get_base_scale() * 0.8}, 0.2).Completed:Wait()
            end
            library._main_window.Visible = false
            library._settings_window.Visible = false
            tooltip_label.Visible = false
        else
            library.open = true
            if library._is_settings then
                library._settings_window.Visible = true
                library._settings_window.BackgroundTransparency = 0.1
                library._set_scale.Scale = get_base_scale() * 0.8
                create_tween(library._set_scale, {Scale = get_base_scale()}, 0.3)
            else
                library._main_window.Visible = true
                library._main_window.BackgroundTransparency = 0.1
                library._main_scale.Scale = get_base_scale() * 0.8
                create_tween(library._main_scale, {Scale = get_base_scale()}, 0.3)
            end
        end
    end)
    table.insert(library.connections, mini_click_conn)
    local function create_base_frame(name)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.new(0, 650, 0, 400)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundColor3 = theme.background
        frame.BackgroundTransparency = 0.1
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = false
        frame.Visible = false
        frame.Parent = screen_gui
        frame.Active = true
        local size_constraint = Instance.new("UISizeConstraint")
        size_constraint.MaxSize = Vector2.new(1400, 900)
        size_constraint.MinSize = Vector2.new(450, 300)
        size_constraint.Parent = frame
        create_corner(frame, 6)
        create_stroke(frame, theme.stroke, 1, 0)
        local bg_noise = Instance.new("ImageLabel")
        bg_noise.Size = UDim2.new(1, 0, 1, 0)
        bg_noise.BackgroundTransparency = 1
        bg_noise.Image = "rbxassetid://9968344105"
        bg_noise.ImageTransparency = 0.8
        bg_noise.ScaleType = Enum.ScaleType.Tile
        bg_noise.TileSize = UDim2.new(0, 100, 0, 100)
        bg_noise.Parent = frame
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1,0,1,0)
        overlay.BackgroundColor3 = theme.background
        overlay.BackgroundTransparency = 0.7
        overlay.Parent = frame
        create_corner(overlay, 6)
        create_corner(bg_noise, 6)
        local drag_header = Instance.new("Frame")
        drag_header.Name = "DragHeader"
        drag_header.Size = UDim2.new(1, 0, 0, 40)
        drag_header.BackgroundTransparency = 1
        drag_header.Parent = frame
        local scale = Instance.new("UIScale")
        scale.Scale = 1
        scale.Parent = frame
        make_draggable(drag_header, frame)
        return frame, scale
    end
    local main_window, main_scale = create_base_frame("MainWindow")
    local settings_window, set_scale = create_base_frame("SettingsWindow")
    library._main_window = main_window
    library._main_scale = main_scale
    library._settings_window = settings_window
    library._set_scale = set_scale
    library._is_settings = false
    local resizer = Instance.new("Frame")
    resizer.Size = UDim2.new(0, 20, 0, 20)
    resizer.Position = UDim2.new(1, 0, 1, 0)
    resizer.AnchorPoint = Vector2.new(1, 1)
    resizer.BackgroundTransparency = 1
    resizer.Parent = main_window
    resizer.ZIndex = 20
    resizer.Active = true
    local resizer_icon = Instance.new("TextLabel")
    resizer_icon.Size = UDim2.new(1, 0, 1, 0)
    resizer_icon.BackgroundTransparency = 1
    resizer_icon.Text = "◢"
    resizer_icon.TextColor3 = theme.text_dark
    resizer_icon.TextSize = 16
    resizer_icon.Parent = resizer
    local resizer_hover = resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then create_tween(resizer_icon, {TextColor3 = theme.accent}) end
    end)
    local resizer_leave = resizer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then create_tween(resizer_icon, {TextColor3 = theme.text_dark}) end
    end)
    table.insert(library.connections, resizer_hover)
    table.insert(library.connections, resizer_leave)
    make_resizable(resizer, main_window, Vector2.new(450, 300))
    local function create_sidebar(parent, is_settings)
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 180, 1, 0)
        bar.BackgroundColor3 = theme.sidebar
        bar.BorderSizePixel = 0
        bar.Parent = parent
        bar.Active = true
        create_corner(bar, 6)
        local div = Instance.new("Frame")
        div.Size = UDim2.new(0, 1, 1, 0)
        div.Position = UDim2.new(1, 0, 0, 0)
        div.BackgroundColor3 = theme.stroke
        div.BorderSizePixel = 0
        div.Parent = bar
        if is_settings then
            local back_btn = Instance.new("TextButton")
            back_btn.Size = UDim2.new(1, -20, 0, 30)
            back_btn.Position = UDim2.new(0, 10, 0, 15)
            back_btn.BackgroundColor3 = theme.container
            back_btn.Text = " < Back to Menu"
            back_btn.Font = config.font_bold
            back_btn.TextSize = 13
            back_btn.TextColor3 = theme.text_dark
            back_btn.TextXAlignment = Enum.TextXAlignment.Left
            back_btn.AutoButtonColor = false
            back_btn.RichText = true
            back_btn.Parent = bar
            create_corner(back_btn, 4)
            create_stroke(back_btn, theme.stroke, 1, 0.5)
            local back_enter = back_btn.MouseEnter:Connect(function() create_tween(back_btn, {TextColor3 = theme.accent}) end)
            local back_leave = back_btn.MouseLeave:Connect(function() create_tween(back_btn, {TextColor3 = theme.text_dark}) end)
            table.insert(library.connections, back_enter)
            table.insert(library.connections, back_leave)
            local title = Instance.new("TextLabel")
            title.Text = "Settings"
            title.Size = UDim2.new(1, 0, 0, 30)
            title.Position = UDim2.new(0, 0, 0, 55)
            title.Font = config.font_bold
            title.TextSize = 22
            title.TextColor3 = theme.text
            title.BackgroundTransparency = 1
            title.RichText = true
            title.Parent = bar
            return bar, nil, back_btn
        else
            local logo = Instance.new("TextLabel")
            logo.Text = config.name
            logo.RichText = true
            logo.Position = UDim2.new(0, 15, 0, 20)
            logo.Size = UDim2.new(1, -30, 0, 30)
            logo.Font = config.font_bold
            logo.TextSize = 20
            logo.TextColor3 = theme.accent
            logo.TextXAlignment = Enum.TextXAlignment.Left
            logo.BackgroundTransparency = 1
            logo.Parent = bar
            register_theme(logo, "TextColor")
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 1, -130)
            container.Position = UDim2.new(0, 0, 0, 60)
            container.BackgroundTransparency = 1
            container.Parent = bar
            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 6)
            list.HorizontalAlignment = Enum.HorizontalAlignment.Center
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Parent = container
            return bar, container, nil
        end
    end
    local main_bar, tab_container, _ = create_sidebar(main_window, false)
    local set_bar, set_container, back_btn = create_sidebar(settings_window, true)
    local profile_btn = Instance.new("TextButton")
    profile_btn.Size = UDim2.new(1, 0, 0, 60)
    profile_btn.Position = UDim2.new(0, 0, 1, 0)
    profile_btn.AnchorPoint = Vector2.new(0, 1)
    profile_btn.BackgroundColor3 = theme.sidebar
    profile_btn.BorderSizePixel = 0
    profile_btn.Text = ""
    profile_btn.AutoButtonColor = false
    profile_btn.Parent = main_bar
    local side_avatar = Instance.new("ImageLabel")
    side_avatar.Size = UDim2.new(0, 36, 0, 36)
    side_avatar.Position = UDim2.new(0, 15, 0.5, 0)
    side_avatar.AnchorPoint = Vector2.new(0, 0.5)
    side_avatar.BackgroundColor3 = theme.container
    local s2, av2 = pcall(function() return players:GetUserThumbnailAsync(local_player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    side_avatar.Image = s2 and av2 or "rbxassetid://0"
    side_avatar.Parent = profile_btn
    create_corner(side_avatar, 18)
    local av_s = create_stroke(side_avatar, theme.accent, 1)
    register_theme(av_s, "BorderColor")
    local side_name = Instance.new("TextLabel")
    side_name.Size = UDim2.new(0, 100, 0, 16)
    side_name.Position = UDim2.new(0, 60, 0.5, -9)
    side_name.AnchorPoint = Vector2.new(0, 0.5)
    side_name.BackgroundTransparency = 1
    side_name.Text = local_player.Name
    side_name.TextColor3 = theme.text
    side_name.Font = config.font_bold
    side_name.TextSize = 13
    side_name.TextXAlignment = Enum.TextXAlignment.Left
    side_name.RichText = true
    side_name.Parent = profile_btn
    local side_sub = Instance.new("TextLabel")
    side_sub.Size = UDim2.new(0, 100, 0, 14)
    side_sub.Position = UDim2.new(0, 60, 0.5, 9)
    side_sub.AnchorPoint = Vector2.new(0, 0.5)
    side_sub.BackgroundTransparency = 1
    side_sub.Text = "Settings"
    side_sub.TextColor3 = theme.text_dark
    side_sub.Font = config.font_main
    side_sub.TextSize = 11
    side_sub.TextXAlignment = Enum.TextXAlignment.Left
    side_sub.RichText = true
    side_sub.Parent = profile_btn
    local is_settings = false
    local animating = false
    local function toggle_main()
        if animating then return end
        animating = true
        library.open = not library.open
        if library.open then
            if is_settings then
                settings_window.Visible = true
                settings_window.BackgroundTransparency = 0.1
                set_scale.Scale = get_base_scale() * 0.8
                create_tween(set_scale, {Scale = get_base_scale()}, 0.3).Completed:Wait()
            else
                main_window.Visible = true
                main_window.BackgroundTransparency = 0.1
                main_scale.Scale = get_base_scale() * 0.8
                create_tween(main_scale, {Scale = get_base_scale()}, 0.3).Completed:Wait()
            end
        else
            if is_settings then
                create_tween(set_scale, {Scale = get_base_scale() * 0.8}, 0.2).Completed:Wait()
            else
                create_tween(main_scale, {Scale = get_base_scale() * 0.8}, 0.2).Completed:Wait()
            end
            main_window.Visible = false
            settings_window.Visible = false
            tooltip_label.Visible = false
        end
        animating = false
    end
    local function switch_to_settings()
        if animating then return end
        animating = true
        settings_window.Position = main_window.Position
        settings_window.Size = main_window.Size
        create_tween(main_scale, {Scale = get_base_scale() * 0.9}, 0.15).Completed:Wait()
        main_window.Visible = false
        settings_window.Visible = true
        settings_window.BackgroundTransparency = 0.1
        set_scale.Scale = get_base_scale() * 0.9
        create_tween(set_scale, {Scale = get_base_scale()}, 0.2).Completed:Wait()
        is_settings = true
        library._is_settings = true
        animating = false
    end
    local function switch_to_main()
        if animating then return end
        animating = true
        main_window.Position = settings_window.Position
        main_window.Size = settings_window.Size
        create_tween(set_scale, {Scale = get_base_scale() * 0.9}, 0.15).Completed:Wait()
        settings_window.Visible = false
        main_window.Visible = true
        main_window.BackgroundTransparency = 0.1
        main_scale.Scale = get_base_scale() * 0.9
        create_tween(main_scale, {Scale = get_base_scale()}, 0.2).Completed:Wait()
        is_settings = false
        library._is_settings = false
        animating = false
    end
    local prof_click = profile_btn.MouseButton1Click:Connect(function() task.spawn(switch_to_settings) end)
    local back_click = back_btn.MouseButton1Click:Connect(function() task.spawn(switch_to_main) end)
    table.insert(library.connections, prof_click)
    table.insert(library.connections, back_click)
    local vp_conn = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if library.open then
            if is_settings and settings_window.Visible then
                set_scale.Scale = get_base_scale()
            elseif not is_settings and main_window.Visible then
                main_scale.Scale = get_base_scale()
            end
        end
    end)
    table.insert(library.connections, vp_conn)
    local function setup_menu_bind()
        if library._menu_bind_connection then
            library._menu_bind_connection:Disconnect()
        end
        library._menu_bind_connection = user_input_service.InputBegan:Connect(function(input, gp)
            if not gp and input.KeyCode == config.keybind then
                task.spawn(toggle_main)
            end
        end)
        table.insert(library.connections, library._menu_bind_connection)
    end
    setup_menu_bind()
    local window_obj = {}
    local main_pages = Instance.new("Frame")
    main_pages.Size = UDim2.new(1, -181, 1, 0)
    main_pages.Position = UDim2.new(0, 181, 0, 0)
    main_pages.BackgroundTransparency = 1
    main_pages.Parent = main_window
    function window_obj:create_raw_section(text, parent)
        local section = {}
        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 0, 0)
        container.BackgroundColor3 = theme.section
        container.Parent = parent
        container.ZIndex = 1
        create_corner(container, 6)
        create_stroke(container, theme.stroke, 1, 0.5)
        section.container = container
        local title = Instance.new("TextLabel")
        title.Text = text
        title.Font = config.font_bold
        title.TextSize = 12
        title.TextColor3 = theme.text_dark
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.RichText = true
        title.Parent = container
        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, -10, 0, 0)
        content.Position = UDim2.new(0, 5, 0, 30)
        content.BackgroundTransparency = 1
        content.Parent = container
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content
        local size_c = list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 40)
        end)
        table.insert(library.connections, size_c)
        function section:button(btn_text, tooltip_text, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = theme.container
            btn.Text = btn_text
            btn.Font = config.font_main
            btn.TextSize = 13
            btn.TextColor3 = theme.text
            btn.AutoButtonColor = false
            btn.RichText = true
            btn.Parent = content
            create_corner(btn, 4)
            local s = create_stroke(btn, theme.stroke, 1, 0.5)
            local e_c = btn.MouseEnter:Connect(function() create_tween(btn, {BackgroundColor3 = theme.stroke}) create_tween(s, {Color = theme.accent}) end)
            local l_c = btn.MouseLeave:Connect(function() create_tween(btn, {BackgroundColor3 = theme.container}) create_tween(s, {Color = theme.stroke}) end)
            local last_click = 0
            local c_c = btn.MouseButton1Click:Connect(function()
                if tick() - last_click < 0.2 then return end
                last_click = tick()
                callback()
            end)
            table.insert(library.connections, e_c)
            table.insert(library.connections, l_c)
            table.insert(library.connections, c_c)
            apply_tooltip(btn, tooltip_text)
            return btn
        end
        function section:toggle(t_text, flag, default, tooltip_text, callback)
            local toggled = default or false
            if library.flags[flag] ~= nil then toggled = library.flags[flag] else library.flags[flag] = toggled end
            library.defaults[flag] = default or false
            local toggle_obj = {}
            library.signals[flag] = function(val)
                if toggled ~= val then
                    toggled = val
                    if toggle_obj.update_anim then toggle_obj.update_anim() end
                    library.unsaved = true
                    callback(val)
                end
            end
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = theme.container
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.Parent = content
            create_corner(btn, 4)
            create_stroke(btn, theme.stroke, 1, 0.5)
            local label = Instance.new("TextLabel")
            label.Text = t_text
            label.Font = config.font_main
            label.TextSize = 13
            label.TextColor3 = theme.text
            label.Size = UDim2.new(1, -30, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.RichText = true
            label.Parent = btn
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 18, 0, 18)
            box.Position = UDim2.new(1, -10, 0.5, 0)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.BackgroundColor3 = theme.background
            box.Parent = btn
            create_corner(box, 4)
            create_stroke(box, theme.stroke, 1, 0.5)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(1, -4, 1, -4)
            fill.Position = UDim2.new(0.5, 0, 0.5, 0)
            fill.AnchorPoint = Vector2.new(0.5, 0.5)
            fill.BackgroundColor3 = theme.accent
            fill.BackgroundTransparency = toggled and 0 or 1
            fill.Parent = box
            create_corner(fill, 3)
            register_theme(fill, "BackgroundColor")
            local sub_container = Instance.new("Frame")
            sub_container.Name = "Sub_" .. t_text
            sub_container.Size = UDim2.new(1, 0, 0, 0)
            sub_container.BackgroundTransparency = 1
            sub_container.ClipsDescendants = true
            sub_container.Visible = false
            sub_container.Parent = content
            local sub_list = Instance.new("UIListLayout")
            sub_list.Padding = UDim.new(0, 6)
            sub_list.SortOrder = Enum.SortOrder.LayoutOrder
            sub_list.Parent = sub_container
            local current_tween = nil
            local function toggle_anim()
                if current_tween then current_tween:Cancel() end
                create_tween(fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                library.flags[flag] = toggled
                if toggled then
                    sub_container.Visible = true
                    sub_container.ClipsDescendants = true
                    local h = sub_list.AbsoluteContentSize.Y
                    if h > 0 then h = h + 6 end
                    current_tween = tween_service:Create(sub_container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, h)})
                    current_tween:Play()
                    current_tween.Completed:Connect(function(state)
                        if state == Enum.PlaybackState.Completed and toggled then sub_container.ClipsDescendants = false end
                    end)
                else
                    sub_container.ClipsDescendants = true
                    current_tween = tween_service:Create(sub_container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                    current_tween:Play()
                    local expected_toggle = toggled
                    current_tween.Completed:Connect(function(playback_state)
                        if playback_state == Enum.PlaybackState.Completed and expected_toggle == toggled and not toggled then sub_container.Visible = false end
                    end)
                end
            end
            toggle_obj.update_anim = toggle_anim
            local sub_c = sub_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if toggled then
                    local h = sub_list.AbsoluteContentSize.Y
                    if h > 0 then h = h + 6 end
                    sub_container.Size = UDim2.new(1, 0, 0, h)
                end
            end)
            table.insert(library.connections, sub_c)
            local last_click = 0
            local btn_c = btn.MouseButton1Click:Connect(function()
                if tick() - last_click < 0.2 then return end
                last_click = tick()
                toggled = not toggled
                library.unsaved = true
                toggle_anim()
                callback(toggled)
            end)
            table.insert(library.connections, btn_c)
            if toggled then toggle_anim() end
            apply_tooltip(btn, tooltip_text)
            task.spawn(callback, toggled)
            return toggle_obj
        end
        function section:text_box(tb_text, flag, placeholder, tooltip_text, callback)
            local val = library.flags[flag] or ""
            library.defaults[flag] = ""
            library.flags[flag] = val
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundTransparency = 1
            frame.Parent = content
            local label = Instance.new("TextLabel")
            label.Text = tb_text
            label.Font = config.font_main
            label.TextSize = 13
            label.TextColor3 = theme.text
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.RichText = true
            label.Parent = frame
            local box_cont = Instance.new("Frame")
            box_cont.Size = UDim2.new(1, 0, 0, 28)
            box_cont.Position = UDim2.new(0, 0, 0, 22)
            box_cont.BackgroundColor3 = theme.container
            box_cont.Parent = frame
            create_corner(box_cont, 4)
            create_stroke(box_cont, theme.stroke, 1, 0.5)
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(1, -10, 1, 0)
            input.Position = UDim2.new(0, 5, 0, 0)
            input.BackgroundTransparency = 1
            input.TextColor3 = theme.text
            input.PlaceholderText = placeholder
            input.PlaceholderColor3 = theme.text_dark
            input.Font = config.font_main
            input.TextSize = 13
            input.TextXAlignment = Enum.TextXAlignment.Left
            input.Text = val
            input.ClearTextOnFocus = false
            input.Parent = box_cont
            local foc_c = input.FocusLost:Connect(function(enter)
                if enter then
                    library.flags[flag] = input.Text
                    library.unsaved = true
                    callback(input.Text)
                end
            end)
            local ch_c = input.Changed:Connect(function(prop)
                if prop == "Text" then
                    library.flags[flag] = input.Text
                end
            end)
            table.insert(library.connections, foc_c)
            table.insert(library.connections, ch_c)
            library.signals[flag] = function(new_val)
                input.Text = new_val
                library.unsaved = true
                callback(new_val)
            end
            apply_tooltip(frame, tooltip_text)
            task.spawn(callback, val)
            return input
        end
        function section:dropdown(d_text, flag, options, default, tooltip_text, callback, custom_parent, is_multi)
            return create_dropdown_element(d_text, flag, options, default, tooltip_text, callback, content, section, is_multi, custom_parent)
        end
        function section:color_picker(cp_text, flag, default, tooltip_text, callback)
            local color = default or Color3.fromRGB(255, 255, 255)
            if library.flags[flag] ~= nil then color = library.flags[flag] else library.flags[flag] = color end
            library.defaults[flag] = default or Color3.fromRGB(255, 255, 255)
            local h, s, v = color:ToHSV()
            local is_open = false
            local container_frame = Instance.new("Frame")
            container_frame.Size = UDim2.new(1, 0, 0, 30)
            container_frame.BackgroundTransparency = 1
            container_frame.Parent = content
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 30)
            frame.BackgroundTransparency = 1
            frame.Parent = container_frame
            frame.ZIndex = 5
            local label = Instance.new("TextLabel")
            label.Text = cp_text
            label.Font = config.font_main
            label.TextSize = 13
            label.TextColor3 = theme.text
            label.Size = UDim2.new(0.6, 0, 1, 0)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.BackgroundTransparency = 1
            label.RichText = true
            label.Parent = frame
            local preview = Instance.new("TextButton")
            preview.Size = UDim2.new(0, 40, 0, 20)
            preview.Position = UDim2.new(1, -5, 0.5, 0)
            preview.AnchorPoint = Vector2.new(1, 0.5)
            preview.BackgroundColor3 = color
            preview.AutoButtonColor = false
            preview.Text = ""
            preview.Parent = frame
            create_corner(preview, 4)
            create_stroke(preview, theme.stroke, 1, 0.5)
            local picker_cont = Instance.new("Frame")
            picker_cont.Size = UDim2.new(1, 0, 0, 0)
            picker_cont.Position = UDim2.new(0, 0, 0, 30)
            picker_cont.BackgroundColor3 = theme.background
            picker_cont.Parent = container_frame
            picker_cont.ClipsDescendants = true
            picker_cont.Visible = false
            picker_cont.ZIndex = 10
            create_corner(picker_cont, 4)
            local sv_map = Instance.new("ImageLabel")
            sv_map.Size = UDim2.new(0, 140, 0, 120)
            sv_map.Position = UDim2.new(0, 10, 0, 10)
            sv_map.Image = "rbxassetid://4155801252"
            sv_map.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            sv_map.Parent = picker_cont
            sv_map.ZIndex = 11
            sv_map.Active = true
            create_corner(sv_map, 4)
            local sv_cursor = Instance.new("Frame")
            sv_cursor.Size = UDim2.new(0, 8, 0, 8)
            sv_cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            sv_cursor.BackgroundColor3 = Color3.new(1, 1, 1)
            sv_cursor.Parent = sv_map
            sv_cursor.Position = UDim2.new(s, 0, 1 - v, 0)
            sv_cursor.ZIndex = 12
            create_corner(sv_cursor, 4)
            local hue_bar = Instance.new("ImageLabel")
            hue_bar.Size = UDim2.new(0, 20, 0, 120)
            hue_bar.Position = UDim2.new(0, 160, 0, 10)
            hue_bar.Image = "rbxassetid://4155801252"
            hue_bar.Parent = picker_cont
            hue_bar.ZIndex = 11
            hue_bar.Active = true
            create_corner(hue_bar, 4)
            local ui_gradient = Instance.new("UIGradient")
            ui_gradient.Rotation = 90
            ui_gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            ui_gradient.Parent = hue_bar
            local h_cursor = Instance.new("Frame")
            h_cursor.Size = UDim2.new(1, 0, 0, 2)
            h_cursor.BackgroundColor3 = Color3.new(1, 1, 1)
            h_cursor.Parent = hue_bar
            h_cursor.Position = UDim2.new(0, 0, h, 0)
            h_cursor.ZIndex = 12
            local hex_input = Instance.new("TextBox")
            hex_input.Size = UDim2.new(0, 170, 0, 20)
            hex_input.Position = UDim2.new(0, 10, 0, 140)
            hex_input.BackgroundColor3 = theme.container
            hex_input.TextColor3 = theme.text
            hex_input.Font = config.font_main
            hex_input.TextSize = 12
            hex_input.Text = "#" .. color:ToHex()
            hex_input.Parent = picker_cont
            hex_input.ZIndex = 11
            create_corner(hex_input, 4)
            create_stroke(hex_input, theme.stroke, 1)
            local function update_color()
                color = Color3.fromHSV(h, s, v)
                preview.BackgroundColor3 = color
                sv_map.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                hex_input.Text = "#" .. color:ToHex()
                library.flags[flag] = color
                library.unsaved = true
                callback(color)
            end
            local hex_c = hex_input.FocusLost:Connect(function()
                local t = hex_input.Text:gsub("#", "")
                if t:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                    pcall(function()
                        local nc = Color3.fromHex(t)
                        h, s, v = nc:ToHSV()
                        h_cursor.Position = UDim2.new(0, 0, h, 0)
                        sv_cursor.Position = UDim2.new(s, 0, 1 - v, 0)
                        update_color()
                    end)
                else
                    hex_input.Text = "#" .. color:ToHex()
                end
            end)
            table.insert(library.connections, hex_c)
            library.signals[flag] = function(val)
                if typeof(val) == "Color3" then
                    color = val
                    h, s, v = color:ToHSV()
                    h_cursor.Position = UDim2.new(0, 0, h, 0)
                    sv_cursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    update_color()
                end
            end
            local function set_sv(input)
                local r_x = math.clamp((input.Position.X - sv_map.AbsolutePosition.X) / sv_map.AbsoluteSize.X, 0, 1)
                local r_y = math.clamp((input.Position.Y - sv_map.AbsolutePosition.Y) / sv_map.AbsoluteSize.Y, 0, 1)
                s = r_x
                v = 1 - r_y
                sv_cursor.Position = UDim2.new(s, 0, 1 - v, 0)
                update_color()
            end
            local function set_h(input)
                local r_y = math.clamp((input.Position.Y - hue_bar.AbsolutePosition.Y) / hue_bar.AbsoluteSize.Y, 0, 1)
                h = r_y
                h_cursor.Position = UDim2.new(0, 0, h, 0)
                update_color()
            end
            local drag_sv, drag_h = false, false
            local sv_changed_conn, h_changed_conn, sv_ended_conn, h_ended_conn
            local sv_b = sv_map.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag_sv = true
                    set_sv(i)
                    sv_changed_conn = user_input_service.InputChanged:Connect(function(inp)
                        if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and drag_sv then set_sv(inp) end
                    end)
                    sv_ended_conn = user_input_service.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            drag_sv = false
                            if sv_changed_conn then sv_changed_conn:Disconnect() sv_changed_conn = nil end
                            if sv_ended_conn then sv_ended_conn:Disconnect() sv_ended_conn = nil end
                        end
                    end)
                    table.insert(library.connections, sv_changed_conn)
                    table.insert(library.connections, sv_ended_conn)
                end
            end)
            local h_b = hue_bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    drag_h = true
                    set_h(i)
                    h_changed_conn = user_input_service.InputChanged:Connect(function(inp)
                        if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and drag_h then set_h(inp) end
                    end)
                    h_ended_conn = user_input_service.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                            drag_h = false
                            if h_changed_conn then h_changed_conn:Disconnect() h_changed_conn = nil end
                            if h_ended_conn then h_ended_conn:Disconnect() h_ended_conn = nil end
                        end
                    end)
                    table.insert(library.connections, h_changed_conn)
                    table.insert(library.connections, h_ended_conn)
                end
            end)
            table.insert(library.connections, sv_b)
            table.insert(library.connections, h_b)
            local prev_c = preview.MouseButton1Click:Connect(function()
                is_open = not is_open
                section.container.ZIndex = is_open and 10 or 1
                container_frame.ZIndex = is_open and 10 or 5
                if is_open then
                    toggle_clips_descendants(container_frame, false)
                    picker_cont.Visible = true
                    create_tween(container_frame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                    create_tween(picker_cont, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                else
                    create_tween(container_frame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                    local t = create_tween(picker_cont, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    t.Completed:Connect(function()
                        if not is_open then 
                            picker_cont.Visible = false 
                            toggle_clips_descendants(container_frame, true)
                        end
                    end)
                end
            end)
            table.insert(library.connections, prev_c)
            apply_tooltip(container_frame, tooltip_text)
            task.spawn(callback, color)
        end
        return section
    end
    local function populate_settings()
        local set_page = Instance.new("ScrollingFrame")
        set_page.Size = UDim2.new(1, -200, 1, -20)
        set_page.Position = UDim2.new(0, 190, 0, 10)
        set_page.BackgroundTransparency = 1
        set_page.ScrollBarThickness = 2
        set_page.ScrollBarImageColor3 = theme.accent
        set_page.Parent = settings_window
        register_theme(set_page, "ScrollBar")
        local list_layout = Instance.new("UIListLayout")
        list_layout.SortOrder = Enum.SortOrder.LayoutOrder
        list_layout.Padding = UDim.new(0, 10)
        list_layout.Parent = set_page
        local sz_c = list_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            set_page.CanvasSize = UDim2.new(0, 0, 0, list_layout.AbsoluteContentSize.Y + 20)
        end)
        table.insert(library.connections, sz_c)
        local menu_sec = window_obj:create_raw_section("Menu Settings", set_page)
        menu_sec:button("Unload UI", "Destroys the Hub", function()
            library:unload()
        end)
        local keybind_btn
        keybind_btn = menu_sec:button("Menu Keybind: " .. tostring(config.keybind.Name), "Change the open/close key", function()
            keybind_btn.Text = "Press any key..."
            local conn
            conn = user_input_service.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                        config.keybind = Enum.KeyCode.LeftControl
                    elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                        config.keybind = input.KeyCode
                    end
                    keybind_btn.Text = "Menu Keybind: " .. tostring(config.keybind.Name)
                    setup_menu_bind()
                    library:notify("Settings", "Menu keybind set to " .. tostring(config.keybind.Name), 2)
                    conn:Disconnect()
                end
            end)
            table.insert(library.connections, conn)
        end)
        menu_sec:toggle("Show Keybind List", "KeybindListToggle", true, "Show the active keybinds widget", function(state)
            library.show_keybinds = state
            if library.keybind_list then library.keybind_list.frame.Visible = state and (#library.keybind_list.container:GetChildren() > 1) end
        end)
        menu_sec:color_picker("Accent Color", "MenuAccentColor", theme.accent, "Change the theme color", function(col)
            library:update_theme(col)
        end)
        local config_sec = window_obj:create_raw_section("Configuration", set_page)
        local config_content = config_sec.container:FindFirstChild("Content")
        local config_name_input = ""
        local selected_config_name = ""
        local config_list = library:get_configs()
        local c_name_frame = Instance.new("Frame")
        c_name_frame.Size = UDim2.new(1, 0, 0, 50)
        c_name_frame.BackgroundTransparency = 1
        c_name_frame.LayoutOrder = 1
        c_name_frame.Parent = config_content
        local c_name_label = Instance.new("TextLabel")
        c_name_label.Text = "Config Name"
        c_name_label.Font = config.font_main
        c_name_label.TextSize = 13
        c_name_label.TextColor3 = theme.text
        c_name_label.Size = UDim2.new(1, 0, 0, 20)
        c_name_label.Position = UDim2.new(0, 5, 0, 0)
        c_name_label.TextXAlignment = Enum.TextXAlignment.Left
        c_name_label.BackgroundTransparency = 1
        c_name_label.RichText = true
        c_name_label.Parent = c_name_frame
        local c_name_box_cont = Instance.new("Frame")
        c_name_box_cont.Size = UDim2.new(1, 0, 0, 28)
        c_name_box_cont.Position = UDim2.new(0, 0, 0, 22)
        c_name_box_cont.BackgroundColor3 = theme.container
        c_name_box_cont.Parent = c_name_frame
        create_corner(c_name_box_cont, 4)
        create_stroke(c_name_box_cont, theme.stroke, 1, 0.5)
        local c_name_input = Instance.new("TextBox")
        c_name_input.Size = UDim2.new(1, -10, 1, 0)
        c_name_input.Position = UDim2.new(0, 5, 0, 0)
        c_name_input.BackgroundTransparency = 1
        c_name_input.TextColor3 = theme.text
        c_name_input.PlaceholderText = "Type config name..."
        c_name_input.PlaceholderColor3 = theme.text_dark
        c_name_input.Font = config.font_main
        c_name_input.TextSize = 13
        c_name_input.TextXAlignment = Enum.TextXAlignment.Left
        c_name_input.Text = ""
        c_name_input.ClearTextOnFocus = false
        c_name_input.Parent = c_name_box_cont
        local txt_c = c_name_input:GetPropertyChangedSignal("Text"):Connect(function()
            config_name_input = c_name_input.Text
        end)
        table.insert(library.connections, txt_c)
        local config_dropdown_frame = Instance.new("Frame")
        config_dropdown_frame.Size = UDim2.new(1, 0, 0, 46)
        config_dropdown_frame.BackgroundTransparency = 1
        config_dropdown_frame.LayoutOrder = 2
        config_dropdown_frame.Parent = config_content
        local cd_label = Instance.new("TextLabel")
        cd_label.Text = "Select Config"
        cd_label.Font = config.font_main
        cd_label.TextSize = 13
        cd_label.TextColor3 = theme.text
        cd_label.Size = UDim2.new(1, 0, 0, 16)
        cd_label.Position = UDim2.new(0, 5, 0, 0)
        cd_label.TextXAlignment = Enum.TextXAlignment.Left
        cd_label.BackgroundTransparency = 1
        cd_label.RichText = true
        cd_label.Parent = config_dropdown_frame
        local cd_interactive = Instance.new("TextButton")
        cd_interactive.Size = UDim2.new(1, 0, 0, 26)
        cd_interactive.Position = UDim2.new(0, 0, 0, 20)
        cd_interactive.BackgroundColor3 = theme.container
        cd_interactive.Text = ""
        cd_interactive.AutoButtonColor = false
        cd_interactive.Parent = config_dropdown_frame
        cd_interactive.ZIndex = 5
        create_corner(cd_interactive, 4)
        create_stroke(cd_interactive, theme.stroke, 1, 0.5)
        local cd_selected_text = Instance.new("TextLabel")
        cd_selected_text.Font = config.font_main
        cd_selected_text.TextSize = 13
        cd_selected_text.TextColor3 = theme.text
        cd_selected_text.Size = UDim2.new(1, -25, 1, 0)
        cd_selected_text.Position = UDim2.new(0, 8, 0, 0)
        cd_selected_text.TextXAlignment = Enum.TextXAlignment.Left
        cd_selected_text.BackgroundTransparency = 1
        cd_selected_text.ZIndex = 6
        cd_selected_text.ClipsDescendants = true
        cd_selected_text.RichText = true
        cd_selected_text.Parent = cd_interactive
        local cd_arrow = Instance.new("ImageLabel")
        cd_arrow.Image = "rbxassetid://10709790948"
        cd_arrow.Size = UDim2.new(0, 18, 0, 18)
        cd_arrow.Position = UDim2.new(1, -20, 0.5, 0)
        cd_arrow.AnchorPoint = Vector2.new(0, 0.5)
        cd_arrow.BackgroundTransparency = 1
        cd_arrow.ImageColor3 = theme.text_dark
        cd_arrow.Parent = cd_interactive
        cd_arrow.ZIndex = 6
        local cd_list_frame = Instance.new("ScrollingFrame")
        cd_list_frame.Size = UDim2.new(1, 0, 0, 0)
        cd_list_frame.Position = UDim2.new(0, 0, 1, 5)
        cd_list_frame.BackgroundColor3 = theme.container
        cd_list_frame.BorderSizePixel = 0
        cd_list_frame.Parent = cd_interactive
        cd_list_frame.ZIndex = 100
        cd_list_frame.Visible = false
        cd_list_frame.Active = true
        cd_list_frame.ScrollBarThickness = 2
        cd_list_frame.ScrollBarImageColor3 = theme.accent
        create_corner(cd_list_frame, 4)
        create_stroke(cd_list_frame, theme.stroke, 1, 0.5)
        local cd_i_list = Instance.new("UIListLayout")
        cd_i_list.SortOrder = Enum.SortOrder.LayoutOrder
        cd_i_list.Parent = cd_list_frame
        local cds_c = cd_i_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            cd_list_frame.CanvasSize = UDim2.new(0, 0, 0, cd_i_list.AbsoluteContentSize.Y)
        end)
        table.insert(library.connections, cds_c)
        local cd_is_dropped = false
        local cd_option_btns = {}
        selected_config_name = #config_list > 0 and config_list[1] or ""
        cd_selected_text.Text = selected_config_name ~= "" and selected_config_name or "No configs"
        local function cd_close_dropdown()
            cd_is_dropped = false
            config_sec.container.ZIndex = 1
            config_dropdown_frame.ZIndex = 5
            create_tween(config_dropdown_frame, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
            local t = create_tween(cd_list_frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            create_tween(cd_arrow, {Rotation = 0}, 0.2)
            t.Completed:Connect(function()
                if not cd_is_dropped then 
                    cd_list_frame.Visible = false 
                    toggle_clips_descendants(config_dropdown_frame, true)
                end
            end)
        end
        local function cd_build_options(opts)
            for _, btn in pairs(cd_option_btns) do btn:Destroy() end
            table.clear(cd_option_btns)
            for _, opt in ipairs(opts) do
                local opt_btn = Instance.new("TextButton")
                opt_btn.Size = UDim2.new(1, 0, 0, 24)
                opt_btn.BackgroundColor3 = theme.container
                opt_btn.BackgroundTransparency = 1
                opt_btn.Text = opt
                opt_btn.Font = config.font_main
                opt_btn.TextSize = 12
                opt_btn.RichText = true
                opt_btn.Parent = cd_list_frame
                opt_btn.ZIndex = 101
                opt_btn.TextColor3 = (selected_config_name == opt) and theme.accent or theme.text_dark
                cd_option_btns[opt] = opt_btn
                local ent_c = opt_btn.MouseEnter:Connect(function()
                    if selected_config_name ~= opt then
                        create_tween(opt_btn, {BackgroundTransparency = 0.8, TextColor3 = theme.accent})
                    end
                end)
                local lev_c = opt_btn.MouseLeave:Connect(function()
                    if selected_config_name ~= opt then
                        create_tween(opt_btn, {BackgroundTransparency = 1, TextColor3 = theme.text_dark})
                    end
                end)
                local clk_c = opt_btn.MouseButton1Click:Connect(function()
                    selected_config_name = opt
                    cd_selected_text.Text = opt
                    for o, b in pairs(cd_option_btns) do
                        b.TextColor3 = (o == opt) and theme.accent or theme.text_dark
                    end
                    cd_close_dropdown()
                end)
                table.insert(library.connections, ent_c)
                table.insert(library.connections, lev_c)
                table.insert(library.connections, clk_c)
            end
        end
        cd_build_options(config_list)
        local cd_int_c = cd_interactive.MouseButton1Click:Connect(function()
            cd_is_dropped = not cd_is_dropped
            config_sec.container.ZIndex = cd_is_dropped and 10 or 1
            config_dropdown_frame.ZIndex = cd_is_dropped and 10 or 5
            if cd_is_dropped then
                toggle_clips_descendants(config_dropdown_frame, false)
                cd_list_frame.Visible = true
                local current_list = library:get_configs()
                cd_build_options(current_list)
                local list_h = math.min(#current_list * 24, 200)
                if list_h < 24 then list_h = 24 end
                local total_h = 46 + list_h + 5
                create_tween(config_dropdown_frame, {Size = UDim2.new(1, 0, 0, total_h)}, 0.2)
                create_tween(cd_list_frame, {Size = UDim2.new(1, 0, 0, list_h)}, 0.2)
                create_tween(cd_arrow, {Rotation = 180}, 0.2)
            else
                cd_close_dropdown()
            end
        end)
        table.insert(library.connections, cd_int_c)
        local function refresh_config_dropdown()
            local new_list = library:get_configs()
            config_list = new_list
            if not table.find(new_list, selected_config_name) then
                selected_config_name = #new_list > 0 and new_list[1] or ""
            end
            cd_selected_text.Text = selected_config_name ~= "" and selected_config_name or "No configs"
            cd_build_options(new_list)
        end
        local create_btn = Instance.new("TextButton")
        create_btn.Size = UDim2.new(1, 0, 0, 32)
        create_btn.BackgroundColor3 = theme.container
        create_btn.Text = "Create New Config"
        create_btn.Font = config.font_main
        create_btn.TextSize = 13
        create_btn.TextColor3 = theme.text
        create_btn.AutoButtonColor = false
        create_btn.LayoutOrder = 3
        create_btn.RichText = true
        create_btn.Parent = config_content
        create_corner(create_btn, 4)
        local cs1 = create_stroke(create_btn, theme.stroke, 1, 0.5)
        local cr_e = create_btn.MouseEnter:Connect(function() create_tween(create_btn, {BackgroundColor3 = theme.stroke}) create_tween(cs1, {Color = theme.accent}) end)
        local cr_l = create_btn.MouseLeave:Connect(function() create_tween(create_btn, {BackgroundColor3 = theme.container}) create_tween(cs1, {Color = theme.stroke}) end)
        local cr_c = create_btn.MouseButton1Click:Connect(function()
            local name = config_name_input
            if not name or name == "" or string.match(name, "^%s*$") then
                library:notify("Error", "Please type a config name first", 3)
                return
            end
            name = string.gsub(name, "^%s+", "")
            name = string.gsub(name, "%s+$", "")
            if name == "" then
                library:notify("Error", "Please type a config name first", 3)
                return
            end
            if library:config_exists(name) then
                library:notify("Error", "Config '" .. name .. "' already exists", 3)
                return
            end
            if library:save_config(name) then
                selected_config_name = name
                c_name_input.Text = ""
                config_name_input = ""
                refresh_config_dropdown()
                library:notify("Config", "Created: " .. name, 3)
            else
                library:notify("Error", "Failed to create config", 3)
            end
        end)
        table.insert(library.connections, cr_e)
        table.insert(library.connections, cr_l)
        table.insert(library.connections, cr_c)
        local load_btn = Instance.new("TextButton")
        load_btn.Size = UDim2.new(1, 0, 0, 32)
        load_btn.BackgroundColor3 = theme.container
        load_btn.Text = "Load Config"
        load_btn.Font = config.font_main
        load_btn.TextSize = 13
        load_btn.TextColor3 = theme.text
        load_btn.AutoButtonColor = false
        load_btn.LayoutOrder = 4
        load_btn.RichText = true
        load_btn.Parent = config_content
        create_corner(load_btn, 4)
        local cs2 = create_stroke(load_btn, theme.stroke, 1, 0.5)
        local ld_e = load_btn.MouseEnter:Connect(function() create_tween(load_btn, {BackgroundColor3 = theme.stroke}) create_tween(cs2, {Color = theme.accent}) end)
        local ld_l = load_btn.MouseLeave:Connect(function() create_tween(load_btn, {BackgroundColor3 = theme.container}) create_tween(cs2, {Color = theme.stroke}) end)
        local ld_c = load_btn.MouseButton1Click:Connect(function()
            local name = selected_config_name
            if not name or name == "" then
                library:notify("Error", "No config selected", 3)
                return
            end
            if not library:config_exists(name) then
                library:notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if library:load_config(name) then
                library:notify("Config", "Loaded: " .. name, 3)
            else
                library:notify("Error", "Failed to load config", 3)
            end
        end)
        table.insert(library.connections, ld_e)
        table.insert(library.connections, ld_l)
        table.insert(library.connections, ld_c)
        local rewrite_btn = Instance.new("TextButton")
        rewrite_btn.Size = UDim2.new(1, 0, 0, 32)
        rewrite_btn.BackgroundColor3 = theme.container
        rewrite_btn.Text = "Rewrite Config"
        rewrite_btn.Font = config.font_main
        rewrite_btn.TextSize = 13
        rewrite_btn.TextColor3 = theme.text
        rewrite_btn.AutoButtonColor = false
        rewrite_btn.LayoutOrder = 5
        rewrite_btn.RichText = true
        rewrite_btn.Parent = config_content
        create_corner(rewrite_btn, 4)
        local cs3 = create_stroke(rewrite_btn, theme.stroke, 1, 0.5)
        local rw_e = rewrite_btn.MouseEnter:Connect(function() create_tween(rewrite_btn, {BackgroundColor3 = theme.stroke}) create_tween(cs3, {Color = theme.accent}) end)
        local rw_l = rewrite_btn.MouseLeave:Connect(function() create_tween(rewrite_btn, {BackgroundColor3 = theme.container}) create_tween(cs3, {Color = theme.stroke}) end)
        local rw_c = rewrite_btn.MouseButton1Click:Connect(function()
            local name = selected_config_name
            if not name or name == "" then
                library:notify("Error", "No config selected", 3)
                return
            end
            if not library:config_exists(name) then
                library:notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if library:save_config(name) then
                library:notify("Config", "Rewritten: " .. name, 3)
            else
                library:notify("Error", "Failed to rewrite config", 3)
            end
        end)
        table.insert(library.connections, rw_e)
        table.insert(library.connections, rw_l)
        table.insert(library.connections, rw_c)
        local delete_btn = Instance.new("TextButton")
        delete_btn.Size = UDim2.new(1, 0, 0, 32)
        delete_btn.BackgroundColor3 = theme.container
        delete_btn.Text = "Delete Config"
        delete_btn.Font = config.font_main
        delete_btn.TextSize = 13
        delete_btn.TextColor3 = theme.text
        delete_btn.AutoButtonColor = false
        delete_btn.LayoutOrder = 6
        delete_btn.RichText = true
        delete_btn.Parent = config_content
        create_corner(delete_btn, 4)
        local cs4 = create_stroke(delete_btn, theme.stroke, 1, 0.5)
        local del_e = delete_btn.MouseEnter:Connect(function() create_tween(delete_btn, {BackgroundColor3 = theme.stroke}) create_tween(cs4, {Color = theme.accent}) end)
        local del_l = delete_btn.MouseLeave:Connect(function() create_tween(delete_btn, {BackgroundColor3 = theme.container}) create_tween(cs4, {Color = theme.stroke}) end)
        local del_c = delete_btn.MouseButton1Click:Connect(function()
            local name = selected_config_name
            if not name or name == "" then
                library:notify("Error", "No config selected", 3)
                return
            end
            if not library:config_exists(name) then
                library:notify("Error", "Config '" .. name .. "' does not exist", 3)
                return
            end
            if library:delete_config(name) then
                refresh_config_dropdown()
                library:notify("Config", "Deleted: " .. name, 3)
            else
                library:notify("Error", "Failed to delete config", 3)
            end
        end)
        table.insert(library.connections, del_e)
        table.insert(library.connections, del_l)
        table.insert(library.connections, del_c)
        local refresh_btn = Instance.new("TextButton")
        refresh_btn.Size = UDim2.new(1, 0, 0, 32)
        refresh_btn.BackgroundColor3 = theme.container
        refresh_btn.Text = "Refresh Config List"
        refresh_btn.Font = config.font_main
        refresh_btn.TextSize = 13
        refresh_btn.TextColor3 = theme.text
        refresh_btn.AutoButtonColor = false
        refresh_btn.LayoutOrder = 7
        refresh_btn.RichText = true
        refresh_btn.Parent = config_content
        create_corner(refresh_btn, 4)
        local cs5 = create_stroke(refresh_btn, theme.stroke, 1, 0.5)
        local ref_e = refresh_btn.MouseEnter:Connect(function() create_tween(refresh_btn, {BackgroundColor3 = theme.stroke}) create_tween(cs5, {Color = theme.accent}) end)
        local ref_l = refresh_btn.MouseLeave:Connect(function() create_tween(refresh_btn, {BackgroundColor3 = theme.container}) create_tween(cs5, {Color = theme.stroke}) end)
        local ref_c = refresh_btn.MouseButton1Click:Connect(function()
            refresh_config_dropdown()
            library:notify("Config", "List Refreshed", 2)
        end)
        table.insert(library.connections, ref_e)
        table.insert(library.connections, ref_l)
        table.insert(library.connections, ref_c)
        local reset_btn = Instance.new("TextButton")
        reset_btn.Size = UDim2.new(1, 0, 0, 32)
        reset_btn.BackgroundColor3 = theme.container
        reset_btn.Text = "Reset to Defaults"
        reset_btn.Font = config.font_main
        reset_btn.TextSize = 13
        reset_btn.TextColor3 = theme.text
        reset_btn.AutoButtonColor = false
        reset_btn.LayoutOrder = 8
        reset_btn.RichText = true
        reset_btn.Parent = config_content
        create_corner(reset_btn, 4)
        local cs6 = create_stroke(reset_btn, theme.stroke, 1, 0.5)
        local res_e = reset_btn.MouseEnter:Connect(function() create_tween(reset_btn, {BackgroundColor3 = theme.stroke}) create_tween(cs6, {Color = theme.accent}) end)
        local res_l = reset_btn.MouseLeave:Connect(function() create_tween(reset_btn, {BackgroundColor3 = theme.container}) create_tween(cs6, {Color = theme.stroke}) end)
        local res_c = reset_btn.MouseButton1Click:Connect(function()
            for flag, val in pairs(library.defaults) do
                if ignored_flags[flag] then continue end
                library.flags[flag] = val
                if library.signals[flag] then
                    task.spawn(library.signals[flag], val)
                end
            end
            library:notify("Settings", "Reset to defaults", 3)
        end)
        table.insert(library.connections, res_e)
        table.insert(library.connections, res_l)
        table.insert(library.connections, res_c)
    end
    populate_settings()
    function window_obj:tab(name, icon_id)
        local tab = {}
        local page_group = Instance.new("CanvasGroup")
        page_group.Size = UDim2.new(1, -20, 1, -20)
        page_group.Position = UDim2.new(0, 10, 0, 10)
        page_group.BackgroundTransparency = 1
        page_group.GroupTransparency = 1
        page_group.Visible = false
        page_group.Parent = main_pages
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.Position = UDim2.new(0, 0, 0, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 0
        page.Parent = page_group
        local tab_btn = Instance.new("TextButton")
        tab_btn.Size = UDim2.new(0, 160, 0, 36)
        tab_btn.BackgroundColor3 = theme.background
        tab_btn.BackgroundTransparency = 1
        tab_btn.Text = ""
        tab_btn.AutoButtonColor = false
        tab_btn.Parent = tab_container
        create_corner(tab_btn, 6)
        local title = Instance.new("TextLabel")
        title.Text = name
        title.Font = config.font_main
        title.TextSize = 14
        title.TextColor3 = theme.text_dark
        title.Size = UDim2.new(1, -20, 1, 0)
        title.Position = UDim2.new(0, icon_id and 35 or 15, 0, 0)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.BackgroundTransparency = 1
        title.RichText = true
        title.Parent = tab_btn
        if icon_id then
            local ico = Instance.new("ImageLabel")
            ico.Size = UDim2.new(0, 20, 0, 20)
            ico.Position = UDim2.new(0, 8, 0.5, 0)
            ico.AnchorPoint = Vector2.new(0, 0.5)
            ico.BackgroundTransparency = 1
            if tonumber(icon_id) then ico.Image = "rbxassetid://" .. icon_id else ico.Image = icon_id end
            ico.ImageColor3 = theme.text_dark
            ico.Parent = tab_btn
            local te_c = tab_btn.MouseEnter:Connect(function() if tab_btn.BackgroundTransparency > 0.5 then create_tween(ico, {ImageColor3 = theme.text}) end end)
            local tl_c = tab_btn.MouseLeave:Connect(function() if tab_btn.BackgroundTransparency > 0.5 then create_tween(ico, {ImageColor3 = theme.text_dark}) end end)
            table.insert(library.connections, te_c)
            table.insert(library.connections, tl_c)
        end
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 16)
        indicator.Position = UDim2.new(0, 0, 0.5, -8)
        indicator.BackgroundColor3 = theme.accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = tab_btn
        create_corner(indicator, 2)
        register_theme(indicator, "BackgroundColor")
        local t_clk = tab_btn.MouseButton1Click:Connect(function()
            for _, p in pairs(main_pages:GetChildren()) do 
                if p:IsA("CanvasGroup") then 
                    create_tween(p, {GroupTransparency = 1}, 0.2)
                    task.delay(0.2, function() p.Visible = false end)
                end 
            end
            for _, t in pairs(tab_container:GetChildren()) do
                if t:IsA("TextButton") then
                    create_tween(t.TextLabel, {TextColor3 = theme.text_dark})
                    create_tween(t, {BackgroundTransparency = 1, BackgroundColor3 = theme.background})
                    if t:FindFirstChild("ImageLabel") then create_tween(t.ImageLabel, {ImageColor3 = theme.text_dark}) end
                    if t:FindFirstChild("Frame") then create_tween(t.Frame, {BackgroundTransparency = 1}) end
                end
            end
            page_group.Visible = true
            create_tween(page_group, {GroupTransparency = 0}, 0.2)
            create_tween(title, {TextColor3 = theme.text})
            create_tween(tab_btn, {BackgroundTransparency = 0.95, BackgroundColor3 = theme.text})
            if tab_btn:FindFirstChild("ImageLabel") then create_tween(tab_btn.ImageLabel, {ImageColor3 = theme.text}) end
            create_tween(indicator, {BackgroundTransparency = 0})
        end)
        table.insert(library.connections, t_clk)
        local tab_count = 0
        for _, c in pairs(tab_container:GetChildren()) do
            if c:IsA("TextButton") then tab_count = tab_count + 1 end
        end
        if tab_count <= 1 then
            page_group.Visible = true
            page_group.GroupTransparency = 0
            title.TextColor3 = theme.text
            tab_btn.BackgroundTransparency = 0.95
            tab_btn.BackgroundColor3 = theme.text
            if tab_btn:FindFirstChild("ImageLabel") then tab_btn.ImageLabel.ImageColor3 = theme.text end
            indicator.BackgroundTransparency = 0
        end
        local left_col = Instance.new("Frame")
        left_col.Size = UDim2.new(0.5, -5, 1, 0)
        left_col.Position = UDim2.new(0, 0, 0, 0)
        left_col.BackgroundTransparency = 1
        left_col.Parent = page
        local left_list = Instance.new("UIListLayout")
        left_list.SortOrder = Enum.SortOrder.LayoutOrder
        left_list.Padding = UDim.new(0, 10)
        left_list.Parent = left_col
        local right_col = Instance.new("Frame")
        right_col.Size = UDim2.new(0.5, -5, 1, 0)
        right_col.Position = UDim2.new(0.5, 5, 0, 0)
        right_col.BackgroundTransparency = 1
        right_col.Parent = page
        local right_list = Instance.new("UIListLayout")
        right_list.SortOrder = Enum.SortOrder.LayoutOrder
        right_list.Padding = UDim.new(0, 10)
        right_list.Parent = right_col
        function tab:section(s_text, side)
            local section = {}
            local parent_col = (side == "Right" and right_col or left_col)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.BackgroundColor3 = theme.section
            container.Parent = parent_col
            container.ZIndex = 1
            create_corner(container, 6)
            create_stroke(container, theme.stroke, 1, 0.5)
            section.container = container
            local sec_data = {instance = container, items = {}}
            table.insert(library.elements, sec_data)
            local s_title = Instance.new("TextLabel")
            s_title.Text = s_text
            s_title.Font = config.font_bold
            s_title.TextSize = 12
            s_title.TextColor3 = theme.text_dark
            s_title.Size = UDim2.new(1, -20, 0, 25)
            s_title.Position = UDim2.new(0, 10, 0, 0)
            s_title.BackgroundTransparency = 1
            s_title.TextXAlignment = Enum.TextXAlignment.Left
            s_title.RichText = true
            s_title.Parent = container
            local content = Instance.new("Frame")
            content.Size = UDim2.new(1, -10, 0, 0)
            content.Position = UDim2.new(0, 5, 0, 25)
            content.BackgroundTransparency = 1
            content.Parent = container
            local list = Instance.new("UIListLayout")
            list.Padding = UDim.new(0, 6)
            list.SortOrder = Enum.SortOrder.LayoutOrder
            list.Parent = content
            local function update_size()
                container.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 35)
                page.CanvasSize = UDim2.new(0, 0, 0, math.max(left_list.AbsoluteContentSize.Y, right_list.AbsoluteContentSize.Y) + 20)
            end
            local list_sz_c = list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_size)
            table.insert(library.connections, list_sz_c)
            function section:toggle(t_text, flag, default, tooltip_text, callback)
                local toggled = default or false
                if library.flags[flag] ~= nil then toggled = library.flags[flag] else library.flags[flag] = toggled end
                library.defaults[flag] = default or false
                local toggle_obj = {}
                library.signals[flag] = function(val)
                    if toggled ~= val then
                        toggled = val
                        if toggle_obj.update_anim then toggle_obj.update_anim() end
                        library.unsaved = true
                        callback(val)
                    end
                end
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 32)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Parent = content
                table.insert(sec_data.items, {name = t_text, instance = btn})
                local label = Instance.new("TextLabel")
                label.Text = t_text
                label.Font = config.font_main
                label.TextSize = 13
                label.TextColor3 = theme.text
                label.Size = UDim2.new(0.65, 0, 1, 0)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.RichText = true
                label.Parent = btn
                local box = Instance.new("Frame")
                box.Size = UDim2.new(0, 18, 0, 18)
                box.Position = UDim2.new(1, -5, 0.5, 0)
                box.AnchorPoint = Vector2.new(1, 0.5)
                box.BackgroundColor3 = theme.background
                box.Parent = btn
                create_corner(box, 4)
                create_stroke(box, theme.stroke, 1, 0.5)
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(1, -4, 1, -4)
                fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                fill.AnchorPoint = Vector2.new(0.5, 0.5)
                fill.BackgroundColor3 = theme.accent
                fill.BackgroundTransparency = toggled and 0 or 1
                fill.Parent = box
                create_corner(fill, 3)
                register_theme(fill, "BackgroundColor")
                local sub_container = Instance.new("Frame")
                sub_container.Name = "Sub_" .. t_text
                sub_container.Size = UDim2.new(1, 0, 0, 0)
                sub_container.BackgroundTransparency = 1
                sub_container.ClipsDescendants = true
                sub_container.Visible = false
                sub_container.Parent = content
                local sub_list = Instance.new("UIListLayout")
                sub_list.Padding = UDim.new(0, 6)
                sub_list.SortOrder = Enum.SortOrder.LayoutOrder
                sub_list.Parent = sub_container
                local current_tween = nil
                local function toggle_anim()
                    if current_tween then current_tween:Cancel() end
                    create_tween(fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                    library.flags[flag] = toggled
                    if toggle_obj.keybind_value then
                        library:update_keybind_list(t_text, toggle_obj.keybind_value.Name, toggled, toggle_obj.keybind_mode)
                    end
                    if toggled then
                        sub_container.Visible = true
                        sub_container.ClipsDescendants = true
                        local h = sub_list.AbsoluteContentSize.Y
                        if h > 0 then h = h + 6 end
                        current_tween = tween_service:Create(sub_container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, h)})
                        current_tween:Play()
                        current_tween.Completed:Connect(function(state)
                            if state == Enum.PlaybackState.Completed and toggled then sub_container.ClipsDescendants = false end
                        end)
                    else
                        sub_container.ClipsDescendants = true
                        current_tween = tween_service:Create(sub_container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                        current_tween:Play()
                        local expected_toggle = toggled
                        current_tween.Completed:Connect(function(playback_state)
                            if playback_state == Enum.PlaybackState.Completed and expected_toggle == toggled and not toggled then sub_container.Visible = false end
                        end)
                    end
                end
                toggle_obj.update_anim = toggle_anim
                local s_sz_c = sub_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if toggled then
                        local h = sub_list.AbsoluteContentSize.Y
                        if h > 0 then h = h + 6 end
                        sub_container.Size = UDim2.new(1, 0, 0, h)
                    end
                end)
                table.insert(library.connections, s_sz_c)
                local last_click = 0
                local b_clk = btn.MouseButton1Click:Connect(function()
                    if tick() - last_click < 0.2 then return end
                    last_click = tick()
                    toggled = not toggled
                    library.unsaved = true
                    toggle_anim()
                    callback(toggled)
                end)
                table.insert(library.connections, b_clk)
                if toggled then toggle_anim() end
                apply_tooltip(btn, tooltip_text)
                task.spawn(callback, toggled)
                function toggle_obj:add_button(txt, cb)
                    local s_btn = Instance.new("TextButton")
                    s_btn.Size = UDim2.new(1, -20, 0, 26)
                    s_btn.Position = UDim2.new(0, 20, 0, 0)
                    s_btn.BackgroundColor3 = theme.container
                    s_btn.Text = txt
                    s_btn.Font = config.font_main
                    s_btn.TextSize = 12
                    s_btn.TextColor3 = theme.text
                    s_btn.AutoButtonColor = false
                    s_btn.RichText = true
                    s_btn.Parent = sub_container
                    create_corner(s_btn, 4)
                    local s = create_stroke(s_btn, theme.stroke, 1, 0.5)
                    local be = s_btn.MouseEnter:Connect(function() create_tween(s_btn, {BackgroundColor3 = theme.stroke}) create_tween(s, {Color = theme.accent}) end)
                    local bl = s_btn.MouseLeave:Connect(function() create_tween(s_btn, {BackgroundColor3 = theme.container}) create_tween(s, {Color = theme.stroke}) end)
                    local last_sub_click = 0
                    local bc = s_btn.MouseButton1Click:Connect(function()
                        if tick() - last_sub_click < 0.2 then return end
                        last_sub_click = tick()
                        cb()
                    end)
                    table.insert(library.connections, be)
                    table.insert(library.connections, bl)
                    table.insert(library.connections, bc)
                end
                function toggle_obj:add_slider(txt, sflag, min, max, def, cb, inc)
                    inc = inc or 1
                    local val = library.flags[sflag] or round_to_increment(def or min, inc)
                    library.defaults[sflag] = round_to_increment(def or min, inc)
                    library.flags[sflag] = val
                    local range = max - min
                    local s_frame = Instance.new("Frame")
                    s_frame.Size = UDim2.new(1, -20, 0, 36)
                    s_frame.Position = UDim2.new(0, 20, 0, 0)
                    s_frame.BackgroundTransparency = 1
                    s_frame.Parent = sub_container
                    local s_label = Instance.new("TextLabel")
                    s_label.Text = txt
                    s_label.Font = config.font_main
                    s_label.TextSize = 12
                    s_label.TextColor3 = theme.text_dark
                    s_label.Size = UDim2.new(1, 0, 0, 16)
                    s_label.TextXAlignment = Enum.TextXAlignment.Left
                    s_label.BackgroundTransparency = 1
                    s_label.RichText = true
                    s_label.Parent = s_frame
                    local s_value = Instance.new("TextBox")
                    s_value.Text = format_number(val, inc)
                    s_value.Font = config.font_main
                    s_value.TextSize = 12
                    s_value.TextColor3 = theme.text
                    s_value.Size = UDim2.new(1, 0, 0, 16)
                    s_value.TextXAlignment = Enum.TextXAlignment.Right
                    s_value.BackgroundTransparency = 1
                    s_value.ClearTextOnFocus = true
                    s_value.Parent = s_frame
                    local slide_bg = Instance.new("Frame")
                    slide_bg.Size = UDim2.new(1, 0, 0, 6)
                    slide_bg.Position = UDim2.new(0, 0, 0, 22)
                    slide_bg.BackgroundColor3 = theme.background
                    slide_bg.Parent = s_frame
                    slide_bg.Active = true
                    create_corner(slide_bg, 3)
                    local slide_fill = Instance.new("Frame")
                    local ratio = range > 0 and (val - min) / range or 0
                    slide_fill.Size = UDim2.new(ratio, 0, 1, 0)
                    slide_fill.BackgroundColor3 = theme.accent
                    slide_fill.BorderSizePixel = 0
                    slide_fill.Parent = slide_bg
                    create_corner(slide_fill, 3)
                    register_theme(slide_fill, "BackgroundColor")
                    local dragging = false
                    local input_changed_conn = nil
                    local function set_val(input)
                        local r = math.clamp((input.Position.X - slide_bg.AbsolutePosition.X) / slide_bg.AbsoluteSize.X, 0, 1)
                        local raw = min + (max - min) * r
                        val = round_to_increment(raw, inc)
                        val = math.clamp(val, min, max)
                        local display_ratio = range > 0 and (val - min) / range or 0
                        s_value.Text = format_number(val, inc)
                        create_tween(slide_fill, {Size = UDim2.new(display_ratio, 0, 1, 0)}, 0.05)
                        library.flags[sflag] = val
                        library.unsaved = true
                        cb(val)
                    end
                    local bg_inp = slide_bg.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            dragging = true
                            set_val(i)
                            input_changed_conn = user_input_service.InputChanged:Connect(function(inp)
                                if (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) and dragging then set_val(inp) end
                            end)
                            local input_ended_conn
                            input_ended_conn = user_input_service.InputEnded:Connect(function(inp)
                                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                                    dragging = false
                                    if input_changed_conn then input_changed_conn:Disconnect() input_changed_conn = nil end
                                    if input_ended_conn then input_ended_conn:Disconnect() input_ended_conn = nil end
                                end
                            end)
                            table.insert(library.connections, input_changed_conn)
                            table.insert(library.connections, input_ended_conn)
                        end
                    end)
                    table.insert(library.connections, bg_inp)
                    local sv_foc = s_value.FocusLost:Connect(function(enter)
                        if enter then
                            local num = tonumber(s_value.Text)
                            if num then
                                num = round_to_increment(num, inc)
                                num = math.clamp(num, min, max)
                                val = num
                                local display_ratio = range > 0 and (val - min) / range or 0
                                s_value.Text = format_number(val, inc)
                                create_tween(slide_fill, {Size = UDim2.new(display_ratio, 0, 1, 0)}, 0.05)
                                library.flags[sflag] = val
                                library.unsaved = true
                                cb(val)
                            else
                                s_value.Text = format_number(val, inc)
                            end
                        else
                            s_value.Text = format_number(val, inc)
                        end
                    end)
                    table.insert(library.connections, sv_foc)
                    library.signals[sflag] = function(loaded_val)
                        val = round_to_increment(loaded_val, inc)
                        val = math.clamp(val, min, max)
                        local display_ratio = range > 0 and (val - min) / range or 0
                        s_value.Text = format_number(val, inc)
                        create_tween(slide_fill, {Size = UDim2.new(display_ratio, 0, 1, 0)}, 0.05)
                        library.unsaved = true
                        cb(val)
                    end
                    task.spawn(cb, val)
                end
                function toggle_obj:add_dropdown(txt, dflag, opts, def, cb, is_multi)
                    create_dropdown_element(txt, dflag, opts, def, nil, cb, content, section, is_multi, sub_container)
                end
                function toggle_obj:keybind(default_key, mode)
                    toggle_obj.keybind_value = default_key or Enum.KeyCode.Unknown
                    toggle_obj.keybind_mode = mode or "Toggle"
                    local key_btn = Instance.new("TextButton")
                    key_btn.Size = UDim2.new(0, 60, 0, 18)
                    key_btn.Position = UDim2.new(1, -30, 0.5, 0)
                    key_btn.AnchorPoint = Vector2.new(1, 0.5)
                    key_btn.BackgroundTransparency = 1
                    key_btn.Text = "[" .. (toggle_obj.keybind_value.Name) .. "]"
                    key_btn.TextColor3 = theme.text_dark
                    key_btn.Font = config.font_main
                    key_btn.TextSize = 11
                    key_btn.TextXAlignment = Enum.TextXAlignment.Right
                    key_btn.RichText = true
                    key_btn.Parent = btn
                    local binding = false
                    local kb_c = key_btn.MouseButton1Click:Connect(function()
                        if binding then return end
                        binding = true
                        key_btn.Text = "[...]"
                        key_btn.TextColor3 = theme.accent
                        local conn
                        conn = user_input_service.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then toggle_obj.keybind_value = Enum.KeyCode.Unknown
                                elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then toggle_obj.keybind_value = input.KeyCode end
                                key_btn.Text = "[" .. (toggle_obj.keybind_value.Name) .. "]"
                                key_btn.TextColor3 = theme.text_dark
                                binding = false
                                library.unsaved = true
                                conn:Disconnect()
                                if toggled then library:update_keybind_list(t_text, toggle_obj.keybind_value.Name, toggled, toggle_obj.keybind_mode) end
                            end
                        end)
                        table.insert(library.connections, conn)
                    end)
                    table.insert(library.connections, kb_c)
                    local mode_gui = Instance.new("Frame")
                    mode_gui.Size = UDim2.new(0, 80, 0, 60)
                    mode_gui.BackgroundColor3 = theme.sidebar
                    mode_gui.Visible = false
                    mode_gui.ZIndex = 100
                    mode_gui.Parent = btn
                    create_corner(mode_gui, 4)
                    create_stroke(mode_gui, theme.stroke, 1)
                    local mode_list = Instance.new("UIListLayout")
                    mode_list.Parent = mode_gui
                    local modes = {"Toggle", "Hold", "Always"}
                    for _, md in ipairs(modes) do
                        local m_btn = Instance.new("TextButton")
                        m_btn.Size = UDim2.new(1, 0, 0, 20)
                        m_btn.BackgroundTransparency = 1
                        m_btn.Text = md
                        m_btn.TextColor3 = theme.text_dark
                        m_btn.Font = config.font_main
                        m_btn.TextSize = 11
                        m_btn.RichText = true
                        m_btn.Parent = mode_gui
                        m_btn.ZIndex = 101
                        local mb_c = m_btn.MouseButton1Click:Connect(function()
                            toggle_obj.keybind_mode = md
                            mode_gui.Visible = false
                            library.unsaved = true
                            if md == "Always" and not toggled then
                                toggled = true
                                toggle_anim()
                                callback(toggled)
                            end
                            if toggled then library:update_keybind_list(t_text, toggle_obj.keybind_value.Name, toggled, md) end
                        end)
                        table.insert(library.connections, mb_c)
                    end
                    local kb2_c = key_btn.MouseButton2Click:Connect(function()
                        mode_gui.Position = UDim2.new(1, -110, 0, 20)
                        mode_gui.Visible = not mode_gui.Visible
                        if mode_gui.Visible then sub_container.ClipsDescendants = false end
                    end)
                    table.insert(library.connections, kb2_c)
                    if toggle_obj.bind_connection then toggle_obj.bind_connection:Disconnect() end
                    if toggle_obj.bind_connection_ended then toggle_obj.bind_connection_ended:Disconnect() end
                    toggle_obj.bind_connection = user_input_service.InputBegan:Connect(function(input, gp)
                        if not gp and input.KeyCode == toggle_obj.keybind_value and toggle_obj.keybind_value ~= Enum.KeyCode.Unknown then
                            if toggle_obj.keybind_mode == "Toggle" then
                                toggled = not toggled
                                toggle_anim()
                                callback(toggled)
                            elseif toggle_obj.keybind_mode == "Hold" then
                                toggled = true
                                toggle_anim()
                                callback(toggled)
                            end
                        end
                    end)
                    toggle_obj.bind_connection_ended = user_input_service.InputEnded:Connect(function(input, gp)
                        if not gp and input.KeyCode == toggle_obj.keybind_value and toggle_obj.keybind_value ~= Enum.KeyCode.Unknown then
                            if toggle_obj.keybind_mode == "Hold" then
                                toggled = false
                                toggle_anim()
                                callback(toggled)
                            end
                        end
                    end)
                    table.insert(library.connections, toggle_obj.bind_connection)
                    table.insert(library.connections, toggle_obj.bind_connection_ended)
                    return toggle_obj
                end
                return toggle_obj
            end
            function section:keybind(k_text, flag, default_key, mode, tooltip_text, callback)
                local key = default_key or Enum.KeyCode.Unknown
                local k_mode = mode or "Toggle"
                if library.flags[flag] ~= nil then
                    local ld = library.flags[flag]
                    if type(ld) == "table" and ld.Key and ld.Mode then
                        key = ld.Key
                        k_mode = ld.Mode
                    end
                else
                    library.flags[flag] = {Key = key, Mode = k_mode}
                end
                library.defaults[flag] = {Key = default_key or Enum.KeyCode.Unknown, Mode = mode or "Toggle"}
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 30)
                frame.BackgroundTransparency = 1
                frame.Parent = content
                local label = Instance.new("TextLabel")
                label.Text = k_text
                label.Font = config.font_main
                label.TextSize = 13
                label.TextColor3 = theme.text
                label.Size = UDim2.new(0.6, 0, 1, 0)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.BackgroundTransparency = 1
                label.RichText = true
                label.Parent = frame
                local key_btn = Instance.new("TextButton")
                key_btn.Size = UDim2.new(0, 80, 0, 20)
                key_btn.Position = UDim2.new(1, -5, 0.5, 0)
                key_btn.AnchorPoint = Vector2.new(1, 0.5)
                key_btn.BackgroundColor3 = theme.container
                key_btn.Text = "[" .. key.Name .. "]"
                key_btn.Font = config.font_main
                key_btn.TextSize = 12
                key_btn.TextColor3 = theme.text_dark
                key_btn.AutoButtonColor = false
                key_btn.RichText = true
                key_btn.Parent = frame
                create_corner(key_btn, 4)
                create_stroke(key_btn, theme.stroke, 1, 0.5)
                local binding = false
                local kb_clk = key_btn.MouseButton1Click:Connect(function()
                    if binding then return end
                    binding = true
                    key_btn.Text = "[...]"
                    key_btn.TextColor3 = theme.accent
                    local conn
                    conn = user_input_service.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                                key = Enum.KeyCode.Unknown
                            elseif input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                                key = input.KeyCode
                            end
                            key_btn.Text = "[" .. key.Name .. "]"
                            key_btn.TextColor3 = theme.text_dark
                            library.flags[flag] = {Key = key, Mode = k_mode}
                            binding = false
                            library.unsaved = true
                            conn:Disconnect()
                            library:update_keybind_list(k_text, key.Name, true, k_mode)
                        end
                    end)
                    table.insert(library.connections, conn)
                end)
                table.insert(library.connections, kb_clk)
                local mode_gui = Instance.new("Frame")
                mode_gui.Size = UDim2.new(0, 80, 0, 60)
                mode_gui.Position = UDim2.new(1, -90, 0, 25)
                mode_gui.BackgroundColor3 = theme.sidebar
                mode_gui.Visible = false
                mode_gui.ZIndex = 100
                mode_gui.Parent = frame
                create_corner(mode_gui, 4)
                create_stroke(mode_gui, theme.stroke, 1)
                local mode_list = Instance.new("UIListLayout")
                mode_list.Parent = mode_gui
                local modes = {"Toggle", "Hold", "Always"}
                for _, md in ipairs(modes) do
                    local m_btn = Instance.new("TextButton")
                    m_btn.Size = UDim2.new(1, 0, 0, 20)
                    m_btn.BackgroundTransparency = 1
                    m_btn.Text = md
                    m_btn.TextColor3 = theme.text_dark
                    m_btn.Font = config.font_main
                    m_btn.TextSize = 11
                    m_btn.RichText = true
                    m_btn.Parent = mode_gui
                    m_btn.ZIndex = 101
                    local mb_clk = m_btn.MouseButton1Click:Connect(function()
                        k_mode = md
                        library.flags[flag] = {Key = key, Mode = k_mode}
                        mode_gui.Visible = false
                        library.unsaved = true
                        library:update_keybind_list(k_text, key.Name, true, k_mode)
                        if k_mode == "Always" then
                            callback(true)
                        end
                    end)
                    table.insert(library.connections, mb_clk)
                end
                local kb2_clk = key_btn.MouseButton2Click:Connect(function()
                    mode_gui.Visible = not mode_gui.Visible
                    if mode_gui.Visible then content.ClipsDescendants = false end
                end)
                table.insert(library.connections, kb2_clk)
                local toggled = false
                local bind_connection = user_input_service.InputBegan:Connect(function(input, gp)
                    if not gp and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        if k_mode == "Toggle" then
                            toggled = not toggled
                            callback(toggled)
                        elseif k_mode == "Hold" then
                            toggled = true
                            callback(toggled)
                        end
                    end
                end)
                local bind_connection_ended = user_input_service.InputEnded:Connect(function(input, gp)
                    if not gp and input.KeyCode == key and key ~= Enum.KeyCode.Unknown then
                        if k_mode == "Hold" then
                            toggled = false
                            callback(toggled)
                        end
                    end
                end)
                table.insert(library.connections, bind_connection)
                table.insert(library.connections, bind_connection_ended)
                library:update_keybind_list(k_text, key.Name, true, k_mode)
                apply_tooltip(frame, tooltip_text)
                local bind_obj = {}
                function bind_obj:set_key(new_key)
                    key = new_key
                    key_btn.Text = "[" .. key.Name .. "]"
                    library.flags[flag] = {Key = key, Mode = k_mode}
                    library.unsaved = true
                    library:update_keybind_list(k_text, key.Name, true, k_mode)
                end
                return bind_obj
            end
            function section:slider(sl_text, flag, min, max, default, increment, tooltip_text, callback)
                create_slider_element(sl_text, flag, min, max, default, increment, tooltip_text, callback, content, sec_data)
            end
            return section
        end
        return tab
    end
    local auto_save_timer = 0
    local auto_save_conn = run_service.Heartbeat:Connect(function(dt)
        if library.auto_save_enabled and library.unsaved and library.open then
            auto_save_timer = auto_save_timer + dt
            if auto_save_timer >= 3 then
                auto_save_timer = 0
                library.unsaved = false
                library:save_config("_autosave")
            end
        end
    end)
    table.insert(library.connections, auto_save_conn)
    main_scale.Scale = get_base_scale()
    main_window.Visible = true
    return window_obj
end

return library
