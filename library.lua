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
    Folder_Name = "PhantomHub",
    Current_Config = "Default"
}

local UI_Colors = {
    Main_Background = Color3.fromRGB(12, 12, 12),
    Sidebar_Background = Color3.fromRGB(8, 8, 8),
    Section_Background = Color3.fromRGB(16, 16, 16),
    Element_Background = Color3.fromRGB(20, 20, 20),
    Element_Hover_Background = Color3.fromRGB(30, 15, 15),
    Border_Color = Color3.fromRGB(45, 15, 15),
    Border_Light_Color = Color3.fromRGB(75, 20, 20),
    Accent_Color = Color3.fromRGB(220, 30, 30),
    Text_White_Color = Color3.fromRGB(240, 240, 240),
    Text_Dark_Color = Color3.fromRGB(140, 140, 140),
    Tooltip_Background = Color3.fromRGB(10, 10, 10),
    Notification_Info_Color = Color3.fromRGB(220, 30, 30),
    Notification_Success_Color = Color3.fromRGB(50, 200, 50),
    Notification_Warning_Color = Color3.fromRGB(220, 150, 30),
    Notification_Error_Color = Color3.fromRGB(250, 50, 50)
}

local Theme_Objects = {}

local function Apply_Theme(Target_Object, Property_Name, Color_Key)
    if not Theme_Objects[Color_Key] then Theme_Objects[Color_Key] = {} end
    table.insert(Theme_Objects[Color_Key], {Target_Object, Property_Name})
    pcall(function() Target_Object[Property_Name] = UI_Colors[Color_Key] end)
end

local function Update_Theme(Color_Key, New_Color)
    UI_Colors[Color_Key] = New_Color
    if Theme_Objects[Color_Key] then
        for _, Item_Data in ipairs(Theme_Objects[Color_Key]) do
            if Item_Data[1] and Item_Data[1].Parent then
                pcall(function() Item_Data[1][Item_Data[2]] = New_Color end)
            end
        end
    end
end

local Main_Font = Enum.Font.GothamMedium
local Bold_Font = Enum.Font.GothamBold

local Screen_Gui = Instance.new("ScreenGui")
Screen_Gui.Name = Http_Service:GenerateGUID(false)
Screen_Gui.Parent = Core_Gui_Service
Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen_Gui.DisplayOrder = 999
Screen_Gui.IgnoreGuiInset = true

local Tooltip_Frame = Instance.new("Frame")
Apply_Theme(Tooltip_Frame, "BackgroundColor3", "Tooltip_Background")
Tooltip_Frame.BackgroundTransparency = 0.15
Tooltip_Frame.Size = UDim2.new(0, 0, 0, 24)
Tooltip_Frame.ZIndex = 2000
Tooltip_Frame.Visible = false
Tooltip_Frame.Parent = Screen_Gui

local Tooltip_Corner = Instance.new("UICorner")
Tooltip_Corner.CornerRadius = UDim.new(0, 4)
Tooltip_Corner.Parent = Tooltip_Frame

local Tooltip_Stroke = Instance.new("UIStroke")
Apply_Theme(Tooltip_Stroke, "Color", "Border_Light_Color")
Tooltip_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Tooltip_Stroke.Transparency = 1
Tooltip_Stroke.Parent = Tooltip_Frame

local Tooltip_Text = Instance.new("TextLabel")
Tooltip_Text.Size = UDim2.new(1, -16, 1, 0)
Tooltip_Text.Position = UDim2.new(0, 8, 0, 0)
Tooltip_Text.BackgroundTransparency = 1
Apply_Theme(Tooltip_Text, "TextColor3", "Text_White_Color")
Tooltip_Text.TextTransparency = 1
Tooltip_Text.TextSize = 12
Tooltip_Text.Font = Main_Font
Tooltip_Text.TextXAlignment = Enum.TextXAlignment.Left
Tooltip_Text.ZIndex = 2001
Tooltip_Text.Parent = Tooltip_Frame

local Notification_Container = Instance.new("Frame")
Notification_Container.Size = UDim2.new(0, 250, 1, -40)
Notification_Container.Position = UDim2.new(1, -270, 0, 20)
Notification_Container.BackgroundTransparency = 1
Notification_Container.ZIndex = 1500
Notification_Container.Parent = Screen_Gui

local Notification_Layout = Instance.new("UIListLayout")
Notification_Layout.SortOrder = Enum.SortOrder.LayoutOrder
Notification_Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
Notification_Layout.Padding = UDim.new(0, 8)
Notification_Layout.Parent = Notification_Container

local Tooltip_Target_Text = ""
local Active_Keybinds = {}
local Keybind_List_Container = nil

local function Animate_Element(Element_Object, Target_Properties, Speed_Value)
    local Tween_Instance = Tween_Service:Create(Element_Object, TweenInfo.new(Speed_Value or 0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), Target_Properties)
    Tween_Instance:Play()
    return Tween_Instance
end

local function Apply_Acrylic_Effect(Parent_Object, Transparency_Value, Corner_Radius)
    local Blur_Image = Instance.new("ImageLabel")
    Blur_Image.Size = UDim2.new(1, 0, 1, 0)
    Blur_Image.BackgroundTransparency = 1
    Blur_Image.Image = "rbxassetid://8992230113"
    Blur_Image.TileSize = UDim2.new(0, 256, 0, 256)
    Blur_Image.ScaleType = Enum.ScaleType.Tile
    Blur_Image.ImageTransparency = Transparency_Value or 0.88
    Blur_Image.ZIndex = Parent_Object.ZIndex - 1
    Blur_Image.Parent = Parent_Object
    if Corner_Radius then
        local Effect_Corner = Instance.new("UICorner")
        Effect_Corner.CornerRadius = Corner_Radius
        Effect_Corner.Parent = Blur_Image
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

local function Snap_Value(Value_Num, Step_Value)
    if not Step_Value then return Value_Num end
    return math.floor((Value_Num / Step_Value) + 0.5) * Step_Value
end

local function Format_Value(Value_Num, Step_Value)
    if Step_Value and Step_Value < 1 then
        local Decimal_Places = tostring(Step_Value):len() - 2
        return string.format("%." .. Decimal_Places .. "f", Value_Num)
    end
    return tostring(Value_Num)
end

local function Get_Configs()
    local Config_List = {}
    if isfolder and isfolder(Library_Api.Folder_Name) and listfiles then
        pcall(function()
            for _, File_Path in ipairs(listfiles(Library_Api.Folder_Name)) do
                local File_Name = File_Path:match("([^/\\]+)%.json$")
                if File_Name then table.insert(Config_List, File_Name) end
            end
        end)
    end
    if #Config_List == 0 then table.insert(Config_List, "Default") end
    return Config_List
end

local function Save_Configuration(Config_Name)
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(Library_Api.Folder_Name) then makefolder(Library_Api.Folder_Name) end
        local Serialized_Data = {}
        for Flag_Key, Flag_Val in pairs(Library_Api.Flags) do
            if typeof(Flag_Val) == "Color3" then
                Serialized_Data[Flag_Key] = {Type = "Color3", R = Flag_Val.R, G = Flag_Val.G, B = Flag_Val.B}
            elseif typeof(Flag_Val) == "EnumItem" then
                Serialized_Data[Flag_Key] = {Type = "KeyCode", Name = Flag_Val.Name}
            elseif type(Flag_Val) == "table" and Flag_Val.Min and Flag_Val.Max then
                Serialized_Data[Flag_Key] = {Type = "Range", Min = Flag_Val.Min, Max = Flag_Val.Max}
            else
                Serialized_Data[Flag_Key] = Flag_Val
            end
        end
        local Theme_Data = {}
        for Color_Key, Color_Val in pairs(UI_Colors) do
            Theme_Data[Color_Key] = {R = Color_Val.R, G = Color_Val.G, B = Color_Val.B}
        end
        local Full_Save_Data = {Flags = Serialized_Data, Theme = Theme_Data}
        writefile(Library_Api.Folder_Name .. "/" .. Config_Name .. ".json", Http_Service:JSONEncode(Full_Save_Data))
        Library_Api:Notify({Title = "Config", Text = "Saved config: " .. Config_Name, Type = "Success", Duration = 2})
    end)
end

local function Load_Configuration(Config_Name)
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local Full_File_Path = Library_Api.Folder_Name .. "/" .. Config_Name .. ".json"
        if isfile(Full_File_Path) then
            local Decoded_Data = Http_Service:JSONDecode(readfile(Full_File_Path))
            if Decoded_Data and type(Decoded_Data) == "table" then
                if Decoded_Data.Theme then
                    for Color_Key, Color_Val in pairs(Decoded_Data.Theme) do
                        if UI_Colors[Color_Key] then
                            Update_Theme(Color_Key, Color3.new(Color_Val.R, Color_Val.G, Color_Val.B))
                        end
                    end
                end
                if Decoded_Data.Flags then
                    for Flag_Key, Flag_Val in pairs(Decoded_Data.Flags) do
                        if type(Flag_Val) == "table" then
                            if Flag_Val.Type == "Color3" then
                                Library_Api.Flags[Flag_Key] = Color3.new(Flag_Val.R, Flag_Val.G, Flag_Val.B)
                            elseif Flag_Val.Type == "KeyCode" then
                                Library_Api.Flags[Flag_Key] = Enum.KeyCode[Flag_Val.Name] or Enum.KeyCode.Unknown
                            elseif Flag_Val.Type == "Range" then
                                Library_Api.Flags[Flag_Key] = {Min = Flag_Val.Min, Max = Flag_Val.Max}
                            else
                                Library_Api.Flags[Flag_Key] = Flag_Val
                            end
                        else
                            Library_Api.Flags[Flag_Key] = Flag_Val
                        end
                    end
                end
                Library_Api:Notify({Title = "Config", Text = "Loaded config: " .. Config_Name, Type = "Info", Duration = 2})
            end
        end
    end)
end

local function Delete_Configuration(Config_Name)
    pcall(function()
        if isfile and delfile then
            local Full_File_Path = Library_Api.Folder_Name .. "/" .. Config_Name .. ".json"
            if isfile(Full_File_Path) then
                delfile(Full_File_Path)
                Library_Api:Notify({Title = "Config", Text = "Deleted config: " .. Config_Name, Type = "Error", Duration = 2})
            end
        end
    end)
end

local function Refresh_Keybinds_List()
    if not Keybind_List_Container then return end
    for _, Child_Element in ipairs(Keybind_List_Container:GetChildren()) do
        if Child_Element:IsA("Frame") then Child_Element:Destroy() end
    end
    for Bind_Name, Bind_Key in pairs(Active_Keybinds) do
        local Bind_Entry_Frame = Instance.new("Frame")
        Bind_Entry_Frame.Size = UDim2.new(1, 0, 0, 20)
        Bind_Entry_Frame.BackgroundTransparency = 1
        Bind_Entry_Frame.Parent = Keybind_List_Container

        local Name_Label = Instance.new("TextLabel")
        Name_Label.Size = UDim2.new(1, -60, 1, 0)
        Name_Label.Position = UDim2.new(0, 5, 0, 0)
        Name_Label.BackgroundTransparency = 1
        Name_Label.Text = Bind_Name
        Apply_Theme(Name_Label, "TextColor3", "Text_Dark_Color")
        Name_Label.TextSize = 11
        Name_Label.Font = Main_Font
        Name_Label.TextXAlignment = Enum.TextXAlignment.Left
        Name_Label.TextTruncate = Enum.TextTruncate.AtEnd
        Name_Label.Parent = Bind_Entry_Frame

        local Key_Label = Instance.new("TextLabel")
        Key_Label.Size = UDim2.new(0, 50, 1, 0)
        Key_Label.Position = UDim2.new(1, -55, 0, 0)
        Key_Label.BackgroundTransparency = 1
        Key_Label.Text = "[" .. Bind_Key .. "]"
        Apply_Theme(Key_Label, "TextColor3", "Accent_Color")
        Key_Label.TextSize = 11
        Key_Label.Font = Bold_Font
        Key_Label.TextXAlignment = Enum.TextXAlignment.Right
        Key_Label.Parent = Bind_Entry_Frame
    end
    Keybind_List_Container.CanvasSize = UDim2.new(0, 0, 0, Keybind_List_Container.UIListLayout.AbsoluteContentSize.Y)
end

