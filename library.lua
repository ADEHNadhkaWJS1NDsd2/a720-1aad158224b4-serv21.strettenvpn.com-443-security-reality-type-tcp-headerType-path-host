local Core_Gui_Service = game:GetService("CoreGui")
local User_Input_Service = game:GetService("UserInputService")
local Run_Service = game:GetService("RunService")
local Tween_Service = game:GetService("TweenService")
local Text_Service = game:GetService("TextService")
local Http_Service = game:GetService("HttpService")
local Workspace_Service = game:GetService("Workspace")
local Players_Service = game:GetService("Players")
local Local_Player = Players_Service.LocalPlayer

local Library_Api = {
    Flags = {},
    Registry = {},
    Keybind_Names = {},
    Theme_Objects = {},
    Transparency_Objects = {},
    Acrylic_Objects = {},
    Saved_Positions = {},
    Instances = {},
    Folder_Name = "PhantomHub",
    Config_Name = "AutoSaveConfig.json",
    Current_Theme = "Rose",
    Global_Settings = {
        Acrylic = true,
        Transparency = true
    }
}

local Themes = {
    ["Rose"] = { mainBackground = Color3.fromRGB(30, 20, 25), sidebarBackground = Color3.fromRGB(35, 25, 30), sectionBackground = Color3.fromRGB(45, 30, 40), elementBackground = Color3.fromRGB(60, 35, 50), elementHoverBackground = Color3.fromRGB(75, 45, 60), borderColor = Color3.fromRGB(0, 0, 0), borderLightColor = Color3.fromRGB(0, 0, 0), accentColor = Color3.fromRGB(220, 90, 130), textWhiteColor = Color3.fromRGB(250, 240, 245), textDarkColor = Color3.fromRGB(200, 170, 185) },
    ["Slate"] = { mainBackground = Color3.fromRGB(15, 17, 20), sidebarBackground = Color3.fromRGB(11, 13, 15), sectionBackground = Color3.fromRGB(20, 22, 26), elementBackground = Color3.fromRGB(28, 30, 35), elementHoverBackground = Color3.fromRGB(38, 42, 48), borderColor = Color3.fromRGB(45, 50, 58), borderLightColor = Color3.fromRGB(65, 75, 88), accentColor = Color3.fromRGB(85, 135, 215), textWhiteColor = Color3.fromRGB(240, 245, 250), textDarkColor = Color3.fromRGB(140, 150, 165) },
    ["Midnight"] = { mainBackground = Color3.fromRGB(10, 12, 18), sidebarBackground = Color3.fromRGB(6, 8, 12), sectionBackground = Color3.fromRGB(16, 18, 26), elementBackground = Color3.fromRGB(22, 26, 36), elementHoverBackground = Color3.fromRGB(30, 35, 48), borderColor = Color3.fromRGB(35, 40, 55), borderLightColor = Color3.fromRGB(55, 65, 85), accentColor = Color3.fromRGB(100, 120, 240), textWhiteColor = Color3.fromRGB(230, 235, 255), textDarkColor = Color3.fromRGB(130, 140, 170) },
    ["Mocha"] = { mainBackground = Color3.fromRGB(20, 16, 14), sidebarBackground = Color3.fromRGB(15, 11, 9), sectionBackground = Color3.fromRGB(26, 22, 18), elementBackground = Color3.fromRGB(35, 28, 24), elementHoverBackground = Color3.fromRGB(48, 38, 32), borderColor = Color3.fromRGB(55, 45, 38), borderLightColor = Color3.fromRGB(85, 70, 60), accentColor = Color3.fromRGB(200, 140, 100), textWhiteColor = Color3.fromRGB(245, 240, 235), textDarkColor = Color3.fromRGB(165, 150, 140) },
    ["Tokyo"] = { mainBackground = Color3.fromRGB(16, 16, 22), sidebarBackground = Color3.fromRGB(12, 12, 18), sectionBackground = Color3.fromRGB(22, 22, 30), elementBackground = Color3.fromRGB(28, 28, 38), elementHoverBackground = Color3.fromRGB(40, 40, 55), borderColor = Color3.fromRGB(45, 45, 60), borderLightColor = Color3.fromRGB(75, 75, 100), accentColor = Color3.fromRGB(185, 135, 245), textWhiteColor = Color3.fromRGB(240, 240, 250), textDarkColor = Color3.fromRGB(150, 150, 175) },
    ["Dracula"] = { mainBackground = Color3.fromRGB(20, 18, 26), sidebarBackground = Color3.fromRGB(16, 14, 20), sectionBackground = Color3.fromRGB(28, 24, 35), elementBackground = Color3.fromRGB(38, 32, 48), elementHoverBackground = Color3.fromRGB(50, 42, 65), borderColor = Color3.fromRGB(60, 50, 75), borderLightColor = Color3.fromRGB(90, 75, 110), accentColor = Color3.fromRGB(255, 120, 150), textWhiteColor = Color3.fromRGB(248, 248, 242), textDarkColor = Color3.fromRGB(165, 150, 180) },
    ["Monokai"] = { mainBackground = Color3.fromRGB(18, 18, 16), sidebarBackground = Color3.fromRGB(14, 14, 12), sectionBackground = Color3.fromRGB(26, 26, 24), elementBackground = Color3.fromRGB(35, 35, 32), elementHoverBackground = Color3.fromRGB(48, 48, 42), borderColor = Color3.fromRGB(55, 55, 48), borderLightColor = Color3.fromRGB(85, 85, 75), accentColor = Color3.fromRGB(165, 225, 45), textWhiteColor = Color3.fromRGB(240, 240, 235), textDarkColor = Color3.fromRGB(160, 160, 150) },
    ["Nord"] = { mainBackground = Color3.fromRGB(24, 28, 34), sidebarBackground = Color3.fromRGB(18, 22, 28), sectionBackground = Color3.fromRGB(32, 38, 46), elementBackground = Color3.fromRGB(40, 48, 58), elementHoverBackground = Color3.fromRGB(55, 65, 78), borderColor = Color3.fromRGB(65, 75, 88), borderLightColor = Color3.fromRGB(95, 105, 120), accentColor = Color3.fromRGB(136, 192, 208), textWhiteColor = Color3.fromRGB(236, 239, 244), textDarkColor = Color3.fromRGB(160, 175, 190) },
    ["Deep Sea"] = { mainBackground = Color3.fromRGB(10, 18, 22), sidebarBackground = Color3.fromRGB(6, 12, 16), sectionBackground = Color3.fromRGB(16, 28, 34), elementBackground = Color3.fromRGB(22, 36, 44), elementHoverBackground = Color3.fromRGB(32, 50, 60), borderColor = Color3.fromRGB(38, 55, 68), borderLightColor = Color3.fromRGB(65, 90, 105), accentColor = Color3.fromRGB(45, 185, 180), textWhiteColor = Color3.fromRGB(225, 245, 250), textDarkColor = Color3.fromRGB(130, 160, 175) },
    ["Forest"] = { mainBackground = Color3.fromRGB(12, 18, 14), sidebarBackground = Color3.fromRGB(8, 14, 10), sectionBackground = Color3.fromRGB(18, 26, 20), elementBackground = Color3.fromRGB(24, 35, 28), elementHoverBackground = Color3.fromRGB(35, 50, 40), borderColor = Color3.fromRGB(45, 60, 50), borderLightColor = Color3.fromRGB(75, 95, 80), accentColor = Color3.fromRGB(100, 200, 130), textWhiteColor = Color3.fromRGB(235, 250, 240), textDarkColor = Color3.fromRGB(140, 170, 150) },
    ["Crimson"] = { mainBackground = Color3.fromRGB(14, 10, 10), sidebarBackground = Color3.fromRGB(10, 6, 6), sectionBackground = Color3.fromRGB(22, 14, 14), elementBackground = Color3.fromRGB(30, 18, 18), elementHoverBackground = Color3.fromRGB(45, 25, 25), borderColor = Color3.fromRGB(50, 25, 25), borderLightColor = Color3.fromRGB(85, 40, 40), accentColor = Color3.fromRGB(220, 45, 45), textWhiteColor = Color3.fromRGB(250, 230, 230), textDarkColor = Color3.fromRGB(165, 135, 135) },
    ["Lavender"] = { mainBackground = Color3.fromRGB(16, 14, 20), sidebarBackground = Color3.fromRGB(12, 10, 16), sectionBackground = Color3.fromRGB(24, 22, 28), elementBackground = Color3.fromRGB(32, 28, 38), elementHoverBackground = Color3.fromRGB(45, 40, 55), borderColor = Color3.fromRGB(55, 45, 65), borderLightColor = Color3.fromRGB(85, 75, 95), accentColor = Color3.fromRGB(180, 150, 240), textWhiteColor = Color3.fromRGB(245, 240, 255), textDarkColor = Color3.fromRGB(155, 145, 175) },
    ["Carbon"] = { mainBackground = Color3.fromRGB(10, 10, 10), sidebarBackground = Color3.fromRGB(5, 5, 5), sectionBackground = Color3.fromRGB(15, 15, 15), elementBackground = Color3.fromRGB(22, 22, 22), elementHoverBackground = Color3.fromRGB(32, 32, 32), borderColor = Color3.fromRGB(40, 40, 40), borderLightColor = Color3.fromRGB(70, 70, 70), accentColor = Color3.fromRGB(220, 220, 220), textWhiteColor = Color3.fromRGB(255, 255, 255), textDarkColor = Color3.fromRGB(150, 150, 150) },
    ["Solarized"] = { mainBackground = Color3.fromRGB(0, 21, 27), sidebarBackground = Color3.fromRGB(0, 14, 18), sectionBackground = Color3.fromRGB(2, 32, 40), elementBackground = Color3.fromRGB(4, 45, 55), elementHoverBackground = Color3.fromRGB(8, 62, 75), borderColor = Color3.fromRGB(15, 75, 90), borderLightColor = Color3.fromRGB(35, 105, 120), accentColor = Color3.fromRGB(40, 160, 150), textWhiteColor = Color3.fromRGB(235, 245, 245), textDarkColor = Color3.fromRGB(120, 145, 155) },
    ["Outrun"] = { mainBackground = Color3.fromRGB(18, 10, 24), sidebarBackground = Color3.fromRGB(12, 6, 18), sectionBackground = Color3.fromRGB(26, 15, 35), elementBackground = Color3.fromRGB(35, 20, 48), elementHoverBackground = Color3.fromRGB(50, 30, 68), borderColor = Color3.fromRGB(65, 35, 85), borderLightColor = Color3.fromRGB(100, 55, 125), accentColor = Color3.fromRGB(255, 80, 180), textWhiteColor = Color3.fromRGB(250, 235, 255), textDarkColor = Color3.fromRGB(160, 130, 185) },
    ["Abyss"] = { mainBackground = Color3.fromRGB(6, 8, 14), sidebarBackground = Color3.fromRGB(3, 5, 9), sectionBackground = Color3.fromRGB(10, 14, 22), elementBackground = Color3.fromRGB(15, 20, 30), elementHoverBackground = Color3.fromRGB(22, 30, 45), borderColor = Color3.fromRGB(28, 38, 55), borderLightColor = Color3.fromRGB(45, 60, 85), accentColor = Color3.fromRGB(50, 140, 255), textWhiteColor = Color3.fromRGB(220, 235, 255), textDarkColor = Color3.fromRGB(110, 135, 165) },
    ["Material"] = { mainBackground = Color3.fromRGB(18, 18, 18), sidebarBackground = Color3.fromRGB(12, 12, 12), sectionBackground = Color3.fromRGB(28, 28, 28), elementBackground = Color3.fromRGB(38, 38, 38), elementHoverBackground = Color3.fromRGB(55, 55, 55), borderColor = Color3.fromRGB(65, 65, 65), borderLightColor = Color3.fromRGB(95, 95, 95), accentColor = Color3.fromRGB(0, 175, 155), textWhiteColor = Color3.fromRGB(250, 250, 250), textDarkColor = Color3.fromRGB(160, 160, 160) }
}

local Main_Font = Enum.Font.GothamMedium
local Bold_Font = Enum.Font.GothamBold

local Custom_Input_Names = {
    [Enum.UserInputType.MouseButton1] = "MB1",
    [Enum.UserInputType.MouseButton2] = "MB2",
    [Enum.UserInputType.MouseButton3] = "MB3",
}

local Screen_Gui = Instance.new("ScreenGui")
Screen_Gui.Name = Http_Service:GenerateGUID(false)
Screen_Gui.Parent = Core_Gui_Service
Screen_Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen_Gui.DisplayOrder = 999
Screen_Gui.IgnoreGuiInset = true

local function Get_Input_Name(Input_Enum)
    if Custom_Input_Names[Input_Enum] then return Custom_Input_Names[Input_Enum] end
    if Input_Enum == Enum.KeyCode.Unknown then return "None" end
    return Input_Enum.Name
end

local function GetTextWidth(Text_String, Size, Font)
    return Text_Service:GetTextSize(Text_String, Size, Font, Vector2.new(10000, 10000)).X
end

