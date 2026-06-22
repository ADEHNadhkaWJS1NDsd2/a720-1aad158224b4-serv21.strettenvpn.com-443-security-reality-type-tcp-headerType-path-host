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
local Virtual_Input_Manager = game:GetService("VirtualInputManager")

local Local_Player = Players_Service.LocalPlayer or Players_Service.PlayerAdded:Wait()
local Fast_Max = math.max
local Fast_Min = math.min
local Fast_Floor = math.floor
local Fast_Clamp = math.clamp
local Fast_Sqrt = math.sqrt
local Fast_Clock = os.clock
local V3_Zero = Vector3.zero

local Lib_Instance = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.lua"))()
if type(Lib_Instance) ~= "table" then Lib_Instance = INSui end

Lib_Instance:ApplyThemePreset("Indigo")

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
    Spam_Sensitivity = 1.0,
    Trigger_Bot = false,
    Dont_Click_On_Spawn = true,
    Trigger_Delay = 0,
    Parry_Visualizer = false,
    Visualizer_Color = Color3.fromRGB(122, 134, 255),
    Ball_Trail = false,
    Trail_Color = Color3.fromRGB(122, 134, 255),
    Ability_Esp = false,
    Esp_Color = Color3.fromRGB(122, 134, 255),
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
    Parry_Range = 10
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
Parry_Section:Dropdown("Parry Method", {"Click"}, {"Click", "Key"}, false, function(Value_In) Config_State.Parry_Method = Value_In end)
Parry_Section:Toggle("Training Balls", false, function(Value_In) Config_State.Training_Balls_Support = Value_In end)

local Spam_Section = Combat_Tab:Section("Auto Spam", "Right")
Spam_Section:Toggle("Auto Spam", false, function(Value_In) Config_State.Auto_Spam = Value_In end):AddKeybind("None", "Toggle")
Spam_Section:Slider("Spam Rate", 200, 10, 10, 500, "cps", function(Value_In) Config_State.Spam_Rate = Value_In end)
Spam_Section:Slider("Spam Sensitivity", 1.0, 0.1, 0.1, 2.0, "", function(Value_In) Config_State.Spam_Sensitivity = Value_In end)

local Trigger_Section = Combat_Tab:Section("Trigger Bot", "Right")
Trigger_Section:Toggle("Trigger Bot", false, function(Value_In) Config_State.Trigger_Bot = Value_In end):AddKeybind("None", "Toggle")
Trigger_Section:Toggle("Ignore Ball Spawn", true, function(Value_In) Config_State.Dont_Click_On_Spawn = Value_In end)
Trigger_Section:Slider("Delay", 0, 1, 0, 100, "ms", function(Value_In) Config_State.Trigger_Delay = Value_In end)

local Visuals_Tab = Win_App:Tab("Visuals", "eye")

local Vis_Main_Section = Visuals_Tab:Section("Visuals", "Left")
Vis_Main_Section:Toggle("Range Visualiser", false, function(Value_In) Config_State.Parry_Visualizer = Value_In end):AddColorpicker("Vis Color", Color3.fromRGB(122, 134, 255), function(Color_Val) Config_State.Visualizer_Color = Color_Val end)
Vis_Main_Section:Toggle("Ball Trail", false, function(Value_In) Config_State.Ball_Trail = Value_In end):AddColorpicker("Trail Color", Color3.fromRGB(122, 134, 255), function(Color_Val) Config_State.Trail_Color = Color_Val end)
Vis_Main_Section:Toggle("Ability ESP", false, function(Value_In) Config_State.Ability_Esp = Value_In end):AddColorpicker("ESP Color", Color3.fromRGB(122, 134, 255), function(Color_Val) Config_State.Esp_Color = Color_Val end)
Vis_Main_Section:Toggle("Rainbow Mode", false, function(Value_In) Config_State.Rainbow_Mode = Value_In end)

