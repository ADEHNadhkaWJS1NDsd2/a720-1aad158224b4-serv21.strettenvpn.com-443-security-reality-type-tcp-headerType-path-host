local LOGO_URL = "https://files.catbox.moe/tzc225.png"
local BG_URL = "https://files.catbox.moe/pli6ip.png"

if game.GameId ~= 4777817887 then
    warn("Join in Blade Ball")
    return
end

print("Loaded Blade Ball")

if _G.NightfallDrawings then
    for _, DrawingObject in pairs(_G.NightfallDrawings) do
        if DrawingObject and type(DrawingObject.Remove) == "function" then
            DrawingObject:Remove()
        end
    end
end

_G.NightfallDrawings = {}

local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")

local LocalPlayer = PlayersService.LocalPlayer
if not LocalPlayer then
    for _ = 1, 200 do
        task.wait(0.05)
        LocalPlayer = PlayersService.LocalPlayer
        if LocalPlayer then break end
    end
end
if not LocalPlayer then return end

local Mouse1Click = mouse1click
local KeyPress = keypress
local KeyRelease = keyrelease

local function IsValidNumber(Value)
    return type(Value) == "number" and Value == Value and Value ~= math.huge and Value ~= -math.huge
end

local function IsValidVector3(Value)
    return typeof(Value) == "Vector3"
        and IsValidNumber(Value.X)
        and IsValidNumber(Value.Y)
        and IsValidNumber(Value.Z)
end

local function IsValidVector2(Value)
    return typeof(Value) == "Vector2"
        and IsValidNumber(Value.X)
        and IsValidNumber(Value.Y)
end

local function GetPartPosition(PartObject)
    if not PartObject or typeof(PartObject) ~= "Instance" or not PartObject:IsA("BasePart") then
        return nil
    end

    local Position = PartObject.Position
    if not IsValidVector3(Position) then
        return nil
    end

    return Position
end

local function GetPartVelocity(PartObject)
    if not PartObject or typeof(PartObject) ~= "Instance" or not PartObject:IsA("BasePart") then
        return nil
    end

    local Velocity = PartObject.AssemblyLinearVelocity
    if not IsValidVector3(Velocity) then
        Velocity = PartObject.Velocity
    end

    if not IsValidVector3(Velocity) then
        return nil
    end

    return Velocity
end

local function GetPartSize(PartObject)
    if not PartObject or typeof(PartObject) ~= "Instance" or not PartObject:IsA("BasePart") then
        return nil
    end

    local Size = PartObject.Size
    if not IsValidVector3(Size) then
        return nil
    end

    return Size
end

local function GetDistanceBetween(PositionA, PositionB)
    if not IsValidVector3(PositionA) or not IsValidVector3(PositionB) then return math.huge end
    local DeltaX = PositionA.X - PositionB.X
    local DeltaY = PositionA.Y - PositionB.Y
    local DeltaZ = PositionA.Z - PositionB.Z
    return math.sqrt(DeltaX * DeltaX + DeltaY * DeltaY + DeltaZ * DeltaZ)
end

local function GetVectorMagnitude(VectorValue)
    if not IsValidVector3(VectorValue) then return 0 end
    return math.sqrt(VectorValue.X * VectorValue.X + VectorValue.Y * VectorValue.Y + VectorValue.Z * VectorValue.Z)
end

local function NormalizeVector(VectorValue)
    if not IsValidVector3(VectorValue) then return Vector3.zero end
    local Magnitude = GetVectorMagnitude(VectorValue)
    if Magnitude < 0.0001 then return Vector3.zero end
    return Vector3.new(VectorValue.X / Magnitude, VectorValue.Y / Magnitude, VectorValue.Z / Magnitude)
end

local function GetDotProduct(VectorA, VectorB)
    if not IsValidVector3(VectorA) or not IsValidVector3(VectorB) then return 0 end
    return VectorA.X * VectorB.X + VectorA.Y * VectorB.Y + VectorA.Z * VectorB.Z
end

local function LerpVector2(A, B, T)
    if not IsValidVector2(A) or not IsValidVector2(B) or not IsValidNumber(T) then
        return IsValidVector2(B) and B or Vector2.new(0, 0)
    end
    return Vector2.new(
        A.X + (B.X - A.X) * T,
        A.Y + (B.Y - A.Y) * T
    )
end

local BallPreviousVelocity = {}
local AntiCurveData = {}
local BallVelocityHistory = {}
local BallLastPosition = {}
local BallWarpBoostUntil = {}

local function GetCurveMultiplier(BallInstance, RootPosition, CurrentVelocity)
    if not BallInstance or typeof(BallInstance) ~= "Instance" or not BallInstance:IsA("BasePart") then return 1 end
    if not IsValidVector3(RootPosition) or not IsValidVector3(CurrentVelocity) then return 1 end

    local BallPosition = GetPartPosition(BallInstance)
    if not BallPosition then return 1 end

    local History = BallVelocityHistory[BallInstance]
    if not History then
        History = {}
        BallVelocityHistory[BallInstance] = History
    end

    table.insert(History, CurrentVelocity)
    if #History > 12 then table.remove(History, 1) end

    local PreviousVelocity = BallPreviousVelocity[BallInstance]
    if not IsValidVector3(PreviousVelocity) then
        BallPreviousVelocity[BallInstance] = CurrentVelocity
        AntiCurveData[BallInstance] = {
            SmoothAx = 0,
            SmoothAy = 0,
            SmoothAz = 0,
            Frames = 0,
            PrevLateral = 0,
            PrevAngular = 0
        }
        return 1
    end

    local Data = AntiCurveData[BallInstance]
    if not Data then
        Data = {
            SmoothAx = 0,
            SmoothAy = 0,
            SmoothAz = 0,
            Frames = 0,
            PrevLateral = 0,
            PrevAngular = 0
        }
        AntiCurveData[BallInstance] = Data
    end

    local AccelerationX = CurrentVelocity.X - PreviousVelocity.X
    local AccelerationY = CurrentVelocity.Y - PreviousVelocity.Y
    local AccelerationZ = CurrentVelocity.Z - PreviousVelocity.Z
    BallPreviousVelocity[BallInstance] = CurrentVelocity

    Data.SmoothAx = Data.SmoothAx * 0.7 + AccelerationX * 0.3
    Data.SmoothAy = Data.SmoothAy * 0.7 + AccelerationY * 0.3
    Data.SmoothAz = Data.SmoothAz * 0.7 + AccelerationZ * 0.3

    local AccelerationMagnitude = math.sqrt(Data.SmoothAx^2 + Data.SmoothAy^2 + Data.SmoothAz^2)
    if AccelerationMagnitude < 0.1 then
        Data.Frames = 0
        return 1
    end

    local DeltaX = RootPosition.X - BallPosition.X
    local DeltaY = RootPosition.Y - BallPosition.Y
    local DeltaZ = RootPosition.Z - BallPosition.Z
    local Distance = math.sqrt(DeltaX^2 + DeltaY^2 + DeltaZ^2)
    if Distance < 12 then
        Data.Frames = 0
        return 1
    end

    local RadialAcceleration = Data.SmoothAx * (DeltaX / Distance) + Data.SmoothAy * (DeltaY / Distance) + Data.SmoothAz * (DeltaZ / Distance)
    local LateralAccelerationSq = math.max(AccelerationMagnitude^2 - RadialAcceleration^2, 0)
    local LateralAcceleration = math.sqrt(LateralAccelerationSq)
    local AngularDeviation = 0

    if #History >= 4 then
        for Index = 2, #History do
            local PreviousDirection = NormalizeVector(History[Index - 1])
            local CurrentDirection = NormalizeVector(History[Index])
            local DotValue = math.clamp(GetDotProduct(PreviousDirection, CurrentDirection), -1, 1)
            local Angle = math.deg(math.acos(DotValue))
            if IsValidNumber(Angle) then
                AngularDeviation = AngularDeviation + Angle / 25
            end
        end
    end

    local LateralTrend = LateralAcceleration - Data.PrevLateral
    local AngularTrend = AngularDeviation - Data.PrevAngular
    Data.PrevLateral = LateralAcceleration
    Data.PrevAngular = AngularDeviation

    local IsStrongCurve = (LateralAcceleration > 38 and RadialAcceleration > -8) or AngularDeviation > 4.5
    local IsGrowingCurve = (LateralTrend > 8 and AngularTrend > 1.5) or (LateralAcceleration > 55 and AngularDeviation > 6)

    if IsStrongCurve or IsGrowingCurve then
        Data.Frames = Data.Frames + 1
        if Data.Frames >= 3 then
            local Severity = math.min(LateralAcceleration / 85, 1.2)
            local AngularBoost = math.min(AngularDeviation / 9, 0.9)
            local TrendBoost = IsGrowingCurve and math.min((LateralTrend + AngularTrend) / 25, 0.45) or 0
            return 1 + 0.65 * Severity + AngularBoost + TrendBoost
        end
    else
        Data.Frames = 0
    end

    return 1