local function Animate_Element(Element, Properties, Speed)
    local Tween = Tween_Service:Create(Element, TweenInfo.new(Speed or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Properties)
    Tween:Play()
    return Tween
end

local function Bind_Color(Instance_Obj, Property, Color_Key)
    table.insert(Library_Api.Theme_Objects, {Obj = Instance_Obj, Prop = Property, Key = Color_Key})
    Instance_Obj[Property] = Themes[Library_Api.Current_Theme][Color_Key]
end

local function Set_Theme_State(Obj, Prop, New_Key)
    if not Obj or not Obj.Parent then return end
    for _, Data in ipairs(Library_Api.Theme_Objects) do
        if Data.Obj == Obj and Data.Prop == Prop then
            Data.Key = New_Key
            Animate_Element(Obj, {[Prop] = Themes[Library_Api.Current_Theme][New_Key]}, 0.25)
            return
        end
    end
    Bind_Color(Obj, Prop, New_Key)
    Animate_Element(Obj, {[Prop] = Themes[Library_Api.Current_Theme][New_Key]}, 0.25)
end

function Library_Api:ChangeTheme(Theme_Name)
    if not Themes[Theme_Name] then return end
    Library_Api.Current_Theme = Theme_Name
    for _, Data in ipairs(Library_Api.Theme_Objects) do
        if Data.Obj and Data.Obj.Parent then
            Animate_Element(Data.Obj, {[Data.Prop] = Themes[Theme_Name][Data.Key]}, 0.3)
        end
    end
end

local function Register_Transparency(Obj, Default_Val)
    table.insert(Library_Api.Transparency_Objects, {Obj = Obj, Def = Default_Val})
    Obj.BackgroundTransparency = Library_Api.Global_Settings.Transparency and Default_Val or 0
end

local function Apply_Acrylic_Effect(Parent)
    local Noise = Instance.new("ImageLabel")
    Noise.Size = UDim2.new(1, 0, 1, 0)
    Noise.BackgroundTransparency = 1
    Noise.Image = "rbxassetid://13830869661"
    Noise.ImageTransparency = 0.92
    Noise.TileSize = UDim2.new(0, 128, 0, 128)
    Noise.ScaleType = Enum.ScaleType.Tile
    Noise.ZIndex = Parent.ZIndex
    Noise.Parent = Parent
    local P_Corner = Parent:FindFirstChildOfClass("UICorner")
    if P_Corner then
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = P_Corner.CornerRadius
        Corner.Parent = Noise
    end
    table.insert(Library_Api.Acrylic_Objects, Noise)
    Noise.Visible = Library_Api.Global_Settings.Acrylic
    return Noise
end

local function Save_To_File(FileName)
    task.spawn(function()
        pcall(function()
            if type(isfolder) == "function" and not isfolder(Library_Api.Folder_Name) then
                makefolder(Library_Api.Folder_Name)
            elseif type(makefolder) == "function" then
                pcall(makefolder, Library_Api.Folder_Name)
            end
        end)
        
        pcall(function()
            local Serialized_Data = {}
            for Key, Val in pairs(Library_Api.Flags) do
                pcall(function()
                    if typeof(Val) == "Color3" then
                        Serialized_Data[Key] = {Type = "Color3", R = Val.R, G = Val.G, B = Val.B}
                    elseif typeof(Val) == "EnumItem" then
                        Serialized_Data[Key] = {Type = "EnumItem", EnumType = tostring(Val.EnumType), Name = Val.Name}
                    elseif type(Val) == "table" and Val.Min ~= nil and Val.Max ~= nil then
                        Serialized_Data[Key] = {Type = "Range", Min = Val.Min, Max = Val.Max}
                    elseif type(Val) == "table" then
                        Serialized_Data[Key] = {Type = "Array", Data = Val}
                    else
                        Serialized_Data[Key] = Val
                    end
                end)
            end
            Serialized_Data["$$Theme"] = Library_Api.Current_Theme
            Serialized_Data["$$Acrylic"] = Library_Api.Global_Settings.Acrylic
            Serialized_Data["$$Transparency"] = Library_Api.Global_Settings.Transparency
            if Library_Api.Instances.MenuTargetPos then
                local pos = Library_Api.Instances.MenuTargetPos
                Serialized_Data["$$MenuPos"] = {X = pos.X.Scale, XOff = pos.X.Offset, Y = pos.Y.Scale, YOff = pos.Y.Offset}
            end
            if Library_Api.Instances.KeybindsTarget then
                local pos = Library_Api.Instances.KeybindsTarget
                Serialized_Data["$$KbPos"] = {X = pos.X.Scale, XOff = pos.X.Offset, Y = pos.Y.Scale, YOff = pos.Y.Offset}
            end
            writefile(Library_Api.Folder_Name .. "/" .. FileName, Http_Service:JSONEncode(Serialized_Data))
        end)
    end)
end

local Save_Pending = false
local Last_Save_Time = os.clock()

local function Auto_Save()
    if Save_Pending then return end
    Save_Pending = true
    task.delay(1, function()
        Save_To_File(Library_Api.Config_Name)
        Last_Save_Time = os.clock()
        Save_Pending = false
    end)
end

Run_Service.Heartbeat:Connect(function()
    if os.clock() - Last_Save_Time >= 5 then
        Last_Save_Time = os.clock()
        Save_To_File(Library_Api.Config_Name)
    end
end)

local function Load_From_File(FileName)
    local success, content = pcall(function()
        return readfile(Library_Api.Folder_Name .. "/" .. FileName)
    end)
    
    if success and content then
        pcall(function()
            local Decoded_Data = Http_Service:JSONDecode(content)
            if type(Decoded_Data) == "table" then
                
                if Decoded_Data["$$Theme"] then
                    Library_Api:ChangeTheme(tostring(Decoded_Data["$$Theme"]))
                end
                
                if Decoded_Data["Custom_Accent_Color"] then
                    local cData = Decoded_Data["Custom_Accent_Color"]
                    local c = Color3.new(cData.R, cData.G, cData.B)
                    for _, theme in pairs(Themes) do theme.accentColor = c end
                    Library_Api:ChangeTheme(tostring(Decoded_Data["$$Theme"] or Library_Api.Current_Theme))
                end

                for Key, Val in pairs(Decoded_Data) do
                    pcall(function()
                        if Key == "$$MenuPos" then
                            local pos = UDim2.new(Val.X, Val.XOff, Val.Y, Val.YOff)
                            Library_Api.Saved_Positions.Menu = pos
                            if Library_Api.Instances.Menu then 
                                Library_Api.Instances.Menu.Position = pos
                                Library_Api.Instances.MenuTargetPos = pos 
                            end
                        elseif Key == "$$KbPos" then
                            local pos = UDim2.new(Val.X, Val.XOff, Val.Y, Val.YOff)
                            Library_Api.Saved_Positions.Keybinds = pos
                            if Library_Api.Instances.Keybinds then 
                                Library_Api.Instances.Keybinds.Position = pos
                                Library_Api.Instances.KeybindsTarget = pos
                            end
                        elseif Key == "$$Acrylic" then
                            Library_Api.Global_Settings.Acrylic = Val
                            Library_Api.Flags["Global_Acrylic"] = Val
                            if type(Library_Api.Registry["Global_Acrylic"]) == "function" then task.spawn(Library_Api.Registry["Global_Acrylic"], Val) end
                        elseif Key == "$$Transparency" then
                            Library_Api.Global_Settings.Transparency = Val
                            Library_Api.Flags["Global_Trans"] = Val
                            if type(Library_Api.Registry["Global_Trans"]) == "function" then task.spawn(Library_Api.Registry["Global_Trans"], Val) end
                        elseif Key ~= "$$Theme" and Key ~= "Custom_Accent_Color" then
                            if type(Val) == "table" then
                                if Val.Type == "Color3" then
                                    Library_Api.Flags[Key] = Color3.new(Val.R, Val.G, Val.B)
                                elseif Val.Type == "EnumItem" then
                                    local enumGroup = tostring(Val.EnumType):gsub("Enum%.", "")
                                    local enumType = Enum[enumGroup]
                                    if enumType then
                                        Library_Api.Flags[Key] = enumType[tostring(Val.Name)] or Enum.KeyCode.Unknown
                                    end
                                elseif Val.Type == "Range" then
                                    Library_Api.Flags[Key] = {Min = Val.Min, Max = Val.Max}
                                elseif Val.Type == "Array" then
                                    Library_Api.Flags[Key] = Val.Data
                                else
                                    Library_Api.Flags[Key] = Val
                                end
                            else
                                Library_Api.Flags[Key] = Val
                            end

                            if type(Library_Api.Registry[Key]) == "function" and Key ~= "Menu_Theme_Select" and Key ~= "Global_Acrylic" and Key ~= "Global_Trans" then
                                task.spawn(Library_Api.Registry[Key], Library_Api.Flags[Key])
                            end
                        end
                    end)
                end
            end
        end)
    end
end

local Tooltip_Frame = Instance.new("Frame")
Tooltip_Frame.Size = UDim2.new(0, 0, 0, 28)
Tooltip_Frame.ZIndex = 2000
Tooltip_Frame.Visible = false
Tooltip_Frame.Parent = Screen_Gui
Bind_Color(Tooltip_Frame, "BackgroundColor3", "elementBackground")
Register_Transparency(Tooltip_Frame, 0.15)

local Tooltip_Corner = Instance.new("UICorner")
Tooltip_Corner.CornerRadius = UDim.new(0, 6)
Tooltip_Corner.Parent = Tooltip_Frame

local Tooltip_Text = Instance.new("TextLabel")
Tooltip_Text.Size = UDim2.new(1, -16, 1, 0)
Tooltip_Text.Position = UDim2.new(0, 8, 0, 0)
Tooltip_Text.BackgroundTransparency = 1
Tooltip_Text.TextTransparency = 1
Tooltip_Text.TextSize = 14
Tooltip_Text.Font = Main_Font
Tooltip_Text.TextXAlignment = Enum.TextXAlignment.Left
Tooltip_Text.ZIndex = 2001
Tooltip_Text.Parent = Tooltip_Frame
Bind_Color(Tooltip_Text, "TextColor3", "textWhiteColor")

local Notification_Container = Instance.new("Frame")
Notification_Container.Size = UDim2.new(0, 280, 1, -40)
Notification_Container.Position = UDim2.new(1, -300, 0, 20)
Notification_Container.BackgroundTransparency = 1
Notification_Container.ZIndex = 1500
Notification_Container.Parent = Screen_Gui

local Notification_Layout = Instance.new("UIListLayout")
Notification_Layout.SortOrder = Enum.SortOrder.LayoutOrder
Notification_Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
Notification_Layout.Padding = UDim.new(0, 10)
Notification_Layout.Parent = Notification_Container

local Tooltip_Target_Text = ""

local function Show_Tooltip(Text)
    Tooltip_Target_Text = Text or ""
    if Tooltip_Target_Text ~= "" then
        Tooltip_Text.Text = Tooltip_Target_Text
        local Text_Width = GetTextWidth(Tooltip_Target_Text, 14, Main_Font)
        Tooltip_Frame.Size = UDim2.new(0, Text_Width + 16, 0, 28)
    end
end

local Keybinds_Frame = Instance.new("Frame")
Keybinds_Frame.Size = UDim2.new(0, 240, 0, 36)
Keybinds_Frame.Position = Library_Api.Saved_Positions.Keybinds or UDim2.new(0, 20, 0, 20)
Keybinds_Frame.Visible = false
Keybinds_Frame.Parent = Screen_Gui
Bind_Color(Keybinds_Frame, "BackgroundColor3", "mainBackground")
Register_Transparency(Keybinds_Frame, 0.1)
Apply_Acrylic_Effect(Keybinds_Frame)
Library_Api.Instances.Keybinds = Keybinds_Frame
Library_Api.Instances.KeybindsTarget = Keybinds_Frame.Position

local Kb_Corner = Instance.new("UICorner")
Kb_Corner.CornerRadius = UDim.new(0, 8)
Kb_Corner.Parent = Keybinds_Frame

local Kb_Top = Instance.new("Frame")
Kb_Top.Size = UDim2.new(1, 0, 0, 36)
Kb_Top.BackgroundTransparency = 1
Kb_Top.Parent = Keybinds_Frame

local Kb_Title = Instance.new("TextLabel")
Kb_Title.Size = UDim2.new(1, -20, 1, 0)
Kb_Title.Position = UDim2.new(0, 10, 0, 0)
Kb_Title.BackgroundTransparency = 1
Kb_Title.Text = "Active Keybinds"
Kb_Title.TextSize = 15
Kb_Title.Font = Bold_Font
Kb_Title.TextXAlignment = Enum.TextXAlignment.Center
Kb_Title.Parent = Kb_Top
Bind_Color(Kb_Title, "TextColor3", "accentColor")

local Kb_Line = Instance.new("Frame")
Kb_Line.Size = UDim2.new(1, 0, 0, 1)
Kb_Line.Position = UDim2.new(0, 0, 1, 0)
Kb_Line.BorderSizePixel = 0
Kb_Line.Parent = Kb_Top
Bind_Color(Kb_Line, "BackgroundColor3", "elementBackground")

local Kb_Container = Instance.new("Frame")
Kb_Container.Size = UDim2.new(1, -16, 1, -44)
Kb_Container.Position = UDim2.new(0, 8, 0, 40)
Kb_Container.BackgroundTransparency = 1
Kb_Container.Parent = Keybinds_Frame

local Kb_Layout = Instance.new("UIListLayout")
Kb_Layout.Padding = UDim.new(0, 8)
Kb_Layout.Parent = Kb_Container

local Kb_Dragging = false
local Kb_Drag_Input = nil
local Kb_Drag_Start = nil
local Kb_Start_Pos = nil

Kb_Top.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Kb_Dragging = true
        Kb_Drag_Start = Input.Position
        Kb_Start_Pos = Keybinds_Frame.Position
        Library_Api.Instances.KeybindsTarget = Kb_Start_Pos
    end
end)

User_Input_Service.InputChanged:Connect(function(Input)
    if Kb_Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = Input.Position - Kb_Drag_Start
        Library_Api.Instances.KeybindsTarget = UDim2.new(Kb_Start_Pos.X.Scale, Kb_Start_Pos.X.Offset + Delta.X, Kb_Start_Pos.Y.Scale, Kb_Start_Pos.Y.Offset + Delta.Y)
    end
end)

User_Input_Service.InputEnded:Connect(function(Input)
    if Kb_Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
        Kb_Dragging = false
        Auto_Save()
    end
end)

Run_Service.RenderStepped:Connect(function()
    if Keybinds_Frame.Visible then
        Keybinds_Frame.Position = Keybinds_Frame.Position:Lerp(Library_Api.Instances.KeybindsTarget, 0.4)
    end
end)

function Library_Api:RefreshKeybinds()
    for _, Child in ipairs(Kb_Container:GetChildren()) do
        if Child:IsA("Frame") then Child:Destroy() end
    end
    local Count = 0
    for Flag, Key in pairs(Library_Api.Flags) do
        if typeof(Key) == "EnumItem" and Key ~= Enum.KeyCode.Unknown then
            local Name = Library_Api.Keybind_Names[Flag] or Flag
            local BindText = "[" .. Get_Input_Name(Key) .. "]"
            local BindWidth = GetTextWidth(BindText, 14, Bold_Font)
            Count = Count + 1
            local Kb_Item = Instance.new("Frame")
            Kb_Item.Size = UDim2.new(1, 0, 0, 26)
            Kb_Item.Parent = Kb_Container
            Bind_Color(Kb_Item, "BackgroundColor3", "elementBackground")
            Register_Transparency(Kb_Item, 0.5)
            
            local Item_Corner = Instance.new("UICorner")
            Item_Corner.CornerRadius = UDim.new(0, 4)
            Item_Corner.Parent = Kb_Item

            local Kb_Val = Instance.new("TextLabel")
            Kb_Val.AnchorPoint = Vector2.new(1, 0.5)
            Kb_Val.Size = UDim2.new(0, BindWidth, 1, 0)
            Kb_Val.Position = UDim2.new(1, -10, 0.5, 0)
            Kb_Val.BackgroundTransparency = 1
            Kb_Val.Text = BindText
            Kb_Val.TextSize = 14
            Kb_Val.Font = Bold_Font
            Kb_Val.TextXAlignment = Enum.TextXAlignment.Right
            Kb_Val.Parent = Kb_Item
            Bind_Color(Kb_Val, "TextColor3", "accentColor")

            local Kb_Name = Instance.new("TextLabel")
            Kb_Name.Size = UDim2.new(1, -(BindWidth + 24), 1, 0)
            Kb_Name.Position = UDim2.new(0, 10, 0, 0)
            Kb_Name.BackgroundTransparency = 1
            Kb_Name.Text = Name
            Kb_Name.TextSize = 14
            Kb_Name.Font = Main_Font
            Kb_Name.TextXAlignment = Enum.TextXAlignment.Left
            Kb_Name.TextTruncate = Enum.TextTruncate.AtEnd
            Kb_Name.Parent = Kb_Item
            Bind_Color(Kb_Name, "TextColor3", "textWhiteColor")
        end
    end
    Animate_Element(Keybinds_Frame, {Size = UDim2.new(0, 240, 0, 50 + (Count * 34))}, 0.25)
end

local function Snap_Value(Value, Step)
    if not Step then return Value end
    return math.floor((Value / Step) + 0.5) * Step
end

local function Format_Value(Value, Step)
    if Step and Step < 1 then
        local Step_Str = tostring(Step)
        local Dot_Index = string.find(Step_Str, "%.")
        local Decimal_Places = Dot_Index and (string.len(Step_Str) - Dot_Index) or 0
        return string.format("%."..Decimal_Places.."f", Value)
    end
    return tostring(math.floor(Value + 0.5))
end

Run_Service.RenderStepped:Connect(function()
    if Tooltip_Target_Text ~= "" then
        local Mouse_Loc = User_Input_Service:GetMouseLocation()
        Tooltip_Frame.Position = UDim2.new(0, Mouse_Loc.X + 20, 0, Mouse_Loc.Y + 20)
        if not Tooltip_Frame.Visible then
            Tooltip_Frame.Visible = true
            Animate_Element(Tooltip_Frame, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.15 or 0}, 0.25)
            Animate_Element(Tooltip_Text, {TextTransparency = 0}, 0.25)
        end
    else
        Animate_Element(Tooltip_Frame, {BackgroundTransparency = 1}, 0.15)
        Animate_Element(Tooltip_Text, {TextTransparency = 1}, 0.15)
        task.delay(0.15, function()
            if Tooltip_Target_Text == "" then
                Tooltip_Frame.Visible = false
            end
        end)
    end
end)

