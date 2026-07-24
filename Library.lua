task.wait(3.5)

local RuntimeConfig = { LibraryUrl =
    "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/Library.lua",
    MinimumLibrarySize = 128 }
if type(table.freeze) == "function" then table.freeze(RuntimeConfig) end

local function FailRuntime(Message) error("radiant.rip: " .. tostring(Message), 0) end

local function ValidateRuntime()
    if typeof(game) ~= "Instance" then FailRuntime("invalid game environment") end
    if type(loadstring) ~= "function" then FailRuntime("loadstring is unavailable") end
    local RequiredFunctions = { { Name = "isfolder", Value = isfolder }, { Name = "makefolder", Value = makefolder }, { Name = "writefile", Value = writefile }, { Name = "readfile", Value =
        readfile }, { Name = "isfile", Value = isfile } }
    for Unused, Requirement in ipairs(RequiredFunctions) do
        if type(Requirement.Value) ~= "function" then FailRuntime(Requirement.Name .. " is unavailable") end
    end
end

local function LoadRadiantLibrary()
    local RequestSuccess, LibrarySource = pcall(function() return game:HttpGet(RuntimeConfig.LibraryUrl) end)
    if not RequestSuccess then FailRuntime("library request failed: " .. tostring(LibrarySource)) end
    if type(LibrarySource) ~= "string" or #LibrarySource < RuntimeConfig.MinimumLibrarySize then FailRuntime("library response is invalid") end
    local LibraryChunk, CompileError = loadstring(LibrarySource)
    LibrarySource = nil
    if type(LibraryChunk) ~= "function" then FailRuntime("library compile failed: " .. tostring(CompileError)) end
    local ExecuteSuccess, LibraryResult = pcall(LibraryChunk)
    LibraryChunk = nil
    if not ExecuteSuccess then FailRuntime("library execution failed: " .. tostring(LibraryResult)) end
    if type(LibraryResult) ~= "table" or type(LibraryResult.Window) ~= "function" or type(LibraryResult.Notification) ~= "function" then FailRuntime("library API is incomplete") end
    return LibraryResult
end

ValidateRuntime()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local Mouse = LocalPlayer:GetMouse()
local VirtualInputManager = nil
pcall(function() VirtualInputManager = game:GetService("VirtualInputManager") end)
local LastGarbageCollectorStep = 0

local function RadiantStepGC(Budget)
    if type(collectgarbage) ~= "function" or os.clock() - LastGarbageCollectorStep < 12 then return end
    LastGarbageCollectorStep = os.clock()
    task.defer(function() pcall(collectgarbage, "step", math.clamp(tonumber(Budget) or 32, 16, 64)) end)
end

local function RadiantReleaseBuffer(Buffer)
    if type(Buffer) == "table" then
        if table.clear then
            pcall(table.clear, Buffer)
        else
            for Key in pairs(Buffer) do Buffer[Key] = nil end
        end
    end
    Buffer = nil
    RadiantStepGC(160)
end

local RadiantGarbageScanner = { Running = false }

local function RadiantScanGarbage(IncludeTables, Visitor, BatchSize)
    if type(getgc) ~= "function" or type(Visitor) ~= "function" then return false end
    if RadiantGarbageScanner.Running then
        local WaitStarted = os.clock()
        repeat
            task.wait()
        until not RadiantGarbageScanner.Running or os.clock() - WaitStarted >= 2
        if RadiantGarbageScanner.Running then return false end
    end
    RadiantGarbageScanner.Running = true
    local Success, Objects = pcall(getgc, IncludeTables == true)
    if not Success or type(Objects) ~= "table" then Success, Objects = pcall(getgc) end
    if not Success or type(Objects) ~= "table" then
        RadiantGarbageScanner.Running = false
        return false
    end
    BatchSize = math.max(math.floor(tonumber(BatchSize) or 384), 32)
    local ProcessSuccess = pcall(function()
        local ObjectCount = #Objects
        local BatchCount = 0
        if ObjectCount > 0 then
            for Index = 1, ObjectCount do
                Visitor(Objects[Index])
                BatchCount = BatchCount + 1
                if BatchCount >= BatchSize then
                    BatchCount = 0
                    task.wait()
                end
            end
        else
            for Unused, Object in pairs(Objects) do
                Visitor(Object)
                BatchCount = BatchCount + 1
                if BatchCount >= BatchSize then
                    BatchCount = 0
                    task.wait()
                end
            end
        end
    end)
    RadiantReleaseBuffer(Objects)
    RadiantGarbageScanner.Running = false
    RadiantStepGC(32)
    return ProcessSuccess
end

function SendKeyPress(KeyCode, HoldDuration)
    HoldDuration = tonumber(HoldDuration) or 0.03
    if VirtualInputManager then
        local Success = pcall(function()
            VirtualInputManager:SendKeyEvent(true, KeyCode, false, game)
            task.wait(math.max(HoldDuration, 0))
            VirtualInputManager:SendKeyEvent(false, KeyCode, false, game)
        end)
        if Success then return true end
    end
    if type(keypress) == "function" and type(keyrelease) == "function" then
        local Success = pcall(function()
            keypress(KeyCode.Value)
            task.wait(math.max(HoldDuration, 0))
            keyrelease(KeyCode.Value)
        end)
        if Success then return true end
    end
    return false
end

function ActivateGuiButton(Button)
    if not Button or not Button.Parent or not Button:IsA("GuiButton") then return false end
    if type(firesignal) == "function" then
        local Triggered = false
        pcall(function()
            firesignal(Button.Activated)
            Triggered = true
        end)
        pcall(function()
            firesignal(Button.MouseButton1Click)
            Triggered = true
        end)
        if Triggered then return true end
    end
    if VirtualInputManager then
        local Position = Button.AbsolutePosition
        local Size = Button.AbsoluteSize
        local X = Position.X + Size.X * 0.5
        local Y = Position.Y + Size.Y * 0.5
        return pcall(function()
            VirtualInputManager:SendMouseButtonEvent(X, Y, 0, true, game, 0)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(X, Y, 0, false, game, 0)
        end)
    end
    return false
end

local Library = LoadRadiantLibrary()
local UiFont = Library.Font or Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
local ScriptStartedAt = os.clock()

local ThemePresets = { ["Radiant Emerald"] = { ["Background"] = Color3.fromRGB(9, 11, 12), ["Inline"] = Color3.fromRGB(13, 16, 17), ["Page Background"] = Color3.fromRGB(17, 20, 21),
    ["Border"] = Color3.fromRGB(3, 5, 5), ["Outline"] = Color3.fromRGB(39, 45, 45), ["Accent"] = Color3.fromRGB(54, 218, 145), ["Element"] = Color3.fromRGB(23, 27, 28), ["Hovered Element"] =
    Color3.fromRGB(31, 37, 37), ["Text"] = Color3.fromRGB(226, 232, 230), ["Text Border"] = Color3.fromRGB(0, 0, 0) }, ["Deep Emerald"] = { ["Background"] = Color3.fromRGB(4, 10, 8),
    ["Inline"] = Color3.fromRGB(7, 17, 13), ["Page Background"] = Color3.fromRGB(8, 22, 17), ["Border"] = Color3.fromRGB(1, 6, 4), ["Outline"] = Color3.fromRGB(16, 46, 35), ["Accent"] =
    Color3.fromRGB(22, 190, 123), ["Element"] = Color3.fromRGB(11, 29, 22), ["Hovered Element"] = Color3.fromRGB(16, 40, 31), ["Text"] = Color3.fromRGB(220, 240, 231), ["Text Border"] =
    Color3.fromRGB(0, 0, 0) }, ["Matrix"] = { ["Background"] = Color3.fromRGB(3, 8, 4), ["Inline"] = Color3.fromRGB(5, 16, 7), ["Page Background"] = Color3.fromRGB(7, 23, 10), ["Border"] =
    Color3.fromRGB(0, 5, 1), ["Outline"] = Color3.fromRGB(16, 55, 22), ["Accent"] = Color3.fromRGB(82, 255, 96), ["Element"] = Color3.fromRGB(10, 31, 13), ["Hovered Element"] =
    Color3.fromRGB(17, 48, 21), ["Text"] = Color3.fromRGB(224, 248, 226), ["Text Border"] = Color3.fromRGB(0, 0, 0) } }

local function ApplyThemePreset(Name)
    local Preset = ThemePresets[Name]
    if not Preset then return end
    for Index, Color in pairs(Preset) do
        Library.Theme[Index] = Color
        if Library.ChangeTheme then Library:ChangeTheme(Index, Color) end
    end
end

ApplyThemePreset("Radiant Emerald")
Library.Folders.Directory = "radiant.rip"
Library.Folders.Configs = "radiant.rip/Configs"
if not isfolder(Library.Folders.Directory) then makefolder(Library.Folders.Directory) end
if not isfolder(Library.Folders.Configs) then makefolder(Library.Folders.Configs) end

local function GetCamera() return workspace.CurrentCamera or workspace:FindFirstChildOfClass("Camera") end

local VisualState = { Player = { Enabled = false, TeamCheck = false, MaxDistance = 1200, Boxes = true, BoxStyle = "Corners", Fill = false, Names = true, HealthBar = true, HealthText = false,
    Distance = true, Weapon = true, Tracers = false, TracerStyle = "Straight", TracerOrigin = "Bottom", TracerEnd = "Feet", TracerThickness = 1, TracerTransparency = 0, BoxColor =
    Color3.fromRGB(54, 218, 145), OutlineColor = Color3.fromRGB(4, 7, 6), FillColor = Color3.fromRGB(28, 82, 61), TextColor = Color3.fromRGB(232, 238, 236), TracerColor = Color3.fromRGB(54,
    218, 145), HealthLowColor = Color3.fromRGB(235, 72, 72), HealthHighColor = Color3.fromRGB(73, 232, 155), FillTransparency = 0.82, TextSize = 13, UpdateInterval = 1 / 60, Objects = {},
    List = {}, Chams = { Enabled = false, ThroughWalls = true, FillColor = Color3.fromRGB(54, 218, 145), OutlineColor = Color3.fromRGB(218, 255, 239), FillTransparency = 0.58,
    OutlineTransparency = 0.12, GlowEnabled = false, GlowColor = Color3.fromRGB(75, 255, 177), GlowTransparency = 0.34 } }, World = { Enabled = false, Ambient = Color3.fromRGB(96, 112, 104),
    OutdoorAmbient = Color3.fromRGB(76, 92, 84), Brightness = 2.4, ClockTime = 14, FogEnabled = false, FogColor = Color3.fromRGB(88, 104, 96), FogDistance = 1500, Saturation = 0, Contrast =
    0.05, TintColor = Color3.fromRGB(255, 255, 255), Bloom = false, Original = nil, ColorCorrection = nil, BloomEffect = nil, Applying = false, Bound = false, RenderStepName =
    "RadiantWorldOverride" }, WorldESP = { Safes = false, Cash = false, SafeColor = Color3.fromRGB(73, 232, 155), CashColor = Color3.fromRGB(255, 208, 92), BrokenColor = Color3.fromRGB(235,
    72, 72), MaxDistance = 1500, Objects = {}, LastScan = 0 }, Connection = nil, PlayerAddedConnection = nil, PlayerRemovingConnection = nil, WorldCharactersBound = false, PlayerClock = 0,
    ChamsClock = 0, WorldClock = 0, CacheClock = 0, Initialized = false }
VisualState.Snapline = {
    Enabled = false,
    Source = "Combat Target",
    TargetPart = "Head",
    Style = "Straight",
    Thickness = 1,
    Transparency = 0,
    Color = Color3.fromRGB(54, 218, 145),
    UpdateInterval = 1 / 60,
    Clock = 0,
    Line = nil,
    Curve = {}
}

VisualState.Widgets = {
    ESPPreviewEnabled = true,
    TargetHUDEnabled = true,
    TargetHUDFollowTarget = false,
    MenuWindow = nil,
    ESPPreview = nil,
    TargetHUD = nil,
    UpdateConnection = nil,
    LastTarget = nil,
    LastMode = nil,
    LastHealth = -1,
    LastMaxHealth = -1,
    LastInfo = nil
}

AutoPickupMoneyEnabled = false
local MoneyCooldown = false
AutoPickupMoneyCoroutine = nil
NoFailLockpickEnabled = false
local LockpickAddedConnection = nil
OpenNearbyDoorsEnabled = false
UnlockNearbyDoorsEnabled = false
NearbyDoorInteractionCoroutine = nil
FlyEnabled = false
FlyConnection = nil
local FlyMethod = "Velocity"
NoclipEnabled = false
NoclipConnection = nil
local NoclipCharacterConnection = nil
local NoclipDescendantConnection = nil
local NoclipParts = setmetatable({}, { __mode = "k" })
local NoclipOriginalCollision = setmetatable({}, { __mode = "k" })
InvisibilityEnabled = false
CrowbarAuraEnabled = false
CrowbarAuraCoroutine = nil
MeleeAuraEnabled = false
MeleeAuraCoroutine = nil
ArmsChamsEnabled = false
ArmsChamsSettings = { ArmColor = Color3.fromRGB(54, 218, 145), Transparency = 0, Material = "ForceField", Connection = nil, Original = setmetatable({}, { __mode = "k" }), CurrentParts =
    setmetatable({}, { __mode = "k" }), CurrentViewModel = nil, Clock = 0 }
FinishAuraEnabled = false
FinishAuraCoroutine = nil
InfStaminaEnabled = false
InfStaminaCoroutine = nil
NoFallDamageEnabled = false
RageBotEnabled = false
RageBotCoroutine = nil
RageBotFOVConnection = nil
RageBotStickyTarget = nil
RageBotCurrentTarget = nil
RageBotSettings = { CheckTeam = false, CheckWhitelist = false, AutoReload = true, TargetMode = "Nearest", FOV = 150, ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 255, 255), Prediction = 0.14, WallCheck = true, Sticky = false, OriginMode = "Camera", FOVOrigin = "Center", TargetPart = "Head",
    Resolver = true, ResolverMode = "Adaptive", ResolverStrength = 1, ResolverMaxSpeed = 190, ResolverDesyncThreshold = 18,
    BulletDirection = "Up", BulletDirectionOffset = 70, MaxDistance = 1200, ServerTickRate = 60, BaseDelay = 0.25, ConfirmationWindow = 0.28, ReloadRetryDelay = 0.45, ReloadTimeout = 3.5 }
local RageShotState = { NextServerShot = 0, LastTool = nil, LearnedDamage = setmetatable({}, { __mode = "k" }), PendingTarget = nil, PendingHealth = nil, PendingTime = 0 }
local RageReloadState = { Tool = nil, StartedAt = 0, LastRequest = 0, PreviousAmmo = 0, InProgress = false }
WhitelistTable = {}

ResolverState = {
    History = setmetatable({}, { __mode = "k" }),
    PoseHistory = setmetatable({}, { __mode = "k" }),
    MaximumSamples = 11,
    MinimumDelta = 1 / 240,
    MaximumDelta = 0.30,
    TeleportDistance = 48,
    MaximumAcceleration = 720,
    ReplicatedPoseTrustTime = 0.42,
    ReplicatedPoseDecay = 2.6,
    ReplicatedPoseMaximumGap = 0.45
}

function ResolverClampVector(Value, MaximumMagnitude)
    if typeof(Value) ~= "Vector3" then return Vector3.zero end

    local Magnitude = Value.Magnitude
    MaximumMagnitude = math.max(tonumber(MaximumMagnitude) or 190, 1)

    if Magnitude > MaximumMagnitude and Magnitude > 0 then
        return Value.Unit * MaximumMagnitude
    end

    return Value
end

function ResolverMedianNumber(Values)
    if type(Values) ~= "table" or #Values == 0 then return 0 end

    local Sorted = table.clone and table.clone(Values) or {}
    if not table.clone then
        for Index, Value in ipairs(Values) do Sorted[Index] = Value end
    end

    table.sort(Sorted)

    local Count = #Sorted
    local Middle = math.floor((Count + 1) * 0.5)

    if Count % 2 == 0 then
        return (Sorted[Middle] + Sorted[Middle + 1]) * 0.5
    end

    return Sorted[Middle]
end

function ResolverMedianVelocity(Samples)
    if type(Samples) ~= "table" or #Samples == 0 then return Vector3.zero end

    local XValues, YValues, ZValues = {}, {}, {}

    for Index, Sample in ipairs(Samples) do
        local Velocity = Sample and Sample.Velocity

        if typeof(Velocity) == "Vector3" then
            XValues[#XValues + 1] = Velocity.X
            YValues[#YValues + 1] = Velocity.Y
            ZValues[#ZValues + 1] = Velocity.Z
        end
    end

    if #XValues == 0 then return Vector3.zero end

    return Vector3.new(
        ResolverMedianNumber(XValues),
        ResolverMedianNumber(YValues),
        ResolverMedianNumber(ZValues)
    )
end

function ResolverGetRoot(Character)
    if not Character then return nil end

    return Character:FindFirstChild("HumanoidRootPart")
        or Character:FindFirstChild("LowerTorso")
        or Character:FindFirstChild("Torso")
        or Character:FindFirstChild("UpperTorso")
end

function ResolverResetData(Data, Character, Root, CurrentTime)
    Data.Character = Character
    Data.Root = Root
    Data.LastPosition = Root and Root.Position or Vector3.zero
    Data.LastTime = CurrentTime or os.clock()
    Data.Samples = {}
    Data.ObservedVelocity = Vector3.zero
    Data.SmoothedVelocity = Vector3.zero
    Data.Acceleration = Vector3.zero
    Data.DesyncScore = 0
    Data.IsDesynced = false
    Data.LastReportedVelocity = Root and Root.AssemblyLinearVelocity or Vector3.zero
    return Data
end

function ResolverGetData(Player, Character)
    if not Player then return nil end

    local Data = ResolverState.History[Player]

    if type(Data) ~= "table" then
        Data = {}
        ResolverState.History[Player] = Data
    end

    local Root = ResolverGetRoot(Character)

    if Data.Character ~= Character or Data.Root ~= Root or not Data.LastTime then
        ResolverResetData(Data, Character, Root, os.clock())
    end

    return Data
end

function ResolverObservePlayer(Player, Character, Settings)
    if not Player or not Character then return nil end

    local Root = ResolverGetRoot(Character)
    if not Root or not Root:IsA("BasePart") then return nil end

    local Data = ResolverGetData(Player, Character)
    local CurrentTime = os.clock()
    local CurrentPosition = Root.Position
    local ReportedVelocity = Root.AssemblyLinearVelocity or Root.Velocity or Vector3.zero
    local MaximumSpeed = math.max(tonumber(Settings and Settings.ResolverMaxSpeed) or 190, 40)
    local Threshold = math.max(tonumber(Settings and Settings.ResolverDesyncThreshold) or 18, 2)
    local DeltaTime = CurrentTime - (Data.LastTime or CurrentTime)

    if DeltaTime < ResolverState.MinimumDelta then
        Data.LastReportedVelocity = ReportedVelocity
        return Data
    end

    if DeltaTime > ResolverState.MaximumDelta then
        return ResolverResetData(Data, Character, Root, CurrentTime)
    end

    local PositionDelta = CurrentPosition - (Data.LastPosition or CurrentPosition)
    local RawObservedVelocity = PositionDelta / DeltaTime
    local Teleported = PositionDelta.Magnitude > ResolverState.TeleportDistance
        or RawObservedVelocity.Magnitude > MaximumSpeed * 3.5

    if Teleported then
        ResolverResetData(Data, Character, Root, CurrentTime)
        Data.LastReportedVelocity = ReportedVelocity
        return Data
    end

    local ObservedVelocity = ResolverClampVector(RawObservedVelocity, MaximumSpeed)
    local Sample = { Velocity = ObservedVelocity, Time = CurrentTime }

    Data.Samples[#Data.Samples + 1] = Sample
    while #Data.Samples > ResolverState.MaximumSamples do table.remove(Data.Samples, 1) end

    local MedianVelocity = ResolverMedianVelocity(Data.Samples)
    local PreviousSmoothed = Data.SmoothedVelocity or MedianVelocity
    local SmoothAlpha = 1 - math.exp(-13 * DeltaTime)
    local SmoothedVelocity = PreviousSmoothed:Lerp(MedianVelocity, math.clamp(SmoothAlpha, 0.08, 0.85))
    local Acceleration = ResolverClampVector(
        (SmoothedVelocity - PreviousSmoothed) / math.max(DeltaTime, ResolverState.MinimumDelta),
        ResolverState.MaximumAcceleration
    )

    local ReportedClamped = ResolverClampVector(ReportedVelocity, MaximumSpeed * 1.5)
    local ObservedSpeed = SmoothedVelocity.Magnitude
    local ReportedSpeed = ReportedClamped.Magnitude
    local SpeedDifference = math.abs(ObservedSpeed - ReportedSpeed)
    local DirectionMismatch = 0

    if ObservedSpeed > 2 and ReportedSpeed > 2 then
        local Dot = math.clamp(SmoothedVelocity.Unit:Dot(ReportedClamped.Unit), -1, 1)
        DirectionMismatch = math.deg(math.acos(Dot))
    end

    local Suspicious = ReportedVelocity.Magnitude > MaximumSpeed * 1.35
        or ObservedSpeed > 4 and ReportedSpeed < 0.75
        or ReportedSpeed > 8 and ObservedSpeed < 0.75
        or SpeedDifference > Threshold
        or DirectionMismatch > 72

    local TargetScore = Suspicious and 1 or 0
    Data.DesyncScore = (Data.DesyncScore or 0) + (TargetScore - (Data.DesyncScore or 0)) * math.clamp(DeltaTime * 9, 0.08, 0.75)
    Data.IsDesynced = Data.DesyncScore >= 0.46
    Data.ObservedVelocity = ObservedVelocity
    Data.SmoothedVelocity = ResolverClampVector(SmoothedVelocity, MaximumSpeed)
    Data.Acceleration = Acceleration
    Data.LastPosition = CurrentPosition
    Data.LastTime = CurrentTime
    Data.LastReportedVelocity = ReportedVelocity

    return Data
end

function ResolverGetMovementVelocity(Player, Character, Settings)
    local Root = ResolverGetRoot(Character)
    if not Root then return Vector3.zero, nil end

    local Data = ResolverObservePlayer(Player, Character, Settings)
    local MaximumSpeed = math.max(tonumber(Settings and Settings.ResolverMaxSpeed) or 190, 40)
    local Mode = tostring(Settings and Settings.ResolverMode or "Adaptive")
    local Reported = ResolverClampVector(Root.AssemblyLinearVelocity or Root.Velocity or Vector3.zero, MaximumSpeed)
    local Observed = Data and Data.SmoothedVelocity or Reported
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local MoveDirection = Humanoid and Humanoid.MoveDirection or Vector3.zero
    local WalkSpeed = Humanoid and math.max(tonumber(Humanoid.WalkSpeed) or 16, 0) or 16
    local Directed = ResolverClampVector(Vector3.new(MoveDirection.X * WalkSpeed, Observed.Y, MoveDirection.Z * WalkSpeed), MaximumSpeed)
    local Resolved = Reported

    if Mode == "Position Delta" then
        Resolved = Observed
    elseif Mode == "Move Direction" then
        Resolved = Directed
    elseif Mode == "Reported" then
        Resolved = Reported
    else
        local Score = Data and Data.DesyncScore or 0

        if Data and Data.IsDesynced then
            Resolved = Observed.Magnitude > 0.35 and Observed or Directed
        elseif Reported.Magnitude < 0.5 and Observed.Magnitude > 2 then
            Resolved = Observed
        elseif Observed.Magnitude < 0.5 and Reported.Magnitude > 8 then
            Resolved = Directed.Magnitude > 0.5 and Directed or Vector3.zero
        else
            local Blend = math.clamp(0.30 + Score * 0.70, 0.30, 1)
            Resolved = Reported:Lerp(Observed, Blend)
        end
    end

    return ResolverClampVector(Resolved, MaximumSpeed), Data
end

function ResolverIsFiniteNumber(Value)
    return type(Value) == "number"
        and Value == Value
        and Value > -1000000
        and Value < 1000000
end

function ResolverIsFiniteVector(Value)
    return typeof(Value) == "Vector3"
        and ResolverIsFiniteNumber(Value.X)
        and ResolverIsFiniteNumber(Value.Y)
        and ResolverIsFiniteNumber(Value.Z)
end

function ResolverGetRigName(Character)
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

    if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R6 then
        return "R6"
    end

    return "R15"
end

function ResolverGetBodyScale(Character)
    local RigName = ResolverGetRigName(Character)
    local Values = {}

    local function AddScale(PartName, ExpectedHeight)
        local Part = Character and Character:FindFirstChild(PartName)

        if Part and Part:IsA("BasePart") and ResolverIsFiniteVector(Part.Size) then
            local Height = Part.Size.Y

            if Height > 0.2 and Height < 8 then
                Values[#Values + 1] = Height / ExpectedHeight
            end
        end
    end

    if RigName == "R6" then
        AddScale("Torso", 2)
        AddScale("Head", 1)
    else
        AddScale("LowerTorso", 1.6)
        AddScale("UpperTorso", 1.6)
        AddScale("Head", 1)
    end

    local Scale = #Values > 0 and ResolverMedianNumber(Values) or 1
    return math.clamp(Scale, 0.65, 1.65)
end

function ResolverGetFallbackPartOffset(Character, PartName, Scale)
    local RigName = ResolverGetRigName(Character)
    Scale = tonumber(Scale) or 1

    if PartName == "HumanoidRootPart" then
        return Vector3.zero
    end

    if RigName == "R6" then
        local Offsets = {
            Torso = Vector3.new(0, 0, 0),
            Head = Vector3.new(0, 1.5, 0),
            ["Left Arm"] = Vector3.new(-1.5, 0, 0),
            ["Right Arm"] = Vector3.new(1.5, 0, 0),
            ["Left Leg"] = Vector3.new(-0.5, -2, 0),
            ["Right Leg"] = Vector3.new(0.5, -2, 0)
        }

        return (Offsets[PartName] or Vector3.zero) * Scale
    end

    local Offsets = {
        LowerTorso = Vector3.new(0, 0.35, 0),
        UpperTorso = Vector3.new(0, 1.35, 0),
        Head = Vector3.new(0, 2.65, 0),
        LeftUpperArm = Vector3.new(-1.15, 1.45, 0),
        RightUpperArm = Vector3.new(1.15, 1.45, 0),
        LeftLowerArm = Vector3.new(-1.55, 0.65, 0),
        RightLowerArm = Vector3.new(1.55, 0.65, 0),
        LeftHand = Vector3.new(-1.65, 0.05, 0),
        RightHand = Vector3.new(1.65, 0.05, 0),
        LeftUpperLeg = Vector3.new(-0.45, -0.75, 0),
        RightUpperLeg = Vector3.new(0.45, -0.75, 0),
        LeftLowerLeg = Vector3.new(-0.45, -1.85, 0),
        RightLowerLeg = Vector3.new(0.45, -1.85, 0),
        LeftFoot = Vector3.new(-0.45, -2.75, -0.1),
        RightFoot = Vector3.new(0.45, -2.75, -0.1)
    }

    return (Offsets[PartName] or Vector3.zero) * Scale
end

function ResolverGetStableRootLook(Root)
    local Look = Root and Root.CFrame.LookVector or Vector3.new(0, 0, -1)
    local FlatLook = Vector3.new(Look.X, 0, Look.Z)

    if FlatLook.Magnitude < 0.05 then
        FlatLook = Vector3.new(0, 0, -1)
    else
        FlatLook = FlatLook.Unit
    end

    return FlatLook
end

function ResolverEstimateRootPosition(Character, Root, Scale)
    if not Root then return nil end

    local RigName = ResolverGetRigName(Character)
    local Candidates = { Root.Position, Root.Position, Root.Position }
    local PartNames = RigName == "R6"
        and { "Torso", "Head", "Left Leg", "Right Leg" }
        or { "LowerTorso", "UpperTorso", "Head", "LeftUpperLeg", "RightUpperLeg" }

    for _, PartName in ipairs(PartNames) do
        local Part = Character:FindFirstChild(PartName)

        if Part and Part:IsA("BasePart") and ResolverIsFiniteVector(Part.Position) then
            local SizeMagnitude = Part.Size.Magnitude

            if SizeMagnitude > 0.3 and SizeMagnitude < 12 * Scale then
                Candidates[#Candidates + 1] = Part.Position - ResolverGetFallbackPartOffset(Character, PartName, Scale)
            end
        end
    end

    local XValues, YValues, ZValues = {}, {}, {}

    for _, Candidate in ipairs(Candidates) do
        XValues[#XValues + 1] = Candidate.X
        YValues[#YValues + 1] = Candidate.Y
        ZValues[#ZValues + 1] = Candidate.Z
    end

    local Median = Vector3.new(
        ResolverMedianNumber(XValues),
        ResolverMedianNumber(YValues),
        ResolverMedianNumber(ZValues)
    )

    local Cluster = {}
    local ClusterRadius = math.max(2.4 * Scale, 1.8)

    for _, Candidate in ipairs(Candidates) do
        if (Candidate - Median).Magnitude <= ClusterRadius then
            Cluster[#Cluster + 1] = Candidate
        end
    end

    if #Cluster < 2 then return Root.Position end

    local Sum = Vector3.zero

    for _, Candidate in ipairs(Cluster) do
        Sum = Sum + Candidate
    end

    local Estimated = Sum / #Cluster

    if (Root.Position - Estimated).Magnitude <= 3.2 * Scale then
        return Root.Position:Lerp(Estimated, 0.30)
    end

    return Estimated
end

function ResolverGetStableRootCFrame(Character)
    local Root = ResolverGetRoot(Character)
    if not Root then return nil, nil end

    local Scale = ResolverGetBodyScale(Character)
    local Position = ResolverEstimateRootPosition(Character, Root, Scale) or Root.Position
    local Look = ResolverGetStableRootLook(Root)

    return CFrame.lookAt(Position, Position + Look, Vector3.yAxis), Scale
end

function ResolverMotorIsUsable(Motor, Scale)
    if not Motor or not Motor:IsA("Motor6D") then return false end
    if not Motor.Part0 or not Motor.Part1 then return false end

    local C0Position = Motor.C0.Position
    local C1Position = Motor.C1.Position
    local MaximumOffset = math.max(6 * (tonumber(Scale) or 1), 4)

    return ResolverIsFiniteVector(C0Position)
        and ResolverIsFiniteVector(C1Position)
        and C0Position.Magnitude <= MaximumOffset
        and C1Position.Magnitude <= MaximumOffset
end

function ResolverBuildExpectedSkeleton(Character)
    local Root = ResolverGetRoot(Character)
    local RootFrame, Scale = ResolverGetStableRootCFrame(Character)

    if not Root or not RootFrame then return {}, Scale or 1, nil end

    local Expected = { [Root] = RootFrame }
    local Motors = {}

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("Motor6D") and ResolverMotorIsUsable(Object, Scale) then
            Motors[#Motors + 1] = Object
        end
    end

    for _ = 1, 18 do
        local Changed = false

        for _, Motor in ipairs(Motors) do
            local Part0 = Motor.Part0
            local Part1 = Motor.Part1
            local Frame0 = Expected[Part0]
            local Frame1 = Expected[Part1]

            if Frame0 and not Frame1 then
                local Candidate = Frame0 * Motor.C0 * Motor.C1:Inverse()

                if (Candidate.Position - RootFrame.Position).Magnitude <= 12 * Scale then
                    Expected[Part1] = Candidate
                    Changed = true
                end
            elseif Frame1 and not Frame0 then
                local Candidate = Frame1 * Motor.C1 * Motor.C0:Inverse()

                if (Candidate.Position - RootFrame.Position).Magnitude <= 12 * Scale then
                    Expected[Part0] = Candidate
                    Changed = true
                end
            end
        end

        if not Changed then break end
    end

    for _, Object in ipairs(Character:GetChildren()) do
        if Object:IsA("BasePart") and not Expected[Object] then
            local Offset = ResolverGetFallbackPartOffset(Character, Object.Name, Scale)
            Expected[Object] = RootFrame * CFrame.new(Offset)
        end
    end

    return Expected, Scale, RootFrame
end

function ResolverFindBodyMotor(Character, Part)
    if not Character or not Part then return nil end

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("Motor6D") and (Object.Part0 == Part or Object.Part1 == Part) then
            return Object
        end
    end

    return nil
end

function ResolverPartSizeAnomaly(Part, Scale)
    if not Part or not Part:IsA("BasePart") then return true end

    local Size = Part.Size
    if not ResolverIsFiniteVector(Size) then return true end

    local Minimum = math.min(Size.X, Size.Y, Size.Z)
    local Maximum = math.max(Size.X, Size.Y, Size.Z)

    if Minimum < 0.08 or Maximum > 5.5 * Scale then return true end

    if Part.Name == "Head" then
        return Size.Magnitude < 0.45 * Scale or Size.Magnitude > 3.3 * Scale
    end

    if Part.Name == "Torso" or Part.Name == "UpperTorso" or Part.Name == "LowerTorso" then
        return Size.Magnitude < 0.75 * Scale or Size.Magnitude > 5.2 * Scale
    end

    return false
end

function ResolverGetNearestTorso(Character)
    return Character:FindFirstChild("UpperTorso")
        or Character:FindFirstChild("Torso")
        or Character:FindFirstChild("LowerTorso")
        or ResolverGetRoot(Character)
end

function ResolverGetPartAnomalyScore(Character, Part, ExpectedFrame, Expected, Scale, RootFrame)
    if not Part or not ExpectedFrame or not RootFrame then return 5 end

    local ActualPosition = Part.Position
    local ExpectedPosition = ExpectedFrame.Position

    if not ResolverIsFiniteVector(ActualPosition) then return 5 end

    local Score = 0
    local Delta = ActualPosition - ExpectedPosition
    local Distance = Delta.Magnitude
    local HorizontalDistance = Vector2.new(Delta.X, Delta.Z).Magnitude
    local VerticalDistance = math.abs(Delta.Y)

    if Distance > 0.85 * Scale then Score = Score + 0.55 end
    if Distance > 1.65 * Scale then Score = Score + 1.20 end
    if Distance > 3.0 * Scale then Score = Score + 2.50 end
    if HorizontalDistance > 1.15 * Scale then Score = Score + 0.80 end
    if VerticalDistance > 1.35 * Scale then Score = Score + 0.80 end

    if ResolverPartSizeAnomaly(Part, Scale) then
        Score = Score + 2
    end

    local Root = ResolverGetRoot(Character)

    if Root and Part ~= Root then
        local VelocityDifference = ((Part.AssemblyLinearVelocity or Vector3.zero) - (Root.AssemblyLinearVelocity or Vector3.zero)).Magnitude

        if VelocityDifference > 45 then Score = Score + 0.65 end
        if VelocityDifference > 110 then Score = Score + 1.25 end

        if not ResolverFindBodyMotor(Character, Part) then
            Score = Score + 0.70
        end
    end

    local PartName = Part.Name

    if PartName == "Head" then
        local Torso = ResolverGetNearestTorso(Character)
        local ExpectedTorso = Torso and Expected[Torso]
        local TorsoPosition = ExpectedTorso and ExpectedTorso.Position or RootFrame.Position + Vector3.new(0, 1.1 * Scale, 0)
        local HeadOffset = ActualPosition - TorsoPosition
        local Vertical = HeadOffset.Y
        local Horizontal = Vector2.new(HeadOffset.X, HeadOffset.Z).Magnitude
        local MinimumHeadHeight = 0.55 * Scale
        local MaximumHeadHeight = 2.35 * Scale

        if Vertical < MinimumHeadHeight then Score = Score + 2.6 end
        if Vertical > MaximumHeadHeight then Score = Score + 2.6 end
        if Horizontal > 1.25 * Scale then Score = Score + 2 end

        if Torso and Torso:IsA("BasePart") then
            local ActualSeparation = (ActualPosition - Torso.Position).Magnitude
            local OverlapDistance = math.max((Part.Size.Y + Torso.Size.Y) * 0.22, 0.45 * Scale)

            if ActualSeparation < OverlapDistance then
                Score = Score + 3
            end
        end
    elseif PartName == "Torso" or PartName == "UpperTorso" or PartName == "LowerTorso" then
        local RootOffset = ActualPosition - RootFrame.Position

        if Vector2.new(RootOffset.X, RootOffset.Z).Magnitude > 1.8 * Scale then
            Score = Score + 2
        end

        if RootOffset.Y < -1.4 * Scale or RootOffset.Y > 2.9 * Scale then
            Score = Score + 2
        end

        local OtherTorso = PartName == "UpperTorso"
            and Character:FindFirstChild("LowerTorso")
            or PartName == "LowerTorso"
                and Character:FindFirstChild("UpperTorso")
                or nil

        if OtherTorso and OtherTorso:IsA("BasePart") then
            local Separation = (ActualPosition - OtherTorso.Position).Magnitude

            if Separation > 3.1 * Scale or Separation < 0.18 * Scale then
                Score = Score + 2.25
            end
        end
    end

    return Score
end

function ResolverCountSkeletonAnomalies(Character, Expected, Scale, RootFrame)
    local Count = 0
    local Names = ResolverGetRigName(Character) == "R6"
        and { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
        or { "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "RightUpperArm", "LeftUpperLeg", "RightUpperLeg" }

    for _, Name in ipairs(Names) do
        local Part = Character:FindFirstChild(Name)
        local ExpectedFrame = Part and Expected[Part]

        if Part and ExpectedFrame then
            local Score = ResolverGetPartAnomalyScore(Character, Part, ExpectedFrame, Expected, Scale, RootFrame)

            if Score >= 1.25 then
                Count = Count + 1
            end
        end
    end

    return Count
end

function ResolverGetPoseHistory(Part)
    if not Part then return nil end

    local Data = ResolverState.PoseHistory[Part]

    if type(Data) ~= "table" then
        Data = {
            Character = nil,
            Root = nil,
            LastTime = 0,
            LastLocalPosition = nil,
            LastExpectedDelta = nil,
            LastPartPosition = nil,
            LastRootPosition = nil,
            StableTime = 0,
            AnomalyStableTime = 0,
            UnstableTime = 0,
            Trust = 0
        }

        ResolverState.PoseHistory[Part] = Data
    end

    return Data
end

function ResolverResetPoseHistory(Data, Character, Root, CurrentTime, LocalPosition, ExpectedDelta, PartPosition)
    Data.Character = Character
    Data.Root = Root
    Data.LastTime = CurrentTime
    Data.LastLocalPosition = LocalPosition
    Data.LastExpectedDelta = ExpectedDelta
    Data.LastPartPosition = PartPosition
    Data.LastRootPosition = Root and Root.Position or nil
    Data.StableTime = 0
    Data.AnomalyStableTime = 0
    Data.UnstableTime = 0
    Data.Trust = 0
    return Data
end

function ResolverGetMotorTransformMagnitude(Motor)
    if not Motor or not Motor:IsA("Motor6D") then return 0 end

    local Transform = Motor.Transform
    local PositionMagnitude = Transform.Position.Magnitude
    local X, Y, Z = Transform:ToOrientation()
    local RotationMagnitude = math.abs(X) + math.abs(Y) + math.abs(Z)

    return PositionMagnitude + RotationMagnitude
end

function ResolverUpdateReplicatedPoseTrust(Character, Part, ExpectedFrame, Scale, RootFrame)
    local Root = ResolverGetRoot(Character)
    if not Root or not Part or not ExpectedFrame or not RootFrame then return 0, true end

    local Data = ResolverGetPoseHistory(Part)
    local CurrentTime = os.clock()
    local CurrentPosition = Part.Position
    local CurrentLocalPosition = RootFrame:PointToObjectSpace(CurrentPosition)
    local ExpectedLocalPosition = RootFrame:PointToObjectSpace(ExpectedFrame.Position)
    local ExpectedDelta = CurrentLocalPosition - ExpectedLocalPosition
    local Motor = ResolverFindBodyMotor(Character, Part)
    local MotorUsable = ResolverMotorIsUsable(Motor, Scale)
    local SizeAnomaly = ResolverPartSizeAnomaly(Part, Scale)

    if Data.Character ~= Character
        or Data.Root ~= Root
        or Data.LastTime <= 0
        or CurrentTime - Data.LastTime > ResolverState.ReplicatedPoseMaximumGap
    then
        ResolverResetPoseHistory(
            Data,
            Character,
            Root,
            CurrentTime,
            CurrentLocalPosition,
            ExpectedDelta,
            CurrentPosition
        )

        return 0, not MotorUsable or SizeAnomaly
    end

    local DeltaTime = math.max(CurrentTime - Data.LastTime, ResolverState.MinimumDelta)
    local LocalMovement = Data.LastLocalPosition and (CurrentLocalPosition - Data.LastLocalPosition).Magnitude or 0
    local ExpectedDeltaMovement = Data.LastExpectedDelta and (ExpectedDelta - Data.LastExpectedDelta).Magnitude or 0
    local RootMovement = Data.LastRootPosition and (Root.Position - Data.LastRootPosition) or Vector3.zero
    local PartMovement = Data.LastPartPosition and (CurrentPosition - Data.LastPartPosition) or Vector3.zero
    local RelativeMovementSpeed = (PartMovement - RootMovement).Magnitude / DeltaTime
    local RootVelocity = Root.AssemblyLinearVelocity or Root.Velocity or Vector3.zero
    local PartVelocity = Part.AssemblyLinearVelocity or Part.Velocity or Vector3.zero
    local VelocityDifference = (PartVelocity - RootVelocity).Magnitude
    local BroadBodyRadius = math.max(8.5 * Scale, 6)
    local InsideBodyEnvelope = CurrentLocalPosition.Magnitude <= BroadBodyRadius
    local MaximumLocalMovement = math.max(0.20 * Scale, DeltaTime * 5.5 * Scale)
    local MaximumDeltaMovement = math.max(0.16 * Scale, DeltaTime * 4.2 * Scale)
    local MotorTransformMagnitude = ResolverGetMotorTransformMagnitude(Motor)

    local StableSample = MotorUsable
        and not SizeAnomaly
        and InsideBodyEnvelope
        and ResolverIsFiniteVector(CurrentLocalPosition)
        and LocalMovement <= MaximumLocalMovement
        and ExpectedDeltaMovement <= MaximumDeltaMovement
        and RelativeMovementSpeed <= 42
        and VelocityDifference <= 58

    local HardReject = not MotorUsable
        or SizeAnomaly
        or not InsideBodyEnvelope
        or RelativeMovementSpeed > 115
        or VelocityDifference > 145
        or ExpectedDeltaMovement > math.max(1.25 * Scale, DeltaTime * 18)

    local AnomalyMagnitude = ExpectedDelta.Magnitude
    local StableAnomaly = StableSample
        and AnomalyMagnitude >= 0.55 * Scale
        and ExpectedDeltaMovement <= math.max(0.10 * Scale, DeltaTime * 2.8 * Scale)

    if StableSample then
        Data.StableTime = math.min(Data.StableTime + DeltaTime, 2.5)
        Data.UnstableTime = math.max(0, Data.UnstableTime - DeltaTime * 1.8)
    else
        Data.StableTime = math.max(0, Data.StableTime - DeltaTime * ResolverState.ReplicatedPoseDecay)
        Data.UnstableTime = math.min(Data.UnstableTime + DeltaTime, 2.5)
    end

    if StableAnomaly then
        Data.AnomalyStableTime = math.min(Data.AnomalyStableTime + DeltaTime, 2.5)
    else
        Data.AnomalyStableTime = math.max(0, Data.AnomalyStableTime - DeltaTime * 2.1)
    end

    local StableTrust = math.clamp(
        (Data.StableTime - 0.12) / math.max(ResolverState.ReplicatedPoseTrustTime - 0.12, 0.01),
        0,
        1
    )

    local AnomalyTrust = math.clamp(
        (Data.AnomalyStableTime - 0.16) / math.max(ResolverState.ReplicatedPoseTrustTime - 0.16, 0.01),
        0,
        1
    )

    local MotorTransformTrust = math.clamp(MotorTransformMagnitude / math.max(0.35 * Scale, 0.2), 0, 1)
    local TargetTrust = math.min(StableTrust, math.max(AnomalyTrust, MotorTransformTrust * StableTrust))

    if AnomalyMagnitude < 0.55 * Scale then
        TargetTrust = StableTrust
    end

    if HardReject then
        TargetTrust = 0
    elseif Data.UnstableTime > 0.20 then
        TargetTrust = TargetTrust * math.clamp(1 - Data.UnstableTime / 0.55, 0, 1)
    end

    local TrustAlpha = math.clamp(DeltaTime * 9, 0.08, 0.75)
    Data.Trust = Data.Trust + (TargetTrust - Data.Trust) * TrustAlpha
    Data.LastTime = CurrentTime
    Data.LastLocalPosition = CurrentLocalPosition
    Data.LastExpectedDelta = ExpectedDelta
    Data.LastPartPosition = CurrentPosition
    Data.LastRootPosition = Root.Position

    return math.clamp(Data.Trust, 0, 1), HardReject
end

function ResolverGetSafePartPosition(Character, TargetPart)
    local Root = ResolverGetRoot(Character)
    if not Root then return TargetPart and TargetPart.Position or nil end

    local Expected, Scale, RootFrame = ResolverBuildExpectedSkeleton(Character)
    local ExpectedFrame = TargetPart and Expected[TargetPart]

    if not ExpectedFrame then
        local FallbackOffset = ResolverGetFallbackPartOffset(Character, TargetPart and TargetPart.Name or "HumanoidRootPart", Scale)
        ExpectedFrame = RootFrame and RootFrame * CFrame.new(FallbackOffset) or Root.CFrame
    end

    local ExpectedPosition = ExpectedFrame.Position
    if not TargetPart or not TargetPart:IsA("BasePart") then return ExpectedPosition end

    local Score = ResolverGetPartAnomalyScore(Character, TargetPart, ExpectedFrame, Expected, Scale, RootFrame)
    local WholeBodyAnomalies = ResolverCountSkeletonAnomalies(Character, Expected, Scale, RootFrame)
    local ReplicatedPoseTrust, HardReject = ResolverUpdateReplicatedPoseTrust(
        Character,
        TargetPart,
        ExpectedFrame,
        Scale,
        RootFrame
    )

    -- A stable part connected to the real skeleton is treated as the actual hitbox,
    -- even when the head is inside the torso or placed unusually high/low.
    if not HardReject and ReplicatedPoseTrust >= 0.72 then
        return TargetPart.Position
    end

    if WholeBodyAnomalies >= 3 then
        Score = math.max(Score, 2.5)
    elseif WholeBodyAnomalies >= 2 then
        Score = math.max(Score, 1.4)
    end

    -- Stable replicated poses reduce correction gradually while transient/desynced
    -- parts continue to use the reconstructed Motor6D skeleton.
    if not HardReject and ReplicatedPoseTrust > 0 then
        Score = Score * (1 - ReplicatedPoseTrust * 0.88)
    end

    if Score >= 1.25 then
        return ExpectedPosition
    end

    if Score >= 0.35 then
        local Alpha = math.clamp((Score - 0.25) / 1.0, 0.15, 0.90)
        Alpha = Alpha * (1 - ReplicatedPoseTrust * 0.75)
        return TargetPart.Position:Lerp(ExpectedPosition, Alpha)
    end

    return TargetPart.Position
end

function ResolveCombatPosition(Player, Character, TargetPart, PredictionTime, Settings)
    if not Character or not TargetPart then return nil, nil end

    local RawPosition = TargetPart.Position
    local Root = ResolverGetRoot(Character)
    local TimeValue = math.clamp(tonumber(PredictionTime) or 0, 0, 0.45)

    if not Player then
        local Velocity = Root and (Root.AssemblyLinearVelocity or Root.Velocity) or Vector3.zero
        return RawPosition + Velocity * TimeValue, nil
    end

    Settings = Settings or {
        ResolverMode = "Adaptive",
        ResolverStrength = 1,
        ResolverMaxSpeed = 190,
        ResolverDesyncThreshold = 18
    }

    Settings.Resolver = true
    Settings.ResolverMode = "Adaptive"
    Settings.ResolverStrength = 1

    local SafePosition = ResolverGetSafePartPosition(Character, TargetPart)
    local Velocity, Data = ResolverGetMovementVelocity(Player, Character, Settings)
    local Acceleration = Data and Data.Acceleration or Vector3.zero

    if Data and Data.IsDesynced then
        Acceleration = ResolverClampVector(Acceleration, 320)
    else
        Acceleration = ResolverClampVector(Acceleration, 180)
    end

    local Predicted = SafePosition + Velocity * TimeValue + Acceleration * (0.5 * TimeValue * TimeValue)
    local MaximumTravel = math.max(tonumber(Settings.ResolverMaxSpeed) or 190, 40) * TimeValue + 2
    local Travel = Predicted - SafePosition

    if Travel.Magnitude > MaximumTravel and Travel.Magnitude > 0 then
        Predicted = SafePosition + Travel.Unit * MaximumTravel
    end

    local Strength = math.clamp(tonumber(Settings.ResolverStrength) or 1, 0, 1)
    local NormalVelocity = Root and ResolverClampVector(Root.AssemblyLinearVelocity or Root.Velocity or Vector3.zero, Settings.ResolverMaxSpeed or 190) or Vector3.zero
    local NormalPrediction = RawPosition + NormalVelocity * TimeValue

    return NormalPrediction:Lerp(Predicted, Strength), Data
end

local HitFeedbackState = { ImpactEnabled = false, ImpactColor = Color3.fromRGB(170, 0, 255), ImpactTransparency = 0.5, ImpactStyle = "Character", DamageIndicatorEnabled = true, DamageColor =
    Color3.fromRGB(255, 255, 255), HeadshotDamageColor = Color3.fromRGB(255, 82, 82), DamageTextSize = 18, DamageDuration = 0.85, DamageRise = 2.8, BulletTracerEnabled = false,
    BulletTracerColor = Color3.fromRGB(54, 218, 145), BulletTracerTime = 0.32, BulletTracerRate = 28, BulletTracerWidth = 0.10, BulletTracerGlow = 2, BulletTracerStyle = "Energy" }

local AttackConfirmationState = { Shots = {}, Window = 2.00, MergeWindow = 0.24, SignalWindow = 0.35, MaximumShots = 96, ShotRange = 5000, PendingDamage = setmetatable({}, { __mode = "k" }),
    BufferedDamage = setmetatable({}, { __mode = "k" }) }

local HitFeedbackRuntimeState = { ActiveObjects = setmetatable({}, { __mode = "k" }), BulletTracerMuzzleCache = setmetatable({}, { __mode = "k" }), BulletTracerAmmoObjects = setmetatable({},
    { __mode = "k" }), BulletTracerAmmoSuppression = setmetatable({}, { __mode = "k" }), BulletTracerWeaponCache = setmetatable({}, { __mode = "k" }),
    BulletTracerLastSpawn = setmetatable({}, { __mode = "k" }), BulletTracerLastRemoteShot = setmetatable({}, { __mode = "k" }), ActiveBulletTracers = 0, BulletTracerSerial = 0 }

local function IsHitFeedbackEnabled() return HitFeedbackState.ImpactEnabled or HitFeedbackState.DamageIndicatorEnabled end

local function GetPlayerFromTrackedCharacter(Character)
    if not Character then return nil end
    local Player = Players:GetPlayerFromCharacter(Character)
    if Player then return Player end
    local NamedPlayer = Players:FindFirstChild(Character.Name)
    if NamedPlayer and NamedPlayer:IsA("Player") then return NamedPlayer end
    for Unused, Candidate in ipairs(Players:GetPlayers()) do
        if Candidate.Character == Character then return Candidate end
    end
    return nil
end

local function GetHumanoidCharacterFromPart(Part)
    local Current = Part
    while Current and Current ~= workspace do
        if Current:IsA("Model") and Current:FindFirstChildOfClass("Humanoid") then return Current end
        Current = Current.Parent
    end
    return nil
end

local function ResolveTrackedCharacter(Player, PreferredCharacter)
    if not Player then return nil end
    local WorldContainer = workspace:FindFirstChild("©")
    local Characters = WorldContainer and WorldContainer:FindFirstChild("Characters")
    local WorldCharacter = Characters and Characters:FindFirstChild(Player.Name)
    if WorldCharacter and WorldCharacter:IsA("Model") then return WorldCharacter end
    if PreferredCharacter and PreferredCharacter:IsA("Model") then return PreferredCharacter end
    return Player.Character
end

local function CleanupAttackConfirmations()
    local CurrentTime = os.clock()
    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Shot = AttackConfirmationState.Shots[Index]
        if not Shot or CurrentTime - Shot.Time > AttackConfirmationState.Window or Shot.ConfirmedAt and CurrentTime - Shot.ConfirmedAt > AttackConfirmationState.MergeWindow then
            table.remove(AttackConfirmationState.Shots, Index)
        end
    end
    while #AttackConfirmationState.Shots > AttackConfirmationState.MaximumShots do table.remove(AttackConfirmationState.Shots, 1) end
end

local function RegisterLocalAttack(TargetCharacter, TargetPart, ShotToken)
    TargetCharacter = TargetCharacter or GetHumanoidCharacterFromPart(TargetPart)
    local TargetPlayer = GetPlayerFromTrackedCharacter(TargetCharacter)
    if not TargetPlayer or TargetPlayer == LocalPlayer or not TargetCharacter then return nil end
    local ResolvedCharacter = ResolveTrackedCharacter(TargetPlayer, TargetCharacter)
    if ResolvedCharacter then TargetCharacter = ResolvedCharacter end
    local PartName = TargetPart and TargetPart.Name or nil
    if TargetPart and not TargetPart:IsDescendantOf(TargetCharacter) then TargetPart = PartName and TargetCharacter:FindFirstChild(PartName, true) or nil end
    if not TargetPart then TargetPart = TargetCharacter:FindFirstChild("HumanoidRootPart") or TargetCharacter:FindFirstChild("Head") or TargetCharacter.PrimaryPart end
    if not TargetPart or not TargetPart:IsA("BasePart") then return nil end
    CleanupAttackConfirmations()
    local CurrentTime = os.clock()
    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Existing = AttackConfirmationState.Shots[Index]
        if Existing and Existing.Player == TargetPlayer and CurrentTime - Existing.Time <= 0.08 and not Existing.SignalConfirmed and(Existing.PartName == TargetPart.Name or
            Existing.Character == TargetCharacter) then
            Existing.Time = CurrentTime
            Existing.Character = TargetCharacter
            Existing.PartName = Existing.PartName == "Head" and "Head" or TargetPart.Name
            Existing.Token = ShotToken or Existing.Token
            return Existing
        end
    end
    if ShotToken ~= nil then
        for Index = #AttackConfirmationState.Shots, 1, -1 do
            local Existing = AttackConfirmationState.Shots[Index]
            if Existing and Existing.Token == ShotToken and Existing.Player == TargetPlayer then
                Existing.Time = CurrentTime
                Existing.Character = TargetCharacter
                Existing.PartName = Existing.PartName == "Head" and "Head" or TargetPart.Name
                Existing.ConfirmedAt = nil
                return Existing
            end
        end
    end
    local Shot = { Time = CurrentTime, Player = TargetPlayer, Character = TargetCharacter, PartName = TargetPart.Name, Token = ShotToken, ConfirmedAt = nil, SignalConfirmed = false,
        DamageConfirmed = false }
    AttackConfirmationState.Shots[#AttackConfirmationState.Shots + 1] = Shot
    return Shot
end

local function FindAttackConfirmation(Character)
    CleanupAttackConfirmations()
    local CurrentTime = os.clock()
    local TargetPlayer = GetPlayerFromTrackedCharacter(Character)
    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Shot = AttackConfirmationState.Shots[Index]
        if Shot and(Shot.Character == Character or TargetPlayer and Shot.Player == TargetPlayer) and(not Shot.ConfirmedAt or CurrentTime - Shot.ConfirmedAt <= AttackConfirmationState.MergeWindow) then
            Shot.ConfirmedAt = Shot.ConfirmedAt or CurrentTime
            return Shot
        end
    end
    return nil
end

local function GetHitFeedbackGuiParent()
    local CurrentPlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer:FindFirstChild("PlayerGui") or PlayerGui
    if CurrentPlayerGui and CurrentPlayerGui.Parent then return CurrentPlayerGui end
    if type(gethui) == "function" then
        local Success, HiddenUi = pcall(gethui)
        if Success and HiddenUi then return HiddenUi end
    end
    return nil
end

function GetBulletTracerWeaponData(Tool)
    if not Tool or not Tool:IsA("Tool") then return nil end

    local Cached = HitFeedbackRuntimeState.BulletTracerWeaponCache[Tool]
    if Cached and Cached.Tool == Tool and Tool.Parent then return Cached end

    local Values = Tool:FindFirstChild("Values")
    local AmmoValue = Values and (Values:FindFirstChild("SERVER_Ammo") or Values:FindFirstChild("Ammo"))
    local StoredAmmo = Values and (Values:FindFirstChild("SERVER_StoredAmmo") or Values:FindFirstChild("StoredAmmo"))
    local HasAmmo = AmmoValue and (AmmoValue:IsA("IntValue") or AmmoValue:IsA("NumberValue"))
    local HasStoredAmmo = StoredAmmo and (StoredAmmo:IsA("IntValue") or StoredAmmo:IsA("NumberValue"))

    if not HasAmmo then
        for _, Object in ipairs(Tool:GetDescendants()) do
            if (Object.Name == "Ammo" or Object.Name == "SERVER_Ammo") and (Object:IsA("IntValue") or Object:IsA("NumberValue")) then
                AmmoValue = Object
                HasAmmo = true
                break
            end
        end
    end

    local Config = nil
    local ConfigModule = Tool:FindFirstChild("Config", true)

    if ConfigModule and ConfigModule:IsA("ModuleScript") then
        local Success, Result = pcall(require, ConfigModule)
        if Success and type(Result) == "table" then Config = Result end
    end

    if not Config then
        for _, Object in ipairs(Tool:GetDescendants()) do
            if Object:IsA("ModuleScript") and (Object.Name == "WeaponConfig" or Object.Name == "GunConfig") then
                local Success, Result = pcall(require, Object)
                if Success and type(Result) == "table" then
                    Config = Result
                    break
                end
            end
        end
    end

    local MagSize = Config and tonumber(rawget(Config, "MagSize")) or nil
    local FireRate = Config and tonumber(rawget(Config, "FireRate")) or nil
    local Spread = Config and tonumber(rawget(Config, "Spread")) or nil
    local Recoil = Config and tonumber(rawget(Config, "Recoil")) or nil
    local Damage = Config and tonumber(rawget(Config, "Damage")) or nil
    local Range = Config and tonumber(rawget(Config, "Range")) or nil
    local BulletsPerShot = Config and tonumber(rawget(Config, "BulletsPerShot")) or nil
    local HasGunScript = Tool:FindFirstChild("Client", true) ~= nil
        or Tool:FindFirstChildWhichIsA("LocalScript", true) ~= nil
        or Tool:FindFirstChildWhichIsA("ModuleScript", true) ~= nil

    local HasHitmarker = Tool:FindFirstChild("Hitmarker", true) ~= nil

    local ConfigFirearm = MagSize and MagSize > 0
        and FireRate and FireRate > 0
        and (Spread ~= nil or Recoil ~= nil)
        and (HasAmmo or HasGunScript or HasHitmarker)

    local LegacyFirearm = HasAmmo and (HasStoredAmmo or HasGunScript or HasHitmarker)
    if not ConfigFirearm and not LegacyFirearm then return nil end

    local Data = {
        Tool = Tool,
        Config = Config,
        Ammo = AmmoValue,
        StoredAmmo = StoredAmmo,
        MagSize = MagSize,
        FireRate = FireRate,
        HasConfigSignature = ConfigFirearm == true
    }

    HitFeedbackRuntimeState.BulletTracerWeaponCache[Tool] = Data
    return Data
end

local function IsBulletTracerWeapon(Tool)
    return GetBulletTracerWeaponData(Tool) ~= nil
end

local function GetBulletTracerMuzzle(Tool)
    local Cached = HitFeedbackRuntimeState.BulletTracerMuzzleCache[Tool]
    if Cached and Cached.Parent and Cached:IsDescendantOf(Tool) then return Cached end
    local BestObject = nil
    local BestScore = -math.huge
    for Unused, Object in ipairs(Tool:GetDescendants()) do
        if Object:IsA("Attachment") or Object:IsA("BasePart") then
            local Name = string.lower(Object.Name)
            local Score = 0
            if string.find(Name, "muzzle", 1, true) then Score = Score + 100 end
            if string.find(Name, "firepoint", 1, true) or string.find(Name, "fire_point", 1, true) then Score = Score + 85 end
            if string.find(Name, "barrel", 1, true) then Score = Score + 65 end
            if string.find(Name, "tip", 1, true) then Score = Score + 45 end
            if Object:IsA("Attachment") then Score = Score + 15 end
            if Object.Name == "Handle" then Score = math.max(Score, 10) end
            if Score > BestScore then
                BestScore = Score
                BestObject = Object
            end
        end
    end
    HitFeedbackRuntimeState.BulletTracerMuzzleCache[Tool] = BestObject
    return BestObject
end

local function GetBulletTracerOrigin(Tool)
    local Muzzle = GetBulletTracerMuzzle(Tool)
    if Muzzle then
        if Muzzle:IsA("Attachment") then return Muzzle.WorldPosition end
        if Muzzle:IsA("BasePart") then return Muzzle.Position end
    end
    local CameraObject = GetCamera()
    if CameraObject then return CameraObject.CFrame.Position end
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    return RootPart and RootPart.Position or nil
end

local function GetBulletTracerTarget(OriginPosition, Tool)
    if not OriginPosition then return nil end
    local AimPosition = nil
    if Mouse then
        local Success, MouseHit = pcall(function() return Mouse.Hit end)
        if Success and MouseHit then AimPosition = MouseHit.Position end
    end
    local CameraObject = GetCamera()
    if not AimPosition and CameraObject then
        local MousePosition = UserInputService:GetMouseLocation()
        local Ray = CameraObject:ViewportPointToRay(MousePosition.X, MousePosition.Y)
        AimPosition = Ray.Origin + Ray.Direction * AttackConfirmationState.ShotRange
    end
    if not AimPosition then return nil end
    local Difference = AimPosition - OriginPosition
    if Difference.Magnitude < 0.1 then return nil end
    local MaximumDistance = math.min(Difference.Magnitude, AttackConfirmationState.ShotRange)
    local RaycastParameters = RaycastParams.new()
    RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParameters.IgnoreWater = true
    local Excluded = {}
    if LocalPlayer.Character then Excluded[#Excluded + 1] = LocalPlayer.Character end
    if Tool then Excluded[#Excluded + 1] = Tool end
    RaycastParameters.FilterDescendantsInstances = Excluded
    local Result = workspace:Raycast(OriginPosition, Difference.Unit * MaximumDistance, RaycastParameters)
    return Result and Result.Position or OriginPosition + Difference.Unit * MaximumDistance
end

local function CreateBulletTracerBeam(Parent, StartAttachment, EndAttachment, Name, Width, Transparency, Color, Texture, TextureSpeed, CurveSize)
    local Beam = Instance.new("Beam")
    Beam.Name = Name
    Beam.Attachment0 = StartAttachment
    Beam.Attachment1 = EndAttachment
    Beam.FaceCamera = true
    Beam.Enabled = true
    Beam.Segments = 12
    Beam.Width0 = Width
    Beam.Width1 = Width * 0.35
    Beam.LightEmission = 1
    Beam.LightInfluence = 0
    Beam.Color = ColorSequence.new(Color)
    Beam.Transparency = NumberSequence.new(Transparency)
    Beam.CurveSize0 = CurveSize or 0
    Beam.CurveSize1 = - (CurveSize or 0)
    if Texture then
        Beam.Texture = Texture
        Beam.TextureMode = Enum.TextureMode.Wrap
        Beam.TextureLength = 1.1
        Beam.TextureSpeed = TextureSpeed or 0
    end
    Beam.Parent = Parent
    return Beam
end

local function SpawnBulletTracer(OriginPosition, TargetPosition, Tool, VerifiedFirearmShot)
    if not HitFeedbackState.BulletTracerEnabled or not OriginPosition or not TargetPosition then return end
    if not VerifiedFirearmShot and not IsBulletTracerWeapon(Tool) then return end
    local Distance = (TargetPosition - OriginPosition).Magnitude
    if Distance < 0.5 then return end
    if HitFeedbackRuntimeState.ActiveBulletTracers >= 64 then return end
    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if not Terrain then return end
    HitFeedbackRuntimeState.ActiveBulletTracers = HitFeedbackRuntimeState.ActiveBulletTracers + 1
    HitFeedbackRuntimeState.BulletTracerSerial = HitFeedbackRuntimeState.BulletTracerSerial + 1
    local Serial = HitFeedbackRuntimeState.BulletTracerSerial
    local StartAttachment = Instance.new("Attachment")
    StartAttachment.Name = "RadiantBulletTracerStart" .. Serial
    StartAttachment.Parent = Terrain
    StartAttachment.WorldPosition = OriginPosition
    local EndAttachment = Instance.new("Attachment")
    EndAttachment.Name = "RadiantBulletTracerEnd" .. Serial
    EndAttachment.Parent = Terrain
    EndAttachment.WorldPosition = TargetPosition
    HitFeedbackRuntimeState.ActiveObjects[StartAttachment] = true
    HitFeedbackRuntimeState.ActiveObjects[EndAttachment] = true
    local Color = HitFeedbackState.BulletTracerColor
    local Duration = math.clamp(tonumber(HitFeedbackState.BulletTracerTime) or 0.32, 0.05, 2)
    local Width = math.clamp(tonumber(HitFeedbackState.BulletTracerWidth) or 0.10, 0.01, 0.5)
    local Glow = math.clamp(tonumber(HitFeedbackState.BulletTracerGlow) or 2, 0, 5)
    local Rate = math.clamp(tonumber(HitFeedbackState.BulletTracerRate) or 28, 0, 120)
    local Style = HitFeedbackState.BulletTracerStyle
    local CoreBeam = CreateBulletTracerBeam(StartAttachment, StartAttachment, EndAttachment, "Core", Width, 0.02, Color, Style == "Energy" and
        "rbxasset://textures/particles/sparkles_main.dds" or nil, Style == "Energy" and 7 or 0, Style == "Pulse" and math.min(Distance * 0.018, 4) or 0)
    local GlowBeam = nil
    if Glow > 0 then
        GlowBeam = CreateBulletTracerBeam(StartAttachment, StartAttachment, EndAttachment, "Glow", Width * (1.8 + Glow * 0.45), math.clamp(0.58 - Glow * 0.035, 0.30, 0.65), Color, nil, 0,
            Style == "Pulse" and -math.min(Distance * 0.012, 2.5) or 0)
    end
    local PulseBeam = nil
    if Style == "Pulse" then PulseBeam = CreateBulletTracerBeam(StartAttachment, StartAttachment, EndAttachment, "Pulse", Width * 0.42, 0.12, Color3.new(1, 1, 1), nil, 0, 0) end
    local ImpactEmitter = Instance.new("ParticleEmitter")
    ImpactEmitter.Name = "ImpactVfx"
    ImpactEmitter.Enabled = Rate > 0
    ImpactEmitter.Rate = Rate
    ImpactEmitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    ImpactEmitter.Color = ColorSequence.new(Color)
    ImpactEmitter.LightEmission = 1
    ImpactEmitter.LightInfluence = 0
    ImpactEmitter.Lifetime = NumberRange.new(math.min(Duration * 0.45, 0.18), math.min(Duration * 0.90, 0.42))
    ImpactEmitter.Speed = NumberRange.new(1.5, 4.5)
    ImpactEmitter.Drag = 5
    ImpactEmitter.SpreadAngle = Vector2.new(180, 180)
    ImpactEmitter.Rotation = NumberRange.new(0, 360)
    ImpactEmitter.RotSpeed = NumberRange.new(-180, 180)
    ImpactEmitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, Width * 3.5), NumberSequenceKeypoint.new(1, 0) })
    ImpactEmitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 1) })
    ImpactEmitter.Parent = EndAttachment
    task.spawn(function()
        local StartTime = os.clock()
        while StartAttachment.Parent and EndAttachment.Parent do
            local Alpha = math.clamp((os.clock() - StartTime) / Duration, 0, 1)
            local CoreTransparency = Alpha * Alpha
            CoreBeam.Transparency = NumberSequence.new(CoreTransparency)
            if GlowBeam then GlowBeam.Transparency = NumberSequence.new(math.clamp(0.55 + Alpha * 0.45, 0, 1)) end
            if PulseBeam then PulseBeam.Transparency = NumberSequence.new(math.clamp(0.12 + Alpha * 0.88, 0, 1)) end
            if Alpha >= 1 then break end
            RunService.Heartbeat:Wait()
        end
        HitFeedbackRuntimeState.ActiveObjects[StartAttachment] = nil
        HitFeedbackRuntimeState.ActiveObjects[EndAttachment] = nil
        if StartAttachment.Parent then StartAttachment:Destroy() end
        if EndAttachment.Parent then EndAttachment:Destroy() end
        HitFeedbackRuntimeState.ActiveBulletTracers = math.max(HitFeedbackRuntimeState.ActiveBulletTracers - 1, 0)
    end)
end

local function GetBulletTracerDirectionPoint(OriginPosition, TargetPosition)
    if RageBotSettings.BulletDirection ~= "Up" then return nil end
    local Middle = (OriginPosition + TargetPosition) * 0.5
    return Middle + Vector3.new(0, math.max(10, tonumber(RageBotSettings.BulletDirectionOffset) or 70), 0)
end

local function SpawnDirectionalBulletTracer(OriginPosition, TargetPosition, Tool, VerifiedFirearmShot)
    if not HitFeedbackState.BulletTracerEnabled or not OriginPosition or not TargetPosition then return end
    if not VerifiedFirearmShot and not IsBulletTracerWeapon(Tool) then return end

    local DirectionPoint = GetBulletTracerDirectionPoint(OriginPosition, TargetPosition)

    if DirectionPoint then
        SpawnBulletTracer(OriginPosition, DirectionPoint, Tool, VerifiedFirearmShot)
        SpawnBulletTracer(DirectionPoint, TargetPosition, Tool, VerifiedFirearmShot)
    else
        SpawnBulletTracer(OriginPosition, TargetPosition, Tool, VerifiedFirearmShot)
    end
end

local function ClearBulletTracers()
    for Object in pairs(HitFeedbackRuntimeState.ActiveObjects) do
        if Object and string.find(Object.Name, "RadiantBulletTracer", 1, true) == 1 then
            HitFeedbackRuntimeState.ActiveObjects[Object] = nil
            if Object.Parent then Object:Destroy() end
        end
    end
    HitFeedbackRuntimeState.ActiveBulletTracers = 0
end

function ShouldSpawnBulletTracer(Tool, MinimumGap)
    if not Tool then return false end

    local CurrentTime = os.clock()
    local PreviousTime = HitFeedbackRuntimeState.BulletTracerLastSpawn[Tool] or 0
    MinimumGap = tonumber(MinimumGap) or 0.025

    if CurrentTime - PreviousTime < MinimumGap then return false end
    HitFeedbackRuntimeState.BulletTracerLastSpawn[Tool] = CurrentTime
    return true
end

function GetBulletTracerTargetFromDirection(OriginPosition, Direction, Tool)
    if typeof(OriginPosition) ~= "Vector3" or typeof(Direction) ~= "Vector3" or Direction.Magnitude < 0.01 then return nil end

    local RaycastParameters = RaycastParams.new()
    RaycastParameters.FilterType = Enum.RaycastFilterType.Exclude
    RaycastParameters.IgnoreWater = true

    local Excluded = {}
    if LocalPlayer.Character then Excluded[#Excluded + 1] = LocalPlayer.Character end
    if Tool then Excluded[#Excluded + 1] = Tool end
    RaycastParameters.FilterDescendantsInstances = Excluded

    local DirectionMagnitude = Direction.Magnitude
    local Distance = DirectionMagnitude > 5 and math.min(DirectionMagnitude, AttackConfirmationState.ShotRange) or AttackConfirmationState.ShotRange
    local Result = workspace:Raycast(OriginPosition, Direction.Unit * Distance, RaycastParameters)
    return Result and Result.Position or OriginPosition + Direction.Unit * Distance
end

function SpawnCapturedBulletTracer(Tool, OriginPosition, Direction)
    if not HitFeedbackState.BulletTracerEnabled then return end

    if not Tool or not Tool:IsA("Tool") then
        Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    end

    if not Tool then return end

    if typeof(OriginPosition) ~= "Vector3" then
        OriginPosition = GetBulletTracerOrigin(Tool)
    end

    if typeof(OriginPosition) ~= "Vector3" or typeof(Direction) ~= "Vector3" or Direction.Magnitude < 0.01 then
        SpawnToolBulletTracer(Tool)
        return
    end

    if not ShouldSpawnBulletTracer(Tool, 0.018) then return end

    local MuzzleOrigin = GetBulletTracerOrigin(Tool)
    if typeof(MuzzleOrigin) == "Vector3" then OriginPosition = MuzzleOrigin end

    local TargetPosition = GetBulletTracerTargetFromDirection(OriginPosition, Direction, Tool)
    if TargetPosition then SpawnDirectionalBulletTracer(OriginPosition, TargetPosition, Tool, true) end
end

local function SpawnToolBulletTracer(Tool)
    if not HitFeedbackState.BulletTracerEnabled or not IsBulletTracerWeapon(Tool) then return end
    if not ShouldSpawnBulletTracer(Tool, 0.025) then return end

    local OriginPosition = GetBulletTracerOrigin(Tool)
    local TargetPosition = GetBulletTracerTarget(OriginPosition, Tool)
    SpawnDirectionalBulletTracer(OriginPosition, TargetPosition, Tool)
end

function FindBulletTracerVectorInTable(Value, Depth)
    if type(Value) ~= "table" or (Depth or 0) > 2 then return nil end

    for _, NestedValue in pairs(Value) do
        if typeof(NestedValue) == "Vector3" and NestedValue.Magnitude > 0.001 then
            return NestedValue
        end

        if type(NestedValue) == "table" then
            local Found = FindBulletTracerVectorInTable(NestedValue, (Depth or 0) + 1)
            if Found then return Found end
        end
    end

    return nil
end

function ParseBulletTracerRemoteArguments(...)
    local Arguments = table.pack(...)
    local MarkerIndex = nil

    for Index = 1, Arguments.n do
        if Arguments[Index] == "FDS9I83" then
            MarkerIndex = Index
            break
        end
    end

    if not MarkerIndex then return nil end

    local Tool = nil
    local OriginPosition = nil
    local Direction = nil

    for Index = 1, Arguments.n do
        local Value = Arguments[Index]

        if not Tool and typeof(Value) == "Instance" and Value:IsA("Tool") then
            Tool = Value
        end
    end

    for Index = MarkerIndex + 1, Arguments.n do
        local Value = Arguments[Index]

        if not OriginPosition and typeof(Value) == "Vector3" then
            OriginPosition = Value
        elseif not Direction and type(Value) == "table" then
            Direction = FindBulletTracerVectorInTable(Value, 0)
        elseif OriginPosition and not Direction and typeof(Value) == "Vector3" then
            Direction = Value
        end
    end

    if not Tool then
        Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    end

    if Tool and not OriginPosition then OriginPosition = GetBulletTracerOrigin(Tool) end

    return Tool, OriginPosition, Direction
end

function DispatchBulletTracerRemoteShot(...)
    local Tool, OriginPosition, Direction = ParseBulletTracerRemoteArguments(...)
    if not Tool then return false end

    HitFeedbackRuntimeState.BulletTracerLastRemoteShot[Tool] = os.clock()

    if typeof(Direction) == "Vector3" then
        SpawnCapturedBulletTracer(Tool, OriginPosition, Direction)
    else
        SpawnToolBulletTracer(Tool)
    end

    return true
end

function HasBulletTracerShootConstant(FunctionObject)
    if type(FunctionObject) ~= "function" then return false end

    if type(isourclosure) == "function" then
        local Success, IsOurs = pcall(isourclosure, FunctionObject)
        if Success and IsOurs then return false end
    elseif type(isexecutorclosure) == "function" then
        local Success, IsOurs = pcall(isexecutorclosure, FunctionObject)
        if Success and IsOurs then return false end
    end

    local Reader = type(getconstants) == "function" and getconstants or type(debug) == "table" and debug.getconstants
    if type(Reader) ~= "function" then return false end

    local Success, Constants = pcall(Reader, FunctionObject)
    if not Success or type(Constants) ~= "table" then return false end

    for _, Constant in pairs(Constants) do
        if Constant == "FDS9I83" then return true end
    end

    return false
end

function HookBulletTracerShootFunction(FunctionObject, State)
    if not HasBulletTracerShootConstant(FunctionObject) then return false end
    if type(hookfunction) ~= "function" then return false end
    if State.ShootHooks[FunctionObject] then return false end

    local OriginalFunction

    local Success, Message = pcall(function()
        OriginalFunction = hookfunction(FunctionObject, function(...)
            local Arguments = table.pack(...)
            local StartedAt = os.clock()
            local Results = table.pack(OriginalFunction(table.unpack(Arguments, 1, Arguments.n)))

            if State.Enabled then
                task.defer(function()
                    local Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
                    if not Tool then return end

                    local RemoteTime = HitFeedbackRuntimeState.BulletTracerLastRemoteShot[Tool] or 0
                    if RemoteTime >= StartedAt then return end

                    local ParsedTool, OriginPosition, Direction = ParseBulletTracerRemoteArguments(table.unpack(Arguments, 1, Arguments.n))
                    ParsedTool = ParsedTool or Tool

                    if typeof(Direction) == "Vector3" then
                        SpawnCapturedBulletTracer(ParsedTool, OriginPosition, Direction)
                    else
                        SpawnToolBulletTracer(ParsedTool)
                    end
                end)
            end

            return table.unpack(Results, 1, Results.n)
        end)
    end)

    if not Success or not OriginalFunction then
        if Message then warn("Bullet tracer Shoot hook: " .. tostring(Message)) end
        return false
    end

    State.ShootHooks[FunctionObject] = OriginalFunction
    return true
end

function ScanBulletTracerShootFunctions(State)
    if not State.Enabled or State.ScanningFunctions then return end

    State.ScanningFunctions = true

    RadiantScanGarbage(false, function(Object)
        if type(Object) == "function" then HookBulletTracerShootFunction(Object, State) end
    end, 192)

    State.ScanningFunctions = false
    RadiantStepGC(16)
end

function InstallBulletTracerFireServerHook(State)
    if State.FireServerVersion >= 1 or type(hookfunction) ~= "function" then return State.FireServerVersion >= 1 end

    local TemporaryRemote = Instance.new("RemoteEvent")
    local FireServerMethod = TemporaryRemote.FireServer
    TemporaryRemote:Destroy()

    local OldFireServer
    local Success = pcall(function()
        OldFireServer = hookfunction(FireServerMethod, function(Self, ...)
            local Arguments = table.pack(...)
            local Results = table.pack(OldFireServer(Self, table.unpack(Arguments, 1, Arguments.n)))

            if State.Enabled then
                task.defer(DispatchBulletTracerRemoteShot, table.unpack(Arguments, 1, Arguments.n))
            end

            return table.unpack(Results, 1, Results.n)
        end)
    end)

    if Success and OldFireServer then
        State.FireServerVersion = 1
        return true
    end

    return false
end

function InstallBulletTracerShotHook()
    local Environment = getgenv()
    local State = rawget(Environment, "RadiantBulletTracerShotHook")

    if type(State) ~= "table" then
        State = {}
        rawset(Environment, "RadiantBulletTracerShotHook", State)
    end

    State.Version = tonumber(State.Version) or 0
    State.FireServerVersion = tonumber(State.FireServerVersion) or 0
    State.Enabled = HitFeedbackState.BulletTracerEnabled
    State.ShootHooks = type(State.ShootHooks) == "table" and State.ShootHooks or setmetatable({}, { __mode = "k" })
    State.ScanningFunctions = false

    if State.Version < 4
        and type(hookmetamethod) == "function"
        and type(newcclosure) == "function"
        and type(getnamecallmethod) == "function"
    then
        local OldNamecall

        local Success = pcall(function()
            OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
                local Method = getnamecallmethod()
                local Arguments = table.pack(...)
                local Results = table.pack(OldNamecall(Self, table.unpack(Arguments, 1, Arguments.n)))

                if State.Enabled and Method == "FireServer" then
                    task.defer(DispatchBulletTracerRemoteShot, table.unpack(Arguments, 1, Arguments.n))
                end

                return table.unpack(Results, 1, Results.n)
            end))
        end)

        if Success and OldNamecall then State.Version = 4 end
    end

    InstallBulletTracerFireServerHook(State)

    if State.Enabled then
        task.defer(ScanBulletTracerShootFunctions, State)
    end

    return State.Version >= 4 or State.FireServerVersion >= 1
end

function SetBulletTracerShotHookEnabled(Value)
    HitFeedbackState.BulletTracerEnabled = Value == true
    InstallBulletTracerShotHook()

    local State = getgenv().RadiantBulletTracerShotHook
    if type(State) ~= "table" then return end

    State.Enabled = Value == true

    if State.Enabled then
        task.defer(ScanBulletTracerShootFunctions, State)
    end
end

local function GetBulletTracerAmmoValue(Tool)
    local Data = GetBulletTracerWeaponData(Tool)
    return Data and Data.Ammo or nil
end

local function BindBulletTracerAmmo(Tool, Connections)
    return IsBulletTracerWeapon(Tool)
end

local function SpawnDamageIndicator(TargetPart, Damage, IsHeadshot)
    if not HitFeedbackState.DamageIndicatorEnabled or not TargetPart or not TargetPart.Parent or not TargetPart:IsA("BasePart") or Damage <= 0 then return end
    local Parent = GetHitFeedbackGuiParent()
    if not Parent then return end
    local Anchor = Instance.new("Part")
    Anchor.Name = "RadiantDamageAnchor"
    Anchor.Size = Vector3.new(0.05, 0.05, 0.05)
    Anchor.Transparency = 1
    Anchor.Anchored = true
    Anchor.CanCollide = false
    Anchor.CanTouch = false
    pcall(function() Anchor.CanQuery = false end)
    Anchor.CFrame = CFrame.new(TargetPart.Position)
    Anchor.Parent = workspace
    HitFeedbackRuntimeState.ActiveObjects[Anchor] = true
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "RadiantDamageIndicator"
    Billboard.Adornee = Anchor
    Billboard.AlwaysOnTop = true
    Billboard.Enabled = true
    Billboard.Size = UDim2.fromOffset(150, 52)
    Billboard.StudsOffsetWorldSpace = Vector3.new(math.random(-35, 35) / 100, 2.1, math.random(-12, 12) / 100)
    Billboard.ZIndexBehavior = Enum.ZIndexBehavior.Global
    pcall(function()
        Billboard.MaxDistance = AttackConfirmationState.ShotRange
        Billboard.LightInfluence = 0
    end)
    Billboard.Parent = Parent
    HitFeedbackRuntimeState.ActiveObjects[Billboard] = true
    local Label = Instance.new("TextLabel")
    Label.Name = "Damage"
    Label.AnchorPoint = Vector2.new(0.5, 0.5)
    Label.Position = UDim2.fromScale(0.5, 0.5)
    Label.Size = UDim2.fromScale(1, 1)
    Label.BackgroundTransparency = 1
    Label.BorderSizePixel = 0
    Label.FontFace = UiFont
    Label.Text = tostring(math.max(math.floor(Damage + 0.5), 1))
    Label.TextSize = math.max(tonumber(HitFeedbackState.DamageTextSize) or 18, 10)
    Label.TextColor3 = IsHeadshot and HitFeedbackState.HeadshotDamageColor or HitFeedbackState.DamageColor
    Label.TextStrokeColor3 = Color3.new(0, 0, 0)
    Label.TextStrokeTransparency = 0.05
    Label.TextTransparency = 0
    Label.TextWrapped = false
    Label.ZIndex = 1002
    Label.Parent = Billboard
    local Scale = Instance.new("UIScale")
    Scale.Scale = 0.82
    Scale.Parent = Label
    local Duration = math.max(tonumber(HitFeedbackState.DamageDuration) or 0.85, 0.20)
    local Rise = math.max(tonumber(HitFeedbackState.DamageRise) or 2.8, 0)
    TweenService:Create(Scale, TweenInfo.new(math.min(Duration * 0.35, 0.18), Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    TweenService:Create(Anchor, TweenInfo.new(Duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = Anchor.Position + Vector3.new(0, Rise, 0) }):Play()
    task.delay(math.min(0.12, Duration * 0.20), function()
        if not Label.Parent then return end
        TweenService:Create(Label, TweenInfo.new(math.max(Duration * 0.80, 0.12), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1, TextStrokeTransparency = 1 })
            :Play()
    end)
    task.delay(Duration + 0.12, function()
        HitFeedbackRuntimeState.ActiveObjects[Billboard] = nil
        HitFeedbackRuntimeState.ActiveObjects[Anchor] = nil
        if Billboard.Parent then Billboard:Destroy() end
        if Anchor.Parent then Anchor:Destroy() end
    end)
end

local function SpawnGhostVisual(HitPosition, TargetCharacterValue)
    if not HitFeedbackState.ImpactEnabled then return end
    if HitFeedbackState.ImpactStyle == "Character" and TargetCharacterValue and TargetCharacterValue:IsA("Model") then
        local Ghost = TargetCharacterValue:Clone()
        if not Ghost then return end
        for Unused, DescendantObject in ipairs(Ghost:GetDescendants()) do
            if DescendantObject:IsA("BasePart") then
                DescendantObject.Transparency = HitFeedbackState.ImpactTransparency
                DescendantObject.Color = HitFeedbackState.ImpactColor
                DescendantObject.Material = Enum.Material.Neon
                DescendantObject.CanCollide = false
                DescendantObject.Anchored = true
            elseif DescendantObject:IsA("Humanoid") or DescendantObject:IsA("Script") or DescendantObject:IsA("LocalScript") or DescendantObject:IsA("ModuleScript") then
                DescendantObject:Destroy()
            end
        end
        local PrimaryPart = Ghost.PrimaryPart or Ghost:FindFirstChild("HumanoidRootPart") or Ghost:FindFirstChild("Torso")
        if PrimaryPart then
            Ghost.PrimaryPart = PrimaryPart
            Ghost:PivotTo(CFrame.new(HitPosition - Vector3.new(0, 2.5, 0)))
        else
            Ghost:MoveTo(HitPosition)
        end
        Ghost.Parent = workspace
        local BasePosition = PrimaryPart and PrimaryPart.Position or HitPosition
        task.spawn(function()
            for Index = 1, 25 do
                if not Ghost or not Ghost.Parent then break end
                for Unused, PartObject in ipairs(Ghost:GetDescendants()) do
                    if PartObject:IsA("BasePart") then PartObject.Transparency = HitFeedbackState.ImpactTransparency + (Index / 25) * (1 - HitFeedbackState.ImpactTransparency) end
                end
                if PrimaryPart and PrimaryPart.Parent then
                    local NewPosition = BasePosition + Vector3.new(0, Index * 0.4, 0)
                    Ghost:PivotTo(CFrame.new(NewPosition) * PrimaryPart.CFrame.Rotation)
                end
                task.wait(0.08)
            end
            if Ghost then Ghost:Destroy() end
        end)
    else
        local GhostPart = Instance.new("Part")
        if HitFeedbackState.ImpactStyle == "Ball" then
            GhostPart.Shape = Enum.PartType.Ball
        elseif HitFeedbackState.ImpactStyle == "Cylinder" then
            GhostPart.Shape = Enum.PartType.Cylinder
        else
            GhostPart.Shape = Enum.PartType.Block
        end
        GhostPart.Size = Vector3.new(1.5, 1.5, 1.5)
        GhostPart.Anchored = true
        GhostPart.CanCollide = false
        GhostPart.Position = HitPosition
        GhostPart.Material = Enum.Material.Neon
        GhostPart.Color = HitFeedbackState.ImpactColor
        GhostPart.Transparency = HitFeedbackState.ImpactTransparency
        GhostPart.Parent = workspace
        local TweenInformation = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        TweenService:Create(GhostPart, TweenInformation, { Position = HitPosition + Vector3.new(0, 7, 0), Transparency = 1, Size = Vector3.new(0.5, 3, 0.5) }):Play()
        task.delay(2, function()
            if GhostPart and GhostPart.Parent then GhostPart:Destroy() end
        end)
    end
end

local HitVisualConnections = {}
local HitVisualToolConnections = setmetatable({}, { __mode = "k" })
local HitVisualBoundSignals = setmetatable({}, { __mode = "k" })
local HitVisualHumanoidConnections = {}
local HitVisualPreviousHealth = {}
local HitVisualTrackedCharacters = {}
local HitVisualWorldCharacters = nil
local HitVisualWorldContainer = nil
local QueueConfirmedDamage

local function DisconnectConnection(Connection)
    if Connection then
        pcall(function() Connection:Disconnect() end)
    end
end

local function DisconnectConnectionList(Connections)
    if not Connections then return end
    for Unused, Connection in pairs(Connections) do DisconnectConnection(Connection) end
    table.clear(Connections)
end

local function FindHitTargetInValue(Value, Visited, Depth)
    if typeof(Value) == "Instance" then
        if Value:IsA("BasePart") then return GetHumanoidCharacterFromPart(Value), Value end
        if Value:IsA("Humanoid") then
            local Character = Value.Parent
            if Character and Character:IsA("Model") then return Character, Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart") or Character.PrimaryPart end
        end
        if Value:IsA("Model") and Value:FindFirstChildOfClass("Humanoid") then return Value, Value:FindFirstChild("Head") or Value:FindFirstChild("HumanoidRootPart") or Value.PrimaryPart end
        return nil, nil
    end
    if type(Value) ~= "table" or Depth >= 3 or Visited[Value] then return nil, nil end
    Visited[Value] = true
    for Key, NestedValue in pairs(Value) do
        local Character, Part = FindHitTargetInValue(NestedValue, Visited, Depth + 1)
        if Character and Part then return Character, Part end
        Character, Part = FindHitTargetInValue(Key, Visited, Depth + 1)
        if Character and Part then return Character, Part end
    end
    return nil, nil
end

local function ResolveHitSignalTarget(...)
    local Arguments = table.pack(...)
    local Visited = {}
    for Index = 1, Arguments.n do
        local Character, Part = FindHitTargetInValue(Arguments[Index], Visited, 0)
        if Character and Part then return Character, Part end
    end
    return nil, nil
end

QueueConfirmedDamage = function(Player, Character, Damage, IsHeadshot, PartName)
    if not Player or not Character or not Character.Parent or not Damage or Damage <= 0 then return end
    local TargetPart = PartName and Character:FindFirstChild(PartName, true) or IsHeadshot and Character:FindFirstChild("Head", true) or
        Character:FindFirstChild("HumanoidRootPart", true) or Character.PrimaryPart or Character:FindFirstChildWhichIsA("BasePart", true)
    if not TargetPart or not TargetPart:IsA("BasePart") then return end
    SpawnGhostVisual(TargetPart.Position, Character)
    SpawnDamageIndicator(TargetPart, Damage, IsHeadshot)
end

local function BufferUnconfirmedDamage(Player, Character, Damage)
    local CurrentTime = os.clock()
    local Buffered = AttackConfirmationState.BufferedDamage[Player]
    if not Buffered or Buffered.Character ~= Character or CurrentTime - Buffered.Time > AttackConfirmationState.SignalWindow then
        Buffered = { Character = Character, Damage = 0, Time = CurrentTime, Version = 0 }
        AttackConfirmationState.BufferedDamage[Player] = Buffered
    end
    Buffered.Damage = Buffered.Damage + Damage
    Buffered.Time = CurrentTime
    Buffered.Version = Buffered.Version + 1
    local Version = Buffered.Version
    task.delay(AttackConfirmationState.SignalWindow, function()
        local Current = AttackConfirmationState.BufferedDamage[Player]
        if Current == Buffered and Current.Version == Version and os.clock() - Current.Time >= AttackConfirmationState.SignalWindow then
            AttackConfirmationState.BufferedDamage[Player] = nil
        end
    end)
end

local function TryConfirmBufferedDamage(Shot)
    if not Shot or not Shot.Player then return false end
    local Buffered = AttackConfirmationState.BufferedDamage[Shot.Player]
    if not Buffered or os.clock() - Buffered.Time > AttackConfirmationState.SignalWindow or not(Buffered.Character == Shot.Character or GetPlayerFromTrackedCharacter(Buffered.Character)
        == Shot.Player) then
        return false
    end
    AttackConfirmationState.BufferedDamage[Shot.Player] = nil
    Shot.DamageConfirmed = true
    QueueConfirmedDamage(Shot.Player, Buffered.Character, Buffered.Damage, Shot.PartName == "Head", Shot.PartName)
    return true
end

local function FindRecentToolShot(Tool)
    local CurrentTime = os.clock()
    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Shot = AttackConfirmationState.Shots[Index]
        if Shot and Shot.Tool == Tool and not Shot.SignalConfirmed and CurrentTime - Shot.Time <= AttackConfirmationState.Window then return Shot end
    end
    return nil
end

local function HandleConfirmedHitSignal(Tool, ...)
    local TargetCharacter, TargetPart = ResolveHitSignalTarget(...)
    local Shot
    if TargetCharacter and TargetPart then
        Shot = RegisterLocalAttack(TargetCharacter, TargetPart, nil)
    else
        Shot = FindRecentToolShot(Tool)
        if not Shot then
            local MouseTarget = Mouse and Mouse.Target
            TargetPart = MouseTarget
            TargetCharacter = GetHumanoidCharacterFromPart(MouseTarget)
            Shot = RegisterLocalAttack(TargetCharacter, TargetPart, nil)
        end
    end
    if not Shot then return end
    Shot.Tool = Tool
    Shot.SignalConfirmed = true
    TryConfirmBufferedDamage(Shot)
end

local function BindToolHitSignal(Tool, SignalObject)
    if not SignalObject or HitVisualBoundSignals[SignalObject] then return end
    local Signal
    if SignalObject:IsA("BindableEvent") then
        Signal = SignalObject.Event
    elseif SignalObject:IsA("RemoteEvent") then
        Signal = SignalObject.OnClientEvent
    end
    if not Signal then return end
    HitVisualBoundSignals[SignalObject] = true
    local Connections = HitVisualToolConnections[Tool]
    if not Connections then return end
    Connections[#Connections + 1] = Signal:Connect(function(...) HandleConfirmedHitSignal(Tool, ...) end)
end

local function RegisterAttackTool(Tool)
    if not Tool or not Tool:IsA("Tool") or HitVisualToolConnections[Tool] then return end

    local TracerHookState = getgenv().RadiantBulletTracerShotHook
    if type(TracerHookState) == "table" and TracerHookState.Enabled then
        task.delay(0.15, ScanBulletTracerShootFunctions, TracerHookState)
    end

    local Connections = {}
    HitVisualToolConnections[Tool] = Connections
    Connections[#Connections + 1] = Tool.Activated:Connect(function()
        if IsBulletTracerWeapon(Tool) and not RageBotEnabled then
            local ActivatedAt = os.clock()

            task.delay(0.055, function()
                if not Tool.Parent or not HitFeedbackState.BulletTracerEnabled then return end
                local RemoteShotAt = HitFeedbackRuntimeState.BulletTracerLastRemoteShot[Tool] or 0
                if RemoteShotAt >= ActivatedAt then return end
                SpawnToolBulletTracer(Tool)
            end)
        end

        local TargetPart = Mouse and Mouse.Target
        local TargetCharacter = GetHumanoidCharacterFromPart(TargetPart)
        local Shot = RegisterLocalAttack(TargetCharacter, TargetPart, nil)
        if Shot then Shot.Tool = Tool end
    end)
    Connections[#Connections + 1] = Tool.ChildAdded:Connect(function(Child)
        HitFeedbackRuntimeState.BulletTracerWeaponCache[Tool] = nil
        HitFeedbackRuntimeState.BulletTracerMuzzleCache[Tool] = nil

        if Child.Name == "Hitmarker" then
            BindToolHitSignal(Tool, Child)
        elseif Child.Name == "Values" or Child.Name == "Config" then
            task.defer(BindBulletTracerAmmo, Tool, Connections)
        end
    end)
    Connections[#Connections + 1] = Tool.AncestryChanged:Connect(function()
        if Tool.Parent then return end
        DisconnectConnectionList(HitVisualToolConnections[Tool])
        HitVisualToolConnections[Tool] = nil
    end)
    BindToolHitSignal(Tool, Tool:FindFirstChild("Hitmarker"))
    BindBulletTracerAmmo(Tool, Connections)
end

local function RegisterToolContainer(Container)
    if not Container then return end
    for Unused, Child in ipairs(Container:GetChildren()) do RegisterAttackTool(Child) end
    local Connection = Container.ChildAdded:Connect(RegisterAttackTool)
    HitVisualConnections[#HitVisualConnections + 1] = Connection
end

local function RegisterLocalCharacter(Character)
    if not Character then return end
    RegisterToolContainer(Character)
end

local function RegisterTargetCharacter(Player, Character)
    if Player == LocalPlayer or not Player then return end
    Character = ResolveTrackedCharacter(Player, Character)
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid") or Character:WaitForChild("Humanoid", 5)
    if not Humanoid then return end
    if HitVisualTrackedCharacters[Player] == Character and HitVisualHumanoidConnections[Player] then return end
    DisconnectConnection(HitVisualHumanoidConnections[Player])
    AttackConfirmationState.PendingDamage[Player] = nil
    AttackConfirmationState.BufferedDamage[Player] = nil
    HitVisualTrackedCharacters[Player] = Character
    HitVisualPreviousHealth[Player] = Humanoid.Health
    HitVisualHumanoidConnections[Player] = Humanoid.HealthChanged:Connect(function(NewHealth)
        if HitVisualTrackedCharacters[Player] ~= Character then return end
        local PreviousHealth = HitVisualPreviousHealth[Player]
        HitVisualPreviousHealth[Player] = NewHealth
        if type(PreviousHealth) ~= "number" then return end
        local Damage = PreviousHealth - NewHealth
        if not IsHitFeedbackEnabled() or Damage <= 0 then return end
        local Confirmation = FindAttackConfirmation(Character)
        if not Confirmation then
            BufferUnconfirmedDamage(Player, Character, Damage)
            return
        end
        Confirmation.DamageConfirmed = true
        QueueConfirmedDamage(Player, Character, Damage, Confirmation.PartName == "Head", Confirmation.PartName)
    end)
end

local function DestroyHitFeedbackRuntime()
    for Unused, Connection in ipairs(HitVisualConnections) do DisconnectConnection(Connection) end
    table.clear(HitVisualConnections)
    for Tool, Connections in pairs(HitVisualToolConnections) do
        DisconnectConnectionList(Connections)
        HitVisualToolConnections[Tool] = nil
    end
    for Player, Connection in pairs(HitVisualHumanoidConnections) do
        DisconnectConnection(Connection)
        HitVisualHumanoidConnections[Player] = nil
    end
    table.clear(HitVisualPreviousHealth)
    table.clear(HitVisualTrackedCharacters)
    table.clear(AttackConfirmationState.Shots)
    table.clear(AttackConfirmationState.PendingDamage)
    table.clear(AttackConfirmationState.BufferedDamage)
    for Object in pairs(HitFeedbackRuntimeState.ActiveObjects) do
        pcall(function()
            if Object and Object.Parent then Object:Destroy() end
        end)
    end
    table.clear(HitFeedbackRuntimeState.ActiveObjects)
    table.clear(HitFeedbackRuntimeState.BulletTracerMuzzleCache)
    table.clear(HitFeedbackRuntimeState.BulletTracerAmmoObjects)
    table.clear(HitFeedbackRuntimeState.BulletTracerAmmoSuppression)
    table.clear(HitFeedbackRuntimeState.BulletTracerWeaponCache)
    table.clear(HitFeedbackRuntimeState.BulletTracerLastSpawn)
    table.clear(HitFeedbackRuntimeState.BulletTracerLastRemoteShot)
    SetBulletTracerShotHookEnabled(false)
    HitFeedbackRuntimeState.ActiveBulletTracers = 0
end

local function QueueTargetCharacterRegistration(Player, Character)
    task.spawn(function()
        local Deadline = os.clock() + 10
        local ResolvedCharacter = ResolveTrackedCharacter(Player, Character)
        while Player and Player.Parent and os.clock() < Deadline and(not ResolvedCharacter or not ResolvedCharacter:FindFirstChildOfClass("Humanoid")) do
            task.wait(0.10)
            ResolvedCharacter = ResolveTrackedCharacter(Player, Character)
        end
        RegisterTargetCharacter(Player, ResolvedCharacter)
    end)
end

local function RegisterTargetPlayer(Player)
    if Player == LocalPlayer then return end
    QueueTargetCharacterRegistration(Player, Player.Character)
    local Connection = Player.CharacterAdded:Connect(function(Character) QueueTargetCharacterRegistration(Player, Character) end)
    HitVisualConnections[#HitVisualConnections + 1] = Connection
end

local function BindWorldCharacterContainer(Characters)
    if not Characters or HitVisualWorldCharacters == Characters then return end
    HitVisualWorldCharacters = Characters
    for Unused, Character in ipairs(Characters:GetChildren()) do
        local Player = Players:FindFirstChild(Character.Name)
        if Player and Player:IsA("Player") then QueueTargetCharacterRegistration(Player, Character) end
    end
    HitVisualConnections[#HitVisualConnections + 1] = Characters.ChildAdded:Connect(function(Character)
        local Player = Players:FindFirstChild(Character.Name)
        if Player and Player:IsA("Player") then QueueTargetCharacterRegistration(Player, Character) end
    end)
end

local function BindWorldContainer(WorldContainer)
    if not WorldContainer or HitVisualWorldContainer == WorldContainer then return end
    HitVisualWorldContainer = WorldContainer
    local Characters = WorldContainer:FindFirstChild("Characters")
    if Characters then BindWorldCharacterContainer(Characters) end
    HitVisualConnections[#HitVisualConnections + 1] = WorldContainer.ChildAdded:Connect(function(Child)
        if Child.Name == "Characters" then BindWorldCharacterContainer(Child) end
    end)
end

local function TryBindWorldCharacters() BindWorldContainer(workspace:FindFirstChild("©")) end

InstallBulletTracerShotHook()
RegisterToolContainer(LocalPlayer:FindFirstChild("Backpack"))
if LocalPlayer.Character then RegisterLocalCharacter(LocalPlayer.Character) end
HitVisualConnections[#HitVisualConnections + 1] = LocalPlayer.CharacterAdded:Connect(function(Character) RegisterLocalCharacter(Character) end)
for Unused, Player in ipairs(Players:GetPlayers()) do RegisterTargetPlayer(Player) end
HitVisualConnections[#HitVisualConnections + 1] = Players.PlayerAdded:Connect(RegisterTargetPlayer)
HitVisualConnections[#HitVisualConnections + 1] = Players.PlayerRemoving:Connect(function(Player)
    DisconnectConnection(HitVisualHumanoidConnections[Player])
    HitVisualHumanoidConnections[Player] = nil
    HitVisualPreviousHealth[Player] = nil
    HitVisualTrackedCharacters[Player] = nil
    AttackConfirmationState.PendingDamage[Player] = nil
    AttackConfirmationState.BufferedDamage[Player] = nil
end)

TryBindWorldCharacters()
HitVisualConnections[#HitVisualConnections + 1] = workspace.ChildAdded:Connect(function(Child)
    if Child.Name == "©" then BindWorldContainer(Child) end
end)

SafeFarmEnabled = false
AltFarmEnabled = false
AutoATMEnabled = false
AutoATMCoroutine = nil
local AutoATMLastCollectTime = 0
local AutoATMInterval = 900
AntiAFKEnabled = true
AntiAFKConnection = nil
local AntiAFKTimer = 0
FastPickupEnabled = false
FastPickupConnection = nil
SafeLocationController = { Locations = { Cube = { Enabled = false, Connection = nil, Position = Vector3.new(-4184.4, 102.7, 276.9) }, Vibe = { Enabled = false, Connection = nil, Position =
    Vector3.new(-4857.5, -161.5, -918.3) }, Mount = { Enabled = false, Connection = nil, Position = Vector3.new(-5169.8, 102.6, -515.5) } } }
local DeathRespawnEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("DeathRespawn")
AutoRespawnEnabled = false
AutoRespawnCoroutine = nil
FullBrightEnabled = false
FullBrightOriginalSettings = {}
local FullBrightLight = nil
FullBrightConnection = nil

function SafeLocationController.IsEnabled(Self, Name)
    local Location = Self.Locations[Name]
    return Location and Location.Enabled or false
end

function SafeLocationController.SetEnabled(Self, Name, State)
    local Location = Self.Locations[Name]
    if not Location then return end
    State = State == true
    if Location.Enabled == State then return end
    Location.Enabled = State
    if Location.Connection then
        Location.Connection:Disconnect()
        Location.Connection = nil
    end
    if not State then return end
    Location.Connection = RunService.RenderStepped:Connect(function()
        if not Location.Enabled then return end
        local Character = LocalPlayer.Character
        if not Character then return end
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        if RootPart then RootPart.CFrame = CFrame.new(Location.Position) end
        if Humanoid and Humanoid.Health <= 0 and type(RequestCharacterRespawn) == "function" then RequestCharacterRespawn() end
    end)
end

function SafeLocationController.DisableAll(Self)
    for Name in pairs(Self.Locations) do Self:SetEnabled(Name, false) end
end

local function GetDrawingTextFont()
    if Drawing and Drawing.Fonts then
        if Drawing.Fonts.Plex then return Drawing.Fonts.Plex end
        if Drawing.Fonts.UI then return Drawing.Fonts.UI end
    end
    return 2
end

local function CreateDrawing(DrawingType, Properties)
    if not Drawing or type(Drawing.new) ~= "function" then return nil end
    local Success, Object = pcall(Drawing.new, DrawingType)
    if not Success or not Object then return nil end
    for Property, Value in pairs(Properties) do
        pcall(function() Object[Property] = Value end)
    end
    return Object
end

local function RemoveDrawing(Object)
    if not Object then return end
    pcall(function()
        Object.Visible = false
        Object:Remove()
    end)
end

local function DisconnectVisualConnection(Connection)
    if Connection then
        pcall(function() Connection:Disconnect() end)
    end
end

local function RefreshPlayerCharacter(Data, Character)
    if Data.Player then Character = ResolveTrackedCharacter(Data.Player, Character) or Character end
    Data.Character = Character
    Data.Humanoid = Character and Character:FindFirstChildOfClass("Humanoid") or nil
    Data.Root = Character and(Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")) or nil
    Data.Head = Character and Character:FindFirstChild("Head") or nil
    Data.ToolName = nil
    Data.NextToolScan = 0
    if Data.Highlight and Data.Highlight.Parent then Data.Highlight:Destroy() end
    if Data.Glow and Data.Glow.Parent then Data.Glow:Destroy() end
    Data.Highlight = nil
    Data.Glow = nil
end

local function CreatePlayerVisual(Player, WithDrawings)
    local Data = VisualState.Player.Objects[Player]
    if not Data then
        Data = { Player = Player, Character = nil, Humanoid = nil, Root = nil, Head = nil, ToolName = nil, NextToolScan = 0, Highlight = nil, Glow = nil, CharacterAddedConnection = nil,
            CharacterRemovingConnection = nil, Drawings = {}, DrawingsReady = false, ListIndex = 0 }
        VisualState.Player.Objects[Player] = Data
        Data.ListIndex = #VisualState.Player.List + 1
        VisualState.Player.List[Data.ListIndex] = Data
        Data.CharacterAddedConnection = Player.CharacterAdded:Connect(function(Character)
            task.spawn(function()
                local Deadline = os.clock() + 8
                local Resolved = ResolveTrackedCharacter(Player, Character)
                while Player.Parent and os.clock() < Deadline do
                    Resolved = ResolveTrackedCharacter(Player, Character)
                    if Resolved and Resolved:FindFirstChildOfClass("Humanoid") and(Resolved:FindFirstChild("HumanoidRootPart") or Resolved:FindFirstChild("Torso")) then break end
                    task.wait(0.12)
                end
                RefreshPlayerCharacter(Data, Resolved or Character)
            end)
        end)
        pcall(function()
            Data.CharacterRemovingConnection = Player.CharacterRemoving:Connect(function(Character)
                if Data.Character == Character or(Data.Character and Data.Character.Name == Character.Name) then
                    task.delay(0.35, function()
                        if not Player.Parent then return end
                        local Resolved = ResolveTrackedCharacter(Player, Player.Character)
                        if Resolved and Resolved ~= Character then
                            RefreshPlayerCharacter(Data, Resolved)
                        else
                            RefreshPlayerCharacter(Data, nil)
                        end
                    end)
                end
            end)
        end)
        task.spawn(function()
            local Deadline = os.clock() + 6
            local Resolved = ResolveTrackedCharacter(Player, Player.Character)
            while Player.Parent and os.clock() < Deadline and(not Resolved or not Resolved:FindFirstChildOfClass("Humanoid")) do
                task.wait(0.15)
                Resolved = ResolveTrackedCharacter(Player, Player.Character)
            end
            RefreshPlayerCharacter(Data, Resolved or Player.Character)
        end)
    end
    if not WithDrawings or Data.DrawingsReady then return Data end
    Data.DrawingsReady = true
    local function Add(Name, DrawingType, Properties)
        local Object = CreateDrawing(DrawingType, Properties)
        Data.Drawings[Name] = Object
        return Object
    end
    Add("Fill", "Square", { Visible = false, Filled = true, Thickness = 1, Transparency = 0.18, ZIndex = 1 })
    Add("BoxOutline", "Square", { Visible = false, Filled = false, Thickness = 3, Color = Color3.new(0, 0, 0), Transparency = 0.95, ZIndex = 2 })
    Add("Box", "Square", { Visible = false, Filled = false, Thickness = 1, Transparency = 1, ZIndex = 3 })
    for Index = 1, 8 do
        Add("CornerOutline" .. Index, "Line", { Visible = false, Thickness = 3, Color = Color3.new(0, 0, 0), Transparency = 0.95, ZIndex = 2 })
        Add("Corner" .. Index, "Line", { Visible = false, Thickness = 1, Transparency = 1, ZIndex = 3 })
    end
    local DrawingFont = GetDrawingTextFont()
    Add("Name", "Text", { Visible = false, Center = true, Outline = true, Font = DrawingFont, Transparency = 1, ZIndex = 5 })
    Add("Info", "Text", { Visible = false, Center = true, Outline = true, Font = DrawingFont, Transparency = 1, ZIndex = 5 })
    Add("HealthBack", "Square", { Visible = false, Filled = true, Color = Color3.new(0, 0, 0), Transparency = 0.86, ZIndex = 3 })
    Add("Health", "Square", { Visible = false, Filled = true, Transparency = 1, ZIndex = 4 })
    Add("HealthText", "Text", { Visible = false, Center = true, Outline = true, Font = DrawingFont, Transparency = 1, ZIndex = 5 })
    Add("Tracer", "Line", { Visible = false, Thickness = 1, Transparency = 1, ZIndex = 2 })
    return Data
end

local function EnsureCurvedTracerDrawings(Data)
    if Data.CurvedTracerReady then return end
    Data.CurvedTracerReady = true
    for Index = 1, 10 do Data.Drawings["TracerCurve" .. Index] = CreateDrawing("Line", { Visible = false, Thickness = 1, Transparency = 1, ZIndex = 2 }) end
end

local function HideTracerDrawings(Drawings)
    if Drawings.Tracer then Drawings.Tracer.Visible = false end
    for Index = 1, 10 do
        local Segment = Drawings["TracerCurve" .. Index]
        if Segment then Segment.Visible = false end
    end
end

local function HidePlayerVisual(Data)
    if not Data then return end
    for Unused, Object in pairs(Data.Drawings) do
        if Object then Object.Visible = false end
    end
end

local function DestroyPlayerVisual(Player)
    local Data = VisualState.Player.Objects[Player]
    if not Data then return end
    DisconnectVisualConnection(Data.CharacterAddedConnection)
    DisconnectVisualConnection(Data.CharacterRemovingConnection)
    for Unused, Object in pairs(Data.Drawings) do RemoveDrawing(Object) end
    if Data.Highlight and Data.Highlight.Parent then Data.Highlight:Destroy() end
    if Data.Glow and Data.Glow.Parent then Data.Glow:Destroy() end
    local Index = Data.ListIndex
    local Last = VisualState.Player.List[#VisualState.Player.List]
    if Index > 0 and Last then
        VisualState.Player.List[Index] = Last
        Last.ListIndex = Index
        VisualState.Player.List[#VisualState.Player.List] = nil
    end
    VisualState.Player.Objects[Player] = nil
end

local function ReconcilePlayerVisualCache()
    local ActivePlayers = {}
    for Unused, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            ActivePlayers[Player] = true
            local Data = VisualState.Player.Objects[Player]
            if not Data then Data = CreatePlayerVisual(Player, false) end
            local Resolved = ResolveTrackedCharacter(Player, Player.Character)
            if Data then
                local NeedsRefresh = false
                if Resolved and Data.Character ~= Resolved then
                    NeedsRefresh = true
                elseif not Data.Root or not Data.Root.Parent or not Data.Humanoid or not Data.Humanoid.Parent then
                    if Resolved then NeedsRefresh = true end
                end
                if NeedsRefresh then RefreshPlayerCharacter(Data, Resolved) end
            end
        end
    end
    local StalePlayers = {}
    for Player in pairs(VisualState.Player.Objects) do
        if not ActivePlayers[Player] or Player.Parent ~= Players then StalePlayers[#StalePlayers + 1] = Player end
    end
    for Unused, Player in ipairs(StalePlayers) do DestroyPlayerVisual(Player) end
end

local function EnsurePlayerCache()
    VisualState.Initialized = true
    ReconcilePlayerVisualCache()
    if not VisualState.PlayerAddedConnection then
        VisualState.PlayerAddedConnection = Players.PlayerAdded:Connect(function(Player)
            if Player ~= LocalPlayer then CreatePlayerVisual(Player, false) end
        end)
    end
    if not VisualState.PlayerRemovingConnection then
        VisualState.PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(Player) DestroyPlayerVisual(Player) end)
    end
    if not VisualState.WorldCharactersBound then
        VisualState.WorldCharactersBound = true
        local function BindWorldCharactersFolder(Folder)
            if not Folder then return end
            for Unused, Character in ipairs(Folder:GetChildren()) do
                local Player = Players:FindFirstChild(Character.Name)
                if Player and Player:IsA("Player") and Player ~= LocalPlayer then
                    local Data = VisualState.Player.Objects[Player] or CreatePlayerVisual(Player, false)
                    if Data then RefreshPlayerCharacter(Data, Character) end
                end
            end
            Folder.ChildAdded:Connect(function(Character)
                local Player = Players:FindFirstChild(Character.Name)
                if Player and Player:IsA("Player") and Player ~= LocalPlayer then
                    task.defer(function()
                        local Data = VisualState.Player.Objects[Player] or CreatePlayerVisual(Player, false)
                        if Data then RefreshPlayerCharacter(Data, Character) end
                    end)
                end
            end)
        end
        local function BindWorldContainer(Container)
            if not Container then return end
            local Characters = Container:FindFirstChild("Characters")
            if Characters then BindWorldCharactersFolder(Characters) end
            Container.ChildAdded:Connect(function(Child)
                if Child.Name == "Characters" then BindWorldCharactersFolder(Child) end
            end)
        end
        BindWorldContainer(workspace:FindFirstChild("©"))
        workspace.ChildAdded:Connect(function(Child)
            if Child.Name == "©" then BindWorldContainer(Child) end
        end)
    end
end

local function GetCachedToolName(Data, CurrentTime)
    if CurrentTime < Data.NextToolScan then return Data.ToolName end
    Data.NextToolScan = CurrentTime + 0.25
    local Tool = Data.Character and Data.Character:FindFirstChildOfClass("Tool")
    Data.ToolName = Tool and Tool.Name or nil
    return Data.ToolName
end

local function GetPlayerBox(CameraObject, Data)
    local Root = Data.Root
    local Head = Data.Head
    if not Root or not Head or not Root.Parent or not Head.Parent then
        RefreshPlayerCharacter(Data, Data.Player.Character)
        Root = Data.Root
        Head = Data.Head
    end
    if not Root or not Head then return nil end
    local RootScreen, RootVisible = CameraObject:WorldToViewportPoint(Root.Position)
    if RootScreen.Z <= 0 or not RootVisible then return nil end
    local TopScreen = CameraObject:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.72, 0))
    local BottomScreen = CameraObject:WorldToViewportPoint(Root.Position - Vector3.new(0, 3.15, 0))
    if TopScreen.Z <= 0 or BottomScreen.Z <= 0 then return nil end
    local Height = math.abs(BottomScreen.Y - TopScreen.Y)
    local ViewportSize = CameraObject.ViewportSize
    local FieldOfView = math.rad(CameraObject.FieldOfView)
    local Depth = math.max(RootScreen.Z, 0.35)
    local ExpectedHeight = (6.5 * ViewportSize.Y) / (2 * math.tan(FieldOfView * 0.5) * Depth)
    ExpectedHeight = math.clamp(ExpectedHeight, 4, ViewportSize.Y * 1.35)
    if Height < ExpectedHeight * 0.48 then
        Height = ExpectedHeight
        TopScreen = Vector3.new(RootScreen.X, RootScreen.Y - Height * 0.46, RootScreen.Z)
        BottomScreen = Vector3.new(RootScreen.X, TopScreen.Y + Height, RootScreen.Z)
    end
    if Height < 4 then return nil end
    local Width = math.clamp(Height * 0.62, 6, ViewportSize.X * 1.10)
    return Vector2.new(RootScreen.X - Width * 0.5, TopScreen.Y), Vector2.new(Width, Height), RootScreen, Vector2.new(TopScreen.X, TopScreen.Y), Vector2.new(BottomScreen.X, BottomScreen.Y)
end

local function SetLine(Line, From, To, Color, Visible, Thickness, Transparency)
    if not Line then return end
    Line.Visible = Visible
    if not Visible then return end
    Line.From = From
    Line.To = To
    Line.Color = Color
    if Thickness then Line.Thickness = Thickness end
    if Transparency then Line.Transparency = Transparency end
end

local function UpdateCornerBox(Data, Position, Size, Color, OutlineColor, Visible)
    local Width = Size.X
    local Height = Size.Y
    local CornerWidth = math.max(Width * 0.28, 4)
    local CornerHeight = math.max(Height * 0.20, 5)
    local X = Position.X
    local Y = Position.Y
    local Right = X + Width
    local Bottom = Y + Height
    local Segments = { { Vector2.new(X, Y), Vector2.new(X + CornerWidth, Y) }, { Vector2.new(X, Y), Vector2.new(X, Y + CornerHeight) }, { Vector2.new(Right, Y),
        Vector2.new(Right - CornerWidth, Y) }, { Vector2.new(Right, Y), Vector2.new(Right, Y + CornerHeight) }, { Vector2.new(X, Bottom), Vector2.new(X + CornerWidth, Bottom) },
        { Vector2.new(X, Bottom), Vector2.new(X, Bottom - CornerHeight) }, { Vector2.new(Right, Bottom), Vector2.new(Right - CornerWidth, Bottom) }, { Vector2.new(Right, Bottom),
        Vector2.new(Right, Bottom - CornerHeight) } }
    for Index, Segment in ipairs(Segments) do
        SetLine(Data.Drawings["CornerOutline" .. Index], Segment[1], Segment[2], OutlineColor, Visible, 3, 0.95)
        SetLine(Data.Drawings["Corner" .. Index], Segment[1], Segment[2], Color, Visible, 1, 1)
    end
end

local function GetTracerOrigin(ViewportSize)
    local Origin = VisualState.Player.TracerOrigin
    if Origin == "Top" then return Vector2.new(ViewportSize.X * 0.5, 2) end
    if Origin == "Center" then return Vector2.new(ViewportSize.X * 0.5, ViewportSize.Y * 0.5) end
    return Vector2.new(ViewportSize.X * 0.5, ViewportSize.Y - 2)
end

local function GetTracerEnd(Position, Size, RootScreen, HeadScreen, FeetScreen)
    local EndMode = VisualState.Player.TracerEnd
    if EndMode == "Head" then return HeadScreen end
    if EndMode == "Body" then return Vector2.new(RootScreen.X, Position.Y + Size.Y * 0.52) end
    return FeetScreen
end

local function QuadraticBezier(A, B, C, T)
    local Inverse = 1 - T
    return A * (Inverse * Inverse) + B * (2 * Inverse * T) + C * (T * T)
end

local function UpdateTracer(Data, ViewportSize, Position, Size, RootScreen, HeadScreen, FeetScreen)
    local Drawings = Data.Drawings
    if not VisualState.Player.Tracers then
        HideTracerDrawings(Drawings)
        return
    end
    local From = GetTracerOrigin(ViewportSize)
    local To = GetTracerEnd(Position, Size, RootScreen, HeadScreen, FeetScreen)
    local Color = VisualState.Player.TracerColor
    local Thickness = VisualState.Player.TracerThickness
    local Transparency = 1 - VisualState.Player.TracerTransparency
    if VisualState.Player.TracerStyle == "Straight" then
        SetLine(Drawings.Tracer, From, To, Color, true, Thickness, Transparency)
        for Index = 1, 10 do
            local Segment = Drawings["TracerCurve" .. Index]
            if Segment then Segment.Visible = false end
        end
        return
    end
    if Drawings.Tracer then Drawings.Tracer.Visible = false end
    EnsureCurvedTracerDrawings(Data)
    local Delta = To - From
    local Direction = Delta.X >= 0 and 1 or -1
    local Control = Vector2.new(From.X + Delta.X * 0.46 + Direction * math.min(math.abs(Delta.Y) * 0.12, 90), From.Y + Delta.Y * 0.42)
    local Previous = From
    for Index = 1, 10 do
        local T = Index / 10
        local Current = QuadraticBezier(From, Control, To, T)
        SetLine(Drawings["TracerCurve" .. Index], Previous, Current, Color, true, Thickness, Transparency)
        Previous = Current
    end
end

function HideTargetSnapline()
    local State = VisualState.Snapline

    if State.Line then State.Line.Visible = false end
    for _, Segment in ipairs(State.Curve) do
        if Segment then Segment.Visible = false end
    end
end

function EnsureTargetSnaplineDrawings()
    local State = VisualState.Snapline

    if not State.Line then
        State.Line = CreateDrawing("Line", {
            Visible = false,
            Thickness = State.Thickness,
            Transparency = 1 - State.Transparency,
            Color = State.Color,
            ZIndex = 8
        })
    end

    if #State.Curve == 0 then
        for Index = 1, 12 do
            State.Curve[Index] = CreateDrawing("Line", {
                Visible = false,
                Thickness = State.Thickness,
                Transparency = 1 - State.Transparency,
                Color = State.Color,
                ZIndex = 8
            })
        end
    end
end

function IsTargetSnaplinePlayerValid(Player)
    if not Player or Player == LocalPlayer or not Player.Parent then return false end

    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Character or not Humanoid or Humanoid.Health <= 0 or not Root then return false end

    if VisualState.Player.TeamCheck and LocalPlayer.Team and Player.Team == LocalPlayer.Team then return false end

    local LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if LocalRoot and (Root.Position - LocalRoot.Position).Magnitude > VisualState.Player.MaxDistance then return false end

    return true
end

function GetClosestSnaplinePlayerToCursor()
    local CameraObject = GetCamera()
    if not CameraObject then return nil end

    local MousePosition = UserInputService:GetMouseLocation()
    local BestPlayer = nil
    local BestDistance = math.huge

    for _, Player in ipairs(Players:GetPlayers()) do
        if IsTargetSnaplinePlayerValid(Player) then
            local Character = Player.Character
            local Part = Character and (Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart"))
            if Part then
                local ScreenPosition, OnScreen = CameraObject:WorldToViewportPoint(Part.Position)
                if OnScreen and ScreenPosition.Z > 0 then
                    local Distance = (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude
                    if Distance < BestDistance then
                        BestDistance = Distance
                        BestPlayer = Player
                    end
                end
            end
        end
    end

    return BestPlayer
end

function GetTargetSnaplinePlayer()
    local State = VisualState.Snapline

    if State.Source == "Closest to Cursor" then
        return GetClosestSnaplinePlayerToCursor()
    end

    if RageBotEnabled and IsTargetSnaplinePlayerValid(RageBotCurrentTarget) then
        return RageBotCurrentTarget
    end

    local AimTarget = S and S.AimBot and (S.AimBot.CurrentTarget or S.AimBot.Target)
    if S and S.AimBot and S.AimBot.Enabled and IsTargetSnaplinePlayerValid(AimTarget) then
        return AimTarget
    end

    return GetClosestSnaplinePlayerToCursor()
end

function GetTargetSnaplineWorldPosition(Character)
    if not Character then return nil end

    local TargetPart = VisualState.Snapline.TargetPart

    if TargetPart == "Head" then
        local Head = Character:FindFirstChild("Head")
        return Head and Head.Position or nil
    end

    if TargetPart == "Body" then
        local Body = Character:FindFirstChild("HumanoidRootPart")
            or Character:FindFirstChild("UpperTorso")
            or Character:FindFirstChild("Torso")

        return Body and Body.Position or nil
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Root then return nil end

    return Root.Position - Vector3.new(0, Humanoid and Humanoid.HipHeight + 1.7 or 3.2, 0)
end

function UpdateTargetSnapline()
    local State = VisualState.Snapline

    if not State.Enabled then
        HideTargetSnapline()
        return
    end

    EnsureTargetSnaplineDrawings()

    local CameraObject = GetCamera()
    local Target = GetTargetSnaplinePlayer()
    local Character = Target and Target.Character
    local WorldPosition = GetTargetSnaplineWorldPosition(Character)

    if not CameraObject or not WorldPosition then
        HideTargetSnapline()
        return
    end

    local ScreenPosition, OnScreen = CameraObject:WorldToViewportPoint(WorldPosition)
    if not OnScreen or ScreenPosition.Z <= 0 then
        HideTargetSnapline()
        return
    end

    local From = UserInputService:GetMouseLocation()
    local To = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
    local Transparency = 1 - math.clamp(State.Transparency, 0, 1)

    if State.Style == "Straight" then
        SetLine(State.Line, From, To, State.Color, true, State.Thickness, Transparency)

        for _, Segment in ipairs(State.Curve) do
            if Segment then Segment.Visible = false end
        end

        return
    end

    if State.Line then State.Line.Visible = false end

    local Delta = To - From
    local Direction = Delta.X >= 0 and 1 or -1
    local Control = Vector2.new(
        From.X + Delta.X * 0.5 + Direction * math.min(math.abs(Delta.Y) * 0.18, 80),
        From.Y + Delta.Y * 0.42
    )

    local Previous = From

    for Index = 1, 12 do
        local Current = QuadraticBezier(From, Control, To, Index / 12)
        SetLine(State.Curve[Index], Previous, Current, State.Color, true, State.Thickness, Transparency)
        Previous = Current
    end
end

local function ShouldRenderPlayer(Data, LocalRoot)
    if not Data.Character or not Data.Humanoid or not Data.Root or Data.Humanoid.Health <= 0 then return false end
    if VisualState.Player.TeamCheck and LocalPlayer.Team and Data.Player.Team == LocalPlayer.Team then return false end
    local Distance = (Data.Root.Position - LocalRoot.Position).Magnitude
    return Distance <= VisualState.Player.MaxDistance, Distance
end

local function UpdatePlayerESP()
    local CameraObject = GetCamera()
    local LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not CameraObject or not LocalRoot then
        for Unused, Data in ipairs(VisualState.Player.List) do HidePlayerVisual(Data) end
        return
    end
    local CurrentTime = os.clock()
    for Unused, Data in ipairs(VisualState.Player.List) do
        if not Data.DrawingsReady then CreatePlayerVisual(Data.Player, true) end
        if not Data.Root or not Data.Root.Parent or not Data.Humanoid or not Data.Humanoid.Parent or not Data.Character or not Data.Character.Parent then
            RefreshPlayerCharacter(Data, Data.Player and Data.Player.Character)
        end
        local ShouldRender, Distance = ShouldRenderPlayer(Data, LocalRoot)
        if not ShouldRender then
            HidePlayerVisual(Data)
            continue
        end
        local Position, Size, RootScreen, HeadScreen, FeetScreen = GetPlayerBox(CameraObject, Data)
        if not Position then
            HidePlayerVisual(Data)
            continue
        end
        local Drawings = Data.Drawings
        local FullBox = VisualState.Player.Boxes and VisualState.Player.BoxStyle == "Full"
        local CornerBox = VisualState.Player.Boxes and VisualState.Player.BoxStyle == "Corners"
        if Drawings.BoxOutline then
            Drawings.BoxOutline.Visible = FullBox
            Drawings.BoxOutline.Position = Position
            Drawings.BoxOutline.Size = Size
            Drawings.BoxOutline.Color = VisualState.Player.OutlineColor
        end
        if Drawings.Box then
            Drawings.Box.Visible = FullBox
            Drawings.Box.Position = Position
            Drawings.Box.Size = Size
            Drawings.Box.Color = VisualState.Player.BoxColor
        end
        UpdateCornerBox(Data, Position, Size, VisualState.Player.BoxColor, VisualState.Player.OutlineColor, CornerBox)
        if Drawings.Fill then
            Drawings.Fill.Visible = VisualState.Player.Fill
            Drawings.Fill.Position = Position
            Drawings.Fill.Size = Size
            Drawings.Fill.Color = VisualState.Player.FillColor
            Drawings.Fill.Transparency = 1 - VisualState.Player.FillTransparency
        end
        if Drawings.Name then
            Drawings.Name.Visible = VisualState.Player.Names
            Drawings.Name.Text = Data.Player.DisplayName ~= Data.Player.Name and(Data.Player.DisplayName .. " [" .. Data.Player.Name .. "]") or Data.Player.Name
            Drawings.Name.Size = VisualState.Player.TextSize
            Drawings.Name.Color = VisualState.Player.TextColor
            Drawings.Name.Position = Vector2.new(Position.X + Size.X * 0.5, Position.Y - VisualState.Player.TextSize - 2)
        end
        local InfoParts = {}
        if VisualState.Player.Distance then InfoParts[#InfoParts + 1] = tostring(math.floor(Distance + 0.5)) .. "m" end
        if VisualState.Player.Weapon then
            local ToolName = GetCachedToolName(Data, CurrentTime)
            if ToolName then InfoParts[#InfoParts + 1] = ToolName end
        end
        if Drawings.Info then
            Drawings.Info.Visible = #InfoParts > 0
            Drawings.Info.Text = table.concat(InfoParts, "  ·  ")
            Drawings.Info.Size = math.max(VisualState.Player.TextSize - 1, 10)
            Drawings.Info.Color = VisualState.Player.TextColor
            Drawings.Info.Position = Vector2.new(Position.X + Size.X * 0.5, Position.Y + Size.Y + 2)
        end
        local HealthPercent = math.clamp(Data.Humanoid.Health / math.max(Data.Humanoid.MaxHealth, 1), 0, 1)
        local HealthColor = VisualState.Player.HealthLowColor:Lerp(VisualState.Player.HealthHighColor, HealthPercent)
        if Drawings.HealthBack then
            Drawings.HealthBack.Visible = VisualState.Player.HealthBar
            Drawings.HealthBack.Position = Vector2.new(Position.X - 6, Position.Y)
            Drawings.HealthBack.Size = Vector2.new(3, Size.Y)
        end
        if Drawings.Health then
            Drawings.Health.Visible = VisualState.Player.HealthBar
            local HealthHeight = Size.Y * HealthPercent
            Drawings.Health.Position = Vector2.new(Position.X - 6, Position.Y + Size.Y - HealthHeight)
            Drawings.Health.Size = Vector2.new(3, HealthHeight)
            Drawings.Health.Color = HealthColor
        end
        if Drawings.HealthText then
            Drawings.HealthText.Visible = VisualState.Player.HealthText
            Drawings.HealthText.Text = tostring(math.floor(Data.Humanoid.Health + 0.5))
            Drawings.HealthText.Size = math.max(VisualState.Player.TextSize - 2, 9)
            Drawings.HealthText.Color = HealthColor
            Drawings.HealthText.Position = Vector2.new(Position.X - 16, Position.Y + Size.Y * (1 - HealthPercent) - 4)
        end
        UpdateTracer(Data, CameraObject.ViewportSize, Position, Size, RootScreen, HeadScreen, FeetScreen)
    end
end

local function DestroyChams(Data)
    if Data.Highlight and Data.Highlight.Parent then Data.Highlight:Destroy() end
    if Data.Glow and Data.Glow.Parent then Data.Glow:Destroy() end
    Data.Highlight = nil
    Data.Glow = nil
end

local function UpdatePlayerChams()
    if not VisualState.Player.Chams.Enabled then
        for Unused, Data in ipairs(VisualState.Player.List) do DestroyChams(Data) end
        return
    end
    for Unused, Data in ipairs(VisualState.Player.List) do
        local Character = Data.Character
        local Humanoid = Data.Humanoid
        if not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 then
            DestroyChams(Data)
            continue
        end
        local Highlight = Data.Highlight
        if not Highlight or Highlight.Parent ~= Character then
            if Highlight then Highlight:Destroy() end
            Highlight = Instance.new("Highlight")
            Highlight.Name = "RadiantPlayerChams"
            Highlight.Adornee = Character
            Highlight.Parent = Character
            Data.Highlight = Highlight
        end
        Highlight.FillColor = VisualState.Player.Chams.FillColor
        Highlight.OutlineColor = VisualState.Player.Chams.OutlineColor
        Highlight.FillTransparency = VisualState.Player.Chams.FillTransparency
        Highlight.OutlineTransparency = VisualState.Player.Chams.OutlineTransparency
        Highlight.DepthMode = VisualState.Player.Chams.ThroughWalls and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
        if VisualState.Player.Chams.GlowEnabled then
            local Glow = Data.Glow
            if not Glow or Glow.Parent ~= Character then
                if Glow then Glow:Destroy() end
                Glow = Instance.new("Highlight")
                Glow.Name = "RadiantPlayerGlow"
                Glow.Adornee = Character
                Glow.Parent = Character
                Data.Glow = Glow
            end
            Glow.FillColor = VisualState.Player.Chams.GlowColor
            Glow.OutlineColor = VisualState.Player.Chams.GlowColor
            Glow.FillTransparency = math.clamp(VisualState.Player.Chams.GlowTransparency + 0.30, 0, 1)
            Glow.OutlineTransparency = VisualState.Player.Chams.GlowTransparency
            Glow.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        elseif Data.Glow then
            Data.Glow:Destroy()
            Data.Glow = nil
        end
    end
end

local function SaveWorldOriginal()
    if VisualState.World.Original then return end
    VisualState.World.Original = { Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogColor =
        Lighting.FogColor, FogStart = Lighting.FogStart, FogEnd = Lighting.FogEnd }
end

local function SetWorldProperty(Object, Property, Value)
    if Object[Property] ~= Value then Object[Property] = Value end
end

local function EnsureWorldEffects()
    local ColorCorrection = VisualState.World.ColorCorrection
    if not ColorCorrection or not ColorCorrection.Parent then
        ColorCorrection = Instance.new("ColorCorrectionEffect")
        ColorCorrection.Name = "RadiantWorldColor"
        ColorCorrection.Parent = Lighting
        VisualState.World.ColorCorrection = ColorCorrection
    end
    SetWorldProperty(ColorCorrection, "Saturation", VisualState.World.Saturation)
    SetWorldProperty(ColorCorrection, "Contrast", VisualState.World.Contrast)
    SetWorldProperty(ColorCorrection, "TintColor", VisualState.World.TintColor)
    local Bloom = VisualState.World.BloomEffect
    if VisualState.World.Bloom then
        if not Bloom or not Bloom.Parent then
            Bloom = Instance.new("BloomEffect")
            Bloom.Name = "RadiantWorldBloom"
            Bloom.Parent = Lighting
            VisualState.World.BloomEffect = Bloom
        end
        SetWorldProperty(Bloom, "Intensity", 0.28)
        SetWorldProperty(Bloom, "Size", 28)
        SetWorldProperty(Bloom, "Threshold", 1.15)
    elseif Bloom then
        Bloom:Destroy()
        VisualState.World.BloomEffect = nil
    end
end

local function ApplyWorldVisuals()
    if not VisualState.World.Enabled or VisualState.World.Applying then return end
    VisualState.World.Applying = true
    local Success = pcall(function()
        SaveWorldOriginal()
        SetWorldProperty(Lighting, "Ambient", VisualState.World.Ambient)
        SetWorldProperty(Lighting, "OutdoorAmbient", VisualState.World.OutdoorAmbient)
        SetWorldProperty(Lighting, "Brightness", VisualState.World.Brightness)
        SetWorldProperty(Lighting, "ClockTime", VisualState.World.ClockTime)
        if VisualState.World.FogEnabled then
            SetWorldProperty(Lighting, "FogColor", VisualState.World.FogColor)
            SetWorldProperty(Lighting, "FogStart", 0)
            SetWorldProperty(Lighting, "FogEnd", VisualState.World.FogDistance)
        else
            SetWorldProperty(Lighting, "FogStart", 0)
            SetWorldProperty(Lighting, "FogEnd", 1000000)
        end
        EnsureWorldEffects()
    end)
    VisualState.World.Applying = false
    return Success
end

local function StartWorldOverride()
    SaveWorldOriginal()
    pcall(function() RunService:UnbindFromRenderStep(VisualState.World.RenderStepName) end)
    local Priority = Enum.RenderPriority.Last.Value + 100 + 100
    RunService:BindToRenderStep(VisualState.World.RenderStepName, Priority, ApplyWorldVisuals)
    VisualState.World.Bound = true
    ApplyWorldVisuals()
end

local function RestoreWorldVisuals()
    pcall(function() RunService:UnbindFromRenderStep(VisualState.World.RenderStepName) end)
    VisualState.World.Bound = false
    local Original = VisualState.World.Original
    if Original then
        pcall(function()
            Lighting.Ambient = Original.Ambient
            Lighting.OutdoorAmbient = Original.OutdoorAmbient
            Lighting.Brightness = Original.Brightness
            Lighting.ClockTime = Original.ClockTime
            Lighting.FogColor = Original.FogColor
            Lighting.FogStart = Original.FogStart
            Lighting.FogEnd = Original.FogEnd
        end)
    end
    if VisualState.World.ColorCorrection then
        VisualState.World.ColorCorrection:Destroy()
        VisualState.World.ColorCorrection = nil
    end
    if VisualState.World.BloomEffect then
        VisualState.World.BloomEffect:Destroy()
        VisualState.World.BloomEffect = nil
    end
    VisualState.World.Original = nil
    VisualState.World.Applying = false
end

local function GetWorldAdornee(Object)
    if Object:IsA("BasePart") then return Object end
    if Object:IsA("Model") then return Object.PrimaryPart or Object:FindFirstChildWhichIsA("BasePart", true) end
    return Object:FindFirstChildWhichIsA("BasePart", true)
end

local function GetWorldObjectBrokenState(Object)
    local Values = Object and Object:FindFirstChild("Values")
    local Broken = Values and Values:FindFirstChild("Broken")
    if Broken and Broken:IsA("ValueBase") then return Broken.Value == true, true end
    return false, false
end

local function GetWorldObjectColor(Object, Kind)
    local IsBroken = GetWorldObjectBrokenState(Object)
    if IsBroken then return VisualState.WorldESP.BrokenColor end
    if Kind == "SAFE" then return VisualState.WorldESP.SafeColor end
    return VisualState.WorldESP.CashColor
end

local function GetSafeDisplayName(Object)
    local Name = string.lower(Object.Name)
    if string.find(Name, "register", 1, true) then return "Register" end
    if string.find(Name, "small", 1, true) then return "Small Safe" end
    if string.find(Name, "medium", 1, true) then return "Medium Safe" end
    if string.find(Name, "large", 1, true) then return "Large Safe" end
    return "Safe"
end

local function GetWorldObjectText(Object, Kind)
    if Kind == "SAFE" then return GetSafeDisplayName(Object) end
    return "Cash"
end

local function CreateWorldLabel(Object, Kind)
    local Adornee = GetWorldAdornee(Object)
    if not Adornee then return nil end
    local Billboard = Instance.new("BillboardGui")
    Billboard.Name = "RadiantWorld" .. Kind
    Billboard.AlwaysOnTop = true
    Billboard.Size = UDim2.new(0, 190, 0, 24)
    Billboard.StudsOffset = Vector3.new(0, 2.25, 0)
    Billboard.MaxDistance = VisualState.WorldESP.MaxDistance
    Billboard.Adornee = Adornee
    Billboard.Parent = PlayerGui
    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Size = UDim2.new(1, 0, 1, 0)
    Label.BackgroundTransparency = 1
    Label.FontFace = UiFont
    Label.TextSize = 13
    Label.TextStrokeTransparency = 0.25
    Label.TextColor3 = GetWorldObjectColor(Object, Kind)
    Label.Parent = Billboard
    local Data = { Object = Object, Kind = Kind, Billboard = Billboard, Label = Label, Adornee = Adornee }
    VisualState.WorldESP.Objects[Object] = Data
    return Data
end

local function GetWorldObjects()
    local Objects = {}
    if VisualState.WorldESP.Safes then
        local Map = workspace:FindFirstChild("Map")
        local Folder = Map and Map:FindFirstChild("BredMakurz")
        if Folder then
            for Unused, Object in ipairs(Folder:GetChildren()) do
                local Name = string.lower(Object.Name)
                if string.find(Name, "safe", 1, true) or string.find(Name, "register", 1, true) then Objects[Object] = "SAFE" end
            end
        end
    end
    if VisualState.WorldESP.Cash then
        local Filter = workspace:FindFirstChild("Filter")
        local Folder = Filter and Filter:FindFirstChild("SpawnedBread")
        if Folder then
            for Unused, Object in ipairs(Folder:GetChildren()) do Objects[Object] = "CASH" end
        end
    end
    return Objects
end

local function UpdateWorldESP()
    local CurrentTime = os.clock()
    if CurrentTime - VisualState.WorldESP.LastScan < 0.20 then return end
    VisualState.WorldESP.LastScan = CurrentTime
    local Current = GetWorldObjects()
    for Object, Data in pairs(VisualState.WorldESP.Objects) do
        if not Current[Object] or not Object.Parent then
            if Data.Billboard then Data.Billboard:Destroy() end
            VisualState.WorldESP.Objects[Object] = nil
        end
    end
    local LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    for Object, Kind in pairs(Current) do
        local Data = VisualState.WorldESP.Objects[Object] or CreateWorldLabel(Object, Kind)
        if Data then
            local Distance = LocalRoot and Data.Adornee and(Data.Adornee.Position - LocalRoot.Position).Magnitude or 0
            Data.Billboard.MaxDistance = VisualState.WorldESP.MaxDistance
            Data.Label.TextColor3 = GetWorldObjectColor(Object, Kind)
            Data.Label.Text = GetWorldObjectText(Object, Kind, Distance)
        end
    end
end

local function EnsureVisualEngine()
    EnsurePlayerCache()
    if VisualState.Connection then return end
    VisualState.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        DeltaTime = math.clamp(DeltaTime, 0, 0.05)
        VisualState.CacheClock = VisualState.CacheClock + DeltaTime
        if VisualState.CacheClock >= 0.40 then
            VisualState.CacheClock = 0
            ReconcilePlayerVisualCache()
        end
        VisualState.PlayerClock = VisualState.PlayerClock + DeltaTime
        if VisualState.Player.Enabled and VisualState.PlayerClock >= VisualState.Player.UpdateInterval then
            VisualState.PlayerClock = VisualState.PlayerClock % VisualState.Player.UpdateInterval
            UpdatePlayerESP()
        end

        VisualState.Snapline.Clock = VisualState.Snapline.Clock + DeltaTime
        if VisualState.Snapline.Clock >= VisualState.Snapline.UpdateInterval then
            VisualState.Snapline.Clock = VisualState.Snapline.Clock % VisualState.Snapline.UpdateInterval
            UpdateTargetSnapline()
        end
        VisualState.ChamsClock = VisualState.ChamsClock + DeltaTime
        if VisualState.ChamsClock >= 0.20 then
            VisualState.ChamsClock = 0
            UpdatePlayerChams()
        end
        VisualState.WorldClock = VisualState.WorldClock + DeltaTime
        if VisualState.WorldClock >= 0.50 then
            VisualState.WorldClock = 0
            if VisualState.WorldESP.Safes or VisualState.WorldESP.Cash then
                UpdateWorldESP()
            elseif next(VisualState.WorldESP.Objects) then
                for Object, Data in pairs(VisualState.WorldESP.Objects) do
                    if Data.Billboard then Data.Billboard:Destroy() end
                    VisualState.WorldESP.Objects[Object] = nil
                end
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    VisualState.PlayerClock = 0
    VisualState.ChamsClock = 0
    VisualState.CacheClock = 0
    task.defer(function() ReconcilePlayerVisualCache() end)
end)

local function DestroyVisualEngine()
    if VisualState.Connection then
        VisualState.Connection:Disconnect()
        VisualState.Connection = nil
    end
    DisconnectVisualConnection(VisualState.PlayerAddedConnection)
    DisconnectVisualConnection(VisualState.PlayerRemovingConnection)
    VisualState.PlayerAddedConnection = nil
    VisualState.PlayerRemovingConnection = nil
    local PlayersToRemove = {}
    for Player in pairs(VisualState.Player.Objects) do PlayersToRemove[#PlayersToRemove + 1] = Player end
    for Unused, Player in ipairs(PlayersToRemove) do DestroyPlayerVisual(Player) end
    VisualState.Player.List = {}

    if VisualState.Snapline.Line then
        RemoveDrawing(VisualState.Snapline.Line)
        VisualState.Snapline.Line = nil
    end

    for Index, Segment in ipairs(VisualState.Snapline.Curve) do
        RemoveDrawing(Segment)
        VisualState.Snapline.Curve[Index] = nil
    end

    VisualState.Snapline.Clock = 0
    VisualState.CacheClock = 0
    VisualState.Initialized = false
    for Object, Data in pairs(VisualState.WorldESP.Objects) do
        if Data.Billboard then Data.Billboard:Destroy() end
        VisualState.WorldESP.Objects[Object] = nil
    end
    RestoreWorldVisuals()
end

local function AutoPickupMoneyLoop()
    while AutoPickupMoneyEnabled do
        local CashFolder = workspace:FindFirstChild("Filter") and workspace.Filter:FindFirstChild("SpawnedBread")
        local RemoteEvent = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("CZDPZUS")
        if CashFolder and RemoteEvent then
            local CharacterModel = LocalPlayer.Character
            local RootPart = CharacterModel and CharacterModel:FindFirstChild("HumanoidRootPart")
            if RootPart then
                for Unused, ValueItem in ipairs(CashFolder:GetChildren()) do
                    if(RootPart.Position - ValueItem.Position).Magnitude < 50 then
                        pcall(function() RemoteEvent:FireServer(ValueItem) end)
                        task.wait(0.35)
                    end
                end
            end
        end
        task.wait(math.random(30, 50) / 100)
    end
    AutoPickupMoneyCoroutine = nil
end

local function AutoPickupMoneyEnable()
    if AutoPickupMoneyEnabled then return end
    AutoPickupMoneyEnabled = true
    if not AutoPickupMoneyCoroutine then AutoPickupMoneyCoroutine = task.spawn(AutoPickupMoneyLoop) end
end

local function AutoPickupMoneyDisable()
    if not AutoPickupMoneyEnabled then return end
    AutoPickupMoneyEnabled = false
    MoneyCooldown = false
end

function FastPickupEnable()
    if FastPickupEnabled then return end
    FastPickupEnabled = true
    for Unused, PromptObject in ipairs(workspace:GetDescendants()) do
        if PromptObject:IsA("ProximityPrompt") then
            PromptObject.HoldDuration = 0
            PromptObject:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                if FastPickupEnabled then PromptObject.HoldDuration = 0 end
            end)
        end
    end
    FastPickupConnection = game.DescendantAdded:Connect(function(AddedDescendant)
        if AddedDescendant:IsA("ProximityPrompt") then
            AddedDescendant.HoldDuration = 0
            AddedDescendant:GetPropertyChangedSignal("HoldDuration"):Connect(function()
                if FastPickupEnabled then AddedDescendant.HoldDuration = 0 end
            end)
        end
    end)
end

function FastPickupDisable()
    if not FastPickupEnabled then return end
    FastPickupEnabled = false
    if FastPickupConnection then
        FastPickupConnection:Disconnect()
        FastPickupConnection = nil
    end
end

local function NoFailLockpickEnable()
    if NoFailLockpickEnabled then return end
    NoFailLockpickEnabled = true
    LockpickAddedConnection = PlayerGui.ChildAdded:Connect(function(ItemObject)
        if ItemObject.Name == "LockpickGUI" then
            pcall(function()
                local MainFrame = ItemObject:WaitForChild("MF", 10)
                if not MainFrame then return end
                local LockpickFrame = MainFrame:WaitForChild("LP_Frame", 10)
                if not LockpickFrame then return end
                local FramesFolder = LockpickFrame:WaitForChild("Frames", 10)
                if not FramesFolder then return end
                for Unused, ButtonName in ipairs({ "B1", "B2", "B3" }) do
                    local ButtonItem = FramesFolder:FindFirstChild(ButtonName)
                    if ButtonItem and ButtonItem:FindFirstChild("Bar") and ButtonItem.Bar:FindFirstChild("UIScale") then ButtonItem.Bar.UIScale.Scale = 10 end
                end
            end)
        end
    end)
end

local function NoFailLockpickDisable()
    if not NoFailLockpickEnabled then return end
    NoFailLockpickEnabled = false
    if LockpickAddedConnection then
        LockpickAddedConnection:Disconnect()
        LockpickAddedConnection = nil
    end
    pcall(function()
        local LockpickGUI = PlayerGui:FindFirstChild("LockpickGUI")
        if not LockpickGUI then return end
        local MainFrame = LockpickGUI:FindFirstChild("MF")
        if not MainFrame then return end
        local LockpickFrame = MainFrame:FindFirstChild("LP_Frame")
        if not LockpickFrame then return end
        local FramesFolder = LockpickFrame:FindFirstChild("Frames")
        if not FramesFolder then return end
        for Unused, ButtonName in ipairs({ "B1", "B2", "B3" }) do
            local ButtonItem = FramesFolder:FindFirstChild(ButtonName)
            if ButtonItem and ButtonItem:FindFirstChild("Bar") and ButtonItem.Bar:FindFirstChild("UIScale") then ButtonItem.Bar.UIScale.Scale = 1 end
        end
    end)
end

local function NearbyDoorInteractionLoop()
    while OpenNearbyDoorsEnabled or UnlockNearbyDoorsEnabled do
        local CharacterModel = LocalPlayer.Character
        local RootPart = CharacterModel and CharacterModel:FindFirstChild("HumanoidRootPart")
        local HumanoidInstance = CharacterModel and CharacterModel:FindFirstChildOfClass("Humanoid")
        if RootPart and HumanoidInstance and HumanoidInstance.Health > 0 then
            local DoorsFolder = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Doors")
            if DoorsFolder then
                for Unused, DoorInstance in ipairs(DoorsFolder:GetChildren()) do
                    local DoorBase = DoorInstance:FindFirstChild("DoorBase")
                    local ValuesFolder = DoorInstance:FindFirstChild("Values")
                    local EventsFolder = DoorInstance:FindFirstChild("Events")
                    if DoorBase and ValuesFolder and EventsFolder then
                        if(RootPart.Position - DoorBase.Position).Magnitude <= 6 then
                            local ToggleEvent = EventsFolder:FindFirstChild("Toggle")
                            if not ToggleEvent then continue end
                            if UnlockNearbyDoorsEnabled then
                                local LockedValue = ValuesFolder:FindFirstChild("Locked")
                                local LockArg = DoorInstance:FindFirstChild("Lock")
                                if LockedValue and LockArg and LockedValue.Value == true then ToggleEvent:FireServer("Unlock", LockArg) end
                            end
                            if OpenNearbyDoorsEnabled then
                                local OpenValue = ValuesFolder:FindFirstChild("Open")
                                local KnobArg = DoorInstance:FindFirstChild("Knob2") or DoorInstance:FindFirstChild("Knob")
                                if OpenValue and KnobArg and OpenValue.Value == false then
                                    local IsLocked = ValuesFolder:FindFirstChild("Locked")
                                    if not IsLocked or IsLocked.Value == false then ToggleEvent:FireServer("Open", KnobArg) end
                                end
                            end
                        end
                    end
                end
            end
        end
        task.wait(math.random(30, 50) / 100)
    end
    NearbyDoorInteractionCoroutine = nil
end

local function StartStopDoorLoop()
    if(OpenNearbyDoorsEnabled or UnlockNearbyDoorsEnabled) and not NearbyDoorInteractionCoroutine then NearbyDoorInteractionCoroutine = task.spawn(NearbyDoorInteractionLoop) end
end

local function OpenNearbyDoorsEnable()
    if OpenNearbyDoorsEnabled then return end
    OpenNearbyDoorsEnabled = true
    StartStopDoorLoop()
end

local function OpenNearbyDoorsDisable()
    if not OpenNearbyDoorsEnabled then return end
    OpenNearbyDoorsEnabled = false
end

local function UnlockNearbyDoorsEnable()
    if UnlockNearbyDoorsEnabled then return end
    UnlockNearbyDoorsEnabled = true
    StartStopDoorLoop()
end

local function UnlockNearbyDoorsDisable()
    if not UnlockNearbyDoorsEnabled then return end
    UnlockNearbyDoorsEnabled = false
end

function FlyEnable()
    if FlyEnabled then return end
    FlyEnabled = true
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid.PlatformStand = true end
    local FlySpeed = FlyMethod == "Bypass" and 60 or 40
    local Events = ReplicatedStorage:FindFirstChild("Events")
    local FlyRemote = FlyMethod == "Bypass" and Events and Events:FindFirstChild("__RZDONL") or nil
    if FlyConnection then FlyConnection:Disconnect() end
    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local CurrentCharacter = LocalPlayer.Character
        local RootPart = CurrentCharacter and CurrentCharacter:FindFirstChild("HumanoidRootPart")
        local CameraObject = GetCamera()
        if not RootPart or not CameraObject then return end
        local MoveDirection = Vector3.new()
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then MoveDirection = MoveDirection + CameraObject.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then MoveDirection = MoveDirection - CameraObject.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then MoveDirection = MoveDirection - CameraObject.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then MoveDirection = MoveDirection + CameraObject.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then MoveDirection = MoveDirection + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then MoveDirection = MoveDirection - Vector3.new(0, 1, 0) end
        if MoveDirection.Magnitude > 0 then MoveDirection = MoveDirection.Unit * FlySpeed end
        RootPart.AssemblyLinearVelocity = MoveDirection
        if FlyMethod == "Bypass" and FlyRemote then FlyRemote:FireServer("__r", Vector3.new(), RootPart.CFrame, false) end
    end)
end

function FlyDisable()
    if not FlyEnabled then return end
    FlyEnabled = false
    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end
    local CharacterObject = LocalPlayer.Character
    if CharacterObject then
        local HumanoidObject = CharacterObject:FindFirstChildOfClass("Humanoid")
        if HumanoidObject then HumanoidObject.PlatformStand = false end
        local RootPart = CharacterObject:FindFirstChild("HumanoidRootPart")
        if RootPart then RootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end
    end
end

local function ClearNoclipCharacterConnections()
    if NoclipDescendantConnection then
        NoclipDescendantConnection:Disconnect()
        NoclipDescendantConnection = nil
    end
    table.clear(NoclipParts)
end

local function RegisterNoclipPart(PartObject)
    if not PartObject:IsA("BasePart") then return end
    NoclipParts[PartObject] = true
    if NoclipOriginalCollision[PartObject] == nil then NoclipOriginalCollision[PartObject] = PartObject.CanCollide end
    PartObject.CanCollide = false
end

local function BindNoclipCharacter(CharacterObject)
    ClearNoclipCharacterConnections()
    if not CharacterObject then return end
    for Unused, DescendantObject in ipairs(CharacterObject:GetDescendants()) do RegisterNoclipPart(DescendantObject) end
    NoclipDescendantConnection = CharacterObject.DescendantAdded:Connect(function(DescendantObject)
        if NoclipEnabled then RegisterNoclipPart(DescendantObject) end
    end)
end

function NoclipEnable()
    if NoclipEnabled then return end
    NoclipEnabled = true
    BindNoclipCharacter(LocalPlayer.Character)
    if NoclipCharacterConnection then NoclipCharacterConnection:Disconnect() end
    NoclipCharacterConnection = LocalPlayer.CharacterAdded:Connect(function(CharacterObject)
        if NoclipEnabled then BindNoclipCharacter(CharacterObject) end
    end)
    if NoclipConnection then NoclipConnection:Disconnect() end
    NoclipConnection = RunService.Stepped:Connect(function()
        if not NoclipEnabled then return end
        for PartObject in pairs(NoclipParts) do
            if PartObject.Parent and PartObject.CanCollide then PartObject.CanCollide = false end
        end
    end)
end

function NoclipDisable()
    if not NoclipEnabled then return end
    NoclipEnabled = false
    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end
    if NoclipCharacterConnection then
        NoclipCharacterConnection:Disconnect()
        NoclipCharacterConnection = nil
    end
    ClearNoclipCharacterConnections()
    for PartObject, OriginalValue in pairs(NoclipOriginalCollision) do
        if PartObject.Parent then PartObject.CanCollide = OriginalValue end
        NoclipOriginalCollision[PartObject] = nil
    end
end

local InvisibilityController = {}
do
    repeat task.wait() until game:IsLoaded()
    local CloneRef = cloneref or function(...) return ... end
    local Service = setmetatable({}, { __index = function(Unused, KeyValue) return CloneRef(game:GetService(KeyValue)) end })
    local P = Service.Players.LocalPlayer
    local Char = P.Character or P.CharacterAdded:Wait()
    local HMND, HRP
    local CharacterParts = {}
    local function Refresh()
        Char = P.Character
        table.clear(CharacterParts)
        if Char then
            HRP = Char:FindFirstChild("HumanoidRootPart")
            HMND = Char:FindFirstChildOfClass("Humanoid")
            for Unused, DescendantObject in ipairs(Char:GetDescendants()) do
                if DescendantObject:IsA("BasePart") then CharacterParts[#CharacterParts + 1] = DescendantObject end
            end
        else
            HRP = nil
            HMND = nil
        end
    end
    Refresh()
    local InvisEnabled = false
    local Track = nil
    local Anim = Instance.new("Animation")
    Anim.AnimationId = "rbxassetid://215384594"
    local InvisFixed = true
    if Char and not Char:FindFirstChild("Torso") then
        pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Invisibility FAILED", Text = "Requires R6 Avatar", Duration = 5 }) end)
        InvisFixed = false
    end
    local HUD = Instance.new("ScreenGui")
    HUD.Name = "InvisWarning"
    HUD.Parent = Service.CoreGui
    local Warn = Instance.new("TextLabel", HUD)
    Warn.Text = "⚠️ You are visible ⚠️"
    Warn.Visible = false
    Warn.Size = UDim2.new(0, 200, 0, 30)
    Warn.Position = UDim2.new(0.5, -100, 0.85, 0)
    Warn.BackgroundTransparency = 1
    Warn.FontFace = UiFont
    Warn.TextSize = 24
    Warn.TextColor3 = Color3.fromRGB(255, 255, 0)
    Warn.TextStrokeTransparency = 0.5
    Warn.ZIndex = 10
    local function LoadTrack()
        if Track then
            pcall(function() Track:Stop() end)
            Track = nil
        end
        if HMND then
            local WasSuccessful, CallResult = pcall(function() return HMND:LoadAnimation(Anim) end)
            if WasSuccessful then
                Track = CallResult
                Track.Priority = Enum.AnimationPriority.Action4
            end
        end
    end
    function InvisibilityController.Enable()
        if InvisEnabled then
            InvisibilityEnabled = true
            return true
        end
        if not InvisFixed then
            InvisibilityEnabled = false
            return false
        end
        Refresh()
        if not Char or not HMND or not HRP then
            InvisibilityEnabled = false
            return false
        end
        if not Char:FindFirstChild("Torso") then
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Invisibility FAILED", Text = "Requires R6 Avatar", Duration = 5 }) end)
            InvisibilityEnabled = false
            return false
        end
        InvisEnabled = true
        InvisibilityEnabled = true
        local CameraObject = GetCamera()
        if CameraObject then CameraObject.CameraSubject = HRP end
        LoadTrack()
        return true
    end
    function InvisibilityController.Disable()
        if not InvisEnabled then
            InvisibilityEnabled = false
            Warn.Visible = false
            return true
        end
        InvisEnabled = false
        InvisibilityEnabled = false
        if Track then
            pcall(function() Track:Stop() end)
        end
        if HMND then
            local CameraObject = GetCamera()
            if CameraObject then CameraObject.CameraSubject = HMND end
        end
        if Char then
            for Unused, ValueItem in ipairs(CharacterParts) do
                if ValueItem.Parent and ValueItem.Transparency == 0.5 then ValueItem.Transparency = 0 end
            end
        end
        Warn.Visible = false
        return true
    end
    InvisibilityController.IsEnabled = function() return InvisEnabled end
    P.CharacterAdded:Connect(function()
        if Track then
            pcall(function() Track:Stop() end)
            Track = nil
        end
        task.wait()
        Refresh()
        if not HMND then
            task.wait(0.5)
            Refresh()
            if not HMND then
                InvisFixed = false
                if InvisEnabled then InvisibilityController.Disable() end
                return
            end
        end
        if HMND.RigType ~= Enum.HumanoidRigType.R6 then
            InvisFixed = false
            if InvisEnabled then InvisibilityController.Disable() end
            pcall(function() game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Invisibility Warning", Text = "Non-R6 Avatar", Duration = 5 }) end)
            return
        else
            InvisFixed = true
        end
        if InvisEnabled then
            if HRP then
                local CameraObject = GetCamera()
                if CameraObject then CameraObject.CameraSubject = HRP end
            end
            LoadTrack()
        end
    end)
    P.CharacterRemoving:Connect(function()
        if Track then
            pcall(function() Track:Stop() end)
            Track = nil
        end
        Warn.Visible = false
    end)
    Service.RunService.Heartbeat:Connect(function(DeltaTime)
        if not InvisEnabled or not InvisFixed then
            if not InvisEnabled and Char then
                for Unused, ValueItem in ipairs(CharacterParts) do
                    if ValueItem.Parent and ValueItem.Transparency == 0.5 then ValueItem.Transparency = 0 end
                end
            end
            Warn.Visible = false
            return
        end
        if not Char or not HMND or not HRP or not HMND:IsDescendantOf(workspace) or HMND.Health <= 0 then
            Warn.Visible = false
            return
        end
        Warn.Visible = not(HMND and HMND:IsDescendantOf(workspace) and HMND.FloorMaterial ~= Enum.Material.Air)
        local MovementSpeed = 12
        if HMND.MoveDirection.Magnitude > 0 then HRP.CFrame = HRP.CFrame + HMND.MoveDirection * MovementSpeed * DeltaTime end
        local OldCF = HRP.CFrame
        local OldOff = HMND.CameraOffset
        local CameraObject = GetCamera()
        local Unused, YValue
        if CameraObject then
            Unused, YValue = CameraObject.CFrame:ToOrientation()
        else
            YValue = 0
        end
        HRP.CFrame = CFrame.new(HRP.Position) * CFrame.fromOrientation(0, YValue, 0) * CFrame.Angles(math.rad(90), 0, 0)
        HMND.CameraOffset = Vector3.new(0, 1.44, 0)
        if Track then
            pcall(function()
                if not Track.IsPlaying then Track:Play() end
                Track:AdjustSpeed(0)
                Track.TimePosition = 0.3
            end)
        else
            LoadTrack()
        end
        Service.RunService.RenderStepped:Wait()
        if HMND and HMND:IsDescendantOf(workspace) then HMND.CameraOffset = OldOff end
        if HRP and HRP:IsDescendantOf(workspace) then HRP.CFrame = OldCF end
        if Track then
            pcall(function() Track:Stop() end)
        end
        if HRP and HRP:IsDescendantOf(workspace) and CameraObject then
            local LookDirection = CameraObject.CFrame.LookVector
            local FlatDirection = Vector3.new(LookDirection.X, 0, LookDirection.Z).Unit
            if FlatDirection.Magnitude > 0.1 then HRP.CFrame = CFrame.new(HRP.Position, HRP.Position + FlatDirection) end
        end
        if Char then
            for Unused, ValueItem in ipairs(CharacterParts) do
                if ValueItem.Parent and ValueItem.Transparency ~= 1 then ValueItem.Transparency = 0.5 end
            end
        end
    end)
end

function InvisibilityEnable()
    if InvisibilityEnabled then return end
    InvisibilityController.Enable()
end

function InvisibilityDisable()
    if not InvisibilityEnabled then return end
    InvisibilityController.Disable()
end

function AntiAFKEnable()
    if AntiAFKEnabled then return end
    AntiAFKEnabled = true
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
    AntiAFKTimer = 0
    AntiAFKConnection = RunService.Heartbeat:Connect(function(DeltaTime)
        if not AntiAFKEnabled then return end
        AntiAFKTimer = AntiAFKTimer + DeltaTime
        if AntiAFKTimer >= 120 then
            AntiAFKTimer = 0
            SendKeyPress(Enum.KeyCode.W, 0.1)
        end
    end)
end

function AntiAFKDisable()
    if not AntiAFKEnabled then return end
    AntiAFKEnabled = false
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
    AntiAFKTimer = 0
end

function CrowbarAuraEnable()
    if CrowbarAuraEnabled then return end
    CrowbarAuraEnabled = true
    CrowbarAuraCoroutine = task.spawn(function()
        while CrowbarAuraEnabled do
            pcall(function()
                local CharacterModel = LocalPlayer.Character
                local RootPart = CharacterModel and CharacterModel:FindFirstChild("HumanoidRootPart")
                if not RootPart then return end
                local ToolObject = CharacterModel:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChild("Crowbar")
                if not ToolObject then
                    task.wait(math.random(40, 70) / 100)
                    return
                end
                local FolderObject = workspace.Map and workspace.Map:FindFirstChild("BredMakurz")
                if not FolderObject then return end
                local Nearest, NearestDist = nil, math.huge
                for Unused, ValueItem in pairs(FolderObject:GetChildren()) do
                    if string.find(ValueItem.Name, "Safe") or string.find(ValueItem.Name, "Register") then
                        local Broken = ValueItem.Values and ValueItem.Values:FindFirstChild("Broken")
                        if Broken and Broken.Value == false then
                            local PartObject = ValueItem.PrimaryPart or ValueItem:FindFirstChild("MainPart") or ValueItem:FindFirstChild("PosPart")
                            if PartObject then
                                local DistanceValue = (PartObject.Position - RootPart.Position).Magnitude
                                if DistanceValue < NearestDist then
                                    NearestDist = DistanceValue
                                    Nearest = ValueItem
                                end
                            end
                        end
                    end
                end
                if Nearest then
                    local PrimaryRemote = ReplicatedStorage.Events and ReplicatedStorage.Events:FindFirstChild("XMHH.2")
                    local SecondaryRemote = ReplicatedStorage.Events and ReplicatedStorage.Events:FindFirstChild("XMHH2.2")
                    if PrimaryRemote and SecondaryRemote then
                        local MainPart = Nearest:FindFirstChild("MainPart") or Nearest:FindFirstChild("PosPart")
                        if MainPart then
                            local ValueObject = PrimaryRemote:InvokeServer("\240\159\141\158", tick(), ToolObject, "DZDRRRKI", Nearest, "Register")
                            if ValueObject then
                                SecondaryRemote:FireServer("\240\159\141\158", tick(), ToolObject, "2389ZFX34", ValueObject, false, CharacterModel["Right Arm"], MainPart, Nearest,
                                    MainPart.Position, MainPart.Position)
                            end
                        end
                    end
                end
            end)
            task.wait(math.random(25, 40) / 100)
        end
    end)
end

function CrowbarAuraDisable()
    CrowbarAuraEnabled = false
    if CrowbarAuraCoroutine then
        task.cancel(CrowbarAuraCoroutine)
        CrowbarAuraCoroutine = nil
    end
end

local SharedAuraTick = 0

function MeleeAuraEnable()
    if MeleeAuraEnabled then return end
    MeleeAuraEnabled = true
    MeleeAuraCoroutine = task.spawn(function()
        while MeleeAuraEnabled do
            if tick() - SharedAuraTick > 0.15 then
                local CharacterModel = LocalPlayer.Character
                if CharacterModel then
                    local RootPart = CharacterModel:FindFirstChild("HumanoidRootPart")
                    local ToolObject = CharacterModel:FindFirstChildOfClass("Tool")
                    if RootPart and ToolObject then
                        local PrimaryRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("XMHH.2")
                        local SecondaryRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("XMHH2.2")
                        if PrimaryRemote and SecondaryRemote then
                            for Unused, PlayerObject in ipairs(Players:GetPlayers()) do
                                if PlayerObject ~= LocalPlayer then
                                    local TargetCharacter = PlayerObject.Character
                                    if TargetCharacter then
                                        local TargetRootPart = TargetCharacter:FindFirstChild("HumanoidRootPart")
                                        local TargetHead = TargetCharacter:FindFirstChild("Head")
                                        local TargetHum = TargetCharacter:FindFirstChildOfClass("Humanoid")
                                        if TargetRootPart and TargetHead and TargetHum and TargetHum.Health > 0 then
                                            local DistanceValue = (RootPart.Position - TargetRootPart.Position).Magnitude
                                            if DistanceValue <= 14 and not TargetCharacter:FindFirstChildOfClass("ForceField") then
                                                SharedAuraTick = tick()
                                                local FirstArgument = { [1] = "🍞", [2] = tick(), [3] = ToolObject, [4] = "43TRFWX", [5] = "Normal", [6] = tick(), [7] = true }
                                                local Success1, OperationResult = pcall(function() return PrimaryRemote:InvokeServer(unpack(FirstArgument)) end)
                                                if Success1 then
                                                    local Handle = ToolObject:FindFirstChild("WeaponHandle") or ToolObject:FindFirstChild("Handle") or CharacterModel:FindFirstChild("Right Arm")
                                                    if Handle then
                                                        local SecondArgument = { [1] = "🍞", [2] = tick(), [3] = ToolObject, [4] = "2389ZFX34", [5] = OperationResult, [6] = false, [7] =
                                                            Handle, [8] = TargetHead, [9] = TargetCharacter, [10] = RootPart.Position, [11] = TargetHead.Position }
                                                        pcall(function() SecondaryRemote:FireServer(unpack(SecondArgument)) end)
                                                    end
                                                end
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

function MeleeAuraDisable()
    MeleeAuraEnabled = false
    if MeleeAuraCoroutine then
        task.cancel(MeleeAuraCoroutine)
        MeleeAuraCoroutine = nil
    end
end

function GetArmsChamsMaterial()
    local MaterialName = ArmsChamsSettings.Material
    if MaterialName == "Neon" then return Enum.Material.Neon end
    if MaterialName == "Glass" then return Enum.Material.Glass end
    if MaterialName == "SmoothPlastic" then return Enum.Material.SmoothPlastic end
    return Enum.Material.ForceField
end

function GetArmsViewModel()
    local CameraObject = GetCamera()
    if not CameraObject then return nil end
    local Names = { "ViewModel", "Viewmodel", "viewmodel", "Arms", "ViewArms" }
    for Unused, Name in ipairs(Names) do
        local ViewModel = CameraObject:FindFirstChild(Name)
        if ViewModel then return ViewModel end
    end
    return nil
end

function IsArmsChamsPart(Part)
    local Name = string.lower(Part.Name):gsub("[%s_%-]", "")
    if Name == "leftarm" or Name == "rightarm" or Name == "lefthand" or Name == "righthand" then return true end
    local Side = string.find(Name, "left", 1, true) or string.find(Name, "right", 1, true)
    if not Side then return false end
    return string.find(Name, "arm", 1, true) ~= nil or string.find(Name, "hand", 1, true) ~= nil or string.find(Name, "sleeve", 1, true) ~= nil or string.find(Name, "glove", 1, true) ~= nil
end

function StoreArmsChamsOriginal(Part)
    if ArmsChamsSettings.Original[Part] then return end
    ArmsChamsSettings.Original[Part] = { Material = Part.Material, Color = Part.Color, Transparency = Part.Transparency, Reflectance = Part.Reflectance, LocalTransparencyModifier =
        Part.LocalTransparencyModifier }
end

function RestoreArmsChamsPart(Part)
    local Original = ArmsChamsSettings.Original[Part]
    if not Original then return end
    if Part and Part.Parent then
        pcall(function()
            Part.Material = Original.Material
            Part.Color = Original.Color
            Part.Transparency = Original.Transparency
            Part.Reflectance = Original.Reflectance
            Part.LocalTransparencyModifier = Original.LocalTransparencyModifier
        end)
    end
    ArmsChamsSettings.Original[Part] = nil
    ArmsChamsSettings.CurrentParts[Part] = nil
end

function RestoreArmsChams()
    local Parts = {}
    for Part in pairs(ArmsChamsSettings.Original) do Parts[#Parts + 1] = Part end
    for Unused, Part in ipairs(Parts) do RestoreArmsChamsPart(Part) end
    ArmsChamsSettings.CurrentViewModel = nil
end

function ApplyArmsChams()
    if not ArmsChamsEnabled then return end
    local ViewModel = GetArmsViewModel()
    if ArmsChamsSettings.CurrentViewModel ~= ViewModel then
        RestoreArmsChams()
        ArmsChamsSettings.CurrentViewModel = ViewModel
    end
    if not ViewModel then return end
    local ActiveParts = setmetatable({}, { __mode = "k" })
    local Material = GetArmsChamsMaterial()
    for Unused, Descendant in ipairs(ViewModel:GetDescendants()) do
        if Descendant:IsA("BasePart") and IsArmsChamsPart(Descendant) then
            StoreArmsChamsOriginal(Descendant)
            local Original = ArmsChamsSettings.Original[Descendant]
            Descendant.Material = Material
            Descendant.Color = ArmsChamsSettings.ArmColor
            Descendant.Transparency = math.max(Original.Transparency, ArmsChamsSettings.Transparency)
            Descendant.LocalTransparencyModifier = Original.LocalTransparencyModifier
            Descendant.Reflectance = 0
            ActiveParts[Descendant] = true
            ArmsChamsSettings.CurrentParts[Descendant] = true
        end
    end
    local Stale = {}
    for Part in pairs(ArmsChamsSettings.Original) do
        if not ActiveParts[Part] then Stale[#Stale + 1] = Part end
    end
    for Unused, Part in ipairs(Stale) do RestoreArmsChamsPart(Part) end
end

function ArmsChamsEnable()
    if ArmsChamsEnabled then
        ApplyArmsChams()
        return
    end
    ArmsChamsEnabled = true
    ArmsChamsSettings.Clock = 0
    if ArmsChamsSettings.Connection then ArmsChamsSettings.Connection:Disconnect() end
    ArmsChamsSettings.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        if not ArmsChamsEnabled then return end
        ArmsChamsSettings.Clock = ArmsChamsSettings.Clock + math.clamp(DeltaTime, 0, 0.05)
        if ArmsChamsSettings.Clock >= 0.15 then
            ArmsChamsSettings.Clock = 0
            ApplyArmsChams()
        end
    end)
    ApplyArmsChams()
end

function ArmsChamsDisable()
    ArmsChamsEnabled = false
    if ArmsChamsSettings.Connection then
        ArmsChamsSettings.Connection:Disconnect()
        ArmsChamsSettings.Connection = nil
    end
    RestoreArmsChams()
end

function FinishAuraEnable()
    if FinishAuraEnabled then return end
    FinishAuraEnabled = true
    FinishAuraCoroutine = task.spawn(function()
        while FinishAuraEnabled do
            if tick() - SharedAuraTick > 0.15 then
                local CharacterModel = LocalPlayer.Character
                if CharacterModel then
                    local RootPart = CharacterModel:FindFirstChild("HumanoidRootPart")
                    local ToolObject = CharacterModel:FindFirstChildOfClass("Tool")
                    if RootPart and ToolObject then
                        local PrimaryRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("XMHH.2")
                        local SecondaryRemote = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("XMHH2.2")
                        if PrimaryRemote and SecondaryRemote then
                            for Unused, PlayerObject in ipairs(Players:GetPlayers()) do
                                if PlayerObject ~= LocalPlayer then
                                    local TargetCharacter = PlayerObject.Character
                                    if TargetCharacter then
                                        local TargetRootPart = TargetCharacter:FindFirstChild("HumanoidRootPart")
                                        local TargetHead = TargetCharacter:FindFirstChild("Head")
                                        local TargetHum = TargetCharacter:FindFirstChildOfClass("Humanoid")
                                        if TargetRootPart and TargetHead and TargetHum and TargetHum.Health > 0 then
                                            local IsDowned = ReplicatedStorage:FindFirstChild("CharStats") and ReplicatedStorage.CharStats:FindFirstChild(PlayerObject.Name)
                                            if IsDowned and IsDowned:FindFirstChild("Downed") and IsDowned.Downed.Value == true then
                                                local DistanceValue = (RootPart.Position - TargetRootPart.Position).Magnitude
                                                if DistanceValue <= 7 and not TargetCharacter:FindFirstChildOfClass("ForceField") then
                                                    SharedAuraTick = tick()
                                                    local InvokeResult = PrimaryRemote:InvokeServer("\240\159\141\158", tick(), ToolObject, "EXECQX")
                                                    if InvokeResult then
                                                        SecondaryRemote:FireServer("\240\159\141\158", tick(), ToolObject, "2389ZFX34", InvokeResult, false,
                                                            CharacterModel:FindFirstChild("Right Leg"), TargetHead, TargetCharacter, TargetHead.Position, TargetHead.Position)
                                                    end
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

function FinishAuraDisable()
    if not FinishAuraEnabled then return end
    FinishAuraEnabled = false
    if FinishAuraCoroutine then
        task.cancel(FinishAuraCoroutine)
        FinishAuraCoroutine = nil
    end
end

do
    local Runtime = { State = nil, Source = nil, Container = nil, CharacterConnection = nil, ResolveAt = 0, ResolveDelay = 0.4, Target = 100, MaximumFunctions = 160, MaximumUpvalues = 64,
        MaximumProtos = 48 }
    local function ReadUpvalue(FunctionObject, Index)
        local Reader = type(getupvalue) == "function" and getupvalue or type(debug) == "table" and debug.getupvalue
        if type(Reader) ~= "function" or type(FunctionObject) ~= "function" then return nil end
        local Success, First, Second = pcall(Reader, FunctionObject, Index)
        if not Success then return nil end
        return Second ~= nil and Second or First
    end
    local function ReadUpvalues(FunctionObject)
        local Reader = type(getupvalues) == "function" and getupvalues or type(debug) == "table" and debug.getupvalues
        if type(Reader) == "function" then
            local Success, Values = pcall(Reader, FunctionObject)
            if Success and type(Values) == "table" then return Values end
        end
        local Values = {}
        local Misses = 0
        for Index = 1, Runtime.MaximumUpvalues do
            local Value = ReadUpvalue(FunctionObject, Index)
            if Value ~= nil then
                Misses = 0
                Values[#Values + 1] = Value
            else
                Misses += 1
                if Misses >= 4 then break end
            end
        end
        return Values
    end
    local function ReadConstants(FunctionObject)
        local Reader = type(getconstants) == "function" and getconstants or type(debug) == "table" and debug.getconstants
        if type(Reader) == "function" then
            local Success, Values = pcall(Reader, FunctionObject)
            if Success and type(Values) == "table" then return Values end
        end
        local SingleReader = type(getconstant) == "function" and getconstant or type(debug) == "table" and debug.getconstant
        local Values = {}
        if type(SingleReader) == "function" then
            local Misses = 0
            for Index = 1, 96 do
                local Success, Value = pcall(SingleReader, FunctionObject, Index)
                if Success and Value ~= nil then
                    Misses = 0
                    Values[#Values + 1] = Value
                else
                    Misses += 1
                    if Misses >= 4 then break end
                end
            end
        end
        return Values
    end
    local function ReadProtos(FunctionObject)
        local Values = {}
        local Added = setmetatable({}, { __mode = "k" })
        local function Add(Value)
            if type(Value) == "function" and not Added[Value] then
                Added[Value] = true
                Values[#Values + 1] = Value
            elseif type(Value) == "table" then
                for _, Nested in pairs(Value) do
                    if type(Nested) == "function" and not Added[Nested] then
                        Added[Nested] = true
                        Values[#Values + 1] = Nested
                    end
                end
            end
        end
        local Reader = type(getprotos) == "function" and getprotos or type(debug) == "table" and debug.getprotos
        if type(Reader) == "function" then
            local Success, Protos = pcall(Reader, FunctionObject)
            if Success then Add(Protos) end
        end
        local SingleReader = type(getproto) == "function" and getproto or type(debug) == "table" and debug.getproto
        if type(SingleReader) == "function" then
            local Misses = 0
            for Index = 1, Runtime.MaximumProtos do
                local Success, Proto = pcall(SingleReader, FunctionObject, Index, true)
                if Success and Proto ~= nil then
                    Misses = 0
                    Add(Proto)
                else
                    Misses += 1
                    if Misses >= 4 then break end
                end
            end
        end
        return Values
    end
    local function HasStaminaIdentity(FunctionObject)
        local Success, Information = pcall(function() return debug and debug.getinfo and debug.getinfo(FunctionObject) end)
        if Success and type(Information) == "table" then
            local Name = string.lower(tostring(Information.name or ""))
            if string.find(Name, "upt_s", 1, true) or string.find(Name, "stamina", 1, true) or string.find(Name, "s_take", 1, true) then return true end
        end
        for _, Constant in pairs(ReadConstants(FunctionObject)) do
            if type(Constant) == "string" then
                local Value = string.lower(Constant)
                if string.find(Value, "upt_s", 1, true) or string.find(Value, "stamina", 1, true) or string.find(Value, "s_take", 1, true) then return true end
            end
        end
        return false
    end
    local function IsStaminaState(Value)
        if type(Value) ~= "table" then return false end
        local Success, Stamina = pcall(function() return Value.S end)
        return Success and type(Stamina) == "number"
    end
    local function GetSource()
        if type(getrenv) ~= "function" then return nil end
        local Success, Environment = pcall(getrenv)
        if not Success or type(Environment) ~= "table" then return nil end
        local Globals = nil
        pcall(function() Globals = Environment._G or Environment.G end)
        if type(Globals) ~= "table" then return nil end
        local Source = nil
        pcall(function() Source = Globals.S_Take or Globals.STake end)
        return type(Source) == "function" and Source or nil
    end
    local function FindState(Source)
        local Container = ReadUpvalue(Source, 2)
        if type(Container) == "function" then
            local DirectState = ReadUpvalue(Container, 7)
            if IsStaminaState(DirectState) then
                Runtime.Container = Container
                return DirectState
            end
        end
        local Queue = {}
        local Trusted = setmetatable({}, { __mode = "k" })
        local Visited = setmetatable({}, { __mode = "k" })
        local function Add(FunctionObject, IsTrusted)
            if type(FunctionObject) == "function" and not Visited[FunctionObject] then
                Queue[#Queue + 1] = FunctionObject
                if IsTrusted then Trusted[FunctionObject] = true end
            end
        end
        Add(Source, true)
        Add(Container, true)
        local Index = 1
        local Processed = 0
        while Index <= #Queue and Processed < Runtime.MaximumFunctions do
            local FunctionObject = Queue[Index]
            Index += 1
            if not Visited[FunctionObject] then
                Visited[FunctionObject] = true
                Processed += 1
                local Identity = Trusted[FunctionObject] or HasStaminaIdentity(FunctionObject)
                for _, Value in pairs(ReadUpvalues(FunctionObject)) do
                    if Identity and IsStaminaState(Value) then
                        Runtime.Container = FunctionObject
                        return Value
                    end
                    if type(Value) == "function" then
                        Add(Value, Identity or HasStaminaIdentity(Value))
                    elseif type(Value) == "table" then
                        local Count = 0
                        for _, Nested in pairs(Value) do
                            Count += 1
                            if Identity and IsStaminaState(Nested) then
                                Runtime.Container = FunctionObject
                                return Nested
                            end
                            if type(Nested) == "function" then Add(Nested, Identity or HasStaminaIdentity(Nested)) end
                            if Count >= 48 then break end
                        end
                    end
                end
                for _, Proto in pairs(ReadProtos(FunctionObject)) do Add(Proto, Identity or HasStaminaIdentity(Proto)) end
            end
        end
        return nil
    end
    local function Resolve(Force)
        local Now = os.clock()
        if not Force and IsStaminaState(Runtime.State) and Now < Runtime.ResolveAt then return Runtime.State end
        if not Force and Now < Runtime.ResolveAt then return nil end
        Runtime.ResolveAt = Now + Runtime.ResolveDelay
        local Source = GetSource()
        if Source ~= Runtime.Source then
            Runtime.Source = Source
            Runtime.State = nil
            Runtime.Container = nil
        end
        if not Source then return nil end
        if type(Runtime.Container) == "function" then
            local CurrentState = ReadUpvalue(Runtime.Container, 7)
            if IsStaminaState(CurrentState) then
                Runtime.State = CurrentState
                return CurrentState
            end
        end
        Runtime.State = FindState(Source)
        return Runtime.State
    end
    local function Apply(Force)
        local State = Resolve(Force)
        if not State then return false end
        local Success = pcall(function() State.S = Runtime.Target end)
        if not Success then Runtime.State = nil end
        return Success
    end
    function InfStaminaEnable()
        if InfStaminaEnabled then
            Apply(true)
            return
        end
        InfStaminaEnabled = true
        Runtime.State = nil
        Runtime.Source = nil
        Runtime.Container = nil
        Runtime.ResolveAt = 0
        if Runtime.CharacterConnection then Runtime.CharacterConnection:Disconnect() end
        Runtime.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
            Runtime.State = nil
            Runtime.Source = nil
            Runtime.Container = nil
            Runtime.ResolveAt = 0
            if InfStaminaEnabled then
                task.defer(function() Apply(true) end)
            end
        end)
        Apply(true)
        InfStaminaCoroutine = task.spawn(function()
            while InfStaminaEnabled do
                Apply(false)
                RunService.Heartbeat:Wait()
            end
            InfStaminaCoroutine = nil
        end)
    end
    function InfStaminaDisable()
        InfStaminaEnabled = false
        if InfStaminaCoroutine then
            task.cancel(InfStaminaCoroutine)
            InfStaminaCoroutine = nil
        end
        if Runtime.CharacterConnection then
            Runtime.CharacterConnection:Disconnect()
            Runtime.CharacterConnection = nil
        end
        Runtime.State = nil
        Runtime.Source = nil
        Runtime.Container = nil
        Runtime.ResolveAt = 0
    end
end

do
    local State = { Patches = {}, DisabledConnections = {}, PatchLookup = setmetatable({}, { __mode = "k" }), ConnectionLookup = setmetatable({}, { __mode = "k" }), Candidates =
        setmetatable({}, { __mode = "k" }), Visited = setmetatable({}, { __mode = "k" }), CandidateCount = 0, ScanRunning = false, LastScan = 0, ScanCooldown = 15, ProcessedFunctions = 0,
        CharacterConnection = nil }
    local function StepGarbageCollector() RadiantStepGC(32) end
    local DebugFunctionCache = {}
    local function GetDebugFunction(DirectFunction, DebugName)
        local CachedFunction = DebugFunctionCache[DebugName]
        if CachedFunction ~= nil then return CachedFunction or nil end
        local ResolvedFunction = nil
        if type(DirectFunction) == "function" then
            ResolvedFunction = DirectFunction
        elseif type(debug) == "table" and type(debug[DebugName]) == "function" then
            ResolvedFunction = debug[DebugName]
        end
        DebugFunctionCache[DebugName] = ResolvedFunction or false
        return ResolvedFunction
    end
    local function ReadConstants(Function)
        local Reader = GetDebugFunction(getconstants, "getconstants")
        if not Reader then return nil end
        local Success, Constants = pcall(Reader, Function)
        if not Success or type(Constants) ~= "table" then return nil end
        return Constants
    end
    local function ReadProtos(Function)
        local Reader = GetDebugFunction(getprotos, "getprotos")
        if not Reader then return nil end
        local Success, Protos = pcall(Reader, Function)
        if not Success or type(Protos) ~= "table" then return nil end
        return Protos
    end
    local function ReadUpvalues(Function)
        local Reader = GetDebugFunction(getupvalues, "getupvalues")
        if not Reader then return nil end
        local Success, Upvalues = pcall(Reader, Function)
        if not Success or type(Upvalues) ~= "table" then return nil end
        return Upvalues
    end
    local function CacheFunction(Function, Depth)
        if type(Function) ~= "function" or State.Visited[Function] or Depth > 4 then return end
        State.Visited[Function] = true
        State.ProcessedFunctions = State.ProcessedFunctions + 1
        if State.ProcessedFunctions >= 128 then
            State.ProcessedFunctions = 0
            task.wait()
        end
        local Constants = ReadConstants(Function)
        if Constants then
            local Matches = nil
            for Index, Constant in pairs(Constants) do
                if type(Index) == "number" and(Constant == "FlllD" or Constant == "FllH") then
                    if not Matches then Matches = {} end
                    Matches[Index] = Constant
                end
            end
            if Matches then
                if not State.Candidates[Function] then State.CandidateCount = State.CandidateCount + 1 end
                State.Candidates[Function] = Matches
            end
        end
        local Protos = ReadProtos(Function)
        if Protos then
            for Unused, Proto in pairs(Protos) do CacheFunction(Proto, Depth + 1) end
        end
        local Upvalues = ReadUpvalues(Function)
        if Upvalues then
            for Unused, Value in pairs(Upvalues) do
                if type(Value) == "function" then CacheFunction(Value, Depth + 1) end
            end
        end
    end
    local function UpdateCandidateCache()
        if State.ScanRunning then return false end
        State.ScanRunning = true
        State.ProcessedFunctions = 0
        local Success = RadiantScanGarbage(false, function(Object)
            if type(Object) == "function" then CacheFunction(Object, 0) end
        end, 160)
        if Success then State.LastScan = os.clock() end
        State.ScanRunning = false
        StepGarbageCollector()
        return Success
    end
    local function PatchFunction(Function, Constants)
        local Writer = GetDebugFunction(setconstant, "setconstant")
        if not Writer then return false end
        local FunctionLookup = State.PatchLookup[Function]
        if not FunctionLookup then
            FunctionLookup = {}
            State.PatchLookup[Function] = FunctionLookup
        end
        local Patched = false
        for Index, Constant in pairs(Constants) do
            if type(Index) == "number" and(Constant == "FlllD" or Constant == "FllH") then
                if FunctionLookup[Index] then
                    Patched = true
                else
                    local Success = pcall(Writer, Function, Index, "RFall")
                    if Success then
                        FunctionLookup[Index] = true
                        State.Patches[#State.Patches + 1] = { Function = Function, Index = Index, Value = Constant }
                        Patched = true
                    end
                end
            end
        end
        return Patched
    end
    local function ReadConnectionFunction(Connection)
        local Success, Function = pcall(function() return Connection.Function end)
        if Success and type(Function) == "function" then return Function end
        return nil
    end
    local function DisableConnection(Connection)
        if State.ConnectionLookup[Connection] then return true end
        local Disabled = pcall(function()
            if type(Connection.Disable) == "function" then
                Connection:Disable()
            else
                Connection.Enabled = false
            end
        end)
        if not Disabled then return false end
        State.ConnectionLookup[Connection] = true
        State.DisabledConnections[#State.DisabledConnections + 1] = Connection
        return true
    end
    local function GetSignals()
        local Signals = { RunService.Heartbeat, RunService.Stepped, RunService.RenderStepped, LocalPlayer.CharacterAdded }
        local Character = LocalPlayer.Character
        if not Character then return Signals end
        local Humanoid = Character:FindFirstChildOfClass("Humanoid")
        local RootPart = Character:FindFirstChild("HumanoidRootPart")
        if Humanoid then
            Signals[#Signals + 1] = Humanoid.StateChanged
            Signals[#Signals + 1] = Humanoid.FreeFalling
            Signals[#Signals + 1] = Humanoid.FallingDown
            Signals[#Signals + 1] = Humanoid:GetPropertyChangedSignal("FloorMaterial")
        end
        if RootPart then
            Signals[#Signals + 1] = RootPart:GetPropertyChangedSignal("AssemblyLinearVelocity")
            Signals[#Signals + 1] = RootPart:GetPropertyChangedSignal("Velocity")
            Signals[#Signals + 1] = RootPart:GetPropertyChangedSignal("Position")
        end
        return Signals
    end
    local function DisableConnections(Candidates)
        if type(getconnections) ~= "function" then return end
        for Unused, Signal in ipairs(GetSignals()) do
            local Success, Connections = pcall(getconnections, Signal)
            if Success and type(Connections) == "table" then
                for Unused, Connection in pairs(Connections) do
                    local Function = ReadConnectionFunction(Connection)
                    if Function and Candidates[Function] then DisableConnection(Connection) end
                end
            end
            Connections = nil
        end
        StepGarbageCollector()
    end
    local function ApplyCachedCandidates()
        local Unpatched = {}
        for Function, Constants in pairs(State.Candidates) do
            if not PatchFunction(Function, Constants) then Unpatched[Function] = true end
        end
        DisableConnections(Unpatched)
        Unpatched = nil
        StepGarbageCollector()
    end
    local function CountCachedCandidates()
        local Count = 0
        for Function in pairs(State.Candidates) do
            if type(Function) == "function" then Count = Count + 1 end
        end
        State.CandidateCount = Count
        return Count
    end
    local function ClearCandidateCache()
        State.Candidates = setmetatable({}, { __mode = "k" })
        State.Visited = setmetatable({}, { __mode = "k" })
        State.CandidateCount = 0
        State.LastScan = 0
        StepGarbageCollector()
    end
    local function Scan(ForceUpdate)
        if State.ScanRunning then return end
        local CachedCount = CountCachedCandidates()
        local RefreshAllowed = State.LastScan == 0 or os.clock() - State.LastScan >= State.ScanCooldown
        if ForceUpdate and RefreshAllowed then
            ClearCandidateCache()
            CachedCount = 0
        end
        if CachedCount == 0 then
            UpdateCandidateCache()
            CachedCount = CountCachedCandidates()
        end
        if CachedCount > 0 then ApplyCachedCandidates() end
    end
    local function Restore()
        local Writer = GetDebugFunction(setconstant, "setconstant")
        if Writer then
            for Index = #State.Patches, 1, -1 do
                local Patch = State.Patches[Index]
                pcall(Writer, Patch.Function, Patch.Index, Patch.Value)
            end
        end
        for Index = #State.DisabledConnections, 1, -1 do
            local Connection = State.DisabledConnections[Index]
            pcall(function()
                if type(Connection.Enable) == "function" then
                    Connection:Enable()
                else
                    Connection.Enabled = true
                end
            end)
        end
        State.Patches = {}
        State.DisabledConnections = {}
        State.PatchLookup = setmetatable({}, { __mode = "k" })
        State.ConnectionLookup = setmetatable({}, { __mode = "k" })
        StepGarbageCollector()
    end
    function NoFallDamageEnable()
        if NoFallDamageEnabled then return end
        NoFallDamageEnabled = true
        Scan(State.CandidateCount == 0)
        if State.CharacterConnection then State.CharacterConnection:Disconnect() end
        State.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function()
            Restore()
            task.spawn(function()
                task.wait(1.25)
                if NoFallDamageEnabled then Scan(true) end
            end)
        end)
    end
    function NoFallDamageDisable()
        if not NoFallDamageEnabled then return end
        NoFallDamageEnabled = false
        if State.CharacterConnection then
            State.CharacterConnection:Disconnect()
            State.CharacterConnection = nil
        end
        Restore()
    end
end

local function GenerateRageRandomString(Length)
    local Result = {}
    for Index = 1, Length do Result[Index] = string.char(math.random(97, 122)) end
    return table.concat(Result)
end

local function GetRageCharacter(Player) return ResolveTrackedCharacter(Player, Player and Player.Character or nil) end

local function GetRageRootPart(Character)
    if not Character then return nil end
    return Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
end

local function GetRageEvents()
    local Events = ReplicatedStorage:FindFirstChild("Events")
    if not Events then return nil, nil, nil end
    return Events:FindFirstChild("GNX_S"), Events:FindFirstChild("ZFKLF__H"), Events:FindFirstChild("GNX_R")
end

local function GetRageAmmoValues(Tool)
    local Values = Tool and Tool:FindFirstChild("Values")
    if not Values then return nil, nil end
    return Values:FindFirstChild("SERVER_Ammo"), Values:FindFirstChild("SERVER_StoredAmmo")
end

local function FindRageNumber(Container, Names)
    if not Container then return nil end
    for _, Name in ipairs(Names) do
        local Object = Container:FindFirstChild(Name, true)
        if Object and (Object:IsA("NumberValue") or Object:IsA("IntValue")) then return tonumber(Object.Value) end
        local Attribute = Container:GetAttribute(Name)
        if type(Attribute) == "number" then return Attribute end
    end
end

local function GetRageShotCadence(Tool)
    local Values = Tool and Tool:FindFirstChild("Values")
    local WeaponDelay = FindRageNumber(Values or Tool, { "FireDelay", "ShootDelay", "ShotDelay", "Cooldown", "FireRateDelay" })
    if not WeaponDelay then
        local FireRate = FindRageNumber(Values or Tool, { "FireRate", "Firerate", "RPM", "RoundsPerMinute" })
        if FireRate and FireRate > 10 then WeaponDelay = 60 / FireRate elseif FireRate and FireRate > 0 then WeaponDelay = 1 / FireRate end
    end
    local BaseDelay = tonumber(RageBotSettings.BaseDelay) or 0.25
    return math.max(BaseDelay, tonumber(WeaponDelay) or 0)
end

local function GetRageServerTime()
    local Success, Time = pcall(workspace.GetServerTimeNow, workspace)
    return Success and Time or os.clock()
end

local function AlignRageServerTick(Time)
    local TickLength = 1 / math.max(RageBotSettings.ServerTickRate, 20)
    return math.ceil(Time / TickLength) * TickLength
end

local function WaitForRageShotSlot(Tool)
    local Now = GetRageServerTime()
    if RageShotState.LastTool ~= Tool then RageShotState.LastTool, RageShotState.NextServerShot = Tool, AlignRageServerTick(Now) end
    local ShotTime = math.max(RageShotState.NextServerShot, AlignRageServerTick(Now))
    while RageBotEnabled and GetRageServerTime() < ShotTime do RunService.Heartbeat:Wait() end
    RageShotState.NextServerShot = AlignRageServerTick(ShotTime + GetRageShotCadence(Tool))
    return RageBotEnabled
end

local function GetRageDamage(Tool, TargetPart)
    local Values = Tool and Tool:FindFirstChild("Values")
    local IsHead = TargetPart and TargetPart.Name == "Head"
    local Names = IsHead and { "HeadshotDamage", "HeadDamage", "HeadDMG", "DamageHead" } or { "Damage", "BaseDamage", "BodyDamage", "DMG" }
    local Damage = FindRageNumber(Values or Tool, Names)
    local Learned = Tool and RageShotState.LearnedDamage[Tool]
    if Learned and Learned > 0 then Damage = Damage and math.max(Damage, Learned) or Learned end
    return math.max(tonumber(Damage) or (IsHead and 35 or 20), 1)
end

local function GetRageDownedValue(Player)
    local CharStats = ReplicatedStorage:FindFirstChild("CharStats")
    local PlayerStats = Player and CharStats and CharStats:FindFirstChild(Player.Name)
    return PlayerStats and PlayerStats:FindFirstChild("Downed")
end

local function IsRageDowned(Player)
    local Downed = GetRageDownedValue(Player)
    return Downed and Downed.Value == true or false
end

local function GetRageShotsNeeded(Tool, Humanoid, TargetPart)
    if not Humanoid then return 0 end
    return math.max(math.ceil(math.max(Humanoid.Health, 0) / GetRageDamage(Tool, TargetPart)), 1)
end

local function IsRageTargetValid(Player, Character, Humanoid)
    if not Player or Player == LocalPlayer or not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 or Character:FindFirstChildOfClass("ForceField") then
        return false
    end
    if RageBotSettings.CheckTeam and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then return false end
    if RageBotSettings.CheckWhitelist and table.find(WhitelistTable, Player.Name) then return false end
    if IsRageDowned(Player) then return false end
    return true
end

local function GetRageTargetPart(Character)
    if not Character then return nil end
    local TargetPart = Character:FindFirstChild(RageBotSettings.TargetPart)
    if TargetPart and TargetPart:IsA("BasePart") then return TargetPart end
    TargetPart = Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    return TargetPart and TargetPart:IsA("BasePart") and TargetPart or nil
end

local function GetRagePredictedPosition(TargetPlayer, TargetCharacter, TargetPart)
    if not TargetPlayer or not TargetCharacter or not TargetPart then return nil end

    local PredictionValue = math.clamp(tonumber(RageBotSettings.Prediction) or 0, 0, 0.45)
    local PositionValue = ResolveCombatPosition(TargetPlayer, TargetCharacter, TargetPart, PredictionValue, RageBotSettings)

    return PositionValue or TargetPart.Position
end


local function IsRageSegmentClear(OriginPosition, TargetPosition, TargetCharacter)
    local Direction = TargetPosition - OriginPosition
    local Distance = Direction.Magnitude
    if Distance < 1 then return true end
    local RayParameters = RaycastParams.new()
    RayParameters.FilterType = Enum.RaycastFilterType.Exclude
    RayParameters.FilterDescendantsInstances = { LocalPlayer.Character, TargetCharacter }
    RayParameters.IgnoreWater = true
    return workspace:Raycast(OriginPosition, Direction.Unit * math.min(Distance, 3000), RayParameters) == nil
end

local function IsRageWallClear(OriginPosition, TargetPosition, TargetCharacter)
    if not RageBotSettings.WallCheck then return true end
    return IsRageSegmentClear(OriginPosition, TargetPosition, TargetCharacter)
end

local function FindClosestTargetRage()
    local LocalCharacter = GetRageCharacter(LocalPlayer)
    local LocalRoot = GetRageRootPart(LocalCharacter)
    local CameraObject = GetCamera()
    if not LocalRoot or not CameraObject then
        RageBotStickyTarget = nil
        return nil, nil, nil
    end
    local function ResolvePlayer(Player)
        local Character = GetRageCharacter(Player)
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local TargetPart = GetRageTargetPart(Character)
        if not TargetPart or not IsRageTargetValid(Player, Character, Humanoid) then return nil, nil end
        ResolverObservePlayer(Player, Character, RageBotSettings)

        local ResolvedPosition = ResolveCombatPosition(Player, Character, TargetPart, 0, RageBotSettings) or TargetPart.Position
        local Distance = (ResolvedPosition - LocalRoot.Position).Magnitude

        if Distance > RageBotSettings.MaxDistance then return nil, nil end

        local OriginPosition = RageBotSettings.OriginMode == "Camera" and CameraObject.CFrame.Position or LocalRoot.Position
        if not IsRageWallClear(OriginPosition, ResolvedPosition, Character) then return nil, nil end

        return Character, TargetPart
    end
    if RageBotSettings.Sticky and RageBotStickyTarget then
        local StickyCharacter, StickyTargetPart = ResolvePlayer(RageBotStickyTarget)
        if StickyCharacter and StickyTargetPart then return RageBotStickyTarget, StickyCharacter, StickyTargetPart end
        RageBotStickyTarget = nil
    end
    local UseFOV = RageBotSettings.TargetMode == "FOV"
    local FOVOriginPoint = CameraObject.ViewportSize * 0.5
    if RageBotSettings.FOVOrigin == "Mouse" then FOVOriginPoint = UserInputService:GetMouseLocation() end
    local BestPlayer = nil
    local BestCharacter = nil
    local BestTargetPart = nil
    local BestScore = math.huge
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            local Character, TargetPart = ResolvePlayer(Player)
            if Character and TargetPart then
                local Score
                if UseFOV then
                    local SelectionPosition = ResolveCombatPosition(Player, Character, TargetPart, 0, RageBotSettings) or TargetPart.Position
                    local ScreenPoint, OnScreen = CameraObject:WorldToViewportPoint(SelectionPosition)
                    if not OnScreen or ScreenPoint.Z <= 0 then continue end
                    Score = (Vector2.new(ScreenPoint.X, ScreenPoint.Y) - FOVOriginPoint).Magnitude
                    if Score > RageBotSettings.FOV then continue end
                else
                    Score = (TargetPart.Position - LocalRoot.Position).Magnitude
                end
                if Score < BestScore then
                    BestScore = Score
                    BestPlayer = Player
                    BestCharacter = Character
                    BestTargetPart = TargetPart
                end
            end
        end
    end
    if BestPlayer and RageBotSettings.Sticky then RageBotStickyTarget = BestPlayer end
    return BestPlayer, BestCharacter, BestTargetPart
end

local RageBotFOVCircle = nil

local function UpdateRageBotFOV()
    if not RageBotSettings.ShowFOV or not RageBotEnabled or not Drawing or type(Drawing.new) ~= "function" then
        if RageBotFOVCircle then RageBotFOVCircle.Visible = false end
        return
    end
    if not RageBotFOVCircle then
        local Success, Circle = pcall(Drawing.new, "Circle")
        if not Success or not Circle then return end
        RageBotFOVCircle = Circle
        RageBotFOVCircle.Filled = false
        RageBotFOVCircle.Thickness = 2
        RageBotFOVCircle.NumSides = 96
    end
    local CameraObject = GetCamera()
    if not CameraObject then
        RageBotFOVCircle.Visible = false
        return
    end
    local FOVOriginPoint = CameraObject.ViewportSize * 0.5
    if RageBotSettings.FOVOrigin == "Mouse" then FOVOriginPoint = UserInputService:GetMouseLocation() end
    RageBotFOVCircle.Position = FOVOriginPoint
    RageBotFOVCircle.Radius = RageBotSettings.FOV
    RageBotFOVCircle.Color = RageBotSettings.FOVColor
    RageBotFOVCircle.Visible = RageBotSettings.TargetMode == "FOV"
end

local function ResetRageReloadState(Tool)
    RageReloadState.Tool, RageReloadState.StartedAt, RageReloadState.LastRequest = Tool, 0, 0
    RageReloadState.PreviousAmmo, RageReloadState.InProgress = 0, false
end

local function SendRageReload(ReloadEvent, Tool)
    if not RageBotSettings.AutoReload or not ReloadEvent or not Tool then return false end
    RageReloadState.LastRequest = GetRageServerTime()
    return pcall(ReloadEvent.FireServer, ReloadEvent, tick(), "KLWE89U0", Tool, nil, nil)
end

local function UpdateRageReload(Tool)
    if RageReloadState.Tool ~= Tool then ResetRageReloadState(Tool) end
    if not RageBotSettings.AutoReload or not Tool or not Tool.Parent then return false end

    local ServerAmmo, StoredAmmo = GetRageAmmoValues(Tool)
    local UnusedStart, UnusedFinish, ReloadEvent = GetRageEvents()
    if not ServerAmmo or not StoredAmmo or not ReloadEvent then return false end
    if ServerAmmo.Value > 0 then ResetRageReloadState(Tool) return false end
    if StoredAmmo.Value <= 0 then return false end

    local Now = GetRageServerTime()
    if not RageReloadState.InProgress then
        RageReloadState.InProgress, RageReloadState.StartedAt = true, Now
        RageReloadState.PreviousAmmo, RageReloadState.LastRequest = ServerAmmo.Value, 0
    elseif Now - RageReloadState.StartedAt > RageBotSettings.ReloadTimeout then
        RageReloadState.StartedAt, RageReloadState.LastRequest = Now, 0
    end

    if Now - RageReloadState.LastRequest >= RageBotSettings.ReloadRetryDelay then SendRageReload(ReloadEvent, Tool) end
    return true
end

local function WaitForRageConfirmation(ServerAmmo, PreviousAmmo, Humanoid, PreviousHealth, DownedValue)
    local Deadline = GetRageServerTime() + RageBotSettings.ConfirmationWindow
    while RageBotEnabled and GetRageServerTime() < Deadline do
        if DownedValue and DownedValue.Value then return true end
        if ServerAmmo and ServerAmmo.Value < PreviousAmmo then return true end
        if Humanoid and Humanoid.Health < PreviousHealth then return true end
        RunService.Heartbeat:Wait()
    end
    return false
end

local function FireRageShot(TargetPlayer, TargetCharacter, TargetPart, LocalRoot, LocalTool)
    if not TargetPlayer or not TargetCharacter or not TargetPart or not LocalRoot or not LocalTool or IsRageDowned(TargetPlayer) then return false end
    local ToolValues, HitConfirmationSignal = LocalTool:FindFirstChild("Values"), LocalTool:FindFirstChild("Hitmarker")
    if not ToolValues or not HitConfirmationSignal then return false end

    local ServerAmmo, StoredAmmo = GetRageAmmoValues(LocalTool)
    local StartEvent, FinishEvent, ReloadEvent = GetRageEvents()
    if not ServerAmmo or not StoredAmmo or not StartEvent or not FinishEvent or not ReloadEvent then return false end

    if ServerAmmo.Value <= 0 then
        if RageBotSettings.AutoReload and StoredAmmo.Value > 0 then SendRageReload(ReloadEvent, LocalTool) end
        return false
    end
    if not WaitForRageShotSlot(LocalTool) then return false end

    local CameraObject = GetCamera()
    local VisualOriginPosition = RageBotSettings.OriginMode == "Camera" and CameraObject and CameraObject.CFrame.Position or LocalRoot.Position + Vector3.new(0, 1.4, 0)
    local PredictedPosition = GetRagePredictedPosition(TargetPlayer, TargetCharacter, TargetPart)
    if not PredictedPosition then return false end

    local Difference = PredictedPosition - VisualOriginPosition
    if Difference.Magnitude <= 0.5 then return false end

    local DirectionVector, RandomId = Difference.Unit * 1000, GenerateRageRandomString(30) .. "0"
    local PreviousAmmo = ServerAmmo.Value
    local Humanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
    local PreviousHealth = Humanoid and Humanoid.Health or 0
    local DownedValue = GetRageDownedValue(TargetPlayer)

    if not pcall(StartEvent.FireServer, StartEvent, GetRageServerTime(), RandomId, LocalTool, "FDS9I83", VisualOriginPosition, { DirectionVector }, false) then return false end
    if not pcall(FinishEvent.FireServer, FinishEvent, "\240\159\167\136", LocalTool, RandomId, 1, TargetPart, PredictedPosition, DirectionVector) then return false end

    RegisterLocalAttack(TargetCharacter, TargetPart, RandomId)
    pcall(HitConfirmationSignal.Fire, HitConfirmationSignal, TargetPart)
    local Confirmed = WaitForRageConfirmation(ServerAmmo, PreviousAmmo, Humanoid, PreviousHealth, DownedValue)
    if Humanoid and Humanoid.Health < PreviousHealth then
        local ActualDamage = PreviousHealth - Humanoid.Health
        local Learned = RageShotState.LearnedDamage[LocalTool]
        RageShotState.LearnedDamage[LocalTool] = Learned and (Learned * 0.65 + ActualDamage * 0.35) or ActualDamage
    end
    if ServerAmmo.Value <= 0 and StoredAmmo.Value > 0 then UpdateRageReload(LocalTool) end
    return Confirmed
end

local function RageBotEnable()
    if RageBotEnabled then return end

    RageBotSettings.Resolver = true
    RageBotSettings.ResolverMode = "Adaptive"
    RageBotSettings.ResolverStrength = 1
    RageBotEnabled = true
    RageBotStickyTarget = nil
    RageBotCoroutine = task.spawn(function()
        while RageBotEnabled do
            local LocalCharacter = GetRageCharacter(LocalPlayer)
            local LocalRoot = GetRageRootPart(LocalCharacter)
            local LocalTool = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
            local IsGun = LocalTool and LocalTool:FindFirstChild("Client") ~= nil
            if IsGun and UpdateRageReload(LocalTool) then
                RunService.Heartbeat:Wait()
                continue
            end

            local TargetPlayer, TargetCharacter, TargetPart = FindClosestTargetRage()
            RageBotCurrentTarget = TargetPlayer

            if TargetPlayer and TargetCharacter and TargetPart and LocalRoot and IsGun then
                local Humanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
                if IsRageTargetValid(TargetPlayer, TargetCharacter, Humanoid) and not IsRageDowned(TargetPlayer) then
                    FireRageShot(TargetPlayer, TargetCharacter, TargetPart, LocalRoot, LocalTool)
                else
                    RageBotCurrentTarget = nil
                end
            elseif not TargetPlayer then
                RageBotCurrentTarget = nil
            end
            RunService.Heartbeat:Wait()
        end
    end)
    if RageBotFOVConnection then RageBotFOVConnection:Disconnect() end
    RageBotFOVConnection = RunService.RenderStepped:Connect(UpdateRageBotFOV)
end

local function RageBotDisable()
    if not RageBotEnabled then return end
    RageBotEnabled = false
    RageBotStickyTarget = nil
    RageBotCurrentTarget = nil
    RageShotState.NextServerShot, RageShotState.LastTool = 0, nil
    ResetRageReloadState(nil)
    if RageBotCoroutine then
        task.cancel(RageBotCoroutine)
        RageBotCoroutine = nil
    end
    if RageBotFOVConnection then
        RageBotFOVConnection:Disconnect()
        RageBotFOVConnection = nil
    end
    if RageBotFOVCircle then RageBotFOVCircle.Visible = false end
end

RadiantFarmModule = (function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local HttpService = game:GetService("HttpService")
    local PathfindingService = game:GetService("PathfindingService")
    local RunService = game:GetService("RunService")
    local StarterGui = game:GetService("StarterGui")
    local TeleportService = game:GetService("TeleportService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local GuiService = game:GetService("GuiService")
    local LogService = game:GetService("LogService")
    local VirtualUser = game:GetService("VirtualUser")
    local CoreGui = game:GetService("CoreGui")
    local Workspace = game:GetService("Workspace")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Events = ReplicatedStorage:WaitForChild("Events")
    local CashPickupRemote = Events:WaitForChild("CZDPZUS")
    local ClaimAllowanceRemote = Events:WaitForChild("CLMZALOW")
    local ATMRemote = Events:WaitForChild("ATM")
    local ShopRemote = Events:WaitForChild("SSHPRMTE1")
    local MeleeRemote = Events:WaitForChild("XMHH.2")
    local MeleeHitRemote = Events:FindFirstChild("XMHH2.2")
    local ShopProtectionRemote = Events:FindFirstChild("BYZERSPROTEC")
    local AutoPlayRemote = Events:FindFirstChild("BRBRBRRBLOOOL2")
    local UpdateClientRemote = Events:FindFirstChild("UpdateClient")
    local FallRemote = Events:FindFirstChild("__RZDONL")
    local DropToolRemote = Events:FindFirstChild("PAZ_TA")
    local LocalPlayer = Players.LocalPlayer
    local UiParent = CoreGui
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then UiParent = result end
    end
    local Environment = getgenv and getgenv() or _G
    local Config = { KeySystem = { ApiBase = "https://getjx.onrender.com", Service = "JX", Prefix = "JX_", ExpirationHours = 1, Keyless = false, SavedKeyFile = "JX/key.json", DiscordInvite =
        "https://discord.gg/getjxs" }, Backend = { WebhookProxy = "https://jx3e.onrender.com/webhook/discord", TokenEndpoint = "https://jx3e.onrender.com/auth/token", RefreshEndpoint =
        "https://jx3e.onrender.com/auth/refresh", ApiKey = "" }, Library = { Url = "https://raw.githubusercontent.com/jianlobiano/Serotonin-Library-Modified/refs/heads/main/Library.lua",
        Title = "JX | Criminality | FARM | Dsc.gg/getjxs", MobileButtonText = "JX" }, Files = { Directory = "JX-CRIMINALITY-FARM", Configs = "JX-CRIMINALITY-FARM/Configs", Assets =
        "JX-CRIMINALITY-FARM/Assets", Settings = "JX_EarnMoney.txt", Device = "RBX/device.json" }, Defaults = { AutoRespawn = true, AutoNotify = false, AutoPlay = false, AutoDeposit = false,
        AutoMoney = false, AutoAllowance = false, AntiAFK = false, AdminCheck = false, AntiFallDamage = false, HideBody = false, AutoDepositThresholdK = 5, BreakingMethod = "Crowbar",
        NotifyMinutes = 1, MoveSpeed = 32, PathMaxParamAttempts = 19, WaypointSpacing = 3, PickupDistance = 8, MoneySearchRadius = 42, MoneyCollectMaxPasses = 18, FarmTickSec = 0.2,
        FarmIdleWaitSec = 0.3, FarmRetryWaitSec = 1, FarmDeadWaitSec = 1.5, FarmBetweenTargetsSec = 0.5, RecoveryIdleSec = 8, ShopPreOpenSec = 0.75, ShopAfterOpenSec = 0.45, ShopBuyPollSec =
        0.05, ShopBuyMaxWaitSec = 10, ShopPostBuySec = 1, IgnoreDuration = 6, DynamicRetargetEnabled = true, DebugPrintEnabled = false, AntiRejoin = true } }
    local Executor = {}
    Executor.request = request or http_request or(syn and syn.request) or(http and http.request)
    Executor.writeFile = writefile or(syn and syn.write_file)
    Executor.readFile = readfile or(syn and syn.read_file)
    Executor.isFile = isfile or(syn and syn.isfile)
    Executor.isFolder = isfolder or(syn and syn.isfolder)
    Executor.makeFolder = makefolder or(syn and syn.makefolder)
    Executor.setClipboard = setclipboard or toclipboard or(syn and syn.set_clipboard)
    local function safeCall(callback, ...)
        local result = table.pack(pcall(callback, ...))
        if not result[1] then return false, result[2] end
        return true, table.unpack(result, 2, result.n)
    end
    local function jsonEncode(value)
        local ok, result = safeCall(HttpService.JSONEncode, HttpService, value)
        return ok and result or nil
    end
    local function jsonDecode(value)
        local ok, result = safeCall(HttpService.JSONDecode, HttpService, value)
        return ok and result or nil
    end
    local function requestJson(options)
        if type(Executor.request) ~= "function" then return nil, "executor_request_missing" end
        local ok, response = safeCall(Executor.request, options)
        if not ok or type(response) ~= "table" then return nil, response or "request_failed" end
        local body = response.Body or response.body or ""
        local decoded = type(body) == "string" and jsonDecode(body) or body
        return { Success = response.Success == true or tonumber(response.StatusCode or response.Status) and tonumber(response.StatusCode or response.Status) >= 200 and
            tonumber(response.StatusCode or response.Status) < 300, StatusCode = tonumber(response.StatusCode or response.Status) or 0, Headers = response.Headers or response.headers or {},
            Body = body, Json = decoded }
    end
    local function ensureFolder(path)
        if type(Executor.makeFolder) ~= "function" or type(Executor.isFolder) ~= "function" then return false end
        local current = ""
        for segment in string.gmatch(path, "[^/]+") do
            current = current == "" and segment or current .. "/" .. segment
            if not Executor.isFolder(current) then safeCall(Executor.makeFolder, current) end
        end
        return true
    end
    ensureFolder(Config.Files.Directory)
    ensureFolder(Config.Files.Configs)
    ensureFolder(Config.Files.Assets)
    local function writeText(path, content)
        if type(Executor.writeFile) ~= "function" then return false end
        local folder = string.match(path, "^(.*)/[^/]+$")
        if folder and folder ~= "" then ensureFolder(folder) end
        return safeCall(Executor.writeFile, path, content)
    end
    local function readText(path)
        if type(Executor.readFile) ~= "function" or type(Executor.isFile) ~= "function" then return nil end
        if not Executor.isFile(path) then return nil end
        local ok, content = safeCall(Executor.readFile, path)
        return ok and content or nil
    end
    local function notify() return false end
    local function trim(value) return tostring(value or ""):gsub("^%s+", ""):gsub("%s+$", "") end
    local function parseCashTextToNumber(value)
        local text = tostring(value or ""):gsub("%s+", ""):upper()
        local multiplier = 1
        if text:sub(-1) == "K" then
            multiplier = 1000
            text = text:sub(1, -2)
        elseif text:sub(-1) == "M" then
            multiplier = 1000000
            text = text:sub(1, -2)
        elseif text:sub(-1) == "B" then
            multiplier = 1000000000
            text = text:sub(1, -2)
        end
        text = text:gsub("[^%d%.%-]", "")
        return math.floor((tonumber(text) or 0) * multiplier)
    end
    local function identifyExecutorName()
        if type(identifyexecutor) == "function" then
            local ok, name = safeCall(identifyexecutor)
            if ok and name then return tostring(name) end
        end
        if is_sirhurt_closure then return "SirHurt" end
        if KRNL_LOADED then return "Krnl" end
        if syn then return "Synapse X" end
        if pebc_execute then return "ProtoSmasher" end
        return "Unknown"
    end
    local function getDeviceType()
        if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile" end
        return "PC"
    end
    local function getCharacter() return LocalPlayer.Character end
    local function getHumanoid(character)
        character = character or getCharacter()
        return character and character:FindFirstChildOfClass("Humanoid") or nil
    end
    local function getRoot(character)
        character = character or getCharacter()
        return character and character:FindFirstChild("HumanoidRootPart") or nil
    end
    local function isDead()
        local humanoid = getHumanoid()
        return not humanoid or humanoid.Health <= 0
    end
    local function findTextLabel(pathNames)
        local current = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        for _, name in ipairs(pathNames) do current = current and current:FindFirstChild(name) end
        if current and current:IsA("TextLabel") then return current end
        return nil
    end
    local function readCashAmountText()
        local candidates = { { "CoreGUI", "StatsFrame", "Frame2", "Frame", "Container", "Cash", "Amt" }, { "CoreGUI", "StatsFrame", "Frame2", "Frame", "Container", "Cash" } }
        for _, path in ipairs(candidates) do
            local label = findTextLabel(path)
            if label then return trim(label.Text) end
        end
        return "0"
    end
    local function readBankAmountText()
        local candidates = { { "CoreGUI", "StatsFrame", "Frame2", "Frame", "Container", "Bank", "Amt" }, { "CoreGUI", "StatsFrame", "Frame2", "Frame", "Container", "Bank" } }
        for _, path in ipairs(candidates) do
            local label = findTextLabel(path)
            if label then return trim(label.Text) end
        end
        return "0"
    end
    local function readAllowanceText()
        local candidates = { { "CoreGUI", "StatsFrame", "Frame2", "Frame", "Container", "Allowance", "Amt" }, { "CoreGUI", "StatsFrame", "Frame2", "Frame", "Container", "Allowance" } }
        for _, path in ipairs(candidates) do
            local label = findTextLabel(path)
            if label then return trim(label.Text) end
        end
        return "Unknown"
    end
    local function readCashAmountValue()
        local data = LocalPlayer:FindFirstChild("PlayerbaseData2")
        local cash = data and data:FindFirstChild("Cash")
        if cash and tonumber(cash.Value) then return tonumber(cash.Value) end
        return parseCashTextToNumber(readCashAmountText())
    end
    local Device = {}
    function Device.getHwid()
        local providers = { gethwid, get_hwid, syn and syn.gethwid }
        for _, provider in ipairs(providers) do
            if type(provider) == "function" then
                local ok, value = safeCall(provider)
                if ok and value and tostring(value) ~= "" then return tostring(value) end
            end
        end
        local existing = readText(Config.Files.Device)
        local decoded = existing and jsonDecode(existing)
        if type(decoded) == "table" and decoded.hwid then return tostring(decoded.hwid) end
        local generated = HttpService:GenerateGUID(false)
        writeText(Config.Files.Device, jsonEncode({ hwid = generated }) or generated)
        return generated
    end
    function Device.getCountry()
        local response = requestJson({ Url = "http://ip-api.com/json", Method = "GET" })
        if response and type(response.Json) == "table" then return tostring(response.Json.country or "Unknown") end
        return "Unknown"
    end
    local KeySystem = { Hwid = Device.getHwid(), RequestId = nil, Saved = nil }
    function KeySystem.fetchPublicConfig()
        local response = requestJson({ Url = Config.KeySystem.ApiBase .. "/api/jx/public/config", Method = "GET", Headers = { ["Content-Type"] = "application/json" } })
        if response and response.Success and type(response.Json) == "table" then
            local settings = response.Json.settings or response.Json
            if settings.expirationHours then Config.KeySystem.ExpirationHours = tonumber(settings.expirationHours) or Config.KeySystem.ExpirationHours end
            if settings.keyless ~= nil then Config.KeySystem.Keyless = settings.keyless == true end
            return settings
        end
        return nil
    end
    function KeySystem.requestKey()
        local response, err = requestJson({ Url = Config.KeySystem.ApiBase .. "/api/jx/keys/request", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body =
            jsonEncode({ service = Config.KeySystem.Service, hwid = KeySystem.Hwid }) })
        if not response or not response.Success then return false, err or response and response.Json or "request_failed" end
        local data = response.Json or {}
        KeySystem.RequestId = data.reqId or data.requestId or data.resId or data.id
        local url = data.checkpointUrl or data.url or data.link or data.keyUrl
        if url and type(Executor.setClipboard) == "function" then safeCall(Executor.setClipboard, tostring(url)) end
        return true, data
    end
    function KeySystem.verifyKey(key)
        key = trim(key)
        if key == "" then return false, "Missing key" end
        local requestId = KeySystem.RequestId or HttpService:GenerateGUID(false)
        local response, err = requestJson({ Url = Config.KeySystem.ApiBase .. "/api/jx/keys/verify", Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body =
            jsonEncode({ key = key, hwid = KeySystem.Hwid, reqId = requestId, service = Config.KeySystem.Service }) })
        if not response or not response.Success then return false, err or response and response.Json or "verify_failed" end
        local data = response.Json or {}
        local valid = data.valid == true or data.ok == true or data._jx_valid_response == true
        if data.spoof_detected == true then return false, data.error or data.message or "HWID spoof detected" end
        if not valid then return false, data.error or data.message or "Invalid or expired key" end
        local expiresAt = tonumber(data.expiresAt) or os.time() + Config.KeySystem.ExpirationHours * 3600
        KeySystem.Saved = { key = key, hwid = KeySystem.Hwid, expiresAt = expiresAt, requestId = requestId, resId = data.resId, mode = data.mode }
        writeText(Config.KeySystem.SavedKeyFile, jsonEncode(KeySystem.Saved) or "")
        return true, data
    end
    function KeySystem.loadSavedKey()
        local content = readText(Config.KeySystem.SavedKeyFile)
        local saved = content and jsonDecode(content)
        if type(saved) ~= "table" or not saved.key then return nil end
        if saved.hwid and tostring(saved.hwid) ~= tostring(KeySystem.Hwid) then return nil end
        if tonumber(saved.expiresAt) and tonumber(saved.expiresAt) <= os.time() then return nil end
        KeySystem.Saved = saved
        return saved
    end
    local Auth = { Token = nil, ExpiresAt = 0 }
    function Auth.requestToken()
        local response = requestJson({ Url = Config.Backend.TokenEndpoint, Method = "POST", Headers = { ["Content-Type"] = "application/json", ["X-API-Key"] = Config.Backend.ApiKey }, Body =
            jsonEncode({ userId = LocalPlayer.UserId, hwid = KeySystem.Hwid }) })
        if response and response.Success and type(response.Json) == "table" and response.Json.token then
            Auth.Token = tostring(response.Json.token)
            Auth.ExpiresAt = os.time() + tonumber(response.Json.expiresIn or 300)
            return Auth.Token
        end
        return nil
    end
    function Auth.refreshToken()
        if not Auth.Token then return Auth.requestToken() end
        local response = requestJson({ Url = Config.Backend.RefreshEndpoint, Method = "POST", Headers = { ["Content-Type"] = "application/json", ["Authorization"] = "Bearer " .. Auth.Token },
            Body = jsonEncode({ token = Auth.Token }) })
        if response and response.Success and type(response.Json) == "table" and response.Json.token then
            Auth.Token = tostring(response.Json.token)
            Auth.ExpiresAt = os.time() + tonumber(response.Json.expiresIn or 300)
            return Auth.Token
        end
        return Auth.requestToken()
    end
    function Auth.getToken()
        if not Auth.Token or os.time() >= Auth.ExpiresAt - 30 then return Auth.refreshToken() end
        return Auth.Token
    end
    local Settings = table.clone(Config.Defaults)
    Settings.WebhookURL = ""
    Settings.EarnMoneyTotal = 0
    function Settings.save()
        local content = table.concat({ "EarnMoney:" .. tostring(math.floor(Settings.EarnMoneyTotal)), "Webhook:" .. tostring(Settings.WebhookURL), "AutoRespawn:" ..
            tostring(Settings.AutoRespawn), "AutoNotify:" .. tostring(Settings.AutoNotify), "AutoPlay:" .. tostring(Settings.AutoPlay), "AutoDeposit:" .. tostring(Settings.AutoDeposit),
            "AutoMoney:" .. tostring(Settings.AutoMoney), "AutoAllowance:" .. tostring(Settings.AutoAllowance), "AntiAFK:" .. tostring(Settings.AntiAFK), "AdminCheck:" ..
            tostring(Settings.AdminCheck), "AntiFallDamage:" .. tostring(Settings.AntiFallDamage), "HideBody:" .. tostring(Settings.HideBody), "AutoDepositThresholdK:" ..
            tostring(Settings.AutoDepositThresholdK), "BreakingMethod:" .. tostring(Settings.BreakingMethod), "NotifyMinutes:" ..
            tostring(math.floor(math.clamp(tonumber(Settings.NotifyMinutes) or 1, 1, 10))), "MoveSpeed:" .. tostring(Settings.MoveSpeed), "AntiRejoin:" .. tostring(Settings.AntiRejoin) },
            "\n")
        return writeText(Config.Files.Settings, content)
    end
    function Settings.load()
        local content = readText(Config.Files.Settings)
        if not content then return false end
        local booleanKeys = { AutoRespawn = true, AutoNotify = true, AutoPlay = true, AutoDeposit = true, AutoMoney = true, AutoAllowance = true, AntiAFK = true, AdminCheck = true,
            AntiFallDamage = true, HideBody = true, AntiRejoin = true }
        for line in string.gmatch(content, "[^\r\n]+") do
            local key, value = line:match("^([^:]+):(.*)$")
            if key == "EarnMoney" then
                Settings.EarnMoneyTotal = tonumber(value) or Settings.EarnMoneyTotal
            elseif key == "Webhook" then
                Settings.WebhookURL = trim(value)
            elseif booleanKeys[key] then
                Settings[key] = string.lower(trim(value)) == "true"
            elseif key == "AutoDepositThresholdK" then
                Settings.AutoDepositThresholdK = math.clamp(tonumber(value) or Settings.AutoDepositThresholdK, 1, 100)
            elseif key == "BreakingMethod" and(value == "Crowbar" or value == "Fist + Lockpick") then
                Settings.BreakingMethod = value
            elseif key == "NotifyMinutes" then
                Settings.NotifyMinutes = math.floor(math.clamp(tonumber(value) or Settings.NotifyMinutes, 1, 10))
            elseif key == "MoveSpeed" then
                Settings.MoveSpeed = math.clamp(tonumber(value) or Settings.MoveSpeed, 10, 45)
            end
        end
        return true
    end
    local function syncEnvironmentSettings()
        Environment.JXFarmNotifyTimeMinutes = Settings.NotifyMinutes
        Environment.JXFarmAutoRespawn = Settings.AutoRespawn
        Environment.JXFarmAutoNotify = Settings.AutoNotify
        Environment.JXFarmAutoPlay = Settings.AutoPlay
        Environment.JXFarmAutoDeposit = Settings.AutoDeposit
        Environment.JXFarmAutoMoney = Settings.AutoMoney
        Environment.JXFarmAutoAllowance = Settings.AutoAllowance
        Environment.JXFarmAntiAfk = Settings.AntiAFK
        Environment.JXFarmAdminCheck = Settings.AdminCheck
        Environment.JXFarmAntiFallDamage = Settings.AntiFallDamage
        Environment.JXFarmInvis = Settings.HideBody
        Environment.JXFarmAutoDepositThresholdK = Settings.AutoDepositThresholdK
        Environment.JXFarmBreakingMethod = Settings.BreakingMethod
        Environment.JXFarmSpeedV2 = Settings.MoveSpeed
        Environment.JXFarmWebhookURL = Settings.WebhookURL
        Environment.JXFarmAntiRejoin = Settings.AntiRejoin
        Environment.CV2_NoFall = Settings.AntiFallDamage
    end
    local Webhook = {}
    function Webhook.send(title, description, fields)
        if trim(Settings.WebhookURL) == "" then return false end
        local token = Auth.getToken()
        local gameName = "Unknown Game"
        local ok, info = safeCall(MarketplaceService.GetProductInfo, MarketplaceService, game.PlaceId)
        if ok and type(info) == "table" and info.Name then gameName = tostring(info.Name) end
        local payload = { url = Settings.WebhookURL, username = "JX-Bot", avatar_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer.UserId) ..
            "&width=420&height=420&format=png", embeds = { { title = title or "Script Executed", description = description or "JX-EXECUTED", color = 16711680, thumbnail = { url =
            "https://www.roblox.com/headshot-thumbnail/image?userId=" .. tostring(LocalPlayer.UserId) .. "&width=420&height=420&format=png" }, fields = fields or { { name = "Username",
            value = LocalPlayer.Name, inline = true }, { name = "User ID", value = tostring(LocalPlayer.UserId), inline = true }, { name = "Account Age", value =
            tostring(LocalPlayer.AccountAge), inline = true }, { name = "Game", value = gameName, inline = true }, { name = "Place ID", value = tostring(game.PlaceId), inline = true },
            { name = "Job ID", value = tostring(game.JobId), inline = false }, { name = "Executor", value = identifyExecutorName(), inline = true }, { name = "Device", value =
            getDeviceType(), inline = true }, { name = "Country", value = Device.getCountry(), inline = true } }, footer = { text = "JX-EXECUTED" }, timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ") } } }
        local headers = { ["Content-Type"] = "application/json" }
        if token then headers.Authorization = "Bearer " .. token end
        local response = requestJson({ Url = Config.Backend.WebhookProxy, Method = "POST", Headers = headers, Body = jsonEncode(payload) })
        return response and response.Success or false
    end
    local Farm = { Enabled = false, UserWantsFarm = false, Busy = false, Status = "Idle", DiedCount = 0, EarnMoneyTotal = Settings.EarnMoneyTotal, StartCash = 0, StartedAt = 0,
        LastNotifyAt = 0, LastDiedIncrementAt = 0, LastRejoinAt = 0, ProcessedList = {}, SortedTargets = {}, TempIgnoredTargets = {}, ForcedNextTargetModel = nil, RetargetPending = false,
        CashAddedConnection = nil, CashAddedTextConnection = nil, LastCashAddedText = "", TargetConnections = {}, DiedConnection = nil, RenderConnection = nil, AdminConnections = {}, UI = {},
        State = { InProgress = false, CooldownUntil = 0, LastAttemptAt = 0, IsRising = false, HasReachedTargetY = false, SUZoneEntered = false, TowerZoneEntered = false, SW11ZoneEntered =
        false, CurrentZoneRoute = nil, SW11SavedEntryPathPoint = nil, SW11SavedVisualPath = nil, TowerFirstPosition = Vector3.new(-4520, 127, -783), TowerSecondPosition = Vector3.new(-4518,
        149, -780), SW11FirstPosition = Vector3.new(-4693, -32, -717), SW11SecondPosition = Vector3.new(-4693, -44, -731), SW11ThirdPosition = Vector3.new(-4693, -32, -743),
        SUFirstPosition = Vector3.new(-3897, 4, -456), RecoveryLoopFixFrom = Vector3.new(-4475, -22, -363), RecoveryLoopFixTo = Vector3.new(-4481, 4, -362), TargetY = 4.8, LastTimeTick = 0,
        LastActiveAt = 0, LastMoveAt = 0, LastFistsRecoveryAt = 0, FistsRecoveryBusy = false, RetryCount = 0, LastShopMainPart = nil } }
    local TargetNames = { "MediumSafe_T_45", "MediumSafe_T_46", "MediumSafe_SEW_2", "MediumSafe_SEW_8", "MediumSafe_HO_24", "MediumSafe_HO_39", "MediumSafe_TS_20", "MediumSafe_VC_21",
        "MediumSafe_VC_30", "MediumSafe_VC_38", "SmallSafe_SW_11", "Register_HO_23", "Register_TS_27", "Register_TS_4" }
    local TargetPositions = { MediumSafe_SEW_2 = Vector3.new(-4312.640625, -93.04354095459, -813.551086425781), MediumSafe_T_46 = Vector3.new(-4513.88330078125, 153.078231811523,
        -805.10205078125), MediumSafe_VC_30 = Vector3.new(-4855.64794921875, -199.84228515625, -868.460571289062), SmallSafe_SW_11 = Vector3.new(-4683.93310546875, -32.621650695801,
        -832.013366699219), MediumSafe_HO_39 = Vector3.new(-4421.9951171875, 25.813669204712, -53.739181518555), MediumSafe_T_45 = Vector3.new(-4514.361328125, 153.078231811523,
        -859.273742675781), Register_HO_23 = Vector3.new(-4429.865234375, 25.892944335938, -41.588287353516), MediumSafe_HO_24 = Vector3.new(-4826.80078125, -77.030784606934,
        -189.607925415039), MediumSafe_TS_20 = Vector3.new(-4704.6767578125, 5.222457885742, -171.515075683594), Register_TS_27 = Vector3.new(-4676.37890625, 5.208802700043,
        -150.077056884766), Register_TS_4 = Vector3.new(-4676.37890625, 5.208802700043, -146.077056884766), MediumSafe_VC_38 = Vector3.new(-4749.26220703125, -199.84228515625,
        -972.707702636719), MediumSafe_VC_21 = Vector3.new(-4804.431640625, -199.84228515625, -972.726379394531), MediumSafe_SEW_8 = Vector3.new(-4711.03271484375, -149.143432617188,
        -868.823913574219) }
    local TargetNameSet = {}
    for _, name in ipairs(TargetNames) do TargetNameSet[name] = true end
    local SUTargetNames = { MediumSafe_VC_21 = true, MediumSafe_VC_30 = true, MediumSafe_VC_38 = true, MediumSafe_SEW_2 = true, MediumSafe_SEW_8 = true, MediumSafe_HO_24 = true }
    local TowerTargetNames = { MediumSafe_T_45 = true, MediumSafe_T_46 = true }
    local SW11TargetNames = { SmallSafe_SW_11 = true }
    local ZoneRoutes = { MediumSafe_HO_39 = { zone = "HO", lowPos = Vector3.new(-4450, 4, -44), highPos = Vector3.new(-4448, 25, -48) }, Register_HO_23 = { zone = "HO", lowPos =
        Vector3.new(-4450, 4, -44), highPos = Vector3.new(-4448, 25, -48) }, MediumSafe_TS_20 = { zone = "TS", lowPos = Vector3.new(-4602, 4, -153), highPos = Vector3.new(-4609, 4, -153) },
        Register_TS_27 = { zone = "TS", lowPos = Vector3.new(-4602, 4, -153), highPos = Vector3.new(-4609, 4, -153) }, Register_TS_4 = { zone = "TS", lowPos = Vector3.new(-4602, 4, -153),
        highPos = Vector3.new(-4609, 4, -153) } }
    Environment.JXFarmTargetPositions = TargetPositions
    local function setUiText(control, text)
        if not control then return end
        if typeof(control) == "Instance" then
            control.Text = text
            return
        end
        if type(control) == "table" then
            if type(control.Set) == "function" then
                control:Set(text)
                return
            end
            if type(control.Update) == "function" then
                control:Update(text)
                return
            end
            if type(control.SetText) == "function" then
                control:SetText(text)
                return
            end
            local object = rawget(control, "Label") or rawget(control, "TextLabel") or rawget(control, "Instance")
            if typeof(object) == "Instance" and object:IsA("TextLabel") then object.Text = text end
        end
    end
    local function setStatus(value)
        Farm.Status = tostring(value)
        Environment.JXFarmActivity = Farm.Status
        if Farm.UI.Status then setUiText(Farm.UI.Status, "Status: " .. Farm.Status) end
    end
    local function isTargetBroken(model)
        local values = model and model:FindFirstChild("Values")
        local broken = values and values:FindFirstChild("Broken")
        return broken and broken:IsA("BoolValue") and broken.Value == true
    end
    local function getTargetPart(model)
        if not model then return nil end
        if model:IsA("BasePart") then return model end
        local mainPart = model:FindFirstChild("MainPart")
        return mainPart and mainPart:IsA("BasePart") and mainPart or nil
    end
    local function isSafeTarget(model) return model ~= nil and TargetNameSet[model.Name] == true end
    local function getMap() return Workspace:FindFirstChild("Map") end
    local function cleanIgnoredTargets()
        local now = tick()
        for target, expiresAt in pairs(Farm.TempIgnoredTargets) do
            if not target.Parent or expiresAt <= now then Farm.TempIgnoredTargets[target] = nil end
        end
    end
    local function rebuildTargets()
        local root = getRoot()
        local map = getMap()
        local targetFolder = map and map:FindFirstChild("BredMakurz")
        local targets = {}
        if not root or not targetFolder then
            Farm.SortedTargets = targets
            return targets
        end
        cleanIgnoredTargets()
        for _, object in ipairs(targetFolder:GetChildren()) do
            if object:IsA("Model") and TargetNameSet[object.Name] and not isTargetBroken(object) and not Farm.TempIgnoredTargets[object] then
                local part = object:FindFirstChild("MainPart")
                if part and part:IsA("BasePart") then table.insert(targets, { obj = object, part = part, distance = (part.Position - root.Position).Magnitude }) end
            end
        end
        table.sort(targets, function(left, right) return left.distance < right.distance end)
        Farm.SortedTargets = targets
        return targets
    end
    local function chooseTarget()
        if Farm.ForcedNextTargetModel and Farm.ForcedNextTargetModel.Parent and not isTargetBroken(Farm.ForcedNextTargetModel) then
            local model = Farm.ForcedNextTargetModel
            Farm.ForcedNextTargetModel = nil
            return model, getTargetPart(model)
        end
        for _, target in ipairs(rebuildTargets()) do
            if target.obj.Parent and target.part.Parent and not Farm.ProcessedList[target.obj] then return target.obj, target.part end
        end
        Farm.ProcessedList = {}
        for _, target in ipairs(rebuildTargets()) do
            if target.obj.Parent and target.part.Parent then return target.obj, target.part end
        end
        return nil, nil
    end
    local function ClearFarmESP()
        local Map = getMap()
        local TargetFolder = Map and Map:FindFirstChild("BredMakurz")
        if not TargetFolder then return end
        for _, Object in ipairs(TargetFolder:GetChildren()) do
            local Highlight = Object:FindFirstChild("ESP_Highlight")
            local Billboard = Object:FindFirstChild("ESP_Billboard")
            if Highlight then Highlight:Destroy() end
            if Billboard then Billboard:Destroy() end
        end
    end
    local function disconnectTargetConnections()
        for object, connection in pairs(Farm.TargetConnections) do
            if connection then connection:Disconnect() end
            Farm.TargetConnections[object] = nil
        end
    end
    local function bindTargetModel(model)
        if not model or not model:IsA("Model") or not isSafeTarget(model) or Farm.TargetConnections[model] then return end
        local values = model:FindFirstChild("Values")
        local broken = values and values:FindFirstChild("Broken")
        if broken and broken:IsA("BoolValue") then
            Farm.TargetConnections[model] = broken:GetPropertyChangedSignal("Value"):Connect(function()
                Farm.ProcessedList[model] = nil
                Farm.RetargetPending = true
            end)
        end
    end
    local function bindTargetTracking()
        disconnectTargetConnections()
        local map = getMap()
        local targetFolder = map and map:FindFirstChild("BredMakurz")
        if not targetFolder then return end
        for _, object in ipairs(targetFolder:GetChildren()) do bindTargetModel(object) end
        Farm.TargetConnections.TargetAdded = targetFolder.ChildAdded:Connect(function(object)
            task.defer(function() bindTargetModel(object) end)
        end)
        Farm.TargetConnections.TargetRemoving = targetFolder.ChildRemoved:Connect(function(object)
            local connection = Farm.TargetConnections[object]
            if connection then
                connection:Disconnect()
                Farm.TargetConnections[object] = nil
            end
            Farm.ProcessedList[object] = nil
            Farm.TempIgnoredTargets[object] = nil
        end)
    end
    local function computePath(destination)
        local root = getRoot()
        local humanoid = getHumanoid()
        if not root or not humanoid then return nil end
        local path = PathfindingService:CreatePath({ AgentRadius = math.max(2, root.Size.X * 0.5), AgentHeight = math.max(5, humanoid.HipHeight + root.Size.Y + 2), AgentCanJump = true,
            AgentCanClimb = true, WaypointSpacing = tonumber(Settings.WaypointSpacing) or 3, Costs = {} })
        local ok = safeCall(path.ComputeAsync, path, root.Position, destination)
        if not ok or path.Status ~= Enum.PathStatus.Success then return nil end
        return path:GetWaypoints()
    end
    local function facePosition(position)
        local root = getRoot()
        if root then
            local flat = Vector3.new(position.X, root.Position.Y, position.Z)
            if(flat - root.Position).Magnitude > 0.01 then root.CFrame = CFrame.lookAt(root.Position, flat) end
        end
    end
    local function moveToPosition(position, statusText)
        local root = getRoot()
        local humanoid = getHumanoid()
        if not root or not humanoid or isDead() then return false end
        setStatus(statusText or "Moving To Target")
        Environment.JXFarmMove = true
        local waypoints = computePath(position)
        if not waypoints then waypoints = { { Position = position, Action = Enum.PathWaypointAction.Walk } } end
        for _, waypoint in ipairs(waypoints) do
            if not Farm.Enabled or isDead() then
                Environment.JXFarmMove = false
                return false
            end
            if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
            local distance = (root.Position - waypoint.Position).Magnitude
            local duration = math.max(distance / math.max(Settings.MoveSpeed, 1), 0.05)
            local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = CFrame.new(waypoint.Position, waypoint.Position + root.CFrame.LookVector) })
            tween:Play()
            local startedAt = tick()
            while tween.PlaybackState == Enum.PlaybackState.Playing do
                if not Farm.Enabled or isDead() or tick() - startedAt > duration + 3 then
                    tween:Cancel()
                    Environment.JXFarmMove = false
                    return false
                end
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                task.wait()
            end
        end
        Environment.JXFarmMove = false
        return(root.Position - position).Magnitude <= 12
    end
    local function moveRoute(positions, statusText)
        for _, position in ipairs(positions) do
            if not moveToPosition(position, statusText) then return false end
        end
        return true
    end
    local function enterTower(model, part)
        Farm.State.TowerZoneEntered = true
        return moveRoute({ Farm.State.TowerFirstPosition, Farm.State.TowerSecondPosition, part.Position }, "Moving To Target")
    end
    local function leaveTower()
        if not Farm.State.TowerZoneEntered then return true end
        setStatus("Leaving Tower")
        local moved = moveRoute({ Farm.State.TowerSecondPosition, Farm.State.TowerFirstPosition }, "Leaving Tower")
        Farm.State.TowerZoneEntered = false
        setStatus("Idle")
        return moved
    end
    local function enterSW11(model, part)
        Farm.State.SW11ZoneEntered = true
        local root = getRoot()
        Farm.State.SW11SavedEntryPathPoint = root and root.Position or nil
        Farm.State.SW11SavedVisualPath = { Farm.State.SW11FirstPosition, Farm.State.SW11SecondPosition, Farm.State.SW11ThirdPosition }
        setStatus("Entering SW_11")
        return moveRoute({ Farm.State.SW11FirstPosition, Farm.State.SW11SecondPosition, Farm.State.SW11ThirdPosition, part.Position }, "Entering SW_11")
    end
    local function leaveSW11()
        if not Farm.State.SW11ZoneEntered then return true end
        setStatus("Leaving SW_11")
        local moved = moveRoute({ Farm.State.SW11ThirdPosition, Farm.State.SW11SecondPosition, Farm.State.SW11FirstPosition }, "Leaving SW_11")
        if moved and Farm.State.SW11SavedEntryPathPoint then moved = moveToPosition(Farm.State.SW11SavedEntryPathPoint, "Leaving SW_11") end
        Farm.State.SW11ZoneEntered = false
        Farm.State.SW11SavedEntryPathPoint = nil
        Farm.State.SW11SavedVisualPath = nil
        setStatus("Idle")
        return moved
    end
    local function enterZoneRoute(model, part)
        local route = ZoneRoutes[model.Name]
        if not route then return false end
        Farm.State.CurrentZoneRoute = route
        return moveRoute({ route.lowPos, route.highPos, part.Position }, "Moving To Target")
    end
    local function leaveZoneRoute()
        local route = Farm.State.CurrentZoneRoute
        if not route then return true end
        local moved = moveRoute({ route.highPos, route.lowPos }, "Leaving " .. route.zone)
        Farm.State.CurrentZoneRoute = nil
        return moved
    end
    local function enterSURoute(model, part)
        Farm.State.SUZoneEntered = true
        return moveRoute({ Farm.State.SUFirstPosition, part.Position }, "Moving To Target")
    end
    local function leaveSURoute()
        if not Farm.State.SUZoneEntered then return true end
        local moved = moveToPosition(Farm.State.SUFirstPosition, "Leaving SU")
        Farm.State.SUZoneEntered = false
        return moved
    end
    local function moveToTargetByRoute(model, part)
        if SW11TargetNames[model.Name] then return enterSW11(model, part) end
        if TowerTargetNames[model.Name] then return enterTower(model, part) end
        if ZoneRoutes[model.Name] then return enterZoneRoute(model, part) end
        if SUTargetNames[model.Name] then return enterSURoute(model, part) end
        return moveToPosition(part.Position, "Moving To Target")
    end
    local function teleportRecovery(position)
        local root = getRoot()
        if not root or not position then return false end
        setStatus("Teleport Recovery")
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.new(position)
        task.wait(Settings.RecoveryIdleSec)
        return(root.Position - position).Magnitude <= 6
    end
    local function runRecoveryLoopFix() return moveRoute({ Farm.State.RecoveryLoopFixFrom, Farm.State.RecoveryLoopFixTo }, "Recovery Move") end
    local function recoveryMove(position)
        local root = getRoot()
        if not root or not position then return false end
        setStatus("Recovery Move")
        if moveToPosition(position, "Recovering Path") then return true end
        if runRecoveryLoopFix() and moveToPosition(position, "Recovering Path") then return true end
        return teleportRecovery(position)
    end
    local function handlePostMoveSuccess(model)
        Farm.State.RetryCount = 0
        Farm.State.LastActiveAt = tick()
        Farm.State.HasReachedTargetY = true
        Farm.State.TargetY = getTargetPart(model) and getTargetPart(model).Position.Y or nil
        return true
    end
    local function handlePostMoveFailure(model, part)
        Farm.State.RetryCount += 1
        Farm.State.HasReachedTargetY = false
        if Farm.State.RetryCount <= 2 and part and recoveryMove(part.Position) then return true end
        Farm.TempIgnoredTargets[model] = tick() + math.max(1, tonumber(Settings.IgnoreDuration) or 6)
        Farm.RetargetPending = true
        return false
    end
    local function processTargetMoveOutcome(model, part, moved)
        if moved then return handlePostMoveSuccess(model) end
        return handlePostMoveFailure(model, part)
    end
    local function getTool(namePattern)
        local character = getCharacter()
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({ character, backpack }) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(namePattern), 1, true) then return tool end
                end
            end
        end
        return nil
    end
    local function equipTool(tool)
        local humanoid = getHumanoid()
        if humanoid and tool then
            safeCall(humanoid.EquipTool, humanoid, tool)
            task.wait(0.1)
            return tool.Parent == getCharacter()
        end
        return false
    end
    local function unequipTools()
        local humanoid = getHumanoid()
        if humanoid then safeCall(humanoid.UnequipTools, humanoid) end
    end
    local function hasFistsTool() return getTool("fists") ~= nil end
    local ShopItemContracts = { Crowbar = { ShopType = "IllegalStore", Category = "Melees", ShopModelName = "Dealer" }, Lockpick = { ShopType = "LegalStore", Category = "Misc",
        ShopModelName = "ArmoryDealer" } }
    local function getShopMainPart(contract)
        local map = getMap()
        local shops = map and map:FindFirstChild("Shopz")
        local shop = shops and shops:FindFirstChild(contract.ShopModelName)
        local mainPart = shop and shop:FindFirstChild("MainPart")
        return mainPart and mainPart:IsA("BasePart") and mainPart or nil
    end
    local function buyItem(itemName)
        local contract = ShopItemContracts[itemName]
        if not contract then return false end
        local shopMainPart = getShopMainPart(contract)
        if not shopMainPart then return false end
        if not moveToPosition(shopMainPart.Position, "Moving To Dealer for " .. itemName) then return false end
        task.wait(Settings.ShopPreOpenSec)
        setStatus(itemName == "Lockpick" and "Buying Lockpicks (idle 5s in shop)" or "Buying " .. itemName)
        if ShopProtectionRemote then safeCall(ShopProtectionRemote.FireServer, ShopProtectionRemote, true, "shop", shopMainPart, contract.ShopType) end
        local ok, success = safeCall(ShopRemote.InvokeServer, ShopRemote, contract.ShopType, contract.Category, itemName, shopMainPart, nil, true)
        if ShopProtectionRemote then safeCall(ShopProtectionRemote.FireServer, ShopProtectionRemote, false) end
        task.wait(Settings.ShopAfterOpenSec)
        if not ok or not success then return false end
        local startedAt = tick()
        while tick() - startedAt < Settings.ShopBuyMaxWaitSec do
            if getTool(itemName) then
                task.wait(Settings.ShopPostBuySec)
                return true
            end
            task.wait(Settings.ShopBuyPollSec)
        end
        return false
    end
    local function ensureBreakingTools()
        if Settings.BreakingMethod == "Fist + Lockpick" then
            if not hasFistsTool() then return false end
            local lockpick = getTool("lockpick")
            if not lockpick then
                setStatus("Moving To Dealer for Lockpick")
                if not buyItem("Lockpick") then return false end
            end
            return true
        end
        local crowbar = getTool("crowbar")
        if not crowbar then
            setStatus("Buying Crowbar")
            if not buyItem("Crowbar") then return false end
        end
        return true
    end
    local function countToolsByName(name)
        local total = 0
        local character = getCharacter()
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({ character, backpack }) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") and item.Name == name then total += 1 end
                end
            end
        end
        return total
    end
    local function findNearestLockpickShopPart()
        local root = getRoot()
        local selected
        local selectedDistance = math.huge
        for _, contract in ipairs({ ShopItemContracts.Lockpick, ShopItemContracts.Crowbar }) do
            local part = getShopMainPart(contract)
            if part then
                local distance = root and(part.Position - root.Position).Magnitude or 0
                if distance < selectedDistance then
                    selected = part
                    selectedDistance = distance
                end
            end
        end
        return selected
    end
    local function purchaseLockpickAt(shopPart)
        if not shopPart then return false end
        local illegalOk, illegalAccepted, illegalMessage = safeCall(ShopRemote.InvokeServer, ShopRemote, "IllegalStore", "Misc", "Lockpick", shopPart, nil, true, nil)
        task.wait(0.25)
        local legalOk, legalAccepted, legalMessage = safeCall(ShopRemote.InvokeServer, ShopRemote, "LegalStore", "Misc", "Lockpick", shopPart, nil, true)
        return illegalOk and(illegalAccepted == true or illegalMessage == "PURCHASE COMPLETE") or legalOk and(legalAccepted == true or legalMessage == "PURCHASE COMPLETE")
    end
    local function buyLockpickBatch(quantity)
        quantity = math.max(1, math.floor(tonumber(quantity) or 7))
        local shopPart = findNearestLockpickShopPart()
        if not shopPart then return false end
        if not moveToPosition(shopPart.Position, "Moving To Dealer for Lockpick") then return false end
        local startingCount = countToolsByName("Lockpick")
        local successfulPurchases = 0
        for _ = 1, quantity do
            if not Farm.Enabled then break end
            if purchaseLockpickAt(shopPart) then successfulPurchases += 1 end
            task.wait(0.20)
        end
        task.wait(0.75)
        return countToolsByName("Lockpick") > startingCount or successfulPurchases > 0
    end
    local function dropLockpick(tool)
        local root = getRoot()
        if not tool or not DropToolRemote or not root then return false end
        local ok = safeCall(DropToolRemote.FireServer, DropToolRemote, tool, nil, root.Position)
        return ok
    end
    local function tryLockpickTarget(target)
        local tool = getTool("Lockpick")
        if not tool then return false, "lockpick_missing" end
        if not equipTool(tool) then return false, "lockpick_equip_failed" end
        local remote = tool:FindFirstChild("Remote")
        if not remote or not remote:IsA("RemoteFunction") then return false, "lockpick_remote_missing" end
        local startOk, token = safeCall(remote.InvokeServer, remote, "S", target, "s")
        if startOk and type(token) == "number" then
            task.wait(0.25)
            local finishOk = safeCall(remote.InvokeServer, remote, "D", target, "s", token)
            return finishOk, finishOk and "lockpick_success" or "lockpick_finish_failed"
        end
        dropLockpick(tool)
        return false, "lockpick_failed"
    end
    local function strikeTargetWithCrowbar(target)
        local tool = getTool("Crowbar")
        local character = getCharacter()
        local targetPart = getTargetPart(target)
        local rightArm = character and(character:FindFirstChild("Right Arm") or character:FindFirstChild("RightHand"))
        if not MeleeRemote or not MeleeHitRemote or not tool or not character or not rightArm or not targetPart then return false end
        equipTool(tool)
        local invokeOk, token = safeCall(MeleeRemote.InvokeServer, MeleeRemote, "🍞", tick(), tool, "DZDRRRKI", target, "Register")
        if invokeOk and type(token) == "number" then
            local fireOk = safeCall(MeleeHitRemote.FireServer, MeleeHitRemote, "🍞", tick(), tool, "2389ZFX34", token, false, rightArm, targetPart, target, targetPart.Position,
                targetPart.Position)
            return fireOk
        end
        return invokeOk
    end
    local function breakTarget(target, targetPart)
        if not target or not target.Parent then return false end
        if isTargetBroken(target) then return true end
        if Settings.BreakingMethod == "Crowbar" then
            if not getTool("Crowbar") and not buyItem("Crowbar") then return false end
            local startedAt = tick()
            while Farm.Enabled and target.Parent and not isTargetBroken(target) and tick() - startedAt < 30 do
                targetPart = getTargetPart(target)
                local root = getRoot()
                if not targetPart or not root then return false end
                if(targetPart.Position - root.Position).Magnitude > 8 then
                    if not moveToTargetByRoute(target, targetPart) then return false end
                end
                strikeTargetWithCrowbar(target)
                task.wait(0.25)
            end
        else
            local startedAt = tick()
            local nextBatchSize = 7
            while Farm.Enabled and target.Parent and not isTargetBroken(target) and tick() - startedAt < 120 do
                targetPart = getTargetPart(target)
                local root = getRoot()
                if not targetPart or not root then return false end
                if(targetPart.Position - root.Position).Magnitude > 8 then
                    if not moveToTargetByRoute(target, targetPart) then return false end
                end
                if not getTool("Lockpick") then
                    if not buyLockpickBatch(nextBatchSize) then return false end
                    nextBatchSize = 15
                    if target.Parent and not isTargetBroken(target) then
                        targetPart = getTargetPart(target)
                        if targetPart then moveToTargetByRoute(target, targetPart) end
                    end
                end
                local opened = tryLockpickTarget(target)
                if opened then
                    local completedAt = tick()
                    while target.Parent and not isTargetBroken(target) and tick() - completedAt < 12 do task.wait(0.10) end
                    break
                end
                task.wait(1.25)
            end
        end
        unequipTools()
        return isTargetBroken(target)
    end
    local function getSpawnedBread()
        local filter = Workspace:FindFirstChild("Filter")
        return filter and filter:FindFirstChild("SpawnedBread") or nil
    end
    local function normalizeCashObject(object)
        local spawnedBread = getSpawnedBread()
        if not spawnedBread or not object then return nil end
        if object.Parent ~= spawnedBread then object = object.Parent end
        if object and object:IsA("BasePart") and object.Parent == spawnedBread then return object end
        return nil
    end
    local function collectCashObject(object)
        local cashObject = normalizeCashObject(object)
        local root = getRoot()
        if not cashObject or not root or(cashObject.Position - root.Position).Magnitude >= 10 then return false end
        local ok = safeCall(CashPickupRemote.FireServer, CashPickupRemote, cashObject, nil)
        return ok
    end
    local function clearNearbyCashNoMove()
        if not Settings.AutoMoney then return 0 end
        local root = getRoot()
        local spawnedBread = getSpawnedBread()
        if not root or not spawnedBread then return 0 end
        local collected = 0
        for _, cashObject in ipairs(spawnedBread:GetChildren()) do
            if cashObject:IsA("BasePart") and cashObject.Transparency < 1 and(cashObject.Position - root.Position).Magnitude <= Settings.PickupDistance then
                if collectCashObject(cashObject) then collected += 1 end
            end
        end
        return collected
    end
    local function collectNearbyCash(duration)
        setStatus("Collecting")
        local startedAt = tick()
        while Farm.Enabled and tick() - startedAt < (duration or 3) do
            clearNearbyCashNoMove()
            task.wait(0.15)
        end
    end
    local function findNearestATMMainPart()
        local root = getRoot()
        local map = getMap()
        local atmFolder = map and map:FindFirstChild("ATMz")
        if not root or not atmFolder then return nil end
        local best
        local bestDistance = math.huge
        for _, atmModel in ipairs(atmFolder:GetChildren()) do
            if atmModel:IsA("Model") and atmModel.Name == "ATM" then
                local mainPart = atmModel:FindFirstChild("MainPart")
                if mainPart and mainPart:IsA("BasePart") then
                    local distance = (mainPart.Position - root.Position).Magnitude
                    if distance < bestDistance then
                        best = mainPart
                        bestDistance = distance
                    end
                end
            end
        end
        return best
    end
    local function claimAllowance()
        if not Settings.AutoAllowance then return false end
        local allowance = readAllowanceText()
        if not string.find(string.upper(allowance), "READY", 1, true) then return false end
        local atmMainPart = findNearestATMMainPart()
        if not atmMainPart then return false end
        setStatus("Claiming Allowance")
        local ok, success = safeCall(ClaimAllowanceRemote.InvokeServer, ClaimAllowanceRemote, atmMainPart, nil)
        task.wait(0.5)
        return ok and success == true
    end
    local function tryDeposit(force)
        if not Settings.AutoDeposit and not force then return false end
        local cash = readCashAmountValue()
        local threshold = math.max(1, tonumber(Settings.AutoDepositThresholdK) or 5) * 1000
        if not force and cash < threshold then return false end
        local atmMainPart = findNearestATMMainPart()
        if not atmMainPart then return false end
        Farm.State.InProgress = true
        setStatus("Depositing Cash")
        local moved = moveToPosition(atmMainPart.Position, "Depositing Cash")
        local success = false
        if moved then
            local ok, result = safeCall(ATMRemote.InvokeServer, ATMRemote, "DP", cash, atmMainPart)
            success = ok and result == true
            task.wait(1)
        end
        Farm.State.InProgress = false
        return moved and success
    end
    local function TryDepositAllNow() return tryDeposit(true) end
    local function handleHackSuccess(model)
        Farm.ProcessedList[model] = true
        Farm.RetargetPending = false
        Farm.State.LastActiveAt = tick()
        collectNearbyCash(3)
        if SW11TargetNames[model.Name] then
            leaveSW11()
        elseif TowerTargetNames[model.Name] then
            leaveTower()
        elseif ZoneRoutes[model.Name] then
            leaveZoneRoute()
        elseif SUTargetNames[model.Name] then
            leaveSURoute()
        end
        return true
    end
    local function processTarget(model, part)
        if not model or not part then return false end
        local moved = moveToTargetByRoute(model, part)
        if not processTargetMoveOutcome(model, part, moved) then return false end
        if not breakTarget(model, part) then
            Farm.TempIgnoredTargets[model] = tick() + Settings.IgnoreDuration
            return false
        end
        return handleHackSuccess(model)
    end
    local function findCashAddedLabel()
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        local core = playerGui and playerGui:FindFirstChild("CoreGUI")
        local stats = core and core:FindFirstChild("StatsFrame")
        local frame2 = stats and stats:FindFirstChild("Frame2")
        local frame = frame2 and frame2:FindFirstChild("Frame")
        local container = frame and frame:FindFirstChild("Container")
        local cash = container and container:FindFirstChild("Cash")
        if not cash then return nil end
        local added = cash:FindFirstChild("Added")
        if added and added:IsA("TextLabel") then return added end
        for _, object in ipairs(cash:GetDescendants()) do
            if object:IsA("TextLabel") and string.lower(object.Name) == "added" then return object end
        end
        return nil
    end
    local function processCashAddedText(text)
        text = trim(text)
        if text == "" or text == Farm.LastCashAddedText then return end
        Farm.LastCashAddedText = text
        if text:sub(1, 1) ~= "+" then return end
        local amount = parseCashTextToNumber(text)
        if amount > 0 then
            Farm.EarnMoneyTotal += amount
            Settings.EarnMoneyTotal = Farm.EarnMoneyTotal
        end
    end
    local function bindCashTracking()
        if Farm.CashAddedConnection then
            Farm.CashAddedConnection:Disconnect()
            Farm.CashAddedConnection = nil
        end
        if Farm.CashAddedTextConnection then
            Farm.CashAddedTextConnection:Disconnect()
            Farm.CashAddedTextConnection = nil
        end
        local label = findCashAddedLabel()
        if label then
            Farm.CashAddedTextConnection = label:GetPropertyChangedSignal("Text"):Connect(function() processCashAddedText(label.Text) end)
            processCashAddedText(label.Text)
            return
        end
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            Farm.CashAddedConnection = playerGui.DescendantAdded:Connect(function(object)
                if object:IsA("TextLabel") and string.lower(object.Name) == "added" then task.defer(bindCashTracking) end
            end)
        end
    end
    local function refreshInfoLabels()
        local elapsed = Farm.StartedAt > 0 and math.floor(tick() - Farm.StartedAt) or 0
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor(elapsed % 3600 / 60)
        local seconds = elapsed % 60
        local currentCash = readCashAmountValue()
        local fallbackTotal = Settings.EarnMoneyTotal + math.max(0, currentCash - Farm.StartCash)
        if fallbackTotal > Farm.EarnMoneyTotal then Farm.EarnMoneyTotal = fallbackTotal end
        if Farm.UI.Died then setUiText(Farm.UI.Died, "Died: " .. tostring(Farm.DiedCount)) end
        if Farm.UI.Bank then setUiText(Farm.UI.Bank, "Bank: " .. readBankAmountText()) end
        if Farm.UI.Allowance then setUiText(Farm.UI.Allowance, "Allowance: " .. readAllowanceText()) end
        if Farm.UI.Time then setUiText(Farm.UI.Time, string.format("Time: %02d:%02d:%02d", hours, minutes, seconds)) end
        if Farm.UI.EarnMoney then setUiText(Farm.UI.EarnMoney, "Earn Money: " .. tostring(math.floor(Farm.EarnMoneyTotal))) end
    end
    local function resetInfo()
        Settings.EarnMoneyTotal = 0
        Farm.EarnMoneyTotal = 0
        Farm.StartCash = readCashAmountValue()
        Farm.DiedCount = 0
        Farm.StartedAt = tick()
        Settings.save()
        refreshInfoLabels()
        notify("Notification", "INFO reset complete", 4)
    end
    local function recommendServer()
        local targets = rebuildTargets()
        local count = #targets
        local text
        if count <= 2 then
            text = "Few targets (" .. tostring(count) .. "), too many competitors. Switch server."
        else
            text = "Enough targets (" .. tostring(count) .. "), farming is viable."
        end
        notify("Recommendation", text, 7)
    end
    local function detectAdmin(player)
        if player == LocalPlayer then return false end
        if player:GetAttribute("IsAdmin") == true then return true end
        for _, containerName in ipairs({ "leaderstats", "Data", "Values", "Admins", "Adminz" }) do
            local container = player:FindFirstChild(containerName)
            if container then
                local value = container:FindFirstChild("Admin") or container:FindFirstChild("IsAdmin")
                if value and value:IsA("BoolValue") and value.Value then return true end
            end
        end
        return false
    end
    local function rejoin(reason)
        if not Settings.AntiRejoin or tick() - Farm.LastRejoinAt < 10 then return end
        Farm.LastRejoinAt = tick()
        notify("JX", tostring(reason or "Rejoining"), 4)
        safeCall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
    end
    local function adminCheck()
        if not Settings.AdminCheck then return false end
        for _, player in ipairs(Players:GetPlayers()) do
            if detectAdmin(player) then
                rejoin("Admin detected")
                return true
            end
        end
        return false
    end
    local function bindAdminDetection()
        table.insert(Farm.AdminConnections, Players.PlayerAdded:Connect(function(player)
            task.wait(1)
            if Settings.AdminCheck and detectAdmin(player) then rejoin("Admin detected: " .. player.Name) end
        end))
        safeCall(function()
            local promptGui = CoreGui:FindFirstChild("RobloxPromptGui")
            local overlay = promptGui and promptGui:FindFirstChild("promptOverlay")
            if overlay then
                table.insert(Farm.AdminConnections, overlay.DescendantAdded:Connect(function(object)
                    if object:IsA("TextLabel") then
                        local text = string.lower(tostring(object.Text))
                        if text:find("kick", 1, true) or text:find("kicked", 1, true) or text:find("disconnect", 1, true) or text:find("error", 1, true) then
                            rejoin("Prompt: " .. object.Text)
                        end
                    end
                end))
            end
        end)
        safeCall(function()
            table.insert(Farm.AdminConnections, GuiService.ErrorMessageChanged:Connect(function(message)
                local text = string.lower(tostring(message))
                if text:find("kick", 1, true) or text:find("disconnect", 1, true) or text:find("error", 1, true) then rejoin("GuiService: " .. tostring(message)) end
            end))
        end)
    end
    local function bindAntiAFK()
        LocalPlayer.Idled:Connect(function()
            if not Settings.AntiAFK then return end
            safeCall(VirtualUser.CaptureController, VirtualUser)
            safeCall(VirtualUser.ClickButton2, VirtualUser, Vector2.new())
        end)
    end
    local NoFallState = { HookInstalled = false, CharacterConnection = nil }
    local function applyNoFallCharacterState()
        if not Settings.AntiFallDamage then return end
        local character = getCharacter()
        if not character then return end
        local charStats = character:FindFirstChild("CharStats")
        if not charStats then return end
        local playerStats = charStats:FindFirstChild(LocalPlayer.Name) or charStats:FindFirstChild(tostring(LocalPlayer.UserId)) or charStats
        local ragdollSwitch = playerStats:FindFirstChild("RagdollSwitch") or charStats:FindFirstChild("RagdollSwitch", true)
        local ragdollTime = playerStats:FindFirstChild("RagdollTime") or charStats:FindFirstChild("RagdollTime", true)
        if ragdollSwitch and ragdollSwitch:IsA("BoolValue") then ragdollSwitch.Value = false end
        if ragdollTime and(ragdollTime:IsA("NumberValue") or ragdollTime:IsA("IntValue")) then ragdollTime.Value = 0 end
    end
    local function bindNoFall()
        Environment.CV2_NoFall = Settings.AntiFallDamage
        if not NoFallState.HookInstalled and type(hookmetamethod) == "function" and type(newcclosure) == "function" and type(getnamecallmethod) == "function" then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if Settings.AntiFallDamage and Environment.CV2_NoFall and self == FallRemote and getnamecallmethod() == "FireServer" and select(1, ...) == "FlllD" then return nil end
                return oldNamecall(self, ...)
            end))
            NoFallState.HookInstalled = true
        end
        if not NoFallState.CharacterConnection then
            NoFallState.CharacterConnection = RunService.Heartbeat:Connect(function()
                Environment.CV2_NoFall = Settings.AntiFallDamage
                applyNoFallCharacterState()
            end)
        end
        applyNoFallCharacterState()
    end
    local InvisState = { Enabled = false, WarningGui = nil, WarningLabel = nil, Animation = nil, Track = nil, HeartbeatConnection = nil }
    local function ensureInvisWarningGui()
        if InvisState.WarningGui and InvisState.WarningGui.Parent then return InvisState.WarningGui, InvisState.WarningLabel end
        local existing = UiParent:FindFirstChild("JXInvisWarningGUI") or UiParent:FindFirstChild("InvisWarningGUI") or UiParent:FindFirstChild("WarningGUI")
        if existing then
            InvisState.WarningGui = existing
            InvisState.WarningLabel = existing:FindFirstChildWhichIsA("TextLabel", true)
            return InvisState.WarningGui, InvisState.WarningLabel
        end
        local screen = Instance.new("ScreenGui")
        screen.Name = "JXInvisWarningGUI"
        screen.ResetOnSpawn = false
        screen.Parent = UiParent
        local label = Instance.new("TextLabel")
        label.Name = "TextLabel"
        label.AnchorPoint = Vector2.new(0.5, 0.5)
        label.Position = UDim2.new(0.5, 0, 0.75, 0)
        label.Size = UDim2.new(0, 420, 0, 52)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.Text = "VISIBLE WARNING"
        label.TextSize = 30
        label.TextColor3 = Color3.fromRGB(190, 190, 190)
        label.Visible = false
        label.Parent = screen
        InvisState.WarningGui = screen
        InvisState.WarningLabel = label
        return InvisState.WarningGui, InvisState.WarningLabel
    end
    local function setVisibleBodyTransparency(character, fromTransparency, toTransparency)
        if not character then return end
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart") and object.Name ~= "HumanoidRootPart" and(fromTransparency == nil or object.Transparency == fromTransparency) then
                if fromTransparency ~= nil or object.Transparency ~= 1 then object.Transparency = toTransparency end
            end
        end
    end
    local function stopInvisTrack()
        if InvisState.Track then
            safeCall(InvisState.Track.Stop, InvisState.Track)
            InvisState.Track = nil
        end
    end
    local function updateInvisCharacter()
        if not InvisState.Enabled then return end
        local character = getCharacter()
        local humanoid = getHumanoid(character)
        local root = getRoot(character)
        local torso = character and character:FindFirstChild("Torso")
        local camera = Workspace.CurrentCamera
        if not character or not humanoid or not root or not torso or not camera then return end
        camera.CameraSubject = root
        if InvisState.WarningLabel then InvisState.WarningLabel.Visible = humanoid.FloorMaterial == Enum.Material.Air end
        local _, cameraYaw = camera.CFrame:ToOrientation()
        root.CFrame = CFrame.new(root.Position) * CFrame.fromOrientation(0, cameraYaw, 0)
        root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
        humanoid.CameraOffset = Vector3.new(0, 1.44, 0)
        if not InvisState.Animation then
            InvisState.Animation = Instance.new("Animation")
            InvisState.Animation.AnimationId = "rbxassetid://215384594"
        end
        stopInvisTrack()
        local ok, track = safeCall(humanoid.LoadAnimation, humanoid, InvisState.Animation)
        if ok and track then
            InvisState.Track = track
            track.Priority = Enum.AnimationPriority.Action4
            track:Play()
            track:AdjustSpeed(0)
            track.TimePosition = 0.3
        end
        RunService.RenderStepped:Wait()
        stopInvisTrack()
        local lookVector = camera.CFrame.LookVector
        local horizontal = Vector3.new(lookVector.X, 0, lookVector.Z)
        if horizontal.Magnitude > 0 then
            horizontal = horizontal.Unit
            root.CFrame = CFrame.new(root.Position, root.Position + horizontal)
        end
        setVisibleBodyTransparency(character, nil, 0.5)
    end
    local function ensureInvisHeartbeat()
        if InvisState.HeartbeatConnection then return end
        InvisState.HeartbeatConnection = RunService.Heartbeat:Connect(function()
            if InvisState.Enabled then
                safeCall(updateInvisCharacter)
            elseif InvisState.WarningLabel then
                InvisState.WarningLabel.Visible = false
            end
        end)
    end
    local function invisEnable()
        local character = getCharacter()
        if not character or not character:FindFirstChild("Torso") then
            notify("Invisibility NOT AVAILABLE", "R6 avatar required", 6)
            return false
        end
        InvisState.Enabled = true
        Settings.HideBody = true
        Environment.JXFarmInvis = true
        Environment.UserWantsInvis = true
        Environment.IsInvisEnabled = true
        ensureInvisWarningGui()
        ensureInvisHeartbeat()
        local root = getRoot(character)
        local camera = Workspace.CurrentCamera
        if camera and root then camera.CameraSubject = root end
        safeCall(updateInvisCharacter)
        return true
    end
    local function invisDisable()
        InvisState.Enabled = false
        Settings.HideBody = false
        Environment.JXFarmInvis = false
        Environment.UserWantsInvis = false
        Environment.IsInvisEnabled = false
        stopInvisTrack()
        local character = getCharacter()
        local humanoid = getHumanoid(character)
        local camera = Workspace.CurrentCamera
        if humanoid then humanoid.CameraOffset = Vector3.zero end
        if camera and humanoid then camera.CameraSubject = humanoid end
        setVisibleBodyTransparency(character, 0.5, 0)
        if InvisState.WarningLabel then InvisState.WarningLabel.Visible = false end
        return true
    end
    _G.Invis_Enable = invisEnable
    _G.Invis_Disable = invisDisable
    local function bindDeathTracking()
        if Farm.DiedConnection then
            Farm.DiedConnection:Disconnect()
            Farm.DiedConnection = nil
        end
        local humanoid = getHumanoid()
        if humanoid then
            Farm.DiedConnection = humanoid.Died:Connect(function()
                if tick() - Farm.LastDiedIncrementAt > 1 then
                    Farm.LastDiedIncrementAt = tick()
                    Farm.DiedCount += 1
                    refreshInfoLabels()
                end
                setStatus("Dead")
            end)
        end
    end
    local function autoRespawnLoop()
        task.spawn(function()
            while true do
                if Settings.AutoRespawn and isDead() then
                    setStatus("Dead")
                    local character = LocalPlayer.CharacterAdded:Wait()
                    character:WaitForChild("Humanoid", 15)
                    task.wait(Settings.FarmDeadWaitSec)
                    bindDeathTracking()
                    if InvisState.Enabled then task.defer(invisEnable) end
                end
                task.wait(1)
            end
        end)
    end
    local function performAutoPlayRemoteSequence()
        local invoked = false
        if AutoPlayRemote and AutoPlayRemote:IsA("RemoteFunction") then
            local ok = safeCall(AutoPlayRemote.InvokeServer, AutoPlayRemote, "", "\15daz\18tough\19")
            invoked = ok
        end
        if UpdateClientRemote and UpdateClientRemote:IsA("RemoteEvent") then safeCall(UpdateClientRemote.FireServer, UpdateClientRemote) end
        return invoked
    end
    local function bindLoadTimeDetection()
        local state = Environment.JXFarmAutoPlayState
        if type(state) ~= "table" then
            state = { enabled = Settings.AutoPlay, busy = false, loadTimeDetected = false, loadTimeReadyAt = 0 }
            Environment.JXFarmAutoPlayState = state
        end
        local function inspect(message)
            local textValue = tostring(message)
            if string.find(textValue, "LOAD%s*TIME%s*:") then
                state.loadTimeDetected = true
                state.loadTimeReadyAt = tick() + 5
                notify("Notification", "LOAD TIME detected. Auto Play starts in 5s.", 5)
            end
        end
        LogService.MessageOut:Connect(inspect)
        safeCall(function()
            for _, entry in ipairs(LogService:GetLogHistory()) do inspect(entry.message or entry.Message or entry.text or "") end
        end)
        task.spawn(function()
            while true do
                state.enabled = Settings.AutoPlay
                if state.enabled and not state.busy then
                    state.busy = true
                    local startedAt = tick()
                    while Settings.AutoPlay and tick() - startedAt < 20 do
                        performAutoPlayRemoteSequence()
                        if state.loadTimeDetected and tick() >= state.loadTimeReadyAt then
                            Farm.UserWantsFarm = true
                            Farm.Enabled = true
                            state.loadTimeDetected = false
                            break
                        end
                        task.wait(0.2)
                    end
                    state.busy = false
                end
                task.wait(0.5)
            end
        end)
    end
    local function notifyLoop()
        task.spawn(function()
            while true do
                local interval = math.max(1, tonumber(Settings.NotifyMinutes) or 1) * 60
                if Settings.AutoNotify and Farm.Enabled and tick() - Farm.LastNotifyAt >= interval then
                    Farm.LastNotifyAt = tick()
                    Webhook.send("JX Farm Update", Farm.Status, { { name = "Status", value = Farm.Status, inline = true }, { name = "Cash", value = readCashAmountText(), inline = true },
                        { name = "Bank", value = readBankAmountText(), inline = true }, { name = "Earn Money", value = tostring(math.floor(Farm.EarnMoneyTotal)), inline = true }, { name =
                        "Died", value = tostring(Farm.DiedCount), inline = true }, { name = "Job ID", value = tostring(game.JobId), inline = false } })
                end
                task.wait(1)
            end
        end)
    end
    local function farmStep()
        if adminCheck() then return end
        if isDead() then
            setStatus("Dead")
            task.wait(Settings.FarmDeadWaitSec)
            return
        end
        if Settings.AutoMoney then clearNearbyCashNoMove() end
        if Settings.AutoAllowance then claimAllowance() end
        if tryDeposit(false) then
            task.wait(Settings.FarmBetweenTargetsSec)
            return
        end
        setStatus("Finding Target")
        local model, part = chooseTarget()
        if not model or not part then
            setStatus("Idle (all opened)")
            task.wait(Settings.FarmIdleWaitSec)
            return
        end
        processTarget(model, part)
        task.wait(Settings.FarmBetweenTargetsSec)
    end
    function Farm.start()
        if Farm.Enabled and Farm.Busy then return end
        Farm.Enabled = true
        Farm.UserWantsFarm = true
        Farm.Busy = true
        Farm.StartCash = readCashAmountValue()
        Farm.EarnMoneyTotal = Settings.EarnMoneyTotal
        Farm.StartedAt = tick()
        Farm.ProcessedList = {}
        Environment.JXFarmEnabled = true
        Environment.UserWantsFarm = true
        notify("Notification", "AutoFarm started", 4)
        task.spawn(function()
            while Farm.Enabled do
                local ok, err = xpcall(farmStep, debug.traceback)
                if not ok then
                    setStatus("Idle")
                    task.wait(Settings.FarmRetryWaitSec)
                end
                task.wait(Settings.FarmTickSec)
            end
            Farm.Busy = false
            setStatus("Idle")
        end)
    end
    function Farm.stop()
        Farm.Enabled = false
        Farm.UserWantsFarm = false
        Environment.JXFarmEnabled = false
        Environment.UserWantsFarm = false
        Environment.JXFarmMove = false
        setStatus("Idle")
        Settings.EarnMoneyTotal = Farm.EarnMoneyTotal
        Settings.save()
        notify("Notification", "AutoFarm stopped", 4)
    end
    local function makeRounded(object, radius)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, radius or 6)
        corner.Parent = object
    end
    local function makeLabel(parent, text, position, size)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Position = position
        label.Size = size
        label.Font = Enum.Font.Gotham
        label.TextSize = 14
        label.TextColor3 = Color3.fromRGB(235, 235, 235)
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Text = text
        label.Parent = parent
        return label
    end
    local function makeButton(parent, text, position, callback)
        local button = Instance.new("TextButton")
        button.Position = position
        button.Size = UDim2.new(0, 155, 0, 32)
        button.BackgroundColor3 = Color3.fromRGB(48, 48, 54)
        button.TextColor3 = Color3.fromRGB(245, 245, 245)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 13
        button.Text = text
        button.Parent = parent
        makeRounded(button, 6)
        button.MouseButton1Click:Connect(callback)
        return button
    end
    local function createKeyGui(onVerified)
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local previous = playerGui:FindFirstChild("KeySystemGUI")
        if previous then previous:Destroy() end
        local screen = Instance.new("ScreenGui")
        screen.Name = "KeySystemGUI"
        screen.ResetOnSpawn = false
        screen.Parent = playerGui
        local frame = Instance.new("Frame")
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, 420, 0, 275)
        frame.Position = UDim2.new(0.5, -210, 0.5, -137)
        frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        frame.BorderSizePixel = 0
        frame.Parent = screen
        makeRounded(frame, 10)
        local title = makeLabel(frame, "🔴 JX-Key System", UDim2.new(0, 18, 0, 12), UDim2.new(1, -36, 0, 32))
        title.Font = Enum.Font.GothamBold
        title.TextSize = 20
        local status = makeLabel(frame, "🌟 Welcome! Press Get Key Button To Get Key!", UDim2.new(0, 18, 0, 50), UDim2.new(1, -36, 0, 46))
        status.TextWrapped = true
        local input = Instance.new("TextBox")
        input.Position = UDim2.new(0, 18, 0, 105)
        input.Size = UDim2.new(1, -36, 0, 42)
        input.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
        input.TextColor3 = Color3.fromRGB(245, 245, 245)
        input.PlaceholderColor3 = Color3.fromRGB(140, 140, 145)
        input.PlaceholderText = "Enter your Key here..."
        input.ClearTextOnFocus = false
        input.Font = Enum.Font.Gotham
        input.TextSize = 14
        input.Parent = frame
        makeRounded(input, 6)
        local getKey = makeButton(frame, "🔑 Get Key", UDim2.new(0, 18, 0, 160), function()
            status.Text = "Requesting key link..."
            task.spawn(function()
                local ok, data = KeySystem.requestKey()
                if ok then
                    status.Text = "Key link copied to clipboard."
                else
                    status.Text = "Unable to request key: " .. tostring(data)
                end
            end)
        end)
        getKey.Size = UDim2.new(0, 120, 0, 36)
        local checkKey = makeButton(frame, "✅ Check Key", UDim2.new(0, 150, 0, 160), function()
            status.Text = "Checking key..."
            task.spawn(function()
                local ok, data = KeySystem.verifyKey(input.Text)
                if ok then
                    status.Text = "Saved key verified! Loading script..."
                    task.wait(0.5)
                    screen:Destroy()
                    onVerified()
                else
                    status.Text = tostring(data)
                end
            end)
        end)
        checkKey.Size = UDim2.new(0, 120, 0, 36)
        local discord = makeButton(frame, "💬 Discord", UDim2.new(0, 282, 0, 160), function()
            if type(Executor.setClipboard) == "function" then safeCall(Executor.setClipboard, Config.KeySystem.DiscordInvite) end
            status.Text = "Join Discord: " .. Config.KeySystem.DiscordInvite
        end)
        discord.Size = UDim2.new(0, 120, 0, 36)
        local close = makeButton(frame, "Close", UDim2.new(0, 282, 0, 213), function()
            screen:Destroy()
            notify("JX", "Key system closed.", 4)
        end)
        close.Size = UDim2.new(0, 120, 0, 34)
        local saved = KeySystem.loadSavedKey()
        if saved then
            input.Text = tostring(saved.key)
            status.Text = "📁 Saved key loaded! Click Check Key to verify."
        end
    end
    local function initializeFarm()
        Settings.load()
        syncEnvironmentSettings()
        Environment.JXFarmTempIgnoredTargets = Farm.TempIgnoredTargets
        Environment.JXFarmRunId = HttpService:GenerateGUID(false)
        Environment.UserWantsFarm = Farm.UserWantsFarm
        Environment.UserWantsInvis = Settings.HideBody
        Environment.IsInvisEnabled = InvisState.Enabled
        Environment.Invis_Toggle = Settings.HideBody
        bindAntiAFK()
        bindNoFall()
        bindAdminDetection()
        bindDeathTracking()
        bindLoadTimeDetection()
        bindCashTracking()
        ClearFarmESP()
        bindTargetTracking()
        autoRespawnLoop()
        Settings.AutoNotify = false
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(1)
            bindDeathTracking()
            bindCashTracking()
            ClearFarmESP()
            bindTargetTracking()
            if Settings.HideBody then task.defer(invisEnable) end
        end)
        RunService.Heartbeat:Connect(function() refreshInfoLabels() end)
    end
    local function start()
        KeySystem.fetchPublicConfig()
        if Config.KeySystem.Keyless then
            notify("JX", "Keyless mode enabled. Loading...", 4)
            initializeFarm()
            return
        end
        local saved = KeySystem.loadSavedKey()
        if saved then
            local ok = KeySystem.verifyKey(saved.key)
            if ok then
                notify("JX", "Saved key is valid! Loading Script...", 4)
                initializeFarm()
                return
            end
        end
        createKeyGui(initializeFarm)
    end
    local EmbeddedInitialized = false
    local function EnsureEmbeddedInitialized()
        if EmbeddedInitialized then return end
        EmbeddedInitialized = true
        initializeFarm()
    end
    return { Settings = Settings, Farm = Farm, EnsureInitialized = EnsureEmbeddedInitialized, SetSetting = function(Key, Value)
        Settings[Key] = Value
        if Key == "HideBody" then
            if Value == true then
                invisEnable()
            else
                invisDisable()
            end
        end
        syncEnvironmentSettings()
        Settings.save()
    end, StartSafe = function()
        EnsureEmbeddedInitialized()
        Settings.AutoPlay = false
        syncEnvironmentSettings()
        Settings.save()
        Farm.start()
    end, StartAlt = function()
        EnsureEmbeddedInitialized()
        Settings.AutoPlay = true
        Settings.AutoRespawn = true
        Settings.AntiAFK = true
        syncEnvironmentSettings()
        Settings.save()
        Farm.start()
    end, Stop = function()
        Farm.stop()
        ClearFarmESP()
    end, MoveToPosition = moveToPosition, TryDeposit = TryDepositAllNow, ClaimAllowance = claimAllowance, GetStatus = function() return Farm.Status end, Destroy = function()
        Farm.stop()
        ClearFarmESP()
        if InvisState.Enabled then invisDisable() end
    end }
end)()

RadiantFarmModule.EnsureInitialized()

function SafeFarmEnable()
    if SafeFarmEnabled then return end
    AltFarmEnabled = false
    SafeFarmEnabled = true
    RadiantFarmModule.StartSafe()
end

function SafeFarmDisable()
    if not SafeFarmEnabled then return end
    SafeFarmEnabled = false
    if not AltFarmEnabled then RadiantFarmModule.Stop() end
end

function AltFarmEnable()
    if AltFarmEnabled then return end
    SafeFarmEnabled = false
    AltFarmEnabled = true
    RadiantFarmModule.StartAlt()
end

function AltFarmDisable()
    if not AltFarmEnabled then return end
    AltFarmEnabled = false
    RadiantFarmModule.SetSetting("AutoPlay", false)
    if not SafeFarmEnabled then RadiantFarmModule.Stop() end
end

local function FindAllATMs()
    local Atms = {}
    for Unused, ObjectValue in ipairs(workspace:GetDescendants()) do
        if ObjectValue:IsA("BasePart") and string.lower(ObjectValue.Name) == "atm" then table.insert(Atms, ObjectValue) end
    end
    return Atms
end

local function SortATMsByDistance(Atms)
    local RootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return Atms end
    table.sort(Atms, function(FirstValue, ButtonItem) return(RootPart.Position - FirstValue.Position).Magnitude < (RootPart.Position - ButtonItem.Position).Magnitude end)
    return Atms
end

local function IsAllowanceAvailable()
    if tick() - AutoATMLastCollectTime < AutoATMInterval then return false end
    local GuiObject = LocalPlayer.PlayerGui
    if not GuiObject then return false end
    for Unused, ScreenGUI in ipairs(GuiObject:GetChildren()) do
        if ScreenGUI:IsA("ScreenGui") then
            for Unused, Frame in ipairs(ScreenGUI:GetDescendants()) do
                if Frame:IsA("TextLabel") or Frame:IsA("TextButton") or Frame:IsA("Frame") then
                    local TextValue = Frame.Text or ""
                    if TextValue:lower():find("allowance") or TextValue:lower():find("available") or TextValue:lower():find("claim") or TextValue:lower():find("collect") or TextValue:lower()
                        :find("take") then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function InteractWithATM()
    if SendKeyPress(Enum.KeyCode.E, 0.1) then return true end
    for Unused, GuiObject in ipairs(PlayerGui:GetChildren()) do
        if GuiObject:IsA("ScreenGui") then
            for Unused, Button in ipairs(GuiObject:GetDescendants()) do
                if Button:IsA("TextButton") and Button.Visible and Button.Active then
                    local Text = string.lower(Button.Text or "")
                    if string.find(Text, "claim", 1, true) or string.find(Text, "take", 1, true) or string.find(Text, "collect", 1, true) then
                        if ActivateGuiButton(Button) then return true end
                    end
                end
            end
        end
    end
    return false
end

local function AutoATMLoop()
    while AutoATMEnabled do
        if not IsAllowanceAvailable() then
            task.wait(6)
            continue
        end
        local AllATMs = FindAllATMs()
        if #AllATMs == 0 then
            task.wait(6)
            continue
        end
        local SortedATMs = SortATMsByDistance(AllATMs)
        for Unused, ATMObject in ipairs(SortedATMs) do
            if not AutoATMEnabled then break end
            local CharacterModel = LocalPlayer.Character
            if not CharacterModel then break end
            local HumanoidObject = CharacterModel:FindFirstChildOfClass("Humanoid")
            if not HumanoidObject or HumanoidObject.Health <= 0 then break end
            if RadiantFarmModule.MoveToPosition(ATMObject.Position, "Moving To ATM") then
                InteractWithATM()
                AutoATMLastCollectTime = tick()
                task.wait(1.5)
                break
            end
        end
        task.wait(45)
    end
    AutoATMCoroutine = nil
end

function AutoATMEnable()
    if AutoATMEnabled then return end
    AutoATMEnabled = true
    AutoATMLastCollectTime = 0
    if not AutoATMCoroutine then AutoATMCoroutine = task.spawn(AutoATMLoop) end
end

function AutoATMDisable()
    AutoATMEnabled = false
    if AutoATMCoroutine then
        task.cancel(AutoATMCoroutine)
        AutoATMCoroutine = nil
    end
end

local function FullBrightApply()
    local LightingObject = game:GetService("Lighting")
    if not FullBrightOriginalSettings.Ambient then
        FullBrightOriginalSettings.Ambient = LightingObject.Ambient
        FullBrightOriginalSettings.Brightness = LightingObject.Brightness
        FullBrightOriginalSettings.FogEnd = LightingObject.FogEnd
        FullBrightOriginalSettings.Effects = {}
        for Unused, EffectObject in ipairs(LightingObject:GetDescendants()) do
            if EffectObject:IsA("BloomEffect") or EffectObject:IsA("BlurEffect") or EffectObject:IsA("ColorCorrectionEffect") or EffectObject:IsA("SunRaysEffect") then
                FullBrightOriginalSettings.Effects[EffectObject] = EffectObject.Enabled
            end
        end
    end
    LightingObject.Ambient = Color3.fromRGB(255, 255, 255)
    LightingObject.Brightness = 1
    LightingObject.FogEnd = 1e10
    for Unused, EffectObject in ipairs(LightingObject:GetDescendants()) do
        if EffectObject:IsA("BloomEffect") or EffectObject:IsA("BlurEffect") or EffectObject:IsA("ColorCorrectionEffect") or EffectObject:IsA("SunRaysEffect") then
            EffectObject.Enabled = false
        end
    end
    local CharacterModel = LocalPlayer.Character
    if CharacterModel then
        local RootPart = CharacterModel:FindFirstChild("HumanoidRootPart")
        if RootPart then
            if not FullBrightLight or not FullBrightLight.Parent then
                FullBrightLight = Instance.new("PointLight")
                FullBrightLight.Brightness = 1
                FullBrightLight.Range = 60
                FullBrightLight.Parent = RootPart
            end
        end
    end
    if not FullBrightConnection then
        FullBrightConnection = LightingObject.Changed:Connect(function()
            if FullBrightEnabled then FullBrightApply() end
        end)
    end
end

local function FullBrightRestore()
    local LightingObject = game:GetService("Lighting")
    if FullBrightOriginalSettings.Ambient then
        LightingObject.Ambient = FullBrightOriginalSettings.Ambient
        LightingObject.Brightness = FullBrightOriginalSettings.Brightness
        LightingObject.FogEnd = FullBrightOriginalSettings.FogEnd
        for EffectObject, IsEnabled in pairs(FullBrightOriginalSettings.Effects) do
            if EffectObject and EffectObject.Parent then EffectObject.Enabled = IsEnabled end
        end
    end
    if FullBrightLight then
        FullBrightLight:Destroy()
        FullBrightLight = nil
    end
    if FullBrightConnection then
        FullBrightConnection:Disconnect()
        FullBrightConnection = nil
    end
end

function FullBrightEnable()
    if FullBrightEnabled then return end
    FullBrightEnabled = true
    FullBrightApply()
end

function FullBrightDisable()
    if not FullBrightEnabled then return end
    FullBrightEnabled = false
    FullBrightRestore()
end

local S = { ChinaHat = { Enabled = false, Model = nil, Motor = nil, Connection = nil, CharacterConnection = nil, Time = 0, Color = Color3.fromRGB(42, 238, 156), Transparency = 0.18, Scale =
    1.05, Height = 0.82, Rainbow = false, RainbowSpeed = 0.10, SpinSpeed = 18, Segments = 32, SurfaceBeams = {}, OutlineBeams = {}, Attachments = {}, AppearanceAccumulator = 0,
    AppearanceInterval = 1 / 60, AppearanceBatchIndex = 1, AppearanceBatchSize = 8 }, AngelWings = { Enabled = false, Model = nil, RenderConnection = nil, CharacterConnection = nil, Phase =
    0, PreviousStroke = -1, StrokeVelocity = 0, CurrentActivity = 0.62, CoreColor = Color3.fromRGB(224, 255, 240), GlowColor = Color3.fromRGB(42, 238, 156), Transparency = 0.18, Scale = 1.30,
    HeightOffset = -0.25, BackOffset = 0.68, SideOffset = 0.14, FlapSpeed = 0.90, Reactive = true, Style = "Seraph", LeftMotor = nil, RightMotor = nil, Feathers = {}, Beams = {}, Emitters =
    {}, Trails = {}, FeatherAccumulator = 0, FeatherInterval = 1 / 60, FeatherBatchIndex = 1, FeatherBatchSize = 10, CachedCharacter = nil, CachedHumanoid = nil, CachedRootPart = nil,
    EmitterAccumulator = 0, EmitterInterval = 0.10 }, AimBot = { Enabled = false, Smoothness = 0.1, FOV = 100, ShowFOV = true, FOVColor = Color3.fromRGB(255, 255, 255), FOVTransparency = 0.5,
    FOVGlow = false, FOVGlowColor = Color3.fromRGB(54, 218, 145), FOVGlowTransparency = 0.18, FOVGlowThickness = 8, WallCheck = true, DownedCheck = true, Prediction = 100, TargetPart =
    "Head", Resolver = true, ResolverMode = "Adaptive", ResolverStrength = 1, ResolverMaxSpeed = 190, ResolverDesyncThreshold = 18,
    Connection = nil, Target = nil, FOVCircle = nil, FOVGlowCircle = nil, FOVUpdateConnection = nil, FOVPosition = Vector2.new(500, 500), Sticky = true }, Blur = { Enabled = false,
    BlurEffect = nil, Connection = nil, LastLookVector = nil, CurrentLookVector = nil, RotationSpeed = 0 }, Freecam = { Enabled = false, Speed = 50, Sensitivity = 0.18, Acceleration = 14,
    BoostMultiplier = 2.5, Connection = nil, InputConnections = {}, KeysDown = {}, Rotating = false, OnMobile = not UserInputService.KeyboardEnabled, MouseDelta = Vector2.new(0, 0),
    Position = nil, Yaw = 0, Pitch = 0, Velocity = Vector3.new(0, 0, 0), SavedCameraType = nil, SavedCameraSubject = nil, SavedFieldOfView = nil, SavedMouseBehavior = nil,
    SavedMouseIconEnabled = nil, SavedRootAnchored = nil, SavedRootPart = nil }, NoRecoil = { Enabled = false, Connections = {}, WeaponCache = setmetatable({}, { __mode = "v" }),
    OriginalValues = setmetatable({}, { __mode = "k" }), RCLConnections = {}, RCLLookup = setmetatable({}, { __mode = "k" }), CacheReady = false, LastScan = 0, ScanCooldown = 2,
    Scanning = false, Settings = { GunMods = { NoRecoil = true, Spread = true, SpreadAmount = 0, NoCrosshair = true, RapidFire = false, RapidFireDelay = 0.10 } } }, CharacterAddedConnection = nil }

function DestroyChinaHat()
    if S.ChinaHat.Motor and S.ChinaHat.Motor.Parent then S.ChinaHat.Motor:Destroy() end
    if S.ChinaHat.Model then S.ChinaHat.Model:Destroy() end
    S.ChinaHat.Model = nil
    S.ChinaHat.Motor = nil
    RadiantReleaseBuffer(S.ChinaHat.SurfaceBeams)
    RadiantReleaseBuffer(S.ChinaHat.OutlineBeams)
    RadiantReleaseBuffer(S.ChinaHat.Attachments)
    S.ChinaHat.SurfaceBeams = {}
    S.ChinaHat.OutlineBeams = {}
    S.ChinaHat.Attachments = {}
    S.ChinaHat.AppearanceAccumulator = 0
    S.ChinaHat.AppearanceBatchIndex = 1
end

function GetChinaHatColor(Index, Offset)
    if not S.ChinaHat.Rainbow then return S.ChinaHat.Color end
    local Segments = math.max(S.ChinaHat.Segments, 1)
    local Hue = (S.ChinaHat.Time * S.ChinaHat.RainbowSpeed + (Index - 1) / Segments + (Offset or 0)) % 1
    return Color3.fromHSV(Hue, 0.82, 1)
end

function CreateChinaHatAttachment(Parent, Name, Position)
    local Attachment = Instance.new("Attachment")
    Attachment.Name = Name
    Attachment.Position = Position
    Attachment.Parent = Parent
    S.ChinaHat.Attachments[#S.ChinaHat.Attachments + 1] = Attachment
    return Attachment
end

function CreateChinaHatBeam(Parent, Name, Attachment0, Attachment1, Width0, Width1, Transparency, ZOffset)
    local Beam = Instance.new("Beam")
    Beam.Name = Name
    Beam.Attachment0 = Attachment0
    Beam.Attachment1 = Attachment1
    Beam.FaceCamera = true
    Beam.Segments = 1
    Beam.Width0 = Width0
    Beam.Width1 = Width1
    Beam.Transparency = Transparency
    Beam.LightEmission = 0.82
    Beam.LightInfluence = 0
    Beam.Brightness = 1
    Beam.ZOffset = ZOffset
    Beam.Parent = Parent
    return Beam
end

function UpdateChinaHatAppearance(UseBatch)
    local Transparency = AngelWingClamp(S.ChinaHat.Transparency, 0, 0.94)
    local SurfaceBeams = S.ChinaHat.SurfaceBeams
    local OutlineBeams = S.ChinaHat.OutlineBeams
    local SurfaceCount = #SurfaceBeams
    local OutlineCount = #OutlineBeams
    local TotalCount = SurfaceCount + OutlineCount
    local StartIndex = UseBatch and S.ChinaHat.AppearanceBatchIndex or 1
    local EndIndex = UseBatch and math.min(StartIndex + S.ChinaHat.AppearanceBatchSize - 1, TotalCount) or TotalCount
    for GlobalIndex = StartIndex, math.min(EndIndex, SurfaceCount) do
        local Index = GlobalIndex
        local Data = SurfaceBeams[Index]
        local StartColor = GetChinaHatColor(Index, 0)
        local EndColor = GetChinaHatColor(Index + 1, 0)
        Data.Beam.Color = ColorSequence.new(StartColor, EndColor)
        Data.Beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, AngelWingClamp(Transparency + 0.26, 0, 0.97)), NumberSequenceKeypoint.new(0.72,
            AngelWingClamp(Transparency + 0.20, 0, 0.96)), NumberSequenceKeypoint.new(1, AngelWingClamp(Transparency + 0.12, 0, 0.95)) })
    end
    local OutlineStart = math.max(StartIndex, SurfaceCount + 1)
    for GlobalIndex = OutlineStart, EndIndex do
        local Index = GlobalIndex - SurfaceCount
        local Data = OutlineBeams[Index]
        if not Data then break end
        local StartColor = GetChinaHatColor(Data.ColorIndex or Index, Data.HueOffset or 0)
        local EndColor = GetChinaHatColor((Data.ColorIndex or Index) + 1, Data.HueOffset or 0)
        Data.Beam.Color = ColorSequence.new(StartColor, EndColor)
        Data.Beam.Transparency = NumberSequence.new(AngelWingClamp(Transparency + (Data.Faint and 0.22 or 0), 0, 0.96))
    end
    if UseBatch and TotalCount > 0 then
        S.ChinaHat.AppearanceBatchIndex = EndIndex >= TotalCount and 1 or EndIndex + 1
    else
        S.ChinaHat.AppearanceBatchIndex = 1
    end
end

function CreateChinaHat(Character)
    DestroyChinaHat()
    Character = Character or LocalPlayer.Character
    if not Character then return end
    local Head = Character:FindFirstChild("Head")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Head or not Humanoid or Humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end
    local Model = Instance.new("Model")
    Model.Name = "MinecraftChinaHat"
    Model.Parent = Character
    local Pivot = Instance.new("Part")
    Pivot.Name = "ChinaHatPivot"
    Pivot.Size = Vector3.new(0.1, 0.1, 0.1)
    Pivot.Transparency = 1
    Pivot.Anchored = false
    Pivot.CanCollide = false
    Pivot.CanTouch = false
    Pivot.CanQuery = false
    Pivot.Massless = true
    Pivot.CastShadow = false
    Pivot.CFrame = Head.CFrame * CFrame.new(0, S.ChinaHat.Height, 0)
    Pivot.Parent = Model
    local Motor = Instance.new("Motor6D")
    Motor.Name = "ChinaHatMotor"
    Motor.Part0 = Head
    Motor.Part1 = Pivot
    Motor.C0 = CFrame.new(0, S.ChinaHat.Height, 0)
    Motor.C1 = CFrame.new()
    Motor.Parent = Head
    local Segments = S.ChinaHat.Segments
    local Scale = S.ChinaHat.Scale
    local Radius = 1.18 * Scale
    local RimHeight = -0.28 * Scale
    local ApexHeight = 0.48 * Scale
    local InnerRadius = Radius * 0.54
    local InnerHeight = RimHeight + (ApexHeight - RimHeight) * 0.46
    local ArcWidth = (Radius * math.pi * 2) / Segments
    local Apex = CreateChinaHatAttachment(Pivot, "HatApex", Vector3.new(0, ApexHeight, 0))
    local Rim = {}
    local Inner = {}
    for Index = 1, Segments do
        local Angle = (Index - 1) / Segments * math.pi * 2
        local X = math.cos(Angle)
        local Z = math.sin(Angle)
        Rim[Index] = CreateChinaHatAttachment(Pivot, "HatRim_" .. Index, Vector3.new(X * Radius, RimHeight, Z * Radius))
        Inner[Index] = CreateChinaHatAttachment(Pivot, "HatInner_" .. Index, Vector3.new(X * InnerRadius, InnerHeight, Z * InnerRadius))
    end
    for Index = 1, Segments do
        local NextIndex = Index % Segments + 1
        local Surface = CreateChinaHatBeam(Pivot, "HatSurface_" .. Index, Apex, Rim[Index], 0.018 * Scale, ArcWidth * 1.08, NumberSequence.new(0.42), -0.02)
        S.ChinaHat.SurfaceBeams[#S.ChinaHat.SurfaceBeams + 1] = { Beam = Surface }
        local RimBeam = CreateChinaHatBeam(Pivot, "HatRimLine_" .. Index, Rim[Index], Rim[NextIndex], 0.038 * Scale, 0.038 * Scale, NumberSequence.new(0.10), 0.03)
        S.ChinaHat.OutlineBeams[#S.ChinaHat.OutlineBeams + 1] = { Beam = RimBeam, ColorIndex = Index, HueOffset = 0, Faint = false }
        local InnerBeam = CreateChinaHatBeam(Pivot, "HatInnerLine_" .. Index, Inner[Index], Inner[NextIndex], 0.024 * Scale, 0.024 * Scale, NumberSequence.new(0.32), 0.02)
        S.ChinaHat.OutlineBeams[#S.ChinaHat.OutlineBeams + 1] = { Beam = InnerBeam, ColorIndex = Index, HueOffset = 0.04, Faint = true }
        if Index % 4 == 1 then
            local Spoke = CreateChinaHatBeam(Pivot, "HatSpoke_" .. Index, Apex, Rim[Index], 0.018 * Scale, 0.018 * Scale, NumberSequence.new(0.38), 0.04)
            S.ChinaHat.OutlineBeams[#S.ChinaHat.OutlineBeams + 1] = { Beam = Spoke, ColorIndex = Index, HueOffset = 0.02, Faint = true }
        end
    end
    S.ChinaHat.Model = Model
    S.ChinaHat.Motor = Motor
    S.ChinaHat.Time = 0
    S.ChinaHat.AppearanceAccumulator = 0
    UpdateChinaHatAppearance()
end

function UpdateChinaHat(DeltaTime)
    if not S.ChinaHat.Enabled then return end
    local Character = LocalPlayer.Character
    if not Character then
        DestroyChinaHat()
        return
    end
    if not S.ChinaHat.Model or S.ChinaHat.Model.Parent ~= Character then
        CreateChinaHat(Character)
        return
    end
    local Motor = S.ChinaHat.Motor
    if not Motor then return end
    DeltaTime = AngelWingClamp(tonumber(DeltaTime) or 0.016, 0.001, 0.05)
    S.ChinaHat.Time = S.ChinaHat.Time + DeltaTime
    local Rotation = math.rad(S.ChinaHat.Time * S.ChinaHat.SpinSpeed)
    local Bob = math.sin(S.ChinaHat.Time * 2) * 0.012
    local Target = CFrame.new(0, Bob, 0) * CFrame.Angles(0, Rotation, 0)
    Motor.Transform = Motor.Transform:Lerp(Target, AngelWingExpAlpha(10, DeltaTime))
    if S.ChinaHat.Rainbow then
        S.ChinaHat.AppearanceAccumulator = S.ChinaHat.AppearanceAccumulator + DeltaTime
        if S.ChinaHat.AppearanceAccumulator >= S.ChinaHat.AppearanceInterval then
            S.ChinaHat.AppearanceAccumulator = S.ChinaHat.AppearanceAccumulator % S.ChinaHat.AppearanceInterval
            UpdateChinaHatAppearance(true)
        end
    else
        S.ChinaHat.AppearanceAccumulator = 0
    end
end

function SetupChinaHat()
    if S.ChinaHat.Connection then S.ChinaHat.Connection:Disconnect() end
    S.ChinaHat.Connection = RunService.Heartbeat:Connect(UpdateChinaHat)
    if S.ChinaHat.CharacterConnection then S.ChinaHat.CharacterConnection:Disconnect() end
    S.ChinaHat.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function(Character)
        task.spawn(function()
            task.wait(0.55)
            if S.ChinaHat.Enabled then CreateChinaHat(Character) end
        end)
    end)
    CreateChinaHat(LocalPlayer.Character)
end

function RebuildChinaHat()
    if not S.ChinaHat.Enabled then return end
    CreateChinaHat(LocalPlayer.Character)
end

function ToggleChinaHat(State)
    S.ChinaHat.Enabled = State
    if State then
        SetupChinaHat()
    else
        if S.ChinaHat.Connection then
            S.ChinaHat.Connection:Disconnect()
            S.ChinaHat.Connection = nil
        end
        if S.ChinaHat.CharacterConnection then
            S.ChinaHat.CharacterConnection:Disconnect()
            S.ChinaHat.CharacterConnection = nil
        end
        DestroyChinaHat()
    end
end

function AngelWingClamp(Value, Minimum, Maximum) return math.max(Minimum, math.min(Maximum, Value)) end

function AngelWingLerp(A, B, Alpha) return A + (B - A) * Alpha end

function AngelWingSmoothStep(Value)
    Value = AngelWingClamp(Value, 0, 1)
    return Value * Value * (3 - 2 * Value)
end

function AngelWingExpAlpha(Speed, DeltaTime) return 1 - math.exp(-Speed * DeltaTime) end

function AngelWingFrame(Position, Tangent, Normal)
    local Axis = Tangent.Magnitude > 0.001 and Tangent.Unit or Vector3.new(1, 0, 0)
    local Up = Normal.Magnitude > 0.001 and Normal.Unit or Vector3.new(0, 1, 0)
    if math.abs(Axis:Dot(Up)) > 0.94 then Up = Vector3.new(0, 0, 1) end
    local Back = Axis:Cross(Up)
    if Back.Magnitude < 0.001 then
        Back = Vector3.new(0, 0, 1)
    else
        Back = Back.Unit
    end
    Up = Back:Cross(Axis)
    if Up.Magnitude < 0.001 then
        Up = Vector3.new(0, 1, 0)
    else
        Up = Up.Unit
    end
    return CFrame.fromMatrix(Position, Axis, Up, Back)
end

function DestroyAngelWingModel()
    if S.AngelWings.LeftMotor and S.AngelWings.LeftMotor.Parent then S.AngelWings.LeftMotor:Destroy() end
    if S.AngelWings.RightMotor and S.AngelWings.RightMotor.Parent then S.AngelWings.RightMotor:Destroy() end
    if S.AngelWings.Model then S.AngelWings.Model:Destroy() end
    S.AngelWings.Model = nil
    S.AngelWings.LeftMotor = nil
    S.AngelWings.RightMotor = nil
    RadiantReleaseBuffer(S.AngelWings.Feathers)
    RadiantReleaseBuffer(S.AngelWings.Beams)
    RadiantReleaseBuffer(S.AngelWings.Emitters)
    RadiantReleaseBuffer(S.AngelWings.Trails)
    S.AngelWings.Feathers = {}
    S.AngelWings.Beams = {}
    S.AngelWings.Emitters = {}
    S.AngelWings.Trails = {}
    S.AngelWings.FeatherAccumulator = 0
    S.AngelWings.FeatherBatchIndex = 1
    S.AngelWings.EmitterAccumulator = 0
    S.AngelWings.CachedCharacter = nil
    S.AngelWings.CachedHumanoid = nil
    S.AngelWings.CachedRootPart = nil
end

function GetAngelWingStyleScale()
    if S.AngelWings.Style == "Classic" then return 0.92 end
    if S.AngelWings.Style == "Compact" then return 0.76 end
    return 1.08
end

function GetAngelWingCounts()
    if S.AngelWings.Style == "Compact" then return 8, 6, 5 end
    if S.AngelWings.Style == "Classic" then return 10, 8, 6 end
    return 12, 9, 7
end

function GetAngelWingStroke(Phase)
    local Cycle = (Phase / (math.pi * 2)) % 1
    local Stroke
    local Downstroke
    if Cycle < 0.10 then
        local T = Cycle / 0.10
        Stroke = AngelWingLerp(-1, -0.96, AngelWingSmoothStep(T))
        Downstroke = false
    elseif Cycle < 0.40 then
        local T = (Cycle - 0.10) / 0.30
        Stroke = AngelWingLerp(-0.96, 1, 1 - (1 - T) ^ 3)
        Downstroke = true
    elseif Cycle < 0.48 then
        local T = (Cycle - 0.40) / 0.08
        Stroke = AngelWingLerp(1, 0.94, AngelWingSmoothStep(T))
        Downstroke = true
    else
        local T = (Cycle - 0.48) / 0.52
        Stroke = AngelWingLerp(0.94, -1, AngelWingSmoothStep(T))
        Downstroke = false
    end
    return Stroke, Downstroke, Cycle
end

function CreateAngelWingPivot(Torso, Model, Side)
    local Pivot = Instance.new("Part")
    Pivot.Name = Side < 0 and "LeftWingPivot" or "RightWingPivot"
    Pivot.Size = Vector3.new(0.12, 0.12, 0.12)
    Pivot.Transparency = 1
    Pivot.Anchored = false
    Pivot.CanCollide = false
    Pivot.CanTouch = false
    Pivot.CanQuery = false
    Pivot.Massless = true
    Pivot.CastShadow = false
    local Offset = Vector3.new(Side * S.AngelWings.SideOffset, S.AngelWings.HeightOffset, S.AngelWings.BackOffset)
    Pivot.CFrame = Torso.CFrame * CFrame.new(Offset)
    Pivot.Parent = Model
    local Motor = Instance.new("Motor6D")
    Motor.Name = Side < 0 and "LeftWingMotor" or "RightWingMotor"
    Motor.Part0 = Torso
    Motor.Part1 = Pivot
    Motor.C0 = CFrame.new(Offset)
    Motor.C1 = CFrame.new()
    Motor.Parent = Torso
    return Pivot, Motor
end

function CreateAngelWingAttachment(Parent, Name, Position, Tangent, Normal)
    local Attachment = Instance.new("Attachment")
    Attachment.Name = Name
    Attachment.CFrame = AngelWingFrame(Position, Tangent, Normal)
    Attachment.Parent = Parent
    return Attachment
end

function CreateAngelWingBeam(Parent, Name, Attachment0, Attachment1, Width0, Width1, Curve0, Curve1, FaceCamera, Color, Transparency, Brightness, ZOffset)
    local Beam = Instance.new("Beam")
    Beam.Name = Name
    Beam.Attachment0 = Attachment0
    Beam.Attachment1 = Attachment1
    Beam.FaceCamera = FaceCamera
    Beam.Segments = 12
    Beam.Width0 = Width0
    Beam.Width1 = Width1
    Beam.CurveSize0 = Curve0
    Beam.CurveSize1 = Curve1
    Beam.Color = Color
    Beam.Transparency = Transparency
    Beam.LightEmission = 0.82
    Beam.LightInfluence = 0.06
    Beam.Brightness = Brightness
    Beam.ZOffset = ZOffset
    Beam.Parent = Parent
    S.AngelWings.Beams[#S.AngelWings.Beams + 1] = Beam
    return Beam
end

function CreateAngelWingFeather(Pivot, Side, Layer, Index, Count, RootPosition, TipPosition, Width, Curve, Flutter, Weight)
    local Progress = Count > 1 and(Index - 1) / (Count - 1) or 0
    local Direction = TipPosition - RootPosition
    local MainNormal = Vector3.new(0, 1, Side * 0.24)
    local CrossNormal = Direction:Cross(MainNormal)
    if CrossNormal.Magnitude < 0.001 then
        CrossNormal = Vector3.new(0, 0, 1)
    else
        CrossNormal = CrossNormal.Unit
    end
    local RootMain = CreateAngelWingAttachment(Pivot, "RootMain_" .. Layer .. "_" .. Index, RootPosition, Direction + Vector3.new(0, Curve * 0.52, 0), MainNormal)
    local TipMain = CreateAngelWingAttachment(Pivot, "TipMain_" .. Layer .. "_" .. Index, TipPosition, Direction + Vector3.new(0, -Curve * 0.18, Side * 0.12), MainNormal)
    local RootCross = CreateAngelWingAttachment(Pivot, "RootCross_" .. Layer .. "_" .. Index, RootPosition, Direction + Vector3.new(0, Curve * 0.52, 0), CrossNormal)
    local TipCross = CreateAngelWingAttachment(Pivot, "TipCross_" .. Layer .. "_" .. Index, TipPosition, Direction + Vector3.new(0, -Curve * 0.18, Side * 0.12), CrossNormal)
    local MainBeam = CreateAngelWingBeam(Pivot, "Feather_" .. Layer .. "_" .. Index, RootMain, TipMain, Width, Width * 0.012, Curve, Curve * 0.58, false,
        ColorSequence.new({ ColorSequenceKeypoint.new(0, S.AngelWings.CoreColor), ColorSequenceKeypoint.new(0.76, S.AngelWings.CoreColor), ColorSequenceKeypoint.new(1,
        S.AngelWings.GlowColor) }), NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.16), NumberSequenceKeypoint.new(0.74, 0.30), NumberSequenceKeypoint.new(1, 1) }), 0.92, 0.015)
    local VolumeBeam = CreateAngelWingBeam(Pivot, "Volume_" .. Layer .. "_" .. Index, RootCross, TipCross, Width * 0.22, Width * 0.005, Curve * 0.94, Curve * 0.52, false,
        ColorSequence.new(S.AngelWings.GlowColor, S.AngelWings.CoreColor), NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.48), NumberSequenceKeypoint.new(0.78, 0.68),
        NumberSequenceKeypoint.new(1, 1) }), 0.72, 0)
    local GlowBeam = CreateAngelWingBeam(Pivot, "Glow_" .. Layer .. "_" .. Index, RootMain, TipMain, Width * 1.22, Width * 0.02, Curve, Curve * 0.58, true,
        ColorSequence.new({ ColorSequenceKeypoint.new(0, S.AngelWings.GlowColor), ColorSequenceKeypoint.new(0.56, S.AngelWings.CoreColor), ColorSequenceKeypoint.new(1,
        S.AngelWings.GlowColor) }), NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(0.70, 0.88), NumberSequenceKeypoint.new(1, 1) }), 0.68, -0.02)
    S.AngelWings.Feathers[#S.AngelWings.Feathers + 1] = { Side = Side, Layer = Layer, Index = Index, Count = Count, Progress = Progress, RootPosition = RootPosition, TipPosition =
        TipPosition, Curve = Curve, Flutter = Flutter, Weight = Weight, Offset = Index * 0.52 + (Layer == "Primary" and 0 or Layer == "Secondary" and 1.8 or 3.1), RootMain = RootMain,
        TipMain = TipMain, RootCross = RootCross, TipCross = TipCross, MainBeam = MainBeam, VolumeBeam = VolumeBeam, GlowBeam = GlowBeam }
end

function CreateAngelWingSide(Pivot, Side, Scale)
    local PrimaryCount, SecondaryCount, CovertCount = GetAngelWingCounts()
    for Index = 1, PrimaryCount do
        local T = PrimaryCount > 1 and(Index - 1) / (PrimaryCount - 1) or 0
        CreateAngelWingFeather(Pivot, Side, "Primary", Index, PrimaryCount, Vector3.new(Side * (0.04 + T * 1.82) * Scale, (0.06 - T * 0.58) * Scale, (0.04 + T * 0.18) * Scale),
            Vector3.new(Side * (3.10 + T * 3.18) * Scale, (0.28 - T * 3.34) * Scale, (0.38 + T * 0.84) * Scale), (0.54 - T * 0.12) * Scale, (1.02 + T * 0.54) * Scale, (0.13 + T * 0.11)
            * Scale, 1)
    end
    for Index = 1, SecondaryCount do
        local T = SecondaryCount > 1 and(Index - 1) / (SecondaryCount - 1) or 0
        CreateAngelWingFeather(Pivot, Side, "Secondary", Index, SecondaryCount, Vector3.new(Side * (0.02 + T * 1.42) * Scale, (0.34 + T * 0.02) * Scale, (0.02 + T * 0.12) * Scale),
            Vector3.new(Side * (2.48 + T * 2.82) * Scale, (1.74 - T * 1.64) * Scale, (0.24 + T * 0.64) * Scale), (0.60 - T * 0.11) * Scale, (1.08 + T * 0.34) * Scale, (0.10 + T * 0.07)
            * Scale, 0.72)
    end
    for Index = 1, CovertCount do
        local T = CovertCount > 1 and(Index - 1) / (CovertCount - 1) or 0
        CreateAngelWingFeather(Pivot, Side, "Covert", Index, CovertCount, Vector3.new(Side * (0.01 + T * 0.94) * Scale, (0.60 + T * 0.08) * Scale, (0.01 + T * 0.08) * Scale),
            Vector3.new(Side * (1.68 + T * 2.12) * Scale, (2.28 - T * 0.92) * Scale, (0.14 + T * 0.46) * Scale), (0.66 - T * 0.14) * Scale, (0.94 + T * 0.26) * Scale, (0.07 + T * 0.05)
            * Scale, 0.46)
    end
end

function CreateAngelWingParticles(Pivot)
    local Aura = Instance.new("Attachment")
    Aura.Position = Vector3.new(0, 0.30, 0.06)
    Aura.Parent = Pivot
    local Emitter = Instance.new("ParticleEmitter")
    Emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    Emitter.Color = ColorSequence.new(S.AngelWings.CoreColor, S.AngelWings.GlowColor)
    Emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.48), NumberSequenceKeypoint.new(0.66, 0.76), NumberSequenceKeypoint.new(1, 1) })
    Emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.06), NumberSequenceKeypoint.new(0.42, 0.14), NumberSequenceKeypoint.new(1, 0) })
    Emitter.Lifetime = NumberRange.new(0.70, 1.20)
    Emitter.Rate = 4
    Emitter.Speed = NumberRange.new(0.12, 0.46)
    Emitter.SpreadAngle = Vector2.new(100, 100)
    Emitter.Rotation = NumberRange.new(0, 360)
    Emitter.RotSpeed = NumberRange.new(-50, 50)
    Emitter.Drag = 2
    Emitter.Acceleration = Vector3.new(0, 0.42, 0)
    Emitter.VelocityInheritance = 0.18
    Emitter.LightEmission = 0.86
    Emitter.LightInfluence = 0
    Emitter.Brightness = 0.9
    Emitter.Parent = Aura
    S.AngelWings.Emitters[#S.AngelWings.Emitters + 1] = Emitter
end

function UpdateAngelWingAppearance()
    local Transparency = AngelWingClamp(S.AngelWings.Transparency, 0, 0.92)
    for Unused, Beam in ipairs(S.AngelWings.Beams) do
        if Beam.Name:find("Glow_") then
            Beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, S.AngelWings.GlowColor), ColorSequenceKeypoint.new(0.56, S.AngelWings.CoreColor), ColorSequenceKeypoint.new(1,
                S.AngelWings.GlowColor) })
            Beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, AngelWingClamp(Transparency + 0.55, 0, 0.96)), NumberSequenceKeypoint.new(0.70,
                AngelWingClamp(Transparency + 0.68, 0, 0.98)), NumberSequenceKeypoint.new(1, 1) })
        elseif Beam.Name:find("Volume_") then
            Beam.Color = ColorSequence.new(S.AngelWings.GlowColor, S.AngelWings.CoreColor)
            Beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, AngelWingClamp(Transparency + 0.28, 0, 0.96)), NumberSequenceKeypoint.new(0.78,
                AngelWingClamp(Transparency + 0.46, 0, 0.98)), NumberSequenceKeypoint.new(1, 1) })
        else
            Beam.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, S.AngelWings.CoreColor), ColorSequenceKeypoint.new(0.76, S.AngelWings.CoreColor), ColorSequenceKeypoint.new(1,
                S.AngelWings.GlowColor) })
            Beam.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, Transparency), NumberSequenceKeypoint.new(0.74, AngelWingClamp(Transparency + 0.14, 0, 0.96)),
                NumberSequenceKeypoint.new(1, 1) })
        end
    end
    for Unused, Emitter in ipairs(S.AngelWings.Emitters) do
        Emitter.Color = ColorSequence.new(S.AngelWings.CoreColor, S.AngelWings.GlowColor)
        Emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, AngelWingClamp(Transparency + 0.30, 0, 0.92)), NumberSequenceKeypoint.new(0.66,
            AngelWingClamp(Transparency + 0.56, 0, 0.98)), NumberSequenceKeypoint.new(1, 1) })
    end
end

function CreateAngelWings(Character)
    DestroyAngelWingModel()
    Character = Character or LocalPlayer.Character
    if not Character then return end
    local Torso = Character:FindFirstChild("Torso")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Torso or not Humanoid or Humanoid.RigType ~= Enum.HumanoidRigType.R6 then return end
    local Model = Instance.new("Model")
    Model.Name = "RadiantCosmeticWings"
    Model.Parent = Character
    local LeftPivot, LeftMotor = CreateAngelWingPivot(Torso, Model, -1)
    local RightPivot, RightMotor = CreateAngelWingPivot(Torso, Model, 1)
    local Scale = S.AngelWings.Scale * GetAngelWingStyleScale()
    CreateAngelWingSide(LeftPivot, -1, Scale)
    CreateAngelWingSide(RightPivot, 1, Scale)
    CreateAngelWingParticles(LeftPivot)
    CreateAngelWingParticles(RightPivot)
    S.AngelWings.Model = Model
    S.AngelWings.LeftMotor = LeftMotor
    S.AngelWings.RightMotor = RightMotor
    S.AngelWings.Phase = 0
    S.AngelWings.PreviousStroke = -1
    S.AngelWings.StrokeVelocity = 0
    S.AngelWings.CurrentActivity = 0.62
    S.AngelWings.FeatherAccumulator = 0
    S.AngelWings.FeatherBatchIndex = 1
    S.AngelWings.EmitterAccumulator = 0
    S.AngelWings.CachedCharacter = Character
    S.AngelWings.CachedHumanoid = Humanoid
    S.AngelWings.CachedRootPart = Character:FindFirstChild("HumanoidRootPart")
    UpdateAngelWingAppearance()
end

function UpdateAngelWingFeathers(Phase, Activity)
    local Feathers = S.AngelWings.Feathers
    local FeatherCount = #Feathers
    if FeatherCount == 0 then return end
    local StartIndex = S.AngelWings.FeatherBatchIndex
    local EndIndex = math.min(StartIndex + S.AngelWings.FeatherBatchSize - 1, FeatherCount)
    for Index = StartIndex, EndIndex do
        local Feather = Feathers[Index]
        local Delay = Feather.Progress * 0.34 + Feather.Weight * 0.08
        local DelayedStroke = GetAngelWingStroke(Phase - Delay)
        local Fold = (1 - DelayedStroke) * 0.5
        local FlutterWave = math.sin(Phase * 1.52 + Feather.Offset)
        local FineWave = math.sin(Phase * 2.34 + Feather.Offset * 1.47)
        local Tip = Feather.TipPosition
        local FoldDistance = Fold * (0.24 + Feather.Progress * 0.82) * Feather.Weight
        Tip = Vector3.new(Tip.X * (1 - FoldDistance * 0.11), Tip.Y + FoldDistance * 0.48, Tip.Z - DelayedStroke * (0.24 + Feather.Progress * 0.58) * Feather.Weight)
        Tip = Tip + Vector3.new(0, FlutterWave * Feather.Flutter * (0.58 + Activity * 0.42), FineWave * Feather.Flutter * 0.38)
        local Direction = Tip - Feather.RootPosition
        local MainNormal = Vector3.new(0, 1, Feather.Side * (0.24 + FineWave * 0.05))
        local CrossNormal = Direction:Cross(MainNormal)
        if CrossNormal.Magnitude < 0.001 then
            CrossNormal = Vector3.new(0, 0, 1)
        else
            CrossNormal = CrossNormal.Unit
        end
        Feather.TipMain.CFrame = AngelWingFrame(Tip, Direction + Vector3.new(0, -Feather.Curve * 0.18, Feather.Side * FlutterWave * Feather.Flutter * 0.18), MainNormal)
        Feather.TipCross.CFrame = AngelWingFrame(Tip, Direction + Vector3.new(0, -Feather.Curve * 0.18, Feather.Side * FlutterWave * Feather.Flutter * 0.18), CrossNormal)
        local CurveScale = AngelWingClamp(1 + DelayedStroke * 0.10 * Feather.Weight + FineWave * 0.025, 0.76, 1.28)
        local Curve0 = Feather.Curve * CurveScale
        local Curve1 = Feather.Curve * 0.58 * AngelWingClamp(1 - DelayedStroke * 0.06 * Feather.Weight, 0.76, 1.24)
        Feather.MainBeam.CurveSize0 = Curve0
        Feather.MainBeam.CurveSize1 = Curve1
        Feather.VolumeBeam.CurveSize0 = Curve0 * 0.94
        Feather.VolumeBeam.CurveSize1 = Curve1 * 0.90
        Feather.GlowBeam.CurveSize0 = Curve0
        Feather.GlowBeam.CurveSize1 = Curve1
    end
    S.AngelWings.FeatherBatchIndex = EndIndex >= FeatherCount and 1 or EndIndex + 1
end

function UpdateAngelWings(DeltaTime)
    if not S.AngelWings.Enabled then return end
    local Character = LocalPlayer.Character
    if not Character then
        DestroyAngelWingModel()
        return
    end
    if not S.AngelWings.Model or S.AngelWings.Model.Parent ~= Character then
        CreateAngelWings(Character)
        return
    end
    local Humanoid = S.AngelWings.CachedHumanoid
    local RootPart = S.AngelWings.CachedRootPart
    if S.AngelWings.CachedCharacter ~= Character or not Humanoid or Humanoid.Parent ~= Character or not RootPart or RootPart.Parent ~= Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart")
        S.AngelWings.CachedCharacter = Character
        S.AngelWings.CachedHumanoid = Humanoid
        S.AngelWings.CachedRootPart = RootPart
    end
    local LeftMotor = S.AngelWings.LeftMotor
    local RightMotor = S.AngelWings.RightMotor
    if not Humanoid or not RootPart or not LeftMotor or not RightMotor then return end
    DeltaTime = AngelWingClamp(tonumber(DeltaTime) or 0.016, 0.001, 0.05)
    local Movement = Humanoid.MoveDirection.Magnitude
    local State = Humanoid:GetState()
    local Airborne = State == Enum.HumanoidStateType.Jumping or State == Enum.HumanoidStateType.Freefall or State == Enum.HumanoidStateType.FallingDown
    local TargetActivity = 0.62
    if S.AngelWings.Reactive then TargetActivity = 0.62 + Movement * 0.18 + (Airborne and 0.30 or 0) end
    S.AngelWings.CurrentActivity = AngelWingLerp(S.AngelWings.CurrentActivity, TargetActivity, AngelWingExpAlpha(4.8, DeltaTime))
    local Activity = S.AngelWings.CurrentActivity
    S.AngelWings.Phase = S.AngelWings.Phase + DeltaTime * S.AngelWings.FlapSpeed * (0.72 + Activity * 0.42) * math.pi * 2
    local Phase = S.AngelWings.Phase
    local Stroke, Downstroke, Cycle = GetAngelWingStroke(Phase)
    local RawVelocity = (Stroke - S.AngelWings.PreviousStroke) / DeltaTime
    S.AngelWings.PreviousStroke = Stroke
    S.AngelWings.StrokeVelocity = AngelWingLerp(S.AngelWings.StrokeVelocity, AngelWingClamp(RawVelocity, -20, 20), AngelWingExpAlpha(13, DeltaTime))
    local StrokeVelocity = S.AngelWings.StrokeVelocity
    local Strength = 56 * Activity
    local Roll = Stroke * Strength
    local Pitch = -8 + (Downstroke and -7 or 5) * Activity + math.sin(Cycle * math.pi * 2) * 2
    local Sweep = -Stroke * 14 * Activity
    local AirSweep = AngelWingClamp(-RootPart.AssemblyLinearVelocity.Y * 0.08, -7, 9)
    local LeftTarget = CFrame.Angles(math.rad(Pitch + AirSweep * 0.14), math.rad(-12 + Sweep - AirSweep * 0.26 - StrokeVelocity * 0.18), math.rad(-30 + Roll))
    local RightTarget = CFrame.Angles(math.rad(Pitch + AirSweep * 0.14), math.rad(12 - Sweep + AirSweep * 0.26 + StrokeVelocity * 0.18), math.rad(30 - Roll))
    local TransformAlpha = AngelWingExpAlpha(13, DeltaTime)
    LeftMotor.Transform = LeftMotor.Transform:Lerp(LeftTarget, TransformAlpha)
    RightMotor.Transform = RightMotor.Transform:Lerp(RightTarget, TransformAlpha)
    S.AngelWings.FeatherAccumulator = S.AngelWings.FeatherAccumulator + DeltaTime
    if S.AngelWings.FeatherAccumulator >= S.AngelWings.FeatherInterval then
        S.AngelWings.FeatherAccumulator = S.AngelWings.FeatherAccumulator % S.AngelWings.FeatherInterval
        UpdateAngelWingFeathers(Phase, Activity)
    end
    local MotionEnergy = AngelWingClamp(math.abs(StrokeVelocity) / 14, 0, 1)
    S.AngelWings.EmitterAccumulator = S.AngelWings.EmitterAccumulator + DeltaTime
    if S.AngelWings.EmitterAccumulator >= S.AngelWings.EmitterInterval then
        S.AngelWings.EmitterAccumulator = S.AngelWings.EmitterAccumulator % S.AngelWings.EmitterInterval
        local MinimumSpeed = 0.10 + MotionEnergy * 0.18
        local MaximumSpeed = 0.42 + MotionEnergy * 0.42
        local Rate = 3 + MotionEnergy * 5
        for Unused, Emitter in ipairs(S.AngelWings.Emitters) do
            Emitter.Rate = Rate
            Emitter.Speed = NumberRange.new(MinimumSpeed, MaximumSpeed)
        end
    end
end

function RebuildAngelWings()
    if not S.AngelWings.Enabled then return end
    CreateAngelWings(LocalPlayer.Character)
end

function ToggleAngelWings(Enabled)
    S.AngelWings.Enabled = Enabled
    if Enabled then
        if not S.AngelWings.RenderConnection then S.AngelWings.RenderConnection = RunService.Heartbeat:Connect(UpdateAngelWings) end
        if not S.AngelWings.CharacterConnection then
            S.AngelWings.CharacterConnection = LocalPlayer.CharacterAdded:Connect(function(Character)
                task.spawn(function()
                    task.wait(0.65)
                    if S.AngelWings.Enabled then CreateAngelWings(Character) end
                end)
            end)
        end
        CreateAngelWings(LocalPlayer.Character)
    else
        if S.AngelWings.RenderConnection then
            S.AngelWings.RenderConnection:Disconnect()
            S.AngelWings.RenderConnection = nil
        end
        if S.AngelWings.CharacterConnection then
            S.AngelWings.CharacterConnection:Disconnect()
            S.AngelWings.CharacterConnection = nil
        end
        DestroyAngelWingModel()
    end
end

function RemoveAimFOVCircle()
    local Circle = S.AimBot.FOVCircle
    if Circle then
        pcall(function()
            Circle.Visible = false
            Circle:Remove()
        end)
    end
    local GlowCircle = S.AimBot.FOVGlowCircle
    if GlowCircle then
        pcall(function()
            GlowCircle.Visible = false
            GlowCircle:Remove()
        end)
    end
    S.AimBot.FOVCircle = nil
    S.AimBot.FOVGlowCircle = nil
end

function CreateAimFOVDrawingCircle(Color, Thickness, Transparency)
    local Success, Circle = pcall(Drawing.new, "Circle")
    if not Success or not Circle then return nil end
    Circle.Color = Color
    Circle.Filled = false
    Circle.Thickness = Thickness
    Circle.Transparency = Transparency
    Circle.Radius = S.AimBot.FOV
    return Circle
end

function CreateFOVCircle()
    RemoveAimFOVCircle()
    if not S.AimBot.ShowFOV or not Drawing or type(Drawing.new) ~= "function" then return end
    local CameraObject = GetCamera()
    local Position = CameraObject and Vector2.new(CameraObject.ViewportSize.X * 0.5, CameraObject.ViewportSize.Y * 0.5) or Vector2.new(500, 500)
    local Visible = S.AimBot.Enabled and S.AimBot.ShowFOV
    if S.AimBot.FOVGlow then
        local GlowCircle = CreateAimFOVDrawingCircle(S.AimBot.FOVGlowColor, S.AimBot.FOVGlowThickness, S.AimBot.FOVGlowTransparency)
        if GlowCircle then
            GlowCircle.Position = Position
            GlowCircle.Visible = Visible
            S.AimBot.FOVGlowCircle = GlowCircle
        end
    end
    local Circle = CreateAimFOVDrawingCircle(S.AimBot.FOVColor, 2, S.AimBot.FOVTransparency)
    if not Circle then
        RemoveAimFOVCircle()
        return
    end
    Circle.Position = Position
    Circle.Visible = Visible
    S.AimBot.FOVCircle = Circle
end

function UpdateFOVCircle()
    local Circle = S.AimBot.FOVCircle
    if not Circle then return end
    local CameraObject = GetCamera()
    if not CameraObject then
        Circle.Visible = false
        if S.AimBot.FOVGlowCircle then S.AimBot.FOVGlowCircle.Visible = false end
        return
    end
    local Position = Vector2.new(CameraObject.ViewportSize.X * 0.5, CameraObject.ViewportSize.Y * 0.5)
    local Visible = S.AimBot.Enabled and S.AimBot.ShowFOV
    Circle.Position = Position
    Circle.Radius = S.AimBot.FOV
    Circle.Color = S.AimBot.FOVColor
    Circle.Transparency = S.AimBot.FOVTransparency
    Circle.Visible = Visible
    local GlowCircle = S.AimBot.FOVGlowCircle
    if S.AimBot.FOVGlow and not GlowCircle then
        CreateFOVCircle()
        return
    end
    if GlowCircle then
        GlowCircle.Position = Position
        GlowCircle.Radius = S.AimBot.FOV
        GlowCircle.Color = S.AimBot.FOVGlowColor
        GlowCircle.Thickness = S.AimBot.FOVGlowThickness
        GlowCircle.Transparency = S.AimBot.FOVGlowTransparency
        GlowCircle.Visible = Visible and S.AimBot.FOVGlow
    end
end

function GetClosestPlayer()
    if not S.AimBot.Enabled then return nil end

    local CameraObject = GetCamera()
    if not CameraObject then return nil end

    local ClosestPlayer = nil
    local ShortestDistance = S.AimBot.FOV
    local CenterPosition = CameraObject.ViewportSize * 0.5

    for _, PlayerObject in ipairs(Players:GetPlayers()) do
        if PlayerObject ~= LocalPlayer and PlayerObject.Character then
            local CharacterObject = PlayerObject.Character
            local HumanoidObject = CharacterObject:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = ResolverGetRoot(CharacterObject)

            if S.AimBot.DownedCheck and HumanoidObject then
                if HumanoidObject.Health <= 0 or HumanoidObject:GetState() == Enum.HumanoidStateType.Dead then continue end
            end

            if HumanoidRootPart then
                local TargetPart = CharacterObject:FindFirstChild(S.AimBot.TargetPart)
                    or CharacterObject:FindFirstChild("Head")
                    or HumanoidRootPart

                if TargetPart and TargetPart:IsA("BasePart") then
                    ResolverObservePlayer(PlayerObject, CharacterObject, S.AimBot)

                    local PredictionTime = math.clamp((tonumber(S.AimBot.Prediction) or 0) / 1000, 0, 0.45)
                    local TargetPosition = ResolveCombatPosition(PlayerObject, CharacterObject, TargetPart, PredictionTime, S.AimBot)
                        or TargetPart.Position

                    if S.AimBot.WallCheck then
                        local Direction = TargetPosition - CameraObject.CFrame.Position
                        local Parameters = RaycastParams.new()
                        Parameters.FilterType = Enum.RaycastFilterType.Exclude
                        Parameters.FilterDescendantsInstances = { LocalPlayer.Character, CameraObject }
                        Parameters.IgnoreWater = true

                        local Result = workspace:Raycast(CameraObject.CFrame.Position, Direction, Parameters)
                        if Result and not Result.Instance:IsDescendantOf(CharacterObject) then continue end
                    end

                    local ScreenPosition, IsOnScreen = CameraObject:WorldToViewportPoint(TargetPosition)

                    if IsOnScreen and ScreenPosition.Z > 0 then
                        local ScreenPoint = Vector2.new(ScreenPosition.X, ScreenPosition.Y)
                        local Distance = (CenterPosition - ScreenPoint).Magnitude

                        if Distance < ShortestDistance then
                            ShortestDistance = Distance
                            ClosestPlayer = PlayerObject
                        end
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

function GetTargetPosition(CharacterObject, PlayerObject)
    if not CharacterObject then return nil end

    local TargetPart = CharacterObject:FindFirstChild(S.AimBot.TargetPart)
        or CharacterObject:FindFirstChild("HumanoidRootPart")
        or CharacterObject:FindFirstChild("Head")

    if not TargetPart or not TargetPart:IsA("BasePart") then return nil end

    PlayerObject = PlayerObject or GetPlayerFromTrackedCharacter(CharacterObject)
    local PredictionTime = math.clamp((tonumber(S.AimBot.Prediction) or 0) / 1000, 0, 0.45)
    local PositionValue = ResolveCombatPosition(PlayerObject, CharacterObject, TargetPart, PredictionTime, S.AimBot)

    return PositionValue or TargetPart.Position
end

function SmoothAim(TargetPosition)
    if not TargetPosition then return end
    local CameraObject = GetCamera()
    if not CameraObject then return end
    local CurrentCFrame = CameraObject.CFrame
    local TargetCFrame = CFrame.lookAt(CurrentCFrame.Position, TargetPosition)
    local SmoothCFrame = CurrentCFrame:Lerp(TargetCFrame, S.AimBot.Smoothness)
    CameraObject.CFrame = SmoothCFrame
end

function AimLoop()
    if not S.AimBot.Enabled then return end
    local CurrentTarget = nil
    if S.AimBot.Sticky then
        CurrentTarget = S.AimBot.Target
        if CurrentTarget then
            local CharacterObject = CurrentTarget.Character
            if not CharacterObject then
                CurrentTarget = nil
                S.AimBot.Target = nil
            else
                local HumanoidObject = CharacterObject:FindFirstChildOfClass("Humanoid")
                if not HumanoidObject or HumanoidObject.Health <= 0 or(S.AimBot.DownedCheck and HumanoidObject:GetState() == Enum.HumanoidStateType.Dead) then
                    CurrentTarget = nil
                    S.AimBot.Target = nil
                end
            end
        end
        if not CurrentTarget then
            CurrentTarget = GetClosestPlayer()
            S.AimBot.Target = CurrentTarget
        end
    else
        CurrentTarget = GetClosestPlayer()
    end

    S.AimBot.CurrentTarget = CurrentTarget

    if CurrentTarget and CurrentTarget.Character then
        local TargetPosition = GetTargetPosition(CurrentTarget.Character, CurrentTarget)
        if TargetPosition then SmoothAim(TargetPosition) end
    end
end

function ToggleAimBot(StateValue)
    S.AimBot.Enabled = StateValue == true
    S.AimBot.Resolver = true
    S.AimBot.ResolverMode = "Adaptive"
    S.AimBot.ResolverStrength = 1
    S.AimBot.Target = nil
    S.AimBot.CurrentTarget = nil
    if S.AimBot.Enabled then
        CreateFOVCircle()
        if S.AimBot.FOVUpdateConnection then S.AimBot.FOVUpdateConnection:Disconnect() end
        S.AimBot.FOVUpdateConnection = RunService.RenderStepped:Connect(UpdateFOVCircle)
        if S.AimBot.Connection then S.AimBot.Connection:Disconnect() end
        S.AimBot.Connection = RunService.RenderStepped:Connect(AimLoop)
        return
    end
    RemoveAimFOVCircle()
    if S.AimBot.FOVUpdateConnection then
        S.AimBot.FOVUpdateConnection:Disconnect()
        S.AimBot.FOVUpdateConnection = nil
    end
    if S.AimBot.Connection then
        S.AimBot.Connection:Disconnect()
        S.AimBot.Connection = nil
    end
end

function SetupBlur()
    if not S.Blur.BlurEffect then
        S.Blur.BlurEffect = Instance.new("BlurEffect", game:GetService("Lighting"))
        S.Blur.BlurEffect.Size = 0
    end
    if S.Blur.Connection then
        S.Blur.Connection:Disconnect()
        S.Blur.Connection = nil
    end
    S.Blur.Connection = RunService.RenderStepped:Connect(function()
        if not S.Blur.Enabled or not S.Blur.BlurEffect then return end
        local CameraObject = GetCamera()
        if not CameraObject then return end
        S.Blur.CurrentLookVector = CameraObject.CFrame.LookVector
        S.Blur.RotationSpeed = (S.Blur.CurrentLookVector - (S.Blur.LastLookVector or S.Blur.CurrentLookVector)).Magnitude * 130
        S.Blur.BlurEffect.Size = math.clamp(S.Blur.RotationSpeed, 0, 20)
        S.Blur.LastLookVector = S.Blur.CurrentLookVector
    end)
end

function DisableBlur()
    if S.Blur.Connection then
        S.Blur.Connection:Disconnect()
        S.Blur.Connection = nil
    end
    if S.Blur.BlurEffect then
        S.Blur.BlurEffect.Size = 0
        S.Blur.BlurEffect:Destroy()
        S.Blur.BlurEffect = nil
    end
end

function ToggleBlur(StateValue)
    S.Blur.Enabled = StateValue
    if StateValue then SetupBlur() else DisableBlur() end
end

function DisconnectFreecamInputs()
    for Unused, Connection in ipairs(S.Freecam.InputConnections) do
        pcall(function() Connection:Disconnect() end)
    end
    S.Freecam.InputConnections = {}
end

function AddFreecamInputConnection(Connection)
    S.Freecam.InputConnections[#S.Freecam.InputConnections + 1] = Connection
    return Connection
end

function SetFreecamRotationState(State)
    State = State == true
    S.Freecam.Rotating = State
    if S.Freecam.OnMobile then return end
    if State then
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    else
        UserInputService.MouseBehavior = S.Freecam.SavedMouseBehavior or Enum.MouseBehavior.Default
        if S.Freecam.SavedMouseIconEnabled ~= nil then
            UserInputService.MouseIconEnabled = S.Freecam.SavedMouseIconEnabled
        else
            UserInputService.MouseIconEnabled = true
        end
    end
end

function GetFreecamMovementVector(CameraFrame)
    local Movement = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then Movement = Movement + CameraFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then Movement = Movement - CameraFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then Movement = Movement - CameraFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then Movement = Movement + CameraFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.E) or UserInputService:IsKeyDown(Enum.KeyCode.Space) then Movement = Movement + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Q) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then Movement = Movement - Vector3.new(0, 1, 0) end
    if Movement.Magnitude > 1 then Movement = Movement.Unit end
    return Movement
end

function UpdateFreecam(DeltaTime)
    if not S.Freecam.Enabled then return end
    local CameraObject = GetCamera()
    if not CameraObject then
        ToggleFreecam(false)
        return
    end
    DeltaTime = math.clamp(tonumber(DeltaTime) or 0.016, 0.001, 0.05)
    CameraObject.CameraType = Enum.CameraType.Scriptable
    local Rotating = UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    if Rotating ~= S.Freecam.Rotating then SetFreecamRotationState(Rotating) end
    if Rotating then
        local Delta = UserInputService:GetMouseDelta()
        if Delta.Magnitude < 0.001 and S.Freecam.MouseDelta.Magnitude > 0 then Delta = S.Freecam.MouseDelta end
        S.Freecam.MouseDelta = Vector2.new(0, 0)
        local Sensitivity = S.Freecam.Sensitivity * 0.01
        S.Freecam.Yaw = S.Freecam.Yaw - Delta.X * Sensitivity
        S.Freecam.Pitch = math.clamp(S.Freecam.Pitch - Delta.Y * Sensitivity, math.rad(-89), math.rad(89))
    end
    local RotationFrame = CFrame.Angles(0, S.Freecam.Yaw, 0) * CFrame.Angles(S.Freecam.Pitch, 0, 0)
    local Movement = GetFreecamMovementVector(RotationFrame)
    local Speed = S.Freecam.Speed
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then Speed = Speed * S.Freecam.BoostMultiplier end
    local TargetVelocity = Movement * Speed
    S.Freecam.Velocity = S.Freecam.Velocity:Lerp(TargetVelocity, 1 - math.exp(-S.Freecam.Acceleration * DeltaTime))
    S.Freecam.Position = S.Freecam.Position + S.Freecam.Velocity * DeltaTime
    local CameraFrame = CFrame.new(S.Freecam.Position) * RotationFrame
    CameraObject.CFrame = CameraFrame
    CameraObject.Focus = CFrame.new(S.Freecam.Position + CameraFrame.LookVector * 512)
end

function SetupFreecam()
    local CameraObject = GetCamera()
    if not CameraObject then
        S.Freecam.Enabled = false
        return
    end
    DisconnectFreecamInputs()
    pcall(function() RunService:UnbindFromRenderStep("RadiantFreecam") end)
    S.Freecam.SavedCameraType = CameraObject.CameraType
    S.Freecam.SavedCameraSubject = CameraObject.CameraSubject
    S.Freecam.SavedFieldOfView = CameraObject.FieldOfView
    S.Freecam.SavedMouseBehavior = UserInputService.MouseBehavior
    S.Freecam.SavedMouseIconEnabled = UserInputService.MouseIconEnabled
    S.Freecam.Position = CameraObject.CFrame.Position
    local Pitch, Yaw = CameraObject.CFrame:ToOrientation()
    S.Freecam.Pitch = math.clamp(Pitch, math.rad(-89), math.rad(89))
    S.Freecam.Yaw = Yaw
    S.Freecam.Velocity = Vector3.new(0, 0, 0)
    S.Freecam.KeysDown = {}
    S.Freecam.Rotating = false
    local Character = LocalPlayer.Character
    local RootPart = Character and Character:FindFirstChild("HumanoidRootPart")
    S.Freecam.SavedRootPart = RootPart
    if RootPart then
        S.Freecam.SavedRootAnchored = RootPart.Anchored
        RootPart.Anchored = true
    else
        S.Freecam.SavedRootAnchored = nil
    end
    CameraObject.CameraType = Enum.CameraType.Scriptable
    AddFreecamInputConnection(UserInputService.InputChanged:Connect(function(Input)
        if not S.Freecam.Enabled then return end
        if Input.UserInputType == Enum.UserInputType.MouseWheel then
            S.Freecam.Speed = math.clamp(S.Freecam.Speed + Input.Position.Z * 5, 1, 250)
        elseif Input.UserInputType == Enum.UserInputType.MouseMovement and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
            S.Freecam.MouseDelta = S.Freecam.MouseDelta + Vector2.new(Input.Delta.X, Input.Delta.Y)
        end
    end))
    pcall(function()
        AddFreecamInputConnection(UserInputService.WindowFocusReleased:Connect(function() SetFreecamRotationState(false) end))
    end)
    RunService:BindToRenderStep("RadiantFreecam", Enum.RenderPriority.Camera.Value + 10, UpdateFreecam)
end

function DisableFreecam()
    pcall(function() RunService:UnbindFromRenderStep("RadiantFreecam") end)
    DisconnectFreecamInputs()
    SetFreecamRotationState(false)
    local CameraObject = GetCamera()
    if CameraObject then
        CameraObject.CameraType = S.Freecam.SavedCameraType or Enum.CameraType.Custom
        if S.Freecam.SavedCameraSubject and S.Freecam.SavedCameraSubject.Parent then
            CameraObject.CameraSubject = S.Freecam.SavedCameraSubject
        elseif LocalPlayer.Character then
            local Humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then CameraObject.CameraSubject = Humanoid end
        end
        if S.Freecam.SavedFieldOfView then CameraObject.FieldOfView = S.Freecam.SavedFieldOfView end
    end
    local RootPart = S.Freecam.SavedRootPart
    if RootPart and RootPart.Parent then RootPart.Anchored = S.Freecam.SavedRootAnchored == true end
    S.Freecam.KeysDown = {}
    S.Freecam.Rotating = false
    S.Freecam.Position = nil
    S.Freecam.Velocity = Vector3.new(0, 0, 0)
    S.Freecam.SavedCameraType = nil
    S.Freecam.SavedCameraSubject = nil
    S.Freecam.SavedFieldOfView = nil
    S.Freecam.SavedMouseBehavior = nil
    S.Freecam.SavedMouseIconEnabled = nil
    S.Freecam.SavedRootAnchored = nil
    S.Freecam.SavedRootPart = nil
end

function ToggleFreecam(State)
    State = State == true
    if State == S.Freecam.Enabled then return end
    S.Freecam.Enabled = State
    if State then
        SetupFreecam()
    else
        DisableFreecam()
    end
end

WeaponModsThread = nil
WeaponIdentityFields = { "Damage", "HeadshotMultiplier", "LimbMultiplier", "Spread", "Recoil", "FireRate", "MagSize", "StoredAmmo", "Range", "BulletsPerShot" }
WeaponRecoilFields = { "Recoil", "RecoilAmount", "CameraRecoil", "CameraRecoilAmount", "Kickback", "Kick", "ViewKick", "RecoilX", "RecoilY", "RecoilZ" }
WeaponRecoilBooleanFields = { "CameraRecoilingEnabled", "RecoilEnabled", "CameraRecoilEnabled" }
WeaponSpreadFields = { "Spread", "SpreadMin", "SpreadMax", "HipSpread", "AimSpread", "ADSSpread", "Bloom", "BloomMin", "BloomMax" }
WeaponCrosshairFields = { "CrossExpansion", "CrosshairExpansion", "CrosshairBloom", "CrosshairKick" }
WeaponMovementSpreadFields = { "WalkSpreadIncrease", "MoveSpreadIncrease", "MovementSpread", "JumpSpreadIncrease" }
WeaponRecoilDamperFields = { "RecoilDamper", "RecoilDamping", "RecoilDecay" }

function IsWeaponConfigNR(Object)
    if type(Object) ~= "table" then return false end
    local IdentityScore = 0
    for _, Field in ipairs(WeaponIdentityFields) do
        if type(rawget(Object, Field)) == "number" then IdentityScore = IdentityScore + 1 end
    end
    local HasAccuracy = type(rawget(Object, "Spread")) == "number" or type(rawget(Object, "Recoil")) == "number"
    local HasWeaponRate = type(rawget(Object, "FireRate")) == "number" or type(rawget(Object, "MagSize")) == "number"
    return IdentityScore >= 4 and HasAccuracy and HasWeaponRate
end

function RememberWeaponFieldNR(Object, Field)
    local Original = S.NoRecoil.OriginalValues[Object]
    if not Original then Original = {}; S.NoRecoil.OriginalValues[Object] = Original end
    if Original[Field] == nil then Original[Field] = rawget(Object, Field) end
end

function SetWeaponFieldNR(Object, Field, Value)
    local Current = rawget(Object, Field)
    if Current == nil or type(Current) ~= type(Value) or Current == Value then return false end
    RememberWeaponFieldNR(Object, Field)
    local WasReadonly = type(isreadonly) == "function" and type(setreadonly) == "function" and isreadonly(Object)
    if WasReadonly then pcall(setreadonly, Object, false) end
    local Success = pcall(function() Object[Field] = Value end)
    if WasReadonly then pcall(setreadonly, Object, true) end
    return Success
end

function ApplyNestedWeaponGroupNR(Key, Value)
    if type(Value) ~= "table" then return end
    local Name = string.lower(tostring(Key))
    local IsRecoil = string.find(Name, "recoil", 1, true) or string.find(Name, "kick", 1, true)
    local IsSpread = string.find(Name, "spread", 1, true) or string.find(Name, "bloom", 1, true)
    local IsCrosshair = string.find(Name, "cross", 1, true)
    if not IsRecoil and not IsSpread and not IsCrosshair then return end
    for NestedField, NestedValue in pairs(Value) do
        if type(NestedValue) == "number" then
            if IsSpread and S.NoRecoil.Settings.GunMods.Spread then
                SetWeaponFieldNR(Value, NestedField, tonumber(S.NoRecoil.Settings.GunMods.SpreadAmount) or 0)
            elseif IsRecoil and S.NoRecoil.Settings.GunMods.NoRecoil then
                SetWeaponFieldNR(Value, NestedField, 0)
            elseif IsCrosshair and S.NoRecoil.Settings.GunMods.NoCrosshair then
                SetWeaponFieldNR(Value, NestedField, 0)
            end
        elseif type(NestedValue) == "boolean" and IsRecoil and S.NoRecoil.Settings.GunMods.NoRecoil then
            SetWeaponFieldNR(Value, NestedField, false)
        end
    end
end

function AddWeaponConfigNR(Cache, Seen, Object)
    if not IsWeaponConfigNR(Object) or Seen[Object] then return end
    Seen[Object] = true
    Cache[#Cache + 1] = Object
end

function CacheWeaponsNR(Force)
    local Now = os.clock()
    if S.NoRecoil.Scanning or (not Force and Now - S.NoRecoil.LastScan < 2) or (Force and Now - S.NoRecoil.LastScan < 0.35) then return false end
    S.NoRecoil.Scanning = true
    local Seen, Cache = setmetatable({}, { __mode = "k" }), setmetatable({}, { __mode = "v" })
    for _, WeaponObject in pairs(S.NoRecoil.WeaponCache) do AddWeaponConfigNR(Cache, Seen, WeaponObject) end
    local Success = RadiantScanGarbage(true, function(Object) AddWeaponConfigNR(Cache, Seen, Object) end, 512)
    if Success then S.NoRecoil.WeaponCache, S.NoRecoil.CacheReady, S.NoRecoil.LastScan = Cache, true, os.clock() end
    S.NoRecoil.Scanning = false
    return Success
end

function ApplyExactWeaponConfigNR(WeaponObject)
    if S.NoRecoil.Settings.GunMods.NoRecoil then
        for _, Field in ipairs(WeaponRecoilFields) do SetWeaponFieldNR(WeaponObject, Field, 0) end
        for _, Field in ipairs(WeaponRecoilBooleanFields) do SetWeaponFieldNR(WeaponObject, Field, false) end
        for _, Field in ipairs(WeaponRecoilDamperFields) do SetWeaponFieldNR(WeaponObject, Field, 1) end
    end
    if S.NoRecoil.Settings.GunMods.Spread then
        local SpreadAmount = tonumber(S.NoRecoil.Settings.GunMods.SpreadAmount) or 0
        for _, Field in ipairs(WeaponSpreadFields) do SetWeaponFieldNR(WeaponObject, Field, SpreadAmount) end
        for _, Field in ipairs(WeaponMovementSpreadFields) do SetWeaponFieldNR(WeaponObject, Field, 0) end
    end
    if S.NoRecoil.Settings.GunMods.NoCrosshair then
        for _, Field in ipairs(WeaponCrosshairFields) do SetWeaponFieldNR(WeaponObject, Field, 0) end
    end

    if S.NoRecoil.Settings.GunMods.RapidFire then
        SetWeaponFieldNR(WeaponObject, "FireRate", GetRapidFireRateNR())

        for _, Field in ipairs({ "FireDelay", "ShootDelay", "ShotDelay", "FireCooldown", "ShotCooldown" }) do
            if type(rawget(WeaponObject, Field)) == "number" then
                SetWeaponFieldNR(WeaponObject, Field, GetRapidFireDelayNR())
            end
        end
    end

    for Key, Value in pairs(WeaponObject) do ApplyNestedWeaponGroupNR(Key, Value) end
end

function ApplyGunModsNR()
    for _, WeaponObject in pairs(S.NoRecoil.WeaponCache) do
        if IsWeaponConfigNR(WeaponObject) then ApplyExactWeaponConfigNR(WeaponObject) end
    end
end

function ResetGunModsNR()
    for WeaponObject, Original in pairs(S.NoRecoil.OriginalValues) do
        if type(WeaponObject) == "table" and type(Original) == "table" then
            local WasReadonly = type(isreadonly) == "function" and type(setreadonly) == "function" and isreadonly(WeaponObject)
            if WasReadonly then pcall(setreadonly, WeaponObject, false) end
            for Field, Value in pairs(Original) do pcall(function() WeaponObject[Field] = Value end) end
            if WasReadonly then pcall(setreadonly, WeaponObject, true) end
        end
    end
end

function DisableRCLConnectionNR(ConnectionObject)
    if S.NoRecoil.RCLLookup[ConnectionObject] then return end
    local DisableMethod = ConnectionObject.Disable or ConnectionObject.DisableConnection
    if type(DisableMethod) ~= "function" then return end
    local Success = pcall(DisableMethod, ConnectionObject)
    if Success then
        S.NoRecoil.RCLLookup[ConnectionObject] = true
        S.NoRecoil.RCLConnections[#S.NoRecoil.RCLConnections + 1] = ConnectionObject
    end
end

function HandleRCLObjectNR(Object)
    if not S.NoRecoil.Enabled or not S.NoRecoil.Settings.GunMods.NoRecoil or type(getconnections) ~= "function" then return end
    if not Object or Object.Name ~= "RCL" or not Object:IsA("BindableEvent") then return end
    local Success, Connections = pcall(getconnections, Object.Event)
    if not Success or type(Connections) ~= "table" then return end
    for _, ConnectionObject in ipairs(Connections) do DisableRCLConnectionNR(ConnectionObject) end
end

function DisableCameraRecoilNR(ScanExisting)
    if not S.NoRecoil.Settings.GunMods.NoRecoil then return end
    if not ScanExisting then return end
    for _, Object in ipairs(game:GetDescendants()) do
        if Object.Name == "RCL" and Object:IsA("BindableEvent") then HandleRCLObjectNR(Object) end
    end
end

function RestoreCameraRecoilNR()
    for _, ConnectionObject in ipairs(S.NoRecoil.RCLConnections) do
        local EnableMethod = ConnectionObject.Enable or ConnectionObject.EnableConnection
        if type(EnableMethod) == "function" then pcall(EnableMethod, ConnectionObject) end
    end
    S.NoRecoil.RCLConnections = {}
    S.NoRecoil.RCLLookup = setmetatable({}, { __mode = "k" })
end

RapidFireStateNR = {
    PatchedUpvalues = setmetatable({}, { __mode = "k" }),
    PatchedTables = setmetatable({}, { __mode = "k" }),
    LastScan = 0,
    Scanning = false
}

function GetRapidFireDelayNR()
    return math.clamp(tonumber(S.NoRecoil.Settings.GunMods.RapidFireDelay) or 0.10, 0.01, 0.5)
end

function GetRapidFireRateNR()
    return 1 / GetRapidFireDelayNR()
end

function IsRapidFireRateNameNR(Name)
    Name = string.lower(tostring(Name or "")):gsub("[^%w]", "")
    return Name == "firerate" or Name == "shootrate" or Name == "shotspersecond" or Name == "roundspersecond"
end

function IsRapidFireDelayNameNR(Name)
    Name = string.lower(tostring(Name or "")):gsub("[^%w]", "")
    return Name == "firedelay" or Name == "shootdelay" or Name == "shotdelay" or Name == "firecooldown" or Name == "shotcooldown"
end

function HasRapidFireFunctionIdentityNR(FunctionObject)
    local Reader = type(getconstants) == "function" and getconstants or type(debug) == "table" and debug.getconstants
    if type(Reader) ~= "function" then return false end

    local Success, Constants = pcall(Reader, FunctionObject)
    if not Success or type(Constants) ~= "table" then return false end

    for _, Constant in pairs(Constants) do
        if Constant == "FDS9I83" then return true end
    end

    return false
end

function PatchRapidFireFunctionNR(FunctionObject)
    if not S.NoRecoil.Enabled or not S.NoRecoil.Settings.GunMods.RapidFire or type(FunctionObject) ~= "function" then return end
    if not HasRapidFireFunctionIdentityNR(FunctionObject) then return end

    local Reader = type(getupvalue) == "function" and getupvalue or type(debug) == "table" and debug.getupvalue
    local Writer = type(setupvalue) == "function" and setupvalue or type(debug) == "table" and debug.setupvalue
    if type(Reader) ~= "function" then return end

    local Rate = GetRapidFireRateNR()
    local Delay = GetRapidFireDelayNR()

    for Index = 1, 64 do
        local Success, First, Second = pcall(Reader, FunctionObject, Index)
        if not Success or First == nil then break end

        local Name, Value
        if Second ~= nil then
            Name, Value = First, Second
        else
            Name, Value = tostring(Index), First
        end

        if type(Value) == "number" and type(Writer) == "function" then
            local Replacement = nil

            if IsRapidFireRateNameNR(Name) then
                Replacement = Rate
            elseif IsRapidFireDelayNameNR(Name) then
                Replacement = Delay
            end

            if Replacement then
                local Patches = RapidFireStateNR.PatchedUpvalues[FunctionObject]
                if not Patches then
                    Patches = {}
                    RapidFireStateNR.PatchedUpvalues[FunctionObject] = Patches
                end

                if Patches[Index] == nil then Patches[Index] = Value end
                pcall(Writer, FunctionObject, Index, Replacement)
            end
        elseif type(Value) == "table" then
            for Key, NestedValue in pairs(Value) do
                if type(NestedValue) == "number" then
                    local Replacement = nil

                    if IsRapidFireRateNameNR(Key) then
                        Replacement = Rate
                    elseif IsRapidFireDelayNameNR(Key) then
                        Replacement = Delay
                    end

                    if Replacement then
                        local Patches = RapidFireStateNR.PatchedTables[Value]
                        if not Patches then
                            Patches = {}
                            RapidFireStateNR.PatchedTables[Value] = Patches
                        end

                        if Patches[Key] == nil then Patches[Key] = NestedValue end
                        pcall(function() Value[Key] = Replacement end)
                    end
                end
            end
        end
    end
end

function ScanRapidFireFunctionsNR(Force)
    if not S.NoRecoil.Enabled or not S.NoRecoil.Settings.GunMods.RapidFire then return end

    local CurrentTime = os.clock()
    if RapidFireStateNR.Scanning or not Force and CurrentTime - RapidFireStateNR.LastScan < 1.5 then return end

    RapidFireStateNR.Scanning = true
    RapidFireStateNR.LastScan = CurrentTime

    RadiantScanGarbage(false, function(Object)
        if type(Object) == "function" then PatchRapidFireFunctionNR(Object) end
    end, 192)

    RapidFireStateNR.Scanning = false
    RadiantStepGC(16)
end

function RestoreRapidFirePatchesNR()
    local Writer = type(setupvalue) == "function" and setupvalue or type(debug) == "table" and debug.setupvalue

    if type(Writer) == "function" then
        for FunctionObject, Patches in pairs(RapidFireStateNR.PatchedUpvalues) do
            for Index, OriginalValue in pairs(Patches) do
                pcall(Writer, FunctionObject, Index, OriginalValue)
            end
        end
    end

    for TableObject, Patches in pairs(RapidFireStateNR.PatchedTables) do
        for Key, OriginalValue in pairs(Patches) do
            pcall(function() TableObject[Key] = OriginalValue end)
        end
    end

    RapidFireStateNR.PatchedUpvalues = setmetatable({}, { __mode = "k" })
    RapidFireStateNR.PatchedTables = setmetatable({}, { __mode = "k" })
end

function ApplyRapidFireNR()
    if not S.NoRecoil.Enabled or not S.NoRecoil.Settings.GunMods.RapidFire then
        RestoreRapidFirePatchesNR()
        return
    end

    ScanRapidFireFunctionsNR(true)
end

function RefreshGunModsNR()
    ResetGunModsNR()
    RestoreCameraRecoilNR()
    RestoreRapidFirePatchesNR()

    if not S.NoRecoil.Enabled then return end

    ApplyGunModsNR()
    DisableCameraRecoilNR(false)
    ApplyRapidFireNR()
end

function HandleWeaponNR(WeaponObject)
    if not S.NoRecoil.Enabled or not WeaponObject or not WeaponObject:IsA("Tool") then return end

    if S.NoRecoil.Settings.GunMods.RapidFire then
        ScanRapidFireFunctionsNR(false)
    end

    task.delay(0.2, function()
        if not S.NoRecoil.Enabled or WeaponObject.Parent ~= LocalPlayer.Character then return end
        CacheWeaponsNR(true)
        ApplyGunModsNR()
    end)
end

function OnCharacterAddedNR(CharacterObject)
    for _, ChildObject in ipairs(CharacterObject:GetChildren()) do
        if ChildObject:IsA("Tool") then HandleWeaponNR(ChildObject) end
    end
    S.NoRecoil.Connections[#S.NoRecoil.Connections + 1] = CharacterObject.ChildAdded:Connect(function(ChildObject)
        if ChildObject:IsA("Tool") then HandleWeaponNR(ChildObject) end
    end)
end

function EnableNoRecoil()
    if S.NoRecoil.Enabled then RefreshGunModsNR(); return end
    S.NoRecoil.Enabled = true
    S.NoRecoil.OriginalValues = setmetatable({}, { __mode = "k" })
    S.NoRecoil.RCLConnections = {}
    S.NoRecoil.RCLLookup = setmetatable({}, { __mode = "k" })
    CacheWeaponsNR(true)
    ApplyGunModsNR()
    DisableCameraRecoilNR(true)
    ApplyRapidFireNR()

    S.NoRecoil.Connections[#S.NoRecoil.Connections + 1] = game.DescendantAdded:Connect(function(Object)
        if Object.Name == "RCL" then task.defer(HandleRCLObjectNR, Object) end
    end)
    S.NoRecoil.Connections[#S.NoRecoil.Connections + 1] = LocalPlayer.CharacterAdded:Connect(OnCharacterAddedNR)
    if LocalPlayer.Character then OnCharacterAddedNR(LocalPlayer.Character) end
end

function DisableNoRecoil()
    if not S.NoRecoil.Enabled then return end
    S.NoRecoil.Enabled = false
    if WeaponModsThread then task.cancel(WeaponModsThread); WeaponModsThread = nil end
    ResetGunModsNR()
    RestoreCameraRecoilNR()
    RestoreRapidFirePatchesNR()

    for _, ConnectionObject in ipairs(S.NoRecoil.Connections) do pcall(function() ConnectionObject:Disconnect() end) end
    S.NoRecoil.Connections = {}
    S.NoRecoil.WeaponCache = setmetatable({}, { __mode = "v" })
    S.NoRecoil.OriginalValues = setmetatable({}, { __mode = "k" })
    S.NoRecoil.CacheReady, S.NoRecoil.LastScan, S.NoRecoil.Scanning = false, 0, false
    RadiantStepGC(32)
end

function ToggleNoRecoil(StateValue)
    if StateValue then EnableNoRecoil() else DisableNoRecoil() end
end

function FindRespawnButton()
    for Unused, Descendant in ipairs(PlayerGui:GetDescendants()) do
        if Descendant:IsA("GuiButton") then
            local Name = string.lower(Descendant.Name)
            local Text = Descendant:IsA("TextButton") and string.lower(Descendant.Text) or ""
            if string.find(Name, "respawn", 1, true) or string.find(Text, "respawn", 1, true) then return Descendant end
        end
    end
    return nil
end

function TriggerRespawnButton()
    local RespawnButton = FindRespawnButton()
    return ActivateGuiButton(RespawnButton)
end

function TriggerRespawnRemote()
    if not DeathRespawnEvent then return false end
    if DeathRespawnEvent:IsA("RemoteEvent") then
        return pcall(function() DeathRespawnEvent:FireServer() end)
    end
    if DeathRespawnEvent:IsA("RemoteFunction") then
        return pcall(function() DeathRespawnEvent:InvokeServer() end)
    end
    if DeathRespawnEvent:IsA("BindableEvent") then
        return pcall(function() DeathRespawnEvent:Fire() end)
    end
    return false
end

function RequestCharacterRespawn()
    local RemoteRequested = TriggerRespawnRemote()
    local ButtonRequested = TriggerRespawnButton()
    if RemoteRequested or ButtonRequested then return true end
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health > 0 then
        return pcall(function() Humanoid.Health = 0 end)
    end
    if Character then
        return pcall(function() Character:BreakJoints() end)
    end
    return false
end

function AutoRespawnEnable()
    if AutoRespawnEnabled then return end
    AutoRespawnEnabled = true
    if AutoRespawnCoroutine then
        task.cancel(AutoRespawnCoroutine)
        AutoRespawnCoroutine = nil
    end
    AutoRespawnCoroutine = task.spawn(function()
        while AutoRespawnEnabled do
            local Character = LocalPlayer.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Humanoid and Humanoid.Health <= 0 then
                local StartedAt = os.clock()
                repeat
                    RequestCharacterRespawn()
                    task.wait(0.75)
                    Character = LocalPlayer.Character
                    Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                until not AutoRespawnEnabled or(Humanoid and Humanoid.Health > 0) or os.clock() - StartedAt >= 8
                task.wait(1)
            else
                task.wait(0.50)
            end
        end
        AutoRespawnCoroutine = nil
    end)
end

function AutoRespawnDisable()
    if not AutoRespawnEnabled then return end
    AutoRespawnEnabled = false
    if AutoRespawnCoroutine then
        task.cancel(AutoRespawnCoroutine)
        AutoRespawnCoroutine = nil
    end
end

function FormatUptime(Seconds)
    Seconds = math.max(math.floor(Seconds), 0)
    local Hours = math.floor(Seconds / 3600)
    local Minutes = math.floor(Seconds % 3600 / 60)
    local RemainingSeconds = Seconds % 60
    return string.format("%02d:%02d:%02d", Hours, Minutes, RemainingSeconds)
end

function GetWatermarkText() return "radiant.rip  |  " .. LocalPlayer.Name .. "  |  " .. os.date("%d.%m.%Y  %H:%M:%S") .. "  |  up " .. FormatUptime(os.clock() - ScriptStartedAt) end

function CreateRadiantWatermark()
    local Parent = type(gethui) == "function" and gethui() or PlayerGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RadiantWatermark"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.Parent = Parent
    local Frame = Instance.new("Frame")
    Frame.Name = "Watermark"
    Frame.Size = UDim2.new(0, 1, 0, 22)
    Frame.Position = UDim2.new(0, 15, 0, 15)
    Frame.BackgroundColor3 = Library.Theme.Background
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.ClipsDescendants = true
    Frame.Parent = ScreenGui
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Library.Theme.Outline
    Stroke.Thickness = 1
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.LineJoinMode = Enum.LineJoinMode.Miter
    Stroke.Parent = Frame
    local Accent = Instance.new("Frame")
    Accent.Name = "Accent"
    Accent.Position = UDim2.new(0, -1, 0, -1)
    Accent.Size = UDim2.new(1, 2, 0, 3)
    Accent.BackgroundColor3 = Library.Theme.Accent
    Accent.BorderSizePixel = 0
    Accent.ZIndex = 3
    Accent.Parent = Frame
    local Label = Instance.new("TextLabel")
    Label.Name = "Text"
    Label.AutomaticSize = Enum.AutomaticSize.X
    Label.Size = UDim2.new(0, 0, 0, 17)
    Label.Position = UDim2.new(0, 7, 0, 4)
    Label.BackgroundTransparency = 1
    Label.BorderSizePixel = 0
    Label.FontFace = UiFont
    Label.TextColor3 = Library.Theme.Text
    Label.TextSize = 13
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Text = GetWatermarkText()
    Label.ZIndex = 4
    Label.Parent = Frame
    local Watermark = { ScreenGui = ScreenGui, Frame = Frame, Label = Label, Connection = nil, InputConnections = {}, Accumulator = 0, Dragging = false, DragStart = nil, StartPosition = nil }
    local function UpdateWidth()
        if not Frame.Parent or not Label.Parent then return end
        Frame.Size = UDim2.new(0, math.max(math.ceil(Label.TextBounds.X) + 14, 16), 0, 22)
    end
    local function IsPointerInput(Input) return Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch end
    Watermark.InputConnections[#Watermark.InputConnections + 1] = Label:GetPropertyChangedSignal("TextBounds"):Connect(UpdateWidth)
    Watermark.InputConnections[#Watermark.InputConnections + 1] = Frame.InputBegan:Connect(function(Input)
        if not IsPointerInput(Input) then return end
        Watermark.Dragging = true
        Watermark.DragStart = Input.Position
        Watermark.StartPosition = Frame.Position
    end)
    Watermark.InputConnections[#Watermark.InputConnections + 1] = UserInputService.InputChanged:Connect(function(Input)
        if not Watermark.Dragging or(Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch) then return end
        local Delta = Input.Position - Watermark.DragStart
        Frame.Position = UDim2.new(Watermark.StartPosition.X.Scale, Watermark.StartPosition.X.Offset + Delta.X, Watermark.StartPosition.Y.Scale, Watermark.StartPosition.Y.Offset + Delta.Y)
    end)
    Watermark.InputConnections[#Watermark.InputConnections + 1] = UserInputService.InputEnded:Connect(function(Input)
        if IsPointerInput(Input) then Watermark.Dragging = false end
    end)
    function Watermark.SetText(Self, Text)
        if Self.Label and Self.Label.Parent then
            Self.Label.Text = tostring(Text)
            UpdateWidth()
        end
    end
    function Watermark.SetVisibility(Self, State)
        if Self.ScreenGui and Self.ScreenGui.Parent then Self.ScreenGui.Enabled = State == true end
    end
    function Watermark.Destroy(Self)
        if Self.Connection then
            Self.Connection:Disconnect()
            Self.Connection = nil
        end
        for Index = #Self.InputConnections, 1, -1 do
            local Connection = Self.InputConnections[Index]
            if Connection then Connection:Disconnect() end
            Self.InputConnections[Index] = nil
        end
        if Self.ScreenGui then
            Self.ScreenGui:Destroy()
            Self.ScreenGui = nil
        end
    end
    task.defer(UpdateWidth)
    Watermark.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        Watermark.Accumulator = Watermark.Accumulator + DeltaTime
        if Watermark.Accumulator >= 0.20 then
            Watermark.Accumulator = Watermark.Accumulator % 0.20
            Watermark:SetText(GetWatermarkText())
        end
    end)
    return Watermark
end

function GetRadiantArmorValue(Character)
    if not Character then return 0 end

    local AttributeNames = { "Armor", "Armour", "ArmorValue", "ArmorHealth", "VestHealth" }
    for _, Name in ipairs(AttributeNames) do
        local Value = Character:GetAttribute(Name)
        if type(Value) == "number" then return math.max(0, math.floor(Value + 0.5)) end
    end

    local Containers = { Character, Character:FindFirstChild("Values"), Character:FindFirstChild("Stats") }
    for _, Container in ipairs(Containers) do
        if Container then
            for _, Name in ipairs(AttributeNames) do
                local ValueObject = Container:FindFirstChild(Name)
                if ValueObject and (ValueObject:IsA("NumberValue") or ValueObject:IsA("IntValue")) then
                    return math.max(0, math.floor(ValueObject.Value + 0.5))
                end
            end
        end
    end

    return 0
end

function GetRadiantTargetWeapon(Character)
    local Tool = Character and Character:FindFirstChildOfClass("Tool")
    return Tool and Tool.Name or "Unarmed"
end

function IsRadiantHUDTargetValid(Player)
    if not Player or Player == LocalPlayer or not Player.Parent then return false end

    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    if not Character or not Humanoid or Humanoid.Health <= 0 or not Root then return false end

    if type(IsRageDowned) == "function" then
        local Success, Downed = pcall(IsRageDowned, Player)
        if Success and Downed then return false end
    end

    return true
end

function GetRadiantHUDTarget()
    if RageBotEnabled and IsRadiantHUDTargetValid(RageBotCurrentTarget) then
        return RageBotCurrentTarget, "RAGE"
    end

    local AimTarget = S and S.AimBot and (S.AimBot.CurrentTarget or S.AimBot.Target)
    if S and S.AimBot and S.AimBot.Enabled and IsRadiantHUDTargetValid(AimTarget) then
        return AimTarget, "AIM"
    end

    return nil, nil
end

function SyncRadiantESPPreview()
    local Widgets = VisualState.Widgets
    local Preview = Widgets and Widgets.ESPPreview
    if not Preview then return end

    local MenuOpen = Widgets.MenuWindow and Widgets.MenuWindow.IsOpen == true
    local Visible = Widgets.ESPPreviewEnabled and MenuOpen

    Preview:SetVisibility(Visible)
    if not Visible then return end

    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local Tool = Character and Character:FindFirstChildOfClass("Tool")

    Preview:SetEnabled(VisualState.Player.Enabled)
    Preview:SetCharacter(Character)
    Preview:Apply(VisualState.Player, {
        Name = LocalPlayer.DisplayName or LocalPlayer.Name,
        Distance = "[24m]",
        Weapon = Tool and Tool.Name or "Unarmed",
        Health = Humanoid and Humanoid.Health or 0,
        MaxHealth = Humanoid and Humanoid.MaxHealth or 100
    })
end

function UpdateRadiantTargetHUD()
    local Widgets = VisualState.Widgets
    local HUD = Widgets and Widgets.TargetHUD
    if not HUD then return end

    HUD:SetFollowTarget(Widgets.TargetHUDFollowTarget)

    local MenuOpen = Widgets.MenuWindow and Widgets.MenuWindow.IsOpen == true
    if not Widgets.TargetHUDEnabled then
        HUD:SetPreviewMode(false)
        HUD:SetVisibility(false)
        Widgets.LastTarget = nil
        Widgets.LastMode = nil
        Widgets.LastInfo = nil
        return
    end

    if MenuOpen then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Tool = Character and Character:FindFirstChildOfClass("Tool")
        local Health = Humanoid and Humanoid.Health or 100
        local MaxHealth = Humanoid and Humanoid.MaxHealth or 100
        local Info = tostring(Tool and Tool.Name or "Unarmed")

        HUD:SetPreviewMode(true)
        HUD:SetVisibility(true)

        if Widgets.LastTarget ~= LocalPlayer or Widgets.LastMode ~= "PREVIEW" then
            Widgets.LastTarget = LocalPlayer
            Widgets.LastMode = "PREVIEW"
            Widgets.LastHealth = Health
            Widgets.LastMaxHealth = MaxHealth
            Widgets.LastInfo = Info
            HUD:SetTarget(LocalPlayer, Health, MaxHealth, Info, "PREVIEW")
        else
            if Widgets.LastHealth ~= Health or Widgets.LastMaxHealth ~= MaxHealth then
                Widgets.LastHealth = Health
                Widgets.LastMaxHealth = MaxHealth
                HUD:SetHealth(Health, MaxHealth)
            end

            if Widgets.LastInfo ~= Info then
                Widgets.LastInfo = Info
                HUD:SetInfo(Info)
            end
        end

        return
    end

    HUD:SetPreviewMode(false)

    local Target, Mode = GetRadiantHUDTarget()
    if not Target then
        HUD:SetVisibility(false)
        Widgets.LastTarget = nil
        Widgets.LastMode = nil
        return
    end

    local Character = Target.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local Root = Character and Character:FindFirstChild("HumanoidRootPart")
    local Head = Character and Character:FindFirstChild("Head")
    local LocalRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or Humanoid.Health <= 0 or not Root then
        HUD:SetVisibility(false)
        Widgets.LastTarget = nil
        Widgets.LastMode = nil
        return
    end

    if Widgets.TargetHUDFollowTarget then
        local CameraObject = GetCamera()
        local FollowPart = Head or Root

        if not CameraObject or not FollowPart then
            HUD:SetVisibility(false)
            return
        end

        local ScreenPosition, OnScreen = CameraObject:WorldToViewportPoint(FollowPart.Position)
        if not OnScreen or ScreenPosition.Z <= 0 then
            HUD:SetVisibility(false)
            return
        end

        HUD:SetFollowScreenPosition(
            Vector2.new(ScreenPosition.X, ScreenPosition.Y),
            CameraObject.ViewportSize,
            Vector2.new(0, -54)
        )
    end

    local Distance = LocalRoot and math.floor((Root.Position - LocalRoot.Position).Magnitude + 0.5) or 0
    local Armor = GetRadiantArmorValue(Character)
    local Weapon = GetRadiantTargetWeapon(Character)
    local Info = string.format("%dm  •  Armor %d  •  %s", Distance, Armor, Weapon)

    HUD:SetVisibility(true)

    if Widgets.LastTarget ~= Target or Widgets.LastMode ~= Mode then
        Widgets.LastTarget = Target
        Widgets.LastMode = Mode
        Widgets.LastHealth = Humanoid.Health
        Widgets.LastMaxHealth = Humanoid.MaxHealth
        Widgets.LastInfo = Info
        HUD:SetTarget(Target, Humanoid.Health, Humanoid.MaxHealth, Info, Mode)
        return
    end

    if Widgets.LastHealth ~= Humanoid.Health or Widgets.LastMaxHealth ~= Humanoid.MaxHealth then
        Widgets.LastHealth = Humanoid.Health
        Widgets.LastMaxHealth = Humanoid.MaxHealth
        HUD:SetHealth(Humanoid.Health, Humanoid.MaxHealth)
    end

    if Widgets.LastInfo ~= Info then
        Widgets.LastInfo = Info
        HUD:SetInfo(Info)
    end
end

function CreateRadiantVisualWidgets()
    local Widgets = VisualState.Widgets
    if not Widgets then return end

    if Widgets.ESPPreview then Widgets.ESPPreview:Destroy() end
    if Widgets.TargetHUD then Widgets.TargetHUD:Destroy() end
    if Widgets.UpdateConnection then Widgets.UpdateConnection:Disconnect() end

    Widgets.ESPPreview = nil
    Widgets.TargetHUD = nil
    Widgets.UpdateConnection = nil
    Widgets.LastTarget = nil

    if type(Library.ESPPreview) ~= "function" or type(Library.TargetHUD) ~= "function" then
        Library:Notification("Library.lua needs ESPPreview and TargetHUD methods", 5, Color3.fromRGB(255, 90, 90))
        return
    end

    Widgets.ESPPreview = Library:ESPPreview({
        Title = "ESP Preview",
        Visible = Widgets.ESPPreviewEnabled and Widgets.MenuWindow and Widgets.MenuWindow.IsOpen == true,
        Position = UDim2.new(1, -290, 0.5, -205),
        Character = LocalPlayer.Character,
        Settings = VisualState.Player,
        Name = LocalPlayer.DisplayName or LocalPlayer.Name
    })

    Widgets.TargetHUD = Library:TargetHUD({
        Visible = false,
        FollowTarget = Widgets.TargetHUDFollowTarget,
        Position = UDim2.new(0.5, 0, 1, -92),
        Size = UDim2.new(0, 282, 0, 78),
        FollowSize = UDim2.new(0, 190, 0, 54)
    })

    SyncRadiantESPPreview()

    local Accumulator = 0
    Widgets.UpdateConnection = RunService.Heartbeat:Connect(function(DeltaTime)
        Accumulator = Accumulator + DeltaTime
        if Accumulator < 0.08 then return end
        Accumulator = 0

        SyncRadiantESPPreview()
        UpdateRadiantTargetHUD()
    end)
end

function DestroyRadiantVisualWidgets()
    local Widgets = VisualState.Widgets
    if not Widgets then return end

    if Widgets.UpdateConnection then
        Widgets.UpdateConnection:Disconnect()
        Widgets.UpdateConnection = nil
    end

    if Widgets.ESPPreview then
        Widgets.ESPPreview:Destroy()
        Widgets.ESPPreview = nil
    end

    if Widgets.TargetHUD then
        Widgets.TargetHUD:Destroy()
        Widgets.TargetHUD = nil
    end

    Widgets.LastTarget = nil
    Widgets.LastMode = nil
    Widgets.MenuWindow = nil
end

function BuildRadiantMenu()
    local Window = Library:Window({ Name = "radiant.rip", Size = UDim2.new(0, 560, 0, 600), FadeSpeed = 0.12 })
    VisualState.Widgets.MenuWindow = Window
    local Watermark = CreateRadiantWatermark()
    local KeybindList = Library:KeybindList()
    Library.MenuKeybind = Enum.KeyCode.Delete
    Watermark:SetVisibility(true)
    KeybindList:SetVisibility(false)
    local Combat = Window:Page({ Name = "Combat", Columns = 2, Subtabs = false })
    local Visuals = Window:Page({ Name = "Visuals", Columns = 2, Subtabs = false })
    local Movement = Window:Page({ Name = "Movement", Columns = 2, Subtabs = false })
    local Farming = Window:Page({ Name = "Farm", Columns = 2, Subtabs = false })
    local Misc = Window:Page({ Name = "Misc", Columns = 2, Subtabs = false })
    local Settings = Window:Page({ Name = "Settings", Columns = 2, Subtabs = false })
    local AimSection = Combat:Section({ Name = "Aim", Side = 1 })
    AimSection:Toggle({ Name = "Enabled", Flag = "Aim Enabled", Default = false, Callback = function(Value)
        ToggleAimBot(Value)
    end }):Keybind({ Name = "Aim Key", Flag = "Aim Bind", Default = nil, Mode = "Toggle", Callback = function()
    end })
    AimSection:Dropdown({ Name = "Target Part", Flag = "Aim Target Part", Default = S.AimBot.TargetPart, Items = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, Callback = function(Value)
        S.AimBot.TargetPart = Value
    end })
    AimSection:Toggle({ Name = "Wall Check", Flag = "Aim Wall Check", Default = S.AimBot.WallCheck, Callback = function(Value) S.AimBot.WallCheck = Value end })
    AimSection:Toggle({ Name = "Downed Check", Flag = "Aim Downed Check", Default = S.AimBot.DownedCheck, Callback = function(Value) S.AimBot.DownedCheck = Value end })
    AimSection:Toggle({ Name = "Sticky Target", Flag = "Aim Sticky", Default = S.AimBot.Sticky, Callback = function(Value)
        S.AimBot.Sticky = Value
        S.AimBot.Target = nil
    end })
    AimSection:Slider({ Name = "FOV", Flag = "Aim FOV", Min = 10, Max = 700, Default = S.AimBot.FOV, Decimals = 1, Suffix = " px", Callback = function(Value) S.AimBot.FOV = Value end })
    AimSection:Slider({ Name = "Smoothness", Flag = "Aim Smoothness", Min = 0.01, Max = 1, Default = S.AimBot.Smoothness, Decimals = 0.01, Callback = function(Value)
        S.AimBot.Smoothness = Value
    end })
    AimSection:Slider({ Name = "Prediction", Flag = "Aim Prediction", Min = 0, Max = 300, Default = S.AimBot.Prediction, Decimals = 1, Suffix = "%", Callback = function(Value)
        S.AimBot.Prediction = Value
    end })
    local AimVisualSection = Combat:Section({ Name = "Aim Display", Side = 1 })
    AimVisualSection:Toggle({ Name = "Show FOV", Flag = "Show Aim FOV", Default = S.AimBot.ShowFOV, Callback = function(Value)
        S.AimBot.ShowFOV = Value
        if Value and S.AimBot.Enabled and not S.AimBot.FOVCircle then
            CreateFOVCircle()
        elseif S.AimBot.FOVCircle then
            S.AimBot.FOVCircle.Visible = Value and S.AimBot.Enabled
        end
    end }):Colorpicker({ Name = "FOV Color", Flag = "Aim FOV Color", Default = S.AimBot.FOVColor, Callback = function(Value)
        S.AimBot.FOVColor = Value
        if S.AimBot.FOVCircle then S.AimBot.FOVCircle.Color = Value end
    end })
    AimVisualSection:Toggle({ Name = "FOV Glow", Flag = "Aim FOV Glow", Default = S.AimBot.FOVGlow, Callback = function(Value)
        S.AimBot.FOVGlow = Value
        if S.AimBot.Enabled and S.AimBot.ShowFOV then CreateFOVCircle() end
    end }):Colorpicker({ Name = "Glow Color", Flag = "Aim FOV Glow Color", Default = S.AimBot.FOVGlowColor, Callback = function(Value)
        S.AimBot.FOVGlowColor = Value
        if S.AimBot.FOVGlowCircle then S.AimBot.FOVGlowCircle.Color = Value end
    end })
    AimVisualSection:Slider({ Name = "Glow Thickness", Flag = "Aim FOV Glow Thickness", Min = 3, Max = 24, Default = S.AimBot.FOVGlowThickness, Decimals = 1, Suffix = " px", Callback = function(Value)
        S.AimBot.FOVGlowThickness = Value
        if S.AimBot.FOVGlowCircle then S.AimBot.FOVGlowCircle.Thickness = Value end
    end })
    AimVisualSection:Slider({ Name = "Glow Transparency", Flag = "Aim FOV Glow Transparency", Min = 0, Max = 1, Default = S.AimBot.FOVGlowTransparency, Decimals = 0.05, Callback = function(Value)
        S.AimBot.FOVGlowTransparency = Value
        if S.AimBot.FOVGlowCircle then S.AimBot.FOVGlowCircle.Transparency = Value end
    end })
    AimVisualSection:Slider({ Name = "FOV Transparency", Flag = "Aim FOV Transparency", Min = 0, Max = 1, Default = S.AimBot.FOVTransparency, Decimals = 0.05, Callback = function(Value)
        S.AimBot.FOVTransparency = Value
        if S.AimBot.FOVCircle then S.AimBot.FOVCircle.Transparency = Value end
    end })
    local RageSection = Combat:Section({ Name = "Rage", Side = 2 })
    RageSection:Toggle({ Name = "Enabled", Flag = "Rage Bot", Default = RageBotEnabled, Callback = function(Value)
        if Value then
            RageBotEnable()
        else
            RageBotDisable()
        end
    end }):Keybind({ Name = "Rage Key", Flag = "Rage Bind", Default = nil, Mode = "Toggle", Callback = function()
    end })
    RageSection:Toggle({ Name = "Auto Reload", Flag = "Rage Auto Reload", Default = RageBotSettings.AutoReload, Callback = function(Value) RageBotSettings.AutoReload = Value end })
    RageSection:Dropdown({ Name = "Target Mode", Flag = "Rage Target Mode", Default = RageBotSettings.TargetMode, Items = { "Nearest", "FOV" }, Callback = function(Value)
        RageBotSettings.TargetMode = Value
    end })
    RageSection:Dropdown({ Name = "Target Part", Flag = "Rage Target Part", Default = RageBotSettings.TargetPart, Items = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, Callback = function(Value)
        RageBotSettings.TargetPart = Value
        RageBotStickyTarget = nil
    end })
    RageSection:Dropdown({ Name = "FOV Origin", Flag = "Rage FOV Origin", Default = RageBotSettings.FOVOrigin, Items = { "Center", "Mouse" }, Callback = function(Value)
        RageBotSettings.FOVOrigin = Value
    end })
    RageSection:Toggle({ Name = "Team Check", Flag = "Rage Team Check", Default = RageBotSettings.CheckTeam, Callback = function(Value) RageBotSettings.CheckTeam = Value end })
    RageSection:Toggle({ Name = "Whitelist Check", Flag = "Rage Whitelist Check", Default = RageBotSettings.CheckWhitelist, Callback = function(Value)
        RageBotSettings.CheckWhitelist = Value
    end })
    RageSection:Slider({ Name = "FOV", Flag = "Rage FOV", Min = 25, Max = 700, Default = RageBotSettings.FOV, Decimals = 1, Suffix = " px", Callback = function(Value)
        RageBotSettings.FOV = Value
    end })
    RageSection:Toggle({ Name = "Show FOV", Flag = "Rage Show FOV", Default = RageBotSettings.ShowFOV, Callback = function(Value)
        RageBotSettings.ShowFOV = Value
    end }):Colorpicker({ Name = "FOV Color", Flag = "Rage FOV Color", Default = RageBotSettings.FOVColor, Callback = function(Value) RageBotSettings.FOVColor = Value end })
    RageSection:Slider({ Name = "Prediction", Flag = "Rage Prediction", Min = 0, Max = 0.45, Default = RageBotSettings.Prediction, Decimals = 0.01, Suffix = "s", Callback = function(Value)
        RageBotSettings.Prediction = Value
    end })
    RageSection:Toggle({ Name = "Wall Check", Flag = "Rage Wall Check", Default = RageBotSettings.WallCheck, Callback = function(Value) RageBotSettings.WallCheck = Value end })
    RageSection:Toggle({ Name = "Sticky Target", Flag = "Rage Sticky", Default = RageBotSettings.Sticky, Callback = function(Value)
        RageBotSettings.Sticky = Value
        if not Value then RageBotStickyTarget = nil end
    end })
    RageSection:Dropdown({ Name = "Origin Mode", Flag = "Rage Origin Mode", Default = RageBotSettings.OriginMode, Items = { "Camera", "Root" }, Callback = function(Value)
        RageBotSettings.OriginMode = Value
    end })
    RageSection:Dropdown({ Name = "Bullet Direction", Flag = "Rage Bullet Direction", Default = RageBotSettings.BulletDirection, Items = { "Direct", "Up" }, Callback = function(Value)
        RageBotSettings.BulletDirection = Value
    end })
    RageSection:Slider({ Name = "Max Distance", Flag = "Rage Max Distance", Min = 100, Max = 2500, Default = RageBotSettings.MaxDistance, Decimals = 50, Suffix = " studs", Callback = function(Value)
        RageBotSettings.MaxDistance = Value
    end })
    local WhitelistInput = ""
    local WhitelistSection = Combat:Section({ Name = "Target Filters", Side = 2 })
    WhitelistSection:Textbox({ Name = "Player Name", Flag = "Whitelist Player", Placeholder = "username", Callback = function(Value) WhitelistInput = tostring(Value) end })
    WhitelistSection:Button({ Name = "Add Player", Callback = function()
        if WhitelistInput == "" then return end
        if not table.find(WhitelistTable, WhitelistInput) then table.insert(WhitelistTable, WhitelistInput) end
    end })
    WhitelistSection:Button({ Name = "Remove Player", Callback = function()
        local Index = table.find(WhitelistTable, WhitelistInput)
        if Index then table.remove(WhitelistTable, Index) end
    end })
    WhitelistSection:Button({ Name = "Clear Whitelist", Callback = function() WhitelistTable = {} end })
    local WeaponSection = Combat:Section({ Name = "Weapon", Side = 2 })
    WeaponSection:Toggle({ Name = "Weapon Mods", Flag = "Weapon Mods", Default = S.NoRecoil.Enabled, Callback = function(Value) ToggleNoRecoil(Value) end })
    WeaponSection:Toggle({ Name = "Remove Recoil", Flag = "Remove Recoil", Default = S.NoRecoil.Settings.GunMods.NoRecoil, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.NoRecoil = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Toggle({ Name = "Modify Spread", Flag = "Modify Spread", Default = S.NoRecoil.Settings.GunMods.Spread, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.Spread = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Slider({ Name = "Spread Amount", Flag = "Spread Amount", Min = 0, Max = 5, Default = S.NoRecoil.Settings.GunMods.SpreadAmount, Decimals = 0.05, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.SpreadAmount = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Toggle({ Name = "Remove Crosshair Expansion", Flag = "Remove Crosshair Expansion", Default = S.NoRecoil.Settings.GunMods.NoCrosshair, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.NoCrosshair = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Toggle({ Name = "Rapid Fire", Flag = "Rapid Fire", Default = S.NoRecoil.Settings.GunMods.RapidFire, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.RapidFire = Value == true
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Slider({ Name = "Fire Delay", Flag = "Rapid Fire Delay", Min = 0.01, Max = 0.5, Default = S.NoRecoil.Settings.GunMods.RapidFireDelay, Decimals = 0.01, Suffix = "s", Callback = function(Value)
        S.NoRecoil.Settings.GunMods.RapidFireDelay = math.clamp(tonumber(Value) or 0.10, 0.01, 0.5)
        if S.NoRecoil.Enabled and S.NoRecoil.Settings.GunMods.RapidFire then RefreshGunModsNR() end
    end })

    local AuraSection = Combat:Section({ Name = "Combat Automation", Side = 2 })
    AuraSection:Toggle({ Name = "Crowbar Aura", Flag = "Crowbar Aura", Default = CrowbarAuraEnabled, Callback = function(Value)
        if Value then
            CrowbarAuraEnable()
        else
            CrowbarAuraDisable()
        end
    end })
    AuraSection:Toggle({ Name = "Melee Aura", Flag = "Melee Aura", Default = MeleeAuraEnabled, Callback = function(Value)
        if Value then
            MeleeAuraEnable()
        else
            MeleeAuraDisable()
        end
    end })
    AuraSection:Toggle({ Name = "Finish Aura", Flag = "Finish Aura", Default = FinishAuraEnabled, Callback = function(Value)
        if Value then
            FinishAuraEnable()
        else
            FinishAuraDisable()
        end
    end })
    local SafeFarmSection = Farming:Section({ Name = "Safe Farm", Side = 1 })
    SafeFarmSection:Toggle({ Name = "Enabled", Flag = "Safe Farm", Default = SafeFarmEnabled, Callback = function(Value)
        if Value then
            SafeFarmEnable()
        else
            SafeFarmDisable()
        end
    end })
    SafeFarmSection:Dropdown({ Name = "Breaking Method", Flag = "Safe Farm Breaking Method", Options = { "Crowbar", "Fist + Lockpick" }, Default = RadiantFarmModule.Settings.BreakingMethod,
        Callback = function(Value)
        RadiantFarmModule.SetSetting("BreakingMethod", Value)
    end })
    SafeFarmSection:Slider({ Name = "Move Speed", Flag = "Safe Farm Speed", Min = 10, Max = 45, Default = RadiantFarmModule.Settings.MoveSpeed, Decimals = 1, Callback = function(Value)
        RadiantFarmModule.SetSetting("MoveSpeed", math.clamp(tonumber(Value) or 32, 10, 45))
    end })
    SafeFarmSection:Label({ Name = "Farm cash options are below. Safety options are in Movement.", Alignment = "Left" })
    local FarmAutomationSection = Farming:Section({ Name = "Farm Automation", Side = 1 })
    FarmAutomationSection:Toggle({ Name = "Collect Farm Cash", Flag = "Safe Farm Auto Money", Default = RadiantFarmModule.Settings.AutoMoney, Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoMoney", Value == true)
    end })
    FarmAutomationSection:Toggle({ Name = "Deposit Farm Cash", Flag = "Safe Farm Auto Deposit", Default = RadiantFarmModule.Settings.AutoDeposit, Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoDeposit", Value == true)
    end })
    FarmAutomationSection:Slider({ Name = "Deposit Threshold", Flag = "Safe Farm Deposit At", Min = 1, Max = 100, Default = RadiantFarmModule.Settings.AutoDepositThresholdK, Decimals = 1,
        Suffix = "k", Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoDepositThresholdK", math.clamp(tonumber(Value) or 5, 1, 100))
    end })
    FarmAutomationSection:Toggle({ Name = "Claim Allowance", Flag = "Safe Farm Auto Allowance", Default = RadiantFarmModule.Settings.AutoAllowance, Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoAllowance", Value == true)
    end })
    local MoneySection = Farming:Section({ Name = "Money Utilities", Side = 2 })
    MoneySection:Toggle({ Name = "Nearby Cash Pickup", Flag = "Auto Pickup Money", Default = AutoPickupMoneyEnabled, Callback = function(Value)
        if Value then
            AutoPickupMoneyEnable()
        else
            AutoPickupMoneyDisable()
        end
    end })
    MoneySection:Toggle({ Name = "Fast Cash Pickup", Flag = "Fast Pickup", Default = FastPickupEnabled, Callback = function(Value)
        if Value then
            FastPickupEnable()
        else
            FastPickupDisable()
        end
    end })
    MoneySection:Toggle({ Name = "Automatic ATM", Flag = "Auto ATM", Default = AutoATMEnabled, Callback = function(Value)
        if Value then
            AutoATMEnable()
        else
            AutoATMDisable()
        end
    end })
    MoneySection:Slider({ Name = "ATM Check Interval", Flag = "ATM Interval", Min = 60, Max = 1800, Default = AutoATMInterval, Decimals = 5, Suffix = "s", Callback = function(Value)
        AutoATMInterval = Value
    end })
    local AltFarmSection = Farming:Section({ Name = "Alt Farm", Side = 2 })
    AltFarmSection:Toggle({ Name = "Enabled", Flag = "Alt Farm", Default = AltFarmEnabled, Callback = function(Value)
        if Value then
            AltFarmEnable()
        else
            AltFarmDisable()
        end
    end })
    AltFarmSection:Label({ Name = "Auto Play, respawn and Anti AFK are handled automatically.", Alignment = "Left" })
    local PlayerESPSection = Visuals:Section({ Name = "Player ESP", Side = 1 })
    local PlayerESPToggle = PlayerESPSection:Toggle({ Name = "Enabled", Flag = "Player ESP", Default = VisualState.Player.Enabled, Callback = function(Value)
        VisualState.Player.Enabled = Value
        EnsureVisualEngine()
        if not Value then
            for Unused, Data in ipairs(VisualState.Player.List) do HidePlayerVisual(Data) end
        end
    end })
    PlayerESPToggle:Colorpicker({ Name = "Box Color", Flag = "Player ESP Box Color", Default = VisualState.Player.BoxColor, Callback = function(Value) VisualState.Player.BoxColor = Value end })
    PlayerESPToggle:Keybind({ Name = "ESP Key", Flag = "Player ESP Bind", Default = nil, Mode = "Toggle", Callback = function() end })
    PlayerESPSection:Dropdown({ Name = "Box Style", Flag = "Player ESP Box Style", Default = VisualState.Player.BoxStyle, Items = { "Corners", "Full" }, Callback = function(Value)
        VisualState.Player.BoxStyle = Value
    end })
    PlayerESPSection:Toggle({ Name = "Boxes", Flag = "Player ESP Boxes", Default = VisualState.Player.Boxes, Callback = function(Value)
        VisualState.Player.Boxes = Value
    end }):Colorpicker({ Name = "Outline Color", Flag = "Player ESP Outline Color", Default = VisualState.Player.OutlineColor, Callback = function(Value)
        VisualState.Player.OutlineColor = Value
    end })
    PlayerESPSection:Toggle({ Name = "Box Fill", Flag = "Player ESP Fill", Default = VisualState.Player.Fill, Callback = function(Value)
        VisualState.Player.Fill = Value
    end }):Colorpicker({ Name = "Fill Color", Flag = "Player ESP Fill Color", Default = VisualState.Player.FillColor, Callback = function(Value) VisualState.Player.FillColor = Value end })
    PlayerESPSection:Slider({ Name = "Fill Transparency", Flag = "Player ESP Fill Transparency", Min = 0, Max = 1, Default = VisualState.Player.FillTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.FillTransparency = Value
    end })
    PlayerESPSection:Toggle({ Name = "Names", Flag = "Player ESP Names", Default = VisualState.Player.Names, Callback = function(Value)
        VisualState.Player.Names = Value
    end }):Colorpicker({ Name = "Text Color", Flag = "Player ESP Text Color", Default = VisualState.Player.TextColor, Callback = function(Value) VisualState.Player.TextColor = Value end })
    PlayerESPSection:Toggle({ Name = "Health Bar", Flag = "Player ESP Health Bar", Default = VisualState.Player.HealthBar, Callback = function(Value)
        VisualState.Player.HealthBar = Value
    end }):Colorpicker({ Name = "Healthy Color", Flag = "Player ESP Health High Color", Default = VisualState.Player.HealthHighColor, Callback = function(Value)
        VisualState.Player.HealthHighColor = Value
    end })
    PlayerESPSection:Label({ Name = "Low Health", Alignment = "Left" }):Colorpicker({ Name = "Low Health", Flag = "Player ESP Health Low Color", Default = VisualState.Player.HealthLowColor,
        Callback = function(Value)
        VisualState.Player.HealthLowColor = Value
    end })
    PlayerESPSection:Toggle({ Name = "Health Value", Flag = "Player ESP Health Value", Default = VisualState.Player.HealthText, Callback = function(Value)
        VisualState.Player.HealthText = Value
    end })
    PlayerESPSection:Toggle({ Name = "Distance", Flag = "Player ESP Distance", Default = VisualState.Player.Distance, Callback = function(Value) VisualState.Player.Distance = Value end })
    PlayerESPSection:Toggle({ Name = "Weapon", Flag = "Player ESP Weapon", Default = VisualState.Player.Weapon, Callback = function(Value) VisualState.Player.Weapon = Value end })
    PlayerESPSection:Toggle({ Name = "Team Check", Flag = "Player ESP Team Check", Default = VisualState.Player.TeamCheck, Callback = function(Value)
        VisualState.Player.TeamCheck = Value
    end })
    PlayerESPSection:Slider({ Name = "Text Size", Flag = "Player ESP Text Size", Min = 10, Max = 20, Default = VisualState.Player.TextSize, Decimals = 1, Callback = function(Value)
        VisualState.Player.TextSize = Value
    end })
    PlayerESPSection:Slider({ Name = "Max Distance", Flag = "Player ESP Max Distance", Min = 100, Max = 3000, Default = VisualState.Player.MaxDistance, Decimals = 50, Suffix = " studs",
        Callback = function(Value)
        VisualState.Player.MaxDistance = Value
    end })
    local PlayerTracerSection = Visuals:Section({ Name = "Player Tracers", Side = 1 })
    PlayerTracerSection:Toggle({ Name = "Enabled", Flag = "Player ESP Tracers", Default = VisualState.Player.Tracers, Callback = function(Value)
        VisualState.Player.Tracers = Value
    end }):Colorpicker({ Name = "Color", Flag = "Player ESP Tracer Color", Default = VisualState.Player.TracerColor, Callback = function(Value)
        VisualState.Player.TracerColor = Value
    end })
    PlayerTracerSection:Dropdown({ Name = "Style", Flag = "Player ESP Tracer Style", Default = VisualState.Player.TracerStyle, Items = { "Straight", "Curved" }, Callback = function(Value)
        VisualState.Player.TracerStyle = Value
    end })
    PlayerTracerSection:Dropdown({ Name = "Origin", Flag = "Player ESP Tracer Origin", Default = VisualState.Player.TracerOrigin, Items = { "Top", "Center", "Bottom" }, Callback = function(Value)
        VisualState.Player.TracerOrigin = Value
    end })
    PlayerTracerSection:Dropdown({ Name = "Target", Flag = "Player ESP Tracer End", Default = VisualState.Player.TracerEnd, Items = { "Head", "Body", "Feet" }, Callback = function(Value)
        VisualState.Player.TracerEnd = Value
    end })
    PlayerTracerSection:Slider({ Name = "Thickness", Flag = "Player ESP Tracer Thickness", Min = 1, Max = 4, Default = VisualState.Player.TracerThickness, Decimals = 0.5, Callback = function(Value)
        VisualState.Player.TracerThickness = Value
    end })
    PlayerTracerSection:Slider({ Name = "Transparency", Flag = "Player ESP Tracer Transparency", Min = 0, Max = 0.90, Default = VisualState.Player.TracerTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.TracerTransparency = Value
    end })

    local SnaplineSection = Visuals:Section({ Name = "Snaplines", Side = 2 })
    SnaplineSection:Toggle({ Name = "Enabled", Flag = "Target Snapline", Default = VisualState.Snapline.Enabled, Callback = function(Value)
        VisualState.Snapline.Enabled = Value == true
        EnsureVisualEngine()
        if not VisualState.Snapline.Enabled then HideTargetSnapline() end
    end }):Colorpicker({ Name = "Color", Flag = "Target Snapline Color", Default = VisualState.Snapline.Color, Callback = function(Value)
        VisualState.Snapline.Color = Value
    end })
    SnaplineSection:Dropdown({ Name = "Source", Flag = "Target Snapline Source", Default = VisualState.Snapline.Source, Items = { "Combat Target", "Closest to Cursor" }, Callback = function(Value)
        VisualState.Snapline.Source = Value
    end })
    SnaplineSection:Dropdown({ Name = "Target", Flag = "Target Snapline Part", Default = VisualState.Snapline.TargetPart, Items = { "Head", "Body", "Feet" }, Callback = function(Value)
        VisualState.Snapline.TargetPart = Value
    end })
    SnaplineSection:Dropdown({ Name = "Style", Flag = "Target Snapline Style", Default = VisualState.Snapline.Style, Items = { "Straight", "Curved" }, Callback = function(Value)
        VisualState.Snapline.Style = Value
    end })
    SnaplineSection:Slider({ Name = "Thickness", Flag = "Target Snapline Thickness", Min = 1, Max = 4, Default = VisualState.Snapline.Thickness, Decimals = 0.5, Callback = function(Value)
        VisualState.Snapline.Thickness = Value
    end })
    SnaplineSection:Slider({ Name = "Transparency", Flag = "Target Snapline Transparency", Min = 0, Max = 0.90, Default = VisualState.Snapline.Transparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Snapline.Transparency = Value
    end })

    local PreviewHUDSection = Visuals:Section({ Name = "ESP Preview & Target HUD", Side = 2 })
    PreviewHUDSection:Toggle({ Name = "ESP Preview", Flag = "ESP Preview", Default = VisualState.Widgets.ESPPreviewEnabled, Callback = function(Value)
        VisualState.Widgets.ESPPreviewEnabled = Value == true
        SyncRadiantESPPreview()
    end })
    PreviewHUDSection:Toggle({ Name = "Target HUD", Flag = "Target HUD", Default = VisualState.Widgets.TargetHUDEnabled, Callback = function(Value)
        VisualState.Widgets.TargetHUDEnabled = Value == true
        UpdateRadiantTargetHUD()
    end })
    PreviewHUDSection:Toggle({ Name = "Follow Target", Flag = "Target HUD Follow Target", Default = VisualState.Widgets.TargetHUDFollowTarget, Callback = function(Value)
        VisualState.Widgets.TargetHUDFollowTarget = Value == true
        if VisualState.Widgets.TargetHUD then
            VisualState.Widgets.TargetHUD:SetFollowTarget(VisualState.Widgets.TargetHUDFollowTarget)
        end
    end })
    PreviewHUDSection:Label({ Name = "Open menu to preview and drag Target HUD", Alignment = "Left" })

    CreateRadiantVisualWidgets()

    local BulletTracerSection = Visuals:Section({ Name = "Bullet Tracers", Side = 1 })
    BulletTracerSection:Toggle({ Name = "Enabled", Flag = "Bullet Tracers", Default = HitFeedbackState.BulletTracerEnabled, Callback = function(Value)
        HitFeedbackState.BulletTracerEnabled = Value == true
        SetBulletTracerShotHookEnabled(HitFeedbackState.BulletTracerEnabled)
        if not HitFeedbackState.BulletTracerEnabled then ClearBulletTracers() end
    end }):Colorpicker({ Name = "Color", Flag = "Bullet Tracer Color", Default = HitFeedbackState.BulletTracerColor, Callback = function(Value)
        HitFeedbackState.BulletTracerColor = Value
    end })
    BulletTracerSection:Dropdown({ Name = "Style", Flag = "Bullet Tracer Style", Default = HitFeedbackState.BulletTracerStyle, Items = { "Clean", "Energy", "Pulse" }, Callback = function(Value)
        HitFeedbackState.BulletTracerStyle = Value
    end })
    BulletTracerSection:Slider({ Name = "Time", Flag = "Bullet Tracer Time", Min = 0.05, Max = 2, Default = HitFeedbackState.BulletTracerTime, Decimals = 0.05, Suffix = " s", Callback = function(Value)
        HitFeedbackState.BulletTracerTime = Value
    end })
    BulletTracerSection:Slider({ Name = "VFX Rate", Flag = "Bullet Tracer Rate", Min = 0, Max = 120, Default = HitFeedbackState.BulletTracerRate, Decimals = 1, Suffix = " p/s", Callback = function(Value)
        HitFeedbackState.BulletTracerRate = Value
    end })
    BulletTracerSection:Slider({ Name = "Width", Flag = "Bullet Tracer Width", Min = 0.01, Max = 0.5, Default = HitFeedbackState.BulletTracerWidth, Decimals = 0.01, Suffix = " studs",
        Callback = function(Value)
        HitFeedbackState.BulletTracerWidth = Value
    end })
    BulletTracerSection:Slider({ Name = "Glow", Flag = "Bullet Tracer Glow", Min = 0, Max = 5, Default = HitFeedbackState.BulletTracerGlow, Decimals = 0.25, Callback = function(Value)
        HitFeedbackState.BulletTracerGlow = Value
    end })
    local ImpactSection = Visuals:Section({ Name = "Bullet Impacts", Side = 1 })
    ImpactSection:Toggle({ Name = "Impact Ghost", Flag = "Impact Ghost", Default = HitFeedbackState.ImpactEnabled, Callback = function(Value)
        HitFeedbackState.ImpactEnabled = Value
    end }):Colorpicker({ Name = "Impact Color", Flag = "Impact Color", Default = HitFeedbackState.ImpactColor, Callback = function(Value) HitFeedbackState.ImpactColor = Value end })
    ImpactSection:Dropdown({ Name = "Impact Style", Flag = "Impact Style", Default = HitFeedbackState.ImpactStyle, Items = { "Character", "Ball", "Cylinder", "Block" }, Callback = function(Value)
        HitFeedbackState.ImpactStyle = Value
    end })
    ImpactSection:Slider({ Name = "Impact Transparency", Flag = "Impact Transparency", Min = 0, Max = 0.95, Default = HitFeedbackState.ImpactTransparency, Decimals = 0.05, Callback = function(Value)
        HitFeedbackState.ImpactTransparency = Value
    end })
    local DamageIndicatorSection = Visuals:Section({ Name = "Damage Indicator", Side = 1 })
    DamageIndicatorSection:Toggle({ Name = "Enabled", Flag = "Damage Indicator", Default = HitFeedbackState.DamageIndicatorEnabled, Callback = function(Value)
        HitFeedbackState.DamageIndicatorEnabled = Value
    end }):Colorpicker({ Name = "Body Damage Color", Flag = "Damage Indicator Body Color", Default = HitFeedbackState.DamageColor, Callback = function(Value)
        HitFeedbackState.DamageColor = Value
    end })
    DamageIndicatorSection:Label({ Name = "Headshot Damage Color", Alignment = "Left" }):Colorpicker({ Name = "Headshot Damage Color", Flag = "Damage Indicator Headshot Color", Default =
        HitFeedbackState.HeadshotDamageColor, Callback = function(Value)
        HitFeedbackState.HeadshotDamageColor = Value
    end })
    DamageIndicatorSection:Slider({ Name = "Text Size", Flag = "Damage Indicator Text Size", Min = 10, Max = 30, Default = HitFeedbackState.DamageTextSize, Decimals = 1, Callback = function(Value)
        HitFeedbackState.DamageTextSize = Value
    end })
    DamageIndicatorSection:Slider({ Name = "Duration", Flag = "Damage Indicator Duration", Min = 0.20, Max = 2, Default = HitFeedbackState.DamageDuration, Decimals = 0.05, Suffix = " s",
        Callback = function(Value)
        HitFeedbackState.DamageDuration = Value
    end })
    DamageIndicatorSection:Slider({ Name = "Rise", Flag = "Damage Indicator Rise", Min = 0.5, Max = 6, Default = HitFeedbackState.DamageRise, Decimals = 0.1, Suffix = " studs", Callback = function(Value)
        HitFeedbackState.DamageRise = Value
    end })
    local ChamsSection = Visuals:Section({ Name = "Player Chams", Side = 2 })
    ChamsSection:Toggle({ Name = "Enabled", Flag = "Player Chams", Default = VisualState.Player.Chams.Enabled, Callback = function(Value)
        VisualState.Player.Chams.Enabled = Value
        EnsureVisualEngine()
        UpdatePlayerChams()
    end }):Colorpicker({ Name = "Fill Color", Flag = "Player Chams Fill", Default = VisualState.Player.Chams.FillColor, Callback = function(Value)
        VisualState.Player.Chams.FillColor = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Label({ Name = "Outline", Alignment = "Left" }):Colorpicker({ Name = "Outline Color", Flag = "Player Chams Outline", Default = VisualState.Player.Chams.OutlineColor,
        Callback = function(Value)
        VisualState.Player.Chams.OutlineColor = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Toggle({ Name = "Through Walls", Flag = "Player Chams Through Walls", Default = VisualState.Player.Chams.ThroughWalls, Callback = function(Value)
        VisualState.Player.Chams.ThroughWalls = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Toggle({ Name = "Glow", Flag = "Player Chams Glow", Default = VisualState.Player.Chams.GlowEnabled, Callback = function(Value)
        VisualState.Player.Chams.GlowEnabled = Value
        UpdatePlayerChams()
    end }):Colorpicker({ Name = "Glow Color", Flag = "Player Chams Glow Color", Default = VisualState.Player.Chams.GlowColor, Callback = function(Value)
        VisualState.Player.Chams.GlowColor = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Slider({ Name = "Fill Transparency", Flag = "Player Chams Fill Transparency", Min = 0, Max = 1, Default = VisualState.Player.Chams.FillTransparency, Decimals = 0.05,
        Callback = function(Value)
        VisualState.Player.Chams.FillTransparency = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Slider({ Name = "Outline Transparency", Flag = "Player Chams Outline Transparency", Min = 0, Max = 1, Default = VisualState.Player.Chams.OutlineTransparency, Decimals = 0.05,
        Callback = function(Value)
        VisualState.Player.Chams.OutlineTransparency = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Slider({ Name = "Glow Transparency", Flag = "Player Chams Glow Transparency", Min = 0, Max = 1, Default = VisualState.Player.Chams.GlowTransparency, Decimals = 0.05,
        Callback = function(Value)
        VisualState.Player.Chams.GlowTransparency = Value
        UpdatePlayerChams()
    end })
    local WorldSection = Visuals:Section({ Name = "World Lighting", Side = 2 })
    WorldSection:Toggle({ Name = "Override Lighting", Flag = "World Override", Default = VisualState.World.Enabled, Callback = function(Value)
        VisualState.World.Enabled = Value
        if Value then
            StartWorldOverride()
        else
            RestoreWorldVisuals()
        end
    end }):Colorpicker({ Name = "Ambient", Flag = "World Ambient", Default = VisualState.World.Ambient, Callback = function(Value)
        VisualState.World.Ambient = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Label({ Name = "Outdoor Ambient", Alignment = "Left" }):Colorpicker({ Name = "Outdoor Ambient", Flag = "World Outdoor Ambient", Default = VisualState.World.OutdoorAmbient,
        Callback = function(Value)
        VisualState.World.OutdoorAmbient = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Label({ Name = "World Tint", Alignment = "Left" }):Colorpicker({ Name = "World Tint", Flag = "World Tint Color", Default = VisualState.World.TintColor, Callback = function(Value)
        VisualState.World.TintColor = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Slider({ Name = "Brightness", Flag = "World Brightness", Min = 0, Max = 5, Default = VisualState.World.Brightness, Decimals = 0.1, Callback = function(Value)
        VisualState.World.Brightness = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Slider({ Name = "Time", Flag = "World Time", Min = 0, Max = 24, Default = VisualState.World.ClockTime, Decimals = 0.5, Suffix = "h", Callback = function(Value)
        VisualState.World.ClockTime = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Toggle({ Name = "Fog", Flag = "World Fog", Default = VisualState.World.FogEnabled, Callback = function(Value)
        VisualState.World.FogEnabled = Value
        ApplyWorldVisuals()
    end }):Colorpicker({ Name = "Fog Color", Flag = "World Fog Color", Default = VisualState.World.FogColor, Callback = function(Value)
        VisualState.World.FogColor = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Slider({ Name = "Fog Distance", Flag = "World Fog Distance", Min = 50, Max = 5000, Default = VisualState.World.FogDistance, Decimals = 50, Suffix = " studs", Callback = function(Value)
        VisualState.World.FogDistance = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Slider({ Name = "Saturation", Flag = "World Saturation", Min = -1, Max = 1, Default = VisualState.World.Saturation, Decimals = 0.05, Callback = function(Value)
        VisualState.World.Saturation = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Slider({ Name = "Contrast", Flag = "World Contrast", Min = -1, Max = 1, Default = VisualState.World.Contrast, Decimals = 0.05, Callback = function(Value)
        VisualState.World.Contrast = Value
        ApplyWorldVisuals()
    end })
    WorldSection:Toggle({ Name = "Bloom", Flag = "World Bloom", Default = VisualState.World.Bloom, Callback = function(Value)
        VisualState.World.Bloom = Value
        ApplyWorldVisuals()
    end })
    local WorldESPSection = Visuals:Section({ Name = "World ESP", Side = 2 })
    WorldESPSection:Toggle({ Name = "Safes", Flag = "World ESP Safes", Default = VisualState.WorldESP.Safes, Callback = function(Value)
        VisualState.WorldESP.Safes = Value
        EnsureVisualEngine()
    end }):Colorpicker({ Name = "Intact Safe Color", Flag = "World ESP Intact Safe Color", Default = VisualState.WorldESP.SafeColor, Callback = function(Value)
        VisualState.WorldESP.SafeColor = Value
    end })
    WorldESPSection:Toggle({ Name = "Cash", Flag = "World ESP Cash", Default = VisualState.WorldESP.Cash, Callback = function(Value)
        VisualState.WorldESP.Cash = Value
        EnsureVisualEngine()
    end }):Colorpicker({ Name = "Cash Color", Flag = "World ESP Cash Color", Default = VisualState.WorldESP.CashColor, Callback = function(Value)
        VisualState.WorldESP.CashColor = Value
    end })
    WorldESPSection:Label({ Name = "Broken Safe Color", Alignment = "Left" }):Colorpicker({ Name = "Broken Safe Color", Flag = "World ESP Broken Safe Color", Default =
        VisualState.WorldESP.BrokenColor, Callback = function(Value)
        VisualState.WorldESP.BrokenColor = Value
    end })
    WorldESPSection:Slider({ Name = "Max Distance", Flag = "World ESP Max Distance", Min = 100, Max = 5000, Default = VisualState.WorldESP.MaxDistance, Decimals = 50, Suffix = " studs",
        Callback = function(Value)
        VisualState.WorldESP.MaxDistance = Value
    end })
    local LocalVisualSection = Visuals:Section({ Name = "Local Player", Side = 1 })
    LocalVisualSection:Toggle({ Name = "Arms Chams", Flag = "Arms Chams", Default = ArmsChamsEnabled, Callback = function(Value)
        if Value then
            ArmsChamsEnable()
        else
            ArmsChamsDisable()
        end
    end }):Colorpicker({ Name = "Arms Color", Flag = "Arms Chams Color", Default = ArmsChamsSettings.ArmColor, Callback = function(Value)
        ArmsChamsSettings.ArmColor = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Dropdown({ Name = "Material", Flag = "Arms Chams Material", Default = ArmsChamsSettings.Material, Items = { "ForceField", "Neon", "SmoothPlastic", "Glass" },
        Callback = function(Value)
        ArmsChamsSettings.Material = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Slider({ Name = "Transparency", Flag = "Arms Chams Transparency", Min = 0, Max = 0.90, Default = ArmsChamsSettings.Transparency, Decimals = 0.02, Callback = function(Value)
        ArmsChamsSettings.Transparency = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Toggle({ Name = "Motion Blur", Flag = "Motion Blur", Default = S.Blur.Enabled, Callback = function(Value) ToggleBlur(Value) end })
    LocalVisualSection:Toggle({ Name = "Hide Body", Flag = "Hide Body", Default = RadiantFarmModule.Settings.HideBody, Callback = function(Value)
        RadiantFarmModule.SetSetting("HideBody", Value == true)
    end })
    local CosmeticsSection = Visuals:Section({ Name = "Cosmetics", Side = 2 })
    CosmeticsSection:Toggle({ Name = "Angel Wings", Flag = "Angel Wings", Default = S.AngelWings.Enabled, Callback = function(Value)
        ToggleAngelWings(Value)
    end }):Colorpicker({ Name = "Feather Color", Flag = "Angel Wing Core Color", Default = S.AngelWings.CoreColor, Callback = function(Value)
        S.AngelWings.CoreColor = Value
        UpdateAngelWingAppearance()
    end })
    CosmeticsSection:Label({ Name = "Wing Glow", Alignment = "Left" }):Colorpicker({ Name = "Wing Glow", Flag = "Angel Wing Glow Color", Default = S.AngelWings.GlowColor, Callback = function(Value)
        S.AngelWings.GlowColor = Value
        UpdateAngelWingAppearance()
    end })
    CosmeticsSection:Slider({ Name = "Wing Size", Flag = "Angel Wing Scale", Min = 0.85, Max = 1.70, Default = S.AngelWings.Scale, Decimals = 0.05, Callback = function(Value)
        S.AngelWings.Scale = Value
        RebuildAngelWings()
    end })
    CosmeticsSection:Slider({ Name = "Wing Height", Flag = "Angel Wing Height", Min = -1, Max = 0.5, Default = S.AngelWings.HeightOffset, Decimals = 0.05, Callback = function(Value)
        S.AngelWings.HeightOffset = Value
        RebuildAngelWings()
    end })
    CosmeticsSection:Slider({ Name = "Wing Back Offset", Flag = "Angel Wing Back Offset", Min = 0.20, Max = 1.40, Default = S.AngelWings.BackOffset, Decimals = 0.05, Callback = function(Value)
        S.AngelWings.BackOffset = Value
        RebuildAngelWings()
    end })
    CosmeticsSection:Slider({ Name = "Wing Transparency", Flag = "Angel Wing Transparency", Min = 0, Max = 0.90, Default = S.AngelWings.Transparency, Decimals = 0.02, Callback = function(Value)
        S.AngelWings.Transparency = Value
        UpdateAngelWingAppearance()
    end })
    CosmeticsSection:Toggle({ Name = "China Hat", Flag = "China Hat", Default = S.ChinaHat.Enabled, Callback = function(Value)
        ToggleChinaHat(Value)
    end }):Colorpicker({ Name = "Hat Color", Flag = "China Hat Color", Default = S.ChinaHat.Color, Callback = function(Value)
        S.ChinaHat.Color = Value
        UpdateChinaHatAppearance()
    end })
    CosmeticsSection:Toggle({ Name = "Hat Rainbow", Flag = "China Hat Rainbow", Default = S.ChinaHat.Rainbow, Callback = function(Value)
        S.ChinaHat.Rainbow = Value
        UpdateChinaHatAppearance()
    end })
    CosmeticsSection:Slider({ Name = "Hat Size", Flag = "China Hat Scale", Min = 0.75, Max = 1.55, Default = S.ChinaHat.Scale, Decimals = 0.05, Callback = function(Value)
        S.ChinaHat.Scale = Value
        RebuildChinaHat()
    end })
    CosmeticsSection:Slider({ Name = "Hat Transparency", Flag = "China Hat Transparency", Min = 0, Max = 0.90, Default = S.ChinaHat.Transparency, Decimals = 0.02, Callback = function(Value)
        S.ChinaHat.Transparency = Value
        UpdateChinaHatAppearance()
    end })
    local MoveSection = Movement:Section({ Name = "Character", Side = 1 })
    MoveSection:Toggle({ Name = "Fly", Flag = "Fly", Default = FlyEnabled, Callback = function(Value)
        if Value then
            FlyEnable()
        else
            FlyDisable()
        end
    end }):Keybind({ Name = "Fly Key", Flag = "Fly Bind", Default = nil, Mode = "Toggle", Callback = function()
    end })
    MoveSection:Dropdown({ Name = "Fly Method", Flag = "Fly Method", Default = FlyMethod, Items = { "Velocity", "Bypass" }, Callback = function(Value)
        FlyMethod = Value
        if FlyEnabled then
            FlyDisable()
            FlyEnable()
        end
    end })
    MoveSection:Toggle({ Name = "Noclip", Flag = "Noclip", Default = NoclipEnabled, Callback = function(Value)
        if Value then
            NoclipEnable()
        else
            NoclipDisable()
        end
    end }):Keybind({ Name = "Noclip Key", Flag = "Noclip Bind", Default = nil, Mode = "Toggle", Callback = function()
    end })
    MoveSection:Toggle({ Name = "Invisibility", Flag = "Invisibility", Default = InvisibilityEnabled, Callback = function(Value)
        if Value then
            InvisibilityEnable()
        else
            InvisibilityDisable()
        end
    end }):Keybind({ Name = "Invisibility Key", Flag = "Invisibility Bind", Default = nil, Mode = "Toggle", Callback = function()
    end })
    MoveSection:Toggle({ Name = "Infinite Stamina", Flag = "Infinite Stamina", Default = InfStaminaEnabled, Callback = function(Value)
        if Value then
            InfStaminaEnable()
        else
            InfStaminaDisable()
        end
    end })
    local CameraSection = Movement:Section({ Name = "Camera", Side = 2 })
    CameraSection:Toggle({ Name = "Freecam", Flag = "Freecam", Default = S.Freecam.Enabled, Callback = function(Value)
        ToggleFreecam(Value)
    end }):Keybind({ Name = "Freecam Key", Flag = "Freecam Bind", Default = nil, Mode = "Toggle", Callback = function()
    end })
    CameraSection:Slider({ Name = "Freecam Speed", Flag = "Freecam Speed", Min = 5, Max = 250, Default = S.Freecam.Speed, Decimals = 1, Callback = function(Value)
        S.Freecam.Speed = Value
    end })
    CameraSection:Slider({ Name = "Look Sensitivity", Flag = "Freecam Sensitivity", Min = 0.05, Max = 0.60, Default = S.Freecam.Sensitivity, Decimals = 0.01, Callback = function(Value)
        S.Freecam.Sensitivity = Value
    end })
    CameraSection:Label({ Name = "RMB look · WASD move · Q/E vertical", Alignment = "Left" })
    local LocationSection = Movement:Section({ Name = "Safe Locations", Side = 2 })
    LocationSection:Toggle({ Name = "Save Cube", Flag = "Save Cube", Default = SafeLocationController:IsEnabled("Cube"), Callback = function(Value)
        SafeLocationController:SetEnabled("Cube", Value)
    end })
    LocationSection:Toggle({ Name = "Save Vibe", Flag = "Save Vibe", Default = SafeLocationController:IsEnabled("Vibe"), Callback = function(Value)
        SafeLocationController:SetEnabled("Vibe", Value)
    end })
    LocationSection:Toggle({ Name = "Save Mount", Flag = "Save Mount", Default = SafeLocationController:IsEnabled("Mount"), Callback = function(Value)
        SafeLocationController:SetEnabled("Mount", Value)
    end })
    local SurvivalSection = Movement:Section({ Name = "Safety", Side = 1 })
    SurvivalSection:Toggle({ Name = "Auto Respawn", Flag = "Auto Respawn", Default = AutoRespawnEnabled or RadiantFarmModule.Settings.AutoRespawn, Callback = function(Value)
        if Value then
            AutoRespawnEnable()
        else
            AutoRespawnDisable()
        end
        RadiantFarmModule.SetSetting("AutoRespawn", Value == true)
    end })
    SurvivalSection:Toggle({ Name = "No Fall Damage", Flag = "No Fall Damage", Default = NoFallDamageEnabled or RadiantFarmModule.Settings.AntiFallDamage, Callback = function(Value)
        if Value then
            NoFallDamageEnable()
        else
            NoFallDamageDisable()
        end
        RadiantFarmModule.SetSetting("AntiFallDamage", Value == true)
    end })
    SurvivalSection:Toggle({ Name = "Anti AFK", Flag = "Anti AFK", Default = AntiAFKEnabled or RadiantFarmModule.Settings.AntiAFK, Callback = function(Value)
        if Value then
            AntiAFKEnable()
        else
            AntiAFKDisable()
        end
        RadiantFarmModule.SetSetting("AntiAFK", Value == true)
    end })
    local InteractionSection = Misc:Section({ Name = "Interaction", Side = 1 })
    InteractionSection:Toggle({ Name = "No Fail Lockpick", Flag = "No Fail Lockpick", Default = NoFailLockpickEnabled, Callback = function(Value)
        if Value then
            NoFailLockpickEnable()
        else
            NoFailLockpickDisable()
        end
    end })
    InteractionSection:Toggle({ Name = "Open Nearby Doors", Flag = "Open Nearby Doors", Default = OpenNearbyDoorsEnabled, Callback = function(Value)
        if Value then
            OpenNearbyDoorsEnable()
        else
            OpenNearbyDoorsDisable()
        end
    end })
    InteractionSection:Toggle({ Name = "Unlock Nearby Doors", Flag = "Unlock Nearby Doors", Default = UnlockNearbyDoorsEnabled, Callback = function(Value)
        if Value then
            UnlockNearbyDoorsEnable()
        else
            UnlockNearbyDoorsDisable()
        end
    end })
    local ServerSafetySection = Misc:Section({ Name = "Server Safety", Side = 2 })
    ServerSafetySection:Toggle({ Name = "Admin Detection", Flag = "Admin Detection", Default = RadiantFarmModule.Settings.AdminCheck, Callback = function(Value)
        RadiantFarmModule.SetSetting("AdminCheck", Value == true)
    end })
    ServerSafetySection:Toggle({ Name = "Reconnect On Error", Flag = "Reconnect On Error", Default = RadiantFarmModule.Settings.AntiRejoin, Callback = function(Value)
        RadiantFarmModule.SetSetting("AntiRejoin", Value == true)
    end })
    local InterfaceSection = Settings:Section({ Name = "Menu", Side = 2 })
    InterfaceSection:Dropdown({ Name = "Theme Preset", Flag = "Theme Preset", Default = "Radiant Emerald", Items = { "Radiant Emerald", "Deep Emerald", "Matrix" }, Callback = function(Value)
        ApplyThemePreset(Value)
    end })
    for Index, Value in pairs(Library.Theme) do
        local ThemeIndex = Index
        local ThemeValue = Value
        InterfaceSection:Label({ Name = ThemeIndex, Alignment = "Left" }):Colorpicker({ Name = ThemeIndex, Default = ThemeValue, Flag = "Theme " .. ThemeIndex, Callback = function(Color)
            Library.Theme[ThemeIndex] = Color
            Library:ChangeTheme(ThemeIndex, Color)
        end })
    end
    InterfaceSection:Label({ Name = "Menu Keybind", Alignment = "Left" }):Keybind({ Name = "Menu Keybind", Flag = "Menu Keybind", Default = Enum.KeyCode.Delete, Mode = "Toggle", Callback = function()
        Library.MenuKeybind = Library.Flags["Menu Keybind"].Key
    end })
    InterfaceSection:Toggle({ Name = "Watermark", Flag = "Watermark", Default = true, Callback = function(Value) Watermark:SetVisibility(Value) end })
    InterfaceSection:Toggle({ Name = "Keybind List", Flag = "Keybind List", Default = false, Callback = function(Value) KeybindList:SetVisibility(Value) end })
    InterfaceSection:Button({ Name = "Unload", Callback = function()
        pcall(function() Watermark:Destroy() end)
        pcall(DisableFreecam)
        S.Freecam.Enabled = false
        pcall(DestroyVisualEngine)
        pcall(RestoreWorldVisuals)
        pcall(function() SafeLocationController:DisableAll() end)
        pcall(function()
            if S.CharacterAddedConnection then
                S.CharacterAddedConnection:Disconnect()
                S.CharacterAddedConnection = nil
            end
        end)
        pcall(function() ToggleAngelWings(false) end)
        pcall(function() ToggleChinaHat(false) end)
        pcall(function()
            if ArmsChamsEnabled then ArmsChamsDisable() end
        end)
        pcall(function()
            if S.Blur.Enabled then ToggleBlur(false) end
        end)
        pcall(InfStaminaDisable)
        pcall(DestroyHitFeedbackRuntime)
        pcall(DestroyRadiantVisualWidgets)
        ResolverState.History = setmetatable({}, { __mode = "k" })
        ResolverState.PoseHistory = setmetatable({}, { __mode = "k" })
        Library:Unload()
    end })
    local ProfilesSection = Settings:Section({ Name = "Configs", Side = 1 })
    local ConfigName = ""
    local ConfigSelected = nil
    local ConfigsListbox = ProfilesSection:Listbox({ Items = {}, Name = "Configs", Flag = "Configs List", Callback = function(Value) ConfigSelected = Value end })
    ProfilesSection:Textbox({ Name = "Config Name", Placeholder = "profile name", Flag = "Config Name", Callback = function(Value) ConfigName = tostring(Value) end })
    local function NormalizeConfigName(Name)
        Name = tostring(Name or "")
        Name = Name:gsub("%.json$", "")
        Name = Name:gsub("[^%w%-%_ ]", "")
        if Name == "" then return nil end
        return Name .. ".json"
    end
    ProfilesSection:Button({ Name = "Create Config", Callback = function()
        local FileName = NormalizeConfigName(ConfigName)
        if not FileName then return end
        local Path = Library.Folders.Configs .. "/" .. FileName
        writefile(Path, Library:GetConfig())
        Library:RefreshConfigsList(ConfigsListbox)
    end })
    ProfilesSection:Button({ Name = "Load Config", Callback = function()
        if not ConfigSelected then return end
        local Path = Library.Folders.Configs .. "/" .. ConfigSelected
        if isfile(Path) then Library:LoadConfig(readfile(Path)) end
    end })
    ProfilesSection:Button({ Name = "Save Config", Callback = function()
        if not ConfigSelected then return end
        local Path = Library.Folders.Configs .. "/" .. ConfigSelected
        writefile(Path, Library:GetConfig())
        Library:Notification("Saved " .. ConfigSelected, 3, Library.Theme.Accent)
    end })
    ProfilesSection:Button({ Name = "Delete Config", Callback = function()
        if not ConfigSelected then return end
        local Path = Library.Folders.Configs .. "/" .. ConfigSelected
        if isfile(Path) then delfile(Path) end
        ConfigSelected = nil
        Library:RefreshConfigsList(ConfigsListbox)
    end })
    ProfilesSection:Button({ Name = "Refresh Configs", Callback = function() Library:RefreshConfigsList(ConfigsListbox) end })
    Library:RefreshConfigsList(ConfigsListbox)
    Library:Notification("radiant.rip loaded", 4, Library.Theme.Accent)
end

BuildRadiantMenu()
if S.CharacterAddedConnection then S.CharacterAddedConnection:Disconnect() end
S.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(Character)
    task.wait(1)
    if FullBrightEnabled then
        if FullBrightLight then
            FullBrightLight:Destroy()
            FullBrightLight = nil
        end
        FullBrightApply()
    end
    if S.ChinaHat.Enabled then CreateChinaHat(Character) end
    if ArmsChamsEnabled then
        task.wait(0.5)
        ArmsChamsEnable()
    end
end)
