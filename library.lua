local coreGuiService = game:GetService("CoreGui")
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local textService = game:GetService("TextService")
local httpService = game:GetService("HttpService")
local workspaceService = game:GetService("Workspace")
local playersService = game:GetService("Players")

local LibraryApi = {
    Flags = {},
    FolderName = "Moonshade",
    ConfigName = "AutoSaveConfig.json"
}

local colors = {
    mainBackground = Color3.new(0.035294, 0.035294, 0.050980),
    sidebarBackground = Color3.new(0.050980, 0.050980, 0.066666),
    sectionBackground = Color3.new(0.066666, 0.066666, 0.082352),
    elementBackground = Color3.new(0.090196, 0.090196, 0.105882),
    elementHoverBackground = Color3.new(0.121568, 0.121568, 0.145098),
    borderColor = Color3.new(0.105882, 0.105882, 0.133333),
    borderLightColor = Color3.new(0.172549, 0.172549, 0.211764),
    accentColor = Color3.new(0.423529, 0.576470, 0.988235),
    accentGradientColor1 = Color3.new(0.423529, 0.576470, 0.988235),
    accentGradientColor2 = Color3.new(0.619607, 0.462745, 0.988235),
    textWhiteColor = Color3.new(0.952941, 0.952941, 0.972549),
    textDarkColor = Color3.new(0.541176, 0.541176, 0.580392),
    tooltipBackground = Color3.new(0.043137, 0.043137, 0.058823),
    notificationInfoColor = Color3.new(0.247058, 0.635294, 0.980392),
    notificationSuccessColor = Color3.new(0.247058, 0.980392, 0.490196),
    notificationWarningColor = Color3.new(0.980392, 0.819607, 0.247058),
    notificationErrorColor = Color3.new(0.980392, 0.247058, 0.247058)
}

local mainFont = Enum.Font.GothamMedium
local boldFont = Enum.Font.GothamBold

local screenGui = Instance.new("ScreenGui")
screenGui.Name = httpService:GenerateGUID(false)
screenGui.Parent = coreGuiService
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true

local tooltipFrame = Instance.new("Frame")
tooltipFrame.BackgroundColor3 = colors.tooltipBackground
tooltipFrame.BackgroundTransparency = 0.158372
tooltipFrame.Size = UDim2.new(0, 0, 0, 24)
tooltipFrame.ZIndex = 2000
tooltipFrame.Visible = false
tooltipFrame.Parent = screenGui

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 4)
tooltipCorner.Parent = tooltipFrame

local tooltipStroke = Instance.new("UIStroke")
tooltipStroke.Color = colors.borderLightColor
tooltipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tooltipStroke.Transparency = 1
tooltipStroke.Parent = tooltipFrame

local tooltipText = Instance.new("TextLabel")
tooltipText.Size = UDim2.new(1, -16, 1, 0)
tooltipText.Position = UDim2.new(0, 8, 0, 0)
tooltipText.BackgroundTransparency = 1
tooltipText.TextColor3 = colors.textWhiteColor
tooltipText.TextTransparency = 1
tooltipText.TextSize = 12
tooltipText.Font = mainFont
tooltipText.TextXAlignment = Enum.TextXAlignment.Left
tooltipText.ZIndex = 2001
tooltipText.Parent = tooltipFrame

local notificationContainer = Instance.new("Frame")
notificationContainer.Size = UDim2.new(0, 300, 1, -40)
notificationContainer.Position = UDim2.new(1, -320, 0, 20)
notificationContainer.BackgroundTransparency = 1
notificationContainer.ZIndex = 1500
notificationContainer.Parent = screenGui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationLayout.Padding = UDim.new(0, 10)
notificationLayout.Parent = notificationContainer

local tooltipTargetText = ""

local function animateElement(element, properties, speed)
    local tween = tweenService:Create(element, TweenInfo.new(speed or 0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), properties)
    tween:Play()
    return tween
end

local function applyAcrylicEffect(parent, transparency, cornerRadius)
    local blurImage = Instance.new("ImageLabel")
    blurImage.Size = UDim2.new(1, 0, 1, 0)
    blurImage.BackgroundTransparency = 1
    blurImage.Image = "rbxassetid://8992230113"
    blurImage.TileSize = UDim2.new(0, 256, 0, 256)
    blurImage.ScaleType = Enum.ScaleType.Tile
    blurImage.ImageTransparency = transparency or 0.88732
    blurImage.ZIndex = parent.ZIndex - 1
    blurImage.Parent = parent
    if cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = cornerRadius
        corner.Parent = blurImage
    end
    return blurImage
end

local function showTooltip(textString)
    if not textString or textString == "" then
        tooltipTargetText = ""
        return
    end
    local textBounds = textService:GetTextSize(textString, 12, mainFont, Vector2.new(500, 24))
    tooltipFrame.Size = UDim2.new(0, textBounds.X + 16, 0, 24)
    tooltipText.Text = textString
    tooltipTargetText = textString
end

local function snapValue(value, step)
    if not step then return value end
    return math.floor((value / step) + 0.5) * step
end

local function formatValue(value, step)
    if step and step < 1 then
        local decimalPlaces = tostring(step):len() - 2
        return string.format("%."..decimalPlaces.."f", value)
    end
    return tostring(value)
end

local function saveConfiguration()
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(LibraryApi.FolderName) then
            makefolder(LibraryApi.FolderName)
        end
        local serializedData = {}
        for key, val in pairs(LibraryApi.Flags) do
            if typeof(val) == "Color3" then
                serializedData[key] = {Type = "Color3", R = val.R, G = val.G, B = val.B}
            elseif typeof(val) == "EnumItem" then
                serializedData[key] = {Type = "KeyCode", Name = val.Name}
            elseif type(val) == "table" and val.Min and val.Max then
                serializedData[key] = {Type = "Range", Min = val.Min, Max = val.Max}
            else
                serializedData[key] = val
            end
        end
        writefile(LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName, httpService:JSONEncode(serializedData))
    end)
end

local function loadConfiguration()
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local fullPath = LibraryApi.FolderName .. "/" .. LibraryApi.ConfigName
        if isfile(fullPath) then
            local decodedData = httpService:JSONDecode(readfile(fullPath))
            if type(decodedData) == "table" then
                for key, val in pairs(decodedData) do
                    if type(val) == "table" then
                        if val.Type == "Color3" then
                            LibraryApi.Flags[key] = Color3.new(val.R, val.G, val.B)
                        elseif val.Type == "KeyCode" then
                            LibraryApi.Flags[key] = Enum.KeyCode[val.Name] or Enum.KeyCode.Unknown
                        elseif val.Type == "Range" then
                            LibraryApi.Flags[key] = {Min = val.Min, Max = val.Max}
                        end
                    else
                        LibraryApi.Flags[key] = val
                    end
                end
            end
        end
    end)
end

loadConfiguration()

runService.RenderStepped:Connect(function()
    if tooltipTargetText ~= "" then
        local mouseLocation = userInputService:GetMouseLocation()
        tooltipFrame.Position = UDim2.new(0, mouseLocation.X + 15, 0, mouseLocation.Y + 15)
        if not tooltipFrame.Visible then
            tooltipFrame.Visible = true
            animateElement(tooltipFrame, {BackgroundTransparency = 0.1837265}, 0.25)
            animateElement(tooltipStroke, {Transparency = 0}, 0.25)
            animateElement(tooltipText, {TextTransparency = 0}, 0.25)
        end
    else
        animateElement(tooltipFrame, {BackgroundTransparency = 1}, 0.15)
        animateElement(tooltipStroke, {Transparency = 1}, 0.15)
        animateElement(tooltipText, {TextTransparency = 1}, 0.15)
        task.delay(0.15, function()
            if tooltipTargetText == "" then
                tooltipFrame.Visible = false
            end
        end)
    end
end)

function LibraryApi:Notify(config)
    local title = config.Title or "Notification"
    local text = config.Text or ""
    local duration = config.Duration or 3
    local notificationType = config.Type or "Info"
    local accentColor = colors["notification" .. notificationType .. "Color"] or colors.accentColor

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(1, 0, 0, 60)
    notificationFrame.Position = UDim2.new(1, 320, 0, 0)
    notificationFrame.BackgroundColor3 = colors.mainBackground
    notificationFrame.BackgroundTransparency = 0.28547
    notificationFrame.ZIndex = 1501
    notificationFrame.Parent = notificationContainer

    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 6)
    notificationCorner.Parent = notificationFrame

    local notificationStroke = Instance.new("UIStroke")
    notificationStroke.Color = colors.borderLightColor
    notificationStroke.Parent = notificationFrame

    applyAcrylicEffect(notificationFrame, 0.91238, UDim.new(0, 6))

    local lineFrame = Instance.new("Frame")
    lineFrame.Size = UDim2.new(0, 3, 1, -12)
    lineFrame.Position = UDim2.new(0, 6, 0, 6)
    lineFrame.BackgroundColor3 = accentColor
    lineFrame.BorderSizePixel = 0
    lineFrame.ZIndex = 1502
    lineFrame.Parent = notificationFrame

    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(0, 3)
    lineCorner.Parent = lineFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -24, 0, 16)
    titleLabel.Position = UDim2.new(0, 16, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.textWhiteColor
    titleLabel.TextSize = 13
    titleLabel.Font = boldFont
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 1502
    titleLabel.Parent = notificationFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -24, 0, 24)
    textLabel.Position = UDim2.new(0, 16, 0, 26)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = colors.textDarkColor
    textLabel.TextSize = 12
    textLabel.Font = mainFont
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.ZIndex = 1502
    textLabel.Parent = notificationFrame

    animateElement(notificationFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.45)

    task.delay(duration, function()
        local hideTween = animateElement(notificationFrame, {Position = UDim2.new(1, 320, 0, 0)}, 0.45)
        hideTween.Completed:Connect(function()
            notificationFrame:Destroy()
        end)
    end)
