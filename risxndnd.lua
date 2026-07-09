if _G.NightfallDrawings then
    for _, DrawingObject in pairs(_G.NightfallDrawings) do
        pcall(function() DrawingObject:Remove() end)
    end
end
_G.NightfallDrawings = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local StatsService = game:GetService("Stats")

local LocalPlayer = PlayersService.LocalPlayer or PlayersService.PlayerAdded:Wait()

local Mouse1Click = mouse1click
local KeyPress = keypress
local KeyRelease = keyrelease

local FastMax = math.max
local FastMin = math.min
local FastFloor = math.floor
local FastClamp = math.clamp
local FastSqrt = math.sqrt
local FastClock = os.clock
local Vector3Zero = Vector3.zero
local TwoPi = math.pi * 2

local function GetDistanceBetween(PositionA, PositionB)
    if not PositionA or not PositionB then return 9999 end
    local Dx = PositionA.X - PositionB.X
    local Dy = PositionA.Y - PositionB.Y
    local Dz = PositionA.Z - PositionB.Z
    return FastSqrt(Dx*Dx + Dy*Dy + Dz*Dz)
end

local function GetVectorMagnitude(Vector)
    if not Vector then return 0 end
    return FastSqrt(Vector.X*Vector.X + Vector.Y*Vector.Y + Vector.Z*Vector.Z)
end

local function NormalizeVector(Vector)
    if not Vector then return Vector3Zero end
    local Magnitude = GetVectorMagnitude(Vector)
    if Magnitude < 0.0001 then return Vector3Zero end
    return Vector.new(Vector.X / Magnitude, Vector.Y / Magnitude, Vector.Z / Magnitude)
end

local function GetDotProduct(VectorA, VectorB)
    if not VectorA or not VectorB then return 0 end
    return VectorA.X*VectorB.X + VectorA.Y*VectorB.Y + VectorA.Z*VectorB.Z
end

local BallPreviousVelocity = {}
local AntiCurveData = {}
local BallVelocityHistory = {}
local BallLastPosition = {}
local BallWarpBoostUntil = {}

local function LerpVector2(A, B, T)
    return Vector2.new(
        A.X + (B.X - A.X) * T,
        A.Y + (B.Y - A.Y) * T
    )
end

local function GetCurveMultiplier(BallInstance, RootPosition, CurrentVelocity)
    if not BallVelocityHistory[BallInstance] then
        BallVelocityHistory[BallInstance] = {}
    end
    local History = BallVelocityHistory[BallInstance]
    table.insert(History, CurrentVelocity)
    if #History > 12 then
        table.remove(History, 1)
    end

    local PreviousVelocity = BallPreviousVelocity[BallInstance]
    if not PreviousVelocity then
        BallPreviousVelocity[BallInstance] = CurrentVelocity
        AntiCurveData[BallInstance] = { 
            SmoothAx = 0, SmoothAy = 0, SmoothAz = 0, 
            Frames = 0, 
            PrevLateral = 0, 
            PrevAngular = 0 
        }
        return 1.0
    end

    local Ax = CurrentVelocity.X - PreviousVelocity.X
    local Ay = CurrentVelocity.Y - PreviousVelocity.Y
    local Az = CurrentVelocity.Z - PreviousVelocity.Z
    BallPreviousVelocity[BallInstance] = CurrentVelocity

    local Data = AntiCurveData[BallInstance]
    Data.SmoothAx = Data.SmoothAx * 0.7 + Ax * 0.3
    Data.SmoothAy = Data.SmoothAy * 0.7 + Ay * 0.3
    Data.SmoothAz = Data.SmoothAz * 0.7 + Az * 0.3

    local AccelerationMagnitude = math.sqrt(Data.SmoothAx^2 + Data.SmoothAy^2 + Data.SmoothAz^2)
    if AccelerationMagnitude < 0.1 then
        Data.Frames = 0
        return 1.0
    end

    local Dx = RootPosition.X - BallInstance.Position.X
    local Dy = RootPosition.Y - BallInstance.Position.Y
    local Dz = RootPosition.Z - BallInstance.Position.Z
    local Distance = math.sqrt(Dx^2 + Dy^2 + Dz^2)
    if Distance < 12 then
        Data.Frames = 0
        return 1.0
    end

    local RadialAcceleration = Data.SmoothAx * (Dx / Distance) + Data.SmoothAy * (Dy / Distance) + Data.SmoothAz * (Dz / Distance)
    local LateralAccelerationSq = math.max(AccelerationMagnitude^2 - RadialAcceleration^2, 0)
    local LateralAcceleration = math.sqrt(LateralAccelerationSq)

    local AngularDeviation = 0
    if #History >= 4 then
        for i = 2, #History do
            local PrevDir = NormalizeVector(History[i-1])
            local CurrDir = NormalizeVector(History[i])
            local DotVal = math.clamp(GetDotProduct(PrevDir, CurrDir), -1, 1)
            local Angle = math.deg(math.acos(DotVal))
            if Angle == Angle then
                AngularDeviation = AngularDeviation + (Angle / 25)
            end
        end
    end

    local LateralTrend = LateralAcceleration - Data.PrevLateral
    local AngularTrend = AngularDeviation - Data.PrevAngular

    Data.PrevLateral = LateralAcceleration
    Data.PrevAngular = AngularDeviation

    local IsStrongCurve = (LateralAcceleration > 38 and RadialAcceleration > -8) or (AngularDeviation > 4.5)
    local IsGrowingCurve = (LateralTrend > 8 and AngularTrend > 1.5) or (LateralAcceleration > 55 and AngularDeviation > 6)

    if IsStrongCurve or IsGrowingCurve then
        Data.Frames = Data.Frames + 1
        if Data.Frames >= 3 then
            local Severity = math.min(LateralAcceleration / 85, 1.2)
            local AngularBoost = math.min(AngularDeviation / 9, 0.9)
            local TrendBoost = 0
            if IsGrowingCurve then
                TrendBoost = math.min((LateralTrend + AngularTrend) / 25, 0.45)
            end
            return 1.0 + (0.65 * Severity) + AngularBoost + TrendBoost
        end
    else
        Data.Frames = 0
    end

    return 1.0
end

local function DetectPositionWarp(BallInstance, DeltaTime)
    if not BallLastPosition[BallInstance] then
        BallLastPosition[BallInstance] = BallInstance.Position
        return false
    end
    local PrevPos = BallLastPosition[BallInstance]
    local PrevVel = BallPreviousVelocity[BallInstance] or Vector3.new(0,0,0)
    if GetVectorMagnitude(PrevVel) < 5 then
        BallLastPosition[BallInstance] = BallInstance.Position
        return false
    end
    local ExpectedPos = PrevPos + PrevVel * DeltaTime
    local Deviation = GetDistanceBetween(BallInstance.Position, ExpectedPos)
    BallLastPosition[BallInstance] = BallInstance.Position
    return Deviation > 4.5
end

local LibraryInstance
local LoaderUrl = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"
for Index = 1, 10 do
    local CacheBuster = ""
    pcall(function() CacheBuster = "?cb=" .. tostring((math.floor((FastClock() or 1) * 1000) + Index * 7919) % 2000000000) end)
    local Success, ResponseData = pcall(function() return game:HttpGet(LoaderUrl .. CacheBuster) end)
    if Success and type(ResponseData) == "string" and #ResponseData > 1000 then
        local LoadedFunction = loadstring(ResponseData)
        if LoadedFunction then
            local EvalSuccess, EvalResult = pcall(LoadedFunction)
            if EvalSuccess and type(EvalResult) == "table" and type(EvalResult.CreateWindow) == "function" then LibraryInstance = EvalResult break end
            local PublicInstance
            pcall(function() PublicInstance = getgenv().INSui end)
            if type(PublicInstance) == "table" and type(PublicInstance.CreateWindow) == "function" then LibraryInstance = PublicInstance break end
            pcall(function() PublicInstance = _G.INSui end)
            if type(PublicInstance) == "table" and type(PublicInstance.CreateWindow) == "function" then LibraryInstance = PublicInstance break end
            pcall(function() PublicInstance = (shared or {}).INSui end)
            if type(PublicInstance) == "table" and type(PublicInstance.CreateWindow) == "function" then LibraryInstance = PublicInstance break end
        end
    end
    task.wait(0.4)
end
if type(LibraryInstance) ~= "table" then return end

LibraryInstance:SetTheme("Indigo")

local WindowApp = LibraryInstance:CreateWindow({
    title = "Nightfall | Recode",
    subtitle = "credits to inspecttor for ui",
    size = Vector2.new(700, 552),
    configName = "Nightfall",
    configFolder = "NightfallConfigs",
    menuKey = "RightShift",
    badge = "v2"
})

