local Workspace_Service = game:GetService("Workspace")
local Players_Service = game:GetService("Players")
local Stats_Service = game:GetService("Stats")
local Http_Service = game:GetService("HttpService")
local Local_Player = Players_Service.LocalPlayer
local Player_Mouse = Local_Player:GetMouse()

local _Cvm_Connection = {}
_Cvm_Connection.__index = _Cvm_Connection
function _Cvm_Connection.new(disconnectFn)
    return setmetatable({Connected = true, _disconnect = disconnectFn}, _Cvm_Connection)
end
function _Cvm_Connection:Disconnect()
    if not self.Connected then return end
    self.Connected = false
    if self._disconnect then self._disconnect() end
end

local _Cvm_Signal = {}
_Cvm_Signal.__index = _Cvm_Signal
function _Cvm_Signal.new()
    return setmetatable({_entries = {}}, _Cvm_Signal)
end
function _Cvm_Signal:Connect(callback)
    local entry = {callback = callback, connected = true}
    table.insert(self._entries, entry)
    return _Cvm_Connection.new(function() entry.connected = false end)
end
function _Cvm_Signal:Fire(...)
    local alive = {}
    for _, entry in ipairs(self._entries) do
        if entry.connected then
            table.insert(alive, entry)
            pcall(entry.callback, ...)
        end
    end
    self._entries = alive
end

local _ChildVm_Class = {}
_ChildVm_Class.__index = _ChildVm_Class
function _ChildVm_Class.new(config)
    config = config or {}
    local self = setmetatable({_watchers = {}, _running = false, _pollRate = config.PollRate or 0.05}, _ChildVm_Class)
    self:_startEngine()
    return self
end
function _ChildVm_Class:_startEngine()
    if self._running then return end
    self._running = true
    task.spawn(function()
        while self._running do
            local alive = {}
            for i = 1, #self._watchers do
                local w = self._watchers[i]
                if w.active then
                    table.insert(alive, w)
                    pcall(w.poll)
                end
            end
            self._watchers = alive
            task.wait(self._pollRate)
        end
    end)
end
local function _cvm_snapshotChildren(parent)
    local set = {}
    pcall(function()
        for _, child in ipairs(parent:GetChildren()) do
            local addr = child.Address
            if addr then set[addr] = child end
        end
    end)
    return set
end
function _ChildVm_Class:OnChildAdded(parent, callback)
    local current = _cvm_snapshotChildren(parent)
    local pending = {}
    local watcher = {active = true, poll = function()
        if not parent or not parent.Parent then return end
        local now = _cvm_snapshotChildren(parent)
        for addr, child in pairs(now) do
            if not current[addr] then
                if not pending[addr] then
                    pending[addr] = true
                    pcall(callback, child)
                end
            else
                pending[addr] = nil
            end
        end
        current = now
    end}
    table.insert(self._watchers, watcher)
    return _Cvm_Connection.new(function() watcher.active = false end)
end
function _ChildVm_Class:OnceChildAdded(parent, callback)
    local conn
    conn = self:OnChildAdded(parent, function(child) conn:Disconnect() callback(child) end)
    return conn
end
function _ChildVm_Class:OnChildRemoved(parent, callback)
    local current = _cvm_snapshotChildren(parent)
    local missingFor = {}
    local watcher = {active = true, poll = function()
        local now = _cvm_snapshotChildren(parent)
        for addr, child in pairs(current) do
            if not now[addr] then
                missingFor[addr] = (missingFor[addr] or 0) + 1
                if missingFor[addr] >= 2 then
                    missingFor[addr] = nil
                    current[addr] = nil
                    pcall(callback, child)
                end
            else
                missingFor[addr] = nil
            end
        end
        for addr, child in pairs(now) do
            if not current[addr] then current[addr] = child end
        end
    end}
    table.insert(self._watchers, watcher)
    return _Cvm_Connection.new(function() watcher.active = false end)
end
function _ChildVm_Class:OnceChildRemoved(parent, callback)
    local conn
    conn = self:OnChildRemoved(parent, function(child) conn:Disconnect() callback(child) end)
    return conn
end
function _ChildVm_Class:OnAttributeChanged(instance, attrName, callback)
    local currentValue = nil
    pcall(function() currentValue = instance:GetAttribute(attrName) end)
    local watcher = {active = true, poll = function()
        if not instance or not instance.Parent then return end
        local newValue = nil
        pcall(function() newValue = instance:GetAttribute(attrName) end)
        if newValue ~= currentValue then
            local old = currentValue
            currentValue = newValue
            pcall(callback, newValue, old)
        end
    end}
    table.insert(self._watchers, watcher)
    return _Cvm_Connection.new(function() watcher.active = false end)
end
function _ChildVm_Class:OnceAttributeChanged(instance, attrName, callback)
    local conn
    conn = self:OnAttributeChanged(instance, attrName, function(new, old) conn:Disconnect() callback(new, old) end)
    return conn
end
function _ChildVm_Class:Destroy()
    self._running = false
    for _, w in ipairs(self._watchers) do w.active = false end
    self._watchers = {}
end

local Cvm = _ChildVm_Class.new()

local Math_Min = math.min
local Math_Max = math.max
local Math_Clamp = math.clamp
local Math_Sqrt = math.sqrt
local Math_Acos = math.acos
local Math_Asin = math.asin
local Math_Deg = math.deg
local Math_Floor = math.floor
local Math_Random = math.random
local Math_Abs = math.abs
local V3_New = Vector3.new
local V3_Zero = Vector3.zero
local V2_New = Vector2.new
local V2_Zero = Vector2.zero
local C3_New = Color3.new
local C3_Hex = Color3.fromHex
local Task_Spawn = task.spawn
local Task_Wait = task.wait
local Safe_Call = pcall
local Time_Tick = tick
local Table_Insert = table.insert
local Table_Remove = table.remove
local String_Lower = string.lower
local String_Sub = string.sub
local String_Find = string.find
local String_Format = string.format
local String_Gsub = string.gsub

local Custom_Run_Service = {}
local Render_Step_Bindings = {}
local Is_Thread_Active = true
local Last_Tick_Timestamp = Time_Tick()
local Accumulated_Frame_Counter = 0
local Sorted_Binding_Registry = {}
local Validated_Bind_Count = 0

local function World_To_Screen(Pos_Vec)
    local Camera_Obj = Workspace_Service.CurrentCamera
    if not Camera_Obj then return V2_Zero, false end
    local Screen_Pos, Is_Visible = Camera_Obj:WorldToViewportPoint(Pos_Vec)
    return V2_New(Screen_Pos.X, Screen_Pos.Y), Is_Visible
end

local function Create_Signal()
    local Signal_Object = {Active_Connections = {}}

    function Signal_Object:Connect(Callback_Function)
        local Connection_Object = {Function_Cb = Callback_Function, Connected = true}
        Table_Insert(Signal_Object.Active_Connections, Connection_Object)
        return {
            Disconnect = function()
                Connection_Object.Connected = false
                Connection_Object.Function_Cb = nil
            end
        }
    end

    function Signal_Object:Fire(...)
        local Connection_Index = 1
        while Connection_Index <= #Signal_Object.Active_Connections do
            local Connection_Object = Signal_Object.Active_Connections[Connection_Index]
            if Connection_Object.Connected then
                Safe_Call(Connection_Object.Function_Cb, ...)
                Connection_Index = Connection_Index + 1
            else
                Table_Remove(Signal_Object.Active_Connections, Connection_Index)
            end
        end
    end

    function Signal_Object:Wait()
        local Current_Thread = coroutine.running()
        local Wait_Connection
        Wait_Connection = Signal_Object:Connect(function(...)
            if Wait_Connection then
                Wait_Connection:Disconnect()
            end
            Task_Spawn(Current_Thread, ...)
        end)
        return coroutine.yield()
    end

    return Signal_Object
end

Custom_Run_Service.Heartbeat = Create_Signal()
Custom_Run_Service.Render_Stepped = Create_Signal()
Custom_Run_Service.Stepped = Create_Signal()

function Custom_Run_Service:Bind_To_Render_Step(Bind_Name, Bind_Priority, Bind_Function)
    if type(Bind_Name) ~= "string" or type(Bind_Function) ~= "function" then return end
    Render_Step_Bindings[Bind_Name] = {Priority = Bind_Priority or 0, Function_Cb = Bind_Function}
end

function Custom_Run_Service:Unbind_From_Render_Step(Bind_Name)
    Render_Step_Bindings[Bind_Name] = nil
end

function Custom_Run_Service:Is_Running()
    return Is_Thread_Active
end

Task_Spawn(function()
    while Is_Thread_Active do
        Safe_Call(function()
            local Current_Frame_Timestamp = Time_Tick()
            local Delta_Frame_Interval = Math_Min(Current_Frame_Timestamp - Last_Tick_Timestamp, 1)
            Last_Tick_Timestamp = Current_Frame_Timestamp
            Accumulated_Frame_Counter = Accumulated_Frame_Counter + 1

            if Is_Thread_Active then
                Custom_Run_Service.Stepped:Fire(Current_Frame_Timestamp, Delta_Frame_Interval)
            end

            if Is_Thread_Active then
                local Active_Count_Snapshot = 0
                for _ in pairs(Render_Step_Bindings) do
                    Active_Count_Snapshot = Active_Count_Snapshot + 1
                end

                if Active_Count_Snapshot ~= Validated_Bind_Count then
                    Sorted_Binding_Registry = {}
                    for _, Bind_Data in pairs(Render_Step_Bindings) do
                        if Bind_Data and type(Bind_Data.Function_Cb) == "function" then
                            Table_Insert(Sorted_Binding_Registry, Bind_Data)
                        end
                    end
                    table.sort(Sorted_Binding_Registry, function(Bind_A, Bind_B)
                        return Bind_A.Priority < Bind_B.Priority
                    end)
                    Validated_Bind_Count = Active_Count_Snapshot
                end

                for Bind_Index = 1, #Sorted_Binding_Registry do
                    if not Is_Thread_Active then break end
                    local Current_Execution_Target = Sorted_Binding_Registry[Bind_Index]
                    if Current_Execution_Target and Current_Execution_Target.Function_Cb then
                        Safe_Call(Current_Execution_Target.Function_Cb, Delta_Frame_Interval)
                    end
                end
            end

            if Is_Thread_Active then
                Custom_Run_Service.Render_Stepped:Fire(Delta_Frame_Interval)
            end

            if Is_Thread_Active then
                Custom_Run_Service.Heartbeat:Fire(Delta_Frame_Interval)
            end
        end)

        if Is_Thread_Active then
            Task_Wait()
        end
    end
end)

Safe_Call(function()
    if _G.Nightfall_Drawings then
        for _, Drawing_Obj in pairs(_G.Nightfall_Drawings) do
            Safe_Call(function() Drawing_Obj:Remove() end)
        end
    end
    if _G.Nightfall_Active then
        _G.Nightfall_Active = false
        Task_Wait(0.1)
    end
    _G.Nightfall_Active = true
    _G.Nightfall_Drawings = {}
end)

local Configuration = {
    Auto_Parry = false,
    Auto_Spam = false,
    Lobby_Parry = false,
    Triggerbot_Enabled = false,
    Dot_Protect = true,
    Min_Threat_Speed = 5,
    Parry_Cooldown = 0,
    Min_Tb_Delay = 1,
    Max_Tb_Delay = 1,
    Parry_Accuracy_Multiplier = 1.100,
    Ping_Multiplier = 1.200,
    Speed_Divisor_Base = 2.200,
    Speed_Divisor_Multiplier = 0.0020,
    Capped_Speed = 9500.0,
    Curve_Min_Speed_Threshold = 40.0,
    Curve_Speed_Threshold_Divisor = 100.0,
    Curve_Ball_Distance_Threshold_Divisor = 1000.0,
    Curve_Dot_Threshold = 0.500,
    Curve_Warping_Duration_Divisor = 1000.0,
    Curve_Warning_Duration = 1.50,
    Curve_Curving_Duration_Divisor = 1000.0,
    Curve_Curving_Duration = 1.50,
    Ping_Sample_Count = 30,
    Capped_Ping = 650.0,
    Dot_Min_Speed = 100.0,
    Dot_Threshold = 0.820,
    Dot_Distance_Threshold = 30.0,
    Dot_Limit_Threshold = 50.0,
    Spam_Threshold = 5,
    Spam_Min_Distance_Speed_Divisor = 6.5,
    Spam_Max_Speed_Divisor = 5.0,
    Spam_Min_Distance = 95.0,
    Spam_Max_Distance = 30.0,
    Parry_Keybind = 0,
    Spam_Keybind = 0,
    Triggerbot_Keybind = 0,
    Auto_Curve_Keybind = 0,
    Hide_Keybind = 0x71,
    Parry_Method = 1,
    Render_Ball_Stats = false,
    Render_Keybinds = true,
    Manual_Spam_Ui = false,
    Manual_Spam_Keybind = 0,
    Auto_Curve = false,
    Auto_Curve_Mode = 1,
    Camera_Sens = 0.50,
    Theme_Preset = 1,
    Custom_Accent_Color = "#A75CFF",
    Warp_Detect_Threshold = 3.0,
    Warp_Boost_Duration = 0.55,
    Warp_Boost_Amount = 6.0,
    Predict_Extra = 0.08,
    Accel_Smooth_Alpha = 0.15,
    Curve_History_Window = 7,
    Curve_Angle_Min_Threshold = 1.0,
    Dot_Back_Distance_Gate = 14.0,
}

local Save_File_Name = "Nightfall_Config.json"

local function Save_Config()
    Safe_Call(function()
        Configuration.Custom_Accent_Color = String_Format("#%02X%02X%02X",
            Math_Floor(Interface_Manager.Palette.Accent_Color.R * 255),
            Math_Floor(Interface_Manager.Palette.Accent_Color.G * 255),
            Math_Floor(Interface_Manager.Palette.Accent_Color.B * 255))

        local Json_Data = Http_Service:JSONEncode(Configuration)
        if writefile then
            writefile(Save_File_Name, Json_Data)
        end
    end)
end

local function Load_Config()
    Safe_Call(function()
        if isfile and isfile(Save_File_Name) and readfile then
            local Json_Data = readfile(Save_File_Name)
            local Decoded_Data = Http_Service:JSONDecode(Json_Data)
            for Key_Name, Value_Data in pairs(Decoded_Data) do
                if Configuration[Key_Name] ~= nil then
                    Configuration[Key_Name] = Value_Data
                end
            end

            if Configuration.Theme_Preset then
                Apply_Theme(Configuration.Theme_Preset)
            end
            if Configuration.Custom_Accent_Color then
                Interface_Manager.Palette.Accent_Color = C3_Hex(Configuration.Custom_Accent_Color)
                Update_Colors()
            end
        end
    end)
end

local Player_State = {
    Entity = {
        Server_Position = V3_Zero,
        Velocity = V3_Zero,
        Speed = 0,
        Ping = 60,
        Smoothed_Ping = 60,
        Ping_History = {},
        Jitter = 0,
        Jitter_Smoothed = 0
    },
    Is_Alive = false,
    Is_Dead = false,
    Manual_Spam_Active = false,
    Aero_Effect_Active = false,
    Aero_Effect_Start_Time = 0,
    Tracked_Speed = 0,
    Tracked_Distance = 0,
    Tracked_Dot_Product = 0,
    Current_Parry_Threshold = 0,
    Scheduled_Trigger_Time = 0
}

local Parry_State = {
    Ball = {
        Position = V3_Zero,
        Last_Position = V3_Zero,
        Velocity = V3_Zero,
        Speed = 0,
        Last_Speed_Tick = 0,
        Maximum_Speed = 0,
        Last_Warping = Time_Tick(),
        Warp_Detected_Time = -999,
        Last_Target_Change = Time_Tick(),
        Last_Targeted_Me = 0,
        Last_Hit = 0,
        Aero_Effect_Active = false,
        Smoothed_Accel = 0,
        Dot = 0,
        Smoothed_Dot = 1,
        Dot_Velocity = 0,
        Distance = 0,
        Parries = 0,
        Auto_Spam = false,
        Cooldown = false,
        Cached_Target = nil
    },
    Target = {
        Current = nil,
        Current_Name = nil
    },
    Trajectory_Cache = {}
}

local Watcher_State = {
    Ball_Conn = nil,
    Current_Ball = nil,
}

local function Interpolate_Value(Start_Value, End_Value, Alpha_Val)
    return Start_Value + (End_Value - Start_Value) * Alpha_Val
end

local function Interpolate_Color(Color_Start, Color_End, Alpha_Val)
    return C3_New(
        Interpolate_Value(Color_Start.R, Color_End.R, Alpha_Val),
        Interpolate_Value(Color_Start.G, Color_End.G, Alpha_Val),
        Interpolate_Value(Color_Start.B, Color_End.B, Alpha_Val)
    )
end

local function Convert_Hsv_To_Rgb(Hue_Val, Sat_Val, Val_Val)
    local R_Col, G_Col, B_Col
    local Index_Val = Math_Floor(Hue_Val * 6)
    local Fract_Val = Hue_Val * 6 - Index_Val
    local P_Val = Val_Val * (1 - Sat_Val)
    local Q_Val = Val_Val * (1 - Fract_Val * Sat_Val)
    local T_Val = Val_Val * (1 - (1 - Fract_Val) * Sat_Val)
    Index_Val = Index_Val % 6
    if Index_Val == 0 then R_Col, G_Col, B_Col = Val_Val, T_Val, P_Val
    elseif Index_Val == 1 then R_Col, G_Col, B_Col = Q_Val, Val_Val, P_Val
    elseif Index_Val == 2 then R_Col, G_Col, B_Col = P_Val, Val_Val, T_Val
    elseif Index_Val == 3 then R_Col, G_Col, B_Col = P_Val, Q_Val, Val_Val
    elseif Index_Val == 4 then R_Col, G_Col, B_Col = T_Val, P_Val, Val_Val
    elseif Index_Val == 5 then R_Col, G_Col, B_Col = Val_Val, P_Val, Q_Val
    end
    return C3_New(R_Col, G_Col, B_Col)
end

