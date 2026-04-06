local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Phantom = {}

local Theme = {
    Main = Color3.fromRGB(10, 10, 10),
    Sidebar = Color3.fromRGB(15, 15, 15),
    Section = Color3.fromRGB(20, 20, 20),
    Stroke = Color3.fromRGB(50, 15, 15),
    Accent = Color3.fromRGB(220, 30, 30),
    Text = Color3.fromRGB(245, 245, 245),
    TextDark = Color3.fromRGB(150, 150, 150),
    SidebarTransparency = 0,
    MainTransparency = 0.05,
    NotifTransparency = 0.1,
    ErrorRed = Color3.fromRGB(200, 0, 0)
}

local Settings = {}
local SettingsFile = "Phantom_Config.json"
local ThemeRegistry = {}

local function LoadSettings()
    if isfile and isfile(SettingsFile) and readfile then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(SettingsFile))
        end)
        if success then
            Settings = result
        end
    end
end

local function SaveSettings()
    if writefile then
        pcall(function()
            writefile(SettingsFile, HttpService:JSONEncode(Settings))
        end)
    end
end

LoadSettings()

local function Create(instance, properties, children)
    local obj = Instance.new(instance)
    for k, v in pairs(properties) do
        obj[k] = v
    end
    if children then
        for _, child in pairs(children) do
            child.Parent = obj
        end
    end
    return obj
end

local function Tween(obj, props, duration, style, direction)
    local info = TweenInfo.new(
        duration or 0.25, 
        style or Enum.EasingStyle.Quart, 
        direction or Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

local function GetIcon(name)
    local icons = {
        Combat = "rbxassetid://75666516613797",
        Visuals = "rbxassetid://131804094851461",
        Settings = "rbxassetid://125142287445982",
        Misc = "rbxassetid://74724520908176",
        Home = "rbxassetid://10747384394",
        Target = "rbxassetid://88733240786900",
        User = "rbxassetid://120214019251678",
        Lock = "rbxassetid://72241908544847"
    }
    if icons[name] then
        return icons[name]
    elseif string.find(tostring(name), "rbxassetid://") then
        return name
    elseif string.find(tostring(name), "http://") then
        return name
    elseif tonumber(name) then
        return "rbxassetid://" .. tostring(name)
    else
        return "rbxassetid://10747384394"
    end
end

local function ShortenKey(keyName)
    local replacements = {
        ["LeftControl"] = "L-Ctrl",
        ["RightControl"] = "R-Ctrl",
        ["LeftShift"] = "L-Shift",
        ["RightShift"] = "R-Shift",
        ["LeftAlt"] = "L-Alt",
        ["RightAlt"] = "R-Alt",
        ["CapsLock"] = "Caps",
        ["Return"] = "Enter",
        ["Backspace"] = "Back",
        ["MouseButton1"] = "M1",
        ["MouseButton2"] = "M2",
        ["MouseButton3"] = "M3",
        ["Unknown"] = "None"
    }
    return replacements[keyName] or keyName
end

local function RegisterTheme(instance, propType)
    ThemeRegistry[instance] = propType
    
    instance.AncestryChanged:Connect(function(_, parent)
        if not parent then
            ThemeRegistry[instance] = nil
        end
    end)
    
    return instance
end

function Phantom:UpdateTheme(newColor)
    Theme.Accent = newColor
    for instance, propType in pairs(ThemeRegistry) do
        if instance and instance.Parent then
            if propType == "TextColor" then 
                instance.TextColor3 = newColor
            elseif propType == "BackgroundColor" then 
                instance.BackgroundColor3 = newColor
            elseif propType == "BorderColor" then 
                instance.Color = newColor
            elseif propType == "ImageColor" then 
                instance.ImageColor3 = newColor
            elseif propType == "ScrollBar" then 
                instance.ScrollBarImageColor3 = newColor
            end
        end
    end
end

local function MakeDraggable(dragObj, moveObj)
    local dragging, dragInput, dragStart, startPos

    dragObj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = moveObj.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragObj.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            local scale = moveObj:FindFirstAncestorOfClass("ScreenGui") and moveObj:FindFirstAncestorOfClass("ScreenGui").AbsoluteSize or Vector2.new(1, 1)
            moveObj.Position = UDim2.new(
                startPos.X.Scale, 
                startPos.X.Offset + delta.X, 
                startPos.Y.Scale, 
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Phantom:Notify(title, text, duration)
    local ScreenGui = CoreGui:FindFirstChild("PhantomUI")
    if not ScreenGui then return end
    
    local Container = ScreenGui:FindFirstChild("NotifContainer")
    if not Container then
        Container = Create("Frame", {
            Name = "NotifContainer",
            Parent = ScreenGui,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -320, 1, -20),
            Size = UDim2.new(0, 300, 1, 0),
            AnchorPoint = Vector2.new(0, 1)
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                Padding = UDim.new(0, 10)
            })
        })
    end

    local NotifFrame = Create("Frame", {
        Parent = Container,
        BackgroundColor3 = Theme.Section,
        BackgroundTransparency = Theme.NotifTransparency,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
        Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
        Create("Frame", {
            BackgroundColor3 = Theme.Accent,
            Size = UDim2.new(0, 4, 1, 0)
        }, {Create("UICorner", {CornerRadius = UDim.new(0, 2)})}),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 10),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 21
        }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 30),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.Gotham,
            Text = text,
            TextColor3 = Theme.TextDark,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 21
        })
    })
    
    Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 70)}, 0.25)
    
    task.delay(duration or 3, function()
        Tween(NotifFrame, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.3)
        wait(0.3)
        NotifFrame:Destroy()
    end)
