local Core_Gui = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")

local Nixware_Library_Ultimate = {}

local Cool_Accent_Color = Color3.fromRGB(75, 110, 220)
local Cool_Main_Background = Color3.fromRGB(16, 16, 16)
local Cool_Sidebar_Color = Color3.fromRGB(21, 21, 21)
local Cool_Section_Color = Color3.fromRGB(21, 21, 21)
local Cool_Border_Color = Color3.fromRGB(45, 45, 45)
local Cool_Element_Background = Color3.fromRGB(30, 30, 30)
local Cool_Text_White = Color3.fromRGB(210, 210, 210)
local Cool_Text_Dark = Color3.fromRGB(130, 130, 130)
local Cool_Font_Style = Enum.Font.RobotoMono

function Nixware_Library_Ultimate:Cool_Window_Create(Window_Name_Text)
    local Cool_Screen_Gui = Instance.new("ScreenGui")
    Cool_Screen_Gui.Name = "Nixware_Exclusive_UI"
    Cool_Screen_Gui.Parent = Core_Gui
    Cool_Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Cool_Screen_Gui.ResetOnSpawn = false

    local Cool_Main_Frame = Instance.new("Frame")
    Cool_Main_Frame.Size = UDim2.new(0, 600, 0, 420)
    Cool_Main_Frame.Position = UDim2.new(0.5, -300, 0.5, -210)
    Cool_Main_Frame.BackgroundColor3 = Cool_Main_Background
    Cool_Main_Frame.BorderSizePixel = 0
    Cool_Main_Frame.Parent = Cool_Screen_Gui

    local Cool_Main_Stroke = Instance.new("UIStroke")
    Cool_Main_Stroke.Color = Cool_Border_Color
    Cool_Main_Stroke.Thickness = 1
    Cool_Main_Stroke.Parent = Cool_Main_Frame

    local Cool_Top_Header = Instance.new("Frame")
    Cool_Top_Header.Size = UDim2.new(1, 0, 0, 20)
    Cool_Top_Header.BackgroundColor3 = Cool_Sidebar_Color
    Cool_Top_Header.BorderSizePixel = 0
    Cool_Top_Header.Parent = Cool_Main_Frame

    local Cool_Accent_Line_Top = Instance.new("Frame")
    Cool_Accent_Line_Top.Size = UDim2.new(1, 0, 0, 2)
    Cool_Accent_Line_Top.BackgroundColor3 = Cool_Accent_Color
    Cool_Accent_Line_Top.BorderSizePixel = 0
    Cool_Accent_Line_Top.Parent = Cool_Top_Header

    local Cool_Title_Text = Instance.new("TextLabel")
    Cool_Title_Text.Size = UDim2.new(1, -10, 1, -2)
    Cool_Title_Text.Position = UDim2.new(0, 10, 0, 2)
    Cool_Title_Text.BackgroundTransparency = 1
    Cool_Title_Text.Text = Window_Name_Text
    Cool_Title_Text.TextColor3 = Cool_Text_White
    Cool_Title_Text.TextSize = 12
    Cool_Title_Text.Font = Cool_Font_Style
    Cool_Title_Text.TextXAlignment = Enum.TextXAlignment.Left
    Cool_Title_Text.Parent = Cool_Top_Header

    local Cool_Sidebar_Area = Instance.new("Frame")
    Cool_Sidebar_Area.Size = UDim2.new(0, 130, 1, -20)
    Cool_Sidebar_Area.Position = UDim2.new(0, 0, 0, 20)
    Cool_Sidebar_Area.BackgroundColor3 = Cool_Sidebar_Color
    Cool_Sidebar_Area.BorderSizePixel = 0
    Cool_Sidebar_Area.Parent = Cool_Main_Frame

    local Cool_Sidebar_Stroke = Instance.new("UIStroke")
    Cool_Sidebar_Stroke.Color = Cool_Border_Color
    Cool_Sidebar_Stroke.Thickness = 1
    Cool_Sidebar_Stroke.Parent = Cool_Sidebar_Area

    local Cool_Tab_List_Layout = Instance.new("UIListLayout")
    Cool_Tab_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Cool_Tab_List_Layout.Padding = UDim.new(0, 2)
    Cool_Tab_List_Layout.Parent = Cool_Sidebar_Area

    local Cool_Tab_Padding = Instance.new("UIPadding")
    Cool_Tab_Padding.PaddingTop = UDim.new(0, 10)
    Cool_Tab_Padding.Parent = Cool_Sidebar_Area

    local Cool_Content_Area = Instance.new("Frame")
    Cool_Content_Area.Size = UDim2.new(1, -130, 1, -20)
    Cool_Content_Area.Position = UDim2.new(0, 130, 0, 20)
    Cool_Content_Area.BackgroundTransparency = 1
    Cool_Content_Area.Parent = Cool_Main_Frame

    local Drag_Is_Active = false
    local Drag_Start_Point = nil
    local Start_Frame_Position = nil

    Cool_Top_Header.InputBegan:Connect(function(Input_Signal)
        if Input_Signal.UserInputType == Enum.UserInputType.MouseButton1 then
            Drag_Is_Active = true
            Drag_Start_Point = Input_Signal.Position
            Start_Frame_Position = Cool_Main_Frame.Position
        end
    end)

    User_Input_Service.InputChanged:Connect(function(Input_Signal)
        if Input_Signal.UserInputType == Enum.UserInputType.MouseMovement and Drag_Is_Active then
            local Delta_Distance = Input_Signal.Position - Drag_Start_Point
            Cool_Main_Frame.Position = UDim2.new(
                Start_Frame_Position.X.Scale, 
                Start_Frame_Position.X.Offset + Delta_Distance.X, 
                Start_Frame_Position.Y.Scale, 
                Start_Frame_Position.Y.Offset + Delta_Distance.Y
            )
        end
    end)

    User_Input_Service.InputEnded:Connect(function(Input_Signal)
        if Input_Signal.UserInputType == Enum.UserInputType.MouseButton1 then
            Drag_Is_Active = false
        end
    end)

    local Cool_Window_Methods = {
        Current_Active_Tab = nil,
        All_Registered_Tabs = {},
        All_Registered_Buttons = {}
    }

    function Cool_Window_Methods:Cool_Tab_Create(Tab_Name_String)
        local Cool_Tab_Button = Instance.new("TextButton")
        Cool_Tab_Button.Size = UDim2.new(1, 0, 0, 28)
        Cool_Tab_Button.BackgroundTransparency = 1
        Cool_Tab_Button.Text = Tab_Name_String
        Cool_Tab_Button.TextColor3 = Cool_Text_Dark
        Cool_Tab_Button.TextSize = 12
        Cool_Tab_Button.Font = Cool_Font_Style
        Cool_Tab_Button.Parent = Cool_Sidebar_Area

        local Cool_Tab_Scroll_Frame = Instance.new("ScrollingFrame")
        Cool_Tab_Scroll_Frame.Size = UDim2.new(1, 0, 1, 0)
        Cool_Tab_Scroll_Frame.BackgroundTransparency = 1
        Cool_Tab_Scroll_Frame.BorderSizePixel = 0
        Cool_Tab_Scroll_Frame.ScrollBarThickness = 2
        Cool_Tab_Scroll_Frame.ScrollBarImageColor3 = Cool_Accent_Color
        Cool_Tab_Scroll_Frame.Visible = false
        Cool_Tab_Scroll_Frame.Parent = Cool_Content_Area

        local Cool_Page_Layout = Instance.new("UIListLayout")
        Cool_Page_Layout.Padding = UDim.new(0, 16)
        Cool_Page_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Cool_Page_Layout.Parent = Cool_Tab_Scroll_Frame

        local Cool_Page_Padding = Instance.new("UIPadding")
        Cool_Page_Padding.PaddingTop = UDim.new(0, 16)
        Cool_Page_Padding.PaddingBottom = UDim.new(0, 16)
        Cool_Page_Padding.Parent = Cool_Tab_Scroll_Frame

        table.insert(Cool_Window_Methods.All_Registered_Tabs, Cool_Tab_Scroll_Frame)
        table.insert(Cool_Window_Methods.All_Registered_Buttons, Cool_Tab_Button)

        if #Cool_Window_Methods.All_Registered_Tabs == 1 then
            Cool_Tab_Scroll_Frame.Visible = true
            Cool_Tab_Button.TextColor3 = Cool_Accent_Color
            Cool_Window_Methods.Current_Active_Tab = Tab_Name_String
        end

        Cool_Tab_Button.MouseButton1Click:Connect(function()
            for _, Tab_Frame in pairs(Cool_Window_Methods.All_Registered_Tabs) do
                Tab_Frame.Visible = false
            end
            for _, Btn in pairs(Cool_Window_Methods.All_Registered_Buttons) do
                Btn.TextColor3 = Cool_Text_Dark
            end
            Cool_Tab_Scroll_Frame.Visible = true
            Cool_Tab_Button.TextColor3 = Cool_Accent_Color
            Cool_Window_Methods.Current_Active_Tab = Tab_Name_String
        end)

        local Cool_Section_Methods = {}

        function Cool_Section_Methods:Cool_Section_Create(Section_Name_String)
            local Cool_Section_Body = Instance.new("Frame")
            Cool_Section_Body.Size = UDim2.new(0.92, 0, 0, 20)
            Cool_Section_Body.BackgroundColor3 = Cool_Section_Color
            Cool_Section_Body.BorderSizePixel = 0
            Cool_Section_Body.Parent = Cool_Tab_Scroll_Frame

            local Cool_Section_Stroke = Instance.new("UIStroke")
            Cool_Section_Stroke.Color = Cool_Border_Color
            Cool_Section_Stroke.Thickness = 1
            Cool_Section_Stroke.Parent = Cool_Section_Body

            local Cool_Section_Title = Instance.new("TextLabel")
            Cool_Section_Title.Position = UDim2.new(0, 12, 0, -8)
            Cool_Section_Title.Size = UDim2.new(0, 0, 0, 16)
            Cool_Section_Title.AutomaticSize = Enum.AutomaticSize.X
            Cool_Section_Title.BackgroundColor3 = Cool_Main_Background
            Cool_Section_Title.BorderSizePixel = 0
            Cool_Section_Title.Text = " " .. Section_Name_String .. " "
            Cool_Section_Title.TextColor3 = Cool_Text_White
            Cool_Section_Title.TextSize = 12
            Cool_Section_Title.Font = Cool_Font_Style
            Cool_Section_Title.Parent = Cool_Section_Body

            local Cool_Section_Container = Instance.new("Frame")
            Cool_Section_Container.Size = UDim2.new(1, 0, 1, -15)
            Cool_Section_Container.Position = UDim2.new(0, 0, 0, 15)
            Cool_Section_Container.BackgroundTransparency = 1
            Cool_Section_Container.Parent = Cool_Section_Body

            local Cool_Container_Layout = Instance.new("UIListLayout")
            Cool_Container_Layout.Padding = UDim.new(0, 8)
            Cool_Container_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Cool_Container_Layout.Parent = Cool_Section_Container

            Cool_Container_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Cool_Section_Body.Size = UDim2.new(0.92, 0, 0, Cool_Container_Layout.AbsoluteContentSize.Y + 25)
                Cool_Tab_Scroll_Frame.CanvasSize = UDim2.new(0, 0, 0, Cool_Page_Layout.AbsoluteContentSize.Y + 32)
            end)

            local function Cool_Inject_Elements(Target_Container_Frame)
                local Cool_Element_Methods = {}

                function Cool_Element_Methods:Cool_Toggle_Create(Toggle_Name, Default_State, Callback_Func)
                    local Cool_Toggle_State = Default_State or false

                    local Cool_Toggle_Frame = Instance.new("TextButton")
                    Cool_Toggle_Frame.Size = UDim2.new(1, -24, 0, 14)
                    Cool_Toggle_Frame.BackgroundTransparency = 1
                    Cool_Toggle_Frame.Text = ""
                    Cool_Toggle_Frame.Parent = Target_Container_Frame

                    local Cool_Toggle_Box = Instance.new("Frame")
                    Cool_Toggle_Box.Size = UDim2.new(0, 12, 0, 12)
                    Cool_Toggle_Box.Position = UDim2.new(0, 0, 0.5, -6)
                    Cool_Toggle_Box.BackgroundColor3 = Cool_Toggle_State and Cool_Accent_Color or Cool_Element_Background
                    Cool_Toggle_Box.BorderSizePixel = 0
                    Cool_Toggle_Box.Parent = Cool_Toggle_Frame

                    local Cool_Toggle_Box_Stroke = Instance.new("UIStroke")
                    Cool_Toggle_Box_Stroke.Color = Cool_Border_Color
                    Cool_Toggle_Box_Stroke.Thickness = 1
                    Cool_Toggle_Box_Stroke.Parent = Cool_Toggle_Box

                    local Cool_Toggle_Label = Instance.new("TextLabel")
                    Cool_Toggle_Label.Size = UDim2.new(1, -20, 1, 0)
                    Cool_Toggle_Label.Position = UDim2.new(0, 20, 0, 0)
                    Cool_Toggle_Label.BackgroundTransparency = 1
                    Cool_Toggle_Label.Text = Toggle_Name
                    Cool_Toggle_Label.TextColor3 = Cool_Toggle_State and Cool_Text_White or Cool_Text_Dark
                    Cool_Toggle_Label.TextSize = 12
                    Cool_Toggle_Label.Font = Cool_Font_Style
                    Cool_Toggle_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Toggle_Label.Parent = Cool_Toggle_Frame

                    Cool_Toggle_Frame.MouseButton1Click:Connect(function()
                        Cool_Toggle_State = not Cool_Toggle_State
                        Cool_Toggle_Box.BackgroundColor3 = Cool_Toggle_State and Cool_Accent_Color or Cool_Element_Background
                        Cool_Toggle_Label.TextColor3 = Cool_Toggle_State and Cool_Text_White or Cool_Text_Dark
                        Callback_Func(Cool_Toggle_State)
                    end)
                end

                function Cool_Element_Methods:Cool_Slider_Create(Slider_Name, Min_Val, Max_Val, Default_Val, Callback_Func)
                    local Cool_Current_Value = Default_Val or Min_Val

                    local Cool_Slider_Frame = Instance.new("Frame")
                    Cool_Slider_Frame.Size = UDim2.new(1, -24, 0, 30)
                    Cool_Slider_Frame.BackgroundTransparency = 1
                    Cool_Slider_Frame.Parent = Target_Container_Frame

                    local Cool_Slider_Label = Instance.new("TextLabel")
                    Cool_Slider_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Slider_Label.BackgroundTransparency = 1
                    Cool_Slider_Label.Text = Slider_Name
                    Cool_Slider_Label.TextColor3 = Cool_Text_White
                    Cool_Slider_Label.TextSize = 12
                    Cool_Slider_Label.Font = Cool_Font_Style
                    Cool_Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Slider_Label.Parent = Cool_Slider_Frame

                    local Cool_Slider_Value_Text = Instance.new("TextLabel")
                    Cool_Slider_Value_Text.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Slider_Value_Text.BackgroundTransparency = 1
                    Cool_Slider_Value_Text.Text = tostring(Cool_Current_Value)
                    Cool_Slider_Value_Text.TextColor3 = Cool_Text_White
                    Cool_Slider_Value_Text.TextSize = 12
                    Cool_Slider_Value_Text.Font = Cool_Font_Style
                    Cool_Slider_Value_Text.TextXAlignment = Enum.TextXAlignment.Right
                    Cool_Slider_Value_Text.Parent = Cool_Slider_Frame

                    local Cool_Slider_Bg = Instance.new("Frame")
                    Cool_Slider_Bg.Size = UDim2.new(1, 0, 0, 8)
                    Cool_Slider_Bg.Position = UDim2.new(0, 0, 0, 18)
                    Cool_Slider_Bg.BackgroundColor3 = Cool_Element_Background
                    Cool_Slider_Bg.BorderSizePixel = 0
                    Cool_Slider_Bg.Parent = Cool_Slider_Frame

                    local Cool_Slider_Bg_Stroke = Instance.new("UIStroke")
                    Cool_Slider_Bg_Stroke.Color = Cool_Border_Color
                    Cool_Slider_Bg_Stroke.Thickness = 1
                    Cool_Slider_Bg_Stroke.Parent = Cool_Slider_Bg

                    local Cool_Slider_Fill = Instance.new("Frame")
                    Cool_Slider_Fill.Size = UDim2.new((Cool_Current_Value - Min_Val) / (Max_Val - Min_Val), 0, 1, 0)
                    Cool_Slider_Fill.BackgroundColor3 = Cool_Accent_Color
                    Cool_Slider_Fill.BorderSizePixel = 0
                    Cool_Slider_Fill.Parent = Cool_Slider_Bg

                    local Slider_Is_Dragging = false

                    Cool_Slider_Bg.InputBegan:Connect(function(Input_Signal)
                        if Input_Signal.UserInputType == Enum.UserInputType.MouseButton1 then
                            Slider_Is_Dragging = true
                        end
                    end)

                    User_Input_Service.InputEnded:Connect(function(Input_Signal)
                        if Input_Signal.UserInputType == Enum.UserInputType.MouseButton1 then
                            Slider_Is_Dragging = false
                        end
                    end)

                    Run_Service.RenderStepped:Connect(function()
                        if Slider_Is_Dragging then
                            local Mouse_Position = User_Input_Service:GetMouseLocation()
                            local Frame_Position = Cool_Slider_Bg.AbsolutePosition
                            local Frame_Size = Cool_Slider_Bg.AbsoluteSize

                            local Delta_X_Clamp = math.clamp(Mouse_Position.X - Frame_Position.X, 0, Frame_Size.X)
                            local Fill_Percentage = Delta_X_Clamp / Frame_Size.X

                            Cool_Current_Value = math.floor(Min_Val + ((Max_Val - Min_Val) * Fill_Percentage))
                            Cool_Slider_Fill.Size = UDim2.new(Fill_Percentage, 0, 1, 0)
                            Cool_Slider_Value_Text.Text = tostring(Cool_Current_Value)
                            
                            Callback_Func(Cool_Current_Value)
                        end
                    end)
                end

                function Cool_Element_Methods:Cool_Button_Create(Button_Name, Callback_Func)
                    local Cool_Button_Frame = Instance.new("TextButton")
                    Cool_Button_Frame.Size = UDim2.new(1, -24, 0, 24)
                    Cool_Button_Frame.BackgroundColor3 = Cool_Element_Background
                    Cool_Button_Frame.BorderSizePixel = 0
                    Cool_Button_Frame.Text = Button_Name
                    Cool_Button_Frame.TextColor3 = Cool_Text_White
                    Cool_Button_Frame.TextSize = 12
                    Cool_Button_Frame.Font = Cool_Font_Style
                    Cool_Button_Frame.Parent = Target_Container_Frame

                    local Cool_Button_Stroke = Instance.new("UIStroke")
                    Cool_Button_Stroke.Color = Cool_Border_Color
                    Cool_Button_Stroke.Thickness = 1
                    Cool_Button_Stroke.Parent = Cool_Button_Frame

                    Cool_Button_Frame.MouseButton1Down:Connect(function()
                        Cool_Button_Stroke.Color = Cool_Accent_Color
                    end)

                    Cool_Button_Frame.MouseButton1Up:Connect(function()
                        Cool_Button_Stroke.Color = Cool_Border_Color
                        Callback_Func()
                    end)
                    
                    Cool_Button_Frame.MouseLeave:Connect(function()
                        Cool_Button_Stroke.Color = Cool_Border_Color
                    end)
                end

                function Cool_Element_Methods:Cool_Dropdown_Create(Dropdown_Name, Options_Table, Default_Option, Callback_Func)
                    local Cool_Dropdown_State = false
                    local Cool_Selected_Option = Default_Option or Options_Table[1]

                    local Cool_Dropdown_Root = Instance.new("Frame")
                    Cool_Dropdown_Root.Size = UDim2.new(1, -24, 0, 42)
                    Cool_Dropdown_Root.BackgroundTransparency = 1
                    Cool_Dropdown_Root.Parent = Target_Container_Frame

                    local Cool_Dropdown_Label = Instance.new("TextLabel")
                    Cool_Dropdown_Label.Size = UDim2.new(1, 0, 0, 14)
                    Cool_Dropdown_Label.BackgroundTransparency = 1
                    Cool_Dropdown_Label.Text = Dropdown_Name
                    Cool_Dropdown_Label.TextColor3 = Cool_Text_White
                    Cool_Dropdown_Label.TextSize = 12
                    Cool_Dropdown_Label.Font = Cool_Font_Style
                    Cool_Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Dropdown_Label.Parent = Cool_Dropdown_Root

                    local Cool_Dropdown_Main_Btn = Instance.new("TextButton")
                    Cool_Dropdown_Main_Btn.Size = UDim2.new(1, 0, 0, 22)
                    Cool_Dropdown_Main_Btn.Position = UDim2.new(0, 0, 0, 18)
                    Cool_Dropdown_Main_Btn.BackgroundColor3 = Cool_Element_Background
                    Cool_Dropdown_Main_Btn.BorderSizePixel = 0
                    Cool_Dropdown_Main_Btn.Text = " " .. Cool_Selected_Option
                    Cool_Dropdown_Main_Btn.TextColor3 = Cool_Text_Dark
                    Cool_Dropdown_Main_Btn.TextSize = 12
                    Cool_Dropdown_Main_Btn.Font = Cool_Font_Style
                    Cool_Dropdown_Main_Btn.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Dropdown_Main_Btn.Parent = Cool_Dropdown_Root

                    local Cool_Dropdown_Main_Stroke = Instance.new("UIStroke")
                    Cool_Dropdown_Main_Stroke.Color = Cool_Border_Color
                    Cool_Dropdown_Main_Stroke.Thickness = 1
                    Cool_Dropdown_Main_Stroke.Parent = Cool_Dropdown_Main_Btn

                    local Cool_Dropdown_Icon = Instance.new("TextLabel")
                    Cool_Dropdown_Icon.Size = UDim2.new(0, 22, 1, 0)
                    Cool_Dropdown_Icon.Position = UDim2.new(1, -22, 0, 0)
                    Cool_Dropdown_Icon.BackgroundTransparency = 1
                    Cool_Dropdown_Icon.Text = "+"
                    Cool_Dropdown_Icon.TextColor3 = Cool_Text_Dark
                    Cool_Dropdown_Icon.TextSize = 14
                    Cool_Dropdown_Icon.Font = Cool_Font_Style
                    Cool_Dropdown_Icon.Parent = Cool_Dropdown_Main_Btn

                    local Cool_Dropdown_List_Frame = Instance.new("Frame")
                    Cool_Dropdown_List_Frame.Size = UDim2.new(1, 0, 0, 0)
                    Cool_Dropdown_List_Frame.Position = UDim2.new(0, 0, 0, 42)
                    Cool_Dropdown_List_Frame.BackgroundColor3 = Cool_Element_Background
                    Cool_Dropdown_List_Frame.BorderSizePixel = 0
                    Cool_Dropdown_List_Frame.Visible = false
                    Cool_Dropdown_List_Frame.ZIndex = 5
                    Cool_Dropdown_List_Frame.Parent = Cool_Dropdown_Root

                    local Cool_Dropdown_List_Stroke = Instance.new("UIStroke")
                    Cool_Dropdown_List_Stroke.Color = Cool_Border_Color
                    Cool_Dropdown_List_Stroke.Thickness = 1
                    Cool_Dropdown_List_Stroke.Parent = Cool_Dropdown_List_Frame

                    local Cool_Dropdown_Layout = Instance.new("UIListLayout")
                    Cool_Dropdown_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                    Cool_Dropdown_Layout.Parent = Cool_Dropdown_List_Frame

                    for _, Option_String in ipairs(Options_Table) do
                        local Cool_Option_Btn = Instance.new("TextButton")
                        Cool_Option_Btn.Size = UDim2.new(1, 0, 0, 20)
                        Cool_Option_Btn.BackgroundColor3 = Cool_Element_Background
                        Cool_Option_Btn.BorderSizePixel = 0
                        Cool_Option_Btn.Text = " " .. Option_String
                        Cool_Option_Btn.TextColor3 = Cool_Text_White
                        Cool_Option_Btn.TextSize = 12
                        Cool_Option_Btn.Font = Cool_Font_Style
                        Cool_Option_Btn.TextXAlignment = Enum.TextXAlignment.Left
                        Cool_Option_Btn.ZIndex = 6
                        Cool_Option_Btn.Parent = Cool_Dropdown_List_Frame

                        Cool_Option_Btn.MouseEnter:Connect(function()
                            Cool_Option_Btn.TextColor3 = Cool_Accent_Color
                        end)

                        Cool_Option_Btn.MouseLeave:Connect(function()
                            Cool_Option_Btn.TextColor3 = Cool_Text_White
                        end)

                        Cool_Option_Btn.MouseButton1Click:Connect(function()
                            Cool_Selected_Option = Option_String
                            Cool_Dropdown_Main_Btn.Text = " " .. Cool_Selected_Option
                            Cool_Dropdown_State = false
                            Cool_Dropdown_List_Frame.Visible = false
                            Cool_Dropdown_Root.Size = UDim2.new(1, -24, 0, 42)
                            Cool_Dropdown_Icon.Text = "+"
                            Callback_Func(Cool_Selected_Option)
                        end)
                    end

                    Cool_Dropdown_Main_Btn.MouseButton1Click:Connect(function()
                        Cool_Dropdown_State = not Cool_Dropdown_State
                        if Cool_Dropdown_State then
                            Cool_Dropdown_List_Frame.Size = UDim2.new(1, 0, 0, #Options_Table * 20)
                            Cool_Dropdown_List_Frame.Visible = true
                            Cool_Dropdown_Root.Size = UDim2.new(1, -24, 0, 42 + (#Options_Table * 20))
                            Cool_Dropdown_Icon.Text = "-"
                        else
                            Cool_Dropdown_List_Frame.Visible = false
                            Cool_Dropdown_Root.Size = UDim2.new(1, -24, 0, 42)
                            Cool_Dropdown_Icon.Text = "+"
                        end
                    end)
                end

                function Cool_Element_Methods:Cool_Module_Create(Module_Name, Module_Desc, Default_State, Callback_Func)
                    local Cool_Module_State = Default_State or false

                    local Cool_Module_Root = Instance.new("Frame")
                    Cool_Module_Root.Size = UDim2.new(1, -24, 0, 36)
                    Cool_Module_Root.BackgroundTransparency = 1
                    Cool_Module_Root.Parent = Target_Container_Frame

                    local Cool_Module_Header = Instance.new("TextButton")
                    Cool_Module_Header.Size = UDim2.new(1, 0, 0, 36)
                    Cool_Module_Header.BackgroundTransparency = 1
                    Cool_Module_Header.Text = ""
                    Cool_Module_Header.Parent = Cool_Module_Root

                    local Cool_Module_Checkbox = Instance.new("Frame")
                    Cool_Module_Checkbox.Size = UDim2.new(0, 12, 0, 12)
                    Cool_Module_Checkbox.Position = UDim2.new(0, 0, 0, 12)
                    Cool_Module_Checkbox.BackgroundColor3 = Cool_Module_State and Cool_Accent_Color or Cool_Element_Background
                    Cool_Module_Checkbox.BorderSizePixel = 0
                    Cool_Module_Checkbox.Parent = Cool_Module_Header

                    local Cool_Module_Stroke = Instance.new("UIStroke")
                    Cool_Module_Stroke.Color = Cool_Border_Color
                    Cool_Module_Stroke.Thickness = 1
                    Cool_Module_Stroke.Parent = Cool_Module_Checkbox

                    local Cool_Module_Title = Instance.new("TextLabel")
                    Cool_Module_Title.Size = UDim2.new(1, -20, 0, 16)
                    Cool_Module_Title.Position = UDim2.new(0, 20, 0, 2)
                    Cool_Module_Title.BackgroundTransparency = 1
                    Cool_Module_Title.Text = Module_Name
                    Cool_Module_Title.TextColor3 = Cool_Module_State and Cool_Text_White or Cool_Text_Dark
                    Cool_Module_Title.TextSize = 12
                    Cool_Module_Title.Font = Cool_Font_Style
                    Cool_Module_Title.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Module_Title.Parent = Cool_Module_Header

                    local Cool_Module_Desc_Label = Instance.new("TextLabel")
                    Cool_Module_Desc_Label.Size = UDim2.new(1, -20, 0, 14)
                    Cool_Module_Desc_Label.Position = UDim2.new(0, 20, 0, 18)
                    Cool_Module_Desc_Label.BackgroundTransparency = 1
                    Cool_Module_Desc_Label.Text = Module_Desc
                    Cool_Module_Desc_Label.TextColor3 = Cool_Text_Dark
                    Cool_Module_Desc_Label.TextSize = 10
                    Cool_Module_Desc_Label.Font = Cool_Font_Style
                    Cool_Module_Desc_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Module_Desc_Label.Parent = Cool_Module_Header

                    local Cool_Module_Content = Instance.new("Frame")
                    Cool_Module_Content.Size = UDim2.new(1, 0, 0, 0)
                    Cool_Module_Content.Position = UDim2.new(0, 12, 0, 44)
                    Cool_Module_Content.BackgroundTransparency = 1
                    Cool_Module_Content.Visible = Cool_Module_State
                    Cool_Module_Content.Parent = Cool_Module_Root

                    local Cool_Module_Layout = Instance.new("UIListLayout")
                    Cool_Module_Layout.Padding = UDim.new(0, 8)
                    Cool_Module_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                    Cool_Module_Layout.Parent = Cool_Module_Content

                    local function Cool_Update_Module_Size()
                        if Cool_Module_State then
                            Cool_Module_Root.Size = UDim2.new(1, -24, 0, 48 + Cool_Module_Layout.AbsoluteContentSize.Y)
                        else
                            Cool_Module_Root.Size = UDim2.new(1, -24, 0, 36)
                        end
                    end

                    Cool_Module_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Cool_Update_Module_Size)

                    Cool_Module_Header.MouseButton1Click:Connect(function()
                        Cool_Module_State = not Cool_Module_State
                        Cool_Module_Checkbox.BackgroundColor3 = Cool_Module_State and Cool_Accent_Color or Cool_Element_Background
                        Cool_Module_Title.TextColor3 = Cool_Module_State and Cool_Text_White or Cool_Text_Dark
                        Cool_Module_Content.Visible = Cool_Module_State
                        Cool_Update_Module_Size()
                        Callback_Func(Cool_Module_State)
                    end)

                    return Cool_Inject_Elements(Cool_Module_Content)
                end

                return Cool_Element_Methods
            end

            return Cool_Inject_Elements(Cool_Section_Container)
        end

        return Cool_Section_Methods
    end

    return Cool_Window_Methods
end

return Nixware_Library_Ultimate