local Vis_Avatar_Section = Visuals_Tab:Section("Avatar Mods", "Right")

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

local Trail_Length_Limit = 60
local Trail_Refresh_Rate = 0.01

local function Create_Esp_Text()
    local Text_Obj = Drawing.new("Text")
    Text_Obj.Size = 18
    Text_Obj.Center = true
    Text_Obj.Outline = true
    Text_Obj.Font = 2
    Text_Obj.Visible = false
    table.insert(_G.Nightfall_Drawings, Text_Obj)
    return Text_Obj
end

if type(Drawing) == "table" and Drawing.new then
    for I_Idx = 1, 40 do
        pcall(function()
            local Line_Obj = Drawing.new("Line")
            Line_Obj.Thickness = 2
            Line_Obj.Visible = false
            Visuals_Data.Sphere_Lines[I_Idx] = Line_Obj
            table.insert(_G.Nightfall_Drawings, Line_Obj)
        end)
    end
    for I_Idx = 1, Trail_Length_Limit do
        pcall(function()
            local Line_Obj = Drawing.new("Line")
            Line_Obj.Visible = false
            Visuals_Data.Ball_Lines[I_Idx] = Line_Obj
            table.insert(_G.Nightfall_Drawings, Line_Obj)
        end)
    end
end

local Smooth_Parry_Radius = 10
local Has_M1_Click = type(mouse1click) == "function"

local function Get_Screen_Position(World_Pos)
    if type(WorldToScreen) == "function" then
        local Screen_Pos, Is_Visible = WorldToScreen(World_Pos)
        return Screen_Pos, Is_Visible
    end
    
    local Camera_Object = Workspace_Service.CurrentCamera
    if not Camera_Object then return Vector2.new(0, 0), false end
    
    local Success_State, P2d_Val = pcall(function() return Camera_Object:WorldToViewportPoint(World_Pos) end)
    if Success_State and P2d_Val then
        return Vector2.new(P2d_Val.X, P2d_Val.Y), P2d_Val.Z > 0
    end
    
    return Vector2.new(0, 0), false
end

local function Get_Real_Ball()
    if Config_State.Training_Balls_Support then
        local Training_Folder = Workspace_Service:FindFirstChild("TrainingBalls")
        if Training_Folder then
            for _, Current_Ball in ipairs(Training_Folder:GetChildren()) do
                if Current_Ball:IsA("BasePart") and Current_Ball:GetAttribute("realBall") == true then
                    return Current_Ball
                end
            end
            for _, Current_Ball in ipairs(Training_Folder:GetChildren()) do
                if Current_Ball:IsA("BasePart") then
                    return Current_Ball
                end
            end
        end
    end

    local Normal_Balls = Workspace_Service:FindFirstChild("Balls")
    
    if Normal_Balls then
        for _, Current_Ball in ipairs(Normal_Balls:GetChildren()) do
            if Current_Ball:IsA("BasePart") and Current_Ball:GetAttribute("realBall") == true then
                return Current_Ball
            end
        end
        for _, Current_Ball in ipairs(Normal_Balls:GetChildren()) do
            if Current_Ball:IsA("BasePart") then
                return Current_Ball
            end
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

local function Execute_Parry()
    if Has_M1_Click then
        mouse1click()
    else
        Virtual_Input_Manager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        Virtual_Input_Manager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end
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
            local Humanoid_Part = Target_Player.Character:FindFirstChild("Humanoid")
            if Root_Part and Humanoid_Part and Humanoid_Part.Health > 0 then
                local Current_Dist_Sq = Get_Distance_Squared(Player_Position, Root_Part.Position)
                if Current_Dist_Sq < Minimum_Distance_Sq then
                    Minimum_Distance_Sq = Current_Dist_Sq
                    Nearest_Entity = Target_Player
                end
            end
        end
    end
    return Nearest_Entity, Fast_Sqrt(Minimum_Distance_Sq)
end

