local Core_Gui = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")
local Tween_Service = game:GetService("TweenService")
local Text_Service = game:GetService("TextService")

local Nixware_Premium_Api = {
    Cool_Flags = {}
}

local Cool_Colors = {
    Main_Bg = Color3.fromRGB(15, 15, 15),
    Sidebar_Bg = Color3.fromRGB(12, 12, 12),
    Group_Bg = Color3.fromRGB(15, 15, 15),
    Border = Color3.fromRGB(35, 35, 35),
    Border_Dark = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(80, 110, 240),
    Accent_Gradient = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 110, 240)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(130, 80, 240))
    },
    Text_White = Color3.fromRGB(220, 220, 220),
    Text_Dark = Color3.fromRGB(120, 120, 120),
    Element_Bg = Color3.fromRGB(22, 22, 22),
    Element_Hover = Color3.fromRGB(30, 30, 30),
    Tooltip_Bg = Color3.fromRGB(10, 10, 10)
}

local Cool_Font = Enum.Font.RobotoMono

local Cool_Tooltip_Gui = Instance.new("ScreenGui")
Cool_Tooltip_Gui.Name = "Nixware_Tooltip_Layer"
Cool_Tooltip_Gui.Parent = Core_Gui
Cool_Tooltip_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Cool_Tooltip_Frame = Instance.new("Frame")
Cool_Tooltip_Frame.BackgroundColor3 = Cool_Colors.Tooltip_Bg
Cool_Tooltip_Frame.BorderSizePixel = 0
Cool_Tooltip_Frame.Visible = false
Cool_Tooltip_Frame.ZIndex = 100
Cool_Tooltip_Frame.Parent = Cool_Tooltip_Gui

local Cool_Tooltip_Stroke = Instance.new("UIStroke")
Cool_Tooltip_Stroke.Color = Cool_Colors.Border
Cool_Tooltip_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
Cool_Tooltip_Stroke.Parent = Cool_Tooltip_Frame

local Cool_Tooltip_Text = Instance.new("TextLabel")
Cool_Tooltip_Text.Size = UDim2.new(1, -12, 1, 0)
Cool_Tooltip_Text.Position = UDim2.new(0, 6, 0, 0)
Cool_Tooltip_Text.BackgroundTransparency = 1
Cool_Tooltip_Text.TextColor3 = Cool_Colors.Text_White
Cool_Tooltip_Text.TextSize = 11
Cool_Tooltip_Text.Font = Cool_Font
Cool_Tooltip_Text.TextXAlignment = Enum.TextXAlignment.Left
Cool_Tooltip_Text.ZIndex = 101
Cool_Tooltip_Text.Parent = Cool_Tooltip_Frame

local Tooltip_Conn = nil

local function Cool_Show_Tooltip(Text_Str)
    if not Text_Str or Text_Str == "" then return end
    local Bounds = Text_Service:GetTextSize(Text_Str, 11, Cool_Font, Vector2.new(500, 20))
    Cool_Tooltip_Frame.Size = UDim2.new(0, Bounds.X + 12, 0, 20)
    Cool_Tooltip_Text.Text = Text_Str
    Cool_Tooltip_Frame.Visible = true
    
    if Tooltip_Conn then Tooltip_Conn:Disconnect() end
    Tooltip_Conn = Run_Service.RenderStepped:Connect(function()
        local Mouse = User_Input_Service:GetMouseLocation()
        Cool_Tooltip_Frame.Position = UDim2.new(0, Mouse.X + 12, 0, Mouse.Y - 12)
    end)
end

local function Cool_Hide_Tooltip()
    Cool_Tooltip_Frame.Visible = false
    if Tooltip_Conn then
        Tooltip_Conn:Disconnect()
        Tooltip_Conn = nil
    end
end

local function Cool_Animate(Object, Props, Speed)
    local Tween = Tween_Service:Create(Object, TweenInfo.new(Speed or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), Props)
    Tween:Play()
    return Tween
end