local function Check_Is_Target(Target_Name)
    local Character_Instance = Local_Player.Character
    if Character_Instance and Character_Instance:FindFirstChild('Highlight') then return true end
    if not Target_Name then return false end
    local My_Name = String_Lower(Local_Player.Name or "")
    local My_Display = String_Lower(Local_Player.DisplayName or Local_Player.Name or "")
    local Tgt_Str = String_Lower(tostring(Target_Name))
    if Tgt_Str == My_Name or Tgt_Str == My_Display then return true end
    local Clean_Target = String_Gsub(Tgt_Str, '%.%.%.$', '')
    if #Clean_Target >= 3 then
        if String_Sub(My_Name, 1, #Clean_Target) == Clean_Target or String_Sub(My_Display, 1, #Clean_Target) == Clean_Target then return true end
        if String_Find(My_Name, Clean_Target, 1, true) or String_Find(My_Display, Clean_Target, 1, true) then return true end
    end
    return false
end

local function Get_Vector_Magnitude(Target_Vec)
    return Target_Vec and Math_Sqrt(Target_Vec.X^2 + Target_Vec.Y^2 + Target_Vec.Z^2) or 0
end

local function Get_Distance_Between(Pos_A, Pos_B)
    return Pos_A and Pos_B and Math_Sqrt((Pos_A.X - Pos_B.X)^2 + (Pos_A.Y - Pos_B.Y)^2 + (Pos_A.Z - Pos_B.Z)^2) or 0
end

local function Normalize_Vector(Target_Vec)
    if not Target_Vec then return V3_Zero end
    local Target_Magnitude = Get_Vector_Magnitude(Target_Vec)
    return Target_Magnitude > 0 and V3_New(Target_Vec.X / Target_Magnitude, Target_Vec.Y / Target_Magnitude, Target_Vec.Z / Target_Magnitude) or V3_Zero
end

local function Get_Dot_Product(Vec_A, Vec_B)
    return Vec_A and Vec_B and (Vec_A.X * Vec_B.X + Vec_A.Y * Vec_B.Y + Vec_A.Z * Vec_B.Z) or 0
end

local function Flatten_Vector(Target_Vec)
    return Target_Vec and V3_New(Target_Vec.X, 0, Target_Vec.Z) or V3_Zero
end

local Network_Ping_Object = nil
local function Get_Raw_Ping()
    local Current_Ping = 60
    if not Network_Ping_Object or not Network_Ping_Object.Parent then
        Safe_Call(function()
            local Server_Stats = Stats_Service:FindFirstChild("Network") and Stats_Service.Network:FindFirstChild("ServerStatsItem")
            if Server_Stats then
                Network_Ping_Object = Server_Stats:FindFirstChild("Data Ping")
            end
        end)
    end

    if Network_Ping_Object then
        local Success_Read, Value_Read = Safe_Call(function()
            return memory_read("double", Network_Ping_Object.Address + 0xC8)
        end)
        if Success_Read and type(Value_Read) == "number" and Value_Read > 0 then
            Current_Ping = Value_Read
        else
            Safe_Call(function() Current_Ping = Network_Ping_Object.Value end)
        end
    end

    return Math_Min(Current_Ping, Configuration.Capped_Ping or 300)
end

local function Check_Is_Spam(Spam_Params)
    local Target_Obj = Parry_State.Target.Current
    if not Target_Obj then
        return false, Spam_Params.Parries
    end

    local Scaled_Ping = Spam_Params.Ping / 10
    local Range_Val = Scaled_Ping + Math_Min(Spam_Params.Speed / Configuration.Spam_Min_Distance_Speed_Divisor, Configuration.Spam_Min_Distance)

    if Spam_Params.Entity_Distance > Range_Val then
        return false, Spam_Params.Parries
    end

    if Spam_Params.Ball_Distance > Range_Val then
        return false, Spam_Params.Parries
    end

    local Maximum_Speed = Configuration.Spam_Max_Speed_Divisor - Math_Min(Spam_Params.Speed / Configuration.Spam_Max_Speed_Divisor, Configuration.Spam_Max_Speed_Divisor)
    local Maximum_Dot = Math_Clamp(Spam_Params.Dot, -1, 0) * Maximum_Speed
    local Accuracy_Val = Math_Min(Range_Val - Maximum_Dot, Configuration.Spam_Max_Distance)

    if Spam_Params.Ball_Distance <= Accuracy_Val and Spam_Params.Parries >= Configuration.Spam_Threshold then
        return true, Spam_Params.Parries
    end

    return false, Spam_Params.Parries
end

local function Scan_For_Nearest_Entity(Player_Position)
    local Nearest_Entity = nil
    local Minimum_Distance = math.huge

    for _, Target_Player in ipairs(Players_Service:GetPlayers()) do
        if Target_Player ~= Local_Player and Target_Player.Character then
            local Root_Part = Target_Player.Character:FindFirstChild("HumanoidRootPart") or Target_Player.Character.PrimaryPart
            local Humanoid_Part = Target_Player.Character:FindFirstChild("Humanoid")
            if Root_Part and Humanoid_Part and Humanoid_Part.Health > 0 then
                local Current_Distance = Get_Distance_Between(Player_Position, Root_Part.Position)
                if Current_Distance < Minimum_Distance then
                    Minimum_Distance = Current_Distance
                    Nearest_Entity = Target_Player
                end
            end
        end
    end
    return Nearest_Entity, Minimum_Distance
end

local function Analyze_Trajectory(Ball_Instance, Player_Position, Ball_Velocity_Vector, Ball_Speed_Scalar)
    if not Parry_State.Trajectory_Cache[Ball_Instance] then
        Parry_State.Trajectory_Cache[Ball_Instance] = {
            History = {},
            Is_Curving = false,
            Last_Dot = 1,
            Curve_Start_Time = 0
        }
    end
    local Trajectory_Data = Parry_State.Trajectory_Cache[Ball_Instance]
    local Flattened_Player_Pos = Flatten_Vector(Player_Position)
    local Flattened_Ball_Pos = Flatten_Vector(Ball_Instance.Position)
    local Flattened_Velocity = Flatten_Vector(Ball_Velocity_Vector)
    local Vector_To_Player = V3_New(
        Flattened_Player_Pos.X - Flattened_Ball_Pos.X,
        Flattened_Player_Pos.Y - Flattened_Ball_Pos.Y,
        Flattened_Player_Pos.Z - Flattened_Ball_Pos.Z
    )
    local Direction_To_Player = Normalize_Vector(Vector_To_Player)
    local Velocity_Direction = Normalize_Vector(Flattened_Velocity)
    local Current_Dot_Product = Get_Dot_Product(Direction_To_Player, Velocity_Direction)

    if not Current_Dot_Product or Current_Dot_Product ~= Current_Dot_Product then
        Current_Dot_Product = 1
    end

    Table_Insert(Trajectory_Data.History, {Velocity = Ball_Velocity_Vector})
    if #Trajectory_Data.History > 20 then
        Table_Remove(Trajectory_Data.History, 1)
    end

    local Window = Configuration.Curve_History_Window
    local History_Count = #Trajectory_Data.History
    if History_Count >= 4 then
        local Angular_Deviation = 0
        local Start_Index = Math_Max(History_Count - Window + 1, 2)
        for Index_I = Start_Index, History_Count do
            local Previous_Sample = Trajectory_Data.History[Index_I - 1]
            local Current_Sample = Trajectory_Data.History[Index_I]
            local Previous_Direction = Normalize_Vector(Flatten_Vector(Previous_Sample.Velocity))
            local Current_Direction = Normalize_Vector(Flatten_Vector(Current_Sample.Velocity))
            local Velocity_Dot = Math_Clamp(Get_Dot_Product(Previous_Direction, Current_Direction), -1, 1)
            local Deviation_Angle = Math_Deg(Math_Acos(Velocity_Dot))
            if Deviation_Angle ~= Deviation_Angle then Deviation_Angle = 0 end
            local Dynamic_Threshold = Math_Clamp(40 / Math_Max(Ball_Speed_Scalar, 1), Configuration.Curve_Angle_Min_Threshold, 3.0)
            if Deviation_Angle > Dynamic_Threshold then
                Angular_Deviation = Angular_Deviation + (Deviation_Angle / Dynamic_Threshold)
            end
        end
        Trajectory_Data.Is_Curving = Angular_Deviation > 3 and Current_Dot_Product < Configuration.Curve_Dot_Threshold
    end

    if Trajectory_Data.Is_Curving then
        if Trajectory_Data.Curve_Start_Time == 0 then
            Trajectory_Data.Curve_Start_Time = Time_Tick()
        end
    else
        Trajectory_Data.Curve_Start_Time = 0
    end

    Trajectory_Data.Last_Dot = Current_Dot_Product
    return Current_Dot_Product, Trajectory_Data.Is_Curving, Trajectory_Data.Curve_Start_Time
end

local function Detect_Position_Warp(Ball_Instance, Last_Known_Pos, Last_Known_Vel, Dt)
    local Lp = Last_Known_Pos
    if Lp.X == 0 and Lp.Y == 0 and Lp.Z == 0 then return false end
    local Vel_Mag = Get_Vector_Magnitude(Last_Known_Vel)
    if Vel_Mag < 3 then return false end
    local Expected_Pos = V3_New(
        Lp.X + Last_Known_Vel.X * Dt,
        Lp.Y + Last_Known_Vel.Y * Dt,
        Lp.Z + Last_Known_Vel.Z * Dt
    )
    local Actual_Deviation = Get_Distance_Between(Ball_Instance.Position, Expected_Pos)
    return Actual_Deviation > Configuration.Warp_Detect_Threshold
end

local function Get_Optimal_Parry_Threshold(Ball_Instance, Ball_Speed, Player_Position, Current_Ping, Distance_To_Ball, Delta_Time)
    local Capped_Speed = Math_Min(Ball_Speed, Configuration.Capped_Speed)
    local Dot_Product, Is_Curving, Curve_Start_Time = Analyze_Trajectory(Ball_Instance, Player_Position, Parry_State.Ball.Velocity, Capped_Speed)
    Player_State.Tracked_Dot_Product = Dot_Product

    -- Smooth dot and track its rate of change (dot velocity = how fast ball turns toward us)
    local Prev_Smoothed_Dot = Parry_State.Ball.Smoothed_Dot
    Parry_State.Ball.Smoothed_Dot = Parry_State.Ball.Smoothed_Dot + (Dot_Product - Parry_State.Ball.Smoothed_Dot) * 0.2
    if Delta_Time and Delta_Time > 0 then
        local Raw_Dot_Vel = (Parry_State.Ball.Smoothed_Dot - Prev_Smoothed_Dot) / Delta_Time
        Parry_State.Ball.Dot_Velocity = Parry_State.Ball.Dot_Velocity + (Raw_Dot_Vel - Parry_State.Ball.Dot_Velocity) * 0.15
    end

    local Smoothed_Dot = Parry_State.Ball.Smoothed_Dot
    local Dot_Vel = Parry_State.Ball.Dot_Velocity

    -- Ping compensation: use smoothed ping + jitter
    local Effective_Ping = Player_State.Entity.Smoothed_Ping or Current_Ping
    local Jitter_Smoothed = Player_State.Entity.Jitter_Smoothed or 0
    local Ping_Seconds = Effective_Ping / 1000
    -- Approaching ball needs more ping buffer, departing ball needs less
    local Approach_Factor = Math_Clamp((Smoothed_Dot + 1) / 2, 0.5, 1.0)
    local Ping_Buffer = (Effective_Ping * 0.09 + Math_Max(0, Jitter_Smoothed - 10) * 0.4) * Approach_Factor

    local Capped_Speed_Diff = Math_Min(Math_Max(Ball_Speed - 9.5, 0), Configuration.Capped_Speed)
    local Dynamic_Divisor = Configuration.Speed_Divisor_Base + (Capped_Speed_Diff * Configuration.Speed_Divisor_Multiplier)
    Dynamic_Divisor = Dynamic_Divisor * Configuration.Parry_Accuracy_Multiplier

    local Base_Threshold = Ping_Buffer + Math_Max(Ball_Speed / Math_Max(Dynamic_Divisor, 0.01), 9.5)
    local Accuracy_Offset = (Configuration.Parry_Accuracy_Multiplier - 1) * 15
    Base_Threshold = Base_Threshold - Accuracy_Offset

    -- Warp detection boost
    local Now = Time_Tick()
    if Delta_Time and Delta_Time > 0 then
        if Detect_Position_Warp(Ball_Instance, Parry_State.Ball.Last_Position, Parry_State.Ball.Velocity, Delta_Time) then
            Parry_State.Ball.Warp_Detected_Time = Now
        end
    end
    local Warp_Boost = 0
    local Time_Since_Warp = Now - Parry_State.Ball.Warp_Detected_Time
    if Time_Since_Warp < Configuration.Warp_Boost_Duration then
        Warp_Boost = Configuration.Warp_Boost_Amount * (1 - Time_Since_Warp / Configuration.Warp_Boost_Duration)
    end

    local Parry_Threshold = Base_Threshold + Warp_Boost

    -- Curve handling
    if Is_Curving and Capped_Speed >= Configuration.Curve_Min_Speed_Threshold then
        local Speed_Factor = Capped_Speed / Configuration.Curve_Speed_Threshold_Divisor
        local Dist_Factor = Distance_To_Ball / Configuration.Curve_Ball_Distance_Threshold_Divisor
        local Active_Curve_Time = Now - Curve_Start_Time
        local Warp_Dur_Factor = Parry_Threshold / Configuration.Curve_Warping_Duration_Divisor
        local Curve_Dur_Factor = Parry_Threshold / Configuration.Curve_Curving_Duration_Divisor

        if Smoothed_Dot < -0.1 then
            -- Backwards curving ball: predict if it will reach us within ping window
            local Predicted_Dot = Smoothed_Dot + Dot_Vel * Ping_Seconds * 2.5
            if Dot_Vel > 0.8 and Predicted_Dot > -0.05 then
                -- Ball is actively turning back toward us, open threshold to catch it
                local Turn_Urgency = Math_Clamp(Dot_Vel / 5.0, 0, 1)
                Parry_Threshold = Math_Max(Parry_Threshold, Base_Threshold + Ping_Buffer * 1.8 + Turn_Urgency * 10)
            else
                -- Ball going away and not turning back, tight cap
                local Back_Cap = Math_Max(Base_Threshold * 0.6, Ping_Buffer * 1.2 + Distance_To_Ball * 0.1)
                Parry_Threshold = Math_Min(Parry_Threshold, Math_Max(Back_Cap, 14))
            end
        else
            local Curve_Deduction = (15.0 * Speed_Factor) * Math_Clamp(1 - Dot_Product, 0.1, 1)
            if Active_Curve_Time < Configuration.Curve_Warning_Duration or Active_Curve_Time < Configuration.Curve_Curving_Duration then
                Curve_Deduction = Curve_Deduction * (1 + Warp_Dur_Factor + Curve_Dur_Factor)
            end
            Parry_Threshold = Math_Max(Parry_Threshold - Curve_Deduction - (Dist_Factor * 5), 18)
        end
    else
        Parry_Threshold = Math_Max(Parry_Threshold, 5.5)
    end

    -- Dot protect: only restrict when ball is genuinely going away at high speed
    if Configuration.Dot_Protect then
        if Smoothed_Dot < -0.2 and Ball_Speed >= 30 then
            local Predicted_Dot = Smoothed_Dot + Dot_Vel * Ping_Seconds * 2.5
            if Dot_Vel > 0.8 and Predicted_Dot > -0.05 then
                -- Turning back toward us, ensure threshold is open enough
                local Turn_Urgency = Math_Clamp(Dot_Vel / 5.0, 0, 1)
                Parry_Threshold = Math_Max(Parry_Threshold, Ping_Buffer * 2.0 + Turn_Urgency * 12)
            else
                -- Genuinely going away
                if Distance_To_Ball > Configuration.Dot_Back_Distance_Gate then
                    local Back_Limit = Math_Max(16, Ping_Buffer * 1.6 + Distance_To_Ball * 0.12)
                    Parry_Threshold = Math_Min(Parry_Threshold, Back_Limit)
                else
                    local Close_Back_Limit = Math_Max(20, Ping_Buffer * 2.0 + Distance_To_Ball * 0.2)
                    Parry_Threshold = Math_Min(Parry_Threshold, Close_Back_Limit)
                end
            end
        elseif Smoothed_Dot > -0.2 and Smoothed_Dot <= Configuration.Dot_Threshold then
            if Capped_Speed >= Configuration.Dot_Min_Speed and Distance_To_Ball <= Configuration.Dot_Distance_Threshold then
                local Angle_Factor = 1 - (Smoothed_Dot / Configuration.Dot_Threshold)
                local Dot_Limit = Ping_Buffer + Distance_To_Ball * 0.8 + (Angle_Factor * 10)
                Parry_Threshold = Math_Min(Parry_Threshold, Math_Max(Dot_Limit, Configuration.Dot_Limit_Threshold))
            end
        end
    end

    return Parry_Threshold * Configuration.Ping_Multiplier
end

local Virtual_Keycode_Map = {
    [8] = "BACK", [9] = "TAB", [13] = "ENTER", [16] = "SHIFT", [17] = "CTRL", [18] = "ALT", [20] = "CAPS",
    [27] = "ESC", [32] = "SPACE", [33] = "PGUP", [34] = "PGDN", [35] = "END", [36] = "HOME",
    [37] = "LEFT", [38] = "UP", [39] = "RIGHT", [40] = "DOWN", [45] = "INS", [46] = "DEL",
    [160] = "LSHF", [161] = "RSHF", [162] = "LCTL", [163] = "RCTL", [164] = "LALT", [165] = "RALT"
}

local function Format_Keycode_Name(Keycode_Val)
    if type(Keycode_Val) ~= "number" or Keycode_Val <= 0 then return "-" end
    if Virtual_Keycode_Map[Keycode_Val] then return Virtual_Keycode_Map[Keycode_Val] end
    if Keycode_Val >= 48 and Keycode_Val <= 57 then return string.char(Keycode_Val) end
    if Keycode_Val >= 65 and Keycode_Val <= 90 then return string.char(Keycode_Val) end
    if Keycode_Val >= 112 and Keycode_Val <= 123 then return String_Format("F%d", Keycode_Val - 111) end
    return String_Format("K%d", Keycode_Val)
end

Interface_Manager = {
    Elements = {}, Toggles = {}, Sliders = {}, Binds = {}, Dropdowns = {}, Color_Pickers = {}, Buttons = {},
    Color_Map = {
        Outline = {}, Background = {}, Inline = {}, Accent_Color = {}, Sidebar_Background = {}, Group_Background = {}, Primary_Text = {}, Secondary_Text = {}, Toggle_Background = {}, Hover_State = {}
    },
    Navigation_Tabs = {"Combat", "Settings", "Themes", "Configs"},
    Current_Tab = "Combat",
    Base_Position = V2_New(200, 200),
    Dimensions = V2_New(550, 430),
    Minimum_Dimensions = V2_New(420, 320),
    Is_Dragging = false,
    Drag_Start_Location = nil,
    Initial_Window_Position = nil,
    Is_Resizing = false,
    Resize_Direction = nil,
    Resize_Start_Location = nil,
    Initial_Window_Size = nil,
    Is_Dragging_Indicator = false,
    Indicator_Drag_Start = nil,
    Initial_Indicator_Position = nil,
    Is_Dragging_Stats = false,
    Stats_Drag_Start = nil,
    Initial_Stats_Position = nil,
    Is_Dragging_Manual_Spam = false,
    Manual_Spam_Drag_Start = nil,
    Initial_Manual_Spam_Position = nil,
    Indicator_Position = V2_New(50, 400),
    Stats_Panel_Position = V2_New(300, 400),
    Manual_Spam_Panel_Position = V2_New(500, 400),
    Active_Slider_Element = nil,
    Active_Dropdown_Element = nil,
    Active_Picker_Element = nil,
    Hide_Key_Held = false,
    Resize_Corners = {},
    Themes = {
        {"Nightfall", {Bg="#0A0B10", Out="#000000", In_Box="#1A1B24", Acc="#A75CFF", Side="#0F1017", Grp="#0D0E15", Prim="#FFFFFF", Sec="#8A8D9E", Tog="#14151E", Hov="#1E1F2A"}},
        {"Bloodmoon", {Bg="#120505", Out="#000000", In_Box="#241010", Acc="#FF3333", Side="#170A0A", Grp="#140707", Prim="#FFFFFF", Sec="#9E7A7A", Tog="#1E1212", Hov="#2A1616"}},
        {"Ocean", {Bg="#050A12", Out="#000000", In_Box="#101A24", Acc="#33A7FF", Side="#0A1017", Grp="#070D14", Prim="#FFFFFF", Sec="#7A8D9E", Tog="#12151E", Hov="#161F2A"}},
        {"Mint", {Bg="#05120C", Out="#000000", In_Box="#10241A", Acc="#33FF99", Side="#0A1712", Grp="#07140F", Prim="#FFFFFF", Sec="#7A9E8A", Tog="#121E17", Hov="#162A1F"}}
    },
    Palette = {
        Background = C3_Hex("#0A0B10"), Outline = C3_Hex("#000000"), Inline = C3_Hex("#1A1B24"),
        Accent_Color = C3_Hex("#A75CFF"), Sidebar_Background = C3_Hex("#0F1017"), Group_Background = C3_Hex("#0D0E15"),
        Primary_Text = C3_Hex("#FFFFFF"), Secondary_Text = C3_Hex("#8A8D9E"), Toggle_Background = C3_Hex("#14151E"),
        Hover_State = C3_Hex("#1E1F2A")
    }
}

function Update_Colors()
    for Color_Key, Objects_List in pairs(Interface_Manager.Color_Map) do
        local Target_Color = Interface_Manager.Palette[Color_Key]
        for _, Target_Obj in ipairs(Objects_List) do
            Safe_Call(function() Target_Obj.Color = Target_Color end)
        end
    end
    for Renderer_Name, Renderer_Data in pairs(Interface_Manager.Tab_Renderers) do
        Renderer_Data.Text_Obj.Color = (Renderer_Name == Interface_Manager.Current_Tab) and Interface_Manager.Palette.Primary_Text or Interface_Manager.Palette.Secondary_Text
    end
end

function Apply_Theme(Theme_Index)
    local Preset_Data = Interface_Manager.Themes[Theme_Index][2]
    Interface_Manager.Palette.Background = C3_Hex(Preset_Data.Bg)
    Interface_Manager.Palette.Outline = C3_Hex(Preset_Data.Out)
    Interface_Manager.Palette.Inline = C3_Hex(Preset_Data.In_Box)
    Interface_Manager.Palette.Accent_Color = C3_Hex(Preset_Data.Acc)
    Interface_Manager.Palette.Sidebar_Background = C3_Hex(Preset_Data.Side)
    Interface_Manager.Palette.Group_Background = C3_Hex(Preset_Data.Grp)
    Interface_Manager.Palette.Primary_Text = C3_Hex(Preset_Data.Prim)
    Interface_Manager.Palette.Secondary_Text = C3_Hex(Preset_Data.Sec)
    Interface_Manager.Palette.Toggle_Background = C3_Hex(Preset_Data.Tog)
    Interface_Manager.Palette.Hover_State = C3_Hex(Preset_Data.Hov)
    Update_Colors()
end

local Uninitialized_Dropdowns = {}

local function Instantiate_Drawing(Class_Name, Properties_Table, Color_Key)
    local Drawing_Object = Drawing.new(Class_Name)
    for Property_Name, Property_Value in pairs(Properties_Table) do
        Safe_Call(function() Drawing_Object[Property_Name] = Property_Value end)
    end
    if Color_Key and Interface_Manager.Color_Map[Color_Key] then
        Table_Insert(Interface_Manager.Color_Map[Color_Key], Drawing_Object)
    end
    Table_Insert(_G.Nightfall_Drawings, Drawing_Object)
    return Drawing_Object
end

local function Construct_User_Interface()
    Interface_Manager.Main_Outline = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 0.3, Rounding = 12}, "Outline")
    Interface_Manager.Main_Background = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 0.7, Rounding = 12}, "Background")
    Interface_Manager.Sidebar_Area = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 0.6, Rounding = 12}, "Sidebar_Background")
    Interface_Manager.Sidebar_Divider = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 0.2}, "Outline")

    local Corner_Directions = {"TL", "TR", "BL", "BR"}
    for _, Direction_Id in ipairs(Corner_Directions) do
        Interface_Manager.Resize_Corners[Direction_Id] = {
            Horizontal = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 1}, "Accent_Color"),
            Vertical = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 1}, "Accent_Color")
        }
    end

    Interface_Manager.Top_Accent_Line = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 1}, "Accent_Color")
    Interface_Manager.Title_Text = Instantiate_Drawing("Text", {Text = "NIGHTFALL", Size = 16, Font = Drawing.Fonts.System, Outline = true, Visible = true, Transparency = 1}, "Primary_Text")

    Interface_Manager.Tab_Renderers = {}
    for Index_Val, Tab_Name in ipairs(Interface_Manager.Navigation_Tabs) do
        local Text_Renderer = Instantiate_Drawing("Text", {Text = Tab_Name, Size = 14, Font = Drawing.Fonts.System, Outline = true, Visible = true, Transparency = 1})
        local Indicator_Renderer = Instantiate_Drawing("Square", {Filled = true, Visible = (Index_Val == 1), Transparency = 1}, "Accent_Color")
        Interface_Manager.Tab_Renderers[Tab_Name] = {Text_Obj = Text_Renderer, Indicator = Indicator_Renderer, Render_Index = Index_Val}
    end

    Interface_Manager.Group_Container_List = {}
    local function Create_Group_Container(Tab_Name, Section_Name, Grid_Side)
        local Container_Data = {
            Outline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.2, Rounding = 8}, "Outline"),
            Background_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.1, Rounding = 8}, "Group_Background"),
            Title_Background = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.6, Rounding = 6}, "Background"),
            Title_Text = Instantiate_Drawing("Text", {Text = Section_Name, Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Primary_Text"),
            Parent_Tab = Tab_Name, Grid_Side = Grid_Side, Item_Count = 0
        }
        Table_Insert(Interface_Manager.Group_Container_List, Container_Data)
        return Container_Data
    end

    local Combat_Main_Section = Create_Group_Container("Combat", "Main", 1)
    local Combat_Offensive_Section = Create_Group_Container("Combat", "Offensive", 2)
    local Settings_Config_Section = Create_Group_Container("Settings", "Configuration", 1)
    local Theme_Main_Section = Create_Group_Container("Themes", "Appearance", 1)
    local Theme_Picker_Section = Create_Group_Container("Themes", "Custom Theme", 2)
    local Configs_Main_Section = Create_Group_Container("Configs", "Config Manager", 1)

    local function Create_Toggle_Element(Parent_Group, Display_Name, Config_Identifier, Keybind_Identifier)
        local Vertical_Offset = Parent_Group.Item_Count * 25
        local Default_Fill_Color = Configuration[Config_Identifier] and Interface_Manager.Palette.Accent_Color or Interface_Manager.Palette.Toggle_Background
        local Default_Text_Color = Configuration[Config_Identifier] and Interface_Manager.Palette.Primary_Text or Interface_Manager.Palette.Secondary_Text
        local Toggle_Element = {
            Outline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Outline, Filled = true, Visible = false, Transparency = 0.3, Rounding = 5}),
            Inline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Inline, Filled = true, Visible = false, Transparency = 0.5, Rounding = 5}),
            Fill_Box = Instantiate_Drawing("Square", {Color = Default_Fill_Color, Filled = true, Visible = false, Transparency = 1, Rounding = 4}),
            Label_Text = Instantiate_Drawing("Text", {Text = Display_Name, Color = Default_Text_Color, Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}),
            Parent_Group = Parent_Group, Offset_Y = Vertical_Offset, Config_Key = Config_Identifier,
            Target_Inline_Color = Interface_Manager.Palette.Inline, Target_Fill_Color = Default_Fill_Color, Target_Text_Color = Default_Text_Color
        }
        Table_Insert(Interface_Manager.Toggles, Toggle_Element)
        if Keybind_Identifier then
            local Keybind_Element = {
                Outline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Outline, Filled = true, Visible = false, Transparency = 0.3, Rounding = 6}),
                Inline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Toggle_Background, Filled = true, Visible = false, Transparency = 0.6, Rounding = 5}),
                Label_Text = Instantiate_Drawing("Text", {Text = "[ - ]", Color = Interface_Manager.Palette.Secondary_Text, Size = 12, Font = Drawing.Fonts.System, Outline = true, Center = true, Visible = false, Transparency = 1}),
                Parent_Group = Parent_Group, Offset_Y = Vertical_Offset, Config_Key = Keybind_Identifier, Action_Key = Keybind_Identifier, Target_Inline_Color = Interface_Manager.Palette.Toggle_Background, Is_Full_Width = false
            }
            Table_Insert(Interface_Manager.Binds, Keybind_Element)
            Toggle_Element.Keybind_Data = Keybind_Element
        end
        Parent_Group.Item_Count = Parent_Group.Item_Count + 1
    end

    local function Create_Dropdown_Element(Parent_Group, Display_Name, Config_Identifier, Option_List, Is_Theme_Dropdown)
        local Vertical_Offset = Parent_Group.Item_Count * 25
        local Dropdown_Element = {
            Outline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Outline, Filled = true, Visible = false, Transparency = 0.3, Rounding = 6}),
            Inline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Toggle_Background, Filled = true, Visible = false, Transparency = 0.6, Rounding = 6}),
            Label_Text = Instantiate_Drawing("Text", {Text = String_Format("%s: %s", Display_Name, Option_List[Configuration[Config_Identifier]]), Color = Interface_Manager.Palette.Secondary_Text, Size = 13, Font = Drawing.Fonts.System, Outline = true, Center = false, Visible = false, Transparency = 1}),
            State_Icon = Instantiate_Drawing("Text", {Text = "+", Color = Interface_Manager.Palette.Secondary_Text, Size = 13, Font = Drawing.Fonts.System, Outline = true, Center = false, Visible = false, Transparency = 1}),
            Parent_Group = Parent_Group, Offset_Y = Vertical_Offset, Config_Key = Config_Identifier, Display_Name = Display_Name, Option_Data = Option_List, Is_Open = false, Current_Height = 0, Maximum_Height = #Option_List * 20 + 2,
            Item_Renderers = {}, Target_Inline_Color = Interface_Manager.Palette.Toggle_Background, Is_Theme_Dropdown = Is_Theme_Dropdown
        }
        Table_Insert(Interface_Manager.Dropdowns, Dropdown_Element)
        Table_Insert(Uninitialized_Dropdowns, Dropdown_Element)
        Parent_Group.Item_Count = Parent_Group.Item_Count + 1.2
    end

    local function Create_Slider_Element(Parent_Group, Display_Name, Config_Identifier, Min_Value, Max_Value, Decimal_Places, Suffix_Text)
        local Vertical_Offset = Parent_Group.Item_Count * 25
        local Slider_Element = {
            Label_Text = Instantiate_Drawing("Text", {Text = Display_Name, Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Secondary_Text"),
            Value_Text = Instantiate_Drawing("Text", {Text = "", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Primary_Text"),
            Outline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.3, Rounding = 6}, "Outline"),
            Background_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.5, Rounding = 6}, "Toggle_Background"),
            Fill_Indicator = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.9, Rounding = 6}, "Accent_Color"),
            Drag_Thumb = Instantiate_Drawing("Circle", {Filled = true, Radius = 4, Visible = false, Transparency = 1}, "Primary_Text"),
            Parent_Group = Parent_Group, Offset_Y = Vertical_Offset + 15, Config_Key = Config_Identifier, Min_Bound = Min_Value, Max_Bound = Max_Value, Precision = Decimal_Places, Value_Suffix = Suffix_Text
        }
        Table_Insert(Interface_Manager.Sliders, Slider_Element)
        Parent_Group.Item_Count = Parent_Group.Item_Count + 1.5
    end

    local function Create_Color_Picker(Parent_Group, Color_Key_Target)
        local Vertical_Offset = Parent_Group.Item_Count * 25
        local Cp_Data = {
            Sv_Outline = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.5, Rounding = 2}, "Outline"),
            Sv_Background = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 1, Rounding = 2}),
            Sv_Blocks = {},
            Hue_Outline = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.5, Rounding = 2}, "Outline"),
            Hue_Blocks = {},
            Alpha_Outline = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.5, Rounding = 2}, "Outline"),
            Alpha_Blocks = {},
            Details_Text1 = Instantiate_Drawing("Text", {Text = "", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Primary_Text"),
            Details_Text2 = Instantiate_Drawing("Text", {Text = "", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Primary_Text"),
            Hex_Text = Instantiate_Drawing("Text", {Text = "", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Accent_Color"),
            Parent_Group = Parent_Group, Offset_Y = Vertical_Offset, Color_Key = Color_Key_Target,
            Hue = 0.7, Sat = 0.7, Val = 0.9, Alpha = 1
        }

        local Grid_Res = 20
        local Sv_Size = 110
        local Block_Size = Sv_Size / Grid_Res
        local Ceil_Size = math.ceil(Block_Size)
        for Index_Y = 0, Grid_Res - 1 do
            for Index_X = 0, Grid_Res - 1 do
                local Sq_Obj = Instantiate_Drawing("Square", {Filled = true, Visible = false, Thickness = 0})
                Table_Insert(Cp_Data.Sv_Blocks, {Sq_Obj, Index_X, Index_Y, Block_Size, Ceil_Size})
            end
        end

        for Index_I = 1, 50 do
            local Hb_Obj = Instantiate_Drawing("Square", {Filled = true, Visible = false, Thickness = 0})
            Table_Insert(Cp_Data.Hue_Blocks, Hb_Obj)
            local Ab_Obj = Instantiate_Drawing("Square", {Filled = true, Visible = false, Thickness = 0})
            Table_Insert(Cp_Data.Alpha_Blocks, Ab_Obj)
        end

        Cp_Data.Sv_Cursor = Instantiate_Drawing("Circle", {Color = C3_New(1, 1, 1), Filled = false, Thickness = 1.5, Radius = 4, Visible = false, Transparency = 1})
        Cp_Data.Hue_Cursor = Instantiate_Drawing("Square", {Color = C3_New(1, 1, 1), Filled = false, Thickness = 1.5, Visible = false, Transparency = 1})
        Cp_Data.Alpha_Cursor = Instantiate_Drawing("Square", {Color = C3_New(1, 1, 1), Filled = false, Thickness = 1.5, Visible = false, Transparency = 1})

        Table_Insert(Interface_Manager.Color_Pickers, Cp_Data)
        Parent_Group.Item_Count = Parent_Group.Item_Count + 7.5
    end

    local function Create_Full_Keybind_Element(Parent_Group, Display_Name, Config_Identifier)
        local Vertical_Offset = Parent_Group.Item_Count * 25
        local Formatted_Text = String_Format("%s [ %s ]", Display_Name, Format_Keycode_Name(Configuration[Config_Identifier]))
        local Keybind_Element = {
            Display_Name = Display_Name,
            Outline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Outline, Filled = true, Visible = false, Transparency = 0.3, Rounding = 8}),
            Inline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Toggle_Background, Filled = true, Visible = false, Transparency = 0.6, Rounding = 7}),
            Label_Text = Instantiate_Drawing("Text", {Text = Formatted_Text, Color = Interface_Manager.Palette.Secondary_Text, Size = 13, Font = Drawing.Fonts.System, Outline = true, Center = true, Visible = false, Transparency = 1}),
            Parent_Group = Parent_Group, Offset_Y = Vertical_Offset, Config_Key = Config_Identifier, Action_Key = Config_Identifier, Is_Full_Width = true, Target_Inline_Color = Interface_Manager.Palette.Toggle_Background
        }
        Table_Insert(Interface_Manager.Binds, Keybind_Element)
        Parent_Group.Item_Count = Parent_Group.Item_Count + 1
    end

    local function Create_Button(Parent_Group, Display_Name, Callback_Func)
        local Vertical_Offset = Parent_Group.Item_Count * 25
        local Btn_Element = {
            Outline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Outline, Filled = true, Visible = false, Transparency = 0.3, Rounding = 6}),
            Inline_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Toggle_Background, Filled = true, Visible = false, Transparency = 0.6, Rounding = 6}),
            Label_Text = Instantiate_Drawing("Text", {Text = Display_Name, Color = Interface_Manager.Palette.Primary_Text, Size = 13, Font = Drawing.Fonts.System, Outline = true, Center = true, Visible = false, Transparency = 1}),
            Parent_Group = Parent_Group, Offset_Y = Vertical_Offset, Callback_Func = Callback_Func, Target_Inline_Color = Interface_Manager.Palette.Toggle_Background
        }
        Table_Insert(Interface_Manager.Buttons, Btn_Element)
        Parent_Group.Item_Count = Parent_Group.Item_Count + 1.2
    end

    Create_Toggle_Element(Combat_Main_Section, "Auto Parry", "Auto_Parry", "Parry_Keybind")
    Create_Toggle_Element(Combat_Main_Section, "Lobby Parry", "Lobby_Parry", nil)
    Create_Dropdown_Element(Combat_Main_Section, "Method", "Parry_Method", {"Click", "Key"}, false)

    Create_Toggle_Element(Combat_Offensive_Section, "Auto Spam", "Auto_Spam", "Spam_Keybind")
    Create_Toggle_Element(Combat_Offensive_Section, "Triggerbot", "Triggerbot_Enabled", "Triggerbot_Keybind")
    Create_Toggle_Element(Combat_Offensive_Section, "Manual Spam", "Manual_Spam_Ui", "Manual_Spam_Keybind")
    Create_Toggle_Element(Combat_Offensive_Section, "Anti Curve", "Dot_Protect", nil)
    Create_Toggle_Element(Combat_Offensive_Section, "Ball Stats", "Render_Ball_Stats", nil)
    Create_Toggle_Element(Combat_Offensive_Section, "Auto Curve", "Auto_Curve", "Auto_Curve_Keybind")
    Create_Dropdown_Element(Combat_Offensive_Section, "Mode", "Auto_Curve_Mode", {"High", "Backwards"}, false)
    Create_Slider_Element(Combat_Offensive_Section, "Camera Senstivity", "Camera_Sens", 0.1, 1.0, 2, "")

    Create_Toggle_Element(Settings_Config_Section, "Keybinds List", "Render_Keybinds", nil)
    Create_Slider_Element(Settings_Config_Section, "Min Tb Delay", "Min_Tb_Delay", 1, 100, 0, " ms")
    Create_Slider_Element(Settings_Config_Section, "Max Tb Delay", "Max_Tb_Delay", 1, 100, 0, " ms")
    Create_Full_Keybind_Element(Settings_Config_Section, "Menu Bind", "Hide_Keybind")

    local Theme_Names = {}
    for _, Theme_Tuple in ipairs(Interface_Manager.Themes) do Table_Insert(Theme_Names, Theme_Tuple[1]) end
    Create_Dropdown_Element(Theme_Main_Section, "Preset", "Theme_Preset", Theme_Names, true)
    Create_Color_Picker(Theme_Picker_Section, "Accent_Color")

    Create_Button(Configs_Main_Section, "Save Config", Save_Config)
    Create_Button(Configs_Main_Section, "Load Config", Load_Config)

    Interface_Manager.Overlay_Indicator = {
        Outline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 0.5, Rounding = 4}, "Outline"),
        Inline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 0.7, Rounding = 4}, "Inline"),
        Background_Box = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 0.9, Rounding = 4}, "Group_Background"),
        Accent_Line = Instantiate_Drawing("Square", {Filled = true, Visible = true, Transparency = 1}, "Accent_Color"),
        Title_Text = Instantiate_Drawing("Text", {Text = "keybinds", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = true, Transparency = 1}, "Primary_Text"),
        Render_Rows = {}
    }
    for _ = 1, 4 do
        Table_Insert(Interface_Manager.Overlay_Indicator.Render_Rows, {
            Name_Text = Instantiate_Drawing("Text", {Text = "", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = true, Transparency = 1}, "Primary_Text"),
            State_Text = Instantiate_Drawing("Text", {Text = "", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = true, Transparency = 1})
        })
    end

    Interface_Manager.Stats_Panel = {
        Outline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.5, Rounding = 4}, "Outline"),
        Inline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.7, Rounding = 4}, "Inline"),
        Background_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.9, Rounding = 4}, "Group_Background"),
        Accent_Line = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 1}, "Accent_Color"),
        Title_Text = Instantiate_Drawing("Text", {Text = "GENERAL", Size = 12, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Secondary_Text"),
        Render_Rows = {}
    }
    local Stat_Identifiers = {"Ball Speed", "Ball Distance", "Ball Dot"}
    for Index_Val = 1, 3 do
        Table_Insert(Interface_Manager.Stats_Panel.Render_Rows, {
            Label_Text = Instantiate_Drawing("Text", {Text = Stat_Identifiers[Index_Val], Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Primary_Text"),
            Value_Text = Instantiate_Drawing("Text", {Text = "-", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Accent_Color"),
            Divider_Line = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.3}, "Outline")
        })
    end

    Interface_Manager.Manual_Spam_Panel = {
        Outline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.5, Rounding = 4}, "Outline"),
        Inline_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.7, Rounding = 4}, "Inline"),
        Background_Box = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 0.9, Rounding = 4}, "Group_Background"),
        Accent_Line = Instantiate_Drawing("Square", {Filled = true, Visible = false, Transparency = 1}, "Accent_Color"),
        Title_Text = Instantiate_Drawing("Text", {Text = "MANUAL SPAM", Size = 13, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1}, "Primary_Text"),
        State_Text = Instantiate_Drawing("Text", {Text = "OFF", Size = 16, Font = Drawing.Fonts.System, Outline = true, Visible = false, Transparency = 1, Center = true}, "Secondary_Text"),
    }

    for _, Dropdown_Data in ipairs(Uninitialized_Dropdowns) do
        Dropdown_Data.List_Outline = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Outline, Filled = true, Transparency = 0, Rounding = 8, Visible = false})
        Dropdown_Data.List_Inline = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Group_Background, Filled = true, Transparency = 0, Rounding = 7, Visible = false})
        for _, Option_String in ipairs(Dropdown_Data.Option_Data) do
            Table_Insert(Dropdown_Data.Item_Renderers, {
                Label_Text = Instantiate_Drawing("Text", {Text = Option_String, Color = Interface_Manager.Palette.Secondary_Text, Size = 13, Font = Drawing.Fonts.System, Outline = true, Transparency = 0, Visible = false}),
                Background_Box = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Toggle_Background, Filled = true, Transparency = 0, Rounding = 4, Visible = false}),
                Active_Indicator = Instantiate_Drawing("Square", {Color = Interface_Manager.Palette.Accent_Color, Filled = true, Transparency = 0, Rounding = 0, Visible = false}),
                Target_Background_Color = Interface_Manager.Palette.Group_Background, Target_Text_Color = Interface_Manager.Palette.Secondary_Text, Base_Layout_Position = V2_Zero, Layout_Dimensions = V2_Zero
            })
        end
    end
