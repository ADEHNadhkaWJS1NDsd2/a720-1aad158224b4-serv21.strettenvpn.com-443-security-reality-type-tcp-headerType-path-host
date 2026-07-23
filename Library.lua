
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
            ["Background"] = FromRGB(15, 15, 20),
            ["Inline"] = FromRGB(20, 20, 25),
            ["Page Background"] = FromRGB(30, 30, 35),
            ["Border"] = FromRGB(10, 10, 10),
            ["Outline"] = FromRGB(27, 27, 32),
            ["Accent"] = FromRGB(235, 157, 255),
            ["Element"] = FromRGB(33, 33, 36),
            ["Hovered Element"] = FromRGB(40, 40, 43),
            ["Text"] = FromRGB(215, 215, 215),
            ["Text Border"] = FromRGB(0, 0, 0)
        },

        MenuKeybind = Enum.KeyCode.Z,

        Tween = {
            Time = 0.3,
            Style = Enum.EasingStyle.Exponential,
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
            Handle
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

            local Dragging = false
            local DragInput = nil
            local DragStart = nil
            local StartPosition = nil

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

                    Dragging = true
                    DragStart =
                        Vector2New(
                            Input.Position.X,
                            Input.Position.Y
                        )

                    StartPosition =
                        Gui.Position

                    if Input.UserInputType
                        == Enum.UserInputType.Touch
                    then
                        DragInput =
                            Input
                    end
                end
            )

            Library:Connect(
                DragHandle.InputChanged,
                function(Input)
                    if Input.UserInputType
                            == Enum.UserInputType.MouseMovement
                        or Input.UserInputType
                            == Enum.UserInputType.Touch
                    then
                        DragInput =
                            Input
                    end
                end
            )

            local ChangedConnection =
                UserInputService.InputChanged:
                Connect(function(Input)
                    if Library.Unloaded
                        or not Dragging
                        or Input ~= DragInput
                        or not Gui.Parent
                    then
                        return
                    end

                    local CurrentPosition =
                        Vector2New(
                            Input.Position.X,
                            Input.Position.Y
                        )

                    local Delta =
                        CurrentPosition
                        - DragStart

                    Gui.Position =
                        UDim2New(
                            StartPosition.X.Scale,
                            StartPosition.X.Offset
                                + Delta.X,
                            StartPosition.Y.Scale,
                            StartPosition.Y.Offset
                                + Delta.Y
                        )
                end)

            TableInsert(
                Library.CoreConnections,
                ChangedConnection
            )

            local EndedConnection =
                UserInputService.InputEnded:
                Connect(function(Input)
                    if Input.UserInputType
                            ~= Enum.UserInputType.MouseButton1
                        and Input.UserInputType
                            ~= Enum.UserInputType.Touch
                    then
                        return
                    end

                    Dragging = false
                    DragInput = nil
                end)

            TableInsert(
                Library.CoreConnections,
                EndedConnection
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

            local Gui =
                self.Instance

            local Resizing = false
            local StartMouse = nil
            local StartSize = nil
            local TargetSize = nil

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
                        Text = ""
                    }
                )

            ResizeButton:Connect(
                "InputBegan",
                function(Input)
                    if Input.UserInputType
                            == Enum.UserInputType.MouseButton1
                        or Input.UserInputType
                            == Enum.UserInputType.Touch
                    then
                        Resizing = true
                        StartMouse =
                            Input.Position

                        StartSize =
                            Gui.AbsoluteSize

                        TargetSize =
                            Gui.Size
                    end
                end
            )

            Library:Connect(
                UserInputService.InputChanged,
                function(Input)
                    if not Resizing then
                        return
                    end

                    if Input.UserInputType
                            ~= Enum.UserInputType.MouseMovement
                        and Input.UserInputType
                            ~= Enum.UserInputType.Touch
                    then
                        return
                    end

                    local Delta =
                        Input.Position
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
                end
            )

            Library:Connect(
                UserInputService.InputEnded,
                function(Input)
                    if Input.UserInputType
                            == Enum.UserInputType.MouseButton1
                        or Input.UserInputType
                            == Enum.UserInputType.Touch
                    then
                        Resizing = false

                        if TargetSize then
                            Gui.Size =
                                TargetSize
                        end
                    end
                end
            )

            Library:Connect(
                RunService.RenderStepped,
                function(DeltaTime)
                    if not Resizing
                        or not TargetSize
                        or not Gui.Parent
                    then
                        return
                    end

                    local Alpha =
                        1
                        - math.exp(
                            -30
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
        AnchorPoint = Vector2New(0.5, 0),
        BackgroundTransparency = 1,
        Position = UDim2New(0.5, 0, 0, 0),
        Name = "\0",
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

        local Items = { } do
            Items["Watermark"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                Size = UDim2New(0, 0, 0, 20),
                Name = "\0",
                Position = UDim2New(0, 15, 0, 15),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Watermark"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["Watermark"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["Watermark"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIPadding", {
                Parent = Items["Watermark"].Instance,
                PaddingTop = UDimNew(0, 2),
                PaddingRight = UDimNew(0, 5),
                PaddingLeft = UDimNew(0, 5)
            })

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["Watermark"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Name,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, 1),
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Watermark"].Instance,
                Name = "\0",
                Position = UDim2New(0, -5, 0, -2),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 10, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })
        end

        function Watermark:SetVisibility(Bool)
            Items["Watermark"].Instance.Visible = Bool
        end

        function Watermark:SetText(
            Text
        )
            Items["Title"].Instance.Text =
                tostring(
                    Text
                )
        end

        function Watermark:GetText()
            return Items["Title"].Instance.Text
        end

        function Watermark:Destroy()
            if Items["Watermark"]
                and Items["Watermark"].Instance
            then
                Items["Watermark"].Instance:
                    Destroy()
            end
        end

        Watermark.Frame =
            Items["Watermark"].Instance

        Watermark.Label =
            Items["Title"].Instance

        return Watermark
    end

    Library.Notification = function(self, Text, Duration, Color, Icon)
        local Items = { } do
            Items["Notification"] = Instances:Create("Frame", {
                Parent = Library.NotifHolder.Instance,
                Name = "\0",
                Size = UDim2New(0, 0, 0, 22),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.X,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Notification"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Notification"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
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
                Name = "\0",
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
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Notification"].Instance,
                Name = "\0",
                Position = UDim2New(0, -5, 0, -1),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 13, 0, 2),
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
                Name = "\0",
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
        local KeybindList = { }
        self.KeyList = KeybindList

        local Items = { } do
            Items["KeybindList"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                BorderColor3 = FromRGB(10, 10, 10),
                AnchorPoint = Vector2New(0, 0.5),
                Name = "\0",
                Position = UDim2New(0, 15, 0.5, 0),
                Size = UDim2New(0, 0, 0, 18),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.XY,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["KeybindList"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["KeybindList"]:MakeDraggable()

            Instances:Create("UIStroke", {
                Parent = Items["KeybindList"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["KeybindList"].Instance,
                Name = "\0",
                Position = UDim2New(0, -5, 0, -5),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 10, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
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
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "Keybinds",
                Name = "\0",
                Size = UDim2New(0, 100, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 0, 0, -1),
                BorderSizePixel = 0,
                TextSize = 13,
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
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "(" .. Mode .. ") " .. Name .. " - " .. Key,
                Name = "\0",
                Size = UDim2New(0, 0, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.X,
                TextSize = 13,
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
                Name = "\0",
                Position = UDim2New(1, 0, 0.5, 0),
                Size = UDim2New(0, 22, 0, 12),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0),
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

            Instances:Create("UIStroke", {
                Parent = Items["ColorpickerButton"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIGradient", {
                Parent = Items["ColorpickerButton"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["ColorpickerWindow"] = Instances:Create("TextButton", {
                Parent = Library.Holder.Instance,
                AutoButtonColor = false,
                Text = "",
                Name = "\0",
                Position = UDim2New(0, Data.Parent.Instance.AbsolutePosition.X, 0, Data.Parent.Instance.AbsolutePosition.Y + 15),
                BorderColor3 = FromRGB(10, 10, 10),
                Visible = false,
                Size = UDim2New(0, 238, 0, 224),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20),
                ZIndex = 1000,
                Active = true,
                Modal = false
            })  Items["ColorpickerWindow"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["ColorpickerWindow"]:MakeResizeable(Vector2New(200, 180), Vector2New(9999, 9999))

            Instances:Create("UIStroke", {
                Parent = Items["ColorpickerWindow"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Data.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, -2, 0, -3),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Items["ColorpickerWindow"]:MakeDraggable(
                Items["Title"]
            )

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["ColorpickerWindow"].Instance,
                Name = "\0",
                Position = UDim2New(0, -6, 0, -6),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 12, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(235, 157, 255)
            })  Items["AccentLine"]:AddToTheme({BackgroundColor3 = "Accent"})

            Instances:Create("UIGradient", {
                Parent = Items["AccentLine"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(65, 65, 65))}
            })

            Instances:Create("UIPadding", {
                Parent = Items["ColorpickerWindow"].Instance,
                PaddingTop = UDimNew(0, 6),
                PaddingBottom = UDimNew(0, 6),
                PaddingRight = UDimNew(0, 6),
                PaddingLeft = UDimNew(0, 6)
            })

            Items["Palette"] = Instances:Create("TextButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Position = UDim2New(0, 0, 0, 15),
                Size = UDim2New(1, -26, 1, -40),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0)
            })

            Items["Saturation"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Saturation"),
                BackgroundTransparency = 1,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Value"] = Instances:Create("ImageLabel", {
                Parent = Items["Palette"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Value"),
                BackgroundTransparency = 1,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Palette"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["PaletteDragger"] = Instances:Create("Frame", {
                Parent = Items["Palette"].Instance,
                AnchorPoint = Vector2New(0.5, 0.5),
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 2, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["PaletteDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Hue"] = Instances:Create("ImageButton", {
                Parent = Items["ColorpickerWindow"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                AutoButtonColor = false,
                AnchorPoint = Vector2New(1, 0),
                Image = Library:GetImage("Hue"),
                Name = "\0",
                Position = UDim2New(1, 0, 0, 15),
                Size = UDim2New(0, 18, 1, -15),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["HueDragger"] = Instances:Create("Frame", {
                Parent = Items["Hue"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["HueDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Hue"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
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
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, -26, 0, 18),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 0, 0)
            })

            Instances:Create("UIStroke", {
                Parent = Items["Alpha"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Checkers"] = Instances:Create("ImageLabel", {
                Parent = Items["Alpha"].Instance,
                ScaleType = Enum.ScaleType.Tile,
                BorderColor3 = FromRGB(0, 0, 0),
                Image = Library:GetImage("Checkers"),
                TileSize = UDim2New(0, 6, 0, 6),
                Name = "\0",
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
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(0, 1, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIStroke", {
                Parent = Items["AlphaDragger"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})
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
                        Name = "\0",
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
                    Vector2New(
                        238,
                        224
                    )

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
                Color =
                    FromHex(
                        Color
                    )
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
                Alpha
                or 0

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
                        self.Saturation,
                        0,
                        0.989
                    ),
                    0,
                    MathClamp(
                        1
                        - self.Value,
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

            Items[
                "ColorpickerButton"
            ].Instance.BackgroundColor3 =
                self.Color

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
                    SlideX

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
                    BorderSizePixel = 2,
                    AutomaticSize =
                        Enum.AutomaticSize.X,
                    TextSize = 14,
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
                    BorderSizePixel = 2,
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
                        TextSize = 13,
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
            Name = Data.Name or Data.name or "Window",
            Size = Data.Size or Data.size or UDim2New(0, 500, 0, 600),

            FadeSpeed = Data.FadeSpeed or Data.fadespeed or 0.25,

            Pages = { },
            SubPages = { },
            Elements = { },

            IsOpen = true
        }

        local Items = { } do
            Items["MainFrame"] = Instances:Create("Frame", {
                Parent = Library.Holder.Instance,
                AnchorPoint = Vector2New(0, 0),
                Name = "\0",
                Position = UDim2New(0, 0, 0, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = Window.Size,
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["MainFrame"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Items["MainFrame"].Instance.Position = UDim2New(0, Camera.ViewportSize.X / 4, 0, Camera.ViewportSize.Y / 4)

            Items["MainFrame"]:MakeDraggable()
            Items["MainFrame"]:MakeResizeable(Vector2New(Window.Size.X.Offset, Window.Size.Y.Offset), Vector2New(9999, 9999))

            Items["AccentBorder"] = Instances:Create("UIStroke", {
                Parent = Items["MainFrame"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(235, 157, 255)
            })  Items["AccentBorder"]:AddToTheme({Color = "Accent"})

            Items["Title"] = Instances:Create("TextLabel", {
                Parent = Items["MainFrame"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Window.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 15),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                Position = UDim2New(0, 6, 0, 1),
                BorderSizePixel = 0,
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Title"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Title"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Inline"] = Instances:Create("Frame", {
                Parent = Items["MainFrame"].Instance,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 20),
                BorderColor3 = FromRGB(27, 27, 32),
                Size = UDim2New(1, -14, 1, -27),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Inline"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Inline"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Library.Theme.Border,
                Name = "\0"
            }):AddToTheme({Color = "Border"})

            Items["Pages"] = Instances:Create("Frame", {
                Parent = Items["Inline"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 7),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -14, 0, 19),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Pages"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding = UDimNew(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Inline"].Instance,
                Name = "\0",
                Position = UDim2New(0, 7, 0, 26),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, -14, 1, -33),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Content"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Content"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Library.Theme.Outline,
                Name = "\0"
            }):AddToTheme({Color = "Outline"})
        end

        local Debounce = false

        function Window:SetOpen(
            Bool
        )
            Bool =
                Bool == true

            Window.IsOpen =
                Bool

            Items[
                "MainFrame"
            ].Instance.Visible =
                Bool

            if not Bool
                and Library.CurrentColorpicker
            then
                Library.CurrentColorpicker:
                    SetOpen(
                        false
                    )
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

    Library.Page = function(self, Data)
        Data = Data or { }

        local Page = {
            Window = self,

            Name = Data.Name or Data.name or "Page",
            Columns = Data.Columns or Data.columns or 2,

            HasSubtabs = Data.Subtabs or Data.subtabs or false,

            Active = false,
            ColumnsData = { },
            Elements = { }
        }

        local Items = { } do
            Items["Inactive"] = Instances:Create("TextButton", {
                Parent = Page.Window.Elements["Pages"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 2,
                TextSize = 14,
                BackgroundColor3 = FromRGB(30, 30, 35)
            })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Inactive"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                Color = Library.Theme.Outline,
                Name = "\0"
            }):AddToTheme({Color = "Outline"})

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Inactive"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                TextTransparency = 0.47999998927116394,
                Text = Page.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Position = UDim2New(0, 0, 0, -1),
                BorderSizePixel = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Hide"] = Instances:Create("Frame", {
                Parent = Items["Inactive"].Instance,
                Visible = false,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, 0, 0, 3),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["Hide"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["MiscPixel1"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                Size = UDim2New(0, 1, 0, 1),
                Name = "\0",
                Position = UDim2New(0, -1, 0, 1),
                BorderColor3 = FromRGB(0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })  Items["MiscPixel1"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["MiscPixel2"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(1, 0),
                Name = "\0",
                Position = UDim2New(1, 1, 0, 1),
                Size = UDim2New(0, 1, 0, 1),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })  Items["MiscPixel2"]:AddToTheme({BackgroundColor3 = "Outline"})

            Items["UIGradient"] = Instances:Create("UIGradient", {
                Parent = Items["Inactive"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(108, 108, 108))}
            })

            Items["Page"] = Instances:Create("Frame", {
                Parent = Page.Window.Elements["Content"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255),
                Visible = false
            })

            if not Page.HasSubtabs then
                Instances:Create("UIListLayout", {
                    Parent = Items["Page"].Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = Enum.UIFlexAlignment.Fill
                })

                for Index = 1, Page.Columns do
                    local NewColumn = Instances:Create("ScrollingFrame", {
                        Parent = Items["Page"].Instance,
                        ScrollBarImageColor3 = FromRGB(235, 157, 255),
                        Active = true,
                        AutomaticCanvasSize = Enum.AutomaticSize.Y,
                        ScrollBarThickness = 1,
                        Name = "\0",
                        BackgroundTransparency = 1,
                        Size = UDim2New(0, 100, 0, 100),
                        BackgroundColor3 = FromRGB(255, 255, 255),
                        BorderColor3 = FromRGB(0, 0, 0),
                        BorderSizePixel = 0,
                        BottomImage = Library:GetImage("Scrollbar"),
                        MidImage = Library:GetImage("Scrollbar"),
                        TopImage = Library:GetImage("Scrollbar"),
                        CanvasSize = UDim2New(0, 0, 0, 0)
                    })  NewColumn:AddToTheme({ScrollBarImageColor3 = "Accent"})

                    Instances:Create("UIPadding", {
                        Parent = NewColumn.Instance,
                        PaddingTop = UDimNew(0, 6),
                        PaddingBottom = UDimNew(0, 6),
                        PaddingRight = UDimNew(0, 6),
                        PaddingLeft = UDimNew(0, 6)
                    })

                    Instances:Create("UIListLayout", {
                        Parent = NewColumn.Instance,
                        Padding = UDimNew(0, 8),
                        SortOrder = Enum.SortOrder.LayoutOrder
                    })

                    Page.ColumnsData[Index] = NewColumn
                end
            else
                Items["Columns"] = Instances:Create("Frame", {
                    Parent = Items["Page"].Instance,
                    Name = "\0",
                    Position = UDim2New(0, 7, 0, 45),
                    BorderColor3 = FromRGB(10, 10, 10),
                    Size = UDim2New(1, -14, 1, -52),
                    BorderSizePixel = 2,
                    BackgroundColor3 = FromRGB(15, 15, 20)
                })  Items["Columns"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

                Items["SubTabs"] = Instances:Create("Frame", {
                    Parent = Items["Page"].Instance,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Position = UDim2New(0, 7, 0, 7),
                    BorderColor3 = FromRGB(0, 0, 0),
                    Size = UDim2New(1, -14, 0, 35),
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(255, 255, 255)
                })

                Instances:Create("UIListLayout", {
                    Parent = Items["SubTabs"].Instance,
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalFlex = Enum.UIFlexAlignment.Fill,
                    Padding = UDimNew(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
            end
        end

        local Debounce = false

        function Page:Turn(
            Bool
        )
            Bool =
                Bool == true

            Page.Active =
                Bool

            Items[
                "Page"
            ].Instance.Visible =
                Bool

            Items[
                "Hide"
            ].Instance.Visible =
                Bool

            Items[
                "Text"
            ].Instance.TextColor3 =
                Bool
                and Library.Theme.Accent
                or Library.Theme.Text

            Items[
                "Text"
            ].Instance.TextTransparency =
                Bool
                and 0
                or 0.5

            Items[
                "Text"
            ]:
                ChangeItemTheme({
                    TextColor3 =
                        Bool
                        and "Accent"
                        or "Text"
                })
        end

        Items["Inactive"]:Connect("MouseButton1Down", function()
            for Index, Value in Page.Window.Pages do
                Value:Turn(Value == Page)
            end
        end)

        if #Page.Window.Pages == 0 then
            Page:Turn(true)
        end

        Page.Elements = Items

        TableInsert(Page.Window.Pages, Page)
        return setmetatable(Page, Library.Pages)
    end

    Library.Pages.SubPage = function(self, Data)
        Data = Data or { }

        local SubPage = {
            Window = self.Window,
            Page = self,

            Icon = Data.Icon or Data.icon or "9080568477801",
            Columns = Data.Columns or Data.columns or 2,

            Active = false,
            ColumnsData = { },
            Elements = { }
        }

        local Items = { } do
            Items["Inactive"] = Instances:Create("TextButton", {
                Parent = SubPage.Page.Elements["SubTabs"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 1, -2),
                BorderSizePixel = 2,
                TextSize = 14,
                BackgroundColor3 = FromRGB(30, 30, 35)
            })  Items["Inactive"]:AddToTheme({BackgroundColor3 = "Page Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Inactive"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Hide"] = Instances:Create("Frame", {
                Parent = Items["Inactive"].Instance,
                Visible = false,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 2),
                Size = UDim2New(1, 0, 0, 2),
                ZIndex = 5,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Hide"]:AddToTheme({BackgroundColor3 = "Background"})

            Items["MiscPixel1"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                Size = UDim2New(0, 1, 0, 1),
                Name = "\0",
                Position = UDim2New(0, -1, 0, 1),
                BorderColor3 = FromRGB(0, 0, 0),
                ZIndex = 5,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })

            Items["MiscPixel2"] = Instances:Create("Frame", {
                Parent = Items["Hide"].Instance,
                BorderColor3 = FromRGB(0, 0, 0),
                AnchorPoint = Vector2New(1, 0),
                Name = "\0",
                Position = UDim2New(1, 1, 0, 1),
                Size = UDim2New(0, 1, 0, 1),
                ZIndex = 5,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 27, 32)
            })

            Items["Icon"] = Instances:Create("ImageLabel", {
                Parent = Items["Inactive"].Instance,
                ScaleType = Enum.ScaleType.Fit,
                ImageTransparency = 0.35,
                BorderColor3 = FromRGB(0, 0, 0),
                Name = "\0",
                AnchorPoint = Vector2New(0.5, 0.5),
                Image = "rbxassetid://"..SubPage.Icon,
                BackgroundTransparency = 1,
                Position = UDim2New(0.5, 0, 0.5, 0),
                Size = UDim2New(0, 30, 0, 30),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Icon"]:AddToTheme({ImageColor3 = "Text"})

            Instances:Create("UIGradient", {
                Parent = Items["Inactive"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(138, 138, 138))}
            })

            Items["Subtab"] = Instances:Create("Frame", {
                Parent = SubPage.Page.Elements["Columns"].Instance,
                BackgroundTransparency = 1,
                Name = "\0",
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Instances:Create("UIPadding", {
                Parent = Items["Subtab"].Instance,
                PaddingTop = UDimNew(0, 6),
                PaddingRight = UDimNew(0, 6),
                PaddingLeft = UDimNew(0, 6)
            })

            Instances:Create("UIListLayout", {
                Parent = Items["Subtab"].Instance,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalFlex = Enum.UIFlexAlignment.Fill
            })

            Instances:Create("UIStroke", {
                Parent = Items["Subtab"].Instance,
                Color = FromRGB(27, 27, 32),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})

            for Index = 1, SubPage.Columns do
                local NewColumn = Instances:Create("ScrollingFrame", {
                    Parent = Items["Subtab"].Instance,
                    ScrollBarImageColor3 = FromRGB(235, 157, 255),
                    Active = true,
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ScrollBarThickness = 1,
                    Name = "\0",
                    BackgroundTransparency = 1,
                    Size = UDim2New(0, 100, 0, 100),
                    BackgroundColor3 = FromRGB(255, 255, 255),
                    BorderColor3 = FromRGB(0, 0, 0),
                    BorderSizePixel = 0,
                    CanvasSize = UDim2New(0, 0, 0, 0)
                })  NewColumn:AddToTheme({ScrollBarImageColor3 = "Accent"})

                Instances:Create("UIPadding", {
                    Parent = NewColumn.Instance,
                    PaddingTop = UDimNew(0, 6),
                    PaddingBottom = UDimNew(0, 6),
                    PaddingRight = UDimNew(0, 6),
                    PaddingLeft = UDimNew(0, 6)
                })

                Instances:Create("UIListLayout", {
                    Parent = NewColumn.Instance,
                    Padding = UDimNew(0, 8),
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                SubPage.ColumnsData[Index] = NewColumn
            end
        end

        local Debounce = false

        function SubPage:Turn(
            Bool
        )
            Bool =
                Bool == true

            SubPage.Active =
                Bool

            Items[
                "Subtab"
            ].Instance.Visible =
                Bool

            Items[
                "Hide"
            ].Instance.Visible =
                Bool

            Items[
                "Icon"
            ].Instance.ImageColor3 =
                Bool
                and Library.Theme.Accent
                or Library.Theme.Text

            Items[
                "Icon"
            ].Instance.ImageTransparency =
                Bool
                and 0
                or 0.35

            Items[
                "Icon"
            ]:
                ChangeItemTheme({
                    ImageColor3 =
                        Bool
                        and "Accent"
                        or "Text"
                })

            Items[
                "Inactive"
            ].Instance.Size =
                Bool
                and UDim2New(
                    1,
                    0,
                    1,
                    1
                )
                or UDim2New(
                    1,
                    0,
                    1,
                    -2
                )
        end

        Items["Inactive"]:Connect("MouseButton1Down", function()
            for Index, Value in SubPage.Window.SubPages do
                Value:Turn(Value == SubPage)
            end
        end)

        if #SubPage.Window.SubPages == 0 then
            SubPage:Turn(true)
        end

        SubPage.Elements = Items

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

        local Items = { } do
            Items["Section"] = Instances:Create("Frame", {
                Parent = Section.Page.ColumnsData[Section.Side].Instance,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 25),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["Section"].Instance,
                Color = FromRGB(10, 10, 10),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["Section"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
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
                Name = "\0",
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
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Content"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
                BackgroundTransparency = 1,
                Position = UDim2New(0, 7, 0, 21),
                BorderColor3 = FromRGB(0, 0, 0),
                Size = UDim2New(1, -14, 1, -20),
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(255, 255, 255)
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
                Name = "\0",
                Size = UDim2New(1, 0, 0, 25),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["MultiSection"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

            Instances:Create("UIStroke", {
                Parent = Items["MultiSection"].Instance,
                Color = FromRGB(10, 10, 10),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["MultiSection"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["MultiSection"].Instance,
                Name = "\0",
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
                Name = "\0",
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
                Name = "\0",
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
                    Name = "\0",
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
                    Name = "\0",
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
                    Name = "\0"
                }):AddToTheme({Color = "Text Border"})

                SubItems["Hide"] = Instances:Create("Frame", {
                    Parent = SubItems["Inactive"].Instance,
                    Visible = false,
                    BorderColor3 = FromRGB(0, 0, 0),
                    AnchorPoint = Vector2New(0, 1),
                    Name = "\0",
                    Position = UDim2New(0, 0, 1, 0),
                    Size = UDim2New(1, 0, 0, 3),
                    ZIndex = 2,
                    BorderSizePixel = 0,
                    BackgroundColor3 = FromRGB(15, 15, 20)
                })  SubItems["Hide"]:AddToTheme({BackgroundColor3 = "Background"})

                SubItems["MiscPixel1"] = Instances:Create("Frame", {
                    Parent = SubItems["Hide"].Instance,
                    Size = UDim2New(0, 1, 0, 1),
                    Name = "\0",
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
                    Name = "\0",
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
                    Name = "\0",
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
                    Name = "\0",
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
                Name = "\0",
                Size = UDim2New(1, 0, 0, Section.Size),
                BorderColor3 = FromRGB(27, 27, 32),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["Section"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Outline"})

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
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Border"})

            Instances:Create("UIPadding", {
                Parent = Items["Section"].Instance,
                PaddingBottom = UDimNew(0, 6)
            })

            Items["AccentLine"] = Instances:Create("Frame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
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
                Name = "\0",
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
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Content"] = Instances:Create("ScrollingFrame", {
                Parent = Items["Section"].Instance,
                Name = "\0",
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
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 3),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(15, 15, 20)
            })  Items["RealDivider"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["RealDivider"].Instance,
                Color = FromRGB(27, 27, 32),
                Name = "\0",
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
            Items["Toggle"] = Instances:Create("TextButton", {
                Parent = Toggle.Section.Elements["Content"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(0, 0, 0),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Name = "\0",
                Size = UDim2New(1, 0, 0, 11),
                BorderSizePixel = 0,
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            Items["Indicator"] = Instances:Create("Frame", {
                Parent = Items["Toggle"].Instance,
                Name = "\0",
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(0, 10, 0, 10),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Indicator"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["Indicator"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIGradient", {
                Parent = Items["Indicator"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Toggle"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                TextTransparency = 0.48,
                Text = Toggle.Name,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                Position = UDim2New(0, 18, 0, -1),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                BorderColor3 = FromRGB(0, 0, 0),
                TextSize = 13,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })  Items["Text"]:AddToTheme({TextColor3 = "Text"})

            Instances:Create("UIStroke", {
                Parent = Items["Text"].Instance,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Toggle"]:OnHover(function()
                if Toggle.Value then
                    return
                end

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme["Hovered Element"]})
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["Toggle"]:OnHoverLeave(function()
                if Toggle.Value then
                    return
                end

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme["Element"]})
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})
            end)
        end

        function Toggle:Get()
            return Toggle.Value
        end

        function Toggle:Set(Bool)
            if Bool == nil then
                Toggle.Value =
                    not Toggle.Value
            else
                Toggle.Value =
                    Bool == true
            end

            Library.Flags[Toggle.Flag] =
                Toggle.Value

            if Toggle.KeybindExtension
                and type(
                    Toggle.KeybindExtension.SetState
                ) == "function"
            then
                Toggle.KeybindExtension:
                    SetState(
                        Toggle.Value,
                        true
                    )
            end

            if Toggle.Value then
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Accent"})

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Accent})
                Items["Text"]:Tween(nil, {TextTransparency = 0})
            else
                Items["Indicator"]:ChangeItemTheme({BackgroundColor3 = "Element"})

                Items["Indicator"]:Tween(nil, {BackgroundColor3 = Library.Theme.Element})
                Items["Text"]:Tween(nil, {TextTransparency = 0.48})
            end

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
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                Size = UDim2New(1, 0, 0, 17),
                Selectable = false,
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Button"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

            Instances:Create("UIGradient", {
                Parent = Items["Button"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Button"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Text"] = Instances:Create("TextLabel", {
                Parent = Items["Button"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Button.Name,
                Name = "\0",
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
                Name = "\0"
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
                Name = "\0",
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
                Name = "\0",
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
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["RealSlider"] = Instances:Create("TextButton", {
                Parent = Items["Slider"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Text = "",
                AutoButtonColor = false,
                Size = UDim2New(1, 0, 0, 10),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["RealSlider"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["RealSlider"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Instances:Create("UIGradient", {
                Parent = Items["RealSlider"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Items["Indicator"] = Instances:Create("Frame", {
                Parent = Items["RealSlider"].Instance,
                Name = "\0",
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
                Name = "\0",
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
                Name = "\0"
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
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Dropdown.Name,
                Name = "\0",
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
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["RealDropdown"] = Instances:Create("Frame", {
                Parent = Items["Dropdown"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 17),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["RealDropdown"]:AddToTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIGradient", {
                Parent = Items["RealDropdown"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["RealDropdown"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Open"] = Instances:Create("TextButton", {
                Parent = Items["RealDropdown"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "+",
                AutoButtonColor = false,
                Name = "\0",
                Size = UDim2New(1, 0, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Right,
                Position = UDim2New(0, -4, 0, -1),
                BorderSizePixel = 0,
                TextSize = 13,
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
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "--",
                Name = "\0",
                Size = UDim2New(1, -25, 1, 0),
                BackgroundTransparency = 1,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Position = UDim2New(0, 5, 0, -1),
                BorderSizePixel = 0,
                TextSize = 13,
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
                BorderColor3 = FromRGB(10, 10, 10),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 5),
                Size = UDim2New(1, 0, 0, 0),
                BorderSizePixel = 2,
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = FromRGB(20, 20, 25)
            })  Items["OptionHolder"]:AddToTheme({BackgroundColor3 = "Inline", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["OptionHolder"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

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
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Hovered Element", BorderColor3 = "Border"})
            end)

            Items["RealDropdown"]:OnHoverLeave(function()
                Items["RealDropdown"]:Tween(nil, {BackgroundColor3 = Library.Theme["Background"]})
                Items["RealDropdown"]:ChangeItemTheme({BackgroundColor3 = "Background", BorderColor3 = "Border"})
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
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionButton.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
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
                TextSize = 13,
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
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Label.Name,
                Name = "\0",
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
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = Textbox.Name,
                Name = "\0",
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
                Name = "\0"
            }):AddToTheme({Color = "Text Border"})

            Items["Background"] = Instances:Create("Frame", {
                Parent = Items["Textbox"].Instance,
                AnchorPoint = Vector2New(0, 1),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BorderColor3 = FromRGB(10, 10, 10),
                Size = UDim2New(1, 0, 0, 17),
                BorderSizePixel = 2,
                BackgroundColor3 = FromRGB(33, 33, 36)
            })  Items["Background"]:AddToTheme({BackgroundColor3 = "Element", BorderColor3 = "Border"})

            Instances:Create("UIGradient", {
                Parent = Items["Background"].Instance,
                Rotation = 90,
                Color = RGBSequence{RGBSequenceKeypoint(0, FromRGB(255, 255, 255)), RGBSequenceKeypoint(1, FromRGB(100, 100, 100))}
            })

            Instances:Create("UIStroke", {
                Parent = Items["Background"].Instance,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                LineJoinMode = Enum.LineJoinMode.Miter,
                Name = "\0",
                Color = FromRGB(27, 27, 32)
            }):AddToTheme({Color = "Outline"})

            Items["Inline"] = Instances:Create("TextBox", {
                Parent = Items["Background"].Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
                BorderColor3 = FromRGB(0, 0, 0),
                Text = "",
                Name = "\0",
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
                ScrollBarImageColor3 = FromRGB(235, 157, 255),
                Active = true,
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 1,
                AnchorPoint = Vector2New(0, 1),
                Size = UDim2New(1, 0, 1, 0),
                Name = "\0",
                Position = UDim2New(0, 0, 1, 0),
                BackgroundColor3 = FromRGB(15, 15, 20),
                BorderColor3 = FromRGB(10, 10, 10),
                BorderSizePixel = 2,
                CanvasSize = UDim2New(0, 0, 0, 0)
            })  Items["RealListbox"]:AddToTheme({ScrollBarImageColor3 = "Accent", BackgroundColor3 = "Background", BorderColor3 = "Border"})

            Instances:Create("UIStroke", {
                Parent = Items["RealListbox"].Instance,
                Color = FromRGB(27, 27, 32),
                Name = "\0",
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            }):AddToTheme({Color = "Outline"})

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
                TextSize = 14,
                BackgroundColor3 = FromRGB(255, 255, 255)
            })

            local OptionText = Instances:Create("TextLabel", {
                Parent = OptionButton.Instance,
                FontFace = Library.Font,
                TextColor3 = FromRGB(215, 215, 215),
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
                TextSize = 13,
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
