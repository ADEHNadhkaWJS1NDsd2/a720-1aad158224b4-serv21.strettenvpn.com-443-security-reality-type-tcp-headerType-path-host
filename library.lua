local Core_Gui = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")
local Text_Service = game:GetService("TextService")

local Nixware_Library_Ultimate = {
    Flags = {}
}

local Cool_Theme = {
    Main_Bg = Color3.fromRGB(15, 15, 15),
    Sidebar_Bg = Color3.fromRGB(15, 15, 15),
    Section_Bg = Color3.fromRGB(15, 15, 15),
    Border = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(65, 115, 225),
    Text_White = Color3.fromRGB(215, 215, 215),
    Text_Dark = Color3.fromRGB(130, 130, 130),
    Element_Bg = Color3.fromRGB(25, 25, 25),
    Element_Hover = Color3.fromRGB(35, 35, 35),
    Tooltip_Bg = Color3.fromRGB(20, 20, 20)
}

local Cool_Font = Enum.Font.RobotoMono

local Cool_Tooltip_Gui = Instance.new("ScreenGui")
Cool_Tooltip_Gui.Name = "Nixware_Tooltip"
Cool_Tooltip_Gui.Parent = Core_Gui
Cool_Tooltip_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Cool_Tooltip_Frame = Instance.new("Frame")
Cool_Tooltip_Frame.BackgroundColor3 = Cool_Theme.Tooltip_Bg
Cool_Tooltip_Frame.BorderSizePixel = 1
Cool_Tooltip_Frame.BorderColor3 = Cool_Theme.Border
Cool_Tooltip_Frame.Visible = false
Cool_Tooltip_Frame.ZIndex = 100
Cool_Tooltip_Frame.Parent = Cool_Tooltip_Gui

local Cool_Tooltip_Label = Instance.new("TextLabel")
Cool_Tooltip_Label.Size = UDim2.new(1, -8, 1, 0)
Cool_Tooltip_Label.Position = UDim2.new(0, 4, 0, 0)
Cool_Tooltip_Label.BackgroundTransparency = 1
Cool_Tooltip_Label.TextColor3 = Cool_Theme.Text_White
Cool_Tooltip_Label.TextSize = 11
Cool_Tooltip_Label.Font = Cool_Font
Cool_Tooltip_Label.TextXAlignment = Enum.TextXAlignment.Left
Cool_Tooltip_Label.ZIndex = 101
Cool_Tooltip_Label.Parent = Cool_Tooltip_Frame

Run_Service.RenderStepped:Connect(function()
    if Cool_Tooltip_Frame.Visible then
        local Mouse_Pos = User_Input_Service:GetMouseLocation()
        Cool_Tooltip_Frame.Position = UDim2.new(0, Mouse_Pos.X + 12, 0, Mouse_Pos.Y - 12)
    end
end)

local function Cool_Show_Tooltip(Text_String)
    if not Text_String or Text_String == "" then return end
    local Text_Bounds = Text_Service:GetTextSize(Text_String, 11, Cool_Font, Vector2.new(400, 20))
    Cool_Tooltip_Frame.Size = UDim2.new(0, Text_Bounds.X + 16, 0, 20)
    Cool_Tooltip_Label.Text = Text_String
    Cool_Tooltip_Frame.Visible = true
end

local function Cool_Hide_Tooltip()
    Cool_Tooltip_Frame.Visible = false
end

