
local LoadingTick = os.clock()

local ExistingLibrary =
    getgenv().Library

if type(ExistingLibrary)
        == "table"
    and type(
        ExistingLibrary.Unload
    ) == "function"
then
    pcall(function()
        ExistingLibrary:
            Unload()
    end)
end

local Library
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local GuiService = game:GetService("GuiService")
    local CoreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")

    gethui = gethui or function()
        return CoreGui
    end

    local LocalPlayer = Players.LocalPlayer
    local Camera = Workspace.CurrentCamera
    local Mouse = LocalPlayer:GetMouse()

    local FromRGB = Color3.fromRGB
    local FromHSV = Color3.fromHSV
    local FromHex = Color3.fromHex

    local RGBSequence = ColorSequence.new
    local RGBSequenceKeypoint = ColorSequenceKeypoint.new

    local NumSequence = NumberSequence.new
    local NumSequenceKeypoint = NumberSequenceKeypoint.new

    local UDim2New = UDim2.new
    local UDimNew = UDim.new
    local Vector2New = Vector2.new

    local InstanceNew = Instance.new

    local MathClamp = math.clamp
    local MathFloor = math.floor

    local TableInsert = table.insert
    local TableFind = table.find
    local TableRemove = table.remove
    local TableConcat = table.concat
    local TableUnpack = table.unpack

    local StringFormat = string.format
    local StringFind = string.find
    local StringGSub = string.gsub

    Library = {
        Build = "RadiantAdaptive-v13.3-AimIconDropdownRail",
        Flags = { },

        Theme = {
            ["Background"] = FromRGB(9, 11, 12),
            ["Inline"] = FromRGB(13, 16, 17),
            ["Page Background"] = FromRGB(17, 20, 21),
            ["Border"] = FromRGB(3, 5, 5),
            ["Outline"] = FromRGB(39, 45, 45),
            ["Accent"] = FromRGB(54, 218, 145),
            ["Element"] = FromRGB(23, 27, 28),
            ["Hovered Element"] = FromRGB(31, 37, 37),
            ["Text"] = FromRGB(226, 232, 230),
            ["Text Border"] = FromRGB(0, 0, 0),
            ["Glass Edge"] = FromRGB(150, 224, 190),
            ["Muted Text"] = FromRGB(158, 178, 169),
            ["Danger"] = FromRGB(235, 72, 72)
        },

        Glass = {
            Enabled = false,
            BlurSize = 0,
            CornerRadius = 10,
            WindowTransparency = 0,
            PanelTransparency = 0,
            ElementTransparency = 0,
            PopupTransparency = 0,
            FloatingTransparency = 0.03
        },

        GlassBlur = nil,
        GlassBlurTween = nil,

        MenuKeybind = Enum.KeyCode.Z,

        Tween = {
            Time = 0.12,
            Style = Enum.EasingStyle.Quad,
            Direction = Enum.EasingDirection.Out
        },

        Folders = {
            Directory = "scriptname",
            Configs = "scriptname/Configs",
            Assets = "scriptname/Assets"
        },

        Images = {
            ["Saturation"] = {"Saturation.png", "https://github.com/sametexe001/images/blob/main/saturation.png?raw=true" },
            ["Value"] = { "Value.png", "https://github.com/sametexe001/images/blob/main/value.png?raw=true" },
            ["Hue"] = { "Hue.png", "https://github.com/sametexe001/images/blob/main/hue.png?raw=true" },
            ["Scrollbar"] =  { "Scrollbar.png", "https://github.com/sametexe001/images/blob/main/scrollbar.png?raw=true" },
            ["Checkers"] = { "Checkers.png", "https://github.com/sametexe001/images/blob/main/checkers.png?raw=true" },
            ["Resize"] = { "Resize.png", "https://github.com/sametexe001/images/blob/main/resize.png?raw=true" },
        },

        Pages = { },
        Sections = { },
        Connections = { },
        CoreConnections = { },
        Threads = { },
        ActiveTweens = setmetatable({}, {__mode = "k"}),
        ActiveSlider = nil,
        SliderConnection = nil,
        ActiveColorpicker = nil,
        ColorpickerConnection = nil,
        ColorpickerInputConnection = nil,
        ColorpickerOverlay = nil,
        Colorpickers = {},
        InputListeners = {
            Began = {},
            Changed = {},
            Ended = {}
        },
        ThemeMap = { },
        ThemeItems = { },

        SetFlags = { },
        KeybindMetadata = { },

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        NotifHolder = nil,
        Font = nil,
        KeyList = nil,
        ActiveWatermark = nil,
        NotificationsHidden = false,
        QuickSettingsWindow = nil,

        CurrentColorpicker = nil,
        CurrentKeybind = nil,
        ActiveKeyPicker = nil,
        SuppressKeybindInput = nil,
        InputRouterReady = false,
        Unloading = false,
        Unloaded = false
    }

    Library.__index = Library
    Library.Sections.__index = Library.Sections
    Library.Pages.__index = Library.Pages

    local Keys = {
        ["Unknown"]           = "Unknown",
        ["Backspace"]         = "Back",
        ["Tab"]               = "Tab",
        ["Clear"]             = "Clear",
        ["Return"]            = "Return",
        ["Pause"]             = "Pause",
        ["Escape"]            = "Escape",
        ["Space"]             = "Space",
        ["QuotedDouble"]      = '"',
        ["Hash"]              = "#",
        ["Dollar"]            = "$",
        ["Percent"]           = "%",
        ["Ampersand"]         = "&",
        ["Quote"]             = "'",
        ["LeftParenthesis"]   = "(",
        ["RightParenthesis"]  = ")",
        ["Asterisk"]          = "*",
        ["Plus"]              = "+",
        ["Comma"]             = ",",
        ["Minus"]             = "-",
        ["Period"]            = ".",
        ["Slash"]             = "/",
        ["Three"]             = "3",
        ["Seven"]             = "7",
        ["Eight"]             = "8",
        ["Colon"]             = ":",
        ["Semicolon"]         = ";",
        ["LessThan"]          = "<",
        ["GreaterThan"]       = ">",
        ["Question"]          = "?",
        ["Equals"]            = "=",
        ["At"]                = "@",
        ["LeftBracket"]       = "LeftBracket",
        ["RightBracket"]      = "RightBracked",
        ["BackSlash"]         = "BackSlash",
        ["Caret"]             = "^",
        ["Underscore"]        = "_",
        ["Backquote"]         = "`",
        ["LeftCurly"]         = "{",
        ["Pipe"]              = "|",
        ["RightCurly"]        = "}",
        ["Tilde"]             = "~",
        ["Delete"]            = "Delete",
        ["End"]               = "End",
        ["KeypadZero"]        = "Keypad0",
        ["KeypadOne"]         = "Keypad1",
        ["KeypadTwo"]         = "Keypad2",
        ["KeypadThree"]       = "Keypad3",
        ["KeypadFour"]        = "Keypad4",
        ["KeypadFive"]        = "Keypad5",
        ["KeypadSix"]         = "Keypad6",
        ["KeypadSeven"]       = "Keypad7",
        ["KeypadEight"]       = "Keypad8",
        ["KeypadNine"]        = "Keypad9",
        ["KeypadPeriod"]      = "KeypadP",
        ["KeypadDivide"]      = "KeypadD",
        ["KeypadMultiply"]    = "KeypadM",
        ["KeypadMinus"]       = "KeypadM",
        ["KeypadPlus"]        = "KeypadP",
        ["KeypadEnter"]       = "KeypadE",
        ["KeypadEquals"]      = "KeypadE",
        ["Insert"]            = "Insert",
        ["Home"]              = "Home",
        ["PageUp"]            = "PageUp",
        ["PageDown"]          = "PageDown",
        ["RightShift"]        = "RightShift",
        ["LeftShift"]         = "LeftShift",
        ["RightControl"]      = "RightControl",
        ["LeftControl"]       = "LeftControl",
        ["LeftAlt"]           = "LeftAlt",
        ["RightAlt"]          = "RightAlt"
    }

    for _, FileName in Library.Folders do
        if not isfolder(FileName) then
            makefolder(FileName)
        end
    end

    for _, ImageData in Library.Images do
        local ImageName = ImageData[1]
        local ImageLink = ImageData[2]

        if not isfile(Library.Folders.Assets .. "/" .. ImageName) then
            writefile(Library.Folders.Assets .. "/" .. ImageName, game:HttpGet(ImageLink))
        end
    end

    local Tween = { } do
        Tween.__index = Tween

        local function RemoveTween(
            Item,
            TweenObject
        )
            local ItemTweens =
                Library.ActiveTweens[
                    Item
                ]

            if not ItemTweens then
                return
            end

            for Property, ActiveTween in pairs(
                ItemTweens
            ) do
                if ActiveTween
                    == TweenObject
                then
                    ItemTweens[
                        Property
                    ] = nil
                end
            end

            if next(ItemTweens) == nil then
                Library.ActiveTweens[
                    Item
                ] = nil
            end
        end

        Tween.Create = function(
            self,
            Item,
            Info,
            Goal,
            IsRawItem
        )
            Item =
                IsRawItem
                and Item
                or Item.Instance

            if not Item
                or Library.Unloaded
            then
                return nil
            end

            Info =
                Info
                or TweenInfo.new(
                    Library.Tween.Time,
                    Library.Tween.Style,
                    Library.Tween.Direction
                )

            local ItemTweens =
                Library.ActiveTweens[
                    Item
                ]

            if not ItemTweens then
                ItemTweens = {}

                Library.ActiveTweens[
                    Item
                ] = ItemTweens
            end

            for Property in pairs(
                Goal
            ) do
                local ActiveTween =
                    ItemTweens[
                        Property
                    ]

                if ActiveTween then
                    pcall(function()
                        ActiveTween:
                            Cancel()
                    end)
                end
            end

            local RobloxTween =
                TweenService:
                Create(
                    Item,
                    Info,
                    Goal
                )

            local NewTween = {
                Tween = RobloxTween,
                Info = Info,
                Goal = Goal,
                Item = Item,
                CompletedConnection = nil
            }

            setmetatable(
                NewTween,
                Tween
            )

            for Property in pairs(
                Goal
            ) do
                ItemTweens[
                    Property
                ] = RobloxTween
            end

            NewTween.CompletedConnection =
                RobloxTween.Completed:
                Connect(function()
                    RemoveTween(
                        Item,
                        RobloxTween
                    )

                    if NewTween.CompletedConnection then
                        NewTween.CompletedConnection:
                            Disconnect()

                        NewTween.CompletedConnection =
                            nil
                    end
                end)

            RobloxTween:Play()

            return NewTween
        end

        Tween.Get = function(self)
            if not self.Tween then
                return
            end

            return self.Tween,
                self.Info,
                self.Goal
        end

        Tween.Pause = function(self)
            if self.Tween then
                pcall(function()
                    self.Tween:
                        Pause()
                end)
            end
        end

        Tween.Play = function(self)
            if self.Tween then
                pcall(function()
                    self.Tween:
                        Play()
                end)
            end
        end

        Tween.Clean = function(self)
            if self.CompletedConnection then
                self.CompletedConnection:
                    Disconnect()

                self.CompletedConnection =
                    nil
            end

            if self.Tween then
                pcall(function()
                    self.Tween:
                        Cancel()
                end)

                RemoveTween(
                    self.Item,
                    self.Tween
                )

                self.Tween = nil
            end
        end
    end

    local Instances = { } do
        Instances.__index = Instances

        Instances.Create = function(self, Class, Properties)
            local NewItem = {
                Instance = InstanceNew(Class),
                Properties = Properties,
                Class = Class
            }

            setmetatable(NewItem, Instances)

            for Property, Value in NewItem.Properties do
                NewItem.Instance[Property] = Value
            end

            return NewItem
        end

        Instances.Border = function(self)
            if not self.Instance then
                return
            end

            local Item = self.Instance
            local UIStroke = Instances:Create("UIStroke", {
                Parent = Item,
                Color = Library.Theme.Border,
                Thickness = 1,
                LineJoinMode = Enum.LineJoinMode.Miter
            })

            UIStroke:AddToTheme({Color = "Border"})

            return UIStroke
        end

        Instances.AddToTheme = function(self, Properties)
            if not self.Instance then
                return
            end

            Library:AddToTheme(self, Properties)
        end

        Instances.ChangeItemTheme = function(self, Properties)
            if not self.Instance then
                return
            end

            Library:ChangeItemTheme(self, Properties)
        end

        Instances.Connect = function(self, Event, Callback, Name)
            if not self.Instance then
                return
            end

            if not self.Instance[Event] then
                return
            end

            return Library:Connect(self.Instance[Event], Callback, Name)
        end

        Instances.Tween = function(self, Info, Goal)
            if not self.Instance then
                return
            end

            return Tween:Create(self, Info, Goal)
        end

        Instances.Disconnect = function(self, Name)
            if not self.Instance then
                return
            end

            return Library:Disconnect(Name)
        end

        Instances.Clean = function(self)
            if not self.Instance then
                return
            end

            self.Instance:Destroy()
            self = nil
        end

        Instances.MakeDraggable = function(
            self,
            Handle,
            Smoothness
        )
            if not self.Instance then
                return
            end

            local Gui = self.Instance
            local DragHandle =
                Handle
                and (Handle.Instance or Handle)
                or Gui

            if DragHandle:IsA("GuiObject") then
                DragHandle.Active = true
            end

            local Dragging = false
            local StartMouse = nil
            local StartPosition = nil
            local PendingPosition = nil
            local MoveConnection = nil
            local EndConnection = nil
            local RenderConnection = nil

            local function Disconnect(Connection)
                if Connection then
                    pcall(function()
                        Connection:Disconnect()
                    end)
                end
            end

            local function ApplyPending()
                if PendingPosition
                    and Gui.Parent
                then
                    Gui.Position = PendingPosition
                    PendingPosition = nil
                end
            end

            local function StopDrag()
                ApplyPending()
                Dragging = false

                Disconnect(MoveConnection)
                Disconnect(EndConnection)
                Disconnect(RenderConnection)

                MoveConnection = nil
                EndConnection = nil
                RenderConnection = nil
            end

            Library:Connect(
                DragHandle.InputBegan,
                function(Input)
                    if Input.UserInputType
                            ~= Enum.UserInputType.MouseButton1
                        and Input.UserInputType
                            ~= Enum.UserInputType.Touch
                    then
                        return
                    end

                    StopDrag()
                    Dragging = true
                    StartMouse = Vector2New(
                        Input.Position.X,
                        Input.Position.Y
                    )
                    StartPosition = Gui.Position

                    local IsTouch =
                        Input.UserInputType
                        == Enum.UserInputType.Touch

                    MoveConnection =
                        UserInputService.InputChanged:
                        Connect(function(ChangedInput)
                            local Matching =
                                IsTouch
                                and ChangedInput == Input
                                or not IsTouch
                                and ChangedInput.UserInputType
                                    == Enum.UserInputType.MouseMovement

                            if not Dragging
                                or not Matching
                            then
                                return
                            end

                            local Delta = Vector2New(
                                ChangedInput.Position.X,
                                ChangedInput.Position.Y
                            ) - StartMouse

                            PendingPosition = UDim2New(
                                StartPosition.X.Scale,
                                StartPosition.X.Offset + Delta.X,
                                StartPosition.Y.Scale,
                                StartPosition.Y.Offset + Delta.Y
                            )
                        end)

                    RenderConnection =
                        RunService.RenderStepped:
                        Connect(function()
                            if Library.Unloaded
                                or not Gui.Parent
                            then
                                StopDrag()
                                return
                            end

                            ApplyPending()
                        end)

                    EndConnection =
                        UserInputService.InputEnded:
                        Connect(function(EndedInput)
                            local Matching =
                                IsTouch
                                and EndedInput == Input
                                or not IsTouch
                                and EndedInput.UserInputType
                                    == Enum.UserInputType.MouseButton1

                            if Matching then
                                StopDrag()
                            end
                        end)
                end
            )

            return self
        end

        Instances.MakeResizeable = function(
            self,
            Minimum,
            Maximum
        )
            if not self.Instance then
                return
            end

            local Gui = self.Instance
            local MinimumSize = Minimum or Vector2New(300, 300)
            local MaximumSize = Maximum or Vector2New(9999, 9999)

            local MoveConnection = nil
            local EndConnection = nil
            local RenderConnection = nil
            local PendingPosition = nil
            local PendingSize = nil
            local Active = false

            local function Disconnect(Connection)
                if Connection then
                    pcall(function()
                        Connection:Disconnect()
                    end)
                end
            end

            local function ApplyPending()
                if not Gui.Parent then
                    return
                end

                if PendingPosition then
                    Gui.Position = PendingPosition
                    PendingPosition = nil
                end

                if PendingSize then
                    Gui.Size = PendingSize
                    PendingSize = nil
                end
            end

            local function StopResize()
                ApplyPending()
                Active = false

                Disconnect(MoveConnection)
                Disconnect(EndConnection)
                Disconnect(RenderConnection)

                MoveConnection = nil
                EndConnection = nil
                RenderConnection = nil
            end

            local function CreateHandle(
                Name,
                Anchor,
                Position,
                Size,
                Horizontal,
                Vertical
            )
                local Handle = Instances:Create("TextButton", {
                    Parent = Gui,
                    Name = Name,
                    AnchorPoint = Anchor,
                    Position = Position,
                    Size = Size,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Text = "",
                    Active = true,
                    Visible = true,
                    ZIndex = 10000
                })

                Handle:Connect("InputBegan", function(Input)
                    if Input.UserInputType
                            ~= Enum.UserInputType.MouseButton1
                        and Input.UserInputType
                            ~= Enum.UserInputType.Touch
                    then
                        return
                    end

                    StopResize()
                    Active = true

                    local StartMouse = Vector2New(
                        Input.Position.X,
                        Input.Position.Y
                    )
                    local StartSize = Gui.AbsoluteSize
                    local StartPosition = Gui.Position
                    local IsTouch =
                        Input.UserInputType
                        == Enum.UserInputType.Touch

                    MoveConnection =
                        UserInputService.InputChanged:
                        Connect(function(ChangedInput)
                            local Matching =
                                IsTouch
                                and ChangedInput == Input
                                or not IsTouch
                                and ChangedInput.UserInputType
                                    == Enum.UserInputType.MouseMovement

                            if not Active
                                or not Matching
                            then
                                return
                            end

                            local Delta = Vector2New(
                                ChangedInput.Position.X,
                                ChangedInput.Position.Y
                            ) - StartMouse

                            local Width = StartSize.X
                            local Height = StartSize.Y

                            if Horizontal == "Left" then
                                Width = StartSize.X - Delta.X
                            elseif Horizontal == "Right" then
                                Width = StartSize.X + Delta.X
                            end

                            if Vertical == "Top" then
                                Height = StartSize.Y - Delta.Y
                            elseif Vertical == "Bottom" then
                                Height = StartSize.Y + Delta.Y
                            end

                            Width = math.clamp(
                                Width,
                                MinimumSize.X,
                                MaximumSize.X
                            )
                            Height = math.clamp(
                                Height,
                                MinimumSize.Y,
                                MaximumSize.Y
                            )

                            local X = StartPosition.X.Offset
                            local Y = StartPosition.Y.Offset

                            if Horizontal == "Left" then
                                X = StartPosition.X.Offset
                                    + StartSize.X
                                    - Width
                            end

                            if Vertical == "Top" then
                                Y = StartPosition.Y.Offset
                                    + StartSize.Y
                                    - Height
                            end

                            PendingPosition = UDim2New(
                                StartPosition.X.Scale,
                                X,
                                StartPosition.Y.Scale,
                                Y
                            )
                            PendingSize = UDim2New(0, Width, 0, Height)
                        end)

                    RenderConnection =
                        RunService.RenderStepped:
                        Connect(function()
                            if Library.Unloaded
                                or not Gui.Parent
                            then
                                StopResize()
                                return
                            end

                            ApplyPending()
                        end)

                    EndConnection =
                        UserInputService.InputEnded:
                        Connect(function(EndedInput)
                            local Matching =
                                IsTouch
                                and EndedInput == Input
                                or not IsTouch
                                and EndedInput.UserInputType
                                    == Enum.UserInputType.MouseButton1

                            if Matching then
                                StopResize()
                            end
                        end)
                end)

                return Handle
            end

            local Corner = UDim2New(0, 14, 0, 14)
            local HorizontalEdge = UDim2New(1, -28, 0, 7)
            local VerticalEdge = UDim2New(0, 7, 1, -28)

            return {
                CreateHandle(
                    "ResizeTopLeft",
                    Vector2New(0, 0),
                    UDim2New(0, 0, 0, 0),
                    Corner,
                    "Left",
                    "Top"
                ),
                CreateHandle(
                    "ResizeTop",
                    Vector2New(0.5, 0),
                    UDim2New(0.5, 0, 0, 0),
                    HorizontalEdge,
                    nil,
                    "Top"
                ),
                CreateHandle(
                    "ResizeTopRight",
                    Vector2New(1, 0),
                    UDim2New(1, 0, 0, 0),
                    Corner,
                    "Right",
                    "Top"
                ),
                CreateHandle(
                    "ResizeRight",
                    Vector2New(1, 0.5),
                    UDim2New(1, 0, 0.5, 0),
                    VerticalEdge,
                    "Right",
                    nil
                ),
                CreateHandle(
                    "ResizeBottomRight",
                    Vector2New(1, 1),
                    UDim2New(1, 0, 1, 0),
                    Corner,
                    "Right",
                    "Bottom"
                ),
                CreateHandle(
                    "ResizeBottom",
                    Vector2New(0.5, 1),
                    UDim2New(0.5, 0, 1, 0),
                    HorizontalEdge,
                    nil,
                    "Bottom"
                ),
                CreateHandle(
                    "ResizeBottomLeft",
                    Vector2New(0, 1),
                    UDim2New(0, 0, 1, 0),
                    Corner,
                    "Left",
                    "Bottom"
                ),
                CreateHandle(
                    "ResizeLeft",
                    Vector2New(0, 0.5),
                    UDim2New(0, 0, 0.5, 0),
                    VerticalEdge,
                    "Left",
                    nil
                )
            }
        end

        Instances.OnHover = function(self, Function)
            if not self.Instance then
                return
            end

            return Library:Connect(self.Instance.MouseEnter, Function)
        end

        Instances.OnHoverLeave = function(self, Function)
            if not self.Instance then
                return
            end

            return Library:Connect(self.Instance.MouseLeave, Function)
        end
    end


    Library.ResolveInstance = function(self, Item)
        if typeof(Item) == "Instance" then
            return Item
        end

        if type(Item) == "table" then
            return Item.Instance
        end

        return nil
    end

    Library.ApplyGlass = function(self, Item, Kind, Radius)
        local Object = self:ResolveInstance(Item)

        if not Object
            or not Object:IsA("GuiObject")
        then
            return nil
        end

        Object.BorderSizePixel = 0

        local Corner =
            Object:FindFirstChild("_RadiantLeanCorner")
            or Object:FindFirstChild("_RadiantRailCorner")
            or Object:FindFirstChild("_EnergyCorner")

        if not Corner then
            Corner = InstanceNew("UICorner")
            Corner.Name = "_RadiantLeanCorner"
            Corner.Parent = Object
        end

        local Limit =
            Kind == "Floating" and 6
            or Kind == "Window" and 5
            or Kind == "Popup" and 6
            or Kind == "Panel" and 4
            or 4

        Corner.CornerRadius = UDimNew(
            0,
            math.min(tonumber(Radius) or Limit, Limit)
        )

        local Stroke =
            Object:FindFirstChild("_RadiantLeanStroke")
            or Object:FindFirstChild("_RadiantRailStroke")
            or Object:FindFirstChild("_EnergyStroke")

        if not Stroke then
            Stroke = InstanceNew("UIStroke")
            Stroke.Name = "_RadiantLeanStroke"
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Stroke.LineJoinMode = Enum.LineJoinMode.Round
            Stroke.Thickness = 1
            Stroke.Parent = Object

            self:AddToTheme(Stroke, {
                Color = "Outline"
            })
        end

        Stroke.LineJoinMode = Enum.LineJoinMode.Round
        Stroke.Transparency =
            Kind == "Floating" and 0.42
            or Kind == "Window" and 0.50
            or Kind == "Panel" and 0.74
            or 0.78

        return Object
    end

    Library.AddGlassShadow = function(self, Item, Radius, Offset)
        local Object = self:ResolveInstance(Item)

        if Object then
            local Existing =
                Object:FindFirstChild("_GlassShadow")

            if Existing then
                Existing:Destroy()
            end
        end

        return nil
    end

    Library.EnsureGlassBlur = function(self)
        if not self.Glass or self.Glass.Enabled ~= true then
            return nil
        end

        if self.GlassBlur and self.GlassBlur.Parent then
            return self.GlassBlur
        end

        local Existing = Lighting:FindFirstChild("_RadiantGlassBlur")

        if Existing then
            Existing:Destroy()
        end

        local Blur = InstanceNew("BlurEffect")
        Blur.Name = "_RadiantGlassBlur"
        Blur.Size = 0
        Blur.Enabled = true
        Blur.Parent = Lighting

        self.GlassBlur = Blur
        return Blur
    end

    Library.SetGlassBlur = function(self, Enabled)
        if self.GlassBlurTween then
            pcall(function()
                self.GlassBlurTween:Cancel()
            end)
            self.GlassBlurTween = nil
        end

        if self.GlassBlur then
            self.GlassBlur.Size = 0
            self.GlassBlur.Enabled = false
        end
    end

    local SmoothFontSuccess,
        SmoothFont =
        pcall(function()
            return Font.new(
                "rbxasset://fonts/families/BuilderSans.json",
                Enum.FontWeight.Medium,
                Enum.FontStyle.Normal
            )
        end)

    Library.Font =
        SmoothFontSuccess
        and SmoothFont
        or Font.fromEnum(
            Enum.Font.GothamMedium
        )

    Library.FontName =
        SmoothFontSuccess
        and "Builder Sans Medium"
        or "Gotham Medium"

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = string.char(0),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
        DisplayOrder = 2147483646
    })

    Library.GetPointerPosition = function(self)
        local PointerPosition =
            UserInputService:
            GetMouseLocation()

        local Holder =
            self.Holder
            and self.Holder.Instance

        if Holder
            and not Holder.IgnoreGuiInset
        then
            local TopLeftInset =
                GuiService:
                GetGuiInset()

            PointerPosition =
                PointerPosition
                - TopLeftInset
        end

        return PointerPosition
    end

    Library.NotifHolder = Instances:Create("Frame", {
        Parent = Library.Holder.Instance,
        BorderColor3 = FromRGB(0, 0, 0),
        AnchorPoint = Vector2New(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2New(0.5, 0, 0, 0),
        Name = string.char(0),
        Size = UDim2New(0.34, 0, 1, -14),
        BorderSizePixel = 0,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Padding = UDimNew(0, 10)
    })

    Library.GetImage = function(self, Image)
        local ImageData = self.Images[Image]

        if not ImageData then
            return
        end

        return getcustomasset(self.Folders.Assets .. "/" .. ImageData[1])
    end

    Library.Round = function(self, Number, Float)
        local Multiplier = 1 / (Float or 1)
        return MathFloor(Number * Multiplier) / Multiplier
    end

    Library.GetTransparencyPropertyFromItem = function(self, Item)
        if Item:IsA("Frame") then
            return { "BackgroundTransparency" }
        elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
            return { "BackgroundTransparency", "ImageTransparency" }
        elseif Item:IsA("ScrollingFrame") then
            return { "BackgroundTransparency", "ScrollBarImageTransparency" }
        elseif Item:IsA("TextBox") then
            return { "TextTransparency", "BackgroundTransparency" }
        elseif Item:IsA("UIStroke") then
            return { "Transparency" }
        end
    end

    Library.FadeItem = function(
        self,
        Item,
        Property,
        Visibility,
        Speed
    )
        if self.Unloaded
            or not Item
            or not Item.Parent
        then
            return nil
        end

        local Goal =
            Visibility
            and 0
            or 1

        return Tween:Create(
            Item,
            TweenInfo.new(
                Speed
                    or self.Tween.Time,
                self.Tween.Style,
                self.Tween.Direction
            ),
            {
                [Property] = Goal
            },
            true
        )
    end

    local function DisconnectRecord(
        Record
    )
        if Record == nil then
            return false
        end

        local RecordType =
            typeof(
                Record
            )

        if RecordType
            == "RBXScriptConnection"
        then
            pcall(function()
                Record:
                    Disconnect()
            end)

            return true
        end

        if type(Record)
            ~= "table"
        then
            return false
        end

        local NestedConnection =
            rawget(
                Record,
                "Connection"
            )

        if NestedConnection
            ~= nil
        then
            return DisconnectRecord(
                NestedConnection
            )
        end

        local DisconnectMethod =
            rawget(
                Record,
                "Disconnect"
            )

        if type(DisconnectMethod)
            == "function"
        then
            pcall(
                DisconnectMethod,
                Record
            )

            return true
        end

        return false
    end

    local function EnsureInputRouter()
        if Library.InputRouterReady
            or Library.Unloaded
        then
            return
        end

        Library.InputRouterReady =
            true

        local RouterSignals = {
            Began =
                UserInputService.InputBegan,
            Changed =
                UserInputService.InputChanged,
            Ended =
                UserInputService.InputEnded
        }

        for Kind, Signal in pairs(
            RouterSignals
        ) do
            local Connection =
                Signal:Connect(function(...)
                    if Library.Unloaded then
                        return
                    end

                    local Listeners =
                        Library.InputListeners[
                            Kind
                        ]

                    for _, Listener in pairs(
                        Listeners
                    ) do
                        if Listener.Connected then
                            local Success,
                                Message =
                                pcall(
                                    Listener.Callback,
                                    ...
                                )

                            if not Success then
                                warn(Message)
                            end
                        end
                    end
                end)

            TableInsert(
                Library.CoreConnections,
                Connection
            )
        end
    end

    Library.Unload = function(self)
        if self.Unloaded
            or self.Unloading
        then
            return
        end

        self.Unloading = true
        self.Unloaded = true

        local CurrentColorpicker =
            self.CurrentColorpicker

        self.CurrentColorpicker =
            nil

        self.ActiveColorpicker =
            nil

        self.ActiveSlider =
            nil

        if CurrentColorpicker
            and type(
                CurrentColorpicker.SetOpen
            ) == "function"
        then
            pcall(function()
                CurrentColorpicker:
                    SetOpen(
                        false
                    )
            end)
        end

        for Index =
            #self.Connections,
            1,
            -1
        do
            DisconnectRecord(
                self.Connections[
                    Index
                ]
            )

            self.Connections[
                Index
            ] = nil
        end

        for Index =
            #self.CoreConnections,
            1,
            -1
        do
            DisconnectRecord(
                self.CoreConnections[
                    Index
                ]
            )

            self.CoreConnections[
                Index
            ] = nil
        end

        for Item,
            ItemTweens in pairs(
                self.ActiveTweens
            )
        do
            if type(ItemTweens)
                == "table"
            then
                for Property,
                    ActiveTween in pairs(
                        ItemTweens
                    )
                do
                    if typeof(ActiveTween)
                        == "Tween"
                    then
                        pcall(function()
                            ActiveTween:
                                Cancel()
                        end)
                    end

                    ItemTweens[
                        Property
                    ] = nil
                end
            end

            self.ActiveTweens[
                Item
            ] = nil
        end

        local RunningThread =
            coroutine.running()

        for Index =
            #self.Threads,
            1,
            -1
        do
            local Thread =
                self.Threads[
                    Index
                ]

            if Thread
                and Thread
                    ~= RunningThread
            then
                pcall(function()
                    task.cancel(
                        Thread
                    )
                end)
            end

            self.Threads[
                Index
            ] = nil
        end

        for _,
            Listeners in pairs(
                self.InputListeners
            )
        do
            if type(Listeners)
                == "table"
            then
                for Name,
                    Listener in pairs(
                        Listeners
                    )
                do
                    if type(Listener)
                        == "table"
                    then
                        Listener.Connected =
                            false
                    end

                    Listeners[
                        Name
                    ] = nil
                end
            end
        end

        if self.GlassBlurTween then
            pcall(function()
                self.GlassBlurTween:Cancel()
            end)
            self.GlassBlurTween = nil
        end

        if self.GlassBlur then
            pcall(function()
                self.GlassBlur:Destroy()
            end)
            self.GlassBlur = nil
        end

        local LegacyGlassBlur =
            Lighting:FindFirstChild("_RadiantGlassBlur")

        if LegacyGlassBlur then
            pcall(function()
                LegacyGlassBlur:Destroy()
            end)
        end

        local Holder =
            self.Holder

        self.Holder = nil
        self.NotifHolder = nil
        self.KeyList = nil
        if self.ActiveKeyPicker and type(self.ActiveKeyPicker.CancelPicking) == "function" then pcall(self.ActiveKeyPicker.CancelPicking, self.ActiveKeyPicker, false) end
        self.CurrentKeybind = nil
        self.ActiveKeyPicker = nil
        self.SuppressKeybindInput = nil
        self.SliderConnection = nil
        self.ColorpickerConnection = nil
        self.ColorpickerInputConnection = nil
        self.ColorpickerOverlay = nil
        self.InputRouterReady = false

        if type(self.Colorpickers)
            == "table"
        then
            table.clear(
                self.Colorpickers
            )
        end

        if Holder then
            local HolderInstance =
                Holder.Instance
                or Holder

            if typeof(HolderInstance)
                == "Instance"
            then
                pcall(function()
                    HolderInstance:
                        Destroy()
                end)
            end
        end

        if type(self.ThemeItems)
            == "table"
        then
            table.clear(
                self.ThemeItems
            )
        end

        if type(self.ThemeMap)
            == "table"
        then
            table.clear(
                self.ThemeMap
            )
        end

        if type(self.SetFlags)
            == "table"
        then
            table.clear(
                self.SetFlags
            )
        end

        if type(self.KeybindMetadata)
            == "table"
        then
            table.clear(
                self.KeybindMetadata
            )
        end

        if type(self.Flags)
            == "table"
        then
            table.clear(
                self.Flags
            )
        end

        if getgenv().Library
            == self
        then
            getgenv().Library =
                nil
        end

        self.Unloading = false
    end

    Library.Thread = function(
        self,
        Function,
        ...
    )
        if self.Unloaded then
            return nil
        end

        local Arguments = {
            ...
        }

        local NewThread =
            task.spawn(function()
                local Success,
                    Message =
                    pcall(
                        Function,
                        TableUnpack(
                            Arguments
                        )
                    )

                if not Success
                    and not self.Unloaded
                then
                    warn(Message)
                end
            end)

        TableInsert(
            self.Threads,
            NewThread
        )

        return NewThread
    end

    Library.SafeCall = function(
        self,
        Function,
        ...
    )
        if self.Unloaded
            or type(Function)
                ~= "function"
        then
            return false
        end

        local Results = {
            pcall(
                Function,
                ...
            )
        }

        local Success =
            TableRemove(
                Results,
                1
            )

        if not Success then
            warn(
                Results[1]
            )

            return false,
                Results[1]
        end

        return true,
            TableUnpack(
                Results
            )
    end

    Library.Connect = function(
        self,
        Event,
        Callback,
        Name
    )
        if self.Unloaded
            or not Event
            or type(Callback)
                ~= "function"
        then
            return nil
        end

        self.UnnamedConnections =
            self.UnnamedConnections
            + 1

        Name =
            Name
            or StringFormat(
                "Connection_%s_%s",
                self.UnnamedConnections,
                HttpService:
                    GenerateGUID(
                        false
                    )
            )

        local NewConnection = {
            Event = Event,
            Callback = Callback,
            Name = Name,
            Connection = nil
        }

        if Event
                == UserInputService.InputBegan
            or Event
                == UserInputService.InputChanged
            or Event
                == UserInputService.InputEnded
        then
            EnsureInputRouter()

            local Kind =
                Event
                    == UserInputService.InputBegan
                and "Began"
                or Event
                    == UserInputService.InputChanged
                and "Changed"
                or "Ended"

            local Listener = {
                Connected = true,
                Callback = Callback
            }

            function Listener:Disconnect()
                if not self.Connected then
                    return
                end

                self.Connected = false

                Library.InputListeners[
                    Kind
                ][Name] = nil
            end

            Library.InputListeners[
                Kind
            ][Name] = Listener

            NewConnection.Connection =
                Listener
        else
            local Connection =
                Event:Connect(function(...)
                    if self.Unloaded then
                        return
                    end

                    local Success,
                        Message =
                        pcall(
                            Callback,
                            ...
                        )

                    if not Success then
                        warn(Message)
                    end
                end)

            NewConnection.Connection =
                Connection
        end

        TableInsert(
            self.Connections,
            NewConnection
        )

        return NewConnection
    end

    Library.Disconnect = function(
        self,
        Name
    )
        for Index,
            Record in ipairs(
                self.Connections
            )
        do
            if Record.Name == Name then
                DisconnectRecord(
                    Record
                )

                TableRemove(
                    self.Connections,
                    Index
                )

                return true
            end
        end

        return false
    end

    Library.NextFlag = function(self)
        self.UnnamedFlags =
            self.UnnamedFlags
            + 1

        return StringFormat(
            "Flag Number %s %s",
            self.UnnamedFlags,
            HttpService:
                GenerateGUID(
                    false
                )
        )
    end

    Library.AddToTheme = function(self, Item, Properties)
        Item = self:ResolveInstance(Item)

        if not Item then
            return
        end

        local ThemeData = {
            Item = Item,
            Properties = Properties,
        }

        for Property, Value in ThemeData.Properties do
            if type(Value) == "string" then
                Item[Property] = self.Theme[Value]
            end
        end

        TableInsert(self.ThemeItems, ThemeData)
        self.ThemeMap[Item] = ThemeData
    end

    local function SerializeConfigValue(Value, Seen)
        local ValueType = typeof(Value)

        if ValueType == "Color3" then
            return {
                __Type = "Color3",
                Hex = "#" .. Value:ToHex()
            }
        elseif ValueType == "EnumItem" then
            return {
                __Type = "EnumItem",
                EnumType = tostring(Value.EnumType):gsub("^Enum%.", ""),
                Name = Value.Name
            }
        elseif ValueType == "Vector2" then
            return {
                __Type = "Vector2",
                X = Value.X,
                Y = Value.Y
            }
        elseif ValueType == "Vector3" then
            return {
                __Type = "Vector3",
                X = Value.X,
                Y = Value.Y,
                Z = Value.Z
            }
        elseif ValueType == "UDim" then
            return {
                __Type = "UDim",
                Scale = Value.Scale,
                Offset = Value.Offset
            }
        elseif ValueType == "UDim2" then
            return {
                __Type = "UDim2",
                XScale = Value.X.Scale,
                XOffset = Value.X.Offset,
                YScale = Value.Y.Scale,
                YOffset = Value.Y.Offset
            }
        elseif ValueType == "CFrame" then
            return {
                __Type = "CFrame",
                Components = {Value:GetComponents()}
            }
        end

        local LuaType = type(Value)

        if LuaType == "nil"
            or LuaType == "boolean"
            or LuaType == "number"
            or LuaType == "string"
        then
            return Value
        end

        if LuaType ~= "table" then
            return nil
        end

        Seen = Seen or {}

        if Seen[Value] then
            return nil
        end

        Seen[Value] = true

        local Result = {}

        for Key, NestedValue in pairs(Value) do
            local KeyType = type(Key)

            if KeyType == "string"
                or KeyType == "number"
            then
                local Serialized = SerializeConfigValue(NestedValue, Seen)

                if Serialized ~= nil then
                    Result[Key] = Serialized
                end
            end
        end

        Seen[Value] = nil

        return Result
    end

    local function DeserializeConfigValue(Value)
        if type(Value) ~= "table" then
            return Value
        end

        local TypeName = Value.__Type

        if TypeName == "Color3" then
            local Success, Result = pcall(FromHex, tostring(Value.Hex or "#FFFFFF"))
            return Success and Result or FromRGB(255, 255, 255)
        elseif TypeName == "EnumItem" then
            local Success, Result = pcall(function()
                local EnumType = Enum[tostring(Value.EnumType or "")]
                return EnumType and EnumType[tostring(Value.Name or "")]
            end)

            return Success and Result or nil
        elseif TypeName == "Vector2" then
            return Vector2New(tonumber(Value.X) or 0, tonumber(Value.Y) or 0)
        elseif TypeName == "Vector3" then
            return Vector3.new(tonumber(Value.X) or 0, tonumber(Value.Y) or 0, tonumber(Value.Z) or 0)
        elseif TypeName == "UDim" then
            return UDimNew(tonumber(Value.Scale) or 0, tonumber(Value.Offset) or 0)
        elseif TypeName == "UDim2" then
            return UDim2New(
                tonumber(Value.XScale) or 0,
                tonumber(Value.XOffset) or 0,
                tonumber(Value.YScale) or 0,
                tonumber(Value.YOffset) or 0
            )
        elseif TypeName == "CFrame" then
            local Components = Value.Components

            if type(Components) == "table" then
                local Success, Result = pcall(function()
                    return CFrame.new(TableUnpack(Components))
                end)

                if Success then
                    return Result
                end
            end

            return CFrame.new()
        end

        local Result = {}

        for Key, NestedValue in pairs(Value) do
            if Key ~= "__Type" then
                Result[Key] = DeserializeConfigValue(NestedValue)
            end
        end

        return Result
    end

    local function IsKeybindConfig(Value)
        return type(Value) == "table"
            and (
                Value.__Type == "Keybind"
                or Value.Class == "Keybind"
                or Value.Mode ~= nil
                    and (
                        Value.Key ~= nil
                        or Value.Value ~= nil
                        or Value.Toggled ~= nil
                    )
            )
    end

    local function IsColorpickerConfig(Value)
        return type(Value) == "table"
            and (
                Value.__Type == "Colorpicker"
                or Value.Class == "Colorpicker"
                or Value.Color ~= nil
                or Value.HexValue ~= nil
            )
    end

    local function SerializeKeybind(Value)
        local Key = Value.Key

        return {
            __Type = "Keybind",
            Key = Key and tostring(Key) or "None",
            Mode = tostring(Value.Mode or "Toggle"),
            Toggled = Value.Toggled == true
        }
    end

    local function SerializeColorpicker(Value)
        local HexValue = Value.HexValue

        if typeof(Value.Color) == "Color3" then
            HexValue = Value.Color:ToHex()
        end

        HexValue = tostring(HexValue or "FFFFFF"):gsub("^#", "")

        return {
            __Type = "Colorpicker",
            Color = "#" .. HexValue,
            Alpha = MathClamp(tonumber(Value.Alpha) or 0, 0, 1)
        }
    end

    Library.GetConfig = function(self)
        local Config = {
            __ConfigVersion = 2
        }

        for Index, Value in pairs(self.Flags) do
            if IsKeybindConfig(Value) then
                Config[Index] = SerializeKeybind(Value)
            elseif IsColorpickerConfig(Value) then
                Config[Index] = SerializeColorpicker(Value)
            else
                Config[Index] = SerializeConfigValue(Value, {})
            end
        end

        local Success, Encoded = pcall(function()
            return HttpService:JSONEncode(Config)
        end)

        if not Success then
            return nil, Encoded
        end

        return Encoded
    end

    Library.LoadConfig = function(self, Config)
        if type(Config) ~= "string"
            or Config == ""
        then
            return false, "Config is empty"
        end

        local DecodeSuccess, Decoded = pcall(function()
            return HttpService:JSONDecode(Config)
        end)

        if not DecodeSuccess
            or type(Decoded) ~= "table"
        then
            return false, Decoded
        end

        local DeferredKeybinds = {}
        local ConfigVersion = tonumber(Decoded.__ConfigVersion) or 1

        local function ApplyFlag(Index, Value)
            local SetFunction = self.SetFlags[Index]

            if type(SetFunction) ~= "function" then
                return
            end

            if IsColorpickerConfig(Value) then
                local ColorValue = Value.Color or Value.Hex or "#FFFFFF"
                SetFunction(ColorValue, tonumber(Value.Alpha) or 0)
            else
                SetFunction(DeserializeConfigValue(Value))
            end
        end

        local Success, Message = self:SafeCall(function()
            for Index, Value in pairs(Decoded) do
                if Index == "__ConfigVersion" then
                    continue
                end

                if IsKeybindConfig(Value) then
                    DeferredKeybinds[#DeferredKeybinds + 1] = {
                        Index = Index,
                        Value = Value
                    }
                else
                    ApplyFlag(Index, Value)
                end
            end

            for _, Entry in ipairs(DeferredKeybinds) do
                local Value = Entry.Value
                local SetFunction = self.SetFlags[Entry.Index]

                if type(SetFunction) == "function" then
                    local KeyValue = Value.Key or Value.Value or "None"
                    local Metadata = self.KeybindMetadata and self.KeybindMetadata[Entry.Index]

                    if ConfigVersion < 2
                        and Metadata
                        and Metadata.HasExplicitDefault ~= true
                    then
                        local NormalizedKey = tostring(KeyValue):gsub("%s+", ""):lower()

                        if NormalizedKey == "mb2"
                            or NormalizedKey == "mousebutton2"
                            or NormalizedKey == "enum.userinputtype.mousebutton2"
                        then
                            KeyValue = "None"
                        end
                    end

                    SetFunction({
                        Key = KeyValue,
                        Mode = Value.Mode or "Toggle",
                        Toggled = Value.Toggled == true
                    })
                end
            end
        end)

        if not Success then
            return false, Message
        end

        self:Notification("Successfully loaded config", 5, FromRGB(0, 255, 0))

        return true
    end

    local function NormalizeConfigName(
        Config
    )
        Config =
            tostring(
                Config
                or "default"
            )

        Config =
            StringGSub(
                Config,
                "[/\\:*?\"<>|]",
                "_"
            )

        if not Config:match(
            "%.json$"
        ) then
            Config =
                Config
                .. ".json"
        end

        return Config
    end

    Library.DeleteConfig = function(
        self,
        Config
    )
        local ConfigName =
            NormalizeConfigName(
                Config
            )

        local Path =
            self.Folders.Configs
            .. "/"
            .. ConfigName

        if isfile(Path) then
            delfile(Path)
        end
    end

    Library.SaveConfig = function(
        self,
        Config
    )
        local ConfigName =
            NormalizeConfigName(
                Config
            )

        local Path =
            self.Folders.Configs
            .. "/"
            .. ConfigName

        local ConfigData, ErrorMessage = self:GetConfig()

        if not ConfigData then
            return nil, ErrorMessage
        end

        local Success, Message = pcall(function()
            writefile(
                Path,
                ConfigData
            )
        end)

        if not Success then
            return nil, Message
        end

        return Path
    end

    Library.RefreshConfigsList = function(
        self,
        Element
    )
        local List = {}

        if isfolder(
            self.Folders.Configs
        ) then
            for _,
                Value in ipairs(
                    listfiles(
                        self.Folders.Configs
                    )
                )
            do
                local FileName =
                    Value:match(
                        "[^/\\]+$"
                    )

                if FileName
                    and FileName:match(
                        "%.json$"
                    )
                then
                    TableInsert(
                        List,
                        FileName
                    )
                end
            end
        end

        table.sort(
            List
        )

        local Signature =
            TableConcat(
                List,
                string.char(0)
            )

        if self.ConfigListSignature
            ~= Signature
        then
            self.ConfigListSignature =
                Signature

            Element:Refresh(
                List
            )
        end

        return List
    end

    Library.ChangeItemTheme = function(self, Item, Properties)
        Item = self:ResolveInstance(Item)

        if not Item or not self.ThemeMap[Item] then
            return
        end

        self.ThemeMap[Item].Properties = Properties
        self.ThemeMap[Item] = self.ThemeMap[Item]
    end

    Library.ChangeTheme = function(self, Theme, Color)
        self.Theme[Theme] = Color

        for _, Item in self.ThemeItems do
            for Property, Value in Item.Properties do
                if type(Value) == "string" and Value == Theme then
                    Item.Item[Property] = Color
                end
            end
        end
    end

    Library.IsMouseOverFrame = function(
        self,
        Frame
    )
        Frame =
            self:ResolveInstance(
                Frame
            )

        if not Frame
            or not Frame.Parent
        then
            return false
        end

        local MousePosition =
            Library:
            GetPointerPosition()

        local Position =
            Frame.AbsolutePosition

        local Size =
            Frame.AbsoluteSize

        return MousePosition.X
                >= Position.X
            and MousePosition.X
                <= Position.X
                    + Size.X
            and MousePosition.Y
                >= Position.Y
            and MousePosition.Y
                <= Position.Y
                    + Size.Y
    end

    Library.Watermark = function(self, Name)
        local Watermark = {
            Title = tostring(Name or "radiant.rip"),
            Visible = true,
            Connections = {},
            FrameCount = 0,
            HeartbeatCount = 0,
            SampleElapsed = 0,
            UpdateElapsed = 0,
            FPS = 0,
            TPS = 0,
            RenderDelta = 1 / 60,
            HeartbeatDelta = 1 / 60,
            Scale = 1,
            Destroyed = false
        }

        local Items = {}
        local ConnectionPrefix =
            "Watermark_"
            .. HttpService:GenerateGUID(false)

        Items.Frame = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = string.char(0),
            Position = UDim2New(0, 12, 0, 12),
            Size = UDim2New(0, 250, 0, 38),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Active = true,
            ClipsDescendants = false,
            ZIndex = 500
        })
        Items.Scale = Instances:Create("UIScale", {
            Parent = Items.Frame.Instance,
            Scale = 1
        })

        Items.Frame:MakeDraggable()

        local Rows = {}
        local RowLayouts = {}
        local Labels = {}

        local function ThemeAccent(Object)
            if Object:IsA("UIStroke") then
                Object.Color = Library.Theme.Accent
                Library:AddToTheme(Object, {Color = "Accent"})
            else
                Object.BackgroundColor3 = Library.Theme.Accent
                Library:AddToTheme(Object, {BackgroundColor3 = "Accent"})
            end
        end

        local function RoundedPart(Parent, Position, Size, Radius)
            local Part = InstanceNew("Frame")
            Part.Position = Position
            Part.Size = Size
            Part.BorderSizePixel = 0
            Part.ZIndex = 504
            Part.Parent = Parent
            ThemeAccent(Part)

            local Corner = InstanceNew("UICorner")
            Corner.CornerRadius = UDimNew(0, Radius or 2)
            Corner.Parent = Part

            return Part
        end

        local function OutlinePart(Parent, Position, Size, Radius)
            local Part = InstanceNew("Frame")
            Part.Position = Position
            Part.Size = Size
            Part.BorderSizePixel = 0
            Part.BackgroundTransparency = 1
            Part.ZIndex = 504
            Part.Parent = Parent

            local Corner = InstanceNew("UICorner")
            Corner.CornerRadius = UDimNew(0, Radius or 2)
            Corner.Parent = Part

            local Stroke = InstanceNew("UIStroke")
            Stroke.Thickness = 1
            Stroke.Transparency = 0.12
            Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            Stroke.LineJoinMode = Enum.LineJoinMode.Round
            Stroke.Parent = Part
            ThemeAccent(Stroke)

            return Part
        end

        local function CreateIcon(Parent, Kind)
            local Holder = InstanceNew("Frame")
            Holder.Name = "Icon"
            Holder.Size = UDim2New(0, 12, 0, 12)
            Holder.BackgroundTransparency = 1
            Holder.BorderSizePixel = 0
            Holder.ZIndex = 503
            Holder.Parent = Parent

            if Kind == "User" then
                RoundedPart(Holder, UDim2New(0, 4, 0, 0), UDim2New(0, 4, 0, 4), 4)
                RoundedPart(Holder, UDim2New(0, 2, 0, 6), UDim2New(0, 8, 0, 5), 3)
            elseif Kind == "Monitor" then
                OutlinePart(Holder, UDim2New(0, 0, 0, 1), UDim2New(0, 12, 0, 8), 2)
                RoundedPart(Holder, UDim2New(0, 5, 0, 9), UDim2New(0, 2, 0, 2), 1)
                RoundedPart(Holder, UDim2New(0, 3, 0, 11), UDim2New(0, 6, 0, 1), 1)
            elseif Kind == "Cloud" then
                RoundedPart(Holder, UDim2New(0, 1, 0, 6), UDim2New(0, 10, 0, 5), 3)
                RoundedPart(Holder, UDim2New(0, 2, 0, 3), UDim2New(0, 5, 0, 6), 4)
                RoundedPart(Holder, UDim2New(0, 6, 0, 4), UDim2New(0, 5, 0, 5), 4)
            elseif Kind == "Position" then
                local Shaft = RoundedPart(Holder, UDim2New(0, 5, 0, 1), UDim2New(0, 2, 0, 9), 1)
                Shaft.Rotation = 38
                local HeadA = RoundedPart(Holder, UDim2New(0, 6, 0, 1), UDim2New(0, 2, 0, 5), 1)
                HeadA.Rotation = -8
                local HeadB = RoundedPart(Holder, UDim2New(0, 8, 0, 3), UDim2New(0, 2, 0, 5), 1)
                HeadB.Rotation = 82
            elseif Kind == "Clock" then
                OutlinePart(Holder, UDim2New(0, 1, 0, 1), UDim2New(0, 10, 0, 10), 5)
                RoundedPart(Holder, UDim2New(0, 5, 0, 3), UDim2New(0, 2, 0, 4), 1)
                local Hand = RoundedPart(Holder, UDim2New(0, 6, 0, 6), UDim2New(0, 4, 0, 1), 1)
                Hand.Rotation = 20
            elseif Kind == "Network" then
                RoundedPart(Holder, UDim2New(0, 1, 0, 8), UDim2New(0, 2, 0, 3), 1)
                RoundedPart(Holder, UDim2New(0, 5, 0, 5), UDim2New(0, 2, 0, 6), 1)
                RoundedPart(Holder, UDim2New(0, 9, 0, 2), UDim2New(0, 2, 0, 9), 1)
            end

            return Holder
        end

        local function CreateRow(Index)
            local Row = InstanceNew("Frame")
            Row.Name = "Row" .. tostring(Index)
            Row.Position = UDim2New(0, 0, 0, (Index - 1) * 20)
            Row.Size = UDim2New(0, 0, 0, 18)
            Row.AutomaticSize = Enum.AutomaticSize.X
            Row.BackgroundTransparency = 1
            Row.BorderSizePixel = 0
            Row.ZIndex = 501
            Row.Parent = Items.Frame.Instance

            local Layout = InstanceNew("UIListLayout")
            Layout.FillDirection = Enum.FillDirection.Horizontal
            Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            Layout.VerticalAlignment = Enum.VerticalAlignment.Center
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Padding = UDimNew(0, 4)
            Layout.Parent = Row

            Rows[Index] = Row
            RowLayouts[Index] = Layout
            return Row
        end

        local function CreateSegment(Row, Key, IconType, InitialText, IsTitle)
            local Segment = InstanceNew("Frame")
            Segment.Name = Key
            Segment.Size = UDim2New(0, 0, 0, 18)
            Segment.AutomaticSize = Enum.AutomaticSize.X
            Segment.BorderSizePixel = 0
            Segment.BackgroundColor3 = Library.Theme.Background
            Segment.BackgroundTransparency = IsTitle and 0.04 or 0.10
            Segment.ZIndex = 502
            Segment.Parent = Row
            Library:AddToTheme(Segment, {BackgroundColor3 = "Background"})

            local Corner = InstanceNew("UICorner")
            Corner.CornerRadius = UDimNew(0, 4)
            Corner.Parent = Segment

            local Padding = InstanceNew("UIPadding")
            Padding.PaddingLeft = UDimNew(0, 6)
            Padding.PaddingRight = UDimNew(0, 6)
            Padding.Parent = Segment

            local Layout = InstanceNew("UIListLayout")
            Layout.FillDirection = Enum.FillDirection.Horizontal
            Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
            Layout.VerticalAlignment = Enum.VerticalAlignment.Center
            Layout.SortOrder = Enum.SortOrder.LayoutOrder
            Layout.Padding = UDimNew(0, IconType and 4 or 0)
            Layout.Parent = Segment

            if IconType then
                CreateIcon(Segment, IconType)
            end

            local Value = InstanceNew("TextLabel")
            Value.Name = "Value"
            Value.Size = UDim2New(0, 0, 0, 16)
            Value.AutomaticSize = Enum.AutomaticSize.X
            Value.BackgroundTransparency = 1
            Value.BorderSizePixel = 0
            Value.FontFace = Library.Font
            Value.Text = tostring(InitialText or "")
            Value.TextSize = IsTitle and 10 or 9
            Value.TextColor3 = IsTitle and Library.Theme.Text or Library.Theme["Muted Text"]
            Value.TextXAlignment = Enum.TextXAlignment.Left
            Value.ZIndex = 503
            Value.Parent = Segment
            Library:AddToTheme(Value, {TextColor3 = IsTitle and "Text" or "Muted Text"})

            Labels[Key] = Value
            return Segment
        end

        local Row1 = CreateRow(1)
        local Row2 = CreateRow(2)

        CreateSegment(Row1, "Title", nil, Watermark.Title, true)
        CreateSegment(Row1, "User", "User", LocalPlayer.Name, false)
        CreateSegment(Row1, "FPS", "Monitor", "0fps", false)
        CreateSegment(Row1, "Ping", "Cloud", "0ms", false)
        CreateSegment(Row2, "Position", "Position", "x0 y0 z0", false)
        CreateSegment(
            Row2,
            "Date",
            "Clock",
            os.date("%d.%m.%Y %H:%M"),
            false
        )

        local function AddConnection(
            Event,
            Callback
        )
            if not Event
                or type(Callback) ~= "function"
            then
                return nil
            end

            local Connection =
                Event:Connect(function(...)
                    if Watermark.Destroyed then
                        return
                    end

                    local Success, Message =
                        pcall(Callback, ...)

                    if not Success then
                        warn(Message)
                    end
                end)

            Watermark.Connections[
                #Watermark.Connections + 1
            ] = Connection

            return Connection
        end

        local function UpdateWidth()
            if Watermark.Destroyed
                or not Items.Frame.Instance.Parent
            then
                return
            end

            Items.Frame.Instance.Size =
                UDim2New(
                    0,
                    math.max(
                        RowLayouts[1].AbsoluteContentSize.X,
                        RowLayouts[2].AbsoluteContentSize.X
                    ),
                    0,
                    38
                )
        end

        local function ReadServerStat(Names)
            local Result = nil

            pcall(function()
                local StatsService =
                    game:GetService("Stats")

                local Network =
                    StatsService:
                        FindFirstChild("Network")

                local ServerStats =
                    Network
                    and Network:
                        FindFirstChild(
                            "ServerStatsItem"
                        )

                if not ServerStats then
                    return
                end

                local Wanted = {}

                for _, StatName in ipairs(Names) do
                    Wanted[
                        string.lower(
                            tostring(StatName)
                        )
                    ] = true
                end

                local function ParseItem(Item)
                    local Value

                    pcall(function()
                        Value =
                            tonumber(
                                Item:GetValue()
                            )
                    end)

                    if not Value then
                        pcall(function()
                            local ValueString =
                                tostring(
                                    Item:GetValueString()
                                )

                            Value = tonumber(
                                ValueString:match(
                                    "[-+]?%d+%.?%d*"
                                )
                            )
                        end)
                    end

                    return Value
                end

                for _, Item in ipairs(
                    ServerStats:GetChildren()
                ) do
                    local ItemName =
                        string.lower(Item.Name)

                    local Match =
                        Wanted[ItemName] == true

                    if not Match then
                        for Name in pairs(Wanted) do
                            if string.find(
                                ItemName,
                                Name,
                                1,
                                true
                            ) then
                                Match = true
                                break
                            end
                        end
                    end

                    if Match then
                        local Value = ParseItem(Item)

                        if Value then
                            Result =
                                math.max(Value, 0)
                            break
                        end
                    end
                end
            end)

            return Result
        end

        local function GetPing()
            local Ping = 0

            pcall(function()
                Ping =
                    (
                        tonumber(
                            LocalPlayer:
                                GetNetworkPing()
                        )
                        or 0
                    ) * 1000
            end)

            if Ping <= 0 then
                Ping = ReadServerStat({
                    "Data Ping"
                }) or 0
            end

            return math.clamp(
                math.floor(Ping + 0.5),
                0,
                9999
            )
        end

        local function GetPosition()
            local Character =
                LocalPlayer.Character

            local Root =
                Character
                and Character:
                    FindFirstChild(
                        "HumanoidRootPart"
                    )

            if not Root then
                return "x0 y0 z0"
            end

            local Position =
                Root.Position

            return StringFormat(
                "x%d y%d z%d",
                MathFloor(Position.X + 0.5),
                MathFloor(Position.Y + 0.5),
                MathFloor(Position.Z + 0.5)
            )
        end

        local function UpdateMetrics()
            if Watermark.Destroyed
                or not Items.Frame.Instance.Parent
            then
                return
            end

            Labels.Title.Text =
                Watermark.Title

            Labels.User.Text =
                tostring(LocalPlayer.Name)

            Labels.FPS.Text =
                StringFormat(
                    "%dfps",
                    math.max(
                        MathFloor(
                            Watermark.FPS + 0.5
                        ),
                        0
                    )
                )

            Labels.Ping.Text =
                StringFormat(
                    "%dms",
                    GetPing()
                )

            Labels.Position.Text =
                GetPosition()

            Labels.Date.Text =
                os.date(
                    "%d.%m.%Y %H:%M"
                )

            UpdateWidth()
        end

        AddConnection(
            RowLayouts[1]:
                GetPropertyChangedSignal(
                    "AbsoluteContentSize"
                ),
            UpdateWidth,
            "Row1Size"
        )

        AddConnection(
            RowLayouts[2]:
                GetPropertyChangedSignal(
                    "AbsoluteContentSize"
                ),
            UpdateWidth,
            "Row2Size"
        )

        AddConnection(
            RunService.RenderStepped,
            function(DeltaTime)
                DeltaTime =
                    tonumber(DeltaTime) or 0

                if DeltaTime > 0 then
                    Watermark.RenderDelta =
                        Watermark.RenderDelta * 0.82
                        + DeltaTime * 0.18

                    Watermark.FPS =
                        1 / math.max(
                            Watermark.RenderDelta,
                            1 / 1000
                        )
                end
            end
        )

        AddConnection(
            RunService.Heartbeat,
            function(DeltaTime)
                DeltaTime =
                    tonumber(DeltaTime) or 0

                if DeltaTime > 0 then
                    Watermark.HeartbeatDelta =
                        Watermark.HeartbeatDelta * 0.82
                        + DeltaTime * 0.18

                    Watermark.TPS =
                        1 / math.max(
                            Watermark.HeartbeatDelta,
                            1 / 1000
                        )
                end

                Watermark.UpdateElapsed =
                    Watermark.UpdateElapsed
                    + DeltaTime

                if Watermark.UpdateElapsed
                    >= 0.25
                then
                    Watermark.UpdateElapsed =
                        Watermark.UpdateElapsed % 0.25

                    UpdateMetrics()
                end
            end
        )

        function Watermark:SetVisibility(Bool)
            Watermark.Visible =
                Bool == true

            if Items.Frame
                and Items.Frame.Instance
            then
                Items.Frame.Instance.Visible =
                    Watermark.Visible
            end
        end

        function Watermark:SetScale(Value)
            Value = math.clamp(
                tonumber(Value) or 1,
                0.55,
                1.75
            )

            Watermark.Scale = Value
            Items.Scale.Instance.Scale = Value
        end

        function Watermark:GetScale()
            return Watermark.Scale
        end

        function Watermark:SetText(Value)
            Watermark.Title =
                tostring(
                    Value or "radiant.rip"
                )

            if Labels.Title
                and Labels.Title.Parent
            then
                Labels.Title.Text =
                    Watermark.Title
                UpdateWidth()
            end
        end

        function Watermark:GetText()
            return Watermark.Title
        end

        function Watermark:Destroy()
            if Watermark.Destroyed then
                return
            end

            Watermark.Destroyed = true

            for Index =
                #Watermark.Connections,
                1,
                -1
            do
                local Connection =
                    Watermark.Connections[Index]

                if typeof(Connection)
                    == "RBXScriptConnection"
                then
                    Connection:Disconnect()
                end

                Watermark.Connections[Index] = nil
            end

            if Library.ActiveWatermark
                == Watermark
            then
                Library.ActiveWatermark = nil
            end

            if Items.Frame
                and Items.Frame.Instance
            then
                Items.Frame.Instance:Destroy()
            end
        end

        Library.ActiveWatermark =
            Watermark

        Watermark.Frame =
            Items.Frame.Instance

        Watermark.Label =
            Labels.Title

        Watermark.Labels =
            Labels

        task.defer(function()
            UpdateMetrics()
            UpdateWidth()
        end)

        return Watermark
    end

    Library.Notification = function(self, Text, Duration, Color, Icon)
        if Library.NotificationsHidden then
            return
        end

        local Items = { } do
            Items["Notification"] = Instances:Create("Frame", {
                Parent = Library.NotifHolder.Instance,
                Name = string.char(0),
                Size = UDim2New(0, 0, 0, 22),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Notification"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
            Library:ApplyGlass(Items["Notification"], "Floating", 9)
            Library:AddGlassShadow(Items["Notification"], 12, 4)

            Instances:Create("UIStroke", {
                Parent = Items["Notification"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIPadding", {
                Parent = Items["Notification"].Instance,
                PaddingTop = UDimNew(0, 1),
                PaddingRight = UDimNew(0, 8),
                PaddingLeft = UDimNew(0, 5)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Notification"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Text,
                Name = string.char(0),
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 13, 0, 2),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0)
            }):AddToTheme({Color = "Text Border"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Notification"].Instance,
                Name = string.char(0),
                Position = UDim2New(0, -5, 0, -1),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 13, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = Color
            })

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Icon"] = Instances:Create("ImageLabel", {
                Parent = Items["Notification"].Instance,
                ImageColor3 = FromRGB(255, 255, 255),
                ScaleType = Enum.ScaleType.Fit,
                BorderColor3 = FromRGB(0, 0, 0),
                Name = string.char(0),
                Image = "rbxassetid://94324346713012",
                BackgroundTransparency = 1,
                Position = UDim2New(0, -2, 0, 3),
                Size = UDim2New(0, 13, 0, 13),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            if not Icon then
                Items["Icon"]:Clean()
                Items["Title"].Instance.Position = UDim2New(0, 1, 0, 2)
            else
                Items["Icon"].Instance.Image = Icon[1]
                Items["Icon"].Instance.ImageColor3 = Icon[2] or FromRGB(255, 255, 255)
            end
        end

        Items["Notification"].Instance.BackgroundTransparency = 1
        Items["Notification"].Instance.Size = UDim2New(0, 0, 0, 0)
        for Index, Value in Items["Notification"].Instance:GetDescendants() do
            if Value:IsA("UIStroke") then
                Value.Transparency = 1
            elseif Value:IsA("TextLabel") then
                Value.TextTransparency = 1
            elseif Value:IsA("ImageLabel") then
                Value.ImageTransparency = 1
            elseif Value:IsA("Frame") then
                Value.BackgroundTransparency = 1
            end
        end

        Library:Thread(function()
            Items["Notification"]:Tween(nil, {BackgroundTransparency = 0, Size = UDim2New(0, 0, 0, 22)})

            task.wait(0.06)

            for Index, Value in Items["Notification"].Instance:GetDescendants() do
                if Value:IsA("UIStroke") then
                    Tween:Create(Value, nil, {Transparency = 0}, true)
                elseif Value:IsA("TextLabel") then
                    Tween:Create(Value, nil, {TextTransparency = 0}, true)
                elseif Value:IsA("ImageLabel") then
                    Tween:Create(Value, nil, {ImageTransparency = 0}, true)
                elseif Value:IsA("Frame") then
                    Tween:Create(Value, nil, {BackgroundTransparency = 0}, true)
                end
            end

            task.delay(Duration + 0.1, function()
                for Index, Value in Items["Notification"].Instance:GetDescendants() do
                    if Value:IsA("UIStroke") then
                        Tween:Create(Value, nil, {Transparency = 1}, true)
                    elseif Value:IsA("TextLabel") then
                        Tween:Create(Value, nil, {TextTransparency = 1}, true)
                    elseif Value:IsA("ImageLabel") then
                        Tween:Create(Value, nil, {ImageTransparency = 1}, true)
                    elseif Value:IsA("Frame") then
                        Tween:Create(Value, nil, {BackgroundTransparency = 1}, true)
                    end
                end

                task.wait(0.06)

                Items["Notification"]:Tween(nil, {BackgroundTransparency = 1, Size = UDim2New(0, 0, 0, 0)})

                task.wait(0.5)
                Items["Notification"]:Clean()
            end)
        end)
    end

    Library.KeybindList = function(self)
        local KeybindList = {
            Visible = false,
            Pinned = false,
            Rows = { },
            Scale = 1
        }

        self.KeyList = KeybindList

        local Items = { }
        local RowTween =
            TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

        Items.Frame =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Library.Holder.Instance,

                    AnchorPoint =
                        Vector2New(0, 0.5),

                    Position =
                        UDim2New(
                            0,
                            18,
                            0.5,
                            0
                        ),

                    Size =
                        UDim2New(
                            0,
                            286,
                            0,
                            252
                        ),

                    BorderSizePixel = 0,
                    BackgroundColor3 =
                        Library.Theme.Background,

                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 400
                }
            )

        Items.Frame:AddToTheme({
            BackgroundColor3 = "Background"
        })

        Library:ApplyGlass(
            Items.Frame,
            "Floating",
            6
        )

        Items.Scale =
            Instances:Create(
                "UIScale",
                {
                    Parent =
                        Items.Frame.Instance,
                    Scale = 1
                }
            )

        Items.Header =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Items.Frame.Instance,

                    Size =
                        UDim2New(1, 0, 0, 31),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Inline,

                    ZIndex = 401
                }
            )

        Items.Header:AddToTheme({
            BackgroundColor3 = "Inline"
        })

        Items.HeaderIcon =
            Library:CreateVectorIcon(
                Items.Header,
                "list",
                {
                    Size = 15,
                    Position =
                        UDim2New(
                            0,
                            10,
                            0.5,
                            0
                        ),
                    AnchorPoint =
                        Vector2New(0, 0.5),
                    Theme = "Accent",
                    ZIndex = 404
                }
            )

        Items.Title =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items.Header.Instance,

                    Position =
                        UDim2New(
                            0,
                            30,
                            0,
                            0
                        ),

                    Size =
                        UDim2New(
                            1,
                            -56,
                            1,
                            0
                        ),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    FontFace = Library.Font,
                    Text = "Keybind list",
                    TextSize = 11,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    TextColor3 =
                        Library.Theme.Text,

                    ZIndex = 403
                }
            )

        Items.Title:AddToTheme({
            TextColor3 = "Text"
        })

        Items.Pin =
            Instances:Create(
                "TextButton",
                {
                    Parent =
                        Items.Header.Instance,

                    AnchorPoint =
                        Vector2New(1, 0.5),

                    Position =
                        UDim2New(
                            1,
                            -8,
                            0.5,
                            0
                        ),

                    Size =
                        UDim2New(
                            0,
                            18,
                            0,
                            18
                        ),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Text = "",
                    ZIndex = 404
                }
            )

        Items.PinIcon =
            Library:CreateVectorIcon(
                Items.Pin,
                "pin",
                {
                    Size = 12,
                    Position =
                        UDim2New(
                            0.5,
                            0,
                            0.5,
                            0
                        ),
                    AnchorPoint =
                        Vector2New(0.5, 0.5),
                    Theme = "Muted Text",
                    ZIndex = 405
                }
            )

        Items.Columns =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Items.Frame.Instance,

                    Position =
                        UDim2New(
                            0,
                            10,
                            0,
                            38
                        ),

                    Size =
                        UDim2New(
                            1,
                            -20,
                            0,
                            22
                        ),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme[
                            "Page Background"
                        ],

                    ZIndex = 401
                }
            )

        Items.Columns:AddToTheme({
            BackgroundColor3 =
                "Page Background"
        })

        Library:ApplyGlass(
            Items.Columns,
            "Element",
            4
        )

        local function HeaderLabel(
            Text,
            Position,
            Size
        )
            local Label =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            Items.Columns.Instance,

                        Position = Position,
                        Size = Size,
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        FontFace = Library.Font,
                        Text = Text,
                        TextSize = 9,
                        TextXAlignment =
                            Enum.TextXAlignment.Left,
                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],
                        ZIndex = 402
                    }
                )

            Label:AddToTheme({
                TextColor3 = "Muted Text"
            })

            return Label
        end

        HeaderLabel(
            "Function",
            UDim2New(0, 10, 0, 0),
            UDim2New(0, 128, 1, 0)
        )

        HeaderLabel(
            "Hotkey",
            UDim2New(0, 144, 0, 0),
            UDim2New(0, 48, 1, 0)
        )

        HeaderLabel(
            "Status",
            UDim2New(0, 198, 0, 0),
            UDim2New(0, 44, 1, 0)
        )

        Items.Content =
            Instances:Create(
                "ScrollingFrame",
                {
                    Parent =
                        Items.Frame.Instance,

                    Position =
                        UDim2New(
                            0,
                            10,
                            0,
                            64
                        ),

                    Size =
                        UDim2New(
                            1,
                            -20,
                            1,
                            -74
                        ),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    ScrollBarImageColor3 =
                        Library.Theme.Accent,
                    ScrollBarThickness = 2,
                    VerticalScrollBarInset =
                        Enum.ScrollBarInset.ScrollBar,
                    ScrollingDirection =
                        Enum.ScrollingDirection.Y,
                    ElasticBehavior =
                        Enum.ElasticBehavior.Never,
                    AutomaticCanvasSize =
                        Enum.AutomaticSize.Y,
                    CanvasSize =
                        UDim2New(0, 0, 0, 0),
                    ClipsDescendants = true,
                    ZIndex = 401
                }
            )

        Items.Content:AddToTheme({
            ScrollBarImageColor3 = "Accent"
        })

        local Layout =
            InstanceNew("UIListLayout")

        Layout.Padding = UDimNew(0, 2)
        Layout.SortOrder =
            Enum.SortOrder.LayoutOrder
        Layout.Parent =
            Items.Content.Instance

        Items.Frame:MakeDraggable(
            Items.Header,
            0
        )

        local function FormatKey(Value)
            Value = tostring(Value or "")

            if Value == ""
                or Value == "None"
                or Value == "Unknown"
            then
                return "—"
            end

            return Value
        end

        local function FormatMode(Value)
            Value = tostring(Value or "Toggle")

            if Value == "" then
                return "Toggle"
            end

            return Value
        end

        function KeybindList:Add(
            Mode,
            Name,
            Key
        )
            local NewKey = {
                Mode = tostring(Mode or "Toggle"),
                RawName = tostring(Name or ""),
                RawKey = tostring(Key or ""),
                Active = false
            }

            NewKey.Frame =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items.Content.Instance,

                        Size =
                            UDim2New(
                                1,
                                0,
                                0,
                                27
                            ),

                        BorderSizePixel = 0,
                        BackgroundColor3 =
                            Library.Theme.Element,
                        BackgroundTransparency = 0.58,
                        AutoButtonColor = false,
                        Text = "",
                        ZIndex = 402
                    }
                )

            NewKey.Frame:AddToTheme({
                BackgroundColor3 = "Element"
            })

            Library:ApplyGlass(
                NewKey.Frame,
                "Element",
                4
            )

            NewKey.Marker =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            NewKey.Frame.Instance,

                        Position =
                            UDim2New(
                                0,
                                7,
                                0.5,
                                0
                            ),

                        AnchorPoint =
                            Vector2New(0, 0.5),

                        Size =
                            UDim2New(
                                0,
                                3,
                                0,
                                13
                            ),

                        BorderSizePixel = 0,
                        BackgroundColor3 =
                            Library.Theme.Accent,
                        BackgroundTransparency = 1,
                        ZIndex = 403
                    }
                )

            NewKey.Marker:AddToTheme({
                BackgroundColor3 = "Accent"
            })

            NewKey.Name =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            NewKey.Frame.Instance,

                        Position =
                            UDim2New(
                                0,
                                16,
                                0,
                                0
                            ),

                        Size =
                            UDim2New(
                                0,
                                122,
                                1,
                                0
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        FontFace = Library.Font,
                        Text = NewKey.RawName,
                        TextSize = 10,
                        TextXAlignment =
                            Enum.TextXAlignment.Left,
                        TextColor3 =
                            Library.Theme.Text,
                        TextTruncate =
                            Enum.TextTruncate.AtEnd,
                        ZIndex = 403
                    }
                )

            NewKey.Name:AddToTheme({
                TextColor3 = "Text"
            })

            NewKey.Key =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            NewKey.Frame.Instance,

                        Position =
                            UDim2New(
                                0,
                                144,
                                0,
                                0
                            ),

                        Size =
                            UDim2New(
                                0,
                                45,
                                1,
                                0
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        FontFace = Library.Font,
                        Text = FormatKey(NewKey.RawKey),
                        TextSize = 10,
                        TextXAlignment =
                            Enum.TextXAlignment.Left,
                        TextColor3 =
                            Library.Theme.Text,
                        ZIndex = 403
                    }
                )

            NewKey.Key:AddToTheme({
                TextColor3 = "Text"
            })

            NewKey.Status =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            NewKey.Frame.Instance,

                        Position =
                            UDim2New(
                                0,
                                198,
                                0,
                                0
                            ),

                        Size =
                            UDim2New(
                                0,
                                48,
                                1,
                                0
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        FontFace = Library.Font,
                        Text = FormatMode(NewKey.Mode),
                        TextSize = 10,
                        TextXAlignment =
                            Enum.TextXAlignment.Left,
                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],
                        ZIndex = 403
                    }
                )

            NewKey.Status:AddToTheme({
                TextColor3 = "Muted Text"
            })

            NewKey.More =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            NewKey.Frame.Instance,

                        AnchorPoint =
                            Vector2New(1, 0.5),

                        Position =
                            UDim2New(
                                1,
                                -8,
                                0.5,
                                0
                            ),

                        Size =
                            UDim2New(
                                0,
                                14,
                                0,
                                14
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        FontFace = Library.Font,
                        Text = "...",
                        TextSize = 10,
                        TextXAlignment =
                            Enum.TextXAlignment.Right,
                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],
                        ZIndex = 403
                    }
                )

            NewKey.More:AddToTheme({
                TextColor3 = "Muted Text"
            })

            local function ApplyState()
                NewKey.Marker:Tween(
                    RowTween,
                    {
                        BackgroundTransparency =
                            NewKey.Active
                            and 0
                            or 1
                    }
                )

                NewKey.Frame:Tween(
                    RowTween,
                    {
                        BackgroundTransparency =
                            NewKey.Active
                            and 0.36
                            or 0.58
                    }
                )

                NewKey.Status:Tween(
                    RowTween,
                    {
                        TextColor3 =
                            NewKey.Active
                            and Library.Theme.Text
                            or Library.Theme[
                                "Muted Text"
                            ]
                    }
                )
            end

            NewKey.Frame:OnHover(function()
                if NewKey.Active then
                    return
                end

                NewKey.Frame:Tween(
                    RowTween,
                    {
                        BackgroundTransparency = 0.46
                    }
                )

                NewKey.More:Tween(
                    RowTween,
                    {
                        TextColor3 =
                            Library.Theme.Text
                    }
                )
            end)

            NewKey.Frame:OnHoverLeave(function()
                if NewKey.Active then
                    NewKey.More:Tween(
                        RowTween,
                        {
                            TextColor3 =
                                Library.Theme[
                                    "Muted Text"
                                ]
                        }
                    )

                    return
                end

                NewKey.Frame:Tween(
                    RowTween,
                    {
                        BackgroundTransparency = 0.58
                    }
                )

                NewKey.More:Tween(
                    RowTween,
                    {
                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ]
                    }
                )
            end)

            function NewKey:Set(
                ModeValue,
                NameValue,
                KeyValue
            )
                NewKey.Mode =
                    tostring(
                        ModeValue
                        or NewKey.Mode
                    )

                NewKey.RawName =
                    tostring(
                        NameValue
                        or NewKey.RawName
                    )

                NewKey.RawKey =
                    tostring(
                        KeyValue
                        or NewKey.RawKey
                    )

                NewKey.Name.Instance.Text =
                    NewKey.RawName

                NewKey.Key.Instance.Text =
                    FormatKey(
                        NewKey.RawKey
                    )

                NewKey.Status.Instance.Text =
                    FormatMode(
                        NewKey.Mode
                    )
            end

            function NewKey:SetStatus(Status)
                local Value =
                    tostring(Status or "")

                NewKey.Active =
                    Value == "Active"
                    or Value == "On"
                    or Value == "Enabled"

                ApplyState()
            end

            function NewKey:Destroy()
                if NewKey.Frame
                    and NewKey.Frame.Instance
                then
                    NewKey.Frame.Instance:
                        Destroy()
                end
            end

            KeybindList.Rows[
                #KeybindList.Rows + 1
            ] = NewKey

            ApplyState()

            return NewKey
        end

        Items.Pin:Connect(
            "MouseButton1Click",
            function()
                KeybindList.Pinned =
                    not KeybindList.Pinned

                Items.PinIcon:SetTheme(
                    KeybindList.Pinned
                    and "Accent"
                    or "Muted Text"
                )
            end
        )

        function KeybindList:SetVisibility(Bool)
            KeybindList.Visible =
                Bool == true

            Items.Frame.Instance.Visible =
                KeybindList.Visible
        end

        function KeybindList:SetScale(Value)
            KeybindList.Scale =
                math.clamp(
                    tonumber(Value)
                    or 1,
                    0.6,
                    1.5
                )

            Items.Scale.Instance.Scale =
                KeybindList.Scale
        end

        KeybindList.Frame =
            Items.Frame.Instance

        KeybindList.Items = Items

        return KeybindList
    end

    Library.InlineAddonLayouts = Library.InlineAddonLayouts or setmetatable({}, { __mode = "k" })

    Library.RegisterInlineAddon = function(self, Parent, Instance, Kind)
        local ParentInstance =
            Library:ResolveInstance(
                Parent
            )

        if typeof(ParentInstance) ~= "Instance" or typeof(Instance) ~= "Instance" then
            return
        end

        local Layout = Library.InlineAddonLayouts[ParentInstance]

        if not Layout then
            Layout = {
                Parent = ParentInstance,
                Items = {},
                Connections = setmetatable({}, { __mode = "k" }),
                Updating = false
            }

            Library.InlineAddonLayouts[ParentInstance] = Layout
        end

        for _, Existing in ipairs(Layout.Items) do
            if Existing.Instance == Instance then
                Existing.Kind = Kind or Existing.Kind

                if Existing.Relayout then
                    task.defer(Existing.Relayout)
                end

                return
            end
        end

        local Item = {
            Instance = Instance,
            Kind = Kind or "Addon",
            Order = #Layout.Items + 1
        }

        Layout.Items[#Layout.Items + 1] = Item

        local function Priority(Value)
            if Value.Kind == "Colorpicker" then
                return 1
            elseif Value.Kind == "Keybind" then
                return 2
            end

            return 3
        end

        local function Relayout()
            if Layout.Updating then return end
            Layout.Updating = true

            local ActiveItems = {}

            for Index = #Layout.Items, 1, -1 do
                local Current = Layout.Items[Index]

                if not Current.Instance or not Current.Instance.Parent then
                    table.remove(Layout.Items, Index)
                else
                    ActiveItems[#ActiveItems + 1] = Current
                end
            end

            table.sort(ActiveItems, function(A, B)
                local PriorityA = Priority(A)
                local PriorityB = Priority(B)

                if PriorityA == PriorityB then
                    return A.Order < B.Order
                end

                return PriorityA < PriorityB
            end)

            local Offset = 0
            local Spacing = 5

            for _, Current in ipairs(ActiveItems) do
                local Addon = Current.Instance
                local Width = Addon.AbsoluteSize.X

                if Width <= 1 then
                    if Current.Kind == "Colorpicker" then
                        Width = 22
                    elseif Current.Kind == "Keybind" then
                        Width = 24
                    else
                        Width = 18
                    end
                end

                local Position = Addon.Position

                Addon.Position = UDim2New(
                    1,
                    -Offset,
                    Position.Y.Scale,
                    Position.Y.Offset
                )

                Offset = Offset + Width + Spacing
            end

            Layout.Updating = false
        end

        Item.Relayout = Relayout

        if not Layout.Connections[Instance] then
            Layout.Connections[Instance] =
                Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                    task.defer(Relayout)
                end)
        end

        if not Layout.ParentConnection then
            Layout.ParentConnection =
                ParentInstance.ChildRemoved:Connect(function()
                    task.defer(Relayout)
                end)
        end

        task.defer(Relayout)
    end

    Library.CreateColorpicker = function(self, Data)
        local Colorpicker = {
            Hue = 0,
            Saturation = 0,
            Value = 0,

            Alpha = 0,

            HexValue = "",

            IsOpen = false,
            LastToggleAt = 0,

            Color = FromRGB(0, 0, 0),

            Class = "Colorpicker"
        }

        Library.Flags[Data.Flag] = { }

        local Items = { } do
            Items["ColorpickerButton"] = Instances:Create("TextButton", {
                Parent = Data.Parent.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0.5),
                Name = string.char(0),
                Position = UDim2New(1, 0, 0.5, 0),
                Size = UDim2New(0, 25, 0, 18),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = Library.Theme.Element,
                ZIndex = 250,
                Active = true,
                Selectable = false
            })

            Colorpicker.CalculateCount = function(self, Index, YScale, YOffset)
                local MaxButtonsAdded = 5

                local Column = Index % MaxButtonsAdded

                local ButtonSize = Items["ColorpickerButton"].Instance.AbsoluteSize
                local Spacing = 4

                local XPosition = (ButtonSize.X + Spacing) * Column - Spacing - 21

                Items["ColorpickerButton"].Instance.Position = UDim2New(1, -XPosition, YScale or 0.5, YOffset or 0)
            end

            Colorpicker:CalculateCount(Data.Count)

            Items["ColorpickerButton"]:AddToTheme({
                BackgroundColor3 = "Element"
            })
            Library:ApplyGlass(
                Items["ColorpickerButton"],
                "Element",
                5
            )

            Items["PaletteBody"] = Instances:Create("Frame", {
                Parent = Items["ColorpickerButton"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 15, 0, 11),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 0, 0),
                ZIndex = 252
            })

            local PaletteBodyCorner = InstanceNew("UICorner")
            PaletteBodyCorner.CornerRadius = UDimNew(1, 0)
            PaletteBodyCorner.Parent = Items["PaletteBody"].Instance

            Items["PaletteHole"] = Instances:Create("Frame", {
                Parent = Items["PaletteBody"].Instance,
                AnchorPoint = Vector2New(1, 1),
                Position = UDim2New(1, 0, 1, 0),
                Size = UDim2New(0, 5, 0, 5),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Element,
                ZIndex = 253
            })
            Items["PaletteHole"]:AddToTheme({
                BackgroundColor3 = "Element"
            })

            local PaletteHoleCorner = InstanceNew("UICorner")
            PaletteHoleCorner.CornerRadius = UDimNew(1, 0)
            PaletteHoleCorner.Parent = Items["PaletteHole"].Instance

            local PaletteTween =
                TweenInfo.new(
                    0.12,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )

            Items["ColorpickerButton"]:OnHover(function()
                Items["ColorpickerButton"]:Tween(
                    PaletteTween,
                    {
                        BackgroundColor3 =
                            Library.Theme["Hovered Element"]
                    }
                )

                Items["PaletteBody"]:Tween(
                    PaletteTween,
                    {
                        Size =
                            UDim2New(
                                0,
                                16,
                                0,
                                12
                            )
                    }
                )
            end)

            Items["ColorpickerButton"]:OnHoverLeave(function()
                if Colorpicker.IsOpen then
                    return
                end

                Items["ColorpickerButton"]:Tween(
                    PaletteTween,
                    {
                        BackgroundColor3 =
                            Library.Theme.Element
                    }
                )

                Items["PaletteBody"]:Tween(
                    PaletteTween,
                    {
                        Size =
                            UDim2New(
                                0,
                                15,
                                0,
                                11
                            )
                    }
                )
            end)

            Items["ColorpickerWindow"] = Instances:Create("TextButton", {
                Parent = Library.Holder.Instance,
                AutoButtonColor = false,
                Text = "",
                Name = string.char(0),
                Position = UDim2New(0, Data.Parent.Instance.AbsolutePosition.X, 0, Data.Parent.Instance.AbsolutePosition.Y + 15),
                BorderColor3 = FromRGB(10, 10, 10),
                Visible = false,
                Size = UDim2New(0, 282, 0, 286),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Background,
                ZIndex = 1000,
                Active = true,
                Modal = false
            })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"})
            Library:ApplyGlass(
                Items["ColorpickerWindow"],
                "Popup",
                7
            )

            Instances:Create("UIStroke", {
                Parent = Items["ColorpickerWindow"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Data.Name,
                Name = string.char(0),
                Size = UDim2New(1, -8, 0, 18),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 0, 0, 0),
                BorderSizePixel = 0,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Items["ColorpickerWindow"]:MakeDraggable(
                Items["Title"]
            )

            Instances:Create("UIPadding", {
                Parent = Items["ColorpickerWindow"].Instance,
                PaddingTop = UDimNew(0, 8),
                PaddingBottom = UDimNew(0, 8),
                PaddingRight = UDimNew(0, 8),
                PaddingLeft = UDimNew(0, 8)
            })

            Items["Palette"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 26),
                Size = UDim2New(1, -30, 0, 150),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0)
            })

            Items["Saturation"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Saturation"),
                BackgroundTransparency = 1,
                Name = string.char(0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Value"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Value"),
                BackgroundTransparency = 1,
                Name = string.char(0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Palette"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["PaletteDragger"] = Instances:Create("Frame", {
                Parent = Items["Palette"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 2, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["PaletteDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Hue"] = Instances:Create("ImageButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                Image = Library:GetImage("Hue"),
                Name = string.char(0),
                Position = UDim2New(1, 0, 0, 26),
                Size = UDim2New(0, 20, 0, 150),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["HueDragger"] = Instances:Create("Frame", {
                Parent = Items["Hue"].Instance,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["HueDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Hue"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Alpha"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2New(0, 1),
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 184),
                Size = UDim2New(1, 0, 0, 14),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Alpha"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Checkers"] = Instances:Create("ImageLabel", {
                Parent = Items["Alpha"].Instance,
                ScaleType = Enum.ScaleType.Tile,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Checkers"),
                TileSize = UDim2New(0, 6, 0, 6),
                Name = string.char(0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIGradient", {
                Parent = Items["Checkers"].Instance,
                Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
            })

            Instances:Create("UIGradient", {
                Parent = Items["Alpha"].Instance,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(0, 0, 0))}
            })

            Items["AlphaDragger"] = Instances:Create("Frame", {
                Parent = Items["Alpha"].Instance,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 1, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["AlphaDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})


            local function CreateValueField(
                Key,
                Caption,
                Position,
                Size
            )
                local Field = Instances:Create("Frame", {
                    Parent = Items["ColorpickerWindow"].Instance,
                    Position = Position,
                    Size = Size,
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Element,
                    ZIndex = 1002
                })
                Field:AddToTheme({
                    BackgroundColor3 = "Element"
                })
                Library:ApplyGlass(Field, "Element", 4)

                local CaptionLabel = Instances:Create("TextLabel", {
                    Parent = Field.Instance,
                    Position = UDim2New(0, 7, 0, 0),
                    Size = UDim2New(0, 34, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    FontFace = Library.Font,
                    Text = Caption,
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextColor3 = Library.Theme["Muted Text"],
                    ZIndex = 1003
                })
                CaptionLabel:AddToTheme({
                    TextColor3 = "Muted Text"
                })

                local Input = Instances:Create("TextBox", {
                    Parent = Field.Instance,
                    Position = UDim2New(0, 40, 0, 0),
                    Size = UDim2New(1, -47, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    ClearTextOnFocus = false,
                    FontFace = Library.Font,
                    Text = "",
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextColor3 = Library.Theme.Text,
                    PlaceholderColor3 = Library.Theme["Muted Text"],
                    ZIndex = 1003
                })
                Input:AddToTheme({
                    TextColor3 = "Text",
                    PlaceholderColor3 = "Muted Text"
                })

                local FieldTween =
                    TweenInfo.new(
                        0.10,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    )

                Field:OnHover(function()
                    Field:Tween(
                        FieldTween,
                        {
                            BackgroundColor3 =
                                Library.Theme["Hovered Element"]
                        }
                    )
                end)

                Field:OnHoverLeave(function()
                    Field:Tween(
                        FieldTween,
                        {
                            BackgroundColor3 =
                                Library.Theme.Element
                        }
                    )
                end)

                Items[Key] = Input
                return Input
            end

            CreateValueField(
                "HexInput",
                "HEX",
                UDim2New(0, 0, 0, 207),
                UDim2New(0.5, -4, 0, 25)
            )

            CreateValueField(
                "AlphaInput",
                "ALPHA",
                UDim2New(0.5, 4, 0, 207),
                UDim2New(0.5, -4, 0, 25)
            )

            CreateValueField(
                "RGBInput",
                "RGB",
                UDim2New(0, 0, 0, 238),
                UDim2New(0.5, -4, 0, 25)
            )

            CreateValueField(
                "HSVInput",
                "HSV",
                UDim2New(0.5, 4, 0, 238),
                UDim2New(0.5, -4, 0, 25)
            )
        end

        Colorpicker.Button =
            Items[
                "ColorpickerButton"
            ].Instance

        Colorpicker.Window =
            Items[
                "ColorpickerWindow"
            ].Instance

        TableInsert(
            Library.Colorpickers,
            Colorpicker
        )

        if not Library.ColorpickerOverlay
            or not Library.ColorpickerOverlay.Parent
        then
            local Overlay =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Library.Holder.Instance,
                        Name = string.char(0),
                        Text = "",
                        AutoButtonColor = false,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position =
                            UDim2New(
                                0,
                                0,
                                0,
                                0
                            ),
                        Size =
                            UDim2New(
                                1,
                                0,
                                1,
                                0
                            ),
                        Visible = false,
                        Active = true,
                        Modal = false,
                        ZIndex = 900
                    }
                )

            Library.ColorpickerOverlay =
                Overlay.Instance

            local OverlayConnection =
                Overlay.Instance
                    .MouseButton1Down:
                Connect(function()
                    local Current =
                        Library.CurrentColorpicker

                    if Current
                        and Current.IsOpen
                    then
                        Current:
                            SetOpen(
                                false
                            )
                    end
                end)

            TableInsert(
                Library.CoreConnections,
                OverlayConnection
            )
        end

        Colorpicker.SlidingMode = nil
        Colorpicker.OpenedAt = 0

        function Colorpicker:ToggleOpen()
            local CurrentTime =
                os.clock()

            if CurrentTime
                - Colorpicker.LastToggleAt
                < 0.12
            then
                return
            end

            Colorpicker.LastToggleAt =
                CurrentTime

            Colorpicker:
                SetOpen(
                    not Colorpicker.IsOpen
                )
        end

        function Colorpicker:SetOpen(
            Bool
        )
            Bool =
                Bool == true

            if Bool
                and Library.CurrentColorpicker
                and Library.CurrentColorpicker
                    ~= Colorpicker
            then
                Library.CurrentColorpicker:
                    SetOpen(
                        false
                    )
            end

            local Window =
                Items[
                    "ColorpickerWindow"
                ].Instance

            local Overlay =
                Library.ColorpickerOverlay

            Colorpicker.IsOpen =
                Bool

            if Bool then
                local ParentPosition =
                    Data.Parent.Instance
                        .AbsolutePosition

                local ParentSize =
                    Data.Parent.Instance
                        .AbsoluteSize

                local ViewportSize =
                    Workspace.CurrentCamera
                    and Workspace.CurrentCamera
                        .ViewportSize
                    or Vector2New(
                        1920,
                        1080
                    )

                local WindowSize =
                    Window.AbsoluteSize

                if WindowSize.X <= 0
                    or WindowSize.Y <= 0
                then
                    WindowSize =
                        Vector2New(
                            282,
                            286
                        )
                end

                local X =
                    MathClamp(
                        ParentPosition.X
                        + ParentSize.X
                        - WindowSize.X,
                        6,
                        math.max(
                            ViewportSize.X
                            - WindowSize.X
                            - 6,
                            6
                        )
                    )

                local Below =
                    ParentPosition.Y
                    + ParentSize.Y
                    + 5

                local Above =
                    ParentPosition.Y
                    - WindowSize.Y
                    - 5

                local Y =
                    Below
                    + WindowSize.Y
                        <= ViewportSize.Y
                    and Below
                    or math.max(
                        Above,
                        6
                    )

                Window.Position =
                    UDim2New(
                        0,
                        X,
                        0,
                        Y
                    )

                if Overlay then
                    Overlay.Visible =
                        true

                    Overlay.Active =
                        true

                    Overlay.ZIndex =
                        900
                end

                Window.Visible =
                    true

                Window.Active =
                    true

                Window.Modal =
                    false

                Window.ZIndex =
                    1000

                for _,
                    Descendant in ipairs(
                        Window:
                        GetDescendants()
                    )
                do
                    if Descendant:IsA(
                        "GuiObject"
                    )
                    then
                        Descendant.ZIndex =
                            math.max(
                                Descendant.ZIndex,
                                1001
                            )
                    end
                end

                Colorpicker.OpenedAt =
                    os.clock()

                Library.CurrentColorpicker =
                    Colorpicker
            else
                Colorpicker.SlidingMode =
                    nil

                if Library.ActiveColorpicker
                    == Colorpicker
                then
                    Library.ActiveColorpicker =
                        nil
                end

                Window.Modal =
                    false

                Window.Active =
                    false

                Window.Visible =
                    false

                if Overlay then
                    Overlay.Active =
                        false

                    Overlay.Visible =
                        false
                end

                if Library.CurrentColorpicker
                    == Colorpicker
                then
                    Library.CurrentColorpicker =
                        nil
                end
            end
        end

        function Colorpicker:Get()
            return Colorpicker.Color,
                Colorpicker.Alpha
        end

        function Colorpicker:SetVisibility(Bool)
           Data.Parent.Instance.Visible = Bool
        end

        function Colorpicker:Set(
            Color,
            Alpha
        )
            if type(Color)
                == "table"
            then
                local Red =
                    Color[1]

                local Green =
                    Color[2]

                local Blue =
                    Color[3]

                Alpha =
                    Alpha
                    or Color[4]

                Color =
                    FromRGB(
                        Red,
                        Green,
                        Blue
                    )
            elseif type(Color)
                == "string"
            then
                local Success, ParsedColor = pcall(
                    FromHex,
                    Color
                )

                if not Success then
                    return
                end

                Color = ParsedColor
            end

            if typeof(Color)
                ~= "Color3"
            then
                return
            end

            self.Hue,
                self.Saturation,
                self.Value =
                Color:ToHSV()

            self.Alpha =
                MathClamp(
                    tonumber(Alpha)
                    or 0,
                    0,
                    1
                )

            self.Color =
                FromHSV(
                    self.Hue,
                    self.Saturation,
                    self.Value
                )

            self.HexValue =
                self.Color:
                ToHex()

            Library.Flags[
                Data.Flag
            ] = {
                Color = self.Color,
                HexValue = self.HexValue,
                Alpha = self.Alpha
            }

            Items[
                "PaletteDragger"
            ].Instance.Position =
                UDim2New(
                    MathClamp(
                        1 - self.Saturation,
                        0,
                        0.989
                    ),
                    0,
                    MathClamp(
                        1 - self.Value,
                        0,
                        0.989
                    ),
                    0
                )

            Items[
                "HueDragger"
            ].Instance.Position =
                UDim2New(
                    0,
                    0,
                    MathClamp(
                        self.Hue,
                        0,
                        0.994
                    ),
                    0
                )

            Items[
                "AlphaDragger"
            ].Instance.Position =
                UDim2New(
                    MathClamp(
                        self.Alpha,
                        0,
                        0.994
                    ),
                    0,
                    0,
                    0
                )

            self:Update()
        end

        function Colorpicker:Update(
            IsFromAlpha
        )
            self.Color =
                FromHSV(
                    self.Hue,
                    self.Saturation,
                    self.Value
                )

            self.HexValue =
                self.Color:
                ToHex()

            Library.Flags[
                Data.Flag
            ] = {
                Color = self.Color,
                HexValue = self.HexValue,
                Alpha = self.Alpha
            }

            if Items["PaletteBody"] then
                Items["PaletteBody"].Instance.BackgroundColor3 =
                    self.Color
            end

            if Items["HexInput"] then
                Items["HexInput"].Instance.Text =
                    "#" .. self.HexValue
            end

            if Items["RGBInput"] then
                Items["RGBInput"].Instance.Text =
                    StringFormat(
                        "%d, %d, %d",
                        MathFloor(self.Color.R * 255 + 0.5),
                        MathFloor(self.Color.G * 255 + 0.5),
                        MathFloor(self.Color.B * 255 + 0.5)
                    )
            end

            if Items["HSVInput"] then
                Items["HSVInput"].Instance.Text =
                    StringFormat(
                        "%d, %d, %d",
                        MathFloor(self.Hue * 360 + 0.5),
                        MathFloor(self.Saturation * 100 + 0.5),
                        MathFloor(self.Value * 100 + 0.5)
                    )
            end

            if Items["AlphaInput"] then
                Items["AlphaInput"].Instance.Text =
                    StringFormat(
                        "%d%%",
                        MathFloor(self.Alpha * 100 + 0.5)
                    )
            end

            Items[
                "Palette"
            ].Instance.BackgroundColor3 =
                FromHSV(
                    self.Hue,
                    1,
                    1
                )

            if not IsFromAlpha then
                Items[
                    "Alpha"
                ].Instance.BackgroundColor3 =
                    self.Color
            end

            if Data.Callback then
                Library:SafeCall(
                    Data.Callback,
                    self.Color,
                    self.Alpha
                )
            end
        end

        function Colorpicker:UpdateFromMouse()
            local MousePosition =
                Library:
                GetPointerPosition()

            if Colorpicker.SlidingMode
                == "Palette"
            then
                local Position =
                    Items[
                        "Palette"
                    ].Instance.AbsolutePosition

                local Size =
                    Items[
                        "Palette"
                    ].Instance.AbsoluteSize

                if Size.X <= 0
                    or Size.Y <= 0
                then
                    return
                end

                local SlideX =
                    MathClamp(
                        (
                            MousePosition.X
                            - Position.X
                        ) / Size.X,
                        0,
                        0.989
                    )

                local SlideY =
                    MathClamp(
                        (
                            MousePosition.Y
                            - Position.Y
                        ) / Size.Y,
                        0,
                        0.989
                    )

                self.Saturation =
                    1 - SlideX

                self.Value =
                    1 - SlideY

                Items[
                    "PaletteDragger"
                ].Instance.Position =
                    UDim2New(
                        SlideX,
                        0,
                        SlideY,
                        0
                    )

                self:Update()
            elseif Colorpicker.SlidingMode
                == "Hue"
            then
                local Position =
                    Items[
                        "Hue"
                    ].Instance.AbsolutePosition

                local Size =
                    Items[
                        "Hue"
                    ].Instance.AbsoluteSize

                if Size.Y <= 0 then
                    return
                end

                local PositionY =
                    MathClamp(
                        (
                            MousePosition.Y
                            - Position.Y
                        ) / Size.Y,
                        0,
                        0.994
                    )

                self.Hue =
                    PositionY

                Items[
                    "HueDragger"
                ].Instance.Position =
                    UDim2New(
                        0,
                        0,
                        PositionY,
                        0
                    )

                self:Update()
            elseif Colorpicker.SlidingMode
                == "Alpha"
            then
                local Position =
                    Items[
                        "Alpha"
                    ].Instance.AbsolutePosition

                local Size =
                    Items[
                        "Alpha"
                    ].Instance.AbsoluteSize

                if Size.X <= 0 then
                    return
                end

                local PositionX =
                    MathClamp(
                        (
                            MousePosition.X
                            - Position.X
                        ) / Size.X,
                        0,
                        0.994
                    )

                self.Alpha =
                    PositionX

                Items[
                    "AlphaDragger"
                ].Instance.Position =
                    UDim2New(
                        PositionX,
                        0,
                        0,
                        0
                    )

                self:Update(
                    true
                )
            end
        end

        function Colorpicker:BeginSlide(
            Mode
        )
            Colorpicker.SlidingMode =
                Mode

            Library.ActiveColorpicker =
                Colorpicker

            Colorpicker:
                UpdateFromMouse()
        end

        function Colorpicker:EndSlide()
            Colorpicker.SlidingMode =
                nil

            if Library.ActiveColorpicker
                == Colorpicker
            then
                Library.ActiveColorpicker =
                    nil
            end
        end

        local function ParseNumbers(Value)
            local Numbers = { }

            for Number in tostring(Value or ""):
                gmatch("[-+]?%d*%.?%d+")
            do
                Numbers[#Numbers + 1] =
                    tonumber(Number)
            end

            return Numbers
        end

        if Items["HexInput"] then
            Items["HexInput"]:Connect(
                "FocusLost",
                function()
                    local Value =
                        Items["HexInput"].Instance.Text:
                        gsub("#", ""):
                        gsub("%s+", "")

                    if #Value == 3 then
                        Value =
                            Value:sub(1, 1):rep(2)
                            .. Value:sub(2, 2):rep(2)
                            .. Value:sub(3, 3):rep(2)
                    end

                    local Success, Parsed =
                        pcall(
                            FromHex,
                            "#" .. Value
                        )

                    if Success and Parsed then
                        Colorpicker:Set(
                            Parsed,
                            Colorpicker.Alpha
                        )
                    else
                        Colorpicker:Update()
                    end
                end
            )
        end

        if Items["RGBInput"] then
            Items["RGBInput"]:Connect(
                "FocusLost",
                function()
                    local Values =
                        ParseNumbers(
                            Items["RGBInput"].Instance.Text
                        )

                    if #Values >= 3 then
                        Colorpicker:Set(
                            FromRGB(
                                MathClamp(Values[1], 0, 255),
                                MathClamp(Values[2], 0, 255),
                                MathClamp(Values[3], 0, 255)
                            ),
                            Colorpicker.Alpha
                        )
                    else
                        Colorpicker:Update()
                    end
                end
            )
        end

        if Items["HSVInput"] then
            Items["HSVInput"]:Connect(
                "FocusLost",
                function()
                    local Values =
                        ParseNumbers(
                            Items["HSVInput"].Instance.Text
                        )

                    if #Values >= 3 then
                        Colorpicker.Hue =
                            (
                                MathClamp(
                                    Values[1],
                                    0,
                                    360
                                )
                                / 360
                            )

                        Colorpicker.Saturation =
                            (
                                MathClamp(
                                    Values[2],
                                    0,
                                    100
                                )
                                / 100
                            )

                        Colorpicker.Value =
                            (
                                MathClamp(
                                    Values[3],
                                    0,
                                    100
                                )
                                / 100
                            )

                        Colorpicker:Update()
                    else
                        Colorpicker:Update()
                    end
                end
            )
        end

        if Items["AlphaInput"] then
            Items["AlphaInput"]:Connect(
                "FocusLost",
                function()
                    local Values =
                        ParseNumbers(
                            Items["AlphaInput"].Instance.Text
                        )

                    if #Values >= 1 then
                        Colorpicker.Alpha =
                            MathClamp(
                                Values[1] / 100,
                                0,
                                1
                            )

                        Colorpicker:Update(true)
                    else
                        Colorpicker:Update()
                    end
                end
            )
        end

        Items[
            "ColorpickerButton"
        ]:Connect(
            "MouseButton1Down",
            function()
                Colorpicker:
                    ToggleOpen()
            end
        )

        Items[
            "Palette"
        ]:Connect(
            "InputBegan",
            function(Input)
                if Input.UserInputType
                        == Enum.UserInputType.MouseButton1
                    or Input.UserInputType
                        == Enum.UserInputType.Touch
                then
                    Colorpicker:
                        BeginSlide(
                            "Palette"
                        )
                end
            end
        )

        Items[
            "Hue"
        ]:Connect(
            "InputBegan",
            function(Input)
                if Input.UserInputType
                        == Enum.UserInputType.MouseButton1
                    or Input.UserInputType
                        == Enum.UserInputType.Touch
                then
                    Colorpicker:
                        BeginSlide(
                            "Hue"
                        )
                end
            end
        )

        Items[
            "Alpha"
        ]:Connect(
            "InputBegan",
            function(Input)
                if Input.UserInputType
                        == Enum.UserInputType.MouseButton1
                    or Input.UserInputType
                        == Enum.UserInputType.Touch
                then
                    Colorpicker:
                        BeginSlide(
                            "Alpha"
                        )
                end
            end
        )

        Library:Connect(
            UserInputService.InputBegan,
            function(Input)
                if not Colorpicker.IsOpen then
                    return
                end

                if Input.UserInputType
                        ~= Enum.UserInputType.MouseButton1
                    and Input.UserInputType
                        ~= Enum.UserInputType.Touch
                then
                    return
                end

                if os.clock()
                    - Colorpicker.OpenedAt
                    < 0.18
                then
                    return
                end

                if Library:IsMouseOverFrame(
                    Items[
                        "ColorpickerWindow"
                    ]
                )
                    or Library:IsMouseOverFrame(
                        Items[
                            "ColorpickerButton"
                        ]
                    )
                then
                    return
                end

                Colorpicker:SetOpen(
                    false
                )
            end
        )

        if not Library.ColorpickerConnection then
            Library.ColorpickerConnection =
                Library:Connect(
                    RunService.RenderStepped,
                    function()
                        local Active =
                            Library.ActiveColorpicker

                        if Active
                            and Active.IsOpen
                            and Active.SlidingMode
                        then
                            Active:
                                UpdateFromMouse()
                        end
                    end,
                    "Library_Colorpicker_Renderer"
                )
        end

        if not Library.ColorpickerInputConnection then
            Library.ColorpickerInputConnection =
                Library:Connect(
                    UserInputService.InputEnded,
                    function(Input)
                        if Input.UserInputType
                                == Enum.UserInputType.MouseButton1
                            or Input.UserInputType
                                == Enum.UserInputType.Touch
                        then
                            local Active =
                                Library.ActiveColorpicker

                            if Active then
                                Active:
                                    EndSlide()
                            end
                        end
                    end,
                    "Library_Colorpicker_InputEnded"
                )
        end

        if Data.Default then
            Colorpicker:Set(Data.Default, Data.Alpha)
        end

        Library.SetFlags[Data.Flag] = function(Color, Alpha)
            Colorpicker:Set(Color, Alpha)
        end

        Colorpicker.Button = Items["ColorpickerButton"].Instance
        Colorpicker.Items = Items

        Library:RegisterInlineAddon(
            Data.Parent,
            Colorpicker.Button,
            "Colorpicker"
        )

        return Colorpicker
    end

    local function ResolveKey(Value)
        if typeof(Value) == "EnumItem" then
            return Value
        end

        if type(Value) == "table" then
            Value =
                Value.Key
                or Value.Name
                or Value.Value
        end

        if type(Value) ~= "string" then
            return nil
        end

        local Clean =
            Value:gsub("%s+", "")

        local Upper =
            string.upper(Clean)

        if Clean == ""
            or Upper == "NONE"
            or Upper == "NIL"
        then
            return nil
        end

        Clean = Clean:
            gsub("^Enum%.", ""):
            gsub("^KeyCode%.", ""):
            gsub("^UserInputType%.", "")

        Upper = string.upper(Clean)

        local Alias = {
            MB1 = "MouseButton1",
            MB2 = "MouseButton2",
            MB3 = "MouseButton3",
            MB4 = "MouseButton4",
            MB5 = "MouseButton5",
            M1 = "MouseButton1",
            M2 = "MouseButton2",
            M3 = "MouseButton3",
            M4 = "MouseButton4",
            M5 = "MouseButton5",
            MOUSE1 = "MouseButton1",
            MOUSE2 = "MouseButton2",
            MOUSE3 = "MouseButton3",
            MOUSE4 = "MouseButton4",
            MOUSE5 = "MouseButton5",
            XBUTTON1 = "MouseButton4",
            XBUTTON2 = "MouseButton5",
            SIDE1 = "MouseButton4",
            SIDE2 = "MouseButton5",

            NUM0 = "KeypadZero",
            NUM1 = "KeypadOne",
            NUM2 = "KeypadTwo",
            NUM3 = "KeypadThree",
            NUM4 = "KeypadFour",
            NUM5 = "KeypadFive",
            NUM6 = "KeypadSix",
            NUM7 = "KeypadSeven",
            NUM8 = "KeypadEight",
            NUM9 = "KeypadNine",

            NUMPAD0 = "KeypadZero",
            NUMPAD1 = "KeypadOne",
            NUMPAD2 = "KeypadTwo",
            NUMPAD3 = "KeypadThree",
            NUMPAD4 = "KeypadFour",
            NUMPAD5 = "KeypadFive",
            NUMPAD6 = "KeypadSix",
            NUMPAD7 = "KeypadSeven",
            NUMPAD8 = "KeypadEight",
            NUMPAD9 = "KeypadNine",

            KP0 = "KeypadZero",
            KP1 = "KeypadOne",
            KP2 = "KeypadTwo",
            KP3 = "KeypadThree",
            KP4 = "KeypadFour",
            KP5 = "KeypadFive",
            KP6 = "KeypadSix",
            KP7 = "KeypadSeven",
            KP8 = "KeypadEight",
            KP9 = "KeypadNine",

            NUMPLUS = "KeypadPlus",
            NUMMINUS = "KeypadMinus",
            NUMMULTIPLY = "KeypadMultiply",
            NUMDIVIDE = "KeypadDivide",
            NUMPERIOD = "KeypadPeriod",
            NUMDECIMAL = "KeypadPeriod",
            NUMENTER = "KeypadEnter",

            KPPLUS = "KeypadPlus",
            KPMINUS = "KeypadMinus",
            KPMULTIPLY = "KeypadMultiply",
            KPDIVIDE = "KeypadDivide",
            KPPERIOD = "KeypadPeriod",
            KPENTER = "KeypadEnter"
        }

        Clean =
            Alias[Upper]
            or Clean

        local Success,
            Result =
            pcall(function()
                return Enum.KeyCode[Clean]
            end)

        if Success and Result then
            return Result
        end

        Success,
            Result =
            pcall(function()
                return Enum.UserInputType[Clean]
            end)

        if Success and Result then
            return Result
        end

        return nil
    end

    local function FormatKey(Key)
        if not Key then
            return "None"
        end

        local Name =
            tostring(Key.Name or "")

        local Display = {
            MouseButton1 = "MB1",
            MouseButton2 = "MB2",
            MouseButton3 = "MB3",
            MouseButton4 = "MB4",
            MouseButton5 = "MB5",

            KeypadZero = "Num 0",
            KeypadOne = "Num 1",
            KeypadTwo = "Num 2",
            KeypadThree = "Num 3",
            KeypadFour = "Num 4",
            KeypadFive = "Num 5",
            KeypadSix = "Num 6",
            KeypadSeven = "Num 7",
            KeypadEight = "Num 8",
            KeypadNine = "Num 9",

            KeypadPlus = "Num +",
            KeypadMinus = "Num -",
            KeypadMultiply = "Num ×",
            KeypadDivide = "Num ÷",
            KeypadPeriod = "Num .",
            KeypadEnter = "Num Enter",

            LeftShift = "LShift",
            RightShift = "RShift",
            LeftControl = "LCtrl",
            RightControl = "RCtrl",
            LeftAlt = "LAlt",
            RightAlt = "RAlt",
            CapsLock = "Caps",
            BackSlash = "\\",
            Quote = "'",
            Semicolon = ";",
            LeftBracket = "[",
            RightBracket = "]"
        }

        return Display[Name]
            or Keys[Name]
            or Name
            or "None"
    end

    local function InputMatchesKey(Input, Key)
        if not Key then
            return false
        end

        if Key.EnumType == Enum.KeyCode then
            return Input.KeyCode == Key
        end

        if Key.EnumType == Enum.UserInputType then
            return Input.UserInputType == Key
        end

        return false
    end

    local function GetBindableInput(Input)
        if not Input then
            return nil
        end

        local InputType =
            Input.UserInputType

        local InputTypeName =
            tostring(
                InputType
                and InputType.Name
                or ""
            )

        if InputType
            == Enum.UserInputType.Keyboard
        then
            if Input.KeyCode
                and Input.KeyCode
                    ~= Enum.KeyCode.Unknown
            then
                return Input.KeyCode
            end

            return nil
        end

        if string.find(
            InputTypeName,
            "MouseButton",
            1,
            true
        ) == 1
        then
            return InputType
        end

        if InputTypeName == "MouseWheel" then
            return InputType
        end

        if string.find(
            InputTypeName,
            "Gamepad",
            1,
            true
        ) == 1
            and Input.KeyCode
            and Input.KeyCode
                ~= Enum.KeyCode.Unknown
        then
            return Input.KeyCode
        end

        return nil
    end

    Library.CreateKeybind = function(self, Data)
        local Keybind = {
            Key = nil,
            Value = "None",
            Mode = Data.Mode or "Toggle",
            Toggled = false,
            IsOpen = false,
            Picking = false,
            PickStartedAt = 0,
            SuppressUntil = 0,
            PopupToken = 0,
            Class = "Keybind"
        }

        Library.Flags[Data.Flag] = { }

        Library.KeybindMetadata[Data.Flag] = {
            HasExplicitDefault =
                Data.HasExplicitDefault == true
                or rawget(Data, "Default") ~= nil
        }

        local KeyListItem
        local PickConnection
        local Items = { }
        local Modes = { }

        local ControlTween =
            TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

        Items["KeyButton"] =
            Instances:Create(
                "TextButton",
                {
                    Parent = Data.Parent.Instance,
                    FontFace = Library.Font,
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2New(1, 0.5),
                    Size = UDim2New(0, 42, 0, 18),
                    Name = string.char(0),
                    Position = UDim2New(1, 0, 0.5, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 =
                        Library.Theme[
                            "Page Background"
                        ],
                    ZIndex = 20
                }
            )

        Items["KeyButton"]:AddToTheme({
            BackgroundColor3 =
                "Page Background"
        })

        Library:ApplyGlass(
            Items["KeyButton"],
            "Element",
            3
        )

        Items["Text"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["KeyButton"].
                        Instance,

                    FontFace = Library.Font,
                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    Text = "None",
                    Name = string.char(0),
                    BackgroundTransparency = 1,
                    Size = UDim2New(1, -8, 1, 0),
                    Position = UDim2New(0, 4, 0, 0),
                    BorderSizePixel = 0,
                    TextSize = 10,
                    ZIndex = 21
                }
            )

        Items["Text"]:AddToTheme({
            TextColor3 = "Muted Text"
        })

        Items["Window"] =
            Instances:Create(
                "CanvasGroup",
                {
                    Parent =
                        Library.Holder.Instance,

                    AnchorPoint =
                        Vector2New(1, 0),

                    Name = string.char(0),
                    Position =
                        UDim2New(0, 0, 0, 0),

                    Size =
                        UDim2New(0, 92, 0, 72),

                    BorderSizePixel = 0,
                    Visible = false,
                    Active = true,
                    ZIndex = 2000,

                    BackgroundColor3 =
                        Library.Theme.Background,

                    GroupTransparency = 1
                }
            )

        Items["Window"]:AddToTheme({
            BackgroundColor3 = "Background"
        })

        Library:ApplyGlass(
            Items["Window"],
            "Popup",
            4
        )

        local WindowPadding =
            InstanceNew("UIPadding")

        WindowPadding.PaddingTop =
            UDimNew(0, 3)

        WindowPadding.PaddingBottom =
            UDimNew(0, 3)

        WindowPadding.Parent =
            Items["Window"].Instance

        local ModeLayout =
            InstanceNew("UIListLayout")

        ModeLayout.Padding =
            UDimNew(0, 0)

        ModeLayout.SortOrder =
            Enum.SortOrder.LayoutOrder

        ModeLayout.Parent =
            Items["Window"].Instance

        for Index,
            ModeName in ipairs({
                "Toggle",
                "Hold",
                "Always"
            })
        do
            local Row =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["Window"].
                            Instance,

                        FontFace = Library.Font,
                        Text = "",
                        AutoButtonColor = false,
                        Name = string.char(0),
                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1,
                        Size = UDim2New(1, 0, 0, 22),
                        ZIndex = 2001,
                        LayoutOrder = Index
                    }
                )

            Row:AddToTheme({
                BackgroundColor3 = "Element"
            })

            local Marker =
                Instances:Create(
                    "Frame",
                    {
                        Parent = Row.Instance,
                        Name = string.char(0),
                        Position = UDim2New(0, 0, 0, 4),
                        Size = UDim2New(0, 2, 1, -8),
                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Accent,

                        BackgroundTransparency = 1,
                        ZIndex = 2002
                    }
                )

            Marker:AddToTheme({
                BackgroundColor3 = "Accent"
            })

            local Label =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent = Row.Instance,
                        FontFace = Library.Font,

                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],

                        Text = ModeName,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 9, 0, 0),

                        Size =
                            UDim2New(1, -14, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        BorderSizePixel = 0,
                        TextSize = 10,
                        ZIndex = 2002
                    }
                )

            Label:AddToTheme({
                TextColor3 = "Muted Text"
            })

            local ModeData = {
                Button = Row,
                Marker = Marker,
                Label = Label
            }

            Modes[ModeName] = ModeData

            Row:OnHover(function()
                if Keybind.Mode == ModeName then
                    return
                end

                Row:Tween(
                    ControlTween,
                    {
                        BackgroundTransparency =
                            0.48
                    }
                )

                Label:Tween(
                    ControlTween,
                    {
                        TextColor3 =
                            Library.Theme.Text
                    }
                )
            end)

            Row:OnHoverLeave(function()
                if Keybind.Mode == ModeName then
                    return
                end

                Row:Tween(
                    ControlTween,
                    {
                        BackgroundTransparency = 1
                    }
                )

                Label:Tween(
                    ControlTween,
                    {
                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ]
                    }
                )
            end)
        end

        Items["KeyButton"]:OnHover(function()
            if Keybind.Picking then
                return
            end

            Items["KeyButton"]:Tween(
                ControlTween,
                {
                    BackgroundColor3 =
                        Library.Theme[
                            "Hovered Element"
                        ]
                }
            )

            Items["Text"]:Tween(
                ControlTween,
                {
                    TextColor3 =
                        Library.Theme.Text
                }
            )
        end)

        Items["KeyButton"]:OnHoverLeave(function()
            if Keybind.Picking then
                return
            end

            Items["KeyButton"]:Tween(
                ControlTween,
                {
                    BackgroundColor3 =
                        Library.Theme[
                            "Page Background"
                        ]
                }
            )

            Items["Text"]:Tween(
                ControlTween,
                {
                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ]
                }
            )
        end)

        if Library.KeyList then
            KeyListItem =
                Library.KeyList:Add(
                    Keybind.Mode,
                    Data.Name,
                    Keybind.Value
                )
        end

        local function UpdateFlag()
            Library.Flags[Data.Flag] = {
                Mode = Keybind.Mode,

                Key =
                    Keybind.Key
                    and tostring(Keybind.Key)
                    or "None",

                Toggled = Keybind.Toggled
            }
        end

        local function UpdateVisual()
            Items["Text"].Instance.Text =
                Keybind.Value

            for ModeName,
                ModeData in pairs(Modes)
            do
                local Active =
                    ModeName == Keybind.Mode

                ModeData.Marker:Tween(
                    ControlTween,
                    {
                        BackgroundTransparency =
                            Active and 0 or 1
                    }
                )

                ModeData.Button:Tween(
                    ControlTween,
                    {
                        BackgroundTransparency =
                            Active and 0.42 or 1
                    }
                )

                ModeData.Label:
                    ChangeItemTheme({
                        TextColor3 =
                            Active
                            and "Text"
                            or "Muted Text"
                    })

                ModeData.Label:Tween(
                    ControlTween,
                    {
                        TextColor3 =
                            Active
                            and Library.Theme.Text
                            or Library.Theme[
                                "Muted Text"
                            ]
                    }
                )
            end

            if KeyListItem then
                KeyListItem:Set(
                    Keybind.Mode,
                    Data.Name,
                    Keybind.Value
                )

                KeyListItem:SetStatus(
                    Keybind.Toggled
                    and "Active"
                    or "Inactive"
                )
            end
        end

        local function Emit()
            UpdateFlag()
            UpdateVisual()

            if Data.Callback then
                Library:SafeCall(
                    Data.Callback,
                    Keybind.Toggled
                )
            end
        end

        function Keybind:Get()
            return
                Keybind.Toggled,
                Keybind.Key,
                Keybind.Mode
        end

        function Keybind:CancelPicking(RestoreText)
            if not Keybind.Picking then
                return
            end

            Keybind.Picking = false

            if Library.ActiveKeyPicker
                == Keybind
            then
                Library.ActiveKeyPicker = nil
            end

            if PickConnection then
                DisconnectRecord(
                    PickConnection
                )

                PickConnection = nil
            end

            if RestoreText ~= false then
                UpdateVisual()

                Items["Text"]:
                    ChangeItemTheme({
                        TextColor3 =
                            "Muted Text"
                    })

                Items["KeyButton"]:Tween(
                    ControlTween,
                    {
                        BackgroundColor3 =
                            Library.Theme[
                                "Page Background"
                            ]
                    }
                )
            end
        end

        function Keybind:SetVisibility(Bool)
            if not Bool then
                Keybind:SetOpen(false)
            end

            Data.Parent.Instance.Visible =
                Bool == true
        end

        function Keybind:SetOpen(Bool)
            Bool = Bool == true

            if Bool
                and Library.CurrentKeybind
                and Library.CurrentKeybind
                    ~= Keybind
            then
                Library.CurrentKeybind:
                    SetOpen(false)
            end

            Keybind.PopupToken += 1

            local Token =
                Keybind.PopupToken

            local Window =
                Items["Window"].Instance

            if Bool then
                local Button =
                    Items["KeyButton"].
                    Instance

                local ButtonPosition =
                    Button.AbsolutePosition

                local ButtonSize =
                    Button.AbsoluteSize

                local WindowSize =
                    Vector2New(92, 72)

                local ViewportSize =
                    Workspace.CurrentCamera
                    and Workspace.CurrentCamera.
                        ViewportSize
                    or Vector2New(1920, 1080)

                local X =
                    MathClamp(
                        ButtonPosition.X
                        + ButtonSize.X,
                        WindowSize.X + 4,
                        ViewportSize.X - 4
                    )

                local Below =
                    ButtonPosition.Y
                    + ButtonSize.Y
                    + 4

                local Above =
                    ButtonPosition.Y
                    - WindowSize.Y
                    - 4

                local Y =
                    Below + WindowSize.Y
                        <= ViewportSize.Y - 4
                    and Below
                    or math.max(Above, 4)

                Window.Position =
                    UDim2New(
                        0,
                        X,
                        0,
                        Y + 3
                    )

                Window.GroupTransparency = 1
                Window.Visible = true
                Window.Active = true

                Items["Window"]:Tween(
                    ControlTween,
                    {
                        Position =
                            UDim2New(
                                0,
                                X,
                                0,
                                Y
                            ),

                        GroupTransparency = 0
                    }
                )

                Library.CurrentKeybind =
                    Keybind
            else
                Items["Window"]:Tween(
                    ControlTween,
                    {
                        GroupTransparency = 1
                    }
                )

                task.delay(
                    0.12,
                    function()
                        if Token
                                == Keybind.PopupToken
                            and not Keybind.IsOpen
                            and Window
                            and Window.Parent
                        then
                            Window.Visible = false
                            Window.Active = false
                        end
                    end
                )

                if Library.CurrentKeybind
                    == Keybind
                then
                    Library.CurrentKeybind = nil
                end
            end

            Keybind.IsOpen = Bool
        end

        function Keybind:SetMode(Mode, Silent)
            if not Modes[Mode] then
                Mode = "Toggle"
            end

            Keybind.Mode = Mode

            if Mode == "Always" then
                Keybind.Toggled = true
            elseif Mode == "Hold" then
                Keybind.Toggled = false
            end

            UpdateFlag()
            UpdateVisual()

            if not Silent
                and Data.Callback
            then
                Library:SafeCall(
                    Data.Callback,
                    Keybind.Toggled
                )
            end
        end

        function Keybind:Set(Value, Silent)
            local NewKey = Value
            local NewMode = Keybind.Mode
            local NewState = nil

            if type(Value) == "table" then
                NewKey =
                    Value.Key
                    or Value.Value

                NewMode =
                    Value.Mode
                    or NewMode

                if Value.Toggled ~= nil then
                    NewState =
                        Value.Toggled == true
                elseif Value.State ~= nil then
                    NewState =
                        Value.State == true
                end
            end

            local Resolved =
                ResolveKey(NewKey)

            if Resolved
                == Enum.KeyCode.Backspace
            then
                Resolved = nil
            end

            Keybind.Key = Resolved
            Keybind.Value =
                FormatKey(Resolved)

            Keybind.Picking = false

            Keybind.SuppressUntil =
                os.clock() + 0.18

            if Library.ActiveKeyPicker
                == Keybind
            then
                Library.ActiveKeyPicker = nil
            end

            Items["Text"]:
                ChangeItemTheme({
                    TextColor3 =
                        "Muted Text"
                })

            Keybind:SetMode(
                NewMode,
                true
            )

            if Keybind.Mode == "Toggle"
                and NewState ~= nil
            then
                Keybind.Toggled =
                    NewState
            elseif Keybind.Mode == "Always" then
                Keybind.Toggled = true
            elseif Keybind.Mode == "Hold" then
                Keybind.Toggled = false
            end

            UpdateFlag()
            UpdateVisual()

            if not Silent
                and Data.KeyChanged
            then
                Library:SafeCall(
                    Data.KeyChanged,
                    Keybind.Key
                )
            end
        end

        function Keybind:SetState(State, Silent)
            local NewState =
                State == true

            local Changed =
                Keybind.Toggled
                ~= NewState

            Keybind.Toggled =
                NewState

            UpdateFlag()
            UpdateVisual()

            if Changed
                and not Silent
                and Data.Callback
            then
                Library:SafeCall(
                    Data.Callback,
                    Keybind.Toggled
                )
            end
        end

        function Keybind:Press(State)
            local Previous =
                Keybind.Toggled

            if Keybind.Mode == "Toggle" then
                Keybind.Toggled =
                    not Keybind.Toggled
            elseif Keybind.Mode == "Hold" then
                Keybind.Toggled =
                    State == true
            elseif Keybind.Mode == "Always" then
                Keybind.Toggled = true
            end

            if Previous ~= Keybind.Toggled
                or Keybind.Mode == "Always"
            then
                Emit()
            end
        end

        Items["KeyButton"]:
            Connect(
                "MouseButton1Click",
                function()
                    if Keybind.Picking then
                        Keybind:
                            CancelPicking(true)

                        return
                    end

                    if Library.ActiveKeyPicker
                        and Library.ActiveKeyPicker
                            ~= Keybind
                    then
                        Library.ActiveKeyPicker:
                            CancelPicking(true)
                    end

                    Library.ActiveKeyPicker =
                        Keybind

                    Keybind.Picking = true
                    Keybind.PickStartedAt =
                        os.clock()

                    Items["Text"].Instance.Text =
                        "press"

                    Items["Text"]:
                        ChangeItemTheme({
                            TextColor3 = "Accent"
                        })

                    Items["KeyButton"]:Tween(
                        ControlTween,
                        {
                            BackgroundColor3 =
                                Library.Theme[
                                    "Hovered Element"
                                ]
                        }
                    )

                    if PickConnection then
                        DisconnectRecord(
                            PickConnection
                        )
                    end

                    PickConnection =
                        Library:Connect(
                            UserInputService.
                                InputBegan,

                            function(Input)
                                if not Keybind.Picking
                                    or Library.
                                        ActiveKeyPicker
                                        ~= Keybind
                                then
                                    return
                                end

                                if os.clock()
                                        - Keybind.
                                            PickStartedAt
                                    < 0.10
                                then
                                    return
                                end

                                if Data.Window
                                    and Data.Window.
                                        IsOpen == false
                                then
                                    Keybind:
                                        CancelPicking(true)

                                    return
                                end

                                if Input.KeyCode
                                        == Enum.KeyCode.
                                            Escape
                                    or Input.KeyCode
                                        == Library.
                                            MenuKeybind
                                then
                                    Keybind:
                                        CancelPicking(true)

                                    return
                                end

                                if Input.KeyCode
                                    == Enum.KeyCode.
                                        Backspace
                                then
                                    Keybind:Set(
                                        nil,
                                        true
                                    )
                                else
                                    local NewKey =
                                        GetBindableInput(
                                            Input
                                        )

                                    if not NewKey then
                                        return
                                    end

                                    Library.
                                        SuppressKeybindInput =
                                        Input

                                    Keybind:Set(
                                        NewKey,
                                        true
                                    )
                                end

                                if Data.KeyChanged then
                                    Library:SafeCall(
                                        Data.KeyChanged,
                                        Keybind.Key
                                    )
                                end

                                if PickConnection then
                                    DisconnectRecord(
                                        PickConnection
                                    )

                                    PickConnection = nil
                                end
                            end,

                            "Keybind_Picker_"
                                .. Data.Flag
                        )
                end
            )

        Items["KeyButton"]:
            Connect(
                "MouseButton2Click",
                function()
                    if not Keybind.Picking then
                        Keybind:SetOpen(
                            not Keybind.IsOpen
                        )
                    end
                end
            )

        Library:Connect(
            UserInputService.InputBegan,
            function(Input, GameProcessed)
                if Keybind.Picking
                    or Library.ActiveKeyPicker
                then
                    return
                end

                if Library.SuppressKeybindInput
                        == Input
                    or os.clock()
                        < Keybind.SuppressUntil
                then
                    return
                end

                if Input.UserInputType
                    == Enum.UserInputType.
                        MouseButton1
                    and Keybind.IsOpen
                    and not Library:
                        IsMouseOverFrame(
                            Items["Window"]
                        )
                then
                    Keybind:SetOpen(false)
                end

                if GameProcessed
                    and UserInputService:
                        GetFocusedTextBox()
                then
                    return
                end

                if Input.UserInputType
                        == Enum.UserInputType.
                            MouseButton2
                    and Library:
                        IsMouseOverFrame(
                            Items["KeyButton"]
                        )
                then
                    return
                end

                if InputMatchesKey(
                    Input,
                    Keybind.Key
                )
                then
                    if Keybind.Mode == "Toggle" then
                        Keybind:Press()
                    elseif Keybind.Mode == "Hold" then
                        Keybind:Press(true)
                    end
                end
            end
        )

        Library:Connect(
            UserInputService.InputEnded,
            function(Input)
                if Library.SuppressKeybindInput
                    == Input
                then
                    Library.SuppressKeybindInput = nil
                end

                if Keybind.Mode == "Hold"
                    and InputMatchesKey(
                        Input,
                        Keybind.Key
                    )
                then
                    Keybind:Press(false)
                end
            end
        )

        for ModeName,
            ModeData in pairs(Modes)
        do
            ModeData.Button:
                Connect(
                    "MouseButton1Down",
                    function()
                        Keybind:SetMode(
                            ModeName
                        )

                        Keybind:SetOpen(false)
                    end
                )
        end

        Keybind:Set(
            {
                Key = Data.Default,
                Mode = Data.Mode or "Toggle"
            },
            true
        )

        Library.SetFlags[Data.Flag] =
            function(Value)
                Keybind:Set(
                    Value,
                    true
                )
            end

        Keybind.Button =
            Items["KeyButton"].Instance

        Keybind.Items = Items

        Library:RegisterInlineAddon(
            Data.Parent,
            Keybind.Button,
            "Keybind"
        )

        return Keybind
    end

    Library.ESPPreview = function(self, Data)
        Data = Data or {}

        local Preview = {
            Visible = Data.Visible ~= false,
            Enabled = true,
            Character = nil,
            LoadingCharacter = nil,
            CharacterClone = nil,
            CharacterToken = 0,
            PartState = {},
            Settings = {},
            Destroyed = false,
            LoadingStartedAt = 0,
            RetryAt = 0,
            RetryAttempts = 0,
            RetryAccumulator = 0,
            Extra = {},
            Scale = math.clamp(
                tonumber(Data.Scale) or 1,
                0.55,
                1.75
            )
        }

        local Items = {}
        local Parent =
            Library:ResolveInstance(
                Data.Parent
            )
            or Library.Holder.Instance

        Items.Frame = Instances:Create("Frame", {
            Parent = Parent,
            Name = string.char(0),
            Size = Data.Size or UDim2New(0, 300, 0, 440),
            Position = Data.Position or UDim2New(1, -320, 0.5, -220),
            BorderSizePixel = 0,
            BorderColor3 = Library.Theme.Border,
            BackgroundColor3 = Library.Theme.Background,
            Visible = Preview.Visible,
            ClipsDescendants = false
        })
        Items.Frame:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
        Library:ApplyGlass(Items.Frame, "Window", 12)
        Library:AddGlassShadow(Items.Frame, 15, 3)
        Items.Frame.Instance.BackgroundTransparency = 0
        Items.Scale = Instances:Create("UIScale", {
            Parent = Items.Frame.Instance,
            Scale = Preview.Scale
        })

        Items.Frame:MakeDraggable()

        Items.Accent = Instances:Create("Frame", {
            Parent = Items.Frame.Instance,
            Position = UDim2New(0, 10, 0, 0),
            Size = UDim2New(1, -20, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Accent
        })
        Items.Accent:AddToTheme({BackgroundColor3 = "Accent"})

        Items.Title = Instances:Create("TextLabel", {
            Parent = Items.Frame.Instance,
            Position = UDim2New(0, 10, 0, 7),
            Size = UDim2New(1, -80, 0, 17),
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = Data.Title or "ESP Preview",
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Library.Theme.Text
        })
        Items.Title:AddToTheme({TextColor3 = "Text"})

        Items.Status = Instances:Create("TextLabel", {
            Parent = Items.Frame.Instance,
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(1, -10, 0, 7),
            Size = UDim2New(0, 60, 0, 17),
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = "ENABLED",
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextColor3 = Library.Theme.Accent
        })
        Items.Status:AddToTheme({TextColor3 = "Accent"})

        Items.Canvas = Instances:Create("Frame", {
            Parent = Items.Frame.Instance,
            Position = UDim2New(0, 10, 0, 31),
            Size = UDim2New(1, -20, 1, -43),
            BorderSizePixel = 0,
            BorderColor3 = Library.Theme.Outline,
            BackgroundColor3 = Library.Theme["Page Background"],
            ClipsDescendants = true
        })
        Items.Canvas:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Outline"})
        Library:ApplyGlass(Items.Canvas, "Panel", 8)
        Items.Canvas.Instance.BackgroundTransparency = 0.012

        Items.Viewport = Instances:Create("ViewportFrame", {
            Parent = Items.Canvas.Instance,
            Position = UDim2New(0, 1, 0, 1),
            Size = UDim2New(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Ambient = FromRGB(185, 185, 195),
            LightColor = FromRGB(255, 255, 255),
            LightDirection = Vector3.new(-0.75, -1, -0.5),
            ZIndex = 1
        })

        Items.World = Instances:Create("WorldModel", {Parent = Items.Viewport.Instance})
        Items.Camera = Instances:Create("Camera", {
            Parent = Items.Viewport.Instance,
            FieldOfView = 28
        })
        Items.Viewport.Instance.CurrentCamera = Items.Camera.Instance

        Items.ModelShade = Instances:Create("Frame", {
            Parent = Items.Canvas.Instance,
            AnchorPoint = Vector2New(0.5, 1),
            Position = UDim2New(0.5, 0, 0.94, 0),
            Size = UDim2New(0, 150, 0, 16),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(0, 0, 0),
            BackgroundTransparency = 0.72,
            ZIndex = 2
        })
        InstanceNew("UICorner", Items.ModelShade.Instance).CornerRadius = UDimNew(1, 0)

        Items.BoxRoot = Instances:Create("Frame", {
            Parent = Items.Canvas.Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0.5, 0, 0.52, 0),
            Size = UDim2New(0, 142, 0, 300),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 5
        })

        Items.Fill = Instances:Create("Frame", {
            Parent = Items.BoxRoot.Instance,
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(28, 82, 61),
            BackgroundTransparency = 0.82,
            ZIndex = 3
        })

        Items.FullOutline = Instances:Create("Frame", {
            Parent = Items.BoxRoot.Instance,
            Position = UDim2New(0, -1, 0, -1),
            Size = UDim2New(1, 2, 1, 2),
            BackgroundTransparency = 1,
            BorderSizePixel = 2,
            BorderColor3 = FromRGB(4, 7, 6),
            ZIndex = 4
        })

        Items.FullBox = Instances:Create("Frame", {
            Parent = Items.BoxRoot.Instance,
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 1,
            BorderColor3 = Library.Theme.Accent,
            ZIndex = 5
        })
        Items.FullBox:AddToTheme({BorderColor3 = "Accent"})

        Items.Corners = {}
        local CornerData = {
            {UDim2New(0, 0, 0, 0), UDim2New(0.28, 0, 0, 2)},
            {UDim2New(0, 0, 0, 0), UDim2New(0, 2, 0.18, 0)},
            {UDim2New(0.72, 0, 0, 0), UDim2New(0.28, 0, 0, 2)},
            {UDim2New(1, -2, 0, 0), UDim2New(0, 2, 0.18, 0)},
            {UDim2New(0, 0, 1, -2), UDim2New(0.28, 0, 0, 2)},
            {UDim2New(0, 0, 0.82, 0), UDim2New(0, 2, 0.18, 0)},
            {UDim2New(0.72, 0, 1, -2), UDim2New(0.28, 0, 0, 2)},
            {UDim2New(1, -2, 0.82, 0), UDim2New(0, 2, 0.18, 0)}
        }

        for Index, Geometry in ipairs(CornerData) do
            local Segment = Instances:Create("Frame", {
                Parent = Items.BoxRoot.Instance,
                Position = Geometry[1],
                Size = Geometry[2],
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Accent,
                ZIndex = 6
            })
            Segment:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIStroke", {
                Parent = Segment.Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Thickness = 1,
                Color = FromRGB(4, 7, 6)
            })

            Items.Corners[Index] = Segment
        end

        Items.Name = Instances:Create("TextLabel", {
            Parent = Items.Canvas.Instance,
            AnchorPoint = Vector2New(0.5, 1),
            Position = UDim2New(0.5, 0, 0.52, -156),
            Size = UDim2New(0, 210, 0, 18),
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = Data.Name or "Local Player",
            TextSize = 13,
            TextColor3 = Library.Theme.Text,
            ZIndex = 8
        })
        Items.Name:AddToTheme({TextColor3 = "Text"})

        Items.Info = Instances:Create("TextLabel", {
            Parent = Items.Canvas.Instance,
            AnchorPoint = Vector2New(0.5, 0),
            Position = UDim2New(0.5, 0, 0.52, 156),
            Size = UDim2New(0, 220, 0, 18),
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = "[24m]  |  Unarmed",
            TextSize = 12,
            TextColor3 = Library.Theme.Text,
            ZIndex = 8
        })
        Items.Info:AddToTheme({TextColor3 = "Text"})

        Items.Filter = Instances:Create("TextLabel", {
            Parent = Items.Canvas.Instance,
            Position = UDim2New(0, 7, 0, 7),
            Size = UDim2New(1, -14, 0, 16),
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = "MAX 1200 STUDS",
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextColor3 = FromRGB(145, 145, 155),
            ZIndex = 8
        })

        Items.HealthBack = Instances:Create("Frame", {
            Parent = Items.BoxRoot.Instance,
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(0, -6, 0, 0),
            Size = UDim2New(0, 4, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(12, 12, 14),
            ZIndex = 7
        })

        Items.Health = Instances:Create("Frame", {
            Parent = Items.HealthBack.Instance,
            AnchorPoint = Vector2New(0, 1),
            Position = UDim2New(0, 0, 1, 0),
            Size = UDim2New(1, 0, 0.74, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(80, 220, 110),
            ZIndex = 8
        })

        Items.HealthText = Instances:Create("TextLabel", {
            Parent = Items.BoxRoot.Instance,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(0, -12, 0.26, 0),
            Size = UDim2New(0, 40, 0, 14),
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = "74",
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextColor3 = FromRGB(80, 220, 110),
            ZIndex = 8
        })

        Items.Highlight = InstanceNew("Highlight")
        Items.Highlight.Name = string.char(0)
        Items.Highlight.Enabled = false
        Items.Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Items.Highlight.Parent = Items.World.Instance

        Items.SnaplineSegments = {}
        for Index = 1, 16 do
            Items.SnaplineSegments[Index] = Instances:Create("Frame", {
                Parent = Items.Canvas.Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(0, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Accent,
                Visible = false,
                ZIndex = 7
            })
            Items.SnaplineSegments[Index]:AddToTheme({BackgroundColor3 = "Accent"})
        end

        local function SetLineSegment(Segment, PointA, PointB, Thickness, Color, Transparency)
            local Delta = PointB - PointA
            local Length = Delta.Magnitude

            Segment.Instance.Position = UDim2New(0, (PointA.X + PointB.X) * 0.5, 0, (PointA.Y + PointB.Y) * 0.5)
            Segment.Instance.Size = UDim2New(0, Length, 0, Thickness)
            Segment.Instance.Rotation = math.deg(math.atan2(Delta.Y, Delta.X))
            Segment.Instance.BackgroundColor3 = Color
            Segment.Instance.BackgroundTransparency = Transparency
            Segment.Instance.Visible = Preview.Enabled and Length > 0.5
        end

        local function UpdateSnapline()
            for _, Segment in ipairs(Items.SnaplineSegments) do
                Segment.Instance.Visible = false
            end

            local Settings = Preview.Settings
            if not Preview.Enabled or not Settings.Tracers then return end

            local Size = Items.Canvas.Instance.AbsoluteSize
            if Size.X <= 1 or Size.Y <= 1 then
                task.defer(UpdateSnapline)
                return
            end

            local OriginY = Settings.TracerOrigin == "Top" and 0 or Settings.TracerOrigin == "Center" and Size.Y * 0.5 or Size.Y
            local TargetY = Settings.TracerEnd == "Head" and Size.Y * 0.18 or Settings.TracerEnd == "Body" and Size.Y * 0.52 or Size.Y * 0.86
            local Start = Vector2New(Size.X * 0.5, OriginY)
            local Finish = Vector2New(Size.X * 0.5, TargetY)
            local Thickness = tonumber(Settings.TracerThickness) or 1
            local Color = Settings.TracerColor or Library.Theme.Accent
            local Transparency = MathClamp(tonumber(Settings.TracerTransparency) or 0, 0, 1)

            if Settings.TracerStyle ~= "Curved" then
                SetLineSegment(Items.SnaplineSegments[1], Start, Finish, Thickness, Color, Transparency)
                return
            end

            local Control = Vector2New(Start.X + math.min(55, Size.X * 0.23), (Start.Y + Finish.Y) * 0.5)
            local Previous = Start

            for Index = 1, 16 do
                local T = Index / 16
                local Inverse = 1 - T
                local Current = Start * (Inverse * Inverse) + Control * (2 * Inverse * T) + Finish * (T * T)
                SetLineSegment(Items.SnaplineSegments[Index], Previous, Current, Thickness, Color, Transparency)
                Previous = Current
            end
        end

        local function ClearCharacter()
            Preview.CharacterToken = Preview.CharacterToken + 1

            if Preview.CharacterClone then
                Preview.CharacterClone:Destroy()
                Preview.CharacterClone = nil
            end

            Preview.Character = nil
            Preview.LoadingCharacter = nil
            Preview.PartState = {}
            Items.Highlight.Adornee = nil
        end

        local function FitCharacterCamera()
            local Clone = Preview.CharacterClone
            if not Clone or not Clone.Parent then return end

            Clone:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
            local BoundsCFrame, BoundsSize = Clone:GetBoundingBox()
            local Focus = BoundsCFrame.Position + Vector3.new(0, BoundsSize.Y * 0.025, 0)
            local ViewportSize = Items.Viewport.Instance.AbsoluteSize
            local Aspect = ViewportSize.Y > 1 and ViewportSize.X / ViewportSize.Y or 0.68
            local VerticalFov = math.rad(Items.Camera.Instance.FieldOfView)
            local HorizontalFov = 2 * math.atan(math.tan(VerticalFov * 0.5) * math.max(Aspect, 0.25))
            local HeightDistance = BoundsSize.Y * 0.5 / math.max(math.tan(VerticalFov * 0.5), 0.01)
            local WidthDistance = BoundsSize.X * 0.5 / math.max(math.tan(HorizontalFov * 0.5), 0.01)
            local Distance = math.max(HeightDistance, WidthDistance, BoundsSize.Z * 2, 6.5) * 1.10

            Items.Camera.Instance.CFrame = CFrame.new(Focus + Vector3.new(0, 0, Distance), Focus)
        end

        local function ApplyCharacterStyle()
            local Settings = Preview.Settings
            local Chams = Settings.Chams or {}
            local Enabled = Preview.Enabled and Chams.Enabled == true

            Items.Highlight.Enabled = Enabled
            Items.Highlight.Adornee = Enabled and Preview.CharacterClone or nil
            Items.Highlight.FillColor = Chams.FillColor or Library.Theme.Accent
            Items.Highlight.OutlineColor = Chams.OutlineColor or Library.Theme.Text
            Items.Highlight.FillTransparency = MathClamp(tonumber(Chams.FillTransparency) or 0.58, 0, 1)
            Items.Highlight.OutlineTransparency = MathClamp(tonumber(Chams.OutlineTransparency) or 0.12, 0, 1)
            Items.Highlight.DepthMode = Chams.ThroughWalls == false and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop

            for Part, Original in pairs(Preview.PartState) do
                if Part and Part.Parent then
                    if Enabled and Chams.GlowEnabled then
                        Part.Color = Chams.GlowColor or Chams.FillColor or Library.Theme.Accent
                        Part.Material = Enum.Material.Neon
                        Part.Transparency = MathClamp(tonumber(Chams.GlowTransparency) or 0.34, 0, 0.85)
                    else
                        Part.Color = Original.Color
                        Part.Material = Original.Material
                        Part.Transparency = Original.Transparency
                    end
                end
            end
        end

        local function CreateDescriptionModel(Character)
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if not Humanoid then return nil end

            local DescriptionSuccess, Description = pcall(Humanoid.GetAppliedDescription, Humanoid)
            if not DescriptionSuccess or not Description then return nil end

            local RigType = Humanoid.RigType
            local Success, Model = pcall(function()
                return Players:CreateHumanoidModelFromDescriptionAsync(Description, RigType)
            end)

            if not Success or not Model then
                Success, Model = pcall(function()
                    return Players:CreateHumanoidModelFromDescription(Description, RigType)
                end)
            end

            return Success and Model or nil
        end

        local function CreateFallbackModel(Character)
            local PreviousArchivable = Character.Archivable
            Character.Archivable = true
            local Success, Clone = pcall(Character.Clone, Character)
            Character.Archivable = PreviousArchivable
            return Success and Clone or nil
        end

        local function PrepareCharacterModel(Clone)
            local RootPart = Clone:FindFirstChild("HumanoidRootPart")

            for _, Descendant in ipairs(Clone:GetDescendants()) do
                if Descendant:IsA("LocalScript") or Descendant:IsA("Script") or Descendant:IsA("ModuleScript") or Descendant:IsA("Animator") or Descendant:IsA("AnimationController") then
                    Descendant:Destroy()
                elseif Descendant:IsA("Motor6D") then
                    Descendant.Transform = CFrame.new()
                elseif Descendant:IsA("BasePart") then
                    Descendant.Anchored = Descendant == RootPart
                    Descendant.CanCollide = false
                    Descendant.CanTouch = false
                    Descendant.CanQuery = false
                    Descendant.CastShadow = true
                    Descendant.Massless = Descendant ~= RootPart

                    if Descendant.Name == "HumanoidRootPart" then
                        Descendant.Transparency = 1
                    else
                        Preview.PartState[Descendant] = {
                            Color = Descendant.Color,
                            Material = Descendant.Material,
                            Transparency = Descendant.Transparency
                        }
                    end
                elseif Descendant:IsA("Humanoid") then
                    Descendant.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                    Descendant.BreakJointsOnDeath = false
                    Descendant.AutoRotate = false
                    Descendant.PlatformStand = false
                end
            end

            if RootPart then Clone.PrimaryPart = RootPart end
            Clone.Name = "PreviewCharacter"
            return Clone
        end

        function Preview:SetCharacter(Character, Force)
            if Preview.Destroyed then
                return false
            end

            if Character == Preview.Character
                and Preview.CharacterClone
                and Preview.CharacterClone.Parent
            then
                return true
            end

            local Now = os.clock()

            if not Character
                or not Character.Parent
            then
                Preview.RetryAt =
                    math.max(
                        Preview.RetryAt,
                        Now + 0.25
                    )

                return false
            end

            local Humanoid =
                Character:
                    FindFirstChildOfClass(
                        "Humanoid"
                    )

            local Root =
                Character:
                    FindFirstChild(
                        "HumanoidRootPart"
                    )

            local Head =
                Character:
                    FindFirstChild(
                        "Head"
                    )

            if not Humanoid
                or not Root
                or not Head
            then
                Preview.RetryAt =
                    math.max(
                        Preview.RetryAt,
                        Now + 0.25
                    )

                return false
            end

            if Preview.LoadingCharacter
                    == Character
                and not Force
                and Now
                    - Preview.LoadingStartedAt
                    < 2.5
            then
                return false
            end

            if not Force
                and Now < Preview.RetryAt
            then
                return false
            end

            ClearCharacter()

            local Token =
                Preview.CharacterToken

            Preview.LoadingCharacter =
                Character

            Preview.LoadingStartedAt =
                Now

            Preview.RetryAt =
                Now + 0.35

            Preview.RetryAttempts =
                Preview.RetryAttempts + 1

            Items.Status.Instance.Text =
                "LOADING"

            Library:Thread(function()
                local Clone =
                    CreateDescriptionModel(
                        Character
                    )
                    or CreateFallbackModel(
                        Character
                    )

                if Token
                        ~= Preview.CharacterToken
                    or Preview.Destroyed
                    or not Items.Frame.Instance.Parent
                then
                    if Clone then
                        Clone:Destroy()
                    end

                    return
                end

                Preview.LoadingCharacter =
                    nil

                if not Clone then
                    Preview.RetryAt =
                        os.clock()
                        + math.min(
                            1.25,
                            0.25
                            + Preview.RetryAttempts
                            * 0.12
                        )

                    Items.Status.Instance.Text =
                        "WAITING"

                    return
                end

                PrepareCharacterModel(Clone)
                Clone.Parent =
                    Items.World.Instance

                Preview.Character =
                    Character

                Preview.CharacterClone =
                    Clone

                Preview.RetryAttempts = 0
                Preview.RetryAt = 0

                FitCharacterCamera()
                ApplyCharacterStyle()

                Preview:Apply(
                    Preview.Settings,
                    Preview.Extra
                )

                task.defer(function()
                    if Token
                            == Preview.CharacterToken
                        and Preview.CharacterClone
                            == Clone
                        and Clone.Parent
                    then
                        FitCharacterCamera()
                        ApplyCharacterStyle()
                    end
                end)
            end)

            return false
        end

        function Preview:EnsureCharacter(Character)
            if Preview.CharacterClone
                and Preview.CharacterClone.Parent
                and Preview.Character == Character
            then
                return true
            end

            return Preview:SetCharacter(
                Character,
                false
            )
        end

        function Preview:Apply(Settings, Extra)
            Preview.Settings = Settings or Preview.Settings or {}
            Preview.Extra = Extra or Preview.Extra or {}

            local Current = Preview.Settings
            local Meta = Preview.Extra
            local Health = MathClamp(tonumber(Meta.Health) or 74, 0, math.max(tonumber(Meta.MaxHealth) or 100, 1))
            local MaxHealth = math.max(tonumber(Meta.MaxHealth) or 100, 1)
            local HealthPercent = Health / MaxHealth
            local BoxVisible = Preview.Enabled and Current.Boxes == true
            local FullStyle = Current.BoxStyle == "Full"
            local TextColor = Current.TextColor or Library.Theme.Text
            local BoxColor = Current.BoxColor or Library.Theme.Accent
            local OutlineColor = Current.OutlineColor or FromRGB(4, 7, 6)
            local HealthColor = (Current.HealthLowColor or FromRGB(235, 72, 72)):Lerp(Current.HealthHighColor or FromRGB(73, 232, 155), HealthPercent)

            Items.Status.Instance.Text = Preview.Enabled and "ENABLED" or "DISABLED"
            Items.Status.Instance.TextColor3 = Preview.Enabled and Library.Theme.Accent or FromRGB(145, 145, 155)

            Items.Fill.Instance.Visible = BoxVisible and Current.Fill == true
            Items.Fill.Instance.BackgroundColor3 = Current.FillColor or FromRGB(28, 82, 61)
            Items.Fill.Instance.BackgroundTransparency = MathClamp(tonumber(Current.FillTransparency) or 0.82, 0, 1)

            Items.FullOutline.Instance.Visible = BoxVisible and FullStyle
            Items.FullOutline.Instance.BorderColor3 = OutlineColor
            Items.FullBox.Instance.Visible = BoxVisible and FullStyle
            Items.FullBox.Instance.BorderColor3 = BoxColor

            for _, Segment in ipairs(Items.Corners) do
                Segment.Instance.Visible = BoxVisible and not FullStyle
                Segment.Instance.BackgroundColor3 = BoxColor

                local Stroke = Segment.Instance:FindFirstChildOfClass("UIStroke")
                if Stroke then Stroke.Color = OutlineColor end
            end

            Items.Name.Instance.Visible = Preview.Enabled and Current.Names == true
            Items.Name.Instance.Text = tostring(Meta.Name or "Local Player")
            Items.Name.Instance.TextColor3 = TextColor
            Items.Name.Instance.TextSize = tonumber(Current.TextSize) or 13

            local Info = {}
            if Current.Distance then table.insert(Info, tostring(Meta.Distance or "[24m]")) end
            if Current.Weapon then table.insert(Info, tostring(Meta.Weapon or "Unarmed")) end
            Items.Info.Instance.Visible = Preview.Enabled and #Info > 0
            Items.Info.Instance.Text = table.concat(Info, "  |  ")
            Items.Info.Instance.TextColor3 = TextColor
            Items.Info.Instance.TextSize = math.max((tonumber(Current.TextSize) or 13) - 1, 10)

            Items.HealthBack.Instance.Visible = Preview.Enabled and Current.HealthBar == true
            Items.Health.Instance.Size = UDim2New(1, 0, HealthPercent, 0)
            Items.Health.Instance.BackgroundColor3 = HealthColor

            Items.HealthText.Instance.Visible = Preview.Enabled and Current.HealthText == true
            Items.HealthText.Instance.Text = tostring(MathFloor(Health + 0.5))
            Items.HealthText.Instance.TextColor3 = HealthColor
            Items.HealthText.Instance.Position = UDim2New(0, -12, 1 - HealthPercent, 0)

            local FilterText = Current.TeamCheck and "TEAM CHECK  •  " or ""
            Items.Filter.Instance.Text = FilterText .. "MAX " .. tostring(MathFloor(tonumber(Current.MaxDistance) or 1200)) .. " STUDS"

            ApplyCharacterStyle()
            UpdateSnapline()
        end

        function Preview:SetScale(Value)
            Value = math.clamp(
                tonumber(Value) or 1,
                0.55,
                1.75
            )

            Preview.Scale = Value
            Items.Scale.Instance.Scale = Value
        end

        function Preview:GetScale()
            return Preview.Scale
        end

        function Preview:SetVisibility(Value)
            Preview.Visible = Value == true
            Items.Frame.Instance.Visible = Preview.Visible
        end

        function Preview:SetEnabled(Value)
            Preview.Enabled = Value == true
            Preview:Apply(Preview.Settings, Preview.Extra)
        end

        function Preview:SetColor(Color)
            Preview.Settings.BoxColor = Color
            Preview:Apply(Preview.Settings, Preview.Extra)
        end

        function Preview:SetHealth(Value, MaxValue)
            Preview.Extra.Health = tonumber(Value) or 0
            Preview.Extra.MaxHealth = tonumber(MaxValue) or Preview.Extra.MaxHealth or 100
            Preview:Apply(Preview.Settings, Preview.Extra)
        end

        function Preview:SetName(Value)
            Preview.Extra.Name = tostring(Value or "Local Player")
            Preview:Apply(Preview.Settings, Preview.Extra)
        end

        function Preview:SetDistance(Value)
            Preview.Extra.Distance = tostring(Value or "[0m]")
            Preview:Apply(Preview.Settings, Preview.Extra)
        end

        function Preview:SetSnapline(Value)
            Preview.Settings.Tracers = Value == true
            Preview:Apply(Preview.Settings, Preview.Extra)
        end

        function Preview:Refresh()
            local Character = Preview.Character or Preview.LoadingCharacter
            Preview.Character = nil
            Preview.LoadingCharacter = nil
            Preview:SetCharacter(Character)
            Preview:Apply(Preview.Settings, Preview.Extra)
        end

        function Preview:Destroy()
            Preview.Destroyed = true

            local Connections = {
                "ViewportSizeConnection",
                "CharacterAddedConnection",
                "CharacterRemovingConnection",
                "AppearanceConnection",
                "RetryConnection"
            }

            for _, Key in ipairs(Connections) do
                local Connection = Preview[Key]

                if Connection then
                    Connection:Disconnect()
                    Preview[Key] = nil
                end
            end

            ClearCharacter()

            if Items.Frame
                and Items.Frame.Instance
            then
                Items.Frame.Instance:Destroy()
            end
        end

        Preview.Frame = Items.Frame.Instance
        Preview.Items = Items

        Preview.CharacterAddedConnection =
            LocalPlayer.CharacterAdded:
                Connect(function(Character)
                    Preview.RetryAt = 0
                    Preview:SetCharacter(
                        Character,
                        true
                    )
                end)

        Preview.CharacterRemovingConnection =
            LocalPlayer.CharacterRemoving:
                Connect(function()
                    ClearCharacter()
                    Preview.RetryAt =
                        os.clock() + 0.15
                end)

        if LocalPlayer.CharacterAppearanceLoaded then
            Preview.AppearanceConnection =
                LocalPlayer.CharacterAppearanceLoaded:
                    Connect(function(Character)
                        Preview.RetryAt = 0
                        Preview:SetCharacter(
                            Character,
                            true
                        )
                    end)
        end

        Preview.RetryConnection =
            RunService.Heartbeat:
                Connect(function(DeltaTime)
                    if Preview.Destroyed
                        or not Preview.Visible
                    then
                        return
                    end

                    Preview.RetryAccumulator =
                        Preview.RetryAccumulator
                        + DeltaTime

                    if Preview.RetryAccumulator
                        < 0.25
                    then
                        return
                    end

                    Preview.RetryAccumulator = 0

                    if not Preview.CharacterClone
                        or not Preview.CharacterClone.Parent
                    then
                        Preview:EnsureCharacter(
                            LocalPlayer.Character
                        )
                    end
                end)

        Preview.ViewportSizeConnection = Items.Viewport.Instance:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            task.defer(FitCharacterCamera)
        end)

        Preview:SetCharacter(Data.Character or LocalPlayer.Character)
        Preview:Apply(Data.Settings or {}, {
            Name = Data.Name or LocalPlayer.DisplayName or LocalPlayer.Name,
            Distance = Data.Distance or "[24m]",
            Weapon = Data.Weapon or "Unarmed",
            Health = Data.Health or 74,
            MaxHealth = Data.MaxHealth or 100
        })

        return Preview
    end

    Library.TargetHUD = function(self, Data)
        Data = Data or {}

        local HUD = {
            Visible = Data.Visible == true,
            FollowTarget = Data.FollowTarget == true,
            PreviewMode = false,
            ManualPosition = Data.Position or UDim2New(0.5, 0, 1, -96),
            FullSize = Data.Size or UDim2New(0, 286, 0, 76),
            FollowSize = Data.FollowSize or UDim2New(0, 184, 0, 52),
            CurrentPlayer = nil,
            ThumbnailToken = 0,
            InternalPositionWrite = false,
            Inventory = {},
            Scale = math.clamp(
                tonumber(Data.Scale) or 1,
                0.55,
                1.75
            )
        }

        local Items = {}
        local Parent =
            Library:ResolveInstance(
                Data.Parent
            )
            or Library.Holder.Instance

        Items.Frame = Instances:Create("CanvasGroup", {
            Parent = Parent,
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = HUD.ManualPosition,
            Size = HUD.FullSize,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            GroupTransparency = 0,
            Visible = HUD.Visible,
            Active = true,
            ClipsDescendants = false,
            ZIndex = 120
        })

        Items.Scale = Instances:Create("UIScale", {
            Parent = Items.Frame.Instance,
            Scale = HUD.Scale
        })

        Items.Frame:MakeDraggable()

        Items.Surface = Instances:Create("Frame", {
            Parent = Items.Frame.Instance,
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background,
            ZIndex = 122
        })
        Items.Surface:AddToTheme({BackgroundColor3 = "Background"})
        Library:ApplyGlass(Items.Surface, "Window", 14)
        Library:AddGlassShadow(Items.Surface, 16, 3)
        Items.Surface.Instance.BackgroundTransparency = 0

        Items.Tint = Instances:Create("Frame", {
            Parent = Items.Surface.Instance,
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Accent,
            BackgroundTransparency = 0.965,
            ZIndex = 123
        })
        Items.Tint:AddToTheme({BackgroundColor3 = "Accent"})

        local TintCorner = InstanceNew("UICorner")
        TintCorner.CornerRadius = UDimNew(0, 14)
        TintCorner.Parent = Items.Tint.Instance

        local TintGradient = InstanceNew("UIGradient")
        TintGradient.Rotation = 20
        TintGradient.Transparency = NumSequence({
            NumSequenceKeypoint(0, 0.46),
            NumSequenceKeypoint(0.58, 0.89),
            NumSequenceKeypoint(1, 1)
        })
        TintGradient.Parent = Items.Tint.Instance

        Items.AvatarBack = Instances:Create("Frame", {
            Parent = Items.Surface.Instance,
            Position = UDim2New(0, 10, 0, 15),
            Size = UDim2New(0, 54, 0, 54),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element,
            ZIndex = 125
        })
        Items.AvatarBack:AddToTheme({BackgroundColor3 = "Element"})
        Library:ApplyGlass(Items.AvatarBack, "Element", 12)

        local AvatarStroke = InstanceNew("UIStroke")
        AvatarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        AvatarStroke.LineJoinMode = Enum.LineJoinMode.Round
        AvatarStroke.Thickness = 2
        AvatarStroke.Parent = Items.AvatarBack.Instance
        Library:AddToTheme(AvatarStroke, {Color = "Accent"})

        Items.Avatar = Instances:Create("ImageLabel", {
            Parent = Items.AvatarBack.Instance,
            Position = UDim2New(0, 3, 0, 3),
            Size = UDim2New(1, -6, 1, -6),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Image = Data.Image or "rbxasset://textures/ui/GuiImagePlaceholder.png",
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 126
        })

        local AvatarCorner = InstanceNew("UICorner")
        AvatarCorner.CornerRadius = UDimNew(0, 9)
        AvatarCorner.Parent = Items.Avatar.Instance

        Items.Name = Instances:Create("TextLabel", {
            Parent = Items.Surface.Instance,
            Position = UDim2New(0, 74, 0, 9),
            Size = UDim2New(0, 136, 0, 19),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = Data.Name or "",
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Library.Theme.Text,
            TextStrokeColor3 = FromRGB(0, 0, 0),
            TextStrokeTransparency = 0.18,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 126
        })
        Items.Name:AddToTheme({TextColor3 = "Text"})

        Items.Info = Instances:Create("TextLabel", {
            Parent = Items.Surface.Instance,
            Position = UDim2New(0, 74, 0, 28),
            Size = UDim2New(0, 136, 0, 13),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = Data.Info or "",
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextColor3 = Library.Theme["Muted Text"],
            TextStrokeColor3 = FromRGB(0, 0, 0),
            TextStrokeTransparency = 0.32,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 126
        })
        Items.Info:AddToTheme({TextColor3 = "Muted Text"})

        Items.Mode = Instances:Create("TextLabel", {
            Parent = Items.Surface.Instance,
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(1, -78, 0, 9),
            Size = UDim2New(0, 54, 0, 19),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Accent,
            BackgroundTransparency = 0,
            Font = Enum.Font.GothamBold,
            Text = "",
            TextSize = 10,
            TextColor3 = Library.Theme.Background,
            ZIndex = 126
        })
        Items.Mode:AddToTheme({
            BackgroundColor3 = "Accent",
            TextColor3 = "Background"
        })
        Library:ApplyGlass(Items.Mode, "Element", 8)
        Items.Mode.Instance.BackgroundTransparency = 0

        Items.Inventory = Instances:Create("Frame", {
            Parent = Items.Surface.Instance,
            Position = UDim2New(0, 74, 0, 43),
            Size = UDim2New(0, 150, 0, 25),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 125
        })

        Items.InventorySlots = {}

        for Index = 1, 5 do
            local Slot = {}

            Slot.Frame = Instances:Create("Frame", {
                Parent = Items.Inventory.Instance,
                Position = UDim2New(0, (Index - 1) * 29, 0, 0),
                Size = UDim2New(0, 24, 0, 24),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Element,
                Visible = false,
                ZIndex = 126
            })
            Slot.Frame:AddToTheme({BackgroundColor3 = "Element"})
            Library:ApplyGlass(Slot.Frame, "Element", 6)
            Slot.Frame.Instance.BackgroundTransparency = 0

            Slot.Image = Instances:Create("ImageLabel", {
                Parent = Slot.Frame.Instance,
                Position = UDim2New(0, 3, 0, 3),
                Size = UDim2New(1, -6, 1, -6),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                ScaleType = Enum.ScaleType.Fit,
                Visible = false,
                ZIndex = 127
            })

            Slot.Text = Instances:Create("TextLabel", {
                Parent = Slot.Frame.Instance,
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                FontFace = Library.Font,
                Text = "",
                TextSize = 10,
                TextColor3 = Library.Theme.Text,
                Visible = false,
                ZIndex = 127
            })
            Slot.Text:AddToTheme({TextColor3 = "Text"})

            Slot.Equipped = Instances:Create("Frame", {
                Parent = Slot.Frame.Instance,
                AnchorPoint = Vector2New(1, 1),
                Position = UDim2New(1, -2, 1, -2),
                Size = UDim2New(0, 5, 0, 5),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Accent,
                Visible = false,
                ZIndex = 128
            })
            Slot.Equipped:AddToTheme({BackgroundColor3 = "Accent"})

            local EquippedCorner = InstanceNew("UICorner")
            EquippedCorner.CornerRadius = UDimNew(1, 0)
            EquippedCorner.Parent = Slot.Equipped.Instance

            Items.InventorySlots[Index] = Slot
        end

        Items.HealthCircle = Instances:Create("Frame", {
            Parent = Items.Surface.Instance,
            AnchorPoint = Vector2New(1, 0),
            Position = UDim2New(1, -10, 0, 13),
            Size = UDim2New(0, 58, 0, 58),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline,
            ZIndex = 125
        })
        Items.HealthCircle:AddToTheme({BackgroundColor3 = "Inline"})
        Library:ApplyGlass(Items.HealthCircle, "Element", 29)

        Items.HealthRing = InstanceNew("UIStroke")
        Items.HealthRing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        Items.HealthRing.LineJoinMode = Enum.LineJoinMode.Round
        Items.HealthRing.Thickness = 3
        Items.HealthRing.Transparency = 0.08
        Items.HealthRing.Color = Library.Theme.Accent
        Items.HealthRing.Parent = Items.HealthCircle.Instance

        Items.HealthValue = Instances:Create("TextLabel", {
            Parent = Items.HealthCircle.Instance,
            Position = UDim2New(0, 0, 0, 8),
            Size = UDim2New(1, 0, 0, 23),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = "100",
            TextSize = 15,
            TextColor3 = Library.Theme.Text,
            ZIndex = 127
        })
        Items.HealthValue:AddToTheme({TextColor3 = "Text"})

        Items.HealthCaption = Instances:Create("TextLabel", {
            Parent = Items.HealthCircle.Instance,
            Position = UDim2New(0, 0, 0, 31),
            Size = UDim2New(1, 0, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            FontFace = Library.Font,
            Text = "HP",
            TextSize = 8,
            TextColor3 = Library.Theme["Muted Text"],
            ZIndex = 127
        })
        Items.HealthCaption:AddToTheme({TextColor3 = "Muted Text"})

        Items.HealthBack = Instances:Create("Frame", {
            Parent = Items.Surface.Instance,
            Position = UDim2New(0, 74, 1, -10),
            Size = UDim2New(0, 150, 0, 5),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline,
            ClipsDescendants = true,
            ZIndex = 125
        })
        Items.HealthBack:AddToTheme({BackgroundColor3 = "Inline"})
        Library:ApplyGlass(Items.HealthBack, "Element", 3)

        Items.HealthBar = Instances:Create("Frame", {
            Parent = Items.HealthBack.Instance,
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Accent,
            ZIndex = 126
        })

        local HealthBarCorner = InstanceNew("UICorner")
        HealthBarCorner.CornerRadius = UDimNew(1, 0)
        HealthBarCorner.Parent = Items.HealthBar.Instance

        Library:Connect(
            Items.Frame.Instance:GetPropertyChangedSignal("Position"),
            function()
                if HUD.InternalPositionWrite or HUD.FollowTarget and not HUD.PreviewMode then
                    return
                end

                HUD.ManualPosition = Items.Frame.Instance.Position
            end,
            "TargetHUDManualPosition"
        )

        local function WritePosition(Position)
            HUD.InternalPositionWrite = true
            Items.Frame.Instance.Position = Position
            HUD.InternalPositionWrite = false
        end

        local function ApplyLayout()
            local Compact = HUD.FollowTarget and not HUD.PreviewMode

            Items.Frame.Instance.Size = Compact and HUD.FollowSize or HUD.FullSize
            Items.AvatarBack.Instance.Position = Compact and UDim2New(0, 8, 0, 9) or UDim2New(0, 10, 0, 15)
            Items.AvatarBack.Instance.Size = Compact and UDim2New(0, 38, 0, 38) or UDim2New(0, 54, 0, 54)
            Items.Name.Instance.Position = Compact and UDim2New(0, 53, 0, 6) or UDim2New(0, 74, 0, 9)
            Items.Name.Instance.Size = Compact and UDim2New(0, 84, 0, 15) or UDim2New(0, 136, 0, 19)
            Items.Name.Instance.TextSize = Compact and 10 or 14
            Items.Info.Instance.Visible = not Compact
            Items.Mode.Instance.Visible = not Compact
            Items.Inventory.Instance.Position = Compact and UDim2New(0, 53, 0, 28) or UDim2New(0, 74, 0, 43)
            Items.HealthCircle.Instance.Position = Compact and UDim2New(1, -7, 0, 8) or UDim2New(1, -10, 0, 13)
            Items.HealthCircle.Instance.Size = Compact and UDim2New(0, 40, 0, 40) or UDim2New(0, 58, 0, 58)
            Items.HealthRing.Thickness = Compact and 2 or 3
            Items.HealthValue.Instance.Position = Compact and UDim2New(0, 0, 0, 5) or UDim2New(0, 0, 0, 8)
            Items.HealthValue.Instance.Size = Compact and UDim2New(1, 0, 0, 18) or UDim2New(1, 0, 0, 23)
            Items.HealthValue.Instance.TextSize = Compact and 11 or 15
            Items.HealthCaption.Instance.Position = Compact and UDim2New(0, 0, 0, 22) or UDim2New(0, 0, 0, 31)
            Items.HealthCaption.Instance.TextSize = Compact and 6 or 8
            Items.HealthBack.Instance.Position = Compact and UDim2New(0, 53, 1, -7) or UDim2New(0, 74, 1, -10)
            Items.HealthBack.Instance.Size = Compact and UDim2New(0, 92, 0, 4) or UDim2New(0, 150, 0, 5)

            for Index, Slot in ipairs(Items.InventorySlots) do
                local Show = Slot.HasItem == true and (not Compact or Index <= 3)
                Slot.Frame.Instance.Position = Compact
                    and UDim2New(0, (Index - 1) * 24, 0, 0)
                    or UDim2New(0, (Index - 1) * 29, 0, 0)
                Slot.Frame.Instance.Size = Compact and UDim2New(0, 19, 0, 19) or UDim2New(0, 24, 0, 24)
                Slot.Frame.Instance.Visible = Show
                Slot.Text.Instance.TextSize = Compact and 8 or 10
            end
        end

        function HUD:SetScale(Value)
            Value = math.clamp(
                tonumber(Value) or 1,
                0.55,
                1.75
            )

            HUD.Scale = Value
            Items.Scale.Instance.Scale = Value
        end

        function HUD:GetScale()
            return HUD.Scale
        end

        function HUD:SetVisibility(Value)
            HUD.Visible = Value == true
            Items.Frame.Instance.Visible = HUD.Visible
        end

        function HUD:SetHealth(Health, MaxHealth)
            local Current = math.max(0, tonumber(Health) or 0)
            local Maximum = math.max(1, tonumber(MaxHealth) or 100)
            local Ratio = MathClamp(Current / Maximum, 0, 1)
            local HealthColor = FromRGB(247, 87, 105):Lerp(FromRGB(117, 238, 174), Ratio)

            Items.HealthBar:Tween(
                TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {
                    Size = UDim2New(Ratio, 0, 1, 0),
                    BackgroundColor3 = HealthColor
                }
            )

            Items.HealthRing.Color = HealthColor
            Items.HealthValue.Instance.Text = StringFormat("%d", MathFloor(Current + 0.5))
        end

        function HUD:SetName(Value)
            Items.Name.Instance.Text = tostring(Value or "")
        end

        function HUD:SetInfo(Value)
            Items.Info.Instance.Text = tostring(Value or "")
        end

        function HUD:SetImage(Value)
            Items.Avatar.Instance.Image = tostring(Value or "")
        end

        function HUD:SetMode(Value)
            local Mode = string.upper(tostring(Value or ""))
            Items.Mode.Instance.Text = Mode == "PREVIEW" and "SELF" or Mode
        end

        function HUD:SetInventory(Inventory)
            Inventory = type(Inventory) == "table" and Inventory or {}
            HUD.Inventory = Inventory

            for Index, Slot in ipairs(Items.InventorySlots) do
                local Entry = Inventory[Index]
                Slot.HasItem = type(Entry) == "table"

                if not Slot.HasItem then
                    Slot.Frame.Instance.Visible = false
                    Slot.Image.Instance.Visible = false
                    Slot.Text.Instance.Visible = false
                    Slot.Equipped.Instance.Visible = false
                else
                    local Image = tostring(Entry.Image or "")
                    local Text = tostring(
                        Entry.Text
                        or Entry.Short
                        or (Entry.Name and string.sub(tostring(Entry.Name), 1, 2))
                        or "?"
                    )

                    Slot.Image.Instance.Image = Image
                    Slot.Image.Instance.Visible = Image ~= ""
                    Slot.Text.Instance.Text = string.upper(Text)
                    Slot.Text.Instance.Visible = Image == ""
                    Slot.Equipped.Instance.Visible = Entry.Equipped == true
                end
            end

            ApplyLayout()
        end

        function HUD:SetFollowTarget(Value)
            Value = Value == true

            if Value and not HUD.FollowTarget and not HUD.PreviewMode then
                HUD.ManualPosition = Items.Frame.Instance.Position
            end

            HUD.FollowTarget = Value
            ApplyLayout()

            if not Value or HUD.PreviewMode then
                WritePosition(HUD.ManualPosition)
            end
        end

        function HUD:SetPreviewMode(Value)
            Value = Value == true
            HUD.PreviewMode = Value
            ApplyLayout()

            if Value or not HUD.FollowTarget then
                WritePosition(HUD.ManualPosition)
            end
        end

        function HUD:SetManualPosition(Position)
            if typeof(Position) ~= "UDim2" then
                return
            end

            HUD.ManualPosition = Position

            if HUD.PreviewMode or not HUD.FollowTarget then
                WritePosition(Position)
            end
        end

        function HUD:GetManualPosition()
            return HUD.ManualPosition
        end

        function HUD:SetFollowScreenPosition(ScreenPosition, ViewportSize, Offset)
            if not HUD.FollowTarget or HUD.PreviewMode then
                return false
            end

            if typeof(ScreenPosition) ~= "Vector2" or typeof(ViewportSize) ~= "Vector2" then
                return false
            end

            Offset = typeof(Offset) == "Vector2" and Offset or Vector2New(0, -46)

            local FrameSize = Items.Frame.Instance.AbsoluteSize
            local HalfWidth = math.max(FrameSize.X * 0.5, 20)
            local HalfHeight = math.max(FrameSize.Y * 0.5, 20)
            local X = MathClamp(ScreenPosition.X + Offset.X, HalfWidth + 6, ViewportSize.X - HalfWidth - 6)
            local Y = MathClamp(ScreenPosition.Y + Offset.Y, HalfHeight + 6, ViewportSize.Y - HalfHeight - 6)

            WritePosition(UDim2New(0, X, 0, Y))
            return true
        end

        function HUD:SetTarget(Player, Health, MaxHealth, Info, Mode)
            HUD:SetName(Player and (Player.DisplayName or Player.Name) or "")
            HUD:SetHealth(Health or 0, MaxHealth or 100)
            HUD:SetInfo(Info or "")
            HUD:SetMode(Mode or "")

            if HUD.CurrentPlayer == Player then
                return
            end

            HUD.CurrentPlayer = Player
            HUD.ThumbnailToken = HUD.ThumbnailToken + 1

            local Token = HUD.ThumbnailToken

            if Player and Player.UserId then
                Library:Thread(function()
                    local Success, Image = pcall(
                        Players.GetUserThumbnailAsync,
                        Players,
                        Player.UserId,
                        Enum.ThumbnailType.HeadShot,
                        Enum.ThumbnailSize.Size100x100
                    )

                    if Success and Token == HUD.ThumbnailToken and Items.Avatar.Instance.Parent then
                        Items.Avatar.Instance.Image = Image
                    end
                end)
            end
        end

        function HUD:Destroy()
            HUD.ThumbnailToken = HUD.ThumbnailToken + 1
            Library:Disconnect("TargetHUDManualPosition")

            if Items.Frame and Items.Frame.Instance then
                Items.Frame.Instance:Destroy()
            end
        end

        HUD.Frame = Items.Frame.Instance
        HUD.Items = Items

        ApplyLayout()

        return HUD
    end

    Library.Window = function(self, Data)
        Data = Data or { }

        local Window = {
            Name = Data.Name or Data.name or "Window",
            Size = Data.Size or Data.size or UDim2New(0, 820, 0, 430),
            FadeSpeed = Data.FadeSpeed or Data.fadespeed or 0.25,
            Pages = { },
            SubPages = { },
            Elements = { },
            IsOpen = true,
            AnimationToken = 0
        }

        local QuickState = {
            Open = false,
            Submenu = nil,
            MenuScale = 1,
            Style =
                Data.Style
                or "Radiant Emerald",

            HideWatermark = false,
            HideNotifications = false,
            HideKeybinds = false
        }

        local Items = { } do
            Items["MainFrame"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                AnchorPoint = Vector2New(0, 0),
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 0),
                Size = Window.Size,
                BorderSizePixel = 0,
                BackgroundTransparency = 1
            })

            Items["MainFrame"].Instance.Position = UDim2New(
                0,
                Camera.ViewportSize.X / 4,
                0,
                Camera.ViewportSize.Y / 4
            )

            Items["MenuScale"] = Instances:Create("UIScale", {
                Parent = Items["MainFrame"].Instance,
                Scale = 1
            })

            Items["Surface"] = Instances:Create("CanvasGroup", {
                Parent = Items["MainFrame"].Instance,
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                GroupTransparency = 0,
                Active = true
            })

            Items["DropdownDim"] =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["Surface"].Instance,

                        Name = string.char(0),
                        Position =
                            UDim2New(0, 0, 0, 0),

                        Size =
                            UDim2New(1, 0, 1, 0),

                        BorderSizePixel = 0,
                        BackgroundColor3 =
                            FromRGB(0, 0, 0),

                        BackgroundTransparency = 1,
                        AutoButtonColor = false,
                        Text = "",
                        Visible = false,
                        Active = false,
                        ZIndex = 850
                    }
                )

            Items["MainFrame"]:MakeResizeable(
                Vector2New(700, 380),
                Vector2New(9999, 9999)
            )

            local RailWidth = 156
            local RailMinimum = 118
            local RailMaximum = 210
            local RailGap = 10

            Items["Rail"] = Instances:Create("Frame", {
                Parent = Items["Surface"].Instance,
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(0, RailWidth, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Background
            })

            Items["RailInset"] = Instances:Create("Frame", {
                Parent = Items["Rail"].Instance,
                Name = string.char(0),
                Position = UDim2New(0, 6, 0, 6),
                Size = UDim2New(1, -12, 1, -12),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme["Page Background"],
                BackgroundTransparency = 0.22,
                ZIndex = 0
            })
            Items["RailInset"]:AddToTheme({
                BackgroundColor3 = "Page Background"
            })
            Library:ApplyGlass(Items["RailInset"], "Popup", 4)
            Items["Rail"]:AddToTheme({
                BackgroundColor3 = "Background"
            })
            Library:ApplyGlass(Items["Rail"], "Window", 4)

            Items["RailStroke"] = Instances:Create("UIStroke", {
                Parent = Items["Rail"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Round,
                Thickness = 1,
                Transparency = 0.42,
                Color = Library.Theme.Outline
            })
            Items["RailStroke"]:AddToTheme({
                Color = "Outline"
            })

            Items["Pages"] = Instances:Create("Frame", {
                Parent = Items["Rail"].Instance,
                Name = string.char(0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 10, 0, 10),
                Size = UDim2New(1, -20, 1, -20),
                BorderSizePixel = 0
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Pages"].Instance,
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Panel"] = Instances:Create("Frame", {
                Parent = Items["Surface"].Instance,
                Name = string.char(0),
                Position = UDim2New(
                    0,
                    RailWidth + RailGap,
                    0,
                    0
                ),
                Size = UDim2New(
                    1,
                    -(RailWidth + RailGap),
                    1,
                    0
                ),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Background,
                ClipsDescendants = true
            })
            Items["Panel"]:AddToTheme({
                BackgroundColor3 = "Background"
            })
            Library:ApplyGlass(Items["Panel"], "Window", 4)

            Items["RailResize"] = Instances:Create("TextButton", {
                Parent = Items["Surface"].Instance,
                Name = string.char(0),
                Position = UDim2New(0, RailWidth, 0, 0),
                Size = UDim2New(0, RailGap, 1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                AutoButtonColor = false,
                Text = "",
                Active = true,
                ZIndex = 9999
            })

            Items["RailResizeLine"] = Instances:Create("Frame", {
                Parent = Items["RailResize"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 1, 1, -18),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Outline,
                BackgroundTransparency = 0.72,
                ZIndex = 10000
            })
            Items["RailResizeLine"]:AddToTheme({
                BackgroundColor3 = "Outline"
            })

            local RailMoveConnection = nil
            local RailEndConnection = nil
            local RailRenderConnection = nil
            local PendingRailWidth = nil

            local function ApplyRailWidth(Value)
                local FrameWidth =
                    Items["MainFrame"].Instance.AbsoluteSize.X

                local DynamicMaximum = math.max(
                    RailMinimum,
                    math.min(RailMaximum, FrameWidth - 430)
                )

                RailWidth = math.clamp(
                    math.floor(Value + 0.5),
                    RailMinimum,
                    DynamicMaximum
                )

                Items["Rail"].Instance.Size =
                    UDim2New(0, RailWidth, 1, 0)
                Items["RailResize"].Instance.Position =
                    UDim2New(0, RailWidth, 0, 0)
                Items["Panel"].Instance.Position =
                    UDim2New(0, RailWidth + RailGap, 0, 0)
                Items["Panel"].Instance.Size =
                    UDim2New(1, -(RailWidth + RailGap), 1, 0)
            end

            local function ApplyPendingRailWidth()
                if PendingRailWidth ~= nil then
                    ApplyRailWidth(PendingRailWidth)
                    PendingRailWidth = nil
                end
            end

            local function StopRailResize()
                ApplyPendingRailWidth()

                if RailMoveConnection then
                    RailMoveConnection:Disconnect()
                    RailMoveConnection = nil
                end

                if RailEndConnection then
                    RailEndConnection:Disconnect()
                    RailEndConnection = nil
                end

                if RailRenderConnection then
                    RailRenderConnection:Disconnect()
                    RailRenderConnection = nil
                end
            end

            Items["RailResize"]:OnHover(function()
                Items["RailResizeLine"]:Tween(nil, {
                    BackgroundTransparency = 0.30,
                    BackgroundColor3 = Library.Theme.Accent
                })
            end)

            Items["RailResize"]:OnHoverLeave(function()
                if RailMoveConnection then
                    return
                end

                Items["RailResizeLine"]:Tween(nil, {
                    BackgroundTransparency = 0.78,
                    BackgroundColor3 = Library.Theme.Outline
                })
            end)

            Items["RailResize"]:Connect("InputBegan", function(Input)
                if Input.UserInputType
                        ~= Enum.UserInputType.MouseButton1
                    and Input.UserInputType
                        ~= Enum.UserInputType.Touch
                then
                    return
                end

                StopRailResize()

                local StartMouse = Input.Position
                local StartWidth = RailWidth
                local IsTouch =
                    Input.UserInputType
                    == Enum.UserInputType.Touch

                Items["RailResizeLine"]:Tween(nil, {
                    BackgroundTransparency = 0.12,
                    BackgroundColor3 = Library.Theme.Accent
                })

                RailMoveConnection =
                    UserInputService.InputChanged:
                    Connect(function(ChangedInput)
                        local Matching =
                            IsTouch
                            and ChangedInput == Input
                            or not IsTouch
                            and ChangedInput.UserInputType
                                == Enum.UserInputType.MouseMovement

                        if not Matching then
                            return
                        end

                        PendingRailWidth =
                            StartWidth
                            + ChangedInput.Position.X
                            - StartMouse.X
                    end)

                RailRenderConnection =
                    RunService.RenderStepped:
                    Connect(function()
                        if Library.Unloaded
                            or not Items["MainFrame"].Instance.Parent
                        then
                            StopRailResize()
                            return
                        end

                        ApplyPendingRailWidth()
                    end)

                RailEndConnection =
                    UserInputService.InputEnded:
                    Connect(function(EndedInput)
                        local Matching =
                            IsTouch
                            and EndedInput == Input
                            or not IsTouch
                            and EndedInput.UserInputType
                                == Enum.UserInputType.MouseButton1

                        if not Matching then
                            return
                        end

                        StopRailResize()
                        Items["RailResizeLine"]:Tween(nil, {
                            BackgroundTransparency = 0.78,
                            BackgroundColor3 = Library.Theme.Outline
                        })
                    end)
            end)

            Library:Connect(
                Items["MainFrame"].Instance:
                    GetPropertyChangedSignal("AbsoluteSize"),
                function()
                    PendingRailWidth = RailWidth
                    ApplyPendingRailWidth()
                end
            )

            task.defer(function()
                ApplyRailWidth(RailWidth)
            end)

            Items["PanelStroke"] = Instances:Create("UIStroke", {
                Parent = Items["Panel"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Round,
                Thickness = 1,
                Transparency = 0.42,
                Color = Library.Theme.Outline
            })
            Items["PanelStroke"]:AddToTheme({
                Color = "Outline"
            })

            Items["Gear"] =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["Panel"].Instance,

                        AnchorPoint =
                            Vector2New(1, 0),

                        Position =
                            UDim2New(
                                1,
                                -7,
                                0,
                                5
                            ),

                        Size =
                            UDim2New(
                                0,
                                24,
                                0,
                                24
                            ),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1,

                        AutoButtonColor = false,
                        Text = "",
                        ZIndex = 701
                    }
                )

            Items["Gear"]:AddToTheme({
                BackgroundColor3 = "Element"
            })

            Library:ApplyGlass(
                Items["Gear"],
                "Element",
                4
            )

            Items["GearIcon"] =
                Library:CreateVectorIcon(
                    Items["Gear"],
                    "gear",
                    {
                        Size = 15,

                        Position =
                            UDim2New(
                                0.5,
                                0,
                                0.5,
                                0
                            ),

                        AnchorPoint =
                            Vector2New(0.5, 0.5),

                        Theme = "Muted Text",
                        ZIndex = 703
                    }
                )

            Items["Title"] =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            Items["Panel"].Instance,

                        FontFace = Library.Font,
                        TextColor3 = Library.Theme.Text,
                        Text = Window.Name,
                        Name = string.char(0),

                        Size =
                            UDim2New(
                                0,
                                150,
                                0,
                                24
                            ),

                        AnchorPoint =
                            Vector2New(1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Right,

                        Position =
                            UDim2New(
                                1,
                                -38,
                                0,
                                5
                            ),

                        BorderSizePixel = 0,
                        TextSize = 14,
                        TextTransparency = 0,
                        ZIndex = 700
                    }
                )

            Items["Title"]:AddToTheme({
                TextColor3 = "Text"
            })

            Items["DragArea"] =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["Panel"].Instance,

                        Position =
                            UDim2New(0, 0, 0, 0),

                        Size =
                            UDim2New(1, -190, 0, 33),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        AutoButtonColor = false,
                        Text = "",
                        ZIndex = 699
                    }
                )

            Items["MainFrame"]:MakeDraggable(
                Items["DragArea"],
                32
            )

            Items["QuickPanel"] =
                Instances:Create(
                    "CanvasGroup",
                    {
                        Parent =
                            Items["Panel"].Instance,

                        AnchorPoint =
                            Vector2New(1, 0),

                        Position =
                            UDim2New(
                                1,
                                -7,
                                0,
                                34
                            ),

                        Size =
                            UDim2New(
                                0,
                                190,
                                0,
                                216
                            ),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Background,

                        Visible = false,
                        Active = true,
                        GroupTransparency = 1,
                        ClipsDescendants = true,
                        ZIndex = 720
                    }
                )

            Items["QuickPanel"]:AddToTheme({
                BackgroundColor3 = "Background"
            })

            Library:ApplyGlass(
                Items["QuickPanel"],
                "Popup",
                6
            )

            Items["QuickProfile"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Items["QuickPanel"].Instance,

                        Position =
                            UDim2New(
                                0,
                                7,
                                0,
                                7
                            ),

                        Size =
                            UDim2New(
                                1,
                                -14,
                                0,
                                45
                            ),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme[
                                "Page Background"
                            ],

                        ZIndex = 721
                    }
                )

            Items["QuickProfile"]:AddToTheme({
                BackgroundColor3 =
                    "Page Background"
            })

            Library:ApplyGlass(
                Items["QuickProfile"],
                "Element",
                5
            )

            Items["QuickAvatar"] =
                Instances:Create(
                    "ImageLabel",
                    {
                        Parent =
                            Items["QuickProfile"].Instance,

                        Position =
                            UDim2New(
                                0,
                                7,
                                0.5,
                                -15
                            ),

                        Size =
                            UDim2New(
                                0,
                                30,
                                0,
                                30
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,

                        Image =
                            "rbxthumb://type=AvatarHeadShot&id="
                            .. tostring(LocalPlayer.UserId)
                            .. "&w=100&h=100",

                        ZIndex = 722
                    }
                )

            local QuickAvatarCorner =
                InstanceNew("UICorner")

            QuickAvatarCorner.CornerRadius =
                UDimNew(1, 0)

            QuickAvatarCorner.Parent =
                Items["QuickAvatar"].Instance

            Items["QuickName"] =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            Items["QuickProfile"].Instance,

                        Position =
                            UDim2New(
                                0,
                                44,
                                0,
                                7
                            ),

                        Size =
                            UDim2New(
                                1,
                                -51,
                                0,
                                15
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        FontFace = Library.Font,

                        Text =
                            LocalPlayer.DisplayName
                            or LocalPlayer.Name,

                        TextSize = 10,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        TextColor3 =
                            Library.Theme.Text,

                        TextTruncate =
                            Enum.TextTruncate.AtEnd,

                        ZIndex = 722
                    }
                )

            Items["QuickName"]:AddToTheme({
                TextColor3 = "Text"
            })

            Items["QuickUser"] =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            Items["QuickProfile"].Instance,

                        Position =
                            UDim2New(
                                0,
                                44,
                                0,
                                22
                            ),

                        Size =
                            UDim2New(
                                1,
                                -51,
                                0,
                                14
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        FontFace = Library.Font,

                        Text =
                            "@"
                            .. tostring(
                                LocalPlayer.Name
                            ),

                        TextSize = 9,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],

                        TextTruncate =
                            Enum.TextTruncate.AtEnd,

                        ZIndex = 722
                    }
                )

            Items["QuickUser"]:AddToTheme({
                TextColor3 = "Muted Text"
            })

            Items["QuickRows"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Items["QuickPanel"].Instance,

                        Position =
                            UDim2New(
                                0,
                                7,
                                0,
                                58
                            ),

                        Size =
                            UDim2New(
                                1,
                                -14,
                                1,
                                -65
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        ZIndex = 721
                    }
                )

            local QuickRowsLayout =
                InstanceNew("UIListLayout")

            QuickRowsLayout.Padding =
                UDimNew(0, 2)

            QuickRowsLayout.SortOrder =
                Enum.SortOrder.LayoutOrder

            QuickRowsLayout.Parent =
                Items["QuickRows"].Instance

            local QuickTween =
                TweenInfo.new(
                    0.12,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )

            local function CreateQuickRow(
                Key,
                Name,
                IconName,
                Value
            )
                local Row =
                    Instances:Create(
                        "TextButton",
                        {
                            Parent =
                                Items["QuickRows"].Instance,

                            Size =
                                UDim2New(
                                    1,
                                    0,
                                    0,
                                    27
                                ),

                            BorderSizePixel = 0,

                            BackgroundColor3 =
                                Library.Theme.Element,

                            BackgroundTransparency = 1,

                            AutoButtonColor = false,
                            Text = "",
                            ZIndex = 722
                        }
                    )

                Row:AddToTheme({
                    BackgroundColor3 = "Element"
                })

                local Icon =
                    Library:CreateVectorIcon(
                        Row,
                        IconName,
                        {
                            Size = 14,

                            Position =
                                UDim2New(
                                    0,
                                    7,
                                    0.5,
                                    0
                                ),

                            AnchorPoint =
                                Vector2New(0, 0.5),

                            Theme = "Muted Text",
                            ZIndex = 724
                        }
                    )

                local Label =
                    Instances:Create(
                        "TextLabel",
                        {
                            Parent = Row.Instance,

                            Position =
                                UDim2New(
                                    0,
                                    27,
                                    0,
                                    0
                                ),

                            Size =
                                UDim2New(
                                    1,
                                    -78,
                                    1,
                                    0
                                ),

                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            FontFace = Library.Font,
                            Text = Name,
                            TextSize = 10,

                            TextXAlignment =
                                Enum.TextXAlignment.Left,

                            TextColor3 =
                                Library.Theme.Text,

                            ZIndex = 723
                        }
                    )

                Label:AddToTheme({
                    TextColor3 = "Text"
                })

                local ValueLabel =
                    Instances:Create(
                        "TextLabel",
                        {
                            Parent = Row.Instance,

                            AnchorPoint =
                                Vector2New(1, 0),

                            Position =
                                UDim2New(
                                    1,
                                    -7,
                                    0,
                                    0
                                ),

                            Size =
                                UDim2New(
                                    0,
                                    48,
                                    1,
                                    0
                                ),

                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            FontFace = Library.Font,
                            Text = Value or "",
                            TextSize = 9,

                            TextXAlignment =
                                Enum.TextXAlignment.Right,

                            TextColor3 =
                                Library.Theme[
                                    "Muted Text"
                                ],

                            ZIndex = 723
                        }
                    )

                ValueLabel:AddToTheme({
                    TextColor3 = "Muted Text"
                })

                Row:OnHover(function()
                    Row:Tween(
                        QuickTween,
                        {
                            BackgroundTransparency =
                                0.36
                        }
                    )

                    Icon:SetTheme("Text")
                end)

                Row:OnHoverLeave(function()
                    Row:Tween(
                        QuickTween,
                        {
                            BackgroundTransparency = 1
                        }
                    )

                    Icon:SetTheme("Muted Text")
                end)

                Items[Key] = {
                    Row = Row,
                    Icon = Icon,
                    Label = Label,
                    Value = ValueLabel
                }

                return Items[Key]
            end

            local ScaleRow =
                CreateQuickRow(
                    "QuickScale",
                    "Menu Scale",
                    "sliders",
                    "100%"
                )

            local StyleRow =
                CreateQuickRow(
                    "QuickStyle",
                    "Style",
                    "palette",
                    QuickState.Style
                )

            local function CreateQuickToggle(
                Key,
                Name,
                IconName,
                Getter,
                Setter
            )
                local Entry =
                    CreateQuickRow(
                        Key,
                        Name,
                        IconName,
                        ""
                    )

                Entry.Box =
                    Instances:Create(
                        "Frame",
                        {
                            Parent =
                                Entry.Row.Instance,

                            AnchorPoint =
                                Vector2New(1, 0.5),

                            Position =
                                UDim2New(
                                    1,
                                    -8,
                                    0.5,
                                    0
                                ),

                            Size =
                                UDim2New(
                                    0,
                                    12,
                                    0,
                                    12
                                ),

                            BorderSizePixel = 0,

                            BackgroundColor3 =
                                Library.Theme.Element,

                            ZIndex = 725
                        }
                    )

                Entry.Box:AddToTheme({
                    BackgroundColor3 = "Element"
                })

                Library:ApplyGlass(
                    Entry.Box,
                    "Element",
                    3
                )

                Entry.Fill =
                    Instances:Create(
                        "Frame",
                        {
                            Parent =
                                Entry.Box.Instance,

                            Position =
                                UDim2New(
                                    0,
                                    3,
                                    0,
                                    3
                                ),

                            Size =
                                UDim2New(
                                    1,
                                    -6,
                                    1,
                                    -6
                                ),

                            BorderSizePixel = 0,

                            BackgroundColor3 =
                                Library.Theme.Accent,

                            BackgroundTransparency = 1,
                            ZIndex = 726
                        }
                    )

                Entry.Fill:AddToTheme({
                    BackgroundColor3 = "Accent"
                })

                local FillCorner =
                    InstanceNew("UICorner")

                FillCorner.CornerRadius =
                    UDimNew(0, 1)

                FillCorner.Parent =
                    Entry.Fill.Instance

                local function Refresh()
                    local Active =
                        Getter() == true

                    Entry.Fill:Tween(
                        QuickTween,
                        {
                            BackgroundTransparency =
                                Active and 0 or 1
                        }
                    )
                end

                Entry.Row:Connect(
                    "MouseButton1Down",
                    function()
                        Setter(
                            not Getter()
                        )

                        Refresh()
                    end
                )

                Entry.Refresh = Refresh
                Refresh()

                return Entry
            end

            local HideWatermark =
                CreateQuickToggle(
                    "QuickHideWatermark",
                    "Hide Watermark",
                    "eyeoff",
                    function()
                        return QuickState.HideWatermark
                    end,
                    function(Value)
                        QuickState.HideWatermark =
                            Value == true

                        if Library.SetFlags[
                            "Watermark"
                        ] then
                            Library.SetFlags[
                                "Watermark"
                            ](
                                not QuickState.
                                    HideWatermark
                            )
                        elseif Library.ActiveWatermark then
                            Library.ActiveWatermark:
                                SetVisibility(
                                    not QuickState.
                                        HideWatermark
                                )
                        end
                    end
                )

            local HideNotifications =
                CreateQuickToggle(
                    "QuickHideNotifications",
                    "Hide Notifications",
                    "belloff",
                    function()
                        return QuickState.
                            HideNotifications
                    end,
                    function(Value)
                        QuickState.
                            HideNotifications =
                            Value == true

                        Library.NotificationsHidden =
                            QuickState.
                                HideNotifications
                    end
                )

            local HideKeybinds =
                CreateQuickToggle(
                    "QuickHideKeybinds",
                    "Hide Keybind List",
                    "list",
                    function()
                        return QuickState.
                            HideKeybinds
                    end,
                    function(Value)
                        QuickState.
                            HideKeybinds =
                            Value == true

                        if Library.SetFlags[
                            "Keybind List"
                        ] then
                            Library.SetFlags[
                                "Keybind List"
                            ](
                                not QuickState.
                                    HideKeybinds
                            )
                        elseif Library.KeyList then
                            Library.KeyList:
                                SetVisibility(
                                    not QuickState.
                                        HideKeybinds
                                )
                        end
                    end
                )

            Items["QuickSubmenu"] =
                Instances:Create(
                    "CanvasGroup",
                    {
                        Parent =
                            Items["Panel"].Instance,

                        AnchorPoint =
                            Vector2New(1, 0),

                        Position =
                            UDim2New(
                                1,
                                -204,
                                0,
                                58
                            ),

                        Size =
                            UDim2New(
                                0,
                                124,
                                0,
                                0
                            ),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Background,

                        Visible = false,
                        Active = true,
                        GroupTransparency = 1,
                        ClipsDescendants = true,
                        ZIndex = 730
                    }
                )

            Items["QuickSubmenu"]:AddToTheme({
                BackgroundColor3 = "Background"
            })

            Library:ApplyGlass(
                Items["QuickSubmenu"],
                "Popup",
                5
            )

            Items["QuickSubmenuRows"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Items["QuickSubmenu"].
                                Instance,

                        Position =
                            UDim2New(
                                0,
                                4,
                                0,
                                4
                            ),

                        Size =
                            UDim2New(
                                1,
                                -8,
                                1,
                                -8
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        ZIndex = 731
                    }
                )

            local QuickSubLayout =
                InstanceNew("UIListLayout")

            QuickSubLayout.Padding =
                UDimNew(0, 1)

            QuickSubLayout.SortOrder =
                Enum.SortOrder.LayoutOrder

            QuickSubLayout.Parent =
                Items["QuickSubmenuRows"].
                    Instance

            local function CloseSubmenu()
                QuickState.Submenu = nil

                Items["QuickSubmenu"]:Tween(
                    QuickTween,
                    {
                        GroupTransparency = 1
                    }
                )

                task.delay(
                    0.12,
                    function()
                        if not QuickState.Submenu
                            and Items[
                                "QuickSubmenu"
                            ].Instance
                            and Items[
                                "QuickSubmenu"
                            ].Instance.Parent
                        then
                            Items[
                                "QuickSubmenu"
                            ].Instance.Visible =
                                false
                        end
                    end
                )
            end

            local function ClearSubmenuRows()
                for _,
                    Child in ipairs(
                        Items[
                            "QuickSubmenuRows"
                        ].Instance:
                            GetChildren()
                    )
                do
                    if Child:IsA("GuiObject") then
                        Child:Destroy()
                    end
                end
            end

            local function OpenSubmenu(
                Kind,
                Options,
                Current,
                Callback
            )
                QuickState.Submenu = Kind
                ClearSubmenuRows()

                local Height =
                    #Options * 24 + 8

                Items["QuickSubmenu"].
                    Instance.Size =
                    UDim2New(
                        0,
                        124,
                        0,
                        Height
                    )

                for _,
                    Option in ipairs(Options)
                do
                    local Row =
                        Instances:Create(
                            "TextButton",
                            {
                                Parent =
                                    Items[
                                        "QuickSubmenuRows"
                                    ].Instance,

                                Size =
                                    UDim2New(
                                        1,
                                        0,
                                        0,
                                        23
                                    ),

                                BorderSizePixel = 0,

                                BackgroundColor3 =
                                    Library.Theme.Element,

                                BackgroundTransparency =
                                    Option == Current
                                    and 0.42
                                    or 1,

                                AutoButtonColor = false,
                                Text = "",
                                ZIndex = 732
                            }
                        )

                    Row:AddToTheme({
                        BackgroundColor3 =
                            "Element"
                    })

                    local Marker =
                        Instances:Create(
                            "Frame",
                            {
                                Parent = Row.Instance,

                                Position =
                                    UDim2New(
                                        0,
                                        0,
                                        0,
                                        4
                                    ),

                                Size =
                                    UDim2New(
                                        0,
                                        2,
                                        1,
                                        -8
                                    ),

                                BorderSizePixel = 0,

                                BackgroundColor3 =
                                    Library.Theme.Accent,

                                BackgroundTransparency =
                                    Option == Current
                                    and 0
                                    or 1,

                                ZIndex = 733
                            }
                        )

                    Marker:AddToTheme({
                        BackgroundColor3 = "Accent"
                    })

                    local Label =
                        Instances:Create(
                            "TextLabel",
                            {
                                Parent = Row.Instance,

                                Position =
                                    UDim2New(
                                        0,
                                        9,
                                        0,
                                        0
                                    ),

                                Size =
                                    UDim2New(
                                        1,
                                        -14,
                                        1,
                                        0
                                    ),

                                BorderSizePixel = 0,
                                BackgroundTransparency = 1,
                                FontFace = Library.Font,
                                Text = tostring(Option),
                                TextSize = 10,

                                TextXAlignment =
                                    Enum.TextXAlignment.Left,

                                TextColor3 =
                                    Option == Current
                                    and Library.Theme.Accent
                                    or Library.Theme.Text,

                                ZIndex = 733
                            }
                        )

                    Label:AddToTheme({
                        TextColor3 =
                            Option == Current
                            and "Accent"
                            or "Text"
                    })

                    Row:OnHover(function()
                        Row:Tween(
                            QuickTween,
                            {
                                BackgroundTransparency =
                                    0.48
                            }
                        )
                    end)

                    Row:OnHoverLeave(function()
                        Row:Tween(
                            QuickTween,
                            {
                                BackgroundTransparency =
                                    Option == Current
                                    and 0.42
                                    or 1
                            }
                        )
                    end)

                    Row:Connect(
                        "MouseButton1Down",
                        function()
                            Callback(Option)
                            CloseSubmenu()
                        end
                    )
                end

                Items["QuickSubmenu"].
                    Instance.GroupTransparency = 1

                Items["QuickSubmenu"].
                    Instance.Visible = true

                Items["QuickSubmenu"]:Tween(
                    QuickTween,
                    {
                        GroupTransparency = 0
                    }
                )
            end

            ScaleRow.Row:Connect(
                "MouseButton1Down",
                function()
                    OpenSubmenu(
                        "Scale",
                        {
                            "75%",
                            "90%",
                            "100%",
                            "110%",
                            "125%"
                        },
                        ScaleRow.Value.Instance.Text,
                        function(Option)
                            local Number =
                                tonumber(
                                    tostring(Option):
                                    gsub("%%", "")
                                )
                                or 100

                            Window:SetMenuScale(
                                Number / 100
                            )
                        end
                    )
                end
            )

            StyleRow.Row:Connect(
                "MouseButton1Down",
                function()
                    OpenSubmenu(
                        "Style",
                        {
                            "Radiant Emerald",
                            "Deep Emerald",
                            "Matrix"
                        },
                        QuickState.Style,
                        function(Option)
                            QuickState.Style =
                                Option

                            StyleRow.Value.
                                Instance.Text =
                                Option

                            if type(
                                Data.StyleCallback
                            ) == "function"
                            then
                                Library:SafeCall(
                                    Data.StyleCallback,
                                    Option
                                )
                            end
                        end
                    )
                end
            )

            function Window:SetMenuScale(Value)
                QuickState.MenuScale =
                    math.clamp(
                        tonumber(Value) or 1,
                        0.65,
                        1.35
                    )

                local MenuScaleItem =
                    Items["MenuScale"]

                if MenuScaleItem
                    and MenuScaleItem.Instance
                then
                    MenuScaleItem.Instance.Scale =
                        QuickState.MenuScale
                end

                ScaleRow.Value.Instance.Text =
                    tostring(
                        math.floor(
                            QuickState.MenuScale
                            * 100
                            + 0.5
                        )
                    )
                    .. "%"
            end

            function Window:SetQuickOpen(Bool)
                QuickState.Open =
                    Bool == true

                if QuickState.Open then
                    Items["QuickPanel"].
                        Instance.Visible = true

                    Items["QuickPanel"].
                        Instance.GroupTransparency = 1

                    Items["QuickPanel"]:Tween(
                        QuickTween,
                        {
                            GroupTransparency = 0
                        }
                    )

                    Items["Gear"]:Tween(
                        QuickTween,
                        {
                            BackgroundTransparency =
                                0.28
                        }
                    )

                    Items["GearIcon"]:
                        SetTheme("Accent")
                else
                    CloseSubmenu()

                    Items["QuickPanel"]:Tween(
                        QuickTween,
                        {
                            GroupTransparency = 1
                        }
                    )

                    Items["Gear"]:Tween(
                        QuickTween,
                        {
                            BackgroundTransparency = 1
                        }
                    )

                    Items["GearIcon"]:
                        SetTheme("Muted Text")

                    task.delay(
                        0.12,
                        function()
                            if not QuickState.Open
                                and Items[
                                    "QuickPanel"
                                ].Instance
                                and Items[
                                    "QuickPanel"
                                ].Instance.Parent
                            then
                                Items[
                                    "QuickPanel"
                                ].Instance.Visible =
                                    false
                            end
                        end
                    )
                end
            end

            Items["Gear"]:OnHover(function()
                Items["Gear"]:Tween(
                    QuickTween,
                    {
                        BackgroundTransparency =
                            0.28
                    }
                )

                Items["GearIcon"]:
                    SetTheme(
                        QuickState.Open
                        and "Accent"
                        or "Text"
                    )
            end)

            Items["Gear"]:OnHoverLeave(function()
                if QuickState.Open then
                    return
                end

                Items["Gear"]:Tween(
                    QuickTween,
                    {
                        BackgroundTransparency = 1
                    }
                )

                Items["GearIcon"]:
                    SetTheme("Muted Text")
            end)

            Items["Gear"]:Connect(
                "MouseButton1Down",
                function()
                    Window:SetQuickOpen(
                        not QuickState.Open
                    )
                end
            )

            Library:Connect(
                UserInputService.InputBegan,
                function(Input)
                    if not QuickState.Open
                        or Input.UserInputType
                            ~= Enum.UserInputType.
                                MouseButton1
                    then
                        return
                    end

                    if Library:IsMouseOverFrame(
                        Items["QuickPanel"]
                    )
                        or Library:IsMouseOverFrame(
                            Items["QuickSubmenu"]
                        )
                        or Library:IsMouseOverFrame(
                            Items["Gear"]
                        )
                    then
                        return
                    end

                    Window:SetQuickOpen(false)
                end
            )

            Window.QuickSettings =
                QuickState

            Library.QuickSettingsWindow =
                Window

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Panel"].Instance,
                Name = string.char(0),
                Position = UDim2New(0, 8, 0, 34),
                Size = UDim2New(1, -16, 1, -42),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme["Page Background"],
                ClipsDescendants = true
            })
            Items["Content"]:AddToTheme({
                BackgroundColor3 = "Page Background"
            })
            Library:ApplyGlass(Items["Content"], "Panel", 2)
        end

        local DropdownDimToken = 0

        function Window:SetDropdownDim(Bool)
            Bool = Bool == true
            DropdownDimToken += 1

            local Token =
                DropdownDimToken

            local Dim =
                Items["DropdownDim"]
                and Items["DropdownDim"].Instance
                or nil

            if not Dim
                or not Dim.Parent
            then
                return
            end

            if Bool then
                Dim.Visible = true
                Dim.Active = true
                Dim.BackgroundTransparency = 1

                Items["DropdownDim"]:Tween(
                    TweenInfo.new(
                        0.14,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        BackgroundTransparency =
                            0.68
                    }
                )
            else
                Dim.Active = false

                Items["DropdownDim"]:Tween(
                    TweenInfo.new(
                        0.12,
                        Enum.EasingStyle.Quad,
                        Enum.EasingDirection.Out
                    ),
                    {
                        BackgroundTransparency = 1
                    }
                )

                task.delay(
                    0.12,
                    function()
                        if Token == DropdownDimToken
                            and Dim
                            and Dim.Parent
                            and Dim.BackgroundTransparency
                                >= 0.99
                        then
                            Dim.Visible = false
                        end
                    end
                )
            end
        end

        Items["DropdownDim"]:Connect(
            "MouseButton1Down",
            function()
                local OpenDropdown =
                    Library.OpenDropdown

                if OpenDropdown
                    and type(
                        OpenDropdown.SetOpen
                    ) == "function"
                then
                    OpenDropdown:SetOpen(false)
                else
                    Window:SetDropdownDim(false)
                end
            end
        )

        local Debounce = false

        function Window:SetOpen(
            Bool
        )
            Bool =
                Bool == true

            if Window.IsOpen
                == Bool
            then
                return
            end

            Window.IsOpen =
                Bool

            Library:SetGlassBlur(Bool)

            Window.AnimationToken =
                Window.AnimationToken
                + 1

            local AnimationToken =
                Window.AnimationToken

            local MainFrame =
                Items[
                    "MainFrame"
                ].Instance

            local Surface =
                Items[
                    "Surface"
                ].Instance

            local MenuScaleItem =
                Items["MenuScale"]

            local MenuScale =
                MenuScaleItem
                and MenuScaleItem.Instance
                or nil

            local AnimationInfo =
                TweenInfo.new(
                    Window.FadeSpeed,
                    Bool
                        and Enum.EasingStyle.Quint
                        or Enum.EasingStyle.Quad,
                    Bool
                        and Enum.EasingDirection.Out
                        or Enum.EasingDirection.In
                )

            if Bool then
                MainFrame.Visible =
                    true

                MainFrame.Active =
                    true

                Surface.Active = true

                Tween:Create(
                    Surface,
                    AnimationInfo,
                    {
                        GroupTransparency = 0
                    },
                    true
                )

                if MenuScale then
                    Tween:Create(
                        MenuScale,
                        AnimationInfo,
                        {
                            Scale =
                                QuickState.MenuScale
                        },
                        true
                    )
                end
            else
                MainFrame.Active =
                    false

                Surface.Active = false

                Tween:Create(
                    Surface,
                    AnimationInfo,
                    {
                        GroupTransparency = 1
                    },
                    true
                )

                if MenuScale then
                    Tween:Create(
                        MenuScale,
                        AnimationInfo,
                        {
                            Scale =
                                QuickState.MenuScale
                                * 0.965
                        },
                        true
                    )
                end

                Window:SetDropdownDim(false)

                if Library.OpenDropdown
                    and type(
                        Library.OpenDropdown.SetOpen
                    ) == "function"
                then
                    Library.OpenDropdown:
                        SetOpen(false)
                end

                if QuickState.Open then
                    Window:SetQuickOpen(false)
                end

                if Library.CurrentColorpicker then
                    Library.CurrentColorpicker:
                        SetOpen(
                            false
                        )
                end

                Library:Thread(function()
                    task.wait(
                        Window.FadeSpeed
                    )

                    if Window.AnimationToken
                            == AnimationToken
                        and not Window.IsOpen
                        and MainFrame.Parent
                    then
                        MainFrame.Visible =
                            false
                    end
                end)
            end
        end

        Library:Connect(
            UserInputService.InputBegan,
            function(
                Input,
                GameProcessed
            )
                if GameProcessed
                    and UserInputService:
                        GetFocusedTextBox()
                then
                    return
                end

                local MenuKey =
                    ResolveKey(
                        Library.MenuKeybind
                    )
                    or Library.MenuKeybind

                if InputMatchesKey(
                    Input,
                    MenuKey
                )
                then
                    Window:SetOpen(
                        not Window.IsOpen
                    )
                end
            end
        )

        Window.Elements = Items

        return setmetatable(Window, Library)
    end

    Library.CreateVectorIcon = function(
        self,
        Parent,
        IconName,
        Data
    )
        Data = Data or { }

        local Controller = {
            Theme = Data.Theme or "Muted Text",
            Parts = { },
            Instance = nil
        }

        local ParentInstance =
            Library:ResolveInstance(Parent)
            or Parent

        local Size =
            tonumber(Data.Size)
            or 16

        local Canvas =
            Instances:Create(
                "Frame",
                {
                    Parent = ParentInstance,
                    Name = string.char(0),
                    AnchorPoint =
                        Data.AnchorPoint
                        or Vector2New(0, 0.5),

                    Position =
                        Data.Position
                        or UDim2New(0, 6, 0.5, 0),

                    Size =
                        UDim2New(
                            0,
                            Size,
                            0,
                            Size
                        ),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    ZIndex = Data.ZIndex or 4
                }
            )

        Controller.Instance =
            Canvas.Instance

        local function Register(
            Object,
            Property
        )
            Object =
                Library:ResolveInstance(Object)
                or Object

            Library:AddToTheme(
                Object,
                {
                    [Property] =
                        Controller.Theme
                }
            )

            Controller.Parts[
                #Controller.Parts + 1
            ] = {
                Object = Object,
                Property = Property
            }

            return Object
        end

        local function Round(
            Object,
            Radius
        )
            Object =
                Library:ResolveInstance(Object)
                or Object

            local Corner =
                InstanceNew("UICorner")

            Corner.CornerRadius =
                UDimNew(
                    Radius == 1
                    and 1
                    or 0,
                    Radius == 1
                    and 0
                    or Radius or 1
                )

            Corner.Parent = Object
        end

        local function Line(
            X,
            Y,
            Width,
            Height,
            Rotation,
            Radius
        )
            local Object =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Canvas.Instance,

                        Name = string.char(0),

                        Position =
                            UDim2New(
                                0,
                                X,
                                0,
                                Y
                            ),

                        Size =
                            UDim2New(
                                0,
                                Width,
                                0,
                                Height
                            ),

                        BorderSizePixel = 0,
                        BackgroundColor3 =
                            Library.Theme[
                                Controller.Theme
                            ],

                        Rotation =
                            Rotation or 0,

                        ZIndex =
                            (Data.ZIndex or 4) + 1
                    }
                )

            Register(
                Object,
                "BackgroundColor3"
            )

            Round(
                Object,
                Radius or 1
            )

            return Object
        end

        local function Outline(
            X,
            Y,
            Width,
            Height,
            Radius,
            Thickness
        )
            local Object =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Canvas.Instance,

                        Name = string.char(0),

                        Position =
                            UDim2New(
                                0,
                                X,
                                0,
                                Y
                            ),

                        Size =
                            UDim2New(
                                0,
                                Width,
                                0,
                                Height
                            ),

                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,

                        ZIndex =
                            (Data.ZIndex or 4) + 1
                    }
                )

            Round(
                Object,
                Radius or 2
            )

            local Stroke =
                InstanceNew("UIStroke")

            Stroke.ApplyStrokeMode =
                Enum.ApplyStrokeMode.Border

            Stroke.LineJoinMode =
                Enum.LineJoinMode.Round

            Stroke.Thickness =
                Thickness or 1.2

            Stroke.Parent =
                Object.Instance

            Register(
                Stroke,
                "Color"
            )

            return Object
        end

        local function Circle(
            X,
            Y,
            Diameter,
            Filled,
            Thickness
        )
            if Filled then
                return Line(
                    X,
                    Y,
                    Diameter,
                    Diameter,
                    0,
                    1
                )
            end

            return Outline(
                X,
                Y,
                Diameter,
                Diameter,
                1,
                Thickness or 1.2
            )
        end

        local Name =
            string.lower(
                tostring(
                    IconName
                    or "dot"
                )
            )

        if Name == "aimtab"
            or Name == "reticle"
        then
            Line(1.6, 4.2, 1.2, 4.0, 0, 1)
            Line(1.6, 3.8, 4.0, 1.2, 0, 1)
            Line(10.4, 3.8, 4.0, 1.2, 0, 1)
            Line(13.2, 4.2, 1.2, 4.0, 0, 1)
            Line(1.6, 10.6, 1.2, 4.0, 0, 1)
            Line(1.6, 13.4, 4.0, 1.2, 0, 1)
            Line(10.4, 13.4, 4.0, 1.2, 0, 1)
            Line(13.2, 10.6, 1.2, 4.0, 0, 1)
            Circle(6.0, 6.0, 4.0, false, 1.15)
            Circle(7.0, 7.0, 2.0, true)
        elseif Name == "crosshair"
            or Name == "aim"
        then
            Circle(4, 4, 8, false, 1.2)
            Circle(6.8, 6.8, 2.4, true)
            Line(7.4, 0.5, 1.2, 3.0, 0, 1)
            Line(7.4, 12.5, 1.2, 3.0, 0, 1)
            Line(0.5, 7.4, 3.0, 1.2, 0, 1)
            Line(12.5, 7.4, 3.0, 1.2, 0, 1)
        elseif Name == "weapon"
            or Name == "gun"
        then
            Line(2, 5.5, 9.5, 2.6, 0, 1)
            Line(11.5, 6, 3.4, 1.3, 0, 1)
            Line(5.2, 8.2, 4.4, 1.3, 0, 1)
            Line(7.2, 8.0, 2.2, 5.4, -18, 1)
            Line(2.5, 4.7, 3.0, 1.1, 0, 1)
        elseif Name == "eye"
            or Name == "esp"
        then
            Outline(1.2, 4.5, 13.6, 7.0, 4, 1.2)
            Circle(5.1, 4.8, 5.8, false, 1.2)
            Circle(7.0, 6.7, 2.1, true)
        elseif Name == "sparkles"
            or Name == "effects"
        then
            Line(7.35, 1.0, 1.3, 9.5, 0, 1)
            Line(3.0, 5.1, 10.0, 1.3, 0, 1)
            Line(5.0, 2.8, 1.2, 5.8, 45, 1)
            Line(9.8, 2.8, 1.2, 5.8, -45, 1)
            Circle(11.8, 11.8, 2.2, true)
        elseif Name == "user"
            or Name == "local"
        then
            Circle(5.0, 1.5, 6.0, false, 1.2)
            Outline(2.8, 9.0, 10.4, 5.5, 4, 1.2)
        elseif Name == "move"
            or Name == "movement"
        then
            Line(7.4, 2.0, 1.2, 11.5, 0, 1)
            Line(2.0, 7.4, 11.5, 1.2, 0, 1)
            Line(5.2, 2.0, 3.8, 1.1, -45, 1)
            Line(7.6, 2.0, 3.8, 1.1, 45, 1)
            Line(10.6, 12.6, 3.8, 1.1, -45, 1)
            Line(8.2, 12.6, 3.8, 1.1, 45, 1)
            Line(2.1, 5.1, 3.6, 1.1, 45, 1)
            Line(2.1, 9.7, 3.6, 1.1, -45, 1)
        elseif Name == "camera" then
            Outline(1.2, 4.0, 13.5, 9.4, 2, 1.2)
            Outline(5.0, 6.0, 5.0, 5.0, 1, 1.2)
            Line(4.0, 2.2, 4.5, 1.8, 0, 1)
            Circle(10.8, 6.0, 1.7, true)
        elseif Name == "sun" or Name == "lighting" then
            Circle(4.8, 4.8, 6.4, false, 1.2)
            Line(7.4, 0.4, 1.2, 2.6, 0, 1)
            Line(7.4, 13.0, 1.2, 2.6, 0, 1)
            Line(0.4, 7.4, 2.6, 1.2, 0, 1)
            Line(13.0, 7.4, 2.6, 1.2, 0, 1)
            Line(2.2, 2.2, 3.0, 1.1, 45, 1)
            Line(10.8, 2.2, 3.0, 1.1, -45, 1)
            Line(2.2, 12.2, 3.0, 1.1, -45, 1)
            Line(10.8, 12.2, 3.0, 1.1, 45, 1)
        elseif Name == "cube" or Name == "world" then
            Circle(2.0, 2.0, 12.0, false, 1.2)
            Line(7.4, 2.4, 1.2, 11.2, 0, 1)
            Line(2.3, 7.4, 11.0, 1.2, 0, 1)
            Outline(4.7, 2.2, 6.6, 11.6, 1, 1.0)
        elseif Name == "briefcase" or Name == "farm" then
            Outline(1.2, 5.2, 13.6, 8.8, 2, 1.2)
            Outline(5.0, 2.2, 5.0, 3.6, 2, 1.2)
            Line(1.5, 8.4, 13.0, 1.2, 0, 1)
            Line(7.0, 7.2, 2.0, 2.6, 0, 1)
        elseif Name == "tool" or Name == "wrench" then
            Line(4.4, 9.3, 9.0, 1.8, -45, 1)
            Circle(1.1, 10.1, 4.5, false, 1.2)
            Circle(10.3, 1.2, 4.5, false, 1.2)
        elseif Name == "sliders" or Name == "interface" then
            Line(1.0, 3.0, 14.0, 1.2, 0, 1)
            Line(1.0, 8.0, 14.0, 1.2, 0, 1)
            Line(1.0, 13.0, 14.0, 1.2, 0, 1)
            Circle(3.0, 1.2, 4.2, true)
            Circle(9.5, 6.2, 4.2, true)
            Circle(6.0, 11.2, 4.2, true)
        elseif Name == "file" or Name == "configs" then
            Outline(3.0, 1.2, 10.0, 13.8, 2, 1.2)
            Line(9.0, 1.2, 4.0, 1.1, 45, 1)
            Line(5.4, 6.2, 4.8, 1.0, 0, 1)
            Line(5.4, 9.0, 4.8, 1.0, 0, 1)
            Line(5.4, 11.8, 3.0, 1.0, 0, 1)
        elseif Name == "gear" or Name == "settings" then
            Circle(4.4, 4.4, 7.2, false, 1.2)
            Circle(6.7, 6.7, 2.6, true)
            Line(7.6, 0.0, 0.9, 2.5, 0, 1)
            Line(7.6, 13.5, 0.9, 2.5, 0, 1)
            Line(0.0, 7.6, 2.5, 0.9, 0, 1)
            Line(13.5, 7.6, 2.5, 0.9, 0, 1)
            Line(2.3, 2.3, 2.1, 0.9, 45, 1)
            Line(11.6, 2.3, 2.1, 0.9, -45, 1)
            Line(2.3, 13.0, 2.1, 0.9, -45, 1)
            Line(11.6, 13.0, 2.1, 0.9, 45, 1)
        elseif Name == "list" then
            Circle(1.4, 2.2, 2.1, true)
            Circle(1.4, 6.9, 2.1, true)
            Circle(1.4, 11.6, 2.1, true)
            Line(5.0, 2.8, 9.0, 1.0, 0, 1)
            Line(5.0, 7.5, 9.0, 1.0, 0, 1)
            Line(5.0, 12.2, 9.0, 1.0, 0, 1)
        elseif Name == "pin" then
            Circle(4.5, 1.5, 6.0, false, 1.2)
            Line(7.2, 5.8, 1.4, 6.0, 0, 1)
            Line(4.7, 5.2, 6.2, 1.2, 0, 1)
            Line(6.4, 11.0, 3.5, 1.0, -45, 1)
        elseif Name == "palette" then
            Circle(2.0, 2.0, 12.0, false, 1.2)
            Circle(4.2, 4.2, 1.8, true)
            Circle(8.3, 3.5, 1.8, true)
            Circle(10.0, 7.0, 1.8, true)
            Circle(5.2, 9.4, 1.8, true)
        elseif Name == "eyeoff" then
            Outline(1.2, 4.5, 13.6, 7.0, 4, 1.2)
            Circle(5.2, 5.0, 5.6, false, 1.2)
            Line(2.0, 13.0, 12.5, 1.1, -45, 1)
        elseif Name == "belloff" then
            Outline(4.2, 2.2, 7.6, 9.8, 4, 1.2)
            Line(3.2, 11.4, 9.6, 1.1, 0, 1)
            Line(7.0, 13.0, 2.0, 1.8, 0, 1)
            Line(2.0, 13.0, 12.5, 1.1, -45, 1)
        else
            Circle(6.0, 6.0, 4.0, true)
        end

        function Controller:SetTheme(Theme)
            if not Library.Theme[Theme] then
                return
            end

            Controller.Theme = Theme

            for _,
                Part in ipairs(
                    Controller.Parts
                )
            do
                Library:ChangeItemTheme(
                    Part.Object,
                    {
                        [Part.Property] = Theme
                    }
                )

                Part.Object[
                    Part.Property
                ] = Library.Theme[Theme]
            end
        end

        function Controller:SetVisible(Bool)
            Canvas.Instance.Visible =
                Bool == true
        end

        return Controller
    end

    Library.Page = function(self, Data)
        Data = Data or { }

        local Page = {
            Window = self,
            Name = Data.Name or Data.name or "Page",
            Columns = Data.Columns or Data.columns or 2,
            HasSubtabs = Data.Subtabs or Data.subtabs or false,
            Active = false,
            AnimationToken = 0,
            ColumnsData = { },
            SubPages = { },
            Elements = { }
        }

        local Items = { } do
            Items["Inactive"] =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Page.Window.
                            Elements["Pages"].
                            Instance,

                        FontFace = Library.Font,
                        Text = "",
                        AutoButtonColor = false,
                        Name = string.char(0),
                        Size = UDim2New(1, 0, 0, 30),
                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1
                    }
                )

            Items["Inactive"]:AddToTheme({
                BackgroundColor3 = "Element"
            })

            Library:ApplyGlass(
                Items["Inactive"],
                "Element",
                4
            )

            Items["Accent"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Items["Inactive"].
                            Instance,

                        Name = string.char(0),
                        AnchorPoint =
                            Vector2New(0, 0.5),

                        Position =
                            UDim2New(0, 6, 0.5, 0),

                        Size =
                            UDim2New(0, 2, 0, 14),

                        BorderSizePixel = 0,
                        BackgroundColor3 =
                            Library.Theme.Accent,

                        BackgroundTransparency = 1,
                        ZIndex = 3
                    }
                )

            Items["Accent"]:AddToTheme({
                BackgroundColor3 = "Accent"
            })

            Items["Text"] =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            Items["Inactive"].
                            Instance,

                        FontFace = Library.Font,

                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],

                        Text = Page.Name,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 14, 0, 0),

                        Size =
                            UDim2New(1, -22, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        BorderSizePixel = 0,
                        TextSize = 11
                    }
                )

            Items["Text"]:AddToTheme({
                TextColor3 = "Muted Text"
            })

            Items["Page"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Page.Window.
                            Elements["Content"].
                            Instance,

                        BackgroundTransparency = 1,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 0, 0, 0),

                        Size =
                            UDim2New(1, 0, 1, 0),

                        BorderSizePixel = 0,
                        Visible = false,
                        ClipsDescendants = true
                    }
                )

            if not Page.HasSubtabs then
                Instances:Create(
                    "UIListLayout",
                    {
                        Parent =
                            Items["Page"].Instance,

                        FillDirection =
                            Enum.FillDirection.Horizontal,

                        HorizontalFlex =
                            Enum.UIFlexAlignment.Fill,

                        SortOrder =
                            Enum.SortOrder.LayoutOrder,

                        VerticalFlex =
                            Enum.UIFlexAlignment.Fill,

                        Padding =
                            UDimNew(0, 6)
                    }
                )

                for Index = 1, Page.Columns do
                    local NewColumn =
                        Instances:Create(
                            "ScrollingFrame",
                            {
                                Parent =
                                    Items["Page"].
                                    Instance,

                                ScrollBarImageColor3 =
                                    Library.Theme.Accent,

                                Active = true,

                                AutomaticCanvasSize =
                                    Enum.AutomaticSize.Y,

                                ScrollBarThickness = 2,

                                VerticalScrollBarInset =
                                    Enum.ScrollBarInset.
                                    ScrollBar,

                                ScrollingDirection =
                                    Enum.ScrollingDirection.Y,

                                ElasticBehavior =
                                    Enum.ElasticBehavior.Never,

                                Name = string.char(0),

                                BackgroundTransparency = 1,

                                Size =
                                    UDim2New(
                                        0,
                                        100,
                                        0,
                                        100
                                    ),

                                BorderSizePixel = 0,
                                ClipsDescendants = true,

                                BottomImage =
                                    Library:
                                    GetImage("Scrollbar"),

                                MidImage =
                                    Library:
                                    GetImage("Scrollbar"),

                                TopImage =
                                    Library:
                                    GetImage("Scrollbar"),

                                CanvasSize =
                                    UDim2New(0, 0, 0, 0)
                            }
                        )

                    NewColumn:AddToTheme({
                        ScrollBarImageColor3 =
                            "Accent"
                    })

                    Instances:Create(
                        "UIPadding",
                        {
                            Parent =
                                NewColumn.Instance,

                            PaddingTop =
                                UDimNew(0, 7),

                            PaddingBottom =
                                UDimNew(0, 7),

                            PaddingRight =
                                UDimNew(0, 9),

                            PaddingLeft =
                                UDimNew(0, 7)
                        }
                    )

                    Instances:Create(
                        "UIListLayout",
                        {
                            Parent =
                                NewColumn.Instance,

                            Padding =
                                UDimNew(0, 7),

                            SortOrder =
                                Enum.SortOrder.LayoutOrder
                        }
                    )

                    Page.ColumnsData[Index] =
                        NewColumn
                end
            else
                Items["SubTabs"] =
                    Instances:Create(
                        "Frame",
                        {
                            Parent =
                                Items["Page"].
                                Instance,

                            Name = string.char(0),

                            BackgroundTransparency = 1,

                            Position =
                                UDim2New(0, 7, 0, 7),

                            Size =
                                UDim2New(1, -14, 0, 32),

                            BorderSizePixel = 0,
                            ClipsDescendants = true
                        }
                    )

                Instances:Create(
                    "UIListLayout",
                    {
                        Parent =
                            Items["SubTabs"].
                            Instance,

                        FillDirection =
                            Enum.FillDirection.Horizontal,

                        HorizontalFlex =
                            Enum.UIFlexAlignment.Fill,

                        Padding =
                            UDimNew(0, 5),

                        SortOrder =
                            Enum.SortOrder.LayoutOrder
                    }
                )

                Items["Columns"] =
                    Instances:Create(
                        "Frame",
                        {
                            Parent =
                                Items["Page"].
                                Instance,

                            Name = string.char(0),

                            Position =
                                UDim2New(0, 0, 0, 44),

                            Size =
                                UDim2New(1, 0, 1, -44),

                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            ClipsDescendants = true
                        }
                    )
            end

            Items["Transition"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Items["Page"].
                            Instance,

                        Name = string.char(0),

                        Position =
                            UDim2New(0, 0, 0, 0),

                        Size =
                            UDim2New(1, 0, 1, 0),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme[
                                "Page Background"
                            ],

                        BackgroundTransparency = 1,

                        Visible = false,
                        Active = false,
                        ZIndex = 500
                    }
                )

            Items["Transition"]:AddToTheme({
                BackgroundColor3 =
                    "Page Background"
            })
        end

        local PageTween =
            TweenInfo.new(
                0.13,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )

        function Page:Turn(Bool)
            Bool = Bool == true
            Page.Active = Bool
            Page.AnimationToken += 1

            local Token =
                Page.AnimationToken

            if Bool then
                Items["Page"].Instance.Visible = true
                Items["Page"].Instance.Position =
                    UDim2New(0, 4, 0, 0)

                Items["Transition"].Instance.Visible = true
                Items["Transition"].Instance.
                    BackgroundTransparency = 0.78

                Items["Page"]:Tween(
                    PageTween,
                    {
                        Position =
                            UDim2New(0, 0, 0, 0)
                    }
                )

                Items["Transition"]:Tween(
                    PageTween,
                    {
                        BackgroundTransparency = 1
                    }
                )

                task.delay(
                    0.13,
                    function()
                        if Token == Page.AnimationToken
                            and Page.Active
                            and Items["Transition"].
                                Instance
                            and Items["Transition"].
                                Instance.Parent
                        then
                            Items["Transition"].
                                Instance.Visible = false
                        end
                    end
                )
            else
                Items["Page"].Instance.Visible = false
                Items["Transition"].Instance.Visible = false
            end

            Items["Inactive"]:Tween(
                PageTween,
                {
                    BackgroundTransparency =
                        Bool and 0.12 or 1,

                    BackgroundColor3 =
                        Bool
                        and Library.Theme[
                            "Hovered Element"
                        ]
                        or Library.Theme.Element
                }
            )

            Items["Accent"]:Tween(
                PageTween,
                {
                    BackgroundTransparency =
                        Bool and 0 or 1,

                    Size =
                        Bool
                        and UDim2New(0, 2, 0, 18)
                        or UDim2New(0, 2, 0, 14)
                }
            )

            Items["Text"]:Tween(
                PageTween,
                {
                    TextColor3 =
                        Bool
                        and Library.Theme.Text
                        or Library.Theme[
                            "Muted Text"
                        ],

                    TextTransparency =
                        Bool and 0 or 0.06
                }
            )

            Items["Text"]:ChangeItemTheme({
                TextColor3 =
                    Bool
                    and "Text"
                    or "Muted Text"
            })
        end

        Items["Inactive"]:OnHover(function()
            if Page.Active then
                return
            end

            Items["Inactive"]:Tween(
                PageTween,
                {
                    BackgroundTransparency = 0.35,

                    BackgroundColor3 =
                        Library.Theme[
                            "Hovered Element"
                        ]
                }
            )

            Items["Text"]:Tween(
                PageTween,
                {
                    TextColor3 =
                        Library.Theme.Text,

                    TextTransparency = 0
                }
            )
        end)

        Items["Inactive"]:OnHoverLeave(function()
            if Page.Active then
                return
            end

            Items["Inactive"]:Tween(
                PageTween,
                {
                    BackgroundTransparency = 1,

                    BackgroundColor3 =
                        Library.Theme.Element
                }
            )

            Items["Text"]:Tween(
                PageTween,
                {
                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    TextTransparency = 0.04
                }
            )
        end)

        Items["Inactive"]:Connect(
            "MouseButton1Down",
            function()
                for _,
                    Value in Page.Window.Pages
                do
                    Value:Turn(
                        Value == Page
                    )
                end
            end
        )

        if #Page.Window.Pages == 0 then
            Page:Turn(true)
        end

        Page.Elements = Items

        TableInsert(
            Page.Window.Pages,
            Page
        )

        return setmetatable(
            Page,
            Library.Pages
        )
    end

    Library.Pages.SubPage = function(self, Data)
        Data = Data or { }

        local Name =
            Data.Name
            or Data.name
            or "Section"

        local Icon =
            Data.Icon
            or Data.icon
            or string.sub(Name, 1, 1)

        local SubPage = {
            Window = self.Window,
            Page = self,
            Name = Name,
            Icon = tostring(Icon),
            Columns = Data.Columns or Data.columns or 2,
            Active = false,
            AnimationToken = 0,
            ColumnsData = { },
            Elements = { }
        }

        local Items = { } do
            Items["Inactive"] =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            SubPage.Page.
                            Elements["SubTabs"].
                            Instance,

                        FontFace = Library.Font,
                        Text = "",
                        AutoButtonColor = false,
                        Name = string.char(0),

                        Size =
                            UDim2New(1, 0, 1, 0),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1
                    }
                )

            Items["Inactive"]:AddToTheme({
                BackgroundColor3 = "Element"
            })

            Library:ApplyGlass(
                Items["Inactive"],
                "Element",
                4
            )

            Items["Icon"] =
                Library:CreateVectorIcon(
                    Items["Inactive"],
                    SubPage.Icon,
                    {
                        Size = 17,
                        Position =
                            UDim2New(
                                0,
                                8,
                                0.5,
                                0
                            ),

                        AnchorPoint =
                            Vector2New(0, 0.5),

                        Theme = "Muted Text",
                        ZIndex = 5
                    }
                )

            Items["Text"] =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            Items["Inactive"].
                            Instance,

                        FontFace = Library.Font,

                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],

                        Text = SubPage.Name,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 28, 0, 0),

                        Size =
                            UDim2New(1, -34, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        TextTruncate =
                            Enum.TextTruncate.AtEnd,

                        BorderSizePixel = 0,
                        TextSize = 10
                    }
                )

            Items["Text"]:AddToTheme({
                TextColor3 = "Muted Text"
            })

            Items["Subtab"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            SubPage.Page.
                            Elements["Columns"].
                            Instance,

                        BackgroundTransparency = 1,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 0, 0, 0),

                        Size =
                            UDim2New(1, 0, 1, 0),

                        BorderSizePixel = 0,
                        Visible = false,
                        ClipsDescendants = true
                    }
                )

            Instances:Create(
                "UIListLayout",
                {
                    Parent =
                        Items["Subtab"].
                        Instance,

                    FillDirection =
                        Enum.FillDirection.Horizontal,

                    HorizontalFlex =
                        Enum.UIFlexAlignment.Fill,

                    SortOrder =
                        Enum.SortOrder.LayoutOrder,

                    VerticalFlex =
                        Enum.UIFlexAlignment.Fill,

                    Padding =
                        UDimNew(0, 6)
                }
            )

            for Index = 1, SubPage.Columns do
                local NewColumn =
                    Instances:Create(
                        "ScrollingFrame",
                        {
                            Parent =
                                Items["Subtab"].
                                Instance,

                            ScrollBarImageColor3 =
                                Library.Theme.Accent,

                            Active = true,

                            AutomaticCanvasSize =
                                Enum.AutomaticSize.Y,

                            ScrollBarThickness = 2,

                            VerticalScrollBarInset =
                                Enum.ScrollBarInset.
                                ScrollBar,

                            ScrollingDirection =
                                Enum.ScrollingDirection.Y,

                            ElasticBehavior =
                                Enum.ElasticBehavior.Never,

                            Name = string.char(0),

                            BackgroundTransparency = 1,

                            Size =
                                UDim2New(
                                    0,
                                    100,
                                    0,
                                    100
                                ),

                            BorderSizePixel = 0,
                            ClipsDescendants = true,

                            BottomImage =
                                Library:
                                GetImage("Scrollbar"),

                            MidImage =
                                Library:
                                GetImage("Scrollbar"),

                            TopImage =
                                Library:
                                GetImage("Scrollbar"),

                            CanvasSize =
                                UDim2New(0, 0, 0, 0)
                        }
                    )

                NewColumn:AddToTheme({
                    ScrollBarImageColor3 =
                        "Accent"
                })

                Instances:Create(
                    "UIPadding",
                    {
                        Parent =
                            NewColumn.Instance,

                        PaddingTop =
                            UDimNew(0, 7),

                        PaddingBottom =
                            UDimNew(0, 7),

                        PaddingRight =
                            UDimNew(0, 9),

                        PaddingLeft =
                            UDimNew(0, 7)
                    }
                )

                Instances:Create(
                    "UIListLayout",
                    {
                        Parent =
                            NewColumn.Instance,

                        Padding =
                            UDimNew(0, 7),

                        SortOrder =
                            Enum.SortOrder.LayoutOrder
                    }
                )

                SubPage.ColumnsData[Index] =
                    NewColumn
            end

            Items["Transition"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            SubPage.Page.
                            Elements["Columns"].
                            Instance,

                        Name = string.char(0),

                        Position =
                            UDim2New(0, 0, 0, 0),

                        Size =
                            UDim2New(1, 0, 1, 0),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme[
                                "Page Background"
                            ],

                        BackgroundTransparency = 1,

                        Visible = false,
                        Active = false,
                        ZIndex = 500
                    }
                )

            Items["Transition"]:AddToTheme({
                BackgroundColor3 =
                    "Page Background"
            })
        end

        local SubTween =
            TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quint,
                Enum.EasingDirection.Out
            )

        function SubPage:Turn(Bool)
            Bool = Bool == true
            SubPage.Active = Bool
            SubPage.AnimationToken += 1

            local Token =
                SubPage.AnimationToken

            if Bool then
                Items["Subtab"].Instance.Visible = true
                Items["Subtab"].Instance.Position =
                    UDim2New(0, 4, 0, 0)

                Items["Transition"].Instance.Visible = true
                Items["Transition"].Instance.
                    BackgroundTransparency = 0.80

                Items["Subtab"]:Tween(
                    SubTween,
                    {
                        Position =
                            UDim2New(0, 0, 0, 0)
                    }
                )

                Items["Transition"]:Tween(
                    SubTween,
                    {
                        BackgroundTransparency = 1
                    }
                )

                task.delay(
                    0.12,
                    function()
                        if Token
                                == SubPage.
                                    AnimationToken
                            and SubPage.Active
                            and Items["Transition"].
                                Instance
                            and Items["Transition"].
                                Instance.Parent
                        then
                            Items["Transition"].
                                Instance.Visible = false
                        end
                    end
                )
            else
                Items["Subtab"].Instance.Visible = false
                Items["Transition"].Instance.Visible = false
            end

            Items["Inactive"]:Tween(
                SubTween,
                {
                    BackgroundTransparency =
                        Bool and 0.18 or 1
                }
            )

            Items["Icon"]:SetTheme(
                Bool
                and "Accent"
                or "Muted Text"
            )

            Items["Text"]:Tween(
                SubTween,
                {
                    TextColor3 =
                        Bool
                        and Library.Theme.Text
                        or Library.Theme[
                            "Muted Text"
                        ],

                    TextTransparency =
                        Bool and 0 or 0.08
                }
            )

            Items["Text"]:ChangeItemTheme({
                TextColor3 =
                    Bool
                    and "Text"
                    or "Muted Text"
            })
        end

        Items["Inactive"]:OnHover(function()
            if SubPage.Active then
                return
            end

            Items["Inactive"]:Tween(
                SubTween,
                {
                    BackgroundTransparency = 0.45,

                    BackgroundColor3 =
                        Library.Theme[
                            "Hovered Element"
                        ]
                }
            )

            Items["Icon"]:SetTheme("Text")

            Items["Text"]:Tween(
                SubTween,
                {
                    TextColor3 =
                        Library.Theme.Text,

                    TextTransparency = 0
                }
            )
        end)

        Items["Inactive"]:OnHoverLeave(function()
            if SubPage.Active then
                return
            end

            Items["Inactive"]:Tween(
                SubTween,
                {
                    BackgroundTransparency = 1,

                    BackgroundColor3 =
                        Library.Theme.Element
                }
            )

            Items["Icon"]:SetTheme(
                "Muted Text"
            )

            Items["Text"]:Tween(
                SubTween,
                {
                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    TextTransparency = 0.08
                }
            )
        end)

        Items["Inactive"]:Connect(
            "MouseButton1Down",
            function()
                for _,
                    Value in SubPage.Page.SubPages
                do
                    Value:Turn(
                        Value == SubPage
                    )
                end
            end
        )

        if #SubPage.Page.SubPages == 0 then
            SubPage:Turn(true)
        end

        SubPage.Elements = Items

        TableInsert(
            SubPage.Page.SubPages,
            SubPage
        )

        TableInsert(
            SubPage.Window.SubPages,
            SubPage
        )

        return setmetatable(
            SubPage,
            Library.Pages
        )
    end

    Library.Pages.Section = function(self, Data)
        Data = Data or { }

        local Section = {
            Window = self.Window,
            Page = self,
            Name = Data.Name or Data.name or "Section",
            Side = Data.Side or Data.side or 1,
            Elements = { }
        }

        local Items = { } do
            Items["Section"] = Instances:Create("Frame", {
                Parent = Section.Page.ColumnsData[Section.Side].Instance,
                Name = string.char(0),
                Size = UDim2New(1, -1, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ClipsDescendants = false
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Section"].Instance,
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                TextTransparency = 0.02,
                Text = Section.Name,
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(1, 0, 0, 14),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                TextSize = 11
            })
            Items["Title"]:AddToTheme({
                TextColor3 = "Text"
            })

            Items["Separator"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 16),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Outline,
                BackgroundTransparency = 0.58
            })
            Items["Separator"]:AddToTheme({
                BackgroundColor3 = "Outline"
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                BackgroundTransparency = 1,
                Name = string.char(0),
                Position = UDim2New(0, 0, 0, 22),
                Size = UDim2New(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                ClipsDescendants = false
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })


            Instances:Create("UIPadding", {
                Parent = Items["Content"].Instance,
                PaddingLeft = UDimNew(0, 1),
                PaddingRight = UDimNew(0, 3)
            })

            Instances:Create("UIPadding", {
                Parent = Items["Section"].Instance,
                PaddingBottom = UDimNew(0, 7)
            })
        end

        Section.Elements = Items
        return setmetatable(Section, Library.Sections)
    end

    Library.Pages.MultiSection = function(self, Data)
        local MultiSection = {
            Window = self.Window,
            Page = self,

            Sections = Data.Sections or Data.sections or { "Section 1", "Section 2", "Section 3" },
            Side = Data.Side or Data.side or 1,

            SectionContents = { },

            Elements = { }
        }

        local Items = { } do
            Items["MultiSection"] = Instances:Create("Frame", {
                Parent = MultiSection.Page.ColumnsData[MultiSection.Side].Instance,
                Name = string.char(0),
                Size = UDim2New(1, 0, 0, 25),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["MultiSection"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["MultiSection"].Instance,
                Color = FromRGB(10, 10, 10),
                Name = string.char(0),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["MultiSection"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Sections"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = string.char(0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 9),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -14, 0, 19),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Sections"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDimNew(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = string.char(0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 35),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, -14, 1, -33),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })
        end

        for Index, Value in MultiSection.Sections do
            local NewSection = {
                Window = MultiSection.Window,
                Page = MultiSection.Page,
                MultiSection = MultiSection,

                Name = Value,

                Elements = { },

                Active = false,
            }

            local SubItems = { } do
                SubItems["Inactive"] = Instances:Create("TextButton", {
                    Parent = Items["Sections"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(0, 0, 0),
                    BorderColor3 = FromRGB(10, 10, 10),
                    Text = "",
                    AutoButtonColor = false,
                    Name = string.char(0),
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 2,
                    TextSize = 14,
                    BackgroundColor3 = FromRGB(30, 30, 35)
                })  SubItems["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

                SubItems["Text"] = Instances:Create("TextLabel", {
                    Parent = SubItems["Inactive"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = FromRGB(215, 215, 215),
                    TextTransparency = 0.48,
                    Text = NewSection.Name,
                    Name = string.char(0),
                    Size = UDim2New(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 0, 0, -1),
                    BorderSizePixel = 0,
                    BorderColor3 = FromRGB(0, 0, 0),
                    TextSize = 13,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })  SubItems["Text"]:AddToTheme({TextColor3 = "Text"})

                Instances:Create("UIStroke", {
                    Parent = SubItems["Text"].Instance,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = string.char(0)
                }):AddToTheme({Color = "Text Border"})

                SubItems["Hide"] = Instances:Create("Frame", {
                    Parent = SubItems["Inactive"].Instance,
                    Visible = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 1),
                    Name = string.char(0),
                    Position = UDim2New(0, 0, 1, 0),
                    Size = UDim2New(1, 0, 0, 3),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(15, 15, 20)
                })  SubItems["Hide"]:AddToTheme({BackgroundColor3 = "Background"})

                SubItems["MiscPixel1"] = Instances:Create("Frame", {
                    Parent = SubItems["Hide"].Instance,
                    Size = UDim2New(0, 1, 0, 1),
                    Name = string.char(0),
                    Position = UDim2New(0, -1, 0, 1),
                    BorderColor3 = FromRGB(0, 0, 0),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 27, 32)
                })  SubItems["MiscPixel1"]:AddToTheme({BackgroundColor3 = "Outline"})

                SubItems["MiscPixel2"] = Instances:Create("Frame", {
                    Parent = SubItems["Hide"].Instance,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(1, 0),
                    Name = string.char(0),
                    Position = UDim2New(1, 1, 0, 1),
                    Size = UDim2New(0, 1, 0, 1),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(27, 27, 32)
                })  SubItems["MiscPixel2"]:AddToTheme({BackgroundColor3 = "Outline"})

                Instances:Create("UIStroke", {
                    Parent = SubItems["Inactive"].Instance,
                    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                    LineJoinMode = Enum.LineJoinMode.Miter,
                    Name = string.char(0),
                    Color = FromRGB(27, 27, 32)
                }):AddToTheme({Color = "Outline"})

                Instances:Create("UIGradient", {
                    Parent = SubItems["Inactive"].Instance,
                    Rotation = 90,
                    Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(108, 108, 108))}
                })

                SubItems["Content"] = Instances:Create("Frame", {
                    Parent = Items["Content"].Instance,
                    BackgroundTransparency = 1,
                    Name = string.char(0),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    Visible = false,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = SubItems["Content"].Instance,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end

            local Debounce = false

            function NewSection:Turn(
                Bool
            )
                Bool =
                    Bool == true

                NewSection.Active =
                    Bool

                SubItems[
                    "Content"
                ].Instance.Visible =
                    Bool

                SubItems[
                    "Text"
                ].Instance.TextColor3 =
                    Bool
                    and Library.Theme.Accent
                    or Library.Theme.Text

                SubItems[
                    "Text"
                ].Instance.TextTransparency =
                    Bool
                    and 0
                    or 0.5

                SubItems[
                    "Text"
                ]:
                    ChangeItemTheme({
                        TextColor3 =
                            Bool
                            and "Accent"
                            or "Text"
                    })
            end

            SubItems["Inactive"]:Connect("MouseButton1Down", function()
                for Index, Value in MultiSection.SectionContents do
                    Value:Turn(Value == NewSection)
                end
            end)

            if #MultiSection.SectionContents == 0 then
                NewSection:Turn(true)
            end

            NewSection.Elements = SubItems

            MultiSection.SectionContents[#MultiSection.SectionContents+1] = setmetatable(NewSection, Library.Sections)
        end

        MultiSection.SectionContents[1]:Turn(true)
        MultiSection.Window.Sections[#MultiSection.Window.Sections+1] = MultiSection
        return TableUnpack(MultiSection.SectionContents)
    end

    Library.Pages.ScrollableSection = function(self, Data)
        Data = Data or { }

        local Section = {
            Window = self.Window,
            Page = self,

            Name = Data.Name or Data.name or "Section",
            Side = Data.Side or Data.side or 1,
            Size = Data.Size or Data.size or 175,

            Elements = { }
        }

        local Items = { } do
            Items["Section"] = Instances:Create("Frame", {
                Parent = Section.Page.ColumnsData[Section.Side].Instance,
                Name = string.char(0),
                Size = UDim2New(1, 0, 0, Section.Size),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})
            Library:ApplyGlass(Items["Section"], "Panel", 4)

            Items["Fade"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 20),
                AnchorPoint = Vector2New(0, 1),
                Position = UDim2New(0, 0, 1, 2),
                BorderSizePixel = 0,
                ZIndex = 15,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })  Items["Fade"]:AddToTheme({BackgroundColor3 = "Inline"})

            Instances:Create("UIGradient", {
                Parent = Items["Fade"].Instance,
                Rotation = -90,
                Transparency = NumSequence{NumSequenceKeypoint(0, 0), NumSequenceKeypoint(0.718, 0.768750011920929), NumSequenceKeypoint(1, 1)}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Section"].Instance,
                Color = FromRGB(10, 10, 10),
                Name = string.char(0),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["Section"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Section"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Section.Name,
                Name = string.char(0),
                Size = UDim2New(1, -12, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 4, 0, 2),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0)
            }):AddToTheme({Color = "Text Border"})

            Items["Content"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Section"].Instance,
                Name = string.char(0),
                ScrollBarThickness = 3,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2New(0, 0, 0, 0),
                ScrollBarImageColor3 = FromRGB(235, 157, 255),
                MidImage = Library:GetImage("Scrollbar"),
                TopImage = Library:GetImage("Scrollbar"),
                BottomImage = Library:GetImage("Scrollbar"),
                Active = true,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 21),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -5, 1, -20),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIPadding", {
                Parent = Items["Content"].Instance,
                PaddingTop = UDimNew(0, 0),
                PaddingBottom = UDimNew(0, 8),
                PaddingRight = UDimNew(0, 11),
                PaddingLeft = UDimNew(0, 8)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        Section.Elements = Items

        return setmetatable(Section, Library.Sections)
    end

    Library.Sections.Divider = function(self)
        local Divider = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
        }

        local Items = { } do
            Items["Divider"] = Instances:Create("Frame", {
                Parent = Divider.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 10),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["RealDivider"] = Instances:Create("Frame", {
                Parent = Items["Divider"].Instance,
                AnchorPoint = Vector2New(0, 0.5),
                Name = string.char(0),
                Position = UDim2New(0, 0, 0.5, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 3),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["RealDivider"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["RealDivider"].Instance,
                Color = FromRGB(27, 27, 32),
                Name = string.char(0),
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})
        end

        function Divider:SetVisibility(Bool)
            Items["Divider"].Instance.Visible = Bool
        end

        return Divider
    end

    Library.Sections.Toggle = function(self, Data)
        Data = Data or { }

        local Toggle = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Toggle",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or false,
            Callback = Data.Callback or Data.callback or function() end,

            Value = false,
            Class = "Toggle",

            Count = 0,
            KeybindExtension = nil
        }

        local Items = { } do
            Items["Toggle"] =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Toggle.Section.
                            Elements[
                                "Content"
                            ].
                            Instance,

                        FontFace =
                            Library.Font,

                        Text = "",

                        AutoButtonColor = false,

                        BackgroundTransparency = 1,

                        Name =
                            string.char(0),

                        Size =
                            UDim2New(
                                1,
                                0,
                                0,
                                15
                            ),

                        BorderSizePixel = 0
                    }
                )

            Items["Indicator"] =
                Instances:Create(
                    "Frame",
                    {
                        Parent =
                            Items["Toggle"].
                            Instance,

                        Name =
                            string.char(0),

                        AnchorPoint =
                            Vector2New(
                                0,
                                0.5
                            ),

                        Position =
                            UDim2New(
                                0,
                                0,
                                0.5,
                                0
                            ),

                        Size =
                            UDim2New(
                                0,
                                13,
                                0,
                                13
                            ),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.
                            Element
                    }
                )

            Items["Indicator"]:
                AddToTheme({
                    BackgroundColor3 =
                        "Element"
                })

            local IndicatorCorner =
                InstanceNew("UICorner")

            IndicatorCorner.CornerRadius =
                UDimNew(
                    0,
                    2
                )

            IndicatorCorner.Parent =
                Items["Indicator"].
                Instance

            Items["IndicatorStroke"] =
                InstanceNew("UIStroke")

            Items["IndicatorStroke"].
                Name =
                "_RadiantToggleStroke"

            Items["IndicatorStroke"].
                Parent =
                Items["Indicator"].
                Instance

            Items["IndicatorStroke"].
                ApplyStrokeMode =
                Enum.ApplyStrokeMode.
                Border

            Items["IndicatorStroke"].
                LineJoinMode =
                Enum.LineJoinMode.
                Round

            Items["IndicatorStroke"].
                Thickness = 1

            Items["IndicatorStroke"].
                Transparency = 0.16

            Library:AddToTheme(
                Items["IndicatorStroke"],
                {
                    Color = "Outline"
                }
            )

            Items["Text"] =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent =
                            Items["Toggle"].
                            Instance,

                        FontFace =
                            Library.Font,

                        TextColor3 =
                            Library.Theme.Text,

                        TextTransparency =
                            0.08,

                        Text =
                            Toggle.Name,

                        Name =
                            string.char(0),

                        Position =
                            UDim2New(
                                0,
                                20,
                                0,
                                0
                            ),

                        Size =
                            UDim2New(
                                1,
                                -20,
                                1,
                                0
                            ),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        BorderSizePixel = 0,

                        TextSize = 12
                    }
                )

            Items["Text"]:
                AddToTheme({
                    TextColor3 = "Text"
                })

            local HoverTween =
                TweenInfo.new(
                    0.08,
                    Enum.EasingStyle.Quad,
                    Enum.EasingDirection.Out
                )

            Items["Toggle"]:
                OnHover(function()
                    Items["Indicator"]:Tween(HoverTween, {
                        BackgroundColor3 = Toggle.Value
                            and Library.Theme.Accent
                            or Library.Theme["Hovered Element"]
                    })

                    Items["Text"]:Tween(HoverTween, {
                        TextTransparency = 0
                    })
                end)

            Items["Toggle"]:
                OnHoverLeave(function()
                    Items["Indicator"]:Tween(HoverTween, {
                        BackgroundColor3 = Toggle.Value
                            and Library.Theme.Accent
                            or Library.Theme.Element
                    })

                    Items["Text"]:Tween(HoverTween, {
                        TextTransparency = Toggle.Value and 0 or 0.08
                    })
                end)
        end

        local function EnsureIndicatorStroke()
            local Stroke =
                Items["IndicatorStroke"]

            if typeof(Stroke) == "Instance"
                and Stroke:IsA("UIStroke")
                and Stroke.Parent
            then
                return Stroke
            end

            local Indicator =
                Items["Indicator"]
                and Items["Indicator"].Instance

            if not Indicator then
                return nil
            end

            Stroke =
                Indicator:FindFirstChild(
                    "_RadiantToggleStroke"
                )
                or Indicator:
                    FindFirstChildOfClass(
                        "UIStroke"
                    )

            if not Stroke then
                Stroke = InstanceNew("UIStroke")
                Stroke.Name =
                    "_RadiantToggleStroke"
                Stroke.ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border
                Stroke.LineJoinMode =
                    Enum.LineJoinMode.Round
                Stroke.Thickness = 1
                Stroke.Transparency = 0
                Stroke.Parent = Indicator

                Library:AddToTheme(
                    Stroke,
                    {
                        Color = "Outline"
                    }
                )
            end

            Items["IndicatorStroke"] =
                Stroke

            return Stroke
        end

        function Toggle:Get()
            return Toggle.Value
        end

        function Toggle:Set(Bool)
            if Bool == nil then
                Toggle.Value = not Toggle.Value
            else
                Toggle.Value = Bool == true
            end

            Library.Flags[Toggle.Flag] = Toggle.Value

            if Toggle.KeybindExtension
                and type(Toggle.KeybindExtension.SetState) == "function"
            then
                Toggle.KeybindExtension:SetState(Toggle.Value, true)
            end

            local IndicatorStroke = EnsureIndicatorStroke()
            local Animation = TweenInfo.new(
                0.10,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

            Items["Indicator"]:ChangeItemTheme({
                BackgroundColor3 = Toggle.Value and "Accent" or "Element"
            })

            Items["Indicator"]:Tween(Animation, {
                BackgroundColor3 = Toggle.Value
                    and Library.Theme.Accent
                    or Library.Theme.Element
            })

            if IndicatorStroke then
                IndicatorStroke.Color = Toggle.Value
                    and Library.Theme.Accent
                    or Library.Theme.Outline
                IndicatorStroke.Transparency = Toggle.Value and 0.06 or 0.16
            end

            Items["Text"]:Tween(Animation, {
                TextTransparency = Toggle.Value and 0 or 0.08
            })

            if Toggle.Callback then
                Library:SafeCall(Toggle.Callback, Toggle.Value)
            end
        end

        function Toggle:SetVisiblity(Bool)
            Items["Toggle"].Instance.Visible = Bool
        end

        function Toggle:Colorpicker(Data)
            Data = Data or { }

            local Colorpicker = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Toggle"],
                Name = Data.Name or Data.name or "Colorpicker",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                Callback = Data.Callback or Data.callback or function() end,
                Alpha = Data.Alpha or Data.alpha or false,
                Count = Toggle.Count,

                FadeSpeed = self.Window.FadeSpeed
            }

            Toggle.Count += 1
            Colorpicker.Count = Toggle.Count

            local Extension = Library:CreateColorpicker(Colorpicker)
            Library.Flags[Colorpicker.Flag] = Extension

            return Colorpicker
        end

        function Toggle:Keybind(Data)
            Data = Data or { }

            local HasExplicitDefault = rawget(Data, "Default") ~= nil
                or rawget(Data, "default") ~= nil
            local DefaultValue = rawget(Data, "Default")

            if DefaultValue == nil then
                DefaultValue = rawget(Data, "default")
            end

            local Keybind = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Toggle"],
                Name = Data.Name or Data.name or "Keybind",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = DefaultValue,
                HasExplicitDefault = HasExplicitDefault,
                Mode = Data.Mode or Data.mode or "Toggle",
                Callback = function(Value)
                    Toggle:Set(Value)

                    local UserCallback =
                        Data.Callback
                        or Data.callback

                    if UserCallback then
                        Library:SafeCall(
                            UserCallback,
                            Value
                        )
                    end
                end,
            }

            local Extension =
                Library:CreateKeybind(
                    Keybind
                )

            Toggle.KeybindExtension =
                Extension

            Extension:SetState(
                Toggle.Value,
                true
            )

            Library.Flags[
                Keybind.Flag
            ] = Extension

            return Keybind,
                Extension
        end

        Items["Toggle"]:Connect("MouseButton1Down", function()
            Toggle:Set()
        end)

        if Toggle.Default then
            Toggle:Set(Toggle.Default)
        end

        Library.SetFlags[Toggle.Flag] = function(Value)
            Toggle:Set(Value)
        end

        return Toggle
    end

    Library.Sections.Button = function(self, Data)
        Data = Data or { }

        local Button = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name,
            Callback = Data.Callback or Data.callback or function() end,
        }

        local Items = { } do
            Items["Button"] = Instances:Create("TextButton", {
                Parent = Button.Section.Elements["Content"].Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                AutoButtonColor = false,
                Name = string.char(0),
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, 0, 0, 17),
                Selectable = false,
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Button"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            Library:ApplyGlass(Items["Button"], "Element", 7)

            Instances:Create("UIGradient", {
                Parent = Items["Button"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Button"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Button"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Button.Name,
                Name = string.char(0),
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2New(0, 0, 0, -1),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Items["TextBorder"] = Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0)
            }):AddToTheme({Color = "Text Border"})

            Items["Button"]:OnHover(function()
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["Button"]:OnHoverLeave(function()
                Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
                Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            end)
        end

        function Button:Press()
            Library:SafeCall(Button.Callback)

            Items["Text"]:ChangeItemTheme({TextColor3 = "Accent"})
            Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Accent"})

            Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Accent})
            Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})

            task.wait(0.1)

            Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
            Items["Button"]:ChangeItemTheme({BackgroundColor3 = "Element"})

            Items["Text"]:Tween(nil, {TextColor3 = Library.Theme.Text})
            Items["Button"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
        end

        function Button:SetVisiblity(Bool)
            Items["Button"].Instance.Visible = Bool
        end

        Items["Button"]:Connect("MouseButton1Down", function()
            Button:Press()
        end)

        return Button
    end

    Library.Sections.Slider = function(self, Data)
        Data = Data or { }

        local Slider = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Slider",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Min = Data.Min or Data.min or 0,
            Default = Data.Default or Data.default or 0,
            Max = Data.Max or Data.max or 100,
            Suffix = Data.Suffix or Data.suffix or "",
            Decimals = Data.Decimals or Data.decimals or 1,
            Callback = Data.Callback or Data.callback or function() end,
            Compact = Data.Compact or Data.compact or false,

            Value = 0,
            Sliding = false,
            Class = "Slider",
        }

        local Items = { } do
            Items["Slider"] = Instances:Create("Frame", {
                Parent = Slider.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 27),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Slider"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Slider.Name,
                Name = string.char(0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 13),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0)
            }):AddToTheme({Color = "Text Border"})

            Items["RealSlider"] = Instances:Create("TextButton", {
                Parent = Items["Slider"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = string.char(0),
                Position = UDim2New(0, 1, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(1, -2, 0, 10),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
            Library:ApplyGlass(Items["RealSlider"], "Element", 6)

            Instances:Create("UIStroke", {
                Parent = Items["RealSlider"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIGradient", {
                Parent = Items["RealSlider"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["Indicator"] = Instances:Create("Frame", {
                Parent = Items["RealSlider"].Instance,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0.5, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["Indicator"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["Value"] = Instances:Create("TextLabel", {
                Parent = Items["RealSlider"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "50/100s",
                Name = string.char(0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, -1),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Value"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0)
            }):AddToTheme({Color = "Text Border"})

            if Slider.Compact then
                Items["Value"]:Clean()
                Items["Value"] = nil

                Items["Slider"].Instance.Size = UDim2New(1,0,0,10)
                Items["Text"].Instance.Parent = Items["RealSlider"].Instance
                Items["Text"].Instance.Position = UDim2New(0,0,0,-2)
                Items["Text"].Instance.TextXAlignment = Enum.TextXAlignment.Center
            end

            Items["RealSlider"]:OnHover(function()
                Items["RealSlider"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["RealSlider"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["RealSlider"]:OnHoverLeave(function()
                Items["RealSlider"]:Tween(nil, {BackgroundColor3 = Library.Theme["Background"]})
                Items["RealSlider"]:ChangeItemTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
            end)
        end

        function Slider:Set(Value)
            Slider.Value = MathClamp(Library:Round(Value, Slider.Decimals), Slider.Min, Slider.Max)

            Library.Flags[Slider.Flag] = Slider.Value

            if Slider.Compact then
                Items["Text"].Instance.Text = `{Slider.Name}: {Slider.Value}{Slider.Suffix}`
            else
                Items["Value"].Instance.Text = `{Slider.Value}{Slider.Suffix}`
            end

            Items["Indicator"].Instance.Size =
                UDim2New(
                    (
                        Slider.Value
                        - Slider.Min
                    ) / math.max(
                        Slider.Max
                        - Slider.Min,
                        0.0001
                    ),
                    0,
                    1,
                    0
                )

            if Slider.Callback then
                Library:SafeCall(Slider.Callback, Slider.Value)
            end
        end

        function Slider:Get()
            return Slider.Value
        end

        function Slider:SetVisibility(Bool)
            Items["Slider"].Instance.Visible = Bool
        end

        function Slider:UpdateFromMouse()
            local MousePosition =
                Library:
                GetPointerPosition()

            local AbsolutePosition =
                Items[
                    "RealSlider"
                ].Instance.AbsolutePosition

            local AbsoluteSize =
                Items[
                    "RealSlider"
                ].Instance.AbsoluteSize

            if AbsoluteSize.X <= 0 then
                return
            end

            local Scale =
                MathClamp(
                    (
                        MousePosition.X
                        - AbsolutePosition.X
                    ) / AbsoluteSize.X,
                    0,
                    1
                )

            Slider:Set(
                Slider.Min
                + (
                    Slider.Max
                    - Slider.Min
                ) * Scale
            )
        end

        Items[
            "RealSlider"
        ]:Connect(
            "MouseButton1Down",
            function()
                Slider.Sliding =
                    true

                Library.ActiveSlider =
                    Slider

                Slider:
                    UpdateFromMouse()
            end
        )

        Library:Connect(
            UserInputService.InputEnded,
            function(Input)
                if Input.UserInputType
                    == Enum.UserInputType.MouseButton1
                then
                    if Library.ActiveSlider
                        == Slider
                    then
                        Library.ActiveSlider =
                            nil
                    end

                    Slider.Sliding =
                        false
                end
            end
        )

        if not Library.SliderConnection then
            Library.SliderConnection =
                Library:Connect(
                    RunService.RenderStepped,
                    function()
                        local ActiveSlider =
                            Library.ActiveSlider

                        if ActiveSlider
                            and ActiveSlider.Sliding
                        then
                            ActiveSlider:
                                UpdateFromMouse()
                        end
                    end,
                    "Library_Slider_Renderer"
                )
        end

        if Slider.Default then
            Slider:Set(Slider.Default)
        end

        Library.SetFlags[Slider.Flag] = function(Value)
            Slider:Set(Value)
        end

        return Slider
    end

    Library.Sections.Dropdown = function(self, Data)
        Data = Data or { }

        local Dropdown = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Name = Data.Name or Data.name or "Dropdown",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Items = Data.Items or Data.items or {"One", "Two", "Three"},
            Default = Data.Default or Data.default,
            Callback = Data.Callback or Data.callback or function() end,
            Multi = Data.Multi or Data.multi or false,
            Value = { },
            IsOpen = false,
            Options = { },
            AnimationToken = 0,
            Class = "Dropdown"
        }

        local Items = { }

        local PopupTween =
            TweenInfo.new(
                0.14,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

        Items["Dropdown"] =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Dropdown.Section.
                        Elements[
                            "Content"
                        ].
                        Instance,

                    BackgroundTransparency = 1,
                    Name = string.char(0),
                    Size = UDim2New(1, 0, 0, 42),
                    BorderSizePixel = 0
                }
            )

        Items["Text"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["Dropdown"].
                        Instance,

                    FontFace = Library.Font,
                    TextColor3 =
                        Library.Theme.Text,

                    Text = Dropdown.Name,
                    Name = string.char(0),
                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    Size = UDim2New(1, 0, 0, 14),
                    BorderSizePixel = 0,
                    TextSize = 11
                }
            )

        Items["Text"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["Field"] =
            Instances:Create(
                "TextButton",
                {
                    Parent =
                        Items["Dropdown"].
                        Instance,

                    AnchorPoint = Vector2New(0, 1),
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 0, 1, 0),

                    Size =
                        UDim2New(1, 0, 0, 25),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Element,

                    AutoButtonColor = false,
                    Text = "",
                    Active = true
                }
            )

        Items["Field"]:AddToTheme({
            BackgroundColor3 = "Element"
        })

        Library:ApplyGlass(
            Items["Field"],
            "Element",
            4
        )

        Items["FieldStroke"] =
            Instances:Create(
                "UIStroke",
                {
                    Parent =
                        Items["Field"].Instance,

                    ApplyStrokeMode =
                        Enum.ApplyStrokeMode.Border,

                    LineJoinMode =
                        Enum.LineJoinMode.Round,

                    Thickness = 1,
                    Transparency = 0.54,
                    Color =
                        Library.Theme.Outline
                }
            )

        Items["FieldStroke"]:AddToTheme({
            Color = "Outline"
        })

        Items["Value"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["Field"].
                        Instance,

                    FontFace = Library.Font,
                    TextColor3 =
                        Library.Theme.Text,

                    Text = "—",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 8, 0, 0),

                    Size =
                        UDim2New(1, -34, 1, 0),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    TextTruncate =
                        Enum.TextTruncate.AtEnd,

                    BorderSizePixel = 0,
                    TextSize = 10,
                    ZIndex = 2
                }
            )

        Items["Value"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["Action"] =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Items["Field"].
                        Instance,

                    AnchorPoint =
                        Vector2New(1, 0),

                    Position =
                        UDim2New(1, 0, 0, 0),

                    Size =
                        UDim2New(0, 28, 1, 0),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme[
                            "Page Background"
                        ],

                    ZIndex = 2
                }
            )

        Items["Action"]:AddToTheme({
            BackgroundColor3 =
                "Page Background"
        })

        local Separator =
            InstanceNew("Frame")

        Separator.Position =
            UDim2New(0, 0, 0, 4)

        Separator.Size =
            UDim2New(0, 1, 1, -8)

        Separator.BorderSizePixel = 0

        Separator.BackgroundColor3 =
            Library.Theme.Outline

        Separator.BackgroundTransparency =
            0.30

        Separator.ZIndex = 3
        Separator.Parent =
            Items["Action"].Instance

        Library:AddToTheme(
            Separator,
            {
                BackgroundColor3 =
                    "Outline"
            }
        )

        Items["Open"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["Action"].
                        Instance,

                    Font =
                        Enum.Font.GothamMedium,

                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    Text = "+",
                    Name = string.char(0),

                    Size =
                        UDim2New(1, 0, 1, 0),

                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    TextSize = 13,
                    ZIndex = 4
                }
            )

        Items["Open"]:AddToTheme({
            TextColor3 = "Muted Text"
        })

        Items["Popup"] =
            Instances:Create(
                "CanvasGroup",
                {
                    Parent =
                        Library.Holder.Instance,

                    Visible = false,
                    Name = string.char(0),
                    Position =
                        UDim2New(0, 0, 0, 0),

                    Size =
                        UDim2New(0, 132, 0, 0),

                    BorderSizePixel = 0,
                    BackgroundColor3 =
                        Library.Theme.Background,

                    BackgroundTransparency = 0,
                    ClipsDescendants = true,
                    GroupTransparency = 1,
                    ZIndex = 900
                }
            )

        Items["Popup"]:AddToTheme({
            BackgroundColor3 = "Background"
        })

        Library:ApplyGlass(
            Items["Popup"],
            "Popup",
            4
        )

        local PopupLayout =
            InstanceNew("UIListLayout")

        PopupLayout.Padding =
            UDimNew(0, 2)

        PopupLayout.SortOrder =
            Enum.SortOrder.LayoutOrder

        PopupLayout.Parent =
            Items["Popup"].Instance

        local PopupPadding =
            InstanceNew("UIPadding")

        PopupPadding.PaddingTop =
            UDimNew(0, 4)

        PopupPadding.PaddingBottom =
            UDimNew(0, 4)

        PopupPadding.Parent =
            Items["Popup"].Instance

        local function GetPopupMetrics(Offset)
            local Field =
                Items["Field"].Instance

            local Position =
                Field.AbsolutePosition

            local Size =
                Field.AbsoluteSize

            local Viewport =
                Workspace.CurrentCamera
                and Workspace.CurrentCamera.
                    ViewportSize
                or Vector2New(1920, 1080)

            local Height =
                math.min(
                    math.max(
                        #Dropdown.Items * 24 + 8,
                        28
                    ),
                    math.max(
                        Viewport.Y - 12,
                        28
                    )
                )

            local X =
                MathClamp(
                    Position.X,
                    6,
                    math.max(
                        Viewport.X
                        - Size.X
                        - 6,
                        6
                    )
                )

            local Below =
                Position.Y
                + Size.Y
                + (Offset or 3)

            local Above =
                Position.Y
                - Height
                - (Offset or 3)

            local Y =
                Below + Height
                    <= Viewport.Y - 6
                and Below
                or math.max(Above, 6)

            return
                UDim2New(0, X, 0, Y),
                UDim2New(
                    0,
                    Size.X,
                    0,
                    Height
                )
        end

        local function UpdatePopupPosition(Offset)
            local Position,
                Size =
                GetPopupMetrics(Offset)

            Items["Popup"].Instance.Position =
                Position

            Items["Popup"].Instance.Size =
                Size
        end

        Library:Connect(
            Items["Field"].Instance:
                GetPropertyChangedSignal(
                    "AbsolutePosition"
                ),
            function()
                if Dropdown.IsOpen then
                    UpdatePopupPosition(3)
                end
            end
        )

        Library:Connect(
            Items["Field"].Instance:
                GetPropertyChangedSignal(
                    "AbsoluteSize"
                ),
            function()
                if Dropdown.IsOpen then
                    UpdatePopupPosition(3)
                end
            end
        )

        function Dropdown:SetOpen(Bool)
            Bool = Bool == true

            if Bool
                and Library.OpenDropdown
                and Library.OpenDropdown
                    ~= Dropdown
            then
                Library.OpenDropdown:
                    SetOpen(false)
            end

            Dropdown.AnimationToken += 1

            local Token =
                Dropdown.AnimationToken

            Dropdown.IsOpen = Bool

            if Dropdown.Window
                and type(
                    Dropdown.Window.
                    SetDropdownDim
                ) == "function"
            then
                Dropdown.Window:
                    SetDropdownDim(Bool)
            end

            if Bool then
                Library.OpenDropdown =
                    Dropdown

                UpdatePopupPosition(6)

                Items["Popup"].Instance.
                    GroupTransparency = 1

                Items["Popup"].Instance.
                    Visible = true

                local FinalPosition,
                    FinalSize =
                    GetPopupMetrics(3)

                Items["Popup"]:Tween(
                    PopupTween,
                    {
                        Position =
                            FinalPosition,

                        Size = FinalSize,

                        GroupTransparency = 0
                    }
                )

                Items["Field"]:Tween(
                    PopupTween,
                    {
                        BackgroundColor3 =
                            Library.Theme[
                                "Hovered Element"
                            ]
                    }
                )

                Items["Action"]:Tween(
                    PopupTween,
                    {
                        BackgroundColor3 =
                            Library.Theme.Element
                    }
                )

                Items["Open"]:Tween(
                    PopupTween,
                    {
                        TextColor3 =
                            Library.Theme.Accent
                    }
                )

                Items["Open"].Instance.Text =
                    "−"
            else
                if Library.OpenDropdown
                    == Dropdown
                then
                    Library.OpenDropdown = nil
                end

                Items["Popup"]:Tween(
                    PopupTween,
                    {
                        GroupTransparency = 1
                    }
                )

                Items["Field"]:Tween(
                    PopupTween,
                    {
                        BackgroundColor3 =
                            Library.Theme.Element
                    }
                )

                Items["Action"]:Tween(
                    PopupTween,
                    {
                        BackgroundColor3 =
                            Library.Theme[
                                "Page Background"
                            ]
                    }
                )

                Items["Open"]:Tween(
                    PopupTween,
                    {
                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ]
                    }
                )

                Items["Open"].Instance.Text =
                    "+"

                task.delay(
                    0.14,
                    function()
                        if Token
                                == Dropdown.
                                    AnimationToken
                            and not Dropdown.IsOpen
                            and Items["Popup"].
                                Instance
                            and Items["Popup"].
                                Instance.Parent
                        then
                            Items["Popup"].
                                Instance.
                                Visible = false
                        end
                    end
                )
            end
        end

        Items["Field"]:OnHover(function()
            if Dropdown.IsOpen then
                return
            end

            Items["Field"]:Tween(
                PopupTween,
                {
                    BackgroundColor3 =
                        Library.Theme[
                            "Hovered Element"
                        ]
                }
            )

            Items["Open"]:Tween(
                PopupTween,
                {
                    TextColor3 =
                        Library.Theme.Text
                }
            )
        end)

        Items["Field"]:OnHoverLeave(function()
            if Dropdown.IsOpen then
                return
            end

            Items["Field"]:Tween(
                PopupTween,
                {
                    BackgroundColor3 =
                        Library.Theme.Element
                }
            )

            Items["Open"]:Tween(
                PopupTween,
                {
                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ]
                }
            )
        end)

        function Dropdown:Set(Option)
            if Dropdown.Multi then
                if type(Option) ~= "table" then
                    return
                end

                for _,
                    OptionData in pairs(
                        Dropdown.Options
                    )
                do
                    OptionData.Selected = false
                    OptionData:Toggle(false)
                end

                Dropdown.Value = { }

                for _,
                    Value in ipairs(Option)
                do
                    local OptionData =
                        Dropdown.Options[
                            Value
                        ]

                    if OptionData then
                        OptionData.Selected = true
                        OptionData:Toggle(true)

                        table.insert(
                            Dropdown.Value,
                            Value
                        )
                    end
                end

                Items["Value"].Instance.Text =
                    #Dropdown.Value > 0
                    and table.concat(
                        Dropdown.Value,
                        ", "
                    )
                    or "—"
            else
                local OptionData =
                    Dropdown.Options[Option]

                if not OptionData then
                    return
                end

                for _,
                    Value in pairs(
                        Dropdown.Options
                    )
                do
                    Value.Selected =
                        Value == OptionData

                    Value:Toggle(
                        Value == OptionData
                    )
                end

                Dropdown.Value =
                    OptionData.Name

                Items["Value"].Instance.Text =
                    OptionData.Name
            end

            Items["Value"].Instance.
                TextTransparency = 0

            Items["Value"].Instance.
                TextColor3 =
                Library.Theme.Text

            Library.Flags[
                Dropdown.Flag
            ] = Dropdown.Value

            if Dropdown.Callback then
                Library:SafeCall(
                    Dropdown.Callback,
                    Dropdown.Value
                )
            end
        end

        function Dropdown:Get()
            return Dropdown.Value
        end

        function Dropdown:SetVisibility(Bool)
            Items["Dropdown"].Instance.
                Visible =
                Bool == true

            if not Bool then
                Dropdown:SetOpen(false)
            end
        end

        function Dropdown:Add(Option)
            local Row =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["Popup"].
                            Instance,

                        FontFace = Library.Font,
                        Text = "",
                        AutoButtonColor = false,
                        Name = string.char(0),

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,

                        Size =
                            UDim2New(1, 0, 0, 21),

                        ZIndex = 901
                    }
                )

            Row:AddToTheme({
                BackgroundColor3 = "Element"
            })

            local Marker =
                Instances:Create(
                    "Frame",
                    {
                        Parent = Row.Instance,
                        Position =
                            UDim2New(0, 0, 0, 4),

                        Size =
                            UDim2New(0, 2, 1, -8),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Accent,

                        BackgroundTransparency = 1,
                        ZIndex = 902
                    }
                )

            Marker:AddToTheme({
                BackgroundColor3 = "Accent"
            })

            local Label =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent = Row.Instance,
                        FontFace = Library.Font,

                        TextColor3 =
                            Library.Theme.Text,

                        TextTransparency = 0.05,
                        Text = tostring(Option),
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 8, 0, 0),

                        Size =
                            UDim2New(1, -14, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        BorderSizePixel = 0,
                        ZIndex = 902,
                        TextSize = 10
                    }
                )

            Label:AddToTheme({
                TextColor3 = "Text"
            })

            local OptionData = {
                Selected = false,
                Name = Option,
                Button = Row,
                Marker = Marker,
                Label = Label
            }

            function OptionData:Toggle(Active)
                OptionData.Selected =
                    Active == true

                OptionData.Marker:Tween(
                    PopupTween,
                    {
                        BackgroundTransparency =
                            Active and 0 or 1
                    }
                )

                OptionData.Button:Tween(
                    PopupTween,
                    {
                        BackgroundTransparency =
                            Active and 0.52 or 1
                    }
                )

                OptionData.Label:
                    ChangeItemTheme({
                        TextColor3 =
                            Active
                            and "Accent"
                            or "Text"
                    })

                OptionData.Label:Tween(
                    PopupTween,
                    {
                        TextColor3 =
                            Active
                            and Library.Theme.Accent
                            or Library.Theme.Text,

                        TextTransparency =
                            Active and 0 or 0.05
                    }
                )
            end

            Row:OnHover(function()
                if OptionData.Selected then
                    return
                end

                OptionData.Button:Tween(
                    PopupTween,
                    {
                        BackgroundTransparency =
                            0.68
                    }
                )

                OptionData.Label:Tween(
                    PopupTween,
                    {
                        TextTransparency = 0
                    }
                )
            end)

            Row:OnHoverLeave(function()
                if OptionData.Selected then
                    return
                end

                OptionData.Button:Tween(
                    PopupTween,
                    {
                        BackgroundTransparency = 1
                    }
                )

                OptionData.Label:Tween(
                    PopupTween,
                    {
                        TextTransparency = 0.05
                    }
                )
            end)

            function OptionData:Set()
                if Dropdown.Multi then
                    OptionData.Selected =
                        not OptionData.Selected

                    local Index =
                        table.find(
                            Dropdown.Value,
                            OptionData.Name
                        )

                    if OptionData.Selected
                        and not Index
                    then
                        table.insert(
                            Dropdown.Value,
                            OptionData.Name
                        )
                    elseif not OptionData.Selected
                        and Index
                    then
                        table.remove(
                            Dropdown.Value,
                            Index
                        )
                    end

                    OptionData:Toggle(
                        OptionData.Selected
                    )

                    Items["Value"].Instance.Text =
                        #Dropdown.Value > 0
                        and table.concat(
                            Dropdown.Value,
                            ", "
                        )
                        or "—"

                    Library.Flags[
                        Dropdown.Flag
                    ] = Dropdown.Value

                    if Dropdown.Callback then
                        Library:SafeCall(
                            Dropdown.Callback,
                            Dropdown.Value
                        )
                    end
                else
                    Dropdown:Set(
                        OptionData.Name
                    )

                    Dropdown:SetOpen(false)
                end
            end

            Row:Connect(
                "MouseButton1Down",
                function()
                    OptionData:Set()
                end
            )

            Dropdown.Options[Option] =
                OptionData

            return OptionData
        end

        function Dropdown:Remove(Option)
            local OptionData =
                Dropdown.Options[Option]

            if not OptionData then
                return
            end

            OptionData.Button:Clean()
            Dropdown.Options[Option] = nil
        end

        function Dropdown:Refresh(List)
            local Existing = { }

            for Name in pairs(
                Dropdown.Options
            )
            do
                table.insert(
                    Existing,
                    Name
                )
            end

            for _,
                Name in ipairs(Existing)
            do
                Dropdown:Remove(Name)
            end

            Dropdown.Items = List or { }

            for _,
                Value in ipairs(
                    Dropdown.Items
                )
            do
                Dropdown:Add(Value)
            end
        end

        for _,
            Value in ipairs(
                Dropdown.Items
            )
        do
            Dropdown:Add(Value)
        end

        Items["Field"]:Connect(
            "MouseButton1Down",
            function()
                Dropdown:SetOpen(
                    not Dropdown.IsOpen
                )
            end
        )

        Library:Connect(
            UserInputService.InputBegan,
            function(Input)
                if not Dropdown.IsOpen then
                    return
                end

                if Input.UserInputType
                        ~= Enum.UserInputType.
                            MouseButton1
                    and Input.UserInputType
                        ~= Enum.UserInputType.
                            Touch
                then
                    return
                end

                if Library:
                    IsMouseOverFrame(
                        Items["Popup"]
                    )
                    or Library:
                    IsMouseOverFrame(
                        Items["Field"]
                    )
                then
                    return
                end

                Dropdown:SetOpen(false)
            end
        )

        if Dropdown.Default ~= nil then
            Dropdown:Set(
                Dropdown.Default
            )
        end

        Library.SetFlags[
            Dropdown.Flag
        ] = function(Value)
            Dropdown:Set(Value)
        end

        return Dropdown
    end

    Library.Sections.Label = function(self, Data)
        Data = Data or { }

        local Label = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name,
            Alignment = Data.Alignment or Data.alignment or "Left",

            Count = 0
        }

        local Items = { } do
            Items["Label"] = Instances:Create("Frame", {
                Parent = Label.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 15),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Label"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Label.Name,
                Name = string.char(0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment[Label.Alignment],
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
            }):AddToTheme({Color = "Text Border"})
        end

        function Label:Colorpicker(Data)
            Data = Data or { }

            local Colorpicker = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Label"],
                Name = Data.Name or Data.name or "Colorpicker",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
                Callback = Data.Callback or Data.callback or function() end,
                Alpha = Data.Alpha or Data.alpha or false,
                Count = Label.Count,
                FadeSpeed = self.Window.FadeSpeed
            }

            Label.Count += 1
            Colorpicker.Count = Label.Count

            local Extension = Library:CreateColorpicker(Colorpicker)

            return Colorpicker, Extension
        end

        function Label:Keybind(Data)
            Data = Data or { }

            local HasExplicitDefault = rawget(Data, "Default") ~= nil
                or rawget(Data, "default") ~= nil
            local DefaultValue = rawget(Data, "Default")

            if DefaultValue == nil then
                DefaultValue = rawget(Data, "default")
            end

            local Keybind = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Label"],
                Name = Data.Name or Data.name or "Keybind",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = DefaultValue,
                HasExplicitDefault = HasExplicitDefault,
                Mode = Data.Mode or Data.mode or "Toggle",
                Callback = Data.Callback or Data.callback or function() end,
            }

            local Extension = Library:CreateKeybind(Keybind)

            return Keybind, Extension
        end

        return Label
    end

    Library.Sections.Textbox = function(self, Data)
        Data = Data or { }

        local Textbox = {
            Window = self.Window,
            Tab = self.Tab,
            Section = self,

            Name = Data.Name or Data.name or "Textbox",
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Placeholder = Data.Placeholder or Data.placeholder or "...",
            Default = Data.Default or Data.default or "",
            Callback = Data.Callback or Data.callback or function() end,

            Value = "",
            Class = "Textbox"
        }

        local Items = { } do
            Items["Textbox"] = Instances:Create("Frame", {
                Parent = Textbox.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = string.char(0),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 34),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Textbox"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Textbox.Name,
                Name = string.char(0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 13),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0)
            }):AddToTheme({Color = "Text Border"})

            Items["Background"] = Instances:Create("Frame", {
                Parent = Items["Textbox"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = string.char(0),
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 17),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            Library:ApplyGlass(Items["Background"], "Element", 7)

            Instances:Create("UIGradient", {
                Parent = Items["Background"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Background"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0),
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Inline"] = Instances:Create("TextBox", {
                Parent = Items["Background"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = string.char(0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                BackgroundTransparency = 1,
                PlaceholderColor3 = FromRGB(178, 178, 178),
                TextXAlignment = Enum.TextXAlignment.Left,
                PlaceholderText = Textbox.Placeholder,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Inline"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIPadding", {
                Parent = Items["Inline"].Instance,
                PaddingBottom = UDimNew(0, 3),
                PaddingLeft = UDimNew(0, 5)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Inline"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = string.char(0)
            }):AddToTheme({Color = "Text Border"})

            Items["Background"]:OnHover(function()
                Items["Background"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["Background"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["Background"]:OnHoverLeave(function()
                Items["Background"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
                Items["Background"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            end)
        end

        function Textbox:Get()
            return Textbox.Value
        end

        function Textbox:SetVisibility(Bool)
            Items["Textbox"].Instance.Visible = Bool
        end

        function Textbox:Set(Value)
            Textbox.Value = Value

            Items["Inline"].Instance.Text = Textbox.Value
            Items["Inline"]:Tween(nil, {TextColor3 = Library.Theme.Text})
            Items["Inline"]:ChangeItemTheme({TextColor3 = "Text"})

            Library.Flags[Textbox.Flag] = Textbox.Value

            if Textbox.Callback then
                Library:SafeCall(Textbox.Callback, Textbox.Value)
            end
        end

        Items["Inline"]:Connect("Focused", function()
            Items["Inline"]:ChangeItemTheme({TextColor3 = "Accent"})
            Items["Inline"]:Tween(nil, {TextColor3 = Library.Theme.Accent})
        end)

        Items["Inline"]:Connect("FocusLost", function()
            Items["Inline"]:ChangeItemTheme({TextColor3 = "Text"})
            Items["Inline"]:Tween(nil, {TextColor3 = Library.Theme.Text})

            Textbox:Set(Items["Inline"].Instance.Text)
        end)

        if Textbox.Default then
            Textbox:Set(Textbox.Default)
        end

        Library.SetFlags[Textbox.Flag] = function(Value)
            Textbox:Set(Value)
        end

        return Textbox
    end

    Library.Sections.PlayerList = function(self, Data)
        Data = Data or { }

        local PlayerList = {
            Window = self.Window,
            Page = self.Page,
            Section = self,
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Callback = Data.Callback or Data.callback or function() end,
            GetStatus = Data.GetStatus or Data.getstatus,
            Height = Data.Height or Data.height or 338,
            FillParent = Data.FillParent == true,
            BaseZIndex = tonumber(Data.ZIndex) or 1,
            Selected = nil,
            Search = "",
            Rows = { },
            Statuses = { },
            IsStatusOpen = false,
            Class = "PlayerList"
        }

        local Items = { }

        local PlayerTween =
            TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

        local StatusColors = {
            None = Library.Theme["Muted Text"],
            Priority = FromRGB(235, 184, 84),
            Whitelist = Library.Theme.Accent,
            Client = Library.Theme.Danger
        }

        Items["Root"] =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        PlayerList.Section.
                        Elements["Content"].
                        Instance,

                    Name = string.char(0),

                    Size =
                        PlayerList.FillParent
                        and UDim2New(
                            1,
                            0,
                            1,
                            0
                        )
                        or UDim2New(
                            1,
                            0,
                            0,
                            PlayerList.Height
                        ),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    ZIndex = PlayerList.BaseZIndex
                }
            )

        Items["Left"] =
            Instances:Create(
                "Frame",
                {
                    Parent = Items["Root"].Instance,
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 0, 0, 0),

                    Size =
                        UDim2New(0.57, -4, 1, 0),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme[
                            "Page Background"
                        ],

                    ClipsDescendants = true
                }
            )

        Items["Left"]:AddToTheme({
            BackgroundColor3 =
                "Page Background"
        })

        Library:ApplyGlass(
            Items["Left"],
            "Panel",
            5
        )

        Items["Right"] =
            Instances:Create(
                "Frame",
                {
                    Parent = Items["Root"].Instance,
                    Name = string.char(0),

                    Position =
                        UDim2New(0.57, 4, 0, 0),

                    Size =
                        UDim2New(0.43, -4, 1, 0),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme[
                            "Page Background"
                        ],

                    ClipsDescendants = false
                }
            )

        Items["Right"]:AddToTheme({
            BackgroundColor3 =
                "Page Background"
        })

        Library:ApplyGlass(
            Items["Right"],
            "Panel",
            5
        )

        Items["Count"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent = Items["Left"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = "Players [0]",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 9, 0, 7),

                    Size =
                        UDim2New(1, -18, 0, 17),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    BorderSizePixel = 0,
                    TextSize = 11
                }
            )

        Items["Count"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["Search"] =
            Instances:Create(
                "TextBox",
                {
                    Parent = Items["Left"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    PlaceholderColor3 =
                        Library.Theme["Muted Text"],

                    PlaceholderText = "Search player...",
                    Text = "",
                    ClearTextOnFocus = false,
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 9, 0, 29),

                    Size =
                        UDim2New(1, -18, 0, 25),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Element,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    TextSize = 10
                }
            )

        Items["Search"]:AddToTheme({
            TextColor3 = "Text",
            PlaceholderColor3 = "Muted Text",
            BackgroundColor3 = "Element"
        })

        Library:ApplyGlass(
            Items["Search"],
            "Element",
            4
        )

        local SearchPadding =
            InstanceNew("UIPadding")

        SearchPadding.PaddingLeft =
            UDimNew(0, 8)

        SearchPadding.PaddingRight =
            UDimNew(0, 8)

        SearchPadding.Parent =
            Items["Search"].Instance

        Items["Header"] =
            Instances:Create(
                "Frame",
                {
                    Parent = Items["Left"].Instance,
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 9, 0, 62),

                    Size =
                        UDim2New(1, -18, 0, 22),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Inline
                }
            )

        Items["Header"]:AddToTheme({
            BackgroundColor3 = "Inline"
        })

        Items["HeaderName"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent = Items["Header"].Instance,
                    FontFace = Library.Font,

                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    Text = "Name",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 8, 0, 0),

                    Size =
                        UDim2New(0.68, -8, 1, 0),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    BorderSizePixel = 0,
                    TextSize = 9
                }
            )

        Items["HeaderName"]:AddToTheme({
            TextColor3 = "Muted Text"
        })

        Items["HeaderStatus"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent = Items["Header"].Instance,
                    FontFace = Library.Font,

                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    Text = "Status",
                    Name = string.char(0),

                    Position =
                        UDim2New(0.68, 0, 0, 0),

                    Size =
                        UDim2New(0.32, -8, 1, 0),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Right,

                    BorderSizePixel = 0,
                    TextSize = 9
                }
            )

        Items["HeaderStatus"]:AddToTheme({
            TextColor3 = "Muted Text"
        })

        Items["List"] =
            Instances:Create(
                "ScrollingFrame",
                {
                    Parent = Items["Left"].Instance,
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 9, 0, 85),

                    Size =
                        UDim2New(1, -18, 1, -94),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,

                    ScrollBarImageColor3 =
                        Library.Theme.Accent,

                    ScrollBarThickness = 2,

                    VerticalScrollBarInset =
                        Enum.ScrollBarInset.ScrollBar,

                    ScrollingDirection =
                        Enum.ScrollingDirection.Y,

                    ElasticBehavior =
                        Enum.ElasticBehavior.Never,

                    AutomaticCanvasSize =
                        Enum.AutomaticSize.Y,

                    CanvasSize =
                        UDim2New(0, 0, 0, 0),

                    ClipsDescendants = true
                }
            )

        Items["List"]:AddToTheme({
            ScrollBarImageColor3 = "Accent"
        })

        local ListLayout =
            InstanceNew("UIListLayout")

        ListLayout.Padding = UDimNew(0, 1)
        ListLayout.SortOrder =
            Enum.SortOrder.LayoutOrder

        ListLayout.Parent =
            Items["List"].Instance

        Items["SelectedTitle"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent = Items["Right"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = "Selected Player",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 10, 0, 7),

                    Size =
                        UDim2New(1, -20, 0, 17),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    BorderSizePixel = 0,
                    TextSize = 11
                }
            )

        Items["SelectedTitle"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["Avatar"] =
            Instances:Create(
                "ImageLabel",
                {
                    Parent = Items["Right"].Instance,
                    Name = string.char(0),

                    AnchorPoint =
                        Vector2New(0.5, 0),

                    Position =
                        UDim2New(0.5, 0, 0, 35),

                    Size =
                        UDim2New(0, 72, 0, 72),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Image = "",
                    ScaleType = Enum.ScaleType.Fit
                }
            )

        local AvatarCorner =
            InstanceNew("UICorner")

        AvatarCorner.CornerRadius =
            UDimNew(1, 0)

        AvatarCorner.Parent =
            Items["Avatar"].Instance

        Items["SelectedName"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent = Items["Right"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = "No player selected",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 10, 0, 113),

                    Size =
                        UDim2New(1, -20, 0, 17),

                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    TextSize = 10
                }
            )

        Items["SelectedName"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["SelectedId"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent = Items["Right"].Instance,
                    FontFace = Library.Font,

                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    Text = "—",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 10, 0, 132),

                    Size =
                        UDim2New(1, -20, 0, 15),

                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    TextSize = 9
                }
            )

        Items["SelectedId"]:AddToTheme({
            TextColor3 = "Muted Text"
        })

        Items["StatusLabel"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent = Items["Right"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = "Status",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 10, 0, 165),

                    Size =
                        UDim2New(1, -20, 0, 15),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    BorderSizePixel = 0,
                    TextSize = 10
                }
            )

        Items["StatusLabel"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["StatusField"] =
            Instances:Create(
                "TextButton",
                {
                    Parent = Items["Right"].Instance,
                    FontFace = Library.Font,
                    Text = "",
                    AutoButtonColor = false,
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 10, 0, 184),

                    Size =
                        UDim2New(1, -20, 0, 26),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Element
                }
            )

        Items["StatusField"]:AddToTheme({
            BackgroundColor3 = "Element"
        })

        Library:ApplyGlass(
            Items["StatusField"],
            "Element",
            4
        )

        Items["StatusValue"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["StatusField"].Instance,

                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    Text = "None",
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 8, 0, 0),

                    Size =
                        UDim2New(1, -30, 1, 0),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    BorderSizePixel = 0,
                    TextSize = 10,
                    ZIndex = 2
                }
            )

        Items["StatusValue"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["StatusArrow"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["StatusField"].Instance,

                    FontFace = Library.Font,

                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    Text = "+",
                    Name = string.char(0),

                    AnchorPoint =
                        Vector2New(1, 0),

                    Position =
                        UDim2New(1, -6, 0, 0),

                    Size =
                        UDim2New(0, 18, 1, 0),

                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    TextSize = 11,
                    ZIndex = 2
                }
            )

        Items["StatusArrow"]:AddToTheme({
            TextColor3 = "Muted Text"
        })

        Items["StatusPopup"] =
            Instances:Create(
                "CanvasGroup",
                {
                    Parent = Items["Right"].Instance,
                    Name = string.char(0),

                    Position =
                        UDim2New(0, 10, 0, 214),

                    Size =
                        UDim2New(1, -20, 0, 69),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Background,

                    GroupTransparency = 1,
                    Visible = false,
                    ZIndex = 40
                }
            )

        Items["StatusPopup"]:AddToTheme({
            BackgroundColor3 = "Background"
        })

        Library:ApplyGlass(
            Items["StatusPopup"],
            "Popup",
            4
        )

        local StatusLayout =
            InstanceNew("UIListLayout")

        StatusLayout.Padding =
            UDimNew(0, 1)

        StatusLayout.SortOrder =
            Enum.SortOrder.LayoutOrder

        StatusLayout.Parent =
            Items["StatusPopup"].Instance

        local StatusRows = { }

        local function GetStatus(Player)
            if not Player then
                return "None"
            end

            if Player == LocalPlayer then
                return "Client"
            end

            if PlayerList.GetStatus then
                local Success,
                    Result =
                    pcall(
                        PlayerList.GetStatus,
                        Player
                    )

                if Success
                    and (
                        Result == "None"
                        or Result == "Priority"
                        or Result == "Whitelist"
                    )
                then
                    return Result
                end
            end

            return
                PlayerList.Statuses[
                    Player.UserId
                ]
                or "None"
        end

        local function ApplyStatusVisual(
            Label,
            Status
        )
            local Color =
                StatusColors[Status]
                or StatusColors.None

            Label.Instance.Text = Status
            Label.Instance.TextColor3 = Color
        end

        local function CloseStatus()
            PlayerList.IsStatusOpen = false

            Items["StatusArrow"].Instance.Text =
                "+"

            Items["StatusPopup"]:Tween(
                PlayerTween,
                {
                    GroupTransparency = 1
                }
            )

            task.delay(
                0.12,
                function()
                    if not PlayerList.
                        IsStatusOpen
                        and Items["StatusPopup"].
                            Instance
                        and Items["StatusPopup"].
                            Instance.Parent
                    then
                        Items["StatusPopup"].
                            Instance.Visible = false
                    end
                end
            )
        end

        local function OpenStatus()
            if not PlayerList.Selected
                or PlayerList.Selected
                    == LocalPlayer
            then
                return
            end

            PlayerList.IsStatusOpen = true

            Items["StatusPopup"].
                Instance.Visible = true

            Items["StatusPopup"].
                Instance.GroupTransparency = 1

            Items["StatusArrow"].Instance.Text =
                "−"

            Items["StatusPopup"]:Tween(
                PlayerTween,
                {
                    GroupTransparency = 0
                }
            )
        end

        local function SetSelectedStatus(
            Status,
            Silent
        )
            local Player =
                PlayerList.Selected

            if not Player
                or Player == LocalPlayer
            then
                return
            end

            Status =
                Status == "Priority"
                and "Priority"
                or Status == "Whitelist"
                and "Whitelist"
                or "None"

            PlayerList.Statuses[
                Player.UserId
            ] = Status

            ApplyStatusVisual(
                Items["StatusValue"],
                Status
            )

            local Row =
                PlayerList.Rows[
                    Player.UserId
                ]

            if Row then
                ApplyStatusVisual(
                    Row.Status,
                    Status
                )
            end

            Library.Flags[
                PlayerList.Flag
            ] = {
                Player = Player.Name,
                UserId = Player.UserId,
                Status = Status
            }

            for Name,
                RowData in pairs(StatusRows)
            do
                local Active =
                    Name == Status

                RowData.Marker:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            Active and 0 or 1
                    }
                )

                RowData.Button:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            Active and 0.48 or 1
                    }
                )
            end

            if not Silent
                and PlayerList.Callback
            then
                Library:SafeCall(
                    PlayerList.Callback,
                    Player,
                    Status
                )
            end
        end

        for Index,
            Status in ipairs({
                "None",
                "Priority",
                "Whitelist"
            })
        do
            local Row =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["StatusPopup"].
                            Instance,

                        FontFace = Library.Font,
                        Text = "",
                        AutoButtonColor = false,
                        Name = string.char(0),

                        Size =
                            UDim2New(1, 0, 0, 22),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1,

                        LayoutOrder = Index,
                        ZIndex = 41
                    }
                )

            Row:AddToTheme({
                BackgroundColor3 = "Element"
            })

            local Marker =
                Instances:Create(
                    "Frame",
                    {
                        Parent = Row.Instance,

                        Position =
                            UDim2New(0, 0, 0, 4),

                        Size =
                            UDim2New(0, 2, 1, -8),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Accent,

                        BackgroundTransparency = 1,
                        ZIndex = 42
                    }
                )

            Marker:AddToTheme({
                BackgroundColor3 = "Accent"
            })

            local Label =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent = Row.Instance,
                        FontFace = Library.Font,

                        TextColor3 =
                            StatusColors[Status],

                        Text = Status,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 8, 0, 0),

                        Size =
                            UDim2New(1, -14, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        BorderSizePixel = 0,
                        TextSize = 10,
                        ZIndex = 42
                    }
                )

            StatusRows[Status] = {
                Button = Row,
                Marker = Marker,
                Label = Label
            }

            Row:OnHover(function()
                Row:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            0.60
                    }
                )
            end)

            Row:OnHoverLeave(function()
                local Current =
                    PlayerList.Selected
                    and GetStatus(
                        PlayerList.Selected
                    )
                    or "None"

                Row:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            Current == Status
                            and 0.48
                            or 1
                    }
                )
            end)

            Row:Connect(
                "MouseButton1Down",
                function()
                    SetSelectedStatus(Status)
                    CloseStatus()
                end
            )
        end

        function PlayerList:Select(Player)
            PlayerList.Selected = Player

            if not Player then
                Items["Avatar"].Instance.Image = ""
                Items["SelectedName"].Instance.Text =
                    "No player selected"

                Items["SelectedId"].Instance.Text =
                    "—"

                ApplyStatusVisual(
                    Items["StatusValue"],
                    "None"
                )

                CloseStatus()
                return
            end

            Items["Avatar"].Instance.Image =
                "rbxthumb://type=AvatarHeadShot&id="
                .. tostring(Player.UserId)
                .. "&w=150&h=150"

            Items["SelectedName"].Instance.Text =
                Player.Name

            Items["SelectedId"].Instance.Text =
                tostring(Player.UserId)

            local Status =
                GetStatus(Player)

            ApplyStatusVisual(
                Items["StatusValue"],
                Status
            )

            for _,
                RowData in pairs(
                    PlayerList.Rows
                )
            do
                local Active =
                    RowData.Player == Player

                RowData.Marker:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            Active and 0 or 1
                    }
                )

                RowData.Button:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            Active and 0.48 or 1
                    }
                )
            end

            for Name,
                RowData in pairs(StatusRows)
            do
                local Active =
                    Name == Status

                RowData.Marker:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            Active and 0 or 1
                    }
                )

                RowData.Button:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            Active and 0.48 or 1
                    }
                )
            end
        end

        local function ApplySearch()
            local Search =
                string.lower(
                    PlayerList.Search
                    or ""
                )

            for _,
                RowData in pairs(
                    PlayerList.Rows
                )
            do
                RowData.Button.Instance.Visible =
                    Search == ""
                    or string.find(
                        string.lower(
                            RowData.Player.Name
                        ),
                        Search,
                        1,
                        true
                    ) ~= nil
            end
        end

        local function ClearRows()
            for _,
                RowData in pairs(
                    PlayerList.Rows
                )
            do
                RowData.Button:Clean()
            end

            table.clear(
                PlayerList.Rows
            )
        end

        local function ApplyLayering()
            local Root =
                Items["Root"].Instance

            if not Root
                or not Root.Parent
            then
                return
            end

            Root.ZIndex =
                PlayerList.BaseZIndex

            local StatusPopup =
                Items["StatusPopup"]
                and Items["StatusPopup"].Instance
                or nil

            for _,
                Object in ipairs(
                    Root:GetDescendants()
                )
            do
                if Object:IsA("GuiObject") then
                    local Depth = 1
                    local Parent =
                        Object.Parent

                    while Parent
                        and Parent ~= Root
                    do
                        Depth += 1
                        Parent = Parent.Parent
                    end

                    local PopupBoost = 0

                    if StatusPopup
                        and (
                            Object == StatusPopup
                            or Object:
                                IsDescendantOf(
                                    StatusPopup
                                )
                        )
                    then
                        PopupBoost = 40
                    end

                    Object.ZIndex =
                        PlayerList.BaseZIndex
                        + Depth
                        + PopupBoost
                end
            end
        end

        local function CreatePlayerRow(Player)
            local Row =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["List"].Instance,

                        FontFace = Library.Font,
                        Text = "",
                        AutoButtonColor = false,
                        Name = string.char(0),

                        Size =
                            UDim2New(1, 0, 0, 27),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1
                    }
                )

            Row:AddToTheme({
                BackgroundColor3 = "Element"
            })

            local Marker =
                Instances:Create(
                    "Frame",
                    {
                        Parent = Row.Instance,

                        Position =
                            UDim2New(0, 0, 0, 4),

                        Size =
                            UDim2New(0, 2, 1, -8),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Accent,

                        BackgroundTransparency = 1,
                        ZIndex = 2
                    }
                )

            Marker:AddToTheme({
                BackgroundColor3 = "Accent"
            })

            local Name =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent = Row.Instance,
                        FontFace = Library.Font,

                        TextColor3 =
                            Library.Theme.Text,

                        Text = Player.Name,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 8, 0, 0),

                        Size =
                            UDim2New(0.66, -8, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        TextTruncate =
                            Enum.TextTruncate.AtEnd,

                        BorderSizePixel = 0,
                        TextSize = 10
                    }
                )

            Name:AddToTheme({
                TextColor3 = "Text"
            })

            local Status =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent = Row.Instance,
                        FontFace = Library.Font,

                        TextColor3 =
                            Library.Theme[
                                "Muted Text"
                            ],

                        Text = "None",
                        Name = string.char(0),

                        Position =
                            UDim2New(0.66, 0, 0, 0),

                        Size =
                            UDim2New(0.34, -7, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Right,

                        BorderSizePixel = 0,
                        TextSize = 9
                    }
                )

            ApplyStatusVisual(
                Status,
                GetStatus(Player)
            )

            local RowData = {
                Player = Player,
                Button = Row,
                Marker = Marker,
                Name = Name,
                Status = Status
            }

            Row:OnHover(function()
                if PlayerList.Selected == Player then
                    return
                end

                Row:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency =
                            0.62
                    }
                )
            end)

            Row:OnHoverLeave(function()
                if PlayerList.Selected == Player then
                    return
                end

                Row:Tween(
                    PlayerTween,
                    {
                        BackgroundTransparency = 1
                    }
                )
            end)

            Row:Connect(
                "MouseButton1Down",
                function()
                    PlayerList:Select(Player)
                end
            )

            PlayerList.Rows[
                Player.UserId
            ] = RowData
        end

        function PlayerList:Refresh()
            local Previous =
                PlayerList.Selected

            ClearRows()

            local PlayerItems =
                Players:GetPlayers()

            table.sort(
                PlayerItems,
                function(A, B)
                    if A == LocalPlayer then
                        return true
                    end

                    if B == LocalPlayer then
                        return false
                    end

                    return string.lower(A.Name)
                        < string.lower(B.Name)
                end
            )

            for _,
                Player in ipairs(PlayerItems)
            do
                CreatePlayerRow(Player)
            end

            Items["Count"].Instance.Text =
                "Players ["
                .. tostring(#PlayerItems)
                .. "]"

            ApplySearch()
            ApplyLayering()

            if Previous
                and Previous.Parent == Players
            then
                PlayerList:Select(Previous)
            elseif #PlayerItems > 0 then
                PlayerList:Select(
                    PlayerItems[1]
                )
            else
                PlayerList:Select(nil)
            end
        end

        Library:Connect(
            Items["Search"].Instance:
                GetPropertyChangedSignal("Text"),
            function()
                PlayerList.Search =
                    Items["Search"].
                    Instance.Text

                ApplySearch()
            end
        )

        Items["Search"]:OnHover(function()
            Items["Search"]:Tween(
                PlayerTween,
                {
                    BackgroundColor3 =
                        Library.Theme[
                            "Hovered Element"
                        ]
                }
            )
        end)

        Items["Search"]:OnHoverLeave(function()
            Items["Search"]:Tween(
                PlayerTween,
                {
                    BackgroundColor3 =
                        Library.Theme.Element
                }
            )
        end)

        Items["StatusField"]:OnHover(function()
            Items["StatusField"]:Tween(
                PlayerTween,
                {
                    BackgroundColor3 =
                        Library.Theme[
                            "Hovered Element"
                        ]
                }
            )

            Items["StatusArrow"]:Tween(
                PlayerTween,
                {
                    TextColor3 =
                        Library.Theme.Text
                }
            )
        end)

        Items["StatusField"]:OnHoverLeave(function()
            if PlayerList.IsStatusOpen then
                return
            end

            Items["StatusField"]:Tween(
                PlayerTween,
                {
                    BackgroundColor3 =
                        Library.Theme.Element
                }
            )

            Items["StatusArrow"]:Tween(
                PlayerTween,
                {
                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ]
                }
            )
        end)

        Items["StatusField"]:Connect(
            "MouseButton1Down",
            function()
                if PlayerList.IsStatusOpen then
                    CloseStatus()
                else
                    OpenStatus()
                end
            end
        )

        Library:Connect(
            Players.PlayerAdded,
            function()
                task.defer(function()
                    PlayerList:Refresh()
                end)
            end
        )

        Library:Connect(
            Players.PlayerRemoving,
            function(Player)
                if PlayerList.Selected == Player then
                    PlayerList.Selected = nil
                end

                task.defer(function()
                    PlayerList:Refresh()
                end)
            end
        )

        PlayerList:Refresh()
        ApplyLayering()

        PlayerList.Items = Items

        Library.SetFlags[
            PlayerList.Flag
        ] = function(Value)
            if type(Value) ~= "table" then
                return
            end

            local Player =
                Players:
                FindFirstChild(
                    tostring(
                        Value.Player
                        or ""
                    )
                )

            if Player then
                PlayerList:Select(Player)

                if Value.Status then
                    SetSelectedStatus(
                        Value.Status,
                        true
                    )
                end
            end
        end

        return PlayerList
    end

    Library.PlayerListWindow = function(
        self,
        Data
    )
        Data = Data or { }

        local PlayerWindow = {
            Visible = Data.Visible == true,
            Scale = tonumber(Data.Scale) or 1,
            Destroyed = false,
            Elements = { },
            PlayerList = nil
        }

        local Items = { }

        Items["Window"] =
            Instances:Create(
                "CanvasGroup",
                {
                    Parent =
                        Library.Holder.Instance,

                    Name = string.char(0),

                    Position =
                        Data.Position
                        or UDim2New(
                            0.5,
                            -340,
                            0.5,
                            -210
                        ),

                    Size =
                        Data.Size
                        or UDim2New(
                            0,
                            680,
                            0,
                            420
                        ),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Background,

                    Visible =
                        PlayerWindow.Visible,

                    GroupTransparency = 0,
                    ClipsDescendants = true,
                    ZIndex = 300
                }
            )

        Items["Window"]:AddToTheme({
            BackgroundColor3 = "Background"
        })

        Library:ApplyGlass(
            Items["Window"],
            "Window",
            6
        )

        Items["Scale"] =
            Instances:Create(
                "UIScale",
                {
                    Parent =
                        Items["Window"].Instance,

                    Scale =
                        PlayerWindow.Scale
                }
            )

        Items["Header"] =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Items["Window"].Instance,

                    Name = string.char(0),

                    Position =
                        UDim2New(0, 0, 0, 0),

                    Size =
                        UDim2New(1, 0, 0, 38),

                    BorderSizePixel = 0,

                    BackgroundColor3 =
                        Library.Theme.Inline,

                    ZIndex = 301
                }
            )

        Items["Header"]:AddToTheme({
            BackgroundColor3 = "Inline"
        })

        Items["HeaderIcon"] =
            Library:CreateVectorIcon(
                Items["Header"],
                "users",
                {
                    Size = 18,

                    Position =
                        UDim2New(
                            0,
                            12,
                            0.5,
                            0
                        ),

                    AnchorPoint =
                        Vector2New(0, 0.5),

                    Theme = "Accent",
                    ZIndex = 303
                }
            )

        Items["Brand"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["Header"].Instance,

                    FontFace = Library.Font,

                    TextColor3 =
                        Library.Theme.Accent,

                    Text =
                        Data.Brand
                        or "radiant.rip",

                    Name = string.char(0),

                    Position =
                        UDim2New(
                            0,
                            39,
                            0,
                            0
                        ),

                    Size =
                        UDim2New(
                            0,
                            88,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    BorderSizePixel = 0,
                    TextSize = 11,
                    ZIndex = 302
                }
            )

        Items["Brand"]:AddToTheme({
            TextColor3 = "Accent"
        })

        Items["Divider"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["Header"].Instance,

                    FontFace = Library.Font,

                    TextColor3 =
                        Library.Theme[
                            "Muted Text"
                        ],

                    Text = "•",
                    Name = string.char(0),

                    Position =
                        UDim2New(
                            0,
                            124,
                            0,
                            0
                        ),

                    Size =
                        UDim2New(
                            0,
                            12,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    TextSize = 10,
                    ZIndex = 302
                }
            )

        Items["Divider"]:AddToTheme({
            TextColor3 = "Muted Text"
        })

        Items["Title"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items["Header"].Instance,

                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,

                    Text =
                        Data.Title
                        or "Player List",

                    Name = string.char(0),

                    Position =
                        UDim2New(
                            0,
                            138,
                            0,
                            0
                        ),

                    Size =
                        UDim2New(
                            1,
                            -150,
                            1,
                            0
                        ),

                    BackgroundTransparency = 1,

                    TextXAlignment =
                        Enum.TextXAlignment.Left,

                    BorderSizePixel = 0,
                    TextSize = 11,
                    ZIndex = 302
                }
            )

        Items["Title"]:AddToTheme({
            TextColor3 = "Text"
        })

        Items["Content"] =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Items["Window"].Instance,

                    Name = string.char(0),

                    Position =
                        UDim2New(
                            0,
                            10,
                            0,
                            48
                        ),

                    Size =
                        UDim2New(
                            1,
                            -20,
                            1,
                            -58
                        ),

                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    ZIndex = 301,
                    Active = true
                }
            )

        Items["Window"]:
            MakeDraggable(
                Items["Header"],
                0
            )

        local FakeSection = {
            Window = PlayerWindow,
            Page = nil,
            Elements = {
                Content = Items["Content"]
            }
        }

        PlayerWindow.PlayerList =
            Library.Sections.PlayerList(
                FakeSection,
                {
                    Flag =
                        Data.Flag
                        or "Player Status",

                    Height =
                        Data.Height
                        or 354,

                    FillParent = true,
                    ZIndex = 302,

                    GetStatus =
                        Data.GetStatus,

                    Callback =
                        Data.Callback
                }
            )

        function PlayerWindow:SetVisibility(Bool)
            PlayerWindow.Visible =
                Bool == true

            Items["Window"].Instance.Visible =
                PlayerWindow.Visible
        end

        function PlayerWindow:SetScale(Value)
            PlayerWindow.Scale =
                math.clamp(
                    tonumber(Value)
                    or 1,
                    0.55,
                    1.6
                )

            Items["Scale"].Instance.Scale =
                PlayerWindow.Scale
        end

        function PlayerWindow:SetSize(Size)
            if typeof(Size) == "UDim2" then
                Items["Window"].Instance.Size =
                    Size
            end
        end

        function PlayerWindow:Destroy()
            if PlayerWindow.Destroyed then
                return
            end

            PlayerWindow.Destroyed = true

            if Items["Window"]
                and Items["Window"].Instance
            then
                Items["Window"].Instance:
                    Destroy()
            end
        end

        PlayerWindow.Elements = Items

        return PlayerWindow
    end

    Library.Sections.Listbox = function(self, Data)
        Data = Data or { }

        local Listbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Items = Data.Items or Data.items or { },
            Multi = Data.Multi or Data.multi or false,
            Default = Data.Default or Data.default,
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Callback = Data.Callback or Data.callback or function() end,
            Size = Data.Size or Data.size or 165,

            Value = nil,
            Options = { },
            Class = "Listbox"
        }

        local Items = { }

        local ListTween =
            TweenInfo.new(
                0.12,
                Enum.EasingStyle.Quad,
                Enum.EasingDirection.Out
            )

        Items["Listbox"] =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Listbox.Section.
                        Elements[
                            "Content"
                        ].
                        Instance,

                    Name = string.char(0),
                    BackgroundTransparency = 1,

                    Size =
                        UDim2New(
                            1,
                            0,
                            0,
                            Listbox.Size
                        ),

                    BorderSizePixel = 0
                }
            )

        Items["RealListbox"] =
            Instances:Create(
                "ScrollingFrame",
                {
                    Parent =
                        Items["Listbox"].
                        Instance,

                    ScrollBarImageColor3 =
                        Library.Theme.Accent,

                    Active = true,

                    AutomaticCanvasSize =
                        Enum.AutomaticSize.Y,

                    ScrollBarThickness = 2,

                    VerticalScrollBarInset =
                        Enum.ScrollBarInset.ScrollBar,

                    ScrollingDirection =
                        Enum.ScrollingDirection.Y,

                    ElasticBehavior =
                        Enum.ElasticBehavior.Never,

                    Size = UDim2New(1, 0, 1, 0),
                    Name = string.char(0),

                    BackgroundColor3 =
                        Library.Theme[
                            "Page Background"
                        ],

                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0),
                    ClipsDescendants = true
                }
            )

        Items["RealListbox"]:AddToTheme({
            ScrollBarImageColor3 = "Accent",
            BackgroundColor3 =
                "Page Background"
        })

        Library:ApplyGlass(
            Items["RealListbox"],
            "Panel",
            4
        )

        local Layout =
            InstanceNew("UIListLayout")

        Layout.Padding = UDimNew(0, 1)
        Layout.SortOrder =
            Enum.SortOrder.LayoutOrder

        Layout.Parent =
            Items["RealListbox"].
            Instance

        local Padding =
            InstanceNew("UIPadding")

        Padding.PaddingTop =
            UDimNew(0, 3)

        Padding.PaddingBottom =
            UDimNew(0, 3)

        Padding.Parent =
            Items["RealListbox"].
            Instance

        local function Emit()
            Library.Flags[Listbox.Flag] =
                Listbox.Value

            if Listbox.Callback then
                Library:SafeCall(
                    Listbox.Callback,
                    Listbox.Value
                )
            end
        end

        local function ClearVisuals()
            for _,
                OptionData in pairs(
                    Listbox.Options
                )
            do
                OptionData.Selected = false
                OptionData:Toggle(false)
            end
        end

        function Listbox:Set(Option, Silent)
            if Option == nil then
                ClearVisuals()
                Listbox.Value = nil
                Library.Flags[Listbox.Flag] = nil

                if not Silent then
                    Emit()
                end

                return
            end

            if Listbox.Multi then
                if type(Option) ~= "table" then
                    return
                end

                ClearVisuals()
                Listbox.Value = { }

                for _,
                    Value in ipairs(Option)
                do
                    local OptionData =
                        Listbox.Options[Value]

                    if OptionData then
                        OptionData.Selected = true
                        OptionData:Toggle(true)

                        table.insert(
                            Listbox.Value,
                            Value
                        )
                    end
                end
            else
                local OptionData =
                    Listbox.Options[Option]

                if not OptionData then
                    return
                end

                ClearVisuals()

                OptionData.Selected = true
                OptionData:Toggle(true)
                Listbox.Value = OptionData.Name
            end

            Library.Flags[Listbox.Flag] =
                Listbox.Value

            if not Silent then
                Emit()
            end
        end

        function Listbox:Get()
            return Listbox.Value
        end

        function Listbox:SetVisibility(Bool)
            Items["Listbox"].Instance.Visible =
                Bool == true
        end

        function Listbox:Remove(Option)
            local OptionData =
                Listbox.Options[Option]

            if not OptionData then
                return
            end

            OptionData.Button:Clean()
            Listbox.Options[Option] = nil
        end

        function Listbox:Refresh(NewItems, Preserve)
            local Previous =
                Preserve ~= false
                and Listbox.Value
                or nil

            local Existing = { }

            for Name in pairs(
                Listbox.Options
            )
            do
                table.insert(
                    Existing,
                    Name
                )
            end

            for _,
                Name in ipairs(Existing)
            do
                Listbox:Remove(Name)
            end

            Listbox.Items =
                NewItems or { }

            for _,
                Value in ipairs(
                    Listbox.Items
                )
            do
                Listbox:Add(Value)
            end

            if Previous
                and Listbox.Options[Previous]
            then
                Listbox:Set(
                    Previous,
                    true
                )
            else
                Listbox:Set(
                    nil,
                    true
                )
            end
        end

        function Listbox:Add(Option)
            Option = tostring(Option)

            local Row =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items["RealListbox"].
                            Instance,

                        FontFace = Library.Font,
                        Text = "",
                        AutoButtonColor = false,
                        Name = string.char(0),

                        BackgroundColor3 =
                            Library.Theme.Element,

                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,

                        Size =
                            UDim2New(1, 0, 0, 22),

                        ZIndex = 5
                    }
                )

            Row:AddToTheme({
                BackgroundColor3 = "Element"
            })

            local Marker =
                Instances:Create(
                    "Frame",
                    {
                        Parent = Row.Instance,
                        Position =
                            UDim2New(0, 0, 0, 4),

                        Size =
                            UDim2New(0, 2, 1, -8),

                        BorderSizePixel = 0,

                        BackgroundColor3 =
                            Library.Theme.Accent,

                        BackgroundTransparency = 1,
                        ZIndex = 6
                    }
                )

            Marker:AddToTheme({
                BackgroundColor3 = "Accent"
            })

            local Text =
                Instances:Create(
                    "TextLabel",
                    {
                        Parent = Row.Instance,
                        FontFace = Library.Font,

                        TextColor3 =
                            Library.Theme.Text,

                        TextTransparency = 0.08,
                        Text = Option,
                        Name = string.char(0),

                        Position =
                            UDim2New(0, 8, 0, 0),

                        Size =
                            UDim2New(1, -14, 1, 0),

                        BackgroundTransparency = 1,

                        TextXAlignment =
                            Enum.TextXAlignment.Left,

                        BorderSizePixel = 0,
                        ZIndex = 6,
                        TextSize = 10
                    }
                )

            Text:AddToTheme({
                TextColor3 = "Text"
            })

            local OptionData = {
                Selected = false,
                Name = Option,
                Text = Text,
                Button = Row,
                Marker = Marker
            }

            function OptionData:Toggle(Active)
                OptionData.Selected =
                    Active == true

                OptionData.Marker:Tween(
                    ListTween,
                    {
                        BackgroundTransparency =
                            Active and 0 or 1
                    }
                )

                OptionData.Button:Tween(
                    ListTween,
                    {
                        BackgroundTransparency =
                            Active and 0.50 or 1
                    }
                )

                OptionData.Text:
                    ChangeItemTheme({
                        TextColor3 =
                            Active
                            and "Accent"
                            or "Text"
                    })

                OptionData.Text:Tween(
                    ListTween,
                    {
                        TextColor3 =
                            Active
                            and Library.Theme.Accent
                            or Library.Theme.Text,

                        TextTransparency =
                            Active and 0 or 0.08
                    }
                )
            end

            Row:OnHover(function()
                if OptionData.Selected then
                    return
                end

                Row:Tween(
                    ListTween,
                    {
                        BackgroundTransparency =
                            0.68
                    }
                )

                Text:Tween(
                    ListTween,
                    {
                        TextTransparency = 0
                    }
                )
            end)

            Row:OnHoverLeave(function()
                if OptionData.Selected then
                    return
                end

                Row:Tween(
                    ListTween,
                    {
                        BackgroundTransparency = 1
                    }
                )

                Text:Tween(
                    ListTween,
                    {
                        TextTransparency = 0.08
                    }
                )
            end)

            Row:Connect(
                "MouseButton1Down",
                function()
                    if Listbox.Multi then
                        local Values =
                            type(Listbox.Value)
                                == "table"
                            and table.clone(
                                Listbox.Value
                            )
                            or { }

                        local Index =
                            table.find(
                                Values,
                                OptionData.Name
                            )

                        if Index then
                            table.remove(
                                Values,
                                Index
                            )
                        else
                            table.insert(
                                Values,
                                OptionData.Name
                            )
                        end

                        Listbox:Set(Values)
                    else
                        Listbox:Set(
                            OptionData.Name
                        )
                    end
                end
            )

            Listbox.Options[Option] =
                OptionData

            return OptionData
        end

        for _,
            Value in ipairs(
                Listbox.Items
            )
        do
            Listbox:Add(Value)
        end

        if Listbox.Default ~= nil then
            Listbox:Set(
                Listbox.Default,
                true
            )
        end

        Library.SetFlags[
            Listbox.Flag
        ] = function(Value)
            Listbox:Set(
                Value,
                true
            )
        end

        return Listbox
    end

getgenv().Library = Library
return Library
