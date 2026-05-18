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
local Del_File = delfile or function() end

local Core_Gui_Service
pcall(function() Core_Gui_Service = game:GetService("CoreGui") end)

local Local_Player = Players_Service.LocalPlayer

local Library_Api = {
    Flags = {},
    Signals = {},
    Defaults = {},
    Open = true,
    Keybind_List = nil,
    Show_Keybinds = true,
    Screen_Gui = nil,
    Connections = {},
    Elements = {},
    Unsaved = false,
    Auto_Save_Enabled = true
}

local Configuration = {
    Name = "PHANTOM HUB",
    Keybind = Enum.KeyCode.LeftControl,
    Duration = 0.3,
    Font_Main = Enum.Font.GothamMedium,
    Font_Bold = Enum.Font.GothamBold,
    Config_Folder = "PhantomHub"
}

if not Is_Folder(Configuration.Config_Folder) then Make_Folder(Configuration.Config_Folder) end

local Menu_Colors = {
    Background = Color3.fromHex("#080505"),
    Sidebar = Color3.fromHex("#0c0707"),
    Container = Color3.fromHex("#140b0b"),
    Section = Color3.fromHex("#1a0e0e"),
    Accent = Color3.fromHex("#ff1a1a"),
    Text = Color3.fromHex("#ffffff"),
    Text_Dark = Color3.fromHex("#997373"),
    Stroke = Color3.fromHex("#2e1717"),
    Success = Color3.fromHex("#00ff88"),
    Danger = Color3.fromHex("#ff4444"),
    Element_Hover = Color3.fromHex("#241414")
}

local Theme_Registry = {}
setmetatable(Theme_Registry, { __mode = "k" })

local function Register_Theme(Instance_Obj, Prop_Type)
    Theme_Registry[Instance_Obj] = Prop_Type
    return Instance_Obj
end

function Library_Api:Update_Theme(New_Color)
    Menu_Colors.Accent = New_Color
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
    if Core_Gui_Service then return Core_Gui_Service end
    return Local_Player:WaitForChild("PlayerGui")
end

local function Tween_Anim(Obj, Props, Time, Style, Dir)
    Time = Time or Configuration.Duration
    Style = Style or Enum.EasingStyle.Quart
    Dir = Dir or Enum.EasingDirection.Out
    local T = Tween_Service:Create(Obj, TweenInfo.new(Time, Style, Dir), Props)
    T:Play()
    return T
end

local function Corner_Radius(Parent, Radius)
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, Radius)
    C.Parent = Parent
    return C
end

local function Stroke_Border(Parent, Color, Thickness, Transparency)
    local S = Instance.new("UIStroke")
    S.Color = Color or Menu_Colors.Stroke
    S.Thickness = Thickness or 1
    S.Transparency = Transparency or 0
    S.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    S.Parent = Parent
    return S
end

local function Round_To_Increment(Value, Increment)
    if Increment <= 0 then return Value end
    return math.round(Value / Increment) * Increment
end

local function Format_Number(Value, Increment)
    if Increment >= 1 then
        return tostring(math.round(Value))
    end
    local Str = tostring(Increment)
    local Dot_Pos = string.find(Str, "%.")
    if Dot_Pos then
        local Decimals = #Str - Dot_Pos
        return string.format("%." .. Decimals .. "f", Value)
    end
    return tostring(Value)
end

local function Make_Draggable(Drag_Area, Frame, On_Drag_Callback)
    local Dragging = false
    local Drag_Input, Drag_Start, Start_Pos
    local C1 = Drag_Area.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Drag_Start = Input.Position
            Start_Pos = Frame.Position
            local C2
            C2 = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    if On_Drag_Callback then On_Drag_Callback(false) end
                    C2:Disconnect()
                end
            end)
        end
    end)
    local C3 = Drag_Area.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            Drag_Input = Input
        end
    end)
    local C4 = Run_Service.RenderStepped:Connect(function()
        if Dragging and Drag_Input then
            local Delta = Drag_Input.Position - Drag_Start
            Frame.Position = UDim2.new(Start_Pos.X.Scale, Start_Pos.X.Offset + Delta.X, Start_Pos.Y.Scale, Start_Pos.Y.Offset + Delta.Y)
            if On_Drag_Callback then On_Drag_Callback(true) end
        end
    end)
    table.insert(Library_Api.Connections, C1)
    table.insert(Library_Api.Connections, C3)
    table.insert(Library_Api.Connections, C4)
    return function() return Dragging end
end

local function Make_Resizable(Resize_Btn, Frame, Min_Size)
    local Dragging = false
    local Drag_Input, Drag_Start, Start_Size, Start_Pos, Scale_Mult
    local C1 = Resize_Btn.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Drag_Input = Input
            Drag_Start = Input.Position
            Start_Size = Frame.Size
            Start_Pos = Frame.Position
            local Scale_Obj = Frame:FindFirstChildWhichIsA("UIScale")
            Scale_Mult = Scale_Obj and Scale_Obj.Scale or 1
            if Scale_Mult <= 0 then Scale_Mult = 1 end
            local C2
            C2 = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    C2:Disconnect()
                end
            end)
        end
    end)
    local C3 = User_Input_Service.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            Drag_Input = Input
        end
    end)
    local C4 = Run_Service.RenderStepped:Connect(function()
        if Dragging and Drag_Input then
            local Delta = Drag_Input.Position - Drag_Start
            local New_X = math.max(Min_Size.X, Start_Size.X.Offset + (Delta.X / Scale_Mult))
            local New_Y = math.max(Min_Size.Y, Start_Size.Y.Offset + (Delta.Y / Scale_Mult))
            local Diff_X = (New_X - Start_Size.X.Offset) * Scale_Mult
            local Diff_Y = (New_Y - Start_Size.Y.Offset) * Scale_Mult
            Frame.Size = UDim2.new(0, New_X, 0, New_Y)
            Frame.Position = UDim2.new(Start_Pos.X.Scale, Start_Pos.X.Offset + (Diff_X / 2), Start_Pos.Y.Scale, Start_Pos.Y.Offset + (Diff_Y / 2))
        end
    end)
    table.insert(Library_Api.Connections, C1)
    table.insert(Library_Api.Connections, C3)
    table.insert(Library_Api.Connections, C4)
end

local function Get_Base_Scale()
    local Vp = workspace.CurrentCamera.ViewportSize
    if Vp.X < 1 or Vp.Y < 1 then return 1 end
    local Scale_X = Vp.X / 800
    local Scale_Y = Vp.Y / 500
    local Scale = math.min(Scale_X, Scale_Y)
    if Scale < 1 then
        return math.clamp(Scale * 0.95, 0.4, 1)
    end
    return 1
end

function Library_Api:Unload()
    for _, Conn in ipairs(Library_Api.Connections) do pcall(function() Conn:Disconnect() end) end
    Library_Api.Connections = {}
    if Library_Api.Screen_Gui then pcall(function() Library_Api.Screen_Gui:Destroy() end) Library_Api.Screen_Gui = nil end
    if Library_Api.Keybind_List then pcall(function() Library_Api.Keybind_List.Screen:Destroy() end) Library_Api.Keybind_List = nil end
    for _, G in pairs(Get_Parent():GetChildren()) do
        if G.Name == "PrismaMini" or G.Name == Configuration.Name or G.Name == "PrismaKeybinds" or G.Name == "PrismaLoader" or G.Name == "PhantomNotifications" or G.Name == "PhantomWatermark" or G.Name == "PhantomTooltip" or G.Name == "PhantomMiniButton" then
            pcall(function() G:Destroy() end)
        end
    end
end

function Library_Api:Get_Configs()
    local Configs = {}
    if Is_Folder(Configuration.Config_Folder) then
        local Files = List_Files(Configuration.Config_Folder)
        for _, File in ipairs(Files) do
            if string.sub(File, -5) == ".json" then
                local Name = string.match(string.gsub(File, "\\", "/"), "([^/]+)%.json$") or File
                if Name ~= "_autosave" then
                    table.insert(Configs, Name)
                end
            end
        end
    end
    return Configs
end

local Ignored_Flags = {
    ConfigSelectorFlag = true,
    MenuAccentColor = true,
    KeybindListToggle = true,
}

local function Serialize_Config_Value(V)
    if typeof(V) == "Color3" then
        return {Type = "Color3", Hex = V:ToHex()}
    elseif typeof(V) == "EnumItem" then
        local Enum_Name = tostring(V.EnumType):match("Enum%.(.+)") or tostring(V.EnumType)
        return {Type = "EnumItem", EnumType = Enum_Name, Name = V.Name}
    elseif type(V) == "table" then
        local Serialized = {}
        for Tk, Tv in pairs(V) do
            Serialized[Tk] = Serialize_Config_Value(Tv)
        end
        return {Type = "Table", Value = Serialized}
    end
    return V
end

local function Deserialize_Config_Value(Value)
    if type(Value) == "table" then
        if Value.Type == "Color3" then
            local C = Color3.new(1, 1, 1)
            pcall(function() C = Color3.fromHex(Value.Hex) end)
            return C
        elseif Value.Type == "EnumItem" then
            local E
            pcall(function() E = Enum[Value.EnumType][Value.Name] end)
            return E
        elseif Value.Type == "Table" then
            local Deserialized = {}
            if type(Value.Value) == "table" then
                for Tk, Tv in pairs(Value.Value) do
                    Deserialized[Tk] = Deserialize_Config_Value(Tv)
                end
            end
            return Deserialized
        end
    end
    return Value
end

function Library_Api:Save_Config(Name)
    if not Name or Name == "" then return false end
    local Save_Flags = {}
    for K, V in pairs(Library_Api.Flags) do
        if Ignored_Flags[K] then continue end
        Save_Flags[K] = Serialize_Config_Value(V)
    end
    local Ok, Json = pcall(Http_Service.JSONEncode, Http_Service, Save_Flags)
    if Ok then
        pcall(function()
            Write_File(Configuration.Config_Folder .. "/" .. Name .. ".json", Json)
        end)
        return true
    end
    return false
end

function Library_Api:Load_Config(Name)
    if not Name or Name == "" then return false end
    local Path = Configuration.Config_Folder .. "/" .. Name .. ".json"
    if not Is_File(Path) then return false end
    local Content = Read_File(Path)
    local Success, Data = pcall(Http_Service.JSONDecode, Http_Service, Content)
    if Success and type(Data) == "table" then
        for Flag, Value in pairs(Data) do
            if Ignored_Flags[Flag] then continue end
            Library_Api.Flags[Flag] = Deserialize_Config_Value(Value)
        end
        for Flag, Value in pairs(Library_Api.Flags) do
            if Ignored_Flags[Flag] then continue end
            if Data[Flag] ~= nil and Library_Api.Signals[Flag] then
                task.spawn(Library_Api.Signals[Flag], Value)
            end
        end
        return true
    end
    return false
end

function Library_Api:Delete_Config(Name)
    if not Name or Name == "" then return false end
    local Path = Configuration.Config_Folder .. "/" .. Name .. ".json"
    if Is_File(Path) then
        pcall(function() Del_File(Path) end)
        return true
    end
    return false
end

function Library_Api:Config_Exists(Name)
    if not Name or Name == "" then return false end
    return Is_File(Configuration.Config_Folder .. "/" .. Name .. ".json")
end

local Tooltip_Gui = Instance.new("ScreenGui")
Tooltip_Gui.Name = "PhantomTooltip"
Tooltip_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Tooltip_Gui.Parent = Get_Parent()

local Tooltip_Label = Instance.new("TextLabel")
Tooltip_Label.BackgroundTransparency = 0.05
Tooltip_Label.BackgroundColor3 = Menu_Colors.Container
Tooltip_Label.TextColor3 = Menu_Colors.Text
Tooltip_Label.Font = Configuration.Font_Main
Tooltip_Label.TextSize = 12
Tooltip_Label.Visible = false
Tooltip_Label.Parent = Tooltip_Gui
Tooltip_Label.ZIndex = 1000
Corner_Radius(Tooltip_Label, 4)
Stroke_Border(Tooltip_Label, Menu_Colors.Stroke, 1)

local function Apply_Tooltip(Gui_Obj, Text)
    if not Text or Text == "" then return end
    local Hovered = false
    local C1 = Gui_Obj.MouseEnter:Connect(function()
        Hovered = true
        task.delay(0.5, function()
            if Hovered and Library_Api.Open then
                Tooltip_Label.Text = " " .. Text .. " "
                Tooltip_Label.Size = UDim2.new(0, Tooltip_Label.TextBounds.X + 10, 0, 20)
                local M_Pos = User_Input_Service:GetMouseLocation()
                Tooltip_Label.Position = UDim2.new(0, M_Pos.X + 10, 0, M_Pos.Y - 25)
                Tooltip_Label.Visible = true
            end
        end)
    end)
    local C2 = Gui_Obj.MouseMoved:Connect(function()
        if Tooltip_Label.Visible then
            local M_Pos = User_Input_Service:GetMouseLocation()
            Tooltip_Label.Position = UDim2.new(0, M_Pos.X + 10, 0, M_Pos.Y - 25)
        end
    end)
    local C3 = Gui_Obj.MouseLeave:Connect(function()
        Hovered = false
        Tooltip_Label.Visible = false
    end)
    table.insert(Library_Api.Connections, C1)
    table.insert(Library_Api.Connections, C2)
    table.insert(Library_Api.Connections, C3)
end

function Library_Api:Notify(Title, Text, Duration)
    local Notif_Gui = Get_Parent():FindFirstChild("PhantomNotifications")
    if not Notif_Gui then
        Notif_Gui = Instance.new("ScreenGui")
        Notif_Gui.Name = "PhantomNotifications"
        Notif_Gui.Parent = Get_Parent()
        local Container = Instance.new("Frame")
        Container.Name = "Container"
        Container.Size = UDim2.new(0, 250, 1, -20)
        Container.Position = UDim2.new(1, -270, 0, 10)
        Container.BackgroundTransparency = 1
        Container.Parent = Notif_Gui
        local Layout = Instance.new("UIListLayout")
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        Layout.Padding = UDim.new(0, 10)
        Layout.Parent = Container
    end
    local Notif_Frame = Instance.new("Frame")
    Notif_Frame.Size = UDim2.new(1, 0, 0, 60)
    Notif_Frame.BackgroundColor3 = Menu_Colors.Background
    Notif_Frame.BackgroundTransparency = 0.1
    Notif_Frame.Position = UDim2.new(1, 300, 0, 0)
    Notif_Frame.Parent = Notif_Gui.Container
    Corner_Radius(Notif_Frame, 6)
    Stroke_Border(Notif_Frame, Menu_Colors.Stroke, 1)
    local N_Noise = Instance.new("ImageLabel")
    N_Noise.Size = UDim2.new(1, 0, 1, 0)
    N_Noise.BackgroundTransparency = 1
    N_Noise.Image = "rbxassetid://9968344105"
    N_Noise.ImageTransparency = 0.9
    N_Noise.ScaleType = Enum.ScaleType.Tile
    N_Noise.TileSize = UDim2.new(0, 100, 0, 100)
    N_Noise.Parent = Notif_Frame
    Corner_Radius(N_Noise, 6)
    local N_Title = Instance.new("TextLabel")
    N_Title.Size = UDim2.new(1, -10, 0, 20)
    N_Title.Position = UDim2.new(0, 10, 0, 5)
    N_Title.BackgroundTransparency = 1
    N_Title.Text = Title
    N_Title.TextColor3 = Menu_Colors.Accent
    N_Title.Font = Configuration.Font_Bold
    N_Title.TextSize = 13
    N_Title.TextXAlignment = Enum.TextXAlignment.Left
    N_Title.Parent = Notif_Frame
    Register_Theme(N_Title, "TextColor")
    local N_Text = Instance.new("TextLabel")
    N_Text.Size = UDim2.new(1, -20, 0, 20)
    N_Text.Position = UDim2.new(0, 10, 0, 25)
    N_Text.BackgroundTransparency = 1
    N_Text.Text = Text
    N_Text.TextColor3 = Menu_Colors.Text
    N_Text.Font = Configuration.Font_Main
    N_Text.TextSize = 12
    N_Text.TextXAlignment = Enum.TextXAlignment.Left
    N_Text.Parent = Notif_Frame
    local Timebar_Bg = Instance.new("Frame")
    Timebar_Bg.Size = UDim2.new(1, 0, 0, 2)
    Timebar_Bg.Position = UDim2.new(0, 0, 1, -2)
    Timebar_Bg.BackgroundColor3 = Menu_Colors.Container
    Timebar_Bg.BorderSizePixel = 0
    Timebar_Bg.Parent = Notif_Frame
    Corner_Radius(Timebar_Bg, 2)
    local Timebar = Instance.new("Frame")
    Timebar.Size = UDim2.new(1, 0, 1, 0)
    Timebar.BackgroundColor3 = Menu_Colors.Accent
    Timebar.BorderSizePixel = 0
    Timebar.Parent = Timebar_Bg
    Corner_Radius(Timebar, 2)
    Register_Theme(Timebar, "BackgroundColor")
    Tween_Anim(Notif_Frame, {Position = UDim2.new(0, 0, 0, 0)}, 0.4)
    Tween_Anim(Timebar, {Size = UDim2.new(0, 0, 1, 0)}, Duration, Enum.EasingStyle.Linear)
    task.delay(Duration, function()
        Tween_Anim(Notif_Frame, {Position = UDim2.new(1, 300, 0, 0)}, 0.4).Completed:Wait()
        Notif_Frame:Destroy()
    end)
end

