local LOGO_URL = "https://files.catbox.moe/tzc225.png"
local BG_URL = "https://files.catbox.moe/pli6ip.png"
local LIBRARY_URL = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"

if game.GameId ~= 5166944221 then
    warn("Join in Death Ball")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

if not Players or not Workspace then return end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    for _ = 1, 200 do
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
        if LocalPlayer then break end
    end
end
if not LocalPlayer then return end

if type(setrobloxinput) == "function" then
    setrobloxinput(true)
end

if type(loadstring) ~= "function" then return end

local LibrarySource = game:HttpGet(LIBRARY_URL)
if type(LibrarySource) ~= "string" or #LibrarySource < 1000 then return end

local LibraryLoader = loadstring(LibrarySource)
if type(LibraryLoader) ~= "function" then return end

local Lib = LibraryLoader()
if type(Lib) ~= "table" or type(Lib.CreateWindow) ~= "function" then
    if type(INSUI) == "table" and type(INSUI.CreateWindow) == "function" then
        Lib = INSUI
    elseif type(INSui) == "table" and type(INSui.CreateWindow) == "function" then
        Lib = INSui
    else
        return
    end
end

if type(Lib.ApplyThemePreset) == "function" then
    Lib:ApplyThemePreset("Indigo")
elseif type(Lib.SetAccent) == "function" then
    Lib:SetAccent(Color3.fromRGB(122, 134, 255), Color3.fromRGB(189, 130, 255))
end

local WindowApp = Lib:CreateWindow({
    title = "Nightfall",
    subtitle = "Death Ball",
    size = Vector2.new(700, 560),
    menuKey = "F2",
    configName = "Nightfall",
    configFolder = "DeathballConfigs",
    smartFps = false,
    checkboxStyle = true,
    opacity = 98,
    logo = LOGO_URL,
    logoSize = 34,
    rounding = 1,
    rowLines = false,
    autoSave = false,
    startOpen = true,
    keybindOverlay = true
})

if type(WindowApp) ~= "table" then return end

if type(Lib.SetBackgroundImage) == "function" then
    Lib:SetBackgroundImage(BG_URL, 0.22, 0.7, 0.09)
end
if type(Lib.SetBackgroundEffect) == "function" then
    Lib:SetBackgroundEffect("Rain")
end
if type(Lib.SetBackgroundEffectColor) == "function" then
    Lib:SetBackgroundEffectColor(Color3.fromRGB(160, 90, 255))
end

local AutoParryEnabled = false
local TTIThreshold = 0.15
local MinSpeedLimit = 35
local MaxSpeedLimit = 500
local BufferSize = 10

if type(Lib.Category) == "function" then
    Lib:Category("COMBAT")
end

if type(WindowApp.Tab) ~= "function" then return end
local CombatTab = WindowApp:Tab("Combat", "swords")
if type(CombatTab) ~= "table" or type(CombatTab.Section) ~= "function" then return end

local AutoParrySection = CombatTab:Section("Auto Parry", "Left", "")
if type(AutoParrySection) ~= "table" then return end

local AutoParryToggle
if type(AutoParrySection.Toggle) == "function" then
    AutoParryToggle = AutoParrySection:Toggle("Enabled", false, function(Value)
        AutoParryEnabled = Value == true
    end)
end

if type(AutoParryToggle) == "table" then
    if type(AutoParryToggle.AddKeybind) == "function" then
        AutoParryToggle:AddKeybind("None", "Toggle")
    end
    if type(AutoParryToggle.SetRisk) == "function" then
        AutoParryToggle:SetRisk()
    end
end

if type(AutoParrySection.Slider) == "function" then
    AutoParrySection:Slider("Parry Timing", 0.15, 0.01, 0.1, 0.5, "s", function(Value)
        if type(Value) == "number" then
            TTIThreshold = Value
        end
    end)
end

local InfoSection = CombatTab:Section("Info", "Right", "")
if type(InfoSection) == "table" then
    if type(InfoSection.Label) == "function" then
        InfoSection:Label(function()
            return "Status: " .. (AutoParryEnabled and "Enabled" or "Disabled")
        end)
    end
    if type(InfoSection.Info) == "function" then
        InfoSection:Info("Lower timing parries later. Higher timing parries earlier.")
    end
end

if type(WindowApp.AddSettingsTab) == "function" then
    WindowApp:AddSettingsTab("cog")
end

local BallTracker = {}
BallTracker.__index = BallTracker

function BallTracker.New(BallInstance, UpdateCallback)
    if not BallInstance or typeof(BallInstance) ~= "Instance" or not BallInstance:IsA("BasePart") then return nil end
    if type(UpdateCallback) ~= "function" then return nil end

    local Self = setmetatable({}, BallTracker)
    Self.Ball = BallInstance
    Self.Callback = UpdateCallback
    Self.LastPosition = nil
    Self.LastTick = 0
    Self.IsRunning = false
    return Self
end

