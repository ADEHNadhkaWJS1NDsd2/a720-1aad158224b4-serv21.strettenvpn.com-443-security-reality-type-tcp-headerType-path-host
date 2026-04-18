local User_Input_Service = game:GetService("UserInputService")
local Core_Gui = game:GetService("CoreGui")

local Nixware_Library_Core = {}

local Accent_Theme_Color = Color3.fromRGB(90, 120, 220)
local Main_Bg_Color = Color3.fromRGB(12, 12, 12)
local Sidebar_Bg_Color = Color3.fromRGB(18, 18, 18)
local Section_Bg_Color = Color3.fromRGB(16, 16, 16)
local Stroke_Line_Color = Color3.fromRGB(35, 35, 35)
local Text_White_Color = Color3.fromRGB(220, 220, 220)

function Nixware_Library_Core:Cool_Window_Create(Window_Name_String)
    local Core_Screen_Gui = Instance.new("ScreenGui")
    Core_Screen_Gui.Name = "Nixware_UI_Root"
    Core_Screen_Gui.Parent = Core_Gui
    Core_Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main_Body_Frame = Instance.new("Frame")
    Main_Body_Frame.Size = UDim2.new(0, 560, 0, 400)
    Main_Body_Frame.Position = UDim2.new(0.5, -280, 0.5, -200)
    Main_Body_Frame.BackgroundColor3 = Main_Bg_Color
    Main_Body_Frame.BorderSizePixel = 0
    Main_Body_Frame.Parent = Core_Screen_Gui

    local Main_Outline_Stroke = Instance.new("UIStroke")
    Main_Outline_Stroke.Color = Stroke_Line_Color
    Main_Outline_Stroke.Thickness = 1
    Main_Outline_Stroke.Parent = Main_Body_Frame

    local Top_Header_Bar = Instance.new("Frame")
    Top_Header_Bar.Size = UDim2.new(1, 0, 0, 22)
    Top_Header_Bar.BackgroundColor3 = Sidebar_Bg_Color
    Top_Header_Bar.BorderSizePixel = 0
    Top_Header_Bar.Parent = Main_Body_Frame

    local Top_Accent_Line = Instance.new("Frame")
    Top_Accent_Line.Size = UDim2.new(1, 0, 0, 2)
    Top_Accent_Line.BackgroundColor3 = Accent_Theme_Color
    Top_Accent_Line.BorderSizePixel = 0
    Top_Accent_Line.Parent = Top_Header_Bar

    local Window_Title_Text = Instance.new("TextLabel")
    Window_Title_Text.Size = UDim2.new(1, -12, 1, -2)
    Window_Title_Text.Position = UDim2.new(0, 12, 0, 2)
    Window_Title_Text.BackgroundTransparency = 1
    Window_Title_Text.Text = Window_Name_String
    Window_Title_Text.TextColor3 = Text_White_Color
    Window_Title_Text.TextSize = 12
    Window_Title_Text.Font = Enum.Font.RobotoMono
    Window_Title_Text.TextXAlignment = Enum.TextXAlignment.Left
    Window_Title_Text.Parent = Top_Header_Bar

    local Sidebar_Holder_Frame = Instance.new("Frame")
    Sidebar_Holder_Frame.Size = UDim2.new(0, 120, 1, -22)
    Sidebar_Holder_Frame.Position = UDim2.new(0, 0, 0, 22)
    Sidebar_Holder_Frame.BackgroundColor3 = Sidebar_Bg_Color
    Sidebar_Holder_Frame.BorderSizePixel = 0
    Sidebar_Holder_Frame.Parent = Main_Body_Frame

    local Sidebar_Outline_Stroke = Instance.new("UIStroke")
    Sidebar_Outline_Stroke.Color = Stroke_Line_Color
    Sidebar_Outline_Stroke.Thickness = 1
    Sidebar_Outline_Stroke.Parent = Sidebar_Holder_Frame

    local Tab_List_Layout = Instance.new("UIListLayout")
    Tab_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tab_List_Layout.Parent = Sidebar_Holder_Frame

    local Content_Area_Frame = Instance.new("Frame")
    Content_Area_Frame.Size = UDim2.new(1, -120, 1, -22)
    Content_Area_Frame.Position = UDim2.new(0, 120, 0, 22)
    Content_Area_Frame.BackgroundTransparency = 1
    Content_Area_Frame.Parent = Main_Body_Frame

    task.spawn(function()
        local Drag_Is_Active = false
        local Drag_Start_Mouse = nil
        local Window_Start_Cords = nil

        while task.wait() do
            local Mouse_Is_Down = User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            local Mouse_Cords_Current = User_Input_Service:GetMouseLocation()
            
            if Mouse_Is_Down then
                local Header_X = Main_Body_Frame.AbsolutePosition.X
                local Header_Y = Main_Body_Frame.AbsolutePosition.Y
                local Header_W = Main_Body_Frame.AbsoluteSize.X
                
                if not Drag_Is_Active and Mouse_Cords_Current.X >= Header_X and Mouse_Cords_Current.X <= Header_X + Header_W and Mouse_Cords_Current.Y >= Header_Y and Mouse_Cords_Current.Y <= Header_Y + 22 then
                    Drag_Is_Active = true
                    Drag_Start_Mouse = Mouse_Cords_Current
                    Window_Start_Cords = Main_Body_Frame.Position
                end
                
                if Drag_Is_Active then
                    local Offset_Delta_X = Mouse_Cords_Current.X - Drag_Start_Mouse.X
                    local Offset_Delta_Y = Mouse_Cords_Current.Y - Drag_Start_Mouse.Y
                    Main_Body_Frame.Position = UDim2.new(Window_Start_Cords.X.Scale, Window_Start_Cords.X.Offset + Offset_Delta_X, Window_Start_Cords.Y.Scale, Window_Start_Cords.Y.Offset + Offset_Delta_Y)
                end
            else
                Drag_Is_Active = false
            end
        end
    end)

    local Tab_System_Logic = {
        Active_Tab_String = nil,
        All_Tabs_Table = {}
    }

    function Tab_System_Logic:Cool_Tab_Create(Tab_Name_String)
        local Tab_Click_Button = Instance.new("TextLabel")
        Tab_Click_Button.Size = UDim2.new(1, 0, 0, 30)
        Tab_Click_Button.BackgroundTransparency = 1
        Tab_Click_Button.Text = Tab_Name_String
        Tab_Click_Button.TextColor3 = Text_White_Color
        Tab_Click_Button.TextSize = 12
        Tab_Click_Button.Font = Enum.Font.RobotoMono
        Tab_Click_Button.Parent = Sidebar_Holder_Frame

        local Tab_Page_Scroll = Instance.new("ScrollingFrame")
        Tab_Page_Scroll.Size = UDim2.new(1, 0, 1, 0)
        Tab_Page_Scroll.BackgroundTransparency = 1
        Tab_Page_Scroll.BorderSizePixel = 0
        Tab_Page_Scroll.ScrollBarThickness = 2
        Tab_Page_Scroll.Visible = false
        Tab_Page_Scroll.Parent = Content_Area_Frame

        local Page_UI_Layout = Instance.new("UIListLayout")
        Page_UI_Layout.Padding = UDim.new(0, 15)
        Page_UI_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Page_UI_Layout.Parent = Tab_Page_Scroll

        local Page_UI_Padding = Instance.new("UIPadding")
        Page_UI_Padding.PaddingTop = UDim.new(0, 15)
        Page_UI_Padding.Parent = Tab_Page_Scroll

        table.insert(Tab_System_Logic.All_Tabs_Table, Tab_Page_Scroll)
        
        if #Tab_System_Logic.All_Tabs_Table == 1 then
            Tab_System_Logic.Active_Tab_String = Tab_Name_String
            Tab_Page_Scroll.Visible = true
            Tab_Click_Button.TextColor3 = Accent_Theme_Color
        end

        task.spawn(function()
            local Btn_Was_Pressed = false
            while task.wait() do
                local Mouse_Is_Down = User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                local Mouse_Cords = User_Input_Service:GetMouseLocation()
                
                local Btn_X = Tab_Click_Button.AbsolutePosition.X
                local Btn_Y = Tab_Click_Button.AbsolutePosition.Y
                local Btn_W = Tab_Click_Button.AbsoluteSize.X
                local Btn_H = Tab_Click_Button.AbsoluteSize.Y
                
                local Is_Hovered = Mouse_Cords.X >= Btn_X and Mouse_Cords.X <= Btn_X + Btn_W and Mouse_Cords.Y >= Btn_Y and Mouse_Cords.Y <= Btn_Y + Btn_H
                
                if Mouse_Is_Down and Is_Hovered and not Btn_Was_Pressed then
                    Btn_Was_Pressed = true
                    for _, Page in pairs(Tab_System_Logic.All_Tabs_Table) do
                        Page.Visible = false
                    end
                    Tab_Page_Scroll.Visible = true
                    Tab_System_Logic.Active_Tab_String = Tab_Name_String
                elseif not Mouse_Is_Down then
                    Btn_Was_Pressed = false
                end
                
                if Tab_System_Logic.Active_Tab_String == Tab_Name_String then
                    Tab_Click_Button.TextColor3 = Accent_Theme_Color
                else
                    Tab_Click_Button.TextColor3 = Text_White_Color
                end
            end
        end)

        local Section_System_Logic = {}

        function Section_System_Logic:Cool_Section_Create(Section_Name_String)
            local Section_Outer_Box = Instance.new("Frame")
            Section_Outer_Box.Size = UDim2.new(0.92, 0, 0, 20)
            Section_Outer_Box.BackgroundColor3 = Section_Bg_Color
            Section_Outer_Box.BorderSizePixel = 0
            Section_Outer_Box.Parent = Tab_Page_Scroll

            local Section_Box_Stroke = Instance.new("UIStroke")
            Section_Box_Stroke.Color = Stroke_Line_Color
            Section_Box_Stroke.Thickness = 1
            Section_Box_Stroke.Parent = Section_Outer_Box

            local Section_Title_Text = Instance.new("TextLabel")
            Section_Title_Text.Position = UDim2.new(0, 12, 0, -7)
            Section_Title_Text.Size = UDim2.new(0, 0, 0, 14)
            Section_Title_Text.AutomaticSize = Enum.AutomaticSize.X
            Section_Title_Text.BackgroundColor3 = Main_Bg_Color
            Section_Title_Text.BorderSizePixel = 0
            Section_Title_Text.Text = " " .. Section_Name_String .. " "
            Section_Title_Text.TextColor3 = Text_White_Color
            Section_Title_Text.TextSize = 11
            Section_Title_Text.Font = Enum.Font.RobotoMono
            Section_Title_Text.Parent = Section_Outer_Box

            local Section_Inner_Container = Instance.new("Frame")
            Section_Inner_Container.Size = UDim2.new(1, 0, 1, -15)
            Section_Inner_Container.Position = UDim2.new(0, 0, 0, 15)
            Section_Inner_Container.BackgroundTransparency = 1
            Section_Inner_Container.Parent = Section_Outer_Box

            local Inner_Container_Layout = Instance.new("UIListLayout")
            Inner_Container_Layout.Padding = UDim.new(0, 8)
            Inner_Container_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            Inner_Container_Layout.Parent = Section_Inner_Container

            task.spawn(function()
                local Prev_Height_Num = 0
                while task.wait(0.1) do
                    local Current_Height_Num = Inner_Container_Layout.AbsoluteContentSize.Y
                    if Current_Height_Num ~= Prev_Height_Num then
                        Prev_Height_Num = Current_Height_Num
                        Section_Outer_Box.Size = UDim2.new(0.92, 0, 0, Current_Height_Num + 25)
                    end
                end
            end)

            local Elements_System_Logic = {}

            function Elements_System_Logic:Cool_Toggle_Create(Toggle_Name_String, Default_Bool_State, Toggle_Callback_Func)
                local Current_Toggle_State = Default_Bool_State or false
                
                local Toggle_Root_Area = Instance.new("Frame")
                Toggle_Root_Area.Size = UDim2.new(1, -20, 0, 14)
                Toggle_Root_Area.BackgroundTransparency = 1
                Toggle_Root_Area.Parent = Section_Inner_Container

                local Toggle_Visual_Box = Instance.new("Frame")
                Toggle_Visual_Box.Size = UDim2.new(0, 12, 0, 12)
                Toggle_Visual_Box.Position = UDim2.new(0, 0, 0.5, -6)
                Toggle_Visual_Box.BackgroundColor3 = Current_Toggle_State and Accent_Theme_Color or Section_Bg_Color
                Toggle_Visual_Box.BorderSizePixel = 0
                Toggle_Visual_Box.Parent = Toggle_Root_Area

                local Toggle_Box_Stroke = Instance.new("UIStroke")
                Toggle_Box_Stroke.Color = Stroke_Line_Color
                Toggle_Box_Stroke.Thickness = 1
                Toggle_Box_Stroke.Parent = Toggle_Visual_Box

                local Toggle_Label_Text = Instance.new("TextLabel")
                Toggle_Label_Text.Size = UDim2.new(1, -20, 1, 0)
                Toggle_Label_Text.Position = UDim2.new(0, 20, 0, 0)
                Toggle_Label_Text.BackgroundTransparency = 1
                Toggle_Label_Text.Text = Toggle_Name_String
                Toggle_Label_Text.TextColor3 = Text_White_Color
                Toggle_Label_Text.TextSize = 11
                Toggle_Label_Text.Font = Enum.Font.RobotoMono
                Toggle_Label_Text.TextXAlignment = Enum.TextXAlignment.Left
                Toggle_Label_Text.Parent = Toggle_Root_Area

                task.spawn(function()
                    local Was_Clicked_Down = false
                    while task.wait() do
                        local Mouse_Is_Down = User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        local Mouse_Cords = User_Input_Service:GetMouseLocation()
                        
                        local Area_X = Toggle_Root_Area.AbsolutePosition.X
                        local Area_Y = Toggle_Root_Area.AbsolutePosition.Y
                        local Area_W = Toggle_Root_Area.AbsoluteSize.X
                        local Area_H = Toggle_Root_Area.AbsoluteSize.Y
                        
                        local Is_Hovered = Mouse_Cords.X >= Area_X and Mouse_Cords.X <= Area_X + Area_W and Mouse_Cords.Y >= Area_Y and Mouse_Cords.Y <= Area_Y + Area_H
                        
                        if Mouse_Is_Down and Is_Hovered and not Was_Clicked_Down then
                            Was_Clicked_Down = true
                            Current_Toggle_State = not Current_Toggle_State
                            Toggle_Visual_Box.BackgroundColor3 = Current_Toggle_State and Accent_Theme_Color or Section_Bg_Color
                            Toggle_Callback_Func(Current_Toggle_State)
                        elseif not Mouse_Is_Down then
                            Was_Clicked_Down = false
                        end
                    end
                end)
            end

            function Elements_System_Logic:Cool_Slider_Create(Slider_Name_String, Min_Num_Val, Max_Num_Val, Default_Num_Val, Slider_Callback_Func)
                local Current_Slider_Val = Default_Num_Val or Min_Num_Val

                local Slider_Root_Area = Instance.new("Frame")
                Slider_Root_Area.Size = UDim2.new(1, -20, 0, 28)
                Slider_Root_Area.BackgroundTransparency = 1
                Slider_Root_Area.Parent = Section_Inner_Container

                local Slider_Label_Text = Instance.new("TextLabel")
                Slider_Label_Text.Size = UDim2.new(1, 0, 0, 14)
                Slider_Label_Text.BackgroundTransparency = 1
                Slider_Label_Text.Text = Slider_Name_String
                Slider_Label_Text.TextColor3 = Text_White_Color
                Slider_Label_Text.TextSize = 11
                Slider_Label_Text.Font = Enum.Font.RobotoMono
                Slider_Label_Text.TextXAlignment = Enum.TextXAlignment.Left
                Slider_Label_Text.Parent = Slider_Root_Area

                local Slider_Value_Text = Instance.new("TextLabel")
                Slider_Value_Text.Size = UDim2.new(1, 0, 0, 14)
                Slider_Value_Text.BackgroundTransparency = 1
                Slider_Value_Text.Text = tostring(Current_Slider_Val)
                Slider_Value_Text.TextColor3 = Text_White_Color
                Slider_Value_Text.TextSize = 11
                Slider_Value_Text.Font = Enum.Font.RobotoMono
                Slider_Value_Text.TextXAlignment = Enum.TextXAlignment.Right
                Slider_Value_Text.Parent = Slider_Root_Area

                local Slider_Bg_Bar = Instance.new("Frame")
                Slider_Bg_Bar.Size = UDim2.new(1, 0, 0, 6)
                Slider_Bg_Bar.Position = UDim2.new(0, 0, 0, 18)
                Slider_Bg_Bar.BackgroundColor3 = Main_Bg_Color
                Slider_Bg_Bar.BorderSizePixel = 0
                Slider_Bg_Bar.Parent = Slider_Root_Area

                local Slider_Bar_Stroke = Instance.new("UIStroke")
                Slider_Bar_Stroke.Color = Stroke_Line_Color
                Slider_Bar_Stroke.Thickness = 1
                Slider_Bar_Stroke.Parent = Slider_Bg_Bar

                local Slider_Fill_Bar = Instance.new("Frame")
                Slider_Fill_Bar.Size = UDim2.new((Current_Slider_Val - Min_Num_Val) / (Max_Num_Val - Min_Num_Val), 0, 1, 0)
                Slider_Fill_Bar.BackgroundColor3 = Accent_Theme_Color
                Slider_Fill_Bar.BorderSizePixel = 0
                Slider_Fill_Bar.Parent = Slider_Bg_Bar

                task.spawn(function()
                    while task.wait() do
                        local Mouse_Is_Down = User_Input_Service:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                        local Mouse_Cords = User_Input_Service:GetMouseLocation()
                        
                        local Bar_X = Slider_Bg_Bar.AbsolutePosition.X
                        local Bar_Y = Slider_Bg_Bar.AbsolutePosition.Y
                        local Bar_W = Slider_Bg_Bar.AbsoluteSize.X
                        local Bar_H = Slider_Bg_Bar.AbsoluteSize.Y
                        
                        if Mouse_Is_Down and Mouse_Cords.X >= Bar_X - 5 and Mouse_Cords.X <= Bar_X + Bar_W + 5 and Mouse_Cords.Y >= Bar_Y - 5 and Mouse_Cords.Y <= Bar_Y + Bar_H + 5 then
                            local Offset_Delta_X = math.clamp(Mouse_Cords.X - Bar_X, 0, Bar_W)
                            local Ratio_Percent = Offset_Delta_X / Bar_W
                            Current_Slider_Val = math.floor(Min_Num_Val + (Max_Num_Val - Min_Num_Val) * Ratio_Percent)
                            Slider_Fill_Bar.Size = UDim2.new(Ratio_Percent, 0, 1, 0)
                            Slider_Value_Text.Text = tostring(Current_Slider_Val)
                            Slider_Callback_Func(Current_Slider_Val)
                        end
                    end
                end)
            end

            return Elements_System_Logic
        end

        return Section_System_Logic
    end

    return Tab_System_Logic
end

return Nixware_Library_Core
