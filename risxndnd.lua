if _G.NightfallDrawings then
    for _, DrawingObj in pairs(_G.NightfallDrawings) do
        pcall(function() DrawingObj:Remove() end)
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
local V3Zero = Vector3.zero
local Pi2 = math.pi * 2

local Camera = WorkspaceService.CurrentCamera
if not Camera then
    Camera = WorkspaceService:WaitForChild("Camera")
end

local function WorldToScreen(WorldPos)
    if typeof(WorldPos) ~= "Vector3" or not Camera then
        return Vector2.new(), false
    end
    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(WorldPos)
    return Vector2.new(ScreenPos.X, ScreenPos.Y), OnScreen
end

local function LerpVector2(A, B, T)
    return Vector2.new(
        A.X + (B.X - A.X) * T,
        A.Y + (B.Y - A.Y) * T
    )
end

local LibInstance
local LoaderUrl = "https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.lua"
for Idx = 1, 10 do
    local CacheBuster = ""
    pcall(function() CacheBuster = "?cb=" .. tostring((math.floor((FastClock() or 1) * 1000) + Idx * 7919) % 2000000000) end)
    local OkStatus, ResData = pcall(function() return game:HttpGet(LoaderUrl .. CacheBuster) end)
    if OkStatus and type(ResData) == "string" and #ResData > 1000 and ResData:find("INSUI_FILE_END", 1, true) then
        local LoadedFunc = loadstring(ResData)
        if LoadedFunc then
            local OkEval, EvalRes = pcall(LoadedFunc)
            if OkEval and type(EvalRes) == "table" and type(EvalRes.CreateWindow) == "function" then
                LibInstance = EvalRes
                break
            end
            local PublicInst
            pcall(function() PublicInst = getgenv().INSui end)
            if type(PublicInst) == "table" and type(PublicInst.CreateWindow) == "function" then
                LibInstance = PublicInst
                break
            end
            pcall(function() PublicInst = _G.INSui end)
            if type(PublicInst) == "table" and type(PublicInst.CreateWindow) == "function" then
                LibInstance = PublicInst
                break
            end
            pcall(function() PublicInst = (shared or {}).INSui end)
            if type(PublicInst) == "table" and type(PublicInst.CreateWindow) == "function" then
                LibInstance = PublicInst
                break
            end
        end
    end
    task.wait(0.4)
end
if type(LibInstance) ~= "table" then return end

LibInstance:SetTheme("Default")

