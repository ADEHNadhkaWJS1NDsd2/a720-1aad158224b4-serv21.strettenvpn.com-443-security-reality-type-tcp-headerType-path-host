local CoreGuiService = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local HttpService = game:GetService("HttpService")
local WorkspaceService = game:GetService("Workspace")
local PlayersService = game:GetService("Players")

local LibraryApi = {
    Flags = {},
    FolderName = "RadiantConfigs",
    SelectedConfig = "",
    AutoSave = true,
    AutoLoad = true,
    WindowPosition = nil
}

local ElementRegistry = {}

function LibraryApi:UpdateUI()
    for Flag, UpdaterList in pairs(ElementRegistry) do
        for _, Updater in ipairs(UpdaterList) do
            pcall(Updater)
        end
    end
end

local function RegisterElement(Flag, UpdateFunction)
    if ElementRegistry[Flag] == nil then
        ElementRegistry[Flag] = {}
    end
    table.insert(ElementRegistry[Flag], UpdateFunction)
end

local LastAutoSaveTime = 0

local function TryAutoSave()
    if not LibraryApi.AutoSave then return end
    local now = os.clock()
    if now - LastAutoSaveTime < 0.75 then return end
    LastAutoSaveTime = now
    local name = LibraryApi.Flags["SelectedConfig"] or LibraryApi.SelectedConfig
    if not name or name == "" then name = "Default" end
    pcall(function()
        SaveConfiguration(name)
        if writefile then
            writefile(LibraryApi.FolderName .. "/LastConfig.txt", name)
        end
    end)
end

local ColorsTable = {
    mainBackground = Color3.fromRGB(15, 20, 15),
    sidebarBackground = Color3.fromRGB(18, 25, 18),
    sectionBackground = Color3.fromRGB(22, 30, 22),
    elementBackground = Color3.fromRGB(25, 35, 25),
    elementHoverBackground = Color3.fromRGB(30, 45, 30),
    borderColor = Color3.fromRGB(35, 50, 35),
    borderLightColor = Color3.fromRGB(50, 75, 50),
    accentColor = Color3.fromRGB(65, 255, 115),
    accentGradient1 = Color3.fromRGB(65, 255, 115),
    accentGradient2 = Color3.fromRGB(40, 200, 90),
    textWhiteColor = Color3.fromRGB(240, 255, 240),
    textDarkColor = Color3.fromRGB(140, 170, 140),
    tooltipBackground = Color3.fromRGB(12, 16, 12),
    notificationInfo = Color3.fromRGB(65, 180, 255),
    notificationSuccess = Color3.fromRGB(65, 255, 115),
    notificationWarning = Color3.fromRGB(255, 200, 65),
    notificationError = Color3.fromRGB(255, 65, 65)
}

local PresetThemes = {
    ["Radiant Green"] = {
        mainBackground = Color3.fromRGB(15, 20, 15),
        sidebarBackground = Color3.fromRGB(18, 25, 18),
        sectionBackground = Color3.fromRGB(22, 30, 22),
        elementBackground = Color3.fromRGB(25, 35, 25),
        elementHoverBackground = Color3.fromRGB(30, 45, 30),
        borderColor = Color3.fromRGB(35, 50, 35),
        borderLightColor = Color3.fromRGB(50, 75, 50),
        accentColor = Color3.fromRGB(65, 255, 115),
        accentGradient1 = Color3.fromRGB(65, 255, 115),
        accentGradient2 = Color3.fromRGB(40, 200, 90),
        textWhiteColor = Color3.fromRGB(240, 255, 240),
        textDarkColor = Color3.fromRGB(140, 170, 140)
    },
    ["Dark Night"] = {
        mainBackground = Color3.fromRGB(15, 15, 25),
        sidebarBackground = Color3.fromRGB(18, 18, 30),
        sectionBackground = Color3.fromRGB(22, 22, 35),
        elementBackground = Color3.fromRGB(25, 25, 40),
        elementHoverBackground = Color3.fromRGB(35, 35, 55),
        borderColor = Color3.fromRGB(35, 35, 50),
        borderLightColor = Color3.fromRGB(50, 50, 75),
        accentColor = Color3.fromRGB(100, 130, 255),
        accentGradient1 = Color3.fromRGB(100, 130, 255),
        accentGradient2 = Color3.fromRGB(70, 90, 200),
        textWhiteColor = Color3.fromRGB(240, 240, 255),
        textDarkColor = Color3.fromRGB(140, 140, 170)
    },
    ["Blood Red"] = {
        mainBackground = Color3.fromRGB(25, 15, 15),
        sidebarBackground = Color3.fromRGB(30, 18, 18),
        sectionBackground = Color3.fromRGB(35, 22, 22),
        elementBackground = Color3.fromRGB(40, 25, 25),
        elementHoverBackground = Color3.fromRGB(55, 30, 30),
        borderColor = Color3.fromRGB(50, 30, 30),
        borderLightColor = Color3.fromRGB(75, 40, 40),
        accentColor = Color3.fromRGB(255, 65, 65),
        accentGradient1 = Color3.fromRGB(255, 65, 65),
        accentGradient2 = Color3.fromRGB(200, 40, 40),
        textWhiteColor = Color3.fromRGB(255, 240, 240),
        textDarkColor = Color3.fromRGB(170, 140, 140)
    }
}

local ThemeRegistry = {}

local function SetColor(Obj, Prop, Role)
    table.insert(ThemeRegistry, {O = Obj, P = Prop, R = Role})
    Obj[Prop] = ColorsTable[Role]
end

local function SetGradient(Obj, Role1, Role2)
    table.insert(ThemeRegistry, {O = Obj, P = "Color", R1 = Role1, R2 = Role2})
    Obj.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, ColorsTable[Role1]),
        ColorSequenceKeypoint.new(1, ColorsTable[Role2])
    }
end

local function UpdateTheme()
    for _, Entry in ipairs(ThemeRegistry) do
        if Entry.O and Entry.O.Parent then
            if Entry.P == "Color" and Entry.R1 and Entry.R2 then
                Entry.O.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, ColorsTable[Entry.R1]),
                    ColorSequenceKeypoint.new(1, ColorsTable[Entry.R2])
                }
            else
                Entry.O[Entry.P] = ColorsTable[Entry.R]
            end
        end
    end
    LibraryApi:UpdateUI()
end

local MainFont = Enum.Font.GothamMedium
local BoldFont = Enum.Font.GothamBold

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = HttpService:GenerateGUID(false)
ScreenGui.Parent = CoreGuiService
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.IgnoreGuiInset = true

local TooltipFrame = Instance.new("Frame")
SetColor(TooltipFrame, "BackgroundColor3", "tooltipBackground")
TooltipFrame.BackgroundTransparency = 0.158372
TooltipFrame.Size = UDim2.new(0, 0, 0, 24)
TooltipFrame.ZIndex = 2000
TooltipFrame.Visible = false
TooltipFrame.Parent = ScreenGui

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 4)
TooltipCorner.Parent = TooltipFrame

local TooltipStroke = Instance.new("UIStroke")
SetColor(TooltipStroke, "Color", "borderLightColor")
TooltipStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
TooltipStroke.Transparency = 1
TooltipStroke.Parent = TooltipFrame

local TooltipText = Instance.new("TextLabel")
TooltipText.Size = UDim2.new(1, -16, 1, 0)
TooltipText.Position = UDim2.new(0, 8, 0, 0)
TooltipText.BackgroundTransparency = 1
SetColor(TooltipText, "TextColor3", "textWhiteColor")
TooltipText.TextTransparency = 1
TooltipText.TextSize = 12
TooltipText.Font = MainFont
TooltipText.TextXAlignment = Enum.TextXAlignment.Left
TooltipText.ZIndex = 2001
TooltipText.Parent = TooltipFrame

local NotificationContainer = Instance.new("Frame")
NotificationContainer.Size = UDim2.new(0, 300, 1, -40)
NotificationContainer.Position = UDim2.new(1, -320, 0, 20)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.ZIndex = 1500
NotificationContainer.Parent = ScreenGui

local NotificationLayout = Instance.new("UIListLayout")
NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotificationLayout.Padding = UDim.new(0, 10)
NotificationLayout.Parent = NotificationContainer

local TooltipTargetText = ""

local function AnimateElement(Element, Properties, Speed)
    local Tween = TweenService:Create(Element, TweenInfo.new(Speed or 0.35, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), Properties)
    Tween:Play()
    return Tween
end

local function ApplyAcrylicEffect(Parent, Transparency, CornerRadius)
    local BlurImage = Instance.new("ImageLabel")
    BlurImage.Size = UDim2.new(1, 0, 1, 0)
    BlurImage.BackgroundTransparency = 1
    BlurImage.Image = "rbxassetid://8992230113"
    BlurImage.TileSize = UDim2.new(0, 256, 0, 256)
    BlurImage.ScaleType = Enum.ScaleType.Tile
    BlurImage.ImageTransparency = Transparency or 0.88732
    BlurImage.ZIndex = Parent.ZIndex - 1
    BlurImage.Parent = Parent
    if CornerRadius then
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = CornerRadius
        Corner.Parent = BlurImage
    end
    return BlurImage
end

local function ShowTooltip(TextString)
    if not TextString or TextString == "" then
        TooltipTargetText = ""
        return
    end
    local TextBounds = TextService:GetTextSize(TextString, 12, MainFont, Vector2.new(500, 24))
    TooltipFrame.Size = UDim2.new(0, TextBounds.X + 16, 0, 24)
    TooltipText.Text = TextString
    TooltipTargetText = TextString
end

local function SnapValue(Value, Step)
    if not Step then return Value end
    return math.floor((Value / Step) + 0.5) * Step
end

local function FormatValue(Value, Step)
    if Step and Step < 1 then
        local DecimalPlaces = tostring(Step):len() - 2
        return string.format("%."..DecimalPlaces.."f", Value)
    end
    return tostring(Value)
end

local function GetConfigList()
    local ConfigList = {}
    if isfolder and isfolder(LibraryApi.FolderName) then
        if listfiles then
            for _, FilePath in ipairs(listfiles(LibraryApi.FolderName)) do
                local FileName = FilePath:match("([^/\\]+)%.json$")
                if FileName then table.insert(ConfigList, FileName) end
            end
        end
    end
    return ConfigList
end

local function SaveConfiguration(FileName)
    pcall(function()
        if not isfolder or not writefile then return end
        if not isfolder(LibraryApi.FolderName) then makefolder(LibraryApi.FolderName) end
        local SerializedData = {}
        for Key, Val in pairs(LibraryApi.Flags) do
            if typeof(Val) == "Color3" then
                SerializedData[Key] = {Type = "Color3", R = Val.R, G = Val.G, B = Val.B}
            elseif type(Val) == "table" and Val.Type == "Keybind" and Val.Value then
                SerializedData[Key] = {
                    Type = "Keybind",
                    InputType = Val.Type,
                    Name = Val.Value.Name,
                    Mode = Val.Mode
                }
            elseif type(Val) == "table" and Val.Min and Val.Max then
                SerializedData[Key] = {Type = "Range", Min = Val.Min, Max = Val.Max}
            elseif type(Val) == "table" then
                SerializedData[Key] = {Type = "Multi", Values = Val}
            else
                SerializedData[Key] = Val
            end
        end
        if LibraryApi.WindowPosition then
            SerializedData["_WindowPosition"] = {
                ScaleX = LibraryApi.WindowPosition.X.Scale,
                OffsetX = LibraryApi.WindowPosition.X.Offset,
                ScaleY = LibraryApi.WindowPosition.Y.Scale,
                OffsetY = LibraryApi.WindowPosition.Y.Offset
            }
        end
        writefile(LibraryApi.FolderName .. "/" .. FileName .. ".json", HttpService:JSONEncode(SerializedData))
    end)
end

local function LoadConfiguration(FileName)
    pcall(function()
        if not isfolder or not isfile or not readfile then return end
        local FullPath = LibraryApi.FolderName .. "/" .. FileName .. ".json"
        if isfile(FullPath) then
            local DecodedData = HttpService:JSONDecode(readfile(FullPath))
            if type(DecodedData) == "table" then
                if DecodedData["_WindowPosition"] then
                    local Wp = DecodedData["_WindowPosition"]
                    LibraryApi.WindowPosition = UDim2.new(Wp.ScaleX or 0.5, Wp.OffsetX or -360, Wp.ScaleY or 0.5, Wp.OffsetY or -240)
                end
                for Key, Val in pairs(DecodedData) do
                    if Key == "_WindowPosition" then continue end
                    if type(Val) == "table" then
                        if Val.Type == "Color3" then
                            LibraryApi.Flags[Key] = Color3.new(Val.R, Val.G, Val.B)
                        elseif Val.Type == "Keybind" then
                            local InputValue
                            if Val.InputType == "KeyCode" then
                                InputValue = Enum.KeyCode[Val.Name] or Enum.KeyCode.Unknown
                                LibraryApi.Flags[Key] = {Type = "KeyCode", Value = InputValue, Mode = Val.Mode or "Toggle"}
                            elseif Val.InputType == "UserInputType" then
                                InputValue = Enum.UserInputType[Val.Name] or Enum.UserInputType.None
                                LibraryApi.Flags[Key] = {Type = "UserInputType", Value = InputValue, Mode = Val.Mode or "Toggle"}
                            end
                        elseif Val.Type == "Range" then
                            LibraryApi.Flags[Key] = {Min = Val.Min, Max = Val.Max}
                        elseif Val.Type == "Multi" then
                            LibraryApi.Flags[Key] = Val.Values or {}
                        end
                    else
                        LibraryApi.Flags[Key] = Val
                    end
                end
            end
        end
    end)
end

RunService.RenderStepped:Connect(function()
    if TooltipTargetText ~= "" then
        local MouseLocation = UserInputService:GetMouseLocation()
        TooltipFrame.Position = UDim2.new(0, MouseLocation.X + 15, 0, MouseLocation.Y + 15)
        if not TooltipFrame.Visible then
            TooltipFrame.Visible = true
            AnimateElement(TooltipFrame, {BackgroundTransparency = 0.1837265}, 0.25)
            AnimateElement(TooltipStroke, {Transparency = 0}, 0.25)
            AnimateElement(TooltipText, {TextTransparency = 0}, 0.25)
        end
    else
        AnimateElement(TooltipFrame, {BackgroundTransparency = 1}, 0.15)
        AnimateElement(TooltipStroke, {Transparency = 1}, 0.15)
        AnimateElement(TooltipText, {TextTransparency = 1}, 0.15)
        task.delay(0.15, function()
            if TooltipTargetText == "" then TooltipFrame.Visible = false end
        end)
    end
end)

local KeybindOverlayList = {}

local function GetKeybindDisplayString(Data)
    if not Data or not Data.Value then return "None" end
    if Data.Value == Enum.KeyCode.Unknown or Data.Value == Enum.UserInputType.None then return "None" end
    if Data.Type == "KeyCode" then
        return Data.Value.Name or "None"
    elseif Data.Type == "UserInputType" then
        if Data.Value == Enum.UserInputType.MouseButton1 then return "Mouse1"
        elseif Data.Value == Enum.UserInputType.MouseButton2 then return "Mouse2"
        elseif Data.Value == Enum.UserInputType.MouseButton3 then return "Mouse3"
        else return Data.Value.Name end
    end
    return "None"
end

local KeybindOverlay = Instance.new("Frame")
KeybindOverlay.Name = "KeybindOverlay"
KeybindOverlay.Size = UDim2.new(0, 210, 0, 40)
KeybindOverlay.Position = UDim2.new(0, 20, 0, 120)
SetColor(KeybindOverlay, "BackgroundColor3", "mainBackground")
KeybindOverlay.BackgroundTransparency = 0.18374
KeybindOverlay.BorderSizePixel = 0
KeybindOverlay.Active = true
KeybindOverlay.ZIndex = 1400
KeybindOverlay.Visible = false
KeybindOverlay.Parent = ScreenGui

local KeybindOverlayCorner = Instance.new("UICorner")
KeybindOverlayCorner.CornerRadius = UDim.new(0, 8)
KeybindOverlayCorner.Parent = KeybindOverlay

local KeybindOverlayStroke = Instance.new("UIStroke")
SetColor(KeybindOverlayStroke, "Color", "borderColor")
KeybindOverlayStroke.Parent = KeybindOverlay

ApplyAcrylicEffect(KeybindOverlay, 0.9, UDim.new(0, 8))

