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

local Mouse1Click = mouse1click
local KeyPress = keypress
local KeyRelease = keyrelease

local Fast_Max = math.max
local Fast_Min = math.min
local Fast_Floor = math.floor
local Fast_Clamp = math.clamp
local Fast_Sqrt = math.sqrt
local Fast_Clock = os.clock
local V3_Zero = Vector3.zero
local Pi_2 = math.pi * 2

local function LerpVector2(A, B, T)
    return Vector2.new(
        A.X + (B.X - A.X) * T,
        A.Y + (B.Y - A.Y) * T
    )
end

local Lib_Instance
local Loader_Url = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.lua"
for I_Idx = 1, 10 do
    local Cache_Buster = ""
    pcall(function() Cache_Buster = "?cb=" .. tostring((math.floor((Fast_Clock() or 1) * 1000) + I_Idx * 7919) % 2000000000) end)
    local Ok_Status, Res_Data = pcall(function() return game:HttpGet(Loader_Url .. Cache_Buster) end)
    if Ok_Status and type(Res_Data) == "string" and #Res_Data > 1000 and Res_Data:find("INSUI_FILE_END", 1, true) then
        local Loaded_Func = loadstring(Res_Data)
        if Loaded_Func then
            local Ok_Eval, Eval_Res = pcall(Loaded_Func)
            if Ok_Eval and type(Eval_Res) == "table" and type(Eval_Res.CreateWindow) == "function" then Lib_Instance = Eval_Res; break end
            
            local Public_Inst
            pcall(function() Public_Inst = getgenv().INSui end);      if type(Public_Inst) == "table" and type(Public_Inst.CreateWindow) == "function" then Lib_Instance = Public_Inst; break end
            pcall(function() Public_Inst = _G.INSui end);             if type(Public_Inst) == "table" and type(Public_Inst.CreateWindow) == "function" then Lib_Instance = Public_Inst; break end
            pcall(function() Public_Inst = (shared or {}).INSui end); if type(Public_Inst) == "table" and type(Public_Inst.CreateWindow) == "function" then Lib_Instance = Public_Inst; break end
        end
    end
    task.wait(0.4)
end
if type(Lib_Instance) ~= "table" then return end

Lib_Instance:SetTheme("Indigo")

local Win_App = Lib_Instance:CreateWindow({
    title = "Nightfall | Recode",
    subtitle = "credits to inspecttor for ui",
    size = Vector2.new(700, 552),
    configName = "Nightfall",
    configFolder = "NigthfallConfigs",
    menuKey = "RightShift",
    badge = "v2"
})