function Library_Api:Init_Watermark()
    local Watermark_Gui = Instance.new("ScreenGui")
    Watermark_Gui.Name = "PhantomWatermark"
    Watermark_Gui.Parent = Get_Parent()
    Watermark_Gui.IgnoreGuiInset = true
    Watermark_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 0, 0, 26)
    Frame.Position = UDim2.new(1, -20, 0, 10)
    Frame.AnchorPoint = Vector2.new(1, 0)
    Frame.BackgroundColor3 = Menu_Colors.Background
    Frame.BackgroundTransparency = 0.05
    Frame.Parent = Watermark_Gui
    Corner_Radius(Frame, 4)
    Stroke_Border(Frame, Menu_Colors.Stroke, 1)
    local Glow = Stroke_Border(Frame, Menu_Colors.Accent, 2, 0.8)
    Register_Theme(Glow, "BorderColor")
    local Accent_Line = Instance.new("Frame")
    Accent_Line.Size = UDim2.new(1, 0, 0, 2)
    Accent_Line.Position = UDim2.new(0, 0, 0, 0)
    Accent_Line.BackgroundColor3 = Menu_Colors.Accent
    Accent_Line.BorderSizePixel = 0
    Accent_Line.Parent = Frame
    Corner_Radius(Accent_Line, 2)
    Register_Theme(Accent_Line, "BackgroundColor")
    local W_Noise = Instance.new("ImageLabel")
    W_Noise.Size = UDim2.new(1, 0, 1, 0)
    W_Noise.BackgroundTransparency = 1
    W_Noise.Image = "rbxassetid://9968344105"
    W_Noise.ImageTransparency = 0.95
    W_Noise.ScaleType = Enum.ScaleType.Tile
    W_Noise.TileSize = UDim2.new(0, 100, 0, 100)
    W_Noise.Parent = Frame
    Corner_Radius(W_Noise, 4)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Configuration.Font_Bold
    Label.TextSize = 12
    Label.TextColor3 = Menu_Colors.Text
    Label.RichText = true
    Label.Parent = Frame
    local Last_Update = 0
    local Frames = 0
    local Conn
    Conn = Run_Service.RenderStepped:Connect(function()
        Frames = Frames + 1
        local Now = os.clock()
        if Now - Last_Update >= 1 then
            local Fps = Frames
            Frames = 0
            Last_Update = Now
            local Ping = "0"
            pcall(function()
                local S = Stats_Service.Network.ServerStatsItem["Data Ping"]:GetValueString()
                Ping = S:match("%d+") or "0"
            end)
            local Time_Str = os.date("%H:%M:%S")
            local Text = string.format(" <font color='#%s'>%s</font> | FPS: %d | Ping: %sms | %s ", Menu_Colors.Accent:ToHex(), Configuration.Name, Fps, Ping, Time_Str)
            Label.Text = Text
            local Bounds = Label.TextBounds.X + 20
            Tween_Anim(Frame, {Size = UDim2.new(0, Bounds, 0, 26)}, 0.1)
        end
    end)
    table.insert(Library_Api.Connections, Conn)
end

function Library_Api:Create_Keybind_List()
    if Library_Api.Keybind_List then return end
    local Screen = Instance.new("ScreenGui")
    Screen.Name = "PrismaKeybinds"
    Screen.Parent = Get_Parent()
    Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 180, 0, 30)
    Frame.Position = UDim2.new(0.01, 0, 0.4, 0)
    Frame.BackgroundColor3 = Menu_Colors.Background
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = Screen
    Frame.Active = true
    Frame.ClipsDescendants = true
    Corner_Radius(Frame, 4)
    Stroke_Border(Frame, Menu_Colors.Stroke, 1, 0)
    Make_Draggable(Frame, Frame)
    local K_Noise = Instance.new("ImageLabel")
    K_Noise.Size = UDim2.new(1, 0, 1, 0)
    K_Noise.BackgroundTransparency = 1
    K_Noise.Image = "rbxassetid://9968344105"
    K_Noise.ImageTransparency = 0.9
    K_Noise.ScaleType = Enum.ScaleType.Tile
    K_Noise.TileSize = UDim2.new(0, 100, 0, 100)
    K_Noise.Parent = Frame
    Corner_Radius(K_Noise, 4)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 24)
    Header.BackgroundColor3 = Menu_Colors.Sidebar
    Header.Parent = Frame
    Corner_Radius(Header, 4)
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 1, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "Keybinds"
    Title.TextColor3 = Menu_Colors.Accent
    Title.Font = Configuration.Font_Bold
    Title.TextSize = 12
    Title.Parent = Header
    Register_Theme(Title, "TextColor")
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 0)
    Container.Position = UDim2.new(0, 0, 0, 26)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame
    local List = Instance.new("UIListLayout")
    List.SortOrder = Enum.SortOrder.LayoutOrder
    List.Parent = Container
    local C1 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Frame.Size = UDim2.new(0, 180, 0, List.AbsoluteContentSize.Y + 30)
    end)
    table.insert(Library_Api.Connections, C1)
    Library_Api.Keybind_List = {Frame = Frame, Container = Container, Screen = Screen}
    Frame.Visible = false
end