function Nixware_Premium_Api:Cool_Window_Create(Window_Name)
    local Cool_Screen = Instance.new("ScreenGui")
    Cool_Screen.Name = "Nixware_Evolution"
    Cool_Screen.Parent = Core_Gui
    Cool_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Cool_Main_Outline = Instance.new("Frame")
    Cool_Main_Outline.Size = UDim2.new(0, 680, 0, 480)
    Cool_Main_Outline.Position = UDim2.new(0.5, -340, 0.5, -240)
    Cool_Main_Outline.BackgroundColor3 = Cool_Colors.Border_Dark
    Cool_Main_Outline.BorderSizePixel = 1
    Cool_Main_Outline.BorderColor3 = Color3.new(0, 0, 0)
    Cool_Main_Outline.Parent = Cool_Screen

    local Cool_Main_Bg = Instance.new("Frame")
    Cool_Main_Bg.Size = UDim2.new(1, -2, 1, -2)
    Cool_Main_Bg.Position = UDim2.new(0, 1, 0, 1)
    Cool_Main_Bg.BackgroundColor3 = Cool_Colors.Main_Bg
    Cool_Main_Bg.BorderSizePixel = 0
    Cool_Main_Bg.Parent = Cool_Main_Outline

    local Cool_Top_Bar = Instance.new("Frame")
    Cool_Top_Bar.Size = UDim2.new(1, 0, 0, 26)
    Cool_Top_Bar.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Top_Bar.BorderSizePixel = 0
    Cool_Top_Bar.Parent = Cool_Main_Bg

    local Cool_Top_Border = Instance.new("Frame")
    Cool_Top_Border.Size = UDim2.new(1, 0, 0, 1)
    Cool_Top_Border.Position = UDim2.new(0, 0, 1, 0)
    Cool_Top_Border.BackgroundColor3 = Cool_Colors.Border
    Cool_Top_Border.BorderSizePixel = 0
    Cool_Top_Border.Parent = Cool_Top_Bar

    local Cool_Accent_Line = Instance.new("Frame")
    Cool_Accent_Line.Size = UDim2.new(1, 0, 0, 2)
    Cool_Accent_Line.BackgroundColor3 = Color3.new(1, 1, 1)
    Cool_Accent_Line.BorderSizePixel = 0
    Cool_Accent_Line.Parent = Cool_Top_Bar

    local Cool_Accent_Grad = Instance.new("UIGradient")
    Cool_Accent_Grad.Color = Cool_Colors.Accent_Gradient
    Cool_Accent_Grad.Parent = Cool_Accent_Line

    local Cool_Title = Instance.new("TextLabel")
    Cool_Title.Size = UDim2.new(1, -12, 1, -2)
    Cool_Title.Position = UDim2.new(0, 12, 0, 2)
    Cool_Title.BackgroundTransparency = 1
    Cool_Title.Text = Window_Name
    Cool_Title.TextColor3 = Cool_Colors.Text_White
    Cool_Title.TextSize = 13
    Cool_Title.Font = Enum.Font.RobotoMono
    Cool_Title.TextXAlignment = Enum.TextXAlignment.Left
    Cool_Title.Parent = Cool_Top_Bar

    local Cool_Sidebar = Instance.new("Frame")
    Cool_Sidebar.Size = UDim2.new(0, 140, 1, -27)
    Cool_Sidebar.Position = UDim2.new(0, 0, 0, 27)
    Cool_Sidebar.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Sidebar.BorderSizePixel = 0
    Cool_Sidebar.Parent = Cool_Main_Bg

    local Cool_Sidebar_Border = Instance.new("Frame")
    Cool_Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
    Cool_Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
    Cool_Sidebar_Border.BackgroundColor3 = Cool_Colors.Border
    Cool_Sidebar_Border.BorderSizePixel = 0
    Cool_Sidebar_Border.ZIndex = 2
    Cool_Sidebar_Border.Parent = Cool_Sidebar

    local Cool_Tab_Layout = Instance.new("UIListLayout")
    Cool_Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Cool_Tab_Layout.Parent = Cool_Sidebar

    local Cool_Tab_Pad = Instance.new("UIPadding")
    Cool_Tab_Pad.PaddingTop = UDim.new(0, 8)
    Cool_Tab_Pad.Parent = Cool_Sidebar

    local Cool_Content_Area = Instance.new("Frame")
    Cool_Content_Area.Size = UDim2.new(1, -141, 1, -27)
    Cool_Content_Area.Position = UDim2.new(0, 141, 0, 27)
    Cool_Content_Area.BackgroundTransparency = 1
    Cool_Content_Area.Parent = Cool_Main_Bg

    local Dragging, Drag_Start, Start_Pos
    Cool_Top_Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Drag_Start = Input.Position
            Start_Pos = Cool_Main_Outline.Position
        end
    end)
    User_Input_Service.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - Drag_Start
            Cool_Main_Outline.Position = UDim2.new(Start_Pos.X.Scale, Start_Pos.X.Offset + Delta.X, Start_Pos.Y.Scale, Start_Pos.Y.Offset + Delta.Y)
        end
    end)
    User_Input_Service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)

    local Cool_Window_Context = { Tabs = {}, Buttons = {} }

    function Cool_Window_Context:Cool_Tab_Create(Tab_Name)
        local Cool_Tab_Btn = Instance.new("TextButton")
        Cool_Tab_Btn.Size = UDim2.new(1, 0, 0, 32)
        Cool_Tab_Btn.BackgroundTransparency = 1
        Cool_Tab_Btn.Text = "   " .. Tab_Name
        Cool_Tab_Btn.TextColor3 = Cool_Colors.Text_Dark
        Cool_Tab_Btn.TextSize = 13
        Cool_Tab_Btn.Font = Cool_Font
        Cool_Tab_Btn.TextXAlignment = Enum.TextXAlignment.Left
        Cool_Tab_Btn.AutoButtonColor = false
        Cool_Tab_Btn.Parent = Cool_Sidebar

        local Cool_Tab_Indicator = Instance.new("Frame")
        Cool_Tab_Indicator.Size = UDim2.new(0, 2, 1, -12)
        Cool_Tab_Indicator.Position = UDim2.new(0, 0, 0, 6)
        Cool_Tab_Indicator.BackgroundColor3 = Cool_Colors.Accent
        Cool_Tab_Indicator.BorderSizePixel = 0
        Cool_Tab_Indicator.BackgroundTransparency = 1
        Cool_Tab_Indicator.Parent = Cool_Tab_Btn

        local Cool_Page = Instance.new("ScrollingFrame")
        Cool_Page.Size = UDim2.new(1, 0, 1, 0)
        Cool_Page.BackgroundTransparency = 1
        Cool_Page.BorderSizePixel = 0
        Cool_Page.ScrollBarThickness = 2
        Cool_Page.ScrollBarImageColor3 = Cool_Colors.Accent
        Cool_Page.Visible = false
        Cool_Page.Parent = Cool_Content_Area

        local Cool_Left_Col = Instance.new("Frame")
        Cool_Left_Col.Size = UDim2.new(0.5, -16, 1, 0)
        Cool_Left_Col.Position = UDim2.new(0, 12, 0, 12)
        Cool_Left_Col.BackgroundTransparency = 1
        Cool_Left_Col.Parent = Cool_Page

        local Cool_Right_Col = Instance.new("Frame")
        Cool_Right_Col.Size = UDim2.new(0.5, -16, 1, 0)
        Cool_Right_Col.Position = UDim2.new(0.5, 4, 0, 12)
        Cool_Right_Col.BackgroundTransparency = 1
        Cool_Right_Col.Parent = Cool_Page

        local Cool_Left_Layout = Instance.new("UIListLayout")
        Cool_Left_Layout.Padding = UDim.new(0, 14)
        Cool_Left_Layout.Parent = Cool_Left_Col

        local Cool_Right_Layout = Instance.new("UIListLayout")
        Cool_Right_Layout.Padding = UDim.new(0, 14)
        Cool_Right_Layout.Parent = Cool_Right_Col

        table.insert(Cool_Window_Context.Tabs, Cool_Page)
        table.insert(Cool_Window_Context.Buttons, { Btn = Cool_Tab_Btn, Ind = Cool_Tab_Indicator })

        local function Cool_Activate_Tab()
            for _, T in pairs(Cool_Window_Context.Tabs) do T.Visible = false end
            for _, B in pairs(Cool_Window_Context.Buttons) do
                Cool_Animate(B.Btn, {TextColor3 = Cool_Colors.Text_Dark}, 0.2)
                Cool_Animate(B.Ind, {BackgroundTransparency = 1}, 0.2)
            end
            Cool_Page.Visible = true
            Cool_Animate(Cool_Tab_Btn, {TextColor3 = Cool_Colors.Text_White}, 0.2)
            Cool_Animate(Cool_Tab_Indicator, {BackgroundTransparency = 0}, 0.2)
        end

        if #Cool_Window_Context.Tabs == 1 then Cool_Activate_Tab() end
        Cool_Tab_Btn.MouseButton1Click:Connect(Cool_Activate_Tab)

        local function Cool_Sync_Canvas()
            local Y = math.max(Cool_Left_Layout.AbsoluteContentSize.Y, Cool_Right_Layout.AbsoluteContentSize.Y)
            Cool_Page.CanvasSize = UDim2.new(0, 0, 0, Y + 24)
        end

        Cool_Left_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Cool_Sync_Canvas)
        Cool_Right_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Cool_Sync_Canvas)

        local Cool_Section_Api = {}

        function Cool_Section_Api:Cool_Section_Create(Side_Str, Section_Title_Str)
            local Cool_Sect_Bg = Instance.new("Frame")
            Cool_Sect_Bg.Size = UDim2.new(1, 0, 0, 20)
            Cool_Sect_Bg.BackgroundColor3 = Cool_Colors.Group_Bg
            Cool_Sect_Bg.BorderSizePixel = 0
            Cool_Sect_Bg.Parent = (Side_Str == "Left") and Cool_Left_Col or Cool_Right_Col

            local Cool_Sect_Stroke = Instance.new("UIStroke")
            Cool_Sect_Stroke.Color = Cool_Colors.Border
            Cool_Sect_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
            Cool_Sect_Stroke.Parent = Cool_Sect_Bg

            local Cool_Sect_Label = Instance.new("TextLabel")
            Cool_Sect_Label.Position = UDim2.new(0, 10, 0, -8)
            Cool_Sect_Label.Size = UDim2.new(0, 0, 0, 16)
            Cool_Sect_Label.AutomaticSize = Enum.AutomaticSize.X
            Cool_Sect_Label.BackgroundColor3 = Cool_Colors.Main_Bg
            Cool_Sect_Label.BorderSizePixel = 0
            Cool_Sect_Label.Text = " " .. Section_Title_Str .. " "
            Cool_Sect_Label.TextColor3 = Cool_Colors.Text_White
            Cool_Sect_Label.TextSize = 12
            Cool_Sect_Label.Font = Cool_Font
            Cool_Sect_Label.ZIndex = 2
            Cool_Sect_Label.Parent = Cool_Sect_Bg

            local Cool_Sect_Content = Instance.new("Frame")
            Cool_Sect_Content.Size = UDim2.new(1, 0, 1, -16)
            Cool_Sect_Content.Position = UDim2.new(0, 0, 0, 16)
            Cool_Sect_Content.BackgroundTransparency = 1
            Cool_Sect_Content.Parent = Cool_Sect_Bg

            local Cool_Layout = Instance.new("UIListLayout")
            Cool_Layout.Padding = UDim.new(0, 8)
            Cool_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Cool_Layout.Parent = Cool_Sect_Content

            local Cool_Pad = Instance.new("UIPadding")
            Cool_Pad.PaddingTop = UDim.new(0, 4)
            Cool_Pad.PaddingBottom = UDim.new(0, 10)
            Cool_Pad.Parent = Cool_Sect_Content

            Cool_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Cool_Sect_Bg.Size = UDim2.new(1, 0, 0, Cool_Layout.AbsoluteContentSize.Y + 30)
            end)

            local function Cool_Element_Injector(Target_Container)
                local Cool_Elements = {}

                function Cool_Elements:Cool_Toggle_Create(Name, Flag, Default, Tooltip, Callback)
                    Nixware_Premium_Api.Cool_Flags[Flag] = Default or false

                    local Cool_Tog_Btn = Instance.new("TextButton")
                    Cool_Tog_Btn.Size = UDim2.new(1, -20, 0, 16)
                    Cool_Tog_Btn.BackgroundTransparency = 1
                    Cool_Tog_Btn.Text = ""
                    Cool_Tog_Btn.Parent = Target_Container

                    local Cool_Box = Instance.new("Frame")
                    Cool_Box.Size = UDim2.new(0, 12, 0, 12)
                    Cool_Box.Position = UDim2.new(0, 0, 0.5, -6)
                    Cool_Box.BackgroundColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Accent or Cool_Colors.Element_Bg
                    Cool_Box.BorderSizePixel = 0
                    Cool_Box.Parent = Cool_Tog_Btn

                    local Cool_Box_Stroke = Instance.new("UIStroke")
                    Cool_Box_Stroke.Color = Cool_Colors.Border
                    Cool_Box_Stroke.Parent = Cool_Box

                    local Cool_Text = Instance.new("TextLabel")
                    Cool_Text.Size = UDim2.new(1, -20, 1, 0)
                    Cool_Text.Position = UDim2.new(0, 20, 0, 0)
                    Cool_Text.BackgroundTransparency = 1
                    Cool_Text.Text = Name
                    Cool_Text.TextColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                    Cool_Text.TextSize = 12
                    Cool_Text.Font = Cool_Font
                    Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Text.Parent = Cool_Tog_Btn

                    Cool_Tog_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip) end)
                    Cool_Tog_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)

                    Cool_Tog_Btn.MouseButton1Click:Connect(function()
                        Nixware_Premium_Api.Cool_Flags[Flag] = not Nixware_Premium_Api.Cool_Flags[Flag]
                        local S = Nixware_Premium_Api.Cool_Flags[Flag]
                        Cool_Animate(Cool_Box, {BackgroundColor3 = S and Cool_Colors.Accent or Cool_Colors.Element_Bg})
                        Cool_Animate(Cool_Text, {TextColor3 = S and Cool_Colors.Text_White or Cool_Colors.Text_Dark})
                        if Callback then Callback(S) end
                    end)
                end

                function Cool_Elements:Cool_Slider_Create(Name, Flag, Min, Max, Default, Tooltip, Callback)
                    Nixware_Premium_Api.Cool_Flags[Flag] = Default or Min

                    local Cool_Sld_Frame = Instance.new("Frame")
                    Cool_Sld_Frame.Size = UDim2.new(1, -20, 0, 32)
                    Cool_Sld_Frame.BackgroundTransparency = 1
                    Cool_Sld_Frame.Parent = Target_Container

                    local Cool_Text = Instance.new("TextLabel")
                    Cool_Text.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Text.BackgroundTransparency = 1
                    Cool_Text.Text = Name
                    Cool_Text.TextColor3 = Cool_Colors.Text_White
                    Cool_Text.TextSize = 12
                    Cool_Text.Font = Cool_Font
                    Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Text.Parent = Cool_Sld_Frame

                    local Cool_Val = Instance.new("TextLabel")
                    Cool_Val.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Val.BackgroundTransparency = 1
                    Cool_Val.Text = tostring(Nixware_Premium_Api.Cool_Flags[Flag])
                    Cool_Val.TextColor3 = Cool_Colors.Text_White
                    Cool_Val.TextSize = 12
                    Cool_Val.Font = Cool_Font
                    Cool_Val.TextXAlignment = Enum.TextXAlignment.Right
                    Cool_Val.Parent = Cool_Sld_Frame

                    local Cool_Bg = Instance.new("Frame")
                    Cool_Bg.Size = UDim2.new(1, 0, 0, 6)
                    Cool_Bg.Position = UDim2.new(0, 0, 0, 20)
                    Cool_Bg.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Bg.BorderSizePixel = 0
                    Cool_Bg.Parent = Cool_Sld_Frame

                    local Cool_Bg_Stroke = Instance.new("UIStroke")
                    Cool_Bg_Stroke.Color = Cool_Colors.Border
                    Cool_Bg_Stroke.Parent = Cool_Bg

                    local Cool_Fill = Instance.new("Frame")
                    Cool_Fill.Size = UDim2.new((Nixware_Premium_Api.Cool_Flags[Flag] - Min) / (Max - Min), 0, 1, 0)
                    Cool_Fill.BackgroundColor3 = Cool_Colors.Accent
                    Cool_Fill.BorderSizePixel = 0
                    Cool_Fill.Parent = Cool_Bg

                    Cool_Bg.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip) end)
                    Cool_Bg.MouseLeave:Connect(Cool_Hide_Tooltip)

                    local Sliding = false
                    Cool_Bg.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true end
                    end)
                    User_Input_Service.InputEnded:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
                    end)

                    Run_Service.RenderStepped:Connect(function()
                        if Sliding then
                            local Pct = math.clamp((User_Input_Service:GetMouseLocation().X - Cool_Bg.AbsolutePosition.X) / Cool_Bg.AbsoluteSize.X, 0, 1)
                            local Value = math.floor(Min + ((Max - Min) * Pct))
                            Nixware_Premium_Api.Cool_Flags[Flag] = Value
                            Cool_Fill.Size = UDim2.new(Pct, 0, 1, 0)
                            Cool_Val.Text = tostring(Value)
                            if Callback then Callback(Value) end
                        end
                    end)
                end

                function Cool_Elements:Cool_Dropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
                    Nixware_Premium_Api.Cool_Flags[Flag] = Default or Options[1]
                    local Open = false

                    local Cool_Drop = Instance.new("Frame")
                    Cool_Drop.Size = UDim2.new(1, -20, 0, 40)
                    Cool_Drop.BackgroundTransparency = 1
                    Cool_Drop.ClipsDescendants = true
                    Cool_Drop.Parent = Target_Container

                    local Cool_Text = Instance.new("TextLabel")
                    Cool_Text.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Text.BackgroundTransparency = 1
                    Cool_Text.Text = Name
                    Cool_Text.TextColor3 = Cool_Colors.Text_White
                    Cool_Text.TextSize = 12
                    Cool_Text.Font = Cool_Font
                    Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Text.Parent = Cool_Drop

                    local Cool_Main_Btn = Instance.new("TextButton")
                    Cool_Main_Btn.Size = UDim2.new(1, 0, 0, 20)
                    Cool_Main_Btn.Position = UDim2.new(0, 0, 0, 18)
                    Cool_Main_Btn.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Main_Btn.BorderSizePixel = 0
                    Cool_Main_Btn.Text = "  " .. Nixware_Premium_Api.Cool_Flags[Flag]
                    Cool_Main_Btn.TextColor3 = Cool_Colors.Text_Dark
                    Cool_Main_Btn.TextSize = 12
                    Cool_Main_Btn.Font = Cool_Font
                    Cool_Main_Btn.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Main_Btn.Parent = Cool_Drop

                    local Cool_Main_Stroke = Instance.new("UIStroke")
                    Cool_Main_Stroke.Color = Cool_Colors.Border
                    Cool_Main_Stroke.Parent = Cool_Main_Btn

                    local Cool_List = Instance.new("Frame")
                    Cool_List.Size = UDim2.new(1, 0, 0, 0)
                    Cool_List.Position = UDim2.new(0, 0, 0, 39)
                    Cool_List.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_List.BorderSizePixel = 0
                    Cool_List.Parent = Cool_Drop

                    local Cool_List_Stroke = Instance.new("UIStroke")
                    Cool_List_Stroke.Color = Cool_Colors.Border
                    Cool_List_Stroke.Parent = Cool_List

                    local Cool_List_Layout = Instance.new("UIListLayout")
                    Cool_List_Layout.Parent = Cool_List

                    local function Cool_Toggle_Menu()
                        Open = not Open
                        Cool_Animate(Cool_Drop, {Size = UDim2.new(1, -20, 0, Open and (39 + (#Options * 20)) or 40)})
                        Cool_Animate(Cool_List, {Size = UDim2.new(1, 0, 0, Open and (#Options * 20) or 0)})
                        Cool_Animate(Cool_Main_Stroke, {Color = Open and Cool_Colors.Accent or Cool_Colors.Border})
                    end

                    for _, Opt in ipairs(Options) do
                        local Cool_Opt = Instance.new("TextButton")
                        Cool_Opt.Size = UDim2.new(1, 0, 0, 20)
                        Cool_Opt.BackgroundTransparency = 1
                        Cool_Opt.Text = "  " .. Opt
                        Cool_Opt.TextColor3 = Cool_Colors.Text_White
                        Cool_Opt.TextSize = 12
                        Cool_Opt.Font = Cool_Font
                        Cool_Opt.TextXAlignment = Enum.TextXAlignment.Left
                        Cool_Opt.Parent = Cool_List

                        Cool_Opt.MouseEnter:Connect(function() Cool_Animate(Cool_Opt, {TextColor3 = Cool_Colors.Accent}) end)
                        Cool_Opt.MouseLeave:Connect(function() Cool_Animate(Cool_Opt, {TextColor3 = Cool_Colors.Text_White}) end)
                        Cool_Opt.MouseButton1Click:Connect(function()
                            Nixware_Premium_Api.Cool_Flags[Flag] = Opt
                            Cool_Main_Btn.Text = "  " .. Opt
                            Cool_Toggle_Menu()
                            if Callback then Callback(Opt) end
                        end)
                    end

                    Cool_Main_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip) end)
                    Cool_Main_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)
                    Cool_Main_Btn.MouseButton1Click:Connect(Cool_Toggle_Menu)
                end

                function Cool_Elements:Cool_ColorPicker_Create(Name, Flag, Default, Tooltip, Callback)
                    Nixware_Premium_Api.Cool_Flags[Flag] = Default or Color3.new(1, 1, 1)
                    local Open = false

                    local Cool_Col_Frame = Instance.new("Frame")
                    Cool_Col_Frame.Size = UDim2.new(1, -20, 0, 20)
                    Cool_Col_Frame.BackgroundTransparency = 1
                    Cool_Col_Frame.ClipsDescendants = true
                    Cool_Col_Frame.Parent = Target_Container

                    local Cool_Main_Btn = Instance.new("TextButton")
                    Cool_Main_Btn.Size = UDim2.new(1, 0, 0, 20)
                    Cool_Main_Btn.BackgroundTransparency = 1
                    Cool_Main_Btn.Text = ""
                    Cool_Main_Btn.Parent = Cool_Col_Frame

                    local Cool_Text = Instance.new("TextLabel")
                    Cool_Text.Size = UDim2.new(1, -25, 1, 0)
                    Cool_Text.BackgroundTransparency = 1
                    Cool_Text.Text = Name
                    Cool_Text.TextColor3 = Cool_Colors.Text_White
                    Cool_Text.TextSize = 12
                    Cool_Text.Font = Cool_Font
                    Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Text.Parent = Cool_Main_Btn

                    local Cool_Prev = Instance.new("Frame")
                    Cool_Prev.Size = UDim2.new(0, 20, 0, 10)
                    Cool_Prev.Position = UDim2.new(1, -20, 0.5, -5)
                    Cool_Prev.BackgroundColor3 = Nixware_Premium_Api.Cool_Flags[Flag]
                    Cool_Prev.BorderSizePixel = 0
                    Cool_Prev.Parent = Cool_Main_Btn

                    local Cool_Prev_Stroke = Instance.new("UIStroke")
                    Cool_Prev_Stroke.Color = Cool_Colors.Border
                    Cool_Prev_Stroke.Parent = Cool_Prev

                    local Cool_Expand = Instance.new("Frame")
                    Cool_Expand.Size = UDim2.new(1, 0, 0, 60)
                    Cool_Expand.Position = UDim2.new(0, 0, 0, 20)
                    Cool_Expand.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Expand.BorderSizePixel = 0
                    Cool_Expand.Parent = Cool_Col_Frame

                    local Cool_Exp_Stroke = Instance.new("UIStroke")
                    Cool_Exp_Stroke.Color = Cool_Colors.Border
                    Cool_Exp_Stroke.Parent = Cool_Expand

                    Cool_Main_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip) end)
                    Cool_Main_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)

                    Cool_Main_Btn.MouseButton1Click:Connect(function()
                        Open = not Open
                        Cool_Animate(Cool_Col_Frame, {Size = UDim2.new(1, -20, 0, Open and 85 or 20)})
                    end)

                    local R, G, B = Nixware_Premium_Api.Cool_Flags[Flag].R, Nixware_Premium_Api.Cool_Flags[Flag].G, Nixware_Premium_Api.Cool_Flags[Flag].B

                    local function Cool_Sync()
                        local Col = Color3.new(R, G, B)
                        Nixware_Premium_Api.Cool_Flags[Flag] = Col
                        Cool_Prev.BackgroundColor3 = Col
                        if Callback then Callback(Col) end
                    end

                    local function Cool_Rgb_Slider(Y_Off, C_Val, Exec)
                        local Frm = Instance.new("Frame")
                        Frm.Size = UDim2.new(1, -10, 0, 12)
                        Frm.Position = UDim2.new(0, 5, 0, Y_Off)
                        Frm.BackgroundTransparency = 1
                        Frm.Parent = Cool_Expand

                        local Bg = Instance.new("Frame")
                        Bg.Size = UDim2.new(1, 0, 0, 6)
                        Bg.Position = UDim2.new(0, 0, 0.5, -3)
                        Bg.BackgroundColor3 = Cool_Colors.Main_Bg
                        Bg.BorderSizePixel = 0
                        Bg.Parent = Frm

                        local Strk = Instance.new("UIStroke")
                        Strk.Color = Cool_Colors.Border
                        Strk.Parent = Bg

                        local Fil = Instance.new("Frame")
                        Fil.Size = UDim2.new(C_Val, 0, 1, 0)
                        Fil.BackgroundColor3 = Cool_Colors.Accent
                        Fil.BorderSizePixel = 0
                        Fil.Parent = Bg

                        local Sld = false
                        Bg.InputBegan:Connect(function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sld = true end
                        end)
                        User_Input_Service.InputEnded:Connect(function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sld = false end
                        end)
                        Run_Service.RenderStepped:Connect(function()
                            if Sld then
                                local Pct = math.clamp((User_Input_Service:GetMouseLocation().X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                                Fil.Size = UDim2.new(Pct, 0, 1, 0)
                                Exec(Pct)
                            end
                        end)
                    end

                    Cool_Rgb_Slider(6, R, function(V) R = V; Cool_Sync() end)
                    Cool_Rgb_Slider(24, G, function(V) G = V; Cool_Sync() end)
                    Cool_Rgb_Slider(42, B, function(V) B = V; Cool_Sync() end)
                end

                function Cool_Elements:Cool_Module_Create(Name, Flag, Desc, Default, Tooltip, Callback)
                    Nixware_Premium_Api.Cool_Flags[Flag] = Default or false

                    local Cool_Mod_Frame = Instance.new("Frame")
                    Cool_Mod_Frame.Size = UDim2.new(1, -20, 0, 40)
                    Cool_Mod_Frame.BackgroundTransparency = 1
                    Cool_Mod_Frame.ClipsDescendants = true
                    Cool_Mod_Frame.Parent = Target_Container

                    local Cool_Mod_Btn = Instance.new("TextButton")
                    Cool_Mod_Btn.Size = UDim2.new(1, 0, 0, 40)
                    Cool_Mod_Btn.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Mod_Btn.BorderSizePixel = 0
                    Cool_Mod_Btn.Text = ""
                    Cool_Mod_Btn.Parent = Cool_Mod_Frame

                    local Cool_Btn_Stroke = Instance.new("UIStroke")
                    Cool_Btn_Stroke.Color = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Accent or Cool_Colors.Border
                    Cool_Btn_Stroke.Parent = Cool_Mod_Btn

                    local Cool_Box = Instance.new("Frame")
                    Cool_Box.Size = UDim2.new(0, 12, 0, 12)
                    Cool_Box.Position = UDim2.new(0, 12, 0.5, -6)
                    Cool_Box.BackgroundColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Accent or Cool_Colors.Element_Bg
                    Cool_Box.BorderSizePixel = 0
                    Cool_Box.Parent = Cool_Mod_Btn

                    local Cool_Box_Stroke = Instance.new("UIStroke")
                    Cool_Box_Stroke.Color = Cool_Colors.Border
                    Cool_Box_Stroke.Parent = Cool_Box

                    local Cool_Text = Instance.new("TextLabel")
                    Cool_Text.Size = UDim2.new(1, -34, 0, 14)
                    Cool_Text.Position = UDim2.new(0, 34, 0, 6)
                    Cool_Text.BackgroundTransparency = 1
                    Cool_Text.Text = Name
                    Cool_Text.TextColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                    Cool_Text.TextSize = 12
                    Cool_Text.Font = Cool_Font
                    Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Text.Parent = Cool_Mod_Btn

                    local Cool_Desc = Instance.new("TextLabel")
                    Cool_Desc.Size = UDim2.new(1, -34, 0, 12)
                    Cool_Desc.Position = UDim2.new(0, 34, 0, 20)
                    Cool_Desc.BackgroundTransparency = 1
                    Cool_Desc.Text = Desc
                    Cool_Desc.TextColor3 = Cool_Colors.Text_Dark
                    Cool_Desc.TextSize = 10
                    Cool_Desc.Font = Cool_Font
                    Cool_Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Desc.Parent = Cool_Mod_Btn

                    local Cool_Mod_Content = Instance.new("Frame")
                    Cool_Mod_Content.Size = UDim2.new(1, 0, 0, 0)
                    Cool_Mod_Content.Position = UDim2.new(0, 0, 0, 42)
                    Cool_Mod_Content.BackgroundTransparency = 1
                    Cool_Mod_Content.Parent = Cool_Mod_Frame

                    local Cool_Layout = Instance.new("UIListLayout")
                    Cool_Layout.Padding = UDim.new(0, 6)
                    Cool_Layout.Parent = Cool_Mod_Content

                    Cool_Mod_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip) end)
                    Cool_Mod_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)

                    local function Cool_Sync()
                        if Nixware_Premium_Api.Cool_Flags[Flag] then
                            Cool_Animate(Cool_Mod_Frame, {Size = UDim2.new(1, -20, 0, 42 + Cool_Layout.AbsoluteContentSize.Y + 4)})
                        else
                            Cool_Animate(Cool_Mod_Frame, {Size = UDim2.new(1, -20, 0, 40)})
                        end
                    end

                    Cool_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if Nixware_Premium_Api.Cool_Flags[Flag] then Cool_Sync() end
                    end)

                    Cool_Mod_Btn.MouseButton1Click:Connect(function()
                        Nixware_Premium_Api.Cool_Flags[Flag] = not Nixware_Premium_Api.Cool_Flags[Flag]
                        local S = Nixware_Premium_Api.Cool_Flags[Flag]
                        Cool_Animate(Cool_Box, {BackgroundColor3 = S and Cool_Colors.Accent or Cool_Colors.Element_Bg})
                        Cool_Animate(Cool_Text, {TextColor3 = S and Cool_Colors.Text_White or Cool_Colors.Text_Dark})
                        Cool_Animate(Cool_Btn_Stroke, {Color = S and Cool_Colors.Accent or Cool_Colors.Border})
                        Cool_Sync()
                        if Callback then Callback(S) end
                    end)

                    if Nixware_Premium_Api.Cool_Flags[Flag] then Cool_Sync() end
                    return Cool_Inject_Elements(Cool_Mod_Content)
                end

                function Cool_Elements:Cool_Button_Create(Name, Tooltip, Callback)
                    local Cool_Btn_Frame = Instance.new("TextButton")
                    Cool_Btn_Frame.Size = UDim2.new(1, -20, 0, 24)
                    Cool_Btn_Frame.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Btn_Frame.BorderSizePixel = 0
                    Cool_Btn_Frame.Text = Name
                    Cool_Btn_Frame.TextColor3 = Cool_Colors.Text_White
                    Cool_Btn_Frame.TextSize = 12
                    Cool_Btn_Frame.Font = Cool_Font
                    Cool_Btn_Frame.Parent = Target_Container

                    local Cool_Btn_Stroke = Instance.new("UIStroke")
                    Cool_Btn_Stroke.Color = Cool_Colors.Border
                    Cool_Btn_Stroke.Parent = Cool_Btn_Frame

                    Cool_Btn_Frame.MouseEnter:Connect(function()
                        Cool_Show_Tooltip(Tooltip)
                        Cool_Animate(Cool_Btn_Frame, {BackgroundColor3 = Cool_Colors.Element_Hover})
                    end)
                    Cool_Btn_Frame.MouseLeave:Connect(function()
                        Cool_Hide_Tooltip()
                        Cool_Animate(Cool_Btn_Frame, {BackgroundColor3 = Cool_Colors.Element_Bg})
                    end)
                    Cool_Btn_Frame.MouseButton1Down:Connect(function() Cool_Animate(Cool_Btn_Stroke, {Color = Cool_Colors.Accent}) end)
                    Cool_Btn_Frame.MouseButton1Up:Connect(function()
                        Cool_Animate(Cool_Btn_Stroke, {Color = Cool_Colors.Border})
                        Callback()
                    end)
                end

                return Cool_Elements
            end

            return Cool_Element_Injector(Cool_Sect_Content)
        end

        return Cool_Section_Api
    end

    return Cool_Window_Context
end

return Nixware_Premium_Api