end

local function Refresh_Layout_Coordinates()
    local Base_Pos = Interface_Manager.Base_Position
    local Base_Size = Interface_Manager.Dimensions

    Interface_Manager.Main_Outline.Position = Base_Pos - V2_New(1, 1)
    Interface_Manager.Main_Outline.Size = Base_Size + V2_New(2, 2)
    Interface_Manager.Main_Background.Position = Base_Pos
    Interface_Manager.Main_Background.Size = Base_Size

    if Interface_Manager.Resize_Corners.TL then
        Interface_Manager.Resize_Corners.TL.Horizontal.Position = Base_Pos - V2_New(1, 1)
        Interface_Manager.Resize_Corners.TL.Horizontal.Size = V2_New(15, 2)
        Interface_Manager.Resize_Corners.TL.Vertical.Position = Base_Pos - V2_New(1, 1)
        Interface_Manager.Resize_Corners.TL.Vertical.Size = V2_New(2, 15)
        Interface_Manager.Resize_Corners.TR.Horizontal.Position = Base_Pos + V2_New(Base_Size.X - 14, -1)
        Interface_Manager.Resize_Corners.TR.Horizontal.Size = V2_New(15, 2)
        Interface_Manager.Resize_Corners.TR.Vertical.Position = Base_Pos + V2_New(Base_Size.X - 1, -1)
        Interface_Manager.Resize_Corners.TR.Vertical.Size = V2_New(2, 15)
        Interface_Manager.Resize_Corners.BL.Horizontal.Position = Base_Pos + V2_New(-1, Base_Size.Y - 1)
        Interface_Manager.Resize_Corners.BL.Horizontal.Size = V2_New(15, 2)
        Interface_Manager.Resize_Corners.BL.Vertical.Position = Base_Pos + V2_New(-1, Base_Size.Y - 14)
        Interface_Manager.Resize_Corners.BL.Vertical.Size = V2_New(2, 15)
        Interface_Manager.Resize_Corners.BR.Horizontal.Position = Base_Pos + V2_New(Base_Size.X - 14, Base_Size.Y - 1)
        Interface_Manager.Resize_Corners.BR.Horizontal.Size = V2_New(15, 2)
        Interface_Manager.Resize_Corners.BR.Vertical.Position = Base_Pos + V2_New(Base_Size.X - 1, Base_Size.Y - 14)
        Interface_Manager.Resize_Corners.BR.Vertical.Size = V2_New(2, 15)
    end

    Interface_Manager.Sidebar_Area.Position = Base_Pos
    Interface_Manager.Sidebar_Area.Size = V2_New(130, Base_Size.Y)
    Interface_Manager.Sidebar_Divider.Position = Base_Pos + V2_New(130, 0)
    Interface_Manager.Sidebar_Divider.Size = V2_New(1, Base_Size.Y)
    Interface_Manager.Top_Accent_Line.Position = Base_Pos
    Interface_Manager.Top_Accent_Line.Size = V2_New(Base_Size.X, 2)
    Interface_Manager.Title_Text.Position = Base_Pos + V2_New(20, 15)

    for _, Tab_Data in pairs(Interface_Manager.Tab_Renderers) do
        local Layout_Y = 50 + (Tab_Data.Render_Index * 30)
        Tab_Data.Text_Obj.Position = Base_Pos + V2_New(25, Layout_Y)
        Tab_Data.Indicator.Position = Base_Pos + V2_New(1, Layout_Y + 1)
        Tab_Data.Indicator.Size = V2_New(2, 12)
    end

    local Calculated_Group_Width = (Base_Size.X - 130 - 45) / 2
    for _, Group_Data in ipairs(Interface_Manager.Group_Container_List) do
        local Layout_X = Base_Pos.X + 130 + 15 + ((Group_Data.Grid_Side - 1) * (Calculated_Group_Width + 15))
        local Layout_Y = Base_Pos.Y + 20
        Group_Data.Outline_Box.Position = V2_New(Layout_X, Layout_Y)
        Group_Data.Outline_Box.Size = V2_New(Calculated_Group_Width, Base_Size.Y - 40)
        Group_Data.Background_Box.Position = V2_New(Layout_X + 1, Layout_Y + 1)
        Group_Data.Background_Box.Size = V2_New(Calculated_Group_Width - 2, Base_Size.Y - 42)
        local Text_Boundary_Width = Group_Data.Title_Text.TextBounds.X
        Group_Data.Title_Background.Position = V2_New(Layout_X + 10, Layout_Y - 2)
        Group_Data.Title_Background.Size = V2_New(Text_Boundary_Width + 8, 4)
        Group_Data.Title_Text.Position = V2_New(Layout_X + 14, Layout_Y - 6)
    end

    for _, Toggle_Data in ipairs(Interface_Manager.Toggles) do
        local Layout_X = Toggle_Data.Parent_Group.Background_Box.Position.X + 15
        local Layout_Y = Toggle_Data.Parent_Group.Background_Box.Position.Y + 20 + Toggle_Data.Offset_Y
        Toggle_Data.Outline_Box.Position = V2_New(Layout_X, Layout_Y)
        Toggle_Data.Outline_Box.Size = V2_New(12, 12)
        Toggle_Data.Inline_Box.Position = V2_New(Layout_X + 1, Layout_Y + 1)
        Toggle_Data.Inline_Box.Size = V2_New(10, 10)
        Toggle_Data.Fill_Box.Position = V2_New(Layout_X + 2, Layout_Y + 2)
        Toggle_Data.Fill_Box.Size = V2_New(8, 8)
        Toggle_Data.Label_Text.Position = V2_New(Layout_X + 20, Layout_Y - 1)
    end

    for _, Dropdown_Data in ipairs(Interface_Manager.Dropdowns) do
        local Layout_X = Dropdown_Data.Parent_Group.Background_Box.Position.X + 15
        local Layout_Y = Dropdown_Data.Parent_Group.Background_Box.Position.Y + 20 + Dropdown_Data.Offset_Y
        local Layout_Width = Dropdown_Data.Parent_Group.Background_Box.Size.X - 30
        Dropdown_Data.Outline_Box.Position = V2_New(Layout_X, Layout_Y)
        Dropdown_Data.Outline_Box.Size = V2_New(Layout_Width, 22)
        Dropdown_Data.Inline_Box.Position = V2_New(Layout_X + 1, Layout_Y + 1)
        Dropdown_Data.Inline_Box.Size = V2_New(Layout_Width - 2, 20)
        Dropdown_Data.Label_Text.Text = String_Format("%s: %s", Dropdown_Data.Display_Name, Dropdown_Data.Option_Data[Configuration[Dropdown_Data.Config_Key]])
        Dropdown_Data.Label_Text.Position = V2_New(Layout_X + 8, Layout_Y + 5)
        Dropdown_Data.State_Icon.Position = V2_New(Layout_X + Layout_Width - 16, Layout_Y + 5)
        Dropdown_Data.List_Outline.Position = V2_New(Layout_X, Layout_Y + 21)
        Dropdown_Data.List_Outline.Size = V2_New(Layout_Width, Dropdown_Data.Current_Height)
        Dropdown_Data.List_Inline.Position = V2_New(Layout_X + 1, Layout_Y + 22)
        Dropdown_Data.List_Inline.Size = V2_New(Layout_Width - 2, Math_Max(0, Dropdown_Data.Current_Height - 2))
        for Option_Index, Option_Renderer in ipairs(Dropdown_Data.Item_Renderers) do
            local Option_Layout_Y = Layout_Y + 22 + ((Option_Index - 1) * 20)
            Option_Renderer.Base_Layout_Position = V2_New(Layout_X + 1, Option_Layout_Y)
            Option_Renderer.Layout_Dimensions = V2_New(Layout_Width - 2, 20)
            Option_Renderer.Background_Box.Position = Option_Renderer.Base_Layout_Position
            Option_Renderer.Background_Box.Size = Option_Renderer.Layout_Dimensions
            Option_Renderer.Active_Indicator.Position = V2_New(Layout_X + 1, Option_Layout_Y + 4)
            Option_Renderer.Active_Indicator.Size = V2_New(2, 12)
            Option_Renderer.Label_Text.Position = V2_New(Layout_X + 12, Option_Layout_Y + 4)
        end
    end

    for _, Slider_Data in ipairs(Interface_Manager.Sliders) do
        local Layout_X = Slider_Data.Parent_Group.Background_Box.Position.X + 15
        local Layout_Y = Slider_Data.Parent_Group.Background_Box.Position.Y + 15 + Slider_Data.Offset_Y
        local Layout_Width = Slider_Data.Parent_Group.Background_Box.Size.X - 30
        Slider_Data.Label_Text.Position = V2_New(Layout_X, Layout_Y - 15)
        Slider_Data.Value_Text.Position = V2_New(Layout_X + Layout_Width - Slider_Data.Value_Text.TextBounds.X, Layout_Y - 15)
        Slider_Data.Outline_Box.Position = V2_New(Layout_X, Layout_Y)
        Slider_Data.Outline_Box.Size = V2_New(Layout_Width, 8)
        Slider_Data.Background_Box.Position = V2_New(Layout_X + 1, Layout_Y + 1)
        Slider_Data.Background_Box.Size = V2_New(Layout_Width - 2, 6)
        local Current_Value = Configuration[Slider_Data.Config_Key]
        local Fill_Percentage = Math_Clamp((Current_Value - Slider_Data.Min_Bound) / (Slider_Data.Max_Bound - Slider_Data.Min_Bound), 0, 1)
        local Fill_Width = Math_Max((Layout_Width - 2) * Fill_Percentage, 2)
        Slider_Data.Fill_Indicator.Position = V2_New(Layout_X + 1, Layout_Y + 1)
        Slider_Data.Fill_Indicator.Size = V2_New(Fill_Width, 6)
        Slider_Data.Drag_Thumb.Position = V2_New(Layout_X + 1 + Fill_Width, Layout_Y + 4)
        local Display_Value = Math_Floor(Current_Value * (10 ^ Slider_Data.Precision)) / (10 ^ Slider_Data.Precision)
        if Slider_Data.Precision > 0 and Display_Value % 1 == 0 then Display_Value = Display_Value .. ".0" end
        if Slider_Data.Precision == 2 and tostring(Display_Value):len() == tostring(Math_Floor(Current_Value)):len() + 2 then Display_Value = Display_Value .. "0" end
        Slider_Data.Value_Text.Text = String_Format("%s%s", tostring(Display_Value), Slider_Data.Value_Suffix)
    end

    for _, Cp_Data in ipairs(Interface_Manager.Color_Pickers) do
        local Layout_X = Cp_Data.Parent_Group.Background_Box.Position.X + 15
        local Layout_Y = Cp_Data.Parent_Group.Background_Box.Position.Y + 20 + Cp_Data.Offset_Y
        local Sv_Size = 110
        local Grid_Res = 20

        Cp_Data.Sv_Outline.Position = V2_New(Layout_X, Layout_Y)
        Cp_Data.Sv_Outline.Size = V2_New(Sv_Size + 2, Sv_Size + 2)
        Cp_Data.Sv_Background.Position = V2_New(Layout_X + 1, Layout_Y + 1)
        Cp_Data.Sv_Background.Size = V2_New(Sv_Size, Sv_Size)
        Cp_Data.Sv_Background.Color = Convert_Hsv_To_Rgb(Cp_Data.Hue, 1, 1)

        for _, Block_Data in ipairs(Cp_Data.Sv_Blocks) do
            local Sq_Obj, Index_X, Index_Y, B_Size, C_Size = Block_Data[1], Block_Data[2], Block_Data[3], Block_Data[4], Block_Data[5]
            Sq_Obj.Position = V2_New(Layout_X + 1 + (Index_X * B_Size), Layout_Y + 1 + (Index_Y * B_Size))
            Sq_Obj.Size = V2_New(C_Size, C_Size)
            local Sat_Val = Index_X / (Grid_Res - 1)
            local Val_Val = 1 - (Index_Y / (Grid_Res - 1))
            Sq_Obj.Color = Convert_Hsv_To_Rgb(Cp_Data.Hue, Sat_Val, Val_Val)
        end

        Cp_Data.Sv_Cursor.Position = V2_New(Layout_X + 1 + (Cp_Data.Sat * Sv_Size), Layout_Y + 1 + ((1 - Cp_Data.Val) * Sv_Size))

        local Hue_X = Layout_X + Sv_Size + 15
        Cp_Data.Hue_Outline.Position = V2_New(Hue_X, Layout_Y)
        Cp_Data.Hue_Outline.Size = V2_New(14, Sv_Size + 2)

        local Block_Height = Sv_Size / 50
        local Ceil_Block_Height = math.ceil(Block_Height)

        for Index_I, Block_Obj in ipairs(Cp_Data.Hue_Blocks) do
            Block_Obj.Position = V2_New(Hue_X + 1, Layout_Y + 1 + ((Index_I - 1) * Block_Height))
            Block_Obj.Size = V2_New(12, Ceil_Block_Height)
            Block_Obj.Color = Convert_Hsv_To_Rgb(1 - ((Index_I - 1) / 49), 1, 1)
        end

        Cp_Data.Hue_Cursor.Position = V2_New(Hue_X - 1, Layout_Y + 1 + ((1 - Cp_Data.Hue) * Sv_Size) - 2)
        Cp_Data.Hue_Cursor.Size = V2_New(16, 4)

        local Alpha_X = Hue_X + 25
        Cp_Data.Alpha_Outline.Position = V2_New(Alpha_X, Layout_Y)
        Cp_Data.Alpha_Outline.Size = V2_New(14, Sv_Size + 2)

        local Current_Color = Convert_Hsv_To_Rgb(Cp_Data.Hue, Cp_Data.Sat, Cp_Data.Val)
        local Bg_Col = Interface_Manager.Palette.Group_Background
        for Index_I, Block_Obj in ipairs(Cp_Data.Alpha_Blocks) do
            Block_Obj.Position = V2_New(Alpha_X + 1, Layout_Y + 1 + ((Index_I - 1) * Block_Height))
            Block_Obj.Size = V2_New(12, Ceil_Block_Height)
            local Alpha_Ratio = 1 - ((Index_I - 1) / 49)
            local Blended_Color = C3_New(
                Bg_Col.R + (Current_Color.R - Bg_Col.R) * Alpha_Ratio,
                Bg_Col.G + (Current_Color.G - Bg_Col.G) * Alpha_Ratio,
                Bg_Col.B + (Current_Color.B - Bg_Col.B) * Alpha_Ratio
            )
            Block_Obj.Color = Blended_Color
        end

        Cp_Data.Alpha_Cursor.Position = V2_New(Alpha_X - 1, Layout_Y + 1 + ((1 - Cp_Data.Alpha) * Sv_Size) - 2)
        Cp_Data.Alpha_Cursor.Size = V2_New(16, 4)

        local Text_Y = Layout_Y + Sv_Size + 10
        local R_Col, G_Col, B_Col = Math_Floor(Current_Color.R * 255), Math_Floor(Current_Color.G * 255), Math_Floor(Current_Color.B * 255)
        local A_Col = Math_Floor(Cp_Data.Alpha * 255)
        Cp_Data.Details_Text1.Text = String_Format("R: %d | G: %d | B: %d | A: %d", R_Col, G_Col, B_Col, A_Col)
        Cp_Data.Details_Text1.Position = V2_New(Layout_X, Text_Y)

        local H_Col, S_Col, V_Col = Math_Floor(Cp_Data.Hue * 360), Math_Floor(Cp_Data.Sat * 100), Math_Floor(Cp_Data.Val * 100)
        Cp_Data.Details_Text2.Text = String_Format("H: %d | S: %d | V: %d", H_Col, S_Col, V_Col)
        Cp_Data.Details_Text2.Position = V2_New(Layout_X, Text_Y + 22)

        Cp_Data.Hex_Text.Text = String_Format("Hex: #%02X%02X%02X", R_Col, G_Col, B_Col)
        Cp_Data.Hex_Text.Position = V2_New(Layout_X, Text_Y + 44)
    end

    for _, Bind_Data in ipairs(Interface_Manager.Binds) do
        local Layout_X = Bind_Data.Parent_Group.Background_Box.Position.X + 15
        local Layout_Y = Bind_Data.Parent_Group.Background_Box.Position.Y + 20 + Bind_Data.Offset_Y
        local Layout_Width = Bind_Data.Parent_Group.Background_Box.Size.X - 30
        if Bind_Data.Is_Full_Width then
            Bind_Data.Outline_Box.Position = V2_New(Layout_X, Layout_Y)
            Bind_Data.Outline_Box.Size = V2_New(Layout_Width, 22)
            Bind_Data.Inline_Box.Position = V2_New(Layout_X + 1, Layout_Y + 1)
            Bind_Data.Inline_Box.Size = V2_New(Layout_Width - 2, 20)
            Bind_Data.Label_Text.Position = V2_New(Layout_X + (Layout_Width / 2), Layout_Y + 12)
        else
            Bind_Data.Outline_Box.Position = V2_New(Layout_X + Layout_Width - 45, Layout_Y - 2)
            Bind_Data.Outline_Box.Size = V2_New(45, 16)
            Bind_Data.Inline_Box.Position = V2_New(Layout_X + Layout_Width - 44, Layout_Y - 1)
            Bind_Data.Inline_Box.Size = V2_New(43, 14)
            Bind_Data.Label_Text.Position = V2_New(Layout_X + Layout_Width - 22.5, Layout_Y + 5)
        end
    end

    for _, Btn_Data in ipairs(Interface_Manager.Buttons) do
        local Layout_X = Btn_Data.Parent_Group.Background_Box.Position.X + 15
        local Layout_Y = Btn_Data.Parent_Group.Background_Box.Position.Y + 20 + Btn_Data.Offset_Y
        local Layout_Width = Btn_Data.Parent_Group.Background_Box.Size.X - 30
        Btn_Data.Outline_Box.Position = V2_New(Layout_X, Layout_Y)
        Btn_Data.Outline_Box.Size = V2_New(Layout_Width, 22)
        Btn_Data.Inline_Box.Position = V2_New(Layout_X + 1, Layout_Y + 1)
        Btn_Data.Inline_Box.Size = V2_New(Layout_Width - 2, 20)
        Btn_Data.Label_Text.Position = V2_New(Layout_X + (Layout_Width / 2), Layout_Y + 11)
    end

    local Indicator_Pos = Interface_Manager.Indicator_Position
    Interface_Manager.Overlay_Indicator.Outline_Box.Position = Indicator_Pos - V2_New(1, 1)
    Interface_Manager.Overlay_Indicator.Outline_Box.Size = V2_New(182, 105)
    Interface_Manager.Overlay_Indicator.Inline_Box.Position = Indicator_Pos
    Interface_Manager.Overlay_Indicator.Inline_Box.Size = V2_New(180, 103)
    Interface_Manager.Overlay_Indicator.Background_Box.Position = Indicator_Pos + V2_New(1, 1)
    Interface_Manager.Overlay_Indicator.Background_Box.Size = V2_New(178, 101)
    Interface_Manager.Overlay_Indicator.Accent_Line.Position = Indicator_Pos + V2_New(1, 1)
    Interface_Manager.Overlay_Indicator.Accent_Line.Size = V2_New(178, 2)
    Interface_Manager.Overlay_Indicator.Title_Text.Position = Indicator_Pos + V2_New(10, 6)

    for Row_Index, Row_Renderer in ipairs(Interface_Manager.Overlay_Indicator.Render_Rows) do
        Row_Renderer.Name_Text.Position = Indicator_Pos + V2_New(10, 10 + (Row_Index * 18))
        Row_Renderer.State_Text.Position = Indicator_Pos + V2_New(140, 10 + (Row_Index * 18))
    end

    local Stats_Pos = Interface_Manager.Stats_Panel_Position
    Interface_Manager.Stats_Panel.Outline_Box.Position = Stats_Pos - V2_New(1, 1)
    Interface_Manager.Stats_Panel.Outline_Box.Size = V2_New(242, 92)
    Interface_Manager.Stats_Panel.Inline_Box.Position = Stats_Pos
    Interface_Manager.Stats_Panel.Inline_Box.Size = V2_New(240, 90)
    Interface_Manager.Stats_Panel.Background_Box.Position = Stats_Pos + V2_New(1, 1)
    Interface_Manager.Stats_Panel.Background_Box.Size = V2_New(238, 88)
    Interface_Manager.Stats_Panel.Accent_Line.Position = Stats_Pos + V2_New(1, 1)
    Interface_Manager.Stats_Panel.Accent_Line.Size = V2_New(238, 2)
    Interface_Manager.Stats_Panel.Title_Text.Position = Stats_Pos + V2_New(10, 8)

    for Row_Index, Row_Renderer in ipairs(Interface_Manager.Stats_Panel.Render_Rows) do
        local Layout_Y = 28 + ((Row_Index - 1) * 20)
        Row_Renderer.Label_Text.Position = Stats_Pos + V2_New(10, Layout_Y)
        Row_Renderer.Value_Text.Position = Stats_Pos + V2_New(190, Layout_Y)
        Row_Renderer.Divider_Line.Position = Stats_Pos + V2_New(10, Layout_Y + 16)
        Row_Renderer.Divider_Line.Size = V2_New(218, 1)
    end

    local Ms_Pos = Interface_Manager.Manual_Spam_Panel_Position
    Interface_Manager.Manual_Spam_Panel.Outline_Box.Position = Ms_Pos - V2_New(1, 1)
    Interface_Manager.Manual_Spam_Panel.Outline_Box.Size = V2_New(142, 62)
    Interface_Manager.Manual_Spam_Panel.Inline_Box.Position = Ms_Pos
    Interface_Manager.Manual_Spam_Panel.Inline_Box.Size = V2_New(140, 60)
    Interface_Manager.Manual_Spam_Panel.Background_Box.Position = Ms_Pos + V2_New(1, 1)
    Interface_Manager.Manual_Spam_Panel.Background_Box.Size = V2_New(138, 58)
    Interface_Manager.Manual_Spam_Panel.Accent_Line.Position = Ms_Pos + V2_New(1, 1)
    Interface_Manager.Manual_Spam_Panel.Accent_Line.Size = V2_New(138, 2)
    Interface_Manager.Manual_Spam_Panel.Title_Text.Position = Ms_Pos + V2_New(10, 6)
    Interface_Manager.Manual_Spam_Panel.State_Text.Position = Ms_Pos + V2_New(70, 30)