end

function Phantom:Window(title)
    if CoreGui:FindFirstChild("PhantomUI") then
        CoreGui.PhantomUI:Destroy()
    end

    local Viewport = Camera.ViewportSize
    local WindowSize = UDim2.new(0, 800, 0, 550)

    if Viewport.X < 500 then
        WindowSize = UDim2.new(0.95, 0, 0.9, 0)
    elseif Viewport.X < 1100 then
        WindowSize = UDim2.new(0.85, 0, 0.75, 0)
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "PhantomUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999,
        IgnoreGuiInset = true
    })

    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Main,
        BackgroundTransparency = Theme.MainTransparency,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = WindowSize,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Active = true
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 14)}),
        Create("UIStroke", {Color = Theme.Stroke, Thickness = 1})
    })

    local TopBar = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        Active = true
    }, {
        Create("ImageButton", {
            Name = "ToggleButton",
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0.5, 0),
            Size = UDim2.new(0, 20, 0, 20),
            AnchorPoint = Vector2.new(0, 0.5),
            Image = GetIcon("Target"),
            ImageColor3 = Theme.Accent
        }),
        Create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 45, 0, 0),
            Size = UDim2.new(0.5, 0, 1, 0),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Text,
            TextSize = 18,
            TextXAlignment = Enum.TextXAlignment.Left,
            RichText = true
        })
    })

    RegisterTheme(TopBar.ToggleButton, "ImageColor")

    local Sidebar = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Theme.Sidebar,
        BackgroundTransparency = Theme.SidebarTransparency,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 200, 1, -50),
        BorderSizePixel = 0,
        ClipsDescendants = true
    }, {
        Create("UICorner", {CornerRadius = UDim.new(0, 14)}),
        Create("Frame", {
            Name = "Decoration",
            BackgroundColor3 = Theme.Sidebar,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -1, 0, 0),
            Size = UDim2.new(0, 1, 1, 0),
            BorderSizePixel = 0,
            ZIndex = 2
        }, {Create("UIStroke", {Color = Theme.Stroke, Thickness = 1})})
    })

    local SidebarContent = Create("Frame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = 3
    }, {
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        }),
        Create("UIPadding", {
            PaddingTop = UDim.new(0, 10), 
            PaddingLeft = UDim.new(0, 15), 
            PaddingRight = UDim.new(0, 15)
        })
    })

    local Container = Create("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 215, 0, 60),
        Size = UDim2.new(1, -230, 1, -75),
        ClipsDescendants = true
    })
    
    local IsHidden = false
    local CurrentWindowPosition = UDim2.new(0.5, 0, 0.5, 0)
    local IsAnimating = false
    
    local ToggleButtonGui = Create("ScreenGui", {
        Name = "PhantomToggle",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 1000,
        IgnoreGuiInset = true,
        Enabled = false
    })

    local MainBtn = Create("TextButton", {
        Parent = ToggleButtonGui,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0, 20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Main,
        BackgroundTransparency = Theme.MainTransparency,
        Text = "P",
        TextColor3 = Theme.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        AutoButtonColor = false
    }, {
        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
        Create("UIStroke", {Color = Theme.Accent, Thickness = 2})
    })

    RegisterTheme(MainBtn, "TextColor")
    RegisterTheme(MainBtn:FindFirstChildOfClass("UIStroke"), "BorderColor")
    
    MakeDraggable(MainBtn, MainBtn)
    
    local function ToggleVisibility()
        if IsAnimating then return end
        IsAnimating = true
        IsHidden = not IsHidden
        
        if IsHidden then
            CurrentWindowPosition = Main.Position
            Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.2)
            Main.Visible = false
            ToggleButtonGui.Enabled = true
            Tween(MainBtn, {Size = UDim2.new(0, 45, 0, 45)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            MainBtn.Position = UDim2.new(0, 20, 0.5, 0)
            Tween(MainBtn, {Size = UDim2.new(0, 0, 0, 0)}, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            task.wait(0.2)
            ToggleButtonGui.Enabled = false
            Main.Position = CurrentWindowPosition
            Main.Size = UDim2.new(0, 0, 0, 0)
            Main.Visible = true
            Tween(Main, {Size = WindowSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
        
        task.wait(0.3)
        IsAnimating = false
    end

    local function UpdateWindowSize()
        local Viewport = Camera.ViewportSize
        local newWindowSize = UDim2.new(0, 800, 0, 550)

        if Viewport.X < 500 then
            newWindowSize = UDim2.new(0.95, 0, 0.9, 0)
        elseif Viewport.X < 1100 then
            newWindowSize = UDim2.new(0.85, 0, 0.75, 0)
        end
        
        WindowSize = newWindowSize
        if not IsHidden then
            Main.Size = newWindowSize
        end
    end
    
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateWindowSize)
    
    TopBar.ToggleButton.MouseButton1Click:Connect(ToggleVisibility)
    MainBtn.MouseButton1Click:Connect(ToggleVisibility)
    
    MakeDraggable(TopBar, Main)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Enum.KeyCode.LeftControl then
            ToggleVisibility()
        end
    end)

    local WindowObj = {}
    local Tabs = {}
    local First = true

    function WindowObj:Tab(name, icon)
        local TabObj = {}
        local TabData = {Selected = false}

        local TabBtn = Create("TextButton", {
            Parent = SidebarContent,
            BackgroundColor3 = Theme.Main,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 42),
            Text = "",
            AutoButtonColor = false
        }, {
            Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
            Create("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 12, 0.5, -10),
                Size = UDim2.new(0, 20, 0, 20),
                Image = GetIcon(icon or name),
                ImageColor3 = Theme.TextDark
            }),
            Create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 44, 0, 0),
                Size = UDim2.new(1, -44, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = name,
                TextColor3 = Theme.TextDark,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        })

        RegisterTheme(TabBtn.Icon, "ImageColor")

        local TabPage = Create("ScrollingFrame", {
            Parent = Container,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 4,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollingEnabled = true,
            ElasticBehavior = Enum.ElasticBehavior.Always,
            ScrollBarImageColor3 = Theme.Stroke
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12),
                FillDirection = Enum.FillDirection.Horizontal
            }),
            Create("UIPadding", {PaddingBottom = UDim.new(0, 10)})
        })

        RegisterTheme(TabPage, "ScrollBar")

        local LeftColumn = Create("Frame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -8, 1, 0),
            LayoutOrder = 1
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12)
            })
        })

        local RightColumn = Create("Frame", {
            Parent = TabPage,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, -8, 1, 0),
            LayoutOrder = 2
        }, {
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 12)
            })
        })

        local function UpdateCanvas()
            local leftHeight = LeftColumn.UIListLayout.AbsoluteContentSize.Y
            local rightHeight = RightColumn.UIListLayout.AbsoluteContentSize.Y
            local maxHeight = math.max(leftHeight, rightHeight)
            TabPage.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 20)
        end

        LeftColumn.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)
        RightColumn.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvas)

        local function Update()
            if TabData.Selected then
                Tween(TabBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Section}, 0.25)
                Tween(TabBtn.Icon, {ImageColor3 = Theme.Accent}, 0.25)
                Tween(TabBtn.Title, {TextColor3 = Theme.Text}, 0.25)
            else
                Tween(TabBtn, {BackgroundTransparency = 1}, 0.25)
                Tween(TabBtn.Icon, {ImageColor3 = Theme.TextDark}, 0.25)
                Tween(TabBtn.Title, {TextColor3 = Theme.TextDark}, 0.25)
            end
        end

        TabBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(Tabs) do
                t.Selected = false
                t.Update()
                t.Page.Visible = false
            end
            TabData.Selected = true
            Update()
            TabPage.Visible = true
        end)

        TabData.Update = Update
        TabData.Page = TabPage
        Tabs[#Tabs + 1] = TabData
        
        if First then
            First = false
            TabData.Selected = true
            Update()
            TabPage.Visible = true
        end

        function TabObj:Section(title, side)
            local Parent = (side == "Right") and RightColumn or LeftColumn
            local SectionObj = {}

            local SectionFrame = Create("Frame", {
                Parent = Parent,
                BackgroundColor3 = Theme.Section,
                BackgroundTransparency = 0.5,
                Size = UDim2.new(1, 0, 0, 100),
                ClipsDescendants = false
            }, {
                Create("UICorner", {CornerRadius = UDim.new(0, 10)}),
                Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                Create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 14, 0, 10),
                    Size = UDim2.new(1, -28, 0, 20),
                    Font = Enum.Font.GothamBold,
                    Text = title:upper(),
                    TextColor3 = Theme.TextDark,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
            })

            local Content = Create("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 40),
                Size = UDim2.new(1, 0, 0, 0)
            }, {
                Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder, 
                    Padding = UDim.new(0, 6)
                }),
                Create("UIPadding", {
                    PaddingLeft = UDim.new(0, 10), 
                    PaddingRight = UDim.new(0, 10), 
                    PaddingBottom = UDim.new(0, 10)
                })
            })

            local function ResizeSection()
                SectionFrame.Size = UDim2.new(1, 0, 0, Content.UIListLayout.AbsoluteContentSize.Y + 50)
            end

            Content.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(ResizeSection)
            ResizeSection()

            function SectionObj:Toggle(text, default, callback)
                if Settings[text] ~= nil then default = Settings[text] end
                local Toggled = default or false
                
                local ToggleBtn = Create("TextButton", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 38),
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -55, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("Frame", {
                        Name = "Switch",
                        BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(45, 45, 55),
                        Position = UDim2.new(1, -42, 0.5, -10),
                        Size = UDim2.new(0, 32, 0, 20)
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                        Create("Frame", {
                            Name = "Knob",
                            BackgroundColor3 = Theme.Text,
                            Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                            Size = UDim2.new(0, 16, 0, 16)
                        }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                    })
                })
                
                if Toggled then 
                    RegisterTheme(ToggleBtn.Switch, "BackgroundColor")
                end
                
                if Toggled then callback(Toggled) end

                ToggleBtn.MouseButton1Click:Connect(function()
                    Toggled = not Toggled
                    Settings[text] = Toggled
                    SaveSettings()
                    
                    if Toggled then
                        RegisterTheme(ToggleBtn.Switch, "BackgroundColor")
                    else
                        ThemeRegistry[ToggleBtn.Switch] = nil
                    end
                    
                    Tween(ToggleBtn.Switch, {
                        BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(45, 45, 55)
                    }, 0.25)
                    Tween(ToggleBtn.Switch.Knob, {
                        Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    }, 0.25)
                    callback(Toggled)
                end)
                
                return {
                    Set = function(value)
                        Toggled = value
                        Settings[text] = Toggled
                        SaveSettings()
                        
                        if Toggled then
                            RegisterTheme(ToggleBtn.Switch, "BackgroundColor")
                        else
                            ThemeRegistry[ToggleBtn.Switch] = nil
                        end
                        
                        ToggleBtn.Switch.BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(45, 45, 55)
                        ToggleBtn.Switch.Knob.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                        callback(Toggled)
                    end
                }
            end

            function SectionObj:Button(text, callback)
                local Btn = Create("TextButton", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 38),
                    Text = "",
                    AutoButtonColor = false
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    })
                })

                Btn.MouseEnter:Connect(function() 
                    Tween(Btn, {BackgroundColor3 = Theme.Stroke}, 0.2) 
                end)
                Btn.MouseLeave:Connect(function() 
                    Tween(Btn, {BackgroundColor3 = Theme.Main}, 0.2) 
                end)
                Btn.MouseButton1Click:Connect(function() 
                    callback() 
                end)
            end

            function SectionObj:Slider(text, min, max, default, callback)
                if Settings[text] ~= nil then default = Settings[text] end
                local Value = default or min
                local Dragging = false

                local SliderFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 50)
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 8),
                        Size = UDim2.new(1, -24, 0, 15),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("TextLabel", {
                        Name = "Val",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -52, 0, 8),
                        Size = UDim2.new(0, 40, 0, 15),
                        Font = Enum.Font.Gotham,
                        Text = tostring(Value),
                        TextColor3 = Theme.TextDark,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Right
                    }),
                    Create("Frame", {
                        Name = "Track",
                        BackgroundColor3 = Color3.fromRGB(45, 45, 55),
                        Position = UDim2.new(0, 12, 0, 35),
                        Size = UDim2.new(1, -24, 0, 4)
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(1, 0)}),
                        Create("Frame", {
                            Name = "Fill",
                            BackgroundColor3 = Theme.Accent,
                            Size = UDim2.new((Value - min) / (max - min), 0, 1, 0)
                        }, {Create("UICorner", {CornerRadius = UDim.new(1, 0)})})
                    })
                })

                local Track = SliderFrame.Track
                RegisterTheme(Track.Fill, "BackgroundColor")
                
                if default then callback(Value) end
                
                local function UpdateSlider(input)
                    local P = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    Value = math.floor((min + ((max - min) * P)) * 10) / 10
                    SliderFrame.Val.Text = tostring(Value)
                    Settings[text] = Value
                    Tween(Track.Fill, {Size = UDim2.new(P, 0, 1, 0)}, 0.05)
                    callback(Value)
                end
                
                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        Dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then 
                        Dragging = false 
                        SaveSettings()
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
                        UpdateSlider(input)
                    end
                end)
                
                return {
                    Set = function(value)
                        Value = math.clamp(value, min, max)
                        SliderFrame.Val.Text = tostring(Value)
                        Settings[text] = Value
                        local P = (Value - min) / (max - min)
                        Track.Fill.Size = UDim2.new(P, 0, 1, 0)
                        callback(Value)
                    end
                }
            end

            function SectionObj:TextBox(text, placeholder, callback)
                local BoxFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 38)
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(0.4, 0, 1, 0),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("TextBox", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.4, 10, 0, 0),
                        Size = UDim2.new(0.6, -22, 1, 0),
                        Font = Enum.Font.Gotham,
                        PlaceholderText = placeholder or "...",
                        PlaceholderColor3 = Color3.fromRGB(90, 90, 110),
                        Text = "",
                        TextColor3 = Theme.Accent,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        ClearTextOnFocus = false
                    })
                })
                
                RegisterTheme(BoxFrame.TextBox, "TextColor")
                
                if Settings[text] then
                    BoxFrame.TextBox.Text = Settings[text]
                    callback(Settings[text])
                end

                BoxFrame.TextBox.FocusLost:Connect(function()
                    Settings[text] = BoxFrame.TextBox.Text
                    SaveSettings()
                    callback(BoxFrame.TextBox.Text)
                end)
            end

            function SectionObj:Keybind(text, default, callback)
                local Key = default or Enum.KeyCode.E
                local Mode = "Toggle"
                local Binding = false
                local Active = false

                if Settings[text] then
                    if Settings[text].Key then
                        if pcall(function() return Enum.KeyCode[Settings[text].Key] end) then
                            Key = Enum.KeyCode[Settings[text].Key]
                        elseif pcall(function() return Enum.UserInputType[Settings[text].Key] end) then
                            Key = Enum.UserInputType[Settings[text].Key]
                        end
                    end
                    if Settings[text].Mode then Mode = Settings[text].Mode end
                end

                local BindFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 38),
                    ZIndex = 2
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -60, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    })
                })

                local BindBtn = Create("TextButton", {
                    Parent = BindFrame,
                    BackgroundColor3 = Theme.Section,
                    Position = UDim2.new(1, -55, 0, 6),
                    Size = UDim2.new(0, 45, 0, 26),
                    Font = Enum.Font.Gotham,
                    Text = ShortenKey(Key.Name),
                    TextColor3 = Theme.TextDark,
                    TextSize = 12,
                    AutoButtonColor = false
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}), 
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1})
                })

                local Context = Create("Frame", {
                    Parent = BindFrame,
                    BackgroundColor3 = Theme.Main,
                    Position = UDim2.new(1, -60, 1, 5),
                    Size = UDim2.new(0, 50, 0, 0),
                    ClipsDescendants = true,
                    Visible = false,
                    ZIndex = 200
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 6)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})
                })

                local function MakeModeBtn(name, modeVal)
                    local btn = Create("TextButton", {
                        Parent = Context,
                        BackgroundColor3 = Theme.Main,
                        Size = UDim2.new(1, 0, 0, 25),
                        Font = Enum.Font.Gotham,
                        Text = name,
                        TextColor3 = (Mode == modeVal) and Theme.Accent or Theme.TextDark,
                        TextSize = 11,
                        AutoButtonColor = false,
                        ZIndex = 201
                    })
                    
                    if Mode == modeVal then
                        RegisterTheme(btn, "TextColor")
                    end
                    
                    btn.MouseEnter:Connect(function() 
                        if Mode ~= modeVal then 
                            btn.TextColor3 = Theme.Text 
                        end 
                    end)
                    btn.MouseLeave:Connect(function() 
                        if Mode ~= modeVal then 
                            btn.TextColor3 = Theme.TextDark 
                        end 
                    end)

                    btn.MouseButton1Click:Connect(function()
                        for _, b in pairs(Context:GetChildren()) do
                            if b:IsA("TextButton") then 
                                ThemeRegistry[b] = nil
                                b.TextColor3 = Theme.TextDark
                            end
                        end
                        
                        Mode = modeVal
                        Settings[text] = {Key = Key.Name, Mode = Mode}
                        SaveSettings()
                        
                        Context.Visible = false
                        Tween(Context, {Size = UDim2.new(0, 50, 0, 0)}, 0.2)
                        BindFrame.ZIndex = 2
                        
                        btn.TextColor3 = Theme.Accent
                        RegisterTheme(btn, "TextColor")
                    end)
                end

                MakeModeBtn("Toggle", "Toggle")
                MakeModeBtn("Hold", "Hold")

                BindBtn.MouseButton1Click:Connect(function()
                    Binding = true
                    BindBtn.Text = "..."
                    BindBtn.TextColor3 = Theme.Accent
                end)

                BindBtn.MouseButton2Click:Connect(function()
                    if Context.Visible then
                        Tween(Context, {Size = UDim2.new(0, 50, 0, 0)}, 0.2)
                        task.delay(0.2, function() 
                            Context.Visible = false 
                            BindFrame.ZIndex = 2 
                        end)
                    else
                        BindFrame.ZIndex = 100
                        Context.Visible = true
                        Tween(Context, {Size = UDim2.new(0, 50, 0, 50)}, 0.2)
                    end
                end)

                UserInputService.InputBegan:Connect(function(input, processed)
                    if Binding then
                        local bindingInput
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            bindingInput = input.KeyCode
                        elseif input.UserInputType == Enum.UserInputType.MouseButton1 or 
                               input.UserInputType == Enum.UserInputType.MouseButton2 or 
                               input.UserInputType == Enum.UserInputType.MouseButton3 then
                            bindingInput = input.UserInputType
                        end

                        if bindingInput and bindingInput ~= Enum.KeyCode.Unknown then
                            Key = bindingInput
                            Binding = false
                            BindBtn.Text = ShortenKey(Key.Name)
                            BindBtn.TextColor3 = Theme.TextDark
                            Settings[text] = {Key = Key.Name, Mode = Mode}
                            SaveSettings()
                        end
                    elseif not processed then
                        local checkInput = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
                        if checkInput == Key then
                            if Mode == "Toggle" then
                                Active = not Active
                                callback(Active)
                            else
                                Active = true
                                callback(true)
                            end
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    local checkInput = (input.UserInputType == Enum.UserInputType.Keyboard) and input.KeyCode or input.UserInputType
                    if checkInput == Key and Mode == "Hold" then
                        Active = false
                        callback(false)
                    end
                end)
            end

            function SectionObj:ColorPicker(text, default, callback)
                if Settings[text] then
                    local c = Settings[text]
                    default = Color3.new(c.R, c.G, c.B)
                end
                
                local Color = default or Color3.fromRGB(255, 255, 255)
                local H, S, V = Color:ToHSV()
                local Expanded = false
                local DraggingColor = false
                local DraggingHue = false

                local PickerFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = true
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(1, -60, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("TextButton", {
                        Name = "Preview",
                        BackgroundColor3 = Color,
                        Position = UDim2.new(1, -42, 0, 9),
                        Size = UDim2.new(0, 30, 0, 20),
                        Text = "",
                        AutoButtonColor = false
                    }, {Create("UICorner", {CornerRadius = UDim.new(0, 4)})})
                })
                
                local Container = Create("Frame", {
                    Parent = PickerFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 45),
                    Size = UDim2.new(1, -20, 0, 140),
                    Visible = false
                })

                local SVBox = Create("ImageButton", {
                    Parent = Container,
                    BackgroundColor3 = Color3.fromHSV(H, 1, 1),
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -25, 1, 0),
                    AutoButtonColor = false,
                    Image = ""
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("Frame", {
                        Name = "Sat",
                        BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(1,0,1,0),
                        BorderSizePixel = 0,
                        ZIndex = 2
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(0, 4)}), 
                        Create("UIGradient", {
                            Color = ColorSequence.new(Color3.new(1,1,1)), 
                            Transparency = NumberSequence.new{
                                NumberSequenceKeypoint.new(0, 0), 
                                NumberSequenceKeypoint.new(1, 1)
                            }
                        })
                    }),
                    Create("Frame", {
                        Name = "Val",
                        BackgroundColor3 = Color3.new(0,0,0),
                        Size = UDim2.new(1,0,1,0),
                        BorderSizePixel = 0,
                        ZIndex = 3
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(0, 4)}), 
                        Create("UIGradient", {
                            Rotation = 90, 
                            Color = ColorSequence.new(Color3.new(0,0,0)), 
                            Transparency = NumberSequence.new{
                                NumberSequenceKeypoint.new(0, 1), 
                                NumberSequenceKeypoint.new(1, 0)
                            }
                        })
                    }),
                    Create("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(0, 8, 0, 8),
                        Position = UDim2.new(S, -4, 1 - V, -4),
                        ZIndex = 4
                    }, {
                        Create("UICorner", {CornerRadius = UDim.new(1, 0)}), 
                        Create("UIStroke", {Thickness = 1, Color = Color3.new(0,0,0)})
                    })
                })

                local HueBar = Create("ImageButton", {
                    Parent = Container,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Position = UDim2.new(1, -15, 0, 0),
                    Size = UDim2.new(0, 15, 1, 0),
                    AutoButtonColor = false
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 4)}),
                    Create("UIGradient", {
                        Rotation = 90, 
                        Color = ColorSequence.new{
                            ColorSequenceKeypoint.new(0, Color3.fromHSV(1,1,1)),
                            ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.834,1,1)),
                            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.667,1,1)),
                            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5,1,1)),
                            ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.333,1,1)),
                            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.167,1,1)),
                            ColorSequenceKeypoint.new(1, Color3.fromHSV(0,1,1))
                        }
                    }),
                    Create("Frame", {
                        Name = "Cursor",
                        BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(1, 4, 0, 4),
                        Position = UDim2.new(0.5, 0, 1 - H, 0),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        BorderSizePixel = 0
                    }, {Create("UIStroke", {Thickness = 1, Color = Color3.new(0,0,0)})})
                })

                if default then callback(Color) end

                local function UpdateColor()
                    Color = Color3.fromHSV(H, S, V)
                    PickerFrame.Preview.BackgroundColor3 = Color
                    SVBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                    Settings[text] = {R = Color.R, G = Color.G, B = Color.B}
                    callback(Color)
                end

                SVBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingColor = true
                    end
                end)

                HueBar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingHue = true
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                        DraggingColor = false
                        DraggingHue = false
                        SaveSettings()
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
                        if DraggingColor then
                            local Size = SVBox.AbsoluteSize
                            local Pos = SVBox.AbsolutePosition
                            local X = math.clamp((input.Position.X - Pos.X) / Size.X, 0, 1)
                            local Y = math.clamp((input.Position.Y - Pos.Y) / Size.Y, 0, 1)
                            S = X
                            V = 1 - Y
                            SVBox.Cursor.Position = UDim2.new(S, -4, 1 - V, -4)
                            UpdateColor()
                        elseif DraggingHue then
                            local Size = HueBar.AbsoluteSize
                            local Pos = HueBar.AbsolutePosition
                            local Y = math.clamp((input.Position.Y - Pos.Y) / Size.Y, 0, 1)
                            H = 1 - Y
                            HueBar.Cursor.Position = UDim2.new(0.5, 0, Y, 0)
                            UpdateColor()
                        end
                    end
                end)

                PickerFrame.Preview.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    Container.Visible = Expanded
                    Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, Expanded and 200 or 38)}, 0.25)
                end)
                
                return {
                    Set = function(color)
                        Color = color
                        H, S, V = Color:ToHSV()
                        PickerFrame.Preview.BackgroundColor3 = Color
                        SVBox.BackgroundColor3 = Color3.fromHSV(H, 1, 1)
                        SVBox.Cursor.Position = UDim2.new(S, -4, 1 - V, -4)
                        HueBar.Cursor.Position = UDim2.new(0.5, 0, 1 - H, 0)
                        Settings[text] = {R = Color.R, G = Color.G, B = Color.B}
                        callback(Color)
                    end
                }
            end

            function SectionObj:Dropdown(text, list, default, callback)
                if Settings[text] then default = Settings[text] end
                local Selected = default or list[1]
                local Expanded = false

                local DropFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = true,
                    ZIndex = 5
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(0.5, 0, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("TextLabel", {
                        Name = "Val",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(0.5, -35, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = Selected,
                        TextColor3 = Theme.Accent,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("ImageButton", {
                        Name = "Arrow",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -20, 0, 19),
                        Size = UDim2.new(0, 16, 0, 16),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Image = "rbxassetid://6031091004",
                        ImageColor3 = Theme.TextDark,
                        ZIndex = 6
                    }),
                    Create("Frame", {
                        Name = "List",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 38),
                        Size = UDim2.new(1, 0, 0, 0)
                    }, {
                        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})
                    })
                })
                
                RegisterTheme(DropFrame.Val, "TextColor")
                
                if default then callback(Selected) end

                for _, item in pairs(list) do
                    local ItemBtn = Create("TextButton", {
                        Parent = DropFrame.List,
                        BackgroundColor3 = Theme.Main,
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Enum.Font.Gotham,
                        Text = "  " .. item,
                        TextColor3 = Theme.TextDark,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        AutoButtonColor = false,
                        ZIndex = 6
                    })

                    ItemBtn.MouseEnter:Connect(function()
                        Tween(ItemBtn, {BackgroundColor3 = Theme.Section, TextColor3 = Theme.Text}, 0.2)
                    end)
                    ItemBtn.MouseLeave:Connect(function()
                        Tween(ItemBtn, {BackgroundColor3 = Theme.Main, TextColor3 = Theme.TextDark}, 0.2)
                    end)

                    ItemBtn.MouseButton1Click:Connect(function()
                        Selected = item
                        DropFrame.Val.Text = Selected
                        Expanded = false
                        Settings[text] = Selected
                        SaveSettings()
                        Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 38)}, 0.25)
                        Tween(DropFrame.Arrow, {Rotation = 0}, 0.25)
                        callback(item)
                    end)
                end

                DropFrame.Arrow.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, Expanded and (38 + #list * 30) or 38)}, 0.25)
                    Tween(DropFrame.Arrow, {Rotation = Expanded and 180 or 0}, 0.25)
                end)
                
                return {
                    Set = function(value)
                        Selected = value
                        DropFrame.Val.Text = Selected
                        Settings[text] = Selected
                        callback(value)
                    end
                }
            end

            function SectionObj:MultiDropdown(text, list, default, callback)
                if Settings[text] then default = Settings[text] end
                local Selected = default or {}
                local Expanded = false

                local function GetDisplayText()
                    if #Selected == 0 then
                        return "None"
                    elseif #Selected == #list then
                        return "All"
                    elseif #Selected <= 2 then
                        return table.concat(Selected, ", ")
                    else
                        return Selected[1] .. ", +" .. (#Selected - 1)
                    end
                end

                local DropFrame = Create("Frame", {
                    Parent = Content,
                    BackgroundColor3 = Theme.Main,
                    Size = UDim2.new(1, 0, 0, 38),
                    ClipsDescendants = true,
                    ZIndex = 5
                }, {
                    Create("UICorner", {CornerRadius = UDim.new(0, 8)}),
                    Create("UIStroke", {Color = Theme.Stroke, Thickness = 1}),
                    Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 12, 0, 0),
                        Size = UDim2.new(0.5, 0, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = text,
                        TextColor3 = Theme.Text,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("TextLabel", {
                        Name = "Val",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0, 0),
                        Size = UDim2.new(0.5, -35, 0, 38),
                        Font = Enum.Font.Gotham,
                        Text = GetDisplayText(),
                        TextColor3 = Theme.Accent,
                        TextSize = 13,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        TextTruncate = Enum.TextTruncate.AtEnd
                    }),
                    Create("ImageButton", {
                        Name = "Arrow",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, -20, 0, 19),
                        Size = UDim2.new(0, 16, 0, 16),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Image = "rbxassetid://6031091004",
                        ImageColor3 = Theme.TextDark,
                        ZIndex = 6
                    }),
                    Create("Frame", {
                        Name = "List",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0, 38),
                        Size = UDim2.new(1, 0, 0, 0)
                    }, {
                        Create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder})
                    })
                })

                RegisterTheme(DropFrame.Val, "TextColor")

                local function IsSelected(item)
                    for _, v in pairs(Selected) do
                        if v == item then return true end
                    end
                    return false
                end

                local function ToggleItem(item)
                    local found = false
                    for i, v in pairs(Selected) do
                        if v == item then
                            table.remove(Selected, i)
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(Selected, item)
                    end
                    DropFrame.Val.Text = GetDisplayText()
                    Settings[text] = Selected
                    SaveSettings()
                    callback(Selected)
                end

                local AllButton = Create("TextButton", {
                    Parent = DropFrame.List,
                    BackgroundColor3 = Theme.Main,
                    BackgroundTransparency = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.GothamBold,
                    Text = "  Select All",
                    TextColor3 = Theme.Accent,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 6,
                    LayoutOrder = 0
                })

                RegisterTheme(AllButton, "TextColor")

                AllButton.MouseEnter:Connect(function()
                    Tween(AllButton, {BackgroundColor3 = Theme.Section}, 0.2)
                end)
                AllButton.MouseLeave:Connect(function()
                    Tween(AllButton, {BackgroundColor3 = Theme.Main}, 0.2)
                end)

                AllButton.MouseButton1Click:Connect(function()
                    if #Selected == #list then
                        Selected = {}
                    else
                        Selected = {}
                        for _, item in pairs(list) do
                            table.insert(Selected, item)
                        end
                    end
                    DropFrame.Val.Text = GetDisplayText()
                    Settings[text] = Selected
                    SaveSettings()
                    callback(Selected)

                    for _, child in pairs(DropFrame.List:GetChildren()) do
                        if child:IsA("TextButton") and child ~= AllButton then
                            local itemName = child.Text:gsub("^  ", ""):gsub(" ✓$", "")
                            local selected = IsSelected(itemName)
                            child.Text = selected and ("  " .. itemName .. " ✓") or ("  " .. itemName)
                            if selected then
                                child.TextColor3 = Theme.Accent
                                RegisterTheme(child, "TextColor")
                            else
                                child.TextColor3 = Theme.TextDark
                                ThemeRegistry[child] = nil
                            end
                        end
                    end
                end)

                for idx, item in pairs(list) do
                    local isSelected = IsSelected(item)
                    local ItemBtn = Create("TextButton", {
                        Parent = DropFrame.List,
                        BackgroundColor3 = Theme.Main,
                        BackgroundTransparency = 0,
                        Size = UDim2.new(1, 0, 0, 30),
                        Font = Enum.Font.Gotham,
                        Text = isSelected and ("  " .. item .. " ✓") or ("  " .. item),
                        TextColor3 = isSelected and Theme.Accent or Theme.TextDark,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        AutoButtonColor = false,
                        ZIndex = 6,
                        LayoutOrder = idx
                    })

                    if isSelected then
                        RegisterTheme(ItemBtn, "TextColor")
                    end

                    ItemBtn.MouseEnter:Connect(function()
                        Tween(ItemBtn, {BackgroundColor3 = Theme.Section, TextColor3 = Theme.Text}, 0.2)
                    end)
                    ItemBtn.MouseLeave:Connect(function()
                        local selected = IsSelected(item)
                        Tween(ItemBtn, {
                            BackgroundColor3 = Theme.Main, 
                            TextColor3 = selected and Theme.Accent or Theme.TextDark
                        }, 0.2)
                    end)

                    ItemBtn.MouseButton1Click:Connect(function()
                        ToggleItem(item)
                        local selected = IsSelected(item)
                        ItemBtn.Text = selected and ("  " .. item .. " ✓") or ("  " .. item)
                        if selected then
                            ItemBtn.TextColor3 = Theme.Accent
                            RegisterTheme(ItemBtn, "TextColor")
                        else
                            ItemBtn.TextColor3 = Theme.TextDark
                            ThemeRegistry[ItemBtn] = nil
                        end
                    end)
                end

                DropFrame.Arrow.MouseButton1Click:Connect(function()
                    Expanded = not Expanded
                    Tween(DropFrame, {Size = UDim2.new(1, 0, 0, Expanded and (38 + (#list + 1) * 30) or 38)}, 0.25)
                    Tween(DropFrame.Arrow, {Rotation = Expanded and 180 or 0}, 0.25)
                end)

                if default and #default > 0 then 
                    callback(Selected) 
                end
                
                return {
                    Set = function(items)
                        Selected = items
                        DropFrame.Val.Text = GetDisplayText()
                        Settings[text] = Selected
                        callback(Selected)
                        
                        for _, child in pairs(DropFrame.List:GetChildren()) do
                            if child:IsA("TextButton") and child ~= AllButton then
                                local itemName = child.Text:gsub("^  ", ""):gsub(" ✓$", "")
                                local selected = IsSelected(itemName)
                                child.Text = selected and ("  " .. itemName .. " ✓") or ("  " .. itemName)
                                if selected then
                                    child.TextColor3 = Theme.Accent
                                    RegisterTheme(child, "TextColor")
                                else
                                    child.TextColor3 = Theme.TextDark
                                    ThemeRegistry[child] = nil
                                end
                            end
                        end
                    end
                }
            end

            return SectionObj
        end
        return TabObj
    end
    return WindowObj
end

return Phantom
