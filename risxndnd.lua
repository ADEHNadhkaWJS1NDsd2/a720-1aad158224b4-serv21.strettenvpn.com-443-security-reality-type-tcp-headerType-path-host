if _G.Nightfall_Drawings then
    for _, Drawing_Obj in pairs(_G.Nightfall_Drawings) do
        pcall(function() Drawing_Obj:Remove() end)
    end
end
_G.Nightfall_Drawings = {}

local Http_Service = game:GetService("HttpService")
local Run_Service = game:GetService("RunService")
local Players_Service = game:GetService("Players")
local Workspace_Service = game:GetService("Workspace")
local Stats_Service = game:GetService("Stats")

local Local_Player = Players_Service.LocalPlayer or Players_Service.PlayerAdded:Wait()
local Fast_Max = math.max
local Fast_Min = math.min
local Fast_Floor = math.floor
local Fast_Clamp = math.clamp
local Fast_Sqrt = math.sqrt
local Fast_Clock = os.clock
local V3_Zero = Vector3.zero
local Pi_2 = math.pi * 2

local Lib_Instance
for _ = 1, 6 do
    local ok, res = pcall(function() return loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.lua"))() end)
    if ok and type(res) == "table" then Lib_Instance = res; break end
    if type(INSui) == "table" then Lib_Instance = INSui; break end
    task.wait(0.4)
end
if type(Lib_Instance) ~= "table" then return end

Lib_Instance:SetTheme("Indigo")

local Win_App = Lib_Instance:CreateWindow({
    title = "Nightfall | Recode",
    subtitle = "credits to inspecttor for ui",
    size = Vector2.new(700, 552),
    configName = "nightfall",
    menuKey = "RightShift",
    badge = "v2"
})

local Config_State = {
    Auto_Parry = false,
    Panic_Spam = false,
    Training_Balls_Support = false,
    Auto_Spam = false,
    Spam_Rate = 200,
    Spam_Sensitivity = 3,
    Trigger_Bot = false,
    Trigger_Delay = 0,
    Trigger_Ignore_Spawn = false,
    Parry_Visualizer = false,
    Visualizer_Color = Color3.fromRGB(122, 134, 255),
    Vis_Thickness = 2.0,
    Vis_Transparency = 1.0,
    Vis_Segments = 40,
    Ability_Esp = false,
    Esp_Color = Color3.fromRGB(122, 134, 255),
    Esp_Text_Size = 18,
    Esp_Offset_Y = 2.0,
    Ball_Trail = false,
    Trail_Color = Color3.fromRGB(122, 134, 255),
    Trail_Length = 60,
    Trail_Thickness = 2.0,
    Rainbow_Mode = false,
    Infinity_Detection = false,
    Slashes_Of_Fury_Detection = false,
    Parry_Method = "Click",
    Headless = false,
    Korblox = false,
    Infinity_Disabled_Parry = false,
    Infinity_Disabled_Spam = false,
    Infinity_Disabled_Trigger = false,
    Fury_Disabled_Parry = false,
    Fury_Disabled_Spam = false,
    Fury_Disabled_Trigger = false,
    Fury_Triggered = false
}

local Runtime_State = {
    Target_Speed = 0,
    Target_Distance = 0,
    Target_Dot = 0,
    Parry_Range = 0
}

local Offsets_Data = {
    Transparency = 0xF0,
    Parent = 0x70,
    Decal_Texture = 0x198
}

local function Write_Float(Addr_Val, Float_Val)
    if Addr_Val and Addr_Val ~= 0 then
        pcall(memory_write, "float", Addr_Val, Float_Val)
    end
end

local function Write_Pointer(Addr_Val, Ptr_Val)
    if Addr_Val and Addr_Val ~= 0 then
        if not pcall(memory_write, "uint64", Addr_Val, Ptr_Val) then
            pcall(memory_write, "pointer", Addr_Val, Ptr_Val)
        end
    end
end

local Combat_Tab = Win_App:Tab("Combat", "swords")

local Parry_Section = Combat_Tab:Section("Auto Parry", "Left")
Parry_Section:Toggle("Auto Parry", false, function(Value_In) Config_State.Auto_Parry = Value_In end):AddKeybind("None", "Toggle")
Parry_Section:Toggle("Panic Spam", false, function(Value_In) Config_State.Panic_Spam = Value_In end)
Parry_Section:Dropdown("Parry Method", {"Click", "Key"}, {"Click"}, false, function(Value_In) Config_State.Parry_Method = type(Value_In) == "table" and Value_In[1] or Value_In end)
Parry_Section:Toggle("Training Balls", false, function(Value_In) Config_State.Training_Balls_Support = Value_In end)

local Spam_Section = Combat_Tab:Section("Auto Spam", "Right")
Spam_Section:Toggle("Auto Spam", false, function(Value_In) Config_State.Auto_Spam = Value_In end):AddKeybind("None", "Toggle")
Spam_Section:Slider("Spam Rate", 200, 10, 10, 500, "cps", function(Value_In) Config_State.Spam_Rate = Value_In end)
Spam_Section:Slider("Spam Sensitivity", 3, 1, 3, 5, "", function(Value_In) Config_State.Spam_Sensitivity = Value_In end)

local Trigger_Section = Combat_Tab:Section("Trigger Bot", "Right")
Trigger_Section:Toggle("Trigger Bot", false, function(Value_In) Config_State.Trigger_Bot = Value_In end):AddKeybind("None", "Toggle")
Trigger_Section:Slider("Delay", 0, 1, 0, 100, "ms", function(Value_In) Config_State.Trigger_Delay = Value_In end)
Trigger_Section:Toggle("Ignore Ball Spawn", false, function(Value_In) Config_State.Trigger_Ignore_Spawn = Value_In end)

local Visuals_Tab = Win_App:Tab("Visuals", "eye")

local Vis_Main_Section = Visuals_Tab:Section("Visuals", "Left")
Vis_Main_Section:Toggle("Range Visualiser", false, function(Value_In) Config_State.Parry_Visualizer = Value_In end):AddColorpicker("Vis Color", Color3.fromRGB(122, 134, 255), function(Color_Val) Config_State.Visualizer_Color = Color_Val end)
Vis_Main_Section:Slider("Vis Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value_In) Config_State.Vis_Thickness = Value_In end)
Vis_Main_Section:Slider("Vis Transparency", 1.0, 0.1, 0.1, 1.0, "", function(Value_In) Config_State.Vis_Transparency = Value_In end)
Vis_Main_Section:Slider("Vis Segments", 40, 1, 10, 100, "", function(Value_In) Config_State.Vis_Segments = Value_In end)

Vis_Main_Section:Toggle("Ability ESP", false, function(Value_In) Config_State.Ability_Esp = Value_In end):AddColorpicker("ESP Color", Color3.fromRGB(122, 134, 255), function(Color_Val) Config_State.Esp_Color = Color_Val end)
Vis_Main_Section:Slider("ESP Text Size", 18, 1, 10, 40, "", function(Value_In) Config_State.Esp_Text_Size = Value_In end)
Vis_Main_Section:Slider("ESP Offset Y", 2.0, 0.5, 0.0, 10.0, "", function(Value_In) Config_State.Esp_Offset_Y = Value_In end)

Vis_Main_Section:Toggle("Rainbow Mode", false, function(Value_In) Config_State.Rainbow_Mode = Value_In end)

local Vis_Trail_Section = Visuals_Tab:Section("Ball Trail", "Right")
Vis_Trail_Section:Toggle("Enable Trail", false, function(Value_In) Config_State.Ball_Trail = Value_In end):AddColorpicker("Trail Color", Color3.fromRGB(122, 134, 255), function(Color_Val) Config_State.Trail_Color = Color_Val end)
Vis_Trail_Section:Slider("Trail Length", 60, 1, 10, 100, "", function(Value_In) Config_State.Trail_Length = Value_In end)
Vis_Trail_Section:Slider("Trail Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value_In) Config_State.Trail_Thickness = Value_In end)

local Vis_Avatar_Section = Visuals_Tab:Section("Avatar", "Right")

local function Apply_Headless(State_Val)
    local Char_Obj = Local_Player.Character
    if not Char_Obj then return end
    local Head_Obj = Char_Obj:FindFirstChild("Head")
    if Head_Obj then
        if State_Val then
            pcall(function() Head_Obj.Size = Vector3.new(0.01, 0.01, 0.01) end)
            if Head_Obj.Address and Head_Obj.Address ~= 0 then
                Write_Float(Head_Obj.Address + Offsets_Data.Transparency, 1.0)
            end
            for _, Child_Obj in ipairs(Head_Obj:GetChildren()) do
                if Child_Obj.ClassName == "Decal" or Child_Obj.Name == "face" or Child_Obj.Name == "Face" or Child_Obj.ClassName:match("Mesh") then
                    pcall(function() Child_Obj.Texture = "" end)
                    pcall(function() Child_Obj.Transparency = 1 end)
                    pcall(function() Child_Obj.Parent = nil end)
                    pcall(function() game:GetService("Debris"):AddItem(Child_Obj, 0) end)
                    if Child_Obj.Address and Child_Obj.Address ~= 0 then
                        if Child_Obj.ClassName == "Decal" or Child_Obj.Name == "face" or Child_Obj.Name == "Face" then
                            pcall(memory_write, "uint64", Child_Obj.Address + Offsets_Data.Decal_Texture + 0x10, 0)
                        end
                        Write_Pointer(Child_Obj.Address + Offsets_Data.Parent, 0)
                    end
                end
            end
        else
            pcall(function() Head_Obj.Size = Vector3.new(1.2, 1, 1.2) end)
        end
    end
end

local function Apply_Korblox(State_Val)
    local Char_Obj = Local_Player.Character
    if not Char_Obj then return end
    local Right_Leg_Names = {
        RightUpperLeg = true,
        RightLowerLeg = true,
        RightFoot = true,
        ["Right Leg"] = true
    }
    if State_Val then
        for _, Part_Obj in ipairs(Char_Obj:GetChildren()) do
            if Right_Leg_Names[Part_Obj.Name] then
                pcall(function() Part_Obj.Size = Vector3.new(0.01, 0.01, 0.01) end)
                if Part_Obj.Address and Part_Obj.Address ~= 0 then
                    Write_Float(Part_Obj.Address + Offsets_Data.Transparency, 1.0)
                end
                for _, Child_Obj in ipairs(Part_Obj:GetChildren()) do
                    if Child_Obj.ClassName:match("Mesh") or Child_Obj.ClassName == "Decal" or Child_Obj.ClassName == "Texture" then
                        pcall(function() Child_Obj.Texture = "" end)
                        pcall(function() Child_Obj.Transparency = 1 end)
                        pcall(function() Child_Obj.Parent = nil end)
                        pcall(function() game:GetService("Debris"):AddItem(Child_Obj, 0) end)
                        if Child_Obj.Address and Child_Obj.Address ~= 0 then
                            Write_Pointer(Child_Obj.Address + Offsets_Data.Parent, 0)
                        end
                    end
                end
            elseif Part_Obj.ClassName == "CharacterMesh" then
                pcall(function()
                    if tostring(Part_Obj.BodyPart):match("RightLeg") then
                        if Part_Obj.Address and Part_Obj.Address ~= 0 then
                            Write_Pointer(Part_Obj.Address + Offsets_Data.Parent, 0)
                        end
                    end
                end)
            elseif Part_Obj.ClassName == "Accessory" then
                pcall(function()
                    local Handle_Obj = Part_Obj:FindFirstChild("Handle")
                    if Handle_Obj then
                        local Weld_Obj = Handle_Obj:FindFirstChildOfClass("Weld") or Handle_Obj:FindFirstChildOfClass("Motor6D")
                        if Weld_Obj and Weld_Obj.Part1 and Right_Leg_Names[Weld_Obj.Part1.Name] then
                            if Part_Obj.Address and Part_Obj.Address ~= 0 then
                                Write_Pointer(Part_Obj.Address + Offsets_Data.Parent, 0)
                            end
                        end
                    end
                end)
            end
        end
    else
        for _, Part_Obj in ipairs(Char_Obj:GetChildren()) do
            if Right_Leg_Names[Part_Obj.Name] then
                pcall(function() Part_Obj.Size = Vector3.new(1, 1, 1) end)
            end
        end
    end
end

Vis_Avatar_Section:Toggle("Headless", false, function(Value_In) 
    Config_State.Headless = Value_In 
    Apply_Headless(Value_In)
end)

Vis_Avatar_Section:Toggle("Korblox", false, function(Value_In) 
    Config_State.Korblox = Value_In 
    Apply_Korblox(Value_In)
end)

local Detections_Tab = Win_App:Tab("Detections", "shield")
local Det_Main_Section = Detections_Tab:Section("Detections", "Left")
Det_Main_Section:Toggle("Infinity Detection", false, function(Value_In) Config_State.Infinity_Detection = Value_In end)
Det_Main_Section:Toggle("Slashes of Fury Detection", false, function(Value_In) Config_State.Slashes_Of_Fury_Detection = Value_In end)

Win_App:AddSettingsTab("cog")

local Visuals_Data = {
    Sphere_Lines = {},
    Ball_Trail_Pos = {},
    Ball_Lines = {},
    Esp_Texts = {},
    Trail_Time = 0
}

local Max_Trail_Lines = 100
local Trail_Refresh_Rate = 0.01

local function Create_Esp_Text()
    if not Drawing or not Drawing.new then return nil end
    local Success, Text_Obj = pcall(function() return Drawing.new("Text") end)
    if not Success or not Text_Obj then return nil end
    Text_Obj.Center = true
    Text_Obj.Outline = true
    Text_Obj.Font = 2
    Text_Obj.Visible = false
    table.insert(_G.Nightfall_Drawings, Text_Obj)
    return Text_Obj
end

if type(Drawing) == "table" and Drawing.new then
    for I_Idx = 1, 100 do
        pcall(function()
            local Line_Obj = Drawing.new("Line")
            if Line_Obj then
                Line_Obj.Visible = false
                Visuals_Data.Sphere_Lines[I_Idx] = Line_Obj
                table.insert(_G.Nightfall_Drawings, Line_Obj)
            end
        end)
    end
    for I_Idx = 1, Max_Trail_Lines do
        pcall(function()
            local Line_Obj = Drawing.new("Line")
            if Line_Obj then
                Line_Obj.Visible = false
                Visuals_Data.Ball_Lines[I_Idx] = Line_Obj
                table.insert(_G.Nightfall_Drawings, Line_Obj)
            end
        end)
    end
end

local Smooth_Parry_Radius = 0

local function Get_Screen_Position(World_Pos)
    if not World_Pos then return Vector2.new(0, 0), false end
    local Success, Pos_2D, Is_Visible = pcall(WorldToScreen, World_Pos)
    if not Success or not Pos_2D then 
        return Vector2.new(0, 0), false 
    end
    local Camera = Workspace_Service.CurrentCamera
    if Camera then
        local Cam_CF = Camera.CFrame
        if Cam_CF then
            local To_Point = World_Pos - Cam_CF.Position
            if Cam_CF.LookVector:Dot(To_Point.Unit) <= 0 then
                Is_Visible = false
            end
        end
    end
    return Pos_2D, Is_Visible
end

local function Get_Real_Ball()
    local Alive_Folder = Workspace_Service:FindFirstChild("Alive")
    local Target_Folder = Alive_Folder and Alive_Folder:FindFirstChild(Local_Player.Name) and Workspace_Service:FindFirstChild("Balls") or Workspace_Service:FindFirstChild("TrainingBalls")
    if Target_Folder then
        for _, Ball in ipairs(Target_Folder:GetChildren()) do
            if Ball:IsA("BasePart") and Ball:GetAttribute("realBall") == true then return Ball end
        end
        for _, Ball in ipairs(Target_Folder:GetChildren()) do
            if Ball:IsA("BasePart") then return Ball end
        end
    end
    return nil
end

local function Get_Memory_Ping()
    local Success_State, Ping_Result = pcall(function()
        return memory_read("double", Stats_Service.Network.ServerStatsItem["Data Ping"].Address + 0xC8)
    end)
    return Success_State and Ping_Result or 50
end

local function Check_Is_Target(Target_Name)
    local Character_Instance = Local_Player.Character
    if Character_Instance and Character_Instance:FindFirstChild('Highlight') then return true end
    if not Target_Name then return false end
    local My_Name = string.lower(Local_Player.Name or "")
    local My_Display = string.lower(Local_Player.DisplayName or Local_Player.Name or "")
    local Tgt_Str = string.lower(tostring(Target_Name))
    if Tgt_Str == My_Name or Tgt_Str == My_Display then return true end
    local Clean_Target = string.gsub(Tgt_Str, '%.%.%.$', '')
    if #Clean_Target >= 3 then
        if string.sub(My_Name, 1, #Clean_Target) == Clean_Target or string.sub(My_Display, 1, #Clean_Target) == Clean_Target then return true end
        if string.find(My_Name, Clean_Target, 1, true) or string.find(My_Display, Clean_Target, 1, true) then return true end
    end
    return false
end

local function Get_Distance_Squared(V1_Pos, V2_Pos)
    local Dx_Val = V1_Pos.X - V2_Pos.X
    local Dy_Val = V1_Pos.Y - V2_Pos.Y
    local Dz_Val = V1_Pos.Z - V2_Pos.Z
    return Dx_Val * Dx_Val + Dy_Val * Dy_Val + Dz_Val * Dz_Val
end

local function Scan_For_Nearest_Entity(Player_Position)
    local Nearest_Entity = nil
    local Minimum_Distance_Sq = math.huge
    for _, Target_Player in ipairs(Players_Service:GetPlayers()) do
        if Target_Player ~= Local_Player and Target_Player.Character then
            local Root_Part = Target_Player.Character:FindFirstChild("HumanoidRootPart") or Target_Player.Character.PrimaryPart
            if Root_Part and Root_Part:IsA("BasePart") then
                local Humanoid_Part = Target_Player.Character:FindFirstChild("Humanoid")
                if Humanoid_Part and Humanoid_Part.Health > 0 then
                    local Current_Dist_Sq = Get_Distance_Squared(Player_Position, Root_Part.Position)
                    if Current_Dist_Sq < Minimum_Distance_Sq then
                        Minimum_Distance_Sq = Current_Dist_Sq
                        Nearest_Entity = Target_Player
                    end
                end
            end
        end
    end
    return Nearest_Entity, Fast_Sqrt(Minimum_Distance_Sq)
end

local function Execute_Parry()
    task.spawn(function()
        if Config_State.Parry_Method == "Click" then
            if typeof(mouse1click) == "function" then
                mouse1click()
            end
        elseif Config_State.Parry_Method == "Key" then
            if typeof(keypress) == "function" and typeof(keyrelease) == "function" then
                keypress(0x46)
                keyrelease(0x46)
            end
        end
    end)
end

local Configuration_Spam = {
    Spam_Min_Distance_Speed_Divisor = 6.5,
    Spam_Max_Speed_Divisor = 5.0,
    Spam_Min_Distance = 95.0,
    Spam_Max_Distance = 30.0
}

local function Check_Is_Spam(Spam_Params)
    local Scaled_Ping = Spam_Params.Ping / 10
    local Range_Val = Scaled_Ping + Fast_Min(Spam_Params.Speed / Configuration_Spam.Spam_Min_Distance_Speed_Divisor, Configuration_Spam.Spam_Min_Distance)
    if Spam_Params.Entity_Distance > Range_Val then return false, Spam_Params.Parries end
    if Spam_Params.Ball_Distance > Range_Val then return false, Spam_Params.Parries end
    local Maximum_Dot = Fast_Clamp(Spam_Params.Dot, -1, 0)
    local Accuracy_Val = Fast_Min(Range_Val - Maximum_Dot, Configuration_Spam.Spam_Max_Distance)
    if Spam_Params.Ball_Distance > Accuracy_Val then return false, Spam_Params.Parries end
    if Spam_Params.Parries < Config_State.Spam_Sensitivity then return false, Spam_Params.Parries end
    return true, Spam_Params.Parries
end

local function Get_Trail_Color_And_Opacity(Offset_Val, Index_Val, Total_Val)
    local Alpha_Val = 1.0 - math.pow(Index_Val / Total_Val, 1.5)
    local Opacity_Val = Fast_Max(Alpha_Val * Alpha_Val * Alpha_Val, 0.05)
    if not Config_State.Rainbow_Mode then
        return Config_State.Trail_Color, Opacity_Val
    end
    local Time_Val = Fast_Clock() * 2.5 + Offset_Val + Index_Val * 0.1
    local R_Val = (math.sin(Time_Val) * 0.5 + 0.5) * 0.95 + 0.05
    local G_Val = (math.sin(Time_Val + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
    local B_Val = (math.sin(Time_Val + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
    return Color3.new(R_Val, G_Val, B_Val), Opacity_Val
end

local function Update_And_Render_Trail(Best_Pos)
    if not Config_State.Ball_Trail then
        for _, Line_Obj in ipairs(Visuals_Data.Ball_Lines) do
            if Line_Obj then Line_Obj.Visible = false end
        end
        return
    end
    if not Best_Pos then
        for _, Line_Obj in ipairs(Visuals_Data.Ball_Lines) do
            if Line_Obj then Line_Obj.Visible = false end
        end
        table.clear(Visuals_Data.Ball_Trail_Pos)
        return
    end
    local Current_Time = Fast_Clock()
    if Current_Time - Visuals_Data.Trail_Time >= Trail_Refresh_Rate then
        Visuals_Data.Trail_Time = Current_Time
        table.insert(Visuals_Data.Ball_Trail_Pos, 1, Best_Pos)
        while #Visuals_Data.Ball_Trail_Pos > Config_State.Trail_Length do
            table.remove(Visuals_Data.Ball_Trail_Pos)
        end
    end
    local Total_Pos = #Visuals_Data.Ball_Trail_Pos
    if Total_Pos < 2 then
        for _, Line_Obj in ipairs(Visuals_Data.Ball_Lines) do
            if Line_Obj then Line_Obj.Visible = false end
        end
        return
    end
    local Base_Offset = Fast_Clock() * 1.5
    for I_Idx = 2, Total_Pos do
        local Line_Obj = Visuals_Data.Ball_Lines[I_Idx - 1]
        if not Line_Obj then break end
        local Pos_1 = Visuals_Data.Ball_Trail_Pos[I_Idx - 1]
        local Pos_2 = Visuals_Data.Ball_Trail_Pos[I_Idx]
        if Pos_1 and Pos_2 then
            local P1_Pos, P1_On_Screen = Get_Screen_Position(Pos_1)
            local P2_Pos, P2_On_Screen = Get_Screen_Position(Pos_2)
            if P1_On_Screen and P2_On_Screen then
                local Color_Val, Opacity_Val = Get_Trail_Color_And_Opacity(Base_Offset, I_Idx, Total_Pos)
                Line_Obj.From = P1_Pos
                Line_Obj.To = P2_Pos
                Line_Obj.Color = Color_Val
                Line_Obj.Transparency = Opacity_Val
                Line_Obj.Thickness = Config_State.Trail_Thickness * (1.0 - math.pow(I_Idx / Total_Pos, 1.5))
                Line_Obj.Visible = true
            else
                Line_Obj.Visible = false
            end
        else
            Line_Obj.Visible = false
        end
    end
    for I_Idx = Total_Pos, #Visuals_Data.Ball_Lines do
        local Line_Obj = Visuals_Data.Ball_Lines[I_Idx]
        if Line_Obj then
            Line_Obj.Visible = false
        end
    end
end

local Is_Parried = false
local Parry_Range_Threshold = 0
local Parry_Accuracy_Value = 85
local Base_Extrapolation_Factor = 2
local Aero_Active = false
local Aero_Start_Time = 0
local Last_Speed = 0
local Last_Ball_Instance = nil
local Last_Distance = 9999
local Scheduled_Trigger_Time = 0
local Accumulated_Spam_Time = 0
local Panic_Accumulated_Time = 0
local Ball_Parries = 0
local Last_From_Change = 0
local Cached_From = nil

local Last_Tick_Time = Fast_Clock()
local Smoothed_Server_Fps = 60
local Cached_Character = nil
local Cached_Alive_Folder = nil

Run_Service.RenderStepped:Connect(function(Delta_Time)
    Delta_Time = Delta_Time or 0.016
    local Current_Render_Time = Fast_Clock()

    local Real_Ball_Visuals = Get_Real_Ball()
    local Best_Ball_Pos = nil
    if Real_Ball_Visuals and Real_Ball_Visuals:IsA("BasePart") then
        Best_Ball_Pos = Real_Ball_Visuals.Position
    end
    Update_And_Render_Trail(Best_Ball_Pos)

    if Config_State.Ability_Esp then
        local current_players = Players_Service:GetPlayers()
        for i = 1, #current_players do
            local player = current_players[i]
            if player == Local_Player then continue end
            local playerName = player.Name
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local isAlive = humanoid and humanoid.Health > 0
            local head = character and character:FindFirstChild("Head")
            local ability = player:GetAttribute("CurrentlyEquippedAbility")
            
            if isAlive and head and ability then
                local textObj = Visuals_Data.Esp_Texts[playerName]
                if not textObj then
                    textObj = Create_Esp_Text()
                    Visuals_Data.Esp_Texts[playerName] = textObj
                end
                
                local Current_Offset_Vector = Vector3.new(0, Config_State.Esp_Offset_Y, 0)
                local pos, onScreen = Get_Screen_Position(head.Position + Current_Offset_Vector)
                
                if onScreen and pos.X > 0 and pos.Y > 0 then
                    textObj.Size = Config_State.Esp_Text_Size
                    textObj.Position = pos
                    textObj.Text = tostring(ability)
                    if Config_State.Rainbow_Mode then
                        local r = (math.sin(Current_Render_Time * 2.5) * 0.5 + 0.5) * 0.95 + 0.05
                        local g = (math.sin(Current_Render_Time * 2.5 + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                        local b = (math.sin(Current_Render_Time * 2.5 + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                        textObj.Color = Color3.new(r, g, b)
                    else
                        textObj.Color = Config_State.Esp_Color
                    end
                    textObj.Visible = true
                else
                    textObj.Visible = false
                end
            else
                local textObj = Visuals_Data.Esp_Texts[playerName]
                if textObj then
                    textObj.Visible = false
                end
            end
        end

        for playerName, textObj in pairs(Visuals_Data.Esp_Texts) do
            if not Players_Service:FindFirstChild(playerName) then
                if textObj then textObj:Remove() end
                Visuals_Data.Esp_Texts[playerName] = nil
            end
        end
    else
        for playerName, textObj in pairs(Visuals_Data.Esp_Texts) do
            if textObj then
                textObj.Visible = false
            end
        end
    end

    if Config_State.Parry_Visualizer and Local_Player.Character then
        local Root_Part = Local_Player.Character:FindFirstChild("HumanoidRootPart")
        if Root_Part and Root_Part:IsA("BasePart") then
            local Root_Pos = Root_Part.Position - Vector3.new(0, 3, 0)
            local Target_Radius = Runtime_State.Parry_Range or 0
            Smooth_Parry_Radius = Smooth_Parry_Radius + (Target_Radius - Smooth_Parry_Radius) * Fast_Clamp(Delta_Time * 15, 0, 1)
            local Radius_Val = Fast_Max(Smooth_Parry_Radius, 5)
            local Segments_Count = Fast_Clamp(Config_State.Vis_Segments, 10, 100)
            local Angle_Step = Pi_2 / Segments_Count
            for I_Idx = 1, 100 do
                local Line_Obj = Visuals_Data.Sphere_Lines[I_Idx]
                if Line_Obj then
                    if I_Idx <= Segments_Count then
                        local Angle_1 = (I_Idx - 1) * Angle_Step
                        local Angle_2 = I_Idx * Angle_Step
                        local P1_3d = Root_Pos + Vector3.new(math.cos(Angle_1) * Radius_Val, 0, math.sin(Angle_1) * Radius_Val)
                        local P2_3d = Root_Pos + Vector3.new(math.cos(Angle_2) * Radius_Val, 0, math.sin(Angle_2) * Radius_Val)
                        local P1_Pos, On_Screen_1 = Get_Screen_Position(P1_3d)
                        local P2_Pos, On_Screen_2 = Get_Screen_Position(P2_3d)
                        if On_Screen_1 and On_Screen_2 then
                            Line_Obj.Visible = true
                            Line_Obj.From = P1_Pos
                            Line_Obj.To = P2_Pos
                            Line_Obj.Thickness = Config_State.Vis_Thickness
                            Line_Obj.Transparency = Config_State.Vis_Transparency
                            if Config_State.Rainbow_Mode then
                                local Offset_T = Current_Render_Time * 2.5 + (I_Idx / Segments_Count) * Pi_2
                                local Vis_R = (math.sin(Offset_T) * 0.5 + 0.5) * 0.95 + 0.05
                                local Vis_G = (math.sin(Offset_T + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                                local Vis_B = (math.sin(Offset_T + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                                Line_Obj.Color = Color3.new(Vis_R, Vis_G, Vis_B)
                            else
                                Line_Obj.Color = Config_State.Visualizer_Color
                            end
                        else
                            Line_Obj.Visible = false
                        end
                    else
                        Line_Obj.Visible = false
                    end
                end
            end
        end
    else
        for I_Idx = 1, 100 do 
            local Line_Obj = Visuals_Data.Sphere_Lines[I_Idx]
            if Line_Obj and Line_Obj.Visible then
                Line_Obj.Visible = false 
            end
        end
    end
end)

Run_Service.Heartbeat:Connect(function(Delta_Time)
    local Current_Time = Fast_Clock()
    local Tick_Delta = Current_Time - Last_Tick_Time
    Last_Tick_Time = Current_Time

    local Current_Char = Local_Player.Character
    if Current_Char and Current_Char ~= Cached_Character then
        Cached_Character = Current_Char
        if Config_State.Headless then pcall(function() Apply_Headless(true) end) end
        if Config_State.Korblox then pcall(function() Apply_Korblox(true) end) end
    end

    if Tick_Delta > 0 then
        Smoothed_Server_Fps = Smoothed_Server_Fps + ((1 / Tick_Delta) - Smoothed_Server_Fps) * 0.1
    end

    local Current_Delta_Time = Delta_Time or 0.016

    if Config_State.Infinity_Detection then
        local Is_Detected = false
        local Runtime_Folder = Workspace_Service:FindFirstChild("Runtime")
        if Runtime_Folder then
            if Runtime_Folder:FindFirstChild("InfinityFX") or Runtime_Folder:FindFirstChild("TrueInfinityFX") then
                Is_Detected = true
            end
        end
        local Current_Balls_Folder = Workspace_Service:FindFirstChild("Balls")
        if Current_Balls_Folder then
            for _, Current_Ball in ipairs(Current_Balls_Folder:GetChildren()) do
                if typeof(Current_Ball) == "Instance" and Current_Ball:IsA("BasePart") then
                    local Body_Part = Current_Ball:FindFirstChild("Body")
                    if Body_Part and Body_Part:FindFirstChild("WEMAZOOKIEGO") then
                        Is_Detected = true
                        break
                    end
                end
            end
        end
        if Local_Player.Character then
            if Local_Player.Character:FindFirstChild("Parry") then
                Is_Detected = true
            end
        end
        
        if Is_Detected then
            if Config_State.Auto_Parry then
                Config_State.Auto_Parry = false
                Config_State.Infinity_Disabled_Parry = true
            end
            if Config_State.Auto_Spam then
                Config_State.Auto_Spam = false
                Config_State.Infinity_Disabled_Spam = true
            end
            if Config_State.Trigger_Bot then
                Config_State.Trigger_Bot = false
                Config_State.Infinity_Disabled_Trigger = true
            end
        else
            if Config_State.Infinity_Disabled_Parry then
                Config_State.Auto_Parry = true
                Config_State.Infinity_Disabled_Parry = false
            end
            if Config_State.Infinity_Disabled_Spam then
                Config_State.Auto_Spam = true
                Config_State.Infinity_Disabled_Spam = false
            end
            if Config_State.Infinity_Disabled_Trigger then
                Config_State.Trigger_Bot = true
                Config_State.Infinity_Disabled_Trigger = false
            end
        end
    end

    if Config_State.Slashes_Of_Fury_Detection then
        local Is_Fury = false
        local Current_Balls_Folder = Workspace_Service:FindFirstChild("Balls")
        if Current_Balls_Folder then
            for _, Current_Ball in ipairs(Current_Balls_Folder:GetChildren()) do
                if Current_Ball:FindFirstChild("ComboCounter") then
                    local Target_Attr = Current_Ball:GetAttribute("target") or Current_Ball:GetAttribute("Target")
                    if Check_Is_Target(Target_Attr) then
                        Is_Fury = true
                    end
                    break
                end
            end
        end
        if not Is_Fury and Local_Player.Character then
            if Local_Player.Character:GetAttribute("FuryCatch") == true then
                Is_Fury = true
            end
        end
        if not Is_Fury then
            local Player_Gui = Local_Player:FindFirstChild("PlayerGui")
            if Player_Gui then
                local Fury_Timer = Player_Gui:FindFirstChild("FuryTimer")
                if Fury_Timer and Fury_Timer.Enabled then
                    Is_Fury = true
                end
            end
        end
        
        if Is_Fury and not Config_State.Fury_Triggered then
            Config_State.Fury_Triggered = true
            if Config_State.Auto_Parry then
                Config_State.Auto_Parry = false
                Config_State.Fury_Disabled_Parry = true
            end
            if Config_State.Auto_Spam then
                Config_State.Auto_Spam = false
                Config_State.Fury_Disabled_Spam = true
            end
            if Config_State.Trigger_Bot then
                Config_State.Trigger_Bot = false
                Config_State.Fury_Disabled_Trigger = true
            end
            task.spawn(function()
                while Config_State.Slashes_Of_Fury_Detection do
                    local Still_Fury = false
                    local Current_Combo = 0
                    local Current_Balls = Workspace_Service:FindFirstChild("Balls")
                    if Current_Balls then
                        for _, Current_Ball in ipairs(Current_Balls:GetChildren()) do
                            local Combo_Obj = Current_Ball:FindFirstChild("ComboCounter")
                            if Combo_Obj then
                                local Target_Attr = Current_Ball:GetAttribute("target") or Current_Ball:GetAttribute("Target")
                                if Check_Is_Target(Target_Attr) then
                                    Still_Fury = true
                                end
                                local Text_Label = Combo_Obj:FindFirstChild("TextLabel")
                                if Text_Label then
                                    Current_Combo = tonumber(Text_Label.Text) or 0
                                end
                                break
                            end
                        end
                    end
                    if not Still_Fury and Local_Player.Character then
                        if Local_Player.Character:GetAttribute("FuryCatch") == true then
                            Still_Fury = true
                        end
                    end
                    if not Still_Fury then
                        local Player_Gui = Local_Player:FindFirstChild("PlayerGui")
                        if Player_Gui then
                            local Fury_Timer = Player_Gui:FindFirstChild("FuryTimer")
                            if Fury_Timer and Fury_Timer.Enabled then
                                Still_Fury = true
                            end
                        end
                    end
                    if not Still_Fury or Current_Combo >= 34 then
                        break
                    end
                    Execute_Parry()
                    task.wait(0.15)
                end
                if Config_State.Fury_Disabled_Parry then
                    Config_State.Auto_Parry = true
                    Config_State.Fury_Disabled_Parry = false
                end
                if Config_State.Fury_Disabled_Spam then
                    Config_State.Auto_Spam = true
                    Config_State.Fury_Disabled_Spam = false
                end
                if Config_State.Fury_Disabled_Trigger then
                    Config_State.Trigger_Bot = true
                    Config_State.Fury_Disabled_Trigger = false
                end
                Config_State.Fury_Triggered = false
            end)
        end
        if not Is_Fury then
            Config_State.Fury_Triggered = false
        end
    else
        if Config_State.Fury_Disabled_Parry then
            Config_State.Auto_Parry = true
            Config_State.Fury_Disabled_Parry = false
        end
        if Config_State.Fury_Disabled_Spam then
            Config_State.Auto_Spam = true
            Config_State.Fury_Disabled_Spam = false
        end
        if Config_State.Fury_Disabled_Trigger then
            Config_State.Trigger_Bot = true
            Config_State.Fury_Disabled_Trigger = false
        end
        Config_State.Fury_Triggered = false
    end

    local Real_Ball = Get_Real_Ball()

    if not Real_Ball or not Real_Ball.Parent then
        if (Current_Time - Last_From_Change) > 0.5 then
            Cached_From = nil
            Ball_Parries = 0
        end
        Is_Parried = false
        Aero_Active = false
        Last_Speed = 0
        Last_Ball_Instance = nil
        Last_Distance = 9999
        Accumulated_Spam_Time = 0
        Panic_Accumulated_Time = 0
        Runtime_State.Target_Speed = 0
        Runtime_State.Target_Distance = 0
        Runtime_State.Target_Dot = 0
        Runtime_State.Parry_Range = 0
        return
    end

    if Real_Ball ~= Last_Ball_Instance then
        Last_Ball_Instance = Real_Ball
        Last_Distance = 9999
        Accumulated_Spam_Time = 0
        Panic_Accumulated_Time = 0
    end

    local Player_Character = Local_Player.Character
    if not Player_Character then return end

    local Root_Part = Player_Character.PrimaryPart
    if not Root_Part or not Root_Part:IsA("BasePart") or not Root_Part.Parent then return end

    if Player_Character:FindFirstChild("SingularityCape") or Root_Part:FindFirstChild("SingularityCape") then
        Is_Parried = false
        Accumulated_Spam_Time = 0
        Panic_Accumulated_Time = 0
        return
    end

    local Root_Position = Root_Part.Position
    local Ball_Position = Real_Ball.Position
    local Delta_Vector = Root_Position - Ball_Position
    local Current_Distance = Delta_Vector.Magnitude

    if Current_Distance == 0 then return end

    local Ball_Velocity = Real_Ball.AssemblyLinearVelocity
    if typeof(Ball_Velocity) ~= "Vector3" then Ball_Velocity = V3_Zero end
    local Current_Speed = Ball_Velocity.Magnitude

    local Velocity_Dir = Ball_Velocity.Magnitude > 0.01 and Ball_Velocity.Unit or V3_Zero
    local Direction_To_Player_Stat = Delta_Vector.Unit
    local Dot_Product_Stat = Direction_To_Player_Stat:Dot(Velocity_Dir)

    Runtime_State.Target_Speed = Current_Speed
    Runtime_State.Target_Distance = Current_Distance
    Runtime_State.Target_Dot = Dot_Product_Stat

    Current_Speed = Last_Speed + (Current_Speed - Last_Speed) * 0.25

    if Current_Speed < 15 then
        Last_Speed = Current_Speed
        return
    end

    local Aero_Visual_Effect = Real_Ball:FindFirstChild("AeroDynamicSlashVFX")
    local Is_Aero_Wait = false

    if Aero_Visual_Effect then
        if not Aero_Active then
            Aero_Active = true
            Aero_Start_Time = Current_Time
        end
        if (Current_Time - Aero_Start_Time) < 0.2 or Ball_Velocity.Y > 10 then
            Is_Aero_Wait = true
        end
    else
        Aero_Active = false
    end

    if Is_Aero_Wait then
        Last_Speed = Current_Speed
        Accumulated_Spam_Time = 0
        return
    end

    local Current_From_Attr = Real_Ball:GetAttribute("from") or Real_Ball:GetAttribute("From")

    if Current_From_Attr ~= nil and Current_From_Attr ~= Cached_From then
        local Time_Difference = Current_Time - Last_From_Change
        if Time_Difference <= 0.35 then
            Ball_Parries = Ball_Parries + 1
        else
            Ball_Parries = 1
        end
        Cached_From = Current_From_Attr
        Last_From_Change = Current_Time
    end

    local Current_Target_Attr = Real_Ball:GetAttribute("target") or Real_Ball:GetAttribute("Target")
    local Is_Target_Me = false
    if (Player_Character and Player_Character:FindFirstChild("Highlight")) or Check_Is_Target(Current_Target_Attr) then
        Is_Target_Me = true
    end

    local Network_Ping = Get_Memory_Ping()
    local Nearest_Player, Distance_To_Nearest_Player = Scan_For_Nearest_Entity(Root_Position)

    local Dead_Folder = Workspace_Service:FindFirstChild("Dead")
    local Is_Dead = Dead_Folder and Dead_Folder:FindFirstChild(Local_Player.Name) ~= nil
    local Is_Training_Ball = Real_Ball.Parent and Real_Ball.Parent.Name == "TrainingBalls"
    local Can_Attack = (not Is_Dead) and (not Is_Training_Ball)

    local Spam_Params = {
        Speed = Current_Speed,
        Parries = Ball_Parries,
        Ball_Distance = Current_Distance,
        Entity_Distance = Distance_To_Nearest_Player,
        Dot = Dot_Product_Stat,
        Ping = Network_Ping
    }

    local Auto_Spam_Active = false
    if Config_State.Auto_Spam and Can_Attack then
        Auto_Spam_Active, _ = Check_Is_Spam(Spam_Params)
    end

    if Auto_Spam_Active then
        local Target_Cps = Fast_Max(Config_State.Spam_Rate, 1)
        local Tickrate_Compensation = 60 / Fast_Max(Smoothed_Server_Fps, 1)
        local Server_Aligned_Delta = Current_Delta_Time * Tickrate_Compensation
        local Spam_Interval = 1 / Target_Cps

        Accumulated_Spam_Time = Accumulated_Spam_Time + Server_Aligned_Delta

        if Accumulated_Spam_Time >= Spam_Interval then
            local Click_Count = Fast_Floor(Accumulated_Spam_Time / Spam_Interval)
            Accumulated_Spam_Time = Accumulated_Spam_Time % Spam_Interval
            for I_Idx = 1, Click_Count do
                Execute_Parry()
            end
        end
        Is_Parried = true
        Last_Speed = Current_Speed
        Last_Distance = Current_Distance
        return
    else
        Accumulated_Spam_Time = 0
    end

    if Config_State.Panic_Spam then
        local Target_Cps = 200
        local Tickrate_Compensation = 60 / Fast_Max(Smoothed_Server_Fps, 1)
        local Server_Aligned_Delta = Current_Delta_Time * Tickrate_Compensation
        local Panic_Interval = 1 / Target_Cps
        
        local Panic_Max_Distance = 25
        local Danger_Zone_Radius = 15
        local Closest_Enemy_Distance_Sq = math.huge
        local Enemy_Look_Dot = 0
        
        if not Cached_Alive_Folder then
            Cached_Alive_Folder = Workspace_Service:FindFirstChild("Alive")
        end
        
        if Cached_Alive_Folder then
            for _, Obj_Val in ipairs(Cached_Alive_Folder:GetChildren()) do
                if Obj_Val ~= Player_Character and Obj_Val.Name ~= Local_Player.Name then
                    local Enemy_Humanoid = Obj_Val:FindFirstChildWhichIsA("Humanoid")
                    local Enemy_Root = Obj_Val:FindFirstChild("HumanoidRootPart") or Obj_Val.PrimaryPart
                    if Enemy_Humanoid and Enemy_Humanoid.Health > 0 and Enemy_Root and Enemy_Root:IsA("BasePart") then
                        local Dist_Sq = Get_Distance_Squared(Enemy_Root.Position, Root_Position)
                        if Dist_Sq < Closest_Enemy_Distance_Sq then
                            Closest_Enemy_Distance_Sq = Dist_Sq
                            local CF_Val = Enemy_Root.CFrame
                            if CF_Val then
                                local Direction_To_Me = (Root_Position - Enemy_Root.Position).Unit
                                Enemy_Look_Dot = CF_Val.LookVector:Dot(Direction_To_Me)
                            end
                        end
                    end
                end
            end
        end

        local Closest_Enemy_Distance = Fast_Sqrt(Closest_Enemy_Distance_Sq)
        local Is_Enemy_Close = Closest_Enemy_Distance <= Panic_Max_Distance
        local Ball_Direction = Ball_Velocity.Magnitude > 0.01 and Ball_Velocity.Unit or V3_Zero
        local Ball_Dot_To_Me = Ball_Direction:Dot(Direction_To_Player_Stat)

        local Dynamic_Dot_Threshold = Fast_Max(0.40, (Current_Distance / Panic_Max_Distance) * 0.75)
        local Angle_To_Player = math.deg(math.acos(Fast_Clamp(Ball_Dot_To_Me, -1, 1)))
        local Dynamic_Angle_Threshold = Fast_Clamp(180 - (Current_Distance * 2), 25, 75)

        local Is_Heading_Towards = (Angle_To_Player <= Dynamic_Angle_Threshold) or (Ball_Dot_To_Me > Dynamic_Dot_Threshold)
        local Is_Extremely_Close = Current_Distance <= Danger_Zone_Radius
        local Is_Approaching = Current_Distance < Last_Distance

        local Is_Clash = Is_Enemy_Close and Current_Speed > 35 and Enemy_Look_Dot > 0.55 and (Is_Approaching or Is_Extremely_Close) and (Is_Heading_Towards or Is_Extremely_Close)

        if Is_Clash then
            Panic_Accumulated_Time = Panic_Accumulated_Time + Server_Aligned_Delta
            if Panic_Accumulated_Time >= Panic_Interval then
                local Click_Count = Fast_Floor(Panic_Accumulated_Time / Panic_Interval)
                Panic_Accumulated_Time = Panic_Accumulated_Time % Panic_Interval
                for I_Idx = 1, Fast_Min(Click_Count, 15) do
                    Execute_Parry()
                end
            end
        else
            Panic_Accumulated_Time = 0
        end
    end

    local Can_Trigger = Is_Target_Me
    if Config_State.Trigger_Ignore_Spawn and Ball_Parries == 0 then
        Can_Trigger = false
    end

    if Config_State.Trigger_Bot and Can_Attack then
        if Can_Trigger and not Is_Parried then
            local Application_Tick = Fast_Clock()
            if Scheduled_Trigger_Time == 0 then
                local Target_Ping = Network_Ping / 10
                local Server_Tick = 1 / Fast_Max(Smoothed_Server_Fps, 1)
                local Compensation_Time = (Target_Ping / 1000) + Current_Delta_Time + Server_Tick
                local Base_Delay = Config_State.Trigger_Delay / 1000
                local Final_Delay = Fast_Max(0, Base_Delay - Compensation_Time)
                Scheduled_Trigger_Time = Application_Tick + Final_Delay
            end
            
            if Scheduled_Trigger_Time > 0 and Application_Tick >= Scheduled_Trigger_Time then
                Is_Parried = true
                Execute_Parry()
                Scheduled_Trigger_Time = 0
            end
        elseif not Can_Trigger then
            Scheduled_Trigger_Time = 0
        end
    else
        Scheduled_Trigger_Time = 0
    end

    if Is_Target_Me then
        if Is_Parried then
            Last_Speed = Current_Speed
            Last_Distance = Current_Distance
            return
        end

        local Ping_Num = Get_Memory_Ping()
        local Adjusted_Ping = Ping_Num / 10

        local Tickrate_Compensation = 60 / Fast_Max(Smoothed_Server_Fps, 1)
        local Distance_Per_Tick = Current_Speed * Tick_Delta
        local Frame_Compensation = Distance_Per_Tick * Base_Extrapolation_Factor * Tickrate_Compensation
        local Segment_Line_Distance = Current_Speed * (Tick_Delta + (Adjusted_Ping / 100)) * Base_Extrapolation_Factor * Tickrate_Compensation
        local Speed_Divisor_Multiplier = (0.85 + (Parry_Accuracy_Value - 1) * (0.35 / 99)) - (Adjusted_Ping * 0.001) - (Segment_Line_Distance * 0.002)
        
        local Dot_Product_Parry = 0
        if Current_Distance > 0.01 and Current_Speed > 0.01 then
            Dot_Product_Parry = Direction_To_Player_Stat:Dot(Velocity_Dir)
        end

        local Speed_Difference_Parry = Fast_Max(Current_Speed - 15, 0)
        local Speed_Divisor_Base_Parry = 2.4 + (Speed_Difference_Parry * 0.002)
        local Speed_Divisor_Parry = Speed_Divisor_Base_Parry * Speed_Divisor_Multiplier

        local Base_Parry_Accuracy = Adjusted_Ping + Fast_Max(Current_Speed / Speed_Divisor_Parry, 15)
        local Final_Threshold = Base_Parry_Accuracy + Frame_Compensation + Parry_Range_Threshold

        Runtime_State.Parry_Range = Final_Threshold

        local Close_Range_Threshold = Fast_Max(20, Final_Threshold * 0.5)

        local Is_Curved = false
        local Dot_Distance_Threshold = 30.0
        local Dot_Limit_Threshold = 55.0

        if Current_Speed > 15 then
            local Distance_Ratio = Fast_Clamp((Current_Distance - Dot_Distance_Threshold) / Dot_Limit_Threshold, 0, 1)
            local Max_Dot_Threshold = 0.82
            local Min_Dot_Threshold = 0.35
            local Dynamic_Dot = Min_Dot_Threshold + (Max_Dot_Threshold - Min_Dot_Threshold) * math.pow(Distance_Ratio, 1.5)
            
            local Target_Ping = Network_Ping / 10
            local Server_Tick = 1 / Fast_Max(Smoothed_Server_Fps, 1)
            local Curve_Compensation = (Target_Ping / 1000) + Current_Delta_Time + Server_Tick
            
            local Dot_Threshold = Dynamic_Dot - (Curve_Compensation * 0.15)
            
            if Current_Distance > Close_Range_Threshold and Dot_Product_Parry < Dot_Threshold then
                Is_Curved = true
            end
        end

        local Is_Moving_Away = Current_Distance > Last_Distance + 0.15

        if Current_Distance <= Final_Threshold and not Is_Moving_Away and not Is_Curved then
            if Config_State.Auto_Parry then
                Is_Parried = true
                Execute_Parry()
            end
        end
    else
        Is_Parried = false
    end

    Last_Speed = Current_Speed
    Last_Distance = Current_Distance
end)

task.spawn(function()
    while true do
        if Config_State.Headless then pcall(function() Apply_Headless(true) end) end
        if Config_State.Korblox then pcall(function() Apply_Korblox(true) end) end
        if task and task.wait then task.wait(1) else wait(1) end
    end
end)
