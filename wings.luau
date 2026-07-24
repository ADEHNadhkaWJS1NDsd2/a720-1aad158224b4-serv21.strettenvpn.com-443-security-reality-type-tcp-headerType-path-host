local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local PreviousController = _G.NightfallWingsController

if PreviousController
    and type(PreviousController.Stop) == "function"
then
    pcall(function()
        PreviousController:Stop()
    end)
end

local DefaultColor =
    Color3.fromRGB(
        120,
        60,
        220
    )

local DefaultOutlineColor =
    Color3.fromRGB(
        120,
        60,
        220
    )

local WingColor =
    DefaultColor

local OutlineColor =
    DefaultOutlineColor

local WingScale =
    1.12

local HeightOffset =
    0

local FlapSpeed =
    1.45

local BackOffset =
    0.72

local RenderFps =
    180

local RenderInterval =
    1 / RenderFps

local LastRenderTime =
    os.clock()

local AnimationTime =
    0

local Drawings = {}

local Controller = {
    Running = true,
    Enabled = true,
    Color = WingColor,
    OutlineColor = OutlineColor,
    Scale = WingScale,
    Height = HeightOffset,
    SwingSpeed = FlapSpeed
}

_G.NightfallWingsController =
    Controller

local function Clamp(
    Value,
    Minimum,
    Maximum
)
    if Value < Minimum then
        return Minimum
    end

    if Value > Maximum then
        return Maximum
    end

    return Value
end

local function LerpNumber(
    StartValue,
    EndValue,
    Alpha
)
    return StartValue
        + (
            EndValue
            - StartValue
        )
        * Alpha
end

local function LerpVector(
    StartValue,
    EndValue,
    Alpha
)
    return StartValue:Lerp(
        EndValue,
        Alpha
    )
end

local function RegisterDrawing(
    DrawingObject,
    DrawingRole
)
    Drawings[
        #Drawings + 1
    ] = {
        Object = DrawingObject,
        Role = DrawingRole
    }

    return DrawingObject
end

local function ApplyDrawingColor(
    DrawingObject,
    DrawingRole
)
    if DrawingRole == "Outline"
        or DrawingRole == "Glow"
    then
        DrawingObject.Color =
            OutlineColor
    else
        DrawingObject.Color =
            WingColor
    end
end

local function ApplyColors()
    for Index = 1,
        #Drawings
    do
        local DrawingData =
            Drawings[Index]

        if DrawingData
            and DrawingData.Object
        then
            ApplyDrawingColor(
                DrawingData.Object,
                DrawingData.Role
            )
        end
    end
end

local function CreateTriangle(
    Transparency,
    ZIndex
)
    local Triangle =
        Drawing.new(
            "Triangle"
        )

    Triangle.Color =
        WingColor

    Triangle.Transparency =
        Transparency

    Triangle.ZIndex =
        ZIndex

    Triangle.Visible =
        false

    return RegisterDrawing(
        Triangle,
        "Fill"
    )
end

local function CreateLine(
    DrawingRole,
    Thickness,
    Transparency,
    ZIndex
)
    local Line =
        Drawing.new(
            "Line"
        )

    ApplyDrawingColor(
        Line,
        DrawingRole
    )

    Line.Thickness =
        Thickness

    Line.Transparency =
        Transparency

    Line.ZIndex =
        ZIndex

    Line.Visible =
        false

    return RegisterDrawing(
        Line,
        DrawingRole
    )
end

local function CreateFeather(
    ZIndex,
    HasShaft
)
    return {
        Left = CreateTriangle(
            0.94,
            ZIndex
        ),
        Right = CreateTriangle(
            0.94,
            ZIndex
        ),
        Shaft = HasShaft
            and CreateLine(
                "Fill",
                1,
                0.72,
                ZIndex + 1
            )
            or nil
    }
end

