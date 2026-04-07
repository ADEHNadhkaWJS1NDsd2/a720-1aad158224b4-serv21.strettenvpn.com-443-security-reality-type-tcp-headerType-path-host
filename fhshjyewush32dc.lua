local user_input_service = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")
local run_service = game:GetService("RunService")
local players = game:GetService("Players")
local core_gui = game:GetService("CoreGui")
local http_service = game:GetService("HttpService")
local marketplace_service = game:GetService("MarketplaceService")
local local_player = players.LocalPlayer
local mouse = local_player:GetMouse()

local UI_TWEEN_INFO = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

local library = {
    flags = {},
    signals = {},
    open = true,
    keybind_list = nil,
    show_keybinds = true,
    screen_gui = nil,
    popup_layer = nil
}

local config = {
    name = "Phantom",
    keybind = Enum.KeyCode.RightShift,
    duration = 0.3,
    font_main = Enum.Font.GothamMedium,
    font_bold = Enum.Font.GothamBold,
    config_folder = "phantom_configs"
}

if not isfolder(config.config_folder) then
    makefolder(config.config_folder)
end

local theme = {
    background = Color3.fromHex("#0a0a0a"),
    sidebar = Color3.fromHex("#0f0f0f"),
    container = Color3.fromHex("#121212"),
    section = Color3.fromHex("#161616"),
    accent = Color3.fromHex("#ff1a1a"),
    accent_dark = Color3.fromHex("#660000"),
    text = Color3.fromHex("#ffffff"),
    text_dark = Color3.fromHex("#808080"),
    stroke = Color3.fromHex("#1f1f1f"),
    success = Color3.fromHex("#00ff88"),
    danger = Color3.fromHex("#ff4444")
}

local theme_registry = setmetatable({}, {__mode = "k"})

local function register_theme(instance, prop_type)
    theme_registry[instance] = prop_type
    return instance
end

function library:update_theme(new_color)
    theme.accent = new_color
    for instance, prop_type in pairs(theme_registry) do
        if instance and instance.Parent then
            if prop_type == "text_color" then
                instance.TextColor3 = new_color
            elseif prop_type == "background_color" then
                instance.BackgroundColor3 = new_color
            elseif prop_type == "border_color" then
                instance.Color = new_color
            elseif prop_type == "image_color" then
                instance.ImageColor3 = new_color
            elseif prop_type == "scroll_bar" then
                instance.ScrollBarImageColor3 = new_color
            end
        end
    end
end

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    return obj
end

local function get_parent()
    local success, result = pcall(function() return core_gui end)
    return success and result or local_player:WaitForChild("PlayerGui")
end

local function tween(obj, props, time, style, dir)
    time = time or config.duration
    style = style or Enum.EasingStyle.Quart
    dir = dir or Enum.EasingDirection.Out
    local t = tween_service:Create(obj, TweenInfo.new(time, style, dir), props)
    t:Play()
    return t
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or theme.stroke
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function gradient(parent, color1, color2, rotation)
    local g = Instance.new("UIGradient")
    g.Rotation = rotation or 90
    g.Color = ColorSequence.new({color1, color2})
    g.Parent = parent
    return g
end

local function make_draggable(drag_obj, move_obj)
    local dragging, drag_input, drag_start, start_pos
    drag_obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            drag_start = input.Position
            start_pos = move_obj.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    drag_obj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            drag_input = input
        end
    end)
    run_service.PreSimulation:Connect(function()
        if dragging and drag_input then
            local delta = drag_input.Position - drag_start
            move_obj.Position = UDim2.new(
                start_pos.X.Scale,
                start_pos.X.Offset + delta.X,
                start_pos.Y.Scale,
                start_pos.Y.Offset + delta.Y
            )
        end
    end)
end

local function make_resizable(resize_btn, frame, min_size, scale_obj)
    local dragging, drag_start, start_size
    local connections = {}
    resize_btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            drag_start = input.Position
            start_size = frame.Size
            local input_changed = user_input_service.InputChanged:Connect(function(input_evt)
                if input_evt.UserInputType == Enum.UserInputType.MouseMovement then
                    local scale = scale_obj and scale_obj.Scale or 1
                    local delta = (input_evt.Position - drag_start) / scale
                    local new_x = math.max(min_size.X, start_size.X.Offset + delta.X)
                    local new_y = math.max(min_size.Y, start_size.Y.Offset + delta.Y)
                    frame.Size = UDim2.new(0, new_x, 0, new_y)
                end
            end)
            local input_ended = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    input_changed:Disconnect()
                    input_ended:Disconnect()
                end
            end)
            table.insert(connections, input_changed)
            table.insert(connections, input_ended)
        end
    end)
end

function library:save_config(name)
    local json = http_service:JSONEncode(library.flags)
    writefile(config.config_folder .. "/" .. name .. ".json", json)
end

function library:load_config(name)
    if isfile(config.config_folder .. "/" .. name .. ".json") then
        local content = readfile(config.config_folder .. "/" .. name .. ".json")
        local data = http_service:JSONDecode(content)
        for flag, value in pairs(data) do
            library.flags[flag] = value
            if library.signals[flag] then
                for _, cb in pairs(library.signals[flag]) do
                    cb(value)
                end
            end
        end
    end
end

