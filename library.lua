local Cool_Core_Gui = game:GetService("CoreGui")
local Cool_User_Input_Service = game:GetService("UserInputService")
local Cool_Run_Service = game:GetService("RunService")
local Cool_Tween_Service = game:GetService("TweenService")
local Cool_Text_Service = game:GetService("TextService")
local Cool_Http_Service = game:GetService("HttpService")

local Cool_Nixware_Evolution_Api = {
    Cool_Flags = {},
    Cool_Instances = {},
    Cool_Connections = {}
}

local Cool_Theme_Config = {
    Cool_Dark_Bg = Color3.fromRGB(8, 8, 8),
    Cool_Main_Bg = Color3.fromRGB(12, 12, 12),
    Cool_Sidebar_Bg = Color3.fromRGB(14, 14, 14),
    Cool_Section_Bg = Color3.fromRGB(18, 18, 18),
    Cool_Element_Bg = Color3.fromRGB(24, 24, 24),
    Cool_Hover_Bg = Color3.fromRGB(32, 32, 32),
    Cool_Border_Light = Color3.fromRGB(45, 45, 45),
    Cool_Border_Dark = Color3.fromRGB(0, 0, 0),
    Cool_Accent_Primary = Color3.fromRGB(105, 130, 255),
    Cool_Accent_Secondary = Color3.fromRGB(145, 100, 255),
    Cool_Text_White = Color3.fromRGB(245, 245, 245),
    Cool_Text_Gray = Color3.fromRGB(155, 155, 155),
    Cool_Main_Font = Enum.Font.GothamMedium,
    Cool_Bold_Font = Enum.Font.GothamBold,
    Cool_Mono_Font = Enum.Font.RobotoMono
}

local Cool_Tooltip_Layer = Instance.new("ScreenGui")
Cool_Tooltip_Layer.Name = Cool_Http_Service:GenerateGUID(false)
Cool_Tooltip_Layer.Parent = Cool_Core_Gui
Cool_Tooltip_Layer.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Cool_Tooltip_Frame = Instance.new("Frame")
Cool_Tooltip_Frame.BackgroundColor3 = Cool_Theme_Config.Cool_Dark_Bg
Cool_Tooltip_Frame.BackgroundTransparency = 1
Cool_Tooltip_Frame.Size = UDim2.new(0, 0, 0, 24)
Cool_Tooltip_Frame.ZIndex = 1000
Cool_Tooltip_Frame.Visible = false
Cool_Tooltip_Frame.Parent = Cool_Tooltip_Layer

local Cool_Tooltip_Corner = Instance.new("UICorner")
Cool_Tooltip_Corner.CornerRadius = UDim.new(0, 4)
Cool_Tooltip_Corner.Parent = Cool_Tooltip_Frame

local Cool_Tooltip_Stroke = Instance.new("UIStroke")
Cool_Tooltip_Stroke.Color = Cool_Theme_Config.Cool_Border_Light
Cool_Tooltip_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Cool_Tooltip_Stroke.Transparency = 1
Cool_Tooltip_Stroke.Parent = Cool_Tooltip_Frame

local Cool_Tooltip_Label = Instance.new("TextLabel")
Cool_Tooltip_Label.Size = UDim2.new(1, -16, 1, 0)
Cool_Tooltip_Label.Position = UDim2.new(0, 8, 0, 0)
Cool_Tooltip_Label.BackgroundTransparency = 1
Cool_Tooltip_Label.TextColor3 = Cool_Theme_Config.Cool_Text_White
Cool_Tooltip_Label.TextTransparency = 1
Cool_Tooltip_Label.TextSize = 12
Cool_Tooltip_Label.Font = Cool_Theme_Config.Cool_Main_Font
Cool_Tooltip_Label.TextXAlignment = Enum.TextXAlignment.Left
Cool_Tooltip_Label.ZIndex = 1001
Cool_Tooltip_Label.Parent = Cool_Tooltip_Frame

local Cool_Tooltip_Target = ""
local Cool_Tooltip_Conn = nil

