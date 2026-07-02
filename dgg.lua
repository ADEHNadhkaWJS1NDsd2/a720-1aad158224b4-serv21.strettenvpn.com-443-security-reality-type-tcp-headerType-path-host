local core_gui_service = game:GetService("CoreGui")
local user_input_service = game:GetService("UserInputService")
local run_service = game:GetService("RunService")
local tween_service = game:GetService("TweenService")
local text_service = game:GetService("TextService")
local http_service = game:GetService("HttpService")
local workspace_service = game:GetService("Workspace")
local players_service = game:GetService("Players")

local Library_Api = {
    Flags = {},
    Folder_Name = "RadiantConfigs",
    Selected_Config = ""
}

local Colors_Table = {
    main_background = Color3.fromRGB(15, 20, 15),
    sidebar_background = Color3.fromRGB(18, 25, 18),
    section_background = Color3.fromRGB(22, 30, 22),
    element_background = Color3.fromRGB(25, 35, 25),
    element_hover_background = Color3.fromRGB(30, 45, 30),
    border_color = Color3.fromRGB(35, 50, 35),
    border_light_color = Color3.fromRGB(50, 75, 50),
    accent_color = Color3.fromRGB(65, 255, 115),
    accent_gradient_1 = Color3.fromRGB(65, 255, 115),
    accent_gradient_2 = Color3.fromRGB(40, 200, 90),
    text_white_color = Color3.fromRGB(240, 255, 240),
    text_dark_color = Color3.fromRGB(140, 170, 140),
    tooltip_background = Color3.fromRGB(12, 16, 12),
    notification_info = Color3.fromRGB(65, 180, 255),
    notification_success = Color3.fromRGB(65, 255, 115),
    notification_warning = Color3.fromRGB(255, 200, 65),
    notification_error = Color3.fromRGB(255, 65, 65)
}

local Preset_Themes = {
    ["Radiant Green"] = {
        main_background = Color3.fromRGB(15, 20, 15),
        sidebar_background = Color3.fromRGB(18, 25, 18),
        section_background = Color3.fromRGB(22, 30, 22),
        element_background = Color3.fromRGB(25, 35, 25),
        element_hover_background = Color3.fromRGB(30, 45, 30),
        border_color = Color3.fromRGB(35, 50, 35),
        border_light_color = Color3.fromRGB(50, 75, 50),
        accent_color = Color3.fromRGB(65, 255, 115),
        accent_gradient_1 = Color3.fromRGB(65, 255, 115),
        accent_gradient_2 = Color3.fromRGB(40, 200, 90),
        text_white_color = Color3.fromRGB(240, 255, 240),
        text_dark_color = Color3.fromRGB(140, 170, 140)
    },
    ["Dark Night"] = {
        main_background = Color3.fromRGB(15, 15, 25),
        sidebar_background = Color3.fromRGB(18, 18, 30),
        section_background = Color3.fromRGB(22, 22, 35),
        element_background = Color3.fromRGB(25, 25, 40),
        element_hover_background = Color3.fromRGB(35, 35, 55),
        border_color = Color3.fromRGB(35, 35, 50),
        border_light_color = Color3.fromRGB(50, 50, 75),
        accent_color = Color3.fromRGB(100, 130, 255),
        accent_gradient_1 = Color3.fromRGB(100, 130, 255),
        accent_gradient_2 = Color3.fromRGB(70, 90, 200),
        text_white_color = Color3.fromRGB(240, 240, 255),
        text_dark_color = Color3.fromRGB(140, 140, 170)
    },
    ["Blood Red"] = {
        main_background = Color3.fromRGB(25, 15, 15),
        sidebar_background = Color3.fromRGB(30, 18, 18),
        section_background = Color3.fromRGB(35, 22, 22),
        element_background = Color3.fromRGB(40, 25, 25),
        element_hover_background = Color3.fromRGB(55, 30, 30),
        border_color = Color3.fromRGB(50, 30, 30),
        border_light_color = Color3.fromRGB(75, 40, 40),
        accent_color = Color3.fromRGB(255, 65, 65),
        accent_gradient_1 = Color3.fromRGB(255, 65, 65),
        accent_gradient_2 = Color3.fromRGB(200, 40, 40),
        text_white_color = Color3.fromRGB(255, 240, 240),
        text_dark_color = Color3.fromRGB(170, 140, 140)
    }
}

local Theme_Registry = {}

local function Set_Color(Obj, Prop, Role)
    table.insert(Theme_Registry, {O = Obj, P = Prop, R = Role})
    Obj[Prop] = Colors_Table[Role]
end

local function Set_Gradient(Obj, Role1, Role2)
    table.insert(Theme_Registry, {O = Obj, P = "Color", R1 = Role1, R2 = Role2})
    Obj.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors_Table[Role1]),
        ColorSequenceKeypoint.new(1, Colors_Table[Role2])
    }
end

local function Update_Theme()
    for _, Entry in ipairs(Theme_Registry) do
        if Entry.O and Entry.O.Parent then
            if Entry.P == "Color" and Entry.R1 and Entry.R2 then
                Entry.O.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Colors_Table[Entry.R1]),
                    ColorSequenceKeypoint.new(1, Colors_Table[Entry.R2])
                }
            else
                Entry.O[Entry.P] = Colors_Table[Entry.R]
            end
        end
    end
end

local main_font = Enum.Font.GothamMedium
local bold_font = Enum.Font.GothamBold

local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = http_service:GenerateGUID(false)
screen_gui.Parent = core_gui_service
screen_gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen_gui.DisplayOrder = 999
screen_gui.IgnoreGuiInset = true

local tooltip_frame = Instance.new("Frame")
Set_Color(tooltip_frame, "BackgroundColor3", "tooltip_background")
tooltip_frame.BackgroundTransparency = 0.158372
tooltip_frame.Size = UDim2.new(0, 0, 0, 24)
tooltip_frame.ZIndex = 2000
tooltip_frame.Visible = false
tooltip_frame.Parent = screen_gui

local tooltip_corner = Instance.new("UICorner")
tooltip_corner.CornerRadius = UDim.new(0, 4)
tooltip_corner.Parent = tooltip_frame

local tooltip_stroke = Instance.new("UIStroke")
Set_Color(tooltip_stroke, "Color", "border_light_color")
tooltip_stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tooltip_stroke.Transparency = 1
tooltip_stroke.Parent = tooltip_frame

local tooltip_text = Instance.new("TextLabel")
tooltip_text.Size = UDim2.new(1, -16, 1, 0)
tooltip_text.Position = UDim2.new(0, 8, 0, 0)
tooltip_text.BackgroundTransparency = 1
Set_Color(tooltip_text, "TextColor3", "text_white_color")
tooltip_text.TextTransparency = 1
tooltip_text.TextSize = 12
tooltip_text.Font = main_font
tooltip_text.TextXAlignment = Enum.TextXAlignment.Left
tooltip_text.ZIndex = 2001
tooltip_text.Parent = tooltip_frame

local notification_container = Instance.new("Frame")
notification_container.Size = UDim2.new(0, 300, 1, -40)
notification_container.Position = UDim2.new(1, -320, 0, 20)
notification_container.BackgroundTransparency = 1
notification_container.ZIndex = 1500
notification_container.Parent = screen_gui

local notification_layout = Instance.new("UIListLayout")
notification_layout.SortOrder = Enum.SortOrder.LayoutOrder
notification_layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notification_layout.Padding = UDim.new(0, 10)
notification_layout.Parent = notification_container

local tooltip_target_text = ""

local function Animate_Element(Element, Properties, Speed)
    local Tween = tween_service:Create(Element, TweenInfo.new(Speed or 0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), Properties)
    Tween:Play()
    return Tween
end

local function Apply_Acrylic_Effect(Parent, Transparency, Corner_Radius)
    local Blur_Image = Instance.new("ImageLabel")
    Blur_Image.Size = UDim2.new(1, 0, 1, 0)
    Blur_Image.BackgroundTransparency = 1
    Blur_Image.Image = "rbxassetid://8992230113"
    Blur_Image.TileSize = UDim2.new(0, 256, 0, 256)
    Blur_Image.ScaleType = Enum.ScaleType.Tile
    Blur_Image.ImageTransparency = Transparency or 0.88732
    Blur_Image.ZIndex = Parent.ZIndex - 1
    Blur_Image.Parent = Parent
    if Corner_Radius then
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = Corner_Radius
        Corner.Parent = Blur_Image
    end
    return Blur_Image
end

local function Show_Tooltip(Text_String)
    if not Text_String or Text_String == "" then
        tooltip_target_text = ""
        return
    end
    local Text_Bounds = text_service:GetTextSize(Text_String, 12, main_font, Vector2.new(500, 24))
    tooltip_frame.Size = UDim2.new(0, Text_Bounds.X + 16, 0, 24)
    tooltip_text.Text = Text_String
    tooltip_target_text = Text_String
end

local function Snap_Value(Value, Step)
    if not Step then return Value end
    return math.floor((Value / Step) + 0.5) * Step
end

local function Format_Value(Value, Step)
    if Step and Step < 1 then
        local Decimal_Places = tostring(Step):len() - 2
        return string.format("%."..Decimal_Places.."f", Value)
    end
    return tostring(Value)
end

local function Get_Config_List()
    local Config_List = {}
    if isfolder and isfolder(Library_Api.Folder_Name) then
        if listfiles then
            for _, File_Path in ipairs(listfiles(Library_Api.Folder_Name)) do
                local File_Name = File_Path:match("([^/\\]+)%.json$")
                if File_Name then table.insert(Config_List, File_Name) end
            end
        end
    end
    return Config_List
end

local function Save_Configuration(File_Name)
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(Library_Api.Folder_Name) then makefolder(Library_Api.Folder_Name) end
        local Serialized_Data = {}
        for Key, Val in pairs(Library_Api.Flags) do
            if typeof(Val) == "Color3" then
                Serialized_Data[Key] = {Type = "Color3", R = Val.R, G = Val.G, B = Val.B}
            elseif typeof(Val) == "EnumItem" then
                Serialized_Data[Key] = {Type = "KeyCode", Name = Val.Name}
            elseif type(Val) == "table" and Val.Min and Val.Max then
                Serialized_Data[Key] = {Type = "Range", Min = Val.Min, Max = Val.Max}
            else
                Serialized_Data[Key] = Val
            end
        end
        writefile(Library_Api.Folder_Name .. "/" .. File_Name .. ".json", http_service:JSONEncode(Serialized_Data))
    end)
end

local function Load_Configuration(File_Name)
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local Full_Path = Library_Api.Folder_Name .. "/" .. File_Name .. ".json"
        if isfile(Full_Path) then
            local Decoded_Data = http_service:JSONDecode(readfile(Full_Path))
            if type(Decoded_Data) == "table" then
                for Key, Val in pairs(Decoded_Data) do
                    if type(Val) == "table" then
                        if Val.Type == "Color3" then
                            Library_Api.Flags[Key] = Color3.new(Val.R, Val.G, Val.B)
                        elseif Val.Type == "KeyCode" then
                            Library_Api.Flags[Key] = Enum.KeyCode[Val.Name] or Enum.KeyCode.Unknown
                        elseif Val.Type == "Range" then
                            Library_Api.Flags[Key] = {Min = Val.Min, Max = Val.Max}
                        end
                    else
                        Library_Api.Flags[Key] = Val
                    end
                end
            end
        end
    end)
end

