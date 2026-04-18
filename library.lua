local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

local NixwareUI = {
    Flags = {}
}

local Theme = {
    Background      = Color3.fromRGB(13, 13, 15),
    Surface         = Color3.fromRGB(18, 18, 22),
    SurfaceHigh     = Color3.fromRGB(24, 24, 30),
    SurfaceHover    = Color3.fromRGB(30, 30, 38),
    Border          = Color3.fromRGB(38, 38, 50),
    BorderLight     = Color3.fromRGB(55, 55, 72),
    Accent          = Color3.fromRGB(99, 120, 255),
    AccentDim       = Color3.fromRGB(60, 75, 180),
    AccentGlow      = Color3.fromRGB(130, 100, 255),
    TextPrimary     = Color3.fromRGB(235, 235, 245),
    TextSecondary   = Color3.fromRGB(130, 130, 155),
    TextMuted       = Color3.fromRGB(70, 70, 90),
    Success         = Color3.fromRGB(80, 210, 140),
    TooltipBg       = Color3.fromRGB(8, 8, 12),
    Shadow          = Color3.fromRGB(0, 0, 0),
    AccentSequence  = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(99, 120, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 100, 255))
    },
    SidebarGrad     = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 18, 24)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(13, 13, 17))
    }
}

local Font = Enum.Font.GothamMedium
local FontBold = Enum.Font.GothamBold
local FontLight = Enum.Font.Gotham

local TooltipGui = Instance.new("ScreenGui")
TooltipGui.Name = "NW_Tooltip"
TooltipGui.Parent = CoreGui
TooltipGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
TooltipGui.DisplayOrder = 999

local TooltipShadow = Instance.new("Frame")
TooltipShadow.BackgroundColor3 = Theme.Shadow
TooltipShadow.BackgroundTransparency = 0.5
TooltipShadow.BorderSizePixel = 0
TooltipShadow.Visible = false
TooltipShadow.ZIndex = 98
TooltipShadow.Parent = TooltipGui

local TooltipShadowCorner = Instance.new("UICorner")
TooltipShadowCorner.CornerRadius = UDim.new(0, 6)
TooltipShadowCorner.Parent = TooltipShadow

local TooltipFrame = Instance.new("Frame")
TooltipFrame.BackgroundColor3 = Theme.TooltipBg
TooltipFrame.BorderSizePixel = 0
TooltipFrame.Visible = false
TooltipFrame.ZIndex = 100
TooltipFrame.Parent = TooltipGui

local TooltipCorner = Instance.new("UICorner")
TooltipCorner.CornerRadius = UDim.new(0, 5)
TooltipCorner.Parent = TooltipFrame

local TooltipStroke = Instance.new("UIStroke")
TooltipStroke.Color = Theme.Border
TooltipStroke.Thickness = 1
TooltipStroke.Parent = TooltipFrame

local TooltipLabel = Instance.new("TextLabel")
TooltipLabel.Size = UDim2.new(1, -16, 1, 0)
TooltipLabel.Position = UDim2.new(0, 8, 0, 0)
TooltipLabel.BackgroundTransparency = 1
TooltipLabel.TextColor3 = Theme.TextSecondary
TooltipLabel.TextSize = 11
TooltipLabel.Font = FontLight
TooltipLabel.TextXAlignment = Enum.TextXAlignment.Left
TooltipLabel.ZIndex = 101
TooltipLabel.Parent = TooltipFrame

local TooltipConn = nil

local function ShowTooltip(text)
    if not text or text == "" then return end
    local bounds = TextService:GetTextSize(text, 11, FontLight, Vector2.new(400, 20))
    local w = bounds.X + 16
    local h = 22
    TooltipFrame.Size = UDim2.new(0, w, 0, h)
    TooltipShadow.Size = UDim2.new(0, w + 4, 0, h + 4)
    TooltipLabel.Text = text
    TooltipFrame.Visible = true
    TooltipShadow.Visible = true
    if TooltipConn then TooltipConn:Disconnect() end
    TooltipConn = RunService.RenderStepped:Connect(function()
        local m = UserInputService:GetMouseLocation()
        local px = m.X + 14
        local py = m.Y - 28
        TooltipFrame.Position = UDim2.fromOffset(px, py)
        TooltipShadow.Position = UDim2.fromOffset(px - 2, py + 2)
    end)
end

local function HideTooltip()
    TooltipFrame.Visible = false
    TooltipShadow.Visible = false
    if TooltipConn then
        TooltipConn:Disconnect()
        TooltipConn = nil
    end
end

local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    return tw
end

local function MakeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function MakeStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = parent
    return s
end

local function MakeShadow(parent, zindex)
    local s = Instance.new("Frame")
    s.Size = UDim2.new(1, 6, 1, 6)
    s.Position = UDim2.new(0, -3, 0, 3)
    s.BackgroundColor3 = Color3.new(0, 0, 0)
    s.BackgroundTransparency = 0.7
    s.BorderSizePixel = 0
    s.ZIndex = (zindex or 1) - 1
    s.Parent = parent
    MakeCorner(s, 8)
    return s
end