end

local function Change_Active_Tab(Tab_Identifier)
    Interface_Manager.Current_Tab = Tab_Identifier
    if Interface_Manager.Active_Dropdown_Element then
        Interface_Manager.Active_Dropdown_Element.Is_Open = false
        Interface_Manager.Active_Dropdown_Element = nil
    end
    for Renderer_Name, Renderer_Data in pairs(Interface_Manager.Tab_Renderers) do
        Renderer_Data.Text_Obj.Color = (Renderer_Name == Tab_Identifier) and Interface_Manager.Palette.Primary_Text or Interface_Manager.Palette.Secondary_Text
        Renderer_Data.Indicator.Visible = (Renderer_Name == Tab_Identifier) and Interface_Manager.Is_Visible
    end
    for _, Group_Data in ipairs(Interface_Manager.Group_Container_List) do
        local Is_Visible = (Group_Data.Parent_Tab == Tab_Identifier) and Interface_Manager.Is_Visible
        Group_Data.Outline_Box.Visible = Is_Visible
        Group_Data.Background_Box.Visible = Is_Visible
        Group_Data.Title_Background.Visible = Is_Visible
        Group_Data.Title_Text.Visible = Is_Visible
    end
    for _, Toggle_Data in ipairs(Interface_Manager.Toggles) do
        local Is_Visible = (Toggle_Data.Parent_Group.Parent_Tab == Tab_Identifier) and Interface_Manager.Is_Visible
        Toggle_Data.Outline_Box.Visible = Is_Visible
        Toggle_Data.Inline_Box.Visible = Is_Visible
        Toggle_Data.Fill_Box.Visible = Is_Visible
        Toggle_Data.Label_Text.Visible = Is_Visible
        if Toggle_Data.Keybind_Data then
            Toggle_Data.Keybind_Data.Outline_Box.Visible = Is_Visible
            Toggle_Data.Keybind_Data.Inline_Box.Visible = Is_Visible
            Toggle_Data.Keybind_Data.Label_Text.Visible = Is_Visible
        end
    end
    for _, Dropdown_Data in ipairs(Interface_Manager.Dropdowns) do
        local Is_Visible = (Dropdown_Data.Parent_Group.Parent_Tab == Tab_Identifier) and Interface_Manager.Is_Visible
        Dropdown_Data.Outline_Box.Visible = Is_Visible
        Dropdown_Data.Inline_Box.Visible = Is_Visible
        Dropdown_Data.Label_Text.Visible = Is_Visible
        Dropdown_Data.State_Icon.Visible = Is_Visible
        if not Is_Visible then
            Dropdown_Data.Current_Height = 0
            Dropdown_Data.List_Outline.Visible = false
            Dropdown_Data.List_Inline.Visible = false
            for _, Option_Renderer in ipairs(Dropdown_Data.Item_Renderers) do
                Option_Renderer.Background_Box.Visible = false
                Option_Renderer.Label_Text.Visible = false
                Option_Renderer.Active_Indicator.Visible = false
            end
        end
    end
    for _, Slider_Data in ipairs(Interface_Manager.Sliders) do
        local Is_Visible = (Slider_Data.Parent_Group.Parent_Tab == Tab_Identifier) and Interface_Manager.Is_Visible
        Slider_Data.Outline_Box.Visible = Is_Visible
        Slider_Data.Background_Box.Visible = Is_Visible
        Slider_Data.Fill_Indicator.Visible = Is_Visible
        Slider_Data.Label_Text.Visible = Is_Visible
        Slider_Data.Value_Text.Visible = Is_Visible
        Slider_Data.Drag_Thumb.Visible = Is_Visible
    end
    for _, Bind_Data in ipairs(Interface_Manager.Binds) do
        if Bind_Data.Is_Full_Width then
            local Is_Visible = (Bind_Data.Parent_Group.Parent_Tab == Tab_Identifier) and Interface_Manager.Is_Visible
            Bind_Data.Outline_Box.Visible = Is_Visible
            Bind_Data.Inline_Box.Visible = Is_Visible
            Bind_Data.Label_Text.Visible = Is_Visible
        end
    end
    for _, Cp_Data in ipairs(Interface_Manager.Color_Pickers) do
        local Is_Visible = (Cp_Data.Parent_Group.Parent_Tab == Tab_Identifier) and Interface_Manager.Is_Visible
        Cp_Data.Sv_Outline.Visible = Is_Visible
        Cp_Data.Sv_Background.Visible = Is_Visible
        Cp_Data.Sv_Cursor.Visible = Is_Visible
        Cp_Data.Hue_Outline.Visible = Is_Visible
        Cp_Data.Hue_Cursor.Visible = Is_Visible
        Cp_Data.Alpha_Outline.Visible = Is_Visible
        Cp_Data.Alpha_Cursor.Visible = Is_Visible
        Cp_Data.Details_Text1.Visible = Is_Visible
        Cp_Data.Details_Text2.Visible = Is_Visible
        Cp_Data.Hex_Text.Visible = Is_Visible
        for _, Sq_Obj in ipairs(Cp_Data.Sv_Blocks) do Sq_Obj[1].Visible = Is_Visible end
        for _, Block_Obj in ipairs(Cp_Data.Hue_Blocks) do Block_Obj.Visible = Is_Visible end
        for _, Block_Obj in ipairs(Cp_Data.Alpha_Blocks) do Block_Obj.Visible = Is_Visible end
    end
    for _, Btn_Data in ipairs(Interface_Manager.Buttons) do
        local Is_Visible = (Btn_Data.Parent_Group.Parent_Tab == Tab_Identifier) and Interface_Manager.Is_Visible
        Btn_Data.Outline_Box.Visible = Is_Visible
        Btn_Data.Inline_Box.Visible = Is_Visible
        Btn_Data.Label_Text.Visible = Is_Visible
    end
    Refresh_Layout_Coordinates()
