local Core_Gui_Service = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")
local Tween_Service = game:GetService("TweenService")
local Text_Service = game:GetService("TextService")
local Http_Service = game:GetService("HttpService")
local Workspace_Service = game:GetService("Workspace")
local Players_Service = game:GetService("Players")

local Library_Api = {
    Flags = {},
    Update_Functions = {},
    Folder_Name = "PhantomHub",
    Config_Name = "Auto_Save_Config.json"
}

local Menu_Colors = {
    Main_Background = Color3.fromRGB(12, 12, 12),
    Sidebar_Background = Color3.fromRGB(17, 17, 17),
    Section_Background = Color3.fromRGB(22, 22, 22),
    Element_Background = Color3.fromRGB(27, 27, 27),
    Element_Hover_Background = Color3.fromRGB(35, 35, 35),
    Border_Color = Color3.fromRGB(40, 40, 40),
    Border_Light_Color = Color3.fromRGB(60, 60, 60),
    Accent_Color = Color3.fromRGB(220, 40, 40),
    Accent_Gradient_Color_1 = Color3.fromRGB(220, 40, 40),
    Accent_Gradient_Color_2 = Color3.fromRGB(150, 20, 20),
    Text_White_Color = Color3.fromRGB(240, 240, 240),
    Text_Dark_Color = Color3.fromRGB(140, 140, 140),
    Tooltip_Background = Color3.fromRGB(15, 15, 15),
    Notification_Info_Color = Color3.fromRGB(40, 150, 220),
    Notification_Success_Color = Color3.fromRGB(40, 220, 100),
    Notification_Warning_Color = Color3.fromRGB(220, 200, 40),
    Notification_Error_Color = Color3.fromRGB(220, 40, 40)
}

local Main_Font = Enum.Font.GothamMedium
local Bold_Font = Enum.Font.GothamBold

local Screen_Gui = Instance.new("ScreenGui")
Screen_Gui.Name = Http_Service:GenerateGUID(false)
Screen_Gui.Parent = Core_Gui_Service
Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen_Gui.DisplayOrder = 999
Screen_Gui.IgnoreGuiInset = true

local Tooltip_Frame = Instance.new("Frame")
Tooltip_Frame.BackgroundColor3 = Menu_Colors.Tooltip_Background
Tooltip_Frame.BackgroundTransparency = 0.158
Tooltip_Frame.Size = UDim2.new(0, 0, 0, 24)
Tooltip_Frame.ZIndex = 2000
Tooltip_Frame.Visible = false
Tooltip_Frame.Parent = Screen_Gui

local Tooltip_Corner = Instance.new("UICorner")
Tooltip_Corner.CornerRadius = UDim.new(0, 4)
Tooltip_Corner.Parent = Tooltip_Frame

local Tooltip_Stroke = Instance.new("UIStroke")
Tooltip_Stroke.Color = Menu_Colors.Border_Light_Color
Tooltip_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Tooltip_Stroke.Transparency = 1
Tooltip_Stroke.Parent = Tooltip_Frame

local Tooltip_Text = Instance.new("TextLabel")
Tooltip_Text.Size = UDim2.new(1, -16, 1, 0)
Tooltip_Text.Position = UDim2.new(0, 8, 0, 0)
Tooltip_Text.BackgroundTransparency = 1
Tooltip_Text.TextColor3 = Menu_Colors.Text_White_Color
Tooltip_Text.TextTransparency = 1
Tooltip_Text.TextSize = 12
Tooltip_Text.Font = Main_Font
Tooltip_Text.TextXAlignment = Enum.TextXAlignment.Left
Tooltip_Text.ZIndex = 2001
Tooltip_Text.Parent = Tooltip_Frame

local Notification_Container = Instance.new("Frame")
Notification_Container.Size = UDim2.new(0, 300, 1, -40)
Notification_Container.Position = UDim2.new(1, -320, 0, 20)
Notification_Container.BackgroundTransparency = 1
Notification_Container.ZIndex = 1500
Notification_Container.Parent = Screen_Gui

local Notification_Layout = Instance.new("UIListLayout")
Notification_Layout.SortOrder = Enum.SortOrder.LayoutOrder
Notification_Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
Notification_Layout.Padding = UDim.new(0, 10)
Notification_Layout.Parent = Notification_Container

local Tooltip_Target_Text = ""

local function Animate_Element(Element, Properties, Speed)
    local Tween = Tween_Service:Create(Element, TweenInfo.new(Speed or 0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), Properties)
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
    Blur_Image.ImageTransparency = Transparency or 0.887
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
        Tooltip_Target_Text = ""
        return
    end
    local Text_Bounds = Text_Service:GetTextSize(Text_String, 12, Main_Font, Vector2.new(500, 24))
    Tooltip_Frame.Size = UDim2.new(0, Text_Bounds.X + 16, 0, 24)
    Tooltip_Text.Text = Text_String
    Tooltip_Target_Text = Text_String
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

local function Get_Configs()
    local Configs_List = {}
    if isfolder(Library_Api.Folder_Name) then
        for _, File in ipairs(listfiles(Library_Api.Folder_Name)) do
            if File:match("%.json$") then
                local File_Name = File:match("([^/\\]+)%.json$")
                if File_Name then
                    table.insert(Configs_List, File_Name)
                end
            end
        end
    end
    return Configs_List
end

local function Save_Configuration(File_Name)
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(Library_Api.Folder_Name) then
            makefolder(Library_Api.Folder_Name)
        end
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
        local Target_File = File_Name and (File_Name .. ".json") or Library_Api.Config_Name
        writefile(Library_Api.Folder_Name .. "/" .. Target_File, Http_Service:JSONEncode(Serialized_Data))
    end)
end

local function Load_Configuration(File_Name)
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local Target_File = File_Name and (File_Name .. ".json") or Library_Api.Config_Name
        local Full_Path = Library_Api.Folder_Name .. "/" .. Target_File
        if isfile(Full_Path) then
            local Decoded_Data = Http_Service:JSONDecode(readfile(Full_Path))
            if type(Decoded_Data) == "table" then
                for Key, Val in pairs(Decoded_Data) do
                    local Parsed_Value = Val
                    if type(Val) == "table" then
                        if Val.Type == "Color3" then
                            Parsed_Value = Color3.new(Val.R, Val.G, Val.B)
                        elseif Val.Type == "KeyCode" then
                            Parsed_Value = Enum.KeyCode[Val.Name] or Enum.KeyCode.Unknown
                        elseif Val.Type == "Range" then
                            Parsed_Value = {Min = Val.Min, Max = Val.Max}
                        end
                    end
                    Library_Api.Flags[Key] = Parsed_Value
                    if Library_Api.Update_Functions[Key] then
                        Library_Api.Update_Functions[Key](Parsed_Value)
                    end
                end
            end
        end
    end)
end

local function Delete_Configuration(File_Name)
    pcall(function()
        if not isfolder or not isfile or not delfile then return end
        local Full_Path = Library_Api.Folder_Name .. "/" .. File_Name .. ".json"
        if isfile(Full_Path) then
            delfile(Full_Path)
        end
    end)
end