local function CreateStroke(
    ZIndex
)
    return {
        Glow = CreateLine(
            "Glow",
            6,
            0.12,
            ZIndex
        ),
        Main = CreateLine(
            "Outline",
            2,
            0.96,
            ZIndex + 1
        )
    }
end

local function CreateWing()
    local Wing = {
        Primary = {},
        Secondary = {},
        Coverts = {},
        Upper = {},
        Inner = {},
        Outline = {}
    }

    for Index = 1,
        8
    do
        Wing.Primary[Index] =
            CreateFeather(
                3,
                true
            )
    end

    for Index = 1,
        7
    do
        Wing.Secondary[Index] =
            CreateFeather(
                5,
                true
            )
    end

    for Index = 1,
        6
    do
        Wing.Coverts[Index] =
            CreateFeather(
                7,
                false
            )
    end

    for Index = 1,
        5
    do
        Wing.Upper[Index] =
            CreateFeather(
                9,
                false
            )
    end

    for Index = 1,
        4
    do
        Wing.Inner[Index] =
            CreateFeather(
                11,
                false
            )
    end

    for Index = 1,
        6
    do
        Wing.Outline[Index] =
            CreateStroke(
                13
            )
    end

    return Wing
end

local LeftWing =
    CreateWing()

local RightWing =
    CreateWing()

local function HideDrawing(
    DrawingObject
)
    if DrawingObject then
        DrawingObject.Visible =
            false
    end
end

local function HideFeather(
    Feather
)
    HideDrawing(
        Feather.Left
    )

    HideDrawing(
        Feather.Right
    )

    HideDrawing(
        Feather.Shaft
    )
end

local function HideStroke(
    Stroke
)
    HideDrawing(
        Stroke.Main
    )

    HideDrawing(
        Stroke.Glow
    )
end

local function HideAll()
    for Index = 1,
        #Drawings
    do
        local DrawingData =
            Drawings[Index]

        if DrawingData
            and DrawingData.Object
        then
            DrawingData.Object.Visible =
                false
        end
    end
end

local function ProjectPoint(
    WorldPoint
)
    Camera =
        Workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local ScreenPoint,
        OnScreen =
        Camera:
        WorldToViewportPoint(
            WorldPoint
        )

    if not OnScreen
        or ScreenPoint.Z <= 0
    then
        return nil
    end

    return Vector2.new(
        ScreenPoint.X,
        ScreenPoint.Y
    )
end

local function DrawLineBetween(
    Line,
    WorldStart,
    WorldEnd
)
    local ScreenStart =
        ProjectPoint(
            WorldStart
        )

    local ScreenEnd =
        ProjectPoint(
            WorldEnd
        )

    if not ScreenStart
        or not ScreenEnd
    then
        Line.Visible =
            false

        return false
    end

    Line.From =
        ScreenStart

    Line.To =
        ScreenEnd

    Line.Visible =
        true

    return true
end

local function DrawStroke(
    Stroke,
    WorldStart,
    WorldEnd
)
    local MainVisible =
        DrawLineBetween(
            Stroke.Main,
            WorldStart,
            WorldEnd
        )

    if MainVisible then
        DrawLineBetween(
            Stroke.Glow,
            WorldStart,
            WorldEnd
        )
    else
        Stroke.Glow.Visible =
            false
    end
end

