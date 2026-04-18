local Core_Gui = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")
local Tween_Service = game:GetService("TweenService")
local Text_Service = game:GetService("TextService")
local Http_Service = game:GetService("HttpService")

local Nixware_Premium_Api = {
    Cool_Flags = {}
}

local Cool_Colors = {
    Main_Bg = Color3.fromRGB(10, 10, 14),
    Sidebar_Bg = Color3.fromRGB(14, 14, 18),
    Section_Bg = Color3.fromRGB(18, 18, 22),
    Element_Bg = Color3.fromRGB(24, 24, 28),
    Element_Hover = Color3.fromRGB(32, 32, 38),
    Border = Color3.fromRGB(28, 28, 35),
    Border_Light = Color3.fromRGB(45, 45, 55),
    Accent = Color3.fromRGB(110, 150, 255),
    Accent_Grad_1 = Color3.fromRGB(110, 150, 255),
    Accent_Grad_2 = Color3.fromRGB(160, 120, 255),
    Text_White = Color3.fromRGB(245, 245, 250),
    Text_Dark = Color3.fromRGB(140, 140, 150),
    Tooltip_Bg = Color3.fromRGB(12, 12, 16)
}

local Cool_Font = Enum.Font.GothamMedium
local Cool_Bold_Font = Enum.Font.GothamBold

local Cool_Tooltip_Gui = Instance.new("ScreenGui")
Cool_Tooltip_Gui.Name = Http_Service:GenerateGUID(false)
Cool_Tooltip_Gui.Parent = Core_Gui
Cool_Tooltip_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Cool_Tooltip_Gui.DisplayOrder = 999 

local Cool_Tooltip_Frame = Instance.new("Frame")
Cool_Tooltip_Frame.BackgroundColor3 = Cool_Colors.Tooltip_Bg
Cool_Tooltip_Frame.BackgroundTransparency = 1
Cool_Tooltip_Frame.Size = UDim2.new(0, 0, 0, 24)
Cool_Tooltip_Frame.ZIndex = 1000
Cool_Tooltip_Frame.Visible = false
Cool_Tooltip_Frame.Parent = Cool_Tooltip_Gui

local Cool_Tooltip_Corner = Instance.new("UICorner")
Cool_Tooltip_Corner.CornerRadius = UDim.new(0, 4)
Cool_Tooltip_Corner.Parent = Cool_Tooltip_Frame

local Cool_Tooltip_Stroke = Instance.new("UIStroke")
Cool_Tooltip_Stroke.Color = Cool_Colors.Border_Light
Cool_Tooltip_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Cool_Tooltip_Stroke.Transparency = 1
Cool_Tooltip_Stroke.Parent = Cool_Tooltip_Frame

local Cool_Tooltip_Text = Instance.new("TextLabel")
Cool_Tooltip_Text.Size = UDim2.new(1, -16, 1, 0)
Cool_Tooltip_Text.Position = UDim2.new(0, 8, 0, 0)
Cool_Tooltip_Text.BackgroundTransparency = 1
Cool_Tooltip_Text.TextColor3 = Cool_Colors.Text_White
Cool_Tooltip_Text.TextTransparency = 1
Cool_Tooltip_Text.TextSize = 12
Cool_Tooltip_Text.Font = Cool_Font
Cool_Tooltip_Text.TextXAlignment = Enum.TextXAlignment.Left
Cool_Tooltip_Text.ZIndex = 1001
Cool_Tooltip_Text.Parent = Cool_Tooltip_Frame

local Tooltip_Target = ""

local function Cool_Animate(Object, Props, Speed)
    local Tween = Tween_Service:Create(Object, TweenInfo.new(Speed or 0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), Props)
    Tween:Play()
    return Tween
end

local function Cool_Show_Tooltip(Text_Str)
    if not Text_Str or Text_Str == "" then
        Tooltip_Target = ""
        return
    end
    local Bounds = Text_Service:GetTextSize(Text_Str, 12, Cool_Font, Vector2.new(500, 24))
    Cool_Tooltip_Frame.Size = UDim2.new(0, Bounds.X + 16, 0, 24)
    Cool_Tooltip_Text.Text = Text_Str
    Tooltip_Target = Text_Str
end

Run_Service.RenderStepped:Connect(function()
    if Tooltip_Target ~= "" then
        local Mouse = User_Input_Service:GetMouseLocation()
        Cool_Tooltip_Frame.Position = UDim2.new(0, Mouse.X + 15, 0, Mouse.Y + 15)
        if not Cool_Tooltip_Frame.Visible then
            Cool_Tooltip_Frame.Visible = true
            Cool_Animate(Cool_Tooltip_Frame, {BackgroundTransparency = 0.05}, 0.2)
            Cool_Animate(Cool_Tooltip_Stroke, {Transparency = 0}, 0.2)
            Cool_Animate(Cool_Tooltip_Text, {TextTransparency = 0}, 0.2)
        end
    else
        Cool_Animate(Cool_Tooltip_Frame, {BackgroundTransparency = 1}, 0.1)
        Cool_Animate(Cool_Tooltip_Stroke, {Transparency = 1}, 0.1)
        Cool_Animate(Cool_Tooltip_Text, {TextTransparency = 1}, 0.1)
        task.delay(0.1, function()
            if Tooltip_Target == "" then
                Cool_Tooltip_Frame.Visible = false
            end
        end)
    end
end)

