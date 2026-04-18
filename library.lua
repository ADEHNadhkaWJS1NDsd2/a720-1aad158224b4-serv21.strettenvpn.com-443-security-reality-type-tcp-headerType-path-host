local Core_Gui = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")

local Nixware_Library_Pure = {}

local Cool_Colors = {
    Main_Bg = Color3.fromRGB(18, 18, 18),
    Sidebar_Bg = Color3.fromRGB(22, 22, 22),
    Section_Bg = Color3.fromRGB(18, 18, 18),
    Border = Color3.fromRGB(45, 45, 45),
    Accent = Color3.fromRGB(90, 120, 240),
    Text_White = Color3.fromRGB(230, 230, 230),
    Text_Dark = Color3.fromRGB(130, 130, 130),
    Element_Bg = Color3.fromRGB(28, 28, 28),
    Element_Hover = Color3.fromRGB(38, 38, 38)
}

local Cool_Font = Enum.Font.GothamMedium

function Nixware_Library_Pure:Cool_Window_Create(Window_Name_Text)
    local Cool_Screen_Gui = Instance.new("ScreenGui")
    Cool_Screen_Gui.Name = "Nixware_Pure_UI"
    Cool_Screen_Gui.Parent = Core_Gui
    Cool_Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Cool_Screen_Gui.ResetOnSpawn = false

    local Cool_Main_Frame = Instance.new("Frame")
    Cool_Main_Frame.Size = UDim2.new(0, 580, 0, 400)
    Cool_Main_Frame.Position = UDim2.new(0.5, -290, 0.5, -200)
    Cool_Main_Frame.BackgroundColor3 = Cool_Colors.Main_Bg
    Cool_Main_Frame.BorderSizePixel = 0
    Cool_Main_Frame.Parent = Cool_Screen_Gui

    local Cool_Main_Stroke = Instance.new("UIStroke")
    Cool_Main_Stroke.Color = Cool_Colors.Border
    Cool_Main_Stroke.Thickness = 1
    Cool_Main_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
    Cool_Main_Stroke.Parent = Cool_Main_Frame

    local Cool_Top_Header = Instance.new("Frame")
    Cool_Top_Header.Size = UDim2.new(1, 0, 0, 22)
    Cool_Top_Header.BackgroundColor3 = Cool_Colors.Main_Bg
    Cool_Top_Header.BorderSizePixel = 0
    Cool_Top_Header.Parent = Cool_Main_Frame

    local Cool_Top_Stroke = Instance.new("Frame")
    Cool_Top_Stroke.Size = UDim2.new(1, 0, 0, 1)
    Cool_Top_Stroke.Position = UDim2.new(0, 0, 1, 0)
    Cool_Top_Stroke.BackgroundColor3 = Cool_Colors.Border
    Cool_Top_Stroke.BorderSizePixel = 0
    Cool_Top_Stroke.ZIndex = 2
    Cool_Top_Stroke.Parent = Cool_Top_Header

    local Cool_Accent_Line = Instance.new("Frame")
    Cool_Accent_Line.Size = UDim2.new(1, 0, 0, 2)
    Cool_Accent_Line.BackgroundColor3 = Cool_Colors.Accent
    Cool_Accent_Line.BorderSizePixel = 0
    Cool_Accent_Line.Parent = Cool_Top_Header

    local Cool_Title_Text = Instance.new("TextLabel")
    Cool_Title_Text.Size = UDim2.new(1, -12, 1, -2)
    Cool_Title_Text.Position = UDim2.new(0, 12, 0, 2)
    Cool_Title_Text.BackgroundTransparency = 1
    Cool_Title_Text.Text = Window_Name_Text
    Cool_Title_Text.TextColor3 = Cool_Colors.Text_White
    Cool_Title_Text.TextSize = 12
    Cool_Title_Text.Font = Enum.Font.GothamBold
    Cool_Title_Text.TextXAlignment = Enum.TextXAlignment.Left
    Cool_Title_Text.Parent = Cool_Top_Header

    local Cool_Sidebar_Area = Instance.new("Frame")
    Cool_Sidebar_Area.Size = UDim2.new(0, 130, 1, -23)
    Cool_Sidebar_Area.Position = UDim2.new(0, 0, 0, 23)
    Cool_Sidebar_Area.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Sidebar_Area.BorderSizePixel = 0
    Cool_Sidebar_Area.Parent = Cool_Main_Frame

    local Cool_Sidebar_Stroke = Instance.new("Frame")
    Cool_Sidebar_Stroke.Size = UDim2.new(0, 1, 1, 0)
    Cool_Sidebar_Stroke.Position = UDim2.new(1, 0, 0, 0)
    Cool_Sidebar_Stroke.BackgroundColor3 = Cool_Colors.Border
    Cool_Sidebar_Stroke.BorderSizePixel = 0
    Cool_Sidebar_Stroke.ZIndex = 2
    Cool_Sidebar_Stroke.Parent = Cool_Sidebar_Area

    local Cool_Tab_Container = Instance.new("Frame")
    Cool_Tab_Container.Size = UDim2.new(1, -1, 1, 0)
    Cool_Tab_Container.BackgroundTransparency = 1
    Cool_Tab_Container.BorderSizePixel = 0
    Cool_Tab_Container.Parent = Cool_Sidebar_Area

    local Cool_Tab_Layout = Instance.new("UIListLayout")
    Cool_Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Cool_Tab_Layout.Padding = UDim.new(0, 0)
    Cool_Tab_Layout.Parent = Cool_Tab_Container

    local Cool_Tab_Padding = Instance.new("UIPadding")
    Cool_Tab_Padding.PaddingTop = UDim.new(0, 6)
    Cool_Tab_Padding.Parent = Cool_Tab_Container

    local Cool_Content_Area = Instance.new("Frame")
    Cool_Content_Area.Size = UDim2.new(1, -131, 1, -23)
    Cool_Content_Area.Position = UDim2.new(0, 131, 0, 23)
    Cool_Content_Area.BackgroundTransparency = 1
    Cool_Content_Area.Parent = Cool_Main_Frame

    local Dragging = false
    local Drag_Input = nil
    local Drag_Start = nil
    local Start_Pos = nil

    local function Cool_Update_Drag(Input)
        local Delta = Input.Position - Drag_Start
        Cool_Main_Frame.Position = UDim2.new(Start_Pos.X.Scale, Start_Pos.X.Offset + Delta.X, Start_Pos.Y.Scale, Start_Pos.Y.Offset + Delta.Y)
    end

    Cool_Top_Header.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Drag_Start = Input.Position
            Start_Pos = Cool_Main_Frame.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Cool_Top_Header.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            Drag_Input = Input
        end
    end)

    User_Input_Service.InputChanged:Connect(function(Input)
        if Input == Drag_Input and Dragging then
            Cool_Update_Drag(Input)
        end
    end)

    local Cool_Window_Methods = {
        Current_Tab = nil,
        Tabs = {},
        Buttons = {}
    }

    function Cool_Window_Methods:Cool_Tab_Create(Tab_Name_String)
        local Cool_Tab_Btn = Instance.new("TextButton")
        Cool_Tab_Btn.Size = UDim2.new(1, 0, 0, 30)
        Cool_Tab_Btn.BackgroundColor3 = Cool_Colors.Sidebar_Bg
        Cool_Tab_Btn.BackgroundTransparency = 0
        Cool_Tab_Btn.BorderSizePixel = 0
        Cool_Tab_Btn.Text = "  " .. Tab_Name_String
        Cool_Tab_Btn.TextColor3 = Cool_Colors.Text_Dark
        Cool_Tab_Btn.TextSize = 12
        Cool_Tab_Btn.Font = Cool_Font
        Cool_Tab_Btn.TextXAlignment = Enum.TextXAlignment.Left
        Cool_Tab_Btn.AutoButtonColor = false
        Cool_Tab_Btn.Parent = Cool_Tab_Container

        local Cool_Tab_Line = Instance.new("Frame")
        Cool_Tab_Line.Size = UDim2.new(0, 2, 1, 0)
        Cool_Tab_Line.BackgroundColor3 = Cool_Colors.Accent
        Cool_Tab_Line.BorderSizePixel = 0
        Cool_Tab_Line.Visible = false
        Cool_Tab_Line.Parent = Cool_Tab_Btn

        local Cool_Scroll_Frame = Instance.new("ScrollingFrame")
        Cool_Scroll_Frame.Size = UDim2.new(1, 0, 1, 0)
        Cool_Scroll_Frame.BackgroundTransparency = 1
        Cool_Scroll_Frame.BorderSizePixel = 0
        Cool_Scroll_Frame.ScrollBarThickness = 2
        Cool_Scroll_Frame.ScrollBarImageColor3 = Cool_Colors.Accent
        Cool_Scroll_Frame.Visible = false
        Cool_Scroll_Frame.Parent = Cool_Content_Area

        local Cool_Page_Layout = Instance.new("UIListLayout")
        Cool_Page_Layout.Padding = UDim.new(0, 16)
        Cool_Page_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Cool_Page_Layout.Parent = Cool_Scroll_Frame

        local Cool_Page_Padding = Instance.new("UIPadding")
        Cool_Page_Padding.PaddingTop = UDim.new(0, 16)
        Cool_Page_Padding.PaddingBottom = UDim.new(0, 16)
        Cool_Page_Padding.Parent = Cool_Scroll_Frame

        table.insert(Cool_Window_Methods.Tabs, Cool_Scroll_Frame)
        table.insert(Cool_Window_Methods.Buttons, {Btn = Cool_Tab_Btn, Line = Cool_Tab_Line})

        if #Cool_Window_Methods.Tabs == 1 then
            Cool_Scroll_Frame.Visible = true
            Cool_Tab_Btn.TextColor3 = Cool_Colors.Accent
            Cool_Tab_Line.Visible = true
            Cool_Window_Methods.Current_Tab = Tab_Name_String
        end

        Cool_Tab_Btn.MouseButton1Click:Connect(function()
            for _, Tab in pairs(Cool_Window_Methods.Tabs) do
                Tab.Visible = false
            end
            for _, Obj in pairs(Cool_Window_Methods.Buttons) do
                Obj.Btn.TextColor3 = Cool_Colors.Text_Dark
                Obj.Line.Visible = false
            end
            Cool_Scroll_Frame.Visible = true
            Cool_Tab_Btn.TextColor3 = Cool_Colors.Accent
            Cool_Tab_Line.Visible = true
            Cool_Window_Methods.Current_Tab = Tab_Name_String
        end)

        local Cool_Section_Methods = {}

        function Cool_Section_Methods:Cool_Section_Create(Section_Name_String)
            local Cool_Section_Frame = Instance.new("Frame")
            Cool_Section_Frame.Size = UDim2.new(1, -24, 0, 20)
            Cool_Section_Frame.BackgroundColor3 = Cool_Colors.Section_Bg
            Cool_Section_Frame.BorderSizePixel = 0
            Cool_Section_Frame.Parent = Cool_Scroll_Frame

            local Cool_Section_Stroke = Instance.new("UIStroke")
            Cool_Section_Stroke.Color = Cool_Colors.Border
            Cool_Section_Stroke.Thickness = 1
            Cool_Section_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
            Cool_Section_Stroke.Parent = Cool_Section_Frame

            local Cool_Section_Title = Instance.new("TextLabel")
            Cool_Section_Title.Position = UDim2.new(0, 12, 0, -8)
            Cool_Section_Title.Size = UDim2.new(0, 0, 0, 16)
            Cool_Section_Title.AutomaticSize = Enum.AutomaticSize.X
            Cool_Section_Title.BackgroundColor3 = Cool_Colors.Main_Bg
            Cool_Section_Title.BorderSizePixel = 0
            Cool_Section_Title.Text = " " .. Section_Name_String .. " "
            Cool_Section_Title.TextColor3 = Cool_Colors.Text_White
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
            Cool_Content_Layout.Padding = UDim.new(0, 6)
            Cool_Content_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Cool_Content_Layout.Parent = Cool_Section_Content

            local Cool_Content_Padding = Instance.new("UIPadding")
            Cool_Content_Padding.PaddingBottom = UDim.new(0, 8)
            Cool_Content_Padding.Parent = Cool_Section_Content

            Cool_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Cool_Section_Frame.Size = UDim2.new(1, -24, 0, Cool_Content_Layout.AbsoluteContentSize.Y + 24)
                Cool_Scroll_Frame.CanvasSize = UDim2.new(0, 0, 0, Cool_Page_Layout.AbsoluteContentSize.Y + 32)
            end)

            local function Cool_Init_Elements(Target_Frame)
                local Cool_Elements = {}

                function Cool_Elements:Cool_Toggle_Create(Toggle_Name, Default_State, Callback_Func)
                    local Cool_State = Default_State or false

                    local Cool_Toggle_Btn = Instance.new("TextButton")
                    Cool_Toggle_Btn.Size = UDim2.new(1, -20, 0, 16)
                    Cool_Toggle_Btn.BackgroundTransparency = 1
                    Cool_Toggle_Btn.Text = ""
                    Cool_Toggle_Btn.AutoButtonColor = false
                    Cool_Toggle_Btn.Parent = Target_Frame

                    local Cool_Box = Instance.new("Frame")
                    Cool_Box.Size = UDim2.new(0, 10, 0, 10)
                    Cool_Box.Position = UDim2.new(0, 0, 0.5, -5)
                    Cool_Box.BackgroundColor3 = Cool_State and Cool_Colors.Accent or Cool_Colors.Element_Bg
                    Cool_Box.BorderSizePixel = 0
                    Cool_Box.Parent = Cool_Toggle_Btn

                    local Cool_Box_Stroke = Instance.new("UIStroke")
                    Cool_Box_Stroke.Color = Cool_Colors.Border
                    Cool_Box_Stroke.Thickness = 1
                    Cool_Box_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Box_Stroke.Parent = Cool_Box

                    local Cool_Label = Instance.new("TextLabel")
                    Cool_Label.Size = UDim2.new(1, -18, 1, 0)
                    Cool_Label.Position = UDim2.new(0, 18, 0, 0)
                    Cool_Label.BackgroundTransparency = 1
                    Cool_Label.Text = Toggle_Name
                    Cool_Label.TextColor3 = Cool_State and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                    Cool_Label.TextSize = 12
                    Cool_Label.Font = Cool_Font
                    Cool_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Label.Parent = Cool_Toggle_Btn

                    Cool_Toggle_Btn.MouseEnter:Connect(function()
                        if not Cool_State then Cool_Box.BackgroundColor3 = Cool_Colors.Element_Hover end
                    end)
                    Cool_Toggle_Btn.MouseLeave:Connect(function()
                        if not Cool_State then Cool_Box.BackgroundColor3 = Cool_Colors.Element_Bg end
                    end)

                    Cool_Toggle_Btn.MouseButton1Click:Connect(function()
                        Cool_State = not Cool_State
                        Cool_Box.BackgroundColor3 = Cool_State and Cool_Colors.Accent or Cool_Colors.Element_Bg
                        Cool_Label.TextColor3 = Cool_State and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                        Callback_Func(Cool_State)
                    end)
                end

                function Cool_Elements:Cool_Slider_Create(Slider_Name, Min_Val, Max_Val, Default_Val, Callback_Func)
                    local Cool_Val = Default_Val or Min_Val

                    local Cool_Slider_Frame = Instance.new("Frame")
                    Cool_Slider_Frame.Size = UDim2.new(1, -20, 0, 26)
                    Cool_Slider_Frame.BackgroundTransparency = 1
                    Cool_Slider_Frame.Parent = Target_Frame

                    local Cool_Label = Instance.new("TextLabel")
                    Cool_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Label.BackgroundTransparency = 1
                    Cool_Label.Text = Slider_Name
                    Cool_Label.TextColor3 = Cool_Colors.Text_White
                    Cool_Label.TextSize = 12
                    Cool_Label.Font = Cool_Font
                    Cool_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Label.Parent = Cool_Slider_Frame

                    local Cool_Val_Label = Instance.new("TextLabel")
                    Cool_Val_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Val_Label.BackgroundTransparency = 1
                    Cool_Val_Label.Text = tostring(Cool_Val)
                    Cool_Val_Label.TextColor3 = Cool_Colors.Text_White
                    Cool_Val_Label.TextSize = 12
                    Cool_Val_Label.Font = Cool_Font
                    Cool_Val_Label.TextXAlignment = Enum.TextXAlignment.Right
                    Cool_Val_Label.Parent = Cool_Slider_Frame

                    local Cool_Bg = Instance.new("Frame")
                    Cool_Bg.Size = UDim2.new(1, 0, 0, 6)
                    Cool_Bg.Position = UDim2.new(0, 0, 0, 18)
                    Cool_Bg.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Bg.BorderSizePixel = 0
                    Cool_Bg.Parent = Cool_Slider_Frame

                    local Cool_Bg_Stroke = Instance.new("UIStroke")
                    Cool_Bg_Stroke.Color = Cool_Colors.Border
                    Cool_Bg_Stroke.Thickness = 1
                    Cool_Bg_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Bg_Stroke.Parent = Cool_Bg

                    local Cool_Fill = Instance.new("Frame")
                    Cool_Fill.Size = UDim2.new((Cool_Val - Min_Val) / (Max_Val - Min_Val), 0, 1, 0)
                    Cool_Fill.BackgroundColor3 = Cool_Colors.Accent
                    Cool_Fill.BorderSizePixel = 0
                    Cool_Fill.Parent = Cool_Bg

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
                            Cool_Val = math.floor(Min_Val + ((Max_Val - Min_Val) * Pct))
                            Cool_Fill.Size = UDim2.new(Pct, 0, 1, 0)
                            Cool_Val_Label.Text = tostring(Cool_Val)
                            Callback_Func(Cool_Val)
                        end
                    end)
                end

                function Cool_Elements:Cool_Button_Create(Button_Name, Callback_Func)
                    local Cool_Btn = Instance.new("TextButton")
                    Cool_Btn.Size = UDim2.new(1, -20, 0, 20)
                    Cool_Btn.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Btn.BorderSizePixel = 0
                    Cool_Btn.Text = Button_Name
                    Cool_Btn.TextColor3 = Cool_Colors.Text_White
                    Cool_Btn.TextSize = 12
                    Cool_Btn.Font = Cool_Font
                    Cool_Btn.AutoButtonColor = false
                    Cool_Btn.Parent = Target_Frame

                    local Cool_Btn_Stroke = Instance.new("UIStroke")
                    Cool_Btn_Stroke.Color = Cool_Colors.Border
                    Cool_Btn_Stroke.Thickness = 1
                    Cool_Btn_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Btn_Stroke.Parent = Cool_Btn

                    Cool_Btn.MouseEnter:Connect(function() Cool_Btn.BackgroundColor3 = Cool_Colors.Element_Hover end)
                    Cool_Btn.MouseLeave:Connect(function() Cool_Btn.BackgroundColor3 = Cool_Colors.Element_Bg end)
                    Cool_Btn.MouseButton1Down:Connect(function() Cool_Btn_Stroke.Color = Cool_Colors.Accent end)
                    Cool_Btn.MouseButton1Up:Connect(function()
                        Cool_Btn_Stroke.Color = Cool_Colors.Border
                        Callback_Func()
                    end)
                end

                function Cool_Elements:Cool_Dropdown_Create(Dropdown_Name, Options, Default, Callback_Func)
                    local Cool_Open = false
                    local Cool_Selected = Default or Options[1]

                    local Cool_Drop_Frame = Instance.new("Frame")
                    Cool_Drop_Frame.Size = UDim2.new(1, -20, 0, 36)
                    Cool_Drop_Frame.BackgroundTransparency = 1
                    Cool_Drop_Frame.ClipsDescendants = true
                    Cool_Drop_Frame.Parent = Target_Frame

                    local Cool_Label = Instance.new("TextLabel")
                    Cool_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Label.BackgroundTransparency = 1
                    Cool_Label.Text = Dropdown_Name
                    Cool_Label.TextColor3 = Cool_Colors.Text_White
                    Cool_Label.TextSize = 12
                    Cool_Label.Font = Cool_Font
                    Cool_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Label.Parent = Cool_Drop_Frame

                    local Cool_Main_Btn = Instance.new("TextButton")
                    Cool_Main_Btn.Size = UDim2.new(1, 0, 0, 18)
                    Cool_Main_Btn.Position = UDim2.new(0, 0, 0, 18)
                    Cool_Main_Btn.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Main_Btn.BorderSizePixel = 0
                    Cool_Main_Btn.Text = "  " .. Cool_Selected
                    Cool_Main_Btn.TextColor3 = Cool_Colors.Text_Dark
                    Cool_Main_Btn.TextSize = 12
                    Cool_Main_Btn.Font = Cool_Font
                    Cool_Main_Btn.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Main_Btn.AutoButtonColor = false
                    Cool_Main_Btn.Parent = Cool_Drop_Frame

                    local Cool_Main_Stroke = Instance.new("UIStroke")
                    Cool_Main_Stroke.Color = Cool_Colors.Border
                    Cool_Main_Stroke.Thickness = 1
                    Cool_Main_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Main_Stroke.Parent = Cool_Main_Btn

                    local Cool_Icon = Instance.new("TextLabel")
                    Cool_Icon.Size = UDim2.new(0, 18, 1, 0)
                    Cool_Icon.Position = UDim2.new(1, -18, 0, 0)
                    Cool_Icon.BackgroundTransparency = 1
                    Cool_Icon.Text = "+"
                    Cool_Icon.TextColor3 = Cool_Colors.Text_Dark
                    Cool_Icon.TextSize = 12
                    Cool_Icon.Font = Cool_Font
                    Cool_Icon.Parent = Cool_Main_Btn

                    local Cool_List = Instance.new("Frame")
                    Cool_List.Size = UDim2.new(1, 0, 0, 0)
                    Cool_List.Position = UDim2.new(0, 0, 0, 37)
                    Cool_List.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_List.BorderSizePixel = 0
                    Cool_List.Parent = Cool_Drop_Frame

                    local Cool_List_Stroke = Instance.new("UIStroke")
                    Cool_List_Stroke.Color = Cool_Colors.Border
                    Cool_List_Stroke.Thickness = 1
                    Cool_List_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_List_Stroke.Parent = Cool_List

                    local Cool_List_Layout = Instance.new("UIListLayout")
                    Cool_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                    Cool_List_Layout.Parent = Cool_List

                    local function Cool_Toggle()
                        Cool_Open = not Cool_Open
                        if Cool_Open then
                            Cool_Drop_Frame.Size = UDim2.new(1, -20, 0, 37 + (#Options * 18))
                            Cool_List.Size = UDim2.new(1, 0, 0, #Options * 18)
                            Cool_Icon.Text = "-"
                            Cool_Main_Stroke.Color = Cool_Colors.Accent
                        else
                            Cool_Drop_Frame.Size = UDim2.new(1, -20, 0, 36)
                            Cool_List.Size = UDim2.new(1, 0, 0, 0)
                            Cool_Icon.Text = "+"
                            Cool_Main_Stroke.Color = Cool_Colors.Border
                        end
                    end

                    for _, Opt in ipairs(Options) do
                        local Cool_Opt_Btn = Instance.new("TextButton")
                        Cool_Opt_Btn.Size = UDim2.new(1, 0, 0, 18)
                        Cool_Opt_Btn.BackgroundTransparency = 1
                        Cool_Opt_Btn.Text = "  " .. Opt
                        Cool_Opt_Btn.TextColor3 = Cool_Colors.Text_White
                        Cool_Opt_Btn.TextSize = 12
                        Cool_Opt_Btn.Font = Cool_Font
                        Cool_Opt_Btn.TextXAlignment = Enum.TextXAlignment.Left
                        Cool_Opt_Btn.AutoButtonColor = false
                        Cool_Opt_Btn.Parent = Cool_List

                        Cool_Opt_Btn.MouseEnter:Connect(function() Cool_Opt_Btn.TextColor3 = Cool_Colors.Accent end)
                        Cool_Opt_Btn.MouseLeave:Connect(function() Cool_Opt_Btn.TextColor3 = Cool_Colors.Text_White end)
                        Cool_Opt_Btn.MouseButton1Click:Connect(function()
                            Cool_Selected = Opt
                            Cool_Main_Btn.Text = "  " .. Cool_Selected
                            Cool_Toggle()
                            Callback_Func(Cool_Selected)
                        end)
                    end

                    Cool_Main_Btn.MouseButton1Click:Connect(Cool_Toggle)
                end

                function Cool_Elements:Cool_Module_Create(Module_Name, Module_Desc, Default_State, Callback_Func)
                    local Cool_State = Default_State or false

                    local Cool_Mod_Frame = Instance.new("Frame")
                    Cool_Mod_Frame.Size = UDim2.new(1, -20, 0, 30)
                    Cool_Mod_Frame.BackgroundTransparency = 1
                    Cool_Mod_Frame.ClipsDescendants = true
                    Cool_Mod_Frame.Parent = Target_Frame

                    local Cool_Mod_Header = Instance.new("TextButton")
                    Cool_Mod_Header.Size = UDim2.new(1, 0, 0, 30)
                    Cool_Mod_Header.BackgroundColor3 = Cool_Colors.Element_Bg
                    Cool_Mod_Header.BorderSizePixel = 0
                    Cool_Mod_Header.Text = ""
                    Cool_Mod_Header.AutoButtonColor = false
                    Cool_Mod_Header.Parent = Cool_Mod_Frame

                    local Cool_Header_Stroke = Instance.new("UIStroke")
                    Cool_Header_Stroke.Color = Cool_State and Cool_Colors.Accent or Cool_Colors.Border
                    Cool_Header_Stroke.Thickness = 1
                    Cool_Header_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Header_Stroke.Parent = Cool_Mod_Header

                    local Cool_Mod_Box = Instance.new("Frame")
                    Cool_Mod_Box.Size = UDim2.new(0, 10, 0, 10)
                    Cool_Mod_Box.Position = UDim2.new(0, 10, 0.5, -5)
                    Cool_Mod_Box.BackgroundColor3 = Cool_State and Cool_Colors.Accent or Cool_Colors.Element_Bg
                    Cool_Mod_Box.BorderSizePixel = 0
                    Cool_Mod_Box.Parent = Cool_Mod_Header

                    local Cool_Box_Stroke = Instance.new("UIStroke")
                    Cool_Box_Stroke.Color = Cool_Colors.Border
                    Cool_Box_Stroke.Thickness = 1
                    Cool_Box_Stroke.LineJoinMode = Enum.LineJoinMode.Miter
                    Cool_Box_Stroke.Parent = Cool_Mod_Box

                    local Cool_Mod_Title = Instance.new("TextLabel")
                    Cool_Mod_Title.Size = UDim2.new(1, -30, 0, 14)
                    Cool_Mod_Title.Position = UDim2.new(0, 30, 0, 2)
                    Cool_Mod_Title.BackgroundTransparency = 1
                    Cool_Mod_Title.Text = Module_Name
                    Cool_Mod_Title.TextColor3 = Cool_State and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                    Cool_Mod_Title.TextSize = 12
                    Cool_Mod_Title.Font = Cool_Font
                    Cool_Mod_Title.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Mod_Title.Parent = Cool_Mod_Header

                    local Cool_Mod_Desc = Instance.new("TextLabel")
                    Cool_Mod_Desc.Size = UDim2.new(1, -30, 0, 10)
                    Cool_Mod_Desc.Position = UDim2.new(0, 30, 0, 16)
                    Cool_Mod_Desc.BackgroundTransparency = 1
                    Cool_Mod_Desc.Text = Module_Desc
                    Cool_Mod_Desc.TextColor3 = Cool_Colors.Text_Dark
                    Cool_Mod_Desc.TextSize = 10
                    Cool_Mod_Desc.Font = Cool_Font
                    Cool_Mod_Desc.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Mod_Desc.Parent = Cool_Mod_Header

                    local Cool_Mod_Content = Instance.new("Frame")
                    Cool_Mod_Content.Size = UDim2.new(1, 0, 0, 0)
                    Cool_Mod_Content.Position = UDim2.new(0, 0, 0, 32)
                    Cool_Mod_Content.BackgroundTransparency = 1
                    Cool_Mod_Content.Parent = Cool_Mod_Frame

                    local Cool_Mod_Layout = Instance.new("UIListLayout")
                    Cool_Mod_Layout.Padding = UDim.new(0, 6)
                    Cool_Mod_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    Cool_Mod_Layout.Parent = Cool_Mod_Content

                    local function Cool_Update_Size()
                        if Cool_State then
                            Cool_Mod_Frame.Size = UDim2.new(1, -20, 0, 32 + Cool_Mod_Layout.AbsoluteContentSize.Y)
                        else
                            Cool_Mod_Frame.Size = UDim2.new(1, -20, 0, 30)
                        end
                    end

                    Cool_Mod_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                        if Cool_State then Cool_Update_Size() end
                    end)

                    Cool_Mod_Header.MouseButton1Click:Connect(function()
                        Cool_State = not Cool_State
                        Cool_Mod_Box.BackgroundColor3 = Cool_State and Cool_Colors.Accent or Cool_Colors.Element_Bg
                        Cool_Mod_Title.TextColor3 = Cool_State and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                        Cool_Header_Stroke.Color = Cool_State and Cool_Colors.Accent or Cool_Colors.Border
                        Cool_Update_Size()
                        Callback_Func(Cool_State)
                    end)
                    
                    if Cool_State then Cool_Update_Size() end

                    return Cool_Init_Elements(Cool_Mod_Content)
                end

                return Cool_Elements
            end

            return Cool_Init_Elements(Cool_Section_Content)
        end

        return Cool_Section_Methods
    end

    return Cool_Window_Methods
end

return Nixware_Library_Pure