end

local function Set_Interface_Visibility(Visibility_State)
    Interface_Manager.Is_Visible = Visibility_State
    Interface_Manager.Main_Outline.Visible = Visibility_State
    Interface_Manager.Main_Background.Visible = Visibility_State
    Interface_Manager.Sidebar_Area.Visible = Visibility_State
    Interface_Manager.Sidebar_Divider.Visible = Visibility_State
    Interface_Manager.Top_Accent_Line.Visible = Visibility_State
    Interface_Manager.Title_Text.Visible = Visibility_State
    if Interface_Manager.Resize_Corners then
        for _, Corner_Renderers in pairs(Interface_Manager.Resize_Corners) do
            Corner_Renderers.Horizontal.Visible = Visibility_State
            Corner_Renderers.Vertical.Visible = Visibility_State
        end
    end
    if not Visibility_State and Interface_Manager.Active_Dropdown_Element then
        Interface_Manager.Active_Dropdown_Element.Is_Open = false
        Interface_Manager.Active_Dropdown_Element = nil
    end
    for Renderer_Name, Renderer_Data in pairs(Interface_Manager.Tab_Renderers) do
        Renderer_Data.Text_Obj.Visible = Visibility_State
        Renderer_Data.Indicator.Visible = (Renderer_Name == Interface_Manager.Current_Tab) and Visibility_State
    end
    Change_Active_Tab(Interface_Manager.Current_Tab)
end

Construct_User_Interface()
Apply_Theme(Configuration.Theme_Preset)
Refresh_Layout_Coordinates()
Set_Interface_Visibility(true)

