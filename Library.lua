
local LoadingTick = os.clock()
-- Past Owl inspired visual pass based on the supplied references; public API preserved.

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

local Library do
    local UserInputService = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
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
        Flags = { },

        Theme = {
            ["Background"] = FromRGB(9, 9, 16),
            ["Inline"] = FromRGB(12, 12, 21),
            ["Page Background"] = FromRGB(14, 14, 25),
            ["Border"] = FromRGB(24, 24, 42),
            ["Outline"] = FromRGB(35, 35, 58),
            ["Accent"] = FromRGB(112, 136, 255),
            ["Accent Soft"] = FromRGB(32, 39, 79),
            ["Element"] = FromRGB(17, 17, 30),
            ["Hovered Element"] = FromRGB(22, 22, 39),
            ["Text"] = FromRGB(236, 237, 247),
            ["Muted Text"] = FromRGB(105, 106, 137),
            ["Danger"] = FromRGB(255, 101, 128),
            ["Success"] = FromRGB(112, 255, 137),
            ["Text Border"] = FromRGB(9, 9, 16)
        },

        Design = "Past Owl Reference",

        MenuKeybind = Enum.KeyCode.Z,

        Tween = {
            Time = 0.16,
            Style = Enum.EasingStyle.Quint,
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

        UnnamedConnections = 0,
        UnnamedFlags = 0,

        Holder = nil,
        NotifHolder = nil,
        Font = nil,
        KeyList = nil,

        CurrentColorpicker = nil,
        CurrentKeybind = nil,
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

            if Class == "UIStroke" then
                local Parent = NewItem.Instance.Parent

                if Parent
                    and (
                        Parent:IsA("TextLabel")
                        or Parent:IsA("TextButton")
                        or Parent:IsA("TextBox")
                    )
                then
                    NewItem.Instance.Transparency = 1
                end
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
                Transparency = 0.48,
                LineJoinMode = Enum.LineJoinMode.Round
            })

            UIStroke:AddToTheme({Color = "Border"})

            return UIStroke
        end

        Instances.Corner = function(self, Radius)
            if not self.Instance then
                return
            end

            return Instances:Create("UICorner", {
                Parent = self.Instance,
                CornerRadius = UDimNew(0, Radius or 8)
            })
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

            local Gui =
                self.Instance

            local DragHandle =
                Handle
                and (
                    Handle.Instance
                    or Handle
                )
                or Gui

            if DragHandle:IsA(
                "GuiObject"
            ) then
                DragHandle.Active =
                    true
            end

            local Dragging = false
            local DragStart = nil
            local StartPosition = nil
            local TargetPosition = nil
            local ReleasedAt = 0

            local MoveConnection = nil
            local EndConnection = nil
            local RenderConnection = nil

            local DragSpeed =
                tonumber(
                    Smoothness
                )
                or 26

            local function Disconnect(
                Connection
            )
                if Connection then
                    pcall(function()
                        Connection:
                            Disconnect()
                    end)
                end
            end

            local function StopConnections(
                StopRender
            )
                Disconnect(
                    MoveConnection
                )

                Disconnect(
                    EndConnection
                )

                MoveConnection = nil
                EndConnection = nil

                if StopRender then
                    Disconnect(
                        RenderConnection
                    )

                    RenderConnection = nil
                end
            end

            local function FinishDrag()
                if not Dragging then
                    return
                end

                Dragging = false
                ReleasedAt = os.clock()

                StopConnections(
                    false
                )
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

                    StopConnections(
                        true
                    )

                    Dragging = true
                    ReleasedAt = 0

                    DragStart =
                        Vector2New(
                            Input.Position.X,
                            Input.Position.Y
                        )

                    StartPosition =
                        Gui.Position

                    TargetPosition =
                        StartPosition

                    local IsTouch =
                        Input.UserInputType
                        == Enum.UserInputType.Touch

                    MoveConnection =
                        UserInputService.InputChanged:
                        Connect(function(ChangedInput)
                            if Library.Unloaded
                                or not Gui.Parent
                            then
                                FinishDrag()
                                return
                            end

                            local IsMatchingInput =
                                IsTouch
                                and ChangedInput
                                    == Input
                                or not IsTouch
                                and ChangedInput.UserInputType
                                    == Enum.UserInputType.MouseMovement

                            if not Dragging
                                or not IsMatchingInput
                            then
                                return
                            end

                            local CurrentPosition =
                                Vector2New(
                                    ChangedInput.Position.X,
                                    ChangedInput.Position.Y
                                )

                            local Delta =
                                CurrentPosition
                                - DragStart

                            TargetPosition =
                                UDim2New(
                                    StartPosition.X.Scale,
                                    StartPosition.X.Offset
                                        + Delta.X,
                                    StartPosition.Y.Scale,
                                    StartPosition.Y.Offset
                                        + Delta.Y
                                )
                        end)

                    EndConnection =
                        UserInputService.InputEnded:
                        Connect(function(EndedInput)
                            local IsMatchingEnd =
                                IsTouch
                                and EndedInput
                                    == Input
                                or not IsTouch
                                and EndedInput.UserInputType
                                    == Enum.UserInputType.MouseButton1

                            if IsMatchingEnd then
                                FinishDrag()
                            end
                        end)

                    RenderConnection =
                        RunService.RenderStepped:
                        Connect(function(DeltaTime)
                            if Library.Unloaded
                                or not Gui.Parent
                                or not TargetPosition
                            then
                                StopConnections(
                                    true
                                )

                                return
                            end

                            local Alpha =
                                1
                                - math.exp(
                                    -DragSpeed
                                    * math.clamp(
                                        DeltaTime,
                                        0,
                                        0.05
                                    )
                                )

                            Gui.Position =
                                Gui.Position:
                                Lerp(
                                    TargetPosition,
                                    Alpha
                                )

                            if not Dragging then
                                local Current =
                                    Gui.Position

                                local Distance =
                                    math.abs(
                                        TargetPosition.X.Offset
                                        - Current.X.Offset
                                    )
                                    + math.abs(
                                        TargetPosition.Y.Offset
                                        - Current.Y.Offset
                                    )

                                if Distance < 0.35
                                    or os.clock()
                                        - ReleasedAt
                                        > 0.18
                                then
                                    Gui.Position =
                                        TargetPosition

                                    StopConnections(
                                        true
                                    )
                                end
                            end
                        end)
                end
            )

            return self
        end

        Instances.MakeResizeable = function(
            self,
            Minimum,
            Maximum,
            Smoothness
        )
            if not self.Instance then
                return
            end

            local Gui =
                self.Instance

            local Resizing = false
            local StartMouse = nil
            local StartSize = nil
            local TargetSize = nil
            local ReleasedAt = 0

            local MoveConnection = nil
            local EndConnection = nil
            local RenderConnection = nil

            local ResizeSpeed =
                tonumber(
                    Smoothness
                )
                or 30

            local ResizeButton =
                Instances:Create(
                    "TextButton",
                    {
                        Parent = Gui,
                        AnchorPoint =
                            Vector2New(
                                1,
                                1
                            ),
                        BorderColor3 =
                            FromRGB(
                                0,
                                0,
                                0
                            ),
                        Size =
                            UDim2New(
                                0,
                                10,
                                0,
                                10
                            ),
                        Position =
                            UDim2New(
                                1,
                                0,
                                1,
                                0
                            ),
                        Name = "\0",
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        AutoButtonColor = false,
                        Visible = true,
                        Text = "",
                        Active = true
                    }
                )

            local function Disconnect(
                Connection
            )
                if Connection then
                    pcall(function()
                        Connection:
                            Disconnect()
                    end)
                end
            end

            local function StopConnections(
                StopRender
            )
                Disconnect(
                    MoveConnection
                )

                Disconnect(
                    EndConnection
                )

                MoveConnection = nil
                EndConnection = nil

                if StopRender then
                    Disconnect(
                        RenderConnection
                    )

                    RenderConnection = nil
                end
            end

            local function FinishResize()
                if not Resizing then
                    return
                end

                Resizing = false
                ReleasedAt = os.clock()

                StopConnections(
                    false
                )
            end

            ResizeButton:Connect(
                "InputBegan",
                function(Input)
                    if Input.UserInputType
                            ~= Enum.UserInputType.MouseButton1
                        and Input.UserInputType
                            ~= Enum.UserInputType.Touch
                    then
                        return
                    end

                    StopConnections(
                        true
                    )

                    Resizing = true
                    ReleasedAt = 0
                    StartMouse = Input.Position
                    StartSize = Gui.AbsoluteSize
                    TargetSize = Gui.Size

                    local IsTouch =
                        Input.UserInputType
                        == Enum.UserInputType.Touch

                    MoveConnection =
                        UserInputService.InputChanged:
                        Connect(function(ChangedInput)
                            if Library.Unloaded
                                or not Gui.Parent
                            then
                                FinishResize()
                                return
                            end

                            local IsMatchingInput =
                                IsTouch
                                and ChangedInput
                                    == Input
                                or not IsTouch
                                and ChangedInput.UserInputType
                                    == Enum.UserInputType.MouseMovement

                            if not Resizing
                                or not IsMatchingInput
                            then
                                return
                            end

                            local Delta =
                                ChangedInput.Position
                                - StartMouse

                            local MaximumSize =
                                Maximum
                                or Gui.Parent.AbsoluteSize

                            local Width =
                                math.clamp(
                                    StartSize.X
                                        + Delta.X,
                                    Minimum.X,
                                    MaximumSize.X
                                )

                            local Height =
                                math.clamp(
                                    StartSize.Y
                                        + Delta.Y,
                                    Minimum.Y,
                                    MaximumSize.Y
                                )

                            TargetSize =
                                UDim2New(
                                    0,
                                    Width,
                                    0,
                                    Height
                                )
                        end)

                    EndConnection =
                        UserInputService.InputEnded:
                        Connect(function(EndedInput)
                            local IsMatchingEnd =
                                IsTouch
                                and EndedInput
                                    == Input
                                or not IsTouch
                                and EndedInput.UserInputType
                                    == Enum.UserInputType.MouseButton1

                            if IsMatchingEnd then
                                FinishResize()
                            end
                        end)

                    RenderConnection =
                        RunService.RenderStepped:
                        Connect(function(DeltaTime)
                            if Library.Unloaded
                                or not Gui.Parent
                                or not TargetSize
                            then
                                StopConnections(
                                    true
                                )

                                return
                            end

                            local Alpha =
                                1
                                - math.exp(
                                    -ResizeSpeed
                                    * math.clamp(
                                        DeltaTime,
                                        0,
                                        0.05
                                    )
                                )

                            Gui.Size =
                                Gui.Size:
                                Lerp(
                                    TargetSize,
                                    Alpha
                                )

                            if not Resizing then
                                local Current =
                                    Gui.Size

                                local Distance =
                                    math.abs(
                                        TargetSize.X.Offset
                                        - Current.X.Offset
                                    )
                                    + math.abs(
                                        TargetSize.Y.Offset
                                        - Current.Y.Offset
                                    )

                                if Distance < 0.35
                                    or os.clock()
                                        - ReleasedAt
                                        > 0.18
                                then
                                    Gui.Size =
                                        TargetSize

                                    StopConnections(
                                        true
                                    )
                                end
                            end
                        end)
                end
            )

            return ResizeButton
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

    Library.Font = Font.fromEnum(Enum.Font.GothamMedium)
    Library.FontName = "Gotham Medium"

    Library.Holder = Instances:Create("ScreenGui", {
        Parent = gethui(),
        Name = "\0",
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
        AnchorPoint = Vector2New(0, 0),
        BackgroundTransparency = 1,
        Position = UDim2New(0, 16, 0, 16),
        Name = "\0",
        Size = UDim2New(0, 210, 1, -32),
        BorderSizePixel = 0,
        BackgroundColor3 = FromRGB(255, 255, 255)
    })

    Instances:Create("UIListLayout", {
        Parent = Library.NotifHolder.Instance,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDimNew(0, 9)
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

        local Holder =
            self.Holder

        self.Holder = nil
        self.NotifHolder = nil
        self.KeyList = nil
        self.CurrentKeybind = nil
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
        Item = Item.Instance or Item

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

    Library.GetConfig = function(self)
        local Config = { }

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Library.Flags do
                if type(Value) == "table" and Value.Key then
                    Config[Index] = {Key = tostring(Value.Key), Mode = Value.Mode}
                elseif type(Value) == "table" and Value.Color then
                    Config[Index] = {Color = "#" .. Value.HexValue, Alpha = Value.Alpha}
                else
                    Config[Index] = Value
                end
            end
        end)

        return HttpService:JSONEncode(Config)
    end

    Library.LoadConfig = function(self, Config)
        local Decoded = HttpService:JSONDecode(Config)

        local Success, Result = Library:SafeCall(function()
            for Index, Value in Decoded do
                local SetFunction = Library.SetFlags[Index]

                if not SetFunction then
                    continue
                end

                if type(Value) == "table" and Value.Key then
                    SetFunction(Value)
                elseif type(Value) == "table" and Value.Color then
                    SetFunction(Value.Color, Value.Alpha)
                else
                    SetFunction(Value)
                end
            end
        end)

        if Success then
            Library:Notification("Successfully loaded config", 5, Color3.fromRGB(0, 255, 0))
        end
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

        writefile(
            Path,
            self:GetConfig()
        )

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
                "\0"
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
        Item = Item.Instance or Item

        if not self.ThemeMap[Item] then
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
            Frame.Instance
            or Frame

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
        local Watermark = { }
        local Items = { }

        Items["Watermark"] = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            AnchorPoint = Vector2New(0, 0),
            Position = UDim2New(0, 14, 0, 14),
            Name = "\0",
            Size = UDim2New(0, 0, 0, 28),
            AutomaticSize = Enum.AutomaticSize.X,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline
        })  Items["Watermark"]:AddToTheme({BackgroundColor3 = "Inline"})

        Items["Watermark"]:Corner(3)
        Items["Watermark"]:Border()
        Items["Watermark"]:MakeDraggable()

        Instances:Create("UIPadding", {
            Parent = Items["Watermark"].Instance,
            PaddingLeft = UDimNew(0, 10),
            PaddingRight = UDimNew(0, 10)
        })

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["Watermark"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = tostring(Name or "PRODUCT | SERVER | 144FPS | 65PING | 12:15PM"),
            Name = "\0",
            Size = UDim2New(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

        function Watermark:SetVisibility(Bool)
            Items["Watermark"].Instance.Visible = Bool == true
        end

        function Watermark:SetText(Text)
            Items["Title"].Instance.Text = tostring(Text)
        end

        function Watermark:GetText()
            return Items["Title"].Instance.Text
        end

        function Watermark:Destroy()
            if Items["Watermark"] and Items["Watermark"].Instance then
                Items["Watermark"].Instance:Destroy()
            end
        end

        Watermark.Frame = Items["Watermark"].Instance
        Watermark.Label = Items["Title"].Instance
        return Watermark
    end

    Library.Notification = function(self, Text, Duration, Color, Icon, Title)
        Duration = tonumber(Duration) or 3
        Color = Color or Library.Theme.Accent

        local Body = tostring(Text or "Notification")
        local Header = tostring(Title or "Notification")

        if type(Text) == "table" then
            Header = tostring(Text.Title or Text.title or Text[1] or Header)
            Body = tostring(Text.Text or Text.text or Text.Message or Text.message or Text[2] or "")
        end

        local Items = { }

        Items["Notification"] = Instances:Create("CanvasGroup", {
            Parent = Library.NotifHolder.Instance,
            Name = "\0",
            Size = UDim2New(0, 182, 0, 57),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline,
            GroupTransparency = 1
        })  Items["Notification"]:AddToTheme({BackgroundColor3 = "Inline"})

        Items["Notification"]:Corner(3)
        Items["Notification"]:Border()

        Items["Title"] = Instances:Create("TextLabel", {
            Parent = Items["Notification"].Instance,
            FontFace = Library.Font,
            TextColor3 = Color,
            Text = Header,
            Name = "\0",
            Position = UDim2New(0, 10, 0, 8),
            Size = UDim2New(1, -20, 0, 14),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 11
        })

        Items["Body"] = Instances:Create("TextLabel", {
            Parent = Items["Notification"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = Body,
            Name = "\0",
            Position = UDim2New(0, 10, 0, 23),
            Size = UDim2New(1, -20, 0, 15),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextSize = 11
        })  Items["Body"]:AddToTheme({TextColor3 = "Text"})

        Items["Track"] = Instances:Create("Frame", {
            Parent = Items["Notification"].Instance,
            Name = "\0",
            Position = UDim2New(0, 10, 1, -10),
            Size = UDim2New(1, -20, 0, 3),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        })  Items["Track"]:AddToTheme({BackgroundColor3 = "Element"})
        Items["Track"]:Corner(99)

        Items["Progress"] = Instances:Create("Frame", {
            Parent = Items["Track"].Instance,
            Name = "\0",
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color
        })
        Items["Progress"]:Corner(99)

        local Scale = Instances:Create("UIScale", {
            Parent = Items["Notification"].Instance,
            Scale = 0.97
        })

        Tween:Create(Items["Notification"].Instance, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            GroupTransparency = 0
        }, true)
        Tween:Create(Scale.Instance, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Scale = 1
        }, true)
        Tween:Create(Items["Progress"].Instance, TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {
            Size = UDim2New(0, 0, 1, 0)
        }, true)

        Library:Thread(function()
            task.wait(Duration)

            if not Items["Notification"].Instance.Parent then
                return
            end

            Tween:Create(Items["Notification"].Instance, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                GroupTransparency = 1
            }, true)
            Tween:Create(Scale.Instance, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Scale = 0.97
            }, true)

            task.wait(0.18)
            Items["Notification"]:Clean()
        end)
    end

    Library.KeybindList = function(self)
        local KeybindList = { }
        self.KeyList = KeybindList

        local Items = { } do
            Items["KeybindList"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(24, 24, 42),
                AnchorPoint = Vector2New(0, 0.5),
                Name = "\0",
                Position = UDim2New(0, 15, 0.5, 0),
                Size = UDim2New(0, 0, 0, 18),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = FromRGB(9, 9, 16)
            })  Items["KeybindList"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["KeybindList"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["KeybindList"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(35, 35, 58)
            }):AddToTheme({Color = "Outline"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                Position = UDim2New(0, -5, 0, -5),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 10, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(112, 136, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Instances:Create("UIPadding", {
                Parent = Items["KeybindList"].Instance,
                PaddingTop = UDimNew(0, 5),
                PaddingBottom = UDimNew(0, 5),
                PaddingRight = UDimNew(0, 5),
                PaddingLeft = UDimNew(0, 5)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["KeybindList"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Keybinds",
                Name = "\0",
                Size = UDim2New(0, 100, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 0, 0, -1),
                BorderSizePixel = 0,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 5, 0, 19),
                BorderColor3 = FromRGB(0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
        end

        function KeybindList:Add(Mode, Name, Key)
            local NewKey = Instances:Create("TextLabel", {
                Parent = Items["Content"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "(" .. Mode .. ") " .. Name .. " - " .. Key,
                Name = "\0",
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  NewKey:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = NewKey.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            function NewKey:Set(Mode, Name, Key)
                NewKey.Instance.Text = "(" .. Mode .. ") " .. Name .. " - " .. Key
            end

            function NewKey:SetStatus(Status)
                if Status == "Active" then
                    NewKey:Tween(nil, {TextColor3 = Library.Theme.Accent})
                    NewKey:ChangeItemTheme({TextColor3 = "Accent"})
                else
                    NewKey:Tween(nil, {TextColor3 = Library.Theme.Text})
                    NewKey:ChangeItemTheme({TextColor3 = "Text"})
                end
            end

            return NewKey
        end

        function KeybindList:SetVisibility(Bool)
            Items["KeybindList"].Instance.Visible = Bool
        end

        return KeybindList
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
            OpenedAt = 0,
            SlidingMode = nil,
            Color = FromRGB(255, 255, 255),
            Class = "Colorpicker"
        }

        Library.Flags[Data.Flag] = { }
        local Items = { }

        Items["ColorpickerButton"] = Instances:Create("TextButton", {
            Parent = Data.Parent.Instance,
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2New(1, 0.5),
            Name = "\0",
            Position = UDim2New(1, -20, 0.5, 0),
            Size = UDim2New(0, 13, 0, 13),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255),
            ZIndex = 250,
            Active = true,
            Selectable = false
        })
        Items["ColorpickerButton"]:Corner(99)
        Items["ColorpickerButton"]:Border()

        function Colorpicker:CalculateCount(Index, YScale, YOffset)
            local Slot = math.max(tonumber(Index) or 1, 1)
            Items["ColorpickerButton"].Instance.Position = UDim2New(
                1,
                -(20 + ((Slot - 1) * 19)),
                YScale or 0.5,
                YOffset or 0
            )
        end

        Colorpicker:CalculateCount(Data.Count)

        Items["ColorpickerWindow"] = Instances:Create("Frame", {
            Parent = Library.Holder.Instance,
            Name = "\0",
            Position = UDim2New(0, 0, 0, 0),
            Visible = false,
            Size = UDim2New(0, 224, 0, 208),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline,
            ZIndex = 1000,
            Active = true
        })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Inline"})
        Items["ColorpickerWindow"]:Corner(3)
        Items["ColorpickerWindow"]:Border()

        Items["Palette"] = Instances:Create("TextButton", {
            Parent = Items["ColorpickerWindow"].Instance,
            Text = "",
            AutoButtonColor = false,
            Name = "\0",
            Position = UDim2New(0, 8, 0, 8),
            Size = UDim2New(1, -16, 0, 112),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 0, 0),
            ZIndex = 1001
        })
        Items["Palette"]:Corner(2)

        Items["Saturation"] = Instances:Create("ImageLabel", {
            Parent = Items["Palette"].Instance,
            Image = Library:GetImage("Saturation"),
            BackgroundTransparency = 1,
            Name = "\0",
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            ZIndex = 1002
        })

        Items["Value"] = Instances:Create("ImageLabel", {
            Parent = Items["Palette"].Instance,
            Image = Library:GetImage("Value"),
            BackgroundTransparency = 1,
            Name = "\0",
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            ZIndex = 1003
        })

        Items["PaletteDragger"] = Instances:Create("Frame", {
            Parent = Items["Palette"].Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Name = "\0",
            Size = UDim2New(0, 6, 0, 6),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 1004
        })
        Instances:Create("UIStroke", {
            Parent = Items["PaletteDragger"].Instance,
            Color = FromRGB(255, 255, 255),
            Thickness = 1,
            Transparency = 0
        })
        Items["PaletteDragger"]:Corner(99)

        Items["Hue"] = Instances:Create("TextButton", {
            Parent = Items["ColorpickerWindow"].Instance,
            Text = "",
            AutoButtonColor = false,
            Name = "\0",
            Position = UDim2New(0, 8, 0, 128),
            Size = UDim2New(1, -16, 0, 8),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255),
            ZIndex = 1001
        })
        Items["Hue"]:Corner(99)
        Instances:Create("UIGradient", {
            Parent = Items["Hue"].Instance,
            Color = RGBSequence{
                RGBSequenceKeypoint(0.00, FromRGB(255, 0, 0)),
                RGBSequenceKeypoint(0.17, FromRGB(255, 255, 0)),
                RGBSequenceKeypoint(0.33, FromRGB(0, 255, 0)),
                RGBSequenceKeypoint(0.50, FromRGB(0, 255, 255)),
                RGBSequenceKeypoint(0.67, FromRGB(0, 0, 255)),
                RGBSequenceKeypoint(0.83, FromRGB(255, 0, 255)),
                RGBSequenceKeypoint(1.00, FromRGB(255, 0, 0))
            }
        })

        Items["HueDragger"] = Instances:Create("Frame", {
            Parent = Items["Hue"].Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Name = "\0",
            Position = UDim2New(0, 0, 0.5, 0),
            Size = UDim2New(0, 5, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 1003
        })
        Instances:Create("UIStroke", {
            Parent = Items["HueDragger"].Instance,
            Color = FromRGB(255, 255, 255),
            Thickness = 1
        })
        Items["HueDragger"]:Corner(99)

        Items["Alpha"] = Instances:Create("TextButton", {
            Parent = Items["ColorpickerWindow"].Instance,
            Text = "",
            AutoButtonColor = false,
            Name = "\0",
            Position = UDim2New(0, 8, 0, 143),
            Size = UDim2New(1, -16, 0, 8),
            BorderSizePixel = 0,
            BackgroundColor3 = FromRGB(255, 255, 255),
            ZIndex = 1001
        })
        Items["Alpha"]:Corner(99)

        Items["Checkers"] = Instances:Create("ImageLabel", {
            Parent = Items["Alpha"].Instance,
            ScaleType = Enum.ScaleType.Tile,
            Image = Library:GetImage("Checkers"),
            TileSize = UDim2New(0, 6, 0, 6),
            Name = "\0",
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            ZIndex = 1001
        })
        Instances:Create("UIGradient", {
            Parent = Items["Checkers"].Instance,
            Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
        })
        Instances:Create("UIGradient", {
            Parent = Items["Alpha"].Instance,
            Transparency = NumSequence{NumSequenceKeypoint(0, 1), NumSequenceKeypoint(1, 0)}
        })

        Items["AlphaDragger"] = Instances:Create("Frame", {
            Parent = Items["Alpha"].Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Name = "\0",
            Position = UDim2New(0, 0, 0.5, 0),
            Size = UDim2New(0, 5, 0, 12),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 1003
        })
        Instances:Create("UIStroke", {
            Parent = Items["AlphaDragger"].Instance,
            Color = FromRGB(255, 255, 255),
            Thickness = 1
        })
        Items["AlphaDragger"]:Corner(99)

        Items["HexBackground"] = Instances:Create("Frame", {
            Parent = Items["ColorpickerWindow"].Instance,
            Name = "\0",
            Position = UDim2New(0, 8, 0, 158),
            Size = UDim2New(1, -48, 0, 27),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element,
            ZIndex = 1001
        })  Items["HexBackground"]:AddToTheme({BackgroundColor3 = "Element"})
        Items["HexBackground"]:Corner(2)
        Items["HexBackground"]:Border()

        Items["HexInput"] = Instances:Create("TextBox", {
            Parent = Items["HexBackground"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            PlaceholderColor3 = Library.Theme["Muted Text"],
            Text = "#FFFFFF",
            PlaceholderText = "#FFFFFF",
            ClearTextOnFocus = false,
            Name = "\0",
            Position = UDim2New(0, 8, 0, 0),
            Size = UDim2New(1, -16, 1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 11,
            ZIndex = 1002
        })  Items["HexInput"]:AddToTheme({TextColor3 = "Text", PlaceholderColor3 = "Muted Text"})

        Items["Edit"] = Instances:Create("TextLabel", {
            Parent = Items["ColorpickerWindow"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            TextTransparency = 0.25,
            Text = "✎",
            Name = "\0",
            Position = UDim2New(1, -36, 0, 158),
            Size = UDim2New(0, 28, 0, 27),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element,
            TextSize = 11,
            ZIndex = 1001
        })  Items["Edit"]:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})
        Items["Edit"]:Corner(2)
        Items["Edit"]:Border()

        Items["Plus"] = Instances:Create("TextLabel", {
            Parent = Items["ColorpickerWindow"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            TextTransparency = 0.35,
            Text = "+",
            Name = "\0",
            Position = UDim2New(0, 8, 0, 188),
            Size = UDim2New(0, 18, 0, 14),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 11,
            ZIndex = 1001
        })  Items["Plus"]:AddToTheme({TextColor3 = "Text"})

        Colorpicker.Button = Items["ColorpickerButton"].Instance
        Colorpicker.Window = Items["ColorpickerWindow"].Instance
        TableInsert(Library.Colorpickers, Colorpicker)

        if not Library.ColorpickerOverlay or not Library.ColorpickerOverlay.Parent then
            local Overlay = Instances:Create("TextButton", {
                Parent = Library.Holder.Instance,
                Name = "\0",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                Visible = false,
                Active = true,
                Modal = false,
                ZIndex = 900
            })
            Library.ColorpickerOverlay = Overlay.Instance
            local OverlayConnection = Overlay.Instance.MouseButton1Down:Connect(function()
                local Current = Library.CurrentColorpicker
                if Current and Current.IsOpen then
                    Current:SetOpen(false)
                end
            end)
            TableInsert(Library.CoreConnections, OverlayConnection)
        end

        function Colorpicker:ToggleOpen()
            local CurrentTime = os.clock()
            if CurrentTime - self.LastToggleAt < 0.12 then
                return
            end
            self.LastToggleAt = CurrentTime
            self:SetOpen(not self.IsOpen)
        end

        function Colorpicker:SetOpen(Bool)
            Bool = Bool == true
            if Bool and Library.CurrentColorpicker and Library.CurrentColorpicker ~= self then
                Library.CurrentColorpicker:SetOpen(false)
            end

            local Window = Items["ColorpickerWindow"].Instance
            local Overlay = Library.ColorpickerOverlay
            self.IsOpen = Bool

            if Bool then
                local ParentPosition = Data.Parent.Instance.AbsolutePosition
                local ParentSize = Data.Parent.Instance.AbsoluteSize
                local ViewportSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2New(1920, 1080)
                local WindowSize = Vector2New(224, 208)
                local X = MathClamp(ParentPosition.X + ParentSize.X - WindowSize.X, 6, math.max(ViewportSize.X - WindowSize.X - 6, 6))
                local Below = ParentPosition.Y + ParentSize.Y + 5
                local Above = ParentPosition.Y - WindowSize.Y - 5
                local Y = Below + WindowSize.Y <= ViewportSize.Y and Below or math.max(Above, 6)

                Window.Position = UDim2New(0, X, 0, Y)
                Window.Visible = true
                Window.Active = true
                Window.ZIndex = 1000
                if Overlay then
                    Overlay.Visible = true
                    Overlay.Active = true
                end
                self.OpenedAt = os.clock()
                Library.CurrentColorpicker = self
            else
                self:EndSlide()
                Window.Visible = false
                Window.Active = false
                if Overlay then
                    Overlay.Visible = false
                    Overlay.Active = false
                end
                if Library.CurrentColorpicker == self then
                    Library.CurrentColorpicker = nil
                end
            end
        end

        function Colorpicker:Get()
            return self.Color, self.Alpha
        end

        function Colorpicker:SetVisibility(Bool)
            Data.Parent.Instance.Visible = Bool == true
        end

        function Colorpicker:Set(Color, Alpha)
            if type(Color) == "table" then
                Alpha = Alpha or Color[4]
                Color = FromRGB(Color[1], Color[2], Color[3])
            elseif type(Color) == "string" then
                local Hex = Color:gsub("#", "")
                local Success, Result = pcall(FromHex, "#" .. Hex)
                if Success then
                    Color = Result
                end
            end

            if typeof(Color) ~= "Color3" then
                return
            end

            self.Hue, self.Saturation, self.Value = Color:ToHSV()
            self.Alpha = MathClamp(tonumber(Alpha) or 0, 0, 1)
            self.Color = FromHSV(self.Hue, self.Saturation, self.Value)
            self.HexValue = self.Color:ToHex()

            Items["PaletteDragger"].Instance.Position = UDim2New(MathClamp(self.Saturation, 0, 0.989), 0, MathClamp(1 - self.Value, 0, 0.989), 0)
            Items["HueDragger"].Instance.Position = UDim2New(MathClamp(self.Hue, 0, 0.994), 0, 0.5, 0)
            Items["AlphaDragger"].Instance.Position = UDim2New(MathClamp(self.Alpha, 0, 0.994), 0, 0.5, 0)
            self:Update()
        end

        function Colorpicker:Update(IsFromAlpha)
            self.Color = FromHSV(self.Hue, self.Saturation, self.Value)
            self.HexValue = self.Color:ToHex()
            Library.Flags[Data.Flag] = {Color = self.Color, HexValue = self.HexValue, Alpha = self.Alpha}
            Items["ColorpickerButton"].Instance.BackgroundColor3 = self.Color
            Items["Palette"].Instance.BackgroundColor3 = FromHSV(self.Hue, 1, 1)
            Items["HexInput"].Instance.Text = "#" .. self.HexValue
            if not IsFromAlpha then
                Items["Alpha"].Instance.BackgroundColor3 = self.Color
            end
            if Data.Callback then
                Library:SafeCall(Data.Callback, self.Color, self.Alpha)
            end
        end

        function Colorpicker:UpdateFromMouse()
            local MousePosition = Library:GetPointerPosition()
            local Item = Items[self.SlidingMode]
            if not Item then
                return
            end
            local Position = Item.Instance.AbsolutePosition
            local Size = Item.Instance.AbsoluteSize

            if self.SlidingMode == "Palette" then
                if Size.X <= 0 or Size.Y <= 0 then return end
                local X = MathClamp((MousePosition.X - Position.X) / Size.X, 0, 0.989)
                local Y = MathClamp((MousePosition.Y - Position.Y) / Size.Y, 0, 0.989)
                self.Saturation = X
                self.Value = 1 - Y
                Items["PaletteDragger"].Instance.Position = UDim2New(X, 0, Y, 0)
                self:Update()
            elseif self.SlidingMode == "Hue" then
                if Size.X <= 0 then return end
                local X = MathClamp((MousePosition.X - Position.X) / Size.X, 0, 0.994)
                self.Hue = X
                Items["HueDragger"].Instance.Position = UDim2New(X, 0, 0.5, 0)
                self:Update()
            elseif self.SlidingMode == "Alpha" then
                if Size.X <= 0 then return end
                local X = MathClamp((MousePosition.X - Position.X) / Size.X, 0, 0.994)
                self.Alpha = X
                Items["AlphaDragger"].Instance.Position = UDim2New(X, 0, 0.5, 0)
                self:Update(true)
            end
        end

        function Colorpicker:BeginSlide(Mode)
            self.SlidingMode = Mode
            Library.ActiveColorpicker = self
            self:UpdateFromMouse()
        end

        function Colorpicker:EndSlide()
            self.SlidingMode = nil
            if Library.ActiveColorpicker == self then
                Library.ActiveColorpicker = nil
            end
        end

        Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
            Colorpicker:ToggleOpen()
        end)

        for _, Mode in ipairs({"Palette", "Hue", "Alpha"}) do
            Items[Mode]:Connect("InputBegan", function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Colorpicker:BeginSlide(Mode)
                end
            end)
        end

        Items["HexInput"]:Connect("FocusLost", function()
            local Hex = Items["HexInput"].Instance.Text:gsub("#", "")
            if #Hex == 6 then
                local Success, Result = pcall(FromHex, "#" .. Hex)
                if Success then
                    Colorpicker:Set(Result, Colorpicker.Alpha)
                    return
                end
            end
            Items["HexInput"].Instance.Text = "#" .. Colorpicker.HexValue
        end)

        Library:Connect(UserInputService.InputBegan, function(Input)
            if not Colorpicker.IsOpen then return end
            if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
            if os.clock() - Colorpicker.OpenedAt < 0.18 then return end
            if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) or Library:IsMouseOverFrame(Items["ColorpickerButton"]) then return end
            Colorpicker:SetOpen(false)
        end)

        if not Library.ColorpickerConnection then
            Library.ColorpickerConnection = Library:Connect(RunService.RenderStepped, function()
                local Active = Library.ActiveColorpicker
                if Active and Active.IsOpen and Active.SlidingMode then
                    Active:UpdateFromMouse()
                end
            end, "Library_Colorpicker_Renderer")
        end

        if not Library.ColorpickerInputConnection then
            Library.ColorpickerInputConnection = Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    local Active = Library.ActiveColorpicker
                    if Active then Active:EndSlide() end
                end
            end, "Library_Colorpicker_InputEnded")
        end

        if Data.Default then
            Colorpicker:Set(Data.Default, Data.Alpha)
        end

        Library.SetFlags[Data.Flag] = function(Color, Alpha)
            Colorpicker:Set(Color, Alpha)
        end

        return Colorpicker
    end

    local function ResolveKey(
        Value
    )
        if typeof(Value)
            == "EnumItem"
        then
            return Value
        end

        if type(Value)
            ~= "string"
        then
            return nil
        end

        local Clean =
            Value:gsub(
                "^Enum%.KeyCode%.",
                ""
            ):
            gsub(
                "^Enum%.UserInputType%.",
                ""
            )

        local Success,
            Result =
            pcall(function()
                return Enum.KeyCode[
                    Clean
                ]
            end)

        if Success
            and Result
        then
            return Result
        end

        Success,
            Result =
            pcall(function()
                return Enum.UserInputType[
                    Clean
                ]
            end)

        if Success then
            return Result
        end

        return nil
    end

    local function FormatKey(
        Key
    )
        if not Key then
            return "None"
        end

        if Key
            == Enum.UserInputType.MouseButton1
        then
            return "MB1"
        end

        if Key
            == Enum.UserInputType.MouseButton2
        then
            return "MB2"
        end

        if Key
            == Enum.UserInputType.MouseButton3
        then
            return "MB3"
        end

        return Keys[
            Key.Name
        ]
        or Key.Name
        or "None"
    end

    local function InputMatchesKey(
        Input,
        Key
    )
        if not Key then
            return false
        end

        if Key.EnumType
            == Enum.KeyCode
        then
            return Input.KeyCode
                == Key
        end

        if Key.EnumType
            == Enum.UserInputType
        then
            return Input.UserInputType
                == Key
        end

        return false
    end

    Library.CreateKeybind = function(
        self,
        Data
    )
        local Keybind = {
            Key = nil,
            Value = "None",
            Mode =
                Data.Mode
                or "Toggle",
            Toggled = false,
            IsOpen = false,
            Picking = false,
            Class = "Keybind"
        }

        Library.Flags[
            Data.Flag
        ] = {}

        local KeyListItem
        local PickConnection

        local Items = {}

        Items["KeyButton"] =
            Instances:Create(
                "TextButton",
                {
                    Parent =
                        Data.Parent.Instance,
                    FontFace =
                        Library.Font,
                    TextColor3 =
                        FromRGB(
                            0,
                            0,
                            0
                        ),
                    BorderColor3 =
                        FromRGB(
                            27,
                            27,
                            32
                        ),
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint =
                        Vector2New(
                            1,
                            0
                        ),
                    Size =
                        UDim2New(
                            0,
                            0,
                            1,
                            1
                        ),
                    Name = "\0",
                    Position =
                        UDim2New(
                            1,
                            0,
                            0,
                            0
                        ),
                    BorderSizePixel = 0,
                    AutomaticSize =
                        Enum.AutomaticSize.X,
                    TextSize = 12,
                    BackgroundColor3 =
                        FromRGB(
                            15,
                            15,
                            20
                        )
                }
            )

        Items["KeyButton"]:
            AddToTheme({
                BackgroundColor3 =
                    "Background",
                BorderColor3 =
                    "Outline"
            })

        Instances:Create(
            "UIStroke",
            {
                Parent =
                    Items[
                        "KeyButton"
                    ].Instance,
                ApplyStrokeMode =
                    Enum.ApplyStrokeMode.Border,
                LineJoinMode =
                    Enum.LineJoinMode.Miter,
                Name = "\0",
                Color =
                    FromRGB(
                        10,
                        10,
                        10
                    )
            }
        ):AddToTheme({
            Color = "Border"
        })

        Items["Text"] =
            Instances:Create(
                "TextLabel",
                {
                    Parent =
                        Items[
                            "KeyButton"
                        ].Instance,
                    FontFace =
                        Library.Font,
                    TextColor3 =
                        FromRGB(
                            215,
                            215,
                            215
                        ),
                    Text = "None",
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position =
                        UDim2New(
                            0,
                            1,
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
                    BorderSizePixel = 0,
                    TextSize = 13
                }
            )

        Items["Text"]:
            AddToTheme({
                TextColor3 =
                    "Text"
            })

        Instances:Create(
            "UIPadding",
            {
                Parent =
                    Items[
                        "KeyButton"
                    ].Instance,
                PaddingRight =
                    UDimNew(
                        0,
                        3
                    ),
                PaddingLeft =
                    UDimNew(
                        0,
                        3
                    ),
                PaddingBottom =
                    UDimNew(
                        0,
                        2
                    )
            }
        )

        Items["Window"] =
            Instances:Create(
                "Frame",
                {
                    Parent =
                        Library.Holder.Instance,
                    BorderColor3 =
                        FromRGB(
                            10,
                            10,
                            10
                        ),
                    AnchorPoint =
                        Vector2New(
                            1,
                            0
                        ),
                    Name = "\0",
                    Position =
                        UDim2New(
                            0,
                            0,
                            0,
                            0
                        ),
                    Size =
                        UDim2New(
                            0,
                            54,
                            0,
                            48
                        ),
                    BorderSizePixel = 0,
                    Visible = false,
                    Active = true,
                    ZIndex = 2000,
                    BackgroundColor3 =
                        FromRGB(
                            15,
                            15,
                            20
                        )
                }
            )

        Items["Window"]:
            AddToTheme({
                BackgroundColor3 =
                    "Background",
                BorderColor3 =
                    "Border"
            })

        local Modes = {}

        for Index,
            ModeName in ipairs({
                "Toggle",
                "Hold",
                "Always"
            })
        do
            local Button =
                Instances:Create(
                    "TextButton",
                    {
                        Parent =
                            Items[
                                "Window"
                            ].Instance,
                        FontFace =
                            Library.Font,
                        TextColor3 =
                            Library.Theme.Text,
                        Text =
                            ModeName,
                        AutoButtonColor = false,
                        Name = "\0",
                        BorderSizePixel = 0,
                        BackgroundTransparency = 1,
                        Position =
                            UDim2New(
                                0,
                                1,
                                0,
                                (
                                    Index - 1
                                ) * 15
                            ),
                        Size =
                            UDim2New(
                                1,
                                -2,
                                0,
                                15
                            ),
                        TextSize = 11,
                        ZIndex = 2001
                    }
                )

            Button:AddToTheme({
                TextColor3 =
                    "Text"
            })

            Modes[
                ModeName
            ] = Button
        end

        if Library.KeyList then
            KeyListItem =
                Library.KeyList:Add(
                    Keybind.Mode,
                    Data.Name,
                    Keybind.Value
                )
        end

        local function UpdateFlag()
            Library.Flags[
                Data.Flag
            ] = {
                Mode =
                    Keybind.Mode,
                Key =
                    Keybind.Key
                    and tostring(
                        Keybind.Key
                    )
                    or "None",
                Toggled =
                    Keybind.Toggled
            }
        end

        local function UpdateVisual()
            Items[
                "Text"
            ].Instance.Text =
                Keybind.Value

            Items[
                "Text"
            ].Instance.Size =
                UDim2New(
                    0,
                    math.max(
                        Items[
                            "Text"
                        ].Instance
                            .TextBounds.X,
                        12
                    ),
                    1,
                    1
                )

            for ModeName,
                Button in pairs(
                    Modes
                )
            do
                local Active =
                    ModeName
                    == Keybind.Mode

                Button.Instance
                    .TextColor3 =
                    Active
                    and Library.Theme.Accent
                    or Library.Theme.Text

                Button:
                    ChangeItemTheme({
                        TextColor3 =
                            Active
                            and "Accent"
                            or "Text"
                    })
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
            return Keybind.Toggled,
                Keybind.Key,
                Keybind.Mode
        end

        function Keybind:SetVisibility(
            Bool
        )
            if not Bool then
                Keybind:SetOpen(
                    false
                )
            end

            Data.Parent.Instance.Visible =
                Bool
        end

        function Keybind:SetOpen(
            Bool
        )
            Bool =
                Bool == true

            if Bool
                and Library.CurrentKeybind
                and Library.CurrentKeybind
                    ~= Keybind
            then
                Library.CurrentKeybind:
                    SetOpen(
                        false
                    )
            end

            local Window =
                Items[
                    "Window"
                ].Instance

            if Bool then
                local Button =
                    Items[
                        "KeyButton"
                    ].Instance

                local ButtonPosition =
                    Button.AbsolutePosition

                local ButtonSize =
                    Button.AbsoluteSize

                local WindowSize =
                    Window.AbsoluteSize

                local ViewportSize =
                    Workspace.CurrentCamera
                    and Workspace.CurrentCamera.ViewportSize
                    or Vector2New(
                        1920,
                        1080
                    )

                local X =
                    MathClamp(
                        ButtonPosition.X
                        + ButtonSize.X
                        - WindowSize.X,
                        4,
                        math.max(
                            ViewportSize.X
                            - WindowSize.X
                            - 4,
                            4
                        )
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
                    Below
                    + WindowSize.Y
                        <= ViewportSize.Y
                    and Below
                    or math.max(
                        Above,
                        4
                    )

                Window.Position =
                    UDim2New(
                        0,
                        X,
                        0,
                        Y
                    )

                Window.Visible =
                    true

                Window.Active =
                    true

                Window.ZIndex =
                    2000

                for _,
                    Descendant in ipairs(
                        Window:GetDescendants()
                    )
                do
                    if Descendant:IsA(
                        "GuiObject"
                    )
                    then
                        Descendant.ZIndex =
                            2001
                    end
                end

                Library.CurrentKeybind =
                    Keybind
            else
                Window.Visible =
                    false

                Window.Active =
                    false

                if Library.CurrentKeybind
                    == Keybind
                then
                    Library.CurrentKeybind =
                        nil
                end
            end

            Keybind.IsOpen =
                Bool
        end

        function Keybind:SetMode(
            Mode,
            Silent
        )
            if not Modes[
                Mode
            ] then
                Mode = "Toggle"
            end

            Keybind.Mode =
                Mode

            if Mode == "Always" then
                Keybind.Toggled =
                    true
            elseif Mode == "Hold" then
                Keybind.Toggled =
                    false
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

        function Keybind:Set(
            Value,
            Silent
        )
            local NewKey =
                Value

            local NewMode =
                Keybind.Mode

            if type(Value)
                == "table"
            then
                NewKey =
                    Value.Key

                NewMode =
                    Value.Mode
                    or NewMode
            end

            local Resolved =
                ResolveKey(
                    NewKey
                )

            if Resolved
                == Enum.KeyCode.Backspace
            then
                Resolved = nil
            end

            Keybind.Key =
                Resolved

            Keybind.Value =
                FormatKey(
                    Resolved
                )

            Keybind.Picking =
                false

            Items[
                "Text"
            ]:
                ChangeItemTheme({
                    TextColor3 =
                        "Text"
                })

            Keybind:SetMode(
                NewMode,
                true
            )

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

        function Keybind:SetState(
            State,
            Silent
        )
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

        function Keybind:Press(
            State
        )
            local Previous =
                Keybind.Toggled

            if Keybind.Mode
                == "Toggle"
            then
                Keybind.Toggled =
                    not Keybind.Toggled
            elseif Keybind.Mode
                == "Hold"
            then
                Keybind.Toggled =
                    State == true
            elseif Keybind.Mode
                == "Always"
            then
                Keybind.Toggled =
                    true
            end

            if Previous
                    ~= Keybind.Toggled
                or Keybind.Mode
                    == "Always"
            then
                Emit()
            end
        end

        Items[
            "KeyButton"
        ]:Connect(
            "MouseButton1Click",
            function()
                if Keybind.Picking then
                    return
                end

                Keybind.Picking =
                    true

                Items[
                    "Text"
                ].Instance.Text =
                    "..."

                Items[
                    "Text"
                ]:
                    ChangeItemTheme({
                        TextColor3 =
                            "Accent"
                    })

                if PickConnection then
                    DisconnectRecord(
                        PickConnection
                    )

                    PickConnection =
                        nil
                end

                PickConnection =
                    Library:Connect(
                        UserInputService.InputBegan,
                        function(
                        Input
                    )
                        local NewKey

                        if Input.UserInputType
                            == Enum.UserInputType.Keyboard
                        then
                            NewKey =
                                Input.KeyCode
                        else
                            NewKey =
                                Input.UserInputType
                        end

                        Keybind:Set(
                            NewKey
                        )

                        if PickConnection then
                            DisconnectRecord(
                                PickConnection
                            )

                            PickConnection =
                                nil
                        end
                    end,
                    "Keybind_Picker_"
                        .. Data.Flag
                )
            end
        )

        Items[
            "KeyButton"
        ]:Connect(
            "MouseButton2Click",
            function()
                if Keybind.Picking then
                    return
                end

                Keybind:SetOpen(
                    not Keybind.IsOpen
                )
            end
        )

        Library:Connect(
            UserInputService.InputBegan,
            function(
                Input,
                GameProcessed
            )
                if Keybind.Picking then
                    return
                end

                if Input.UserInputType
                    == Enum.UserInputType.MouseButton1
                then
                    if Keybind.IsOpen
                        and not Library:
                            IsMouseOverFrame(
                                Items[
                                    "Window"
                                ]
                            )
                    then
                        Keybind:SetOpen(
                            false
                        )
                    end
                end

                if GameProcessed
                    and UserInputService:
                        GetFocusedTextBox()
                then
                    return
                end

                if Input.UserInputType
                        == Enum.UserInputType.MouseButton2
                    and Library:
                        IsMouseOverFrame(
                            Items[
                                "KeyButton"
                            ]
                        )
                then
                    return
                end

                if InputMatchesKey(
                    Input,
                    Keybind.Key
                )
                then
                    if Keybind.Mode
                        == "Toggle"
                    then
                        Keybind:Press()
                    elseif Keybind.Mode
                        == "Hold"
                    then
                        Keybind:Press(
                            true
                        )
                    end
                end
            end
        )

        Library:Connect(
            UserInputService.InputEnded,
            function(Input)
                if Keybind.Mode
                        == "Hold"
                    and InputMatchesKey(
                        Input,
                        Keybind.Key
                    )
                then
                    Keybind:Press(
                        false
                    )
                end
            end
        )

        for ModeName,
            Button in pairs(
                Modes
            )
        do
            Button:Connect(
                "MouseButton1Down",
                function()
                    Keybind:SetMode(
                        ModeName
                    )

                    Keybind:SetOpen(
                        false
                    )
                end
            )
        end

        Keybind:Set(
            {
                Key =
                    Data.Default,
                Mode =
                    Data.Mode
                    or "Toggle"
            },
            true
        )

        Library.SetFlags[
            Data.Flag
        ] = function(Value)
            Keybind:Set(
                Value,
                true
            )
        end

        return Keybind
    end

    Library.Window = function(self, Data)
        Data = Data or { }

        local Window = {
            Name = Data.Name or Data.name or "PRODUCT",
            Size = Data.Size or Data.size or UDim2New(0, 620, 0, 500),
            Logo = Data.Logo or Data.logo,
            LogoText = Data.LogoText or Data.logotext or "ϟ",
            SaveCallback = Data.SaveCallback or Data.savecallback or Data.Save or Data.save,
            FadeSpeed = Data.FadeSpeed or Data.fadespeed or 0.16,
            Pages = { },
            SubPages = { },
            Sections = { },
            Elements = { },
            IsOpen = true,
            AnimationToken = 0,
            SearchText = ""
        }

        local Items = { }

        Items["MainFrame"] = Instances:Create("CanvasGroup", {
            Parent = Library.Holder.Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Name = "\0",
            Position = UDim2New(0.5, 0, 0.5, 0),
            Size = Window.Size,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background,
            GroupTransparency = 0,
            ClipsDescendants = true
        })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background"})
        Items["MainFrame"]:Corner(4)
        Items["MainFrame"]:Border()

        Items["MenuScale"] = Instances:Create("UIScale", {
            Parent = Items["MainFrame"].Instance,
            Scale = 1
        })

        Items["Sidebar"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            Position = UDim2New(0, 0, 0, 0),
            Size = UDim2New(0, 68, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline
        })  Items["Sidebar"]:AddToTheme({BackgroundColor3 = "Inline"})

        Items["LogoArea"] = Instances:Create("Frame", {
            Parent = Items["Sidebar"].Instance,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 70),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        })  Items["LogoArea"]:AddToTheme({BackgroundColor3 = "Element"})

        if Window.Logo then
            Items["Logo"] = Instances:Create("ImageLabel", {
                Parent = Items["LogoArea"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 34, 0, 34),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Image = tostring(Window.Logo):find("rbxasset") and tostring(Window.Logo) or ("rbxassetid://" .. tostring(Window.Logo)),
                ImageColor3 = Library.Theme.Accent
            })  Items["Logo"]:AddToTheme({ImageColor3 = "Accent"})
        else
            Items["Logo"] = Instances:Create("TextLabel", {
                Parent = Items["LogoArea"].Instance,
                FontFace = Library.Font,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = Window.LogoText,
                TextColor3 = Library.Theme.Accent,
                TextSize = 34
            })  Items["Logo"]:AddToTheme({TextColor3 = "Accent"})
        end

        Items["Pages"] = Instances:Create("Frame", {
            Parent = Items["Sidebar"].Instance,
            Name = "\0",
            Position = UDim2New(0, 0, 0, 76),
            Size = UDim2New(1, 0, 1, -84),
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Pages"].Instance,
            FillDirection = Enum.FillDirection.Vertical,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
            Padding = UDimNew(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Items["Header"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            Position = UDim2New(0, 68, 0, 0),
            Size = UDim2New(1, -68, 0, 52),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background
        })  Items["Header"]:AddToTheme({BackgroundColor3 = "Background"})

        Items["TopTabs"] = Instances:Create("Frame", {
            Parent = Items["Header"].Instance,
            Name = "\0",
            Position = UDim2New(0, 18, 0, 0),
            Size = UDim2New(1, -100, 1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1
        })

        Items["Save"] = Instances:Create("TextButton", {
            Parent = Items["Header"].Instance,
            FontFace = Library.Font,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, -12, 0.5, 0),
            Size = UDim2New(0, 50, 0, 26),
            Text = "Save",
            AutoButtonColor = false,
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element,
            TextColor3 = Library.Theme.Text,
            TextSize = 11
        })  Items["Save"]:AddToTheme({BackgroundColor3 = "Element", TextColor3 = "Text"})
        Items["Save"]:Corner(2)
        Items["Save"]:Connect("MouseButton1Down", function()
            if type(Window.SaveCallback) == "function" then
                Library:SafeCall(Window.SaveCallback)
            end
        end)

        Items["SearchArea"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            Position = UDim2New(0, 68, 0, 52),
            Size = UDim2New(1, -68, 0, 40),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline
        })  Items["SearchArea"]:AddToTheme({BackgroundColor3 = "Inline"})

        Items["SearchBackground"] = Instances:Create("Frame", {
            Parent = Items["SearchArea"].Instance,
            Name = "\0",
            Position = UDim2New(0, 14, 0, 6),
            Size = UDim2New(1, -54, 0, 28),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background
        })  Items["SearchBackground"]:AddToTheme({BackgroundColor3 = "Background"})
        Items["SearchBackground"]:Corner(2)

        Items["Search"] = Instances:Create("TextBox", {
            Parent = Items["SearchBackground"].Instance,
            FontFace = Library.Font,
            Position = UDim2New(0, 10, 0, 0),
            Size = UDim2New(1, -34, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ClearTextOnFocus = false,
            Text = "",
            PlaceholderText = "Search",
            PlaceholderColor3 = Library.Theme["Muted Text"],
            TextColor3 = Library.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextSize = 11
        })  Items["Search"]:AddToTheme({TextColor3 = "Text", PlaceholderColor3 = "Muted Text"})

        Items["SearchIcon"] = Instances:Create("TextLabel", {
            Parent = Items["SearchBackground"].Instance,
            FontFace = Library.Font,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, -8, 0.5, 0),
            Size = UDim2New(0, 18, 0, 18),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = "⌕",
            TextColor3 = Library.Theme["Muted Text"],
            TextSize = 15
        })  Items["SearchIcon"]:AddToTheme({TextColor3 = "Muted Text"})

        Items["SearchSettings"] = Instances:Create("TextLabel", {
            Parent = Items["SearchArea"].Instance,
            FontFace = Library.Font,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, -11, 0.5, 0),
            Size = UDim2New(0, 28, 0, 28),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Background,
            Text = "⚙",
            TextColor3 = Library.Theme["Muted Text"],
            TextSize = 13
        })  Items["SearchSettings"]:AddToTheme({BackgroundColor3 = "Background", TextColor3 = "Muted Text"})
        Items["SearchSettings"]:Corner(2)

        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["MainFrame"].Instance,
            Name = "\0",
            Position = UDim2New(0, 68, 0, 92),
            Size = UDim2New(1, -68, 1, -92),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Inline,
            ClipsDescendants = false
        })  Items["Content"]:AddToTheme({BackgroundColor3 = "Inline"})

        Items["MainFrame"]:MakeDraggable(Items["Header"], 26)
        Items["MainFrame"]:MakeResizeable(Vector2New(500, 390), Vector2New(1100, 850), 28)

        local function ApplySearch()
            local Query = string.lower(Items["Search"].Instance.Text or "")
            Window.SearchText = Query

            for _, Section in ipairs(Window.Sections) do
                local Root = Section.Elements and (Section.Elements["Section"] or Section.Elements["MultiSection"])
                if Root and Root.Instance and Root.Instance.Parent then
                    local Visible = Query == ""
                    if not Visible then
                        for _, Descendant in ipairs(Root.Instance:GetDescendants()) do
                            if Descendant:IsA("TextLabel") or Descendant:IsA("TextButton") then
                                local Candidate = string.lower(tostring(Descendant.Text or ""))
                                if Candidate:find(Query, 1, true) then
                                    Visible = true
                                    break
                                end
                            end
                        end
                    end
                    Root.Instance.Visible = Visible
                end
            end
        end

        local SearchConnection = Items["Search"].Instance:GetPropertyChangedSignal("Text"):Connect(ApplySearch)
        TableInsert(Library.CoreConnections, SearchConnection)

        function Window:SetOpen(Bool)
            Bool = Bool == true
            if Window.IsOpen == Bool then return end
            Window.IsOpen = Bool
            Window.AnimationToken += 1
            local Token = Window.AnimationToken
            local MainFrame = Items["MainFrame"].Instance
            local Scale = Items["MenuScale"].Instance
            local Info = TweenInfo.new(Window.FadeSpeed, Enum.EasingStyle.Quint, Bool and Enum.EasingDirection.Out or Enum.EasingDirection.In)

            if Bool then
                MainFrame.Visible = true
                MainFrame.Active = true
                Tween:Create(MainFrame, Info, {GroupTransparency = 0}, true)
                Tween:Create(Scale, Info, {Scale = 1}, true)
            else
                MainFrame.Active = false
                Tween:Create(MainFrame, Info, {GroupTransparency = 1}, true)
                Tween:Create(Scale, Info, {Scale = 0.985}, true)
                if Library.CurrentColorpicker then Library.CurrentColorpicker:SetOpen(false) end
                Library:Thread(function()
                    task.wait(Window.FadeSpeed)
                    if Window.AnimationToken == Token and not Window.IsOpen and MainFrame.Parent then
                        MainFrame.Visible = false
                    end
                end)
            end
        end

        Library:Connect(UserInputService.InputBegan, function(Input, GameProcessed)
            if GameProcessed and UserInputService:GetFocusedTextBox() then return end
            local MenuKey = ResolveKey(Library.MenuKeybind) or Library.MenuKeybind
            if InputMatchesKey(Input, MenuKey) then
                Window:SetOpen(not Window.IsOpen)
            end
        end)

        Items["Inline"] = Items["MainFrame"]
        Window.Elements = Items
        return setmetatable(Window, Library)
    end

    Library.Page = function(self, Data)
        Data = Data or { }

        local Page = {
            Window = self,
            Name = Data.Name or Data.name or "Page",
            Icon = Data.Icon or Data.icon,
            Glyph = Data.Glyph or Data.glyph,
            Columns = Data.Columns or Data.columns or 2,
            HasSubtabs = Data.Subtabs or Data.subtabs or false,
            Active = false,
            ColumnsData = { },
            SubPages = { },
            Elements = { }
        }

        local Items = { }

        Items["Inactive"] = Instances:Create("TextButton", {
            Parent = Page.Window.Elements["Pages"].Instance,
            Text = "",
            AutoButtonColor = false,
            Name = "\0",
            Size = UDim2New(0, 48, 0, 44),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element,
            BackgroundTransparency = 1
        })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Element"})
        Items["Inactive"]:Corner(3)

        Items["Hide"] = Instances:Create("Frame", {
            Parent = Items["Inactive"].Instance,
            Visible = false,
            AnchorPoint = Vector2New(0, 0.5),
            Position = UDim2New(0, -10, 0.5, 0),
            Size = UDim2New(0, 2, 0, 20),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Accent
        })  Items["Hide"]:AddToTheme({BackgroundColor3 = "Accent"})

        if Page.Icon then
            Items["Icon"] = Instances:Create("ImageLabel", {
                Parent = Items["Inactive"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 18, 0, 18),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Image = tostring(Page.Icon):find("rbxasset") and tostring(Page.Icon) or ("rbxassetid://" .. tostring(Page.Icon)),
                ImageColor3 = Library.Theme["Muted Text"],
                ImageTransparency = 0.1
            })  Items["Icon"]:AddToTheme({ImageColor3 = "Muted Text"})
        else
            Items["Icon"] = Instances:Create("TextLabel", {
                Parent = Items["Inactive"].Instance,
                FontFace = Library.Font,
                AnchorPoint = Vector2New(0.5, 0.5),
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = tostring(Page.Glyph or Page.Name:sub(1, 1)):upper(),
                TextColor3 = Library.Theme["Muted Text"],
                TextSize = 13
            })  Items["Icon"]:AddToTheme({TextColor3 = "Muted Text"})
        end

        Items["Page"] = Instances:Create("Frame", {
            Parent = Page.Window.Elements["Content"].Instance,
            BackgroundTransparency = 1,
            Name = "\0",
            Position = UDim2New(0, 0, 0, 0),
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            Visible = false
        })

        if Page.HasSubtabs then
            Items["SubTabs"] = Instances:Create("Frame", {
                Parent = Page.Window.Elements["TopTabs"].Instance,
                Name = "\0",
                Position = UDim2New(0, 0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                Visible = false
            })
            Instances:Create("UIListLayout", {
                Parent = Items["SubTabs"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Center,
                Padding = UDimNew(0, 18),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            Items["Columns"] = Items["Page"]
        else
            Items["Columns"] = Items["Page"]
            Instances:Create("UIPadding", {
                Parent = Items["Page"].Instance,
                PaddingTop = UDimNew(0, 8),
                PaddingBottom = UDimNew(0, 8),
                PaddingLeft = UDimNew(0, 10),
                PaddingRight = UDimNew(0, 10)
            })
            Instances:Create("UIListLayout", {
                Parent = Items["Page"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalFlex = Enum.UIFlexAlignment.Fill
            })

            for Index = 1, Page.Columns do
                local NewColumn = Instances:Create("ScrollingFrame", {
                    Parent = Items["Page"].Instance,
                    ScrollBarImageColor3 = Library.Theme.Accent,
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 2,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 100, 0, 100),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })  NewColumn:AddToTheme({ScrollBarImageColor3 = "Accent"})
                Instances:Create("UIPadding", {
                    Parent = NewColumn.Instance,
                    PaddingBottom = UDimNew(0, 4),
                    PaddingRight = UDimNew(0, 3)
                })
                Instances:Create("UIListLayout", {
                    Parent = NewColumn.Instance,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                Page.ColumnsData[Index] = NewColumn
            end
        end

        function Page:Turn(Bool)
            Bool = Bool == true
            Page.Active = Bool
            Items["Page"].Instance.Visible = Bool
            Items["Hide"].Instance.Visible = Bool
            if Items["SubTabs"] then
                Items["SubTabs"].Instance.Visible = Bool
            end
            Items["Inactive"]:Tween(nil, {BackgroundTransparency = Bool and 0 or 1})
            if Items["Icon"].Instance:IsA("ImageLabel") then
                Items["Icon"]:Tween(nil, {ImageColor3 = Bool and Library.Theme.Accent or Library.Theme["Muted Text"]})
            else
                Items["Icon"]:Tween(nil, {TextColor3 = Bool and Library.Theme.Accent or Library.Theme["Muted Text"]})
            end
        end

        Items["Inactive"]:Connect("MouseButton1Down", function()
            for _, Value in ipairs(Page.Window.Pages) do
                Value:Turn(Value == Page)
            end
        end)

        if #Page.Window.Pages == 0 then Page:Turn(true) end
        Page.Elements = Items
        TableInsert(Page.Window.Pages, Page)
        return setmetatable(Page, Library.Pages)
    end

    Library.Pages.SubPage = function(self, Data)
        Data = Data or { }

        local SubPage = {
            Window = self.Window,
            Page = self,
            Name = Data.Name or Data.name or "Subpage",
            Columns = Data.Columns or Data.columns or 2,
            Active = false,
            ColumnsData = { },
            Elements = { }
        }

        local Items = { }
        Items["Inactive"] = Instances:Create("TextButton", {
            Parent = SubPage.Page.Elements["SubTabs"].Instance,
            FontFace = Library.Font,
            Text = SubPage.Name,
            TextColor3 = Library.Theme["Muted Text"],
            AutoButtonColor = false,
            AutomaticSize = Enum.AutomaticSize.X,
            Name = "\0",
            Size = UDim2New(0, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            TextSize = 11
        })  Items["Inactive"]:AddToTheme({TextColor3 = "Muted Text"})
        Instances:Create("UIPadding", {
            Parent = Items["Inactive"].Instance,
            PaddingLeft = UDimNew(0, 2),
            PaddingRight = UDimNew(0, 2)
        })

        Items["Hide"] = Instances:Create("Frame", {
            Parent = Items["Inactive"].Instance,
            Visible = false,
            AnchorPoint = Vector2New(0.5, 1),
            Position = UDim2New(0.5, 0, 1, -7),
            Size = UDim2New(1, 0, 0, 1),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Accent
        })  Items["Hide"]:AddToTheme({BackgroundColor3 = "Accent"})

        Items["Subtab"] = Instances:Create("Frame", {
            Parent = SubPage.Page.Elements["Columns"].Instance,
            BackgroundTransparency = 1,
            Name = "\0",
            Size = UDim2New(1, 0, 1, 0),
            BorderSizePixel = 0,
            Visible = false
        })
        Instances:Create("UIPadding", {
            Parent = Items["Subtab"].Instance,
            PaddingTop = UDimNew(0, 8),
            PaddingBottom = UDimNew(0, 8),
            PaddingRight = UDimNew(0, 10),
            PaddingLeft = UDimNew(0, 10)
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Subtab"].Instance,
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalFlex = Enum.UIFlexAlignment.Fill,
            Padding = UDimNew(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalFlex = Enum.UIFlexAlignment.Fill
        })

        for Index = 1, SubPage.Columns do
            local NewColumn = Instances:Create("ScrollingFrame", {
                Parent = Items["Subtab"].Instance,
                ScrollBarImageColor3 = Library.Theme.Accent,
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 2,
                Name = "\0",
                BackgroundTransparency = 1,
                Size = UDim2New(0, 100, 0, 100),
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0)
            })  NewColumn:AddToTheme({ScrollBarImageColor3 = "Accent"})
            Instances:Create("UIPadding", {
                Parent = NewColumn.Instance,
                PaddingBottom = UDimNew(0, 4),
                PaddingRight = UDimNew(0, 3)
            })
            Instances:Create("UIListLayout", {
                Parent = NewColumn.Instance,
                Padding = UDimNew(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            SubPage.ColumnsData[Index] = NewColumn
        end

        function SubPage:Turn(Bool)
            Bool = Bool == true
            SubPage.Active = Bool
            Items["Subtab"].Instance.Visible = Bool
            Items["Hide"].Instance.Visible = Bool
            Items["Inactive"]:Tween(nil, {
                TextColor3 = Bool and Library.Theme.Text or Library.Theme["Muted Text"]
            })
        end

        Items["Inactive"]:Connect("MouseButton1Down", function()
            for _, Value in ipairs(SubPage.Page.SubPages) do
                Value:Turn(Value == SubPage)
            end
        end)

        if #SubPage.Page.SubPages == 0 then SubPage:Turn(true) end
        SubPage.Elements = Items
        TableInsert(SubPage.Page.SubPages, SubPage)
        TableInsert(SubPage.Window.SubPages, SubPage)
        return setmetatable(SubPage, Library.Pages)
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

        local Items = { }
        Items["Section"] = Instances:Create("Frame", {
            Parent = Section.Page.ColumnsData[Section.Side].Instance,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 42),
            BorderSizePixel = 0,
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Library.Theme["Page Background"]
        })  Items["Section"]:AddToTheme({BackgroundColor3 = "Page Background"})
        Items["Section"]:Corner(2)
        Items["Section"]:Border()

        Instances:Create("UIPadding", {
            Parent = Items["Section"].Instance,
            PaddingBottom = UDimNew(0, 9)
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Section"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme["Muted Text"],
            Text = Section.Name,
            Name = "\0",
            Position = UDim2New(0, 10, 0, 6),
            Size = UDim2New(1, -20, 0, 16),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            TextSize = 11
        })  Items["Text"]:AddToTheme({TextColor3 = "Muted Text"})

        Items["Content"] = Instances:Create("Frame", {
            Parent = Items["Section"].Instance,
            Name = "\0",
            BackgroundTransparency = 1,
            Position = UDim2New(0, 10, 0, 28),
            Size = UDim2New(1, -20, 1, -28),
            BorderSizePixel = 0
        })
        Instances:Create("UIListLayout", {
            Parent = Items["Content"].Instance,
            Padding = UDimNew(0, 7),
            SortOrder = Enum.SortOrder.LayoutOrder
        })

        Section.Elements = Items
        TableInsert(Section.Window.Sections, Section)
        return setmetatable(Section, Library.Sections)
    end

    Library.Pages.MultiSection = function(self, Data)
        Data = Data or { }

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
                Name = "\0",
                Size = UDim2New(1, 0, 0, 74),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Library.Theme["Page Background"]
            })  Items["MultiSection"]:AddToTheme({BackgroundColor3 = "Page Background"})

            Items["MultiSection"]:Corner(2)
            Items["MultiSection"]:Border()

            Instances:Create("UIPadding", {
                Parent = Items["MultiSection"].Instance,
                PaddingBottom = UDimNew(0, 10)
            })

            Items["Sections"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 12, 0, 10),
                Size = UDim2New(1, -24, 0, 32),
                BorderSizePixel = 0
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Sections"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 12, 0, 52),
                Size = UDim2New(1, -24, 1, -52),
                BorderSizePixel = 0
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
                    Text = "",
                    AutoButtonColor = false,
                    Name = "\0",
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Element,
                    BackgroundTransparency = 0.55
                })  SubItems["Inactive"]:AddToTheme({BackgroundColor3 = "Element"})

                SubItems["Inactive"]:Corner(7)

                SubItems["Text"] = Instances:Create("TextLabel", {
                    Parent = SubItems["Inactive"].Instance,
                    FontFace = Library.Font,
                    TextColor3 = Library.Theme.Text,
                    TextTransparency = 0.35,
                    Text = NewSection.Name,
                    Name = "\0",
                    Size = UDim2New(1, -12, 1, 0),
                    Position = UDim2New(0, 6, 0, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    TextSize = 13
                })  SubItems["Text"]:AddToTheme({TextColor3 = "Text"})

                SubItems["Hide"] = Instances:Create("Frame", {
                    Parent = SubItems["Inactive"].Instance,
                    Visible = false,
                    AnchorPoint = Vector2New(0.5, 1),
                    Name = "\0",
                    Position = UDim2New(0.5, 0, 1, -3),
                    Size = UDim2New(0, 18, 0, 2),
                    BorderSizePixel = 0,
                    BackgroundColor3 = Library.Theme.Accent
                })  SubItems["Hide"]:AddToTheme({BackgroundColor3 = "Accent"})

                SubItems["Hide"]:Corner(99)

                SubItems["Content"] = Instances:Create("Frame", {
                    Parent = Items["Content"].Instance,
                    BackgroundTransparency = 1,
                    Name = "\0",
                    Size = UDim2New(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    Visible = false
                })

                Instances:Create("UIListLayout", {
                    Parent = SubItems["Content"].Instance,
                    Padding = UDimNew(0, 9),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                SubItems["Inactive"]:OnHover(function()
                    if not NewSection.Active then
                        SubItems["Inactive"]:Tween(nil, {BackgroundTransparency = 0.25})
                    end
                end)

                SubItems["Inactive"]:OnHoverLeave(function()
                    if not NewSection.Active then
                        SubItems["Inactive"]:Tween(nil, {BackgroundTransparency = 0.55})
                    end
                end)
            end

            function NewSection:Turn(Bool)
                Bool = Bool == true
                NewSection.Active = Bool

                SubItems["Content"].Instance.Visible = Bool
                SubItems["Hide"].Instance.Visible = Bool

                SubItems["Inactive"]:Tween(nil, {
                    BackgroundTransparency = Bool and 0.08 or 0.55
                })

                SubItems["Text"]:Tween(nil, {
                    TextColor3 = Bool and Library.Theme.Accent or Library.Theme.Text,
                    TextTransparency = Bool and 0 or 0.35
                })

                SubItems["Text"]:ChangeItemTheme({
                    TextColor3 = Bool and "Accent" or "Text"
                })
            end

            SubItems["Inactive"]:Connect("MouseButton1Down", function()
                for Index, SectionData in MultiSection.SectionContents do
                    SectionData:Turn(SectionData == NewSection)
                end
            end)

            if #MultiSection.SectionContents == 0 then
                NewSection:Turn(true)
            end

            NewSection.Elements = SubItems
            MultiSection.SectionContents[#MultiSection.SectionContents + 1] =
                setmetatable(NewSection, Library.Sections)
        end

        if MultiSection.SectionContents[1] then
            MultiSection.SectionContents[1]:Turn(true)
        end

        TableInsert(MultiSection.Window.Sections, MultiSection)

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
                Name = "\0",
                Size = UDim2New(1, 0, 0, Section.Size),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme["Page Background"],
                ClipsDescendants = true
            })  Items["Section"]:AddToTheme({BackgroundColor3 = "Page Background"})

            Items["Section"]:Corner(2)
            Items["Section"]:Border()

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                Position = UDim2New(0, 14, 0, 15),
                Size = UDim2New(0, 6, 0, 6),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Accent
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Items["AccentLine"].Instance.Visible = false

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Section"].Instance,
                FontFace = Library.Font,
                TextColor3 = Library.Theme["Muted Text"],
                Text = Section.Name,
                Name = "\0",
                Size = UDim2New(1, -40, 0, 18),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 28, 0, 7),
                BorderSizePixel = 0,
                TextSize = 13
            })  Items["Text"]:AddToTheme({TextColor3 = "Muted Text"})

            Items["Content"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                ScrollBarThickness = 2,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                CanvasSize = UDim2New(0, 0, 0, 0),
                ScrollBarImageColor3 = Library.Theme.Accent,
                Active = true,
                BackgroundTransparency = 1,
                Position = UDim2New(0, 12, 0, 38),
                Size = UDim2New(1, -24, 1, -50),
                BorderSizePixel = 0
            })  Items["Content"]:AddToTheme({ScrollBarImageColor3 = "Accent"})

            Instances:Create("UIPadding", {
                Parent = Items["Content"].Instance,
                PaddingBottom = UDimNew(0, 8),
                PaddingRight = UDimNew(0, 7)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Content"].Instance,
                Padding = UDimNew(0, 9),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Fade"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, 0, 0, 18),
                BorderSizePixel = 0,
                ZIndex = 15,
                BackgroundColor3 = Library.Theme["Page Background"]
            })  Items["Fade"]:AddToTheme({BackgroundColor3 = "Page Background"})

            Instances:Create("UIGradient", {
                Parent = Items["Fade"].Instance,
                Rotation = -90,
                Transparency = NumSequence{
                    NumSequenceKeypoint(0, 0),
                    NumSequenceKeypoint(1, 1)
                }
            })
        end

        Section.Elements = Items
        TableInsert(Section.Window.Sections, Section)

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
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 10),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["RealDivider"] = Instances:Create("Frame", {
                Parent = Items["Divider"].Instance,
                AnchorPoint = Vector2New(0, 0.5),
                Name = "\0",
                Position = UDim2New(0, 0, 0.5, 0),
                BorderColor3 = FromRGB(24, 24, 42),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Border,
                BackgroundTransparency = 0.25
            })  Items["RealDivider"]:AddToTheme({BackgroundColor3 = "Border"})
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

        local Items = { }
        Items["Toggle"] = Instances:Create("TextButton", {
            Parent = Toggle.Section.Elements["Content"].Instance,
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Name = "\0",
            Size = UDim2New(1, 0, 0, 21),
            BorderSizePixel = 0
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Toggle"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            TextTransparency = 0.12,
            Text = Toggle.Name,
            Name = "\0",
            Position = UDim2New(0, 0, 0, 0),
            Size = UDim2New(1, -42, 1, 0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            BorderSizePixel = 0,
            TextSize = 11
        })  Items["Text"]:AddToTheme({TextColor3 = "Muted Text"})

        Items["Indicator"] = Instances:Create("Frame", {
            Parent = Items["Toggle"].Instance,
            AnchorPoint = Vector2New(1, 0.5),
            Position = UDim2New(1, 0, 0.5, 0),
            Size = UDim2New(0, 12, 0, 12),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element"})
        Items["Indicator"]:Corner(2)
        Items["Indicator"]:Border()

        Items["Check"] = Instances:Create("TextLabel", {
            Parent = Items["Indicator"].Instance,
            FontFace = Library.Font,
            TextColor3 = FromRGB(235, 239, 255),
            Text = "✓",
            Name = "\0",
            Size = UDim2New(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            TextSize = 9,
            Visible = false
        })

        function Toggle:Get()
            return Toggle.Value
        end

        function Toggle:Set(Bool)
            Toggle.Value = Bool == nil and not Toggle.Value or Bool == true
            Library.Flags[Toggle.Flag] = Toggle.Value

            if Toggle.KeybindExtension and type(Toggle.KeybindExtension.SetState) == "function" then
                Toggle.KeybindExtension:SetState(Toggle.Value, true)
            end

            Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = Toggle.Value and "Accent" or "Element"})
            Items["Indicator"]:Tween(nil, {
                BackgroundColor3 = Toggle.Value and Library.Theme.Accent or Library.Theme.Element
            })
            Items["Check"].Instance.Visible = Toggle.Value
            Items["Text"]:Tween(nil, {TextTransparency = Toggle.Value and 0 or 0.12})

            if Toggle.Callback then
                Library:SafeCall(Toggle.Callback, Toggle.Value)
            end
        end

        function Toggle:SetVisiblity(Bool)
            Items["Toggle"].Instance.Visible = Bool
        end

        Toggle.SetVisibility = Toggle.SetVisiblity

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
                Count = Toggle.Count + 1,
                FadeSpeed = self.Window.FadeSpeed
            }
            Toggle.Count += 1
            local Extension = Library:CreateColorpicker(Colorpicker)
            Library.Flags[Colorpicker.Flag] = Extension
            return Colorpicker, Extension
        end

        function Toggle:Keybind(Data)
            Data = Data or { }
            local Keybind = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,
                Parent = Items["Toggle"],
                Name = Data.Name or Data.name or "Keybind",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "MB2",
                Mode = Data.Mode or Data.mode or "Toggle",
                Callback = function(Value)
                    Toggle:Set(Value)
                    local UserCallback = Data.Callback or Data.callback
                    if UserCallback then Library:SafeCall(UserCallback, Value) end
                end
            }
            local Extension = Library:CreateKeybind(Keybind)
            Toggle.KeybindExtension = Extension
            Extension:SetState(Toggle.Value, true)
            Library.Flags[Keybind.Flag] = Extension
            return Keybind, Extension
        end

        Items["Toggle"]:Connect("MouseButton1Down", function()
            Toggle:Set()
        end)

        Items["Toggle"]:OnHover(function()
            Items["Text"]:Tween(nil, {TextTransparency = 0})
        end)
        Items["Toggle"]:OnHoverLeave(function()
            Items["Text"]:Tween(nil, {TextTransparency = Toggle.Value and 0 or 0.12})
        end)

        Toggle:Set(Toggle.Default)
        Library.SetFlags[Toggle.Flag] = function(Value) Toggle:Set(Value) end
        return Toggle
    end

    Library.Sections.Button = function(self, Data)
        Data = Data or { }

        local Button = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Name = Data.Name or Data.name or "Button",
            Callback = Data.Callback or Data.callback or function() end,
        }

        local Items = { } do
            Items["Button"] = Instances:Create("TextButton", {
                Parent = Button.Section.Elements["Content"].Instance,
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 30),
                Selectable = false,
                BorderSizePixel = 0,
                BackgroundColor3 = Library.Theme.Element
            })  Items["Button"]:AddToTheme({BackgroundColor3 = "Element"})

            Items["Button"]:Corner(2)
            Items["Button"]:Border()

            Items["Scale"] = Instances:Create("UIScale", {
                Parent = Items["Button"].Instance,
                Scale = 1
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Button"].Instance,
                FontFace = Library.Font,
                TextColor3 = Library.Theme.Text,
                Text = Button.Name,
                Name = "\0",
                Size = UDim2New(1, -16, 1, 0),
                Position = UDim2New(0, 8, 0, 0),
                BackgroundTransparency = 1,
                TextTruncate = Enum.TextTruncate.AtEnd,
                BorderSizePixel = 0,
                TextSize = 13
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Items["Button"]:OnHover(function()
                Items["Button"]:Tween(nil, {
                    BackgroundColor3 = Library.Theme["Hovered Element"]
                })
            end)

            Items["Button"]:OnHoverLeave(function()
                Items["Button"]:Tween(nil, {
                    BackgroundColor3 = Library.Theme.Element
                })
            end)
        end

        function Button:Press()
            Library:SafeCall(Button.Callback)

            Tween:Create(
                Items["Scale"].Instance,
                TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Scale = 0.975},
                true
            )

            Items["Button"]:Tween(nil, {
                BackgroundColor3 = Library.Theme["Accent Soft"]
            })

            task.wait(0.08)

            Tween:Create(
                Items["Scale"].Instance,
                TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Scale = 1},
                true
            )

            Items["Button"]:Tween(nil, {
                BackgroundColor3 = Library.Theme.Element
            })
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
            Class = "Slider"
        }

        local Items = { }
        Items["Slider"] = Instances:Create("Frame", {
            Parent = Slider.Section.Elements["Content"].Instance,
            BackgroundTransparency = 1,
            Name = "\0",
            Size = UDim2New(1, 0, 0, Slider.Compact and 20 or 34),
            BorderSizePixel = 0
        })

        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["Slider"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme["Muted Text"],
            Text = Slider.Name,
            Name = "\0",
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2New(0, 0, 0, 0),
            Size = UDim2New(1, -45, 0, 14),
            BorderSizePixel = 0,
            TextSize = 11
        })  Items["Text"]:AddToTheme({TextColor3 = "Muted Text"})

        Items["Value"] = Instances:Create("TextLabel", {
            Parent = Items["Slider"].Instance,
            FontFace = Library.Font,
            TextColor3 = Library.Theme.Text,
            Text = "0",
            Name = "\0",
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right,
            Position = UDim2New(1, -44, 0, 0),
            Size = UDim2New(0, 44, 0, 14),
            BorderSizePixel = 0,
            TextSize = 11
        })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

        Items["RealSlider"] = Instances:Create("TextButton", {
            Parent = Items["Slider"].Instance,
            AnchorPoint = Vector2New(0, 1),
            Position = UDim2New(0, 0, 1, -3),
            Text = "",
            AutoButtonColor = false,
            Size = UDim2New(1, 0, 0, 3),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Element
        })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Element"})
        Items["RealSlider"]:Corner(99)

        Items["Indicator"] = Instances:Create("Frame", {
            Parent = Items["RealSlider"].Instance,
            Name = "\0",
            Size = UDim2New(0, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Accent
        })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Accent"})
        Items["Indicator"]:Corner(99)

        Items["Knob"] = Instances:Create("Frame", {
            Parent = Items["RealSlider"].Instance,
            AnchorPoint = Vector2New(0.5, 0.5),
            Position = UDim2New(0, 0, 0.5, 0),
            Size = UDim2New(0, 7, 0, 7),
            BorderSizePixel = 0,
            BackgroundColor3 = Library.Theme.Text
        })  Items["Knob"]:AddToTheme({BackgroundColor3 = "Text"})
        Items["Knob"]:Corner(99)

        if Slider.Compact then
            Items["Text"].Instance.Size = UDim2New(1, -50, 0, 14)
            Items["Text"].Instance.TextColor3 = Library.Theme.Text
            Items["Text"]:ChangeItemTheme({TextColor3 = "Text"})
        end

        function Slider:Set(Value)
            Slider.Value = MathClamp(Library:Round(Value, Slider.Decimals), Slider.Min, Slider.Max)
            Library.Flags[Slider.Flag] = Slider.Value
            Items["Value"].Instance.Text = tostring(Slider.Value) .. Slider.Suffix
            if Slider.Compact then
                Items["Text"].Instance.Text = Slider.Name
            end
            local Scale = (Slider.Value - Slider.Min) / math.max(Slider.Max - Slider.Min, 0.0001)
            Items["Indicator"].Instance.Size = UDim2New(Scale, 0, 1, 0)
            Items["Knob"].Instance.Position = UDim2New(Scale, 0, 0.5, 0)
            if Slider.Callback then Library:SafeCall(Slider.Callback, Slider.Value) end
        end

        function Slider:Get() return Slider.Value end
        function Slider:SetVisibility(Bool) Items["Slider"].Instance.Visible = Bool end

        function Slider:UpdateFromMouse()
            local MousePosition = Library:GetPointerPosition()
            local Position = Items["RealSlider"].Instance.AbsolutePosition
            local Size = Items["RealSlider"].Instance.AbsoluteSize
            if Size.X <= 0 then return end
            local Scale = MathClamp((MousePosition.X - Position.X) / Size.X, 0, 1)
            Slider:Set(Slider.Min + (Slider.Max - Slider.Min) * Scale)
        end

        Items["RealSlider"]:Connect("MouseButton1Down", function()
            Slider.Sliding = true
            Library.ActiveSlider = Slider
            Slider:UpdateFromMouse()
        end)

        Library:Connect(UserInputService.InputEnded, function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                if Library.ActiveSlider == Slider then Library.ActiveSlider = nil end
                Slider.Sliding = false
            end
        end)

        if not Library.SliderConnection then
            Library.SliderConnection = Library:Connect(RunService.RenderStepped, function()
                local Active = Library.ActiveSlider
                if Active and Active.Sliding then Active:UpdateFromMouse() end
            end, "Library_Slider_Renderer")
        end

        Slider:Set(Slider.Default)
        Library.SetFlags[Slider.Flag] = function(Value) Slider:Set(Value) end
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
            Items = Data.Items or Data.items or { "One", "Two", "Three" },
            Default = Data.Default or Data.default or nil,
            Callback = Data.Callback or Data.callback or function() end,
            Multi = Data.Multi or Data.multi or false,

            Value = { },
            IsOpen = false,
            Options = { },
            Class = "Dropdown",
        }

        local Items = { } do
            Items["Dropdown"] = Instances:Create("Frame", {
                Parent = Dropdown.Section.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 34),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Dropdown"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Dropdown.Name,
                Name = "\0",
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 13),
                BorderSizePixel = 0,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["RealDropdown"] = Instances:Create("Frame", {
                Parent = Items["Dropdown"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(24, 24, 42),
                Size = UDim2New(1, 0, 0, 17),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(17, 17, 30)
            })  Items["RealDropdown"]:AddToTheme({BackgroundColor3 = "Element"})

            Items["RealDropdown"].Instance.BorderSizePixel = 0
            Items["RealDropdown"].Instance.BackgroundColor3 = Library.Theme.Element
            Items["RealDropdown"].Instance.Size = UDim2New(1, 0, 0, 28)
            Items["RealDropdown"]:Corner(2)
            Items["RealDropdown"]:Border()

            Items["Open"] = Instances:Create("TextButton", {
                Parent = Items["RealDropdown"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "⌄",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2New(0, -4, 0, -1),
                BorderSizePixel = 0,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Open"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Open"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Value"] = Instances:Create("TextLabel", {
                Parent = Items["RealDropdown"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "--",
                Name = "\0",
                Size = UDim2New(1, -25, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2New(0, 5, 0, -1),
                BorderSizePixel = 0,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Value"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Value"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["OptionHolder"] = Instances:Create("Frame", {
                Parent = Items["Dropdown"].Instance,
                Visible = false,
                BorderColor3 = FromRGB(24, 24, 42),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 5),
                Size = UDim2New(1, 0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(12, 12, 21)
            })  Items["OptionHolder"]:AddToTheme({BackgroundColor3 = "Inline"})

            Items["OptionHolder"].Instance.BorderSizePixel = 0
            Items["OptionHolder"]:Corner(2)
            Items["OptionHolder"]:Border()

            Instances:Create("UIListLayout", {
                Parent = Items["OptionHolder"].Instance,
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = Items["OptionHolder"].Instance,
                PaddingBottom = UDimNew(0, 2)
            })

            Items["RealDropdown"]:OnHover(function()
                Items["RealDropdown"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element"})
            end)

            Items["RealDropdown"]:OnHoverLeave(function()
                Items["RealDropdown"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Element"})
            end)
        end

        function Dropdown:Set(Option)
            if Dropdown.Multi then
                if type(Option) ~= "table" then
                    return
                end

                Dropdown.Value = Option

                for Index, Value in Option do
                    local OptionData = Dropdown.Options[Value]

                    if not OptionData then
                        return
                    end

                    OptionData.Selected = true
                    OptionData:Toggle("Active")
                end

                Library.Flags[Dropdown.Flag] = Dropdown.Value

                Items["Value"].Instance.Text = TableConcat(Option, ", ")
            else
                if not Dropdown.Options[Option] then
                    return
                end

                local OptionData = Dropdown.Options[Option]

                Dropdown.Value = OptionData.Name

                OptionData.Selected = true
                OptionData:Toggle("Active")

                for Index, Value in Dropdown.Options do
                    if Value ~= OptionData then
                        Value.Selected = false
                        Value:Toggle("Inactive")
                    end
                end

                Library.Flags[Dropdown.Flag] = Dropdown.Value

                Items["Value"].Instance.Text = Option
            end

            if Dropdown.Callback then
                Library:SafeCall(Dropdown.Callback, Option)
            end
        end

        function Dropdown:Get()
            return Dropdown.Value
        end

        function Dropdown:SetVisibility(Bool)
            Items["Dropdown"].Instance.Visible = Bool
        end

        function Dropdown:Add(Option)
            local OptionButton = Instances:Create("TextButton", {
                Parent = Items["OptionHolder"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2New(1, 0, 0, 15),
                ZIndex = 5,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionButton.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                TextTransparency = 0.48,
                Text = Option,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -5, 1, 0),
                Position = UDim2New(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                ZIndex = 5,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            OptionText:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = OptionText.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            local OptionData = {
                Selected = false,
                Name = Option,
                Text = OptionText,
                Button = OptionButton
            }

            function OptionData:Toggle(State)
                if State == "Active" then
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Accent"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Accent, TextTransparency = 0})
                else
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Text"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.48})
                end
            end

            function OptionData:Set()
                OptionData.Selected = not OptionData.Selected

                if Dropdown.Multi then
                    local Index = TableFind(Dropdown.Value, OptionData.Name)

                    if Index then
                        TableRemove(Dropdown.Value, Index)
                    else
                        TableInsert(Dropdown.Value, OptionData.Name)
                    end

                    Library.Flags[Dropdown.Flag] = Dropdown.Value

                    OptionData:Toggle(Index and "Inactive" or "Active")

                    local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "--"

                    Items["Value"].Instance.Text = TextFormat
                else
                    if OptionData.Selected then
                        Dropdown.Value = OptionData.Name

                        Library.Flags[Dropdown.Flag] = Dropdown.Value

                        OptionData:Toggle("Active")
                        Items["Value"].Instance.Text = OptionData.Name

                        for Index, Value in Dropdown.Options do
                            if Value ~= OptionData then
                                Value.Selected = false
                                Value:Toggle("Inactive")
                            end
                        end
                    else
                        Dropdown.Value = nil

                        OptionData:Toggle("Inactive")
                        Items["Value"].Instance.Text = "--"
                    end
                end

                if Dropdown.Callback then
                    Library:SafeCall(Dropdown.Callback, Dropdown.Value)
                end
            end

            OptionButton:Connect("MouseButton1Down", function()
                OptionData:Set()
            end)

            Dropdown.Options[Option] = OptionData
            return OptionData
        end

        function Dropdown:Remove(Option)
            if Dropdown.Options[Option] then
                Dropdown.Options[Option].Button:Clean()
            end
        end

        function Dropdown:Refresh(List)
            for Index, Value in Dropdown.Options do
                Dropdown:Remove(Value.Name)
            end

            for Index, Value in List do
                Dropdown:Add(Value)
            end
        end

        local Debounce = false

        function Dropdown:SetOpen(
            Bool
        )
            Bool =
                Bool == true

            Dropdown.IsOpen =
                Bool

            Items[
                "OptionHolder"
            ].Instance.Visible =
                Bool

            Items[
                "OptionHolder"
            ].Instance.ZIndex =
                Bool
                and 15
                or 1

            Items[
                "Open"
            ].Instance.Text =
                Bool
                and "-"
                or "+"

            Items[
                "Open"
            ].Instance.Position =
                Bool
                and UDim2New(
                    0,
                    -5,
                    0,
                    -1
                )
                or UDim2New(
                    0,
                    -4,
                    0,
                    -1
                )

            for _,
                Descendant in ipairs(
                    Items[
                        "OptionHolder"
                    ].Instance:
                    GetDescendants()
                )
            do
                if not StringFind(
                    Descendant.ClassName,
                    "UI"
                ) then
                    Descendant.ZIndex =
                        Bool
                        and 15
                        or 1
                end
            end
        end

        for Index, Value in Dropdown.Items do
            Dropdown:Add(Value)
        end

        Items["Open"]:Connect("MouseButton1Down", function()
            Dropdown:SetOpen(not Dropdown.IsOpen)
        end)

        if Dropdown.Default then
            Dropdown:Set(Dropdown.Default)
        end

        Library.SetFlags[Dropdown.Flag] = function(Value)
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
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 15),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Label"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Label.Name,
                Name = "\0",
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment[Label.Alignment],
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize = 11,
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

            local Keybind = {
                Window = self.Window,
                Tab = self.Tab,
                Section = self.Section,

                Parent = Items["Label"],
                Name = Data.Name or Data.name or "Keybind",
                Flag = Data.Flag or Data.flag or Library:NextFlag(),
                Default = Data.Default or Data.default or "MB2",
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
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 34),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Textbox"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Textbox.Name,
                Name = "\0",
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2New(1, 0, 0, 13),
                BorderSizePixel = 0,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Background"] = Instances:Create("Frame", {
                Parent = Items["Textbox"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(24, 24, 42),
                Size = UDim2New(1, 0, 0, 17),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(17, 17, 30)
            })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element"})

            Items["Background"].Instance.BorderSizePixel = 0
            Items["Background"].Instance.Size = UDim2New(1, 0, 0, 28)
            Items["Background"]:Corner(2)
            Items["Background"]:Border()

            Items["Inline"] = Instances:Create("TextBox", {
                Parent = Items["Background"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                ClearTextOnFocus = false,
                BackgroundTransparency = 1,
                PlaceholderColor3 = FromRGB(105, 106, 137),
                TextXAlignment = Enum.TextXAlignment.Left,
                PlaceholderText = Textbox.Placeholder,
                TextSize = 11,
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
                Name = "\0"
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

    Library.Sections.Listbox = function(self, Data)
        Data = Data or {}

        local Listbox = {
            Window = self.Window,
            Page = self.Page,
            Section = self,

            Items = Data.Items or Data.items or { },
            Multi = Data.Multi or Data.multi or false,
            Default = Data.Default or Data.default or 1,
            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Callback = Data.Callback or Data.callback or function() end,
            Size = Data.Size or Data.size or 175,

            Value = { },
            Options = { },
            Class = "Listbox",
        }

        local Items = { } do
            Items["Listbox"] = Instances:Create("Frame", {
                Parent = Listbox.Section.Elements["Content"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Size = UDim2New(1, 0, 0, Listbox.Size),
                BorderColor3 = FromRGB(0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["RealListbox"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Listbox"].Instance,
                ScrollBarImageColor3 = FromRGB(112, 136, 255),
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 1,
                AnchorPoint = Vector2New(0, 1),
                Size = UDim2New(1, 0, 1, 0),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BackgroundColor3 = FromRGB(9, 9, 16),
                BorderColor3 = FromRGB(24, 24, 42),
                BorderSizePixel = 0,
                CanvasSize = UDim2New(0, 0, 0, 0)
            })  Items["RealListbox"]:AddToTheme({ScrollBarImageColor3 = "Accent", BackgroundColor3 = "Inline"})

            Items["RealListbox"].Instance.BorderSizePixel = 0
            Items["RealListbox"].Instance.BackgroundColor3 = Library.Theme.Inline
            Items["RealListbox"].Instance.ScrollBarThickness = 3
            Items["RealListbox"]:Corner(8)
            Items["RealListbox"]:Border()

            Instances:Create("UIListLayout", {
                Parent = Items["RealListbox"].Instance,
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = Items["RealListbox"].Instance,
                PaddingBottom = UDimNew(0, 5),
                PaddingTop = UDimNew(0, 2)
            })
        end

        function Listbox:Set(Option)
            if Listbox.Multi then
                if type(Option) ~= "table" then
                    return
                end

                Listbox.Value = Option

                Library.Flags[Listbox.Flag] = Listbox.Value

                for Index, Value in Option do
                    local OptionData = Listbox.Options[Value]

                    if not OptionData then
                        return
                    end

                    OptionData.Selected = true
                    OptionData:Toggle("Active")
                end
            else
                if not Listbox.Options[Option] then
                    return
                end

                local OptionData = Listbox.Options[Option]

                Listbox.Value = OptionData.Name

                Library.Flags[Listbox.Flag] = Listbox.Value

                OptionData.Selected = true
                OptionData:Toggle("Active")

                for Index, Value in Listbox.Options do
                    if Value ~= OptionData then
                        Value.Selected = false
                        Value:Toggle("Inactive")
                    end
                end
            end

            if Listbox.Callback then
                Library:SafeCall(Listbox.Callback, Option)
            end
        end

        function Listbox:Get()
            return Listbox.Value
        end

        function Listbox:SetVisibility(Bool)
            Items["Listbox"].Instance.Visible = Bool
        end

        function Listbox:Remove(Option)
            if Listbox.Options[Option] then
                Listbox.Options[Option].Button:Clean()
            end
        end

        function Listbox:Refresh(List)
            for Index, Value in Listbox.Options do
                Listbox:Remove(Value.Name)
            end

            for Index, Value in List do
                Listbox:Add(Value)
            end
        end

        function Listbox:Add(Option)
            local OptionButton = Instances:Create("TextButton", {
                Parent = Items["RealListbox"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2New(1, 0, 0, 15),
                ZIndex = 5,
                TextSize = 12,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionButton.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(236, 237, 247),
                TextTransparency = 0.48,
                Text = Option,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -5, 1, 0),
                Position = UDim2New(0, 5, 0, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Center,
                BorderSizePixel = 0,
                ZIndex = 5,
                TextSize = 11,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            OptionText:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = OptionText.Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            local OptionData = {
                Selected = false,
                Name = Option,
                Text = OptionText,
                Button = OptionButton
            }

            function OptionData:Toggle(State)
                if State == "Active" then
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Accent"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Accent, TextTransparency = 0})
                else
                    OptionData.Text:ChangeItemTheme({TextColor3 = "Text"})
                    OptionData.Text:Tween(nil, {TextColor3 = Library.Theme.Text, TextTransparency = 0.48})
                end
            end

            function OptionData:Set()
                OptionData.Selected = not OptionData.Selected

                if Listbox.Multi then
                    local Index = TableFind(Listbox.Value, OptionData.Name)

                    if Index then
                        TableRemove(Listbox.Value, Index)
                    else
                        TableInsert(Listbox.Value, OptionData.Name)
                    end

                    OptionData:Toggle(Index and "Inactive" or "Active")

                    local TextFormat = #Listbox.Value > 0 and TableConcat(Listbox.Value, ", ") or "--"
                else
                    if OptionData.Selected then
                        Listbox.Value = OptionData.Name

                        OptionData:Toggle("Active")

                        for Index, Value in Listbox.Options do
                            if Value ~= OptionData then
                                Value.Selected = false
                                Value:Toggle("Inactive")
                            end
                        end
                    else
                        Listbox.Value = nil

                        OptionData:Toggle("Inactive")
                    end
                end

                if Listbox.Callback then
                    Library:SafeCall(Listbox.Callback, Listbox.Value)
                end
            end

            OptionButton:Connect("MouseButton1Down", function()
                OptionData:Set()
            end)

            Listbox.Options[Option] = OptionData
            return OptionData
        end

        for Index, Value in Listbox.Items do
            Listbox:Add(Value)
        end

        if Listbox.Default then
            Listbox:Set(Listbox.Default)
        end

        Library.SetFlags[Listbox.Flag] = function(Value)
            Listbox:Set(Value)
        end

        return Listbox
    end
end

getgenv().Library = Library
return Library