Run_Service.RenderStepped:Connect(function()
    if Tooltip_Target_Text ~= "" then
        local Mouse_Location = User_Input_Service:GetMouseLocation()
        Tooltip_Frame.Position = UDim2.new(0, Mouse_Location.X + 15, 0, Mouse_Location.Y + 15)
        if not Tooltip_Frame.Visible then
            Tooltip_Frame.Visible = true
            Animate_Element(Tooltip_Frame, {BackgroundTransparency = 0.15}, 0.25)
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

function Library_Api:Notify(Config_Table)
    local Title_Text = Config_Table.Title or "Notification"
    local Body_Text = Config_Table.Text or ""
    local Duration_Time = Config_Table.Duration or 3
    local Notification_Type = Config_Table.Type or "Info"

    local Notification_Frame = Instance.new("Frame")
    Notification_Frame.Size = UDim2.new(1, 0, 0, 50)
    Notification_Frame.Position = UDim2.new(1, 270, 0, 0)
    Apply_Theme(Notification_Frame, "BackgroundColor3", "Section_Background")
    Notification_Frame.BackgroundTransparency = 0.05
    Notification_Frame.ZIndex = 1501
    Notification_Frame.Parent = Notification_Container

    local Notification_Corner = Instance.new("UICorner")
    Notification_Corner.CornerRadius = UDim.new(0, 4)
    Notification_Corner.Parent = Notification_Frame

    local Notification_Stroke = Instance.new("UIStroke")
    Apply_Theme(Notification_Stroke, "Color", "Border_Color")
    Notification_Stroke.Parent = Notification_Frame

    local Line_Frame = Instance.new("Frame")
    Line_Frame.Size = UDim2.new(0, 2, 1, -16)
    Line_Frame.Position = UDim2.new(0, 8, 0, 8)
    Apply_Theme(Line_Frame, "BackgroundColor3", "Notification_" .. Notification_Type .. "_Color")
    Line_Frame.BorderSizePixel = 0
    Line_Frame.ZIndex = 1502
    Line_Frame.Parent = Notification_Frame

    local Line_Corner = Instance.new("UICorner")
    Line_Corner.CornerRadius = UDim.new(0, 2)
    Line_Corner.Parent = Line_Frame

    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -24, 0, 14)
    Title_Label.Position = UDim2.new(0, 16, 0, 8)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Title_Text
    Apply_Theme(Title_Label, "TextColor3", "Text_White_Color")
    Title_Label.TextSize = 12
    Title_Label.Font = Bold_Font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.ZIndex = 1502
    Title_Label.Parent = Notification_Frame

    local Text_Label = Instance.new("TextLabel")
    Text_Label.Size = UDim2.new(1, -24, 0, 18)
    Text_Label.Position = UDim2.new(0, 16, 0, 24)
    Text_Label.BackgroundTransparency = 1
    Text_Label.Text = Body_Text
    Apply_Theme(Text_Label, "TextColor3", "Text_Dark_Color")
    Text_Label.TextSize = 11
    Text_Label.Font = Main_Font
    Text_Label.TextXAlignment = Enum.TextXAlignment.Left
    Text_Label.TextWrapped = true
    Text_Label.ZIndex = 1502
    Text_Label.Parent = Notification_Frame

    Animate_Element(Notification_Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.45)

    task.delay(Duration_Time, function()
        local Hide_Tween = Animate_Element(Notification_Frame, {Position = UDim2.new(1, 270, 0, 0)}, 0.45)
        Hide_Tween.Completed:Connect(function()
            Notification_Frame:Destroy()
        end)
    end)
end