Task_Spawn(function()
    local Was_Mouse_Pressed = false
    while _G.Nightfall_Active do
        Task_Wait()

        local Is_Mouse_Pressed = ismouse1pressed()

        local Mouse_Position = V2_New(Player_Mouse.X, Player_Mouse.Y)
        local function Is_Location_In_Bounds(Position_Vector, Dimensions_Vector)
            return Mouse_Position.X >= Position_Vector.X and Mouse_Position.X <= Position_Vector.X + Dimensions_Vector.X and Mouse_Position.Y >= Position_Vector.Y and Mouse_Position.Y <= Position_Vector.Y + Dimensions_Vector.Y
        end

        local Should_Render_Keybinds = Configuration.Render_Keybinds
        Interface_Manager.Overlay_Indicator.Outline_Box.Visible = Should_Render_Keybinds
        Interface_Manager.Overlay_Indicator.Inline_Box.Visible = Should_Render_Keybinds
        Interface_Manager.Overlay_Indicator.Background_Box.Visible = Should_Render_Keybinds
        Interface_Manager.Overlay_Indicator.Accent_Line.Visible = Should_Render_Keybinds
        Interface_Manager.Overlay_Indicator.Title_Text.Visible = Should_Render_Keybinds
        for _, Row_Renderer in ipairs(Interface_Manager.Overlay_Indicator.Render_Rows) do
            Row_Renderer.Name_Text.Visible = Should_Render_Keybinds
            Row_Renderer.State_Text.Visible = Should_Render_Keybinds
        end

        if Should_Render_Keybinds then
            Interface_Manager.Overlay_Indicator.Render_Rows[1].Name_Text.Text = String_Format("[%s] Parry", Format_Keycode_Name(Configuration.Parry_Keybind))
            Interface_Manager.Overlay_Indicator.Render_Rows[1].State_Text.Text = Configuration.Auto_Parry and "[ON]" or "[OFF]"
            Interface_Manager.Overlay_Indicator.Render_Rows[1].State_Text.Color = Configuration.Auto_Parry and Interface_Manager.Palette.Accent_Color or Interface_Manager.Palette.Secondary_Text

            Interface_Manager.Overlay_Indicator.Render_Rows[2].Name_Text.Text = String_Format("[%s] Spam", Format_Keycode_Name(Configuration.Spam_Keybind))
            Interface_Manager.Overlay_Indicator.Render_Rows[2].State_Text.Text = Configuration.Auto_Spam and "[ON]" or "[OFF]"
            Interface_Manager.Overlay_Indicator.Render_Rows[2].State_Text.Color = Configuration.Auto_Spam and Interface_Manager.Palette.Accent_Color or Interface_Manager.Palette.Secondary_Text

            Interface_Manager.Overlay_Indicator.Render_Rows[3].Name_Text.Text = String_Format("[%s] Trig", Format_Keycode_Name(Configuration.Triggerbot_Keybind))
            Interface_Manager.Overlay_Indicator.Render_Rows[3].State_Text.Text = Configuration.Triggerbot_Enabled and "[ON]" or "[OFF]"
            Interface_Manager.Overlay_Indicator.Render_Rows[3].State_Text.Color = Configuration.Triggerbot_Enabled and Interface_Manager.Palette.Accent_Color or Interface_Manager.Palette.Secondary_Text

            Interface_Manager.Overlay_Indicator.Render_Rows[4].Name_Text.Text = String_Format("[%s] Curve", Format_Keycode_Name(Configuration.Auto_Curve_Keybind))
            Interface_Manager.Overlay_Indicator.Render_Rows[4].State_Text.Text = Configuration.Auto_Curve and "[ON]" or "[OFF]"
            Interface_Manager.Overlay_Indicator.Render_Rows[4].State_Text.Color = Configuration.Auto_Curve and Interface_Manager.Palette.Accent_Color or Interface_Manager.Palette.Secondary_Text
        end

        local Should_Render_Stats = Configuration.Render_Ball_Stats and Player_State.Is_Alive
        Interface_Manager.Stats_Panel.Outline_Box.Visible = Should_Render_Stats
        Interface_Manager.Stats_Panel.Inline_Box.Visible = Should_Render_Stats
        Interface_Manager.Stats_Panel.Background_Box.Visible = Should_Render_Stats
        Interface_Manager.Stats_Panel.Accent_Line.Visible = Should_Render_Stats
        Interface_Manager.Stats_Panel.Title_Text.Visible = Should_Render_Stats

        for Index_Val, Row_Renderer in ipairs(Interface_Manager.Stats_Panel.Render_Rows) do
            Row_Renderer.Label_Text.Visible = Should_Render_Stats
            Row_Renderer.Value_Text.Visible = Should_Render_Stats
            Row_Renderer.Divider_Line.Visible = (Should_Render_Stats and Index_Val < 3)
        end

        if Should_Render_Stats then
            Interface_Manager.Stats_Panel.Render_Rows[1].Value_Text.Text = tostring(Math_Floor(Player_State.Tracked_Speed or 0))
            Interface_Manager.Stats_Panel.Render_Rows[2].Value_Text.Text = tostring(Math_Floor(Player_State.Tracked_Distance or 0))
            Interface_Manager.Stats_Panel.Render_Rows[3].Value_Text.Text = String_Format("%.2f", Player_State.Tracked_Dot_Product or 0)
        end

        local Should_Render_Manual_Spam = Configuration.Manual_Spam_Ui
        if not Should_Render_Manual_Spam or not Player_State.Is_Alive then
            Player_State.Manual_Spam_Active = false
        end

        Interface_Manager.Manual_Spam_Panel.Outline_Box.Visible = Should_Render_Manual_Spam
        Interface_Manager.Manual_Spam_Panel.Inline_Box.Visible = Should_Render_Manual_Spam
        Interface_Manager.Manual_Spam_Panel.Background_Box.Visible = Should_Render_Manual_Spam
        Interface_Manager.Manual_Spam_Panel.Accent_Line.Visible = Should_Render_Manual_Spam
        Interface_Manager.Manual_Spam_Panel.Title_Text.Visible = Should_Render_Manual_Spam
        Interface_Manager.Manual_Spam_Panel.State_Text.Visible = Should_Render_Manual_Spam

        if Should_Render_Manual_Spam then
            Interface_Manager.Manual_Spam_Panel.State_Text.Text = Player_State.Manual_Spam_Active and "ON" or "OFF"
            Interface_Manager.Manual_Spam_Panel.State_Text.Color = Player_State.Manual_Spam_Active and Interface_Manager.Palette.Accent_Color or Interface_Manager.Palette.Secondary_Text
        end

        local Is_Hover_Obstructed = false
        if Interface_Manager.Active_Dropdown_Element and Interface_Manager.Active_Dropdown_Element.Current_Height > 10 then
            if Is_Location_In_Bounds(Interface_Manager.Active_Dropdown_Element.List_Outline.Position, Interface_Manager.Active_Dropdown_Element.List_Outline.Size) then Is_Hover_Obstructed = true end
        end

        if Interface_Manager.Is_Visible then
            local Resize_Boundaries = {
                TL = {Position_Vec = Interface_Manager.Base_Position, Dimensions_Vec = V2_New(15, 15)},
                TR = {Position_Vec = Interface_Manager.Base_Position + V2_New(Interface_Manager.Dimensions.X - 15, 0), Dimensions_Vec = V2_New(15, 15)},
                BL = {Position_Vec = Interface_Manager.Base_Position + V2_New(0, Interface_Manager.Dimensions.Y - 15), Dimensions_Vec = V2_New(15, 15)},
                BR = {Position_Vec = Interface_Manager.Base_Position + V2_New(Interface_Manager.Dimensions.X - 15, Interface_Manager.Dimensions.Y - 15), Dimensions_Vec = V2_New(15, 15)}
            }
            for Direction_Id, Corner_Renderers in pairs(Interface_Manager.Resize_Corners) do
                local Boundary_Data = Resize_Boundaries[Direction_Id]
                if Is_Location_In_Bounds(Boundary_Data.Position_Vec - V2_New(4, 4), Boundary_Data.Dimensions_Vec + V2_New(8, 8)) then
                    Corner_Renderers.Horizontal.Transparency = 1
                    Corner_Renderers.Vertical.Transparency = 1
                else
                    Corner_Renderers.Horizontal.Transparency = 0.3
                    Corner_Renderers.Vertical.Transparency = 0.3
                end
            end

            for _, Toggle_Data in ipairs(Interface_Manager.Toggles) do
                if Toggle_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab then
                    local Is_Hovered = not Is_Hover_Obstructed and Is_Location_In_Bounds(Toggle_Data.Outline_Box.Position, V2_New(Toggle_Data.Label_Text.TextBounds.X + 25, 12))
                    local Is_Enabled = Configuration[Toggle_Data.Config_Key]
                    local Interpolation_Target_Inline = Is_Enabled and Interface_Manager.Palette.Accent_Color or (Is_Hovered and Interface_Manager.Palette.Secondary_Text or Interface_Manager.Palette.Toggle_Background)
                    local Interpolation_Target_Fill = Is_Enabled and Interface_Manager.Palette.Accent_Color or Interface_Manager.Palette.Toggle_Background

                    Toggle_Data.Target_Inline_Color = Interpolate_Color(Toggle_Data.Target_Inline_Color, Interpolation_Target_Inline, 0.15)
                    Toggle_Data.Target_Fill_Color = Interpolate_Color(Toggle_Data.Target_Fill_Color, Interpolation_Target_Fill, 0.15)
                    Toggle_Data.Inline_Box.Color = Toggle_Data.Target_Inline_Color
                    Toggle_Data.Fill_Box.Color = Toggle_Data.Target_Fill_Color
                end
            end

            for _, Dropdown_Data in ipairs(Interface_Manager.Dropdowns) do
                if Dropdown_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab then
                    local Is_Base_Hovered = not Is_Hover_Obstructed and Is_Location_In_Bounds(Dropdown_Data.Outline_Box.Position, Dropdown_Data.Outline_Box.Size)
                    local Is_State_Active = Dropdown_Data.Is_Open or Is_Base_Hovered
                    Dropdown_Data.Target_Inline_Color = Interpolate_Color(Dropdown_Data.Target_Inline_Color, Is_State_Active and Interface_Manager.Palette.Hover_State or Interface_Manager.Palette.Toggle_Background, 0.15)
                    Dropdown_Data.Inline_Box.Color = Dropdown_Data.Target_Inline_Color
                    Dropdown_Data.State_Icon.Text = Dropdown_Data.Is_Open and "-" or "+"
                    local Target_Height_Dimension = Dropdown_Data.Is_Open and Dropdown_Data.Maximum_Height or 0
                    Dropdown_Data.Current_Height = Interpolate_Value(Dropdown_Data.Current_Height, Target_Height_Dimension, 0.2)
                    local Is_List_Visible = Dropdown_Data.Current_Height > 2
                    Dropdown_Data.List_Outline.Visible = Is_List_Visible
                    Dropdown_Data.List_Inline.Visible = Is_List_Visible

                    if Is_List_Visible then
                        local Layout_Base_Transparency = Interpolate_Value(Dropdown_Data.List_Outline.Transparency, Dropdown_Data.Is_Open and 0.95 or 0, 0.15)
                        Dropdown_Data.List_Outline.Transparency = Math_Clamp(Layout_Base_Transparency - 0.4, 0, 1)
                        Dropdown_Data.List_Inline.Transparency = Layout_Base_Transparency
                        for Render_Index, Option_Renderer in ipairs(Dropdown_Data.Item_Renderers) do
                            Option_Renderer.Background_Box.Visible = true
                            Option_Renderer.Label_Text.Visible = true
                            Option_Renderer.Active_Indicator.Visible = true
                            local Is_Option_Hovered = Dropdown_Data.Is_Open and Is_Location_In_Bounds(Option_Renderer.Base_Layout_Position, Option_Renderer.Layout_Dimensions)
                            local Is_Option_Selected = Configuration[Dropdown_Data.Config_Key] == Render_Index
                            local Interpolation_Target_Background = Is_Option_Hovered and Interface_Manager.Palette.Hover_State or Interface_Manager.Palette.Group_Background
                            Option_Renderer.Target_Background_Color = Interpolate_Color(Option_Renderer.Target_Background_Color, Interpolation_Target_Background, 0.2)
                            Option_Renderer.Background_Box.Color = Option_Renderer.Target_Background_Color
                            local Element_Item_Transparency = Interpolate_Value(Option_Renderer.Label_Text.Transparency, Dropdown_Data.Is_Open and 1 or 0, 0.15)
                            Option_Renderer.Background_Box.Transparency = Layout_Base_Transparency
                            Option_Renderer.Label_Text.Transparency = Element_Item_Transparency
                            Option_Renderer.Active_Indicator.Transparency = Is_Option_Selected and Element_Item_Transparency or 0
                        end
                    else
                        for _, Option_Renderer in ipairs(Dropdown_Data.Item_Renderers) do
                            Option_Renderer.Background_Box.Visible = false
                            Option_Renderer.Label_Text.Visible = false
                            Option_Renderer.Active_Indicator.Visible = false
                        end
                    end
                else
                    Dropdown_Data.List_Outline.Visible = false
                    Dropdown_Data.List_Inline.Visible = false
                    for _, Option_Renderer in ipairs(Dropdown_Data.Item_Renderers) do
                        Option_Renderer.Background_Box.Visible = false
                        Option_Renderer.Label_Text.Visible = false
                        Option_Renderer.Active_Indicator.Visible = false
                    end
                end
            end

            for _, Bind_Data in ipairs(Interface_Manager.Binds) do
                if Bind_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab then
                    local Is_Bind_Hovered = not Is_Hover_Obstructed and Is_Location_In_Bounds(Bind_Data.Outline_Box.Position, Bind_Data.Outline_Box.Size)
                    local Target_Inline_Color = Is_Bind_Hovered and Interface_Manager.Palette.Hover_State or Interface_Manager.Palette.Toggle_Background
                    Bind_Data.Target_Inline_Color = Interpolate_Color(Bind_Data.Target_Inline_Color, Target_Inline_Color, 0.15)
                    Bind_Data.Inline_Box.Color = Bind_Data.Target_Inline_Color
                    if Bind_Data.Is_Full_Width then
                        Bind_Data.Label_Text.Text = Interface_Manager.Active_Keybind_Listener == Bind_Data.Action_Key and String_Format("%s [ ... ]", Bind_Data.Display_Name) or String_Format("%s [ %s ]", Bind_Data.Display_Name, Format_Keycode_Name(Configuration[Bind_Data.Config_Key]))
                    else
                        Bind_Data.Label_Text.Text = Interface_Manager.Active_Keybind_Listener == Bind_Data.Action_Key and "[..]" or String_Format("[%s]", Format_Keycode_Name(Configuration[Bind_Data.Config_Key]))
                    end
                end
            end

            for _, Btn_Data in ipairs(Interface_Manager.Buttons) do
                if Btn_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab then
                    local Is_Bind_Hovered = not Is_Hover_Obstructed and Is_Location_In_Bounds(Btn_Data.Outline_Box.Position, Btn_Data.Outline_Box.Size)
                    local Target_Inline_Color = Is_Bind_Hovered and Interface_Manager.Palette.Hover_State or Interface_Manager.Palette.Toggle_Background
                    Btn_Data.Target_Inline_Color = Interpolate_Color(Btn_Data.Target_Inline_Color, Target_Inline_Color, 0.15)
                    Btn_Data.Inline_Box.Color = Btn_Data.Target_Inline_Color
                end
            end
        end

        if Interface_Manager.Active_Keybind_Listener then
            Safe_Call(function()
                for Current_Key_Code = 1, 255 do
                    if iskeypressed(Current_Key_Code) and not Is_Mouse_Pressed and Current_Key_Code ~= 1 and Current_Key_Code ~= 2 then
                        if Current_Key_Code == 27 then
                            Configuration[Interface_Manager.Active_Keybind_Listener] = 0
                        else
                            Configuration[Interface_Manager.Active_Keybind_Listener] = Current_Key_Code
                        end
                        Interface_Manager.Hide_Key_Held = true
                        Interface_Manager.Active_Keybind_Listener = nil
                        Refresh_Layout_Coordinates()
                        break
                    end
                end
            end)
        else
            Safe_Call(function()
                if type(Configuration.Hide_Keybind) == "number" and Configuration.Hide_Keybind > 0 and iskeypressed(Configuration.Hide_Keybind) then
                    if not Interface_Manager.Hide_Key_Held then
                        Set_Interface_Visibility(not Interface_Manager.Is_Visible)
                        Interface_Manager.Hide_Key_Held = true
                    end
                else
                    Interface_Manager.Hide_Key_Held = false
                end

                if type(Configuration.Manual_Spam_Keybind) == "number" and Configuration.Manual_Spam_Keybind > 0 and iskeypressed(Configuration.Manual_Spam_Keybind) then
                    if not Interface_Manager.Manual_Spam_Keybind_Held then
                        Player_State.Manual_Spam_Active = not Player_State.Manual_Spam_Active
                        Interface_Manager.Manual_Spam_Keybind_Held = true
                    end
                else
                    Interface_Manager.Manual_Spam_Keybind_Held = false
                end
            end)

            local function Process_Keybind_Action(Keycode_Value, Config_Reference)
                Safe_Call(function()
                    if type(Keycode_Value) == "number" and Keycode_Value > 0 and iskeypressed(Keycode_Value) then
                        if not Interface_Manager[Config_Reference.."_Held"] then
                            Configuration[Config_Reference] = not Configuration[Config_Reference]
                            Interface_Manager[Config_Reference.."_Held"] = true
                        end
                    else
                        Interface_Manager[Config_Reference.."_Held"] = false
                    end
                end)
            end

            Process_Keybind_Action(Configuration.Parry_Keybind, "Auto_Parry")
            Process_Keybind_Action(Configuration.Spam_Keybind, "Auto_Spam")
            Process_Keybind_Action(Configuration.Triggerbot_Keybind, "Triggerbot_Enabled")
            Process_Keybind_Action(Configuration.Auto_Curve_Keybind, "Auto_Curve")
        end

        if Is_Mouse_Pressed and not Was_Mouse_Pressed then
            if Configuration.Render_Keybinds and Is_Location_In_Bounds(Interface_Manager.Overlay_Indicator.Outline_Box.Position, V2_New(Interface_Manager.Overlay_Indicator.Outline_Box.Size.X, 25)) then
                Interface_Manager.Is_Dragging_Indicator = true
                Interface_Manager.Indicator_Drag_Start = Mouse_Position
                Interface_Manager.Initial_Indicator_Position = Interface_Manager.Indicator_Position
            end

            if Configuration.Render_Ball_Stats and Is_Location_In_Bounds(Interface_Manager.Stats_Panel.Outline_Box.Position, V2_New(Interface_Manager.Stats_Panel.Outline_Box.Size.X, 25)) then
                Interface_Manager.Is_Dragging_Stats = true
                Interface_Manager.Stats_Drag_Start = Mouse_Position
                Interface_Manager.Initial_Stats_Position = Interface_Manager.Stats_Panel_Position
            end

            if Configuration.Manual_Spam_Ui and Is_Location_In_Bounds(Interface_Manager.Manual_Spam_Panel.Outline_Box.Position, Interface_Manager.Manual_Spam_Panel.Outline_Box.Size) then
                if Mouse_Position.Y <= Interface_Manager.Manual_Spam_Panel.Outline_Box.Position.Y + 25 then
                    Interface_Manager.Is_Dragging_Manual_Spam = true
                    Interface_Manager.Manual_Spam_Drag_Start = Mouse_Position
                    Interface_Manager.Initial_Manual_Spam_Position = Interface_Manager.Manual_Spam_Panel_Position
                else
                    if Player_State.Is_Alive then
                        Player_State.Manual_Spam_Active = not Player_State.Manual_Spam_Active
                    end
                end
            end

            if Interface_Manager.Is_Visible then
                local Is_Corner_Clicked = false
                local Resize_Boundaries = {
                    TL = {Position_Vec = Interface_Manager.Base_Position, Dimensions_Vec = V2_New(15, 15)},
                    TR = {Position_Vec = Interface_Manager.Base_Position + V2_New(Interface_Manager.Dimensions.X - 15, 0), Dimensions_Vec = V2_New(15, 15)},
                    BL = {Position_Vec = Interface_Manager.Base_Position + V2_New(0, Interface_Manager.Dimensions.Y - 15), Dimensions_Vec = V2_New(15, 15)},
                    BR = {Position_Vec = Interface_Manager.Base_Position + V2_New(Interface_Manager.Dimensions.X - 15, Interface_Manager.Dimensions.Y - 15), Dimensions_Vec = V2_New(15, 15)}
                }
                for Direction_Id, Corner_Data in pairs(Interface_Manager.Resize_Corners) do
                    local Boundary_Data = Resize_Boundaries[Direction_Id]
                    if Is_Location_In_Bounds(Boundary_Data.Position_Vec - V2_New(4, 4), Boundary_Data.Dimensions_Vec + V2_New(8, 8)) then
                        Interface_Manager.Is_Resizing = true
                        Interface_Manager.Resize_Direction = Direction_Id
                        Interface_Manager.Resize_Start_Location = Mouse_Position
                        Interface_Manager.Initial_Window_Size = Interface_Manager.Dimensions
                        Interface_Manager.Initial_Window_Position = Interface_Manager.Base_Position
                        Is_Corner_Clicked = true
                        break
                    end
                end
                if not Is_Corner_Clicked and Is_Location_In_Bounds(Interface_Manager.Main_Outline.Position, V2_New(Interface_Manager.Main_Outline.Size.X, 30)) then
                    Interface_Manager.Is_Dragging = true
                    Interface_Manager.Drag_Start_Location = Mouse_Position
                    Interface_Manager.Initial_Window_Position = Interface_Manager.Base_Position
                end
            end

            if Interface_Manager.Is_Visible and not Interface_Manager.Is_Resizing and not Interface_Manager.Is_Dragging and not Interface_Manager.Is_Dragging_Indicator and not Interface_Manager.Is_Dragging_Stats and not Interface_Manager.Is_Dragging_Manual_Spam then
                if Mouse_Position.X >= Interface_Manager.Base_Position.X and Mouse_Position.X <= Interface_Manager.Base_Position.X + 130 then
                    for Tab_Name, Renderer_Data in pairs(Interface_Manager.Tab_Renderers) do
                        if Mouse_Position.Y >= Interface_Manager.Base_Position.Y + 45 + (Renderer_Data.Render_Index * 30) and Mouse_Position.Y <= Interface_Manager.Base_Position.Y + 65 + (Renderer_Data.Render_Index * 30) then
                            Change_Active_Tab(Tab_Name)
                        end
                    end
                end

                local Has_Interacted_With_Dropdown = false
                if Interface_Manager.Active_Dropdown_Element then
                    local Active_Dropdown_Data = Interface_Manager.Active_Dropdown_Element
                    if Active_Dropdown_Data.Is_Open then
                        for Option_Index, Option_Renderer in ipairs(Active_Dropdown_Data.Item_Renderers) do
                            if Is_Location_In_Bounds(Option_Renderer.Base_Layout_Position, Option_Renderer.Layout_Dimensions) then
                                Configuration[Active_Dropdown_Data.Config_Key] = Option_Index
                                Active_Dropdown_Data.Is_Open = false
                                Interface_Manager.Active_Dropdown_Element = nil
                                Has_Interacted_With_Dropdown = true
                                if Active_Dropdown_Data.Is_Theme_Dropdown then
                                    Apply_Theme(Option_Index)
                                end
                                Refresh_Layout_Coordinates()
                                break
                            end
                        end
                    end
                    if not Has_Interacted_With_Dropdown and not Is_Location_In_Bounds(Active_Dropdown_Data.Outline_Box.Position, Active_Dropdown_Data.Outline_Box.Size) then
                        Active_Dropdown_Data.Is_Open = false
                        Interface_Manager.Active_Dropdown_Element = nil
                        Has_Interacted_With_Dropdown = true
                    end
                end

                if not Has_Interacted_With_Dropdown then
                    for _, Dropdown_Data in ipairs(Interface_Manager.Dropdowns) do
                        if Dropdown_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab and Is_Location_In_Bounds(Dropdown_Data.Outline_Box.Position, Dropdown_Data.Outline_Box.Size) then
                            if Interface_Manager.Active_Dropdown_Element and Interface_Manager.Active_Dropdown_Element ~= Dropdown_Data then
                                Interface_Manager.Active_Dropdown_Element.Is_Open = false
                            end
                            Dropdown_Data.Is_Open = not Dropdown_Data.Is_Open
                            Interface_Manager.Active_Dropdown_Element = Dropdown_Data.Is_Open and Dropdown_Data or nil
                            Has_Interacted_With_Dropdown = true
                            break
                        end
                    end
                end

                if not Has_Interacted_With_Dropdown and not Is_Hover_Obstructed then
                    for _, Toggle_Data in ipairs(Interface_Manager.Toggles) do
                        if Toggle_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab and Is_Location_In_Bounds(Toggle_Data.Outline_Box.Position, V2_New(Toggle_Data.Label_Text.TextBounds.X + 25, 12)) then
                            local Is_Bind_Interaction = false
                            if Toggle_Data.Keybind_Data and Is_Location_In_Bounds(Toggle_Data.Keybind_Data.Outline_Box.Position, Toggle_Data.Keybind_Data.Outline_Box.Size) then
                                Is_Bind_Interaction = true
                            end
                            if not Is_Bind_Interaction then
                                Configuration[Toggle_Data.Config_Key] = not Configuration[Toggle_Data.Config_Key]
                            end
                        end
                    end
                    for _, Bind_Data in ipairs(Interface_Manager.Binds) do
                        if Bind_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab and Is_Location_In_Bounds(Bind_Data.Outline_Box.Position, Bind_Data.Outline_Box.Size) then
                            Interface_Manager.Active_Keybind_Listener = Bind_Data.Action_Key
                        end
                    end
                    for _, Slider_Data in ipairs(Interface_Manager.Sliders) do
                        if Slider_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab and Is_Location_In_Bounds(Slider_Data.Outline_Box.Position - V2_New(0, 5), Slider_Data.Outline_Box.Size + V2_New(0, 10)) then
                            Interface_Manager.Active_Slider_Element = Slider_Data
                        end
                    end
                    for _, Cp_Data in ipairs(Interface_Manager.Color_Pickers) do
                        if Cp_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab then
                            if Is_Location_In_Bounds(Cp_Data.Sv_Background.Position, Cp_Data.Sv_Background.Size) or Is_Location_In_Bounds(Cp_Data.Hue_Outline.Position, Cp_Data.Hue_Outline.Size) or Is_Location_In_Bounds(Cp_Data.Alpha_Outline.Position, Cp_Data.Alpha_Outline.Size) then
                                Interface_Manager.Active_Picker_Element = Cp_Data
                            end
                        end
                    end
                    for _, Btn_Data in ipairs(Interface_Manager.Buttons) do
                        if Btn_Data.Parent_Group.Parent_Tab == Interface_Manager.Current_Tab and Is_Location_In_Bounds(Btn_Data.Outline_Box.Position, Btn_Data.Outline_Box.Size) then
                            if Btn_Data.Callback_Func then Btn_Data.Callback_Func() end
                        end
                    end
                end
            end
        end

        if Is_Mouse_Pressed and Interface_Manager.Active_Slider_Element and not Is_Hover_Obstructed then
            local Slider_Instance = Interface_Manager.Active_Slider_Element
            local Fill_Percentage = Math_Clamp((Mouse_Position.X - Slider_Instance.Outline_Box.Position.X) / Slider_Instance.Outline_Box.Size.X, 0, 1)
            local Calculated_Value = Slider_Instance.Min_Bound + (Fill_Percentage * (Slider_Instance.Max_Bound - Slider_Instance.Min_Bound))
            if Slider_Instance.Precision == 0 then Calculated_Value = Math_Floor(Calculated_Value) end
            Configuration[Slider_Instance.Config_Key] = Calculated_Value
            Refresh_Layout_Coordinates()
        end

        if Is_Mouse_Pressed and Interface_Manager.Active_Picker_Element and not Is_Hover_Obstructed then
            local Cp_Data = Interface_Manager.Active_Picker_Element
            if Mouse_Position.X >= Cp_Data.Hue_Outline.Position.X - 5 and Mouse_Position.X <= Cp_Data.Hue_Outline.Position.X + Cp_Data.Hue_Outline.Size.X + 5 then
                local Inner_Y = Cp_Data.Hue_Outline.Position.Y + 1
                local Inner_Height = Cp_Data.Hue_Outline.Size.Y - 2
                Cp_Data.Hue = 1 - Math_Clamp((Mouse_Position.Y - Inner_Y) / Inner_Height, 0, 1)
            elseif Mouse_Position.X >= Cp_Data.Alpha_Outline.Position.X - 5 and Mouse_Position.X <= Cp_Data.Alpha_Outline.Position.X + Cp_Data.Alpha_Outline.Size.X + 5 then
                local Alpha_Inner_Y = Cp_Data.Alpha_Outline.Position.Y + 1
                local Alpha_Inner_Height = Cp_Data.Alpha_Outline.Size.Y - 2
                Cp_Data.Alpha = 1 - Math_Clamp((Mouse_Position.Y - Alpha_Inner_Y) / Alpha_Inner_Height, 0, 1)
            elseif Mouse_Position.X >= Cp_Data.Sv_Background.Position.X - 5 and Mouse_Position.X <= Cp_Data.Sv_Background.Position.X + Cp_Data.Sv_Background.Size.X + 5 then
                local Sv_Inner_X = Cp_Data.Sv_Background.Position.X
                local Sv_Inner_Y = Cp_Data.Sv_Background.Position.Y
                local Sv_Inner_Width = Cp_Data.Sv_Background.Size.X
                local Sv_Inner_Height = Cp_Data.Sv_Background.Size.Y
                Cp_Data.Sat = Math_Clamp((Mouse_Position.X - Sv_Inner_X) / Sv_Inner_Width, 0, 1)
                Cp_Data.Val = 1 - Math_Clamp((Mouse_Position.Y - Sv_Inner_Y) / Sv_Inner_Height, 0, 1)
            end
            Interface_Manager.Palette[Cp_Data.Color_Key] = Convert_Hsv_To_Rgb(Cp_Data.Hue, Cp_Data.Sat, Cp_Data.Val)
            Update_Colors()
            Refresh_Layout_Coordinates()
        end

        if not Is_Mouse_Pressed then
            Interface_Manager.Is_Dragging = false
            Interface_Manager.Is_Resizing = false
            Interface_Manager.Is_Dragging_Indicator = false
            Interface_Manager.Is_Dragging_Stats = false
            Interface_Manager.Is_Dragging_Manual_Spam = false
            Interface_Manager.Active_Slider_Element = nil
            Interface_Manager.Active_Picker_Element = nil
        end

        if Interface_Manager.Is_Resizing then
            local Displacement_Vector = Mouse_Position - Interface_Manager.Resize_Start_Location
            local New_Layout_X = Interface_Manager.Initial_Window_Position.X
            local New_Layout_Y = Interface_Manager.Initial_Window_Position.Y
            local New_Layout_Width = Interface_Manager.Initial_Window_Size.X
            local New_Layout_Height = Interface_Manager.Initial_Window_Size.Y
            if String_Find(Interface_Manager.Resize_Direction, "B") then
                New_Layout_Height = Math_Max(Interface_Manager.Minimum_Dimensions.Y, Interface_Manager.Initial_Window_Size.Y + Displacement_Vector.Y)
            elseif String_Find(Interface_Manager.Resize_Direction, "T") then
                New_Layout_Height = Math_Max(Interface_Manager.Minimum_Dimensions.Y, Interface_Manager.Initial_Window_Size.Y - Displacement_Vector.Y)
                New_Layout_Y = Interface_Manager.Initial_Window_Position.Y + (Interface_Manager.Initial_Window_Size.Y - New_Layout_Height)
            end
            if String_Find(Interface_Manager.Resize_Direction, "R") then
                New_Layout_Width = Math_Max(Interface_Manager.Minimum_Dimensions.X, Interface_Manager.Initial_Window_Size.X + Displacement_Vector.X)
            elseif String_Find(Interface_Manager.Resize_Direction, "L") then
                New_Layout_Width = Math_Max(Interface_Manager.Minimum_Dimensions.X, Interface_Manager.Initial_Window_Size.X - Displacement_Vector.X)
                New_Layout_X = Interface_Manager.Initial_Window_Position.X + (Interface_Manager.Initial_Window_Size.X - New_Layout_Width)
            end
            Interface_Manager.Dimensions = V2_New(New_Layout_Width, New_Layout_Height)
            Interface_Manager.Base_Position = V2_New(New_Layout_X, New_Layout_Y)
            Refresh_Layout_Coordinates()
        elseif Interface_Manager.Is_Dragging then
            Interface_Manager.Base_Position = Interface_Manager.Initial_Window_Position + (Mouse_Position - Interface_Manager.Drag_Start_Location)
            Refresh_Layout_Coordinates()
        end

        if Interface_Manager.Is_Dragging_Indicator then
            Interface_Manager.Indicator_Position = Interface_Manager.Initial_Indicator_Position + (Mouse_Position - Interface_Manager.Indicator_Drag_Start)
            Refresh_Layout_Coordinates()
        end
        if Interface_Manager.Is_Dragging_Stats then
            Interface_Manager.Stats_Panel_Position = Interface_Manager.Initial_Stats_Position + (Mouse_Position - Interface_Manager.Stats_Drag_Start)
            Refresh_Layout_Coordinates()
        end
        if Interface_Manager.Is_Dragging_Manual_Spam then
            Interface_Manager.Manual_Spam_Panel_Position = Interface_Manager.Initial_Manual_Spam_Position + (Mouse_Position - Interface_Manager.Manual_Spam_Drag_Start)
            Refresh_Layout_Coordinates()
        end

        Was_Mouse_Pressed = Is_Mouse_Pressed
    end
end)