local WinApp = LibInstance:CreateWindow({
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
    Accuracy = 100,
    AutoParryType = "Default",
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

local OffsetsData = {
    Transparency = 0xF0,
    Parent = 0x70,
    DecalTexture = 0x198
}

local function WriteFloat(AddrVal, FloatVal)
    if AddrVal and AddrVal ~= 0 then
        pcall(memory_write, "float", AddrVal, FloatVal)
    end
end

local function WritePointer(AddrVal, PtrVal)
    if AddrVal and AddrVal ~= 0 then
        if not pcall(memory_write, "uint64", AddrVal, PtrVal) then
            pcall(memory_write, "pointer", AddrVal, PtrVal)
        end
    end
end

local function GenerateRandomAccuracy()
    local MinAcc = FastMin(ConfigState.RandomAccuracyMin, ConfigState.RandomAccuracyMax)
    local MaxAcc = FastMax(ConfigState.RandomAccuracyMin, ConfigState.RandomAccuracyMax)
    RuntimeState.GeneratedAccuracy = math.random(MinAcc, MaxAcc)
end

local CombatTab = WinApp:Tab("Combat", "swords")

local ParrySection = CombatTab:Section("Auto Parry", "Left", "")
ParrySection:Toggle("Auto Parry", false, function(Val) ConfigState.AutoParry = Val end):AddKeybind("None", "Toggle")
ParrySection:Slider("Accuracy", 100, 1, 1, 100, "%", function(Val) ConfigState.Accuracy = Val end)

local RandomAccToggle = ParrySection:Toggle("Random Accuracy", false, function(Val) ConfigState.RandomAccuracy = Val end)
ParrySection:RangeSlider("Random Parry Accuracy", 80, 100, 1, 1, 100, "%", function(MinVal, MaxVal)
    ConfigState.RandomAccuracyMin = MinVal
    ConfigState.RandomAccuracyMax = MaxVal
end):DependsOn(RandomAccToggle)

ParrySection:Dropdown("Auto Parry Type", {"Default"}, {"Default", "Geometric", "Quadratic"}, false, function(Val)
    ConfigState.AutoParryType = type(Val) == "table" and Val[1] or Val
end)

ParrySection:Toggle("Panic Spam", false, function(Val) ConfigState.PanicSpam = Val end)
ParrySection:Dropdown("Parry Method", {"Click"}, {"Click", "Key"}, false, function(Val)
    ConfigState.ParryMethod = type(Val) == "table" and Val[1] or Val
end)
ParrySection:Toggle("Training Balls", false, function(Val) ConfigState.TrainingBallsSupport = Val end)
ParrySection:Toggle("Orbit Ball", false, function(Val) ConfigState.OrbitBall = Val end):AddKeybind("None", "Toggle")
ParrySection:Slider("Orbit Radius", 25, 1, 5, 100, "", function(Val) ConfigState.OrbitRadius = Val end)
ParrySection:Slider("Orbit Speed", 50, 1, 10, 200, "", function(Val) ConfigState.OrbitSpeed = Val end)
ParrySection:Slider("Orbit Height", 5, 0.5, -30, 50, "", function(Val) ConfigState.OrbitHeight = Val end)

local SpamSection = CombatTab:Section("Auto Spam", "Right", "")
SpamSection:Toggle("Auto Spam", false, function(Val) ConfigState.AutoSpam = Val end):AddKeybind("None", "Toggle")
SpamSection:Toggle("Manual Spam", false, function(Val) ConfigState.ManualSpam = Val end):AddKeybind("None", "Toggle")
SpamSection:Slider("Spam Rate", 300, 100, 200, 3000, "cps", function(Val)
    ConfigState.SpamRate = Val
    local CalculatedInterval = 1 / FastMax(Val, 1)
    AutoSpamInterval = CalculatedInterval
    ManualSpamInterval = CalculatedInterval
    PanicSpamInterval = CalculatedInterval
end)
SpamSection:Slider("Spam Sensitivity", 3, 1, 1, 5, "", function(Val) ConfigState.SpamSensitivity = Val end)

local TriggerSection = CombatTab:Section("Trigger Bot", "Right", "")
TriggerSection:Toggle("Trigger Bot", false, function(Val) ConfigState.TriggerBot = Val end):AddKeybind("None", "Toggle")
TriggerSection:Slider("Delay", 0, 1, 0, 100, "ms", function(Val) ConfigState.TriggerDelay = Val end)
TriggerSection:Toggle("Ignore Ball Spawn", false, function(Val) ConfigState.TriggerIgnoreSpawn = Val end)

local VisualsTab = WinApp:Tab("Visuals", "eye")

local VisMainSection = VisualsTab:Section("Visuals", "Left", "")
VisMainSection:Toggle("Range Visualiser", false, function(Val) ConfigState.ParryVisualizer = Val end):AddColorpicker("Vis Color", Color3.fromRGB(220, 30, 30), function(ColorVal, AlphaVal) ConfigState.VisualizerColor = ColorVal end)
VisMainSection:Slider("Vis Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Val) ConfigState.VisThickness = Val end)
VisMainSection:Slider("Vis Transparency", 1.0, 0.1, 0.1, 1.0, "", function(Val) ConfigState.VisTransparency = Val end)
VisMainSection:Slider("Vis Segments", 40, 1, 10, 100, "", function(Val) ConfigState.VisSegments = Val end)

VisMainSection:Toggle("Ability ESP", false, function(Val) ConfigState.AbilityEsp = Val end):AddColorpicker("ESP Color", Color3.fromRGB(220, 30, 30), function(ColorVal, AlphaVal) ConfigState.EspColor = ColorVal end)
VisMainSection:Slider("ESP Text Size", 18, 1, 10, 40, "", function(Val) ConfigState.EspTextSize = Val end)
VisMainSection:Slider("ESP Offset Y", 2.0, 0.5, 0.0, 10.0, "", function(Val) ConfigState.EspOffsetY = Val end)

VisMainSection:Toggle("Rainbow Mode", false, function(Val) ConfigState.RainbowMode = Val end)

local VisTrailSection = VisualsTab:Section("Ball Trail", "Right", "")
VisTrailSection:Toggle("Enable Trail", false, function(Val) ConfigState.BallTrail = Val end):AddColorpicker("Trail Color", Color3.fromRGB(220, 30, 30), function(ColorVal, AlphaVal) ConfigState.TrailColor = ColorVal end)
VisTrailSection:Slider("Trail Length", 60, 1, 10, 100, "", function(Val) ConfigState.TrailLength = Val end)
VisTrailSection:Slider("Trail Thickness", 2.0, 0.1, 1.0, 10.0, "", function(Val) ConfigState.TrailThickness = Val end)

local VisAvatarSection = VisualsTab:Section("Avatar", "Right", "")

local function ApplyHeadless(StateVal)
    local CharObj = LocalPlayer.Character
    if not CharObj or typeof(CharObj) ~= "Instance" then return end
    local HeadObj = CharObj:FindFirstChild("Head")
    if HeadObj and typeof(HeadObj) == "Instance" and HeadObj:IsA("BasePart") then
        if StateVal then
            pcall(function() HeadObj.Size = Vector3.new(0.01, 0.01, 0.01) end)
            if HeadObj.Address and HeadObj.Address ~= 0 then
                WriteFloat(HeadObj.Address + OffsetsData.Transparency, 1.0)
            end
            for _, ChildObj in ipairs(HeadObj:GetChildren()) do
                if typeof(ChildObj) == "Instance" and (ChildObj.ClassName == "Decal" or ChildObj.Name == "face" or ChildObj.Name == "Face" or ChildObj.ClassName:match("Mesh")) then
                    pcall(function() ChildObj.Texture = "" end)
                    pcall(function() ChildObj.Transparency = 1 end)
                    pcall(function() ChildObj.Parent = nil end)
                    pcall(function() game:GetService("Debris"):AddItem(ChildObj, 0) end)
                    if ChildObj.Address and ChildObj.Address ~= 0 then
                        if ChildObj.ClassName == "Decal" or ChildObj.Name == "face" or ChildObj.Name == "Face" then
                            pcall(memory_write, "uint64", ChildObj.Address + OffsetsData.DecalTexture + 0x10, 0)
                        end
                        WritePointer(ChildObj.Address + OffsetsData.Parent, 0)
                    end
                end
            end
        else
            pcall(function() HeadObj.Size = Vector3.new(1.2, 1, 1.2) end)
        end
    end
end

local function ApplyKorblox(StateVal)
    local CharObj = LocalPlayer.Character
    if not CharObj or typeof(CharObj) ~= "Instance" then return end
    local RightLegNames = {
        RightUpperLeg = true,
        RightLowerLeg = true,
        RightFoot = true,
        ["Right Leg"] = true
    }
    if StateVal then
        for _, PartObj in ipairs(CharObj:GetChildren()) do
            if typeof(PartObj) == "Instance" and RightLegNames[PartObj.Name] and PartObj:IsA("BasePart") then
                pcall(function() PartObj.Size = Vector3.new(0.01, 0.01, 0.01) end)
                if PartObj.Address and PartObj.Address ~= 0 then
                    WriteFloat(PartObj.Address + OffsetsData.Transparency, 1.0)
                end
                for _, ChildObj in ipairs(PartObj:GetChildren()) do
                    if typeof(ChildObj) == "Instance" and (ChildObj.ClassName:match("Mesh") or ChildObj.ClassName == "Decal" or ChildObj.ClassName == "Texture") then
                        pcall(function() ChildObj.Texture = "" end)
                        pcall(function() ChildObj.Transparency = 1 end)
                        pcall(function() ChildObj.Parent = nil end)
                        pcall(function() game:GetService("Debris"):AddItem(ChildObj, 0) end)
                        if ChildObj.Address and ChildObj.Address ~= 0 then
                            WritePointer(ChildObj.Address + OffsetsData.Parent, 0)
                        end
                    end
                end
            elseif typeof(PartObj) == "Instance" and PartObj.ClassName == "CharacterMesh" then
                pcall(function()
                    if tostring(PartObj.BodyPart):match("RightLeg") then
                        if PartObj.Address and PartObj.Address ~= 0 then
                            WritePointer(PartObj.Address + OffsetsData.Parent, 0)
                        end
                    end
                end)
            elseif typeof(PartObj) == "Instance" and PartObj.ClassName == "Accessory" then
                pcall(function()
                    local HandleObj = PartObj:FindFirstChild("Handle")
                    if HandleObj and typeof(HandleObj) == "Instance" then
                        local WeldObj = HandleObj:FindFirstChildOfClass("Weld") or HandleObj:FindFirstChildOfClass("Motor6D")
                        if WeldObj and typeof(WeldObj) == "Instance" and WeldObj.Part1 and RightLegNames[WeldObj.Part1.Name] then
                            if PartObj.Address and PartObj.Address ~= 0 then
                                WritePointer(PartObj.Address + OffsetsData.Parent, 0)
                            end
                        end
                    end
                end)
            end
        end
    else
        for _, PartObj in ipairs(CharObj:GetChildren()) do
            if typeof(PartObj) == "Instance" and RightLegNames[PartObj.Name] and PartObj:IsA("BasePart") then
                pcall(function() PartObj.Size = Vector3.new(1, 1, 1) end)
            end
        end
    end
end

VisAvatarSection:Toggle("Headless", false, function(Val)
    ConfigState.Headless = Val
    ApplyHeadless(Val)
end)

VisAvatarSection:Toggle("Korblox", false, function(Val)
    ConfigState.Korblox = Val
    ApplyKorblox(Val)
end)

local DetectionsTab = WinApp:Tab("Detections", "shield")
local DetMainSection = DetectionsTab:Section("Detections", "Left", "")
DetMainSection:Toggle("Infinity Detection", false, function(Val) ConfigState.InfinityDetection = Val end)
DetMainSection:Toggle("Slashes of Fury Detection", false, function(Val) ConfigState.SlashesOfFuryDetection = Val end)

WinApp:AddSettingsTab("cog")

local VisualsData = {
    SphereLines = {},
    BallTrailPos = {},
    BallLines = {},
    EspTexts = {}
}

local MaxTrailLines = 100

local function CreateEspText()
    if not Drawing or not Drawing.new then return nil end
    local Success, TextObj = pcall(function() return Drawing.new("Text") end)
    if not Success or not TextObj then return nil end
    TextObj.Center = true
    TextObj.Outline = true
    TextObj.Font = 2
    TextObj.Visible = false
    table.insert(_G.NightfallDrawings, TextObj)
    return TextObj
end

if type(Drawing) == "table" and Drawing.new then
    for Idx = 1, 100 do
        pcall(function()
            local LineObj = Drawing.new("Line")
            if LineObj then
                LineObj.Visible = false
                VisualsData.SphereLines[Idx] = LineObj
                table.insert(_G.NightfallDrawings, LineObj)
            end
        end)
    end
    for Idx = 1, MaxTrailLines do
        pcall(function()
            local LineObj = Drawing.new("Line")
            if LineObj then
                LineObj.Visible = false
                VisualsData.BallLines[Idx] = LineObj
                table.insert(_G.NightfallDrawings, LineObj)
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
            if typeof(Ball) == "Instance" and Ball:IsA("BasePart") and Ball:GetAttribute("realBall") == true then return Ball end
        end
        for _, Ball in ipairs(TargetFolder:GetChildren()) do
            if typeof(Ball) == "Instance" and Ball:IsA("BasePart") then return Ball end
        end
    end
    return nil
end

local function GetMemoryPing()
    local SuccessState, PingResult = pcall(function()
        return memory_read("double", StatsService.Network.ServerStatsItem["Data Ping"].Address + 0xC8)
    end)
    return (SuccessState and type(PingResult) == "number") and PingResult or 50
end

local function CheckIsTarget(TargetName)
    if not LocalPlayer then return false end
    local CharacterInstance = LocalPlayer.Character
    if CharacterInstance and typeof(CharacterInstance) == "Instance" and CharacterInstance:FindFirstChild("Highlight") then return true end
    if not TargetName then return false end
    local MyName = string.lower(LocalPlayer.Name or "")
    local MyDisplay = string.lower(LocalPlayer.DisplayName or LocalPlayer.Name or "")
    local TgtStr = string.lower(tostring(TargetName))
    if TgtStr == MyName or TgtStr == MyDisplay then return true end
    local CleanTarget = string.gsub(TgtStr, "%.%.%.$", "")
    if #CleanTarget >= 3 then
        if string.sub(MyName, 1, #CleanTarget) == CleanTarget or string.sub(MyDisplay, 1, #CleanTarget) == CleanTarget then return true end
        if string.find(MyName, CleanTarget, 1, true) or string.find(MyDisplay, CleanTarget, 1, true) then return true end
    end
    return false
end

local function GetDistanceSquared(V1Pos, V2Pos)
    local DxVal = V1Pos.X - V2Pos.X
    local DyVal = V1Pos.Y - V2Pos.Y
    local DzVal = V1Pos.Z - V2Pos.Z
    return DxVal * DxVal + DyVal * DyVal + DzVal * DzVal
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

local SpamConfig = {
    SpamMinDistanceSpeedDivisor = 6.5,
    SpamMaxSpeedDivisor = 5.0,
    SpamMinDistance = 95.0,
    SpamMaxDistance = 30.0
}

local function CheckIsSpam(SpamParams)
    if SpamParams.IsMovingAway then return false, 0 end
    if SpamParams.Parries < ConfigState.SpamSensitivity then return false, SpamParams.Parries end

    local ScaledPing = SpamParams.Ping / 10
    local RangeVal = ScaledPing + FastMin(SpamParams.Speed / SpamConfig.SpamMinDistanceSpeedDivisor, SpamConfig.SpamMinDistance)

    local IsSnap = (SpamParams.Dot > 0.75) and (SpamParams.DotDelta > 0.15) and (SpamParams.BallDistance <= RangeVal * 1.75)
    if IsSnap then return true, SpamParams.Parries end

    if SpamParams.EntityDistance > RangeVal then return false, SpamParams.Parries end
    if SpamParams.BallDistance > RangeVal then return false, SpamParams.Parries end

    local MaximumDot = FastClamp(SpamParams.Dot, -1, 0)
    local AccuracyVal = FastMin(RangeVal - MaximumDot, SpamConfig.SpamMaxDistance)
    if SpamParams.BallDistance > AccuracyVal then return false, SpamParams.Parries end

    return true, SpamParams.Parries
end

local function GetTrailColorAndOpacity(OffsetVal, IndexVal, TotalVal)
    local AlphaVal = 1.0 - math.pow(IndexVal / TotalVal, 1.5)
    local OpacityVal = FastMax(AlphaVal * AlphaVal * AlphaVal, 0.05)
    if not ConfigState.RainbowMode then
        return ConfigState.TrailColor, OpacityVal
    end
    local TimeVal = FastClock() * 2.5 + OffsetVal + IndexVal * 0.1
    local RVal = (math.sin(TimeVal) * 0.5 + 0.5) * 0.95 + 0.05
    local GVal = (math.sin(TimeVal + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
    local BVal = (math.sin(TimeVal + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
    return Color3.new(RVal, GVal, BVal), OpacityVal
end

local function UpdateAndRenderTrail(CurrentBallPos)
    if not ConfigState.BallTrail then
        for _, LineObj in ipairs(VisualsData.BallLines) do
            if LineObj then LineObj.Visible = false end
        end
        return
    end
    if not CurrentBallPos or typeof(CurrentBallPos) ~= "Vector3" then
        for _, LineObj in ipairs(VisualsData.BallLines) do
            if LineObj then LineObj.Visible = false end
        end
        table.clear(VisualsData.BallTrailPos)
        return
    end

    local LastTrackedPos = VisualsData.BallTrailPos[1]
    if not LastTrackedPos or (LastTrackedPos - CurrentBallPos).Magnitude > 0.05 then
        table.insert(VisualsData.BallTrailPos, 1, CurrentBallPos)
        while #VisualsData.BallTrailPos > ConfigState.TrailLength do
            table.remove(VisualsData.BallTrailPos)
        end
    end

    local TotalPos = #VisualsData.BallTrailPos
    if TotalPos < 2 then
        for _, LineObj in ipairs(VisualsData.BallLines) do
            if LineObj then LineObj.Visible = false end
        end
        return
    end

    local BaseOffset = FastClock() * 1.5
    for Idx = 2, TotalPos do
        local LineObj = VisualsData.BallLines[Idx - 1]
        if not LineObj then break end

        local Pos1 = VisualsData.BallTrailPos[Idx - 1]
        local Pos2 = VisualsData.BallTrailPos[Idx]

        if Pos1 and Pos2 and typeof(Pos1) == "Vector3" and typeof(Pos2) == "Vector3" then
            local P1_2D, Vis1 = WorldToScreen(Pos1)
            local P2_2D, Vis2 = WorldToScreen(Pos2)

            if Vis1 and Vis2 then
                local ColorVal, OpacityVal = GetTrailColorAndOpacity(BaseOffset, Idx, TotalPos)
                LineObj.From = P1_2D
                LineObj.To = P2_2D
                LineObj.Color = ColorVal
                LineObj.Transparency = OpacityVal
                LineObj.Thickness = ConfigState.TrailThickness * (1.0 - math.pow(Idx / TotalPos, 1.5))
                LineObj.Visible = true
            else
                LineObj.Visible = false
            end
        else
            LineObj.Visible = false
        end
    end
    for Idx = TotalPos, #VisualsData.BallLines do
        local LineObj = VisualsData.BallLines[Idx]
        if LineObj then
            LineObj.Visible = false
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

local SmoothVisualRootPos = nil
local EspSmoothedPositions = {}
local CachedCharacter = nil
local CharacterFullyLoaded = false

RunService.RenderStepped:Connect(function(DeltaTime)
    if type(DeltaTime) ~= "number" then DeltaTime = 0.016 end
    local CurrentRenderTime = FastClock()

    local RealBallVisuals = GetRealBall()
    local CurrentBallPos = nil

    if RealBallVisuals and typeof(RealBallVisuals) == "Instance" and RealBallVisuals:IsA("BasePart") then
        CurrentBallPos = RealBallVisuals.Position
    end

    UpdateAndRenderTrail(CurrentBallPos)

    if ConfigState.AbilityEsp then
        local CurrentPlayersList = PlayersService:GetPlayers()
        for Idx = 1, #CurrentPlayersList do
            local TargetPlayer = CurrentPlayersList[Idx]
            if not TargetPlayer or typeof(TargetPlayer) ~= "Instance" or TargetPlayer == LocalPlayer then continue end

            local PlayerNameStr = TargetPlayer.Name
            local TargetCharacter = TargetPlayer.Character
            local TargetHumanoid = TargetCharacter and typeof(TargetCharacter) == "Instance" and TargetCharacter:FindFirstChildWhichIsA("Humanoid")
            local TargetHead = TargetCharacter and typeof(TargetCharacter) == "Instance" and TargetCharacter:FindFirstChild("Head")
            local TargetAbility = TargetPlayer:GetAttribute("CurrentlyEquippedAbility")

            if TargetHumanoid and TargetHumanoid.Health > 0 and TargetHead and typeof(TargetHead) == "Instance" and TargetHead:IsA("BasePart") and TargetAbility then
                local HeadPos = TargetHead.Position
                local CurrentOffsetVector = Vector3.new(0, ConfigState.EspOffsetY, 0)
                local Target3D = HeadPos + CurrentOffsetVector

                local ScreenCoords, IsOnScreen = WorldToScreen(Target3D)
                if IsOnScreen and ScreenCoords.X > 0 and ScreenCoords.Y > 0 then
                    local TextDrawing = VisualsData.EspTexts[PlayerNameStr]
                    if not TextDrawing then
                        TextDrawing = CreateEspText()
                        VisualsData.EspTexts[PlayerNameStr] = TextDrawing
                    end
                    if TextDrawing then
                        TextDrawing.Size = ConfigState.EspTextSize
                        local SmoothedPos = ScreenCoords
                        if EspSmoothedPositions[PlayerNameStr] then
                            local LerpAlpha = FastClamp(DeltaTime * 32, 0, 1)
                            SmoothedPos = LerpVector2(EspSmoothedPositions[PlayerNameStr], ScreenCoords, LerpAlpha)
                        end
                        EspSmoothedPositions[PlayerNameStr] = SmoothedPos
                        TextDrawing.Position = SmoothedPos
                        TextDrawing.Text = tostring(TargetAbility)
                        if ConfigState.RainbowMode then
                            local ColorR = (math.sin(CurrentRenderTime * 2.5) * 0.5 + 0.5) * 0.95 + 0.05
                            local ColorG = (math.sin(CurrentRenderTime * 2.5 + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                            local ColorB = (math.sin(CurrentRenderTime * 2.5 + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                            TextDrawing.Color = Color3.new(ColorR, ColorG, ColorB)
                        else
                            TextDrawing.Color = ConfigState.EspColor
                        end
                        TextDrawing.Visible = true
                    end
                else
                    local TextDrawing = VisualsData.EspTexts[PlayerNameStr]
                    if TextDrawing then TextDrawing.Visible = false end
                end
            else
                local TextDrawing = VisualsData.EspTexts[PlayerNameStr]
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

    local LocalChar = LocalPlayer.Character
    local RootPartVis = LocalChar and typeof(LocalChar) == "Instance" and LocalChar:FindFirstChild("HumanoidRootPart")
    if ConfigState.ParryVisualizer and RootPartVis and typeof(RootPartVis) == "Instance" and RootPartVis:IsA("BasePart") then
        local RootPosRaw = RootPartVis.Position - Vector3.new(0, 3, 0)
        if SmoothVisualRootPos == nil then
            SmoothVisualRootPos = RootPosRaw
        else
            local LerpAlpha = FastClamp(DeltaTime * 18, 0, 1)
            SmoothVisualRootPos = SmoothVisualRootPos:Lerp(RootPosRaw, LerpAlpha)
        end
        local RootPos = SmoothVisualRootPos
        local TargetRadius = RuntimeState.ParryRange or 15
        SmoothParryRadius = SmoothParryRadius + (TargetRadius - SmoothParryRadius) * FastClamp(DeltaTime * 20, 0, 1)
        local RadiusVal = FastMax(SmoothParryRadius, 5)
        local SegmentsCount = FastClamp(ConfigState.VisSegments, 10, 100)
        local AngleStep = Pi2 / SegmentsCount
        for Idx = 1, 100 do
            local LineObj = VisualsData.SphereLines[Idx]
            if LineObj then
                if Idx <= SegmentsCount then
                    local Angle1 = (Idx - 1) * AngleStep
                    local Angle2 = Idx * AngleStep
                    local P1_3d = RootPos + Vector3.new(math.cos(Angle1) * RadiusVal, 0, math.sin(Angle1) * RadiusVal)
                    local P2_3d = RootPos + Vector3.new(math.cos(Angle2) * RadiusVal, 0, math.sin(Angle2) * RadiusVal)

                    local P1_Pos, OnScreen1 = WorldToScreen(P1_3d)
                    local P2_Pos, OnScreen2 = WorldToScreen(P2_3d)

                    if OnScreen1 and OnScreen2 then
                        LineObj.Visible = true
                        LineObj.From = P1_Pos
                        LineObj.To = P2_Pos
                        LineObj.Thickness = ConfigState.VisThickness
                        LineObj.Transparency = ConfigState.VisTransparency
                        if ConfigState.RainbowMode then
                            local OffsetT = CurrentRenderTime * 2.5 + (Idx / SegmentsCount) * Pi2
                            local VisR = (math.sin(OffsetT) * 0.5 + 0.5) * 0.95 + 0.05
                            local VisG = (math.sin(OffsetT + 2.094) * 0.5 + 0.5) * 0.95 + 0.05
                            local VisB = (math.sin(OffsetT + 4.188) * 0.5 + 0.5) * 0.95 + 0.05
                            LineObj.Color = Color3.new(VisR, VisG, VisB)
                        else
                            LineObj.Color = ConfigState.VisualizerColor
                        end
                    else
                        LineObj.Visible = false
                    end
                else
                    LineObj.Visible = false
                end
            end
        end
    else
        for Idx = 1, 100 do
            local LineObj = VisualsData.SphereLines[Idx]
            if LineObj and LineObj.Visible then
                LineObj.Visible = false
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
    for _, ChildObj in ipairs(ChildrenList) do
        if typeof(ChildObj) == "Instance" and (ChildObj.Name == "Pull" or ChildObj.Name == "MaxPull") then
            PullTime = CurrentTime
            break
        end
    end

    local PlayerCharacterObj = LocalPlayer.Character

    if PlayerCharacterObj ~= CachedCharacter then
        CachedCharacter = PlayerCharacterObj
        CharacterFullyLoaded = false
    end

    if PlayerCharacterObj and typeof(PlayerCharacterObj) == "Instance" and not CharacterFullyLoaded then
        local HRP = PlayerCharacterObj:FindFirstChild("HumanoidRootPart")
        if HRP and typeof(HRP) == "Instance" then
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

    if PlayerCharacterObj and typeof(PlayerCharacterObj) == "Instance" and CharacterFullyLoaded then
        if ConfigState.Headless then
            local TargetHead = PlayerCharacterObj:FindFirstChild("Head")
            if TargetHead and typeof(TargetHead) == "Instance" and TargetHead:IsA("BasePart") and TargetHead.Size.X > 0.1 then
                pcall(function() ApplyHeadless(true) end)
            end
        end
        if ConfigState.Korblox then
            local TargetRightLeg = PlayerCharacterObj:FindFirstChild("RightUpperLeg") or PlayerCharacterObj:FindFirstChild("Right Leg")
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
                    local TargetAttr = CurrentBall:GetAttribute("target") or CurrentBall:GetAttribute("Target")
                    if CheckIsTarget(TargetAttr) then
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
                            local ComboObj = typeof(CurrentBall) == "Instance" and CurrentBall:FindFirstChild("ComboCounter")
                            if ComboObj and typeof(ComboObj) == "Instance" then
                                local TargetAttr = CurrentBall:GetAttribute("target") or CurrentBall:GetAttribute("Target")
                                if CheckIsTarget(TargetAttr) then
                                    StillFury = true
                                end
                                local TextLabel = ComboObj:FindFirstChild("TextLabel")
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
        return
    end

    if RealBall ~= LastBallInstance then
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

    local IsTKActive = false
    local BodyPart = RealBall:FindFirstChild("Body")
    if BodyPart and typeof(BodyPart) == "Instance" and BodyPart:FindFirstChild("At2") then
        IsTKActive = true
    end

    local IsPullActive = (CurrentTime - PullTime) <= 0.1

    if IsPullActive or IsTKActive then
        IsParried = false
        local TempVelocity = RealBall.AssemblyLinearVelocity
        LastSpeed = typeof(TempVelocity) == "Vector3" and TempVelocity.Magnitude or 0
        LastDistance = (RootPart.Position - RealBall.Position).Magnitude
        NextAutoClick = 0
        NextManualClick = 0
        NextPanicClick = 0
        ScheduledTriggerTime = 0
        return
    end

    local RootPosition = RootPart.Position
    local BallPosition = RealBall.Position
    local DeltaVector = RootPosition - BallPosition
    local CurrentDistance = DeltaVector.Magnitude

    if CurrentDistance == 0 then return end

    local BallVelocity = RealBall.AssemblyLinearVelocity
    if typeof(BallVelocity) ~= "Vector3" then BallVelocity = V3Zero end
    local CurrentSpeed = BallVelocity.Magnitude

    local ApproachSpeed = 0
    if LastDistance ~= 9999 then
        ApproachSpeed = FastMax((LastDistance - CurrentDistance) / CurrentDeltaTime, 0)
    end
    local EffectiveSpeed = FastMax(CurrentSpeed, ApproachSpeed)
    local SpeedDelta = FastMax(EffectiveSpeed - LastSpeed, 0)

    local VelocityDir = BallVelocity.Magnitude > 0.01 and BallVelocity.Unit or V3Zero
    local DirectionToPlayerStat = DeltaVector.Unit
    local DotProductStat = DirectionToPlayerStat:Dot(VelocityDir)

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

    local CurrentFromAttr = RealBall:GetAttribute("from") or RealBall:GetAttribute("From")
    if CurrentFromAttr ~= nil and CurrentFromAttr ~= CachedFrom then
        CachedFrom = CurrentFromAttr
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
        if CurrentTime >= NextManualClick then
            if ConfigState.ParryMethod == "Click" then
                if typeof(Mouse1Click) == "function" then Mouse1Click() end
            else
                if typeof(KeyPress) == "function" and typeof(KeyRelease) == "function" then KeyPress(0x46) KeyRelease(0x46) end
            end
            NextManualClick = CurrentTime + ManualSpamInterval
        end
    else
        NextManualClick = 0
    end

    local SpamParams = {
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
        AutoSpamActive, _ = CheckIsSpam(SpamParams)
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
            for _, ObjVal in ipairs(CachedAliveFolder:GetChildren()) do
                if typeof(ObjVal) == "Instance" and ObjVal ~= PlayerCharacter and ObjVal.Name ~= LocalPlayer.Name then
                    local EnemyHumanoid = ObjVal:FindFirstChildWhichIsA("Humanoid")
                    local EnemyRoot = ObjVal:FindFirstChild("HumanoidRootPart") or ObjVal.PrimaryPart
                    if EnemyHumanoid and typeof(EnemyHumanoid) == "Instance" and EnemyHumanoid.Health > 0 and EnemyRoot and typeof(EnemyRoot) == "Instance" and EnemyRoot:IsA("BasePart") then
                        local DistSq = GetDistanceSquared(EnemyRoot.Position, RootPosition)
                        if DistSq < ClosestEnemyDistanceSq then
                            ClosestEnemyDistanceSq = DistSq
                            local CFVal = EnemyRoot.CFrame
                            if CFVal then
                                local DirectionToMe = (RootPosition - EnemyRoot.Position).Unit
                                EnemyLookDot = CFVal.LookVector:Dot(DirectionToMe)
                            end
                        end
                    end
                end
            end
        end

        local ClosestEnemyDistance = FastSqrt(ClosestEnemyDistanceSq)
        local IsEnemyClose = ClosestEnemyDistance <= PanicMaxDistance
        local BallDirection = BallVelocity.Magnitude > 0.01 and BallVelocity.Unit or V3Zero
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
                local PingSec = NetworkPing / 1000
                local BallSpeedFactor = FastClamp(EffectiveSpeed / 70, 0.55, 1.5)
                local DeltaCompensation = CurrentDeltaTime * 1.8
                local TickCompensation = ServerTickRate * 1.5
                local SpeedCompensation = FastClamp(EffectiveSpeed / 100, 0, 0.025)
                local TotalCompensation = PingSec + DeltaCompensation + TickCompensation + SpeedCompensation
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

        local KpsIntensity = FastClamp(SmoothedKps, 0, 20) / 20
        local KpsMitigation = 1 - (KpsIntensity * 0.55)

        local AccuracyValue = ConfigState.Accuracy
        if ConfigState.RandomAccuracy then
            AccuracyValue = RuntimeState.GeneratedAccuracy
        end
        AccuracyValue = FastClamp(AccuracyValue, 1, 100)

        local AccuracyScale = (AccuracyValue - 1) / 99
        local AccuracyMultiplier = 0.7 + (AccuracyScale * 0.35)

        local DynamicScaling = FastMax(EffectiveSpeed - 9.5, 0) * 0.002
        local FinalSpeedDivisor = (2.4 + DynamicScaling) * AccuracyMultiplier

        local BaseExtrapolationFactor = 2.4 + DynamicScaling
        local FinalExtrapolationFactor = BaseExtrapolationFactor * AccuracyMultiplier

        local ExtrapolationDistance = EffectiveSpeed * CurrentDeltaTime * FinalExtrapolationFactor * KpsMitigation

        local BaseDistance = FastMax(EffectiveSpeed / FinalSpeedDivisor, 9.5)
        local LowAccuracyDelay = (1 - AccuracyScale) * 1.4

        local ParryType = ConfigState.AutoParryType or "Default"
        local UnifiedThreshold
        if ParryType == "Geometric" then
            local GeomFactor = FastMax(EffectiveSpeed / 38, 0.9) ^ 0.72
            UnifiedThreshold = (BaseDistance * GeomFactor) + (ExtrapolationDistance * 0.82) + (KpsIntensity * 1.35) - (LowAccuracyDelay * 0.6)
            UnifiedThreshold = FastMax(UnifiedThreshold, 8.0)
        elseif ParryType == "Quadratic" then
            local QuadSpeedTerm = (EffectiveSpeed * EffectiveSpeed) / 1350
            local QuadExtra = QuadSpeedTerm * AccuracyMultiplier * 0.9
            UnifiedThreshold = BaseDistance + ExtrapolationDistance + QuadExtra + (KpsIntensity * 1.65) - LowAccuracyDelay
            UnifiedThreshold = FastMax(UnifiedThreshold, 10.5)
        else
            UnifiedThreshold = BaseDistance + ExtrapolationDistance + (KpsIntensity * 1.5) - LowAccuracyDelay
            UnifiedThreshold = FastMax(UnifiedThreshold, 9.5)
        end

        RuntimeState.ParryRange = UnifiedThreshold

        local VelocityUnit = CurrentSpeed > 0 and VelocityDir or V3Zero
        local DirectionToPlayer = CurrentDistance > 0 and (RootPosition - BallPosition).Unit or V3Zero
        local DotProductParry = VelocityUnit:Dot(DirectionToPlayer)

        local CloseRangeThreshold = FastMax(20, UnifiedThreshold * 0.6)

        local IsCurved = false
        local DotDistanceThreshold = 35.0
        local DotLimitThreshold = 55.0

        if CurrentSpeed > 15 then
            local DistanceRatio = FastClamp((CurrentDistance - DotDistanceThreshold) / DotLimitThreshold, 0, 1)

            local MaxDotThreshold = 0.85 - (0.1 * (1 - AccuracyScale))
            local MinDotThreshold = 0.55 - (0.1 * (1 - AccuracyScale))

            local DynamicDot = MinDotThreshold + (MaxDotThreshold - MinDotThreshold) * math.pow(DistanceRatio, 1.5)

            local CurveCompensation = CurrentDeltaTime * FinalExtrapolationFactor * KpsMitigation
            local DotThreshold = DynamicDot - (CurveCompensation * 0.15)

            local CurveTolerance = 0.9 - (0.45 * (1 - AccuracyScale))

            if CurrentDistance > CloseRangeThreshold * CurveTolerance and DotProductParry < DotThreshold then
                IsCurved = true
            end
        end

        if CurrentDistance <= UnifiedThreshold and not IsMovingAway and not IsCurved then
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
    local RealBall = GetRealBall()
    if not RealBall or typeof(RealBall) ~= "Instance" or not RealBall:IsA("BasePart") or not RealBall.Parent then return end
    local Character = LocalPlayer.Character
    if not Character or typeof(Character) ~= "Instance" then return end
    local RootPart = Character.PrimaryPart
    if not RootPart or typeof(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") or not RootPart.Parent then
        RootPart = Character:FindFirstChild("HumanoidRootPart")
        if not RootPart or typeof(RootPart) ~= "Instance" or not RootPart:IsA("BasePart") or not RootPart.Parent then return end
    end
    local BallPosition = RealBall.Position
    local TimeValue = FastClock() * (ConfigState.OrbitSpeed / 10)
    local OrbitPosition = Vector3.new(
        BallPosition.X + math.cos(TimeValue) * ConfigState.OrbitRadius,
        BallPosition.Y + ConfigState.OrbitHeight,
        BallPosition.Z + math.sin(TimeValue) * ConfigState.OrbitRadius
    )
    local TargetCFrame = CFrame.lookAt(OrbitPosition, BallPosition)
    local LerpAlpha = math.clamp(DeltaTime * 22, 0, 0.35)
    pcall(function()
        RootPart.CFrame = RootPart.CFrame:Lerp(TargetCFrame, LerpAlpha)
    end)
end)