function Library_Api:Notify(Config)
    local Title = Config.Title or "Notification"
    local Text = Config.Text or ""
    local Duration = Config.Duration or 3

    local Notification_Frame = Instance.new("Frame")
    Notification_Frame.Size = UDim2.new(1, 0, 0, 60)
    Notification_Frame.ZIndex = 1501
    Notification_Frame.Parent = Notification_Container
    Bind_Color(Notification_Frame, "BackgroundColor3", "sectionBackground")
    Register_Transparency(Notification_Frame, 0.05)

    local Notification_Corner = Instance.new("UICorner")
    Notification_Corner.CornerRadius = UDim.new(0, 6)
    Notification_Corner.Parent = Notification_Frame

    local Line_Frame = Instance.new("Frame")
    Line_Frame.Size = UDim2.new(0, 4, 1, -20)
    Line_Frame.Position = UDim2.new(0, 10, 0, 10)
    Line_Frame.BorderSizePixel = 0
    Line_Frame.ZIndex = 1502
    Line_Frame.Parent = Notification_Frame
    Bind_Color(Line_Frame, "BackgroundColor3", "accentColor")

    local Line_Corner = Instance.new("UICorner")
    Line_Corner.CornerRadius = UDim.new(0, 2)
    Line_Corner.Parent = Line_Frame

    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -30, 0, 18)
    Title_Label.Position = UDim2.new(0, 20, 0, 10)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Title
    Title_Label.TextSize = 15
    Title_Label.Font = Bold_Font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.ZIndex = 1502
    Title_Label.Parent = Notification_Frame
    Bind_Color(Title_Label, "TextColor3", "textWhiteColor")

    local Text_Label = Instance.new("TextLabel")
    Text_Label.Size = UDim2.new(1, -30, 0, 20)
    Text_Label.Position = UDim2.new(0, 20, 0, 30)
    Text_Label.BackgroundTransparency = 1
    Text_Label.Text = Text
    Text_Label.TextSize = 14
    Text_Label.Font = Main_Font
    Text_Label.TextXAlignment = Enum.TextXAlignment.Left
    Text_Label.TextWrapped = true
    Text_Label.ZIndex = 1502
    Text_Label.Parent = Notification_Frame
    Bind_Color(Text_Label, "TextColor3", "textDarkColor")

    Notification_Frame.BackgroundTransparency = 1
    Line_Frame.BackgroundTransparency = 1
    Title_Label.TextTransparency = 1
    Text_Label.TextTransparency = 1

    Animate_Element(Notification_Frame, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.05 or 0}, 0.35)
    Animate_Element(Line_Frame, {BackgroundTransparency = 0}, 0.35)
    Animate_Element(Title_Label, {TextTransparency = 0}, 0.35)
    Animate_Element(Text_Label, {TextTransparency = 0}, 0.35)

    task.delay(Duration, function()
        local Hide_Tween = Animate_Element(Notification_Frame, {BackgroundTransparency = 1}, 0.35)
        Animate_Element(Line_Frame, {BackgroundTransparency = 1}, 0.35)
        Animate_Element(Title_Label, {TextTransparency = 1}, 0.35)
        Animate_Element(Text_Label, {TextTransparency = 1}, 0.35)
        Hide_Tween.Completed:Connect(function()
            Notification_Frame:Destroy()
        end)
    end)
end