run_service.RenderStepped:Connect(function()
    if tooltip_target_text ~= "" then
        local Mouse_Location = user_input_service:GetMouseLocation()
        tooltip_frame.Position = UDim2.new(0, Mouse_Location.X + 15, 0, Mouse_Location.Y + 15)
        if not tooltip_frame.Visible then
            tooltip_frame.Visible = true
            Animate_Element(tooltip_frame, {BackgroundTransparency = 0.1837265}, 0.25)
            Animate_Element(tooltip_stroke, {Transparency = 0}, 0.25)
            Animate_Element(tooltip_text, {TextTransparency = 0}, 0.25)
        end
    else
        Animate_Element(tooltip_frame, {BackgroundTransparency = 1}, 0.15)
        Animate_Element(tooltip_stroke, {Transparency = 1}, 0.15)
        Animate_Element(tooltip_text, {TextTransparency = 1}, 0.15)
        task.delay(0.15, function()
            if tooltip_target_text == "" then tooltip_frame.Visible = false end
        end)
    end
end)

function Library_Api:Notify(Config)
    local Title = Config.Title or "Notification"
    local Text = Config.Text or ""
    local Duration = Config.Duration or 3
    local Notification_Type = Config.Type or "info"
    
    local Notification_Frame = Instance.new("Frame")
    Notification_Frame.Size = UDim2.new(1, 0, 0, 60)
    Notification_Frame.Position = UDim2.new(1, 320, 0, 0)
    Set_Color(Notification_Frame, "BackgroundColor3", "main_background")
    Notification_Frame.BackgroundTransparency = 0.28547
    Notification_Frame.ZIndex = 1501
    Notification_Frame.Parent = notification_container

    local Notification_Corner = Instance.new("UICorner")
    Notification_Corner.CornerRadius = UDim.new(0, 6)
    Notification_Corner.Parent = Notification_Frame

    local Notification_Stroke = Instance.new("UIStroke")
    Set_Color(Notification_Stroke, "Color", "border_light_color")
    Notification_Stroke.Parent = Notification_Frame

    Apply_Acrylic_Effect(Notification_Frame, 0.91238, UDim.new(0, 6))

    local Line_Frame = Instance.new("Frame")
    Line_Frame.Size = UDim2.new(0, 3, 1, -12)
    Line_Frame.Position = UDim2.new(0, 6, 0, 6)
    Set_Color(Line_Frame, "BackgroundColor3", "notification_" .. string.lower(Notification_Type))
    Line_Frame.BorderSizePixel = 0
    Line_Frame.ZIndex = 1502
    Line_Frame.Parent = Notification_Frame

    local Line_Corner = Instance.new("UICorner")
    Line_Corner.CornerRadius = UDim.new(0, 3)
    Line_Corner.Parent = Line_Frame

    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -24, 0, 16)
    Title_Label.Position = UDim2.new(0, 16, 0, 8)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Title
    Set_Color(Title_Label, "TextColor3", "text_white_color")
    Title_Label.TextSize = 13
    Title_Label.Font = bold_font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.ZIndex = 1502
    Title_Label.Parent = Notification_Frame

    local Text_Label = Instance.new("TextLabel")
    Text_Label.Size = UDim2.new(1, -24, 0, 24)
    Text_Label.Position = UDim2.new(0, 16, 0, 26)
    Text_Label.BackgroundTransparency = 1
    Text_Label.Text = Text
    Set_Color(Text_Label, "TextColor3", "text_dark_color")
    Text_Label.TextSize = 12
    Text_Label.Font = main_font
    Text_Label.TextXAlignment = Enum.TextXAlignment.Left
    Text_Label.TextWrapped = true
    Text_Label.ZIndex = 1502
    Text_Label.Parent = Notification_Frame

    Animate_Element(Notification_Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.45)

    task.delay(Duration, function()
        local Hide_Tween = Animate_Element(Notification_Frame, {Position = UDim2.new(1, 320, 0, 0)}, 0.45)
        Hide_Tween.Completed:Connect(function() Notification_Frame:Destroy() end)
    end)
end