local ConfigState = {
    AutoParry = false,
    AutoParryType = "New",
    Accuracy = 100,
    RandomAccuracy = false,
    RandomAccuracyMin = 80,
    RandomAccuracyMax = 100,
    PanicSpam = false,
    TrainingBallsSupport = false,
    AutoSpam = false,
    ManualSpam = false,
    SpamRate = 200,
    SpamSensitivity = 3,
    TriggerBot = false,
    TriggerDelay = 0,
    TriggerIgnoreSpawn = false,
    ParryVisualizer = false,
    VisualizerColor = Color3.fromRGB(220, 30, 30),
    VisThickness = 2.0,
    VisTransparency = 1.0,
    VisSegments = 40,
    AbilityEsp = false,
    EspColor = Color3.fromRGB(220, 30, 30),
    EspTextSize = 18,
    EspOffsetY = 2.0,
    BallTrail = false,
    TrailColor = Color3.fromRGB(220, 30, 30),
    TrailLength = 60,
    TrailThickness = 2.0,
    RainbowMode = false,
    InfinityDetection = false,
    SlashesOfFuryDetection = false,
    ParryMethod = "Click",
    Headless = false,
    Korblox = false,
    InfinityDisabledParry = false,
    InfinityDisabledSpam = false,
    InfinityDisabledTrigger = false,
    FuryDisabledParry = false,
    FuryDisabledSpam = false,
    FuryDisabledTrigger = false,
    FuryTriggered = false,
    OrbitBall = false,
    OrbitRadius = 25,
    OrbitSpeed = 50,
    OrbitHeight = 5
}

local RuntimeState = {
    TargetSpeed = 0,
    TargetDistance = 0,
    TargetDot = 0,
    ParryRange = 15,
    GeneratedAccuracy = 100
}

local AutoSpamInterval = 1 / 200
local ManualSpamInterval = 1 / 200
local PanicSpamInterval = 1 / 400

local NextAutoClick = 0
local NextManualClick = 0
local NextPanicClick = 0
local ManualSpamAccumulator = 0

local OffsetsData = {
    Transparency = 0xD0,
    Parent = 0x68,
    DecalTexture = 0x180,
    StatsValue = 0xC8
}

local function IsValidAddress(AddressValue)
    return AddressValue and type(AddressValue) == "number" and AddressValue > 0xFFF
end

local function WriteFloat(AddressValue, FloatValue)
    if IsValidAddress(AddressValue) then
        pcall(memory_write, "float", AddressValue, FloatValue)
    end
end

local function WritePointer(AddressValue, PointerValue)
    if IsValidAddress(AddressValue) then
        if not pcall(memory_write, "uint64", AddressValue, PointerValue) then
            pcall(memory_write, "pointer", AddressValue, PointerValue)
        end
    end
end

local function GenerateRandomAccuracy()
    local MinAcc = FastMin(ConfigState.RandomAccuracyMin, ConfigState.RandomAccuracyMax)
    local MaxAcc = FastMax(ConfigState.RandomAccuracyMin, ConfigState.RandomAccuracyMax)
    
    local BaseRandom = MinAcc + (math.random() * (MaxAcc - MinAcc))
    local Jitter = (math.random() - 0.5) * 4.5
    local FinalValue = FastClamp(BaseRandom + Jitter, MinAcc, MaxAcc)
    
    RuntimeState.GeneratedAccuracy = FinalValue
end

local CombatTab = WindowApp:Tab("Combat", "swords")

local ParrySection = CombatTab:Section("Auto Parry", "Left", "")
ParrySection:Toggle("Auto Parry", false, function(Value) ConfigState.AutoParry = Value end):AddKeybind("None", "Toggle")
ParrySection:Slider("Accuracy", 100, 1, 1, 100, "%", function(Value) ConfigState.Accuracy = Value end)
ParrySection:Dropdown("Auto Parry Type", "New", {"New", "Old"}, false, function(Value) 
    ConfigState.AutoParryType = type(Value) == "table" and Value[1] or Value 
end)

local RandomAccuracyToggle = ParrySection:Toggle("Random Accuracy", false, function(Value) ConfigState.RandomAccuracy = Value end)
ParrySection:RangeSlider("Random Parry Accuracy", 80, 100, 1, 1, 100, "%", function(MinValue, MaxValue)
    ConfigState.RandomAccuracyMin = MinValue
    ConfigState.RandomAccuracyMax = MaxValue
end):DependsOn(RandomAccuracyToggle)

ParrySection:Toggle("Panic Spam", false, function(Value) ConfigState.PanicSpam = Value end)
ParrySection:Dropdown("Parry Method", {"Click"}, {"Click", "Key"}, false, function(Value) ConfigState.ParryMethod = type(Value) == "table" and Value[1] or Value end)
ParrySection:Toggle("Training Balls", false, function(Value) ConfigState.TrainingBallsSupport = Value end)
ParrySection:Toggle("Orbit Ball", false, function(Value) ConfigState.OrbitBall = Value end):AddKeybind("None", "Toggle")
ParrySection:Slider("Orbit Radius", 25, 1, 5, 100, "", function(Value) ConfigState.OrbitRadius = Value end)
ParrySection:Slider("Orbit Speed", 50, 1, 10, 200, "", function(Value) ConfigState.OrbitSpeed = Value end)
ParrySection:Slider("Orbit Height", 5, 0.5, -30, 50, "", function(Value) ConfigState.OrbitHeight = Value end)

local SpamSection = CombatTab:Section("Auto Spam", "Right", "")
SpamSection:Toggle("Auto Spam", false, function(Value) ConfigState.AutoSpam = Value end):AddKeybind("None", "Toggle")
SpamSection:Toggle("Manual Spam", false, function(Value) ConfigState.ManualSpam = Value end):AddKeybind("None", "Toggle")
SpamSection:Slider("Spam Rate", 300, 100, 200, 3000, "cps", function(Value) 
    ConfigState.SpamRate = Value 
    local CalculatedInterval = 1 / FastMax(Value, 1)
    AutoSpamInterval = CalculatedInterval
    ManualSpamInterval = CalculatedInterval
    PanicSpamInterval = CalculatedInterval
    NextAutoClick = 0
    NextManualClick = 0
    NextPanicClick = 0
    ManualSpamAccumulator = 0
end)
SpamSection:Slider("Spam Sensitivity", 3, 1, 1, 5, "", function(Value) ConfigState.SpamSensitivity = Value end)

local TriggerSection = CombatTab:Section("Trigger Bot", "Right", "")
TriggerSection:Toggle("Trigger Bot", false, function(Value) ConfigState.TriggerBot = Value end):AddKeybind("None", "Toggle")
TriggerSection:Slider("Delay", 0, 1, 0, 100, "ms", function(Value) ConfigState.TriggerDelay = Value end)
TriggerSection:Toggle("Ignore Ball Spawn", false, function(Value) ConfigState.TriggerIgnoreSpawn = Value end)

local VisualsTab = WindowApp:Tab("Visuals", "eye")