end

local function DetectPositionWarp(BallInstance, DeltaTime)
    if not BallInstance or typeof(BallInstance) ~= "Instance" or not BallInstance:IsA("BasePart") then return false end
    if not IsValidNumber(DeltaTime) or DeltaTime <= 0 then return false end

    local CurrentPosition = GetPartPosition(BallInstance)
    if not CurrentPosition then return false end

    local PreviousPosition = BallLastPosition[BallInstance]
    if not IsValidVector3(PreviousPosition) then
        BallLastPosition[BallInstance] = CurrentPosition
        return false
    end

    local PreviousVelocity = BallPreviousVelocity[BallInstance]
    if not IsValidVector3(PreviousVelocity) or GetVectorMagnitude(PreviousVelocity) < 5 then
        BallLastPosition[BallInstance] = CurrentPosition
        return false
    end

    local ExpectedPosition = PreviousPosition + PreviousVelocity * DeltaTime
    local Deviation = GetDistanceBetween(CurrentPosition, ExpectedPosition)
    BallLastPosition[BallInstance] = CurrentPosition
    return IsValidNumber(Deviation) and Deviation > 4.5
end

local LibraryInstance
local LoaderUrl = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.min.lua"

for Index = 1, 10 do
    local CacheBuster = "?cb=" .. tostring((math.floor(os.clock() * 1000) + Index * 7919) % 2000000000)
    local ResponseData = game:HttpGet(LoaderUrl .. CacheBuster)

    if type(ResponseData) == "string" and #ResponseData > 1000 then
        _G.NightfallLoadedLibrary = nil
        local WrappedSource = "_G.NightfallLoadedLibrary = (function()\n" .. ResponseData .. "\nend)()"
        local LoadedFunction = loadstring(WrappedSource)

        if type(LoadedFunction) == "function" then
            LoadedFunction()
        end

        local PublicInstance = _G.NightfallLoadedLibrary or _G.INSui
        if type(PublicInstance) == "table" and type(PublicInstance.CreateWindow) == "function" then
            LibraryInstance = PublicInstance
            break
        end
    end

    task.wait(0.4)
end

_G.NightfallLoadedLibrary = nil
if type(LibraryInstance) ~= "table" then return end

LibraryInstance:SetTheme("Indigo")

local WindowApp = LibraryInstance:CreateWindow({
    title = "Nightfall",
    subtitle = "Blade Ball",
    size = Vector2.new(700, 552),
    configName = "Nightfall",
    configFolder = "BladeballConfigs",
    menuKey = "F2",
    badge = "v2",
    logo = LOGO_URL,
    logoSize = 34,
    checkboxStyle = true
})

LibraryInstance:SetBackgroundImage(BG_URL, 0.22, 0.7, 0.09)