local function DrawFeather(
    Feather,
    RootPosition,
    TipPosition,
    Width,
    PlaneNormal,
    Bend,
    Curve
)
    local Direction =
        TipPosition
        - RootPosition

    if Direction.Magnitude
        <= 0.001
    then
        HideFeather(
            Feather
        )

        return
    end

    local WidthDirection =
        PlaneNormal:
        Cross(
            Direction
        )

    if WidthDirection.Magnitude
        <= 0.001
    then
        HideFeather(
            Feather
        )

        return
    end

    WidthDirection =
        WidthDirection.Unit

    local WidePosition =
        RootPosition
        + Direction * 0.53
        + PlaneNormal * Bend
        + WidthDirection * Curve

    local LeftPosition =
        WidePosition
        + WidthDirection * Width

    local RightPosition =
        WidePosition
        - WidthDirection * Width

    local ScreenRoot =
        ProjectPoint(
            RootPosition
        )

    local ScreenLeft =
        ProjectPoint(
            LeftPosition
        )

    local ScreenRight =
        ProjectPoint(
            RightPosition
        )

    local ScreenTip =
        ProjectPoint(
            TipPosition
        )

    if not ScreenRoot
        or not ScreenLeft
        or not ScreenRight
        or not ScreenTip
    then
        HideFeather(
            Feather
        )

        return
    end

    Feather.Left.PointA =
        ScreenRoot

    Feather.Left.PointB =
        ScreenLeft

    Feather.Left.PointC =
        ScreenTip

    Feather.Left.Visible =
        true

    Feather.Right.PointA =
        ScreenRoot

    Feather.Right.PointB =
        ScreenTip

    Feather.Right.PointC =
        ScreenRight

    Feather.Right.Visible =
        true

    if Feather.Shaft then
        Feather.Shaft.From =
            ScreenRoot

        Feather.Shaft.To =
            ScreenTip

        Feather.Shaft.Visible =
            true
    end
end

local function GetWingAnchor()
    local Character =
        LocalPlayer.Character

    if not Character then
        return nil,
            nil
    end

    local UpperTorso =
        Character:
        FindFirstChild(
            "UpperTorso"
        )

    local Torso =
        Character:
        FindFirstChild(
            "Torso"
        )

    local RootPart =
        Character:
        FindFirstChild(
            "HumanoidRootPart"
        )

    local AnchorPart =
        UpperTorso
        or Torso
        or RootPart

    if not AnchorPart
        or not AnchorPart:IsA(
            "BasePart"
        )
    then
        return nil,
            nil
    end

    local IsR6 =
        Torso ~= nil
        and UpperTorso == nil

    return AnchorPart,
        IsR6
end

local function CalculateWingPoints(
    Origin,
    SideVector,
    UpVector,
    BackVector,
    Flap,
    Fold
)
    local Raised =
        math.max(
            Flap,
            0
        )

    local Lowered =
        math.max(
            -Flap,
            0
        )

    local Root =
        Origin
        + SideVector
            * (
                0.46
                * WingScale
            )

    local Shoulder =
        Origin
        + SideVector
            * (
                (
                    1.24
                    - Fold * 0.06
                )
                * WingScale
            )
        + UpVector
            * (
                (
                    0.62
                    + Flap * 0.14
                )
                * WingScale
            )
        + BackVector
            * (
                0.06
                * WingScale
            )

    local Elbow =
        Origin
        + SideVector
            * (
                (
                    2.62
                    - Raised * 0.25
                    + Lowered * 0.11
                    - Fold * 0.13
                )
                * WingScale
            )
        + UpVector
            * (
                (
                    2.76
                    + Flap * 0.62
                )
                * WingScale
            )
        + BackVector
            * (
                (
                    0.18
                    + Fold * 0.13
                )
                * WingScale
            )

    local Wrist =
        Origin
        + SideVector
            * (
                (
                    4.36
                    - Raised * 0.59
                    + Lowered * 0.26
                    - Fold * 0.30
                )
                * WingScale
            )
        + UpVector
            * (
                (
                    2.38
                    + Flap * 0.91
                )
                * WingScale
            )
        + BackVector
            * (
                (
                    0.34
                    + Raised * 0.31
                    + Fold * 0.21
                )
                * WingScale
            )

    local Outer =
        Origin
        + SideVector
            * (
                (
                    5.92
                    - Raised * 0.94
                    + Lowered * 0.40
                    - Fold * 0.51
                )
                * WingScale
            )
        + UpVector
            * (
                (
                    1.34
                    + Flap * 1.18
                )
                * WingScale
            )
        + BackVector
            * (
                (
                    0.49
                    + Raised * 0.49
                    + Fold * 0.37
                )
                * WingScale
            )

    local LowerOuter =
        Origin
        + SideVector
            * (
                (
                    5.48
                    - Raised * 0.78
                    + Lowered * 0.34
                    - Fold * 0.42
                )
                * WingScale
            )
        + UpVector
            * (
                (
                    -0.12
                    + Flap * 0.79
                )
                * WingScale
            )
        + BackVector
            * (
                (
                    0.54
                    + Raised * 0.42
                    + Fold * 0.31
                )
                * WingScale
            )

    local LowerInner =
        Origin
        + SideVector
            * (
                (
                    2.14
                    - Fold * 0.10
                )
                * WingScale
            )
        + UpVector
            * (
                (
                    -0.48
                    + Flap * 0.22
                )
                * WingScale
            )
        + BackVector
            * (
                (
                    0.23
                    + Fold * 0.08
                )
                * WingScale
            )

    return {
        Root = Root,
        Shoulder = Shoulder,
        Elbow = Elbow,
        Wrist = Wrist,
        Outer = Outer,
        LowerOuter = LowerOuter,
        LowerInner = LowerInner
    }