Run_Service.RenderStepped:Connect(function()
    if Tooltip_Target_Text ~= "" then
        local Mouse_Location = User_Input_Service:GetMouseLocation()
        Tooltip_Frame.Position = UDim2.new(0, Mouse_Location.X + 15, 0, Mouse_Location.Y + 15)
        if not Tooltip_Frame.Visible then
            Tooltip_Frame.Visible = true
            Animate_Element(Tooltip_Frame, {BackgroundTransparency = 0.18}, 0.25)
            Animate_Element(Tooltip_Stroke, {Transparency = 0}, 0.25)
            Animate_Element(Tooltip_Text, {TextTransparency = 0}, 0.25)
        end
    else
        Animate_Element(Tooltip_Frame, {BackgroundTransparency = 1}, 0.15)
        Animate_Element(Tooltip_Stroke, {Transparency = 1}, 0.15)
        Animate_Element(Tooltip_Text, {TextTransparency = 1}, 0.15)
        task.delay(0.15, function()
            if Tooltip_Target_Text == "" then
                Tooltip_Frame.Visible = false
            end
        end)
    end
end)

function Library_Api:Notify(Config)
    local Title = Config.Title or "Notification"
    local Text = Config.Text or ""
    local Duration = Config.Duration or 3
    local Notification_Type = Config.Type or "Info"
    local Accent_Color = Menu_Colors["Notification_" .. Notification_Type .. "_Color"] or Menu_Colors.Accent_Color

    local Notification_Frame = Instance.new("Frame")
    Notification_Frame.Size = UDim2.new(1, 0, 0, 60)
    Notification_Frame.Position = UDim2.new(1, 320, 0, 0)
    Notification_Frame.BackgroundColor3 = Menu_Colors.Main_Background
    Notification_Frame.BackgroundTransparency = 0.285
    Notification_Frame.ZIndex = 1501
    Notification_Frame.Parent = Notification_Container

    local Notification_Corner = Instance.new("UICorner")
    Notification_Corner.CornerRadius = UDim.new(0, 6)
    Notification_Corner.Parent = Notification_Frame

    local Notification_Stroke = Instance.new("UIStroke")
    Notification_Stroke.Color = Menu_Colors.Border_Light_Color
    Notification_Stroke.Parent = Notification_Frame

    Apply_Acrylic_Effect(Notification_Frame, 0.912, UDim.new(0, 6))

    local Line_Frame = Instance.new("Frame")
    Line_Frame.Size = UDim2.new(0, 3, 1, -12)
    Line_Frame.Position = UDim2.new(0, 6, 0, 6)
    Line_Frame.BackgroundColor3 = Accent_Color
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
    Title_Label.TextColor3 = Menu_Colors.Text_White_Color
    Title_Label.TextSize = 13
    Title_Label.Font = Bold_Font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.ZIndex = 1502
    Title_Label.Parent = Notification_Frame

    local Text_Label = Instance.new("TextLabel")
    Text_Label.Size = UDim2.new(1, -24, 0, 24)
    Text_Label.Position = UDim2.new(0, 16, 0, 26)
    Text_Label.BackgroundTransparency = 1
    Text_Label.Text = Text
    Text_Label.TextColor3 = Menu_Colors.Text_Dark_Color
    Text_Label.TextSize = 12
    Text_Label.Font = Main_Font
    Text_Label.TextXAlignment = Enum.TextXAlignment.Left
    Text_Label.TextWrapped = true
    Text_Label.ZIndex = 1502
    Text_Label.Parent = Notification_Frame

    Animate_Element(Notification_Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.45)

    task.delay(Duration, function()
        local Hide_Tween = Animate_Element(Notification_Frame, {Position = UDim2.new(1, 320, 0, 0)}, 0.45)
        Hide_Tween.Completed:Connect(function()
            Notification_Frame:Destroy()
        end)
    end)
end