function library:create_keybind_list()
    if library.keybind_list then return end
    local screen = create("ScreenGui", {
        Name = "phantom_keybinds",
        Parent = get_parent(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    local frame = create("Frame", {
        Size = UDim2.new(0, 180, 0, 30),
        Position = UDim2.new(0.01, 0, 0.4, 0),
        BackgroundColor3 = theme.background,
        Parent = screen,
        Active = true,
        ClipsDescendants = true
    })
    corner(frame, 4)
    stroke(frame, theme.stroke, 1, 0)
    make_draggable(frame, frame)
    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundColor3 = theme.sidebar,
        Parent = frame
    })
    corner(header, 4)
    local title = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Keybinds",
        TextColor3 = theme.accent,
        Font = config.font_bold,
        TextSize = 12,
        Parent = header
    })
    register_theme(title, "text_color")
    local container = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundTransparency = 1,
        Parent = frame
    })
    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = container
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        frame.Size = UDim2.new(0, 180, 0, list.AbsoluteContentSize.Y + 30)
    end)
    library.keybind_list = {
        frame = frame,
        container = container,
        screen = screen
    }
    frame.Visible = false
end

local function get_real_elements()
    local count = 0
    if library.keybind_list then
        for _, child in pairs(library.keybind_list.container:GetChildren()) do
            if child:IsA("Frame") then
                count = count + 1
            end
        end
    end
    return count
end

