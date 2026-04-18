local Core_Gui = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")
local Tween_Service = game:GetService("TweenService")
local Text_Service = game:GetService("TextService")
local Http_Service = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")

local Nixware_Premium_Api = {
    Flags = {}
}

local Colors = {
    Main_Bg = Color3.new(0.035294, 0.035294, 0.050980),
    Sidebar_Bg = Color3.new(0.050980, 0.050980, 0.066666),
    Section_Bg = Color3.new(0.066666, 0.066666, 0.082352),
    Element_Bg = Color3.new(0.090196, 0.090196, 0.105882),
    Element_Hover = Color3.new(0.121568, 0.121568, 0.145098),
    Border = Color3.new(0.105882, 0.105882, 0.133333),
    Border_Light = Color3.new(0.172549, 0.172549, 0.211764),
    Accent = Color3.new(0.423529, 0.576470, 0.988235),
    Accent_Grad_1 = Color3.new(0.423529, 0.576470, 0.988235),
    Accent_Grad_2 = Color3.new(0.619607, 0.462745, 0.988235),
    Text_White = Color3.new(0.952941, 0.952941, 0.972549),
    Text_Dark = Color3.new(0.541176, 0.541176, 0.580392),
    Tooltip_Bg = Color3.new(0.043137, 0.043137, 0.058823),
    Notify_Info = Color3.new(0.247058, 0.635294, 0.980392),
    Notify_Success = Color3.new(0.247058, 0.980392, 0.490196),
    Notify_Warning = Color3.new(0.980392, 0.819607, 0.247058),
    Notify_Error = Color3.new(0.980392, 0.247058, 0.247058)
}

local Main_Font = Enum.Font.GothamMedium
local Bold_Font = Enum.Font.GothamBold

local Screen_Gui = Instance.new("ScreenGui")
Screen_Gui.Name = Http_Service:GenerateGUID(false)
Screen_Gui.Parent = Core_Gui
Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen_Gui.DisplayOrder = 999 
Screen_Gui.IgnoreGuiInset = true

local Tooltip_Frame = Instance.new("Frame")
Tooltip_Frame.BackgroundColor3 = Colors.Tooltip_Bg
Tooltip_Frame.BackgroundTransparency = 0.158372
Tooltip_Frame.Size = UDim2.new(0, 0, 0, 24)
Tooltip_Frame.ZIndex = 2000
Tooltip_Frame.Visible = false
Tooltip_Frame.Parent = Screen_Gui

local Tooltip_Corner = Instance.new("UICorner")
Tooltip_Corner.CornerRadius = UDim.new(0, 4)
Tooltip_Corner.Parent = Tooltip_Frame

local Tooltip_Stroke = Instance.new("UIStroke")
Tooltip_Stroke.Color = Colors.Border_Light
Tooltip_Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
Tooltip_Stroke.Transparency = 1
Tooltip_Stroke.Parent = Tooltip_Frame

local Tooltip_Text = Instance.new("TextLabel")
Tooltip_Text.Size = UDim2.new(1, -16, 1, 0)
Tooltip_Text.Position = UDim2.new(0, 8, 0, 0)
Tooltip_Text.BackgroundTransparency = 1
Tooltip_Text.TextColor3 = Colors.Text_White
Tooltip_Text.TextTransparency = 1
Tooltip_Text.TextSize = 12
Tooltip_Text.Font = Main_Font
Tooltip_Text.TextXAlignment = Enum.TextXAlignment.Left
Tooltip_Text.ZIndex = 2001
Tooltip_Text.Parent = Tooltip_Frame

local Notify_Container = Instance.new("Frame")
Notify_Container.Size = UDim2.new(0, 300, 1, -40)
Notify_Container.Position = UDim2.new(1, -320, 0, 20)
Notify_Container.BackgroundTransparency = 1
Notify_Container.ZIndex = 1500
Notify_Container.Parent = Screen_Gui

local Notify_Layout = Instance.new("UIListLayout")
Notify_Layout.SortOrder = Enum.SortOrder.LayoutOrder
Notify_Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
Notify_Layout.Padding = UDim.new(0, 10)
Notify_Layout.Parent = Notify_Container

local Tooltip_Target = ""

local function Animate(Object, Props, Speed)
    local Tween = Tween_Service:Create(Object, TweenInfo.new(Speed or 0.21837482, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), Props)
    Tween:Play()
    return Tween
end

local function Apply_Acrylic(Parent, Transparency, Corner_Radius)
    local Blur = Instance.new("ImageLabel")
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundTransparency = 1
    Blur.Image = "rbxassetid://8992230113"
    Blur.TileSize = UDim2.new(0, 256, 0, 256)
    Blur.ScaleType = Enum.ScaleType.Tile
    Blur.ImageTransparency = Transparency or 0.88732
    Blur.ZIndex = Parent.ZIndex - 1
    Blur.Parent = Parent
    if Corner_Radius then
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = Corner_Radius
        Corner.Parent = Blur
    end
    return Blur
end

local function Show_Tooltip(Text_Str)
    if not Text_Str or Text_Str == "" then
        Tooltip_Target = ""
        return
    end
    local Bounds = Text_Service:GetTextSize(Text_Str, 12, Main_Font, Vector2.new(500, 24))
    Tooltip_Frame.Size = UDim2.new(0, Bounds.X + 16, 0, 24)
    Tooltip_Text.Text = Text_Str
    Tooltip_Target = Text_Str
end

local function Snap_Value(Value, Step)
    if not Step then return Value end
    return math.floor((Value / Step) + 0.5) * Step
end

local function Format_Value(Value, Step)
    if Step and Step < 1 then
        local Decimals = tostring(Step):len() - 2
        return string.format("%."..Decimals.."f", Value)
    end
    return tostring(Value)
end

Run_Service.RenderStepped:Connect(function()
    if Tooltip_Target ~= "" then
        local Mouse = User_Input_Service:GetMouseLocation()
        Tooltip_Frame.Position = UDim2.new(0, Mouse.X + 15, 0, Mouse.Y + 15)
        if not Tooltip_Frame.Visible then
            Tooltip_Frame.Visible = true
            Animate(Tooltip_Frame, {BackgroundTransparency = 0.1837265}, 0.1837265)
            Animate(Tooltip_Stroke, {Transparency = 0}, 0.1837265)
            Animate(Tooltip_Text, {TextTransparency = 0}, 0.1837265)
        end
    else
        Animate(Tooltip_Frame, {BackgroundTransparency = 1}, 0.1284739)
        Animate(Tooltip_Stroke, {Transparency = 1}, 0.1284739)
        Animate(Tooltip_Text, {TextTransparency = 1}, 0.1284739)
        task.delay(0.1284739, function()
            if Tooltip_Target == "" then
                Tooltip_Frame.Visible = false
            end
        end)
    end
end)

