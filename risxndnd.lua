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
    FolderName = "PhantomHub",
    CurrentConfig = "Default"
}

local colors = {
    mainBackground = Color3.fromRGB(12, 12, 12),
    sidebarBackground = Color3.fromRGB(8, 8, 8),
    sectionBackground = Color3.fromRGB(16, 16, 16),
    elementBackground = Color3.fromRGB(20, 20, 20),
    elementHoverBackground = Color3.fromRGB(30, 15, 15),
    borderColor = Color3.fromRGB(45, 15, 15),
    borderLightColor = Color3.fromRGB(75, 20, 20),
    accentColor = Color3.fromRGB(220, 30, 30),
    textWhiteColor = Color3.fromRGB(240, 240, 240),
    textDarkColor = Color3.fromRGB(140, 140, 140),
    tooltipBackground = Color3.fromRGB(10, 10, 10),
    notificationInfoColor = Color3.fromRGB(220, 30, 30),
    notificationSuccessColor = Color3.fromRGB(50, 200, 50),
    notificationWarningColor = Color3.fromRGB(220, 150, 30),
    notificationErrorColor = Color3.fromRGB(250, 50, 50)
}

local themeObjects = {}

local function applyTheme(obj, prop, colorName)
    if not themeObjects[colorName] then themeObjects[colorName] = {} end
    table.insert(themeObjects[colorName], {obj, prop})
    pcall(function() obj[prop] = colors[colorName] end)
end

local function updateTheme(colorName, color)
    colors[colorName] = color
    if themeObjects[colorName] then
        for _, item in ipairs(themeObjects[colorName]) do
            if item[1] and item[1].Parent then
                pcall(function() item[1][item[2]] = color end)
            end
        end
    end
end

local mainFont = Enum.Font.GothamMedium
local boldFont = Enum.Font.GothamBold

local screenGui = Instance.new("ScreenGui")
screenGui.Name = httpService:GenerateGUID(false)
screenGui.Parent = coreGuiService
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.DisplayOrder = 999
screenGui.IgnoreGuiInset = true

local tooltipFrame = Instance.new("Frame")
applyTheme(tooltipFrame, "BackgroundColor3", "tooltipBackground")
tooltipFrame.BackgroundTransparency = 0.15
tooltipFrame.Size = UDim2.new(0, 0, 0, 24)
tooltipFrame.ZIndex = 2000
tooltipFrame.Visible = false
tooltipFrame.Parent = screenGui

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 4)
tooltipCorner.Parent = tooltipFrame

local tooltipStroke = Instance.new("UIStroke")
applyTheme(tooltipStroke, "Color", "borderLightColor")
tooltipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
tooltipStroke.Transparency = 1
tooltipStroke.Parent = tooltipFrame

local tooltipText = Instance.new("TextLabel")
tooltipText.Size = UDim2.new(1, -16, 1, 0)
tooltipText.Position = UDim2.new(0, 8, 0, 0)
tooltipText.BackgroundTransparency = 1
applyTheme(tooltipText, "TextColor3", "textWhiteColor")
tooltipText.TextTransparency = 1
tooltipText.TextSize = 12
tooltipText.Font = mainFont
tooltipText.TextXAlignment = Enum.TextXAlignment.Left
tooltipText.ZIndex = 2001
tooltipText.Parent = tooltipFrame

local notificationContainer = Instance.new("Frame")
notificationContainer.Size = UDim2.new(0, 250, 1, -40)
notificationContainer.Position = UDim2.new(1, -270, 0, 20)
notificationContainer.BackgroundTransparency = 1
notificationContainer.ZIndex = 1500
notificationContainer.Parent = screenGui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notificationLayout.Padding = UDim.new(0, 8)
notificationLayout.Parent = notificationContainer

local tooltipTargetText = ""
local activeKeybinds = {}
local keybindListContainer = nil

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
    blurImage.ImageTransparency = transparency or 0.88
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

local function Get_Configs()
    local list = {}
    if isfolder and isfolder(LibraryApi.FolderName) and listfiles then
        pcall(function()
            for _, f in ipairs(listfiles(LibraryApi.FolderName)) do
                local name = f:match("([^/\\]+)%.json$")
                if name then table.insert(list, name) end
            end
        end)
    end
    if #list == 0 then table.insert(list, "Default") end
    return list
end

local function Save_Configuration(name)
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(LibraryApi.FolderName) then makefolder(LibraryApi.FolderName) end
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
        local themeData = {}
        for k, v in pairs(colors) do
            themeData[k] = {R = v.R, G = v.G, B = v.B}
        end
        local fullData = {Flags = serializedData, Theme = themeData}
        writefile(LibraryApi.FolderName .. "/" .. name .. ".json", httpService:JSONEncode(fullData))
        LibraryApi:Notify({Title = "Config", Text = "Saved config: " .. name, Type = "Success", Duration = 2})
    end)
end

local function Load_Configuration(name)
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local fullPath = LibraryApi.FolderName .. "/" .. name .. ".json"
        if isfile(fullPath) then
            local decodedData = httpService:JSONDecode(readfile(fullPath))
            if decodedData and type(decodedData) == "table" then
                if decodedData.Theme then
                    for k, v in pairs(decodedData.Theme) do
                        if colors[k] then
                            updateTheme(k, Color3.new(v.R, v.G, v.B))
                        end
                    end
                end
                if decodedData.Flags then
                    for key, val in pairs(decodedData.Flags) do
                        if type(val) == "table" then
                            if val.Type == "Color3" then
                                LibraryApi.Flags[key] = Color3.new(val.R, val.G, val.B)
                            elseif val.Type == "KeyCode" then
                                LibraryApi.Flags[key] = Enum.KeyCode[val.Name] or Enum.KeyCode.Unknown
                            elseif val.Type == "Range" then
                                LibraryApi.Flags[key] = {Min = val.Min, Max = val.Max}
                            else
                                LibraryApi.Flags[key] = val
                            end
                        else
                            LibraryApi.Flags[key] = val
                        end
                    end
                end
                LibraryApi:Notify({Title = "Config", Text = "Loaded config: " .. name, Type = "Info", Duration = 2})
            end
        end
    end)
end

local function Delete_Configuration(name)
    pcall(function()
        if isfile and delfile then
            local fullPath = LibraryApi.FolderName .. "/" .. name .. ".json"
            if isfile(fullPath) then
                delfile(fullPath)
                LibraryApi:Notify({Title = "Config", Text = "Deleted config: " .. name, Type = "Error", Duration = 2})
            end
        end
    end)
end

local function Refresh_Keybinds_List()
    if not keybindListContainer then return end
    for _, child in ipairs(keybindListContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for name, key in pairs(activeKeybinds) do
        local kbEntry = Instance.new("Frame")
        kbEntry.Size = UDim2.new(1, 0, 0, 20)
        kbEntry.BackgroundTransparency = 1
        kbEntry.Parent = keybindListContainer

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -60, 1, 0)
        nameLbl.Position = UDim2.new(0, 5, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = name
        nameLbl.TextColor3 = colors.textDarkColor
        nameLbl.TextSize = 11
        nameLbl.Font = mainFont
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.Parent = kbEntry

        local keyLbl = Instance.new("TextLabel")
        keyLbl.Size = UDim2.new(0, 50, 1, 0)
        keyLbl.Position = UDim2.new(1, -55, 0, 0)
        keyLbl.BackgroundTransparency = 1
        keyLbl.Text = "[" .. key .. "]"
        keyLbl.TextColor3 = colors.accentColor
        keyLbl.TextSize = 11
        keyLbl.Font = boldFont
        keyLbl.TextXAlignment = Enum.TextXAlignment.Right
        keyLbl.Parent = kbEntry
    end
    keybindListContainer.CanvasSize = UDim2.new(0, 0, 0, keybindListContainer.UIListLayout.AbsoluteContentSize.Y)
end

runService.RenderStepped:Connect(function()
    if tooltipTargetText ~= "" then
        local mouseLocation = userInputService:GetMouseLocation()
        tooltipFrame.Position = UDim2.new(0, mouseLocation.X + 15, 0, mouseLocation.Y + 15)
        if not tooltipFrame.Visible then
            tooltipFrame.Visible = true
            animateElement(tooltipFrame, {BackgroundTransparency = 0.15}, 0.25)
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

    local notificationFrame = Instance.new("Frame")
    notificationFrame.Size = UDim2.new(1, 0, 0, 50)
    notificationFrame.Position = UDim2.new(1, 270, 0, 0)
    notificationFrame.BackgroundColor3 = colors.sectionBackground
    notificationFrame.BackgroundTransparency = 0.05
    notificationFrame.ZIndex = 1501
    notificationFrame.Parent = notificationContainer

    local notificationCorner = Instance.new("UICorner")
    notificationCorner.CornerRadius = UDim.new(0, 4)
    notificationCorner.Parent = notificationFrame

    local notificationStroke = Instance.new("UIStroke")
    notificationStroke.Color = colors.borderColor
    notificationStroke.Parent = notificationFrame

    local lineFrame = Instance.new("Frame")
    lineFrame.Size = UDim2.new(0, 2, 1, -16)
    lineFrame.Position = UDim2.new(0, 8, 0, 8)
    lineFrame.BackgroundColor3 = colors["notification" .. notificationType .. "Color"] or colors.accentColor
    lineFrame.BorderSizePixel = 0
    lineFrame.ZIndex = 1502
    lineFrame.Parent = notificationFrame

    local lineCorner = Instance.new("UICorner")
    lineCorner.CornerRadius = UDim.new(0, 2)
    lineCorner.Parent = lineFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -24, 0, 14)
    titleLabel.Position = UDim2.new(0, 16, 0, 8)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = colors.textWhiteColor
    titleLabel.TextSize = 12
    titleLabel.Font = boldFont
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 1502
    titleLabel.Parent = notificationFrame

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -24, 0, 18)
    textLabel.Position = UDim2.new(0, 16, 0, 24)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = colors.textDarkColor
    textLabel.TextSize = 11
    textLabel.Font = mainFont
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.ZIndex = 1502
    textLabel.Parent = notificationFrame

    animateElement(notificationFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.45)

    task.delay(duration, function()
        local hideTween = animateElement(notificationFrame, {Position = UDim2.new(1, 270, 0, 0)}, 0.45)
        hideTween.Completed:Connect(function()
            notificationFrame:Destroy()
        end)
    end)