function NixwareUI:CreateWindow(title, subtitle)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NixwareEvolution"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false

    local MainShadow = Instance.new("Frame")
    MainShadow.Size = UDim2.new(0, 720, 0, 500)
    MainShadow.Position = UDim2.new(0.5, -360, 0.5, -250)
    MainShadow.BackgroundColor3 = Color3.new(0, 0, 0)
    MainShadow.BackgroundTransparency = 0.55
    MainShadow.BorderSizePixel = 0
    MainShadow.ZIndex = 1
    MainShadow.Parent = ScreenGui
    MakeCorner(MainShadow, 10)

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 720, 0, 500)
    Main.Position = UDim2.new(0.5, -360, 0.5, -250)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.ZIndex = 2
    Main.Parent = ScreenGui
    MakeCorner(Main, 8)
    MakeStroke(Main, Theme.Border, 1)

    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundColor3 = Theme.Surface
    TopBar.BorderSizePixel = 0
    TopBar.ZIndex = 3
    TopBar.Parent = Main
    MakeCorner(TopBar, 8)

    local TopBarBottomFix = Instance.new("Frame")
    TopBarBottomFix.Size = UDim2.new(1, 0, 0, 8)
    TopBarBottomFix.Position = UDim2.new(0, 0, 1, -8)
    TopBarBottomFix.BackgroundColor3 = Theme.Surface
    TopBarBottomFix.BorderSizePixel = 0
    TopBarBottomFix.ZIndex = 3
    TopBarBottomFix.Parent = TopBar

    local TopBorder = Instance.new("Frame")
    TopBorder.Size = UDim2.new(1, 0, 0, 1)
    TopBorder.Position = UDim2.new(0, 0, 1, -1)
    TopBorder.BackgroundColor3 = Theme.Border
    TopBorder.BorderSizePixel = 0
    TopBorder.ZIndex = 4
    TopBorder.Parent = TopBar

    local AccentLine = Instance.new("Frame")
    AccentLine.Size = UDim2.new(1, 0, 0, 2)
    AccentLine.BackgroundColor3 = Color3.new(1, 1, 1)
    AccentLine.BorderSizePixel = 0
    AccentLine.ZIndex = 4
    AccentLine.Parent = TopBar
    MakeCorner(AccentLine, 2)
    local AccentGrad = Instance.new("UIGradient")
    AccentGrad.Color = Theme.AccentSequence
    AccentGrad.Parent = AccentLine

    local TitleDot = Instance.new("Frame")
    TitleDot.Size = UDim2.new(0, 6, 0, 6)
    TitleDot.Position = UDim2.new(0, 14, 0.5, -3)
    TitleDot.BackgroundColor3 = Theme.Accent
    TitleDot.BorderSizePixel = 0
    TitleDot.ZIndex = 5
    TitleDot.Parent = TopBar
    MakeCorner(TitleDot, 3)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.5, -30, 1, -2)
    TitleLabel.Position = UDim2.new(0, 28, 0, 2)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title or "Nixware"
    TitleLabel.TextColor3 = Theme.TextPrimary
    TitleLabel.TextSize = 13
    TitleLabel.Font = FontBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 5
    TitleLabel.Parent = TopBar

    if subtitle then
        local SubLabel = Instance.new("TextLabel")
        SubLabel.Size = UDim2.new(0.5, -10, 1, -2)
        SubLabel.Position = UDim2.new(0.5, 0, 0, 2)
        SubLabel.BackgroundTransparency = 1
        SubLabel.Text = subtitle
        SubLabel.TextColor3 = Theme.TextMuted
        SubLabel.TextSize = 11
        SubLabel.Font = FontLight
        SubLabel.TextXAlignment = Enum.TextXAlignment.Right
        SubLabel.ZIndex = 5
        SubLabel.Parent = TopBar
    end

    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 148, 1, -40)
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.BackgroundColor3 = Theme.Surface
    Sidebar.BorderSizePixel = 0
    Sidebar.ZIndex = 3
    Sidebar.Parent = Main

    local SidebarBottomFix = Instance.new("Frame")
    SidebarBottomFix.Size = UDim2.new(1, 0, 0, 8)
    SidebarBottomFix.BackgroundColor3 = Theme.Surface
    SidebarBottomFix.BorderSizePixel = 0
    SidebarBottomFix.ZIndex = 3
    SidebarBottomFix.Parent = Sidebar

    local SidebarGrad = Instance.new("UIGradient")
    SidebarGrad.Color = Theme.SidebarGrad
    SidebarGrad.Rotation = 90
    SidebarGrad.Parent = Sidebar

    local SidebarBorderRight = Instance.new("Frame")
    SidebarBorderRight.Size = UDim2.new(0, 1, 1, 0)
    SidebarBorderRight.Position = UDim2.new(1, -1, 0, 0)
    SidebarBorderRight.BackgroundColor3 = Theme.Border
    SidebarBorderRight.BorderSizePixel = 0
    SidebarBorderRight.ZIndex = 4
    SidebarBorderRight.Parent = Sidebar

    local SidebarBottomRoundFix = Instance.new("Frame")
    SidebarBottomRoundFix.Size = UDim2.new(0, 8, 0, 8)
    SidebarBottomRoundFix.Position = UDim2.new(0, 0, 1, -8)
    SidebarBottomRoundFix.BackgroundColor3 = Theme.Surface
    SidebarBottomRoundFix.BorderSizePixel = 0
    SidebarBottomRoundFix.ZIndex = 3
    SidebarBottomRoundFix.Parent = Sidebar

    local TabList = Instance.new("Frame")
    TabList.Size = UDim2.new(1, 0, 1, 0)
    TabList.BackgroundTransparency = 1
    TabList.BorderSizePixel = 0
    TabList.ZIndex = 3
    TabList.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.Parent = TabList

    local TabListPad = Instance.new("UIPadding")
    TabListPad.PaddingTop = UDim.new(0, 10)
    TabListPad.PaddingLeft = UDim.new(0, 8)
    TabListPad.PaddingRight = UDim.new(0, 8)
    TabListPad.Parent = TabList

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -150, 1, -40)
    ContentArea.Position = UDim2.new(0, 150, 0, 40)
    ContentArea.BackgroundTransparency = 1
    ContentArea.BorderSizePixel = 0
    ContentArea.ZIndex = 3
    ContentArea.Parent = Main

    local Dragging, DragStart, StartPos = false, nil, nil
    TopBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = inp.Position
            StartPos = Main.Position
        end
    end)
    RunService.RenderStepped:Connect(function()
        if Dragging then
            local pos = UserInputService:GetMouseLocation()
            if DragStart then
                local delta = Vector2.new(pos.X - DragStart.X, pos.Y - DragStart.Y)
                Main.Position = UDim2.new(
                    StartPos.X.Scale,
                    StartPos.X.Offset + delta.X,
                    StartPos.Y.Scale,
                    StartPos.Y.Offset + delta.Y
                )
                MainShadow.Position = UDim2.new(
                    StartPos.X.Scale,
                    StartPos.X.Offset + delta.X + 4,
                    StartPos.Y.Scale,
                    StartPos.Y.Offset + delta.Y + 6
                )
            end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)

    local WindowAPI = { _tabs = {}, _btns = {} }

    function WindowAPI:CreateTab(tabName, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, 0, 0, 34)
        TabBtn.BackgroundColor3 = Theme.SurfaceHigh
        TabBtn.BackgroundTransparency = 1
        TabBtn.BorderSizePixel = 0
        TabBtn.Text = ""
        TabBtn.AutoButtonColor = false
        TabBtn.ZIndex = 4
        TabBtn.Parent = TabList
        MakeCorner(TabBtn, 6)

        local TabBtnStroke = MakeStroke(TabBtn, Theme.Border, 1)
        TabBtnStroke.Transparency = 1

        local TabIndicator = Instance.new("Frame")
        TabIndicator.Size = UDim2.new(0, 3, 0.5, 0)
        TabIndicator.Position = UDim2.new(0, 0, 0.25, 0)
        TabIndicator.BackgroundColor3 = Theme.Accent
        TabIndicator.BackgroundTransparency = 1
        TabIndicator.BorderSizePixel = 0
        TabIndicator.ZIndex = 5
        TabIndicator.Parent = TabBtn
        MakeCorner(TabIndicator, 2)

        local TabText = Instance.new("TextLabel")
        TabText.Size = UDim2.new(1, -18, 1, 0)
        TabText.Position = UDim2.new(0, 14, 0, 0)
        TabText.BackgroundTransparency = 1
        TabText.Text = (icon and icon .. "  " or "") .. tabName
        TabText.TextColor3 = Theme.TextMuted
        TabText.TextSize = 12
        TabText.Font = Font
        TabText.TextXAlignment = Enum.TextXAlignment.Left
        TabText.ZIndex = 5
        TabText.Parent = TabBtn

        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.ScrollBarThickness = 3
        Page.ScrollBarImageColor3 = Theme.AccentDim
        Page.ScrollBarImageTransparency = 0.4
        Page.Visible = false
        Page.ZIndex = 3
        Page.Parent = ContentArea

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingLeft = UDim.new(0, 14)
        PagePad.PaddingRight = UDim.new(0, 14)
        PagePad.PaddingTop = UDim.new(0, 14)
        PagePad.PaddingBottom = UDim.new(0, 14)
        PagePad.Parent = Page

        local LeftCol = Instance.new("Frame")
        LeftCol.Size = UDim2.new(0.5, -7, 1, 0)
        LeftCol.BackgroundTransparency = 1
        LeftCol.BorderSizePixel = 0
        LeftCol.ZIndex = 3
        LeftCol.Parent = Page

        local RightCol = Instance.new("Frame")
        RightCol.Size = UDim2.new(0.5, -7, 1, 0)
        RightCol.Position = UDim2.new(0.5, 7, 0, 0)
        RightCol.BackgroundTransparency = 1
        RightCol.BorderSizePixel = 0
        RightCol.ZIndex = 3
        RightCol.Parent = Page

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Parent = LeftCol

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Parent = RightCol

        table.insert(WindowAPI._tabs, Page)
        table.insert(WindowAPI._btns, { btn = TabBtn, ind = TabIndicator, txt = TabText, stroke = TabBtnStroke })

        local function SyncCanvas()
            local h = math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
            Page.CanvasSize = UDim2.new(0, 0, 0, h + 28)
        end
        LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SyncCanvas)
        RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(SyncCanvas)

        local function ActivateTab()
            for _, p in pairs(WindowAPI._tabs) do
                p.Visible = false
            end
            for _, b in pairs(WindowAPI._btns) do
                Tween(b.btn, { BackgroundTransparency = 1 })
                Tween(b.stroke, { Transparency = 1 })
                Tween(b.txt, { TextColor3 = Theme.TextMuted })
                Tween(b.ind, { BackgroundTransparency = 1 })
            end
            Page.Visible = true
            Tween(TabBtn, { BackgroundTransparency = 0 })
            Tween(TabBtnStroke, { Transparency = 0 })
            Tween(TabText, { TextColor3 = Theme.TextPrimary })
            Tween(TabIndicator, { BackgroundTransparency = 0 })
        end

        if #WindowAPI._tabs == 1 then ActivateTab() end
        TabBtn.MouseButton1Click:Connect(ActivateTab)

        TabBtn.MouseEnter:Connect(function()
            if Page.Visible then return end
            Tween(TabBtn, { BackgroundTransparency = 0.6 })
        end)
        TabBtn.MouseLeave:Connect(function()
            if Page.Visible then return end
            Tween(TabBtn, { BackgroundTransparency = 1 })
        end)

        local TabAPI = {}

        function TabAPI:CreateSection(side, sectionTitle)
            local ParentCol = (side == "Right") and RightCol or LeftCol

            local SectWrap = Instance.new("Frame")
            SectWrap.Size = UDim2.new(1, 0, 0, 20)
            SectWrap.BackgroundTransparency = 1
            SectWrap.BorderSizePixel = 0
            SectWrap.ZIndex = 3
            SectWrap.Parent = ParentCol

            local SectBg = Instance.new("Frame")
            SectBg.Size = UDim2.new(1, 0, 1, 0)
            SectBg.BackgroundColor3 = Theme.Surface
            SectBg.BorderSizePixel = 0
            SectBg.ZIndex = 3
            SectBg.Parent = SectWrap
            MakeCorner(SectBg, 8)
            MakeStroke(SectBg, Theme.Border, 1)

            local SectHeader = Instance.new("Frame")
            SectHeader.Size = UDim2.new(1, 0, 0, 28)
            SectHeader.BackgroundTransparency = 1
            SectHeader.BorderSizePixel = 0
            SectHeader.ZIndex = 4
            SectHeader.Parent = SectBg

            local SectDot = Instance.new("Frame")
            SectDot.Size = UDim2.new(0, 4, 0, 4)
            SectDot.Position = UDim2.new(0, 10, 0.5, -2)
            SectDot.BackgroundColor3 = Theme.Accent
            SectDot.BorderSizePixel = 0
            SectDot.ZIndex = 5
            SectDot.Parent = SectHeader
            MakeCorner(SectDot, 2)

            local SectTitle = Instance.new("TextLabel")
            SectTitle.Size = UDim2.new(1, -24, 1, 0)
            SectTitle.Position = UDim2.new(0, 22, 0, 0)
            SectTitle.BackgroundTransparency = 1
            SectTitle.Text = sectionTitle or "Section"
            SectTitle.TextColor3 = Theme.TextSecondary
            SectTitle.TextSize = 11
            SectTitle.Font = FontBold
            SectTitle.TextXAlignment = Enum.TextXAlignment.Left
            SectTitle.ZIndex = 5
            SectTitle.Parent = SectHeader

            local SectDivider = Instance.new("Frame")
            SectDivider.Size = UDim2.new(1, -20, 0, 1)
            SectDivider.Position = UDim2.new(0, 10, 0, 27)
            SectDivider.BackgroundColor3 = Theme.Border
            SectDivider.BorderSizePixel = 0
            SectDivider.ZIndex = 4
            SectDivider.Parent = SectBg

            local SectContent = Instance.new("Frame")
            SectContent.Size = UDim2.new(1, 0, 1, -30)
            SectContent.Position = UDim2.new(0, 0, 0, 30)
            SectContent.BackgroundTransparency = 1
            SectContent.BorderSizePixel = 0
            SectContent.ZIndex = 4
            SectContent.Parent = SectBg

            local SectLayout = Instance.new("UIListLayout")
            SectLayout.Padding = UDim.new(0, 6)
            SectLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            SectLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectLayout.Parent = SectContent

            local SectPad = Instance.new("UIPadding")
            SectPad.PaddingTop = UDim.new(0, 6)
            SectPad.PaddingBottom = UDim.new(0, 10)
            SectPad.Parent = SectContent

            SectLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                local newH = SectLayout.AbsoluteContentSize.Y + 40
                SectBg.Size = UDim2.new(1, 0, 0, newH)
                SectWrap.Size = UDim2.new(1, 0, 0, newH)
            end)

            local function BuildElements(container)
                local E = {}

                function E:Toggle(name, flag, default, tooltip, callback)
                    NixwareUI.Flags[flag] = (default == true)

                    local Row = Instance.new("TextButton")
                    Row.Size = UDim2.new(1, -16, 0, 22)
                    Row.BackgroundColor3 = Theme.SurfaceHigh
                    Row.BackgroundTransparency = 1
                    Row.BorderSizePixel = 0
                    Row.Text = ""
                    Row.AutoButtonColor = false
                    Row.ZIndex = 5
                    Row.Parent = container
                    MakeCorner(Row, 4)

                    local Box = Instance.new("Frame")
                    Box.Size = UDim2.new(0, 14, 0, 14)
                    Box.Position = UDim2.new(0, 2, 0.5, -7)
                    Box.BackgroundColor3 = NixwareUI.Flags[flag] and Theme.Accent or Theme.Background
                    Box.BorderSizePixel = 0
                    Box.ZIndex = 6
                    Box.Parent = Row
                    MakeCorner(Box, 3)
                    MakeStroke(Box, NixwareUI.Flags[flag] and Theme.Accent or Theme.Border, 1)

                    local Check = Instance.new("TextLabel")
                    Check.Size = UDim2.new(1, 0, 1, 0)
                    Check.BackgroundTransparency = 1
                    Check.Text = "✓"
                    Check.TextColor3 = Color3.new(1, 1, 1)
                    Check.TextSize = 10
                    Check.Font = FontBold
                    Check.TextTransparency = NixwareUI.Flags[flag] and 0 or 1
                    Check.ZIndex = 7
                    Check.Parent = Box

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -22, 1, 0)
                    Label.Position = UDim2.new(0, 22, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Text = name
                    Label.TextColor3 = NixwareUI.Flags[flag] and Theme.TextPrimary or Theme.TextSecondary
                    Label.TextSize = 12
                    Label.Font = Font
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.ZIndex = 6
                    Label.Parent = Row

                    Row.MouseEnter:Connect(function()
                        ShowTooltip(tooltip)
                        Tween(Row, { BackgroundTransparency = 0 })
                    end)
                    Row.MouseLeave:Connect(function()
                        HideTooltip()
                        Tween(Row, { BackgroundTransparency = 1 })
                    end)
                    Row.MouseButton1Click:Connect(function()
                        NixwareUI.Flags[flag] = not NixwareUI.Flags[flag]
                        local s = NixwareUI.Flags[flag]
                        local boxStroke = Box:FindFirstChildOfClass("UIStroke")
                        Tween(Box, { BackgroundColor3 = s and Theme.Accent or Theme.Background })
                        if boxStroke then Tween(boxStroke, { Color = s and Theme.Accent or Theme.Border }) end
                        Tween(Check, { TextTransparency = s and 0 or 1 })
                        Tween(Label, { TextColor3 = s and Theme.TextPrimary or Theme.TextSecondary })
                        if callback then callback(s) end
                    end)
                end

                function E:Slider(name, flag, min, max, default, suffix, tooltip, callback)
                    NixwareUI.Flags[flag] = default or min

                    local Wrap = Instance.new("Frame")
                    Wrap.Size = UDim2.new(1, -16, 0, 38)
                    Wrap.BackgroundTransparency = 1
                    Wrap.BorderSizePixel = 0
                    Wrap.ZIndex = 5
                    Wrap.Parent = container

                    local TopRow = Instance.new("Frame")
                    TopRow.Size = UDim2.new(1, 0, 0, 16)
                    TopRow.BackgroundTransparency = 1
                    TopRow.BorderSizePixel = 0
                    TopRow.ZIndex = 5
                    TopRow.Parent = Wrap

                    local NameLabel = Instance.new("TextLabel")
                    NameLabel.Size = UDim2.new(0.7, 0, 1, 0)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Text = name
                    NameLabel.TextColor3 = Theme.TextSecondary
                    NameLabel.TextSize = 12
                    NameLabel.Font = Font
                    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    NameLabel.ZIndex = 6
                    NameLabel.Parent = TopRow

                    local ValLabel = Instance.new("TextLabel")
                    ValLabel.Size = UDim2.new(0.3, 0, 1, 0)
                    ValLabel.Position = UDim2.new(0.7, 0, 0, 0)
                    ValLabel.BackgroundTransparency = 1
                    ValLabel.Text = tostring(NixwareUI.Flags[flag]) .. (suffix or "")
                    ValLabel.TextColor3 = Theme.Accent
                    ValLabel.TextSize = 11
                    ValLabel.Font = FontBold
                    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValLabel.ZIndex = 6
                    ValLabel.Parent = TopRow

                    local Track = Instance.new("Frame")
                    Track.Size = UDim2.new(1, 0, 0, 6)
                    Track.Position = UDim2.new(0, 0, 0, 22)
                    Track.BackgroundColor3 = Theme.Background
                    Track.BorderSizePixel = 0
                    Track.ZIndex = 5
                    Track.Parent = Wrap
                    MakeCorner(Track, 3)
                    MakeStroke(Track, Theme.Border, 1)

                    local Fill = Instance.new("Frame")
                    local initPct = (NixwareUI.Flags[flag] - min) / (max - min)
                    Fill.Size = UDim2.new(initPct, 0, 1, 0)
                    Fill.BackgroundColor3 = Theme.Accent
                    Fill.BorderSizePixel = 0
                    Fill.ZIndex = 6
                    Fill.Parent = Track
                    MakeCorner(Fill, 3)

                    local FillGrad = Instance.new("UIGradient")
                    FillGrad.Color = Theme.AccentSequence
                    FillGrad.Parent = Fill

                    local Knob = Instance.new("Frame")
                    Knob.Size = UDim2.new(0, 10, 0, 10)
                    Knob.Position = UDim2.new(initPct, -5, 0.5, -5)
                    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
                    Knob.BorderSizePixel = 0
                    Knob.ZIndex = 7
                    Knob.Parent = Track
                    MakeCorner(Knob, 5)

                    Track.MouseEnter:Connect(function() ShowTooltip(tooltip) end)
                    Track.MouseLeave:Connect(function() HideTooltip() end)

                    local sliding = false
                    Track.InputBegan:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
                    end)
                    UserInputService.InputEnded:Connect(function(inp)
                        if inp.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
                    end)
                    RunService.RenderStepped:Connect(function()
                        if sliding then
                            local mx = UserInputService:GetMouseLocation().X
                            local pct = math.clamp((mx - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                            local val = math.floor(min + (max - min) * pct)
                            NixwareUI.Flags[flag] = val
                            Fill.Size = UDim2.new(pct, 0, 1, 0)
                            Knob.Position = UDim2.new(pct, -5, 0.5, -5)
                            ValLabel.Text = tostring(val) .. (suffix or "")
                            if callback then callback(val) end
                        end
                    end)
                end

                function E:Dropdown(name, flag, options, default, tooltip, callback)
                    NixwareUI.Flags[flag] = default or options[1]
                    local open = false

                    local Wrap = Instance.new("Frame")
                    Wrap.Size = UDim2.new(1, -16, 0, 48)
                    Wrap.BackgroundTransparency = 1
                    Wrap.BorderSizePixel = 0
                    Wrap.ClipsDescendants = true
                    Wrap.ZIndex = 5
                    Wrap.Parent = container

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, 0, 0, 14)
                    Label.BackgroundTransparency = 1
                    Label.Text = name
                    Label.TextColor3 = Theme.TextSecondary
                    Label.TextSize = 11
                    Label.Font = Font
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.ZIndex = 6
                    Label.Parent = Wrap

                    local MainBtn = Instance.new("TextButton")
                    MainBtn.Size = UDim2.new(1, 0, 0, 26)
                    MainBtn.Position = UDim2.new(0, 0, 0, 16)
                    MainBtn.BackgroundColor3 = Theme.SurfaceHigh
                    MainBtn.BorderSizePixel = 0
                    MainBtn.Text = ""
                    MainBtn.ZIndex = 6
                    MainBtn.Parent = Wrap
                    MakeCorner(MainBtn, 5)
                    local MainStroke = MakeStroke(MainBtn, Theme.Border, 1)

                    local MainText = Instance.new("TextLabel")
                    MainText.Size = UDim2.new(1, -32, 1, 0)
                    MainText.Position = UDim2.new(0, 10, 0, 0)
                    MainText.BackgroundTransparency = 1
                    MainText.Text = NixwareUI.Flags[flag]
                    MainText.TextColor3 = Theme.TextPrimary
                    MainText.TextSize = 12
                    MainText.Font = Font
                    MainText.TextXAlignment = Enum.TextXAlignment.Left
                    MainText.ZIndex = 7
                    MainText.Parent = MainBtn

                    local Arrow = Instance.new("TextLabel")
                    Arrow.Size = UDim2.new(0, 20, 1, 0)
                    Arrow.Position = UDim2.new(1, -22, 0, 0)
                    Arrow.BackgroundTransparency = 1
                    Arrow.Text = "▾"
                    Arrow.TextColor3 = Theme.TextMuted
                    Arrow.TextSize = 12
                    Arrow.Font = Font
                    Arrow.ZIndex = 7
                    Arrow.Parent = MainBtn

                    local ListBg = Instance.new("Frame")
                    ListBg.Size = UDim2.new(1, 0, 0, 0)
                    ListBg.Position = UDim2.new(0, 0, 0, 44)
                    ListBg.BackgroundColor3 = Theme.SurfaceHigh
                    ListBg.BorderSizePixel = 0
                    ListBg.ZIndex = 6
                    ListBg.Parent = Wrap
                    MakeCorner(ListBg, 5)
                    MakeStroke(ListBg, Theme.Border, 1)

                    local ListLayout = Instance.new("UIListLayout")
                    ListLayout.Parent = ListBg

                    for _, opt in ipairs(options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, 0, 0, 24)
                        OptBtn.BackgroundTransparency = 1
                        OptBtn.BorderSizePixel = 0
                        OptBtn.Text = ""
                        OptBtn.ZIndex = 7
                        OptBtn.Parent = ListBg

                        local OptText = Instance.new("TextLabel")
                        OptText.Size = UDim2.new(1, -14, 1, 0)
                        OptText.Position = UDim2.new(0, 10, 0, 0)
                        OptText.BackgroundTransparency = 1
                        OptText.Text = opt
                        OptText.TextColor3 = Theme.TextSecondary
                        OptText.TextSize = 12
                        OptText.Font = Font
                        OptText.TextXAlignment = Enum.TextXAlignment.Left
                        OptText.ZIndex = 8
                        OptText.Parent = OptBtn

                        OptBtn.MouseEnter:Connect(function() Tween(OptText, { TextColor3 = Theme.Accent }) end)
                        OptBtn.MouseLeave:Connect(function() Tween(OptText, { TextColor3 = Theme.TextSecondary }) end)
                        OptBtn.MouseButton1Click:Connect(function()
                            NixwareUI.Flags[flag] = opt
                            MainText.Text = opt
                            open = false
                            Tween(Wrap, { Size = UDim2.new(1, -16, 0, 48) })
                            Tween(ListBg, { Size = UDim2.new(1, 0, 0, 0) })
                            Tween(MainStroke, { Color = Theme.Border })
                            Tween(Arrow, { TextColor3 = Theme.TextMuted })
                            if callback then callback(opt) end
                        end)
                    end

                    MainBtn.MouseEnter:Connect(function() ShowTooltip(tooltip) end)
                    MainBtn.MouseLeave:Connect(function() HideTooltip() end)
                    MainBtn.MouseButton1Click:Connect(function()
                        open = not open
                        local targetH = open and (44 + #options * 24 + 2) or 48
                        local listH = open and (#options * 24) or 0
                        Tween(Wrap, { Size = UDim2.new(1, -16, 0, targetH) })
                        Tween(ListBg, { Size = UDim2.new(1, 0, 0, listH) })
                        Tween(MainStroke, { Color = open and Theme.Accent or Theme.Border })
                        Tween(Arrow, { TextColor3 = open and Theme.Accent or Theme.TextMuted })
                    end)
                end

                function E:Button(name, tooltip, callback)
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1, -16, 0, 28)
                    Btn.BackgroundColor3 = Theme.SurfaceHigh
                    Btn.BorderSizePixel = 0
                    Btn.Text = name
                    Btn.TextColor3 = Theme.TextSecondary
                    Btn.TextSize = 12
                    Btn.Font = Font
                    Btn.AutoButtonColor = false
                    Btn.ZIndex = 5
                    Btn.Parent = container
                    MakeCorner(Btn, 5)
                    local BtnStroke = MakeStroke(Btn, Theme.Border, 1)

                    Btn.MouseEnter:Connect(function()
                        ShowTooltip(tooltip)
                        Tween(Btn, { BackgroundColor3 = Theme.SurfaceHover })
                        Tween(Btn, { TextColor3 = Theme.TextPrimary })
                    end)
                    Btn.MouseLeave:Connect(function()
                        HideTooltip()
                        Tween(Btn, { BackgroundColor3 = Theme.SurfaceHigh })
                        Tween(Btn, { TextColor3 = Theme.TextSecondary })
                    end)
                    Btn.MouseButton1Down:Connect(function()
                        Tween(BtnStroke, { Color = Theme.Accent })
                        Tween(Btn, { TextColor3 = Theme.Accent })
                    end)
                    Btn.MouseButton1Up:Connect(function()
                        Tween(BtnStroke, { Color = Theme.Border })
                        Tween(Btn, { TextColor3 = Theme.TextPrimary })
                        if callback then callback() end
                    end)
                end

                function E:ColorPicker(name, flag, default, tooltip, callback)
                    NixwareUI.Flags[flag] = default or Color3.new(1, 1, 1)
                    local open = false

                    local Wrap = Instance.new("Frame")
                    Wrap.Size = UDim2.new(1, -16, 0, 26)
                    Wrap.BackgroundTransparency = 1
                    Wrap.BorderSizePixel = 0
                    Wrap.ClipsDescendants = true
                    Wrap.ZIndex = 5
                    Wrap.Parent = container

                    local Header = Instance.new("TextButton")
                    Header.Size = UDim2.new(1, 0, 0, 26)
                    Header.BackgroundTransparency = 1
                    Header.BorderSizePixel = 0
                    Header.Text = ""
                    Header.ZIndex = 6
                    Header.Parent = Wrap

                    local NameLabel = Instance.new("TextLabel")
                    NameLabel.Size = UDim2.new(1, -36, 1, 0)
                    NameLabel.BackgroundTransparency = 1
                    NameLabel.Text = name
                    NameLabel.TextColor3 = Theme.TextSecondary
                    NameLabel.TextSize = 12
                    NameLabel.Font = Font
                    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
                    NameLabel.ZIndex = 7
                    NameLabel.Parent = Header

                    local Preview = Instance.new("Frame")
                    Preview.Size = UDim2.new(0, 24, 0, 12)
                    Preview.Position = UDim2.new(1, -26, 0.5, -6)
                    Preview.BackgroundColor3 = NixwareUI.Flags[flag]
                    Preview.BorderSizePixel = 0
                    Preview.ZIndex = 7
                    Preview.Parent = Header
                    MakeCorner(Preview, 3)
                    MakeStroke(Preview, Theme.Border, 1)

                    local Expand = Instance.new("Frame")
                    Expand.Size = UDim2.new(1, 0, 0, 72)
                    Expand.Position = UDim2.new(0, 0, 0, 28)
                    Expand.BackgroundColor3 = Theme.SurfaceHigh
                    Expand.BorderSizePixel = 0
                    Expand.ZIndex = 6
                    Expand.Parent = Wrap
                    MakeCorner(Expand, 5)
                    MakeStroke(Expand, Theme.Border, 1)

                    Header.MouseEnter:Connect(function() ShowTooltip(tooltip) end)
                    Header.MouseLeave:Connect(function() HideTooltip() end)
                    Header.MouseButton1Click:Connect(function()
                        open = not open
                        Tween(Wrap, { Size = UDim2.new(1, -16, 0, open and 104 or 26) })
                    end)

                    local r = NixwareUI.Flags[flag].R
                    local g = NixwareUI.Flags[flag].G
                    local b = NixwareUI.Flags[flag].B

                    local function SyncColor()
                        local col = Color3.new(r, g, b)
                        NixwareUI.Flags[flag] = col
                        Preview.BackgroundColor3 = col
                        if callback then callback(col) end
                    end

                    local function MakeRgbTrack(yOffset, val, onChange)
                        local TrackBg = Instance.new("Frame")
                        TrackBg.Size = UDim2.new(1, -16, 0, 8)
                        TrackBg.Position = UDim2.new(0, 8, 0, yOffset)
                        TrackBg.BackgroundColor3 = Theme.Background
                        TrackBg.BorderSizePixel = 0
                        TrackBg.ZIndex = 7
                        TrackBg.Parent = Expand
                        MakeCorner(TrackBg, 4)
                        MakeStroke(TrackBg, Theme.Border, 1)

                        local TrackFill = Instance.new("Frame")
                        TrackFill.Size = UDim2.new(val, 0, 1, 0)
                        TrackFill.BackgroundColor3 = Theme.Accent
                        TrackFill.BorderSizePixel = 0
                        TrackFill.ZIndex = 8
                        TrackFill.Parent = TrackBg
                        MakeCorner(TrackFill, 4)

                        local sld = false
                        TrackBg.InputBegan:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sld = true end
                        end)
                        UserInputService.InputEnded:Connect(function(inp)
                            if inp.UserInputType == Enum.UserInputType.MouseButton1 then sld = false end
                        end)
                        RunService.RenderStepped:Connect(function()
                            if sld then
                                local pct = math.clamp((UserInputService:GetMouseLocation().X - TrackBg.AbsolutePosition.X) / TrackBg.AbsoluteSize.X, 0, 1)
                                TrackFill.Size = UDim2.new(pct, 0, 1, 0)
                                onChange(pct)
                            end
                        end)
                    end

                    MakeRgbTrack(8, r, function(v) r = v; SyncColor() end)
                    MakeRgbTrack(28, g, function(v) g = v; SyncColor() end)
                    MakeRgbTrack(48, b, function(v) b = v; SyncColor() end)

                    local RLabel = Instance.new("TextLabel")
                    RLabel.Size = UDim2.new(0, 8, 0, 8)
                    RLabel.Position = UDim2.new(0, 0, 0, 8)
                    RLabel.BackgroundTransparency = 1
                    RLabel.Text = "R"
                    RLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
                    RLabel.TextSize = 9
                    RLabel.Font = FontBold
                    RLabel.ZIndex = 9
                    RLabel.Parent = Expand

                    local GLabel = RLabel:Clone()
                    GLabel.Position = UDim2.new(0, 0, 0, 28)
                    GLabel.Text = "G"
                    GLabel.TextColor3 = Color3.fromRGB(100, 210, 100)
                    GLabel.Parent = Expand

                    local BLabel = RLabel:Clone()
                    BLabel.Position = UDim2.new(0, 0, 0, 48)
                    BLabel.Text = "B"
                    BLabel.TextColor3 = Color3.fromRGB(100, 140, 255)
                    BLabel.Parent = Expand
                end

                function E:Label(text, color)
                    local L = Instance.new("TextLabel")
                    L.Size = UDim2.new(1, -16, 0, 16)
                    L.BackgroundTransparency = 1
                    L.BorderSizePixel = 0
                    L.Text = text
                    L.TextColor3 = color or Theme.TextMuted
                    L.TextSize = 11
                    L.Font = FontLight
                    L.TextXAlignment = Enum.TextXAlignment.Left
                    L.ZIndex = 5
                    L.Parent = container
                end

                function E:Separator()
                    local Sep = Instance.new("Frame")
                    Sep.Size = UDim2.new(1, -16, 0, 1)
                    Sep.BackgroundColor3 = Theme.Border
                    Sep.BorderSizePixel = 0
                    Sep.ZIndex = 5
                    Sep.Parent = container
                end

                return E
            end

            return BuildElements(SectContent)
        end

        return TabAPI
    end

    return WindowAPI
end

return NixwareUI