end

local function RenderLayer(
    Feathers,
    RootFunction,
    SideVector,
    UpVector,
    BackVector,
    CurrentTime,
    FlapPhase,
    Configuration
)
    local Count =
        #Feathers

    for Index = 1,
        Count
    do
        local Alpha =
            (
                Index
                - 1
            )
            / math.max(
                Count - 1,
                1
            )

        local RootPosition =
            RootFunction(
                Alpha
            )

        local DelayedFlap =
            math.sin(
                FlapPhase
                - Alpha
                    * Configuration.FlapDelay
            )

        local Ripple =
            math.sin(
                CurrentTime
                    * Configuration.RippleSpeed
                - Alpha
                    * Configuration.RippleDelay
                + Index
                    * Configuration.RippleSpacing
            )
            * Configuration.RippleStrength

        local FineRipple =
            math.sin(
                CurrentTime
                    * Configuration.FineSpeed
                + Index * 0.73
            )
            * Configuration.FineStrength

        local Outward =
            LerpNumber(
                Configuration.OutwardStart,
                Configuration.OutwardEnd,
                Alpha
            )

        local Downward =
            LerpNumber(
                Configuration.DownStart,
                Configuration.DownEnd,
                Alpha
            )

        local Depth =
            LerpNumber(
                Configuration.DepthStart,
                Configuration.DepthEnd,
                Alpha
            )

        local Width =
            LerpNumber(
                Configuration.WidthStart,
                Configuration.WidthEnd,
                Alpha
            )

        local TipPosition =
            RootPosition
            + SideVector
                * (
                    (
                        Outward
                        + Ripple
                            * Configuration.OutwardRipple
                        - math.max(
                            DelayedFlap,
                            0
                        )
                            * Alpha
                            * Configuration.FoldInfluence
                    )
                    * WingScale
                )
            - UpVector
                * (
                    (
                        Downward
                        - Ripple
                            * Configuration.UpRipple
                        - DelayedFlap
                            * Alpha
                            * Configuration.FlapInfluence
                    )
                    * WingScale
                )
            + BackVector
                * (
                    (
                        Depth
                        + FineRipple
                        + math.max(
                            DelayedFlap,
                            0
                        )
                            * Alpha
                            * Configuration.DepthInfluence
                    )
                    * WingScale
                )

        DrawFeather(
            Feathers[Index],
            RootPosition,
            TipPosition,
            Width * WingScale,
            BackVector,
            LerpNumber(
                Configuration.BendStart,
                Configuration.BendEnd,
                Alpha
            ) * WingScale,
            Ripple
                * Configuration.CurveInfluence
                * WingScale
        )
    end
end