function Nixware_Library_Ultimate:Cool_Window_Create(Window_Name)
    local Cool_Screen_Gui = Instance.new("ScreenGui")
    Cool_Screen_Gui.Name = "Nixware_Project"
    Cool_Screen_Gui.Parent = Core_Gui
    Cool_Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Cool_Screen_Gui.ResetOnSpawn = false

    local Cool_Main_Frame = Instance.new("Frame")
    Cool_Main_Frame.Size = UDim2.new(0, 640, 0, 450)
    Cool_Main_Frame.Position = UDim2.new(0.5, -320, 0.5, -225)
    Cool_Main_Frame.BackgroundColor3 = Cool_Theme.Main_Bg
    Cool_Main_Frame.BorderSizePixel = 0
    Cool_Main_Frame.Parent = Cool_Screen_Gui

    local Cool_Main_Stroke = Instance.new("UIStroke")
    Cool_Main_Stroke.Color = Cool_Theme.Border
    Cool_Main_Stroke.Thickness = 1
    Cool_Main_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
    Cool_Main_Stroke.Parent = Cool_Main_Frame

    local Cool_Top_Bar = Instance.new("Frame")
    Cool_Top_Bar.Size = UDim2.new(1, 0, 0, 24)
    Cool_Top_Bar.BackgroundColor3 = Cool_Theme.Main_Bg
    Cool_Top_Bar.BorderSizePixel = 0
    Cool_Top_Bar.Parent = Cool_Main_Frame

    local Cool_Top_Stroke = Instance.new("Frame")
    Cool_Top_Stroke.Size = UDim2.new(1, 0, 0, 1)
    Cool_Top_Stroke.Position = UDim2.new(0, 0, 1, 0)
    Cool_Top_Stroke.BackgroundColor3 = Cool_Theme.Border
    Cool_Top_Stroke.BorderSizePixel = 0
    Cool_Top_Stroke.ZIndex = 2
    Cool_Top_Stroke.Parent = Cool_Top_Bar

    local Cool_Accent_Top = Instance.new("Frame")
    Cool_Accent_Top.Size = UDim2.new(1, 0, 0, 2)
    Cool_Accent_Top.BackgroundColor3 = Cool_Theme.Accent
    Cool_Accent_Top.BorderSizePixel = 0
    Cool_Accent_Top.Parent = Cool_Top_Bar

    local Cool_Title = Instance.new("TextLabel")
    Cool_Title.Size = UDim2.new(1, -12, 1, -2)
    Cool_Title.Position = UDim2.new(0, 12, 0, 2)
    Cool_Title.BackgroundTransparency = 1
    Cool_Title.Text = Window_Name
    Cool_Title.TextColor3 = Cool_Theme.Text_White
    Cool_Title.TextSize = 13
    Cool_Title.Font = Cool_Font
    Cool_Title.TextXAlignment = Enum.TextXAlignment.Left
    Cool_Title.Parent = Cool_Top_Bar

    local Cool_Sidebar = Instance.new("Frame")
    Cool_Sidebar.Size = UDim2.new(0, 140, 1, -25)
    Cool_Sidebar.Position = UDim2.new(0, 0, 0, 25)
    Cool_Sidebar.BackgroundColor3 = Cool_Theme.Sidebar_Bg
    Cool_Sidebar.BorderSizePixel = 0
    Cool_Sidebar.Parent = Cool_Main_Frame

    local Cool_Sidebar_Stroke = Instance.new("Frame")
    Cool_Sidebar_Stroke.Size = UDim2.new(0, 1, 1, 0)
    Cool_Sidebar_Stroke.Position = UDim2.new(1, 0, 0, 0)
    Cool_Sidebar_Stroke.BackgroundColor3 = Cool_Theme.Border
    Cool_Sidebar_Stroke.BorderSizePixel = 0
    Cool_Sidebar_Stroke.ZIndex = 2
    Cool_Sidebar_Stroke.Parent = Cool_Sidebar

    local Cool_Tab_Layout = Instance.new("UIListLayout")
    Cool_Tab_Layout.Padding = UDim.new(0, 0)
    Cool_Tab_Layout.Parent = Cool_Sidebar

    local Cool_Tab_Padding = Instance.new("UIPadding")
    Cool_Tab_Padding.PaddingTop = UDim.new(0, 10)
    Cool_Tab_Padding.Parent = Cool_Sidebar

    local Cool_Content_Area = Instance.new("Frame")
    Cool_Content_Area.Size = UDim2.new(1, -141, 1, -25)
    Cool_Content_Area.Position = UDim2.new(0, 141, 0, 25)
    Cool_Content_Area.BackgroundTransparency = 1
    Cool_Content_Area.Parent = Cool_Main_Frame

    local Dragging, Drag_Start, Start_Pos
    Cool_Top_Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Drag_Start = Input.Position
            Start_Pos = Cool_Main_Frame.Position
        end
    end)
    User_Input_Service.InputChanged:Connect(function(Input)
        if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = Input.Position - Drag_Start
            Cool_Main_Frame.Position = UDim2.new(Start_Pos.X.Scale, Start_Pos.X.Offset + Delta.X, Start_Pos.Y.Scale, Start_Pos.Y.Offset + Delta.Y)
        end
    end)
    User_Input_Service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)

    local Cool_Window_API = { Current_Tab = nil, Tabs = {}, Buttons = {} }

    function Cool_Window_API:Cool_Tab_Create(Tab_Name)
        local Cool_Tab_Btn = Instance.new("TextButton")
        Cool_Tab_Btn.Size = UDim2.new(1, 0, 0, 28)
        Cool_Tab_Btn.BackgroundTransparency = 1
        Cool_Tab_Btn.Text = "  " .. Tab_Name
        Cool_Tab_Btn.TextColor3 = Cool_Theme.Text_Dark
        Cool_Tab_Btn.TextSize = 13
        Cool_Tab_Btn.Font = Cool_Font
        Cool_Tab_Btn.TextXAlignment = Enum.TextXAlignment.Left
        Cool_Tab_Btn.Parent = Cool_Sidebar

        local Cool_Tab_Line = Instance.new("Frame")
        Cool_Tab_Line.Size = UDim2.new(0, 2, 1, 0)
        Cool_Tab_Line.BackgroundColor3 = Cool_Theme.Accent
        Cool_Tab_Line.BorderSizePixel = 0
        Cool_Tab_Line.Visible = false
        Cool_Tab_Line.Parent = Cool_Tab_Btn

        local Cool_Page = Instance.new("ScrollingFrame")
        Cool_Page.Size = UDim2.new(1, 0, 1, 0)
        Cool_Page.BackgroundTransparency = 1
        Cool_Page.BorderSizePixel = 0
        Cool_Page.ScrollBarThickness = 2
        Cool_Page.ScrollBarImageColor3 = Cool_Theme.Accent
        Cool_Page.Visible = false
        Cool_Page.Parent = Cool_Content_Area

        local Cool_Page_Pad = Instance.new("UIPadding")
        Cool_Page_Pad.PaddingTop = UDim.new(0, 12)
        Cool_Page_Pad.PaddingLeft = UDim.new(0, 12)
        Cool_Page_Pad.PaddingRight = UDim.new(0, 12)
        Cool_Page_Pad.PaddingBottom = UDim.new(0, 12)
        Cool_Page_Pad.Parent = Cool_Page

        local Cool_Left_Col = Instance.new("Frame")
        Cool_Left_Col.Size = UDim2.new(0.5, -6, 1, 0)
        Cool_Left_Col.BackgroundTransparency = 1
        Cool_Left_Col.Parent = Cool_Page

        local Cool_Left_Layout = Instance.new("UIListLayout")
        Cool_Left_Layout.Padding = UDim.new(0, 12)
        Cool_Left_Layout.Parent = Cool_Left_Col

        local Cool_Right_Col = Instance.new("Frame")
        Cool_Right_Col.Size = UDim2.new(0.5, -6, 1, 0)
        Cool_Right_Col.Position = UDim2.new(0.5, 6, 0, 0)
        Cool_Right_Col.BackgroundTransparency = 1
        Cool_Right_Col.Parent = Cool_Page

        local Cool_Right_Layout = Instance.new("UIListLayout")
        Cool_Right_Layout.Padding = UDim.new(0, 12)
        Cool_Right_Layout.Parent = Cool_Right_Col

        table.insert(Cool_Window_API.Tabs, Cool_Page)
        table.insert(Cool_Window_API.Buttons, { Btn = Cool_Tab_Btn, Line = Cool_Tab_Line })

        if #Cool_Window_API.Tabs == 1 then
            Cool_Page.Visible = true
            Cool_Tab_Btn.TextColor3 = Cool_Theme.Accent
            Cool_Tab_Line.Visible = true
            Cool_Window_API.Current_Tab = Tab_Name
        end

        Cool_Tab_Btn.MouseButton1Click:Connect(function()
            for _, Tab in pairs(Cool_Window_API.Tabs) do Tab.Visible = false end
            for _, Obj in pairs(Cool_Window_API.Buttons) do
                Obj.Btn.TextColor3 = Cool_Theme.Text_Dark
                Obj.Line.Visible = false
            end
            Cool_Page.Visible = true
            Cool_Tab_Btn.TextColor3 = Cool_Theme.Accent
            Cool_Tab_Line.Visible = true
            Cool_Window_API.Current_Tab = Tab_Name
        end)

        local function Cool_Update_Canvas()
            local Max_Y = math.max(Cool_Left_Layout.AbsoluteContentSize.Y, Cool_Right_Layout.AbsoluteContentSize.Y)
            Cool_Page.CanvasSize = UDim2.new(0, 0, 0, Max_Y + 24)
        end

        Cool_Left_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Cool_Update_Canvas)
        Cool_Right_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Cool_Update_Canvas)

        local Cool_Section_API = {}

        function Cool_Section_API:Cool_Section_Create(Side, Section_Name)
            local Cool_Section_Frame = Instance.new("Frame")
            Cool_Section_Frame.Size = UDim2.new(1, 0, 0, 20)
            Cool_Section_Frame.BackgroundColor3 = Cool_Theme.Section_Bg
            Cool_Section_Frame.BorderSizePixel = 0
            Cool_Section_Frame.Parent = (Side == "Left") and Cool_Left_Col or Cool_Right_Col

            local Cool_Section_Stroke = Instance.new("UIStroke")
            Cool_Section_Stroke.Color = Cool_Theme.Border
            Cool_Section_Stroke.Thickness = 1
            Cool_Section_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
            Cool_Section_Stroke.Parent = Cool_Section_Frame

            local Cool_Section_Title = Instance.new("TextLabel")
            Cool_Section_Title.Position = UDim2.new(0, 12, 0, -8)
            Cool_Section_Title.Size = UDim2.new(0, 0, 0, 16)
            Cool_Section_Title.AutomaticSize = Enum.AutomaticSize.X
            Cool_Section_Title.BackgroundColor3 = Cool_Theme.Main_Bg
            Cool_Section_Title.BorderSizePixel = 0
            Cool_Section_Title.Text = " " .. Section_Name .. " "
            Cool_Section_Title.TextColor3 = Cool_Theme.Text_White
            Cool_Section_Title.TextSize = 12
            Cool_Section_Title.Font = Cool_Font
            Cool_Section_Title.ZIndex = 2
            Cool_Section_Title.Parent = Cool_Section_Frame

            local Cool_Section_Content = Instance.new("Frame")
            Cool_Section_Content.Size = UDim2.new(1, 0, 1, -16)
            Cool_Section_Content.Position = UDim2.new(0, 0, 0, 16)
            Cool_Section_Content.BackgroundTransparency = 1
            Cool_Section_Content.Parent = Cool_Section_Frame

            local Cool_Content_Layout = Instance.new("UIListLayout")
            Cool_Content_Layout.Padding = UDim.new(0, 8)
            Cool_Content_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Cool_Content_Layout.Parent = Cool_Section_Content

            local Cool_Content_Padding = Instance.new("UIPadding")
            Cool_Content_Padding.PaddingBottom = UDim.new(0, 10)
            Cool_Content_Padding.Parent = Cool_Section_Content

            Cool_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Cool_Section_Frame.Size = UDim2.new(1, 0, 0, Cool_Content_Layout.AbsoluteContentSize.Y + 26)
            end)

            local function Cool_Inject_Elements(Target_Frame)
                local Cool_Elements_API = {}

                function Cool_Elements_API:Cool_Toggle_Create(Toggle_Name, Flag_Name, Default_State, Tooltip_Text, Callback)
                    Nixware_Library_Ultimate.Flags[Flag_Name] = Default_State or false

                    local Cool_Toggle_Btn = Instance.new("TextButton")
                    Cool_Toggle_Btn.Size = UDim2.new(1, -20, 0, 16)
                    Cool_Toggle_Btn.BackgroundTransparency = 1
                    Cool_Toggle_Btn.Text = ""
                    Cool_Toggle_Btn.Parent = Target_Frame

                    local Cool_Box = Instance.new("Frame")
                    Cool_Box.Size = UDim2.new(0, 12, 0, 12)
                    Cool_Box.Position = UDim2.new(0, 0, 0.5, -6)
                    Cool_Box.BackgroundColor3 = Nixware_Library_Ultimate.Flags[Flag_Name] and Cool_Theme.Accent or Cool_Theme.Element_Bg
                    Cool_Box.BorderSizePixel = 0
                    Cool_Box.Parent = Cool_Toggle_Btn

                    local Cool_Box_Stroke = Instance.new("UIStroke")
                    Cool_Box_Stroke.Color = Cool_Theme.Border
                    Cool_Box_Stroke.Thickness = 1
                    Cool_Box_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Box_Stroke.Parent = Cool_Box

                    local Cool_Label = Instance.new("TextLabel")
                    Cool_Label.Size = UDim2.new(1, -20, 1, 0)
                    Cool_Label.Position = UDim2.new(0, 20, 0, 0)
                    Cool_Label.BackgroundTransparency = 1
                    Cool_Label.Text = Toggle_Name
                    Cool_Label.TextColor3 = Nixware_Library_Ultimate.Flags[Flag_Name] and Cool_Theme.Text_White or Cool_Theme.Text_Dark
                    Cool_Label.TextSize = 12
                    Cool_Label.Font = Cool_Font
                    Cool_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Label.Parent = Cool_Toggle_Btn

                    Cool_Toggle_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip_Text) end)
                    Cool_Toggle_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)

                    Cool_Toggle_Btn.MouseButton1Click:Connect(function()
                        Nixware_Library_Ultimate.Flags[Flag_Name] = not Nixware_Library_Ultimate.Flags[Flag_Name]
                        local State = Nixware_Library_Ultimate.Flags[Flag_Name]
                        Cool_Box.BackgroundColor3 = State and Cool_Theme.Accent or Cool_Theme.Element_Bg
                        Cool_Label.TextColor3 = State and Cool_Theme.Text_White or Cool_Theme.Text_Dark
                        if Callback then Callback(State) end
                    end)
                end

                function Cool_Elements_API:Cool_Slider_Create(Slider_Name, Flag_Name, Min, Max, Default, Tooltip_Text, Callback)
                    Nixware_Library_Ultimate.Flags[Flag_Name] = Default or Min

                    local Cool_Slider_Frame = Instance.new("Frame")
                    Cool_Slider_Frame.Size = UDim2.new(1, -20, 0, 32)
                    Cool_Slider_Frame.BackgroundTransparency = 1
                    Cool_Slider_Frame.Parent = Target_Frame

                    local Cool_Label = Instance.new("TextLabel")
                    Cool_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Label.BackgroundTransparency = 1
                    Cool_Label.Text = Slider_Name
                    Cool_Label.TextColor3 = Cool_Theme.Text_White
                    Cool_Label.TextSize = 12
                    Cool_Label.Font = Cool_Font
                    Cool_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Label.Parent = Cool_Slider_Frame

                    local Cool_Val_Label = Instance.new("TextLabel")
                    Cool_Val_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Val_Label.BackgroundTransparency = 1
                    Cool_Val_Label.Text = tostring(Nixware_Library_Ultimate.Flags[Flag_Name])
                    Cool_Val_Label.TextColor3 = Cool_Theme.Text_White
                    Cool_Val_Label.TextSize = 12
                    Cool_Val_Label.Font = Cool_Font
                    Cool_Val_Label.TextXAlignment = Enum.TextXAlignment.Right
                    Cool_Val_Label.Parent = Cool_Slider_Frame

                    local Cool_Bg = Instance.new("Frame")
                    Cool_Bg.Size = UDim2.new(1, 0, 0, 8)
                    Cool_Bg.Position = UDim2.new(0, 0, 0, 20)
                    Cool_Bg.BackgroundColor3 = Cool_Theme.Element_Bg
                    Cool_Bg.BorderSizePixel = 0
                    Cool_Bg.Parent = Cool_Slider_Frame

                    local Cool_Bg_Stroke = Instance.new("UIStroke")
                    Cool_Bg_Stroke.Color = Cool_Theme.Border
                    Cool_Bg_Stroke.Thickness = 1
                    Cool_Bg_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Bg_Stroke.Parent = Cool_Bg

                    local Cool_Fill = Instance.new("Frame")
                    Cool_Fill.Size = UDim2.new((Nixware_Library_Ultimate.Flags[Flag_Name] - Min) / (Max - Min), 0, 1, 0)
                    Cool_Fill.BackgroundColor3 = Cool_Theme.Accent
                    Cool_Fill.BorderSizePixel = 0
                    Cool_Fill.Parent = Cool_Bg

                    Cool_Bg.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip_Text) end)
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
                            local Mouse = User_Input_Service:GetMouseLocation()
                            local Pct = math.clamp((Mouse.X - Cool_Bg.AbsolutePosition.X) / Cool_Bg.AbsoluteSize.X, 0, 1)
                            local Val = math.floor(Min + ((Max - Min) * Pct))
                            Nixware_Library_Ultimate.Flags[Flag_Name] = Val
                            Cool_Fill.Size = UDim2.new(Pct, 0, 1, 0)
                            Cool_Val_Label.Text = tostring(Val)
                            if Callback then Callback(Val) end
                        end
                    end)
                end

                function Cool_Elements_API:Cool_Dropdown_Create(Drop_Name, Flag_Name, Options, Default, Tooltip_Text, Callback)
                    Nixware_Library_Ultimate.Flags[Flag_Name] = Default or Options[1]
                    local Is_Open = false

                    local Cool_Drop_Frame = Instance.new("Frame")
                    Cool_Drop_Frame.Size = UDim2.new(1, -20, 0, 40)
                    Cool_Drop_Frame.BackgroundTransparency = 1
                    Cool_Drop_Frame.ClipsDescendants = true
                    Cool_Drop_Frame.Parent = Target_Frame

                    local Cool_Label = Instance.new("TextLabel")
                    Cool_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Label.BackgroundTransparency = 1
                    Cool_Label.Text = Drop_Name
                    Cool_Label.TextColor3 = Cool_Theme.Text_White
                    Cool_Label.TextSize = 12
                    Cool_Label.Font = Cool_Font
                    Cool_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Label.Parent = Cool_Drop_Frame

                    local Cool_Main_Btn = Instance.new("TextButton")
                    Cool_Main_Btn.Size = UDim2.new(1, 0, 0, 20)
                    Cool_Main_Btn.Position = UDim2.new(0, 0, 0, 18)
                    Cool_Main_Btn.BackgroundColor3 = Cool_Theme.Element_Bg
                    Cool_Main_Btn.BorderSizePixel = 0
                    Cool_Main_Btn.Text = "  " .. Nixware_Library_Ultimate.Flags[Flag_Name]
                    Cool_Main_Btn.TextColor3 = Cool_Theme.Text_Dark
                    Cool_Main_Btn.TextSize = 12
                    Cool_Main_Btn.Font = Cool_Font
                    Cool_Main_Btn.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Main_Btn.Parent = Cool_Drop_Frame

                    local Cool_Main_Stroke = Instance.new("UIStroke")
                    Cool_Main_Stroke.Color = Cool_Theme.Border
                    Cool_Main_Stroke.Thickness = 1
                    Cool_Main_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Main_Stroke.Parent = Cool_Main_Btn

                    local Cool_Icon = Instance.new("TextLabel")
                    Cool_Icon.Size = UDim2.new(0, 20, 1, 0)
                    Cool_Icon.Position = UDim2.new(1, -20, 0, 0)
                    Cool_Icon.BackgroundTransparency = 1
                    Cool_Icon.Text = "+"
                    Cool_Icon.TextColor3 = Cool_Theme.Text_Dark
                    Cool_Icon.TextSize = 12
                    Cool_Icon.Font = Cool_Font
                    Cool_Icon.Parent = Cool_Main_Btn

                    local Cool_List = Instance.new("Frame")
                    Cool_List.Size = UDim2.new(1, 0, 0, 0)
                    Cool_List.Position = UDim2.new(0, 0, 0, 39)
                    Cool_List.BackgroundColor3 = Cool_Theme.Element_Bg
                    Cool_List.BorderSizePixel = 0
                    Cool_List.Parent = Cool_Drop_Frame

                    local Cool_List_Stroke = Instance.new("UIStroke")
                    Cool_List_Stroke.Color = Cool_Theme.Border
                    Cool_List_Stroke.Thickness = 1
                    Cool_List_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_List_Stroke.Parent = Cool_List

                    local Cool_List_Layout = Instance.new("UIListLayout")
                    Cool_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                    Cool_List_Layout.Parent = Cool_List

                    Cool_Main_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip_Text) end)
                    Cool_Main_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)

                    local function Cool_Toggle_Drop()
                        Is_Open = not Is_Open
                        if Is_Open then
                            Cool_Drop_Frame.Size = UDim2.new(1, -20, 0, 39 + (#Options * 20))
                            Cool_List.Size = UDim2.new(1, 0, 0, #Options * 20)
                            Cool_Icon.Text = "-"
                            Cool_Main_Stroke.Color = Cool_Theme.Accent
                        else
                            Cool_Drop_Frame.Size = UDim2.new(1, -20, 0, 40)
                            Cool_List.Size = UDim2.new(1, 0, 0, 0)
                            Cool_Icon.Text = "+"
                            Cool_Main_Stroke.Color = Cool_Theme.Border
                        end
                    end

                    for _, Opt in ipairs(Options) do
                        local Cool_Opt_Btn = Instance.new("TextButton")
                        Cool_Opt_Btn.Size = UDim2.new(1, 0, 0, 20)
                        Cool_Opt_Btn.BackgroundTransparency = 1
                        Cool_Opt_Btn.Text = "  " .. Opt
                        Cool_Opt_Btn.TextColor3 = Cool_Theme.Text_White
                        Cool_Opt_Btn.TextSize = 12
                        Cool_Opt_Btn.Font = Cool_Font
                        Cool_Opt_Btn.TextXAlignment = Enum.TextXAlignment.Left
                        Cool_Opt_Btn.Parent = Cool_List

                        Cool_Opt_Btn.MouseEnter:Connect(function() Cool_Opt_Btn.TextColor3 = Cool_Theme.Accent end)
                        Cool_Opt_Btn.MouseLeave:Connect(function() Cool_Opt_Btn.TextColor3 = Cool_Theme.Text_White end)

                        Cool_Opt_Btn.MouseButton1Click:Connect(function()
                            Nixware_Library_Ultimate.Flags[Flag_Name] = Opt
                            Cool_Main_Btn.Text = "  " .. Opt
                            Cool_Toggle_Drop()
                            if Callback then Callback(Opt) end
                        end)
                    end

                    Cool_Main_Btn.MouseButton1Click:Connect(Cool_Toggle_Drop)
                end

                function Cool_Elements_API:Cool_ColorPicker_Create(Picker_Name, Flag_Name, Default_Color, Tooltip_Text, Callback)
                    Nixware_Library_Ultimate.Flags[Flag_Name] = Default_Color or Color3.new(1, 1, 1)
                    local Is_Open = false

                    local Cool_Color_Frame = Instance.new("Frame")
                    Cool_Color_Frame.Size = UDim2.new(1, -20, 0, 20)
                    Cool_Color_Frame.BackgroundTransparency = 1
                    Cool_Color_Frame.ClipsDescendants = true
                    Cool_Color_Frame.Parent = Target_Frame

                    local Cool_Main_Btn = Instance.new("TextButton")
                    Cool_Main_Btn.Size = UDim2.new(1, 0, 0, 20)
                    Cool_Main_Btn.BackgroundTransparency = 1
                    Cool_Main_Btn.Text = ""
                    Cool_Main_Btn.Parent = Cool_Color_Frame

                    local Cool_Label = Instance.new("TextLabel")
                    Cool_Label.Size = UDim2.new(1, -25, 1, 0)
                    Cool_Label.BackgroundTransparency = 1
                    Cool_Label.Text = Picker_Name
                    Cool_Label.TextColor3 = Cool_Theme.Text_White
                    Cool_Label.TextSize = 12
                    Cool_Label.Font = Cool_Font
                    Cool_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Label.Parent = Cool_Main_Btn

                    local Cool_Preview = Instance.new("Frame")
                    Cool_Preview.Size = UDim2.new(0, 16, 0, 10)
                    Cool_Preview.Position = UDim2.new(1, -16, 0.5, -5)
                    Cool_Preview.BackgroundColor3 = Nixware_Library_Ultimate.Flags[Flag_Name]
                    Cool_Preview.BorderSizePixel = 0
                    Cool_Preview.Parent = Cool_Main_Btn

                    local Cool_Prev_Stroke = Instance.new("UIStroke")
                    Cool_Prev_Stroke.Color = Cool_Theme.Border
                    Cool_Prev_Stroke.Thickness = 1
                    Cool_Prev_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Prev_Stroke.Parent = Cool_Preview

                    local Cool_Sliders_Area = Instance.new("Frame")
                    Cool_Sliders_Area.Size = UDim2.new(1, 0, 0, 60)
                    Cool_Sliders_Area.Position = UDim2.new(0, 0, 0, 20)
                    Cool_Sliders_Area.BackgroundColor3 = Cool_Theme.Element_Bg
                    Cool_Sliders_Area.BorderSizePixel = 0
                    Cool_Sliders_Area.Parent = Cool_Color_Frame

                    local Cool_Area_Stroke = Instance.new("UIStroke")
                    Cool_Area_Stroke.Color = Cool_Theme.Border
                    Cool_Area_Stroke.Thickness = 1
                    Cool_Area_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Area_Stroke.Parent = Cool_Sliders_Area

                    Cool_Main_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip_Text) end)
                    Cool_Main_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)

                    Cool_Main_Btn.MouseButton1Click:Connect(function()
                        Is_Open = not Is_Open
                        Cool_Color_Frame.Size = UDim2.new(1, -20, 0, Is_Open and 85 or 20)
                    end)

                    local function Cool_Add_Rgb_Slider(Name, Y_Pos, Init_Val, Comp_Callback)
                        local S_Frame = Instance.new("Frame")
                        S_Frame.Size = UDim2.new(1, -10, 0, 14)
                        S_Frame.Position = UDim2.new(0, 5, 0, Y_Pos)
                        S_Frame.BackgroundTransparency = 1
                        S_Frame.Parent = Cool_Sliders_Area

                        local S_Label = Instance.new("TextLabel")
                        S_Label.Size = UDim2.new(0, 15, 1, 0)
                        S_Label.BackgroundTransparency = 1
                        S_Label.Text = Name
                        S_Label.TextColor3 = Cool_Theme.Text_White
                        S_Label.TextSize = 10
                        S_Label.Font = Cool_Font
                        S_Label.Parent = S_Frame

                        local S_Bg = Instance.new("Frame")
                        S_Bg.Size = UDim2.new(1, -20, 0, 6)
                        S_Bg.Position = UDim2.new(0, 20, 0.5, -3)
                        S_Bg.BackgroundColor3 = Cool_Theme.Main_Bg
                        S_Bg.BorderSizePixel = 0
                        S_Bg.Parent = S_Frame

                        local S_Stroke = Instance.new("UIStroke")
                        S_Stroke.Color = Cool_Theme.Border
                        S_Stroke.Thickness = 1
                        S_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                        S_Stroke.Parent = S_Bg

                        local S_Fill = Instance.new("Frame")
                        S_Fill.Size = UDim2.new(Init_Val, 0, 1, 0)
                        S_Fill.BackgroundColor3 = Cool_Theme.Accent
                        S_Fill.BorderSizePixel = 0
                        S_Fill.Parent = S_Bg

                        local Sliding = false
                        S_Bg.InputBegan:Connect(function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = true end
                        end)
                        User_Input_Service.InputEnded:Connect(function(Input)
                            if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
                        end)

                        Run_Service.RenderStepped:Connect(function()
                            if Sliding then
                                local Mouse = User_Input_Service:GetMouseLocation()
                                local Pct = math.clamp((Mouse.X - S_Bg.AbsolutePosition.X) / S_Bg.AbsoluteSize.X, 0, 1)
                                S_Fill.Size = UDim2.new(Pct, 0, 1, 0)
                                Comp_Callback(Pct)
                            end
                        end)
                    end

                    local Cur_Color = Nixware_Library_Ultimate.Flags[Flag_Name]
                    local R, G, B = Cur_Color.R, Cur_Color.G, Cur_Color.B

                    local function Cool_Update_Color()
                        local New_Col = Color3.new(R, G, B)
                        Nixware_Library_Ultimate.Flags[Flag_Name] = New_Col
                        Cool_Preview.BackgroundColor3 = New_Col
                        if Callback then Callback(New_Col) end
                    end

                    Cool_Add_Rgb_Slider("R", 5, R, function(Val) R = Val; Cool_Update_Color() end)
                    Cool_Add_Rgb_Slider("G", 23, G, function(Val) G = Val; Cool_Update_Color() end)
                    Cool_Add_Rgb_Slider("B", 41, B, function(Val) B = Val; Cool_Update_Color() end)
                end

                function Cool_Elements_API:Cool_Module_Create(Module_Name, Flag_Name, Module_Desc, Default_State, Tooltip_Text, Callback)
                    Nixware_Library_Ultimate.Flags[Flag_Name] = Default_State or false

                    local Cool_Mod_Frame = Instance.new("Frame")
                    Cool_Mod_Frame.Size = UDim2.new(1, -20, 0, 36)
                    Cool_Mod_Frame.BackgroundTransparency = 1
                    Cool_Mod_Frame.ClipsDescendants = true
                    Cool_Mod_Frame.Parent = Target_Frame

                    local Cool_Mod_Btn = Instance.new("TextButton")
                    Cool_Mod_Btn.Size = UDim2.new(1, 0, 0, 36)
                    Cool_Mod_Btn.BackgroundColor3 = Cool_Theme.Element_Bg
                    Cool_Mod_Btn.BorderSizePixel = 0
                    Cool_Mod_Btn.Text = ""
                    Cool_Mod_Btn.Parent = Cool_Mod_Frame

                    local Cool_Btn_Stroke = Instance.new("UIStroke")
                    Cool_Btn_Stroke.Color = Nixware_Library_Ultimate.Flags[Flag_Name] and Cool_Theme.Accent or Cool_Theme.Border
                    Cool_Btn_Stroke.Thickness = 1
                    Cool_Btn_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Btn_Stroke.Parent = Cool_Mod_Btn

                    local Cool_Box = Instance.new("Frame")
                    Cool_Box.Size = UDim2.new(0, 12, 0, 12)
                    Cool_Box.Position = UDim2.new(0, 10, 0.5, -6)
                    Cool_Box.BackgroundColor3 = Nixware_Library_Ultimate.Flags[Flag_Name] and Cool_Theme.Accent or Cool_Theme.Element_Bg
                    Cool_Box.BorderSizePixel = 0
                    Cool_Box.Parent = Cool_Mod_Btn

                    local Cool_Box_Stroke = Instance.new("UIStroke")
                    Cool_Box_Stroke.Color = Cool_Theme.Border
                    Cool_Box_Stroke.Thickness = 1
                    Cool_Box_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Box_Stroke.Parent = Cool_Box

                    local Cool_Title = Instance.new("TextLabel")
                    Cool_Title.Size = UDim2.new(1, -32, 0, 14)
                    Cool_Title.Position = UDim2.new(0, 32, 0, 4)
                    Cool_Title.BackgroundTransparency = 1
                    Cool_Title.Text = Module_Name
                    Cool_Title.TextColor3 = Nixware_Library_Ultimate.Flags[Flag_Name] and Cool_Theme.Text_White or Cool_Theme.Text_Dark
                    Cool_Title.TextSize = 12
                    Cool_Title.Font = Cool_Font
                    Cool_Title.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Title.Parent = Cool_Mod_Btn

                    local Cool_Desc = Instance.new("TextLabel")
                    Cool_Desc.Size = UDim2.new(1, -32, 0, 12)
                    Cool_Desc.Position = UDim2.new(0, 32, 0, 18)
                    Cool_Desc.BackgroundTransparency = 1
                    Cool_Desc.Text = Module_Desc
                    Cool_Desc.TextColor3 = Cool_Theme.Text_Dark
                    Cool_Desc.TextSize = 10
                    Cool_Desc.Font = Cool_Font
                    Cool_Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Desc.Parent = Cool_Mod_Btn

                    local Cool_Mod_Content = Instance.new("Frame")
                    Cool_Mod_Content.Size = UDim2.new(1, 0, 0, 0)
                    Cool_Mod_Content.Position = UDim2.new(0, 0, 0, 38)
                    Cool_Mod_Content.BackgroundTransparency = 1
                    Cool_Mod_Content.Parent = Cool_Mod_Frame

                    local Cool_Mod_Layout = Instance.new("UIListLayout")
                    Cool_Mod_Layout.Padding = UDim.new(0, 6)
                    Cool_Mod_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    Cool_Mod_Layout.Parent = Cool_Mod_Content

                    Cool_Mod_Btn.MouseEnter:Connect(function() Cool_Show_Tooltip(Tooltip_Text) end)
                    Cool_Mod_Btn.MouseLeave:Connect(Cool_Hide_Tooltip)

                    local function Cool_Update_Mod()
                        if Nixware_Library_Ultimate.Flags[Flag_Name] then
                            Cool_Mod_Frame.Size = UDim2.new(1, -20, 0, 38 + Cool_Mod_Layout.AbsoluteContentSize.Y + 4)
                        else
                            Cool_Mod_Frame.Size = UDim2.new(1, -20, 0, 36)
                        end
                    end

                    Cool_Mod_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if Nixware_Library_Ultimate.Flags[Flag_Name] then Cool_Update_Mod() end
                    end)

                    Cool_Mod_Btn.MouseButton1Click:Connect(function()
                        Nixware_Library_Ultimate.Flags[Flag_Name] = not Nixware_Library_Ultimate.Flags[Flag_Name]
                        local State = Nixware_Library_Ultimate.Flags[Flag_Name]
                        Cool_Box.BackgroundColor3 = State and Cool_Theme.Accent or Cool_Theme.Element_Bg
                        Cool_Title.TextColor3 = State and Cool_Theme.Text_White or Cool_Theme.Text_Dark
                        Cool_Btn_Stroke.Color = State and Cool_Theme.Accent or Cool_Theme.Border
                        Cool_Update_Mod()
                        if Callback then Callback(State) end
                    end)

                    if Nixware_Library_Ultimate.Flags[Flag_Name] then Cool_Update_Mod() end
                    return Cool_Inject_Elements(Cool_Mod_Content)
                end

                return Cool_Elements_API
            end

            return Cool_Inject_Elements(Cool_Section_Content)
        end

        return Cool_Section_API
    end

    return Cool_Window_API
end

return Nixware_Library_Ultimate
