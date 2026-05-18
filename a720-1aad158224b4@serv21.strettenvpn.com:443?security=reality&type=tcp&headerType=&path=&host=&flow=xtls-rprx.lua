local User_Input_Service = game:GetService("UserInputService")
local Tween_Service = game:GetService("TweenService")
local Run_Service = game:GetService("RunService")
local Players_Service = game:GetService("Players")
local Http_Service = game:GetService("HttpService")
local Stats_Service = game:GetService("Stats")
local Is_Folder = isfolder or function() return false end
local Make_Folder = makefolder or function() end
local Is_File = isfile or function() return false end
local Read_File = readfile or function() return "" end
local Write_File = writefile or function() end
local List_Files = listfiles or function() return {} end
local Delete_File = delfile or function() end
local Core_Gui
pcall(function() Core_Gui = game:GetService("CoreGui") end)
local Local_Player = Players_Service.LocalPlayer
local Library_Table = {
    Flags = {},
    Signals = {},
    Defaults = {},
    Is_Open = true,
    Keybind_List = nil,
    Show_Keybinds = true,
    Screen_Gui = nil,
    Connections = {},
    Elements = {},
    Is_Unsaved = false,
    Auto_Save_Enabled = true
}
local Config_Table = {
    Name = "PHANTOM HUB",
    Keybind = Enum.KeyCode.LeftControl,
    Duration = 0.3,
    Font_Main = Enum.Font.GothamMedium,
    Font_Bold = Enum.Font.GothamBold,
    Config_Folder = "PhantomHub"
}
if not Is_Folder(Config_Table.Config_Folder) then Make_Folder(Config_Table.Config_Folder) end
local Theme_Table = {
    Background = Color3.fromHex("#080505"),
    Sidebar = Color3.fromHex("#0c0707"),
    Container = Color3.fromHex("#140b0b"),
    Section = Color3.fromHex("#1a0e0e"),
    Accent = Color3.fromHex("#ff1a1a"),
    Text = Color3.fromHex("#ffffff"),
    Text_Dark = Color3.fromHex("#997373"),
    Stroke = Color3.fromHex("#2e1717"),
    Success = Color3.fromHex("#00ff88"),
    Danger = Color3.fromHex("#ff4444")
}
local Theme_Registry = {}
setmetatable(Theme_Registry, { __mode = "k" })
local function Register_Theme(Instance_Obj, Prop_Type)
    Theme_Registry[Instance_Obj] = Prop_Type
    return Instance_Obj
end
function Library_Table:Update_Theme(New_Color)
    Theme_Table.Accent = New_Color
    for Instance_Obj, Prop_Type in pairs(Theme_Registry) do
        if Instance_Obj and Instance_Obj.Parent then
            if Prop_Type == "TextColor" then Instance_Obj.TextColor3 = New_Color
            elseif Prop_Type == "BackgroundColor" then Instance_Obj.BackgroundColor3 = New_Color
            elseif Prop_Type == "BorderColor" then
                if Instance_Obj:IsA("UIStroke") then Instance_Obj.Color = New_Color else Instance_Obj.BorderColor3 = New_Color end
            elseif Prop_Type == "ImageColor" then Instance_Obj.ImageColor3 = New_Color
            elseif Prop_Type == "ScrollBar" then Instance_Obj.ScrollBarImageColor3 = New_Color
            end
        end
    end
end
local function Get_Parent()
    if Core_Gui then return Core_Gui end
    return Local_Player:WaitForChild("PlayerGui")
end
local function Create_Tween(Object, Props, Time_Val, Style, Direction)
    Time_Val = Time_Val or Config_Table.Duration
    Style = Style or Enum.EasingStyle.Quart
    Direction = Direction or Enum.EasingDirection.Out
    local Tween_Obj = Tween_Service:Create(Object, TweenInfo.new(Time_Val, Style, Direction), Props)
    Tween_Obj:Play()
    return Tween_Obj
end
local function Create_Corner(Parent_Obj, Radius_Val)
    local Corner_Obj = Instance.new("UICorner")
    Corner_Obj.CornerRadius = UDim.new(0, Radius_Val)
    Corner_Obj.Parent = Parent_Obj
    return Corner_Obj
end
local function Create_Stroke(Parent_Obj, Color_Val, Thickness_Val, Transparency_Val)
    local Stroke_Obj = Instance.new("UIStroke")
    Stroke_Obj.Color = Color_Val or Theme_Table.Stroke
    Stroke_Obj.Thickness = Thickness_Val or 1
    Stroke_Obj.Transparency = Transparency_Val or 0
    Stroke_Obj.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke_Obj.Parent = Parent_Obj
    return Stroke_Obj
end
local function Round_To_Increment(Value, Increment)
    if Increment <= 0 then return Value end
    return math.round(Value / Increment) * Increment
end
local function Format_Number(Value, Increment)
    if Increment >= 1 then return tostring(math.round(Value)) end
    local String_Val = tostring(Increment)
    local Dot_Pos = string.find(String_Val, "%.")
    if Dot_Pos then
        local Decimals = #String_Val - Dot_Pos
        return string.format("%." .. Decimals .. "f", Value)
    end
    return tostring(Value)
end
local function Make_Draggable(Drag_Area, Frame_Obj, On_Drag_Callback)
    local Is_Dragging = false
    local Drag_Start_Pos, Start_Frame_Pos
    local Conn_1 = Drag_Area.InputBegan:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging = true
            Drag_Start_Pos = Input_Obj.Position
            Start_Frame_Pos = Frame_Obj.Position
        end
    end)
    local Conn_2 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            if Is_Dragging then
                Is_Dragging = false
                if On_Drag_Callback then On_Drag_Callback(false) end
            end
        end
    end)
    local Conn_3 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            if Is_Dragging then
                local Delta = Input_Obj.Position - Drag_Start_Pos
                Frame_Obj.Position = UDim2.new(Start_Frame_Pos.X.Scale, Start_Frame_Pos.X.Offset + Delta.X, Start_Frame_Pos.Y.Scale, Start_Frame_Pos.Y.Offset + Delta.Y)
                if On_Drag_Callback then On_Drag_Callback(true) end
            end
        end
    end)
    table.insert(Library_Table.Connections, Conn_1)
    table.insert(Library_Table.Connections, Conn_2)
    table.insert(Library_Table.Connections, Conn_3)
    return function() return Is_Dragging end
end
local function Make_Resizable(Resize_Btn, Frame_Obj, Min_Size)
    local Is_Dragging = false
    local Drag_Start_Pos, Start_Frame_Size, Start_Frame_Pos, Scale_Mult
    local Conn_1 = Resize_Btn.InputBegan:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging = true
            Drag_Start_Pos = Input_Obj.Position
            Start_Frame_Size = Frame_Obj.Size
            Start_Frame_Pos = Frame_Obj.Position
            local Scale_Obj = Frame_Obj:FindFirstChildWhichIsA("UIScale")
            Scale_Mult = Scale_Obj and Scale_Obj.Scale or 1
            if Scale_Mult <= 0 then Scale_Mult = 1 end
        end
    end)
    local Conn_2 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging = false
        end
    end)
    local Conn_3 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            if Is_Dragging then
                local Delta = Input_Obj.Position - Drag_Start_Pos
                local New_X = math.max(Min_Size.X, Start_Frame_Size.X.Offset + (Delta.X / Scale_Mult))
                local New_Y = math.max(Min_Size.Y, Start_Frame_Size.Y.Offset + (Delta.Y / Scale_Mult))
                local Diff_X = (New_X - Start_Frame_Size.X.Offset) * Scale_Mult
                local Diff_Y = (New_Y - Start_Frame_Size.Y.Offset) * Scale_Mult
                Frame_Obj.Size = UDim2.new(0, New_X, 0, New_Y)
                Frame_Obj.Position = UDim2.new(Start_Frame_Pos.X.Scale, Start_Frame_Pos.X.Offset + (Diff_X / 2), Start_Frame_Pos.Y.Scale, Start_Frame_Pos.Y.Offset + (Diff_Y / 2))
            end
        end
    end)
    table.insert(Library_Table.Connections, Conn_1)
    table.insert(Library_Table.Connections, Conn_2)
    table.insert(Library_Table.Connections, Conn_3)
end
local function Get_Base_Scale()
    local Viewport_Size = workspace.CurrentCamera.ViewportSize
    if Viewport_Size.X < 1 or Viewport_Size.Y < 1 then return 1 end
    local Scale_X = Viewport_Size.X / 800
    local Scale_Y = Viewport_Size.Y / 500
    local Scale_Val = math.min(Scale_X, Scale_Y)
    if Scale_Val < 1 then return math.clamp(Scale_Val * 0.95, 0.4, 1) end
    return 1
end
function Library_Table:Unload_Library()
    for _, Conn_Obj in ipairs(Library_Table.Connections) do pcall(function() Conn_Obj:Disconnect() end) end
    Library_Table.Connections = {}
    if Library_Table.Screen_Gui then pcall(function() Library_Table.Screen_Gui:Destroy() end) Library_Table.Screen_Gui = nil end
    if Library_Table.Keybind_List then pcall(function() Library_Table.Keybind_List.Screen:Destroy() end) Library_Table.Keybind_List = nil end
    for _, Gui_Element in pairs(Get_Parent():GetChildren()) do
        if Gui_Element.Name == Config_Table.Name or Gui_Element.Name == "PrismaKeybinds" or Gui_Element.Name == "PhantomNotifications" or Gui_Element.Name == "PhantomWatermark" or Gui_Element.Name == "PhantomTooltip" or Gui_Element.Name == "PhantomMiniButton" then
            pcall(function() Gui_Element:Destroy() end)
        end
    end
end
function Library_Table:Get_Configs()
    local Configs_List = {}
    if Is_Folder(Config_Table.Config_Folder) then
        local Files = List_Files(Config_Table.Config_Folder)
        for _, File_Path in ipairs(Files) do
            if string.sub(File_Path, -5) == ".json" then
                local Config_Name = string.match(string.gsub(File_Path, "\\", "/"), "([^/]+)%.json$") or File_Path
                if Config_Name ~= "_autosave" then table.insert(Configs_List, Config_Name) end
            end
        end
    end
    return Configs_List
end
local Ignored_Flags = {
    ConfigSelectorFlag = true,
    MenuAccentColor = true,
    KeybindListToggle = true,
}
local function Serialize_Config_Value(Value)
    if typeof(Value) == "Color3" then return {Type = "Color3", Hex = Value:ToHex()}
    elseif typeof(Value) == "EnumItem" then
        local Enum_Name = tostring(Value.EnumType):match("Enum%.(.+)") or tostring(Value.EnumType)
        return {Type = "EnumItem", EnumType = Enum_Name, Name = Value.Name}
    elseif type(Value) == "table" then
        local Serialized_Table = {}
        for Table_Key, Table_Val in pairs(Value) do Serialized_Table[Table_Key] = Serialize_Config_Value(Table_Val) end
        return {Type = "Table", Value = Serialized_Table}
    end
    return Value
end
local function Deserialize_Config_Value(Value)
    if type(Value) == "table" then
        if Value.Type == "Color3" then
            local Color_Obj = Color3.new(1, 1, 1)
            pcall(function() Color_Obj = Color3.fromHex(Value.Hex) end)
            return Color_Obj
        elseif Value.Type == "EnumItem" then
            local Enum_Obj
            pcall(function() Enum_Obj = Enum[Value.EnumType][Value.Name] end)
            return Enum_Obj
        elseif Value.Type == "Table" then
            local Deserialized_Table = {}
            if type(Value.Value) == "table" then
                for Table_Key, Table_Val in pairs(Value.Value) do Deserialized_Table[Table_Key] = Deserialize_Config_Value(Table_Val) end
            end
            return Deserialized_Table
        end
    end
    return Value
end
function Library_Table:Save_Config(Config_Name)
    if not Config_Name or Config_Name == "" then return false end
    local Save_Flags = {}
    for Flag_Key, Flag_Val in pairs(Library_Table.Flags) do
        if Ignored_Flags[Flag_Key] then continue end
        Save_Flags[Flag_Key] = Serialize_Config_Value(Flag_Val)
    end
    local Is_Ok, Json_Data = pcall(Http_Service.JSONEncode, Http_Service, Save_Flags)
    if Is_Ok then
        pcall(function() Write_File(Config_Table.Config_Folder .. "/" .. Config_Name .. ".json", Json_Data) end)
        return true
    end
    return false
end
function Library_Table:Load_Config(Config_Name)
    if not Config_Name or Config_Name == "" then return false end
    local File_Path = Config_Table.Config_Folder .. "/" .. Config_Name .. ".json"
    if not Is_File(File_Path) then return false end
    local File_Content = Read_File(File_Path)
    local Is_Success, Decoded_Data = pcall(Http_Service.JSONDecode, Http_Service, File_Content)
    if Is_Success and type(Decoded_Data) == "table" then
        for Flag_Key, Flag_Val in pairs(Decoded_Data) do
            if Ignored_Flags[Flag_Key] then continue end
            Library_Table.Flags[Flag_Key] = Deserialize_Config_Value(Flag_Val)
        end
        for Flag_Key, Flag_Val in pairs(Library_Table.Flags) do
            if Ignored_Flags[Flag_Key] then continue end
            if Decoded_Data[Flag_Key] ~= nil and Library_Table.Signals[Flag_Key] then
                task.spawn(Library_Table.Signals[Flag_Key], Flag_Val)
            end
        end
        return true
    end
    return false
end
function Library_Table:Delete_Config(Config_Name)
    if not Config_Name or Config_Name == "" then return false end
    local File_Path = Config_Table.Config_Folder .. "/" .. Config_Name .. ".json"
    if Is_File(File_Path) then
        pcall(function() Delete_File(File_Path) end)
        return true
    end
    return false
end
function Library_Table:Config_Exists(Config_Name)
    if not Config_Name or Config_Name == "" then return false end
    return Is_File(Config_Table.Config_Folder .. "/" .. Config_Name .. ".json")
end
local Tooltip_Gui = Instance.new("ScreenGui")
Tooltip_Gui.Name = "PhantomTooltip"
Tooltip_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Tooltip_Gui.Parent = Get_Parent()
local Tooltip_Label = Instance.new("TextLabel")
Tooltip_Label.BackgroundTransparency = 0.05
Tooltip_Label.BackgroundColor3 = Theme_Table.Container
Tooltip_Label.TextColor3 = Theme_Table.Text
Tooltip_Label.Font = Config_Table.Font_Main
Tooltip_Label.TextSize = 12
Tooltip_Label.Visible = false
Tooltip_Label.Parent = Tooltip_Gui
Tooltip_Label.ZIndex = 1000
Create_Corner(Tooltip_Label, 4)
Create_Stroke(Tooltip_Label, Theme_Table.Stroke, 1)
local function Apply_Tooltip(Gui_Obj, Tooltip_Text)
    if not Tooltip_Text or Tooltip_Text == "" then return end
    local Is_Hovered = false
    local Conn_1 = Gui_Obj.MouseEnter:Connect(function()
        Is_Hovered = true
        task.delay(0.5, function()
            if Is_Hovered and Library_Table.Is_Open then
                Tooltip_Label.Text = " " .. Tooltip_Text .. " "
                Tooltip_Label.Size = UDim2.new(0, Tooltip_Label.TextBounds.X + 10, 0, 20)
                local Mouse_Pos = User_Input_Service:GetMouseLocation()
                Tooltip_Label.Position = UDim2.new(0, Mouse_Pos.X + 10, 0, Mouse_Pos.Y - 25)
                Tooltip_Label.Visible = true
            end
        end)
    end)
    local Conn_2 = Gui_Obj.MouseMoved:Connect(function()
        if Tooltip_Label.Visible then
            local Mouse_Pos = User_Input_Service:GetMouseLocation()
            Tooltip_Label.Position = UDim2.new(0, Mouse_Pos.X + 10, 0, Mouse_Pos.Y - 25)
        end
    end)
    local Conn_3 = Gui_Obj.MouseLeave:Connect(function()
        Is_Hovered = false
        Tooltip_Label.Visible = false
    end)
    table.insert(Library_Table.Connections, Conn_1)
    table.insert(Library_Table.Connections, Conn_2)
    table.insert(Library_Table.Connections, Conn_3)
end
function Library_Table:Notify_User(Title_Str, Text_Str, Duration_Val)
    local Notif_Gui = Get_Parent():FindFirstChild("PhantomNotifications")
    if not Notif_Gui then
        Notif_Gui = Instance.new("ScreenGui")
        Notif_Gui.Name = "PhantomNotifications"
        Notif_Gui.Parent = Get_Parent()
        local Notif_Container = Instance.new("Frame")
        Notif_Container.Name = "Container"
        Notif_Container.Size = UDim2.new(0, 250, 1, -20)
        Notif_Container.Position = UDim2.new(1, -270, 0, 10)
        Notif_Container.BackgroundTransparency = 1
        Notif_Container.Parent = Notif_Gui
        local Layout_Obj = Instance.new("UIListLayout")
        Layout_Obj.SortOrder = Enum.SortOrder.LayoutOrder
        Layout_Obj.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout_Obj.Padding = UDim.new(0, 10)
        Layout_Obj.Parent = Notif_Container
    end
    local Notif_Frame = Instance.new("Frame")
    Notif_Frame.Size = UDim2.new(1, 0, 0, 60)
    Notif_Frame.BackgroundColor3 = Theme_Table.Background
    Notif_Frame.BackgroundTransparency = 0.1
    Notif_Frame.Position = UDim2.new(1, 300, 0, 0)
    Notif_Frame.Parent = Notif_Gui.Container
    Create_Corner(Notif_Frame, 6)
    Create_Stroke(Notif_Frame, Theme_Table.Stroke, 1)
    local Noise_Img = Instance.new("ImageLabel")
    Noise_Img.Size = UDim2.new(1, 0, 1, 0)
    Noise_Img.BackgroundTransparency = 1
    Noise_Img.Image = "rbxassetid://9968344105"
    Noise_Img.ImageTransparency = 0.9
    Noise_Img.ScaleType = Enum.ScaleType.Tile
    Noise_Img.TileSize = UDim2.new(0, 100, 0, 100)
    Noise_Img.Parent = Notif_Frame
    Create_Corner(Noise_Img, 6)
    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -10, 0, 20)
    Title_Label.Position = UDim2.new(0, 10, 0, 5)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Title_Str
    Title_Label.TextColor3 = Theme_Table.Accent
    Title_Label.Font = Config_Table.Font_Bold
    Title_Label.TextSize = 13
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.Parent = Notif_Frame
    Register_Theme(Title_Label, "TextColor")
    local Text_Label = Instance.new("TextLabel")
    Text_Label.Size = UDim2.new(1, -20, 0, 20)
    Text_Label.Position = UDim2.new(0, 10, 0, 25)
    Text_Label.BackgroundTransparency = 1
    Text_Label.Text = Text_Str
    Text_Label.TextColor3 = Theme_Table.Text
    Text_Label.Font = Config_Table.Font_Main
    Text_Label.TextSize = 12
    Text_Label.TextXAlignment = Enum.TextXAlignment.Left
    Text_Label.Parent = Notif_Frame
    local Timebar_Bg = Instance.new("Frame")
    Timebar_Bg.Size = UDim2.new(1, 0, 0, 2)
    Timebar_Bg.Position = UDim2.new(0, 0, 1, -2)
    Timebar_Bg.BackgroundColor3 = Theme_Table.Container
    Timebar_Bg.BorderSizePixel = 0
    Timebar_Bg.Parent = Notif_Frame
    Create_Corner(Timebar_Bg, 2)
    local Timebar_Fill = Instance.new("Frame")
    Timebar_Fill.Size = UDim2.new(1, 0, 1, 0)
    Timebar_Fill.BackgroundColor3 = Theme_Table.Accent
    Timebar_Fill.BorderSizePixel = 0
    Timebar_Fill.Parent = Timebar_Bg
    Create_Corner(Timebar_Fill, 2)
    Register_Theme(Timebar_Fill, "BackgroundColor")
    Create_Tween(Notif_Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    Create_Tween(Timebar_Fill, {Size = UDim2.new(0, 0, 1, 0)}, Duration_Val, Enum.EasingStyle.Linear)
    task.delay(Duration_Val, function()
        Create_Tween(Notif_Frame, {Position = UDim2.new(1, 300, 0, 0)}, 0.4).Completed:Wait()
        Notif_Frame:Destroy()
    end)
end
function Library_Table:Init_Watermark()
    local Watermark_Gui = Instance.new("ScreenGui")
    Watermark_Gui.Name = "PhantomWatermark"
    Watermark_Gui.Parent = Get_Parent()
    Watermark_Gui.IgnoreGuiInset = true
    Watermark_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local WM_Frame = Instance.new("Frame")
    WM_Frame.Size = UDim2.new(0, 0, 0, 26)
    WM_Frame.Position = UDim2.new(1, -20, 0, 10)
    WM_Frame.AnchorPoint = Vector2.new(1, 0)
    WM_Frame.BackgroundColor3 = Theme_Table.Background
    WM_Frame.BackgroundTransparency = 0.05
    WM_Frame.Parent = Watermark_Gui
    Create_Corner(WM_Frame, 4)
    Create_Stroke(WM_Frame, Theme_Table.Stroke, 1)
    local WM_Glow = Create_Stroke(WM_Frame, Theme_Table.Accent, 2, 0.8)
    Register_Theme(WM_Glow, "BorderColor")
    local Accent_Line = Instance.new("Frame")
    Accent_Line.Size = UDim2.new(1, 0, 0, 2)
    Accent_Line.Position = UDim2.new(0, 0, 0, 0)
    Accent_Line.BackgroundColor3 = Theme_Table.Accent
    Accent_Line.BorderSizePixel = 0
    Accent_Line.Parent = WM_Frame
    Create_Corner(Accent_Line, 2)
    Register_Theme(Accent_Line, "BackgroundColor")
    local WM_Noise = Instance.new("ImageLabel")
    WM_Noise.Size = UDim2.new(1, 0, 1, 0)
    WM_Noise.BackgroundTransparency = 1
    WM_Noise.Image = "rbxassetid://9968344105"
    WM_Noise.ImageTransparency = 0.95
    WM_Noise.ScaleType = Enum.ScaleType.Tile
    WM_Noise.TileSize = UDim2.new(0, 100, 0, 100)
    WM_Noise.Parent = WM_Frame
    Create_Corner(WM_Noise, 4)
    local WM_Label = Instance.new("TextLabel")
    WM_Label.Size = UDim2.new(1, 0, 1, 0)
    WM_Label.BackgroundTransparency = 1
    WM_Label.Font = Config_Table.Font_Bold
    WM_Label.TextSize = 12
    WM_Label.TextColor3 = Theme_Table.Text
    WM_Label.RichText = true
    WM_Label.Parent = WM_Frame
    local Last_Update = 0
    local Frames_Count = 0
    local Run_Conn = Run_Service.RenderStepped:Connect(function()
        Frames_Count = Frames_Count + 1
        local Now_Time = os.clock()
        if Now_Time - Last_Update >= 1 then
            local FPS_Val = Frames_Count
            Frames_Count = 0
            Last_Update = Now_Time
            local Ping_Val = "0"
            pcall(function()
                local Stats_Str = Stats_Service.Network.ServerStatsItem["Data Ping"]:GetValueString()
                Ping_Val = Stats_Str:match("%d+") or "0"
            end)
            local Time_Str = os.date("%H:%M:%S")
            local Display_Text = string.format(" <font color='#%s'>%s</font> | FPS: %d | Ping: %sms | %s ", Theme_Table.Accent:ToHex(), Config_Table.Name, FPS_Val, Ping_Val, Time_Str)
            WM_Label.Text = Display_Text
            local Bounds_X = WM_Label.TextBounds.X + 20
            Create_Tween(WM_Frame, {Size = UDim2.new(0, Bounds_X, 0, 26)}, 0.1)
        end
    end)
    table.insert(Library_Table.Connections, Run_Conn)
end
function Library_Table:Create_Keybind_List()
    if Library_Table.Keybind_List then return end
    local KB_Screen = Instance.new("ScreenGui")
    KB_Screen.Name = "PrismaKeybinds"
    KB_Screen.Parent = Get_Parent()
    KB_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local KB_Frame = Instance.new("Frame")
    KB_Frame.Size = UDim2.new(0, 180, 0, 30)
    KB_Frame.Position = UDim2.new(0.01, 0, 0.4, 0)
    KB_Frame.BackgroundColor3 = Theme_Table.Background
    KB_Frame.BackgroundTransparency = 0.1
    KB_Frame.Parent = KB_Screen
    KB_Frame.Active = true
    KB_Frame.ClipsDescendants = true
    Create_Corner(KB_Frame, 4)
    Create_Stroke(KB_Frame, Theme_Table.Stroke, 1, 0)
    Make_Draggable(KB_Frame, KB_Frame)
    local KB_Noise = Instance.new("ImageLabel")
    KB_Noise.Size = UDim2.new(1, 0, 1, 0)
    KB_Noise.BackgroundTransparency = 1
    KB_Noise.Image = "rbxassetid://9968344105"
    KB_Noise.ImageTransparency = 0.9
    KB_Noise.ScaleType = Enum.ScaleType.Tile
    KB_Noise.TileSize = UDim2.new(0, 100, 0, 100)
    KB_Noise.Parent = KB_Frame
    Create_Corner(KB_Noise, 4)
    local KB_Header = Instance.new("Frame")
    KB_Header.Size = UDim2.new(1, 0, 0, 24)
    KB_Header.BackgroundColor3 = Theme_Table.Sidebar
    KB_Header.Parent = KB_Frame
    Create_Corner(KB_Header, 4)
    local KB_Title = Instance.new("TextLabel")
    KB_Title.Size = UDim2.new(1, 0, 1, 0)
    KB_Title.BackgroundTransparency = 1
    KB_Title.Text = "Keybinds"
    KB_Title.TextColor3 = Theme_Table.Accent
    KB_Title.Font = Config_Table.Font_Bold
    KB_Title.TextSize = 12
    KB_Title.Parent = KB_Header
    Register_Theme(KB_Title, "TextColor")
    local KB_Container = Instance.new("Frame")
    KB_Container.Size = UDim2.new(1, 0, 0, 0)
    KB_Container.Position = UDim2.new(0, 0, 0, 26)
    KB_Container.BackgroundTransparency = 1
    KB_Container.Parent = KB_Frame
    local KB_Layout = Instance.new("UIListLayout")
    KB_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    KB_Layout.Parent = KB_Container
    local Conn_1 = KB_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        KB_Frame.Size = UDim2.new(0, 180, 0, KB_Layout.AbsoluteContentSize.Y + 30)
    end)
    table.insert(Library_Table.Connections, Conn_1)
    Library_Table.Keybind_List = {Frame = KB_Frame, Container = KB_Container, Screen = KB_Screen}
    KB_Frame.Visible = false