function library:update_keybind_list(name, key, active)
    if not library.keybind_list then library:create_keybind_list() end
    local existing = library.keybind_list.container:FindFirstChild(name)
    if not library.show_keybinds then
        library.keybind_list.frame.Visible = false
        return
    end
    if active and key ~= "None" then
        library.keybind_list.frame.Visible = true
        if not existing then
            local item = create("Frame", {
                Name = name,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Parent = library.keybind_list.container
            })
            local l_name = create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = name,
                TextColor3 = theme.text,
                Font = config.font_main,
                TextSize = 12,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = item
            })
            local l_key = create("TextLabel", {
                Size = UDim2.new(0.4, -5, 1, 0),
                Position = UDim2.new(0.6, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = "["..key.."]",
                TextColor3 = theme.text_dark,
                Font = config.font_main,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = item
            })
        end
    else
        if existing then existing:Destroy() end
        task.wait()
        if get_real_elements() == 0 then
            library.keybind_list.frame.Visible = false
        end
    end
end

function library:create_window(options)
    if options and options.name then config.name = options.name end
    for _, g in pairs(get_parent():GetChildren()) do
        if g.Name == config.name or g.Name == "phantom_toggle" then g:Destroy() end
    end
    
    library.popup_layer = create("Frame", {
        Name = "popup_layer",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = get_parent(),
        ZIndex = 100
    })
    
    local screen_gui = create("ScreenGui", {
        Name = config.name,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        Parent = get_parent()
    })
    library.screen_gui = screen_gui
    
    local toggle_button_gui = create("ScreenGui", {
        Name = "phantom_toggle",
        Parent = get_parent(),
        Enabled = false,
        IgnoreGuiInset = true
    })
    
    local main_btn = create("TextButton", {
        Size = UDim2.new(0, 45, 0, 45),
        Position = UDim2.new(0, 20, 0.5, 0),
        BackgroundColor3 = theme.background,
        Text = "P",
        TextColor3 = theme.accent,
        Font = config.font_bold,
        TextSize = 20,
        Parent = toggle_button_gui,
        ClipsDescendants = true
    })
    corner(main_btn, 22)
    stroke(main_btn, theme.accent, 2)
    register_theme(main_btn, "text_color")
    make_draggable(main_btn, main_btn)
    
    local function create_base_frame(name)
        local frame = create("Frame", {
            Name = name,
            Size = UDim2.new(0, 700, 0, 450),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = theme.background,
            BackgroundTransparency = 0.02,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Visible = false,
            Parent = screen_gui,
            Active = true
        })
        corner(frame, 6)
        stroke(frame, theme.stroke, 1, 0)
        local drag_header = create("Frame", {
            Name = "drag_header",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            Parent = frame
        })
        local scale = Instance.new("UIScale")
        scale.Scale = 1
        scale.Parent = frame
        make_draggable(drag_header, frame)
        return frame, scale
    end
    
    local main_window, main_scale = create_base_frame("main_window")
    local settings_window, set_scale = create_base_frame("settings_window")
    
    local resizer = create("Frame", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = main_window,
        ZIndex = 20,
        Active = true
    })
    local resizer_icon = create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "◢",
        TextColor3 = theme.text_dark,
        TextSize = 16,
        Parent = resizer
    })
    resizer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            tween(resizer_icon, {TextColor3 = theme.accent})
        end
    end)
    resizer.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            tween(resizer_icon, {TextColor3 = theme.text_dark})
        end
    end)
    make_resizable(resizer, main_window, Vector2.new(500, 350), main_scale)
    
    local function create_sidebar(parent, is_settings)
        local bar = create("Frame", {
            Size = UDim2.new(0, 180, 1, 0),
            BackgroundColor3 = theme.sidebar,
            BorderSizePixel = 0,
            Parent = parent,
            Active = true
        })
        corner(bar, 6)
        local div = create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = theme.stroke,
            BorderSizePixel = 0,
            Parent = bar
        })
        if is_settings then
            local back_btn = create("TextButton", {
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 15),
                BackgroundColor3 = theme.container,
                Text = " < Back to Menu",
                Font = config.font_bold,
                TextSize = 13,
                TextColor3 = theme.text_dark,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent = bar
            })
            corner(back_btn, 4)
            stroke(back_btn, theme.stroke, 1, 0.5)
            back_btn.MouseEnter:Connect(function() tween(back_btn, {TextColor3 = theme.accent}) end)
            back_btn.MouseLeave:Connect(function() tween(back_btn, {TextColor3 = theme.text_dark}) end)
            register_theme(back_btn, "text_color")
            local title = create("TextLabel", {
                Text = "Settings",
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 55),
                Font = config.font_bold,
                TextSize = 22,
                TextColor3 = theme.text,
                BackgroundTransparency = 1,
                Parent = bar
            })
            return bar, nil, back_btn
        else
            local logo = create("TextLabel", {
                Text = config.name,
                RichText = true,
                Position = UDim2.new(0, 15, 0, 20),
                Size = UDim2.new(1, -30, 0, 30),
                Font = config.font_bold,
                TextSize = 20,
                TextColor3 = theme.accent,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Parent = bar
            })
            register_theme(logo, "text_color")
            local container = create("Frame", {
                Size = UDim2.new(1, 0, 1, -140),
                Position = UDim2.new(0, 0, 0, 70),
                BackgroundTransparency = 1,
                Parent = bar
            })
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
    
    local minimize_btn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -5, 0, 5),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = "-",
        Font = config.font_bold,
        TextSize = 24,
        TextColor3 = theme.text,
        ZIndex = 100,
        Parent = main_window
    })
    
    local profile_btn = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = theme.sidebar,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = main_bar
    })
    
    local side_avatar = create("ImageLabel", {
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 15, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = theme.container,
        Parent = profile_btn
    })
    local s, thumb = pcall(function() return players:GetUserThumbnailAsync(local_player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    if s and thumb then side_avatar.Image = thumb end
    corner(side_avatar, 18)
    local av_s = stroke(side_avatar, theme.accent, 1)
    register_theme(av_s, "border_color")
    
    local side_name = create("TextLabel", {
        Size = UDim2.new(0, 100, 0, 16),
        Position = UDim2.new(0, 60, 0.5, -9),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = local_player.Name,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextColor3 = theme.text,
        Font = config.font_bold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = profile_btn
    })
    
    local side_sub = create("TextLabel", {
        Size = UDim2.new(0, 100, 0, 14),
        Position = UDim2.new(0, 60, 0.5, 9),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "Settings",
        TextColor3 = theme.text_dark,
        Font = config.font_main,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = profile_btn
    })
    
    local is_settings = false
    local is_animating = false
    
    local function toggle_ui()
        if is_animating then return end
        is_animating = true
        library.open = not library.open
        if library.open then
            if is_settings then
                settings_window.Visible = true
                set_scale.Scale = 0
                tween(set_scale, {Scale = 1}, 0.25)
            else
                main_window.Visible = true
                main_scale.Scale = 0
                tween(main_scale, {Scale = 1}, 0.25)
            end
            toggle_button_gui.Enabled = false
            task.wait(0.25)
        else
            tween(main_scale, {Scale = 0}, 0.2)
            tween(set_scale, {Scale = 0}, 0.2)
            task.wait(0.2)
            main_window.Visible = false
            settings_window.Visible = false
            toggle_button_gui.Enabled = true
            main_btn.Size = UDim2.new(0, 0, 0, 0)
            tween(main_btn, {Size = UDim2.new(0, 45, 0, 45)}, 0.3, Enum.EasingStyle.Back)
            task.wait(0.3)
        end
        is_animating = false
    end
    
    minimize_btn.MouseButton1Click:Connect(toggle_ui)
    main_btn.MouseButton1Click:Connect(toggle_ui)
    
    local function switch_to_settings()
        if is_animating then return end
        is_animating = true
        tween(main_scale, {Scale = 0.9}, 0.2)
        task.wait(0.1)
        main_window.Visible = false
        settings_window.Visible = true
        set_scale.Scale = 0.9
        tween(set_scale, {Scale = 1}, 0.25)
        is_settings = true
        task.wait(0.25)
        is_animating = false
    end
    
    local function switch_to_main()
        if is_animating then return end
        is_animating = true
        tween(set_scale, {Scale = 0.9}, 0.2)
        task.wait(0.1)
        settings_window.Visible = false
        main_window.Visible = true
        main_scale.Scale = 0.9
        tween(main_scale, {Scale = 1}, 0.25)
        is_settings = false
        task.wait(0.25)
        is_animating = false
    end
    
    profile_btn.MouseButton1Click:Connect(switch_to_settings)
    back_btn.MouseButton1Click:Connect(switch_to_main)
    
    user_input_service.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == config.keybind then
            toggle_ui()
        end
    end)
    
    local window_obj = {}
    local main_pages = create("Frame", {
        Size = UDim2.new(1, -181, 1, 0),
        Position = UDim2.new(0, 181, 0, 0),
        BackgroundTransparency = 1,
        Parent = main_window
    })
    
    local function create_section_frame(text, parent, use_padding)
        local container = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = theme.section,
            Parent = parent
        })
        corner(container, 6)
        stroke(container, theme.stroke, 1, 0.5)
        
        local title = create("TextLabel", {
            Text = text,
            Font = config.font_bold,
            TextSize = 12,
            TextColor3 = theme.text_dark,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = container
        })
        
        local content = create("Frame", {
            Size = UDim2.new(1, -10, 0, 0),
            Position = UDim2.new(0, 5, 0, 30),
            BackgroundTransparency = 1,
            Parent = container
        })
        
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 8)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content
        
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 40)
        end)
        
        return container, content, list
    end
    
    function window_obj:create_raw_section(text, parent)
        local container, content, list = create_section_frame(text, parent)
        
        local section = {}
        
        function section:button(text_str, callback)
            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = theme.container,
                Text = text_str,
                Font = config.font_main,
                TextSize = 13,
                TextColor3 = theme.text,
                TextTruncate = Enum.TextTruncate.AtEnd,
                AutoButtonColor = false,
                Parent = content
            })
            corner(btn, 4)
            local s = stroke(btn, theme.stroke, 1, 0.5)
            btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = theme.stroke}) tween(s, {Color = theme.accent}) end)
            btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = theme.container}) tween(s, {Color = theme.stroke}) end)
            btn.MouseButton1Click:Connect(callback)
            section.button_label = btn
        end
        
        function section:toggle(text_str, flag, default, callback)
            local toggled = default or false
            library.flags[flag] = toggled
            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = theme.container,
                Text = "",
                AutoButtonColor = false,
                Parent = content
            })
            corner(btn, 4)
            stroke(btn, theme.stroke, 1, 0.5)
            
            local label = create("TextLabel", {
                Text = text_str,
                Font = config.font_main,
                TextSize = 13,
                TextColor3 = theme.text,
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BackgroundTransparency = 1,
                Parent = btn
            })
            
            local box = create("Frame", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -10, 0.5, 0),
                AnchorPoint = Vector2.new(1, 0.5),
                BackgroundColor3 = theme.background,
                Parent = btn
            })
            corner(box, 4)
            stroke(box, theme.stroke, 1, 0.5)
            
            local fill = create("Frame", {
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = theme.accent,
                BackgroundTransparency = toggled and 0 or 1,
                Parent = box
            })
            corner(fill, 3)
            register_theme(fill, "background_color")
            
            library.signals[flag] = library.signals[flag] or {}
            table.insert(library.signals[flag], function(val)
                toggled = val
                tween(fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                callback(toggled)
            end)
            
            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                tween(fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                library.flags[flag] = toggled
                callback(toggled)
            end)
        end
        
        function section:text_box(text_str, placeholder, callback)
            local frame = create("Frame", {
                Size = UDim2.new(1, 0, 0, 52),
                BackgroundTransparency = 1,
                Parent = content
            })
            
            local label = create("TextLabel", {
                Text = text_str,
                Font = config.font_main,
                TextSize = 13,
                TextColor3 = theme.text,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 5, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BackgroundTransparency = 1,
                Parent = frame
            })
            
            local box_cont = create("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundColor3 = theme.container,
                Parent = frame
            })
            corner(box_cont, 4)
            
            local input = create("TextBox", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextColor3 = theme.text,
                PlaceholderText = placeholder,
                Font = config.font_main,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = "",
                Parent = box_cont
            })
            
            input.FocusLost:Connect(function(enter)
                if enter then callback(input.Text) end
            end)
        end
        
        return section
    end
    
    local function populate_settings()
        local set_page = create("ScrollingFrame", {
            Size = UDim2.new(1, -200, 1, -20),
            Position = UDim2.new(0, 190, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = theme.accent,
            Parent = settings_window
        })
        register_theme(set_page, "scroll_bar")
        
        local list_layout = Instance.new("UIListLayout")
        list_layout.SortOrder = Enum.SortOrder.LayoutOrder
        list_layout.Padding = UDim.new(0, 10)
        list_layout.Parent = set_page
        
        list_layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            set_page.CanvasSize = UDim2.new(0, 0, 0, list_layout.AbsoluteContentSize.Y + 20)
        end)
        
        local menu_sec = window_obj:create_raw_section("Menu Settings", set_page)
        menu_sec:button("Menu Keybind: " .. tostring(config.keybind.Name), function()
            menu_sec.button_label.Text = "Press any key..."
            local connection
            connection = user_input_service.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    connection:Disconnect()
                    config.keybind = input.KeyCode
                    menu_sec.button_label.Text = "Menu Keybind: " .. tostring(config.keybind.Name)
                end
            end)
            task.wait(5)
            if connection and connection.Connected then
                connection:Disconnect()
                menu_sec.button_label.Text = "Menu Keybind: " .. tostring(config.keybind.Name)
            end
        end)
        
        menu_sec:toggle("Show Keybind List", "keybind_list_toggle", true, function(state)
            library.show_keybinds = state
            if library.keybind_list then
                library.keybind_list.frame.Visible = state and (get_real_elements() > 0)
            end
        end)
        
        local config_sec = window_obj:create_raw_section("Configuration", set_page)
        local config_name = ""
        config_sec:text_box("Config Name", "e.g. Legit", function(val)
            config_name = val
        end)
        config_sec:button("Save Config", function()
            if config_name ~= "" then
                library:save_config(config_name)
            end
        end)
        config_sec:button("Load Config", function()
            if config_name ~= "" then
                library:load_config(config_name)
            end
        end)
    end
    
    populate_settings()
    
    function window_obj:tab(name, icon_id)
        local tab = {}
        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            ScrollBarThickness = 0,
            Visible = false,
            Parent = main_pages
        })
        
        local tab_btn = create("TextButton", {
            Size = UDim2.new(0, 160, 0, 38),
            BackgroundColor3 = theme.background,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = tab_container
        })
        corner(tab_btn, 6)
        
        local title = create("TextLabel", {
            Text = name,
            Font = config.font_main,
            TextSize = 14,
            TextColor3 = theme.text_dark,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, icon_id and 35 or 15, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            BackgroundTransparency = 1,
            Parent = tab_btn
        })
        
        if icon_id then
            local ico = create("ImageLabel", {
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 8, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundTransparency = 1,
                Parent = tab_btn
            })
            if tonumber(icon_id) then
                ico.Image = "rbxassetid://" .. icon_id
            else
                ico.Image = icon_id
            end
            ico.ImageColor3 = theme.text_dark
            tab_btn.MouseEnter:Connect(function()
                if tab_btn.BackgroundTransparency > 0.5 then
                    tween(ico, {ImageColor3 = theme.text})
                end
            end)
            tab_btn.MouseLeave:Connect(function()
                if tab_btn.BackgroundTransparency > 0.5 then
                    tween(ico, {ImageColor3 = theme.text_dark})
                end
            end)
        end
        
        local indicator = create("Frame", {
            Size = UDim2.new(0, 3, 0, 16),
            Position = UDim2.new(0, 0, 0.5, -8),
            BackgroundColor3 = theme.accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = tab_btn
        })
        corner(indicator, 2)
        register_theme(indicator, "background_color")
        
        tab_btn.MouseButton1Click:Connect(function()
            for _, p in pairs(main_pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
            for _, t in pairs(tab_container:GetChildren()) do
                if t:IsA("TextButton") then
                    tween(t.TextLabel, {TextColor3 = theme.text_dark})
                    tween(t, {BackgroundTransparency = 1, BackgroundColor3 = theme.background})
                    if t:FindFirstChild("ImageLabel") then tween(t.ImageLabel, {ImageColor3 = theme.text_dark}) end
                    tween(t.Frame, {BackgroundTransparency = 1})
                end
            end
            page.Visible = true
            tween(title, {TextColor3 = theme.text})
            tween(tab_btn, {BackgroundTransparency = 0.95, BackgroundColor3 = theme.text})
            if tab_btn:FindFirstChild("ImageLabel") then tween(tab_btn.ImageLabel, {ImageColor3 = theme.text}) end
            tween(indicator, {BackgroundTransparency = 0})
        end)
        
        if #tab_container:GetChildren() == 1 then
            page.Visible = true
            title.TextColor3 = theme.text
            tab_btn.BackgroundTransparency = 0.95
            tab_btn.BackgroundColor3 = theme.text
            if tab_btn:FindFirstChild("ImageLabel") then tab_btn.ImageLabel.ImageColor3 = theme.text end
            indicator.BackgroundTransparency = 0
        end
        
        local left_col = create("Frame", {
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = page
        })
        local left_list = Instance.new("UIListLayout")
        left_list.SortOrder = Enum.SortOrder.LayoutOrder
        left_list.Padding = UDim.new(0, 10)
        left_list.Parent = left_col
        
        local right_col = create("Frame", {
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 5, 0, 0),
            BackgroundTransparency = 1,
            Parent = page
        })
        local right_list = Instance.new("UIListLayout")
        right_list.SortOrder = Enum.SortOrder.LayoutOrder
        right_list.Padding = UDim.new(0, 10)
        right_list.Parent = right_col
        
        function tab:section(text_str, side)
            local section = {}
            local parent_col = (side == "Right" and right_col or left_col)
            local container, content, list = create_section_frame(text_str, parent_col)
            
            local function update_canvas()
                page.CanvasSize = UDim2.new(0, 0, 0, math.max(left_list.AbsoluteContentSize.Y, right_list.AbsoluteContentSize.Y) + 20)
            end
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_canvas)
            left_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_canvas)
            right_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_canvas)
            
            function section:toggle(text_str, flag, default, callback)
                local toggled = default or false
                library.flags[flag] = toggled
                local toggle_obj = {}
                local btn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = content
                })
                
                local label = create("TextLabel", {
                    Text = text_str,
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = theme.text,
                    Size = UDim2.new(0.65, 0, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                    Parent = btn
                })
                
                local box = create("Frame", {
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(1, -5, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = theme.background,
                    Parent = btn
                })
                corner(box, 4)
                stroke(box, theme.stroke, 1, 0.5)
                
                local fill = create("Frame", {
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = theme.accent,
                    BackgroundTransparency = 1,
                    Parent = box
                })
                corner(fill, 3)
                register_theme(fill, "background_color")
                
                local sub_container = create("Frame", {
                    Name = "sub_" .. text_str,
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Visible = false,
                    Parent = content
                })
                local sub_list = Instance.new("UIListLayout")
                sub_list.Padding = UDim.new(0, 8)
                sub_list.SortOrder = Enum.SortOrder.LayoutOrder
                sub_list.Parent = sub_container
                
                local function toggle_anim()
                    tween(fill, {BackgroundTransparency = toggled and 0 or 1}, 0.2)
                    library.flags[flag] = toggled
                    if toggle_obj.keybind_value then
                        library:update_keybind_list(text_str, toggle_obj.keybind_value.Name, toggled)
                    end
                    if toggled then
                        sub_container.Visible = true
                        local h = sub_list.AbsoluteContentSize.Y
                        if h > 0 then h = h + 8 end
                        tween(sub_container, {Size = UDim2.new(1, 0, 0, h)}, 0.3)
                    else
                        tween(sub_container, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
                        task.delay(0.3, function() if not toggled then sub_container.Visible = false end end)
                    end
                end
                
                sub_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if toggled then
                        local h = sub_list.AbsoluteContentSize.Y
                        if h > 0 then h = h + 8 end
                        tween(sub_container, {Size = UDim2.new(1, 0, 0, h)}, 0.1)
                    end
                end)
                
                library.signals[flag] = library.signals[flag] or {}
                table.insert(library.signals[flag], function(val)
                    toggled = val
                    toggle_anim()
                    callback(toggled)
                end)
                
                btn.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    toggle_anim()
                    callback(toggled)
                end)
                
                if toggled then toggle_anim() end
                
                function toggle_obj:add_button(txt, cb)
                    local s_btn = create("TextButton", {
                        Size = UDim2.new(1, -20, 0, 28),
                        Position = UDim2.new(0, 20, 0, 0),
                        BackgroundColor3 = theme.container,
                        Text = txt,
                        Font = config.font_main,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        AutoButtonColor = false,
                        Parent = sub_container
                    })
                    corner(s_btn, 4)
                    local s = stroke(s_btn, theme.stroke, 1, 0.5)
                    s_btn.MouseEnter:Connect(function() tween(s_btn, {BackgroundColor3 = theme.stroke}) tween(s, {Color = theme.accent}) end)
                    s_btn.MouseLeave:Connect(function() tween(s_btn, {BackgroundColor3 = theme.container}) tween(s, {Color = theme.stroke}) end)
                    s_btn.MouseButton1Click:Connect(cb)
                end
                
                function toggle_obj:add_slider(txt, min, max, def, cb)
                    local s_frame = create("Frame", {
                        Size = UDim2.new(1, -20, 0, 42),
                        BackgroundTransparency = 1,
                        Parent = sub_container
                    })
                    local s_label = create("TextLabel", {
                        Text = txt,
                        Font = config.font_main,
                        TextSize = 12,
                        TextColor3 = theme.text_dark,
                        Size = UDim2.new(1, 0, 0, 18),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        BackgroundTransparency = 1,
                        Parent = s_frame
                    })
                    local s_value = create("TextLabel", {
                        Text = tostring(def),
                        Font = config.font_main,
                        TextSize = 12,
                        TextColor3 = theme.text,
                        Size = UDim2.new(1, 0, 0, 18),
                        TextXAlignment = Enum.TextXAlignment.Right,
                        BackgroundTransparency = 1,
                        Parent = s_frame
                    })
                    local slide_bg = create("Frame", {
                        Size = UDim2.new(1, 0, 0, 6),
                        Position = UDim2.new(0, 0, 0, 26),
                        BackgroundColor3 = theme.background,
                        Parent = s_frame
                    })
                    corner(slide_bg, 3)
                    local slide_fill = create("Frame", {
                        Size = UDim2.new((def - min) / (max - min), 0, 1, 0),
                        BackgroundColor3 = theme.accent,
                        BorderSizePixel = 0,
                        Parent = slide_bg
                    })
                    corner(slide_fill, 3)
                    register_theme(slide_fill, "background_color")
                    
                    local dragging_sub = false
                    local function set_sub(input)
                        local r = math.clamp((input.Position.X - slide_bg.AbsolutePosition.X) / slide_bg.AbsoluteSize.X, 0, 1)
                        local val = math.floor(min + (max - min) * r)
                        s_value.Text = tostring(val)
                        tween(slide_fill, {Size = UDim2.new(r, 0, 1, 0)}, 0.05)
                        cb(val)
                    end
                    slide_bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_sub = true set_sub(i) end end)
                    user_input_service.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_sub = false end end)
                    user_input_service.InputChanged:Connect(function(i) if dragging_sub and i.UserInputType == Enum.UserInputType.MouseMovement then set_sub(i) end end)
                end
                
                function toggle_obj:add_dropdown(txt, opts, def, cb)
                    section:dropdown(txt, opts, def, cb, sub_container)
                end
                
                function toggle_obj:keybind(default_key)
                    toggle_obj.keybind_value = default_key or Enum.KeyCode.None
                    local key_btn = create("TextButton", {
                        Size = UDim2.new(0, 60, 0, 18),
                        Position = UDim2.new(1, -30, 0.5, 0),
                        AnchorPoint = Vector2.new(1, 0.5),
                        BackgroundTransparency = 1,
                        Text = "[" .. (toggle_obj.keybind_value.Name) .. "]",
                        TextColor3 = theme.text_dark,
                        Font = config.font_main,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Parent = btn
                    })
                    
                    key_btn.MouseButton1Click:Connect(function()
                        key_btn.Text = "[...]"
                        key_btn.TextColor3 = theme.accent
                        local connection
                        connection = user_input_service.InputBegan:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                connection:Disconnect()
                                toggle_obj.keybind_value = input.KeyCode
                                key_btn.Text = "[" .. (toggle_obj.keybind_value.Name) .. "]"
                                key_btn.TextColor3 = theme.text_dark
                            end
                        end)
                        task.wait(5)
                        if connection and connection.Connected then
                            connection:Disconnect()
                            key_btn.Text = "[" .. (toggle_obj.keybind_value.Name) .. "]"
                            key_btn.TextColor3 = theme.text_dark
                        end
                    end)
                    
                    user_input_service.InputBegan:Connect(function(input, gp)
                        if not gp and input.KeyCode == toggle_obj.keybind_value then
                            toggled = not toggled
                            toggle_anim()
                            callback(toggled)
                        end
                    end)
                    return toggle_obj
                end
                return toggle_obj
            end
            
            function section:button(text_str, callback)
                local btn = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = theme.container,
                    Text = text_str,
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = theme.text,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    AutoButtonColor = false,
                    Parent = content
                })
                corner(btn, 4)
                local s = stroke(btn, theme.stroke, 1, 0.5)
                btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = theme.stroke}) tween(s, {Color = theme.accent}) end)
                btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = theme.container}) tween(s, {Color = theme.stroke}) end)
                register_theme(s, "border_color")
                btn.MouseButton1Click:Connect(callback)
            end
            
            function section:slider(text_str, min, max, default, callback)
                local val = default or min
                local frame = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 48),
                    BackgroundTransparency = 1,
                    Parent = content
                })
                local label = create("TextLabel", {
                    Text = text_str,
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = theme.text,
                    Size = UDim2.new(0.6, 0, 0, 20),
                    Position = UDim2.new(0, 5, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                local val_label = create("TextLabel", {
                    Text = tostring(val),
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = theme.text,
                    Size = UDim2.new(0.4, -5, 0, 20),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                local bar = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 28),
                    BackgroundColor3 = theme.container,
                    Parent = frame
                })
                corner(bar, 3)
                stroke(bar, theme.stroke, 1, 0.5)
                local fill = create("Frame", {
                    Size = UDim2.new((val - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = theme.accent,
                    BorderSizePixel = 0,
                    Parent = bar
                })
                corner(fill, 3)
                register_theme(fill, "background_color")
                
                local dragging_slider = false
                local function set_val(input)
                    local ratio = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local new_value = math.floor(min + (max - min) * ratio)
                    val_label.Text = tostring(new_value)
                    tween(fill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.05)
                    callback(new_value)
                end
                bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_slider = true set_val(i) end end)
                user_input_service.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging_slider = false end end)
                user_input_service.InputChanged:Connect(function(i) if dragging_slider and i.UserInputType == Enum.UserInputType.MouseMovement then set_val(i) end end)
            end
            
            function section:text_box(text_str, placeholder, callback)
                local frame = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundTransparency = 1,
                    Parent = content
                })
                local label = create("TextLabel", {
                    Text = text_str,
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = theme.text,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 5, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                local box_cont = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = theme.container,
                    Parent = frame
                })
                corner(box_cont, 4)
                local s = stroke(box_cont, theme.stroke, 1, 0.5)
                local input = create("TextBox", {
                    Size = UDim2.new(1, -10, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = theme.text,
                    PlaceholderText = placeholder or "Type here...",
                    PlaceholderColor3 = theme.text_dark,
                    Font = config.font_main,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = "",
                    Parent = box_cont
                })
                input.Focused:Connect(function() tween(s, {Color = theme.accent}) end)
                input.FocusLost:Connect(function(enter)
                    tween(s, {Color = theme.stroke})
                    if enter then callback(input.Text) end
                end)
            end
            
            function section:dropdown(text_str, options, default, callback, custom_parent)
                local selected = default or options[1]
                local is_dropped = false
                local parent = custom_parent or content
                local drop_frame = create("Frame", {
                    Size = UDim2.new(1, custom_parent and -20 or 0, 0, 52),
                    Position = custom_parent and UDim2.new(0, 20, 0, 0) or UDim2.new(0, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Parent = parent,
                    ZIndex = 5
                })
                local label = create("TextLabel", {
                    Text = text_str,
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = custom_parent and theme.text_dark or theme.text,
                    Size = UDim2.new(1, 0, 0, 20),
                    Position = UDim2.new(0, 5, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                    Parent = drop_frame
                })
                local interactive = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 22),
                    BackgroundColor3 = theme.container,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = drop_frame,
                    ZIndex = 5
                })
                corner(interactive, 4)
                stroke(interactive, theme.stroke, 1, 0.5)
                
                local selected_text = create("TextLabel", {
                    Text = selected,
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = theme.text,
                    Size = UDim2.new(1, -25, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                    ZIndex = 6,
                    Parent = interactive
                })
                
                local arrow = create("ImageLabel", {
                    Image = "rbxassetid://10709790948",
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(1, -20, 0.5, 0),
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    ImageColor3 = theme.text_dark,
                    Parent = interactive,
                    ZIndex = 6
                })
                
                local list_frame = create("ScrollingFrame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    BackgroundColor3 = theme.container,
                    BorderSizePixel = 0,
                    Parent = interactive,
                    ZIndex = 10,
                    Visible = false,
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = theme.accent
                })
                corner(list_frame, 4)
                stroke(list_frame, theme.stroke, 1, 0.5)
                
                local i_list = Instance.new("UIListLayout")
                i_list.SortOrder = Enum.SortOrder.LayoutOrder
                i_list.Parent = list_frame
                i_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list_frame.CanvasSize = UDim2.new(0, 0, 0, i_list.AbsoluteContentSize.Y)
                end)
                
                for _, opt in ipairs(options) do
                    local opt_btn = create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = theme.container,
                        BackgroundTransparency = 1,
                        Text = opt,
                        TextColor3 = theme.text_dark,
                        Font = config.font_main,
                        TextSize = 12,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Parent = list_frame,
                        ZIndex = 11
                    })
                    opt_btn.MouseEnter:Connect(function() tween(opt_btn, {BackgroundTransparency = 0.8, TextColor3 = theme.accent}) end)
                    opt_btn.MouseLeave:Connect(function() tween(opt_btn, {BackgroundTransparency = 1, TextColor3 = theme.text_dark}) end)
                    register_theme(opt_btn, "text_color")
                    opt_btn.MouseButton1Click:Connect(function()
                        selected = opt
                        selected_text.Text = selected
                        callback(selected)
                        is_dropped = false
                        tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, 52)}, 0.2)
                        tween(list_frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        tween(arrow, {Rotation = 0}, 0.2)
                        task.wait(0.2)
                        list_frame.Visible = false
                    end)
                end
                
                interactive.MouseButton1Click:Connect(function()
                    is_dropped = not is_dropped
                    if is_dropped then
                        list_frame.Visible = true
                        local list_h = math.min(#options * 28, 200)
                        local total_h = 52 + list_h + 5
                        tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, total_h)}, 0.2)
                        tween(list_frame, {Size = UDim2.new(1, 0, 0, list_h)}, 0.2)
                        tween(arrow, {Rotation = 180}, 0.2)
                    else
                        tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, 52)}, 0.2)
                        tween(list_frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        tween(arrow, {Rotation = 0}, 0.2)
                        task.wait(0.2)
                        list_frame.Visible = false
                    end
                end)
            end
            
            function section:color_picker(text_str, default, callback)
                local color = default or Color3.fromRGB(255, 255, 255)
                local h, s_val, v = color:ToHSV()
                local is_open = false
                local frame = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundTransparency = 1,
                    Parent = content,
                    ZIndex = 5
                })
                local label = create("TextLabel", {
                    Text = text_str,
                    Font = config.font_main,
                    TextSize = 13,
                    TextColor3 = theme.text,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    BackgroundTransparency = 1,
                    Parent = frame
                })
                local preview = create("TextButton", {
                    Size = UDim2.new(0, 40, 0, 24),
                    Position = UDim2.new(1, -5, 0.5, 0),
                    AnchorPoint = Vector2.new(1, 0.5),
                    BackgroundColor3 = color,
                    AutoButtonColor = false,
                    Text = "",
                    Parent = frame
                })
                corner(preview, 4)
                stroke(preview, theme.stroke, 1, 0.5)
                
                local picker_cont = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    BackgroundColor3 = theme.background,
                    Parent = content,
                    ClipsDescendants = true,
                    ZIndex = 10
                })
                corner(picker_cont, 4)
                
                local sv_map = create("ImageLabel", {
                    Size = UDim2.new(0, 140, 0, 120),
                    Position = UDim2.new(0, 10, 0, 10),
                    Image = "rbxassetid://4155801252",
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    Parent = picker_cont,
                    ZIndex = 11
                })
                corner(sv_map, 4)
                
                local sv_cursor = create("Frame", {
                    Size = UDim2.new(0, 8, 0, 8),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    Parent = sv_map,
                    Position = UDim2.new(s_val, 0, 1-v, 0),
                    ZIndex = 12
                })
                corner(sv_cursor, 4)
                
                local hue_bar = create("ImageLabel", {
                    Size = UDim2.new(0, 20, 0, 120),
                    Position = UDim2.new(0, 160, 0, 10),
                    Image = "rbxassetid://4155801252",
                    Parent = picker_cont,
                    ZIndex = 11
                })
                corner(hue_bar, 4)
                
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
                
                local h_cursor = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 2),
                    BackgroundColor3 = Color3.new(1,1,1),
                    Parent = hue_bar,
                    Position = UDim2.new(0, 0, h, 0),
                    ZIndex = 12
                })
                
                local function update_col()
                    color = Color3.fromHSV(h, s_val, v)
                    preview.BackgroundColor3 = color
                    sv_map.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    callback(color)
                end
                
                local function set_sv(input)
                    local r_x = math.clamp((input.Position.X - sv_map.AbsolutePosition.X) / sv_map.AbsoluteSize.X, 0, 1)
                    local r_y = math.clamp((input.Position.Y - sv_map.AbsolutePosition.Y) / sv_map.AbsoluteSize.Y, 0, 1)
                    s_val = r_x
                    v = 1 - r_y
                    sv_cursor.Position = UDim2.new(s_val, 0, 1-v, 0)
                    update_col()
                end
                
                local function set_h(input)
                    local r_y = math.clamp((input.Position.Y - hue_bar.AbsolutePosition.Y) / hue_bar.AbsoluteSize.Y, 0, 1)
                    h = r_y
                    h_cursor.Position = UDim2.new(0, 0, h, 0)
                    update_col()
                end
                
                local drag_sv, drag_h = false, false
                sv_map.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag_sv = true set_sv(i) end end)
                hue_bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag_h = true set_h(i) end end)
                user_input_service.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then drag_sv = false drag_h = false end end)
                user_input_service.InputChanged:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseMovement then
                        if drag_sv then set_sv(i) end
                        if drag_h then set_h(i) end
                    end
                end)
                
                preview.MouseButton1Click:Connect(function()
                    is_open = not is_open
                    tween(picker_cont, {Size = UDim2.new(1, 0, 0, is_open and 140 or 0)}, 0.2)
                end)
            end
            
            return section
        end
        return tab
    end
    
    main_scale.Scale = 1
    main_window.Visible = true
    return window_obj
end

return library
