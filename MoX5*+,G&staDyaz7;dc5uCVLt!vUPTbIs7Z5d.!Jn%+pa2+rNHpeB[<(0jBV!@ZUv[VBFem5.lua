if _G.NightfallDrawings then
    for _, drawingObj in pairs(_G.NightfallDrawings) do
        pcall(function() drawingObj:Remove() end)
    end
end
_G.NightfallDrawings = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local PlayersService = game:GetService("Players")
local WorkspaceService = game:GetService("Workspace")
local StatsService = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = PlayersService.LocalPlayer or PlayersService.PlayerAdded:Wait()
local FastMax = math.max
local FastFloor = math.floor
local FastClock = os.clock

local LibInstance = loadstring(game:HttpGet("https://raw.githubusercontent.com/neaxusxgod-png/INS-ui/main/uilib.lua"))()
if type(LibInstance) ~= "table" then LibInstance = INSui end

LibInstance:ApplyThemePreset("Indigo")

local WinApp = LibInstance:CreateWindow({
    title = "Nightfall | Recode",
    subtitle = "credits to inspecttor for ui",
    size = Vector2.new(700, 552),
    configName = "nightfall",
    menuKey = "RightShift",
    badge = "v2"
})

local ConfigState = {
    AutoParry = false,
    PanicSpam = false,
    TrainingBallsSupport = false,
    AutoSpam = false,
    SpamRate = 200,
    SpamSensitivity = 1.0,
    TriggerBot = false,
    DontClickOnSpawn = true,
    TriggerDelay = 0,
    ParryVisualizer = false,
    InfinityDetection = false,
    SlashesOfFuryDetection = false,
    ParryMethod = "Click",
    Headless = false,
    Korblox = false,
    InfinityDisabled = false,
    FuryTriggered = false
}

local RuntimeState = {
    TargetSpeed = 0,
    TargetDistance = 0,
    TargetDot = 0,
    ParryRange = 10
}

local Offsets = {
    Transparency = 0xF0,
    Parent = 0x70,
    DecalTexture = 0x198
}

local function WriteFloat(addr, val)
    if addr and addr ~= 0 then
        pcall(memory_write, "float", addr, val)
    end
end

local function WritePointer(addr, val)
    if addr and addr ~= 0 then
        if not pcall(memory_write, "uint64", addr, val) then
            pcall(memory_write, "pointer", addr, val)
        end
    end
end

local CombatTab = WinApp:Tab("Combat", "swords")

local ParrySection = CombatTab:Section("Auto Parry", "Left")
ParrySection:Toggle("Auto Parry", false, function(valueIn) ConfigState.AutoParry = valueIn end):AddKeybind("None", "Toggle")
ParrySection:Toggle("Panic Spam", false, function(valueIn) ConfigState.PanicSpam = valueIn end)
ParrySection:Dropdown("Parry Method", {"Click"}, {"Click", "Key"}, false, function(valueIn) ConfigState.ParryMethod = valueIn end)
ParrySection:Toggle("Training Balls", false, function(valueIn) ConfigState.TrainingBallsSupport = valueIn end)

local SpamSection = CombatTab:Section("Auto Spam", "Right")
SpamSection:Toggle("Auto Spam", false, function(valueIn) ConfigState.AutoSpam = valueIn end):AddKeybind("None", "Toggle")
SpamSection:Slider("Spam Rate", 200, 10, 10, 500, "cps", function(valueIn) ConfigState.SpamRate = valueIn end)
SpamSection:Slider("Spam Sensitivity", 1.0, 0.1, 0.1, 2.0, "", function(valueIn) ConfigState.SpamSensitivity = valueIn end)

local TriggerSection = CombatTab:Section("Trigger Bot", "Right")
TriggerSection:Toggle("Trigger Bot", false, function(valueIn) ConfigState.TriggerBot = valueIn end):AddKeybind("None", "Toggle")
TriggerSection:Toggle("Ignore Ball Spawn", true, function(valueIn) ConfigState.DontClickOnSpawn = valueIn end)
TriggerSection:Slider("Delay", 0, 1, 0, 100, "ms", function(valueIn) ConfigState.TriggerDelay = valueIn end)

local VisualsTab = WinApp:Tab("Visuals", "eye")

local VisMainSection = VisualsTab:Section("Visuals", "Left")
VisMainSection:Toggle("Range Visualiser", false, function(valueIn) ConfigState.ParryVisualizer = valueIn end)

local VisAvatarSection = VisualsTab:Section("Avatar Mods", "Right")

local function ApplyHeadless(state)
    local char = LocalPlayer.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if head then
        if state then
            pcall(function() head.Size = Vector3.new(0.01, 0.01, 0.01) end)
            if head.Address and head.Address ~= 0 then
                WriteFloat(head.Address + Offsets.Transparency, 1.0)
            end
            for _, child in ipairs(head:GetChildren()) do
                if child.ClassName == "Decal" or child.Name == "face" or child.Name == "Face" or child.ClassName:match("Mesh") then
                    pcall(function() child.Texture = "" end)
                    pcall(function() child.Transparency = 1 end)
                    pcall(function() child.Parent = nil end)
                    pcall(function() game:GetService("Debris"):AddItem(child, 0) end)
                    if child.Address and child.Address ~= 0 then
                        if child.ClassName == "Decal" or child.Name == "face" or child.Name == "Face" then
                            pcall(memory_write, "uint64", child.Address + Offsets.DecalTexture + 0x10, 0)
                        end
                        WritePointer(child.Address + Offsets.Parent, 0)
                    end
                end
            end
        else
            pcall(function() head.Size = Vector3.new(1.2, 1, 1.2) end)
        end
    end
end

local function ApplyKorblox(state)
    local char = LocalPlayer.Character
    if not char then return end
    local rightLegNames = {
        RightUpperLeg = true,
        RightLowerLeg = true,
        RightFoot = true,
        ["Right Leg"] = true
    }
    if state then
        for _, part in ipairs(char:GetChildren()) do
            if rightLegNames[part.Name] then
                pcall(function() part.Size = Vector3.new(0.01, 0.01, 0.01) end)
                if part.Address and part.Address ~= 0 then
                    WriteFloat(part.Address + Offsets.Transparency, 1.0)
                end
                for _, child in ipairs(part:GetChildren()) do
                    if child.ClassName:match("Mesh") or child.ClassName == "Decal" or child.ClassName == "Texture" then
                        pcall(function() child.Texture = "" end)
                        pcall(function() child.Transparency = 1 end)
                        pcall(function() child.Parent = nil end)
                        pcall(function() game:GetService("Debris"):AddItem(child, 0) end)
                        if child.Address and child.Address ~= 0 then
                            WritePointer(child.Address + Offsets.Parent, 0)
                        end
                    end
                end
            elseif part.ClassName == "CharacterMesh" then
                pcall(function()
                    if tostring(part.BodyPart):match("RightLeg") then
                        if part.Address and part.Address ~= 0 then
                            WritePointer(part.Address + Offsets.Parent, 0)
                        end
                    end
                end)
            elseif part.ClassName == "Accessory" then
                pcall(function()
                    local handle = part:FindFirstChild("Handle")
                    if handle then
                        local weld = handle:FindFirstChildOfClass("Weld") or handle:FindFirstChildOfClass("Motor6D")
                        if weld and weld.Part1 and rightLegNames[weld.Part1.Name] then
                            if part.Address and part.Address ~= 0 then
                                WritePointer(part.Address + Offsets.Parent, 0)
                            end
                        end
                    end
                end)
            end
        end
    else
        for _, part in ipairs(char:GetChildren()) do
            if rightLegNames[part.Name] then
                pcall(function() part.Size = Vector3.new(1, 1, 1) end)
            end
        end
    end
end

VisAvatarSection:Toggle("Headless", false, function(valueIn) 
    ConfigState.Headless = valueIn 
    ApplyHeadless(valueIn)
end)

VisAvatarSection:Toggle("Korblox", false, function(valueIn) 
    ConfigState.Korblox = valueIn 
    ApplyKorblox(valueIn)
end)

local DetectionsTab = WinApp:Tab("Detections", "shield")
local DetMainSection = DetectionsTab:Section("Detections", "Left")
DetMainSection:Toggle("Infinity Detection", false, function(valueIn) ConfigState.InfinityDetection = valueIn end)
DetMainSection:Toggle("Slashes of Fury Detection", false, function(valueIn) ConfigState.SlashesOfFuryDetection = valueIn end)

WinApp:AddSettingsTab("cog")

local VisualsData = {
    SphereLines = {}
}

if type(Drawing) == "table" and Drawing.new then
    for iIdx = 1, 40 do
        pcall(function()
            local lineObj = Drawing.new("Line")
            lineObj.Thickness = 2
            lineObj.Visible = false
            VisualsData.SphereLines[iIdx] = lineObj
            table.insert(_G.NightfallDrawings, lineObj)
        end)
    end
end

local SmoothParryRadius = 10

local function GetScreenPosition(worldPos)
    if type(WorldToScreen) == "function" then
        local screenPos, isVisible = WorldToScreen(worldPos)
        return screenPos, isVisible
    end
    
    local cameraObject = WorkspaceService.CurrentCamera
    if not cameraObject then return Vector2.new(0, 0), false end
    
    local success, p2d = pcall(function() return cameraObject:WorldToViewportPoint(worldPos) end)
    if success and p2d then
        return Vector2.new(p2d.X, p2d.Y), p2d.Z > 0
    end
    
    return Vector2.new(0, 0), false
end

local function GetRealBall()
    if ConfigState.TrainingBallsSupport then
        local trainingFolder = WorkspaceService:FindFirstChild("TrainingBalls")
        if trainingFolder then
            for _, currentBall in ipairs(trainingFolder:GetChildren()) do
                if currentBall:IsA("BasePart") and currentBall:GetAttribute("realBall") == true then
                    return currentBall
                end
            end
            for _, currentBall in ipairs(trainingFolder:GetChildren()) do
                if currentBall:IsA("BasePart") then
                    return currentBall
                end
            end
        end
    end

    local aliveFolder = WorkspaceService:FindFirstChild("Alive")
    local targetFolder = (aliveFolder and aliveFolder:FindFirstChild(LocalPlayer.Name)) and WorkspaceService:FindFirstChild("Balls") or WorkspaceService:FindFirstChild("TrainingBalls")
    
    if not targetFolder then
        targetFolder = WorkspaceService:FindFirstChild("Balls")
    end

    if targetFolder then
        for _, currentBall in ipairs(targetFolder:GetChildren()) do
            if currentBall:IsA("BasePart") and currentBall:GetAttribute("realBall") == true then
                return currentBall
            end
        end
        for _, currentBall in ipairs(targetFolder:GetChildren()) do
            if currentBall:IsA("BasePart") then
                return currentBall
            end
        end
    end
    return nil
end

local function GetMemoryPing()
    local successState, pingResult = pcall(function()
        return memory_read("double", StatsService.Network.ServerStatsItem["Data Ping"].Address + 0xC8)
    end)
    return successState and pingResult or 50
end

local function CheckIsTarget(targetName)
    local characterInstance = LocalPlayer.Character
    if characterInstance and characterInstance:FindFirstChild('Highlight') then return true end
    
    if not targetName then return false end
    local myName = string.lower(LocalPlayer.Name or "")
    local myDisplay = string.lower(LocalPlayer.DisplayName or LocalPlayer.Name or "")
    local tgtStr = string.lower(tostring(targetName))
    
    if tgtStr == myName or tgtStr == myDisplay then return true end
    
    local cleanTarget = string.gsub(tgtStr, '%.%.%.$', '')
    if #cleanTarget >= 3 then
        if string.sub(myName, 1, #cleanTarget) == cleanTarget or string.sub(myDisplay, 1, #cleanTarget) == cleanTarget then return true end
        if string.find(myName, cleanTarget, 1, true) or string.find(myDisplay, cleanTarget, 1, true) then return true end
    end
    return false
end

local function ExecuteParry()
    if type(mouse1click) == "function" then
        mouse1click()
    else
        pcall(function()
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end)
    end
end

local function ScanForNearestEntity(playerPosition)
    local nearestEntity = nil
    local minimumDistance = math.huge
    for _, targetPlayer in ipairs(PlayersService:GetPlayers()) do
        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
            local rootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart") or targetPlayer.Character.PrimaryPart
            local humanoidPart = targetPlayer.Character:FindFirstChild("Humanoid")
            if rootPart and humanoidPart and humanoidPart.Health > 0 then
                local currentDistance = (playerPosition - rootPart.Position).Magnitude
                if currentDistance < minimumDistance then
                    minimumDistance = currentDistance
                    nearestEntity = targetPlayer
                end
            end
        end
    end
    return nearestEntity, minimumDistance
end

local ConfigurationSpam = {
    SpamMinDistanceSpeedDivisor = 6.5,
    SpamMaxSpeedDivisor = 5.0,
    SpamMinDistance = 95.0,
    SpamMaxDistance = 30.0,
    SpamThreshold = 5
}

local function CheckIsSpam(spamParams)
    local scaledPing = spamParams.Ping / 10
    local baseRange = scaledPing + math.min(spamParams.Speed / ConfigurationSpam.SpamMinDistanceSpeedDivisor, ConfigurationSpam.SpamMinDistance)
    local rangeVal = baseRange * ConfigState.SpamSensitivity
    
    if spamParams.EntityDistance > rangeVal then return false, spamParams.Parries end
    if spamParams.BallDistance > rangeVal then return false, spamParams.Parries end
    
    local maximumSpeed = ConfigurationSpam.SpamMaxSpeedDivisor - math.min(spamParams.Speed / ConfigurationSpam.SpamMaxSpeedDivisor, ConfigurationSpam.SpamMaxSpeedDivisor)
    local maximumDot = math.clamp(spamParams.Dot, -1, 0) * maximumSpeed
    local accuracyVal = math.min(rangeVal - maximumDot, ConfigurationSpam.SpamMaxDistance) * ConfigState.SpamSensitivity
    
    if spamParams.BallDistance > accuracyVal then return false, spamParams.Parries end
    if spamParams.Parries < ConfigurationSpam.SpamThreshold then return false, spamParams.Parries end
    
    return true, spamParams.Parries
end

local IsParried = false
local SpeedDivisorFactor = 1.1
local EffectiveDivisor = 1.05
local BaseExtrapolationFrames = 2.5
local ParryRange = 10
local AeroActive = false
local AeroStartTime = 0
local LastSpeed = 0
local LastBallInstance = nil
local LastDistance = 9999
local MinTbDelay = 1 
local MaxTbDelay = 50
local ScheduledTriggerTime = 0
local CooldownEndTime = 0 
local AccumulatedSpamTime = 0
local PanicAccumulatedTime = 0
local BallParries = 0
local LastFromChange = 0
local CachedFrom = nil

local LastTickTime = FastClock()
local SmoothedServerFps = 60
local CachedCharacter = nil

RunService.RenderStepped:Connect(function(deltaTime)
    deltaTime = deltaTime or 0.016

    if ConfigState.ParryVisualizer and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        if rootPart and rootPart.Parent then
            local rootPos = rootPart.Position - Vector3.new(0, 3, 0)
            local targetRadius = RuntimeState.ParryRange or 10
            SmoothParryRadius = SmoothParryRadius + (targetRadius - SmoothParryRadius) * math.clamp(deltaTime * 15, 0, 1)
            
            local radiusVal = math.max(SmoothParryRadius, 5)
            local segmentsCount = 40
            local angleStep = (math.pi * 2) / segmentsCount
            
            for iIdx = 1, segmentsCount do
                local lineObj = VisualsData.SphereLines[iIdx]
                if lineObj then
                    local angle1 = (iIdx - 1) * angleStep
                    local angle2 = iIdx * angleStep
                    
                    local p13d = rootPos + Vector3.new(math.cos(angle1) * radiusVal, 0, math.sin(angle1) * radiusVal)
                    local p23d = rootPos + Vector3.new(math.cos(angle2) * radiusVal, 0, math.sin(angle2) * radiusVal)
                    
                    local p1Pos, onScreen1 = GetScreenPosition(p13d)
                    local p2Pos, onScreen2 = GetScreenPosition(p23d)
                    
                    if onScreen1 and onScreen2 then
                        lineObj.Visible = true
                        lineObj.From = p1Pos
                        lineObj.To = p2Pos
                        lineObj.Color = Color3.fromRGB(122, 134, 255)
                    else
                        lineObj.Visible = false
                    end
                end
            end
        end
    else
        for iIdx = 1, 40 do 
            local lineObj = VisualsData.SphereLines[iIdx]
            if lineObj then
                lineObj.Visible = false 
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(deltaTime)
    local currentTime = FastClock()
    local tickDelta = currentTime - LastTickTime
    LastTickTime = currentTime

    local currentChar = LocalPlayer.Character
    if currentChar and currentChar ~= CachedCharacter then
        CachedCharacter = currentChar
        if ConfigState.Headless then ApplyHeadless(true) end
        if ConfigState.Korblox then ApplyKorblox(true) end
    end

    if tickDelta > 0 then
        SmoothedServerFps = SmoothedServerFps + ((1 / tickDelta) - SmoothedServerFps) * 0.1
    end

    local lagCompensationFactor = math.clamp(math.pow(60 / math.max(SmoothedServerFps, 10), 1.15), 1, 3.5)
    local currentDeltaTime = deltaTime or 0.016

    if ConfigState.InfinityDetection then
        local isDetected = false
        local runtimeFolder = WorkspaceService:FindFirstChild("Runtime")
        if runtimeFolder then
            if runtimeFolder:FindFirstChild("InfinityFX") or runtimeFolder:FindFirstChild("TrueInfinityFX") then
                isDetected = true
            end
        end
        local currentBallsFolder = WorkspaceService:FindFirstChild("Balls")
        if currentBallsFolder then
            for _, currentBall in ipairs(currentBallsFolder:GetChildren()) do
                if typeof(currentBall) == "Instance" and currentBall:IsA("BasePart") then
                    local bodyPart = currentBall:FindFirstChild("Body")
                    if bodyPart and bodyPart:FindFirstChild("WEMAZOOKIEGO") then
                        isDetected = true
                        break
                    end
                end
            end
        end
        if LocalPlayer.Character then
            if LocalPlayer.Character:FindFirstChild("Parry") then
                isDetected = true
            end
        end
        if isDetected then
            if ConfigState.AutoParry then
                ConfigState.AutoParry = false
                ConfigState.InfinityDisabled = true
            end
        else
            if ConfigState.InfinityDisabled then
                ConfigState.AutoParry = true
                ConfigState.InfinityDisabled = false
            end
        end
    end

    if ConfigState.SlashesOfFuryDetection then
        local isFury = false
        local currentBallsFolder = WorkspaceService:FindFirstChild("Balls")
        if currentBallsFolder then
            for _, currentBall in ipairs(currentBallsFolder:GetChildren()) do
                if currentBall:FindFirstChild("ComboCounter") then
                    isFury = true
                    break
                end
            end
        end
        if not isFury and LocalPlayer.Character then
            if LocalPlayer.Character:GetAttribute("FuryCatch") == true then
                isFury = true
            end
        end
        if not isFury then
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                local furyTimer = playerGui:FindFirstChild("FuryTimer")
                if furyTimer and furyTimer.Enabled then
                    isFury = true
                end
            end
        end
        if not isFury then
            for _, currentPlr in ipairs(PlayersService:GetPlayers()) do
                if currentPlr.Character and currentPlr.Character:FindFirstChild("FuryHighlight") then
                    isFury = true
                    break
                end
            end
        end
        if isFury and not ConfigState.FuryTriggered then
            ConfigState.FuryTriggered = true
            task.spawn(function()
                while ConfigState.SlashesOfFuryDetection do
                    local stillFury = false
                    local currentCombo = 0
                    local currentBalls = WorkspaceService:FindFirstChild("Balls")
                    if currentBalls then
                        for _, currentBall in ipairs(currentBalls:GetChildren()) do
                            local comboObj = currentBall:FindFirstChild("ComboCounter")
                            if comboObj then
                                stillFury = true
                                local textLabel = comboObj:FindFirstChild("TextLabel")
                                if textLabel then
                                    currentCombo = tonumber(textLabel.Text) or 0
                                end
                                break
                            end
                        end
                    end
                    if not stillFury and LocalPlayer.Character then
                        if LocalPlayer.Character:GetAttribute("FuryCatch") == true then
                            stillFury = true
                        end
                    end
                    if not stillFury then
                        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                        if playerGui then
                            local furyTimer = playerGui:FindFirstChild("FuryTimer")
                            if furyTimer and furyTimer.Enabled then
                                stillFury = true
                            end
                        end
                    end
                    if not stillFury then
                        for _, currentPlr in ipairs(PlayersService:GetPlayers()) do
                            if currentPlr.Character and currentPlr.Character:FindFirstChild("FuryHighlight") then
                                stillFury = true
                                break
                            end
                        end
                    end
                    if not stillFury or currentCombo >= 34 then
                        break
                    end
                    ExecuteParry()
                    task.wait(0.15)
                end
                ConfigState.FuryTriggered = false
            end)
        end
        if not isFury then
            ConfigState.FuryTriggered = false
        end
    end

    local realBall = GetRealBall()

    if not realBall or not realBall.Parent then
        if (currentTime - LastFromChange) > 0.5 then
            CachedFrom = nil
            BallParries = 0
        end
        IsParried = false
        AeroActive = false
        LastSpeed = 0
        LastBallInstance = nil
        LastDistance = 9999
        AccumulatedSpamTime = 0
        PanicAccumulatedTime = 0
        RuntimeState.TargetSpeed = 0
        RuntimeState.TargetDistance = 0
        RuntimeState.TargetDot = 0
        RuntimeState.ParryRange = 10
        return
    end

    if realBall ~= LastBallInstance then
        LastBallInstance = realBall
        LastDistance = 9999
        AccumulatedSpamTime = 0
        PanicAccumulatedTime = 0
    end

    local playerCharacter = LocalPlayer.Character
    if not playerCharacter or not playerCharacter.PrimaryPart then return end

    local rootPart = playerCharacter.PrimaryPart
    if not rootPart or not rootPart.Parent then return end

    if playerCharacter:FindFirstChild("SingularityCape") or rootPart:FindFirstChild("SingularityCape") then
        IsParried = false
        AccumulatedSpamTime = 0
        PanicAccumulatedTime = 0
        return
    end

    local rootPosition = rootPart.Position
    if typeof(rootPosition) ~= "Vector3" then return end

    local ballPosition = realBall.Position
    if typeof(ballPosition) ~= "Vector3" then return end

    local deltaVector = rootPosition - ballPosition
    local currentDistance = deltaVector.Magnitude

    if currentDistance == 0 then return end

    local ballVelocity = realBall.AssemblyLinearVelocity
    if typeof(ballVelocity) ~= "Vector3" then ballVelocity = Vector3.new(0, 0, 0) end
    local currentSpeed = ballVelocity.Magnitude

    local velocityDir = ballVelocity.Magnitude > 0.01 and ballVelocity.Unit or Vector3.zero
    local directionToPlayerStat = deltaVector.Unit
    local dotProductStat = directionToPlayerStat:Dot(velocityDir)

    RuntimeState.TargetSpeed = currentSpeed
    RuntimeState.TargetDistance = currentDistance
    RuntimeState.TargetDot = dotProductStat

    currentSpeed = LastSpeed + (currentSpeed - LastSpeed) * 0.25

    if currentSpeed < 0.1 then
        LastSpeed = currentSpeed
        return
    end

    local aeroVisualEffect = realBall:FindFirstChild("AeroDynamicSlashVFX")
    local isAeroWait = false

    if aeroVisualEffect then
        if not AeroActive then
            AeroActive = true
            AeroStartTime = currentTime
        end
        if (currentTime - AeroStartTime) < 0.2 or ballVelocity.Y > 10 then
            isAeroWait = true
        end
    else
        AeroActive = false
    end

    if isAeroWait then
        LastSpeed = currentSpeed
        AccumulatedSpamTime = 0
        return
    end

    local currentFromAttr = realBall:GetAttribute("from") or realBall:GetAttribute("From")

    if currentFromAttr ~= nil and currentFromAttr ~= CachedFrom then
        local timeDifference = currentTime - LastFromChange
        if timeDifference <= 0.35 then
            BallParries = BallParries + 1
        else
            BallParries = 1
        end
        CachedFrom = currentFromAttr
        LastFromChange = currentTime
    end

    local currentTargetAttr = realBall:GetAttribute("target") or realBall:GetAttribute("Target")
    local networkPing = GetMemoryPing()
    local isTargetMe = CheckIsTarget(currentTargetAttr)

    local directionToPlayer = (rootPosition - ballPosition).Unit
    local trajectoryDotProduct = directionToPlayer:Dot(velocityDir)
    local nearestPlayer, distanceToNearestPlayer = ScanForNearestEntity(rootPosition)

    local spamParams = {
        Speed = currentSpeed,
        Parries = BallParries,
        BallDistance = currentDistance,
        EntityDistance = distanceToNearestPlayer,
        Dot = trajectoryDotProduct,
        Ping = networkPing
    }

    local autoSpamActive = false
    if ConfigState.AutoSpam then
        autoSpamActive, _ = CheckIsSpam(spamParams)
    end

    if autoSpamActive then
        local spamInterval = 1 / FastMax(ConfigState.SpamRate, 1)
        AccumulatedSpamTime = AccumulatedSpamTime + currentDeltaTime
        if AccumulatedSpamTime >= spamInterval then
            local clickCount = FastFloor(AccumulatedSpamTime / spamInterval)
            AccumulatedSpamTime = AccumulatedSpamTime % spamInterval
            for iIdx = 1, clickCount do
                ExecuteParry()
            end
        end
        IsParried = true
        LastSpeed = currentSpeed
        LastDistance = currentDistance
        return
    else
        AccumulatedSpamTime = 0
    end

    if ConfigState.PanicSpam then
        local targetCps = 200
        local spamInterval = 1 / targetCps
        local panicMaxDistance = 25
        local dangerZoneRadius = 15
        local closestEnemyDistance = math.huge
        local enemyLookDot = 0
        local aliveFolder = WorkspaceService:FindFirstChild("Alive")
        
        if aliveFolder then
            for _, obj in ipairs(aliveFolder:GetChildren()) do
                if obj ~= playerCharacter and obj.Name ~= LocalPlayer.Name then
                    local enemyHumanoid = obj:FindFirstChildWhichIsA("Humanoid")
                    local enemyRoot = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
                    if enemyHumanoid and enemyHumanoid.Health > 0 and enemyRoot then
                        local distToEnemy = (enemyRoot.Position - rootPosition).Magnitude
                        if distToEnemy < closestEnemyDistance then
                            closestEnemyDistance = distToEnemy
                            local directionToMe = (rootPosition - enemyRoot.Position).Unit
                            enemyLookDot = enemyRoot.CFrame.LookVector:Dot(directionToMe)
                        end
                    end
                end
            end
        end

        local isEnemyClose = closestEnemyDistance <= panicMaxDistance
        local ballDirection = ballVelocity.Magnitude > 0.01 and ballVelocity.Unit or Vector3.zero
        local ballDotToMe = ballDirection:Dot(directionToPlayer)

        local dynamicDotThreshold = math.max(0.40, (currentDistance / panicMaxDistance) * 0.75)
        local angleToPlayer = math.deg(math.acos(math.clamp(ballDotToMe, -1, 1)))
        local dynamicAngleThreshold = math.clamp(180 - (currentDistance * 2), 25, 75)

        local isHeadingTowards = (angleToPlayer <= dynamicAngleThreshold) or (ballDotToMe > dynamicDotThreshold)
        local isExtremelyClose = currentDistance <= dangerZoneRadius
        local isApproaching = currentDistance < LastDistance

        local isClash = isEnemyClose and currentSpeed > 35 and enemyLookDot > 0.55 and (isApproaching or isExtremelyClose) and (isHeadingTowards or isExtremelyClose)

        if isClash then
            PanicAccumulatedTime = PanicAccumulatedTime + currentDeltaTime
            if PanicAccumulatedTime >= spamInterval then
                local clickCount = math.floor(PanicAccumulatedTime / spamInterval)
                PanicAccumulatedTime = PanicAccumulatedTime - (clickCount * spamInterval)
                for iIdx = 1, math.min(clickCount, 15) do
                    ExecuteParry()
                end
            end
        else
            PanicAccumulatedTime = 0
        end
    end

    if ConfigState.TriggerBot then
        local applicationTick = FastClock()
        if applicationTick >= CooldownEndTime then
            if not (ConfigState.DontClickOnSpawn and BallParries == 0) then
                if isTargetMe then
                    if ScheduledTriggerTime == 0 then
                        local randomizedDelay = math.random(math.min(MinTbDelay, MaxTbDelay), math.max(MinTbDelay, MaxTbDelay)) / 1000
                        ScheduledTriggerTime = applicationTick + randomizedDelay
                    end
                else
                    ScheduledTriggerTime = 0
                end
                
                if isTargetMe and ScheduledTriggerTime > 0 then
                    if applicationTick >= ScheduledTriggerTime then
                        IsParried = true
                        ExecuteParry()
                        ScheduledTriggerTime = 0
                        CooldownEndTime = applicationTick + 0.4
                    end
                end
            else
                ScheduledTriggerTime = 0
            end
        end
    else
        ScheduledTriggerTime = 0
    end

    local speedDifference = math.max(currentSpeed - 9.5, 0)
    local speedDivisorBase = 2.4 + (math.log10(speedDifference + 1) * math.pow(speedDifference, 0.45) * 0.08)
    local speedDivisor = speedDivisorBase * SpeedDivisorFactor * EffectiveDivisor

    local exponentialDecayRate = math.max(30, math.pow(currentSpeed, 0.85))
    local distanceMultiplier = 1.0 + (math.exp(-currentDistance / exponentialDecayRate) * 1.8)

    local distancePerTick = currentSpeed * currentDeltaTime * lagCompensationFactor
    local dynamicFrames = (BaseExtrapolationFrames + (math.log10(currentSpeed + 10) * 0.6)) * lagCompensationFactor
    local frameDistanceCompensation = distancePerTick * dynamicFrames
    
    local finalThreshold = (math.max((currentSpeed / speedDivisor), ParryRange) + frameDistanceCompensation) * distanceMultiplier
    RuntimeState.ParryRange = finalThreshold

    if isTargetMe then
        if IsParried then
            LastSpeed = currentSpeed
            LastDistance = currentDistance
            return
        end
        
        local segmentVector = ballVelocity * currentDeltaTime * dynamicFrames
        local playerToBallVector = rootPosition - ballPosition
        local segmentLengthSquared = math.pow(segmentVector.X, 2) + math.pow(segmentVector.Y, 2) + math.pow(segmentVector.Z, 2)
        
        local tFactor = 0
        if segmentLengthSquared > 0 then
            tFactor = math.clamp(playerToBallVector:Dot(segmentVector) / segmentLengthSquared, 0, 1)
        end
        
        local closestPointOnLine = ballPosition + (segmentVector * tFactor)
        local distanceToLine = (rootPosition - closestPointOnLine).Magnitude

        local dotProduct = 0
        if currentDistance > 0.01 and currentSpeed > 0.01 then
            dotProduct = (deltaVector.Unit):Dot(velocityDir)
        end

        local isCurved = false
        local closeRangeThreshold = math.max(20, finalThreshold * 0.5)

        if currentSpeed > 10 and currentDistance > closeRangeThreshold then
            local dotThresholdBase = 0.82
            local distanceFactorCurved = math.pow(math.clamp((currentDistance - closeRangeThreshold) / 25, 0, 1), 1.5)
            local dotThreshold = dotThresholdBase * distanceFactorCurved

            if dotProduct < dotThreshold then
                isCurved = true
            end
        end

        local isMovingAway = currentDistance > LastDistance + 0.15

        if distanceToLine <= finalThreshold and not isCurved and not isMovingAway then
            if ConfigState.AutoParry then
                IsParried = true
                ExecuteParry()
            end
        end
    else
        IsParried = false
    end

    LastSpeed = currentSpeed
    LastDistance = currentDistance
end)

task.spawn(function()
    while true do
        if ConfigState.Headless then pcall(function() ApplyHeadless(true) end) end
        if ConfigState.Korblox then pcall(function() ApplyKorblox(true) end) end
        if task and task.wait then task.wait(1) else wait(1) end
    end
end)
