local User_Input_Service = game:GetService("UserInputService")
local Core_Gui = game:GetService("CoreGui")

local Nixware_Library = {}

local Cool_Accent_Color = Color3.fromRGB(120, 150, 255)
local Background_Dark_Main = Color3.fromRGB(10, 10, 10)
local Sidebar_Dark_Color = Color3.fromRGB(14, 14, 14)
local Section_Dark_Color = Color3.fromRGB(18, 18, 18)
local Border_Gray_Line = Color3.fromRGB(35, 35, 35)
local Text_White_Main = Color3.fromRGB(215, 215, 215)

function Nixware_Library:Cool_Window_Create(Window_Title)
    local Screen_Gui = Instance.new("ScreenGui")
    Screen_Gui.Name = "Nixware_Project"
    Screen_Gui.Parent = Core_Gui
    Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main_Frame_Body = Instance.new("Frame")
    Main_Frame_Body.Name = "Main_Frame"
    Main_Frame_Body.Size = UDim2.new(0, 520, 0, 380)
    Main_Frame_Body.Position = UDim2.new(0.5, -260, 0.5, -190)
    Main_Frame_Body.BackgroundColor3 = Background_Dark_Main
    Main_Frame_Body.BorderSizePixel = 0
    Main_Frame_Body.Parent = Screen_Gui

    local Main_Stroke_Outline = Instance.new("UIStroke")
    Main_Stroke_Outline.Color = Border_Gray_Line
    Main_Stroke_Outline.Thickness = 1
    Main_Stroke_Outline.Parent = Main_Frame_Body

    local Top_Bar_Header = Instance.new("Frame")
    Top_Bar_Header.Size = UDim2.new(1, 0, 0, 24)
    Top_Bar_Header.BackgroundColor3 = Sidebar_Dark_Color
    Top_Bar_Header.BorderSizePixel = 0
    Top_Bar_Header.Parent = Main_Frame_Body

    local Accent_Line_Top = Instance.new("Frame")
    Accent_Line_Top.Size = UDim2.new(1, 0, 0, 1)
    Accent_Line_Top.Position = UDim2.new(0, 0, 0, 0)
    Accent_Line_Top.BackgroundColor3 = Cool_Accent_Color
    Accent_Line_Top.BorderSizePixel = 0
    Accent_Line_Top.Parent = Top_Bar_Header

    local Title_Label_Text = Instance.new("TextLabel")
    Title_Label_Text.Size = UDim2.new(1, -10, 1, 0)
    Title_Label_Text.Position = UDim2.new(0, 10, 0, 0)
    Title_Label_Text.BackgroundTransparency = 1
    Title_Label_Text.Text = Window_Title
    Title_Label_Text.TextColor3 = Text_White_Main
    Title_Label_Text.TextSize = 13
    Title_Label_Text.Font = Enum.Font.RobotoMono
    Title_Label_Text.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label_Text.Parent = Top_Bar_Header

    local Tab_Holder_Left = Instance.new("Frame")
    Tab_Holder_Left.Size = UDim2.new(0, 110, 1, -24)
    Tab_Holder_Left.Position = UDim2.new(0, 0, 0, 24)
    Tab_Holder_Left.BackgroundColor3 = Sidebar_Dark_Color
    Tab_Holder_Left.BorderSizePixel = 0
    Tab_Holder_Left.Parent = Main_Frame_Body

    local Tab_Layout_List = Instance.new("UIListLayout")
    Tab_Layout_List.SortOrder = Enum.SortOrder.LayoutOrder
    Tab_Layout_List.Parent = Tab_Holder_Left

    local Content_Holder_Right = Instance.new("Frame")
    Content_Holder_Right.Size = UDim2.new(1, -110, 1, -24)
    Content_Holder_Right.Position = UDim2.new(0, 110, 0, 24)
    Content_Holder_Right.BackgroundTransparency = 1
    Content_Holder_Right.Parent = Main_Frame_Body

    local Dragging_Is_Active = false
    local Drag_Origin_Point = nil
    local Frame_Origin_Pos = nil

    Top_Bar_Header.InputBegan:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging_Is_Active = true
            Drag_Origin_Point = Input_Obj.Position
            Frame_Origin_Pos = Main_Frame_Body.Position
        end
    end)

    User_Input_Service.InputChanged:Connect(function(Input_Obj)
        if Dragging_Is_Active and Input_Obj.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta_V2 = Input_Obj.Position - Drag_Origin_Point
            Main_Frame_Body.Position = UDim2.new(Frame_Origin_Pos.X.Scale, Frame_Origin_Pos.X.Offset + Delta_V2.X, Frame_Origin_Pos.Y.Scale, Frame_Origin_Pos.Y.Offset + Delta_V2.Y)
        end
    end)

    User_Input_Service.InputEnded:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging_Is_Active = false
        end
    end)

    local Window_Control_Methods = {
        Current_Active_Tab = nil,
        Tabs_Internal_List = {}
    }

    function Window_Control_Methods:Cool_Tab_Create(Tab_Name)
        local Tab_Button_Link = Instance.new("TextButton")
        Tab_Button_Link.Size = UDim2.new(1, 0, 0, 32)
        Tab_Button_Link.BackgroundTransparency = 1
        Tab_Button_Link.Text = Tab_Name
        Tab_Button_Link.TextColor3 = Text_White_Main
        Tab_Button_Link.TextSize = 12
        Tab_Button_Link.Font = Enum.Font.RobotoMono
        Tab_Button_Link.Parent = Tab_Holder_Left

        local Tab_Page_Frame = Instance.new("ScrollingFrame")
        Tab_Page_Frame.Size = UDim2.new(1, 0, 1, 0)
        Tab_Page_Frame.BackgroundTransparency = 1
        Tab_Page_Frame.BorderSizePixel = 0
        Tab_Page_Frame.ScrollBarThickness = 1
        Tab_Page_Frame.Visible = false
        Tab_Page_Frame.Parent = Content_Holder_Right

        local Page_Layout_Settings = Instance.new("UIListLayout")
        Page_Layout_Settings.Padding = UDim.new(0, 10)
        Page_Layout_Settings.HorizontalAlignment = Enum.HorizontalAlignment.Center
        Page_Layout_Settings.Parent = Tab_Page_Frame

        local Page_Padding_Outer = Instance.new("UIPadding")
        Page_Padding_Outer.PaddingTop = UDim.new(0, 12)
        Page_Padding_Outer.Parent = Tab_Page_Frame

        Tab_Button_Link.MouseButton1Click:Connect(function()
            for _, Page_Item in pairs(Window_Control_Methods.Tabs_Internal_List) do
                Page_Item.Visible = false
            end
            Tab_Page_Frame.Visible = true
        end)

        table.insert(Window_Control_Methods.Tabs_Internal_List, Tab_Page_Frame)
        if #Window_Control_Methods.Tabs_Internal_List == 1 then
            Tab_Page_Frame.Visible = true
        end

        local Tab_Feature_Logic = {}

        function Tab_Feature_Logic:Cool_Section_Create(Section_Label)
            local Section_Body_Frame = Instance.new("Frame")
            Section_Body_Frame.Size = UDim2.new(0.94, 0, 0, 20)
            Section_Body_Frame.BackgroundColor3 = Section_Dark_Color
            Section_Body_Frame.BorderSizePixel = 0
            Section_Body_Frame.Parent = Tab_Page_Frame

            local Section_Stroke_Line = Instance.new("UIStroke")
            Section_Stroke_Line.Color = Border_Gray_Line
            Section_Stroke_Line.Thickness = 1
            Section_Stroke_Line.Parent = Section_Body_Frame

            local Section_Header_Text = Instance.new("TextLabel")
            Section_Header_Text.Size = UDim2.new(1, -10, 0, 18)
            Section_Header_Text.Position = UDim2.new(0, 10, 0, -10)
            Section_Header_Text.BackgroundTransparency = 0
            Section_Header_Text.BackgroundColor3 = Background_Dark_Main
            Section_Header_Text.Text = " " .. Section_Label .. " "
            Section_Header_Text.TextColor3 = Text_White_Main
            Section_Header_Text.TextSize = 11
            Section_Header_Text.Font = Enum.Font.RobotoMono
            Section_Header_Text.AutomaticSize = Enum.AutomaticSize.X
            Section_Header_Text.Parent = Section_Body_Frame

            local Section_Layout_Stack = Instance.new("UIListLayout")
            Section_Layout_Stack.Padding = UDim.new(0, 6)
            Section_Layout_Stack.Parent = Section_Body_Frame

            local Section_Padding_Inner = Instance.new("UIPadding")
            Section_Padding_Inner.PaddingLeft = UDim.new(0, 10)
            Section_Padding_Inner.PaddingTop = UDim.new(0, 14)
            Section_Padding_Inner.PaddingBottom = UDim.new(0, 10)
            Section_Padding_Inner.Parent = Section_Body_Frame
            
            Section_Layout_Stack:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Section_Body_Frame.Size = UDim2.new(0.94, 0, 0, Section_Layout_Stack.AbsoluteContentSize.Y + 24)
            end)

            local Final_Element_Methods = {}

            function Final_Element_Methods:Cool_Toggle_Create(Toggle_Label, Default_State, Toggle_Callback)
                local Toggle_Status = Default_State or false
                
                local Toggle_Click_Area = Instance.new("TextButton")
                Toggle_Click_Area.Size = UDim2.new(1, -10, 0, 20)
                Toggle_Click_Area.BackgroundTransparency = 1
                Toggle_Click_Area.Text = ""
                Toggle_Click_Area.Parent = Section_Body_Frame

                local Box_Check_Visual = Instance.new("Frame")
                Box_Check_Visual.Size = UDim2.new(0, 12, 0, 12)
                Box_Check_Visual.Position = UDim2.new(0, 0, 0.5, -6)
                Box_Check_Visual.BackgroundColor3 = Toggle_Status and Cool_Accent_Color or Background_Dark_Main
                Box_Check_Visual.BorderSizePixel = 0
                Box_Check_Visual.Parent = Toggle_Click_Area

                local Check_Stroke_Style = Instance.new("UIStroke")
                Check_Stroke_Style.Color = Border_Gray_Line
                Check_Stroke_Style.Thickness = 1
                Check_Stroke_Style.Parent = Box_Check_Visual

                local Label_Display_Text = Instance.new("TextLabel")
                Label_Display_Text.Size = UDim2.new(1, -20, 1, 0)
                Label_Display_Text.Position = UDim2.new(0, 20, 0, 0)
                Label_Display_Text.BackgroundTransparency = 1
                Label_Display_Text.Text = Toggle_Label
                Label_Display_Text.TextColor3 = Text_White_Main
                Label_Display_Text.TextSize = 12
                Label_Display_Text.Font = Enum.Font.RobotoMono
                Label_Display_Text.TextXAlignment = Enum.TextXAlignment.Left
                Label_Display_Text.Parent = Toggle_Click_Area

                Toggle_Click_Area.MouseButton1Click:Connect(function()
                    Toggle_Status = not Toggle_Status
                    Box_Check_Visual.BackgroundColor3 = Toggle_Status and Cool_Accent_Color or Background_Dark_Main
                    Toggle_Callback(Toggle_Status)
                end)
            end

            function Final_Element_Methods:Cool_Slider_Create(Slider_Label, Min_Boundary, Max_Boundary, Current_Pos, Slider_Callback)
                local Slider_Val = Current_Pos or Min_Boundary

                local Slider_Root_Box = Instance.new("Frame")
                Slider_Root_Box.Size = UDim2.new(1, -10, 0, 32)
                Slider_Root_Box.BackgroundTransparency = 1
                Slider_Root_Box.Parent = Section_Body_Frame

                local Label_Name_Tag = Instance.new("TextLabel")
                Label_Name_Tag.Size = UDim2.new(1, 0, 0, 16)
                Label_Name_Tag.BackgroundTransparency = 1
                Label_Name_Tag.Text = Slider_Label
                Label_Name_Tag.TextColor3 = Text_White_Main
                Label_Name_Tag.TextSize = 11
                Label_Name_Tag.Font = Enum.Font.RobotoMono
                Label_Name_Tag.TextXAlignment = Enum.TextXAlignment.Left
                Label_Name_Tag.Parent = Slider_Root_Box

                local Label_Num_Display = Instance.new("TextLabel")
                Label_Num_Display.Size = UDim2.new(1, 0, 0, 16)
                Label_Num_Display.BackgroundTransparency = 1
                Label_Num_Display.Text = tostring(Slider_Val)
                Label_Num_Display.TextColor3 = Text_White_Main
                Label_Num_Display.TextSize = 11
                Label_Num_Display.Font = Enum.Font.RobotoMono
                Label_Num_Display.TextXAlignment = Enum.TextXAlignment.Right
                Label_Num_Display.Parent = Slider_Root_Box

                local Bar_Bg_Area = Instance.new("Frame")
                Bar_Bg_Area.Size = UDim2.new(1, -5, 0, 8)
                Bar_Bg_Area.Position = UDim2.new(0, 0, 0, 20)
                Bar_Bg_Area.BackgroundColor3 = Background_Dark_Main
                Bar_Bg_Area.BorderSizePixel = 0
                Bar_Bg_Area.Parent = Slider_Root_Box

                local Bar_Stroke_Line = Instance.new("UIStroke")
                Bar_Stroke_Line.Color = Border_Gray_Line
                Bar_Stroke_Line.Thickness = 1
                Bar_Stroke_Line.Parent = Bar_Bg_Area

                local Bar_Fill_Progress = Instance.new("Frame")
                Bar_Fill_Progress.Size = UDim2.new((Slider_Val - Min_Boundary) / (Max_Boundary - Min_Boundary), 0, 1, 0)
                Bar_Fill_Progress.BackgroundColor3 = Cool_Accent_Color
                Bar_Fill_Progress.BorderSizePixel = 0
                Bar_Fill_Progress.Parent = Bar_Bg_Area

                local function Cool_Update_Slider_Visual()
                    local Mouse_Coord_Pos = User_Input_Service:GetMouseLocation()
                    local Relative_Delta_X = math.clamp(Mouse_Coord_Pos.X - Bar_Bg_Area.AbsolutePosition.X, 0, Bar_Bg_Area.AbsoluteSize.X)
                    local Fill_Ratio = Relative_Delta_X / Bar_Bg_Area.AbsoluteSize.X
                    Slider_Val = math.floor(Min_Boundary + (Max_Boundary - Min_Boundary) * Fill_Ratio)
                    Bar_Fill_Progress.Size = UDim2.new(Fill_Ratio, 0, 1, 0)
                    Label_Num_Display.Text = tostring(Slider_Val)
                    Slider_Callback(Slider_Val)
                end

                Bar_Bg_Area.InputBegan:Connect(function(Input_Signal)
                    if Input_Signal.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Move_Input_Conn
                        Move_Input_Conn = User_Input_Service.InputChanged:Connect(function(Move_Signal)
                            if Move_Signal.UserInputType == Enum.UserInputType.MouseMovement then
                                Cool_Update_Slider_Visual()
                            end
                        end)
                        User_Input_Service.InputEnded:Connect(function(End_Signal)
                            if End_Signal.UserInputType == Enum.UserInputType.MouseButton1 then
                                Move_Input_Conn:Disconnect()
                            end
                        end)
                        Cool_Update_Slider_Visual()
                    end
                end)
            end

            return Final_Element_Methods
        end

        return Tab_Feature_Logic
    end

    return Window_Control_Methods
end

return Nixware_Library