function Nixware_Premium_Api:Notify(Config)
    local Title = Config.Title or "Notification"
    local Text = Config.Text or ""
    local Duration = Config.Duration or 3
    local Type = Config.Type or "Info"
    local Accent_Color = Colors["Notify_" .. Type] or Colors.Accent

    local Notif_Frame = Instance.new("Frame")
    Notif_Frame.Size = UDim2.new(1, 0, 0, 60)
    Notif_Frame.Position = UDim2.new(1, 320, 0, 0)
    Notif_Frame.BackgroundColor3 = Colors.Main_Bg
    Notif_Frame.BackgroundTransparency = 0.28547
    Notif_Frame.ZIndex = 1501
    Notif_Frame.Parent = Notify_Container

    local Notif_Corner = Instance.new("UICorner")
    Notif_Corner.CornerRadius = UDim.new(0, 6)
    Notif_Corner.Parent = Notif_Frame

    local Notif_Stroke = Instance.new("UIStroke")
    Notif_Stroke.Color = Colors.Border_Light
    Notif_Stroke.Parent = Notif_Frame

    Apply_Acrylic(Notif_Frame, 0.91238, UDim.new(0, 6))

    local Line = Instance.new("Frame")
    Line.Size = UDim2.new(0, 3, 1, -12)
    Line.Position = UDim2.new(0, 6, 0, 6)
    Line.BackgroundColor3 = Accent_Color
    Line.BorderSizePixel = 0
    Line.ZIndex = 1502
    Line.Parent = Notif_Frame

    local Line_Corner = Instance.new("UICorner")
    Line_Corner.CornerRadius = UDim.new(0, 3)
    Line_Corner.Parent = Line

    local Title_Lbl = Instance.new("TextLabel")
    Title_Lbl.Size = UDim2.new(1, -24, 0, 16)
    Title_Lbl.Position = UDim2.new(0, 16, 0, 8)
    Title_Lbl.BackgroundTransparency = 1
    Title_Lbl.Text = Title
    Title_Lbl.TextColor3 = Colors.Text_White
    Title_Lbl.TextSize = 13
    Title_Lbl.Font = Bold_Font
    Title_Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Title_Lbl.ZIndex = 1502
    Title_Lbl.Parent = Notif_Frame

    local Text_Lbl = Instance.new("TextLabel")
    Text_Lbl.Size = UDim2.new(1, -24, 0, 24)
    Text_Lbl.Position = UDim2.new(0, 16, 0, 26)
    Text_Lbl.BackgroundTransparency = 1
    Text_Lbl.Text = Text
    Text_Lbl.TextColor3 = Colors.Text_Dark
    Text_Lbl.TextSize = 12
    Text_Lbl.Font = Main_Font
    Text_Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Text_Lbl.TextWrapped = true
    Text_Lbl.ZIndex = 1502
    Text_Lbl.Parent = Notif_Frame

    Animate(Notif_Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.43857)

    task.delay(Duration, function()
        local Out = Animate(Notif_Frame, {Position = UDim2.new(1, 320, 0, 0)}, 0.38472)
        Out.Completed:Connect(function()
            Notif_Frame:Destroy()
        end)
    end)
end