local Configuration_Spam = {
    Spam_Min_Distance_Speed_Divisor = 6.5,
    Spam_Max_Speed_Divisor = 5.0,
    Spam_Min_Distance = 95.0,
    Spam_Max_Distance = 30.0,
    Spam_Threshold = 5
}

local function Check_Is_Spam(Spam_Params)
    local Scaled_Ping = Spam_Params.Ping / 10
    local Base_Range = Scaled_Ping + Fast_Min(Spam_Params.Speed / Configuration_Spam.Spam_Min_Distance_Speed_Divisor, Configuration_Spam.Spam_Min_Distance)
    local Range_Val = Base_Range * Config_State.Spam_Sensitivity
    
    if Spam_Params.Entity_Distance > Range_Val then return false, Spam_Params.Parries end
    if Spam_Params.Ball_Distance > Range_Val then return false, Spam_Params.Parries end
    
    local Maximum_Speed = Configuration_Spam.Spam_Max_Speed_Divisor - Fast_Min(Spam_Params.Speed / Configuration_Spam.Spam_Max_Speed_Divisor, Configuration_Spam.Spam_Max_Speed_Divisor)
    local Maximum_Dot = Fast_Clamp(Spam_Params.Dot, -1, 0) * Maximum_Speed
    local Accuracy_Val = Fast_Min(Range_Val - Maximum_Dot, Configuration_Spam.Spam_Max_Distance) * Config_State.Spam_Sensitivity
    
    if Spam_Params.Ball_Distance > Accuracy_Val then return false, Spam_Params.Parries end
    if Spam_Params.Parries < Configuration_Spam.Spam_Threshold then return false, Spam_Params.Parries end
    
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
    if not Config_State.Ball_Trail or not Best_Pos then
        for _, Line_Obj in ipairs(Visuals_Data.Ball_Lines) do Line_Obj.Visible = false end
        if not Best_Pos then Visuals_Data.Ball_Trail_Pos = {} end
        return
    end

    local Current_Time = Fast_Clock()
    if Current_Time - Visuals_Data.Trail_Time >= Trail_Refresh_Rate then
        Visuals_Data.Trail_Time = Current_Time
        table.insert(Visuals_Data.Ball_Trail_Pos, 1, Best_Pos)
        if #Visuals_Data.Ball_Trail_Pos > Trail_Length_Limit then 
            table.remove(Visuals_Data.Ball_Trail_Pos) 
        end
    end

    local Total_Pos = #Visuals_Data.Ball_Trail_Pos
    if Total_Pos < 2 then
        for _, Line_Obj in ipairs(Visuals_Data.Ball_Lines) do Line_Obj.Visible = false end
        return
    end

    local Base_Offset = Fast_Clock() * 1.5

    for I_Idx = 2, Total_Pos do
        local Line_Obj = Visuals_Data.Ball_Lines[I_Idx - 1]
        if not Line_Obj then break end

        local P1_Pos, P1_On_Screen = Get_Screen_Position(Visuals_Data.Ball_Trail_Pos[I_Idx - 1])
        local P2_Pos, P2_On_Screen = Get_Screen_Position(Visuals_Data.Ball_Trail_Pos[I_Idx])

        if P1_On_Screen and P2_On_Screen then
            local Color_Val, Opacity_Val = Get_Trail_Color_And_Opacity(Base_Offset, I_Idx, Total_Pos)
            Line_Obj.From = P1_Pos
            Line_Obj.To = P2_Pos
            Line_Obj.Color = Color_Val
            Line_Obj.Transparency = Opacity_Val
            Line_Obj.Thickness = 2.0 + math.pow(1.0 - (I_Idx / Total_Pos), 1.5) * 4.5
            Line_Obj.Visible = true
        else
            Line_Obj.Visible = false
        end
    end

    for I_Idx = Total_Pos, #Visuals_Data.Ball_Lines do
        if Visuals_Data.Ball_Lines[I_Idx] then
            Visuals_Data.Ball_Lines[I_Idx].Visible = false
        end
    end
