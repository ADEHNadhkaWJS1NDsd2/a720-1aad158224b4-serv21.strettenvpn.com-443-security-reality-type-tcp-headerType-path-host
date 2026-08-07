
local LOGO_URL = "https://files.catbox.moe/tzc225.png"
local BG_URL = "https://files.catbox.moe/pli6ip.png"

if game.GameId ~= 5166944221 then
    warn("Join in Death Ball")
    return
end

print("Loaded Death Ball")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
setrobloxinput(true)

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"))() or INSui

local AutoParryEnabled = false
local TTIThreshold = 0.15
local MinSpeedLimit, MaxSpeedLimit, BufferSize = 35, 500, 10


local WindowApp = Lib:CreateWindow({
	title = "Nightfall",
	subtitle = "Death Ball",
	size = Vector2.new(700, 560),
	menuKey = "F2",
	configName = "Nightfall",
	configFolder = "DeathballConfigs",
	badge = "v2",
	opacity = 0.95,
	rounding = 1,
	rowLines = false,
	smartFps = false,
	autoSave = true,
	startOpen = true,
	keybindOverlay = true,
	logo = LOGO_URL,
	logoSize = 34,
	checkboxStyle = true,
	theme = {
		accentA = Color3.fromRGB(120, 60, 220),
		accentB = Color3.fromRGB(80, 40, 180),
	},
})

Lib:SetBackgroundImage(BG_URL, 0.22, 0.7, 0.09)
Lib:SetBackgroundEffect("Rain")
Lib:SetBackgroundEffectColor(Color3.fromRGB(160, 90, 255))

local CombatTab = WindowApp:Tab("Combat", "swords")

local AutoParrySection = CombatTab:Section("Auto Parry", "Left", "")
local AutoParryToggle = AutoParrySection:Toggle("Enabled", false, function(Value)
	AutoParryEnabled = Value
end)
AutoParryToggle:AddKeybind("None", "Toggle")
AutoParryToggle:SetRisk()

AutoParrySection:Slider("Parry Timing", 0.15, 0.01, 0.1, 0.5, "s", function(Value)
	TTIThreshold = Value
end)

local InfoSection = CombatTab:Section("Info", "Right", "")
InfoSection:Label(function()
	return "Status: " .. (AutoParryEnabled and "Enabled" or "Disabled")
end)
InfoSection:Info("Lower timing parries later. Higher timing parries earlier.")

WindowApp:AddSettingsTab("cog")

local BallTracker = {}
BallTracker.__index = BallTracker

function BallTracker.New(BallInstance, UpdateCallback)
    local Self = setmetatable({}, BallTracker)
    Self.Ball = BallInstance
    Self.Callback = UpdateCallback
    Self.LastPosition = nil
    Self.LastTick = 0
    Self.IsRunning = false
    return Self
end

function BallTracker:Start()
    self.IsRunning = true
    task.spawn(function()
        while self.IsRunning and self.Ball and self.Ball.Parent do
            task.wait()
            
            local CurrentPosition = self.Ball.Position
            if not CurrentPosition then continue end
            
            local CurrentTick = tick()
            local DeltaTime = CurrentTick - self.LastTick
            
            if self.LastPosition and DeltaTime > 0.001 then
                local DeltaX = CurrentPosition.X - self.LastPosition.X
                local DeltaY = CurrentPosition.Y - self.LastPosition.Y
                local DeltaZ = CurrentPosition.Z - self.LastPosition.Z
                local StepDistance = math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY + DeltaZ * DeltaZ)
                
                if StepDistance < 30 then
                    local StepVelocity = StepDistance / DeltaTime
                    self.Callback(CurrentPosition, self.LastPosition, StepVelocity, DeltaTime, StepDistance)
                end
            end
            
            self.LastPosition = CurrentPosition
            self.LastTick = CurrentTick
        end
    end)
end

function BallTracker:Stop()
    self.IsRunning = false
end

local LastParryTime = 0
local PositionBuffer = {}
local TimeBuffer = {}
BufferSize = 10
MaxSpeedLimit = 500
MinSpeedLimit = 35

local InterpolatedRadians = 0
local LastWarpTick = tick()

local function LinearInterpolation(Start, End, Alpha)
    return Start + (End - Start) * Alpha
end

local function ValidateTarget()
    local Character = LocalPlayer.Character
    if not Character then return false end
    
    local Highlight = Character:FindFirstChild("Highlight")
    if not Highlight then return false end
    
    local MemoryValue = memory_read("float", Highlight.Address + 228)
    return MemoryValue > 0.3 and MemoryValue < 0.4
end

local function ExecuteParry()
    keypress(70)
    keyrelease(70)
end

local function GetPlayerRootPosition()
    local Character = LocalPlayer.Character
    if Character then
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if RootPart then 
            return RootPart.Position 
        end
    end
    return nil
end

local function CalculateDistance(PointA, PointB)
    local DeltaX = PointA.X - PointB.X
    local DeltaY = PointA.Y - PointB.Y
    local DeltaZ = PointA.Z - PointB.Z
    return math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY + DeltaZ * DeltaZ)
end