local PrimaryConfiguration = {
    OutwardStart = 0.78,
    OutwardEnd = 1.48,
    DownStart = 0.54,
    DownEnd = 1.74,
    DepthStart = 0.16,
    DepthEnd = 0.36,
    WidthStart = 0.50,
    WidthEnd = 0.36,
    BendStart = 0.07,
    BendEnd = 0.18,
    RippleSpeed = 1.88,
    RippleDelay = 0.60,
    RippleSpacing = 0.54,
    RippleStrength = 0.034,
    FineSpeed = 1.24,
    FineStrength = 0.015,
    OutwardRipple = 0.34,
    UpRipple = 0.58,
    CurveInfluence = 0.12,
    FlapDelay = 0.57,
    FlapInfluence = 0.46,
    FoldInfluence = 0.38,
    DepthInfluence = 0.31
}

local SecondaryConfiguration = {
    OutwardStart = 0.56,
    OutwardEnd = 1.14,
    DownStart = 0.29,
    DownEnd = 1.04,
    DepthStart = 0.10,
    DepthEnd = 0.25,
    WidthStart = 0.46,
    WidthEnd = 0.35,
    BendStart = 0.05,
    BendEnd = 0.14,
    RippleSpeed = 1.68,
    RippleDelay = 0.49,
    RippleSpacing = 0.58,
    RippleStrength = 0.029,
    FineSpeed = 1.31,
    FineStrength = 0.012,
    OutwardRipple = 0.27,
    UpRipple = 0.46,
    CurveInfluence = 0.10,
    FlapDelay = 0.46,
    FlapInfluence = 0.32,
    FoldInfluence = 0.25,
    DepthInfluence = 0.20
}

local CovertsConfiguration = {
    OutwardStart = 0.35,
    OutwardEnd = 0.77,
    DownStart = 0.15,
    DownEnd = 0.59,
    DepthStart = 0.07,
    DepthEnd = 0.15,
    WidthStart = 0.39,
    WidthEnd = 0.30,
    BendStart = 0.04,
    BendEnd = 0.10,
    RippleSpeed = 1.43,
    RippleDelay = 0.37,
    RippleSpacing = 0.62,
    RippleStrength = 0.019,
    FineSpeed = 1.14,
    FineStrength = 0.008,
    OutwardRipple = 0.20,
    UpRipple = 0.34,
    CurveInfluence = 0.07,
    FlapDelay = 0.35,
    FlapInfluence = 0.18,
    FoldInfluence = 0.13,
    DepthInfluence = 0.10
}

local UpperConfiguration = {
    OutwardStart = 0.26,
    OutwardEnd = 0.57,
    DownStart = 0.07,
    DownEnd = 0.29,
    DepthStart = 0.05,
    DepthEnd = 0.10,
    WidthStart = 0.34,
    WidthEnd = 0.27,
    BendStart = 0.03,
    BendEnd = 0.07,
    RippleSpeed = 1.24,
    RippleDelay = 0.27,
    RippleSpacing = 0.67,
    RippleStrength = 0.013,
    FineSpeed = 1.06,
    FineStrength = 0.006,
    OutwardRipple = 0.14,
    UpRipple = 0.23,
    CurveInfluence = 0.05,
    FlapDelay = 0.25,
    FlapInfluence = 0.09,
    FoldInfluence = 0.06,
    DepthInfluence = 0.05
}

local InnerConfiguration = {
    OutwardStart = 0.21,
    OutwardEnd = 0.41,
    DownStart = 0.10,
    DownEnd = 0.23,
    DepthStart = 0.07,
    DepthEnd = 0.11,
    WidthStart = 0.30,
    WidthEnd = 0.25,
    BendStart = 0.03,
    BendEnd = 0.06,
    RippleSpeed = 1.09,
    RippleDelay = 0.18,
    RippleSpacing = 0.73,
    RippleStrength = 0.009,
    FineSpeed = 0.95,
    FineStrength = 0.004,
    OutwardRipple = 0.10,
    UpRipple = 0.15,
    CurveInfluence = 0.03,
    FlapDelay = 0.17,
    FlapInfluence = 0.05,
    FoldInfluence = 0.03,
    DepthInfluence = 0.03
}