function BallTracker:Start()
    if self.IsRunning then return end
    if not self.Ball or typeof(self.Ball) ~= "Instance" or not self.Ball:IsA("BasePart") then return end
    if type(self.Callback) ~= "function" then return end

    self.IsRunning = true

    task.spawn(function()
        while self.IsRunning do
            local Ball = self.Ball
            if not Ball or typeof(Ball) ~= "Instance" or not Ball.Parent or not Ball:IsA("BasePart") then break end

            task.wait()

            local CurrentPosition = Ball.Position
            if typeof(CurrentPosition) ~= "Vector3" then continue end

            local CurrentTick = tick()
            local DeltaTime = CurrentTick - self.LastTick

            if typeof(self.LastPosition) == "Vector3" and DeltaTime > 0.001 then
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

        self.IsRunning = false
    end)
end

function BallTracker:Stop()
    self.IsRunning = false
end

local LastParryTime = 0
local PositionBuffer = {}
local TimeBuffer = {}
local InterpolatedRadians = 0
local LastWarpTick = tick()

local function IsValidNumber(Value)
    return type(Value) == "number" and Value == Value and Value ~= math.huge and Value ~= -math.huge
end

local function IsValidVector3(Value)
    return typeof(Value) == "Vector3"
        and IsValidNumber(Value.X)
        and IsValidNumber(Value.Y)
        and IsValidNumber(Value.Z)
end

local function IsValidAddress(Value)
    return type(Value) == "number" and Value > 0xFFF
end

local function LinearInterpolation(Start, End, Alpha)
    if not IsValidNumber(Start) or not IsValidNumber(End) or not IsValidNumber(Alpha) then
        return IsValidNumber(End) and End or 0
    end
    return Start + (End - Start) * Alpha
end

local function ValidateTarget()
    local Character = LocalPlayer.Character
    if not Character or typeof(Character) ~= "Instance" then return false end

    local Highlight = Character:FindFirstChild("Highlight")
    if not Highlight or typeof(Highlight) ~= "Instance" then return false end

    local Address = Highlight.Address
    if not IsValidAddress(Address) then return false end
    if type(memory_read) ~= "function" then return false end

    local MemoryValue = memory_read("float", Address + 228)
    return IsValidNumber(MemoryValue) and MemoryValue > 0.3 and MemoryValue < 0.4
end

local function ExecuteParry()
    if type(keypress) ~= "function" or type(keyrelease) ~= "function" then return false end
    keypress(70)
    keyrelease(70)
    return true
end

local function GetPlayerRootPosition()
    local Character = LocalPlayer.Character
    if not Character or typeof(Character) ~= "Instance" then return nil end

    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    if not RootPart or typeof(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") then return nil end

    local Position = RootPart.Position
    if not IsValidVector3(Position) then return nil end

    return Position
end

local function CalculateDistance(PointA, PointB)
    if not IsValidVector3(PointA) or not IsValidVector3(PointB) then return math.huge end

    local DeltaX = PointA.X - PointB.X
    local DeltaY = PointA.Y - PointB.Y
    local DeltaZ = PointA.Z - PointB.Z
    return math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY + DeltaZ * DeltaZ)
end

local function GetNetworkPing()
    if type(GetPingValue) ~= "function" then return 50 end

    local Ping = GetPingValue()
    if not IsValidNumber(Ping) or Ping < 0 then return 50 end
    return Ping
end