local Config_State = {
    Auto_Parry = false,
    Accuracy = 100,
    Random_Accuracy = false,
    Random_Accuracy_Min = 80,
    Random_Accuracy_Max = 100,
    Panic_Spam = false,
    Training_Balls_Support = false,
    Auto_Spam = false,
    Manual_Spam = false,
    Spam_Rate = 200,
    Spam_Sensitivity = 3,
    Trigger_Bot = false,
    Trigger_Delay = 0,
    Trigger_Ignore_Spawn = false,
    Parry_Visualizer = false,
    Visualizer_Color = Color3.fromRGB(220, 30, 30),
    Vis_Thickness = 2.0,
    Vis_Transparency = 1.0,
    Vis_Segments = 40,
    Ability_Esp = false,
    Esp_Color = Color3.fromRGB(220, 30, 30),
    Esp_Text_Size = 18,
    Esp_Offset_Y = 2.0,
    Ball_Trail = false,
    Trail_Color = Color3.fromRGB(220, 30, 30),
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
    Parry_Range = 15,
    Generated_Accuracy = 100
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

local function Generate_Random_Accuracy()
    local Min_Acc = Fast_Min(Config_State.Random_Accuracy_Min, Config_State.Random_Accuracy_Max)
    local Max_Acc = Fast_Max(Config_State.Random_Accuracy_Min, Config_State.Random_Accuracy_Max)
    
    local U1 = Fast_Max(math.random(), 0.000001)
    local U2 = math.random()
    local Z0 = Fast_Sqrt(-2.0 * math.log(U1)) * math.cos(Pi_2 * U2)
    
    local Mean = (Min_Acc + Max_Acc) / 2
    local Std_Dev = Fast_Max((Max_Acc - Min_Acc) / 4, 1)
    
    Runtime_State.Generated_Accuracy = Fast_Clamp(Mean + (Z0 * Std_Dev), Min_Acc, Max_Acc)
end

local Combat_Tab = Win_App:Tab("Combat", "swords")

local Parry_Section = Combat_Tab:Section("Auto Parry", "Left", "")
Parry_Section:Toggle("Auto Parry", false, function(Value_In) Config_State.Auto_Parry = Value_In end):AddKeybind("None", "Toggle")
Parry_Section:Slider("Accuracy", 100, 1, 1, 100, "%", function(Value_In) Config_State.Accuracy = Value_In end)

local Random_Acc_Toggle = Parry_Section:Toggle("Random Accuracy", false, function(Value_In) Config_State.Random_Accuracy = Value_In end)
Parry_Section:RangeSlider("Random Parry Accuracy", 80, 100, 1, 1, 100, "%", function(Min_Val, Max_Val)
    Config_State.Random_Accuracy_Min = Min_Val
    Config_State.Random_Accuracy_Max = Max_Val
end):DependsOn(Random_Acc_Toggle)

Parry_Section:Toggle("Panic Spam", false, function(Value_In) Config_State.Panic_Spam = Value_In end)
Parry_Section:Dropdown("Parry Method", {"Click"}, {"Click", "Key"}, false, function(Value_In) Config_State.Parry_Method = type(Value_In) == "table" and Value_In[1] or Value_In end)
Parry_Section:Toggle("Training Balls", false, function(Value_In) Config_State.Training_Balls_Support = Value_In end)

local Spam_Section = Combat_Tab:Section("Auto Spam", "Right", "")
Spam_Section:Toggle("Auto Spam", false, function(Value_In) Config_State.Auto_Spam = Value_In end):AddKeybind("None", "Toggle")
Spam_Section:Toggle("Manual Spam", false, function(Value_In) Config_State.Manual_Spam = Value_In end):AddKeybind("None", "Toggle")
Spam_Section:Slider("Spam Rate", 200, 100, 200, 5000, "cps", function(Value_In) Config_State.Spam_Rate = Value_In end)
Spam_Section:Slider("Spam Sensitivity", 3, 1, 1, 5, "", function(Value_In) Config_State.Spam_Sensitivity = Value_In end)

local Trigger_Section = Combat_Tab:Section("Trigger Bot", "Right", "")
Trigger_Section:Toggle("Trigger Bot", false, function(Value_In) Config_State.Trigger_Bot = Value_In end):AddKeybind("None", "Toggle")
Trigger_Section:Slider("Delay", 0, 1, 0, 100, "ms", function(Value_In) Config_State.Trigger_Delay = Value_In end)
Trigger_Section:Toggle("Ignore Ball Spawn", false, function(Value_In) Config_State.Trigger_Ignore_Spawn = Value_In end)

local Visuals_Tab = Win_App:Tab("Visuals", "eye")

local Vis_Main_Section = Visuals_Tab:Section("Visuals", "Left", "")
Vis_Main_Section:Toggle("Range Visualiser", false, function(Value_In) Config_State.Parry_Visualizer = Value_In end):AddColorpicker("Vis Color", Color3.fromRGB(220, 30, 30), function(Color_Val) Config_State.Visualizer_Color = Color_Val end)
Vis_Main_Section:Slider("Vis Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value_In) Config_State.Vis_Thickness = Value_In end)
Vis_Main_Section:Slider("Vis Transparency", 1.0, 0.1, 0.1, 1.0, "", function(Value_In) Config_State.Vis_Transparency = Value_In end)
Vis_Main_Section:Slider("Vis Segments", 40, 1, 10, 100, "", function(Value_In) Config_State.Vis_Segments = Value_In end)

Vis_Main_Section:Toggle("Ability ESP", false, function(Value_In) Config_State.Ability_Esp = Value_In end):AddColorpicker("ESP Color", Color3.fromRGB(220, 30, 30), function(Color_Val) Config_State.Esp_Color = Color_Val end)
Vis_Main_Section:Slider("ESP Text Size", 18, 1, 10, 40, "", function(Value_In) Config_State.Esp_Text_Size = Value_In end)
Vis_Main_Section:Slider("ESP Offset Y", 2.0, 0.5, 0.0, 10.0, "", function(Value_In) Config_State.Esp_Offset_Y = Value_In end)

Vis_Main_Section:Toggle("Rainbow Mode", false, function(Value_In) Config_State.Rainbow_Mode = Value_In end)

local Vis_Trail_Section = Visuals_Tab:Section("Ball Trail", "Right", "")
Vis_Trail_Section:Toggle("Enable Trail", false, function(Value_In) Config_State.Ball_Trail = Value_In end):AddColorpicker("Trail Color", Color3.fromRGB(220, 30, 30), function(Color_Val) Config_State.Trail_Color = Color_Val end)
Vis_Trail_Section:Slider("Trail Length", 60, 1, 10, 100, "", function(Value_In) Config_State.Trail_Length = Value_In end)
Vis_Trail_Section:Slider("Trail Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value_In) Config_State.Trail_Thickness = Value_In end)

local Vis_Avatar_Section = Visuals_Tab:Section("Avatar", "Right", "")

local function Apply_Headless(State_Val)
    local Char_Obj = Local_Player.Character
    if not Char_Obj or typeof(Char_Obj) ~= "Instance" then return end
    local Head_Obj = Char_Obj:FindFirstChild("Head")
    if Head_Obj and typeof(Head_Obj) == "Instance" and Head_Obj:IsA("BasePart") then
        if State_Val then
            pcall(function() Head_Obj.Size = Vector3.new(0.01, 0.01, 0.01) end)
            if Head_Obj.Address and Head_Obj.Address ~= 0 then
                Write_Float(Head_Obj.Address + Offsets_Data.Transparency, 1.0)
            end
            for _, Child_Obj in ipairs(Head_Obj:GetChildren()) do
                if typeof(Child_Obj) == "Instance" and (Child_Obj.ClassName == "Decal" or Child_Obj.Name == "face" or Child_Obj.Name == "Face" or Child_Obj.ClassName:match("Mesh")) then
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
    if not Char_Obj or typeof(Char_Obj) ~= "Instance" then return end
    local Right_Leg_Names = {
        RightUpperLeg = true,
        RightLowerLeg = true,
        RightFoot = true,
        ["Right Leg"] = true
    }
    if State_Val then
        for _, Part_Obj in ipairs(Char_Obj:GetChildren()) do
            if typeof(Part_Obj) == "Instance" and Right_Leg_Names[Part_Obj.Name] and Part_Obj:IsA("BasePart") then
                pcall(function() Part_Obj.Size = Vector3.new(0.01, 0.01, 0.01) end)
                if Part_Obj.Address and Part_Obj.Address ~= 0 then
                    Write_Float(Part_Obj.Address + Offsets_Data.Transparency, 1.0)
                end
                for _, Child_Obj in ipairs(Part_Obj:GetChildren()) do
                    if typeof(Child_Obj) == "Instance" and (Child_Obj.ClassName:match("Mesh") or Child_Obj.ClassName == "Decal" or Child_Obj.ClassName == "Texture") then
                        pcall(function() Child_Obj.Texture = "" end)
                        pcall(function() Child_Obj.Transparency = 1 end)
                        pcall(function() Child_Obj.Parent = nil end)
                        pcall(function() game:GetService("Debris"):AddItem(Child_Obj, 0) end)
                        if Child_Obj.Address and Child_Obj.Address ~= 0 then
                            Write_Pointer(Child_Obj.Address + Offsets_Data.Parent, 0)
                        end
                    end
                end
            elseif typeof(Part_Obj) == "Instance" and Part_Obj.ClassName == "CharacterMesh" then
                pcall(function()
                    if tostring(Part_Obj.BodyPart):match("RightLeg") then
                        if Part_Obj.Address and Part_Obj.Address ~= 0 then
                            Write_Pointer(Part_Obj.Address + Offsets_Data.Parent, 0)
                        end
                    end
                end)
            elseif typeof(Part_Obj) == "Instance" and Part_Obj.ClassName == "Accessory" then
                pcall(function()
                    local Handle_Obj = Part_Obj:FindFirstChild("Handle")
                    if Handle_Obj and typeof(Handle_Obj) == "Instance" then
                        local Weld_Obj = Handle_Obj:FindFirstChildOfClass("Weld") or Handle_Obj:FindFirstChildOfClass("Motor6D")
                        if Weld_Obj and typeof(Weld_Obj) == "Instance" and Weld_Obj.Part1 and Right_Leg_Names[Weld_Obj.Part1.Name] then
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
            if typeof(Part_Obj) == "Instance" and Right_Leg_Names[Part_Obj.Name] and Part_Obj:IsA("BasePart") then
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
local Det_Main_Section = Detections_Tab:Section("Detections", "Left", "")
Det_Main_Section:Toggle("Infinity Detection", false, function(Value_In) Config_State.Infinity_Detection = Value_In end)
Det_Main_Section:Toggle("Slashes of Fury Detection", false, function(Value_In) Config_State.Slashes_Of_Fury_Detection = Value_In end)

Win_App:AddSettingsTab("cog")

local Visuals_Data = {
    Sphere_Lines = {},
    Ball_Trail_Pos = {},
    Ball_Lines = {},
    Esp_Texts = {}
}

local Max_Trail_Lines = 100

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

local Smooth_Parry_Radius = 15

local function Get_Real_Ball()
    local Alive_Folder = Workspace_Service:FindFirstChild("Alive")
    local Dead_Folder = Workspace_Service:FindFirstChild("Dead")
    local Target_Folder = nil

    if Alive_Folder and typeof(Alive_Folder) == "Instance" and Alive_Folder:FindFirstChild(Local_Player.Name) then
        Target_Folder = Workspace_Service:FindFirstChild("Balls")
    elseif Dead_Folder and typeof(Dead_Folder) == "Instance" and Dead_Folder:FindFirstChild(Local_Player.Name) then
        if Config_State.Training_Balls_Support then
            Target_Folder = Workspace_Service:FindFirstChild("TrainingBalls")
        else
            Target_Folder = Workspace_Service:FindFirstChild("Balls")
        end
    else
        Target_Folder = Workspace_Service:FindFirstChild("Balls")
    end

    if Target_Folder and typeof(Target_Folder) == "Instance" then
        for _, Ball in ipairs(Target_Folder:GetChildren()) do
            if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:GetAttribute("realBall") == true then return Ball end
        end
        for _, Ball in ipairs(Target_Folder:GetChildren()) do
            if typeof(Ball) == "Instance" and Ball:IsA("BasePart") then return Ball end
        end
    end
    return nil
end

local function Get_Memory_Ping()
    local Success_State, Ping_Result = pcall(function()
        return memory_read("double", Stats_Service.Network.ServerStatsItem["Data Ping"].Address + 0xC8)
    end)
    return (Success_State and type(Ping_Result) == "number") and Ping_Result or 50
end

local function Check_Is_Target(Target_Name)
    local Character_Instance = Local_Player.Character
    if Character_Instance and typeof(Character_Instance) == "Instance" and Character_Instance:FindFirstChild('Highlight') then return true end
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
    if not Player_Position or typeof(Player_Position) ~= "Vector3" then return nil, math.huge end
    local Nearest_Entity = nil
    local Minimum_Distance_Sq = math.huge
    for _, Target_Player in ipairs(Players_Service:GetPlayers()) do
        if Target_Player ~= Local_Player and Target_Player.Character and typeof(Target_Player.Character) == "Instance" then
            local Root_Part = Target_Player.Character:FindFirstChild("HumanoidRootPart") or Target_Player.Character.PrimaryPart
            if Root_Part and typeof(Root_Part) == "Instance" and Root_Part:IsA("BasePart") then
                local Humanoid_Part = Target_Player.Character:FindFirstChild("Humanoid")
                if Humanoid_Part and typeof(Humanoid_Part) == "Instance" and Humanoid_Part.Health > 0 then
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
            if typeof(Mouse1Click) == "function" then
                Mouse1Click()
            end
        elseif Config_State.Parry_Method == "Key" then
            if typeof(KeyPress) == "function" and typeof(KeyRelease) == "function" then
                KeyPress(0x46)
                KeyRelease(0x46)
            end
        end
    end)
end

local function Execute_Parry_Direct()
    if Config_State.Parry_Method == "Click" then
        if typeof(Mouse1Click) == "function" then
            Mouse1Click()
        end
    elseif Config_State.Parry_Method == "Key" then
        if typeof(KeyPress) == "function" and typeof(KeyRelease) == "function" then
            KeyPress(0x46)
            KeyRelease(0x46)
        end
    end
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

local function Update_And_Render_Trail(Current_Ball_Pos)
    if not Config_State.Ball_Trail then
        for _, Line_Obj in ipairs(Visuals_Data.Ball_Lines) do
            if Line_Obj then Line_Obj.Visible = false end
        end
        return
    end
    if not Current_Ball_Pos or typeof(Current_Ball_Pos) ~= "Vector3" then
        for _, Line_Obj in ipairs(Visuals_Data.Ball_Lines) do
            if Line_Obj then Line_Obj.Visible = false end
        end
        table.clear(Visuals_Data.Ball_Trail_Pos)
        return
    end
    
    local Last_Tracked_Pos = Visuals_Data.Ball_Trail_Pos[1]
    if not Last_Tracked_Pos or (Last_Tracked_Pos - Current_Ball_Pos).Magnitude > 0.05 then
        table.insert(Visuals_Data.Ball_Trail_Pos, 1, Current_Ball_Pos)
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
        
        if Pos_1 and Pos_2 and typeof(Pos_1) == "Vector3" and typeof(Pos_2) == "Vector3" then
            local P1_2D, Vis_1 = WorldToScreen(Pos_1)
            local P2_2D, Vis_2 = WorldToScreen(Pos_2)
            
            if Vis_1 and Vis_2 then
                local Color_Val, Opacity_Val = Get_Trail_Color_And_Opacity(Base_Offset, I_Idx, Total_Pos)
                Line_Obj.From = P1_2D
                Line_Obj.To = P2_2D
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

local Pull_Time = 0

local Is_Parried = false
local Parry_Range_Threshold = 0
local Aero_Active = false
local Aero_Start_Time = 0
local Last_Speed = 0
local Last_Ball_Instance = nil
local Last_Distance = 9999
local Scheduled_Trigger_Time = 0
local Accumulated_Spam_Time = 0
local Panic_Accumulated_Time = 0
local Manual_Accumulated_Time = 0
local Ball_Parries = 0
local Last_From_Change = 0
local Cached_From = nil

local Current_Kps = 0
local Smoothed_Kps = 0

local Smoothed_Server_Fps = 60
local Last_Game_Time = Workspace_Service.DistributedGameTime
local Cached_Alive_Folder = nil

local Smooth_Visual_Root_Pos = nil
local Esp_Smoothed_Positions = {}
local Cached_Character = nil
local Character_Fully_Loaded = false

Run_Service.RenderStepped:Connect(function(Delta_Time)
    if type(Delta_Time) ~= "number" then Delta_Time = 0.016 end
    local Current_Render_Time = Fast_Clock()

    local Real_Ball_Visuals = Get_Real_Ball()
    local Current_Ball_Pos = nil
    
    if Real_Ball_Visuals and typeof(Real_Ball_Visuals) == "Instance" and Real_Ball_Visuals:IsA("BasePart") then
        Current_Ball_Pos = Real_Ball_Visuals.Position
    end
    
    Update_And_Render_Trail(Current_Ball_Pos)

    if Config_State.Ability_Esp then
        local Current_Players_List = Players_Service:GetPlayers()
        for I_Idx = 1, #Current_Players_List do
            local Target_Player = Current_Players_List[I_Idx]
            if Target_Player == Local_Player then continue end
            
            local Player_Name_Str = Target_Player.Name
            local Target_Character = Target_Player.Character
            local Target_Humanoid = Target_Character and typeof(Target_Character) == "Instance" and Target_Character:FindFirstChild("Humanoid")
            local Is_Entity_Alive = Target_Humanoid and typeof(Target_Humanoid) == "Instance" and Target_Humanoid.Health > 0
            local Target_Head = Target_Character and typeof(Target_Character) == "Instance" and Target_Character:FindFirstChild("Head")
            local Target_Ability = Target_Player:GetAttribute("CurrentlyEquippedAbility")
            
            if Is_Entity_Alive and Target_Head and typeof(Target_Head) == "Instance" and Target_Head:IsA("BasePart") and Target_Ability then
                local Head_Pos = Target_Head.Position
                local Current_Offset_Vector = Vector3.new(0, Config_State.Esp_Offset_Y, 0)
                local Target_3D = Head_Pos + Current_Offset_Vector
                
                local Screen_Coords, Is_On_Screen = WorldToScreen(Target_3D)
                if Is_On_Screen and Screen_Coords.X > 0 and Screen_Coords.Y > 0 then
                    local Text_Drawing = Visuals_Data.Esp_Texts[Player_Name_Str]
                    if not Text_Drawing then
                        Text_Drawing = Create_Esp_Text()
                        Visuals_Data.Esp_Texts[Player_Name_Str] = Text_Drawing
                    end
                        if Text_Drawing then
                            Text_Drawing.Size = Config_State.Esp_Text_Size
                            local Smoothed_Pos = Screen_Coords
                            if Esp_Smoothed_Positions[Player_Name_Str] then
                                local Lerp_Alpha = Fast_Clamp(Delta_Time * 32, 0, 1)
                                Smoothed_Pos = LerpVector2(Esp_Smoothed_Positions[Player_Name_Str], Screen_Coords, Lerp_Alpha)
                            end
                            Esp_Smoothed_Positions[Player_Name_Str] = Smoothed_Pos
                            Text_Drawing.Position = Smoothed_Pos
                            Text_Drawing.Text = tostring(Target_Ability)
                            if Config_State.Rainbow_Mode then
                                local Color_R = (math.sin(Current_Render_Time * 2.5) * 0.5 + 0.5) * 0.95 + 0.05
                                local Color_G = (math.sin(Current_Render_Time * 2.5 + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                                local Color_B = (math.sin(Current_Render_Time * 2.5 + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                                Text_Drawing.Color = Color3.new(Color_R, Color_G, Color_B)
                            else
                                Text_Drawing.Color = Config_State.Esp_Color
                            end
                            Text_Drawing.Visible = true
                        end
                else
                    local Text_Drawing = Visuals_Data.Esp_Texts[Player_Name_Str]
                    if Text_Drawing then Text_Drawing.Visible = false end
                end
            else
                local Text_Drawing = Visuals_Data.Esp_Texts[Player_Name_Str]
                if Text_Drawing then
                    Text_Drawing.Visible = false
                end
            end
        end

        for Key_Name, Text_Drawing in pairs(Visuals_Data.Esp_Texts) do
            if not Players_Service:FindFirstChild(Key_Name) then
                if Text_Drawing then Text_Drawing:Remove() end
                Visuals_Data.Esp_Texts[Key_Name] = nil
                       Esp_Smoothed_Positions[Key_Name] = nil
            end
        end
    else
        for Key_Name, Text_Drawing in pairs(Visuals_Data.Esp_Texts) do
            if Text_Drawing then
                Text_Drawing.Visible = false
            end
        end
    end

    local Local_Char = Local_Player.Character
    local Root_Part_Vis = Local_Char and typeof(Local_Char) == "Instance" and Local_Char:FindFirstChild("HumanoidRootPart")
    if Config_State.Parry_Visualizer and Root_Part_Vis and typeof(Root_Part_Vis) == "Instance" and Root_Part_Vis:IsA("BasePart") then
       local Root_Pos_Raw = Root_Part_Vis.Position - Vector3.new(0, 3, 0)
       if Smooth_Visual_Root_Pos == nil then
           Smooth_Visual_Root_Pos = Root_Pos_Raw
       else
           local Lerp_Alpha = Fast_Clamp(Delta_Time * 18, 0, 1)
           Smooth_Visual_Root_Pos = Smooth_Visual_Root_Pos:Lerp(Root_Pos_Raw, Lerp_Alpha)
       end
       local Root_Pos = Smooth_Visual_Root_Pos
       local Target_Radius = Runtime_State.Parry_Range or 15
       Smooth_Parry_Radius = Smooth_Parry_Radius + (Target_Radius - Smooth_Parry_Radius) * Fast_Clamp(Delta_Time * 20, 0, 1)
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
                    
                    local P1_Pos, On_Screen_1 = WorldToScreen(P1_3d)
                    local P2_Pos, On_Screen_2 = WorldToScreen(P2_3d)
                    
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
    if type(Delta_Time) ~= "number" then Delta_Time = 0.016 end
    local Current_Delta_Time = Delta_Time

    local Runtime_Folder = Workspace_Service:FindFirstChild("Runtime")
    local Children_List = Runtime_Folder and typeof(Runtime_Folder) == "Instance" and Runtime_Folder:GetChildren() or Workspace_Service:GetChildren()
    for _, Child_Obj in ipairs(Children_List) do
        if typeof(Child_Obj) == "Instance" and (Child_Obj.Name == "Pull" or Child_Obj.Name == "MaxPull") then
            Pull_Time = Current_Time
            break
        end
    end

    local Player_Character_Obj = Local_Player.Character

    if Player_Character_Obj ~= Cached_Character then
        Cached_Character = Player_Character_Obj
        Character_Fully_Loaded = false
    end

    if Player_Character_Obj and typeof(Player_Character_Obj) == "Instance" and not Character_Fully_Loaded then
        local HRP = Player_Character_Obj:FindFirstChild("HumanoidRootPart")
        if HRP and typeof(HRP) == "Instance" then
            Character_Fully_Loaded = true
            task.spawn(function()
                task.wait(0.5)
                if Config_State.Headless then
                    pcall(function() Apply_Headless(true) end)
                end
                if Config_State.Korblox then
                    pcall(function() Apply_Korblox(true) end)
                end
            end)
        end
    end

    if Player_Character_Obj and typeof(Player_Character_Obj) == "Instance" and Character_Fully_Loaded then
        if Config_State.Headless then
            local Target_Head = Player_Character_Obj:FindFirstChild("Head")
            if Target_Head and typeof(Target_Head) == "Instance" and Target_Head:IsA("BasePart") and Target_Head.Size.X > 0.1 then
                pcall(function() Apply_Headless(true) end)
            end
        end
        if Config_State.Korblox then
            local Target_Right_Leg = Player_Character_Obj:FindFirstChild("RightUpperLeg") or Player_Character_Obj:FindFirstChild("Right Leg")
            if Target_Right_Leg and typeof(Target_Right_Leg) == "Instance" and Target_Right_Leg:IsA("BasePart") and Target_Right_Leg.Size.X > 0.1 then
                pcall(function() Apply_Korblox(true) end)
            end
        end
    end

    local Current_Game_Time = Workspace_Service.DistributedGameTime
    if Current_Game_Time ~= Last_Game_Time then
        local Server_Tick_Delta = Current_Game_Time - Last_Game_Time
        Last_Game_Time = Current_Game_Time
        if Server_Tick_Delta > 0 then
            local Current_Server_Fps = 1 / Server_Tick_Delta
            Smoothed_Server_Fps = Smoothed_Server_Fps + (Current_Server_Fps - Smoothed_Server_Fps) * 0.1
        end
    end

    if Config_State.Manual_Spam then
        local Target_Spam_Rate = Fast_Clamp(Config_State.Spam_Rate, 200, 500)
        local Spam_Interval = 1 / Target_Spam_Rate
        Manual_Accumulated_Time = Manual_Accumulated_Time + Current_Delta_Time
        
        if Manual_Accumulated_Time >= Spam_Interval then
            local Click_Count = Fast_Floor(Manual_Accumulated_Time / Spam_Interval)
            Manual_Accumulated_Time = Manual_Accumulated_Time % Spam_Interval
            
            Click_Count = Fast_Min(Click_Count, 2)
            for I_Idx = 1, Click_Count do
                task.spawn(Execute_Parry_Direct)
            end
        end
    else
        Manual_Accumulated_Time = 0
    end

    if Config_State.Infinity_Detection then
        local Is_Detected = false
        local Infinity_Runtime_Folder = Workspace_Service:FindFirstChild("Runtime")
        if Infinity_Runtime_Folder and typeof(Infinity_Runtime_Folder) == "Instance" then
            if Infinity_Runtime_Folder:FindFirstChild("InfinityFX") or Infinity_Runtime_Folder:FindFirstChild("TrueInfinityFX") then
                Is_Detected = true
            end
        end
        local Current_Balls_Folder = Workspace_Service:FindFirstChild("Balls")
        if Current_Balls_Folder and typeof(Current_Balls_Folder) == "Instance" then
            for _, Current_Ball in ipairs(Current_Balls_Folder:GetChildren()) do
                if typeof(Current_Ball) == "Instance" and Current_Ball:IsA("BasePart") then
                    local Body_Part = Current_Ball:FindFirstChild("Body")
                    if Body_Part and typeof(Body_Part) == "Instance" and Body_Part:FindFirstChild("WEMAZOOKIEGO") then
                        Is_Detected = true
                        break
                    end
                end
            end
        end
        if Local_Player.Character and typeof(Local_Player.Character) == "Instance" then
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
        if Current_Balls_Folder and typeof(Current_Balls_Folder) == "Instance" then
            for _, Current_Ball in ipairs(Current_Balls_Folder:GetChildren()) do
                if typeof(Current_Ball) == "Instance" and Current_Ball:FindFirstChild("ComboCounter") then
                    local Target_Attr = Current_Ball:GetAttribute("target") or Current_Ball:GetAttribute("Target")
                    if Check_Is_Target(Target_Attr) then
                        Is_Fury = true
                    end
                    break
                end
            end
        end
        if not Is_Fury and Local_Player.Character and typeof(Local_Player.Character) == "Instance" then
            if Local_Player.Character:GetAttribute("FuryCatch") == true then
                Is_Fury = true
            end
        end
        if not Is_Fury then
            local Player_Gui = Local_Player:FindFirstChild("PlayerGui")
            if Player_Gui and typeof(Player_Gui) == "Instance" then
                local Fury_Timer = Player_Gui:FindFirstChild("FuryTimer")
                if Fury_Timer and typeof(Fury_Timer) == "Instance" and Fury_Timer.Enabled then
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
                    if Current_Balls and typeof(Current_Balls) == "Instance" then
                        for _, Current_Ball in ipairs(Current_Balls:GetChildren()) do
                            local Combo_Obj = typeof(Current_Ball) == "Instance" and Current_Ball:FindFirstChild("ComboCounter")
                            if Combo_Obj and typeof(Combo_Obj) == "Instance" then
                                local Target_Attr = Current_Ball:GetAttribute("target") or Current_Ball:GetAttribute("Target")
                                if Check_Is_Target(Target_Attr) then
                                    Still_Fury = true
                                end
                                local Text_Label = Combo_Obj:FindFirstChild("TextLabel")
                                if Text_Label and typeof(Text_Label) == "Instance" then
                                    Current_Combo = tonumber(Text_Label.Text) or 0
                                end
                                break
                            end
                        end
                    end
                    if not Still_Fury and Local_Player.Character and typeof(Local_Player.Character) == "Instance" then
                        if Local_Player.Character:GetAttribute("FuryCatch") == true then
                            Still_Fury = true
                        end
                    end
                    if not Still_Fury then
                        local Player_Gui = Local_Player:FindFirstChild("PlayerGui")
                        if Player_Gui and typeof(Player_Gui) == "Instance" then
                            local Fury_Timer = Player_Gui:FindFirstChild("FuryTimer")
                            if Fury_Timer and typeof(Fury_Timer) == "Instance" and Fury_Timer.Enabled then
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

    if not Real_Ball or typeof(Real_Ball) ~= "Instance" or not Real_Ball:IsA("BasePart") or not Real_Ball.Parent then
        if (Current_Time - Last_From_Change) > 0.5 then
            Cached_From = nil
            Ball_Parries = 0
            Current_Kps = 0
            Smoothed_Kps = 0
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
        Runtime_State.Parry_Range = 15
        return
    end

    if Real_Ball ~= Last_Ball_Instance then
        Last_Ball_Instance = Real_Ball
        Last_Distance = 9999
        Accumulated_Spam_Time = 0
        Panic_Accumulated_Time = 0
        if Config_State.Random_Accuracy then
            Generate_Random_Accuracy()
        end
    end

    local Player_Character = Local_Player.Character
    if not Player_Character or typeof(Player_Character) ~= "Instance" then return end

    local Root_Part = Player_Character.PrimaryPart
    if not Root_Part or typeof(Root_Part) ~= "Instance" or not Root_Part:IsA("BasePart") or not Root_Part.Parent then return end

    if Player_Character:FindFirstChild("SingularityCape") or Root_Part:FindFirstChild("SingularityCape") then
        Is_Parried = false
        Accumulated_Spam_Time = 0
        Panic_Accumulated_Time = 0
        return
    end

    local Is_TK_Active = false
    local Body_Part = Real_Ball:FindFirstChild("Body")
    if Body_Part and typeof(Body_Part) == "Instance" and Body_Part:FindFirstChild("At2") then
        Is_TK_Active = true
    end

    local Is_Pull_Active = (Current_Time - Pull_Time) <= 0.1

    if Is_Pull_Active or Is_TK_Active then
        Is_Parried = false
        local Temp_Velocity = Real_Ball.AssemblyLinearVelocity
        Last_Speed = typeof(Temp_Velocity) == "Vector3" and Temp_Velocity.Magnitude or 0
        Last_Distance = (Root_Part.Position - Real_Ball.Position).Magnitude
        Accumulated_Spam_Time = 0
        Panic_Accumulated_Time = 0
        Scheduled_Trigger_Time = 0
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

    local Approach_Speed = 0
    if Last_Distance ~= 9999 then
        Approach_Speed = Fast_Max((Last_Distance - Current_Distance) / Current_Delta_Time, 0)
    end
    local Effective_Speed = Fast_Max(Current_Speed, Approach_Speed)
    local Speed_Delta = Fast_Max(Effective_Speed - Last_Speed, 0)

    local Velocity_Dir = Ball_Velocity.Magnitude > 0.01 and Ball_Velocity.Unit or V3_Zero
    local Direction_To_Player_Stat = Delta_Vector.Unit
    local Dot_Product_Stat = Direction_To_Player_Stat:Dot(Velocity_Dir)

    Runtime_State.Target_Speed = Current_Speed
    Runtime_State.Target_Distance = Current_Distance
    Runtime_State.Target_Dot = Dot_Product_Stat

    if Effective_Speed < 15 then
        Last_Speed = Effective_Speed
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
        Last_Speed = Effective_Speed
        Accumulated_Spam_Time = 0
        return
    end

    local Current_From_Attr = Real_Ball:GetAttribute("from") or Real_Ball:GetAttribute("From")

    if Current_From_Attr ~= nil and Current_From_Attr ~= Cached_From then
        local Time_Since_Last = Current_Time - Last_From_Change
        if Time_Since_Last <= 0.35 then
            Ball_Parries = Ball_Parries + 1
        else
            Ball_Parries = 1
        end

        if Time_Since_Last > 0 then
            Current_Kps = 1 / Time_Since_Last
            Smoothed_Kps = Smoothed_Kps + (Current_Kps - Smoothed_Kps) * 0.25
        end

        Cached_From = Current_From_Attr
        Last_From_Change = Current_Time
        
        if Config_State.Random_Accuracy then
            local Jitter_Chance = math.random()
            if Jitter_Chance > 0.3 then
                Generate_Random_Accuracy()
            end
        end
    end

    local Current_Target_Attr = Real_Ball:GetAttribute("target") or Real_Ball:GetAttribute("Target")
    local Is_Target_Me = false
    if (Player_Character and Player_Character:FindFirstChild("Highlight")) or Check_Is_Target(Current_Target_Attr) then
        Is_Target_Me = true
    end

    local Network_Ping = Get_Memory_Ping()
    local Nearest_Player, Distance_To_Nearest_Player = Scan_For_Nearest_Entity(Root_Position)

    local Dead_Folder = Workspace_Service:FindFirstChild("Dead")
    local Is_Dead = Dead_Folder and typeof(Dead_Folder) == "Instance" and Dead_Folder:FindFirstChild(Local_Player.Name) ~= nil
    local Is_Training_Ball = Real_Ball.Parent and Real_Ball.Parent.Name == "TrainingBalls"
    local Can_Attack = (not Is_Dead) and (not Is_Training_Ball)

    local Spam_Params = {
        Speed = Effective_Speed,
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
        local Target_Spam_Rate = Fast_Clamp(Config_State.Spam_Rate, 200, 500)
        local Spam_Interval = 1 / Target_Spam_Rate
        Accumulated_Spam_Time = Accumulated_Spam_Time + Current_Delta_Time

        if Accumulated_Spam_Time >= Spam_Interval then
            local Click_Count = Fast_Floor(Accumulated_Spam_Time / Spam_Interval)
            Accumulated_Spam_Time = Accumulated_Spam_Time % Spam_Interval
            
            Click_Count = Fast_Min(Click_Count, 2)
            for I_Idx = 1, Click_Count do
                task.spawn(Execute_Parry_Direct)
            end
        end
        Is_Parried = true
        Last_Speed = Effective_Speed
        Last_Distance = Current_Distance
        return
    else
        Accumulated_Spam_Time = 0
    end

    if Config_State.Panic_Spam then
        local Target_Cps = 200
        local Panic_Interval = 1 / Target_Cps
        
        local Panic_Max_Distance = 25
        local Danger_Zone_Radius = 15
        local Closest_Enemy_Distance_Sq = math.huge
        local Enemy_Look_Dot = 0
        
        if not Cached_Alive_Folder then
            Cached_Alive_Folder = Workspace_Service:FindFirstChild("Alive")
        end
        
        if Cached_Alive_Folder and typeof(Cached_Alive_Folder) == "Instance" then
            for _, Obj_Val in ipairs(Cached_Alive_Folder:GetChildren()) do
                if typeof(Obj_Val) == "Instance" and Obj_Val ~= Player_Character and Obj_Val.Name ~= Local_Player.Name then
                    local Enemy_Humanoid = Obj_Val:FindFirstChildWhichIsA("Humanoid")
                    local Enemy_Root = Obj_Val:FindFirstChild("HumanoidRootPart") or Obj_Val.PrimaryPart
                    if Enemy_Humanoid and typeof(Enemy_Humanoid) == "Instance" and Enemy_Humanoid.Health > 0 and Enemy_Root and typeof(Enemy_Root) == "Instance" and Enemy_Root:IsA("BasePart") then
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
            Panic_Accumulated_Time = Panic_Accumulated_Time + Current_Delta_Time
            if Panic_Accumulated_Time >= Panic_Interval then
                local Click_Count = Fast_Floor(Panic_Accumulated_Time / Panic_Interval)
                Panic_Accumulated_Time = Panic_Accumulated_Time % Panic_Interval
                
                Click_Count = Fast_Min(Click_Count, 2)
                for I_Idx = 1, Click_Count do
                    task.spawn(Execute_Parry_Direct)
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

    local Server_Tick_Rate = 1 / Fast_Max(Smoothed_Server_Fps, 1)

    if Config_State.Trigger_Bot and Can_Attack then
        if Can_Trigger and not Is_Parried then
            local Application_Tick = Fast_Clock()
            if Scheduled_Trigger_Time == 0 then
                local Ping_Sec = (Network_Ping / 10) / 1000
                local Ball_Speed_Factor = Fast_Clamp(Effective_Speed / 80, 0.6, 1.35)
                local Compensation = Ping_Sec + Current_Delta_Time + Server_Tick_Rate
                local Base_Delay = Config_State.Trigger_Delay / 1000
                local Final_Delay = Fast_Max(0, (Base_Delay * Ball_Speed_Factor) - Compensation)
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
            Last_Speed = Effective_Speed
            Last_Distance = Current_Distance
            return
        end

        local Kps_Intensity = Fast_Clamp(Smoothed_Kps, 0, 20) / 20
        local Kps_Mitigation = 1 - (Kps_Intensity * 0.55)

        local Accuracy_Value = Config_State.Accuracy
        if Config_State.Random_Accuracy then
            local Time_Jitter = math.sin(Current_Time * 15) * 1.5
            Accuracy_Value = Runtime_State.Generated_Accuracy + Time_Jitter
        end
        Accuracy_Value = Fast_Clamp(Accuracy_Value, 1, 100)

        local Accuracy_Scale = (Accuracy_Value - 1) / 99
        local Accuracy_Multiplier = 0.7 + (Accuracy_Scale * 0.35)

        local Dynamic_Scaling = Fast_Max(Effective_Speed - 9.5, 0) * 0.002
        local Final_Speed_Divisor = (2.4 + Dynamic_Scaling) * Accuracy_Multiplier

        local Base_Extrapolation_Factor = 2.4 + Dynamic_Scaling
        local Final_Extrapolation_Factor = Base_Extrapolation_Factor * Accuracy_Multiplier
        
        local Extrapolation_Distance = Effective_Speed * Current_Delta_Time * Final_Extrapolation_Factor * Kps_Mitigation
        
        local Base_Distance = Fast_Max(Effective_Speed / Final_Speed_Divisor, 9.5)
        local Low_Accuracy_Delay = (1 - Accuracy_Scale) * 1.45
        
        local Unified_Threshold = Base_Distance + Extrapolation_Distance + (Kps_Intensity * 1.5) - Low_Accuracy_Delay
        Unified_Threshold = Fast_Max(Unified_Threshold, 9.5)
        
        Runtime_State.Parry_Range = Unified_Threshold

        local Velocity_Unit = Current_Speed > 0 and Velocity_Dir or V3_Zero
        local Direction_To_Player = Current_Distance > 0 and (Root_Position - Ball_Position).Unit or V3_Zero
        local Dot_Product_Parry = Velocity_Unit:Dot(Direction_To_Player)

        local Close_Range_Threshold = Fast_Max(20, Unified_Threshold * 0.6)

        local Is_Curved = false
        local Dot_Distance_Threshold = 35.0
        local Dot_Limit_Threshold = 55.0

        if Current_Speed > 15 then
            local Distance_Ratio = Fast_Clamp((Current_Distance - Dot_Distance_Threshold) / Dot_Limit_Threshold, 0, 1)
            
            local Max_Dot_Threshold = 0.85 - (0.1 * (1 - Accuracy_Scale))
            local Min_Dot_Threshold = 0.55 - (0.1 * (1 - Accuracy_Scale))
            
            local Dynamic_Dot = Min_Dot_Threshold + (Max_Dot_Threshold - Min_Dot_Threshold) * math.pow(Distance_Ratio, 1.5)
            
            local Curve_Compensation = Current_Delta_Time * Final_Extrapolation_Factor * Kps_Mitigation
            local Dot_Threshold = Dynamic_Dot - (Curve_Compensation * 0.15)
            
            local Curve_Tolerance = 0.9 - (0.45 * (1 - Accuracy_Scale))
            
            if Current_Distance > Close_Range_Threshold * Curve_Tolerance and Dot_Product_Parry < Dot_Threshold then
                Is_Curved = true
            end
        end

        local Is_Moving_Away = Current_Distance > Last_Distance + 0.15

        if Current_Distance <= Unified_Threshold and not Is_Moving_Away and not Is_Curved then
            if Config_State.Auto_Parry then
                Is_Parried = true
                Execute_Parry_Direct()
            end
        end
    else
        Is_Parried = false
    end

    Last_Speed = Effective_Speed
    Last_Distance = Current_Distance
end)