local KeybindOverlayAccent = Instance.new("Frame")
KeybindOverlayAccent.Size = UDim2.new(1, 0, 0, 2)
KeybindOverlayAccent.BackgroundColor3 = Color3.new(1, 1, 1)
KeybindOverlayAccent.BorderSizePixel = 0
KeybindOverlayAccent.ZIndex = 1402
KeybindOverlayAccent.Parent = KeybindOverlay

local KeybindOverlayAccentCorner = Instance.new("UICorner")
KeybindOverlayAccentCorner.CornerRadius = UDim.new(0, 8)
KeybindOverlayAccentCorner.Parent = KeybindOverlayAccent

local KeybindOverlayAccentGradient = Instance.new("UIGradient")
SetGradient(KeybindOverlayAccentGradient, "accentGradient1", "accentGradient2")
KeybindOverlayAccentGradient.Parent = KeybindOverlayAccent

local KeybindOverlayHeader = Instance.new("Frame")
KeybindOverlayHeader.Size = UDim2.new(1, 0, 0, 26)
KeybindOverlayHeader.Position = UDim2.new(0, 0, 0, 2)
SetColor(KeybindOverlayHeader, "BackgroundColor3", "sidebarBackground")
KeybindOverlayHeader.BackgroundTransparency = 0.21847
KeybindOverlayHeader.BorderSizePixel = 0
KeybindOverlayHeader.ZIndex = 1401
KeybindOverlayHeader.Parent = KeybindOverlay

local KeybindOverlayTitle = Instance.new("TextLabel")
KeybindOverlayTitle.Size = UDim2.new(1, -16, 1, 0)
KeybindOverlayTitle.Position = UDim2.new(0, 10, 0, 0)
KeybindOverlayTitle.BackgroundTransparency = 1
KeybindOverlayTitle.Text = "Keybinds"
SetColor(KeybindOverlayTitle, "TextColor3", "textWhiteColor")
KeybindOverlayTitle.TextSize = 12
KeybindOverlayTitle.Font = BoldFont
KeybindOverlayTitle.TextXAlignment = Enum.TextXAlignment.Left
KeybindOverlayTitle.ZIndex = 1402
KeybindOverlayTitle.Parent = KeybindOverlayHeader

local KeybindOverlayHeaderBorder = Instance.new("Frame")
KeybindOverlayHeaderBorder.Size = UDim2.new(1, 0, 0, 1)
KeybindOverlayHeaderBorder.Position = UDim2.new(0, 0, 1, 0)
SetColor(KeybindOverlayHeaderBorder, "BackgroundColor3", "borderColor")
KeybindOverlayHeaderBorder.BorderSizePixel = 0
KeybindOverlayHeaderBorder.ZIndex = 1402
KeybindOverlayHeaderBorder.Parent = KeybindOverlayHeader

local KeybindOverlayListFrame = Instance.new("Frame")
KeybindOverlayListFrame.Size = UDim2.new(1, -16, 0, 0)
KeybindOverlayListFrame.Position = UDim2.new(0, 8, 0, 34)
KeybindOverlayListFrame.BackgroundTransparency = 1
KeybindOverlayListFrame.ZIndex = 1402
KeybindOverlayListFrame.Parent = KeybindOverlay

local KeybindOverlayLayout = Instance.new("UIListLayout")
KeybindOverlayLayout.SortOrder = Enum.SortOrder.LayoutOrder
KeybindOverlayLayout.Padding = UDim.new(0, 4)
KeybindOverlayLayout.Parent = KeybindOverlayListFrame

local IsKeybindOverlayDragging = false
local KeybindOverlayDragInput = nil
local KeybindOverlayDragStart = nil
local KeybindOverlayStartPos = nil

KeybindOverlay.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        IsKeybindOverlayDragging = true
        KeybindOverlayDragStart = Input.Position
        KeybindOverlayStartPos = KeybindOverlay.Position
    end
end)

KeybindOverlay.InputChanged:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
        KeybindOverlayDragInput = Input
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        IsKeybindOverlayDragging = false
    end
end)

RunService.RenderStepped:Connect(function()
    if IsKeybindOverlayDragging and KeybindOverlayDragInput then
        local Delta = KeybindOverlayDragInput.Position - KeybindOverlayDragStart
        KeybindOverlay.Position = UDim2.new(KeybindOverlayStartPos.X.Scale, KeybindOverlayStartPos.X.Offset + Delta.X, KeybindOverlayStartPos.Y.Scale, KeybindOverlayStartPos.Y.Offset + Delta.Y)
    end
    KeybindOverlay.Size = UDim2.new(0, 210, 0, 40 + KeybindOverlayLayout.AbsoluteContentSize.Y)
    local VisibleCount = 0
    for _, Entry in ipairs(KeybindOverlayList) do
        if Entry.Frame and Entry.Frame.Visible then VisibleCount = VisibleCount + 1 end
    end
    KeybindOverlay.Visible = (LibraryApi.Flags["KeybindOverlayEnabled"] ~= false) and VisibleCount > 0
end)

local function AddKeybindToOverlay(Name, Flag)
    local EntryFrame = Instance.new("Frame")
    EntryFrame.Size = UDim2.new(1, 0, 0, 16)
    EntryFrame.BackgroundTransparency = 1
    EntryFrame.ZIndex = 1402
    EntryFrame.Parent = KeybindOverlayListFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(0.5, 0, 1, 0)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = Name
    SetColor(NameLabel, "TextColor3", "textWhiteColor")
    NameLabel.TextSize = 11
    NameLabel.Font = MainFont
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    NameLabel.ZIndex = 1403
    NameLabel.Parent = EntryFrame

    local KeyLabel = Instance.new("TextLabel")
    KeyLabel.Size = UDim2.new(0.5, 0, 1, 0)
    KeyLabel.Position = UDim2.new(0.5, 0, 0, 0)
    KeyLabel.BackgroundTransparency = 1
    SetColor(KeyLabel, "TextColor3", "accentColor")
    KeyLabel.TextSize = 11
    KeyLabel.Font = BoldFont
    KeyLabel.TextXAlignment = Enum.TextXAlignment.Right
    KeyLabel.ZIndex = 1403
    KeyLabel.Parent = EntryFrame

    local ModeLabel = Instance.new("TextLabel")
    ModeLabel.Size = UDim2.new(1, 0, 0, 0)
    ModeLabel.BackgroundTransparency = 1
    ModeLabel.Visible = false
    ModeLabel.Parent = EntryFrame

    local function UpdateEntry()
        local Data = LibraryApi.Flags[Flag]
        local Display = GetKeybindDisplayString(Data)
        local Active = Data and Data.Value ~= nil
            and Data.Value ~= Enum.KeyCode.Unknown
            and Data.Value ~= Enum.UserInputType.None
            and Display ~= "None"
        EntryFrame.Visible = Active
        local modeText = (Data and Data.Mode or "Toggle")
        local stateText = ""
        if Data and Data.Mode == "Toggle" and Data.State ~= nil then
            stateText = Data.State and " ON" or " OFF"
        end
        KeyLabel.Text = "[ " .. Display .. " ] " .. modeText .. stateText
        if Data and Data.Mode == "Toggle" and Data.State ~= nil then
            KeyLabel.TextColor3 = Data.State and ColorsTable.accentColor or ColorsTable.textDarkColor
        else
            KeyLabel.TextColor3 = ColorsTable.accentColor
        end
    end
    UpdateEntry()
    RegisterElement(Flag, UpdateEntry)
    table.insert(KeybindOverlayList, {Frame = EntryFrame, Update = UpdateEntry})
end