end

function LibraryApi:CreateWindow(windowName)
    local mainBackground = Instance.new("Frame")
    mainBackground.Size = UDim2.new(0, 720, 0, 480)
    mainBackground.Position = UDim2.new(0.5, -360, 0.5, -240)
    mainBackground.BackgroundColor3 = colors.mainBackground
    mainBackground.BackgroundTransparency = 0.18374
    mainBackground.BorderSizePixel = 0
    mainBackground.Active = true
    mainBackground.Parent = screenGui

    local uiScaleModifier = Instance.new("UIScale")
    uiScaleModifier.Parent = mainBackground
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainBackground
    
    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = colors.borderColor
    mainStroke.Parent = mainBackground

    applyAcrylicEffect(mainBackground, 0.88741, UDim.new(0, 6))

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36)
    topBar.BackgroundColor3 = colors.sidebarBackground
    topBar.BackgroundTransparency = 0.21847
    topBar.BorderSizePixel = 0
    topBar.Parent = mainBackground
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 6)
    topCorner.Parent = topBar

    local topHider = Instance.new("Frame")
    topHider.Size = UDim2.new(1, 0, 0, 6)
    topHider.Position = UDim2.new(0, 0, 1, -6)
    topHider.BackgroundColor3 = colors.sidebarBackground
    topHider.BackgroundTransparency = 0.21847
    topHider.BorderSizePixel = 0
    topHider.Parent = topBar

    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.BackgroundColor3 = Color3.new(1, 1, 1)
    accentLine.BorderSizePixel = 0
    accentLine.Parent = topBar
    
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 6)
    accentCorner.Parent = accentLine

    local accentGradient = Instance.new("UIGradient")
    accentGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, colors.accentGradientColor1),
        ColorSequenceKeypoint.new(1, colors.accentGradientColor2)
    }
    accentGradient.Parent = accentLine

    local topBorder = Instance.new("Frame")
    topBorder.Size = UDim2.new(1, 0, 0, 1)
    topBorder.Position = UDim2.new(0, 0, 1, 0)
    topBorder.BackgroundColor3 = colors.borderColor
    topBorder.BorderSizePixel = 0
    topBorder.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, -2)
    titleLabel.Position = UDim2.new(0, 15, 0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowName
    titleLabel.TextColor3 = colors.textWhiteColor
    titleLabel.TextSize = 13
    titleLabel.Font = boldFont
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Size = UDim2.new(0, 150, 1, -37)
    sidebarFrame.Position = UDim2.new(0, 0, 0, 37)
    sidebarFrame.BackgroundColor3 = colors.sidebarBackground
    sidebarFrame.BackgroundTransparency = 0.21847
    sidebarFrame.BorderSizePixel = 0
    sidebarFrame.Parent = mainBackground
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 6)
    sidebarCorner.Parent = sidebarFrame

    local sidebarHiderRight = Instance.new("Frame")
    sidebarHiderRight.Size = UDim2.new(0, 6, 1, 0)
    sidebarHiderRight.Position = UDim2.new(1, -6, 0, 0)
    sidebarHiderRight.BackgroundColor3 = colors.sidebarBackground
    sidebarHiderRight.BackgroundTransparency = 0.21847
    sidebarHiderRight.BorderSizePixel = 0
    sidebarHiderRight.Parent = sidebarFrame

    local sidebarHiderTop = Instance.new("Frame")
    sidebarHiderTop.Size = UDim2.new(1, 0, 0, 6)
    sidebarHiderTop.BackgroundColor3 = colors.sidebarBackground
    sidebarHiderTop.BackgroundTransparency = 0.21847
    sidebarHiderTop.BorderSizePixel = 0
    sidebarHiderTop.Parent = sidebarFrame

    local sidebarBorder = Instance.new("Frame")
    sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    sidebarBorder.Position = UDim2.new(1, 0, 0, 0)
    sidebarBorder.BackgroundColor3 = colors.borderColor
    sidebarBorder.BorderSizePixel = 0
    sidebarBorder.Parent = sidebarFrame

    local tabScrollingFrame = Instance.new("ScrollingFrame")
    tabScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
    tabScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    tabScrollingFrame.BackgroundTransparency = 1
    tabScrollingFrame.BorderSizePixel = 0
    tabScrollingFrame.ScrollBarThickness = 0
    tabScrollingFrame.Parent = sidebarFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabScrollingFrame

    local contentAreaFrame = Instance.new("Frame")
    contentAreaFrame.Size = UDim2.new(1, -151, 1, -37)
    contentAreaFrame.Position = UDim2.new(0, 151, 0, 37)
    contentAreaFrame.BackgroundTransparency = 1
    contentAreaFrame.Parent = mainBackground

    local mobileToggleButton = Instance.new("ImageButton")
    mobileToggleButton.Size = UDim2.new(0, 50, 0, 50)
    mobileToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
    mobileToggleButton.BackgroundColor3 = colors.mainBackground
    mobileToggleButton.BorderSizePixel = 0
    mobileToggleButton.ZIndex = 1000
    mobileToggleButton.Visible = userInputService.TouchEnabled
    mobileToggleButton.Parent = screenGui
    
    local success, avatarImage = pcall(function()
        return playersService:GetUserThumbnailAsync(playersService.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    mobileToggleButton.Image = success and avatarImage or ""

    local mobileToggleCorner = Instance.new("UICorner")
    mobileToggleCorner.CornerRadius = UDim.new(1, 0)
    mobileToggleCorner.Parent = mobileToggleButton

    local mobileToggleStroke = Instance.new("UIStroke")
    mobileToggleStroke.Color = colors.accentColor
    mobileToggleStroke.Thickness = 2
    mobileToggleStroke.Parent = mobileToggleButton

    local isToggleDragging = false
    local toggleDragInput = nil
    local toggleDragStart = nil
    local toggleStartPos = nil

    mobileToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isToggleDragging = true
            toggleDragStart = input.Position
            toggleStartPos = mobileToggleButton.Position
        end
    end)

    mobileToggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            toggleDragInput = input
        end
    end)

    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isToggleDragging = false
        end
    end)

    runService.RenderStepped:Connect(function()
        if isToggleDragging and toggleDragInput then
            local delta = toggleDragInput.Position - toggleDragStart
            mobileToggleButton.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
        end
    end)

    local toggleClickTime = 0
    mobileToggleButton.MouseButton1Down:Connect(function()
        toggleClickTime = tick()
        animateElement(mobileToggleButton, {Size = UDim2.new(0, 45, 0, 45)}, 0.25)
    end)
    
    mobileToggleButton.MouseButton1Up:Connect(function()
        animateElement(mobileToggleButton, {Size = UDim2.new(0, 50, 0, 50)}, 0.25)
        if tick() - toggleClickTime < 0.2 then
            mainBackground.Visible = not mainBackground.Visible
        end
    end)

    local function updateResponsiveScale()
        local vp = workspaceService.CurrentCamera.ViewportSize
        if vp.X < 1 or vp.Y < 1 then 
            uiScaleModifier.Scale = 1
            return
        end
        local scaleX = vp.X / 800
        local scaleY = vp.Y / 500
        local scale = math.min(scaleX, scaleY)
        if scale < 1 then
            uiScaleModifier.Scale = math.clamp(scale * 0.95, 0.4, 1)
        else
            uiScaleModifier.Scale = 1
        end
    end

    workspaceService.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateResponsiveScale)
    updateResponsiveScale()

    local isDragging = false
    local dragInput = nil
    local dragStart = nil
    local startPosition = nil
    local targetPosition = mainBackground.Position

    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isDragging = true
            dragStart = input.Position
            startPosition = mainBackground.Position
        end
    end)

    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then 
            dragInput = input 
        end
    end)

    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            isDragging = false 
        end
    end)

    runService.RenderStepped:Connect(function()
        if isDragging and dragInput then
            local delta = dragInput.Position - dragStart
            targetPosition = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + (delta.X / uiScaleModifier.Scale), startPosition.Y.Scale, startPosition.Y.Offset + (delta.Y / uiScaleModifier.Scale))
        end
        mainBackground.Position = mainBackground.Position:Lerp(targetPosition, 0.25)
    end)

    local windowContext = { Tabs = {}, Active_Tab = nil }

    function windowContext:Tab_Create(tabName, iconId)
        local tabData = {}

        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        tabButton.BackgroundColor3 = colors.elementHoverBackground
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        tabButton.Parent = tabScrollingFrame
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = tabButton

        local tabLabel = Instance.new("TextLabel")
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        tabLabel.TextColor3 = colors.textDarkColor
        tabLabel.TextSize = 12
        tabLabel.Font = mainFont
        tabLabel.TextXAlignment = Enum.TextXAlignment.Left
        tabLabel.Parent = tabButton

        if iconId and iconId ~= "" then
            local tabIcon = Instance.new("ImageLabel")
            tabIcon.Size = UDim2.new(0, 14, 0, 14)
            tabIcon.Position = UDim2.new(0, 12, 0.5, -7)
            tabIcon.BackgroundTransparency = 1
            tabIcon.Image = iconId
            tabIcon.ImageColor3 = colors.textDarkColor
            tabIcon.Parent = tabButton
            tabData.Icon = tabIcon
            tabLabel.Position = UDim2.new(0, 34, 0, 0)
            tabLabel.Size = UDim2.new(1, -44, 1, 0)
        else
            tabLabel.Position = UDim2.new(0, 12, 0, 0)
            tabLabel.Size = UDim2.new(1, -20, 1, 0)
        end

        local tabIndicator = Instance.new("Frame")
        tabIndicator.Size = UDim2.new(0, 2, 0, 0)
        tabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        tabIndicator.BackgroundColor3 = colors.accentColor
        tabIndicator.BorderSizePixel = 0
        tabIndicator.Parent = tabButton
        
        local indicatorCorner = Instance.new("UICorner")
        indicatorCorner.CornerRadius = UDim.new(0, 2)
        indicatorCorner.Parent = tabIndicator

        local pageScrollingFrame = Instance.new("ScrollingFrame")
        pageScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
        pageScrollingFrame.BackgroundTransparency = 1
        pageScrollingFrame.BorderSizePixel = 0
        pageScrollingFrame.ScrollBarThickness = 2
        pageScrollingFrame.ScrollBarImageColor3 = colors.accentColor
        pageScrollingFrame.Visible = false
        pageScrollingFrame.Parent = contentAreaFrame

        local leftColumnFrame = Instance.new("Frame")
        leftColumnFrame.Size = UDim2.new(0.5, -16, 1, 0)
        leftColumnFrame.Position = UDim2.new(0, 10, 0, 10)
        leftColumnFrame.BackgroundTransparency = 1
        leftColumnFrame.Parent = pageScrollingFrame

        local rightColumnFrame = Instance.new("Frame")
        rightColumnFrame.Size = UDim2.new(0.5, -16, 1, 0)
        rightColumnFrame.Position = UDim2.new(0.5, 6, 0, 10)
        rightColumnFrame.BackgroundTransparency = 1
        rightColumnFrame.Parent = pageScrollingFrame

        local leftColumnLayout = Instance.new("UIListLayout")
        leftColumnLayout.Padding = UDim.new(0, 10)
        leftColumnLayout.Parent = leftColumnFrame

        local rightColumnLayout = Instance.new("UIListLayout")
        rightColumnLayout.Padding = UDim.new(0, 10)
        rightColumnLayout.Parent = rightColumnFrame

        runService.RenderStepped:Connect(function()
            local maxColumnHeight = math.max(leftColumnLayout.AbsoluteContentSize.Y, rightColumnLayout.AbsoluteContentSize.Y)
            pageScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, maxColumnHeight + 20)
            tabScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
        end)

        function tabData:Activate()
            if windowContext.Active_Tab == tabData then return end
            if windowContext.Active_Tab then
                animateElement(windowContext.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.3)
                animateElement(windowContext.Active_Tab.Lbl, {TextColor3 = colors.textDarkColor}, 0.3)
                if windowContext.Active_Tab.Icon then animateElement(windowContext.Active_Tab.Icon, {ImageColor3 = colors.textDarkColor}, 0.3) end
                animateElement(windowContext.Active_Tab.Ind, {Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.3)
                windowContext.Active_Tab.Page.Visible = false
            end
            windowContext.Active_Tab = tabData
            pageScrollingFrame.Visible = true
            animateElement(tabButton, {BackgroundTransparency = 0.11847}, 0.3)
            animateElement(tabLabel, {TextColor3 = colors.textWhiteColor}, 0.3)
            if tabData.Icon then animateElement(tabData.Icon, {ImageColor3 = colors.accentColor}, 0.3) end
            animateElement(tabIndicator, {Size = UDim2.new(0, 2, 0, 16), Position = UDim2.new(0, 0, 0.5, -8)}, 0.3)
        end

        tabButton.MouseButton1Click:Connect(function() tabData:Activate() end)

        tabData.Btn = tabButton
        tabData.Lbl = tabLabel
        tabData.Ind = tabIndicator
        tabData.Page = pageScrollingFrame

        table.insert(windowContext.Tabs, tabData)
        if #windowContext.Tabs == 1 then tabData:Activate() end

        local function elementInjector(targetContainer)
            local elements = {}

            function elements:Subtext_Create(text)
                local subtextLabel = Instance.new("TextLabel")
                subtextLabel.Size = UDim2.new(1, -10, 0, 14)
                subtextLabel.BackgroundTransparency = 1
                subtextLabel.Text = text
                subtextLabel.TextColor3 = colors.textDarkColor
                subtextLabel.TextSize = 11
                subtextLabel.Font = mainFont
                subtextLabel.TextXAlignment = Enum.TextXAlignment.Left
                subtextLabel.Parent = targetContainer
            end

            function elements:Toggle_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or false)

                local toggleButton = Instance.new("TextButton")
                toggleButton.Size = UDim2.new(1, 0, 0, 16)
                toggleButton.BackgroundTransparency = 1
                toggleButton.Text = ""
                toggleButton.Parent = targetContainer

                local checkboxFrame = Instance.new("Frame")
                checkboxFrame.Size = UDim2.new(0, 14, 0, 14)
                checkboxFrame.Position = UDim2.new(0, 2, 0.5, -7)
                checkboxFrame.BackgroundColor3 = LibraryApi.Flags[flag] and colors.accentColor or colors.elementBackground
                checkboxFrame.BackgroundTransparency = 0.21847
                checkboxFrame.Parent = toggleButton
                
                local checkboxCorner = Instance.new("UICorner")
                checkboxCorner.CornerRadius = UDim.new(0, 3)
                checkboxCorner.Parent = checkboxFrame
                
                local checkboxStroke = Instance.new("UIStroke")
                checkboxStroke.Color = LibraryApi.Flags[flag] and colors.accentColor or colors.borderColor
                checkboxStroke.Parent = checkboxFrame

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(1, -26, 1, 0)
                toggleLabel.Position = UDim2.new(0, 24, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = name
                toggleLabel.TextColor3 = LibraryApi.Flags[flag] and colors.textWhiteColor or colors.textDarkColor
                toggleLabel.TextSize = 12
                toggleLabel.Font = mainFont
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleButton

                toggleButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not LibraryApi.Flags[flag] then animateElement(checkboxStroke, {Color = colors.borderLightColor}, 0.25) end
                end)
                toggleButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not LibraryApi.Flags[flag] then animateElement(checkboxStroke, {Color = colors.borderColor}, 0.25) end
                end)

                toggleButton.MouseButton1Click:Connect(function()
                    LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                    local newState = LibraryApi.Flags[flag]
                    animateElement(checkboxFrame, {BackgroundColor3 = newState and colors.accentColor or colors.elementBackground}, 0.3)
                    animateElement(checkboxStroke, {Color = newState and colors.accentColor or colors.borderColor}, 0.3)
                    animateElement(toggleLabel, {TextColor3 = newState and colors.textWhiteColor or colors.textDarkColor}, 0.3)
                    saveConfiguration()
                    if callback then task.spawn(callback, newState) end
                end)
            end

            function elements:Slider_Create(name, flag, min, max, default, step, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or snapValue(default or min, step)

                local sliderFrame = Instance.new("Frame")
                sliderFrame.Size = UDim2.new(1, 0, 0, 36)
                sliderFrame.BackgroundTransparency = 1
                sliderFrame.Parent = targetContainer

                local sliderLabel = Instance.new("TextLabel")
                sliderLabel.Size = UDim2.new(1, -50, 0, 14)
                sliderLabel.Position = UDim2.new(0, 2, 0, 0)
                sliderLabel.BackgroundTransparency = 1
                sliderLabel.Text = name
                sliderLabel.TextColor3 = colors.textWhiteColor
                sliderLabel.TextSize = 12
                sliderLabel.Font = mainFont
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame

                local valueTextBox = Instance.new("TextBox")
                valueTextBox.Size = UDim2.new(0, 40, 0, 14)
                valueTextBox.Position = UDim2.new(1, -42, 0, 0)
                valueTextBox.BackgroundTransparency = 1
                valueTextBox.Text = formatValue(LibraryApi.Flags[flag], step)
                valueTextBox.TextColor3 = colors.textWhiteColor
                valueTextBox.TextSize = 12
                valueTextBox.Font = mainFont
                valueTextBox.TextXAlignment = Enum.TextXAlignment.Right
                valueTextBox.ClearTextOnFocus = false
                valueTextBox.Parent = sliderFrame

                local sliderBackground = Instance.new("TextButton")
                sliderBackground.Size = UDim2.new(1, -4, 0, 6)
                sliderBackground.Position = UDim2.new(0, 2, 0, 24)
                sliderBackground.BackgroundColor3 = colors.elementBackground
                sliderBackground.BackgroundTransparency = 0.21847
                sliderBackground.Text = ""
                sliderBackground.AutoButtonColor = false
                sliderBackground.Parent = sliderFrame
                
                local sliderBackgroundCorner = Instance.new("UICorner")
                sliderBackgroundCorner.CornerRadius = UDim.new(0, 3)
                sliderBackgroundCorner.Parent = sliderBackground
                
                local sliderBackgroundStroke = Instance.new("UIStroke")
                sliderBackgroundStroke.Color = colors.borderColor
                sliderBackgroundStroke.Parent = sliderBackground

                local sliderFill = Instance.new("Frame")
                local initialPercentage = (LibraryApi.Flags[flag] - min) / (max - min)
                sliderFill.Size = UDim2.new(initialPercentage, 0, 1, 0)
                sliderFill.BackgroundColor3 = colors.accentColor
                sliderFill.Parent = sliderBackground
                
                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(0, 3)
                sliderFillCorner.Parent = sliderFill

                local sliderKnob = Instance.new("Frame")
                sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderKnob.Size = UDim2.new(0, 10, 0, 10)
                sliderKnob.Position = UDim2.new(initialPercentage, 0, 0.5, 0)
                sliderKnob.BackgroundColor3 = colors.textWhiteColor
                sliderKnob.ZIndex = 2
                sliderKnob.Parent = sliderBackground
                local sliderKnobCorner = Instance.new("UICorner"); sliderKnobCorner.CornerRadius = UDim.new(1, 0); sliderKnobCorner.Parent = sliderKnob
                local sliderKnobStroke = Instance.new("UIStroke"); sliderKnobStroke.Color = colors.borderColor; sliderKnobStroke.Parent = sliderKnob

                sliderBackground.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    animateElement(sliderBackgroundStroke, {Color = colors.borderLightColor}, 0.25)
                end)
                sliderBackground.MouseLeave:Connect(function()
                    showTooltip("")
                    animateElement(sliderBackgroundStroke, {Color = colors.borderColor}, 0.25)
                end)

                local isSliding = false

                local function setSliderValue(newValue)
                    local clampedValue = math.clamp(newValue, min, max)
                    local snappedValue = snapValue(clampedValue, step)
                    if LibraryApi.Flags[flag] ~= snappedValue then
                        LibraryApi.Flags[flag] = snappedValue
                        local percentage = (snappedValue - min) / (max - min)
                        animateElement(sliderFill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.15)
                        animateElement(sliderKnob, {Position = UDim2.new(percentage, 0, 0.5, 0)}, 0.15)
                        valueTextBox.Text = formatValue(snappedValue, step)
                        saveConfiguration()
                        if callback then task.spawn(callback, snappedValue) end
                    end
                end

                sliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isSliding = true
                        local percentage = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                        setSliderValue(min + ((max - min) * percentage))
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                        isSliding = false 
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
                        local percentage = math.clamp((input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X, 0, 1)
                        setSliderValue(min + ((max - min) * percentage))
                    end
                end)

                valueTextBox.FocusLost:Connect(function()
                    local inputValue = tonumber(valueTextBox.Text)
                    if inputValue then
                        setSliderValue(inputValue)
                    else
                        valueTextBox.Text = formatValue(LibraryApi.Flags[flag], step)
                    end
                end)
            end

            function elements:RangeSlider_Create(name, flag, min, max, defaultMin, defaultMax, step, tooltip, callback)
                if not LibraryApi.Flags[flag] then
                    LibraryApi.Flags[flag] = {Min = snapValue(defaultMin or min, step), Max = snapValue(defaultMax or max, step)}
                end

                local rangeSliderFrame = Instance.new("Frame")
                rangeSliderFrame.Size = UDim2.new(1, 0, 0, 36)
                rangeSliderFrame.BackgroundTransparency = 1
                rangeSliderFrame.Parent = targetContainer

                local rangeSliderLabel = Instance.new("TextLabel")
                rangeSliderLabel.Size = UDim2.new(1, -80, 0, 14)
                rangeSliderLabel.Position = UDim2.new(0, 2, 0, 0)
                rangeSliderLabel.BackgroundTransparency = 1
                rangeSliderLabel.Text = name
                rangeSliderLabel.TextColor3 = colors.textWhiteColor
                rangeSliderLabel.TextSize = 12
                rangeSliderLabel.Font = mainFont
                rangeSliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                rangeSliderLabel.Parent = rangeSliderFrame

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 80, 0, 14)
                valueLabel.Position = UDim2.new(1, -82, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = formatValue(LibraryApi.Flags[flag].Min, step) .. " - " .. formatValue(LibraryApi.Flags[flag].Max, step)
                valueLabel.TextColor3 = colors.textWhiteColor
                valueLabel.TextSize = 12
                valueLabel.Font = mainFont
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = rangeSliderFrame

                local rangeSliderBackground = Instance.new("TextButton")
                rangeSliderBackground.Size = UDim2.new(1, -4, 0, 6)
                rangeSliderBackground.Position = UDim2.new(0, 2, 0, 24)
                rangeSliderBackground.BackgroundColor3 = colors.elementBackground
                rangeSliderBackground.BackgroundTransparency = 0.21847
                rangeSliderBackground.Text = ""
                rangeSliderBackground.AutoButtonColor = false
                rangeSliderBackground.Parent = rangeSliderFrame
                
                local rangeSliderBackgroundCorner = Instance.new("UICorner")
                rangeSliderBackgroundCorner.CornerRadius = UDim.new(0, 3)
                rangeSliderBackgroundCorner.Parent = rangeSliderBackground
                
                local rangeSliderBackgroundStroke = Instance.new("UIStroke")
                rangeSliderBackgroundStroke.Color = colors.borderColor
                rangeSliderBackgroundStroke.Parent = rangeSliderBackground

                local rangeSliderFill = Instance.new("Frame")
                rangeSliderFill.BackgroundColor3 = colors.accentColor
                rangeSliderFill.Parent = rangeSliderBackground
                
                local rangeSliderFillCorner = Instance.new("UICorner")
                rangeSliderFillCorner.CornerRadius = UDim.new(0, 3)
                rangeSliderFillCorner.Parent = rangeSliderFill

                local minRangeKnob = Instance.new("Frame")
                minRangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                minRangeKnob.Size = UDim2.new(0, 10, 0, 10)
                minRangeKnob.BackgroundColor3 = colors.textWhiteColor
                minRangeKnob.ZIndex = 2
                minRangeKnob.Parent = rangeSliderBackground
                local minRangeKnobCorner = Instance.new("UICorner"); minRangeKnobCorner.CornerRadius = UDim.new(1, 0); minRangeKnobCorner.Parent = minRangeKnob
                local minRangeKnobStroke = Instance.new("UIStroke"); minRangeKnobStroke.Color = colors.borderColor; minRangeKnobStroke.Parent = minRangeKnob

                local maxRangeKnob = Instance.new("Frame")
                maxRangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                maxRangeKnob.Size = UDim2.new(0, 10, 0, 10)
                maxRangeKnob.BackgroundColor3 = colors.textWhiteColor
                maxRangeKnob.ZIndex = 2
                maxRangeKnob.Parent = rangeSliderBackground
                local maxRangeKnobCorner = Instance.new("UICorner"); maxRangeKnobCorner.CornerRadius = UDim.new(1, 0); maxRangeKnobCorner.Parent = maxRangeKnob
                local maxRangeKnobStroke = Instance.new("UIStroke"); maxRangeKnobStroke.Color = colors.borderColor; maxRangeKnobStroke.Parent = maxRangeKnob

                local function updateRangeSliderVisuals()
                    local minPercentage = (LibraryApi.Flags[flag].Min - min) / (max - min)
                    local maxPercentage = (LibraryApi.Flags[flag].Max - min) / (max - min)
                    animateElement(rangeSliderFill, {Position = UDim2.new(minPercentage, 0, 0, 0), Size = UDim2.new(maxPercentage - minPercentage, 0, 1, 0)}, 0.15)
                    animateElement(minRangeKnob, {Position = UDim2.new(minPercentage, 0, 0.5, 0)}, 0.15)
                    animateElement(maxRangeKnob, {Position = UDim2.new(maxPercentage, 0, 0.5, 0)}, 0.15)
                    valueLabel.Text = formatValue(LibraryApi.Flags[flag].Min, step) .. " - " .. formatValue(LibraryApi.Flags[flag].Max, step)
                end
                updateRangeSliderVisuals()

                rangeSliderBackground.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    animateElement(rangeSliderBackgroundStroke, {Color = colors.borderLightColor}, 0.25)
                end)
                rangeSliderBackground.MouseLeave:Connect(function()
                    showTooltip("")
                    animateElement(rangeSliderBackgroundStroke, {Color = colors.borderColor}, 0.25)
                end)

                local isSlidingMin = false
                local isSlidingMax = false

                rangeSliderBackground.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        local mouseX = input.Position.X
                        local minPercentage = (LibraryApi.Flags[flag].Min - min) / (max - min)
                        local maxPercentage = (LibraryApi.Flags[flag].Max - min) / (max - min)
                        local minKnobPosition = rangeSliderBackground.AbsolutePosition.X + (rangeSliderBackground.AbsoluteSize.X * minPercentage)
                        local maxKnobPosition = rangeSliderBackground.AbsolutePosition.X + (rangeSliderBackground.AbsoluteSize.X * maxPercentage)
                        
                        if math.abs(mouseX - minKnobPosition) < math.abs(mouseX - maxKnobPosition) then
                            isSlidingMin = true
                        else
                            isSlidingMax = true
                        end
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                        isSlidingMin = false
                        isSlidingMax = false
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if (isSlidingMin or isSlidingMax) and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then 
                        local percentage = math.clamp((input.Position.X - rangeSliderBackground.AbsolutePosition.X) / rangeSliderBackground.AbsoluteSize.X, 0, 1)
                        local calculatedValue = snapValue(min + ((max - min) * percentage), step)
                        
                        if isSlidingMin then
                            if calculatedValue <= LibraryApi.Flags[flag].Max then
                                LibraryApi.Flags[flag].Min = calculatedValue
                            else
                                LibraryApi.Flags[flag].Min = LibraryApi.Flags[flag].Max
                            end
                        elseif isSlidingMax then
                            if calculatedValue >= LibraryApi.Flags[flag].Min then
                                LibraryApi.Flags[flag].Max = calculatedValue
                            else
                                LibraryApi.Flags[flag].Max = LibraryApi.Flags[flag].Min
                            end
                        end
                        updateRangeSliderVisuals()
                        saveConfiguration()
                        if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                    end
                end)
            end

            function elements:Textbox_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or "")

                local textboxFrame = Instance.new("Frame")
                textboxFrame.Size = UDim2.new(1, 0, 0, 36)
                textboxFrame.BackgroundTransparency = 1
                textboxFrame.Parent = targetContainer

                local textboxLabel = Instance.new("TextLabel")
                textboxLabel.Size = UDim2.new(1, -120, 1, 0)
                textboxLabel.Position = UDim2.new(0, 2, 0, 0)
                textboxLabel.BackgroundTransparency = 1
                textboxLabel.Text = name
                textboxLabel.TextColor3 = colors.textWhiteColor
                textboxLabel.TextSize = 12
                textboxLabel.Font = mainFont
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                textboxLabel.Parent = textboxFrame

                local textboxInputBackground = Instance.new("Frame")
                textboxInputBackground.Size = UDim2.new(0, 110, 0, 24)
                textboxInputBackground.Position = UDim2.new(1, -112, 0.5, -12)
                textboxInputBackground.BackgroundColor3 = colors.elementBackground
                textboxInputBackground.BackgroundTransparency = 0.21847
                textboxInputBackground.Parent = textboxFrame
                
                local textboxInputBackgroundCorner = Instance.new("UICorner")
                textboxInputBackgroundCorner.CornerRadius = UDim.new(0, 4)
                textboxInputBackgroundCorner.Parent = textboxInputBackground
                
                local textboxInputBackgroundStroke = Instance.new("UIStroke")
                textboxInputBackgroundStroke.Color = colors.borderColor
                textboxInputBackgroundStroke.Parent = textboxInputBackground

                local inputTextBox = Instance.new("TextBox")
                inputTextBox.Size = UDim2.new(1, -10, 1, 0)
                inputTextBox.Position = UDim2.new(0, 5, 0, 0)
                inputTextBox.BackgroundTransparency = 1
                inputTextBox.Text = LibraryApi.Flags[flag]
                inputTextBox.TextColor3 = colors.textDarkColor
                inputTextBox.TextSize = 12
                inputTextBox.Font = mainFont
                inputTextBox.ClearTextOnFocus = false
                inputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                inputTextBox.ClipsDescendants = true
                inputTextBox.Parent = textboxInputBackground

                inputTextBox.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    animateElement(textboxInputBackgroundStroke, {Color = colors.borderLightColor}, 0.25)
                end)
                inputTextBox.MouseLeave:Connect(function()
                    showTooltip("")
                    animateElement(textboxInputBackgroundStroke, {Color = colors.borderColor}, 0.25)
                end)

                inputTextBox.Focused:Connect(function()
                    animateElement(textboxInputBackgroundStroke, {Color = colors.accentColor}, 0.25)
                    animateElement(inputTextBox, {TextColor3 = colors.textWhiteColor}, 0.25)
                end)

                inputTextBox.FocusLost:Connect(function()
                    animateElement(textboxInputBackgroundStroke, {Color = colors.borderColor}, 0.25)
                    animateElement(inputTextBox, {TextColor3 = colors.textDarkColor}, 0.25)
                    LibraryApi.Flags[flag] = inputTextBox.Text
                    saveConfiguration()
                    if callback then task.spawn(callback, inputTextBox.Text) end
                end)
            end

            function elements:Keybind_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or Enum.KeyCode.Unknown)
                local isListening = false

                local keybindFrame = Instance.new("Frame")
                keybindFrame.Size = UDim2.new(1, 0, 0, 30)
                keybindFrame.BackgroundTransparency = 1
                keybindFrame.Parent = targetContainer

                local keybindIcon = Instance.new("ImageLabel")
                keybindIcon.Size = UDim2.new(0, 18, 0, 18)
                keybindIcon.Position = UDim2.new(0, 6, 0.5, -9)
                keybindIcon.BackgroundTransparency = 1
                keybindIcon.Image = "rbxassetid://119296823312315"
                keybindIcon.ImageColor3 = colors.textWhiteColor
                keybindIcon.Parent = keybindFrame

                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Size = UDim2.new(1, -100, 1, 0)
                keybindLabel.Position = UDim2.new(0, 28, 0, 0)
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.Text = name
                keybindLabel.TextColor3 = colors.textWhiteColor
                keybindLabel.TextSize = 12
                keybindLabel.Font = mainFont
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                keybindLabel.Parent = keybindFrame

                local keybindButton = Instance.new("TextButton")
                keybindButton.Size = UDim2.new(0, 70, 0, 22)
                keybindButton.Position = UDim2.new(1, -74, 0.5, -11)
                keybindButton.BackgroundColor3 = colors.elementBackground
                keybindButton.BackgroundTransparency = 0.21847
                keybindButton.Text = LibraryApi.Flags[flag] == Enum.KeyCode.Unknown and "[ None ]" or "[ " .. LibraryApi.Flags[flag].Name .. " ]"
                keybindButton.TextColor3 = colors.textDarkColor
                keybindButton.TextSize = 11
                keybindButton.Font = boldFont
                keybindButton.AutoButtonColor = false
                keybindButton.Parent = keybindFrame

                local keybindButtonCorner = Instance.new("UICorner")
                keybindButtonCorner.CornerRadius = UDim.new(0, 4)
                keybindButtonCorner.Parent = keybindButton

                local keybindButtonStroke = Instance.new("UIStroke")
                keybindButtonStroke.Color = colors.borderColor
                keybindButtonStroke.Parent = keybindButton

                keybindButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not isListening then animateElement(keybindButtonStroke, {Color = colors.borderLightColor}, 0.25) end
                end)
                keybindButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not isListening then animateElement(keybindButtonStroke, {Color = colors.borderColor}, 0.25) end
                end)

                keybindButton.MouseButton1Click:Connect(function()
                    isListening = true
                    keybindButton.Text = "[ ... ]"
                    animateElement(keybindButtonStroke, {Color = colors.accentColor}, 0.3)
                    animateElement(keybindButton, {TextColor3 = colors.textWhiteColor}, 0.3)
                end)

                userInputService.InputBegan:Connect(function(input)
                    if isListening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = input.KeyCode
                            keybindButton.Text = "[ " .. input.KeyCode.Name .. " ]"
                        elseif input.KeyCode == Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = Enum.KeyCode.Unknown
                            keybindButton.Text = "[ None ]"
                        end
                        isListening = false
                        animateElement(keybindButtonStroke, {Color = colors.borderColor}, 0.3)
                        animateElement(keybindButton, {TextColor3 = colors.textDarkColor}, 0.3)
                        saveConfiguration()
                        if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                    else
                        if input.KeyCode == LibraryApi.Flags[flag] and input.KeyCode ~= Enum.KeyCode.Unknown then
                            if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                        end
                    end
                end)
            end

            function elements:Dropdown_Create(name, flag, options, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or options[1])
                local isDropdownOpen = false

                local dropdownFrame = Instance.new("Frame")
                dropdownFrame.Size = UDim2.new(1, 0, 0, 46)
                dropdownFrame.BackgroundTransparency = 1
                dropdownFrame.ClipsDescendants = true
                dropdownFrame.Parent = targetContainer

                local dropdownLabel = Instance.new("TextLabel")
                dropdownLabel.Size = UDim2.new(1, -10, 0, 14)
                dropdownLabel.Position = UDim2.new(0, 2, 0, 0)
                dropdownLabel.BackgroundTransparency = 1
                dropdownLabel.Text = name
                dropdownLabel.TextColor3 = colors.textWhiteColor
                dropdownLabel.TextSize = 12
                dropdownLabel.Font = mainFont
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownMainButton = Instance.new("TextButton")
                dropdownMainButton.Size = UDim2.new(1, -4, 0, 24)
                dropdownMainButton.Position = UDim2.new(0, 2, 0, 20)
                dropdownMainButton.BackgroundColor3 = colors.elementBackground
                dropdownMainButton.BackgroundTransparency = 0.21847
                dropdownMainButton.Text = ""
                dropdownMainButton.AutoButtonColor = false
                dropdownMainButton.Parent = dropdownFrame
                
                local dropdownMainButtonCorner = Instance.new("UICorner")
                dropdownMainButtonCorner.CornerRadius = UDim.new(0, 4)
                dropdownMainButtonCorner.Parent = dropdownMainButton
                
                local dropdownMainButtonStroke = Instance.new("UIStroke")
                dropdownMainButtonStroke.Color = colors.borderColor
                dropdownMainButtonStroke.Parent = dropdownMainButton

                local selectedOptionLabel = Instance.new("TextLabel")
                selectedOptionLabel.Size = UDim2.new(1, -30, 1, 0)
                selectedOptionLabel.Position = UDim2.new(0, 8, 0, 0)
                selectedOptionLabel.BackgroundTransparency = 1
                selectedOptionLabel.Text = LibraryApi.Flags[flag]
                selectedOptionLabel.TextColor3 = colors.textDarkColor
                selectedOptionLabel.TextSize = 12
                selectedOptionLabel.Font = mainFont
                selectedOptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                selectedOptionLabel.Parent = dropdownMainButton

                local dropdownArrowIcon = Instance.new("ImageLabel")
                dropdownArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                dropdownArrowIcon.Position = UDim2.new(1, -22, 0.5, -7)
                dropdownArrowIcon.BackgroundTransparency = 1
                dropdownArrowIcon.Image = "rbxassetid://6031090656"
                dropdownArrowIcon.ImageColor3 = colors.textDarkColor
                dropdownArrowIcon.Parent = dropdownMainButton

                local dropdownOptionListFrame = Instance.new("ScrollingFrame")
                dropdownOptionListFrame.Size = UDim2.new(1, -4, 0, 0)
                dropdownOptionListFrame.Position = UDim2.new(0, 2, 0, 48)
                dropdownOptionListFrame.BackgroundColor3 = colors.elementBackground
                dropdownOptionListFrame.BackgroundTransparency = 0.21847
                dropdownOptionListFrame.BorderSizePixel = 0
                dropdownOptionListFrame.ScrollBarThickness = 2
                dropdownOptionListFrame.ScrollBarImageColor3 = colors.accentColor
                dropdownOptionListFrame.ClipsDescendants = true
                dropdownOptionListFrame.Parent = dropdownFrame
                
                local dropdownOptionListCorner = Instance.new("UICorner")
                dropdownOptionListCorner.CornerRadius = UDim.new(0, 4)
                dropdownOptionListCorner.Parent = dropdownOptionListFrame
                
                local dropdownOptionListStroke = Instance.new("UIStroke")
                dropdownOptionListStroke.Color = colors.borderColor
                dropdownOptionListStroke.Transparency = 1
                dropdownOptionListStroke.Parent = dropdownOptionListFrame

                local dropdownOptionListLayout = Instance.new("UIListLayout")
                dropdownOptionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownOptionListLayout.Parent = dropdownOptionListFrame

                local function toggleDropdownState()
                    isDropdownOpen = not isDropdownOpen
                    local maxListHeight = math.min(#options * 24, 120)
                    local targetListHeight = isDropdownOpen and maxListHeight or 0
                    animateElement(dropdownMainButtonStroke, {Color = isDropdownOpen and colors.accentColor or colors.borderColor}, 0.3)
                    animateElement(dropdownArrowIcon, {Rotation = isDropdownOpen and 180 or 0, ImageColor3 = isDropdownOpen and colors.accentColor or colors.textDarkColor}, 0.3)
                    animateElement(dropdownOptionListFrame, {Size = UDim2.new(1, -4, 0, targetListHeight)}, 0.3)
                    animateElement(dropdownOptionListStroke, {Transparency = isDropdownOpen and 0 or 1}, 0.3)
                    animateElement(dropdownFrame, {Size = UDim2.new(1, 0, 0, 46 + targetListHeight + (isDropdownOpen and 4 or 0))}, 0.3)
                end

                dropdownMainButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not isDropdownOpen then animateElement(dropdownMainButtonStroke, {Color = colors.borderLightColor}, 0.25) end
                end)
                dropdownMainButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not isDropdownOpen then animateElement(dropdownMainButtonStroke, {Color = colors.borderColor}, 0.25) end
                end)
                dropdownMainButton.MouseButton1Click:Connect(toggleDropdownState)

                for _, option in ipairs(options) do
                    local optionButton = Instance.new("TextButton")
                    optionButton.Size = UDim2.new(1, 0, 0, 24)
                    optionButton.BackgroundColor3 = colors.elementHoverBackground
                    optionButton.BackgroundTransparency = 1
                    optionButton.Text = ""
                    optionButton.Parent = dropdownOptionListFrame

                    local optionLabel = Instance.new("TextLabel")
                    optionLabel.Size = UDim2.new(1, -20, 1, 0)
                    optionLabel.Position = UDim2.new(0, 8, 0, 0)
                    optionLabel.BackgroundTransparency = 1
                    optionLabel.Text = option
                    optionLabel.TextColor3 = LibraryApi.Flags[flag] == option and colors.accentColor or colors.textDarkColor
                    optionLabel.TextSize = 12
                    optionLabel.Font = mainFont
                    optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                    optionLabel.Parent = optionButton

                    optionButton.MouseEnter:Connect(function() 
                        animateElement(optionButton, {BackgroundTransparency = 0.21847}, 0.25)
                        if LibraryApi.Flags[flag] ~= option then
                            animateElement(optionLabel, {TextColor3 = colors.textWhiteColor}, 0.25) 
                        end
                    end)
                    optionButton.MouseLeave:Connect(function()
                        animateElement(optionButton, {BackgroundTransparency = 1}, 0.25)
                        if LibraryApi.Flags[flag] ~= option then
                            animateElement(optionLabel, {TextColor3 = colors.textDarkColor}, 0.25)
                        end
                    end)

                    optionButton.MouseButton1Click:Connect(function()
                        LibraryApi.Flags[flag] = option
                        selectedOptionLabel.Text = option
                        toggleDropdownState()
                        for _, child in ipairs(dropdownOptionListFrame:GetChildren()) do
                            if child:IsA("TextButton") then
                                animateElement(child:FindFirstChildOfClass("TextLabel"), {TextColor3 = colors.textDarkColor}, 0.3)
                            end
                        end
                        animateElement(optionLabel, {TextColor3 = colors.accentColor}, 0.3)
                        saveConfiguration()
                        if callback then task.spawn(callback, option) end
                    end)
                end
                dropdownOptionListFrame.CanvasSize = UDim2.new(0, 0, 0, #options * 24)
            end

            function elements:ColorPicker_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or Color3.new(1, 1, 1))
                local isColorPickerOpen = false
                local hue, saturation, value = LibraryApi.Flags[flag]:ToHSV()

                local colorPickerFrame = Instance.new("Frame")
                colorPickerFrame.Size = UDim2.new(1, 0, 0, 24)
                colorPickerFrame.BackgroundTransparency = 1
                colorPickerFrame.ClipsDescendants = true
                colorPickerFrame.Parent = targetContainer

                local colorPickerLabel = Instance.new("TextLabel")
                colorPickerLabel.Size = UDim2.new(1, -40, 0, 24)
                colorPickerLabel.Position = UDim2.new(0, 2, 0, 0)
                colorPickerLabel.BackgroundTransparency = 1
                colorPickerLabel.Text = name
                colorPickerLabel.TextColor3 = colors.textWhiteColor
                colorPickerLabel.TextSize = 12
                colorPickerLabel.Font = mainFont
                colorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                colorPickerLabel.Parent = colorPickerFrame

                local colorPreviewButton = Instance.new("TextButton")
                colorPreviewButton.Size = UDim2.new(0, 24, 0, 14)
                colorPreviewButton.Position = UDim2.new(1, -28, 0, 5)
                colorPreviewButton.BackgroundColor3 = LibraryApi.Flags[flag]
                colorPreviewButton.Text = ""
                colorPreviewButton.AutoButtonColor = false
                colorPreviewButton.Parent = colorPickerFrame
                
                local colorPreviewButtonCorner = Instance.new("UICorner")
                colorPreviewButtonCorner.CornerRadius = UDim.new(0, 3)
                colorPreviewButtonCorner.Parent = colorPreviewButton
                
                local colorPreviewButtonStroke = Instance.new("UIStroke")
                colorPreviewButtonStroke.Color = colors.borderColor
                colorPreviewButtonStroke.Parent = colorPreviewButton

                local expandedPickerFrame = Instance.new("Frame")
                expandedPickerFrame.Size = UDim2.new(1, -4, 0, 190)
                expandedPickerFrame.Position = UDim2.new(0, 2, 0, 28)
                expandedPickerFrame.BackgroundColor3 = colors.elementBackground
                expandedPickerFrame.BackgroundTransparency = 0.21847
                expandedPickerFrame.Parent = colorPickerFrame
                
                local expandedPickerCorner = Instance.new("UICorner")
                expandedPickerCorner.CornerRadius = UDim.new(0, 4)
                expandedPickerCorner.Parent = expandedPickerFrame
                
                local expandedPickerStroke = Instance.new("UIStroke")
                expandedPickerStroke.Color = colors.borderColor
                expandedPickerStroke.Parent = expandedPickerFrame

                local saturationValueMap = Instance.new("ImageButton")
                saturationValueMap.Size = UDim2.new(1, -16, 0, 150)
                saturationValueMap.Position = UDim2.new(0, 8, 0, 8)
                saturationValueMap.Image = "rbxassetid://4155801252"
                saturationValueMap.ImageColor3 = Color3.fromHSV(hue, 1, 1)
                saturationValueMap.AutoButtonColor = false
                saturationValueMap.Parent = expandedPickerFrame
                local saturationValueMapCorner = Instance.new("UICorner"); saturationValueMapCorner.CornerRadius = UDim.new(0, 3); saturationValueMapCorner.Parent = saturationValueMap
                local saturationValueMapStroke = Instance.new("UIStroke"); saturationValueMapStroke.Color = colors.borderColor; saturationValueMapStroke.Parent = saturationValueMap

                local saturationValueMapCursor = Instance.new("Frame")
                saturationValueMapCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                saturationValueMapCursor.Size = UDim2.new(0, 6, 0, 6)
                saturationValueMapCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
                saturationValueMapCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                saturationValueMapCursor.Parent = saturationValueMap
                local saturationValueMapCursorCorner = Instance.new("UICorner"); saturationValueMapCursorCorner.CornerRadius = UDim.new(1, 0); saturationValueMapCursorCorner.Parent = saturationValueMapCursor
                local saturationValueMapCursorStroke = Instance.new("UIStroke"); saturationValueMapCursorStroke.Color = Color3.new(0, 0, 0); saturationValueMapCursorStroke.Parent = saturationValueMapCursor

                local hueMap = Instance.new("TextButton")
                hueMap.Size = UDim2.new(1, -16, 0, 12)
                hueMap.Position = UDim2.new(0, 8, 0, 168)
                hueMap.Text = ""
                hueMap.AutoButtonColor = false
                hueMap.BackgroundColor3 = Color3.new(1, 1, 1)
                hueMap.Parent = expandedPickerFrame
                local hueMapCorner = Instance.new("UICorner"); hueMapCorner.CornerRadius = UDim.new(0, 3); hueMapCorner.Parent = hueMap
                local hueMapStroke = Instance.new("UIStroke"); hueMapStroke.Color = colors.borderColor; hueMapStroke.Parent = hueMap

                local hueGradient = Instance.new("UIGradient")
                hueGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(1/6, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(2/6, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(3/6, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(4/6, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(5/6, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                }
                hueGradient.Parent = hueMap

                local hueMapCursor = Instance.new("Frame")
                hueMapCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                hueMapCursor.Size = UDim2.new(0, 4, 1, 4)
                hueMapCursor.Position = UDim2.new(hue, 0, 0.5, 0)
                hueMapCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                hueMapCursor.Parent = hueMap
                local hueMapCursorCorner = Instance.new("UICorner"); hueMapCursorCorner.CornerRadius = UDim.new(0, 2); hueMapCursorCorner.Parent = hueMapCursor
                local hueMapCursorStroke = Instance.new("UIStroke"); hueMapCursorStroke.Color = Color3.new(0, 0, 0); hueMapCursorStroke.Parent = hueMapCursor

                local function updateColorPickerState()
                    local currentColor = Color3.fromHSV(hue, saturation, value)
                    LibraryApi.Flags[flag] = currentColor
                    saturationValueMap.ImageColor3 = Color3.fromHSV(hue, 1, 1)
                    colorPreviewButton.BackgroundColor3 = currentColor
                    saturationValueMapCursor.Position = UDim2.new(saturation, 0, 1 - value, 0)
                    hueMapCursor.Position = UDim2.new(hue, 0, 0.5, 0)
                    saveConfiguration()
                    if callback then task.spawn(callback, currentColor) end
                end

                local isSlidingSaturationValue = false
                local isSlidingHue = false

                local function processSaturationValueInput(input)
                    saturation = math.clamp((input.Position.X - saturationValueMap.AbsolutePosition.X) / saturationValueMap.AbsoluteSize.X, 0, 1)
                    value = 1 - math.clamp((input.Position.Y - saturationValueMap.AbsolutePosition.Y) / saturationValueMap.AbsoluteSize.Y, 0, 1)
                    updateColorPickerState()
                end

                local function processHueInput(input)
                    hue = math.clamp((input.Position.X - hueMap.AbsolutePosition.X) / hueMap.AbsoluteSize.X, 0, 1)
                    updateColorPickerState()
                end

                saturationValueMap.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isSlidingSaturationValue = true
                        processSaturationValueInput(input)
                    end
                end)
                
                hueMap.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isSlidingHue = true
                        processHueInput(input)
                    end
                end)

                userInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        isSlidingSaturationValue = false
                        isSlidingHue = false
                    end
                end)

                userInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if isSlidingSaturationValue then processSaturationValueInput(input) end
                        if isSlidingHue then processHueInput(input) end
                    end
                end)

                colorPreviewButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not isColorPickerOpen then animateElement(colorPreviewButtonStroke, {Color = colors.borderLightColor}, 0.25) end
                end)
                colorPreviewButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not isColorPickerOpen then animateElement(colorPreviewButtonStroke, {Color = colors.borderColor}, 0.25) end
                end)

                colorPreviewButton.MouseButton1Click:Connect(function()
                    isColorPickerOpen = not isColorPickerOpen
                    animateElement(colorPreviewButtonStroke, {Color = isColorPickerOpen and colors.accentColor or colors.borderColor}, 0.3)
                    animateElement(colorPickerFrame, {Size = UDim2.new(1, 0, 0, isColorPickerOpen and 224 or 24)}, 0.3)
                end)
            end

            function elements:Button_Create(name, tooltip, callback)
                local buttonFrame = Instance.new("Frame")
                buttonFrame.Size = UDim2.new(1, 0, 0, 30)
                buttonFrame.BackgroundTransparency = 1
                buttonFrame.Parent = targetContainer

                local actionButton = Instance.new("TextButton")
                actionButton.Size = UDim2.new(1, -4, 1, 0)
                actionButton.Position = UDim2.new(0, 2, 0, 0)
                actionButton.BackgroundColor3 = colors.elementBackground
                actionButton.BackgroundTransparency = 0.21847
                actionButton.Text = name
                actionButton.TextColor3 = colors.textWhiteColor
                actionButton.TextSize = 12
                actionButton.Font = boldFont
                actionButton.AutoButtonColor = false
                actionButton.Parent = buttonFrame
                
                local actionButtonCorner = Instance.new("UICorner")
                actionButtonCorner.CornerRadius = UDim.new(0, 4)
                actionButtonCorner.Parent = actionButton
                
                local actionButtonStroke = Instance.new("UIStroke")
                actionButtonStroke.Color = colors.borderColor
                actionButtonStroke.Parent = actionButton

                actionButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    animateElement(actionButton, {BackgroundColor3 = colors.elementHoverBackground}, 0.25)
                    animateElement(actionButtonStroke, {Color = colors.accentColor}, 0.25)
                    animateElement(actionButton, {TextColor3 = colors.accentColor}, 0.25)
                end)
                actionButton.MouseLeave:Connect(function()
                    showTooltip("")
                    animateElement(actionButton, {BackgroundColor3 = colors.elementBackground}, 0.25)
                    animateElement(actionButtonStroke, {Color = colors.borderColor}, 0.25)
                    animateElement(actionButton, {TextColor3 = colors.textWhiteColor}, 0.25)
                end)
                actionButton.MouseButton1Down:Connect(function() animateElement(actionButton, {Size = UDim2.new(0.96, 0, 0.85, 0), Position = UDim2.new(0.02, 0, 0.075, 0)}, 0.15) end)
                actionButton.MouseButton1Up:Connect(function()
                    animateElement(actionButton, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.15)
                    if callback then task.spawn(callback) end
                end)
            end

            function elements:SubButton_Create(name, tooltip, callback)
                local subButtonFrame = Instance.new("Frame")
                subButtonFrame.Size = UDim2.new(1, 0, 0, 22)
                subButtonFrame.BackgroundTransparency = 1
                subButtonFrame.Parent = targetContainer

                local subButtonAction = Instance.new("TextButton")
                subButtonAction.Size = UDim2.new(1, -16, 1, 0)
                subButtonAction.Position = UDim2.new(0, 8, 0, 0)
                subButtonAction.BackgroundColor3 = colors.sectionBackground
                subButtonAction.BackgroundTransparency = 0.21847
                subButtonAction.Text = name
                subButtonAction.TextColor3 = colors.textDarkColor
                subButtonAction.TextSize = 11
                subButtonAction.Font = mainFont
                subButtonAction.AutoButtonColor = false
                subButtonAction.Parent = subButtonFrame
                
                local subButtonCorner = Instance.new("UICorner")
                subButtonCorner.CornerRadius = UDim.new(0, 3)
                subButtonCorner.Parent = subButtonAction
                
                local subButtonStroke = Instance.new("UIStroke")
                subButtonStroke.Color = colors.borderColor
                subButtonStroke.Parent = subButtonAction

                subButtonAction.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    animateElement(subButtonAction, {BackgroundColor3 = colors.elementBackground}, 0.25)
                    animateElement(subButtonStroke, {Color = colors.borderLightColor}, 0.25)
                    animateElement(subButtonAction, {TextColor3 = colors.textWhiteColor}, 0.25)
                end)
                subButtonAction.MouseLeave:Connect(function()
                    showTooltip("")
                    animateElement(subButtonAction, {BackgroundColor3 = colors.sectionBackground}, 0.25)
                    animateElement(subButtonStroke, {Color = colors.borderColor}, 0.25)
                    animateElement(subButtonAction, {TextColor3 = colors.textDarkColor}, 0.25)
                end)
                subButtonAction.MouseButton1Down:Connect(function() animateElement(subButtonAction, {Size = UDim2.new(0.96, -16, 0.85, 0), Position = UDim2.new(0.02, 8, 0.075, 0)}, 0.15) end)
                subButtonAction.MouseButton1Up:Connect(function()
                    animateElement(subButtonAction, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0)}, 0.15)
                    if callback then task.spawn(callback) end
                end)
            end

            function elements:Module_Create(name, flag, descriptionText, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or false)

                local moduleFrame = Instance.new("Frame")
                moduleFrame.Size = UDim2.new(1, 0, 0, 46)
                moduleFrame.BackgroundTransparency = 1
                moduleFrame.ClipsDescendants = true
                moduleFrame.Parent = targetContainer

                local moduleToggleButton = Instance.new("TextButton")
                moduleToggleButton.Size = UDim2.new(1, -4, 0, 44)
                moduleToggleButton.Position = UDim2.new(0, 2, 0, 0)
                moduleToggleButton.BackgroundColor3 = colors.elementBackground
                moduleToggleButton.BackgroundTransparency = 0.21847
                moduleToggleButton.Text = ""
                moduleToggleButton.AutoButtonColor = false
                moduleToggleButton.Parent = moduleFrame
                
                local moduleToggleButtonCorner = Instance.new("UICorner")
                moduleToggleButtonCorner.CornerRadius = UDim.new(0, 6)
                moduleToggleButtonCorner.Parent = moduleToggleButton
                
                local moduleToggleButtonStroke = Instance.new("UIStroke")
                moduleToggleButtonStroke.Color = LibraryApi.Flags[flag] and colors.accentColor or colors.borderColor
                moduleToggleButtonStroke.Parent = moduleToggleButton

                local moduleCheckboxFrame = Instance.new("Frame")
                moduleCheckboxFrame.Size = UDim2.new(0, 16, 0, 16)
                moduleCheckboxFrame.Position = UDim2.new(0, 14, 0.5, -8)
                moduleCheckboxFrame.BackgroundColor3 = LibraryApi.Flags[flag] and colors.accentColor or colors.sectionBackground
                moduleCheckboxFrame.BackgroundTransparency = 0.21847
                moduleCheckboxFrame.Parent = moduleToggleButton
                
                local moduleCheckboxCorner = Instance.new("UICorner")
                moduleCheckboxCorner.CornerRadius = UDim.new(0, 4)
                moduleCheckboxCorner.Parent = moduleCheckboxFrame
                
                local moduleCheckboxStroke = Instance.new("UIStroke")
                moduleCheckboxStroke.Color = colors.borderColor
                moduleCheckboxStroke.Parent = moduleCheckboxFrame

                local moduleLabel = Instance.new("TextLabel")
                moduleLabel.Size = UDim2.new(1, -45, 0, 16)
                moduleLabel.Position = UDim2.new(0, 40, 0, 6)
                moduleLabel.BackgroundTransparency = 1
                moduleLabel.Text = name
                moduleLabel.TextColor3 = LibraryApi.Flags[flag] and colors.textWhiteColor or colors.textDarkColor
                moduleLabel.TextSize = 13
                moduleLabel.Font = boldFont
                moduleLabel.TextXAlignment = Enum.TextXAlignment.Left
                moduleLabel.Parent = moduleToggleButton

                local moduleDescriptionLabel = Instance.new("TextLabel")
                moduleDescriptionLabel.Size = UDim2.new(1, -45, 0, 14)
                moduleDescriptionLabel.Position = UDim2.new(0, 40, 0, 22)
                moduleDescriptionLabel.BackgroundTransparency = 1
                moduleDescriptionLabel.Text = descriptionText
                moduleDescriptionLabel.TextColor3 = colors.textDarkColor
                moduleDescriptionLabel.TextSize = 11
                moduleDescriptionLabel.Font = mainFont
                moduleDescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                moduleDescriptionLabel.Parent = moduleToggleButton

                local moduleArrowIcon = Instance.new("ImageLabel")
                moduleArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                moduleArrowIcon.Position = UDim2.new(1, -22, 0, 14)
                moduleArrowIcon.BackgroundTransparency = 1
                moduleArrowIcon.Image = "rbxassetid://6031090656"
                moduleArrowIcon.ImageColor3 = LibraryApi.Flags[flag] and colors.accentColor or colors.textDarkColor
                moduleArrowIcon.Rotation = LibraryApi.Flags[flag] and 180 or 0
                moduleArrowIcon.Parent = moduleToggleButton

                local moduleContentFrame = Instance.new("Frame")
                moduleContentFrame.Size = UDim2.new(1, -16, 0, 0)
                moduleContentFrame.Position = UDim2.new(0, 12, 0, 48)
                moduleContentFrame.BackgroundTransparency = 1
                moduleContentFrame.Parent = moduleFrame

                local moduleContentLayout = Instance.new("UIListLayout")
                moduleContentLayout.Padding = UDim.new(0, 8)
                moduleContentLayout.Parent = moduleContentFrame

                local function synchronizeModuleSize()
                    if LibraryApi.Flags[flag] then
                        animateElement(moduleFrame, {Size = UDim2.new(1, 0, 0, 46 + moduleContentLayout.AbsoluteContentSize.Y + 8)}, 0.3)
                        animateElement(moduleArrowIcon, {Rotation = 180, ImageColor3 = colors.accentColor}, 0.3)
                    else
                        animateElement(moduleFrame, {Size = UDim2.new(1, 0, 0, 46)}, 0.3)
                        animateElement(moduleArrowIcon, {Rotation = 0, ImageColor3 = colors.textDarkColor}, 0.3)
                    end
                end

                moduleContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if LibraryApi.Flags[flag] then synchronizeModuleSize() end
                end)

                moduleToggleButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not LibraryApi.Flags[flag] then animateElement(moduleToggleButtonStroke, {Color = colors.borderLightColor}, 0.25) end
                end)
                moduleToggleButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not LibraryApi.Flags[flag] then animateElement(moduleToggleButtonStroke, {Color = colors.borderColor}, 0.25) end
                end)

                moduleToggleButton.MouseButton1Click:Connect(function()
                    LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                    local newState = LibraryApi.Flags[flag]
                    animateElement(moduleCheckboxFrame, {BackgroundColor3 = newState and colors.accentColor or colors.sectionBackground}, 0.3)
                    animateElement(moduleToggleButtonStroke, {Color = newState and colors.accentColor or colors.borderColor}, 0.3)
                    animateElement(moduleLabel, {TextColor3 = newState and colors.textWhiteColor or colors.textDarkColor}, 0.3)
                    synchronizeModuleSize()
                    saveConfiguration()
                    if callback then task.spawn(callback, newState) end
                end)

                return elementInjector(moduleContentFrame)
            end

            return elements
        end

        local sectionApi = {}

        function sectionApi:Section_Create(columnSide, sectionTitle)
            local sectionBackgroundFrame = Instance.new("Frame")
            sectionBackgroundFrame.Size = UDim2.new(1, 0, 0, 40)
            sectionBackgroundFrame.BackgroundColor3 = colors.sectionBackground
            sectionBackgroundFrame.BackgroundTransparency = 0.21847
            sectionBackgroundFrame.Parent = (columnSide == "Left") and leftColumnFrame or rightColumnFrame
            
            local sectionBackgroundCorner = Instance.new("UICorner")
            sectionBackgroundCorner.CornerRadius = UDim.new(0, 6)
            sectionBackgroundCorner.Parent = sectionBackgroundFrame
            
            local sectionBackgroundStroke = Instance.new("UIStroke")
            sectionBackgroundStroke.Color = colors.borderColor
            sectionBackgroundStroke.Parent = sectionBackgroundFrame

            local sectionHeaderFrame = Instance.new("Frame")
            sectionHeaderFrame.Size = UDim2.new(1, 0, 0, 26)
            sectionHeaderFrame.BackgroundTransparency = 1
            sectionHeaderFrame.Parent = sectionBackgroundFrame

            local sectionLabel = Instance.new("TextLabel")
            sectionLabel.Size = UDim2.new(1, -20, 1, 0)
            sectionLabel.Position = UDim2.new(0, 10, 0, 0)
            sectionLabel.BackgroundTransparency = 1
            sectionLabel.Text = sectionTitle
            sectionLabel.TextColor3 = colors.textWhiteColor
            sectionLabel.TextSize = 12
            sectionLabel.Font = boldFont
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionHeaderFrame

            local sectionSeparatorLine = Instance.new("Frame")
            sectionSeparatorLine.Size = UDim2.new(1, -20, 0, 1)
            sectionSeparatorLine.Position = UDim2.new(0, 10, 1, 0)
            sectionSeparatorLine.BackgroundColor3 = colors.borderColor
            sectionSeparatorLine.BorderSizePixel = 0
            sectionSeparatorLine.Parent = sectionHeaderFrame

            local sectionContentFrame = Instance.new("Frame")
            sectionContentFrame.Size = UDim2.new(1, -16, 1, -34)
            sectionContentFrame.Position = UDim2.new(0, 8, 0, 32)
            sectionContentFrame.BackgroundTransparency = 1
            sectionContentFrame.Parent = sectionBackgroundFrame

            local sectionContentLayout = Instance.new("UIListLayout")
            sectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            sectionContentLayout.Padding = UDim.new(0, 8)
            sectionContentLayout.Parent = sectionContentFrame

            runService.RenderStepped:Connect(function()
                sectionBackgroundFrame.Size = UDim2.new(1, 0, 0, sectionContentLayout.AbsoluteContentSize.Y + 44)
            end)

            return elementInjector(sectionContentFrame)
        end

        return sectionApi
    end

    return windowContext
end

return LibraryApi