function Library_Api:Create_Window(Window_Name)
    local Main_Background = Instance.new("Frame")
    Main_Background.Size = UDim2.new(0, 720, 0, 480)
    Main_Background.Position = UDim2.new(0.5, -360, 0.5, -240)
    Main_Background.BackgroundColor3 = Menu_Colors.Main_Background
    Main_Background.BackgroundTransparency = 0.18
    Main_Background.BorderSizePixel = 0
    Main_Background.Active = true
    Main_Background.Parent = Screen_Gui

    local Ui_Scale_Modifier = Instance.new("UIScale")
    Ui_Scale_Modifier.Parent = Main_Background
    
    local Main_Corner = Instance.new("UICorner")
    Main_Corner.CornerRadius = UDim.new(0, 6)
    Main_Corner.Parent = Main_Background
    
    local Main_Stroke = Instance.new("UIStroke")
    Main_Stroke.Color = Menu_Colors.Border_Color
    Main_Stroke.Parent = Main_Background

    Apply_Acrylic_Effect(Main_Background, 0.887, UDim.new(0, 6))

    local Top_Bar = Instance.new("Frame")
    Top_Bar.Size = UDim2.new(1, 0, 0, 36)
    Top_Bar.BackgroundColor3 = Menu_Colors.Sidebar_Background
    Top_Bar.BackgroundTransparency = 0.218
    Top_Bar.BorderSizePixel = 0
    Top_Bar.Parent = Main_Background
    
    local Top_Corner = Instance.new("UICorner")
    Top_Corner.CornerRadius = UDim.new(0, 6)
    Top_Corner.Parent = Top_Bar

    local Top_Hider = Instance.new("Frame")
    Top_Hider.Size = UDim2.new(1, 0, 0, 6)
    Top_Hider.Position = UDim2.new(0, 0, 1, -6)
    Top_Hider.BackgroundColor3 = Menu_Colors.Sidebar_Background
    Top_Hider.BackgroundTransparency = 0.218
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
    Accent_Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Menu_Colors.Accent_Gradient_Color_1),
        ColorSequenceKeypoint.new(1, Menu_Colors.Accent_Gradient_Color_2)
    }
    Accent_Gradient.Parent = Accent_Line

    local Top_Border = Instance.new("Frame")
    Top_Border.Size = UDim2.new(1, 0, 0, 1)
    Top_Border.Position = UDim2.new(0, 0, 1, 0)
    Top_Border.BackgroundColor3 = Menu_Colors.Border_Color
    Top_Border.BorderSizePixel = 0
    Top_Border.Parent = Top_Bar

    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -20, 1, -2)
    Title_Label.Position = UDim2.new(0, 15, 0, 2)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Window_Name
    Title_Label.TextColor3 = Menu_Colors.Text_White_Color
    Title_Label.TextSize = 13
    Title_Label.Font = Bold_Font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.Parent = Top_Bar

    local Sidebar_Frame = Instance.new("Frame")
    Sidebar_Frame.Size = UDim2.new(0, 150, 1, -37)
    Sidebar_Frame.Position = UDim2.new(0, 0, 0, 37)
    Sidebar_Frame.BackgroundColor3 = Menu_Colors.Sidebar_Background
    Sidebar_Frame.BackgroundTransparency = 0.218
    Sidebar_Frame.BorderSizePixel = 0
    Sidebar_Frame.ZIndex = 5
    Sidebar_Frame.Parent = Main_Background
    
    local Sidebar_Corner = Instance.new("UICorner")
    Sidebar_Corner.CornerRadius = UDim.new(0, 6)
    Sidebar_Corner.Parent = Sidebar_Frame

    local Sidebar_Hider_Right = Instance.new("Frame")
    Sidebar_Hider_Right.Size = UDim2.new(0, 6, 1, 0)
    Sidebar_Hider_Right.Position = UDim2.new(1, -6, 0, 0)
    Sidebar_Hider_Right.BackgroundColor3 = Menu_Colors.Sidebar_Background
    Sidebar_Hider_Right.BackgroundTransparency = 0.218
    Sidebar_Hider_Right.BorderSizePixel = 0
    Sidebar_Hider_Right.Parent = Sidebar_Frame

    local Sidebar_Hider_Top = Instance.new("Frame")
    Sidebar_Hider_Top.Size = UDim2.new(1, 0, 0, 6)
    Sidebar_Hider_Top.BackgroundColor3 = Menu_Colors.Sidebar_Background
    Sidebar_Hider_Top.BackgroundTransparency = 0.218
    Sidebar_Hider_Top.BorderSizePixel = 0
    Sidebar_Hider_Top.Parent = Sidebar_Frame

    local Sidebar_Border = Instance.new("Frame")
    Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
    Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
    Sidebar_Border.BackgroundColor3 = Menu_Colors.Border_Color
    Sidebar_Border.BorderSizePixel = 0
    Sidebar_Border.Parent = Sidebar_Frame

    local Tab_Scrolling_Frame = Instance.new("ScrollingFrame")
    Tab_Scrolling_Frame.Size = UDim2.new(1, -10, 1, -60)
    Tab_Scrolling_Frame.Position = UDim2.new(0, 5, 0, 5)
    Tab_Scrolling_Frame.BackgroundTransparency = 1
    Tab_Scrolling_Frame.BorderSizePixel = 0
    Tab_Scrolling_Frame.ScrollBarThickness = 0
    Tab_Scrolling_Frame.Parent = Sidebar_Frame

    local Tab_Layout = Instance.new("UIListLayout")
    Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tab_Layout.Padding = UDim.new(0, 4)
    Tab_Layout.Parent = Tab_Scrolling_Frame

    local Profile_Button = Instance.new("TextButton")
    Profile_Button.Size = UDim2.new(1, -10, 0, 50)
    Profile_Button.Position = UDim2.new(0, 5, 1, -55)
    Profile_Button.BackgroundColor3 = Menu_Colors.Element_Background
    Profile_Button.BackgroundTransparency = 1
    Profile_Button.Text = ""
    Profile_Button.AutoButtonColor = false
    Profile_Button.ZIndex = 15
    Profile_Button.Active = true
    Profile_Button.Parent = Sidebar_Frame

    local Profile_Button_Corner = Instance.new("UICorner")
    Profile_Button_Corner.CornerRadius = UDim.new(0, 6)
    Profile_Button_Corner.Parent = Profile_Button

    local Profile_Avatar = Instance.new("ImageLabel")
    Profile_Avatar.Size = UDim2.new(0, 36, 0, 36)
    Profile_Avatar.Position = UDim2.new(0, 7, 0.5, -18)
    Profile_Avatar.BackgroundColor3 = Menu_Colors.Main_Background
    Profile_Avatar.BorderSizePixel = 0
    Profile_Avatar.ZIndex = 16
    Profile_Avatar.Parent = Profile_Button

    local Success, Avatar_Image_Url = pcall(function()
        return Players_Service:GetUserThumbnailAsync(Players_Service.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    Profile_Avatar.Image = Success and Avatar_Image_Url or ""

    local Profile_Avatar_Corner = Instance.new("UICorner")
    Profile_Avatar_Corner.CornerRadius = UDim.new(1, 0)
    Profile_Avatar_Corner.Parent = Profile_Avatar

    local Profile_Avatar_Stroke = Instance.new("UIStroke")
    Profile_Avatar_Stroke.Color = Menu_Colors.Accent_Color
    Profile_Avatar_Stroke.Thickness = 1
    Profile_Avatar_Stroke.Parent = Profile_Avatar

    local Profile_Name = Instance.new("TextLabel")
    Profile_Name.Size = UDim2.new(1, -55, 0, 16)
    Profile_Name.Position = UDim2.new(0, 50, 0, 9)
    Profile_Name.BackgroundTransparency = 1
    Profile_Name.Text = Players_Service.LocalPlayer.Name
    Profile_Name.TextColor3 = Menu_Colors.Text_White_Color
    Profile_Name.TextSize = 13
    Profile_Name.Font = Bold_Font
    Profile_Name.TextXAlignment = Enum.TextXAlignment.Left
    Profile_Name.ZIndex = 16
    Profile_Name.Parent = Profile_Button

    local Profile_Subtext = Instance.new("TextLabel")
    Profile_Subtext.Size = UDim2.new(1, -55, 0, 14)
    Profile_Subtext.Position = UDim2.new(0, 50, 0, 26)
    Profile_Subtext.BackgroundTransparency = 1
    Profile_Subtext.Text = "Settings"
    Profile_Subtext.TextColor3 = Menu_Colors.Text_Dark_Color
    Profile_Subtext.TextSize = 12
    Profile_Subtext.Font = Main_Font
    Profile_Subtext.TextXAlignment = Enum.TextXAlignment.Left
    Profile_Subtext.ZIndex = 16
    Profile_Subtext.Parent = Profile_Button

    local Content_Area_Frame = Instance.new("Frame")
    Content_Area_Frame.Size = UDim2.new(1, -151, 1, -37)
    Content_Area_Frame.Position = UDim2.new(0, 151, 0, 37)
    Content_Area_Frame.BackgroundTransparency = 1
    Content_Area_Frame.ZIndex = 5
    Content_Area_Frame.Parent = Main_Background

    local Mobile_Toggle_Button = Instance.new("ImageButton")
    Mobile_Toggle_Button.Size = UDim2.new(0, 50, 0, 50)
    Mobile_Toggle_Button.Position = UDim2.new(0, 20, 0.5, -25)
    Mobile_Toggle_Button.BackgroundColor3 = Menu_Colors.Main_Background
    Mobile_Toggle_Button.BorderSizePixel = 0
    Mobile_Toggle_Button.ZIndex = 1000
    Mobile_Toggle_Button.Visible = User_Input_Service.TouchEnabled
    Mobile_Toggle_Button.Image = Success and Avatar_Image_Url or ""
    Mobile_Toggle_Button.Parent = Screen_Gui

    local Mobile_Toggle_Corner = Instance.new("UICorner")
    Mobile_Toggle_Corner.CornerRadius = UDim.new(1, 0)
    Mobile_Toggle_Corner.Parent = Mobile_Toggle_Button

    local Mobile_Toggle_Stroke = Instance.new("UIStroke")
    Mobile_Toggle_Stroke.Color = Menu_Colors.Accent_Color
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

    User_Input_Service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Is_Toggle_Dragging = false
        end
    end)

    Run_Service.RenderStepped:Connect(function()
        if Is_Toggle_Dragging and Toggle_Drag_Input then
            local Delta = Toggle_Drag_Input.Position - Toggle_Drag_Start
            Mobile_Toggle_Button.Position = UDim2.new(Toggle_Start_Pos.X.Scale, Toggle_Start_Pos.X.Offset + Delta.X, Toggle_Start_Pos.Y.Scale, Toggle_Start_Pos.Y.Offset + Delta.Y)
        end
    end)

    local Toggle_Click_Time = 0
    Mobile_Toggle_Button.MouseButton1Down:Connect(function()
        Toggle_Click_Time = tick()
        Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 45, 0, 45)}, 0.25)
    end)
    
    Mobile_Toggle_Button.MouseButton1Up:Connect(function()
        Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 50, 0, 50)}, 0.25)
        if tick() - Toggle_Click_Time < 0.2 then
            Main_Background.Visible = not Main_Background.Visible
        end
    end)

    local function Update_Responsive_Scale()
        local Vp = Workspace_Service.CurrentCamera.ViewportSize
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

    Workspace_Service.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Update_Responsive_Scale)
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

    User_Input_Service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
            Is_Dragging = false 
        end
    end)

    Run_Service.RenderStepped:Connect(function()
        if Is_Dragging and Drag_Input then
            local Delta = Drag_Input.Position - Drag_Start
            Target_Position = UDim2.new(Start_Position.X.Scale, Start_Position.X.Offset + (Delta.X / Ui_Scale_Modifier.Scale), Start_Position.Y.Scale, Start_Position.Y.Offset + (Delta.Y / Ui_Scale_Modifier.Scale))
        end
        Main_Background.Position = Main_Background.Position:Lerp(Target_Position, 0.25)
    end)

    local Window_Context = { Tabs = {}, Active_Tab = nil }

    function Window_Context:Tab_Create(Tab_Name, Icon_Id, Is_Hidden)
        local Tab_Data = {}

        local Tab_Button = Instance.new("TextButton")
        Tab_Button.Size = UDim2.new(1, 0, 0, 32)
        Tab_Button.BackgroundColor3 = Menu_Colors.Element_Hover_Background
        Tab_Button.BackgroundTransparency = 1
        Tab_Button.Text = ""
        Tab_Button.AutoButtonColor = false
        Tab_Button.Visible = not Is_Hidden
        Tab_Button.Parent = Tab_Scrolling_Frame
        
        local Button_Corner = Instance.new("UICorner")
        Button_Corner.CornerRadius = UDim.new(0, 4)
        Button_Corner.Parent = Tab_Button

        local Tab_Label = Instance.new("TextLabel")
        Tab_Label.BackgroundTransparency = 1
        Tab_Label.Text = Tab_Name
        Tab_Label.TextColor3 = Menu_Colors.Text_Dark_Color
        Tab_Label.TextSize = 12
        Tab_Label.Font = Main_Font
        Tab_Label.TextXAlignment = Enum.TextXAlignment.Left
        Tab_Label.Parent = Tab_Button

        if Icon_Id and Icon_Id ~= "" then
            local Tab_Icon = Instance.new("ImageLabel")
            Tab_Icon.Size = UDim2.new(0, 14, 0, 14)
            Tab_Icon.Position = UDim2.new(0, 12, 0.5, -7)
            Tab_Icon.BackgroundTransparency = 1
            Tab_Icon.Image = Icon_Id
            Tab_Icon.ImageColor3 = Menu_Colors.Text_Dark_Color
            Tab_Icon.Parent = Tab_Button
            Tab_Data.Icon = Tab_Icon
            Tab_Label.Position = UDim2.new(0, 34, 0, 0)
            Tab_Label.Size = UDim2.new(1, -44, 1, 0)
        else
            Tab_Label.Position = UDim2.new(0, 12, 0, 0)
            Tab_Label.Size = UDim2.new(1, -20, 1, 0)
        end

        local Tab_Indicator = Instance.new("Frame")
        Tab_Indicator.Size = UDim2.new(0, 2, 0, 0)
        Tab_Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Tab_Indicator.BackgroundColor3 = Menu_Colors.Accent_Color
        Tab_Indicator.BorderSizePixel = 0
        Tab_Indicator.Parent = Tab_Button
        
        local Indicator_Corner = Instance.new("UICorner")
        Indicator_Corner.CornerRadius = UDim.new(0, 2)
        Indicator_Corner.Parent = Tab_Indicator

        local Page_Scrolling_Frame = Instance.new("ScrollingFrame")
        Page_Scrolling_Frame.Size = UDim2.new(1, 0, 1, 0)
        Page_Scrolling_Frame.BackgroundTransparency = 1
        Page_Scrolling_Frame.BorderSizePixel = 0
        Page_Scrolling_Frame.ScrollBarThickness = 2
        Page_Scrolling_Frame.ScrollBarImageColor3 = Menu_Colors.Accent_Color
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

        Run_Service.RenderStepped:Connect(function()
            local Max_Column_Height = math.max(Left_Column_Layout.AbsoluteContentSize.Y, Right_Column_Layout.AbsoluteContentSize.Y)
            Page_Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, Max_Column_Height + 20)
            Tab_Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, Tab_Layout.AbsoluteContentSize.Y + 10)
        end)

        function Tab_Data:Activate()
            if Window_Context.Active_Tab == Tab_Data then return end
            if Window_Context.Active_Tab then
                Animate_Element(Window_Context.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.3)
                Animate_Element(Window_Context.Active_Tab.Lbl, {TextColor3 = Menu_Colors.Text_Dark_Color}, 0.3)
                if Window_Context.Active_Tab.Icon then Animate_Element(Window_Context.Active_Tab.Icon, {ImageColor3 = Menu_Colors.Text_Dark_Color}, 0.3) end
                Animate_Element(Window_Context.Active_Tab.Ind, {Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.3)
                Window_Context.Active_Tab.Page.Visible = false
            end
            Window_Context.Active_Tab = Tab_Data
            Page_Scrolling_Frame.Visible = true
            Animate_Element(Tab_Button, {BackgroundTransparency = 0.118}, 0.3)
            Animate_Element(Tab_Label, {TextColor3 = Menu_Colors.Text_White_Color}, 0.3)
            if Tab_Data.Icon then Animate_Element(Tab_Data.Icon, {ImageColor3 = Menu_Colors.Accent_Color}, 0.3) end
            Animate_Element(Tab_Indicator, {Size = UDim2.new(0, 2, 0, 16), Position = UDim2.new(0, 0, 0.5, -8)}, 0.3)
            
            if Tab_Data.Is_Profile then
                Animate_Element(Profile_Button, {BackgroundTransparency = 0.118}, 0.3)
                Animate_Element(Profile_Name, {TextColor3 = Menu_Colors.Accent_Color}, 0.3)
            else
                Animate_Element(Profile_Button, {BackgroundTransparency = 1}, 0.3)
                Animate_Element(Profile_Name, {TextColor3 = Menu_Colors.Text_White_Color}, 0.3)
            end
        end

        Tab_Button.MouseButton1Down:Connect(function() Tab_Data:Activate() end)

        Tab_Data.Btn = Tab_Button
        Tab_Data.Lbl = Tab_Label
        Tab_Data.Ind = Tab_Indicator
        Tab_Data.Page = Page_Scrolling_Frame
        Tab_Data.Is_Profile = Is_Hidden

        table.insert(Window_Context.Tabs, Tab_Data)
        if #Window_Context.Tabs == 1 and not Is_Hidden then Tab_Data:Activate() end

        local function Element_Injector(Target_Container)
            local Elements = {}

            function Elements:Subtext_Create(Text)
                local Subtext_Label = Instance.new("TextLabel")
                Subtext_Label.Size = UDim2.new(1, -10, 0, 14)
                Subtext_Label.BackgroundTransparency = 1
                Subtext_Label.Text = Text
                Subtext_Label.TextColor3 = Menu_Colors.Text_Dark_Color
                Subtext_Label.TextSize = 11
                Subtext_Label.Font = Main_Font
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
                Checkbox_Frame.BackgroundColor3 = Library_Api.Flags[Flag] and Menu_Colors.Accent_Color or Menu_Colors.Element_Background
                Checkbox_Frame.BackgroundTransparency = 0.218
                Checkbox_Frame.Parent = Toggle_Button
                
                local Checkbox_Corner = Instance.new("UICorner")
                Checkbox_Corner.CornerRadius = UDim.new(0, 3)
                Checkbox_Corner.Parent = Checkbox_Frame
                
                local Checkbox_Stroke = Instance.new("UIStroke")
                Checkbox_Stroke.Color = Library_Api.Flags[Flag] and Menu_Colors.Accent_Color or Menu_Colors.Border_Color
                Checkbox_Stroke.Parent = Checkbox_Frame

                local Toggle_Label = Instance.new("TextLabel")
                Toggle_Label.Size = UDim2.new(1, -26, 1, 0)
                Toggle_Label.Position = UDim2.new(0, 24, 0, 0)
                Toggle_Label.BackgroundTransparency = 1
                Toggle_Label.Text = Name
                Toggle_Label.TextColor3 = Library_Api.Flags[Flag] and Menu_Colors.Text_White_Color or Menu_Colors.Text_Dark_Color
                Toggle_Label.TextSize = 12
                Toggle_Label.Font = Main_Font
                Toggle_Label.TextXAlignment = Enum.TextXAlignment.Left
                Toggle_Label.Parent = Toggle_Button

                Toggle_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Stroke, {Color = Menu_Colors.Border_Light_Color}, 0.25) end
                end)
                Toggle_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Stroke, {Color = Menu_Colors.Border_Color}, 0.25) end
                end)

                local function Set_State(New_State)
                    Library_Api.Flags[Flag] = New_State
                    Animate_Element(Checkbox_Frame, {BackgroundColor3 = New_State and Menu_Colors.Accent_Color or Menu_Colors.Element_Background}, 0.3)
                    Animate_Element(Checkbox_Stroke, {Color = New_State and Menu_Colors.Accent_Color or Menu_Colors.Border_Color}, 0.3)
                    Animate_Element(Toggle_Label, {TextColor3 = New_State and Menu_Colors.Text_White_Color or Menu_Colors.Text_Dark_Color}, 0.3)
                    if Callback then task.spawn(Callback, New_State) end
                end

                Library_Api.Update_Functions[Flag] = Set_State

                Toggle_Button.MouseButton1Click:Connect(function()
                    Set_State(not Library_Api.Flags[Flag])
                    Save_Configuration()
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
                Slider_Label.TextColor3 = Menu_Colors.Text_White_Color
                Slider_Label.TextSize = 12
                Slider_Label.Font = Main_Font
                Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Slider_Label.Parent = Slider_Frame

                local Value_Text_Box = Instance.new("TextBox")
                Value_Text_Box.Size = UDim2.new(0, 40, 0, 14)
                Value_Text_Box.Position = UDim2.new(1, -42, 0, 0)
                Value_Text_Box.BackgroundTransparency = 1
                Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
                Value_Text_Box.TextColor3 = Menu_Colors.Text_White_Color
                Value_Text_Box.TextSize = 12
                Value_Text_Box.Font = Main_Font
                Value_Text_Box.TextXAlignment = Enum.TextXAlignment.Right
                Value_Text_Box.ClearTextOnFocus = false
                Value_Text_Box.Parent = Slider_Frame

                local Slider_Background = Instance.new("TextButton")
                Slider_Background.Size = UDim2.new(1, -4, 0, 6)
                Slider_Background.Position = UDim2.new(0, 2, 0, 24)
                Slider_Background.BackgroundColor3 = Menu_Colors.Element_Background
                Slider_Background.BackgroundTransparency = 0.218
                Slider_Background.Text = ""
                Slider_Background.AutoButtonColor = false
                Slider_Background.Parent = Slider_Frame
                
                local Slider_Background_Corner = Instance.new("UICorner")
                Slider_Background_Corner.CornerRadius = UDim.new(0, 3)
                Slider_Background_Corner.Parent = Slider_Background
                
                local Slider_Background_Stroke = Instance.new("UIStroke")
                Slider_Background_Stroke.Color = Menu_Colors.Border_Color
                Slider_Background_Stroke.Parent = Slider_Background

                local Slider_Fill = Instance.new("Frame")
                local Initial_Percentage = (Library_Api.Flags[Flag] - Min) / (Max - Min)
                Slider_Fill.Size = UDim2.new(Initial_Percentage, 0, 1, 0)
                Slider_Fill.BackgroundColor3 = Menu_Colors.Accent_Color
                Slider_Fill.Parent = Slider_Background
                
                local Slider_Fill_Corner = Instance.new("UICorner")
                Slider_Fill_Corner.CornerRadius = UDim.new(0, 3)
                Slider_Fill_Corner.Parent = Slider_Fill

                local Slider_Knob = Instance.new("Frame")
                Slider_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Slider_Knob.Size = UDim2.new(0, 10, 0, 10)
                Slider_Knob.Position = UDim2.new(Initial_Percentage, 0, 0.5, 0)
                Slider_Knob.BackgroundColor3 = Menu_Colors.Text_White_Color
                Slider_Knob.ZIndex = 2
                Slider_Knob.Parent = Slider_Background
                local Slider_Knob_Corner = Instance.new("UICorner"); Slider_Knob_Corner.CornerRadius = UDim.new(1, 0); Slider_Knob_Corner.Parent = Slider_Knob
                local Slider_Knob_Stroke = Instance.new("UIStroke"); Slider_Knob_Stroke.Color = Menu_Colors.Border_Color; Slider_Knob_Stroke.Parent = Slider_Knob

                Slider_Background.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Slider_Background_Stroke, {Color = Menu_Colors.Border_Light_Color}, 0.25)
                end)
                Slider_Background.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Slider_Background_Stroke, {Color = Menu_Colors.Border_Color}, 0.25)
                end)

                local Is_Sliding = false

                local function Set_Slider_Value(New_Value)
                    local Clamped_Value = math.clamp(New_Value, Min, Max)
                    local Snapped_Value = Snap_Value(Clamped_Value, Step)
                    Library_Api.Flags[Flag] = Snapped_Value
                    local Percentage = (Snapped_Value - Min) / (Max - Min)
                    Animate_Element(Slider_Fill, {Size = UDim2.new(Percentage, 0, 1, 0)}, 0.15)
                    Animate_Element(Slider_Knob, {Position = UDim2.new(Percentage, 0, 0.5, 0)}, 0.15)
                    Value_Text_Box.Text = Format_Value(Snapped_Value, Step)
                    if Callback then task.spawn(Callback, Snapped_Value) end
                end

                Library_Api.Update_Functions[Flag] = Set_Slider_Value

                Slider_Background.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding = true
                        local Percentage = math.clamp((Input.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
                        Set_Slider_Value(Min + ((Max - Min) * Percentage))
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                        if Is_Sliding then Save_Configuration() end
                        Is_Sliding = false 
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if Is_Sliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then 
                        local Percentage = math.clamp((Input.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
                        Set_Slider_Value(Min + ((Max - Min) * Percentage))
                    end
                end)

                Value_Text_Box.FocusLost:Connect(function()
                    local Input_Value = tonumber(Value_Text_Box.Text)
                    if Input_Value then
                        Set_Slider_Value(Input_Value)
                        Save_Configuration()
                    else
                        Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
                    end
                end)
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
                Color_Picker_Label.TextColor3 = Menu_Colors.Text_White_Color
                Color_Picker_Label.TextSize = 12
                Color_Picker_Label.Font = Main_Font
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
                Color_Preview_Button_Stroke.Color = Menu_Colors.Border_Color
                Color_Preview_Button_Stroke.Parent = Color_Preview_Button

                local Expanded_Picker_Frame = Instance.new("Frame")
                Expanded_Picker_Frame.Size = UDim2.new(1, -4, 0, 190)
                Expanded_Picker_Frame.Position = UDim2.new(0, 2, 0, 28)
                Expanded_Picker_Frame.BackgroundColor3 = Menu_Colors.Element_Background
                Expanded_Picker_Frame.BackgroundTransparency = 0.218
                Expanded_Picker_Frame.Parent = Color_Picker_Frame
                
                local Expanded_Picker_Corner = Instance.new("UICorner")
                Expanded_Picker_Corner.CornerRadius = UDim.new(0, 4)
                Expanded_Picker_Corner.Parent = Expanded_Picker_Frame
                
                local Expanded_Picker_Stroke = Instance.new("UIStroke")
                Expanded_Picker_Stroke.Color = Menu_Colors.Border_Color
                Expanded_Picker_Stroke.Parent = Expanded_Picker_Frame

                local Saturation_Value_Map = Instance.new("ImageButton")
                Saturation_Value_Map.Size = UDim2.new(1, -16, 0, 150)
                Saturation_Value_Map.Position = UDim2.new(0, 8, 0, 8)
                Saturation_Value_Map.Image = "rbxassetid://4155801252"
                Saturation_Value_Map.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
                Saturation_Value_Map.AutoButtonColor = false
                Saturation_Value_Map.Parent = Expanded_Picker_Frame
                local Saturation_Value_Map_Corner = Instance.new("UICorner"); Saturation_Value_Map_Corner.CornerRadius = UDim.new(0, 3); Saturation_Value_Map_Corner.Parent = Saturation_Value_Map
                local Saturation_Value_Map_Stroke = Instance.new("UIStroke"); Saturation_Value_Map_Stroke.Color = Menu_Colors.Border_Color; Saturation_Value_Map_Stroke.Parent = Saturation_Value_Map

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
                local Hue_Map_Stroke = Instance.new("UIStroke"); Hue_Map_Stroke.Color = Menu_Colors.Border_Color; Hue_Map_Stroke.Parent = Hue_Map

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

                Library_Api.Update_Functions[Flag] = function(New_Color)
                    Library_Api.Flags[Flag] = New_Color
                    Hue, Saturation, Value = New_Color:ToHSV()
                    Update_Color_Picker_State()
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

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        if Is_Sliding_Saturation_Value or Is_Sliding_Hue then
                            Save_Configuration()
                        end
                        Is_Sliding_Saturation_Value = false
                        Is_Sliding_Hue = false
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Is_Sliding_Saturation_Value then Process_Saturation_Value_Input(Input) end
                        if Is_Sliding_Hue then Process_Hue_Input(Input) end
                    end
                end)

                Color_Preview_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Color_Picker_Open then Animate_Element(Color_Preview_Button_Stroke, {Color = Menu_Colors.Border_Light_Color}, 0.25) end
                end)
                Color_Preview_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Color_Picker_Open then Animate_Element(Color_Preview_Button_Stroke, {Color = Menu_Colors.Border_Color}, 0.25) end
                end)

                Color_Preview_Button.MouseButton1Click:Connect(function()
                    Is_Color_Picker_Open = not Is_Color_Picker_Open
                    Animate_Element(Color_Preview_Button_Stroke, {Color = Is_Color_Picker_Open and Menu_Colors.Accent_Color or Menu_Colors.Border_Color}, 0.3)
                    Animate_Element(Color_Picker_Frame, {Size = UDim2.new(1, 0, 0, Is_Color_Picker_Open and 224 or 24)}, 0.3)
                end)
            end

            function Elements:Dropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Options[1])
                local Is_Dropdown_Open = false

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
                Dropdown_Label.TextColor3 = Menu_Colors.Text_White_Color
                Dropdown_Label.TextSize = 12
                Dropdown_Label.Font = Main_Font
                Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown_Label.Parent = Dropdown_Frame

                local Dropdown_Main_Button = Instance.new("TextButton")
                Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 24)
                Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 20)
                Dropdown_Main_Button.BackgroundColor3 = Menu_Colors.Element_Background
                Dropdown_Main_Button.BackgroundTransparency = 0.218
                Dropdown_Main_Button.Text = ""
                Dropdown_Main_Button.AutoButtonColor = false
                Dropdown_Main_Button.Parent = Dropdown_Frame
                
                local Dropdown_Main_Button_Corner = Instance.new("UICorner")
                Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button
                
                local Dropdown_Main_Button_Stroke = Instance.new("UIStroke")
                Dropdown_Main_Button_Stroke.Color = Menu_Colors.Border_Color
                Dropdown_Main_Button_Stroke.Parent = Dropdown_Main_Button

                local Selected_Option_Label = Instance.new("TextLabel")
                Selected_Option_Label.Size = UDim2.new(1, -30, 1, 0)
                Selected_Option_Label.Position = UDim2.new(0, 8, 0, 0)
                Selected_Option_Label.BackgroundTransparency = 1
                Selected_Option_Label.Text = Library_Api.Flags[Flag] or "None"
                Selected_Option_Label.TextColor3 = Menu_Colors.Text_Dark_Color
                Selected_Option_Label.TextSize = 12
                Selected_Option_Label.Font = Main_Font
                Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                Selected_Option_Label.Parent = Dropdown_Main_Button

                local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
                Dropdown_Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Dropdown_Arrow_Icon.Position = UDim2.new(1, -22, 0.5, -7)
                Dropdown_Arrow_Icon.BackgroundTransparency = 1
                Dropdown_Arrow_Icon.Image = "rbxassetid://6031090656"
                Dropdown_Arrow_Icon.ImageColor3 = Menu_Colors.Text_Dark_Color
                Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button

                local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
                Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
                Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 48)
                Dropdown_Option_List_Frame.BackgroundColor3 = Menu_Colors.Element_Background
                Dropdown_Option_List_Frame.BackgroundTransparency = 0.218
                Dropdown_Option_List_Frame.BorderSizePixel = 0
                Dropdown_Option_List_Frame.ScrollBarThickness = 2
                Dropdown_Option_List_Frame.ScrollBarImageColor3 = Menu_Colors.Accent_Color
                Dropdown_Option_List_Frame.ClipsDescendants = true
                Dropdown_Option_List_Frame.Parent = Dropdown_Frame
                
                local Dropdown_Option_List_Corner = Instance.new("UICorner")
                Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame

                local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
                Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

                local function Toggle_Dropdown_State()
                    Is_Dropdown_Open = not Is_Dropdown_Open
                    local Max_List_Height = math.min(#Options * 24, 120)
                    local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
                    Animate_Element(Dropdown_Main_Button_Stroke, {Color = Is_Dropdown_Open and Menu_Colors.Accent_Color or Menu_Colors.Border_Color}, 0.3)
                    Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0, ImageColor3 = Is_Dropdown_Open and Menu_Colors.Accent_Color or Menu_Colors.Text_Dark_Color}, 0.3)
                    Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.3)
                    Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 46 + Target_List_Height + (Is_Dropdown_Open and 4 or 0))}, 0.3)
                end

                Dropdown_Main_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Menu_Colors.Border_Light_Color}, 0.25) end
                end)
                Dropdown_Main_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button_Stroke, {Color = Menu_Colors.Border_Color}, 0.25) end
                end)
                Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

                local function Setup_Options()
                    for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child:IsA("TextButton") then Child:Destroy() end
                    end
                    for _, Option in ipairs(Options) do
                        local Option_Button = Instance.new("TextButton")
                        Option_Button.Size = UDim2.new(1, 0, 0, 24)
                        Option_Button.BackgroundColor3 = Menu_Colors.Element_Hover_Background
                        Option_Button.BackgroundTransparency = 1
                        Option_Button.Text = ""
                        Option_Button.Parent = Dropdown_Option_List_Frame

                        local Option_Label = Instance.new("TextLabel")
                        Option_Label.Size = UDim2.new(1, -20, 1, 0)
                        Option_Label.Position = UDim2.new(0, 8, 0, 0)
                        Option_Label.BackgroundTransparency = 1
                        Option_Label.Text = Option
                        Option_Label.TextColor3 = Library_Api.Flags[Flag] == Option and Menu_Colors.Accent_Color or Menu_Colors.Text_Dark_Color
                        Option_Label.TextSize = 12
                        Option_Label.Font = Main_Font
                        Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                        Option_Label.Parent = Option_Button

                        Option_Button.MouseEnter:Connect(function() 
                            Animate_Element(Option_Button, {BackgroundTransparency = 0.218}, 0.25)
                            if Library_Api.Flags[Flag] ~= Option then
                                Animate_Element(Option_Label, {TextColor3 = Menu_Colors.Text_White_Color}, 0.25) 
                            end
                        end)
                        Option_Button.MouseLeave:Connect(function()
                            Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.25)
                            if Library_Api.Flags[Flag] ~= Option then
                                Animate_Element(Option_Label, {TextColor3 = Menu_Colors.Text_Dark_Color}, 0.25)
                            end
                        end)

                        Option_Button.MouseButton1Click:Connect(function()
                            Library_Api.Flags[Flag] = Option
                            Selected_Option_Label.Text = Option
                            Toggle_Dropdown_State()
                            for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                                if Child:IsA("TextButton") then
                                    Animate_Element(Child:FindFirstChildOfClass("TextLabel"), {TextColor3 = Menu_Colors.Text_Dark_Color}, 0.3)
                                end
                            end
                            Animate_Element(Option_Label, {TextColor3 = Menu_Colors.Accent_Color}, 0.3)
                            Save_Configuration()
                            if Callback then task.spawn(Callback, Option) end
                        end)
                    end
                    Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Options * 24)
                end
                
                Setup_Options()

                local Dropdown_Context = {}
                function Dropdown_Context:Refresh(New_Options)
                    Options = New_Options
                    Setup_Options()
                    local Found = false
                    for _, Opt in ipairs(Options) do
                        if Opt == Library_Api.Flags[Flag] then Found = true break end
                    end
                    if not Found and #Options > 0 then
                        Library_Api.Flags[Flag] = Options[1]
                        Selected_Option_Label.Text = Options[1]
                    elseif #Options == 0 then
                        Selected_Option_Label.Text = "None"
                        Library_Api.Flags[Flag] = nil
                    end
                end

                Library_Api.Update_Functions[Flag] = function(New_Value)
                    Library_Api.Flags[Flag] = New_Value
                    Selected_Option_Label.Text = New_Value
                    for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child:IsA("TextButton") then
                            local Lbl = Child:FindFirstChildOfClass("TextLabel")
                            if Lbl then
                                Lbl.TextColor3 = Lbl.Text == New_Value and Menu_Colors.Accent_Color or Menu_Colors.Text_Dark_Color
                            end
                        end
                    end
                    if Callback then task.spawn(Callback, New_Value) end
                end

                return Dropdown_Context
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
                Textbox_Label.TextColor3 = Menu_Colors.Text_White_Color
                Textbox_Label.TextSize = 12
                Textbox_Label.Font = Main_Font
                Textbox_Label.TextXAlignment = Enum.TextXAlignment.Left
                Textbox_Label.Parent = Textbox_Frame

                local Textbox_Input_Background = Instance.new("Frame")
                Textbox_Input_Background.Size = UDim2.new(0, 110, 0, 24)
                Textbox_Input_Background.Position = UDim2.new(1, -112, 0.5, -12)
                Textbox_Input_Background.BackgroundColor3 = Menu_Colors.Element_Background
                Textbox_Input_Background.BackgroundTransparency = 0.218
                Textbox_Input_Background.Parent = Textbox_Frame
                
                local Textbox_Input_Background_Corner = Instance.new("UICorner")
                Textbox_Input_Background_Corner.CornerRadius = UDim.new(0, 4)
                Textbox_Input_Background_Corner.Parent = Textbox_Input_Background
                
                local Textbox_Input_Background_Stroke = Instance.new("UIStroke")
                Textbox_Input_Background_Stroke.Color = Menu_Colors.Border_Color
                Textbox_Input_Background_Stroke.Parent = Textbox_Input_Background

                local Input_Text_Box = Instance.new("TextBox")
                Input_Text_Box.Size = UDim2.new(1, -10, 1, 0)
                Input_Text_Box.Position = UDim2.new(0, 5, 0, 0)
                Input_Text_Box.BackgroundTransparency = 1
                Input_Text_Box.Text = Library_Api.Flags[Flag]
                Input_Text_Box.TextColor3 = Menu_Colors.Text_Dark_Color
                Input_Text_Box.TextSize = 12
                Input_Text_Box.Font = Main_Font
                Input_Text_Box.ClearTextOnFocus = false
                Input_Text_Box.TextXAlignment = Enum.TextXAlignment.Left
                Input_Text_Box.ClipsDescendants = true
                Input_Text_Box.Parent = Textbox_Input_Background

                Input_Text_Box.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Menu_Colors.Border_Light_Color}, 0.25)
                end)
                Input_Text_Box.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Menu_Colors.Border_Color}, 0.25)
                end)

                Input_Text_Box.Focused:Connect(function()
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Menu_Colors.Accent_Color}, 0.25)
                    Animate_Element(Input_Text_Box, {TextColor3 = Menu_Colors.Text_White_Color}, 0.25)
                end)

                Input_Text_Box.FocusLost:Connect(function()
                    Animate_Element(Textbox_Input_Background_Stroke, {Color = Menu_Colors.Border_Color}, 0.25)
                    Animate_Element(Input_Text_Box, {TextColor3 = Menu_Colors.Text_Dark_Color}, 0.25)
                    Library_Api.Flags[Flag] = Input_Text_Box.Text
                    Save_Configuration()
                    if Callback then task.spawn(Callback, Input_Text_Box.Text) end
                end)

                Library_Api.Update_Functions[Flag] = function(New_Value)
                    Library_Api.Flags[Flag] = New_Value
                    Input_Text_Box.Text = New_Value
                    if Callback then task.spawn(Callback, New_Value) end
                end
            end

            function Elements:Button_Create(Name, Tooltip, Callback)
                local Button_Frame = Instance.new("Frame")
                Button_Frame.Size = UDim2.new(1, 0, 0, 30)
                Button_Frame.BackgroundTransparency = 1
                Button_Frame.Parent = Target_Container

                local Action_Button = Instance.new("TextButton")
                Action_Button.Size = UDim2.new(1, -4, 1, 0)
                Action_Button.Position = UDim2.new(0, 2, 0, 0)
                Action_Button.BackgroundColor3 = Menu_Colors.Element_Background
                Action_Button.BackgroundTransparency = 0.218
                Action_Button.Text = Name
                Action_Button.TextColor3 = Menu_Colors.Text_White_Color
                Action_Button.TextSize = 12
                Action_Button.Font = Bold_Font
                Action_Button.AutoButtonColor = false
                Action_Button.Parent = Button_Frame
                
                local Action_Button_Corner = Instance.new("UICorner")
                Action_Button_Corner.CornerRadius = UDim.new(0, 4)
                Action_Button_Corner.Parent = Action_Button
                
                local Action_Button_Stroke = Instance.new("UIStroke")
                Action_Button_Stroke.Color = Menu_Colors.Border_Color
                Action_Button_Stroke.Parent = Action_Button

                Action_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Action_Button, {BackgroundColor3 = Menu_Colors.Element_Hover_Background}, 0.25)
                    Animate_Element(Action_Button_Stroke, {Color = Menu_Colors.Accent_Color}, 0.25)
                    Animate_Element(Action_Button, {TextColor3 = Menu_Colors.Accent_Color}, 0.25)
                end)
                Action_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Action_Button, {BackgroundColor3 = Menu_Colors.Element_Background}, 0.25)
                    Animate_Element(Action_Button_Stroke, {Color = Menu_Colors.Border_Color}, 0.25)
                    Animate_Element(Action_Button, {TextColor3 = Menu_Colors.Text_White_Color}, 0.25)
                end)
                Action_Button.MouseButton1Down:Connect(function() Animate_Element(Action_Button, {Size = UDim2.new(0.96, 0, 0.85, 0), Position = UDim2.new(0.02, 0, 0.075, 0)}, 0.15) end)
                Action_Button.MouseButton1Up:Connect(function()
                    Animate_Element(Action_Button, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.15)
                    if Callback then task.spawn(Callback) end
                end)
            end

            return Elements
        end

        local Section_Api = {}
        function Section_Api:Section_Create(Column_Side, Section_Title)
            local Section_Background_Frame = Instance.new("Frame")
            Section_Background_Frame.Size = UDim2.new(1, 0, 0, 40)
            Section_Background_Frame.BackgroundColor3 = Menu_Colors.Section_Background
            Section_Background_Frame.BackgroundTransparency = 0.218
            Section_Background_Frame.Parent = (Column_Side == "Left") and Left_Column_Frame or Right_Column_Frame
            
            local Section_Background_Corner = Instance.new("UICorner")
            Section_Background_Corner.CornerRadius = UDim.new(0, 6)
            Section_Background_Corner.Parent = Section_Background_Frame
            
            local Section_Background_Stroke = Instance.new("UIStroke")
            Section_Background_Stroke.Color = Menu_Colors.Border_Color
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
            Section_Label.TextColor3 = Menu_Colors.Text_White_Color
            Section_Label.TextSize = 12
            Section_Label.Font = Bold_Font
            Section_Label.TextXAlignment = Enum.TextXAlignment.Left
            Section_Label.Parent = Section_Header_Frame

            local Section_Separator_Line = Instance.new("Frame")
            Section_Separator_Line.Size = UDim2.new(1, -20, 0, 1)
            Section_Separator_Line.Position = UDim2.new(0, 10, 1, 0)
            Section_Separator_Line.BackgroundColor3 = Menu_Colors.Border_Color
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

            Run_Service.RenderStepped:Connect(function()
                Section_Background_Frame.Size = UDim2.new(1, 0, 0, Section_Content_Layout.AbsoluteContentSize.Y + 44)
            end)

            return Element_Injector(Section_Content_Frame)
        end
        return Section_Api
    end

    local Settings_Tab_Context = Window_Context:Tab_Create("Settings", "", true)
    
    Profile_Button.MouseButton1Down:Connect(function()
        Settings_Tab_Context:Activate()
    end)

    local Theme_Section = Settings_Tab_Context:Section_Create("Left", "Theme")
    
    Theme_Section:ColorPicker_Create("Accent Color", "Menu_Accent_Color", Menu_Colors.Accent_Color, "Select global menu accent color", function(New_Color)
        Menu_Colors.Accent_Color = New_Color
        Library_Api:Notify({
            Title = "Theme Updated", 
            Text = "Settings saved. Restart menu to fully apply changes.", 
            Duration = 3, 
            Type = "Success"
        })
    end)

    local Config_Section = Settings_Tab_Context:Section_Create("Right", "PhantomHub Config")
    
    local Config_Name_Input = ""
    Config_Section:Textbox_Create("Config Name", "New_Config_Name", "", "Enter a name for the config", function(Value)
        Config_Name_Input = Value
    end)

    local Selected_Config = ""
    local Config_Dropdown = Config_Section:Dropdown_Create("Select Config", "Selected_Config", Get_Configs(), "", "Select a configuration", function(Value)
        Selected_Config = Value
    end)

    Config_Section:Button_Create("Save New Config", "Saves current settings to new config", function()
        if Config_Name_Input ~= "" then
            Save_Configuration(Config_Name_Input)
            Config_Dropdown:Refresh(Get_Configs())
            Library_Api:Notify({Title = "System", Text = "Saved Config: " .. Config_Name_Input, Type = "Success"})
        end
    end)

    Config_Section:Button_Create("Load Config", "Loads selected configuration", function()
        if Selected_Config and Selected_Config ~= "" then
            Load_Configuration(Selected_Config)
            Library_Api:Notify({Title = "System", Text = "Loaded Config: " .. Selected_Config, Type = "Info"})
        end
    end)

    Config_Section:Button_Create("Rewrite Config", "Overwrites selected configuration", function()
        if Selected_Config and Selected_Config ~= "" then
            Save_Configuration(Selected_Config)
            Library_Api:Notify({Title = "System", Text = "Rewrote Config: " .. Selected_Config, Type = "Warning"})
        end
    end)

    Config_Section:Button_Create("Delete Config", "Deletes selected configuration", function()
        if Selected_Config and Selected_Config ~= "" then
            Delete_Configuration(Selected_Config)
            Config_Dropdown:Refresh(Get_Configs())
            Library_Api:Notify({Title = "System", Text = "Deleted Config: " .. Selected_Config, Type = "Error"})
        end
    end)

    User_Input_Service.InputBegan:Connect(function(Input, Game_Processed_Event)
        if not Game_Processed_Event and Input.KeyCode == Enum.KeyCode.Delete then
            Main_Background.Visible = not Main_Background.Visible
        end
    end)

    return Window_Context
end

return Library_Api