local function RenderWing(
    Wing,
    Points,
    SideVector,
    UpVector,
    BackVector,
    CurrentTime,
    FlapPhase
)
    RenderLayer(
        Wing.Primary,
        function(Alpha)
            return LerpVector(
                Points.Wrist,
                Points.LowerOuter,
                Alpha
            )
        end,
        SideVector,
        UpVector,
        BackVector,
        CurrentTime,
        FlapPhase,
        PrimaryConfiguration
    )

    RenderLayer(
        Wing.Secondary,
        function(Alpha)
            return LerpVector(
                Points.Shoulder,
                Points.Outer,
                Alpha
            )
        end,
        SideVector,
        UpVector,
        BackVector,
        CurrentTime,
        FlapPhase - 0.08,
        SecondaryConfiguration
    )

    RenderLayer(
        Wing.Coverts,
        function(Alpha)
            return LerpVector(
                Points.Root,
                Points.Wrist,
                Alpha
            )
        end,
        SideVector,
        UpVector,
        BackVector,
        CurrentTime,
        FlapPhase - 0.13,
        CovertsConfiguration
    )

    RenderLayer(
        Wing.Upper,
        function(Alpha)
            if Alpha < 0.48 then
                return LerpVector(
                    Points.Root,
                    Points.Elbow,
                    Alpha / 0.48
                )
            end

            return LerpVector(
                Points.Elbow,
                Points.Wrist,
                (
                    Alpha
                    - 0.48
                )
                / 0.52
            )
        end,
        SideVector,
        UpVector,
        BackVector,
        CurrentTime,
        FlapPhase - 0.18,
        UpperConfiguration
    )

    RenderLayer(
        Wing.Inner,
        function(Alpha)
            return LerpVector(
                Points.Root,
                Points.Shoulder,
                Alpha
            )
        end,
        SideVector,
        UpVector,
        BackVector,
        CurrentTime,
        FlapPhase - 0.22,
        InnerConfiguration
    )

    DrawStroke(
        Wing.Outline[1],
        Points.Root,
        Points.Shoulder
    )

    DrawStroke(
        Wing.Outline[2],
        Points.Shoulder,
        Points.Elbow
    )

    DrawStroke(
        Wing.Outline[3],
        Points.Elbow,
        Points.Wrist
    )

    DrawStroke(
        Wing.Outline[4],
        Points.Wrist,
        Points.Outer
    )

    DrawStroke(
        Wing.Outline[5],
        Points.Outer,
        Points.LowerOuter
    )

    DrawStroke(
        Wing.Outline[6],
        Points.LowerOuter,
        Points.LowerInner
    )
end

function Controller:SetEnabled(
    Value
)
    local NewState =
        Value == true

    if self.Enabled
        == NewState
    then
        if not NewState then
            HideAll()
        end

        return
    end

    self.Enabled =
        NewState

    if not NewState then
        HideAll()
    end
end

function Controller:SetColor(
    Value
)
    if typeof(Value)
        ~= "Color3"
    then
        return
    end

    WingColor =
        Value

    self.Color =
        Value

    ApplyColors()
end

function Controller:SetOutlineColor(
    Value
)
    if typeof(Value)
        ~= "Color3"
    then
        return
    end

    OutlineColor =
        Value

    self.OutlineColor =
        Value

    ApplyColors()
end

function Controller:SetScale(
    Value
)
    if type(Value)
        ~= "number"
    then
        return
    end

    WingScale =
        Clamp(
            Value,
            0.45,
            2.5
        )

    self.Scale =
        WingScale
end

function Controller:SetHeight(
    Value
)
    if type(Value)
        ~= "number"
    then
        return
    end

    HeightOffset =
        Clamp(
            Value,
            -2.5,
            3.5
        )

    self.Height =
        HeightOffset