local VisMainSection = VisualsTab:Section("Visuals", "Left", "")
VisMainSection:Toggle("Range Visualiser", false, function(Value) ConfigState.ParryVisualizer = Value end):AddColorpicker("Vis Color", Color3.fromRGB(220, 30, 30), function(ColorValue) ConfigState.VisualizerColor = ColorValue end)
VisMainSection:Slider("Vis Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value) ConfigState.VisThickness = Value end)
VisMainSection:Slider("Vis Transparency", 1.0, 0.1, 0.1, 1.0, "", function(Value) ConfigState.VisTransparency = Value end)
VisMainSection:Slider("Vis Segments", 40, 1, 10, 100, "", function(Value) ConfigState.VisSegments = Value end)

VisMainSection:Toggle("Ability ESP", false, function(Value) ConfigState.AbilityEsp = Value end)
VisMainSection:Colorpicker("ESP Color", Color3.fromRGB(220, 30, 30), function(Color, Alpha) ConfigState.EspColor = Color or Color3.fromRGB(220, 30, 30) end, 1)
VisMainSection:Slider("ESP Text Size", 18, 1, 10, 40, "", function(Value) ConfigState.EspTextSize = Value end)
VisMainSection:Slider("ESP Offset Y", 2.0, 0.5, 0.0, 10.0, "", function(Value) ConfigState.EspOffsetY = Value end)

VisMainSection:Toggle("Rainbow Mode", false, function(Value) ConfigState.RainbowMode = Value end)

local VisTrailSection = VisualsTab:Section("Ball Trail", "Right", "")
VisTrailSection:Toggle("Enable Trail", false, function(Value) ConfigState.BallTrail = Value end):AddColorpicker("Trail Color", Color3.fromRGB(220, 30, 30), function(ColorValue) ConfigState.TrailColor = ColorValue end)
VisTrailSection:Slider("Trail Length", 60, 1, 3, 100, "", function(Value) ConfigState.TrailLength = Value end)
VisTrailSection:Slider("Trail Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value) ConfigState.TrailThickness = Value end)

local VisAvatarSection = VisualsTab:Section("Avatar", "Right", "")

local function ApplyHeadless(StateValue)
    local CharacterObject = LocalPlayer.Character
    if not CharacterObject or typeof(CharacterObject) ~= "Instance" then return end
    local HeadObject = CharacterObject:FindFirstChild("Head")
    if HeadObject and typeof(HeadObject) == "Instance" and HeadObject:IsA("BasePart") then
        if StateValue then
            pcall(function() HeadObject.Size = Vector3.new(0.01, 0.01, 0.01) end)
            if IsValidAddress(HeadObject.Address) then
                WriteFloat(HeadObject.Address + OffsetsData.Transparency, 1.0)
            end
            for _, ChildObject in ipairs(HeadObject:GetChildren()) do
                if typeof(ChildObject) == "Instance" and (ChildObject.ClassName == "Decal" or ChildObject.Name == "face" or ChildObject.Name == "Face" or ChildObject.ClassName:match("Mesh")) then
                    pcall(function() ChildObject.Texture = "" end)
                    pcall(function() ChildObject.Transparency = 1 end)
                    pcall(function() ChildObject.Parent = nil end)
                    pcall(function() game:GetService("Debris"):AddItem(ChildObject, 0) end)
                    if IsValidAddress(ChildObject.Address) then
                        if ChildObject.ClassName == "Decal" or ChildObject.Name == "face" or ChildObject.Name == "Face" then
                            pcall(memory_write, "uint64", ChildObject.Address + OffsetsData.DecalTexture + 0x10, 0)
                        end
                        WritePointer(ChildObject.Address + OffsetsData.Parent, 0)
                    end
                end
            end
        else
            pcall(function() HeadObject.Size = Vector3.new(1.2, 1, 1.2) end)
        end
    end
end

local function ApplyKorblox(StateValue)
    local CharacterObject = LocalPlayer.Character
    if not CharacterObject or typeof(CharacterObject) ~= "Instance" then return end
    local RightLegNames = {
        RightUpperLeg = true,
        RightLowerLeg = true,
        RightFoot = true,
        ["Right Leg"] = true
    }
    if StateValue then
        for _, PartObject in ipairs(CharacterObject:GetChildren()) do
            if typeof(PartObject) == "Instance" and RightLegNames[PartObject.Name] and PartObject:IsA("BasePart") then
                pcall(function() PartObject.Size = Vector3.new(0.01, 0.01, 0.01) end)
                if IsValidAddress(PartObject.Address) then
                    WriteFloat(PartObject.Address + OffsetsData.Transparency, 1.0)
                end
                for _, ChildObject in ipairs(PartObject:GetChildren()) do
                    if typeof(ChildObject) == "Instance" and (ChildObject.ClassName:match("Mesh") or ChildObject.ClassName == "Decal" or ChildObject.ClassName == "Texture") then
                        pcall(function() ChildObject.Texture = "" end)
                        pcall(function() ChildObject.Transparency = 1 end)
                        pcall(function() ChildObject.Parent = nil end)
                        pcall(function() game:GetService("Debris"):AddItem(ChildObject, 0) end)
                        if IsValidAddress(ChildObject.Address) then
                            WritePointer(ChildObject.Address + OffsetsData.Parent, 0)
                        end
                    end
                end
            elseif typeof(PartObject) == "Instance" and PartObject.ClassName == "CharacterMesh" then
                pcall(function()
                    if tostring(PartObject.BodyPart):match("RightLeg") then
                        if IsValidAddress(PartObject.Address) then
                            WritePointer(PartObject.Address + OffsetsData.Parent, 0)
                        end
                    end
                end)
            elseif typeof(PartObject) == "Instance" and PartObject.ClassName == "Accessory" then
                pcall(function()
                    local HandleObject = PartObject:FindFirstChild("Handle")
                    if HandleObject and typeof(HandleObject) == "Instance" then
                        local WeldObject = HandleObject:FindFirstChildOfClass("Weld") or HandleObject:FindFirstChildOfClass("Motor6D")
                        if WeldObject and typeof(WeldObject) == "Instance" and WeldObject.Part1 and RightLegNames[WeldObject.Part1.Name] then
                            if IsValidAddress(PartObject.Address) then
                                WritePointer(PartObject.Address + OffsetsData.Parent, 0)
                            end
                        end
                    end
                end)
            end
        end
    else
        for _, PartObject in ipairs(CharacterObject:GetChildren()) do
            if typeof(PartObject) == "Instance" and RightLegNames[PartObject.Name] and PartObject:IsA("BasePart") then
                pcall(function() PartObject.Size = Vector3.new(1, 1, 1) end)
            end
        end
    end
end

VisAvatarSection:Toggle("Headless", false, function(Value) 
    ConfigState.Headless = Value 
    ApplyHeadless(Value)
end)

VisAvatarSection:Toggle("Korblox", false, function(Value) 
    ConfigState.Korblox = Value 
    ApplyKorblox(Value)
end)

local DetectionsTab = WindowApp:Tab("Detections", "shield")
local DetMainSection = DetectionsTab:Section("Detections", "Left", "")
DetMainSection:Toggle("Infinity Detection", false, function(Value) ConfigState.InfinityDetection = Value end)
DetMainSection:Toggle("Slashes of Fury Detection", false, function(Value) ConfigState.SlashesOfFuryDetection = Value end)

WindowApp:AddSettingsTab("cog")

local VisualsData = {
    SphereLines = {},
    BallTrailPositions = {},
    BallLines = {},
    EspTexts = {}
}

local MaxTrailLines = 100

local function CreateEspText()
    if not Drawing or not Drawing.new then return nil end
    local Success, TextObject = pcall(function() return Drawing.new("Text") end)
    if not Success or not TextObject then return nil end
    TextObject.Center = true
    TextObject.Outline = true
    TextObject.Font = 2
    TextObject.Transparency = 0
    TextObject.ZIndex = 2
    TextObject.Color = ConfigState.EspColor or Color3.fromRGB(220, 30, 30)
    TextObject.Visible = false
    table.insert(_G.NightfallDrawings, TextObject)
    return TextObject
end

if type(Drawing) == "table" and Drawing.new then
    for Index = 1, 100 do
        pcall(function()
            local LineObject = Drawing.new("Line")
            if LineObject then
                LineObject.Visible = false
                VisualsData.SphereLines[Index] = LineObject
                table.insert(_G.NightfallDrawings, LineObject)
            end
        end)
    end
    for Index = 1, MaxTrailLines do
        pcall(function()
            local LineObject = Drawing.new("Line")
            if LineObject then
                LineObject.Visible = false
                VisualsData.BallLines[Index] = LineObject
                table.insert(_G.NightfallDrawings, LineObject)
            end
        end)
    end
end

local SmoothParryRadius = 15

local function GetRealBall()
    local AliveFolder = WorkspaceService:FindFirstChild("Alive")
    local DeadFolder = WorkspaceService:FindFirstChild("Dead")
    local TargetFolder = nil
    if AliveFolder and typeof(AliveFolder) == "Instance" and AliveFolder:FindFirstChild(LocalPlayer.Name) then
        TargetFolder = WorkspaceService:FindFirstChild("Balls")
    elseif DeadFolder and typeof(DeadFolder) == "Instance" and DeadFolder:FindFirstChild(LocalPlayer.Name) then
        if ConfigState.TrainingBallsSupport then
            TargetFolder = WorkspaceService:FindFirstChild("TrainingBalls")
        else
            TargetFolder = WorkspaceService:FindFirstChild("Balls")
        end
    else
        TargetFolder = WorkspaceService:FindFirstChild("Balls")
    end
    if TargetFolder and typeof(TargetFolder) == "Instance" then
        for _, Ball in ipairs(TargetFolder:GetChildren()) do
            if typeof(Ball) == "Instance" and Ball:IsA("BasePart") then return Ball end
        end
    end
    return nil
end

local function GetMemoryPing()
    local SuccessState, PingResult = pcall(function()
        local PingStatsItem = StatsService.Network.ServerStatsItem["Data Ping"]
        if IsValidAddress(PingStatsItem.Address) then
            return memory_read("double", PingStatsItem.Address + OffsetsData.StatsValue)
        end
        return 50
    end)
    return (SuccessState and type(PingResult) == "number") and PingResult or 50
end

local function CheckIsTarget(TargetName)
    if not LocalPlayer then return false end
    local CharacterInstance = LocalPlayer.Character
    if CharacterInstance and typeof(CharacterInstance) == "Instance" and CharacterInstance:FindFirstChild('Highlight') then return true end
    if not TargetName then return false end
    local MyName = string.lower(LocalPlayer.Name or "")
    local MyDisplay = string.lower(LocalPlayer.DisplayName or LocalPlayer.Name or "")
    local TargetString = string.lower(tostring(TargetName))
    if TargetString == MyName or TargetString == MyDisplay then return true end
    local CleanTarget = string.gsub(TargetString, '%.%.%.$', '')
    if #CleanTarget >= 3 then
        if string.sub(MyName, 1, #CleanTarget) == CleanTarget or string.sub(MyDisplay, 1, #CleanTarget) == CleanTarget then return true end
        if string.find(MyName, CleanTarget, 1, true) or string.find(MyDisplay, CleanTarget, 1, true) then return true end
    end
    return false
end

local function GetDistanceSquared(V1Position, V2Position)
    local DxValue = V1Position.X - V2Position.X
    local DyValue = V1Position.Y - V2Position.Y
    local DzValue = V1Position.Z - V2Position.Z
    return DxValue * DxValue + DyValue * DyValue + DzValue * DzValue
end

local function ScanForNearestEntity(PlayerPosition)
    if not PlayerPosition or typeof(PlayerPosition) ~= "Vector3" then return nil, math.huge end
    local NearestEntity = nil
    local MinimumDistanceSq = math.huge
    for _, TargetPlayer in ipairs(PlayersService:GetPlayers()) do
        if not TargetPlayer or typeof(TargetPlayer) ~= "Instance" or TargetPlayer == LocalPlayer then continue end
        if TargetPlayer.Character and typeof(TargetPlayer.Character) == "Instance" then
            local RootPart = TargetPlayer.Character:FindFirstChild("HumanoidRootPart") or TargetPlayer.Character.PrimaryPart
            if RootPart and typeof(RootPart) == "Instance" and RootPart:IsA("BasePart") then
                local HumanoidPart = TargetPlayer.Character:FindFirstChild("Humanoid")
                if HumanoidPart and typeof(HumanoidPart) == "Instance" and HumanoidPart.Health > 0 then
                    local CurrentDistSq = GetDistanceSquared(PlayerPosition, RootPart.Position)
                    if CurrentDistSq < MinimumDistanceSq then
                        MinimumDistanceSq = CurrentDistSq
                        NearestEntity = TargetPlayer
                    end
                end
            end
        end
    end
    return NearestEntity, FastSqrt(MinimumDistanceSq)
end

local function ExecuteParryDirect()
    if ConfigState.ParryMethod == "Click" then
        if typeof(Mouse1Click) == "function" then
            Mouse1Click()
        end
    elseif ConfigState.ParryMethod == "Key" then
        if typeof(KeyPress) == "function" and typeof(KeyRelease) == "function" then
            KeyPress(0x46)
            KeyRelease(0x46)
        end
    end
end

local function ExecuteParry()
    task.spawn(ExecuteParryDirect)
end

local SpamConfiguration = {
    SpamMinDistanceSpeedDivisor = 6.5,
    SpamMaxSpeedDivisor = 5.0,
    SpamMinDistance = 95.0,
    SpamMaxDistance = 30.0
}

local function CheckIsSpam(SpamParameters)
    if SpamParameters.IsMovingAway then return false, 0 end
    if SpamParameters.Parries < ConfigState.SpamSensitivity then return false, SpamParameters.Parries end
    local ScaledPing = SpamParameters.Ping / 10
    local RangeValue = ScaledPing + FastMin(SpamParameters.Speed / SpamConfiguration.SpamMinDistanceSpeedDivisor, SpamConfiguration.SpamMinDistance)
    local IsSnap = (SpamParameters.Dot > 0.75) and (SpamParameters.DotDelta > 0.15) and (SpamParameters.BallDistance <= RangeValue * 1.75)
    if IsSnap then return true, SpamParameters.Parries end
    if SpamParameters.EntityDistance > RangeValue then return false, SpamParameters.Parries end
    if SpamParameters.BallDistance > RangeValue then return false, SpamParameters.Parries end
    local MaximumDot = FastClamp(SpamParameters.Dot, -1, 0)
    local AccuracyValue = FastMin(RangeValue - MaximumDot, SpamConfiguration.SpamMaxDistance)
    if SpamParameters.BallDistance > AccuracyValue then return false, SpamParameters.Parries end
    return true, SpamParameters.Parries
end

local function GetTrailColorAndOpacity(OffsetValue, IndexValue, TotalValue)
    local AlphaValue = 1.0 - math.pow(IndexValue / TotalValue, 1.5)
    local OpacityValue = FastMax(AlphaValue * AlphaValue * AlphaValue, 0.05)
    if not ConfigState.RainbowMode then
        return ConfigState.TrailColor, OpacityValue
    end
    local TimeValue = FastClock() * 2.5 + OffsetValue + IndexValue * 0.1
    local RValue = (math.sin(TimeValue) * 0.5 + 0.5) * 0.95 + 0.05
    local GValue = (math.sin(TimeValue + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
    local BValue = (math.sin(TimeValue + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
    return Color3.new(RValue, GValue, BValue), OpacityValue
end

local function UpdateAndRenderTrail(CurrentBallPosition)
    if not ConfigState.BallTrail then
        for _, LineObject in ipairs(VisualsData.BallLines) do
            if LineObject then LineObject.Visible = false end
        end
        table.clear(VisualsData.BallTrailPositions)
        return
    end
    if not CurrentBallPosition or typeof(CurrentBallPosition) ~= "Vector3" then
        for _, LineObject in ipairs(VisualsData.BallLines) do
            if LineObject then LineObject.Visible = false end
        end
        table.clear(VisualsData.BallTrailPositions)
        return
    end
    
    local LastTrackedPosition = VisualsData.BallTrailPositions[1]
    if not LastTrackedPosition or (LastTrackedPosition - CurrentBallPosition).Magnitude > 0.05 then
        table.insert(VisualsData.BallTrailPositions, 1, CurrentBallPosition)
    end

    while #VisualsData.BallTrailPositions > ConfigState.TrailLength do
        table.remove(VisualsData.BallTrailPositions)
    end

    local TotalPositions = #VisualsData.BallTrailPositions
    if TotalPositions < 2 then
        for _, LineObject in ipairs(VisualsData.BallLines) do
            if LineObject then LineObject.Visible = false end
        end
        return
    end
    
    local BaseOffset = FastClock() * 1.5
    for Index = 2, TotalPositions do
        local LineObject = VisualsData.BallLines[Index - 1]
        if not LineObject then break end
        
        local Position1 = VisualsData.BallTrailPositions[Index - 1]
        local Position2 = VisualsData.BallTrailPositions[Index]
        
        if Position1 and Position2 and typeof(Position1) == "Vector3" and typeof(Position2) == "Vector3" then
            local Point1Screen, Visible1 = WorldToScreen(Position1)
            local Point2Screen, Visible2 = WorldToScreen(Position2)
            
            if Visible1 and Visible2 then
                local ColorValue, OpacityValue = GetTrailColorAndOpacity(BaseOffset, Index, TotalPositions)
                LineObject.From = Point1Screen
                LineObject.To = Point2Screen
                LineObject.Color = ColorValue
                LineObject.Transparency = OpacityValue
                LineObject.Thickness = ConfigState.TrailThickness * (1.0 - math.pow(Index / TotalPositions, 1.5))
                LineObject.Visible = true
            else
                LineObject.Visible = false
            end
        else
            LineObject.Visible = false
        end
    end
    for Index = TotalPositions, #VisualsData.BallLines do
        local LineObject = VisualsData.BallLines[Index]
        if LineObject then
            LineObject.Visible = false
        end
    end
end

local PullTime = 0
local IsParried = false
local ParryRangeThreshold = 0
local AeroActive = false
local AeroStartTime = 0
local LastSpeed = 0
local LastBallInstance = nil
local LastDistance = 9999
local LastDotProduct = 0
local ScheduledTriggerTime = 0
local BallParries = 0
local LastFromChange = 0
local CachedFrom = nil
local CachedTarget = nil
local ActiveTarget = nil
local CurrentKps = 0
local SmoothedKps = 0
local SmoothedServerFps = 60
local LastGameTime = WorkspaceService.DistributedGameTime
local CachedAliveFolder = nil
local SmoothVisualRootPosition = nil
local EspSmoothedPositions = {}
local CachedCharacter = nil
local CharacterFullyLoaded = false
local PullActive = false
local LastPullTime = 0

RunService.RenderStepped:Connect(function(DeltaTime)
    if type(DeltaTime) ~= "number" then DeltaTime = 0.016 end
    local CurrentRenderTime = FastClock()
    local RealBallVisuals = GetRealBall()
    local CurrentBallPosition = nil
    
    if RealBallVisuals and typeof(RealBallVisuals) == "Instance" and RealBallVisuals:IsA("BasePart") then
        CurrentBallPosition = RealBallVisuals.Position
    end
    
    UpdateAndRenderTrail(CurrentBallPosition)

    if ConfigState.AbilityEsp then
        local CurrentPlayersList = PlayersService:GetPlayers()
        for Index = 1, #CurrentPlayersList do
            local TargetPlayer = CurrentPlayersList[Index]
            if not TargetPlayer or typeof(TargetPlayer) ~= "Instance" or TargetPlayer == LocalPlayer then continue end
            
            local PlayerNameString = TargetPlayer.Name
            local TargetCharacter = TargetPlayer.Character
            local TargetHumanoid = TargetCharacter and typeof(TargetCharacter) == "Instance" and TargetCharacter:FindFirstChildWhichIsA("Humanoid")
            local TargetHead = TargetCharacter and typeof(TargetCharacter) == "Instance" and TargetCharacter:FindFirstChild("Head")
            local TargetAbility = TargetPlayer:GetAttribute("CurrentlyEquippedAbility")
            
            if TargetHumanoid and TargetHumanoid.Health > 0 and TargetHead and typeof(TargetHead) == "Instance" and TargetHead:IsA("BasePart") and TargetAbility and tostring(TargetAbility) ~= "" then
                local HeadPosition = TargetHead.Position
                local CurrentOffsetVector = Vector3.new(0, ConfigState.EspOffsetY, 0)
                local Target3D = HeadPosition + CurrentOffsetVector
                
                local ScreenCoordinates, IsOnScreen = WorldToScreen(Target3D)
                if IsOnScreen and ScreenCoordinates.X > 0 and ScreenCoordinates.Y > 0 then
                    local TextDrawing = VisualsData.EspTexts[PlayerNameString]
                    if not TextDrawing then
                        TextDrawing = CreateEspText()
                        VisualsData.EspTexts[PlayerNameString] = TextDrawing
                    end
                    if TextDrawing then
                        local DrawColor = ConfigState.EspColor
                        if (not DrawColor) or (typeof(DrawColor) ~= "Color3") then
                            DrawColor = Color3.fromRGB(220, 30, 30)
                        end
                        TextDrawing.Color = DrawColor
                        TextDrawing.Size = ConfigState.EspTextSize
                        local SmoothedPosition = ScreenCoordinates
                        if EspSmoothedPositions[PlayerNameString] then
                            local LerpAlpha = FastClamp(DeltaTime * 32, 0, 1)
                            SmoothedPosition = LerpVector2(EspSmoothedPositions[PlayerNameString], ScreenCoordinates, LerpAlpha)
                        end
                        EspSmoothedPositions[PlayerNameString] = SmoothedPosition
                        TextDrawing.Position = SmoothedPosition
                        TextDrawing.Text = tostring(TargetAbility)
                        if ConfigState.RainbowMode then
                            local TimeValue = CurrentRenderTime * 2.5
                            local RValue = (math.sin(TimeValue) * 0.5 + 0.5) * 0.95 + 0.05
                            local GValue = (math.sin(TimeValue + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                            local BValue = (math.sin(TimeValue + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                            TextDrawing.Color = Color3.new(RValue, GValue, BValue)
                        else
                            TextDrawing.Color = DrawColor
                        end
                        TextDrawing.Visible = true
                    end
                else
                    local TextDrawing = VisualsData.EspTexts[PlayerNameString]
                    if TextDrawing then TextDrawing.Visible = false end
                end
            else
                local TextDrawing = VisualsData.EspTexts[PlayerNameString]
                if TextDrawing then
                    TextDrawing.Visible = false
                end
            end
        end
        for KeyName, TextDrawing in pairs(VisualsData.EspTexts) do
            if not PlayersService:FindFirstChild(KeyName) then
                if TextDrawing then TextDrawing:Remove() end
                VisualsData.EspTexts[KeyName] = nil
                EspSmoothedPositions[KeyName] = nil
            end
        end
    else
        for KeyName, TextDrawing in pairs(VisualsData.EspTexts) do
            if TextDrawing then
                TextDrawing.Visible = false
            end
        end
    end

    local LocalCharacter = LocalPlayer.Character
    local RootPartVisual = LocalCharacter and typeof(LocalCharacter) == "Instance" and LocalCharacter:FindFirstChild("HumanoidRootPart")
    if ConfigState.ParryVisualizer and RootPartVisual and typeof(RootPartVisual) == "Instance" and RootPartVisual:IsA("BasePart") then
       local RootPositionRaw = RootPartVisual.Position - Vector3.new(0, 3, 0)
       if SmoothVisualRootPosition == nil then
           SmoothVisualRootPosition = RootPositionRaw
       else
           local LerpAlpha = FastClamp(DeltaTime * 18, 0, 1)
           SmoothVisualRootPosition = SmoothVisualRootPosition:Lerp(RootPositionRaw, LerpAlpha)
       end
       local RootPosition = SmoothVisualRootPosition
       local TargetRadius = RuntimeState.ParryRange or 15
       SmoothParryRadius = SmoothParryRadius + (TargetRadius - SmoothParryRadius) * FastClamp(DeltaTime * 20, 0, 1)
       local RadiusValue = FastMax(SmoothParryRadius, 5)
        local SegmentsCount = FastClamp(ConfigState.VisSegments, 10, 100)
        local AngleStep = TwoPi / SegmentsCount
        for Index = 1, 100 do
            local LineObject = VisualsData.SphereLines[Index]
            if LineObject then
                if Index <= SegmentsCount then
                    local Angle1 = (Index - 1) * AngleStep
                    local Angle2 = Index * AngleStep
                    local Point1_3d = RootPosition + Vector3.new(math.cos(Angle1) * RadiusValue, 0, math.sin(Angle1) * RadiusValue)
                    local Point2_3d = RootPosition + Vector3.new(math.cos(Angle2) * RadiusValue, 0, math.sin(Angle2) * RadiusValue)
                    local Point1Position, OnScreen1 = WorldToScreen(Point1_3d)
                    local Point2Position, OnScreen2 = WorldToScreen(Point2_3d)
                    if OnScreen1 and OnScreen2 then
                        LineObject.Visible = true
                        LineObject.From = Point1Position
                        LineObject.To = Point2Position
                        LineObject.Thickness = ConfigState.VisThickness
                        LineObject.Transparency = ConfigState.VisTransparency
                        if ConfigState.RainbowMode then
                            local OffsetT = CurrentRenderTime * 2.5 + (Index / SegmentsCount) * TwoPi
                            local VisR = (math.sin(OffsetT) * 0.5 + 0.5) * 0.95 + 0.05
                            local VisG = (math.sin(OffsetT + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                            local VisB = (math.sin(OffsetT + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                            LineObject.Color = Color3.new(VisR, VisG, VisB)
                        else
                            LineObject.Color = ConfigState.VisualizerColor
                        end
                    else
                        LineObject.Visible = false
                    end
                else
                    LineObject.Visible = false
                end
            end
        end
    else
        for Index = 1, 100 do 
            local LineObject = VisualsData.SphereLines[Index]
            if LineObject and LineObject.Visible then
                LineObject.Visible = false 
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(DeltaTime)
    local CurrentTime = FastClock()
    if type(DeltaTime) ~= "number" then DeltaTime = 0.016 end
    local CurrentDeltaTime = DeltaTime

    local RuntimeFolder = WorkspaceService:FindFirstChild("Runtime")
    local ChildrenList = RuntimeFolder and typeof(RuntimeFolder) == "Instance" and RuntimeFolder:GetChildren() or WorkspaceService:GetChildren()
    for _, ChildObject in ipairs(ChildrenList) do
        if typeof(ChildObject) == "Instance" and (ChildObject.Name == "Pull" or ChildObject.Name == "MaxPull") then
            PullTime = CurrentTime
            break
        end
    end

    local PlayerCharacterObject = LocalPlayer.Character

    if PlayerCharacterObject ~= CachedCharacter then
        CachedCharacter = PlayerCharacterObject
        CharacterFullyLoaded = false
    end

    if PlayerCharacterObject and typeof(PlayerCharacterObject) == "Instance" and not CharacterFullyLoaded then
        local HumanoidRootPart = PlayerCharacterObject:FindFirstChild("HumanoidRootPart")
        if HumanoidRootPart and typeof(HumanoidRootPart) == "Instance" then
            CharacterFullyLoaded = true
            task.spawn(function()
                task.wait(0.5)
                if ConfigState.Headless then
                    pcall(function() ApplyHeadless(true) end)
                end
                if ConfigState.Korblox then
                    pcall(function() ApplyKorblox(true) end)
                end
            end)
        end
    end

    if PlayerCharacterObject and typeof(PlayerCharacterObject) == "Instance" and CharacterFullyLoaded then
        if ConfigState.Headless then
            local TargetHead = PlayerCharacterObject:FindFirstChild("Head")
            if TargetHead and typeof(TargetHead) == "Instance" and TargetHead:IsA("BasePart") and TargetHead.Size.X > 0.1 then
                pcall(function() ApplyHeadless(true) end)
            end
        end
        if ConfigState.Korblox then
            local TargetRightLeg = PlayerCharacterObject:FindFirstChild("RightUpperLeg") or PlayerCharacterObject:FindFirstChild("Right Leg")
            if TargetRightLeg and typeof(TargetRightLeg) == "Instance" and TargetRightLeg:IsA("BasePart") and TargetRightLeg.Size.X > 0.1 then
                pcall(function() ApplyKorblox(true) end)
            end
        end
    end

    local CurrentGameTime = WorkspaceService.DistributedGameTime
    if CurrentGameTime ~= LastGameTime then
        local ServerTickDelta = CurrentGameTime - LastGameTime
        LastGameTime = CurrentGameTime
        if ServerTickDelta > 0 then
            local CurrentServerFps = 1 / ServerTickDelta
            SmoothedServerFps = SmoothedServerFps + (CurrentServerFps - SmoothedServerFps) * 0.1
        end
    end

    if ConfigState.InfinityDetection then
        local IsDetected = false
        local InfinityRuntimeFolder = WorkspaceService:FindFirstChild("Runtime")
        if InfinityRuntimeFolder and typeof(InfinityRuntimeFolder) == "Instance" then
            if InfinityRuntimeFolder:FindFirstChild("InfinityFX") or InfinityRuntimeFolder:FindFirstChild("TrueInfinityFX") then
                IsDetected = true
            end
        end
        local CurrentBallsFolder = WorkspaceService:FindFirstChild("Balls")
        if CurrentBallsFolder and typeof(CurrentBallsFolder) == "Instance" then
            for _, CurrentBall in ipairs(CurrentBallsFolder:GetChildren()) do
                if typeof(CurrentBall) == "Instance" and CurrentBall:IsA("BasePart") then
                    local BodyPart = CurrentBall:FindFirstChild("Body")
                    if BodyPart and typeof(BodyPart) == "Instance" and BodyPart:FindFirstChild("WEMAZOOKIEGO") then
                        IsDetected = true
                        break
                    end
                end
            end
        end
        if LocalPlayer.Character and typeof(LocalPlayer.Character) == "Instance" then
            if LocalPlayer.Character:FindFirstChild("Parry") then
                IsDetected = true
            end
        end
        
        if IsDetected then
            if ConfigState.AutoParry then
                ConfigState.AutoParry = false
                ConfigState.InfinityDisabledParry = true
            end
            if ConfigState.AutoSpam then
                ConfigState.AutoSpam = false
                ConfigState.InfinityDisabledSpam = true
            end
            if ConfigState.TriggerBot then
                ConfigState.TriggerBot = false
                ConfigState.InfinityDisabledTrigger = true
            end
        else
            if ConfigState.InfinityDisabledParry then
                ConfigState.AutoParry = true
                ConfigState.InfinityDisabledParry = false
            end
            if ConfigState.InfinityDisabledSpam then
                ConfigState.AutoSpam = true
                ConfigState.InfinityDisabledSpam = false
            end
            if ConfigState.InfinityDisabledTrigger then
                ConfigState.TriggerBot = true
                ConfigState.InfinityDisabledTrigger = false
            end
        end
    end

    if ConfigState.SlashesOfFuryDetection then
        local IsFury = false
        local CurrentBallsFolder = WorkspaceService:FindFirstChild("Balls")
        if CurrentBallsFolder and typeof(CurrentBallsFolder) == "Instance" then
            for _, CurrentBall in ipairs(CurrentBallsFolder:GetChildren()) do
                if typeof(CurrentBall) == "Instance" and CurrentBall:FindFirstChild("ComboCounter") then
                    local TargetAttribute = CurrentBall:GetAttribute("target") or CurrentBall:GetAttribute("Target")
                    if CheckIsTarget(TargetAttribute) then
                        IsFury = true
                    end
                    break
                end
            end
        end
        if not IsFury and LocalPlayer.Character and typeof(LocalPlayer.Character) == "Instance" then
            if LocalPlayer.Character:GetAttribute("FuryCatch") == true then
                IsFury = true
            end
        end
        if not IsFury then
            local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if PlayerGui and typeof(PlayerGui) == "Instance" then
                local FuryTimer = PlayerGui:FindFirstChild("FuryTimer")
                if FuryTimer and typeof(FuryTimer) == "Instance" and FuryTimer.Enabled then
                    IsFury = true
                end
            end
        end
        
        if IsFury and not ConfigState.FuryTriggered then
            ConfigState.FuryTriggered = true
            if ConfigState.AutoParry then
                ConfigState.AutoParry = false
                ConfigState.FuryDisabledParry = true
            end
            if ConfigState.AutoSpam then
                ConfigState.AutoSpam = false
                ConfigState.FuryDisabledSpam = true
            end
            if ConfigState.TriggerBot then
                ConfigState.TriggerBot = false
                ConfigState.FuryDisabledTrigger = true
            end
            task.spawn(function()
                while ConfigState.SlashesOfFuryDetection do
                    local StillFury = false
                    local CurrentCombo = 0
                    local CurrentBalls = WorkspaceService:FindFirstChild("Balls")
                    if CurrentBalls and typeof(CurrentBalls) == "Instance" then
                        for _, CurrentBall in ipairs(CurrentBalls:GetChildren()) do
                            local ComboObject = typeof(CurrentBall) == "Instance" and CurrentBall:FindFirstChild("ComboCounter")
                            if ComboObject and typeof(ComboObject) == "Instance" then
                                local TargetAttribute = CurrentBall:GetAttribute("target") or CurrentBall:GetAttribute("Target")
                                if CheckIsTarget(TargetAttribute) then
                                    StillFury = true
                                end
                                local TextLabel = ComboObject:FindFirstChild("TextLabel")
                                if TextLabel and typeof(TextLabel) == "Instance" then
                                    CurrentCombo = tonumber(TextLabel.Text) or 0
                                end
                                break
                            end
                        end
                    end
                    if not StillFury and LocalPlayer.Character and typeof(LocalPlayer.Character) == "Instance" then
                        if LocalPlayer.Character:GetAttribute("FuryCatch") == true then
                            StillFury = true
                        end
                    end
                    if not StillFury then
                        local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if PlayerGui and typeof(PlayerGui) == "Instance" then
                            local FuryTimer = PlayerGui:FindFirstChild("FuryTimer")
                            if FuryTimer and typeof(FuryTimer) == "Instance" and FuryTimer.Enabled then
                                StillFury = true
                            end
                        end
                    end
                    if not StillFury or CurrentCombo >= 34 then
                        break
                    end
                    ExecuteParryDirect()
                    task.wait(0.15)
                end
                if ConfigState.FuryDisabledParry then
                    ConfigState.AutoParry = true
                    ConfigState.FuryDisabledParry = false
                end
                if ConfigState.FuryDisabledSpam then
                    ConfigState.AutoSpam = true
                    ConfigState.FuryDisabledSpam = false
                end
                if ConfigState.FuryDisabledTrigger then
                    ConfigState.TriggerBot = true
                    ConfigState.FuryDisabledTrigger = false
                end
                ConfigState.FuryTriggered = false
            end)
        end
        if not IsFury then
            ConfigState.FuryTriggered = false
        end
    else
        if ConfigState.FuryDisabledParry then
            ConfigState.AutoParry = true
            ConfigState.FuryDisabledParry = false
        end
        if ConfigState.FuryDisabledSpam then
            ConfigState.AutoSpam = true
            ConfigState.FuryDisabledSpam = false
        end
        if ConfigState.FuryDisabledTrigger then
            ConfigState.TriggerBot = true
            ConfigState.FuryDisabledTrigger = false
        end
        ConfigState.FuryTriggered = false
    end

    local RealBall = GetRealBall()

    if not RealBall or typeof(RealBall) ~= "Instance" or not RealBall:IsA("BasePart") or not RealBall.Parent then
        if (CurrentTime - LastFromChange) > 0.5 then
            CachedFrom = nil
            CachedTarget = nil
            ActiveTarget = nil
            BallParries = 0
            CurrentKps = 0
            SmoothedKps = 0
        end
        IsParried = false
        AeroActive = false
        LastSpeed = 0
        LastBallInstance = nil
        LastDistance = 9999
        LastDotProduct = 0
        NextAutoClick = 0
        NextManualClick = 0
        NextPanicClick = 0
        RuntimeState.TargetSpeed = 0
        RuntimeState.TargetDistance = 0
        RuntimeState.TargetDot = 0
        RuntimeState.ParryRange = 15
        PullActive = false
        return
    end

    if RealBall ~= LastBallInstance then
        if LastBallInstance then
            BallPreviousVelocity[LastBallInstance] = nil
            AntiCurveData[LastBallInstance] = nil
        end
        LastBallInstance = RealBall
        LastDistance = 9999
        LastDotProduct = 0
        NextAutoClick = 0
        NextManualClick = 0
        NextPanicClick = 0
        if ConfigState.RandomAccuracy then
            GenerateRandomAccuracy()
        end
    end

    local PlayerCharacter = LocalPlayer.Character
    if not PlayerCharacter or typeof(PlayerCharacter) ~= "Instance" then return end

    local RootPart = PlayerCharacter.PrimaryPart
    if not RootPart or typeof(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") or not RootPart.Parent then return end

    if PlayerCharacter:FindFirstChild("SingularityCape") or RootPart:FindFirstChild("SingularityCape") then
        IsParried = false
        NextAutoClick = 0
        NextManualClick = 0
        NextPanicClick = 0
        return
    end

    local IsTkActive = false
    local BodyPart = RealBall:FindFirstChild("Body")
    if BodyPart and typeof(BodyPart) == "Instance" and BodyPart:FindFirstChild("At2") then
        IsTkActive = true
    end

    local IsPullActive = (CurrentTime - PullTime) <= 0.1

    if IsPullActive then
        IsParried = false
        NextAutoClick = 0
        NextManualClick = 0
        NextPanicClick = 0
        ScheduledTriggerTime = 0
        PullActive = true
        LastPullTime = CurrentTime
        return
    end

    if PullActive then
        IsParried = false
        return
    end

    local RootPosition = RootPart.Position
    local BallPosition = RealBall.Position
    local DeltaVector = RootPosition - BallPosition
    local CurrentDistance = DeltaVector.Magnitude

    if CurrentDistance == 0 then return end

    local BallVelocity = RealBall.AssemblyLinearVelocity
    if typeof(BallVelocity) ~= "Vector3" then BallVelocity = Vector3Zero end
    local CurrentSpeed = BallVelocity.Magnitude

    local ApproachSpeed = 0
    if LastDistance ~= 9999 then
        ApproachSpeed = FastMax((LastDistance - CurrentDistance) / CurrentDeltaTime, 0)
    end
    local EffectiveSpeed = FastMax(CurrentSpeed, ApproachSpeed)
    local SpeedDelta = FastMax(EffectiveSpeed - LastSpeed, 0)

    local VelocityDirection = BallVelocity.Magnitude > 0.01 and BallVelocity.Unit or Vector3Zero
    local DirectionToPlayerStat = DeltaVector.Unit
    local DotProductStat = DirectionToPlayerStat:Dot(VelocityDirection)
    
    local DotDelta = DotProductStat - LastDotProduct
    LastDotProduct = DotProductStat

    local IsMovingAway = CurrentDistance > LastDistance + 0.25

    RuntimeState.TargetSpeed = CurrentSpeed
    RuntimeState.TargetDistance = CurrentDistance
    RuntimeState.TargetDot = DotProductStat

    if EffectiveSpeed < 15 then
        LastSpeed = EffectiveSpeed
        return
    end

    local AeroVisualEffect = RealBall:FindFirstChild("AeroDynamicSlashVFX")
    local IsAeroWait = false

    if AeroVisualEffect then
        if not AeroActive then
            AeroActive = true
            AeroStartTime = CurrentTime
        end
        if (CurrentTime - AeroStartTime) < 0.2 or BallVelocity.Y > 10 then
            IsAeroWait = true
        end
    else
        AeroActive = false
    end

    if IsAeroWait then
        LastSpeed = EffectiveSpeed
        NextAutoClick = 0
        NextManualClick = 0
        NextPanicClick = 0
        return
    end

    local CurrentFromAttribute = RealBall:GetAttribute("from") or RealBall:GetAttribute("From")
    if CurrentFromAttribute ~= nil and CurrentFromAttribute ~= CachedFrom then
        CachedFrom = CurrentFromAttribute
        local CurrentWaitTime = FastClock()
        local TimeSinceLast = CurrentWaitTime - LastFromChange
        if TimeSinceLast <= 0.45 then
            BallParries = BallParries + 1
        else
            BallParries = 1
        end
        if TimeSinceLast > 0 then
            CurrentKps = 1 / TimeSinceLast
            SmoothedKps = SmoothedKps + (CurrentKps - SmoothedKps) * 0.25
        end
        LastFromChange = CurrentWaitTime
        if PullActive then
            PullActive = false
        end
        if ConfigState.RandomAccuracy then
            GenerateRandomAccuracy()
        end
    end
    
    local RawTarget = RealBall:GetAttribute("target") or RealBall:GetAttribute("Target")
    if RawTarget ~= nil and RawTarget ~= CachedTarget then
        CachedTarget = RawTarget
        task.spawn(function()
            task.wait(0.1)
            ActiveTarget = RawTarget
        end)
    end

    local IsTargetMe = false
    if PlayerCharacter and PlayerCharacter:FindFirstChild("Highlight") then
        IsTargetMe = true
    end

    local NetworkPing = GetMemoryPing()
    local NearestPlayer, DistanceToNearestPlayer = ScanForNearestEntity(RootPosition)

    local DeadFolder = WorkspaceService:FindFirstChild("Dead")
    local IsDead = DeadFolder and typeof(DeadFolder) == "Instance" and DeadFolder:FindFirstChild(LocalPlayer.Name) ~= nil
    local IsTrainingBall = RealBall.Parent and RealBall.Parent.Name == "TrainingBalls"
    local CanAttack = (not IsDead) and (not IsTrainingBall)

    if ConfigState.ManualSpam then
        if NextManualClick == 0 then
            NextManualClick = CurrentTime
        end
        local ClicksToPerform = 0
        local MaxClicksPerFrame = 120
        local YieldEvery = 15
        while CurrentTime >= NextManualClick and ClicksToPerform < MaxClicksPerFrame do
            if isrbxactive() then
                if ConfigState.ParryMethod == "Click" then
                    if typeof(Mouse1Click) == "function" then Mouse1Click() end
                else
                    if typeof(KeyPress) == "function" and typeof(KeyRelease) == "function" then 
                        KeyPress(0x46) 
                        KeyRelease(0x46) 
                    end
                end
            end
            NextManualClick = NextManualClick + ManualSpamInterval
            ClicksToPerform = ClicksToPerform + 1
            if ClicksToPerform % YieldEvery == 0 then
                task.wait()
            end
        end
    else
        ManualSpamAccumulator = 0
        NextManualClick = 0
    end

    local SpamParameters = {
        Speed = EffectiveSpeed,
        Parries = BallParries,
        BallDistance = CurrentDistance,
        EntityDistance = DistanceToNearestPlayer,
        Dot = DotProductStat,
        DotDelta = DotDelta,
        Ping = NetworkPing,
        IsMovingAway = IsMovingAway
    }

    local AutoSpamActive = false
    if ConfigState.AutoSpam and CanAttack then
        AutoSpamActive, _ = CheckIsSpam(SpamParameters)
    end

    if AutoSpamActive and not IsMovingAway and not (CurrentDistance > LastDistance) then
        if NextAutoClick == 0 then
            NextAutoClick = CurrentTime
        end
        while CurrentTime >= NextAutoClick do
            if ConfigState.ParryMethod == "Click" then
                if typeof(Mouse1Click) == "function" then Mouse1Click() end
            else
                if typeof(KeyPress) == "function" and typeof(KeyRelease) == "function" then KeyPress(0x46) KeyRelease(0x46) end
            end
            NextAutoClick = NextAutoClick + AutoSpamInterval
        end
        IsParried = true
        LastSpeed = EffectiveSpeed
        LastDistance = CurrentDistance
        return
    else
        NextAutoClick = 0
    end

    if ConfigState.PanicSpam then
        local PanicMaxDistance = 25
        local DangerZoneRadius = 15
        local ClosestEnemyDistanceSq = math.huge
        local EnemyLookDot = 0
        
        if not CachedAliveFolder then
            CachedAliveFolder = WorkspaceService:FindFirstChild("Alive")
        end
        
        if CachedAliveFolder and typeof(CachedAliveFolder) == "Instance" then
            for _, ObjectValue in ipairs(CachedAliveFolder:GetChildren()) do
                if typeof(ObjectValue) == "Instance" and ObjectValue ~= PlayerCharacter and ObjectValue.Name ~= LocalPlayer.Name then
                    local EnemyHumanoid = ObjectValue:FindFirstChildWhichIsA("Humanoid")
                    local EnemyRoot = ObjectValue:FindFirstChild("HumanoidRootPart") or ObjectValue.PrimaryPart
                    if EnemyHumanoid and typeof(EnemyHumanoid) == "Instance" and EnemyHumanoid.Health > 0 and EnemyRoot and typeof(EnemyRoot) == "Instance" and EnemyRoot:IsA("BasePart") then
                        local DistanceSq = GetDistanceSquared(EnemyRoot.Position, RootPosition)
                        if DistanceSq < ClosestEnemyDistanceSq then
                            ClosestEnemyDistanceSq = DistanceSq
                            local CFrameValue = EnemyRoot.CFrame
                            if CFrameValue then
                                local DirectionToMe = (RootPosition - EnemyRoot.Position).Unit
                                EnemyLookDot = CFrameValue.LookVector:Dot(DirectionToMe)
                            end
                        end
                    end
                end
            end
        end

        local ClosestEnemyDistance = FastSqrt(ClosestEnemyDistanceSq)
        local IsEnemyClose = ClosestEnemyDistance <= PanicMaxDistance
        local BallDirection = BallVelocity.Magnitude > 0.01 and BallVelocity.Unit or Vector3Zero
        local BallDotToMe = BallDirection:Dot(DirectionToPlayerStat)

        local DynamicDotThreshold = FastMax(0.40, (CurrentDistance / PanicMaxDistance) * 0.75)
        local AngleToPlayer = math.deg(math.acos(FastClamp(BallDotToMe, -1, 1)))
        local DynamicAngleThreshold = FastClamp(180 - (CurrentDistance * 2), 25, 75)

        local IsHeadingTowards = (AngleToPlayer <= DynamicAngleThreshold) or (BallDotToMe > DynamicDotThreshold)
        local IsExtremelyClose = CurrentDistance <= DangerZoneRadius
        local IsApproaching = CurrentDistance < LastDistance

        local IsClash = IsEnemyClose and CurrentSpeed > 35 and EnemyLookDot > 0.55 and (IsApproaching or IsExtremelyClose) and (IsHeadingTowards or IsExtremelyClose) and not IsMovingAway

        if IsClash then
            if NextPanicClick == 0 then
                NextPanicClick = CurrentTime
            end
            while CurrentTime >= NextPanicClick do
                ExecuteParryDirect()
                NextPanicClick = NextPanicClick + PanicSpamInterval
            end
        else
            NextPanicClick = 0
        end
    else
        NextPanicClick = 0
    end

    local CanTrigger = IsTargetMe
    if ConfigState.TriggerIgnoreSpawn and BallParries == 0 then
        CanTrigger = false
    end

    local ServerTickRate = 1 / FastMax(SmoothedServerFps, 30)

    if ConfigState.TriggerBot and CanAttack then
        if CanTrigger and not IsParried then
            local ApplicationTick = FastClock()
            if ScheduledTriggerTime == 0 then
                local PingSeconds = NetworkPing / 1000
                local BallSpeedFactor = FastClamp(EffectiveSpeed / 70, 0.55, 1.5)
                local DeltaCompensation = CurrentDeltaTime * 1.8
                local TickCompensation = ServerTickRate * 1.5
                local SpeedCompensation = FastClamp(EffectiveSpeed / 100, 0, 0.025)
                local TotalCompensation = PingSeconds + DeltaCompensation + TickCompensation + SpeedCompensation
                local BaseDelay = (ConfigState.TriggerDelay / 1000) * BallSpeedFactor
                local FinalDelay = FastMax(0, BaseDelay - TotalCompensation * 0.95)
                ScheduledTriggerTime = ApplicationTick + FinalDelay
            end
            if ScheduledTriggerTime > 0 and ApplicationTick >= ScheduledTriggerTime then
                IsParried = true
                ExecuteParry()
                ScheduledTriggerTime = 0
            end
        elseif not CanTrigger then
            ScheduledTriggerTime = 0
        end
    else
        ScheduledTriggerTime = 0
    end

    if IsTargetMe then
        if IsParried then
            LastSpeed = EffectiveSpeed
            LastDistance = CurrentDistance
            return
        end

        local VelocityUnit = CurrentSpeed > 0 and VelocityDirection or Vector3Zero
        local DirectionToPlayer = CurrentDistance > 0 and (RootPosition - BallPosition).Unit or Vector3Zero
        local DotProductParry = VelocityUnit:Dot(DirectionToPlayer)

        local PingSeconds = NetworkPing / 1000
        local ReactionTime = PingSeconds + CurrentDeltaTime + ServerTickRate
        local TimeToImpact = CurrentDistance / FastMax(EffectiveSpeed, 1)

        local IsPointBlank = false
        local FatalDistance = EffectiveSpeed * ReactionTime + 7.5

        if CurrentDistance <= 18 then
            if DotProductParry > 0.05 then
                IsPointBlank = true
            end
        elseif CurrentDistance <= FatalDistance and DotProductParry > 0.18 then
            IsPointBlank = true
        elseif TimeToImpact <= ReactionTime and DotProductParry > 0.08 then
            IsPointBlank = true
        end

        local IsSnap = false
        if CurrentDistance < 28 and DotDelta > 0.12 and DotProductParry > 0.35 then
            IsSnap = true
        end

        local SafeKps = type(SmoothedKps) == "number" and SmoothedKps or 0
        local PredictionTime = PingSeconds + CurrentDeltaTime * 2.2 + (SafeKps / 20 * 0.025)
        local PredictedBallPos = BallPosition + (BallVelocity * PredictionTime)
        local PredictedDistance = GetDistanceBetween(RootPosition, PredictedBallPos)
        
        local SpeedFactor = FastClamp(EffectiveSpeed / 85, 0.6, 1.45)
        local DynamicPredictedThreshold = 14 + (SpeedFactor * 6)
        
        local UpclosePredictedHit = PredictedDistance <= DynamicPredictedThreshold and DotProductParry > 0.22
        
        local ShortTermPrediction = BallPosition + (BallVelocity * (PingSeconds * 0.6 + CurrentDeltaTime * 0.9))
        local ShortTermDistance = GetDistanceBetween(RootPosition, ShortTermPrediction)
        local VeryClosePredictedHit = ShortTermDistance <= 11 and DotProductParry > 0.15 and EffectiveSpeed > 55

        local KpsIntensity = FastClamp(SmoothedKps, 0, 20) / 20
        local KpsMitigation = 1 - (KpsIntensity * 0.55)

        local AccuracyValue = ConfigState.RandomAccuracy and RuntimeState.GeneratedAccuracy or ConfigState.Accuracy
        if ConfigState.RandomAccuracy then
            local ExtraJitter = (math.random() - 0.5) * 3.2
            AccuracyValue = FastClamp(AccuracyValue + ExtraJitter, 1, 100)
        end
        local AccuracyScale = (AccuracyValue - 1) / 99
        local AccuracyMultiplier = 0.82 + (AccuracyScale * 0.35)

        local DynamicScaling = FastMax(EffectiveSpeed - 9.5, 0) * 0.002
        local SpeedDivisorBase = 2.4 + DynamicScaling
        local FinalSpeedDivisor = SpeedDivisorBase * AccuracyMultiplier

        local ExtraFactor = 2.5 + DynamicScaling * 0.45
        local ExtrapolationDistance = EffectiveSpeed * CurrentDeltaTime * ExtraFactor * KpsMitigation

        local BaseDistance = FastMax(EffectiveSpeed / FinalSpeedDivisor, 9.5)
        local EarlyBoost = (1 - AccuracyScale) * 3.65

        local UnifiedThreshold = FastMax(BaseDistance + ExtrapolationDistance + (KpsIntensity * 1.5) + EarlyBoost, 9.5)
        
        local CloseRangeThreshold = FastMax(15, UnifiedThreshold * 0.5)
        
        local CurveMultiplier = 1.0
        if CurrentDistance > CloseRangeThreshold and not IsPointBlank and not IsSnap then
            CurveMultiplier = GetCurveMultiplier(RealBall, RootPosition, BallVelocity)
        end

        local IsWarping = DetectPositionWarp(RealBall, CurrentDeltaTime)
        if IsWarping then
            BallWarpBoostUntil[RealBall] = tick() + 0.45
        end

        local WarpBoost = 1.0
        if BallWarpBoostUntil[RealBall] and tick() < BallWarpBoostUntil[RealBall] then
            WarpBoost = 1.35
        end

        UnifiedThreshold = UnifiedThreshold * CurveMultiplier * WarpBoost
        RuntimeState.ParryRange = UnifiedThreshold

        local IsCurved = false
        if CurrentSpeed > 15 then
            local DistanceRatio = FastClamp((CurrentDistance - 35.0) / 55.0, 0, 1)
            local MaxDotThreshold = 0.82 - (0.05 * (1 - AccuracyScale))
            local MinDotThreshold = 0.55 - (0.05 * (1 - AccuracyScale))
            local DynamicDot = MinDotThreshold + (MaxDotThreshold - MinDotThreshold) * math.pow(DistanceRatio, 1.5)
            local CurveCompensation = CurrentDeltaTime * ExtraFactor * KpsMitigation
            local DotThreshold = DynamicDot - (CurveCompensation * 0.15)
            
            if CurrentDistance > CloseRangeThreshold * (1.1 - (0.4 * (1 - AccuracyScale))) and DotProductParry < DotThreshold then
                IsCurved = true
            end
        end

        if CurrentDistance <= 22 then
            IsCurved = false
        end

        if not IsPointBlank and not IsSnap and CurrentDistance <= 14 and DotProductParry > 0.03 and not IsMovingAway then
            if ConfigState.AutoParry then
                IsParried = true
                ExecuteParryDirect()
            end
            LastSpeed = EffectiveSpeed
            LastDistance = CurrentDistance
            return
        end

        if ConfigState.AutoParryType == "Old" then
            if IsPointBlank or IsSnap then
                if ConfigState.AutoParry then
                    IsParried = true
                    ExecuteParryDirect()
                end
            elseif CurrentDistance <= UnifiedThreshold and not IsMovingAway and not IsCurved then
                if ConfigState.AutoParry then
                    IsParried = true
                    ExecuteParryDirect()
                end
            end
        else
            if IsPointBlank or IsSnap or UpclosePredictedHit or VeryClosePredictedHit then
                if ConfigState.AutoParry then
                    IsParried = true
                    ExecuteParryDirect()
                end
            elseif CurrentDistance <= UnifiedThreshold and not IsMovingAway and not IsCurved then
                if ConfigState.AutoParry then
                    IsParried = true
                    ExecuteParryDirect()
                end
            end
        end
    else
        IsParried = false
    end

    LastSpeed = EffectiveSpeed
    LastDistance = CurrentDistance
end)

RunService.RenderStepped:Connect(function(DeltaTime)
    pcall(function()
        if not ConfigState.OrbitBall then return end
        local AliveFolder = WorkspaceService:FindFirstChild("Alive")
        if not AliveFolder or typeof(AliveFolder) ~= "Instance" or not AliveFolder:FindFirstChild(LocalPlayer.Name) then return end
        local RealBall = GetRealBall()
        if not RealBall or typeof(RealBall) ~= "Instance" or not RealBall:IsA("BasePart") or not RealBall.Parent then return end
        local CharacterObject = LocalPlayer.Character
        if not CharacterObject or typeof(CharacterObject) ~= "Instance" then return end
        local RootPart = CharacterObject.PrimaryPart
        if not RootPart or typeof(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") or not RootPart.Parent then
            RootPart = CharacterObject:FindFirstChild("HumanoidRootPart")
            if not RootPart or typeof(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") or not RootPart.Parent then return end
        end
        local BallPosition = RealBall.Position
        local TimeValue = os.clock() * (ConfigState.OrbitSpeed / 50)
        local OrbitPosition = Vector3.new(
            BallPosition.X + math.cos(TimeValue) * ConfigState.OrbitRadius,
            BallPosition.Y + ConfigState.OrbitHeight,
            BallPosition.Z + math.sin(TimeValue) * ConfigState.OrbitRadius
        )
        local TargetCframe = CFrame.lookAt(OrbitPosition, BallPosition)
        local LerpAlpha = math.clamp(DeltaTime * 35, 0, 0.65)
        pcall(function()
            RootPart.CFrame = RootPart.CFrame:Lerp(TargetCframe, LerpAlpha)
        end)
    end)
end)