local ConfigState = {
    AutoParry = false,
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
    NightfallWings = false,
    NightfallWingsColor = Color3.fromRGB(120, 60, 220),
    NightfallWingsSwingSpeed = 1.45,
    NightfallChinaHat = false,
    NightfallChinaHatColor = Color3.fromRGB(112, 64, 225),
    NightfallChinaHatScale = 1,
    NightfallChinaHatHeight = 0,
    NightfallChinaHatRadius = 1.55,
    NightfallChinaHatConeHeight = 1.30,
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


local NightfallWingsUrl = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/wings.luau"
local NightfallChinaHatUrl = "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/china.luau"

local NightfallWingsController = nil
local NightfallChinaHatController = nil
local NightfallWingsLoading = false
local NightfallChinaHatLoading = false

local function FetchExternalControllerSource(Url)
    if type(Url) ~= "string" or Url == "" then return nil end

    local CacheValue = tostring(math.floor(os.clock() * 1000000)) .. tostring(math.random(100000, 999999))
    local SourceData = game:HttpGet(Url .. "?cb=" .. CacheValue)

    if type(SourceData) ~= "string" or #SourceData < 1000 then
        return nil
    end

    return SourceData
end

local function ExecuteExternalController(SourceData, GlobalName)
    if type(SourceData) ~= "string" or type(GlobalName) ~= "string" or type(loadstring) ~= "function" then
        return nil
    end

    local CompatibilityPrefix = [[
local pcall = pcall or function(FunctionValue, ...)
    return true, FunctionValue(...)
end
]]

    local WrappedSource = CompatibilityPrefix .. "\nreturn (function()\n" .. SourceData .. "\nend)()"
    local LoaderFunction = loadstring(WrappedSource)
    if type(LoaderFunction) ~= "function" then
        return nil
    end

    local ControllerValue = LoaderFunction()
    if type(ControllerValue) ~= "table" then
        ControllerValue = _G[GlobalName]
    end

    if type(ControllerValue) ~= "table" then
        return nil
    end

    _G[GlobalName] = ControllerValue
    return ControllerValue
end

local function GetNightfallWingsController()
    local ControllerValue = NightfallWingsController or _G.NightfallWingsController

    if type(ControllerValue) == "table"
        and ControllerValue.Running ~= false
        and type(ControllerValue.SetEnabled) == "function"
        and type(ControllerValue.SetColor) == "function"
        and type(ControllerValue.SetSwingSpeed) == "function"
    then
        NightfallWingsController = ControllerValue
        return ControllerValue
    end

    NightfallWingsController = nil
    return nil
end

local function ApplyNightfallWingsState()
    local ControllerValue = GetNightfallWingsController()
    if not ControllerValue then return end

    ControllerValue:SetColor(ConfigState.NightfallWingsColor)
    ControllerValue:SetSwingSpeed(ConfigState.NightfallWingsSwingSpeed)
    ControllerValue:SetEnabled(ConfigState.NightfallWings)
end

local function LoadNightfallWings()
    local ExistingController = GetNightfallWingsController()
    if ExistingController then return ExistingController end
    if NightfallWingsLoading then return nil end

    NightfallWingsLoading = true

    local SourceData = FetchExternalControllerSource(NightfallWingsUrl)
    local ControllerValue = nil

    if SourceData then
        ControllerValue = ExecuteExternalController(SourceData, "NightfallWingsController")
    end

    NightfallWingsLoading = false
    NightfallWingsController = ControllerValue

    return GetNightfallWingsController()
end

local function SetNightfallWingsEnabled(Value)
    ConfigState.NightfallWings = Value == true

    local ControllerValue = GetNightfallWingsController()

    if not ConfigState.NightfallWings then
        if ControllerValue then
            ControllerValue:SetEnabled(false)
        end
        return
    end

    if ControllerValue then
        ApplyNightfallWingsState()
        return
    end

    task.spawn(function()
        local LoadedController = LoadNightfallWings()
        if LoadedController then
            ApplyNightfallWingsState()
        end
    end)
end

local function SetNightfallWingsColor(Value)
    if typeof(Value) ~= "Color3" then return end

    ConfigState.NightfallWingsColor = Value

    local ControllerValue = GetNightfallWingsController()
    if ControllerValue then
        ControllerValue:SetColor(Value)
    end
end

local function SetNightfallWingsSwingSpeed(Value)
    if type(Value) ~= "number" then return end

    ConfigState.NightfallWingsSwingSpeed = math.clamp(Value, 0.1, 6)

    local ControllerValue = GetNightfallWingsController()
    if ControllerValue then
        ControllerValue:SetSwingSpeed(ConfigState.NightfallWingsSwingSpeed)
    end
end

local ExistingNightfallWingsController = GetNightfallWingsController()
if ExistingNightfallWingsController then
    ExistingNightfallWingsController:SetEnabled(false)
end

local function GetNightfallChinaHatController()
    local ControllerValue = NightfallChinaHatController or _G.NightfallChinaHatController

    if type(ControllerValue) == "table"
        and ControllerValue.Running ~= false
        and type(ControllerValue.SetEnabled) == "function"
        and type(ControllerValue.SetColor) == "function"
        and type(ControllerValue.SetScale) == "function"
        and type(ControllerValue.SetHeight) == "function"
        and type(ControllerValue.SetRadius) == "function"
        and type(ControllerValue.SetConeHeight) == "function"
    then
        NightfallChinaHatController = ControllerValue
        return ControllerValue
    end

    NightfallChinaHatController = nil
    return nil
end

local function ApplyNightfallChinaHatState()
    local ControllerValue = GetNightfallChinaHatController()
    if not ControllerValue then return end

    ControllerValue:SetColor(ConfigState.NightfallChinaHatColor)
    ControllerValue:SetScale(ConfigState.NightfallChinaHatScale)
    ControllerValue:SetHeight(ConfigState.NightfallChinaHatHeight)
    ControllerValue:SetRadius(ConfigState.NightfallChinaHatRadius)
    ControllerValue:SetConeHeight(ConfigState.NightfallChinaHatConeHeight)
    ControllerValue:SetEnabled(ConfigState.NightfallChinaHat)
end

local function LoadNightfallChinaHat()
    local ExistingController = GetNightfallChinaHatController()
    if ExistingController then return ExistingController end
    if NightfallChinaHatLoading then return nil end

    NightfallChinaHatLoading = true

    local SourceData = FetchExternalControllerSource(NightfallChinaHatUrl)
    local ControllerValue = nil

    if SourceData then
        ControllerValue = ExecuteExternalController(SourceData, "NightfallChinaHatController")
    end

    NightfallChinaHatLoading = false
    NightfallChinaHatController = ControllerValue

    return GetNightfallChinaHatController()
end

local function SetNightfallChinaHatEnabled(Value)
    ConfigState.NightfallChinaHat = Value == true

    local ControllerValue = GetNightfallChinaHatController()

    if not ConfigState.NightfallChinaHat then
        if ControllerValue then
            ControllerValue:SetEnabled(false)
        end
        return
    end

    if ControllerValue then
        ApplyNightfallChinaHatState()
        return
    end

    task.spawn(function()
        local LoadedController = LoadNightfallChinaHat()
        if LoadedController then
            ApplyNightfallChinaHatState()
        end
    end)
end

local function SetNightfallChinaHatColor(Value)
    if typeof(Value) ~= "Color3" then return end

    ConfigState.NightfallChinaHatColor = Value

    local ControllerValue = GetNightfallChinaHatController()
    if ControllerValue then
        ControllerValue:SetColor(Value)
    end
end

local function SetNightfallChinaHatScale(Value)
    if type(Value) ~= "number" then return end

    ConfigState.NightfallChinaHatScale = Value

    local ControllerValue = GetNightfallChinaHatController()
    if ControllerValue then
        ControllerValue:SetScale(Value)
    end
end

local function SetNightfallChinaHatHeight(Value)
    if type(Value) ~= "number" then return end

    ConfigState.NightfallChinaHatHeight = Value

    local ControllerValue = GetNightfallChinaHatController()
    if ControllerValue then
        ControllerValue:SetHeight(Value)
    end
end

local function SetNightfallChinaHatRadius(Value)
    if type(Value) ~= "number" then return end

    ConfigState.NightfallChinaHatRadius = Value

    local ControllerValue = GetNightfallChinaHatController()
    if ControllerValue then
        ControllerValue:SetRadius(Value)
    end
end

local function SetNightfallChinaHatConeHeight(Value)
    if type(Value) ~= "number" then return end

    ConfigState.NightfallChinaHatConeHeight = Value

    local ControllerValue = GetNightfallChinaHatController()
    if ControllerValue then
        ControllerValue:SetConeHeight(Value)
    end
end

local ExistingNightfallChinaHatController = GetNightfallChinaHatController()
if ExistingNightfallChinaHatController then
    ExistingNightfallChinaHatController:SetEnabled(false)
end

local RuntimeState = {
    TargetSpeed = 0,
    TargetDistance = 0,
    TargetDot = 0,
    ParryRange = 15,
    GeneratedAccuracy = 100,
    ShouldSpam = false,
    PanicShouldSpam = false
}

local OffsetsData = {
    Transparency = 0xD0,
    Parent = 0x68,
    DecalTexture = 0x180
}

local function IsValidAddress(AddressValue)
    return type(AddressValue) == "number" and AddressValue > 0xFFF
end

local function WriteFloat(AddressValue, FloatValue)
    if IsValidAddress(AddressValue) and IsValidNumber(FloatValue) then
        memory_write("float", AddressValue, FloatValue)
    end
end

local function WritePointer(AddressValue, PointerValue)
    if IsValidAddress(AddressValue) and type(PointerValue) == "number" then
        memory_write("uintptr_t", AddressValue, PointerValue)
    end
end

local function GenerateRandomAccuracy()
    local MinimumAccuracy = math.min(ConfigState.RandomAccuracyMin, ConfigState.RandomAccuracyMax)
    local MaximumAccuracy = math.max(ConfigState.RandomAccuracyMin, ConfigState.RandomAccuracyMax)
    
    local BaseRandom = MinimumAccuracy + (math.random() * (MaximumAccuracy - MinimumAccuracy))
    local Jitter = (math.random() - 0.5) * 4.5
    local FinalValue = math.clamp(BaseRandom + Jitter, MinimumAccuracy, MaximumAccuracy)
    
    RuntimeState.GeneratedAccuracy = FinalValue
end

local CombatTab = WindowApp:Tab("Combat", "swords")

local AutoParrySection = CombatTab:Section("Auto Parry", "Left", "")
local AutoParryToggle = AutoParrySection:Toggle("Enabled", false, function(Value)
    ConfigState.AutoParry = Value
end)
AutoParryToggle:AddKeybind("None", "Toggle")
AutoParrySection:Slider("Accuracy", 100, 1, 1, 100, "%", function(Value)
    ConfigState.Accuracy = Value
end)
local RandomAccuracyToggle = AutoParrySection:Toggle("Random Accuracy", false, function(Value)
    ConfigState.RandomAccuracy = Value
end)
AutoParrySection:RangeSlider("Accuracy Range", 80, 100, 1, 1, 100, "%", function(MinValue, MaxValue)
    ConfigState.RandomAccuracyMin = MinValue
    ConfigState.RandomAccuracyMax = MaxValue
end):DependsOn(RandomAccuracyToggle)
AutoParrySection:Dropdown("Input Method", {"Click"}, {"Click", "Key"}, false, function(Value)
    ConfigState.ParryMethod = type(Value) == "table" and Value[1] or Value
end)
AutoParrySection:Toggle("Training Ball Support", false, function(Value)
    ConfigState.TrainingBallsSupport = Value
end)

local SpamSection = CombatTab:Section("Spam", "Right", "")
SpamSection:Toggle("Auto Spam", false, function(Value)
    ConfigState.AutoSpam = Value
end):AddKeybind("None", "Toggle")
SpamSection:Toggle("Manual Spam", false, function(Value)
    ConfigState.ManualSpam = Value
end):AddKeybind("None", "Toggle")
SpamSection:Toggle("Panic Spam", false, function(Value)
    ConfigState.PanicSpam = Value
end)
SpamSection:Slider("Rate", 200, 25, 200, 1000, "/s", function(Value)
    ConfigState.SpamRate = Value
end)
SpamSection:Slider("Sensitivity", 3, 1, 1, 5, "", function(Value)
    ConfigState.SpamSensitivity = Value
end)

local OrbitSection = CombatTab:Section("Orbit", "Left", "")
OrbitSection:Toggle("Enabled", false, function(Value)
    ConfigState.OrbitBall = Value
end):AddKeybind("None", "Toggle")
OrbitSection:Slider("Radius", 25, 1, 5, 100, "", function(Value)
    ConfigState.OrbitRadius = Value
end)
OrbitSection:Slider("Speed", 50, 1, 10, 200, "", function(Value)
    ConfigState.OrbitSpeed = Value
end)
OrbitSection:Slider("Height", 5, 0.5, -30, 50, "", function(Value)
    ConfigState.OrbitHeight = Value
end)

local TriggerSection = CombatTab:Section("Trigger Parry", "Right", "")
TriggerSection:Toggle("Enabled", false, function(Value)
    ConfigState.TriggerBot = Value
end):AddKeybind("None", "Toggle")
TriggerSection:Slider("Delay", 0, 1, 0, 100, "ms", function(Value)
    ConfigState.TriggerDelay = Value
end)
TriggerSection:Toggle("Ignore Spawn", false, function(Value)
    ConfigState.TriggerIgnoreSpawn = Value
end)

local VisualsTab = WindowApp:Tab("Visuals", "eye")

local ParryRangeSection = VisualsTab:Section("Parry Range", "Left", "")
ParryRangeSection:Toggle("Enabled", false, function(Value)
    ConfigState.ParryVisualizer = Value
end):AddColorpicker("Color", Color3.fromRGB(220, 30, 30), function(ColorValue)
    ConfigState.VisualizerColor = ColorValue
end)
ParryRangeSection:Slider("Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value)
    ConfigState.VisThickness = Value
end)
ParryRangeSection:Slider("Transparency", 1.0, 0.1, 0.1, 1.0, "", function(Value)
    ConfigState.VisTransparency = Value
end)
ParryRangeSection:Slider("Segments", 40, 1, 10, 100, "", function(Value)
    ConfigState.VisSegments = Value
end)

local BallTrailSection = VisualsTab:Section("Ball Trail", "Right", "")
BallTrailSection:Toggle("Enabled", false, function(Value)
    ConfigState.BallTrail = Value
end):AddColorpicker("Color", Color3.fromRGB(220, 30, 30), function(ColorValue)
    ConfigState.TrailColor = ColorValue
end)
BallTrailSection:Slider("Length", 60, 1, 3, 100, "", function(Value)
    ConfigState.TrailLength = Value
end)
BallTrailSection:Slider("Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Value)
    ConfigState.TrailThickness = Value
end)

local AbilityEspSection = VisualsTab:Section("Ability ESP", "Left", "")
AbilityEspSection:Toggle("Enabled", false, function(Value)
    ConfigState.AbilityEsp = Value
end)
AbilityEspSection:Colorpicker("Color", Color3.fromRGB(220, 30, 30), function(Color)
    ConfigState.EspColor = Color or Color3.fromRGB(220, 30, 30)
end, 1)
AbilityEspSection:Slider("Text Size", 18, 1, 10, 40, "", function(Value)
    ConfigState.EspTextSize = Value
end)
AbilityEspSection:Slider("Vertical Offset", 2.0, 0.5, 0.0, 10.0, "", function(Value)
    ConfigState.EspOffsetY = Value
end)

local EffectsSection = VisualsTab:Section("Effects", "Right", "")
EffectsSection:Toggle("Rainbow", false, function(Value)
    ConfigState.RainbowMode = Value
end)

local WingsSection = VisualsTab:Section("Wings", "Left", "")
local WingsToggle = WingsSection:Toggle("Enabled", false, function(Value)
    SetNightfallWingsEnabled(Value)
end)
WingsToggle:AddColorpicker("Color", ConfigState.NightfallWingsColor, function(ColorValue)
    SetNightfallWingsColor(ColorValue)
end)
WingsSection:Slider("Animation Speed", ConfigState.NightfallWingsSwingSpeed, 0.05, 0.1, 6, "x", function(Value)
    SetNightfallWingsSwingSpeed(Value)
end)

local ChinaHatSection = VisualsTab:Section("China Hat", "Right", "")
local ChinaHatToggle = ChinaHatSection:Toggle("Enabled", false, function(Value)
    SetNightfallChinaHatEnabled(Value)
end)
ChinaHatToggle:AddColorpicker("Color", ConfigState.NightfallChinaHatColor, function(ColorValue)
    SetNightfallChinaHatColor(ColorValue)
end)
ChinaHatSection:Slider("Scale", ConfigState.NightfallChinaHatScale, 0.05, 0.55, 1.65, "x", function(Value)
    SetNightfallChinaHatScale(Value)
end)
ChinaHatSection:Slider("Height", ConfigState.NightfallChinaHatHeight, 0.05, -1.25, 2.5, "", function(Value)
    SetNightfallChinaHatHeight(Value)
end)
ChinaHatSection:Slider("Radius", ConfigState.NightfallChinaHatRadius, 0.05, 0.75, 3.25, "", function(Value)
    SetNightfallChinaHatRadius(Value)
end)
ChinaHatSection:Slider("Cone Height", ConfigState.NightfallChinaHatConeHeight, 0.05, 0.7, 3.5, "", function(Value)
    SetNightfallChinaHatConeHeight(Value)
end)

local function ApplyHeadless(StateValue)
    local CharacterObject = LocalPlayer.Character
    if not CharacterObject or typeof(CharacterObject) ~= "Instance" then return end

    local HeadObject = CharacterObject:FindFirstChild("Head")
    if not HeadObject or typeof(HeadObject) ~= "Instance" or not HeadObject:IsA("BasePart") then return end

    HeadObject.Size = StateValue and Vector3.new(0.01, 0.01, 0.01) or Vector3.new(1.2, 1, 1.2)
    if not StateValue then return end

    if IsValidAddress(HeadObject.Address) then
        WriteFloat(HeadObject.Address + OffsetsData.Transparency, 1)
    end

    for _, ChildObject in ipairs(HeadObject:GetChildren()) do
        if ChildObject and typeof(ChildObject) == "Instance" then
            local ClassName = ChildObject.ClassName or ""
            local ChildName = ChildObject.Name or ""
            local IsVisual = ClassName == "Decal" or ClassName == "Texture" or string.find(ClassName, "Mesh", 1, true) ~= nil or ChildName == "face" or ChildName == "Face"

            if IsVisual then
                if ClassName == "Decal" or ClassName == "Texture" or string.find(ClassName, "Mesh", 1, true) ~= nil then
                    if ChildObject.Texture ~= nil then ChildObject.Texture = "" end
                    if ChildObject.Transparency ~= nil then ChildObject.Transparency = 1 end
                end

                if IsValidAddress(ChildObject.Address) then
                    if ClassName == "Decal" or ChildName == "face" or ChildName == "Face" then
                        WritePointer(ChildObject.Address + OffsetsData.DecalTexture + 0x10, 0)
                    end
                    WritePointer(ChildObject.Address + OffsetsData.Parent, 0)
                end
            end
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

    for _, PartObject in ipairs(CharacterObject:GetChildren()) do
        if PartObject and typeof(PartObject) == "Instance" then
            if RightLegNames[PartObject.Name] and PartObject:IsA("BasePart") then
                PartObject.Size = StateValue and Vector3.new(0.01, 0.01, 0.01) or Vector3.new(1, 1, 1)

                if StateValue and IsValidAddress(PartObject.Address) then
                    WriteFloat(PartObject.Address + OffsetsData.Transparency, 1)
                end

                if StateValue then
                    for _, ChildObject in ipairs(PartObject:GetChildren()) do
                        if ChildObject and typeof(ChildObject) == "Instance" then
                            local ClassName = ChildObject.ClassName or ""
                            local IsVisual = string.find(ClassName, "Mesh", 1, true) ~= nil or ClassName == "Decal" or ClassName == "Texture"
                            if IsVisual and IsValidAddress(ChildObject.Address) then
                                WritePointer(ChildObject.Address + OffsetsData.Parent, 0)
                            end
                        end
                    end
                end
            end
        end
    end
end

local CharacterSection = VisualsTab:Section("Character", "Left", "")
CharacterSection:Toggle("Headless", false, function(Value)
    ConfigState.Headless = Value
    ApplyHeadless(Value)
end)
CharacterSection:Toggle("Korblox", false, function(Value)
    ConfigState.Korblox = Value
    ApplyKorblox(Value)
end)

local DetectionsTab = WindowApp:Tab("Detections", "shield")
local DetectionSection = DetectionsTab:Section("Detections", "Left", "")
DetectionSection:Toggle("Infinity", false, function(Value)
    ConfigState.InfinityDetection = Value
end)
DetectionSection:Toggle("Slashes of Fury", false, function(Value)
    ConfigState.SlashesOfFuryDetection = Value
end)

WindowApp:AddSettingsTab("cog")

_G.Nightfall_Active = true

if _G.NightfallSpamConnection then
    if type(_G.NightfallSpamConnection.Disconnect) == "function" then
        _G.NightfallSpamConnection:Disconnect()
    end
    _G.NightfallSpamConnection = nil
end

local VisualsData = {
    SphereLines = {},
    BallTrailPositions = {},
    BallLines = {},
    EspTexts = {}
}

local MaxTrailLines = 100

local function CreateEspText()
    if type(Drawing) ~= "table" or type(Drawing.new) ~= "function" then return nil end
    local TextObject = Drawing.new("Text")
    if not TextObject then return nil end
    TextObject.Center = true
    TextObject.Outline = true
    TextObject.Font = type(Drawing.Fonts) == "table" and Drawing.Fonts.System or 2
    TextObject.Transparency = 0
    TextObject.ZIndex = 2
    TextObject.Color = typeof(ConfigState.EspColor) == "Color3" and ConfigState.EspColor or Color3.fromRGB(220, 30, 30)
    TextObject.Visible = false
    table.insert(_G.NightfallDrawings, TextObject)
    return TextObject
end

if type(Drawing) == "table" and type(Drawing.new) == "function" then
    for Index = 1, 100 do
        local LineObject = Drawing.new("Line")
        if LineObject then
            LineObject.Visible = false
            VisualsData.SphereLines[Index] = LineObject
            table.insert(_G.NightfallDrawings, LineObject)
        end
    end

    for Index = 1, MaxTrailLines do
        local LineObject = Drawing.new("Line")
        if LineObject then
            LineObject.Visible = false
            VisualsData.BallLines[Index] = LineObject
            table.insert(_G.NightfallDrawings, LineObject)
        end
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
    if type(GetPingValue) ~= "function" then return 50 end
    local PingValue = GetPingValue()
    if not IsValidNumber(PingValue) or PingValue < 0 then return 50 end
    return PingValue
end

local function CheckIsTarget(TargetName)
    if not LocalPlayer then return false end
    local CharacterInstance = LocalPlayer.Character
    if CharacterInstance and typeof(CharacterInstance) == "Instance" and CharacterInstance:FindFirstChild('Highlight') then return true end
    if not TargetName then return false end
    local MyName = string.lower(LocalPlayer.Name or "")
    local MyDisplay = MyName
    local TargetString = string.lower(tostring(TargetName))
    if TargetString == MyName or TargetString == MyDisplay then return true end
    local CleanTarget = string.gsub(TargetString, '%.%.%.$', '')
    if #CleanTarget >= 3 then
        if string.sub(MyName, 1, #CleanTarget) == CleanTarget or string.sub(MyDisplay, 1, #CleanTarget) == CleanTarget then return true end
        if string.find(MyName, CleanTarget, 1, true) or string.find(MyDisplay, CleanTarget, 1, true) then return true end
    end
    return false
end

local function CheckTargetAttribute(TargetValue)
    if TargetValue == nil or not LocalPlayer then return false end

    if typeof(TargetValue) == "Instance" then
        if TargetValue == LocalPlayer then return true end
        TargetValue = TargetValue.Name
    end

    local MyName = string.lower(LocalPlayer.Name or "")
    local MyDisplay = MyName
    local MyUserId = tostring(LocalPlayer.UserId or "")
    local TargetString = string.lower(tostring(TargetValue))
    local CleanTarget = string.gsub(TargetString, '%.%.%.$', '')

    if CleanTarget == MyName or CleanTarget == MyDisplay or CleanTarget == MyUserId then
        return true
    end

    if #CleanTarget >= 3 then
        if string.sub(MyName, 1, #CleanTarget) == CleanTarget then return true end
        if string.sub(MyDisplay, 1, #CleanTarget) == CleanTarget then return true end
    end

    return false
end

local function GetDistanceSquared(V1Position, V2Position)
    if not IsValidVector3(V1Position) or not IsValidVector3(V2Position) then return math.huge end
    local DeltaX = V1Position.X - V2Position.X
    local DeltaY = V1Position.Y - V2Position.Y
    local DeltaZ = V1Position.Z - V2Position.Z
    return DeltaX * DeltaX + DeltaY * DeltaY + DeltaZ * DeltaZ
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
                    local CurrentDistSq = GetDistanceSquared(PlayerPosition, GetPartPosition(RootPart))
                    if CurrentDistSq < MinimumDistanceSq then
                        MinimumDistanceSq = CurrentDistSq
                        NearestEntity = TargetPlayer
                    end
                end
            end
        end
    end
    return NearestEntity, math.sqrt(MinimumDistanceSq)
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

local SpamAccumulator = 0
local SpamWindowActive = true
local NextSpamWindowCheck = 0
local SpamBurstCap = 20

local function IsGameWindowActive()
    local CurrentTime = os.clock()
    if CurrentTime < NextSpamWindowCheck then return SpamWindowActive end

    NextSpamWindowCheck = CurrentTime + 0.25
    if type(isrbxactive) ~= "function" then
        SpamWindowActive = true
        return true
    end

    local Result = isrbxactive()
    SpamWindowActive = Result ~= false
    return SpamWindowActive
end

local function ExecuteParryBatch(ClickCount)
    if ClickCount <= 0 then
        return
    end

    local ParryMethod =
        ConfigState.ParryMethod

    if ParryMethod == "Click" then
        local ClickFunction =
            Mouse1Click

        if typeof(ClickFunction) ~= "function" then
            return
        end

        for _ = 1, ClickCount do
            ClickFunction()
        end

        return
    end

    if ParryMethod == "Key" then
        local PressFunction =
            KeyPress

        local ReleaseFunction =
            KeyRelease

        if typeof(PressFunction) ~= "function"
            or typeof(ReleaseFunction) ~= "function"
        then
            return
        end

        for _ = 1, ClickCount do
            PressFunction(0x46)
            ReleaseFunction(0x46)
        end
    end
end

_G.NightfallSpamConnection = RunService.Heartbeat:Connect(function(DeltaTime)
    if not _G.Nightfall_Active then
        SpamAccumulator = 0
        return
    end

    local SpamActive =
        ConfigState.ManualSpam
        or RuntimeState.ShouldSpam
        or RuntimeState.PanicShouldSpam

    if not SpamActive
        or not IsGameWindowActive()
    then
        SpamAccumulator = 0
        return
    end

    local SafeDeltaTime =
        type(DeltaTime) == "number"
        and math.clamp(
            DeltaTime,
            0.001,
            0.05
        )
        or (1 / 60)

    local RequestedRate =
        math.clamp(
            tonumber(
                ConfigState.SpamRate
            ) or 200,
            200,
            1000
        )

    local FrameCapacity =
        math.min(
            RequestedRate
            * SafeDeltaTime,
            SpamBurstCap
        )

    SpamAccumulator =
        math.min(
            SpamAccumulator
            + FrameCapacity,
            SpamBurstCap
        )

    local ClickCount =
        math.floor(
            SpamAccumulator
        )

    if ClickCount <= 0 then
        return
    end

    SpamAccumulator =
        SpamAccumulator
        - ClickCount

    ExecuteParryBatch(
        ClickCount
    )
end)

local SpamConfiguration = {
    SpamMinDistanceSpeedDivisor = 6.5,
    SpamMaxSpeedDivisor = 5.0,
    SpamMinDistance = 95.0,
    SpamMaxDistance = 30.0
}

local CachedSpamNearestPlayer = nil
local CachedSpamNearestDistance = math.huge
local NextSpamEntityScan = 0

local function CheckIsSpam(SpamParameters)
    if SpamParameters.IsMovingAway then return false, 0 end
    if SpamParameters.Parries < ConfigState.SpamSensitivity then return false, SpamParameters.Parries end
    local ScaledPing = SpamParameters.Ping / 10
    local RangeValue = ScaledPing + math.min(SpamParameters.Speed / SpamConfiguration.SpamMinDistanceSpeedDivisor, SpamConfiguration.SpamMinDistance)
    local IsSnap = (SpamParameters.Dot > 0.75) and (SpamParameters.DotDelta > 0.15) and (SpamParameters.BallDistance <= RangeValue * 1.75)
    if IsSnap then return true, SpamParameters.Parries end
    if SpamParameters.EntityDistance > RangeValue then return false, SpamParameters.Parries end
    if SpamParameters.BallDistance > RangeValue then return false, SpamParameters.Parries end
    local MaximumDot = math.clamp(SpamParameters.Dot, -1, 0)
    local AccuracyValue = math.min(RangeValue - MaximumDot, SpamConfiguration.SpamMaxDistance)
    if SpamParameters.BallDistance > AccuracyValue then return false, SpamParameters.Parries end
    return true, SpamParameters.Parries
end

local function GetTrailColorAndOpacity(OffsetValue, IndexValue, TotalValue)
    local AlphaValue = 1.0 - math.pow(IndexValue / TotalValue, 1.5)
    local OpacityValue = math.max(AlphaValue * AlphaValue * AlphaValue, 0.05)
    if not ConfigState.RainbowMode then
        return ConfigState.TrailColor, OpacityValue
    end
    local TimeValue = os.clock() * 2.5 + OffsetValue + IndexValue * 0.1
    local RedValue = (math.sin(TimeValue) * 0.5 + 0.5) * 0.95 + 0.05
    local GreenValue = (math.sin(TimeValue + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
    local BlueValue = (math.sin(TimeValue + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
    return Color3.new(RedValue, GreenValue, BlueValue), OpacityValue
end

local function UpdateAndRenderTrail(CurrentBallPosition)
    if not ConfigState.BallTrail or not IsValidVector3(CurrentBallPosition) then
        for _, LineObject in ipairs(VisualsData.BallLines) do
            if LineObject then LineObject.Visible = false end
        end
        table.clear(VisualsData.BallTrailPositions)
        return
    end

    local LastTrackedPosition = VisualsData.BallTrailPositions[1]
    if not IsValidVector3(LastTrackedPosition) or GetDistanceBetween(LastTrackedPosition, CurrentBallPosition) > 0.05 then
        table.insert(VisualsData.BallTrailPositions, 1, CurrentBallPosition)
    end

    local TrailLength = math.clamp(tonumber(ConfigState.TrailLength) or 60, 3, MaxTrailLines)
    while #VisualsData.BallTrailPositions > TrailLength do
        table.remove(VisualsData.BallTrailPositions)
    end

    local TotalPositions = #VisualsData.BallTrailPositions
    if TotalPositions < 2 then
        for _, LineObject in ipairs(VisualsData.BallLines) do
            if LineObject then LineObject.Visible = false end
        end
        return
    end

    local BaseOffset = os.clock() * 1.5
    for Index = 2, TotalPositions do
        local LineObject = VisualsData.BallLines[Index - 1]
        if not LineObject then break end

        local Position1 = VisualsData.BallTrailPositions[Index - 1]
        local Position2 = VisualsData.BallTrailPositions[Index]
        if IsValidVector3(Position1) and IsValidVector3(Position2) then
            local Point1Screen, Visible1 = WorldToScreen(Position1)
            local Point2Screen, Visible2 = WorldToScreen(Position2)

            if Visible1 and Visible2 and IsValidVector2(Point1Screen) and IsValidVector2(Point2Screen) then
                local ColorValue, OpacityValue = GetTrailColorAndOpacity(BaseOffset, Index, TotalPositions)
                LineObject.From = Point1Screen
                LineObject.To = Point2Screen
                LineObject.Color = ColorValue
                LineObject.Transparency = OpacityValue
                LineObject.Thickness = (tonumber(ConfigState.TrailThickness) or 2) * (1 - math.pow(Index / TotalPositions, 1.5))
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
        if LineObject then LineObject.Visible = false end
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
local LastTargetActivation = 0
local CachedTarget = nil
local CurrentKps = 0
local SmoothedKps = 0
local SmoothedServerFps = 60
local CachedAliveFolder = nil
local SmoothVisualRootPosition = nil
local EspSmoothedPositions = {}
local CachedCharacter = nil
local CharacterFullyLoaded = false
local PullActive = false
local LastPullTime = 0

RunService.RenderStepped:Connect(function(DeltaTime)
    if not IsValidNumber(DeltaTime) then DeltaTime = 0.016 end
    local CurrentRenderTime = os.clock()
    local RealBallVisuals = GetRealBall()
    local CurrentBallPosition = GetPartPosition(RealBallVisuals)
    UpdateAndRenderTrail(CurrentBallPosition)

    if ConfigState.AbilityEsp then
        local CurrentPlayersList = PlayersService:GetPlayers()
        for Index = 1, #CurrentPlayersList do
            local TargetPlayer = CurrentPlayersList[Index]
            if TargetPlayer and typeof(TargetPlayer) == "Instance" and TargetPlayer ~= LocalPlayer then
                local PlayerNameString = TargetPlayer.Name
                local TargetCharacter = TargetPlayer.Character
                local TargetHumanoid = TargetCharacter and typeof(TargetCharacter) == "Instance" and TargetCharacter:FindFirstChildWhichIsA("Humanoid") or nil
                local TargetHead = TargetCharacter and typeof(TargetCharacter) == "Instance" and TargetCharacter:FindFirstChild("Head") or nil
                local TargetAbility = TargetPlayer:GetAttribute("CurrentlyEquippedAbility")
                local HeadPosition = GetPartPosition(TargetHead)

                if TargetHumanoid and TargetHumanoid.Health > 0 and HeadPosition and TargetAbility and tostring(TargetAbility) ~= "" then
                    local Target3D = HeadPosition + Vector3.new(0, tonumber(ConfigState.EspOffsetY) or 2, 0)
                    local ScreenCoordinates, IsOnScreen = WorldToScreen(Target3D)
                    local TextDrawing = VisualsData.EspTexts[PlayerNameString]

                    if IsOnScreen and IsValidVector2(ScreenCoordinates) and ScreenCoordinates.X > 0 and ScreenCoordinates.Y > 0 then
                        if not TextDrawing then
                            TextDrawing = CreateEspText()
                            VisualsData.EspTexts[PlayerNameString] = TextDrawing
                        end

                        if TextDrawing then
                            local DrawColor = typeof(ConfigState.EspColor) == "Color3" and ConfigState.EspColor or Color3.fromRGB(220, 30, 30)
                            local SmoothedPosition = ScreenCoordinates
                            local PreviousPosition = EspSmoothedPositions[PlayerNameString]
                            if IsValidVector2(PreviousPosition) then
                                SmoothedPosition = LerpVector2(PreviousPosition, ScreenCoordinates, math.clamp(DeltaTime * 32, 0, 1))
                            end

                            EspSmoothedPositions[PlayerNameString] = SmoothedPosition
                            TextDrawing.Position = SmoothedPosition
                            TextDrawing.FontSize = tonumber(ConfigState.EspTextSize) or 18
                            TextDrawing.Text = tostring(TargetAbility)

                            if ConfigState.RainbowMode then
                                local TimeValue = CurrentRenderTime * 2.5
                                TextDrawing.Color = Color3.new(
                                    (math.sin(TimeValue) * 0.5 + 0.5) * 0.95 + 0.05,
                                    (math.sin(TimeValue + 2.094) * 0.5 + 0.5) * 0.95 + 0.05,
                                    (math.sin(TimeValue + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                                )
                            else
                                TextDrawing.Color = DrawColor
                            end
                            TextDrawing.Visible = true
                        end
                    elseif TextDrawing then
                        TextDrawing.Visible = false
                    end
                else
                    local TextDrawing = VisualsData.EspTexts[PlayerNameString]
                    if TextDrawing then TextDrawing.Visible = false end
                end
            end
        end

        for KeyName, TextDrawing in pairs(VisualsData.EspTexts) do
            if not PlayersService:FindFirstChild(KeyName) then
                if TextDrawing and type(TextDrawing.Remove) == "function" then TextDrawing:Remove() end
                VisualsData.EspTexts[KeyName] = nil
                EspSmoothedPositions[KeyName] = nil
            end
        end
    else
        for _, TextDrawing in pairs(VisualsData.EspTexts) do
            if TextDrawing then TextDrawing.Visible = false end
        end
    end

    local LocalCharacter = LocalPlayer.Character
    local RootPartVisual = LocalCharacter and typeof(LocalCharacter) == "Instance" and LocalCharacter:FindFirstChild("HumanoidRootPart") or nil
    local RootPartPosition = GetPartPosition(RootPartVisual)

    if ConfigState.ParryVisualizer and RootPartPosition then
        local RootPositionRaw = RootPartPosition - Vector3.new(0, 3, 0)
        if not IsValidVector3(SmoothVisualRootPosition) then
            SmoothVisualRootPosition = RootPositionRaw
        else
            SmoothVisualRootPosition = SmoothVisualRootPosition:Lerp(RootPositionRaw, math.clamp(DeltaTime * 18, 0, 1))
        end

        local RootPosition = SmoothVisualRootPosition
        local TargetRadius = IsValidNumber(RuntimeState.ParryRange) and RuntimeState.ParryRange or 15
        SmoothParryRadius = SmoothParryRadius + (TargetRadius - SmoothParryRadius) * math.clamp(DeltaTime * 20, 0, 1)
        local RadiusValue = math.max(SmoothParryRadius, 5)
        local SegmentsCount = math.clamp(tonumber(ConfigState.VisSegments) or 40, 10, 100)
        local AngleStep = math.pi * 2 / SegmentsCount

        for Index = 1, 100 do
            local LineObject = VisualsData.SphereLines[Index]
            if LineObject then
                if Index <= SegmentsCount then
                    local Angle1 = (Index - 1) * AngleStep
                    local Angle2 = Index * AngleStep
                    local Point1World = RootPosition + Vector3.new(math.cos(Angle1) * RadiusValue, 0, math.sin(Angle1) * RadiusValue)
                    local Point2World = RootPosition + Vector3.new(math.cos(Angle2) * RadiusValue, 0, math.sin(Angle2) * RadiusValue)
                    local Point1Position, OnScreen1 = WorldToScreen(Point1World)
                    local Point2Position, OnScreen2 = WorldToScreen(Point2World)

                    if OnScreen1 and OnScreen2 and IsValidVector2(Point1Position) and IsValidVector2(Point2Position) then
                        LineObject.From = Point1Position
                        LineObject.To = Point2Position
                        LineObject.Thickness = tonumber(ConfigState.VisThickness) or 2
                        LineObject.Transparency = tonumber(ConfigState.VisTransparency) or 1

                        if ConfigState.RainbowMode then
                            local OffsetT = CurrentRenderTime * 2.5 + Index / SegmentsCount * math.pi * 2
                            LineObject.Color = Color3.new(
                                (math.sin(OffsetT) * 0.5 + 0.5) * 0.95 + 0.05,
                                (math.sin(OffsetT + 2.094) * 0.5 + 0.5) * 0.95 + 0.05,
                                (math.sin(OffsetT + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                            )
                        else
                            LineObject.Color = typeof(ConfigState.VisualizerColor) == "Color3" and ConfigState.VisualizerColor or Color3.fromRGB(220, 30, 30)
                        end
                        LineObject.Visible = true
                    else
                        LineObject.Visible = false
                    end
                else
                    LineObject.Visible = false
                end
            end
        end
    else
        SmoothVisualRootPosition = nil
        for Index = 1, 100 do
            local LineObject = VisualsData.SphereLines[Index]
            if LineObject then LineObject.Visible = false end
        end
    end
end)

RunService.Heartbeat:Connect(function(DeltaTime)
    RuntimeState.PanicShouldSpam = false

    local CurrentTime = os.clock()
    if not IsValidNumber(DeltaTime) or DeltaTime <= 0 then DeltaTime = 0.016 end
    local CurrentDeltaTime = math.clamp(DeltaTime, 0.001, 0.05)

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
                if ConfigState.Headless then ApplyHeadless(true) end
                if ConfigState.Korblox then ApplyKorblox(true) end
            end)
        end
    end

    if PlayerCharacterObject and typeof(PlayerCharacterObject) == "Instance" and CharacterFullyLoaded then
        if ConfigState.Headless then
            local TargetHead = PlayerCharacterObject:FindFirstChild("Head")
            local TargetHeadSize = GetPartSize(TargetHead)
            if TargetHeadSize and TargetHeadSize.X > 0.1 then ApplyHeadless(true) end
        end
        if ConfigState.Korblox then
            local TargetRightLeg = PlayerCharacterObject:FindFirstChild("RightUpperLeg") or PlayerCharacterObject:FindFirstChild("Right Leg")
            local TargetRightLegSize = GetPartSize(TargetRightLeg)
            if TargetRightLegSize and TargetRightLegSize.X > 0.1 then ApplyKorblox(true) end
        end
    end

    if CurrentDeltaTime > 0 then
        local CurrentServerFps = 1 / math.max(CurrentDeltaTime, 1 / 360)
        SmoothedServerFps = SmoothedServerFps + (CurrentServerFps - SmoothedServerFps) * 0.1
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
                if FuryTimer and typeof(FuryTimer) == "Instance" then
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
                            if FuryTimer and typeof(FuryTimer) == "Instance" then
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
        if (CurrentTime - LastTargetActivation) > 0.5 then
            CachedTarget = nil
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
        RuntimeState.PanicShouldSpam = false
        RuntimeState.TargetSpeed = 0
        RuntimeState.TargetDistance = 0
        RuntimeState.TargetDot = 0
        RuntimeState.ParryRange = 15
        RuntimeState.ShouldSpam = false
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
        RuntimeState.PanicShouldSpam = false
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
        RuntimeState.PanicShouldSpam = false
        RuntimeState.ShouldSpam = false
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
        RuntimeState.PanicShouldSpam = false
        ScheduledTriggerTime = 0
        RuntimeState.ShouldSpam = false
        PullActive = true
        LastPullTime = CurrentTime
        return
    end

    if PullActive then
        IsParried = false
        RuntimeState.ShouldSpam = false
        return
    end

    local RootPosition = GetPartPosition(RootPart)
    local BallPosition = GetPartPosition(RealBall)
    if not RootPosition or not BallPosition then
        RuntimeState.PanicShouldSpam = false
        RuntimeState.ShouldSpam = false
        return
    end

    local DeltaVector = RootPosition - BallPosition
    local CurrentDistance = GetVectorMagnitude(DeltaVector)
    if CurrentDistance <= 0.0001 then return end

    local BallVelocity = GetPartVelocity(RealBall) or Vector3.zero
    local CurrentSpeed = GetVectorMagnitude(BallVelocity)

    local ApproachSpeed = 0
    if LastDistance ~= 9999 then
        ApproachSpeed = math.max((LastDistance - CurrentDistance) / CurrentDeltaTime, 0)
    end
    local EffectiveSpeed = math.max(CurrentSpeed, ApproachSpeed)
    local SpeedDelta = math.max(EffectiveSpeed - LastSpeed, 0)

    local VelocityDirection = CurrentSpeed > 0.01 and NormalizeVector(BallVelocity) or Vector3.zero
    local DirectionToPlayerStat = NormalizeVector(DeltaVector)
    local DotProductStat = GetDotProduct(DirectionToPlayerStat, VelocityDirection)
    
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
        RuntimeState.PanicShouldSpam = false
        RuntimeState.ShouldSpam = false
        return
    end

    local TargetAttribute = RealBall:GetAttribute("target")
    if TargetAttribute == nil then
        TargetAttribute = RealBall:GetAttribute("Target")
    end

    local IsTargetMe = CheckTargetAttribute(TargetAttribute)

    if TargetAttribute ~= CachedTarget then
        CachedTarget = TargetAttribute

        if IsTargetMe then
            local CurrentWaitTime = os.clock()
            local TimeSinceLast = CurrentWaitTime - LastTargetActivation

            if TimeSinceLast <= 0.5 then
                BallParries = BallParries + 1
            else
                BallParries = 1
            end

            if TimeSinceLast > 0 then
                CurrentKps = 1 / TimeSinceLast
                SmoothedKps = SmoothedKps + (CurrentKps - SmoothedKps) * 0.25
            end

            LastTargetActivation = CurrentWaitTime

            if PullActive then
                PullActive = false
            end

            if ConfigState.RandomAccuracy then
                GenerateRandomAccuracy()
            end
        end
    end

    local TargetWindowActive = IsTargetMe and (CurrentTime - LastTargetActivation) <= 0.5

    local NetworkPing = GetMemoryPing()
    local NearestPlayer = nil
    local DistanceToNearestPlayer = math.huge

    if ConfigState.AutoSpam
        or ConfigState.PanicSpam
    then
        if CurrentTime >= NextSpamEntityScan then
            CachedSpamNearestPlayer,
            CachedSpamNearestDistance =
                ScanForNearestEntity(
                    RootPosition
                )

            NextSpamEntityScan =
                CurrentTime + 0.06
        end

        NearestPlayer =
            CachedSpamNearestPlayer

        DistanceToNearestPlayer =
            CachedSpamNearestDistance
    else
        CachedSpamNearestPlayer = nil
        CachedSpamNearestDistance = math.huge
        NextSpamEntityScan = 0
    end

    local DeadFolder = WorkspaceService:FindFirstChild("Dead")
    local IsDead = DeadFolder and typeof(DeadFolder) == "Instance" and DeadFolder:FindFirstChild(LocalPlayer.Name) ~= nil
    local IsTrainingBall = RealBall.Parent and RealBall.Parent.Name == "TrainingBalls"
    local CanAttack = (not IsDead) and (not IsTrainingBall)

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
    if ConfigState.AutoSpam and CanAttack and TargetWindowActive then
        AutoSpamActive, _ = CheckIsSpam(SpamParameters)
    end

    if AutoSpamActive and not IsMovingAway and not (CurrentDistance > LastDistance) then
        RuntimeState.ShouldSpam = true
        IsParried = true
        LastSpeed = EffectiveSpeed
        LastDistance = CurrentDistance
        return
    else
        RuntimeState.ShouldSpam = false
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
                        local EnemyPosition = GetPartPosition(EnemyRoot)
                        local DistanceSq = GetDistanceSquared(EnemyPosition, RootPosition)
                        if EnemyPosition and DistanceSq < ClosestEnemyDistanceSq then
                            ClosestEnemyDistanceSq = DistanceSq
                            local EnemyVelocity = GetPartVelocity(EnemyRoot)
                            if EnemyVelocity and GetVectorMagnitude(EnemyVelocity) > 0.1 then
                                local DirectionToMe = NormalizeVector(RootPosition - EnemyPosition)
                                EnemyLookDot = GetDotProduct(NormalizeVector(EnemyVelocity), DirectionToMe)
                            else
                                EnemyLookDot = 1
                            end
                        end
                    end
                end
            end
        end

        local ClosestEnemyDistance = math.sqrt(ClosestEnemyDistanceSq)
        local IsEnemyClose = ClosestEnemyDistance <= PanicMaxDistance
        local BallDirection = CurrentSpeed > 0.01 and NormalizeVector(BallVelocity) or Vector3.zero
        local BallDotToMe = GetDotProduct(BallDirection, DirectionToPlayerStat)

        local DynamicDotThreshold = math.max(0.40, (CurrentDistance / PanicMaxDistance) * 0.75)
        local AngleToPlayer = math.deg(math.acos(math.clamp(BallDotToMe, -1, 1)))
        local DynamicAngleThreshold = math.clamp(180 - (CurrentDistance * 2), 25, 75)

        local IsHeadingTowards = (AngleToPlayer <= DynamicAngleThreshold) or (BallDotToMe > DynamicDotThreshold)
        local IsExtremelyClose = CurrentDistance <= DangerZoneRadius
        local IsApproaching = CurrentDistance < LastDistance

        local IsClash = IsEnemyClose and CurrentSpeed > 35 and EnemyLookDot > 0.55 and (IsApproaching or IsExtremelyClose) and (IsHeadingTowards or IsExtremelyClose) and not IsMovingAway

        RuntimeState.PanicShouldSpam = IsClash
    else
        RuntimeState.PanicShouldSpam = false
    end

    local CanTrigger = IsTargetMe
    if ConfigState.TriggerIgnoreSpawn and BallParries == 0 then
        CanTrigger = false
    end

    local ServerTickRate = 1 / math.max(SmoothedServerFps, 30)

    if ConfigState.TriggerBot and CanAttack then
        if CanTrigger and not IsParried then
            local ApplicationTick = os.clock()
            if ScheduledTriggerTime == 0 then
                local PingSeconds = NetworkPing / 1000
                local BallSpeedFactor = math.clamp(EffectiveSpeed / 70, 0.55, 1.5)
                local DeltaCompensation = CurrentDeltaTime * 1.8
                local TickCompensation = ServerTickRate * 1.5
                local SpeedCompensation = math.clamp(EffectiveSpeed / 100, 0, 0.025)
                local TotalCompensation = PingSeconds + DeltaCompensation + TickCompensation + SpeedCompensation
                local BaseDelay = (ConfigState.TriggerDelay / 1000) * BallSpeedFactor
                local FinalDelay = math.max(0, BaseDelay - TotalCompensation * 0.95)
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

        local VelocityUnit = CurrentSpeed > 0 and VelocityDirection or Vector3.zero
        local DirectionToPlayer = CurrentDistance > 0 and NormalizeVector(RootPosition - BallPosition) or Vector3.zero
        local DotProductParry = GetDotProduct(VelocityUnit, DirectionToPlayer)

        local PingSeconds = NetworkPing / 1000
        local ReactionTime = PingSeconds + CurrentDeltaTime + ServerTickRate
        local TimeToImpact = CurrentDistance / math.max(EffectiveSpeed, 1)

        local SafeKps = type(SmoothedKps) == "number" and SmoothedKps or 0
        local PredictionTime = PingSeconds + CurrentDeltaTime * 2.5 + (SafeKps / 20 * 0.025)
        local PredictedBallPos = BallPosition + (BallVelocity * PredictionTime)
        local PredictedDistance = GetDistanceBetween(RootPosition, PredictedBallPos)
        
        local SpeedFactor = math.clamp(EffectiveSpeed / 85, 0.6, 1.45)
        local DynamicPredictedThreshold = 20 + (SpeedFactor * 7)
        
        local UpclosePredictedHit = PredictedDistance <= DynamicPredictedThreshold and DotProductParry > 0.22
        
        local ShortTermPrediction = BallPosition + (BallVelocity * (PingSeconds * 0.6 + CurrentDeltaTime * 0.9))
        local ShortTermDistance = GetDistanceBetween(RootPosition, ShortTermPrediction)
        local VeryClosePredictedHit = ShortTermDistance <= 11 and DotProductParry > 0.15 and EffectiveSpeed > 55

        local KpsIntensity = math.clamp(SmoothedKps, 0, 20) / 20
        local KpsMitigation = 1 - (KpsIntensity * 0.55)

        local AccuracyValue = ConfigState.RandomAccuracy and RuntimeState.GeneratedAccuracy or ConfigState.Accuracy
        if ConfigState.RandomAccuracy then
            local ExtraJitter = (math.random() - 0.5) * 3.2
            AccuracyValue = math.clamp(AccuracyValue + ExtraJitter, 1, 100)
        end
        local AccuracyScale = (AccuracyValue - 1) / 100
        local AccuracyMultiplier = 0.7 + (AccuracyScale * 0.35)

        local DynamicScaling = math.max(EffectiveSpeed - 9.5, 0) * 0.002
        local SpeedDivisorBase = 2.4 + DynamicScaling
        local FinalSpeedDivisor = SpeedDivisorBase * AccuracyMultiplier

        local ExtraFactor = 2 + DynamicScaling * 0.15
        local ExtrapolationDistance = EffectiveSpeed * CurrentDeltaTime * ExtraFactor * KpsMitigation

        local BaseDistance = math.max(EffectiveSpeed / FinalSpeedDivisor, 9.5)
        local EarlyBoost = (1 - AccuracyScale) * 3.5

        local UnifiedThreshold = math.max(BaseDistance + ExtrapolationDistance + (KpsIntensity * 1.5) + EarlyBoost, 9.5)
        
        local CloseRangeThreshold = math.max(15, UnifiedThreshold * 0.5)
        
        local CurveMultiplier = 1.0
        if CurrentDistance > CloseRangeThreshold then
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
            local DistanceRatio = math.clamp((CurrentDistance - 35.0) / 55.0, 0, 1)
            local MaxDotThreshold = 0.85 - (0.05 * (1 - AccuracyScale))
            local MinDotThreshold = 0.55 - (0.05 * (1 - AccuracyScale))
            local DynamicDot = MinDotThreshold + (MaxDotThreshold - MinDotThreshold) * math.pow(DistanceRatio, 1.5)
            local CurveCompensation = CurrentDeltaTime * ExtraFactor * KpsMitigation
            local DotThreshold = DynamicDot - (CurveCompensation * 0.15)
            
            if CurrentDistance > CloseRangeThreshold * (1.1 - (0.25 * (1 - AccuracyScale))) and DotProductParry < DotThreshold then
                IsCurved = true
            end
        end

        if CurrentDistance <= 20 then
            IsCurved = false
        end

        if UpclosePredictedHit or VeryClosePredictedHit then
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
        IsParried = false
    end

    LastSpeed = EffectiveSpeed
    LastDistance = CurrentDistance
end)

RunService.RenderStepped:Connect(function(DeltaTime)
    if not ConfigState.OrbitBall then return end
    if not IsValidNumber(DeltaTime) then DeltaTime = 0.016 end

    local AliveFolder = WorkspaceService:FindFirstChild("Alive")
    if not AliveFolder or typeof(AliveFolder) ~= "Instance" or not AliveFolder:FindFirstChild(LocalPlayer.Name) then return end

    local RealBall = GetRealBall()
    local BallPosition = GetPartPosition(RealBall)
    if not BallPosition then return end

    local CharacterObject = LocalPlayer.Character
    if not CharacterObject or typeof(CharacterObject) ~= "Instance" then return end

    local RootPart = CharacterObject.PrimaryPart
    if not RootPart or typeof(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") then
        RootPart = CharacterObject:FindFirstChild("HumanoidRootPart")
    end

    local RootPosition = GetPartPosition(RootPart)
    if not RootPosition then return end

    local OrbitRadius = tonumber(ConfigState.OrbitRadius) or 25
    local OrbitHeight = tonumber(ConfigState.OrbitHeight) or 5
    local OrbitSpeed = tonumber(ConfigState.OrbitSpeed) or 50
    local TimeValue = os.clock() * OrbitSpeed / 50
    local OrbitPosition = Vector3.new(
        BallPosition.X + math.cos(TimeValue) * OrbitRadius,
        BallPosition.Y + OrbitHeight,
        BallPosition.Z + math.sin(TimeValue) * OrbitRadius
    )

    RootPart.Position = RootPosition:Lerp(OrbitPosition, math.clamp(DeltaTime * 35, 0, 0.65))
end)