function Library_Api:Create_Window(Window_Name)
    local Main_Background = Instance.new("Frame")
    Main_Background.Size = UDim2.new(0, 720, 0, 480)
    Main_Background.Position = UDim2.new(0.5, -360, 0.5, -240)
    Set_Color(Main_Background, "BackgroundColor3", "main_background")
    Main_Background.BackgroundTransparency = 0.18374
    Main_Background.BorderSizePixel = 0
    Main_Background.Active = true
    Main_Background.Parent = screen_gui

    local Ui_Scale_Modifier = Instance.new("UIScale")
    Ui_Scale_Modifier.Parent = Main_Background
    
    local Main_Corner = Instance.new("UICorner")
    Main_Corner.CornerRadius = UDim.new(0, 6)
    Main_Corner.Parent = Main_Background
    
    local Main_Stroke = Instance.new("UIStroke")
    Set_Color(Main_Stroke, "Color", "border_color")
    Main_Stroke.Parent = Main_Background

    Apply_Acrylic_Effect(Main_Background, 0.88741, UDim.new(0, 6))

    local Top_Bar = Instance.new("Frame")
    Top_Bar.Size = UDim2.new(1, 0, 0, 36)
    Set_Color(Top_Bar, "BackgroundColor3", "sidebar_background")
    Top_Bar.BackgroundTransparency = 0.21847
    Top_Bar.BorderSizePixel = 0
    Top_Bar.Parent = Main_Background
    
    local Top_Corner = Instance.new("UICorner")
    Top_Corner.CornerRadius = UDim.new(0, 6)
    Top_Corner.Parent = Top_Bar

    local Top_Hider = Instance.new("Frame")
    Top_Hider.Size = UDim2.new(1, 0, 0, 6)
    Top_Hider.Position = UDim2.new(0, 0, 1, -6)
    Set_Color(Top_Hider, "BackgroundColor3", "sidebar_background")
    Top_Hider.BackgroundTransparency = 0.21847
    Top_Hider.BorderSizePixel = 0
    Top_Hider.Parent = Top_Bar

    local Accent_Line = Instance.new("Frame")
    Accent_Line.Size = UDim2.new(1, 0, 0, 2)
    Accent_Line.BackgroundColor3 = Color3.new(1, 1, 1)
    Accent_Line.BorderSizePixel = 0
    Accent_Line.Parent = Top_Bar
    
    local Accent_Corner = Instance.new("UICorner")
    Accent_Corner.CornerRadius = UDim.new(0, 6)
    Accent_Corner.Parent = Accent_Line

    local Accent_Gradient = Instance.new("UIGradient")
    Set_Gradient(Accent_Gradient, "accent_gradient_1", "accent_gradient_2")
    Accent_Gradient.Parent = Accent_Line

    local Top_Border = Instance.new("Frame")
    Top_Border.Size = UDim2.new(1, 0, 0, 1)
    Top_Border.Position = UDim2.new(0, 0, 1, 0)
    Set_Color(Top_Border, "BackgroundColor3", "border_color")
    Top_Border.BorderSizePixel = 0
    Top_Border.Parent = Top_Bar

    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -20, 1, -2)
    Title_Label.Position = UDim2.new(0, 15, 0, 2)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Window_Name
    Set_Color(Title_Label, "TextColor3", "text_white_color")
    Title_Label.TextSize = 13
    Title_Label.Font = bold_font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.Parent = Top_Bar

    local Sidebar_Frame = Instance.new("Frame")
    Sidebar_Frame.Size = UDim2.new(0, 150, 1, -37)
    Sidebar_Frame.Position = UDim2.new(0, 0, 0, 37)
    Set_Color(Sidebar_Frame, "BackgroundColor3", "sidebar_background")
    Sidebar_Frame.BackgroundTransparency = 0.21847
    Sidebar_Frame.BorderSizePixel = 0
    Sidebar_Frame.Parent = Main_Background
    
    local Sidebar_Corner = Instance.new("UICorner")
    Sidebar_Corner.CornerRadius = UDim.new(0, 6)
    Sidebar_Corner.Parent = Sidebar_Frame

    local Sidebar_Hider_Right = Instance.new("Frame")
    Sidebar_Hider_Right.Size = UDim2.new(0, 6, 1, 0)
    Sidebar_Hider_Right.Position = UDim2.new(1, -6, 0, 0)
    Set_Color(Sidebar_Hider_Right, "BackgroundColor3", "sidebar_background")
    Sidebar_Hider_Right.BackgroundTransparency = 0.21847
    Sidebar_Hider_Right.BorderSizePixel = 0
    Sidebar_Hider_Right.Parent = Sidebar_Frame

    local Sidebar_Hider_Top = Instance.new("Frame")
    Sidebar_Hider_Top.Size = UDim2.new(1, 0, 0, 6)
    Set_Color(Sidebar_Hider_Top, "BackgroundColor3", "sidebar_background")
    Sidebar_Hider_Top.BackgroundTransparency = 0.21847
    Sidebar_Hider_Top.BorderSizePixel = 0
    Sidebar_Hider_Top.Parent = Sidebar_Frame

    local Sidebar_Border = Instance.new("Frame")
    Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
    Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
    Set_Color(Sidebar_Border, "BackgroundColor3", "border_color")
    Sidebar_Border.BorderSizePixel = 0
    Sidebar_Border.Parent = Sidebar_Frame

    local Tab_Scrolling_Frame = Instance.new("ScrollingFrame")
    Tab_Scrolling_Frame.Size = UDim2.new(1, -10, 1, -10)
    Tab_Scrolling_Frame.Position = UDim2.new(0, 5, 0, 5)
    Tab_Scrolling_Frame.BackgroundTransparency = 1
    Tab_Scrolling_Frame.BorderSizePixel = 0
    Tab_Scrolling_Frame.ScrollBarThickness = 0
    Tab_Scrolling_Frame.Parent = Sidebar_Frame

    local Tab_Layout = Instance.new("UIListLayout")
    Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tab_Layout.Padding = UDim.new(0, 4)
    Tab_Layout.Parent = Tab_Scrolling_Frame

    local Content_Area_Frame = Instance.new("Frame")
    Content_Area_Frame.Size = UDim2.new(1, -151, 1, -37)
    Content_Area_Frame.Position = UDim2.new(0, 151, 0, 37)
    Content_Area_Frame.BackgroundTransparency = 1
    Content_Area_Frame.Parent = Main_Background

    local Mobile_Toggle_Button = Instance.new("ImageButton")
    Mobile_Toggle_Button.Size = UDim2.new(0, 50, 0, 50)
    Mobile_Toggle_Button.Position = UDim2.new(0, 20, 0.5, -25)
    Set_Color(Mobile_Toggle_Button, "BackgroundColor3", "main_background")
    Mobile_Toggle_Button.BorderSizePixel = 0
    Mobile_Toggle_Button.ZIndex = 1000
    Mobile_Toggle_Button.Visible = user_input_service.TouchEnabled
    Mobile_Toggle_Button.Parent = screen_gui
    
    local Success, Avatar_Image = pcall(function()
        return players_service:GetUserThumbnailAsync(players_service.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    Mobile_Toggle_Button.Image = Success and Avatar_Image or ""

    local Mobile_Toggle_Corner = Instance.new("UICorner")
    Mobile_Toggle_Corner.CornerRadius = UDim.new(1, 0)
    Mobile_Toggle_Corner.Parent = Mobile_Toggle_Button

    local Mobile_Toggle_Stroke = Instance.new("UIStroke")
    Set_Color(Mobile_Toggle_Stroke, "Color", "accent_color")
    Mobile_Toggle_Stroke.Thickness = 2
    Mobile_Toggle_Stroke.Parent = Mobile_Toggle_Button

    local Is_Toggle_Dragging = false
    local Toggle_Drag_Input = nil
    local Toggle_Drag_Start = nil
    local Toggle_Start_Pos = nil

    Mobile_Toggle_Button.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Is_Toggle_Dragging = true
            Toggle_Drag_Start = Input.Position
            Toggle_Start_Pos = Mobile_Toggle_Button.Position
        end
    end)

    Mobile_Toggle_Button.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            Toggle_Drag_Input = Input
        end
    end)

    user_input_service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Is_Toggle_Dragging = false
        end
    end)

    run_service.RenderStepped:Connect(function()
        if Is_Toggle_Dragging and Toggle_Drag_Input then
            local Delta = Toggle_Drag_Input.Position - Toggle_Drag_Start
            Mobile_Toggle_Button.Position = UDim2.new(Toggle_Start_Pos.X.Scale, Toggle_Start_Pos.X.Offset + Delta.X, Toggle_Start_Pos.Y.Scale, Toggle_Start_Pos.Y.Offset + Delta.Y)
        end
    end)

    local Toggle_Click_Time = 0
    Mobile_Toggle_Button.MouseButton1Down:Connect(function()
        Toggle_Click_Time = os.clock()
        Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 45, 0, 45)}, 0.25)
    end)
    
    Mobile_Toggle_Button.MouseButton1Up:Connect(function()
        Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 50, 0, 50)}, 0.25)
        if os.clock() - Toggle_Click_Time < 0.2 then
            Main_Background.Visible = not Main_Background.Visible
        end
    end)

    local function Update_Responsive_Scale()
        local Vp = workspace_service.CurrentCamera.ViewportSize
        if Vp.X < 1 or Vp.Y < 1 then 
            Ui_Scale_Modifier.Scale = 1
            return
        end
        local Scale_X = Vp.X / 800
        local Scale_Y = Vp.Y / 500
        local Scale = math.min(Scale_X, Scale_Y)
        if Scale < 1 then
            Ui_Scale_Modifier.Scale = math.clamp(Scale * 0.95, 0.4, 1)
        else
            Ui_Scale_Modifier.Scale = 1
        end
    end

    workspace_service.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Update_Responsive_Scale)
    Update_Responsive_Scale()

    local Is_Dragging = false
    local Drag_Input = nil
    local Drag_Start = nil
    local Start_Position = nil
    local Target_Position = Main_Background.Position

    Top_Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging = true
            Drag_Start = Input.Position
            Start_Position = Main_Background.Position
        end
    end)

    Top_Bar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then 
            Drag_Input = Input 
        end
    end)

    user_input_service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
            Is_Dragging = false 
        end
    end)

    run_service.RenderStepped:Connect(function()
        if Is_Dragging and Drag_Input then
            local Delta = Drag_Input.Position - Drag_Start
            Target_Position = UDim2.new(Start_Position.X.Scale, Start_Position.X.Offset + (Delta.X / Ui_Scale_Modifier.Scale), Start_Position.Y.Scale, Start_Position.Y.Offset + (Delta.Y / Ui_Scale_Modifier.Scale))
        end
        Main_Background.Position = Main_Background.Position:Lerp(Target_Position, 0.25)
    end)

    local Window_Context = { Tabs = {}, Active_Tab = nil }

    function Window_Context:Tab_Create(Tab_Name, Icon_Id, Is_Bottom)
        local Tab_Data = {}

        local Tab_Button = Instance.new("TextButton")
        Set_Color(Tab_Button, "BackgroundColor3", "element_hover_background")
        Tab_Button.BackgroundTransparency = 1
        Tab_Button.Text = ""
        Tab_Button.AutoButtonColor = false
        
        local Button_Corner = Instance.new("UICorner")
        Button_Corner.CornerRadius = UDim.new(0, 6)
        Button_Corner.Parent = Tab_Button

        local Tab_Label = Instance.new("TextLabel")
        Tab_Label.BackgroundTransparency = 1
        Set_Color(Tab_Label, "TextColor3", "text_dark_color")
        Tab_Label.TextSize = 12
        Tab_Label.Font = main_font
        Tab_Label.TextXAlignment = Enum.TextXAlignment.Left
        Tab_Label.Parent = Tab_Button

        if Is_Bottom then
            Tab_Button.Parent = Sidebar_Frame
            Tab_Button.Size = UDim2.new(1, -12, 0, 42)
            Tab_Button.Position = UDim2.new(0, 6, 1, -48)
            Tab_Scrolling_Frame.Size = UDim2.new(1, -10, 1, -56)
            
            local Tab_Icon = Instance.new("ImageLabel")
            Tab_Icon.Size = UDim2.new(0, 26, 0, 26)
            Tab_Icon.Position = UDim2.new(0, 10, 0.5, -13)
            Tab_Icon.BackgroundTransparency = 1
            Tab_Icon.Image = Success and Avatar_Image or ""
            Tab_Icon.ScaleType = Enum.ScaleType.Crop 
            Tab_Icon.Parent = Tab_Button
            
            local Icon_Corner = Instance.new("UICorner")
            Icon_Corner.CornerRadius = UDim.new(1, 0)
            Icon_Corner.Parent = Tab_Icon
            
            Tab_Label.Position = UDim2.new(0, 44, 0, 0)
            Tab_Label.Size = UDim2.new(1, -50, 1, 0)
            Tab_Label.Text = players_service.LocalPlayer.Name
            Tab_Label.Font = bold_font
        else
            Tab_Button.Parent = Tab_Scrolling_Frame
            Tab_Button.Size = UDim2.new(1, 0, 0, 32)
            Tab_Label.Text = Tab_Name
            if Icon_Id and Icon_Id ~= "" then
                local Tab_Icon = Instance.new("ImageLabel")
                Tab_Icon.Size = UDim2.new(0, 14, 0, 14)
                Tab_Icon.Position = UDim2.new(0, 12, 0.5, -7)
                Tab_Icon.BackgroundTransparency = 1
                Tab_Icon.Image = Icon_Id
                Set_Color(Tab_Icon, "ImageColor3", "text_dark_color")
                Tab_Icon.Parent = Tab_Button
                Tab_Data.Icon = Tab_Icon
                Tab_Label.Position = UDim2.new(0, 34, 0, 0)
                Tab_Label.Size = UDim2.new(1, -44, 1, 0)
            else
                Tab_Label.Position = UDim2.new(0, 12, 0, 0)
                Tab_Label.Size = UDim2.new(1, -20, 1, 0)
            end
        end

        local Tab_Indicator = Instance.new("Frame")
        Tab_Indicator.Size = UDim2.new(0, 3, 0, 0)
        Tab_Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Set_Color(Tab_Indicator, "BackgroundColor3", "accent_color")
        Tab_Indicator.BorderSizePixel = 0
        Tab_Indicator.Parent = Tab_Button
        
        local Indicator_Corner = Instance.new("UICorner")
        Indicator_Corner.CornerRadius = UDim.new(0, 3)
        Indicator_Corner.Parent = Tab_Indicator

        local Page_Scrolling_Frame = Instance.new("ScrollingFrame")
        Page_Scrolling_Frame.Size = UDim2.new(1, 0, 1, 0)
        Page_Scrolling_Frame.BackgroundTransparency = 1
        Page_Scrolling_Frame.BorderSizePixel = 0
        Page_Scrolling_Frame.ScrollBarThickness = 2
        Set_Color(Page_Scrolling_Frame, "ScrollBarImageColor3", "accent_color")
        Page_Scrolling_Frame.Visible = false
        Page_Scrolling_Frame.Parent = Content_Area_Frame

        local Left_Column_Frame = Instance.new("Frame")
        Left_Column_Frame.Size = UDim2.new(0.5, -16, 1, 0)
        Left_Column_Frame.Position = UDim2.new(0, 10, 0, 10)
        Left_Column_Frame.BackgroundTransparency = 1
        Left_Column_Frame.Parent = Page_Scrolling_Frame

        local Right_Column_Frame = Instance.new("Frame")
        Right_Column_Frame.Size = UDim2.new(0.5, -16, 1, 0)
        Right_Column_Frame.Position = UDim2.new(0.5, 6, 0, 10)
        Right_Column_Frame.BackgroundTransparency = 1
        Right_Column_Frame.Parent = Page_Scrolling_Frame

        local Left_Column_Layout = Instance.new("UIListLayout")
        Left_Column_Layout.Padding = UDim.new(0, 10)
        Left_Column_Layout.Parent = Left_Column_Frame

        local Right_Column_Layout = Instance.new("UIListLayout")
        Right_Column_Layout.Padding = UDim.new(0, 10)
        Right_Column_Layout.Parent = Right_Column_Frame

        run_service.RenderStepped:Connect(function()
            local Max_Column_Height = math.max(Left_Column_Layout.AbsoluteContentSize.Y, Right_Column_Layout.AbsoluteContentSize.Y)
            Page_Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, Max_Column_Height + 20)
            Tab_Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, Tab_Layout.AbsoluteContentSize.Y + 10)
        end)

        function Tab_Data:Activate()
            if Window_Context.Active_Tab == Tab_Data then return end
            if Window_Context.Active_Tab then
                Animate_Element(Window_Context.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.3)
                Animate_Element(Window_Context.Active_Tab.Lbl, {TextColor3 = Colors_Table.text_dark_color}, 0.3)
                if Window_Context.Active_Tab.Icon then Animate_Element(Window_Context.Active_Tab.Icon, {ImageColor3 = Colors_Table.text_dark_color}, 0.3) end
                Animate_Element(Window_Context.Active_Tab.Ind, {Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.3)
                Window_Context.Active_Tab.Page.Visible = false
            end
            Window_Context.Active_Tab = Tab_Data
            Page_Scrolling_Frame.Visible = true
            Animate_Element(Tab_Button, {BackgroundTransparency = 0.11847}, 0.3)
            Animate_Element(Tab_Label, {TextColor3 = Colors_Table.text_white_color}, 0.3)
            if Tab_Data.Icon then Animate_Element(Tab_Data.Icon, {ImageColor3 = Colors_Table.accent_color}, 0.3) end
            Animate_Element(Tab_Indicator, {Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 0, 0.5, -9)}, 0.3)
        end

        Tab_Button.MouseButton1Click:Connect(function() Tab_Data:Activate() end)

        Tab_Data.Btn = Tab_Button
        Tab_Data.Lbl = Tab_Label
        Tab_Data.Ind = Tab_Indicator
        Tab_Data.Page = Page_Scrolling_Frame

        table.insert(Window_Context.Tabs, Tab_Data)
        if #Window_Context.Tabs == 1 then Tab_Data:Activate() end

        local function Element_Injector(Target_Container)
            local Elements = {}

            function Elements:Subtext_Create(Text)
                local Subtext_Label = Instance.new("TextLabel")
                Subtext_Label.Size = UDim2.new(1, -10, 0, 14)
                Subtext_Label.BackgroundTransparency = 1
                Subtext_Label.Text = Text
                Set_Color(Subtext_Label, "TextColor3", "text_dark_color")
                Subtext_Label.TextSize = 11
                Subtext_Label.Font = main_font
                Subtext_Label.TextXAlignment = Enum.TextXAlignment.Left
                Subtext_Label.Parent = Target_Container
            end

            function Elements:Toggle_Create(Name, Flag, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or false)

                local Toggle_Button = Instance.new("TextButton")
                Toggle_Button.Size = UDim2.new(1, 0, 0, 16)
                Toggle_Button.BackgroundTransparency = 1
                Toggle_Button.Text = ""
                Toggle_Button.Parent = Target_Container

                local Checkbox_Frame = Instance.new("Frame")
                Checkbox_Frame.Size = UDim2.new(0, 14, 0, 14)
                Checkbox_Frame.Position = UDim2.new(0, 2, 0.5, -7)
                Set_Color(Checkbox_Frame, "BackgroundColor3", Library_Api.Flags[Flag] and "accent_color" or "element_background")
                Checkbox_Frame.BackgroundTransparency = 0.21847
                Checkbox_Frame.Parent = Toggle_Button
                
                local Checkbox_Corner = Instance.new("UICorner")
                Checkbox_Corner.CornerRadius = UDim.new(0, 3)
                Checkbox_Corner.Parent = Checkbox_Frame
                
                local Checkbox_Stroke = Instance.new("UIStroke")
                Set_Color(Checkbox_Stroke, "Color", Library_Api.Flags[Flag] and "accent_color" or "border_color")
                Checkbox_Stroke.Parent = Checkbox_Frame

                local Toggle_Label = Instance.new("TextLabel")
                Toggle_Label.Size = UDim2.new(1, -26, 1, 0)
                Toggle_Label.Position = UDim2.new(0, 24, 0, 0)
                Toggle_Label.BackgroundTransparency = 1
                Toggle_Label.Text = Name
                Set_Color(Toggle_Label, "TextColor3", Library_Api.Flags[Flag] and "text_white_color" or "text_dark_color")
                Toggle_Label.TextSize = 12
                Toggle_Label.Font = main_font
                Toggle_Label.TextXAlignment = Enum.TextXAlignment.Left
                Toggle_Label.Parent = Toggle_Button

                Toggle_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Stroke, {Color = Colors_Table.border_light_color}, 0.25) end
                end)
                Toggle_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Stroke, {Color = Colors_Table.border_color}, 0.25) end
                end)

                Toggle_Button.MouseButton1Click:Connect(function()
                    Library_Api.Flags[Flag] = not Library_Api.Flags[Flag]
                    local New_State = Library_Api.Flags[Flag]
                    Animate_Element(Checkbox_Frame, {BackgroundColor3 = New_State and Colors_Table.accent_color or Colors_Table.element_background}, 0.3)
                    Animate_Element(Checkbox_Stroke, {Color = New_State and Colors_Table.accent_color or Colors_Table.border_color}, 0.3)
                    Animate_Element(Toggle_Label, {TextColor3 = New_State and Colors_Table.text_white_color or Colors_Table.text_dark_color}, 0.3)
                    if Callback then task.spawn(Callback, New_State) end
                end)
            end

            function Elements:Slider_Create(Name, Flag, Min, Max, Default, Step, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or Snap_Value(Default or Min, Step)

                local Slider_Frame = Instance.new("Frame")
                Slider_Frame.Size = UDim2.new(1, 0, 0, 36)
                Slider_Frame.BackgroundTransparency = 1
                Slider_Frame.Parent = Target_Container

                local Slider_Label = Instance.new("TextLabel")
                Slider_Label.Size = UDim2.new(1, -50, 0, 14)
                Slider_Label.Position = UDim2.new(0, 2, 0, 0)
                Slider_Label.BackgroundTransparency = 1
                Slider_Label.Text = Name
                Set_Color(Slider_Label, "TextColor3", "text_white_color")
                Slider_Label.TextSize = 12
                Slider_Label.Font = main_font
                Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Slider_Label.Parent = Slider_Frame

                local Value_Text_Box = Instance.new("TextBox")
                Value_Text_Box.Size = UDim2.new(0, 40, 0, 14)
                Value_Text_Box.Position = UDim2.new(1, -42, 0, 0)
                Value_Text_Box.BackgroundTransparency = 1
                Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
                Set_Color(Value_Text_Box, "TextColor3", "text_white_color")
                Value_Text_Box.TextSize = 12
                Value_Text_Box.Font = main_font
                Value_Text_Box.TextXAlignment = Enum.TextXAlignment.Right
                Value_Text_Box.ClearTextOnFocus = false
                Value_Text_Box.Parent = Slider_Frame

                local Slider_Background = Instance.new("TextButton")
                Slider_Background.Size = UDim2.new(1, -4, 0, 6)
                Slider_Background.Position = UDim2.new(0, 2, 0, 24)
                Set_Color(Slider_Background, "BackgroundColor3", "element_background")
                Slider_Background.BackgroundTransparency = 0.21847
                Slider_Background.Text = ""
                Slider_Background.AutoButtonColor = false
                Slider_Background.Parent = Slider_Frame
                
                local Slider_Background_Corner = Instance.new("UICorner")
                Slider_Background_Corner.CornerRadius = UDim.new(0, 3)
                Slider_Background_Corner.Parent = Slider_Background
                
                local Slider_Background_Stroke = Instance.new("UIStroke")
                Set_Color(Slider_Background_Stroke, "Color", "border_color")
                Slider_Background_Stroke.Parent = Slider_Background

                local Slider_Fill = Instance.new("Frame")
                local Initial_Percentage = (Library_Api.Flags[Flag] - Min) / (Max - Min)
                Slider_Fill.Size = UDim2.new(Initial_Percentage, 0, 1, 0)
                Set_Color(Slider_Fill, "BackgroundColor3", "accent_color")
                Slider_Fill.Parent = Slider_Background
                
                local Slider_Fill_Corner = Instance.new("UICorner")
                Slider_Fill_Corner.CornerRadius = UDim.new(0, 3)
                Slider_Fill_Corner.Parent = Slider_Fill

                local Slider_Knob = Instance.new("Frame")
                Slider_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Slider_Knob.Size = UDim2.new(0, 10, 0, 10)
                Slider_Knob.Position = UDim2.new(Initial_Percentage, 0, 0.5, 0)
                Set_Color(Slider_Knob, "BackgroundColor3", "text_white_color")
                Slider_Knob.ZIndex = 2
                Slider_Knob.Parent = Slider_Background
                local Slider_Knob_Corner = Instance.new("UICorner"); Slider_Knob_Corner.CornerRadius = UDim.new(1, 0); Slider_Knob_Corner.Parent = Slider_Knob
                local Slider_Knob_Stroke = Instance.new("UIStroke"); Set_Color(Slider_Knob_Stroke, "Color", "border_color"); Slider_Knob_Stroke.Parent = Slider_Knob

                Slider_Background.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Slider_Background_Stroke, {Color = Colors_Table.border_light_color}, 0.25)
                end)
                Slider_Background.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Slider_Background_Stroke, {Color = Colors_Table.border_color}, 0.25)
                end)

                local Is_Sliding = false

                local function Set_Slider_Value(New_Value)
                    local Clamped_Value = math.clamp(New_Value, Min, Max)
                    local Snapped_Value = Snap_Value(Clamped_Value, Step)
                    if Library_Api.Flags[Flag] ~= Snapped_Value then
                        Library_Api.Flags[Flag] = Snapped_Value
                        local Percentage = (Snapped_Value - Min) / (Max - Min)
                        Animate_Element(Slider_Fill, {Size = UDim2.new(Percentage, 0, 1, 0)}, 0.15)
                        Animate_Element(Slider_Knob, {Position = UDim2.new(Percentage, 0, 0.5, 0)}, 0.15)
                        Value_Text_Box.Text = Format_Value(Snapped_Value, Step)
                        if Callback then task.spawn(Callback, Snapped_Value) end
                    end
                end

                Slider_Background.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding = true
                        local Percentage = math.clamp((Input.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
                        Set_Slider_Value(Min + ((Max - Min) * Percentage))
                    end
                end)

                user_input_service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                        Is_Sliding = false 
                    end
                end)

                user_input_service.InputChanged:Connect(function(Input)
                    if Is_Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then 
                        local Percentage = math.clamp((Input.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
                        Set_Slider_Value(Min + ((Max - Min) * Percentage))
                    end
                end)

                Value_Text_Box.FocusLost:Connect(function()
                    local Input_Value = tonumber(Value_Text_Box.Text)
                    if Input_Value then
                        Set_Slider_Value(Input_Value)
                    else
                        Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
                    end
                end)
            end

            function Elements:RangeSlider_Create(Name, Flag, Min, Max, Default_Min, Default_Max, Step, Tooltip, Callback)
                if not Library_Api.Flags[Flag] then
                    Library_Api.Flags[Flag] = {Min = Snap_Value(Default_Min or Min, Step), Max = Snap_Value(Default_Max or Max, Step)}
                end

                local Range_Slider_Frame = Instance.new("Frame")
                Range_Slider_Frame.Size = UDim2.new(1, 0, 0, 36)
                Range_Slider_Frame.BackgroundTransparency = 1
                Range_Slider_Frame.Parent = Target_Container

                local Range_Slider_Label = Instance.new("TextLabel")
                Range_Slider_Label.Size = UDim2.new(1, -80, 0, 14)
                Range_Slider_Label.Position = UDim2.new(0, 2, 0, 0)
                Range_Slider_Label.BackgroundTransparency = 1
                Range_Slider_Label.Text = Name
                Set_Color(Range_Slider_Label, "TextColor3", "text_white_color")
                Range_Slider_Label.TextSize = 12
                Range_Slider_Label.Font = main_font
                Range_Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Range_Slider_Label.Parent = Range_Slider_Frame

                local Value_Label = Instance.new("TextLabel")
                Value_Label.Size = UDim2.new(0, 80, 0, 14)
                Value_Label.Position = UDim2.new(1, -82, 0, 0)
                Value_Label.BackgroundTransparency = 1
                Value_Label.Text = Format_Value(Library_Api.Flags[Flag].Min, Step) .. " - " .. Format_Value(Library_Api.Flags[Flag].Max, Step)
                Set_Color(Value_Label, "TextColor3", "text_white_color")
                Value_Label.TextSize = 12
                Value_Label.Font = main_font
                Value_Label.TextXAlignment = Enum.TextXAlignment.Right
                Value_Label.Parent = Range_Slider_Frame

                local Range_Slider_Background = Instance.new("TextButton")
                Range_Slider_Background.Size = UDim2.new(1, -4, 0, 6)
                Range_Slider_Background.Position = UDim2.new(0, 2, 0, 24)
                Set_Color(Range_Slider_Background, "BackgroundColor3", "element_background")
                Range_Slider_Background.BackgroundTransparency = 0.21847
                Range_Slider_Background.Text = ""
                Range_Slider_Background.AutoButtonColor = false
                Range_Slider_Background.Parent = Range_Slider_Frame
                
                local Range_Slider_Background_Corner = Instance.new("UICorner")
                Range_Slider_Background_Corner.CornerRadius = UDim.new(0, 3)
                Range_Slider_Background_Corner.Parent = Range_Slider_Background
                
                local Range_Slider_Background_Stroke = Instance.new("UIStroke")
                Set_Color(Range_Slider_Background_Stroke, "Color", "border_color")
                Range_Slider_Background_Stroke.Parent = Range_Slider_Background

                local Range_Slider_Fill = Instance.new("Frame")
                Set_Color(Range_Slider_Fill, "BackgroundColor3", "accent_color")
                Range_Slider_Fill.Parent = Range_Slider_Background
                
                local Range_Slider_Fill_Corner = Instance.new("UICorner")
                Range_Slider_Fill_Corner.CornerRadius = UDim.new(0, 3)
                Range_Slider_Fill_Corner.Parent = Range_Slider_Fill

                local Min_Range_Knob = Instance.new("Frame")
                Min_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Min_Range_Knob.Size = UDim2.new(0, 10, 0, 10)
                Set_Color(Min_Range_Knob, "BackgroundColor3", "text_white_color")
                Min_Range_Knob.ZIndex = 2
                Min_Range_Knob.Parent = Range_Slider_Background
                local Min_Range_Knob_Corner = Instance.new("UICorner"); Min_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Min_Range_Knob_Corner.Parent = Min_Range_Knob
                local Min_Range_Knob_Stroke = Instance.new("UIStroke"); Set_Color(Min_Range_Knob_Stroke, "Color", "border_color"); Min_Range_Knob_Stroke.Parent = Min_Range_Knob

                local Max_Range_Knob = Instance.new("Frame")
                Max_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Max_Range_Knob.Size = UDim2.new(0, 10, 0, 10)
                Set_Color(Max_Range_Knob, "BackgroundColor3", "text_white_color")
                Max_Range_Knob.ZIndex = 2
                Max_Range_Knob.Parent = Range_Slider_Background
                local Max_Range_Knob_Corner = Instance.new("UICorner"); Max_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Max_Range_Knob_Corner.Parent = Max_Range_Knob
                local Max_Range_Knob_Stroke = Instance.new("UIStroke"); Set_Color(Max_Range_Knob_Stroke, "Color", "border_color"); Max_Range_Knob_Stroke.Parent = Max_Range_Knob

                local function Update_Range_Slider_Visuals()
                    local Min_Percentage = (Library_Api.Flags[Flag].Min - Min) / (Max - Min)
                    local Max_Percentage = (Library_Api.Flags[Flag].Max - Min) / (Max - Min)
                    Animate_Element(Range_Slider_Fill, {Position = UDim2.new(Min_Percentage, 0, 0, 0), Size = UDim2.new(Max_Percentage - Min_Percentage, 0, 1, 0)}, 0.15)
                    Animate_Element(Min_Range_Knob, {Position = UDim2.new(Min_Percentage, 0, 0.5, 0)}, 0.15)
                    Animate_Element(Max_Range_Knob, {Position = UDim2.new(Max_Percentage, 0, 0.5, 0)}, 0.15)
                    Value_Label.Text = Format_Value(Library_Api.Flags[Flag].Min, Step) .. " - " .. Format_Value(Library_Api.Flags[Flag].Max, Step)
                end
                Update_Range_Slider_Visuals()

                Range_Slider_Background.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Range_Slider_Background_Stroke, {Color = Colors_Table.border_light_color}, 0.25)
                end)
                Range_Slider_Background.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Range_Slider_Background_Stroke, {Color = Colors_Table.border_color}, 0.25)
                end)

                local Is_Sliding_Min = false
                local Is_Sliding_Max = false

                Range_Slider_Background.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        local Mouse_X = Input.Position.X
                        local Min_Percentage = (Library_Api.Flags[Flag].Min - Min) / (Max - Min)
                        local Max_Percentage = (Library_Api.Flags[Flag].Max - Min) / (Max - Min)
                        local Min_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Min_Percentage)
                        local Max_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Max_Percentage)
                        
                        if math.abs(Mouse_X - Min_Knob_Position) < math.abs(Mouse_X - Max_Knob_Position) then
                            Is_Sliding_Min = true
                        else
                            Is_Sliding_Max = true
                        end
                    end
                end)

                user_input_service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                        Is_Sliding_Min = false
                        Is_Sliding_Max = false
                    end
                end)

                user_input_service.InputChanged:Connect(function(Input)
                    if (Is_Sliding_Min or Is_Sliding_Max) and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then 
                        local Percentage = math.clamp((Input.Position.X - Range_Slider_Background.AbsolutePosition.X) / Range_Slider_Background.AbsoluteSize.X, 0, 1)
                        local Calculated_Value = Snap_Value(Min + ((Max - Min) * Percentage), Step)
                        
                        if Is_Sliding_Min then
                            if Calculated_Value <= Library_Api.Flags[Flag].Max then
                                Library_Api.Flags[Flag].Min = Calculated_Value
                            else
                                Library_Api.Flags[Flag].Min = Library_Api.Flags[Flag].Max
                            end
                        elseif Is_Sliding_Max then
                            if Calculated_Value >= Library_Api.Flags[Flag].Min then
                                Library_Api.Flags[Flag].Max = Calculated_Value
                            else
                                Library_Api.Flags[Flag].Max = Library_Api.Flags[Flag].Min
                            end
                        end
                        Update_Range_Slider_Visuals()
                        if Callback then task.spawn(Callback, Library_Api.Flags[Flag]) end
                    end
                end)
            end

            function Elements:Textbox_Create(Name, Flag, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or "")

                local Textbox_Frame = Instance.new("Frame")
                Textbox_Frame.Size = UDim2.new(1, 0, 0, 36)
                Textbox_Frame.BackgroundTransparency = 1
                Textbox_Frame.Parent = Target_Container

                local Textbox_Label = Instance.new("TextLabel")
                Textbox_Label.Size = UDim2.new(1, -120, 1, 0)
                Textbox_Label.Position = UDim2.new(0, 2, 0, 0)
                Textbox_Label.BackgroundTransparency = 1
                Textbox_Label.Text = Name
                Set_Color(Textbox_Label, "TextColor3", "text_white_color")
                Textbox_Label.TextSize = 12
                Textbox_Label.Font = main_font
                Textbox_Label.TextXAlignment = Enum.TextXAlignment.Left
                Textbox_Label.Parent = Textbox_Frame

                local Textbox_Input_Background = Instance.new("Frame")
                Textbox_Input_Background.Size = UDim2.new(0, 110, 0, 24)
                Textbox_Input_Background.Position = UDim2.new(1, -112, 0.5, -12)
                Set_Color(Textbox_Input_Background, "BackgroundColor3", "element_background")
                Textbox_Input_Background.BackgroundTransparency = 0.21847
                Textbox_Input_Background.Parent = Textbox_Frame
                
                local Textbox_Input_Background_Corner = Instance.new("UICorner")
                Textbox_Input_Background_Corner.CornerRadius = UDim.new(0, 4)
                Textbox_Input_Background_Corner.Parent = Textbox_Input_Background
                
                local Textbox_Input_Background_Stroke = Instance.new("UIStroke")
                Set_Color(Textbox_Input_Background_Stroke, "Color", "border_color")
                Textbox_Input_Background_Stroke.Parent = Textbox_Input_Background

                local Input_Text_Box = Instance.new("TextBox")
                Input_Text_Box.Size = UDim2.new(1, -10, 1, 0)
                Input_Text_Box.Position = UDim2.new(0, 5, 0, 0)
                Input_Text_Box.BackgroundTransparency = 1
                Input_Text_Box.Text = Library_Api.Flags[Flag]
                Set_Color(Input_Text_Box, "TextColor3", "text_dark_color")
                Input_Text_Box.TextSize = 12
                Input_Text_Box.Font = main_font
                Input_Text_Box.ClearTextOnFocus = false
                Input_Text_Box.TextXAlignment = Enum.TextXAlignment.Left
                Input_Text_Box.ClipsDescendants = true
                Input_Text_Box.Parent = Textbox_Input_Background

                Input_Text_Box.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Colors_Table.border_light_color}, 0.25)
                end)
                Input_Text_Box.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Colors_Table.border_color}, 0.25)
                end)

                Input_Text_Box.Focused:Connect(function()
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Colors_Table.accent_color}, 0.25)
                    Animate_Element(Input_Text_Box, {TextColor3 = Colors_Table.text_white_color}, 0.25)
                end)

                Input_Text_Box.FocusLost:Connect(function()
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Colors_Table.border_color}, 0.25)
                    Animate_Element(Input_Text_Box, {TextColor3 = Colors_Table.text_dark_color}, 0.25)
                    Library_Api.Flags[Flag] = Input_Text_Box.Text
                    if Callback then task.spawn(Callback, Input_Text_Box.Text) end
                end)
            end

            function Elements:Keybind_Create(Name, Flag, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Enum.KeyCode.Unknown)
                local Is_Listening = false

                local Keybind_Frame = Instance.new("Frame")
                Keybind_Frame.Size = UDim2.new(1, 0, 0, 30)
                Keybind_Frame.BackgroundTransparency = 1
                Keybind_Frame.Parent = Target_Container

                local Keybind_Icon = Instance.new("ImageLabel")
                Keybind_Icon.Size = UDim2.new(0, 18, 0, 18)
                Keybind_Icon.Position = UDim2.new(0, 6, 0.5, -9)
                Keybind_Icon.BackgroundTransparency = 1
                Keybind_Icon.Image = "rbxassetid://119296823312315"
                Set_Color(Keybind_Icon, "ImageColor3", "text_white_color")
                Keybind_Icon.Parent = Keybind_Frame

                local Keybind_Label = Instance.new("TextLabel")
                Keybind_Label.Size = UDim2.new(1, -100, 1, 0)
                Keybind_Label.Position = UDim2.new(0, 28, 0, 0)
                Keybind_Label.BackgroundTransparency = 1
                Keybind_Label.Text = Name
                Set_Color(Keybind_Label, "TextColor3", "text_white_color")
                Keybind_Label.TextSize = 12
                Keybind_Label.Font = main_font
                Keybind_Label.TextXAlignment = Enum.TextXAlignment.Left
                Keybind_Label.Parent = Keybind_Frame

                local Keybind_Button = Instance.new("TextButton")
                Keybind_Button.Size = UDim2.new(0, 70, 0, 22)
                Keybind_Button.Position = UDim2.new(1, -74, 0.5, -11)
                Set_Color(Keybind_Button, "BackgroundColor3", "element_background")
                Keybind_Button.BackgroundTransparency = 0.21847
                Keybind_Button.Text = Library_Api.Flags[Flag] == Enum.KeyCode.Unknown and "[ None ]" or "[ " .. Library_Api.Flags[Flag].Name .. " ]"
                Set_Color(Keybind_Button, "TextColor3", "text_dark_color")
                Keybind_Button.TextSize = 11
                Keybind_Button.Font = bold_font
                Keybind_Button.AutoButtonColor = false
                Keybind_Button.Parent = Keybind_Frame

                local Keybind_Button_Corner = Instance.new("UICorner")
                Keybind_Button_Corner.CornerRadius = UDim.new(0, 4)
                Keybind_Button_Corner.Parent = Keybind_Button

                local Keybind_Button_Stroke = Instance.new("UIStroke")
                Set_Color(Keybind_Button_Stroke, "Color", "border_color")
                Keybind_Button_Stroke.Parent = Keybind_Button

                Keybind_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Listening then Animate_Element(Keybind_Button_Stroke, {Color = Colors_Table.border_light_color}, 0.25) end
                end)
                Keybind_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Listening then Animate_Element(Keybind_Button_Stroke, {Color = Colors_Table.border_color}, 0.25) end
                end)

                Keybind_Button.MouseButton1Click:Connect(function()
                    Is_Listening = true
                    Keybind_Button.Text = "[ ... ]"
                    Animate_Element(Keybind_Button_Stroke, {Color = Colors_Table.accent_color}, 0.3)
                    Animate_Element(Keybind_Button, {TextColor3 = Colors_Table.text_white_color}, 0.3)
                end)

                user_input_service.InputBegan:Connect(function(Input)
                    if Is_Listening then
                        if Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode ~= Enum.KeyCode.Escape then
                            Library_Api.Flags[Flag] = Input.KeyCode
                            Keybind_Button.Text = "[ " .. Input.KeyCode.Name .. " ]"
                        elseif Input.KeyCode == Enum.KeyCode.Escape then
                            Library_Api.Flags[Flag] = Enum.KeyCode.Unknown
                            Keybind_Button.Text = "[ None ]"
                        end
                        Is_Listening = false
                        Animate_Element(Keybind_Button_Stroke, {Color = Colors_Table.border_color}, 0.3)
                        Animate_Element(Keybind_Button, {TextColor3 = Colors_Table.text_dark_color}, 0.3)
                        if Callback then task.spawn(Callback, Library_Api.Flags[Flag]) end
                    else
                        if Input.KeyCode == Library_Api.Flags[Flag] and Input.KeyCode ~= Enum.KeyCode.Unknown then
                            if Callback then task.spawn(Callback, Library_Api.Flags[Flag]) end
                        end
                    end
                end)
            end

            function Elements:Dropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Options[1])
                local Is_Dropdown_Open = false
                local Current_Options = Options
                local Dropdown_Api = {}

                local Dropdown_Frame = Instance.new("Frame")
                Dropdown_Frame.Size = UDim2.new(1, 0, 0, 46)
                Dropdown_Frame.BackgroundTransparency = 1
                Dropdown_Frame.ClipsDescendants = true
                Dropdown_Frame.Parent = Target_Container

                local Dropdown_Label = Instance.new("TextLabel")
                Dropdown_Label.Size = UDim2.new(1, -10, 0, 14)
                Dropdown_Label.Position = UDim2.new(0, 2, 0, 0)
                Dropdown_Label.BackgroundTransparency = 1
                Dropdown_Label.Text = Name
                Set_Color(Dropdown_Label, "TextColor3", "text_white_color")
                Dropdown_Label.TextSize = 12
                Dropdown_Label.Font = main_font
                Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown_Label.Parent = Dropdown_Frame

                local Dropdown_Main_Button = Instance.new("TextButton")
                Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 24)
                Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 20)
                Set_Color(Dropdown_Main_Button, "BackgroundColor3", "element_background")
                Dropdown_Main_Button.BackgroundTransparency = 0.21847
                Dropdown_Main_Button.Text = ""
                Dropdown_Main_Button.AutoButtonColor = false
                Dropdown_Main_Button.Parent = Dropdown_Frame
                
                local Dropdown_Main_Button_Corner = Instance.new("UICorner")
                Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button
                
                local Dropdown_Main_Button_Stroke = Instance.new("UIStroke")
                Set_Color(Dropdown_Main_Button_Stroke, "Color", "border_color")
                Dropdown_Main_Button_Stroke.Parent = Dropdown_Main_Button

                local Selected_Option_Label = Instance.new("TextLabel")
                Selected_Option_Label.Size = UDim2.new(1, -30, 1, 0)
                Selected_Option_Label.Position = UDim2.new(0, 8, 0, 0)
                Selected_Option_Label.BackgroundTransparency = 1
                Selected_Option_Label.Text = Library_Api.Flags[Flag] or ""
                Set_Color(Selected_Option_Label, "TextColor3", "text_dark_color")
                Selected_Option_Label.TextSize = 12
                Selected_Option_Label.Font = main_font
                Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                Selected_Option_Label.Parent = Dropdown_Main_Button

                local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
                Dropdown_Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Dropdown_Arrow_Icon.Position = UDim2.new(1, -22, 0.5, -7)
                Dropdown_Arrow_Icon.BackgroundTransparency = 1
                Dropdown_Arrow_Icon.Image = "rbxassetid://6031090656"
                Set_Color(Dropdown_Arrow_Icon, "ImageColor3", "text_dark_color")
                Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button

                local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
                Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
                Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 48)
                Set_Color(Dropdown_Option_List_Frame, "BackgroundColor3", "element_background")
                Dropdown_Option_List_Frame.BackgroundTransparency = 0.21847
                Dropdown_Option_List_Frame.BorderSizePixel = 0
                Dropdown_Option_List_Frame.ScrollBarThickness = 2
                Set_Color(Dropdown_Option_List_Frame, "ScrollBarImageColor3", "accent_color")
                Dropdown_Option_List_Frame.ClipsDescendants = true
                Dropdown_Option_List_Frame.Parent = Dropdown_Frame
                
                local Dropdown_Option_List_Corner = Instance.new("UICorner")
                Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame
                
                local Dropdown_Option_List_Stroke = Instance.new("UIStroke")
                Set_Color(Dropdown_Option_List_Stroke, "Color", "border_color")
                Dropdown_Option_List_Stroke.Transparency = 1
                Dropdown_Option_List_Stroke.Parent = Dropdown_Option_List_Frame

                local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
                Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

                local function Toggle_Dropdown_State()
                    Is_Dropdown_Open = not Is_Dropdown_Open
                    local Max_List_Height = math.min(#Current_Options * 24, 120)
                    local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
                    Animate_Element(Dropdown_Main_Button_Stroke, {Color = Is_Dropdown_Open and Colors_Table.accent_color or Colors_Table.border_color}, 0.3)
                    Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0, ImageColor3 = Is_Dropdown_Open and Colors_Table.accent_color or Colors_Table.text_dark_color}, 0.3)
                    Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.3)
                    Animate_Element(Dropdown_Option_List_Stroke, {Transparency = Is_Dropdown_Open and 0 or 1}, 0.3)
                    Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 46 + Target_List_Height + (Is_Dropdown_Open and 4 or 0))}, 0.3)
                end

                Dropdown_Main_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Colors_Table.border_light_color}, 0.25) end
                end)
                Dropdown_Main_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Colors_Table.border_color}, 0.25) end
                end)
                Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

                function Dropdown_Api:Refresh(New_Options)
                    Current_Options = New_Options
                    for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child:IsA("TextButton") then Child:Destroy() end
                    end
                    for _, Option in ipairs(Current_Options) do
                        local Option_Button = Instance.new("TextButton")
                        Option_Button.Size = UDim2.new(1, 0, 0, 24)
                        Set_Color(Option_Button, "BackgroundColor3", "element_hover_background")
                        Option_Button.BackgroundTransparency = 1
                        Option_Button.Text = ""
                        Option_Button.Parent = Dropdown_Option_List_Frame

                        local Option_Label = Instance.new("TextLabel")
                        Option_Label.Size = UDim2.new(1, -20, 1, 0)
                        Option_Label.Position = UDim2.new(0, 8, 0, 0)
                        Option_Label.BackgroundTransparency = 1
                        Option_Label.Text = Option
                        Set_Color(Option_Label, "TextColor3", Library_Api.Flags[Flag] == Option and "accent_color" or "text_dark_color")
                        Option_Label.TextSize = 12
                        Option_Label.Font = main_font
                        Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                        Option_Label.Parent = Option_Button

                        Option_Button.MouseEnter:Connect(function() 
                            Animate_Element(Option_Button, {BackgroundTransparency = 0.21847}, 0.25)
                            if Library_Api.Flags[Flag] ~= Option then Animate_Element(Option_Label, {TextColor3 = Colors_Table.text_white_color}, 0.25) end
                        end)
                        Option_Button.MouseLeave:Connect(function()
                            Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.25)
                            if Library_Api.Flags[Flag] ~= Option then Animate_Element(Option_Label, {TextColor3 = Colors_Table.text_dark_color}, 0.25) end
                        end)

                        Option_Button.MouseButton1Click:Connect(function()
                            Library_Api.Flags[Flag] = Option
                            Selected_Option_Label.Text = Option
                            Toggle_Dropdown_State()
                            for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                                if Child:IsA("TextButton") then
                                    Animate_Element(Child:FindFirstChildOfClass("TextLabel"), {TextColor3 = Colors_Table.text_dark_color}, 0.3)
                                end
                            end
                            Animate_Element(Option_Label, {TextColor3 = Colors_Table.accent_color}, 0.3)
                            if Callback then task.spawn(Callback, Option) end
                        end)
                    end
                    Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Current_Options * 24)
                end

                Dropdown_Api:Refresh(Current_Options)
                return Dropdown_Api
            end

            function Elements:ColorPicker_Create(Name, Flag, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Color3.new(1, 1, 1))
                local Is_Color_Picker_Open = false
                local Hue, Saturation, Value = Library_Api.Flags[Flag]:ToHSV()

                local Color_Picker_Frame = Instance.new("Frame")
                Color_Picker_Frame.Size = UDim2.new(1, 0, 0, 24)
                Color_Picker_Frame.BackgroundTransparency = 1
                Color_Picker_Frame.ClipsDescendants = true
                Color_Picker_Frame.Parent = Target_Container

                local Color_Picker_Label = Instance.new("TextLabel")
                Color_Picker_Label.Size = UDim2.new(1, -40, 0, 24)
                Color_Picker_Label.Position = UDim2.new(0, 2, 0, 0)
                Color_Picker_Label.BackgroundTransparency = 1
                Color_Picker_Label.Text = Name
                Set_Color(Color_Picker_Label, "TextColor3", "text_white_color")
                Color_Picker_Label.TextSize = 12
                Color_Picker_Label.Font = main_font
                Color_Picker_Label.TextXAlignment = Enum.TextXAlignment.Left
                Color_Picker_Label.Parent = Color_Picker_Frame

                local Color_Preview_Button = Instance.new("TextButton")
                Color_Preview_Button.Size = UDim2.new(0, 24, 0, 14)
                Color_Preview_Button.Position = UDim2.new(1, -28, 0, 5)
                Color_Preview_Button.BackgroundColor3 = Library_Api.Flags[Flag]
                Color_Preview_Button.Text = ""
                Color_Preview_Button.AutoButtonColor = false
                Color_Preview_Button.Parent = Color_Picker_Frame
                
                local Color_Preview_Button_Corner = Instance.new("UICorner")
                Color_Preview_Button_Corner.CornerRadius = UDim.new(0, 3)
                Color_Preview_Button_Corner.Parent = Color_Preview_Button
                
                local Color_Preview_Button_Stroke = Instance.new("UIStroke")
                Set_Color(Color_Preview_Button_Stroke, "Color", "border_color")
                Color_Preview_Button_Stroke.Parent = Color_Preview_Button

                local Expanded_Picker_Frame = Instance.new("Frame")
                Expanded_Picker_Frame.Size = UDim2.new(1, -4, 0, 190)
                Expanded_Picker_Frame.Position = UDim2.new(0, 2, 0, 28)
                Set_Color(Expanded_Picker_Frame, "BackgroundColor3", "element_background")
                Expanded_Picker_Frame.BackgroundTransparency = 0.21847
                Expanded_Picker_Frame.Parent = Color_Picker_Frame
                
                local Expanded_Picker_Corner = Instance.new("UICorner")
                Expanded_Picker_Corner.CornerRadius = UDim.new(0, 4)
                Expanded_Picker_Corner.Parent = Expanded_Picker_Frame
                
                local Expanded_Picker_Stroke = Instance.new("UIStroke")
                Set_Color(Expanded_Picker_Stroke, "Color", "border_color")
                Expanded_Picker_Stroke.Parent = Expanded_Picker_Frame

                local Saturation_Value_Map = Instance.new("ImageButton")
                Saturation_Value_Map.Size = UDim2.new(1, -16, 0, 150)
                Saturation_Value_Map.Position = UDim2.new(0, 8, 0, 8)
                Saturation_Value_Map.Image = "rbxassetid://4155801252"
                Saturation_Value_Map.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
                Saturation_Value_Map.AutoButtonColor = false
                Saturation_Value_Map.Parent = Expanded_Picker_Frame
                local Saturation_Value_Map_Corner = Instance.new("UICorner"); Saturation_Value_Map_Corner.CornerRadius = UDim.new(0, 3); Saturation_Value_Map_Corner.Parent = Saturation_Value_Map
                local Saturation_Value_Map_Stroke = Instance.new("UIStroke"); Set_Color(Saturation_Value_Map_Stroke, "Color", "border_color"); Saturation_Value_Map_Stroke.Parent = Saturation_Value_Map

                local Saturation_Value_Map_Cursor = Instance.new("Frame")
                Saturation_Value_Map_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                Saturation_Value_Map_Cursor.Size = UDim2.new(0, 6, 0, 6)
                Saturation_Value_Map_Cursor.Position = UDim2.new(Saturation, 0, 1 - Value, 0)
                Saturation_Value_Map_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                Saturation_Value_Map_Cursor.Parent = Saturation_Value_Map
                local Saturation_Value_Map_Cursor_Corner = Instance.new("UICorner"); Saturation_Value_Map_Cursor_Corner.CornerRadius = UDim.new(1, 0); Saturation_Value_Map_Cursor_Corner.Parent = Saturation_Value_Map_Cursor
                local Saturation_Value_Map_Cursor_Stroke = Instance.new("UIStroke"); Saturation_Value_Map_Cursor_Stroke.Color = Color3.new(0, 0, 0); Saturation_Value_Map_Cursor_Stroke.Parent = Saturation_Value_Map_Cursor

                local Hue_Map = Instance.new("TextButton")
                Hue_Map.Size = UDim2.new(1, -16, 0, 12)
                Hue_Map.Position = UDim2.new(0, 8, 0, 168)
                Hue_Map.Text = ""
                Hue_Map.AutoButtonColor = false
                Hue_Map.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Map.Parent = Expanded_Picker_Frame
                local Hue_Map_Corner = Instance.new("UICorner"); Hue_Map_Corner.CornerRadius = UDim.new(0, 3); Hue_Map_Corner.Parent = Hue_Map
                local Hue_Map_Stroke = Instance.new("UIStroke"); Set_Color(Hue_Map_Stroke, "Color", "border_color"); Hue_Map_Stroke.Parent = Hue_Map

                local Hue_Gradient = Instance.new("UIGradient")
                Hue_Gradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(1/6, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(2/6, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(3/6, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(4/6, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(5/6, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                }
                Hue_Gradient.Parent = Hue_Map

                local Hue_Map_Cursor = Instance.new("Frame")
                Hue_Map_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                Hue_Map_Cursor.Size = UDim2.new(0, 4, 1, 4)
                Hue_Map_Cursor.Position = UDim2.new(Hue, 0, 0.5, 0)
                Hue_Map_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Map_Cursor.Parent = Hue_Map
                local Hue_Map_Cursor_Corner = Instance.new("UICorner"); Hue_Map_Cursor_Corner.CornerRadius = UDim.new(0, 2); Hue_Map_Cursor_Corner.Parent = Hue_Map_Cursor
                local Hue_Map_Cursor_Stroke = Instance.new("UIStroke"); Hue_Map_Cursor_Stroke.Color = Color3.new(0, 0, 0); Hue_Map_Cursor_Stroke.Parent = Hue_Map_Cursor

                local function Update_Color_Picker_State()
                    local Current_Color = Color3.fromHSV(Hue, Saturation, Value)
                    Library_Api.Flags[Flag] = Current_Color
                    Saturation_Value_Map.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
                    Color_Preview_Button.BackgroundColor3 = Current_Color
                    Saturation_Value_Map_Cursor.Position = UDim2.new(Saturation, 0, 1 - Value, 0)
                    Hue_Map_Cursor.Position = UDim2.new(Hue, 0, 0.5, 0)
                    if Callback then task.spawn(Callback, Current_Color) end
                end

                local Is_Sliding_Saturation_Value = false
                local Is_Sliding_Hue = false

                local function Process_Saturation_Value_Input(Input)
                    Saturation = math.clamp((Input.Position.X - Saturation_Value_Map.AbsolutePosition.X) / Saturation_Value_Map.AbsoluteSize.X, 0, 1)
                    Value = 1 - math.clamp((Input.Position.Y - Saturation_Value_Map.AbsolutePosition.Y) / Saturation_Value_Map.AbsoluteSize.Y, 0, 1)
                    Update_Color_Picker_State()
                end

                local function Process_Hue_Input(Input)
                    Hue = math.clamp((Input.Position.X - Hue_Map.AbsolutePosition.X) / Hue_Map.AbsoluteSize.X, 0, 1)
                    Update_Color_Picker_State()
                end

                Saturation_Value_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding_Saturation_Value = true
                        Process_Saturation_Value_Input(Input)
                    end
                end)
                
                Hue_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding_Hue = true
                        Process_Hue_Input(Input)
                    end
                end)

                user_input_service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding_Saturation_Value = false
                        Is_Sliding_Hue = false
                    end
                end)

                user_input_service.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Is_Sliding_Saturation_Value then Process_Saturation_Value_Input(Input) end
                        if Is_Sliding_Hue then Process_Hue_Input(Input) end
                    end
                end)

                Color_Preview_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Color_Picker_Open then Animate_Element(Color_Preview_Button_Stroke, {Color = Colors_Table.border_light_color}, 0.25) end
                end)
                Color_Preview_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Color_Picker_Open then Animate_Element(Color_Preview_Button_Stroke, {Color = Colors_Table.border_color}, 0.25) end
                end)

                Color_Preview_Button.MouseButton1Click:Connect(function()
                    Is_Color_Picker_Open = not Is_Color_Picker_Open
                    Animate_Element(Color_Preview_Button_Stroke, {Color = Is_Color_Picker_Open and Colors_Table.accent_color or Colors_Table.border_color}, 0.3)
                    Animate_Element(Color_Picker_Frame, {Size = UDim2.new(1, 0, 0, Is_Color_Picker_Open and 224 or 24)}, 0.3)
                end)
            end

            function Elements:Button_Create(Name, Tooltip, Callback)
                local Button_Frame = Instance.new("Frame")
                Button_Frame.Size = UDim2.new(1, 0, 0, 30)
                Button_Frame.BackgroundTransparency = 1
                Button_Frame.Parent = Target_Container

                local Action_Button = Instance.new("TextButton")
                Action_Button.Size = UDim2.new(1, -4, 1, 0)
                Action_Button.Position = UDim2.new(0, 2, 0, 0)
                Set_Color(Action_Button, "BackgroundColor3", "element_background")
                Action_Button.BackgroundTransparency = 0.21847
                Action_Button.Text = Name
                Set_Color(Action_Button, "TextColor3", "text_white_color")
                Action_Button.TextSize = 12
                Action_Button.Font = bold_font
                Action_Button.AutoButtonColor = false
                Action_Button.Parent = Button_Frame
                
                local Action_Button_Corner = Instance.new("UICorner")
                Action_Button_Corner.CornerRadius = UDim.new(0, 4)
                Action_Button_Corner.Parent = Action_Button
                
                local Action_Button_Stroke = Instance.new("UIStroke")
                Set_Color(Action_Button_Stroke, "Color", "border_color")
                Action_Button_Stroke.Parent = Action_Button

                Action_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Action_Button, {BackgroundColor3 = Colors_Table.element_hover_background}, 0.25)
                    Animate_Element(Action_Button_Stroke, {Color = Colors_Table.accent_color}, 0.25)
                    Animate_Element(Action_Button, {TextColor3 = Colors_Table.accent_color}, 0.25)
                end)
                Action_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Action_Button, {BackgroundColor3 = Colors_Table.element_background}, 0.25)
                    Animate_Element(Action_Button_Stroke, {Color = Colors_Table.border_color}, 0.25)
                    Animate_Element(Action_Button, {TextColor3 = Colors_Table.text_white_color}, 0.25)
                end)
                Action_Button.MouseButton1Down:Connect(function() Animate_Element(Action_Button, {Size = UDim2.new(0.96, 0, 0.85, 0), Position = UDim2.new(0.02, 0, 0.075, 0)}, 0.15) end)
                Action_Button.MouseButton1Up:Connect(function()
                    Animate_Element(Action_Button, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.15)
                    if Callback then task.spawn(Callback) end
                end)
            end

            function Elements:SubButton_Create(Name, Tooltip, Callback)
                local Sub_Button_Frame = Instance.new("Frame")
                Sub_Button_Frame.Size = UDim2.new(1, 0, 0, 22)
                Sub_Button_Frame.BackgroundTransparency = 1
                Sub_Button_Frame.Parent = Target_Container

                local Sub_Button_Action = Instance.new("TextButton")
                Sub_Button_Action.Size = UDim2.new(1, -16, 1, 0)
                Sub_Button_Action.Position = UDim2.new(0, 8, 0, 0)
                Set_Color(Sub_Button_Action, "BackgroundColor3", "section_background")
                Sub_Button_Action.BackgroundTransparency = 0.21847
                Sub_Button_Action.Text = Name
                Set_Color(Sub_Button_Action, "TextColor3", "text_dark_color")
                Sub_Button_Action.TextSize = 11
                Sub_Button_Action.Font = main_font
                Sub_Button_Action.AutoButtonColor = false
                Sub_Button_Action.Parent = Sub_Button_Frame
                
                local Sub_Button_Corner = Instance.new("UICorner")
                Sub_Button_Corner.CornerRadius = UDim.new(0, 3)
                Sub_Button_Corner.Parent = Sub_Button_Action
                
                local Sub_Button_Stroke = Instance.new("UIStroke")
                Set_Color(Sub_Button_Stroke, "Color", "border_color")
                Sub_Button_Stroke.Parent = Sub_Button_Action

                Sub_Button_Action.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Sub_Button_Action, {BackgroundColor3 = Colors_Table.element_background}, 0.25)
                    Animate_Element(Sub_Button_Stroke, {Color = Colors_Table.border_light_color}, 0.25)
                    Animate_Element(Sub_Button_Action, {TextColor3 = Colors_Table.text_white_color}, 0.25)
                end)
                Sub_Button_Action.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Sub_Button_Action, {BackgroundColor3 = Colors_Table.section_background}, 0.25)
                    Animate_Element(Sub_Button_Stroke, {Color = Colors_Table.border_color}, 0.25)
                    Animate_Element(Sub_Button_Action, {TextColor3 = Colors_Table.text_dark_color}, 0.25)
                end)
                Sub_Button_Action.MouseButton1Down:Connect(function() Animate_Element(Sub_Button_Action, {Size = UDim2.new(0.96, -16, 0.85, 0), Position = UDim2.new(0.02, 8, 0.075, 0)}, 0.15) end)
                Sub_Button_Action.MouseButton1Up:Connect(function()
                    Animate_Element(Sub_Button_Action, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0)}, 0.15)
                    if Callback then task.spawn(Callback) end
                end)
            end

            function Elements:Module_Create(Name, Flag, Description_Text, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or false)

                local Module_Frame = Instance.new("Frame")
                Module_Frame.Size = UDim2.new(1, 0, 0, 46)
                Module_Frame.BackgroundTransparency = 1
                Module_Frame.ClipsDescendants = true
                Module_Frame.Parent = Target_Container

                local Module_Toggle_Button = Instance.new("TextButton")
                Module_Toggle_Button.Size = UDim2.new(1, -4, 0, 44)
                Module_Toggle_Button.Position = UDim2.new(0, 2, 0, 0)
                Set_Color(Module_Toggle_Button, "BackgroundColor3", "element_background")
                Module_Toggle_Button.BackgroundTransparency = 0.21847
                Module_Toggle_Button.Text = ""
                Module_Toggle_Button.AutoButtonColor = false
                Module_Toggle_Button.Parent = Module_Frame
                
                local Module_Toggle_Button_Corner = Instance.new("UICorner")
                Module_Toggle_Button_Corner.CornerRadius = UDim.new(0, 6)
                Module_Toggle_Button_Corner.Parent = Module_Toggle_Button
                
                local Module_Toggle_Button_Stroke = Instance.new("UIStroke")
                Set_Color(Module_Toggle_Button_Stroke, "Color", Library_Api.Flags[Flag] and "accent_color" or "border_color")
                Module_Toggle_Button_Stroke.Parent = Module_Toggle_Button

                local Module_Checkbox_Frame = Instance.new("Frame")
                Module_Checkbox_Frame.Size = UDim2.new(0, 16, 0, 16)
                Module_Checkbox_Frame.Position = UDim2.new(0, 14, 0.5, -8)
                Set_Color(Module_Checkbox_Frame, "BackgroundColor3", Library_Api.Flags[Flag] and "accent_color" or "section_background")
                Module_Checkbox_Frame.BackgroundTransparency = 0.21847
                Module_Checkbox_Frame.Parent = Module_Toggle_Button
                
                local Module_Checkbox_Corner = Instance.new("UICorner")
                Module_Checkbox_Corner.CornerRadius = UDim.new(0, 4)
                Module_Checkbox_Corner.Parent = Module_Checkbox_Frame
                
                local Module_Checkbox_Stroke = Instance.new("UIStroke")
                Set_Color(Module_Checkbox_Stroke, "Color", "border_color")
                Module_Checkbox_Stroke.Parent = Module_Checkbox_Frame

                local Module_Label = Instance.new("TextLabel")
                Module_Label.Size = UDim2.new(1, -45, 0, 16)
                Module_Label.Position = UDim2.new(0, 40, 0, 6)
                Module_Label.BackgroundTransparency = 1
                Module_Label.Text = Name
                Set_Color(Module_Label, "TextColor3", Library_Api.Flags[Flag] and "text_white_color" or "text_dark_color")
                Module_Label.TextSize = 13
                Module_Label.Font = bold_font
                Module_Label.TextXAlignment = Enum.TextXAlignment.Left
                Module_Label.Parent = Module_Toggle_Button

                local Module_Description_Label = Instance.new("TextLabel")
                Module_Description_Label.Size = UDim2.new(1, -45, 0, 14)
                Module_Description_Label.Position = UDim2.new(0, 40, 0, 22)
                Module_Description_Label.BackgroundTransparency = 1
                Module_Description_Label.Text = Description_Text
                Set_Color(Module_Description_Label, "TextColor3", "text_dark_color")
                Module_Description_Label.TextSize = 11
                Module_Description_Label.Font = main_font
                Module_Description_Label.TextXAlignment = Enum.TextXAlignment.Left
                Module_Description_Label.Parent = Module_Toggle_Button

                local Module_Arrow_Icon = Instance.new("ImageLabel")
                Module_Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Module_Arrow_Icon.Position = UDim2.new(1, -22, 0, 14)
                Module_Arrow_Icon.BackgroundTransparency = 1
                Module_Arrow_Icon.Image = "rbxassetid://6031090656"
                Set_Color(Module_Arrow_Icon, "ImageColor3", Library_Api.Flags[Flag] and "accent_color" or "text_dark_color")
                Module_Arrow_Icon.Rotation = Library_Api.Flags[Flag] and 180 or 0
                Module_Arrow_Icon.Parent = Module_Toggle_Button

                local Module_Content_Frame = Instance.new("Frame")
                Module_Content_Frame.Size = UDim2.new(1, -16, 0, 0)
                Module_Content_Frame.Position = UDim2.new(0, 12, 0, 48)
                Module_Content_Frame.BackgroundTransparency = 1
                Module_Content_Frame.Parent = Module_Frame

                local Module_Content_Layout = Instance.new("UIListLayout")
                Module_Content_Layout.Padding = UDim.new(0, 8)
                Module_Content_Layout.Parent = Module_Content_Frame

                local function Synchronize_Module_Size()
                    if Library_Api.Flags[Flag] then
                        Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 46 + Module_Content_Layout.AbsoluteContentSize.Y + 8)}, 0.3)
                        Animate_Element(Module_Arrow_Icon, {Rotation = 180, ImageColor3 = Colors_Table.accent_color}, 0.3)
                    else
                        Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 46)}, 0.3)
                        Animate_Element(Module_Arrow_Icon, {Rotation = 0, ImageColor3 = Colors_Table.text_dark_color}, 0.3)
                    end
                end

                Module_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Library_Api.Flags[Flag] then Synchronize_Module_Size() end
                end)

                Module_Toggle_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Library_Api.Flags[Flag] then Animate_Element(Module_Toggle_Button_Stroke, {Color = Colors_Table.border_light_color}, 0.25) end
                end)
                Module_Toggle_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Library_Api.Flags[Flag] then Animate_Element(Module_Toggle_Button_Stroke, {Color = Colors_Table.border_color}, 0.25) end
                end)

                Module_Toggle_Button.MouseButton1Click:Connect(function()
                    Library_Api.Flags[Flag] = not Library_Api.Flags[Flag]
                    local New_State = Library_Api.Flags[Flag]
                    Animate_Element(Module_Checkbox_Frame, {BackgroundColor3 = New_State and Colors_Table.accent_color or Colors_Table.section_background}, 0.3)
                    Animate_Element(Module_Toggle_Button_Stroke, {Color = New_State and Colors_Table.accent_color or Colors_Table.border_color}, 0.3)
                    Animate_Element(Module_Label, {TextColor3 = New_State and Colors_Table.text_white_color or Colors_Table.text_dark_color}, 0.3)
                    Synchronize_Module_Size()
                    if Callback then task.spawn(Callback, New_State) end
                end)

                return Element_Injector(Module_Content_Frame)
            end

            return Elements
        end

        local Section_Api = {}

        function Section_Api:Section_Create(Column_Side, Section_Title)
            local Section_Background_Frame = Instance.new("Frame")
            Section_Background_Frame.Size = UDim2.new(1, 0, 0, 40)
            Set_Color(Section_Background_Frame, "BackgroundColor3", "section_background")
            Section_Background_Frame.BackgroundTransparency = 0.21847
            Section_Background_Frame.Parent = (Column_Side == "Left") and Left_Column_Frame or Right_Column_Frame
            
            local Section_Background_Corner = Instance.new("UICorner")
            Section_Background_Corner.CornerRadius = UDim.new(0, 6)
            Section_Background_Corner.Parent = Section_Background_Frame
            
            local Section_Background_Stroke = Instance.new("UIStroke")
            Set_Color(Section_Background_Stroke, "Color", "border_color")
            Section_Background_Stroke.Parent = Section_Background_Frame

            local Section_Header_Frame = Instance.new("Frame")
            Section_Header_Frame.Size = UDim2.new(1, 0, 0, 26)
            Section_Header_Frame.BackgroundTransparency = 1
            Section_Header_Frame.Parent = Section_Background_Frame

            local Section_Label = Instance.new("TextLabel")
            Section_Label.Size = UDim2.new(1, -20, 1, 0)
            Section_Label.Position = UDim2.new(0, 10, 0, 0)
            Section_Label.BackgroundTransparency = 1
            Section_Label.Text = Section_Title
            Set_Color(Section_Label, "TextColor3", "text_white_color")
            Section_Label.TextSize = 12
            Section_Label.Font = bold_font
            Section_Label.TextXAlignment = Enum.TextXAlignment.Left
            Section_Label.Parent = Section_Header_Frame

            local Section_Separator_Line = Instance.new("Frame")
            Section_Separator_Line.Size = UDim2.new(1, -20, 0, 1)
            Section_Separator_Line.Position = UDim2.new(0, 10, 1, 0)
            Set_Color(Section_Separator_Line, "BackgroundColor3", "border_color")
            Section_Separator_Line.BorderSizePixel = 0
            Section_Separator_Line.Parent = Section_Header_Frame

            local Section_Content_Frame = Instance.new("Frame")
            Section_Content_Frame.Size = UDim2.new(1, -16, 1, -34)
            Section_Content_Frame.Position = UDim2.new(0, 8, 0, 32)
            Section_Content_Frame.BackgroundTransparency = 1
            Section_Content_Frame.Parent = Section_Background_Frame

            local Section_Content_Layout = Instance.new("UIListLayout")
            Section_Content_Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Section_Content_Layout.Padding = UDim.new(0, 8)
            Section_Content_Layout.Parent = Section_Content_Frame

            run_service.RenderStepped:Connect(function()
                Section_Background_Frame.Size = UDim2.new(1, 0, 0, Section_Content_Layout.AbsoluteContentSize.Y + 44)
            end)

            return Element_Injector(Section_Content_Frame)
        end

        return Section_Api
    end

    local Profile_Tab = Window_Context:Tab_Create("radiant.rip", nil, true)
    
    local Config_Section = Profile_Tab:Section_Create("Left", "System & Configuration")
    local Config_Dropdown = Config_Section:Dropdown_Create("Saved Configs", "Selected_Config", Get_Config_List(), "Select a configuration", "Select config to load, overwrite or delete", function(Val) end)
    
    Config_Section:Button_Create("Refresh Configs", "Update the list of saved configurations", function()
        Config_Dropdown:Refresh(Get_Config_List())
        Library_Api:Notify({Title = "System", Text = "Configuration list refreshed.", Duration = 2, Type = "Info"})
    end)
    
    Config_Section:Textbox_Create("New Config Name", "New_Config_Name", "", "Name for a new config file", function(Val) end)
    
    Config_Section:Button_Create("Save New Config", "Saves current settings to the new name", function() 
        local Name = Library_Api.Flags["New_Config_Name"]
        if Name and Name ~= "" then
            Save_Configuration(Name)
            Config_Dropdown:Refresh(Get_Config_List())
            Library_Api:Notify({Title = "System", Text = "Saved new configuration: " .. Name, Duration = 3, Type = "Success"})
        else
            Library_Api:Notify({Title = "Error", Text = "Config name cannot be empty.", Duration = 3, Type = "Error"})
        end
    end)

    Config_Section:Button_Create("Overwrite Selected", "Overwrites the config selected in the dropdown", function() 
        local Name = Library_Api.Flags["Selected_Config"]
        if Name and Name ~= "" then
            Save_Configuration(Name)
            Library_Api:Notify({Title = "System", Text = "Overwrote configuration: " .. Name, Duration = 3, Type = "Success"})
        else
            Library_Api:Notify({Title = "Error", Text = "No configuration selected to overwrite.", Duration = 3, Type = "Error"})
        end
    end)

    Config_Section:Button_Create("Load Selected", "Loads the config selected in the dropdown", function() 
        local Name = Library_Api.Flags["Selected_Config"]
        if Name and Name ~= "" then
            Load_Configuration(Name)
            Library_Api:Notify({Title = "System", Text = "Loaded configuration: " .. Name, Duration = 3, Type = "Info"})
        else
            Library_Api:Notify({Title = "Error", Text = "No configuration selected to load.", Duration = 3, Type = "Error"})
        end
    end)

    Config_Section:Button_Create("Delete Selected", "Deletes the config selected in the dropdown", function() 
        local Name = Library_Api.Flags["Selected_Config"]
        if Name and Name ~= "" then
            pcall(function() delfile(Library_Api.Folder_Name .. "/" .. Name .. ".json") end)
            Config_Dropdown:Refresh(Get_Config_List())
            Library_Api:Notify({Title = "System", Text = "Deleted configuration: " .. Name, Duration = 3, Type = "Warning"})
        end
    end)
    
    local Theme_Section = Profile_Tab:Section_Create("Right", "Theme Customization")
    
    local Theme_Names = {}
    for T_Name, _ in pairs(Preset_Themes) do table.insert(Theme_Names, T_Name) end
    
    Theme_Section:Dropdown_Create("Preset Themes", "Selected_Theme", Theme_Names, "Radiant Green", "Select a pre-made theme", function(Val)
        if Preset_Themes[Val] then
            for K, V in pairs(Preset_Themes[Val]) do
                Colors_Table[K] = V
            end
            Update_Theme()
            Library_Api:Notify({Title = "Theme", Text = "Applied preset: " .. Val, Duration = 3, Type = "Info"})
        end
    end)

    Theme_Section:Subtext_Create("Custom Colors")

    local function Hex_Format(Str)
        return Str:gsub("_", " "):gsub("^%l", string.upper)
    end

    for Key, Default_Color in pairs(Colors_Table) do
        if not Key:match("notification") and not Key:match("gradient") then
            Theme_Section:ColorPicker_Create(Hex_Format(Key), "Theme_Color_" .. Key, Default_Color, "Change " .. Hex_Format(Key), function(New_Color)
                Colors_Table[Key] = New_Color
                if Key == "accent_color" then
                    Colors_Table.accent_gradient_1 = New_Color
                    Colors_Table.accent_gradient_2 = Color3.new(New_Color.R * 0.7, New_Color.G * 0.7, New_Color.B * 0.7)
                end
                Update_Theme()
            end)
        end
    end

    local Menu_Section = Profile_Tab:Section_Create("Right", "Menu Controls")
    Menu_Section:Keybind_Create("Menu Toggle Bind", "Menu_Toggle_Key", Enum.KeyCode.Delete, "Key to hide/show menu", function() end)
    Menu_Section:Button_Create("Unload Script", "Removes the UI completely", function() screen_gui:Destroy() end)

    user_input_service.InputBegan:Connect(function(Input, Game_Processed_Event)
        if not Game_Processed_Event and Input.KeyCode == (Library_Api.Flags["Menu_Toggle_Key"] or Enum.KeyCode.Delete) then
            Main_Background.Visible = not Main_Background.Visible
        end
    end)

    return Window_Context
end

return Library_Api