function Nixware_Premium_Api:Cool_Window_Create(Window_Name)
    local Cool_Screen = Instance.new("ScreenGui")
    Cool_Screen.Name = Http_Service:GenerateGUID(false)
    Cool_Screen.Parent = Core_Gui
    Cool_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Cool_Main_Bg = Instance.new("Frame")
    Cool_Main_Bg.Size = UDim2.new(0, 720, 0, 480)
    Cool_Main_Bg.Position = UDim2.new(0.5, -360, 0.5, -240)
    Cool_Main_Bg.BackgroundColor3 = Cool_Colors.Main_Bg
    Cool_Main_Bg.BorderSizePixel = 0
    Cool_Main_Bg.Active = true
    Cool_Main_Bg.Parent = Cool_Screen
    
    local Main_Corner = Instance.new("UICorner")
    Main_Corner.CornerRadius = UDim.new(0, 6)
    Main_Corner.Parent = Cool_Main_Bg
    
    local Main_Stroke = Instance.new("UIStroke")
    Main_Stroke.Color = Cool_Colors.Border
    Main_Stroke.Parent = Cool_Main_Bg

    local Cool_Top_Bar = Instance.new("Frame")
    Cool_Top_Bar.Size = UDim2.new(1, 0, 0, 36)
    Cool_Top_Bar.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Top_Bar.BorderSizePixel = 0
    Cool_Top_Bar.Parent = Cool_Main_Bg
    
    local Top_Corner = Instance.new("UICorner")
    Top_Corner.CornerRadius = UDim.new(0, 6)
    Top_Corner.Parent = Cool_Top_Bar

    local Cool_Top_Hider = Instance.new("Frame")
    Cool_Top_Hider.Size = UDim2.new(1, 0, 0, 6)
    Cool_Top_Hider.Position = UDim2.new(0, 0, 1, -6)
    Cool_Top_Hider.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Top_Hider.BorderSizePixel = 0
    Cool_Top_Hider.Parent = Cool_Top_Bar

    local Cool_Accent_Line = Instance.new("Frame")
    Cool_Accent_Line.Size = UDim2.new(1, 0, 0, 2)
    Cool_Accent_Line.BackgroundColor3 = Color3.new(1, 1, 1)
    Cool_Accent_Line.BorderSizePixel = 0
    Cool_Accent_Line.Parent = Cool_Top_Bar
    
    local Accent_Corner = Instance.new("UICorner")
    Accent_Corner.CornerRadius = UDim.new(0, 6)
    Accent_Corner.Parent = Cool_Accent_Line

    local Cool_Accent_Grad = Instance.new("UIGradient")
    Cool_Accent_Grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Cool_Colors.Accent_Grad_1),
        ColorSequenceKeypoint.new(1, Cool_Colors.Accent_Grad_2)
    }
    Cool_Accent_Grad.Parent = Cool_Accent_Line

    local Cool_Top_Border = Instance.new("Frame")
    Cool_Top_Border.Size = UDim2.new(1, 0, 0, 1)
    Cool_Top_Border.Position = UDim2.new(0, 0, 1, 0)
    Cool_Top_Border.BackgroundColor3 = Cool_Colors.Border
    Cool_Top_Border.BorderSizePixel = 0
    Cool_Top_Border.Parent = Cool_Top_Bar

    local Cool_Title = Instance.new("TextLabel")
    Cool_Title.Size = UDim2.new(1, -20, 1, -2)
    Cool_Title.Position = UDim2.new(0, 15, 0, 2)
    Cool_Title.BackgroundTransparency = 1
    Cool_Title.Text = Window_Name
    Cool_Title.TextColor3 = Cool_Colors.Text_White
    Cool_Title.TextSize = 13
    Cool_Title.Font = Cool_Bold_Font
    Cool_Title.TextXAlignment = Enum.TextXAlignment.Left
    Cool_Title.Parent = Cool_Top_Bar

    local Cool_Sidebar = Instance.new("Frame")
    Cool_Sidebar.Size = UDim2.new(0, 150, 1, -37)
    Cool_Sidebar.Position = UDim2.new(0, 0, 0, 37)
    Cool_Sidebar.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Sidebar.BorderSizePixel = 0
    Cool_Sidebar.Parent = Cool_Main_Bg
    
    local Sidebar_Corner = Instance.new("UICorner")
    Sidebar_Corner.CornerRadius = UDim.new(0, 6)
    Sidebar_Corner.Parent = Cool_Sidebar

    local Cool_Sidebar_Hider_R = Instance.new("Frame")
    Cool_Sidebar_Hider_R.Size = UDim2.new(0, 6, 1, 0)
    Cool_Sidebar_Hider_R.Position = UDim2.new(1, -6, 0, 0)
    Cool_Sidebar_Hider_R.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Sidebar_Hider_R.BorderSizePixel = 0
    Cool_Sidebar_Hider_R.Parent = Cool_Sidebar

    local Cool_Sidebar_Hider_T = Instance.new("Frame")
    Cool_Sidebar_Hider_T.Size = UDim2.new(1, 0, 0, 6)
    Cool_Sidebar_Hider_T.BackgroundColor3 = Cool_Colors.Sidebar_Bg
    Cool_Sidebar_Hider_T.BorderSizePixel = 0
    Cool_Sidebar_Hider_T.Parent = Cool_Sidebar

    local Cool_Sidebar_Border = Instance.new("Frame")
    Cool_Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
    Cool_Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
    Cool_Sidebar_Border.BackgroundColor3 = Cool_Colors.Border
    Cool_Sidebar_Border.BorderSizePixel = 0
    Cool_Sidebar_Border.Parent = Cool_Sidebar

    local Cool_Tab_Scroll = Instance.new("ScrollingFrame")
    Cool_Tab_Scroll.Size = UDim2.new(1, -10, 1, -10)
    Cool_Tab_Scroll.Position = UDim2.new(0, 5, 0, 5)
    Cool_Tab_Scroll.BackgroundTransparency = 1
    Cool_Tab_Scroll.BorderSizePixel = 0
    Cool_Tab_Scroll.ScrollBarThickness = 0
    Cool_Tab_Scroll.Parent = Cool_Sidebar

    local Cool_Tab_Layout = Instance.new("UIListLayout")
    Cool_Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Cool_Tab_Layout.Padding = UDim.new(0, 4)
    Cool_Tab_Layout.Parent = Cool_Tab_Scroll

    local Cool_Content_Area = Instance.new("Frame")
    Cool_Content_Area.Size = UDim2.new(1, -151, 1, -37)
    Cool_Content_Area.Position = UDim2.new(0, 151, 0, 37)
    Cool_Content_Area.BackgroundTransparency = 1
    Cool_Content_Area.Parent = Cool_Main_Bg

    local Dragging = false
    local Drag_Input = nil
    local Drag_Start = nil
    local Start_Pos = nil
    local Target_Pos = Cool_Main_Bg.Position

    Cool_Top_Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Drag_Start = Input.Position
            Start_Pos = Cool_Main_Bg.Position
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
            end)
        end
    end)

    Cool_Top_Bar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then Drag_Input = Input end
    end)

    Run_Service.RenderStepped:Connect(function()
        if Dragging and Drag_Input then
            local Delta = Drag_Input.Position - Drag_Start
            Target_Pos = UDim2.new(Start_Pos.X.Scale, Start_Pos.X.Offset + Delta.X, Start_Pos.Y.Scale, Start_Pos.Y.Offset + Delta.Y)
        end
        Cool_Main_Bg.Position = Cool_Main_Bg.Position:Lerp(Target_Pos, 0.18)
    end)

    local Cool_Window_Context = { Tabs = {}, Active_Tab = nil }

    function Cool_Window_Context:Cool_Tab_Create(Tab_Name)
        local Cool_Tab_Data = {}

        local Cool_Tab_Btn = Instance.new("TextButton")
        Cool_Tab_Btn.Size = UDim2.new(1, 0, 0, 32)
        Cool_Tab_Btn.BackgroundColor3 = Cool_Colors.Element_Hover
        Cool_Tab_Btn.BackgroundTransparency = 1
        Cool_Tab_Btn.Text = ""
        Cool_Tab_Btn.AutoButtonColor = false
        Cool_Tab_Btn.Parent = Cool_Tab_Scroll
        
        local Btn_Corner = Instance.new("UICorner")
        Btn_Corner.CornerRadius = UDim.new(0, 4)
        Btn_Corner.Parent = Cool_Tab_Btn

        local Cool_Tab_Label = Instance.new("TextLabel")
        Cool_Tab_Label.Size = UDim2.new(1, -20, 1, 0)
        Cool_Tab_Label.Position = UDim2.new(0, 12, 0, 0)
        Cool_Tab_Label.BackgroundTransparency = 1
        Cool_Tab_Label.Text = Tab_Name
        Cool_Tab_Label.TextColor3 = Cool_Colors.Text_Dark
        Cool_Tab_Label.TextSize = 12
        Cool_Tab_Label.Font = Cool_Font
        Cool_Tab_Label.TextXAlignment = Enum.TextXAlignment.Left
        Cool_Tab_Label.Parent = Cool_Tab_Btn

        local Cool_Tab_Ind = Instance.new("Frame")
        Cool_Tab_Ind.Size = UDim2.new(0, 2, 0, 0)
        Cool_Tab_Ind.Position = UDim2.new(0, 0, 0.5, 0)
        Cool_Tab_Ind.BackgroundColor3 = Cool_Colors.Accent
        Cool_Tab_Ind.BorderSizePixel = 0
        Cool_Tab_Ind.Parent = Cool_Tab_Btn
        
        local Ind_Corner = Instance.new("UICorner")
        Ind_Corner.CornerRadius = UDim.new(0, 2)
        Ind_Corner.Parent = Cool_Tab_Ind

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
        Cool_Left_Col.Position = UDim2.new(0, 10, 0, 10)
        Cool_Left_Col.BackgroundTransparency = 1
        Cool_Left_Col.Parent = Cool_Page

        local Cool_Right_Col = Instance.new("Frame")
        Cool_Right_Col.Size = UDim2.new(0.5, -16, 1, 0)
        Cool_Right_Col.Position = UDim2.new(0.5, 6, 0, 10)
        Cool_Right_Col.BackgroundTransparency = 1
        Cool_Right_Col.Parent = Cool_Page

        local Cool_Left_Layout = Instance.new("UIListLayout")
        Cool_Left_Layout.Padding = UDim.new(0, 10)
        Cool_Left_Layout.Parent = Cool_Left_Col

        local Cool_Right_Layout = Instance.new("UIListLayout")
        Cool_Right_Layout.Padding = UDim.new(0, 10)
        Cool_Right_Layout.Parent = Cool_Right_Col

        Run_Service.RenderStepped:Connect(function()
            local Max_Y = math.max(Cool_Left_Layout.AbsoluteContentSize.Y, Cool_Right_Layout.AbsoluteContentSize.Y)
            Cool_Page.CanvasSize = UDim2.new(0, 0, 0, Max_Y + 20)
            Cool_Tab_Scroll.CanvasSize = UDim2.new(0, 0, 0, Cool_Tab_Layout.AbsoluteContentSize.Y + 10)
        end)

        function Cool_Tab_Data:Activate()
            if Cool_Window_Context.Active_Tab == Cool_Tab_Data then return end
            if Cool_Window_Context.Active_Tab then
                Cool_Animate(Cool_Window_Context.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.2)
                Cool_Animate(Cool_Window_Context.Active_Tab.Lbl, {TextColor3 = Cool_Colors.Text_Dark}, 0.2)
                Cool_Animate(Cool_Window_Context.Active_Tab.Ind, {Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.2)
                Cool_Window_Context.Active_Tab.Page.Visible = false
            end
            Cool_Window_Context.Active_Tab = Cool_Tab_Data
            Cool_Page.Visible = true
            Cool_Animate(Cool_Tab_Btn, {BackgroundTransparency = 0}, 0.2)
            Cool_Animate(Cool_Tab_Label, {TextColor3 = Cool_Colors.Text_White}, 0.2)
            Cool_Animate(Cool_Tab_Ind, {Size = UDim2.new(0, 2, 0, 16), Position = UDim2.new(0, 0, 0.5, -8)}, 0.2)
        end

        Cool_Tab_Btn.MouseButton1Click:Connect(function() Cool_Tab_Data:Activate() end)

        Cool_Tab_Data.Btn = Cool_Tab_Btn
        Cool_Tab_Data.Lbl = Cool_Tab_Label
        Cool_Tab_Data.Ind = Cool_Tab_Ind
        Cool_Tab_Data.Page = Cool_Page

        table.insert(Cool_Window_Context.Tabs, Cool_Tab_Data)
        if #Cool_Window_Context.Tabs == 1 then Cool_Tab_Data:Activate() end

        local function Cool_Element_Injector(Target_Container)
            local Cool_Elements = {}

            function Cool_Elements:Cool_Toggle_Create(Name, Flag, Default, Tooltip, Callback)
                Nixware_Premium_Api.Cool_Flags[Flag] = Default or false

                local Cool_Tog_Btn = Instance.new("TextButton")
                Cool_Tog_Btn.Size = UDim2.new(1, 0, 0, 16)
                Cool_Tog_Btn.BackgroundTransparency = 1
                Cool_Tog_Btn.Text = ""
                Cool_Tog_Btn.Parent = Target_Container

                local Cool_Box = Instance.new("Frame")
                Cool_Box.Size = UDim2.new(0, 14, 0, 14)
                Cool_Box.Position = UDim2.new(0, 2, 0.5, -7)
                Cool_Box.BackgroundColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Accent or Cool_Colors.Element_Bg
                Cool_Box.Parent = Cool_Tog_Btn
                
                local Box_Corner = Instance.new("UICorner")
                Box_Corner.CornerRadius = UDim.new(0, 3)
                Box_Corner.Parent = Cool_Box
                
                local Box_Stroke = Instance.new("UIStroke")
                Box_Stroke.Color = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Accent or Cool_Colors.Border
                Box_Stroke.Parent = Cool_Box

                local Cool_Text = Instance.new("TextLabel")
                Cool_Text.Size = UDim2.new(1, -26, 1, 0)
                Cool_Text.Position = UDim2.new(0, 24, 0, 0)
                Cool_Text.BackgroundTransparency = 1
                Cool_Text.Text = Name
                Cool_Text.TextColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                Cool_Text.TextSize = 12
                Cool_Text.Font = Cool_Font
                Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Text.Parent = Cool_Tog_Btn

                Cool_Tog_Btn.MouseEnter:Connect(function()
                    Cool_Show_Tooltip(Tooltip)
                    if not Nixware_Premium_Api.Cool_Flags[Flag] then Cool_Animate(Box_Stroke, {Color = Cool_Colors.Border_Light}, 0.2) end
                end)
                Cool_Tog_Btn.MouseLeave:Connect(function()
                    Cool_Show_Tooltip("")
                    if not Nixware_Premium_Api.Cool_Flags[Flag] then Cool_Animate(Box_Stroke, {Color = Cool_Colors.Border}, 0.2) end
                end)

                Cool_Tog_Btn.MouseButton1Click:Connect(function()
                    Nixware_Premium_Api.Cool_Flags[Flag] = not Nixware_Premium_Api.Cool_Flags[Flag]
                    local S = Nixware_Premium_Api.Cool_Flags[Flag]
                    Cool_Animate(Cool_Box, {BackgroundColor3 = S and Cool_Colors.Accent or Cool_Colors.Element_Bg}, 0.2)
                    Cool_Animate(Box_Stroke, {Color = S and Cool_Colors.Accent or Cool_Colors.Border}, 0.2)
                    Cool_Animate(Cool_Text, {TextColor3 = S and Cool_Colors.Text_White or Cool_Colors.Text_Dark}, 0.2)
                    if Callback then task.spawn(Callback, S) end
                end)
            end

            function Cool_Elements:Cool_Slider_Create(Name, Flag, Min, Max, Default, Tooltip, Callback)
                Nixware_Premium_Api.Cool_Flags[Flag] = Default or Min

                local Cool_Sld_Frame = Instance.new("Frame")
                Cool_Sld_Frame.Size = UDim2.new(1, 0, 0, 36)
                Cool_Sld_Frame.BackgroundTransparency = 1
                Cool_Sld_Frame.Parent = Target_Container

                local Cool_Text = Instance.new("TextLabel")
                Cool_Text.Size = UDim2.new(1, -10, 0, 14)
                Cool_Text.Position = UDim2.new(0, 2, 0, 0)
                Cool_Text.BackgroundTransparency = 1
                Cool_Text.Text = Name
                Cool_Text.TextColor3 = Cool_Colors.Text_White
                Cool_Text.TextSize = 12
                Cool_Text.Font = Cool_Font
                Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Text.Parent = Cool_Sld_Frame

                local Cool_Val = Instance.new("TextLabel")
                Cool_Val.Size = UDim2.new(1, -10, 0, 14)
                Cool_Val.Position = UDim2.new(0, 0, 0, 0)
                Cool_Val.BackgroundTransparency = 1
                Cool_Val.Text = tostring(Nixware_Premium_Api.Cool_Flags[Flag])
                Cool_Val.TextColor3 = Cool_Colors.Text_White
                Cool_Val.TextSize = 12
                Cool_Val.Font = Cool_Font
                Cool_Val.TextXAlignment = Enum.TextXAlignment.Right
                Cool_Val.Parent = Cool_Sld_Frame

                local Cool_Bg = Instance.new("TextButton")
                Cool_Bg.Size = UDim2.new(1, -4, 0, 6)
                Cool_Bg.Position = UDim2.new(0, 2, 0, 24)
                Cool_Bg.BackgroundColor3 = Cool_Colors.Element_Bg
                Cool_Bg.Text = ""
                Cool_Bg.AutoButtonColor = false
                Cool_Bg.Parent = Cool_Sld_Frame
                
                local Bg_Corner = Instance.new("UICorner")
                Bg_Corner.CornerRadius = UDim.new(0, 3)
                Bg_Corner.Parent = Cool_Bg
                
                local Bg_Stroke = Instance.new("UIStroke")
                Bg_Stroke.Color = Cool_Colors.Border
                Bg_Stroke.Parent = Cool_Bg

                local Cool_Fill = Instance.new("Frame")
                Cool_Fill.Size = UDim2.new((Nixware_Premium_Api.Cool_Flags[Flag] - Min) / (Max - Min), 0, 1, 0)
                Cool_Fill.BackgroundColor3 = Cool_Colors.Accent
                Cool_Fill.Parent = Cool_Bg
                
                local Fill_Corner = Instance.new("UICorner")
                Fill_Corner.CornerRadius = UDim.new(0, 3)
                Fill_Corner.Parent = Cool_Fill

                Cool_Bg.MouseEnter:Connect(function()
                    Cool_Show_Tooltip(Tooltip)
                    Cool_Animate(Bg_Stroke, {Color = Cool_Colors.Border_Light}, 0.2)
                end)
                Cool_Bg.MouseLeave:Connect(function()
                    Cool_Show_Tooltip("")
                    Cool_Animate(Bg_Stroke, {Color = Cool_Colors.Border}, 0.2)
                end)

                local Sliding = false
                local function Update_Value(Input)
                    local Pct = math.clamp((Input.Position.X - Cool_Bg.AbsolutePosition.X) / Cool_Bg.AbsoluteSize.X, 0, 1)
                    local Val = math.floor(Min + ((Max - Min) * Pct))
                    Nixware_Premium_Api.Cool_Flags[Flag] = Val
                    Cool_Animate(Cool_Fill, {Size = UDim2.new(Pct, 0, 1, 0)}, 0.05)
                    Cool_Val.Text = tostring(Val)
                    if Callback then task.spawn(Callback, Val) end
                end

                Cool_Bg.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Sliding = true
                        Update_Value(Input)
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if Sliding and Input.UserInputType == Enum.UserInputType.MouseMovement then Update_Value(Input) end
                end)
            end

            function Cool_Elements:Cool_Dropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
                Nixware_Premium_Api.Cool_Flags[Flag] = Default or Options[1]
                local Open = false

                local Cool_Drop_Frame = Instance.new("Frame")
                Cool_Drop_Frame.Size = UDim2.new(1, 0, 0, 46)
                Cool_Drop_Frame.BackgroundTransparency = 1
                Cool_Drop_Frame.Parent = Target_Container

                local Cool_Text = Instance.new("TextLabel")
                Cool_Text.Size = UDim2.new(1, -10, 0, 14)
                Cool_Text.Position = UDim2.new(0, 2, 0, 0)
                Cool_Text.BackgroundTransparency = 1
                Cool_Text.Text = Name
                Cool_Text.TextColor3 = Cool_Colors.Text_White
                Cool_Text.TextSize = 12
                Cool_Text.Font = Cool_Font
                Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Text.Parent = Cool_Drop_Frame

                local Cool_Main_Btn = Instance.new("TextButton")
                Cool_Main_Btn.Size = UDim2.new(1, -4, 0, 24)
                Cool_Main_Btn.Position = UDim2.new(0, 2, 0, 20)
                Cool_Main_Btn.BackgroundColor3 = Cool_Colors.Element_Bg
                Cool_Main_Btn.Text = ""
                Cool_Main_Btn.AutoButtonColor = false
                Cool_Main_Btn.Parent = Cool_Drop_Frame
                
                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 4)
                Btn_Corner.Parent = Cool_Main_Btn
                
                local Main_Stroke = Instance.new("UIStroke")
                Main_Stroke.Color = Cool_Colors.Border
                Main_Stroke.Parent = Cool_Main_Btn

                local Cool_Selected = Instance.new("TextLabel")
                Cool_Selected.Size = UDim2.new(1, -20, 1, 0)
                Cool_Selected.Position = UDim2.new(0, 8, 0, 0)
                Cool_Selected.BackgroundTransparency = 1
                Cool_Selected.Text = Nixware_Premium_Api.Cool_Flags[Flag]
                Cool_Selected.TextColor3 = Cool_Colors.Text_Dark
                Cool_Selected.TextSize = 12
                Cool_Selected.Font = Cool_Font
                Cool_Selected.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Selected.Parent = Cool_Main_Btn

                local Cool_List = Instance.new("Frame")
                Cool_List.Size = UDim2.new(1, -4, 0, 0)
                Cool_List.Position = UDim2.new(0, 2, 0, 48)
                Cool_List.BackgroundColor3 = Cool_Colors.Element_Bg
                Cool_List.ClipsDescendants = true
                Cool_List.ZIndex = 5
                Cool_List.Parent = Cool_Drop_Frame
                
                local List_Corner = Instance.new("UICorner")
                List_Corner.CornerRadius = UDim.new(0, 4)
                List_Corner.Parent = Cool_List
                
                local List_Stroke = Instance.new("UIStroke")
                List_Stroke.Color = Cool_Colors.Border
                List_Stroke.Transparency = 1
                List_Stroke.Parent = Cool_List

                local Cool_List_Layout = Instance.new("UIListLayout")
                Cool_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Cool_List_Layout.Parent = Cool_List

                local function Toggle()
                    Open = not Open
                    local Target_Size = Open and (#Options * 24) or 0
                    Cool_Animate(Main_Stroke, {Color = Open and Cool_Colors.Accent or Cool_Colors.Border}, 0.2)
                    Cool_Animate(Cool_List, {Size = UDim2.new(1, -4, 0, Target_Size)}, 0.2)
                    Cool_Animate(List_Stroke, {Transparency = Open and 0 or 1}, 0.2)
                    Cool_Animate(Cool_Drop_Frame, {Size = UDim2.new(1, 0, 0, 46 + Target_Size + (Open and 6 or 0))}, 0.2)
                end

                Cool_Main_Btn.MouseEnter:Connect(function()
                    Cool_Show_Tooltip(Tooltip)
                    if not Open then Cool_Animate(Main_Stroke, {Color = Cool_Colors.Border_Light}, 0.2) end
                end)
                Cool_Main_Btn.MouseLeave:Connect(function()
                    Cool_Show_Tooltip("")
                    if not Open then Cool_Animate(Main_Stroke, {Color = Cool_Colors.Border}, 0.2) end
                end)
                Cool_Main_Btn.MouseButton1Click:Connect(Toggle)

                for _, Opt in ipairs(Options) do
                    local Cool_Opt_Btn = Instance.new("TextButton")
                    Cool_Opt_Btn.Size = UDim2.new(1, 0, 0, 24)
                    Cool_Opt_Btn.BackgroundTransparency = 1
                    Cool_Opt_Btn.Text = ""
                    Cool_Opt_Btn.ZIndex = 6
                    Cool_Opt_Btn.Parent = Cool_List

                    local Cool_Opt_Text = Instance.new("TextLabel")
                    Cool_Opt_Text.Size = UDim2.new(1, -20, 1, 0)
                    Cool_Opt_Text.Position = UDim2.new(0, 8, 0, 0)
                    Cool_Opt_Text.BackgroundTransparency = 1
                    Cool_Opt_Text.Text = Opt
                    Cool_Opt_Text.TextColor3 = Cool_Colors.Text_Dark
                    Cool_Opt_Text.TextSize = 12
                    Cool_Opt_Text.Font = Cool_Font
                    Cool_Opt_Text.TextXAlignment = Enum.TextXAlignment.Left
                    Cool_Opt_Text.ZIndex = 6
                    Cool_Opt_Text.Parent = Cool_Opt_Btn

                    Cool_Opt_Btn.MouseEnter:Connect(function() Cool_Animate(Cool_Opt_Text, {TextColor3 = Cool_Colors.Accent}, 0.15) end)
                    Cool_Opt_Btn.MouseLeave:Connect(function()
                        if Nixware_Premium_Api.Cool_Flags[Flag] ~= Opt then
                            Cool_Animate(Cool_Opt_Text, {TextColor3 = Cool_Colors.Text_Dark}, 0.15)
                        else
                            Cool_Animate(Cool_Opt_Text, {TextColor3 = Cool_Colors.Text_White}, 0.15)
                        end
                    end)

                    Cool_Opt_Btn.MouseButton1Click:Connect(function()
                        Nixware_Premium_Api.Cool_Flags[Flag] = Opt
                        Cool_Selected.Text = Opt
                        Toggle()
                        for _, Child in ipairs(Cool_List:GetChildren()) do
                            if Child:IsA("TextButton") then
                                Child:FindFirstChildOfClass("TextLabel").TextColor3 = Cool_Colors.Text_Dark
                            end
                        end
                        Cool_Opt_Text.TextColor3 = Cool_Colors.Text_White
                        if Callback then task.spawn(Callback, Opt) end
                    end)
                end
            end

            function Cool_Elements:Cool_ColorPicker_Create(Name, Flag, Default, Tooltip, Callback)
                Nixware_Premium_Api.Cool_Flags[Flag] = Default or Color3.fromRGB(255, 255, 255)
                local Open = false
                local H, S, V = Nixware_Premium_Api.Cool_Flags[Flag]:ToHSV()

                local Cool_Col_Frame = Instance.new("Frame")
                Cool_Col_Frame.Size = UDim2.new(1, 0, 0, 24)
                Cool_Col_Frame.BackgroundTransparency = 1
                Cool_Col_Frame.ClipsDescendants = true
                Cool_Col_Frame.Parent = Target_Container

                local Cool_Text = Instance.new("TextLabel")
                Cool_Text.Size = UDim2.new(1, -40, 0, 24)
                Cool_Text.Position = UDim2.new(0, 2, 0, 0)
                Cool_Text.BackgroundTransparency = 1
                Cool_Text.Text = Name
                Cool_Text.TextColor3 = Cool_Colors.Text_White
                Cool_Text.TextSize = 12
                Cool_Text.Font = Cool_Font
                Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Text.Parent = Cool_Col_Frame

                local Cool_Prev_Btn = Instance.new("TextButton")
                Cool_Prev_Btn.Size = UDim2.new(0, 24, 0, 14)
                Cool_Prev_Btn.Position = UDim2.new(1, -28, 0, 5)
                Cool_Prev_Btn.BackgroundColor3 = Nixware_Premium_Api.Cool_Flags[Flag]
                Cool_Prev_Btn.Text = ""
                Cool_Prev_Btn.AutoButtonColor = false
                Cool_Prev_Btn.Parent = Cool_Col_Frame
                
                local Prev_Corner = Instance.new("UICorner")
                Prev_Corner.CornerRadius = UDim.new(0, 3)
                Prev_Corner.Parent = Cool_Prev_Btn
                
                local Prev_Stroke = Instance.new("UIStroke")
                Prev_Stroke.Color = Cool_Colors.Border
                Prev_Stroke.Parent = Cool_Prev_Btn

                local Cool_Expand = Instance.new("Frame")
                Cool_Expand.Size = UDim2.new(1, -4, 0, 190)
                Cool_Expand.Position = UDim2.new(0, 2, 0, 28)
                Cool_Expand.BackgroundColor3 = Cool_Colors.Element_Bg
                Cool_Expand.Parent = Cool_Col_Frame
                
                local Expand_Corner = Instance.new("UICorner")
                Expand_Corner.CornerRadius = UDim.new(0, 4)
                Expand_Corner.Parent = Cool_Expand
                
                local Expand_Stroke = Instance.new("UIStroke")
                Expand_Stroke.Color = Cool_Colors.Border
                Expand_Stroke.Parent = Cool_Expand

                local SV_Map = Instance.new("ImageButton")
                SV_Map.Size = UDim2.new(1, -16, 0, 150)
                SV_Map.Position = UDim2.new(0, 8, 0, 8)
                SV_Map.Image = "rbxassetid://4155801252"
                SV_Map.ImageColor3 = Color3.fromHSV(H, 1, 1)
                SV_Map.AutoButtonColor = false
                SV_Map.Parent = Cool_Expand
                local SV_Corner = Instance.new("UICorner"); SV_Corner.CornerRadius = UDim.new(0, 3); SV_Corner.Parent = SV_Map
                local SV_Stroke = Instance.new("UIStroke"); SV_Stroke.Color = Cool_Colors.Border; SV_Stroke.Parent = SV_Map

                local SV_Cursor = Instance.new("Frame")
                SV_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SV_Cursor.Size = UDim2.new(0, 6, 0, 6)
                SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                SV_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SV_Cursor.Parent = SV_Map
                local Curs_Corner = Instance.new("UICorner"); Curs_Corner.CornerRadius = UDim.new(1, 0); Curs_Corner.Parent = SV_Cursor
                local Curs_Stroke = Instance.new("UIStroke"); Curs_Stroke.Color = Color3.new(0, 0, 0); Curs_Stroke.Parent = SV_Cursor

                local Hue_Map = Instance.new("TextButton")
                Hue_Map.Size = UDim2.new(1, -16, 0, 12)
                Hue_Map.Position = UDim2.new(0, 8, 0, 168)
                Hue_Map.Text = ""
                Hue_Map.AutoButtonColor = false
                Hue_Map.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Map.Parent = Cool_Expand
                local Hue_Corner = Instance.new("UICorner"); Hue_Corner.CornerRadius = UDim.new(0, 3); Hue_Corner.Parent = Hue_Map
                local Hue_Stroke = Instance.new("UIStroke"); Hue_Stroke.Color = Cool_Colors.Border; Hue_Stroke.Parent = Hue_Map

                local Hue_Grad = Instance.new("UIGradient")
                Hue_Grad.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }
                Hue_Grad.Parent = Hue_Map

                local Hue_Cursor = Instance.new("Frame")
                Hue_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                Hue_Cursor.Size = UDim2.new(0, 4, 1, 4)
                Hue_Cursor.Position = UDim2.new(H, 0, 0.5, 0)
                Hue_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Cursor.Parent = Hue_Map
                local HC_Corner = Instance.new("UICorner"); HC_Corner.CornerRadius = UDim.new(0, 2); HC_Corner.Parent = Hue_Cursor
                local HC_Stroke = Instance.new("UIStroke"); HC_Stroke.Color = Color3.new(0, 0, 0); HC_Stroke.Parent = Hue_Cursor

                local function UpdateColor()
                    local Col = Color3.fromHSV(H, S, V)
                    Nixware_Premium_Api.Cool_Flags[Flag] = Col
                    SV_Map.ImageColor3 = Color3.fromHSV(H, 1, 1)
                    Cool_Prev_Btn.BackgroundColor3 = Col
                    SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    Hue_Cursor.Position = UDim2.new(H, 0, 0.5, 0)
                    if Callback then task.spawn(Callback, Col) end
                end

                local SV_Sliding = false
                SV_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then SV_Sliding = true end
                end)
                
                local Hue_Sliding = false
                Hue_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Hue_Sliding = true end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SV_Sliding = false
                        Hue_Sliding = false
                    end
                end)

                Run_Service.RenderStepped:Connect(function()
                    if SV_Sliding then
                        local Mouse = User_Input_Service:GetMouseLocation()
                        S = math.clamp((Mouse.X - SV_Map.AbsolutePosition.X) / SV_Map.AbsoluteSize.X, 0, 1)
                        V = 1 - math.clamp((Mouse.Y - SV_Map.AbsolutePosition.Y) / SV_Map.AbsoluteSize.Y, 0, 1)
                        UpdateColor()
                    end
                    if Hue_Sliding then
                        local Mouse = User_Input_Service:GetMouseLocation()
                        H = math.clamp((Mouse.X - Hue_Map.AbsolutePosition.X) / Hue_Map.AbsoluteSize.X, 0, 1)
                        UpdateColor()
                    end
                end)

                Cool_Prev_Btn.MouseEnter:Connect(function()
                    Cool_Show_Tooltip(Tooltip)
                    if not Open then Cool_Animate(Prev_Stroke, {Color = Cool_Colors.Border_Light}, 0.2) end
                end)
                Cool_Prev_Btn.MouseLeave:Connect(function()
                    Cool_Show_Tooltip("")
                    if not Open then Cool_Animate(Prev_Stroke, {Color = Cool_Colors.Border}, 0.2) end
                end)

                Cool_Prev_Btn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Cool_Animate(Prev_Stroke, {Color = Open and Cool_Colors.Accent or Cool_Colors.Border}, 0.2)
                    Cool_Animate(Cool_Col_Frame, {Size = UDim2.new(1, 0, 0, Open and 224 or 24)}, 0.25)
                end)
            end

            function Cool_Elements:Cool_Button_Create(Name, Tooltip, Callback)
                local Cool_Btn_Frame = Instance.new("Frame")
                Cool_Btn_Frame.Size = UDim2.new(1, 0, 0, 28)
                Cool_Btn_Frame.BackgroundTransparency = 1
                Cool_Btn_Frame.Parent = Target_Container

                local Cool_Btn = Instance.new("TextButton")
                Cool_Btn.Size = UDim2.new(1, -4, 1, 0)
                Cool_Btn.Position = UDim2.new(0, 2, 0, 0)
                Cool_Btn.BackgroundColor3 = Cool_Colors.Element_Bg
                Cool_Btn.Text = Name
                Cool_Btn.TextColor3 = Cool_Colors.Text_White
                Cool_Btn.TextSize = 12
                Cool_Btn.Font = Cool_Bold_Font
                Cool_Btn.AutoButtonColor = false
                Cool_Btn.Parent = Cool_Btn_Frame
                
                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 4)
                Btn_Corner.Parent = Cool_Btn
                
                local Btn_Stroke = Instance.new("UIStroke")
                Btn_Stroke.Color = Cool_Colors.Border
                Btn_Stroke.Parent = Cool_Btn

                Cool_Btn.MouseEnter:Connect(function()
                    Cool_Show_Tooltip(Tooltip)
                    Cool_Animate(Cool_Btn, {BackgroundColor3 = Cool_Colors.Element_Hover}, 0.2)
                    Cool_Animate(Btn_Stroke, {Color = Cool_Colors.Accent}, 0.2)
                end)
                Cool_Btn.MouseLeave:Connect(function()
                    Cool_Show_Tooltip("")
                    Cool_Animate(Cool_Btn, {BackgroundColor3 = Cool_Colors.Element_Bg}, 0.2)
                    Cool_Animate(Btn_Stroke, {Color = Cool_Colors.Border}, 0.2)
                end)
                Cool_Btn.MouseButton1Down:Connect(function() Cool_Animate(Cool_Btn, {Size = UDim2.new(0.96, 0, 0.9, 0), Position = UDim2.new(0.02, 0, 0.05, 0)}, 0.1) end)
                Cool_Btn.MouseButton1Up:Connect(function()
                    Cool_Animate(Cool_Btn, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.1)
                    if Callback then task.spawn(Callback) end
                end)
            end

            function Cool_Elements:Cool_Module_Create(Name, Flag, Desc, Default, Tooltip, Callback)
                Nixware_Premium_Api.Cool_Flags[Flag] = Default or false

                local Cool_Mod_Frame = Instance.new("Frame")
                Cool_Mod_Frame.Size = UDim2.new(1, 0, 0, 46)
                Cool_Mod_Frame.BackgroundTransparency = 1
                Cool_Mod_Frame.ClipsDescendants = true
                Cool_Mod_Frame.Parent = Target_Container

                local Cool_Mod_Btn = Instance.new("TextButton")
                Cool_Mod_Btn.Size = UDim2.new(1, -4, 0, 44)
                Cool_Mod_Btn.Position = UDim2.new(0, 2, 0, 0)
                Cool_Mod_Btn.BackgroundColor3 = Cool_Colors.Element_Bg
                Cool_Mod_Btn.Text = ""
                Cool_Mod_Btn.AutoButtonColor = false
                Cool_Mod_Btn.Parent = Cool_Mod_Frame
                
                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 6)
                Btn_Corner.Parent = Cool_Mod_Btn
                
                local Btn_Stroke = Instance.new("UIStroke")
                Btn_Stroke.Color = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Accent or Cool_Colors.Border
                Btn_Stroke.Parent = Cool_Mod_Btn

                local Cool_Box = Instance.new("Frame")
                Cool_Box.Size = UDim2.new(0, 16, 0, 16)
                Cool_Box.Position = UDim2.new(0, 14, 0.5, -8)
                Cool_Box.BackgroundColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Accent or Cool_Colors.Section_Bg
                Cool_Box.Parent = Cool_Mod_Btn
                
                local Box_Corner = Instance.new("UICorner")
                Box_Corner.CornerRadius = UDim.new(0, 4)
                Box_Corner.Parent = Cool_Box
                
                local Box_Stroke = Instance.new("UIStroke")
                Box_Stroke.Color = Cool_Colors.Border
                Box_Stroke.Parent = Cool_Box

                local Cool_Text = Instance.new("TextLabel")
                Cool_Text.Size = UDim2.new(1, -45, 0, 16)
                Cool_Text.Position = UDim2.new(0, 40, 0, 6)
                Cool_Text.BackgroundTransparency = 1
                Cool_Text.Text = Name
                Cool_Text.TextColor3 = Nixware_Premium_Api.Cool_Flags[Flag] and Cool_Colors.Text_White or Cool_Colors.Text_Dark
                Cool_Text.TextSize = 13
                Cool_Text.Font = Cool_Bold_Font
                Cool_Text.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Text.Parent = Cool_Mod_Btn

                local Cool_Desc = Instance.new("TextLabel")
                Cool_Desc.Size = UDim2.new(1, -45, 0, 14)
                Cool_Desc.Position = UDim2.new(0, 40, 0, 22)
                Cool_Desc.BackgroundTransparency = 1
                Cool_Desc.Text = Desc
                Cool_Desc.TextColor3 = Cool_Colors.Text_Dark
                Cool_Desc.TextSize = 11
                Cool_Desc.Font = Cool_Font
                Cool_Desc.TextXAlignment = Enum.TextXAlignment.Left
                Cool_Desc.Parent = Cool_Mod_Btn

                local Cool_Mod_Content = Instance.new("Frame")
                Cool_Mod_Content.Size = UDim2.new(1, -16, 0, 0)
                Cool_Mod_Content.Position = UDim2.new(0, 12, 0, 48)
                Cool_Mod_Content.BackgroundTransparency = 1
                Cool_Mod_Content.Parent = Cool_Mod_Frame

                local Cool_Layout = Instance.new("UIListLayout")
                Cool_Layout.Padding = UDim.new(0, 8)
                Cool_Layout.Parent = Cool_Mod_Content

                local function Sync_Size()
                    if Nixware_Premium_Api.Cool_Flags[Flag] then
                        Cool_Animate(Cool_Mod_Frame, {Size = UDim2.new(1, 0, 0, 46 + Cool_Layout.AbsoluteContentSize.Y + 8)}, 0.25)
                    else
                        Cool_Animate(Cool_Mod_Frame, {Size = UDim2.new(1, 0, 0, 46)}, 0.25)
                    end
                end

                Cool_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Nixware_Premium_Api.Cool_Flags[Flag] then Sync_Size() end
                end)

                Cool_Mod_Btn.MouseEnter:Connect(function()
                    Cool_Show_Tooltip(Tooltip)
                    if not Nixware_Premium_Api.Cool_Flags[Flag] then Cool_Animate(Btn_Stroke, {Color = Cool_Colors.Border_Light}, 0.2) end
                end)
                Cool_Mod_Btn.MouseLeave:Connect(function()
                    Cool_Show_Tooltip("")
                    if not Nixware_Premium_Api.Cool_Flags[Flag] then Cool_Animate(Btn_Stroke, {Color = Cool_Colors.Border}, 0.2) end
                end)

                Cool_Mod_Btn.MouseButton1Click:Connect(function()
                    Nixware_Premium_Api.Cool_Flags[Flag] = not Nixware_Premium_Api.Cool_Flags[Flag]
                    local S = Nixware_Premium_Api.Cool_Flags[Flag]
                    Cool_Animate(Cool_Box, {BackgroundColor3 = S and Cool_Colors.Accent or Cool_Colors.Section_Bg}, 0.2)
                    Cool_Animate(Btn_Stroke, {Color = S and Cool_Colors.Accent or Cool_Colors.Border}, 0.2)
                    Cool_Animate(Cool_Text, {TextColor3 = S and Cool_Colors.Text_White or Cool_Colors.Text_Dark}, 0.2)
                    Sync_Size()
                    if Callback then task.spawn(Callback, S) end
                end)

                return Cool_Element_Injector(Cool_Mod_Content)
            end

            return Cool_Elements
        end

        local Cool_Section_Api = {}

        function Cool_Section_Api:Cool_Section_Create(Side_Str, Section_Title_Str)
            local Cool_Sect_Bg = Instance.new("Frame")
            Cool_Sect_Bg.Size = UDim2.new(1, 0, 0, 40)
            Cool_Sect_Bg.BackgroundColor3 = Cool_Colors.Section_Bg
            Cool_Sect_Bg.Parent = (Side_Str == "Left") and Cool_Left_Col or Cool_Right_Col
            
            local Sect_Corner = Instance.new("UICorner")
            Sect_Corner.CornerRadius = UDim.new(0, 6)
            Sect_Corner.Parent = Cool_Sect_Bg
            
            local Sect_Stroke = Instance.new("UIStroke")
            Sect_Stroke.Color = Cool_Colors.Border
            Sect_Stroke.Parent = Cool_Sect_Bg

            local Cool_Sect_Header = Instance.new("Frame")
            Cool_Sect_Header.Size = UDim2.new(1, 0, 0, 26)
            Cool_Sect_Header.BackgroundTransparency = 1
            Cool_Sect_Header.Parent = Cool_Sect_Bg

            local Cool_Sect_Label = Instance.new("TextLabel")
            Cool_Sect_Label.Size = UDim2.new(1, -20, 1, 0)
            Cool_Sect_Label.Position = UDim2.new(0, 10, 0, 0)
            Cool_Sect_Label.BackgroundTransparency = 1
            Cool_Sect_Label.Text = Section_Title_Str
            Cool_Sect_Label.TextColor3 = Cool_Colors.Text_White
            Cool_Sect_Label.TextSize = 12
            Cool_Sect_Label.Font = Cool_Bold_Font
            Cool_Sect_Label.TextXAlignment = Enum.TextXAlignment.Left
            Cool_Sect_Label.Parent = Cool_Sect_Header

            local Cool_Sect_Line = Instance.new("Frame")
            Cool_Sect_Line.Size = UDim2.new(1, -20, 0, 1)
            Cool_Sect_Line.Position = UDim2.new(0, 10, 1, 0)
            Cool_Sect_Line.BackgroundColor3 = Cool_Colors.Border
            Cool_Sect_Line.BorderSizePixel = 0
            Cool_Sect_Line.Parent = Cool_Sect_Header

            local Cool_Sect_Content = Instance.new("Frame")
            Cool_Sect_Content.Size = UDim2.new(1, -16, 1, -34)
            Cool_Sect_Content.Position = UDim2.new(0, 8, 0, 32)
            Cool_Sect_Content.BackgroundTransparency = 1
            Cool_Sect_Content.Parent = Cool_Sect_Bg

            local Cool_Layout = Instance.new("UIListLayout")
            Cool_Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Cool_Layout.Padding = UDim.new(0, 8)
            Cool_Layout.Parent = Cool_Sect_Content

            Run_Service.RenderStepped:Connect(function()
                Cool_Sect_Bg.Size = UDim2.new(1, 0, 0, Cool_Layout.AbsoluteContentSize.Y + 44)
            end)

            return Cool_Element_Injector(Cool_Sect_Content)
        end

        return Cool_Section_Api
    end

    return Cool_Window_Context
end

return Nixware_Premium_Api