local function Do_Click()
    if not isrbxactive() then return end
    if Configuration.Parry_Method == 1 then
        mouse1press()
        Task_Wait()
        mouse1release()
    else
        keypress(0x46)
        Task_Wait()
        keyrelease(0x46)
    end
end

local function Execute_Parry_Action(Is_Lobby_Parry_Call)
    local Did_Curve = false
    if not Is_Lobby_Parry_Call and Configuration.Auto_Curve and ismouse2pressed() then
        local Curve_Mode = Configuration.Auto_Curve_Mode
        local Sensitivity_Val = Configuration.Camera_Sens
        local Delta_X, Delta_Y = 0, 0
        if Curve_Mode == 1 then
            Delta_Y = -(600 * Sensitivity_Val)
        elseif Curve_Mode == 2 then
            Delta_X = 8000 * Sensitivity_Val
        end
        if Delta_X ~= 0 or Delta_Y ~= 0 then
            Did_Curve = true
            Task_Spawn(function()
                if mousemoverel then mousemoverel(Delta_X, Delta_Y) end
                Task_Spawn(Do_Click)
                Task_Wait(0.01)
                if mousemoverel then mousemoverel(-Delta_X, -Delta_Y) end
            end)
        end
    end

    if not Did_Curve then
        Task_Spawn(Do_Click)
    end
end

local Auto_Thread_Offsets = {0, 0.002, 0.004, 0.006, 0.008, 0.010, 0.012, 0.014, 0.016, 0.018}
for Index_I = 1, 10 do
    Task_Spawn(function()
        local Stagger_Offset = Auto_Thread_Offsets[Index_I]
        while _G.Nightfall_Active do
            local Is_Spamming = Player_State.Is_Alive and Parry_State.Ball.Auto_Spam
            if Is_Spamming and isrbxactive() then
                if Stagger_Offset > 0 then
                    local Start_Tick = tick()
                    while tick() - Start_Tick < Stagger_Offset do
                        Task_Wait()
                    end
                end
                if Configuration.Parry_Method == 1 then
                    mouse1press()
                    mouse1release()
                else
                    keypress(0x46)
                    keyrelease(0x46)
                end
            end
            Task_Wait()
        end
    end)
end

local Manual_Thread_Offsets = {0, 0.002, 0.004, 0.006, 0.008, 0.010, 0.012, 0.014, 0.016, 0.018}
for Index_I = 1, 10 do
    Task_Spawn(function()
        local Stagger_Offset = Manual_Thread_Offsets[Index_I]
        while _G.Nightfall_Active do
            local Is_Manual_Spamming = Player_State.Manual_Spam_Active
            if Is_Manual_Spamming and isrbxactive() then
                if Stagger_Offset > 0 then
                    local Start_Tick = tick()
                    while tick() - Start_Tick < Stagger_Offset do
                        Task_Wait()
                    end
                end
                if Configuration.Parry_Method == 1 then
                    mouse1press()
                    mouse1release()
                else
                    keypress(0x46)
                    keyrelease(0x46)
                end
            end
            Task_Wait()
        end
    end)
end