function Library_Api:CreateWindow(Window_Name)
    local Main_Background = Instance.new("Frame")
    Main_Background.Size = UDim2.new(0, 720, 0, 480)
    Main_Background.Position = UDim2.new(0.5, -360, 0.5, -240)
    Apply_Theme(Main_Background, "BackgroundColor3", "Main_Background")
    Main_Background.BackgroundTransparency = 0.18
    Main_Background.BorderSizePixel = 0
    Main_Background.Active = true
    Main_Background.Parent = Screen_Gui

    local UI_Scale_Modifier = Instance.new("UIScale")
    UI_Scale_Modifier.Parent = Main_Background
    
    local Main_Corner = Instance.new("UICorner")
    Main_Corner.CornerRadius = UDim.new(0, 6)
    Main_Corner.Parent = Main_Background
    
    local Main_Stroke = Instance.new("UIStroke")
    Apply_Theme(Main_Stroke, "Color", "Border_Color")
    Main_Stroke.Parent = Main_Background

    Apply_Acrylic_Effect(Main_Background, 0.88, UDim.new(0, 6))

    local Top_Bar = Instance.new("Frame")
    Top_Bar.Size = UDim2.new(1, 0, 0, 36)
    Apply_Theme(Top_Bar, "BackgroundColor3", "Sidebar_Background")
    Top_Bar.BackgroundTransparency = 0.21
    Top_Bar.BorderSizePixel = 0
    Top_Bar.Parent = Main_Background
    
    local Top_Corner = Instance.new("UICorner")
    Top_Corner.CornerRadius = UDim.new(0, 6)
    Top_Corner.Parent = Top_Bar

    local Top_Hider = Instance.new("Frame")
    Top_Hider.Size = UDim2.new(1, 0, 0, 6)
    Top_Hider.Position = UDim2.new(0, 0, 1, -6)
    Apply_Theme(Top_Hider, "BackgroundColor3", "Sidebar_Background")
    Top_Hider.BackgroundTransparency = 0.21
    Top_Hider.BorderSizePixel = 0
    Top_Hider.Parent = Top_Bar

    local Top_Border = Instance.new("Frame")
    Top_Border.Size = UDim2.new(1, 0, 0, 1)
    Top_Border.Position = UDim2.new(0, 0, 1, 0)
    Apply_Theme(Top_Border, "BackgroundColor3", "Border_Color")
    Top_Border.BorderSizePixel = 0
    Top_Border.Parent = Top_Bar

    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -20, 1, -2)
    Title_Label.Position = UDim2.new(0, 15, 0, 2)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Window_Name
    Apply_Theme(Title_Label, "TextColor3", "Text_White_Color")
    Title_Label.TextSize = 13
    Title_Label.Font = Bold_Font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.Parent = Top_Bar

    local Sidebar_Frame = Instance.new("Frame")
    Sidebar_Frame.Size = UDim2.new(0, 150, 1, -37)
    Sidebar_Frame.Position = UDim2.new(0, 0, 0, 37)
    Apply_Theme(Sidebar_Frame, "BackgroundColor3", "Sidebar_Background")
    Sidebar_Frame.BackgroundTransparency = 0.21
    Sidebar_Frame.BorderSizePixel = 0
    Sidebar_Frame.Parent = Main_Background
    
    local Sidebar_Corner = Instance.new("UICorner")
    Sidebar_Corner.CornerRadius = UDim.new(0, 6)
    Sidebar_Corner.Parent = Sidebar_Frame

    local Sidebar_Hider_Right = Instance.new("Frame")
    Sidebar_Hider_Right.Size = UDim2.new(0, 6, 1, 0)
    Sidebar_Hider_Right.Position = UDim2.new(1, -6, 0, 0)
    Apply_Theme(Sidebar_Hider_Right, "BackgroundColor3", "Sidebar_Background")
    Sidebar_Hider_Right.BackgroundTransparency = 0.21
    Sidebar_Hider_Right.BorderSizePixel = 0
    Sidebar_Hider_Right.Parent = Sidebar_Frame

    local Sidebar_Hider_Top = Instance.new("Frame")
    Sidebar_Hider_Top.Size = UDim2.new(1, 0, 0, 6)
    Apply_Theme(Sidebar_Hider_Top, "BackgroundColor3", "Sidebar_Background")
    Sidebar_Hider_Top.BackgroundTransparency = 0.21
    Sidebar_Hider_Top.BorderSizePixel = 0
    Sidebar_Hider_Top.Parent = Sidebar_Frame

    local Sidebar_Border = Instance.new("Frame")
    Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
    Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
    Apply_Theme(Sidebar_Border, "BackgroundColor3", "Border_Color")
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
    Profile_Button.Size = UDim2.new(1, -10, 0, 45)
    Profile_Button.Position = UDim2.new(0, 5, 1, -50)
    Profile_Button.BackgroundTransparency = 1
    Profile_Button.Text = ""
    Profile_Button.Parent = Sidebar_Frame

    local Profile_Corner = Instance.new("UICorner")
    Profile_Corner.CornerRadius = UDim.new(0, 6)
    Profile_Corner.Parent = Profile_Button

    local Avatar_Image = Instance.new("ImageLabel")
    Avatar_Image.Size = UDim2.new(0, 30, 0, 30)
    Avatar_Image.Position = UDim2.new(0, 5, 0.5, -15)
    Avatar_Image.BackgroundTransparency = 1
    local Success_Fetch, Thumb_URL = pcall(function() return Players_Service:GetUserThumbnailAsync(Players_Service.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
    Avatar_Image.Image = Success_Fetch and Thumb_URL or ""
    Avatar_Image.Parent = Profile_Button

    local Avatar_Corner = Instance.new("UICorner")
    Avatar_Corner.CornerRadius = UDim.new(1, 0)
    Avatar_Corner.Parent = Avatar_Image

    local Avatar_Stroke = Instance.new("UIStroke")
    Avatar_Stroke.Thickness = 1.5
    Apply_Theme(Avatar_Stroke, "Color", "Accent_Color")
    Avatar_Stroke.Parent = Avatar_Image

    local Username_Label = Instance.new("TextLabel")
    Username_Label.Size = UDim2.new(1, -45, 0, 14)
    Username_Label.Position = UDim2.new(0, 42, 0, 8)
    Username_Label.BackgroundTransparency = 1
    Username_Label.Text = Players_Service.LocalPlayer.Name
    Apply_Theme(Username_Label, "TextColor3", "Text_White_Color")
    Username_Label.TextSize = 12
    Username_Label.Font = Bold_Font
    Username_Label.TextXAlignment = Enum.TextXAlignment.Left
    Username_Label.TextTruncate = Enum.TextTruncate.AtEnd
    Username_Label.Parent = Profile_Button

    local Settings_Sub_Label = Instance.new("TextLabel")
    Settings_Sub_Label.Size = UDim2.new(1, -45, 0, 12)
    Settings_Sub_Label.Position = UDim2.new(0, 42, 0, 24)
    Settings_Sub_Label.BackgroundTransparency = 1
    Settings_Sub_Label.Text = "Settings"
    Apply_Theme(Settings_Sub_Label, "TextColor3", "Text_Dark_Color")
    Settings_Sub_Label.TextSize = 11
    Settings_Sub_Label.Font = Main_Font
    Settings_Sub_Label.TextXAlignment = Enum.TextXAlignment.Left
    Settings_Sub_Label.Parent = Profile_Button

    local Content_Area_Frame = Instance.new("Frame")
    Content_Area_Frame.Size = UDim2.new(1, -151, 1, -37)
    Content_Area_Frame.Position = UDim2.new(0, 151, 0, 37)
    Content_Area_Frame.BackgroundTransparency = 1
    Content_Area_Frame.Parent = Main_Background

    local KB_Outer_Frame = Instance.new("Frame")
    KB_Outer_Frame.Size = UDim2.new(0, 180, 0, 200)
    KB_Outer_Frame.Position = UDim2.new(0, 20, 0.5, -100)
    Apply_Theme(KB_Outer_Frame, "BackgroundColor3", "Main_Background")
    KB_Outer_Frame.BackgroundTransparency = 0.18
    KB_Outer_Frame.Visible = false
    KB_Outer_Frame.Parent = Screen_Gui

    local KB_Outer_Corner = Instance.new("UICorner")
    KB_Outer_Corner.CornerRadius = UDim.new(0, 6)
    KB_Outer_Corner.Parent = KB_Outer_Frame

    local KB_Outer_Stroke = Instance.new("UIStroke")
    Apply_Theme(KB_Outer_Stroke, "Color", "Border_Color")
    KB_Outer_Stroke.Parent = KB_Outer_Frame

    Apply_Acrylic_Effect(KB_Outer_Frame, 0.88, UDim.new(0, 6))

    local KB_Header_Label = Instance.new("TextLabel")
    KB_Header_Label.Size = UDim2.new(1, 0, 0, 26)
    KB_Header_Label.BackgroundTransparency = 1
    KB_Header_Label.Text = "Keybinds"
    Apply_Theme(KB_Header_Label, "TextColor3", "Text_White_Color")
    KB_Header_Label.TextSize = 12
    KB_Header_Label.Font = Bold_Font
    KB_Header_Label.Parent = KB_Outer_Frame

    local KB_Header_Line = Instance.new("Frame")
    KB_Header_Line.Size = UDim2.new(1, -20, 0, 1)
    KB_Header_Line.Position = UDim2.new(0, 10, 0, 26)
    Apply_Theme(KB_Header_Line, "BackgroundColor3", "Border_Color")
    KB_Header_Line.BorderSizePixel = 0
    KB_Header_Line.Parent = KB_Outer_Frame

    Keybind_List_Container = Instance.new("ScrollingFrame")
    Keybind_List_Container.Size = UDim2.new(1, -10, 1, -35)
    Keybind_List_Container.Position = UDim2.new(0, 5, 0, 30)
    Keybind_List_Container.BackgroundTransparency = 1
    Keybind_List_Container.BorderSizePixel = 0
    Keybind_List_Container.ScrollBarThickness = 0
    Keybind_List_Container.Parent = KB_Outer_Frame

    local KB_Layout = Instance.new("UIListLayout")
    KB_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    KB_Layout.Parent = Keybind_List_Container
    
    local Is_Updating_KB_Size = false
    local function Update_Keybind_List_Size()
        if Is_Updating_KB_Size then return end
        Is_Updating_KB_Size = true
        task.defer(function()
            Keybind_List_Container.CanvasSize = UDim2.new(0, 0, 0, KB_Layout.AbsoluteContentSize.Y)
            Is_Updating_KB_Size = false
        end)
    end
    KB_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Keybind_List_Size)

    local KB_Drag_Start_Pos, KB_Start_Pos
    local Is_Dragging_KB = false
    KB_Header_Label.InputBegan:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging_KB = true
            KB_Drag_Start_Pos = Input_Event.Position
            KB_Start_Pos = KB_Outer_Frame.Position
        end
    end)
    User_Input_Service.InputChanged:Connect(function(Input_Event)
        if Is_Dragging_KB and (Input_Event.UserInputType == Enum.UserInputType.MouseMovement or Input_Event.UserInputType == Enum.UserInputType.Touch) then
            local Delta_Pos = Input_Event.Position - KB_Drag_Start_Pos
            KB_Outer_Frame.Position = UDim2.new(KB_Start_Pos.X.Scale, KB_Start_Pos.X.Offset + Delta_Pos.X, KB_Start_Pos.Y.Scale, KB_Start_Pos.Y.Offset + Delta_Pos.Y)
        end
    end)
    User_Input_Service.InputEnded:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging_KB = false
        end
    end)

    local Mobile_Toggle_Btn = Instance.new("ImageButton")
    Mobile_Toggle_Btn.Size = UDim2.new(0, 36, 0, 36)
    Mobile_Toggle_Btn.Position = UDim2.new(0, 20, 0.5, -18)
    Apply_Theme(Mobile_Toggle_Btn, "BackgroundColor3", "Main_Background")
    Mobile_Toggle_Btn.BorderSizePixel = 0
    Mobile_Toggle_Btn.ZIndex = 1000
    Mobile_Toggle_Btn.Visible = true
    Mobile_Toggle_Btn.Image = "rbxassetid://131244616689186"
    Mobile_Toggle_Btn.Parent = Screen_Gui

    local Mobile_Toggle_Corner = Instance.new("UICorner")
    Mobile_Toggle_Corner.CornerRadius = UDim.new(1, 0)
    Mobile_Toggle_Corner.Parent = Mobile_Toggle_Btn

    local Mobile_Toggle_Stroke = Instance.new("UIStroke")
    Apply_Theme(Mobile_Toggle_Stroke, "Color", "Accent_Color")
    Mobile_Toggle_Stroke.Thickness = 2
    Mobile_Toggle_Stroke.Parent = Mobile_Toggle_Btn

    local Is_Dragging_Toggle = false
    local Toggle_Drag_Input = nil
    local Toggle_Drag_Start_Pos = nil
    local Toggle_Start_Pos = nil

    Mobile_Toggle_Btn.InputBegan:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging_Toggle = true
            Toggle_Drag_Start_Pos = Input_Event.Position
            Toggle_Start_Pos = Mobile_Toggle_Btn.Position
        end
    end)

    Mobile_Toggle_Btn.InputChanged:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseMovement or Input_Event.UserInputType == Enum.UserInputType.Touch then
            Toggle_Drag_Input = Input_Event
        end
    end)

    User_Input_Service.InputEnded:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging_Toggle = false
        end
    end)

    Run_Service.RenderStepped:Connect(function()
        if Is_Dragging_Toggle and Toggle_Drag_Input then
            local Delta_Pos = Toggle_Drag_Input.Position - Toggle_Drag_Start_Pos
            Mobile_Toggle_Btn.Position = UDim2.new(Toggle_Start_Pos.X.Scale, Toggle_Start_Pos.X.Offset + Delta_Pos.X, Toggle_Start_Pos.Y.Scale, Toggle_Start_Pos.Y.Offset + Delta_Pos.Y)
        end
    end)

    local Toggle_Click_Time = 0
    Mobile_Toggle_Btn.MouseButton1Down:Connect(function()
        Toggle_Click_Time = tick()
        Animate_Element(Mobile_Toggle_Btn, {Size = UDim2.new(0, 30, 0, 30)}, 0.25)
    end)
    
    Mobile_Toggle_Btn.MouseButton1Up:Connect(function()
        Animate_Element(Mobile_Toggle_Btn, {Size = UDim2.new(0, 36, 0, 36)}, 0.25)
        if tick() - Toggle_Click_Time < 0.2 then
            Main_Background.Visible = not Main_Background.Visible
        end
    end)

    local function Update_Responsive_Scale()
        local Viewport_Size = Workspace_Service.CurrentCamera.ViewportSize
        if Viewport_Size.X < 1 or Viewport_Size.Y < 1 then 
            UI_Scale_Modifier.Scale = 1
            return
        end
        local Scale_X = Viewport_Size.X / 800
        local Scale_Y = Viewport_Size.Y / 500
        local Final_Scale = math.min(Scale_X, Scale_Y)
        if Final_Scale < 1 then
            UI_Scale_Modifier.Scale = math.clamp(Final_Scale * 0.95, 0.4, 1)
        else
            UI_Scale_Modifier.Scale = 1
        end
    end

    Workspace_Service.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Update_Responsive_Scale)
    Update_Responsive_Scale()

    local Is_Dragging_Menu = false
    local Menu_Drag_Input = nil
    local Menu_Drag_Start_Pos = nil
    local Menu_Start_Pos = nil
    local Menu_Target_Pos = Main_Background.Position

    Top_Bar.InputBegan:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging_Menu = true
            Menu_Drag_Start_Pos = Input_Event.Position
            Menu_Start_Pos = Main_Background.Position
        end
    end)

    Top_Bar.InputChanged:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseMovement or Input_Event.UserInputType == Enum.UserInputType.Touch then 
            Menu_Drag_Input = Input_Event 
        end
    end)

    User_Input_Service.InputEnded:Connect(function(Input_Event)
        if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then 
            Is_Dragging_Menu = false 
        end
    end)

    Run_Service.RenderStepped:Connect(function()
        if Is_Dragging_Menu and Menu_Drag_Input then
            local Delta_Pos = Menu_Drag_Input.Position - Menu_Drag_Start_Pos
            Menu_Target_Pos = UDim2.new(Menu_Start_Pos.X.Scale, Menu_Start_Pos.X.Offset + (Delta_Pos.X / UI_Scale_Modifier.Scale), Menu_Start_Pos.Y.Scale, Menu_Start_Pos.Y.Offset + (Delta_Pos.Y / UI_Scale_Modifier.Scale))
        end
        Main_Background.Position = Main_Background.Position:Lerp(Menu_Target_Pos, 0.25)
    end)

    local Window_Context = { Tabs = {}, Active_Tab = nil }

    function Window_Context:Tab_Create(Tab_Name, Icon_Id, Is_Hidden)
        local Tab_Data = {}

        local Tab_Button = Instance.new("TextButton")
        Tab_Button.Size = UDim2.new(1, 0, 0, 32)
        Apply_Theme(Tab_Button, "BackgroundColor3", "Element_Hover_Background")
        Tab_Button.BackgroundTransparency = 1
        Tab_Button.Text = ""
        Tab_Button.AutoButtonColor = false
        if not Is_Hidden then
            Tab_Button.Parent = Tab_Scrolling_Frame
        end
        
        local Button_Corner = Instance.new("UICorner")
        Button_Corner.CornerRadius = UDim.new(0, 4)
        Button_Corner.Parent = Tab_Button

        local Tab_Label = Instance.new("TextLabel")
        Tab_Label.BackgroundTransparency = 1
        Tab_Label.Text = Tab_Name
        Apply_Theme(Tab_Label, "TextColor3", "Text_Dark_Color")
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
            Apply_Theme(Tab_Icon, "ImageColor3", "Text_Dark_Color")
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
        Apply_Theme(Tab_Indicator, "BackgroundColor3", "Accent_Color")
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
        Apply_Theme(Page_Scrolling_Frame, "ScrollBarImageColor3", "Accent_Color")
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

        local Is_Updating_Canvas = false
        local function Update_Canvas_Size()
            if Is_Updating_Canvas then return end
            Is_Updating_Canvas = true
            task.defer(function()
                local Max_Column_Height = math.max(Left_Column_Layout.AbsoluteContentSize.Y, Right_Column_Layout.AbsoluteContentSize.Y)
                Page_Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, Max_Column_Height + 20)
                if not Is_Hidden then
                    Tab_Scrolling_Frame.CanvasSize = UDim2.new(0, 0, 0, Tab_Layout.AbsoluteContentSize.Y + 10)
                end
                Is_Updating_Canvas = false
            end)
        end

        Left_Column_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas_Size)
        Right_Column_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas_Size)
        if not Is_Hidden then
            Tab_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas_Size)
        end
        Update_Canvas_Size()

        function Tab_Data:Activate()
            if Window_Context.Active_Tab == Tab_Data then return end
            if Window_Context.Active_Tab then
                Animate_Element(Window_Context.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.3)
                pcall(function() Window_Context.Active_Tab.Lbl.TextColor3 = UI_Colors.Text_Dark_Color end)
                if Window_Context.Active_Tab.Icon then pcall(function() Window_Context.Active_Tab.Icon.ImageColor3 = UI_Colors.Text_Dark_Color end) end
                Animate_Element(Window_Context.Active_Tab.Ind, {Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.3)
                Window_Context.Active_Tab.Page.Visible = false
            end
            Window_Context.Active_Tab = Tab_Data
            Page_Scrolling_Frame.Visible = true
            Animate_Element(Tab_Button, {BackgroundTransparency = 0.11}, 0.3)
            pcall(function() Tab_Label.TextColor3 = UI_Colors.Text_White_Color end)
            if Tab_Data.Icon then pcall(function() Tab_Data.Icon.ImageColor3 = UI_Colors.Accent_Color end) end
            Animate_Element(Tab_Indicator, {Size = UDim2.new(0, 2, 0, 16), Position = UDim2.new(0, 0, 0.5, -8)}, 0.3)
        end

        Tab_Button.MouseButton1Click:Connect(function() Tab_Data:Activate() end)

        Tab_Data.Btn = Tab_Button
        Tab_Data.Lbl = Tab_Label
        Tab_Data.Ind = Tab_Indicator
        Tab_Data.Page = Page_Scrolling_Frame

        if not Is_Hidden then
            table.insert(Window_Context.Tabs, Tab_Data)
            if #Window_Context.Tabs == 1 then Tab_Data:Activate() end
        end

        local function Element_Injector(Target_Container)
            local Element_Api = {}

            function Element_Api:Label_Create(Name_String, Initial_Value)
                local Label_Background = Instance.new("Frame")
                Label_Background.Size = UDim2.new(1, 0, 0, 26)
                Apply_Theme(Label_Background, "BackgroundColor3", "Element_Background")
                Label_Background.BackgroundTransparency = 0.21
                Label_Background.Parent = Target_Container

                local Label_Corner = Instance.new("UICorner")
                Label_Corner.CornerRadius = UDim.new(0, 4)
                Label_Corner.Parent = Label_Background

                local Label_Stroke = Instance.new("UIStroke")
                Apply_Theme(Label_Stroke, "Color", "Border_Color")
                Label_Stroke.Parent = Label_Background

                local Title_Label = Instance.new("TextLabel")
                Title_Label.Size = UDim2.new(0.5, 0, 1, 0)
                Title_Label.Position = UDim2.new(0, 8, 0, 0)
                Title_Label.BackgroundTransparency = 1
                Title_Label.Text = Name_String
                Apply_Theme(Title_Label, "TextColor3", "Text_Dark_Color")
                Title_Label.TextSize = 12
                Title_Label.Font = Main_Font
                Title_Label.TextXAlignment = Enum.TextXAlignment.Left
                Title_Label.Parent = Label_Background

                local Value_Label = Instance.new("TextLabel")
                Value_Label.Size = UDim2.new(0.5, -8, 1, 0)
                Value_Label.Position = UDim2.new(0.5, 0, 0, 0)
                Value_Label.BackgroundTransparency = 1
                Value_Label.Text = Initial_Value or ""
                Apply_Theme(Value_Label, "TextColor3", "Text_White_Color")
                Value_Label.TextSize = 12
                Value_Label.Font = Bold_Font
                Value_Label.TextXAlignment = Enum.TextXAlignment.Right
                Value_Label.Parent = Label_Background

                local Label_Api = {}
                function Label_Api:Set(Text_Value)
                    Value_Label.Text = tostring(Text_Value)
                end
                return Label_Api
            end

            function Element_Api:Subtext_Create(Text_String)
                local Subtext_Label = Instance.new("TextLabel")
                Subtext_Label.Size = UDim2.new(1, -10, 0, 14)
                Subtext_Label.BackgroundTransparency = 1
                Subtext_Label.Text = Text_String
                Apply_Theme(Subtext_Label, "TextColor3", "Text_Dark_Color")
                Subtext_Label.TextSize = 11
                Subtext_Label.Font = Main_Font
                Subtext_Label.TextXAlignment = Enum.TextXAlignment.Left
                Subtext_Label.Parent = Target_Container
            end

            function Element_Api:Toggle_Create(Name_String, Flag_Name, Default_Value, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or (Default_Value or false)

                local Toggle_Button = Instance.new("TextButton")
                Toggle_Button.Size = UDim2.new(1, 0, 0, 16)
                Toggle_Button.BackgroundTransparency = 1
                Toggle_Button.Text = ""
                Toggle_Button.Parent = Target_Container

                local Checkbox_Frame = Instance.new("Frame")
                Checkbox_Frame.Size = UDim2.new(0, 14, 0, 14)
                Checkbox_Frame.Position = UDim2.new(0, 2, 0.5, -7)
                Apply_Theme(Checkbox_Frame, "BackgroundColor3", Library_Api.Flags[Flag_Name] and "Accent_Color" or "Element_Background")
                Checkbox_Frame.BackgroundTransparency = 0.21
                Checkbox_Frame.Parent = Toggle_Button
                
                local Checkbox_Corner = Instance.new("UICorner")
                Checkbox_Corner.CornerRadius = UDim.new(0, 3)
                Checkbox_Corner.Parent = Checkbox_Frame
                
                local Checkbox_Stroke = Instance.new("UIStroke")
                Apply_Theme(Checkbox_Stroke, "Color", Library_Api.Flags[Flag_Name] and "Accent_Color" or "Border_Color")
                Checkbox_Stroke.Parent = Checkbox_Frame

                local Toggle_Label = Instance.new("TextLabel")
                Toggle_Label.Size = UDim2.new(1, -26, 1, 0)
                Toggle_Label.Position = UDim2.new(0, 24, 0, 0)
                Toggle_Label.BackgroundTransparency = 1
                Toggle_Label.Text = Name_String
                Apply_Theme(Toggle_Label, "TextColor3", Library_Api.Flags[Flag_Name] and "Text_White_Color" or "Text_Dark_Color")
                Toggle_Label.TextSize = 12
                Toggle_Label.Font = Main_Font
                Toggle_Label.TextXAlignment = Enum.TextXAlignment.Left
                Toggle_Label.Parent = Toggle_Button

                Toggle_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    if not Library_Api.Flags[Flag_Name] then pcall(function() Checkbox_Stroke.Color = UI_Colors.Border_Light_Color end) end
                end)
                Toggle_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Library_Api.Flags[Flag_Name] then pcall(function() Checkbox_Stroke.Color = UI_Colors.Border_Color end) end
                end)

                Toggle_Button.MouseButton1Click:Connect(function()
                    Library_Api.Flags[Flag_Name] = not Library_Api.Flags[Flag_Name]
                    local New_State = Library_Api.Flags[Flag_Name]
                    Apply_Theme(Checkbox_Frame, "BackgroundColor3", New_State and "Accent_Color" or "Element_Background")
                    Apply_Theme(Checkbox_Stroke, "Color", New_State and "Accent_Color" or "Border_Color")
                    Apply_Theme(Toggle_Label, "TextColor3", New_State and "Text_White_Color" or "Text_Dark_Color")
                    if Callback_Func then task.spawn(Callback_Func, New_State) end
                end)
            end

            function Element_Api:Slider_Create(Name_String, Flag_Name, Min_Val, Max_Val, Default_Val, Step_Val, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or Snap_Value(Default_Val or Min_Val, Step_Val)

                local Slider_Frame = Instance.new("Frame")
                Slider_Frame.Size = UDim2.new(1, 0, 0, 36)
                Slider_Frame.BackgroundTransparency = 1
                Slider_Frame.Parent = Target_Container

                local Slider_Label = Instance.new("TextLabel")
                Slider_Label.Size = UDim2.new(1, -50, 0, 14)
                Slider_Label.Position = UDim2.new(0, 2, 0, 0)
                Slider_Label.BackgroundTransparency = 1
                Slider_Label.Text = Name_String
                Apply_Theme(Slider_Label, "TextColor3", "Text_White_Color")
                Slider_Label.TextSize = 12
                Slider_Label.Font = Main_Font
                Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Slider_Label.Parent = Slider_Frame

                local Value_Text_Box = Instance.new("TextBox")
                Value_Text_Box.Size = UDim2.new(0, 40, 0, 14)
                Value_Text_Box.Position = UDim2.new(1, -42, 0, 0)
                Value_Text_Box.BackgroundTransparency = 1
                Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag_Name], Step_Val)
                Apply_Theme(Value_Text_Box, "TextColor3", "Text_White_Color")
                Value_Text_Box.TextSize = 12
                Value_Text_Box.Font = Main_Font
                Value_Text_Box.TextXAlignment = Enum.TextXAlignment.Right
                Value_Text_Box.ClearTextOnFocus = false
                Value_Text_Box.Parent = Slider_Frame

                local Slider_Background = Instance.new("TextButton")
                Slider_Background.Size = UDim2.new(1, -4, 0, 6)
                Slider_Background.Position = UDim2.new(0, 2, 0, 24)
                Apply_Theme(Slider_Background, "BackgroundColor3", "Element_Background")
                Slider_Background.BackgroundTransparency = 0.21
                Slider_Background.Text = ""
                Slider_Background.AutoButtonColor = false
                Slider_Background.Parent = Slider_Frame
                
                local Slider_Background_Corner = Instance.new("UICorner")
                Slider_Background_Corner.CornerRadius = UDim.new(0, 3)
                Slider_Background_Corner.Parent = Slider_Background
                
                local Slider_Background_Stroke = Instance.new("UIStroke")
                Apply_Theme(Slider_Background_Stroke, "Color", "Border_Color")
                Slider_Background_Stroke.Parent = Slider_Background

                local Slider_Fill = Instance.new("Frame")
                local Initial_Percentage = (Library_Api.Flags[Flag_Name] - Min_Val) / (Max_Val - Min_Val)
                Slider_Fill.Size = UDim2.new(Initial_Percentage, 0, 1, 0)
                Apply_Theme(Slider_Fill, "BackgroundColor3", "Accent_Color")
                Slider_Fill.Parent = Slider_Background
                
                local Slider_Fill_Corner = Instance.new("UICorner")
                Slider_Fill_Corner.CornerRadius = UDim.new(0, 3)
                Slider_Fill_Corner.Parent = Slider_Fill

                local Slider_Knob = Instance.new("Frame")
                Slider_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Slider_Knob.Size = UDim2.new(0, 10, 0, 10)
                Slider_Knob.Position = UDim2.new(Initial_Percentage, 0, 0.5, 0)
                Apply_Theme(Slider_Knob, "BackgroundColor3", "Text_White_Color")
                Slider_Knob.ZIndex = 2
                Slider_Knob.Parent = Slider_Background
                local Slider_Knob_Corner = Instance.new("UICorner"); Slider_Knob_Corner.CornerRadius = UDim.new(1, 0); Slider_Knob_Corner.Parent = Slider_Knob
                local Slider_Knob_Stroke = Instance.new("UIStroke"); Apply_Theme(Slider_Knob_Stroke, "Color", "Border_Color"); Slider_Knob_Stroke.Parent = Slider_Knob

                Slider_Background.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    pcall(function() Slider_Background_Stroke.Color = UI_Colors.Border_Light_Color end)
                end)
                Slider_Background.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    pcall(function() Slider_Background_Stroke.Color = UI_Colors.Border_Color end)
                end)

                local Is_Sliding = false

                local function Set_Slider_Value(New_Value)
                    local Clamped_Value = math.clamp(New_Value, Min_Val, Max_Val)
                    local Snapped_Value = Snap_Value(Clamped_Value, Step_Val)
                    if Library_Api.Flags[Flag_Name] ~= Snapped_Value then
                        Library_Api.Flags[Flag_Name] = Snapped_Value
                        local Calc_Percentage = (Snapped_Value - Min_Val) / (Max_Val - Min_Val)
                        Animate_Element(Slider_Fill, {Size = UDim2.new(Calc_Percentage, 0, 1, 0)}, 0.15)
                        Animate_Element(Slider_Knob, {Position = UDim2.new(Calc_Percentage, 0, 0.5, 0)}, 0.15)
                        Value_Text_Box.Text = Format_Value(Snapped_Value, Step_Val)
                        if Callback_Func then task.spawn(Callback_Func, Snapped_Value) end
                    end
                end

                Slider_Background.InputBegan:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding = true
                        local Calc_Percentage = math.clamp((Input_Event.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
                        Set_Slider_Value(Min_Val + ((Max_Val - Min_Val) * Calc_Percentage))
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then 
                        Is_Sliding = false 
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input_Event)
                    if Is_Sliding and (Input_Event.UserInputType == Enum.UserInputType.MouseMovement or Input_Event.UserInputType == Enum.UserInputType.Touch) then 
                        local Calc_Percentage = math.clamp((Input_Event.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
                        Set_Slider_Value(Min_Val + ((Max_Val - Min_Val) * Calc_Percentage))
                    end
                end)

                Value_Text_Box.FocusLost:Connect(function()
                    local Input_Value = tonumber(Value_Text_Box.Text)
                    if Input_Value then
                        Set_Slider_Value(Input_Value)
                    else
                        Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag_Name], Step_Val)
                    end
                end)
            end

            function Element_Api:RangeSlider_Create(Name_String, Flag_Name, Min_Val, Max_Val, Default_Min, Default_Max, Step_Val, Tooltip_Text, Callback_Func)
                if not Library_Api.Flags[Flag_Name] then
                    Library_Api.Flags[Flag_Name] = {Min = Snap_Value(Default_Min or Min_Val, Step_Val), Max = Snap_Value(Default_Max or Max_Val, Step_Val)}
                end

                local Range_Slider_Frame = Instance.new("Frame")
                Range_Slider_Frame.Size = UDim2.new(1, 0, 0, 36)
                Range_Slider_Frame.BackgroundTransparency = 1
                Range_Slider_Frame.Parent = Target_Container

                local Range_Slider_Label = Instance.new("TextLabel")
                Range_Slider_Label.Size = UDim2.new(1, -80, 0, 14)
                Range_Slider_Label.Position = UDim2.new(0, 2, 0, 0)
                Range_Slider_Label.BackgroundTransparency = 1
                Range_Slider_Label.Text = Name_String
                Apply_Theme(Range_Slider_Label, "TextColor3", "Text_White_Color")
                Range_Slider_Label.TextSize = 12
                Range_Slider_Label.Font = Main_Font
                Range_Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Range_Slider_Label.Parent = Range_Slider_Frame

                local Value_Label = Instance.new("TextLabel")
                Value_Label.Size = UDim2.new(0, 80, 0, 14)
                Value_Label.Position = UDim2.new(1, -82, 0, 0)
                Value_Label.BackgroundTransparency = 1
                Value_Label.Text = Format_Value(Library_Api.Flags[Flag_Name].Min, Step_Val) .. " - " .. Format_Value(Library_Api.Flags[Flag_Name].Max, Step_Val)
                Apply_Theme(Value_Label, "TextColor3", "Text_White_Color")
                Value_Label.TextSize = 12
                Value_Label.Font = Main_Font
                Value_Label.TextXAlignment = Enum.TextXAlignment.Right
                Value_Label.Parent = Range_Slider_Frame

                local Range_Slider_Background = Instance.new("TextButton")
                Range_Slider_Background.Size = UDim2.new(1, -4, 0, 6)
                Range_Slider_Background.Position = UDim2.new(0, 2, 0, 24)
                Apply_Theme(Range_Slider_Background, "BackgroundColor3", "Element_Background")
                Range_Slider_Background.BackgroundTransparency = 0.21
                Range_Slider_Background.Text = ""
                Range_Slider_Background.AutoButtonColor = false
                Range_Slider_Background.Parent = Range_Slider_Frame
                
                local Range_Slider_Background_Corner = Instance.new("UICorner")
                Range_Slider_Background_Corner.CornerRadius = UDim.new(0, 3)
                Range_Slider_Background_Corner.Parent = Range_Slider_Background
                
                local Range_Slider_Background_Stroke = Instance.new("UIStroke")
                Apply_Theme(Range_Slider_Background_Stroke, "Color", "Border_Color")
                Range_Slider_Background_Stroke.Parent = Range_Slider_Background

                local Range_Slider_Fill = Instance.new("Frame")
                Apply_Theme(Range_Slider_Fill, "BackgroundColor3", "Accent_Color")
                Range_Slider_Fill.Parent = Range_Slider_Background
                
                local Range_Slider_Fill_Corner = Instance.new("UICorner")
                Range_Slider_Fill_Corner.CornerRadius = UDim.new(0, 3)
                Range_Slider_Fill_Corner.Parent = Range_Slider_Fill

                local Min_Range_Knob = Instance.new("Frame")
                Min_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Min_Range_Knob.Size = UDim2.new(0, 10, 0, 10)
                Apply_Theme(Min_Range_Knob, "BackgroundColor3", "Text_White_Color")
                Min_Range_Knob.ZIndex = 2
                Min_Range_Knob.Parent = Range_Slider_Background
                local Min_Range_Knob_Corner = Instance.new("UICorner"); Min_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Min_Range_Knob_Corner.Parent = Min_Range_Knob
                local Min_Range_Knob_Stroke = Instance.new("UIStroke"); Apply_Theme(Min_Range_Knob_Stroke, "Color", "Border_Color"); Min_Range_Knob_Stroke.Parent = Min_Range_Knob

                local Max_Range_Knob = Instance.new("Frame")
                Max_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Max_Range_Knob.Size = UDim2.new(0, 10, 0, 10)
                Apply_Theme(Max_Range_Knob, "BackgroundColor3", "Text_White_Color")
                Max_Range_Knob.ZIndex = 2
                Max_Range_Knob.Parent = Range_Slider_Background
                local Max_Range_Knob_Corner = Instance.new("UICorner"); Max_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Max_Range_Knob_Corner.Parent = Max_Range_Knob
                local Max_Range_Knob_Stroke = Instance.new("UIStroke"); Apply_Theme(Max_Range_Knob_Stroke, "Color", "Border_Color"); Max_Range_Knob_Stroke.Parent = Max_Range_Knob

                local function Update_Range_Slider_Visuals()
                    local Min_Percentage = (Library_Api.Flags[Flag_Name].Min - Min_Val) / (Max_Val - Min_Val)
                    local Max_Percentage = (Library_Api.Flags[Flag_Name].Max - Min_Val) / (Max_Val - Min_Val)
                    Animate_Element(Range_Slider_Fill, {Position = UDim2.new(Min_Percentage, 0, 0, 0), Size = UDim2.new(Max_Percentage - Min_Percentage, 0, 1, 0)}, 0.15)
                    Animate_Element(Min_Range_Knob, {Position = UDim2.new(Min_Percentage, 0, 0.5, 0)}, 0.15)
                    Animate_Element(Max_Range_Knob, {Position = UDim2.new(Max_Percentage, 0, 0.5, 0)}, 0.15)
                    Value_Label.Text = Format_Value(Library_Api.Flags[Flag_Name].Min, Step_Val) .. " - " .. Format_Value(Library_Api.Flags[Flag_Name].Max, Step_Val)
                end
                Update_Range_Slider_Visuals()

                Range_Slider_Background.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    pcall(function() Range_Slider_Background_Stroke.Color = UI_Colors.Border_Light_Color end)
                end)
                Range_Slider_Background.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    pcall(function() Range_Slider_Background_Stroke.Color = UI_Colors.Border_Color end)
                end)

                local Is_Sliding_Min = false
                local Is_Sliding_Max = false

                Range_Slider_Background.InputBegan:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
                        local Mouse_X = Input_Event.Position.X
                        local Min_Percentage = (Library_Api.Flags[Flag_Name].Min - Min_Val) / (Max_Val - Min_Val)
                        local Max_Percentage = (Library_Api.Flags[Flag_Name].Max - Min_Val) / (Max_Val - Min_Val)
                        local Min_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Min_Percentage)
                        local Max_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Max_Percentage)
                        
                        if math.abs(Mouse_X - Min_Knob_Position) < math.abs(Mouse_X - Max_Knob_Position) then
                            Is_Sliding_Min = true
                        else
                            Is_Sliding_Max = true
                        end
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then 
                        Is_Sliding_Min = false
                        Is_Sliding_Max = false
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input_Event)
                    if (Is_Sliding_Min or Is_Sliding_Max) and (Input_Event.UserInputType == Enum.UserInputType.MouseMovement or Input_Event.UserInputType == Enum.UserInputType.Touch) then 
                        local Calc_Percentage = math.clamp((Input_Event.Position.X - Range_Slider_Background.AbsolutePosition.X) / Range_Slider_Background.AbsoluteSize.X, 0, 1)
                        local Calculated_Value = Snap_Value(Min_Val + ((Max_Val - Min_Val) * Calc_Percentage), Step_Val)
                        
                        if Is_Sliding_Min then
                            if Calculated_Value <= Library_Api.Flags[Flag_Name].Max then
                                Library_Api.Flags[Flag_Name].Min = Calculated_Value
                            else
                                Library_Api.Flags[Flag_Name].Min = Library_Api.Flags[Flag_Name].Max
                            end
                        elseif Is_Sliding_Max then
                            if Calculated_Value >= Library_Api.Flags[Flag_Name].Min then
                                Library_Api.Flags[Flag_Name].Max = Calculated_Value
                            else
                                Library_Api.Flags[Flag_Name].Max = Library_Api.Flags[Flag_Name].Min
                            end
                        end
                        Update_Range_Slider_Visuals()
                        if Callback_Func then task.spawn(Callback_Func, Library_Api.Flags[Flag_Name]) end
                    end
                end)
            end

            function Element_Api:Textbox_Create(Name_String, Flag_Name, Default_Value, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or (Default_Value or "")

                local Textbox_Frame = Instance.new("Frame")
                Textbox_Frame.Size = UDim2.new(1, 0, 0, 36)
                Textbox_Frame.BackgroundTransparency = 1
                Textbox_Frame.Parent = Target_Container

                local Textbox_Label = Instance.new("TextLabel")
                Textbox_Label.Size = UDim2.new(1, -120, 1, 0)
                Textbox_Label.Position = UDim2.new(0, 2, 0, 0)
                Textbox_Label.BackgroundTransparency = 1
                Textbox_Label.Text = Name_String
                Apply_Theme(Textbox_Label, "TextColor3", "Text_White_Color")
                Textbox_Label.TextSize = 12
                Textbox_Label.Font = Main_Font
                Textbox_Label.TextXAlignment = Enum.TextXAlignment.Left
                Textbox_Label.Parent = Textbox_Frame

                local Textbox_Input_Background = Instance.new("Frame")
                Textbox_Input_Background.Size = UDim2.new(0, 110, 0, 24)
                Textbox_Input_Background.Position = UDim2.new(1, -112, 0.5, -12)
                Apply_Theme(Textbox_Input_Background, "BackgroundColor3", "Element_Background")
                Textbox_Input_Background.BackgroundTransparency = 0.21
                Textbox_Input_Background.Parent = Textbox_Frame
                
                local Textbox_Input_Background_Corner = Instance.new("UICorner")
                Textbox_Input_Background_Corner.CornerRadius = UDim.new(0, 4)
                Textbox_Input_Background_Corner.Parent = Textbox_Input_Background
                
                local Textbox_Input_Background_Stroke = Instance.new("UIStroke")
                Apply_Theme(Textbox_Input_Background_Stroke, "Color", "Border_Color")
                Textbox_Input_Background_Stroke.Parent = Textbox_Input_Background

                local Input_Text_Box = Instance.new("TextBox")
                Input_Text_Box.Size = UDim2.new(1, -10, 1, 0)
                Input_Text_Box.Position = UDim2.new(0, 5, 0, 0)
                Input_Text_Box.BackgroundTransparency = 1
                Input_Text_Box.Text = Library_Api.Flags[Flag_Name]
                Apply_Theme(Input_Text_Box, "TextColor3", "Text_Dark_Color")
                Input_Text_Box.TextSize = 12
                Input_Text_Box.Font = Main_Font
                Input_Text_Box.ClearTextOnFocus = false
                Input_Text_Box.TextXAlignment = Enum.TextXAlignment.Left
                Input_Text_Box.ClipsDescendants = true
                Input_Text_Box.Parent = Textbox_Input_Background

                Input_Text_Box.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    pcall(function() Textbox_Input_Background_Stroke.Color = UI_Colors.Border_Light_Color end)
                end)
                Input_Text_Box.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    pcall(function() Textbox_Input_Background_Stroke.Color = UI_Colors.Border_Color end)
                end)

                Input_Text_Box.Focused:Connect(function()
                    pcall(function() Textbox_Input_Background_Stroke.Color = UI_Colors.Accent_Color end)
                    pcall(function() Input_Text_Box.TextColor3 = UI_Colors.Text_White_Color end)
                end)

                Input_Text_Box.FocusLost:Connect(function()
                    pcall(function() Textbox_Input_Background_Stroke.Color = UI_Colors.Border_Color end)
                    pcall(function() Input_Text_Box.TextColor3 = UI_Colors.Text_Dark_Color end)
                    Library_Api.Flags[Flag_Name] = Input_Text_Box.Text
                    if Callback_Func then task.spawn(Callback_Func, Input_Text_Box.Text) end
                end)
            end

            function Element_Api:Keybind_Create(Name_String, Flag_Name, Default_Value, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or (Default_Value or Enum.KeyCode.Unknown)
                if Library_Api.Flags[Flag_Name] ~= Enum.KeyCode.Unknown then
                    Active_Keybinds[Name_String] = Library_Api.Flags[Flag_Name].Name
                    Refresh_Keybinds_List()
                end
                local Is_Listening = false

                local Keybind_Frame = Instance.new("Frame")
                Keybind_Frame.Size = UDim2.new(1, 0, 0, 30)
                Keybind_Frame.BackgroundTransparency = 1
                Keybind_Frame.Parent = Target_Container

                local Keybind_Icon = Instance.new("ImageLabel")
                Keybind_Icon.Size = UDim2.new(0, 18, 0, 18)
                Keybind_Icon.Position = UDim2.new(0, 6, 0.5, -9)
                Keybind_Icon.BackgroundTransparency = 1
                Keybind_Icon.Image = "rbxassetid://104798010403294"
                Apply_Theme(Keybind_Icon, "ImageColor3", "Text_White_Color")
                Keybind_Icon.Parent = Keybind_Frame

                local Keybind_Label = Instance.new("TextLabel")
                Keybind_Label.Size = UDim2.new(1, -100, 1, 0)
                Keybind_Label.Position = UDim2.new(0, 28, 0, 0)
                Keybind_Label.BackgroundTransparency = 1
                Keybind_Label.Text = Name_String
                Apply_Theme(Keybind_Label, "TextColor3", "Text_White_Color")
                Keybind_Label.TextSize = 12
                Keybind_Label.Font = Main_Font
                Keybind_Label.TextXAlignment = Enum.TextXAlignment.Left
                Keybind_Label.Parent = Keybind_Frame

                local Keybind_Button = Instance.new("TextButton")
                Keybind_Button.Size = UDim2.new(0, 70, 0, 22)
                Keybind_Button.Position = UDim2.new(1, -74, 0.5, -11)
                Apply_Theme(Keybind_Button, "BackgroundColor3", "Element_Background")
                Keybind_Button.BackgroundTransparency = 0.21
                Keybind_Button.Text = Library_Api.Flags[Flag_Name] == Enum.KeyCode.Unknown and "[ None ]" or "[ " .. Library_Api.Flags[Flag_Name].Name .. " ]"
                Apply_Theme(Keybind_Button, "TextColor3", "Text_Dark_Color")
                Keybind_Button.TextSize = 11
                Keybind_Button.Font = Bold_Font
                Keybind_Button.AutoButtonColor = false
                Keybind_Button.Parent = Keybind_Frame

                local Keybind_Button_Corner = Instance.new("UICorner")
                Keybind_Button_Corner.CornerRadius = UDim.new(0, 4)
                Keybind_Button_Corner.Parent = Keybind_Button

                local Keybind_Button_Stroke = Instance.new("UIStroke")
                Apply_Theme(Keybind_Button_Stroke, "Color", "Border_Color")
                Keybind_Button_Stroke.Parent = Keybind_Button

                Keybind_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    if not Is_Listening then pcall(function() Keybind_Button_Stroke.Color = UI_Colors.Border_Light_Color end) end
                end)
                Keybind_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Listening then pcall(function() Keybind_Button_Stroke.Color = UI_Colors.Border_Color end) end
                end)

                Keybind_Button.MouseButton1Click:Connect(function()
                    Is_Listening = true
                    Keybind_Button.Text = "[ ... ]"
                    pcall(function() Keybind_Button_Stroke.Color = UI_Colors.Accent_Color end)
                    pcall(function() Keybind_Button.TextColor3 = UI_Colors.Text_White_Color end)
                end)

                User_Input_Service.InputBegan:Connect(function(Input_Event)
                    if Is_Listening then
                        if Input_Event.KeyCode ~= Enum.KeyCode.Unknown and Input_Event.KeyCode ~= Enum.KeyCode.Escape then
                            Library_Api.Flags[Flag_Name] = Input_Event.KeyCode
                            Keybind_Button.Text = "[ " .. Input_Event.KeyCode.Name .. " ]"
                            Active_Keybinds[Name_String] = Input_Event.KeyCode.Name
                        elseif Input_Event.KeyCode == Enum.KeyCode.Escape then
                            Library_Api.Flags[Flag_Name] = Enum.KeyCode.Unknown
                            Keybind_Button.Text = "[ None ]"
                            Active_Keybinds[Name_String] = nil
                        end
                        Is_Listening = false
                        Refresh_Keybinds_List()
                        pcall(function() Keybind_Button_Stroke.Color = UI_Colors.Border_Color end)
                        pcall(function() Keybind_Button.TextColor3 = UI_Colors.Text_Dark_Color end)
                        if Callback_Func then task.spawn(Callback_Func, Library_Api.Flags[Flag_Name]) end
                    else
                        if Input_Event.KeyCode == Library_Api.Flags[Flag_Name] and Input_Event.KeyCode ~= Enum.KeyCode.Unknown then
                            if Callback_Func then task.spawn(Callback_Func, Library_Api.Flags[Flag_Name]) end
                        end
                    end
                end)
            end

            function Element_Api:Dropdown_Create(Name_String, Flag_Name, Options_Table, Default_Value, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or (Default_Value or Options_Table[1])
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
                Dropdown_Label.Text = Name_String
                Apply_Theme(Dropdown_Label, "TextColor3", "Text_White_Color")
                Dropdown_Label.TextSize = 12
                Dropdown_Label.Font = Main_Font
                Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown_Label.Parent = Dropdown_Frame

                local Dropdown_Main_Button = Instance.new("TextButton")
                Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 24)
                Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 20)
                Apply_Theme(Dropdown_Main_Button, "BackgroundColor3", "Element_Background")
                Dropdown_Main_Button.BackgroundTransparency = 0.21
                Dropdown_Main_Button.Text = ""
                Dropdown_Main_Button.AutoButtonColor = false
                Dropdown_Main_Button.Parent = Dropdown_Frame
                
                local Dropdown_Main_Button_Corner = Instance.new("UICorner")
                Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button
                
                local Dropdown_Main_Button_Stroke = Instance.new("UIStroke")
                Apply_Theme(Dropdown_Main_Button_Stroke, "Color", "Border_Color")
                Dropdown_Main_Button_Stroke.Parent = Dropdown_Main_Button

                local Selected_Option_Label = Instance.new("TextLabel")
                Selected_Option_Label.Size = UDim2.new(1, -30, 1, 0)
                Selected_Option_Label.Position = UDim2.new(0, 8, 0, 0)
                Selected_Option_Label.BackgroundTransparency = 1
                Selected_Option_Label.Text = Library_Api.Flags[Flag_Name]
                Apply_Theme(Selected_Option_Label, "TextColor3", "Text_Dark_Color")
                Selected_Option_Label.TextSize = 12
                Selected_Option_Label.Font = Main_Font
                Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                Selected_Option_Label.Parent = Dropdown_Main_Button

                local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
                Dropdown_Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Dropdown_Arrow_Icon.Position = UDim2.new(1, -22, 0.5, -7)
                Dropdown_Arrow_Icon.BackgroundTransparency = 1
                Dropdown_Arrow_Icon.Image = "rbxassetid://6031090656"
                Apply_Theme(Dropdown_Arrow_Icon, "ImageColor3", "Text_Dark_Color")
                Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button

                local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
                Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
                Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 48)
                Apply_Theme(Dropdown_Option_List_Frame, "BackgroundColor3", "Element_Background")
                Dropdown_Option_List_Frame.BackgroundTransparency = 0.21
                Dropdown_Option_List_Frame.BorderSizePixel = 0
                Dropdown_Option_List_Frame.ScrollBarThickness = 2
                Apply_Theme(Dropdown_Option_List_Frame, "ScrollBarImageColor3", "Accent_Color")
                Dropdown_Option_List_Frame.ClipsDescendants = true
                Dropdown_Option_List_Frame.Parent = Dropdown_Frame
                
                local Dropdown_Option_List_Corner = Instance.new("UICorner")
                Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame
                
                local Dropdown_Option_List_Stroke = Instance.new("UIStroke")
                Apply_Theme(Dropdown_Option_List_Stroke, "Color", "Border_Color")
                Dropdown_Option_List_Stroke.Transparency = 1
                Dropdown_Option_List_Stroke.Parent = Dropdown_Option_List_Frame

                local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
                Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

                local function Toggle_Dropdown_State()
                    Is_Dropdown_Open = not Is_Dropdown_Open
                    local Active_Child_Count = 0
                    for _, Child_Element in ipairs(Dropdown_Option_List_Frame:GetChildren()) do if Child_Element:IsA("TextButton") then Active_Child_Count = Active_Child_Count + 1 end end
                    local Max_List_Height = math.min(Active_Child_Count * 24, 120)
                    local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
                    pcall(function() Dropdown_Main_Button_Stroke.Color = Is_Dropdown_Open and UI_Colors.Accent_Color or UI_Colors.Border_Color end)
                    Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0}, 0.3)
                    pcall(function() Dropdown_Arrow_Icon.ImageColor3 = Is_Dropdown_Open and UI_Colors.Accent_Color or UI_Colors.Text_Dark_Color end)
                    Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.3)
                    Animate_Element(Dropdown_Option_List_Stroke, {Transparency = Is_Dropdown_Open and 0 or 1}, 0.3)
                    Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 46 + Target_List_Height + (Is_Dropdown_Open and 4 or 0))}, 0.3)
                end

                Dropdown_Main_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    if not Is_Dropdown_Open then pcall(function() Dropdown_Main_Button_Stroke.Color = UI_Colors.Border_Light_Color end) end
                end)
                Dropdown_Main_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Dropdown_Open then pcall(function() Dropdown_Main_Button_Stroke.Color = UI_Colors.Border_Color end) end
                end)
                Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

                local function Populate_Dropdown(Passed_Options)
                    for _, Child_Element in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child_Element:IsA("TextButton") then Child_Element:Destroy() end
                    end
                    for _, Current_Option in ipairs(Passed_Options) do
                        local Option_Button = Instance.new("TextButton")
                        Option_Button.Size = UDim2.new(1, 0, 0, 24)
                        Apply_Theme(Option_Button, "BackgroundColor3", "Element_Hover_Background")
                        Option_Button.BackgroundTransparency = 1
                        Option_Button.Text = ""
                        Option_Button.Parent = Dropdown_Option_List_Frame

                        local Option_Label = Instance.new("TextLabel")
                        Option_Label.Size = UDim2.new(1, -20, 1, 0)
                        Option_Label.Position = UDim2.new(0, 8, 0, 0)
                        Option_Label.BackgroundTransparency = 1
                        Option_Label.Text = Current_Option
                        Apply_Theme(Option_Label, "TextColor3", Library_Api.Flags[Flag_Name] == Current_Option and "Accent_Color" or "Text_Dark_Color")
                        Option_Label.TextSize = 12
                        Option_Label.Font = Main_Font
                        Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                        Option_Label.Parent = Option_Button

                        Option_Button.MouseEnter:Connect(function() 
                            Animate_Element(Option_Button, {BackgroundTransparency = 0.21}, 0.25)
                            if Library_Api.Flags[Flag_Name] ~= Current_Option then
                                pcall(function() Option_Label.TextColor3 = UI_Colors.Text_White_Color end) 
                            end
                        end)
                        Option_Button.MouseLeave:Connect(function()
                            Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.25)
                            if Library_Api.Flags[Flag_Name] ~= Current_Option then
                                pcall(function() Option_Label.TextColor3 = UI_Colors.Text_Dark_Color end)
                            end
                        end)

                        Option_Button.MouseButton1Click:Connect(function()
                            Library_Api.Flags[Flag_Name] = Current_Option
                            Selected_Option_Label.Text = Current_Option
                            Toggle_Dropdown_State()
                            for _, Child_Element in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                                if Child_Element:IsA("TextButton") then
                                    pcall(function() Child_Element:FindFirstChildOfClass("TextLabel").TextColor3 = UI_Colors.Text_Dark_Color end)
                                end
                            end
                            pcall(function() Option_Label.TextColor3 = UI_Colors.Accent_Color end)
                            if Callback_Func then task.spawn(Callback_Func, Current_Option) end
                        end)
                    end
                    Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Passed_Options * 24)
                end
                Populate_Dropdown(Options_Table)

                local Dropdown_Api = {}
                function Dropdown_Api:Refresh(New_Options)
                    Populate_Dropdown(New_Options)
                    local Found_Match = false
                    for _, Option_Item in ipairs(New_Options) do if Option_Item == Library_Api.Flags[Flag_Name] then Found_Match = true break end end
                    if not Found_Match then
                        Library_Api.Flags[Flag_Name] = New_Options[1] or ""
                        Selected_Option_Label.Text = Library_Api.Flags[Flag_Name]
                    end
                end
                return Dropdown_Api
            end

            function Element_Api:MultiDropdown_Create(Name_String, Flag_Name, Options_Table, Default_Value, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or (Default_Value or {})
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
                Dropdown_Label.Text = Name_String
                Apply_Theme(Dropdown_Label, "TextColor3", "Text_White_Color")
                Dropdown_Label.TextSize = 12
                Dropdown_Label.Font = Main_Font
                Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown_Label.Parent = Dropdown_Frame

                local Dropdown_Main_Button = Instance.new("TextButton")
                Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 24)
                Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 20)
                Apply_Theme(Dropdown_Main_Button, "BackgroundColor3", "Element_Background")
                Dropdown_Main_Button.BackgroundTransparency = 0.21
                Dropdown_Main_Button.Text = ""
                Dropdown_Main_Button.AutoButtonColor = false
                Dropdown_Main_Button.Parent = Dropdown_Frame
                
                local Dropdown_Main_Button_Corner = Instance.new("UICorner")
                Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button
                
                local Dropdown_Main_Button_Stroke = Instance.new("UIStroke")
                Apply_Theme(Dropdown_Main_Button_Stroke, "Color", "Border_Color")
                Dropdown_Main_Button_Stroke.Parent = Dropdown_Main_Button

                local Selected_Option_Label = Instance.new("TextLabel")
                Selected_Option_Label.Size = UDim2.new(1, -30, 1, 0)
                Selected_Option_Label.Position = UDim2.new(0, 8, 0, 0)
                Selected_Option_Label.BackgroundTransparency = 1
                
                local function Update_Selected_Text()
                    if #Library_Api.Flags[Flag_Name] == 0 then
                        Selected_Option_Label.Text = "None"
                    else
                        Selected_Option_Label.Text = table.concat(Library_Api.Flags[Flag_Name], ", ")
                    end
                end
                Update_Selected_Text()
                
                Apply_Theme(Selected_Option_Label, "TextColor3", "Text_Dark_Color")
                Selected_Option_Label.TextSize = 12
                Selected_Option_Label.Font = Main_Font
                Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                Selected_Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Selected_Option_Label.Parent = Dropdown_Main_Button

                local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
                Dropdown_Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Dropdown_Arrow_Icon.Position = UDim2.new(1, -22, 0.5, -7)
                Dropdown_Arrow_Icon.BackgroundTransparency = 1
                Dropdown_Arrow_Icon.Image = "rbxassetid://6031090656"
                Apply_Theme(Dropdown_Arrow_Icon, "ImageColor3", "Text_Dark_Color")
                Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button

                local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
                Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
                Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 48)
                Apply_Theme(Dropdown_Option_List_Frame, "BackgroundColor3", "Element_Background")
                Dropdown_Option_List_Frame.BackgroundTransparency = 0.21
                Dropdown_Option_List_Frame.BorderSizePixel = 0
                Dropdown_Option_List_Frame.ScrollBarThickness = 2
                Apply_Theme(Dropdown_Option_List_Frame, "ScrollBarImageColor3", "Accent_Color")
                Dropdown_Option_List_Frame.ClipsDescendants = true
                Dropdown_Option_List_Frame.Parent = Dropdown_Frame
                
                local Dropdown_Option_List_Corner = Instance.new("UICorner")
                Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 4)
                Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame
                
                local Dropdown_Option_List_Stroke = Instance.new("UIStroke")
                Apply_Theme(Dropdown_Option_List_Stroke, "Color", "Border_Color")
                Dropdown_Option_List_Stroke.Transparency = 1
                Dropdown_Option_List_Stroke.Parent = Dropdown_Option_List_Frame

                local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
                Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

                local function Toggle_Dropdown_State()
                    Is_Dropdown_Open = not Is_Dropdown_Open
                    local Active_Child_Count = 0
                    for _, Child_Element in ipairs(Dropdown_Option_List_Frame:GetChildren()) do if Child_Element:IsA("TextButton") then Active_Child_Count = Active_Child_Count + 1 end end
                    local Max_List_Height = math.min(Active_Child_Count * 24, 120)
                    local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
                    pcall(function() Dropdown_Main_Button_Stroke.Color = Is_Dropdown_Open and UI_Colors.Accent_Color or UI_Colors.Border_Color end)
                    Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0}, 0.3)
                    pcall(function() Dropdown_Arrow_Icon.ImageColor3 = Is_Dropdown_Open and UI_Colors.Accent_Color or UI_Colors.Text_Dark_Color end)
                    Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.3)
                    Animate_Element(Dropdown_Option_List_Stroke, {Transparency = Is_Dropdown_Open and 0 or 1}, 0.3)
                    Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 46 + Target_List_Height + (Is_Dropdown_Open and 4 or 0))}, 0.3)
                end

                Dropdown_Main_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    if not Is_Dropdown_Open then pcall(function() Dropdown_Main_Button_Stroke.Color = UI_Colors.Border_Light_Color end) end
                end)
                Dropdown_Main_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Dropdown_Open then pcall(function() Dropdown_Main_Button_Stroke.Color = UI_Colors.Border_Color end) end
                end)
                Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

                local function Populate_Dropdown(Passed_Options)
                    for _, Child_Element in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child_Element:IsA("TextButton") then Child_Element:Destroy() end
                    end
                    for _, Current_Option in ipairs(Passed_Options) do
                        local Option_Button = Instance.new("TextButton")
                        Option_Button.Size = UDim2.new(1, 0, 0, 24)
                        Apply_Theme(Option_Button, "BackgroundColor3", "Element_Hover_Background")
                        Option_Button.BackgroundTransparency = 1
                        Option_Button.Text = ""
                        Option_Button.Parent = Dropdown_Option_List_Frame

                        local Is_Selected = false
                        for _, Found_Val in pairs(Library_Api.Flags[Flag_Name]) do
                            if Found_Val == Current_Option then Is_Selected = true break end
                        end

                        local Option_Label = Instance.new("TextLabel")
                        Option_Label.Size = UDim2.new(1, -20, 1, 0)
                        Option_Label.Position = UDim2.new(0, 8, 0, 0)
                        Option_Label.BackgroundTransparency = 1
                        Option_Label.Text = Current_Option
                        Apply_Theme(Option_Label, "TextColor3", Is_Selected and "Accent_Color" or "Text_Dark_Color")
                        Option_Label.TextSize = 12
                        Option_Label.Font = Main_Font
                        Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                        Option_Label.Parent = Option_Button

                        Option_Button.MouseEnter:Connect(function() 
                            Animate_Element(Option_Button, {BackgroundTransparency = 0.21}, 0.25)
                            Is_Selected = table.find(Library_Api.Flags[Flag_Name], Current_Option) ~= nil
                            if not Is_Selected then
                                pcall(function() Option_Label.TextColor3 = UI_Colors.Text_White_Color end) 
                            end
                        end)
                        Option_Button.MouseLeave:Connect(function()
                            Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.25)
                            Is_Selected = table.find(Library_Api.Flags[Flag_Name], Current_Option) ~= nil
                            if not Is_Selected then
                                pcall(function() Option_Label.TextColor3 = UI_Colors.Text_Dark_Color end)
                            end
                        end)

                        Option_Button.MouseButton1Click:Connect(function()
                            local Index_Match = table.find(Library_Api.Flags[Flag_Name], Current_Option)
                            if Index_Match then
                                table.remove(Library_Api.Flags[Flag_Name], Index_Match)
                                pcall(function() Option_Label.TextColor3 = UI_Colors.Text_White_Color end)
                            else
                                table.insert(Library_Api.Flags[Flag_Name], Current_Option)
                                pcall(function() Option_Label.TextColor3 = UI_Colors.Accent_Color end)
                            end
                            Update_Selected_Text()
                            if Callback_Func then task.spawn(Callback_Func, Library_Api.Flags[Flag_Name]) end
                        end)
                    end
                    Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Passed_Options * 24)
                end
                Populate_Dropdown(Options_Table)

                local Dropdown_Api = {}
                function Dropdown_Api:Refresh(New_Options)
                    Populate_Dropdown(New_Options)
                end
                return Dropdown_Api
            end

            function Element_Api:ColorPicker_Create(Name_String, Flag_Name, Default_Value, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or (Default_Value or Color3.new(1, 1, 1))
                local Is_Color_Picker_Open = false
                local Hue_Val, Saturation_Val, Brightness_Val = Library_Api.Flags[Flag_Name]:ToHSV()

                local Color_Picker_Frame = Instance.new("Frame")
                Color_Picker_Frame.Size = UDim2.new(1, 0, 0, 24)
                Color_Picker_Frame.BackgroundTransparency = 1
                Color_Picker_Frame.ClipsDescendants = true
                Color_Picker_Frame.Parent = Target_Container

                local Color_Picker_Label = Instance.new("TextLabel")
                Color_Picker_Label.Size = UDim2.new(1, -40, 0, 24)
                Color_Picker_Label.Position = UDim2.new(0, 2, 0, 0)
                Color_Picker_Label.BackgroundTransparency = 1
                Color_Picker_Label.Text = Name_String
                Apply_Theme(Color_Picker_Label, "TextColor3", "Text_White_Color")
                Color_Picker_Label.TextSize = 12
                Color_Picker_Label.Font = Main_Font
                Color_Picker_Label.TextXAlignment = Enum.TextXAlignment.Left
                Color_Picker_Label.Parent = Color_Picker_Frame

                local Color_Preview_Button = Instance.new("TextButton")
                Color_Preview_Button.Size = UDim2.new(0, 24, 0, 14)
                Color_Preview_Button.Position = UDim2.new(1, -28, 0, 5)
                Color_Preview_Button.BackgroundColor3 = Library_Api.Flags[Flag_Name]
                Color_Preview_Button.Text = ""
                Color_Preview_Button.AutoButtonColor = false
                Color_Preview_Button.Parent = Color_Picker_Frame
                
                local Color_Preview_Button_Corner = Instance.new("UICorner")
                Color_Preview_Button_Corner.CornerRadius = UDim.new(0, 3)
                Color_Preview_Button_Corner.Parent = Color_Preview_Button
                
                local Color_Preview_Button_Stroke = Instance.new("UIStroke")
                Apply_Theme(Color_Preview_Button_Stroke, "Color", "Border_Color")
                Color_Preview_Button_Stroke.Parent = Color_Preview_Button

                local Expanded_Picker_Frame = Instance.new("Frame")
                Expanded_Picker_Frame.Size = UDim2.new(1, -4, 0, 190)
                Expanded_Picker_Frame.Position = UDim2.new(0, 2, 0, 28)
                Apply_Theme(Expanded_Picker_Frame, "BackgroundColor3", "Element_Background")
                Expanded_Picker_Frame.BackgroundTransparency = 0.21
                Expanded_Picker_Frame.Parent = Color_Picker_Frame
                
                local Expanded_Picker_Corner = Instance.new("UICorner")
                Expanded_Picker_Corner.CornerRadius = UDim.new(0, 4)
                Expanded_Picker_Corner.Parent = Expanded_Picker_Frame
                
                local Expanded_Picker_Stroke = Instance.new("UIStroke")
                Apply_Theme(Expanded_Picker_Stroke, "Color", "Border_Color")
                Expanded_Picker_Stroke.Parent = Expanded_Picker_Frame

                local Saturation_Value_Map = Instance.new("ImageButton")
                Saturation_Value_Map.Size = UDim2.new(1, -16, 0, 150)
                Saturation_Value_Map.Position = UDim2.new(0, 8, 0, 8)
                Saturation_Value_Map.Image = "rbxassetid://4155801252"
                Saturation_Value_Map.ImageColor3 = Color3.fromHSV(Hue_Val, 1, 1)
                Saturation_Value_Map.AutoButtonColor = false
                Saturation_Value_Map.Parent = Expanded_Picker_Frame
                local Saturation_Value_Map_Corner = Instance.new("UICorner"); Saturation_Value_Map_Corner.CornerRadius = UDim.new(0, 3); Saturation_Value_Map_Corner.Parent = Saturation_Value_Map
                local Saturation_Value_Map_Stroke = Instance.new("UIStroke"); Apply_Theme(Saturation_Value_Map_Stroke, "Color", "Border_Color"); Saturation_Value_Map_Stroke.Parent = Saturation_Value_Map

                local Saturation_Value_Map_Cursor = Instance.new("Frame")
                Saturation_Value_Map_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                Saturation_Value_Map_Cursor.Size = UDim2.new(0, 6, 0, 6)
                Saturation_Value_Map_Cursor.Position = UDim2.new(Saturation_Val, 0, 1 - Brightness_Val, 0)
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
                local Hue_Map_Stroke = Instance.new("UIStroke"); Apply_Theme(Hue_Map_Stroke, "Color", "Border_Color"); Hue_Map_Stroke.Parent = Hue_Map

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
                Hue_Map_Cursor.Position = UDim2.new(Hue_Val, 0, 0.5, 0)
                Hue_Map_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Map_Cursor.Parent = Hue_Map
                local Hue_Map_Cursor_Corner = Instance.new("UICorner"); Hue_Map_Cursor_Corner.CornerRadius = UDim.new(0, 2); Hue_Map_Cursor_Corner.Parent = Hue_Map_Cursor
                local Hue_Map_Cursor_Stroke = Instance.new("UIStroke"); Hue_Map_Cursor_Stroke.Color = Color3.new(0, 0, 0); Hue_Map_Cursor_Stroke.Parent = Hue_Map_Cursor

                local function Update_Color_Picker_State()
                    local Current_Color = Color3.fromHSV(Hue_Val, Saturation_Val, Brightness_Val)
                    Library_Api.Flags[Flag_Name] = Current_Color
                    Saturation_Value_Map.ImageColor3 = Color3.fromHSV(Hue_Val, 1, 1)
                    Color_Preview_Button.BackgroundColor3 = Current_Color
                    Saturation_Value_Map_Cursor.Position = UDim2.new(Saturation_Val, 0, 1 - Brightness_Val, 0)
                    Hue_Map_Cursor.Position = UDim2.new(Hue_Val, 0, 0.5, 0)
                    if Callback_Func then task.spawn(Callback_Func, Current_Color) end
                end

                local Is_Sliding_Saturation_Value = false
                local Is_Sliding_Hue = false

                local function Process_Saturation_Value_Input(Input_Event)
                    Saturation_Val = math.clamp((Input_Event.Position.X - Saturation_Value_Map.AbsolutePosition.X) / Saturation_Value_Map.AbsoluteSize.X, 0, 1)
                    Brightness_Val = 1 - math.clamp((Input_Event.Position.Y - Saturation_Value_Map.AbsolutePosition.Y) / Saturation_Value_Map.AbsoluteSize.Y, 0, 1)
                    Update_Color_Picker_State()
                end

                local function Process_Hue_Input(Input_Event)
                    Hue_Val = math.clamp((Input_Event.Position.X - Hue_Map.AbsolutePosition.X) / Hue_Map.AbsoluteSize.X, 0, 1)
                    Update_Color_Picker_State()
                end

                Saturation_Value_Map.InputBegan:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding_Saturation_Value = true
                        Process_Saturation_Value_Input(Input_Event)
                    end
                end)
                
                Hue_Map.InputBegan:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding_Hue = true
                        Process_Hue_Input(Input_Event)
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseButton1 or Input_Event.UserInputType == Enum.UserInputType.Touch then
                        Is_Sliding_Saturation_Value = false
                        Is_Sliding_Hue = false
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input_Event)
                    if Input_Event.UserInputType == Enum.UserInputType.MouseMovement or Input_Event.UserInputType == Enum.UserInputType.Touch then
                        if Is_Sliding_Saturation_Value then Process_Saturation_Value_Input(Input_Event) end
                        if Is_Sliding_Hue then Process_Hue_Input(Input_Event) end
                    end
                end)

                Color_Preview_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    if not Is_Color_Picker_Open then pcall(function() Color_Preview_Button_Stroke.Color = UI_Colors.Border_Light_Color end) end
                end)
                Color_Preview_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Color_Picker_Open then pcall(function() Color_Preview_Button_Stroke.Color = UI_Colors.Border_Color end) end
                end)

                Color_Preview_Button.MouseButton1Click:Connect(function()
                    Is_Color_Picker_Open = not Is_Color_Picker_Open
                    pcall(function() Color_Preview_Button_Stroke.Color = Is_Color_Picker_Open and UI_Colors.Accent_Color or UI_Colors.Border_Color end)
                    Animate_Element(Color_Picker_Frame, {Size = UDim2.new(1, 0, 0, Is_Color_Picker_Open and 224 or 24)}, 0.3)
                end)
                
                local Color_Api = {}
                function Color_Api:Set(New_Color_Val)
                    Hue_Val, Saturation_Val, Brightness_Val = New_Color_Val:ToHSV()
                    Update_Color_Picker_State()
                end
                return Color_Api
            end

            function Element_Api:Button_Create(Name_String, Tooltip_Text, Callback_Func)
                local Button_Frame = Instance.new("Frame")
                Button_Frame.Size = UDim2.new(1, 0, 0, 30)
                Button_Frame.BackgroundTransparency = 1
                Button_Frame.Parent = Target_Container

                local Action_Button = Instance.new("TextButton")
                Action_Button.Size = UDim2.new(1, -4, 1, 0)
                Action_Button.Position = UDim2.new(0, 2, 0, 0)
                Apply_Theme(Action_Button, "BackgroundColor3", "Element_Background")
                Action_Button.BackgroundTransparency = 0.21
                Action_Button.Text = Name_String
                Apply_Theme(Action_Button, "TextColor3", "Text_White_Color")
                Action_Button.TextSize = 12
                Action_Button.Font = Bold_Font
                Action_Button.AutoButtonColor = false
                Action_Button.Parent = Button_Frame
                
                local Action_Button_Corner = Instance.new("UICorner")
                Action_Button_Corner.CornerRadius = UDim.new(0, 4)
                Action_Button_Corner.Parent = Action_Button
                
                local Action_Button_Stroke = Instance.new("UIStroke")
                Apply_Theme(Action_Button_Stroke, "Color", "Border_Color")
                Action_Button_Stroke.Parent = Action_Button

                Action_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    pcall(function() Action_Button.BackgroundColor3 = UI_Colors.Element_Hover_Background end)
                    pcall(function() Action_Button_Stroke.Color = UI_Colors.Accent_Color end)
                    pcall(function() Action_Button.TextColor3 = UI_Colors.Accent_Color end)
                end)
                Action_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    pcall(function() Action_Button.BackgroundColor3 = UI_Colors.Element_Background end)
                    pcall(function() Action_Button_Stroke.Color = UI_Colors.Border_Color end)
                    pcall(function() Action_Button.TextColor3 = UI_Colors.Text_White_Color end)
                end)
                Action_Button.MouseButton1Down:Connect(function() Animate_Element(Action_Button, {Size = UDim2.new(0.96, 0, 0.85, 0), Position = UDim2.new(0.02, 0, 0.075, 0)}, 0.15) end)
                Action_Button.MouseButton1Up:Connect(function()
                    Animate_Element(Action_Button, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.15)
                    if Callback_Func then task.spawn(Callback_Func) end
                end)
            end

            function Element_Api:SubButton_Create(Name_String, Tooltip_Text, Callback_Func)
                local Sub_Button_Frame = Instance.new("Frame")
                Sub_Button_Frame.Size = UDim2.new(1, 0, 0, 22)
                Sub_Button_Frame.BackgroundTransparency = 1
                Sub_Button_Frame.Parent = Target_Container

                local Sub_Button_Action = Instance.new("TextButton")
                Sub_Button_Action.Size = UDim2.new(1, -16, 1, 0)
                Sub_Button_Action.Position = UDim2.new(0, 8, 0, 0)
                Apply_Theme(Sub_Button_Action, "BackgroundColor3", "Section_Background")
                Sub_Button_Action.BackgroundTransparency = 0.21
                Sub_Button_Action.Text = Name_String
                Apply_Theme(Sub_Button_Action, "TextColor3", "Text_Dark_Color")
                Sub_Button_Action.TextSize = 11
                Sub_Button_Action.Font = Main_Font
                Sub_Button_Action.AutoButtonColor = false
                Sub_Button_Action.Parent = Sub_Button_Frame
                
                local Sub_Button_Corner = Instance.new("UICorner")
                Sub_Button_Corner.CornerRadius = UDim.new(0, 3)
                Sub_Button_Corner.Parent = Sub_Button_Action
                
                local Sub_Button_Stroke = Instance.new("UIStroke")
                Apply_Theme(Sub_Button_Stroke, "Color", "Border_Color")
                Sub_Button_Stroke.Parent = Sub_Button_Action

                Sub_Button_Action.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    pcall(function() Sub_Button_Action.BackgroundColor3 = UI_Colors.Element_Background end)
                    pcall(function() Sub_Button_Stroke.Color = UI_Colors.Border_Light_Color end)
                    pcall(function() Sub_Button_Action.TextColor3 = UI_Colors.Text_White_Color end)
                end)
                Sub_Button_Action.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    pcall(function() Sub_Button_Action.BackgroundColor3 = UI_Colors.Section_Background end)
                    pcall(function() Sub_Button_Stroke.Color = UI_Colors.Border_Color end)
                    pcall(function() Sub_Button_Action.TextColor3 = UI_Colors.Text_Dark_Color end)
                end)
                Sub_Button_Action.MouseButton1Down:Connect(function() Animate_Element(Sub_Button_Action, {Size = UDim2.new(0.96, -16, 0.85, 0), Position = UDim2.new(0.02, 8, 0.075, 0)}, 0.15) end)
                Sub_Button_Action.MouseButton1Up:Connect(function()
                    Animate_Element(Sub_Button_Action, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0)}, 0.15)
                    if Callback_Func then task.spawn(Callback_Func) end
                end)
            end

            function Element_Api:Module_Create(Name_String, Flag_Name, Description_Text, Default_Value, Tooltip_Text, Callback_Func)
                Library_Api.Flags[Flag_Name] = Library_Api.Flags[Flag_Name] ~= nil and Library_Api.Flags[Flag_Name] or (Default_Value or false)

                local Module_Frame = Instance.new("Frame")
                Module_Frame.Size = UDim2.new(1, 0, 0, 46)
                Module_Frame.BackgroundTransparency = 1
                Module_Frame.ClipsDescendants = true
                Module_Frame.Parent = Target_Container

                local Module_Toggle_Button = Instance.new("TextButton")
                Module_Toggle_Button.Size = UDim2.new(1, -4, 0, 44)
                Module_Toggle_Button.Position = UDim2.new(0, 2, 0, 0)
                Apply_Theme(Module_Toggle_Button, "BackgroundColor3", "Element_Background")
                Module_Toggle_Button.BackgroundTransparency = 0.21
                Module_Toggle_Button.Text = ""
                Module_Toggle_Button.AutoButtonColor = false
                Module_Toggle_Button.Parent = Module_Frame
                
                local Module_Toggle_Button_Corner = Instance.new("UICorner")
                Module_Toggle_Button_Corner.CornerRadius = UDim.new(0, 6)
                Module_Toggle_Button_Corner.Parent = Module_Toggle_Button
                
                local Module_Toggle_Button_Stroke = Instance.new("UIStroke")
                Apply_Theme(Module_Toggle_Button_Stroke, "Color", Library_Api.Flags[Flag_Name] and "Accent_Color" or "Border_Color")
                Module_Toggle_Button_Stroke.Parent = Module_Toggle_Button

                local Module_Checkbox_Frame = Instance.new("Frame")
                Module_Checkbox_Frame.Size = UDim2.new(0, 16, 0, 16)
                Module_Checkbox_Frame.Position = UDim2.new(0, 14, 0.5, -8)
                Apply_Theme(Module_Checkbox_Frame, "BackgroundColor3", Library_Api.Flags[Flag_Name] and "Accent_Color" or "Section_Background")
                Module_Checkbox_Frame.BackgroundTransparency = 0.21
                Module_Checkbox_Frame.Parent = Module_Toggle_Button
                
                local Module_Checkbox_Corner = Instance.new("UICorner")
                Module_Checkbox_Corner.CornerRadius = UDim.new(0, 4)
                Module_Checkbox_Corner.Parent = Module_Checkbox_Frame
                
                local Module_Checkbox_Stroke = Instance.new("UIStroke")
                Apply_Theme(Module_Checkbox_Stroke, "Color", "Border_Color")
                Module_Checkbox_Stroke.Parent = Module_Checkbox_Frame

                local Module_Label = Instance.new("TextLabel")
                Module_Label.Size = UDim2.new(1, -45, 0, 16)
                Module_Label.Position = UDim2.new(0, 40, 0, 6)
                Module_Label.BackgroundTransparency = 1
                Module_Label.Text = Name_String
                Apply_Theme(Module_Label, "TextColor3", Library_Api.Flags[Flag_Name] and "Text_White_Color" or "Text_Dark_Color")
                Module_Label.TextSize = 13
                Module_Label.Font = Bold_Font
                Module_Label.TextXAlignment = Enum.TextXAlignment.Left
                Module_Label.Parent = Module_Toggle_Button

                local Module_Description_Label = Instance.new("TextLabel")
                Module_Description_Label.Size = UDim2.new(1, -45, 0, 14)
                Module_Description_Label.Position = UDim2.new(0, 40, 0, 22)
                Module_Description_Label.BackgroundTransparency = 1
                Module_Description_Label.Text = Description_Text
                Apply_Theme(Module_Description_Label, "TextColor3", "Text_Dark_Color")
                Module_Description_Label.TextSize = 11
                Module_Description_Label.Font = Main_Font
                Module_Description_Label.TextXAlignment = Enum.TextXAlignment.Left
                Module_Description_Label.Parent = Module_Toggle_Button

                local Module_Arrow_Icon = Instance.new("ImageLabel")
                Module_Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Module_Arrow_Icon.Position = UDim2.new(1, -22, 0, 14)
                Module_Arrow_Icon.BackgroundTransparency = 1
                Module_Arrow_Icon.Image = "rbxassetid://6031090656"
                Apply_Theme(Module_Arrow_Icon, "ImageColor3", Library_Api.Flags[Flag_Name] and "Accent_Color" or "Text_Dark_Color")
                Module_Arrow_Icon.Rotation = Library_Api.Flags[Flag_Name] and 180 or 0
                Module_Arrow_Icon.Parent = Module_Toggle_Button

                local Module_Content_Frame = Instance.new("Frame")
                Module_Content_Frame.Size = UDim2.new(1, -16, 0, 0)
                Module_Content_Frame.Position = UDim2.new(0, 12, 0, 48)
                Module_Content_Frame.BackgroundTransparency = 1
                Module_Content_Frame.Parent = Module_Frame

                local Module_Content_Layout = Instance.new("UIListLayout")
                Module_Content_Layout.Padding = UDim.new(0, 8)
                Module_Content_Layout.Parent = Module_Content_Frame

                local Is_Updating_Module = false
                local function Synchronize_Module_Size()
                    if Is_Updating_Module then return end
                    Is_Updating_Module = true
                    task.defer(function()
                        if Library_Api.Flags[Flag_Name] then
                            Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 46 + Module_Content_Layout.AbsoluteContentSize.Y + 8)}, 0.3)
                            Animate_Element(Module_Arrow_Icon, {Rotation = 180}, 0.3)
                            pcall(function() Module_Arrow_Icon.ImageColor3 = UI_Colors.Accent_Color end)
                        else
                            Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 46)}, 0.3)
                            Animate_Element(Module_Arrow_Icon, {Rotation = 0}, 0.3)
                            pcall(function() Module_Arrow_Icon.ImageColor3 = UI_Colors.Text_Dark_Color end)
                        end
                        Is_Updating_Module = false
                    end)
                end

                Module_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Library_Api.Flags[Flag_Name] then Synchronize_Module_Size() end
                end)

                Module_Toggle_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip_Text)
                    if not Library_Api.Flags[Flag_Name] then pcall(function() Module_Toggle_Button_Stroke.Color = UI_Colors.Border_Light_Color end) end
                end)
                Module_Toggle_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Library_Api.Flags[Flag_Name] then pcall(function() Module_Toggle_Button_Stroke.Color = UI_Colors.Border_Color end) end
                end)

                Module_Toggle_Button.MouseButton1Click:Connect(function()
                    Library_Api.Flags[Flag_Name] = not Library_Api.Flags[Flag_Name]
                    local New_State = Library_Api.Flags[Flag_Name]
                    Apply_Theme(Module_Checkbox_Frame, "BackgroundColor3", New_State and "Accent_Color" or "Section_Background")
                    Apply_Theme(Module_Toggle_Button_Stroke, "Color", New_State and "Accent_Color" or "Border_Color")
                    Apply_Theme(Module_Label, "TextColor3", New_State and "Text_White_Color" or "Text_Dark_Color")
                    Synchronize_Module_Size()
                    if Callback_Func then task.spawn(Callback_Func, New_State) end
                end)

                return Element_Injector(Module_Content_Frame)
            end

            return elements
        end

        local Section_Api = {}

        function Section_Api:Section_Create(Column_Side, Section_Title)
            local Section_Background_Frame = Instance.new("Frame")
            Section_Background_Frame.Size = UDim2.new(1, 0, 0, 40)
            Apply_Theme(Section_Background_Frame, "BackgroundColor3", "Section_Background")
            Section_Background_Frame.BackgroundTransparency = 0.21
            Section_Background_Frame.Parent = (Column_Side == "Left") and Left_Column_Frame or Right_Column_Frame
            
            local Section_Background_Corner = Instance.new("UICorner")
            Section_Background_Corner.CornerRadius = UDim.new(0, 6)
            Section_Background_Corner.Parent = Section_Background_Frame
            
            local Section_Background_Stroke = Instance.new("UIStroke")
            Apply_Theme(Section_Background_Stroke, "Color", "Border_Color")
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
            Apply_Theme(Section_Label, "TextColor3", "Text_White_Color")
            Section_Label.TextSize = 12
            Section_Label.Font = Bold_Font
            Section_Label.TextXAlignment = Enum.TextXAlignment.Left
            Section_Label.Parent = Section_Header_Frame

            local Section_Separator_Line = Instance.new("Frame")
            Section_Separator_Line.Size = UDim2.new(1, -20, 0, 1)
            Section_Separator_Line.Position = UDim2.new(0, 10, 1, 0)
            Apply_Theme(Section_Separator_Line, "BackgroundColor3", "Border_Color")
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

            local Is_Updating_Section = false
            local function Update_Section_Size()
                if Is_Updating_Section then return end
                Is_Updating_Section = true
                task.defer(function()
                    Section_Background_Frame.Size = UDim2.new(1, 0, 0, Section_Content_Layout.AbsoluteContentSize.Y + 44)
                    Is_Updating_Section = false
                end)
            end
            Section_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Section_Size)
            Update_Section_Size()

            return Element_Injector(Section_Content_Frame)
        end

        local Settings_Tab = Window_Context:Tab_Create("Settings", "rbxassetid://104798010403294", true)
        local Theme_Section = Settings_Tab:Section_Create("Left", "Theme Colors")
        local Config_Section = Settings_Tab:Section_Create("Right", "Configuration")
        
        local Accent_Picker = Theme_Section:ColorPicker_Create("Accent Color", "Internal_Accent_Flag", UI_Colors.Accent_Color, "", function(Pick_Color) Update_Theme("Accent_Color", Pick_Color) end)
        local Main_Bg_Picker = Theme_Section:ColorPicker_Create("Main Background", "Internal_Main_Bg_Flag", UI_Colors.Main_Background, "", function(Pick_Color) Update_Theme("Main_Background", Pick_Color) end)
        local Side_Bg_Picker = Theme_Section:ColorPicker_Create("Sidebar Background", "Internal_Side_Bg_Flag", UI_Colors.Sidebar_Background, "", function(Pick_Color) Update_Theme("Sidebar_Background", Pick_Color) end)
        local Sec_Bg_Picker = Theme_Section:ColorPicker_Create("Section Background", "Internal_Sec_Bg_Flag", UI_Colors.Section_Background, "", function(Pick_Color) Update_Theme("Section_Background", Pick_Color) end)
        local Elem_Bg_Picker = Theme_Section:ColorPicker_Create("Element Background", "Internal_Elem_Bg_Flag", UI_Colors.Element_Background, "", function(Pick_Color) Update_Theme("Element_Background", Pick_Color) end)
        local Border_Picker = Theme_Section:ColorPicker_Create("Border Color", "Internal_Border_Flag", UI_Colors.Border_Color, "", function(Pick_Color) Update_Theme("Border_Color", Pick_Color) end)
        local Text_Wht_Picker = Theme_Section:ColorPicker_Create("Text White", "Internal_Text_W_Flag", UI_Colors.Text_White_Color, "", function(Pick_Color) Update_Theme("Text_White_Color", Pick_Color) end)
        
        Theme_Section:Toggle_Create("Show Keybinds List", "Internal_Show_KB_Flag", false, "", function(Toggle_State) KB_Outer_Frame.Visible = Toggle_State end)

        local Cfg_Dropdown = Config_Section:Dropdown_Create("Select Config", "Internal_Cfg_Sel_Flag", Get_Configs(), "Default", "", function(Dropdown_Value) Library_Api.Current_Config = Dropdown_Value end)
        local Cfg_Textbox = Config_Section:Textbox_Create("Config Name", "Internal_Cfg_Name_Flag", "Default", "", function(Text_Value) Library_Api.Current_Config = Text_Value end)
        
        Config_Section:Button_Create("Load Config", "", function() 
            Load_Configuration(Library_Api.Current_Config)
            Accent_Picker:Set(UI_Colors.Accent_Color)
            Main_Bg_Picker:Set(UI_Colors.Main_Background)
            Side_Bg_Picker:Set(UI_Colors.Sidebar_Background)
            Sec_Bg_Picker:Set(UI_Colors.Section_Background)
            Elem_Bg_Picker:Set(UI_Colors.Element_Background)
            Border_Picker:Set(UI_Colors.Border_Color)
            Text_Wht_Picker:Set(UI_Colors.Text_White_Color)
        end)
        
        Config_Section:Button_Create("Save Config", "", function()
            Save_Configuration(Library_Api.Current_Config)
            Cfg_Dropdown:Refresh(Get_Configs())
        end)
        
        Config_Section:Button_Create("Rewrite Config", "", function()
            Save_Configuration(Library_Api.Current_Config)
        end)
        
        Config_Section:SubButton_Create("Delete Config", "", function()
            Delete_Configuration(Library_Api.Current_Config)
            Cfg_Dropdown:Refresh(Get_Configs())
        end)

        Profile_Button.MouseButton1Click:Connect(function()
            Settings_Tab:Activate()
        end)

        return Section_Api
    end

    User_Input_Service.InputBegan:Connect(function(Input_Event, Game_Processed_Event)
        if not Game_Processed_Event and Input_Event.KeyCode == Enum.KeyCode.Delete then
            Main_Background.Visible = not Main_Background.Visible
        end
    end)

    return Window_Context
end

return Library_Api