end

local Is_Parried = false
local Speed_Divisor_Factor = 1.1
local Effective_Divisor = 1.05
local Base_Extrapolation_Frames = 2.5
local Parry_Range_Threshold = 10
local Aero_Active = false
local Aero_Start_Time = 0
local Last_Speed = 0
local Last_Ball_Instance = nil
local Last_Distance = 9999
local Min_Tb_Delay = 1 
local Max_Tb_Delay = 50
local Scheduled_Trigger_Time = 0
local Cooldown_End_Time = 0 
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
    local Best_Ball_Pos = Real_Ball_Visuals and Real_Ball_Visuals.Position or nil
    Update_And_Render_Trail(Best_Ball_Pos)

    local Current_Players = Players_Service:GetPlayers()
    for _, Target_Player in pairs(Current_Players) do
        if Target_Player == Local_Player then continue end
        
        local Char_Obj = Target_Player.Character
        local Head_Obj = Char_Obj and Char_Obj:FindFirstChild("Head")
        local Ability_Val = Target_Player:GetAttribute("CurrentlyEquippedAbility")
        
        if Config_State.Ability_Esp and Head_Obj and Ability_Val then
            if not Visuals_Data.Esp_Texts[Target_Player] then
                Visuals_Data.Esp_Texts[Target_Player] = Create_Esp_Text()
            end
            
            local Pos_Val, On_Screen = Get_Screen_Position(Head_Obj.Position + Vector3.new(0, 2, 0))
            local Text_Obj = Visuals_Data.Esp_Texts[Target_Player]
            
            if On_Screen then
                Text_Obj.Position = Pos_Val
                Text_Obj.Text = tostring(Ability_Val)
                if Config_State.Rainbow_Mode then
                    local R_Val = (math.sin(Current_Render_Time * 2.5) * 0.5 + 0.5) * 0.95 + 0.05
                    local G_Val = (math.sin(Current_Render_Time * 2.5 + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                    local B_Val = (math.sin(Current_Render_Time * 2.5 + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                    Text_Obj.Color = Color3.new(R_Val, G_Val, B_Val)
                else
                    Text_Obj.Color = Config_State.Esp_Color
                end
                Text_Obj.Visible = true
            else
                Text_Obj.Visible = false
            end
        else
            if Visuals_Data.Esp_Texts[Target_Player] then
                Visuals_Data.Esp_Texts[Target_Player].Visible = false
            end
        end
    end

    for Player_Key, Text_Obj in pairs(Visuals_Data.Esp_Texts) do
        local Found_Player = false
        for _, P_Obj in pairs(Current_Players) do
            if P_Obj == Player_Key then
                Found_Player = true
                break
            end
        end
        if not Found_Player then
            Text_Obj:Remove()
            Visuals_Data.Esp_Texts[Player_Key] = nil
        end
    end

    if Config_State.Parry_Visualizer and Local_Player.Character and Local_Player.Character:FindFirstChild("HumanoidRootPart") then
        local Root_Part = Local_Player.Character.HumanoidRootPart
        if Root_Part and Root_Part.Parent then
            local Root_Pos = Root_Part.Position - Vector3.new(0, 3, 0)
            local Target_Radius = Runtime_State.Parry_Range or 10
            Smooth_Parry_Radius = Smooth_Parry_Radius + (Target_Radius - Smooth_Parry_Radius) * Fast_Clamp(Delta_Time * 15, 0, 1)
            
            local Radius_Val = Fast_Max(Smooth_Parry_Radius, 5)
            local Segments_Count = 40
            local Angle_Step = (math.pi * 2) / Segments_Count
            
            for I_Idx = 1, Segments_Count do
                local Line_Obj = Visuals_Data.Sphere_Lines[I_Idx]
                if Line_Obj then
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
                        
                        if Config_State.Rainbow_Mode then
                            local Offset_T = Current_Render_Time * 2.5 + (I_Idx / Segments_Count) * math.pi * 2
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
                end
            end
        end
    else
        for I_Idx = 1, 40 do 
            local Line_Obj = Visuals_Data.Sphere_Lines[I_Idx]
            if Line_Obj then
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
        if Config_State.Headless then Apply_Headless(true) end
        if Config_State.Korblox then Apply_Korblox(true) end
    end

    if Tick_Delta > 0 then
        Smoothed_Server_Fps = Smoothed_Server_Fps + ((1 / Tick_Delta) - Smoothed_Server_Fps) * 0.1
    end

    local Lag_Compensation_Factor = Fast_Clamp(math.pow(60 / Fast_Max(Smoothed_Server_Fps, 10), 1.15), 1, 3.5)
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
                    Is_Fury = true
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
        if not Is_Fury then
            for _, Current_Plr in ipairs(Players_Service:GetPlayers()) do
                if Current_Plr.Character and Current_Plr.Character:FindFirstChild("FuryHighlight") then
                    Is_Fury = true
                    break
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
                                Still_Fury = true
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
                    if not Still_Fury then
                        for _, Current_Plr in ipairs(Players_Service:GetPlayers()) do
                            if Current_Plr.Character and Current_Plr.Character:FindFirstChild("FuryHighlight") then
                                Still_Fury = true
                                break
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
        Runtime_State.Parry_Range = 10
        return
    end

    if Real_Ball ~= Last_Ball_Instance then
        Last_Ball_Instance = Real_Ball
        Last_Distance = 9999
        Accumulated_Spam_Time = 0
        Panic_Accumulated_Time = 0
    end

    local Player_Character = Local_Player.Character
    if not Player_Character or not Player_Character.PrimaryPart then return end

    local Root_Part = Player_Character.PrimaryPart
    if not Root_Part or not Root_Part.Parent then return end

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

    if Current_Speed < 0.1 then
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
        if Time_Difference <= 0.65 then
            Ball_Parries = Ball_Parries + 1
        else
            Ball_Parries = 1
        end
        Cached_From = Current_From_Attr
        Last_From_Change = Current_Time
    end

    local Current_Target_Attr = Real_Ball:GetAttribute("target") or Real_Ball:GetAttribute("Target")
    local Network_Ping = Get_Memory_Ping()
    local Is_Target_Me = Check_Is_Target(Current_Target_Attr)

    local Direction_To_Player = (Root_Position - Ball_Position).Unit
    local Trajectory_Dot_Product = Direction_To_Player:Dot(Velocity_Dir)
    local Nearest_Player, Distance_To_Nearest_Player = Scan_For_Nearest_Entity(Root_Position)

    local Spam_Params = {
        Speed = Current_Speed,
        Parries = Ball_Parries,
        Ball_Distance = Current_Distance,
        Entity_Distance = Distance_To_Nearest_Player,
        Dot = Trajectory_Dot_Product,
        Ping = Network_Ping
    }

    local Auto_Spam_Active = false
    if Config_State.Auto_Spam then
        Auto_Spam_Active, _ = Check_Is_Spam(Spam_Params)
    end

    if Auto_Spam_Active then
        local Target_Cps = Fast_Max(Config_State.Spam_Rate, 1)
        Accumulated_Spam_Time = Accumulated_Spam_Time + (Current_Delta_Time * Target_Cps)
        local Click_Count = Fast_Floor(Accumulated_Spam_Time)
        if Click_Count > 0 then
            Accumulated_Spam_Time = Accumulated_Spam_Time - Click_Count
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
                    if Enemy_Humanoid and Enemy_Humanoid.Health > 0 and Enemy_Root then
                        local Dist_Sq = Get_Distance_Squared(Enemy_Root.Position, Root_Position)
                        if Dist_Sq < Closest_Enemy_Distance_Sq then
                            Closest_Enemy_Distance_Sq = Dist_Sq
                            local Direction_To_Me = (Root_Position - Enemy_Root.Position).Unit
                            Enemy_Look_Dot = Enemy_Root.CFrame.LookVector:Dot(Direction_To_Me)
                        end
                    end
                end
            end
        end

        local Closest_Enemy_Distance = Fast_Sqrt(Closest_Enemy_Distance_Sq)
        local Is_Enemy_Close = Closest_Enemy_Distance <= Panic_Max_Distance
        local Ball_Direction = Ball_Velocity.Magnitude > 0.01 and Ball_Velocity.Unit or V3_Zero
        local Ball_Dot_To_Me = Ball_Direction:Dot(Direction_To_Player)

        local Dynamic_Dot_Threshold = Fast_Max(0.40, (Current_Distance / Panic_Max_Distance) * 0.75)
        local Angle_To_Player = math.deg(math.acos(Fast_Clamp(Ball_Dot_To_Me, -1, 1)))
        local Dynamic_Angle_Threshold = Fast_Clamp(180 - (Current_Distance * 2), 25, 75)

        local Is_Heading_Towards = (Angle_To_Player <= Dynamic_Angle_Threshold) or (Ball_Dot_To_Me > Dynamic_Dot_Threshold)
        local Is_Extremely_Close = Current_Distance <= Danger_Zone_Radius
        local Is_Approaching = Current_Distance < Last_Distance

        local Is_Clash = Is_Enemy_Close and Current_Speed > 35 and Enemy_Look_Dot > 0.55 and (Is_Approaching or Is_Extremely_Close) and (Is_Heading_Towards or Is_Extremely_Close)

        if Is_Clash then
            Panic_Accumulated_Time = Panic_Accumulated_Time + (Current_Delta_Time * Target_Cps)
            local Click_Count = Fast_Floor(Panic_Accumulated_Time)
            if Click_Count > 0 then
                Panic_Accumulated_Time = Panic_Accumulated_Time - Click_Count
                for I_Idx = 1, Fast_Min(Click_Count, 15) do
                    Execute_Parry()
                end
            end
        else
            Panic_Accumulated_Time = 0
        end
    end

    if Config_State.Trigger_Bot then
        local Application_Tick = Fast_Clock()
        if Application_Tick >= Cooldown_End_Time then
            if not (Config_State.Dont_Click_On_Spawn and Ball_Parries == 0) then
                if Is_Target_Me then
                    if Scheduled_Trigger_Time == 0 then
                        local Randomized_Delay = math.random(Fast_Min(Min_Tb_Delay, Max_Tb_Delay), Fast_Max(Min_Tb_Delay, Max_Tb_Delay)) / 1000
                        Scheduled_Trigger_Time = Application_Tick + Randomized_Delay
                    end
                else
                    Scheduled_Trigger_Time = 0
                end
                
                if Is_Target_Me and Scheduled_Trigger_Time > 0 then
                    if Application_Tick >= Scheduled_Trigger_Time then
                        Is_Parried = true
                        Execute_Parry()
                        Scheduled_Trigger_Time = 0
                        Cooldown_End_Time = Application_Tick + 0.4
                    end
                end
            else
                Scheduled_Trigger_Time = 0
            end
        end
    else
        Scheduled_Trigger_Time = 0
    end

    local Speed_Difference = Fast_Max(Current_Speed - 9.5, 0)
    local Speed_Divisor_Base = 2.4 + (math.log10(Speed_Difference + 1) * math.pow(Speed_Difference, 0.45) * 0.08)
    local Speed_Divisor = Speed_Divisor_Base * Speed_Divisor_Factor * Effective_Divisor

    local Exponential_Decay_Rate = Fast_Max(30, math.pow(Current_Speed, 0.85))
    local Distance_Multiplier = 1.0 + (math.exp(-Current_Distance / Exponential_Decay_Rate) * 1.8)

    local Server_Tick_Rate = Fast_Max(Smoothed_Server_Fps, 10)
    local Ping_Sec = Network_Ping / 1000
    local Shadow_Distance = Current_Speed * (Ping_Sec + (1 / Server_Tick_Rate))

    local Speed_Delta = Fast_Max(Current_Speed - Last_Speed, 0)
    local Accelerated_Speed = Current_Speed + Speed_Delta
    local Distance_Per_Tick = Accelerated_Speed * Current_Delta_Time * Lag_Compensation_Factor
    local Dynamic_Frames = (Base_Extrapolation_Frames + (math.log10(Current_Speed + 10) * 0.6)) * Lag_Compensation_Factor

    local Projection_Magnitude = Fast_Min(Distance_Per_Tick * Dynamic_Frames, Fast_Clamp(Current_Speed * 0.35, 10, 70))
    local Projected_Ball_Position = Ball_Position + (Velocity_Dir * Projection_Magnitude)
    
    local Projected_Delta_Vector = Root_Position - Projected_Ball_Position
    local Projected_Distance = Projected_Delta_Vector.Magnitude
    local Projected_Direction = Projected_Distance > 0.01 and Projected_Delta_Vector.Unit or V3_Zero

    local Final_Threshold = (Fast_Max((Current_Speed / Speed_Divisor), Parry_Range_Threshold) + Shadow_Distance) * Distance_Multiplier
    local Final_Threshold_Sq = Final_Threshold * Final_Threshold
    Runtime_State.Parry_Range = Final_Threshold

    if Is_Target_Me then
        if Is_Parried then
            Last_Speed = Current_Speed
            Last_Distance = Current_Distance
            return
        end
        
        local Segment_Vector = Ball_Velocity * Current_Delta_Time * Dynamic_Frames
        local Player_To_Proj_Vector = Root_Position - Projected_Ball_Position
        local Segment_Length_Squared = Segment_Vector.X * Segment_Vector.X + Segment_Vector.Y * Segment_Vector.Y + Segment_Vector.Z * Segment_Vector.Z
        
        local T_Factor = 0
        if Segment_Length_Squared > 0 then
            T_Factor = Fast_Clamp(Player_To_Proj_Vector:Dot(Segment_Vector) / Segment_Length_Squared, 0, 1)
        end
        
        local Closest_Point_On_Line = Projected_Ball_Position + (Segment_Vector * T_Factor)
        local Distance_To_Line_Sq = Get_Distance_Squared(Root_Position, Closest_Point_On_Line)

        local Speed = Current_Speed
        local Distance = Projected_Distance
        local Velocity = Ball_Velocity
        local Ball_Direction = Velocity.Magnitude > 0.01 and Velocity.Unit or V3_Zero
        local Dot = Projected_Direction:Dot(Ball_Direction)
        local Speed_Threshold = Fast_Min(Speed / 100, 40)
        local Angle_Threshold = 40 * Fast_Max(Dot, 0)
        local Ball_Distance_Threshold = 15 - Fast_Min(Distance / 1000, 15) - Angle_Threshold + Speed_Threshold

        local Is_Curved = false
        local Close_Range_Threshold = Fast_Max(20, Final_Threshold * 0.5)

        if Speed > 10 and Distance > Close_Range_Threshold then
            local Distance_Factor_Curved = math.pow(Fast_Clamp((Distance - Close_Range_Threshold) / 25, 0, 1), 1.5)
            local Base_Dot_Threshold = 0.82 * Distance_Factor_Curved
            
            if Dot < Base_Dot_Threshold then
                Is_Curved = true
            end
            
            if Distance > Ball_Distance_Threshold and Dot < 0.65 then
                Is_Curved = true
            end
        end

        local Is_Moving_Away = Projected_Distance > Last_Distance + Projection_Magnitude + 0.15

        if Distance_To_Line_Sq <= Final_Threshold_Sq and not Is_Curved and not Is_Moving_Away then
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