local function ProcessBallUpdate(CurrentPosition, PreviousPosition, StepVelocity, DeltaTime, StepDistance)
    if not AutoParryEnabled then return end
    if not IsValidVector3(CurrentPosition) or not IsValidVector3(PreviousPosition) then return end
    if not IsValidNumber(StepVelocity) or not IsValidNumber(DeltaTime) or not IsValidNumber(StepDistance) then return end

    if not ValidateTarget() then
        table.clear(PositionBuffer)
        table.clear(TimeBuffer)
        InterpolatedRadians = 0
        return
    end

    if StepVelocity < MinSpeedLimit or StepVelocity > MaxSpeedLimit then return end

    local TargetPosition = GetPlayerRootPosition()
    if not TargetPosition then return end

    PositionBuffer[#PositionBuffer + 1] = CurrentPosition
    TimeBuffer[#TimeBuffer + 1] = tick()

    if #PositionBuffer > BufferSize then
        table.remove(PositionBuffer, 1)
        table.remove(TimeBuffer, 1)
    end

    if #PositionBuffer < 5 then return end

    local FirstPosition = PositionBuffer[1]
    local LastPosition = PositionBuffer[#PositionBuffer]
    local FirstTick = TimeBuffer[1]
    local LastTick = TimeBuffer[#TimeBuffer]

    if not IsValidVector3(FirstPosition) or not IsValidVector3(LastPosition) then return end
    if not IsValidNumber(FirstTick) or not IsValidNumber(LastTick) then return end

    local TotalDeltaTime = LastTick - FirstTick
    if TotalDeltaTime < 0.01 then return end

    local AverageSpeed = CalculateDistance(LastPosition, FirstPosition) / TotalDeltaTime
    if not IsValidNumber(AverageSpeed) or AverageSpeed < MinSpeedLimit or AverageSpeed > MaxSpeedLimit then return end

    local DistanceToPlayer = CalculateDistance(CurrentPosition, TargetPosition)
    if not IsValidNumber(DistanceToPlayer) then return end

    local VelocityX = (LastPosition.X - FirstPosition.X) / TotalDeltaTime
    local VelocityY = (LastPosition.Y - FirstPosition.Y) / TotalDeltaTime
    local VelocityZ = (LastPosition.Z - FirstPosition.Z) / TotalDeltaTime
    local VelocityVector = Vector3.new(VelocityX, VelocityY, VelocityZ)

    if not IsValidVector3(VelocityVector) or VelocityVector.Magnitude < 0.001 then return end

    local DirectionVector = VelocityVector.Unit
    local VectorToPlayer = TargetPosition - CurrentPosition

    if not IsValidVector3(VectorToPlayer) or VectorToPlayer.Magnitude < 0.001 then return end

    local PlayerDirection = VectorToPlayer.Unit
    local DotProduct = PlayerDirection:Dot(DirectionVector)
    if not IsValidNumber(DotProduct) then return end

    local DistanceAlongTrajectory = VectorToPlayer:Dot(DirectionVector)
    if not IsValidNumber(DistanceAlongTrajectory) then return end

    local ProjectedPosition = CurrentPosition + DirectionVector * DistanceAlongTrajectory
    local MissDistance = CalculateDistance(TargetPosition, ProjectedPosition)
    local WillHitPhysically = MissDistance <= 5.5 and DistanceAlongTrajectory > 0

    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Exclude

    local Character = LocalPlayer.Character
    RayParams.FilterDescendantsInstances = Character and {Character} or {}

    local RayDirection = CurrentPosition - TargetPosition
    local RayResult = Workspace:Raycast(TargetPosition, RayDirection, RayParams)
    local IsObstructed = false

    if RayResult and RayResult.Instance then
        local HitInstance = RayResult.Instance
        if typeof(HitInstance) == "Instance"
            and HitInstance:IsA("BasePart")
            and HitInstance.CanCollide
            and HitInstance.Name ~= "Part"
            and not HitInstance:IsA("MeshPart")
        then
            IsObstructed = true
        end
    end

    local NetworkPing = GetNetworkPing()
    local ReachTime = (DistanceToPlayer / AverageSpeed) - (NetworkPing / 1000)
    local DotThreshold = 0.55 - (NetworkPing / 1000)
    local SpeedThreshold = math.min(AverageSpeed / 100, 40)
    local AngleThreshold = 40 * math.max(DotProduct, 0)
    local DistanceThreshold = 15 - math.min(DistanceToPlayer / 1000, 15) + AngleThreshold + SpeedThreshold

    if AverageSpeed > 100 and ReachTime > NetworkPing / 10 then
        DistanceThreshold = math.max(DistanceThreshold - 15, 15)
    end

    local ClampedDot = math.clamp(DotProduct, -1, 1)
    local CalculatedRadians = math.rad(math.asin(ClampedDot))
    InterpolatedRadians = LinearInterpolation(InterpolatedRadians, CalculatedRadians, 0.8)

    local IsCurved = false

    if DistanceToPlayer >= DistanceThreshold then
        if InterpolatedRadians < 0.018 then
            LastWarpTick = tick()
        end

        if tick() - LastWarpTick < ReachTime / 1.5 then
            IsCurved = true
        else
            IsCurved = DotProduct < DotThreshold
        end
    end

    if not WillHitPhysically or IsObstructed then
        IsCurved = true
    end

    if IsCurved then return end

    local TimeToImpact = DistanceToPlayer / AverageSpeed
    if DotProduct <= 0.65 or not WillHitPhysically then return end
    if TimeToImpact > TTIThreshold then return end
    if tick() - LastParryTime < 0.01 then return end

    if ExecuteParry() then
        LastParryTime = tick()
    end
end

local ActiveTrackers = {}

local function UpdateWorkspaceScans()
    local Children = Workspace:GetChildren()
    if type(Children) ~= "table" then return end

    for _, Object in ipairs(Children) do
        if Object
            and typeof(Object) == "Instance"
            and Object:IsA("MeshPart")
            and Object.Name == "Part"
            and not ActiveTrackers[Object]
        then
            local Tracker = BallTracker.New(Object, ProcessBallUpdate)
            if Tracker then
                Tracker:Start()
                ActiveTrackers[Object] = Tracker
            end
        end
    end

    for BallObject, Tracker in pairs(ActiveTrackers) do
        if not BallObject
            or typeof(BallObject) ~= "Instance"
            or not BallObject.Parent
        then
            if Tracker and type(Tracker.Stop) == "function" then
                Tracker:Stop()
            end
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