end

function LibraryApi:CreateWindow(windowName)
    local mainBackground = Instance.new("Frame")
    mainBackground.Size = UDim2.new(0, 720, 0, 480)
    mainBackground.Position = UDim2.new(0.5, -360, 0.5, -240)
    applyTheme(mainBackground, "BackgroundColor3", "mainBackground")
    mainBackground.BackgroundTransparency = 0.18
    mainBackground.BorderSizePixel = 0
    mainBackground.Active = true
    mainBackground.Parent = screenGui

    local uiScaleModifier = Instance.new("UIScale")
    uiScaleModifier.Parent = mainBackground
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 6)
    mainCorner.Parent = mainBackground
    
    local mainStroke = Instance.new("UIStroke")
    applyTheme(mainStroke, "Color", "borderColor")
    mainStroke.Parent = mainBackground

    applyAcrylicEffect(mainBackground, 0.88, UDim.new(0, 6))

    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36)
    applyTheme(topBar, "BackgroundColor3", "sidebarBackground")
    topBar.BackgroundTransparency = 0.21
    topBar.BorderSizePixel = 0
    topBar.Parent = mainBackground
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 6)
    topCorner.Parent = topBar

    local topHider = Instance.new("Frame")
    topHider.Size = UDim2.new(1, 0, 0, 6)
    topHider.Position = UDim2.new(0, 0, 1, -6)
    applyTheme(topHider, "BackgroundColor3", "sidebarBackground")
    topHider.BackgroundTransparency = 0.21
    topHider.BorderSizePixel = 0
    topHider.Parent = topBar

    local topBorder = Instance.new("Frame")
    topBorder.Size = UDim2.new(1, 0, 0, 1)
    topBorder.Position = UDim2.new(0, 0, 1, 0)
    applyTheme(topBorder, "BackgroundColor3", "borderColor")
    topBorder.BorderSizePixel = 0
    topBorder.Parent = topBar

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -20, 1, -2)
    titleLabel.Position = UDim2.new(0, 15, 0, 2)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowName
    applyTheme(titleLabel, "TextColor3", "textWhiteColor")
    titleLabel.TextSize = 13
    titleLabel.Font = boldFont
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar

    local sidebarFrame = Instance.new("Frame")
    sidebarFrame.Size = UDim2.new(0, 150, 1, -37)
    sidebarFrame.Position = UDim2.new(0, 0, 0, 37)
    applyTheme(sidebarFrame, "BackgroundColor3", "sidebarBackground")
    sidebarFrame.BackgroundTransparency = 0.21
    sidebarFrame.BorderSizePixel = 0
    sidebarFrame.Parent = mainBackground
    
    local sidebarCorner = Instance.new("UICorner")
    sidebarCorner.CornerRadius = UDim.new(0, 6)
    sidebarCorner.Parent = sidebarFrame

    local sidebarHiderRight = Instance.new("Frame")
    sidebarHiderRight.Size = UDim2.new(0, 6, 1, 0)
    sidebarHiderRight.Position = UDim2.new(1, -6, 0, 0)
    applyTheme(sidebarHiderRight, "BackgroundColor3", "sidebarBackground")
    sidebarHiderRight.BackgroundTransparency = 0.21
    sidebarHiderRight.BorderSizePixel = 0
    sidebarHiderRight.Parent = sidebarFrame

    local sidebarHiderTop = Instance.new("Frame")
    sidebarHiderTop.Size = UDim2.new(1, 0, 0, 6)
    applyTheme(sidebarHiderTop, "BackgroundColor3", "sidebarBackground")
    sidebarHiderTop.BackgroundTransparency = 0.21
    sidebarHiderTop.BorderSizePixel = 0
    sidebarHiderTop.Parent = sidebarFrame

    local sidebarBorder = Instance.new("Frame")
    sidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    sidebarBorder.Position = UDim2.new(1, 0, 0, 0)
    applyTheme(sidebarBorder, "BackgroundColor3", "borderColor")
    sidebarBorder.BorderSizePixel = 0
    sidebarBorder.Parent = sidebarFrame

    local tabScrollingFrame = Instance.new("ScrollingFrame")
    tabScrollingFrame.Size = UDim2.new(1, -10, 1, -60)
    tabScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    tabScrollingFrame.BackgroundTransparency = 1
    tabScrollingFrame.BorderSizePixel = 0
    tabScrollingFrame.ScrollBarThickness = 0
    tabScrollingFrame.Parent = sidebarFrame

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 4)
    tabLayout.Parent = tabScrollingFrame

    local profileButton = Instance.new("TextButton")
    profileButton.Size = UDim2.new(1, -10, 0, 45)
    profileButton.Position = UDim2.new(0, 5, 1, -50)
    profileButton.BackgroundTransparency = 1
    profileButton.Text = ""
    profileButton.Parent = sidebarFrame

    local profileCorner = Instance.new("UICorner")
    profileCorner.CornerRadius = UDim.new(0, 6)
    profileCorner.Parent = profileButton

    local avatarImage = Instance.new("ImageLabel")
    avatarImage.Size = UDim2.new(0, 30, 0, 30)
    avatarImage.Position = UDim2.new(0, 5, 0.5, -15)
    avatarImage.BackgroundTransparency = 1
    local success, thumb = pcall(function() return playersService:GetUserThumbnailAsync(playersService.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
    avatarImage.Image = success and thumb or ""
    avatarImage.Parent = profileButton

    local avatarUICorner = Instance.new("UICorner")
    avatarUICorner.CornerRadius = UDim.new(1, 0)
    avatarUICorner.Parent = avatarImage

    local avatarStroke = Instance.new("UIStroke")
    avatarStroke.Thickness = 1.5
    applyTheme(avatarStroke, "Color", "accentColor")
    avatarStroke.Parent = avatarImage

    local usernameLabel = Instance.new("TextLabel")
    usernameLabel.Size = UDim2.new(1, -45, 0, 14)
    usernameLabel.Position = UDim2.new(0, 42, 0, 8)
    usernameLabel.BackgroundTransparency = 1
    usernameLabel.Text = playersService.LocalPlayer.Name
    applyTheme(usernameLabel, "TextColor3", "textWhiteColor")
    usernameLabel.TextSize = 12
    usernameLabel.Font = boldFont
    usernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    usernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    usernameLabel.Parent = profileButton

    local settingsSubLabel = Instance.new("TextLabel")
    settingsSubLabel.Size = UDim2.new(1, -45, 0, 12)
    settingsSubLabel.Position = UDim2.new(0, 42, 0, 24)
    settingsSubLabel.BackgroundTransparency = 1
    settingsSubLabel.Text = "Settings"
    applyTheme(settingsSubLabel, "TextColor3", "textDarkColor")
    settingsSubLabel.TextSize = 11
    settingsSubLabel.Font = mainFont
    settingsSubLabel.TextXAlignment = Enum.TextXAlignment.Left
    settingsSubLabel.Parent = profileButton

    local contentAreaFrame = Instance.new("Frame")
    contentAreaFrame.Size = UDim2.new(1, -151, 1, -37)
    contentAreaFrame.Position = UDim2.new(0, 151, 0, 37)
    contentAreaFrame.BackgroundTransparency = 1
    contentAreaFrame.Parent = mainBackground

    local kbOuterFrame = Instance.new("Frame")
    kbOuterFrame.Size = UDim2.new(0, 180, 0, 200)
    kbOuterFrame.Position = UDim2.new(0, 20, 0.5, -100)
    applyTheme(kbOuterFrame, "BackgroundColor3", "mainBackground")
    kbOuterFrame.BackgroundTransparency = 0.18
    kbOuterFrame.Visible = false
    kbOuterFrame.Parent = screenGui

    local kbOuterCorner = Instance.new("UICorner")
    kbOuterCorner.CornerRadius = UDim.new(0, 6)
    kbOuterCorner.Parent = kbOuterFrame

    local kbOuterStroke = Instance.new("UIStroke")
    applyTheme(kbOuterStroke, "Color", "borderColor")
    kbOuterStroke.Parent = kbOuterFrame

    applyAcrylicEffect(kbOuterFrame, 0.88, UDim.new(0, 6))

    local kbHeader = Instance.new("TextLabel")
    kbHeader.Size = UDim2.new(1, 0, 0, 26)
    kbHeader.BackgroundTransparency = 1
    kbHeader.Text = "Keybinds"
    applyTheme(kbHeader, "TextColor3", "textWhiteColor")
    kbHeader.TextSize = 12
    kbHeader.Font = boldFont
    kbHeader.Parent = kbOuterFrame

    local kbHeaderLine = Instance.new("Frame")
    kbHeaderLine.Size = UDim2.new(1, -20, 0, 1)
    kbHeaderLine.Position = UDim2.new(0, 10, 0, 26)
    applyTheme(kbHeaderLine, "BackgroundColor3", "borderColor")
    kbHeaderLine.BorderSizePixel = 0
    kbHeaderLine.Parent = kbOuterFrame

    keybindListContainer = Instance.new("ScrollingFrame")
    keybindListContainer.Size = UDim2.new(1, -10, 1, -35)
    keybindListContainer.Position = UDim2.new(0, 5, 0, 30)
    keybindListContainer.BackgroundTransparency = 1
    keybindListContainer.BorderSizePixel = 0
    keybindListContainer.ScrollBarThickness = 0
    keybindListContainer.Parent = kbOuterFrame

    local kbLayout = Instance.new("UIListLayout")
    kbLayout.SortOrder = Enum.SortOrder.LayoutOrder
    kbLayout.Parent = keybindListContainer
    
    local function Update_Keybind_List_Size()
        keybindListContainer.CanvasSize = UDim2.new(0, 0, 0, kbLayout.AbsoluteContentSize.Y)
    end
    kbLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Keybind_List_Size)

    local kbDragStart, kbStartPos
    local kbDragging = false
    kbHeader.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            kbDragging = true
            kbDragStart = input.Position
            kbStartPos = kbOuterFrame.Position
        end
    end)
    userInputService.InputChanged:Connect(function(input)
        if kbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - kbDragStart
            kbOuterFrame.Position = UDim2.new(kbStartPos.X.Scale, kbStartPos.X.Offset + delta.X, kbStartPos.Y.Scale, kbStartPos.Y.Offset + delta.Y)
        end
    end)
    userInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            kbDragging = false
        end
    end)

    local mobileToggleButton = Instance.new("ImageButton")
    mobileToggleButton.Size = UDim2.new(0, 36, 0, 36)
    mobileToggleButton.Position = UDim2.new(0, 20, 0.5, -18)
    applyTheme(mobileToggleButton, "BackgroundColor3", "mainBackground")
    mobileToggleButton.BorderSizePixel = 0
    mobileToggleButton.ZIndex = 1000
    mobileToggleButton.Visible = true
    mobileToggleButton.Image = "rbxassetid://131244616689186"
    mobileToggleButton.Parent = screenGui

    local mobileToggleCorner = Instance.new("UICorner")
    mobileToggleCorner.CornerRadius = UDim.new(1, 0)
    mobileToggleCorner.Parent = mobileToggleButton

    local mobileToggleStroke = Instance.new("UIStroke")
    applyTheme(mobileToggleStroke, "Color", "accentColor")
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
        animateElement(mobileToggleButton, {Size = UDim2.new(0, 30, 0, 30)}, 0.25)
    end)
    
    mobileToggleButton.MouseButton1Up:Connect(function()
        animateElement(mobileToggleButton, {Size = UDim2.new(0, 36, 0, 36)}, 0.25)
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

    function windowContext:Tab_Create(tabName, iconId, isHidden)
        local tabData = {}

        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 32)
        applyTheme(tabButton, "BackgroundColor3", "elementHoverBackground")
        tabButton.BackgroundTransparency = 1
        tabButton.Text = ""
        tabButton.AutoButtonColor = false
        if not isHidden then
            tabButton.Parent = tabScrollingFrame
        end
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 4)
        buttonCorner.Parent = tabButton

        local tabLabel = Instance.new("TextLabel")
        tabLabel.BackgroundTransparency = 1
        tabLabel.Text = tabName
        applyTheme(tabLabel, "TextColor3", "textDarkColor")
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
            applyTheme(tabIcon, "ImageColor3", "textDarkColor")
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
        applyTheme(tabIndicator, "BackgroundColor3", "accentColor")
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
        applyTheme(pageScrollingFrame, "ScrollBarImageColor3", "accentColor")
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

        local function Update_Canvas_Size()
            local maxColumnHeight = math.max(leftColumnLayout.AbsoluteContentSize.Y, rightColumnLayout.AbsoluteContentSize.Y)
            pageScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, maxColumnHeight + 20)
            if not isHidden then
                tabScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, tabLayout.AbsoluteContentSize.Y + 10)
            end
        end

        leftColumnLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas_Size)
        rightColumnLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas_Size)
        if not isHidden then
            tabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Canvas_Size)
        end
        Update_Canvas_Size()

        function tabData:Activate()
            if windowContext.Active_Tab == tabData then return end
            if windowContext.Active_Tab then
                animateElement(windowContext.Active_Tab.Btn, {BackgroundTransparency = 1}, 0.3)
                pcall(function() windowContext.Active_Tab.Lbl.TextColor3 = colors.textDarkColor end)
                if windowContext.Active_Tab.Icon then pcall(function() windowContext.Active_Tab.Icon.ImageColor3 = colors.textDarkColor end) end
                animateElement(windowContext.Active_Tab.Ind, {Size = UDim2.new(0, 2, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.3)
                windowContext.Active_Tab.Page.Visible = false
            end
            windowContext.Active_Tab = tabData
            pageScrollingFrame.Visible = true
            animateElement(tabButton, {BackgroundTransparency = 0.11}, 0.3)
            pcall(function() tabLabel.TextColor3 = colors.textWhiteColor end)
            if tabData.Icon then pcall(function() tabData.Icon.ImageColor3 = colors.accentColor end) end
            animateElement(tabIndicator, {Size = UDim2.new(0, 2, 0, 16), Position = UDim2.new(0, 0, 0.5, -8)}, 0.3)
        end

        tabButton.MouseButton1Click:Connect(function() tabData:Activate() end)

        tabData.Btn = tabButton
        tabData.Lbl = tabLabel
        tabData.Ind = tabIndicator
        tabData.Page = pageScrollingFrame

        if not isHidden then
            table.insert(windowContext.Tabs, tabData)
            if #windowContext.Tabs == 1 then tabData:Activate() end
        end

        local function elementInjector(targetContainer)
            local elements = {}

            function elements:Label_Create(name, initialValue)
                local labelBg = Instance.new("Frame")
                labelBg.Size = UDim2.new(1, 0, 0, 26)
                applyTheme(labelBg, "BackgroundColor3", "elementBackground")
                labelBg.BackgroundTransparency = 0.21
                labelBg.Parent = targetContainer

                local labelCorner = Instance.new("UICorner")
                labelCorner.CornerRadius = UDim.new(0, 4)
                labelCorner.Parent = labelBg

                local labelStroke = Instance.new("UIStroke")
                applyTheme(labelStroke, "Color", "borderColor")
                labelStroke.Parent = labelBg

                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(0.5, 0, 1, 0)
                titleLabel.Position = UDim2.new(0, 8, 0, 0)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = name
                applyTheme(titleLabel, "TextColor3", "textDarkColor")
                titleLabel.TextSize = 12
                titleLabel.Font = mainFont
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.Parent = labelBg

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0.5, -8, 1, 0)
                valueLabel.Position = UDim2.new(0.5, 0, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = initialValue or ""
                applyTheme(valueLabel, "TextColor3", "textWhiteColor")
                valueLabel.TextSize = 12
                valueLabel.Font = boldFont
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = labelBg

                local api = {}
                function api:Set(text)
                    valueLabel.Text = tostring(text)
                end
                return api
            end

            function elements:Subtext_Create(text)
                local subtextLabel = Instance.new("TextLabel")
                subtextLabel.Size = UDim2.new(1, -10, 0, 14)
                subtextLabel.BackgroundTransparency = 1
                subtextLabel.Text = text
                applyTheme(subtextLabel, "TextColor3", "textDarkColor")
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
                applyTheme(checkboxFrame, "BackgroundColor3", LibraryApi.Flags[flag] and "accentColor" or "elementBackground")
                checkboxFrame.BackgroundTransparency = 0.21
                checkboxFrame.Parent = toggleButton
                
                local checkboxCorner = Instance.new("UICorner")
                checkboxCorner.CornerRadius = UDim.new(0, 3)
                checkboxCorner.Parent = checkboxFrame
                
                local checkboxStroke = Instance.new("UIStroke")
                applyTheme(checkboxStroke, "Color", LibraryApi.Flags[flag] and "accentColor" or "borderColor")
                checkboxStroke.Parent = checkboxFrame

                local toggleLabel = Instance.new("TextLabel")
                toggleLabel.Size = UDim2.new(1, -26, 1, 0)
                toggleLabel.Position = UDim2.new(0, 24, 0, 0)
                toggleLabel.BackgroundTransparency = 1
                toggleLabel.Text = name
                applyTheme(toggleLabel, "TextColor3", LibraryApi.Flags[flag] and "textWhiteColor" or "textDarkColor")
                toggleLabel.TextSize = 12
                toggleLabel.Font = mainFont
                toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                toggleLabel.Parent = toggleButton

                toggleButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not LibraryApi.Flags[flag] then pcall(function() checkboxStroke.Color = colors.borderLightColor end) end
                end)
                toggleButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not LibraryApi.Flags[flag] then pcall(function() checkboxStroke.Color = colors.borderColor end) end
                end)

                toggleButton.MouseButton1Click:Connect(function()
                    LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                    local newState = LibraryApi.Flags[flag]
                    applyTheme(checkboxFrame, "BackgroundColor3", newState and "accentColor" or "elementBackground")
                    applyTheme(checkboxStroke, "Color", newState and "accentColor" or "borderColor")
                    applyTheme(toggleLabel, "TextColor3", newState and "textWhiteColor" or "textDarkColor")
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
                applyTheme(sliderLabel, "TextColor3", "textWhiteColor")
                sliderLabel.TextSize = 12
                sliderLabel.Font = mainFont
                sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                sliderLabel.Parent = sliderFrame

                local valueTextBox = Instance.new("TextBox")
                valueTextBox.Size = UDim2.new(0, 40, 0, 14)
                valueTextBox.Position = UDim2.new(1, -42, 0, 0)
                valueTextBox.BackgroundTransparency = 1
                valueTextBox.Text = formatValue(LibraryApi.Flags[flag], step)
                applyTheme(valueTextBox, "TextColor3", "textWhiteColor")
                valueTextBox.TextSize = 12
                valueTextBox.Font = mainFont
                valueTextBox.TextXAlignment = Enum.TextXAlignment.Right
                valueTextBox.ClearTextOnFocus = false
                valueTextBox.Parent = sliderFrame

                local sliderBackground = Instance.new("TextButton")
                sliderBackground.Size = UDim2.new(1, -4, 0, 6)
                sliderBackground.Position = UDim2.new(0, 2, 0, 24)
                applyTheme(sliderBackground, "BackgroundColor3", "elementBackground")
                sliderBackground.BackgroundTransparency = 0.21
                sliderBackground.Text = ""
                sliderBackground.AutoButtonColor = false
                sliderBackground.Parent = sliderFrame
                
                local sliderBackgroundCorner = Instance.new("UICorner")
                sliderBackgroundCorner.CornerRadius = UDim.new(0, 3)
                sliderBackgroundCorner.Parent = sliderBackground
                
                local sliderBackgroundStroke = Instance.new("UIStroke")
                applyTheme(sliderBackgroundStroke, "Color", "borderColor")
                sliderBackgroundStroke.Parent = sliderBackground

                local sliderFill = Instance.new("Frame")
                local initialPercentage = (LibraryApi.Flags[flag] - min) / (max - min)
                sliderFill.Size = UDim2.new(initialPercentage, 0, 1, 0)
                applyTheme(sliderFill, "BackgroundColor3", "accentColor")
                sliderFill.Parent = sliderBackground
                
                local sliderFillCorner = Instance.new("UICorner")
                sliderFillCorner.CornerRadius = UDim.new(0, 3)
                sliderFillCorner.Parent = sliderFill

                local sliderKnob = Instance.new("Frame")
                sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                sliderKnob.Size = UDim2.new(0, 10, 0, 10)
                sliderKnob.Position = UDim2.new(initialPercentage, 0, 0.5, 0)
                applyTheme(sliderKnob, "BackgroundColor3", "textWhiteColor")
                sliderKnob.ZIndex = 2
                sliderKnob.Parent = sliderBackground
                local sliderKnobCorner = Instance.new("UICorner"); sliderKnobCorner.CornerRadius = UDim.new(1, 0); sliderKnobCorner.Parent = sliderKnob
                local sliderKnobStroke = Instance.new("UIStroke"); applyTheme(sliderKnobStroke, "Color", "borderColor"); sliderKnobStroke.Parent = sliderKnob

                sliderBackground.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    pcall(function() sliderBackgroundStroke.Color = colors.borderLightColor end)
                end)
                sliderBackground.MouseLeave:Connect(function()
                    showTooltip("")
                    pcall(function() sliderBackgroundStroke.Color = colors.borderColor end)
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
                applyTheme(rangeSliderLabel, "TextColor3", "textWhiteColor")
                rangeSliderLabel.TextSize = 12
                rangeSliderLabel.Font = mainFont
                rangeSliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                rangeSliderLabel.Parent = rangeSliderFrame

                local valueLabel = Instance.new("TextLabel")
                valueLabel.Size = UDim2.new(0, 80, 0, 14)
                valueLabel.Position = UDim2.new(1, -82, 0, 0)
                valueLabel.BackgroundTransparency = 1
                valueLabel.Text = formatValue(LibraryApi.Flags[flag].Min, step) .. " - " .. formatValue(LibraryApi.Flags[flag].Max, step)
                applyTheme(valueLabel, "TextColor3", "textWhiteColor")
                valueLabel.TextSize = 12
                valueLabel.Font = mainFont
                valueLabel.TextXAlignment = Enum.TextXAlignment.Right
                valueLabel.Parent = rangeSliderFrame

                local rangeSliderBackground = Instance.new("TextButton")
                rangeSliderBackground.Size = UDim2.new(1, -4, 0, 6)
                rangeSliderBackground.Position = UDim2.new(0, 2, 0, 24)
                applyTheme(rangeSliderBackground, "BackgroundColor3", "elementBackground")
                rangeSliderBackground.BackgroundTransparency = 0.21
                rangeSliderBackground.Text = ""
                rangeSliderBackground.AutoButtonColor = false
                rangeSliderBackground.Parent = rangeSliderFrame
                
                local rangeSliderBackgroundCorner = Instance.new("UICorner")
                rangeSliderBackgroundCorner.CornerRadius = UDim.new(0, 3)
                rangeSliderBackgroundCorner.Parent = rangeSliderBackground
                
                local rangeSliderBackgroundStroke = Instance.new("UIStroke")
                applyTheme(rangeSliderBackgroundStroke, "Color", "borderColor")
                rangeSliderBackgroundStroke.Parent = rangeSliderBackground

                local rangeSliderFill = Instance.new("Frame")
                applyTheme(rangeSliderFill, "BackgroundColor3", "accentColor")
                rangeSliderFill.Parent = rangeSliderBackground
                
                local rangeSliderFillCorner = Instance.new("UICorner")
                rangeSliderFillCorner.CornerRadius = UDim.new(0, 3)
                rangeSliderFillCorner.Parent = rangeSliderFill

                local minRangeKnob = Instance.new("Frame")
                minRangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                minRangeKnob.Size = UDim2.new(0, 10, 0, 10)
                applyTheme(minRangeKnob, "BackgroundColor3", "textWhiteColor")
                minRangeKnob.ZIndex = 2
                minRangeKnob.Parent = rangeSliderBackground
                local minRangeKnobCorner = Instance.new("UICorner"); minRangeKnobCorner.CornerRadius = UDim.new(1, 0); minRangeKnobCorner.Parent = minRangeKnob
                local minRangeKnobStroke = Instance.new("UIStroke"); applyTheme(minRangeKnobStroke, "Color", "borderColor"); minRangeKnobStroke.Parent = minRangeKnob

                local maxRangeKnob = Instance.new("Frame")
                maxRangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                maxRangeKnob.Size = UDim2.new(0, 10, 0, 10)
                applyTheme(maxRangeKnob, "BackgroundColor3", "textWhiteColor")
                maxRangeKnob.ZIndex = 2
                maxRangeKnob.Parent = rangeSliderBackground
                local maxRangeKnobCorner = Instance.new("UICorner"); maxRangeKnobCorner.CornerRadius = UDim.new(1, 0); maxRangeKnobCorner.Parent = maxRangeKnob
                local maxRangeKnobStroke = Instance.new("UIStroke"); applyTheme(maxRangeKnobStroke, "Color", "borderColor"); maxRangeKnobStroke.Parent = maxRangeKnob

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
                    pcall(function() rangeSliderBackgroundStroke.Color = colors.borderLightColor end)
                end)
                rangeSliderBackground.MouseLeave:Connect(function()
                    showTooltip("")
                    pcall(function() rangeSliderBackgroundStroke.Color = colors.borderColor end)
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
                applyTheme(textboxLabel, "TextColor3", "textWhiteColor")
                textboxLabel.TextSize = 12
                textboxLabel.Font = mainFont
                textboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                textboxLabel.Parent = textboxFrame

                local textboxInputBackground = Instance.new("Frame")
                textboxInputBackground.Size = UDim2.new(0, 110, 0, 24)
                textboxInputBackground.Position = UDim2.new(1, -112, 0.5, -12)
                applyTheme(textboxInputBackground, "BackgroundColor3", "elementBackground")
                textboxInputBackground.BackgroundTransparency = 0.21
                textboxInputBackground.Parent = textboxFrame
                
                local textboxInputBackgroundCorner = Instance.new("UICorner")
                textboxInputBackgroundCorner.CornerRadius = UDim.new(0, 4)
                textboxInputBackgroundCorner.Parent = textboxInputBackground
                
                local textboxInputBackgroundStroke = Instance.new("UIStroke")
                applyTheme(textboxInputBackgroundStroke, "Color", "borderColor")
                textboxInputBackgroundStroke.Parent = textboxInputBackground

                local inputTextBox = Instance.new("TextBox")
                inputTextBox.Size = UDim2.new(1, -10, 1, 0)
                inputTextBox.Position = UDim2.new(0, 5, 0, 0)
                inputTextBox.BackgroundTransparency = 1
                inputTextBox.Text = LibraryApi.Flags[flag]
                applyTheme(inputTextBox, "TextColor3", "textDarkColor")
                inputTextBox.TextSize = 12
                inputTextBox.Font = mainFont
                inputTextBox.ClearTextOnFocus = false
                inputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                inputTextBox.ClipsDescendants = true
                inputTextBox.Parent = textboxInputBackground

                inputTextBox.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    pcall(function() textboxInputBackgroundStroke.Color = colors.borderLightColor end)
                end)
                inputTextBox.MouseLeave:Connect(function()
                    showTooltip("")
                    pcall(function() textboxInputBackgroundStroke.Color = colors.borderColor end)
                end)

                inputTextBox.Focused:Connect(function()
                    pcall(function() textboxInputBackgroundStroke.Color = colors.accentColor end)
                    pcall(function() inputTextBox.TextColor3 = colors.textWhiteColor end)
                end)

                inputTextBox.FocusLost:Connect(function()
                    pcall(function() textboxInputBackgroundStroke.Color = colors.borderColor end)
                    pcall(function() inputTextBox.TextColor3 = colors.textDarkColor end)
                    LibraryApi.Flags[flag] = inputTextBox.Text
                    if callback then task.spawn(callback, inputTextBox.Text) end
                end)
            end

            function elements:Keybind_Create(name, flag, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or Enum.KeyCode.Unknown)
                if LibraryApi.Flags[flag] ~= Enum.KeyCode.Unknown then
                    activeKeybinds[name] = LibraryApi.Flags[flag].Name
                    Refresh_Keybinds_List()
                end
                local isListening = false

                local keybindFrame = Instance.new("Frame")
                keybindFrame.Size = UDim2.new(1, 0, 0, 30)
                keybindFrame.BackgroundTransparency = 1
                keybindFrame.Parent = targetContainer

                local keybindIcon = Instance.new("ImageLabel")
                keybindIcon.Size = UDim2.new(0, 18, 0, 18)
                keybindIcon.Position = UDim2.new(0, 6, 0.5, -9)
                keybindIcon.BackgroundTransparency = 1
                keybindIcon.Image = "rbxassetid://104798010403294"
                applyTheme(keybindIcon, "ImageColor3", "textWhiteColor")
                keybindIcon.Parent = keybindFrame

                local keybindLabel = Instance.new("TextLabel")
                keybindLabel.Size = UDim2.new(1, -100, 1, 0)
                keybindLabel.Position = UDim2.new(0, 28, 0, 0)
                keybindLabel.BackgroundTransparency = 1
                keybindLabel.Text = name
                applyTheme(keybindLabel, "TextColor3", "textWhiteColor")
                keybindLabel.TextSize = 12
                keybindLabel.Font = mainFont
                keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                keybindLabel.Parent = keybindFrame

                local keybindButton = Instance.new("TextButton")
                keybindButton.Size = UDim2.new(0, 70, 0, 22)
                keybindButton.Position = UDim2.new(1, -74, 0.5, -11)
                applyTheme(keybindButton, "BackgroundColor3", "elementBackground")
                keybindButton.BackgroundTransparency = 0.21
                keybindButton.Text = LibraryApi.Flags[flag] == Enum.KeyCode.Unknown and "[ None ]" or "[ " .. LibraryApi.Flags[flag].Name .. " ]"
                applyTheme(keybindButton, "TextColor3", "textDarkColor")
                keybindButton.TextSize = 11
                keybindButton.Font = boldFont
                keybindButton.AutoButtonColor = false
                keybindButton.Parent = keybindFrame

                local keybindButtonCorner = Instance.new("UICorner")
                keybindButtonCorner.CornerRadius = UDim.new(0, 4)
                keybindButtonCorner.Parent = keybindButton

                local keybindButtonStroke = Instance.new("UIStroke")
                applyTheme(keybindButtonStroke, "Color", "borderColor")
                keybindButtonStroke.Parent = keybindButton

                keybindButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not isListening then pcall(function() keybindButtonStroke.Color = colors.borderLightColor end) end
                end)
                keybindButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not isListening then pcall(function() keybindButtonStroke.Color = colors.borderColor end) end
                end)

                keybindButton.MouseButton1Click:Connect(function()
                    isListening = true
                    keybindButton.Text = "[ ... ]"
                    pcall(function() keybindButtonStroke.Color = colors.accentColor end)
                    pcall(function() keybindButton.TextColor3 = colors.textWhiteColor end)
                end)

                userInputService.InputBegan:Connect(function(input)
                    if isListening then
                        if input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode ~= Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = input.KeyCode
                            keybindButton.Text = "[ " .. input.KeyCode.Name .. " ]"
                            activeKeybinds[name] = input.KeyCode.Name
                        elseif input.KeyCode == Enum.KeyCode.Escape then
                            LibraryApi.Flags[flag] = Enum.KeyCode.Unknown
                            keybindButton.Text = "[ None ]"
                            activeKeybinds[name] = nil
                        end
                        isListening = false
                        Refresh_Keybinds_List()
                        pcall(function() keybindButtonStroke.Color = colors.borderColor end)
                        pcall(function() keybindButton.TextColor3 = colors.textDarkColor end)
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
                applyTheme(dropdownLabel, "TextColor3", "textWhiteColor")
                dropdownLabel.TextSize = 12
                dropdownLabel.Font = mainFont
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownMainButton = Instance.new("TextButton")
                dropdownMainButton.Size = UDim2.new(1, -4, 0, 24)
                dropdownMainButton.Position = UDim2.new(0, 2, 0, 20)
                applyTheme(dropdownMainButton, "BackgroundColor3", "elementBackground")
                dropdownMainButton.BackgroundTransparency = 0.21
                dropdownMainButton.Text = ""
                dropdownMainButton.AutoButtonColor = false
                dropdownMainButton.Parent = dropdownFrame
                
                local dropdownMainButtonCorner = Instance.new("UICorner")
                dropdownMainButtonCorner.CornerRadius = UDim.new(0, 4)
                dropdownMainButtonCorner.Parent = dropdownMainButton
                
                local dropdownMainButtonStroke = Instance.new("UIStroke")
                applyTheme(dropdownMainButtonStroke, "Color", "borderColor")
                dropdownMainButtonStroke.Parent = dropdownMainButton

                local selectedOptionLabel = Instance.new("TextLabel")
                selectedOptionLabel.Size = UDim2.new(1, -30, 1, 0)
                selectedOptionLabel.Position = UDim2.new(0, 8, 0, 0)
                selectedOptionLabel.BackgroundTransparency = 1
                selectedOptionLabel.Text = LibraryApi.Flags[flag]
                applyTheme(selectedOptionLabel, "TextColor3", "textDarkColor")
                selectedOptionLabel.TextSize = 12
                selectedOptionLabel.Font = mainFont
                selectedOptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                selectedOptionLabel.Parent = dropdownMainButton

                local dropdownArrowIcon = Instance.new("ImageLabel")
                dropdownArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                dropdownArrowIcon.Position = UDim2.new(1, -22, 0.5, -7)
                dropdownArrowIcon.BackgroundTransparency = 1
                dropdownArrowIcon.Image = "rbxassetid://6031090656"
                applyTheme(dropdownArrowIcon, "ImageColor3", "textDarkColor")
                dropdownArrowIcon.Parent = dropdownMainButton

                local dropdownOptionListFrame = Instance.new("ScrollingFrame")
                dropdownOptionListFrame.Size = UDim2.new(1, -4, 0, 0)
                dropdownOptionListFrame.Position = UDim2.new(0, 2, 0, 48)
                applyTheme(dropdownOptionListFrame, "BackgroundColor3", "elementBackground")
                dropdownOptionListFrame.BackgroundTransparency = 0.21
                dropdownOptionListFrame.BorderSizePixel = 0
                dropdownOptionListFrame.ScrollBarThickness = 2
                applyTheme(dropdownOptionListFrame, "ScrollBarImageColor3", "accentColor")
                dropdownOptionListFrame.ClipsDescendants = true
                dropdownOptionListFrame.Parent = dropdownFrame
                
                local dropdownOptionListCorner = Instance.new("UICorner")
                dropdownOptionListCorner.CornerRadius = UDim.new(0, 4)
                dropdownOptionListCorner.Parent = dropdownOptionListFrame
                
                local dropdownOptionListStroke = Instance.new("UIStroke")
                applyTheme(dropdownOptionListStroke, "Color", "borderColor")
                dropdownOptionListStroke.Transparency = 1
                dropdownOptionListStroke.Parent = dropdownOptionListFrame

                local dropdownOptionListLayout = Instance.new("UIListLayout")
                dropdownOptionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownOptionListLayout.Parent = dropdownOptionListFrame

                local function toggleDropdownState()
                    isDropdownOpen = not isDropdownOpen
                    local count = 0
                    for _, c in ipairs(dropdownOptionListFrame:GetChildren()) do if c:IsA("TextButton") then count = count + 1 end end
                    local maxListHeight = math.min(count * 24, 120)
                    local targetListHeight = isDropdownOpen and maxListHeight or 0
                    pcall(function() dropdownMainButtonStroke.Color = isDropdownOpen and colors.accentColor or colors.borderColor end)
                    animateElement(dropdownArrowIcon, {Rotation = isDropdownOpen and 180 or 0}, 0.3)
                    pcall(function() dropdownArrowIcon.ImageColor3 = isDropdownOpen and colors.accentColor or colors.textDarkColor end)
                    animateElement(dropdownOptionListFrame, {Size = UDim2.new(1, -4, 0, targetListHeight)}, 0.3)
                    animateElement(dropdownOptionListStroke, {Transparency = isDropdownOpen and 0 or 1}, 0.3)
                    animateElement(dropdownFrame, {Size = UDim2.new(1, 0, 0, 46 + targetListHeight + (isDropdownOpen and 4 or 0))}, 0.3)
                end

                dropdownMainButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not isDropdownOpen then pcall(function() dropdownMainButtonStroke.Color = colors.borderLightColor end) end
                end)
                dropdownMainButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not isDropdownOpen then pcall(function() dropdownMainButtonStroke.Color = colors.borderColor end) end
                end)
                dropdownMainButton.MouseButton1Click:Connect(toggleDropdownState)

                local function populate(opts)
                    for _, child in ipairs(dropdownOptionListFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, option in ipairs(opts) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Size = UDim2.new(1, 0, 0, 24)
                        applyTheme(optionButton, "BackgroundColor3", "elementHoverBackground")
                        optionButton.BackgroundTransparency = 1
                        optionButton.Text = ""
                        optionButton.Parent = dropdownOptionListFrame

                        local optionLabel = Instance.new("TextLabel")
                        optionLabel.Size = UDim2.new(1, -20, 1, 0)
                        optionLabel.Position = UDim2.new(0, 8, 0, 0)
                        optionLabel.BackgroundTransparency = 1
                        optionLabel.Text = option
                        applyTheme(optionLabel, "TextColor3", LibraryApi.Flags[flag] == option and "accentColor" or "textDarkColor")
                        optionLabel.TextSize = 12
                        optionLabel.Font = mainFont
                        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                        optionLabel.Parent = optionButton

                        optionButton.MouseEnter:Connect(function() 
                            animateElement(optionButton, {BackgroundTransparency = 0.21}, 0.25)
                            if LibraryApi.Flags[flag] ~= option then
                                pcall(function() optionLabel.TextColor3 = colors.textWhiteColor end) 
                            end
                        end)
                        optionButton.MouseLeave:Connect(function()
                            animateElement(optionButton, {BackgroundTransparency = 1}, 0.25)
                            if LibraryApi.Flags[flag] ~= option then
                                pcall(function() optionLabel.TextColor3 = colors.textDarkColor end)
                            end
                        end)

                        optionButton.MouseButton1Click:Connect(function()
                            LibraryApi.Flags[flag] = option
                            selectedOptionLabel.Text = option
                            toggleDropdownState()
                            for _, child in ipairs(dropdownOptionListFrame:GetChildren()) do
                                if child:IsA("TextButton") then
                                    pcall(function() child:FindFirstChildOfClass("TextLabel").TextColor3 = colors.textDarkColor end)
                                end
                            end
                            pcall(function() optionLabel.TextColor3 = colors.accentColor end)
                            if callback then task.spawn(callback, option) end
                        end)
                    end
                    dropdownOptionListFrame.CanvasSize = UDim2.new(0, 0, 0, #opts * 24)
                end
                populate(options)

                local api = {}
                function api:Refresh(newOpts)
                    populate(newOpts)
                    local found = false
                    for _, o in ipairs(newOpts) do if o == LibraryApi.Flags[flag] then found = true break end end
                    if not found then
                        LibraryApi.Flags[flag] = newOpts[1] or ""
                        selectedOptionLabel.Text = LibraryApi.Flags[flag]
                    end
                end
                return api
            end

            function elements:MultiDropdown_Create(name, flag, options, default, tooltip, callback)
                LibraryApi.Flags[flag] = LibraryApi.Flags[flag] ~= nil and LibraryApi.Flags[flag] or (default or {})
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
                applyTheme(dropdownLabel, "TextColor3", "textWhiteColor")
                dropdownLabel.TextSize = 12
                dropdownLabel.Font = mainFont
                dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                dropdownLabel.Parent = dropdownFrame

                local dropdownMainButton = Instance.new("TextButton")
                dropdownMainButton.Size = UDim2.new(1, -4, 0, 24)
                dropdownMainButton.Position = UDim2.new(0, 2, 0, 20)
                applyTheme(dropdownMainButton, "BackgroundColor3", "elementBackground")
                dropdownMainButton.BackgroundTransparency = 0.21
                dropdownMainButton.Text = ""
                dropdownMainButton.AutoButtonColor = false
                dropdownMainButton.Parent = dropdownFrame
                
                local dropdownMainButtonCorner = Instance.new("UICorner")
                dropdownMainButtonCorner.CornerRadius = UDim.new(0, 4)
                dropdownMainButtonCorner.Parent = dropdownMainButton
                
                local dropdownMainButtonStroke = Instance.new("UIStroke")
                applyTheme(dropdownMainButtonStroke, "Color", "borderColor")
                dropdownMainButtonStroke.Parent = dropdownMainButton

                local selectedOptionLabel = Instance.new("TextLabel")
                selectedOptionLabel.Size = UDim2.new(1, -30, 1, 0)
                selectedOptionLabel.Position = UDim2.new(0, 8, 0, 0)
                selectedOptionLabel.BackgroundTransparency = 1
                
                local function updateSelectedText()
                    if #LibraryApi.Flags[flag] == 0 then
                        selectedOptionLabel.Text = "None"
                    else
                        selectedOptionLabel.Text = table.concat(LibraryApi.Flags[flag], ", ")
                    end
                end
                updateSelectedText()
                
                applyTheme(selectedOptionLabel, "TextColor3", "textDarkColor")
                selectedOptionLabel.TextSize = 12
                selectedOptionLabel.Font = mainFont
                selectedOptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                selectedOptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
                selectedOptionLabel.Parent = dropdownMainButton

                local dropdownArrowIcon = Instance.new("ImageLabel")
                dropdownArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                dropdownArrowIcon.Position = UDim2.new(1, -22, 0.5, -7)
                dropdownArrowIcon.BackgroundTransparency = 1
                dropdownArrowIcon.Image = "rbxassetid://6031090656"
                applyTheme(dropdownArrowIcon, "ImageColor3", "textDarkColor")
                dropdownArrowIcon.Parent = dropdownMainButton

                local dropdownOptionListFrame = Instance.new("ScrollingFrame")
                dropdownOptionListFrame.Size = UDim2.new(1, -4, 0, 0)
                dropdownOptionListFrame.Position = UDim2.new(0, 2, 0, 48)
                applyTheme(dropdownOptionListFrame, "BackgroundColor3", "elementBackground")
                dropdownOptionListFrame.BackgroundTransparency = 0.21
                dropdownOptionListFrame.BorderSizePixel = 0
                dropdownOptionListFrame.ScrollBarThickness = 2
                applyTheme(dropdownOptionListFrame, "ScrollBarImageColor3", "accentColor")
                dropdownOptionListFrame.ClipsDescendants = true
                dropdownOptionListFrame.Parent = dropdownFrame
                
                local dropdownOptionListCorner = Instance.new("UICorner")
                dropdownOptionListCorner.CornerRadius = UDim.new(0, 4)
                dropdownOptionListCorner.Parent = dropdownOptionListFrame
                
                local dropdownOptionListStroke = Instance.new("UIStroke")
                applyTheme(dropdownOptionListStroke, "Color", "borderColor")
                dropdownOptionListStroke.Transparency = 1
                dropdownOptionListStroke.Parent = dropdownOptionListFrame

                local dropdownOptionListLayout = Instance.new("UIListLayout")
                dropdownOptionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                dropdownOptionListLayout.Parent = dropdownOptionListFrame

                local function toggleDropdownState()
                    isDropdownOpen = not isDropdownOpen
                    local count = 0
                    for _, c in ipairs(dropdownOptionListFrame:GetChildren()) do if c:IsA("TextButton") then count = count + 1 end end
                    local maxListHeight = math.min(count * 24, 120)
                    local targetListHeight = isDropdownOpen and maxListHeight or 0
                    pcall(function() dropdownMainButtonStroke.Color = isDropdownOpen and colors.accentColor or colors.borderColor end)
                    animateElement(dropdownArrowIcon, {Rotation = isDropdownOpen and 180 or 0}, 0.3)
                    pcall(function() dropdownArrowIcon.ImageColor3 = isDropdownOpen and colors.accentColor or colors.textDarkColor end)
                    animateElement(dropdownOptionListFrame, {Size = UDim2.new(1, -4, 0, targetListHeight)}, 0.3)
                    animateElement(dropdownOptionListStroke, {Transparency = isDropdownOpen and 0 or 1}, 0.3)
                    animateElement(dropdownFrame, {Size = UDim2.new(1, 0, 0, 46 + targetListHeight + (isDropdownOpen and 4 or 0))}, 0.3)
                end

                dropdownMainButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not isDropdownOpen then pcall(function() dropdownMainButtonStroke.Color = colors.borderLightColor end) end
                end)
                dropdownMainButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not isDropdownOpen then pcall(function() dropdownMainButtonStroke.Color = colors.borderColor end) end
                end)
                dropdownMainButton.MouseButton1Click:Connect(toggleDropdownState)

                local function populate(opts)
                    for _, child in ipairs(dropdownOptionListFrame:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    for _, option in ipairs(opts) do
                        local optionButton = Instance.new("TextButton")
                        optionButton.Size = UDim2.new(1, 0, 0, 24)
                        applyTheme(optionButton, "BackgroundColor3", "elementHoverBackground")
                        optionButton.BackgroundTransparency = 1
                        optionButton.Text = ""
                        optionButton.Parent = dropdownOptionListFrame

                        local isSelected = false
                        for _, v in pairs(LibraryApi.Flags[flag]) do
                            if v == option then isSelected = true break end
                        end

                        local optionLabel = Instance.new("TextLabel")
                        optionLabel.Size = UDim2.new(1, -20, 1, 0)
                        optionLabel.Position = UDim2.new(0, 8, 0, 0)
                        optionLabel.BackgroundTransparency = 1
                        optionLabel.Text = option
                        applyTheme(optionLabel, "TextColor3", isSelected and "accentColor" or "textDarkColor")
                        optionLabel.TextSize = 12
                        optionLabel.Font = mainFont
                        optionLabel.TextXAlignment = Enum.TextXAlignment.Left
                        optionLabel.Parent = optionButton

                        optionButton.MouseEnter:Connect(function() 
                            animateElement(optionButton, {BackgroundTransparency = 0.21}, 0.25)
                            isSelected = table.find(LibraryApi.Flags[flag], option) ~= nil
                            if not isSelected then
                                pcall(function() optionLabel.TextColor3 = colors.textWhiteColor end) 
                            end
                        end)
                        optionButton.MouseLeave:Connect(function()
                            animateElement(optionButton, {BackgroundTransparency = 1}, 0.25)
                            isSelected = table.find(LibraryApi.Flags[flag], option) ~= nil
                            if not isSelected then
                                pcall(function() optionLabel.TextColor3 = colors.textDarkColor end)
                            end
                        end)

                        optionButton.MouseButton1Click:Connect(function()
                            local idx = table.find(LibraryApi.Flags[flag], option)
                            if idx then
                                table.remove(LibraryApi.Flags[flag], idx)
                                pcall(function() optionLabel.TextColor3 = colors.textWhiteColor end)
                            else
                                table.insert(LibraryApi.Flags[flag], option)
                                pcall(function() optionLabel.TextColor3 = colors.accentColor end)
                            end
                            updateSelectedText()
                            if callback then task.spawn(callback, LibraryApi.Flags[flag]) end
                        end)
                    end
                    dropdownOptionListFrame.CanvasSize = UDim2.new(0, 0, 0, #opts * 24)
                end
                populate(options)

                local api = {}
                function api:Refresh(newOpts)
                    populate(newOpts)
                end
                return api
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
                applyTheme(colorPickerLabel, "TextColor3", "textWhiteColor")
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
                applyTheme(colorPreviewButtonStroke, "Color", "borderColor")
                colorPreviewButtonStroke.Parent = colorPreviewButton

                local expandedPickerFrame = Instance.new("Frame")
                expandedPickerFrame.Size = UDim2.new(1, -4, 0, 190)
                expandedPickerFrame.Position = UDim2.new(0, 2, 0, 28)
                applyTheme(expandedPickerFrame, "BackgroundColor3", "elementBackground")
                expandedPickerFrame.BackgroundTransparency = 0.21
                expandedPickerFrame.Parent = colorPickerFrame
                
                local expandedPickerCorner = Instance.new("UICorner")
                expandedPickerCorner.CornerRadius = UDim.new(0, 4)
                expandedPickerCorner.Parent = expandedPickerFrame
                
                local expandedPickerStroke = Instance.new("UIStroke")
                applyTheme(expandedPickerStroke, "Color", "borderColor")
                expandedPickerStroke.Parent = expandedPickerFrame

                local saturationValueMap = Instance.new("ImageButton")
                saturationValueMap.Size = UDim2.new(1, -16, 0, 150)
                saturationValueMap.Position = UDim2.new(0, 8, 0, 8)
                saturationValueMap.Image = "rbxassetid://4155801252"
                saturationValueMap.ImageColor3 = Color3.fromHSV(hue, 1, 1)
                saturationValueMap.AutoButtonColor = false
                saturationValueMap.Parent = expandedPickerFrame
                local saturationValueMapCorner = Instance.new("UICorner"); saturationValueMapCorner.CornerRadius = UDim.new(0, 3); saturationValueMapCorner.Parent = saturationValueMap
                local saturationValueMapStroke = Instance.new("UIStroke"); applyTheme(saturationValueMapStroke, "Color", "borderColor"); saturationValueMapStroke.Parent = saturationValueMap

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
                local hueMapStroke = Instance.new("UIStroke"); applyTheme(hueMapStroke, "Color", "borderColor"); hueMapStroke.Parent = hueMap

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
                    if not isColorPickerOpen then pcall(function() colorPreviewButtonStroke.Color = colors.borderLightColor end) end
                end)
                colorPreviewButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not isColorPickerOpen then pcall(function() colorPreviewButtonStroke.Color = colors.borderColor end) end
                end)

                colorPreviewButton.MouseButton1Click:Connect(function()
                    isColorPickerOpen = not isColorPickerOpen
                    pcall(function() colorPreviewButtonStroke.Color = isColorPickerOpen and colors.accentColor or colors.borderColor end)
                    animateElement(colorPickerFrame, {Size = UDim2.new(1, 0, 0, isColorPickerOpen and 224 or 24)}, 0.3)
                end)
                
                local api = {}
                function api:Set(col)
                    hue, saturation, value = col:ToHSV()
                    updateColorPickerState()
                end
                return api
            end

            function elements:Button_Create(name, tooltip, callback)
                local buttonFrame = Instance.new("Frame")
                buttonFrame.Size = UDim2.new(1, 0, 0, 30)
                buttonFrame.BackgroundTransparency = 1
                buttonFrame.Parent = targetContainer

                local actionButton = Instance.new("TextButton")
                actionButton.Size = UDim2.new(1, -4, 1, 0)
                actionButton.Position = UDim2.new(0, 2, 0, 0)
                applyTheme(actionButton, "BackgroundColor3", "elementBackground")
                actionButton.BackgroundTransparency = 0.21
                actionButton.Text = name
                applyTheme(actionButton, "TextColor3", "textWhiteColor")
                actionButton.TextSize = 12
                actionButton.Font = boldFont
                actionButton.AutoButtonColor = false
                actionButton.Parent = buttonFrame
                
                local actionButtonCorner = Instance.new("UICorner")
                actionButtonCorner.CornerRadius = UDim.new(0, 4)
                actionButtonCorner.Parent = actionButton
                
                local actionButtonStroke = Instance.new("UIStroke")
                applyTheme(actionButtonStroke, "Color", "borderColor")
                actionButtonStroke.Parent = actionButton

                actionButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    pcall(function() actionButton.BackgroundColor3 = colors.elementHoverBackground end)
                    pcall(function() actionButtonStroke.Color = colors.accentColor end)
                    pcall(function() actionButton.TextColor3 = colors.accentColor end)
                end)
                actionButton.MouseLeave:Connect(function()
                    showTooltip("")
                    pcall(function() actionButton.BackgroundColor3 = colors.elementBackground end)
                    pcall(function() actionButtonStroke.Color = colors.borderColor end)
                    pcall(function() actionButton.TextColor3 = colors.textWhiteColor end)
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
                applyTheme(subButtonAction, "BackgroundColor3", "sectionBackground")
                subButtonAction.BackgroundTransparency = 0.21
                subButtonAction.Text = name
                applyTheme(subButtonAction, "TextColor3", "textDarkColor")
                subButtonAction.TextSize = 11
                subButtonAction.Font = mainFont
                subButtonAction.AutoButtonColor = false
                subButtonAction.Parent = subButtonFrame
                
                local subButtonCorner = Instance.new("UICorner")
                subButtonCorner.CornerRadius = UDim.new(0, 3)
                subButtonCorner.Parent = subButtonAction
                
                local subButtonStroke = Instance.new("UIStroke")
                applyTheme(subButtonStroke, "Color", "borderColor")
                subButtonStroke.Parent = subButtonAction

                subButtonAction.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    pcall(function() subButtonAction.BackgroundColor3 = colors.elementBackground end)
                    pcall(function() subButtonStroke.Color = colors.borderLightColor end)
                    pcall(function() subButtonAction.TextColor3 = colors.textWhiteColor end)
                end)
                subButtonAction.MouseLeave:Connect(function()
                    showTooltip("")
                    pcall(function() subButtonAction.BackgroundColor3 = colors.sectionBackground end)
                    pcall(function() subButtonStroke.Color = colors.borderColor end)
                    pcall(function() subButtonAction.TextColor3 = colors.textDarkColor end)
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
                applyTheme(moduleToggleButton, "BackgroundColor3", "elementBackground")
                moduleToggleButton.BackgroundTransparency = 0.21
                moduleToggleButton.Text = ""
                moduleToggleButton.AutoButtonColor = false
                moduleToggleButton.Parent = moduleFrame
                
                local moduleToggleButtonCorner = Instance.new("UICorner")
                moduleToggleButtonCorner.CornerRadius = UDim.new(0, 6)
                moduleToggleButtonCorner.Parent = moduleToggleButton
                
                local moduleToggleButtonStroke = Instance.new("UIStroke")
                applyTheme(moduleToggleButtonStroke, "Color", LibraryApi.Flags[flag] and "accentColor" or "borderColor")
                moduleToggleButtonStroke.Parent = moduleToggleButton

                local moduleCheckboxFrame = Instance.new("Frame")
                moduleCheckboxFrame.Size = UDim2.new(0, 16, 0, 16)
                moduleCheckboxFrame.Position = UDim2.new(0, 14, 0.5, -8)
                applyTheme(moduleCheckboxFrame, "BackgroundColor3", LibraryApi.Flags[flag] and "accentColor" or "sectionBackground")
                moduleCheckboxFrame.BackgroundTransparency = 0.21
                moduleCheckboxFrame.Parent = moduleToggleButton
                
                local moduleCheckboxCorner = Instance.new("UICorner")
                moduleCheckboxCorner.CornerRadius = UDim.new(0, 4)
                moduleCheckboxCorner.Parent = moduleCheckboxFrame
                
                local moduleCheckboxStroke = Instance.new("UIStroke")
                applyTheme(moduleCheckboxStroke, "Color", "borderColor")
                moduleCheckboxStroke.Parent = moduleCheckboxFrame

                local moduleLabel = Instance.new("TextLabel")
                moduleLabel.Size = UDim2.new(1, -45, 0, 16)
                moduleLabel.Position = UDim2.new(0, 40, 0, 6)
                moduleLabel.BackgroundTransparency = 1
                moduleLabel.Text = name
                applyTheme(moduleLabel, "TextColor3", LibraryApi.Flags[flag] and "textWhiteColor" or "textDarkColor")
                moduleLabel.TextSize = 13
                moduleLabel.Font = boldFont
                moduleLabel.TextXAlignment = Enum.TextXAlignment.Left
                moduleLabel.Parent = moduleToggleButton

                local moduleDescriptionLabel = Instance.new("TextLabel")
                moduleDescriptionLabel.Size = UDim2.new(1, -45, 0, 14)
                moduleDescriptionLabel.Position = UDim2.new(0, 40, 0, 22)
                moduleDescriptionLabel.BackgroundTransparency = 1
                moduleDescriptionLabel.Text = descriptionText
                applyTheme(moduleDescriptionLabel, "TextColor3", "textDarkColor")
                moduleDescriptionLabel.TextSize = 11
                moduleDescriptionLabel.Font = mainFont
                moduleDescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                moduleDescriptionLabel.Parent = moduleToggleButton

                local moduleArrowIcon = Instance.new("ImageLabel")
                moduleArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                moduleArrowIcon.Position = UDim2.new(1, -22, 0, 14)
                moduleArrowIcon.BackgroundTransparency = 1
                moduleArrowIcon.Image = "rbxassetid://6031090656"
                applyTheme(moduleArrowIcon, "ImageColor3", LibraryApi.Flags[flag] and "accentColor" or "textDarkColor")
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

                local function Synchronize_Module_Size()
                    if LibraryApi.Flags[flag] then
                        animateElement(moduleFrame, {Size = UDim2.new(1, 0, 0, 46 + moduleContentLayout.AbsoluteContentSize.Y + 8)}, 0.3)
                        animateElement(moduleArrowIcon, {Rotation = 180}, 0.3)
                        pcall(function() moduleArrowIcon.ImageColor3 = colors.accentColor end)
                    else
                        animateElement(moduleFrame, {Size = UDim2.new(1, 0, 0, 46)}, 0.3)
                        animateElement(moduleArrowIcon, {Rotation = 0}, 0.3)
                        pcall(function() moduleArrowIcon.ImageColor3 = colors.textDarkColor end)
                    end
                end

                moduleContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if LibraryApi.Flags[flag] then Synchronize_Module_Size() end
                end)

                moduleToggleButton.MouseEnter:Connect(function()
                    showTooltip(tooltip)
                    if not LibraryApi.Flags[flag] then pcall(function() moduleToggleButtonStroke.Color = colors.borderLightColor end) end
                end)
                moduleToggleButton.MouseLeave:Connect(function()
                    showTooltip("")
                    if not LibraryApi.Flags[flag] then pcall(function() moduleToggleButtonStroke.Color = colors.borderColor end) end
                end)

                moduleToggleButton.MouseButton1Click:Connect(function()
                    LibraryApi.Flags[flag] = not LibraryApi.Flags[flag]
                    local newState = LibraryApi.Flags[flag]
                    applyTheme(moduleCheckboxFrame, "BackgroundColor3", newState and "accentColor" or "sectionBackground")
                    applyTheme(moduleToggleButtonStroke, "Color", newState and "accentColor" or "borderColor")
                    applyTheme(moduleLabel, "TextColor3", newState and "textWhiteColor" or "textDarkColor")
                    Synchronize_Module_Size()
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
            applyTheme(sectionBackgroundFrame, "BackgroundColor3", "sectionBackground")
            sectionBackgroundFrame.BackgroundTransparency = 0.21
            sectionBackgroundFrame.Parent = (columnSide == "Left") and leftColumnFrame or rightColumnFrame
            
            local sectionBackgroundCorner = Instance.new("UICorner")
            sectionBackgroundCorner.CornerRadius = UDim.new(0, 6)
            sectionBackgroundCorner.Parent = sectionBackgroundFrame
            
            local sectionBackgroundStroke = Instance.new("UIStroke")
            applyTheme(sectionBackgroundStroke, "Color", "borderColor")
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
            applyTheme(sectionLabel, "TextColor3", "textWhiteColor")
            sectionLabel.TextSize = 12
            sectionLabel.Font = boldFont
            sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            sectionLabel.Parent = sectionHeaderFrame

            local sectionSeparatorLine = Instance.new("Frame")
            sectionSeparatorLine.Size = UDim2.new(1, -20, 0, 1)
            sectionSeparatorLine.Position = UDim2.new(0, 10, 1, 0)
            applyTheme(sectionSeparatorLine, "BackgroundColor3", "borderColor")
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

            local function Update_Section_Size()
                sectionBackgroundFrame.Size = UDim2.new(1, 0, 0, sectionContentLayout.AbsoluteContentSize.Y + 44)
            end
            sectionContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Update_Section_Size)
            Update_Section_Size()

            return elementInjector(sectionContentFrame)
        end

        local settingsTab = windowContext:Tab_Create("Settings", "rbxassetid://104798010403294", true)
        local themeSection = settingsTab:Section_Create("Left", "Theme Colors")
        local configSection = settingsTab:Section_Create("Right", "Configuration")
        
        local accentPicker = themeSection:ColorPicker_Create("Accent Color", "InternalAccent", colors.accentColor, "", function(c) updateTheme("accentColor", c) end)
        local mainBgPicker = themeSection:ColorPicker_Create("Main Background", "InternalMainBg", colors.mainBackground, "", function(c) updateTheme("mainBackground", c) end)
        local sideBgPicker = themeSection:ColorPicker_Create("Sidebar Background", "InternalSideBg", colors.sidebarBackground, "", function(c) updateTheme("sidebarBackground", c) end)
        local secBgPicker = themeSection:ColorPicker_Create("Section Background", "InternalSecBg", colors.sectionBackground, "", function(c) updateTheme("sectionBackground", c) end)
        local elemBgPicker = themeSection:ColorPicker_Create("Element Background", "InternalElemBg", colors.elementBackground, "", function(c) updateTheme("elementBackground", c) end)
        local borderPicker = themeSection:ColorPicker_Create("Border Color", "InternalBorder", colors.borderColor, "", function(c) updateTheme("borderColor", c) end)
        local textWhtPicker = themeSection:ColorPicker_Create("Text White", "InternalTextW", colors.textWhiteColor, "", function(c) updateTheme("textWhiteColor", c) end)
        
        themeSection:Toggle_Create("Show Keybinds List", "InternalShowKB", false, "", function(s) kbOuterFrame.Visible = s end)

        local cfgDropdown = configSection:Dropdown_Create("Select Config", "InternalCfgSel", Get_Configs(), "Default", "", function(v) LibraryApi.CurrentConfig = v end)
        local cfgTextbox = configSection:Textbox_Create("Config Name", "InternalCfgName", "Default", "", function(v) LibraryApi.CurrentConfig = v end)
        
        configSection:Button_Create("Load Config", "", function() 
            Load_Configuration(LibraryApi.CurrentConfig)
            accentPicker:Set(colors.accentColor)
            mainBgPicker:Set(colors.mainBackground)
            sideBgPicker:Set(colors.sidebarBackground)
            secBgPicker:Set(colors.sectionBackground)
            elemBgPicker:Set(colors.elementBackground)
            borderPicker:Set(colors.borderColor)
            textWhtPicker:Set(colors.textWhiteColor)
        end)
        
        configSection:Button_Create("Save Config", "", function()
            Save_Configuration(LibraryApi.CurrentConfig)
            cfgDropdown:Refresh(Get_Configs())
        end)
        
        configSection:Button_Create("Rewrite Config", "", function()
            Save_Configuration(LibraryApi.CurrentConfig)
        end)
        
        configSection:SubButton_Create("Delete Config", "", function()
            Delete_Configuration(LibraryApi.CurrentConfig)
            cfgDropdown:Refresh(Get_Configs())
        end)

        profileButton.MouseButton1Click:Connect(function()
            settingsTab:Activate()
        end)

        return sectionApi
    end

    userInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if not gameProcessedEvent and input.KeyCode == Enum.KeyCode.Delete then
            mainBackground.Visible = not mainBackground.Visible
        end
    end)

    return windowContext
end

return LibraryApi
