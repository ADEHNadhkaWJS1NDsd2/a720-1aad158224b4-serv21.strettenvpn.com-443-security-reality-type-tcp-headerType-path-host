task.wait(3.5)

RadiantRuntimeUnloaded = false

local RuntimeConfig = { LibraryUrl =
    "https://raw.githubusercontent.com/ADEHNadhkaWJS1NDsd2/a720-1aad158224b4-serv21.strettenvpn.com-443-security-reality-type-tcp-headerType-path-host/refs/heads/main/Library.lua?minimalui=v3",
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

local function ExtractHttpBody(Response)
    if type(Response) == "string" then return Response end
    if type(Response) ~= "table" then return nil end
    local Body = Response.Body or Response.body or Response.ResponseBody or Response.responseBody or Response.Data or Response.data
    if type(Body) == "string" then return Body end
    return nil
end

local function IsValidLibrarySource(Source)
    if type(Source) ~= "string" or #Source < RuntimeConfig.MinimumLibrarySize then return false end
    local Prefix = string.sub(Source, 1, 256)
    if string.find(string.lower(Prefix), "<!doctype html", 1, true) or string.find(string.lower(Prefix), "<html", 1, true) then return false end
    return true
end

local function RequestLibrarySource()
    local Errors = {}
    local Environment = type(getgenv) == "function" and getgenv() or _G
    local RequestFunctions = {
        Environment and Environment.request,
        Environment and Environment.http_request,
        type(syn) == "table" and syn.request or nil,
        type(http) == "table" and http.request or nil,
        type(fluxus) == "table" and fluxus.request or nil
    }

    for _, RequestFunction in ipairs(RequestFunctions) do
        if type(RequestFunction) == "function" then
            local Success, Response = pcall(RequestFunction, {
                Url = RuntimeConfig.LibraryUrl,
                Method = "GET",
                Headers = {
                    ["Accept"] = "text/plain,*/*",
                    ["Cache-Control"] = "no-cache",
                    ["User-Agent"] = "radiant.rip"
                }
            })
            local Source = Success and ExtractHttpBody(Response) or nil
            if IsValidLibrarySource(Source) then return Source end
            table.insert(Errors, Success and ("request returned " .. typeof(Response)) or tostring(Response))
        end
    end

    local HttpGetAttempts = {
        function() return game:HttpGet(RuntimeConfig.LibraryUrl, true) end,
        function() return game.HttpGet(game, RuntimeConfig.LibraryUrl, true) end,
        function() return game:HttpGetAsync(RuntimeConfig.LibraryUrl) end
    }

    for _, Attempt in ipairs(HttpGetAttempts) do
        local Success, Response = pcall(Attempt)
        local Source = Success and ExtractHttpBody(Response) or nil
        if IsValidLibrarySource(Source) then return Source end
        table.insert(Errors, Success and ("HttpGet returned " .. typeof(Response)) or tostring(Response))
    end

    local HttpService = game:GetService("HttpService")
    local Success, Response = pcall(function() return HttpService:GetAsync(RuntimeConfig.LibraryUrl, true) end)
    local Source = Success and ExtractHttpBody(Response) or nil
    if IsValidLibrarySource(Source) then return Source end
    table.insert(Errors, Success and ("GetAsync returned " .. typeof(Response)) or tostring(Response))

    return nil, table.concat(Errors, " | ")
end

local function LoadRadiantLibrary()
    local LibrarySource, RequestError = RequestLibrarySource()
    if not IsValidLibrarySource(LibrarySource) then FailRuntime("library request failed: " .. tostring(RequestError or "empty response")) end

    local LibraryChunk, CompileError = loadstring(LibrarySource, "@radiant.rip/Library.lua")
    LibrarySource = nil
    if type(LibraryChunk) ~= "function" then FailRuntime("library compile failed: " .. tostring(CompileError)) end

    local ExecuteSuccess, LibraryResult = pcall(LibraryChunk)
    LibraryChunk = nil
    if not ExecuteSuccess then FailRuntime("library execution failed: " .. tostring(LibraryResult)) end

    if type(LibraryResult) ~= "table" and type(getgenv) == "function" then
        LibraryResult = getgenv().Library
    end
    if type(LibraryResult) ~= "table" or type(LibraryResult.Window) ~= "function" or type(LibraryResult.Notification) ~= "function" then
        FailRuntime("library API is incomplete")
    end
    return LibraryResult
end

ValidateRuntime()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
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

    -- Executor keypress APIs normally expect a Windows virtual-key code,
    -- not Roblox Enum.KeyCode.Value. R is VK_R (0x52 / 82), while
    -- Enum.KeyCode.R.Value is different in Roblox.
    local VirtualKeyCode =
        KeyCode == Enum.KeyCode.R and 0x52
        or KeyCode == Enum.KeyCode.V and 0x56
        or KeyCode == Enum.KeyCode.Z and 0x5A
        or KeyCode == Enum.KeyCode.X and 0x58
        or KeyCode == Enum.KeyCode.B and 0x42
        or KeyCode == Enum.KeyCode.G and 0x47
        or KeyCode == Enum.KeyCode.H and 0x48
        or KeyCode == Enum.KeyCode.Q and 0x51
        or KeyCode.Value

    -- Prefer the executor input API. VirtualInputManager can return without
    -- raising an error while the injected event is ignored by the live client.
    if type(keypress) == "function" and type(keyrelease) == "function" then
        local Success = pcall(function()
            keypress(VirtualKeyCode)
            task.wait(math.max(HoldDuration, 0))
            keyrelease(VirtualKeyCode)
        end)
        if Success then return true end
    end

    if type(key_down) == "function" and type(key_up) == "function" then
        local Success = pcall(function()
            key_down(VirtualKeyCode)
            task.wait(math.max(HoldDuration, 0))
            key_up(VirtualKeyCode)
        end)
        if Success then return true end
    end

    if VirtualInputManager then
        local Success = pcall(function()
            VirtualInputManager:SendKeyEvent(true, KeyCode, false, game)
            task.wait(math.max(HoldDuration, 0))
            VirtualInputManager:SendKeyEvent(false, KeyCode, false, game)
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
local UiFont = Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
pcall(function() Library.Font = UiFont end)
local ScriptStartedAt = os.clock()

local ThemePresets = {
    ["Radiant Emerald"] = {
        ["Background"] = Color3.fromRGB(9, 11, 12),
        ["Inline"] = Color3.fromRGB(13, 16, 17),
        ["Page Background"] = Color3.fromRGB(17, 20, 21),
        ["Border"] = Color3.fromRGB(3, 5, 5),
        ["Outline"] = Color3.fromRGB(39, 45, 45),
        ["Accent"] = Color3.fromRGB(54, 218, 145),
        ["Element"] = Color3.fromRGB(23, 27, 28),
        ["Hovered Element"] = Color3.fromRGB(31, 37, 37),
        ["Text"] = Color3.fromRGB(226, 232, 230),
        ["Text Border"] = Color3.fromRGB(0, 0, 0),
        ["Glass Edge"] = Color3.fromRGB(150, 224, 190),
        ["Muted Text"] = Color3.fromRGB(158, 178, 169),
        ["Danger"] = Color3.fromRGB(235, 72, 72)
    },
    ["Deep Emerald"] = {
        ["Background"] = Color3.fromRGB(4, 10, 8),
        ["Inline"] = Color3.fromRGB(7, 17, 13),
        ["Page Background"] = Color3.fromRGB(8, 22, 17),
        ["Border"] = Color3.fromRGB(1, 6, 4),
        ["Outline"] = Color3.fromRGB(16, 46, 35),
        ["Accent"] = Color3.fromRGB(22, 190, 123),
        ["Element"] = Color3.fromRGB(11, 29, 22),
        ["Hovered Element"] = Color3.fromRGB(16, 40, 31),
        ["Text"] = Color3.fromRGB(220, 240, 231),
        ["Text Border"] = Color3.fromRGB(0, 0, 0),
        ["Glass Edge"] = Color3.fromRGB(128, 211, 168),
        ["Muted Text"] = Color3.fromRGB(145, 180, 161),
        ["Danger"] = Color3.fromRGB(235, 72, 72)
    },
    ["Matrix"] = {
        ["Background"] = Color3.fromRGB(3, 8, 4),
        ["Inline"] = Color3.fromRGB(5, 16, 7),
        ["Page Background"] = Color3.fromRGB(7, 23, 10),
        ["Border"] = Color3.fromRGB(0, 5, 1),
        ["Outline"] = Color3.fromRGB(16, 55, 22),
        ["Accent"] = Color3.fromRGB(82, 255, 96),
        ["Element"] = Color3.fromRGB(10, 31, 13),
        ["Hovered Element"] = Color3.fromRGB(17, 48, 21),
        ["Text"] = Color3.fromRGB(224, 248, 226),
        ["Text Border"] = Color3.fromRGB(0, 0, 0),
        ["Glass Edge"] = Color3.fromRGB(166, 255, 175),
        ["Muted Text"] = Color3.fromRGB(166, 205, 171),
        ["Danger"] = Color3.fromRGB(235, 72, 72)
    }
}

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
    218, 145), HealthLowColor = Color3.fromRGB(235, 72, 72), HealthHighColor = Color3.fromRGB(73, 232, 155), FillTransparency = 0.82, TextSize = 13, UpdateInterval = 1 / 50, Objects = {},
    List = {}, Chams = { Enabled = false, ThroughWalls = true, FillEnabled = true, FillColor = Color3.fromRGB(54, 218, 145), OutlineEnabled = true, OutlineColor = Color3.fromRGB(218, 255, 239), FillTransparency = 0.42,
    OutlineTransparency = 0.08, OutlineThickness = 0.035, WallTransparency = 0.58, GlowEnabled = true, GlowColor = Color3.fromRGB(75, 255, 177), GlowTransparency = 0.62, GlowScale = 1.045 } }, World = { Enabled = false, Ambient = Color3.fromRGB(96, 112, 104),
    OutdoorAmbient = Color3.fromRGB(76, 92, 84), Brightness = 2.4, ClockTime = 14, FogEnabled = false, FogColor = Color3.fromRGB(88, 104, 96), FogDecay = Color3.fromRGB(72, 91, 82), FogStart = 20, FogDistance = 900, FogDensity = 0.42, FogHaze = 2.4, FogGlare = 0.12, FogOffset = 0, Saturation = 0, Contrast =
    0.05, TintColor = Color3.fromRGB(255, 255, 255), Bloom = false, Original = nil, ColorCorrection = nil, BloomEffect = nil, Atmosphere = nil, Applying = false, Bound = false, RenderStepName =
    "RadiantWorldOverride", Connection = nil, Accumulator = 0, ApplyInterval = 0.25, AtmospheresSuppressed = false, Dirty = false }, WorldESP = { Safes = false, Cash = false, SafeColor = Color3.fromRGB(73, 232, 155), CashColor = Color3.fromRGB(255, 208, 92), BrokenColor = Color3.fromRGB(235,
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
    UpdateInterval = 1 / 50,
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
AutoStrafeEnabled = false
BunnyHopEnabled = false
AirControlEnabled = false
MovementAssistConnection = nil
MovementAssistSettings = { AirControlStrength = 0.5, StrafeStrength = 0.7, MaxAirSpeed = 32, TickInterval = 1 / 64, TickAccumulator = 0, TickIndex = 0, JumpCooldown = 0.1, LastJump = 0, LastJumpTick = -1000, GroundTicks = 0, AirTicks = 0, JumpArmed = true, LastYaw = nil, WasGrounded = true, TakeoffSpeed = 0, LastWishDirection = Vector3.new() }
NoclipEnabled = false
NoclipConnection = nil
local NoclipCharacterConnection = nil
local NoclipDescendantConnection = nil
local NoclipParts = setmetatable({}, { __mode = "k" })
local NoclipOriginalCollision = setmetatable({}, { __mode = "k" })
InvisibilityEnabled = false
HideHeadEnabled = false
CrowbarAuraEnabled = false
CrowbarAuraCoroutine = nil
MeleeAuraEnabled = false
MeleeAuraCoroutine = nil
ArmsChamsEnabled = false
ArmsChamsSettings = { FillEnabled = true, FillColor = Color3.fromRGB(54, 218, 145), FillTransparency = 0.18, GlowEnabled = true, GlowColor = Color3.fromRGB(54, 218, 145), GlowTransparency = 0.55, GlowScale = 1.035, OutlineEnabled = true, OutlineColor = Color3.fromRGB(218, 255, 239), OutlineTransparency = 0.08, OutlineThickness = 0.035, Connection = nil, Original = setmetatable({}, { __mode = "k" }), CurrentParts = setmetatable({}, { __mode = "k" }), Overlays = setmetatable({}, { __mode = "k" }), CurrentViewModel = nil, CurrentMode = nil, CurrentCamera = nil, TransitionUntil = 0, Clock = 0 }
WeaponChamsEnabled = false
WeaponChamsSettings = { FillEnabled = true, FillColor = Color3.fromRGB(54, 218, 145), FillTransparency = 0.16, GlowEnabled = true, GlowColor = Color3.fromRGB(92, 255, 189), GlowTransparency = 0.58, GlowScale = 1.012, OutlineEnabled = true, OutlineColor = Color3.fromRGB(218, 255, 239), OutlineTransparency = 0.05, OutlineThickness = 0.035, FirstPerson = true, ThirdPerson = true, Connection = nil, RenderName = nil, Folder = nil, Original = setmetatable({}, { __mode = "k" }), CurrentParts = setmetatable({}, { __mode = "k" }), Overlays = setmetatable({}, { __mode = "k" }), RuntimeObjects = {}, CurrentMode = nil, CurrentRoot = nil, CurrentCamera = nil, TransitionUntil = 0, TransitionDelay = 0.10, Clock = 0, ScanInterval = 0.09, Highlight = nil }
ChamsViewState = { FirstPerson = false, Candidate = false, CandidateSince = 0, CurrentCamera = nil, EnterDistance = 1.55, ExitDistance = 3.15 }
FinishAuraEnabled = false
FinishAuraConnection = nil
FinishAuraBusy = false
InfStaminaEnabled = false
InfStaminaCoroutine = nil
NoFallDamageEnabled = false
RageBotEnabled = false
RageBotCoroutine = nil
RageBotFOVConnection = nil
RageBotStickyTarget = nil
RageBotCurrentTarget = nil
RageBotSettings = { CheckTeam = false, CheckWhitelist = false, AutoReload = true, InstantReload = false, Delay = 0.15, TargetMode = "Nearest", FOV = 150, ShowFOV = false,
    FOVColor = Color3.fromRGB(255, 255, 255), Prediction = 0.14, MagicBullet = false, MagicSamples = 8, Sticky = false, OriginMode = "Camera", FOVOrigin = "Center", TargetPart = "Head",
    Resolver = true,
    ScanInterval = 0.10, MaxWallCandidates = 3,
    MaxDistance = 1200, ServerTickRate = 60, ConfirmationWindow = 0.28, ReloadRetryDelay = 1.25, ReloadTimeout = 5.5 }
local RageShotState = {
    NextServerShot = 0,
    LastTool = nil,
    LearnedDamage = setmetatable({}, { __mode = "k" }),
    PendingTarget = nil,
    PendingCharacter = nil,
    PendingHumanoid = nil,
    PendingTool = nil,
    PendingPart = nil,
    PendingKey = nil,
    PendingHealth = nil,
    PendingTime = 0,
    PendingDeadline = 0,
    PendingLineOfSight = false,
    PendingMode = nil,
    PendingRegistrationKey = nil,
    PendingOrigin = nil,
    PendingAim = nil,
    TargetFailures = setmetatable({}, { __mode = "k" }),
    TargetBackoff = setmetatable({}, { __mode = "k" }),
    Sending = false
}
local RageMutedShotSounds = setmetatable({}, { __mode = "k" })
local RageReloadState = {
    Tool = nil,
    StartedAt = 0,
    LastRequest = 0,
    LastProgressAt = 0,
    PreviousAmmo = nil,
    LastAmmo = nil,
    LastStored = nil,
    InProgress = false,
    Attempts = 0,
    LastKeyPress = 0,
    LastStartRequest = 0,
    AmmoCache = setmetatable({}, { __mode = "k" })
}
WhitelistTable = {}

ResolverState = {
    History = setmetatable({}, { __mode = "k" }),
    PoseHistory = setmetatable({}, { __mode = "k" }),
    SkeletonCache = setmetatable({}, { __mode = "k" }),
    SafePartCache = setmetatable({}, { __mode = "k" }),

    MovementUpdateInterval = 1 / 45,
    MinimumDelta = 1 / 240,
    MaximumDelta = 0.28,
    TeleportDistance = 32,
    MaximumAcceleration = 170,
    PartOffsetUpdateInterval = 1 / 30,
    SampleLimit = 9,
    MinimumSamples = 4,
    MaximumJitter = 46,
    MaximumPrediction = 0.46,
    PoseDeviation = 1.35
}

RageResolverTargetScan = {
    LastScan = 0,
    Player = nil,
    Character = nil,
    Part = nil
}

RageMagicBulletCache = {
    TargetPart = nil,
    Origin = nil,
    HitPosition = nil,
    Time = 0
}

RageWallbangSampleCache = setmetatable({}, { __mode = "k" })
RageMagicRegistrationState = RageMagicRegistrationState or {
    Cache = setmetatable({}, { __mode = "k" }),
    ConfirmedLifetime = 20,
    RejectBaseTime = 0.9,
    RejectMaximumTime = 7.5
}
RageMagicRegistrationState.Cache = setmetatable({}, { __mode = "k" })
RageMagicRegistrationState.ConfirmedLifetime = 20
RageMagicRegistrationState.RejectBaseTime = 0.9
RageMagicRegistrationState.RejectMaximumTime = 7.5
RageMagicProbeState = RageMagicProbeState or {
    Cache = setmetatable({}, { __mode = "k" }),
    FailureCooldown = 0.35,
    MaximumCooldown = 1.4,
    OriginTolerance = 6.0,
    TargetTolerance = 2.5
}

function ResolverIsFiniteNumber(Value)
    return type(Value) == "number"
        and Value == Value
        and Value > -math.huge
        and Value < math.huge
end

function ResolverIsFiniteVector(Value)
    return typeof(Value) == "Vector3"
        and ResolverIsFiniteNumber(Value.X)
        and ResolverIsFiniteNumber(Value.Y)
        and ResolverIsFiniteNumber(Value.Z)
end

function ResolverClampVector(Value, MaximumMagnitude)
    if not ResolverIsFiniteVector(Value) then
        return Vector3.zero
    end

    MaximumMagnitude = math.max(
        tonumber(MaximumMagnitude) or 190,
        1
    )

    local Magnitude = Value.Magnitude

    if Magnitude > MaximumMagnitude and Magnitude > 0 then
        return Value.Unit * MaximumMagnitude
    end

    return Value
end

function ResolverMedian(Values)
    local Count = #Values
    if Count == 0 then return 0 end
    table.sort(Values)
    local Middle = math.floor((Count + 1) * 0.5)
    if Count % 2 == 1 then return Values[Middle] end
    return (Values[Middle] + Values[Middle + 1]) * 0.5
end

function ResolverGetRobustVelocity(Samples, MaximumSpeed)
    local Count = #Samples
    if Count == 0 then return Vector3.zero, 0 end

    local X, Y, Z = {}, {}, {}
    for Index = 1, Count do
        local Sample = Samples[Index]
        X[Index], Y[Index], Z[Index] = Sample.X, Sample.Y, Sample.Z
    end

    local Median = Vector3.new(ResolverMedian(X), ResolverMedian(Y), ResolverMedian(Z))
    local Sum = Vector3.zero
    local WeightSum = 0
    local Jitter = 0

    for Index = 1, Count do
        local Sample = Samples[Index]
        local Distance = (Sample - Median).Magnitude
        local Recency = Index / Count
        local Weight = (0.35 + Recency * 0.65) / (1 + Distance * 0.055)
        Sum += Sample * Weight
        WeightSum += Weight
        Jitter += Distance
    end

    local Velocity = WeightSum > 0 and Sum / WeightSum or Median
    return ResolverClampVector(Velocity, MaximumSpeed), Jitter / Count
end

function ResolverGetPingSeconds()
    local Ping = 0
    pcall(function()
        local Value = tonumber(LocalPlayer:GetNetworkPing())
        if Value and Value >= 0 then Ping = math.max(Ping, Value) end
    end)
    pcall(function()
        local StatsService = game:GetService("Stats")
        local DataPing = StatsService.Network.ServerStatsItem["Data Ping"]
        local Milliseconds = DataPing and tonumber(DataPing:GetValue())
        if Milliseconds and Milliseconds >= 0 then Ping = math.max(Ping, Milliseconds / 1000) end
    end)
    return math.clamp(Ping, 0, 1.5)
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
    Data.LastPosition = Root and Root.Position or Vector3.new(0, 0, 0)
    Data.LastTime = CurrentTime or os.clock()
    Data.ObservedVelocity = Vector3.zero
    Data.SmoothedVelocity = Vector3.zero
    Data.ResolvedVelocity = Vector3.zero
    Data.Acceleration = Vector3.zero
    Data.LastReportedVelocity = Root and (Root.AssemblyLinearVelocity or Root.Velocity) or Vector3.new(0, 0, 0)
    Data.DesyncScore = 0
    Data.IsDesynced = false
    Data.Confidence = 0
    Data.Jitter = 0
    Data.DirectionChanges = 0
    Data.LastObservedVelocity = Vector3.zero
    Data.Samples = {}
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

    if Data.Character ~= Character
        or Data.Root ~= Root
        or not Data.LastTime
    then
        ResolverResetData(
            Data,
            Character,
            Root,
            os.clock()
        )
    end

    return Data
end

function ResolverGetDirectedVelocity(Character, Root, MaximumSpeed)
    local Humanoid =
        Character
        and Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return Vector3.zero
    end

    local MoveDirection = Humanoid.MoveDirection
    local WalkSpeed = math.max(
        tonumber(Humanoid.WalkSpeed) or 16,
        0
    )
    local ReportedY =
        Root
        and (
            Root.AssemblyLinearVelocity
            or Root.Velocity
        ).Y
        or 0

    return ResolverClampVector(
        Vector3.new(
            MoveDirection.X * WalkSpeed,
            ReportedY,
            MoveDirection.Z * WalkSpeed
        ),
        MaximumSpeed
    )
end

function ResolverObservePlayer(Player, Character, Settings)
    if not Player or not Character then return nil end

    local Root = ResolverGetRoot(Character)
    if not Root or not Root:IsA("BasePart") then return nil end

    local Data = ResolverGetData(Player, Character)
    local CurrentTime = os.clock()
    local DeltaTime = CurrentTime - (Data.LastTime or CurrentTime)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RawReported = Root.AssemblyLinearVelocity or Root.Velocity or Vector3.new(0, 0, 0)
    local WalkSpeed = Humanoid and tonumber(Humanoid.WalkSpeed) or 16
    local PingSeconds = ResolverGetPingSeconds()
    local MaximumSpeed = math.clamp(math.max(84, WalkSpeed * 6.5, RawReported.Magnitude * 1.45), 84, 230)
    local Reported = ResolverClampVector(RawReported, MaximumSpeed)

    Data.LastReportedVelocity = Reported
    if DeltaTime < ResolverState.MovementUpdateInterval then return Data end

    if DeltaTime > ResolverState.MaximumDelta then
        return ResolverResetData(Data, Character, Root, CurrentTime)
    end

    local CurrentPosition = Root.Position
    local PositionDelta = CurrentPosition - (Data.LastPosition or CurrentPosition)
    local RawObserved = PositionDelta / math.max(DeltaTime, ResolverState.MinimumDelta)

    if PositionDelta.Magnitude > ResolverState.TeleportDistance
        or RawObserved.Magnitude > MaximumSpeed * 2.75
    then
        ResolverResetData(Data, Character, Root, CurrentTime)
        Data.LastReportedVelocity = Reported
        return Data
    end

    local Observed = ResolverClampVector(RawObserved, MaximumSpeed)
    local Samples = Data.Samples or {}
    Samples[#Samples + 1] = Observed
    while #Samples > ResolverState.SampleLimit do table.remove(Samples, 1) end
    Data.Samples = Samples

    local RobustObserved, Jitter = ResolverGetRobustVelocity(Samples, MaximumSpeed)
    local PreviousSmoothed = Data.SmoothedVelocity or RobustObserved
    local SmoothAlpha = math.clamp(1 - math.exp(-14 * DeltaTime), 0.18, 0.82)
    local Smoothed = PreviousSmoothed:Lerp(RobustObserved, SmoothAlpha)
    local Directed = ResolverGetDirectedVelocity(Character, Root, MaximumSpeed)
    local Difference = (Smoothed - Reported).Magnitude
    local Alignment = 1

    if Smoothed.Magnitude > 1 and Reported.Magnitude > 1 then
        Alignment = Smoothed.Unit:Dot(Reported.Unit)
    end

    local PreviousObserved = Data.LastObservedVelocity or Vector3.new(0, 0, 0)
    if PreviousObserved.Magnitude > 5 and Observed.Magnitude > 5
        and PreviousObserved.Unit:Dot(Observed.Unit) < -0.15
    then
        Data.DirectionChanges = math.min((Data.DirectionChanges or 0) + 1, 8)
    else
        Data.DirectionChanges = math.max((Data.DirectionChanges or 0) - DeltaTime * 2.5, 0)
    end

    local Threshold = math.clamp(10 + PingSeconds * 70 + Jitter * 0.16, 10, 34)
    local ObservedMoving = Smoothed.Magnitude > 2.5
    local ReportedMoving = Reported.Magnitude > 2.5
    local Suspicious = Difference > Threshold
        or Alignment < -0.12
        or (ObservedMoving and not ReportedMoving)
        or (ReportedMoving and Smoothed.Magnitude < 0.75)
        or (Data.DirectionChanges or 0) >= 2

    local TargetScore = Suspicious and 1 or 0
    local ScoreAlpha = math.clamp(DeltaTime * 7.5, 0.12, 0.48)
    Data.DesyncScore = (Data.DesyncScore or 0) + (TargetScore - (Data.DesyncScore or 0)) * ScoreAlpha
    Data.IsDesynced = Data.DesyncScore >= 0.38
    Data.Jitter = Jitter

    local SampleConfidence = math.clamp(#Samples / ResolverState.SampleLimit, 0, 1)
    local JitterPenalty = math.clamp(Jitter / math.max(ResolverState.MaximumJitter, 1), 0, 0.75)
    Data.Confidence = SampleConfidence * (1 - JitterPenalty)

    local Resolved = Reported
    if #Samples >= ResolverState.MinimumSamples then
        if Data.IsDesynced then
            local DirectedWeight = Directed.Magnitude > 1 and 0.12 or 0
            Resolved = Smoothed:Lerp(Directed, DirectedWeight)
        else
            local Blend = math.clamp(0.22 + Data.Confidence * 0.42, 0.22, 0.64)
            Resolved = Reported:Lerp(Smoothed, Blend)
        end
    elseif Directed.Magnitude > 1 and Reported.Magnitude < 1 then
        Resolved = Directed
    end

    if Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air then
        Resolved = Vector3.new(Resolved.X, math.abs(Resolved.Y) < 10 and 0 or Resolved.Y, Resolved.Z)
    end

    Resolved = ResolverClampVector(Resolved, MaximumSpeed)
    local PreviousResolved = Data.ResolvedVelocity or Resolved
    local ResolveAlpha = Data.IsDesynced and 0.76 or 0.54
    Resolved = PreviousResolved:Lerp(Resolved, ResolveAlpha)

    local RawAcceleration = (Resolved - PreviousResolved) / math.max(DeltaTime, ResolverState.MinimumDelta)
    local Acceleration = ResolverClampVector(RawAcceleration, ResolverState.MaximumAcceleration)

    Data.ObservedVelocity = Observed
    Data.SmoothedVelocity = Smoothed
    Data.ResolvedVelocity = Resolved
    Data.Acceleration = (Data.Acceleration or Vector3.zero):Lerp(Acceleration, 0.24)
    Data.LastObservedVelocity = Observed
    Data.LastPosition = CurrentPosition
    Data.LastTime = CurrentTime
    return Data
end

function ResolverGetMovementVelocity(Player, Character, Settings)
    local Root = ResolverGetRoot(Character)

    if not Root then
        return Vector3.zero, nil
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RawReported = Root.AssemblyLinearVelocity or Root.Velocity or Vector3.new(0, 0, 0)
    local WalkSpeed = Humanoid and tonumber(Humanoid.WalkSpeed) or 16
    local MaximumSpeed = math.clamp(math.max(96, WalkSpeed * 7.5, RawReported.Magnitude * 1.75), 96, 260)
    local Reported = ResolverClampVector(RawReported, MaximumSpeed)

    if not Player then
        return Reported, nil
    end

    local Data = ResolverObservePlayer(
        Player,
        Character,
        Settings
    )

    if not Data then
        return Reported, nil
    end

    return ResolverClampVector(
        Data.ResolvedVelocity or Reported,
        MaximumSpeed
    ), Data
end

function ResolverGetFallbackPartOffset(Character, PartName)
    local Humanoid =
        Character
        and Character:FindFirstChildOfClass("Humanoid")

    local IsR6 =
        Humanoid
        and Humanoid.RigType == Enum.HumanoidRigType.R6

    if PartName == "Head" then
        return Vector3.new(
            0,
            IsR6 and 1.5 or 1.75,
            0
        )
    elseif PartName == "UpperTorso" then
        return Vector3.new(0, 0.75, 0)
    elseif PartName == "LowerTorso" then
        return Vector3.new(0, -0.15, 0)
    elseif PartName == "Torso" then
        return Vector3.new(0, 0.45, 0)
    end

    return Vector3.zero
end

function ResolverGetSafePartPosition(Character, TargetPart, UseStable)
    if not Character or not TargetPart or not TargetPart:IsA("BasePart") then return nil end

    local Root = ResolverGetRoot(Character)
    if not Root or not Root:IsA("BasePart") then return TargetPart.Position end

    local RawPosition = TargetPart.Position
    local RelativePosition = Root.CFrame:PointToObjectSpace(RawPosition)
    local PartName = TargetPart.Name
    local MaximumOffset = PartName == "Head" and 5.25
        or (string.find(string.lower(PartName), "torso", 1, true) and 5.75)
        or 8.5

    local Size = TargetPart.Size
    local SizeValid = ResolverIsFiniteVector(Size)
        and Size.X > 0.05 and Size.Y > 0.05 and Size.Z > 0.05
        and Size.Magnitude < 18
    local OffsetValid = ResolverIsFiniteVector(RelativePosition)
        and RelativePosition.Magnitude <= MaximumOffset

    local Cache = ResolverState.SafePartCache[TargetPart]
    if type(Cache) ~= "table" or Cache.Character ~= Character then
        Cache = { Character = Character, Offset = nil, LastUpdate = 0 }
        ResolverState.SafePartCache[TargetPart] = Cache
    end

    local CurrentTime = os.clock()
    if SizeValid and OffsetValid
        and CurrentTime - (Cache.LastUpdate or 0) >= ResolverState.PartOffsetUpdateInterval
    then
        if ResolverIsFiniteVector(Cache.Offset) then
            local Deviation = (RelativePosition - Cache.Offset).Magnitude
            if Deviation <= ResolverState.PoseDeviation then
                Cache.Offset = Cache.Offset:Lerp(RelativePosition, 0.18)
            end
        else
            Cache.Offset = RelativePosition
        end
        Cache.LastUpdate = CurrentTime
    end

    if UseStable then
        local StableOffset = ResolverIsFiniteVector(Cache.Offset)
            and Cache.Offset
            or ResolverGetFallbackPartOffset(Character, PartName)
        StableOffset = Vector3.new(
            math.clamp(StableOffset.X, -0.35, 0.35),
            StableOffset.Y,
            math.clamp(StableOffset.Z, -0.35, 0.35)
        )
        return Root.Position + StableOffset
    end

    if SizeValid and OffsetValid then return RawPosition end

    local SafeOffset = ResolverIsFiniteVector(Cache.Offset)
        and Cache.Offset
        or ResolverGetFallbackPartOffset(Character, PartName)
    return Root.CFrame:PointToWorldSpace(SafeOffset)
end

function ResolveCombatPosition(Player, Character, TargetPart, PredictionTime, Settings)
    if not Character or not TargetPart or not TargetPart:IsA("BasePart") then return nil, nil end

    Settings = Settings or {}
    local BaseTime = math.clamp(tonumber(PredictionTime) or 0, 0, 0.38)
    local Root = ResolverGetRoot(Character)
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RawVelocity = Root and (Root.AssemblyLinearVelocity or Root.Velocity or Vector3.zero) or Vector3.new(0, 0, 0)
    local WalkSpeed = Humanoid and tonumber(Humanoid.WalkSpeed) or 16
    local MaximumSpeed = math.clamp(math.max(84, WalkSpeed * 6.5, RawVelocity.Magnitude * 1.45), 84, 230)
    local ReportedVelocity = ResolverClampVector(RawVelocity, MaximumSpeed)
    local RawPosition = TargetPart.Position

    if Settings.Resolver == false or not Player then
        return RawPosition + ReportedVelocity * BaseTime, nil
    end

    local ResolvedVelocity, Data = ResolverGetMovementVelocity(Player, Character, Settings)
    local PingSeconds = ResolverGetPingSeconds()
    local SnapshotAge = Data and math.clamp(os.clock() - (Data.LastTime or os.clock()), 0, 0.10) or 0
    local NetworkLead = math.clamp(PingSeconds * 0.45 + SnapshotAge * 0.55, 0, 0.18)
    local TimeValue = math.clamp(BaseTime + NetworkLead, 0, ResolverState.MaximumPrediction)
    local Confidence = Data and tonumber(Data.Confidence) or 0
    local UseStablePose = Data and (Data.IsDesynced or (Data.Jitter or 0) > ResolverState.MaximumJitter * 0.65) or false
    local SafePosition = ResolverGetSafePartPosition(Character, TargetPart, UseStablePose) or RawPosition
    local Acceleration = Vector3.zero

    if Data and Confidence >= 0.42 and not Data.IsDesynced
        and (Data.Jitter or 0) < ResolverState.MaximumJitter
    then
        Acceleration = ResolverClampVector(Data.Acceleration or Vector3.zero, 72)
    end

    if Humanoid and Humanoid.FloorMaterial ~= Enum.Material.Air and math.abs(ResolvedVelocity.Y) < 10 then
        ResolvedVelocity = Vector3.new(ResolvedVelocity.X, 0, ResolvedVelocity.Z)
        Acceleration = Vector3.new(Acceleration.X, 0, Acceleration.Z)
    end

    local NormalPrediction = RawPosition + ReportedVelocity * TimeValue
    local ResolvedPrediction = SafePosition + ResolvedVelocity * TimeValue
        + Acceleration * (0.5 * TimeValue * TimeValue)
    local MaximumTravel = MaximumSpeed * TimeValue + 1.25
    local Travel = ResolvedPrediction - SafePosition

    if Travel.Magnitude > MaximumTravel and Travel.Magnitude > 0 then
        ResolvedPrediction = SafePosition + Travel.Unit * MaximumTravel
    end

    local Strength = Data and Data.IsDesynced and 0.94
        or math.clamp(0.42 + Confidence * 0.48, 0.42, 0.90)
    return NormalPrediction:Lerp(ResolvedPrediction, Strength), Data
end

local HitSounds = {
    ["None"] = "",
    ["Rust Headshot"] = "rbxassetid://5043539486",
    ["Keyboard"] = "rbxassetid://18439144240",
    ["Minecraft"] = "rbxassetid://8766809464",
    ["Minecraft2"] = "rbxassetid://3442683707",
    ["Skeet"] = "rbxassetid://4817809188",
    ["Neverlose"] = "rbxassetid://97643101798871",
    ["Medal"] = "rbxassetid://6607336718",
    ["Fatality"] = "rbxassetid://115982072912004",
    ["Mortal Combat"] = "rbxassetid://108030242037022",
    ["Switches"] = "rbxassetid://6607173363",
    ["Bubble"] = "rbxassetid://6534947588",
    ["Laser"] = "rbxassetid://7837461331",
    ["Steve"] = "rbxassetid://4965083997",
    ["Call of Duty"] = "rbxassetid://5952120301",
    ["Bat"] = "rbxassetid://3333907347",
    ["TF2 Critical"] = "rbxassetid://296102734",
    ["Saber"] = "rbxassetid://8415678813",
    ["Bameware"] = "rbxassetid://3124331820",
    ["Tick"] = "rbxassetid://134410911353980",
    ["Taco Bell"] = "rbxassetid://127488139302452"
}

local HitSoundNames = { "None", "Rust Headshot", "Keyboard", "Minecraft", "Minecraft2", "Skeet", "Neverlose", "Medal", "Fatality", "Mortal Combat", "Switches", "Bubble", "Laser", "Steve", "Call of Duty", "Bat", "TF2 Critical", "Saber", "Bameware", "Tick", "Taco Bell" }

local HitFeedbackState = { ImpactEnabled = false, ImpactColor = Color3.fromRGB(170, 0, 255), ImpactTransparency = 0.5, ImpactStyle = "Character", HitmarkerEnabled = true,
    HitmarkerColor = Color3.fromRGB(255, 255, 255), HeadshotHitmarkerColor = Color3.fromRGB(255, 82, 82), HitmarkerSize = 28, HitmarkerDuration = 0.24,
    HitSound = "None", HitSoundVolume = 1, HitSoundPlaybackSpeed = 1, DamageIndicatorEnabled = true, DamageColor = Color3.fromRGB(255, 255, 255),
    HeadshotDamageColor = Color3.fromRGB(255, 82, 82), DamageTextSize = 18, DamageDuration = 0.85, DamageRise = 2.8, BulletTracerEnabled = false,
    BulletTracerColor = Color3.fromRGB(54, 218, 145), BulletTracerTime = 0.32, BulletTracerRate = 28, BulletTracerWidth = 0.10, BulletTracerGlow = 2, BulletTracerStyle = "Energy" }

local AttackConfirmationState = { Shots = {}, Window = 1.00, DamageWindow = 0.80, MergeWindow = 0.16, SignalWindow = 0.30, MaximumShots = 96, ShotRange = 5000, PendingDamage = setmetatable({}, { __mode = "k" }),
    BufferedDamage = setmetatable({}, { __mode = "k" }) }

local HitFeedbackRuntimeState = { ActiveObjects = setmetatable({}, { __mode = "k" }), BulletTracerMuzzleCache = setmetatable({}, { __mode = "k" }), BulletTracerAmmoObjects = setmetatable({},
    { __mode = "k" }), BulletTracerAmmoSuppression = setmetatable({}, { __mode = "k" }), BulletTracerWeaponCache = setmetatable({}, { __mode = "k" }),
    BulletTracerLastSpawn = setmetatable({}, { __mode = "k" }), BulletTracerLastRemoteShot = setmetatable({}, { __mode = "k" }), ActiveBulletTracers = 0, BulletTracerSerial = 0 }

local function IsHitFeedbackEnabled() return HitFeedbackState.HitmarkerEnabled or HitFeedbackState.ImpactEnabled or HitFeedbackState.DamageIndicatorEnabled or HitFeedbackState.HitParticlesEnabled == true or HitFeedbackState.HitSound ~= "None" end
local function IsShotTrackingEnabled() return HitFeedbackState.BulletTracerEnabled or IsHitFeedbackEnabled() end

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
        local Expired = not Shot or CurrentTime - (Shot.Time or 0) > AttackConfirmationState.Window
        local Completed = Shot and Shot.DamageConfirmed and CurrentTime - (Shot.ConfirmedAt or Shot.Time or 0) > AttackConfirmationState.MergeWindow
        if Expired or Completed then table.remove(AttackConfirmationState.Shots, Index) end
    end
    while #AttackConfirmationState.Shots > AttackConfirmationState.MaximumShots do table.remove(AttackConfirmationState.Shots, 1) end
end

local function ResolveLocalAttackTarget(TargetCharacter, TargetPart)
    TargetCharacter = TargetCharacter or GetHumanoidCharacterFromPart(TargetPart)
    local TargetPlayer = GetPlayerFromTrackedCharacter(TargetCharacter)
    if not TargetPlayer or TargetPlayer == LocalPlayer or not TargetCharacter then return nil, nil, nil, nil end
    local ResolvedCharacter = ResolveTrackedCharacter(TargetPlayer, TargetCharacter)
    if ResolvedCharacter then TargetCharacter = ResolvedCharacter end
    local PartName = TargetPart and TargetPart.Name or nil
    if TargetPart and not TargetPart:IsDescendantOf(TargetCharacter) then TargetPart = PartName and TargetCharacter:FindFirstChild(PartName, true) or nil end
    if not TargetPart then TargetPart = TargetCharacter:FindFirstChild("HumanoidRootPart") or TargetCharacter:FindFirstChild("Head") or TargetCharacter.PrimaryPart end
    if not TargetPart or not TargetPart:IsA("BasePart") then return TargetPlayer, TargetCharacter, nil, PartName end
    return TargetPlayer, TargetCharacter, TargetPart, TargetPart.Name
end

local IsVerifiedLocalFirearmTool

local function RegisterLocalAttack(TargetCharacter, TargetPart, ShotToken, Tool, Source, OriginPosition, Direction)
    if not Tool or not Tool:IsA("Tool") or type(IsVerifiedLocalFirearmTool) ~= "function" or not IsVerifiedLocalFirearmTool(Tool) then return nil end
    local TargetPlayer, ResolvedCharacter, ResolvedPart, PartName = ResolveLocalAttackTarget(TargetCharacter, TargetPart)
    CleanupAttackConfirmations()
    local CurrentTime = os.clock()

    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Existing = AttackConfirmationState.Shots[Index]
        local SameToken = ShotToken ~= nil and Existing.Token ~= nil and tostring(Existing.Token) == tostring(ShotToken)
        local SameRemoteShot = Existing.Tool == Tool and CurrentTime - (Existing.Time or 0) <= 0.022
        if Existing.VerifiedFire and (SameToken or SameRemoteShot) then
            Existing.Time = CurrentTime
            Existing.Token = ShotToken or Existing.Token
            Existing.Source = Source or Existing.Source
            Existing.Origin = typeof(OriginPosition) == "Vector3" and OriginPosition or Existing.Origin
            Existing.Direction = typeof(Direction) == "Vector3" and Direction or Existing.Direction
            if TargetPlayer and ResolvedCharacter then
                Existing.Player = TargetPlayer
                Existing.Character = ResolvedCharacter
                Existing.PartName = Existing.PartName == "Head" and "Head" or PartName
            end
            return Existing
        end
    end

    local Shot = {
        Time = CurrentTime,
        Player = TargetPlayer,
        Character = ResolvedCharacter,
        PartName = PartName,
        Token = ShotToken,
        Tool = Tool,
        Source = Source or "Local",
        Origin = typeof(OriginPosition) == "Vector3" and OriginPosition or nil,
        Direction = typeof(Direction) == "Vector3" and Direction or nil,
        VerifiedFire = true,
        ConfirmedAt = nil,
        SignalConfirmed = false,
        DamageConfirmed = false,
        TracerSpawned = false
    }
    AttackConfirmationState.Shots[#AttackConfirmationState.Shots + 1] = Shot
    return Shot
end

local function AttachAttackTarget(Shot, TargetCharacter, TargetPart)
    if not Shot or not Shot.VerifiedFire then return false end
    local TargetPlayer, ResolvedCharacter, ResolvedPart, PartName = ResolveLocalAttackTarget(TargetCharacter, TargetPart)
    if not TargetPlayer or not ResolvedCharacter then return false end
    Shot.Player = TargetPlayer
    Shot.Character = ResolvedCharacter
    Shot.PartName = Shot.PartName == "Head" and "Head" or PartName
    return true
end

local function FindAttackConfirmation(Character)
    CleanupAttackConfirmations()
    local CurrentTime = os.clock()
    local TargetPlayer = GetPlayerFromTrackedCharacter(Character)
    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Shot = AttackConfirmationState.Shots[Index]
        local MatchesTarget = Shot and (Shot.Character == Character or TargetPlayer and Shot.Player == TargetPlayer)
        if Shot and Shot.VerifiedFire and not Shot.DamageConfirmed and MatchesTarget and CurrentTime - (Shot.Time or 0) <= AttackConfirmationState.DamageWindow then
            Shot.ConfirmedAt = CurrentTime
            return Shot
        end
    end
    return nil
end

local function GetActiveConfirmedCombatTarget()
    if RageBotEnabled and RageBotCurrentTarget then return RageBotCurrentTarget end
    local AimBot = S and S.AimBot
    if AimBot and AimBot.Enabled then return AimBot.CurrentTarget or AimBot.Target end
    return nil
end

local function FindTargetAwareAttackConfirmation(Player, Character)
    local Exact = FindAttackConfirmation(Character)
    if Exact then return Exact end

    local ActiveTarget = GetActiveConfirmedCombatTarget()
    if ActiveTarget ~= Player then return nil end

    CleanupAttackConfirmations()
    local CurrentTime = os.clock()
    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Shot = AttackConfirmationState.Shots[Index]
        if Shot and Shot.VerifiedFire and not Shot.DamageConfirmed and CurrentTime - (Shot.Time or 0) <= AttackConfirmationState.DamageWindow then
            local Source = tostring(Shot.Source or "")
            local IsCombatShot = Source == "RageBot" or Source == "Remote" or Source == "Aimbot"
            local HasNoResolvedTarget = Shot.Player == nil or Shot.Character == nil
            if IsCombatShot and HasNoResolvedTarget then
                Shot.Player = Player
                Shot.Character = Character
                Shot.PartName = Shot.PartName or (RageBotSettings.TargetPart or "Head")
                Shot.ConfirmedAt = CurrentTime
                return Shot
            end
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

IsVerifiedLocalFirearmTool = function(Tool)
    local Character = LocalPlayer.Character
    return Tool ~= nil and Tool:IsA("Tool") and Character ~= nil and Tool.Parent == Character and IsBulletTracerWeapon(Tool)
end

local function IsLocalGunShotRemote(Remote)
    return typeof(Remote) == "Instance" and Remote:IsA("RemoteEvent") and Remote.Name == "GNX_S" and Remote:IsDescendantOf(ReplicatedStorage)
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
    if not IsVerifiedLocalFirearmTool(Tool) then return end
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

local function SpawnDirectionalBulletTracer(OriginPosition, TargetPosition, Tool, VerifiedFirearmShot)
    if not HitFeedbackState.BulletTracerEnabled or not OriginPosition or not TargetPosition then return end
    if not IsVerifiedLocalFirearmTool(Tool) then return end
    SpawnBulletTracer(OriginPosition, TargetPosition, Tool, VerifiedFirearmShot)
end

HitFeedbackRuntimeState.SpawnConfirmedTracer = function(Shot, TargetPart)
    if not HitFeedbackState.BulletTracerEnabled or not Shot or Shot.TracerSpawned then return false end
    local Tool = Shot.Tool
    if not IsVerifiedLocalFirearmTool(Tool) then return false end
    if not TargetPart or not TargetPart:IsA("BasePart") or not TargetPart.Parent then return false end
    local OriginPosition = typeof(Shot.Origin) == "Vector3" and Shot.Origin or GetBulletTracerOrigin(Tool)
    local TargetPosition = TargetPart.Position
    if typeof(OriginPosition) ~= "Vector3" or typeof(TargetPosition) ~= "Vector3" or (TargetPosition - OriginPosition).Magnitude < 0.5 then return false end
    Shot.TracerSpawned = true
    SpawnDirectionalBulletTracer(OriginPosition, TargetPosition, Tool, true)
    return true
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
    if not IsVerifiedLocalFirearmTool(Tool) then return false end

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
    if not IsVerifiedLocalFirearmTool(Tool) then return end

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
    if not HitFeedbackState.BulletTracerEnabled or not IsVerifiedLocalFirearmTool(Tool) then return end
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
    local ShotToken = MarkerIndex >= 3 and Arguments[MarkerIndex - 2] or nil

    for Index = 1, Arguments.n do
        local Value = Arguments[Index]
        if not Tool and typeof(Value) == "Instance" and Value:IsA("Tool") then Tool = Value end
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

    if not Tool then Tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool") end
    if Tool and not OriginPosition then OriginPosition = GetBulletTracerOrigin(Tool) end
    return Tool, OriginPosition, Direction, ShotToken
end

function ResolveCapturedShotTarget(OriginPosition, Direction, Tool)
    if typeof(OriginPosition) ~= "Vector3" or typeof(Direction) ~= "Vector3" or Direction.Magnitude < 0.01 then return nil, nil end
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
    if not Result then return nil, nil end
    local Character = GetHumanoidCharacterFromPart(Result.Instance)
    if not Character then return nil, nil end
    return Character, Result.Instance
end

function DispatchBulletTracerRemoteShot(Remote, ...)
    if not IsLocalGunShotRemote(Remote) then return false end
    local Tool, OriginPosition, Direction, ShotToken = ParseBulletTracerRemoteArguments(...)
    if not IsVerifiedLocalFirearmTool(Tool) then return false end

    HitFeedbackRuntimeState.BulletTracerLastRemoteShot[Tool] = os.clock()
    local TargetCharacter, TargetPart = ResolveCapturedShotTarget(OriginPosition, Direction, Tool)
    local Shot = RegisterLocalAttack(TargetCharacter, TargetPart, ShotToken, Tool, "Remote", OriginPosition, Direction)
    if not Shot then return false end

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
                task.defer(DispatchBulletTracerRemoteShot, Self, table.unpack(Arguments, 1, Arguments.n))
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

    if type(State) ~= "table" or State.TrackerVersion ~= 8 then
        if type(State) == "table" then State.Enabled = false end
        State = {}
        rawset(Environment, "RadiantBulletTracerShotHook", State)
    end

    State.TrackerVersion = 8
    State.Version = tonumber(State.Version) or 0
    State.FireServerVersion = tonumber(State.FireServerVersion) or 0
    State.Enabled = IsShotTrackingEnabled()
    State.ShootHooks = setmetatable({}, { __mode = "k" })
    State.ScanningFunctions = false

    local FireServerInstalled = InstallBulletTracerFireServerHook(State)

    if not FireServerInstalled
        and State.Version < 5
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
                    task.defer(DispatchBulletTracerRemoteShot, Self, table.unpack(Arguments, 1, Arguments.n))
                end
                return table.unpack(Results, 1, Results.n)
            end))
        end)
        if Success and OldNamecall then State.Version = 5 end
    end

    return FireServerInstalled or State.Version >= 5
end

function RefreshLocalShotTracking()
    InstallBulletTracerShotHook()
    local State = getgenv().RadiantBulletTracerShotHook
    if type(State) == "table" then State.Enabled = IsShotTrackingEnabled() end
end

function SetBulletTracerShotHookEnabled(Value)
    HitFeedbackState.BulletTracerEnabled = Value == true
    RefreshLocalShotTracking()
end

local function GetBulletTracerAmmoValue(Tool)
    local Data = GetBulletTracerWeaponData(Tool)
    return Data and Data.Ammo or nil
end

local function BindBulletTracerAmmo(Tool, Connections)
    return IsBulletTracerWeapon(Tool)
end

local function GetConfirmedHitmarkerParent()
    local Holder = Library and Library.Holder
    local HolderInstance = Holder and (Holder.Instance or Holder)
    if typeof(HolderInstance) == "Instance" and HolderInstance:IsA("ScreenGui") and HolderInstance.Parent then
        return HolderInstance
    end

    local Existing = HitFeedbackRuntimeState.HitmarkerGui
    if Existing and Existing.Parent then return Existing end

    local Parent = GetHitFeedbackGuiParent()
    if not Parent then return nil end

    local Gui = Instance.new("ScreenGui")
    Gui.Name = "RadiantConfirmedHitmarkerGui"
    Gui.IgnoreGuiInset = true
    Gui.ResetOnSpawn = false
    Gui.DisplayOrder = 99999
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    Gui.Parent = Parent
    HitFeedbackRuntimeState.HitmarkerGui = Gui
    HitFeedbackRuntimeState.ActiveObjects[Gui] = true
    return Gui
end

local function SpawnConfirmedHitmarker(IsHeadshot)
    if not HitFeedbackState.HitmarkerEnabled then return end
    local Parent = GetConfirmedHitmarkerParent()
    if not Parent then return end

    local Size = math.clamp(tonumber(HitFeedbackState.HitmarkerSize) or 28, 12, 60)
    local Duration = math.clamp(tonumber(HitFeedbackState.HitmarkerDuration) or 0.24, 0.08, 1)
    local Color = IsHeadshot and HitFeedbackState.HeadshotHitmarkerColor or HitFeedbackState.HitmarkerColor

    local Holder = Instance.new("Frame")
    Holder.Name = "RadiantConfirmedHitmarker"
    Holder.AnchorPoint = Vector2.new(0.5, 0.5)
    Holder.Position = UDim2.fromScale(0.5, 0.5)
    Holder.Size = UDim2.fromOffset(Size * 2, Size * 2)
    Holder.BackgroundTransparency = 1
    Holder.BorderSizePixel = 0
    Holder.ZIndex = 10000
    Holder.Parent = Parent
    HitFeedbackRuntimeState.ActiveObjects[Holder] = true

    local Scale = Instance.new("UIScale")
    Scale.Scale = 0.68
    Scale.Parent = Holder

    local Thickness = math.max(math.floor(Size * 0.11 + 0.5), 2)
    local ArmLength = math.max(math.floor(Size * 0.48 + 0.5), 7)
    local Gap = math.max(math.floor(Size * 0.16 + 0.5), 3)

    local function CreateArm(Rotation, X, Y)
        local Arm = Instance.new("Frame")
        Arm.Name = "Arm"
        Arm.AnchorPoint = Vector2.new(0.5, 0.5)
        Arm.Position = UDim2.new(0.5, X * (Gap + ArmLength * 0.5), 0.5, Y * (Gap + ArmLength * 0.5))
        Arm.Size = UDim2.fromOffset(ArmLength, Thickness)
        Arm.Rotation = Rotation
        Arm.BackgroundColor3 = Color
        Arm.BackgroundTransparency = 0
        Arm.BorderSizePixel = 0
        Arm.ZIndex = 10001
        Arm.Parent = Holder
        return Arm
    end

    local Root = math.sqrt(0.5)
    local Arms = {
        CreateArm(45, Root, Root),
        CreateArm(45, -Root, -Root),
        CreateArm(-45, Root, -Root),
        CreateArm(-45, -Root, Root)
    }

    TweenService:Create(Scale, TweenInfo.new(math.min(Duration * 0.35, 0.10), Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    task.delay(math.min(Duration * 0.30, 0.08), function()
        if not Holder.Parent then return end
        TweenService:Create(Scale, TweenInfo.new(math.max(Duration * 0.70, 0.08), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.16 }):Play()
        for _, Arm in ipairs(Arms) do
            TweenService:Create(Arm, TweenInfo.new(math.max(Duration * 0.70, 0.08), Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
        end
    end)

    task.delay(Duration + 0.06, function()
        HitFeedbackRuntimeState.ActiveObjects[Holder] = nil
        if Holder.Parent then Holder:Destroy() end
    end)
end

local function PlayConfirmedHitSound()
    local SoundId = HitSounds[HitFeedbackState.HitSound]
    if type(SoundId) ~= "string" or SoundId == "" then return end

    local Sound = Instance.new("Sound")
    Sound.Name = "RadiantConfirmedHitSound"
    Sound.SoundId = SoundId
    Sound.Volume = math.clamp(tonumber(HitFeedbackState.HitSoundVolume) or 1, 0, 5)
    Sound.PlaybackSpeed = math.clamp(tonumber(HitFeedbackState.HitSoundPlaybackSpeed) or 1, 0.5, 2)
    Sound.Parent = SoundService
    HitFeedbackRuntimeState.ActiveObjects[Sound] = true

    local Finished = false
    local function DestroySound()
        if Finished then return end
        Finished = true
        HitFeedbackRuntimeState.ActiveObjects[Sound] = nil
        if Sound.Parent then Sound:Destroy() end
    end

    local EndedConnection
    EndedConnection = Sound.Ended:Connect(function()
        if EndedConnection then EndedConnection:Disconnect() end
        DestroySound()
    end)

    local Success = pcall(function() Sound:Play() end)
    if not Success then
        if EndedConnection then EndedConnection:Disconnect() end
        DestroySound()
        return
    end

    task.delay(6, function()
        if EndedConnection then EndedConnection:Disconnect() end
        DestroySound()
    end)
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


local WorldEffectsState = {
    Enabled = false,
    Effect = "Sakura",
    Intensity = 70,
    Radius = 65,
    Height = 42,
    Wind = 8,
    Folder = nil,
    Anchor = nil,
    Connection = nil,
    Generation = 0,
    SpawnAccumulator = 0,
    StepAccumulator = 0,
    WeatherActive = 0,
    SplashActive = 0,
    SplashLimit = 24,
    MaxPool = 144,
    UpdateRate = 30,
    Pool = {},
    Active = {}
}

local HitParticleState = {
    Enabled = false,
    Style = "Sparks",
    Color = Color3.fromRGB(95, 255, 180),
    Count = 18,
    Lifetime = 0.55,
    Size = 0.22
}

local WorldEffectTextures = {
    Sakura = "rbxassetid://243660364",
    Rain = "rbxassetid://241876196",
    Snow = "rbxassetid://8158344433",
    Embers = "rbxassetid://1266170131",
    Fireflies = "rbxassetid://296874871"
}

local function ReleaseWorldBeamNode(Node)
    if not Node then return end
    if Node.IsSplash then
        WorldEffectsState.SplashActive = math.max((WorldEffectsState.SplashActive or 0) - 1, 0)
    else
        WorldEffectsState.WeatherActive = math.max((WorldEffectsState.WeatherActive or 0) - 1, 0)
    end
    Node.Active = false
    Node.IsSplash = false
    Node.Effect = nil
    Node.ImpactPosition = nil
    Node.ImpactNormal = nil
    Node.SurfacePoint = nil
    Node.SurfaceNormal = nil
    Node.Gravity = nil
    Node.Drag = nil
    Node.Bounces = nil
    Node.BaseCoreWidth = nil
    Node.BaseGlowWidth = nil
    if Node.Core then Node.Core.Enabled = false end
    if Node.Glow then Node.Glow.Enabled = false end
    if Node.A0 then Node.A0.Position = Vector3.new(0, -10000, 0) end
    if Node.A1 then Node.A1.Position = Vector3.new(0, -10000, 0) end
    if #WorldEffectsState.Pool < (WorldEffectsState.MaxPool or 144) then
        WorldEffectsState.Pool[#WorldEffectsState.Pool + 1] = Node
    end
end

local function DestroyWorldEffects()
    WorldEffectsState.Generation += 1
    if WorldEffectsState.Connection then pcall(function() WorldEffectsState.Connection:Disconnect() end) end
    WorldEffectsState.Connection = nil
    WorldEffectsState.Active = {}
    WorldEffectsState.Pool = {}
    if WorldEffectsState.Folder then pcall(function() WorldEffectsState.Folder:Destroy() end) end
    WorldEffectsState.Folder = nil
    WorldEffectsState.Anchor = nil
    WorldEffectsState.SpawnAccumulator = 0
    WorldEffectsState.StepAccumulator = 0
    WorldEffectsState.WeatherActive = 0
    WorldEffectsState.SplashActive = 0
end

local function CreateWorldBeamNode(Anchor)
    local A0 = Instance.new("Attachment")
    A0.Name = "Beam0"
    A0.Position = Vector3.new(0, -10000, 0)
    A0.Parent = Anchor
    local A1 = Instance.new("Attachment")
    A1.Name = "Beam1"
    A1.Position = Vector3.new(0, -10000, 0)
    A1.Parent = Anchor
    local Core = Instance.new("Beam")
    Core.Name = "Core"
    Core.Attachment0 = A0
    Core.Attachment1 = A1
    Core.Enabled = false
    Core.FaceCamera = true
    Core.LightInfluence = 0
    Core.LightEmission = 0.65
    Core.Brightness = 1
    Core.Segments = 1
    Core.Width0 = 0.04
    Core.Width1 = 0.01
    Core.Transparency = NumberSequence.new(0.15)
    Core.Parent = Anchor
    local Glow = Instance.new("Beam")
    Glow.Name = "Glow"
    Glow.Attachment0 = A0
    Glow.Attachment1 = A1
    Glow.Enabled = false
    Glow.FaceCamera = true
    Glow.LightInfluence = 0
    Glow.LightEmission = 1
    Glow.Brightness = 0.55
    Glow.Segments = 1
    Glow.Width0 = 0.10
    Glow.Width1 = 0.025
    Glow.Transparency = NumberSequence.new(0.82)
    Glow.Parent = Anchor
    return { A0 = A0, A1 = A1, Core = Core, Glow = Glow, Active = false }
end

local function AcquireWorldBeamNode(Anchor)
    local Node = table.remove(WorldEffectsState.Pool)
    if not Node or not Node.A0 or not Node.A0.Parent then Node = CreateWorldBeamNode(Anchor) end
    Node.Active = true
    Node.Core.Enabled = true
    Node.Glow.Enabled = true
    return Node
end

local function ConfigureWorldBeamNode(Node, Effect, CameraObject)
    local Radius = math.max(tonumber(WorldEffectsState.Radius) or 65, 15)
    local Height = math.max(tonumber(WorldEffectsState.Height) or 42, 12)
    local Wind = tonumber(WorldEffectsState.Wind) or 0
    local CameraFrame = CameraObject.CFrame
    local CameraPosition = CameraFrame.Position
    local Forward = Vector3.new(CameraFrame.LookVector.X, 0, CameraFrame.LookVector.Z)
    if Forward.Magnitude <= 0.05 then Forward = Vector3.new(0, 0, -1) else Forward = Forward.Unit end
    local Right = Vector3.new(-Forward.Z, 0, Forward.X)
    local Side = (math.random() * 2 - 1) * Radius
    local Front = (math.random() ^ 0.72) * Radius + 5
    local Phase = math.random() * math.pi * 2
    Node.Effect = Effect
    Node.IsSplash = false
    Node.Age = 0
    Node.Phase = Phase
    Node.ImpactPosition = nil
    Node.ImpactNormal = nil
    Node.Curve = 0
    Node.Sway = Right * (0.4 + math.random() * 1.2) + Forward * (math.random() * 0.5 - 0.25)
    Node.Frequency = 0.8 + math.random() * 2.8
    Node.Position = CameraPosition + Forward * Front + Right * Side
    Node.Core.Texture = ""
    Node.Glow.Texture = ""
    Node.Core.CurveSize0 = 0
    Node.Core.CurveSize1 = 0
    Node.Glow.CurveSize0 = 0
    Node.Glow.CurveSize1 = 0
    Node.Core.Brightness = 1
    Node.Glow.Brightness = 0.52
    if Effect == "Rain" then
        Node.Position += Vector3.new(0, Height * (0.55 + math.random() * 0.75), 0)
        Node.Velocity = Vector3.new(Wind * 0.72, -(88 + math.random() * 52), Wind * 0.10)
        Node.Length = 4.5 + math.random() * 5.5
        Node.Lifetime = 1.2 + math.random() * 0.65
        Node.Core.Segments = 1
        Node.Glow.Segments = 1
        Node.Core.Width0, Node.Core.Width1 = 0.028, 0.004
        Node.Glow.Width0, Node.Glow.Width1 = 0.085, 0.012
        Node.Core.Color = ColorSequence.new(Color3.fromRGB(188, 220, 255), Color3.fromRGB(238, 248, 255))
        Node.Glow.Color = ColorSequence.new(Color3.fromRGB(95, 165, 255), Color3.fromRGB(210, 235, 255))
        Node.Core.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.06), NumberSequenceKeypoint.new(0.82, 0.24), NumberSequenceKeypoint.new(1, 0.92) })
        Node.Glow.Transparency = NumberSequence.new(0.87)
        if math.random() < 0.22 and (WorldEffectsState.SplashLimit or 0) > 0 then
            local Parameters = RaycastParams.new()
            Parameters.FilterType = Enum.RaycastFilterType.Exclude
            Parameters.IgnoreWater = false
            Parameters.FilterDescendantsInstances = { WorldEffectsState.Folder, LocalPlayer.Character, CameraObject }
            local Direction = Node.Velocity.Unit * math.min(Node.Velocity.Magnitude * Node.Lifetime, 190)
            local Result = workspace:Raycast(Node.Position, Direction, Parameters)
            if Result then
                Node.Lifetime = math.max(Result.Distance / math.max(Node.Velocity.Magnitude, 1), 0.08)
                Node.ImpactPosition = Result.Position
                Node.ImpactNormal = Result.Normal
            end
        end
    elseif Effect == "Sakura" then
        Node.Position += Vector3.new(0, math.random() * Height * 0.90 - Height * 0.08, 0)
        Node.Velocity = Vector3.new(Wind * 0.28, -(3.2 + math.random() * 4.3), Wind * 0.06)
        Node.Length = 0.52 + math.random() * 0.55
        Node.Lifetime = 5.2 + math.random() * 4.2
        Node.Sway *= 1.8
        Node.Core.Segments = 7
        Node.Glow.Segments = 7
        Node.Core.Width0, Node.Core.Width1 = 0.18, 0.018
        Node.Glow.Width0, Node.Glow.Width1 = 0.29, 0.035
        Node.Core.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 126, 190)), ColorSequenceKeypoint.new(0.55, Color3.fromRGB(255, 218, 237)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 160, 210)) })
        Node.Glow.Color = ColorSequence.new(Color3.fromRGB(255, 118, 193), Color3.fromRGB(255, 225, 242))
        Node.Core.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.10), NumberSequenceKeypoint.new(0.62, 0.04), NumberSequenceKeypoint.new(1, 0.90) })
        Node.Glow.Transparency = NumberSequence.new(0.88)
    elseif Effect == "Snow" then
        Node.Position += Vector3.new(0, math.random() * Height, 0)
        Node.Velocity = Vector3.new(Wind * 0.11, -(2.1 + math.random() * 3.4), Wind * 0.03)
        Node.Length = 0.14 + math.random() * 0.26
        Node.Lifetime = 6.5 + math.random() * 5.5
        Node.Sway *= 1.35
        Node.Core.Segments = 3
        Node.Glow.Segments = 3
        Node.Core.Width0, Node.Core.Width1 = 0.075, 0.018
        Node.Glow.Width0, Node.Glow.Width1 = 0.15, 0.035
        Node.Core.Color = ColorSequence.new(Color3.fromRGB(235, 246, 255), Color3.fromRGB(255, 255, 255))
        Node.Glow.Color = ColorSequence.new(Color3.fromRGB(180, 220, 255), Color3.fromRGB(255, 255, 255))
        Node.Core.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.04), NumberSequenceKeypoint.new(1, 0.72) })
        Node.Glow.Transparency = NumberSequence.new(0.88)
    elseif Effect == "Embers" then
        Node.Position += Vector3.new(0, math.random() * math.min(Height, 14) - 3, 0)
        Node.Velocity = Vector3.new(Wind * 0.12, 5.5 + math.random() * 10.5, Wind * 0.025)
        Node.Length = 0.35 + math.random() * 0.85
        Node.Lifetime = 2.1 + math.random() * 3.0
        Node.Sway *= 0.85
        Node.Core.Segments = 4
        Node.Glow.Segments = 4
        Node.Core.Width0, Node.Core.Width1 = 0.052, 0.004
        Node.Glow.Width0, Node.Glow.Width1 = 0.16, 0.012
        Node.Core.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 250, 155)), ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 154, 38)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 45, 8)) })
        Node.Glow.Color = ColorSequence.new(Color3.fromRGB(255, 205, 70), Color3.fromRGB(255, 55, 10))
        Node.Core.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 0.90) })
        Node.Glow.Transparency = NumberSequence.new(0.78)
        Node.Core.Brightness = 1.35
        Node.Glow.Brightness = 0.85
    elseif Effect == "Fireflies" then
        Node.Position += Vector3.new(0, math.random() * math.min(Height, 24) - 4, 0)
        Node.Velocity = Vector3.new(Wind * 0.018, math.random() * 0.5 - 0.25, 0)
        Node.Length = 0.07 + math.random() * 0.10
        Node.Lifetime = 4.0 + math.random() * 5.0
        Node.Sway *= 0.72
        Node.Core.Segments = 2
        Node.Glow.Segments = 2
        Node.Core.Width0, Node.Core.Width1 = 0.11, 0.055
        Node.Glow.Width0, Node.Glow.Width1 = 0.32, 0.16
        Node.Core.Color = ColorSequence.new(Color3.fromRGB(255, 255, 190), Color3.fromRGB(155, 255, 74))
        Node.Glow.Color = ColorSequence.new(Color3.fromRGB(225, 255, 95), Color3.fromRGB(115, 255, 45))
        Node.Core.Transparency = NumberSequence.new(0.04)
        Node.Glow.Transparency = NumberSequence.new(0.70)
        Node.Core.Brightness = 1.5
        Node.Glow.Brightness = 1
    else
        Node.Effect = "RainSplash"
        Node.Position = CameraPosition
        Node.Velocity = Vector3.new(0, 0, 0)
        Node.Length = 0.15
        Node.Lifetime = 0.18
    end
end

local function SpawnWorldBeam(CameraObject)
    local Anchor = WorldEffectsState.Anchor
    if not Anchor or not Anchor.Parent then return end
    local Node = AcquireWorldBeamNode(Anchor)
    ConfigureWorldBeamNode(Node, WorldEffectsState.Effect, CameraObject)
    WorldEffectsState.WeatherActive = (WorldEffectsState.WeatherActive or 0) + 1
    WorldEffectsState.Active[#WorldEffectsState.Active + 1] = Node
end

local function SpawnWorldBeamSplash(Position, Normal, ImpactVelocity, CameraObject)
    local Anchor = WorldEffectsState.Anchor
    if not Anchor or not Anchor.Parent or typeof(Position) ~= "Vector3" or not CameraObject then return end
    local SplashLimit = math.clamp(tonumber(WorldEffectsState.SplashLimit) or 24, 8, 30)
    if (WorldEffectsState.SplashActive or 0) >= SplashLimit then return end
    local SurfaceNormal = typeof(Normal) == "Vector3" and Normal or Vector3.new(0, 1, 0)
    if SurfaceNormal.Magnitude <= 0.01 then SurfaceNormal = Vector3.new(0, 1, 0) else SurfaceNormal = SurfaceNormal.Unit end
    local ReferenceAxis = math.abs(SurfaceNormal.Y) < 0.88 and Vector3.new(0, 1, 0) or CameraObject.CFrame.RightVector
    local TangentA = SurfaceNormal:Cross(ReferenceAxis)
    if TangentA.Magnitude <= 0.01 then TangentA = SurfaceNormal:Cross(Vector3.new(0, 0, 1)) end
    if TangentA.Magnitude <= 0.01 then TangentA = Vector3.new(1, 0, 0) else TangentA = TangentA.Unit end
    local TangentB = SurfaceNormal:Cross(TangentA)
    if TangentB.Magnitude <= 0.01 then TangentB = Vector3.new(0, 0, 1) else TangentB = TangentB.Unit end
    local IncidentVelocity = typeof(ImpactVelocity) == "Vector3" and ImpactVelocity or Vector3.new(0, -110, 0)
    local IncidentSpeed = math.clamp(IncidentVelocity.Magnitude, 45, 165)
    local Reflected = IncidentVelocity - SurfaceNormal * (2 * IncidentVelocity:Dot(SurfaceNormal))
    if Reflected.Magnitude <= 0.01 then Reflected = SurfaceNormal else Reflected = Reflected.Unit end
    local Ring = AcquireWorldBeamNode(Anchor)
    Ring.Effect = "RainSplash"
    Ring.IsSplash = true
    Ring.Age = 0
    Ring.Lifetime = 0.22
    Ring.Position = Position + SurfaceNormal * 0.028
    Ring.Velocity = Vector3.new(0, 0, 0)
    Ring.Length = 0.14
    Ring.Phase = math.random() * math.pi * 2
    Ring.Sway = TangentA
    Ring.Frequency = 1
    Ring.SurfaceNormal = SurfaceNormal
    Ring.Core.Segments = 12
    Ring.Glow.Segments = 12
    Ring.Core.CurveSize0, Ring.Core.CurveSize1 = 0.46, -0.46
    Ring.Glow.CurveSize0, Ring.Glow.CurveSize1 = 0.46, -0.46
    Ring.Core.Width0, Ring.Core.Width1 = 0.018, 0.018
    Ring.Glow.Width0, Ring.Glow.Width1 = 0.058, 0.058
    Ring.Core.Color = ColorSequence.new(Color3.fromRGB(218, 240, 255))
    Ring.Glow.Color = ColorSequence.new(Color3.fromRGB(118, 188, 255))
    Ring.Core.Transparency = NumberSequence.new(0.14)
    Ring.Glow.Transparency = NumberSequence.new(0.82)
    Ring.Core.Brightness = 1
    Ring.Glow.Brightness = 0.58
    WorldEffectsState.SplashActive = (WorldEffectsState.SplashActive or 0) + 1
    WorldEffectsState.Active[#WorldEffectsState.Active + 1] = Ring
    local Intensity = math.clamp(tonumber(WorldEffectsState.Intensity) or 70, 5, 250)
    local DropCount = math.clamp(3 + math.floor(Intensity / 72) + math.random(0, 1), 3, 7)
    DropCount = math.min(DropCount, SplashLimit - (WorldEffectsState.SplashActive or 0))
    local SpeedScale = math.clamp((IncidentSpeed / 110) ^ 0.45, 0.72, 1.32)
    for Index = 1, DropCount do
        local Angle = (Index / math.max(DropCount, 1)) * math.pi * 2 + (math.random() - 0.5) * 0.85
        local Radial = TangentA * math.cos(Angle) + TangentB * math.sin(Angle)
        if Radial.Magnitude <= 0.01 then Radial = TangentA else Radial = Radial.Unit end
        local Drop = AcquireWorldBeamNode(Anchor)
        Drop.Effect = "RainSplashDrop"
        Drop.IsSplash = true
        Drop.Age = 0
        Drop.Lifetime = 0.24 + math.random() * 0.24
        Drop.Position = Position + SurfaceNormal * 0.035 + Radial * (math.random() * 0.07)
        Drop.Velocity = Radial * ((4.5 + math.random() * 8.5) * SpeedScale)
            + SurfaceNormal * ((2.8 + math.random() * 6.2) * SpeedScale)
            + Reflected * (0.65 + math.random() * 1.7)
        Drop.Gravity = Vector3.new(0, -(72 + math.random() * 38), 0)
        Drop.Drag = 1.8 + math.random() * 2.1
        Drop.SurfacePoint = Position
        Drop.SurfaceNormal = SurfaceNormal
        Drop.Bounces = 0
        Drop.Length = 0.08 + math.random() * 0.18
        Drop.Phase = math.random() * math.pi * 2
        Drop.Sway = Radial
        Drop.Frequency = 1
        Drop.Core.Segments = 1
        Drop.Glow.Segments = 1
        Drop.Core.CurveSize0, Drop.Core.CurveSize1 = 0, 0
        Drop.Glow.CurveSize0, Drop.Glow.CurveSize1 = 0, 0
        Drop.BaseCoreWidth = 0.018 + math.random() * 0.014
        Drop.BaseGlowWidth = Drop.BaseCoreWidth * 3.1
        Drop.Core.Width0, Drop.Core.Width1 = Drop.BaseCoreWidth, Drop.BaseCoreWidth * 0.18
        Drop.Glow.Width0, Drop.Glow.Width1 = Drop.BaseGlowWidth, Drop.BaseGlowWidth * 0.18
        Drop.Core.Color = ColorSequence.new(Color3.fromRGB(225, 244, 255), Color3.fromRGB(175, 218, 255))
        Drop.Glow.Color = ColorSequence.new(Color3.fromRGB(108, 180, 255), Color3.fromRGB(205, 235, 255))
        Drop.Core.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.05), NumberSequenceKeypoint.new(1, 0.76) })
        Drop.Glow.Transparency = NumberSequence.new(0.84)
        Drop.Core.Brightness = 1.25
        Drop.Glow.Brightness = 0.72
        WorldEffectsState.SplashActive = (WorldEffectsState.SplashActive or 0) + 1
        WorldEffectsState.Active[#WorldEffectsState.Active + 1] = Drop
    end
end

local function UpdateWorldBeamNode(Node, Step, CameraObject, CameraPosition)
    Node.Age += Step
    local LifeAlpha = math.clamp(Node.Age / math.max(Node.Lifetime, 0.01), 0, 1)
    local Sine = math.sin((Node.Phase or 0) + Node.Age * (Node.Frequency or 1))
    local Direction
    if Node.Effect == "RainSplash" then
        Node.Length = 0.14 + LifeAlpha * 1.34
        Direction = typeof(Node.Sway) == "Vector3" and Node.Sway or CameraObject.CFrame.RightVector
        local Curve = 0.30 + LifeAlpha * 0.78
        Node.Core.CurveSize0, Node.Core.CurveSize1 = Curve, -Curve
        Node.Glow.CurveSize0, Node.Glow.CurveSize1 = Curve, -Curve
        Node.Core.Brightness = 1.0 * (1 - LifeAlpha)
        Node.Glow.Brightness = 0.58 * (1 - LifeAlpha)
    elseif Node.Effect == "RainSplashDrop" then
        local Gravity = typeof(Node.Gravity) == "Vector3" and Node.Gravity or Vector3.new(0, -88, 0)
        local DragFactor = math.exp(-(tonumber(Node.Drag) or 2.6) * Step)
        Node.Velocity = (Node.Velocity + Gravity * Step) * DragFactor
        local NextPosition = Node.Position + Node.Velocity * Step
        local SurfacePoint = Node.SurfacePoint
        local SurfaceNormal = Node.SurfaceNormal
        if typeof(SurfacePoint) == "Vector3" and typeof(SurfaceNormal) == "Vector3" and (Node.Bounces or 0) < 1 then
            local OldDistance = (Node.Position - SurfacePoint):Dot(SurfaceNormal)
            local NewDistance = (NextPosition - SurfacePoint):Dot(SurfaceNormal)
            local NormalSpeed = Node.Velocity:Dot(SurfaceNormal)
            if OldDistance > 0.002 and NewDistance <= 0.002 and NormalSpeed < 0 then
                local TangentialVelocity = Node.Velocity - SurfaceNormal * NormalSpeed
                Node.Velocity = TangentialVelocity * 0.46 + SurfaceNormal * (-NormalSpeed) * 0.24
                NextPosition = SurfacePoint + SurfaceNormal * 0.008 + TangentialVelocity * Step * 0.18
                Node.Bounces = (Node.Bounces or 0) + 1
                Node.Length *= 0.72
                Node.Lifetime = math.min(Node.Lifetime, Node.Age + 0.15)
            end
        end
        Node.Position = NextPosition
        Direction = Node.Velocity
        local Fade = math.max(1 - LifeAlpha, 0)
        local BaseCoreWidth = tonumber(Node.BaseCoreWidth) or 0.024
        local BaseGlowWidth = tonumber(Node.BaseGlowWidth) or 0.074
        Node.Core.Width0, Node.Core.Width1 = BaseCoreWidth * (0.36 + Fade * 0.64), BaseCoreWidth * 0.12
        Node.Glow.Width0, Node.Glow.Width1 = BaseGlowWidth * (0.30 + Fade * 0.70), BaseGlowWidth * 0.10
        Node.Core.Brightness = 1.25 * Fade
        Node.Glow.Brightness = 0.72 * Fade
        if Node.Velocity.Magnitude < 1.1 and Node.Age > 0.12 then Node.Lifetime = math.min(Node.Lifetime, Node.Age + 0.05) end
    elseif Node.Effect == "Sakura" then
        Node.Velocity += Vector3.new(0, -0.28, 0) * Step
        Node.Position += (Node.Velocity + Node.Sway * Sine) * Step
        Direction = Node.Velocity + Node.Sway * Sine * 0.72
        local Curve = math.sin((Node.Phase or 0) + Node.Age * 3.4) * 0.32
        Node.Core.CurveSize0, Node.Core.CurveSize1 = Curve, -Curve
        Node.Glow.CurveSize0, Node.Glow.CurveSize1 = Curve, -Curve
    elseif Node.Effect == "Snow" then
        Node.Position += (Node.Velocity + Node.Sway * Sine * 0.55) * Step
        Direction = Node.Velocity + Node.Sway * Sine * 0.38
        local Curve = math.sin((Node.Phase or 0) + Node.Age * 1.8) * 0.10
        Node.Core.CurveSize0, Node.Core.CurveSize1 = Curve, -Curve
        Node.Glow.CurveSize0, Node.Glow.CurveSize1 = Curve, -Curve
    elseif Node.Effect == "Embers" then
        Node.Velocity += Vector3.new(0, 1.35, 0) * Step
        Node.Position += (Node.Velocity + Node.Sway * Sine * 0.42) * Step
        Direction = Node.Velocity + Node.Sway * Sine * 0.35
    elseif Node.Effect == "Fireflies" then
        local Orbit = Node.Sway * Sine + Vector3.new(0, math.cos((Node.Phase or 0) + Node.Age * 1.6) * 0.75, 0)
        Node.Position += (Node.Velocity + Orbit) * Step
        Direction = CameraObject.CFrame.RightVector
        local Flicker = 0.38 + 0.62 * math.abs(math.sin((Node.Phase or 0) + Node.Age * 4.8))
        Node.Core.Brightness = 0.65 + Flicker * 1.1
        Node.Glow.Brightness = 0.35 + Flicker * 0.8
        Node.Core.Width0, Node.Core.Width1 = 0.075 + Flicker * 0.055, 0.035 + Flicker * 0.035
        Node.Glow.Width0, Node.Glow.Width1 = 0.22 + Flicker * 0.16, 0.10 + Flicker * 0.10
    else
        Node.Position += Node.Velocity * Step
        Direction = Node.Velocity
    end
    if Direction.Magnitude <= 0.01 then Direction = Vector3.new(0, -1, 0) else Direction = Direction.Unit end
    Node.A0.Position = Node.Position
    Node.A1.Position = Node.Position - Direction * Node.Length
    if Node.Effect ~= "Fireflies" and Node.Effect ~= "RainSplash" and Node.Effect ~= "RainSplashDrop" then
        local Fade = 1 - math.clamp((LifeAlpha - 0.72) / 0.28, 0, 1)
        Node.Core.Brightness = math.max(0.08, Fade)
        Node.Glow.Brightness = math.max(0.04, Fade * 0.55)
    end
    return LifeAlpha >= 1
end

local function StartWorldEffects()
    DestroyWorldEffects()
    if not WorldEffectsState.Enabled then return end
    local CameraObject = workspace.CurrentCamera
    if not CameraObject then return end
    local Generation = WorldEffectsState.Generation
    local Folder = Instance.new("Folder")
    Folder.Name = "RadiantBeamWeather"
    Folder.Parent = workspace
    local Anchor = Instance.new("Part")
    Anchor.Name = "BeamAnchor"
    Anchor.Anchored = true
    Anchor.CanCollide = false
    Anchor.CanTouch = false
    Anchor.CanQuery = false
    Anchor.CastShadow = false
    Anchor.Transparency = 1
    Anchor.Size = Vector3.new(0.05, 0.05, 0.05)
    Anchor.CFrame = CFrame.new()
    Anchor.Parent = Folder
    WorldEffectsState.Folder = Folder
    WorldEffectsState.Anchor = Anchor
    WorldEffectsState.SpawnAccumulator = 0
    WorldEffectsState.StepAccumulator = 0
    WorldEffectsState.WeatherActive = 0
    WorldEffectsState.SplashActive = 0
    WorldEffectsState.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        if Generation ~= WorldEffectsState.Generation or not WorldEffectsState.Enabled or not Folder.Parent or not Anchor.Parent then return end

        WorldEffectsState.StepAccumulator += math.min(math.max(DeltaTime, 0), 0.1)
        local FixedStep = 1 / math.max(tonumber(WorldEffectsState.UpdateRate) or 30, 15)
        if WorldEffectsState.StepAccumulator < FixedStep then return end

        local Step = math.min(WorldEffectsState.StepAccumulator, FixedStep * 2)
        WorldEffectsState.StepAccumulator = 0

        local CurrentCamera = workspace.CurrentCamera
        if not CurrentCamera then return end
        local CameraPosition = CurrentCamera.CFrame.Position
        local Effect = WorldEffectsState.Effect
        local Intensity = math.clamp(tonumber(WorldEffectsState.Intensity) or 70, 5, 250)

        local Rate = Effect == "Rain" and math.clamp(Intensity * 0.36, 6, 88)
            or Effect == "Snow" and math.clamp(Intensity * 0.16, 3, 40)
            or Effect == "Sakura" and math.clamp(Intensity * 0.10, 2, 26)
            or Effect == "Embers" and math.clamp(Intensity * 0.10, 2, 26)
            or math.clamp(Intensity * 0.045, 1, 12)

        local ActiveLimit = Effect == "Rain" and 72
            or Effect == "Snow" and 64
            or Effect == "Sakura" and 52
            or Effect == "Embers" and 48
            or 36

        WorldEffectsState.SpawnAccumulator += Step * Rate
        local SpawnCount = math.min(math.floor(WorldEffectsState.SpawnAccumulator), 3)
        WorldEffectsState.SpawnAccumulator -= SpawnCount

        for _ = 1, SpawnCount do
            if (WorldEffectsState.WeatherActive or 0) >= ActiveLimit then break end
            SpawnWorldBeam(CurrentCamera)
        end

        local MaximumDistance = math.max((tonumber(WorldEffectsState.Radius) or 65) * 2.4, 150)
        local MaximumDistanceSquared = MaximumDistance * MaximumDistance

        for Index = #WorldEffectsState.Active, 1, -1 do
            local Node = WorldEffectsState.Active[Index]
            local Expired = UpdateWorldBeamNode(Node, Step, CurrentCamera, CameraPosition)

            if not Expired and Node.Effect ~= "RainSplash" and Node.Effect ~= "RainSplashDrop" then
                local Offset = Node.Position - CameraPosition
                if Offset:Dot(Offset) > MaximumDistanceSquared then Expired = true end
            end

            if Expired then
                if Node.Effect == "Rain"
                    and Node.ImpactPosition
                    and (WorldEffectsState.SplashActive or 0) < math.max((WorldEffectsState.SplashLimit or 24) - 3, 0) then
                    SpawnWorldBeamSplash(Node.ImpactPosition, Node.ImpactNormal, Node.Velocity, CurrentCamera)
                end

                local LastIndex = #WorldEffectsState.Active
                WorldEffectsState.Active[Index] = WorldEffectsState.Active[LastIndex]
                WorldEffectsState.Active[LastIndex] = nil
                ReleaseWorldBeamNode(Node)
            end
        end
    end)
end

local function SpawnHitParticles(HitPosition, TargetCharacterValue)
    if not HitParticleState.Enabled or typeof(HitPosition) ~= "Vector3" then return end
    local Anchor = Instance.new("Part")
    Anchor.Name = "RadiantHitVFX"
    Anchor.Anchored = true
    Anchor.CanCollide = false
    Anchor.CanTouch = false
    Anchor.CanQuery = false
    Anchor.Transparency = 1
    Anchor.Size = Vector3.new(0.1, 0.1, 0.1)
    Anchor.Position = HitPosition
    Anchor.Parent = workspace
    local Attachment = Instance.new("Attachment")
    Attachment.Parent = Anchor
    local Emitter = Instance.new("ParticleEmitter")
    Emitter.Enabled = false
    Emitter.Rate = 0
    Emitter.LightEmission = 0.7
    Emitter.Color = ColorSequence.new(HitParticleState.Color)
    Emitter.Lifetime = NumberRange.new(HitParticleState.Lifetime * 0.55, HitParticleState.Lifetime)
    Emitter.Speed = NumberRange.new(7, 18)
    Emitter.SpreadAngle = Vector2.new(180, 180)
    Emitter.Drag = 4
    Emitter.Acceleration = Vector3.new(0, -18, 0)
    Emitter.Rotation = NumberRange.new(0, 360)
    Emitter.RotSpeed = NumberRange.new(-180, 180)
    Emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, HitParticleState.Size), NumberSequenceKeypoint.new(0.55, HitParticleState.Size * 0.55), NumberSequenceKeypoint.new(1, 0) })
    Emitter.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.7, 0.25), NumberSequenceKeypoint.new(1, 1) })
    if HitParticleState.Style == "Blood Mist" then
        Emitter.Texture = "rbxassetid://243098098"
        Emitter.Speed = NumberRange.new(3, 9)
        Emitter.Drag = 7
        Emitter.Color = ColorSequence.new(Color3.fromRGB(170, 20, 30), HitParticleState.Color)
        Emitter.Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, HitParticleState.Size * 1.7), NumberSequenceKeypoint.new(1, 0) })
    elseif HitParticleState.Style == "Energy" then
        Emitter.Texture = "rbxassetid://296874871"
        Emitter.Speed = NumberRange.new(9, 22)
        Emitter.LightEmission = 1
    elseif HitParticleState.Style == "Petals" then
        Emitter.Texture = WorldEffectTextures.Sakura
        Emitter.Speed = NumberRange.new(4, 11)
        Emitter.Drag = 2
    else
        Emitter.Texture = "rbxassetid://1266170131"
    end
    Emitter.Parent = Attachment
    Emitter:Emit(math.clamp(math.floor(HitParticleState.Count), 1, 80))
    task.delay(math.max(HitParticleState.Lifetime + 0.35, 0.5), function() if Anchor.Parent then Anchor:Destroy() end end)
end

local RespawnSafetyState = { Generation = 0, RemovingConnection = nil, AddedConnection = nil, DiedConnection = nil, Cleaning = false, Suspended = false, CurrentCharacter = nil, Preserved = nil, RespawnRequestedFor = nil, LastRespawnRequest = 0 }

local function ClearRespawnTransientState(Character)
    Character = Character or RespawnSafetyState.CurrentCharacter or LocalPlayer.Character
    if RespawnSafetyState.Suspended then return end
    RespawnSafetyState.Suspended = true
    RespawnSafetyState.Cleaning = true
    RespawnSafetyState.Generation += 1
    local Generation = RespawnSafetyState.Generation
    RespawnSafetyState.CurrentCharacter = Character
    RespawnSafetyState.Preserved = {
        Rage = RageBotEnabled == true, Arms = ArmsChamsEnabled == true, Weapon = WeaponChamsEnabled == true, World = WorldEffectsState.Enabled == true,
        Fly = FlyEnabled == true, Noclip = NoclipEnabled == true, Invis = InvisibilityEnabled == true, Stamina = InfStaminaEnabled == true, NoFall = NoFallDamageEnabled == true,
        Bunny = BunnyHopEnabled == true, Strafe = AutoStrafeEnabled == true, Air = AirControlEnabled == true
    }
    pcall(function() if RageBotEnabled and RageBotAPI and type(RageBotAPI.Disable) == "function" then RageBotAPI.Disable() end end)
    pcall(function() if FlyEnabled and type(FlyDisable) == "function" then FlyDisable() end end)
    pcall(function() if NoclipEnabled and type(NoclipDisable) == "function" then NoclipDisable() end end)
    pcall(function() if InvisibilityEnabled and type(InvisibilityDisable) == "function" then InvisibilityDisable() end end)
    pcall(function() if InfStaminaEnabled and type(InfStaminaDisable) == "function" then InfStaminaDisable() end end)
    pcall(function() if NoFallDamageEnabled and type(NoFallDamageDisable) == "function" then NoFallDamageDisable() end end)
    pcall(function() if type(DisableMovementAssist) == "function" then DisableMovementAssist() end end)
    pcall(function() if WeaponChamsEnabled and type(WeaponChamsDisable) == "function" then WeaponChamsDisable() else RestoreWeaponChams() end end)
    pcall(function() if ArmsChamsEnabled and type(ArmsChamsDisable) == "function" then ArmsChamsDisable() else RestoreArmsChams() end end)
    pcall(function() DestroyWorldEffects() end)
    pcall(function() if RadiantMuzzleMotorEngine and type(RadiantMuzzleMotorEngine.Restore) == "function" then RadiantMuzzleMotorEngine.Restore() end end)
    pcall(function() ClearBulletTracers() end)
    pcall(function() DestroyHitFeedbackRuntime() end)
    pcall(function() if WeaponChamsSettings then WeaponChamsSettings.ActiveTool = nil; WeaponChamsSettings.ActiveViewModel = nil end end)
    pcall(function() RageBotRuntime.PendingShot = nil; RageBotRuntime.Target = nil end)
    pcall(function()
        RageShotState.Sending = false
        RageShotState.NextServerShot = 0
        RageShotState.LastTool = nil
        if type(RageShotState.ClearPending) == "function" then RageShotState.ClearPending() end
        RageBotAPI._ReportedShots = {}
    end)
    pcall(function() RadiantAimEngine.MagicCache = {}; RadiantAimEngine.WallbangCache = {}; RadiantAimEngine._ActiveTool = nil end)
    pcall(function() ResolverState.History = setmetatable({}, { __mode = "k" }); ResolverState.PoseHistory = setmetatable({}, { __mode = "k" }); ResolverState.SkeletonCache = setmetatable({}, { __mode = "k" }) end)
    task.defer(function() if Generation == RespawnSafetyState.Generation then RespawnSafetyState.Cleaning = false end end)
end

local function BindRespawnSafety(Character)
    RespawnSafetyState.CurrentCharacter = Character
    RespawnSafetyState.RespawnRequestedFor = nil
    if RespawnSafetyState.DiedConnection then pcall(function() RespawnSafetyState.DiedConnection:Disconnect() end) end
    RespawnSafetyState.DiedConnection = nil
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then RespawnSafetyState.DiedConnection = Humanoid.Died:Connect(function() ClearRespawnTransientState(Character) end) end
end

local function SpawnGhostVisual(HitPosition, TargetCharacterValue)
    SpawnHitParticles(HitPosition, TargetCharacterValue)
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

QueueConfirmedDamage = function(Player, Character, Damage, IsHeadshot, PartName, Shot)
    if not Player or not Character or not Character.Parent or not Damage or Damage <= 0 then return end
    local TargetPart = PartName and Character:FindFirstChild(PartName, true) or IsHeadshot and Character:FindFirstChild("Head", true) or
        Character:FindFirstChild("HumanoidRootPart", true) or Character.PrimaryPart or Character:FindFirstChildWhichIsA("BasePart", true)
    if not TargetPart or not TargetPart:IsA("BasePart") then return end
    if type(HitFeedbackRuntimeState.SpawnConfirmedTracer) == "function" then HitFeedbackRuntimeState.SpawnConfirmedTracer(Shot, TargetPart) end
    SpawnConfirmedHitmarker(IsHeadshot)
    PlayConfirmedHitSound()
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
    Shot.ConfirmedAt = os.clock()
    if type(RageShotState.ConfirmDamage) == "function" then
        RageShotState.ConfirmDamage(Shot.Player, Buffered.Damage)
    end
    QueueConfirmedDamage(Shot.Player, Buffered.Character, Buffered.Damage, Shot.PartName == "Head", Shot.PartName, Shot)
    return true
end

local function FindRecentToolShot(Tool)
    local CurrentTime = os.clock()
    for Index = #AttackConfirmationState.Shots, 1, -1 do
        local Shot = AttackConfirmationState.Shots[Index]
        if Shot and Shot.VerifiedFire and Shot.Tool == Tool and not Shot.DamageConfirmed and CurrentTime - (Shot.Time or 0) <= AttackConfirmationState.DamageWindow then return Shot end
    end
    return nil
end

local function HandleConfirmedHitSignal(Tool, ...)
    local Shot = FindRecentToolShot(Tool)
    if not Shot then return end
    local TargetCharacter, TargetPart = ResolveHitSignalTarget(...)
    if not TargetCharacter or not TargetPart then
        local MouseTarget = Mouse and Mouse.Target
        TargetPart = MouseTarget
        TargetCharacter = GetHumanoidCharacterFromPart(MouseTarget)
    end
    if TargetCharacter and TargetPart then AttachAttackTarget(Shot, TargetCharacter, TargetPart) end
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
    local Connections = {}
    HitVisualToolConnections[Tool] = Connections
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
        if not IsShotTrackingEnabled() or Damage <= 0 then return end
        local Confirmation = FindTargetAwareAttackConfirmation(Player, Character)
        if not Confirmation then
            BufferUnconfirmedDamage(Player, Character, Damage)
            return
        end
        Confirmation.DamageConfirmed = true
        Confirmation.ConfirmedAt = os.clock()
        if type(RageShotState.ConfirmDamage) == "function" then
            RageShotState.ConfirmDamage(Player, Damage)
        end
        QueueConfirmedDamage(Player, Character, Damage, Confirmation.PartName == "Head", Confirmation.PartName, Confirmation)
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
    local ShotHookState = getgenv().RadiantBulletTracerShotHook
    if type(ShotHookState) == "table" then ShotHookState.Enabled = false end
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
        if Humanoid and Humanoid.Health <= 0 then
            if AutoRespawnEnabled and type(RequestCharacterRespawn) == "function" then RequestCharacterRespawn() end
            return
        end
        if RootPart then RootPart.CFrame = CFrame.new(Location.Position) end
    end)
end

function SafeLocationController.DisableAll(Self)
    for Name in pairs(Self.Locations) do Self:SetEnabled(Name, false) end
end

local function GetDrawingTextFont()
    if Drawing and Drawing.Fonts then
        if Drawing.Fonts.UI ~= nil then return Drawing.Fonts.UI end
        if Drawing.Fonts.System ~= nil then return Drawing.Fonts.System end
        if Drawing.Fonts.Plex ~= nil then return Drawing.Fonts.Plex end
    end
    return 0
end

local function CreateDrawing(DrawingType, Properties)
    if not Drawing then return nil end
    local Constructor = Drawing.new or Drawing.New
    if type(Constructor) ~= "function" then return nil end
    local Success, Object = pcall(Constructor, DrawingType)
    if not Success or not Object then
        Success, Object = pcall(function() return Constructor(Drawing, DrawingType) end)
    end
    if not Success or not Object then return nil end
    for Property, Value in pairs(Properties or {}) do
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
    if Data.ChamsFolder and Data.ChamsFolder.Parent then Data.ChamsFolder:Destroy() end
    Data.ChamsFolder = nil
    Data.ChamsParts = nil
    if Data.Highlight and Data.Highlight.Parent then Data.Highlight:Destroy() end
    if Data.Glow and Data.Glow.Parent then Data.Glow:Destroy() end
    Data.Highlight = nil
    Data.Glow = nil
    Data.ChamsCharacter = nil

    if VisualState.Player.Chams.Enabled then
        task.defer(function()
            if Data.Character == Character then
                ApplyPlayerChamData(Data)
            end
        end)
    end
end

local function CreatePlayerVisual(Player, WithDrawings)
    local Data = VisualState.Player.Objects[Player]
    if not Data then
        Data = { Player = Player, Character = nil, Humanoid = nil, Root = nil, Head = nil, ToolName = nil, NextToolScan = 0, Highlight = nil, Glow = nil, ChamsCharacter = nil, ChamsFolder = nil, ChamsParts = nil, CharacterAddedConnection = nil,
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
    DestroyChams(Data)
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

    return nil
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

function RestoreLegacyPlayerChamParts(Data)
    if not Data then return end

    if Data.ChamsParts then
        for Source, PartData in pairs(Data.ChamsParts) do
            if Source
                and Source.Parent
                and type(PartData) == "table"
                and PartData.OriginalLocalTransparencyModifier
                    ~= nil
            then
                pcall(function()
                    Source.LocalTransparencyModifier =
                        PartData.OriginalLocalTransparencyModifier
                end)
            end

            if type(PartData) == "table" then
                for Key, Object in pairs(PartData) do
                    if typeof(Object) == "Instance" then
                        pcall(function()
                            Object:Destroy()
                        end)
                    end
                    PartData[Key] = nil
                end
            end
        end
    end

    if Data.ChamsFolder then
        pcall(function()
            Data.ChamsFolder:Destroy()
        end)
    end

    Data.ChamsFolder = nil
    Data.ChamsFillModel = nil
    Data.ChamsGlowModel = nil
    Data.ChamsParts = nil
end

function DestroyChams(Data)
    if not Data then return end

    RestoreLegacyPlayerChamParts(Data)

    if Data.Highlight then
        pcall(function()
            Data.Highlight:Destroy()
        end)
    end

    if Data.Glow then
        pcall(function()
            Data.Glow:Destroy()
        end)
    end

    Data.Highlight = nil
    Data.Glow = nil
    Data.ChamsCharacter = nil
end

local function EnsurePlayerHighlight(
    Current,
    Parent,
    Name
)
    if Current
        and Current.Parent == Parent
        and Current:IsA("Highlight")
    then
        return Current
    end

    if Current then
        pcall(function()
            Current:Destroy()
        end)
    end

    local Highlight = Instance.new("Highlight")
    Highlight.Name = Name
    Highlight.Enabled = false
    Highlight.Parent = Parent

    return Highlight
end

function ApplyPlayerChamData(Data)
    if not Data then return end

    local Settings = VisualState.Player.Chams
    local Character = Data.Character
    local Humanoid = Data.Humanoid
    local PlayerObject = Data.Player

    local TeamBlocked =
        VisualState.Player.TeamCheck
        and PlayerObject
        and PlayerObject.Team ~= nil
        and PlayerObject.Team == LocalPlayer.Team

    if not Settings.Enabled
        or not Character
        or not Character.Parent
        or not Humanoid
        or not Humanoid.Parent
        or Humanoid.Health <= 0
        or TeamBlocked
    then
        DestroyChams(Data)
        return
    end

    if Data.ChamsCharacter ~= Character then
        DestroyChams(Data)
        Data.ChamsCharacter = Character
    else
        RestoreLegacyPlayerChamParts(Data)
    end

    local MainEnabled =
        Settings.FillEnabled
        or Settings.OutlineEnabled

    if MainEnabled then
        Data.Highlight = EnsurePlayerHighlight(
            Data.Highlight,
            Character,
            "RadiantChams"
        )

        local Highlight = Data.Highlight
        Highlight.Adornee = Character
        Highlight.DepthMode = Settings.ThroughWalls
            and Enum.HighlightDepthMode.AlwaysOnTop
            or Enum.HighlightDepthMode.Occluded
        Highlight.FillColor = Settings.FillColor
        Highlight.FillTransparency =
            Settings.FillEnabled
            and math.clamp(
                tonumber(Settings.FillTransparency)
                    or 0.42,
                0,
                1
            )
            or 1
        Highlight.OutlineColor =
            Settings.OutlineColor
        Highlight.OutlineTransparency =
            Settings.OutlineEnabled
            and math.clamp(
                tonumber(Settings.OutlineTransparency)
                    or 0.08,
                0,
                1
            )
            or 1
        Highlight.Enabled = true
    elseif Data.Highlight then
        Data.Highlight:Destroy()
        Data.Highlight = nil
    end

    if Settings.GlowEnabled then
        Data.Glow = EnsurePlayerHighlight(
            Data.Glow,
            Character,
            "RadiantChamsGlow"
        )

        local Glow = Data.Glow
        Glow.Adornee = Character
        Glow.DepthMode =
            Enum.HighlightDepthMode.AlwaysOnTop
        Glow.FillColor = Settings.GlowColor
        Glow.FillTransparency = math.clamp(
            tonumber(Settings.GlowTransparency)
                or 0.62,
            0.35,
            1
        )
        Glow.OutlineColor = Settings.GlowColor
        Glow.OutlineTransparency = 1
        Glow.Enabled = true
    elseif Data.Glow then
        Data.Glow:Destroy()
        Data.Glow = nil
    end
end

function UpdatePlayerChams()
    local Settings = VisualState.Player.Chams

    for _, Data in ipairs(
        VisualState.Player.List
    ) do
        if Settings.Enabled then
            ApplyPlayerChamData(Data)
        else
            DestroyChams(Data)
        end
    end
end

function SyncPlayerChams()
    UpdatePlayerChams()
end


local function SaveWorldOriginal()
    if VisualState.World.Original then return end

    local Atmospheres = {}
    for _, Object in ipairs(Lighting:GetChildren()) do
        if Object:IsA("Atmosphere") and Object ~= VisualState.World.Atmosphere then
            Atmospheres[#Atmospheres + 1] = {
                Object = Object,
                Density = Object.Density,
                Offset = Object.Offset,
                Color = Object.Color,
                Decay = Object.Decay,
                Glare = Object.Glare,
                Haze = Object.Haze
            }
        end
    end

    VisualState.World.Original = {
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
        Brightness = Lighting.Brightness,
        ClockTime = Lighting.ClockTime,
        FogColor = Lighting.FogColor,
        FogStart = Lighting.FogStart,
        FogEnd = Lighting.FogEnd,
        Atmospheres = Atmospheres
    }
end

local function SetWorldProperty(Object, Property, Value)
    if Object[Property] ~= Value then Object[Property] = Value end
end


function RestoreRadiantAtmospheres()
    local Atmosphere = VisualState.World.Atmosphere
    if Atmosphere and Atmosphere.Parent then Atmosphere:Destroy() end
    VisualState.World.Atmosphere = nil
    VisualState.World.AtmospheresSuppressed = false

    local Original = VisualState.World.Original
    local Entries = Original and Original.Atmospheres
    if type(Entries) ~= "table" then return end

    for _, Entry in ipairs(Entries) do
        local Object = Entry.Object
        if Object and Object.Parent then
            pcall(function()
                Object.Density = Entry.Density
                Object.Offset = Entry.Offset
                Object.Color = Entry.Color
                Object.Decay = Entry.Decay
                Object.Glare = Entry.Glare
                Object.Haze = Entry.Haze
            end)
        end
    end
end

function EnsureRadiantAtmosphere()
    if not VisualState.World.FogEnabled then
        RestoreRadiantAtmospheres()
        return
    end

    local Original = VisualState.World.Original
    local Entries = Original and Original.Atmospheres
    if not VisualState.World.AtmospheresSuppressed and type(Entries) == "table" then
        for _, Entry in ipairs(Entries) do
            local Object = Entry.Object
            if Object and Object.Parent and Object ~= VisualState.World.Atmosphere then
                SetWorldProperty(Object, "Density", 0)
                SetWorldProperty(Object, "Haze", 0)
                SetWorldProperty(Object, "Glare", 0)
            end
        end
        VisualState.World.AtmospheresSuppressed = true
    end

    local Atmosphere = VisualState.World.Atmosphere
    if not Atmosphere or not Atmosphere.Parent then
        Atmosphere = Instance.new("Atmosphere")
        Atmosphere.Name = "RadiantFogAtmosphere"
        Atmosphere.Parent = Lighting
        VisualState.World.Atmosphere = Atmosphere
    end

    SetWorldProperty(Atmosphere, "Density", math.clamp(tonumber(VisualState.World.FogDensity) or 0.42, 0, 1))
    SetWorldProperty(Atmosphere, "Offset", math.clamp(tonumber(VisualState.World.FogOffset) or 0, -1, 1))
    SetWorldProperty(Atmosphere, "Color", VisualState.World.FogColor)
    SetWorldProperty(Atmosphere, "Decay", VisualState.World.FogDecay)
    SetWorldProperty(Atmosphere, "Glare", math.clamp(tonumber(VisualState.World.FogGlare) or 0.12, 0, 10))
    SetWorldProperty(Atmosphere, "Haze", math.clamp(tonumber(VisualState.World.FogHaze) or 2.4, 0, 10))
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
    EnsureRadiantAtmosphere()
end

local function ApplyWorldLightingCore()
    if not VisualState.World.Enabled then return end

    SetWorldProperty(
        Lighting,
        "Ambient",
        VisualState.World.Ambient
    )
    SetWorldProperty(
        Lighting,
        "OutdoorAmbient",
        VisualState.World.OutdoorAmbient
    )
    SetWorldProperty(
        Lighting,
        "Brightness",
        VisualState.World.Brightness
    )
    SetWorldProperty(
        Lighting,
        "ClockTime",
        VisualState.World.ClockTime
    )

    if VisualState.World.FogEnabled then
        local FogDistance = math.max(
            tonumber(VisualState.World.FogDistance) or 900,
            25
        )
        local FogStart = math.clamp(
            tonumber(VisualState.World.FogStart) or 20,
            0,
            math.max(FogDistance - 1, 0)
        )

        SetWorldProperty(
            Lighting,
            "FogColor",
            VisualState.World.FogColor
        )
        SetWorldProperty(
            Lighting,
            "FogStart",
            FogStart
        )
        SetWorldProperty(
            Lighting,
            "FogEnd",
            FogDistance
        )
    else
        SetWorldProperty(Lighting, "FogStart", 0)
        SetWorldProperty(Lighting, "FogEnd", 1000000)
    end
end

local function ApplyWorldVisuals()
    if not VisualState.World.Enabled
        or VisualState.World.Applying
    then
        return
    end

    VisualState.World.Applying = true

    local Success = pcall(function()
        SaveWorldOriginal()
        ApplyWorldLightingCore()
        EnsureWorldEffects()
        VisualState.World.Dirty = false
    end)

    VisualState.World.Applying = false
    return Success
end

local WorldVisualApplyGeneration = 0

local function QueueWorldVisualApply()
    if not VisualState.World.Enabled then return end

    VisualState.World.Dirty = true
    WorldVisualApplyGeneration += 1

    local Generation = WorldVisualApplyGeneration

    task.delay(0.03, function()
        if Generation ~= WorldVisualApplyGeneration
            or not VisualState.World.Enabled
        then
            return
        end

        ApplyWorldVisuals()
    end)
end

local function StartWorldOverride()
    if FullBrightEnabled
        and type(FullBrightDisable) == "function"
    then
        pcall(FullBrightDisable)
    end

    SaveWorldOriginal()

    pcall(function()
        RunService:UnbindFromRenderStep(
            VisualState.World.RenderStepName
        )
    end)

    if VisualState.World.Connection then
        pcall(function()
            VisualState.World.Connection:Disconnect()
        end)
        VisualState.World.Connection = nil
    end

    VisualState.World.Accumulator = 0
    VisualState.World.Bound = true
    VisualState.World.Dirty = true

    ApplyWorldVisuals()

    RunService:BindToRenderStep(
        VisualState.World.RenderStepName,
        Enum.RenderPriority.Last.Value + 10,
        function()
            if not VisualState.World.Enabled then
                return
            end

            ApplyWorldLightingCore()

            if VisualState.World.Dirty then
                ApplyWorldVisuals()
            end
        end
    )
end

local function RestoreWorldVisuals()
    pcall(function() RunService:UnbindFromRenderStep(VisualState.World.RenderStepName) end)
    if VisualState.World.Connection then
        pcall(function() VisualState.World.Connection:Disconnect() end)
        VisualState.World.Connection = nil
    end
    VisualState.World.Accumulator = 0
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
    RestoreRadiantAtmospheres()
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
    VisualState.World.Dirty = false
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
    if VisualState.ChamsRenderConnection then
        VisualState.ChamsRenderConnection:Disconnect()
        VisualState.ChamsRenderConnection = nil
    end
    if VisualState.Connection then return end
    VisualState.Connection = RunService.Heartbeat:Connect(function(DeltaTime)
        DeltaTime = math.clamp(DeltaTime, 0, 0.05)
        VisualState.CacheClock = VisualState.CacheClock + DeltaTime
        if VisualState.CacheClock >= 0.50 then
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
        VisualState.ChamsClock =
            VisualState.ChamsClock + DeltaTime

        if VisualState.ChamsClock >= 1 then
            VisualState.ChamsClock = 0

            if VisualState.Player.Chams.Enabled then
                UpdatePlayerChams()
            end
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
    if VisualState.ChamsRenderConnection then
        VisualState.ChamsRenderConnection:Disconnect()
        VisualState.ChamsRenderConnection = nil
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

local function GetMovementAssistInput(HumanoidObject)
    local CameraObject = GetCamera()
    if not CameraObject then return Vector3.new(), Vector3.new(), Vector3.new(), 0, 0 end

    local Forward = Vector3.new(CameraObject.CFrame.LookVector.X, 0, CameraObject.CFrame.LookVector.Z)
    local Right = Vector3.new(CameraObject.CFrame.RightVector.X, 0, CameraObject.CFrame.RightVector.Z)
    if Forward.Magnitude > 0.001 then Forward = Forward.Unit end
    if Right.Magnitude > 0.001 then Right = Right.Unit end

    local ForwardMove = 0
    local SideMove = 0
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then ForwardMove = ForwardMove + 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then ForwardMove = ForwardMove - 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then SideMove = SideMove + 1 end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then SideMove = SideMove - 1 end

    local Direction = Forward * ForwardMove + Right * SideMove
    if Direction.Magnitude <= 0.001 and HumanoidObject then
        local MoveDirection = HumanoidObject.MoveDirection
        if typeof(MoveDirection) == "Vector3" then
            Direction = Vector3.new(MoveDirection.X, 0, MoveDirection.Z)
        end
    end

    return Direction.Magnitude > 0.001 and Direction.Unit or Vector3.new(), Forward, Right, ForwardMove, SideMove
end

local function IsMovementAssistGrounded(HumanoidObject)
    if not HumanoidObject or HumanoidObject.FloorMaterial == Enum.Material.Air then return false end
    local State = HumanoidObject:GetState()
    return State ~= Enum.HumanoidStateType.Freefall and State ~= Enum.HumanoidStateType.Jumping and State ~= Enum.HumanoidStateType.FallingDown
end

local function UpdateMovementAssist(DeltaTime)
    if FlyEnabled or InvisibilityEnabled or S and S.Freecam and S.Freecam.Enabled then return end

    local CharacterObject = LocalPlayer.Character
    local HumanoidObject = CharacterObject and CharacterObject:FindFirstChildOfClass("Humanoid")
    local RootPart = CharacterObject and CharacterObject:FindFirstChild("HumanoidRootPart")
    if not HumanoidObject or not RootPart or HumanoidObject.Health <= 0 then return end

    local State = HumanoidObject:GetState()
    if State == Enum.HumanoidStateType.Dead or State == Enum.HumanoidStateType.Seated or State == Enum.HumanoidStateType.Swimming or State == Enum.HumanoidStateType.Climbing then return end

    local RawDelta = math.clamp(tonumber(DeltaTime) or 0, 1 / 300, 0.05)
    local TickInterval = math.clamp(tonumber(MovementAssistSettings.TickInterval) or 1 / 64, 1 / 120, 1 / 30)
    MovementAssistSettings.TickAccumulator = (tonumber(MovementAssistSettings.TickAccumulator) or 0) + RawDelta
    if MovementAssistSettings.TickAccumulator < TickInterval then return end

    local FrameTime = math.min(MovementAssistSettings.TickAccumulator, TickInterval * 2)
    MovementAssistSettings.TickAccumulator = MovementAssistSettings.TickAccumulator % TickInterval
    MovementAssistSettings.TickIndex = (tonumber(MovementAssistSettings.TickIndex) or 0) + 1

    local InputDirection, CameraForward = GetMovementAssistInput(HumanoidObject)
    local Grounded = IsMovementAssistGrounded(HumanoidObject)
    local CurrentTime = os.clock()
    local SpaceHeld = UserInputService:IsKeyDown(Enum.KeyCode.Space)
    local Velocity = RootPart.AssemblyLinearVelocity
    local Horizontal = Vector3.new(Velocity.X, 0, Velocity.Z)
    local CurrentSpeed = Horizontal.Magnitude

    if Grounded then
        MovementAssistSettings.GroundTicks = (tonumber(MovementAssistSettings.GroundTicks) or 0) + 1
        MovementAssistSettings.AirTicks = 0
        MovementAssistSettings.TakeoffSpeed = CurrentSpeed
    else
        MovementAssistSettings.AirTicks = (tonumber(MovementAssistSettings.AirTicks) or 0) + 1
        MovementAssistSettings.GroundTicks = 0
        MovementAssistSettings.JumpArmed = true
        if MovementAssistSettings.WasGrounded then
            MovementAssistSettings.TakeoffSpeed = math.max(CurrentSpeed, HumanoidObject.WalkSpeed)
        end
    end

    if not SpaceHeld then MovementAssistSettings.JumpArmed = true end

    local TickGap = MovementAssistSettings.TickIndex - (tonumber(MovementAssistSettings.LastJumpTick) or -1000)
    local StableLanding = Grounded and (tonumber(MovementAssistSettings.GroundTicks) or 0) >= 2
    local JumpReady = CurrentTime - (tonumber(MovementAssistSettings.LastJump) or 0) >= math.max(tonumber(MovementAssistSettings.JumpCooldown) or 0.1, TickInterval * 5)
    if BunnyHopEnabled and SpaceHeld and StableLanding and MovementAssistSettings.JumpArmed and JumpReady and TickGap >= 5 then
        MovementAssistSettings.LastJump = CurrentTime
        MovementAssistSettings.LastJumpTick = MovementAssistSettings.TickIndex
        MovementAssistSettings.JumpArmed = false
        MovementAssistSettings.GroundTicks = 0
        HumanoidObject.Jump = true
        HumanoidObject:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    MovementAssistSettings.WasGrounded = Grounded

    local CameraObject = GetCamera()
    local DeltaYaw = 0
    if CameraObject then
        local Look = CameraObject.CFrame.LookVector
        local Yaw = math.atan2(-Look.X, -Look.Z)
        local LastYaw = MovementAssistSettings.LastYaw
        MovementAssistSettings.LastYaw = Yaw
        if LastYaw then DeltaYaw = math.atan2(math.sin(Yaw - LastYaw), math.cos(Yaw - LastYaw)) end
    end

    if Grounded or not AutoStrafeEnabled and not AirControlEnabled then return end

    local Strength = math.clamp(tonumber(MovementAssistSettings.StrafeStrength) or 0.7, 0, 1)
    local Control = math.clamp(tonumber(MovementAssistSettings.AirControlStrength) or 0.5, 0, 1)
    local WalkSpeed = math.max(tonumber(HumanoidObject.WalkSpeed) or 16, 1)
    local UserCap = math.max(tonumber(MovementAssistSettings.MaxAirSpeed) or 32, WalkSpeed)
    local SafeCap = math.min(UserCap, WalkSpeed * 2.25)
    local WishDirection = InputDirection

    if WishDirection.Magnitude <= 0.001 and AutoStrafeEnabled then
        local BaseDirection = CurrentSpeed > 0.05 and Horizontal.Unit or CameraForward
        if math.abs(DeltaYaw) > 0.00002 then
            local Side = DeltaYaw > 0 and 1 or -1
            local Lateral = Vector3.new(-BaseDirection.Z, 0, BaseDirection.X) * Side
            local TurnAmount = math.clamp(math.abs(DeltaYaw) * 80, 0.2, 1)
            WishDirection = BaseDirection * (0.72 - TurnAmount * 0.32) + Lateral * (0.28 + TurnAmount * 0.72)
        else
            WishDirection = BaseDirection
        end
    end

    if WishDirection.Magnitude <= 0.001 then return end
    WishDirection = WishDirection.Unit
    MovementAssistSettings.LastWishDirection = WishDirection

    local NewHorizontal = Horizontal
    if AirControlEnabled and InputDirection.Magnitude > 0.001 then
        local PreserveSpeed = math.clamp(math.max(CurrentSpeed, WalkSpeed), WalkSpeed, SafeCap)
        local DesiredHorizontal = WishDirection * PreserveSpeed
        local TurnRate = 2.5 + Control * 11.5
        local TurnAlpha = 1 - math.exp(-TurnRate * FrameTime)
        NewHorizontal = Horizontal:Lerp(DesiredHorizontal, math.clamp(TurnAlpha, 0, 0.42 + Control * 0.36))
    end

    if AutoStrafeEnabled then
        local AirAcceleration = WalkSpeed * (3.5 + Strength * 8.5)
        local CurrentAlongWish = NewHorizontal:Dot(WishDirection)
        local AddSpeed = SafeCap - CurrentAlongWish
        if AddSpeed > 0 then
            local AccelSpeed = math.min(AddSpeed, AirAcceleration * FrameTime)
            NewHorizontal = NewHorizontal + WishDirection * AccelSpeed
        end
    elseif AirControlEnabled and NewHorizontal.Magnitude < WalkSpeed then
        NewHorizontal = NewHorizontal + WishDirection * math.min(WalkSpeed - NewHorizontal.Magnitude, WalkSpeed * Control * FrameTime * 3)
    end

    local NewSpeed = NewHorizontal.Magnitude
    if NewSpeed > SafeCap then NewHorizontal = NewHorizontal.Unit * SafeCap end

    RootPart.AssemblyLinearVelocity = Vector3.new(NewHorizontal.X, Velocity.Y, NewHorizontal.Z)
    if InputDirection.Magnitude > 0.001 then HumanoidObject:Move(InputDirection, false) end
end

function UpdateMovementAssistConnection()
    local ShouldRun = AutoStrafeEnabled or BunnyHopEnabled or AirControlEnabled
    if ShouldRun and not MovementAssistConnection then
        MovementAssistConnection = (RunService.PreSimulation or RunService.Heartbeat):Connect(UpdateMovementAssist)
    elseif not ShouldRun and MovementAssistConnection then
        MovementAssistConnection:Disconnect()
        MovementAssistConnection = nil
        MovementAssistSettings.LastJump = 0
        MovementAssistSettings.LastJumpTick = -1000
        MovementAssistSettings.TickAccumulator = 0
        MovementAssistSettings.TickIndex = 0
        MovementAssistSettings.GroundTicks = 0
        MovementAssistSettings.AirTicks = 0
        MovementAssistSettings.JumpArmed = true
        MovementAssistSettings.LastYaw = nil
    end
end

function DisableMovementAssist()
    AutoStrafeEnabled = false
    BunnyHopEnabled = false
    AirControlEnabled = false
    if MovementAssistConnection then
        MovementAssistConnection:Disconnect()
        MovementAssistConnection = nil
    end
    MovementAssistSettings.LastJump = 0
    MovementAssistSettings.LastJumpTick = -1000
    MovementAssistSettings.TickAccumulator = 0
    MovementAssistSettings.TickIndex = 0
    MovementAssistSettings.GroundTicks = 0
    MovementAssistSettings.AirTicks = 0
    MovementAssistSettings.JumpArmed = true
    MovementAssistSettings.LastYaw = nil
end

function GetFlyInputVelocity(CameraObject, Speed, IncludeVertical)
    local Velocity = Vector3.new(0, 0, 0)

    if UserInputService:IsKeyDown(Enum.KeyCode.W) then
        Velocity += CameraObject.CFrame.LookVector * Speed
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then
        Velocity -= CameraObject.CFrame.LookVector * Speed
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then
        Velocity -= CameraObject.CFrame.RightVector * Speed
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then
        Velocity += CameraObject.CFrame.RightVector * Speed
    end

    if IncludeVertical then
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Velocity += Vector3.new(0, Speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            Velocity -= Vector3.new(0, Speed, 0)
        end
    end

    if Velocity.Magnitude > Speed then
        Velocity = Velocity.Unit * Speed
    end

    return Velocity
end

function FlyEnable()
    if FlyEnabled then return end

    FlyEnabled = true

    local Events = ReplicatedStorage:FindFirstChild("Events")
    local RagdollRemote = Events and Events:FindFirstChild("__RZDONL")

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end

        local Character = LocalPlayer.Character
        local RootPart = Character
            and Character:FindFirstChild("HumanoidRootPart")
        local CameraObject = GetCamera()

        if not RootPart or not CameraObject then
            return
        end

        if FlyMethod == "Ragdoll" then
            local Velocity = GetFlyInputVelocity(
                CameraObject,
                60,
                false
            )

            RootPart.Velocity = Velocity

            if RagdollRemote then
                RagdollRemote:FireServer(
                    "__---r",
                    Vector3.new(0, 0, 0),
                    RootPart.CFrame,
                    false
                )
            end
        else
            local Velocity = GetFlyInputVelocity(
                CameraObject,
                40,
                true
            )

            RootPart.AssemblyLinearVelocity = Velocity
        end
    end)
end

function FlyDisable()
    if not FlyEnabled then return end

    FlyEnabled = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    local Character = LocalPlayer.Character
    local RootPart = Character
        and Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character
        and Character:FindFirstChildOfClass("Humanoid")

    if RootPart then
        RootPart.Velocity = Vector3.new(0, 0, 0)
        RootPart.AssemblyLinearVelocity =
            Vector3.new(0, 0, 0)
    end

    if Humanoid then
        Humanoid.PlatformStand = false
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
;(function()
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
end)()

function InvisibilityEnable()
    if InvisibilityEnabled then return end
    InvisibilityController.Enable()
end

function InvisibilityDisable()
    if not InvisibilityEnabled then return end
    InvisibilityController.Disable()
end


do
    local LegacyState = rawget(
        getgenv(),
        "RadiantHideHeadHook"
    )

    if type(LegacyState) == "table" then
        LegacyState.Enabled = false

        if LegacyState.VisualFolder then
            pcall(function()
                LegacyState.VisualFolder:Destroy()
            end)
        end

        if LegacyState.ScreenGui then
            pcall(function()
                LegacyState.ScreenGui:Destroy()
            end)
        end

        LegacyState.VisualFolder = nil
        LegacyState.OriginPart = nil
        LegacyState.DirectionPart = nil
        LegacyState.ScreenGui = nil
        LegacyState.StatusLabel = nil
    end

    local DebugFolder = workspace:FindFirstChild(
        "_RadiantHideHeadDebug"
    )

    if DebugFolder then
        DebugFolder:Destroy()
    end

    pcall(function()
        local Parent = type(gethui) == "function"
            and gethui()
            or game:GetService("CoreGui")
        local DebugGui = Parent:FindFirstChild(
            "_RadiantHideHeadDebugGui"
        )

        if DebugGui then
            DebugGui:Destroy()
        end
    end)
end

HideHeadController = HideHeadController or {
    Enabled = false,
    Installed = false,
    Remote = nil,
    RemoteConnection = nil,
    OriginalFireServer = nil
}

local function ClonePacketTable(Source)
    if type(Source) ~= "table" then
        return Source
    end

    if type(table.clone) == "function" then
        return table.clone(Source)
    end

    local Copy = {}

    for Key, Value in pairs(Source) do
        Copy[Key] = Value
    end

    return Copy
end

local function CreateHiddenHeadVector()
    return Vector3.new(
        math.random(1, 1000),
        math.random(1, 1000),
        math.random(1, 1000)
    )
end

function ResolveHideHeadRemote(State)
    local Events = ReplicatedStorage:FindFirstChild(
        "Events"
    )

    if not Events then
        return nil
    end

    local MovementRemote = Events:FindFirstChild(
        "MOVZREP"
    )

    if MovementRemote then
        State.Remote = MovementRemote
    end

    if not State.RemoteConnection then
        State.RemoteConnection = Events.ChildAdded:Connect(
            function(Child)
                if Child.Name == "MOVZREP"
                    and Child:IsA("RemoteEvent")
                then
                    State.Remote = Child
                end
            end
        )
    end

    return State.Remote
end

function IsHideHeadMovementRemote(State, Remote)
    if typeof(Remote) ~= "Instance"
        or not Remote:IsA("RemoteEvent")
    then
        return false
    end

    if Remote == State.Remote then
        return true
    end

    if Remote.Name ~= "MOVZREP" then
        return false
    end

    local Parent = Remote.Parent

    if not Parent or Parent.Name ~= "Events" then
        return false
    end

    State.Remote = Remote
    return true
end

function InstallHideHeadHook()
    local Environment = getgenv()
    local State = rawget(
        Environment,
        "RadiantHideHeadHook"
    )

    if type(State) ~= "table"
        or State.Version ~= 3
    then
        if type(State) == "table" then
            State.Enabled = false

            if typeof(State.RemoteConnection)
                == "RBXScriptConnection"
            then
                State.RemoteConnection:Disconnect()
            end

            if State.VisualFolder then
                pcall(function()
                    State.VisualFolder:Destroy()
                end)
            end

            if State.ScreenGui then
                pcall(function()
                    State.ScreenGui:Destroy()
                end)
            end
        end

        State = {
            Version = 3,
            Enabled = false,
            Installed = false,
            Remote = nil,
            RemoteConnection = nil,
            OriginalFireServer = nil
        }

        rawset(
            Environment,
            "RadiantHideHeadHook",
            State
        )
    end

    HideHeadController = State
    ResolveHideHeadRemote(State)

    if State.Installed then
        return true
    end

    if type(hookfunction) ~= "function" then
        return false
    end

    local TemporaryRemote =
        Instance.new("RemoteEvent")
    local FireServerMethod =
        TemporaryRemote.FireServer

    TemporaryRemote:Destroy()

    local OriginalFireServer

    local Success = pcall(function()
        OriginalFireServer = hookfunction(
            FireServerMethod,
            function(Self, ...)
                local Arguments = table.pack(...)

                if State.Enabled
                    and IsHideHeadMovementRemote(
                        State,
                        Self
                    )
                then
                    local Packet = Arguments[1]
                    local JointData =
                        type(Packet) == "table"
                        and Packet[1]

                    if type(JointData) == "table" then
                        local PacketCopy =
                            ClonePacketTable(Packet)
                        local JointCopy =
                            ClonePacketTable(JointData)

                        JointCopy[2] =
                            CreateHiddenHeadVector()
                        JointCopy[3] =
                            CreateHiddenHeadVector()

                        PacketCopy[1] = JointCopy
                        Arguments[1] = PacketCopy
                    end
                end

                return OriginalFireServer(
                    Self,
                    table.unpack(
                        Arguments,
                        1,
                        Arguments.n
                    )
                )
            end
        )
    end)

    if not Success or not OriginalFireServer then
        return false
    end

    State.OriginalFireServer =
        OriginalFireServer
    State.Installed = true

    return true
end

function SetHideHeadEnabled(Value)
    HideHeadEnabled = Value == true

    local Installed = InstallHideHeadHook()
    local State = getgenv().RadiantHideHeadHook

    if type(State) == "table" then
        State.Enabled =
            HideHeadEnabled
            and Installed

        ResolveHideHeadRemote(State)
    end

    if not Installed then
        HideHeadEnabled = false
    end

    return HideHeadEnabled
end

function ShutdownHideHeadController()
    HideHeadEnabled = false

    local State = getgenv().RadiantHideHeadHook

    if type(State) == "table" then
        State.Enabled = false

        if typeof(State.RemoteConnection)
            == "RBXScriptConnection"
        then
            State.RemoteConnection:Disconnect()
        end

        State.RemoteConnection = nil
        State.Remote = nil

        if State.VisualFolder then
            pcall(function()
                State.VisualFolder:Destroy()
            end)
        end

        if State.ScreenGui then
            pcall(function()
                State.ScreenGui:Destroy()
            end)
        end

        State.VisualFolder = nil
        State.ScreenGui = nil
    end
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

function GetArmsViewModel()
    local CameraObject = GetCamera()
    if not CameraObject then return nil end
    local Names = { "ViewModel", "Viewmodel", "viewmodel", "Arms", "ViewArms" }
    for Unused, Name in ipairs(Names) do
        local ViewModel = CameraObject:FindFirstChild(Name)
        if ViewModel then return ViewModel end
    end
    for Unused, Child in ipairs(CameraObject:GetChildren()) do
        if Child:IsA("Model") and Child:FindFirstChildWhichIsA("BasePart", true) then
            local LowerName = string.lower(Child.Name)
            if string.find(LowerName, "view", 1, true) or string.find(LowerName, "arm", 1, true) then return Child end
        end
    end
    return nil
end

function IsLocalFirstPerson(ForceRefresh)
    local CameraObject = GetCamera()
    local Character = LocalPlayer.Character
    local ViewModel = GetArmsViewModel()

    if not CameraObject or not Character then
        ChamsViewState.FirstPerson = false
        ChamsViewState.Candidate = false
        ChamsViewState.CurrentCamera = CameraObject
        return false, ViewModel
    end

    local CurrentTime = os.clock()
    local Head = Character:FindFirstChild("Head")
    local Root = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    local Reference = Head or Root
    local Distance = Reference and (CameraObject.CFrame.Position - Reference.Position).Magnitude or math.huge
    local Locked = LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson
    local ForcedThirdPerson = type(S) == "table" and type(S.ThirdPerson) == "table" and S.ThirdPerson.Enabled == true
    local EnterDistance = tonumber(ChamsViewState.EnterDistance) or 1.55
    local ExitDistance = tonumber(ChamsViewState.ExitDistance) or 3.15
    local Wanted

    if ForcedThirdPerson then
        Wanted = false
    elseif Locked then
        Wanted = true
    elseif ChamsViewState.FirstPerson then
        Wanted = Distance <= ExitDistance
    else
        Wanted = Distance <= EnterDistance
    end

    if ChamsViewState.CurrentCamera ~= CameraObject then
        ChamsViewState.CurrentCamera = CameraObject
        ChamsViewState.FirstPerson = Wanted
        ChamsViewState.Candidate = Wanted
        ChamsViewState.CandidateSince = CurrentTime
        return Wanted, ViewModel
    end

    if ForceRefresh then
        ChamsViewState.FirstPerson = Wanted
        ChamsViewState.Candidate = Wanted
        ChamsViewState.CandidateSince = CurrentTime
    elseif Wanted ~= ChamsViewState.FirstPerson then
        if ChamsViewState.Candidate ~= Wanted then
            ChamsViewState.Candidate = Wanted
            ChamsViewState.CandidateSince = CurrentTime
        elseif CurrentTime - (ChamsViewState.CandidateSince or 0) >= 0.06 then
            ChamsViewState.FirstPerson = Wanted
            ChamsViewState.CandidateSince = CurrentTime
        end
    else
        ChamsViewState.Candidate = Wanted
        ChamsViewState.CandidateSince = CurrentTime
    end

    return ChamsViewState.FirstPerson, ViewModel
end

function IsArmsChamsPart(Part)
    if Part:GetAttribute("RadiantArmsOverlay") or Part:GetAttribute("RadiantWeaponOverlay") then return false end
    local Name = string.lower(Part.Name):gsub("[%s_%-]", "")
    if Name == "leftarm" or Name == "rightarm" or Name == "lefthand" or Name == "righthand" then return true end
    local Side = string.find(Name, "left", 1, true) or string.find(Name, "right", 1, true)
    if not Side then return false end
    return string.find(Name, "arm", 1, true) ~= nil or string.find(Name, "hand", 1, true) ~= nil or string.find(Name, "sleeve", 1, true) ~= nil or string.find(Name, "glove", 1, true) ~= nil
end

function PrepareLocalChamOverlay(Source, Overlay, Prefix, Kind, AttributeName)
    PrepareChamShell(Source, Overlay, Source.Parent, Prefix .. Kind, Enum.Material.ForceField, false, AttributeName)
    local Weld = Instance.new("WeldConstraint")
    Weld.Name = Prefix .. "Weld"
    Weld.Part0 = Source
    Weld.Part1 = Overlay
    Weld.Parent = Overlay
    return Overlay
end

function CreateLocalChamOverlay(Source, Prefix, Kind, AttributeName)
    local Success, Overlay = pcall(function() return Source:Clone() end)
    if not Success or not Overlay or not Overlay:IsA("BasePart") then return nil end
    return PrepareLocalChamOverlay(Source, Overlay, Prefix, Kind, AttributeName)
end

function UpdatePartOutline(Outline, Parent, Adornee, Name, Color, Transparency)
    if not Outline or not Outline.Parent then
        Outline = Instance.new("Highlight")
        Outline.Name = Name
        Outline.Parent = Parent
    end
    Outline.Adornee = Adornee
    Outline.DepthMode = Enum.HighlightDepthMode.Occluded
    Outline.FillTransparency = 1
    Outline.OutlineColor = Color
    Outline.OutlineTransparency = math.clamp(Transparency, 0, 1)
    Outline.Enabled = Adornee ~= nil
    return Outline
end

function StoreArmsChamsOriginal(Part)
    if ArmsChamsSettings.Original[Part] then return end
    ArmsChamsSettings.Original[Part] = { LocalTransparencyModifier = Part.LocalTransparencyModifier, RuntimeLocalTransparencyModifier = Part.LocalTransparencyModifier }
end

function DestroyArmsOverlay(Part)
    local OverlayData = ArmsChamsSettings.Overlays[Part]
    if not OverlayData then return end
    if OverlayData.Fill and OverlayData.Fill.Parent then OverlayData.Fill:Destroy() end
    if OverlayData.Glow and OverlayData.Glow.Parent then OverlayData.Glow:Destroy() end
    if OverlayData.Outline and OverlayData.Outline.Parent then OverlayData.Outline:Destroy() end
    ArmsChamsSettings.Overlays[Part] = nil
end

function UpdateArmsOverlay(Source)
    if not Source or not Source.Parent then return end
    local OverlayData = ArmsChamsSettings.Overlays[Source]
    if not OverlayData then OverlayData = {} ArmsChamsSettings.Overlays[Source] = OverlayData end
    local Original = ArmsChamsSettings.Original[Source]
    local HasSurfaceChams = ArmsChamsSettings.FillEnabled or ArmsChamsSettings.GlowEnabled
    local CurrentModifier = Source.LocalTransparencyModifier

    if Original and CurrentModifier < 0.995 then
        Original.RuntimeLocalTransparencyModifier = CurrentModifier
    end

    local SourceModifier = Original and Original.RuntimeLocalTransparencyModifier or 0
    local SourceTransparency = 1 - (1 - math.clamp(Source.Transparency, 0, 1)) * (1 - math.clamp(SourceModifier, 0, 1))
    local FillTransparency = 1 - (1 - math.clamp(ArmsChamsSettings.FillTransparency, 0, 1)) * (1 - SourceTransparency)
    local GlowTransparency = 1 - (1 - math.clamp(ArmsChamsSettings.GlowTransparency, 0, 1)) * (1 - SourceTransparency)

    if ArmsChamsSettings.FillEnabled then
        if not OverlayData.Fill or not OverlayData.Fill.Parent then OverlayData.Fill = CreateLocalChamOverlay(Source, "RadiantArms", "Fill", "RadiantArmsOverlay") end
        if OverlayData.Fill then
            OverlayData.Fill.Material = Enum.Material.ForceField
            OverlayData.Fill.Color = ArmsChamsSettings.FillColor
            OverlayData.Fill.Size = Source.Size
            ApplyChamPartTransparency(OverlayData.Fill, FillTransparency)
        end
    elseif OverlayData.Fill then OverlayData.Fill:Destroy() OverlayData.Fill = nil end

    if ArmsChamsSettings.GlowEnabled then
        if not OverlayData.Glow or not OverlayData.Glow.Parent then OverlayData.Glow = CreateLocalChamOverlay(Source, "RadiantArms", "Glow", "RadiantArmsOverlay") end
        if OverlayData.Glow then
            OverlayData.Glow.Material = Enum.Material.Neon
            OverlayData.Glow.Color = ArmsChamsSettings.GlowColor
            OverlayData.Glow.Size = Source.Size * math.clamp(tonumber(ArmsChamsSettings.GlowScale) or 1.035, 1.001, 1.08)
            ApplyChamPartTransparency(OverlayData.Glow, GlowTransparency)
        end
    elseif OverlayData.Glow then OverlayData.Glow:Destroy() OverlayData.Glow = nil end

    if Original then Source.LocalTransparencyModifier = HasSurfaceChams and 1 or Original.LocalTransparencyModifier end

    if ArmsChamsSettings.OutlineEnabled then
        local Adornee = OverlayData.Fill or OverlayData.Glow or Source
        OverlayData.Outline = UpdatePartOutline(OverlayData.Outline, Source.Parent, Adornee, "RadiantArmsOutline", ArmsChamsSettings.OutlineColor, ArmsChamsSettings.OutlineTransparency)
    elseif OverlayData.Outline then OverlayData.Outline:Destroy() OverlayData.Outline = nil end
end

function RestoreArmsChamsPart(Part)
    local Original = ArmsChamsSettings.Original[Part]
    DestroyArmsOverlay(Part)
    if Original and Part and Part.Parent then pcall(function() Part.LocalTransparencyModifier = Original.LocalTransparencyModifier end) end
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

    local CameraObject = GetCamera()
    local FirstPerson, ViewModel = IsLocalFirstPerson()
    local Mode = FirstPerson and "FirstPerson" or "ThirdPerson"
    local CurrentTime = os.clock()

    if ArmsChamsSettings.CurrentCamera ~= CameraObject
        or ArmsChamsSettings.CurrentMode ~= Mode
    then
        RestoreArmsChams()
        ArmsChamsSettings.CurrentCamera = CameraObject
        ArmsChamsSettings.CurrentMode = Mode
        ArmsChamsSettings.TransitionUntil = CurrentTime + 0.075
    end

    if not FirstPerson then
        if next(ArmsChamsSettings.Original) ~= nil then RestoreArmsChams() end
        return
    end

    if not ViewModel or not ViewModel.Parent then
        if CurrentTime >= (ArmsChamsSettings.TransitionUntil or 0) then RestoreArmsChams() end
        return
    end

    if ArmsChamsSettings.CurrentViewModel ~= ViewModel then
        RestoreArmsChams()
        ArmsChamsSettings.CurrentMode = Mode
        ArmsChamsSettings.CurrentCamera = CameraObject
        ArmsChamsSettings.CurrentViewModel = ViewModel
        ArmsChamsSettings.TransitionUntil = CurrentTime + 0.035
    end

    local ActiveParts = setmetatable({}, { __mode = "k" })
    for _, Descendant in ipairs(ViewModel:GetDescendants()) do
        if Descendant:IsA("BasePart")
            and Descendant.Transparency < 0.995
            and IsArmsChamsPart(Descendant)
        then
            StoreArmsChamsOriginal(Descendant)
            UpdateArmsOverlay(Descendant)
            ActiveParts[Descendant] = true
            ArmsChamsSettings.CurrentParts[Descendant] = true
        end
    end

    local Stale = {}
    for Part in pairs(ArmsChamsSettings.Original) do
        if not ActiveParts[Part] then Stale[#Stale + 1] = Part end
    end
    for _, Part in ipairs(Stale) do RestoreArmsChamsPart(Part) end
end

function SyncArmsChamsTransparency()
    local HasSurfaceChams = ArmsChamsSettings.FillEnabled or ArmsChamsSettings.GlowEnabled
    for Part in pairs(ArmsChamsSettings.CurrentParts) do
        local Original = ArmsChamsSettings.Original[Part]
        if Part and Part.Parent and Original then Part.LocalTransparencyModifier = HasSurfaceChams and 1 or Original.LocalTransparencyModifier end
    end
    for Source, OverlayData in pairs(ArmsChamsSettings.Overlays) do
        if Source and Source.Parent and OverlayData then
            if OverlayData.Fill and OverlayData.Fill.Parent then ApplyChamPartTransparency(OverlayData.Fill, ArmsChamsSettings.FillTransparency) end
            if OverlayData.Glow and OverlayData.Glow.Parent then ApplyChamPartTransparency(OverlayData.Glow, ArmsChamsSettings.GlowTransparency) end
            if OverlayData.Outline and OverlayData.Outline.Parent then
                OverlayData.Outline.OutlineColor = ArmsChamsSettings.OutlineColor
                OverlayData.Outline.OutlineTransparency = math.clamp(ArmsChamsSettings.OutlineTransparency, 0, 1)
                OverlayData.Outline.FillTransparency = 1
            end
        end
    end
end

function ArmsChamsEnable()
    if ArmsChamsEnabled then ApplyArmsChams() return end
    ArmsChamsEnabled = true
    ArmsChamsSettings.Clock = 0
    ArmsChamsSettings.CurrentMode = nil
    ArmsChamsSettings.CurrentCamera = nil
    if ArmsChamsSettings.Connection then ArmsChamsSettings.Connection:Disconnect() end
    ArmsChamsSettings.Connection = RunService.RenderStepped:Connect(function(DeltaTime)
        if not ArmsChamsEnabled then return end
        ArmsChamsSettings.Clock = ArmsChamsSettings.Clock + math.clamp(DeltaTime, 0, 0.05)
        if ArmsChamsSettings.Clock >= 0.03 then
            ArmsChamsSettings.Clock = 0
            ApplyArmsChams()
        end
        SyncArmsChamsTransparency()
    end)
    ApplyArmsChams()
end

function ArmsChamsDisable()
    ArmsChamsEnabled = false
    if ArmsChamsSettings.Connection then ArmsChamsSettings.Connection:Disconnect() ArmsChamsSettings.Connection = nil end
    RestoreArmsChams()
end

function GetWeaponChamVisualExtent(Part)
    if not Part or not Part:IsA("BasePart") then return math.huge end
    local Size = Part.Size
    local Extent = math.max(math.abs(Size.X), math.abs(Size.Y), math.abs(Size.Z))
    local Mesh = Part:FindFirstChildWhichIsA("DataModelMesh")
    if Mesh then
        pcall(function()
            local Scale = Mesh.Scale
            Extent = math.max(Extent, math.abs(Scale.X), math.abs(Scale.Y), math.abs(Scale.Z))
        end)
    end
    return Extent
end

function IsWeaponChamsPart(Part, FirstPerson)
    if not Part or not Part:IsA("BasePart") then return false end
    if Part:GetAttribute("RadiantArmsOverlay") or Part:GetAttribute("RadiantWeaponOverlay") then return false end
    if IsArmsChamsPart(Part) then return false end
    if Part.Size.Magnitude <= 0.02 then return false end

    local Name = string.lower(Part.Name):gsub("[%s_%-]", "")
    local Blocked = {
        "firepos", "originfirepos", "muzzlepoint", "muzzleattachment", "aimpoint", "camera",
        "hitbox", "collider", "collision", "raycast", "bulletorigin", "rootpart", "primarypart",
        "humanoidrootpart", "aimpart", "reference", "pivot", "handlehitbox", "soundpart",
        "trajectory", "projectile", "bulletpath", "tracerorigin", "lookvector", "direction",
        "axis", "guide", "helper", "debug", "boundingbox", "bounds", "proxy", "weldpart",
        "motorpart", "constraintpart", "mountpart", "anchorpart", "centerpart", "viewroot"
    }
    for _, Token in ipairs(Blocked) do
        if string.find(Name, Token, 1, true) then return false end
    end

    local Size = Part.Size
    local X, Y, Z = math.abs(Size.X), math.abs(Size.Y), math.abs(Size.Z)
    local Maximum = math.max(X, Y, Z)
    local Minimum = math.min(X, Y, Z)
    local Middle = X + Y + Z - Maximum - Minimum
    local Volume = X * Y * Z
    local HasMesh = Part:IsA("MeshPart") or Part:IsA("UnionOperation") or Part:FindFirstChildWhichIsA("DataModelMesh") ~= nil
    local NonBlockShape = false
    if Part:IsA("Part") then pcall(function() NonBlockShape = Part.Shape ~= Enum.PartType.Block end) end

    if FirstPerson then
        if HasMesh or NonBlockShape then
            if Maximum > 6.5 then return false end
        else
            local VisualTokens = { "slide", "barrel", "magazine", "mag", "trigger", "sight", "grip", "stock", "receiver", "frame", "bolt", "shell", "pump", "rail", "cylinder", "guard", "blade", "handle", "body" }
            local NamedVisual = false
            for _, Token in ipairs(VisualTokens) do
                if string.find(Name, Token, 1, true) then NamedVisual = true break end
            end
            if not NamedVisual then return false end
            if Maximum > 3.15 or Volume > 5.25 then return false end
            if Maximum > 1.6 and Maximum / math.max(Middle, 0.04) > 8 then return false end
            if Middle > 1.1 and Middle / math.max(Minimum, 0.025) > 14 then return false end
        end
    elseif GetWeaponChamVisualExtent(Part) > 14 then
        return false
    end
    return true
end

function IsWeaponChamsSourceVisible(Part)
    if not Part or not Part.Parent then return false end
    local Effective = 1 - (1 - math.clamp(Part.Transparency, 0, 1)) * (1 - math.clamp(Part.LocalTransparencyModifier, 0, 1))
    return Effective < 0.985
end

function NormalizeWeaponRootName(Value)
    return string.lower(tostring(Value or "")):gsub("[%s_%-%.]", "")
end

function GetEquippedWeaponTool()
    local Character = LocalPlayer.Character
    return Character and Character:FindFirstChildOfClass("Tool") or nil
end

function GetWeaponVisiblePartCount(Root)
    if not Root then return 0 end
    local Count = 0
    for _, Descendant in ipairs(Root:GetDescendants()) do
        if Descendant:IsA("BasePart") and IsWeaponChamsPart(Descendant) then
            local Effective = 1 - (1 - math.clamp(Descendant.Transparency, 0, 1)) * (1 - math.clamp(Descendant.LocalTransparencyModifier, 0, 1))
            if Effective < 0.985 then Count += 1 end
        end
    end
    return Count
end

function GetActiveFirstPersonWeaponRoot(ViewModel)
    if not ViewModel or not ViewModel.Parent then return nil end

    local VM = rawget(_G, "VM")
    if type(VM) == "table" and typeof(VM.CloneTool) == "Instance" and VM.CloneTool.Parent then
        local Success, IsCurrent = pcall(function() return VM.CloneTool:IsDescendantOf(ViewModel) end)
        if Success and IsCurrent and GetWeaponVisiblePartCount(VM.CloneTool) > 0 then return VM.CloneTool end
    end

    local Equipped = GetEquippedWeaponTool()
    local EquippedName = Equipped and NormalizeWeaponRootName(Equipped.Name) or ""
    local BestRoot = nil
    local BestScore = -math.huge

    for _, Candidate in ipairs(ViewModel:GetChildren()) do
        if Candidate:IsA("Tool") or Candidate:IsA("Model") then
            local Score = GetWeaponVisiblePartCount(Candidate) * 4
            local RootName = NormalizeWeaponRootName(Candidate.Name)
            if EquippedName ~= "" and RootName == EquippedName then Score += 150 end
            if Candidate:FindFirstChild("WeaponHandle", true) then Score += 45 end
            if Candidate:FindFirstChild("Handle", true) then Score += 25 end
            if Candidate:FindFirstChild("FirePos", true) or Candidate:FindFirstChild("OriginFirePos", true) then Score += 35 end
            local LowerName = string.lower(Candidate.Name)
            if string.find(LowerName, "arm", 1, true) or string.find(LowerName, "hand", 1, true) then Score -= 120 end
            if Score > BestScore then BestScore, BestRoot = Score, Candidate end
        end
    end

    return BestScore >= 20 and BestRoot or nil
end

function GetActiveThirdPersonWeaponRoot()
    return GetEquippedWeaponTool()
end

function GetActiveWeaponChamsRoot(FirstPerson, ViewModel)
    if FirstPerson then
        if not WeaponChamsSettings.FirstPerson then return nil end
        return GetActiveFirstPersonWeaponRoot(ViewModel)
    end
    if not WeaponChamsSettings.ThirdPerson then return nil end
    return GetActiveThirdPersonWeaponRoot()
end

function CaptureWeaponChamTextureState(Part)
    local State = { Children = {} }
    pcall(function() State.TextureID = Part.TextureID end)
    pcall(function() State.TextureId = Part.TextureId end)
    for _, Descendant in ipairs(Part:GetDescendants()) do
        if Descendant:IsA("Decal") or Descendant:IsA("Texture") then
            State.Children[#State.Children + 1] = { Object = Descendant, Kind = "Texture", Transparency = Descendant.Transparency }
        elseif Descendant:IsA("SurfaceAppearance") then
            State.Children[#State.Children + 1] = { Object = Descendant, Kind = "SurfaceAppearance", Parent = Descendant.Parent }
        elseif Descendant:IsA("DataModelMesh") then
            local Entry = { Object = Descendant, Kind = "Mesh" }
            pcall(function() Entry.TextureId = Descendant.TextureId end)
            State.Children[#State.Children + 1] = Entry
        end
    end
    return State
end

function StoreWeaponChamsOriginal(Part)
    if WeaponChamsSettings.Original[Part] then return end
    local MaterialVariant = ""
    pcall(function() MaterialVariant = Part.MaterialVariant end)
    WeaponChamsSettings.Original[Part] = {
        Material = Part.Material,
        MaterialVariant = MaterialVariant,
        Color = Part.Color,
        Transparency = Part.Transparency,
        RuntimeTransparency = Part.Transparency,
        LastAppliedTransparency = nil,
        Reflectance = Part.Reflectance,
        LocalTransparencyModifier = Part.LocalTransparencyModifier,
        Textures = CaptureWeaponChamTextureState(Part),
        FillApplied = false
    }
end

function ApplyWeaponChamTextureOverride(Part, Original)
    local Textures = Original and Original.Textures
    if not Textures then return end
    pcall(function() Part.TextureID = "" end)
    pcall(function() Part.TextureId = "" end)
    for _, Entry in ipairs(Textures.Children) do
        local Object = Entry.Object
        if Object then
            if Entry.Kind == "Texture" and Object.Parent then
                pcall(function() Object.Transparency = 1 end)
            elseif Entry.Kind == "SurfaceAppearance" and Object.Parent then
                pcall(function() Object.Parent = nil end)
            elseif Entry.Kind == "Mesh" and Object.Parent then
                pcall(function() Object.TextureId = "" end)
            end
        end
    end
end

function RestoreWeaponChamTextureState(Part, Original)
    local Textures = Original and Original.Textures
    if not Textures then return end
    if Part and Part.Parent then
        if Textures.TextureID ~= nil then pcall(function() Part.TextureID = Textures.TextureID end) end
        if Textures.TextureId ~= nil then pcall(function() Part.TextureId = Textures.TextureId end) end
    end
    for _, Entry in ipairs(Textures.Children) do
        local Object = Entry.Object
        if Object then
            if Entry.Kind == "Texture" and Object.Parent then
                pcall(function() Object.Transparency = Entry.Transparency end)
            elseif Entry.Kind == "SurfaceAppearance" and Part and Part.Parent and Entry.Parent then
                pcall(function() Object.Parent = Entry.Parent end)
            elseif Entry.Kind == "Mesh" and Object.Parent and Entry.TextureId ~= nil then
                pcall(function() Object.TextureId = Entry.TextureId end)
            end
        end
    end
end

function GetWeaponRuntimeTransparency(Source, Original)
    local Current = math.clamp(Source.Transparency, 0, 1)
    if not Original then return Current end
    local LastApplied = Original.LastAppliedTransparency
    if LastApplied == nil or math.abs(Current - LastApplied) > 0.003 then
        Original.RuntimeTransparency = Current
    end
    return math.clamp(tonumber(Original.RuntimeTransparency) or 0, 0, 1)
end

function GetWeaponEffectiveTransparency(Source, Original)
    local Base = GetWeaponRuntimeTransparency(Source, Original)
    local LocalModifier = math.clamp(Source.LocalTransparencyModifier, 0, 1)
    return 1 - (1 - Base) * (1 - LocalModifier), Base
end

function CombineWeaponChamTransparency(ChamTransparency, SourceTransparency)
    return 1 - (1 - math.clamp(ChamTransparency, 0, 1)) * (1 - math.clamp(SourceTransparency, 0, 1))
end

function RegisterWeaponChamsRuntime(Object)
    if Object then
        WeaponChamsSettings.RuntimeObjects[#WeaponChamsSettings.RuntimeObjects + 1] = Object
    end
    return Object
end

function DestroyWeaponChamsRuntime()
    local RuntimeObjects = WeaponChamsSettings.RuntimeObjects
    for Index = #RuntimeObjects, 1, -1 do
        local Object = RuntimeObjects[Index]
        RuntimeObjects[Index] = nil
        if typeof(Object) == "Instance" then pcall(function() Object:Destroy() end) end
    end
    if WeaponChamsSettings.Folder then pcall(function() WeaponChamsSettings.Folder:Destroy() end) end
    WeaponChamsSettings.Folder = nil
    WeaponChamsSettings.Highlight = nil
end

function EnsureWeaponChamsFolder(Root)
    local Folder = WeaponChamsSettings.Folder
    if Folder and (not Folder.Parent or Folder.Parent ~= Root) then
        DestroyWeaponChamsRuntime()
        Folder = nil
    end
    if not Folder and Root and Root.Parent then
        Folder = Instance.new("Folder")
        Folder.Name = "RadiantWeaponChamsRuntime"
        Folder:SetAttribute("RadiantWeaponOverlay", true)
        Folder.Parent = Root
        WeaponChamsSettings.Folder = RegisterWeaponChamsRuntime(Folder)
    end
    return Folder
end

function DestroyWeaponOverlay(Part)
    local OverlayData = WeaponChamsSettings.Overlays[Part]
    if not OverlayData then return end
    for _, Key in ipairs({ "Glow", "Outline", "Effect" }) do
        local Object = OverlayData[Key]
        if Object then pcall(function() Object:Destroy() end) end
        OverlayData[Key] = nil
    end
    WeaponChamsSettings.Overlays[Part] = nil
end

function DestroyWeaponChamsHighlight()
    if WeaponChamsSettings.Highlight then
        pcall(function() WeaponChamsSettings.Highlight:Destroy() end)
        WeaponChamsSettings.Highlight = nil
    end
end

function EnsureWeaponChamsHighlight(Root)
    DestroyWeaponChamsHighlight()
    return nil
end

function CreateWeaponChamEffect(Source, Folder)
    if not Source or not Source.Parent or not Folder or not Folder.Parent then return nil end
    local Effect = Instance.new("Highlight")
    Effect.Name = "RadiantWeaponEffect"
    Effect:SetAttribute("RadiantWeaponOverlay", true)
    Effect.Adornee = Source
    Effect.DepthMode = Enum.HighlightDepthMode.Occluded
    Effect.FillTransparency = 1
    Effect.OutlineTransparency = 1
    Effect.Parent = Folder
    return RegisterWeaponChamsRuntime(Effect)
end

function RestoreWeaponFillVisual(Source, Original)
    if not Original or not Source or not Source.Parent then return end
    Source.Material = Original.Material
    pcall(function() Source.MaterialVariant = Original.MaterialVariant or "" end)
    Source.Color = Original.Color
    Source.Reflectance = Original.Reflectance
    RestoreWeaponChamTextureState(Source, Original)
    local Runtime = math.clamp(tonumber(Original.RuntimeTransparency) or tonumber(Original.Transparency) or 0, 0, 1)
    Source.Transparency = Runtime
    Original.LastAppliedTransparency = Runtime
    Original.FillApplied = false
end

function UpdateWeaponOverlay(Source)
    if not Source or not Source.Parent then return end
    local Original = WeaponChamsSettings.Original[Source]
    if not Original then return end

    local EffectiveTransparency, RuntimeTransparency = GetWeaponEffectiveTransparency(Source, Original)
    local HiddenByGame = EffectiveTransparency >= 0.985
    local OverlayData = WeaponChamsSettings.Overlays[Source]
    if not OverlayData then
        OverlayData = {}
        WeaponChamsSettings.Overlays[Source] = OverlayData
    end

    if HiddenByGame then
        if Original.FillApplied then RestoreWeaponFillVisual(Source, Original) end
        DestroyWeaponOverlay(Source)
        Source.Transparency = 1
        Original.LastAppliedTransparency = 1
        return
    end

    if WeaponChamsSettings.FillEnabled then
        Original.FillApplied = true
        ApplyWeaponChamTextureOverride(Source, Original)
        Source.Material = Enum.Material.ForceField
        pcall(function() Source.MaterialVariant = "" end)
        Source.Color = WeaponChamsSettings.FillColor
        Source.Reflectance = 0
        local Applied = CombineWeaponChamTransparency(WeaponChamsSettings.FillTransparency, RuntimeTransparency)
        Source.Transparency = Applied
        Original.LastAppliedTransparency = Applied
    elseif Original.FillApplied then
        RestoreWeaponFillVisual(Source, Original)
    end

    local Folder = EnsureWeaponChamsFolder(WeaponChamsSettings.CurrentRoot)
    local WantsEffect = WeaponChamsSettings.GlowEnabled or WeaponChamsSettings.OutlineEnabled
    if WantsEffect and Folder then
        if not OverlayData.Effect or not OverlayData.Effect.Parent then
            OverlayData.Effect = CreateWeaponChamEffect(Source, Folder)
        end
        if OverlayData.Effect then
            OverlayData.Effect.Adornee = Source
            OverlayData.Effect.DepthMode = Enum.HighlightDepthMode.Occluded
            OverlayData.Effect.FillColor = WeaponChamsSettings.GlowColor
            OverlayData.Effect.FillTransparency = WeaponChamsSettings.GlowEnabled
                and CombineWeaponChamTransparency(WeaponChamsSettings.GlowTransparency, RuntimeTransparency) or 1
            OverlayData.Effect.OutlineColor = WeaponChamsSettings.OutlineColor
            OverlayData.Effect.OutlineTransparency = WeaponChamsSettings.OutlineEnabled
                and math.clamp(WeaponChamsSettings.OutlineTransparency, 0, 1) or 1
            OverlayData.Effect.Enabled = true
        end
    elseif OverlayData.Effect then
        pcall(function() OverlayData.Effect:Destroy() end)
        OverlayData.Effect = nil
    end
    if OverlayData.Glow then pcall(function() OverlayData.Glow:Destroy() end) OverlayData.Glow = nil end
    if OverlayData.Outline then pcall(function() OverlayData.Outline:Destroy() end) OverlayData.Outline = nil end
end

function RestoreWeaponChamsPart(Part)
    local Original = WeaponChamsSettings.Original[Part]
    DestroyWeaponOverlay(Part)
    if Original and Part and Part.Parent then
        pcall(function()
            Part.Material = Original.Material
            Part.MaterialVariant = Original.MaterialVariant or ""
            Part.Color = Original.Color
            Part.Reflectance = Original.Reflectance
            Part.Transparency = math.clamp(tonumber(Original.RuntimeTransparency) or tonumber(Original.Transparency) or 0, 0, 1)
        end)
        RestoreWeaponChamTextureState(Part, Original)
    end
    WeaponChamsSettings.Original[Part] = nil
    WeaponChamsSettings.CurrentParts[Part] = nil
end

function RestoreWeaponChams()
    local Parts = {}
    for Part in pairs(WeaponChamsSettings.Original) do Parts[#Parts + 1] = Part end
    for _, Part in ipairs(Parts) do RestoreWeaponChamsPart(Part) end
    WeaponChamsSettings.CurrentParts = setmetatable({}, { __mode = "k" })
    WeaponChamsSettings.Overlays = setmetatable({}, { __mode = "k" })
    WeaponChamsSettings.CurrentRoot = nil
    DestroyWeaponChamsHighlight()
    DestroyWeaponChamsRuntime()
end

function PurgeLegacyWeaponChams()
    local Roots = { GetCamera(), LocalPlayer.Character }
    local ViewModel = GetArmsViewModel()
    if ViewModel then Roots[#Roots + 1] = ViewModel end
    for _, Root in ipairs(Roots) do
        if Root then
            for _, Descendant in ipairs(Root:GetDescendants()) do
                if Descendant:GetAttribute("RadiantWeaponOverlay")
                    or Descendant.Name == "RadiantWeaponOutline"
                    or Descendant.Name == "RadiantWeaponChams"
                    or Descendant.Name == "RadiantWeaponChamsRuntime"
                    or Descendant.Name == "RadiantWeaponFill"
                    or Descendant.Name == "RadiantWeaponGlow"
                    or Descendant.Name == "RadiantWeaponHighlight"
                    or Descendant.Name == "RadiantWeaponEffect"
                then
                    pcall(function() Descendant:Destroy() end)
                end
            end
        end
    end
end

function CollectWeaponChamsParts(Root, ActiveParts, FirstPerson)
    if not Root or not Root.Parent then return end
    if Root:IsA("BasePart") and IsWeaponChamsPart(Root, FirstPerson) and IsWeaponChamsSourceVisible(Root) then
        StoreWeaponChamsOriginal(Root)
        ActiveParts[Root] = true
        WeaponChamsSettings.CurrentParts[Root] = true
        UpdateWeaponOverlay(Root)
    end
    for _, Descendant in ipairs(Root:GetDescendants()) do
        if Descendant:IsA("BasePart")
            and IsWeaponChamsPart(Descendant, FirstPerson)
            and IsWeaponChamsSourceVisible(Descendant)
        then
            StoreWeaponChamsOriginal(Descendant)
            ActiveParts[Descendant] = true
            WeaponChamsSettings.CurrentParts[Descendant] = true
            UpdateWeaponOverlay(Descendant)
        end
    end
end

function ApplyWeaponChams(ForceModeRefresh)
    if not WeaponChamsEnabled then return end
    local CameraObject = GetCamera()
    if not CameraObject then return end
    local FirstPerson, ViewModel = IsLocalFirstPerson(ForceModeRefresh == true)
    local Mode = FirstPerson and "FirstPerson" or "ThirdPerson"
    local Root = GetActiveWeaponChamsRoot(FirstPerson, ViewModel)
    local Changed = WeaponChamsSettings.CurrentCamera ~= CameraObject
        or WeaponChamsSettings.CurrentMode ~= Mode
        or WeaponChamsSettings.CurrentRoot ~= Root

    if Changed then
        RestoreWeaponChams()
        PurgeLegacyWeaponChams()
        WeaponChamsSettings.CurrentCamera = CameraObject
        WeaponChamsSettings.CurrentMode = Mode
        WeaponChamsSettings.CurrentRoot = Root
        WeaponChamsSettings.TransitionUntil = os.clock() + (tonumber(WeaponChamsSettings.TransitionDelay) or 0.10)
        return
    end

    if not Root or not Root.Parent then return end
    if os.clock() < (WeaponChamsSettings.TransitionUntil or 0) then return end
    EnsureWeaponChamsFolder(Root)
    DestroyWeaponChamsHighlight()

    local ActiveParts = setmetatable({}, { __mode = "k" })
    CollectWeaponChamsParts(Root, ActiveParts, FirstPerson)

    local Stale = {}
    for Part in pairs(WeaponChamsSettings.Original) do
        if not ActiveParts[Part] then Stale[#Stale + 1] = Part end
    end
    for _, Part in ipairs(Stale) do RestoreWeaponChamsPart(Part) end

    WeaponChamsSettings.CurrentCamera = CameraObject
    WeaponChamsSettings.CurrentMode = Mode
    WeaponChamsSettings.CurrentRoot = Root
end

function SyncWeaponChams()
    if not WeaponChamsEnabled then return end
    local CameraObject = GetCamera()
    if not CameraObject then return end
    local FirstPerson, ViewModel = IsLocalFirstPerson()
    local Mode = FirstPerson and "FirstPerson" or "ThirdPerson"
    local Root = GetActiveWeaponChamsRoot(FirstPerson, ViewModel)

    if WeaponChamsSettings.CurrentCamera ~= CameraObject
        or WeaponChamsSettings.CurrentMode ~= Mode
        or WeaponChamsSettings.CurrentRoot ~= Root
    then
        ApplyWeaponChams(true)
        return
    end

    if os.clock() >= (WeaponChamsSettings.TransitionUntil or 0) and next(WeaponChamsSettings.CurrentParts) == nil then
        ApplyWeaponChams(false)
        return
    end

    local Stale = {}
    for Source in pairs(WeaponChamsSettings.CurrentParts) do
        if not Source or not Source.Parent or not Root or (Source ~= Root and not Source:IsDescendantOf(Root)) then
            Stale[#Stale + 1] = Source
        else
            UpdateWeaponOverlay(Source)
        end
    end
    for _, Part in ipairs(Stale) do RestoreWeaponChamsPart(Part) end
end

function WeaponChamsEnable()
    if WeaponChamsEnabled then ApplyWeaponChams(true) return end
    WeaponChamsEnabled = true
    WeaponChamsSettings.Clock = 0
    WeaponChamsSettings.CurrentMode = nil
    WeaponChamsSettings.CurrentRoot = nil
    WeaponChamsSettings.CurrentCamera = nil
    WeaponChamsSettings.TransitionUntil = 0
    RestoreWeaponChams()
    PurgeLegacyWeaponChams()
    local RenderName = "RadiantWeaponChamsSync_" .. tostring(LocalPlayer.UserId)
    WeaponChamsSettings.RenderName = RenderName
    pcall(function() RunService:UnbindFromRenderStep(RenderName) end)
    RunService:BindToRenderStep(RenderName, Enum.RenderPriority.Last.Value + 100, function(DeltaTime)
        if not WeaponChamsEnabled then return end
        WeaponChamsSettings.Clock += math.clamp(DeltaTime, 0, 0.05)
        if WeaponChamsSettings.Clock >= (WeaponChamsSettings.ScanInterval or 0.09) then
            WeaponChamsSettings.Clock = 0
            ApplyWeaponChams()
        end
        SyncWeaponChams()
    end)
    WeaponChamsSettings.Connection = RenderName
    ApplyWeaponChams(true)
end

function WeaponChamsDisable()
    WeaponChamsEnabled = false
    local RenderName = WeaponChamsSettings.RenderName or WeaponChamsSettings.Connection
    if type(RenderName) == "string" then
        pcall(function() RunService:UnbindFromRenderStep(RenderName) end)
    elseif WeaponChamsSettings.Connection and typeof(WeaponChamsSettings.Connection) == "RBXScriptConnection" then
        WeaponChamsSettings.Connection:Disconnect()
    end
    WeaponChamsSettings.Connection = nil
    WeaponChamsSettings.RenderName = nil
    RestoreWeaponChams()
    PurgeLegacyWeaponChams()
end

function GetFinishAuraTarget(LocalRoot)
    if not LocalRoot then return nil end

    local CharStats = ReplicatedStorage:FindFirstChild("CharStats")
    local ClosestCharacter = nil
    local ClosestDistance = 7

    for _, PlayerObject in ipairs(Players:GetPlayers()) do
        if PlayerObject ~= LocalPlayer then
            local Character = PlayerObject.Character
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local Head = Character and Character:FindFirstChild("Head")
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            local Stats = CharStats and CharStats:FindFirstChild(PlayerObject.Name)
            local Downed = Stats and Stats:FindFirstChild("Downed")

            if Root
                and Head
                and Humanoid
                and Humanoid.Health > 0
                and Downed
                and Downed.Value == true
                and not Character:FindFirstChildOfClass("ForceField")
            then
                local Distance = (LocalRoot.Position - Root.Position).Magnitude
                if Distance <= ClosestDistance then
                    ClosestDistance = Distance
                    ClosestCharacter = Character
                end
            end
        end
    end

    return ClosestCharacter
end

function ExecuteFinishAura(TargetCharacter)
    if FinishAuraBusy
        or not FinishAuraEnabled
        or not TargetCharacter
    then
        return
    end

    local Character = LocalPlayer.Character
    local Tool = Character and Character:FindFirstChildOfClass("Tool")
    local RightLeg = Character and (
        Character:FindFirstChild("Right Leg")
        or Character:FindFirstChild("RightLowerLeg")
        or Character:FindFirstChild("RightFoot")
    )
    local TargetHead = TargetCharacter:FindFirstChild("Head")

    local Events = ReplicatedStorage:FindFirstChild("Events")
    local InvokeRemote = Events and Events:FindFirstChild("XMHH.2")
    local FireRemote = Events and Events:FindFirstChild("XMHH2.2")

    if not Character
        or not Tool
        or not RightLeg
        or not TargetHead
        or not InvokeRemote
        or not FireRemote
    then
        return
    end

    FinishAuraBusy = true

    task.spawn(function()
        local Success, InvokeResult = pcall(function()
            return InvokeRemote:InvokeServer(
                "\240\159\141\158",
                tick(),
                Tool,
                "EXECQX"
            )
        end)

        if Success
            and InvokeResult
            and FinishAuraEnabled
            and TargetCharacter.Parent
            and TargetHead.Parent
        then
            task.wait(0.25)

            if FinishAuraEnabled
                and Tool.Parent
                and TargetCharacter.Parent
                and TargetHead.Parent
            then
                pcall(function()
                    FireRemote:FireServer(
                        "\240\159\141\158",
                        tick(),
                        Tool,
                        "2389ZFX34",
                        InvokeResult,
                        false,
                        RightLeg,
                        TargetHead,
                        TargetCharacter,
                        TargetHead.Position,
                        TargetHead.Position
                    )
                end)
            end
        end

        FinishAuraBusy = false
    end)
end

function FinishAuraEnable()
    if FinishAuraEnabled then return end

    FinishAuraEnabled = true
    FinishAuraBusy = false

    if FinishAuraConnection then
        FinishAuraConnection:Disconnect()
        FinishAuraConnection = nil
    end

    FinishAuraConnection = RunService.RenderStepped:Connect(function()
        if not FinishAuraEnabled or FinishAuraBusy then
            return
        end

        local Character = LocalPlayer.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        local Tool = Character and Character:FindFirstChildOfClass("Tool")

        if not Root or not Tool then
            return
        end

        local TargetCharacter = GetFinishAuraTarget(Root)
        if TargetCharacter then
            ExecuteFinishAura(TargetCharacter)
        end
    end)
end

function FinishAuraDisable()
    FinishAuraEnabled = false
    FinishAuraBusy = false

    if FinishAuraConnection then
        FinishAuraConnection:Disconnect()
        FinishAuraConnection = nil
    end
end


;(function()
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
end)()

;(function()
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
end)()

RageRandomStrFunction = nil
RageRandomStrLastScan = 0

function FindRageRandomStrFunction()
    if type(RageRandomStrFunction) == "function" then
        return RageRandomStrFunction
    end

    local CurrentTime = os.clock()
    if CurrentTime - RageRandomStrLastScan < 2 then
        return nil
    end

    RageRandomStrLastScan = CurrentTime
    if type(getgc) ~= "function" then return nil end

    local Success, Objects = pcall(getgc, true)
    if not Success or type(Objects) ~= "table" then return nil end

    for _, Object in ipairs(Objects) do
        if type(Object) == "function" then
            local Name = nil

            if debug and type(debug.info) == "function" then
                pcall(function()
                    Name = debug.info(Object, "n")
                end)
            elseif type(getinfo) == "function" then
                pcall(function()
                    local Information = getinfo(Object)
                    Name = Information and Information.name
                end)
            end

            if Name == "RandomStr" then
                RageRandomStrFunction = Object
                return Object
            end
        end
    end

    return nil
end

function GenerateRageRandomString(Length)
    local Result = {}

    for Index = 1, Length do
        Result[Index] = string.char(math.random(65, 122))
    end

    return table.concat(Result)
end

RageShotIdCounter = RageShotIdCounter or 0

function GenerateRageShotId()
    RageShotIdCounter = (RageShotIdCounter + 1) % 1000000

    local RandomFunction = FindRageRandomStrFunction()

    if RandomFunction then
        local Success, Result = pcall(RandomFunction, 30)

        if Success and type(Result) == "string" and #Result >= 30 then
            return string.sub(Result, 1, 30) .. tostring(RageShotIdCounter)
        end
    end

    return GenerateRageRandomString(30) .. tostring(RageShotIdCounter)
end

function GetRageFireOrigin(Tool)
    if not Tool then return nil end

    -- Match gun Shoot(): prefer viewmodel FirePos when VM is active.
    local VM = rawget(_G, "VM")
    if type(VM) == "table"
        and VM.Enabled
        and VM.CloneTool
        and VM.CloneTool.Parent
        and type(VM.Check) == "function"
    then
        local OkCheck, IsVM = pcall(VM.Check, Tool)
        if OkCheck and IsVM then
            local HandleName = nil
            local Config = GetRageWeaponConfig(Tool)
            if type(Config) == "table" then
                HandleName = Config.HandleName
            end
            HandleName = HandleName or "Handle"

            local VMHandle =
                VM.CloneTool:FindFirstChild(HandleName)
                or VM.CloneTool:FindFirstChild("WeaponHandle")
                or VM.CloneTool:FindFirstChild("Handle")

            local VMFire =
                VMHandle
                and (
                    VMHandle:FindFirstChild("FirePos")
                    or VMHandle:FindFirstChild("OriginFirePos")
                )

            if VMFire and VMFire:IsA("Attachment") then
                local Sway = rawget(_G, "VM_SwayCF") or CFrame.new()
                local Walk = rawget(_G, "VM_WalkCF") or CFrame.new()
                local Ok, Pos = pcall(function()
                    return (VMFire.WorldCFrame * Sway * Walk).Position
                end)
                if Ok and typeof(Pos) == "Vector3" then
                    return Pos
                end
            end
        end
    end

    local WeaponHandle =
        Tool:FindFirstChild("WeaponHandle")
        or Tool:FindFirstChild("Handle")

    local FirePosition = nil

    if WeaponHandle then
        FirePosition =
            WeaponHandle:FindFirstChild("FirePos")
            or WeaponHandle:FindFirstChild("firePos")
            or WeaponHandle:FindFirstChild("OriginFirePos")
    end

    FirePosition =
        FirePosition
        or Tool:FindFirstChild("FirePos", true)
        or Tool:FindFirstChild("firePos", true)
        or Tool:FindFirstChild("OriginFirePos", true)

    if not FirePosition then return nil end

    if FirePosition:IsA("Attachment") then
        return FirePosition.WorldCFrame.Position
    elseif FirePosition:IsA("BasePart") then
        return FirePosition.Position
    end

    local Success, Position = pcall(function()
        local WorldFrame = FirePosition.WorldCFrame
        return WorldFrame and WorldFrame.Position
    end)

    return Success and Position or nil
end

function GetRageWeaponNumber(Tool, Names)
    if not Tool then return nil end

    for _, Name in ipairs(Names) do
        local Attribute = Tool:GetAttribute(Name)

        if type(Attribute) == "number" then
            return Attribute
        end

        local Object = Tool:FindFirstChild(Name, true)

        if Object
            and (
                Object:IsA("IntValue")
                or Object:IsA("NumberValue")
            )
        then
            return tonumber(Object.Value)
        end
    end

    return nil
end

function GetRageBulletsPerShot(Tool)
    local Count = GetRageWeaponNumber(
        Tool,
        {
            "BulletsPerShot",
            "PelletsPerShot",
            "Pellets",
            "ProjectileCount",
            "BulletCount"
        }
    )

    return math.clamp(
        math.floor(tonumber(Count) or 1),
        1,
        32
    )
end

RageWeaponConfigCache = setmetatable({}, { __mode = "k" })

RageGetConfigFunction = nil

function GetRageFinalConfigFunction()
    if type(RageGetConfigFunction) == "function" then
        return RageGetConfigFunction
    end

    local NewModules = ReplicatedStorage:FindFirstChild("NewModules")
    local Shared = NewModules and NewModules:FindFirstChild("Shared")
    local Extensions = Shared and Shared:FindFirstChild("Extensions")
    local GetConfigModule = Extensions and Extensions:FindFirstChild("GetConfig")

    if GetConfigModule and GetConfigModule:IsA("ModuleScript") then
        local Success, Loader = pcall(require, GetConfigModule)

        if Success and type(Loader) == "function" then
            RageGetConfigFunction = Loader
            return Loader
        end
    end

    return nil
end

function GetRageWeaponConfig(Tool)
    if not Tool then return nil end

    local Cached = RageWeaponConfigCache[Tool]

    if Cached ~= nil then
        return Cached ~= false and Cached or nil
    end

    local Config = nil
    local GetConfig = GetRageFinalConfigFunction()

    if GetConfig then
        local Success, Result = pcall(GetConfig, Tool)

        if Success and type(Result) == "table" then
            Config = Result
        end
    end

    if not Config then
        local ConfigModule =
            Tool:FindFirstChild("Config")
            or Tool:FindFirstChild("ConfigModule")

        if ConfigModule and ConfigModule:IsA("ModuleScript") then
            local Success, Result = pcall(require, ConfigModule)

            if Success and type(Result) == "table" then
                Config = Result
            end
        end
    end

    RageWeaponConfigCache[Tool] = Config or false
    return Config
end

RAGE_PROTOCOL_INT_SALT = 28951

function GetRageIntSalt(_)
    -- The supplied Gun module defines one module-wide protected salt.
    return RAGE_PROTOCOL_INT_SALT
end

function GetRageProtocolTimestamp(_)
    local Values = ReplicatedStorage:FindFirstChild("Values")
    local ServerTick = Values and Values:FindFirstChild("ServerTick")
    local TickValue = ServerTick and tonumber(ServerTick.Value)

    if not TickValue then
        return nil
    end

    return TickValue - RAGE_PROTOCOL_INT_SALT
end

function GetRageBulletType(Tool)
    if not Tool then return false end

    local Attribute = Tool:GetAttribute("BulletType")

    if type(Attribute) == "string"
        or type(Attribute) == "boolean"
    then
        return Attribute
    end

    local Object = Tool:FindFirstChild("BulletType", true)

    if Object then
        if Object:IsA("StringValue") then
            return Object.Value
        elseif Object:IsA("BoolValue") then
            return Object.Value
        end
    end

    return false
end

function BuildRageBulletTable(Tool, DirectionVector, OriginPosition, HitPosition, UseEndpoint)
    local Count = GetRageBulletsPerShot(Tool)
    local Bullets = table.create(Count)

    local Dir = Vector3.new(0, 0, -1)
    if typeof(DirectionVector) == "Vector3" and DirectionVector.Magnitude > 0.001 then
        Dir = DirectionVector.Unit
    end
    if typeof(OriginPosition) == "Vector3" and typeof(HitPosition) == "Vector3" then
        local Travel = HitPosition - OriginPosition
        if Travel.Magnitude > 0.5 then
            Dir = Travel.Unit
        end
    end

    local BulletVector = Dir * 650
    for Index = 1, Count do
        Bullets[Index] = BulletVector
    end

    return Bullets
end


function GetRageCharacter(Player) return ResolveTrackedCharacter(Player, Player and Player.Character or nil) end

function GetRageRootPart(Character)
    if not Character then return nil end
    return Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
end

function GetRageEvents()
    local Events = ReplicatedStorage:FindFirstChild("Events")
    local Events2 = ReplicatedStorage:FindFirstChild("Events2")
    if not Events then return nil, nil, nil, nil end
    return Events:FindFirstChild("GNX_S"),
        Events:FindFirstChild("ZFKLF__H"),
        Events:FindFirstChild("GNX_R"),
        Events2 and Events2:FindFirstChild("Visualize")
end

-- One shared guard is used by every executed copy of Radiant. This matters
-- because rerunning the script without unloading the previous menu leaves the
-- older RageBot coroutine alive. Both copies can otherwise send GNX_S almost
-- simultaneously and make one cadence slot look like a double shot.
function InstallRageDuplicateShotGuard()
    local Environment = getgenv()
    local State = rawget(Environment, "RadiantRageDuplicateShotGuard")

    if type(State) ~= "table" then
        State = {
            Version = 1,
            Installed = false,
            Window = 0.12,
            LastByTool = setmetatable({}, { __mode = "k" })
        }
        rawset(Environment, "RadiantRageDuplicateShotGuard", State)
    end

    State.Window = 0.12
    State.LastByTool = type(State.LastByTool) == "table"
        and State.LastByTool
        or setmetatable({}, { __mode = "k" })

    local ShotRemote = select(1, GetRageEvents())
    if not ShotRemote then return false end
    State.Remote = ShotRemote

    if State.Installed then
        return true
    end

    if type(hookfunction) ~= "function" then
        return false
    end

    local TemporaryRemote = Instance.new("RemoteEvent")
    local FireServerMethod = TemporaryRemote.FireServer
    TemporaryRemote:Destroy()

    local OldFireServer
    local Success = pcall(function()
        OldFireServer = hookfunction(FireServerMethod, function(Self, ...)
            if Self == State.Remote then
                local Arguments = table.pack(...)
                local Tool = Arguments[3]
                local Marker = Arguments[4]

                if Marker == "FDS9I83"
                    and typeof(Tool) == "Instance"
                    and Tool:IsA("Tool")
                then
                    local Now = os.clock()
                    local Last = State.LastByTool[Tool] or 0

                    if Now - Last < State.Window then
                        return nil
                    end

                    State.LastByTool[Tool] = Now
                end
            end

            return OldFireServer(Self, ...)
        end)
    end)

    State.Installed = Success and OldFireServer ~= nil
    return State.Installed
end

;(function()
    -- Kill any previous FireServer hook from older Radiant runs that swallowed
    -- GNX_S packets (return nil on rate-limit) and prevented ammo/damage.
    local Environment = getgenv()
    local State = rawget(Environment, "RadiantRageDuplicateShotGuard")
    if type(State) == "table" then
        State.Installed = false
        State.Window = 0
        if type(State.LastByTool) == "table" then
            table.clear(State.LastByTool)
        end
    end
end)()

RageNativeEffectsFunction = nil

function GetRageNativeEffects()
    if type(RageNativeEffectsFunction) == "function" then
        return RageNativeEffectsFunction
    end

    local NewModules = ReplicatedStorage:FindFirstChild("NewModules")
    local Client = NewModules and NewModules:FindFirstChild("Client")
    local Services = Client and Client:FindFirstChild("Services")
    local EffectsModule = Services and Services:FindFirstChild("Effects")

    if EffectsModule and EffectsModule:IsA("ModuleScript") then
        local Success, EffectsFunction = pcall(require, EffectsModule)

        if Success and type(EffectsFunction) == "function" then
            RageNativeEffectsFunction = EffectsFunction
            return EffectsFunction
        end
    end

    return nil
end

RageCurrentAmmoNames = {
    "SERVER_Ammo", "Ammo", "CurrentAmmo", "Clip", "Magazine",
    "MagAmmo", "AmmoInMag", "LoadedAmmo", "Bullets"
}

RageStoredAmmoNames = {
    "SERVER_StoredAmmo", "StoredAmmo", "ReserveAmmo", "AmmoReserve",
    "Reserve", "BackupAmmo", "TotalAmmo", "SpareAmmo"
}

function IsRageAmmoValue(Object)
    return Object and (
        Object:IsA("IntValue")
        or Object:IsA("NumberValue")
    )
end

function FindRageAmmoValue(Tool, Names, Stored)
    if not Tool then return nil end

    local Containers = {
        Tool:FindFirstChild("Values"),
        Tool:FindFirstChild("Stats"),
        Tool:FindFirstChild("Configuration"),
        Tool
    }

    for _, Name in ipairs(Names) do
        for _, Container in ipairs(Containers) do
            if Container then
                local Object = Container:FindFirstChild(Name)

                if IsRageAmmoValue(Object) then
                    return Object
                end
            end
        end
    end

    local Lookup = {}
    for Priority, Name in ipairs(Names) do
        Lookup[string.lower(Name)] = Priority
    end

    local Best = nil
    local BestPriority = math.huge

    for _, Object in ipairs(Tool:GetDescendants()) do
        if IsRageAmmoValue(Object) then
            local LowerName = string.lower(Object.Name)
            local Priority = Lookup[LowerName]

            if not Priority and string.find(LowerName, "ammo", 1, true) then
                local IsStoredName =
                    string.find(LowerName, "stored", 1, true)
                    or string.find(LowerName, "reserve", 1, true)
                    or string.find(LowerName, "spare", 1, true)
                    or string.find(LowerName, "backup", 1, true)

                if Stored == (IsStoredName ~= nil) then
                    Priority = 100
                end
            end

            if Priority and Priority < BestPriority then
                Best = Object
                BestPriority = Priority
            end
        end
    end

    return Best
end

function GetRageAmmoValues(Tool, ForceRefresh)
    if not Tool then return nil, nil end

    local CurrentTime = os.clock()
    local Cached = RageReloadState.AmmoCache[Tool]

    if not ForceRefresh
        and Cached
        and CurrentTime - Cached.Time < 1.5
        and (not Cached.Ammo or Cached.Ammo.Parent)
        and (not Cached.Stored or Cached.Stored.Parent)
    then
        return Cached.Ammo, Cached.Stored
    end

    local Ammo = FindRageAmmoValue(Tool, RageCurrentAmmoNames, false)
    local Stored = FindRageAmmoValue(Tool, RageStoredAmmoNames, true)

    RageReloadState.AmmoCache[Tool] = {
        Time = CurrentTime,
        Ammo = Ammo,
        Stored = Stored
    }

    return Ammo, Stored
end

function ReadRageAmmoValue(Object)
    if not IsRageAmmoValue(Object) then return nil end

    local Success, Value = pcall(function()
        return tonumber(Object.Value)
    end)

    return Success and Value or nil
end

function GetRageLocalAmmoValues(Tool)
    if not Tool then return nil, nil end

    local Values = Tool:FindFirstChild("Values")
    if not Values then return nil, nil end

    local Ammo = Values:FindFirstChild("Ammo")
    local Stored = Values:FindFirstChild("StoredAmmo")

    return IsRageAmmoValue(Ammo) and Ammo or nil,
        IsRageAmmoValue(Stored) and Stored or nil
end

function SynchronizeRageLocalAmmo(Tool)
    if not Tool then return false end

    local Values = Tool:FindFirstChild("Values")
    if not Values then return false end

    local LocalAmmo = Values:FindFirstChild("Ammo")
    local LocalStored = Values:FindFirstChild("StoredAmmo")
    local ServerAmmo = Values:FindFirstChild("SERVER_Ammo")
    local ServerStored = Values:FindFirstChild("SERVER_StoredAmmo")

    local Changed = false

    -- This mirrors the gun module's own ComEvent "Sync" handler. It never
    -- invents ammunition; it only copies the replicated server values into
    -- the local values that native Reload() actually checks.
    if IsRageAmmoValue(LocalAmmo) and IsRageAmmoValue(ServerAmmo) then
        local ServerValue = ReadRageAmmoValue(ServerAmmo)
        if ServerValue ~= nil and LocalAmmo.Value ~= ServerValue then
            pcall(function() LocalAmmo.Value = ServerValue end)
            Changed = true
        end
    end

    if IsRageAmmoValue(LocalStored) and IsRageAmmoValue(ServerStored) then
        local ServerValue = ReadRageAmmoValue(ServerStored)
        if ServerValue ~= nil and LocalStored.Value ~= ServerValue then
            pcall(function() LocalStored.Value = ServerValue end)
            Changed = true
        end
    end

    return Changed
end

function IsRageFirearm(Tool)
    if not Tool or not Tool:IsA("Tool") then return false end

    local Ammo = select(1, GetRageAmmoValues(Tool))
    if Ammo then return true end
    if Tool:FindFirstChild("Hitmarker") then return true end
    if Tool:FindFirstChild("Values") and Tool:FindFirstChild("Client", true) then return true end

    return false
end

function FindRageNumber(Container, Names)
    if not Container then return nil end
    for _, Name in ipairs(Names) do
        local Object = Container:FindFirstChild(Name, true)
        if Object and (Object:IsA("NumberValue") or Object:IsA("IntValue")) then return tonumber(Object.Value) end
        local Attribute = Container:GetAttribute(Name)
        if type(Attribute) == "number" then return Attribute end
    end
end

function GetRageNetworkPingSeconds()
    local PingSeconds = 0

    pcall(function()
        if LocalPlayer and type(LocalPlayer.GetNetworkPing) == "function" then
            local Value = tonumber(LocalPlayer:GetNetworkPing())
            if Value and Value >= 0 then
                PingSeconds = math.max(PingSeconds, Value)
            end
        end
    end)

    pcall(function()
        local StatsService = game:GetService("Stats")
        local DataPing = StatsService.Network.ServerStatsItem["Data Ping"]
        local Milliseconds = DataPing and tonumber(DataPing:GetValue())
        if Milliseconds and Milliseconds >= 0 then
            PingSeconds = math.max(PingSeconds, Milliseconds / 1000)
        end
    end)

    return math.clamp(PingSeconds, 0, 1.5)
end

function GetRageShotCadence(Tool)
    return math.clamp(tonumber(RageBotSettings.Delay) or 0.15, 0.01, 0.5)
end

function MuteRageShotSoundsInRoot(Root)
    if not Root or not Root.Parent then return end

    local Objects = { Root }
    local Success, Descendants = pcall(Root.GetDescendants, Root)
    if Success and type(Descendants) == "table" then
        for _, Object in ipairs(Descendants) do
            Objects[#Objects + 1] = Object
        end
    end

    for _, Object in ipairs(Objects) do
        if Object and Object:IsA("Sound") and RageMutedShotSounds[Object] == nil then
            local Volume = tonumber(Object.Volume)
            RageMutedShotSounds[Object] = Volume or 0
            Object.Volume = 0
        end
    end
end

function MuteRageShotSounds(Tool)
    MuteRageShotSoundsInRoot(Tool)

    local ViewModelTool = _G.VM and _G.VM.CloneTool
    if ViewModelTool and ViewModelTool ~= Tool then
        MuteRageShotSoundsInRoot(ViewModelTool)
    end
end

function RestoreRageShotSounds()
    for Sound, Volume in pairs(RageMutedShotSounds) do
        if Sound and Sound.Parent and Sound:IsA("Sound") then
            pcall(function()
                Sound.Volume = Volume
            end)
        end
        RageMutedShotSounds[Sound] = nil
    end
end

function GetRageServerTime()
    local Success, Time = pcall(workspace.GetServerTimeNow, workspace)
    return Success and Time or os.clock()
end

function AlignRageServerTick(Time)
    local TickLength = 1 / math.max(RageBotSettings.ServerTickRate, 20)
    return math.ceil(Time / TickLength) * TickLength
end

function WaitForRageShotSlot(Tool)
    local Now = os.clock()
    local Delay = GetRageShotCadence(Tool)

    if RageShotState.LastTool ~= Tool then
        RageShotState.LastTool = Tool
        RageShotState.NextServerShot = 0
    end

    local Remaining = (tonumber(RageShotState.NextServerShot) or 0) - Now
    if Remaining > 0 then
        task.wait(Remaining)
    end
    if not RageBotEnabled then return false end

    RageShotState.NextServerShot = os.clock() + Delay
    return true
end

function GetRageDamage(Tool, TargetPart)
    local Values = Tool and Tool:FindFirstChild("Values")
    local IsHead = TargetPart and TargetPart.Name == "Head"
    local Names = IsHead and { "HeadshotDamage", "HeadDamage", "HeadDMG", "DamageHead" } or { "Damage", "BaseDamage", "BodyDamage", "DMG" }
    local Damage = FindRageNumber(Values or Tool, Names)
    local Learned = Tool and RageShotState.LearnedDamage[Tool]
    if Learned and Learned > 0 then
        Damage = Damage and Damage * 0.35 + Learned * 0.65 or Learned
    end
    return math.max(tonumber(Damage) or (IsHead and 35 or 20), 1)
end

function GetRageDownedValue(Player)
    local CharStats = ReplicatedStorage:FindFirstChild("CharStats")
    local PlayerStats = Player and CharStats and CharStats:FindFirstChild(Player.Name)
    return PlayerStats and PlayerStats:FindFirstChild("Downed")
end

function IsRageDowned(Player)
    if not Player then return false end
    local Downed = GetRageDownedValue(Player)
    if Downed and Downed.Value == true then return true end

    local Character = GetRageCharacter(Player)
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health > 0 and Humanoid.Health <= 15 then return true end

    local CharacterStats = Character and Character:FindFirstChild("CharStats")
    local CharacterDowned = CharacterStats and CharacterStats:FindFirstChild("Downed")
    return CharacterDowned and CharacterDowned.Value == true or false
end

function GetRageShotsNeeded(Tool, Humanoid, TargetPart)
    if not Humanoid then return 0 end
    return math.max(math.ceil(math.max(Humanoid.Health, 0) / GetRageDamage(Tool, TargetPart)), 1)
end

function IsRageTargetValid(Player, Character, Humanoid)
    if not Player or Player == LocalPlayer or not Character or not Character.Parent or not Humanoid or Humanoid.Health <= 0 or Character:FindFirstChildOfClass("ForceField") then
        return false
    end
    if RageBotSettings.CheckTeam and Player.Team and LocalPlayer.Team and Player.Team == LocalPlayer.Team then return false end
    if RageBotSettings.CheckWhitelist and table.find(WhitelistTable, Player.Name) then return false end
    if IsRageDowned(Player) then return false end
    return true
end

function GetRageTargetPart(Character)
    if not Character then return nil end
    local TargetPart = Character:FindFirstChild(RageBotSettings.TargetPart)
    if TargetPart and TargetPart:IsA("BasePart") then return TargetPart end
    TargetPart = Character:FindFirstChild("Head") or Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("UpperTorso") or Character:FindFirstChild("Torso")
    return TargetPart and TargetPart:IsA("BasePart") and TargetPart or nil
end

function GetRagePredictedPosition(TargetPlayer, TargetCharacter, TargetPart)
    if not TargetPlayer or not TargetCharacter or not TargetPart then return nil end

    local PredictionValue = math.clamp(tonumber(RageBotSettings.Prediction) or 0, 0, 0.45)
    local PositionValue = ResolveCombatPosition(TargetPlayer, TargetCharacter, TargetPart, PredictionValue, RageBotSettings)

    return PositionValue or TargetPart.Position
end


function IsRageSegmentClear(OriginPosition, TargetPosition, TargetCharacter)
    local Direction = TargetPosition - OriginPosition
    local Distance = Direction.Magnitude
    if Distance < 1 then return true end
    local RayParameters = RaycastParams.new()
    RayParameters.FilterType = Enum.RaycastFilterType.Exclude
    RayParameters.FilterDescendantsInstances = { LocalPlayer.Character, TargetCharacter }
    RayParameters.IgnoreWater = true
    return workspace:Raycast(OriginPosition, Direction.Unit * math.min(Distance, 3000), RayParameters) == nil
end

function IsRageWallClear(OriginPosition, TargetPosition, TargetCharacter)
    -- Server-side hit validation uses its own line-of-sight raycast.
    -- Never skip this check: client-only origin spoofing produces visual shots
    -- but the server rejects the damage report.
    return IsRageSegmentClear(OriginPosition, TargetPosition, TargetCharacter)
end

function GetRageCandidate(Player, LocalRoot, CameraObject, UseFOV, FOVOriginPoint)
    if not Player or Player == LocalPlayer then return nil end

    local Character = GetRageCharacter(Player)
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local TargetPart = GetRageTargetPart(Character)

    if not TargetPart
        or not IsRageTargetValid(Player, Character, Humanoid)
    then
        return nil
    end

    local RawPosition = TargetPart.Position
    local CameraPosition = CameraObject and CameraObject.CFrame.Position or LocalRoot.Position
    local WorldDistance = (RawPosition - CameraPosition).Magnitude

    if WorldDistance > RageBotSettings.MaxDistance then
        return nil
    end

    -- Nearest = closest to camera in world space.
    local Score = WorldDistance

    if UseFOV then
        local ScreenPoint, OnScreen =
            CameraObject:WorldToViewportPoint(RawPosition)

        if not OnScreen or ScreenPoint.Z <= 0 then
            return nil
        end

        Score = (
            Vector2.new(ScreenPoint.X, ScreenPoint.Y)
            - FOVOriginPoint
        ).Magnitude

        if Score > RageBotSettings.FOV then
            return nil
        end
    end

    return {
        Player = Player,
        Character = Character,
        Humanoid = Humanoid,
        Part = TargetPart,
        RawPosition = RawPosition,
        Score = Score
    }
end

function IsCachedRageTargetUsable(Player, Character, TargetPart)
    if not Player or not Character or not TargetPart then return false end
    if Player.Parent ~= Players or Character.Parent == nil or TargetPart.Parent == nil then return false end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    return IsRageTargetValid(Player, Character, Humanoid)
end

function ResolveRageCandidateWall(Candidate, OriginPosition)
    if not Candidate then return false end
    if RageBotSettings.MagicBullet then return true end

    local ResolvedPosition = ResolveCombatPosition(
        Candidate.Player,
        Candidate.Character,
        Candidate.Part,
        0,
        RageBotSettings
    ) or Candidate.RawPosition

    return IsRageSegmentClear(
        OriginPosition,
        ResolvedPosition,
        Candidate.Character
    )
end

function FindClosestTargetRage()
    if RadiantAimEngine and type(RadiantAimEngine.AcquireTarget) == "function" then
        return RadiantAimEngine.AcquireTarget()
    end
    return nil, nil, nil
end

RageBotFOVCircle = nil

function UpdateRageBotFOV()
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
        RageBotFOVCircle.NumSides = 48
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

RageNativeGunControllerCache = setmetatable({}, { __mode = "kv" })

function ReadRageConnectionFunction(Connection)
    local Success, FunctionObject = pcall(function()
        return Connection.Function
            or Connection.Callback
            or Connection.Func
    end)

    if Success and type(FunctionObject) == "function" then
        return FunctionObject
    end

    return nil
end

function ReadRageFunctionUpvalues(FunctionObject)
    if type(FunctionObject) ~= "function" then
        return nil
    end

    local BulkReader =
        type(getupvalues) == "function"
        and getupvalues
        or (
            type(debug) == "table"
            and type(debug.getupvalues) == "function"
            and debug.getupvalues
        )

    if BulkReader then
        local Success, Values = pcall(BulkReader, FunctionObject)

        if Success and type(Values) == "table" then
            return Values
        end
    end

    local SingleReader =
        type(getupvalue) == "function"
        and getupvalue
        or (
            type(debug) == "table"
            and type(debug.getupvalue) == "function"
            and debug.getupvalue
        )

    if not SingleReader then
        return nil
    end

    local Values = {}

    for Index = 1, 48 do
        local Success, First, Second =
            pcall(SingleReader, FunctionObject, Index)

        if not Success or (First == nil and Second == nil) then
            break
        end

        Values[Index] =
            Second ~= nil
            and Second
            or First
    end

    return Values
end

function IsRageNativeGunController(Candidate, Tool)
    if Candidate == nil then
        return false
    end

    local Success,
        CandidateTool,
        ReloadFunction,
        EquipFunction,
        UnequipFunction =
        pcall(function()
            return Candidate.Tool,
                Candidate.Reload,
                Candidate.Equip,
                Candidate.Unequip
        end)

    return Success
        and CandidateTool == Tool
        and type(ReloadFunction) == "function"
        and type(EquipFunction) == "function"
        and type(UnequipFunction) == "function"
end

function FindRageControllerInSignal(Signal, Tool)
    if type(getconnections) ~= "function" or not Signal then
        return nil
    end

    local Success, Connections = pcall(getconnections, Signal)

    if not Success or type(Connections) ~= "table" then
        return nil
    end

    for _, Connection in pairs(Connections) do
        local FunctionObject =
            ReadRageConnectionFunction(Connection)

        local Upvalues =
            ReadRageFunctionUpvalues(FunctionObject)

        if type(Upvalues) == "table" then
            for _, Candidate in pairs(Upvalues) do
                if IsRageNativeGunController(
                    Candidate,
                    Tool
                ) then
                    return Candidate
                end
            end
        end
    end

    return nil
end

function FindRageControllerInGarbageCollector(Tool)
    if type(getgc) ~= "function" then
        return nil
    end

    local Success, Objects = pcall(getgc, true)
    if not Success or type(Objects) ~= "table" then
        return nil
    end

    local FunctionCandidates = {}
    local Checked = 0

    for _, Object in pairs(Objects) do
        Checked = Checked + 1

        if IsRageNativeGunController(Object, Tool) then
            return Object
        end

        if type(Object) == "function" then
            FunctionCandidates[#FunctionCandidates + 1] = Object
        end

        if Checked % 512 == 0 then
            task.wait()
        end
    end

    for Index, FunctionObject in ipairs(FunctionCandidates) do
        local Upvalues = ReadRageFunctionUpvalues(FunctionObject)
        if type(Upvalues) == "table" then
            for _, Candidate in pairs(Upvalues) do
                if IsRageNativeGunController(Candidate, Tool) then
                    return Candidate
                end
            end
        end

        if Index % 256 == 0 then
            task.wait()
        end
    end

    return nil
end

function GetRageNativeGunController(Tool, ForceRefresh)
    if not Tool then
        return nil
    end

    if not ForceRefresh then
        local Cached = RageNativeGunControllerCache[Tool]

        if IsRageNativeGunController(Cached, Tool) then
            return Cached
        end
    end

    local Signals = {
        Tool.Equipped,
        Tool.Unequipped,
        Tool.Activated,
        Tool.Deactivated,
        UserInputService.InputBegan
    }

    local Controller = nil

    for _, Signal in ipairs(Signals) do
        Controller = FindRageControllerInSignal(Signal, Tool)
        if Controller then
            break
        end
    end

    if not Controller and ForceRefresh then
        Controller = FindRageControllerInGarbageCollector(Tool)
    end

    if Controller then
        RageNativeGunControllerCache[Tool] = Controller
    end

    return Controller
end

function GetRageNativeReloadState(Controller)
    if not Controller then return nil end

    local Success, Reload = pcall(function()
        return Controller.Reload
    end)

    if not Success or type(Reload) ~= "function" then
        return nil
    end

    local Upvalues = ReadRageFunctionUpvalues(Reload)
    if type(Upvalues) ~= "table" then return nil end

    for _, Candidate in pairs(Upvalues) do
        if type(Candidate) == "table" then
            local StateSuccess, ReloadDB, ReloadFinishing, CantCancel = pcall(function()
                return Candidate.reloadDB,
                    Candidate.reloadFinishing,
                    Candidate.cantCancelReload
            end)

            if StateSuccess
                and (ReloadDB ~= nil
                    or ReloadFinishing ~= nil
                    or CantCancel ~= nil)
            then
                return Candidate
            end
        end
    end

    return nil
end

function CallRageNativeReload(Tool)
    local Controller = GetRageNativeGunController(Tool)

    if not Controller then
        Controller = GetRageNativeGunController(Tool, true)
    end

    if not Controller then
        return false
    end

    local InternalState = GetRageNativeReloadState(Controller)
    local Success = pcall(function()
        local Reload = Controller.Reload
        if type(Reload) ~= "function" then
            error("native reload method missing")
        end
        Reload()
    end)

    if not Success then
        RageNativeGunControllerCache[Tool] = nil
        return false
    end

    -- pcall only proves the function did not throw. Native Reload() has many
    -- early returns, so verify its internal reloadDB flag when available.
    if InternalState then
        local StateSuccess, Started = pcall(function()
            return InternalState.reloadDB == true
                or InternalState.reloadFinishing == true
        end)

        if StateSuccess then
            return Started
        end
    end

    return true
end

function ResetRageReloadState(Tool)
    RageReloadState.Tool = Tool
    RageReloadState.StartedAt = 0
    RageReloadState.LastRequest = 0
    RageReloadState.LastProgressAt = 0
    RageReloadState.PreviousAmmo = nil
    RageReloadState.LastAmmo = nil
    RageReloadState.LastStored = nil
    RageReloadState.InProgress = false
    RageReloadState.Attempts = 0
    RageReloadState.LastStartRequest = 0
end

function PulseRageReloadKey()
    local CurrentTime = os.clock()

    if CurrentTime - RageReloadState.LastKeyPress < 0.65 then
        return false
    end

    RageReloadState.LastKeyPress = CurrentTime
    return SendKeyPress(Enum.KeyCode.R, 0.09)
end

function GetRageReloadNumber(Tool, Names)
    if not Tool then return nil end

    for _, Name in ipairs(Names) do
        local Attribute = Tool:GetAttribute(Name)

        if type(Attribute) == "number" then
            return tonumber(Attribute)
        end

        local Object = Tool:FindFirstChild(Name, true)

        if Object and (
            Object:IsA("NumberValue")
            or Object:IsA("IntValue")
        ) then
            return tonumber(Object.Value)
        end
    end

    local Config = GetRageWeaponConfig(Tool)

    if type(Config) == "table" then
        for _, Name in ipairs(Names) do
            if type(Config[Name]) == "number" then
                return tonumber(Config[Name])
            end
        end
    end

    return nil
end

function GetRageMagazineSize(Tool)
    return GetRageReloadNumber(
        Tool,
        {
            "MagSize",
            "MagazineSize",
            "ClipSize",
            "MaxAmmo",
            "AmmoCapacity"
        }
    )
end

function GetRageReloadDuration(Tool)
    local Duration = GetRageReloadNumber(
        Tool,
        {
            "ReloadTime",
            "ReloadDuration",
            "ShellInTime"
        }
    )

    return math.clamp(
        tonumber(Duration) or 2.52,
        0.45,
        10
    )
end

function GetRageReloadingValue(Tool)
    if not Tool then return nil end

    for _, Name in ipairs({
        "Reloading",
        "IsReloading",
        "reloadDB",
        "ReloadDB"
    }) do
        local Object = Tool:FindFirstChild(Name, true)

        if Object and Object:IsA("BoolValue") then
            return Object.Value
        end

        local Attribute = Tool:GetAttribute(Name)

        if type(Attribute) == "boolean" then
            return Attribute
        end
    end

    return nil
end

function BuildRageReloadData(AmmoValue, StoredValue)
    return {
        ammo = tonumber(AmmoValue) or 0,
        storedAmmo = tonumber(StoredValue) or 0
    }
end

function SendRageReloadStart(
    ReloadEvent,
    Tool,
    AmmoValue,
    StoredValue
)
    if not ReloadEvent or not Tool then return false end
    local Timestamp = type(GetRageProtocolTimestamp) == "function"
        and GetRageProtocolTimestamp(Tool)
        or tick()
    return pcall(function()
        ReloadEvent:FireServer(Timestamp, "STZNRD", Tool, nil, nil)
    end)
end

function SendRageReload(
    ReloadEvent,
    Tool,
    AmmoValue,
    StoredValue
)
    if not (RageBotSettings.AutoReload or RageBotSettings.InstantReload)
        or not Tool
        or not Tool.Parent
    then
        return false
    end

    local Stored = tonumber(StoredValue)
    if Stored ~= nil and Stored <= 0 then
        return false
    end

    ReloadEvent = ReloadEvent
        or (
            ReplicatedStorage:FindFirstChild("Events")
            and ReplicatedStorage.Events:FindFirstChild("GNX_R")
        )

    if not ReloadEvent then
        return false
    end

    local CurrentTime = os.clock()
    local MinimumInterval = RageBotSettings.InstantReload and 0.035 or 0.10
    if CurrentTime - RageReloadState.LastRequest < MinimumInterval then
        return false
    end

    local Requested = pcall(function()
        ReloadEvent:FireServer(
            tick(),
            "KLWE89U0",
            Tool
        )
    end)

    if Requested then
        RageReloadState.LastStartRequest = CurrentTime
        RageReloadState.LastRequest = CurrentTime
        RageReloadState.Attempts += 1
    end

    return Requested
end

function UpdateRageReload(Tool)
    if RageReloadState.Tool ~= Tool then
        ResetRageReloadState(Tool)
    end

    if not (RageBotSettings.AutoReload or RageBotSettings.InstantReload)
        or not Tool
        or not Tool.Parent
    then
        return false
    end

    local ServerAmmo, StoredAmmo = GetRageAmmoValues(Tool)
    local AmmoValue = ReadRageAmmoValue(ServerAmmo)
    local StoredValue = ReadRageAmmoValue(StoredAmmo)

    if AmmoValue == nil then
        ServerAmmo, StoredAmmo = GetRageAmmoValues(Tool, true)
        AmmoValue = ReadRageAmmoValue(ServerAmmo)
        StoredValue = ReadRageAmmoValue(StoredAmmo)
    end

    if AmmoValue == nil or (StoredValue ~= nil and StoredValue <= 0) then
        RageReloadState.LastAmmo = AmmoValue
        RageReloadState.LastStored = StoredValue
        RageReloadState.InProgress = false
        return false
    end

    local PreviousAmmo = RageReloadState.LastAmmo
    local PreviousStored = RageReloadState.LastStored
    local AmmoChanged = PreviousAmmo ~= nil and AmmoValue ~= PreviousAmmo
    local StoredChanged = PreviousStored ~= nil and StoredValue ~= PreviousStored
    local Empty = AmmoValue <= 0
    local ShouldRequest = false

    if RageBotSettings.InstantReload then
        ShouldRequest = PreviousAmmo == nil
            or AmmoChanged
            or StoredChanged
            or (Empty and os.clock() - RageReloadState.LastRequest >= 0.12)
    elseif RageBotSettings.AutoReload then
        ShouldRequest = Empty
    end

    RageReloadState.LastAmmo = AmmoValue
    RageReloadState.LastStored = StoredValue
    RageReloadState.PreviousAmmo = PreviousAmmo

    if ShouldRequest then
        local UnusedStart, UnusedFinish, ReloadEvent = GetRageEvents()
        if SendRageReload(ReloadEvent, Tool, AmmoValue, StoredValue) then
            RageReloadState.InProgress = Empty
            RageReloadState.StartedAt = RageReloadState.StartedAt > 0 and RageReloadState.StartedAt or os.clock()
            RageReloadState.LastProgressAt = os.clock()
        end
    elseif AmmoChanged then
        RageReloadState.LastProgressAt = os.clock()
    end

    if not Empty then
        RageReloadState.InProgress = false
        RageReloadState.StartedAt = 0
        return false
    end

    return true
end

function ClampRageHitPositionToPart(TargetPart, DesiredPosition)
    if not TargetPart or not TargetPart:IsA("BasePart") then return DesiredPosition end

    local HalfSize = TargetPart.Size * 0.5
    local Margin = Vector3.new(
        math.min(HalfSize.X * 0.08, 0.08),
        math.min(HalfSize.Y * 0.08, 0.08),
        math.min(HalfSize.Z * 0.08, 0.08)
    )

    local Limit = Vector3.new(
        math.max(HalfSize.X - Margin.X, 0.04),
        math.max(HalfSize.Y - Margin.Y, 0.04),
        math.max(HalfSize.Z - Margin.Z, 0.04)
    )

    local LocalPosition = TargetPart.CFrame:PointToObjectSpace(
        typeof(DesiredPosition) == "Vector3" and DesiredPosition or TargetPart.Position
    )

    LocalPosition = Vector3.new(
        math.clamp(LocalPosition.X, -Limit.X, Limit.X),
        math.clamp(LocalPosition.Y, -Limit.Y, Limit.Y),
        math.clamp(LocalPosition.Z, -Limit.Z, Limit.Z)
    )

    return TargetPart.CFrame:PointToWorldSpace(LocalPosition)
end


RageBotAPI = RageBotAPI or {}

function GetRageMagicRegistrationKey(TargetPart, SamplePoint)
    if not TargetPart or typeof(SamplePoint) ~= "Vector3" then return nil end
    local LocalOffset = TargetPart.CFrame:PointToObjectSpace(SamplePoint)
    local Scale = 4
    return table.concat({
        TargetPart.Name,
        math.floor(LocalOffset.X * Scale + 0.5),
        math.floor(LocalOffset.Y * Scale + 0.5),
        math.floor(LocalOffset.Z * Scale + 0.5)
    }, ":")
end

function GetRageMagicRegistrationEntry(Character, Key, Create)
    if not Character or not Key then return nil end
    local CharacterCache = RageMagicRegistrationState.Cache[Character]
    if not CharacterCache and Create then
        CharacterCache = {}
        RageMagicRegistrationState.Cache[Character] = CharacterCache
    end
    if not CharacterCache then return nil end
    local Entry = CharacterCache[Key]
    if not Entry and Create then
        Entry = { ConfirmedAt = 0, Failures = 0, RejectedUntil = 0 }
        CharacterCache[Key] = Entry
    end
    return Entry
end

function MarkRageMagicRegistrationConfirmed(Character, Key)
    local Entry = GetRageMagicRegistrationEntry(Character, Key, true)
    if not Entry then return end
    Entry.ConfirmedAt = os.clock()
    Entry.Failures = 0
    Entry.RejectedUntil = 0
    if RadiantAimEngine and RadiantAimEngine.State and Character then
        local Cache = RadiantAimEngine.State.RouteCache[Character]
        if Cache then Cache.Time = os.clock() end
    end
end

function MarkRageMagicRegistrationFailed(Character, Key)
    local Entry = GetRageMagicRegistrationEntry(Character, Key, true)
    if not Entry then return end
    Entry.Failures = (tonumber(Entry.Failures) or 0) + 1
    local Delay = math.min(
        (tonumber(RageMagicRegistrationState.RejectBaseTime) or 0.45) * Entry.Failures,
        tonumber(RageMagicRegistrationState.RejectMaximumTime) or 2.5
    )
    Entry.RejectedUntil = os.clock() + Delay
    if RadiantAimEngine and type(RadiantAimEngine.ClearWallbangCache) == "function" and Character then
        RadiantAimEngine.ClearWallbangCache(Character)
    end
end

function GetRageMagicProbeEntry(Character, Create)
    if not Character then return nil end
    local Entry = RageMagicProbeState.Cache[Character]
    if not Entry and Create then
        Entry = {
            Failures = 0,
            BlockedUntil = 0,
            Origin = nil,
            TargetPosition = nil
        }
        RageMagicProbeState.Cache[Character] = Entry
    end
    return Entry
end

function IsRageMagicProbeBlocked(Character, Origin, TargetPosition)
    local Entry = GetRageMagicProbeEntry(Character, false)
    if not Entry then return false end
    local CurrentTime = os.clock()
    if CurrentTime >= (tonumber(Entry.BlockedUntil) or 0) then
        return false
    end

    local OriginMoved = typeof(Origin) == "Vector3"
        and typeof(Entry.Origin) == "Vector3"
        and (Origin - Entry.Origin).Magnitude > (tonumber(RageMagicProbeState.OriginTolerance) or 6)
    local TargetMoved = typeof(TargetPosition) == "Vector3"
        and typeof(Entry.TargetPosition) == "Vector3"
        and (TargetPosition - Entry.TargetPosition).Magnitude > (tonumber(RageMagicProbeState.TargetTolerance) or 2.5)

    if OriginMoved or TargetMoved then
        Entry.BlockedUntil = 0
        Entry.Failures = 0
        return false
    end

    return true
end

function MarkRageMagicProbeConfirmed(Character)
    local Entry = GetRageMagicProbeEntry(Character, true)
    if not Entry then return end
    Entry.Failures = 0
    Entry.BlockedUntil = 0
    Entry.Origin = nil
    Entry.TargetPosition = nil
end

function MarkRageMagicProbeFailed(Character, Origin, TargetPosition)
    local Entry = GetRageMagicProbeEntry(Character, true)
    if not Entry then return end
    Entry.Failures = (tonumber(Entry.Failures) or 0) + 1
    local Delay = math.min(
        (tonumber(RageMagicProbeState.FailureCooldown) or 2.5) * Entry.Failures,
        tonumber(RageMagicProbeState.MaximumCooldown) or 8
    )
    Entry.BlockedUntil = os.clock() + Delay
    Entry.Origin = typeof(Origin) == "Vector3" and Origin or nil
    Entry.TargetPosition = typeof(TargetPosition) == "Vector3" and TargetPosition or nil
end

RageShotState.ClearPending = function()
    RageShotState.PendingTarget = nil
    RageShotState.PendingCharacter = nil
    RageShotState.PendingHumanoid = nil
    RageShotState.PendingTool = nil
    RageShotState.PendingPart = nil
    RageShotState.PendingKey = nil
    RageShotState.PendingHealth = nil
    RageShotState.PendingTime = 0
    RageShotState.PendingDeadline = 0
    RageShotState.PendingLineOfSight = false
    RageShotState.PendingMode = nil
    RageShotState.PendingRegistrationKey = nil
    RageShotState.PendingOrigin = nil
    RageShotState.PendingAim = nil
    RageShotState.PendingHitPosition = nil
end

RageShotState.GetConfirmationWindow = function(Distance)
    local Ping = 0
    local Success, Value = pcall(function()
        return LocalPlayer:GetNetworkPing()
    end)
    if Success and type(Value) == "number" then
        Ping = math.clamp(Value, 0, 0.5)
    end
    local RangeDelay = math.clamp((tonumber(Distance) or 0) / 2600, 0, 0.38)
    return math.clamp(
        math.max(tonumber(RageBotSettings.ConfirmationWindow) or 0.28, 0.20 + Ping * 2.8 + RangeDelay),
        0.28,
        1.20
    )
end

function IsRageMagicPathMode(Mode)
    return Mode == "magic_wallbang"
        or Mode == "magic_trajectory"
        or Mode == "magic_vertical"
        or Mode == "magic_ghost"
end


RageShotState.ConfirmDamage = function(Player, Damage)
    if not Player or RageShotState.PendingTarget ~= Player then
        return false
    end

    local Tool = RageShotState.PendingTool
    local PendingCharacter = RageShotState.PendingCharacter
    local PendingRegistrationKey = RageShotState.PendingRegistrationKey
    local PendingMode = RageShotState.PendingMode
    local NumericDamage = tonumber(Damage) or 0
    if Tool and NumericDamage > 0 then
        local Previous = tonumber(RageShotState.LearnedDamage[Tool]) or 0
        RageShotState.LearnedDamage[Tool] = Previous > 0 and Previous * 0.72 + NumericDamage * 0.28 or NumericDamage
    end

    RageShotState.TargetFailures[Player] = 0
    RageShotState.TargetBackoff[Player] = 0

    if IsRageMagicPathMode(PendingMode) and PendingCharacter then
        if PendingRegistrationKey then
            MarkRageMagicRegistrationConfirmed(PendingCharacter, PendingRegistrationKey)
        end
        MarkRageMagicProbeConfirmed(PendingCharacter)
        if RadiantAimEngine and RadiantAimEngine.State and RadiantAimEngine.State.RelayCooldown then
            RadiantAimEngine.State.RelayCooldown[PendingCharacter] = nil
        end
    end

    local Fail = RageBotAPI._MagicFail
    if type(Fail) == "table" and Fail.LastTarget == Player then
        Fail.Count = 0
        Fail.PartIndex = 1
    end

    RageShotState.ClearPending()
    return true
end

RageShotState.UpdatePending = function()
    local Player = RageShotState.PendingTarget
    if not Player then
        return true
    end

    local Character = RageShotState.PendingCharacter
    local Humanoid = RageShotState.PendingHumanoid
    local CurrentTime = os.clock()

    if not RageBotEnabled
        or not Player.Parent
        or not Character
        or not Character.Parent
        or not Humanoid
        or not Humanoid.Parent
        or Humanoid.Health <= 0
        or IsRageDowned(Player)
    then
        RageShotState.ClearPending()
        return true
    end

    local HealthBefore = tonumber(RageShotState.PendingHealth)
    local CurrentHealth = tonumber(Humanoid.Health)
    if HealthBefore and CurrentHealth and CurrentHealth < HealthBefore - 0.05 then
        RageShotState.ConfirmDamage(Player, HealthBefore - CurrentHealth)
        return true
    end

    if CurrentTime < (tonumber(RageShotState.PendingDeadline) or 0) then
        if IsRageMagicPathMode(RageShotState.PendingMode) then
            return false
        end
        local Cadence = RageShotState.PendingTool
            and GetRageShotCadence(RageShotState.PendingTool)
            or 0.15
        local MinimumWait = math.max(0.085, Cadence * 0.88)
        if CurrentTime - (tonumber(RageShotState.PendingTime) or 0) >= MinimumWait then
            return true
        end
        return false
    end

    if IsRageMagicPathMode(RageShotState.PendingMode) and RageShotState.PendingCharacter then
        if RageShotState.PendingRegistrationKey then
            MarkRageMagicRegistrationFailed(
                RageShotState.PendingCharacter,
                RageShotState.PendingRegistrationKey
            )
        end
        MarkRageMagicProbeFailed(
            RageShotState.PendingCharacter,
            RageShotState.PendingOrigin,
            RageShotState.PendingPart and RageShotState.PendingPart.Position or RageShotState.PendingHitPosition
        )
        if (RageShotState.PendingMode == "magic_trajectory" or RageShotState.PendingMode == "magic_vertical")
            and RadiantAimEngine
            and RadiantAimEngine.State
            and RadiantAimEngine.State.RelayCooldown
        then
            RadiantAimEngine.State.RelayCooldown[RageShotState.PendingCharacter] =
                os.clock() + math.max(tonumber(RadiantAimEngine.Config.TrajectoryRelayFailureCooldown) or 0.85, 0.25)
        end
        if RadiantAimEngine and type(RadiantAimEngine.ClearWallbangCache) == "function" then
            RadiantAimEngine.ClearWallbangCache(RageShotState.PendingCharacter)
        end
    end

    local Failures = (tonumber(RageShotState.TargetFailures[Player]) or 0) + 1
    RageShotState.TargetFailures[Player] = Failures
    RageShotState.TargetBackoff[Player] = CurrentTime + 0.02

    local Fail = RageBotAPI._MagicFail
    if type(Fail) ~= "table" then
        Fail = { Count = 0, PartIndex = 1, LastTarget = nil }
        RageBotAPI._MagicFail = Fail
    end
    Fail.LastTarget = Player
    Fail.Count = Failures
    Fail.PartIndex = (tonumber(Fail.PartIndex) or 1) + 1

    RageShotState.ClearPending()
    return false
end

RageShotState.MarkPathFailure = function(Player)
    if not Player then return end
    local CurrentTime = os.clock()
    if CurrentTime < (tonumber(RageShotState.TargetBackoff[Player]) or 0) then return end

    local Failures = (tonumber(RageShotState.TargetFailures[Player]) or 0) + 1
    RageShotState.TargetFailures[Player] = Failures
    RageShotState.TargetBackoff[Player] = CurrentTime + math.min(0.035 + Failures * 0.035, 0.22)

    local Fail = RageBotAPI._MagicFail
    if type(Fail) ~= "table" then
        Fail = { Count = 0, PartIndex = 1, LastTarget = nil }
        RageBotAPI._MagicFail = Fail
    end
    Fail.LastTarget = Player
    Fail.Count = Failures
    Fail.PartIndex = (tonumber(Fail.PartIndex) or 1) + 1
end


RadiantAimEngine = {}
RadiantAimEngine.Version = "RadiantMagicEngine-2.3-RegistrationSafe"
RadiantAimEngine._Fail = {}
RadiantAimEngine._ActiveTool = nil
RadiantAimEngine.MagicCache = {}
RadiantAimEngine.WallbangCache = {}
RadiantAimEngine.Config = {
    CandidateBudget = 120,
    TraceBudget = 64,
    ValidRouteLimit = 18,
    MagicPartLimit = 3,
    MagicPointLimit = 3,
    MagicSampleLimit = 8,
    CacheCandidateBudget = 18,
    CacheLifetime = 0.24,
    CacheOriginTolerance = 5.5,
    CacheTargetTolerance = 2.5,
    BlockerScanLimit = 12,
    MaximumOriginShift = 168,
    PreferredOriginShift = 72,
    OriginClearance = 0.62,
    OriginProbeSize = 0.42,
    TargetScanInterval = 0.065,
    TargetWallChecks = 4,
    HitboxInset = 0.10,
    MaximumPrediction = 2.65,
    MinimumPrediction = 0.04,
    ConfirmedBonus = 560,
    RejectedPenalty = 340,
    FailurePenalty = 54,
    ReportDelayMaximum = 0.060,
    TrajectoryRelayMaximumShift = 168,
    TrajectoryRelayFailureCooldown = 0.72,
    VerticalMinimumDelta = 4.5,
    VerticalRatioThreshold = 0.52,
    VerticalProbeSize = 0.22,
    VerticalOriginClearance = 0.26,
    VerticalTraceBudget = 104,
    VerticalValidRouteLimit = 26,
    VerticalCandidateLimit = 78,
    VerticalTargetGap = 0.24,
}
RadiantAimEngine.State = {
    RouteCache = setmetatable({}, { __mode = "k" }),
    Motion = setmetatable({}, { __mode = "k" }),
    Target = { Time = 0, Player = nil, Character = nil, Part = nil },
    RelayCooldown = setmetatable({}, { __mode = "k" }),
    Generation = 0,
    Sequence = 0,
}

function RadiantAimEngine.IsVector(Value)
    return typeof(Value) == "Vector3"
        and Value.X == Value.X
        and Value.Y == Value.Y
        and Value.Z == Value.Z
end

function RadiantAimEngine.MakeRayParams()
    local Parameters = RaycastParams.new()
    Parameters.FilterType = Enum.RaycastFilterType.Exclude
    Parameters.IgnoreWater = true
    local Filter = {}
    if LocalPlayer.Character then Filter[#Filter + 1] = LocalPlayer.Character end
    local Camera = workspace.CurrentCamera
    if Camera then Filter[#Filter + 1] = Camera end
    Parameters.FilterDescendantsInstances = Filter
    return Parameters
end

function RadiantAimEngine.MakeOverlapParams(TargetCharacter)
    local Parameters = OverlapParams.new()
    Parameters.FilterType = Enum.RaycastFilterType.Exclude
    Parameters.MaxParts = 24
    local Filter = {}
    if LocalPlayer.Character then Filter[#Filter + 1] = LocalPlayer.Character end
    if TargetCharacter then Filter[#Filter + 1] = TargetCharacter end
    local Camera = workspace.CurrentCamera
    if Camera then Filter[#Filter + 1] = Camera end
    Parameters.FilterDescendantsInstances = Filter
    return Parameters
end

function RadiantAimEngine.GetParts(Character, Preferred)
    local Result, Seen = {}, {}
    local function Add(Part)
        if Part and Part:IsA("BasePart") and Part.Parent and not Seen[Part] then
            Seen[Part] = true
            Result[#Result + 1] = Part
        end
    end
    Add(Preferred)
    if Character then
        for _, Name in ipairs({
            "Head", "UpperTorso", "Torso", "LowerTorso",
            "LeftUpperArm", "RightUpperArm", "LeftArm", "RightArm",
            "LeftUpperLeg", "RightUpperLeg", "LeftLeg", "RightLeg"
        }) do
            Add(Character:FindFirstChild(Name))
        end
    end
    return Result
end

function RadiantAimEngine.GetPartWeight(Part)
    if not Part then return 0 end
    if Part.Name == "Head" then return 112 end
    if Part.Name == "UpperTorso" or Part.Name == "Torso" then return 92 end
    if Part.Name == "LowerTorso" then return 76 end
    if string.find(Part.Name, "Arm") then return 50 end
    if string.find(Part.Name, "Leg") then return 42 end
    return 30
end

function RadiantAimEngine.ClampPoint(Part, Point, Expansion)
    if not Part or not Part:IsA("BasePart") then return Point end
    local Half = Part.Size * 0.5
    local Inset = tonumber(RadiantAimEngine.Config.HitboxInset) or 0.10
    local Extra = tonumber(Expansion) or 0
    local Limit = Vector3.new(
        math.max(Half.X - Inset + Extra, 0.04),
        math.max(Half.Y - Inset + Extra, 0.04),
        math.max(Half.Z - Inset + Extra, 0.04)
    )
    local Source = RadiantAimEngine.IsVector(Point) and Point or Part.Position
    local LocalPoint = Part.CFrame:PointToObjectSpace(Source)
    LocalPoint = Vector3.new(
        math.clamp(LocalPoint.X, -Limit.X, Limit.X),
        math.clamp(LocalPoint.Y, -Limit.Y, Limit.Y),
        math.clamp(LocalPoint.Z, -Limit.Z, Limit.Z)
    )
    return Part.CFrame:PointToWorldSpace(LocalPoint)
end

function RadiantAimEngine.GetMotionPrediction(Player, Character, Part, Origin)
    local CurrentTime = os.clock()
    local Position = Part.Position
    local Stored = RadiantAimEngine.State.Motion[Part]
    local Velocity = Part.AssemblyLinearVelocity or Vector3.new(0, 0, 0)
    if Stored and RadiantAimEngine.IsVector(Stored.Position) and CurrentTime > (Stored.Time or 0) then
        local DeltaTime = math.clamp(CurrentTime - Stored.Time, 1 / 240, 0.22)
        local Measured = (Position - Stored.Position) / DeltaTime
        if Measured.Magnitude <= 190 then
            local PreviousVelocity = RadiantAimEngine.IsVector(Stored.Velocity) and Stored.Velocity or Velocity
            Velocity = PreviousVelocity * 0.44 + Velocity * 0.32 + Measured * 0.24
        end
    end
    RadiantAimEngine.State.Motion[Part] = { Position = Position, Time = CurrentTime, Velocity = Velocity }
    local Distance = (Position - Origin).Magnitude
    local Ping = GetRageNetworkPingSeconds()
    local LeadTime = math.clamp(Ping * 0.82 + Distance / 10500, 0, 0.18)
    local Lead = Velocity * LeadTime
    local Maximum = math.clamp((tonumber(RadiantAimEngine.Config.MaximumPrediction) or 2.65) + Distance / 2200, 0.45, 3.8)
    if Lead.Magnitude > Maximum then Lead = Lead.Unit * Maximum end
    if Lead.Magnitude < (tonumber(RadiantAimEngine.Config.MinimumPrediction) or 0.04) then Lead = Vector3.new(0, 0, 0) end
    return Position + Lead, Lead
end

function RadiantAimEngine.BuildHitPoints(Part, PredictedCenter)
    local Half = Part.Size * 0.5
    local Safe = Vector3.new(
        math.max(Half.X - 0.12, 0.04),
        math.max(Half.Y - 0.12, 0.04),
        math.max(Half.Z - 0.12, 0.04)
    )
    local Shift = RadiantAimEngine.IsVector(PredictedCenter) and PredictedCenter - Part.Position or Vector3.new(0, 0, 0)
    local Pattern = {
        Vector3.new(0, 0, 0),
        Vector3.new(0.52, 0, 0), Vector3.new(-0.52, 0, 0),
        Vector3.new(0, 0.52, 0), Vector3.new(0, -0.52, 0),
        Vector3.new(0, 0, 0.52), Vector3.new(0, 0, -0.52),
        Vector3.new(0.36, 0.36, 0), Vector3.new(-0.36, 0.36, 0),
        Vector3.new(0.36, -0.36, 0), Vector3.new(-0.36, -0.36, 0),
        Vector3.new(0.30, 0, 0.30), Vector3.new(-0.30, 0, -0.30),
    }
    local Points = table.create(#Pattern)
    for Index, Unit in ipairs(Pattern) do
        local LocalPoint = Vector3.new(Unit.X * Safe.X, Unit.Y * Safe.Y, Unit.Z * Safe.Z)
        Points[Index] = RadiantAimEngine.ClampPoint(Part, Part.CFrame:PointToWorldSpace(LocalPoint) + Shift, 0)
    end
    return Points
end

function RadiantAimEngine.GetBasis(Origin, Target)
    local Forward = Target - Origin
    if Forward.Magnitude <= 0.001 then Forward = Vector3.new(0, 0, -1) else Forward = Forward.Unit end
    local Reference = math.abs(Forward.Y) > 0.94 and Vector3.new(1, 0, 0) or Vector3.new(0, 1, 0)
    local Right = Forward:Cross(Reference)
    if Right.Magnitude <= 0.001 then Right = Vector3.new(1, 0, 0) else Right = Right.Unit end
    local Up = Right:Cross(Forward)
    if Up.Magnitude <= 0.001 then Up = Vector3.new(0, 1, 0) else Up = Up.Unit end
    return Forward, Right, Up
end

function RadiantAimEngine.SegmentPartInterval(Origin, Destination, Part, Expansion)
    if not Part or not Part:IsA("BasePart") then return false, nil, nil end
    local LocalOrigin = Part.CFrame:PointToObjectSpace(Origin)
    local LocalDelta = Part.CFrame:VectorToObjectSpace(Destination - Origin)
    local Extra = tonumber(Expansion) or 0
    local Half = Part.Size * 0.5 + Vector3.new(Extra, Extra, Extra)
    local Minimum, Maximum = 0, 1
    local function Clip(Offset, Delta, Extent)
        if math.abs(Delta) <= 1e-7 then
            return math.abs(Offset) <= Extent, Minimum, Maximum
        end
        local First = (-Extent - Offset) / Delta
        local Second = (Extent - Offset) / Delta
        if First > Second then First, Second = Second, First end
        local NewMinimum = math.max(Minimum, First)
        local NewMaximum = math.min(Maximum, Second)
        return NewMinimum <= NewMaximum, NewMinimum, NewMaximum
    end
    local Valid
    Valid, Minimum, Maximum = Clip(LocalOrigin.X, LocalDelta.X, Half.X)
    if not Valid then return false, nil, nil end
    Valid, Minimum, Maximum = Clip(LocalOrigin.Y, LocalDelta.Y, Half.Y)
    if not Valid then return false, nil, nil end
    Valid, Minimum, Maximum = Clip(LocalOrigin.Z, LocalDelta.Z, Half.Z)
    if not Valid then return false, nil, nil end
    if Maximum < 0 or Minimum > 1 then return false, nil, nil end
    return true, math.clamp(Minimum, 0, 1), math.clamp(Maximum, 0, 1)
end

function RadiantAimEngine.ResolveCharacterHitPart(Character, Instance)
    if not Character or not Instance or not Instance:IsDescendantOf(Character) then return nil end
    local Current = Instance
    while Current and Current.Parent and Current.Parent ~= Character do
        Current = Current.Parent
    end
    if Current and Current:IsA("BasePart") and Current.Name ~= "HumanoidRootPart" then return Current end
    return nil
end

function RadiantAimEngine.TraceToTarget(Origin, HitPosition, TargetCharacter, TargetPart, Parameters)
    local Delta = HitPosition - Origin
    local Distance = Delta.Magnitude
    if Distance <= 0.05 then return nil end
    local Intersects, Entry = RadiantAimEngine.SegmentPartInterval(Origin, HitPosition, TargetPart, 0.03)
    local TargetDistance = Intersects and Distance * (Entry or 1) or Distance
    local Result = workspace:Raycast(Origin, Delta.Unit * (Distance + 1.25), Parameters)
    if not Result then
        return {
            Clear = Intersects,
            Kind = Intersects and "geometric" or "miss",
            Distance = Distance,
            TargetDistance = TargetDistance,
            Hit = nil,
            ResolvedPart = Intersects and TargetPart or nil,
            ResolvedPosition = Intersects and HitPosition or nil,
        }
    end
    local ResultDistance = (Result.Position - Origin).Magnitude
    local ResolvedPart = RadiantAimEngine.ResolveCharacterHitPart(TargetCharacter, Result.Instance)
    local IsTarget = ResolvedPart ~= nil
    if IsTarget or ResultDistance >= TargetDistance - 0.10 then
        return {
            Clear = true,
            Kind = IsTarget and "target" or "geometric",
            Distance = Distance,
            TargetDistance = TargetDistance,
            HitDistance = ResultDistance,
            Hit = Result,
            ResolvedPart = ResolvedPart or TargetPart,
            ResolvedPosition = IsTarget and Result.Position or HitPosition,
        }
    end
    return {
        Clear = false,
        Kind = "blocked",
        Distance = Distance,
        TargetDistance = TargetDistance,
        HitDistance = ResultDistance,
        Hit = Result,
        ResolvedPart = nil,
        ResolvedPosition = nil,
    }
end
function RadiantAimEngine.GetProjectedExtent(Part, Axis)
    if not Part or not Part:IsA("BasePart") then return 0 end
    local Half = Part.Size * 0.5
    return math.abs(Part.CFrame.RightVector:Dot(Axis)) * Half.X
        + math.abs(Part.CFrame.UpVector:Dot(Axis)) * Half.Y
        + math.abs(Part.CFrame.LookVector:Dot(Axis)) * Half.Z
end

function RadiantAimEngine.CollectBlockers(Origin, HitPosition, TargetCharacter)
    local Delta = HitPosition - Origin
    local Distance = Delta.Magnitude
    if Distance <= 0.05 then return {} end
    local Direction = Delta.Unit
    local Parameters = RadiantAimEngine.MakeRayParams()
    local Filter = table.clone(Parameters.FilterDescendantsInstances or {})
    local Seen = {}
    local ResultList = {}
    local Travelled = 0
    local Limit = math.max(math.floor(tonumber(RadiantAimEngine.Config.BlockerScanLimit) or 12), 1)
    for _ = 1, Limit do
        Parameters.FilterDescendantsInstances = Filter
        local Remaining = Distance - Travelled + 1.2
        if Remaining <= 0.05 then break end
        local Cursor = Origin + Direction * Travelled
        local Result = workspace:Raycast(Cursor, Direction * Remaining, Parameters)
        if not Result then break end
        if TargetCharacter and Result.Instance and Result.Instance:IsDescendantOf(TargetCharacter) then break end
        local Instance = Result.Instance
        local EntryDistance = math.max((Result.Position - Origin):Dot(Direction), Travelled)
        local ExitDistance = EntryDistance + 0.35
        if Instance and Instance:IsA("BasePart") then
            local Intersects, _, Exit = RadiantAimEngine.SegmentPartInterval(Origin, HitPosition, Instance, 0.05)
            if Intersects and Exit then ExitDistance = math.max(ExitDistance, Exit * Distance) end
        end
        if Instance and not Seen[Instance] then
            Seen[Instance] = true
            ResultList[#ResultList + 1] = {
                Part = Instance,
                Hit = Result,
                EntryDistance = EntryDistance,
                ExitDistance = math.min(ExitDistance, Distance),
            }
            Filter[#Filter + 1] = Instance
        end
        Travelled = math.min(math.max(ExitDistance + 0.08, EntryDistance + 0.08), Distance)
        if Travelled >= Distance - 0.05 then break end
    end
    table.sort(ResultList, function(A, B) return A.EntryDistance < B.EntryDistance end)
    return ResultList
end

function RadiantAimEngine.IsPointFree(Point, TargetCharacter, Radius)
    if not RadiantAimEngine.IsVector(Point) then return false end
    local Probe = math.max(tonumber(Radius) or tonumber(RadiantAimEngine.Config.OriginProbeSize) or 0.42, 0.15)
    local Overlap = RadiantAimEngine.MakeOverlapParams(TargetCharacter)
    local Success, Parts = pcall(function()
        return workspace:GetPartBoundsInBox(CFrame.new(Point), Vector3.new(Probe, Probe, Probe), Overlap)
    end)
    if Success and type(Parts) == "table" then
        for _, Part in ipairs(Parts) do
            if Part and Part:IsA("BasePart") and Part.Parent and Part.CanCollide then return false end
        end
    end
    local Parameters = RadiantAimEngine.MakeRayParams()
    if TargetCharacter then
        local Filter = table.clone(Parameters.FilterDescendantsInstances or {})
        Filter[#Filter + 1] = TargetCharacter
        Parameters.FilterDescendantsInstances = Filter
    end
    for _, Direction in ipairs({ Vector3.new(0, -1, 0), Vector3.new(0, 1, 0) }) do
        local Result = workspace:Raycast(Point, Direction * Probe, Parameters)
        if Result and Result.Instance == workspace.Terrain and Result.Distance < Probe * 0.72 then return false end
    end
    return true
end

function RadiantAimEngine.IsRelayPointFree(Point, TargetCharacter)
    return RadiantAimEngine.IsPointFree(Point, TargetCharacter, tonumber(RadiantAimEngine.Config.OriginProbeSize) or 0.42)
end

function RadiantAimEngine.GetRegistrationScore(Character, Key)
    local Entry = GetRageMagicRegistrationEntry(Character, Key, false)
    if not Entry then return 0, false end
    local CurrentTime = os.clock()
    local Score = 0
    if CurrentTime - (tonumber(Entry.ConfirmedAt) or 0) <= (tonumber(RageMagicRegistrationState.ConfirmedLifetime) or 20) then
        Score -= tonumber(RadiantAimEngine.Config.ConfirmedBonus) or 560
    end
    local Rejected = CurrentTime < (tonumber(Entry.RejectedUntil) or 0)
    if Rejected then Score += tonumber(RadiantAimEngine.Config.RejectedPenalty) or 340 end
    Score += (tonumber(Entry.Failures) or 0) * (tonumber(RadiantAimEngine.Config.FailurePenalty) or 54)
    return Score, Rejected
end

function RadiantAimEngine.GetTargetFacingPoint(Part, HitPosition, Clearance)
    if not Part or not Part:IsA("BasePart") then return nil end
    local LocalTarget = Part.CFrame:PointToObjectSpace(HitPosition)
    local Half = Part.Size * 0.5
    local X = math.abs(LocalTarget.X) / math.max(Half.X, 0.01)
    local Y = math.abs(LocalTarget.Y) / math.max(Half.Y, 0.01)
    local Z = math.abs(LocalTarget.Z) / math.max(Half.Z, 0.01)
    local Extra = math.max(tonumber(Clearance) or 0.62, 0.10)
    local LocalPoint = Vector3.new(
        math.clamp(LocalTarget.X, -Half.X, Half.X),
        math.clamp(LocalTarget.Y, -Half.Y, Half.Y),
        math.clamp(LocalTarget.Z, -Half.Z, Half.Z)
    )
    if X >= Y and X >= Z then
        local Sign = LocalTarget.X >= 0 and 1 or -1
        LocalPoint = Vector3.new(Sign * (Half.X + Extra), LocalPoint.Y, LocalPoint.Z)
    elseif Y >= X and Y >= Z then
        local Sign = LocalTarget.Y >= 0 and 1 or -1
        LocalPoint = Vector3.new(LocalPoint.X, Sign * (Half.Y + Extra), LocalPoint.Z)
    else
        local Sign = LocalTarget.Z >= 0 and 1 or -1
        LocalPoint = Vector3.new(LocalPoint.X, LocalPoint.Y, Sign * (Half.Z + Extra))
    end
    return Part.CFrame:PointToWorldSpace(LocalPoint)
end

function RadiantAimEngine.IsPointInsideCharacter(Character, Point, Padding)
    if not Character or not RadiantAimEngine.IsVector(Point) then return false end
    local Extra = math.max(tonumber(Padding) or 0.05, 0)
    for _, Child in ipairs(Character:GetChildren()) do
        if Child:IsA("BasePart") and Child.Name ~= "HumanoidRootPart" then
            local LocalPoint = Child.CFrame:PointToObjectSpace(Point)
            local Half = Child.Size * 0.5 + Vector3.new(Extra, Extra, Extra)
            if math.abs(LocalPoint.X) <= Half.X and math.abs(LocalPoint.Y) <= Half.Y and math.abs(LocalPoint.Z) <= Half.Z then
                return true
            end
        end
    end
    return false
end

function RadiantAimEngine.GetVerticalContext(RealOrigin, TargetPart, HitPosition, Blockers)
    local Delta = HitPosition - RealOrigin
    local Distance = Delta.Magnitude
    if Distance <= 0.05 then return nil end
    local VerticalDistance = math.abs(Delta.Y)
    local VerticalRatio = VerticalDistance / Distance
    if VerticalDistance < math.max(tonumber(RadiantAimEngine.Config.VerticalMinimumDelta) or 4.5, 1) then return nil end
    if VerticalRatio < math.clamp(tonumber(RadiantAimEngine.Config.VerticalRatioThreshold) or 0.52, 0.20, 0.95) then return nil end
    local Forward, Right, Up = RadiantAimEngine.GetBasis(RealOrigin, HitPosition)
    local HorizontalA = Vector3.new(Right.X, 0, Right.Z)
    if HorizontalA.Magnitude <= 0.05 then HorizontalA = Vector3.new(1, 0, 0) else HorizontalA = HorizontalA.Unit end
    local HorizontalB = Vector3.new(Up.X, 0, Up.Z)
    if HorizontalB.Magnitude <= 0.05 or math.abs(HorizontalA:Dot(HorizontalB)) > 0.92 then
        HorizontalB = Vector3.new(-HorizontalA.Z, 0, HorizontalA.X)
    else
        HorizontalB = (HorizontalB - HorizontalA * HorizontalA:Dot(HorizontalB)).Unit
    end
    local Intersects, Entry = RadiantAimEngine.SegmentPartInterval(RealOrigin, HitPosition, TargetPart, 0.02)
    local TargetEntryDistance = Distance * (Intersects and (Entry or 0.94) or 0.94)
    local LastExitDistance = 0
    local LastBlocker = nil
    for _, Blocker in ipairs(Blockers or {}) do
        local ExitDistance = tonumber(Blocker.ExitDistance) or tonumber(Blocker.EntryDistance) or 0
        if ExitDistance > LastExitDistance and ExitDistance < TargetEntryDistance then
            LastExitDistance = ExitDistance
            LastBlocker = Blocker
        end
    end
    return {
        Forward = Forward,
        HorizontalA = HorizontalA,
        HorizontalB = HorizontalB,
        Distance = Distance,
        TargetEntryDistance = TargetEntryDistance,
        LastExitDistance = LastExitDistance,
        LastBlocker = LastBlocker,
        Gap = TargetEntryDistance - LastExitDistance,
        ShooterAbove = RealOrigin.Y > HitPosition.Y,
    }
end

function RadiantAimEngine.AddVerticalInteriorCandidates(RealOrigin, TargetCharacter, TargetPart, HitPosition, Blockers, Add)
    local Context = RadiantAimEngine.GetVerticalContext(RealOrigin, TargetPart, HitPosition, Blockers)
    if not Context or type(Add) ~= "function" then return nil end
    local Probe = math.max(tonumber(RadiantAimEngine.Config.VerticalProbeSize) or 0.22, 0.12)
    local Clearance = math.max(tonumber(RadiantAimEngine.Config.VerticalOriginClearance) or 0.26, Probe * 0.75)
    local TargetGap = math.max(tonumber(RadiantAimEngine.Config.VerticalTargetGap) or 0.24, 0.16)
    local Limit = math.max(math.floor(tonumber(RadiantAimEngine.Config.VerticalCandidateLimit) or 78), 16)
    local Added = 0
    local StartDistance = Context.LastExitDistance + Clearance
    local EndDistance = Context.TargetEntryDistance - TargetGap
    local A, B = Context.HorizontalA, Context.HorizontalB
    local Directions = {
        A, -A, B, -B,
        (A + B).Unit, (A - B).Unit, (-A + B).Unit, (-A - B).Unit
    }
    local function Push(Point, Family, Score, Path)
        if Added >= Limit then return false end
        if Add(Point, Family, Score, Path, Probe, true) then
            Added += 1
            return true
        end
        return false
    end
    local Centers = {}
    if EndDistance > StartDistance + 0.08 then
        for PositionIndex, Fraction in ipairs({ 0, 0.10, 0.24, 0.42, 0.62, 0.80, 1 }) do
            local Travel = StartDistance + (EndDistance - StartDistance) * Fraction
            local Center = RealOrigin + Context.Forward * Travel
            Centers[#Centers + 1] = Center
            Push(Center, "vertical_gap_center_" .. tostring(PositionIndex), -136 + PositionIndex * 1.7, { RealOrigin, Center, HitPosition })
        end
    end
    local TargetExtent = RadiantAimEngine.GetProjectedExtent(TargetPart, Context.Forward)
    local TargetSideBase = HitPosition - Context.Forward * math.max(TargetExtent + TargetGap, 0.38)
    Push(TargetSideBase, "vertical_target_face", -116, { RealOrigin, TargetSideBase, HitPosition })
    local Last = Context.LastBlocker
    local LastFace = nil
    if Last and Last.Part and Last.Part:IsA("BasePart") then
        LastFace = RadiantAimEngine.GetTargetFacingPoint(Last.Part, HitPosition, Clearance)
        if LastFace then
            Push(LastFace, "vertical_last_face", -132, { RealOrigin, Last.Hit and Last.Hit.Position or LastFace, LastFace, HitPosition })
        end
    end
    for PositionIndex, Center in ipairs(Centers) do
        for Ring, Radius in ipairs({ 0.30, 0.58, 0.92 }) do
            local DirectionLimit = Ring == 3 and 4 or 8
            for DirectionIndex = 1, DirectionLimit do
                local Direction = Directions[DirectionIndex]
                local Point = Center + Direction * Radius
                Push(Point, "vertical_gap_ring_" .. tostring(PositionIndex) .. "_" .. tostring(Ring) .. "_" .. tostring(DirectionIndex), -122 + PositionIndex * 1.9 + Ring * 2.2, { RealOrigin, Center, Point, HitPosition })
                if Added >= Limit then break end
            end
            if Added >= Limit then break end
        end
        if Added >= Limit then break end
    end
    if Added < Limit then
        for Ring, Radius in ipairs({ 0.30, 0.58, 0.90 }) do
            for DirectionIndex, Direction in ipairs(Directions) do
                local Point = TargetSideBase + Direction * Radius
                Push(Point, "vertical_target_ring_" .. tostring(Ring) .. "_" .. tostring(DirectionIndex), -108 + Ring * 2.8, { RealOrigin, Point, HitPosition })
                if Added >= Limit then break end
            end
            if Added >= Limit then break end
        end
    end
    if Added < Limit and LastFace then
        for Ring, Radius in ipairs({ 0.26, 0.50, 0.82, 1.12 }) do
            for DirectionIndex, Direction in ipairs(Directions) do
                local Point = LastFace + Direction * Radius
                Push(Point, "vertical_last_ring_" .. tostring(Ring) .. "_" .. tostring(DirectionIndex), -126 + Ring * 2.4, { RealOrigin, LastFace, Point, HitPosition })
                if Added >= Limit then break end
            end
            if Added >= Limit then break end
        end
    end
    return Context
end
function RadiantAimEngine.BuildOriginCandidates(RealOrigin, TargetCharacter, TargetPart, HitPosition, Blockers)
    local Budget = math.max(math.floor(tonumber(RadiantAimEngine.Config.CandidateBudget) or 144), 32)
    local MaximumShift = math.max(tonumber(RadiantAimEngine.Config.MaximumOriginShift) or 168, 16)
    local Clearance = math.max(tonumber(RadiantAimEngine.Config.OriginClearance) or 0.62, 0.18)
    local Delta = HitPosition - RealOrigin
    local Distance = Delta.Magnitude
    if Distance <= 0.05 then return {} end
    local Forward, Right, Up = RadiantAimEngine.GetBasis(RealOrigin, HitPosition)
    local Candidates, Seen = table.create(Budget), {}
    local function Add(Point, Family, BaseScore, PathPoints, ProbeSize, Vertical)
        if #Candidates >= Budget or not RadiantAimEngine.IsVector(Point) then return false end
        local Shift = (Point - RealOrigin).Magnitude
        if Shift > MaximumShift or (Point - HitPosition).Magnitude <= 0.18 then return false end
        local Key = string.format("%d:%d:%d", math.floor(Point.X * 4 + 0.5), math.floor(Point.Y * 4 + 0.5), math.floor(Point.Z * 4 + 0.5))
        if Seen[Key] then return false end
        Seen[Key] = true
        Candidates[#Candidates + 1] = {
            Origin = Point,
            Family = Family,
            BaseScore = tonumber(BaseScore) or 0,
            Shift = Shift,
            PathPoints = PathPoints,
            ProbeSize = tonumber(ProbeSize),
            Vertical = Vertical == true,
        }
        return true
    end

    RadiantAimEngine.AddVerticalInteriorCandidates(RealOrigin, TargetCharacter, TargetPart, HitPosition, Blockers, Add)

    for BlockerIndex = #Blockers, 1, -1 do
        local Entry = Blockers[BlockerIndex]
        local ExitDistance = tonumber(Entry.ExitDistance) or tonumber(Entry.EntryDistance) or 0
        for Layer = 1, 4 do
            local Offset = Clearance * (0.75 + Layer * 0.72)
            local Point = RealOrigin + Forward * math.min(ExitDistance + Offset, Distance - 0.24)
            Add(Point, "line_exit_" .. tostring(BlockerIndex), Layer * 0.8 + (#Blockers - BlockerIndex) * 1.5, {
                RealOrigin,
                Entry.Hit and Entry.Hit.Position or Point,
                Point,
                HitPosition,
            })
        end
        local Part = Entry.Part
        if Part and Part:IsA("BasePart") then
            local Face = RadiantAimEngine.GetTargetFacingPoint(Part, HitPosition, Clearance)
            if Face then
                local PartRight = Part.CFrame.RightVector
                local PartUp = Part.CFrame.UpVector
                local PartLook = Part.CFrame.LookVector
                local Scale = math.clamp(Part.Size.Magnitude * 0.08, 0.45, 3.2)
                Add(Face, "target_face_" .. tostring(BlockerIndex), 2.4, { RealOrigin, Face, HitPosition })
                for Ring = 1, 3 do
                    local Radius = Scale * Ring * 0.72
                    for _, Direction in ipairs({
                        PartRight, -PartRight, PartUp, -PartUp, PartLook, -PartLook,
                        (PartRight + PartUp).Unit, (PartRight - PartUp).Unit,
                        (-PartRight + PartUp).Unit, (-PartRight - PartUp).Unit
                    }) do
                        Add(Face + Direction * Radius, "face_ring_" .. tostring(BlockerIndex), 3.2 + Ring * 0.9, {
                            RealOrigin,
                            Face + Direction * Radius,
                            HitPosition,
                        })
                    end
                end
            end
        end
        if #Candidates >= Budget then break end
    end

    local TargetExtent = math.max(TargetPart.Size.Magnitude * 0.5, 0.8)
    local ShellDirections = {
        Forward, -Forward, Right, -Right, Up, -Up,
        (Right + Up).Unit, (Right - Up).Unit, (-Right + Up).Unit, (-Right - Up).Unit,
        (Forward + Right).Unit, (Forward - Right).Unit, (-Forward + Right).Unit, (-Forward - Right).Unit,
        (Forward + Up).Unit, (Forward - Up).Unit, (-Forward + Up).Unit, (-Forward - Up).Unit,
    }
    for Ring = 1, 5 do
        local Radius = TargetExtent + 0.65 + Ring * 0.78
        for DirectionIndex, Direction in ipairs(ShellDirections) do
            Add(HitPosition + Direction * Radius, "target_shell_" .. tostring(DirectionIndex), 8 + Ring * 1.1, {
                RealOrigin,
                HitPosition + Direction * Radius,
                HitPosition,
            })
        end
        if #Candidates >= Budget then break end
    end

    for Layer = 1, 8 do
        local T = 0.30 + Layer * 0.075
        local Center = RealOrigin:Lerp(HitPosition, math.clamp(T, 0.30, 0.90))
        local Radius = 0.8 + Layer * 0.48
        for DirectionIndex, Direction in ipairs({ Right, -Right, Up, -Up, (Right + Up).Unit, (Right - Up).Unit }) do
            Add(Center + Direction * Radius, "corridor_" .. tostring(DirectionIndex), 12 + Layer * 0.7, {
                RealOrigin,
                Center + Direction * Radius,
                HitPosition,
            })
        end
        if #Candidates >= Budget then break end
    end

    return Candidates
end
function RadiantAimEngine.EvaluateOriginCandidate(RealOrigin, Candidate, TargetCharacter, TargetPart, HitPosition, Parameters)
    if not Candidate or not RadiantAimEngine.IsVector(Candidate.Origin) then return nil end
    if RadiantAimEngine.IsPointInsideCharacter(TargetCharacter, Candidate.Origin, 0.04) then return nil end
    local LocalOrigin = TargetPart.CFrame:PointToObjectSpace(Candidate.Origin)
    local TargetHalf = TargetPart.Size * 0.5 + Vector3.new(0.10, 0.10, 0.10)
    if math.abs(LocalOrigin.X) <= TargetHalf.X and math.abs(LocalOrigin.Y) <= TargetHalf.Y and math.abs(LocalOrigin.Z) <= TargetHalf.Z then return nil end
    local Trace = RadiantAimEngine.TraceToTarget(Candidate.Origin, HitPosition, TargetCharacter, TargetPart, Parameters)
    if not Trace or not Trace.Clear then return nil end
    local ProbeSize = tonumber(Candidate.ProbeSize) or tonumber(RadiantAimEngine.Config.OriginProbeSize) or 0.42
    if not RadiantAimEngine.IsPointFree(Candidate.Origin, TargetCharacter, ProbeSize) then return nil end
    local ResolvedPart = Trace.ResolvedPart and Trace.ResolvedPart:IsA("BasePart") and Trace.ResolvedPart or TargetPart
    local ResolvedPosition = RadiantAimEngine.IsVector(Trace.ResolvedPosition) and Trace.ResolvedPosition or HitPosition
    ResolvedPosition = RadiantAimEngine.ClampPoint(ResolvedPart, ResolvedPosition, 0)
    local AimDelta = ResolvedPosition - Candidate.Origin
    if AimDelta.Magnitude <= 0.05 then return nil end
    local RegistrationKey = GetRageMagicRegistrationKey(ResolvedPart, Candidate.Origin)
    local RegistrationScore, Rejected = RadiantAimEngine.GetRegistrationScore(TargetCharacter, RegistrationKey)
    local PreferredShift = math.max(tonumber(RadiantAimEngine.Config.PreferredOriginShift) or 72, 8)
    local ShiftWeight = Candidate.Vertical and 0.095 or 0.045
    local ShiftPenalty = Candidate.Shift * ShiftWeight
    if Candidate.Shift > PreferredShift then ShiftPenalty += (Candidate.Shift - PreferredShift) * (Candidate.Vertical and 0.19 or 0.12) end
    local DirectDelta = HitPosition - RealOrigin
    local LineDistance = 0
    if DirectDelta.Magnitude > 0.05 then
        local Unit = DirectDelta.Unit
        local Along = math.clamp((Candidate.Origin - RealOrigin):Dot(Unit), 0, DirectDelta.Magnitude)
        LineDistance = (Candidate.Origin - (RealOrigin + Unit * Along)).Magnitude
    end
    local Score = (Candidate.BaseScore or 0) + ShiftPenalty + LineDistance * (Candidate.Vertical and 0.035 or 0.11) + RegistrationScore
    if Candidate.Vertical then Score -= 26 end
    if Rejected then Score += 80 end
    if Trace.Kind == "target" then Score -= 32 elseif Trace.Kind == "geometric" then Score -= 8 end
    local PathPoints = Candidate.PathPoints
    if type(PathPoints) == "table" then
        PathPoints = table.clone(PathPoints)
        if #PathPoints > 0 then PathPoints[#PathPoints] = ResolvedPosition end
    else
        PathPoints = { RealOrigin, Candidate.Origin, ResolvedPosition }
    end
    return {
        Origin = Candidate.Origin,
        Aim = ResolvedPosition,
        HitPosition = ResolvedPosition,
        Part = ResolvedPart,
        Score = Score,
        BaseScore = Candidate.BaseScore or 0,
        Family = Candidate.Family,
        RegistrationKey = RegistrationKey,
        RegistrationReady = true,
        PathPoints = PathPoints,
        Shift = Candidate.Shift,
        TraceKind = Trace.Kind,
        ProbeSize = ProbeSize,
        Vertical = Candidate.Vertical == true,
    }
end
function RadiantAimEngine.GetCacheKey(TargetPart, HitPosition)
    local LocalPoint = TargetPart.CFrame:PointToObjectSpace(HitPosition)
    return TargetPart.Name .. ":" .. tostring(math.floor(LocalPoint.X * 4 + 0.5)) .. ":" .. tostring(math.floor(LocalPoint.Y * 4 + 0.5)) .. ":" .. tostring(math.floor(LocalPoint.Z * 4 + 0.5))
end

function RadiantAimEngine.TryCachedRoute(RealOrigin, TargetCharacter, TargetPart, HitPosition, Parameters, TargetPlayer)
    local CharacterCache = RadiantAimEngine.State.RouteCache[TargetCharacter]
    if type(CharacterCache) ~= "table" then return nil end
    local Entry = CharacterCache[RadiantAimEngine.GetCacheKey(TargetPart, HitPosition)]
    if type(Entry) ~= "table" then return nil end
    if os.clock() - (tonumber(Entry.Time) or 0) > (tonumber(RadiantAimEngine.Config.CacheLifetime) or 0.24) then return nil end
    if not RadiantAimEngine.IsVector(Entry.RealOrigin) or (Entry.RealOrigin - RealOrigin).Magnitude > (tonumber(RadiantAimEngine.Config.CacheOriginTolerance) or 5.5) then return nil end
    if not RadiantAimEngine.IsVector(Entry.HitPosition) or (Entry.HitPosition - HitPosition).Magnitude > (tonumber(RadiantAimEngine.Config.CacheTargetTolerance) or 2.5) then return nil end
    local Limit = math.min(#Entry.Candidates, math.max(math.floor(tonumber(RadiantAimEngine.Config.CacheCandidateBudget) or 18), 1))
    local Ranked = table.create(Limit)
    for Index = 1, Limit do
        local Cached = Entry.Candidates[Index]
        if Cached and RadiantAimEngine.IsVector(Cached.Origin) then
            local Candidate = {
                Origin = Cached.Origin,
                Family = Cached.Family,
                BaseScore = Cached.BaseScore,
                Shift = (Cached.Origin - RealOrigin).Magnitude,
                PathPoints = { RealOrigin, Cached.Origin, HitPosition },
                ProbeSize = Cached.ProbeSize,
                Vertical = Cached.Vertical == true,
            }
            local Evaluated = RadiantAimEngine.EvaluateOriginCandidate(RealOrigin, Candidate, TargetCharacter, TargetPart, HitPosition, Parameters)
            if Evaluated then Ranked[#Ranked + 1] = Evaluated end
        end
    end
    table.sort(Ranked, function(A, B)
        if A.Score ~= B.Score then return A.Score < B.Score end
        return A.Shift < B.Shift
    end)
    local VerticalContext = false
    for _, Route in ipairs(Ranked) do
        if Route.Vertical then VerticalContext = true break end
    end
    return RadiantAimEngine.SelectRouteSample(Ranked, TargetPlayer, VerticalContext, TargetCharacter)
end
function RadiantAimEngine.StoreRouteCache(TargetCharacter, TargetPart, HitPosition, RealOrigin, Ranked)
    local CharacterCache = RadiantAimEngine.State.RouteCache[TargetCharacter]
    if type(CharacterCache) ~= "table" then
        CharacterCache = {}
        RadiantAimEngine.State.RouteCache[TargetCharacter] = CharacterCache
    end
    local Stored = table.create(math.min(#Ranked, 28))
    for Index = 1, math.min(#Ranked, 28) do
        local Route = Ranked[Index]
        Stored[Index] = {
            Origin = Route.Origin,
            Family = Route.Family,
            BaseScore = Route.BaseScore or Route.Score,
            ProbeSize = Route.ProbeSize,
            Vertical = Route.Vertical == true,
        }
    end
    CharacterCache[RadiantAimEngine.GetCacheKey(TargetPart, HitPosition)] = {
        Time = os.clock(),
        RealOrigin = RealOrigin,
        HitPosition = HitPosition,
        Candidates = Stored,
    }
end
function RadiantAimEngine.SelectRouteSample(Ranked, TargetPlayer, VerticalContext, TargetCharacter)
    if type(Ranked) ~= "table" or #Ranked == 0 then return nil end

    local Requested = math.clamp(
        math.floor(tonumber(RageBotSettings.MagicSamples) or tonumber(RadiantAimEngine.Config.MagicSampleLimit) or 8),
        1,
        16
    )
    local RouteLimit = math.min(#Ranked, Requested, VerticalContext and 12 or 8)
    local Available, Confirmed = {}, {}

    for Index = 1, RouteLimit do
        local Route = Ranked[Index]
        local RegistrationScore, Rejected = 0, false
        if TargetCharacter and Route.RegistrationKey then
            RegistrationScore, Rejected = RadiantAimEngine.GetRegistrationScore(TargetCharacter, Route.RegistrationKey)
        end
        if not Rejected then
            Route.RegistrationScore = RegistrationScore
            Available[#Available + 1] = Route
            if RegistrationScore <= -(tonumber(RadiantAimEngine.Config.ConfirmedBonus) or 560) * 0.5 then
                Confirmed[#Confirmed + 1] = Route
            end
        end
    end

    local Pool = #Confirmed > 0 and Confirmed or Available
    if #Pool == 0 then Pool = Ranked end

    table.sort(Pool, function(A, B)
        local AConfirmed = (tonumber(A.RegistrationScore) or 0) < 0
        local BConfirmed = (tonumber(B.RegistrationScore) or 0) < 0
        if AConfirmed ~= BConfirmed then return AConfirmed end

        local AScore = tonumber(A.Score) or math.huge
        local BScore = tonumber(B.Score) or math.huge
        if A.LowRoute ~= B.LowRoute and math.abs(AScore - BScore) <= 4.5 then
            return A.LowRoute == true
        end
        if AScore ~= BScore then return AScore < BScore end
        return (tonumber(A.Shift) or math.huge) < (tonumber(B.Shift) or math.huge)
    end)

    local Failures = math.max(tonumber(RageShotState.TargetFailures[TargetPlayer]) or 0, 0)
    local ProbeLimit = math.min(#Pool, #Confirmed > 0 and 1 or 3)
    local Index = 1 + (Failures % math.max(ProbeLimit, 1))
    local Route = Pool[Index] or Pool[1]
    if Route then
        Route.RouteSampleIndex = Index
        Route.RouteSampleCount = ProbeLimit
    end
    return Route
end

function RadiantAimEngine.PlanWallbang(RealOrigin, TargetPlayer, TargetCharacter, TargetPart, HitPosition)
    if not RadiantAimEngine.IsVector(RealOrigin) or not TargetCharacter or not TargetPart or not RadiantAimEngine.IsVector(HitPosition) then return nil end
    local Parameters = RadiantAimEngine.MakeRayParams()
    local Cached = RadiantAimEngine.TryCachedRoute(RealOrigin, TargetCharacter, TargetPart, HitPosition, Parameters, TargetPlayer)
    if Cached then return Cached end
    local Blockers = RadiantAimEngine.CollectBlockers(RealOrigin, HitPosition, TargetCharacter)
    local VerticalContext = RadiantAimEngine.GetVerticalContext(RealOrigin, TargetPart, HitPosition, Blockers)
    local Candidates = RadiantAimEngine.BuildOriginCandidates(RealOrigin, TargetCharacter, TargetPart, HitPosition, Blockers)
    table.sort(Candidates, function(A, B)
        local AScore = (A.BaseScore or 0) + (A.Shift or 0) * (A.Vertical and 0.075 or 0.035)
        local BScore = (B.BaseScore or 0) + (B.Shift or 0) * (B.Vertical and 0.075 or 0.035)
        return AScore < BScore
    end)
    local DefaultLimit = tonumber(RadiantAimEngine.Config.ValidRouteLimit) or 18
    local ValidLimit = VerticalContext and math.max(math.floor(tonumber(RadiantAimEngine.Config.VerticalValidRouteLimit) or 26), 6) or math.max(math.floor(DefaultLimit), 4)
    local Ranked = table.create(math.min(#Candidates, ValidLimit))
    local DefaultBudget = tonumber(RadiantAimEngine.Config.TraceBudget) or 64
    local RequestedBudget = VerticalContext and math.max(tonumber(RadiantAimEngine.Config.VerticalTraceBudget) or 104, DefaultBudget) or DefaultBudget
    local TraceBudget = math.min(#Candidates, math.max(math.floor(RequestedBudget), 12))
    for CandidateIndex = 1, TraceBudget do
        local Candidate = Candidates[CandidateIndex]
        local Evaluated = RadiantAimEngine.EvaluateOriginCandidate(RealOrigin, Candidate, TargetCharacter, TargetPart, HitPosition, Parameters)
        if Evaluated then
            local LowReference = math.min(RealOrigin.Y, HitPosition.Y)
            Evaluated.LowRoute = Evaluated.Origin.Y < LowReference - 0.30
            if Evaluated.LowRoute then
                local LowDepth = math.clamp(LowReference - Evaluated.Origin.Y, 0, 3)
                Evaluated.Score -= LowDepth * 1.15
            end
            Ranked[#Ranked + 1] = Evaluated
            if #Ranked >= ValidLimit then break end
        end
    end
    table.sort(Ranked, function(A, B)
        if A.Score ~= B.Score then return A.Score < B.Score end
        return A.Shift < B.Shift
    end)
    RadiantAimEngine.StoreRouteCache(TargetCharacter, TargetPart, HitPosition, RealOrigin, Ranked)
    return RadiantAimEngine.SelectRouteSample(Ranked, TargetPlayer, VerticalContext, TargetCharacter)
end
function RadiantAimEngine.ResolveDirect(Origin, Player, Character, Preferred)
    local Parameters = RadiantAimEngine.MakeRayParams()
    local Parts = RadiantAimEngine.GetParts(Character, Preferred)
    local Best
    for PartIndex, Part in ipairs(Parts) do
        if PartIndex > 5 then break end
        local Predicted = RadiantAimEngine.GetMotionPrediction(Player, Character, Part, Origin)
        local Points = RadiantAimEngine.BuildHitPoints(Part, Predicted)
        for PointIndex, Point in ipairs(Points) do
            local Trace = RadiantAimEngine.TraceToTarget(Origin, Point, Character, Part, Parameters)
            if Trace and Trace.Clear then
                local ResolvedPart = Trace.ResolvedPart and Trace.ResolvedPart:IsA("BasePart") and Trace.ResolvedPart or Part
                local ResolvedPosition = RadiantAimEngine.IsVector(Trace.ResolvedPosition) and Trace.ResolvedPosition or Point
                ResolvedPosition = RadiantAimEngine.ClampPoint(ResolvedPart, ResolvedPosition, 0)
                local Score = -RadiantAimEngine.GetPartWeight(ResolvedPart) + PartIndex * 1.8 + PointIndex * 0.22
                if Trace.Kind == "target" then Score -= 8 end
                if not Best or Score < Best.Score then
                    Best = {
                        Part = ResolvedPart,
                        Aim = ResolvedPosition,
                        HitPosition = ResolvedPosition,
                        Score = Score,
                    }
                end
                if ResolvedPart == Preferred and PointIndex == 1 and Trace.Kind == "target" then return Best end
            end
        end
    end
    return Best
end
function RadiantAimEngine.ResolveShot(Origin, TargetPlayer, Character, PreferredPart)
    if not RadiantAimEngine.IsVector(Origin) or not TargetPlayer or not Character or not PreferredPart then return nil end
    local Direct = RadiantAimEngine.ResolveDirect(Origin, TargetPlayer, Character, PreferredPart)
    if Direct then
        local Delta = Direct.Aim - Origin
        if Delta.Magnitude > 0.05 then
            local Seed = math.max(math.floor(tonumber(RadiantAimEngine.State.Sequence) or 0), 0)
            if RageBotSettings.MagicBullet then RadiantAimEngine.State.Sequence = Seed + 1 end
            return {
                Origin = Origin,
                RealOrigin = Origin,
                Aim = Direct.Aim,
                HitPosition = Direct.HitPosition,
                Part = Direct.Part,
                Dir = Delta.Unit,
                Mode = RageBotSettings.MagicBullet and "magic_los" or "los",
                RegistrationKey = nil,
                RegistrationReady = true,
                SampleSeed = Seed,
                RouteSampleIndex = 1,
                RouteSampleCount = 1,
                TrajectoryPoints = { Origin, Direct.Aim },
            }
        end
    end
    if RageBotSettings.MagicBullet ~= true then return nil end

    local Parts = RadiantAimEngine.GetParts(Character, PreferredPart)
    local Best
    local PartLimit = math.max(math.floor(tonumber(RadiantAimEngine.Config.MagicPartLimit) or 3), 1)
    for PartIndex, Part in ipairs(Parts) do
        if PartIndex > PartLimit then break end
        local Predicted = RadiantAimEngine.GetMotionPrediction(TargetPlayer, Character, Part, Origin)
        local Points = RadiantAimEngine.BuildHitPoints(Part, Predicted)
        local PointLimit = Part == PreferredPart and math.max(math.floor(tonumber(RadiantAimEngine.Config.MagicPointLimit) or 3), 1) or 1
        for PointIndex = 1, math.min(#Points, PointLimit) do
            local HitPosition = Points[PointIndex]
            local Route = RadiantAimEngine.PlanWallbang(Origin, TargetPlayer, Character, Part, HitPosition)
            if Route then
                local ResolvedPart = Route.Part and Route.Part.Parent and Route.Part or Part
                local ResolvedHitPosition = RadiantAimEngine.IsVector(Route.HitPosition) and Route.HitPosition or HitPosition
                local Score = Route.Score - RadiantAimEngine.GetPartWeight(ResolvedPart) * 0.36 + PartIndex * 2.2 + PointIndex * 0.55
                if not Best or Score < Best.Score then
                    Best = {
                        Route = Route,
                        Score = Score,
                        Part = ResolvedPart,
                        HitPosition = ResolvedHitPosition,
                    }
                end
            end
        end
    end
    if not Best then return nil end

    local Route = Best.Route
    local PacketOrigin = Route.Origin
    local ChosenAim = Route.Aim
    local Delta = ChosenAim - PacketOrigin
    if Delta.Magnitude <= 0.05 then return nil end
    RageMagicBulletCache.TargetPart = Best.Part
    RageMagicBulletCache.Character = Character
    RageMagicBulletCache.Origin = PacketOrigin
    RageMagicBulletCache.RealOrigin = Origin
    RageMagicBulletCache.PartPosition = Best.Part.Position
    RageMagicBulletCache.HitPosition = Best.HitPosition
    RageMagicBulletCache.SampleAim = ChosenAim
    RageMagicBulletCache.RegistrationKey = Route.RegistrationKey
    RageMagicBulletCache.Score = Best.Score
    RageMagicBulletCache.Time = os.clock()
    local Seed = math.max(math.floor(tonumber(RadiantAimEngine.State.Sequence) or 0), 0)
    RadiantAimEngine.State.Sequence = Seed + 1
    return {
        Origin = PacketOrigin,
        RealOrigin = Origin,
        Aim = ChosenAim,
        HitPosition = Best.HitPosition,
        Part = Best.Part,
        Dir = Delta.Unit,
        Mode = Route.Vertical and "magic_vertical" or ((PacketOrigin - Origin).Magnitude > 0.5 and "magic_trajectory" or "magic_wallbang"),
        RegistrationKey = Route.RegistrationKey,
        RegistrationReady = Route.RegistrationReady == true,
        RouteKind = Route.TraceKind,
        RouteScore = Best.Score,
        RouteFamily = Route.Family,
        VerticalRoute = Route.Vertical == true,
        TrajectoryPoints = Route.PathPoints or { Origin, PacketOrigin, ChosenAim },
        RelayShift = (PacketOrigin - Origin).Magnitude,
        RelayBlockers = 0,
        SampleSeed = Seed,
        RouteSampleIndex = Route.RouteSampleIndex or 1,
        RouteSampleCount = Route.RouteSampleCount or 1,
    }
end

function RadiantAimEngine.ResolveRayHandler()
    local Cached = RadiantAimEngine.State.RayHandler
    if type(Cached) == "table" and type(Cached.CastRay) == "function" then return Cached end
    if RadiantAimEngine.State.RayHandlerResolved then return nil end
    RadiantAimEngine.State.RayHandlerResolved = true

    local NewModules = ReplicatedStorage:FindFirstChild("NewModules")
    local Shared = NewModules and NewModules:FindFirstChild("Shared")
    local Services = Shared and Shared:FindFirstChild("Services")
    local Module = Services and Services:FindFirstChild("RayHandler")
    if not Module or not Module:IsA("ModuleScript") then return nil end

    local Success, Handler = pcall(require, Module)
    if Success and type(Handler) == "table" and type(Handler.CastRay) == "function" then
        RadiantAimEngine.State.RayHandler = Handler
        return Handler
    end
    return nil
end

function RadiantAimEngine.GetBulletVectorLength(Tool)
    local Config = GetRageWeaponConfig(Tool)
    local Value = Config and (
        Config.Range
        or Config.BulletRange
        or Config.MaxRange
        or Config.Distance
        or Config.MaxDistance
    )
    return math.clamp(tonumber(Value) or 500, 100, 5000)
end

function RadiantAimEngine.TraceWithRayHandler(Origin, HitPosition, TargetCharacter, TargetPart)
    local Handler = RadiantAimEngine.ResolveRayHandler()
    if not Handler or Handler.HasSetUp ~= true then return nil end

    local Delta = HitPosition - Origin
    local Distance = Delta.Magnitude
    if Distance <= 0.05 then return nil end

    local CastVector = Delta.Unit * (Distance + 1.25)
    local Success, HitPart, HitPositionResult, HitNormal, HitMaterial, HitData = pcall(
        Handler.CastRay,
        Ray.new(Origin, CastVector),
        nil,
        { type = "g" },
        nil
    )
    if not Success then return nil end

    local ResolvedPart = HitPart and RadiantAimEngine.ResolveCharacterHitPart(TargetCharacter, HitPart) or nil
    local Intersects, Entry = RadiantAimEngine.SegmentPartInterval(Origin, HitPosition, TargetPart, 0.03)
    local TargetDistance = Intersects and Distance * (Entry or 1) or Distance

    if ResolvedPart then
        return {
            Clear = true,
            Kind = "rayhandler_target",
            Distance = Distance,
            TargetDistance = TargetDistance,
            HitDistance = typeof(HitPositionResult) == "Vector3" and (HitPositionResult - Origin).Magnitude or Distance,
            HitPart = HitPart,
            HitPosition = HitPositionResult,
            HitNormal = HitNormal,
            HitMaterial = HitMaterial,
            HitData = HitData,
            ResolvedPart = ResolvedPart,
            ResolvedPosition = typeof(HitPositionResult) == "Vector3" and HitPositionResult or HitPosition,
        }
    end

    if HitPart then
        return {
            Clear = false,
            Kind = "rayhandler_blocked",
            Distance = Distance,
            TargetDistance = TargetDistance,
            HitDistance = typeof(HitPositionResult) == "Vector3" and (HitPositionResult - Origin).Magnitude or 0,
            HitPart = HitPart,
            HitPosition = HitPositionResult,
            HitNormal = HitNormal,
            HitMaterial = HitMaterial,
            HitData = HitData,
            ResolvedPart = nil,
            ResolvedPosition = nil,
        }
    end

    return {
        Clear = Intersects,
        Kind = Intersects and "rayhandler_geometric" or "rayhandler_miss",
        Distance = Distance,
        TargetDistance = TargetDistance,
        HitDistance = Distance,
        HitPart = nil,
        HitPosition = HitPositionResult,
        HitNormal = HitNormal,
        HitMaterial = HitMaterial,
        HitData = HitData,
        ResolvedPart = Intersects and TargetPart or nil,
        ResolvedPosition = Intersects and HitPosition or nil,
    }
end

function RadiantAimEngine.BuildMagicSamplePoints(Part, PredictedCenter, Requested)
    local Result, Seen = {}, {}
    local function Add(Point)
        if not RadiantAimEngine.IsVector(Point) or #Result >= Requested then return end
        Point = RadiantAimEngine.ClampPoint(Part, Point, 0)
        local LocalPoint = Part.CFrame:PointToObjectSpace(Point)
        local Key = string.format("%d:%d:%d", math.floor(LocalPoint.X * 20 + 0.5), math.floor(LocalPoint.Y * 20 + 0.5), math.floor(LocalPoint.Z * 20 + 0.5))
        if Seen[Key] then return end
        Seen[Key] = true
        Result[#Result + 1] = Point
    end

    for _, Point in ipairs(RadiantAimEngine.BuildHitPoints(Part, PredictedCenter)) do
        Add(Point)
        if #Result >= Requested then return Result end
    end

    local Half = Part.Size * 0.5
    local Safe = Vector3.new(math.max(Half.X - 0.12, 0.04), math.max(Half.Y - 0.12, 0.04), math.max(Half.Z - 0.12, 0.04))
    local Shift = RadiantAimEngine.IsVector(PredictedCenter) and PredictedCenter - Part.Position or Vector3.zero
    local Golden = math.pi * (3 - math.sqrt(5))
    local ExtraCount = math.max(Requested * 2, 16)
    for Index = 1, ExtraCount do
        local Y = 1 - 2 * ((Index - 0.5) / ExtraCount)
        local Radius = math.sqrt(math.max(1 - Y * Y, 0))
        local Angle = Golden * Index
        local Unit = Vector3.new(math.cos(Angle) * Radius, Y, math.sin(Angle) * Radius) * 0.82
        local LocalPoint = Vector3.new(Unit.X * Safe.X, Unit.Y * Safe.Y, Unit.Z * Safe.Z)
        Add(Part.CFrame:PointToWorldSpace(LocalPoint) + Shift)
        if #Result >= Requested then break end
    end
    return Result
end

function RadiantAimEngine.BuildMagicBulletSamples(Shot, TargetPlayer, TargetCharacter, TargetPart, BulletCount)
    if not Shot or not TargetCharacter or not TargetPart then return nil end
    local PacketOrigin = Shot.Origin
    local RealOrigin = Shot.RealOrigin or PacketOrigin
    local Part = Shot.Part and Shot.Part.Parent and Shot.Part or TargetPart
    if not RadiantAimEngine.IsVector(PacketOrigin) or not Part or not Part:IsA("BasePart") then return nil end

    local Aim = Shot.Aim
    if not RadiantAimEngine.IsVector(Aim) then
        Aim = RadiantAimEngine.GetMotionPrediction(TargetPlayer, TargetCharacter, Part, PacketOrigin)
    end
    if not RadiantAimEngine.IsVector(Aim) then Aim = Part.Position end
    Aim = RadiantAimEngine.ClampPoint(Part, Aim, 0)

    local Delta = Aim - PacketOrigin
    if Delta.Magnitude <= 0.05 then return nil end
    local Direction = Delta.Unit
    local PathPoints
    if type(Shot.TrajectoryPoints) == "table" and #Shot.TrajectoryPoints >= 2 then
        PathPoints = table.clone(Shot.TrajectoryPoints)
        PathPoints[#PathPoints] = Aim
    else
        PathPoints = { RealOrigin, PacketOrigin, Aim }
    end

    local Sample = {
        Origin = PacketOrigin,
        Aim = Aim,
        HitPosition = Aim,
        Part = Part,
        Dir = Direction,
        RayVector = Direction * RadiantAimEngine.GetBulletVectorLength(Shot.Tool),
        PacketDirection = Direction,
        TrajectoryPoints = PathPoints,
        TraceKind = "stable",
    }

    local Count = math.max(math.floor(tonumber(BulletCount) or 1), 1)
    Shot.BulletSamples = { Sample }
    Shot.SampleCount = 1
    Shot.BulletSampleMap = table.create(Count)
    for BulletIndex = 1, Count do Shot.BulletSampleMap[BulletIndex] = Sample end
    return Shot.BulletSamples
end

function RadiantAimEngine.ClearWallbangCache(Character)
    if Character then
        RadiantAimEngine.State.RouteCache[Character] = nil
        RageWallbangSampleCache[Character] = nil
        RadiantAimEngine.State.RelayCooldown[Character] = nil
    else
        RadiantAimEngine.State.RouteCache = setmetatable({}, { __mode = "k" })
        RadiantAimEngine.State.Motion = setmetatable({}, { __mode = "k" })
        RageWallbangSampleCache = setmetatable({}, { __mode = "k" })
        RadiantAimEngine.State.RelayCooldown = setmetatable({}, { __mode = "k" })
    end
    RadiantAimEngine.State.Generation += 1
end

function RadiantAimEngine.AcquireTarget()
    local CurrentTime = os.clock()
    local Cached = RadiantAimEngine.State.Target
    local Interval = math.max(tonumber(RadiantAimEngine.Config.TargetScanInterval) or 0.065, 0.035)
    if CurrentTime - (tonumber(Cached.Time) or 0) < Interval
        and IsCachedRageTargetUsable(Cached.Player, Cached.Character, Cached.Part)
    then
        return Cached.Player, Cached.Character, Cached.Part
    end
    local LocalCharacter = GetRageCharacter(LocalPlayer)
    local LocalRoot = GetRageRootPart(LocalCharacter)
    local Camera = GetCamera()
    if not LocalRoot or not Camera then
        Cached.Time, Cached.Player, Cached.Character, Cached.Part = CurrentTime, nil, nil, nil
        return nil, nil, nil
    end
    local UseFOV = RageBotSettings.TargetMode == "FOV"
    local FOVOrigin = RageBotSettings.FOVOrigin == "Mouse" and UserInputService:GetMouseLocation() or Camera.ViewportSize * 0.5
    local Origin = RageBotSettings.OriginMode == "Camera" and Camera.CFrame.Position or LocalRoot.Position
    if RageBotSettings.Sticky and RageBotStickyTarget then
        local Candidate = GetRageCandidate(RageBotStickyTarget, LocalRoot, Camera, UseFOV, FOVOrigin)
        if Candidate and (RageBotSettings.MagicBullet or ResolveRageCandidateWall(Candidate, Origin)) then
            Cached.Time, Cached.Player, Cached.Character, Cached.Part = CurrentTime, Candidate.Player, Candidate.Character, Candidate.Part
            return Candidate.Player, Candidate.Character, Candidate.Part
        end
        RageBotStickyTarget = nil
    end
    local Candidates = {}
    for _, Player in ipairs(Players:GetPlayers()) do
        local Candidate = GetRageCandidate(Player, LocalRoot, Camera, UseFOV, FOVOrigin)
        if Candidate then
            local Failures = tonumber(RageShotState.TargetFailures[Player]) or 0
            local Backoff = math.max((tonumber(RageShotState.TargetBackoff[Player]) or 0) - CurrentTime, 0)
            Candidate.EngineScore = Candidate.Score + Failures * 12 + Backoff * 180
            Candidates[#Candidates + 1] = Candidate
        end
    end
    table.sort(Candidates, function(A, B) return A.EngineScore < B.EngineScore end)
    local Selected
    local Checks = math.min(#Candidates, math.max(math.floor(tonumber(RadiantAimEngine.Config.TargetWallChecks) or 4), 1))
    for Index = 1, Checks do
        local Candidate = Candidates[Index]
        if RageBotSettings.MagicBullet or ResolveRageCandidateWall(Candidate, Origin) then
            Selected = Candidate
            break
        end
    end
    if Selected and RageBotSettings.Sticky then RageBotStickyTarget = Selected.Player end
    Cached.Time = CurrentTime
    Cached.Player = Selected and Selected.Player or nil
    Cached.Character = Selected and Selected.Character or nil
    Cached.Part = Selected and Selected.Part or nil
    return Cached.Player, Cached.Character, Cached.Part
end

function RageBotAPI.FindWallbangPoint(Origin, TargetPart, TargetCharacter, TargetPlayer)
    if not TargetPart or not TargetCharacter or not RadiantAimEngine.IsVector(Origin) then return nil, nil, nil end
    local HitPosition = RadiantAimEngine.ClampPoint(TargetPart, TargetPart.Position, 0)
    local Route = RadiantAimEngine.PlanWallbang(Origin, TargetPlayer, TargetCharacter, TargetPart, HitPosition)
    return Route and Route.Aim or nil, Route and Route.Part or TargetPart, Route and Route.Origin or Origin
end

RadiantMuzzleMotorEngine = {
    Version = "MuzzleMotorSync-Disabled-RegistrationSafe",
    Config = { Enabled = false },
    State = { Active = nil },
}

function RadiantMuzzleMotorEngine.Restore()
    RadiantMuzzleMotorEngine.State.Active = nil
end

function RageBotAPI.ValidateAppliedMagicRegistration(Tool, RealOrigin, Shot, TargetCharacter)
    if not Shot or not IsRageMagicPathMode(Shot.Mode) then return true end
    if not Tool or not Tool.Parent or not TargetCharacter or not TargetCharacter.Parent then return false end
    if not RadiantAimEngine.IsVector(RealOrigin) or not RadiantAimEngine.IsVector(Shot.Aim) then return false end
    if not Shot.Part or not Shot.Part.Parent or not RadiantAimEngine.IsVector(Shot.HitPosition) then return false end
    local PacketOrigin = RadiantAimEngine.IsVector(Shot.Origin) and Shot.Origin or RealOrigin
    local Delta = Shot.Aim - PacketOrigin
    if Shot.Mode == "magic_trajectory" or Shot.Mode == "magic_vertical" then
        local Shift = (PacketOrigin - RealOrigin).Magnitude
        if Shift > math.max(tonumber(RadiantAimEngine.Config.TrajectoryRelayMaximumShift) or 96, 8) then return false end
        if not RadiantAimEngine.IsRelayPointFree(PacketOrigin, TargetCharacter) then return false end
    end
    return Delta.Magnitude > 0.05 and Shot.RegistrationReady == true
end

function RageBotAPI.ResolveGhostMagicShot(RealOrigin, LocalRoot, TargetCharacter, PreferredPart)
    if RageBotSettings.MagicBullet ~= true
        or typeof(RealOrigin) ~= "Vector3"
        or not LocalRoot
        or not LocalRoot.Parent
        or not TargetCharacter
        or not TargetCharacter.Parent
    then
        return nil
    end

    local Parts = {}
    local Seen = {}

    local function AddPart(Part)
        if Part
            and Part:IsA("BasePart")
            and Part:IsDescendantOf(TargetCharacter)
            and not Seen[Part]
        then
            Seen[Part] = true
            Parts[#Parts + 1] = Part
        end
    end

    AddPart(PreferredPart)
    AddPart(TargetCharacter:FindFirstChild("Head"))
    AddPart(TargetCharacter:FindFirstChild("UpperTorso"))
    AddPart(TargetCharacter:FindFirstChild("Torso"))
    AddPart(TargetCharacter:FindFirstChild("HumanoidRootPart"))

    for _, Descendant in ipairs(TargetCharacter:GetDescendants()) do
        AddPart(Descendant)
    end

    if #Parts == 0 then return nil end

    local Parameters = RaycastParams.new()
    Parameters.FilterType = Enum.RaycastFilterType.Exclude
    Parameters.FilterDescendantsInstances = {
        workspace.CurrentCamera,
        LocalPlayer.Character
    }
    Parameters.IgnoreWater = true

    local Attempts = 6
    local RootPosition = LocalRoot.Position

    for Attempt = 1, Attempts do
        local CandidateOrigin = RootPosition + Vector3.new(
            math.random(-18, 18),
            math.random(-18, 18),
            math.random(-18, 18)
        )

        for _, Part in ipairs(Parts) do
            if not Part.Parent then continue end

            local AimPosition = Part.Position
            local Delta = AimPosition - CandidateOrigin
            if Delta.Magnitude <= 0.05 then continue end

            local Direction = Delta.Unit
            local Result = workspace:Raycast(
                CandidateOrigin,
                Direction * 1000,
                Parameters
            )

            if Result
                and typeof(Result.Position) == "Vector3"
                and (Result.Position - AimPosition).Magnitude <= 25
            then
                return {
                    Origin = CandidateOrigin,
                    RealOrigin = RealOrigin,
                    Aim = AimPosition,
                    HitPosition = AimPosition,
                    Part = Part,
                    Dir = Direction,
                    Mode = "magic_ghost",
                    RegistrationKey = nil,
                    RegistrationReady = true,
                    RouteKind = "ghost_random_origin",
                    RouteScore = Attempt,
                    RouteFamily = "ghost",
                    TrajectoryPoints = {
                        RealOrigin,
                        CandidateOrigin,
                        AimPosition
                    },
                    SampleSeed = Attempt,
                    RouteSampleIndex = Attempt,
                    RouteSampleCount = Attempts
                }
            end
        end
    end

    return nil
end

function RageBotAPI.FireRageShot(TargetPlayer, TargetCharacter, TargetPart, LocalRoot, LocalTool)
    if RespawnSafetyState and RespawnSafetyState.Suspended then return false end
    if not LocalPlayer.Character or not LocalRoot or LocalRoot.Parent ~= LocalPlayer.Character or not LocalTool or not LocalTool:IsDescendantOf(LocalPlayer.Character) then return false end
    if not TargetPlayer
        or not TargetCharacter
        or not TargetPart
        or not LocalRoot
        or not LocalTool
        or IsRageDowned(TargetPlayer)
    then
        return false
    end

    local Events = ReplicatedStorage:FindFirstChild("Events")
    local GNX_S = Events and Events:FindFirstChild("GNX_S")
    local ZFKLF = Events and Events:FindFirstChild("ZFKLF__H")
    if not GNX_S then
        return false
    end

    if type(RageShotState.UpdatePending) == "function" then
        RageShotState.UpdatePending()
    end

    local Values = LocalTool:FindFirstChild("Values")
    local ServerAmmo = Values and Values:FindFirstChild("SERVER_Ammo")
    local Hitmarker = LocalTool:FindFirstChild("Hitmarker")
    if not Values then
        return false
    end

    local AmmoValue = ServerAmmo and tonumber(ServerAmmo.Value)
    if AmmoValue ~= nil and AmmoValue <= 0 then
        if RageBotSettings.AutoReload then
            UpdateRageReload(LocalTool)
        end
        return false
    end

    local Handle = LocalTool:FindFirstChild("WeaponHandle")
        or LocalTool:FindFirstChild("Handle")
    local Camera = workspace.CurrentCamera
    local RealOrigin = (type(GetRageFireOrigin) == "function" and GetRageFireOrigin(LocalTool))
        or (Handle and Handle.Position)
        or (Camera and Camera.CFrame.Position)
        or LocalRoot.Position
    local ShotSlotReserved = false

    if RageBotSettings.MagicBullet then
        if not WaitForRageShotSlot(LocalTool) then return false end
        ShotSlotReserved = true
        if not LocalTool.Parent or not TargetCharacter.Parent or not TargetPart.Parent or IsRageDowned(TargetPlayer) then return false end
        Handle = LocalTool:FindFirstChild("WeaponHandle") or LocalTool:FindFirstChild("Handle")
        Camera = workspace.CurrentCamera
        RealOrigin = (type(GetRageFireOrigin) == "function" and GetRageFireOrigin(LocalTool))
            or (Handle and Handle.Position)
            or (Camera and Camera.CFrame.Position)
            or LocalRoot.Position
    end

    RadiantAimEngine._ActiveTool = LocalTool
    local Shot = RadiantAimEngine.ResolveShot(
        RealOrigin,
        TargetPlayer,
        TargetCharacter,
        TargetPart
    )
    RadiantAimEngine._ActiveTool = nil

    if RageBotSettings.MagicBullet
        and (
            not Shot
            or Shot.Mode ~= "magic_los"
        )
    then
        local GhostShot = RageBotAPI.ResolveGhostMagicShot(
            RealOrigin,
            LocalRoot,
            TargetCharacter,
            TargetPart
        )
        if GhostShot then
            Shot = GhostShot
        end
    end

    if not Shot or typeof(Shot.Dir) ~= "Vector3" then
        if not RageBotSettings.MagicBullet and type(RageShotState.MarkPathFailure) == "function" then
            RageShotState.MarkPathFailure(TargetPlayer)
        end
        return false
    end

    local PacketOrigin = Shot.Origin
    local ChosenAim = Shot.Aim
    local HitPosition = Shot.HitPosition or ChosenAim
    local AimPart = Shot.Part or TargetPart
    local FinalDir = Shot.Dir
    if IsRageMagicPathMode(Shot.Mode) and typeof(ChosenAim) == "Vector3" and typeof(PacketOrigin) == "Vector3" then
        local SampleDelta = ChosenAim - PacketOrigin
        if SampleDelta.Magnitude > 0.05 then
            FinalDir = SampleDelta.Unit
            Shot.Dir = FinalDir
        end
    end
    local BulletCount = GetRageBulletsPerShot(LocalTool)
    Shot.Tool = LocalTool
    if RageBotSettings.MagicBullet
        and Shot.Mode ~= "magic_ghost"
        and type(Shot.Mode) == "string"
        and string.sub(Shot.Mode, 1, 6) == "magic_"
    then
        local Samples = RadiantAimEngine.BuildMagicBulletSamples(Shot, TargetPlayer, TargetCharacter, AimPart, BulletCount)
        local Primary = Samples and Samples[1]
        if Primary then
            PacketOrigin = Primary.Origin
            ChosenAim = Primary.Aim
            HitPosition = Primary.HitPosition
            AimPart = Primary.Part
            FinalDir = Primary.Dir
            Shot.Origin = PacketOrigin
            Shot.Aim = ChosenAim
            Shot.HitPosition = HitPosition
            Shot.Part = AimPart
            Shot.Dir = FinalDir
            Shot.TrajectoryPoints = Primary.TrajectoryPoints
        end
    end

    local Motor, SavedC0 = Shot.Motor, Shot.SavedC0

    if not RageBotAPI.ValidateAppliedMagicRegistration(
        LocalTool,
        RealOrigin,
        Shot,
        TargetCharacter
    ) then
        if Motor and SavedC0 then
            pcall(function() Motor.C0 = SavedC0 end)
        end
        if IsRageMagicPathMode(Shot.Mode) and Shot.RegistrationKey then
            MarkRageMagicRegistrationFailed(TargetCharacter, Shot.RegistrationKey)
            RadiantAimEngine.ClearWallbangCache(TargetCharacter)
        end
        return false
    end

    if not ShotSlotReserved and not WaitForRageShotSlot(LocalTool) then
        if Motor and SavedC0 then
            pcall(function() Motor.C0 = SavedC0 end)
        end
        return false
    end

    local Key = GenerateRageShotId()
    local ProtocolTime = tick()
    local ProtectedTime = GetRageProtocolTimestamp(LocalTool)
    if type(ProtectedTime) == "number" and math.abs(ProtectedTime - ProtocolTime) <= 8 then
        ProtocolTime = ProtectedTime
    end
    local BulletType = GetRageBulletType(LocalTool)
    local BulletTable
    if Shot.Mode == "magic_ghost" then
        BulletTable = table.create(BulletCount)
        local GhostVector = FinalDir.Unit * 1000
        for BulletIndex = 1, BulletCount do
            BulletTable[BulletIndex] = GhostVector
        end
    elseif RageBotSettings.MagicBullet and type(Shot.BulletSampleMap) == "table" and #Shot.BulletSampleMap > 0 then
        BulletTable = table.create(BulletCount)
        for BulletIndex = 1, BulletCount do
            local Sample = Shot.BulletSampleMap[BulletIndex]
            local SampleDir = Sample and Sample.Dir or FinalDir
            if typeof(SampleDir) == "Vector3" and SampleDir.Magnitude > 0.001 then
                BulletTable[BulletIndex] = SampleDir.Unit * 650
            else
                BulletTable[BulletIndex] = FinalDir.Unit * 650
            end
        end
    elseif IsRageMagicPathMode(Shot.Mode) then
        BulletTable = table.create(BulletCount)
        local Scaled = FinalDir.Unit * 650
        for BulletIndex = 1, BulletCount do
            BulletTable[BulletIndex] = Scaled
        end
    else
        BulletTable = BuildRageBulletTable(
            LocalTool,
            FinalDir,
            PacketOrigin,
            ChosenAim,
            false
        )
    end

    if RageShotState.Sending then
        if Motor and SavedC0 then
            pcall(function() Motor.C0 = SavedC0 end)
        end
        return false
    end
    RageShotState.Sending = true
    RageBotAPI._LastFireClock = os.clock()

    local Humanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
    local HealthBefore = Humanoid and Humanoid.Health or nil

    local ShotGeneration = RespawnSafetyState and RespawnSafetyState.Generation or 0
    if RespawnSafetyState and RespawnSafetyState.Suspended then
        RageShotState.Sending = false
        return false
    end
    local Sent = false
    if ZFKLF then
        RageBotAPI._ReportedShots = RageBotAPI._ReportedShots or {}
        RageBotAPI._ReportedShots[Key] = os.clock()
    end
    local SendSuccess = pcall(function()
        GNX_S:FireServer(
            ProtocolTime,
            Key,
            LocalTool,
            "FDS9I83",
            PacketOrigin,
            BulletTable,
            BulletType
        )
    end)
    Sent = SendSuccess == true

    if Sent and ZFKLF then
        local UnitDirection = FinalDir.Magnitude > 0.001 and FinalDir.Unit or FinalDir
        local ReportDistance = 0
        if typeof(PacketOrigin) == "Vector3" and typeof(HitPosition) == "Vector3" then
            ReportDistance = (HitPosition - PacketOrigin).Magnitude
        elseif typeof(PacketOrigin) == "Vector3" and typeof(ChosenAim) == "Vector3" then
            ReportDistance = (ChosenAim - PacketOrigin).Magnitude
        end
        if ReportDistance < 0.05 then
            ReportDistance = 0.05
        end
        local ReportDelay = math.clamp(
            0.006 + GetRageNetworkPingSeconds() * 0.22 + ReportDistance / 14000,
            0.006,
            tonumber(RadiantAimEngine.Config.ReportDelayMaximum) or 0.060
        )
        if Shot.Mode == "magic_ghost" then
            ReportDelay = math.clamp(
                tonumber(RageBotSettings.Delay) or 0.15,
                0.01,
                0.5
            )
        end
        local ReportCount = math.max(#BulletTable, 1)
        local FrozenHitPosition = PacketOrigin + UnitDirection * ReportDistance
        if AimPart and AimPart:IsA("BasePart") then
            FrozenHitPosition = ClampRageHitPositionToPart(AimPart, FrozenHitPosition)
            local FixedDelta = FrozenHitPosition - PacketOrigin
            if FixedDelta.Magnitude > 0.05 then
                UnitDirection = FixedDelta.Unit
                ReportDistance = FixedDelta.Magnitude
                FrozenHitPosition = PacketOrigin + UnitDirection * ReportDistance
            end
        end
        local FrozenDirection = UnitDirection
        task.delay(ReportDelay, function()
            if RespawnSafetyState and (RespawnSafetyState.Suspended or ShotGeneration ~= RespawnSafetyState.Generation) then return end
            if not LocalTool or not LocalTool.Parent or not AimPart or not AimPart.Parent then return end
            for BulletIndex = 1, ReportCount do
                local Sample = type(Shot.BulletSampleMap) == "table" and Shot.BulletSampleMap[BulletIndex] or nil
                local SampleDir = FrozenDirection
                local SampleHit = FrozenHitPosition
                local SamplePart = AimPart
                if Sample then
                    SamplePart = Sample.Part or AimPart
                    if typeof(Sample.Dir) == "Vector3" and Sample.Dir.Magnitude > 0.001 then
                        SampleDir = Sample.Dir.Unit
                    end
                    if typeof(Sample.HitPosition) == "Vector3" and typeof(PacketOrigin) == "Vector3" then
                        local Dist = (Sample.HitPosition - PacketOrigin).Magnitude
                        if Dist < 0.05 then Dist = ReportDistance end
                        SampleHit = PacketOrigin + SampleDir * Dist
                    else
                        SampleHit = PacketOrigin + SampleDir * ReportDistance
                    end
                end
                RageBotAPI.FireRageHitReport(
                    LocalTool,
                    Key,
                    SamplePart,
                    SampleHit,
                    SampleDir,
                    BulletIndex
                )
            end
        end)
    end

    if Motor and SavedC0 then
        task.delay(0.05, function()
            pcall(function()
                Motor.C0 = SavedC0
            end)
        end)
    end

    if Sent then
        task.delay(0.08, function()
            if RespawnSafetyState and (RespawnSafetyState.Suspended or ShotGeneration ~= RespawnSafetyState.Generation) then return end
            if LocalTool and LocalTool.Parent then SynchronizeRageLocalAmmo(LocalTool) end
        end)

        if Hitmarker then
            pcall(function()
                Hitmarker:Fire(AimPart)
            end)
        end

        RegisterLocalAttack(
            TargetCharacter,
            AimPart,
            Key,
            LocalTool,
            "RageBot",
            PacketOrigin,
            FinalDir
        )

        if HitFeedbackState.BulletTracerEnabled then
            local SampleRoutes = Shot.BulletSamples
            if type(SampleRoutes) == "table" and #SampleRoutes > 0 then
                for _, Sample in ipairs(SampleRoutes) do
                    local Points = Sample.TrajectoryPoints
                    if type(Points) == "table" and #Points >= 2 then
                        for SegmentIndex = 1, #Points - 1 do
                            local SegmentStart = Points[SegmentIndex]
                            local SegmentEnd = Points[SegmentIndex + 1]
                            if typeof(SegmentStart) == "Vector3" and typeof(SegmentEnd) == "Vector3" then
                                SpawnDirectionalBulletTracer(SegmentStart, SegmentEnd, LocalTool, true)
                            end
                        end
                    else
                        SpawnDirectionalBulletTracer(Sample.Origin, Sample.Aim, LocalTool, true)
                    end
                end
            elseif type(Shot.TrajectoryPoints) == "table" and #Shot.TrajectoryPoints >= 2 then
                for SegmentIndex = 1, #Shot.TrajectoryPoints - 1 do
                    local SegmentStart = Shot.TrajectoryPoints[SegmentIndex]
                    local SegmentEnd = Shot.TrajectoryPoints[SegmentIndex + 1]
                    if typeof(SegmentStart) == "Vector3" and typeof(SegmentEnd) == "Vector3" then
                        SpawnDirectionalBulletTracer(SegmentStart, SegmentEnd, LocalTool, true)
                    end
                end
            else
                SpawnDirectionalBulletTracer(PacketOrigin, ChosenAim, LocalTool, true)
            end
        end

        if not RageShotState.PendingTarget then
            RageShotState.PendingTarget = TargetPlayer
            RageShotState.PendingCharacter = TargetCharacter
            RageShotState.PendingHumanoid = Humanoid
            RageShotState.PendingTool = LocalTool
            RageShotState.PendingPart = AimPart
            RageShotState.PendingKey = Key
            RageShotState.PendingHealth = HealthBefore
            RageShotState.PendingTime = os.clock()
            RageShotState.PendingOrigin = PacketOrigin
            RageShotState.PendingAim = ChosenAim
            RageShotState.PendingHitPosition = HitPosition
            if type(RageShotState.GetConfirmationWindow) == "function" then
                local ConfirmationDistance = typeof(PacketOrigin) == "Vector3" and typeof(HitPosition) == "Vector3"
                    and (HitPosition - PacketOrigin).Magnitude or 0
                RageShotState.PendingDeadline = RageShotState.PendingTime + RageShotState.GetConfirmationWindow(ConfirmationDistance)
            end
            RageShotState.PendingLineOfSight = Shot.Mode == "los" or Shot.Mode == "magic_los"
            RageShotState.PendingMode = Shot.Mode
            RageShotState.PendingRegistrationKey =
                Shot.RegistrationKey

        end

        local FailKey = tostring(TargetCharacter)
        if RadiantAimEngine._Fail[FailKey] then
            RadiantAimEngine._Fail[FailKey].Count = 0
        end
    end

    if Sent then
        RageBotAPI._PendingMagic = {
            Key = Key,
            Tool = LocalTool,
            HitPart = AimPart,
            HitPos = HitPosition,
            SampleAim = ChosenAim,
            Dir = FinalDir,
            Origin = PacketOrigin,
            Mode = Shot.Mode,
            Time = os.clock(),
        }
    else
        RageBotAPI._PendingMagic = nil
    end

    RageShotState.Sending = false
    return Sent == true
end


function RageBotAPI.FireRageHitReport(Tool, ShotId, TargetPart, HitPosition, DirectionVector, BulletIndex)
    local Events = ReplicatedStorage:FindFirstChild("Events")
    local ZFKLF = Events and Events:FindFirstChild("ZFKLF__H")
    if not ZFKLF or not Tool or not TargetPart then
        return
    end
    local Dir = Vector3.new(0, 0, -1)
    if typeof(DirectionVector) == "Vector3" and DirectionVector.Magnitude > 0.001 then
        Dir = DirectionVector.Unit
    end
    local Pos = HitPosition
    if typeof(Pos) ~= "Vector3" then
        Pos = TargetPart.Position
    end
    pcall(function()
        ZFKLF:FireServer(
            "🧈",
            Tool,
            ShotId,
            BulletIndex or 1,
            TargetPart,
            Pos,
            Dir
        )
    end)
end

function RageBotAPI.InstallVisualizeHitHook()
    if RageBotAPI._VisualizeHooked then
        return
    end
    RageBotAPI._VisualizeHooked = true

    local Events2 = ReplicatedStorage:FindFirstChild("Events2")
    local Visualize = Events2 and Events2:FindFirstChild("Visualize")
    local Events = ReplicatedStorage:FindFirstChild("Events")
    local ZFKLF = Events and Events:FindFirstChild("ZFKLF__H")
    if not Visualize or not Visualize:IsA("BindableEvent") or not ZFKLF then
        return
    end

    RageBotAPI._VisualizeConnection = Visualize.Event:Connect(function(_, shotCode, _, gun, _, startPos, bulletsPerShot)
        if not RageBotEnabled then
            return
        end

        local Reported = RageBotAPI._ReportedShots
        if type(Reported) == "table" then
            local CurrentTime = os.clock()
            for Code, Time in pairs(Reported) do
                if CurrentTime - (tonumber(Time) or 0) > 1.25 then Reported[Code] = nil end
            end
            if shotCode ~= nil and Reported[shotCode]
                and CurrentTime - (tonumber(Reported[shotCode]) or 0) <= 1.25
            then
                return
            end
        end

        local Tool = LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if not Tool or (gun and gun ~= Tool) then
            return
        end

        local TargetPlayer = RageBotCurrentTarget
        local Character = TargetPlayer and TargetPlayer.Character
        if not Character then
            return
        end

        local Head = Character:FindFirstChild("Head")
            or Character:FindFirstChild(RageBotSettings.TargetPart or "Head")
        if not Head then
            return
        end

        if IsRageDowned(TargetPlayer) then
            return
        end

        local HitPos = Head.Position
        local Origin = typeof(startPos) == "Vector3" and startPos or HitPos
        local Count = 1
        if type(bulletsPerShot) == "table" then
            Count = math.clamp(#bulletsPerShot, 1, 8)
        elseif type(bulletsPerShot) == "number" then
            Count = math.clamp(bulletsPerShot, 1, 8)
        end

        task.wait(0.005)
        for Idx = 1, Count do
            local Direction = CFrame.new(Origin, HitPos).LookVector
            pcall(function()
                ZFKLF:FireServer(
                    "🧈",
                    gun or Tool,
                    shotCode,
                    Idx,
                    Head,
                    HitPos,
                    Direction
                )
            end)
        end

        local Hitmarker = Tool:FindFirstChild("Hitmarker")
        if Hitmarker then
            pcall(function()
                Hitmarker:Fire(Head)
            end)
        end
    end)
end

function RageBotAPI.InstallVoltBulletHooks()
    if RageBotAPI._VoltHooksInstalled then
        return
    end
    RageBotAPI._VoltHooksInstalled = true
end

function RageBotAPI.Enable()
    if RageBotEnabled then return end

    if type(RageBotAPI.InstallVisualizeHitHook) == "function" then
        RageBotAPI.InstallVisualizeHitHook()
    end
    if type(RageBotAPI.InstallVoltBulletHooks) == "function" then
        RageBotAPI.InstallVoltBulletHooks()
    end

    RageBotEnabled = true
    RageBotStickyTarget = nil
    RageResolverTargetScan.LastScan = 0
    RageResolverTargetScan.Player = nil
    RageResolverTargetScan.Character = nil
    RageResolverTargetScan.Part = nil

    RageBotCoroutine = task.spawn(function()
        while RageBotEnabled do
            if RespawnSafetyState and RespawnSafetyState.Suspended then task.wait(0.15) continue end
            local LocalCharacter = GetRageCharacter(LocalPlayer)
            local LocalRoot = GetRageRootPart(LocalCharacter)
            local LocalTool = LocalCharacter and LocalCharacter:FindFirstChildOfClass("Tool")
            local IsGun = IsRageFirearm(LocalTool)
            if IsGun and UpdateRageReload(LocalTool) then
                task.wait(0.05)
                continue
            end

            local TargetPlayer, TargetCharacter, TargetPart = FindClosestTargetRage()
            RageBotCurrentTarget = TargetPlayer

            if TargetPlayer and TargetCharacter and TargetPart and LocalRoot and IsGun then
                local Humanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
                if IsRageTargetValid(TargetPlayer, TargetCharacter, Humanoid) and not IsRageDowned(TargetPlayer) then
                    local Fired = RageBotAPI.FireRageShot(
                        TargetPlayer,
                        TargetCharacter,
                        TargetPart,
                        LocalRoot,
                        LocalTool
                    )
                    if not Fired then
                        task.wait(0.05)
                    end
                else
                    RageBotCurrentTarget = nil
                end
            elseif not TargetPlayer then
                RageBotCurrentTarget = nil
            end
            task.wait(1 / 45)
        end
    end)
    if RageBotFOVConnection then RageBotFOVConnection:Disconnect() end
    RageBotFOVConnection = RunService.RenderStepped:Connect(UpdateRageBotFOV)
end

function RageBotAPI.Disable()
    if not RageBotEnabled then return end
    RageBotEnabled = false
    RageBotStickyTarget = nil
    RageBotCurrentTarget = nil
    RageResolverTargetScan.LastScan = 0
    RageResolverTargetScan.Player = nil
    RageResolverTargetScan.Character = nil
    RageResolverTargetScan.Part = nil
    RageMagicBulletCache.TargetPart = nil
    RageMagicBulletCache.Character = nil
    RageMagicBulletCache.Origin = nil
    RageMagicBulletCache.RealOrigin = nil
    RageMagicBulletCache.PartPosition = nil
    RageMagicBulletCache.HitPosition = nil
    RageMagicBulletCache.SampleAim = nil
    RageMagicBulletCache.Manipulated = nil
    RageMagicBulletCache.Time = 0
    if RadiantAimEngine and type(RadiantAimEngine.ClearWallbangCache) == "function" then
        RadiantAimEngine.ClearWallbangCache()
    end
    RageBotAPI._ReportedShots = {}
    RageShotState.NextServerShot, RageShotState.LastTool = 0, nil
    RageShotState.Sending = false
    if type(RageShotState.ClearPending) == "function" then RageShotState.ClearPending() end
    RageShotState.TargetFailures = setmetatable({}, { __mode = "k" })
    RageShotState.TargetBackoff = setmetatable({}, { __mode = "k" })
    RageMagicRegistrationState.Cache = setmetatable({}, { __mode = "k" })
    RageMagicProbeState.Cache = setmetatable({}, { __mode = "k" })
    RestoreRageShotSounds()
    ResetRageReloadState(nil)
    RageReloadState.AmmoCache = setmetatable({}, { __mode = "k" })
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
    local Farm = {
        Enabled = false,
        UserWantsFarm = false,
        Busy = false,
        Status = "Idle",
        DiedCount = 0,
        EarnMoneyTotal = Settings.EarnMoneyTotal,
        StartCash = 0,
        StartedAt = 0,
        LastNotifyAt = 0,
        LastDiedIncrementAt = 0,
        LastRejoinAt = 0,
        ProcessedList = {},
        SortedTargets = {},
        TempIgnoredTargets = {},
        ForcedNextTargetModel = nil,
        RetargetPending = false,
        CashAddedConnection = nil,
        CashAddedTextConnection = nil,
        LastCashAddedText = "",
        TargetConnections = {},
        DiedConnection = nil,
        RenderConnection = nil,
        AdminConnections = {},
        UI = {},
        State = {
            InProgress = false,
            CooldownUntil = 0,
            LastAttemptAt = 0,
            IsRising = false,
            HasReachedTargetY = false,
            SUZoneEntered = false,
            TowerZoneEntered = false,
            SW11ZoneEntered = false,
            CurrentZoneRoute = nil,
            SW11SavedEntryPathPoint = nil,
            SW11SavedVisualPath = nil,
            TowerFirstPosition = Vector3.new(-4520, 127, -783),
            TowerSecondPosition = Vector3.new(-4518, 149, -780),
            SW11FirstPosition = Vector3.new(-4693, -32, -717),
            SW11SecondPosition = Vector3.new(-4693, -44, -731),
            SW11ThirdPosition = Vector3.new(-4693, -32, -743),
            SUFirstPosition = Vector3.new(-3897, 4, -456),
            RecoveryLoopFixFrom = Vector3.new(-4475, -22, -363),
            RecoveryLoopFixTo = Vector3.new(-4481, 4, -362),
            TargetY = 4.8,
            LastTimeTick = 0,
            LastActiveAt = 0,
            LastMoveAt = 0,
            LastFistsRecoveryAt = 0,
            FistsRecoveryBusy = false,
            RetryCount = 0,
            LastShopMainPart = nil
        }
    }

    local TargetNames = {
        "MediumSafe_T_45",
        "MediumSafe_T_46",
        "MediumSafe_SEW_2",
        "MediumSafe_SEW_8",
        "MediumSafe_HO_24",
        "MediumSafe_HO_39",
        "MediumSafe_TS_20",
        "MediumSafe_VC_21",
        "MediumSafe_VC_30",
        "MediumSafe_VC_38",
        "SmallSafe_SW_11",
        "Register_HO_23",
        "Register_TS_27",
        "Register_TS_4"
    }

    local TargetPositions = {
        MediumSafe_SEW_2 = Vector3.new(-4312.640625, -93.04354095459, -813.551086425781),
        MediumSafe_T_46 = Vector3.new(-4513.88330078125, 153.078231811523, -805.10205078125),
        MediumSafe_VC_30 = Vector3.new(-4855.64794921875, -199.84228515625, -868.460571289062),
        SmallSafe_SW_11 = Vector3.new(-4683.93310546875, -32.621650695801, -832.013366699219),
        MediumSafe_HO_39 = Vector3.new(-4421.9951171875, 25.813669204712, -53.739181518555),
        MediumSafe_T_45 = Vector3.new(-4514.361328125, 153.078231811523, -859.273742675781),
        Register_HO_23 = Vector3.new(-4429.865234375, 25.892944335938, -41.588287353516),
        MediumSafe_HO_24 = Vector3.new(-4826.80078125, -77.030784606934, -189.607925415039),
        MediumSafe_TS_20 = Vector3.new(-4704.6767578125, 5.222457885742, -171.515075683594),
        Register_TS_27 = Vector3.new(-4676.37890625, 5.208802700043, -150.077056884766),
        Register_TS_4 = Vector3.new(-4676.37890625, 5.208802700043, -146.077056884766),
        MediumSafe_VC_38 = Vector3.new(-4749.26220703125, -199.84228515625, -972.707702636719),
        MediumSafe_VC_21 = Vector3.new(-4804.431640625, -199.84228515625, -972.726379394531),
        MediumSafe_SEW_8 = Vector3.new(-4711.03271484375, -149.143432617188, -868.823913574219)
    }

    local TargetNameSet = {}
    for _, name in ipairs(TargetNames) do
        TargetNameSet[name] = true
    end

    local SUTargetNames = {
        MediumSafe_VC_21 = true,
        MediumSafe_VC_30 = true,
        MediumSafe_VC_38 = true,
        MediumSafe_SEW_2 = true,
        MediumSafe_SEW_8 = true,
        MediumSafe_HO_24 = true
    }

    local TowerTargetNames = {
        MediumSafe_T_45 = true,
        MediumSafe_T_46 = true
    }

    local SW11TargetNames = {
        SmallSafe_SW_11 = true
    }

    local ZoneRoutes = {
        MediumSafe_HO_39 = {
            zone = "HO",
            lowPos = Vector3.new(-4450, 4, -44),
            highPos = Vector3.new(-4448, 25, -48)
        },
        Register_HO_23 = {
            zone = "HO",
            lowPos = Vector3.new(-4450, 4, -44),
            highPos = Vector3.new(-4448, 25, -48)
        },
        MediumSafe_TS_20 = {
            zone = "TS",
            lowPos = Vector3.new(-4602, 4, -153),
            highPos = Vector3.new(-4609, 4, -153)
        },
        Register_TS_27 = {
            zone = "TS",
            lowPos = Vector3.new(-4602, 4, -153),
            highPos = Vector3.new(-4609, 4, -153)
        },
        Register_TS_4 = {
            zone = "TS",
            lowPos = Vector3.new(-4602, 4, -153),
            highPos = Vector3.new(-4609, 4, -153)
        }
    }

    Environment.JXFarmTargetPositions = TargetPositions

    local function setUiText(control, text)
        if not control then
            return
        end
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
            if typeof(object) == "Instance" and object:IsA("TextLabel") then
                object.Text = text
            end
        end
    end

    local function setStatus(value)
        Farm.Status = tostring(value)
        Environment.JXFarmActivity = Farm.Status
        if Farm.UI.Status then
            setUiText(Farm.UI.Status, "Status: " .. Farm.Status)
        end
    end

    local function isTargetBroken(model)
        local values = model and model:FindFirstChild("Values")
        local broken = values and values:FindFirstChild("Broken")
        return broken and broken:IsA("BoolValue") and broken.Value == true
    end

    local function getTargetPart(model)
        if not model then
            return nil
        end
        if model:IsA("BasePart") then
            return model
        end
        local mainPart = model:FindFirstChild("MainPart")
        return mainPart and mainPart:IsA("BasePart") and mainPart or nil
    end

    local function isSafeTarget(model)
        return model ~= nil and TargetNameSet[model.Name] == true
    end

    local function getMap()
        return Workspace:FindFirstChild("Map")
    end

    local function cleanIgnoredTargets()
        local now = tick()
        for target, expiresAt in pairs(Farm.TempIgnoredTargets) do
            if not target.Parent or expiresAt <= now then
                Farm.TempIgnoredTargets[target] = nil
            end
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
                if part and part:IsA("BasePart") then
                    table.insert(targets, {
                        obj = object,
                        part = part,
                        distance = (part.Position - root.Position).Magnitude
                    })
                end
            end
        end
        table.sort(targets, function(left, right)
            return left.distance < right.distance
        end)
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
            if target.obj.Parent and target.part.Parent and not Farm.ProcessedList[target.obj] then
                return target.obj, target.part
            end
        end
        Farm.ProcessedList = {}
        for _, target in ipairs(rebuildTargets()) do
            if target.obj.Parent and target.part.Parent then
                return target.obj, target.part
            end
        end
        return nil, nil
    end

    local function ClearFarmESP()
        local map = getMap()
        local targetFolder = map and map:FindFirstChild("BredMakurz")
        if not targetFolder then
            return
        end
        for _, object in ipairs(targetFolder:GetChildren()) do
            local highlight = object:FindFirstChild("ESP_Highlight")
            local billboard = object:FindFirstChild("ESP_Billboard")
            if highlight then
                highlight:Destroy()
            end
            if billboard then
                billboard:Destroy()
            end
        end
    end

    local function disconnectTargetConnections()
        for object, connection in pairs(Farm.TargetConnections) do
            if connection then
                connection:Disconnect()
            end
            Farm.TargetConnections[object] = nil
        end
    end

    local function bindTargetModel(model)
        if not model or not model:IsA("Model") or not isSafeTarget(model) or Farm.TargetConnections[model] then
            return
        end
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
        if not targetFolder then
            return
        end
        for _, object in ipairs(targetFolder:GetChildren()) do
            bindTargetModel(object)
        end
        Farm.TargetConnections.TargetAdded = targetFolder.ChildAdded:Connect(function(object)
            task.defer(function()
                bindTargetModel(object)
    end)
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
        if not root or not humanoid then
            return nil
        end
        local path = PathfindingService:CreatePath({
            AgentRadius = math.max(2, root.Size.X * 0.5),
            AgentHeight = math.max(5, humanoid.HipHeight + root.Size.Y + 2),
            AgentCanJump = true,
            AgentCanClimb = true,
            WaypointSpacing = tonumber(Settings.WaypointSpacing) or 3,
            Costs = {}
        })
        local ok = safeCall(path.ComputeAsync, path, root.Position, destination)
        if not ok or path.Status ~= Enum.PathStatus.Success then
            return nil
        end
        return path:GetWaypoints()
    end

    local function facePosition(position)
        local root = getRoot()
        if root then
            local flat = Vector3.new(position.X, root.Position.Y, position.Z)
            if (flat - root.Position).Magnitude > 0.01 then
                root.CFrame = CFrame.lookAt(root.Position, flat)
            end
        end
    end

    local function moveToPosition(position, statusText)
        local root = getRoot()
        local humanoid = getHumanoid()
        if not root or not humanoid or isDead() then
            return false
        end
        setStatus(statusText or "Moving To Target")
        Environment.JXFarmMove = true
        local waypoints = computePath(position)
        if not waypoints then
            waypoints = {{Position = position, Action = Enum.PathWaypointAction.Walk}}
        end
        for _, waypoint in ipairs(waypoints) do
            if not Farm.Enabled or isDead() then
                Environment.JXFarmMove = false
                return false
            end
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            local distance = (root.Position - waypoint.Position).Magnitude
            local duration = math.max(distance / math.max(Settings.MoveSpeed, 1), 0.05)
            local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(waypoint.Position, waypoint.Position + root.CFrame.LookVector)
            })
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
        return (root.Position - position).Magnitude <= 12
    end

    local function moveRoute(positions, statusText)
        for _, position in ipairs(positions) do
            if not moveToPosition(position, statusText) then
                return false
            end
        end
        return true
    end

    local function enterTower(model, part)
        Farm.State.TowerZoneEntered = true
        return moveRoute({
            Farm.State.TowerFirstPosition,
            Farm.State.TowerSecondPosition,
            part.Position
        }, "Moving To Target")
    end

    local function leaveTower()
        if not Farm.State.TowerZoneEntered then
            return true
        end
        setStatus("Leaving Tower")
        local moved = moveRoute({
            Farm.State.TowerSecondPosition,
            Farm.State.TowerFirstPosition
        }, "Leaving Tower")
        Farm.State.TowerZoneEntered = false
        setStatus("Idle")
        return moved
    end

    local function enterSW11(model, part)
        Farm.State.SW11ZoneEntered = true
        local root = getRoot()
        Farm.State.SW11SavedEntryPathPoint = root and root.Position or nil
        Farm.State.SW11SavedVisualPath = {
            Farm.State.SW11FirstPosition,
            Farm.State.SW11SecondPosition,
            Farm.State.SW11ThirdPosition
        }
        setStatus("Entering SW_11")
        return moveRoute({
            Farm.State.SW11FirstPosition,
            Farm.State.SW11SecondPosition,
            Farm.State.SW11ThirdPosition,
            part.Position
        }, "Entering SW_11")
    end

    local function leaveSW11()
        if not Farm.State.SW11ZoneEntered then
            return true
        end
        setStatus("Leaving SW_11")
        local moved = moveRoute({
            Farm.State.SW11ThirdPosition,
            Farm.State.SW11SecondPosition,
            Farm.State.SW11FirstPosition
        }, "Leaving SW_11")
        if moved and Farm.State.SW11SavedEntryPathPoint then
            moved = moveToPosition(Farm.State.SW11SavedEntryPathPoint, "Leaving SW_11")
        end
        Farm.State.SW11ZoneEntered = false
        Farm.State.SW11SavedEntryPathPoint = nil
        Farm.State.SW11SavedVisualPath = nil
        setStatus("Idle")
        return moved
    end

    local function enterZoneRoute(model, part)
        local route = ZoneRoutes[model.Name]
        if not route then
            return false
        end
        Farm.State.CurrentZoneRoute = route
        return moveRoute({route.lowPos, route.highPos, part.Position}, "Moving To Target")
    end

    local function leaveZoneRoute()
        local route = Farm.State.CurrentZoneRoute
        if not route then
            return true
        end
        local moved = moveRoute({route.highPos, route.lowPos}, "Leaving " .. route.zone)
        Farm.State.CurrentZoneRoute = nil
        return moved
    end

    local function enterSURoute(model, part)
        Farm.State.SUZoneEntered = true
        return moveRoute({Farm.State.SUFirstPosition, part.Position}, "Moving To Target")
    end

    local function leaveSURoute()
        if not Farm.State.SUZoneEntered then
            return true
        end
        local moved = moveToPosition(Farm.State.SUFirstPosition, "Leaving SU")
        Farm.State.SUZoneEntered = false
        return moved
    end

    local function moveToTargetByRoute(model, part)
        if SW11TargetNames[model.Name] then
            return enterSW11(model, part)
        end
        if TowerTargetNames[model.Name] then
            return enterTower(model, part)
        end
        if ZoneRoutes[model.Name] then
            return enterZoneRoute(model, part)
        end
        if SUTargetNames[model.Name] then
            return enterSURoute(model, part)
        end
        return moveToPosition(part.Position, "Moving To Target")
    end

    local function teleportRecovery(position)
        local root = getRoot()
        if not root or not position then
            return false
        end
        setStatus("Teleport Recovery")
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.new(position)
        task.wait(Settings.RecoveryIdleSec)
        return (root.Position - position).Magnitude <= 6
    end

    local function runRecoveryLoopFix()
        return moveRoute({
            Farm.State.RecoveryLoopFixFrom,
            Farm.State.RecoveryLoopFixTo
        }, "Recovery Move")
    end

    local function recoveryMove(position)
        local root = getRoot()
        if not root or not position then
            return false
        end
        setStatus("Recovery Move")
        if moveToPosition(position, "Recovering Path") then
            return true
        end
        if runRecoveryLoopFix() and moveToPosition(position, "Recovering Path") then
            return true
        end
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
        if Farm.State.RetryCount <= 2 and part and recoveryMove(part.Position) then
            return true
        end
        Farm.TempIgnoredTargets[model] = tick() + math.max(1, tonumber(Settings.IgnoreDuration) or 6)
        Farm.RetargetPending = true
        return false
    end

    local function processTargetMoveOutcome(model, part, moved)
        if moved then
            return handlePostMoveSuccess(model)
        end
        return handlePostMoveFailure(model, part)
    end

local function getTool(namePattern)
        local character = getCharacter()
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({character, backpack}) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and string.find(string.lower(tool.Name), string.lower(namePattern), 1, true) then
                        return tool
                    end
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
        if humanoid then
            safeCall(humanoid.UnequipTools, humanoid)
        end
    end

    local function hasFistsTool()
        return getTool("fists") ~= nil
    end

    local ShopItemContracts = {
        Crowbar = {
            ShopType = "IllegalStore",
            Category = "Melees",
            ShopModelName = "Dealer"
        },
        Lockpick = {
            ShopType = "LegalStore",
            Category = "Misc",
            ShopModelName = "ArmoryDealer"
        }
    }

    local function getShopMainPart(contract)
        local map = getMap()
        local shops = map and map:FindFirstChild("Shopz")
        local shop = shops and shops:FindFirstChild(contract.ShopModelName)
        local mainPart = shop and shop:FindFirstChild("MainPart")
        return mainPart and mainPart:IsA("BasePart") and mainPart or nil
    end

    local function buyItem(itemName)
        local contract = ShopItemContracts[itemName]
        if not contract then
            return false
        end
        local shopMainPart = getShopMainPart(contract)
        if not shopMainPart then
            return false
        end
        if not moveToPosition(shopMainPart.Position, "Moving To Dealer for " .. itemName) then
            return false
        end
        task.wait(Settings.ShopPreOpenSec)
        setStatus(itemName == "Lockpick" and "Buying Lockpicks (idle 5s in shop)" or "Buying " .. itemName)
        if ShopProtectionRemote then
            safeCall(
                ShopProtectionRemote.FireServer,
                ShopProtectionRemote,
                true,
                "shop",
                shopMainPart,
                contract.ShopType
            )
        end
        local ok, success = safeCall(
            ShopRemote.InvokeServer,
            ShopRemote,
            contract.ShopType,
            contract.Category,
            itemName,
            shopMainPart,
            nil,
            true
        )
        if ShopProtectionRemote then
            safeCall(ShopProtectionRemote.FireServer, ShopProtectionRemote, false)
        end
        task.wait(Settings.ShopAfterOpenSec)
        if not ok or not success then
            return false
        end
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
            if not hasFistsTool() then
                return false
            end
            local lockpick = getTool("lockpick")
            if not lockpick then
                setStatus("Moving To Dealer for Lockpick")
                if not buyItem("Lockpick") then
                    return false
                end
            end
            return true
        end
        local crowbar = getTool("crowbar")
        if not crowbar then
            setStatus("Buying Crowbar")
            if not buyItem("Crowbar") then
                return false
            end
        end
        return true
    end

    local function countToolsByName(name)
        local total = 0
        local character = getCharacter()
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        for _, container in ipairs({character, backpack}) do
            if container then
                for _, item in ipairs(container:GetChildren()) do
                    if item:IsA("Tool") and item.Name == name then
                        total += 1
                    end
                end
            end
        end
        return total
    end

    local function findNearestLockpickShopPart()
        local root = getRoot()
        local selected
        local selectedDistance = math.huge
        for _, contract in ipairs({
            ShopItemContracts.Lockpick,
            ShopItemContracts.Crowbar
        }) do
            local part = getShopMainPart(contract)
            if part then
                local distance = root and (part.Position - root.Position).Magnitude or 0
                if distance < selectedDistance then
                    selected = part
                    selectedDistance = distance
                end
            end
        end
        return selected
    end

    local function purchaseLockpickAt(shopPart)
        if not shopPart then
            return false
        end
        local illegalOk, illegalAccepted, illegalMessage = safeCall(
            ShopRemote.InvokeServer,
            ShopRemote,
            "IllegalStore",
            "Misc",
            "Lockpick",
            shopPart,
            nil,
            true,
            nil
        )
        task.wait(0.25)
        local legalOk, legalAccepted, legalMessage = safeCall(
            ShopRemote.InvokeServer,
            ShopRemote,
            "LegalStore",
            "Misc",
            "Lockpick",
            shopPart,
            nil,
            true
        )
        return illegalOk
            and (illegalAccepted == true or illegalMessage == "PURCHASE COMPLETE")
            or legalOk
            and (legalAccepted == true or legalMessage == "PURCHASE COMPLETE")
    end

    local function buyLockpickBatch(quantity)
        quantity = math.max(1, math.floor(tonumber(quantity) or 7))
        local shopPart = findNearestLockpickShopPart()
        if not shopPart then
            return false
        end
        if not moveToPosition(shopPart.Position, "Moving To Dealer for Lockpick") then
            return false
        end
        local startingCount = countToolsByName("Lockpick")
        local successfulPurchases = 0
        for _ = 1, quantity do
            if not Farm.Enabled then
                break
            end
            if purchaseLockpickAt(shopPart) then
                successfulPurchases += 1
            end
            task.wait(0.20)
        end
        task.wait(0.75)
        return countToolsByName("Lockpick") > startingCount or successfulPurchases > 0
    end

    local function dropLockpick(tool)
        local root = getRoot()
        if not tool or not DropToolRemote or not root then
            return false
        end
        local ok = safeCall(
            DropToolRemote.FireServer,
            DropToolRemote,
            tool,
            nil,
            root.Position
        )
        return ok
    end

    local function tryLockpickTarget(target)
        local tool = getTool("Lockpick")
        if not tool then
            return false, "lockpick_missing"
        end
        if not equipTool(tool) then
            return false, "lockpick_equip_failed"
        end
        local remote = tool:FindFirstChild("Remote")
        if not remote or not remote:IsA("RemoteFunction") then
            return false, "lockpick_remote_missing"
        end
        local startOk, token = safeCall(
            remote.InvokeServer,
            remote,
            "S",
            target,
            "s"
        )
        if startOk and type(token) == "number" then
            task.wait(0.25)
            local finishOk = safeCall(
                remote.InvokeServer,
                remote,
                "D",
                target,
                "s",
                token
            )
            return finishOk, finishOk and "lockpick_success" or "lockpick_finish_failed"
        end
        dropLockpick(tool)
        return false, "lockpick_failed"
    end

    local function strikeTargetWithCrowbar(target)
        local tool = getTool("Crowbar")
        local character = getCharacter()
        local targetPart = getTargetPart(target)
        local rightArm = character and (
            character:FindFirstChild("Right Arm")
            or character:FindFirstChild("RightHand")
        )
        if not MeleeRemote
            or not MeleeHitRemote
            or not tool
            or not character
            or not rightArm
            or not targetPart
        then
            return false
        end
        equipTool(tool)
        local invokeOk, token = safeCall(
            MeleeRemote.InvokeServer,
            MeleeRemote,
            "🍞",
            tick(),
            tool,
            "DZDRRRKI",
            target,
            "Register"
        )
        if invokeOk and type(token) == "number" then
            local fireOk = safeCall(
                MeleeHitRemote.FireServer,
                MeleeHitRemote,
                "🍞",
                tick(),
                tool,
                "2389ZFX34",
                token,
                false,
                rightArm,
                targetPart,
                target,
                targetPart.Position,
                targetPart.Position
            )
            return fireOk
        end
        return invokeOk
    end

    local function breakTarget(target, targetPart)
        if not target or not target.Parent then
            return false
        end
        if isTargetBroken(target) then
            return true
        end
        if Settings.BreakingMethod == "Crowbar" then
            if not getTool("Crowbar") and not buyItem("Crowbar") then
                return false
            end
            local startedAt = tick()
            while Farm.Enabled
                and target.Parent
                and not isTargetBroken(target)
                and tick() - startedAt < 30
            do
                targetPart = getTargetPart(target)
                local root = getRoot()
                if not targetPart or not root then
                    return false
                end
                if (targetPart.Position - root.Position).Magnitude > 8 then
                    if not moveToTargetByRoute(target, targetPart) then
                        return false
                    end
                end
                strikeTargetWithCrowbar(target)
                task.wait(0.25)
            end
        else
            local startedAt = tick()
            local nextBatchSize = 7
            while Farm.Enabled
                and target.Parent
                and not isTargetBroken(target)
                and tick() - startedAt < 120
            do
                targetPart = getTargetPart(target)
                local root = getRoot()
                if not targetPart or not root then
                    return false
                end
                if (targetPart.Position - root.Position).Magnitude > 8 then
                    if not moveToTargetByRoute(target, targetPart) then
                        return false
                    end
                end
                if not getTool("Lockpick") then
                    if not buyLockpickBatch(nextBatchSize) then
                        return false
                    end
                    nextBatchSize = 15
                    if target.Parent and not isTargetBroken(target) then
                        targetPart = getTargetPart(target)
                        if targetPart then
                            moveToTargetByRoute(target, targetPart)
                        end
                    end
                end
                local opened = tryLockpickTarget(target)
                if opened then
                    local completedAt = tick()
                    while target.Parent
                        and not isTargetBroken(target)
                        and tick() - completedAt < 12
                    do
                        task.wait(0.10)
                    end
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
        if not spawnedBread or not object then
            return nil
        end
        if object.Parent ~= spawnedBread then
            object = object.Parent
        end
        if object and object:IsA("BasePart") and object.Parent == spawnedBread then
            return object
        end
        return nil
    end

    local function collectCashObject(object)
        local cashObject = normalizeCashObject(object)
        local root = getRoot()
        if not cashObject or not root or (cashObject.Position - root.Position).Magnitude >= 10 then
            return false
        end
        local ok = safeCall(CashPickupRemote.FireServer, CashPickupRemote, cashObject, nil)
        return ok
    end

    local function clearNearbyCashNoMove()
        if not Settings.AutoMoney then
            return 0
        end
        local root = getRoot()
        local spawnedBread = getSpawnedBread()
        if not root or not spawnedBread then
            return 0
        end
        local collected = 0
        for _, cashObject in ipairs(spawnedBread:GetChildren()) do
            if cashObject:IsA("BasePart") and cashObject.Transparency < 1 and (cashObject.Position - root.Position).Magnitude <= Settings.PickupDistance then
                if collectCashObject(cashObject) then
                    collected += 1
                end
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
        if not root or not atmFolder then
            return nil
        end
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
        if not Settings.AutoAllowance then
            return false
        end
        local allowance = readAllowanceText()
        if not string.find(string.upper(allowance), "READY", 1, true) then
            return false
        end
        local atmMainPart = findNearestATMMainPart()
        if not atmMainPart then
            return false
        end
        setStatus("Claiming Allowance")
        local ok, success = safeCall(
            ClaimAllowanceRemote.InvokeServer,
            ClaimAllowanceRemote,
            atmMainPart,
            nil
        )
        task.wait(0.5)
        return ok and success == true
    end

    local function tryDeposit(force)
        if not Settings.AutoDeposit and not force then
            return false
        end
        local cash = readCashAmountValue()
        local threshold = math.max(1, tonumber(Settings.AutoDepositThresholdK) or 5) * 1000
        if not force and cash < threshold then
            return false
        end
        local atmMainPart = findNearestATMMainPart()
        if not atmMainPart then
            return false
        end
        Farm.State.InProgress = true
        setStatus("Depositing Cash")
        local moved = moveToPosition(atmMainPart.Position, "Depositing Cash")
        local success = false
        if moved then
            local ok, result = safeCall(
                ATMRemote.InvokeServer,
                ATMRemote,
                "DP",
                cash,
                atmMainPart
            )
            success = ok and result == true
            task.wait(1)
        end
        Farm.State.InProgress = false
        return moved and success
    end

    local function TryDepositAllNow()
        return tryDeposit(true)
    end

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
        if not model or not part then
            return false
        end
        local moved = moveToTargetByRoute(model, part)
        if not processTargetMoveOutcome(model, part, moved) then
            return false
        end
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
        if not cash then
            return nil
        end
        local added = cash:FindFirstChild("Added")
        if added and added:IsA("TextLabel") then
            return added
        end
        for _, object in ipairs(cash:GetDescendants()) do
            if object:IsA("TextLabel") and string.lower(object.Name) == "added" then
                return object
            end
        end
        return nil
    end

    local function processCashAddedText(text)
        text = trim(text)
        if text == "" or text == Farm.LastCashAddedText then
            return
        end
        Farm.LastCashAddedText = text
        if text:sub(1, 1) ~= "+" then
            return
        end
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
            Farm.CashAddedTextConnection = label:GetPropertyChangedSignal("Text"):Connect(function()
                processCashAddedText(label.Text)
            end)
            processCashAddedText(label.Text)
            return
        end
        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            Farm.CashAddedConnection = playerGui.DescendantAdded:Connect(function(object)
                if object:IsA("TextLabel") and string.lower(object.Name) == "added" then
                    task.defer(bindCashTracking)
                end
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
        if fallbackTotal > Farm.EarnMoneyTotal then
            Farm.EarnMoneyTotal = fallbackTotal
        end
        if Farm.UI.Died then
            setUiText(Farm.UI.Died, "Died: " .. tostring(Farm.DiedCount))
        end
        if Farm.UI.Bank then
            setUiText(Farm.UI.Bank, "Bank: " .. readBankAmountText())
        end
        if Farm.UI.Allowance then
            setUiText(Farm.UI.Allowance, "Allowance: " .. readAllowanceText())
        end
        if Farm.UI.Time then
            setUiText(Farm.UI.Time, string.format("Time: %02d:%02d:%02d", hours, minutes, seconds))
        end
        if Farm.UI.EarnMoney then
            setUiText(Farm.UI.EarnMoney, "Earn Money: " .. tostring(math.floor(Farm.EarnMoneyTotal)))
        end
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

    --[[
    Presumed administrator IDs from the pseudocode.
    local AssumedAdministratorUserIds = {
        3294804378,
        93676120,
        54087314,
        81275825,
        140837601,
        1229486091,
        46567801,
        418086275,
        29706395,
        3717066084,
        1424338327,
        5046662686,
        5046661126,
        5046659439,
        418199326,
        1024216621,
        1810535041,
        63238912,
        111250044,
        63315426,
        730176906,
        141193516,
        194512073,
        193945439,
        412741116,
        195538733,
        102045519,
        955294,
        957835150,
        25689921,
        366613818,
        281593651,
        455275714,
        208929505,
        96783330,
        156152502,
        93281166,
        959606619,
        142821118,
        632886139,
        175931803,
        122209625,
        278097946,
        142989311,
        1517131734,
        446849296,
        87189764,
        67180844,
        9212846,
        47352513,
        48058122,
        155413858,
        10497435,
        513615792,
        55893752,
        55476024,
        151691292,
        136584758,
        16983447,
        3111449,
        94693025,
        271400893,
        5005262660,
        295331237,
        64489098,
        244844600,
        114332275,
        25048901,
        69262878,
        50801509,
        92504899,
        42066711,
        50585425,
        31365111,
        166406495,
        2457253857,
        29761878,
        21831137,
        948293345,
        439942262,
        38578487,
        1163048,
        7713309208,
        3659305297,
        15598614,
        34616594,
        626833004,
        198610386,
        153835477,
        3923114296,
        3937697838,
        102146039,
        119861460,
        371665775,
        1206543842,
        93428604,
        1863173316,
        90814576,
        374665997,
        423005063,
        140172831,
        42662179,
        9066859,
        438805620,
        14855669,
        727189337,
        1871290386,
        608073286,
    }
    ]]
    local function detectAdmin(player)
        if player == LocalPlayer then
            return false
        end
        if player:GetAttribute("IsAdmin") == true then
            return true
        end
        for _, containerName in ipairs({"leaderstats", "Data", "Values", "Admins", "Adminz"}) do
            local container = player:FindFirstChild(containerName)
            if container then
                local value = container:FindFirstChild("Admin") or container:FindFirstChild("IsAdmin")
                if value and value:IsA("BoolValue") and value.Value then
                    return true
                end
            end
        end
        return false
    end

    local function rejoin(reason)
        if not Settings.AntiRejoin or tick() - Farm.LastRejoinAt < 10 then
            return
        end
        Farm.LastRejoinAt = tick()
        notify("JX", tostring(reason or "Rejoining"), 4)
        safeCall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
    end

    local function adminCheck()
        if not Settings.AdminCheck then
            return false
        end
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
            if Settings.AdminCheck and detectAdmin(player) then
                rejoin("Admin detected: " .. player.Name)
            end
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
                if text:find("kick", 1, true) or text:find("disconnect", 1, true) or text:find("error", 1, true) then
                    rejoin("GuiService: " .. tostring(message))
                end
            end))
        end)
    end

    local function bindAntiAFK()
        LocalPlayer.Idled:Connect(function()
            if not Settings.AntiAFK then
                return
            end
            safeCall(VirtualUser.CaptureController, VirtualUser)
            safeCall(VirtualUser.ClickButton2, VirtualUser, Vector2.new())
        end)
    end

    local NoFallState = {
        HookInstalled = false,
        CharacterConnection = nil
    }

    local function applyNoFallCharacterState()
        if not Settings.AntiFallDamage then
            return
        end
        local character = getCharacter()
        if not character then
            return
        end
        local charStats = character:FindFirstChild("CharStats")
        if not charStats then
            return
        end
        local playerStats = charStats:FindFirstChild(LocalPlayer.Name)
            or charStats:FindFirstChild(tostring(LocalPlayer.UserId))
            or charStats
        local ragdollSwitch = playerStats:FindFirstChild("RagdollSwitch")
            or charStats:FindFirstChild("RagdollSwitch", true)
        local ragdollTime = playerStats:FindFirstChild("RagdollTime")
            or charStats:FindFirstChild("RagdollTime", true)
        if ragdollSwitch and ragdollSwitch:IsA("BoolValue") then
            ragdollSwitch.Value = false
        end
        if ragdollTime and (ragdollTime:IsA("NumberValue") or ragdollTime:IsA("IntValue")) then
            ragdollTime.Value = 0
        end
    end

    local function bindNoFall()
        Environment.CV2_NoFall = Settings.AntiFallDamage
        if not NoFallState.HookInstalled
            and type(hookmetamethod) == "function"
            and type(newcclosure) == "function"
            and type(getnamecallmethod) == "function"
        then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
                if Settings.AntiFallDamage
                    and Environment.CV2_NoFall
                    and self == FallRemote
                    and getnamecallmethod() == "FireServer"
                    and select(1, ...) == "FlllD"
                then
                    return nil
                end
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

    local InvisState = {
        Enabled = false,
        WarningGui = nil,
        WarningLabel = nil,
        Animation = nil,
        Track = nil,
        HeartbeatConnection = nil
    }

    local function ensureInvisWarningGui()
        if InvisState.WarningGui and InvisState.WarningGui.Parent then
            return InvisState.WarningGui, InvisState.WarningLabel
        end
        local existing = UiParent:FindFirstChild("JXInvisWarningGUI")
            or UiParent:FindFirstChild("InvisWarningGUI")
            or UiParent:FindFirstChild("WarningGUI")
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
        label.Font = Enum.Font.BuilderSansBold
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
        if not character then
            return
        end
        for _, object in ipairs(character:GetDescendants()) do
            if object:IsA("BasePart")
                and object.Name ~= "HumanoidRootPart"
                and (fromTransparency == nil or object.Transparency == fromTransparency)
            then
                if fromTransparency ~= nil or object.Transparency ~= 1 then
                    object.Transparency = toTransparency
                end
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
        if not InvisState.Enabled then
            return
        end
        local character = getCharacter()
        local humanoid = getHumanoid(character)
        local root = getRoot(character)
        local torso = character and character:FindFirstChild("Torso")
        local camera = Workspace.CurrentCamera
        if not character or not humanoid or not root or not torso or not camera then
            return
        end
        camera.CameraSubject = root
        if InvisState.WarningLabel then
            InvisState.WarningLabel.Visible = humanoid.FloorMaterial == Enum.Material.Air
        end
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
        if InvisState.HeartbeatConnection then
            return
        end
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
        if camera and root then
            camera.CameraSubject = root
        end
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
        if humanoid then
            humanoid.CameraOffset = Vector3.zero
        end
        if camera and humanoid then
            camera.CameraSubject = humanoid
        end
        setVisibleBodyTransparency(character, 0.5, 0)
        if InvisState.WarningLabel then
            InvisState.WarningLabel.Visible = false
        end
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
                    if InvisState.Enabled then
                        task.defer(invisEnable)
                    end
                end
                task.wait(1)
            end
        end)
    end

    local function performAutoPlayRemoteSequence()
        local invoked = false
        if AutoPlayRemote and AutoPlayRemote:IsA("RemoteFunction") then
            local ok = safeCall(
                AutoPlayRemote.InvokeServer,
                AutoPlayRemote,
                "",
                "\15daz\18tough\19"
            )
            invoked = ok
        end
        if UpdateClientRemote and UpdateClientRemote:IsA("RemoteEvent") then
            safeCall(UpdateClientRemote.FireServer, UpdateClientRemote)
        end
        return invoked
    end

    local function bindLoadTimeDetection()
        local state = Environment.JXFarmAutoPlayState
        if type(state) ~= "table" then
            state = {
                enabled = Settings.AutoPlay,
                busy = false,
                loadTimeDetected = false,
                loadTimeReadyAt = 0
            }
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
            for _, entry in ipairs(LogService:GetLogHistory()) do
                inspect(entry.message or entry.Message or entry.text or "")
            end
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
                    Webhook.send("JX Farm Update", Farm.Status, {
                        {name = "Status", value = Farm.Status, inline = true},
                        {name = "Cash", value = readCashAmountText(), inline = true},
                        {name = "Bank", value = readBankAmountText(), inline = true},
                        {name = "Earn Money", value = tostring(math.floor(Farm.EarnMoneyTotal)), inline = true},
                        {name = "Died", value = tostring(Farm.DiedCount), inline = true},
                        {name = "Job ID", value = tostring(game.JobId), inline = false}
                    })
                end
                task.wait(1)
            end
        end)
    end

    local function farmStep()
        if adminCheck() then
            return
        end
        if isDead() then
            setStatus("Dead")
            task.wait(Settings.FarmDeadWaitSec)
            return
        end
        if Settings.AutoMoney then
            clearNearbyCashNoMove()
        end
        if Settings.AutoAllowance then
            claimAllowance()
        end
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
        if Farm.Enabled and Farm.Busy then
            return
        end
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
        label.Font = Enum.Font.BuilderSans
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
        button.Font = Enum.Font.BuilderSansBold
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
        title.Font = Enum.Font.BuilderSansBold
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
        input.Font = Enum.Font.BuilderSans
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

function FindAllATMs()
    local Atms = {}
    for Unused, ObjectValue in ipairs(workspace:GetDescendants()) do
        if ObjectValue:IsA("BasePart") and string.lower(ObjectValue.Name) == "atm" then table.insert(Atms, ObjectValue) end
    end
    return Atms
end

function SortATMsByDistance(Atms)
    local RootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not RootPart then return Atms end
    table.sort(Atms, function(FirstValue, ButtonItem) return(RootPart.Position - FirstValue.Position).Magnitude < (RootPart.Position - ButtonItem.Position).Magnitude end)
    return Atms
end

function IsAllowanceAvailable()
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

function InteractWithATM()
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

function AutoATMLoop()
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

function FullBrightApply()
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

function FullBrightRestore()
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

S = { ChinaHat = { Enabled = false, Model = nil, Motor = nil, Connection = nil, CharacterConnection = nil, Time = 0, Color = Color3.fromRGB(42, 238, 156), Transparency = 0.18, Scale =
    1.05, Height = 0.82, Rainbow = false, RainbowSpeed = 0.10, SpinSpeed = 18, Segments = 32, SurfaceBeams = {}, OutlineBeams = {}, Attachments = {}, AppearanceAccumulator = 0,
    AppearanceInterval = 1 / 60, AppearanceBatchIndex = 1, AppearanceBatchSize = 8 }, AngelWings = { Enabled = false, Model = nil, RenderConnection = nil, CharacterConnection = nil, Phase =
    0, PreviousStroke = -1, StrokeVelocity = 0, CurrentActivity = 0.62, CoreColor = Color3.fromRGB(224, 255, 240), GlowColor = Color3.fromRGB(42, 238, 156), Transparency = 0.18, Scale = 1.30,
    HeightOffset = -0.25, BackOffset = 0.68, SideOffset = 0.14, FlapSpeed = 0.90, Reactive = true, Style = "Seraph", LeftMotor = nil, RightMotor = nil, Feathers = {}, Beams = {}, Emitters =
    {}, Trails = {}, FeatherAccumulator = 0, FeatherInterval = 1 / 60, FeatherBatchIndex = 1, FeatherBatchSize = 10, CachedCharacter = nil, CachedHumanoid = nil, CachedRootPart = nil,
    EmitterAccumulator = 0, EmitterInterval = 0.10 }, AimBot = { Enabled = false, Type = "Aimbot", Smoothness = 0.1, FOV = 100, ShowFOV = true, FOVColor = Color3.fromRGB(255, 255, 255), FOVTransparency = 0.5,
    FOVGlow = false, FOVGlowColor = Color3.fromRGB(54, 218, 145), FOVGlowTransparency = 0.18, FOVGlowThickness = 8, WallCheck = true, DownedCheck = true, Prediction = 100, TargetPart =
    "Head", Resolver = true, ResolverMode = "Adaptive", ResolverStrength = 0.85, ResolverMaxSpeed = 190, ResolverDesyncThreshold = 18,
    Connection = nil, Target = nil, CurrentTarget = nil, CachedScanTarget = nil, LastTargetScan = 0, TargetScanInterval = 1 / 20,
    PositionCacheCharacter = nil, PositionCacheValue = nil, LastPositionUpdate = 0, PositionUpdateInterval = 1 / 45,
    FOVCircle = nil, FOVGlowCircle = nil, FOVUpdateConnection = nil, FOVPosition = Vector2.new(500, 500), Sticky = true }, Blur = { Enabled = false,
    BlurEffect = nil, Connection = nil, LastLookVector = nil, CurrentLookVector = nil, RotationSpeed = 0 }, ThirdPerson = { Enabled = false, Distance = 8, Shoulder = 1.35, Height = 0.35, Connection = nil, SavedCameraMode = nil,
    SavedMinZoom = nil, SavedMaxZoom = nil, OriginalOffsets = setmetatable({}, { __mode = "k" }) }, Freecam = { Enabled = false, Speed = 50, Sensitivity = 0.18, Acceleration = 14,
    BoostMultiplier = 2.5, Connection = nil, InputConnections = {}, KeysDown = {}, Rotating = false, OnMobile = not UserInputService.KeyboardEnabled, MouseDelta = Vector2.new(0, 0),
    Position = nil, Yaw = 0, Pitch = 0, Velocity = Vector3.new(0, 0, 0), SavedCameraType = nil, SavedCameraSubject = nil, SavedFieldOfView = nil, SavedMouseBehavior = nil,
    SavedMouseIconEnabled = nil, SavedRootAnchored = nil, SavedRootPart = nil }, NoRecoil = { Enabled = false, Connections = {}, WeaponCache = setmetatable({}, { __mode = "v" }),
    OriginalValues = setmetatable({}, { __mode = "k" }), RCLConnections = {}, RCLLookup = setmetatable({}, { __mode = "k" }), CacheReady = false, LastScan = 0, ScanCooldown = 2,
    Scanning = false, Settings = { GunMods = { NoRecoil = true, Spread = true, SpreadAmount = 0, NoCrosshair = true, InstantReload = false, InstantEquip = false } } }, CharacterAddedConnection = nil }

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

    local CurrentTime = os.clock()
    local ScanInterval = math.max(
        tonumber(S.AimBot.TargetScanInterval) or 0.05,
        0.04
    )

    if CurrentTime - (S.AimBot.LastTargetScan or 0) < ScanInterval then
        return S.AimBot.CachedScanTarget
    end

    S.AimBot.LastTargetScan = CurrentTime

    local CameraObject = GetCamera()
    if not CameraObject then return nil end

    local ClosestPlayer = nil
    local ShortestDistance = S.AimBot.FOV
    local CenterPosition = CameraObject.ViewportSize * 0.5
    local CameraPosition = CameraObject.CFrame.Position

    local WallParameters = nil
    if S.AimBot.WallCheck then
        WallParameters = RaycastParams.new()
        WallParameters.FilterType = Enum.RaycastFilterType.Exclude
        WallParameters.FilterDescendantsInstances = {
            LocalPlayer.Character,
            CameraObject
        }
        WallParameters.IgnoreWater = true
    end

    -- Cheap scan only: resolver runs after one target has been selected.
    for _, PlayerObject in ipairs(Players:GetPlayers()) do
        if PlayerObject ~= LocalPlayer then
            local CharacterObject = PlayerObject.Character
            local HumanoidObject = CharacterObject
                and CharacterObject:FindFirstChildOfClass("Humanoid")
            local HumanoidRootPart = ResolverGetRoot(CharacterObject)

            if CharacterObject
                and HumanoidRootPart
                and HumanoidObject
                and HumanoidObject.Health > 0
            then
                if S.AimBot.DownedCheck
                    and HumanoidObject:GetState() == Enum.HumanoidStateType.Dead
                then
                    continue
                end

                local TargetPart = CharacterObject:FindFirstChild(S.AimBot.TargetPart)
                    or CharacterObject:FindFirstChild("Head")
                    or HumanoidRootPart

                if TargetPart and TargetPart:IsA("BasePart") then
                    local TargetPosition = TargetPart.Position

                    if WallParameters then
                        local Result = workspace:Raycast(
                            CameraPosition,
                            TargetPosition - CameraPosition,
                            WallParameters
                        )

                        if Result
                            and not Result.Instance:IsDescendantOf(CharacterObject)
                        then
                            continue
                        end
                    end

                    local ScreenPosition, IsOnScreen =
                        CameraObject:WorldToViewportPoint(TargetPosition)

                    if IsOnScreen and ScreenPosition.Z > 0 then
                        local Distance = (
                            CenterPosition
                            - Vector2.new(ScreenPosition.X, ScreenPosition.Y)
                        ).Magnitude

                        if Distance < ShortestDistance then
                            ShortestDistance = Distance
                            ClosestPlayer = PlayerObject
                        end
                    end
                end
            end
        end
    end

    S.AimBot.CachedScanTarget = ClosestPlayer
    return ClosestPlayer
end

function GetTargetPosition(CharacterObject, PlayerObject)
    if not CharacterObject then return nil end

    local CurrentTime = os.clock()
    local UpdateInterval = math.max(
        tonumber(S.AimBot.PositionUpdateInterval) or (1 / 45),
        1 / 60
    )

    if S.AimBot.PositionCacheCharacter == CharacterObject
        and S.AimBot.PositionCacheValue
        and CurrentTime - (S.AimBot.LastPositionUpdate or 0) < UpdateInterval
    then
        return S.AimBot.PositionCacheValue
    end

    local TargetPart = CharacterObject:FindFirstChild(S.AimBot.TargetPart)
        or CharacterObject:FindFirstChild("HumanoidRootPart")
        or CharacterObject:FindFirstChild("Head")

    if not TargetPart or not TargetPart:IsA("BasePart") then
        return nil
    end

    local PredictionTime = math.clamp(
        (tonumber(S.AimBot.Prediction) or 0) / 1000,
        0,
        0.30
    )

    -- Resolver runs only for the selected/cached target, never during
    -- the full player scan.
    local PositionValue = ResolveCombatPosition(
        PlayerObject,
        CharacterObject,
        TargetPart,
        PredictionTime,
        S.AimBot
    ) or TargetPart.Position

    S.AimBot.PositionCacheCharacter = CharacterObject
    S.AimBot.PositionCacheValue = PositionValue
    S.AimBot.LastPositionUpdate = CurrentTime

    return PositionValue
end

function GetAimSmoothAlpha()
    return math.clamp(
        tonumber(S.AimBot.Smoothness) or 0.1,
        0.01,
        1
    )
end

function SmoothAim(TargetPosition)
    if not TargetPosition then return end

    local CameraObject = GetCamera()
    if not CameraObject then return end

    local CurrentCFrame = CameraObject.CFrame
    local TargetCFrame = CFrame.lookAt(
        CurrentCFrame.Position,
        TargetPosition
    )

    CameraObject.CFrame = CurrentCFrame:Lerp(
        TargetCFrame,
        GetAimSmoothAlpha()
    )
end

function SmoothAimDirection(CurrentDirection, TargetDirection)
    if typeof(TargetDirection) ~= "Vector3"
        or TargetDirection.Magnitude <= 0.001
    then
        return nil
    end

    TargetDirection = TargetDirection.Unit

    if typeof(CurrentDirection) ~= "Vector3"
        or CurrentDirection.Magnitude <= 0.001
    then
        return TargetDirection
    end

    local Blended = CurrentDirection.Unit:Lerp(
        TargetDirection,
        GetAimSmoothAlpha()
    )

    if Blended.Magnitude <= 0.001 then
        return TargetDirection
    end

    return Blended.Unit
end

function AimLoop()
    if not S.AimBot.Enabled then return end

    local CurrentTarget = nil

    if S.AimBot.Sticky then
        CurrentTarget = S.AimBot.Target

        if CurrentTarget then
            local CharacterObject = CurrentTarget.Character
            local HumanoidObject = CharacterObject
                and CharacterObject:FindFirstChildOfClass("Humanoid")

            if not CharacterObject
                or not HumanoidObject
                or HumanoidObject.Health <= 0
            then
                CurrentTarget = nil
                S.AimBot.Target = nil
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

    if S.AimBot.Type ~= "Aimbot" then
        return
    end

    if CurrentTarget and CurrentTarget.Character then
        local TargetPosition = GetTargetPosition(
            CurrentTarget.Character,
            CurrentTarget
        )

        if TargetPosition then
            SmoothAim(TargetPosition)
        end
    end
end

SilentAimController = SilentAimController or {
    Connection = nil
}

function DisableSilentAimController()
    if SilentAimController.Connection then
        SilentAimController.Connection:Disconnect()
        SilentAimController.Connection = nil
    end
end

function EnableSilentAimController()
    if SilentAimController.Connection then
        return true
    end

    local Events = ReplicatedStorage:FindFirstChild("Events")
    local Events2 = ReplicatedStorage:FindFirstChild("Events2")
    local Visualize = Events2 and Events2:FindFirstChild("Visualize")
    local HitRemote = Events and Events:FindFirstChild("ZFKLF__H")

    if not Visualize
        or not Visualize:IsA("BindableEvent")
        or not HitRemote
    then
        return false
    end

    SilentAimController.Connection = Visualize.Event:Connect(function(
        Hitbox,
        Weapon,
        OriginalDirection,
        HitObject,
        OriginalHitPosition,
        OriginPosition,
        HitPoints
    )
        if not S.AimBot.Enabled
            or S.AimBot.Type ~= "Silent Aim"
        then
            return
        end

        local TargetPlayer = S.AimBot.CurrentTarget
        local TargetCharacter = TargetPlayer and TargetPlayer.Character
        local TargetPart = TargetCharacter and (
            TargetCharacter:FindFirstChild(S.AimBot.TargetPart)
            or TargetCharacter:FindFirstChild("Head")
            or TargetCharacter:FindFirstChild("HumanoidRootPart")
        )

        local Humanoid = TargetCharacter
            and TargetCharacter:FindFirstChildOfClass("Humanoid")

        if not TargetPart
            or not TargetPart:IsA("BasePart")
            or not Humanoid
            or Humanoid.Health <= 0
            or typeof(OriginPosition) ~= "Vector3"
            or not HitObject
        then
            return
        end

        local TargetPosition = TargetPart.Position
        local TargetDelta = TargetPosition - OriginPosition

        if TargetDelta.Magnitude <= 0.001 then
            return
        end

        local Direction = SmoothAimDirection(
            OriginalDirection,
            TargetDelta.Unit
        )

        if not Direction then
            return
        end

        local BulletCount = 1
        if type(HitPoints) == "table" then
            BulletCount = math.clamp(#HitPoints, 1, 100)
        end

        task.delay(0.005, function()
            if not S.AimBot.Enabled
                or S.AimBot.Type ~= "Silent Aim"
                or not TargetPart.Parent
            then
                return
            end

            for _ = 1, BulletCount do
                HitRemote:FireServer(
                    "\240\159\167\136",
                    HitObject,
                    Weapon,
                    Direction,
                    TargetPart,
                    TargetPosition,
                    Direction
                )
            end

            local Hitmarker = typeof(HitObject) == "Instance"
                and HitObject:FindFirstChild("Hitmarker")

            if Hitmarker and Hitmarker:IsA("BindableEvent") then
                Hitmarker:Fire(TargetPart)
            end
        end)
    end)

    return true
end

function UpdateSilentAimController()
    if S.AimBot.Enabled
        and S.AimBot.Type == "Silent Aim"
    then
        EnableSilentAimController()
    else
        DisableSilentAimController()
    end
end

function ToggleAimBot(StateValue)
    S.AimBot.Enabled = StateValue == true
    S.AimBot.Resolver = true
    S.AimBot.ResolverMode = "Adaptive"
    S.AimBot.ResolverStrength = 0.85
    S.AimBot.Target = nil
    S.AimBot.CurrentTarget = nil
    S.AimBot.CachedScanTarget = nil
    S.AimBot.LastTargetScan = 0
    S.AimBot.PositionCacheCharacter = nil
    S.AimBot.PositionCacheValue = nil
    S.AimBot.LastPositionUpdate = 0

    if S.AimBot.Enabled then
        CreateFOVCircle()

        if S.AimBot.FOVUpdateConnection then
            S.AimBot.FOVUpdateConnection:Disconnect()
        end

        S.AimBot.FOVUpdateConnection =
            RunService.RenderStepped:Connect(UpdateFOVCircle)

        if S.AimBot.Connection then
            S.AimBot.Connection:Disconnect()
        end

        S.AimBot.Connection =
            RunService.RenderStepped:Connect(AimLoop)

        UpdateSilentAimController()
        return
    end

    RemoveAimFOVCircle()
    DisableSilentAimController()

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

function RestoreThirdPersonOffsets()
    for Humanoid, Offset in pairs(S.ThirdPerson.OriginalOffsets) do
        if Humanoid and Humanoid.Parent then
            pcall(function() Humanoid.CameraOffset = Offset end)
        end
    end
    S.ThirdPerson.OriginalOffsets = setmetatable({}, { __mode = "k" })
end

function UpdateThirdPerson()
    if not S.ThirdPerson.Enabled or S.Freecam.Enabled then
        return
    end

    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        if S.ThirdPerson.OriginalOffsets[Humanoid] == nil then
            S.ThirdPerson.OriginalOffsets[Humanoid] = Humanoid.CameraOffset
        end
        Humanoid.CameraOffset = Vector3.new(
            S.ThirdPerson.Shoulder,
            S.ThirdPerson.Height,
            0
        )
    end

    LocalPlayer.CameraMode = Enum.CameraMode.Classic
    LocalPlayer.CameraMinZoomDistance = S.ThirdPerson.Distance
    LocalPlayer.CameraMaxZoomDistance = S.ThirdPerson.Distance
end

function EnableThirdPerson()
    if S.ThirdPerson.Connection then
        S.ThirdPerson.Connection:Disconnect()
        S.ThirdPerson.Connection = nil
    end

    S.ThirdPerson.SavedCameraMode = LocalPlayer.CameraMode
    S.ThirdPerson.SavedMinZoom = LocalPlayer.CameraMinZoomDistance
    S.ThirdPerson.SavedMaxZoom = LocalPlayer.CameraMaxZoomDistance
    S.ThirdPerson.Connection = RunService.RenderStepped:Connect(UpdateThirdPerson)
    UpdateThirdPerson()
end

function DisableThirdPerson()
    if S.ThirdPerson.Connection then
        S.ThirdPerson.Connection:Disconnect()
        S.ThirdPerson.Connection = nil
    end

    RestoreThirdPersonOffsets()
    if S.ThirdPerson.SavedCameraMode ~= nil then
        pcall(function() LocalPlayer.CameraMode = S.ThirdPerson.SavedCameraMode end)
    end
    if S.ThirdPerson.SavedMinZoom ~= nil then
        pcall(function() LocalPlayer.CameraMinZoomDistance = S.ThirdPerson.SavedMinZoom end)
    end
    if S.ThirdPerson.SavedMaxZoom ~= nil then
        pcall(function() LocalPlayer.CameraMaxZoomDistance = S.ThirdPerson.SavedMaxZoom end)
    end

    S.ThirdPerson.SavedCameraMode = nil
    S.ThirdPerson.SavedMinZoom = nil
    S.ThirdPerson.SavedMaxZoom = nil
end

function ToggleThirdPerson(State)
    State = State == true
    if State == S.ThirdPerson.Enabled then
        return
    end
    S.ThirdPerson.Enabled = State
    if State then
        EnableThirdPerson()
    else
        DisableThirdPerson()
    end
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
WeaponReloadTimeFields = { "ReloadTime" }
WeaponReloadSpeedFields = { "ReloadAnimSpeed" }
WeaponEquipTimeFields = { "EquipTime" }
WeaponEquipSpeedFields = { "EquipAnimSpeed" }
WeaponShotgunReloadTimeFields = { "ReloadStartTime", "ShellInTime", "ReloadFinishTime", "FinishPumpWait", "LoopEndDelay" }
WeaponShotgunReloadSpeedFields = { "ReloadStartAnimSpeed", "ShellInAnimSpeed" }

function IsWeaponConfigNR(Object)
    if type(Object) ~= "table" then return false end
    local IdentityScore = 0
    for _, Field in ipairs(WeaponIdentityFields) do
        if type(rawget(Object, Field)) == "number" then IdentityScore = IdentityScore + 1 end
    end
    local HasAccuracy = type(rawget(Object, "Spread")) == "number" or type(rawget(Object, "Recoil")) == "number"
    local HasWeaponRate = type(rawget(Object, "FireRate")) == "number" or type(rawget(Object, "MagSize")) == "number"
    local HasTiming = type(rawget(Object, "ReloadTime")) == "number" or type(rawget(Object, "EquipTime")) == "number"
    return IdentityScore >= 4 and HasWeaponRate and (HasAccuracy or HasTiming)
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
    if S.NoRecoil.Settings.GunMods.InstantEquip then
        for _, Field in ipairs(WeaponEquipTimeFields) do SetWeaponFieldNR(WeaponObject, Field, 0.01) end
        for _, Field in ipairs(WeaponEquipSpeedFields) do SetWeaponFieldNR(WeaponObject, Field, 100) end
    end

    for Key, Value in pairs(WeaponObject) do ApplyNestedWeaponGroupNR(Key, Value) end
end

WeaponInstantReloadState = WeaponInstantReloadState or {
    Busy = false,
    LastRequest = 0,
    InputConnection = nil,
    CharacterAddedConnection = nil,
    CharacterChildConnection = nil,
    ToolConnections = {},
    BoundTool = nil
}

function GetWeaponInstantReloadTool()
    local Character = LocalPlayer and LocalPlayer.Character
    local Tool = Character and Character:FindFirstChildOfClass("Tool")
    if not Tool or not IsRageFirearm(Tool) then return nil end
    return Tool
end

function DisconnectWeaponInstantReloadTool()
    for _, Connection in ipairs(
        WeaponInstantReloadState.ToolConnections
    ) do
        if typeof(Connection) == "RBXScriptConnection" then
            pcall(function()
                Connection:Disconnect()
            end)
        end
    end

    WeaponInstantReloadState.ToolConnections = {}
    WeaponInstantReloadState.BoundTool = nil
    WeaponInstantReloadState.Busy = false
end

function PerformWeaponInstantReload(Tool)
    if not S.NoRecoil.Settings.GunMods.InstantReload
        or WeaponInstantReloadState.Busy
        or not Tool
        or not Tool.Parent
        or not IsRageFirearm(Tool)
    then
        return false
    end

    local Values = Tool:FindFirstChild("Values")
    local Ammo = Values and (
        Values:FindFirstChild("SERVER_Ammo")
        or Values:FindFirstChild("Ammo")
    )
    local Stored = Values and (
        Values:FindFirstChild("SERVER_StoredAmmo")
        or Values:FindFirstChild("StoredAmmo")
    )

    local AmmoValue = Ammo and tonumber(Ammo.Value)
    local StoredValue = Stored and tonumber(Stored.Value)
    local MagSize = GetRageMagazineSize(Tool)

    if StoredValue ~= nil and StoredValue <= 0 then
        return false
    end

    if AmmoValue ~= nil
        and MagSize
        and AmmoValue >= MagSize
    then
        return false
    end

    local Now = os.clock()
    if Now - WeaponInstantReloadState.LastRequest < 0.035 then
        return false
    end

    local Events = ReplicatedStorage:FindFirstChild("Events")
    local ReloadEvent = Events and Events:FindFirstChild("GNX_R")
    if not ReloadEvent then return false end

    WeaponInstantReloadState.LastRequest = Now
    WeaponInstantReloadState.Busy = true

    local Requested = pcall(function()
        ReloadEvent:FireServer(
            tick(),
            "KLWE89U0",
            Tool
        )
    end)

    WeaponInstantReloadState.Busy = false

    if Requested then
        task.delay(0.04, function()
            if not S.NoRecoil.Settings.GunMods.InstantReload
                or not Tool
                or not Tool.Parent
            then
                return
            end

            local CurrentValues = Tool:FindFirstChild("Values")
            local CurrentAmmo = CurrentValues and (
                CurrentValues:FindFirstChild("SERVER_Ammo")
                or CurrentValues:FindFirstChild("Ammo")
            )

            if CurrentAmmo
                and AmmoValue ~= nil
                and tonumber(CurrentAmmo.Value) <= AmmoValue
            then
                pcall(function()
                    ReloadEvent:FireServer(
                        tick(),
                        "KLWE89U0",
                        Tool
                    )
                end)
            end
        end)
    end

    return Requested
end

function BindWeaponInstantReloadTool(Tool)
    if WeaponInstantReloadState.BoundTool == Tool then
        return
    end

    DisconnectWeaponInstantReloadTool()

    if not S.NoRecoil.Settings.GunMods.InstantReload
        or not Tool
        or not Tool.Parent
        or not IsRageFirearm(Tool)
    then
        return
    end

    local Values = Tool:FindFirstChild("Values")
    local Ammo = Values and (
        Values:FindFirstChild("SERVER_Ammo")
        or Values:FindFirstChild("Ammo")
    )
    local Stored = Values and (
        Values:FindFirstChild("SERVER_StoredAmmo")
        or Values:FindFirstChild("StoredAmmo")
    )

    if not Ammo then return end

    WeaponInstantReloadState.BoundTool = Tool

    WeaponInstantReloadState.ToolConnections[#WeaponInstantReloadState.ToolConnections + 1] =
        Ammo:GetPropertyChangedSignal("Value"):Connect(function()
            if S.NoRecoil.Settings.GunMods.InstantReload then
                PerformWeaponInstantReload(Tool)
            end
        end)

    if Stored then
        WeaponInstantReloadState.ToolConnections[#WeaponInstantReloadState.ToolConnections + 1] =
            Stored:GetPropertyChangedSignal("Value"):Connect(function()
                if S.NoRecoil.Settings.GunMods.InstantReload then
                    PerformWeaponInstantReload(Tool)
                end
            end)
    end

    task.defer(function()
        PerformWeaponInstantReload(Tool)
    end)
end

function RefreshWeaponInstantReloadBinding()
    if not S.NoRecoil.Settings.GunMods.InstantReload then
        DisconnectWeaponInstantReloadTool()
        return
    end

    BindWeaponInstantReloadTool(
        GetWeaponInstantReloadTool()
    )
end

function DisconnectWeaponInstantReloadRuntime()
    DisconnectWeaponInstantReloadTool()

    local Fields = {
        "InputConnection",
        "CharacterAddedConnection",
        "CharacterChildConnection"
    }

    for _, Field in ipairs(Fields) do
        local Connection = WeaponInstantReloadState[Field]
        if typeof(Connection) == "RBXScriptConnection" then
            pcall(function()
                Connection:Disconnect()
            end)
        end
        WeaponInstantReloadState[Field] = nil
    end
end

function InstallWeaponInstantReloadInput()
    if WeaponInstantReloadState.InputConnection then return end

    WeaponInstantReloadState.InputConnection =
        UserInputService.InputBegan:Connect(function(Input, Processed)
            if Processed or Input.KeyCode ~= Enum.KeyCode.R then
                return
            end

            PerformWeaponInstantReload(
                GetWeaponInstantReloadTool()
            )
        end)

    local function BindCharacter(Character)
        local OldConnection =
            WeaponInstantReloadState.CharacterChildConnection

        if typeof(OldConnection) == "RBXScriptConnection" then
            OldConnection:Disconnect()
        end

        WeaponInstantReloadState.CharacterChildConnection =
            Character.ChildAdded:Connect(function(Child)
                if Child:IsA("Tool") then
                    task.defer(function()
                        BindWeaponInstantReloadTool(Child)
                    end)
                end
            end)

        task.defer(function()
            RefreshWeaponInstantReloadBinding()
        end)
    end

    if LocalPlayer.Character then
        BindCharacter(LocalPlayer.Character)
    end

    WeaponInstantReloadState.CharacterAddedConnection =
        LocalPlayer.CharacterAdded:Connect(function(Character)
            BindCharacter(Character)
        end)
end

InstallWeaponInstantReloadInput()


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

function RefreshGunModsNR()
    ResetGunModsNR()
    RestoreCameraRecoilNR()

    if not S.NoRecoil.Enabled then return end

    ApplyGunModsNR()
    DisableCameraRecoilNR(false)
end

function HandleWeaponNR(WeaponObject)
    if not S.NoRecoil.Enabled or not WeaponObject or not WeaponObject:IsA("Tool") then return end

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
    local Character = LocalPlayer.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    if not Character or not Humanoid or Humanoid.Health > 0 then return false end
    local CurrentTime = os.clock()
    if RespawnSafetyState.RespawnRequestedFor == Character and CurrentTime - (RespawnSafetyState.LastRespawnRequest or 0) < 3.5 then return false end
    RespawnSafetyState.RespawnRequestedFor = Character
    RespawnSafetyState.LastRespawnRequest = CurrentTime
    local RemoteRequested = TriggerRespawnRemote()
    if RemoteRequested then return true end
    return TriggerRespawnButton()
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
                RequestCharacterRespawn()
                local StartedAt = os.clock()
                repeat
                    task.wait(0.25)
                    Character = LocalPlayer.Character
                    Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
                until not AutoRespawnEnabled or (Humanoid and Humanoid.Health > 0) or os.clock() - StartedAt >= 5
                if AutoRespawnEnabled and (not Humanoid or Humanoid.Health <= 0) then RequestCharacterRespawn() end
                task.wait(1.5)
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

function GetWatermarkText()
    return "radiant.rip"
end

function CreateRadiantWatermark()
    local Parent =
        type(gethui) == "function"
        and gethui()
        or PlayerGui

    local Existing =
        Parent:FindFirstChild(
            "RadiantWatermark"
        )

    if Existing then
        Existing:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RadiantWatermark"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior =
        Enum.ZIndexBehavior.Global
    ScreenGui.DisplayOrder = 2147483647
    ScreenGui.Parent = Parent

    local Frame = Instance.new("Frame")
    Frame.Name = "Watermark"
    Frame.Position = UDim2.new(0, 12, 0, 12)
    Frame.Size = UDim2.new(0, 230, 0, 42)
    Frame.BackgroundColor3 =
        Color3.fromRGB(8, 9, 13)
    Frame.BackgroundTransparency = 0.20
    Frame.BorderSizePixel = 0
    Frame.Active = true
    Frame.ClipsDescendants = false
    Frame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Padding = Instance.new("UIPadding")
    Padding.PaddingLeft = UDim.new(0, 8)
    Padding.PaddingRight = UDim.new(0, 8)
    Padding.PaddingTop = UDim.new(0, 5)
    Padding.PaddingBottom = UDim.new(0, 5)
    Padding.Parent = Frame

    local Rows = {}
    local RowLayouts = {}
    local Labels = {}

    local TextColor =
        Library.Theme.Text
        or Color3.fromRGB(225, 230, 228)

    local MutedColor =
        Library.Theme["Muted Text"]
        or Color3.fromRGB(137, 143, 160)

    local IconColor =
        Library.Theme.Accent:
        Lerp(MutedColor, 0.48)

    local function CreateRow(Index)
        local Row = Instance.new("Frame")
        Row.Name = "Row" .. tostring(Index)
        Row.Position = UDim2.new(
            0,
            0,
            0,
            (Index - 1) * 17
        )
        Row.Size = UDim2.new(0, 0, 0, 14)
        Row.AutomaticSize = Enum.AutomaticSize.X
        Row.BackgroundTransparency = 1
        Row.BorderSizePixel = 0
        Row.Parent = Frame

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection =
            Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment =
            Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment =
            Enum.VerticalAlignment.Center
        Layout.SortOrder =
            Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(0, 8)
        Layout.Parent = Row

        Rows[Index] = Row
        RowLayouts[Index] = Layout

        return Row
    end

    local function CreateSegment(
        Row,
        Key,
        Icon,
        InitialText,
        Color
    )
        local Segment = Instance.new("Frame")
        Segment.Name = Key
        Segment.Size = UDim2.new(0, 0, 0, 14)
        Segment.AutomaticSize =
            Enum.AutomaticSize.X
        Segment.BackgroundTransparency = 1
        Segment.BorderSizePixel = 0
        Segment.Parent = Row

        local Layout = Instance.new("UIListLayout")
        Layout.FillDirection =
            Enum.FillDirection.Horizontal
        Layout.HorizontalAlignment =
            Enum.HorizontalAlignment.Left
        Layout.VerticalAlignment =
            Enum.VerticalAlignment.Center
        Layout.SortOrder =
            Enum.SortOrder.LayoutOrder
        Layout.Padding = UDim.new(
            0,
            Icon and 3 or 0
        )
        Layout.Parent = Segment

        if Icon then
            local IconLabel =
                Instance.new("TextLabel")

            IconLabel.Name = "Icon"
            IconLabel.Size =
                UDim2.new(0, 11, 0, 14)
            IconLabel.BackgroundTransparency = 1
            IconLabel.BorderSizePixel = 0
            IconLabel.Font =
                Enum.Font.GothamMedium
            IconLabel.Text = Icon
            IconLabel.TextSize = 10
            IconLabel.TextColor3 = IconColor
            IconLabel.TextXAlignment =
                Enum.TextXAlignment.Center
            IconLabel.Parent = Segment
        end

        local Value = Instance.new("TextLabel")
        Value.Name = "Value"
        Value.Size = UDim2.new(0, 0, 0, 14)
        Value.AutomaticSize =
            Enum.AutomaticSize.X
        Value.BackgroundTransparency = 1
        Value.BorderSizePixel = 0
        Value.FontFace = UiFont
        Value.Text = InitialText or ""
        Value.TextSize = 10
        Value.TextColor3 =
            Color or MutedColor
        Value.TextXAlignment =
            Enum.TextXAlignment.Left
        Value.Parent = Segment

        Labels[Key] = Value

        return Value
    end

    local Row1 = CreateRow(1)
    local Row2 = CreateRow(2)

    CreateSegment(
        Row1,
        "Title",
        nil,
        "radiant.rip",
        IconColor
    )

    CreateSegment(
        Row1,
        "User",
        "●",
        LocalPlayer.Name,
        TextColor
    )

    CreateSegment(
        Row1,
        "FPS",
        "▣",
        "0fps",
        MutedColor
    )

    CreateSegment(
        Row1,
        "Ping",
        "☁",
        "0ms",
        MutedColor
    )

    CreateSegment(
        Row2,
        "Position",
        "➤",
        "x0 y0 z0",
        MutedColor
    )

    CreateSegment(
        Row2,
        "TPS",
        "◔",
        "0.0tps",
        MutedColor
    )

    CreateSegment(
        Row2,
        "Network",
        "⇅",
        "0.00kbps",
        MutedColor
    )

    local Watermark = {
        ScreenGui = ScreenGui,
        Frame = Frame,
        Label = Labels.Title,
        Labels = Labels,
        Connections = {},
        Dragging = false,
        DragStart = nil,
        StartPosition = nil,
        FrameCount = 0,
        HeartbeatCount = 0,
        SampleElapsed = 0,
        UpdateElapsed = 0,
        FPS = 0,
        TPS = 0
    }

    local function AddConnection(Connection)
        Watermark.Connections[
            #Watermark.Connections + 1
        ] = Connection

        return Connection
    end

    local function UpdateWidth()
        if not Frame.Parent then
            return
        end

        local FirstWidth =
            RowLayouts[1].AbsoluteContentSize.X

        local SecondWidth =
            RowLayouts[2].AbsoluteContentSize.X

        Frame.Size = UDim2.new(
            0,
            math.max(
                math.ceil(
                    math.max(
                        FirstWidth,
                        SecondWidth
                    )
                ) + 16,
                120
            ),
            0,
            42
        )
    end

    local function ReadServerStat(Names)
        local Number = 0

        pcall(function()
            local StatsService =
                game:GetService("Stats")

            local Network =
                StatsService:FindFirstChild(
                    "Network"
                )

            local ServerStats =
                Network
                and Network:FindFirstChild(
                    "ServerStatsItem"
                )

            if not ServerStats then
                ServerStats =
                    StatsService.Network.
                    ServerStatsItem
            end

            for _, Name in ipairs(Names) do
                local Item

                pcall(function()
                    Item =
                        ServerStats:
                        FindFirstChild(Name)
                        or ServerStats[Name]
                end)

                if Item then
                    local Success, Value =
                        pcall(function()
                            return Item:GetValue()
                        end)

                    Value =
                        Success
                        and tonumber(Value)
                        or nil

                    if Value then
                        Number = math.max(
                            Number,
                            Value
                        )
                        break
                    end
                end
            end
        end)

        return math.max(Number, 0)
    end

    local function GetPingMilliseconds()
        local Ping = 0

        pcall(function()
            Ping =
                math.max(
                    Ping,
                    (
                        tonumber(
                            LocalPlayer:
                                GetNetworkPing()
                        )
                        or 0
                    ) * 1000
                )
        end)

        if Ping <= 0 then
            Ping = ReadServerStat({
                "Data Ping"
            })
        end

        return math.clamp(
            math.floor(Ping + 0.5),
            0,
            9999
        )
    end

    local function GetNetworkKbps()
        local Receive = ReadServerStat({
            "Data Receive Kbps",
            "Data Receive KBPS",
            "Data Receive"
        })

        local Send = ReadServerStat({
            "Data Send Kbps",
            "Data Send KBPS",
            "Data Send"
        })

        return math.max(
            Receive + Send,
            0
        )
    end

    local function GetPositionText()
        local Character =
            LocalPlayer.Character

        local Root =
            Character
            and Character:FindFirstChild(
                "HumanoidRootPart"
            )

        if not Root then
            return "x0 y0 z0"
        end

        local Position = Root.Position

        return string.format(
            "x%d y%d z%d",
            math.floor(Position.X + 0.5),
            math.floor(Position.Y + 0.5),
            math.floor(Position.Z + 0.5)
        )
    end

    local function UpdateMetrics()
        if not Frame.Parent then
            return
        end

        Labels.User.Text =
            tostring(LocalPlayer.Name)

        Labels.FPS.Text =
            string.format(
                "%dfps",
                math.max(
                    math.floor(
                        Watermark.FPS + 0.5
                    ),
                    0
                )
            )

        Labels.Ping.Text =
            string.format(
                "%dms",
                GetPingMilliseconds()
            )

        Labels.Position.Text =
            GetPositionText()

        Labels.TPS.Text =
            string.format(
                "%.1ftps",
                math.max(
                    Watermark.TPS,
                    0
                )
            )

        Labels.Network.Text =
            string.format(
                "%.2fkbps",
                GetNetworkKbps()
            )

        UpdateWidth()
    end

    local function IsPointerInput(Input)
        return Input.UserInputType
                == Enum.UserInputType.MouseButton1
            or Input.UserInputType
                == Enum.UserInputType.Touch
    end

    AddConnection(
        RowLayouts[1]:
            GetPropertyChangedSignal(
                "AbsoluteContentSize"
            ):
            Connect(UpdateWidth)
    )

    AddConnection(
        RowLayouts[2]:
            GetPropertyChangedSignal(
                "AbsoluteContentSize"
            ):
            Connect(UpdateWidth)
    )

    AddConnection(
        Frame.InputBegan:
            Connect(function(Input)
                if not IsPointerInput(Input) then
                    return
                end

                Watermark.Dragging = true
                Watermark.DragStart =
                    Input.Position
                Watermark.StartPosition =
                    Frame.Position
            end)
    )

    AddConnection(
        UserInputService.InputChanged:
            Connect(function(Input)
                if not Watermark.Dragging
                    or (
                        Input.UserInputType
                            ~= Enum.UserInputType.
                                MouseMovement
                        and Input.UserInputType
                            ~= Enum.UserInputType.
                                Touch
                    )
                then
                    return
                end

                local Delta =
                    Input.Position
                    - Watermark.DragStart

                Frame.Position = UDim2.new(
                    Watermark.StartPosition.X.Scale,
                    Watermark.StartPosition.X.Offset
                        + Delta.X,
                    Watermark.StartPosition.Y.Scale,
                    Watermark.StartPosition.Y.Offset
                        + Delta.Y
                )
            end)
    )

    AddConnection(
        UserInputService.InputEnded:
            Connect(function(Input)
                if IsPointerInput(Input) then
                    Watermark.Dragging = false
                end
            end)
    )

    AddConnection(
        RunService.RenderStepped:
            Connect(function()
                Watermark.FrameCount =
                    Watermark.FrameCount + 1
            end)
    )

    AddConnection(
        RunService.Heartbeat:
            Connect(function(DeltaTime)
                Watermark.HeartbeatCount =
                    Watermark.HeartbeatCount + 1

                Watermark.SampleElapsed =
                    Watermark.SampleElapsed
                    + DeltaTime

                Watermark.UpdateElapsed =
                    Watermark.UpdateElapsed
                    + DeltaTime

                if Watermark.SampleElapsed
                    >= 0.5
                then
                    Watermark.FPS =
                        Watermark.FrameCount
                        / Watermark.SampleElapsed

                    Watermark.TPS =
                        Watermark.HeartbeatCount
                        / Watermark.SampleElapsed

                    Watermark.FrameCount = 0
                    Watermark.HeartbeatCount = 0
                    Watermark.SampleElapsed = 0
                end

                if Watermark.UpdateElapsed
                    >= 0.25
                then
                    Watermark.UpdateElapsed =
                        Watermark.UpdateElapsed
                        % 0.25

                    UpdateMetrics()
                end
            end)
    )

    function Watermark:SetText(Value)
        if Labels.Title
            and Labels.Title.Parent
        then
            Labels.Title.Text =
                tostring(Value or "radiant.rip")
            UpdateWidth()
        end
    end

    function Watermark:SetVisibility(State)
        if ScreenGui and ScreenGui.Parent then
            ScreenGui.Enabled =
                State == true
        end
    end

    function Watermark:Destroy()
        for Index =
            #Watermark.Connections,
            1,
            -1
        do
            local Connection =
                Watermark.Connections[Index]

            if Connection then
                Connection:Disconnect()
            end

            Watermark.Connections[Index] = nil
        end

        if ScreenGui then
            ScreenGui:Destroy()
            ScreenGui = nil
        end
    end

    task.defer(function()
        UpdateMetrics()
        UpdateWidth()
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

function GetRadiantToolTexture(Tool)
    if not Tool or not Tool:IsA("Tool") then
        return ""
    end

    local Texture = ""

    pcall(function()
        Texture = Tool.TextureId or ""
    end)

    if type(Texture) == "string" and Texture ~= "" then
        return Texture
    end

    local Handle = Tool:FindFirstChild("Handle") or Tool:FindFirstChild("WeaponHandle")

    if Handle then
        local TextureObject =
            Handle:FindFirstChildOfClass("Decal")
            or Handle:FindFirstChildOfClass("Texture")

        if TextureObject and type(TextureObject.Texture) == "string" then
            return TextureObject.Texture
        end
    end

    return ""
end

function GetRadiantHUDInventory(PlayerObject, Limit)
    Limit = math.clamp(tonumber(Limit) or 5, 1, 5)

    local Result = {}
    local Seen = {}
    local Character = PlayerObject and PlayerObject.Character

    local function AddTool(Tool, Equipped)
        if #Result >= Limit
            or not Tool
            or not Tool:IsA("Tool")
            or Seen[Tool]
        then
            return
        end

        Seen[Tool] = true

        local Name = tostring(Tool.Name or "Item")

        Result[#Result + 1] = {
            Name = Name,
            Image = GetRadiantToolTexture(Tool),
            Text = string.sub(string.upper(Name), 1, 2),
            Equipped = Equipped == true
        }
    end

    if Character then
        for _, Child in ipairs(Character:GetChildren()) do
            AddTool(Child, true)
        end
    end

    local Backpack =
        PlayerObject
        and (
            PlayerObject:FindFirstChildOfClass("Backpack")
            or PlayerObject:FindFirstChild("Backpack")
        )

    if Backpack then
        for _, Child in ipairs(Backpack:GetChildren()) do
            AddTool(Child, false)
        end
    end

    if #Result == 0 then
        Result[1] = {
            Name = "Fists",
            Image = "",
            Text = "FST",
            Equipped = true
        }
    end

    local Signature = {}

    for Index, Entry in ipairs(Result) do
        Signature[Index] = table.concat({
            tostring(Entry.Name),
            tostring(Entry.Image),
            Entry.Equipped and "1" or "0"
        }, ":")
    end

    return Result, table.concat(Signature, "|")
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

    if not HUD then
        return
    end

    HUD:SetFollowTarget(Widgets.TargetHUDFollowTarget)

    local MenuOpen = Widgets.MenuWindow and Widgets.MenuWindow.IsOpen == true

    if not Widgets.TargetHUDEnabled then
        HUD:SetPreviewMode(false)
        HUD:SetVisibility(false)
        Widgets.LastTarget = nil
        Widgets.LastMode = nil
        Widgets.LastInfo = nil
        Widgets.LastInventorySignature = nil
        return
    end

    if MenuOpen then
        local Character = LocalPlayer.Character
        local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
        local Health = Humanoid and Humanoid.Health or 100
        local MaxHealth = Humanoid and Humanoid.MaxHealth or 100
        local Inventory, Signature = GetRadiantHUDInventory(LocalPlayer, 5)

        HUD:SetPreviewMode(true)
        HUD:SetVisibility(true)

        if Widgets.LastTarget ~= LocalPlayer or Widgets.LastMode ~= "PREVIEW" then
            Widgets.LastTarget = LocalPlayer
            Widgets.LastMode = "PREVIEW"
            Widgets.LastHealth = Health
            Widgets.LastMaxHealth = MaxHealth
            Widgets.LastInfo = "Local inventory"
            Widgets.LastInventorySignature = Signature

            HUD:SetTarget(
                LocalPlayer,
                Health,
                MaxHealth,
                "Local inventory",
                "PREVIEW"
            )

            HUD:SetInventory(Inventory)
        else
            if Widgets.LastHealth ~= Health or Widgets.LastMaxHealth ~= MaxHealth then
                Widgets.LastHealth = Health
                Widgets.LastMaxHealth = MaxHealth
                HUD:SetHealth(Health, MaxHealth)
            end

            if Widgets.LastInventorySignature ~= Signature then
                Widgets.LastInventorySignature = Signature
                HUD:SetInventory(Inventory)
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
        Widgets.LastInventorySignature = nil
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
        Widgets.LastInventorySignature = nil
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
            Vector2.new(0, -46)
        )
    end

    local Distance =
        LocalRoot
        and math.floor((Root.Position - LocalRoot.Position).Magnitude + 0.5)
        or 0

    local Info = string.format("%d studs", Distance)
    local Inventory, Signature = GetRadiantHUDInventory(Target, 5)

    HUD:SetVisibility(true)

    if Widgets.LastTarget ~= Target or Widgets.LastMode ~= Mode then
        Widgets.LastTarget = Target
        Widgets.LastMode = Mode
        Widgets.LastHealth = Humanoid.Health
        Widgets.LastMaxHealth = Humanoid.MaxHealth
        Widgets.LastInfo = Info
        Widgets.LastInventorySignature = Signature

        HUD:SetTarget(
            Target,
            Humanoid.Health,
            Humanoid.MaxHealth,
            Info,
            Mode
        )

        HUD:SetInventory(Inventory)
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

    if Widgets.LastInventorySignature ~= Signature then
        Widgets.LastInventorySignature = Signature
        HUD:SetInventory(Inventory)
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
        Position = UDim2.new(1, -320, 0.5, -220),
        Size = UDim2.new(0, 300, 0, 440),
        Character = LocalPlayer.Character,
        Settings = VisualState.Player,
        Name = LocalPlayer.DisplayName or LocalPlayer.Name
    })

    Widgets.TargetHUD = Library:TargetHUD({
        Visible = false,
        FollowTarget = Widgets.TargetHUDFollowTarget,
        Position = UDim2.new(0.5, 0, 1, -96),
        Size = UDim2.new(0, 310, 0, 86),
        FollowSize = UDim2.new(0, 196, 0, 56)
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
    local Window = Library:Window({ Name = "radiant.rip", Size = UDim2.new(0, 540, 0, 600), FadeSpeed = 0.12 })
    VisualState.Widgets.MenuWindow = Window
    local Watermark = CreateRadiantWatermark()
    local KeybindList = Library:KeybindList()
    Library.MenuKeybind = Enum.KeyCode.Delete
    Watermark:SetVisibility(true)
    KeybindList:SetVisibility(false)
    local Combat = Window:Page({ Name = "Combat", Columns = 2, Subtabs = false })
    local Visuals = Window:Page({ Name = "Visuals", Columns = 2, Subtabs = false })
    local PlayersPage = Window:Page({ Name = "ESP", Columns = 2, Subtabs = false })
    local Movement = Window:Page({ Name = "Movement", Columns = 2, Subtabs = false })
    local WorldPage = Window:Page({ Name = "World", Columns = 2, Subtabs = false })
    local Farming = Window:Page({ Name = "Farm", Columns = 2, Subtabs = false })
    local Utility = Window:Page({ Name = "Misc", Columns = 2, Subtabs = false })
    local Settings = Window:Page({ Name = "Settings", Columns = 2, Subtabs = false })

    local AimSection = Combat:Section({ Name = "Aim", Side = 1 })
    AimSection:Toggle({ Name = "Enable", Flag = "Aim Enabled", Default = false, Callback = function(Value)
        ToggleAimBot(Value)
    end }):Keybind({ Name = "Aim Bind", Flag = "Aim Bind", Default = "None", Mode = "Toggle", Callback = function()
    end })
    AimSection:Dropdown({ Name = "Mode", Flag = "Aim Type", Default = S.AimBot.Type, Items = { "Aimbot", "Silent Aim" }, Callback = function(Value)
        S.AimBot.Type = Value == "Silent Aim" and "Silent Aim" or "Aimbot"
        S.AimBot.Target = nil
        S.AimBot.CurrentTarget = nil
        S.AimBot.CachedScanTarget = nil
        UpdateSilentAimController()
    end })
    AimSection:Dropdown({ Name = "Hitbox", Flag = "Aim Target Part", Default = S.AimBot.TargetPart, Items = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, Callback = function(Value)
        S.AimBot.TargetPart = Value
    end })
    AimSection:Toggle({ Name = "Visibility Check", Flag = "Aim Wall Check", Default = S.AimBot.WallCheck, Callback = function(Value) S.AimBot.WallCheck = Value end })
    AimSection:Toggle({ Name = "Downed Check", Flag = "Aim Downed Check", Default = S.AimBot.DownedCheck, Callback = function(Value) S.AimBot.DownedCheck = Value end })
    AimSection:Toggle({ Name = "Lock Target", Flag = "Aim Sticky", Default = S.AimBot.Sticky, Callback = function(Value)
        S.AimBot.Sticky = Value
        S.AimBot.Target = nil
    end })
    AimSection:Slider({ Name = "FOV Size", Flag = "Aim FOV", Min = 10, Max = 700, Default = S.AimBot.FOV, Decimals = 1, Suffix = " px", Callback = function(Value) S.AimBot.FOV = Value end })
    AimSection:Slider({ Name = "Smooth", Flag = "Aim Smoothness", Min = 0.01, Max = 1, Default = S.AimBot.Smoothness, Decimals = 0.01, Callback = function(Value)
        S.AimBot.Smoothness = Value
    end })
    AimSection:Slider({ Name = "Prediction", Flag = "Aim Prediction", Min = 0, Max = 300, Default = S.AimBot.Prediction, Decimals = 1, Suffix = "%", Callback = function(Value)
        S.AimBot.Prediction = Value
    end })
    local AimVisualSection = Visuals:Section({ Name = "Aim FOV", Side = 2 })
    AimVisualSection:Toggle({ Name = "FOV Circle", Flag = "Show Aim FOV", Default = S.AimBot.ShowFOV, Callback = function(Value)
        S.AimBot.ShowFOV = Value
        if Value and S.AimBot.Enabled and not S.AimBot.FOVCircle then
            CreateFOVCircle()
        elseif S.AimBot.FOVCircle then
            S.AimBot.FOVCircle.Visible = Value and S.AimBot.Enabled
        end
    end }):Colorpicker({ Name = "Circle Color", Flag = "Aim FOV Color", Default = S.AimBot.FOVColor, Callback = function(Value)
        S.AimBot.FOVColor = Value
        if S.AimBot.FOVCircle then S.AimBot.FOVCircle.Color = Value end
    end })
    AimVisualSection:Toggle({ Name = "Glow", Flag = "Aim FOV Glow", Default = S.AimBot.FOVGlow, Callback = function(Value)
        S.AimBot.FOVGlow = Value
        if S.AimBot.Enabled and S.AimBot.ShowFOV then CreateFOVCircle() end
    end }):Colorpicker({ Name = "Glow Color", Flag = "Aim FOV Glow Color", Default = S.AimBot.FOVGlowColor, Callback = function(Value)
        S.AimBot.FOVGlowColor = Value
        if S.AimBot.FOVGlowCircle then S.AimBot.FOVGlowCircle.Color = Value end
    end })
    AimVisualSection:Slider({ Name = "Glow Width", Flag = "Aim FOV Glow Thickness", Min = 3, Max = 24, Default = S.AimBot.FOVGlowThickness, Decimals = 1, Suffix = " px", Callback = function(Value)
        S.AimBot.FOVGlowThickness = Value
        if S.AimBot.FOVGlowCircle then S.AimBot.FOVGlowCircle.Thickness = Value end
    end })
    AimVisualSection:Slider({ Name = "Glow Alpha", Flag = "Aim FOV Glow Transparency", Min = 0, Max = 1, Default = S.AimBot.FOVGlowTransparency, Decimals = 0.05, Callback = function(Value)
        S.AimBot.FOVGlowTransparency = Value
        if S.AimBot.FOVGlowCircle then S.AimBot.FOVGlowCircle.Transparency = Value end
    end })
    AimVisualSection:Slider({ Name = "Circle Alpha", Flag = "Aim FOV Transparency", Min = 0, Max = 1, Default = S.AimBot.FOVTransparency, Decimals = 0.05, Callback = function(Value)
        S.AimBot.FOVTransparency = Value
        if S.AimBot.FOVCircle then S.AimBot.FOVCircle.Transparency = Value end
    end })
    local RageSection = Combat:Section({ Name = "Rage", Side = 2 })
    RageSection:Toggle({ Name = "Enable", Flag = "Rage Bot", Default = RageBotEnabled, Callback = function(Value)
        if Value then
            RageBotAPI.Enable()
        else
            RageBotAPI.Disable()
        end
    end }):Keybind({ Name = "Rage Bind", Flag = "Rage Bind", Default = "None", Mode = "Toggle", Callback = function()
    end })
    RageSection:Slider({ Name = "Shot Delay", Flag = "Rage Delay", Min = 0.01, Max = 0.5, Default = RageBotSettings.Delay, Decimals = 0.01, Suffix = "s", Callback = function(Value)
        RageBotSettings.Delay = math.clamp(tonumber(Value) or 0.15, 0.01, 0.5)
        RageShotState.NextServerShot = 0
    end })
    RageSection:Toggle({ Name = "Auto Reload", Flag = "Rage Auto Reload", Default = RageBotSettings.AutoReload, Callback = function(Value)
        RageBotSettings.AutoReload = Value == true
        if not RageBotSettings.AutoReload then ResetRageReloadState(nil) end
    end })
    RageSection:Dropdown({ Name = "Selection", Flag = "Rage Target Mode", Default = RageBotSettings.TargetMode, Items = { "Nearest", "FOV" }, Callback = function(Value)
        RageBotSettings.TargetMode = Value
    end })
    RageSection:Dropdown({ Name = "Hitbox", Flag = "Rage Target Part", Default = RageBotSettings.TargetPart, Items = { "Head", "HumanoidRootPart", "UpperTorso", "Torso" }, Callback = function(Value)
        RageBotSettings.TargetPart = Value
        RageBotStickyTarget = nil
        RageResolverTargetScan.LastScan = 0
        RageResolverTargetScan.Player = nil
        RageResolverTargetScan.Character = nil
        RageResolverTargetScan.Part = nil
        if RadiantAimEngine and type(RadiantAimEngine.ClearWallbangCache) == "function" then RadiantAimEngine.ClearWallbangCache() end
    end })
    RageSection:Dropdown({ Name = "FOV Anchor", Flag = "Rage FOV Origin", Default = RageBotSettings.FOVOrigin, Items = { "Center", "Mouse" }, Callback = function(Value)
        RageBotSettings.FOVOrigin = Value
    end })
    RageSection:Toggle({ Name = "Team Check", Flag = "Rage Team Check", Default = RageBotSettings.CheckTeam, Callback = function(Value) RageBotSettings.CheckTeam = Value end })
    RageSection:Toggle({ Name = "Use Whitelist", Flag = "Rage Whitelist Check", Default = RageBotSettings.CheckWhitelist, Callback = function(Value)
        RageBotSettings.CheckWhitelist = Value
    end })
    RageSection:Slider({ Name = "FOV Size", Flag = "Rage FOV", Min = 25, Max = 700, Default = RageBotSettings.FOV, Decimals = 1, Suffix = " px", Callback = function(Value)
        RageBotSettings.FOV = Value
    end })
    RageSection:Toggle({ Name = "FOV Circle", Flag = "Rage Show FOV", Default = RageBotSettings.ShowFOV, Callback = function(Value)
        RageBotSettings.ShowFOV = Value
    end }):Colorpicker({ Name = "Circle Color", Flag = "Rage FOV Color", Default = RageBotSettings.FOVColor, Callback = function(Value) RageBotSettings.FOVColor = Value end })
    RageSection:Slider({ Name = "Prediction", Flag = "Rage Prediction", Min = 0, Max = 0.45, Default = RageBotSettings.Prediction, Decimals = 0.01, Suffix = "s", Callback = function(Value)
        RageBotSettings.Prediction = Value
    end })
    RageSection:Toggle({ Name = "Resolver", Flag = "Rage Resolver", Default = RageBotSettings.Resolver, Callback = function(Value)
        RageBotSettings.Resolver = Value == true
    end })
    RageSection:Toggle({ Name = "Wallbang", Flag = "Rage Magic Bullet", Default = RageBotSettings.MagicBullet, Callback = function(Value)
        RageBotSettings.MagicBullet = Value == true
        RageBotStickyTarget = nil
        RageResolverTargetScan.LastScan = 0
        RageResolverTargetScan.Player = nil
        RageResolverTargetScan.Character = nil
        RageResolverTargetScan.Part = nil
        RageMagicBulletCache.TargetPart = nil
        RageMagicBulletCache.Character = nil
        RageMagicBulletCache.Origin = nil
        RageMagicBulletCache.RealOrigin = nil
        RageMagicBulletCache.PartPosition = nil
        RageMagicBulletCache.HitPosition = nil
        RageMagicBulletCache.SampleAim = nil
        RageMagicBulletCache.Manipulated = nil
        RageMagicBulletCache.RegistrationKey = nil
        RageMagicBulletCache.Score = nil
        RageMagicBulletCache.Time = 0
        RageMagicRegistrationState.Cache = setmetatable({}, { __mode = "k" })
        RageMagicProbeState.Cache = setmetatable({}, { __mode = "k" })
        if type(RageShotState.ClearPending) == "function" then RageShotState.ClearPending() end
        if RadiantAimEngine and type(RadiantAimEngine.ClearWallbangCache) == "function" then
            RadiantAimEngine.ClearWallbangCache()
        end
    end })
    RageSection:Slider({ Name = "Samples", Flag = "Rage Magic Samples", Min = 1, Max = 16, Default = RageBotSettings.MagicSamples, Decimals = 1, Callback = function(Value)
        RageBotSettings.MagicSamples = math.clamp(math.floor(tonumber(Value) or 8), 1, 16)
        RadiantAimEngine.Config.MagicSampleLimit = RageBotSettings.MagicSamples
        if RadiantAimEngine and type(RadiantAimEngine.ClearWallbangCache) == "function" then RadiantAimEngine.ClearWallbangCache() end
    end })
    RageSection:Toggle({ Name = "Lock Target", Flag = "Rage Sticky", Default = RageBotSettings.Sticky, Callback = function(Value)
        RageBotSettings.Sticky = Value
        if not Value then RageBotStickyTarget = nil end
    end })
    RageSection:Dropdown({ Name = "Origin", Flag = "Rage Origin Mode", Default = RageBotSettings.OriginMode, Items = { "Camera", "Root" }, Callback = function(Value)
        RageBotSettings.OriginMode = Value
    end })
    RageSection:Slider({ Name = "Range", Flag = "Rage Max Distance", Min = 100, Max = 2500, Default = RageBotSettings.MaxDistance, Decimals = 50, Suffix = " studs", Callback = function(Value)
        RageBotSettings.MaxDistance = Value
    end })
    local WhitelistInput = ""
    local WhitelistSection = PlayersPage:Section({ Name = "Whitelist", Side = 2 })
    WhitelistSection:Textbox({ Name = "Username", Flag = "Whitelist Player", Placeholder = "username", Callback = function(Value) WhitelistInput = tostring(Value) end })
    WhitelistSection:Button({ Name = "Add", Callback = function()
        if WhitelistInput == "" then return end
        if not table.find(WhitelistTable, WhitelistInput) then table.insert(WhitelistTable, WhitelistInput) end
    end })
    WhitelistSection:Button({ Name = "Remove", Callback = function()
        local Index = table.find(WhitelistTable, WhitelistInput)
        if Index then table.remove(WhitelistTable, Index) end
    end })
    WhitelistSection:Button({ Name = "Clear", Callback = function() WhitelistTable = {} end })
    local WeaponSection = Combat:Section({ Name = "Weapons", Side = 1 })
    WeaponSection:Toggle({ Name = "Enable", Flag = "Weapon Mods", Default = S.NoRecoil.Enabled, Callback = function(Value) ToggleNoRecoil(Value) end })
    WeaponSection:Toggle({ Name = "Instant Reload", Flag = "Weapon Instant Reload", Default = S.NoRecoil.Settings.GunMods.InstantReload, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.InstantReload = Value == true
        WeaponInstantReloadState.Busy = false
        RefreshWeaponInstantReloadBinding()
    end })
    WeaponSection:Toggle({ Name = "Instant Equip", Flag = "Weapon Instant Equip", Default = S.NoRecoil.Settings.GunMods.InstantEquip, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.InstantEquip = Value == true
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Toggle({ Name = "No Recoil", Flag = "Remove Recoil", Default = S.NoRecoil.Settings.GunMods.NoRecoil, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.NoRecoil = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Toggle({ Name = "Spread Override", Flag = "Modify Spread", Default = S.NoRecoil.Settings.GunMods.Spread, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.Spread = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Slider({ Name = "Spread", Flag = "Spread Amount", Min = 0, Max = 5, Default = S.NoRecoil.Settings.GunMods.SpreadAmount, Decimals = 0.05, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.SpreadAmount = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    WeaponSection:Toggle({ Name = "Static Crosshair", Flag = "Remove Crosshair Expansion", Default = S.NoRecoil.Settings.GunMods.NoCrosshair, Callback = function(Value)
        S.NoRecoil.Settings.GunMods.NoCrosshair = Value
        if S.NoRecoil.Enabled then RefreshGunModsNR() end
    end })
    local AuraSection = Combat:Section({ Name = "Auras", Side = 2 })
    AuraSection:Toggle({ Name = "Crowbar", Flag = "Crowbar Aura", Default = CrowbarAuraEnabled, Callback = function(Value)
        if Value then
            CrowbarAuraEnable()
        else
            CrowbarAuraDisable()
        end
    end })
    AuraSection:Toggle({ Name = "Melee", Flag = "Melee Aura", Default = MeleeAuraEnabled, Callback = function(Value)
        if Value then
            MeleeAuraEnable()
        else
            MeleeAuraDisable()
        end
    end })
    AuraSection:Toggle({ Name = "Finish", Flag = "Finish Aura", Default = FinishAuraEnabled, Callback = function(Value)
        if Value then
            FinishAuraEnable()
        else
            FinishAuraDisable()
        end
    end })
    local SafeFarmSection = Farming:Section({ Name = "Safe Farm", Side = 1 })
    SafeFarmSection:Toggle({ Name = "Enable", Flag = "Safe Farm", Default = SafeFarmEnabled, Callback = function(Value)
        if Value then
            SafeFarmEnable()
        else
            SafeFarmDisable()
        end
    end })
    local BreakingMethodItems = { "Crowbar", "Fist + Lockpick" }
    local CurrentBreakingMethod = RadiantFarmModule.Settings.BreakingMethod
    if CurrentBreakingMethod ~= "Crowbar" and CurrentBreakingMethod ~= "Fist + Lockpick" then
        CurrentBreakingMethod = "Crowbar"
        RadiantFarmModule.SetSetting("BreakingMethod", CurrentBreakingMethod)
    end
    SafeFarmSection:Dropdown({ Name = "Method", Flag = "Safe Farm Breaking Method", Items = BreakingMethodItems, Default = CurrentBreakingMethod, Callback = function(Value)
        if type(Value) == "number" then
            Value = BreakingMethodItems[Value]
        elseif Value == "1" then
            Value = "Crowbar"
        elseif Value == "2" then
            Value = "Fist + Lockpick"
        end
        if Value == "Crowbar" or Value == "Fist + Lockpick" then
            RadiantFarmModule.SetSetting("BreakingMethod", Value)
        end
    end })
    SafeFarmSection:Slider({ Name = "Speed", Flag = "Safe Farm Speed", Min = 10, Max = 45, Default = RadiantFarmModule.Settings.MoveSpeed, Decimals = 1, Callback = function(Value)
        RadiantFarmModule.SetSetting("MoveSpeed", math.clamp(tonumber(Value) or 32, 10, 45))
    end })
    local FarmAutomationSection = Farming:Section({ Name = "Automation", Side = 1 })
    FarmAutomationSection:Toggle({ Name = "Collect Cash", Flag = "Safe Farm Auto Money", Default = RadiantFarmModule.Settings.AutoMoney, Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoMoney", Value == true)
    end })
    FarmAutomationSection:Toggle({ Name = "Auto Deposit", Flag = "Safe Farm Auto Deposit", Default = RadiantFarmModule.Settings.AutoDeposit, Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoDeposit", Value == true)
    end })
    FarmAutomationSection:Slider({ Name = "Deposit At", Flag = "Safe Farm Deposit At", Min = 1, Max = 100, Default = RadiantFarmModule.Settings.AutoDepositThresholdK, Decimals = 1,
        Suffix = "k", Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoDepositThresholdK", math.clamp(tonumber(Value) or 5, 1, 100))
    end })
    FarmAutomationSection:Toggle({ Name = "Allowance", Flag = "Safe Farm Auto Allowance", Default = RadiantFarmModule.Settings.AutoAllowance, Callback = function(Value)
        RadiantFarmModule.SetSetting("AutoAllowance", Value == true)
    end })
    local MoneySection = Farming:Section({ Name = "Cash", Side = 2 })
    MoneySection:Toggle({ Name = "Pickup Cash", Flag = "Auto Pickup Money", Default = AutoPickupMoneyEnabled, Callback = function(Value)
        if Value then
            AutoPickupMoneyEnable()
        else
            AutoPickupMoneyDisable()
        end
    end })
    MoneySection:Toggle({ Name = "Fast Pickup", Flag = "Fast Pickup", Default = FastPickupEnabled, Callback = function(Value)
        if Value then
            FastPickupEnable()
        else
            FastPickupDisable()
        end
    end })
    MoneySection:Toggle({ Name = "Auto ATM", Flag = "Auto ATM", Default = AutoATMEnabled, Callback = function(Value)
        if Value then
            AutoATMEnable()
        else
            AutoATMDisable()
        end
    end })
    MoneySection:Slider({ Name = "ATM Interval", Flag = "ATM Interval", Min = 60, Max = 1800, Default = AutoATMInterval, Decimals = 5, Suffix = "s", Callback = function(Value)
        AutoATMInterval = Value
    end })
    local AltFarmSection = Farming:Section({ Name = "Alt Farm", Side = 2 })
    AltFarmSection:Toggle({ Name = "Enable", Flag = "Alt Farm", Default = AltFarmEnabled, Callback = function(Value)
        if Value then
            AltFarmEnable()
        else
            AltFarmDisable()
        end
    end })
    local PlayerESPSection = PlayersPage:Section({ Name = "Players", Side = 1 })
    local PlayerESPToggle = PlayerESPSection:Toggle({ Name = "Enable", Flag = "Player ESP", Default = VisualState.Player.Enabled, Callback = function(Value)
        VisualState.Player.Enabled = Value
        EnsureVisualEngine()
        if not Value then
            for Unused, Data in ipairs(VisualState.Player.List) do HidePlayerVisual(Data) end
        end
    end })
    PlayerESPToggle:Colorpicker({ Name = "Box Color", Flag = "Player ESP Box Color", Default = VisualState.Player.BoxColor, Callback = function(Value) VisualState.Player.BoxColor = Value end })
    PlayerESPToggle:Keybind({ Name = "ESP Bind", Flag = "Player ESP Bind", Default = "None", Mode = "Toggle", Callback = function() end })
    PlayerESPSection:Dropdown({ Name = "Box Style", Flag = "Player ESP Box Style", Default = VisualState.Player.BoxStyle, Items = { "Corners", "Full" }, Callback = function(Value)
        VisualState.Player.BoxStyle = Value
    end })
    PlayerESPSection:Toggle({ Name = "Boxes", Flag = "Player ESP Boxes", Default = VisualState.Player.Boxes, Callback = function(Value)
        VisualState.Player.Boxes = Value
    end }):Colorpicker({ Name = "Outline Color", Flag = "Player ESP Outline Color", Default = VisualState.Player.OutlineColor, Callback = function(Value)
        VisualState.Player.OutlineColor = Value
    end })
    PlayerESPSection:Toggle({ Name = "Fill", Flag = "Player ESP Fill", Default = VisualState.Player.Fill, Callback = function(Value)
        VisualState.Player.Fill = Value
    end }):Colorpicker({ Name = "Fill Color", Flag = "Player ESP Fill Color", Default = VisualState.Player.FillColor, Callback = function(Value) VisualState.Player.FillColor = Value end })
    PlayerESPSection:Slider({ Name = "Fill Alpha", Flag = "Player ESP Fill Transparency", Min = 0, Max = 1, Default = VisualState.Player.FillTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.FillTransparency = Value
    end })
    PlayerESPSection:Toggle({ Name = "Names", Flag = "Player ESP Names", Default = VisualState.Player.Names, Callback = function(Value)
        VisualState.Player.Names = Value
    end }):Colorpicker({ Name = "Text Color", Flag = "Player ESP Text Color", Default = VisualState.Player.TextColor, Callback = function(Value) VisualState.Player.TextColor = Value end })
    PlayerESPSection:Toggle({ Name = "Health Bar", Flag = "Player ESP Health Bar", Default = VisualState.Player.HealthBar, Callback = function(Value)
        VisualState.Player.HealthBar = Value
    end }):Colorpicker({ Name = "High HP", Flag = "Player ESP Health High Color", Default = VisualState.Player.HealthHighColor, Callback = function(Value)
        VisualState.Player.HealthHighColor = Value
    end })
    PlayerESPSection:Label({ Name = "Low HP", Alignment = "Left" }):Colorpicker({ Name = "Low HP", Flag = "Player ESP Health Low Color", Default = VisualState.Player.HealthLowColor,
        Callback = function(Value)
        VisualState.Player.HealthLowColor = Value
    end })
    PlayerESPSection:Toggle({ Name = "Health Text", Flag = "Player ESP Health Value", Default = VisualState.Player.HealthText, Callback = function(Value)
        VisualState.Player.HealthText = Value
    end })
    PlayerESPSection:Toggle({ Name = "Distance", Flag = "Player ESP Distance", Default = VisualState.Player.Distance, Callback = function(Value) VisualState.Player.Distance = Value end })
    PlayerESPSection:Toggle({ Name = "Weapon", Flag = "Player ESP Weapon", Default = VisualState.Player.Weapon, Callback = function(Value) VisualState.Player.Weapon = Value end })
    PlayerESPSection:Toggle({ Name = "Team Check", Flag = "Player ESP Team Check", Default = VisualState.Player.TeamCheck, Callback = function(Value)
        VisualState.Player.TeamCheck = Value
        UpdatePlayerChams()
    end })
    PlayerESPSection:Slider({ Name = "Text Size", Flag = "Player ESP Text Size", Min = 10, Max = 20, Default = VisualState.Player.TextSize, Decimals = 1, Callback = function(Value)
        VisualState.Player.TextSize = Value
    end })
    PlayerESPSection:Slider({ Name = "Range", Flag = "Player ESP Max Distance", Min = 100, Max = 3000, Default = VisualState.Player.MaxDistance, Decimals = 50, Suffix = " studs",
        Callback = function(Value)
        VisualState.Player.MaxDistance = Value
    end })
    local PlayerTracerSection = PlayersPage:Section({ Name = "Tracers", Side = 2 })
    PlayerTracerSection:Toggle({ Name = "Enable", Flag = "Player ESP Tracers", Default = VisualState.Player.Tracers, Callback = function(Value)
        VisualState.Player.Tracers = Value
    end }):Colorpicker({ Name = "Color", Flag = "Player ESP Tracer Color", Default = VisualState.Player.TracerColor, Callback = function(Value)
        VisualState.Player.TracerColor = Value
    end })
    PlayerTracerSection:Dropdown({ Name = "Style", Flag = "Player ESP Tracer Style", Default = VisualState.Player.TracerStyle, Items = { "Straight", "Curved" }, Callback = function(Value)
        VisualState.Player.TracerStyle = Value
    end })
    PlayerTracerSection:Dropdown({ Name = "Start", Flag = "Player ESP Tracer Origin", Default = VisualState.Player.TracerOrigin, Items = { "Top", "Center", "Bottom" }, Callback = function(Value)
        VisualState.Player.TracerOrigin = Value
    end })
    PlayerTracerSection:Dropdown({ Name = "End", Flag = "Player ESP Tracer End", Default = VisualState.Player.TracerEnd, Items = { "Head", "Body", "Feet" }, Callback = function(Value)
        VisualState.Player.TracerEnd = Value
    end })
    PlayerTracerSection:Slider({ Name = "Width", Flag = "Player ESP Tracer Thickness", Min = 1, Max = 4, Default = VisualState.Player.TracerThickness, Decimals = 0.5, Callback = function(Value)
        VisualState.Player.TracerThickness = Value
    end })
    PlayerTracerSection:Slider({ Name = "Alpha", Flag = "Player ESP Tracer Transparency", Min = 0, Max = 0.90, Default = VisualState.Player.TracerTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.TracerTransparency = Value
    end })

    local SnaplineSection = PlayersPage:Section({ Name = "Target Line", Side = 2 })
    SnaplineSection:Toggle({ Name = "Enable", Flag = "Target Snapline", Default = VisualState.Snapline.Enabled, Callback = function(Value)
        VisualState.Snapline.Enabled = Value == true
        EnsureVisualEngine()
        if not VisualState.Snapline.Enabled then HideTargetSnapline() end
    end }):Colorpicker({ Name = "Color", Flag = "Target Snapline Color", Default = VisualState.Snapline.Color, Callback = function(Value)
        VisualState.Snapline.Color = Value
    end })
    SnaplineSection:Dropdown({ Name = "Start", Flag = "Target Snapline Source", Default = VisualState.Snapline.Source, Items = { "Combat Target", "Closest to Cursor" }, Callback = function(Value)
        VisualState.Snapline.Source = Value
    end })
    SnaplineSection:Dropdown({ Name = "End", Flag = "Target Snapline Part", Default = VisualState.Snapline.TargetPart, Items = { "Head", "Body", "Feet" }, Callback = function(Value)
        VisualState.Snapline.TargetPart = Value
    end })
    SnaplineSection:Dropdown({ Name = "Style", Flag = "Target Snapline Style", Default = VisualState.Snapline.Style, Items = { "Straight", "Curved" }, Callback = function(Value)
        VisualState.Snapline.Style = Value
    end })
    SnaplineSection:Slider({ Name = "Width", Flag = "Target Snapline Thickness", Min = 1, Max = 4, Default = VisualState.Snapline.Thickness, Decimals = 0.5, Callback = function(Value)
        VisualState.Snapline.Thickness = Value
    end })
    SnaplineSection:Slider({ Name = "Alpha", Flag = "Target Snapline Transparency", Min = 0, Max = 0.90, Default = VisualState.Snapline.Transparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Snapline.Transparency = Value
    end })

    local PreviewHUDSection = PlayersPage:Section({ Name = "HUD", Side = 2 })
    PreviewHUDSection:Toggle({ Name = "Preview", Flag = "ESP Preview", Default = VisualState.Widgets.ESPPreviewEnabled, Callback = function(Value)
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
    PreviewHUDSection:Label({ Name = "Drag Target HUD while the menu is open", Alignment = "Left" })

    CreateRadiantVisualWidgets()

    local BulletTracerSection = Visuals:Section({ Name = "Bullet Tracers", Side = 1 })
    BulletTracerSection:Toggle({ Name = "Enable", Flag = "Bullet Tracers", Default = HitFeedbackState.BulletTracerEnabled, Callback = function(Value)
        HitFeedbackState.BulletTracerEnabled = Value == true
        SetBulletTracerShotHookEnabled(HitFeedbackState.BulletTracerEnabled)
        if not HitFeedbackState.BulletTracerEnabled then ClearBulletTracers() end
    end }):Colorpicker({ Name = "Color", Flag = "Bullet Tracer Color", Default = HitFeedbackState.BulletTracerColor, Callback = function(Value)
        HitFeedbackState.BulletTracerColor = Value
    end })
    BulletTracerSection:Dropdown({ Name = "Style", Flag = "Bullet Tracer Style", Default = HitFeedbackState.BulletTracerStyle, Items = { "Clean", "Energy", "Pulse" }, Callback = function(Value)
        HitFeedbackState.BulletTracerStyle = Value
    end })
    BulletTracerSection:Slider({ Name = "Lifetime", Flag = "Bullet Tracer Time", Min = 0.05, Max = 2, Default = HitFeedbackState.BulletTracerTime, Decimals = 0.05, Suffix = " s", Callback = function(Value)
        HitFeedbackState.BulletTracerTime = Value
    end })
    BulletTracerSection:Slider({ Name = "Rate", Flag = "Bullet Tracer Rate", Min = 0, Max = 120, Default = HitFeedbackState.BulletTracerRate, Decimals = 1, Suffix = " p/s", Callback = function(Value)
        HitFeedbackState.BulletTracerRate = Value
    end })
    BulletTracerSection:Slider({ Name = "Width", Flag = "Bullet Tracer Width", Min = 0.01, Max = 0.5, Default = HitFeedbackState.BulletTracerWidth, Decimals = 0.01, Suffix = " studs",
        Callback = function(Value)
        HitFeedbackState.BulletTracerWidth = Value
    end })
    BulletTracerSection:Slider({ Name = "Glow", Flag = "Bullet Tracer Glow", Min = 0, Max = 5, Default = HitFeedbackState.BulletTracerGlow, Decimals = 0.25, Callback = function(Value)
        HitFeedbackState.BulletTracerGlow = Value
    end })
    local ImpactSection = Visuals:Section({ Name = "Impacts", Side = 1 })
    ImpactSection:Toggle({ Name = "Ghost", Flag = "Impact Ghost", Default = HitFeedbackState.ImpactEnabled, Callback = function(Value)
        HitFeedbackState.ImpactEnabled = Value == true
        RefreshLocalShotTracking()
    end }):Colorpicker({ Name = "Color", Flag = "Impact Color", Default = HitFeedbackState.ImpactColor, Callback = function(Value) HitFeedbackState.ImpactColor = Value end })
    ImpactSection:Dropdown({ Name = "Style", Flag = "Impact Style", Default = HitFeedbackState.ImpactStyle, Items = { "Character", "Ball", "Cylinder", "Block" }, Callback = function(Value)
        HitFeedbackState.ImpactStyle = Value
    end })
    ImpactSection:Slider({ Name = "Alpha", Flag = "Impact Transparency", Min = 0, Max = 0.95, Default = HitFeedbackState.ImpactTransparency, Decimals = 0.05, Callback = function(Value)
        HitFeedbackState.ImpactTransparency = Value
    end })
    local HitmarkerSection = Visuals:Section({ Name = "Hit Marker", Side = 1 })
    HitmarkerSection:Toggle({ Name = "Enable", Flag = "Confirmed Hitmarker", Default = HitFeedbackState.HitmarkerEnabled, Callback = function(Value)
        HitFeedbackState.HitmarkerEnabled = Value == true
        RefreshLocalShotTracking()
    end }):Colorpicker({ Name = "Body Color", Flag = "Hitmarker Body Color", Default = HitFeedbackState.HitmarkerColor, Callback = function(Value)
        HitFeedbackState.HitmarkerColor = Value
    end })
    HitmarkerSection:Label({ Name = "Head Color", Alignment = "Left" }):Colorpicker({ Name = "Head Color", Flag = "Hitmarker Headshot Color", Default =
        HitFeedbackState.HeadshotHitmarkerColor, Callback = function(Value)
        HitFeedbackState.HeadshotHitmarkerColor = Value
    end })
    HitmarkerSection:Slider({ Name = "Size", Flag = "Hitmarker Size", Min = 12, Max = 60, Default = HitFeedbackState.HitmarkerSize, Decimals = 1, Suffix = " px", Callback = function(Value)
        HitFeedbackState.HitmarkerSize = Value
    end })
    HitmarkerSection:Slider({ Name = "Lifetime", Flag = "Hitmarker Duration", Min = 0.08, Max = 1, Default = HitFeedbackState.HitmarkerDuration, Decimals = 0.02, Suffix = " s",
        Callback = function(Value)
        HitFeedbackState.HitmarkerDuration = Value
    end })
    local HitSoundSection = Visuals:Section({ Name = "Hit Sound", Side = 1 })
    HitSoundSection:Dropdown({ Name = "Sound", Flag = "Hit Sound", Default = HitFeedbackState.HitSound, Items = HitSoundNames, Callback = function(Value)
        HitFeedbackState.HitSound = HitSounds[Value] ~= nil and Value or "None"
        RefreshLocalShotTracking()
    end })
    HitSoundSection:Slider({ Name = "Volume", Flag = "Hit Sound Volume", Min = 0, Max = 5, Default = HitFeedbackState.HitSoundVolume, Decimals = 0.05, Callback = function(Value)
        HitFeedbackState.HitSoundVolume = Value
    end })
    HitSoundSection:Slider({ Name = "Pitch", Flag = "Hit Sound Pitch", Min = 0.5, Max = 2, Default = HitFeedbackState.HitSoundPlaybackSpeed, Decimals = 0.05, Callback = function(Value)
        HitFeedbackState.HitSoundPlaybackSpeed = Value
    end })
    local DamageIndicatorSection = Visuals:Section({ Name = "Damage Text", Side = 1 })
    DamageIndicatorSection:Toggle({ Name = "Enable", Flag = "Damage Indicator", Default = HitFeedbackState.DamageIndicatorEnabled, Callback = function(Value)
        HitFeedbackState.DamageIndicatorEnabled = Value == true
        RefreshLocalShotTracking()
    end }):Colorpicker({ Name = "Body Color", Flag = "Damage Indicator Body Color", Default = HitFeedbackState.DamageColor, Callback = function(Value)
        HitFeedbackState.DamageColor = Value
    end })
    DamageIndicatorSection:Label({ Name = "Head Color", Alignment = "Left" }):Colorpicker({ Name = "Head Color", Flag = "Damage Indicator Headshot Color", Default =
        HitFeedbackState.HeadshotDamageColor, Callback = function(Value)
        HitFeedbackState.HeadshotDamageColor = Value
    end })
    DamageIndicatorSection:Slider({ Name = "Text Size", Flag = "Damage Indicator Text Size", Min = 10, Max = 30, Default = HitFeedbackState.DamageTextSize, Decimals = 1, Callback = function(Value)
        HitFeedbackState.DamageTextSize = Value
    end })
    DamageIndicatorSection:Slider({ Name = "Lifetime", Flag = "Damage Indicator Duration", Min = 0.20, Max = 2, Default = HitFeedbackState.DamageDuration, Decimals = 0.05, Suffix = " s",
        Callback = function(Value)
        HitFeedbackState.DamageDuration = Value
    end })
    DamageIndicatorSection:Slider({ Name = "Rise", Flag = "Damage Indicator Rise", Min = 0.5, Max = 6, Default = HitFeedbackState.DamageRise, Decimals = 0.1, Suffix = " studs", Callback = function(Value)
        HitFeedbackState.DamageRise = Value
    end })
    local ChamsSection = PlayersPage:Section({ Name = "Chams", Side = 1 })
    ChamsSection:Toggle({ Name = "Enable", Flag = "Player Chams", Default = VisualState.Player.Chams.Enabled, Callback = function(Value)
        VisualState.Player.Chams.Enabled = Value
        EnsureVisualEngine()
        UpdatePlayerChams()
    end })
    ChamsSection:Toggle({ Name = "Fill", Flag = "Player Chams Fill Enabled", Default = VisualState.Player.Chams.FillEnabled, Callback = function(Value)
        VisualState.Player.Chams.FillEnabled = Value
        UpdatePlayerChams()
    end }):Colorpicker({ Name = "Fill Color", Flag = "Player Chams Fill", Default = VisualState.Player.Chams.FillColor, Callback = function(Value)
        VisualState.Player.Chams.FillColor = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Toggle({ Name = "Outline", Flag = "Player Chams Outline Enabled", Default = VisualState.Player.Chams.OutlineEnabled, Callback = function(Value)
        VisualState.Player.Chams.OutlineEnabled = Value
        UpdatePlayerChams()
    end }):Colorpicker({ Name = "Outline Color", Flag = "Player Chams Outline", Default = VisualState.Player.Chams.OutlineColor, Callback = function(Value)
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
    ChamsSection:Slider({ Name = "Fill Alpha", Flag = "Player Chams Fill Transparency", Min = 0, Max = 1, Default = VisualState.Player.Chams.FillTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.Chams.FillTransparency = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Slider({ Name = "Outline Alpha", Flag = "Player Chams Outline Transparency", Min = 0, Max = 1, Default = VisualState.Player.Chams.OutlineTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.Chams.OutlineTransparency = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Slider({ Name = "Wall Alpha", Flag = "Player Chams Wall Transparency", Min = 0, Max = 1, Default = VisualState.Player.Chams.WallTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.Chams.WallTransparency = Value
        UpdatePlayerChams()
    end })
    ChamsSection:Slider({ Name = "Glow Alpha", Flag = "Player Chams Glow Transparency", Min = 0, Max = 1, Default = VisualState.Player.Chams.GlowTransparency, Decimals = 0.05, Callback = function(Value)
        VisualState.Player.Chams.GlowTransparency = Value
        UpdatePlayerChams()
    end })
    local WorldSection = WorldPage:Section({ Name = "Lighting", Side = 1 })
    WorldSection:Toggle({ Name = "Enable", Flag = "World Override", Default = VisualState.World.Enabled, Callback = function(Value)
        VisualState.World.Enabled = Value
        if Value then
            StartWorldOverride()
        else
            RestoreWorldVisuals()
        end
    end }):Colorpicker({ Name = "Ambient", Flag = "World Ambient", Default = VisualState.World.Ambient, Callback = function(Value)
        VisualState.World.Ambient = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Label({ Name = "Outdoor", Alignment = "Left" }):Colorpicker({ Name = "Outdoor", Flag = "World Outdoor Ambient", Default = VisualState.World.OutdoorAmbient,
        Callback = function(Value)
        VisualState.World.OutdoorAmbient = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Label({ Name = "Tint", Alignment = "Left" }):Colorpicker({ Name = "Tint", Flag = "World Tint Color", Default = VisualState.World.TintColor, Callback = function(Value)
        VisualState.World.TintColor = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Brightness", Flag = "World Brightness", Min = 0, Max = 5, Default = VisualState.World.Brightness, Decimals = 0.1, Callback = function(Value)
        VisualState.World.Brightness = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Time", Flag = "World Time", Min = 0, Max = 24, Default = VisualState.World.ClockTime, Decimals = 0.5, Suffix = "h", Callback = function(Value)
        VisualState.World.ClockTime = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Toggle({ Name = "Fog", Flag = "World Fog", Default = VisualState.World.FogEnabled, Callback = function(Value)
        VisualState.World.FogEnabled = Value
        QueueWorldVisualApply()
    end }):Colorpicker({ Name = "Fog Color", Flag = "World Fog Color", Default = VisualState.World.FogColor, Callback = function(Value)
        VisualState.World.FogColor = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Distance", Flag = "World Fog Distance", Min = 50, Max = 5000, Default = VisualState.World.FogDistance, Decimals = 50, Suffix = " studs", Callback = function(Value)
        VisualState.World.FogDistance = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Start", Flag = "World Fog Start", Min = 0, Max = 1500, Default = VisualState.World.FogStart, Decimals = 10, Suffix = " studs", Callback = function(Value)
        VisualState.World.FogStart = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Density", Flag = "World Fog Density", Min = 0, Max = 1, Default = VisualState.World.FogDensity, Decimals = 0.01, Callback = function(Value)
        VisualState.World.FogDensity = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Haze", Flag = "World Fog Haze", Min = 0, Max = 10, Default = VisualState.World.FogHaze, Decimals = 0.1, Callback = function(Value)
        VisualState.World.FogHaze = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Glare", Flag = "World Fog Glare", Min = 0, Max = 10, Default = VisualState.World.FogGlare, Decimals = 0.1, Callback = function(Value)
        VisualState.World.FogGlare = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Offset", Flag = "World Fog Offset", Min = -1, Max = 1, Default = VisualState.World.FogOffset, Decimals = 0.05, Callback = function(Value)
        VisualState.World.FogOffset = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Label({ Name = "Fog Decay", Alignment = "Left" }):Colorpicker({ Name = "Fog Decay", Flag = "World Fog Decay", Default = VisualState.World.FogDecay, Callback = function(Value)
        VisualState.World.FogDecay = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Saturation", Flag = "World Saturation", Min = -1, Max = 1, Default = VisualState.World.Saturation, Decimals = 0.05, Callback = function(Value)
        VisualState.World.Saturation = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Slider({ Name = "Contrast", Flag = "World Contrast", Min = -1, Max = 1, Default = VisualState.World.Contrast, Decimals = 0.05, Callback = function(Value)
        VisualState.World.Contrast = Value
        QueueWorldVisualApply()
    end })
    WorldSection:Toggle({ Name = "Bloom", Flag = "World Bloom", Default = VisualState.World.Bloom, Callback = function(Value)
        VisualState.World.Bloom = Value
        QueueWorldVisualApply()
    end })

    local WorldEffectsSection = WorldPage:Section({ Name = "World FX", Side = 2 })
    WorldEffectsSection:Toggle({ Name = "Enable", Flag = "World Effects Enabled", Default = WorldEffectsState.Enabled, Callback = function(Value)
        WorldEffectsState.Enabled = Value == true
        if WorldEffectsState.Enabled then StartWorldEffects() else DestroyWorldEffects() end
    end })
    WorldEffectsSection:Dropdown({ Name = "Effect", Flag = "World Effect Type", Default = WorldEffectsState.Effect, Items = { "Sakura", "Rain", "Snow", "Embers", "Fireflies" }, Callback = function(Value)
        WorldEffectsState.Effect = Value
        if WorldEffectsState.Enabled then StartWorldEffects() end
    end })
    WorldEffectsSection:Slider({ Name = "Intensity", Flag = "World Effect Intensity", Min = 5, Max = 250, Default = WorldEffectsState.Intensity, Decimals = 5, Suffix = " p/s", Callback = function(Value)
        WorldEffectsState.Intensity = Value
    end })
    WorldEffectsSection:Slider({ Name = "Radius", Flag = "World Effect Radius", Min = 15, Max = 150, Default = WorldEffectsState.Radius, Decimals = 5, Suffix = " studs", Callback = function(Value)
        WorldEffectsState.Radius = Value
    end })
    WorldEffectsSection:Slider({ Name = "Height", Flag = "World Effect Height", Min = 15, Max = 90, Default = WorldEffectsState.Height, Decimals = 1, Suffix = " studs", Callback = function(Value)
        WorldEffectsState.Height = Value
    end })
    WorldEffectsSection:Slider({ Name = "Wind", Flag = "World Effect Wind", Min = -35, Max = 35, Default = WorldEffectsState.Wind, Decimals = 1, Callback = function(Value)
        WorldEffectsState.Wind = Value
    end })
    local HitParticlesSection = Visuals:Section({ Name = "Hit FX", Side = 2 })
    HitParticlesSection:Toggle({ Name = "Enable", Flag = "Hit Particles Enabled", Default = HitParticleState.Enabled, Callback = function(Value)
        HitParticleState.Enabled = Value == true
        HitFeedbackState.HitParticlesEnabled = HitParticleState.Enabled
        RefreshLocalShotTracking()
    end }):Colorpicker({ Name = "Color", Flag = "Hit Particles Color", Default = HitParticleState.Color, Callback = function(Value) HitParticleState.Color = Value end })
    HitParticlesSection:Dropdown({ Name = "Style", Flag = "Hit Particles Style", Default = HitParticleState.Style, Items = { "Sparks", "Energy", "Blood Mist", "Petals" }, Callback = function(Value) HitParticleState.Style = Value end })
    HitParticlesSection:Slider({ Name = "Count", Flag = "Hit Particles Count", Min = 1, Max = 80, Default = HitParticleState.Count, Decimals = 1, Callback = function(Value) HitParticleState.Count = Value end })
    HitParticlesSection:Slider({ Name = "Lifetime", Flag = "Hit Particles Lifetime", Min = 0.15, Max = 2, Default = HitParticleState.Lifetime, Decimals = 0.05, Suffix = " s", Callback = function(Value) HitParticleState.Lifetime = Value end })
    HitParticlesSection:Slider({ Name = "Size", Flag = "Hit Particles Size", Min = 0.05, Max = 1, Default = HitParticleState.Size, Decimals = 0.05, Callback = function(Value) HitParticleState.Size = Value end })

    local WorldESPSection = WorldPage:Section({ Name = "World ESP", Side = 2 })
    WorldESPSection:Toggle({ Name = "Safes", Flag = "World ESP Safes", Default = VisualState.WorldESP.Safes, Callback = function(Value)
        VisualState.WorldESP.Safes = Value
        EnsureVisualEngine()
    end }):Colorpicker({ Name = "Safe Color", Flag = "World ESP Intact Safe Color", Default = VisualState.WorldESP.SafeColor, Callback = function(Value)
        VisualState.WorldESP.SafeColor = Value
    end })
    WorldESPSection:Toggle({ Name = "Cash", Flag = "World ESP Cash", Default = VisualState.WorldESP.Cash, Callback = function(Value)
        VisualState.WorldESP.Cash = Value
        EnsureVisualEngine()
    end }):Colorpicker({ Name = "Cash Color", Flag = "World ESP Cash Color", Default = VisualState.WorldESP.CashColor, Callback = function(Value)
        VisualState.WorldESP.CashColor = Value
    end })
    WorldESPSection:Label({ Name = "Broken Color", Alignment = "Left" }):Colorpicker({ Name = "Broken Color", Flag = "World ESP Broken Safe Color", Default =
        VisualState.WorldESP.BrokenColor, Callback = function(Value)
        VisualState.WorldESP.BrokenColor = Value
    end })
    WorldESPSection:Slider({ Name = "Range", Flag = "World ESP Max Distance", Min = 100, Max = 5000, Default = VisualState.WorldESP.MaxDistance, Decimals = 50, Suffix = " studs",
        Callback = function(Value)
        VisualState.WorldESP.MaxDistance = Value
    end })
    local LocalVisualSection = Visuals:Section({ Name = "Local", Side = 2 })
    LocalVisualSection:Toggle({ Name = "Arms", Flag = "Arms Chams", Default = ArmsChamsEnabled, Callback = function(Value)
        if Value then ArmsChamsEnable() else ArmsChamsDisable() end
    end })
    LocalVisualSection:Toggle({ Name = "Fill", Flag = "Arms Chams Fill", Default = ArmsChamsSettings.FillEnabled, Callback = function(Value)
        ArmsChamsSettings.FillEnabled = Value
        ApplyArmsChams()
    end }):Colorpicker({ Name = "Fill Color", Flag = "Arms Chams Fill Color", Default = ArmsChamsSettings.FillColor, Callback = function(Value)
        ArmsChamsSettings.FillColor = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Slider({ Name = "Fill Alpha", Flag = "Arms Chams Fill Transparency", Min = 0, Max = 1, Default = ArmsChamsSettings.FillTransparency, Decimals = 0.01, Callback = function(Value)
        ArmsChamsSettings.FillTransparency = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Toggle({ Name = "Glow", Flag = "Arms Chams Glow", Default = ArmsChamsSettings.GlowEnabled, Callback = function(Value)
        ArmsChamsSettings.GlowEnabled = Value
        ApplyArmsChams()
    end }):Colorpicker({ Name = "Glow Color", Flag = "Arms Chams Glow Color", Default = ArmsChamsSettings.GlowColor, Callback = function(Value)
        ArmsChamsSettings.GlowColor = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Slider({ Name = "Glow Alpha", Flag = "Arms Chams Glow Transparency", Min = 0, Max = 1, Default = ArmsChamsSettings.GlowTransparency, Decimals = 0.01, Callback = function(Value)
        ArmsChamsSettings.GlowTransparency = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Slider({ Name = "Glow Size", Flag = "Arms Chams Glow Size", Min = 1.001, Max = 1.08, Default = ArmsChamsSettings.GlowScale, Decimals = 0.005, Callback = function(Value)
        ArmsChamsSettings.GlowScale = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Toggle({ Name = "Outline", Flag = "Arms Chams Outline", Default = ArmsChamsSettings.OutlineEnabled, Callback = function(Value)
        ArmsChamsSettings.OutlineEnabled = Value
        ApplyArmsChams()
    end }):Colorpicker({ Name = "Outline Color", Flag = "Arms Chams Outline Color", Default = ArmsChamsSettings.OutlineColor, Callback = function(Value)
        ArmsChamsSettings.OutlineColor = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Slider({ Name = "Outline Alpha", Flag = "Arms Chams Outline Transparency", Min = 0, Max = 1, Default = ArmsChamsSettings.OutlineTransparency, Decimals = 0.01, Callback = function(Value)
        ArmsChamsSettings.OutlineTransparency = Value
        ApplyArmsChams()
    end })
    LocalVisualSection:Toggle({ Name = "Weapon", Flag = "Weapon Chams", Default = WeaponChamsEnabled, Callback = function(Value)
        if Value then WeaponChamsEnable() else WeaponChamsDisable() end
    end })
    LocalVisualSection:Toggle({ Name = "First Person", Flag = "Weapon Chams First Person", Default = WeaponChamsSettings.FirstPerson, Callback = function(Value)
        WeaponChamsSettings.FirstPerson = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Toggle({ Name = "Third Person", Flag = "Weapon Chams Third Person", Default = WeaponChamsSettings.ThirdPerson, Callback = function(Value)
        WeaponChamsSettings.ThirdPerson = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Toggle({ Name = "Fill", Flag = "Weapon Chams Fill", Default = WeaponChamsSettings.FillEnabled, Callback = function(Value)
        WeaponChamsSettings.FillEnabled = Value
        ApplyWeaponChams()
    end }):Colorpicker({ Name = "Fill Color", Flag = "Weapon Chams Fill Color", Default = WeaponChamsSettings.FillColor, Callback = function(Value)
        WeaponChamsSettings.FillColor = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Slider({ Name = "Fill Alpha", Flag = "Weapon Chams Fill Transparency", Min = 0, Max = 1, Default = WeaponChamsSettings.FillTransparency, Decimals = 0.01, Callback = function(Value)
        WeaponChamsSettings.FillTransparency = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Toggle({ Name = "Glow", Flag = "Weapon Chams Glow", Default = WeaponChamsSettings.GlowEnabled, Callback = function(Value)
        WeaponChamsSettings.GlowEnabled = Value
        ApplyWeaponChams()
    end }):Colorpicker({ Name = "Glow Color", Flag = "Weapon Chams Glow Color", Default = WeaponChamsSettings.GlowColor, Callback = function(Value)
        WeaponChamsSettings.GlowColor = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Slider({ Name = "Glow Alpha", Flag = "Weapon Chams Glow Transparency", Min = 0, Max = 1, Default = WeaponChamsSettings.GlowTransparency, Decimals = 0.01, Callback = function(Value)
        WeaponChamsSettings.GlowTransparency = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Slider({ Name = "Glow Size", Flag = "Weapon Chams Glow Size", Min = 1, Max = 1.025, Default = WeaponChamsSettings.GlowScale, Decimals = 0.001, Callback = function(Value)
        WeaponChamsSettings.GlowScale = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Toggle({ Name = "Outline", Flag = "Weapon Chams Outline", Default = WeaponChamsSettings.OutlineEnabled, Callback = function(Value)
        WeaponChamsSettings.OutlineEnabled = Value
        ApplyWeaponChams()
    end }):Colorpicker({ Name = "Outline Color", Flag = "Weapon Chams Outline Color", Default = WeaponChamsSettings.OutlineColor, Callback = function(Value)
        WeaponChamsSettings.OutlineColor = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Slider({ Name = "Outline Alpha", Flag = "Weapon Chams Outline Transparency", Min = 0, Max = 1, Default = WeaponChamsSettings.OutlineTransparency, Decimals = 0.01, Callback = function(Value)
        WeaponChamsSettings.OutlineTransparency = Value
        ApplyWeaponChams()
    end })
    LocalVisualSection:Toggle({ Name = "Motion Blur", Flag = "Motion Blur", Default = S.Blur.Enabled, Callback = function(Value) ToggleBlur(Value) end })
    LocalVisualSection:Toggle({ Name = "Hide Body", Flag = "Hide Body", Default = RadiantFarmModule.Settings.HideBody, Callback = function(Value)
        RadiantFarmModule.SetSetting("HideBody", Value == true)
    end })
    local CosmeticsSection = Visuals:Section({ Name = "Cosmetics", Side = 2 })
    CosmeticsSection:Toggle({ Name = "Wings", Flag = "Angel Wings", Default = S.AngelWings.Enabled, Callback = function(Value)
        ToggleAngelWings(Value)
    end }):Colorpicker({ Name = "Wing Color", Flag = "Angel Wing Core Color", Default = S.AngelWings.CoreColor, Callback = function(Value)
        S.AngelWings.CoreColor = Value
        UpdateAngelWingAppearance()
    end })
    CosmeticsSection:Label({ Name = "Glow Color", Alignment = "Left" }):Colorpicker({ Name = "Glow Color", Flag = "Angel Wing Glow Color", Default = S.AngelWings.GlowColor, Callback = function(Value)
        S.AngelWings.GlowColor = Value
        UpdateAngelWingAppearance()
    end })
    CosmeticsSection:Slider({ Name = "Size", Flag = "Angel Wing Scale", Min = 0.85, Max = 1.70, Default = S.AngelWings.Scale, Decimals = 0.05, Callback = function(Value)
        S.AngelWings.Scale = Value
        RebuildAngelWings()
    end })
    CosmeticsSection:Slider({ Name = "Height", Flag = "Angel Wing Height", Min = -1, Max = 0.5, Default = S.AngelWings.HeightOffset, Decimals = 0.05, Callback = function(Value)
        S.AngelWings.HeightOffset = Value
        RebuildAngelWings()
    end })
    CosmeticsSection:Slider({ Name = "Back Offset", Flag = "Angel Wing Back Offset", Min = 0.20, Max = 1.40, Default = S.AngelWings.BackOffset, Decimals = 0.05, Callback = function(Value)
        S.AngelWings.BackOffset = Value
        RebuildAngelWings()
    end })
    CosmeticsSection:Slider({ Name = "Alpha", Flag = "Angel Wing Transparency", Min = 0, Max = 0.90, Default = S.AngelWings.Transparency, Decimals = 0.02, Callback = function(Value)
        S.AngelWings.Transparency = Value
        UpdateAngelWingAppearance()
    end })
    CosmeticsSection:Toggle({ Name = "China Hat", Flag = "China Hat", Default = S.ChinaHat.Enabled, Callback = function(Value)
        ToggleChinaHat(Value)
    end }):Colorpicker({ Name = "Hat Color", Flag = "China Hat Color", Default = S.ChinaHat.Color, Callback = function(Value)
        S.ChinaHat.Color = Value
        UpdateChinaHatAppearance()
    end })
    CosmeticsSection:Toggle({ Name = "Rainbow", Flag = "China Hat Rainbow", Default = S.ChinaHat.Rainbow, Callback = function(Value)
        S.ChinaHat.Rainbow = Value
        UpdateChinaHatAppearance()
    end })
    CosmeticsSection:Slider({ Name = "Size", Flag = "China Hat Scale", Min = 0.75, Max = 1.55, Default = S.ChinaHat.Scale, Decimals = 0.05, Callback = function(Value)
        S.ChinaHat.Scale = Value
        RebuildChinaHat()
    end })
    CosmeticsSection:Slider({ Name = "Alpha", Flag = "China Hat Transparency", Min = 0, Max = 0.90, Default = S.ChinaHat.Transparency, Decimals = 0.02, Callback = function(Value)
        S.ChinaHat.Transparency = Value
        UpdateChinaHatAppearance()
    end })
    local MoveSection = Movement:Section({ Name = "Movement", Side = 1 })
    MoveSection:Toggle({ Name = "Fly", Flag = "Fly", Default = FlyEnabled, Callback = function(Value)
        if Value then
            FlyEnable()
        else
            FlyDisable()
        end
    end }):Keybind({ Name = "Fly Bind", Flag = "Fly Bind", Default = "None", Mode = "Toggle", Callback = function()
    end })
    MoveSection:Dropdown({ Name = "Mode", Flag = "Fly Method", Default = FlyMethod, Items = { "Velocity", "Ragdoll" }, Callback = function(Value)
        FlyMethod = Value == "Bypass"
            and "Ragdoll"
            or Value

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
    end }):Keybind({ Name = "Noclip Bind", Flag = "Noclip Bind", Default = "None", Mode = "Toggle", Callback = function()
    end })
    MoveSection:Toggle({ Name = "Invisibility", Flag = "Invisibility", Default = InvisibilityEnabled, Callback = function(Value)
        if Value then
            InvisibilityEnable()
        else
            InvisibilityDisable()
        end
    end }):Keybind({ Name = "Invisibility Bind", Flag = "Invisibility Bind", Default = "None", Mode = "Toggle", Callback = function()
    end })
    MoveSection:Toggle({ Name = "Hide Head", Flag = "Hide Head", Default = HideHeadEnabled, Callback = function(Value)
        SetHideHeadEnabled(Value)
    end })
    MoveSection:Toggle({ Name = "Infinite Stamina", Flag = "Infinite Stamina", Default = InfStaminaEnabled, Callback = function(Value)
        if Value then
            InfStaminaEnable()
        else
            InfStaminaDisable()
        end
    end })
    MoveSection:Toggle({ Name = "Bunny Hop", Flag = "Bunny Hop", Default = BunnyHopEnabled, Callback = function(Value)
        BunnyHopEnabled = Value == true
        UpdateMovementAssistConnection()
    end })
    MoveSection:Toggle({ Name = "Auto Strafe", Flag = "Auto Strafe", Default = AutoStrafeEnabled, Callback = function(Value)
        AutoStrafeEnabled = Value == true
        UpdateMovementAssistConnection()
    end })
    MoveSection:Toggle({ Name = "Air Control", Flag = "Air Control", Default = AirControlEnabled, Callback = function(Value)
        AirControlEnabled = Value == true
        UpdateMovementAssistConnection()
    end })
    MoveSection:Slider({ Name = "Air Control", Flag = "Air Control Strength", Min = 0, Max = 100, Default = MovementAssistSettings.AirControlStrength * 100, Decimals = 1, Suffix = "%", Callback = function(Value)
        MovementAssistSettings.AirControlStrength = math.clamp((tonumber(Value) or 50) / 100, 0, 1)
    end })
    MoveSection:Slider({ Name = "Strafe", Flag = "Strafe Strength", Min = 0, Max = 100, Default = MovementAssistSettings.StrafeStrength * 100, Decimals = 1, Suffix = "%", Callback = function(Value)
        MovementAssistSettings.StrafeStrength = math.clamp((tonumber(Value) or 70) / 100, 0, 1)
    end })
    MoveSection:Slider({ Name = "Air Speed", Flag = "Maximum Air Speed", Min = 16, Max = 50, Default = MovementAssistSettings.MaxAirSpeed, Decimals = 1, Suffix = " studs/s", Callback = function(Value)
        MovementAssistSettings.MaxAirSpeed = math.clamp(tonumber(Value) or 32, 16, 50)
    end })
    MoveSection:Label({ Name = "Max 3 jumps per second", Alignment = "Left" })
    local CameraSection = Movement:Section({ Name = "Camera", Side = 2 })
    CameraSection:Toggle({ Name = "Third Person", Flag = "Third Person", Default = S.ThirdPerson.Enabled, Callback = function(Value)
        ToggleThirdPerson(Value)
    end }):Keybind({ Name = "Third Person Bind", Flag = "Third Person Bind", Default = "None", Mode = "Toggle", Callback = function()
    end })
    CameraSection:Slider({ Name = "Distance", Flag = "Third Person Distance", Min = 3, Max = 24, Default = S.ThirdPerson.Distance, Decimals = 0.5, Suffix = " studs", Callback = function(Value)
        S.ThirdPerson.Distance = math.clamp(tonumber(Value) or 8, 3, 24)
        if S.ThirdPerson.Enabled then UpdateThirdPerson() end
    end })
    CameraSection:Slider({ Name = "Shoulder", Flag = "Third Person Shoulder", Min = -4, Max = 4, Default = S.ThirdPerson.Shoulder, Decimals = 0.05, Callback = function(Value)
        S.ThirdPerson.Shoulder = tonumber(Value) or 0
        if S.ThirdPerson.Enabled then UpdateThirdPerson() end
    end })
    CameraSection:Slider({ Name = "Height", Flag = "Third Person Height", Min = -2, Max = 4, Default = S.ThirdPerson.Height, Decimals = 0.05, Callback = function(Value)
        S.ThirdPerson.Height = tonumber(Value) or 0
        if S.ThirdPerson.Enabled then UpdateThirdPerson() end
    end })
    CameraSection:Toggle({ Name = "Freecam", Flag = "Freecam", Default = S.Freecam.Enabled, Callback = function(Value)
        ToggleFreecam(Value)
    end }):Keybind({ Name = "Freecam Bind", Flag = "Freecam Bind", Default = "None", Mode = "Toggle", Callback = function()
    end })
    CameraSection:Slider({ Name = "Speed", Flag = "Freecam Speed", Min = 5, Max = 250, Default = S.Freecam.Speed, Decimals = 1, Callback = function(Value)
        S.Freecam.Speed = Value
    end })
    CameraSection:Slider({ Name = "Sensitivity", Flag = "Freecam Sensitivity", Min = 0.05, Max = 0.60, Default = S.Freecam.Sensitivity, Decimals = 0.01, Callback = function(Value)
        S.Freecam.Sensitivity = Value
    end })
    CameraSection:Label({ Name = "RMB: look · WASD: move · Q/E: vertical", Alignment = "Left" })
    local LocationSection = Movement:Section({ Name = "Positions", Side = 2 })
    LocationSection:Toggle({ Name = "Cube", Flag = "Save Cube", Default = SafeLocationController:IsEnabled("Cube"), Callback = function(Value)
        SafeLocationController:SetEnabled("Cube", Value)
    end })
    LocationSection:Toggle({ Name = "Vibe", Flag = "Save Vibe", Default = SafeLocationController:IsEnabled("Vibe"), Callback = function(Value)
        SafeLocationController:SetEnabled("Vibe", Value)
    end })
    LocationSection:Toggle({ Name = "Mount", Flag = "Save Mount", Default = SafeLocationController:IsEnabled("Mount"), Callback = function(Value)
        SafeLocationController:SetEnabled("Mount", Value)
    end })
    local SurvivalSection = Movement:Section({ Name = "Survival", Side = 1 })
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
    local InteractionSection = Utility:Section({ Name = "Interaction", Side = 1 })
    InteractionSection:Toggle({ Name = "No-Fail Lockpick", Flag = "No Fail Lockpick", Default = NoFailLockpickEnabled, Callback = function(Value)
        if Value then
            NoFailLockpickEnable()
        else
            NoFailLockpickDisable()
        end
    end })
    InteractionSection:Toggle({ Name = "Open Doors", Flag = "Open Nearby Doors", Default = OpenNearbyDoorsEnabled, Callback = function(Value)
        if Value then
            OpenNearbyDoorsEnable()
        else
            OpenNearbyDoorsDisable()
        end
    end })
    InteractionSection:Toggle({ Name = "Unlock Doors", Flag = "Unlock Nearby Doors", Default = UnlockNearbyDoorsEnabled, Callback = function(Value)
        if Value then
            UnlockNearbyDoorsEnable()
        else
            UnlockNearbyDoorsDisable()
        end
    end })
    local ServerSafetySection = Utility:Section({ Name = "Server", Side = 2 })
    ServerSafetySection:Toggle({ Name = "Staff Check", Flag = "Admin Detection", Default = RadiantFarmModule.Settings.AdminCheck, Callback = function(Value)
        RadiantFarmModule.SetSetting("AdminCheck", Value == true)
    end })
    ServerSafetySection:Toggle({ Name = "Auto Rejoin", Flag = "Reconnect On Error", Default = RadiantFarmModule.Settings.AntiRejoin, Callback = function(Value)
        RadiantFarmModule.SetSetting("AntiRejoin", Value == true)
    end })
    local InterfaceSection = Settings:Section({ Name = "Interface", Side = 2 })
    InterfaceSection:Dropdown({ Name = "Preset", Flag = "Theme Preset", Default = "Radiant Emerald", Items = { "Radiant Emerald", "Deep Emerald", "Matrix" }, Callback = function(Value)
        ApplyThemePreset(Value)

        if VisualState
            and VisualState.Widgets
        then
            VisualState.Widgets.LastTarget = nil
            VisualState.Widgets.LastMode = nil
            VisualState.Widgets.LastInfo = nil
            VisualState.Widgets.LastInventorySignature = nil
        end
    end })
    for Index, Value in pairs(Library.Theme) do
        local ThemeIndex = Index
        local ThemeValue = Value
        InterfaceSection:Label({ Name = ThemeIndex, Alignment = "Left" }):Colorpicker({ Name = ThemeIndex, Default = ThemeValue, Flag = "Theme " .. ThemeIndex, Callback = function(Color)
            Library.Theme[ThemeIndex] = Color
            Library:ChangeTheme(ThemeIndex, Color)
        end })
    end
    InterfaceSection:Label({ Name = "Menu Bind", Alignment = "Left" }):Keybind({ Name = "Menu Bind", Flag = "Menu Keybind", Default = Enum.KeyCode.Delete, Mode = "Toggle", Callback = function()
        Library.MenuKeybind = Library.Flags["Menu Keybind"].Key
    end })
    InterfaceSection:Toggle({ Name = "Watermark", Flag = "Watermark", Default = true, Callback = function(Value) Watermark:SetVisibility(Value) end })
    InterfaceSection:Toggle({ Name = "Keybinds", Flag = "Keybind List", Default = false, Callback = function(Value) KeybindList:SetVisibility(Value) end })
    InterfaceSection:Button({ Name = "Unload", Callback = function()
        if RadiantRuntimeUnloaded then return end
        RadiantRuntimeUnloaded = true

        local function SafeCall(Function, ...)
            if type(Function) ~= "function" then return end
            local Arguments = table.pack(...)
            pcall(function()
                Function(table.unpack(Arguments, 1, Arguments.n))
            end)
        end

        local function DisconnectField(Container, Field)
            if type(Container) ~= "table" then return end
            local Connection = Container[Field]
            if typeof(Connection) == "RBXScriptConnection" then
                pcall(function() Connection:Disconnect() end)
            end
            Container[Field] = nil
        end

        pcall(function()
            local Holder = Library and Library.Holder
            local Instance = Holder and (Holder.Instance or Holder)
            if typeof(Instance) == "Instance" and Instance:IsA("ScreenGui") then
                Instance.Enabled = false
            end
        end)

        RageBotEnabled = false
        AimbotEnabled = false
        SafeFarmEnabled = false
        AltFarmEnabled = false
        AutoRespawnEnabled = false
        NoFallDamageEnabled = false
        AntiAFKEnabled = false
        FlyEnabled = false
        NoclipEnabled = false
        InvisibilityEnabled = false
        HideHeadEnabled = false
        InfStaminaEnabled = false
        BunnyHopEnabled = false
        AutoStrafeEnabled = false
        AirControlEnabled = false
        OpenNearbyDoorsEnabled = false
        UnlockNearbyDoorsEnabled = false
        NoFailLockpickEnabled = false
        ArmsChamsEnabled = false
        WeaponChamsEnabled = false
        FullBrightEnabled = false

        if RespawnSafetyState then
            RespawnSafetyState.Generation += 1
            RespawnSafetyState.Suspended = true
            RespawnSafetyState.Preserved = nil
            RespawnSafetyState.RespawnRequestedFor = nil
            DisconnectField(RespawnSafetyState, "RemovingConnection")
            DisconnectField(RespawnSafetyState, "AddedConnection")
            DisconnectField(RespawnSafetyState, "DiedConnection")
        end

        DisconnectField(S, "CharacterAddedConnection")

        if WeaponInstantReloadState then
            WeaponInstantReloadState.Busy = false
            SafeCall(DisconnectWeaponInstantReloadRuntime)
        end

        if typeof(RageBotFOVConnection) == "RBXScriptConnection" then
            pcall(function() RageBotFOVConnection:Disconnect() end)
            RageBotFOVConnection = nil
        end

        SafeCall(function()
            if RageBotAPI and type(RageBotAPI.Disable) == "function" then
                RageBotAPI.Disable()
            end
        end)
        SafeCall(ToggleAimBot, false)
        SafeCall(DisableSilentAimController)
        SafeCall(DisableNoRecoil)
        SafeCall(SetBulletTracerShotHookEnabled, false)

        SafeCall(function()
            if not RadiantFarmModule then return end
            if type(RadiantFarmModule.SetSetting) == "function" then
                local SettingsToDisable = {
                    "AutoPlay",
                    "AutoMoney",
                    "AutoDeposit",
                    "AutoAllowance",
                    "AutoRespawn",
                    "AntiFallDamage",
                    "AntiAFK",
                    "AdminCheck",
                    "AntiRejoin",
                    "HideBody"
                }
                for _, Setting in ipairs(SettingsToDisable) do
                    RadiantFarmModule.SetSetting(Setting, false)
                end
            end
            if type(RadiantFarmModule.Stop) == "function" then
                RadiantFarmModule.Stop()
            end
        end)

        SafeCall(AutoRespawnDisable)
        SafeCall(NoFallDamageDisable)
        SafeCall(AntiAFKDisable)
        SafeCall(FlyDisable)
        SafeCall(NoclipDisable)
        SafeCall(InvisibilityDisable)
        SafeCall(ShutdownHideHeadController)
        SafeCall(CrowbarAuraDisable)
        SafeCall(MeleeAuraDisable)
        SafeCall(FinishAuraDisable)
        SafeCall(InfStaminaDisable)
        SafeCall(DisableMovementAssist)
        SafeCall(OpenNearbyDoorsDisable)
        SafeCall(UnlockNearbyDoorsDisable)
        SafeCall(NoFailLockpickDisable)
        SafeCall(DisableThirdPerson)
        SafeCall(DisableFreecam)
        SafeCall(ToggleBlur, false)
        SafeCall(FullBrightDisable)
        SafeCall(ToggleAngelWings, false)
        SafeCall(ToggleChinaHat, false)

        SafeCall(function()
            if ArmsChamsEnabled or ArmsChamsSettings.Connection then
                ArmsChamsDisable()
            else
                RestoreArmsChams()
            end
        end)

        SafeCall(function()
            if WeaponChamsEnabled
                or WeaponChamsSettings.Connection
                or WeaponChamsSettings.RenderName
            then
                WeaponChamsDisable()
            else
                RestoreWeaponChams()
            end
        end)

        SafeCall(ClearBulletTracers)
        SafeCall(RestoreRageShotSounds)
        SafeCall(DestroyHitFeedbackRuntime)
        SafeCall(DestroyWorldEffects)
        SafeCall(DestroyVisualEngine)
        SafeCall(RestoreWorldVisuals)
        SafeCall(ClearRespawnTransientState)
        SafeCall(DestroyRadiantVisualWidgets)

        SafeCall(function()
            if SafeLocationController
                and type(SafeLocationController.DisableAll) == "function"
            then
                SafeLocationController:DisableAll()
            end
        end)

        SafeCall(function()
            if Watermark and type(Watermark.Destroy) == "function" then
                Watermark:Destroy()
            end
        end)

        SafeCall(function()
            if KeybindList and type(KeybindList.Destroy) == "function" then
                KeybindList:Destroy()
            elseif KeybindList and type(KeybindList.SetVisibility) == "function" then
                KeybindList:SetVisibility(false)
            end
        end)

        if ResolverState then
            ResolverState.History = setmetatable({}, { __mode = "k" })
            ResolverState.PoseHistory = setmetatable({}, { __mode = "k" })
            ResolverState.SkeletonCache = setmetatable({}, { __mode = "k" })
        end

        SafeCall(function()
            if Library and type(Library.Unload) == "function" then
                Library:Unload()
            end
        end)

        collectgarbage("collect")
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
    ProfilesSection:Button({ Name = "Create", Callback = function()
        local FileName = NormalizeConfigName(ConfigName)
        if not FileName then return end
        local Path = Library.Folders.Configs .. "/" .. FileName
        writefile(Path, Library:GetConfig())
        Library:RefreshConfigsList(ConfigsListbox)
    end })
    ProfilesSection:Button({ Name = "Load", Callback = function()
        if not ConfigSelected then return end
        local Path = Library.Folders.Configs .. "/" .. ConfigSelected
        if isfile(Path) then Library:LoadConfig(readfile(Path)) end
    end })
    ProfilesSection:Button({ Name = "Save", Callback = function()
        if not ConfigSelected then return end
        local Path = Library.Folders.Configs .. "/" .. ConfigSelected
        writefile(Path, Library:GetConfig())
        Library:Notification("Saved " .. ConfigSelected, 3, Library.Theme.Accent)
    end })
    ProfilesSection:Button({ Name = "Delete", Callback = function()
        if not ConfigSelected then return end
        local Path = Library.Folders.Configs .. "/" .. ConfigSelected
        if isfile(Path) then delfile(Path) end
        ConfigSelected = nil
        Library:RefreshConfigsList(ConfigsListbox)
    end })
    ProfilesSection:Button({ Name = "Refresh", Callback = function() Library:RefreshConfigsList(ConfigsListbox) end })
    Library:RefreshConfigsList(ConfigsListbox)
    Library:Notification("radiant.rip loaded", 4, Library.Theme.Accent)
end

BuildRadiantMenu()
if S.CharacterAddedConnection then S.CharacterAddedConnection:Disconnect() end
if RespawnSafetyState.RemovingConnection then RespawnSafetyState.RemovingConnection:Disconnect() end
RespawnSafetyState.RemovingConnection = LocalPlayer.CharacterRemoving:Connect(function(Character)
    ClearRespawnTransientState(Character)
end)
S.CharacterAddedConnection = LocalPlayer.CharacterAdded:Connect(function(Character)
    RespawnSafetyState.Generation += 1
    local Generation = RespawnSafetyState.Generation
    local Preserved = RespawnSafetyState.Preserved or {}
    RespawnSafetyState.Suspended = true
    RespawnSafetyState.CurrentCharacter = Character
    RespawnSafetyState.RespawnRequestedFor = nil
    BindRespawnSafety(Character)
    task.spawn(function()
        local Humanoid = Character:WaitForChild("Humanoid", 8)
        local RootPart = Character:WaitForChild("HumanoidRootPart", 8)
        if not Humanoid or not RootPart then return end
        local StartedAt = os.clock()
        while Generation == RespawnSafetyState.Generation and Character == LocalPlayer.Character and (not Character:IsDescendantOf(workspace) or Humanoid.Health <= 0) and os.clock() - StartedAt < 8 do task.wait(0.1) end
        task.wait(0.8)
        if Generation ~= RespawnSafetyState.Generation or Character ~= LocalPlayer.Character or Humanoid.Health <= 0 then return end
        RespawnSafetyState.Suspended = false
        RespawnSafetyState.Preserved = nil
        if FullBrightEnabled then
            pcall(function()
                if FullBrightLight then
                    FullBrightLight:Destroy()
                    FullBrightLight = nil
                end
                FullBrightApply()
            end)
        end
        if S.ChinaHat.Enabled then pcall(function() CreateChinaHat(Character) end) end
        if S.AngelWings.Enabled then pcall(function() RebuildAngelWings() end) end
        if Preserved.World and WorldEffectsState.Enabled then pcall(StartWorldEffects) end
        task.wait(0.15)
        if Generation ~= RespawnSafetyState.Generation then return end
        if Preserved.Arms then pcall(ArmsChamsEnable) end
        if Preserved.Weapon then pcall(WeaponChamsEnable) end
        if Preserved.Bunny or Preserved.Strafe or Preserved.Air then
            BunnyHopEnabled = Preserved.Bunny == true
            AutoStrafeEnabled = Preserved.Strafe == true
            AirControlEnabled = Preserved.Air == true
            pcall(UpdateMovementAssistConnection)
        end
        task.wait(0.35)
        if Generation ~= RespawnSafetyState.Generation then return end
        if Preserved.Noclip then pcall(NoclipEnable) end
        if Preserved.Fly then pcall(FlyEnable) end
        if Preserved.Invis then pcall(InvisibilityEnable) end
        task.wait(0.35)
        if Generation ~= RespawnSafetyState.Generation then return end
        if Preserved.Stamina then pcall(InfStaminaEnable) end
        if Preserved.NoFall then pcall(NoFallDamageEnable) end
        if Preserved.Rage then pcall(function() RageBotAPI.Enable() end) end
    end)
end)
if LocalPlayer.Character then
    RespawnSafetyState.Suspended = false
    BindRespawnSafety(LocalPlayer.Character)
end
