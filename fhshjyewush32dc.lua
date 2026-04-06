local user_input_service = game:GetService("UserInputService")
local tween_service = game:GetService("TweenService")
local run_service = game:GetService("RunService")
local players = game:GetService("Players")
local core_gui = game:GetService("CoreGui")
local http_service = game:GetService("HttpService")
local marketplace_service = game:GetService("MarketplaceService")
local local_player = players.LocalPlayer
local mouse = local_player:GetMouse()
local library = {
    flags = {},
    signals = {},
    open = true,
    keybind_list = nil,
    show_keybinds = true,
    screen_gui = nil
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
    background = Color3.fromHex("#050505"),
    sidebar = Color3.fromHex("#0a0a0a"),
    container = Color3.fromHex("#121212"),
    section = Color3.fromHex("#181818"),
    accent = Color3.fromHex("#d90429"),
    text = Color3.fromHex("#ffffff"),
    text_dark = Color3.fromHex("#8b8b8b"),
    stroke = Color3.fromHex("#2a2a2a"),
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
    resize_btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            drag_start = input.Position
            start_size = frame.Size
            local input_changed
            input_changed = user_input_service.InputChanged:Connect(function(input_evt)
                if input_evt.UserInputType == Enum.UserInputType.MouseMovement then
                    local scale = scale_obj and scale_obj.Scale or 1
                    local delta = (input_evt.Position - drag_start) / scale
                    local new_x = math.max(min_size.X, start_size.X.Offset + delta.X)
                    local new_y = math.max(min_size.Y, start_size.Y.Offset + delta.Y)
                    frame.Size = UDim2.new(0, new_x, 0, new_y)
                end
            end)
            local input_ended
            input_ended = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    input_changed:Disconnect()
                    input_ended:Disconnect()
                end
            end)
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
    local screen = Instance.new("ScreenGui")
    screen.Name = "phantom_keybinds"
    screen.Parent = get_parent()
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 30)
    frame.Position = UDim2.new(0.01, 0, 0.4, 0)
    frame.BackgroundColor3 = theme.background
    frame.Parent = screen
    frame.Active = true
    frame.ClipsDescendants = true
    corner(frame, 4)
    stroke(frame, theme.stroke, 1, 0)
    make_draggable(frame, frame)
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 24)
    header.BackgroundColor3 = theme.sidebar
    header.Parent = frame
    corner(header, 4)
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "Keybinds"
    title.TextColor3 = theme.accent
    title.Font = config.font_bold
    title.TextSize = 12
    title.Parent = header
    register_theme(title, "text_color")
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.Position = UDim2.new(0, 0, 0, 26)
    container.BackgroundTransparency = 1
    container.Parent = frame
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
            l_name.TextTruncate = Enum.TextTruncate.AtEnd
            l_name.TextXAlignment = Enum.TextXAlignment.Left
            l_name.Parent = item
            local l_key = Instance.new("TextLabel")
            l_key.Size = UDim2.new(0.4, -5, 1, 0)
            l_key.Position = UDim2.new(0.6, 0, 0, 0)
            l_key.BackgroundTransparency = 1
            l_key.Text = "["..key.."]"
            l_key.TextColor3 = theme.text_dark
            l_key.Font = config.font_main
            l_key.TextSize = 12
            l_key.TextXAlignment = Enum.TextXAlignment.Right
            l_key.Parent = item
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
    local screen_gui = Instance.new("ScreenGui")
    screen_gui.Name = config.name
    screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen_gui.IgnoreGuiInset = true
    screen_gui.ResetOnSpawn = false
    screen_gui.Parent = get_parent()
    library.screen_gui = screen_gui
    local toggle_button_gui = Instance.new("ScreenGui")
    toggle_button_gui.Name = "phantom_toggle"
    toggle_button_gui.Parent = get_parent()
    toggle_button_gui.Enabled = false
    toggle_button_gui.IgnoreGuiInset = true
    local main_btn = Instance.new("TextButton")
    main_btn.Size = UDim2.new(0, 45, 0, 45)
    main_btn.Position = UDim2.new(0, 20, 0.5, 0)
    main_btn.BackgroundColor3 = theme.background
    main_btn.Text = "P"
    main_btn.TextColor3 = theme.accent
    main_btn.Font = config.font_bold
    main_btn.TextSize = 20
    main_btn.Parent = toggle_button_gui
    main_btn.ClipsDescendants = true
    corner(main_btn, 22)
    stroke(main_btn, theme.accent, 2)
    register_theme(main_btn, "text_color")
    make_draggable(main_btn, main_btn)
    local function create_base_frame(name)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.Size = UDim2.new(0, 700, 0, 450)
        frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundColor3 = theme.background
        frame.BackgroundTransparency = 0.02
        frame.BorderSizePixel = 0
        frame.ClipsDescendants = true
        frame.Visible = false
        frame.Parent = screen_gui
        frame.Active = true
        corner(frame, 6)
        stroke(frame, theme.stroke, 1, 0)
        local drag_header = Instance.new("Frame")
        drag_header.Name = "drag_header"
        drag_header.Size = UDim2.new(1, 0, 0, 40)
        drag_header.BackgroundTransparency = 1
        drag_header.Parent = frame
        local scale = Instance.new("UIScale")
        scale.Scale = 1
        scale.Parent = frame
        make_draggable(drag_header, frame)
        return frame, scale
    end
    local main_window, main_scale = create_base_frame("main_window")
    local settings_window, set_scale = create_base_frame("settings_window")
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
        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(0, 180, 1, 0)
        bar.BackgroundColor3 = theme.sidebar
        bar.BorderSizePixel = 0
        bar.Parent = parent
        bar.Active = true
        corner(bar, 6)
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
            back_btn.Parent = bar
            corner(back_btn, 4)
            stroke(back_btn, theme.stroke, 1, 0.5)
            back_btn.MouseEnter:Connect(function() tween(back_btn, {TextColor3 = theme.accent}) end)
            back_btn.MouseLeave:Connect(function() tween(back_btn, {TextColor3 = theme.text_dark}) end)
            register_theme(back_btn, "text_color")
            local title = Instance.new("TextLabel")
            title.Text = "Settings"
            title.Size = UDim2.new(1, 0, 0, 30)
            title.Position = UDim2.new(0, 0, 0, 55)
            title.Font = config.font_bold
            title.TextSize = 22
            title.TextColor3 = theme.text
            title.BackgroundTransparency = 1
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
            register_theme(logo, "text_color")
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 1, -140)
            container.Position = UDim2.new(0, 0, 0, 70)
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
    local minimize_btn = Instance.new("TextButton")
    minimize_btn.Size = UDim2.new(0, 30, 0, 30)
    minimize_btn.Position = UDim2.new(1, -5, 0, 5)
    minimize_btn.AnchorPoint = Vector2.new(1, 0)
    minimize_btn.BackgroundTransparency = 1
    minimize_btn.Text = "-"
    minimize_btn.Font = config.font_bold
    minimize_btn.TextSize = 24
    minimize_btn.TextColor3 = theme.text
    minimize_btn.ZIndex = 100
    minimize_btn.Parent = main_window
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
    local s, thumb = pcall(function() return players:GetUserThumbnailAsync(local_player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    if s and thumb then side_avatar.Image = thumb end
    side_avatar.Parent = profile_btn
    corner(side_avatar, 18)
    local av_s = stroke(side_avatar, theme.accent, 1)
    register_theme(av_s, "border_color")
    local side_name = Instance.new("TextLabel")
    side_name.Size = UDim2.new(0, 100, 0, 16)
    side_name.Position = UDim2.new(0, 60, 0.5, -9)
    side_name.AnchorPoint = Vector2.new(0, 0.5)
    side_name.BackgroundTransparency = 1
    side_name.Text = local_player.Name
    side_name.TextTruncate = Enum.TextTruncate.AtEnd
    side_name.TextColor3 = theme.text
    side_name.Font = config.font_bold
    side_name.TextSize = 13
    side_name.TextXAlignment = Enum.TextXAlignment.Left
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
    side_sub.Parent = profile_btn
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
        corner(container, 6)
        stroke(container, theme.stroke, 1, 0.5)
        local title = Instance.new("TextLabel")
        title.Text = text
        title.Font = config.font_bold
        title.TextSize = 12
        title.TextColor3 = theme.text_dark
        title.Size = UDim2.new(1, -20, 0, 30)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.Parent = container
        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -10, 0, 0)
        content.Position = UDim2.new(0, 5, 0, 30)
        content.BackgroundTransparency = 1
        content.Parent = container
        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 6)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            container.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 40)
        end)
        function section:button(text_str, callback)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = theme.container
            btn.Text = text_str
            btn.Font = config.font_main
            btn.TextSize = 13
            btn.TextColor3 = theme.text
            btn.TextTruncate = Enum.TextTruncate.AtEnd
            btn.AutoButtonColor = false
            btn.Parent = content
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
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 32)
            btn.BackgroundColor3 = theme.container
            btn.Text = ""
            btn.AutoButtonColor = false
            btn.Parent = content
            corner(btn, 4)
            stroke(btn, theme.stroke, 1, 0.5)
            local label = Instance.new("TextLabel")
            label.Text = text_str
            label.Font = config.font_main
            label.TextSize = 13
            label.TextColor3 = theme.text
            label.Size = UDim2.new(1, -30, 1, 0)
            label.Position = UDim2.new(0, 10, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.BackgroundTransparency = 1
            label.Parent = btn
            local box = Instance.new("Frame")
            box.Size = UDim2.new(0, 18, 0, 18)
            box.Position = UDim2.new(1, -10, 0.5, 0)
            box.AnchorPoint = Vector2.new(1, 0.5)
            box.BackgroundColor3 = theme.background
            box.Parent = btn
            corner(box, 4)
            stroke(box, theme.stroke, 1, 0.5)
            local fill = Instance.new("Frame")
            fill.Size = UDim2.new(1, -4, 1, -4)
            fill.Position = UDim2.new(0.5, 0, 0.5, 0)
            fill.AnchorPoint = Vector2.new(0.5, 0.5)
            fill.BackgroundColor3 = theme.accent
            fill.BackgroundTransparency = toggled and 0 or 1
            fill.Parent = box
            corner(fill, 3)
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
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 0, 50)
            frame.BackgroundTransparency = 1
            frame.Parent = content
            local label = Instance.new("TextLabel")
            label.Text = text_str
            label.Font = config.font_main
            label.TextSize = 13
            label.TextColor3 = theme.text
            label.Size = UDim2.new(1, 0, 0, 20)
            label.Position = UDim2.new(0, 5, 0, 0)
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextTruncate = Enum.TextTruncate.AtEnd
            label.BackgroundTransparency = 1
            label.Parent = frame
            local box_cont = Instance.new("Frame")
            box_cont.Size = UDim2.new(1, 0, 0, 28)
            box_cont.Position = UDim2.new(0, 0, 0, 22)
            box_cont.BackgroundColor3 = theme.container
            box_cont.Parent = frame
            corner(box_cont, 4)
            local input = Instance.new("TextBox")
            input.Size = UDim2.new(1, -10, 1, 0)
            input.Position = UDim2.new(0, 5, 0, 0)
            input.BackgroundTransparency = 1
            input.TextColor3 = theme.text
            input.PlaceholderText = placeholder
            input.Font = config.font_main
            input.TextSize = 13
            input.TextXAlignment = Enum.TextXAlignment.Left
            input.Text = ""
            input.Parent = box_cont
            input.FocusLost:Connect(function(enter)
                if enter then callback(input.Text) end
            end)
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
            local input = user_input_service.InputBegan:Wait()
            if input.UserInputType == Enum.UserInputType.Keyboard then
                config.keybind = input.KeyCode
            end
            menu_sec.button_label.Text = "Menu Keybind: " .. tostring(config.keybind.Name)
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
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, -20, 1, -20)
        page.Position = UDim2.new(0, 10, 0, 10)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 0
        page.Visible = false
        page.Parent = main_pages
        local tab_btn = Instance.new("TextButton")
        tab_btn.Size = UDim2.new(0, 160, 0, 36)
        tab_btn.BackgroundColor3 = theme.background
        tab_btn.BackgroundTransparency = 1
        tab_btn.Text = ""
        tab_btn.AutoButtonColor = false
        tab_btn.Parent = tab_container
        corner(tab_btn, 6)
        local title = Instance.new("TextLabel")
        title.Text = name
        title.Font = config.font_main
        title.TextSize = 14
        title.TextColor3 = theme.text_dark
        title.Size = UDim2.new(1, -20, 1, 0)
        title.Position = UDim2.new(0, icon_id and 35 or 15, 0, 0)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.BackgroundTransparency = 1
        title.Parent = tab_btn
        if icon_id then
            local ico = Instance.new("ImageLabel")
            ico.Size = UDim2.new(0, 20, 0, 20)
            ico.Position = UDim2.new(0, 8, 0.5, 0)
            ico.AnchorPoint = Vector2.new(0, 0.5)
            ico.BackgroundTransparency = 1
            if tonumber(icon_id) then
                ico.Image = "rbxassetid://" .. icon_id
            else
                ico.Image = icon_id
            end
            ico.ImageColor3 = theme.text_dark
            ico.Parent = tab_btn
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
        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 3, 0, 16)
        indicator.Position = UDim2.new(0, 0, 0.5, -8)
        indicator.BackgroundColor3 = theme.accent
        indicator.BackgroundTransparency = 1
        indicator.BorderSizePixel = 0
        indicator.Parent = tab_btn
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
        function tab:section(text_str, side)
            local section = {}
            local parent_col = (side == "Right" and right_col or left_col)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, 0, 0, 0)
            container.BackgroundColor3 = theme.section
            container.Parent = parent_col
            corner(container, 6)
            stroke(container, theme.stroke, 1, 0.5)
            local title_lbl = Instance.new("TextLabel")
            title_lbl.Text = text_str
            title_lbl.Font = config.font_bold
            title_lbl.TextSize = 12
            title_lbl.TextColor3 = theme.text_dark
            title_lbl.Size = UDim2.new(1, -20, 0, 25)
            title_lbl.Position = UDim2.new(0, 10, 0, 0)
            title_lbl.BackgroundTransparency = 1
            title_lbl.TextXAlignment = Enum.TextXAlignment.Left
            title_lbl.TextTruncate = Enum.TextTruncate.AtEnd
            title_lbl.Parent = container
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
            list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update_size)
            function section:toggle(text_str, flag, default, callback)
                local toggled = default or false
                library.flags[flag] = toggled
                local toggle_obj = {}
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 32)
                btn.BackgroundTransparency = 1
                btn.Text = ""
                btn.Parent = content
                local label = Instance.new("TextLabel")
                label.Text = text_str
                label.Font = config.font_main
                label.TextSize = 13
                label.TextColor3 = theme.text
                label.Size = UDim2.new(0.65, 0, 1, 0)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextTruncate = Enum.TextTruncate.AtEnd
                label.BackgroundTransparency = 1
                label.Parent = btn
                local box = Instance.new("Frame")
                box.Size = UDim2.new(0, 18, 0, 18)
                box.Position = UDim2.new(1, -5, 0.5, 0)
                box.AnchorPoint = Vector2.new(1, 0.5)
                box.BackgroundColor3 = theme.background
                box.Parent = btn
                corner(box, 4)
                stroke(box, theme.stroke, 1, 0.5)
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new(1, -4, 1, -4)
                fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                fill.AnchorPoint = Vector2.new(0.5, 0.5)
                fill.BackgroundColor3 = theme.accent
                fill.BackgroundTransparency = 1
                fill.Parent = box
                corner(fill, 3)
                register_theme(fill, "background_color")
                local sub_container = Instance.new("Frame")
                sub_container.Name = "sub_" .. text_str
                sub_container.Size = UDim2.new(1, 0, 0, 0)
                sub_container.BackgroundTransparency = 1
                sub_container.ClipsDescendants = true
                sub_container.Visible = false
                sub_container.Parent = content
                local sub_list = Instance.new("UIListLayout")
                sub_list.Padding = UDim.new(0, 6)
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
                        if h > 0 then h = h + 6 end
                        tween(sub_container, {Size = UDim2.new(1, 0, 0, h)}, 0.3)
                    else
                        tween(sub_container, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
                        task.delay(0.3, function() if not toggled then sub_container.Visible = false end end)
                    end
                end
                sub_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if toggled then
                        local h = sub_list.AbsoluteContentSize.Y
                        if h > 0 then h = h + 6 end
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
                    local s_btn = Instance.new("TextButton")
                    s_btn.Size = UDim2.new(1, -20, 0, 26)
                    s_btn.Position = UDim2.new(0, 20, 0, 0)
                    s_btn.BackgroundColor3 = theme.container
                    s_btn.Text = txt
                    s_btn.Font = config.font_main
                    s_btn.TextSize = 12
                    s_btn.TextColor3 = theme.text
                    s_btn.TextTruncate = Enum.TextTruncate.AtEnd
                    s_btn.AutoButtonColor = false
                    s_btn.Parent = sub_container
                    corner(s_btn, 4)
                    local s = stroke(s_btn, theme.stroke, 1, 0.5)
                    s_btn.MouseEnter:Connect(function() tween(s_btn, {BackgroundColor3 = theme.stroke}) tween(s, {Color = theme.accent}) end)
                    s_btn.MouseLeave:Connect(function() tween(s_btn, {BackgroundColor3 = theme.container}) tween(s, {Color = theme.stroke}) end)
                    s_btn.MouseButton1Click:Connect(cb)
                end
                function toggle_obj:add_slider(txt, min, max, def, cb)
                    local s_frame = Instance.new("Frame")
                    s_frame.Size = UDim2.new(1, -20, 0, 36)
                    s_frame.BackgroundTransparency = 1
                    s_frame.Parent = sub_container
                    local s_label = Instance.new("TextLabel")
                    s_label.Text = txt
                    s_label.Font = config.font_main
                    s_label.TextSize = 12
                    s_label.TextColor3 = theme.text_dark
                    s_label.Size = UDim2.new(1, 0, 0, 16)
                    s_label.TextXAlignment = Enum.TextXAlignment.Left
                    s_label.TextTruncate = Enum.TextTruncate.AtEnd
                    s_label.BackgroundTransparency = 1
                    s_label.Parent = s_frame
                    local s_value = Instance.new("TextLabel")
                    s_value.Text = tostring(def)
                    s_value.Font = config.font_main
                    s_value.TextSize = 12
                    s_value.TextColor3 = theme.text
                    s_value.Size = UDim2.new(1, 0, 0, 16)
                    s_value.TextXAlignment = Enum.TextXAlignment.Right
                    s_value.BackgroundTransparency = 1
                    s_value.Parent = s_frame
                    local slide_bg = Instance.new("Frame")
                    slide_bg.Size = UDim2.new(1, 0, 0, 6)
                    slide_bg.Position = UDim2.new(0, 0, 0, 22)
                    slide_bg.BackgroundColor3 = theme.background
                    slide_bg.Parent = s_frame
                    corner(slide_bg, 3)
                    local slide_fill = Instance.new("Frame")
                    slide_fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
                    slide_fill.BackgroundColor3 = theme.accent
                    slide_fill.BorderSizePixel = 0
                    slide_fill.Parent = slide_bg
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
                    key_btn.Parent = btn
                    key_btn.MouseButton1Click:Connect(function()
                        key_btn.Text = "[...]"
                        key_btn.TextColor3 = theme.accent
                        local input = user_input_service.InputBegan:Wait()
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            toggle_obj.keybind_value = input.KeyCode
                        end
                        key_btn.Text = "[" .. (toggle_obj.keybind_value.Name) .. "]"
                        key_btn.TextColor3 = theme.text_dark
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
                local btn = Instance.new("TextButton")
                btn.Size = UDim2.new(1, 0, 0, 30)
                btn.BackgroundColor3 = theme.container
                btn.Text = text_str
                btn.Font = config.font_main
                btn.TextSize = 13
                btn.TextColor3 = theme.text
                btn.TextTruncate = Enum.TextTruncate.AtEnd
                btn.AutoButtonColor = false
                btn.Parent = content
                corner(btn, 4)
                local s = stroke(btn, theme.stroke, 1, 0.5)
                btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = theme.stroke}) tween(s, {Color = theme.accent}) end)
                btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = theme.container}) tween(s, {Color = theme.stroke}) end)
                register_theme(s, "border_color")
                btn.MouseButton1Click:Connect(callback)
            end
            function section:slider(text_str, min, max, default, callback)
                local val = default or min
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 42)
                frame.BackgroundTransparency = 1
                frame.Parent = content
                local label = Instance.new("TextLabel")
                label.Text = text_str
                label.Font = config.font_main
                label.TextSize = 13
                label.TextColor3 = theme.text
                label.Size = UDim2.new(0.6, 0, 0, 16)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextTruncate = Enum.TextTruncate.AtEnd
                label.BackgroundTransparency = 1
                label.Parent = frame
                local val_label = Instance.new("TextLabel")
                val_label.Text = tostring(val)
                val_label.Font = config.font_main
                val_label.TextSize = 13
                val_label.TextColor3 = theme.text
                val_label.Size = UDim2.new(0.4, -5, 0, 16)
                val_label.Position = UDim2.new(0.6, 0, 0, 0)
                val_label.TextXAlignment = Enum.TextXAlignment.Right
                val_label.BackgroundTransparency = 1
                val_label.Parent = frame
                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(1, 0, 0, 6)
                bar.Position = UDim2.new(0, 0, 0, 24)
                bar.BackgroundColor3 = theme.container
                bar.Parent = frame
                corner(bar, 3)
                stroke(bar, theme.stroke, 1, 0.5)
                local fill = Instance.new("Frame")
                fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                fill.BackgroundColor3 = theme.accent
                fill.BorderSizePixel = 0
                fill.Parent = bar
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
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 46)
                frame.BackgroundTransparency = 1
                frame.Parent = content
                local label = Instance.new("TextLabel")
                label.Text = text_str
                label.Font = config.font_main
                label.TextSize = 13
                label.TextColor3 = theme.text
                label.Size = UDim2.new(1, 0, 0, 16)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextTruncate = Enum.TextTruncate.AtEnd
                label.BackgroundTransparency = 1
                label.Parent = frame
                local box_cont = Instance.new("Frame")
                box_cont.Size = UDim2.new(1, 0, 0, 26)
                box_cont.Position = UDim2.new(0, 0, 0, 20)
                box_cont.BackgroundColor3 = theme.container
                box_cont.Parent = frame
                corner(box_cont, 4)
                local s = stroke(box_cont, theme.stroke, 1, 0.5)
                local input = Instance.new("TextBox")
                input.Size = UDim2.new(1, -10, 1, 0)
                input.Position = UDim2.new(0, 5, 0, 0)
                input.BackgroundTransparency = 1
                input.TextColor3 = theme.text
                input.PlaceholderText = placeholder or "Type here..."
                input.PlaceholderColor3 = theme.text_dark
                input.Font = config.font_main
                input.TextSize = 13
                input.TextXAlignment = Enum.TextXAlignment.Left
                input.Text = ""
                input.Parent = box_cont
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
                local drop_frame = Instance.new("Frame")
                drop_frame.Size = UDim2.new(1, custom_parent and -20 or 0, 0, 46)
                if custom_parent then drop_frame.Position = UDim2.new(0, 20, 0, 0) end
                drop_frame.BackgroundTransparency = 1
                drop_frame.Parent = parent
                drop_frame.ZIndex = 5
                local label = Instance.new("TextLabel")
                label.Text = text_str
                label.Font = config.font_main
                label.TextSize = 13
                label.TextColor3 = custom_parent and theme.text_dark or theme.text
                label.Size = UDim2.new(1, 0, 0, 16)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextTruncate = Enum.TextTruncate.AtEnd
                label.BackgroundTransparency = 1
                label.Parent = drop_frame
                local interactive = Instance.new("TextButton")
                interactive.Size = UDim2.new(1, 0, 0, 26)
                interactive.Position = UDim2.new(0, 0, 0, 20)
                interactive.BackgroundColor3 = theme.container
                interactive.Text = ""
                interactive.AutoButtonColor = false
                interactive.Parent = drop_frame
                interactive.ZIndex = 5
                corner(interactive, 4)
                stroke(interactive, theme.stroke, 1, 0.5)
                local selected_text = Instance.new("TextLabel")
                selected_text.Text = selected
                selected_text.Font = config.font_main
                selected_text.TextSize = 13
                selected_text.TextColor3 = theme.text
                selected_text.Size = UDim2.new(1, -25, 1, 0)
                selected_text.Position = UDim2.new(0, 8, 0, 0)
                selected_text.TextXAlignment = Enum.TextXAlignment.Left
                selected_text.TextTruncate = Enum.TextTruncate.AtEnd
                selected_text.BackgroundTransparency = 1
                selected_text.ZIndex = 6
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
                list_frame.ZIndex = 10
                list_frame.Visible = false
                list_frame.ScrollBarThickness = 2
                list_frame.ScrollBarImageColor3 = theme.accent
                corner(list_frame, 4)
                stroke(list_frame, theme.stroke, 1, 0.5)
                local i_list = Instance.new("UIListLayout")
                i_list.SortOrder = Enum.SortOrder.LayoutOrder
                i_list.Parent = list_frame
                i_list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    list_frame.CanvasSize = UDim2.new(0, 0, 0, i_list.AbsoluteContentSize.Y)
                end)
                for _, opt in ipairs(options) do
                    local opt_btn = Instance.new("TextButton")
                    opt_btn.Size = UDim2.new(1, 0, 0, 24)
                    opt_btn.BackgroundColor3 = theme.container
                    opt_btn.BackgroundTransparency = 1
                    opt_btn.Text = opt
                    opt_btn.TextColor3 = theme.text_dark
                    opt_btn.Font = config.font_main
                    opt_btn.TextSize = 12
                    opt_btn.TextTruncate = Enum.TextTruncate.AtEnd
                    opt_btn.Parent = list_frame
                    opt_btn.ZIndex = 11
                    opt_btn.MouseEnter:Connect(function() tween(opt_btn, {BackgroundTransparency = 0.8, TextColor3 = theme.accent}) end)
                    opt_btn.MouseLeave:Connect(function() tween(opt_btn, {BackgroundTransparency = 1, TextColor3 = theme.text_dark}) end)
                    register_theme(opt_btn, "text_color")
                    opt_btn.MouseButton1Click:Connect(function()
                        selected = opt
                        selected_text.Text = selected
                        callback(selected)
                        is_dropped = false
                        tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, 46)}, 0.2)
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
                        local list_h = math.min(#options * 24, 200)
                        local total_h = 46 + list_h + 5
                        tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, total_h)}, 0.2)
                        tween(list_frame, {Size = UDim2.new(1, 0, 0, list_h)}, 0.2)
                        tween(arrow, {Rotation = 180}, 0.2)
                    else
                        tween(drop_frame, {Size = UDim2.new(1, custom_parent and -20 or 0, 0, 46)}, 0.2)
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
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(1, 0, 0, 30)
                frame.BackgroundTransparency = 1
                frame.Parent = content
                frame.ZIndex = 5
                local label = Instance.new("TextLabel")
                label.Text = text_str
                label.Font = config.font_main
                label.TextSize = 13
                label.TextColor3 = theme.text
                label.Size = UDim2.new(0.6, 0, 1, 0)
                label.Position = UDim2.new(0, 5, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextTruncate = Enum.TextTruncate.AtEnd
                label.BackgroundTransparency = 1
                label.Parent = frame
                local preview = Instance.new("TextButton")
                preview.Size = UDim2.new(0, 40, 0, 20)
                preview.Position = UDim2.new(1, -5, 0.5, 0)
                preview.AnchorPoint = Vector2.new(1, 0.5)
                preview.BackgroundColor3 = color
                preview.AutoButtonColor = false
                preview.Text = ""
                preview.Parent = frame
                corner(preview, 4)
                stroke(preview, theme.stroke, 1, 0.5)
                local picker_cont = Instance.new("Frame")
                picker_cont.Size = UDim2.new(1, 0, 0, 0)
                picker_cont.BackgroundColor3 = theme.background
                picker_cont.Parent = content
                picker_cont.ClipsDescendants = true
                picker_cont.ZIndex = 10
                corner(picker_cont, 4)
                local sv_map = Instance.new("ImageLabel")
                sv_map.Size = UDim2.new(0, 140, 0, 120)
                sv_map.Position = UDim2.new(0, 10, 0, 10)
                sv_map.Image = "rbxassetid://4155801252"
                sv_map.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                sv_map.Parent = picker_cont
                sv_map.ZIndex = 11
                corner(sv_map, 4)
                local sv_cursor = Instance.new("Frame")
                sv_cursor.Size = UDim2.new(0, 8, 0, 8)
                sv_cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                sv_cursor.BackgroundColor3 = Color3.new(1,1,1)
                sv_cursor.Parent = sv_map
                sv_cursor.Position = UDim2.new(s_val, 0, 1-v, 0)
                sv_cursor.ZIndex = 12
                corner(sv_cursor, 4)
                local hue_bar = Instance.new("ImageLabel")
                hue_bar.Size = UDim2.new(0, 20, 0, 120)
                hue_bar.Position = UDim2.new(0, 160, 0, 10)
                hue_bar.Image = "rbxassetid://4155801252"
                hue_bar.Parent = picker_cont
                hue_bar.ZIndex = 11
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
                local h_cursor = Instance.new("Frame")
                h_cursor.Size = UDim2.new(1, 0, 0, 2)
                h_cursor.BackgroundColor3 = Color3.new(1,1,1)
                h_cursor.Parent = hue_bar
                h_cursor.Position = UDim2.new(0, 0, h, 0)
                h_cursor.ZIndex = 12
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