end
function Library_Table:Update_Keybind_List(Item_Name, Item_Key, Is_Active, Item_Mode)
    if not Library_Table.Keybind_List then Library_Table:Create_Keybind_List() end
    local Existing_Item = Library_Table.Keybind_List.Container:FindFirstChild(Item_Name)
    if Is_Active and Item_Key ~= "None" and Item_Key ~= "Unknown" and Item_Mode ~= "Always" then
        if not Existing_Item then
            local New_Item = Instance.new("Frame")
            New_Item.Name = Item_Name
            New_Item.Size = UDim2.new(1, 0, 0, 20)
            New_Item.BackgroundTransparency = 1
            New_Item.Parent = Library_Table.Keybind_List.Container
            local Name_Label = Instance.new("TextLabel")
            Name_Label.Name = "LName"
            Name_Label.Size = UDim2.new(0.6, 0, 1, 0)
            Name_Label.Position = UDim2.new(0, 5, 0, 0)
            Name_Label.BackgroundTransparency = 1
            Name_Label.Text = Item_Name
            Name_Label.TextColor3 = Theme_Table.Text
            Name_Label.Font = Config_Table.Font_Main
            Name_Label.TextSize = 12
            Name_Label.TextXAlignment = Enum.TextXAlignment.Left
            Name_Label.Parent = New_Item
            local Key_Label = Instance.new("TextLabel")
            Key_Label.Name = "LKey"
            Key_Label.Size = UDim2.new(0.4, -5, 1, 0)
            Key_Label.Position = UDim2.new(0.6, 0, 0, 0)
            Key_Label.BackgroundTransparency = 1
            Key_Label.Text = "[" .. tostring(Item_Key) .. "]"
            Key_Label.TextColor3 = Theme_Table.Text_Dark
            Key_Label.Font = Config_Table.Font_Main
            Key_Label.TextSize = 12
            Key_Label.TextXAlignment = Enum.TextXAlignment.Right
            Key_Label.Parent = New_Item
        else
            local Key_Label = Existing_Item:FindFirstChild("LKey")
            if Key_Label then Key_Label.Text = "[" .. tostring(Item_Key) .. "]" end
        end
    else
        if Existing_Item then Existing_Item:Destroy() end
    end
    if Library_Table.Show_Keybinds then
        Library_Table.Keybind_List.Frame.Visible = (#Library_Table.Keybind_List.Container:GetChildren() > 1)
    else
        Library_Table.Keybind_List.Frame.Visible = false
    end
end
local function Create_Dropdown_Element(DD_Text, DD_Flag, Options_List, Default_Val, Tooltip_Text, Callback_Func, Parent_Frame, Section_Ref, Is_Multi, Custom_Parent)
    local Selected_Val = Library_Table.Flags[DD_Flag]
    if Selected_Val == nil then
        if Is_Multi then
            if type(Default_Val) ~= "table" then Selected_Val = {Default_Val} else Selected_Val = Default_Val end
        else
            Selected_Val = Default_Val or Options_List[1]
        end
    end
    Library_Table.Defaults[DD_Flag] = Selected_Val
    Library_Table.Flags[DD_Flag] = Selected_Val
    local Is_Dropped = false
    local DD_Parent = Custom_Parent or Parent_Frame
    local DD_Frame = Instance.new("Frame")
    DD_Frame.Size = UDim2.new(1, Custom_Parent and -20 or 0, 0, 46)
    if Custom_Parent then DD_Frame.Position = UDim2.new(0, 20, 0, 0) end
    DD_Frame.BackgroundTransparency = 1
    DD_Frame.Parent = DD_Parent
    DD_Frame.ZIndex = 5
    local DD_Label = Instance.new("TextLabel")
    DD_Label.Text = DD_Text
    DD_Label.Font = Config_Table.Font_Main
    DD_Label.TextSize = 13
    DD_Label.TextColor3 = Custom_Parent and Theme_Table.Text_Dark or Theme_Table.Text
    DD_Label.Size = UDim2.new(1, 0, 0, 16)
    DD_Label.Position = UDim2.new(0, 5, 0, 0)
    DD_Label.TextXAlignment = Enum.TextXAlignment.Left
    DD_Label.BackgroundTransparency = 1
    DD_Label.Parent = DD_Frame
    local DD_Interactive = Instance.new("TextButton")
    DD_Interactive.Size = UDim2.new(1, 0, 0, 26)
    DD_Interactive.Position = UDim2.new(0, 0, 0, 20)
    DD_Interactive.BackgroundColor3 = Theme_Table.Container
    DD_Interactive.Text = ""
    DD_Interactive.AutoButtonColor = false
    DD_Interactive.Parent = DD_Frame
    DD_Interactive.ZIndex = 5
    Create_Corner(DD_Interactive, 4)
    Create_Stroke(DD_Interactive, Theme_Table.Stroke, 1, 0.5)
    local Selected_Text_Label = Instance.new("TextLabel")
    Selected_Text_Label.Font = Config_Table.Font_Main
    Selected_Text_Label.TextSize = 13
    Selected_Text_Label.TextColor3 = Theme_Table.Text
    Selected_Text_Label.Size = UDim2.new(1, -25, 1, 0)
    Selected_Text_Label.Position = UDim2.new(0, 8, 0, 0)
    Selected_Text_Label.TextXAlignment = Enum.TextXAlignment.Left
    Selected_Text_Label.BackgroundTransparency = 1
    Selected_Text_Label.ZIndex = 6
    Selected_Text_Label.ClipsDescendants = false
    Selected_Text_Label.TextTruncate = Enum.TextTruncate.AtEnd
    Selected_Text_Label.Parent = DD_Interactive
    local DD_Arrow = Instance.new("ImageLabel")
    DD_Arrow.Image = "rbxassetid://10709790948"
    DD_Arrow.Size = UDim2.new(0, 18, 0, 18)
    DD_Arrow.Position = UDim2.new(1, -20, 0.5, 0)
    DD_Arrow.AnchorPoint = Vector2.new(0, 0.5)
    DD_Arrow.BackgroundTransparency = 1
    DD_Arrow.ImageColor3 = Theme_Table.Text_Dark
    DD_Arrow.Parent = DD_Interactive
    DD_Arrow.ZIndex = 6
    local DD_List_Frame = Instance.new("ScrollingFrame")
    DD_List_Frame.Size = UDim2.new(1, 0, 0, 0)
    DD_List_Frame.Position = UDim2.new(0, 0, 1, 5)
    DD_List_Frame.BackgroundColor3 = Theme_Table.Container
    DD_List_Frame.BorderSizePixel = 0
    DD_List_Frame.Parent = DD_Interactive
    DD_List_Frame.ZIndex = 10
    DD_List_Frame.Visible = false
    DD_List_Frame.Active = true
    DD_List_Frame.ScrollBarThickness = 2
    DD_List_Frame.ScrollBarImageColor3 = Theme_Table.Accent
    Create_Corner(DD_List_Frame, 4)
    Create_Stroke(DD_List_Frame, Theme_Table.Stroke, 1, 0.5)
    local DD_Layout = Instance.new("UIListLayout")
    DD_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    DD_Layout.Parent = DD_List_Frame
    local Conn_1 = DD_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        DD_List_Frame.CanvasSize = UDim2.new(0, 0, 0, DD_Layout.AbsoluteContentSize.Y)
    end)
    table.insert(Library_Table.Connections, Conn_1)
    local function Close_Dropdown()
        Is_Dropped = false
        if Section_Ref and Section_Ref.Container then Section_Ref.Container.ZIndex = 1 end
        DD_Frame.ZIndex = 5
        if Custom_Parent then Custom_Parent.ZIndex = 1 end
        Create_Tween(DD_Frame, {Size = UDim2.new(1, Custom_Parent and -20 or 0, 0, 46)}, 0.2)
        local Tween_List = Create_Tween(DD_List_Frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        Create_Tween(DD_Arrow, {Rotation = 0}, 0.2)
        local Conn_2
        Conn_2 = Tween_List.Completed:Connect(function()
            if not Is_Dropped then DD_List_Frame.Visible = false end
            Conn_2:Disconnect()
        end)
    end
    local Option_Btns = {}
    local function Check_Is_Selected(Opt_Val)
        if Is_Multi then
            for _, Val in ipairs(Selected_Val) do
                if Val == Opt_Val then return true end
            end
            return false
        else
            return Selected_Val == Opt_Val
        end
    end
    local function Update_Visuals()
        if Is_Multi then
            Selected_Text_Label.Text = (#Selected_Val > 0 and table.concat(Selected_Val, ", ") or "None")
        else
            Selected_Text_Label.Text = tostring(Selected_Val)
        end
        for Opt_Val, Btn_Obj in pairs(Option_Btns) do
            if Check_Is_Selected(Opt_Val) then
                Btn_Obj.TextColor3 = Theme_Table.Accent
            else
                Btn_Obj.TextColor3 = Theme_Table.Text_Dark
            end
        end
    end
    local function Build_Options(New_Options)
        for _, Btn_Obj in pairs(Option_Btns) do Btn_Obj:Destroy() end
        table.clear(Option_Btns)
        Options_List = New_Options
        for _, Opt_Val in ipairs(Options_List) do
            local Opt_Btn = Instance.new("TextButton")
            Opt_Btn.Size = UDim2.new(1, 0, 0, 24)
            Opt_Btn.BackgroundColor3 = Theme_Table.Container
            Opt_Btn.BackgroundTransparency = 1
            Opt_Btn.Text = Opt_Val
            Opt_Btn.Font = Config_Table.Font_Main
            Opt_Btn.TextSize = 12
            Opt_Btn.Parent = DD_List_Frame
            Opt_Btn.ZIndex = 11
            if Check_Is_Selected(Opt_Val) then
                Opt_Btn.TextColor3 = Theme_Table.Accent
            else
                Opt_Btn.TextColor3 = Theme_Table.Text_Dark
            end
            Option_Btns[Opt_Val] = Opt_Btn
            local Conn_3 = Opt_Btn.MouseEnter:Connect(function()
                if not Check_Is_Selected(Opt_Val) then
                    Create_Tween(Opt_Btn, {BackgroundTransparency = 0.8, TextColor3 = Theme_Table.Accent})
                end
            end)
            local Conn_4 = Opt_Btn.MouseLeave:Connect(function()
                if not Check_Is_Selected(Opt_Val) then
                    Create_Tween(Opt_Btn, {BackgroundTransparency = 1, TextColor3 = Theme_Table.Text_Dark})
                end
            end)
            local Conn_5 = Opt_Btn.MouseButton1Click:Connect(function()
                if Is_Multi then
                    local Found_Idx = table.find(Selected_Val, Opt_Val)
                    if Found_Idx then table.remove(Selected_Val, Found_Idx) else table.insert(Selected_Val, Opt_Val) end
                    Update_Visuals()
                    Library_Table.Flags[DD_Flag] = Selected_Val
                    Library_Table.Is_Unsaved = true
                    Callback_Func(Selected_Val)
                else
                    Selected_Val = Opt_Val
                    Update_Visuals()
                    Library_Table.Flags[DD_Flag] = Selected_Val
                    Library_Table.Is_Unsaved = true
                    Callback_Func(Selected_Val)
                    Close_Dropdown()
                end
            end)
            table.insert(Library_Table.Connections, Conn_3)
            table.insert(Library_Table.Connections, Conn_4)
            table.insert(Library_Table.Connections, Conn_5)
        end
    end
    Build_Options(Options_List)
    Update_Visuals()
    Library_Table.Signals[DD_Flag] = function(Loaded_Val)
        if Is_Multi then
            if type(Loaded_Val) == "table" then Selected_Val = Loaded_Val else Selected_Val = {Loaded_Val} end
        else
            Selected_Val = Loaded_Val
        end
        Update_Visuals()
        Library_Table.Is_Unsaved = true
        Callback_Func(Selected_Val)
    end
    local Conn_6 = DD_Interactive.MouseButton1Click:Connect(function()
        Is_Dropped = not Is_Dropped
        if Section_Ref and Section_Ref.Container then Section_Ref.Container.ZIndex = Is_Dropped and 10 or 1 end
        DD_Frame.ZIndex = Is_Dropped and 10 or 5
        if Custom_Parent then Custom_Parent.ZIndex = Is_Dropped and 10 or 1 Custom_Parent.ClipsDescendants = false end
        if Is_Dropped then
            DD_List_Frame.Visible = true
            local List_Height = math.min(#Options_List * 24, 200)
            local Total_Height = 46 + List_Height + 5
            Create_Tween(DD_Frame, {Size = UDim2.new(1, Custom_Parent and -20 or 0, 0, Total_Height)}, 0.2)
            Create_Tween(DD_List_Frame, {Size = UDim2.new(1, 0, 0, List_Height)}, 0.2)
            Create_Tween(DD_Arrow, {Rotation = 180}, 0.2)
        else
            Close_Dropdown()
        end
    end)
    table.insert(Library_Table.Connections, Conn_6)
    Apply_Tooltip(DD_Frame, Tooltip_Text)
    task.spawn(Callback_Func, Selected_Val)
    local Dropdown_Object = {}
    Dropdown_Object.Frame = DD_Frame
    function Dropdown_Object:Refresh(New_Options, New_Default)
        if Is_Multi then
            if type(New_Default) ~= "table" then Selected_Val = {New_Default} else Selected_Val = New_Default end
        else
            Selected_Val = New_Default or (New_Options[1] or "")
        end
        Library_Table.Flags[DD_Flag] = Selected_Val
        Build_Options(New_Options)
        Update_Visuals()
    end
    function Dropdown_Object:Get_Selected()
        return Selected_Val
    end
    function Dropdown_Object:Set(Set_Val)
        if Is_Multi then
            if type(Set_Val) == "table" then Selected_Val = Set_Val else Selected_Val = {Set_Val} end
        else
            Selected_Val = Set_Val
        end
        Library_Table.Flags[DD_Flag] = Selected_Val
        Update_Visuals()
        Callback_Func(Selected_Val)
    end
    return Dropdown_Object
end
local function Create_Slider_Element(Slider_Text, Slider_Flag, Min_Val, Max_Val, Default_Val, Increment_Val, Tooltip_Text, Callback_Func, Parent_Frame, Section_Data)
    Increment_Val = Increment_Val or 1
    local Current_Val = Library_Table.Flags[Slider_Flag]
    if Current_Val == nil then Current_Val = Default_Val or Min_Val end
    Current_Val = Round_To_Increment(Current_Val, Increment_Val)
    Library_Table.Defaults[Slider_Flag] = Current_Val
    Library_Table.Flags[Slider_Flag] = Current_Val
    local Slider_Frame = Instance.new("Frame")
    Slider_Frame.Size = UDim2.new(1, 0, 0, 42)
    Slider_Frame.BackgroundTransparency = 1
    Slider_Frame.Parent = Parent_Frame
    if Section_Data then table.insert(Section_Data.Items, {Name = Slider_Text, Instance = Slider_Frame}) end
    local Slider_Label = Instance.new("TextLabel")
    Slider_Label.Text = Slider_Text
    Slider_Label.Font = Config_Table.Font_Main
    Slider_Label.TextSize = 13
    Slider_Label.TextColor3 = Theme_Table.Text
    Slider_Label.Size = UDim2.new(0.6, 0, 0, 16)
    Slider_Label.Position = UDim2.new(0, 5, 0, 0)
    Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
    Slider_Label.BackgroundTransparency = 1
    Slider_Label.Parent = Slider_Frame
    local Value_Box = Instance.new("TextBox")
    Value_Box.Text = Format_Number(Current_Val, Increment_Val)
    Value_Box.Font = Config_Table.Font_Main
    Value_Box.TextSize = 13
    Value_Box.TextColor3 = Theme_Table.Text
    Value_Box.Size = UDim2.new(0.4, -5, 0, 16)
    Value_Box.Position = UDim2.new(0.6, 0, 0, 0)
    Value_Box.TextXAlignment = Enum.TextXAlignment.Right
    Value_Box.BackgroundTransparency = 1
    Value_Box.ClearTextOnFocus = true
    Value_Box.Parent = Slider_Frame
    local Slider_Bar = Instance.new("Frame")
    Slider_Bar.Size = UDim2.new(1, 0, 0, 6)
    Slider_Bar.Position = UDim2.new(0, 0, 0, 24)
    Slider_Bar.BackgroundColor3 = Theme_Table.Container
    Slider_Bar.Parent = Slider_Frame
    Create_Corner(Slider_Bar, 3)
    Create_Stroke(Slider_Bar, Theme_Table.Stroke, 1, 0.5)
    local Slider_Fill = Instance.new("Frame")
    local Range_Val = Max_Val - Min_Val
    local Ratio_Val = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
    Slider_Fill.Size = UDim2.new(Ratio_Val, 0, 1, 0)
    Slider_Fill.BackgroundColor3 = Theme_Table.Accent
    Slider_Fill.BorderSizePixel = 0
    Slider_Fill.Parent = Slider_Bar
    Create_Corner(Slider_Fill, 3)
    Register_Theme(Slider_Fill, "BackgroundColor")
    local Is_Dragging = false
    local function Set_From_Input(Input_Obj)
        local Calc_Ratio = math.clamp((Input_Obj.Position.X - Slider_Bar.AbsolutePosition.X) / Slider_Bar.AbsoluteSize.X, 0, 1)
        local Raw_Val = Min_Val + (Max_Val - Min_Val) * Calc_Ratio
        Current_Val = Round_To_Increment(Raw_Val, Increment_Val)
        Current_Val = math.clamp(Current_Val, Min_Val, Max_Val)
        local Display_Ratio = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
        Value_Box.Text = Format_Number(Current_Val, Increment_Val)
        Create_Tween(Slider_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
        Library_Table.Flags[Slider_Flag] = Current_Val
        Library_Table.Is_Unsaved = true
        Callback_Func(Current_Val)
    end
    local Conn_1 = Slider_Bar.InputBegan:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            Is_Dragging = true
            Set_From_Input(Input_Obj)
        end
    end)
    local Conn_2 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            if Is_Dragging then Is_Dragging = false end
        end
    end)
    local Conn_3 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
            if Is_Dragging then Set_From_Input(Input_Obj) end
        end
    end)
    table.insert(Library_Table.Connections, Conn_1)
    table.insert(Library_Table.Connections, Conn_2)
    table.insert(Library_Table.Connections, Conn_3)
    local Conn_5 = Value_Box.FocusLost:Connect(function(Enter_Pressed)
        if Enter_Pressed then
            local Clean_Text = string.gsub(Value_Box.Text, "[^%d.-]", "")
            local Num_Val = tonumber(Clean_Text)
            if Num_Val then
                Num_Val = Round_To_Increment(Num_Val, Increment_Val)
                Num_Val = math.clamp(Num_Val, Min_Val, Max_Val)
                Current_Val = Num_Val
                local Display_Ratio = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
                Value_Box.Text = Format_Number(Current_Val, Increment_Val)
                Create_Tween(Slider_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                Library_Table.Flags[Slider_Flag] = Current_Val
                Library_Table.Is_Unsaved = true
                Callback_Func(Current_Val)
            else
                Value_Box.Text = Format_Number(Current_Val, Increment_Val)
            end
        else
            Value_Box.Text = Format_Number(Current_Val, Increment_Val)
        end
    end)
    table.insert(Library_Table.Connections, Conn_5)
    Library_Table.Signals[Slider_Flag] = function(Loaded_Val)
        Current_Val = Round_To_Increment(Loaded_Val, Increment_Val)
        Current_Val = math.clamp(Current_Val, Min_Val, Max_Val)
        local Display_Ratio = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
        Value_Box.Text = Format_Number(Current_Val, Increment_Val)
        Create_Tween(Slider_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
        Library_Table.Is_Unsaved = true
        Callback_Func(Current_Val)
    end
    Apply_Tooltip(Slider_Frame, Tooltip_Text)
    task.spawn(Callback_Func, Current_Val)
    return Slider_Frame
end
function Library_Table:CreateWindow(Init_Options)
    if Init_Options and Init_Options.Name then Config_Table.Name = Init_Options.Name end
    if Init_Options and Init_Options.Config_Folder then Config_Table.Config_Folder = Init_Options.Config_Folder end
    if not Is_Folder(Config_Table.Config_Folder) then Make_Folder(Config_Table.Config_Folder) end
    Library_Table:Unload_Library()
    Library_Table:Init_Watermark()
    local Hub_Screen_Gui = Instance.new("ScreenGui")
    Hub_Screen_Gui.Name = Config_Table.Name
    Hub_Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Hub_Screen_Gui.IgnoreGuiInset = true
    Hub_Screen_Gui.ResetOnSpawn = false
    Hub_Screen_Gui.Parent = Get_Parent()
    Library_Table.Screen_Gui = Hub_Screen_Gui
    local Mini_Gui = Instance.new("ScreenGui")
    Mini_Gui.Name = "PhantomMiniButton"
    Mini_Gui.Parent = Get_Parent()
    Mini_Gui.Enabled = true
    Mini_Gui.IgnoreGuiInset = true
    local Mini_Button = Instance.new("ImageButton")
    Mini_Button.Size = UDim2.new(0, 46, 0, 46)
    Mini_Button.Position = UDim2.new(0, 20, 0.5, -23)
    Mini_Button.BackgroundColor3 = Theme_Table.Background
    Mini_Button.BackgroundTransparency = 0.1
    Mini_Button.Image = "rbxassetid://112964043447417"
    Mini_Button.ImageColor3 = Theme_Table.Accent
    Mini_Button.ScaleType = Enum.ScaleType.Fit
    Mini_Button.AutoButtonColor = false
    Mini_Button.Active = true
    Mini_Button.Parent = Mini_Gui
    Create_Corner(Mini_Button, 23)
    Create_Stroke(Mini_Button, Theme_Table.Accent, 2, 0.3)
    Register_Theme(Mini_Button, "ImageColor")
    local Mini_Was_Dragged = false
    Make_Draggable(Mini_Button, Mini_Button, function(Was_Drag) Mini_Was_Dragged = Was_Drag end)
    local Conn_1 = Mini_Button.MouseButton1Click:Connect(function()
        if Mini_Was_Dragged then
            Mini_Was_Dragged = false
            return
        end
        if Library_Table.Is_Open then
            Library_Table.Is_Open = false
            if Library_Table.Is_Settings_Active then
                Create_Tween(Library_Table.Settings_Scale, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            else
                Create_Tween(Library_Table.Main_Scale, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            end
            Library_Table.Main_Window.Visible = false
            Library_Table.Settings_Window.Visible = false
            Tooltip_Label.Visible = false
        else
            Library_Table.Is_Open = true
            if Library_Table.Is_Settings_Active then
                Library_Table.Settings_Window.Visible = true
                Library_Table.Settings_Window.BackgroundTransparency = 0.1
                Library_Table.Settings_Scale.Scale = Get_Base_Scale() * 0.8
                Create_Tween(Library_Table.Settings_Scale, {Scale = Get_Base_Scale()}, 0.3)
            else
                Library_Table.Main_Window.Visible = true
                Library_Table.Main_Window.BackgroundTransparency = 0.1
                Library_Table.Main_Scale.Scale = Get_Base_Scale() * 0.8
                Create_Tween(Library_Table.Main_Scale, {Scale = Get_Base_Scale()}, 0.3)
            end
        end
    end)
    table.insert(Library_Table.Connections, Conn_1)
    local function Create_Base_Frame(Frame_Name)
        local Base_Frame = Instance.new("Frame")
        Base_Frame.Name = Frame_Name
        Base_Frame.Size = UDim2.new(0, 650, 0, 400)
        Base_Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Base_Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        Base_Frame.BackgroundColor3 = Theme_Table.Background
        Base_Frame.BackgroundTransparency = 0.1
        Base_Frame.BorderSizePixel = 0
        Base_Frame.ClipsDescendants = false
        Base_Frame.Visible = false
        Base_Frame.Parent = Hub_Screen_Gui
        Base_Frame.Active = true
        local Size_Constraint = Instance.new("UISizeConstraint")
        Size_Constraint.MaxSize = Vector2.new(1400, 900)
        Size_Constraint.MinSize = Vector2.new(300, 200)
        Size_Constraint.Parent = Base_Frame
        Create_Corner(Base_Frame, 6)
        Create_Stroke(Base_Frame, Theme_Table.Stroke, 1, 0)
        local Bg_Noise = Instance.new("ImageLabel")
        Bg_Noise.Size = UDim2.new(1, 0, 1, 0)
        Bg_Noise.BackgroundTransparency = 1
        Bg_Noise.Image = "rbxassetid://9968344105"
        Bg_Noise.ImageTransparency = 0.9
        Bg_Noise.ScaleType = Enum.ScaleType.Tile
        Bg_Noise.TileSize = UDim2.new(0, 100, 0, 100)
        Bg_Noise.Parent = Base_Frame
        Create_Corner(Bg_Noise, 6)
        local Drag_Header = Instance.new("Frame")
        Drag_Header.Name = "DragHeader"
        Drag_Header.Size = UDim2.new(0, 180, 0, 60)
        Drag_Header.BackgroundTransparency = 1
        Drag_Header.Parent = Base_Frame
        local Scale_Obj = Instance.new("UIScale")
        Scale_Obj.Scale = 1
        Scale_Obj.Parent = Base_Frame
        Make_Draggable(Drag_Header, Base_Frame)
        return Base_Frame, Scale_Obj
    end
    local Main_Win, Main_Scale_Obj = Create_Base_Frame("MainWindow")
    local Settings_Win, Set_Scale_Obj = Create_Base_Frame("SettingsWindow")
    Library_Table.Main_Window = Main_Win
    Library_Table.Main_Scale = Main_Scale_Obj
    Library_Table.Settings_Window = Settings_Win
    Library_Table.Settings_Scale = Set_Scale_Obj
    Library_Table.Is_Settings_Active = false
    local Resizer_Frame = Instance.new("Frame")
    Resizer_Frame.Size = UDim2.new(0, 20, 0, 20)
    Resizer_Frame.Position = UDim2.new(1, 0, 1, 0)
    Resizer_Frame.AnchorPoint = Vector2.new(1, 1)
    Resizer_Frame.BackgroundTransparency = 1
    Resizer_Frame.Parent = Main_Win
    Resizer_Frame.ZIndex = 20
    Resizer_Frame.Active = true
    local Resizer_Icon = Instance.new("TextLabel")
    Resizer_Icon.Size = UDim2.new(1, 0, 1, 0)
    Resizer_Icon.BackgroundTransparency = 1
    Resizer_Icon.Text = "◢"
    Resizer_Icon.TextColor3 = Theme_Table.Text_Dark
    Resizer_Icon.TextSize = 16
    Resizer_Icon.Parent = Resizer_Frame
    local Conn_2 = Resizer_Frame.InputBegan:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement then Create_Tween(Resizer_Icon, {TextColor3 = Theme_Table.Accent}) end
    end)
    local Conn_3 = Resizer_Frame.InputEnded:Connect(function(Input_Obj)
        if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement then Create_Tween(Resizer_Icon, {TextColor3 = Theme_Table.Text_Dark}) end
    end)
    table.insert(Library_Table.Connections, Conn_2)
    table.insert(Library_Table.Connections, Conn_3)
    Make_Resizable(Resizer_Frame, Main_Win, Vector2.new(300, 200))
    local function Create_Sidebar(Parent_Obj, Is_Settings_Sidebar)
        local Sidebar_Frame = Instance.new("Frame")
        Sidebar_Frame.Size = UDim2.new(0, 180, 1, 0)
        Sidebar_Frame.BackgroundColor3 = Theme_Table.Sidebar
        Sidebar_Frame.BorderSizePixel = 0
        Sidebar_Frame.Parent = Parent_Obj
        Sidebar_Frame.Active = true
        Create_Corner(Sidebar_Frame, 6)
        local Divider_Line = Instance.new("Frame")
        Divider_Line.Size = UDim2.new(0, 1, 1, 0)
        Divider_Line.Position = UDim2.new(1, 0, 0, 0)
        Divider_Line.BackgroundColor3 = Theme_Table.Stroke
        Divider_Line.BorderSizePixel = 0
        Divider_Line.Parent = Sidebar_Frame
        if Is_Settings_Sidebar then
            local Back_Btn = Instance.new("TextButton")
            Back_Btn.Size = UDim2.new(1, -20, 0, 30)
            Back_Btn.Position = UDim2.new(0, 10, 0, 15)
            Back_Btn.BackgroundColor3 = Theme_Table.Container
            Back_Btn.Text = " < Back to Menu"
            Back_Btn.Font = Config_Table.Font_Bold
            Back_Btn.TextSize = 13
            Back_Btn.TextColor3 = Theme_Table.Text_Dark
            Back_Btn.TextXAlignment = Enum.TextXAlignment.Left
            Back_Btn.AutoButtonColor = false
            Back_Btn.Parent = Sidebar_Frame
            Create_Corner(Back_Btn, 4)
            Create_Stroke(Back_Btn, Theme_Table.Stroke, 1, 0.5)
            local Conn_4 = Back_Btn.MouseEnter:Connect(function() Create_Tween(Back_Btn, {TextColor3 = Theme_Table.Accent}) end)
            local Conn_5 = Back_Btn.MouseLeave:Connect(function() Create_Tween(Back_Btn, {TextColor3 = Theme_Table.Text_Dark}) end)
            table.insert(Library_Table.Connections, Conn_4)
            table.insert(Library_Table.Connections, Conn_5)
            local Title_Label = Instance.new("TextLabel")
            Title_Label.Text = "Settings"
            Title_Label.Size = UDim2.new(1, 0, 0, 30)
            Title_Label.Position = UDim2.new(0, 0, 0, 55)
            Title_Label.Font = Config_Table.Font_Bold
            Title_Label.TextSize = 22
            Title_Label.TextColor3 = Theme_Table.Text
            Title_Label.BackgroundTransparency = 1
            Title_Label.Parent = Sidebar_Frame
            return Sidebar_Frame, nil, Back_Btn
        else
            local Logo_Label = Instance.new("TextLabel")
            Logo_Label.Text = Config_Table.Name
            Logo_Label.RichText = true
            Logo_Label.Position = UDim2.new(0, 15, 0, 20)
            Logo_Label.Size = UDim2.new(1, -30, 0, 30)
            Logo_Label.Font = Config_Table.Font_Bold
            Logo_Label.TextSize = 20
            Logo_Label.TextColor3 = Theme_Table.Accent
            Logo_Label.TextXAlignment = Enum.TextXAlignment.Left
            Logo_Label.BackgroundTransparency = 1
            Logo_Label.Parent = Sidebar_Frame
            Register_Theme(Logo_Label, "TextColor")
            local Container_Frame = Instance.new("Frame")
            Container_Frame.Size = UDim2.new(1, 0, 1, -130)
            Container_Frame.Position = UDim2.new(0, 0, 0, 60)
            Container_Frame.BackgroundTransparency = 1
            Container_Frame.Parent = Sidebar_Frame
            local List_Layout = Instance.new("UIListLayout")
            List_Layout.Padding = UDim.new(0, 6)
            List_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
            List_Layout.Parent = Container_Frame
            return Sidebar_Frame, Container_Frame, nil
        end
    end
    local Main_Bar, Tab_Container_Frame, _ = Create_Sidebar(Main_Win, false)
    local Set_Bar, _, Back_Button = Create_Sidebar(Settings_Win, true)
    local Profile_Btn = Instance.new("TextButton")
    Profile_Btn.Size = UDim2.new(1, 0, 0, 60)
    Profile_Btn.Position = UDim2.new(0, 0, 1, 0)
    Profile_Btn.AnchorPoint = Vector2.new(0, 1)
    Profile_Btn.BackgroundColor3 = Theme_Table.Sidebar
    Profile_Btn.BorderSizePixel = 0
    Profile_Btn.Text = ""
    Profile_Btn.AutoButtonColor = false
    Profile_Btn.Parent = Main_Bar
    local Side_Avatar = Instance.new("ImageLabel")
    Side_Avatar.Size = UDim2.new(0, 36, 0, 36)
    Side_Avatar.Position = UDim2.new(0, 15, 0.5, 0)
    Side_Avatar.AnchorPoint = Vector2.new(0, 0.5)
    Side_Avatar.BackgroundColor3 = Theme_Table.Container
    local Has_Av, Av_Url = pcall(function() return Players_Service:GetUserThumbnailAsync(Local_Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    Side_Avatar.Image = Has_Av and Av_Url or "rbxassetid://0"
    Side_Avatar.Parent = Profile_Btn
    Create_Corner(Side_Avatar, 18)
    local Av_Stroke = Create_Stroke(Side_Avatar, Theme_Table.Accent, 1)
    Register_Theme(Av_Stroke, "BorderColor")
    local Side_Name = Instance.new("TextLabel")
    Side_Name.Size = UDim2.new(0, 100, 0, 16)
    Side_Name.Position = UDim2.new(0, 60, 0.5, -9)
    Side_Name.AnchorPoint = Vector2.new(0, 0.5)
    Side_Name.BackgroundTransparency = 1
    Side_Name.Text = Local_Player.Name
    Side_Name.TextColor3 = Theme_Table.Text
    Side_Name.Font = Config_Table.Font_Bold
    Side_Name.TextSize = 13
    Side_Name.TextXAlignment = Enum.TextXAlignment.Left
    Side_Name.Parent = Profile_Btn
    local Side_Sub = Instance.new("TextLabel")
    Side_Sub.Size = UDim2.new(0, 100, 0, 14)
    Side_Sub.Position = UDim2.new(0, 60, 0.5, 9)
    Side_Sub.AnchorPoint = Vector2.new(0, 0.5)
    Side_Sub.BackgroundTransparency = 1
    Side_Sub.Text = "Settings"
    Side_Sub.TextColor3 = Theme_Table.Text_Dark
    Side_Sub.Font = Config_Table.Font_Main
    Side_Sub.TextSize = 11
    Side_Sub.TextXAlignment = Enum.TextXAlignment.Left
    Side_Sub.Parent = Profile_Btn
    local Is_Settings_Mode = false
    local Is_Animating = false
    local function Toggle_Main_UI()
        if Is_Animating then return end
        Is_Animating = true
        Library_Table.Is_Open = not Library_Table.Is_Open
        if Library_Table.Is_Open then
            if Is_Settings_Mode then
                Settings_Win.Visible = true
                Settings_Win.BackgroundTransparency = 0.1
                Set_Scale_Obj.Scale = Get_Base_Scale() * 0.8
                Create_Tween(Set_Scale_Obj, {Scale = Get_Base_Scale()}, 0.3).Completed:Wait()
            else
                Main_Win.Visible = true
                Main_Win.BackgroundTransparency = 0.1
                Main_Scale_Obj.Scale = Get_Base_Scale() * 0.8
                Create_Tween(Main_Scale_Obj, {Scale = Get_Base_Scale()}, 0.3).Completed:Wait()
            end
        else
            if Is_Settings_Mode then
                Create_Tween(Set_Scale_Obj, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            else
                Create_Tween(Main_Scale_Obj, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            end
            Main_Win.Visible = false
            Settings_Win.Visible = false
            Tooltip_Label.Visible = false
        end
        Is_Animating = false
    end
    local function Switch_To_Settings()
        if Is_Animating then return end
        Is_Animating = true
        Settings_Win.Position = Main_Win.Position
        Settings_Win.Size = Main_Win.Size
        Create_Tween(Main_Scale_Obj, {Scale = Get_Base_Scale() * 0.9}, 0.15).Completed:Wait()
        Main_Win.Visible = false
        Settings_Win.Visible = true
        Settings_Win.BackgroundTransparency = 0.1
        Set_Scale_Obj.Scale = Get_Base_Scale() * 0.9
        Create_Tween(Set_Scale_Obj, {Scale = Get_Base_Scale()}, 0.2).Completed:Wait()
        Is_Settings_Mode = true
        Library_Table.Is_Settings_Active = true
        Is_Animating = false
    end
    local function Switch_To_Main()
        if Is_Animating then return end
        Is_Animating = true
        Main_Win.Position = Settings_Win.Position
        Main_Win.Size = Settings_Win.Size
        Create_Tween(Set_Scale_Obj, {Scale = Get_Base_Scale() * 0.9}, 0.15).Completed:Wait()
        Settings_Win.Visible = false
        Main_Win.Visible = true
        Main_Win.BackgroundTransparency = 0.1
        Main_Scale_Obj.Scale = Get_Base_Scale() * 0.9
        Create_Tween(Main_Scale_Obj, {Scale = Get_Base_Scale()}, 0.2).Completed:Wait()
        Is_Settings_Mode = false
        Library_Table.Is_Settings_Active = false
        Is_Animating = false
    end
    local Conn_6 = Profile_Btn.MouseButton1Click:Connect(function() task.spawn(Switch_To_Settings) end)
    local Conn_7 = Back_Button.MouseButton1Click:Connect(function() task.spawn(Switch_To_Main) end)
    table.insert(Library_Table.Connections, Conn_6)
    table.insert(Library_Table.Connections, Conn_7)
    local Conn_8 = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if Library_Table.Is_Open then
            if Is_Settings_Mode and Settings_Win.Visible then
                Set_Scale_Obj.Scale = Get_Base_Scale()
            elseif not Is_Settings_Mode and Main_Win.Visible then
                Main_Scale_Obj.Scale = Get_Base_Scale()
            end
        end
    end)
    table.insert(Library_Table.Connections, Conn_8)
    local Menu_Bind_Conn = User_Input_Service.InputBegan:Connect(function(Input_Obj, Is_Game_Processed)
        if not Is_Game_Processed and Input_Obj.KeyCode == Config_Table.Keybind then
            task.spawn(Toggle_Main_UI)
        end
    end)
    table.insert(Library_Table.Connections, Menu_Bind_Conn)
    local Window_Object = {}
    local Main_Pages = Instance.new("Frame")
    Main_Pages.Size = UDim2.new(1, -181, 1, 0)
    Main_Pages.Position = UDim2.new(0, 181, 0, 0)
    Main_Pages.BackgroundTransparency = 1
    Main_Pages.Parent = Main_Win
    function Window_Object:Create_Raw_Section(Section_Text, Parent_Obj)
        local Section_Object = {}
        local Container_Frame = Instance.new("Frame")
        Container_Frame.Size = UDim2.new(1, 0, 0, 0)
        Container_Frame.BackgroundColor3 = Theme_Table.Section
        Container_Frame.Parent = Parent_Obj
        Container_Frame.ZIndex = 1
        Create_Corner(Container_Frame, 6)
        Create_Stroke(Container_Frame, Theme_Table.Stroke, 1, 0.5)
        Section_Object.Container = Container_Frame
        local Title_Label = Instance.new("TextLabel")
        Title_Label.Text = Section_Text
        Title_Label.Font = Config_Table.Font_Bold
        Title_Label.TextSize = 12
        Title_Label.TextColor3 = Theme_Table.Text_Dark
        Title_Label.Size = UDim2.new(1, -20, 0, 30)
        Title_Label.Position = UDim2.new(0, 10, 0, 0)
        Title_Label.BackgroundTransparency = 1
        Title_Label.TextXAlignment = Enum.TextXAlignment.Left
        Title_Label.Parent = Container_Frame
        local Content_Frame = Instance.new("Frame")
        Content_Frame.Name = "Content"
        Content_Frame.Size = UDim2.new(1, -10, 0, 0)
        Content_Frame.Position = UDim2.new(0, 5, 0, 30)
        Content_Frame.BackgroundTransparency = 1
        Content_Frame.Parent = Container_Frame
        local List_Layout = Instance.new("UIListLayout")
        List_Layout.Padding = UDim.new(0, 6)
        List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
        List_Layout.Parent = Content_Frame
        local L_Conn_1 = List_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container_Frame.Size = UDim2.new(1, 0, 0, List_Layout.AbsoluteContentSize.Y + 40)
        end)
        table.insert(Library_Table.Connections, L_Conn_1)
        function Section_Object:Label(Label_Text, Opts_Table)
            Opts_Table = Opts_Table or {}
            local Label_Obj = {}
            local Frame_Obj = Instance.new("Frame")
            Frame_Obj.Size = UDim2.new(1, 0, 0, 26)
            Frame_Obj.BackgroundColor3 = Theme_Table.Container
            Frame_Obj.BackgroundTransparency = 0.5
            Frame_Obj.Parent = Content_Frame
            Create_Corner(Frame_Obj, 4)
            Create_Stroke(Frame_Obj, Theme_Table.Stroke, 1, 0.5)
            local Accent_Line = Instance.new("Frame")
            Accent_Line.Size = UDim2.new(0, 3, 1, -10)
            Accent_Line.Position = UDim2.new(0, 5, 0.5, 0)
            Accent_Line.AnchorPoint = Vector2.new(0, 0.5)
            Accent_Line.BackgroundColor3 = Theme_Table.Accent
            Accent_Line.BorderSizePixel = 0
            Accent_Line.Parent = Frame_Obj
            Create_Corner(Accent_Line, 2)
            Register_Theme(Accent_Line, "BackgroundColor")
            local Text_Lbl = Instance.new("TextLabel")
            Text_Lbl.Size = UDim2.new(1, -15, 1, 0)
            Text_Lbl.Position = UDim2.new(0, 15, 0, 0)
            Text_Lbl.BackgroundTransparency = 1
            Text_Lbl.Text = tostring(Label_Text)
            Text_Lbl.Font = Config_Table.Font_Main
            Text_Lbl.TextSize = 13
            Text_Lbl.TextColor3 = Opts_Table.Color or Theme_Table.Text
            Text_Lbl.TextXAlignment = Opts_Table.Alignment or Enum.TextXAlignment.Left
            Text_Lbl.RichText = true
            Text_Lbl.TextWrapped = true
            Text_Lbl.Parent = Frame_Obj
            local function Update_Height()
                local Text_Height = Text_Lbl.TextBounds.Y
                if Text_Height > 16 then Frame_Obj.Size = UDim2.new(1, 0, 0, Text_Height + 10) else Frame_Obj.Size = UDim2.new(1, 0, 0, 26) end
            end
            local Bounds_Conn = Text_Lbl:GetPropertyChangedSignal("TextBounds"):Connect(Update_Height)
            table.insert(Library_Table.Connections, Bounds_Conn)
            Update_Height()
            function Label_Obj:Set(New_Text) Text_Lbl.Text = tostring(New_Text) end
            function Label_Obj:Set_Color(New_Color) Text_Lbl.TextColor3 = New_Color end
            return Label_Obj
        end
        function Section_Object:Button(Button_Text, Tooltip_Text, Callback_Func)
            local Btn_Obj = Instance.new("TextButton")
            Btn_Obj.Size = UDim2.new(1, 0, 0, 32)
            Btn_Obj.BackgroundColor3 = Theme_Table.Container
            Btn_Obj.Text = Button_Text
            Btn_Obj.Font = Config_Table.Font_Main
            Btn_Obj.TextSize = 13
            Btn_Obj.TextColor3 = Theme_Table.Text
            Btn_Obj.AutoButtonColor = false
            Btn_Obj.Parent = Content_Frame
            Create_Corner(Btn_Obj, 4)
            local Stroke_Obj = Create_Stroke(Btn_Obj, Theme_Table.Stroke, 1, 0.5)
            local B_Conn_1 = Btn_Obj.MouseEnter:Connect(function() Create_Tween(Btn_Obj, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(Stroke_Obj, {Color = Theme_Table.Accent}) end)
            local B_Conn_2 = Btn_Obj.MouseLeave:Connect(function() Create_Tween(Btn_Obj, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(Stroke_Obj, {Color = Theme_Table.Stroke}) end)
            local B_Conn_3 = Btn_Obj.MouseButton1Click:Connect(Callback_Func)
            table.insert(Library_Table.Connections, B_Conn_1)
            table.insert(Library_Table.Connections, B_Conn_2)
            table.insert(Library_Table.Connections, B_Conn_3)
            Apply_Tooltip(Btn_Obj, Tooltip_Text)
            return Btn_Obj
        end
        function Section_Object:Toggle(Toggle_Text, Toggle_Flag, Default_Val, Tooltip_Text, Callback_Func)
            Library_Table.Defaults[Toggle_Flag] = Default_Val or false
            local Is_Toggled = Library_Table.Flags[Toggle_Flag]
            if Is_Toggled == nil then
                Is_Toggled = Default_Val or false
                Library_Table.Flags[Toggle_Flag] = Is_Toggled
            end
            local Toggle_Obj = {}
            Library_Table.Signals[Toggle_Flag] = function(Loaded_Val)
                if Is_Toggled ~= Loaded_Val then
                    Is_Toggled = Loaded_Val
                    if Toggle_Obj.Update_Anim then Toggle_Obj.Update_Anim() end
                    Library_Table.Is_Unsaved = true
                    Callback_Func(Loaded_Val)
                end
            end
            local Btn_Obj = Instance.new("TextButton")
            Btn_Obj.Size = UDim2.new(1, 0, 0, 32)
            Btn_Obj.BackgroundColor3 = Theme_Table.Container
            Btn_Obj.Text = ""
            Btn_Obj.AutoButtonColor = false
            Btn_Obj.Parent = Content_Frame
            Create_Corner(Btn_Obj, 4)
            Create_Stroke(Btn_Obj, Theme_Table.Stroke, 1, 0.5)
            local Text_Label = Instance.new("TextLabel")
            Text_Label.Text = Toggle_Text
            Text_Label.Font = Config_Table.Font_Main
            Text_Label.TextSize = 13
            Text_Label.TextColor3 = Theme_Table.Text
            Text_Label.Size = UDim2.new(1, -30, 1, 0)
            Text_Label.Position = UDim2.new(0, 10, 0, 0)
            Text_Label.TextXAlignment = Enum.TextXAlignment.Left
            Text_Label.BackgroundTransparency = 1
            Text_Label.Parent = Btn_Obj
            local Box_Frame = Instance.new("Frame")
            Box_Frame.Size = UDim2.new(0, 18, 0, 18)
            Box_Frame.Position = UDim2.new(1, -10, 0.5, 0)
            Box_Frame.AnchorPoint = Vector2.new(1, 0.5)
            Box_Frame.BackgroundColor3 = Theme_Table.Background
            Box_Frame.Parent = Btn_Obj
            Create_Corner(Box_Frame, 4)
            Create_Stroke(Box_Frame, Theme_Table.Stroke, 1, 0.5)
            local Fill_Frame = Instance.new("Frame")
            Fill_Frame.Size = UDim2.new(1, -4, 1, -4)
            Fill_Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
            Fill_Frame.AnchorPoint = Vector2.new(0.5, 0.5)
            Fill_Frame.BackgroundColor3 = Theme_Table.Accent
            Fill_Frame.BackgroundTransparency = Is_Toggled and 0 or 1
            Fill_Frame.Parent = Box_Frame
            Create_Corner(Fill_Frame, 3)
            Register_Theme(Fill_Frame, "BackgroundColor")
            local Sub_Container = Instance.new("Frame")
            Sub_Container.Name = "Sub_" .. Toggle_Text
            Sub_Container.Size = UDim2.new(1, 0, 0, 0)
            Sub_Container.BackgroundTransparency = 1
            Sub_Container.ClipsDescendants = true
            Sub_Container.Visible = false
            Sub_Container.Parent = Content_Frame
            local Sub_List = Instance.new("UIListLayout")
            Sub_List.Padding = UDim.new(0, 6)
            Sub_List.SortOrder = Enum.SortOrder.LayoutOrder
            Sub_List.Parent = Sub_Container
            local Current_Tween = nil
            local function Toggle_Anim()
                if Current_Tween then Current_Tween:Cancel() end
                Create_Tween(Fill_Frame, {BackgroundTransparency = Is_Toggled and 0 or 1}, 0.2)
                Library_Table.Flags[Toggle_Flag] = Is_Toggled
                if Toggle_Obj.Keybind_Value then
                    Library_Table:Update_Keybind_List(Toggle_Text, Toggle_Obj.Keybind_Value.Name, Is_Toggled, Toggle_Obj.Keybind_Mode)
                end
                if Is_Toggled then
                    Sub_Container.Visible = true
                    Sub_Container.ClipsDescendants = true
                    local Height_Val = Sub_List.AbsoluteContentSize.Y
                    if Height_Val > 0 then Height_Val = Height_Val + 6 end
                    Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, Height_Val)})
                    Current_Tween:Play()
                    local T_Conn
                    T_Conn = Current_Tween.Completed:Connect(function(State_Val)
                        if State_Val == Enum.PlaybackState.Completed and Is_Toggled then Sub_Container.ClipsDescendants = false end
                        T_Conn:Disconnect()
                    end)
                else
                    Sub_Container.ClipsDescendants = true
                    Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                    Current_Tween:Play()
                    local Expected_Toggle = Is_Toggled
                    local T_Conn
                    T_Conn = Current_Tween.Completed:Connect(function(State_Val)
                        if State_Val == Enum.PlaybackState.Completed and Expected_Toggle == Is_Toggled and not Is_Toggled then Sub_Container.Visible = false end
                        T_Conn:Disconnect()
                    end)
                end
            end
            Toggle_Obj.Update_Anim = Toggle_Anim
            local TL_Conn_1 = Sub_List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Is_Toggled then
                    local Height_Val = Sub_List.AbsoluteContentSize.Y
                    if Height_Val > 0 then Height_Val = Height_Val + 6 end
                    Sub_Container.Size = UDim2.new(1, 0, 0, Height_Val)
                end
            end)
            table.insert(Library_Table.Connections, TL_Conn_1)
            local TL_Conn_2 = Btn_Obj.MouseButton1Click:Connect(function()
                Is_Toggled = not Is_Toggled
                Library_Table.Is_Unsaved = true
                Toggle_Anim()
                Callback_Func(Is_Toggled)
            end)
            table.insert(Library_Table.Connections, TL_Conn_2)
            if Is_Toggled then Toggle_Anim() end
            Apply_Tooltip(Btn_Obj, Tooltip_Text)
            task.spawn(Callback_Func, Is_Toggled)
            return Toggle_Obj
        end
        function Section_Object:TextBox(Input_Text, Input_Flag, Placeholder_Str, Tooltip_Text, Callback_Func)
            Library_Table.Defaults[Input_Flag] = ""
            local Frame_Obj = Instance.new("Frame")
            Frame_Obj.Size = UDim2.new(1, 0, 0, 50)
            Frame_Obj.BackgroundTransparency = 1
            Frame_Obj.Parent = Content_Frame
            local Label_Obj = Instance.new("TextLabel")
            Label_Obj.Text = Input_Text
            Label_Obj.Font = Config_Table.Font_Main
            Label_Obj.TextSize = 13
            Label_Obj.TextColor3 = Theme_Table.Text
            Label_Obj.Size = UDim2.new(1, 0, 0, 20)
            Label_Obj.Position = UDim2.new(0, 5, 0, 0)
            Label_Obj.TextXAlignment = Enum.TextXAlignment.Left
            Label_Obj.BackgroundTransparency = 1
            Label_Obj.Parent = Frame_Obj
            local Box_Container = Instance.new("Frame")
            Box_Container.Size = UDim2.new(1, 0, 0, 28)
            Box_Container.Position = UDim2.new(0, 0, 0, 22)
            Box_Container.BackgroundColor3 = Theme_Table.Container
            Box_Container.Parent = Frame_Obj
            Create_Corner(Box_Container, 4)
            Create_Stroke(Box_Container, Theme_Table.Stroke, 1, 0.5)
            local Text_Input = Instance.new("TextBox")
            Text_Input.Size = UDim2.new(1, -10, 1, 0)
            Text_Input.Position = UDim2.new(0, 5, 0, 0)
            Text_Input.BackgroundTransparency = 1
            Text_Input.TextColor3 = Theme_Table.Text
            Text_Input.PlaceholderText = Placeholder_Str
            Text_Input.PlaceholderColor3 = Theme_Table.Text_Dark
            Text_Input.Font = Config_Table.Font_Main
            Text_Input.TextSize = 13
            Text_Input.TextXAlignment = Enum.TextXAlignment.Left
            local Current_Text = Library_Table.Flags[Input_Flag] or ""
            Text_Input.Text = Current_Text
            Text_Input.ClearTextOnFocus = false
            Text_Input.Parent = Box_Container
            local I_Conn_1 = Text_Input.FocusLost:Connect(function(Enter_Pressed)
                if Enter_Pressed then
                    Library_Table.Flags[Input_Flag] = Text_Input.Text
                    Library_Table.Is_Unsaved = true
                    Callback_Func(Text_Input.Text)
                end
            end)
            local I_Conn_2 = Text_Input.Changed:Connect(function(Prop_Name)
                if Prop_Name == "Text" then Library_Table.Flags[Input_Flag] = Text_Input.Text end
            end)
            table.insert(Library_Table.Connections, I_Conn_1)
            table.insert(Library_Table.Connections, I_Conn_2)
            Library_Table.Flags[Input_Flag] = Current_Text
            Library_Table.Signals[Input_Flag] = function(Loaded_Val)
                Text_Input.Text = Loaded_Val
                Library_Table.Is_Unsaved = true
                Callback_Func(Loaded_Val)
            end
            Apply_Tooltip(Frame_Obj, Tooltip_Text)
            task.spawn(Callback_Func, Current_Text)
            return Text_Input
        end
        function Section_Object:Dropdown(DD_Text, DD_Flag, Options_List, Default_Val, Tooltip_Text, Callback_Func, Custom_Parent, Is_Multi)
            return Create_Dropdown_Element(DD_Text, DD_Flag, Options_List, Default_Val, Tooltip_Text, Callback_Func, Content_Frame, Section_Object, Is_Multi, Custom_Parent)
        end
        function Section_Object:ColorPicker(Picker_Text, Picker_Flag, Default_Color, Tooltip_Text, Callback_Func)
            local Current_Color = Library_Table.Flags[Picker_Flag] or Default_Color or Color3.fromRGB(255, 255, 255)
            Library_Table.Defaults[Picker_Flag] = Default_Color or Color3.fromRGB(255, 255, 255)
            Library_Table.Flags[Picker_Flag] = Current_Color
            local H_Val, S_Val, V_Val = Current_Color:ToHSV()
            local Is_Picker_Open = false
            local Container_Frame = Instance.new("Frame")
            Container_Frame.Size = UDim2.new(1, 0, 0, 30)
            Container_Frame.BackgroundTransparency = 1
            Container_Frame.Parent = Content_Frame
            local Frame_Obj = Instance.new("Frame")
            Frame_Obj.Size = UDim2.new(1, 0, 0, 30)
            Frame_Obj.BackgroundTransparency = 1
            Frame_Obj.Parent = Container_Frame
            Frame_Obj.ZIndex = 5
            local Label_Obj = Instance.new("TextLabel")
            Label_Obj.Text = Picker_Text
            Label_Obj.Font = Config_Table.Font_Main
            Label_Obj.TextSize = 13
            Label_Obj.TextColor3 = Theme_Table.Text
            Label_Obj.Size = UDim2.new(0.6, 0, 1, 0)
            Label_Obj.Position = UDim2.new(0, 5, 0, 0)
            Label_Obj.TextXAlignment = Enum.TextXAlignment.Left
            Label_Obj.BackgroundTransparency = 1
            Label_Obj.Parent = Frame_Obj
            local Preview_Btn = Instance.new("TextButton")
            Preview_Btn.Size = UDim2.new(0, 40, 0, 20)
            Preview_Btn.Position = UDim2.new(1, -5, 0.5, 0)
            Preview_Btn.AnchorPoint = Vector2.new(1, 0.5)
            Preview_Btn.BackgroundColor3 = Current_Color
            Preview_Btn.AutoButtonColor = false
            Preview_Btn.Text = ""
            Preview_Btn.Parent = Frame_Obj
            Create_Corner(Preview_Btn, 4)
            Create_Stroke(Preview_Btn, Theme_Table.Stroke, 1, 0.5)
            local Picker_Content = Instance.new("Frame")
            Picker_Content.Size = UDim2.new(1, 0, 0, 0)
            Picker_Content.Position = UDim2.new(0, 0, 0, 30)
            Picker_Content.BackgroundColor3 = Theme_Table.Background
            Picker_Content.Parent = Container_Frame
            Picker_Content.ClipsDescendants = true
            Picker_Content.Visible = false
            Picker_Content.ZIndex = 10
            Create_Corner(Picker_Content, 4)
            local SV_Map = Instance.new("ImageLabel")
            SV_Map.Size = UDim2.new(0, 140, 0, 120)
            SV_Map.Position = UDim2.new(0, 10, 0, 10)
            SV_Map.Image = "rbxassetid://4155801252"
            SV_Map.BackgroundColor3 = Color3.fromHSV(H_Val, 1, 1)
            SV_Map.Parent = Picker_Content
            SV_Map.ZIndex = 11
            SV_Map.Active = true
            Create_Corner(SV_Map, 4)
            local SV_Cursor = Instance.new("Frame")
            SV_Cursor.Size = UDim2.new(0, 8, 0, 8)
            SV_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            SV_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
            SV_Cursor.Parent = SV_Map
            SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
            SV_Cursor.ZIndex = 12
            Create_Corner(SV_Cursor, 4)
            local Hue_Bar = Instance.new("ImageLabel")
            Hue_Bar.Size = UDim2.new(0, 20, 0, 120)
            Hue_Bar.Position = UDim2.new(0, 160, 0, 10)
            Hue_Bar.Image = "rbxassetid://4155801252"
            Hue_Bar.Parent = Picker_Content
            Hue_Bar.ZIndex = 11
            Hue_Bar.Active = true
            Create_Corner(Hue_Bar, 4)
            local UI_Gradient = Instance.new("UIGradient")
            UI_Gradient.Rotation = 90
            UI_Gradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            UI_Gradient.Parent = Hue_Bar
            local H_Cursor = Instance.new("Frame")
            H_Cursor.Size = UDim2.new(1, 0, 0, 2)
            H_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
            H_Cursor.Parent = Hue_Bar
            H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
            H_Cursor.ZIndex = 12
            local Hex_Input = Instance.new("TextBox")
            Hex_Input.Size = UDim2.new(0, 170, 0, 20)
            Hex_Input.Position = UDim2.new(0, 10, 0, 140)
            Hex_Input.BackgroundColor3 = Theme_Table.Container
            Hex_Input.TextColor3 = Theme_Table.Text
            Hex_Input.Font = Config_Table.Font_Main
            Hex_Input.TextSize = 12
            Hex_Input.Text = "#" .. Current_Color:ToHex()
            Hex_Input.Parent = Picker_Content
            Hex_Input.ZIndex = 11
            Create_Corner(Hex_Input, 4)
            Create_Stroke(Hex_Input, Theme_Table.Stroke, 1)
            local function Update_Color()
                Current_Color = Color3.fromHSV(H_Val, S_Val, V_Val)
                Preview_Btn.BackgroundColor3 = Current_Color
                SV_Map.BackgroundColor3 = Color3.fromHSV(H_Val, 1, 1)
                Hex_Input.Text = "#" .. Current_Color:ToHex()
                Library_Table.Flags[Picker_Flag] = Current_Color
                Library_Table.Is_Unsaved = true
                Callback_Func(Current_Color)
            end
            local H_Conn_1 = Hex_Input.FocusLost:Connect(function()
                local Text_Val = Hex_Input.Text:gsub("#", "")
                if Text_Val:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                    pcall(function()
                        local New_Color = Color3.fromHex(Text_Val)
                        H_Val, S_Val, V_Val = New_Color:ToHSV()
                        H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
                        SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
                        Update_Color()
                    end)
                else
                    Hex_Input.Text = "#" .. Current_Color:ToHex()
                end
            end)
            table.insert(Library_Table.Connections, H_Conn_1)
            Library_Table.Signals[Picker_Flag] = function(Loaded_Val)
                if typeof(Loaded_Val) == "Color3" then
                    Current_Color = Loaded_Val
                    H_Val, S_Val, V_Val = Current_Color:ToHSV()
                    H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
                    SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
                    Update_Color()
                end
            end
            local function Set_SV_From_Input(Input_Obj)
                local Ratio_X = math.clamp((Input_Obj.Position.X - SV_Map.AbsolutePosition.X) / SV_Map.AbsoluteSize.X, 0, 1)
                local Ratio_Y = math.clamp((Input_Obj.Position.Y - SV_Map.AbsolutePosition.Y) / SV_Map.AbsoluteSize.Y, 0, 1)
                S_Val = Ratio_X
                V_Val = 1 - Ratio_Y
                SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
                Update_Color()
            end
            local function Set_H_From_Input(Input_Obj)
                local Ratio_Y = math.clamp((Input_Obj.Position.Y - Hue_Bar.AbsolutePosition.Y) / Hue_Bar.AbsoluteSize.Y, 0, 1)
                H_Val = Ratio_Y
                H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
                Update_Color()
            end
            local Is_Dragging_SV = false
            local SV_Conn_1 = SV_Map.InputBegan:Connect(function(Input_Obj)
                if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                    Is_Dragging_SV = true
                    Set_SV_From_Input(Input_Obj)
                end
            end)
            local SV_Conn_2 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
                if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                    if Is_Dragging_SV then Is_Dragging_SV = false end
                end
            end)
            local SV_Conn_3 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
                if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                    if Is_Dragging_SV then Set_SV_From_Input(Input_Obj) end
                end
            end)
            table.insert(Library_Table.Connections, SV_Conn_1)
            table.insert(Library_Table.Connections, SV_Conn_2)
            table.insert(Library_Table.Connections, SV_Conn_3)
            local Is_Dragging_H = false
            local H_Conn_2 = Hue_Bar.InputBegan:Connect(function(Input_Obj)
                if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                    Is_Dragging_H = true
                    Set_H_From_Input(Input_Obj)
                end
            end)
            local H_Conn_3 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
                if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                    if Is_Dragging_H then Is_Dragging_H = false end
                end
            end)
            local H_Conn_4 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
                if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                    if Is_Dragging_H then Set_H_From_Input(Input_Obj) end
                end
            end)
            table.insert(Library_Table.Connections, H_Conn_2)
            table.insert(Library_Table.Connections, H_Conn_3)
            table.insert(Library_Table.Connections, H_Conn_4)
            local P_Conn_1 = Preview_Btn.MouseButton1Click:Connect(function()
                Is_Picker_Open = not Is_Picker_Open
                Section_Object.Container.ZIndex = Is_Picker_Open and 10 or 1
                Container_Frame.ZIndex = Is_Picker_Open and 10 or 5
                if Is_Picker_Open then
                    Picker_Content.Visible = true
                    Create_Tween(Container_Frame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                    Create_Tween(Picker_Content, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                else
                    Create_Tween(Container_Frame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                    local Tween_Obj = Create_Tween(Picker_Content, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    local P_Conn_2
                    P_Conn_2 = Tween_Obj.Completed:Connect(function()
                        if not Is_Picker_Open then Picker_Content.Visible = false end
                        P_Conn_2:Disconnect()
                    end)
                end
            end)
            table.insert(Library_Table.Connections, P_Conn_1)
            Apply_Tooltip(Container_Frame, Tooltip_Text)
            task.spawn(Callback_Func, Current_Color)
        end
        return Section_Object
    end
    local function Populate_Settings()
        local Set_Page = Instance.new("ScrollingFrame")
        Set_Page.Size = UDim2.new(1, -200, 1, -20)
        Set_Page.Position = UDim2.new(0, 190, 0, 10)
        Set_Page.BackgroundTransparency = 1
        Set_Page.ScrollBarThickness = 2
        Set_Page.ScrollBarImageColor3 = Theme_Table.Accent
        Set_Page.Active = true
        Set_Page.Parent = Settings_Win
        Register_Theme(Set_Page, "ScrollBar")
        local List_Layout = Instance.new("UIListLayout")
        List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
        List_Layout.Padding = UDim.new(0, 10)
        List_Layout.Parent = Set_Page
        local Conn_1 = List_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Set_Page.CanvasSize = UDim2.new(0, 0, 0, List_Layout.AbsoluteContentSize.Y + 20)
        end)
        table.insert(Library_Table.Connections, Conn_1)
        local Menu_Section = Window_Object:Create_Raw_Section("Menu Settings", Set_Page)
        Menu_Section:Button("Unload UI", "Destroys the Hub", function()
            Library_Table:Unload_Library()
        end)
        local Keybind_Btn
        Keybind_Btn = Menu_Section:Button("Menu Keybind: " .. tostring(Config_Table.Keybind.Name), "Change the open/close key", function()
            Keybind_Btn.Text = "Press any key..."
            local Key_Conn
            Key_Conn = User_Input_Service.InputBegan:Connect(function(Input_Obj)
                if Input_Obj.UserInputType == Enum.UserInputType.Keyboard then
                    if Input_Obj.KeyCode == Enum.KeyCode.Backspace or Input_Obj.KeyCode == Enum.KeyCode.Delete then
                        Config_Table.Keybind = Enum.KeyCode.LeftControl
                    elseif Input_Obj.KeyCode ~= Enum.KeyCode.Escape and Input_Obj.KeyCode ~= Enum.KeyCode.Unknown then
                        Config_Table.Keybind = Input_Obj.KeyCode
                    end
                    Keybind_Btn.Text = "Menu Keybind: " .. tostring(Config_Table.Keybind.Name)
                    Library_Table:Notify_User("Settings", "Menu keybind set to " .. tostring(Config_Table.Keybind.Name), 2)
                    Key_Conn:Disconnect()
                end
            end)
        end)
        Menu_Section:Toggle("Show Keybind List", "KeybindListToggle", true, "Show the active keybinds widget", function(State_Val)
            Library_Table.Show_Keybinds = State_Val
            if Library_Table.Keybind_List then
                Library_Table.Keybind_List.Frame.Visible = State_Val and (#Library_Table.Keybind_List.Container:GetChildren() > 1)
            end
        end)
        Menu_Section:ColorPicker("Accent Color", "MenuAccentColor", Theme_Table.Accent, "Change the theme color", function(Color_Val)
            Library_Table:Update_Theme(Color_Val)
        end)
        local Config_Section = Window_Object:Create_Raw_Section("Configuration", Set_Page)
        local Config_Content = Config_Section.Container:FindFirstChild("Content")
        local Config_Name_Input = ""
        local Selected_Config_Name = ""
        local Config_List = Library_Table:Get_Configs()
        local CName_Frame = Instance.new("Frame")
        CName_Frame.Size = UDim2.new(1, 0, 0, 50)
        CName_Frame.BackgroundTransparency = 1
        CName_Frame.LayoutOrder = 1
        CName_Frame.Parent = Config_Content
        local CName_Label = Instance.new("TextLabel")
        CName_Label.Text = "Config Name"
        CName_Label.Font = Config_Table.Font_Main
        CName_Label.TextSize = 13
        CName_Label.TextColor3 = Theme_Table.Text
        CName_Label.Size = UDim2.new(1, 0, 0, 20)
        CName_Label.Position = UDim2.new(0, 5, 0, 0)
        CName_Label.TextXAlignment = Enum.TextXAlignment.Left
        CName_Label.BackgroundTransparency = 1
        CName_Label.Parent = CName_Frame
        local CName_Box_Cont = Instance.new("Frame")
        CName_Box_Cont.Size = UDim2.new(1, 0, 0, 28)
        CName_Box_Cont.Position = UDim2.new(0, 0, 0, 22)
        CName_Box_Cont.BackgroundColor3 = Theme_Table.Container
        CName_Box_Cont.Parent = CName_Frame
        Create_Corner(CName_Box_Cont, 4)
        Create_Stroke(CName_Box_Cont, Theme_Table.Stroke, 1, 0.5)
        local CName_Input_Box = Instance.new("TextBox")
        CName_Input_Box.Size = UDim2.new(1, -10, 1, 0)
        CName_Input_Box.Position = UDim2.new(0, 5, 0, 0)
        CName_Input_Box.BackgroundTransparency = 1
        CName_Input_Box.TextColor3 = Theme_Table.Text
        CName_Input_Box.PlaceholderText = "Type config name..."
        CName_Input_Box.PlaceholderColor3 = Theme_Table.Text_Dark
        CName_Input_Box.Font = Config_Table.Font_Main
        CName_Input_Box.TextSize = 13
        CName_Input_Box.TextXAlignment = Enum.TextXAlignment.Left
        CName_Input_Box.Text = ""
        CName_Input_Box.ClearTextOnFocus = false
        CName_Input_Box.Parent = CName_Box_Cont
        local Conn_2 = CName_Input_Box:GetPropertyChangedSignal("Text"):Connect(function()
            Config_Name_Input = CName_Input_Box.Text
        end)
        table.insert(Library_Table.Connections, Conn_2)
        local Config_DD_Frame = Instance.new("Frame")
        Config_DD_Frame.Size = UDim2.new(1, 0, 0, 46)
        Config_DD_Frame.BackgroundTransparency = 1
        Config_DD_Frame.LayoutOrder = 2
        Config_DD_Frame.Parent = Config_Content
        local CD_Label = Instance.new("TextLabel")
        CD_Label.Text = "Select Config"
        CD_Label.Font = Config_Table.Font_Main
        CD_Label.TextSize = 13
        CD_Label.TextColor3 = Theme_Table.Text
        CD_Label.Size = UDim2.new(1, 0, 0, 16)
        CD_Label.Position = UDim2.new(0, 5, 0, 0)
        CD_Label.TextXAlignment = Enum.TextXAlignment.Left
        CD_Label.BackgroundTransparency = 1
        CD_Label.Parent = Config_DD_Frame
        local CD_Interactive = Instance.new("TextButton")
        CD_Interactive.Size = UDim2.new(1, 0, 0, 26)
        CD_Interactive.Position = UDim2.new(0, 0, 0, 20)
        CD_Interactive.BackgroundColor3 = Theme_Table.Container
        CD_Interactive.Text = ""
        CD_Interactive.AutoButtonColor = false
        CD_Interactive.Parent = Config_DD_Frame
        CD_Interactive.ZIndex = 5
        Create_Corner(CD_Interactive, 4)
        Create_Stroke(CD_Interactive, Theme_Table.Stroke, 1, 0.5)
        local CD_Selected_Text = Instance.new("TextLabel")
        CD_Selected_Text.Font = Config_Table.Font_Main
        CD_Selected_Text.TextSize = 13
        CD_Selected_Text.TextColor3 = Theme_Table.Text
        CD_Selected_Text.Size = UDim2.new(1, -25, 1, 0)
        CD_Selected_Text.Position = UDim2.new(0, 8, 0, 0)
        CD_Selected_Text.TextXAlignment = Enum.TextXAlignment.Left
        CD_Selected_Text.BackgroundTransparency = 1
        CD_Selected_Text.ZIndex = 6
        CD_Selected_Text.ClipsDescendants = false
        CD_Selected_Text.TextTruncate = Enum.TextTruncate.AtEnd
        CD_Selected_Text.Parent = CD_Interactive
        local CD_Arrow = Instance.new("ImageLabel")
        CD_Arrow.Image = "rbxassetid://10709790948"
        CD_Arrow.Size = UDim2.new(0, 18, 0, 18)
        CD_Arrow.Position = UDim2.new(1, -20, 0.5, 0)
        CD_Arrow.AnchorPoint = Vector2.new(0, 0.5)
        CD_Arrow.BackgroundTransparency = 1
        CD_Arrow.ImageColor3 = Theme_Table.Text_Dark
        CD_Arrow.Parent = CD_Interactive
        CD_Arrow.ZIndex = 6
        local CD_List_Frame = Instance.new("ScrollingFrame")
        CD_List_Frame.Size = UDim2.new(1, 0, 0, 0)
        CD_List_Frame.Position = UDim2.new(0, 0, 1, 5)
        CD_List_Frame.BackgroundColor3 = Theme_Table.Container
        CD_List_Frame.BorderSizePixel = 0
        CD_List_Frame.Parent = CD_Interactive
        CD_List_Frame.ZIndex = 10
        CD_List_Frame.Visible = false
        CD_List_Frame.Active = true
        CD_List_Frame.ScrollBarThickness = 2
        CD_List_Frame.ScrollBarImageColor3 = Theme_Table.Accent
        Create_Corner(CD_List_Frame, 4)
        Create_Stroke(CD_List_Frame, Theme_Table.Stroke, 1, 0.5)
        local CD_List_Layout = Instance.new("UIListLayout")
        CD_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
        CD_List_Layout.Parent = CD_List_Frame
        local Conn_3 = CD_List_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            CD_List_Frame.CanvasSize = UDim2.new(0, 0, 0, CD_List_Layout.AbsoluteContentSize.Y)
        end)
        table.insert(Library_Table.Connections, Conn_3)
        local CD_Is_Dropped = false
        local CD_Option_Btns = {}
        Selected_Config_Name = #Config_List > 0 and Config_List[1] or ""
        CD_Selected_Text.Text = Selected_Config_Name ~= "" and Selected_Config_Name or "No configs"
        local function CD_Close_Dropdown()
            CD_Is_Dropped = false
            Config_Section.Container.ZIndex = 1
            Config_DD_Frame.ZIndex = 5
            Create_Tween(Config_DD_Frame, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
            local Tween_Obj = Create_Tween(CD_List_Frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Create_Tween(CD_Arrow, {Rotation = 0}, 0.2)
            local Conn_4
            Conn_4 = Tween_Obj.Completed:Connect(function()
                if not CD_Is_Dropped then CD_List_Frame.Visible = false end
                Conn_4:Disconnect()
            end)
        end
        local function CD_Build_Options(Options_Arr)
            for _, Btn_Obj in pairs(CD_Option_Btns) do Btn_Obj:Destroy() end
            table.clear(CD_Option_Btns)
            for _, Opt_Val in ipairs(Options_Arr) do
                local Opt_Btn = Instance.new("TextButton")
                Opt_Btn.Size = UDim2.new(1, 0, 0, 24)
                Opt_Btn.BackgroundColor3 = Theme_Table.Container
                Opt_Btn.BackgroundTransparency = 1
                Opt_Btn.Text = Opt_Val
                Opt_Btn.Font = Config_Table.Font_Main
                Opt_Btn.TextSize = 12
                Opt_Btn.Parent = CD_List_Frame
                Opt_Btn.ZIndex = 11
                Opt_Btn.TextColor3 = (Selected_Config_Name == Opt_Val) and Theme_Table.Accent or Theme_Table.Text_Dark
                CD_Option_Btns[Opt_Val] = Opt_Btn
                local Conn_5 = Opt_Btn.MouseEnter:Connect(function()
                    if Selected_Config_Name ~= Opt_Val then Create_Tween(Opt_Btn, {BackgroundTransparency = 0.8, TextColor3 = Theme_Table.Accent}) end
                end)
                local Conn_6 = Opt_Btn.MouseLeave:Connect(function()
                    if Selected_Config_Name ~= Opt_Val then Create_Tween(Opt_Btn, {BackgroundTransparency = 1, TextColor3 = Theme_Table.Text_Dark}) end
                end)
                local Conn_7 = Opt_Btn.MouseButton1Click:Connect(function()
                    Selected_Config_Name = Opt_Val
                    CD_Selected_Text.Text = Opt_Val
                    for Opt_Key, Opt_Val_Btn in pairs(CD_Option_Btns) do Opt_Val_Btn.TextColor3 = (Opt_Key == Opt_Val) and Theme_Table.Accent or Theme_Table.Text_Dark end
                    CD_Close_Dropdown()
                end)
                table.insert(Library_Table.Connections, Conn_5)
                table.insert(Library_Table.Connections, Conn_6)
                table.insert(Library_Table.Connections, Conn_7)
            end
        end
        CD_Build_Options(Config_List)
        local Conn_8 = CD_Interactive.MouseButton1Click:Connect(function()
            CD_Is_Dropped = not CD_Is_Dropped
            Config_Section.Container.ZIndex = CD_Is_Dropped and 10 or 1
            Config_DD_Frame.ZIndex = CD_Is_Dropped and 10 or 5
            if CD_Is_Dropped then
                CD_List_Frame.Visible = true
                local Current_List = Library_Table:Get_Configs()
                CD_Build_Options(Current_List)
                local List_Height = math.min(#Current_List * 24, 200)
                if List_Height < 24 then List_Height = 24 end
                local Total_Height = 46 + List_Height + 5
                Create_Tween(Config_DD_Frame, {Size = UDim2.new(1, 0, 0, Total_Height)}, 0.2)
                Create_Tween(CD_List_Frame, {Size = UDim2.new(1, 0, 0, List_Height)}, 0.2)
                Create_Tween(CD_Arrow, {Rotation = 180}, 0.2)
            else
                CD_Close_Dropdown()
            end
        end)
        table.insert(Library_Table.Connections, Conn_8)
        local function Refresh_Config_Dropdown()
            local New_List = Library_Table:Get_Configs()
            Config_List = New_List
            if not table.find(New_List, Selected_Config_Name) then
                Selected_Config_Name = #New_List > 0 and New_List[1] or ""
            end
            CD_Selected_Text.Text = Selected_Config_Name ~= "" and Selected_Config_Name or "No configs"
            CD_Build_Options(New_List)
        end
        local Create_Btn = Instance.new("TextButton")
        Create_Btn.Size = UDim2.new(1, 0, 0, 32)
        Create_Btn.BackgroundColor3 = Theme_Table.Container
        Create_Btn.Text = "Create New Config"
        Create_Btn.Font = Config_Table.Font_Main
        Create_Btn.TextSize = 13
        Create_Btn.TextColor3 = Theme_Table.Text
        Create_Btn.AutoButtonColor = false
        Create_Btn.LayoutOrder = 3
        Create_Btn.Parent = Config_Content
        Create_Corner(Create_Btn, 4)
        local CS_Stroke_1 = Create_Stroke(Create_Btn, Theme_Table.Stroke, 1, 0.5)
        local Conn_9 = Create_Btn.MouseEnter:Connect(function() Create_Tween(Create_Btn, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(CS_Stroke_1, {Color = Theme_Table.Accent}) end)
        local Conn_10 = Create_Btn.MouseLeave:Connect(function() Create_Tween(Create_Btn, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(CS_Stroke_1, {Color = Theme_Table.Stroke}) end)
        local Conn_11 = Create_Btn.MouseButton1Click:Connect(function()
            local Config_Name_Str = Config_Name_Input
            if not Config_Name_Str or Config_Name_Str == "" or string.match(Config_Name_Str, "^%s*$") then
                Library_Table:Notify_User("Error", "Please type a config name first", 3)
                return
            end
            Config_Name_Str = string.gsub(Config_Name_Str, "^%s+", "")
            Config_Name_Str = string.gsub(Config_Name_Str, "%s+$", "")
            if Config_Name_Str == "" then
                Library_Table:Notify_User("Error", "Please type a config name first", 3)
                return
            end
            if Library_Table:Config_Exists(Config_Name_Str) then
                Library_Table:Notify_User("Error", "Config '" .. Config_Name_Str .. "' already exists", 3)
                return
            end
            if Library_Table:Save_Config(Config_Name_Str) then
                Selected_Config_Name = Config_Name_Str
                CName_Input_Box.Text = ""
                Config_Name_Input = ""
                Refresh_Config_Dropdown()
                Library_Table:Notify_User("Config", "Created: " .. Config_Name_Str, 3)
            else
                Library_Table:Notify_User("Error", "Failed to create config", 3)
            end
        end)
        table.insert(Library_Table.Connections, Conn_9)
        table.insert(Library_Table.Connections, Conn_10)
        table.insert(Library_Table.Connections, Conn_11)
        local Load_Btn = Instance.new("TextButton")
        Load_Btn.Size = UDim2.new(1, 0, 0, 32)
        Load_Btn.BackgroundColor3 = Theme_Table.Container
        Load_Btn.Text = "Load Config"
        Load_Btn.Font = Config_Table.Font_Main
        Load_Btn.TextSize = 13
        Load_Btn.TextColor3 = Theme_Table.Text
        Load_Btn.AutoButtonColor = false
        Load_Btn.LayoutOrder = 4
        Load_Btn.Parent = Config_Content
        Create_Corner(Load_Btn, 4)
        local CS_Stroke_2 = Create_Stroke(Load_Btn, Theme_Table.Stroke, 1, 0.5)
        local Conn_12 = Load_Btn.MouseEnter:Connect(function() Create_Tween(Load_Btn, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(CS_Stroke_2, {Color = Theme_Table.Accent}) end)
        local Conn_13 = Load_Btn.MouseLeave:Connect(function() Create_Tween(Load_Btn, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(CS_Stroke_2, {Color = Theme_Table.Stroke}) end)
        local Conn_14 = Load_Btn.MouseButton1Click:Connect(function()
            local Config_Name_Str = Selected_Config_Name
            if not Config_Name_Str or Config_Name_Str == "" then
                Library_Table:Notify_User("Error", "No config selected", 3)
                return
            end
            if not Library_Table:Config_Exists(Config_Name_Str) then
                Library_Table:Notify_User("Error", "Config '" .. Config_Name_Str .. "' does not exist", 3)
                return
            end
            if Library_Table:Load_Config(Config_Name_Str) then
                Library_Table:Notify_User("Config", "Loaded: " .. Config_Name_Str, 3)
            else
                Library_Table:Notify_User("Error", "Failed to load config", 3)
            end
        end)
        table.insert(Library_Table.Connections, Conn_12)
        table.insert(Library_Table.Connections, Conn_13)
        table.insert(Library_Table.Connections, Conn_14)
        local Rewrite_Btn = Instance.new("TextButton")
        Rewrite_Btn.Size = UDim2.new(1, 0, 0, 32)
        Rewrite_Btn.BackgroundColor3 = Theme_Table.Container
        Rewrite_Btn.Text = "Rewrite Config"
        Rewrite_Btn.Font = Config_Table.Font_Main
        Rewrite_Btn.TextSize = 13
        Rewrite_Btn.TextColor3 = Theme_Table.Text
        Rewrite_Btn.AutoButtonColor = false
        Rewrite_Btn.LayoutOrder = 5
        Rewrite_Btn.Parent = Config_Content
        Create_Corner(Rewrite_Btn, 4)
        local CS_Stroke_3 = Create_Stroke(Rewrite_Btn, Theme_Table.Stroke, 1, 0.5)
        local Conn_15 = Rewrite_Btn.MouseEnter:Connect(function() Create_Tween(Rewrite_Btn, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(CS_Stroke_3, {Color = Theme_Table.Accent}) end)
        local Conn_16 = Rewrite_Btn.MouseLeave:Connect(function() Create_Tween(Rewrite_Btn, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(CS_Stroke_3, {Color = Theme_Table.Stroke}) end)
        local Conn_17 = Rewrite_Btn.MouseButton1Click:Connect(function()
            local Config_Name_Str = Selected_Config_Name
            if not Config_Name_Str or Config_Name_Str == "" then
                Library_Table:Notify_User("Error", "No config selected", 3)
                return
            end
            if not Library_Table:Config_Exists(Config_Name_Str) then
                Library_Table:Notify_User("Error", "Config '" .. Config_Name_Str .. "' does not exist", 3)
                return
            end
            if Library_Table:Save_Config(Config_Name_Str) then
                Library_Table:Notify_User("Config", "Rewritten: " .. Config_Name_Str, 3)
            else
                Library_Table:Notify_User("Error", "Failed to rewrite config", 3)
            end
        end)
        table.insert(Library_Table.Connections, Conn_15)
        table.insert(Library_Table.Connections, Conn_16)
        table.insert(Library_Table.Connections, Conn_17)
        local Delete_Btn = Instance.new("TextButton")
        Delete_Btn.Size = UDim2.new(1, 0, 0, 32)
        Delete_Btn.BackgroundColor3 = Theme_Table.Container
        Delete_Btn.Text = "Delete Config"
        Delete_Btn.Font = Config_Table.Font_Main
        Delete_Btn.TextSize = 13
        Delete_Btn.TextColor3 = Theme_Table.Text
        Delete_Btn.AutoButtonColor = false
        Delete_Btn.LayoutOrder = 6
        Delete_Btn.Parent = Config_Content
        Create_Corner(Delete_Btn, 4)
        local CS_Stroke_4 = Create_Stroke(Delete_Btn, Theme_Table.Stroke, 1, 0.5)
        local Conn_18 = Delete_Btn.MouseEnter:Connect(function() Create_Tween(Delete_Btn, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(CS_Stroke_4, {Color = Theme_Table.Accent}) end)
        local Conn_19 = Delete_Btn.MouseLeave:Connect(function() Create_Tween(Delete_Btn, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(CS_Stroke_4, {Color = Theme_Table.Stroke}) end)
        local Conn_20 = Delete_Btn.MouseButton1Click:Connect(function()
            local Config_Name_Str = Selected_Config_Name
            if not Config_Name_Str or Config_Name_Str == "" then
                Library_Table:Notify_User("Error", "No config selected", 3)
                return
            end
            if not Library_Table:Config_Exists(Config_Name_Str) then
                Library_Table:Notify_User("Error", "Config '" .. Config_Name_Str .. "' does not exist", 3)
                return
            end
            if Library_Table:Delete_Config(Config_Name_Str) then
                Refresh_Config_Dropdown()
                Library_Table:Notify_User("Config", "Deleted: " .. Config_Name_Str, 3)
            else
                Library_Table:Notify_User("Error", "Failed to delete config", 3)
            end
        end)
        table.insert(Library_Table.Connections, Conn_18)
        table.insert(Library_Table.Connections, Conn_19)
        table.insert(Library_Table.Connections, Conn_20)
        local Refresh_Btn = Instance.new("TextButton")
        Refresh_Btn.Size = UDim2.new(1, 0, 0, 32)
        Refresh_Btn.BackgroundColor3 = Theme_Table.Container
        Refresh_Btn.Text = "Refresh Config List"
        Refresh_Btn.Font = Config_Table.Font_Main
        Refresh_Btn.TextSize = 13
        Refresh_Btn.TextColor3 = Theme_Table.Text
        Refresh_Btn.AutoButtonColor = false
        Refresh_Btn.LayoutOrder = 7
        Refresh_Btn.Parent = Config_Content
        Create_Corner(Refresh_Btn, 4)
        local CS_Stroke_5 = Create_Stroke(Refresh_Btn, Theme_Table.Stroke, 1, 0.5)
        local Conn_21 = Refresh_Btn.MouseEnter:Connect(function() Create_Tween(Refresh_Btn, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(CS_Stroke_5, {Color = Theme_Table.Accent}) end)
        local Conn_22 = Refresh_Btn.MouseLeave:Connect(function() Create_Tween(Refresh_Btn, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(CS_Stroke_5, {Color = Theme_Table.Stroke}) end)
        local Conn_23 = Refresh_Btn.MouseButton1Click:Connect(function()
            Refresh_Config_Dropdown()
            Library_Table:Notify_User("Config", "List Refreshed", 2)
        end)
        table.insert(Library_Table.Connections, Conn_21)
        table.insert(Library_Table.Connections, Conn_22)
        table.insert(Library_Table.Connections, Conn_23)
        local Reset_Btn = Instance.new("TextButton")
        Reset_Btn.Size = UDim2.new(1, 0, 0, 32)
        Reset_Btn.BackgroundColor3 = Theme_Table.Container
        Reset_Btn.Text = "Reset to Defaults"
        Reset_Btn.Font = Config_Table.Font_Main
        Reset_Btn.TextSize = 13
        Reset_Btn.TextColor3 = Theme_Table.Text
        Reset_Btn.AutoButtonColor = false
        Reset_Btn.LayoutOrder = 8
        Reset_Btn.Parent = Config_Content
        Create_Corner(Reset_Btn, 4)
        local CS_Stroke_6 = Create_Stroke(Reset_Btn, Theme_Table.Stroke, 1, 0.5)
        local Conn_24 = Reset_Btn.MouseEnter:Connect(function() Create_Tween(Reset_Btn, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(CS_Stroke_6, {Color = Theme_Table.Accent}) end)
        local Conn_25 = Reset_Btn.MouseLeave:Connect(function() Create_Tween(Reset_Btn, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(CS_Stroke_6, {Color = Theme_Table.Stroke}) end)
        local Conn_26 = Reset_Btn.MouseButton1Click:Connect(function()
            for Flag_Name, Flag_Val in pairs(Library_Table.Defaults) do
                if Ignored_Flags[Flag_Name] then continue end
                Library_Table.Flags[Flag_Name] = Flag_Val
                if Library_Table.Signals[Flag_Name] then
                    task.spawn(Library_Table.Signals[Flag_Name], Flag_Val)
                end
            end
            Library_Table:Notify_User("Settings", "Reset to defaults", 3)
        end)
        table.insert(Library_Table.Connections, Conn_24)
        table.insert(Library_Table.Connections, Conn_25)
        table.insert(Library_Table.Connections, Conn_26)
    end
    Populate_Settings()
    function Window_Object:Tab(Tab_Name, Icon_Id)
        local Tab_Object = {}
        local Page_Frame = Instance.new("ScrollingFrame")
        Page_Frame.Size = UDim2.new(1, -20, 1, -20)
        Page_Frame.Position = UDim2.new(0, 10, 0, 10)
        Page_Frame.BackgroundTransparency = 1
        Page_Frame.ScrollBarThickness = 0
        Page_Frame.Visible = false
        Page_Frame.Active = true
        Page_Frame.Parent = Main_Pages
        local Tab_Btn = Instance.new("TextButton")
        Tab_Btn.Size = UDim2.new(0, 160, 0, 36)
        Tab_Btn.BackgroundColor3 = Theme_Table.Background
        Tab_Btn.BackgroundTransparency = 1
        Tab_Btn.Text = ""
        Tab_Btn.AutoButtonColor = false
        Tab_Btn.Parent = Tab_Container_Frame
        Create_Corner(Tab_Btn, 6)
        local Title_Label = Instance.new("TextLabel")
        Title_Label.Text = Tab_Name
        Title_Label.Font = Config_Table.Font_Main
        Title_Label.TextSize = 14
        Title_Label.TextColor3 = Theme_Table.Text_Dark
        Title_Label.Size = UDim2.new(1, -20, 1, 0)
        Title_Label.Position = UDim2.new(0, Icon_Id and 35 or 15, 0, 0)
        Title_Label.TextXAlignment = Enum.TextXAlignment.Left
        Title_Label.BackgroundTransparency = 1
        Title_Label.Parent = Tab_Btn
        if Icon_Id then
            local Icon_Image = Instance.new("ImageLabel")
            Icon_Image.Size = UDim2.new(0, 20, 0, 20)
            Icon_Image.Position = UDim2.new(0, 8, 0.5, 0)
            Icon_Image.AnchorPoint = Vector2.new(0, 0.5)
            Icon_Image.BackgroundTransparency = 1
            if tonumber(Icon_Id) then Icon_Image.Image = "rbxassetid://" .. Icon_Id else Icon_Image.Image = Icon_Id end
            Icon_Image.ImageColor3 = Theme_Table.Text_Dark
            Icon_Image.Parent = Tab_Btn
            local Conn_1 = Tab_Btn.MouseEnter:Connect(function() if Tab_Btn.BackgroundTransparency > 0.5 then Create_Tween(Icon_Image, {ImageColor3 = Theme_Table.Text}) end end)
            local Conn_2 = Tab_Btn.MouseLeave:Connect(function() if Tab_Btn.BackgroundTransparency > 0.5 then Create_Tween(Icon_Image, {ImageColor3 = Theme_Table.Text_Dark}) end end)
            table.insert(Library_Table.Connections, Conn_1)
            table.insert(Library_Table.Connections, Conn_2)
        end
        local Indicator_Frame = Instance.new("Frame")
        Indicator_Frame.Size = UDim2.new(0, 3, 0, 16)
        Indicator_Frame.Position = UDim2.new(0, 0, 0.5, -8)
        Indicator_Frame.BackgroundColor3 = Theme_Table.Accent
        Indicator_Frame.BackgroundTransparency = 1
        Indicator_Frame.BorderSizePixel = 0
        Indicator_Frame.Parent = Tab_Btn
        Create_Corner(Indicator_Frame, 2)
        Register_Theme(Indicator_Frame, "BackgroundColor")
        local Conn_3 = Tab_Btn.MouseButton1Click:Connect(function()
            for _, Page_Element in pairs(Main_Pages:GetChildren()) do if Page_Element:IsA("ScrollingFrame") then Page_Element.Visible = false end end
            for _, Tab_Element in pairs(Tab_Container_Frame:GetChildren()) do
                if Tab_Element:IsA("TextButton") then
                    Create_Tween(Tab_Element.TextLabel, {TextColor3 = Theme_Table.Text_Dark})
                    Create_Tween(Tab_Element, {BackgroundTransparency = 1, BackgroundColor3 = Theme_Table.Background})
                    if Tab_Element:FindFirstChild("ImageLabel") then Create_Tween(Tab_Element.ImageLabel, {ImageColor3 = Theme_Table.Text_Dark}) end
                    Create_Tween(Tab_Element.Frame, {BackgroundTransparency = 1})
                end
            end
            Page_Frame.Visible = true
            Create_Tween(Title_Label, {TextColor3 = Theme_Table.Text})
            Create_Tween(Tab_Btn, {BackgroundTransparency = 0.95, BackgroundColor3 = Theme_Table.Text})
            if Tab_Btn:FindFirstChild("ImageLabel") then Create_Tween(Tab_Btn.ImageLabel, {ImageColor3 = Theme_Table.Text}) end
            Create_Tween(Indicator_Frame, {BackgroundTransparency = 0})
        end)
        table.insert(Library_Table.Connections, Conn_3)
        local Tab_Count = 0
        for _, Child_Element in pairs(Tab_Container_Frame:GetChildren()) do
            if Child_Element:IsA("TextButton") then Tab_Count = Tab_Count + 1 end
        end
        if Tab_Count <= 1 then
            Page_Frame.Visible = true
            Title_Label.TextColor3 = Theme_Table.Text
            Tab_Btn.BackgroundTransparency = 0.95
            Tab_Btn.BackgroundColor3 = Theme_Table.Text
            if Tab_Btn:FindFirstChild("ImageLabel") then Tab_Btn.ImageLabel.ImageColor3 = Theme_Table.Text end
            Indicator_Frame.BackgroundTransparency = 0
        end
        local Left_Column = Instance.new("Frame")
        Left_Column.Size = UDim2.new(0.5, -5, 1, 0)
        Left_Column.Position = UDim2.new(0, 0, 0, 0)
        Left_Column.BackgroundTransparency = 1
        Left_Column.Parent = Page_Frame
        local Left_List_Layout = Instance.new("UIListLayout")
        Left_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Left_List_Layout.Padding = UDim.new(0, 10)
        Left_List_Layout.Parent = Left_Column
        local Right_Column = Instance.new("Frame")
        Right_Column.Size = UDim2.new(0.5, -5, 1, 0)
        Right_Column.Position = UDim2.new(0.5, 5, 0, 0)
        Right_Column.BackgroundTransparency = 1
        Right_Column.Parent = Page_Frame
        local Right_List_Layout = Instance.new("UIListLayout")
        Right_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Right_List_Layout.Padding = UDim.new(0, 10)
        Right_List_Layout.Parent = Right_Column
        function Tab_Object:Section(Section_Text, Side_Str)
            local Section_Object = {}
            local Parent_Column = (Side_Str == "Right" and Right_Column or Left_Column)
            local Container_Frame = Instance.new("Frame")
            Container_Frame.Size = UDim2.new(1, 0, 0, 0)
            Container_Frame.BackgroundColor3 = Theme_Table.Section
            Container_Frame.Parent = Parent_Column
            Container_Frame.ZIndex = 1
            Create_Corner(Container_Frame, 6)
            Create_Stroke(Container_Frame, Theme_Table.Stroke, 1, 0.5)
            Section_Object.Container = Container_Frame
            local Section_Data = {Instance = Container_Frame, Items = {}}
            table.insert(Library_Table.Elements, Section_Data)
            local Section_Title = Instance.new("TextLabel")
            Section_Title.Text = Section_Text
            Section_Title.Font = Config_Table.Font_Bold
            Section_Title.TextSize = 12
            Section_Title.TextColor3 = Theme_Table.Text_Dark
            Section_Title.Size = UDim2.new(1, -20, 0, 25)
            Section_Title.Position = UDim2.new(0, 10, 0, 0)
            Section_Title.BackgroundTransparency = 1
            Section_Title.TextXAlignment = Enum.TextXAlignment.Left
            Section_Title.Parent = Container_Frame
            local Content_Frame = Instance.new("Frame")
            Content_Frame.Size = UDim2.new(1, -10, 0, 0)
            Content_Frame.Position = UDim2.new(0, 5, 0, 25)
            Content_Frame.BackgroundTransparency = 1
            Content_Frame.Parent = Container_Frame
            local List_Layout = Instance.new("UIListLayout")
            List_Layout.Padding = UDim.new(0, 6)
            List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
            List_Layout.Parent = Content_Frame
            local function Update_Section_Size()
                Container_Frame.Size = UDim2.new(1, 0, 0, List_Layout.AbsoluteContentSize.Y + 35)
                Page_Frame.CanvasSize = UDim2.new(0, 0, 0, math.max(Left_List_Layout.AbsoluteContentSize.Y, Right_List_Layout.AbsoluteContentSize.Y) + 20)
            end
            local Conn_4 = List_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Section_Size)
            table.insert(Library_Table.Connections, Conn_4)
            function Section_Object:Label(Label_Text, Opts_Table)
                Opts_Table = Opts_Table or {}
                local Label_Obj = {}
                local Frame_Obj = Instance.new("Frame")
                Frame_Obj.Size = UDim2.new(1, 0, 0, 26)
                Frame_Obj.BackgroundTransparency = 1
                Frame_Obj.Parent = Content_Frame
                table.insert(Section_Data.Items, {Name = Label_Text, Instance = Frame_Obj})
                local Text_Lbl = Instance.new("TextLabel")
                Text_Lbl.Size = UDim2.new(1, -10, 1, 0)
                Text_Lbl.Position = UDim2.new(0, 5, 0, 0)
                Text_Lbl.BackgroundTransparency = 1
                Text_Lbl.Text = tostring(Label_Text)
                Text_Lbl.Font = Config_Table.Font_Main
                Text_Lbl.TextSize = 13
                Text_Lbl.TextColor3 = Opts_Table.Color or Theme_Table.Text
                Text_Lbl.TextXAlignment = Opts_Table.Alignment or Enum.TextXAlignment.Left
                Text_Lbl.RichText = true
                Text_Lbl.TextWrapped = true
                Text_Lbl.Parent = Frame_Obj
                local function Update_Height()
                    local Text_Height = Text_Lbl.TextBounds.Y
                    if Text_Height > 16 then Frame_Obj.Size = UDim2.new(1, 0, 0, Text_Height + 10) else Frame_Obj.Size = UDim2.new(1, 0, 0, 26) end
                end
                local Bounds_Conn = Text_Lbl:GetPropertyChangedSignal("TextBounds"):Connect(Update_Height)
                table.insert(Library_Table.Connections, Bounds_Conn)
                Update_Height()
                function Label_Obj:Set(New_Text) Text_Lbl.Text = tostring(New_Text) end
                function Label_Obj:Set_Color(New_Color) Text_Lbl.TextColor3 = New_Color end
                return Label_Obj
            end
            function Section_Object:Toggle(Toggle_Text, Toggle_Flag, Default_Val, Tooltip_Text, Callback_Func)
                Library_Table.Defaults[Toggle_Flag] = Default_Val or false
                local Is_Toggled = Library_Table.Flags[Toggle_Flag]
                if Is_Toggled == nil then
                    Is_Toggled = Default_Val or false
                    Library_Table.Flags[Toggle_Flag] = Is_Toggled
                end
                local Toggle_Obj = {}
                Library_Table.Signals[Toggle_Flag] = function(Loaded_Val)
                    if Is_Toggled ~= Loaded_Val then
                        Is_Toggled = Loaded_Val
                        if Toggle_Obj.Update_Anim then Toggle_Obj.Update_Anim() end
                        Library_Table.Is_Unsaved = true
                        Callback_Func(Loaded_Val)
                    end
                end
                local Btn_Obj = Instance.new("TextButton")
                Btn_Obj.Size = UDim2.new(1, 0, 0, 32)
                Btn_Obj.BackgroundColor3 = Theme_Table.Container
                Btn_Obj.Text = ""
                Btn_Obj.AutoButtonColor = false
                Btn_Obj.Parent = Content_Frame
                table.insert(Section_Data.Items, {Name = Toggle_Text, Instance = Btn_Obj})
                Create_Corner(Btn_Obj, 4)
                Create_Stroke(Btn_Obj, Theme_Table.Stroke, 1, 0.5)
                local Text_Label = Instance.new("TextLabel")
                Text_Label.Text = Toggle_Text
                Text_Label.Font = Config_Table.Font_Main
                Text_Label.TextSize = 13
                Text_Label.TextColor3 = Theme_Table.Text
                Text_Label.Size = UDim2.new(1, -30, 1, 0)
                Text_Label.Position = UDim2.new(0, 10, 0, 0)
                Text_Label.TextXAlignment = Enum.TextXAlignment.Left
                Text_Label.BackgroundTransparency = 1
                Text_Label.Parent = Btn_Obj
                local Box_Frame = Instance.new("Frame")
                Box_Frame.Size = UDim2.new(0, 18, 0, 18)
                Box_Frame.Position = UDim2.new(1, -10, 0.5, 0)
                Box_Frame.AnchorPoint = Vector2.new(1, 0.5)
                Box_Frame.BackgroundColor3 = Theme_Table.Background
                Box_Frame.Parent = Btn_Obj
                Create_Corner(Box_Frame, 4)
                Create_Stroke(Box_Frame, Theme_Table.Stroke, 1, 0.5)
                local Fill_Frame = Instance.new("Frame")
                Fill_Frame.Size = UDim2.new(1, -4, 1, -4)
                Fill_Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill_Frame.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill_Frame.BackgroundColor3 = Theme_Table.Accent
                Fill_Frame.BackgroundTransparency = Is_Toggled and 0 or 1
                Fill_Frame.Parent = Box_Frame
                Create_Corner(Fill_Frame, 3)
                Register_Theme(Fill_Frame, "BackgroundColor")
                local Sub_Container = Instance.new("Frame")
                Sub_Container.Name = "Sub_" .. Toggle_Text
                Sub_Container.Size = UDim2.new(1, 0, 0, 0)
                Sub_Container.BackgroundTransparency = 1
                Sub_Container.ClipsDescendants = true
                Sub_Container.Visible = false
                Sub_Container.Parent = Content_Frame
                local Sub_List_Layout = Instance.new("UIListLayout")
                Sub_List_Layout.Padding = UDim.new(0, 6)
                Sub_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Sub_List_Layout.Parent = Sub_Container
                local Current_Tween = nil
                local function Toggle_Anim()
                    if Current_Tween then Current_Tween:Cancel() end
                    Create_Tween(Fill_Frame, {BackgroundTransparency = Is_Toggled and 0 or 1}, 0.2)
                    Library_Table.Flags[Toggle_Flag] = Is_Toggled
                    if Toggle_Obj.Keybind_Value then
                        Library_Table:Update_Keybind_List(Toggle_Text, Toggle_Obj.Keybind_Value.Name, Is_Toggled, Toggle_Obj.Keybind_Mode)
                    end
                    if Is_Toggled then
                        Sub_Container.Visible = true
                        Sub_Container.ClipsDescendants = true
                        local Height_Val = Sub_List_Layout.AbsoluteContentSize.Y
                        if Height_Val > 0 then Height_Val = Height_Val + 6 end
                        Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, Height_Val)})
                        Current_Tween:Play()
                        local T_Conn_1
                        T_Conn_1 = Current_Tween.Completed:Connect(function(State_Val)
                            if State_Val == Enum.PlaybackState.Completed and Is_Toggled then Sub_Container.ClipsDescendants = false end
                            T_Conn_1:Disconnect()
                        end)
                    else
                        Sub_Container.ClipsDescendants = true
                        Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                        Current_Tween:Play()
                        local Expected_Toggle = Is_Toggled
                        local T_Conn_2
                        T_Conn_2 = Current_Tween.Completed:Connect(function(Playback_State)
                            if Playback_State == Enum.PlaybackState.Completed and Expected_Toggle == Is_Toggled and not Is_Toggled then Sub_Container.Visible = false end
                            T_Conn_2:Disconnect()
                        end)
                    end
                end
                Toggle_Obj.Update_Anim = Toggle_Anim
                local Conn_5 = Sub_List_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Is_Toggled then
                        local Height_Val = Sub_List_Layout.AbsoluteContentSize.Y
                        if Height_Val > 0 then Height_Val = Height_Val + 6 end
                        Sub_Container.Size = UDim2.new(1, 0, 0, Height_Val)
                    end
                end)
                table.insert(Library_Table.Connections, Conn_5)
                local Conn_6 = Btn_Obj.MouseButton1Click:Connect(function()
                    Is_Toggled = not Is_Toggled
                    Library_Table.Is_Unsaved = true
                    Toggle_Anim()
                    Callback_Func(Is_Toggled)
                end)
                table.insert(Library_Table.Connections, Conn_6)
                if Is_Toggled then Toggle_Anim() end
                Apply_Tooltip(Btn_Obj, Tooltip_Text)
                task.spawn(Callback_Func, Is_Toggled)
                function Toggle_Obj:AddButton(Btn_Text, Sub_Callback)
                    local Sub_Btn = Instance.new("TextButton")
                    Sub_Btn.Size = UDim2.new(1, -20, 0, 26)
                    Sub_Btn.Position = UDim2.new(0, 20, 0, 0)
                    Sub_Btn.BackgroundColor3 = Theme_Table.Container
                    Sub_Btn.Text = Btn_Text
                    Sub_Btn.Font = Config_Table.Font_Main
                    Sub_Btn.TextSize = 12
                    Sub_Btn.TextColor3 = Theme_Table.Text
                    Sub_Btn.AutoButtonColor = false
                    Sub_Btn.Parent = Sub_Container
                    Create_Corner(Sub_Btn, 4)
                    local Stroke_Obj = Create_Stroke(Sub_Btn, Theme_Table.Stroke, 1, 0.5)
                    local Sub_Conn_1 = Sub_Btn.MouseEnter:Connect(function() Create_Tween(Sub_Btn, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(Stroke_Obj, {Color = Theme_Table.Accent}) end)
                    local Sub_Conn_2 = Sub_Btn.MouseLeave:Connect(function() Create_Tween(Sub_Btn, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(Stroke_Obj, {Color = Theme_Table.Stroke}) end)
                    local Sub_Conn_3 = Sub_Btn.MouseButton1Click:Connect(Sub_Callback)
                    table.insert(Library_Table.Connections, Sub_Conn_1)
                    table.insert(Library_Table.Connections, Sub_Conn_2)
                    table.insert(Library_Table.Connections, Sub_Conn_3)
                end
                function Toggle_Obj:AddSlider(Slider_Text, Slider_Flag, Min_Val, Max_Val, Def_Val, Sub_Callback, Inc_Val)
                    Inc_Val = Inc_Val or 1
                    local Current_Val = Library_Table.Flags[Slider_Flag]
                    if Current_Val == nil then Current_Val = Def_Val or Min_Val end
                    Current_Val = Round_To_Increment(Current_Val, Inc_Val)
                    Library_Table.Defaults[Slider_Flag] = Current_Val
                    Library_Table.Flags[Slider_Flag] = Current_Val
                    local Range_Val = Max_Val - Min_Val
                    local Sub_Frame = Instance.new("Frame")
                    Sub_Frame.Size = UDim2.new(1, -20, 0, 36)
                    Sub_Frame.Position = UDim2.new(0, 20, 0, 0)
                    Sub_Frame.BackgroundTransparency = 1
                    Sub_Frame.Parent = Sub_Container
                    local Sub_Label = Instance.new("TextLabel")
                    Sub_Label.Text = Slider_Text
                    Sub_Label.Font = Config_Table.Font_Main
                    Sub_Label.TextSize = 12
                    Sub_Label.TextColor3 = Theme_Table.Text_Dark
                    Sub_Label.Size = UDim2.new(1, 0, 0, 16)
                    Sub_Label.TextXAlignment = Enum.TextXAlignment.Left
                    Sub_Label.BackgroundTransparency = 1
                    Sub_Label.Parent = Sub_Frame
                    local Sub_Value_Box = Instance.new("TextBox")
                    Sub_Value_Box.Text = Format_Number(Current_Val, Inc_Val)
                    Sub_Value_Box.Font = Config_Table.Font_Main
                    Sub_Value_Box.TextSize = 12
                    Sub_Value_Box.TextColor3 = Theme_Table.Text
                    Sub_Value_Box.Size = UDim2.new(1, 0, 0, 16)
                    Sub_Value_Box.TextXAlignment = Enum.TextXAlignment.Right
                    Sub_Value_Box.BackgroundTransparency = 1
                    Sub_Value_Box.ClearTextOnFocus = true
                    Sub_Value_Box.Parent = Sub_Frame
                    local Slide_Bg = Instance.new("Frame")
                    Slide_Bg.Size = UDim2.new(1, 0, 0, 6)
                    Slide_Bg.Position = UDim2.new(0, 0, 0, 22)
                    Slide_Bg.BackgroundColor3 = Theme_Table.Background
                    Slide_Bg.Parent = Sub_Frame
                    Create_Corner(Slide_Bg, 3)
                    local Slide_Fill = Instance.new("Frame")
                    local Ratio_Val = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
                    Slide_Fill.Size = UDim2.new(Ratio_Val, 0, 1, 0)
                    Slide_Fill.BackgroundColor3 = Theme_Table.Accent
                    Slide_Fill.BorderSizePixel = 0
                    Slide_Fill.Parent = Slide_Bg
                    Create_Corner(Slide_Fill, 3)
                    Register_Theme(Slide_Fill, "BackgroundColor")
                    local Is_Dragging = false
                    local function Set_Slider_Value(Input_Obj)
                        local Calc_Ratio = math.clamp((Input_Obj.Position.X - Slide_Bg.AbsolutePosition.X) / Slide_Bg.AbsoluteSize.X, 0, 1)
                        local Raw_Val = Min_Val + (Max_Val - Min_Val) * Calc_Ratio
                        Current_Val = Round_To_Increment(Raw_Val, Inc_Val)
                        Current_Val = math.clamp(Current_Val, Min_Val, Max_Val)
                        local Display_Ratio = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
                        Sub_Value_Box.Text = Format_Number(Current_Val, Inc_Val)
                        Create_Tween(Slide_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                        Library_Table.Flags[Slider_Flag] = Current_Val
                        Library_Table.Is_Unsaved = true
                        Sub_Callback(Current_Val)
                    end
                    local TS_Conn_1 = Slide_Bg.InputBegan:Connect(function(Input_Obj)
                        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                            Is_Dragging = true
                            Set_Slider_Value(Input_Obj)
                        end
                    end)
                    local TS_Conn_2 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
                        if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                            if Is_Dragging then Is_Dragging = false end
                        end
                    end)
                    local TS_Conn_3 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
                        if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                            if Is_Dragging then Set_Slider_Value(Input_Obj) end
                        end
                    end)
                    table.insert(Library_Table.Connections, TS_Conn_1)
                    table.insert(Library_Table.Connections, TS_Conn_2)
                    table.insert(Library_Table.Connections, TS_Conn_3)
                    local TS_Conn_4 = Sub_Value_Box.FocusLost:Connect(function(Enter_Pressed)
                        if Enter_Pressed then
                            local Clean_Text = string.gsub(Sub_Value_Box.Text, "[^%d.-]", "")
                            local Num_Val = tonumber(Clean_Text)
                            if Num_Val then
                                Num_Val = Round_To_Increment(Num_Val, Inc_Val)
                                Num_Val = math.clamp(Num_Val, Min_Val, Max_Val)
                                Current_Val = Num_Val
                                local Display_Ratio = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
                                Sub_Value_Box.Text = Format_Number(Current_Val, Inc_Val)
                                Create_Tween(Slide_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                                Library_Table.Flags[Slider_Flag] = Current_Val
                                Library_Table.Is_Unsaved = true
                                Sub_Callback(Current_Val)
                            else
                                Sub_Value_Box.Text = Format_Number(Current_Val, Inc_Val)
                            end
                        else
                            Sub_Value_Box.Text = Format_Number(Current_Val, Inc_Val)
                        end
                    end)
                    table.insert(Library_Table.Connections, TS_Conn_4)
                    Library_Table.Signals[Slider_Flag] = function(Loaded_Val)
                        Current_Val = Round_To_Increment(Loaded_Val, Inc_Val)
                        Current_Val = math.clamp(Current_Val, Min_Val, Max_Val)
                        local Display_Ratio = Range_Val > 0 and (Current_Val - Min_Val) / Range_Val or 0
                        Sub_Value_Box.Text = Format_Number(Current_Val, Inc_Val)
                        Create_Tween(Slide_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                        Library_Table.Is_Unsaved = true
                        Sub_Callback(Current_Val)
                    end
                    task.spawn(Sub_Callback, Current_Val)
                end
                function Toggle_Obj:AddDropdown(DD_Text, DD_Flag, Options_List, Default_Val, Sub_Callback, Is_Multi)
                    Create_Dropdown_Element(DD_Text, DD_Flag, Options_List, Default_Val, nil, Sub_Callback, Content_Frame, Section_Object, Is_Multi, Sub_Container)
                end
                function Toggle_Obj:Keybind(Default_Key, Keybind_Mode)
                    Toggle_Obj.Keybind_Value = Default_Key or Enum.KeyCode.Unknown
                    Toggle_Obj.Keybind_Mode = Keybind_Mode or "Toggle"
                    local Key_Btn = Instance.new("TextButton")
                    Key_Btn.Size = UDim2.new(0, 60, 0, 18)
                    Key_Btn.Position = UDim2.new(1, -30, 0.5, 0)
                    Key_Btn.AnchorPoint = Vector2.new(1, 0.5)
                    Key_Btn.BackgroundTransparency = 1
                    Key_Btn.Text = "[" .. (Toggle_Obj.Keybind_Value.Name) .. "]"
                    Key_Btn.TextColor3 = Theme_Table.Text_Dark
                    Key_Btn.Font = Config_Table.Font_Main
                    Key_Btn.TextSize = 11
                    Key_Btn.TextXAlignment = Enum.TextXAlignment.Right
                    Key_Btn.Parent = Btn_Obj
                    local Is_Binding = false
                    local KB_Conn_1 = Key_Btn.MouseButton1Click:Connect(function()
                        if Is_Binding then return end
                        Is_Binding = true
                        Key_Btn.Text = "[...]"
                        Key_Btn.TextColor3 = Theme_Table.Accent
                        local Conn_Wait
                        Conn_Wait = User_Input_Service.InputBegan:Connect(function(Input_Obj)
                            if Input_Obj.UserInputType == Enum.UserInputType.Keyboard then
                                if Input_Obj.KeyCode == Enum.KeyCode.Backspace or Input_Obj.KeyCode == Enum.KeyCode.Delete then Toggle_Obj.Keybind_Value = Enum.KeyCode.Unknown
                                elseif Input_Obj.KeyCode ~= Enum.KeyCode.Escape and Input_Obj.KeyCode ~= Enum.KeyCode.Unknown then Toggle_Obj.Keybind_Value = Input_Obj.KeyCode end
                                Key_Btn.Text = "[" .. (Toggle_Obj.Keybind_Value.Name) .. "]"
                                Key_Btn.TextColor3 = Theme_Table.Text_Dark
                                Is_Binding = false
                                Library_Table.Is_Unsaved = true
                                Conn_Wait:Disconnect()
                                if Is_Toggled then Library_Table:Update_Keybind_List(Toggle_Text, Toggle_Obj.Keybind_Value.Name, Is_Toggled, Toggle_Obj.Keybind_Mode) end
                            end
                        end)
                    end)
                    table.insert(Library_Table.Connections, KB_Conn_1)
                    local Mode_Gui = Instance.new("Frame")
                    Mode_Gui.Size = UDim2.new(0, 80, 0, 60)
                    Mode_Gui.BackgroundColor3 = Theme_Table.Sidebar
                    Mode_Gui.Visible = false
                    Mode_Gui.ZIndex = 100
                    Mode_Gui.Parent = Btn_Obj
                    Create_Corner(Mode_Gui, 4)
                    Create_Stroke(Mode_Gui, Theme_Table.Stroke, 1)
                    local Mode_List_Layout = Instance.new("UIListLayout")
                    Mode_List_Layout.Parent = Mode_Gui
                    local Available_Modes = {"Toggle", "Hold", "Always"}
                    for _, Mode_Str in ipairs(Available_Modes) do
                        local Mode_Btn = Instance.new("TextButton")
                        Mode_Btn.Size = UDim2.new(1, 0, 0, 20)
                        Mode_Btn.BackgroundTransparency = 1
                        Mode_Btn.Text = Mode_Str
                        Mode_Btn.TextColor3 = Theme_Table.Text_Dark
                        Mode_Btn.Font = Config_Table.Font_Main
                        Mode_Btn.TextSize = 11
                        Mode_Btn.Parent = Mode_Gui
                        Mode_Btn.ZIndex = 101
                        local MB_Conn_1 = Mode_Btn.MouseButton1Click:Connect(function()
                            Toggle_Obj.Keybind_Mode = Mode_Str
                            Mode_Gui.Visible = false
                            Library_Table.Is_Unsaved = true
                            if Mode_Str == "Always" and not Is_Toggled then
                                Is_Toggled = true
                                Toggle_Anim()
                                Callback_Func(Is_Toggled)
                            end
                            if Is_Toggled then Library_Table:Update_Keybind_List(Toggle_Text, Toggle_Obj.Keybind_Value.Name, Is_Toggled, Mode_Str) end
                        end)
                        table.insert(Library_Table.Connections, MB_Conn_1)
                    end
                    local KB_Conn_2 = Key_Btn.MouseButton2Click:Connect(function()
                        Mode_Gui.Position = UDim2.new(1, -110, 0, 20)
                        Mode_Gui.Visible = not Mode_Gui.Visible
                        if Mode_Gui.Visible then Sub_Container.ClipsDescendants = false end
                    end)
                    table.insert(Library_Table.Connections, KB_Conn_2)
                    if Toggle_Obj.Bind_Connection then Toggle_Obj.Bind_Connection:Disconnect() end
                    if Toggle_Obj.Bind_Connection_Ended then Toggle_Obj.Bind_Connection_Ended:Disconnect() end
                    Toggle_Obj.Bind_Connection = User_Input_Service.InputBegan:Connect(function(Input_Obj, Is_Game_Processed)
                        if not Is_Game_Processed and Input_Obj.KeyCode == Toggle_Obj.Keybind_Value and Toggle_Obj.Keybind_Value ~= Enum.KeyCode.Unknown then
                            if Toggle_Obj.Keybind_Mode == "Toggle" then
                                Is_Toggled = not Is_Toggled
                                Toggle_Anim()
                                Callback_Func(Is_Toggled)
                            elseif Toggle_Obj.Keybind_Mode == "Hold" then
                                Is_Toggled = true
                                Toggle_Anim()
                                Callback_Func(Is_Toggled)
                            end
                        end
                    end)
                    Toggle_Obj.Bind_Connection_Ended = User_Input_Service.InputEnded:Connect(function(Input_Obj, Is_Game_Processed)
                        if not Is_Game_Processed and Input_Obj.KeyCode == Toggle_Obj.Keybind_Value and Toggle_Obj.Keybind_Value ~= Enum.KeyCode.Unknown then
                            if Toggle_Obj.Keybind_Mode == "Hold" then
                                Is_Toggled = false
                                Toggle_Anim()
                                Callback_Func(Is_Toggled)
                            end
                        end
                    end)
                    table.insert(Library_Table.Connections, Toggle_Obj.Bind_Connection)
                    table.insert(Library_Table.Connections, Toggle_Obj.Bind_Connection_Ended)
                    if Is_Toggled then Library_Table:Update_Keybind_List(Toggle_Text, Toggle_Obj.Keybind_Value.Name, Is_Toggled, Toggle_Obj.Keybind_Mode) end
                    return Toggle_Obj
                end
                return Toggle_Obj
            end
            function Section_Object:Keybind(Bind_Text, Bind_Flag, Default_Key, Bind_Mode, Tooltip_Text, Callback_Func)
                local Def_Obj = Library_Table.Flags[Bind_Flag]
                local Current_Key = Def_Obj and Def_Obj.Key or (Default_Key or Enum.KeyCode.Unknown)
                local Current_Mode = Def_Obj and Def_Obj.Mode or (Bind_Mode or "Toggle")
                Library_Table.Defaults[Bind_Flag] = {Key = Default_Key or Enum.KeyCode.Unknown, Mode = Bind_Mode or "Toggle"}
                Library_Table.Flags[Bind_Flag] = {Key = Current_Key, Mode = Current_Mode}
                local Frame_Obj = Instance.new("Frame")
                Frame_Obj.Size = UDim2.new(1, 0, 0, 30)
                Frame_Obj.BackgroundTransparency = 1
                Frame_Obj.Parent = Content_Frame
                local Label_Obj = Instance.new("TextLabel")
                Label_Obj.Text = Bind_Text
                Label_Obj.Font = Config_Table.Font_Main
                Label_Obj.TextSize = 13
                Label_Obj.TextColor3 = Theme_Table.Text
                Label_Obj.Size = UDim2.new(0.6, 0, 1, 0)
                Label_Obj.Position = UDim2.new(0, 5, 0, 0)
                Label_Obj.TextXAlignment = Enum.TextXAlignment.Left
                Label_Obj.BackgroundTransparency = 1
                Label_Obj.Parent = Frame_Obj
                local Key_Btn = Instance.new("TextButton")
                Key_Btn.Size = UDim2.new(0, 80, 0, 20)
                Key_Btn.Position = UDim2.new(1, -5, 0.5, 0)
                Key_Btn.AnchorPoint = Vector2.new(1, 0.5)
                Key_Btn.BackgroundColor3 = Theme_Table.Container
                Key_Btn.Text = "[" .. Current_Key.Name .. "]"
                Key_Btn.Font = Config_Table.Font_Main
                Key_Btn.TextSize = 12
                Key_Btn.TextColor3 = Theme_Table.Text_Dark
                Key_Btn.AutoButtonColor = false
                Key_Btn.Parent = Frame_Obj
                Create_Corner(Key_Btn, 4)
                Create_Stroke(Key_Btn, Theme_Table.Stroke, 1, 0.5)
                local Is_Toggled = (Current_Mode == "Always")
                Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                local Is_Binding = false
                local Conn_1 = Key_Btn.MouseButton1Click:Connect(function()
                    if Is_Binding then return end
                    Is_Binding = true
                    Key_Btn.Text = "[...]"
                    Key_Btn.TextColor3 = Theme_Table.Accent
                    local Conn_Wait
                    Conn_Wait = User_Input_Service.InputBegan:Connect(function(Input_Obj)
                        if Input_Obj.UserInputType == Enum.UserInputType.Keyboard then
                            if Input_Obj.KeyCode == Enum.KeyCode.Backspace or Input_Obj.KeyCode == Enum.KeyCode.Delete then
                                Current_Key = Enum.KeyCode.Unknown
                            elseif Input_Obj.KeyCode ~= Enum.KeyCode.Escape and Input_Obj.KeyCode ~= Enum.KeyCode.Unknown then
                                Current_Key = Input_Obj.KeyCode
                            end
                            Key_Btn.Text = "[" .. Current_Key.Name .. "]"
                            Key_Btn.TextColor3 = Theme_Table.Text_Dark
                            Library_Table.Flags[Bind_Flag] = {Key = Current_Key, Mode = Current_Mode}
                            Is_Binding = false
                            Library_Table.Is_Unsaved = true
                            Conn_Wait:Disconnect()
                            Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                        end
                    end)
                end)
                table.insert(Library_Table.Connections, Conn_1)
                local Mode_Gui = Instance.new("Frame")
                Mode_Gui.Size = UDim2.new(0, 80, 0, 60)
                Mode_Gui.Position = UDim2.new(1, -90, 0, 25)
                Mode_Gui.BackgroundColor3 = Theme_Table.Sidebar
                Mode_Gui.Visible = false
                Mode_Gui.ZIndex = 100
                Mode_Gui.Parent = Frame_Obj
                Create_Corner(Mode_Gui, 4)
                Create_Stroke(Mode_Gui, Theme_Table.Stroke, 1)
                local Mode_List_Layout = Instance.new("UIListLayout")
                Mode_List_Layout.Parent = Mode_Gui
                local Available_Modes = {"Toggle", "Hold", "Always"}
                for _, Mode_Str in ipairs(Available_Modes) do
                    local Mode_Btn = Instance.new("TextButton")
                    Mode_Btn.Size = UDim2.new(1, 0, 0, 20)
                    Mode_Btn.BackgroundTransparency = 1
                    Mode_Btn.Text = Mode_Str
                    Mode_Btn.TextColor3 = Theme_Table.Text_Dark
                    Mode_Btn.Font = Config_Table.Font_Main
                    Mode_Btn.TextSize = 11
                    Mode_Btn.Parent = Mode_Gui
                    Mode_Btn.ZIndex = 101
                    local Conn_2 = Mode_Btn.MouseButton1Click:Connect(function()
                        Current_Mode = Mode_Str
                        Library_Table.Flags[Bind_Flag] = {Key = Current_Key, Mode = Current_Mode}
                        Mode_Gui.Visible = false
                        Library_Table.Is_Unsaved = true
                        if Current_Mode == "Always" then
                            Is_Toggled = true
                            Callback_Func(true)
                        end
                        Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                    end)
                    table.insert(Library_Table.Connections, Conn_2)
                end
                local Conn_3 = Key_Btn.MouseButton2Click:Connect(function()
                    Mode_Gui.Visible = not Mode_Gui.Visible
                    if Mode_Gui.Visible then Content_Frame.ClipsDescendants = false end
                end)
                table.insert(Library_Table.Connections, Conn_3)
                local Bind_Conn = User_Input_Service.InputBegan:Connect(function(Input_Obj, Is_Game_Processed)
                    if not Is_Game_Processed and Input_Obj.KeyCode == Current_Key and Current_Key ~= Enum.KeyCode.Unknown then
                        if Current_Mode == "Toggle" then
                            Is_Toggled = not Is_Toggled
                            Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                            Callback_Func(Is_Toggled)
                        elseif Current_Mode == "Hold" then
                            Is_Toggled = true
                            Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                            Callback_Func(Is_Toggled)
                        end
                    end
                end)
                local Bind_Conn_Ended = User_Input_Service.InputEnded:Connect(function(Input_Obj, Is_Game_Processed)
                    if not Is_Game_Processed and Input_Obj.KeyCode == Current_Key and Current_Key ~= Enum.KeyCode.Unknown then
                        if Current_Mode == "Hold" then
                            Is_Toggled = false
                            Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                            Callback_Func(Is_Toggled)
                        end
                    end
                end)
                table.insert(Library_Table.Connections, Bind_Conn)
                table.insert(Library_Table.Connections, Bind_Conn_Ended)
                Apply_Tooltip(Frame_Obj, Tooltip_Text)
                Library_Table.Signals[Bind_Flag] = function(Loaded_Val)
                    if type(Loaded_Val) == "table" and Loaded_Val.Key then
                        Current_Key = Loaded_Val.Key
                        Current_Mode = Loaded_Val.Mode or "Toggle"
                        Key_Btn.Text = "[" .. Current_Key.Name .. "]"
                        if Current_Mode == "Always" then
                            Is_Toggled = true
                            Callback_Func(true)
                        end
                        Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                    end
                end
                local Bind_Obj_Return = {}
                function Bind_Obj_Return:SetKey(New_Key)
                    Current_Key = New_Key
                    Key_Btn.Text = "[" .. Current_Key.Name .. "]"
                    Library_Table.Flags[Bind_Flag] = {Key = Current_Key, Mode = Current_Mode}
                    Library_Table.Is_Unsaved = true
                    Library_Table:Update_Keybind_List(Bind_Text, Current_Key.Name, Is_Toggled, Current_Mode)
                end
                return Bind_Obj_Return
            end
            function Section_Object:Button(Button_Text, Tooltip_Text, Callback_Func)
                local Btn_Obj = Instance.new("TextButton")
                Btn_Obj.Size = UDim2.new(1, 0, 0, 30)
                Btn_Obj.BackgroundColor3 = Theme_Table.Container
                Btn_Obj.Text = Button_Text
                Btn_Obj.Font = Config_Table.Font_Main
                Btn_Obj.TextSize = 13
                Btn_Obj.TextColor3 = Theme_Table.Text
                Btn_Obj.AutoButtonColor = false
                Btn_Obj.Parent = Content_Frame
                table.insert(Section_Data.Items, {Name = Button_Text, Instance = Btn_Obj})
                Create_Corner(Btn_Obj, 4)
                local Stroke_Obj = Create_Stroke(Btn_Obj, Theme_Table.Stroke, 1, 0.5)
                local Conn_1 = Btn_Obj.MouseEnter:Connect(function() Create_Tween(Btn_Obj, {BackgroundColor3 = Theme_Table.Stroke}) Create_Tween(Stroke_Obj, {Color = Theme_Table.Accent}) end)
                local Conn_2 = Btn_Obj.MouseLeave:Connect(function() Create_Tween(Btn_Obj, {BackgroundColor3 = Theme_Table.Container}) Create_Tween(Stroke_Obj, {Color = Theme_Table.Stroke}) end)
                local Conn_3 = Btn_Obj.MouseButton1Click:Connect(Callback_Func)
                table.insert(Library_Table.Connections, Conn_1)
                table.insert(Library_Table.Connections, Conn_2)
                table.insert(Library_Table.Connections, Conn_3)
                Apply_Tooltip(Btn_Obj, Tooltip_Text)
            end
            function Section_Object:Slider(Slider_Text, Slider_Flag, Min_Val, Max_Val, Default_Val, Increment_Val, Tooltip_Text, Callback_Func)
                Create_Slider_Element(Slider_Text, Slider_Flag, Min_Val, Max_Val, Default_Val, Increment_Val, Tooltip_Text, Callback_Func, Content_Frame, Section_Data)
            end
            function Section_Object:TextBox(Input_Text, Input_Flag, Placeholder_Str, Tooltip_Text, Callback_Func)
                Library_Table.Defaults[Input_Flag] = ""
                local Frame_Obj = Instance.new("Frame")
                Frame_Obj.Size = UDim2.new(1, 0, 0, 46)
                Frame_Obj.BackgroundTransparency = 1
                Frame_Obj.Parent = Content_Frame
                table.insert(Section_Data.Items, {Name = Input_Text, Instance = Frame_Obj})
                local Label_Obj = Instance.new("TextLabel")
                Label_Obj.Text = Input_Text
                Label_Obj.Font = Config_Table.Font_Main
                Label_Obj.TextSize = 13
                Label_Obj.TextColor3 = Theme_Table.Text
                Label_Obj.Size = UDim2.new(1, 0, 0, 16)
                Label_Obj.Position = UDim2.new(0, 5, 0, 0)
                Label_Obj.TextXAlignment = Enum.TextXAlignment.Left
                Label_Obj.BackgroundTransparency = 1
                Label_Obj.Parent = Frame_Obj
                local Box_Container = Instance.new("Frame")
                Box_Container.Size = UDim2.new(1, 0, 0, 26)
                Box_Container.Position = UDim2.new(0, 0, 0, 20)
                Box_Container.BackgroundColor3 = Theme_Table.Container
                Box_Container.Parent = Frame_Obj
                Create_Corner(Box_Container, 4)
                local Stroke_Obj = Create_Stroke(Box_Container, Theme_Table.Stroke, 1, 0.5)
                local Text_Input = Instance.new("TextBox")
                Text_Input.Size = UDim2.new(1, -10, 1, 0)
                Text_Input.Position = UDim2.new(0, 5, 0, 0)
                Text_Input.BackgroundTransparency = 1
                Text_Input.TextColor3 = Theme_Table.Text
                Text_Input.PlaceholderText = Placeholder_Str or "Type here..."
                Text_Input.PlaceholderColor3 = Theme_Table.Text_Dark
                Text_Input.Font = Config_Table.Font_Main
                Text_Input.TextSize = 13
                Text_Input.TextXAlignment = Enum.TextXAlignment.Left
                local Current_Text = Library_Table.Flags[Input_Flag] or ""
                Text_Input.Text = Current_Text
                Text_Input.ClearTextOnFocus = false
                Text_Input.Parent = Box_Container
                local Conn_1 = Text_Input.Focused:Connect(function() Create_Tween(Stroke_Obj, {Color = Theme_Table.Accent}) end)
                local Conn_2 = Text_Input.FocusLost:Connect(function(Enter_Pressed)
                    Create_Tween(Stroke_Obj, {Color = Theme_Table.Stroke})
                    if Enter_Pressed then
                        Library_Table.Flags[Input_Flag] = Text_Input.Text
                        Library_Table.Is_Unsaved = true
                        Callback_Func(Text_Input.Text)
                    end
                end)
                table.insert(Library_Table.Connections, Conn_1)
                table.insert(Library_Table.Connections, Conn_2)
                Library_Table.Flags[Input_Flag] = Current_Text
                Library_Table.Signals[Input_Flag] = function(Loaded_Val)
                    Text_Input.Text = Loaded_Val
                    Library_Table.Is_Unsaved = true
                    Callback_Func(Loaded_Val)
                end
                Apply_Tooltip(Frame_Obj, Tooltip_Text)
                task.spawn(Callback_Func, Current_Text)
            end
            function Section_Object:Dropdown(DD_Text, DD_Flag, Options_List, Default_Val, Tooltip_Text, Callback_Func, Custom_Parent, Is_Multi)
                local Dropdown_Obj = Create_Dropdown_Element(DD_Text, DD_Flag, Options_List, Default_Val, Tooltip_Text, Callback_Func, Content_Frame, Section_Object, Is_Multi, Custom_Parent)
                if not Custom_Parent then table.insert(Section_Data.Items, {Name = DD_Text, Instance = Dropdown_Obj.Frame}) end
                return Dropdown_Obj
            end
            function Section_Object:ColorPicker(Picker_Text, Picker_Flag, Default_Color, Tooltip_Text, Callback_Func)
                local Current_Color = Library_Table.Flags[Picker_Flag] or Default_Color or Color3.fromRGB(255, 255, 255)
                Library_Table.Defaults[Picker_Flag] = Default_Color or Color3.fromRGB(255, 255, 255)
                Library_Table.Flags[Picker_Flag] = Current_Color
                local H_Val, S_Val, V_Val = Current_Color:ToHSV()
                local Is_Picker_Open = false
                local Container_Frame = Instance.new("Frame")
                Container_Frame.Size = UDim2.new(1, 0, 0, 30)
                Container_Frame.BackgroundTransparency = 1
                Container_Frame.Parent = Content_Frame
                table.insert(Section_Data.Items, {Name = Picker_Text, Instance = Container_Frame})
                local Frame_Obj = Instance.new("Frame")
                Frame_Obj.Size = UDim2.new(1, 0, 0, 30)
                Frame_Obj.BackgroundTransparency = 1
                Frame_Obj.Parent = Container_Frame
                Frame_Obj.ZIndex = 5
                local Label_Obj = Instance.new("TextLabel")
                Label_Obj.Text = Picker_Text
                Label_Obj.Font = Config_Table.Font_Main
                Label_Obj.TextSize = 13
                Label_Obj.TextColor3 = Theme_Table.Text
                Label_Obj.Size = UDim2.new(0.6, 0, 1, 0)
                Label_Obj.Position = UDim2.new(0, 5, 0, 0)
                Label_Obj.TextXAlignment = Enum.TextXAlignment.Left
                Label_Obj.BackgroundTransparency = 1
                Label_Obj.Parent = Frame_Obj
                local Preview_Btn = Instance.new("TextButton")
                Preview_Btn.Size = UDim2.new(0, 40, 0, 20)
                Preview_Btn.Position = UDim2.new(1, -5, 0.5, 0)
                Preview_Btn.AnchorPoint = Vector2.new(1, 0.5)
                Preview_Btn.BackgroundColor3 = Current_Color
                Preview_Btn.AutoButtonColor = false
                Preview_Btn.Text = ""
                Preview_Btn.Parent = Frame_Obj
                Create_Corner(Preview_Btn, 4)
                Create_Stroke(Preview_Btn, Theme_Table.Stroke, 1, 0.5)
                local Picker_Content = Instance.new("Frame")
                Picker_Content.Size = UDim2.new(1, 0, 0, 0)
                Picker_Content.Position = UDim2.new(0, 0, 0, 30)
                Picker_Content.BackgroundColor3 = Theme_Table.Background
                Picker_Content.Parent = Container_Frame
                Picker_Content.ClipsDescendants = true
                Picker_Content.Visible = false
                Picker_Content.ZIndex = 10
                Create_Corner(Picker_Content, 4)
                local SV_Map = Instance.new("ImageLabel")
                SV_Map.Size = UDim2.new(0, 140, 0, 120)
                SV_Map.Position = UDim2.new(0, 10, 0, 10)
                SV_Map.Image = "rbxassetid://4155801252"
                SV_Map.BackgroundColor3 = Color3.fromHSV(H_Val, 1, 1)
                SV_Map.Parent = Picker_Content
                SV_Map.ZIndex = 11
                Create_Corner(SV_Map, 4)
                local SV_Cursor = Instance.new("Frame")
                SV_Cursor.Size = UDim2.new(0, 8, 0, 8)
                SV_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SV_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SV_Cursor.Parent = SV_Map
                SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
                SV_Cursor.ZIndex = 12
                Create_Corner(SV_Cursor, 4)
                local Hue_Bar = Instance.new("ImageLabel")
                Hue_Bar.Size = UDim2.new(0, 20, 0, 120)
                Hue_Bar.Position = UDim2.new(0, 160, 0, 10)
                Hue_Bar.Image = "rbxassetid://4155801252"
                Hue_Bar.Parent = Picker_Content
                Hue_Bar.ZIndex = 11
                Create_Corner(Hue_Bar, 4)
                local UI_Gradient = Instance.new("UIGradient")
                UI_Gradient.Rotation = 90
                UI_Gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                })
                UI_Gradient.Parent = Hue_Bar
                local H_Cursor = Instance.new("Frame")
                H_Cursor.Size = UDim2.new(1, 0, 0, 2)
                H_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                H_Cursor.Parent = Hue_Bar
                H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
                H_Cursor.ZIndex = 12
                local Hex_Input = Instance.new("TextBox")
                Hex_Input.Size = UDim2.new(0, 170, 0, 20)
                Hex_Input.Position = UDim2.new(0, 10, 0, 140)
                Hex_Input.BackgroundColor3 = Theme_Table.Container
                Hex_Input.TextColor3 = Theme_Table.Text
                Hex_Input.Font = Config_Table.Font_Main
                Hex_Input.TextSize = 12
                Hex_Input.Text = "#" .. Current_Color:ToHex()
                Hex_Input.Parent = Picker_Content
                Hex_Input.ZIndex = 11
                Create_Corner(Hex_Input, 4)
                Create_Stroke(Hex_Input, Theme_Table.Stroke, 1)
                local function Update_Color()
                    Current_Color = Color3.fromHSV(H_Val, S_Val, V_Val)
                    Preview_Btn.BackgroundColor3 = Current_Color
                    SV_Map.BackgroundColor3 = Color3.fromHSV(H_Val, 1, 1)
                    Hex_Input.Text = "#" .. Current_Color:ToHex()
                    Library_Table.Flags[Picker_Flag] = Current_Color
                    Library_Table.Is_Unsaved = true
                    Callback_Func(Current_Color)
                end
                local H_Conn_1 = Hex_Input.FocusLost:Connect(function()
                    local Text_Val = Hex_Input.Text:gsub("#", "")
                    if Text_Val:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                        pcall(function()
                            local New_Color = Color3.fromHex(Text_Val)
                            H_Val, S_Val, V_Val = New_Color:ToHSV()
                            H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
                            SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
                            Update_Color()
                        end)
                    else
                        Hex_Input.Text = "#" .. Current_Color:ToHex()
                    end
                end)
                table.insert(Library_Table.Connections, H_Conn_1)
                Library_Table.Signals[Picker_Flag] = function(Loaded_Val)
                    if typeof(Loaded_Val) == "Color3" then
                        Current_Color = Loaded_Val
                        H_Val, S_Val, V_Val = Current_Color:ToHSV()
                        H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
                        SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
                        Update_Color()
                    end
                end
                local function Set_SV_From_Input(Input_Obj)
                    local Ratio_X = math.clamp((Input_Obj.Position.X - SV_Map.AbsolutePosition.X) / SV_Map.AbsoluteSize.X, 0, 1)
                    local Ratio_Y = math.clamp((Input_Obj.Position.Y - SV_Map.AbsolutePosition.Y) / SV_Map.AbsoluteSize.Y, 0, 1)
                    S_Val = Ratio_X
                    V_Val = 1 - Ratio_Y
                    SV_Cursor.Position = UDim2.new(S_Val, 0, 1 - V_Val, 0)
                    Update_Color()
                end
                local function Set_H_From_Input(Input_Obj)
                    local Ratio_Y = math.clamp((Input_Obj.Position.Y - Hue_Bar.AbsolutePosition.Y) / Hue_Bar.AbsoluteSize.Y, 0, 1)
                    H_Val = Ratio_Y
                    H_Cursor.Position = UDim2.new(0, 0, H_Val, 0)
                    Update_Color()
                end
                local Is_Dragging_SV = false
                local SV_Conn_1 = SV_Map.InputBegan:Connect(function(Input_Obj)
                    if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                        Is_Dragging_SV = true
                        Set_SV_From_Input(Input_Obj)
                    end
                end)
                local SV_Conn_2 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
                    if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                        if Is_Dragging_SV then Is_Dragging_SV = false end
                    end
                end)
                local SV_Conn_3 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
                    if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                        if Is_Dragging_SV then Set_SV_From_Input(Input_Obj) end
                    end
                end)
                table.insert(Library_Table.Connections, SV_Conn_1)
                table.insert(Library_Table.Connections, SV_Conn_2)
                table.insert(Library_Table.Connections, SV_Conn_3)
                local Is_Dragging_H = false
                local H_Conn_2 = Hue_Bar.InputBegan:Connect(function(Input_Obj)
                    if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                        Is_Dragging_H = true
                        Set_H_From_Input(Input_Obj)
                    end
                end)
                local H_Conn_3 = User_Input_Service.InputEnded:Connect(function(Input_Obj)
                    if Input_Obj.UserInputType == Enum.UserInputType.MouseButton1 or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                        if Is_Dragging_H then Is_Dragging_H = false end
                    end
                end)
                local H_Conn_4 = User_Input_Service.InputChanged:Connect(function(Input_Obj)
                    if Input_Obj.UserInputType == Enum.UserInputType.MouseMovement or Input_Obj.UserInputType == Enum.UserInputType.Touch then
                        if Is_Dragging_H then Set_H_From_Input(Input_Obj) end
                    end
                end)
                table.insert(Library_Table.Connections, H_Conn_2)
                table.insert(Library_Table.Connections, H_Conn_3)
                table.insert(Library_Table.Connections, H_Conn_4)
                local P_Conn_1 = Preview_Btn.MouseButton1Click:Connect(function()
                    Is_Picker_Open = not Is_Picker_Open
                    Section_Object.Container.ZIndex = Is_Picker_Open and 10 or 1
                    Container_Frame.ZIndex = Is_Picker_Open and 10 or 5
                    if Is_Picker_Open then
                        Picker_Content.Visible = true
                        Create_Tween(Container_Frame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                        Create_Tween(Picker_Content, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                    else
                        Create_Tween(Container_Frame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                        local Tween_Obj = Create_Tween(Picker_Content, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        local P_Conn_2
                        P_Conn_2 = Tween_Obj.Completed:Connect(function()
                            if not Is_Picker_Open then Picker_Content.Visible = false end
                            P_Conn_2:Disconnect()
                        end)
                    end
                end)
                table.insert(Library_Table.Connections, P_Conn_1)
                Apply_Tooltip(Container_Frame, Tooltip_Text)
                task.spawn(Callback_Func, Current_Color)
            end
            return Section_Object
        end
        return Tab_Object
    end
    local Auto_Save_Timer = 0
    local Auto_Save_Conn = Run_Service.Heartbeat:Connect(function(Delta_Time)
        if Library_Table.Auto_Save_Enabled and Library_Table.Is_Unsaved then
            Auto_Save_Timer = Auto_Save_Timer + Delta_Time
            if Auto_Save_Timer >= 3 then
                Auto_Save_Timer = 0
                Library_Table.Is_Unsaved = false
                Library_Table:Save_Config("_autosave")
            end
        end
    end)
    table.insert(Library_Table.Connections, Auto_Save_Conn)
    task.defer(function()
        Library_Table:Load_Config("_autosave")
    end)
    Main_Scale_Obj.Scale = Get_Base_Scale()
    Main_Win.Visible = true
    return Window_Object
end
return Library_Table