function Library_Api:CreateWindow(Window_Name)
    local Normal_Size = UDim2.new(0, 680, 0, 420)

    local Main_Background = Instance.new("Frame")
    Main_Background.Size = Normal_Size
    Main_Background.Position = Library_Api.Saved_Positions.Menu or UDim2.new(0.5, -340, 0.5, -210)
    Main_Background.BorderSizePixel = 0
    Main_Background.Active = true
    Main_Background.ClipsDescendants = true
    Main_Background.Parent = Screen_Gui
    Bind_Color(Main_Background, "BackgroundColor3", "mainBackground")
    Register_Transparency(Main_Background, 0.18)
    Library_Api.Instances.Menu = Main_Background

    local Top_Accent_Line = Instance.new("Frame")
    Top_Accent_Line.Size = UDim2.new(1, 0, 0, 3)
    Top_Accent_Line.Position = UDim2.new(0, 0, 0, 0)
    Top_Accent_Line.BorderSizePixel = 0
    Top_Accent_Line.ZIndex = 5
    Top_Accent_Line.Parent = Main_Background
    Bind_Color(Top_Accent_Line, "BackgroundColor3", "accentColor")
    
    local Top_Accent_Corner = Instance.new("UICorner")
    Top_Accent_Corner.CornerRadius = UDim.new(0, 8)
    Top_Accent_Corner.Parent = Top_Accent_Line
    
    local Top_Accent_Hider = Instance.new("Frame")
    Top_Accent_Hider.Size = UDim2.new(1, 0, 0, 2)
    Top_Accent_Hider.Position = UDim2.new(0, 0, 1, -2)
    Top_Accent_Hider.BorderSizePixel = 0
    Top_Accent_Hider.ZIndex = 5
    Top_Accent_Hider.Parent = Top_Accent_Line
    Bind_Color(Top_Accent_Hider, "BackgroundColor3", "accentColor")

    local Ui_Scale_Modifier = Instance.new("UIScale")
    Ui_Scale_Modifier.Parent = Main_Background
    
    local Main_Corner = Instance.new("UICorner")
    Main_Corner.CornerRadius = UDim.new(0, 8)
    Main_Corner.Parent = Main_Background

    Apply_Acrylic_Effect(Main_Background)

    local Top_Bar = Instance.new("Frame")
    Top_Bar.Size = UDim2.new(1, 0, 0, 42)
    Top_Bar.BorderSizePixel = 0
    Top_Bar.Parent = Main_Background
    Bind_Color(Top_Bar, "BackgroundColor3", "sidebarBackground")
    Register_Transparency(Top_Bar, 0.21)
    
    local Top_Corner = Instance.new("UICorner")
    Top_Corner.CornerRadius = UDim.new(0, 8)
    Top_Corner.Parent = Top_Bar

    local Top_Hider = Instance.new("Frame")
    Top_Hider.Size = UDim2.new(1, 0, 0, 8)
    Top_Hider.Position = UDim2.new(0, 0, 1, -8)
    Top_Hider.BorderSizePixel = 0
    Top_Hider.Parent = Top_Bar
    Bind_Color(Top_Hider, "BackgroundColor3", "sidebarBackground")
    Register_Transparency(Top_Hider, 0.21)

    local Top_Border = Instance.new("Frame")
    Top_Border.Size = UDim2.new(1, 0, 0, 1)
    Top_Border.Position = UDim2.new(0, 0, 1, 0)
    Top_Border.BorderSizePixel = 0
    Top_Border.Parent = Top_Bar
    Bind_Color(Top_Border, "BackgroundColor3", "elementBackground")

    local Title_Label = Instance.new("TextLabel")
    Title_Label.Size = UDim2.new(1, -120, 1, -2)
    Title_Label.Position = UDim2.new(0, 20, 0, 2)
    Title_Label.BackgroundTransparency = 1
    Title_Label.Text = Window_Name
    Title_Label.TextSize = 16
    Title_Label.Font = Bold_Font
    Title_Label.TextXAlignment = Enum.TextXAlignment.Left
    Title_Label.Parent = Top_Bar
    Bind_Color(Title_Label, "TextColor3", "textWhiteColor")

    local Window_Controls = Instance.new("Frame")
    Window_Controls.AnchorPoint = Vector2.new(1, 0)
    Window_Controls.Size = UDim2.new(0, 110, 1, 0)
    Window_Controls.Position = UDim2.new(1, -10, 0, 0)
    Window_Controls.BackgroundTransparency = 1
    Window_Controls.Parent = Top_Bar

    local Controls_Layout = Instance.new("UIListLayout")
    Controls_Layout.FillDirection = Enum.FillDirection.Horizontal
    Controls_Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    Controls_Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Controls_Layout.Padding = UDim.new(0, 8)
    Controls_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Controls_Layout.Parent = Window_Controls

    local function Create_Ctrl_Btn(Type, Order)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 30, 0, 30)
        Btn.BackgroundTransparency = 1
        Btn.Text = ""
        Btn.LayoutOrder = Order
        Btn.Parent = Window_Controls

        local Icon = Instance.new("ImageLabel", Btn)
        Icon.Size = UDim2.new(0, 18, 0, 18)
        Icon.AnchorPoint = Vector2.new(0.5, 0.5)
        Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        Icon.BackgroundTransparency = 1
        Bind_Color(Icon, "ImageColor3", "textDarkColor")

        if Type == "Min" then
            Icon.Image = "rbxassetid://114881903200357"
        elseif Type == "Max" then
            Icon.Image = "rbxassetid://71596577790781"
        elseif Type == "Close" then
            Icon.Image = "rbxassetid://73860578620454"
        end

        Btn.MouseEnter:Connect(function()
            if Type == "Close" then
                Set_Theme_State(Icon, "ImageColor3", "accentColor")
            else
                Set_Theme_State(Icon, "ImageColor3", "textWhiteColor")
            end
        end)
        
        Btn.MouseLeave:Connect(function()
            Set_Theme_State(Icon, "ImageColor3", "textDarkColor")
        end)

        return Btn
    end

    local Min_Btn = Create_Ctrl_Btn("Min", 1)
    local Max_Btn = Create_Ctrl_Btn("Max", 2)
    local Close_Btn = Create_Ctrl_Btn("Close", 3)

    local Sidebar_Width = 180
    local Sidebar_Frame = Instance.new("Frame")
    Sidebar_Frame.Size = UDim2.new(0, Sidebar_Width, 1, -43)
    Sidebar_Frame.Position = UDim2.new(0, 0, 0, 43)
    Sidebar_Frame.BorderSizePixel = 0
    Sidebar_Frame.Parent = Main_Background
    Bind_Color(Sidebar_Frame, "BackgroundColor3", "sidebarBackground")
    Register_Transparency(Sidebar_Frame, 0.21)
    
    local Sidebar_Corner = Instance.new("UICorner")
    Sidebar_Corner.CornerRadius = UDim.new(0, 8)
    Sidebar_Corner.Parent = Sidebar_Frame

    local Sidebar_Hider_Right = Instance.new("Frame")
    Sidebar_Hider_Right.Size = UDim2.new(0, 8, 1, 0)
    Sidebar_Hider_Right.Position = UDim2.new(1, -8, 0, 0)
    Sidebar_Hider_Right.BorderSizePixel = 0
    Sidebar_Hider_Right.Parent = Sidebar_Frame
    Bind_Color(Sidebar_Hider_Right, "BackgroundColor3", "sidebarBackground")
    Register_Transparency(Sidebar_Hider_Right, 0.21)

    local Sidebar_Hider_Top = Instance.new("Frame")
    Sidebar_Hider_Top.Size = UDim2.new(1, 0, 0, 8)
    Sidebar_Hider_Top.BorderSizePixel = 0
    Sidebar_Hider_Top.Parent = Sidebar_Frame
    Bind_Color(Sidebar_Hider_Top, "BackgroundColor3", "sidebarBackground")
    Register_Transparency(Sidebar_Hider_Top, 0.21)

    local Sidebar_Border = Instance.new("Frame")
    Sidebar_Border.Size = UDim2.new(0, 1, 1, 0)
    Sidebar_Border.Position = UDim2.new(1, 0, 0, 0)
    Sidebar_Border.BorderSizePixel = 0
    Sidebar_Border.Parent = Sidebar_Frame
    Bind_Color(Sidebar_Border, "BackgroundColor3", "elementBackground")

    local Tab_Scrolling_Frame = Instance.new("ScrollingFrame")
    Tab_Scrolling_Frame.Size = UDim2.new(1, -12, 1, -70)
    Tab_Scrolling_Frame.Position = UDim2.new(0, 6, 0, 8)
    Tab_Scrolling_Frame.BackgroundTransparency = 1
    Tab_Scrolling_Frame.BorderSizePixel = 0
    Tab_Scrolling_Frame.ScrollBarThickness = 0
    Tab_Scrolling_Frame.Active = true
    Tab_Scrolling_Frame.Parent = Sidebar_Frame

    local Tab_Layout = Instance.new("UIListLayout")
    Tab_Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Tab_Layout.Padding = UDim.new(0, 8)
    Tab_Layout.Parent = Tab_Scrolling_Frame

    local Profile_Button = Instance.new("TextButton")
    Profile_Button.Size = UDim2.new(1, -12, 0, 52)
    Profile_Button.Position = UDim2.new(0, 6, 1, -58)
    Profile_Button.BackgroundTransparency = 1
    Profile_Button.Text = ""
    Profile_Button.AutoButtonColor = false
    Profile_Button.Parent = Sidebar_Frame
    Bind_Color(Profile_Button, "BackgroundColor3", "elementBackground")

    local Profile_Corner = Instance.new("UICorner")
    Profile_Corner.CornerRadius = UDim.new(0, 6)
    Profile_Corner.Parent = Profile_Button

    local Avatar_Img = Instance.new("ImageLabel")
    Avatar_Img.Size = UDim2.new(0, 32, 0, 32)
    Avatar_Img.Position = UDim2.new(0, 10, 0.5, -16)
    Avatar_Img.BackgroundTransparency = 1
    Avatar_Img.Image = "rbxthumb://type=AvatarHeadShot&id=" .. Local_Player.UserId .. "&w=48&h=48"
    Avatar_Img.Parent = Profile_Button
    
    local Av_Corner = Instance.new("UICorner")
    Av_Corner.CornerRadius = UDim.new(1, 0)
    Av_Corner.Parent = Avatar_Img

    local Profile_Name_Label = Instance.new("TextLabel")
    Profile_Name_Label.Size = UDim2.new(1, -52, 0, 16)
    Profile_Name_Label.Position = UDim2.new(0, 50, 0, 10)
    Profile_Name_Label.BackgroundTransparency = 1
    Profile_Name_Label.Text = Local_Player.DisplayName
    Profile_Name_Label.TextSize = 14
    Profile_Name_Label.Font = Bold_Font
    Profile_Name_Label.TextXAlignment = Enum.TextXAlignment.Left
    Profile_Name_Label.TextTruncate = Enum.TextTruncate.AtEnd
    Profile_Name_Label.Parent = Profile_Button
    Bind_Color(Profile_Name_Label, "TextColor3", "textWhiteColor")

    local Profile_Sub_Label = Instance.new("TextLabel")
    Profile_Sub_Label.Size = UDim2.new(1, -52, 0, 14)
    Profile_Sub_Label.Position = UDim2.new(0, 50, 0, 28)
    Profile_Sub_Label.BackgroundTransparency = 1
    Profile_Sub_Label.Text = "Settings"
    Profile_Sub_Label.TextSize = 12
    Profile_Sub_Label.Font = Main_Font
    Profile_Sub_Label.TextXAlignment = Enum.TextXAlignment.Left
    Profile_Sub_Label.Parent = Profile_Button
    Bind_Color(Profile_Sub_Label, "TextColor3", "textDarkColor")

    local Content_Area_Frame = Instance.new("Frame")
    Content_Area_Frame.Size = UDim2.new(1, -(Sidebar_Width + 1), 1, -43)
    Content_Area_Frame.Position = UDim2.new(0, Sidebar_Width + 1, 0, 43)
    Content_Area_Frame.BackgroundTransparency = 1
    Content_Area_Frame.Parent = Main_Background

    local Mobile_Toggle_Button = Instance.new("ImageButton")
    Mobile_Toggle_Button.Size = UDim2.new(0, 56, 0, 56)
    Mobile_Toggle_Button.Position = UDim2.new(0, 20, 0.5, -28)
    Mobile_Toggle_Button.BorderSizePixel = 0
    Mobile_Toggle_Button.ZIndex = 1000
    Mobile_Toggle_Button.Visible = true
    Mobile_Toggle_Button.Image = "rbxassetid://112964043447417"
    Mobile_Toggle_Button.Parent = Screen_Gui
    Bind_Color(Mobile_Toggle_Button, "BackgroundColor3", "elementBackground")
    Bind_Color(Mobile_Toggle_Button, "ImageColor3", "textWhiteColor")

    local Mobile_Toggle_Corner = Instance.new("UICorner")
    Mobile_Toggle_Corner.CornerRadius = UDim.new(1, 0)
    Mobile_Toggle_Corner.Parent = Mobile_Toggle_Button

    local Toggle_Dragging = false
    local Toggle_Drag_Input = nil
    local Toggle_Drag_Start = nil
    local Toggle_Start_Pos = nil
    local Toggle_Target_Pos = Mobile_Toggle_Button.Position

    Mobile_Toggle_Button.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Toggle_Dragging = true
            Toggle_Drag_Start = Input.Position
            Toggle_Start_Pos = Mobile_Toggle_Button.Position
            Toggle_Target_Pos = Toggle_Start_Pos
        end
    end)

    User_Input_Service.InputChanged:Connect(function(Input)
        if Toggle_Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - Toggle_Drag_Start
            Toggle_Target_Pos = UDim2.new(Toggle_Start_Pos.X.Scale, Toggle_Start_Pos.X.Offset + Delta.X, Toggle_Start_Pos.Y.Scale, Toggle_Start_Pos.Y.Offset + Delta.Y)
        end
    end)
    
    User_Input_Service.InputEnded:Connect(function(Input)
        if Toggle_Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Toggle_Dragging = false
        end
    end)

    Run_Service.RenderStepped:Connect(function()
        Mobile_Toggle_Button.Position = Mobile_Toggle_Button.Position:Lerp(Toggle_Target_Pos, 0.4)
    end)

    local Toggle_Click_Time = 0
    Mobile_Toggle_Button.MouseButton1Down:Connect(function()
        Toggle_Click_Time = os.clock()
        Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 50, 0, 50)}, 0.25)
    end)
    
    Mobile_Toggle_Button.MouseButton1Up:Connect(function()
        Animate_Element(Mobile_Toggle_Button, {Size = UDim2.new(0, 56, 0, 56)}, 0.25)
        if os.clock() - Toggle_Click_Time < 0.2 then
            Main_Background.Visible = not Main_Background.Visible
        end
    end)

    local function Update_Responsive_Scale()
        local Vp = Workspace_Service.CurrentCamera.ViewportSize
        if Vp.X < 1 or Vp.Y < 1 then 
            Ui_Scale_Modifier.Scale = 1
            return
        end
        -- Исправленный и более мягкий множитель
        Ui_Scale_Modifier.Scale = math.clamp(Vp.X / 1600, 0.75, 1.2)
    end

    Workspace_Service.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Update_Responsive_Scale)
    Update_Responsive_Scale()

    local Main_Dragging = false
    local Main_Drag_Input = nil
    local Main_Drag_Start = nil
    local Main_Start_Pos = nil
    Library_Api.Instances.MenuTargetPos = Main_Background.Position

    local Is_Minimized = false
    local Is_Maximized = false
    local Normal_Pos = Main_Background.Position

    Top_Bar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Main_Dragging = true
            Main_Drag_Start = Input.Position
            Main_Start_Pos = Main_Background.Position
            Library_Api.Instances.MenuTargetPos = Main_Start_Pos
        end
    end)

    User_Input_Service.InputChanged:Connect(function(Input)
        if Main_Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            local Delta = Input.Position - Main_Drag_Start
            Library_Api.Instances.MenuTargetPos = UDim2.new(Main_Start_Pos.X.Scale, Main_Start_Pos.X.Offset + (Delta.X / Ui_Scale_Modifier.Scale), Main_Start_Pos.Y.Scale, Main_Start_Pos.Y.Offset + (Delta.Y / Ui_Scale_Modifier.Scale))
        end
    end)
    
    User_Input_Service.InputEnded:Connect(function(Input)
        if Main_Dragging and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Main_Dragging = false
            Auto_Save()
        end
    end)

    Run_Service.RenderStepped:Connect(function()
        if Main_Background.Visible then
            Main_Background.Position = Main_Background.Position:Lerp(Library_Api.Instances.MenuTargetPos, 0.4)
        end
    end)

    Min_Btn.MouseButton1Click:Connect(function()
        Is_Minimized = not Is_Minimized
        Sidebar_Frame.Visible = not Is_Minimized
        Content_Area_Frame.Visible = not Is_Minimized
        if Is_Minimized then
            Animate_Element(Main_Background, {Size = UDim2.new(Main_Background.Size.X.Scale, Main_Background.Size.X.Offset, 0, 42)}, 0.3)
        else
            local targetSize = Is_Maximized and UDim2.new(0, 850, 0, 520) or Normal_Size
            Animate_Element(Main_Background, {Size = targetSize}, 0.3)
        end
    end)

    Max_Btn.MouseButton1Click:Connect(function()
        if Is_Minimized then return end
        Is_Maximized = not Is_Maximized
        if Is_Maximized then
            Normal_Pos = Library_Api.Instances.MenuTargetPos
            local Vp = Workspace_Service.CurrentCamera.ViewportSize
            local targetX = math.min(Vp.X / Ui_Scale_Modifier.Scale - 60, 950)
            local targetY = math.min(Vp.Y / Ui_Scale_Modifier.Scale - 60, 600)
            Library_Api.Instances.MenuTargetPos = UDim2.new(0.5, -targetX/2, 0.5, -targetY/2)
            Animate_Element(Main_Background, {Size = UDim2.new(0, targetX, 0, targetY)}, 0.3)
        else
            Library_Api.Instances.MenuTargetPos = Normal_Pos
            Animate_Element(Main_Background, {Size = Normal_Size}, 0.3)
        end
    end)

    Close_Btn.MouseButton1Click:Connect(function()
        Main_Background.Visible = false
    end)

    local Window_Context = { Tabs = {}, Active_Tab = nil }

    function Window_Context:Tab_Create(Tab_Name, Icon_Id)
        local Tab_Data = {}

        local Tab_Button = Instance.new("TextButton")
        Tab_Button.Size = UDim2.new(1, 0, 0, 40)
        Tab_Button.BackgroundTransparency = 1
        Tab_Button.Text = ""
        Tab_Button.AutoButtonColor = false
        Tab_Button.Parent = Tab_Scrolling_Frame
        Bind_Color(Tab_Button, "BackgroundColor3", "elementHoverBackground")
        
        local Button_Corner = Instance.new("UICorner")
        Button_Corner.CornerRadius = UDim.new(0, 6)
        Button_Corner.Parent = Tab_Button

        local Tab_Label = Instance.new("TextLabel")
        Tab_Label.BackgroundTransparency = 1
        Tab_Label.Text = Tab_Name
        Tab_Label.TextSize = 14
        Tab_Label.Font = Main_Font
        Tab_Label.TextXAlignment = Enum.TextXAlignment.Left
        Tab_Label.TextTruncate = Enum.TextTruncate.AtEnd
        Tab_Label.Parent = Tab_Button
        Bind_Color(Tab_Label, "TextColor3", "textDarkColor")

        if Icon_Id and Icon_Id ~= "" then
            local Tab_Icon = Instance.new("ImageLabel")
            Tab_Icon.Size = UDim2.new(0, 18, 0, 18)
            Tab_Icon.Position = UDim2.new(0, 12, 0.5, -9)
            Tab_Icon.BackgroundTransparency = 1
            Tab_Icon.Image = Icon_Id
            Tab_Icon.Parent = Tab_Button
            Bind_Color(Tab_Icon, "ImageColor3", "textDarkColor")
            Tab_Data.Icon = Tab_Icon
            Tab_Label.Position = UDim2.new(0, 38, 0, 0)
            Tab_Label.Size = UDim2.new(1, -44, 1, 0)
        else
            Tab_Label.Position = UDim2.new(0, 14, 0, 0)
            Tab_Label.Size = UDim2.new(1, -20, 1, 0)
        end

        local Tab_Indicator = Instance.new("Frame")
        Tab_Indicator.Size = UDim2.new(0, 4, 0, 0)
        Tab_Indicator.Position = UDim2.new(0, 0, 0.5, 0)
        Tab_Indicator.BorderSizePixel = 0
        Tab_Indicator.Parent = Tab_Button
        Bind_Color(Tab_Indicator, "BackgroundColor3", "accentColor")
        
        local Indicator_Corner = Instance.new("UICorner")
        Indicator_Corner.CornerRadius = UDim.new(0, 2)
        Indicator_Corner.Parent = Tab_Indicator

        local Page_Scrolling_Frame = Instance.new("ScrollingFrame")
        Page_Scrolling_Frame.Size = UDim2.new(1, 0, 1, 0)
        Page_Scrolling_Frame.BackgroundTransparency = 1
        Page_Scrolling_Frame.BorderSizePixel = 0
        Page_Scrolling_Frame.ScrollBarThickness = 2
        Page_Scrolling_Frame.Active = true
        Page_Scrolling_Frame.Visible = false
        Page_Scrolling_Frame.Parent = Content_Area_Frame
        Bind_Color(Page_Scrolling_Frame, "ScrollBarImageColor3", "accentColor")

        local Left_Column_Frame = Instance.new("Frame")
        Left_Column_Frame.Size = UDim2.new(0.5, -14, 1, 0)
        Left_Column_Frame.Position = UDim2.new(0, 10, 0, 10)
        Left_Column_Frame.BackgroundTransparency = 1
        Left_Column_Frame.Parent = Page_Scrolling_Frame

        local Right_Column_Frame = Instance.new("Frame")
        Right_Column_Frame.Size = UDim2.new(0.5, -14, 1, 0)
        Right_Column_Frame.Position = UDim2.new(0.5, 4, 0, 10)
        Right_Column_Frame.BackgroundTransparency = 1
        Right_Column_Frame.Parent = Page_Scrolling_Frame

        local Left_Column_Layout = Instance.new("UIListLayout")
        Left_Column_Layout.Padding = UDim.new(0, 10)
        Left_Column_Layout.Parent = Left_Column_Frame

        local Right_Column_Layout = Instance.new("UIListLayout")
        Right_Column_Layout.Padding = UDim.new(0, 10)
        Right_Column_Layout.Parent = Right_Column_Frame

        local function Update_Canvas()
            local Max_Column_Height = math.max(Left_Column_Layout.AbsoluteContentSize.Y, Right_Column_Layout.AbsoluteContentSize.Y)
            Animate_Element(Page_Scrolling_Frame, {CanvasSize = UDim2.new(0, 0, 0, Max_Column_Height + 35)}, 0.25)
        end

        Left_Column_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas)
        Right_Column_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas)

        Tab_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Animate_Element(Tab_Scrolling_Frame, {CanvasSize = UDim2.new(0, 0, 0, Tab_Layout.AbsoluteContentSize.Y + 15)}, 0.25)
        end)

        function Tab_Data:Activate()
            if Window_Context.Active_Tab == Tab_Data then return end
            if Window_Context.Active_Tab then
                Animate_Element(Window_Context.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.25)
                Set_Theme_State(Window_Context.Active_Tab.Lbl, "TextColor3", "textDarkColor")
                Animate_Element(Window_Context.Active_Tab.Ind, {Size = UDim2.new(0, 4, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.25)
                Window_Context.Active_Tab.Page.Visible = false
            end
            
            if Tab_Name ~= "Settings" then
                Animate_Element(Profile_Button, {BackgroundTransparency = 1}, 0.25)
            end

            Window_Context.Active_Tab = Tab_Data
            Page_Scrolling_Frame.Visible = true
            Animate_Element(Tab_Button, {BackgroundTransparency = 0.11}, 0.25)
            Set_Theme_State(Tab_Label, "TextColor3", "textWhiteColor")
            Animate_Element(Tab_Indicator, {Size = UDim2.new(0, 4, 0, 24), Position = UDim2.new(0, 0, 0.5, -12)}, 0.25)
        end

        Tab_Button.MouseButton1Click:Connect(function() Tab_Data:Activate() end)

        Tab_Data.Btn = Tab_Button
        Tab_Data.Lbl = Tab_Label
        Tab_Data.Ind = Tab_Indicator
        Tab_Data.Page = Page_Scrolling_Frame

        table.insert(Window_Context.Tabs, Tab_Data)
        if #Window_Context.Tabs == 1 then Tab_Data:Activate() end

        local function Element_Injector(Target_Container)
            local Elements = {}

            function Elements:Label_Create(Name, Initial_Value)
                local Label_Bg = Instance.new("Frame")
                Label_Bg.Size = UDim2.new(1, 0, 0, 30)
                Label_Bg.Parent = Target_Container
                Bind_Color(Label_Bg, "BackgroundColor3", "elementBackground")
                Register_Transparency(Label_Bg, 0.21)

                local Label_Corner = Instance.new("UICorner")
                Label_Corner.CornerRadius = UDim.new(0, 6)
                Label_Corner.Parent = Label_Bg

                local Title_Label = Instance.new("TextLabel")
                Title_Label.Size = UDim2.new(0.5, 0, 1, 0)
                Title_Label.Position = UDim2.new(0, 10, 0, 0)
                Title_Label.BackgroundTransparency = 1
                Title_Label.Text = Name
                Title_Label.TextSize = 14
                Title_Label.Font = Main_Font
                Title_Label.TextXAlignment = Enum.TextXAlignment.Left
                Title_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Title_Label.Parent = Label_Bg
                Bind_Color(Title_Label, "TextColor3", "textDarkColor")

                local Value_Label = Instance.new("TextLabel")
                Value_Label.AnchorPoint = Vector2.new(1, 0)
                Value_Label.Size = UDim2.new(0.5, -10, 1, 0)
                Value_Label.Position = UDim2.new(1, -10, 0, 0)
                Value_Label.BackgroundTransparency = 1
                Value_Label.Text = Initial_Value or ""
                Value_Label.TextSize = 14
                Value_Label.Font = Bold_Font
                Value_Label.TextXAlignment = Enum.TextXAlignment.Right
                Value_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Value_Label.Parent = Label_Bg
                Bind_Color(Value_Label, "TextColor3", "textWhiteColor")

                local Api = {}
                function Api:Set(Text)
                    Value_Label.Text = tostring(Text)
                end
                return Api
            end

            function Elements:Subtext_Create(Text)
                local Subtext_Label = Instance.new("TextLabel")
                Subtext_Label.Size = UDim2.new(1, -14, 0, 18)
                Subtext_Label.BackgroundTransparency = 1
                Subtext_Label.Text = Text
                Subtext_Label.TextSize = 13
                Subtext_Label.Font = Main_Font
                Subtext_Label.TextXAlignment = Enum.TextXAlignment.Left
                Subtext_Label.TextWrapped = true
                Subtext_Label.Parent = Target_Container
                Bind_Color(Subtext_Label, "TextColor3", "textDarkColor")
            end

            function Elements:Toggle_Create(Name, Flag, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or false)

                local Toggle_Button = Instance.new("TextButton")
                Toggle_Button.Size = UDim2.new(1, 0, 0, 24)
                Toggle_Button.BackgroundTransparency = 1
                Toggle_Button.Text = ""
                Toggle_Button.Parent = Target_Container

                local Checkbox_Frame = Instance.new("Frame")
                Checkbox_Frame.Size = UDim2.new(0, 20, 0, 20)
                Checkbox_Frame.Position = UDim2.new(0, 2, 0.5, -10)
                Checkbox_Frame.Parent = Toggle_Button
                Bind_Color(Checkbox_Frame, "BackgroundColor3", "elementBackground")
                Register_Transparency(Checkbox_Frame, 0.21)
                
                local Checkbox_Corner = Instance.new("UICorner")
                Checkbox_Corner.CornerRadius = UDim.new(0, 4)
                Checkbox_Corner.Parent = Checkbox_Frame

                local Toggle_Label = Instance.new("TextLabel")
                Toggle_Label.Size = UDim2.new(1, -32, 1, 0)
                Toggle_Label.Position = UDim2.new(0, 30, 0, 0)
                Toggle_Label.BackgroundTransparency = 1
                Toggle_Label.Text = Name
                Toggle_Label.TextSize = 14
                Toggle_Label.Font = Main_Font
                Toggle_Label.TextXAlignment = Enum.TextXAlignment.Left
                Toggle_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Toggle_Label.Parent = Toggle_Button
                Bind_Color(Toggle_Label, "TextColor3", "textDarkColor")

                Library_Api.Registry[Flag] = function(New_State)
                    Library_Api.Flags[Flag] = New_State
                    Set_Theme_State(Checkbox_Frame, "BackgroundColor3", New_State and "accentColor" or "elementBackground")
                    Set_Theme_State(Toggle_Label, "TextColor3", New_State and "textWhiteColor" or "textDarkColor")
                    if type(Callback) == "function" then task.spawn(Callback, New_State) end
                end

                Toggle_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Frame, {BackgroundTransparency = 0.1}, 0.2) end
                end)
                Toggle_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Library_Api.Flags[Flag] then Animate_Element(Checkbox_Frame, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2) end
                end)

                Toggle_Button.MouseButton1Click:Connect(function()
                    Library_Api.Flags[Flag] = not Library_Api.Flags[Flag]
                    Library_Api.Registry[Flag](Library_Api.Flags[Flag])
                    Auto_Save()
                end)
                
                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
            end

            function Elements:Slider_Create(Name, Flag, Min, Max, Default, Step, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or Snap_Value(Default or Min, Step)

                local Slider_Frame = Instance.new("Frame")
                Slider_Frame.Size = UDim2.new(1, 0, 0, 42)
                Slider_Frame.BackgroundTransparency = 1
                Slider_Frame.Parent = Target_Container

                local Slider_Label = Instance.new("TextLabel")
                Slider_Label.Size = UDim2.new(1, -70, 0, 18)
                Slider_Label.Position = UDim2.new(0, 2, 0, 0)
                Slider_Label.BackgroundTransparency = 1
                Slider_Label.Text = Name
                Slider_Label.TextSize = 14
                Slider_Label.Font = Main_Font
                Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Slider_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Slider_Label.Parent = Slider_Frame
                Bind_Color(Slider_Label, "TextColor3", "textWhiteColor")

                local Value_Text_Box = Instance.new("TextBox")
                Value_Text_Box.AnchorPoint = Vector2.new(1, 0)
                Value_Text_Box.Size = UDim2.new(0, 60, 0, 18)
                Value_Text_Box.Position = UDim2.new(1, -4, 0, 0)
                Value_Text_Box.BackgroundTransparency = 1
                Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
                Value_Text_Box.TextSize = 14
                Value_Text_Box.Font = Main_Font
                Value_Text_Box.TextXAlignment = Enum.TextXAlignment.Right
                Value_Text_Box.ClearTextOnFocus = false
                Value_Text_Box.Parent = Slider_Frame
                Bind_Color(Value_Text_Box, "TextColor3", "textWhiteColor")

                local function UpdateValSize(text)
                    local w = GetTextWidth(text, 14, Main_Font)
                    w = math.max(40, w + 12)
                    Value_Text_Box.Size = UDim2.new(0, w, 0, 18)
                    Slider_Label.Size = UDim2.new(1, -(w + 20), 0, 18)
                end

                local Slider_Background = Instance.new("TextButton")
                Slider_Background.Size = UDim2.new(1, -4, 0, 10)
                Slider_Background.Position = UDim2.new(0, 2, 0, 26)
                Slider_Background.Text = ""
                Slider_Background.AutoButtonColor = false
                Slider_Background.Parent = Slider_Frame
                Bind_Color(Slider_Background, "BackgroundColor3", "elementBackground")
                Register_Transparency(Slider_Background, 0.21)
                
                local Slider_Background_Corner = Instance.new("UICorner")
                Slider_Background_Corner.CornerRadius = UDim.new(0, 5)
                Slider_Background_Corner.Parent = Slider_Background

                local Slider_Fill = Instance.new("Frame")
                Slider_Fill.Size = UDim2.new(0, 0, 1, 0)
                Slider_Fill.Parent = Slider_Background
                Bind_Color(Slider_Fill, "BackgroundColor3", "accentColor")
                
                local Slider_Fill_Corner = Instance.new("UICorner")
                Slider_Fill_Corner.CornerRadius = UDim.new(0, 5)
                Slider_Fill_Corner.Parent = Slider_Fill

                local Slider_Knob = Instance.new("Frame")
                Slider_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Slider_Knob.Size = UDim2.new(0, 16, 0, 16)
                Slider_Knob.ZIndex = 2
                Slider_Knob.Parent = Slider_Background
                Bind_Color(Slider_Knob, "BackgroundColor3", "textWhiteColor")
                local Slider_Knob_Corner = Instance.new("UICorner"); Slider_Knob_Corner.CornerRadius = UDim.new(1, 0); Slider_Knob_Corner.Parent = Slider_Knob

                Library_Api.Registry[Flag] = function(New_Value)
                    local Clamped_Value = math.clamp(New_Value, Min, Max)
                    local Snapped_Value = Snap_Value(Clamped_Value, Step)
                    Library_Api.Flags[Flag] = Snapped_Value
                    local Denominator = Max - Min
                    if Denominator == 0 then Denominator = 1 end
                    local Percentage = (Snapped_Value - Min) / Denominator
                    local formatStr = Format_Value(Snapped_Value, Step)
                    Animate_Element(Slider_Fill, {Size = UDim2.new(Percentage, 0, 1, 0)}, 0.15)
                    Animate_Element(Slider_Knob, {Position = UDim2.new(Percentage, 0, 0.5, 0)}, 0.15)
                    Value_Text_Box.Text = formatStr
                    UpdateValSize(formatStr)
                    if type(Callback) == "function" then task.spawn(Callback, Snapped_Value) end
                end

                Slider_Background.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Slider_Background, {BackgroundTransparency = 0.1}, 0.2)
                end)
                Slider_Background.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Slider_Background, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2)
                end)

                local Dragging_Slider = false

                local function Update_Slider(Input)
                    local Percentage = math.clamp((Input.Position.X - Slider_Background.AbsolutePosition.X) / Slider_Background.AbsoluteSize.X, 0, 1)
                    Library_Api.Registry[Flag](Min + ((Max - Min) * Percentage))
                end

                Slider_Background.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging_Slider = true
                        Update_Slider(Input)
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if Dragging_Slider and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        Update_Slider(Input)
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Dragging_Slider and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                        Dragging_Slider = false
                        Auto_Save()
                    end
                end)

                Value_Text_Box.FocusLost:Connect(function()
                    local Input_Value = tonumber(Value_Text_Box.Text)
                    if Input_Value then
                        Library_Api.Registry[Flag](Input_Value)
                        Auto_Save()
                    else
                        Value_Text_Box.Text = Format_Value(Library_Api.Flags[Flag], Step)
                    end
                end)
                
                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
            end

            function Elements:RangeSlider_Create(Name, Flag, Min, Max, Default_Min, Default_Max, Step, Tooltip, Callback)
                if type(Library_Api.Flags[Flag]) ~= "table" then
                    Library_Api.Flags[Flag] = {Min = Snap_Value(Default_Min or Min, Step), Max = Snap_Value(Default_Max or Max, Step)}
                end

                local Range_Slider_Frame = Instance.new("Frame")
                Range_Slider_Frame.Size = UDim2.new(1, 0, 0, 42)
                Range_Slider_Frame.BackgroundTransparency = 1
                Range_Slider_Frame.Parent = Target_Container

                local Range_Slider_Label = Instance.new("TextLabel")
                Range_Slider_Label.Size = UDim2.new(1, -120, 0, 18)
                Range_Slider_Label.Position = UDim2.new(0, 2, 0, 0)
                Range_Slider_Label.BackgroundTransparency = 1
                Range_Slider_Label.Text = Name
                Range_Slider_Label.TextSize = 14
                Range_Slider_Label.Font = Main_Font
                Range_Slider_Label.TextXAlignment = Enum.TextXAlignment.Left
                Range_Slider_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Range_Slider_Label.Parent = Range_Slider_Frame
                Bind_Color(Range_Slider_Label, "TextColor3", "textWhiteColor")

                local Value_Label = Instance.new("TextLabel")
                Value_Label.AnchorPoint = Vector2.new(1, 0)
                Value_Label.Size = UDim2.new(0, 110, 0, 18)
                Value_Label.Position = UDim2.new(1, -4, 0, 0)
                Value_Label.BackgroundTransparency = 1
                Value_Label.Text = ""
                Value_Label.TextSize = 14
                Value_Label.Font = Main_Font
                Value_Label.TextXAlignment = Enum.TextXAlignment.Right
                Value_Label.Parent = Range_Slider_Frame
                Bind_Color(Value_Label, "TextColor3", "textWhiteColor")

                local function UpdateValSize(text)
                    local w = GetTextWidth(text, 14, Main_Font)
                    w = math.max(70, w + 12)
                    Value_Label.Size = UDim2.new(0, w, 0, 18)
                    Range_Slider_Label.Size = UDim2.new(1, -(w + 20), 0, 18)
                end

                local Range_Slider_Background = Instance.new("TextButton")
                Range_Slider_Background.Size = UDim2.new(1, -4, 0, 10)
                Range_Slider_Background.Position = UDim2.new(0, 2, 0, 26)
                Range_Slider_Background.Text = ""
                Range_Slider_Background.AutoButtonColor = false
                Range_Slider_Background.Parent = Range_Slider_Frame
                Bind_Color(Range_Slider_Background, "BackgroundColor3", "elementBackground")
                Register_Transparency(Range_Slider_Background, 0.21)
                
                local Range_Slider_Background_Corner = Instance.new("UICorner")
                Range_Slider_Background_Corner.CornerRadius = UDim.new(0, 5)
                Range_Slider_Background_Corner.Parent = Range_Slider_Background

                local Range_Slider_Fill = Instance.new("Frame")
                Range_Slider_Fill.Parent = Range_Slider_Background
                Bind_Color(Range_Slider_Fill, "BackgroundColor3", "accentColor")
                
                local Range_Slider_Fill_Corner = Instance.new("UICorner")
                Range_Slider_Fill_Corner.CornerRadius = UDim.new(0, 5)
                Range_Slider_Fill_Corner.Parent = Range_Slider_Fill

                local Min_Range_Knob = Instance.new("Frame")
                Min_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Min_Range_Knob.Size = UDim2.new(0, 16, 0, 16)
                Min_Range_Knob.ZIndex = 2
                Min_Range_Knob.Parent = Range_Slider_Background
                Bind_Color(Min_Range_Knob, "BackgroundColor3", "textWhiteColor")
                local Min_Range_Knob_Corner = Instance.new("UICorner"); Min_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Min_Range_Knob_Corner.Parent = Min_Range_Knob

                local Max_Range_Knob = Instance.new("Frame")
                Max_Range_Knob.AnchorPoint = Vector2.new(0.5, 0.5)
                Max_Range_Knob.Size = UDim2.new(0, 16, 0, 16)
                Max_Range_Knob.ZIndex = 2
                Max_Range_Knob.Parent = Range_Slider_Background
                Bind_Color(Max_Range_Knob, "BackgroundColor3", "textWhiteColor")
                local Max_Range_Knob_Corner = Instance.new("UICorner"); Max_Range_Knob_Corner.CornerRadius = UDim.new(1, 0); Max_Range_Knob_Corner.Parent = Max_Range_Knob

                Library_Api.Registry[Flag] = function(New_Range)
                    local current = type(New_Range) == "table" and New_Range or {Min = Min, Max = Max}
                    Library_Api.Flags[Flag].Min = math.clamp(current.Min, Min, Max)
                    Library_Api.Flags[Flag].Max = math.clamp(current.Max, Min, Max)
                    local Denominator = Max - Min
                    if Denominator == 0 then Denominator = 1 end
                    local Min_Percentage = (Library_Api.Flags[Flag].Min - Min) / Denominator
                    local Max_Percentage = (Library_Api.Flags[Flag].Max - Min) / Denominator
                    local formatStr = Format_Value(Library_Api.Flags[Flag].Min, Step) .. " - " .. Format_Value(Library_Api.Flags[Flag].Max, Step)
                    Animate_Element(Range_Slider_Fill, {Position = UDim2.new(Min_Percentage, 0, 0, 0), Size = UDim2.new(Max_Percentage - Min_Percentage, 0, 1, 0)}, 0.15)
                    Animate_Element(Min_Range_Knob, {Position = UDim2.new(Min_Percentage, 0, 0.5, 0)}, 0.15)
                    Animate_Element(Max_Range_Knob, {Position = UDim2.new(Max_Percentage, 0, 0.5, 0)}, 0.15)
                    Value_Label.Text = formatStr
                    UpdateValSize(formatStr)
                    if type(Callback) == "function" then task.spawn(Callback, Library_Api.Flags[Flag]) end
                end

                Range_Slider_Background.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Range_Slider_Background, {BackgroundTransparency = 0.1}, 0.2)
                end)
                Range_Slider_Background.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Range_Slider_Background, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2)
                end)

                local Is_Sliding_Min = false
                local Is_Sliding_Max = false

                Range_Slider_Background.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        local Mouse_X = Input.Position.X
                        local Denominator = Max - Min
                        if Denominator == 0 then Denominator = 1 end
                        local Min_Percentage = (Library_Api.Flags[Flag].Min - Min) / Denominator
                        local Max_Percentage = (Library_Api.Flags[Flag].Max - Min) / Denominator
                        local Min_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Min_Percentage)
                        local Max_Knob_Position = Range_Slider_Background.AbsolutePosition.X + (Range_Slider_Background.AbsoluteSize.X * Max_Percentage)
                        
                        if math.abs(Mouse_X - Min_Knob_Position) < math.abs(Mouse_X - Max_Knob_Position) then
                            Is_Sliding_Min = true
                        else
                            Is_Sliding_Max = true
                        end
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if (Is_Sliding_Min or Is_Sliding_Max) and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                        local Percentage = math.clamp((Input.Position.X - Range_Slider_Background.AbsolutePosition.X) / Range_Slider_Background.AbsoluteSize.X, 0, 1)
                        local Calculated_Value = Snap_Value(Min + ((Max - Min) * Percentage), Step)
                        
                        local tempRange = {Min = Library_Api.Flags[Flag].Min, Max = Library_Api.Flags[Flag].Max}
                        if Is_Sliding_Min then
                            tempRange.Min = math.clamp(Calculated_Value, Min, tempRange.Max)
                        elseif Is_Sliding_Max then
                            tempRange.Max = math.clamp(Calculated_Value, tempRange.Min, Max)
                        end
                        Library_Api.Registry[Flag](tempRange)
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if (Is_Sliding_Min or Is_Sliding_Max) and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
                        Is_Sliding_Min = false
                        Is_Sliding_Max = false
                        Auto_Save()
                    end
                end)

                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
            end

            function Elements:Textbox_Create(Name, Flag, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or "")

                local Textbox_Frame = Instance.new("Frame")
                Textbox_Frame.Size = UDim2.new(1, 0, 0, 42)
                Textbox_Frame.BackgroundTransparency = 1
                Textbox_Frame.Parent = Target_Container

                local labelWidth = GetTextWidth(Name, 14, Main_Font)
                labelWidth = math.clamp(labelWidth + 12, 60, 180)

                local Textbox_Label = Instance.new("TextLabel")
                Textbox_Label.Size = UDim2.new(0, labelWidth, 1, 0)
                Textbox_Label.Position = UDim2.new(0, 2, 0, 0)
                Textbox_Label.BackgroundTransparency = 1
                Textbox_Label.Text = Name
                Textbox_Label.TextSize = 14
                Textbox_Label.Font = Main_Font
                Textbox_Label.TextXAlignment = Enum.TextXAlignment.Left
                Textbox_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Textbox_Label.Parent = Textbox_Frame
                Bind_Color(Textbox_Label, "TextColor3", "textWhiteColor")

                local Textbox_Input_Background = Instance.new("Frame")
                Textbox_Input_Background.AnchorPoint = Vector2.new(1, 0.5)
                Textbox_Input_Background.Size = UDim2.new(1, -(labelWidth + 18), 0, 30)
                Textbox_Input_Background.Position = UDim2.new(1, -4, 0.5, 0)
                Textbox_Input_Background.Parent = Textbox_Frame
                Bind_Color(Textbox_Input_Background, "BackgroundColor3", "elementBackground")
                Register_Transparency(Textbox_Input_Background, 0.21)
                
                local Textbox_Input_Background_Corner = Instance.new("UICorner")
                Textbox_Input_Background_Corner.CornerRadius = UDim.new(0, 6)
                Textbox_Input_Background_Corner.Parent = Textbox_Input_Background

                local Input_Text_Box = Instance.new("TextBox")
                Input_Text_Box.Size = UDim2.new(1, -16, 1, 0)
                Input_Text_Box.Position = UDim2.new(0, 8, 0, 0)
                Input_Text_Box.BackgroundTransparency = 1
                Input_Text_Box.Text = ""
                Input_Text_Box.TextSize = 14
                Input_Text_Box.Font = Main_Font
                Input_Text_Box.ClearTextOnFocus = false
                Input_Text_Box.TextXAlignment = Enum.TextXAlignment.Left
                Input_Text_Box.ClipsDescendants = true
                Input_Text_Box.Parent = Textbox_Input_Background
                Bind_Color(Input_Text_Box, "TextColor3", "textDarkColor")

                Library_Api.Registry[Flag] = function(New_Text)
                    Library_Api.Flags[Flag] = New_Text
                    Input_Text_Box.Text = tostring(New_Text)
                    if type(Callback) == "function" then task.spawn(Callback, New_Text) end
                end

                Input_Text_Box.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Input_Text_Box:IsFocused() then Animate_Element(Textbox_Input_Background, {BackgroundTransparency = 0.1}, 0.2) end
                end)
                Input_Text_Box.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Input_Text_Box:IsFocused() then Animate_Element(Textbox_Input_Background, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2) end
                end)

                Input_Text_Box.Focused:Connect(function()
                    Set_Theme_State(Input_Text_Box, "TextColor3", "textWhiteColor")
                end)

                Input_Text_Box.FocusLost:Connect(function()
                    Set_Theme_State(Input_Text_Box, "TextColor3", "textDarkColor")
                    Library_Api.Registry[Flag](Input_Text_Box.Text)
                    Auto_Save()
                end)

                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
            end

            function Elements:Keybind_Create(Name, Flag, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Enum.KeyCode.Unknown)
                Library_Api.Keybind_Names[Flag] = Name
                local Is_Listening = false

                local Keybind_Frame = Instance.new("Frame")
                Keybind_Frame.Size = UDim2.new(1, 0, 0, 36)
                Keybind_Frame.BackgroundTransparency = 1
                Keybind_Frame.Parent = Target_Container

                local Keybind_Icon = Instance.new("ImageLabel")
                Keybind_Icon.Size = UDim2.new(0, 18, 0, 18)
                Keybind_Icon.Position = UDim2.new(0, 2, 0.5, -9)
                Keybind_Icon.BackgroundTransparency = 1
                Keybind_Icon.Image = "rbxassetid://127939607767683"
                Keybind_Icon.Parent = Keybind_Frame
                Bind_Color(Keybind_Icon, "ImageColor3", "textDarkColor")

                local Keybind_Label = Instance.new("TextLabel")
                Keybind_Label.Size = UDim2.new(1, -120, 1, 0)
                Keybind_Label.Position = UDim2.new(0, 28, 0, 0)
                Keybind_Label.BackgroundTransparency = 1
                Keybind_Label.Text = Name
                Keybind_Label.TextSize = 14
                Keybind_Label.Font = Main_Font
                Keybind_Label.TextXAlignment = Enum.TextXAlignment.Left
                Keybind_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Keybind_Label.Parent = Keybind_Frame
                Bind_Color(Keybind_Label, "TextColor3", "textWhiteColor")

                local Keybind_Button = Instance.new("TextButton")
                Keybind_Button.AnchorPoint = Vector2.new(1, 0.5)
                Keybind_Button.Size = UDim2.new(0, 80, 0, 26)
                Keybind_Button.Position = UDim2.new(1, -4, 0.5, 0)
                Keybind_Button.Text = ""
                Keybind_Button.TextSize = 13
                Keybind_Button.Font = Bold_Font
                Keybind_Button.AutoButtonColor = false
                Keybind_Button.Parent = Keybind_Frame
                Bind_Color(Keybind_Button, "BackgroundColor3", "elementBackground")
                Register_Transparency(Keybind_Button, 0.21)
                Bind_Color(Keybind_Button, "TextColor3", "textDarkColor")

                local Keybind_Button_Corner = Instance.new("UICorner")
                Keybind_Button_Corner.CornerRadius = UDim.new(0, 6)
                Keybind_Button_Corner.Parent = Keybind_Button

                local function UpdateKeybindSize(text)
                    local w = GetTextWidth(text, 13, Bold_Font)
                    w = math.clamp(w + 24, 60, 140)
                    Animate_Element(Keybind_Button, {Size = UDim2.new(0, w, 0, 26)}, 0.2)
                    Keybind_Label.Size = UDim2.new(1, -(w + 40), 1, 0)
                end

                Library_Api.Registry[Flag] = function(New_Bind)
                    Library_Api.Flags[Flag] = New_Bind
                    local bindStr = "[ " .. Get_Input_Name(New_Bind) .. " ]"
                    Keybind_Button.Text = bindStr
                    UpdateKeybindSize(bindStr)
                    Library_Api:RefreshKeybinds()
                end

                Keybind_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Listening then Animate_Element(Keybind_Button, {BackgroundTransparency = 0.1}, 0.2) end
                end)
                Keybind_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Listening then Animate_Element(Keybind_Button, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2) end
                end)

                Keybind_Button.MouseButton1Click:Connect(function()
                    Is_Listening = true
                    Keybind_Button.Text = "[ ... ]"
                    UpdateKeybindSize("[ ... ]")
                    Set_Theme_State(Keybind_Button, "TextColor3", "textWhiteColor")
                end)

                User_Input_Service.InputBegan:Connect(function(Input, gameProcessed)
                    if Is_Listening then
                        local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
                        if Key ~= Enum.KeyCode.Unknown and not (Input.UserInputType == Enum.UserInputType.MouseMovement) then
                            if Key == Enum.KeyCode.Escape then
                                Library_Api.Registry[Flag](Enum.KeyCode.Unknown)
                            else
                                Library_Api.Registry[Flag](Key)
                            end
                            Is_Listening = false
                            Set_Theme_State(Keybind_Button, "TextColor3", "textDarkColor")
                            Auto_Save()
                        end
                    else
                        if gameProcessed then return end
                        local Key = Input.KeyCode == Enum.KeyCode.Unknown and Input.UserInputType or Input.KeyCode
                        if Key == Library_Api.Flags[Flag] and Key ~= Enum.KeyCode.Unknown then
                            if type(Callback) == "function" then task.spawn(Callback, Library_Api.Flags[Flag]) end
                        end
                    end
                end)

                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
            end

            function Elements:Dropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
                Options = type(Options) == "table" and Options or {"None"}
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or Options[1])
                local Is_Dropdown_Open = false

                local Dropdown_Frame = Instance.new("Frame")
                Dropdown_Frame.Size = UDim2.new(1, 0, 0, 56)
                Dropdown_Frame.BackgroundTransparency = 1
                Dropdown_Frame.ClipsDescendants = true
                Dropdown_Frame.ZIndex = 5
                Dropdown_Frame.Parent = Target_Container

                local Dropdown_Label = Instance.new("TextLabel")
                Dropdown_Label.Size = UDim2.new(1, -10, 0, 20)
                Dropdown_Label.Position = UDim2.new(0, 2, 0, 0)
                Dropdown_Label.BackgroundTransparency = 1
                Dropdown_Label.Text = Name
                Dropdown_Label.TextSize = 14
                Dropdown_Label.Font = Main_Font
                Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Dropdown_Label.Parent = Dropdown_Frame
                Bind_Color(Dropdown_Label, "TextColor3", "textWhiteColor")

                local Dropdown_Main_Button = Instance.new("TextButton")
                Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 32)
                Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 22)
                Dropdown_Main_Button.Text = ""
                Dropdown_Main_Button.AutoButtonColor = false
                Dropdown_Main_Button.Parent = Dropdown_Frame
                Bind_Color(Dropdown_Main_Button, "BackgroundColor3", "elementBackground")
                Register_Transparency(Dropdown_Main_Button, 0.21)
                
                local Dropdown_Main_Button_Corner = Instance.new("UICorner")
                Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 6)
                Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button

                local Selected_Option_Label = Instance.new("TextLabel")
                Selected_Option_Label.Size = UDim2.new(1, -40, 1, 0)
                Selected_Option_Label.Position = UDim2.new(0, 12, 0, 0)
                Selected_Option_Label.BackgroundTransparency = 1
                Selected_Option_Label.Text = ""
                Selected_Option_Label.TextSize = 14
                Selected_Option_Label.Font = Main_Font
                Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                Selected_Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Selected_Option_Label.Parent = Dropdown_Main_Button
                Bind_Color(Selected_Option_Label, "TextColor3", "textDarkColor")

                local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
                Dropdown_Arrow_Icon.Size = UDim2.new(0, 18, 0, 18)
                Dropdown_Arrow_Icon.Position = UDim2.new(1, -26, 0.5, -9)
                Dropdown_Arrow_Icon.BackgroundTransparency = 1
                Dropdown_Arrow_Icon.Image = "rbxassetid://10492813580"
                Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button
                Bind_Color(Dropdown_Arrow_Icon, "ImageColor3", "textDarkColor")

                local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
                Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
                Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 58)
                Dropdown_Option_List_Frame.BorderSizePixel = 0
                Dropdown_Option_List_Frame.ScrollBarThickness = 2
                Dropdown_Option_List_Frame.ClipsDescendants = true
                Dropdown_Option_List_Frame.Active = true
                Dropdown_Option_List_Frame.ZIndex = 10
                Dropdown_Option_List_Frame.Parent = Dropdown_Frame
                Bind_Color(Dropdown_Option_List_Frame, "BackgroundColor3", "elementBackground")
                Bind_Color(Dropdown_Option_List_Frame, "ScrollBarImageColor3", "accentColor")
                Register_Transparency(Dropdown_Option_List_Frame, 0.21)
                
                local Dropdown_Option_List_Corner = Instance.new("UICorner")
                Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 6)
                Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame

                local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
                Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Dropdown_Option_List_Layout.Padding = UDim.new(0, 4)
                Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

                local function Toggle_Dropdown_State()
                    Is_Dropdown_Open = not Is_Dropdown_Open
                    local Max_List_Height = math.min(#Options * 28 + (#Options * 4), 160)
                    local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
                    Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0}, 0.25)
                    Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.25)
                    Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 56 + Target_List_Height + (Is_Dropdown_Open and 6 or 0))}, 0.25)
                end

                Dropdown_Main_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button, {BackgroundTransparency = 0.1}, 0.2) end
                end)
                Dropdown_Main_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2) end
                end)
                Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

                local function Render_Options()
                    for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child:IsA("TextButton") then Child:Destroy() end
                    end
                    for _, Option in ipairs(Options) do
                        local Option_Button = Instance.new("TextButton")
                        Option_Button.Size = UDim2.new(1, 0, 0, 28)
                        Option_Button.BackgroundTransparency = 1
                        Option_Button.Text = ""
                        Option_Button.ZIndex = 11
                        Option_Button.Parent = Dropdown_Option_List_Frame
                        Bind_Color(Option_Button, "BackgroundColor3", "elementHoverBackground")

                        local Option_Label = Instance.new("TextLabel")
                        Option_Label.Size = UDim2.new(1, -24, 1, 0)
                        Option_Label.Position = UDim2.new(0, 12, 0, 0)
                        Option_Label.BackgroundTransparency = 1
                        Option_Label.Text = Option
                        Option_Label.TextSize = 14
                        Option_Label.Font = Main_Font
                        Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                        Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
                        Option_Label.ZIndex = 11
                        Option_Label.Parent = Option_Button
                        
                        table.insert(Library_Api.Theme_Objects, {Obj = Option_Label, Prop = "TextColor3", Key = (Library_Api.Flags[Flag] == Option and "accentColor" or "textDarkColor")})
                        Option_Label.TextColor3 = Themes[Library_Api.Current_Theme][(Library_Api.Flags[Flag] == Option and "accentColor" or "textDarkColor")]

                        Option_Button.MouseEnter:Connect(function() 
                            Animate_Element(Option_Button, {BackgroundTransparency = 0.21}, 0.2)
                            if Library_Api.Flags[Flag] ~= Option then
                                Set_Theme_State(Option_Label, "TextColor3", "textWhiteColor")
                            end
                        end)
                        Option_Button.MouseLeave:Connect(function()
                            Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.2)
                            if Library_Api.Flags[Flag] ~= Option then
                                Set_Theme_State(Option_Label, "TextColor3", "textDarkColor")
                            end
                        end)

                        Option_Button.MouseButton1Click:Connect(function()
                            Library_Api.Registry[Flag](Option)
                            Toggle_Dropdown_State()
                            Auto_Save()
                        end)
                    end
                    Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Options * 28 + (#Options * 4))
                end

                Library_Api.Registry[Flag] = function(New_Val)
                    Library_Api.Flags[Flag] = New_Val
                    Selected_Option_Label.Text = tostring(New_Val)
                    for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child:IsA("TextButton") then
                            local Lbl = Child:FindFirstChildOfClass("TextLabel")
                            if Lbl then
                                local isSel = (Lbl.Text == tostring(New_Val))
                                Set_Theme_State(Lbl, "TextColor3", isSel and "accentColor" or "textDarkColor")
                            end
                        end
                    end
                    if type(Callback) == "function" then task.spawn(Callback, New_Val) end
                end

                Render_Options()
                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])

                local Api = {}
                function Api:Refresh(New_Opts)
                    Options = type(New_Opts) == "table" and New_Opts or {"None"}
                    Render_Options()
                end
                return Api
            end

            function Elements:MultiDropdown_Create(Name, Flag, Options, Default, Tooltip, Callback)
                Options = type(Options) == "table" and Options or {}
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or {})
                local Is_Dropdown_Open = false

                local Dropdown_Frame = Instance.new("Frame")
                Dropdown_Frame.Size = UDim2.new(1, 0, 0, 56)
                Dropdown_Frame.BackgroundTransparency = 1
                Dropdown_Frame.ClipsDescendants = true
                Dropdown_Frame.ZIndex = 5
                Dropdown_Frame.Parent = Target_Container

                local Dropdown_Label = Instance.new("TextLabel")
                Dropdown_Label.Size = UDim2.new(1, -10, 0, 20)
                Dropdown_Label.Position = UDim2.new(0, 2, 0, 0)
                Dropdown_Label.BackgroundTransparency = 1
                Dropdown_Label.Text = Name
                Dropdown_Label.TextSize = 14
                Dropdown_Label.Font = Main_Font
                Dropdown_Label.TextXAlignment = Enum.TextXAlignment.Left
                Dropdown_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Dropdown_Label.Parent = Dropdown_Frame
                Bind_Color(Dropdown_Label, "TextColor3", "textWhiteColor")

                local Dropdown_Main_Button = Instance.new("TextButton")
                Dropdown_Main_Button.Size = UDim2.new(1, -4, 0, 32)
                Dropdown_Main_Button.Position = UDim2.new(0, 2, 0, 22)
                Dropdown_Main_Button.Text = ""
                Dropdown_Main_Button.AutoButtonColor = false
                Dropdown_Main_Button.Parent = Dropdown_Frame
                Bind_Color(Dropdown_Main_Button, "BackgroundColor3", "elementBackground")
                Register_Transparency(Dropdown_Main_Button, 0.21)
                
                local Dropdown_Main_Button_Corner = Instance.new("UICorner")
                Dropdown_Main_Button_Corner.CornerRadius = UDim.new(0, 6)
                Dropdown_Main_Button_Corner.Parent = Dropdown_Main_Button

                local Selected_Option_Label = Instance.new("TextLabel")
                Selected_Option_Label.Size = UDim2.new(1, -40, 1, 0)
                Selected_Option_Label.Position = UDim2.new(0, 12, 0, 0)
                Selected_Option_Label.BackgroundTransparency = 1
                Selected_Option_Label.TextSize = 14
                Selected_Option_Label.Font = Main_Font
                Selected_Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                Selected_Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Selected_Option_Label.Parent = Dropdown_Main_Button
                Bind_Color(Selected_Option_Label, "TextColor3", "textDarkColor")

                local Dropdown_Arrow_Icon = Instance.new("ImageLabel")
                Dropdown_Arrow_Icon.Size = UDim2.new(0, 18, 0, 18)
                Dropdown_Arrow_Icon.Position = UDim2.new(1, -26, 0.5, -9)
                Dropdown_Arrow_Icon.BackgroundTransparency = 1
                Dropdown_Arrow_Icon.Image = "rbxassetid://10492813580"
                Dropdown_Arrow_Icon.Parent = Dropdown_Main_Button
                Bind_Color(Dropdown_Arrow_Icon, "ImageColor3", "textDarkColor")

                local Dropdown_Option_List_Frame = Instance.new("ScrollingFrame")
                Dropdown_Option_List_Frame.Size = UDim2.new(1, -4, 0, 0)
                Dropdown_Option_List_Frame.Position = UDim2.new(0, 2, 0, 58)
                Dropdown_Option_List_Frame.BorderSizePixel = 0
                Dropdown_Option_List_Frame.ScrollBarThickness = 2
                Dropdown_Option_List_Frame.ClipsDescendants = true
                Dropdown_Option_List_Frame.Active = true
                Dropdown_Option_List_Frame.ZIndex = 10
                Dropdown_Option_List_Frame.Parent = Dropdown_Frame
                Bind_Color(Dropdown_Option_List_Frame, "BackgroundColor3", "elementBackground")
                Bind_Color(Dropdown_Option_List_Frame, "ScrollBarImageColor3", "accentColor")
                Register_Transparency(Dropdown_Option_List_Frame, 0.21)
                
                local Dropdown_Option_List_Corner = Instance.new("UICorner")
                Dropdown_Option_List_Corner.CornerRadius = UDim.new(0, 6)
                Dropdown_Option_List_Corner.Parent = Dropdown_Option_List_Frame

                local Dropdown_Option_List_Layout = Instance.new("UIListLayout")
                Dropdown_Option_List_Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Dropdown_Option_List_Layout.Padding = UDim.new(0, 4)
                Dropdown_Option_List_Layout.Parent = Dropdown_Option_List_Frame

                local function Toggle_Dropdown_State()
                    Is_Dropdown_Open = not Is_Dropdown_Open
                    local Max_List_Height = math.min(#Options * 28 + (#Options * 4), 160)
                    local Target_List_Height = Is_Dropdown_Open and Max_List_Height or 0
                    Animate_Element(Dropdown_Arrow_Icon, {Rotation = Is_Dropdown_Open and 180 or 0}, 0.25)
                    Animate_Element(Dropdown_Option_List_Frame, {Size = UDim2.new(1, -4, 0, Target_List_Height)}, 0.25)
                    Animate_Element(Dropdown_Frame, {Size = UDim2.new(1, 0, 0, 56 + Target_List_Height + (Is_Dropdown_Open and 6 or 0))}, 0.25)
                end

                Dropdown_Main_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button, {BackgroundTransparency = 0.1}, 0.2) end
                end)
                Dropdown_Main_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    if not Is_Dropdown_Open then Animate_Element(Dropdown_Main_Button, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2) end
                end)
                Dropdown_Main_Button.MouseButton1Click:Connect(Toggle_Dropdown_State)

                local function Render_Options()
                    for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child:IsA("TextButton") then Child:Destroy() end
                    end
                    local currArr = type(Library_Api.Flags[Flag]) == "table" and Library_Api.Flags[Flag] or {}
                    for _, Option in ipairs(Options) do
                        local Option_Button = Instance.new("TextButton")
                        Option_Button.Size = UDim2.new(1, 0, 0, 28)
                        Option_Button.BackgroundTransparency = 1
                        Option_Button.Text = ""
                        Option_Button.ZIndex = 11
                        Option_Button.Parent = Dropdown_Option_List_Frame
                        Bind_Color(Option_Button, "BackgroundColor3", "elementHoverBackground")

                        local Option_Label = Instance.new("TextLabel")
                        Option_Label.Size = UDim2.new(1, -24, 1, 0)
                        Option_Label.Position = UDim2.new(0, 12, 0, 0)
                        Option_Label.BackgroundTransparency = 1
                        Option_Label.Text = Option
                        Option_Label.TextSize = 14
                        Option_Label.Font = Main_Font
                        Option_Label.TextXAlignment = Enum.TextXAlignment.Left
                        Option_Label.TextTruncate = Enum.TextTruncate.AtEnd
                        Option_Label.ZIndex = 11
                        Option_Label.Parent = Option_Button
                        
                        local isSel = table.find(currArr, Option) ~= nil
                        table.insert(Library_Api.Theme_Objects, {Obj = Option_Label, Prop = "TextColor3", Key = (isSel and "accentColor" or "textDarkColor")})
                        Option_Label.TextColor3 = Themes[Library_Api.Current_Theme][isSel and "accentColor" or "textDarkColor"]

                        Option_Button.MouseEnter:Connect(function() 
                            Animate_Element(Option_Button, {BackgroundTransparency = 0.21}, 0.2)
                            if table.find(type(Library_Api.Flags[Flag]) == "table" and Library_Api.Flags[Flag] or {}, Option) == nil then
                                Set_Theme_State(Option_Label, "TextColor3", "textWhiteColor")
                            end
                        end)
                        Option_Button.MouseLeave:Connect(function()
                            Animate_Element(Option_Button, {BackgroundTransparency = 1}, 0.2)
                            if table.find(type(Library_Api.Flags[Flag]) == "table" and Library_Api.Flags[Flag] or {}, Option) == nil then
                                Set_Theme_State(Option_Label, "TextColor3", "textDarkColor")
                            end
                        end)

                        Option_Button.MouseButton1Click:Connect(function()
                            local curr = type(Library_Api.Flags[Flag]) == "table" and Library_Api.Flags[Flag] or {}
                            local Idx = table.find(curr, Option)
                            local newArr = {}
                            for _, v in ipairs(curr) do table.insert(newArr, v) end
                            if Idx then
                                table.remove(newArr, Idx)
                            else
                                table.insert(newArr, Option)
                            end
                            Library_Api.Registry[Flag](newArr)
                            Auto_Save()
                        end)
                    end
                    Dropdown_Option_List_Frame.CanvasSize = UDim2.new(0, 0, 0, #Options * 28 + (#Options * 4))
                end

                Library_Api.Registry[Flag] = function(New_Array)
                    local arr = type(New_Array) == "table" and New_Array or {}
                    Library_Api.Flags[Flag] = arr
                    if #arr == 0 then
                        Selected_Option_Label.Text = "None"
                    else
                        Selected_Option_Label.Text = table.concat(arr, ", ")
                    end
                    
                    for _, Child in ipairs(Dropdown_Option_List_Frame:GetChildren()) do
                        if Child:IsA("TextButton") then
                            local Lbl = Child:FindFirstChildOfClass("TextLabel")
                            if Lbl then
                                local isSel = table.find(arr, Lbl.Text) ~= nil
                                Set_Theme_State(Lbl, "TextColor3", isSel and "accentColor" or "textDarkColor")
                            end
                        end
                    end
                    if type(Callback) == "function" then task.spawn(Callback, arr) end
                end

                Render_Options()
                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])

                local Api = {}
                function Api:Refresh(New_Opts)
                    Options = type(New_Opts) == "table" and New_Opts or {}
                    Render_Options()
                end
                return Api
            end

            function Elements:ColorPicker_Create(Name, Flag, Default, Tooltip, Callback)
                local initialColor = typeof(Default) == "Color3" and Default or Color3.new(1, 1, 1)
                Library_Api.Flags[Flag] = typeof(Library_Api.Flags[Flag]) == "Color3" and Library_Api.Flags[Flag] or initialColor
                local Is_Color_Picker_Open = false
                local Hue, Saturation, Value = Library_Api.Flags[Flag]:ToHSV()

                local Color_Picker_Frame = Instance.new("Frame")
                Color_Picker_Frame.Size = UDim2.new(1, 0, 0, 28)
                Color_Picker_Frame.BackgroundTransparency = 1
                Color_Picker_Frame.ClipsDescendants = true
                Color_Picker_Frame.Parent = Target_Container

                local Color_Picker_Top_Area = Instance.new("Frame")
                Color_Picker_Top_Area.Size = UDim2.new(1, 0, 0, 28)
                Color_Picker_Top_Area.BackgroundTransparency = 1
                Color_Picker_Top_Area.Parent = Color_Picker_Frame

                local Color_Picker_Label = Instance.new("TextLabel")
                Color_Picker_Label.Size = UDim2.new(1, -50, 1, 0)
                Color_Picker_Label.Position = UDim2.new(0, 2, 0, 0)
                Color_Picker_Label.BackgroundTransparency = 1
                Color_Picker_Label.Text = Name
                Color_Picker_Label.TextSize = 14
                Color_Picker_Label.Font = Main_Font
                Color_Picker_Label.TextXAlignment = Enum.TextXAlignment.Left
                Color_Picker_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Color_Picker_Label.Parent = Color_Picker_Top_Area
                Bind_Color(Color_Picker_Label, "TextColor3", "textWhiteColor")

                local Color_Preview_Button = Instance.new("TextButton")
                Color_Preview_Button.AnchorPoint = Vector2.new(1, 0.5)
                Color_Preview_Button.Size = UDim2.new(0, 36, 0, 18)
                Color_Preview_Button.Position = UDim2.new(1, -4, 0.5, 0)
                Color_Preview_Button.BackgroundColor3 = Library_Api.Flags[Flag]
                Color_Preview_Button.Text = ""
                Color_Preview_Button.AutoButtonColor = false
                Color_Preview_Button.Parent = Color_Picker_Top_Area
                
                local Color_Preview_Button_Corner = Instance.new("UICorner")
                Color_Preview_Button_Corner.CornerRadius = UDim.new(0, 4)
                Color_Preview_Button_Corner.Parent = Color_Preview_Button

                local Expanded_Picker_Frame = Instance.new("Frame")
                Expanded_Picker_Frame.Size = UDim2.new(1, -4, 0, 130)
                Expanded_Picker_Frame.Position = UDim2.new(0, 2, 0, 34)
                Expanded_Picker_Frame.Parent = Color_Picker_Frame
                Bind_Color(Expanded_Picker_Frame, "BackgroundColor3", "elementBackground")
                Register_Transparency(Expanded_Picker_Frame, 0.21)
                
                local Expanded_Picker_Corner = Instance.new("UICorner")
                Expanded_Picker_Corner.CornerRadius = UDim.new(0, 6)
                Expanded_Picker_Corner.Parent = Expanded_Picker_Frame

                local Saturation_Value_Map = Instance.new("TextButton")
                Saturation_Value_Map.Size = UDim2.new(1, -20, 0, 90)
                Saturation_Value_Map.Position = UDim2.new(0, 10, 0, 10)
                Saturation_Value_Map.AutoButtonColor = false
                Saturation_Value_Map.Text = ""
                Saturation_Value_Map.BackgroundColor3 = Color3.fromHSV(math.clamp(Hue, 0, 1), 1, 1)
                Saturation_Value_Map.Parent = Expanded_Picker_Frame
                local Saturation_Value_Map_Corner = Instance.new("UICorner"); Saturation_Value_Map_Corner.CornerRadius = UDim.new(0, 4); Saturation_Value_Map_Corner.Parent = Saturation_Value_Map

                local White_Overlay = Instance.new("Frame")
                White_Overlay.Size = UDim2.new(1, 0, 1, 0)
                White_Overlay.BackgroundColor3 = Color3.new(1, 1, 1)
                White_Overlay.BorderSizePixel = 0
                White_Overlay.Parent = Saturation_Value_Map
                local White_Corner = Instance.new("UICorner"); White_Corner.CornerRadius = UDim.new(0, 4); White_Corner.Parent = White_Overlay
                local White_Gradient = Instance.new("UIGradient")
                White_Gradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)}
                White_Gradient.Parent = White_Overlay

                local Black_Overlay = Instance.new("Frame")
                Black_Overlay.Size = UDim2.new(1, 0, 1, 0)
                Black_Overlay.BackgroundColor3 = Color3.new(0, 0, 0)
                Black_Overlay.BorderSizePixel = 0
                Black_Overlay.Parent = Saturation_Value_Map
                local Black_Corner = Instance.new("UICorner"); Black_Corner.CornerRadius = UDim.new(0, 4); Black_Corner.Parent = Black_Overlay
                local Black_Gradient = Instance.new("UIGradient")
                Black_Gradient.Rotation = 90
                Black_Gradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)}
                Black_Gradient.Parent = Black_Overlay

                local Saturation_Value_Map_Cursor = Instance.new("Frame")
                Saturation_Value_Map_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                Saturation_Value_Map_Cursor.Size = UDim2.new(0, 8, 0, 8)
                Saturation_Value_Map_Cursor.Position = UDim2.new(math.clamp(Saturation, 0, 1), 0, math.clamp(1 - Value, 0, 1), 0)
                Saturation_Value_Map_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                Saturation_Value_Map_Cursor.ZIndex = 2
                Saturation_Value_Map_Cursor.Parent = Saturation_Value_Map
                local Saturation_Value_Map_Cursor_Corner = Instance.new("UICorner"); Saturation_Value_Map_Cursor_Corner.CornerRadius = UDim.new(1, 0); Saturation_Value_Map_Cursor_Corner.Parent = Saturation_Value_Map_Cursor

                local Hue_Map = Instance.new("TextButton")
                Hue_Map.Size = UDim2.new(1, -20, 0, 12)
                Hue_Map.Position = UDim2.new(0, 10, 0, 108)
                Hue_Map.Text = ""
                Hue_Map.AutoButtonColor = false
                Hue_Map.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Map.Parent = Expanded_Picker_Frame
                local Hue_Map_Corner = Instance.new("UICorner"); Hue_Map_Corner.CornerRadius = UDim.new(0, 4); Hue_Map_Corner.Parent = Hue_Map

                local Hue_Gradient = Instance.new("UIGradient")
                Hue_Gradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(1/6, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(2/6, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(3/6, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(4/6, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(5/6, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                }
                Hue_Gradient.Parent = Hue_Map

                local Hue_Map_Cursor = Instance.new("Frame")
                Hue_Map_Cursor.AnchorPoint = Vector2.new(0.5, 0.5)
                Hue_Map_Cursor.Size = UDim2.new(0, 4, 1, 6)
                Hue_Map_Cursor.Position = UDim2.new(math.clamp(Hue, 0, 1), 0, 0.5, 0)
                Hue_Map_Cursor.BackgroundColor3 = Color3.new(1, 1, 1)
                Hue_Map_Cursor.ZIndex = 2
                Hue_Map_Cursor.Parent = Hue_Map
                local Hue_Map_Cursor_Corner = Instance.new("UICorner"); Hue_Map_Cursor_Corner.CornerRadius = UDim.new(0, 2); Hue_Map_Cursor_Corner.Parent = Hue_Map_Cursor

                Library_Api.Registry[Flag] = function(New_Color, From_Internal)
                    local c = typeof(New_Color) == "Color3" and New_Color or Color3.new(1,1,1)
                    Library_Api.Flags[Flag] = c
                    if not From_Internal then
                        local h, s, v = c:ToHSV()
                        Hue = h
                        Saturation = s
                        Value = v
                    end
                    Saturation_Value_Map.BackgroundColor3 = Color3.fromHSV(math.clamp(Hue, 0, 1), 1, 1)
                    Color_Preview_Button.BackgroundColor3 = c
                    Saturation_Value_Map_Cursor.Position = UDim2.new(math.clamp(Saturation, 0, 1), 0, math.clamp(1 - Value, 0, 1), 0)
                    Hue_Map_Cursor.Position = UDim2.new(math.clamp(Hue, 0, 1), 0, 0.5, 0)
                    if type(Callback) == "function" then task.spawn(Callback, c) end
                end

                local Dragging_Sat = false
                local Dragging_Hue = false

                local function Update_Sat(Input)
                    Saturation = math.clamp((Input.Position.X - Saturation_Value_Map.AbsolutePosition.X) / Saturation_Value_Map.AbsoluteSize.X, 0, 1)
                    Value = 1 - math.clamp((Input.Position.Y - Saturation_Value_Map.AbsolutePosition.Y) / Saturation_Value_Map.AbsoluteSize.Y, 0, 1)
                    Library_Api.Registry[Flag](Color3.fromHSV(Hue, Saturation, Value), true)
                end

                local function Update_Hue(Input)
                    Hue = math.clamp((Input.Position.X - Hue_Map.AbsolutePosition.X) / Hue_Map.AbsoluteSize.X, 0, 1)
                    Library_Api.Registry[Flag](Color3.fromHSV(Hue, Saturation, Value), true)
                end

                Saturation_Value_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging_Sat = true
                        Update_Sat(Input)
                    end
                end)
                
                Hue_Map.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        Dragging_Hue = true
                        Update_Hue(Input)
                    end
                end)

                User_Input_Service.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if Dragging_Sat then Update_Sat(Input) end
                        if Dragging_Hue then Update_Hue(Input) end
                    end
                end)

                User_Input_Service.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        if Dragging_Sat or Dragging_Hue then
                            Dragging_Sat = false
                            Dragging_Hue = false
                            Auto_Save()
                        end
                    end
                end)

                Color_Preview_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                end)
                Color_Preview_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                end)

                Color_Preview_Button.MouseButton1Click:Connect(function()
                    Is_Color_Picker_Open = not Is_Color_Picker_Open
                    Animate_Element(Color_Picker_Frame, {Size = UDim2.new(1, 0, 0, Is_Color_Picker_Open and 172 or 28)}, 0.25)
                end)
                
                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])
            end

            function Elements:Button_Create(Name, Tooltip, Callback)
                local Button_Frame = Instance.new("Frame")
                Button_Frame.Size = UDim2.new(1, 0, 0, 32)
                Button_Frame.BackgroundTransparency = 1
                Button_Frame.Parent = Target_Container

                local Action_Button = Instance.new("TextButton")
                Action_Button.Size = UDim2.new(1, -4, 1, 0)
                Action_Button.Position = UDim2.new(0, 2, 0, 0)
                Action_Button.Text = Name
                Action_Button.TextSize = 14
                Action_Button.Font = Bold_Font
                Action_Button.AutoButtonColor = false
                Action_Button.TextTruncate = Enum.TextTruncate.AtEnd
                Action_Button.Parent = Button_Frame
                Bind_Color(Action_Button, "BackgroundColor3", "elementBackground")
                Bind_Color(Action_Button, "TextColor3", "textWhiteColor")
                Register_Transparency(Action_Button, 0.21)
                
                local Action_Button_Corner = Instance.new("UICorner")
                Action_Button_Corner.CornerRadius = UDim.new(0, 6)
                Action_Button_Corner.Parent = Action_Button

                Action_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Action_Button, {BackgroundTransparency = 0.1}, 0.2)
                end)
                Action_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Action_Button, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2)
                end)
                Action_Button.MouseButton1Down:Connect(function() Animate_Element(Action_Button, {Size = UDim2.new(0.96, 0, 0.85, 0), Position = UDim2.new(0.02, 0, 0.075, 0)}, 0.15) end)
                Action_Button.MouseButton1Up:Connect(function()
                    Animate_Element(Action_Button, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.15)
                    if type(Callback) == "function" then task.spawn(Callback) end
                end)
            end

            function Elements:SubButton_Create(Name, Tooltip, Callback)
                local Sub_Button_Frame = Instance.new("Frame")
                Sub_Button_Frame.Size = UDim2.new(1, 0, 0, 26)
                Sub_Button_Frame.BackgroundTransparency = 1
                Sub_Button_Frame.Parent = Target_Container

                local Sub_Button_Action = Instance.new("TextButton")
                Sub_Button_Action.Size = UDim2.new(1, -16, 1, 0)
                Sub_Button_Action.Position = UDim2.new(0, 8, 0, 0)
                Sub_Button_Action.Text = Name
                Sub_Button_Action.TextSize = 13
                Sub_Button_Action.Font = Main_Font
                Sub_Button_Action.AutoButtonColor = false
                Sub_Button_Action.TextTruncate = Enum.TextTruncate.AtEnd
                Sub_Button_Action.Parent = Sub_Button_Frame
                Bind_Color(Sub_Button_Action, "BackgroundColor3", "sectionBackground")
                Bind_Color(Sub_Button_Action, "TextColor3", "textDarkColor")
                Register_Transparency(Sub_Button_Action, 0.21)
                
                local Sub_Button_Corner = Instance.new("UICorner")
                Sub_Button_Corner.CornerRadius = UDim.new(0, 4)
                Sub_Button_Corner.Parent = Sub_Button_Action

                Sub_Button_Action.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                    Animate_Element(Sub_Button_Action, {BackgroundTransparency = 0.1}, 0.2)
                end)
                Sub_Button_Action.MouseLeave:Connect(function()
                    Show_Tooltip("")
                    Animate_Element(Sub_Button_Action, {BackgroundTransparency = Library_Api.Global_Settings.Transparency and 0.21 or 0}, 0.2)
                end)
                Sub_Button_Action.MouseButton1Down:Connect(function() Animate_Element(Sub_Button_Action, {Size = UDim2.new(0.96, -16, 0.85, 0), Position = UDim2.new(0.02, 8, 0.075, 0)}, 0.15) end)
                Sub_Button_Action.MouseButton1Up:Connect(function()
                    Animate_Element(Sub_Button_Action, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0)}, 0.15)
                    if type(Callback) == "function" then task.spawn(Callback) end
                end)
            end

            function Elements:Module_Create(Name, Flag, Description_Text, Default, Tooltip, Callback)
                Library_Api.Flags[Flag] = Library_Api.Flags[Flag] ~= nil and Library_Api.Flags[Flag] or (Default or false)

                local Module_Frame = Instance.new("Frame")
                Module_Frame.Size = UDim2.new(1, 0, 0, 56)
                Module_Frame.BackgroundTransparency = 1
                Module_Frame.ClipsDescendants = true
                Module_Frame.Parent = Target_Container

                local Module_Toggle_Button = Instance.new("TextButton")
                Module_Toggle_Button.Size = UDim2.new(1, -4, 0, 52)
                Module_Toggle_Button.Position = UDim2.new(0, 2, 0, 0)
                Module_Toggle_Button.Text = ""
                Module_Toggle_Button.AutoButtonColor = false
                Module_Toggle_Button.Parent = Module_Frame
                Bind_Color(Module_Toggle_Button, "BackgroundColor3", "elementBackground")
                Register_Transparency(Module_Toggle_Button, 0.21)
                
                local Module_Toggle_Button_Corner = Instance.new("UICorner")
                Module_Toggle_Button_Corner.CornerRadius = UDim.new(0, 6)
                Module_Toggle_Button_Corner.Parent = Module_Toggle_Button

                local Module_Checkbox_Frame = Instance.new("Frame")
                Module_Checkbox_Frame.Size = UDim2.new(0, 20, 0, 20)
                Module_Checkbox_Frame.Position = UDim2.new(0, 14, 0.5, -10)
                Module_Checkbox_Frame.Parent = Module_Toggle_Button
                Bind_Color(Module_Checkbox_Frame, "BackgroundColor3", "sectionBackground")
                Register_Transparency(Module_Checkbox_Frame, 0.21)
                
                local Module_Checkbox_Corner = Instance.new("UICorner")
                Module_Checkbox_Corner.CornerRadius = UDim.new(0, 4)
                Module_Checkbox_Corner.Parent = Module_Checkbox_Frame

                local Module_Label = Instance.new("TextLabel")
                Module_Label.Size = UDim2.new(1, -55, 0, 18)
                Module_Label.Position = UDim2.new(0, 44, 0, 6)
                Module_Label.BackgroundTransparency = 1
                Module_Label.Text = Name
                Module_Label.TextSize = 15
                Module_Label.Font = Bold_Font
                Module_Label.TextXAlignment = Enum.TextXAlignment.Left
                Module_Label.TextTruncate = Enum.TextTruncate.AtEnd
                Module_Label.Parent = Module_Toggle_Button
                Bind_Color(Module_Label, "TextColor3", "textDarkColor")

                local Module_Description_Label = Instance.new("TextLabel")
                Module_Description_Label.Size = UDim2.new(1, -55, 0, 26)
                Module_Description_Label.Position = UDim2.new(0, 44, 0, 22)
                Module_Description_Label.BackgroundTransparency = 1
                Module_Description_Label.Text = Description_Text
                Module_Description_Label.TextSize = 13
                Module_Description_Label.Font = Main_Font
                Module_Description_Label.TextXAlignment = Enum.TextXAlignment.Left
                Module_Description_Label.TextYAlignment = Enum.TextYAlignment.Top
                Module_Description_Label.TextWrapped = true
                Module_Description_Label.Parent = Module_Toggle_Button
                Bind_Color(Module_Description_Label, "TextColor3", "textDarkColor")

                local Module_Arrow_Icon = Instance.new("ImageLabel")
                Module_Arrow_Icon.Size = UDim2.new(0, 16, 0, 16)
                Module_Arrow_Icon.Position = UDim2.new(1, -24, 0.5, -8)
                Module_Arrow_Icon.BackgroundTransparency = 1
                Module_Arrow_Icon.Image = "rbxassetid://10492813580"
                Module_Arrow_Icon.Rotation = 0
                Module_Arrow_Icon.Parent = Module_Toggle_Button
                Bind_Color(Module_Arrow_Icon, "ImageColor3", "textDarkColor")

                local Module_Content_Frame = Instance.new("Frame")
                Module_Content_Frame.Size = UDim2.new(1, -16, 0, 0)
                Module_Content_Frame.Position = UDim2.new(0, 12, 0, 58)
                Module_Content_Frame.BackgroundTransparency = 1
                Module_Content_Frame.Parent = Module_Frame

                local Module_Content_Layout = Instance.new("UIListLayout")
                Module_Content_Layout.Padding = UDim.new(0, 10)
                Module_Content_Layout.Parent = Module_Content_Frame

                local function Synchronize_Module_Size()
                    if Library_Api.Flags[Flag] then
                        Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 56 + Module_Content_Layout.AbsoluteContentSize.Y + 10)}, 0.25)
                        Animate_Element(Module_Arrow_Icon, {Rotation = 180}, 0.25)
                    else
                        Animate_Element(Module_Frame, {Size = UDim2.new(1, 0, 0, 56)}, 0.25)
                        Animate_Element(Module_Arrow_Icon, {Rotation = 0}, 0.25)
                    end
                end

                Module_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if Library_Api.Flags[Flag] then Synchronize_Module_Size() end
                end)

                Library_Api.Registry[Flag] = function(New_State)
                    Library_Api.Flags[Flag] = New_State
                    Set_Theme_State(Module_Checkbox_Frame, "BackgroundColor3", New_State and "accentColor" or "sectionBackground")
                    Set_Theme_State(Module_Label, "TextColor3", New_State and "textWhiteColor" or "textDarkColor")
                    Synchronize_Module_Size()
                    if type(Callback) == "function" then task.spawn(Callback, New_State) end
                end

                Module_Toggle_Button.MouseEnter:Connect(function()
                    Show_Tooltip(Tooltip)
                end)
                Module_Toggle_Button.MouseLeave:Connect(function()
                    Show_Tooltip("")
                end)

                Module_Toggle_Button.MouseButton1Click:Connect(function()
                    Library_Api.Registry[Flag](not Library_Api.Flags[Flag])
                    Auto_Save()
                end)
                
                task.spawn(Library_Api.Registry[Flag], Library_Api.Flags[Flag])

                return Element_Injector(Module_Content_Frame)
            end

            return Elements
        end

        function Tab_Data:Section_Create(Column_Side, Section_Title)
            local Section_Background_Frame = Instance.new("Frame")
            Section_Background_Frame.Size = UDim2.new(1, 0, 0, 44)
            Section_Background_Frame.ClipsDescendants = true
            Section_Background_Frame.Parent = (Column_Side == "Left") and Left_Column_Frame or Right_Column_Frame
            Bind_Color(Section_Background_Frame, "BackgroundColor3", "sectionBackground")
            Register_Transparency(Section_Background_Frame, 0.21)

            local Section_Accent_Line = Instance.new("Frame")
            Section_Accent_Line.Size = UDim2.new(1, 0, 0, 2)
            Section_Accent_Line.Position = UDim2.new(0, 0, 0, 0)
            Section_Accent_Line.BorderSizePixel = 0
            Section_Accent_Line.Parent = Section_Background_Frame
            Bind_Color(Section_Accent_Line, "BackgroundColor3", "elementBackground")
            
            local Section_Background_Corner = Instance.new("UICorner")
            Section_Background_Corner.CornerRadius = UDim.new(0, 8)
            Section_Background_Corner.Parent = Section_Background_Frame

            local Section_Header_Frame = Instance.new("Frame")
            Section_Header_Frame.Size = UDim2.new(1, 0, 0, 30)
            Section_Header_Frame.BackgroundTransparency = 1
            Section_Header_Frame.Parent = Section_Background_Frame

            local Section_Label = Instance.new("TextLabel")
            Section_Label.Size = UDim2.new(1, -24, 1, 0)
            Section_Label.Position = UDim2.new(0, 12, 0, 0)
            Section_Label.BackgroundTransparency = 1
            Section_Label.Text = Section_Title
            Section_Label.TextSize = 14
            Section_Label.Font = Bold_Font
            Section_Label.TextXAlignment = Enum.TextXAlignment.Left
            Section_Label.TextTruncate = Enum.TextTruncate.AtEnd
            Section_Label.Parent = Section_Header_Frame
            Bind_Color(Section_Label, "TextColor3", "textWhiteColor")

            local Section_Separator_Line = Instance.new("Frame")
            Section_Separator_Line.Size = UDim2.new(1, -24, 0, 1)
            Section_Separator_Line.Position = UDim2.new(0, 12, 1, 0)
            Section_Separator_Line.BorderSizePixel = 0
            Section_Separator_Line.Parent = Section_Header_Frame
            Bind_Color(Section_Separator_Line, "BackgroundColor3", "elementBackground")

            local Section_Content_Frame = Instance.new("Frame")
            Section_Content_Frame.Size = UDim2.new(1, -20, 1, -40)
            Section_Content_Frame.Position = UDim2.new(0, 10, 0, 36)
            Section_Content_Frame.BackgroundTransparency = 1
            Section_Content_Frame.Parent = Section_Background_Frame

            local Section_Content_Layout = Instance.new("UIListLayout")
            Section_Content_Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Section_Content_Layout.Padding = UDim.new(0, 10)
            Section_Content_Layout.Parent = Section_Content_Frame

            Section_Content_Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Animate_Element(Section_Background_Frame, {Size = UDim2.new(1, 0, 0, Section_Content_Layout.AbsoluteContentSize.Y + 46)}, 0.25)
            end)
            Section_Background_Frame.Size = UDim2.new(1, 0, 0, Section_Content_Layout.AbsoluteContentSize.Y + 46)

            return Element_Injector(Section_Content_Frame)
        end

        Tab_Data.Elements = Element_Injector(Page_Scrolling_Frame)

        return Tab_Data
    end

    local Settings_Api = Window_Context:Tab_Create("Settings", "")
    local Settings_Tab_Obj = Settings_Api
    Settings_Tab_Obj.Btn.Visible = false

    Profile_Button.MouseEnter:Connect(function() Animate_Element(Profile_Button, {BackgroundTransparency = 0.11}, 0.2) end)
    Profile_Button.MouseLeave:Connect(function() 
        if Window_Context.Active_Tab ~= Settings_Tab_Obj then
            Animate_Element(Profile_Button, {BackgroundTransparency = 1}, 0.2) 
        end
    end)
    Profile_Button.MouseButton1Click:Connect(function()
        Settings_Tab_Obj:Activate()
        Animate_Element(Profile_Button, {BackgroundTransparency = 0.11}, 0.25)
    end)

    local Left_Settings = Settings_Api:Section_Create("Left", "Menu UI")
    
    Left_Settings:Keybind_Create("Menu Toggle", "Menu_Toggle_Key", Enum.KeyCode.Delete, "Toggle Menu Visibility", function()
        Main_Background.Visible = not Main_Background.Visible
    end)
    
    Left_Settings:Toggle_Create("Keybinds List", "Show_Keybinds", false, "Toggle Keybinds Tracker", function(State)
        Keybinds_Frame.Visible = State
    end)

    local Theme_List = {}
    for Name, _ in pairs(Themes) do table.insert(Theme_List, Name) end
    table.sort(Theme_List)

    Left_Settings:Dropdown_Create("Menu Theme", "Menu_Theme_Select", Theme_List, "Rose", "Select global theme", function(Theme_Name)
        Library_Api:ChangeTheme(Theme_Name)
        Auto_Save()
    end)

    Left_Settings:ColorPicker_Create("Custom Accent", "Custom_Accent_Color", Themes["Rose"].accentColor, "Override active theme accent", function(Color_Val)
        for _, theme in pairs(Themes) do
            theme.accentColor = Color_Val
        end
        Library_Api:ChangeTheme(Library_Api.Current_Theme)
        Auto_Save()
    end)

    Left_Settings:Toggle_Create("Enable Acrylic", "Global_Acrylic", true, "Toggle blur effects", function(State)
        Library_Api.Global_Settings.Acrylic = State
        for _, Obj in ipairs(Library_Api.Acrylic_Objects) do
            if Obj and Obj.Parent then Obj.Visible = State end
        end
        Auto_Save()
    end)

    Left_Settings:Toggle_Create("Enable Transparency", "Global_Trans", true, "Toggle element transparency", function(State)
        Library_Api.Global_Settings.Transparency = State
        for _, Data in ipairs(Library_Api.Transparency_Objects) do
            if Data.Obj and Data.Obj.Parent then
                Data.Obj.BackgroundTransparency = State and Data.Def or 0
            end
        end
        Auto_Save()
    end)

    local Right_Settings = Settings_Api:Section_Create("Right", "Configurations")
    
    local function Get_Configs()
        local List = {}
        local success, files = pcall(function() return listfiles(Library_Api.Folder_Name) end)
        if success and type(files) == "table" then
            for _, File in ipairs(files) do
                local Name = tostring(File):match("([^/\\]+)%.json$")
                if Name and Name ~= "AutoSaveConfig" then table.insert(List, Name) end
            end
        end
        return #List > 0 and List or {"None"}
    end

    local Config_Name_Input = ""
    Right_Settings:Textbox_Create("Config Name", "Cfg_Name", "", "", function(Val) Config_Name_Input = Val end)
    
    local Cfg_Dropdown = Right_Settings:Dropdown_Create("Select Config", "Cfg_Select", Get_Configs(), "None", "", function() end)

    Right_Settings:Button_Create("Save Config", "", function()
        if Config_Name_Input ~= "" then
            Save_To_File(Config_Name_Input .. ".json")
            Cfg_Dropdown:Refresh(Get_Configs())
            Library_Api:Notify({Title = "Phantom Hub", Text = "Saved Config: " .. Config_Name_Input, Type = "Success"})
        end
    end)

    Right_Settings:Button_Create("Rewrite Config", "", function()
        if Library_Api.Flags["Cfg_Select"] and Library_Api.Flags["Cfg_Select"] ~= "None" then
            Save_To_File(Library_Api.Flags["Cfg_Select"] .. ".json")
            Library_Api:Notify({Title = "Phantom Hub", Text = "Rewritten Config", Type = "Info"})
        end
    end)
    
    Right_Settings:Button_Create("Load Config", "", function()
        if Library_Api.Flags["Cfg_Select"] and Library_Api.Flags["Cfg_Select"] ~= "None" then
            Load_From_File(Library_Api.Flags["Cfg_Select"] .. ".json")
            Library_Api:RefreshKeybinds()
            Library_Api:Notify({Title = "Phantom Hub", Text = "Loaded Config", Type = "Success"})
        end
    end)
    
    Right_Settings:Button_Create("Delete Config", "", function()
        if Library_Api.Flags["Cfg_Select"] and Library_Api.Flags["Cfg_Select"] ~= "None" then
            pcall(function() delfile(Library_Api.Folder_Name .. "/" .. Library_Api.Flags["Cfg_Select"] .. ".json") end)
            Cfg_Dropdown:Refresh(Get_Configs())
            Library_Api:Notify({Title = "Phantom Hub", Text = "Deleted Config", Type = "Error"})
        end
    end)

    Load_From_File(Library_Api.Config_Name)

    return Window_Context
end

return Library_Api