end

function Controller:SetSwingSpeed(
    Value
)
    if type(Value)
        ~= "number"
    then
        return
    end

    FlapSpeed =
        Clamp(
            Value,
            0.1,
            6
        )

    self.SwingSpeed =
        FlapSpeed
end

function Controller:SetFps(
    Value
)
    if type(Value)
        ~= "number"
    then
        return
    end

    RenderFps =
        Clamp(
            math.floor(
                Value + 0.5
            ),
            30,
            360
        )

    RenderInterval =
        1 / RenderFps
end

function Controller:GetFps()
    return RenderFps
end

function Controller:Stop()
    if not self.Running then
        return
    end

    self.Running =
        false

    self.Enabled =
        false

    HideAll()

    for Index = 1,
        #Drawings
    do
        local DrawingData =
            Drawings[Index]

        if DrawingData
            and DrawingData.Object
        then
            pcall(function()
                DrawingData.Object:
                    Remove()
            end)
        end
    end

    Drawings = {}

    if _G.NightfallWingsController
        == self
    then
        _G.NightfallWingsController =
            nil
    end
end

ApplyColors()

RunService.RenderStepped:
Connect(function(DeltaTime)
    if not Controller.Running then
        return
    end

    local CurrentTime =
        os.clock()

    if CurrentTime
        - LastRenderTime
        < RenderInterval
    then
        return
    end

    local FrameDelta =
        CurrentTime
        - LastRenderTime

    LastRenderTime =
        CurrentTime

    if not Controller.Enabled then
        HideAll()

        return
    end

    if not Drawing
        or type(Drawing.new)
            ~= "function"
    then
        return
    end

    local AnchorPart,
        IsR6 =
        GetWingAnchor()

    if not AnchorPart then
        HideAll()

        return
    end

    local AnchorFrame =
        AnchorPart.CFrame

    local Position =
        AnchorFrame.Position

    local RightVector =
        AnchorFrame.RightVector

    local UpVector =
        AnchorFrame.UpVector

    local BackVector =
        -AnchorFrame.LookVector

    local AttachmentHeight =
        IsR6
        and 0.12
        or 0.48

    local Origin =
        Position
        + UpVector
            * (
                AttachmentHeight
                + HeightOffset
            )
        + BackVector
            * BackOffset

    AnimationTime =
        AnimationTime
        + Clamp(
            type(FrameDelta)
                == "number"
                and FrameDelta
                or DeltaTime,
            0.001,
            0.05
        )

    local FlapPhase =
        AnimationTime
        * FlapSpeed

    local MainWave =
        math.sin(
            FlapPhase
        )

    local HarmonicWave =
        math.sin(
            FlapPhase * 2
            - 0.88
        )

    local SlowWave =
        math.sin(
            FlapPhase * 0.5
            + 0.31
        )

    local Flap =
        (
            MainWave * 0.81
            + HarmonicWave * 0.14
            + SlowWave * 0.05
        )
        * 0.72

    local Fold =
        Clamp(
            0.5
            + 0.5
                * math.sin(
                    FlapPhase
                    - math.pi * 0.5
                ),
            0,
            1
        )

    Fold =
        Fold
        * Fold
        * (
            3
            - 2 * Fold
        )

    local LeftPoints =
        CalculateWingPoints(
            Origin,
            -RightVector,
            UpVector,
            BackVector,
            Flap,
            Fold
        )

    local RightPoints =
        CalculateWingPoints(
            Origin,
            RightVector,
            UpVector,
            BackVector,
            Flap,
            Fold
        )

    RenderWing(
        LeftWing,
        LeftPoints,
        -RightVector,
        UpVector,
        BackVector,
        AnimationTime,
        FlapPhase
    )

    RenderWing(
        RightWing,
        RightPoints,
        RightVector,
        UpVector,
        BackVector,
        AnimationTime + 0.018,
        FlapPhase + 0.012
    )
end)

return Controller