function Library_Api:Update_Keybind_List(Name, Key, Active, Mode)
    if not Library_Api.Keybind_List then Library_Api:Create_Keybind_List() end
    local Existing = Library_Api.Keybind_List.Container:FindFirstChild(Name)
    if Active and Key ~= "None" and Key ~= "Unknown" and Mode ~= "Always" then
        if not Existing then
            local Item = Instance.new("Frame")
            Item.Name = Name
            Item.Size = UDim2.new(1, 0, 0, 20)
            Item.BackgroundTransparency = 1
            Item.Parent = Library_Api.Keybind_List.Container
            local L_Name = Instance.new("TextLabel")
            L_Name.Name = "LName"
            L_Name.Size = UDim2.new(0.6, 0, 1, 0)
            L_Name.Position = UDim2.new(0, 5, 0, 0)
            L_Name.BackgroundTransparency = 1
            L_Name.Text = Name
            L_Name.TextColor3 = Menu_Colors.Text
            L_Name.Font = Configuration.Font_Main
            L_Name.TextSize = 12
            L_Name.TextXAlignment = Enum.TextXAlignment.Left
            L_Name.Parent = Item
            local L_Key = Instance.new("TextLabel")
            L_Key.Name = "LKey"
            L_Key.Size = UDim2.new(0.4, -5, 1, 0)
            L_Key.Position = UDim2.new(0.6, 0, 0, 0)
            L_Key.BackgroundTransparency = 1
            L_Key.Text = "[" .. tostring(Key) .. "]"
            L_Key.TextColor3 = Menu_Colors.Text_Dark
            L_Key.Font = Configuration.Font_Main
            L_Key.TextSize = 12
            L_Key.TextXAlignment = Enum.TextXAlignment.Right
            L_Key.Parent = Item
        else
            local L_Key = Existing:FindFirstChild("LKey")
            if L_Key then L_Key.Text = "[" .. tostring(Key) .. "]" end
        end
    else
        if Existing then Existing:Destroy() end
    end
    if Library_Api.Show_Keybinds then
        Library_Api.Keybind_List.Frame.Visible = (#Library_Api.Keybind_List.Container:GetChildren() > 1)
    else
        Library_Api.Keybind_List.Frame.Visible = false
    end
end

local function Create_Dropdown_Element(Text, Flag, Options, Default, Tooltip_Text, Callback, Parent_Frame, Section_Ref, Is_Multi, Custom_Parent)
    local Selected = Library_Api.Flags[Flag]
    if Selected == nil then
        if Is_Multi then
            if type(Default) ~= "table" then Selected = {Default} else Selected = Default end
        else
            Selected = Default or Options[1]
        end
    end
    Library_Api.Defaults[Flag] = Selected
    Library_Api.Flags[Flag] = Selected
    local Is_Dropped = false
    local Parent = Custom_Parent or Parent_Frame
    local Drop_Frame = Instance.new("Frame")
    Drop_Frame.Size = UDim2.new(1, Custom_Parent and -20 or 0, 0, 46)
    if Custom_Parent then Drop_Frame.Position = UDim2.new(0, 20, 0, 0) end
    Drop_Frame.BackgroundTransparency = 1
    Drop_Frame.Parent = Parent
    Drop_Frame.ZIndex = 5
    local D_Label = Instance.new("TextLabel")
    D_Label.Text = Text
    D_Label.Font = Configuration.Font_Main
    D_Label.TextSize = 13
    D_Label.TextColor3 = Custom_Parent and Menu_Colors.Text_Dark or Menu_Colors.Text
    D_Label.Size = UDim2.new(1, 0, 0, 16)
    D_Label.Position = UDim2.new(0, 5, 0, 0)
    D_Label.TextXAlignment = Enum.TextXAlignment.Left
    D_Label.BackgroundTransparency = 1
    D_Label.Parent = Drop_Frame
    local Interactive = Instance.new("TextButton")
    Interactive.Size = UDim2.new(1, 0, 0, 26)
    Interactive.Position = UDim2.new(0, 0, 0, 20)
    Interactive.BackgroundColor3 = Menu_Colors.Container
    Interactive.Text = ""
    Interactive.AutoButtonColor = false
    Interactive.Parent = Drop_Frame
    Interactive.ZIndex = 5
    Corner_Radius(Interactive, 4)
    Stroke_Border(Interactive, Menu_Colors.Stroke, 1, 0.5)
    local Selected_Text = Instance.new("TextLabel")
    Selected_Text.Font = Configuration.Font_Main
    Selected_Text.TextSize = 13
    Selected_Text.TextColor3 = Menu_Colors.Text
    Selected_Text.Size = UDim2.new(1, -25, 1, 0)
    Selected_Text.Position = UDim2.new(0, 8, 0, 0)
    Selected_Text.TextXAlignment = Enum.TextXAlignment.Left
    Selected_Text.BackgroundTransparency = 1
    Selected_Text.ZIndex = 6
    Selected_Text.ClipsDescendants = false
    Selected_Text.TextTruncate = Enum.TextTruncate.AtEnd
    Selected_Text.Parent = Interactive
    local Arrow = Instance.new("ImageLabel")
    Arrow.Image = "rbxassetid://10709790948"
    Arrow.Size = UDim2.new(0, 18, 0, 18)
    Arrow.Position = UDim2.new(1, -20, 0.5, 0)
    Arrow.AnchorPoint = Vector2.new(0, 0.5)
    Arrow.BackgroundTransparency = 1
    Arrow.ImageColor3 = Menu_Colors.Text_Dark
    Arrow.Parent = Interactive
    Arrow.ZIndex = 6
    local List_Frame = Instance.new("ScrollingFrame")
    List_Frame.Size = UDim2.new(1, 0, 0, 0)
    List_Frame.Position = UDim2.new(0, 0, 1, 5)
    List_Frame.BackgroundColor3 = Menu_Colors.Container
    List_Frame.BorderSizePixel = 0
    List_Frame.Parent = Interactive
    List_Frame.ZIndex = 10
    List_Frame.Visible = false
    List_Frame.Active = true
    List_Frame.ScrollBarThickness = 2
    List_Frame.ScrollBarImageColor3 = Menu_Colors.Accent
    List_Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Corner_Radius(List_Frame, 4)
    Stroke_Border(List_Frame, Menu_Colors.Stroke, 1, 0.5)
    local I_List = Instance.new("UIListLayout")
    I_List.SortOrder = Enum.SortOrder.LayoutOrder
    I_List.Parent = List_Frame
    
    local function Close_Dropdown()
        Is_Dropped = false
        if Section_Ref and Section_Ref.Container then Section_Ref.Container.ZIndex = 1 end
        Drop_Frame.ZIndex = 5
        if Custom_Parent then Custom_Parent.ZIndex = 1 end
        Tween_Anim(Drop_Frame, {Size = UDim2.new(1, Custom_Parent and -20 or 0, 0, 46)}, 0.2)
        local T = Tween_Anim(List_Frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
        Tween_Anim(Arrow, {Rotation = 0}, 0.2)
        local C2
        C2 = T.Completed:Connect(function()
            if not Is_Dropped then List_Frame.Visible = false end
            C2:Disconnect()
        end)
    end
    
    local Option_Btns = {}
    local function Is_Selected(Opt)
        if Is_Multi then
            for _, V in ipairs(Selected) do
                if V == Opt then return true end
            end
            return false
        else
            return Selected == Opt
        end
    end
    
    local function Update_Visuals()
        if Is_Multi then
            Selected_Text.Text = (#Selected > 0 and table.concat(Selected, ", ") or "None")
        else
            Selected_Text.Text = tostring(Selected)
        end
        for Opt, Btn in pairs(Option_Btns) do
            if Is_Selected(Opt) then
                Btn.TextColor3 = Menu_Colors.Accent
                Btn.BackgroundTransparency = 0.8
                Btn.BackgroundColor3 = Menu_Colors.Element_Hover
            else
                Btn.TextColor3 = Menu_Colors.Text_Dark
                Btn.BackgroundTransparency = 1
                Btn.BackgroundColor3 = Menu_Colors.Container
            end
        end
    end
    
    local function Build_Options(New_Options)
        for _, Btn in pairs(Option_Btns) do Btn:Destroy() end
        table.clear(Option_Btns)
        Options = New_Options
        for _, Opt in ipairs(Options) do
            local Opt_Btn = Instance.new("TextButton")
            Opt_Btn.Size = UDim2.new(1, 0, 0, 24)
            Opt_Btn.BackgroundColor3 = Menu_Colors.Container
            Opt_Btn.BackgroundTransparency = 1
            Opt_Btn.Text = Opt
            Opt_Btn.Font = Configuration.Font_Main
            Opt_Btn.TextSize = 12
            Opt_Btn.Parent = List_Frame
            Opt_Btn.ZIndex = 11
            
            if Is_Selected(Opt) then
                Opt_Btn.TextColor3 = Menu_Colors.Accent
                Opt_Btn.BackgroundTransparency = 0.8
                Opt_Btn.BackgroundColor3 = Menu_Colors.Element_Hover
            else
                Opt_Btn.TextColor3 = Menu_Colors.Text_Dark
            end
            
            Option_Btns[Opt] = Opt_Btn
            local C3 = Opt_Btn.MouseEnter:Connect(function()
                if not Is_Selected(Opt) then
                    Tween_Anim(Opt_Btn, {BackgroundTransparency = 0, BackgroundColor3 = Menu_Colors.Element_Hover, TextColor3 = Menu_Colors.Accent})
                end
            end)
            local C4 = Opt_Btn.MouseLeave:Connect(function()
                if not Is_Selected(Opt) then
                    Tween_Anim(Opt_Btn, {BackgroundTransparency = 1, BackgroundColor3 = Menu_Colors.Container, TextColor3 = Menu_Colors.Text_Dark})
                end
            end)
            local C5 = Opt_Btn.MouseButton1Click:Connect(function()
                if Is_Multi then
                    local Found = table.find(Selected, Opt)
                    if Found then table.remove(Selected, Found) else table.insert(Selected, Opt) end
                    Update_Visuals()
                    Library_Api.Flags[Flag] = Selected
                    Library_Api.Unsaved = true
                    Callback(Selected)
                else
                    Selected = Opt
                    Update_Visuals()
                    Library_Api.Flags[Flag] = Selected
                    Library_Api.Unsaved = true
                    Callback(Selected)
                    Close_Dropdown()
                end
            end)
            table.insert(Library_Api.Connections, C3)
            table.insert(Library_Api.Connections, C4)
            table.insert(Library_Api.Connections, C5)
        end
    end
    
    Build_Options(Options)
    Update_Visuals()
    
    Library_Api.Signals[Flag] = function(Val)
        if Is_Multi then
            if type(Val) == "table" then
                Selected = Val
            else
                Selected = {Val}
            end
        else
            Selected = Val
        end
        Update_Visuals()
        Library_Api.Unsaved = true
        Callback(Selected)
    end
    
    local C6 = Interactive.MouseButton1Click:Connect(function()
        Is_Dropped = not Is_Dropped
        if Section_Ref and Section_Ref.Container then Section_Ref.Container.ZIndex = Is_Dropped and 10 or 1 end
        Drop_Frame.ZIndex = Is_Dropped and 10 or 5
        if Custom_Parent then Custom_Parent.ZIndex = Is_Dropped and 10 or 1 Custom_Parent.ClipsDescendants = false end
        if Is_Dropped then
            List_Frame.Visible = true
            local List_H = math.min(#Options * 24, 200)
            local Total_H = 46 + List_H + 5
            Tween_Anim(Drop_Frame, {Size = UDim2.new(1, Custom_Parent and -20 or 0, 0, Total_H)}, 0.2)
            Tween_Anim(List_Frame, {Size = UDim2.new(1, 0, 0, List_H)}, 0.2)
            Tween_Anim(Arrow, {Rotation = 180}, 0.2)
        else
            Close_Dropdown()
        end
    end)
    table.insert(Library_Api.Connections, C6)
    Apply_Tooltip(Drop_Frame, Tooltip_Text)
    task.spawn(Callback, Selected)
    
    local Dropdown_Obj = {}
    Dropdown_Obj.Frame = Drop_Frame
    function Dropdown_Obj:Refresh(New_Options, New_Default)
        if Is_Multi then
            if type(New_Default) ~= "table" then Selected = {New_Default} else Selected = New_Default end
        else
            Selected = New_Default or (New_Options[1] or "")
        end
        Library_Api.Flags[Flag] = Selected
        Build_Options(New_Options)
        Update_Visuals()
    end
    function Dropdown_Obj:Get_Selected()
        return Selected
    end
    function Dropdown_Obj:Set(Val)
        if Is_Multi then
            if type(Val) == "table" then Selected = Val else Selected = {Val} end
        else
            Selected = Val
        end
        Library_Api.Flags[Flag] = Selected
        Update_Visuals()
        Callback(Selected)
    end
    return Dropdown_Obj
end

local function Create_Slider_Element(Text, Flag, Min, Max, Default, Increment, Tooltip_Text, Callback, Parent_Frame, Sec_Data)
    Increment = Increment or 1
    local Val = Library_Api.Flags[Flag]
    if Val == nil then
        Val = Default or Min
    end
    Val = Round_To_Increment(Val, Increment)
    Library_Api.Defaults[Flag] = Val
    Library_Api.Flags[Flag] = Val
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 42)
    Frame.BackgroundTransparency = 1
    Frame.Parent = Parent_Frame
    if Sec_Data then table.insert(Sec_Data.Items, {Name = Text, Instance = Frame}) end
    local Label = Instance.new("TextLabel")
    Label.Text = Text
    Label.Font = Configuration.Font_Main
    Label.TextSize = 13
    Label.TextColor3 = Menu_Colors.Text
    Label.Size = UDim2.new(0.6, 0, 0, 16)
    Label.Position = UDim2.new(0, 5, 0, 0)
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.BackgroundTransparency = 1
    Label.Parent = Frame
    local Val_Label = Instance.new("TextBox")
    Val_Label.Text = Format_Number(Val, Increment)
    Val_Label.Font = Configuration.Font_Main
    Val_Label.TextSize = 13
    Val_Label.TextColor3 = Menu_Colors.Text
    Val_Label.Size = UDim2.new(0.4, -5, 0, 16)
    Val_Label.Position = UDim2.new(0.6, 0, 0, 0)
    Val_Label.TextXAlignment = Enum.TextXAlignment.Right
    Val_Label.BackgroundTransparency = 1
    Val_Label.ClearTextOnFocus = true
    Val_Label.Parent = Frame
    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 0, 6)
    Bar.Position = UDim2.new(0, 0, 0, 24)
    Bar.BackgroundColor3 = Menu_Colors.Container
    Bar.Parent = Frame
    Corner_Radius(Bar, 3)
    Stroke_Border(Bar, Menu_Colors.Stroke, 1, 0.5)
    local Fill = Instance.new("Frame")
    local Range = Max - Min
    local Ratio = Range > 0 and (Val - Min) / Range or 0
    Fill.Size = UDim2.new(Ratio, 0, 1, 0)
    Fill.BackgroundColor3 = Menu_Colors.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Corner_Radius(Fill, 3)
    Register_Theme(Fill, "BackgroundColor")
    local Dragging = false
    local Drag_Input
    local function Set_From_Input(Input)
        local R = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        local Raw = Min + (Max - Min) * R
        Val = Round_To_Increment(Raw, Increment)
        Val = math.clamp(Val, Min, Max)
        local Display_Ratio = Range > 0 and (Val - Min) / Range or 0
        Val_Label.Text = Format_Number(Val, Increment)
        Tween_Anim(Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
        Library_Api.Flags[Flag] = Val
        Library_Api.Unsaved = true
        Callback(Val)
    end
    local C1 = Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            Drag_Input = Input
            Set_From_Input(Input)
            local C2
            C2 = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                    C2:Disconnect()
                end
            end)
        end
    end)
    local C3 = User_Input_Service.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            Drag_Input = Input
        end
    end)
    local C4 = Run_Service.RenderStepped:Connect(function()
        if Dragging and Drag_Input then
            Set_From_Input(Drag_Input)
        end
    end)
    table.insert(Library_Api.Connections, C1)
    table.insert(Library_Api.Connections, C3)
    table.insert(Library_Api.Connections, C4)
    local C5 = Val_Label.FocusLost:Connect(function(Enter)
        if Enter then
            local Clean_Text = string.gsub(Val_Label.Text, "[^%d.-]", "")
            local Num = tonumber(Clean_Text)
            if Num then
                Num = Round_To_Increment(Num, Increment)
                Num = math.clamp(Num, Min, Max)
                Val = Num
                local Display_Ratio = Range > 0 and (Val - Min) / Range or 0
                Val_Label.Text = Format_Number(Val, Increment)
                Tween_Anim(Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                Library_Api.Flags[Flag] = Val
                Library_Api.Unsaved = true
                Callback(Val)
            else
                Val_Label.Text = Format_Number(Val, Increment)
            end
        else
            Val_Label.Text = Format_Number(Val, Increment)
        end
    end)
    table.insert(Library_Api.Connections, C5)
    Library_Api.Signals[Flag] = function(Loaded_Val)
        Val = Round_To_Increment(Loaded_Val, Increment)
        Val = math.clamp(Val, Min, Max)
        local Display_Ratio = Range > 0 and (Val - Min) / Range or 0
        Val_Label.Text = Format_Number(Val, Increment)
        Tween_Anim(Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
        Library_Api.Unsaved = true
        Callback(Val)
    end
    Apply_Tooltip(Frame, Tooltip_Text)
    task.spawn(Callback, Val)
    return Frame
end

function Library_Api:Create_Window(Options)
    if Options and Options.Name then Configuration.Name = Options.Name end
    if Options and Options.ConfigFolder then Configuration.Config_Folder = Options.ConfigFolder end
    if not Is_Folder(Configuration.Config_Folder) then Make_Folder(Configuration.Config_Folder) end
    Library_Api:Unload()
    Library_Api:Init_Watermark()
    
    local Screen_Gui_Main = Instance.new("ScreenGui")
    Screen_Gui_Main.Name = Configuration.Name
    Screen_Gui_Main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Screen_Gui_Main.IgnoreGuiInset = true
    Screen_Gui_Main.ResetOnSpawn = false
    Screen_Gui_Main.Parent = Get_Parent()
    Library_Api.Screen_Gui = Screen_Gui_Main
    
    local Mini_Gui = Instance.new("ScreenGui")
    Mini_Gui.Name = "PhantomMiniButton"
    Mini_Gui.Parent = Get_Parent()
    Mini_Gui.Enabled = true
    Mini_Gui.IgnoreGuiInset = true
    
    local Mini_Button = Instance.new("ImageButton")
    Mini_Button.Size = UDim2.new(0, 46, 0, 46)
    Mini_Button.Position = UDim2.new(0, 20, 0.5, -23)
    Mini_Button.BackgroundColor3 = Menu_Colors.Background
    Mini_Button.BackgroundTransparency = 0.1
    Mini_Button.Image = "rbxassetid://112964043447417"
    Mini_Button.ImageColor3 = Menu_Colors.Accent
    Mini_Button.ScaleType = Enum.ScaleType.Fit
    Mini_Button.AutoButtonColor = false
    Mini_Button.Active = true
    Mini_Button.Parent = Mini_Gui
    Corner_Radius(Mini_Button, 23)
    Stroke_Border(Mini_Button, Menu_Colors.Accent, 2, 0.3)
    Register_Theme(Mini_Button, "ImageColor")
    
    local Mini_Was_Dragged = false
    Make_Draggable(Mini_Button, Mini_Button, function(Was_Drag)
        Mini_Was_Dragged = Was_Drag
    end)
    
    local C1 = Mini_Button.MouseButton1Click:Connect(function()
        if Mini_Was_Dragged then
            Mini_Was_Dragged = false
            return
        end
        if Library_Api.Open then
            Library_Api.Open = false
            if Library_Api._Is_Settings then
                Tween_Anim(Library_Api._Set_Scale, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            else
                Tween_Anim(Library_Api._Main_Scale, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            end
            Library_Api._Main_Window.Visible = false
            Library_Api._Settings_Window.Visible = false
            Tooltip_Label.Visible = false
        else
            Library_Api.Open = true
            if Library_Api._Is_Settings then
                Library_Api._Settings_Window.Visible = true
                Library_Api._Settings_Window.BackgroundTransparency = 0.1
                Library_Api._Set_Scale.Scale = Get_Base_Scale() * 0.8
                Tween_Anim(Library_Api._Set_Scale, {Scale = Get_Base_Scale()}, 0.3)
            else
                Library_Api._Main_Window.Visible = true
                Library_Api._Main_Window.BackgroundTransparency = 0.1
                Library_Api._Main_Scale.Scale = Get_Base_Scale() * 0.8
                Tween_Anim(Library_Api._Main_Scale, {Scale = Get_Base_Scale()}, 0.3)
            end
        end
    end)
    table.insert(Library_Api.Connections, C1)
    
    local function Create_Base_Frame(Name)
        local Frame = Instance.new("Frame")
        Frame.Name = Name
        Frame.Size = UDim2.new(0, 650, 0, 400)
        Frame.Position = UDim2.new(0.5, 0, 0.5, 0)
        Frame.AnchorPoint = Vector2.new(0.5, 0.5)
        Frame.BackgroundColor3 = Menu_Colors.Background
        Frame.BackgroundTransparency = 0.1
        Frame.BorderSizePixel = 0
        Frame.ClipsDescendants = false
        Frame.Visible = false
        Frame.Parent = Screen_Gui_Main
        Frame.Active = true
        local Size_Constraint = Instance.new("UISizeConstraint")
        Size_Constraint.MaxSize = Vector2.new(1400, 900)
        Size_Constraint.MinSize = Vector2.new(450, 300)
        Size_Constraint.Parent = Frame
        Corner_Radius(Frame, 6)
        Stroke_Border(Frame, Menu_Colors.Stroke, 1, 0)
        local Bg_Noise = Instance.new("ImageLabel")
        Bg_Noise.Size = UDim2.new(1, 0, 1, 0)
        Bg_Noise.BackgroundTransparency = 1
        Bg_Noise.Image = "rbxassetid://9968344105"
        Bg_Noise.ImageTransparency = 0.9
        Bg_Noise.ScaleType = Enum.ScaleType.Tile
        Bg_Noise.TileSize = UDim2.new(0, 100, 0, 100)
        Bg_Noise.Parent = Frame
        Corner_Radius(Bg_Noise, 6)
        local Drag_Header = Instance.new("Frame")
        Drag_Header.Name = "DragHeader"
        Drag_Header.Size = UDim2.new(0, 180, 0, 60)
        Drag_Header.BackgroundTransparency = 1
        Drag_Header.Parent = Frame
        local Scale = Instance.new("UIScale")
        Scale.Scale = 1
        Scale.Parent = Frame
        Make_Draggable(Drag_Header, Frame)
        return Frame, Scale
    end
    
    local Main_Window, Main_Scale = Create_Base_Frame("MainWindow")
    local Settings_Window, Set_Scale = Create_Base_Frame("SettingsWindow")
    Library_Api._Main_Window = Main_Window
    Library_Api._Main_Scale = Main_Scale
    Library_Api._Settings_Window = Settings_Window
    Library_Api._Set_Scale = Set_Scale
    Library_Api._Is_Settings = false
    
    local Resizer = Instance.new("Frame")
    Resizer.Size = UDim2.new(0, 20, 0, 20)
    Resizer.Position = UDim2.new(1, 0, 1, 0)
    Resizer.AnchorPoint = Vector2.new(1, 1)
    Resizer.BackgroundTransparency = 1
    Resizer.Parent = Main_Window
    Resizer.ZIndex = 20
    Resizer.Active = true
    local Resizer_Icon = Instance.new("TextLabel")
    Resizer_Icon.Size = UDim2.new(1, 0, 1, 0)
    Resizer_Icon.BackgroundTransparency = 1
    Resizer_Icon.Text = "◢"
    Resizer_Icon.TextColor3 = Menu_Colors.Text_Dark
    Resizer_Icon.TextSize = 16
    Resizer_Icon.Parent = Resizer
    
    local C2 = Resizer.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then Tween_Anim(Resizer_Icon, {TextColor3 = Menu_Colors.Accent}) end
    end)
    local C3 = Resizer.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then Tween_Anim(Resizer_Icon, {TextColor3 = Menu_Colors.Text_Dark}) end
    end)
    table.insert(Library_Api.Connections, C2)
    table.insert(Library_Api.Connections, C3)
    Make_Resizable(Resizer, Main_Window, Vector2.new(450, 300))
    
    local function Create_Sidebar(Parent, Is_Settings)
        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(0, 180, 1, 0)
        Bar.BackgroundColor3 = Menu_Colors.Sidebar
        Bar.BorderSizePixel = 0
        Bar.Parent = Parent
        Bar.Active = true
        Corner_Radius(Bar, 6)
        local Div = Instance.new("Frame")
        Div.Size = UDim2.new(0, 1, 1, 0)
        Div.Position = UDim2.new(1, 0, 0, 0)
        Div.BackgroundColor3 = Menu_Colors.Stroke
        Div.BorderSizePixel = 0
        Div.Parent = Bar
        
        if Is_Settings then
            local Back_Btn = Instance.new("TextButton")
            Back_Btn.Size = UDim2.new(1, -20, 0, 30)
            Back_Btn.Position = UDim2.new(0, 10, 0, 15)
            Back_Btn.BackgroundColor3 = Menu_Colors.Container
            Back_Btn.Text = " < Back to Menu"
            Back_Btn.Font = Configuration.Font_Bold
            Back_Btn.TextSize = 13
            Back_Btn.TextColor3 = Menu_Colors.Text_Dark
            Back_Btn.TextXAlignment = Enum.TextXAlignment.Left
            Back_Btn.AutoButtonColor = false
            Back_Btn.Parent = Bar
            Corner_Radius(Back_Btn, 4)
            Stroke_Border(Back_Btn, Menu_Colors.Stroke, 1, 0.5)
            local C4 = Back_Btn.MouseEnter:Connect(function() Tween_Anim(Back_Btn, {TextColor3 = Menu_Colors.Accent}) end)
            local C5 = Back_Btn.MouseLeave:Connect(function() Tween_Anim(Back_Btn, {TextColor3 = Menu_Colors.Text_Dark}) end)
            table.insert(Library_Api.Connections, C4)
            table.insert(Library_Api.Connections, C5)
            local Title = Instance.new("TextLabel")
            Title.Text = "Settings"
            Title.Size = UDim2.new(1, 0, 0, 30)
            Title.Position = UDim2.new(0, 0, 0, 55)
            Title.Font = Configuration.Font_Bold
            Title.TextSize = 22
            Title.TextColor3 = Menu_Colors.Text
            Title.BackgroundTransparency = 1
            Title.Parent = Bar
            return Bar, nil, Back_Btn
        else
            local Logo = Instance.new("TextLabel")
            Logo.Text = Configuration.Name
            Logo.RichText = true
            Logo.Position = UDim2.new(0, 15, 0, 20)
            Logo.Size = UDim2.new(1, -30, 0, 30)
            Logo.Font = Configuration.Font_Bold
            Logo.TextSize = 20
            Logo.TextColor3 = Menu_Colors.Accent
            Logo.TextXAlignment = Enum.TextXAlignment.Left
            Logo.BackgroundTransparency = 1
            Logo.Parent = Bar
            Register_Theme(Logo, "TextColor")
            local Container = Instance.new("ScrollingFrame")
            Container.Size = UDim2.new(1, 0, 1, -130)
            Container.Position = UDim2.new(0, 0, 0, 60)
            Container.BackgroundTransparency = 1
            Container.BorderSizePixel = 0
            Container.ScrollBarThickness = 2
            Container.ScrollBarImageColor3 = Menu_Colors.Accent
            Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
            Container.ClipsDescendants = true
            Container.Parent = Bar
            Register_Theme(Container, "ScrollBar")
            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 6)
            List.HorizontalAlignment = Enum.HorizontalAlignment.Center
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Container
            return Bar, Container, nil
        end
    end
    
    local Main_Bar, Tab_Container, _ = Create_Sidebar(Main_Window, false)
    local Set_Bar, Set_Container, Back_Btn = Create_Sidebar(Settings_Window, true)
    
    local Profile_Btn = Instance.new("TextButton")
    Profile_Btn.Size = UDim2.new(1, 0, 0, 60)
    Profile_Btn.Position = UDim2.new(0, 0, 1, 0)
    Profile_Btn.AnchorPoint = Vector2.new(0, 1)
    Profile_Btn.BackgroundColor3 = Menu_Colors.Sidebar
    Profile_Btn.BorderSizePixel = 0
    Profile_Btn.Text = ""
    Profile_Btn.AutoButtonColor = false
    Profile_Btn.Parent = Main_Bar
    
    local Side_Avatar = Instance.new("ImageLabel")
    Side_Avatar.Size = UDim2.new(0, 36, 0, 36)
    Side_Avatar.Position = UDim2.new(0, 15, 0.5, 0)
    Side_Avatar.AnchorPoint = Vector2.new(0, 0.5)
    Side_Avatar.BackgroundColor3 = Menu_Colors.Container
    local S2, Av2 = pcall(function() return Players_Service:GetUserThumbnailAsync(Local_Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100) end)
    Side_Avatar.Image = S2 and Av2 or "rbxassetid://0"
    Side_Avatar.Parent = Profile_Btn
    Corner_Radius(Side_Avatar, 18)
    local Av_S = Stroke_Border(Side_Avatar, Menu_Colors.Accent, 1)
    Register_Theme(Av_S, "BorderColor")
    
    local Side_Name = Instance.new("TextLabel")
    Side_Name.Size = UDim2.new(0, 100, 0, 16)
    Side_Name.Position = UDim2.new(0, 60, 0.5, -9)
    Side_Name.AnchorPoint = Vector2.new(0, 0.5)
    Side_Name.BackgroundTransparency = 1
    Side_Name.Text = Local_Player.Name
    Side_Name.TextColor3 = Menu_Colors.Text
    Side_Name.Font = Configuration.Font_Bold
    Side_Name.TextSize = 13
    Side_Name.TextXAlignment = Enum.TextXAlignment.Left
    Side_Name.Parent = Profile_Btn
    
    local Side_Sub = Instance.new("TextLabel")
    Side_Sub.Size = UDim2.new(0, 100, 0, 14)
    Side_Sub.Position = UDim2.new(0, 60, 0.5, 9)
    Side_Sub.AnchorPoint = Vector2.new(0, 0.5)
    Side_Sub.BackgroundTransparency = 1
    Side_Sub.Text = "Settings"
    Side_Sub.TextColor3 = Menu_Colors.Text_Dark
    Side_Sub.Font = Configuration.Font_Main
    Side_Sub.TextSize = 11
    Side_Sub.TextXAlignment = Enum.TextXAlignment.Left
    Side_Sub.Parent = Profile_Btn
    
    local Is_Settings = false
    local Animating = false
    
    local function Toggle_Main()
        if Animating then return end
        Animating = true
        Library_Api.Open = not Library_Api.Open
        if Library_Api.Open then
            if Is_Settings then
                Settings_Window.Visible = true
                Settings_Window.BackgroundTransparency = 0.1
                Set_Scale.Scale = Get_Base_Scale() * 0.8
                Tween_Anim(Set_Scale, {Scale = Get_Base_Scale()}, 0.3).Completed:Wait()
            else
                Main_Window.Visible = true
                Main_Window.BackgroundTransparency = 0.1
                Main_Scale.Scale = Get_Base_Scale() * 0.8
                Tween_Anim(Main_Scale, {Scale = Get_Base_Scale()}, 0.3).Completed:Wait()
            end
        else
            if Is_Settings then
                Tween_Anim(Set_Scale, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            else
                Tween_Anim(Main_Scale, {Scale = Get_Base_Scale() * 0.8}, 0.2).Completed:Wait()
            end
            Main_Window.Visible = false
            Settings_Window.Visible = false
            Tooltip_Label.Visible = false
        end
        Animating = false
    end
    
    local function Switch_To_Settings()
        if Animating then return end
        Animating = true
        Settings_Window.Position = Main_Window.Position
        Settings_Window.Size = Main_Window.Size
        Tween_Anim(Main_Scale, {Scale = Get_Base_Scale() * 0.9}, 0.15).Completed:Wait()
        Main_Window.Visible = false
        Settings_Window.Visible = true
        Settings_Window.BackgroundTransparency = 0.1
        Set_Scale.Scale = Get_Base_Scale() * 0.9
        Tween_Anim(Set_Scale, {Scale = Get_Base_Scale()}, 0.2).Completed:Wait()
        Is_Settings = true
        Library_Api._Is_Settings = true
        Animating = false
    end
    
    local function Switch_To_Main()
        if Animating then return end
        Animating = true
        Main_Window.Position = Settings_Window.Position
        Main_Window.Size = Settings_Window.Size
        Tween_Anim(Set_Scale, {Scale = Get_Base_Scale() * 0.9}, 0.15).Completed:Wait()
        Settings_Window.Visible = false
        Main_Window.Visible = true
        Main_Window.BackgroundTransparency = 0.1
        Main_Scale.Scale = Get_Base_Scale() * 0.9
        Tween_Anim(Main_Scale, {Scale = Get_Base_Scale()}, 0.2).Completed:Wait()
        Is_Settings = false
        Library_Api._Is_Settings = false
        Animating = false
    end
    
    local C6 = Profile_Btn.MouseButton1Click:Connect(function() task.spawn(Switch_To_Settings) end)
    local C7 = Back_Btn.MouseButton1Click:Connect(function() task.spawn(Switch_To_Main) end)
    table.insert(Library_Api.Connections, C6)
    table.insert(Library_Api.Connections, C7)
    
    local C8 = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if Library_Api.Open then
            if Is_Settings and Settings_Window.Visible then
                Set_Scale.Scale = Get_Base_Scale()
            elseif not Is_Settings and Main_Window.Visible then
                Main_Scale.Scale = Get_Base_Scale()
            end
        end
    end)
    table.insert(Library_Api.Connections, C8)
    
    local Menu_Bind_Connection = User_Input_Service.InputBegan:Connect(function(Input, Gp)
        if not Gp and Input.KeyCode == Configuration.Keybind then
            task.spawn(Toggle_Main)
        end
    end)
    table.insert(Library_Api.Connections, Menu_Bind_Connection)
    
    local Window_Obj = {}
    local Main_Pages = Instance.new("Frame")
    Main_Pages.Size = UDim2.new(1, -181, 1, 0)
    Main_Pages.Position = UDim2.new(0, 181, 0, 0)
    Main_Pages.BackgroundTransparency = 1
    Main_Pages.Parent = Main_Window
    
    function Window_Obj:Create_Raw_Section(Text, Parent_Val)
        local Section = {}
        local Container = Instance.new("Frame")
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.BackgroundColor3 = Menu_Colors.Section
        Container.Parent = Parent_Val
        Container.ZIndex = 1
        Corner_Radius(Container, 6)
        Stroke_Border(Container, Menu_Colors.Stroke, 1, 0.5)
        Section.Container = Container
        local Title = Instance.new("TextLabel")
        Title.Text = Text
        Title.Font = Configuration.Font_Bold
        Title.TextSize = 12
        Title.TextColor3 = Menu_Colors.Text_Dark
        Title.Size = UDim2.new(1, -20, 0, 30)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Container
        local Content = Instance.new("Frame")
        Content.Name = "Content"
        Content.Size = UDim2.new(1, -10, 0, 0)
        Content.Position = UDim2.new(0, 5, 0, 30)
        Content.BackgroundTransparency = 1
        Content.Parent = Container
        local List = Instance.new("UIListLayout")
        List.Padding = UDim.new(0, 6)
        List.SortOrder = Enum.SortOrder.LayoutOrder
        List.Parent = Content
        local Lc1 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 40)
        end)
        table.insert(Library_Api.Connections, Lc1)
        
        function Section:Label(L_Text, Options)
            Options = Options or {}
            local Label_Obj = {}
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 26)
            Frame.BackgroundColor3 = Menu_Colors.Container
            Frame.BackgroundTransparency = 0.5
            Frame.Parent = Content
            Corner_Radius(Frame, 4)
            Stroke_Border(Frame, Menu_Colors.Stroke, 1, 0.5)
            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, -10, 1, -10)
            Lbl.Position = UDim2.new(0, 5, 0, 5)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = tostring(L_Text)
            Lbl.Font = Configuration.Font_Main
            Lbl.TextSize = 13
            Lbl.TextColor3 = Options.Color or Menu_Colors.Text
            Lbl.TextXAlignment = Options.Alignment or Enum.TextXAlignment.Left
            Lbl.TextYAlignment = Enum.TextYAlignment.Top
            Lbl.RichText = true
            Lbl.TextWrapped = true
            Lbl.Parent = Frame
            local function Update_Height()
                local Text_Height = Lbl.TextBounds.Y
                if Text_Height > 16 then Frame.Size = UDim2.new(1, 0, 0, Text_Height + 10) else Frame.Size = UDim2.new(1, 0, 0, 26) end
            end
            local Bounds_Conn = Lbl:GetPropertyChangedSignal("TextBounds"):Connect(Update_Height)
            table.insert(Library_Api.Connections, Bounds_Conn)
            Update_Height()
            function Label_Obj:Set(New_Text) Lbl.Text = tostring(New_Text) end
            function Label_Obj:Set_Color(New_Color) Lbl.TextColor3 = New_Color end
            return Label_Obj
        end
        
        function Section:Button(Text_Val, Tooltip_Text, Callback)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Menu_Colors.Container
            Btn.Text = Text_Val
            Btn.Font = Configuration.Font_Main
            Btn.TextSize = 13
            Btn.TextColor3 = Menu_Colors.Text
            Btn.AutoButtonColor = false
            Btn.Parent = Content
            Corner_Radius(Btn, 4)
            local S = Stroke_Border(Btn, Menu_Colors.Stroke, 1, 0.5)
            local Bc1 = Btn.MouseEnter:Connect(function() Tween_Anim(Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(S, {Color = Menu_Colors.Accent}) end)
            local Bc2 = Btn.MouseLeave:Connect(function() Tween_Anim(Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(S, {Color = Menu_Colors.Stroke}) end)
            local Bc3 = Btn.MouseButton1Click:Connect(Callback)
            table.insert(Library_Api.Connections, Bc1)
            table.insert(Library_Api.Connections, Bc2)
            table.insert(Library_Api.Connections, Bc3)
            Apply_Tooltip(Btn, Tooltip_Text)
            return Btn
        end
        
        function Section:Toggle(Text_Val, Flag, Default, Tooltip_Text, Callback)
            Library_Api.Defaults[Flag] = Default or false
            local Toggled = Library_Api.Flags[Flag]
            if Toggled == nil then
                Toggled = Default or false
                Library_Api.Flags[Flag] = Toggled
            end
            local Toggle_Obj = {}
            Library_Api.Signals[Flag] = function(Val)
                if Toggled ~= Val then
                    Toggled = Val
                    if Toggle_Obj.Update_Anim then Toggle_Obj.Update_Anim() end
                    Library_Api.Unsaved = true
                    Callback(Val)
                end
            end
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 32)
            Btn.BackgroundColor3 = Menu_Colors.Container
            Btn.Text = ""
            Btn.AutoButtonColor = false
            Btn.Parent = Content
            Corner_Radius(Btn, 4)
            Stroke_Border(Btn, Menu_Colors.Stroke, 1, 0.5)
            local Label = Instance.new("TextLabel")
            Label.Text = Text_Val
            Label.Font = Configuration.Font_Main
            Label.TextSize = 13
            Label.TextColor3 = Menu_Colors.Text
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Btn
            local Box = Instance.new("Frame")
            Box.Size = UDim2.new(0, 18, 0, 18)
            Box.Position = UDim2.new(1, -10, 0.5, 0)
            Box.AnchorPoint = Vector2.new(1, 0.5)
            Box.BackgroundColor3 = Menu_Colors.Background
            Box.Parent = Btn
            Corner_Radius(Box, 4)
            Stroke_Border(Box, Menu_Colors.Stroke, 1, 0.5)
            local Fill = Instance.new("Frame")
            Fill.Size = UDim2.new(1, -4, 1, -4)
            Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
            Fill.AnchorPoint = Vector2.new(0.5, 0.5)
            Fill.BackgroundColor3 = Menu_Colors.Accent
            Fill.BackgroundTransparency = Toggled and 0 or 1
            Fill.Parent = Box
            Corner_Radius(Fill, 3)
            Register_Theme(Fill, "BackgroundColor")
            local Sub_Container = Instance.new("Frame")
            Sub_Container.Name = "Sub_" .. Text_Val
            Sub_Container.Size = UDim2.new(1, 0, 0, 0)
            Sub_Container.BackgroundTransparency = 1
            Sub_Container.ClipsDescendants = true
            Sub_Container.Visible = false
            Sub_Container.Parent = Content
            local Sub_List = Instance.new("UIListLayout")
            Sub_List.Padding = UDim.new(0, 6)
            Sub_List.SortOrder = Enum.SortOrder.LayoutOrder
            Sub_List.Parent = Sub_Container
            local Current_Tween = nil
            local function Toggle_Anim()
                if Current_Tween then Current_Tween:Cancel() end
                Tween_Anim(Fill, {BackgroundTransparency = Toggled and 0 or 1}, 0.2)
                Library_Api.Flags[Flag] = Toggled
                if Toggle_Obj.Keybind_Value then
                    Library_Api:Update_Keybind_List(Text_Val, Toggle_Obj.Keybind_Value.Name, Toggled, Toggle_Obj.Keybind_Mode)
                end
                if Toggled then
                    Sub_Container.Visible = true
                    Sub_Container.ClipsDescendants = true
                    local H = Sub_List.AbsoluteContentSize.Y
                    if H > 0 then H = H + 6 end
                    Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, H)})
                    Current_Tween:Play()
                    local Tc
                    Tc = Current_Tween.Completed:Connect(function(State)
                        if State == Enum.PlaybackState.Completed and Toggled then Sub_Container.ClipsDescendants = false end
                        Tc:Disconnect()
                    end)
                else
                    Sub_Container.ClipsDescendants = true
                    Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                    Current_Tween:Play()
                    local Expected_Toggle = Toggled
                    local Tc
                    Tc = Current_Tween.Completed:Connect(function(Playback_State)
                        if Playback_State == Enum.PlaybackState.Completed and Expected_Toggle == Toggled and not Toggled then Sub_Container.Visible = false end
                        Tc:Disconnect()
                    end)
                end
            end
            Toggle_Obj.Update_Anim = Toggle_Anim
            local Tlc1 = Sub_List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                if Toggled then
                    local H = Sub_List.AbsoluteContentSize.Y
                    if H > 0 then H = H + 6 end
                    Sub_Container.Size = UDim2.new(1, 0, 0, H)
                end
            end)
            table.insert(Library_Api.Connections, Tlc1)
            local Tlc2 = Btn.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Library_Api.Unsaved = true
                Toggle_Anim()
                Callback(Toggled)
            end)
            table.insert(Library_Api.Connections, Tlc2)
            if Toggled then Toggle_Anim() end
            Apply_Tooltip(Btn, Tooltip_Text)
            task.spawn(Callback, Toggled)
            return Toggle_Obj
        end
        
        function Section:Textbox(Text_Val, Flag, Placeholder, Tooltip_Text, Callback)
            Library_Api.Defaults[Flag] = ""
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 50)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Content
            local Label = Instance.new("TextLabel")
            Label.Text = Text_Val
            Label.Font = Configuration.Font_Main
            Label.TextSize = 13
            Label.TextColor3 = Menu_Colors.Text
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Frame
            local Box_Cont = Instance.new("Frame")
            Box_Cont.Size = UDim2.new(1, 0, 0, 28)
            Box_Cont.Position = UDim2.new(0, 0, 0, 22)
            Box_Cont.BackgroundColor3 = Menu_Colors.Container
            Box_Cont.Parent = Frame
            Corner_Radius(Box_Cont, 4)
            Stroke_Border(Box_Cont, Menu_Colors.Stroke, 1, 0.5)
            local Input = Instance.new("TextBox")
            Input.Size = UDim2.new(1, -10, 1, 0)
            Input.Position = UDim2.new(0, 5, 0, 0)
            Input.BackgroundTransparency = 1
            Input.TextColor3 = Menu_Colors.Text
            Input.PlaceholderText = Placeholder
            Input.PlaceholderColor3 = Menu_Colors.Text_Dark
            Input.Font = Configuration.Font_Main
            Input.TextSize = 13
            Input.TextXAlignment = Enum.TextXAlignment.Left
            local Current_Text = Library_Api.Flags[Flag] or ""
            Input.Text = Current_Text
            Input.ClearTextOnFocus = false
            Input.Parent = Box_Cont
            local Ic1 = Input.FocusLost:Connect(function(Enter)
                if Enter then
                    Library_Api.Flags[Flag] = Input.Text
                    Library_Api.Unsaved = true
                    Callback(Input.Text)
                end
            end)
            local Ic2 = Input.Changed:Connect(function(Prop)
                if Prop == "Text" then Library_Api.Flags[Flag] = Input.Text end
            end)
            table.insert(Library_Api.Connections, Ic1)
            table.insert(Library_Api.Connections, Ic2)
            Library_Api.Flags[Flag] = Current_Text
            Library_Api.Signals[Flag] = function(Val)
                Input.Text = Val
                Library_Api.Unsaved = true
                Callback(Val)
            end
            Apply_Tooltip(Frame, Tooltip_Text)
            task.spawn(Callback, Current_Text)
            return Input
        end
        
        function Section:Dropdown(Text_Val, Flag, Options, Default, Tooltip_Text, Callback, Custom_Parent, Is_Multi)
            return Create_Dropdown_Element(Text_Val, Flag, Options, Default, Tooltip_Text, Callback, Content, Section, Is_Multi, Custom_Parent)
        end
        
        function Section:ColorPicker(Text_Val, Flag, Default, Tooltip_Text, Callback)
            local Color_Val = Library_Api.Flags[Flag] or Default or Color3.fromRGB(255, 255, 255)
            Library_Api.Defaults[Flag] = Default or Color3.fromRGB(255, 255, 255)
            Library_Api.Flags[Flag] = Color_Val
            local H, S, V = Color_Val:ToHSV()
            local Is_Open = false
            local Container_Frame = Instance.new("Frame")
            Container_Frame.Size = UDim2.new(1, 0, 0, 30)
            Container_Frame.BackgroundTransparency = 1
            Container_Frame.Parent = Content
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 30)
            Frame.BackgroundTransparency = 1
            Frame.Parent = Container_Frame
            Frame.ZIndex = 5
            local Label = Instance.new("TextLabel")
            Label.Text = Text_Val
            Label.Font = Configuration.Font_Main
            Label.TextSize = 13
            Label.TextColor3 = Menu_Colors.Text
            Label.Size = UDim2.new(0.6, 0, 1, 0)
            Label.Position = UDim2.new(0, 5, 0, 0)
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = Frame
            local Preview = Instance.new("TextButton")
            Preview.Size = UDim2.new(0, 40, 0, 20)
            Preview.Position = UDim2.new(1, -5, 0.5, 0)
            Preview.AnchorPoint = Vector2.new(1, 0.5)
            Preview.BackgroundColor3 = Color_Val
            Preview.AutoButtonColor = false
            Preview.Text = ""
            Preview.Parent = Frame
            Corner_Radius(Preview, 4)
            Stroke_Border(Preview, Menu_Colors.Stroke, 1, 0.5)
            local Picker_Cont = Instance.new("Frame")
            Picker_Cont.Size = UDim2.new(1, 0, 0, 0)
            Picker_Cont.Position = UDim2.new(0, 0, 0, 30)
            Picker_Cont.BackgroundColor3 = Menu_Colors.Background
            Picker_Cont.Parent = Container_Frame
            Picker_Cont.ClipsDescendants = true
            Picker_Cont.Visible = false
            Picker_Cont.ZIndex = 10
            Corner_Radius(Picker_Cont, 4)
            local SV_Map = Instance.new("ImageLabel")
            SV_Map.Size = UDim2.new(0, 140, 0, 120)
            SV_Map.Position = UDim2.new(0, 10, 0, 10)
            SV_Map.Image = "rbxassetid://4155801252"
            SV_Map.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
            SV_Map.Parent = Picker_Cont
            SV_Map.ZIndex = 11
            SV_Map.Active = true
            Corner_Radius(SV_Map, 4)
            local SV_Cursor = Instance.new("Frame")
            SV_Cursor.Size = UDim2.new(0, 8, 0, 8)
            SV_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
            SV_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
            SV_Cursor.Parent = SV_Map
            SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
            SV_Cursor.ZIndex = 12
            Corner_Radius(SV_Cursor, 4)
            local Hue_Bar = Instance.new("ImageLabel")
            Hue_Bar.Size = UDim2.new(0, 20, 0, 120)
            Hue_Bar.Position = UDim2.new(0, 160, 0, 10)
            Hue_Bar.Image = "rbxassetid://4155801252"
            Hue_Bar.Parent = Picker_Cont
            Hue_Bar.ZIndex = 11
            Hue_Bar.Active = true
            Corner_Radius(Hue_Bar, 4)
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
            H_Cursor.Position = UDim2.new(0, 0, H, 0)
            H_Cursor.ZIndex = 12
            local Hex_Input = Instance.new("TextBox")
            Hex_Input.Size = UDim2.new(0, 170, 0, 20)
            Hex_Input.Position = UDim2.new(0, 10, 0, 140)
            Hex_Input.BackgroundColor3 = Menu_Colors.Container
            Hex_Input.TextColor3 = Menu_Colors.Text
            Hex_Input.Font = Configuration.Font_Main
            Hex_Input.TextSize = 12
            Hex_Input.Text = "#" .. Color_Val:ToHex()
            Hex_Input.Parent = Picker_Cont
            Hex_Input.ZIndex = 11
            Corner_Radius(Hex_Input, 4)
            Stroke_Border(Hex_Input, Menu_Colors.Stroke, 1)
            local function Update_Color()
                Color_Val = Color3.fromHSV(H, S, V)
                Preview.BackgroundColor3 = Color_Val
                SV_Map.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                Hex_Input.Text = "#" .. Color_Val:ToHex()
                Library_Api.Flags[Flag] = Color_Val
                Library_Api.Unsaved = true
                Callback(Color_Val)
            end
            local Hc1 = Hex_Input.FocusLost:Connect(function()
                local T_Hex = Hex_Input.Text:gsub("#", "")
                if T_Hex:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                    pcall(function()
                        local Nc = Color3.fromHex(T_Hex)
                        H, S, V = Nc:ToHSV()
                        H_Cursor.Position = UDim2.new(0, 0, H, 0)
                        SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        Update_Color()
                    end)
                else
                    Hex_Input.Text = "#" .. Color_Val:ToHex()
                end
            end)
            table.insert(Library_Api.Connections, Hc1)
            Library_Api.Signals[Flag] = function(Loaded_Val)
                if typeof(Loaded_Val) == "Color3" then
                    Color_Val = Loaded_Val
                    H, S, V = Color_Val:ToHSV()
                    H_Cursor.Position = UDim2.new(0, 0, H, 0)
                    SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    Update_Color()
                end
            end
            local function Set_SV(Input)
                local R_X = math.clamp((Input.Position.X - SV_Map.AbsolutePosition.X) / SV_Map.AbsoluteSize.X, 0, 1)
                local R_Y = math.clamp((Input.Position.Y - SV_Map.AbsolutePosition.Y) / SV_Map.AbsoluteSize.Y, 0, 1)
                S = R_X
                V = 1 - R_Y
                SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                Update_Color()
            end
            local function Set_H(Input)
                local R_Y = math.clamp((Input.Position.Y - Hue_Bar.AbsolutePosition.Y) / Hue_Bar.AbsoluteSize.Y, 0, 1)
                H = R_Y
                H_Cursor.Position = UDim2.new(0, 0, H, 0)
                Update_Color()
            end
            local Drag_SV = false
            local Drag_Input_SV
            local Sv1 = SV_Map.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Drag_SV = true
                    Drag_Input_SV = Input
                    Set_SV(Input)
                    local Sc2
                    Sc2 = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Drag_SV = false
                            Sc2:Disconnect()
                        end
                    end)
                end
            end)
            local Sv3 = User_Input_Service.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Drag_SV then Drag_Input_SV = Input end
                end
            end)
            local Sv4 = Run_Service.RenderStepped:Connect(function()
                if Drag_SV and Drag_Input_SV then Set_SV(Drag_Input_SV) end
            end)
            table.insert(Library_Api.Connections, Sv1)
            table.insert(Library_Api.Connections, Sv3)
            table.insert(Library_Api.Connections, Sv4)
            local Drag_H = false
            local Drag_Input_H
            local H1 = Hue_Bar.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Drag_H = true
                    Drag_Input_H = Input
                    Set_H(Input)
                    local Hc2
                    Hc2 = Input.Changed:Connect(function()
                        if Input.UserInputState == Enum.UserInputState.End then
                            Drag_H = false
                            Hc2:Disconnect()
                        end
                    end)
                end
            end)
            local H3 = User_Input_Service.InputChanged:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                    if Drag_H then Drag_Input_H = Input end
                end
            end)
            local H4 = Run_Service.RenderStepped:Connect(function()
                if Drag_H and Drag_Input_H then Set_H(Drag_Input_H) end
            end)
            table.insert(Library_Api.Connections, H1)
            table.insert(Library_Api.Connections, H3)
            table.insert(Library_Api.Connections, H4)
            local Pc1 = Preview.MouseButton1Click:Connect(function()
                Is_Open = not Is_Open
                Container_Frame.ZIndex = Is_Open and 10 or 5
                if Is_Open then
                    Picker_Cont.Visible = true
                    Tween_Anim(Container_Frame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                    Tween_Anim(Picker_Cont, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                else
                    Tween_Anim(Container_Frame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                    local T_Anim = Tween_Anim(Picker_Cont, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                    local Pc2
                    Pc2 = T_Anim.Completed:Connect(function()
                        if not Is_Open then Picker_Cont.Visible = false end
                        Pc2:Disconnect()
                    end)
                end
            end)
            table.insert(Library_Api.Connections, Pc1)
            Apply_Tooltip(Container_Frame, Tooltip_Text)
            task.spawn(Callback, Color_Val)
            return Section
        end
        return Section
    end

    local function Populate_Settings()
        local Set_Page = Instance.new("ScrollingFrame")
        Set_Page.Size = UDim2.new(1, -200, 1, -20)
        Set_Page.Position = UDim2.new(0, 190, 0, 10)
        Set_Page.BackgroundTransparency = 1
        Set_Page.ScrollBarThickness = 2
        Set_Page.ScrollBarImageColor3 = Menu_Colors.Accent
        Set_Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Set_Page.Active = true
        Set_Page.Parent = Settings_Window
        Register_Theme(Set_Page, "ScrollBar")
        
        local List_Layout = Instance.new("UIListLayout")
        List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
        List_Layout.Padding = UDim.new(0, 10)
        List_Layout.Parent = Set_Page
        
        local Menu_Sec = Window_Obj:Create_Raw_Section("Menu Settings", Set_Page)
        Menu_Sec:Button("Unload UI", "Destroys the Hub", function()
            Library_Api:Unload()
        end)
        
        local Keybind_Btn
        Keybind_Btn = Menu_Sec:Button("Menu Keybind: " .. tostring(Configuration.Keybind.Name), "Change the open/close key", function()
            Keybind_Btn.Text = "Press any key..."
            local Conn
            Conn = User_Input_Service.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.Keyboard then
                    if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Delete then
                        Configuration.Keybind = Enum.KeyCode.LeftControl
                    elseif Input.KeyCode ~= Enum.KeyCode.Escape and Input.KeyCode ~= Enum.KeyCode.Unknown then
                        Configuration.Keybind = Input.KeyCode
                    end
                    Keybind_Btn.Text = "Menu Keybind: " .. tostring(Configuration.Keybind.Name)
                    Library_Api:Notify("Settings", "Menu keybind set to " .. tostring(Configuration.Keybind.Name), 2)
                    Conn:Disconnect()
                end
            end)
        end)
        
        Menu_Sec:Toggle("Show Keybind List", "KeybindListToggle", true, "Show the active keybinds widget", function(State)
            Library_Api.Show_Keybinds = State
            if Library_Api.Keybind_List then
                Library_Api.Keybind_List.Frame.Visible = State and (#Library_Api.Keybind_List.Container:GetChildren() > 1)
            end
        end)
        
        Menu_Sec:ColorPicker("Accent Color", "MenuAccentColor", Menu_Colors.Accent, "Change the theme color", function(Col)
            Library_Api:Update_Theme(Col)
        end)
        
        local Config_Sec = Window_Obj:Create_Raw_Section("Configuration", Set_Page)
        local Config_Content = Config_Sec.Container:FindFirstChild("Content")
        
        local Config_Name_Input = ""
        local Selected_Config_Name = ""
        local Config_List = Library_Api:Get_Configs()
        
        local C_Name_Frame = Instance.new("Frame")
        C_Name_Frame.Size = UDim2.new(1, 0, 0, 50)
        C_Name_Frame.BackgroundTransparency = 1
        C_Name_Frame.LayoutOrder = 1
        C_Name_Frame.Parent = Config_Content
        
        local C_Name_Label = Instance.new("TextLabel")
        C_Name_Label.Text = "Config Name"
        C_Name_Label.Font = Configuration.Font_Main
        C_Name_Label.TextSize = 13
        C_Name_Label.TextColor3 = Menu_Colors.Text
        C_Name_Label.Size = UDim2.new(1, 0, 0, 20)
        C_Name_Label.Position = UDim2.new(0, 5, 0, 0)
        C_Name_Label.TextXAlignment = Enum.TextXAlignment.Left
        C_Name_Label.BackgroundTransparency = 1
        C_Name_Label.Parent = C_Name_Frame
        
        local C_Name_Box_Cont = Instance.new("Frame")
        C_Name_Box_Cont.Size = UDim2.new(1, 0, 0, 28)
        C_Name_Box_Cont.Position = UDim2.new(0, 0, 0, 22)
        C_Name_Box_Cont.BackgroundColor3 = Menu_Colors.Container
        C_Name_Box_Cont.Parent = C_Name_Frame
        Corner_Radius(C_Name_Box_Cont, 4)
        Stroke_Border(C_Name_Box_Cont, Menu_Colors.Stroke, 1, 0.5)
        
        local C_Name_Input = Instance.new("TextBox")
        C_Name_Input.Size = UDim2.new(1, -10, 1, 0)
        C_Name_Input.Position = UDim2.new(0, 5, 0, 0)
        C_Name_Input.BackgroundTransparency = 1
        C_Name_Input.TextColor3 = Menu_Colors.Text
        C_Name_Input.PlaceholderText = "Type config name..."
        C_Name_Input.PlaceholderColor3 = Menu_Colors.Text_Dark
        C_Name_Input.Font = Configuration.Font_Main
        C_Name_Input.TextSize = 13
        C_Name_Input.TextXAlignment = Enum.TextXAlignment.Left
        C_Name_Input.Text = ""
        C_Name_Input.ClearTextOnFocus = false
        C_Name_Input.Parent = C_Name_Box_Cont
        
        local C2 = C_Name_Input:GetPropertyChangedSignal("Text"):Connect(function()
            Config_Name_Input = C_Name_Input.Text
        end)
        table.insert(Library_Api.Connections, C2)
        
        local Config_Dropdown_Frame = Instance.new("Frame")
        Config_Dropdown_Frame.Size = UDim2.new(1, 0, 0, 46)
        Config_Dropdown_Frame.BackgroundTransparency = 1
        Config_Dropdown_Frame.LayoutOrder = 2
        Config_Dropdown_Frame.Parent = Config_Content
        
        local CD_Label = Instance.new("TextLabel")
        CD_Label.Text = "Select Config"
        CD_Label.Font = Configuration.Font_Main
        CD_Label.TextSize = 13
        CD_Label.TextColor3 = Menu_Colors.Text
        CD_Label.Size = UDim2.new(1, 0, 0, 16)
        CD_Label.Position = UDim2.new(0, 5, 0, 0)
        CD_Label.TextXAlignment = Enum.TextXAlignment.Left
        CD_Label.BackgroundTransparency = 1
        CD_Label.Parent = Config_Dropdown_Frame
        
        local CD_Interactive = Instance.new("TextButton")
        CD_Interactive.Size = UDim2.new(1, 0, 0, 26)
        CD_Interactive.Position = UDim2.new(0, 0, 0, 20)
        CD_Interactive.BackgroundColor3 = Menu_Colors.Container
        CD_Interactive.Text = ""
        CD_Interactive.AutoButtonColor = false
        CD_Interactive.Parent = Config_Dropdown_Frame
        CD_Interactive.ZIndex = 5
        Corner_Radius(CD_Interactive, 4)
        Stroke_Border(CD_Interactive, Menu_Colors.Stroke, 1, 0.5)
        
        local CD_Selected_Text = Instance.new("TextLabel")
        CD_Selected_Text.Font = Configuration.Font_Main
        CD_Selected_Text.TextSize = 13
        CD_Selected_Text.TextColor3 = Menu_Colors.Text
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
        CD_Arrow.ImageColor3 = Menu_Colors.Text_Dark
        CD_Arrow.Parent = CD_Interactive
        CD_Arrow.ZIndex = 6
        
        local CD_List_Frame = Instance.new("ScrollingFrame")
        CD_List_Frame.Size = UDim2.new(1, 0, 0, 0)
        CD_List_Frame.Position = UDim2.new(0, 0, 1, 5)
        CD_List_Frame.BackgroundColor3 = Menu_Colors.Container
        CD_List_Frame.BorderSizePixel = 0
        CD_List_Frame.Parent = CD_Interactive
        CD_List_Frame.ZIndex = 10
        CD_List_Frame.Visible = false
        CD_List_Frame.Active = true
        CD_List_Frame.ScrollBarThickness = 2
        CD_List_Frame.ScrollBarImageColor3 = Menu_Colors.Accent
        CD_List_Frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Corner_Radius(CD_List_Frame, 4)
        Stroke_Border(CD_List_Frame, Menu_Colors.Stroke, 1, 0.5)
        
        local CD_I_List = Instance.new("UIListLayout")
        CD_I_List.SortOrder = Enum.SortOrder.LayoutOrder
        CD_I_List.Parent = CD_List_Frame
        
        local CD_Is_Dropped = false
        local CD_Option_Btns = {}
        
        Selected_Config_Name = #Config_List > 0 and Config_List[1] or ""
        CD_Selected_Text.Text = Selected_Config_Name ~= "" and Selected_Config_Name or "No configs"
        
        local function CD_Close_Dropdown()
            CD_Is_Dropped = false
            Config_Sec.Container.ZIndex = 1
            Config_Dropdown_Frame.ZIndex = 5
            Tween_Anim(Config_Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 46)}, 0.2)
            local T = Tween_Anim(CD_List_Frame, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
            Tween_Anim(CD_Arrow, {Rotation = 0}, 0.2)
            local C4
            C4 = T.Completed:Connect(function()
                if not CD_Is_Dropped then CD_List_Frame.Visible = false end
                C4:Disconnect()
            end)
        end
        
        local function CD_Build_Options(Opts)
            for _, Btn in pairs(CD_Option_Btns) do Btn:Destroy() end
            table.clear(CD_Option_Btns)
            for _, Opt in ipairs(Opts) do
                local Opt_Btn = Instance.new("TextButton")
                Opt_Btn.Size = UDim2.new(1, 0, 0, 24)
                Opt_Btn.BackgroundColor3 = Menu_Colors.Container
                Opt_Btn.BackgroundTransparency = 1
                Opt_Btn.Text = Opt
                Opt_Btn.Font = Configuration.Font_Main
                Opt_Btn.TextSize = 12
                Opt_Btn.Parent = CD_List_Frame
                Opt_Btn.ZIndex = 11
                Opt_Btn.TextColor3 = (Selected_Config_Name == Opt) and Menu_Colors.Accent or Menu_Colors.Text_Dark
                
                if Selected_Config_Name == Opt then
                    Opt_Btn.BackgroundTransparency = 0.8
                    Opt_Btn.BackgroundColor3 = Menu_Colors.Element_Hover
                end
                
                CD_Option_Btns[Opt] = Opt_Btn
                local C5 = Opt_Btn.MouseEnter:Connect(function()
                    if Selected_Config_Name ~= Opt then Tween_Anim(Opt_Btn, {BackgroundTransparency = 0, BackgroundColor3 = Menu_Colors.Element_Hover, TextColor3 = Menu_Colors.Accent}) end
                end)
                local C6 = Opt_Btn.MouseLeave:Connect(function()
                    if Selected_Config_Name ~= Opt then Tween_Anim(Opt_Btn, {BackgroundTransparency = 1, BackgroundColor3 = Menu_Colors.Container, TextColor3 = Menu_Colors.Text_Dark}) end
                end)
                local C7 = Opt_Btn.MouseButton1Click:Connect(function()
                    Selected_Config_Name = Opt
                    CD_Selected_Text.Text = Opt
                    for O, B in pairs(CD_Option_Btns) do 
                        B.TextColor3 = (O == Opt) and Menu_Colors.Accent or Menu_Colors.Text_Dark 
                        B.BackgroundTransparency = (O == Opt) and 0.8 or 1
                        B.BackgroundColor3 = (O == Opt) and Menu_Colors.Element_Hover or Menu_Colors.Container
                    end
                    CD_Close_Dropdown()
                end)
                table.insert(Library_Api.Connections, C5)
                table.insert(Library_Api.Connections, C6)
                table.insert(Library_Api.Connections, C7)
            end
        end
        
        CD_Build_Options(Config_List)
        
        local C8 = CD_Interactive.MouseButton1Click:Connect(function()
            CD_Is_Dropped = not CD_Is_Dropped
            Config_Sec.Container.ZIndex = CD_Is_Dropped and 10 or 1
            Config_Dropdown_Frame.ZIndex = CD_Is_Dropped and 10 or 5
            if CD_Is_Dropped then
                CD_List_Frame.Visible = true
                local Current_List = Library_Api:Get_Configs()
                CD_Build_Options(Current_List)
                local List_H = math.min(#Current_List * 24, 200)
                if List_H < 24 then List_H = 24 end
                local Total_H = 46 + List_H + 5
                Tween_Anim(Config_Dropdown_Frame, {Size = UDim2.new(1, 0, 0, Total_H)}, 0.2)
                Tween_Anim(CD_List_Frame, {Size = UDim2.new(1, 0, 0, List_H)}, 0.2)
                Tween_Anim(CD_Arrow, {Rotation = 180}, 0.2)
            else
                CD_Close_Dropdown()
            end
        end)
        table.insert(Library_Api.Connections, C8)
        
        local function Refresh_Config_Dropdown()
            local New_List = Library_Api:Get_Configs()
            Config_List = New_List
            if not table.find(New_List, Selected_Config_Name) then
                Selected_Config_Name = #New_List > 0 and New_List[1] or ""
            end
            CD_Selected_Text.Text = Selected_Config_Name ~= "" and Selected_Config_Name or "No configs"
            CD_Build_Options(New_List)
        end
        
        local Create_Btn = Instance.new("TextButton")
        Create_Btn.Size = UDim2.new(1, 0, 0, 32)
        Create_Btn.BackgroundColor3 = Menu_Colors.Container
        Create_Btn.Text = "Create New Config"
        Create_Btn.Font = Configuration.Font_Main
        Create_Btn.TextSize = 13
        Create_Btn.TextColor3 = Menu_Colors.Text
        Create_Btn.AutoButtonColor = false
        Create_Btn.LayoutOrder = 3
        Create_Btn.Parent = Config_Content
        Corner_Radius(Create_Btn, 4)
        local Cs1 = Stroke_Border(Create_Btn, Menu_Colors.Stroke, 1, 0.5)
        local C9 = Create_Btn.MouseEnter:Connect(function() Tween_Anim(Create_Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(Cs1, {Color = Menu_Colors.Accent}) end)
        local C10 = Create_Btn.MouseLeave:Connect(function() Tween_Anim(Create_Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(Cs1, {Color = Menu_Colors.Stroke}) end)
        local C11 = Create_Btn.MouseButton1Click:Connect(function()
            local Name = Config_Name_Input
            if not Name or Name == "" or string.match(Name, "^%s*$") then
                Library_Api:Notify("Error", "Please type a config name first", 3)
                return
            end
            Name = string.gsub(Name, "^%s+", "")
            Name = string.gsub(Name, "%s+$", "")
            if Name == "" then
                Library_Api:Notify("Error", "Please type a config name first", 3)
                return
            end
            if Library_Api:Config_Exists(Name) then
                Library_Api:Notify("Error", "Config '" .. Name .. "' already exists", 3)
                return
            end
            if Library_Api:Save_Config(Name) then
                Selected_Config_Name = Name
                C_Name_Input.Text = ""
                Config_Name_Input = ""
                Refresh_Config_Dropdown()
                Library_Api:Notify("Config", "Created: " .. Name, 3)
            else
                Library_Api:Notify("Error", "Failed to create config", 3)
            end
        end)
        table.insert(Library_Api.Connections, C9)
        table.insert(Library_Api.Connections, C10)
        table.insert(Library_Api.Connections, C11)
        
        local Load_Btn = Instance.new("TextButton")
        Load_Btn.Size = UDim2.new(1, 0, 0, 32)
        Load_Btn.BackgroundColor3 = Menu_Colors.Container
        Load_Btn.Text = "Load Config"
        Load_Btn.Font = Configuration.Font_Main
        Load_Btn.TextSize = 13
        Load_Btn.TextColor3 = Menu_Colors.Text
        Load_Btn.AutoButtonColor = false
        Load_Btn.LayoutOrder = 4
        Load_Btn.Parent = Config_Content
        Corner_Radius(Load_Btn, 4)
        local Cs2 = Stroke_Border(Load_Btn, Menu_Colors.Stroke, 1, 0.5)
        local C12 = Load_Btn.MouseEnter:Connect(function() Tween_Anim(Load_Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(Cs2, {Color = Menu_Colors.Accent}) end)
        local C13 = Load_Btn.MouseLeave:Connect(function() Tween_Anim(Load_Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(Cs2, {Color = Menu_Colors.Stroke}) end)
        local C14 = Load_Btn.MouseButton1Click:Connect(function()
            local Name = Selected_Config_Name
            if not Name or Name == "" then
                Library_Api:Notify("Error", "No config selected", 3)
                return
            end
            if not Library_Api:Config_Exists(Name) then
                Library_Api:Notify("Error", "Config '" .. Name .. "' does not exist", 3)
                return
            end
            if Library_Api:Load_Config(Name) then
                Library_Api:Notify("Config", "Loaded: " .. Name, 3)
            else
                Library_Api:Notify("Error", "Failed to load config", 3)
            end
        end)
        table.insert(Library_Api.Connections, C12)
        table.insert(Library_Api.Connections, C13)
        table.insert(Library_Api.Connections, C14)
        
        local Rewrite_Btn = Instance.new("TextButton")
        Rewrite_Btn.Size = UDim2.new(1, 0, 0, 32)
        Rewrite_Btn.BackgroundColor3 = Menu_Colors.Container
        Rewrite_Btn.Text = "Rewrite Config"
        Rewrite_Btn.Font = Configuration.Font_Main
        Rewrite_Btn.TextSize = 13
        Rewrite_Btn.TextColor3 = Menu_Colors.Text
        Rewrite_Btn.AutoButtonColor = false
        Rewrite_Btn.LayoutOrder = 5
        Rewrite_Btn.Parent = Config_Content
        Corner_Radius(Rewrite_Btn, 4)
        local Cs3 = Stroke_Border(Rewrite_Btn, Menu_Colors.Stroke, 1, 0.5)
        local C15 = Rewrite_Btn.MouseEnter:Connect(function() Tween_Anim(Rewrite_Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(Cs3, {Color = Menu_Colors.Accent}) end)
        local C16 = Rewrite_Btn.MouseLeave:Connect(function() Tween_Anim(Rewrite_Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(Cs3, {Color = Menu_Colors.Stroke}) end)
        local C17 = Rewrite_Btn.MouseButton1Click:Connect(function()
            local Name = Selected_Config_Name
            if not Name or Name == "" then
                Library_Api:Notify("Error", "No config selected", 3)
                return
            end
            if not Library_Api:Config_Exists(Name) then
                Library_Api:Notify("Error", "Config '" .. Name .. "' does not exist", 3)
                return
            end
            if Library_Api:Save_Config(Name) then
                Library_Api:Notify("Config", "Rewritten: " .. Name, 3)
            else
                Library_Api:Notify("Error", "Failed to rewrite config", 3)
            end
        end)
        table.insert(Library_Api.Connections, C15)
        table.insert(Library_Api.Connections, C16)
        table.insert(Library_Api.Connections, C17)
        
        local Delete_Btn = Instance.new("TextButton")
        Delete_Btn.Size = UDim2.new(1, 0, 0, 32)
        Delete_Btn.BackgroundColor3 = Menu_Colors.Container
        Delete_Btn.Text = "Delete Config"
        Delete_Btn.Font = Configuration.Font_Main
        Delete_Btn.TextSize = 13
        Delete_Btn.TextColor3 = Menu_Colors.Text
        Delete_Btn.AutoButtonColor = false
        Delete_Btn.LayoutOrder = 6
        Delete_Btn.Parent = Config_Content
        Corner_Radius(Delete_Btn, 4)
        local Cs4 = Stroke_Border(Delete_Btn, Menu_Colors.Stroke, 1, 0.5)
        local C18 = Delete_Btn.MouseEnter:Connect(function() Tween_Anim(Delete_Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(Cs4, {Color = Menu_Colors.Accent}) end)
        local C19 = Delete_Btn.MouseLeave:Connect(function() Tween_Anim(Delete_Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(Cs4, {Color = Menu_Colors.Stroke}) end)
        local C20 = Delete_Btn.MouseButton1Click:Connect(function()
            local Name = Selected_Config_Name
            if not Name or Name == "" then
                Library_Api:Notify("Error", "No config selected", 3)
                return
            end
            if not Library_Api:Config_Exists(Name) then
                Library_Api:Notify("Error", "Config '" .. Name .. "' does not exist", 3)
                return
            end
            if Library_Api:Delete_Config(Name) then
                Refresh_Config_Dropdown()
                Library_Api:Notify("Config", "Deleted: " .. Name, 3)
            else
                Library_Api:Notify("Error", "Failed to delete config", 3)
            end
        end)
        table.insert(Library_Api.Connections, C18)
        table.insert(Library_Api.Connections, C19)
        table.insert(Library_Api.Connections, C20)
        
        local Refresh_Btn = Instance.new("TextButton")
        Refresh_Btn.Size = UDim2.new(1, 0, 0, 32)
        Refresh_Btn.BackgroundColor3 = Menu_Colors.Container
        Refresh_Btn.Text = "Refresh Config List"
        Refresh_Btn.Font = Configuration.Font_Main
        Refresh_Btn.TextSize = 13
        Refresh_Btn.TextColor3 = Menu_Colors.Text
        Refresh_Btn.AutoButtonColor = false
        Refresh_Btn.LayoutOrder = 7
        Refresh_Btn.Parent = Config_Content
        Corner_Radius(Refresh_Btn, 4)
        local Cs5 = Stroke_Border(Refresh_Btn, Menu_Colors.Stroke, 1, 0.5)
        local C21 = Refresh_Btn.MouseEnter:Connect(function() Tween_Anim(Refresh_Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(Cs5, {Color = Menu_Colors.Accent}) end)
        local C22 = Refresh_Btn.MouseLeave:Connect(function() Tween_Anim(Refresh_Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(Cs5, {Color = Menu_Colors.Stroke}) end)
        local C23 = Refresh_Btn.MouseButton1Click:Connect(function()
            Refresh_Config_Dropdown()
            Library_Api:Notify("Config", "List Refreshed", 2)
        end)
        table.insert(Library_Api.Connections, C21)
        table.insert(Library_Api.Connections, C22)
        table.insert(Library_Api.Connections, C23)
        
        local Reset_Btn = Instance.new("TextButton")
        Reset_Btn.Size = UDim2.new(1, 0, 0, 32)
        Reset_Btn.BackgroundColor3 = Menu_Colors.Container
        Reset_Btn.Text = "Reset to Defaults"
        Reset_Btn.Font = Configuration.Font_Main
        Reset_Btn.TextSize = 13
        Reset_Btn.TextColor3 = Menu_Colors.Text
        Reset_Btn.AutoButtonColor = false
        Reset_Btn.LayoutOrder = 8
        Reset_Btn.Parent = Config_Content
        Corner_Radius(Reset_Btn, 4)
        local Cs6 = Stroke_Border(Reset_Btn, Menu_Colors.Stroke, 1, 0.5)
        local C24 = Reset_Btn.MouseEnter:Connect(function() Tween_Anim(Reset_Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(Cs6, {Color = Menu_Colors.Accent}) end)
        local C25 = Reset_Btn.MouseLeave:Connect(function() Tween_Anim(Reset_Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(Cs6, {Color = Menu_Colors.Stroke}) end)
        local C26 = Reset_Btn.MouseButton1Click:Connect(function()
            for Flag, Val in pairs(Library_Api.Defaults) do
                if Ignored_Flags[Flag] then continue end
                Library_Api.Flags[Flag] = Val
                if Library_Api.Signals[Flag] then
                    task.spawn(Library_Api.Signals[Flag], Val)
                end
            end
            Library_Api:Notify("Settings", "Reset to defaults", 3)
        end)
        table.insert(Library_Api.Connections, C24)
        table.insert(Library_Api.Connections, C25)
        table.insert(Library_Api.Connections, C26)
    end
    
    Populate_Settings()
    
    function Window_Obj:Tab(Name, Icon_Id)
        local Tab = {}
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 0
        Page.Visible = false
        Page.Active = true
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        Page.Parent = Main_Pages
        
        local Tab_Btn = Instance.new("TextButton")
        Tab_Btn.Size = UDim2.new(1, 0, 0, 36)
        Tab_Btn.BackgroundColor3 = Menu_Colors.Background
        Tab_Btn.BackgroundTransparency = 1
        Tab_Btn.Text = ""
        Tab_Btn.AutoButtonColor = false
        Tab_Btn.Parent = Tab_Container
        Corner_Radius(Tab_Btn, 6)
        
        local Title = Instance.new("TextLabel")
        Title.Text = Name
        Title.Font = Configuration.Font_Main
        Title.TextSize = 14
        Title.TextColor3 = Menu_Colors.Text_Dark
        Title.Size = UDim2.new(1, -20, 1, 0)
        Title.Position = UDim2.new(0, Icon_Id and 35 or 15, 0, 0)
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.BackgroundTransparency = 1
        Title.Parent = Tab_Btn
        
        if Icon_Id then
            local Ico = Instance.new("ImageLabel")
            Ico.Size = UDim2.new(0, 20, 0, 20)
            Ico.Position = UDim2.new(0, 8, 0.5, 0)
            Ico.AnchorPoint = Vector2.new(0, 0.5)
            Ico.BackgroundTransparency = 1
            if tonumber(Icon_Id) then Ico.Image = "rbxassetid://" .. Icon_Id else Ico.Image = Icon_Id end
            Ico.ImageColor3 = Menu_Colors.Text_Dark
            Ico.Parent = Tab_Btn
            local C1 = Tab_Btn.MouseEnter:Connect(function() if Tab_Btn.BackgroundTransparency > 0.5 then Tween_Anim(Ico, {ImageColor3 = Menu_Colors.Text}) end end)
            local C2 = Tab_Btn.MouseLeave:Connect(function() if Tab_Btn.BackgroundTransparency > 0.5 then Tween_Anim(Ico, {ImageColor3 = Menu_Colors.Text_Dark}) end end)
            table.insert(Library_Api.Connections, C1)
            table.insert(Library_Api.Connections, C2)
        end
        
        local Indicator = Instance.new("Frame")
        Indicator.Size = UDim2.new(0, 3, 0, 16)
        Indicator.Position = UDim2.new(0, 0, 0.5, -8)
        Indicator.BackgroundColor3 = Menu_Colors.Accent
        Indicator.BackgroundTransparency = 1
        Indicator.BorderSizePixel = 0
        Indicator.Parent = Tab_Btn
        Corner_Radius(Indicator, 2)
        Register_Theme(Indicator, "BackgroundColor")
        
        local C3 = Tab_Btn.MouseButton1Click:Connect(function()
            for _, P in pairs(Main_Pages:GetChildren()) do if P:IsA("ScrollingFrame") then P.Visible = false end end
            for _, T in pairs(Tab_Container:GetChildren()) do
                if T:IsA("TextButton") then
                    Tween_Anim(T.TextLabel, {TextColor3 = Menu_Colors.Text_Dark})
                    Tween_Anim(T, {BackgroundTransparency = 1, BackgroundColor3 = Menu_Colors.Background})
                    if T:FindFirstChild("ImageLabel") then Tween_Anim(T.ImageLabel, {ImageColor3 = Menu_Colors.Text_Dark}) end
                    if T:FindFirstChild("Frame") then Tween_Anim(T.Frame, {BackgroundTransparency = 1}) end
                end
            end
            Page.Visible = true
            Tween_Anim(Title, {TextColor3 = Menu_Colors.Text})
            Tween_Anim(Tab_Btn, {BackgroundTransparency = 0.95, BackgroundColor3 = Menu_Colors.Text})
            if Tab_Btn:FindFirstChild("ImageLabel") then Tween_Anim(Tab_Btn.ImageLabel, {ImageColor3 = Menu_Colors.Text}) end
            Tween_Anim(Indicator, {BackgroundTransparency = 0})
        end)
        table.insert(Library_Api.Connections, C3)
        
        local Tab_Count = 0
        for _, C in pairs(Tab_Container:GetChildren()) do
            if C:IsA("TextButton") then Tab_Count = Tab_Count + 1 end
        end
        if Tab_Count <= 1 then
            Page.Visible = true
            Title.TextColor3 = Menu_Colors.Text
            Tab_Btn.BackgroundTransparency = 0.95
            Tab_Btn.BackgroundColor3 = Menu_Colors.Text
            if Tab_Btn:FindFirstChild("ImageLabel") then Tab_Btn.ImageLabel.ImageColor3 = Menu_Colors.Text end
            Indicator.BackgroundTransparency = 0
        end
        
        local Left_Col = Instance.new("Frame")
        Left_Col.Size = UDim2.new(0.5, -5, 0, 0)
        Left_Col.Position = UDim2.new(0, 0, 0, 0)
        Left_Col.BackgroundTransparency = 1
        Left_Col.AutomaticSize = Enum.AutomaticSize.Y
        Left_Col.Parent = Page
        local Left_List = Instance.new("UIListLayout")
        Left_List.SortOrder = Enum.SortOrder.LayoutOrder
        Left_List.Padding = UDim.new(0, 10)
        Left_List.Parent = Left_Col
        
        local Right_Col = Instance.new("Frame")
        Right_Col.Size = UDim2.new(0.5, -5, 0, 0)
        Right_Col.Position = UDim2.new(0.5, 5, 0, 0)
        Right_Col.BackgroundTransparency = 1
        Right_Col.AutomaticSize = Enum.AutomaticSize.Y
        Right_Col.Parent = Page
        local Right_List = Instance.new("UIListLayout")
        Right_List.SortOrder = Enum.SortOrder.LayoutOrder
        Right_List.Padding = UDim.new(0, 10)
        Right_List.Parent = Right_Col
        
        function Tab:Section(Text, Side)
            local Section = {}
            local Parent_Col = (Side == "Right" and Right_Col or Left_Col)
            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, 0)
            Container.BackgroundColor3 = Menu_Colors.Section
            Container.Parent = Parent_Col
            Container.ZIndex = 1
            Corner_Radius(Container, 6)
            Stroke_Border(Container, Menu_Colors.Stroke, 1, 0.5)
            Section.Container = Container
            local Sec_Data = {Instance = Container, Items = {}}
            table.insert(Library_Api.Elements, Sec_Data)
            
            local S_Title = Instance.new("TextLabel")
            S_Title.Text = Text
            S_Title.Font = Configuration.Font_Bold
            S_Title.TextSize = 12
            S_Title.TextColor3 = Menu_Colors.Text_Dark
            S_Title.Size = UDim2.new(1, -20, 0, 25)
            S_Title.Position = UDim2.new(0, 10, 0, 0)
            S_Title.BackgroundTransparency = 1
            S_Title.TextXAlignment = Enum.TextXAlignment.Left
            S_Title.Parent = Container
            
            local Content = Instance.new("Frame")
            Content.Size = UDim2.new(1, -10, 0, 0)
            Content.Position = UDim2.new(0, 5, 0, 25)
            Content.BackgroundTransparency = 1
            Content.Parent = Container
            local List = Instance.new("UIListLayout")
            List.Padding = UDim.new(0, 6)
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Parent = Content
            
            local function Update_Size()
                Container.Size = UDim2.new(1, 0, 0, List.AbsoluteContentSize.Y + 35)
                Page.CanvasSize = UDim2.new(0, 0, 0, math.max(Left_List.AbsoluteContentSize.Y, Right_List.AbsoluteContentSize.Y) + 20)
            end
            local C4 = List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Size)
            table.insert(Library_Api.Connections, C4)
            
            function Section:Label(L_Text, Options)
                Options = Options or {}
                local Label_Obj = {}
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 26)
                Frame.BackgroundColor3 = Menu_Colors.Container
                Frame.BackgroundTransparency = 0.5
                Frame.Parent = Content
                table.insert(Sec_Data.Items, {Name = L_Text, Instance = Frame})
                Corner_Radius(Frame, 4)
                Stroke_Border(Frame, Menu_Colors.Stroke, 1, 0.5)
                
                local Lbl = Instance.new("TextLabel")
                Lbl.Size = UDim2.new(1, -10, 1, -10)
                Lbl.Position = UDim2.new(0, 5, 0, 5)
                Lbl.BackgroundTransparency = 1
                Lbl.Text = tostring(L_Text)
                Lbl.Font = Configuration.Font_Main
                Lbl.TextSize = 13
                Lbl.TextColor3 = Options.Color or Menu_Colors.Text
                Lbl.TextXAlignment = Options.Alignment or Enum.TextXAlignment.Left
                Lbl.TextYAlignment = Enum.TextYAlignment.Top
                Lbl.RichText = true
                Lbl.TextWrapped = true
                Lbl.Parent = Frame
                
                local function Update_Height()
                    local Text_Height = Lbl.TextBounds.Y
                    if Text_Height > 16 then Frame.Size = UDim2.new(1, 0, 0, Text_Height + 10) else Frame.Size = UDim2.new(1, 0, 0, 26) end
                end
                local Bounds_Conn = Lbl:GetPropertyChangedSignal("TextBounds"):Connect(Update_Height)
                table.insert(Library_Api.Connections, Bounds_Conn)
                Update_Height()
                function Label_Obj:Set(New_Text) Lbl.Text = tostring(New_Text) end
                function Label_Obj:Set_Color(New_Color) Lbl.TextColor3 = New_Color end
                return Label_Obj
            end
            
            function Section:Toggle(Text_Val, Flag, Default, Tooltip_Text, Callback)
                Library_Api.Defaults[Flag] = Default or false
                local Toggled = Library_Api.Flags[Flag]
                if Toggled == nil then
                    Toggled = Default or false
                    Library_Api.Flags[Flag] = Toggled
                end
                local Toggle_Obj = {}
                Library_Api.Signals[Flag] = function(Val)
                    if Toggled ~= Val then
                        Toggled = Val
                        if Toggle_Obj.Update_Anim then Toggle_Obj.Update_Anim() end
                        Library_Api.Unsaved = true
                        Callback(Val)
                    end
                end
                
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 32)
                Btn.BackgroundColor3 = Menu_Colors.Container
                Btn.Text = ""
                Btn.AutoButtonColor = false
                Btn.Parent = Content
                table.insert(Sec_Data.Items, {Name = Text_Val, Instance = Btn})
                Corner_Radius(Btn, 4)
                Stroke_Border(Btn, Menu_Colors.Stroke, 1, 0.5)
                
                local Label = Instance.new("TextLabel")
                Label.Text = Text_Val
                Label.Font = Configuration.Font_Main
                Label.TextSize = 13
                Label.TextColor3 = Menu_Colors.Text
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Position = UDim2.new(0, 10, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Btn
                
                local Box = Instance.new("Frame")
                Box.Size = UDim2.new(0, 18, 0, 18)
                Box.Position = UDim2.new(1, -10, 0.5, 0)
                Box.AnchorPoint = Vector2.new(1, 0.5)
                Box.BackgroundColor3 = Menu_Colors.Background
                Box.Parent = Btn
                Corner_Radius(Box, 4)
                Stroke_Border(Box, Menu_Colors.Stroke, 1, 0.5)
                
                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new(1, -4, 1, -4)
                Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
                Fill.AnchorPoint = Vector2.new(0.5, 0.5)
                Fill.BackgroundColor3 = Menu_Colors.Accent
                Fill.BackgroundTransparency = Toggled and 0 or 1
                Fill.Parent = Box
                Corner_Radius(Fill, 3)
                Register_Theme(Fill, "BackgroundColor")
                
                local Sub_Container = Instance.new("Frame")
                Sub_Container.Name = "Sub_" .. Text_Val
                Sub_Container.Size = UDim2.new(1, 0, 0, 0)
                Sub_Container.BackgroundTransparency = 1
                Sub_Container.ClipsDescendants = true
                Sub_Container.Visible = false
                Sub_Container.Parent = Content
                local Sub_List = Instance.new("UIListLayout")
                Sub_List.Padding = UDim.new(0, 6)
                Sub_List.SortOrder = Enum.SortOrder.LayoutOrder
                Sub_List.Parent = Sub_Container
                
                local Current_Tween = nil
                local function Toggle_Anim()
                    if Current_Tween then Current_Tween:Cancel() end
                    Tween_Anim(Fill, {BackgroundTransparency = Toggled and 0 or 1}, 0.2)
                    Library_Api.Flags[Flag] = Toggled
                    if Toggle_Obj.Keybind_Value then
                        Library_Api:Update_Keybind_List(Text_Val, Toggle_Obj.Keybind_Value.Name, Toggled, Toggle_Obj.Keybind_Mode)
                    end
                    if Toggled then
                        Sub_Container.Visible = true
                        Sub_Container.ClipsDescendants = true
                        local H = Sub_List.AbsoluteContentSize.Y
                        if H > 0 then H = H + 6 end
                        Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, H)})
                        Current_Tween:Play()
                        local Tc
                        Tc = Current_Tween.Completed:Connect(function(State)
                            if State == Enum.PlaybackState.Completed and Toggled then Sub_Container.ClipsDescendants = false end
                            Tc:Disconnect()
                        end)
                    else
                        Sub_Container.ClipsDescendants = true
                        Current_Tween = Tween_Service:Create(Sub_Container, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 0)})
                        Current_Tween:Play()
                        local Expected_Toggle = Toggled
                        local Tc
                        Tc = Current_Tween.Completed:Connect(function(Playback_State)
                            if Playback_State == Enum.PlaybackState.Completed and Expected_Toggle == Toggled and not Toggled then Sub_Container.Visible = false end
                            Tc:Disconnect()
                        end)
                    end
                end
                Toggle_Obj.Update_Anim = Toggle_Anim
                
                local C5 = Sub_List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Toggled then
                        local H = Sub_List.AbsoluteContentSize.Y
                        if H > 0 then H = H + 6 end
                        Sub_Container.Size = UDim2.new(1, 0, 0, H)
                    end
                end)
                table.insert(Library_Api.Connections, C5)
                
                local C6 = Btn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Library_Api.Unsaved = true
                    Toggle_Anim()
                    Callback(Toggled)
                end)
                table.insert(Library_Api.Connections, C6)
                if Toggled then Toggle_Anim() end
                Apply_Tooltip(Btn, Tooltip_Text)
                task.spawn(Callback, Toggled)
                
                function Toggle_Obj:AddButton(Txt, Cb)
                    local S_Btn = Instance.new("TextButton")
                    S_Btn.Size = UDim2.new(1, -20, 0, 26)
                    S_Btn.Position = UDim2.new(0, 20, 0, 0)
                    S_Btn.BackgroundColor3 = Menu_Colors.Container
                    S_Btn.Text = Txt
                    S_Btn.Font = Configuration.Font_Main
                    S_Btn.TextSize = 12
                    S_Btn.TextColor3 = Menu_Colors.Text
                    S_Btn.AutoButtonColor = false
                    S_Btn.Parent = Sub_Container
                    Corner_Radius(S_Btn, 4)
                    local S = Stroke_Border(S_Btn, Menu_Colors.Stroke, 1, 0.5)
                    local Tbc1 = S_Btn.MouseEnter:Connect(function() Tween_Anim(S_Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(S, {Color = Menu_Colors.Accent}) end)
                    local Tbc2 = S_Btn.MouseLeave:Connect(function() Tween_Anim(S_Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(S, {Color = Menu_Colors.Stroke}) end)
                    local Tbc3 = S_Btn.MouseButton1Click:Connect(Cb)
                    table.insert(Library_Api.Connections, Tbc1)
                    table.insert(Library_Api.Connections, Tbc2)
                    table.insert(Library_Api.Connections, Tbc3)
                end
                
                function Toggle_Obj:AddSlider(Txt, S_Flag, Min, Max, Def, Cb, Inc)
                    Inc = Inc or 1
                    local Val = Library_Api.Flags[S_Flag]
                    if Val == nil then Val = Def or Min end
                    Val = Round_To_Increment(Val, Inc)
                    Library_Api.Defaults[S_Flag] = Val
                    Library_Api.Flags[S_Flag] = Val
                    local Range = Max - Min
                    local S_Frame = Instance.new("Frame")
                    S_Frame.Size = UDim2.new(1, -20, 0, 36)
                    S_Frame.Position = UDim2.new(0, 20, 0, 0)
                    S_Frame.BackgroundTransparency = 1
                    S_Frame.Parent = Sub_Container
                    local S_Label = Instance.new("TextLabel")
                    S_Label.Text = Txt
                    S_Label.Font = Configuration.Font_Main
                    S_Label.TextSize = 12
                    S_Label.TextColor3 = Menu_Colors.Text_Dark
                    S_Label.Size = UDim2.new(1, 0, 0, 16)
                    S_Label.TextXAlignment = Enum.TextXAlignment.Left
                    S_Label.BackgroundTransparency = 1
                    S_Label.Parent = S_Frame
                    local S_Value = Instance.new("TextBox")
                    S_Value.Text = Format_Number(Val, Inc)
                    S_Value.Font = Configuration.Font_Main
                    S_Value.TextSize = 12
                    S_Value.TextColor3 = Menu_Colors.Text
                    S_Value.Size = UDim2.new(1, 0, 0, 16)
                    S_Value.TextXAlignment = Enum.TextXAlignment.Right
                    S_Value.BackgroundTransparency = 1
                    S_Value.ClearTextOnFocus = true
                    S_Value.Parent = S_Frame
                    local Slide_Bg = Instance.new("Frame")
                    Slide_Bg.Size = UDim2.new(1, 0, 0, 6)
                    Slide_Bg.Position = UDim2.new(0, 0, 0, 22)
                    Slide_Bg.BackgroundColor3 = Menu_Colors.Background
                    Slide_Bg.Parent = S_Frame
                    Corner_Radius(Slide_Bg, 3)
                    local Slide_Fill = Instance.new("Frame")
                    local Ratio = Range > 0 and (Val - Min) / Range or 0
                    Slide_Fill.Size = UDim2.new(Ratio, 0, 1, 0)
                    Slide_Fill.BackgroundColor3 = Menu_Colors.Accent
                    Slide_Fill.BorderSizePixel = 0
                    Slide_Fill.Parent = Slide_Bg
                    Corner_Radius(Slide_Fill, 3)
                    Register_Theme(Slide_Fill, "BackgroundColor")
                    
                    local Dragging = false
                    local Drag_Input
                    local function Set(Input)
                        local R = math.clamp((Input.Position.X - Slide_Bg.AbsolutePosition.X) / Slide_Bg.AbsoluteSize.X, 0, 1)
                        local Raw = Min + (Max - Min) * R
                        Val = Round_To_Increment(Raw, Inc)
                        Val = math.clamp(Val, Min, Max)
                        local Display_Ratio = Range > 0 and (Val - Min) / Range or 0
                        S_Value.Text = Format_Number(Val, Inc)
                        Tween_Anim(Slide_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                        Library_Api.Flags[S_Flag] = Val
                        Library_Api.Unsaved = true
                        Cb(Val)
                    end
                    
                    local Ts1 = Slide_Bg.InputBegan:Connect(function(I)
                        if I.UserInputType == Enum.UserInputType.MouseButton1 or I.UserInputType == Enum.UserInputType.Touch then
                            Dragging = true
                            Drag_Input = I
                            Set(I)
                            local Tsc
                            Tsc = I.Changed:Connect(function()
                                if I.UserInputState == Enum.UserInputState.End then
                                    Dragging = false
                                    Tsc:Disconnect()
                                end
                            end)
                        end
                    end)
                    local Ts2 = User_Input_Service.InputChanged:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                            if Dragging then Drag_Input = Input end
                        end
                    end)
                    local Ts3 = Run_Service.RenderStepped:Connect(function()
                        if Dragging and Drag_Input then Set(Drag_Input) end
                    end)
                    table.insert(Library_Api.Connections, Ts1)
                    table.insert(Library_Api.Connections, Ts2)
                    table.insert(Library_Api.Connections, Ts3)
                    
                    local Ts4 = S_Value.FocusLost:Connect(function(Enter)
                        if Enter then
                            local Clean_Text = string.gsub(S_Value.Text, "[^%d.-]", "")
                            local Num = tonumber(Clean_Text)
                            if Num then
                                Num = Round_To_Increment(Num, Inc)
                                Num = math.clamp(Num, Min, Max)
                                Val = Num
                                local Display_Ratio = Range > 0 and (Val - Min) / Range or 0
                                S_Value.Text = Format_Number(Val, Inc)
                                Tween_Anim(Slide_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                                Library_Api.Flags[S_Flag] = Val
                                Library_Api.Unsaved = true
                                Cb(Val)
                            else
                                S_Value.Text = Format_Number(Val, Inc)
                            end
                        else
                            S_Value.Text = Format_Number(Val, Inc)
                        end
                    end)
                    table.insert(Library_Api.Connections, Ts4)
                    
                    Library_Api.Signals[S_Flag] = function(Loaded_Val)
                        Val = Round_To_Increment(Loaded_Val, Inc)
                        Val = math.clamp(Val, Min, Max)
                        local Display_Ratio = Range > 0 and (Val - Min) / Range or 0
                        S_Value.Text = Format_Number(Val, Inc)
                        Tween_Anim(Slide_Fill, {Size = UDim2.new(Display_Ratio, 0, 1, 0)}, 0.05)
                        Library_Api.Unsaved = true
                        Cb(Val)
                    end
                    task.spawn(Cb, Val)
                end
                
                function Toggle_Obj:AddDropdown(Txt, D_Flag, Opts, Def, Cb, Is_Multi)
                    Create_Dropdown_Element(Txt, D_Flag, Opts, Def, nil, Cb, Content, Section, Is_Multi, Sub_Container)
                end
                
                function Toggle_Obj:Keybind(Default_Key, Mode)
                    Toggle_Obj.Keybind_Value = Default_Key or Enum.KeyCode.Unknown
                    Toggle_Obj.Keybind_Mode = Mode or "Toggle"
                    local Key_Btn = Instance.new("TextButton")
                    Key_Btn.Size = UDim2.new(0, 60, 0, 18)
                    Key_Btn.Position = UDim2.new(1, -30, 0.5, 0)
                    Key_Btn.AnchorPoint = Vector2.new(1, 0.5)
                    Key_Btn.BackgroundTransparency = 1
                    Key_Btn.Text = "[" .. (Toggle_Obj.Keybind_Value.Name) .. "]"
                    Key_Btn.TextColor3 = Menu_Colors.Text_Dark
                    Key_Btn.Font = Configuration.Font_Main
                    Key_Btn.TextSize = 11
                    Key_Btn.TextXAlignment = Enum.TextXAlignment.Right
                    Key_Btn.Parent = Btn
                    
                    local Binding = false
                    local Kb1 = Key_Btn.MouseButton1Click:Connect(function()
                        if Binding then return end
                        Binding = true
                        Key_Btn.Text = "[...]"
                        Key_Btn.TextColor3 = Menu_Colors.Accent
                        local Conn
                        Conn = User_Input_Service.InputBegan:Connect(function(Input)
                            if Input.UserInputType == Enum.UserInputType.Keyboard then
                                if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Delete then 
                                    Toggle_Obj.Keybind_Value = Enum.KeyCode.Unknown
                                elseif Input.KeyCode ~= Enum.KeyCode.Escape and Input.KeyCode ~= Enum.KeyCode.Unknown then 
                                    Toggle_Obj.Keybind_Value = Input.KeyCode 
                                end
                                Key_Btn.Text = "[" .. (Toggle_Obj.Keybind_Value.Name) .. "]"
                                Key_Btn.TextColor3 = Menu_Colors.Text_Dark
                                Binding = false
                                Library_Api.Unsaved = true
                                Conn:Disconnect()
                                if Toggled then Library_Api:Update_Keybind_List(Text_Val, Toggle_Obj.Keybind_Value.Name, Toggled, Toggle_Obj.Keybind_Mode) end
                            end
                        end)
                    end)
                    table.insert(Library_Api.Connections, Kb1)
                    
                    local Mode_Gui = Instance.new("Frame")
                    Mode_Gui.Size = UDim2.new(0, 80, 0, 60)
                    Mode_Gui.BackgroundColor3 = Menu_Colors.Sidebar
                    Mode_Gui.Visible = false
                    Mode_Gui.ZIndex = 100
                    Mode_Gui.Parent = Btn
                    Corner_Radius(Mode_Gui, 4)
                    Stroke_Border(Mode_Gui, Menu_Colors.Stroke, 1)
                    
                    local Mode_List = Instance.new("UIListLayout")
                    Mode_List.Parent = Mode_Gui
                    local Modes = {"Toggle", "Hold", "Always"}
                    for _, Md in ipairs(Modes) do
                        local M_Btn = Instance.new("TextButton")
                        M_Btn.Size = UDim2.new(1, 0, 0, 20)
                        M_Btn.BackgroundTransparency = 1
                        M_Btn.Text = Md
                        M_Btn.TextColor3 = Menu_Colors.Text_Dark
                        M_Btn.Font = Configuration.Font_Main
                        M_Btn.TextSize = 11
                        M_Btn.Parent = Mode_Gui
                        M_Btn.ZIndex = 101
                        local Mb1 = M_Btn.MouseButton1Click:Connect(function()
                            Toggle_Obj.Keybind_Mode = Md
                            Mode_Gui.Visible = false
                            Library_Api.Unsaved = true
                            if Md == "Always" and not Toggled then
                                Toggled = true
                                Toggle_Anim()
                                Callback(Toggled)
                            end
                            if Toggled then Library_Api:Update_Keybind_List(Text_Val, Toggle_Obj.Keybind_Value.Name, Toggled, Md) end
                        end)
                        table.insert(Library_Api.Connections, Mb1)
                    end
                    
                    local Kb2 = Key_Btn.MouseButton2Click:Connect(function()
                        Mode_Gui.Position = UDim2.new(1, -110, 0, 20)
                        Mode_Gui.Visible = not Mode_Gui.Visible
                        if Mode_Gui.Visible then Sub_Container.ClipsDescendants = false end
                    end)
                    table.insert(Library_Api.Connections, Kb2)
                    
                    if Toggle_Obj.Bind_Connection then Toggle_Obj.Bind_Connection:Disconnect() end
                    if Toggle_Obj.Bind_Connection_Ended then Toggle_Obj.Bind_Connection_Ended:Disconnect() end
                    
                    Toggle_Obj.Bind_Connection = User_Input_Service.InputBegan:Connect(function(Input, Gp)
                        if not Gp and Input.KeyCode == Toggle_Obj.Keybind_Value and Toggle_Obj.Keybind_Value ~= Enum.KeyCode.Unknown then
                            if Toggle_Obj.Keybind_Mode == "Toggle" then
                                Toggled = not Toggled
                                Toggle_Anim()
                                Callback(Toggled)
                            elseif Toggle_Obj.Keybind_Mode == "Hold" then
                                Toggled = true
                                Toggle_Anim()
                                Callback(Toggled)
                            end
                        end
                    end)
                    
                    Toggle_Obj.Bind_Connection_Ended = User_Input_Service.InputEnded:Connect(function(Input, Gp)
                        if not Gp and Input.KeyCode == Toggle_Obj.Keybind_Value and Toggle_Obj.Keybind_Value ~= Enum.KeyCode.Unknown then
                            if Toggle_Obj.Keybind_Mode == "Hold" then
                                Toggled = false
                                Toggle_Anim()
                                Callback(Toggled)
                            end
                        end
                    end)
                    
                    table.insert(Library_Api.Connections, Toggle_Obj.Bind_Connection)
                    table.insert(Library_Api.Connections, Toggle_Obj.Bind_Connection_Ended)
                    if Toggled then Library_Api:Update_Keybind_List(Text_Val, Toggle_Obj.Keybind_Value.Name, Toggled, Toggle_Obj.Keybind_Mode) end
                    return Toggle_Obj
                end
                
                return Toggle_Obj
            end
            
            function Section:Keybind(Text_Val, Flag, Default_Key, Mode, Tooltip_Text, Callback)
                local Def_Obj = Library_Api.Flags[Flag]
                local Key = Def_Obj and Def_Obj.Key or (Default_Key or Enum.KeyCode.Unknown)
                local K_Mode = Def_Obj and Def_Obj.Mode or (Mode or "Toggle")
                Library_Api.Defaults[Flag] = {Key = Default_Key or Enum.KeyCode.Unknown, Mode = Mode or "Toggle"}
                Library_Api.Flags[Flag] = {Key = Key, Mode = K_Mode}
                
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 30)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Content
                
                local Label = Instance.new("TextLabel")
                Label.Text = Text_Val
                Label.Font = Configuration.Font_Main
                Label.TextSize = 13
                Label.TextColor3 = Menu_Colors.Text
                Label.Size = UDim2.new(0.6, 0, 1, 0)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                
                local Key_Btn = Instance.new("TextButton")
                Key_Btn.Size = UDim2.new(0, 80, 0, 20)
                Key_Btn.Position = UDim2.new(1, -5, 0.5, 0)
                Key_Btn.AnchorPoint = Vector2.new(1, 0.5)
                Key_Btn.BackgroundColor3 = Menu_Colors.Container
                Key_Btn.Text = "[" .. Key.Name .. "]"
                Key_Btn.Font = Configuration.Font_Main
                Key_Btn.TextSize = 12
                Key_Btn.TextColor3 = Menu_Colors.Text_Dark
                Key_Btn.AutoButtonColor = false
                Key_Btn.Parent = Frame
                Corner_Radius(Key_Btn, 4)
                Stroke_Border(Key_Btn, Menu_Colors.Stroke, 1, 0.5)
                
                local Toggled = (K_Mode == "Always")
                Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                
                local Binding = false
                local C1 = Key_Btn.MouseButton1Click:Connect(function()
                    if Binding then return end
                    Binding = true
                    Key_Btn.Text = "[...]"
                    Key_Btn.TextColor3 = Menu_Colors.Accent
                    local Conn
                    Conn = User_Input_Service.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.Keyboard then
                            if Input.KeyCode == Enum.KeyCode.Backspace or Input.KeyCode == Enum.KeyCode.Delete then
                                Key = Enum.KeyCode.Unknown
                            elseif Input.KeyCode ~= Enum.KeyCode.Escape and Input.KeyCode ~= Enum.KeyCode.Unknown then
                                Key = Input.KeyCode
                            end
                            Key_Btn.Text = "[" .. Key.Name .. "]"
                            Key_Btn.TextColor3 = Menu_Colors.Text_Dark
                            Library_Api.Flags[Flag] = {Key = Key, Mode = K_Mode}
                            Binding = false
                            Library_Api.Unsaved = true
                            Conn:Disconnect()
                            Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                        end
                    end)
                end)
                table.insert(Library_Api.Connections, C1)
                
                local Mode_Gui = Instance.new("Frame")
                Mode_Gui.Size = UDim2.new(0, 80, 0, 60)
                Mode_Gui.Position = UDim2.new(1, -90, 0, 25)
                Mode_Gui.BackgroundColor3 = Menu_Colors.Sidebar
                Mode_Gui.Visible = false
                Mode_Gui.ZIndex = 100
                Mode_Gui.Parent = Frame
                Corner_Radius(Mode_Gui, 4)
                Stroke_Border(Mode_Gui, Menu_Colors.Stroke, 1)
                
                local Mode_List = Instance.new("UIListLayout")
                Mode_List.Parent = Mode_Gui
                local Modes = {"Toggle", "Hold", "Always"}
                for _, Md in ipairs(Modes) do
                    local M_Btn = Instance.new("TextButton")
                    M_Btn.Size = UDim2.new(1, 0, 0, 20)
                    M_Btn.BackgroundTransparency = 1
                    M_Btn.Text = Md
                    M_Btn.TextColor3 = Menu_Colors.Text_Dark
                    M_Btn.Font = Configuration.Font_Main
                    M_Btn.TextSize = 11
                    M_Btn.Parent = Mode_Gui
                    M_Btn.ZIndex = 101
                    local C2 = M_Btn.MouseButton1Click:Connect(function()
                        K_Mode = Md
                        Library_Api.Flags[Flag] = {Key = Key, Mode = K_Mode}
                        Mode_Gui.Visible = false
                        Library_Api.Unsaved = true
                        if K_Mode == "Always" then
                            Toggled = true
                            Callback(true)
                        end
                        Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                    end)
                    table.insert(Library_Api.Connections, C2)
                end
                
                local C3 = Key_Btn.MouseButton2Click:Connect(function()
                    Mode_Gui.Visible = not Mode_Gui.Visible
                    if Mode_Gui.Visible then Content.ClipsDescendants = false end
                end)
                table.insert(Library_Api.Connections, C3)
                
                local Bind_Connection = User_Input_Service.InputBegan:Connect(function(Input, Gp)
                    if not Gp and Input.KeyCode == Key and Key ~= Enum.KeyCode.Unknown then
                        if K_Mode == "Toggle" then
                            Toggled = not Toggled
                            Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                            Callback(Toggled)
                        elseif K_Mode == "Hold" then
                            Toggled = true
                            Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                            Callback(Toggled)
                        end
                    end
                end)
                
                local Bind_Connection_Ended = User_Input_Service.InputEnded:Connect(function(Input, Gp)
                    if not Gp and Input.KeyCode == Key and Key ~= Enum.KeyCode.Unknown then
                        if K_Mode == "Hold" then
                            Toggled = false
                            Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                            Callback(Toggled)
                        end
                    end
                end)
                
                table.insert(Library_Api.Connections, Bind_Connection)
                table.insert(Library_Api.Connections, Bind_Connection_Ended)
                Apply_Tooltip(Frame, Tooltip_Text)
                
                Library_Api.Signals[Flag] = function(Val)
                    if type(Val) == "table" and Val.Key then
                        Key = Val.Key
                        K_Mode = Val.Mode or "Toggle"
                        Key_Btn.Text = "[" .. Key.Name .. "]"
                        if K_Mode == "Always" then
                            Toggled = true
                            Callback(true)
                        end
                        Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                    end
                end
                
                local Bind_Obj = {}
                function Bind_Obj:Set_Key(New_Key)
                    Key = New_Key
                    Key_Btn.Text = "[" .. Key.Name .. "]"
                    Library_Api.Flags[Flag] = {Key = Key, Mode = K_Mode}
                    Library_Api.Unsaved = true
                    Library_Api:Update_Keybind_List(Text_Val, Key.Name, Toggled, K_Mode)
                end
                return Bind_Obj
            end
            
            function Section:Button(Text_Val, Tooltip_Text, Callback)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 30)
                Btn.BackgroundColor3 = Menu_Colors.Container
                Btn.Text = Text_Val
                Btn.Font = Configuration.Font_Main
                Btn.TextSize = 13
                Btn.TextColor3 = Menu_Colors.Text
                Btn.AutoButtonColor = false
                Btn.Parent = Content
                table.insert(Sec_Data.Items, {Name = Text_Val, Instance = Btn})
                Corner_Radius(Btn, 4)
                local S = Stroke_Border(Btn, Menu_Colors.Stroke, 1, 0.5)
                local C1 = Btn.MouseEnter:Connect(function() Tween_Anim(Btn, {BackgroundColor3 = Menu_Colors.Stroke}) Tween_Anim(S, {Color = Menu_Colors.Accent}) end)
                local C2 = Btn.MouseLeave:Connect(function() Tween_Anim(Btn, {BackgroundColor3 = Menu_Colors.Container}) Tween_Anim(S, {Color = Menu_Colors.Stroke}) end)
                local C3 = Btn.MouseButton1Click:Connect(Callback)
                table.insert(Library_Api.Connections, C1)
                table.insert(Library_Api.Connections, C2)
                table.insert(Library_Api.Connections, C3)
                Apply_Tooltip(Btn, Tooltip_Text)
            end
            
            function Section:Slider(Text_Val, Flag, Min, Max, Default, Increment, Tooltip_Text, Callback)
                Create_Slider_Element(Text_Val, Flag, Min, Max, Default, Increment, Tooltip_Text, Callback, Content, Sec_Data)
            end
            
            function Section:Textbox(Text_Val, Flag, Placeholder, Tooltip_Text, Callback)
                Library_Api.Defaults[Flag] = ""
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 46)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Content
                table.insert(Sec_Data.Items, {Name = Text_Val, Instance = Frame})
                local Label = Instance.new("TextLabel")
                Label.Text = Text_Val
                Label.Font = Configuration.Font_Main
                Label.TextSize = 13
                Label.TextColor3 = Menu_Colors.Text
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local Box_Cont = Instance.new("Frame")
                Box_Cont.Size = UDim2.new(1, 0, 0, 26)
                Box_Cont.Position = UDim2.new(0, 0, 0, 20)
                Box_Cont.BackgroundColor3 = Menu_Colors.Container
                Box_Cont.Parent = Frame
                Corner_Radius(Box_Cont, 4)
                local S = Stroke_Border(Box_Cont, Menu_Colors.Stroke, 1, 0.5)
                local Input = Instance.new("TextBox")
                Input.Size = UDim2.new(1, -10, 1, 0)
                Input.Position = UDim2.new(0, 5, 0, 0)
                Input.BackgroundTransparency = 1
                Input.TextColor3 = Menu_Colors.Text
                Input.PlaceholderText = Placeholder or "Type here..."
                Input.PlaceholderColor3 = Menu_Colors.Text_Dark
                Input.Font = Configuration.Font_Main
                Input.TextSize = 13
                Input.TextXAlignment = Enum.TextXAlignment.Left
                local Current_Text = Library_Api.Flags[Flag] or ""
                Input.Text = Current_Text
                Input.ClearTextOnFocus = false
                Input.Parent = Box_Cont
                local C1 = Input.Focused:Connect(function() Tween_Anim(S, {Color = Menu_Colors.Accent}) end)
                local C2 = Input.FocusLost:Connect(function(Enter)
                    Tween_Anim(S, {Color = Menu_Colors.Stroke})
                    if Enter then
                        Library_Api.Flags[Flag] = Input.Text
                        Library_Api.Unsaved = true
                        Callback(Input.Text)
                    end
                end)
                table.insert(Library_Api.Connections, C1)
                table.insert(Library_Api.Connections, C2)
                Library_Api.Flags[Flag] = Current_Text
                Library_Api.Signals[Flag] = function(Val)
                    Input.Text = Val
                    Library_Api.Unsaved = true
                    Callback(Val)
                end
                Apply_Tooltip(Frame, Tooltip_Text)
                task.spawn(Callback, Current_Text)
            end
            
            function Section:Dropdown(Text_Val, Flag, Options, Default, Tooltip_Text, Callback, Custom_Parent, Is_Multi)
                local Obj = Create_Dropdown_Element(Text_Val, Flag, Options, Default, Tooltip_Text, Callback, Content, Section, Is_Multi, Custom_Parent)
                if not Custom_Parent then table.insert(Sec_Data.Items, {Name = Text_Val, Instance = Obj.Frame}) end
                return Obj
            end
            
            function Section:ColorPicker(Text_Val, Flag, Default, Tooltip_Text, Callback)
                local Color_Val = Library_Api.Flags[Flag] or Default or Color3.fromRGB(255, 255, 255)
                Library_Api.Defaults[Flag] = Default or Color3.fromRGB(255, 255, 255)
                Library_Api.Flags[Flag] = Color_Val
                local H, S, V = Color_Val:ToHSV()
                local Is_Open = false
                local Container_Frame = Instance.new("Frame")
                Container_Frame.Size = UDim2.new(1, 0, 0, 30)
                Container_Frame.BackgroundTransparency = 1
                Container_Frame.Parent = Content
                table.insert(Sec_Data.Items, {Name = Text_Val, Instance = Container_Frame})
                local Frame = Instance.new("Frame")
                Frame.Size = UDim2.new(1, 0, 0, 30)
                Frame.BackgroundTransparency = 1
                Frame.Parent = Container_Frame
                Frame.ZIndex = 5
                local Label = Instance.new("TextLabel")
                Label.Text = Text_Val
                Label.Font = Configuration.Font_Main
                Label.TextSize = 13
                Label.TextColor3 = Menu_Colors.Text
                Label.Size = UDim2.new(0.6, 0, 1, 0)
                Label.Position = UDim2.new(0, 5, 0, 0)
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = Frame
                local Preview = Instance.new("TextButton")
                Preview.Size = UDim2.new(0, 40, 0, 20)
                Preview.Position = UDim2.new(1, -5, 0.5, 0)
                Preview.AnchorPoint = Vector2.new(1, 0.5)
                Preview.BackgroundColor3 = Color_Val
                Preview.AutoButtonColor = false
                Preview.Text = ""
                Preview.Parent = Frame
                Corner_Radius(Preview, 4)
                Stroke_Border(Preview, Menu_Colors.Stroke, 1, 0.5)
                local Picker_Cont = Instance.new("Frame")
                Picker_Cont.Size = UDim2.new(1, 0, 0, 0)
                Picker_Cont.Position = UDim2.new(0, 0, 0, 30)
                Picker_Cont.BackgroundColor3 = Menu_Colors.Background
                Picker_Cont.Parent = Container_Frame
                Picker_Cont.ClipsDescendants = true
                Picker_Cont.Visible = false
                Picker_Cont.ZIndex = 10
                Corner_Radius(Picker_Cont, 4)
                local SV_Map = Instance.new("ImageLabel")
                SV_Map.Size = UDim2.new(0, 140, 0, 120)
                SV_Map.Position = UDim2.new(0, 10, 0, 10)
                SV_Map.Image = "rbxassetid://4155801252"
                SV_Map.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                SV_Map.Parent = Picker_Cont
                SV_Map.ZIndex = 11
                Corner_Radius(SV_Map, 4)
                local SV_Cursor = Instance.new("Frame")
                SV_Cursor.Size = UDim2.new(0, 8, 0, 8)
                SV_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SV_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SV_Cursor.Parent = SV_Map
                SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                SV_Cursor.ZIndex = 12
                Corner_Radius(SV_Cursor, 4)
                local Hue_Bar = Instance.new("ImageLabel")
                Hue_Bar.Size = UDim2.new(0, 20, 0, 120)
                Hue_Bar.Position = UDim2.new(0, 160, 0, 10)
                Hue_Bar.Image = "rbxassetid://4155801252"
                Hue_Bar.Parent = Picker_Cont
                Hue_Bar.ZIndex = 11
                Corner_Radius(Hue_Bar, 4)
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
                H_Cursor.Position = UDim2.new(0, 0, H, 0)
                H_Cursor.ZIndex = 12
                local Hex_Input = Instance.new("TextBox")
                Hex_Input.Size = UDim2.new(0, 170, 0, 20)
                Hex_Input.Position = UDim2.new(0, 10, 0, 140)
                Hex_Input.BackgroundColor3 = Menu_Colors.Container
                Hex_Input.TextColor3 = Menu_Colors.Text
                Hex_Input.Font = Configuration.Font_Main
                Hex_Input.TextSize = 12
                Hex_Input.Text = "#" .. Color_Val:ToHex()
                Hex_Input.Parent = Picker_Cont
                Hex_Input.ZIndex = 11
                Corner_Radius(Hex_Input, 4)
                Stroke_Border(Hex_Input, Menu_Colors.Stroke, 1)
                
                local function Update_Color()
                    Color_Val = Color3.fromHSV(H, S, V)
                    Preview.BackgroundColor3 = Color_Val
                    SV_Map.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    Hex_Input.Text = "#" .. Color_Val:ToHex()
                    Library_Api.Flags[Flag] = Color_Val
                    Library_Api.Unsaved = true
                    Callback(Color_Val)
                end
                
                local Hc1 = Hex_Input.FocusLost:Connect(function()
                    local T_Hex = Hex_Input.Text:gsub("#", "")
                    if T_Hex:match("^[0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F]$") then
                        pcall(function()
                            local Nc = Color3.fromHex(T_Hex)
                            H, S, V = Nc:ToHSV()
                            H_Cursor.Position = UDim2.new(0, 0, H, 0)
                            SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                            Update_Color()
                        end)
                    else
                        Hex_Input.Text = "#" .. Color_Val:ToHex()
                    end
                end)
                table.insert(Library_Api.Connections, Hc1)
                
                Library_Api.Signals[Flag] = function(Loaded_Val)
                    if typeof(Loaded_Val) == "Color3" then
                        Color_Val = Loaded_Val
                        H, S, V = Color_Val:ToHSV()
                        H_Cursor.Position = UDim2.new(0, 0, H, 0)
                        SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                        Update_Color()
                    end
                end
                
                local function Set_SV(Input)
                    local R_X = math.clamp((Input.Position.X - SV_Map.AbsolutePosition.X) / SV_Map.AbsoluteSize.X, 0, 1)
                    local R_Y = math.clamp((Input.Position.Y - SV_Map.AbsolutePosition.Y) / SV_Map.AbsoluteSize.Y, 0, 1)
                    S = R_X
                    V = 1 - R_Y
                    SV_Cursor.Position = UDim2.new(S, 0, 1 - V, 0)
                    Update_Color()
                end
                
                local function Set_H(Input)
                    local R_Y = math.clamp((Input.Position.Y - Hue_Bar.AbsolutePosition.Y) / Hue_Bar.AbsoluteSize.Y, 0, 1)
                    H = R_Y
                    H_Cursor.Position = UDim2.new(0, 0, H, 0)
                    Update_Color()
                end
                
                local Drag_SV = false
                local Drag_Input_SV
                local Sv1 = SV_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Drag_SV = true
                        Drag_Input_SV = Input
                        Set_SV(Input)
                        local Sc2
                        Sc2 = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Drag_SV = false
                                Sc2:Disconnect()
                            end
                        end)
                    end
                end)
                local Sv3 = User_Input_Service.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Drag_SV then Drag_Input_SV = Input end
                    end
                end)
                local Sv4 = Run_Service.RenderStepped:Connect(function()
                    if Drag_SV and Drag_Input_SV then Set_SV(Drag_Input_SV) end
                end)
                table.insert(Library_Api.Connections, Sv1)
                table.insert(Library_Api.Connections, Sv3)
                table.insert(Library_Api.Connections, Sv4)
                
                local Drag_H = false
                local Drag_Input_H
                local H1 = Hue_Bar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Drag_H = true
                        Drag_Input_H = Input
                        Set_H(Input)
                        local Hc2
                        Hc2 = Input.Changed:Connect(function()
                            if Input.UserInputState == Enum.UserInputState.End then
                                Drag_H = false
                                Hc2:Disconnect()
                            end
                        end)
                    end
                end)
                local H3 = User_Input_Service.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Drag_H then Drag_Input_H = Input end
                    end
                end)
                local H4 = Run_Service.RenderStepped:Connect(function()
                    if Drag_H and Drag_Input_H then Set_H(Drag_Input_H) end
                end)
                table.insert(Library_Api.Connections, H1)
                table.insert(Library_Api.Connections, H3)
                table.insert(Library_Api.Connections, H4)
                
                local Pc1 = Preview.MouseButton1Click:Connect(function()
                    Is_Open = not Is_Open
                    Section.Container.ZIndex = Is_Open and 10 or 1
                    Container_Frame.ZIndex = Is_Open and 10 or 5
                    if Is_Open then
                        Picker_Cont.Visible = true
                        Tween_Anim(Container_Frame, {Size = UDim2.new(1, 0, 0, 200)}, 0.2)
                        Tween_Anim(Picker_Cont, {Size = UDim2.new(1, 0, 0, 170)}, 0.2)
                    else
                        Tween_Anim(Container_Frame, {Size = UDim2.new(1, 0, 0, 30)}, 0.2)
                        local T = Tween_Anim(Picker_Cont, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
                        local Pc2
                        Pc2 = T.Completed:Connect(function()
                            if not Is_Open then Picker_Cont.Visible = false end
                            Pc2:Disconnect()
                        end)
                    end
                end)
                table.insert(Library_Api.Connections, Pc1)
                Apply_Tooltip(Container_Frame, Tooltip_Text)
                task.spawn(Callback, Color_Val)
            end
            
            return Section
        end
        return Tab
    end
    
    local Auto_Save_Timer = 0
    local Auto_Save_Conn = Run_Service.Heartbeat:Connect(function(Dt)
        if Library_Api.Auto_Save_Enabled and Library_Api.Unsaved then
            Auto_Save_Timer = Auto_Save_Timer + Dt
            if Auto_Save_Timer >= 3 then
                Auto_Save_Timer = 0
                Library_Api.Unsaved = false
                Library_Api:Save_Config("_autosave")
            end
        end
    end)
    table.insert(Library_Api.Connections, Auto_Save_Conn)
    
    task.defer(function()
        Library_Api:Load_Config("_autosave")
    end)
    
    Main_Scale.Scale = Get_Base_Scale()
    Main_Window.Visible = true
    return Window_Obj
end

return Library_Api