local function Setup_Ball_Watcher(Ball_Instance)
    if Watcher_State.Ball_Conn then
        Watcher_State.Ball_Conn:Disconnect()
        Watcher_State.Ball_Conn = nil
    end
    if not Ball_Instance then
        Parry_State.Ball.Cached_Target = nil
        return
    end
    Watcher_State.Current_Ball = Ball_Instance
    Parry_State.Ball.Cached_Target = Ball_Instance:GetAttribute("target")
    Watcher_State.Ball_Conn = Cvm:OnAttributeChanged(Ball_Instance, "target", function(New_Value)
        Parry_State.Ball.Cached_Target = New_Value
    end)
end

Custom_Run_Service.Heartbeat:Connect(function(Delta_Time)
    Delta_Time = Delta_Time or 0.016

    local Active_Ball_Instances = {}
    local Ball_Folder_Check = Workspace_Service:FindFirstChild("Balls")
    if Ball_Folder_Check then
        for _, Ball_Instance in ipairs(Ball_Folder_Check:GetChildren()) do
            if Ball_Instance:GetAttribute("realBall") then
                Active_Ball_Instances[Ball_Instance] = true
            end
        end
    end
    local Training_Folder_Check = Workspace_Service:FindFirstChild("TrainingBalls")
    if Training_Folder_Check then
        for _, Training_Ball in ipairs(Training_Folder_Check:GetChildren()) do
            if Training_Ball:GetAttribute("realBall") then
                Active_Ball_Instances[Training_Ball] = true
            end
        end
    end
    for Tracked_Ball in pairs(Parry_State.Trajectory_Cache) do
        if not Active_Ball_Instances[Tracked_Ball] then
            Parry_State.Trajectory_Cache[Tracked_Ball] = nil
        end
    end

    Safe_Call(function()
        local Player_Character = Local_Player.Character
        local Root_Part = Player_Character and Player_Character:FindFirstChild("HumanoidRootPart")
        local Humanoid_Part = Player_Character and Player_Character:FindFirstChild("Humanoid")

        if not Root_Part or not Humanoid_Part or Humanoid_Part.Health <= 0 then
            Parry_State.Target.Current_Name = nil
            Parry_State.Ball.Auto_Spam = false
            Parry_State.Ball.Parries = 0
            Parry_State.Ball.Cooldown = false
            Player_State.Scheduled_Trigger_Time = 0
            Parry_State.Trajectory_Cache = {}
            Player_State.Current_Parry_Threshold = 0
            Player_State.Is_Alive = false
            Player_State.Is_Dead = true
            Parry_State.Ball.Last_Position = V3_Zero
            Parry_State.Ball.Smoothed_Accel = 0
            return
        end

        local Alive_Folder = Workspace_Service:FindFirstChild("Alive")
        local Dead_Folder = Workspace_Service:FindFirstChild("Dead")
        local Is_Entity_Alive = false
        local Is_Entity_Dead = false

        if Alive_Folder and Player_Character:IsDescendantOf(Alive_Folder) then
            Is_Entity_Alive = true
        elseif Dead_Folder and Player_Character:IsDescendantOf(Dead_Folder) then
            Is_Entity_Dead = true
        else
            Is_Entity_Alive = Humanoid_Part.Health > 0
            Is_Entity_Dead = Humanoid_Part.Health <= 0
        end

        Player_State.Is_Alive = Is_Entity_Alive
        Player_State.Is_Dead = Is_Entity_Dead

        if not Is_Entity_Alive then
            Parry_State.Ball.Auto_Spam = false
        end

        local Application_Tick = Time_Tick()
        Player_State.Entity.Server_Position = Root_Part.Position
        Player_State.Entity.Velocity = Root_Part.AssemblyLinearVelocity
        Player_State.Entity.Speed = Get_Vector_Magnitude(Player_State.Entity.Velocity)

        Player_State.Entity.Ping = Get_Raw_Ping()

        Table_Insert(Player_State.Entity.Ping_History, Player_State.Entity.Ping)
        if #Player_State.Entity.Ping_History > 20 then
            Table_Remove(Player_State.Entity.Ping_History, 1)
        end
        local Ping_Sum = 0
        local Ping_Max = 0
        for _, P_Val in ipairs(Player_State.Entity.Ping_History) do
            Ping_Sum = Ping_Sum + P_Val
            if P_Val > Ping_Max then Ping_Max = P_Val end
        end
        local Ping_Mean = Ping_Sum / #Player_State.Entity.Ping_History
        local Variance_Sum = 0
        for _, P_Val in ipairs(Player_State.Entity.Ping_History) do
            Variance_Sum = Variance_Sum + (P_Val - Ping_Mean)^2
        end
        local Raw_Jitter = Math_Sqrt(Variance_Sum / #Player_State.Entity.Ping_History)
        Player_State.Entity.Jitter = Raw_Jitter
        Player_State.Entity.Jitter_Smoothed = Player_State.Entity.Jitter_Smoothed + (Raw_Jitter - Player_State.Entity.Jitter_Smoothed) * 0.1
        local Spike_Offset = Math_Max(0, Ping_Max - Ping_Mean - Raw_Jitter)
        Player_State.Entity.Smoothed_Ping = Ping_Mean + (Raw_Jitter * 0.5) + (Spike_Offset * 0.3)

        local Ball_Entity_Found = false

        if Is_Entity_Alive and (Configuration.Auto_Parry or Configuration.Auto_Spam or Configuration.Triggerbot_Enabled or Configuration.Render_Ball_Stats) then
            local Predicted_Position = Player_State.Entity.Server_Position + (Player_State.Entity.Velocity * 0.015)
            local Ball_Folder = Workspace_Service:FindFirstChild("Balls")

            if Ball_Folder then
                for _, Ball_Instance in ipairs(Ball_Folder:GetChildren()) do
                    if Ball_Instance:GetAttribute("realBall") then
                        Ball_Entity_Found = true
                        if Watcher_State.Current_Ball ~= Ball_Instance then
                            Setup_Ball_Watcher(Ball_Instance)
                        end
                        local Target_Attribute_Name = Parry_State.Ball.Cached_Target

                        local Prev_Ball_Position = Parry_State.Ball.Position
                        Parry_State.Ball.Position = Ball_Instance.Position
                        Parry_State.Ball.Velocity = Ball_Instance.AssemblyLinearVelocity
                        Parry_State.Ball.Speed = Get_Vector_Magnitude(Parry_State.Ball.Velocity)
                        Parry_State.Ball.Distance = Get_Distance_Between(Predicted_Position, Parry_State.Ball.Position)

                        local Is_Targeting_Local_Player = Check_Is_Target(Target_Attribute_Name)
                        local Nearest_Player_Entity, Distance_To_Nearest_Player = Scan_For_Nearest_Entity(Predicted_Position)

                        if Target_Attribute_Name ~= Parry_State.Target.Current_Name then
                            Parry_State.Ball.Cooldown = false
                            Parry_State.Ball.Old_Speed = Parry_State.Ball.Speed

                            local Time_Since_Change = Application_Tick - (Parry_State.Ball.Last_Target_Change or 0)

                            if Time_Since_Change <= 0.6 then
                                Parry_State.Ball.Parries = Parry_State.Ball.Parries + 1
                            else
                                Parry_State.Ball.Parries = 1
                                Parry_State.Ball.Auto_Spam = false
                            end

                            Parry_State.Target.Current_Name = Target_Attribute_Name
                            Parry_State.Ball.Last_Target_Change = Application_Tick

                            if Parry_State.Trajectory_Cache[Ball_Instance] then
                                Parry_State.Trajectory_Cache[Ball_Instance].History = {}
                                Parry_State.Trajectory_Cache[Ball_Instance].Is_Curving = false
                                Parry_State.Trajectory_Cache[Ball_Instance].Curve_Start_Time = 0
                            end

                            if Is_Targeting_Local_Player and Configuration.Triggerbot_Enabled then
                                local Elapsed_Since_Change = Application_Tick - Parry_State.Ball.Last_Target_Change
                                local Raw_Delay = Math_Random(Configuration.Min_Tb_Delay, Configuration.Max_Tb_Delay) / 1000
                                local Compensated_Delay = Math_Max(0, Raw_Delay - Elapsed_Since_Change)
                                Player_State.Scheduled_Trigger_Time = Application_Tick + Compensated_Delay
                            end
                        end

                        if Is_Targeting_Local_Player then
                            Parry_State.Ball.Last_Targeted_Me = Application_Tick
                        end

                        if Alive_Folder then
                            Parry_State.Target.Current = Alive_Folder:FindFirstChild(Target_Attribute_Name)
                        end

                        Parry_State.Ball.Maximum_Speed = Math_Max(Parry_State.Ball.Maximum_Speed, Parry_State.Ball.Speed)

                        local Raw_Accel = 0
                        if Parry_State.Ball.Last_Speed_Tick > 0 and Delta_Time > 0 then
                            Raw_Accel = (Parry_State.Ball.Speed - Parry_State.Ball.Last_Speed_Tick) / Delta_Time
                        end
                        Parry_State.Ball.Smoothed_Accel = Parry_State.Ball.Smoothed_Accel + (Raw_Accel - Parry_State.Ball.Smoothed_Accel) * Configuration.Accel_Smooth_Alpha
                        Parry_State.Ball.Last_Speed_Tick = Parry_State.Ball.Speed
                        if Prev_Ball_Position.X ~= 0 or Prev_Ball_Position.Y ~= 0 or Prev_Ball_Position.Z ~= 0 then
                            Parry_State.Ball.Last_Position = Prev_Ball_Position
                        end

                        local Parry_Threshold_Range = Get_Optimal_Parry_Threshold(
                            Ball_Instance,
                            Parry_State.Ball.Speed,
                            Predicted_Position,
                            Player_State.Entity.Ping,
                            Parry_State.Ball.Distance,
                            Delta_Time
                        )
                        Player_State.Current_Parry_Threshold = Parry_Threshold_Range

                        local Trajectory_Dot_Product = Player_State.Tracked_Dot_Product

                        if Configuration.Render_Ball_Stats then
                            Player_State.Tracked_Speed = Parry_State.Ball.Speed
                            Player_State.Tracked_Distance = Parry_State.Ball.Distance
                        end

                        local Singularity_Cape = Root_Part:FindFirstChild("SingularityCape")
                        if Singularity_Cape then
                            Parry_State.Ball.Cooldown = true
                        else

                        local Awaiting_Aero_Effect = false
                        local Aero_Visual_Effect = Ball_Instance:FindFirstChild("AeroDynamicSlashVFX")
                        if Aero_Visual_Effect then
                            if not Player_State.Aero_Effect_Active then
                                Player_State.Aero_Effect_Active = true
                                Player_State.Aero_Effect_Start_Time = Application_Tick
                            end
                            local Time_Since_Aero = Application_Tick - Player_State.Aero_Effect_Start_Time
                            if Time_Since_Aero < 0.2 or Ball_Instance.AssemblyLinearVelocity.Y > 10 then
                                Awaiting_Aero_Effect = true
                            end
                        else
                            Player_State.Aero_Effect_Active = false
                        end

                        local Block_All = Awaiting_Aero_Effect

                        if Configuration.Triggerbot_Enabled and Is_Targeting_Local_Player and not Block_All and Player_State.Scheduled_Trigger_Time > 0 then
                            if Application_Tick >= Player_State.Scheduled_Trigger_Time then
                                if not Parry_State.Ball.Cooldown then
                                    Execute_Parry_Action(false)
                                    Parry_State.Ball.Cooldown = true
                                end
                                Player_State.Scheduled_Trigger_Time = 0
                            end
                        end

                        local Spam_Params = {
                            Speed = Parry_State.Ball.Speed,
                            Parries = Parry_State.Ball.Parries,
                            Ball_Distance = Parry_State.Ball.Distance,
                            Entity_Distance = Distance_To_Nearest_Player,
                            Dot = Trajectory_Dot_Product,
                            Ping = Player_State.Entity.Ping
                        }

                        if Configuration.Auto_Spam and not Block_All then
                            if Is_Targeting_Local_Player then
                                Parry_State.Ball.Auto_Spam, Parry_State.Ball.Parries = Check_Is_Spam(Spam_Params)
                            elseif Parry_State.Ball.Auto_Spam then
                                if Trajectory_Dot_Product < 0.2 or Parry_State.Ball.Distance > 35 then
                                    Parry_State.Ball.Auto_Spam = false
                                else
                                    Parry_State.Ball.Auto_Spam, Parry_State.Ball.Parries = Check_Is_Spam(Spam_Params)
                                end
                            end
                        else
                            Parry_State.Ball.Auto_Spam = false
                        end

                        local Parry_Threshold_Range = Player_State.Current_Parry_Threshold

                        local Effective_Ping = Player_State.Entity.Smoothed_Ping or Player_State.Entity.Ping
                        local Jitter_Comp = (Player_State.Entity.Jitter_Smoothed or 0) * 0.5
                        local Ping_Seconds = (Effective_Ping + Jitter_Comp) / 1000
                        local Predict_Time = Ping_Seconds * Configuration.Ping_Multiplier + Configuration.Predict_Extra

                        local Predicted_Speed = Math_Max(Parry_State.Ball.Speed + (Parry_State.Ball.Smoothed_Accel * Predict_Time), Parry_State.Ball.Speed)
                        local Predicted_Ball_Pos = Parry_State.Ball.Position + (Parry_State.Ball.Velocity * (Predicted_Speed / Math_Max(Parry_State.Ball.Speed, 0.01)) * Predict_Time)

                        local Player_Vel = Player_State.Entity.Velocity
                        local Predicted_Player_Pos = Player_State.Entity.Server_Position + V3_New(
                            Player_Vel.X * Predict_Time,
                            Player_Vel.Y * Predict_Time,
                            Player_Vel.Z * Predict_Time
                        )

                        local Predicted_Distance = Get_Distance_Between(Predicted_Player_Pos, Predicted_Ball_Pos)

                        if Is_Targeting_Local_Player and Configuration.Auto_Parry and not Block_All and Parry_State.Ball.Speed >= Configuration.Min_Threat_Speed then
                            if Configuration.Auto_Curve and ismouse2pressed() then
                                Parry_Threshold_Range = Parry_Threshold_Range + (Parry_State.Ball.Speed * 0.015)
                            end

                            if not Parry_State.Ball.Cooldown and Predicted_Distance <= Parry_Threshold_Range then
                                Execute_Parry_Action(false)
                                Parry_State.Ball.Cooldown = true
                            end
                        end
                        end
                    end
                end
            end

            if not Ball_Entity_Found then
                Setup_Ball_Watcher(nil)
                Parry_State.Target.Current_Name = nil
                Parry_State.Ball.Auto_Spam = false
                Parry_State.Ball.Parries = 0
                Parry_State.Ball.Cooldown = false
                Player_State.Scheduled_Trigger_Time = 0
                Parry_State.Trajectory_Cache = {}
                Player_State.Current_Parry_Threshold = 0
                Parry_State.Ball.Last_Speed_Tick = 0
                Parry_State.Ball.Smoothed_Accel = 0
                Parry_State.Ball.Last_Position = V3_Zero
                Parry_State.Ball.Warp_Detected_Time = 0
                Parry_State.Ball.Smoothed_Dot = 1
                Parry_State.Ball.Dot_Velocity = 0
            end
        elseif Is_Entity_Dead and Configuration.Lobby_Parry then
            local Training_Folder = Workspace_Service:FindFirstChild("TrainingBalls")
            local Training_Ball_Found = false

            if Training_Folder then
                for _, Training_Ball in ipairs(Training_Folder:GetChildren()) do
                    if Training_Ball:GetAttribute("realBall") then
                        Training_Ball_Found = true
                        local Training_Target_Name = Training_Ball:GetAttribute("target")

                        if Training_Target_Name ~= Parry_State.Target.Current_Name then
                            Parry_State.Target.Current_Name = Training_Target_Name
                            Parry_State.Ball.Cooldown = false
                            Parry_State.Ball.Parries = 0
                            if Parry_State.Trajectory_Cache[Training_Ball] then
                                Parry_State.Trajectory_Cache[Training_Ball].History = {}
                                Parry_State.Trajectory_Cache[Training_Ball].Is_Curving = false
                                Parry_State.Trajectory_Cache[Training_Ball].Curve_Start_Time = 0
                            end
                        end

                        local Is_Targeting_Local_Player = Check_Is_Target(Training_Target_Name)
                        local Training_Ball_Velocity = Training_Ball.AssemblyLinearVelocity
                        local Training_Ball_Speed = Get_Vector_Magnitude(Training_Ball_Velocity)

                        local Training_Threshold = Get_Optimal_Parry_Threshold(
                            Training_Ball,
                            Training_Ball_Speed,
                            Player_State.Entity.Server_Position,
                            Player_State.Entity.Ping,
                            Get_Distance_Between(Player_State.Entity.Server_Position, Training_Ball.Position),
                            Delta_Time
                        )
                        Player_State.Current_Parry_Threshold = Training_Threshold

                        if Configuration.Auto_Curve and ismouse2pressed() then
                            Training_Threshold = Training_Threshold + (Training_Ball_Speed * 0.015)
                        end

                        if Is_Targeting_Local_Player then
                            local Ping_Seconds = Player_State.Entity.Ping / 1000
                            local Predict_Time = Ping_Seconds * Configuration.Ping_Multiplier + Configuration.Predict_Extra

                            local Predicted_Train_Speed = Math_Max(Training_Ball_Speed, Training_Ball_Speed)
                            local Predicted_Train_Dir = Normalize_Vector(Training_Ball_Velocity)
                            local Predicted_Train_Pos = Training_Ball.Position + (Predicted_Train_Dir * (Predicted_Train_Speed * Predict_Time))

                            local Player_Vel = Player_State.Entity.Velocity
                            local Predicted_Player_Pos = Player_State.Entity.Server_Position + V3_New(
                                Player_Vel.X * Predict_Time,
                                Player_Vel.Y * Predict_Time,
                                Player_Vel.Z * Predict_Time
                            )

                            local Predicted_Train_Distance = Get_Distance_Between(Predicted_Player_Pos, Predicted_Train_Pos)

                            if not Parry_State.Ball.Cooldown and Predicted_Train_Distance <= Training_Threshold then
                                Execute_Parry_Action(true)
                                Parry_State.Ball.Cooldown = true
                            end
                        end
                    end
                end
            end

            if not Training_Ball_Found then
                Parry_State.Target.Current_Name = nil
                Parry_State.Ball.Cooldown = false
                Parry_State.Trajectory_Cache = {}
                Player_State.Current_Parry_Threshold = 0
            end
        else
            Player_State.Current_Parry_Threshold = 0
        end
    end)
end)