local function ProcessBallUpdate(CurrentPosition, PreviousPosition, StepVelocity, DeltaTime, StepDistance)
    if not AutoParryEnabled then return end

    if not ValidateTarget() then
        PositionBuffer = {}
        TimeBuffer = {}
        InterpolatedRadians = 0
        return
    end
    
    if StepVelocity < MinSpeedLimit or StepVelocity > MaxSpeedLimit then return end
    
    local TargetPosition = GetPlayerRootPosition()
    if not TargetPosition then return end
    
    table.insert(PositionBuffer, CurrentPosition)
    table.insert(TimeBuffer, tick())
    
    if #PositionBuffer > BufferSize then
        table.remove(PositionBuffer, 1)
        table.remove(TimeBuffer, 1)
    end
    
    if #PositionBuffer < 5 then return end
    
    local FirstPosition = PositionBuffer[1]
    local LastPosition = PositionBuffer[#PositionBuffer]
    local FirstTick = TimeBuffer[1]
    local LastTick = TimeBuffer[#TimeBuffer]
    local TotalDeltaTime = LastTick - FirstTick
    
    if TotalDeltaTime < 0.01 then return end
    
    local AverageSpeed = CalculateDistance(LastPosition, FirstPosition) / TotalDeltaTime
    if AverageSpeed < MinSpeedLimit or AverageSpeed > MaxSpeedLimit then return end
    
    local DistanceToPlayer = CalculateDistance(CurrentPosition, TargetPosition)
    
    local VelocityX = (LastPosition.X - FirstPosition.X) / TotalDeltaTime
    local VelocityY = (LastPosition.Y - FirstPosition.Y) / TotalDeltaTime
    local VelocityZ = (LastPosition.Z - FirstPosition.Z) / TotalDeltaTime
    
    local VelocityVector = Vector3.new(VelocityX, VelocityY, VelocityZ)
    local DirectionVector = VelocityVector.Unit
    
    local VectorToPlayer = TargetPosition - CurrentPosition
    local PlayerDirection = VectorToPlayer.Unit
    local DotProduct = PlayerDirection:Dot(DirectionVector)
    
    local DistanceAlongTrajectory = VectorToPlayer:Dot(DirectionVector)
    local ProjectedPosition = CurrentPosition + (DirectionVector * DistanceAlongTrajectory)
    local MissDistance = CalculateDistance(TargetPosition, ProjectedPosition)
    
    local WillHitPhysically = (MissDistance <= 5.5) and (DistanceAlongTrajectory > 0)
    
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude
    RayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local RayDirection = CurrentPosition - TargetPosition
    local RayResult = Workspace:Raycast(TargetPosition, RayDirection, RayParams)
    local IsObstructed = false
    
    if RayResult and RayResult.Instance then
        if RayResult.Instance.CanCollide and RayResult.Instance.Name ~= "Part" and RayResult.Instance.ClassName ~= "MeshPart" then
            IsObstructed = true
        end
    end
    
    local NetworkPing = GetPingValue()
    
    local ReachTime = (DistanceToPlayer / AverageSpeed) - (NetworkPing / 1000)
    local DotThreshold = 0.55 - (NetworkPing / 1000)
    local SpeedThreshold = math.min(AverageSpeed / 100, 40)
    local AngleThreshold = 40 * math.max(DotProduct, 0)
    local DistanceThreshold = 15 - math.min(DistanceToPlayer / 1000, 15) + AngleThreshold + SpeedThreshold
    
    if AverageSpeed > 100 and ReachTime > (NetworkPing / 10) then
        DistanceThreshold = math.max(DistanceThreshold - 15, 15)
    end
    
    local ClampedDot = math.clamp(DotProduct, -1, 1)
    local CalculatedRadians = math.rad(math.asin(ClampedDot))
    
    InterpolatedRadians = LinearInterpolation(InterpolatedRadians, CalculatedRadians, 0.8)
    
    local IsCurved = false
    
    if DistanceToPlayer < DistanceThreshold then
        IsCurved = false
    else
        if InterpolatedRadians < 0.018 then
            LastWarpTick = tick()
        end
        
        if (tick() - LastWarpTick) < (ReachTime / 1.5) then
            IsCurved = true
        else
            IsCurved = (DotProduct < DotThreshold)
        end
    end
    
    if not WillHitPhysically or IsObstructed then
        IsCurved = true
    end
    
    if not IsCurved then
        local TimeToImpact = DistanceToPlayer / AverageSpeed
        local TTIThresholdSeconds = TTIThreshold

        if DotProduct > 0.65 and WillHitPhysically then
            if TimeToImpact <= TTIThresholdSeconds and (tick() - LastParryTime >= 0.01) then
                ExecuteParry()
                LastParryTime = tick()
            end
        end
    end
end

local ActiveTrackers = {}

local function UpdateWorkspaceScans()
    for _, Object in pairs(Workspace:GetChildren()) do
        if Object.ClassName == "MeshPart" and Object.Name == "Part" then
            if not ActiveTrackers[Object] then
                local Tracker = BallTracker.New(Object, ProcessBallUpdate)
                Tracker:Start()
                ActiveTrackers[Object] = Tracker
            end
        end
    end
    
    for BallObject, Tracker in pairs(ActiveTrackers) do
        if not BallObject.Parent then
            Tracker:Stop()
            ActiveTrackers[BallObject] = nil
        end
    end
end

task.spawn(function()
    while true do
        UpdateWorkspaceScans()
        task.wait(0.5)
    end
end)