local function Cool_Tween_Instance(Cool_Object, Cool_Props, Cool_Time)
    local Cool_Tween_Info = TweenInfo.new(Cool_Time or 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local Cool_Anim = Cool_Tween_Service:Create(Cool_Object, Cool_Tween_Info, Cool_Props)
    Cool_Anim:Play()
    return Cool_Anim
end

local function Cool_Apply_Corner(Cool_Object, Cool_Radius)
    local Cool_Corner = Instance.new("UICorner")
    Cool_Corner.CornerRadius = UDim.new(0, Cool_Radius or 6)
    Cool_Corner.Parent = Cool_Object
    return Cool_Corner
end

local function Cool_Apply_Stroke(Cool_Object, Cool_Color, Cool_Thickness)
    local Cool_Stroke = Instance.new("UIStroke")
    Cool_Stroke.Color = Cool_Color or Cool_Theme_Config.Cool_Border_Light
    Cool_Stroke.Thickness = Cool_Thickness or 1
    Cool_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Cool_Stroke.Parent = Cool_Object
    return Cool_Stroke
end

local function Cool_Process_Tooltip()
    if Cool_Tooltip_Conn then Cool_Tooltip_Conn:Disconnect() end
    Cool_Tooltip_Conn = Cool_Run_Service.RenderStepped:Connect(function()
        if Cool_Tooltip_Target ~= "" then
            local Cool_Mouse_Loc = Cool_User_Input_Service:GetMouseLocation()
            local Cool_Target_X = Cool_Mouse_Loc.X + 15
            local Cool_Target_Y = Cool_Mouse_Loc.Y + 15
            Cool_Tooltip_Frame.Position = UDim2.new(0, Cool_Target_X, 0, Cool_Target_Y)
            if not Cool_Tooltip_Frame.Visible then
                Cool_Tooltip_Frame.Visible = true
                Cool_Tween_Instance(Cool_Tooltip_Frame, {BackgroundTransparency = 0.05}, 0.2)
                Cool_Tween_Instance(Cool_Tooltip_Stroke, {Transparency = 0}, 0.2)
                Cool_Tween_Instance(Cool_Tooltip_Label, {TextTransparency = 0}, 0.2)
            end
        else
            Cool_Tween_Instance(Cool_Tooltip_Frame, {BackgroundTransparency = 1}, 0.1)
            Cool_Tween_Instance(Cool_Tooltip_Stroke, {Transparency = 1}, 0.1)
            Cool_Tween_Instance(Cool_Tooltip_Label, {TextTransparency = 1}, 0.1)
            task.delay(0.1, function()
                if Cool_Tooltip_Target == "" then
                    Cool_Tooltip_Frame.Visible = false
                end
            end)
        end
    end)
end
Cool_Process_Tooltip()

local function Cool_Update_Tooltip(Cool_Text)
    if not Cool_Text or Cool_Text == "" then
        Cool_Tooltip_Target = ""
        return
    end
    local Cool_Bounds = Cool_Text_Service:GetTextSize(Cool_Text, 12, Cool_Theme_Config.Cool_Main_Font, Vector2.new(800, 24))
    Cool_Tooltip_Frame.Size = UDim2.new(0, Cool_Bounds.X + 16, 0, 24)
    Cool_Tooltip_Label.Text = Cool_Text
    Cool_Tooltip_Target = Cool_Text
end

function Cool_Nixware_Evolution_Api:Cool_Create_Environment(Cool_Window_Config)
    local Cool_Window_Name = Cool_Window_Config.Name or "Phantom Hub Evolution"
    local Cool_Window_Size = Cool_Window_Config.Size or UDim2.new(0, 750, 0, 520)

    local Cool_Screen_Gui = Instance.new("ScreenGui")
    Cool_Screen_Gui.Name = Cool_Http_Service:GenerateGUID(false)
    Cool_Screen_Gui.Parent = Cool_Core_Gui
    Cool_Screen_Gui.ResetOnSpawn = false
    Cool_Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Cool_Drop_Shadow_Holder = Instance.new("Frame")
    Cool_Drop_Shadow_Holder.Size = Cool_Window_Size
    Cool_Drop_Shadow_Holder.Position = UDim2.new(0.5, -Cool_Window_Size.X.Offset / 2, 0.5, -Cool_Window_Size.Y.Offset / 2)
    Cool_Drop_Shadow_Holder.BackgroundTransparency = 1
    Cool_Drop_Shadow_Holder.Parent = Cool_Screen_Gui

    local Cool_Main_Shadow = Instance.new("ImageLabel")
    Cool_Main_Shadow.Size = UDim2.new(1, 60, 1, 60)
    Cool_Main_Shadow.Position = UDim2.new(0, -30, 0, -30)
    Cool_Main_Shadow.BackgroundTransparency = 1
    Cool_Main_Shadow.Image = "rbxassetid://6015536814"
    Cool_Main_Shadow.ImageColor3 = Color3.new(0, 0, 0)
    Cool_Main_Shadow.ImageTransparency = 0.4
    Cool_Main_Shadow.ScaleType = Enum.ScaleType.Slice
    Cool_Main_Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    Cool_Main_Shadow.Parent = Cool_Drop_Shadow_Holder

    local Cool_Main_Frame = Instance.new("Frame")
    Cool_Main_Frame.Size = UDim2.new(1, 0, 1, 0)
    Cool_Main_Frame.BackgroundColor3 = Cool_Theme_Config.Cool_Main_Bg
    Cool_Main_Frame.Parent = Cool_Drop_Shadow_Holder
    Cool_Apply_Corner(Cool_Main_Frame, 8)
    Cool_Apply_Stroke(Cool_Main_Frame, Cool_Theme_Config.Cool_Border_Light, 1)

    local Cool_Top_Section = Instance.new("Frame")
    Cool_Top_Section.Size = UDim2.new(1, 0, 0, 40)
    Cool_Top_Section.BackgroundColor3 = Cool_Theme_Config.Cool_Sidebar_Bg
    Cool_Top_Section.Parent = Cool_Main_Frame
    Cool_Apply_Corner(Cool_Top_Section, 8)

    local Cool_Top_Hider = Instance.new("Frame")
    Cool_Top_Hider.Size = UDim2.new(1, 0, 0, 8)
    Cool_Top_Hider.Position = UDim2.new(0, 0, 1, -8)
    Cool_Top_Hider.BackgroundColor3 = Cool_Theme_Config.Cool_Sidebar_Bg
    Cool_Top_Hider.BorderSizePixel = 0
    Cool_Top_Hider.Parent = Cool_Top_Section

    local Cool_Top_Separator = Instance.new("Frame")
    Cool_Top_Separator.Size = UDim2.new(1, 0, 0, 1)
    Cool_Top_Separator.Position = UDim2.new(0, 0, 1, 0)
    Cool_Top_Separator.BackgroundColor3 = Cool_Theme_Config.Cool_Border_Light
    Cool_Top_Separator.BorderSizePixel = 0
    Cool_Top_Separator.Parent = Cool_Top_Section

    local Cool_Gradient_Bar = Instance.new("Frame")
    Cool_Gradient_Bar.Size = UDim2.new(1, 0, 0, 2)
    Cool_Gradient_Bar.BackgroundColor3 = Color3.new(1, 1, 1)
    Cool_Gradient_Bar.BorderSizePixel = 0
    Cool_Gradient_Bar.Parent = Cool_Top_Section
    Cool_Apply_Corner(Cool_Gradient_Bar, 8)

    local Cool_UIGradient = Instance.new("UIGradient")
    Cool_UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Cool_Theme_Config.Cool_Accent_Primary),
        ColorSequenceKeypoint.new(1, Cool_Theme_Config.Cool_Accent_Secondary)
    }
    Cool_UIGradient.Parent = Cool_Gradient_Bar

    local Cool_Title_Label = Instance.new("TextLabel")
    Cool_Title_Label.Size = UDim2.new(1, -30, 1, -2)
    Cool_Title_Label.Position = UDim2.new(0, 15, 0, 2)
    Cool_Title_Label.BackgroundTransparency = 1
    Cool_Title_Label.Text = Cool_Window_Name
    Cool_Title_Label.TextColor3 = Cool_Theme_Config.Cool_Text_White
    Cool_Title_Label.TextSize = 14
    Cool_Title_Label.Font = Cool_Theme_Config.Cool_Bold_Font
    Cool_Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Cool_Title_Label.Parent = Cool_Top_Section

    local Cool_Sidebar_Frame = Instance.new("Frame")
    Cool_Sidebar_Frame.Size = UDim2.new(0, 170, 1, -41)
    Cool_Sidebar_Frame.Position = UDim2.new(0, 0, 0, 41)
    Cool_Sidebar_Frame.BackgroundColor3 = Cool_Theme_Config.Cool_Sidebar_Bg
    Cool_Sidebar_Frame.Parent = Cool_Main_Frame
    Cool_Apply_Corner(Cool_Sidebar_Frame, 8)

    local Cool_Sidebar_Hider = Instance.new("Frame")
    Cool_Sidebar_Hider.Size = UDim2.new(0, 8, 1, 0)
    Cool_Sidebar_Hider.Position = UDim2.new(1, -8, 0, 0)
    Cool_Sidebar_Hider.BackgroundColor3 = Cool_Theme_Config.Cool_Sidebar_Bg
    Cool_Sidebar_Hider.BorderSizePixel = 0
    Cool_Sidebar_Hider.Parent = Cool_Sidebar_Frame

    local Cool_Sidebar_Hider_Top = Instance.new("Frame")
    Cool_Sidebar_Hider_Top.Size = UDim2.new(1, 0, 0, 8)
    Cool_Sidebar_Hider_Top.BackgroundColor3 = Cool_Theme_Config.Cool_Sidebar_Bg
    Cool_Sidebar_Hider_Top.BorderSizePixel = 0
    Cool_Sidebar_Hider_Top.Parent = Cool_Sidebar_Frame

    local Cool_Sidebar_Separator = Instance.new("Frame")
    Cool_Sidebar_Separator.Size = UDim2.new(0, 1, 1, 0)
    Cool_Sidebar_Separator.Position = UDim2.new(1, 0, 0, 0)
    Cool_Sidebar_Separator.BackgroundColor3 = Cool_Theme_Config.Cool_Border_Light
    Cool_Sidebar_Separator.BorderSizePixel = 0
    Cool_Sidebar_Separator.Parent = Cool_Sidebar_Frame

    local Cool_Tab_Scroll = Instance.new("ScrollingFrame")
    Cool_Tab_Scroll.Size = UDim2.new(1, -10, 1, -20)
    Cool_Tab_Scroll.Position = UDim2.new(0, 5, 0, 10)
    Cool_Tab_Scroll.BackgroundTransparency = 1
    Cool_Tab_Scroll.BorderSizePixel = 0
    Cool_Tab_Scroll.ScrollBarThickness = 0
    Cool_Tab_Scroll.Parent = Cool_Sidebar_Frame

    local Cool_Tab_List_Layout = Instance.new("UIListLayout")
    Cool_Tab_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Cool_Tab_List_Layout.Padding = UDim.new(0, 6)
    Cool_Tab_List_Layout.Parent = Cool_Tab_Scroll

    local Cool_Content_Container = Instance.new("Frame")
    Cool_Content_Container.Size = UDim2.new(1, -171, 1, -41)
    Cool_Content_Container.Position = UDim2.new(0, 171, 0, 41)
    Cool_Content_Container.BackgroundTransparency = 1
    Cool_Content_Container.Parent = Cool_Main_Frame

    local Cool_Dragging = false
    local Cool_Drag_Input = nil
    local Cool_Drag_Start = nil
    local Cool_Start_Pos = nil

    local function Cool_Update_Drag(Cool_Input)
        local Cool_Delta = Cool_Input.Position - Cool_Drag_Start
        local Cool_Target_Pos = UDim2.new(Cool_Start_Pos.X.Scale, Cool_Start_Pos.X.Offset + Cool_Delta.X, Cool_Start_Pos.Y.Scale, Cool_Start_Pos.Y.Offset + Cool_Delta.Y)
        Cool_Tween_Instance(Cool_Drop_Shadow_Holder, {Position = Cool_Target_Pos}, 0.08)
    end

    Cool_Top_Section.InputBegan:Connect(function(Cool_Input)
        if Cool_Input.UserInputType == Enum.UserInputType.MouseButton1 or Cool_Input.UserInputType == Enum.UserInputType.Touch then
            Cool_Dragging = true
            Cool_Drag_Start = Cool_Input.Position
            Cool_Start_Pos = Cool_Drop_Shadow_Holder.Position
            Cool_Input.Changed:Connect(function()
                if Cool_Input.UserInputState == Enum.UserInputState.End then
                    Cool_Dragging = false
                end
            end)
        end
    end)

    Cool_Top_Section.InputChanged:Connect(function(Cool_Input)
        if Cool_Input.UserInputType == Enum.UserInputType.MouseMovement or Cool_Input.UserInputType == Enum.UserInputType.Touch then
            Cool_Drag_Input = Cool_Input
        end
    end)

    Cool_Run_Service.RenderStepped:Connect(function()
        if Cool_Dragging and Cool_Drag_Input then
            Cool_Update_Drag(Cool_Drag_Input)
        end
    end)

    local Cool_Tab_Api = { Cool_Tabs_Table = {}, Cool_Active_Tab = nil }

    function Cool_Tab_Api:Cool_Create_Tab(Cool_Tab_Name, Cool_Tab_Icon)
        local Cool_Tab_Data = {}

        local Cool_Tab_Button = Instance.new("TextButton")
        Cool_Tab_Button.Size = UDim2.new(1, 0, 0, 36)
        Cool_Tab_Button.BackgroundColor3 = Cool_Theme_Config.Cool_Main_Bg
        Cool_Tab_Button.BackgroundTransparency = 1
        Cool_Tab_Button.Text = ""
        Cool_Tab_Button.AutoButtonColor = false
        Cool_Tab_Button.Parent = Cool_Tab_Scroll
        Cool_Apply_Corner(Cool_Tab_Button, 6)

        local Cool_Tab_Label = Instance.new("TextLabel")
        Cool_Tab_Label.Size = UDim2.new(1, -30, 1, 0)
        Cool_Tab_Label.Position = UDim2.new(0, 12, 0, 0)
        Cool_Tab_Label.BackgroundTransparency = 1
        Cool_Tab_Label.Text = Cool_Tab_Name
        Cool_Tab_Label.TextColor3 = Cool_Theme_Config.Cool_Text_Gray
        Cool_Tab_Label.TextSize = 13
        Cool_Tab_Label.Font = Cool_Theme_Config.Cool_Main_Font
        Cool_Tab_Label.TextXAlignment = Enum.TextXAlignment.Left
        Cool_Tab_Label.Parent = Cool_Tab_Button

        local Cool_Tab_Indicator = Instance.new("Frame")
        Cool_Tab_Indicator.Size = UDim2.new(0, 3, 0, 0)
        Cool_Tab_Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Cool_Tab_Indicator.BackgroundColor3 = Cool_Theme_Config.Cool_Accent_Primary
        Cool_Tab_Indicator.Parent = Cool_Tab_Button
        Cool_Apply_Corner(Cool_Tab_Indicator, 4)

        local Cool_Tab_Content_Group = Instance.new("CanvasGroup")
        Cool_Tab_Content_Group.Size = UDim2.new(1, 0, 1, 0)
        Cool_Tab_Content_Group.BackgroundTransparency = 1
        Cool_Tab_Content_Group.GroupTransparency = 1
        Cool_Tab_Content_Group.Visible = false
        Cool_Tab_Content_Group.Parent = Cool_Content_Container

        local Cool_Tab_Content_Scroll = Instance.new("ScrollingFrame")
        Cool_Tab_Content_Scroll.Size = UDim2.new(1, 0, 1, 0)
        Cool_Tab_Content_Scroll.BackgroundTransparency = 1
        Cool_Tab_Content_Scroll.BorderSizePixel = 0
        Cool_Tab_Content_Scroll.ScrollBarThickness = 2
        Cool_Tab_Content_Scroll.ScrollBarImageColor3 = Cool_Theme_Config.Cool_Accent_Primary
        Cool_Tab_Content_Scroll.Parent = Cool_Tab_Content_Group

        local Cool_Left_Column = Instance.new("Frame")
        Cool_Left_Column.Size = UDim2.new(0.5, -18, 1, 0)
        Cool_Left_Column.Position = UDim2.new(0, 12, 0, 12)
        Cool_Left_Column.BackgroundTransparency = 1
        Cool_Left_Column.Parent = Cool_Tab_Content_Scroll

        local Cool_Right_Column = Instance.new("Frame")
        Cool_Right_Column.Size = UDim2.new(0.5, -18, 1, 0)
        Cool_Right_Column.Position = UDim2.new(0.5, 6, 0, 12)
        Cool_Right_Column.BackgroundTransparency = 1
        Cool_Right_Column.Parent = Cool_Tab_Content_Scroll

        local Cool_Left_List = Instance.new("UIListLayout")
        Cool_Left_List.SortOrder = Enum.SortOrder.LayoutOrder
        Cool_Left_List.Padding = UDim.new(0, 12)
        Cool_Left_List.Parent = Cool_Left_Column

        local Cool_Right_List = Instance.new("UIListLayout")
        Cool_Right_List.SortOrder = Enum.SortOrder.LayoutOrder
        Cool_Right_List.Padding = UDim.new(0, 12)
        Cool_Right_List.Parent = Cool_Right_Column

        Cool_Run_Service.RenderStepped:Connect(function()
            local Cool_Max_Y = math.max(Cool_Left_List.AbsoluteContentSize.Y, Cool_Right_List.AbsoluteContentSize.Y)
            Cool_Tab_Content_Scroll.CanvasSize = UDim2.new(0, 0, 0, Cool_Max_Y + 24)
            Cool_Tab_Scroll.CanvasSize = UDim2.new(0, 0, 0, Cool_Tab_List_Layout.AbsoluteContentSize.Y + 10)
        end)

        function Cool_Tab_Data:Cool_Activate()
            if Cool_Tab_Api.Cool_Active_Tab == Cool_Tab_Data then return end
            if Cool_Tab_Api.Cool_Active_Tab then
                Cool_Tween_Instance(Cool_Tab_Api.Cool_Active_Tab.Button, {BackgroundTransparency = 1}, 0.2)
                Cool_Tween_Instance(Cool_Tab_Api.Cool_Active_Tab.Label, {TextColor3 = Cool_Theme_Config.Cool_Text_Gray}, 0.2)
                Cool_Tween_Instance(Cool_Tab_Api.Cool_Active_Tab.Indicator, {Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.2)
                local Cool_Old_Group = Cool_Tab_Api.Cool_Active_Tab.Group
                Cool_Tween_Instance(Cool_Old_Group, {GroupTransparency = 1}, 0.15).Completed:Connect(function()
                    if Cool_Tab_Api.Cool_Active_Tab ~= Cool_Tab_Data then
                        Cool_Old_Group.Visible = false
                    end
                end)
            end

            Cool_Tab_Api.Cool_Active_Tab = Cool_Tab_Data
            Cool_Tab_Content_Group.Visible = true
            Cool_Tween_Instance(Cool_Tab_Button, {BackgroundTransparency = 0.05}, 0.2)
            Cool_Tween_Instance(Cool_Tab_Label, {TextColor3 = Cool_Theme_Config.Cool_Text_White}, 0.2)
            Cool_Tween_Instance(Cool_Tab_Indicator, {Size = UDim2.new(0, 3, 0, 20), Position = UDim2.new(0, 0, 0.5, -10)}, 0.2)
            Cool_Tween_Instance(Cool_Tab_Content_Group, {GroupTransparency = 0}, 0.25)
        end

        Cool_Tab_Button.MouseButton1Click:Connect(function()
            Cool_Tab_Data:Cool_Activate()
        end)

        Cool_Tab_Button.MouseEnter:Connect(function()
            if Cool_Tab_Api.Cool_Active_Tab ~= Cool_Tab_Data then
                Cool_Tween_Instance(Cool_Tab_Label, {TextColor3 = Cool_Theme_Config.Cool_Text_White}, 0.15)
                Cool_Tween_Instance(Cool_Tab_Button, {BackgroundTransparency = 0.8}, 0.15)
            end
        end)

        Cool_Tab_Button.MouseLeave:Connect(function()
            if Cool_Tab_Api.Cool_Active_Tab ~= Cool_Tab_Data then
                Cool_Tween_Instance(Cool_Tab_Label, {TextColor3 = Cool_Theme_Config.Cool_Text_Gray}, 0.15)
                Cool_Tween_Instance(Cool_Tab_Button, {BackgroundTransparency = 1}, 0.15)
            end
        end)

        Cool_Tab_Data.Button = Cool_Tab_Button
        Cool_Tab_Data.Label = Cool_Tab_Label
        Cool_Tab_Data.Indicator = Cool_Tab_Indicator
        Cool_Tab_Data.Group = Cool_Tab_Content_Group

        table.insert(Cool_Tab_Api.Cool_Tabs_Table, Cool_Tab_Data)
        if #Cool_Tab_Api.Cool_Tabs_Table == 1 then
            Cool_Tab_Data:Cool_Activate()
        end

        local Cool_Section_Api = {}

        function Cool_Section_Api:Cool_Create_Section(Cool_Side, Cool_Section_Name)
            local Cool_Section_Frame = Instance.new("Frame")
            Cool_Section_Frame.Size = UDim2.new(1, 0, 0, 40)
            Cool_Section_Frame.BackgroundColor3 = Cool_Theme_Config.Cool_Section_Bg
            Cool_Section_Frame.Parent = (Cool_Side:lower() == "left") and Cool_Left_Column or Cool_Right_Column
            Cool_Apply_Corner(Cool_Section_Frame, 6)
            Cool_Apply_Stroke(Cool_Section_Frame, Cool_Theme_Config.Cool_Border_Light, 1)

            local Cool_Section_Header = Instance.new("Frame")
            Cool_Section_Header.Size = UDim2.new(1, 0, 0, 26)
            Cool_Section_Header.BackgroundTransparency = 1
            Cool_Section_Header.Parent = Cool_Section_Frame

            local Cool_Section_Title = Instance.new("TextLabel")
            Cool_Section_Title.Size = UDim2.new(1, -20, 1, 0)
            Cool_Section_Title.Position = UDim2.new(0, 10, 0, 0)
            Cool_Section_Title.BackgroundTransparency = 1
            Cool_Section_Title.Text = Cool_Section_Name
            Cool_Section_Title.TextColor3 = Cool_Theme_Config.Cool_Text_White
            Cool_Section_Title.TextSize = 12
            Cool_Section_Title.Font = Cool_Theme_Config.Cool_Bold_Font
            Cool_Section_Title.TextXAlignment = Enum.TextXAlignment.Left
            Cool_Section_Title.Parent = Cool_Section_Header

            local Cool_Section_Line = Instance.new("Frame")
            Cool_Section_Line.Size = UDim2.new(1, -20, 0, 1)
            Cool_Section_Line.Position = UDim2.new(0, 10, 1, 0)
            Cool_Section_Line.BackgroundColor3 = Cool_Theme_Config.Cool_Border_Light
            Cool_Section_Line.BorderSizePixel = 0
            Cool_Section_Line.Parent = Cool_Section_Header

            local Cool_Section_Container = Instance.new("Frame")
            Cool_Section_Container.Size = UDim2.new(1, -20, 1, -34)
            Cool_Section_Container.Position = UDim2.new(0, 10, 0, 32)
            Cool_Section_Container.BackgroundTransparency = 1
            Cool_Section_Container.Parent = Cool_Section_Frame

            local Cool_Container_Layout = Instance.new("UIListLayout")
            Cool_Container_Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Cool_Container_Layout.Padding = UDim.new(0, 10)
            Cool_Container_Layout.Parent = Cool_Section_Container

            Cool_Run_Service.RenderStepped:Connect(function()
                Cool_Section_Frame.Size = UDim2.new(1, 0, 0, Cool_Container_Layout.AbsoluteContentSize.Y + 44)
            end)

            local Cool_Elements_Api = {}

            function Cool_Elements_Api:Cool_Create_Toggle(Cool_Toggle_Name, Cool_Flag, Cool_Default, Cool_Tooltip_Text, Cool_Callback)
                Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] = Cool_Default or false

                local Cool_Toggle_Frame = Instance.new("TextButton")
                Cool_Toggle_Frame.Size = UDim2.new(1, 0, 0, 16)
                Cool_Toggle_Frame.BackgroundTransparency = 1
                Cool_Toggle_Frame.Text = ""
                Cool_Toggle_Frame.Parent = Cool_Section_Container

                local Cool_Toggle_Box = Instance.new("Frame")
                Cool_Toggle_Box.Size = UDim2.new(0, 16, 0, 16)
                Cool_Toggle_Box.BackgroundColor3 = Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] and Cool_Theme_Config.Cool_Accent_Primary or Cool_Theme_Config.Cool_Element_Bg
                Cool_Toggle_Box.Parent = Cool_Toggle_Frame
                Cool_Apply_Corner(Cool_Toggle_Box, 4)
                local Cool_Box_Stroke = Cool_Apply_Stroke(Cool_Toggle_Box, Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] and Cool_Theme_Config.Cool_Accent_Primary or Cool_Theme_Config.Cool_Border_Light, 1)

                local Cool_Toggle_Check = Instance.new("ImageLabel")
                Cool_Toggle_Check.Size = UDim2.new(0, 12, 0, 12)
                Cool_Toggle_Check.Position = UDim2.new(0.5, -6, 0.5, -6)
                Cool_Toggle_Check.BackgroundTransparency = 1
                Cool_Toggle_Check.Image = "rbxassetid://6031094667"
                Cool_Toggle_Check.ImageTransparency = Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] and 0 or 1
                Cool_Toggle_Check.Parent = Cool_Toggle_Box

                local Cool_Toggle_Label = Instance.new("TextLabel")
                Cool_Toggle_Label.Size = UDim2.new(1, -26, 1, 0)
                Cool_Toggle_Label.Position = UDim2.new(0, 24, 0, 0)
                Cool_Toggle_Label.BackgroundTransparency = 1
                Cool_Toggle_Label.Text = Cool_Toggle_Name
                Cool_Toggle_Label.TextColor3 = Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] and Cool_Theme_Config.Cool_Text_White or Cool_Theme_Config.Cool_Text_Gray
                Cool_Toggle_Label.TextSize = 12
                Cool_Toggle_Label.Font = Cool_Theme_Config.Cool_Main_Font
                Cool_Toggle_Label.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Toggle_Label.Parent = Cool_Toggle_Frame

                Cool_Toggle_Frame.MouseEnter:Connect(function()
                    Cool_Update_Tooltip(Cool_Tooltip_Text)
                    if not Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] then
                        Cool_Tween_Instance(Cool_Box_Stroke, {Color = Cool_Theme_Config.Cool_Text_Gray}, 0.2)
                    end
                end)

                Cool_Toggle_Frame.MouseLeave:Connect(function()
                    Cool_Update_Tooltip("")
                    if not Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] then
                        Cool_Tween_Instance(Cool_Box_Stroke, {Color = Cool_Theme_Config.Cool_Border_Light}, 0.2)
                    end
                end)

                Cool_Toggle_Frame.MouseButton1Click:Connect(function()
                    Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] = not Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag]
                    local Cool_State = Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag]
                    
                    Cool_Tween_Instance(Cool_Toggle_Box, {BackgroundColor3 = Cool_State and Cool_Theme_Config.Cool_Accent_Primary or Cool_Theme_Config.Cool_Element_Bg}, 0.2)
                    Cool_Tween_Instance(Cool_Box_Stroke, {Color = Cool_State and Cool_Theme_Config.Cool_Accent_Primary or Cool_Theme_Config.Cool_Border_Light}, 0.2)
                    Cool_Tween_Instance(Cool_Toggle_Check, {ImageTransparency = Cool_State and 0 or 1}, 0.2)
                    Cool_Tween_Instance(Cool_Toggle_Label, {TextColor3 = Cool_State and Cool_Theme_Config.Cool_Text_White or Cool_Theme_Config.Cool_Text_Gray}, 0.2)

                    if Cool_Callback then task.spawn(Cool_Callback, Cool_State) end
                end)
            end

            function Cool_Elements_Api:Cool_Create_Slider(Cool_Slider_Name, Cool_Flag, Cool_Min, Cool_Max, Cool_Default, Cool_Float, Cool_Tooltip_Text, Cool_Callback)
                Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] = Cool_Default or Cool_Min

                local Cool_Slider_Frame = Instance.new("Frame")
                Cool_Slider_Frame.Size = UDim2.new(1, 0, 0, 36)
                Cool_Slider_Frame.BackgroundTransparency = 1
                Cool_Slider_Frame.Parent = Cool_Section_Container

                local Cool_Slider_Label = Instance.new("TextLabel")
                Cool_Slider_Label.Size = UDim2.new(1, 0, 0, 14)
                Cool_Slider_Label.BackgroundTransparency = 1
                Cool_Slider_Label.Text = Cool_Slider_Name
                Cool_Slider_Label.TextColor3 = Cool_Theme_Config.Cool_Text_White
                Cool_Slider_Label.TextSize = 12
                Cool_Slider_Label.Font = Cool_Theme_Config.Cool_Main_Font
                Cool_Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Slider_Label.Parent = Cool_Slider_Frame

                local Cool_Slider_Value = Instance.new("TextLabel")
                Cool_Slider_Value.Size = UDim2.new(1, 0, 0, 14)
                Cool_Slider_Value.BackgroundTransparency = 1
                Cool_Slider_Value.Text = tostring(Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag])
                Cool_Slider_Value.TextColor3 = Cool_Theme_Config.Cool_Text_White
                Cool_Slider_Value.TextSize = 12
                Cool_Slider_Value.Font = Cool_Theme_Config.Cool_Mono_Font
                Cool_Slider_Value.TextXAlignment = Enum.TextXAlignment.Right
                Cool_Slider_Value.Parent = Cool_Slider_Frame

                local Cool_Slider_Bg = Instance.new("TextButton")
                Cool_Slider_Bg.Size = UDim2.new(1, 0, 0, 8)
                Cool_Slider_Bg.Position = UDim2.new(0, 0, 0, 22)
                Cool_Slider_Bg.BackgroundColor3 = Cool_Theme_Config.Cool_Element_Bg
                Cool_Slider_Bg.Text = ""
                Cool_Slider_Bg.AutoButtonColor = false
                Cool_Slider_Bg.Parent = Cool_Slider_Frame
                Cool_Apply_Corner(Cool_Slider_Bg, 4)
                local Cool_Bg_Stroke = Cool_Apply_Stroke(Cool_Slider_Bg, Cool_Theme_Config.Cool_Border_Light, 1)

                local Cool_Slider_Fill = Instance.new("Frame")
                Cool_Slider_Fill.Size = UDim2.new((Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] - Cool_Min) / (Cool_Max - Cool_Min), 0, 1, 0)
                Cool_Slider_Fill.BackgroundColor3 = Cool_Theme_Config.Cool_Accent_Primary
                Cool_Slider_Fill.Parent = Cool_Slider_Bg
                Cool_Apply_Corner(Cool_Slider_Fill, 4)

                Cool_Slider_Bg.MouseEnter:Connect(function()
                    Cool_Update_Tooltip(Cool_Tooltip_Text)
                    Cool_Tween_Instance(Cool_Bg_Stroke, {Color = Cool_Theme_Config.Cool_Text_Gray}, 0.2)
                end)
                Cool_Slider_Bg.MouseLeave:Connect(function()
                    Cool_Update_Tooltip("")
                    Cool_Tween_Instance(Cool_Bg_Stroke, {Color = Cool_Theme_Config.Cool_Border_Light}, 0.2)
                end)

                local Cool_Sliding = false

                local function Cool_Update_Value(Cool_Input)
                    local Cool_Pos = math.clamp((Cool_Input.Position.X - Cool_Slider_Bg.AbsolutePosition.X) / Cool_Slider_Bg.AbsoluteSize.X, 0, 1)
                    local Cool_Raw_Val = Cool_Min + (Cool_Max - Cool_Min) * Cool_Pos
                    local Cool_Final_Val = Cool_Float and math.floor(Cool_Raw_Val * 10) / 10 or math.floor(Cool_Raw_Val)
                    
                    Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] = Cool_Final_Val
                    Cool_Tween_Instance(Cool_Slider_Fill, {Size = UDim2.new(Cool_Pos, 0, 1, 0)}, 0.05)
                    Cool_Slider_Value.Text = tostring(Cool_Final_Val)
                    
                    if Cool_Callback then task.spawn(Cool_Callback, Cool_Final_Val) end
                end

                Cool_Slider_Bg.InputBegan:Connect(function(Cool_Input)
                    if Cool_Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Cool_Sliding = true
                        Cool_Update_Value(Cool_Input)
                    end
                end)

                Cool_User_Input_Service.InputEnded:Connect(function(Cool_Input)
                    if Cool_Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Cool_Sliding = false
                    end
                end)

                Cool_User_Input_Service.InputChanged:Connect(function(Cool_Input)
                    if Cool_Sliding and Cool_Input.UserInputType == Enum.UserInputType.MouseMovement then
                        Cool_Update_Value(Cool_Input)
                    end
                end)
            end

            function Cool_Elements_Api:Cool_Create_Dropdown(Cool_Dropdown_Name, Cool_Flag, Cool_Options, Cool_Default, Cool_Tooltip_Text, Cool_Callback)
                Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] = Cool_Default or Cool_Options[1]
                local Cool_Open = false

                local Cool_Dropdown_Frame = Instance.new("Frame")
                Cool_Dropdown_Frame.Size = UDim2.new(1, 0, 0, 46)
                Cool_Dropdown_Frame.BackgroundTransparency = 1
                Cool_Dropdown_Frame.Parent = Cool_Section_Container

                local Cool_Dropdown_Label = Instance.new("TextLabel")
                Cool_Dropdown_Label.Size = UDim2.new(1, 0, 0, 14)
                Cool_Dropdown_Label.BackgroundTransparency = 1
                Cool_Dropdown_Label.Text = Cool_Dropdown_Name
                Cool_Dropdown_Label.TextColor3 = Cool_Theme_Config.Cool_Text_White
                Cool_Dropdown_Label.TextSize = 12
                Cool_Dropdown_Label.Font = Cool_Theme_Config.Cool_Main_Font
                Cool_Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Dropdown_Label.Parent = Cool_Dropdown_Frame

                local Cool_Dropdown_Main = Instance.new("TextButton")
                Cool_Dropdown_Main.Size = UDim2.new(1, 0, 0, 24)
                Cool_Dropdown_Main.Position = UDim2.new(0, 0, 0, 20)
                Cool_Dropdown_Main.BackgroundColor3 = Cool_Theme_Config.Cool_Element_Bg
                Cool_Dropdown_Main.Text = ""
                Cool_Dropdown_Main.AutoButtonColor = false
                Cool_Dropdown_Main.Parent = Cool_Dropdown_Frame
                Cool_Apply_Corner(Cool_Dropdown_Main, 4)
                local Cool_Main_Stroke = Cool_Apply_Stroke(Cool_Dropdown_Main, Cool_Theme_Config.Cool_Border_Light, 1)

                local Cool_Selected_Text = Instance.new("TextLabel")
                Cool_Selected_Text.Size = UDim2.new(1, -16, 1, 0)
                Cool_Selected_Text.Position = UDim2.new(0, 8, 0, 0)
                Cool_Selected_Text.BackgroundTransparency = 1
                Cool_Selected_Text.Text = Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag]
                Cool_Selected_Text.TextColor3 = Cool_Theme_Config.Cool_Text_Gray
                Cool_Selected_Text.TextSize = 12
                Cool_Selected_Text.Font = Cool_Theme_Config.Cool_Main_Font
                Cool_Selected_Text.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Selected_Text.Parent = Cool_Dropdown_Main

                local Cool_Dropdown_Icon = Instance.new("ImageLabel")
                Cool_Dropdown_Icon.Size = UDim2.new(0, 14, 0, 14)
                Cool_Dropdown_Icon.Position = UDim2.new(1, -20, 0.5, -7)
                Cool_Dropdown_Icon.BackgroundTransparency = 1
                Cool_Dropdown_Icon.Image = "rbxassetid://6031090656"
                Cool_Dropdown_Icon.ImageColor3 = Cool_Theme_Config.Cool_Text_Gray
                Cool_Dropdown_Icon.Parent = Cool_Dropdown_Main

                local Cool_Dropdown_Scroll = Instance.new("ScrollingFrame")
                Cool_Dropdown_Scroll.Size = UDim2.new(1, 0, 0, 0)
                Cool_Dropdown_Scroll.Position = UDim2.new(0, 0, 0, 48)
                Cool_Dropdown_Scroll.BackgroundColor3 = Cool_Theme_Config.Cool_Element_Bg
                Cool_Dropdown_Scroll.BorderSizePixel = 0
                Cool_Dropdown_Scroll.ScrollBarThickness = 2
                Cool_Dropdown_Scroll.ScrollBarImageColor3 = Cool_Theme_Config.Cool_Accent_Primary
                Cool_Dropdown_Scroll.ClipsDescendants = true
                Cool_Dropdown_Scroll.ZIndex = 10
                Cool_Dropdown_Scroll.Parent = Cool_Dropdown_Frame
                Cool_Apply_Corner(Cool_Dropdown_Scroll, 4)
                local Cool_Scroll_Stroke = Cool_Apply_Stroke(Cool_Dropdown_Scroll, Cool_Theme_Config.Cool_Border_Light, 1)
                Cool_Scroll_Stroke.Transparency = 1

                local Cool_Scroll_Layout = Instance.new("UIListLayout")
                Cool_Scroll_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Cool_Scroll_Layout.Parent = Cool_Dropdown_Scroll

                local function Cool_Toggle_Dropdown()
                    Cool_Open = not Cool_Open
                    local Cool_Target_Size = Cool_Open and math.min(#Cool_Options * 24, 120) or 0
                    
                    Cool_Tween_Instance(Cool_Dropdown_Icon, {Rotation = Cool_Open and 180 or 0}, 0.2)
                    Cool_Tween_Instance(Cool_Main_Stroke, {Color = Cool_Open and Cool_Theme_Config.Cool_Accent_Primary or Cool_Theme_Config.Cool_Border_Light}, 0.2)
                    Cool_Tween_Instance(Cool_Dropdown_Scroll, {Size = UDim2.new(1, 0, 0, Cool_Target_Size)}, 0.2)
                    Cool_Tween_Instance(Cool_Scroll_Stroke, {Transparency = Cool_Open and 0 or 1}, 0.2)
                    
                    Cool_Tween_Instance(Cool_Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 46 + Cool_Target_Size + (Cool_Open and 4 or 0))}, 0.2)
                end

                Cool_Dropdown_Main.MouseEnter:Connect(function()
                    Cool_Update_Tooltip(Cool_Tooltip_Text)
                    if not Cool_Open then Cool_Tween_Instance(Cool_Main_Stroke, {Color = Cool_Theme_Config.Cool_Text_Gray}, 0.2) end
                end)
                Cool_Dropdown_Main.MouseLeave:Connect(function()
                    Cool_Update_Tooltip("")
                    if not Cool_Open then Cool_Tween_Instance(Cool_Main_Stroke, {Color = Cool_Theme_Config.Cool_Border_Light}, 0.2) end
                end)
                Cool_Dropdown_Main.MouseButton1Click:Connect(Cool_Toggle_Dropdown)

                for _, Cool_Opt in ipairs(Cool_Options) do
                    local Cool_Option_Btn = Instance.new("TextButton")
                    Cool_Option_Btn.Size = UDim2.new(1, 0, 0, 24)
                    Cool_Option_Btn.BackgroundColor3 = Cool_Theme_Config.Cool_Hover_Bg
                    Cool_Option_Btn.BackgroundTransparency = 1
                    Cool_Option_Btn.Text = ""
                    Cool_Option_Btn.ZIndex = 11
                    Cool_Option_Btn.Parent = Cool_Dropdown_Scroll

                    local Cool_Option_Label = Instance.new("TextLabel")
                    Cool_Option_Label.Size = UDim2.new(1, -16, 1, 0)
                    Cool_Option_Label.Position = UDim2.new(0, 8, 0, 0)
                    Cool_Option_Label.BackgroundTransparency = 1
                    Cool_Option_Label.Text = Cool_Opt
                    Cool_Option_Label.TextColor3 = Cool_Theme_Config.Cool_Text_Gray
                    Cool_Option_Label.TextSize = 12
                    Cool_Option_Label.Font = Cool_Theme_Config.Cool_Main_Font
                    Cool_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Option_Label.ZIndex = 11
                    Cool_Option_Label.Parent = Cool_Option_Btn

                    Cool_Option_Btn.MouseEnter:Connect(function()
                        Cool_Tween_Instance(Cool_Option_Btn, {BackgroundTransparency = 0.5}, 0.15)
                        Cool_Tween_Instance(Cool_Option_Label, {TextColor3 = Cool_Theme_Config.Cool_Accent_Primary}, 0.15)
                    end)
                    Cool_Option_Btn.MouseLeave:Connect(function()
                        Cool_Tween_Instance(Cool_Option_Btn, {BackgroundTransparency = 1}, 0.15)
                        if Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] ~= Cool_Opt then
                            Cool_Tween_Instance(Cool_Option_Label, {TextColor3 = Cool_Theme_Config.Cool_Text_Gray}, 0.15)
                        else
                            Cool_Tween_Instance(Cool_Option_Label, {TextColor3 = Cool_Theme_Config.Cool_Text_White}, 0.15)
                        end
                    end)

                    Cool_Option_Btn.MouseButton1Click:Connect(function()
                        Cool_Nixware_Evolution_Api.Cool_Flags[Cool_Flag] = Cool_Opt
                        Cool_Selected_Text.Text = Cool_Opt
                        Cool_Toggle_Dropdown()
                        for _, Cool_Child in ipairs(Cool_Dropdown_Scroll:GetChildren()) do
                            if Cool_Child:IsA("TextButton") then
                                Cool_Child:FindFirstChildOfClass("TextLabel").TextColor3 = Cool_Theme_Config.Cool_Text_Gray
                            end
                        end
                        Cool_Option_Label.TextColor3 = Cool_Theme_Config.Cool_Text_White
                        if Cool_Callback then task.spawn(Cool_Callback, Cool_Opt) end
                    end)
                end
                Cool_Dropdown_Scroll.CanvasSize = UDim2.new(0, 0, 0, Cool_Scroll_Layout.AbsoluteContentSize.Y)
            end

            function Cool_Elements_Api:Cool_Create_Button(Cool_Button_Name, Cool_Tooltip_Text, Cool_Callback)
                local Cool_Button_Frame = Instance.new("Frame")
                Cool_Button_Frame.Size = UDim2.new(1, 0, 0, 28)
                Cool_Button_Frame.BackgroundTransparency = 1
                Cool_Button_Frame.Parent = Cool_Section_Container

                local Cool_Button_Btn = Instance.new("TextButton")
                Cool_Button_Btn.Size = UDim2.new(1, 0, 1, 0)
                Cool_Button_Btn.BackgroundColor3 = Cool_Theme_Config.Cool_Element_Bg
                Cool_Button_Btn.Text = Cool_Button_Name
                Cool_Button_Btn.TextColor3 = Cool_Theme_Config.Cool_Text_White
                Cool_Button_Btn.TextSize = 12
                Cool_Button_Btn.Font = Cool_Theme_Config.Cool_Bold_Font
                Cool_Button_Btn.AutoButtonColor = false
                Cool_Button_Btn.Parent = Cool_Button_Frame
                Cool_Apply_Corner(Cool_Button_Btn, 4)
                local Cool_Btn_Stroke = Cool_Apply_Stroke(Cool_Button_Btn, Cool_Theme_Config.Cool_Border_Light, 1)

                Cool_Button_Btn.MouseEnter:Connect(function()
                    Cool_Update_Tooltip(Cool_Tooltip_Text)
                    Cool_Tween_Instance(Cool_Button_Btn, {BackgroundColor3 = Cool_Theme_Config.Cool_Hover_Bg}, 0.2)
                    Cool_Tween_Instance(Cool_Btn_Stroke, {Color = Cool_Theme_Config.Cool_Accent_Primary}, 0.2)
                end)

                Cool_Button_Btn.MouseLeave:Connect(function()
                    Cool_Update_Tooltip("")
                    Cool_Tween_Instance(Cool_Button_Btn, {BackgroundColor3 = Cool_Theme_Config.Cool_Element_Bg}, 0.2)
                    Cool_Tween_Instance(Cool_Btn_Stroke, {Color = Cool_Theme_Config.Cool_Border_Light}, 0.2)
                end)

                Cool_Button_Btn.MouseButton1Down:Connect(function()
                    Cool_Tween_Instance(Cool_Button_Btn, {Size = UDim2.new(0.96, 0, 0.9, 0), Position = UDim2.new(0.02, 0, 0.05, 0)}, 0.1)
                end)

                Cool_Button_Btn.MouseButton1Up:Connect(function()
                    Cool_Tween_Instance(Cool_Button_Btn, {Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0)}, 0.1)
                    if Cool_Callback then task.spawn(Cool_Callback) end
                end)
            end

            return Cool_Elements_Api
        end

        return Cool_Section_Api
    end

    return Cool_Tab_Api
end

return Cool_Nixware_Evolution_Api