function LibraryApi:Notify(Config)
    local Title = Config.Title or "Notification"
    local Text = Config.Text or ""
    local Duration = Config.Duration or 3
    local RawType = Config.Type or "Info"
    local NotificationType = RawType:sub(1, 1):upper() .. RawType:sub(2):lower()
    
    local NotificationFrame = Instance.new("Frame")
    NotificationFrame.Size = UDim2.new(1, 0, 0, 60)
    NotificationFrame.Position = UDim2.new(1, 320, 0, 0)
    SetColor(NotificationFrame, "BackgroundColor3", "mainBackground")
    NotificationFrame.BackgroundTransparency = 0.28547
    NotificationFrame.ZIndex = 1501
    NotificationFrame.Parent = NotificationContainer

    local NotificationCorner = Instance.new("UICorner")
    NotificationCorner.CornerRadius = UDim.new(0, 6)
    NotificationCorner.Parent = NotificationFrame

    local NotificationStroke = Instance.new("UIStroke")
    SetColor(NotificationStroke, "Color", "borderLightColor")
    NotificationStroke.Parent = NotificationFrame

    local AcrylicBlur = ApplyAcrylicEffect(NotificationFrame, 0.91238, UDim.new(0, 6))

    local LineFrame = Instance.new("Frame")
    LineFrame.Size = UDim2.new(0, 3, 1, -12)
    LineFrame.Position = UDim2.new(0, 6, 0, 6)
    
    local LineColorKey = "notification" .. NotificationType
    if not ColorsTable[LineColorKey] then LineColorKey = "notificationInfo" end
    SetColor(LineFrame, "BackgroundColor3", LineColorKey)
    
    LineFrame.BorderSizePixel = 0
    LineFrame.ZIndex = 1502
    LineFrame.Parent = NotificationFrame

    local LineCorner = Instance.new("UICorner")
    LineCorner.CornerRadius = UDim.new(0, 3)
    LineCorner.Parent = LineFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -24, 0, 16)
    TitleLabel.Position = UDim2.new(0, 16, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Title
    SetColor(TitleLabel, "TextColor3", "textWhiteColor")
    TitleLabel.TextSize = 13
    TitleLabel.Font = BoldFont
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 1502
    TitleLabel.Parent = NotificationFrame

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Size = UDim2.new(1, -24, 0, 24)
    TextLabel.Position = UDim2.new(0, 16, 0, 26)
    TextLabel.BackgroundTransparency = 1
    TextLabel.Text = Text
    SetColor(TextLabel, "TextColor3", "textDarkColor")
    TextLabel.TextSize = 12
    TextLabel.Font = MainFont
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextWrapped = true
    TextLabel.ZIndex = 1502
    TextLabel.Parent = NotificationFrame

    task.delay(Duration, function()
        AnimateElement(NotificationFrame, {BackgroundTransparency = 1}, 0.45)
        AnimateElement(NotificationStroke, {Transparency = 1}, 0.45)
        AnimateElement(LineFrame, {BackgroundTransparency = 1}, 0.45)
        AnimateElement(TitleLabel, {TextTransparency = 1}, 0.45)
        AnimateElement(TextLabel, {TextTransparency = 1}, 0.45)
        if AcrylicBlur then AnimateElement(AcrylicBlur, {ImageTransparency = 1}, 0.45) end
        
        task.delay(0.5, function()
            if NotificationFrame and NotificationFrame.Parent then
                NotificationFrame:Destroy()
            end
        end)
    end)
end

function LibraryApi:CreateWindow(WindowName)
    local MainBackground = Instance.new("Frame")
    MainBackground.Size = UDim2.new(0, 720, 0, 480)
    MainBackground.Position = UDim2.new(0.5, -360, 0.5, -240)
    SetColor(MainBackground, "BackgroundColor3", "mainBackground")
    MainBackground.BackgroundTransparency = 0.18374
    MainBackground.BorderSizePixel = 0
    MainBackground.Active = true
    MainBackground.Parent = ScreenGui

    local UiScaleModifier = Instance.new("UIScale")
    UiScaleModifier.Parent = MainBackground
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainBackground
    
    local MainStroke = Instance.new("UIStroke")
    SetColor(MainStroke, "Color", "borderColor")
    MainStroke.Parent = MainBackground

    ApplyAcrylicEffect(MainBackground, 0.88741, UDim.new(0, 8))

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 36)
    SetColor(TopBar, "BackgroundColor3", "sidebarBackground")
    TopBar.BackgroundTransparency = 0.21847
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainBackground
    
    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    local TopHider = Instance.new("Frame")
    TopHider.Size = UDim2.new(1, 0, 0, 6)
    TopHider.Position = UDim2.new(0, 0, 1, -6)
    SetColor(TopHider, "BackgroundColor3", "sidebarBackground")
    TopHider.BackgroundTransparency = 0.21847
    TopHider.BorderSizePixel = 0
    TopHider.Parent = TopBar

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.BackgroundColor3 = Color3.new(1, 1, 1)
    AccentLine.BorderSizePixel = 0
    AccentLine.Parent = TopBar
    
    local AccentCorner = Instance.new("UICorner")
    AccentCorner.CornerRadius = UDim.new(0, 8)
    AccentCorner.Parent = AccentLine

    local AccentGradient = Instance.new("UIGradient")
    SetGradient(AccentGradient, "accentGradient1", "accentGradient2")
    AccentGradient.Parent = AccentLine

    local TopBorder = Instance.new("Frame")
    TopBorder.Size = UDim2.new(1, 0, 0, 1)
    TopBorder.Position = UDim2.new(0, 0, 1, 0)
    SetColor(TopBorder, "BackgroundColor3", "borderColor")
    TopBorder.BorderSizePixel = 0
    TopBorder.Parent = TopBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -20, 1, -2)
    TitleLabel.Position = UDim2.new(0, 15, 0, 2)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = WindowName
    SetColor(TitleLabel, "TextColor3", "textWhiteColor")
    TitleLabel.TextSize = 13
    TitleLabel.Font = BoldFont
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TopBar

    local SidebarFrame = Instance.new("Frame")
    SidebarFrame.Size = UDim2.new(0, 150, 1, -37)
    SidebarFrame.Position = UDim2.new(0, 0, 0, 37)
    SetColor(SidebarFrame, "BackgroundColor3", "sidebarBackground")
    SidebarFrame.BackgroundTransparency = 0.21847
    SidebarFrame.BorderSizePixel = 0
    SidebarFrame.Parent = MainBackground
    
    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, 8)
    SidebarCorner.Parent = SidebarFrame

    local SidebarHiderRight = Instance.new("Frame")
    SidebarHiderRight.Size = UDim2.new(0, 6, 1, 0)
    SidebarHiderRight.Position = UDim2.new(1, -6, 0, 0)
    SetColor(SidebarHiderRight, "BackgroundColor3", "sidebarBackground")
    SidebarHiderRight.BackgroundTransparency = 0.21847
    SidebarHiderRight.BorderSizePixel = 0
    SidebarHiderRight.Parent = SidebarFrame

    local SidebarHiderTop = Instance.new("Frame")
    SidebarHiderTop.Size = UDim2.new(1, 0, 0, 6)
    SetColor(SidebarHiderTop, "BackgroundColor3", "sidebarBackground")
    SidebarHiderTop.BackgroundTransparency = 0.21847
    SidebarHiderTop.BorderSizePixel = 0
    SidebarHiderTop.Parent = SidebarFrame

    local SidebarBorder = Instance.new("Frame")
    SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
    SetColor(SidebarBorder, "BackgroundColor3", "borderColor")
    SidebarBorder.BorderSizePixel = 0
    SidebarBorder.Parent = SidebarFrame

    local TabScrollingFrame = Instance.new("ScrollingFrame")
    TabScrollingFrame.Size = UDim2.new(1, -10, 1, -10)
    TabScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    TabScrollingFrame.BackgroundTransparency = 1
    TabScrollingFrame.BorderSizePixel = 0
    TabScrollingFrame.ScrollBarThickness = 0
    TabScrollingFrame.Parent = SidebarFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabScrollingFrame

    local ContentAreaFrame = Instance.new("Frame")
    ContentAreaFrame.Size = UDim2.new(1, -151, 1, -37)
    ContentAreaFrame.Position = UDim2.new(0, 151, 0, 37)
    ContentAreaFrame.BackgroundTransparency = 1
    ContentAreaFrame.Parent = MainBackground

    local MobileToggleButton = Instance.new("ImageButton")
    MobileToggleButton.Size = UDim2.new(0, 50, 0, 50)
    MobileToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
    SetColor(MobileToggleButton, "BackgroundColor3", "mainBackground")
    MobileToggleButton.BorderSizePixel = 0
    MobileToggleButton.ZIndex = 1000
    MobileToggleButton.Visible = UserInputService.TouchEnabled
    MobileToggleButton.Parent = ScreenGui
    
    local Success, AvatarImage = pcall(function()
        return PlayersService:GetUserThumbnailAsync(PlayersService.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
    end)
    MobileToggleButton.Image = Success and AvatarImage or ""

    local MobileToggleCorner = Instance.new("UICorner")
    MobileToggleCorner.CornerRadius = UDim.new(1, 0)
    MobileToggleCorner.Parent = MobileToggleButton

    local MobileToggleStroke = Instance.new("UIStroke")
    SetColor(MobileToggleStroke, "Color", "accentColor")
    MobileToggleStroke.Thickness = 2
    MobileToggleStroke.Parent = MobileToggleButton

    local IsToggleDragging = false
    local ToggleDragInput = nil
    local ToggleDragStart = nil
    local ToggleStartPos = nil

    MobileToggleButton.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            IsToggleDragging = true
            ToggleDragStart = Input.Position
            ToggleStartPos = MobileToggleButton.Position
        end
    end)

    MobileToggleButton.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            ToggleDragInput = Input
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            IsToggleDragging = false
        end
    end)

    RunService.RenderStepped:Connect(function()
        if IsToggleDragging and ToggleDragInput then
            local Delta = ToggleDragInput.Position - ToggleDragStart
            MobileToggleButton.Position = UDim2.new(ToggleStartPos.X.Scale, ToggleStartPos.X.Offset + Delta.X, ToggleStartPos.Y.Scale, ToggleStartPos.Y.Offset + Delta.Y)
        end
    end)

    local ToggleClickTime = 0
    MobileToggleButton.MouseButton1Down:Connect(function()
        ToggleClickTime = os.clock()
        AnimateElement(MobileToggleButton, {Size = UDim2.new(0, 45, 0, 45)}, 0.25)
    end)
    
    MobileToggleButton.MouseButton1Up:Connect(function()
        AnimateElement(MobileToggleButton, {Size = UDim2.new(0, 50, 0, 50)}, 0.25)
        if os.clock() - ToggleClickTime < 0.2 then
            MainBackground.Visible = not MainBackground.Visible
        end
    end)

    local function UpdateResponsiveScale()
        local Vp = WorkspaceService.CurrentCamera.ViewportSize
        if Vp.X < 1 or Vp.Y < 1 then 
            UiScaleModifier.Scale = 1
            return
        end
        local ScaleX = Vp.X / 800
        local ScaleY = Vp.Y / 500
        local Scale = math.min(ScaleX, ScaleY)
        if Scale < 1 then
            UiScaleModifier.Scale = math.clamp(Scale * 0.95, 0.4, 1)
        else
            UiScaleModifier.Scale = 1
        end
    end

    WorkspaceService.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateResponsiveScale)
    UpdateResponsiveScale()

    local IsDragging = false
    local DragInput = nil
    local DragStart = nil
    local StartPosition = nil
    local TargetPosition = MainBackground.Position

    TopBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            IsDragging = true
            DragStart = Input.Position
            StartPosition = MainBackground.Position
        end
    end)

    TopBar.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then 
            DragInput = Input 
        end
    end)

    UserInputService.InputEnded:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
            IsDragging = false 
            LibraryApi.WindowPosition = TargetPosition
        end
    end)

    RunService.RenderStepped:Connect(function()
        if IsDragging and DragInput then
            local Delta = DragInput.Position - DragStart
            TargetPosition = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + (Delta.X / UiScaleModifier.Scale), StartPosition.Y.Scale, StartPosition.Y.Offset + (Delta.Y / UiScaleModifier.Scale))
        end
        MainBackground.Position = MainBackground.Position:Lerp(TargetPosition, 0.25)
    end)

    local WindowContext = { Tabs = {}, ActiveTab = nil }

    function WindowContext:TabCreate(TabName, IconId, IsBottom)
        local TabData = {}

        local TabButton = Instance.new("TextButton")
        SetColor(TabButton, "BackgroundColor3", "elementHoverBackground")
        TabButton.BackgroundTransparency = 1
        TabButton.Text = ""
        TabButton.AutoButtonColor = false
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 6)
        ButtonCorner.Parent = TabButton

        local TabLabel = Instance.new("TextLabel")
        TabLabel.BackgroundTransparency = 1
        SetColor(TabLabel, "TextColor3", "textDarkColor")
        TabLabel.TextSize = 12
        TabLabel.Font = MainFont
        TabLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabLabel.Parent = TabButton

        if IsBottom then
            TabButton.Parent = SidebarFrame
            TabButton.Size = UDim2.new(1, -12, 0, 42)
            TabButton.Position = UDim2.new(0, 6, 1, -48)
            TabScrollingFrame.Size = UDim2.new(1, -10, 1, -56)
            
            local TabIcon = Instance.new("ImageLabel")
            TabIcon.Size = UDim2.new(0, 26, 0, 26)
            TabIcon.Position = UDim2.new(0, 10, 0.5, -13)
            TabIcon.BackgroundTransparency = 1
            TabIcon.Image = Success and AvatarImage or ""
            TabIcon.ScaleType = Enum.ScaleType.Crop 
            TabIcon.Parent = TabButton
            
            local IconCorner = Instance.new("UICorner")
            IconCorner.CornerRadius = UDim.new(1, 0)
            IconCorner.Parent = TabIcon
            
            local AvatarStroke = Instance.new("UIStroke")
            SetColor(AvatarStroke, "Color", "accentColor")
            AvatarStroke.Thickness = 2
            AvatarStroke.Parent = TabIcon
            
            TabLabel.Position = UDim2.new(0, 44, 0, 0)
            TabLabel.Size = UDim2.new(1, -50, 1, 0)
            TabLabel.Text = PlayersService.LocalPlayer.Name
            TabLabel.Font = BoldFont
            
            local ProfileStroke = Instance.new("UIStroke")
            SetColor(ProfileStroke, "Color", "borderLightColor")
            ProfileStroke.Thickness = 1
            ProfileStroke.Parent = TabButton
        else
            TabButton.Parent = TabScrollingFrame
            TabButton.Size = UDim2.new(1, 0, 0, 32)
            TabLabel.Text = TabName
            if IconId and IconId ~= "" then
                local TabIcon = Instance.new("ImageLabel")
                TabIcon.Size = UDim2.new(0, 14, 0, 14)
                TabIcon.Position = UDim2.new(0, 12, 0.5, -7)
                TabIcon.BackgroundTransparency = 1
                TabIcon.Image = IconId
                SetColor(TabIcon, "ImageColor3", "textDarkColor")
                TabIcon.Parent = TabButton
                TabData.Icon = TabIcon
                TabLabel.Position = UDim2.new(0, 34, 0, 0)
                TabLabel.Size = UDim2.new(1, -44, 1, 0)
            else
                TabLabel.Position = UDim2.new(0, 12, 0, 0)
                TabLabel.Size = UDim2.new(1, -20, 1, 0)
            end
        end

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0.5, 0)
        SetColor(TabIndicator, "BackgroundColor3", "accentColor")
        TabIndicator.BorderSizePixel = 0
        TabIndicator.Parent = TabButton
        
        local IndicatorCorner = Instance.new("UICorner")
        IndicatorCorner.CornerRadius = UDim.new(0, 3)
        IndicatorCorner.Parent = TabIndicator

        local PageScrollingFrame = Instance.new("ScrollingFrame")
        PageScrollingFrame.Size = UDim2.new(1, 0, 1, 0)
        PageScrollingFrame.BackgroundTransparency = 1
        PageScrollingFrame.BorderSizePixel = 0
        PageScrollingFrame.ScrollBarThickness = 2
        SetColor(PageScrollingFrame, "ScrollBarImageColor3", "accentColor")
        PageScrollingFrame.Visible = false
        PageScrollingFrame.Parent = ContentAreaFrame

        local LeftColumnFrame = Instance.new("Frame")
        LeftColumnFrame.Size = UDim2.new(0.5, -16, 1, 0)
        LeftColumnFrame.Position = UDim2.new(0, 10, 0, 10)
        LeftColumnFrame.BackgroundTransparency = 1
        LeftColumnFrame.Parent = PageScrollingFrame

        local RightColumnFrame = Instance.new("Frame")
        RightColumnFrame.Size = UDim2.new(0.5, -16, 1, 0)
        RightColumnFrame.Position = UDim2.new(0.5, 6, 0, 10)
        RightColumnFrame.BackgroundTransparency = 1
        RightColumnFrame.Parent = PageScrollingFrame

        local LeftColumnLayout = Instance.new("UIListLayout")
        LeftColumnLayout.Padding = UDim.new(0, 10)
        LeftColumnLayout.Parent = LeftColumnFrame

        local RightColumnLayout = Instance.new("UIListLayout")
        RightColumnLayout.Padding = UDim.new(0, 10)
        RightColumnLayout.Parent = RightColumnFrame

        RunService.RenderStepped:Connect(function()
            local MaxColumnHeight = math.max(LeftColumnLayout.AbsoluteContentSize.Y, RightColumnLayout.AbsoluteContentSize.Y)
            PageScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, MaxColumnHeight + 20)
            TabScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 10)
        end)

        function TabData:Activate()
            if WindowContext.ActiveTab == TabData then return end
            if WindowContext.ActiveTab then
                AnimateElement(WindowContext.ActiveTab.Btn, {BackgroundTransparency = 1}, 0.3)
                AnimateElement(WindowContext.ActiveTab.Lbl, {TextColor3 = ColorsTable.textDarkColor}, 0.3)
                if WindowContext.ActiveTab.Icon then AnimateElement(WindowContext.ActiveTab.Icon, {ImageColor3 = ColorsTable.textDarkColor}, 0.3) end
                AnimateElement(WindowContext.ActiveTab.Ind, {Size = UDim2.new(0, 3, 0, 0), Position = UDim2.new(0, 0, 0.5, 0)}, 0.3)
                WindowContext.ActiveTab.Page.Visible = false
            end
            WindowContext.ActiveTab = TabData
            PageScrollingFrame.Visible = true
            AnimateElement(TabButton, {BackgroundTransparency = 0.11847}, 0.3)
            AnimateElement(TabLabel, {TextColor3 = ColorsTable.textWhiteColor}, 0.3)
            if TabData.Icon then AnimateElement(TabData.Icon, {ImageColor3 = ColorsTable.accentColor}, 0.3) end
            AnimateElement(TabIndicator, {Size = UDim2.new(0, 3, 0, 18), Position = UDim2.new(0, 0, 0.5, -9)}, 0.3)
        end

        TabButton.MouseButton1Click:Connect(function() TabData:Activate() end)

        TabData.Btn = TabButton
        TabData.Lbl = TabLabel
        TabData.Ind = TabIndicator
        TabData.Page = PageScrollingFrame

        table.insert(WindowContext.Tabs, TabData)
        if #WindowContext.Tabs == 1 then TabData:Activate() end

        local function ElementInjector(TargetContainer)
            local Elements = {}

            function Elements:SubtextCreate(Text)
                local SubtextLabel = Instance.new("TextLabel")
                SubtextLabel.Size = UDim2.new(1, -10, 0, 14)
                SubtextLabel.BackgroundTransparency = 1
                SubtextLabel.Text = Text
                SetColor(SubtextLabel, "TextColor3", "textDarkColor")
                SubtextLabel.TextSize = 11
                SubtextLabel.Font = MainFont
                SubtextLabel.TextXAlignment = Enum.TextXAlignment.Left
                SubtextLabel.Parent = TargetContainer
            end

            function Elements:ToggleCreate(Name, Flag, Default, Tooltip, Callback)
                LibraryApi.Flags[Flag] = LibraryApi.Flags[Flag] ~= nil and LibraryApi.Flags[Flag] or (Default or false)

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Size = UDim2.new(1, 0, 0, 16)
                ToggleButton.BackgroundTransparency = 1
                ToggleButton.Text = ""
                ToggleButton.Parent = TargetContainer

                local CheckboxFrame = Instance.new("Frame")
                CheckboxFrame.Size = UDim2.new(0, 14, 0, 14)
                CheckboxFrame.Position = UDim2.new(0, 2, 0.5, -7)
                SetColor(CheckboxFrame, "BackgroundColor3", LibraryApi.Flags[Flag] and "accentColor" or "elementBackground")
                CheckboxFrame.BackgroundTransparency = 0.21847
                CheckboxFrame.Parent = ToggleButton
                
                local CheckboxCorner = Instance.new("UICorner")
                CheckboxCorner.CornerRadius = UDim.new(0, 3)
                CheckboxCorner.Parent = CheckboxFrame
                
                local CheckboxStroke = Instance.new("UIStroke")
                SetColor(CheckboxStroke, "Color", LibraryApi.Flags[Flag] and "accentColor" or "borderColor")
                CheckboxStroke.Parent = CheckboxFrame

                local ToggleLabel = Instance.new("TextLabel")
                ToggleLabel.Size = UDim2.new(1, -26, 1, 0)
                ToggleLabel.Position = UDim2.new(0, 24, 0, 0)
                ToggleLabel.BackgroundTransparency = 1
                ToggleLabel.Text = Name
                SetColor(ToggleLabel, "TextColor3", LibraryApi.Flags[Flag] and "textWhiteColor" or "textDarkColor")
                ToggleLabel.TextSize = 12
                ToggleLabel.Font = MainFont
                ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ToggleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                ToggleLabel.Parent = ToggleButton

                ToggleButton.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    if not LibraryApi.Flags[Flag] then AnimateElement(CheckboxStroke, {Color = ColorsTable.borderLightColor}, 0.25) end
                end)
                ToggleButton.MouseLeave:Connect(function()
                    ShowTooltip("")
                    if not LibraryApi.Flags[Flag] then AnimateElement(CheckboxStroke, {Color = ColorsTable.borderColor}, 0.25) end
                end)

                ToggleButton.MouseButton1Click:Connect(function()
                    LibraryApi.Flags[Flag] = not LibraryApi.Flags[Flag]
                    local NewState = LibraryApi.Flags[Flag]
                    AnimateElement(CheckboxFrame, {BackgroundColor3 = NewState and ColorsTable.accentColor or ColorsTable.elementBackground}, 0.3)
                    AnimateElement(CheckboxStroke, {Color = NewState and ColorsTable.accentColor or ColorsTable.borderColor}, 0.3)
                    AnimateElement(ToggleLabel, {TextColor3 = NewState and ColorsTable.textWhiteColor or ColorsTable.textDarkColor}, 0.3)
                    if Callback then task.spawn(Callback, NewState) end
                    TryAutoSave()
                end)

                local function UpdateToggleVisual()
                    local CurrentState = LibraryApi.Flags[Flag]
                    CheckboxFrame.BackgroundColor3 = CurrentState and ColorsTable.accentColor or ColorsTable.elementBackground
                    CheckboxStroke.Color = CurrentState and ColorsTable.accentColor or ColorsTable.borderColor
                    ToggleLabel.TextColor3 = CurrentState and ColorsTable.textWhiteColor or ColorsTable.textDarkColor
                end
                UpdateToggleVisual()
                RegisterElement(Flag, UpdateToggleVisual)
            end

            function Elements:SliderCreate(Name, Flag, Min, Max, Default, Step, Tooltip, Callback)
                LibraryApi.Flags[Flag] = LibraryApi.Flags[Flag] ~= nil and LibraryApi.Flags[Flag] or SnapValue(Default or Min, Step)

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 36)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = TargetContainer

                local SliderLabel = Instance.new("TextLabel")
                SliderLabel.Size = UDim2.new(1, -50, 0, 14)
                SliderLabel.Position = UDim2.new(0, 2, 0, 0)
                SliderLabel.BackgroundTransparency = 1
                SliderLabel.Text = Name
                SetColor(SliderLabel, "TextColor3", "textWhiteColor")
                SliderLabel.TextSize = 12
                SliderLabel.Font = MainFont
                SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                SliderLabel.Parent = SliderFrame

                local ValueTextBox = Instance.new("TextBox")
                ValueTextBox.Size = UDim2.new(0, 40, 0, 14)
                ValueTextBox.Position = UDim2.new(1, -42, 0, 0)
                ValueTextBox.BackgroundTransparency = 1
                ValueTextBox.Text = FormatValue(LibraryApi.Flags[Flag], Step)
                SetColor(ValueTextBox, "TextColor3", "textWhiteColor")
                ValueTextBox.TextSize = 12
                ValueTextBox.Font = MainFont
                ValueTextBox.TextXAlignment = Enum.TextXAlignment.Right
                ValueTextBox.ClearTextOnFocus = false
                ValueTextBox.Parent = SliderFrame

                local SliderBackground = Instance.new("TextButton")
                SliderBackground.Size = UDim2.new(1, -4, 0, 6)
                SliderBackground.Position = UDim2.new(0, 2, 0, 24)
                SetColor(SliderBackground, "BackgroundColor3", "elementBackground")
                SliderBackground.BackgroundTransparency = 0.21847
                SliderBackground.Text = ""
                SliderBackground.AutoButtonColor = false
                SliderBackground.Parent = SliderFrame
                
                local SliderBackgroundCorner = Instance.new("UICorner")
                SliderBackgroundCorner.CornerRadius = UDim.new(0, 3)
                SliderBackgroundCorner.Parent = SliderBackground
                
                local SliderBackgroundStroke = Instance.new("UIStroke")
                SetColor(SliderBackgroundStroke, "Color", "borderColor")
                SliderBackgroundStroke.Parent = SliderBackground

                local SliderFill = Instance.new("Frame")
                local InitialPercentage = (LibraryApi.Flags[Flag] - Min) / (Max - Min)
                SliderFill.Size = UDim2.new(InitialPercentage, 0, 1, 0)
                SetColor(SliderFill, "BackgroundColor3", "accentColor")
                SliderFill.Parent = SliderBackground
                
                local SliderFillCorner = Instance.new("UICorner")
                SliderFillCorner.CornerRadius = UDim.new(0, 3)
                SliderFillCorner.Parent = SliderFill

                local SliderKnob = Instance.new("Frame")
                SliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                SliderKnob.Size = UDim2.new(0, 10, 0, 10)
                SliderKnob.Position = UDim2.new(InitialPercentage, 0, 0.5, 0)
                SetColor(SliderKnob, "BackgroundColor3", "textWhiteColor")
                SliderKnob.ZIndex = 2
                SliderKnob.Parent = SliderBackground
                local SliderKnobCorner = Instance.new("UICorner"); SliderKnobCorner.CornerRadius = UDim.new(1, 0); SliderKnobCorner.Parent = SliderKnob
                local SliderKnobStroke = Instance.new("UIStroke"); SetColor(SliderKnobStroke, "Color", "borderColor"); SliderKnobStroke.Parent = SliderKnob

                SliderBackground.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    AnimateElement(SliderBackgroundStroke, {Color = ColorsTable.borderLightColor}, 0.25)
                end)
                SliderBackground.MouseLeave:Connect(function()
                    ShowTooltip("")
                    AnimateElement(SliderBackgroundStroke, {Color = ColorsTable.borderColor}, 0.25)
                end)

                local IsSliding = false

                local function SetSliderValue(NewValue)
                    local ClampedValue = math.clamp(NewValue, Min, Max)
                    local SnappedValue = SnapValue(ClampedValue, Step)
                    if LibraryApi.Flags[Flag] ~= SnappedValue then
                        LibraryApi.Flags[Flag] = SnappedValue
                        local Percentage = (SnappedValue - Min) / (Max - Min)
                        AnimateElement(SliderFill, {Size = UDim2.new(Percentage, 0, 1, 0)}, 0.15)
                        AnimateElement(SliderKnob, {Position = UDim2.new(Percentage, 0, 0.5, 0)}, 0.15)
                        ValueTextBox.Text = FormatValue(SnappedValue, Step)
                        if Callback then task.spawn(Callback, SnappedValue) end
                        TryAutoSave()
                    end
                end

                SliderBackground.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        IsSliding = true
                        local Percentage = math.clamp((Input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                        SetSliderValue(Min + ((Max - Min) * Percentage))
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                        IsSliding = false 
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if IsSliding and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then 
                        local Percentage = math.clamp((Input.Position.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                        SetSliderValue(Min + ((Max - Min) * Percentage))
                    end
                end)

                ValueTextBox.FocusLost:Connect(function()
                    local InputValue = tonumber(ValueTextBox.Text)
                    if InputValue then
                        SetSliderValue(InputValue)
                    else
                        ValueTextBox.Text = FormatValue(LibraryApi.Flags[Flag], Step)
                    end
                end)

                local function UpdateSliderVisual()
                    local CurrentValue = LibraryApi.Flags[Flag]
                    local Percentage = (CurrentValue - Min) / (Max - Min)
                    SliderFill.Size = UDim2.new(Percentage, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(Percentage, 0, 0.5, 0)
                    ValueTextBox.Text = FormatValue(CurrentValue, Step)
                end
                UpdateSliderVisual()
                RegisterElement(Flag, UpdateSliderVisual)
            end

            function Elements:RangeSliderCreate(Name, Flag, Min, Max, DefaultMin, DefaultMax, Step, Tooltip, Callback)
                if not LibraryApi.Flags[Flag] then
                    LibraryApi.Flags[Flag] = {Min = SnapValue(DefaultMin or Min, Step), Max = SnapValue(DefaultMax or Max, Step)}
                end

                local RangeSliderFrame = Instance.new("Frame")
                RangeSliderFrame.Size = UDim2.new(1, 0, 0, 36)
                RangeSliderFrame.BackgroundTransparency = 1
                RangeSliderFrame.Parent = TargetContainer

                local RangeSliderLabel = Instance.new("TextLabel")
                RangeSliderLabel.Size = UDim2.new(1, -80, 0, 14)
                RangeSliderLabel.Position = UDim2.new(0, 2, 0, 0)
                RangeSliderLabel.BackgroundTransparency = 1
                RangeSliderLabel.Text = Name
                SetColor(RangeSliderLabel, "TextColor3", "textWhiteColor")
                RangeSliderLabel.TextSize = 12
                RangeSliderLabel.Font = MainFont
                RangeSliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                RangeSliderLabel.Parent = RangeSliderFrame

                local ValueLabel = Instance.new("TextLabel")
                ValueLabel.Size = UDim2.new(0, 80, 0, 14)
                ValueLabel.Position = UDim2.new(1, -82, 0, 0)
                ValueLabel.BackgroundTransparency = 1
                ValueLabel.Text = FormatValue(LibraryApi.Flags[Flag].Min, Step) .. " - " .. FormatValue(LibraryApi.Flags[Flag].Max, Step)
                SetColor(ValueLabel, "TextColor3", "textWhiteColor")
                ValueLabel.TextSize = 12
                ValueLabel.Font = MainFont
                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValueLabel.Parent = RangeSliderFrame

                local RangeSliderBackground = Instance.new("TextButton")
                RangeSliderBackground.Size = UDim2.new(1, -4, 0, 6)
                RangeSliderBackground.Position = UDim2.new(0, 2, 0, 24)
                SetColor(RangeSliderBackground, "BackgroundColor3", "elementBackground")
                RangeSliderBackground.BackgroundTransparency = 0.21847
                RangeSliderBackground.Text = ""
                RangeSliderBackground.AutoButtonColor = false
                RangeSliderBackground.Parent = RangeSliderFrame
                
                local RangeSliderBackgroundCorner = Instance.new("UICorner")
                RangeSliderBackgroundCorner.CornerRadius = UDim.new(0, 3)
                RangeSliderBackgroundCorner.Parent = RangeSliderBackground
                
                local RangeSliderBackgroundStroke = Instance.new("UIStroke")
                SetColor(RangeSliderBackgroundStroke, "Color", "borderColor")
                RangeSliderBackgroundStroke.Parent = RangeSliderBackground

                local RangeSliderFill = Instance.new("Frame")
                SetColor(RangeSliderFill, "BackgroundColor3", "accentColor")
                RangeSliderFill.Parent = RangeSliderBackground
                
                local RangeSliderFillCorner = Instance.new("UICorner")
                RangeSliderFillCorner.CornerRadius = UDim.new(0, 3)
                RangeSliderFillCorner.Parent = RangeSliderFill

                local MinRangeKnob = Instance.new("Frame")
                MinRangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                MinRangeKnob.Size = UDim2.new(0, 10, 0, 10)
                SetColor(MinRangeKnob, "BackgroundColor3", "textWhiteColor")
                MinRangeKnob.ZIndex = 2
                MinRangeKnob.Parent = RangeSliderBackground
                local MinRangeKnobCorner = Instance.new("UICorner"); MinRangeKnobCorner.CornerRadius = UDim.new(1, 0); MinRangeKnobCorner.Parent = MinRangeKnob
                local MinRangeKnobStroke = Instance.new("UIStroke"); SetColor(MinRangeKnobStroke, "Color", "borderColor"); MinRangeKnobStroke.Parent = MinRangeKnob

                local MaxRangeKnob = Instance.new("Frame")
                MaxRangeKnob.AnchorPoint = Vector2.new(0.5, 0.5)
                MaxRangeKnob.Size = UDim2.new(0, 10, 0, 10)
                SetColor(MaxRangeKnob, "BackgroundColor3", "textWhiteColor")
                MaxRangeKnob.ZIndex = 2
                MaxRangeKnob.Parent = RangeSliderBackground
                local MaxRangeKnobCorner = Instance.new("UICorner"); MaxRangeKnobCorner.CornerRadius = UDim.new(1, 0); MaxRangeKnobCorner.Parent = MaxRangeKnob
                local MaxRangeKnobStroke = Instance.new("UIStroke"); SetColor(MaxRangeKnobStroke, "Color", "borderColor"); MaxRangeKnobStroke.Parent = MaxRangeKnob

                local function UpdateRangeSliderVisuals()
                    local MinPercentage = (LibraryApi.Flags[Flag].Min - Min) / (Max - Min)
                    local MaxPercentage = (LibraryApi.Flags[Flag].Max - Min) / (Max - Min)
                    AnimateElement(RangeSliderFill, {Position = UDim2.new(MinPercentage, 0, 0, 0), Size = UDim2.new(MaxPercentage - MinPercentage, 0, 1, 0)}, 0.15)
                    AnimateElement(MinRangeKnob, {Position = UDim2.new(MinPercentage, 0, 0.5, 0)}, 0.15)
                    AnimateElement(MaxRangeKnob, {Position = UDim2.new(MaxPercentage, 0, 0.5, 0)}, 0.15)
                    ValueLabel.Text = FormatValue(LibraryApi.Flags[Flag].Min, Step) .. " - " .. FormatValue(LibraryApi.Flags[Flag].Max, Step)
                end
                UpdateRangeSliderVisuals()
                RegisterElement(Flag, UpdateRangeSliderVisuals)

                RangeSliderBackground.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    AnimateElement(RangeSliderBackgroundStroke, {Color = ColorsTable.borderLightColor}, 0.25)
                end)
                RangeSliderBackground.MouseLeave:Connect(function()
                    ShowTooltip("")
                    AnimateElement(RangeSliderBackgroundStroke, {Color = ColorsTable.borderColor}, 0.25)
                end)

                local IsSlidingMin = false
                local IsSlidingMax = false

                RangeSliderBackground.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        local MouseX = Input.Position.X
                        local MinPercentage = (LibraryApi.Flags[Flag].Min - Min) / (Max - Min)
                        local MaxPercentage = (LibraryApi.Flags[Flag].Max - Min) / (Max - Min)
                        local MinKnobPosition = RangeSliderBackground.AbsolutePosition.X + (RangeSliderBackground.AbsoluteSize.X * MinPercentage)
                        local MaxKnobPosition = RangeSliderBackground.AbsolutePosition.X + (RangeSliderBackground.AbsoluteSize.X * MaxPercentage)
                        
                        if math.abs(MouseX - MinKnobPosition) < math.abs(MouseX - MaxKnobPosition) then
                            IsSlidingMin = true
                        else
                            IsSlidingMax = true
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
                        IsSlidingMin = false
                        IsSlidingMax = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if (IsSlidingMin or IsSlidingMax) and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then 
                        local Percentage = math.clamp((Input.Position.X - RangeSliderBackground.AbsolutePosition.X) / RangeSliderBackground.AbsoluteSize.X, 0, 1)
                        local CalculatedValue = SnapValue(Min + ((Max - Min) * Percentage), Step)
                        
                        if IsSlidingMin then
                            if CalculatedValue <= LibraryApi.Flags[Flag].Max then
                                LibraryApi.Flags[Flag].Min = CalculatedValue
                            else
                                LibraryApi.Flags[Flag].Min = LibraryApi.Flags[Flag].Max
                            end
                        elseif IsSlidingMax then
                            if CalculatedValue >= LibraryApi.Flags[Flag].Min then
                                LibraryApi.Flags[Flag].Max = CalculatedValue
                            else
                                LibraryApi.Flags[Flag].Max = LibraryApi.Flags[Flag].Min
                            end
                        end
                        UpdateRangeSliderVisuals()
                        if Callback then task.spawn(Callback, LibraryApi.Flags[Flag]) end
                        TryAutoSave()
                    end
                end)
            end

            function Elements:TextboxCreate(Name, Flag, Default, Tooltip, Callback)
                LibraryApi.Flags[Flag] = LibraryApi.Flags[Flag] ~= nil and LibraryApi.Flags[Flag] or (Default or "")

                local TextboxFrame = Instance.new("Frame")
                TextboxFrame.Size = UDim2.new(1, 0, 0, 36)
                TextboxFrame.BackgroundTransparency = 1
                TextboxFrame.Parent = TargetContainer

                local TextboxLabel = Instance.new("TextLabel")
                TextboxLabel.Size = UDim2.new(1, -120, 1, 0)
                TextboxLabel.Position = UDim2.new(0, 2, 0, 0)
                TextboxLabel.BackgroundTransparency = 1
                TextboxLabel.Text = Name
                SetColor(TextboxLabel, "TextColor3", "textWhiteColor")
                TextboxLabel.TextSize = 12
                TextboxLabel.Font = MainFont
                TextboxLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextboxLabel.Parent = TextboxFrame

                local TextboxInputBackground = Instance.new("Frame")
                TextboxInputBackground.Size = UDim2.new(0, 110, 0, 24)
                TextboxInputBackground.Position = UDim2.new(1, -112, 0.5, -12)
                SetColor(TextboxInputBackground, "BackgroundColor3", "elementBackground")
                TextboxInputBackground.BackgroundTransparency = 0.21847
                TextboxInputBackground.Parent = TextboxFrame
                
                local TextboxInputBackgroundCorner = Instance.new("UICorner")
                TextboxInputBackgroundCorner.CornerRadius = UDim.new(0, 4)
                TextboxInputBackgroundCorner.Parent = TextboxInputBackground
                
                local TextboxInputBackgroundStroke = Instance.new("UIStroke")
                SetColor(TextboxInputBackgroundStroke, "Color", "borderColor")
                TextboxInputBackgroundStroke.Parent = TextboxInputBackground

                local InputTextBox = Instance.new("TextBox")
                InputTextBox.Size = UDim2.new(1, -10, 1, 0)
                InputTextBox.Position = UDim2.new(0, 5, 0, 0)
                InputTextBox.BackgroundTransparency = 1
                InputTextBox.Text = LibraryApi.Flags[Flag]
                SetColor(InputTextBox, "TextColor3", "textDarkColor")
                InputTextBox.TextSize = 12
                InputTextBox.Font = MainFont
                InputTextBox.ClearTextOnFocus = false
                InputTextBox.TextXAlignment = Enum.TextXAlignment.Left
                InputTextBox.ClipsDescendants = true
                InputTextBox.Parent = TextboxInputBackground

                InputTextBox.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    AnimateElement(TextboxInputBackgroundStroke, {Color = ColorsTable.borderLightColor}, 0.25)
                end)
                InputTextBox.MouseLeave:Connect(function()
                    ShowTooltip("")
                    AnimateElement(TextboxInputBackgroundStroke, {Color = ColorsTable.borderColor}, 0.25)
                end)

                InputTextBox.Focused:Connect(function()
                    AnimateElement(TextboxInputBackgroundStroke, {Color = ColorsTable.accentColor}, 0.25)
                    AnimateElement(InputTextBox, {TextColor3 = ColorsTable.textWhiteColor}, 0.25)
                end)

                InputTextBox.FocusLost:Connect(function()
                    AnimateElement(TextboxInputBackgroundStroke, {Color = ColorsTable.borderColor}, 0.25)
                    AnimateElement(InputTextBox, {TextColor3 = ColorsTable.textDarkColor}, 0.25)
                    LibraryApi.Flags[Flag] = InputTextBox.Text
                    if Callback then task.spawn(Callback, InputTextBox.Text) end
                    TryAutoSave()
                end)

                local function UpdateTextboxVisual()
                    InputTextBox.Text = LibraryApi.Flags[Flag] or ""
                end
                UpdateTextboxVisual()
                RegisterElement(Flag, UpdateTextboxVisual)
            end

            function Elements:KeybindCreate(Name, Flag, Default, Tooltip, Callback)
                if type(LibraryApi.Flags[Flag]) ~= "table" or not LibraryApi.Flags[Flag].Value then
                    local Old = LibraryApi.Flags[Flag]
                    if typeof(Old) == "EnumItem" then
                        if Old.EnumType == Enum.KeyCode then
                            LibraryApi.Flags[Flag] = {Type = "KeyCode", Value = Old, Mode = "Toggle"}
                        else
                            LibraryApi.Flags[Flag] = {Type = "UserInputType", Value = Old, Mode = "Toggle"}
                        end
                    else
                        LibraryApi.Flags[Flag] = {Type = "KeyCode", Value = Default or Enum.KeyCode.Unknown, Mode = "Toggle"}
                    end
                end

                local KeybindData = LibraryApi.Flags[Flag]
                if KeybindData.Mode == "Toggle" and KeybindData.State == nil then KeybindData.State = false end
                local IsListening = false
                local Modes = {"Hold", "Toggle", "Always"}

                local function GetInputDisplay()
                    if not KeybindData or not KeybindData.Value then return "None" end
                    if KeybindData.Value == Enum.KeyCode.Unknown or KeybindData.Value == Enum.UserInputType.None then return "None" end
                    if KeybindData.Type == "KeyCode" then
                        return KeybindData.Value.Name or "None"
                    elseif KeybindData.Type == "UserInputType" then
                        if KeybindData.Value == Enum.UserInputType.MouseButton1 then return "Mouse1"
                        elseif KeybindData.Value == Enum.UserInputType.MouseButton2 then return "Mouse2"
                        elseif KeybindData.Value == Enum.UserInputType.MouseButton3 then return "Mouse3"
                        else return KeybindData.Value.Name end
                    end
                    return "None"
                end

                local KeybindFrame = Instance.new("Frame")
                KeybindFrame.Size = UDim2.new(1, 0, 0, 30)
                KeybindFrame.BackgroundTransparency = 1
                KeybindFrame.Parent = TargetContainer

                local KeybindLabel = Instance.new("TextLabel")
                KeybindLabel.Size = UDim2.new(1, -100, 1, 0)
                KeybindLabel.Position = UDim2.new(0, 2, 0, 0)
                KeybindLabel.BackgroundTransparency = 1
                KeybindLabel.Text = Name
                SetColor(KeybindLabel, "TextColor3", "textWhiteColor")
                KeybindLabel.TextSize = 12
                KeybindLabel.Font = MainFont
                KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
                KeybindLabel.TextTruncate = Enum.TextTruncate.AtEnd
                KeybindLabel.Parent = KeybindFrame

                local KeybindButton = Instance.new("TextButton")
                KeybindButton.Size = UDim2.new(0, 95, 0, 22)
                KeybindButton.Position = UDim2.new(1, -99, 0.5, -11)
                SetColor(KeybindButton, "BackgroundColor3", "elementBackground")
                KeybindButton.BackgroundTransparency = 0.21847
                KeybindButton.Text = "[ " .. GetInputDisplay() .. " ] " .. KeybindData.Mode
                SetColor(KeybindButton, "TextColor3", "textDarkColor")
                KeybindButton.TextSize = 10
                KeybindButton.Font = BoldFont
                KeybindButton.AutoButtonColor = false
                KeybindButton.Parent = KeybindFrame

                local KeybindButtonCorner = Instance.new("UICorner")
                KeybindButtonCorner.CornerRadius = UDim.new(0, 4)
                KeybindButtonCorner.Parent = KeybindButton

                local KeybindButtonStroke = Instance.new("UIStroke")
                SetColor(KeybindButtonStroke, "Color", "borderColor")
                KeybindButtonStroke.Parent = KeybindButton

                KeybindButton.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    if not IsListening then AnimateElement(KeybindButtonStroke, {Color = ColorsTable.borderLightColor}, 0.25) end
                end)
                KeybindButton.MouseLeave:Connect(function()
                    ShowTooltip("")
                    if not IsListening then AnimateElement(KeybindButtonStroke, {Color = ColorsTable.borderColor}, 0.25) end
                end)

                KeybindButton.MouseButton1Click:Connect(function()
                    IsListening = true
                    KeybindButton.Text = "[ ... ]"
                    AnimateElement(KeybindButtonStroke, {Color = ColorsTable.accentColor}, 0.3)
                    AnimateElement(KeybindButton, {TextColor3 = ColorsTable.textWhiteColor}, 0.3)
                end)

                KeybindButton.MouseButton2Click:Connect(function()
                    if KeybindData.Value == Enum.UserInputType.MouseButton2 then return end

                    for _, Child in ipairs(ScreenGui:GetChildren()) do
                        if Child.Name == "KeybindModeMenu" then Child:Destroy() end
                    end

                    local ContextMenu = Instance.new("Frame")
                    ContextMenu.Name = "KeybindModeMenu"
                    ContextMenu.Size = UDim2.new(0, 140, 0, 120)
                    ContextMenu.Position = UDim2.new(0, KeybindButton.AbsolutePosition.X - 10, 0, KeybindButton.AbsolutePosition.Y + KeybindButton.AbsoluteSize.Y + 6)
                    SetColor(ContextMenu, "BackgroundColor3", "elementBackground")
                    ContextMenu.BackgroundTransparency = 0.08
                    ContextMenu.BorderSizePixel = 0
                    ContextMenu.ZIndex = 3500
                    ContextMenu.Parent = ScreenGui
                    
                    local MenuCorner = Instance.new("UICorner")
                    MenuCorner.CornerRadius = UDim.new(0, 8)
                    MenuCorner.Parent = ContextMenu
                    
                    local MenuStroke = Instance.new("UIStroke")
                    SetColor(MenuStroke, "Color", "accentColor")
                    MenuStroke.Thickness = 1.5
                    MenuStroke.Transparency = 0.3
                    MenuStroke.Parent = ContextMenu

                    ApplyAcrylicEffect(ContextMenu, 0.92, UDim.new(0, 8))

                    local MenuContent = Instance.new("Frame")
                    MenuContent.Size = UDim2.new(1, 0, 1, 0)
                    MenuContent.BackgroundTransparency = 1
                    MenuContent.ZIndex = 3501
                    MenuContent.Parent = ContextMenu

                    local ContentPadding = Instance.new("UIPadding")
                    ContentPadding.PaddingLeft = UDim.new(0, 8)
                    ContentPadding.PaddingRight = UDim.new(0, 8)
                    ContentPadding.Parent = MenuContent

                    local MenuLayout = Instance.new("UIListLayout")
                    MenuLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    MenuLayout.Padding = UDim.new(0, 3)
                    MenuLayout.Parent = MenuContent

                    local TitleLabel = Instance.new("TextLabel")
                    TitleLabel.Size = UDim2.new(1, 0, 0, 22)
                    TitleLabel.BackgroundTransparency = 1
                    TitleLabel.Text = "Select Mode"
                    SetColor(TitleLabel, "TextColor3", "textWhiteColor")
                    TitleLabel.TextSize = 11
                    TitleLabel.Font = BoldFont
                    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
                    TitleLabel.ZIndex = 3502
                    TitleLabel.Parent = MenuContent

                    for _, ModeName in ipairs(Modes) do
                        local ModeBtn = Instance.new("TextButton")
                        ModeBtn.Size = UDim2.new(1, -16, 0, 24)
                        ModeBtn.BackgroundColor3 = ColorsTable.elementBackground
                        ModeBtn.BackgroundTransparency = 1
                        ModeBtn.Text = ModeName
                        SetColor(ModeBtn, "TextColor3", KeybindData.Mode == ModeName and "accentColor" or "textWhiteColor")
                        ModeBtn.TextSize = 12
                        ModeBtn.Font = MainFont
                        ModeBtn.TextXAlignment = Enum.TextXAlignment.Left
                        ModeBtn.ZIndex = 3502
                        ModeBtn.Parent = MenuContent
                        
                        local BtnCorner = Instance.new("UICorner")
                        BtnCorner.CornerRadius = UDim.new(0, 5)
                        BtnCorner.Parent = ModeBtn

                        ModeBtn.MouseButton1Click:Connect(function()
                            KeybindData.Mode = ModeName
                            KeybindButton.Text = "[ " .. GetInputDisplay() .. " ] " .. KeybindData.Mode
                            LibraryApi:UpdateUI()
                            ContextMenu:Destroy()
                            if Callback then task.spawn(Callback, KeybindData.State) end
                        end)
                        
                        ModeBtn.MouseEnter:Connect(function()
                            AnimateElement(ModeBtn, {BackgroundTransparency = 0.25, BackgroundColor3 = ColorsTable.elementHoverBackground}, 0.12)
                        end)
                        ModeBtn.MouseLeave:Connect(function()
                            AnimateElement(ModeBtn, {BackgroundTransparency = 1, BackgroundColor3 = ColorsTable.elementBackground}, 0.12)
                        end)
                    end
                end)

                UserInputService.InputBegan:Connect(function(Input, GameProcessed)
                    if IsListening then
                        local NewBind = nil
                        if Input.KeyCode ~= Enum.KeyCode.Unknown and Input.KeyCode ~= Enum.KeyCode.Escape then
                            NewBind = {Type = "KeyCode", Value = Input.KeyCode}
                        elseif Input.UserInputType == Enum.UserInputType.MouseButton1 or
                               Input.UserInputType == Enum.UserInputType.MouseButton2 or
                               Input.UserInputType == Enum.UserInputType.MouseButton3 then
                            NewBind = {Type = "UserInputType", Value = Input.UserInputType}
                        elseif Input.KeyCode == Enum.KeyCode.Escape then
                            NewBind = {Type = "KeyCode", Value = Enum.KeyCode.Unknown}
                        end
                        if NewBind then
                            KeybindData.Type = NewBind.Type
                            KeybindData.Value = NewBind.Value
                            KeybindButton.Text = "[ " .. GetInputDisplay() .. " ] " .. KeybindData.Mode
                            IsListening = false
                            LibraryApi:UpdateUI()
                            AnimateElement(KeybindButtonStroke, {Color = ColorsTable.borderColor}, 0.3)
                            AnimateElement(KeybindButton, {TextColor3 = ColorsTable.textDarkColor}, 0.3)
                            if Callback then task.spawn(Callback, KeybindData.State) end
                            TryAutoSave()
                        end
                    else
                        if GameProcessed then return end 

                        local Matches = false
                        if KeybindData.Type == "KeyCode" and Input.KeyCode == KeybindData.Value then
                            Matches = true
                        elseif KeybindData.Type == "UserInputType" and Input.UserInputType == KeybindData.Value then
                            Matches = true
                        end

                        if Matches and KeybindData.Value ~= Enum.KeyCode.Unknown then
                            if KeybindData.Mode == "Toggle" then
                                KeybindData.State = not (KeybindData.State or false)
                            elseif KeybindData.Mode == "Hold" or KeybindData.Mode == "Always" then
                                KeybindData.State = true
                            end
                            
                            if Callback then task.spawn(Callback, KeybindData.State) end
                            LibraryApi:UpdateUI()
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input, GameProcessed)
                    if IsListening then return end

                    local Matches = false
                    if KeybindData.Type == "KeyCode" and Input.KeyCode == KeybindData.Value then
                        Matches = true
                    elseif KeybindData.Type == "UserInputType" and Input.UserInputType == KeybindData.Value then
                        Matches = true
                    end

                    if Matches and KeybindData.Value ~= Enum.KeyCode.Unknown then
                        if KeybindData.Mode == "Hold" then
                            KeybindData.State = false
                            if Callback then task.spawn(Callback, KeybindData.State) end
                            LibraryApi:UpdateUI()
                        end
                    end
                end)

                local function UpdateKeybindVisual()
                    local CurrentData = LibraryApi.Flags[Flag]
                    local function GetCurrentDisplay()
                        if not CurrentData or not CurrentData.Value then return "None" end
                        if CurrentData.Value == Enum.KeyCode.Unknown or CurrentData.Value == Enum.UserInputType.None then return "None" end
                        if CurrentData.Type == "KeyCode" then
                            return CurrentData.Value.Name or "None"
                        elseif CurrentData.Type == "UserInputType" then
                            if CurrentData.Value == Enum.UserInputType.MouseButton1 then return "Mouse1"
                            elseif CurrentData.Value == Enum.UserInputType.MouseButton2 then return "Mouse2"
                            elseif CurrentData.Value == Enum.UserInputType.MouseButton3 then return "Mouse3"
                            else return CurrentData.Value.Name end
                        end
                        return "None"
                    end
                    KeybindButton.Text = "[ " .. GetCurrentDisplay() .. " ] " .. (CurrentData and CurrentData.Mode or "Toggle")
                end
                UpdateKeybindVisual()
                RegisterElement(Flag, UpdateKeybindVisual)
                AddKeybindToOverlay(Name, Flag)
            end

            function Elements:DropdownCreate(Name, Flag, Options, Default, Tooltip, Callback)
                LibraryApi.Flags[Flag] = LibraryApi.Flags[Flag] ~= nil and LibraryApi.Flags[Flag] or (Default or Options[1])
                local IsDropdownOpen = false
                local CurrentOptions = Options
                local DropdownApi = {}

                local DropdownFrame = Instance.new("Frame")
                DropdownFrame.Size = UDim2.new(1, 0, 0, 46)
                DropdownFrame.BackgroundTransparency = 1
                DropdownFrame.ClipsDescendants = true
                DropdownFrame.Parent = TargetContainer

                local DropdownLabel = Instance.new("TextLabel")
                DropdownLabel.Size = UDim2.new(1, -10, 0, 14)
                DropdownLabel.Position = UDim2.new(0, 2, 0, 0)
                DropdownLabel.BackgroundTransparency = 1
                DropdownLabel.Text = Name
                SetColor(DropdownLabel, "TextColor3", "textWhiteColor")
                DropdownLabel.TextSize = 12
                DropdownLabel.Font = MainFont
                DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
                DropdownLabel.Parent = DropdownFrame

                local DropdownMainButton = Instance.new("TextButton")
                DropdownMainButton.Size = UDim2.new(1, -4, 0, 24)
                DropdownMainButton.Position = UDim2.new(0, 2, 0, 20)
                SetColor(DropdownMainButton, "BackgroundColor3", "elementBackground")
                DropdownMainButton.BackgroundTransparency = 0.21847
                DropdownMainButton.Text = ""
                DropdownMainButton.AutoButtonColor = false
                DropdownMainButton.Parent = DropdownFrame
                
                local DropdownMainButtonCorner = Instance.new("UICorner")
                DropdownMainButtonCorner.CornerRadius = UDim.new(0, 4)
                DropdownMainButtonCorner.Parent = DropdownMainButton
                
                local DropdownMainButtonStroke = Instance.new("UIStroke")
                SetColor(DropdownMainButtonStroke, "Color", "borderColor")
                DropdownMainButtonStroke.Parent = DropdownMainButton

                local SelectedOptionLabel = Instance.new("TextLabel")
                SelectedOptionLabel.Size = UDim2.new(1, -30, 1, 0)
                SelectedOptionLabel.Position = UDim2.new(0, 8, 0, 0)
                SelectedOptionLabel.BackgroundTransparency = 1
                SelectedOptionLabel.Text = LibraryApi.Flags[Flag] or ""
                SetColor(SelectedOptionLabel, "TextColor3", "textDarkColor")
                SelectedOptionLabel.TextSize = 12
                SelectedOptionLabel.Font = MainFont
                SelectedOptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                SelectedOptionLabel.Parent = DropdownMainButton

                local DropdownArrowIcon = Instance.new("ImageLabel")
                DropdownArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                DropdownArrowIcon.Position = UDim2.new(1, -22, 0.5, -7)
                DropdownArrowIcon.BackgroundTransparency = 1
                DropdownArrowIcon.Image = "rbxassetid://6031090656"
                SetColor(DropdownArrowIcon, "ImageColor3", "textDarkColor")
                DropdownArrowIcon.Parent = DropdownMainButton

                local DropdownOptionListFrame = Instance.new("ScrollingFrame")
                DropdownOptionListFrame.Size = UDim2.new(1, -4, 0, 0)
                DropdownOptionListFrame.Position = UDim2.new(0, 2, 0, 48)
                SetColor(DropdownOptionListFrame, "BackgroundColor3", "elementBackground")
                DropdownOptionListFrame.BackgroundTransparency = 0.21847
                DropdownOptionListFrame.BorderSizePixel = 0
                DropdownOptionListFrame.ScrollBarThickness = 2
                SetColor(DropdownOptionListFrame, "ScrollBarImageColor3", "accentColor")
                DropdownOptionListFrame.ClipsDescendants = true
                DropdownOptionListFrame.Parent = DropdownFrame
                
                local DropdownOptionListCorner = Instance.new("UICorner")
                DropdownOptionListCorner.CornerRadius = UDim.new(0, 4)
                DropdownOptionListCorner.Parent = DropdownOptionListFrame
                
                local DropdownOptionListStroke = Instance.new("UIStroke")
                SetColor(DropdownOptionListStroke, "Color", "borderColor")
                DropdownOptionListStroke.Transparency = 1
                DropdownOptionListStroke.Parent = DropdownOptionListFrame

                local DropdownOptionListLayout = Instance.new("UIListLayout")
                DropdownOptionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                DropdownOptionListLayout.Parent = DropdownOptionListFrame

                local function ToggleDropdownState()
                    IsDropdownOpen = not IsDropdownOpen
                    local MaxListHeight = math.min(#CurrentOptions * 24, 120)
                    local TargetListHeight = IsDropdownOpen and MaxListHeight or 0
                    AnimateElement(DropdownMainButtonStroke, {Color = IsDropdownOpen and ColorsTable.accentColor or ColorsTable.borderColor}, 0.3)
                    AnimateElement(DropdownArrowIcon, {Rotation = IsDropdownOpen and 180 or 0, ImageColor3 = IsDropdownOpen and ColorsTable.accentColor or ColorsTable.textDarkColor}, 0.3)
                    AnimateElement(DropdownOptionListFrame, {Size = UDim2.new(1, -4, 0, TargetListHeight)}, 0.3)
                    AnimateElement(DropdownOptionListStroke, {Transparency = IsDropdownOpen and 0 or 1}, 0.3)
                    AnimateElement(DropdownFrame, {Size = UDim2.new(1, 0, 0, 46 + TargetListHeight + (IsDropdownOpen and 4 or 0))}, 0.3)
                end

                DropdownMainButton.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    if not IsDropdownOpen then AnimateElement(DropdownMainButtonStroke, {Color = ColorsTable.borderLightColor}, 0.25) end
                end)
                DropdownMainButton.MouseLeave:Connect(function()
                    ShowTooltip("")
                    if not IsDropdownOpen then AnimateElement(DropdownMainButtonStroke, {Color = ColorsTable.borderColor}, 0.25) end
                end)
                DropdownMainButton.MouseButton1Click:Connect(ToggleDropdownState)

                function DropdownApi:Refresh(NewOptions)
                    CurrentOptions = NewOptions
                    for _, Child in ipairs(DropdownOptionListFrame:GetChildren()) do
                        if Child:IsA("TextButton") then Child:Destroy() end
                    end
                    for _, Option in ipairs(CurrentOptions) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Size = UDim2.new(1, 0, 0, 24)
                        SetColor(OptionButton, "BackgroundColor3", "elementHoverBackground")
                        OptionButton.BackgroundTransparency = 1
                        OptionButton.Text = ""
                        OptionButton.Parent = DropdownOptionListFrame

                        local OptionLabel = Instance.new("TextLabel")
                        OptionLabel.Size = UDim2.new(1, -20, 1, 0)
                        OptionLabel.Position = UDim2.new(0, 8, 0, 0)
                        OptionLabel.BackgroundTransparency = 1
                        OptionLabel.Text = Option
                        SetColor(OptionLabel, "TextColor3", LibraryApi.Flags[Flag] == Option and "accentColor" or "textDarkColor")
                        OptionLabel.TextSize = 12
                        OptionLabel.Font = MainFont
                        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                        OptionLabel.Parent = OptionButton

                        OptionButton.MouseEnter:Connect(function() 
                            AnimateElement(OptionButton, {BackgroundTransparency = 0.21847}, 0.25)
                            if LibraryApi.Flags[Flag] ~= Option then AnimateElement(OptionLabel, {TextColor3 = ColorsTable.textWhiteColor}, 0.25) end
                        end)
                        OptionButton.MouseLeave:Connect(function()
                            AnimateElement(OptionButton, {BackgroundTransparency = 1}, 0.25)
                            if LibraryApi.Flags[Flag] ~= Option then AnimateElement(OptionLabel, {TextColor3 = ColorsTable.textDarkColor}, 0.25) end
                        end)

                        OptionButton.MouseButton1Click:Connect(function()
                            LibraryApi.Flags[Flag] = Option
                            SelectedOptionLabel.Text = Option
                            ToggleDropdownState()
                            for _, Child in ipairs(DropdownOptionListFrame:GetChildren()) do
                                if Child:IsA("TextButton") then
                                    AnimateElement(Child:FindFirstChildOfClass("TextLabel"), {TextColor3 = ColorsTable.textDarkColor}, 0.3)
                                end
                            end
                            AnimateElement(OptionLabel, {TextColor3 = ColorsTable.accentColor}, 0.3)
                            if Callback then task.spawn(Callback, Option) end
                            TryAutoSave()
                        end)
                    end
                    DropdownOptionListFrame.CanvasSize = UDim2.new(0, 0, 0, #CurrentOptions * 24)
                end

                DropdownApi:Refresh(CurrentOptions)

                local function UpdateDropdownVisual()
                    SelectedOptionLabel.Text = LibraryApi.Flags[Flag] or ""
                end
                UpdateDropdownVisual()
                RegisterElement(Flag, UpdateDropdownVisual)
                return DropdownApi
            end

            function Elements:MultiDropdownCreate(Name, Flag, Options, Default, Tooltip, Callback)
                LibraryApi.Flags[Flag] = LibraryApi.Flags[Flag] or (Default or {})
                if type(LibraryApi.Flags[Flag]) ~= "table" then LibraryApi.Flags[Flag] = {} end
                local IsOpen = false
                local CurrentOptions = Options
                local MultiApi = {}

                local MultiFrame = Instance.new("Frame")
                MultiFrame.Size = UDim2.new(1, 0, 0, 46)
                MultiFrame.BackgroundTransparency = 1
                MultiFrame.ClipsDescendants = true
                MultiFrame.Parent = TargetContainer

                local MultiLabel = Instance.new("TextLabel")
                MultiLabel.Size = UDim2.new(1, -10, 0, 14)
                MultiLabel.Position = UDim2.new(0, 2, 0, 0)
                MultiLabel.BackgroundTransparency = 1
                MultiLabel.Text = Name
                SetColor(MultiLabel, "TextColor3", "textWhiteColor")
                MultiLabel.TextSize = 12
                MultiLabel.Font = MainFont
                MultiLabel.TextXAlignment = Enum.TextXAlignment.Left
                MultiLabel.Parent = MultiFrame

                local MultiMainButton = Instance.new("TextButton")
                MultiMainButton.Size = UDim2.new(1, -4, 0, 24)
                MultiMainButton.Position = UDim2.new(0, 2, 0, 20)
                SetColor(MultiMainButton, "BackgroundColor3", "elementBackground")
                MultiMainButton.BackgroundTransparency = 0.21847
                MultiMainButton.Text = ""
                MultiMainButton.AutoButtonColor = false
                MultiMainButton.Parent = MultiFrame
                
                local MultiMainButtonCorner = Instance.new("UICorner")
                MultiMainButtonCorner.CornerRadius = UDim.new(0, 4)
                MultiMainButtonCorner.Parent = MultiMainButton
                
                local MultiMainButtonStroke = Instance.new("UIStroke")
                SetColor(MultiMainButtonStroke, "Color", "borderColor")
                MultiMainButtonStroke.Parent = MultiMainButton

                local SelectedTextLabel = Instance.new("TextLabel")
                SelectedTextLabel.Size = UDim2.new(1, -30, 1, 0)
                SelectedTextLabel.Position = UDim2.new(0, 8, 0, 0)
                SelectedTextLabel.BackgroundTransparency = 1
                SetColor(SelectedTextLabel, "TextColor3", "textDarkColor")
                SelectedTextLabel.TextSize = 11
                SelectedTextLabel.Font = MainFont
                SelectedTextLabel.TextXAlignment = Enum.TextXAlignment.Left
                SelectedTextLabel.Parent = MultiMainButton

                local MultiArrowIcon = Instance.new("ImageLabel")
                MultiArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                MultiArrowIcon.Position = UDim2.new(1, -22, 0.5, -7)
                MultiArrowIcon.BackgroundTransparency = 1
                MultiArrowIcon.Image = "rbxassetid://6031090656"
                SetColor(MultiArrowIcon, "ImageColor3", "textDarkColor")
                MultiArrowIcon.Parent = MultiMainButton

                local MultiOptionListFrame = Instance.new("ScrollingFrame")
                MultiOptionListFrame.Size = UDim2.new(1, -4, 0, 0)
                MultiOptionListFrame.Position = UDim2.new(0, 2, 0, 48)
                SetColor(MultiOptionListFrame, "BackgroundColor3", "elementBackground")
                MultiOptionListFrame.BackgroundTransparency = 0.21847
                MultiOptionListFrame.BorderSizePixel = 0
                MultiOptionListFrame.ScrollBarThickness = 2
                SetColor(MultiOptionListFrame, "ScrollBarImageColor3", "accentColor")
                MultiOptionListFrame.ClipsDescendants = true
                MultiOptionListFrame.Parent = MultiFrame
                
                local MultiOptionListCorner = Instance.new("UICorner")
                MultiOptionListCorner.CornerRadius = UDim.new(0, 4)
                MultiOptionListCorner.Parent = MultiOptionListFrame
                
                local MultiOptionListStroke = Instance.new("UIStroke")
                SetColor(MultiOptionListStroke, "Color", "borderColor")
                MultiOptionListStroke.Transparency = 1
                MultiOptionListStroke.Parent = MultiOptionListFrame

                local MultiOptionListLayout = Instance.new("UIListLayout")
                MultiOptionListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                MultiOptionListLayout.Parent = MultiOptionListFrame

                local function UpdateSelectedText()
                    local Sel = LibraryApi.Flags[Flag]
                    if #Sel == 0 then
                        SelectedTextLabel.Text = "None"
                    elseif #Sel == 1 then
                        SelectedTextLabel.Text = Sel[1]
                    elseif #Sel <= 2 then
                        SelectedTextLabel.Text = table.concat(Sel, ", ")
                    else
                        SelectedTextLabel.Text = #Sel .. " selected"
                    end
                end
                UpdateSelectedText()

                local function ToggleMultiState()
                    IsOpen = not IsOpen
                    local MaxListHeight = math.min(#CurrentOptions * 24 + 4, 160)
                    local TargetListHeight = IsOpen and MaxListHeight or 0
                    AnimateElement(MultiMainButtonStroke, {Color = IsOpen and ColorsTable.accentColor or ColorsTable.borderColor}, 0.3)
                    AnimateElement(MultiArrowIcon, {Rotation = IsOpen and 180 or 0, ImageColor3 = IsOpen and ColorsTable.accentColor or ColorsTable.textDarkColor}, 0.3)
                    AnimateElement(MultiOptionListFrame, {Size = UDim2.new(1, -4, 0, TargetListHeight)}, 0.3)
                    AnimateElement(MultiOptionListStroke, {Transparency = IsOpen and 0 or 1}, 0.3)
                    AnimateElement(MultiFrame, {Size = UDim2.new(1, 0, 0, 46 + TargetListHeight + (IsOpen and 4 or 0))}, 0.3)
                end

                MultiMainButton.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    if not IsOpen then AnimateElement(MultiMainButtonStroke, {Color = ColorsTable.borderLightColor}, 0.25) end
                end)
                MultiMainButton.MouseLeave:Connect(function()
                    ShowTooltip("")
                    if not IsOpen then AnimateElement(MultiMainButtonStroke, {Color = ColorsTable.borderColor}, 0.25) end
                end)
                MultiMainButton.MouseButton1Click:Connect(ToggleMultiState)

                function MultiApi:Refresh(NewOptions)
                    CurrentOptions = NewOptions or CurrentOptions
                    for _, Child in ipairs(MultiOptionListFrame:GetChildren()) do
                        if Child:IsA("TextButton") then Child:Destroy() end
                    end
                    for _, Option in ipairs(CurrentOptions) do
                        local OptionButton = Instance.new("TextButton")
                        OptionButton.Size = UDim2.new(1, 0, 0, 24)
                        SetColor(OptionButton, "BackgroundColor3", "elementHoverBackground")
                        OptionButton.BackgroundTransparency = 1
                        OptionButton.Text = ""
                        OptionButton.Parent = MultiOptionListFrame

                        local CheckFrame = Instance.new("Frame")
                        CheckFrame.Size = UDim2.new(0, 14, 0, 14)
                        CheckFrame.Position = UDim2.new(0, 8, 0.5, -7)
                        local IsSelected = false
                        for _, V in ipairs(LibraryApi.Flags[Flag]) do
                            if V == Option then IsSelected = true break end
                        end
                        SetColor(CheckFrame, "BackgroundColor3", IsSelected and "accentColor" or "elementBackground")
                        CheckFrame.BackgroundTransparency = 0.21847
                        CheckFrame.Parent = OptionButton
                        
                        local CheckCorner = Instance.new("UICorner")
                        CheckCorner.CornerRadius = UDim.new(0, 3)
                        CheckCorner.Parent = CheckFrame
                        
                        local CheckStroke = Instance.new("UIStroke")
                        SetColor(CheckStroke, "Color", IsSelected and "accentColor" or "borderColor")
                        CheckStroke.Parent = CheckFrame

                        local OptionLabel = Instance.new("TextLabel")
                        OptionLabel.Size = UDim2.new(1, -30, 1, 0)
                        OptionLabel.Position = UDim2.new(0, 28, 0, 0)
                        OptionLabel.BackgroundTransparency = 1
                        OptionLabel.Text = Option
                        SetColor(OptionLabel, "TextColor3", "textDarkColor")
                        OptionLabel.TextSize = 12
                        OptionLabel.Font = MainFont
                        OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                        OptionLabel.Parent = OptionButton

                        OptionButton.MouseEnter:Connect(function()
                            AnimateElement(OptionButton, {BackgroundTransparency = 0.21847}, 0.25)
                            AnimateElement(OptionLabel, {TextColor3 = ColorsTable.textWhiteColor}, 0.25)
                        end)
                        OptionButton.MouseLeave:Connect(function()
                            AnimateElement(OptionButton, {BackgroundTransparency = 1}, 0.25)
                            AnimateElement(OptionLabel, {TextColor3 = ColorsTable.textDarkColor}, 0.25)
                        end)

                        OptionButton.MouseButton1Click:Connect(function()
                            local IsCurrentlySelected = false
                            for _, V in ipairs(LibraryApi.Flags[Flag]) do
                                if V == Option then IsCurrentlySelected = true break end
                            end
                            
                            if IsCurrentlySelected then
                                for I = #LibraryApi.Flags[Flag], 1, -1 do
                                    if LibraryApi.Flags[Flag][I] == Option then
                                        table.remove(LibraryApi.Flags[Flag], I)
                                        break
                                    end
                                end
                                AnimateElement(CheckFrame, {BackgroundColor3 = ColorsTable.elementBackground}, 0.2)
                                AnimateElement(CheckStroke, {Color = ColorsTable.borderColor}, 0.2)
                            else
                                table.insert(LibraryApi.Flags[Flag], Option)
                                AnimateElement(CheckFrame, {BackgroundColor3 = ColorsTable.accentColor}, 0.2)
                                AnimateElement(CheckStroke, {Color = ColorsTable.accentColor}, 0.2)
                            end
                            UpdateSelectedText()
                            if Callback then task.spawn(Callback, LibraryApi.Flags[Flag]) end
                            TryAutoSave()
                        end)
                    end
                    MultiOptionListFrame.CanvasSize = UDim2.new(0, 0, 0, #CurrentOptions * 24)
                    UpdateSelectedText()
                end

                MultiApi:Refresh(CurrentOptions)

                local function UpdateMultiDropdownVisual()
                    UpdateSelectedText()
                end
                UpdateMultiDropdownVisual()
                RegisterElement(Flag, UpdateMultiDropdownVisual)
                return MultiApi
            end

            function Elements:ColorPickerCreate(Name, Flag, Default, Tooltip, Callback)
                LibraryApi.Flags[Flag] = LibraryApi.Flags[Flag] ~= nil and LibraryApi.Flags[Flag] or (Default or Color3.new(1, 1, 1))
                local IsColorPickerOpen = false
                local Hue, Saturation, Value = LibraryApi.Flags[Flag]:ToHSV()

                local ColorPickerFrame = Instance.new("Frame")
                ColorPickerFrame.Size = UDim2.new(1, 0, 0, 24)
                ColorPickerFrame.BackgroundTransparency = 1
                ColorPickerFrame.ClipsDescendants = true
                ColorPickerFrame.Parent = TargetContainer

                local ColorPickerLabel = Instance.new("TextLabel")
                ColorPickerLabel.Size = UDim2.new(1, -40, 0, 24)
                ColorPickerLabel.Position = UDim2.new(0, 2, 0, 0)
                ColorPickerLabel.BackgroundTransparency = 1
                ColorPickerLabel.Text = Name
                SetColor(ColorPickerLabel, "TextColor3", "textWhiteColor")
                ColorPickerLabel.TextSize = 12
                ColorPickerLabel.Font = MainFont
                ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
                ColorPickerLabel.Parent = ColorPickerFrame

                local ColorPreviewButton = Instance.new("TextButton")
                ColorPreviewButton.Size = UDim2.new(0, 24, 0, 14)
                ColorPreviewButton.Position = UDim2.new(1, -28, 0, 5)
                ColorPreviewButton.BackgroundColor3 = LibraryApi.Flags[Flag]
                ColorPreviewButton.Text = ""
                ColorPreviewButton.AutoButtonColor = false
                ColorPreviewButton.Parent = ColorPickerFrame
                
                local ColorPreviewButtonCorner = Instance.new("UICorner")
                ColorPreviewButtonCorner.CornerRadius = UDim.new(0, 3)
                ColorPreviewButtonCorner.Parent = ColorPreviewButton
                
                local ColorPreviewButtonStroke = Instance.new("UIStroke")
                SetColor(ColorPreviewButtonStroke, "Color", "borderColor")
                ColorPreviewButtonStroke.Parent = ColorPreviewButton

                local ExpandedPickerFrame = Instance.new("Frame")
                ExpandedPickerFrame.Size = UDim2.new(1, -4, 0, 190)
                ExpandedPickerFrame.Position = UDim2.new(0, 2, 0, 28)
                SetColor(ExpandedPickerFrame, "BackgroundColor3", "elementBackground")
                ExpandedPickerFrame.BackgroundTransparency = 0.21847
                ExpandedPickerFrame.Visible = false
                ExpandedPickerFrame.Parent = ColorPickerFrame
                
                local ExpandedPickerCorner = Instance.new("UICorner")
                ExpandedPickerCorner.CornerRadius = UDim.new(0, 4)
                ExpandedPickerCorner.Parent = ExpandedPickerFrame
                
                local ExpandedPickerStroke = Instance.new("UIStroke")
                SetColor(ExpandedPickerStroke, "Color", "borderColor")
                ExpandedPickerStroke.Parent = ExpandedPickerFrame

                local SaturationValueMap = Instance.new("ImageButton")
                SaturationValueMap.Size = UDim2.new(1, -16, 0, 150)
                SaturationValueMap.Position = UDim2.new(0, 8, 0, 8)
                SaturationValueMap.Image = "rbxassetid://4155801252"
                SaturationValueMap.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
                SaturationValueMap.AutoButtonColor = false
                SaturationValueMap.Parent = ExpandedPickerFrame
                local SaturationValueMapCorner = Instance.new("UICorner"); SaturationValueMapCorner.CornerRadius = UDim.new(0, 3); SaturationValueMapCorner.Parent = SaturationValueMap
                local SaturationValueMapStroke = Instance.new("UIStroke"); SetColor(SaturationValueMapStroke, "Color", "borderColor"); SaturationValueMapStroke.Parent = SaturationValueMap

                local SaturationValueMapCursor = Instance.new("Frame")
                SaturationValueMapCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                SaturationValueMapCursor.Size = UDim2.new(0, 6, 0, 6)
                SaturationValueMapCursor.Position = UDim2.new(1 - Saturation, 0, 1 - Value, 0)
                SaturationValueMapCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                SaturationValueMapCursor.Parent = SaturationValueMap
                local SaturationValueMapCursorCorner = Instance.new("UICorner"); SaturationValueMapCursorCorner.CornerRadius = UDim.new(1, 0); SaturationValueMapCursorCorner.Parent = SaturationValueMapCursor
                local SaturationValueMapCursorStroke = Instance.new("UIStroke"); SaturationValueMapCursorStroke.Color = Color3.new(0, 0, 0); SaturationValueMapCursorStroke.Parent = SaturationValueMapCursor

                local HueMap = Instance.new("TextButton")
                HueMap.Size = UDim2.new(1, -16, 0, 12)
                HueMap.Position = UDim2.new(0, 8, 0, 168)
                HueMap.Text = ""
                HueMap.AutoButtonColor = false
                HueMap.BackgroundColor3 = Color3.new(1, 1, 1)
                HueMap.Parent = ExpandedPickerFrame
                local HueMapCorner = Instance.new("UICorner"); HueMapCorner.CornerRadius = UDim.new(0, 3); HueMapCorner.Parent = HueMap
                local HueMapStroke = Instance.new("UIStroke"); SetColor(HueMapStroke, "Color", "borderColor"); HueMapStroke.Parent = HueMap

                local HueGradient = Instance.new("UIGradient")
                HueGradient.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
                    ColorSequenceKeypoint.new(1/6, Color3.new(1, 1, 0)),
                    ColorSequenceKeypoint.new(2/6, Color3.new(0, 1, 0)),
                    ColorSequenceKeypoint.new(3/6, Color3.new(0, 1, 1)),
                    ColorSequenceKeypoint.new(4/6, Color3.new(0, 0, 1)),
                    ColorSequenceKeypoint.new(5/6, Color3.new(1, 0, 1)),
                    ColorSequenceKeypoint.new(1, Color3.new(1, 0, 0))
                }
                HueGradient.Parent = HueMap

                local HueMapCursor = Instance.new("Frame")
                HueMapCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                HueMapCursor.Size = UDim2.new(0, 4, 1, 4)
                HueMapCursor.Position = UDim2.new(Hue, 0, 0.5, 0)
                HueMapCursor.BackgroundColor3 = Color3.new(1, 1, 1)
                HueMapCursor.Parent = HueMap
                local HueMapCursorCorner = Instance.new("UICorner"); HueMapCursorCorner.CornerRadius = UDim.new(0, 2); HueMapCursorCorner.Parent = HueMapCursor
                local HueMapCursorStroke = Instance.new("UIStroke"); HueMapCursorStroke.Color = Color3.new(0, 0, 0); HueMapCursorStroke.Parent = HueMapCursor

                local function UpdateColorPickerState()
                    local CurrentColor = Color3.fromHSV(Hue, Saturation, Value)
                    LibraryApi.Flags[Flag] = CurrentColor
                    SaturationValueMap.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
                    ColorPreviewButton.BackgroundColor3 = CurrentColor
                    SaturationValueMapCursor.Position = UDim2.new(1 - Saturation, 0, 1 - Value, 0)
                    HueMapCursor.Position = UDim2.new(Hue, 0, 0.5, 0)
                    if Callback then task.spawn(Callback, CurrentColor) end
                    TryAutoSave()
                end

                local IsSlidingSaturationValue = false
                local IsSlidingHue = false

                local function ProcessSaturationValueInput(Input)
                    Saturation = 1 - math.clamp((Input.Position.X - SaturationValueMap.AbsolutePosition.X) / SaturationValueMap.AbsoluteSize.X, 0, 1)
                    Value = 1 - math.clamp((Input.Position.Y - SaturationValueMap.AbsolutePosition.Y) / SaturationValueMap.AbsoluteSize.Y, 0, 1)
                    UpdateColorPickerState()
                end

                local function ProcessHueInput(Input)
                    Hue = math.clamp((Input.Position.X - HueMap.AbsolutePosition.X) / HueMap.AbsoluteSize.X, 0, 1)
                    UpdateColorPickerState()
                end

                SaturationValueMap.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        IsSlidingSaturationValue = true
                        ProcessSaturationValueInput(Input)
                    end
                end)
                
                HueMap.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        IsSlidingHue = true
                        ProcessHueInput(Input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                        IsSlidingSaturationValue = false
                        IsSlidingHue = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
                        if IsSlidingSaturationValue then ProcessSaturationValueInput(Input) end
                        if IsSlidingHue then ProcessHueInput(Input) end
                    end
                end)

                ColorPreviewButton.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    if not IsColorPickerOpen then AnimateElement(ColorPreviewButtonStroke, {Color = ColorsTable.borderLightColor}, 0.25) end
                end)
                ColorPreviewButton.MouseLeave:Connect(function()
                    ShowTooltip("")
                    if not IsColorPickerOpen then AnimateElement(ColorPreviewButtonStroke, {Color = ColorsTable.borderColor}, 0.25) end
                end)

                ColorPreviewButton.MouseButton1Click:Connect(function()
                    local CurrentColor = LibraryApi.Flags[Flag]
                    Hue, Saturation, Value = CurrentColor:ToHSV()
                    SaturationValueMap.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
                    SaturationValueMapCursor.Position = UDim2.new(1 - Saturation, 0, 1 - Value, 0)
                    HueMapCursor.Position = UDim2.new(Hue, 0, 0.5, 0)
                    ColorPreviewButton.BackgroundColor3 = CurrentColor
                    IsColorPickerOpen = not IsColorPickerOpen
                    ExpandedPickerFrame.Visible = IsColorPickerOpen
                    AnimateElement(ColorPreviewButtonStroke, {Color = IsColorPickerOpen and ColorsTable.accentColor or ColorsTable.borderColor}, 0.3)
                    AnimateElement(ColorPickerFrame, {Size = UDim2.new(1, 0, 0, IsColorPickerOpen and 224 or 24)}, 0.3)
                end)

                local function UpdateColorPickerVisual()
                    local CurrentColor = LibraryApi.Flags[Flag]
                    Hue, Saturation, Value = CurrentColor:ToHSV()
                    ColorPreviewButton.BackgroundColor3 = CurrentColor
                    SaturationValueMap.ImageColor3 = Color3.fromHSV(Hue, 1, 1)
                    SaturationValueMapCursor.Position = UDim2.new(1 - Saturation, 0, 1 - Value, 0)
                    HueMapCursor.Position = UDim2.new(Hue, 0, 0.5, 0)
                end
                UpdateColorPickerVisual()
                RegisterElement(Flag, UpdateColorPickerVisual)
            end

            function Elements:ButtonCreate(Name, Tooltip, Callback)
                local ButtonFrame = Instance.new("Frame")
                ButtonFrame.Size = UDim2.new(1, 0, 0, 30)
                ButtonFrame.BackgroundTransparency = 1
                ButtonFrame.Parent = TargetContainer

                local ActionButton = Instance.new("TextButton")
                ActionButton.Size = UDim2.new(1, -4, 1, 0)
                ActionButton.Position = UDim2.new(0, 2, 0, 0)
                SetColor(ActionButton, "BackgroundColor3", "elementBackground")
                ActionButton.BackgroundTransparency = 0.21847
                ActionButton.Text = Name
                SetColor(ActionButton, "TextColor3", "textWhiteColor")
                ActionButton.TextSize = 12
                ActionButton.Font = BoldFont
                ActionButton.AutoButtonColor = false
                ActionButton.Parent = ButtonFrame
                
                local ActionButtonCorner = Instance.new("UICorner")
                ActionButtonCorner.CornerRadius = UDim.new(0, 4)
                ActionButtonCorner.Parent = ActionButton
                
                local ActionButtonStroke = Instance.new("UIStroke")
                SetColor(ActionButtonStroke, "Color", "borderColor")
                ActionButtonStroke.Parent = ActionButton

                ActionButton.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    AnimateElement(ActionButton, {BackgroundColor3 = ColorsTable.elementHoverBackground}, 0.25)
                    AnimateElement(ActionButtonStroke, {Color = ColorsTable.borderLightColor}, 0.25)
                end)
                ActionButton.MouseLeave:Connect(function()
                    ShowTooltip("")
                    AnimateElement(ActionButton, {BackgroundColor3 = ColorsTable.elementBackground}, 0.25)
                    AnimateElement(ActionButtonStroke, {Color = ColorsTable.borderColor}, 0.25)
                end)
                ActionButton.MouseButton1Down:Connect(function() AnimateElement(ActionButton, {Size = UDim2.new(0.96, 0, 0.85, 0), Position = UDim2.new(0.02, 0, 0.075, 0)}, 0.15) end)
                ActionButton.MouseButton1Up:Connect(function()
                    AnimateElement(ActionButton, {Size = UDim2.new(1, -4, 1, 0), Position = UDim2.new(0, 2, 0, 0)}, 0.15)
                    if Callback then task.spawn(Callback) end
                end)
            end

            function Elements:SubButtonCreate(Name, Tooltip, Callback)
                local SubButtonFrame = Instance.new("Frame")
                SubButtonFrame.Size = UDim2.new(1, 0, 0, 22)
                SubButtonFrame.BackgroundTransparency = 1
                SubButtonFrame.Parent = TargetContainer

                local SubButtonAction = Instance.new("TextButton")
                SubButtonAction.Size = UDim2.new(1, -16, 1, 0)
                SubButtonAction.Position = UDim2.new(0, 8, 0, 0)
                SetColor(SubButtonAction, "BackgroundColor3", "sectionBackground")
                SubButtonAction.BackgroundTransparency = 0.21847
                SubButtonAction.Text = Name
                SetColor(SubButtonAction, "TextColor3", "textDarkColor")
                SubButtonAction.TextSize = 11
                SubButtonAction.Font = MainFont
                SubButtonAction.AutoButtonColor = false
                SubButtonAction.Parent = SubButtonFrame
                
                local SubButtonCorner = Instance.new("UICorner")
                SubButtonCorner.CornerRadius = UDim.new(0, 3)
                SubButtonCorner.Parent = SubButtonAction
                
                local SubButtonStroke = Instance.new("UIStroke")
                SetColor(SubButtonStroke, "Color", "borderColor")
                SubButtonStroke.Parent = SubButtonAction

                SubButtonAction.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    AnimateElement(SubButtonAction, {BackgroundColor3 = ColorsTable.elementBackground}, 0.25)
                end)
                SubButtonAction.MouseLeave:Connect(function()
                    ShowTooltip("")
                    AnimateElement(SubButtonAction, {BackgroundColor3 = ColorsTable.sectionBackground}, 0.25)
                end)
                SubButtonAction.MouseButton1Down:Connect(function() AnimateElement(SubButtonAction, {Size = UDim2.new(0.96, -16, 0.85, 0), Position = UDim2.new(0.02, 8, 0.075, 0)}, 0.15) end)
                SubButtonAction.MouseButton1Up:Connect(function()
                    AnimateElement(SubButtonAction, {Size = UDim2.new(1, -16, 1, 0), Position = UDim2.new(0, 8, 0, 0)}, 0.15)
                    if Callback then task.spawn(Callback) end
                end)
            end

            function Elements:ModuleCreate(Name, Flag, DescriptionText, Default, Tooltip, Callback)
                LibraryApi.Flags[Flag] = LibraryApi.Flags[Flag] ~= nil and LibraryApi.Flags[Flag] or (Default or false)

                local DescBounds = TextService:GetTextSize(DescriptionText, 11, MainFont, Vector2.new(9999, 60))
                local DescHeight = math.clamp(DescBounds.Y, 14, 36)
                local HeaderBaseHeight = 22 + DescHeight + 8

                local ModuleFrame = Instance.new("Frame")
                ModuleFrame.Size = UDim2.new(1, 0, 0, HeaderBaseHeight + 2)
                ModuleFrame.BackgroundTransparency = 1
                ModuleFrame.ClipsDescendants = true
                ModuleFrame.Parent = TargetContainer

                local ModuleToggleButton = Instance.new("TextButton")
                ModuleToggleButton.Size = UDim2.new(1, -4, 0, HeaderBaseHeight)
                ModuleToggleButton.Position = UDim2.new(0, 2, 0, 0)
                SetColor(ModuleToggleButton, "BackgroundColor3", "elementBackground")
                ModuleToggleButton.BackgroundTransparency = 0.21847
                ModuleToggleButton.Text = ""
                ModuleToggleButton.AutoButtonColor = false
                ModuleToggleButton.Parent = ModuleFrame
                
                local ModuleToggleButtonCorner = Instance.new("UICorner")
                ModuleToggleButtonCorner.CornerRadius = UDim.new(0, 6)
                ModuleToggleButtonCorner.Parent = ModuleToggleButton
                
                local ModuleToggleButtonStroke = Instance.new("UIStroke")
                SetColor(ModuleToggleButtonStroke, "Color", LibraryApi.Flags[Flag] and "accentColor" or "borderColor")
                ModuleToggleButtonStroke.Parent = ModuleToggleButton

                local ModuleCheckboxFrame = Instance.new("Frame")
                ModuleCheckboxFrame.Size = UDim2.new(0, 16, 0, 16)
                ModuleCheckboxFrame.Position = UDim2.new(0, 14, 0, 8)
                SetColor(ModuleCheckboxFrame, "BackgroundColor3", LibraryApi.Flags[Flag] and "accentColor" or "sectionBackground")
                ModuleCheckboxFrame.BackgroundTransparency = 0.21847
                ModuleCheckboxFrame.Parent = ModuleToggleButton
                
                local ModuleCheckboxCorner = Instance.new("UICorner")
                ModuleCheckboxCorner.CornerRadius = UDim.new(0, 4)
                ModuleCheckboxCorner.Parent = ModuleCheckboxFrame
                
                local ModuleCheckboxStroke = Instance.new("UIStroke")
                SetColor(ModuleCheckboxStroke, "Color", "borderColor")
                ModuleCheckboxStroke.Parent = ModuleCheckboxFrame

                local ModuleLabel = Instance.new("TextLabel")
                ModuleLabel.Size = UDim2.new(1, -45, 0, 16)
                ModuleLabel.Position = UDim2.new(0, 40, 0, 6)
                ModuleLabel.BackgroundTransparency = 1
                ModuleLabel.Text = Name
                SetColor(ModuleLabel, "TextColor3", LibraryApi.Flags[Flag] and "textWhiteColor" or "textDarkColor")
                ModuleLabel.TextSize = 13
                ModuleLabel.Font = BoldFont
                ModuleLabel.TextXAlignment = Enum.TextXAlignment.Left
                ModuleLabel.Parent = ModuleToggleButton

                local ModuleDescriptionLabel = Instance.new("TextLabel")
                ModuleDescriptionLabel.Size = UDim2.new(1, -45, 0, DescHeight)
                ModuleDescriptionLabel.Position = UDim2.new(0, 40, 0, 22)
                ModuleDescriptionLabel.BackgroundTransparency = 1
                ModuleDescriptionLabel.Text = DescriptionText
                ModuleDescriptionLabel.TextWrapped = true
                SetColor(ModuleDescriptionLabel, "TextColor3", "textDarkColor")
                ModuleDescriptionLabel.TextSize = 11
                ModuleDescriptionLabel.Font = MainFont
                ModuleDescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
                ModuleDescriptionLabel.Parent = ModuleToggleButton

                local ModuleArrowIcon = Instance.new("ImageLabel")
                ModuleArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                ModuleArrowIcon.Position = UDim2.new(1, -22, 1, -18)
                ModuleArrowIcon.BackgroundTransparency = 1
                ModuleArrowIcon.Image = "rbxassetid://6031090656"
                SetColor(ModuleArrowIcon, "ImageColor3", LibraryApi.Flags[Flag] and "accentColor" or "textDarkColor")
                ModuleArrowIcon.Rotation = LibraryApi.Flags[Flag] and 180 or 0
                ModuleArrowIcon.Parent = ModuleToggleButton

                local ModuleContentFrame = Instance.new("Frame")
                ModuleContentFrame.Size = UDim2.new(1, -16, 0, 0)
                ModuleContentFrame.Position = UDim2.new(0, 12, 0, HeaderBaseHeight + 4)
                ModuleContentFrame.BackgroundTransparency = 1
                ModuleContentFrame.Parent = ModuleFrame

                local ModuleContentLayout = Instance.new("UIListLayout")
                ModuleContentLayout.Padding = UDim.new(0, 8)
                ModuleContentLayout.Parent = ModuleContentFrame

                local function SynchronizeModuleSize()
                    if LibraryApi.Flags[Flag] then
                        AnimateElement(ModuleFrame, {Size = UDim2.new(1, 0, 0, HeaderBaseHeight + ModuleContentLayout.AbsoluteContentSize.Y + 8)}, 0.3)
                        AnimateElement(ModuleArrowIcon, {Rotation = 180, ImageColor3 = ColorsTable.accentColor}, 0.3)
                    else
                        AnimateElement(ModuleFrame, {Size = UDim2.new(1, 0, 0, HeaderBaseHeight)}, 0.3)
                        AnimateElement(ModuleArrowIcon, {Rotation = 0, ImageColor3 = ColorsTable.textDarkColor}, 0.3)
                    end
                end

                ModuleContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                    if LibraryApi.Flags[Flag] then SynchronizeModuleSize() end
                end)

                ModuleToggleButton.MouseEnter:Connect(function()
                    ShowTooltip(Tooltip)
                    if not LibraryApi.Flags[Flag] then AnimateElement(ModuleToggleButtonStroke, {Color = ColorsTable.borderLightColor}, 0.25) end
                end)
                ModuleToggleButton.MouseLeave:Connect(function()
                    ShowTooltip("")
                    if not LibraryApi.Flags[Flag] then AnimateElement(ModuleToggleButtonStroke, {Color = ColorsTable.borderColor}, 0.25) end
                end)

                ModuleToggleButton.MouseButton1Click:Connect(function()
                    LibraryApi.Flags[Flag] = not LibraryApi.Flags[Flag]
                    local NewState = LibraryApi.Flags[Flag]
                    AnimateElement(ModuleCheckboxFrame, {BackgroundColor3 = NewState and ColorsTable.accentColor or ColorsTable.sectionBackground}, 0.3)
                    AnimateElement(ModuleToggleButtonStroke, {Color = NewState and ColorsTable.accentColor or ColorsTable.borderColor}, 0.3)
                    AnimateElement(ModuleLabel, {TextColor3 = NewState and ColorsTable.textWhiteColor or ColorsTable.textDarkColor}, 0.3)
                    SynchronizeModuleSize()
                    if Callback then task.spawn(Callback, NewState) end
                    TryAutoSave()
                end)

                local function UpdateModuleVisual()
                    local CurrentState = LibraryApi.Flags[Flag]
                    ModuleCheckboxFrame.BackgroundColor3 = CurrentState and ColorsTable.accentColor or ColorsTable.sectionBackground
                    ModuleToggleButtonStroke.Color = CurrentState and ColorsTable.accentColor or ColorsTable.borderColor
                    ModuleLabel.TextColor3 = CurrentState and ColorsTable.textWhiteColor or ColorsTable.textDarkColor
                    SynchronizeModuleSize()
                end
                UpdateModuleVisual()
                RegisterElement(Flag, UpdateModuleVisual)

                return ElementInjector(ModuleContentFrame)
            end

            return Elements
        end

        local SectionApi = {}

        function SectionApi:SectionCreate(ColumnSide, SectionTitle)
            local SectionBackgroundFrame = Instance.new("Frame")
            SectionBackgroundFrame.Size = UDim2.new(1, 0, 0, 40)
            SetColor(SectionBackgroundFrame, "BackgroundColor3", "sectionBackground")
            SectionBackgroundFrame.BackgroundTransparency = 0.21847
            SectionBackgroundFrame.Parent = (ColumnSide == "Left") and LeftColumnFrame or RightColumnFrame
            
            local SectionBackgroundCorner = Instance.new("UICorner")
            SectionBackgroundCorner.CornerRadius = UDim.new(0, 8)
            SectionBackgroundCorner.Parent = SectionBackgroundFrame
            
            local SectionBackgroundStroke = Instance.new("UIStroke")
            SetColor(SectionBackgroundStroke, "Color", "borderColor")
            SectionBackgroundStroke.Parent = SectionBackgroundFrame

            local SectionHeaderFrame = Instance.new("Frame")
            SectionHeaderFrame.Size = UDim2.new(1, 0, 0, 26)
            SectionHeaderFrame.BackgroundTransparency = 1
            SectionHeaderFrame.Parent = SectionBackgroundFrame

            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Size = UDim2.new(1, -20, 1, 0)
            SectionLabel.Position = UDim2.new(0, 10, 0, 0)
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Text = SectionTitle
            SetColor(SectionLabel, "TextColor3", "textWhiteColor")
            SectionLabel.TextSize = 12
            SectionLabel.Font = BoldFont
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
            SectionLabel.Parent = SectionHeaderFrame

            local SectionSeparatorLine = Instance.new("Frame")
            SectionSeparatorLine.Size = UDim2.new(1, -20, 0, 1)
            SectionSeparatorLine.Position = UDim2.new(0, 10, 1, 0)
            SetColor(SectionSeparatorLine, "BackgroundColor3", "borderColor")
            SectionSeparatorLine.BorderSizePixel = 0
            SectionSeparatorLine.Parent = SectionHeaderFrame

            local SectionContentFrame = Instance.new("Frame")
            SectionContentFrame.Size = UDim2.new(1, -16, 1, -34)
            SectionContentFrame.Position = UDim2.new(0, 8, 0, 32)
            SectionContentFrame.BackgroundTransparency = 1
            SectionContentFrame.Parent = SectionBackgroundFrame

            local SectionContentLayout = Instance.new("UIListLayout")
            SectionContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionContentLayout.Padding = UDim.new(0, 8)
            SectionContentLayout.Parent = SectionContentFrame

            RunService.RenderStepped:Connect(function()
                SectionBackgroundFrame.Size = UDim2.new(1, 0, 0, SectionContentLayout.AbsoluteContentSize.Y + 44)
            end)

            return ElementInjector(SectionContentFrame)
        end

        return SectionApi
    end

    local ProfileTab = WindowContext:TabCreate("radiant.rip", nil, true)
    
    local ConfigSection = ProfileTab:SectionCreate("Left", "System & Configuration")
    local ConfigDropdown = ConfigSection:DropdownCreate("Saved Configs", "SelectedConfig", GetConfigList(), "Select a configuration", "Select config to load, overwrite or delete", function(Val) end)
    
    ConfigSection:ButtonCreate("Refresh Configs", "Update the list of saved configurations", function()
        ConfigDropdown:Refresh(GetConfigList())
        LibraryApi:Notify({Title = "System", Text = "Configuration list refreshed.", Duration = 2, Type = "Info"})
    end)
    
    ConfigSection:TextboxCreate("New Config Name", "NewConfigName", "", "Name for a new config file", function(Val) end)
    
    ConfigSection:ButtonCreate("Save New Config", "Saves current settings to the new name", function() 
        local Name = LibraryApi.Flags["NewConfigName"]
        if Name and Name ~= "" then
            SaveConfiguration(Name)
            ConfigDropdown:Refresh(GetConfigList())
            LibraryApi:Notify({Title = "System", Text = "Saved new configuration: " .. Name, Duration = 3, Type = "Success"})
        else
            LibraryApi:Notify({Title = "Error", Text = "Config name cannot be empty.", Duration = 3, Type = "Error"})
        end
    end)

    ConfigSection:ButtonCreate("Overwrite Selected", "Overwrites the config selected in the dropdown", function() 
        local Name = LibraryApi.Flags["SelectedConfig"]
        if Name and Name ~= "" then
            SaveConfiguration(Name)
            LibraryApi:Notify({Title = "System", Text = "Overwrote configuration: " .. Name, Duration = 3, Type = "Success"})
        else
            LibraryApi:Notify({Title = "Error", Text = "No configuration selected to overwrite.", Duration = 3, Type = "Error"})
        end
    end)

    ConfigSection:ButtonCreate("Load Selected", "Loads the config selected in the dropdown", function() 
        local Name = LibraryApi.Flags["SelectedConfig"]
        if Name and Name ~= "" then
            LoadConfiguration(Name)
            LibraryApi:UpdateUI()
            LibraryApi:Notify({Title = "System", Text = "Loaded configuration: " .. Name, Duration = 3, Type = "Info"})
        else
            LibraryApi:Notify({Title = "Error", Text = "No configuration selected to load.", Duration = 3, Type = "Error"})
        end
    end)

    ConfigSection:ButtonCreate("Delete Selected", "Deletes the config selected in the dropdown", function() 
        local Name = LibraryApi.Flags["SelectedConfig"]
        if Name and Name ~= "" then
            pcall(function() delfile(LibraryApi.FolderName .. "/" .. Name .. ".json") end)
            ConfigDropdown:Refresh(GetConfigList())
            LibraryApi:Notify({Title = "System", Text = "Deleted configuration: " .. Name, Duration = 3, Type = "Warning"})
        end
    end)
    
    local ThemeSection = ProfileTab:SectionCreate("Right", "Theme Customization")
    
    local ThemeNames = {}
    for TName, _ in pairs(PresetThemes) do table.insert(ThemeNames, TName) end
    
    ThemeSection:DropdownCreate("Preset Themes", "SelectedTheme", ThemeNames, "Radiant Green", "Select a pre-made theme", function(Val)
        if PresetThemes[Val] then
            for K, V in pairs(PresetThemes[Val]) do
                ColorsTable[K] = V
            end
            UpdateTheme()
            LibraryApi:Notify({Title = "Theme", Text = "Applied preset: " .. Val, Duration = 3, Type = "Info"})
        end
    end)

    ThemeSection:SubtextCreate("Custom Colors")

    local function HexFormat(Str)
        return Str:gsub("_", " "):gsub("^%l", string.upper)
    end

    for Key, DefaultColor in pairs(ColorsTable) do
        if not Key:match("notification") and not Key:match("gradient") then
            ThemeSection:ColorPickerCreate(HexFormat(Key), "ThemeColor_" .. Key, DefaultColor, "Change " .. HexFormat(Key), function(NewColor)
                ColorsTable[Key] = NewColor
                if Key == "accentColor" then
                    ColorsTable.accentGradient1 = NewColor
                    ColorsTable.accentGradient2 = Color3.new(NewColor.R * 0.7, NewColor.G * 0.7, NewColor.B * 0.7)
                end
                UpdateTheme()
            end)
        end
    end

    local MenuSection = ProfileTab:SectionCreate("Right", "Menu Controls")
    MenuSection:KeybindCreate("Menu Toggle Bind", "MenuToggleKey", Enum.KeyCode.Delete, "Key to hide/show menu", function() end)
    MenuSection:ToggleCreate("Keybinds Overlay", "KeybindOverlayEnabled", true, "Show or hide the on-screen keybinds list", function(State) end)
    MenuSection:ButtonCreate("Unload Script", "Removes the UI completely", function() ScreenGui:Destroy() end)

    UserInputService.InputBegan:Connect(function(Input, GameProcessedEvent)
        if not GameProcessedEvent then
            local MenuBind = LibraryApi.Flags["MenuToggleKey"]
            local Matches = false
            if MenuBind and MenuBind.Type == "KeyCode" and Input.KeyCode == MenuBind.Value then
                Matches = true
            elseif MenuBind and MenuBind.Type == "UserInputType" and Input.UserInputType == MenuBind.Value then
                Matches = true
            end
            if Matches then
                MainBackground.Visible = not MainBackground.Visible
            end
        end
    end)

    if LibraryApi.AutoLoad then
        pcall(function()
            if isfile and isfile(LibraryApi.FolderName .. "/LastConfig.txt") then
                local lastName = readfile(LibraryApi.FolderName .. "/LastConfig.txt")
                if lastName and lastName ~= "" then
                    LoadConfiguration(lastName)
                    LibraryApi.SelectedConfig = lastName
                    LibraryApi:UpdateUI()
                    if LibraryApi.WindowPosition then
                        MainBackground.Position = LibraryApi.WindowPosition
                        TargetPosition = LibraryApi.WindowPosition
                    end
                    if ConfigDropdown then
                        ConfigDropdown:Refresh(GetConfigList())
                    end
                end
            end
        end)
    end

    return WindowContext
end

return LibraryApi