function Nixware_Premium_Api:Window_Create(Window_Name)
    local Main_Bg = Instance.new("Frame")
    Main_Bg.Size = UDim2.new(0, 720, 0, 480)
    Main_Bg.Position = UDim2.new(0.5, -360, 0.5, -240)
    Main_Bg.BackgroundColor3 = Colors.Main_Bg
    Main_Bg.BackgroundTransparency = 0.18374
    Main_Bg.BorderSizePixel = 0
    Main_Bg.Active = true
    Main_Bg.Parent = Screen_Gui
    
    local Main_Corner = Instance.new("UICorner")
    Main_Corner.CornerRadius = UDim.new(0, 6)
    Main_Corner.Parent = Main_Bg
    
    local Main_Stroke = Instance.new("UIStroke")
    Main_Stroke.Color = Colors.Border
    Main_Stroke.Parent = Main_Bg

    Apply_Acrylic(Main_Bg, 0.88741, UDim.new(0, 6))

    local Top_Bar = Instance.new("Frame")
    Top_Bar.Size = UDim2.new(1, 0, 0, 36)
    Top_Bar.BackgroundColor3 = Colors.Sidebar_Bg
    Top_Bar.BackgroundTransparency = 0.21847
    Top_Bar.BorderSizePixel = 0
    Top_Bar.Parent = Main_Bg
    
    local Top_Corner = Instance.new("UICorner")
    Top_Corner.CornerRadius = UDim.new(0, 6)
    Top_Corner.Parent = Top_Bar

    local Top_Hider = Instance.new("Frame")
    Top_Hider.Size = UDim2.new(1, 0, 0, 6)
    Top_Hider.Position = UDim2.new(0, 0, 1, -6)
    Top_Hider.BackgroundColor3 = Colors.Sidebar_Bg
    Top_Hider.BackgroundTransparency = 0.21847
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

    local Accent_Grad = Instance.new("UIGradient")
    Accent_Grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Accent_Grad_1),
        ColorSequenceKeypoint.new(1, Colors.Accent_Grad_2)
    }
    Accent_Grad.Parent = Accent_Line

    local Top_Border = Instance.new("Frame")
    Top_Border.Size = UDim2.new(1, 0, 0, 1)
    Top_Border.Position = UDim2.new(0, 0, 1, 0)
    Top_Border.BackgroundColor3 = Colors.Border
    Top_Border.BorderSizePixel = 0
    Top_Border.Parent = Top_Bar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -20, 1, -2)
    Title.Position = UDim2.new(0, 15, 0, 2)
    Title.BackgroundTransparency = 1
    Title.Text = Window_Name
    Title.TextColor3 = Colors.Text_White
    Title.TextSize = 13
    Title.Font = Bold_Font
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Top_Bar

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -37)
    Sidebar.Position = UDim2.new(0, 0, 0, 37)
    Sidebar.BackgroundColor3 = Colors.Sidebar_Bg
    Sidebar.BackgroundTransparency = 0.21847
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Main_Bg
    
    local Sidebar_Corner = Instance.new("UICorner")
    Sidebar_Corner.CornerRadius = UDim.new(0, 6)
    Sidebar_Corner.Parent = Sidebar

    local Sidebar_Hider_R = Instance.new("Frame")
    Sidebar_Hider_R.Size = UDim2.new(0, 6, 1, 0)
    Sidebar_Hider_R.Position = UDim2.new(1, -6, 0, 0)
    Sidebar_Hider_R.BackgroundColor3 = Colors.Sidebar_Bg
    Sidebar_Hider_R.BackgroundTransparency = 0.21847
    Sidebar_Hider_R.BorderSizePixel = 0
    Sidebar_Hider_R.Parent = Sidebar

    local Sidebar_Hider_T = Instance.new("Frame")
    Sidebar_Hider_T.Size = UDim2.new(1, 0, 0, 6)
    Sidebar_Hider_T.BackgroundColor3 = Colors.Sidebar_Bg
    Sidebar_Hider_T.BackgroundTransparency = 0.21847
    Sidebar_Hider_T.BorderSizePixel = 0
    Sidebar_Hider_T.Parent = Sidebar

    local Sidebar_Border = Instance.new("Frame")
    Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
    Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
    Sidebar_Border.BackgroundColor3 = Colors.Border
    Sidebar_Border.BorderSizePixel = 0
    Sidebar_Border.Parent = Sidebar

    local Tab_Scroll = Instance.new("ScrollingFrame")
    Tab_Scroll.Size = UDim2.new(1, -10, 1, -10)
    Tab_Scroll.Position = UDim2.new(0, 5, 0, 5)
    Tab_Scroll.BackgroundTransparency = 1
    Tab_Scroll.BorderSizePixel = 0
    Tab_Scroll.ScrollBarThickness = 0
    Tab_Scroll.Parent = Sidebar

    local Tab_Layout = Instance.new("UIListLayout")
    Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tab_Layout.Padding = UDim.new(0, 4)
    Tab_Layout.Parent = Tab_Scroll

    local Content_Area = Instance.new("Frame")
    Content_Area.Size = UDim2.new(1, -151, 1, -37)
    Content_Area.Position = UDim2.new(0, 151, 0, 37)
    Content_Area.BackgroundTransparency = 1
    Content_Area.Parent = Main_Bg

    local Dragging = false
    local Drag_Input = nil
    local Drag_Start = nil
    local Start_Pos = nil
    local Target_Pos = Main_Bg.Position

    Top_Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            Drag_Start = Input.Position
            Start_Pos = Main_Bg.Position
        end
    end)

    Top_Bar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then Drag_Input = Input end
    end)

    User_Input_Service.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)

    Run_Service.RenderStepped:Connect(function()
        if Dragging and Drag_Input then
            local Delta = Drag_Input.Position - Drag_Start
            Target_Pos = UDim2.new(Start_Pos.X.Scale, Start_Pos.X.Offset + Delta.X, Start_Pos.Y.Scale, Start_Pos.Y.Offset + Delta.Y)
        end
        Main_Bg.Position = Main_Bg.Position:Lerp(Target_Pos, 0.1743819)
    end)

    local Window_Context = { Tabs = {}, Active_Tab = nil }

    function Window_Context:Tab_Create(Tab_Name, Icon_Id)
        local Tab_Data = {}

        local Tab_Btn = Instance.new("TextButton")
        Tab_Btn.Size = UDim2.new(1, 0, 0, 32)
        Tab_Btn.BackgroundColor3 = Colors.Element_Hover
        Tab_Btn.BackgroundTransparency = 1
        Tab_Btn.Text = ""
        Tab_Btn.AutoButtonColor = false
        Tab_Btn.Parent = Tab_Scroll
        
        local Btn_Corner = Instance.new("UICorner")
        Btn_Corner.CornerRadius = UDim.new(0, 4)
        Btn_Corner.Parent = Tab_Btn

        local Tab_Label = Instance.new("TextLabel")
        Tab_Label.BackgroundTransparency = 1
        Tab_Label.Text = Tab_Name
        Tab_Label.TextColor3 = Colors.Text_Dark
        Tab_Label.TextSize = 12
        Tab_Label.Font = Main_Font
        Tab_Label.TextXAlignment = Enum.TextXAlignment.Left
        Tab_Label.Parent = Tab_Btn

        if Icon_Id and Icon_Id ~= "" then
            local Tab_Icon = Instance.new("ImageLabel")
            Tab_Icon.Size = UDim2.new(0, 14, 0, 14)
            Tab_Icon.Position = UDim2.new(0, 12, 0.5, -7)
            Tab_Icon.BackgroundTransparency = 1
            Tab_Icon.Image = Icon_Id
            Tab_Icon.ImageColor3 = Colors.Text_Dark
            Tab_Icon.Parent = Tab_Btn
            Tab_Data.Icon = Tab_Icon
            Tab_Label.Position = UDim2.new(0, 34, 0, 0)
            Tab_Label.Size = UDim2.new(1, -44, 1, 0)
        else
            Tab_Label.Position = UDim2.new(0, 12, 0, 0)
            Tab_Label.Size = UDim2.new(1, -20, 1, 0)
        end

        local Tab_Ind = Instance.new("Frame")
        Tab_Ind.Size = UDim2.new(0, 2, 0, 0)
        Tab_Ind.Position = UDim2.new(0, 0, 0.5, 0)
        Tab_Ind.BackgroundColor3 = Colors.Accent
        Tab_Ind.BorderSizePixel = 0
        Tab_Ind.Parent = Tab_Btn
        
        local Ind_Corner = Instance.new("UICorner")
        Ind_Corner.CornerRadius = UDim.new(0, 2)
        Ind_Corner.Parent = Tab_Ind

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Colors.Accent
        Page.Visible = false
        Page.Parent = Content_Area

        local Left_Col = Instance.new("Frame")
        Left_Col.Size = UDim2.new(0.5, -16, 1, 0)
        Left_Col.Position = UDim2.new(0, 10, 0, 10)
        Left_Col.BackgroundTransparency = 1
        Left_Col.Parent = Page

        local Right_Col = Instance.new("Frame")
        Right_Col.Size = UDim2.new(0.5, -16, 1, 0)
        Right_Col.Position = UDim2.new(0.5, 6, 0, 10)
        Right_Col.BackgroundTransparency = 1
        Right_Col.Parent = Page

        local Left_Layout = Instance.new("UIListLayout")
        Left_Layout.Padding = UDim.new(0, 10)
        Left_Layout.Parent = Left_Col

        local Right_Layout = Instance.new("UIListLayout")
        Right_Layout.Padding = UDim.new(0, 10)
        Right_Layout.Parent = Right_Col

        Run_Service.RenderStepped:Connect(function()
            local Max_Y = math.max(Left_Layout.AbsoluteContentSize.Y, Right_Layout.AbsoluteContentSize.Y)
            Page.CanvasSize = UDim2.new(0, 0, 0, Max_Y + 20)
            Tab_Scroll.CanvasSize = UDim2.new(0, 0, 0, Tab_Layout.AbsoluteContentSize.Y + 10)
        end)

        function Tab_Data:Activate()
            if Window_Context.Active_Tab == Tab_Data then return end
            if Window_Context.Active_Tab then
                Animate(Window_Context.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.228197)
                Animate(Window_Context.Active_Tab.Lbl, {TextColor3 = Colors.Text_Dark}, 0.228197)
                if Window_Context.Active_Tab.Icon then Animate(Window_Context.Active_Tab.Icon, {ImageColor3 = Colors.Text_Dark}, 0.228197) end
                Animate(Window_Context.Active_Tab.Ind, {Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.228197)
                Window_Context.Active_Tab.Page.Visible = false
            end
            Window_Context.Active_Tab = Tab_Data
            Page.Visible = true
            Animate(Tab_Btn, {BackgroundTransparency = 0.11847}, 0.228197)
            Animate(Tab_Label, {TextColor3 = Colors.Text_White}, 0.228197)
            if Tab_Data.Icon then Animate(Tab_Data.Icon, {ImageColor3 = Colors.Accent}, 0.228197) end
            Animate(Tab_Ind, {Size = UDim2.new(0, 2, 0, 16), Position = UDim2.new(0, 0, 0.5, -8)}, 0.228197)
        end

        Tab_Btn.MouseButton1Click:Connect(function() Tab_Data:Activate() end)

        Tab_Data.Btn = Tab_Btn
        Tab_Data.Lbl = Tab_Label
        Tab_Data.Ind = Tab_Ind
        Tab_Data.Page = Page

        table.insert(Window_Context.Tabs, Tab_Data)
        if #Window_Context.Tabs == 1 then Tab_Data:Activate() end

        local function Element_Injector(Target_Container)
            local Elements = {}

            function Elements:Subtext_Create(Text)
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -10, 0, 14)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = Text
                Lbl.TextColor3 = Colors.Text_Dark
                Lbl.TextSize = 11
                Lbl.Font = Main_Font
                Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Lbl.Parent = Target_Container
            end

            function Elements:Toggle_Create(Name, Flag, Default, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = Default or false

                local Tog_Btn = Instance.new("TextButton")
                Tog_Btn.Size = UDim2.new(1, 0, 0, 16)
                Tog_Btn.BackgroundTransparency = 1
                Tog_Btn.Text = ""
                Tog_Btn.Parent = Target_Container

                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 14, 0, 14)
                Box.Position = UDim2.new(0, 2, 0.5, -7)
                Box.BackgroundColor3 = Nixware_Premium_Api.Flags[Flag] and Colors.Accent or Colors.Element_Bg
                Box.BackgroundTransparency = 0.21847
                Box.Parent = Tog_Btn
                
                local Box_Corner = Instance.new("UICorner")
                Box_Corner.CornerRadius = UDim.new(0, 3)
                Box_Corner.Parent = Box
                
                local Box_Stroke = Instance.new("UIStroke")
                Box_Stroke.Color = Nixware_Premium_Api.Flags[Flag] and Colors.Accent or Colors.Border
                Box_Stroke.Parent = Box

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -26, 1, 0)
                Text.Position = UDim2.new(0, 24, 0, 0)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Nixware_Premium_Api.Flags[Flag] and Colors.Text_White or Colors.Text_Dark
                Text.TextSize = 12
                Text.Font = Main_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Tog_Btn

                Tog_Btn.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Nixware_Premium_Api.Flags[Flag] then Animate(Box_Stroke, {Color = Colors.Border_Light}, 0.231948) end
                end)
                Tog_Btn.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Nixware_Premium_Api.Flags[Flag] then Animate(Box_Stroke, {Color = Colors.Border}, 0.231948) end
                end)

                Tog_Btn.MouseButton1Click:Connect(function()
                    Nixware_Premium_Api.Flags[Flag] = not Nixware_Premium_Api.Flags[Flag]
                    local S = Nixware_Premium_Api.Flags[Flag]
                    Animate(Box, {BackgroundColor3 = S and Colors.Accent or Colors.Element_Bg}, 0.231948)
                    Animate(Box_Stroke, {Color = S and Colors.Accent or Colors.Border}, 0.231948)
                    Animate(Text, {TextColor3 = S and Colors.Text_White or Colors.Text_Dark}, 0.231948)
                    if Callback then task.spawn(Callback, S) end
                end)
            end

            function Elements:Slider_Create(Name, Flag, Min, Max, Default, Step, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = Snap_Value(Default or Min, Step)

                local Sld_Frame = Instance.new("Frame")
                Sld_Frame.Size = UDim2.new(1, 0, 0, 36)
                Sld_Frame.BackgroundTransparency = 1
                Sld_Frame.Parent = Target_Container

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -50, 0, 14)
                Text.Position = UDim2.new(0, 2, 0, 0)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Colors.Text_White
                Text.TextSize = 12
                Text.Font = Main_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Sld_Frame

                local Val_Box = Instance.new("TextBox")
                Val_Box.Size = UDim2.new(0, 40, 0, 14)
                Val_Box.Position = UDim2.new(1, -42, 0, 0)
                Val_Box.BackgroundTransparency = 1
                Val_Box.Text = Format_Value(Nixware_Premium_Api.Flags[Flag], Step)
                Val_Box.TextColor3 = Colors.Text_White
                Val_Box.TextSize = 12
                Val_Box.Font = Main_Font
                Val_Box.TextXAlignment = Enum.TextXAlignment.Right
                Val_Box.ClearTextOnFocus = false
                Val_Box.Parent = Sld_Frame

                local Bg = Instance.new("TextButton")
                Bg.Size = UDim2.new(1, -4, 0, 6)
                Bg.Position = UDim2.new(0, 2, 0, 24)
                Bg.BackgroundColor3 = Colors.Element_Bg
                Bg.BackgroundTransparency = 0.21847
                Bg.Text = ""
                Bg.AutoButtonColor = false
                Bg.Parent = Sld_Frame
                
                local Bg_Corner = Instance.new("UICorner")
                Bg_Corner.CornerRadius = UDim.new(0, 3)
                Bg_Corner.Parent = Bg
                
                local Bg_Stroke = Instance.new("UIStroke")
                Bg_Stroke.Color = Colors.Border
                Bg_Stroke.Parent = Bg

                local Fill = Instance.new("Frame")
                local Initial_Pct = (Nixware_Premium_Api.Flags[Flag] - Min) / (Max - Min)
                Fill.Size = UDim2.new(Initial_Pct, 0, 1, 0)
                Fill.BackgroundColor3 = Colors.Accent
                Fill.Parent = Bg
                
                local Fill_Corner = Instance.new("UICorner")
                Fill_Corner.CornerRadius = UDim.new(0, 3)
                Fill_Corner.Parent = Fill

                local Knob = Instance.new("Frame")
                Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob.Size = UDim2.new(0, 10, 0, 10)
                Knob.Position = UDim2.new(Initial_Pct, 0, 0.5, 0)
                Knob.BackgroundColor3 = Colors.Text_White
                Knob.ZIndex = 2
                Knob.Parent = Bg
                local Knob_Corner = Instance.new("UICorner"); Knob_Corner.CornerRadius = UDim.new(1, 0); Knob_Corner.Parent = Knob
                local Knob_Stroke = Instance.new("UIStroke"); Knob_Stroke.Color = Colors.Border; Knob_Stroke.Parent = Knob

                Bg.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate(Bg_Stroke, {Color = Colors.Border_Light}, 0.24183)
                end)
                Bg.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate(Bg_Stroke, {Color = Colors.Border}, 0.24183)
                end)

                local Sliding = false

                local function Set_Value(New_Val)
                    local Clamped = math.clamp(New_Val, Min, Max)
                    local Snapped = Snap_Value(Clamped, Step)
                    if Nixware_Premium_Api.Flags[Flag] ~= Snapped then
                        Nixware_Premium_Api.Flags[Flag] = Snapped
                        local Pct = (Snapped - Min) / (Max - Min)
                        Animate(Fill, {Size = UDim2.new(Pct, 0, 1, 0)}, 0.082739)
                        Animate(Knob, {Position = UDim2.new(Pct, 0, 0.5, 0)}, 0.082739)
                        Val_Box.Text = Format_Value(Snapped, Step)
                        if Callback then task.spawn(Callback, Snapped) end
                    end
                end

                Bg.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Sliding = true
                        local Pct = math.clamp((Input.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                        Set_Value(Min + ((Max - Min) * Pct))
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Sliding = false end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if Sliding and Input.UserInputType == Enum.UserInputType.MouseMovement then 
                        local Pct = math.clamp((Input.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                        Set_Value(Min + ((Max - Min) * Pct))
                    end
                end)

                Val_Box.FocusLost:Connect(function()
                    local Input_Val = tonumber(Val_Box.Text)
                    if Input_Val then
                        Set_Value(Input_Val)
                    else
                        Val_Box.Text = Format_Value(Nixware_Premium_Api.Flags[Flag], Step)
                    end
                end)
            end

            function Elements:RangeSlider_Create(Name, Flag, Min, Max, DefMin, DefMax, Step, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = {Min = Snap_Value(DefMin or Min, Step), Max = Snap_Value(DefMax or Max, Step)}

                local Sld_Frame = Instance.new("Frame")
                Sld_Frame.Size = UDim2.new(1, 0, 0, 36)
                Sld_Frame.BackgroundTransparency = 1
                Sld_Frame.Parent = Target_Container

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -80, 0, 14)
                Text.Position = UDim2.new(0, 2, 0, 0)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Colors.Text_White
                Text.TextSize = 12
                Text.Font = Main_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Sld_Frame

                local Val_Lbl = Instance.new("TextLabel")
                Val_Lbl.Size = UDim2.new(0, 80, 0, 14)
                Val_Lbl.Position = UDim2.new(1, -82, 0, 0)
                Val_Lbl.BackgroundTransparency = 1
                Val_Lbl.Text = Format_Value(Nixware_Premium_Api.Flags[Flag].Min, Step) .. " - " .. Format_Value(Nixware_Premium_Api.Flags[Flag].Max, Step)
                Val_Lbl.TextColor3 = Colors.Text_White
                Val_Lbl.TextSize = 12
                Val_Lbl.Font = Main_Font
                Val_Lbl.TextXAlignment = Enum.TextXAlignment.Right
                Val_Lbl.Parent = Sld_Frame

                local Bg = Instance.new("TextButton")
                Bg.Size = UDim2.new(1, -4, 0, 6)
                Bg.Position = UDim2.new(0, 2, 0, 24)
                Bg.BackgroundColor3 = Colors.Element_Bg
                Bg.BackgroundTransparency = 0.21847
                Bg.Text = ""
                Bg.AutoButtonColor = false
                Bg.Parent = Sld_Frame
                
                local Bg_Corner = Instance.new("UICorner")
                Bg_Corner.CornerRadius = UDim.new(0, 3)
                Bg_Corner.Parent = Bg
                
                local Bg_Stroke = Instance.new("UIStroke")
                Bg_Stroke.Color = Colors.Border
                Bg_Stroke.Parent = Bg

                local Fill = Instance.new("Frame")
                Fill.BackgroundColor3 = Colors.Accent
                Fill.Parent = Bg
                
                local Fill_Corner = Instance.new("UICorner")
                Fill_Corner.CornerRadius = UDim.new(0, 3)
                Fill_Corner.Parent = Fill

                local Knob_Min = Instance.new("Frame")
                Knob_Min.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob_Min.Size = UDim2.new(0, 10, 0, 10)
                Knob_Min.BackgroundColor3 = Colors.Text_White
                Knob_Min.ZIndex = 2
                Knob_Min.Parent = Bg
                local KMin_Corner = Instance.new("UICorner"); KMin_Corner.CornerRadius = UDim.new(1, 0); KMin_Corner.Parent = Knob_Min
                local KMin_Stroke = Instance.new("UIStroke"); KMin_Stroke.Color = Colors.Border; KMin_Stroke.Parent = Knob_Min

                local Knob_Max = Instance.new("Frame")
                Knob_Max.AnchorPoint = Vector2.new(0.5, 0.5)
                Knob_Max.Size = UDim2.new(0, 10, 0, 10)
                Knob_Max.BackgroundColor3 = Colors.Text_White
                Knob_Max.ZIndex = 2
                Knob_Max.Parent = Bg
                local KMax_Corner = Instance.new("UICorner"); KMax_Corner.CornerRadius = UDim.new(1, 0); KMax_Corner.Parent = Knob_Max
                local KMax_Stroke = Instance.new("UIStroke"); KMax_Stroke.Color = Colors.Border; KMax_Stroke.Parent = Knob_Max

                local function Update_Visuals()
                    local Pct1 = (Nixware_Premium_Api.Flags[Flag].Min - Min) / (Max - Min)
                    local Pct2 = (Nixware_Premium_Api.Flags[Flag].Max - Min) / (Max - Min)
                    Animate(Fill, {Position = UDim2.new(Pct1, 0, 0, 0), Size = UDim2.new(Pct2 - Pct1, 0, 1, 0)}, 0.082736)
                    Animate(Knob_Min, {Position = UDim2.new(Pct1, 0, 0.5, 0)}, 0.082736)
                    Animate(Knob_Max, {Position = UDim2.new(Pct2, 0, 0.5, 0)}, 0.082736)
                    Val_Lbl.Text = Format_Value(Nixware_Premium_Api.Flags[Flag].Min, Step) .. " - " .. Format_Value(Nixware_Premium_Api.Flags[Flag].Max, Step)
                end
                Update_Visuals()

                Bg.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate(Bg_Stroke, {Color = Colors.Border_Light}, 0.24183)
                end)
                Bg.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate(Bg_Stroke, {Color = Colors.Border}, 0.24183)
                end)

                local Sliding_Min = false
                local Sliding_Max = false

                Bg.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local Mouse_X = Input.Position.X
                        local Pct1 = (Nixware_Premium_Api.Flags[Flag].Min - Min) / (Max - Min)
                        local Pct2 = (Nixware_Premium_Api.Flags[Flag].Max - Min) / (Max - Min)
                        local Pos1 = Bg.AbsolutePosition.X + (Bg.AbsoluteSize.X * Pct1)
                        local Pos2 = Bg.AbsolutePosition.X + (Bg.AbsoluteSize.X * Pct2)
                        
                        if math.abs(Mouse_X - Pos1) < math.abs(Mouse_X - Pos2) then
                            Sliding_Min = true
                        else
                            Sliding_Max = true
                        end
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        Sliding_Min = false
                        Sliding_Max = false
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if (Sliding_Min or Sliding_Max) and Input.UserInputType == Enum.UserInputType.MouseMovement then 
                        local Pct = math.clamp((Input.Position.X - Bg.AbsolutePosition.X) / Bg.AbsoluteSize.X, 0, 1)
                        local Calc_Val = Snap_Value(Min + ((Max - Min) * Pct), Step)
                        
                        if Sliding_Min then
                            if Calc_Val <= Nixware_Premium_Api.Flags[Flag].Max then
                                Nixware_Premium_Api.Flags[Flag].Min = Calc_Val
                            else
                                Nixware_Premium_Api.Flags[Flag].Min = Nixware_Premium_Api.Flags[Flag].Max
                            end
                        elseif Sliding_Max then
                            if Calc_Val >= Nixware_Premium_Api.Flags[Flag].Min then
                                Nixware_Premium_Api.Flags[Flag].Max = Calc_Val
                            else
                                Nixware_Premium_Api.Flags[Flag].Max = Nixware_Premium_Api.Flags[Flag].Min
                            end
                        end
                        Update_Visuals()
                        if Callback then task.spawn(Callback, Nixware_Premium_Api.Flags[Flag]) end
                    end
                end)
            end

            function Elements:Textbox_Create(Name, Flag, Default, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = Default or ""

                local Box_Frame = Instance.new("Frame")
                Box_Frame.Size = UDim2.new(1, 0, 0, 36)
                Box_Frame.BackgroundTransparency = 1
                Box_Frame.Parent = Target_Container

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -120, 1, 0)
                Text.Position = UDim2.new(0, 2, 0, 0)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Colors.Text_White
                Text.TextSize = 12
                Text.Font = Main_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Box_Frame

                local Txt_Bg = Instance.new("Frame")
                Txt_Bg.Size = UDim2.new(0, 110, 0, 24)
                Txt_Bg.Position = UDim2.new(1, -112, 0.5, -12)
                Txt_Bg.BackgroundColor3 = Colors.Element_Bg
                Txt_Bg.BackgroundTransparency = 0.21847
                Txt_Bg.Parent = Box_Frame
                
                local Bg_Corner = Instance.new("UICorner")
                Bg_Corner.CornerRadius = UDim.new(0, 4)
                Bg_Corner.Parent = Txt_Bg
                
                local Bg_Stroke = Instance.new("UIStroke")
                Bg_Stroke.Color = Colors.Border
                Bg_Stroke.Parent = Txt_Bg

                local Input_Box = Instance.new("TextBox")
                Input_Box.Size = UDim2.new(1, -10, 1, 0)
                Input_Box.Position = UDim2.new(0, 5, 0, 0)
                Input_Box.BackgroundTransparency = 1
                Input_Box.Text = Nixware_Premium_Api.Flags[Flag]
                Input_Box.TextColor3 = Colors.Text_Dark
                Input_Box.TextSize = 12
                Input_Box.Font = Main_Font
                Input_Box.ClearTextOnFocus = false
                Input_Box.TextXAlignment = Enum.TextXAlignment.Left
                Input_Box.ClipsDescendants = true
                Input_Box.Parent = Txt_Bg

                Input_Box.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate(Bg_Stroke, {Color = Colors.Border_Light}, 0.24182)
                end)
                Input_Box.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate(Bg_Stroke, {Color = Colors.Border}, 0.24182)
                end)

                Input_Box.Focused:Connect(function()
                    Animate(Bg_Stroke, {Color = Colors.Accent}, 0.24182)
                    Animate(Input_Box, {TextColor3 = Colors.Text_White}, 0.24182)
                end)

                Input_Box.FocusLost:Connect(function()
                    Animate(Bg_Stroke, {Color = Colors.Border}, 0.24182)
                    Animate(Input_Box, {TextColor3 = Colors.Text_Dark}, 0.24182)
                    Nixware_Premium_Api.Flags[Flag] = Input_Box.Text
                    if Callback then task.spawn(Callback, Input_Box.Text) end
                end)
            end

            function Elements:Keybind_Create(Name, Flag, Default, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = Default or Enum.KeyCode.Unknown
                local Listening = false

                local Bind_Frame = Instance.new("Frame")
                Bind_Frame.Size = UDim2.new(1, 0, 0, 24)
                Bind_Frame.BackgroundTransparency = 1
                Bind_Frame.Parent = Target_Container

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -80, 1, 0)
                Text.Position = UDim2.new(0, 2, 0, 0)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Colors.Text_White
                Text.TextSize = 12
                Text.Font = Main_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Bind_Frame

                local Bind_Btn = Instance.new("TextButton")
                Bind_Btn.Size = UDim2.new(0, 70, 0, 20)
                Bind_Btn.Position = UDim2.new(1, -72, 0.5, -10)
                Bind_Btn.BackgroundColor3 = Colors.Element_Bg
                Bind_Btn.BackgroundTransparency = 0.21847
                Bind_Btn.Text = Nixware_Premium_Api.Flags[Flag] == Enum.KeyCode.Unknown and "[ None ]" or "[ " .. Nixware_Premium_Api.Flags[Flag].Name .. " ]"
                Bind_Btn.TextColor3 = Colors.Text_Dark
                Bind_Btn.TextSize = 11
                Bind_Btn.Font = Bold_Font
                Bind_Btn.AutoButtonColor = false
                Bind_Btn.Parent = Bind_Frame

                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 4)
                Btn_Corner.Parent = Bind_Btn

                local Btn_Stroke = Instance.new("UIStroke")
                Btn_Stroke.Color = Colors.Border
                Btn_Stroke.Parent = Bind_Btn

                Bind_Btn.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Listening then Animate(Btn_Stroke, {Color = Colors.Border_Light}, 0.20147) end
                end)
                Bind_Btn.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Listening then Animate(Btn_Stroke, {Color = Colors.Border}, 0.20147) end
                end)

                Bind_Btn.MouseButton1Click:Connect(function()
                    Listening = true
                    Bind_Btn.Text = "[ ... ]"
                    Animate(Btn_Stroke, {Color = Colors.Accent}, 0.20147)
                    Animate(Bind_Btn, {TextColor3 = Colors.Text_White}, 0.20147)
                end)

                User_Input_Service.InputBegan:Connect(function(Input)
                    if Listening then
                        if Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode ~= Enum.KeyCode.Escape then
                            Nixware_Premium_Api.Flags[Flag] = Input.KeyCode
                            Bind_Btn.Text = "[ " .. Input.KeyCode.Name .. " ]"
                        elseif Input.KeyCode == Enum.KeyCode.Escape then
                            Nixware_Premium_Api.Flags[Flag] = Enum.KeyCode.Unknown
                            Bind_Btn.Text = "[ None ]"
                        end
                        Listening = false
                        Animate(Btn_Stroke, {Color = Colors.Border}, 0.20147)
                        Animate(Bind_Btn, {TextColor3 = Colors.Text_Dark}, 0.20147)
                        if Callback then task.spawn(Callback, Nixware_Premium_Api.Flags[Flag]) end
                    else
                        if Input.KeyCode == Nixware_Premium_Api.Flags[Flag] and Input.KeyCode ~= Enum.KeyCode.Unknown then
                            if Callback then task.spawn(Callback, Nixware_Premium_Api.Flags[Flag]) end
                        end
                    end
                end)
            end

            function Elements:Dropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = Default or Options[1]
                local Open = false

                local Drop_Frame = Instance.new("Frame")
                Drop_Frame.Size = UDim2.new(1, 0, 0, 46)
                Drop_Frame.BackgroundTransparency = 1
                Drop_Frame.ClipsDescendants = true
                Drop_Frame.Parent = Target_Container

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -10, 0, 14)
                Text.Position = UDim2.new(0, 2, 0, 0)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Colors.Text_White
                Text.TextSize = 12
                Text.Font = Main_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Drop_Frame

                local Main_Btn = Instance.new("TextButton")
                Main_Btn.Size = UDim2.new(1, -4, 0, 24)
                Main_Btn.Position = UDim2.new(0, 2, 0, 20)
                Main_Btn.BackgroundColor3 = Colors.Element_Bg
                Main_Btn.BackgroundTransparency = 0.21847
                Main_Btn.Text = ""
                Main_Btn.AutoButtonColor = false
                Main_Btn.Parent = Drop_Frame
                
                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 4)
                Btn_Corner.Parent = Main_Btn
                
                local Main_Stroke = Instance.new("UIStroke")
                Main_Stroke.Color = Colors.Border
                Main_Stroke.Parent = Main_Btn

                local Selected = Instance.new("TextLabel")
                Selected.Size = UDim2.new(1, -30, 1, 0)
                Selected.Position = UDim2.new(0, 8, 0, 0)
                Selected.BackgroundTransparency = 1
                Selected.Text = Nixware_Premium_Api.Flags[Flag]
                Selected.TextColor3 = Colors.Text_Dark
                Selected.TextSize = 12
                Selected.Font = Main_Font
                Selected.TextXAlignment = Enum.TextXAlignment.Left
                Selected.Parent = Main_Btn

                local Arrow_Icon = Instance.new("ImageLabel")
                Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Arrow_Icon.Position = UDim2.new(1, -22, 0.5, -7)
                Arrow_Icon.BackgroundTransparency = 1
                Arrow_Icon.Image = "rbxassetid://6031090656"
                Arrow_Icon.ImageColor3 = Colors.Text_Dark
                Arrow_Icon.Parent = Main_Btn

                local List = Instance.new("ScrollingFrame")
                List.Size = UDim2.new(1, -4, 0, 0)
                List.Position = UDim2.new(0, 2, 0, 48)
                List.BackgroundColor3 = Colors.Element_Bg
                List.BackgroundTransparency = 0.21847
                List.BorderSizePixel = 0
                List.ScrollBarThickness = 2
                List.ScrollBarImageColor3 = Colors.Accent
                List.ClipsDescendants = true
                List.Parent = Drop_Frame
                
                local List_Corner = Instance.new("UICorner")
                List_Corner.CornerRadius = UDim.new(0, 4)
                List_Corner.Parent = List
                
                local List_Stroke = Instance.new("UIStroke")
                List_Stroke.Color = Colors.Border
                List_Stroke.Transparency = 1
                List_Stroke.Parent = List

                local List_Layout = Instance.new("UIListLayout")
                List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                List_Layout.Parent = List

                local function Toggle()
                    Open = not Open
                    local Max_Height = math.min(#Options * 24, 120)
                    local Target_Size = Open and Max_Height or 0
                    Animate(Main_Stroke, {Color = Open and Colors.Accent or Colors.Border}, 0.256247)
                    Animate(Arrow_Icon, {Rotation = Open and 180 or 0, ImageColor3 = Open and Colors.Accent or Colors.Text_Dark}, 0.256247)
                    Animate(List, {Size = UDim2.new(1, -4, 0, Target_Size)}, 0.256247)
                    Animate(List_Stroke, {Transparency = Open and 0 or 1}, 0.256247)
                    Animate(Drop_Frame, {Size = UDim2.new(1, 0, 0, 46 + Target_Size + (Open and 4 or 0))}, 0.256247)
                end

                Main_Btn.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Open then Animate(Main_Stroke, {Color = Colors.Border_Light}, 0.198375) end
                end)
                Main_Btn.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Open then Animate(Main_Stroke, {Color = Colors.Border}, 0.198375) end
                end)
                Main_Btn.MouseButton1Click:Connect(Toggle)

                for _, Opt in ipairs(Options) do
                    local Opt_Btn = Instance.new("TextButton")
                    Opt_Btn.Size = UDim2.new(1, 0, 0, 24)
                    Opt_Btn.BackgroundColor3 = Colors.Element_Hover
                    Opt_Btn.BackgroundTransparency = 1
                    Opt_Btn.Text = ""
                    Opt_Btn.Parent = List

                    local Opt_Text = Instance.new("TextLabel")
                    Opt_Text.Size = UDim2.new(1, -20, 1, 0)
                    Opt_Text.Position = UDim2.new(0, 8, 0, 0)
                    Opt_Text.BackgroundTransparency = 1
                    Opt_Text.Text = Opt
                    Opt_Text.TextColor3 = Nixware_Premium_Api.Flags[Flag] == Opt and Colors.Accent or Colors.Text_Dark
                    Opt_Text.TextSize = 12
                    Opt_Text.Font = Main_Font
                    Opt_Text.TextXAlignment = Enum.TextXAlignment.Left
                    Opt_Text.Parent = Opt_Btn

                    Opt_Btn.MouseEnter:Connect(function() 
                        Animate(Opt_Btn, {BackgroundTransparency = 0.21847}, 0.153283)
                        if Nixware_Premium_Api.Flags[Flag] ~= Opt then
                            Animate(Opt_Text, {TextColor3 = Colors.Text_White}, 0.153283) 
                        end
                    end)
                    Opt_Btn.MouseLeave:Connect(function()
                        Animate(Opt_Btn, {BackgroundTransparency = 1}, 0.153283)
                        if Nixware_Premium_Api.Flags[Flag] ~= Opt then
                            Animate(Opt_Text, {TextColor3 = Colors.Text_Dark}, 0.153283)
                        end
                    end)

                    Opt_Btn.MouseButton1Click:Connect(function()
                        Nixware_Premium_Api.Flags[Flag] = Opt
                        Selected.Text = Opt
                        Toggle()
                        for _, Child in ipairs(List:GetChildren()) do
                            if Child:IsA("TextButton") then
                                Animate(Child:FindFirstChildOfClass("TextLabel"), {TextColor3 = Colors.Text_Dark}, 0.153283)
                            end
                        end
                        Animate(Opt_Text, {TextColor3 = Colors.Accent}, 0.153283)
                        if Callback then task.spawn(Callback, Opt) end
                    end)
                end
                List.CanvasSize = UDim2.new(0, 0, 0, #Options * 24)
            end

            function Elements:ColorPicker_Create(Name, Flag, Default, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = Default or Color3.new(1, 1, 1)
                local Open = false
                local H, S, V = Nixware_Premium_Api.Flags[Flag]:ToHSV()

                local Col_Frame = Instance.new("Frame")
                Col_Frame.Size = UDim2.new(1, 0, 0, 24)
                Col_Frame.BackgroundTransparency = 1
                Col_Frame.ClipsDescendants = true
                Col_Frame.Parent = Target_Container

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -40, 0, 24)
                Text.Position = UDim2.new(0, 2, 0, 0)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Colors.Text_White
                Text.TextSize = 12
                Text.Font = Main_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Col_Frame

                local Prev_Btn = Instance.new("TextButton")
                Prev_Btn.Size = UDim2.new(0, 24, 0, 14)
                Prev_Btn.Position = UDim2.new(1, -28, 0, 5)
                Prev_Btn.BackgroundColor3 = Nixware_Premium_Api.Flags[Flag]
                Prev_Btn.Text = ""
                Prev_Btn.AutoButtonColor = false
                Prev_Btn.Parent = Col_Frame
                
                local Prev_Corner = Instance.new("UICorner")
                Prev_Corner.CornerRadius = UDim.new(0, 3)
                Prev_Corner.Parent = Prev_Btn
                
                local Prev_Stroke = Instance.new("UIStroke")
                Prev_Stroke.Color = Colors.Border
                Prev_Stroke.Parent = Prev_Btn

                local Expand = Instance.new("Frame")
                Expand.Size = UDim2.new(1, -4, 0, 190)
                Expand.Position = UDim2.new(0, 2, 0, 28)
                Expand.BackgroundColor3 = Colors.Element_Bg
                Expand.BackgroundTransparency = 0.21847
                Expand.Parent = Col_Frame
                
                local Expand_Corner = Instance.new("UICorner")
                Expand_Corner.CornerRadius = UDim.new(0, 4)
                Expand_Corner.Parent = Expand
                
                local Expand_Stroke = Instance.new("UIStroke")
                Expand_Stroke.Color = Colors.Border
                Expand_Stroke.Parent = Expand

                local SV_Map = Instance.new("ImageButton")
                SV_Map.Size = UDim2.new(1, -16, 0, 150)
                SV_Map.Position = UDim2.new(0, 8, 0, 8)
                SV_Map.Image = "rbxassetid://4155801252"
                SV_Map.ImageColor3 = Color3.fromHSV(H, 1, 1)
                SV_Map.AutoButtonColor = false
                SV_Map.Parent = Expand
                local SV_Corner = Instance.new("UICorner"); SV_Corner.CornerRadius = UDim.new(0, 3); SV_Corner.Parent = SV_Map
                local SV_Stroke = Instance.new("UIStroke"); SV_Stroke.Color = Colors.Border; SV_Stroke.Parent = SV_Map

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
                Hue_Map.Parent = Expand
                local Hue_Corner = Instance.new("UICorner"); Hue_Corner.CornerRadius = UDim.new(0, 3); Hue_Corner.Parent = Hue_Map
                local Hue_Stroke = Instance.new("UIStroke"); Hue_Stroke.Color = Colors.Border; Hue_Stroke.Parent = Hue_Map

                local Hue_Grad = Instance.new("UIGradient")
                Hue_Grad.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(1/6, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(2/6, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(3/6, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(4/6, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(5/6, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
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
                    Nixware_Premium_Api.Flags[Flag] = Col
                    SV_Map.ImageColor3 = Color3.fromHSV(H, 1, 1)
                    Prev_Btn.BackgroundColor3 = Col
                    SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    Hue_Cursor.Position = UDim2.new(H, 0, 0.5, 0)
                    if Callback then task.spawn(Callback, Col) end
                end

                local SV_Sliding = false
                local Hue_Sliding = false

                local function Process_SV(Input)
                    S = math.clamp((Input.Position.X - SV_Map.AbsolutePosition.X) / SV_Map.AbsoluteSize.X, 0, 1)
                    V = 1 - math.clamp((Input.Position.Y - SV_Map.AbsolutePosition.Y) / SV_Map.AbsoluteSize.Y, 0, 1)
                    UpdateColor()
                end

                local function Process_Hue(Input)
                    H = math.clamp((Input.Position.X - Hue_Map.AbsolutePosition.X) / Hue_Map.AbsoluteSize.X, 0, 1)
                    UpdateColor()
                end

                SV_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SV_Sliding = true
                        Process_SV(Input)
                    end
                end)
                
                Hue_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Hue_Sliding = true
                        Process_Hue(Input)
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        SV_Sliding = false
                        Hue_Sliding = false
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement then
                        if SV_Sliding then Process_SV(Input) end
                        if Hue_Sliding then Process_Hue(Input) end
                    end
                end)

                Prev_Btn.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Open then Animate(Prev_Stroke, {Color = Colors.Border_Light}, 0.218413) end
                end)
                Prev_Btn.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Open then Animate(Prev_Stroke, {Color = Colors.Border}, 0.218413) end
                end)

                Prev_Btn.MouseButton1Click:Connect(function()
                    Open = not Open
                    Animate(Prev_Stroke, {Color = Open and Colors.Accent or Colors.Border}, 0.263628)
                    Animate(Col_Frame, {Size = UDim2.new(1, 0, 0, Open and 224 or 24)}, 0.281352)
                end)
            end

            function Elements:Button_Create(Name, Tooltip, Callback)
                local Btn_Frame = Instance.new("Frame")
                Btn_Frame.Size = UDim2.new(1, 0, 0, 30)
                Btn_Frame.BackgroundTransparency = 1
                Btn_Frame.Parent = Target_Container

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -4, 1, 0)
                Btn.Position = UDim2.new(0, 2, 0, 0)
                Btn.BackgroundColor3 = Colors.Element_Bg
                Btn.BackgroundTransparency = 0.21847
                Btn.Text = Name
                Btn.TextColor3 = Colors.Text_White
                Btn.TextSize = 12
                Btn.Font = Bold_Font
                Btn.AutoButtonColor = false
                Btn.Parent = Btn_Frame
                
                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 4)
                Btn_Corner.Parent = Btn
                
                local Btn_Stroke = Instance.new("UIStroke")
                Btn_Stroke.Color = Colors.Border
                Btn_Stroke.Parent = Btn

                Btn.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate(Btn, {BackgroundColor3 = Colors.Element_Hover}, 0.219834)
                    Animate(Btn_Stroke, {Color = Colors.Accent}, 0.219834)
                    Animate(Btn, {TextColor3 = Colors.Accent}, 0.219834)
                end)
                Btn.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate(Btn, {BackgroundColor3 = Colors.Element_Bg}, 0.219834)
                    Animate(Btn_Stroke, {Color = Colors.Border}, 0.219834)
                    Animate(Btn, {TextColor3 = Colors.Text_White}, 0.219834)
                end)
                Btn.MouseButton1Down:Connect(function() Animate(Btn, {Size = UDim2.new(0.96, 0, 0.85, 0), Position = UDim2.new(0.02, 0, 0.075, 0)}, 0.124538) end)
                Btn.MouseButton1Up:Connect(function()
                    Animate(Btn, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.124538)
                    if Callback then task.spawn(Callback) end
                end)
            end

            function Elements:SubButton_Create(Name, Tooltip, Callback)
                local Btn_Frame = Instance.new("Frame")
                Btn_Frame.Size = UDim2.new(1, 0, 0, 22)
                Btn_Frame.BackgroundTransparency = 1
                Btn_Frame.Parent = Target_Container

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, -16, 1, 0)
                Btn.Position = UDim2.new(0, 8, 0, 0)
                Btn.BackgroundColor3 = Colors.Section_Bg
                Btn.BackgroundTransparency = 0.21847
                Btn.Text = Name
                Btn.TextColor3 = Colors.Text_Dark
                Btn.TextSize = 11
                Btn.Font = Main_Font
                Btn.AutoButtonColor = false
                Btn.Parent = Btn_Frame
                
                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 3)
                Btn_Corner.Parent = Btn
                
                local Btn_Stroke = Instance.new("UIStroke")
                Btn_Stroke.Color = Colors.Border
                Btn_Stroke.Parent = Btn

                Btn.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate(Btn, {BackgroundColor3 = Colors.Element_Bg}, 0.219834)
                    Animate(Btn_Stroke, {Color = Colors.Border_Light}, 0.219834)
                    Animate(Btn, {TextColor3 = Colors.Text_White}, 0.219834)
                end)
                Btn.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate(Btn, {BackgroundColor3 = Colors.Section_Bg}, 0.219834)
                    Animate(Btn_Stroke, {Color = Colors.Border}, 0.219834)
                    Animate(Btn, {TextColor3 = Colors.Text_Dark}, 0.219834)
                end)
                Btn.MouseButton1Down:Connect(function() Animate(Btn, {Size = UDim2.new(0.96, -16, 0.85, 0), Position = UDim2.new(0.02, 8, 0.075, 0)}, 0.124538) end)
                Btn.MouseButton1Up:Connect(function()
                    Animate(Btn, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0)}, 0.124538)
                    if Callback then task.spawn(Callback) end
                end)
            end

            function Elements:Module_Create(Name, Flag, Desc, Default, Tooltip, Callback)
                Nixware_Premium_Api.Flags[Flag] = Default or false

                local Mod_Frame = Instance.new("Frame")
                Mod_Frame.Size = UDim2.new(1, 0, 0, 46)
                Mod_Frame.BackgroundTransparency = 1
                Mod_Frame.ClipsDescendants = true
                Mod_Frame.Parent = Target_Container

                local Mod_Btn = Instance.new("TextButton")
                Mod_Btn.Size = UDim2.new(1, -4, 0, 44)
                Mod_Btn.Position = UDim2.new(0, 2, 0, 0)
                Mod_Btn.BackgroundColor3 = Colors.Element_Bg
                Mod_Btn.BackgroundTransparency = 0.21847
                Mod_Btn.Text = ""
                Mod_Btn.AutoButtonColor = false
                Mod_Btn.Parent = Mod_Frame
                
                local Btn_Corner = Instance.new("UICorner")
                Btn_Corner.CornerRadius = UDim.new(0, 6)
                Btn_Corner.Parent = Mod_Btn
                
                local Btn_Stroke = Instance.new("UIStroke")
                Btn_Stroke.Color = Nixware_Premium_Api.Flags[Flag] and Colors.Accent or Colors.Border
                Btn_Stroke.Parent = Mod_Btn

                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 16, 0, 16)
                Box.Position = UDim2.new(0, 14, 0.5, -8)
                Box.BackgroundColor3 = Nixware_Premium_Api.Flags[Flag] and Colors.Accent or Colors.Section_Bg
                Box.BackgroundTransparency = 0.21847
                Box.Parent = Mod_Btn
                
                local Box_Corner = Instance.new("UICorner")
                Box_Corner.CornerRadius = UDim.new(0, 4)
                Box_Corner.Parent = Box
                
                local Box_Stroke = Instance.new("UIStroke")
                Box_Stroke.Color = Colors.Border
                Box_Stroke.Parent = Box

                local Text = Instance.new("TextLabel")
                Text.Size = UDim2.new(1, -45, 0, 16)
                Text.Position = UDim2.new(0, 40, 0, 6)
                Text.BackgroundTransparency = 1
                Text.Text = Name
                Text.TextColor3 = Nixware_Premium_Api.Flags[Flag] and Colors.Text_White or Colors.Text_Dark
                Text.TextSize = 13
                Text.Font = Bold_Font
                Text.TextXAlignment = Enum.TextXAlignment.Left
                Text.Parent = Mod_Btn

                local Desc_Lbl = Instance.new("TextLabel")
                Desc_Lbl.Size = UDim2.new(1, -45, 0, 14)
                Desc_Lbl.Position = UDim2.new(0, 40, 0, 22)
                Desc_Lbl.BackgroundTransparency = 1
                Desc_Lbl.Text = Desc
                Desc_Lbl.TextColor3 = Colors.Text_Dark
                Desc_Lbl.TextSize = 11
                Desc_Lbl.Font = Main_Font
                Desc_Lbl.TextXAlignment = Enum.TextXAlignment.Left
                Desc_Lbl.Parent = Mod_Btn

                local Arrow_Icon = Instance.new("ImageLabel")
                Arrow_Icon.Size = UDim2.new(0, 14, 0, 14)
                Arrow_Icon.Position = UDim2.new(1, -22, 0, 14)
                Arrow_Icon.BackgroundTransparency = 1
                Arrow_Icon.Image = "rbxassetid://6031090656"
                Arrow_Icon.ImageColor3 = Nixware_Premium_Api.Flags[Flag] and Colors.Accent or Colors.Text_Dark
                Arrow_Icon.Rotation = Nixware_Premium_Api.Flags[Flag] and 180 or 0
                Arrow_Icon.Parent = Mod_Btn

                local Mod_Content = Instance.new("Frame")
                Mod_Content.Size = UDim2.new(1, -16, 0, 0)
                Mod_Content.Position = UDim2.new(0, 12, 0, 48)
                Mod_Content.BackgroundTransparency = 1
                Mod_Content.Parent = Mod_Frame

                local Layout = Instance.new("UIListLayout")
                Layout.Padding = UDim.new(0, 8)
                Layout.Parent = Mod_Content

                local function Sync_Size()
                    if Nixware_Premium_Api.Flags[Flag] then
                        Animate(Mod_Frame, {Size = UDim2.new(1, 0, 0, 46 + Layout.AbsoluteContentSize.Y + 8)}, 0.287413)
                        Animate(Arrow_Icon, {Rotation = 180, ImageColor3 = Colors.Accent}, 0.287413)
                    else
                        Animate(Mod_Frame, {Size = UDim2.new(1, 0, 0, 46)}, 0.287413)
                        Animate(Arrow_Icon, {Rotation = 0, ImageColor3 = Colors.Text_Dark}, 0.287413)
                    end
                end

                Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Nixware_Premium_Api.Flags[Flag] then Sync_Size() end
                end)

                Mod_Btn.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Nixware_Premium_Api.Flags[Flag] then Animate(Btn_Stroke, {Color = Colors.Border_Light}, 0.218461) end
                end)
                Mod_Btn.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Nixware_Premium_Api.Flags[Flag] then Animate(Btn_Stroke, {Color = Colors.Border}, 0.218461) end
                end)

                Mod_Btn.MouseButton1Click:Connect(function()
                    Nixware_Premium_Api.Flags[Flag] = not Nixware_Premium_Api.Flags[Flag]
                    local S = Nixware_Premium_Api.Flags[Flag]
                    Animate(Box, {BackgroundColor3 = S and Colors.Accent or Colors.Section_Bg}, 0.218461)
                    Animate(Btn_Stroke, {Color = S and Colors.Accent or Colors.Border}, 0.218461)
                    Animate(Text, {TextColor3 = S and Colors.Text_White or Colors.Text_Dark}, 0.218461)
                    Sync_Size()
                    if Callback then task.spawn(Callback, S) end
                end)

                return Element_Injector(Mod_Content)
            end

            return Elements
        end

        local Section_Api = {}

        function Section_Api:Section_Create(Side_Str, Section_Title_Str)
            local Sect_Bg = Instance.new("Frame")
            Sect_Bg.Size = UDim2.new(1, 0, 0, 40)
            Sect_Bg.BackgroundColor3 = Colors.Section_Bg
            Sect_Bg.BackgroundTransparency = 0.21847
            Sect_Bg.Parent = (Side_Str == "Left") and Left_Col or Right_Col
            
            local Sect_Corner = Instance.new("UICorner")
            Sect_Corner.CornerRadius = UDim.new(0, 6)
            Sect_Corner.Parent = Sect_Bg
            
            local Sect_Stroke = Instance.new("UIStroke")
            Sect_Stroke.Color = Colors.Border
            Sect_Stroke.Parent = Sect_Bg

            local Sect_Header = Instance.new("Frame")
            Sect_Header.Size = UDim2.new(1, 0, 0, 26)
            Sect_Header.BackgroundTransparency = 1
            Sect_Header.Parent = Sect_Bg

            local Sect_Label = Instance.new("TextLabel")
            Sect_Label.Size = UDim2.new(1, -20, 1, 0)
            Sect_Label.Position = UDim2.new(0, 10, 0, 0)
            Sect_Label.BackgroundTransparency = 1
            Sect_Label.Text = Section_Title_Str
            Sect_Label.TextColor3 = Colors.Text_White
            Sect_Label.TextSize = 12
            Sect_Label.Font = Bold_Font
            Sect_Label.TextXAlignment = Enum.TextXAlignment.Left
            Sect_Label.Parent = Sect_Header

            local Sect_Line = Instance.new("Frame")
            Sect_Line.Size = UDim2.new(1, -20, 0, 1)
            Sect_Line.Position = UDim2.new(0, 10, 1, 0)
            Sect_Line.BackgroundColor3 = Colors.Border
            Sect_Line.BorderSizePixel = 0
            Sect_Line.Parent = Sect_Header

            local Sect_Content = Instance.new("Frame")
            Sect_Content.Size = UDim2.new(1, -16, 1, -34)
            Sect_Content.Position = UDim2.new(0, 8, 0, 32)
            Sect_Content.BackgroundTransparency = 1
            Sect_Content.Parent = Sect_Bg

            local Layout = Instance.new("UIListLayout")
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Padding = UDim.new(0, 8)
            Layout.Parent = Sect_Content

            Run_Service.RenderStepped:Connect(function()
                Sect_Bg.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y + 44)
            end)

            return Element_Injector(Sect_Content)
        end

        return Section_Api
    end

    return Window_Context
end

return Nixware_Premium_Api
