local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local BasePartPrimitiveOffset = 0x128
local PrimitiveRotationOffset = 0xC8
local PrimitivePositionOffset = 0xEC

local DefaultColor = Color3.fromRGB(112, 64, 225)

local Scale = 1.12
local BackOffset = 0.68
local RootGap = 0.46

local R15AttachmentHeight = 0.48
local R6AttachmentHeight = 0.12
local FallbackAttachmentHeight = 0.38

local FlapSpeed = 1.45
local FlapStrength = 0.72
local FeatherWaveStrength = 0.034

local PreviousController = _G.NightfallWingsController

if PreviousController and PreviousController.Stop then
    pcall(function()
        PreviousController:Stop()
    end)
end

local Controller = {
    Running = true,
    Enabled = true,
    Color = DefaultColor,
    SwingSpeed = FlapSpeed
}

_G.NightfallWingsController = Controller

local Drawings = {}
local DrawingRoles = {}

local ActiveCharacter = nil
local CachedAnchorPart = nil
local CachedPrimitiveAddress = 0
local StableBack = nil
local AnimationTime = 0
local RenderRevision = 0

local Palette = {}

local function Clamp(Value, Minimum, Maximum)
    if Value < Minimum then
        return Minimum
    end

    if Value > Maximum then
        return Maximum
    end

    return Value
end

local function LerpNumber(A, B, Alpha)
    return A + (B - A) * Alpha
end

local function LerpVector(A, B, Alpha)
    return A + (B - A) * Alpha
end

local function SmoothStep(Value)
    local Alpha = Clamp(Value, 0, 1)

    return Alpha * Alpha * (3 - 2 * Alpha)
end

local function MixColor(A, B, Alpha)
    return Color3.new(
        LerpNumber(A.R, B.R, Alpha),
        LerpNumber(A.G, B.G, Alpha),
        LerpNumber(A.B, B.B, Alpha)
    )
end

local function BuildPalette(BaseColor)
    local Night = Color3.fromRGB(8, 5, 25)
    local DeepIndigo = Color3.fromRGB(30, 16, 82)
    local Violet = Color3.fromRGB(133, 76, 255)
    local Ice = Color3.fromRGB(192, 230, 255)
    local White = Color3.fromRGB(255, 252, 255)

    Palette.Core = MixColor(BaseColor, Violet, 0.24)
    Palette.Dark = MixColor(BaseColor, Night, 0.62)
    Palette.Shadow = MixColor(BaseColor, DeepIndigo, 0.52)
    Palette.Light = MixColor(BaseColor, White, 0.58)
    Palette.Highlight = MixColor(BaseColor, Ice, 0.72)
    Palette.Edge = MixColor(BaseColor, White, 0.78)
    Palette.Shaft = MixColor(BaseColor, Ice, 0.54)
    Palette.Glow = MixColor(BaseColor, Violet, 0.48)
end

local function RegisterDrawing(DrawingObject, Role)
    Drawings[#Drawings + 1] = DrawingObject
    DrawingRoles[DrawingObject] = Role

    if Palette[Role] then
        DrawingObject.Color = Palette[Role]
    end

    return DrawingObject
end

local function ApplyPalette()
    for Index = 1, #Drawings do
        local DrawingObject = Drawings[Index]
        local Role = DrawingRoles[DrawingObject]

        if Role and Palette[Role] then
            DrawingObject.Color = Palette[Role]
        end
    end
end

BuildPalette(DefaultColor)

local function CreateTriangle(Role, Transparency, ZIndex)
    local Triangle = Drawing.new("Triangle")

    Triangle.Color = Palette[Role]
    Triangle.Transparency = Transparency
    Triangle.ZIndex = ZIndex
    Triangle.Visible = false

    return RegisterDrawing(Triangle, Role)
end

local function CreateLine(Role, Thickness, Transparency, ZIndex)
    local Line = Drawing.new("Line")

    Line.Color = Palette[Role]
    Line.Thickness = Thickness
    Line.Transparency = Transparency
    Line.ZIndex = ZIndex
    Line.Visible = false

    return RegisterDrawing(Line, Role)
end

local function CreateStroke(MainRole, Thickness, Transparency, GlowThickness, GlowTransparency, ZIndex)
    return {
        Glow = CreateLine("Glow", GlowThickness, GlowTransparency, ZIndex),
        Main = CreateLine(MainRole, Thickness, Transparency, ZIndex + 1)
    }
end

local function CreateFeather(LeftRole, RightRole, ZIndex, HasShaft)
    local Feather = {
        Left = CreateTriangle(LeftRole, 0.93, ZIndex),
        Right = CreateTriangle(RightRole, 0.93, ZIndex),
        Shaft = nil
    }

    if HasShaft then
        Feather.Shaft = CreateLine("Shaft", 1, 0.67, ZIndex + 1)
    end

    return Feather
end

local function HideStroke(Stroke)
    Stroke.Glow.Visible = false
    Stroke.Main.Visible = false
end

local function HideFeather(Feather)
    Feather.Left.Visible = false
    Feather.Right.Visible = false

    if Feather.Shaft then
        Feather.Shaft.Visible = false
    end
end

local function HideAll()
    for Index = 1, #Drawings do
        local DrawingObject = Drawings[Index]

        pcall(function()
            DrawingObject.Visible = false
        end)
    end
end

local function DrawLineObject(Line, WorldA, WorldB)
    local ScreenA, VisibleA = WorldToScreen(WorldA)
    local ScreenB, VisibleB = WorldToScreen(WorldB)

    if not VisibleA or not VisibleB then
        Line.Visible = false
        return false
    end

    Line.From = ScreenA
    Line.To = ScreenB
    Line.Visible = true

    return true
end

local function DrawStroke(Stroke, WorldA, WorldB)
    local MainVisible = DrawLineObject(Stroke.Main, WorldA, WorldB)

    if MainVisible then
        DrawLineObject(Stroke.Glow, WorldA, WorldB)
    else
        Stroke.Glow.Visible = false
    end
end

local function DrawFeather(Feather, RootPosition, TipPosition, Width, PlaneNormal, Bend, Curve)
    local Direction = TipPosition - RootPosition

    if Direction.Magnitude < 0.001 then
        HideFeather(Feather)
        return
    end

    local WidthDirection = PlaneNormal:Cross(Direction)

    if WidthDirection.Magnitude < 0.001 then
        HideFeather(Feather)
        return
    end

    WidthDirection = WidthDirection.Unit

    local WidePosition =
        RootPosition
        + Direction * 0.53
        + PlaneNormal * Bend
        + WidthDirection * Curve

    local LeftPosition = WidePosition + WidthDirection * Width
    local RightPosition = WidePosition - WidthDirection * Width

    local ScreenRoot, VisibleRoot = WorldToScreen(RootPosition)
    local ScreenLeft, VisibleLeft = WorldToScreen(LeftPosition)
    local ScreenRight, VisibleRight = WorldToScreen(RightPosition)
    local ScreenTip, VisibleTip = WorldToScreen(TipPosition)

    if not VisibleRoot or not VisibleLeft or not VisibleRight or not VisibleTip then
        HideFeather(Feather)
        return
    end

    Feather.Left.PointA = ScreenRoot
    Feather.Left.PointB = ScreenLeft
    Feather.Left.PointC = ScreenTip
    Feather.Left.Visible = true

    Feather.Right.PointA = ScreenRoot
    Feather.Right.PointB = ScreenTip
    Feather.Right.PointC = ScreenRight
    Feather.Right.Visible = true

    if Feather.Shaft then
        Feather.Shaft.From = ScreenRoot
        Feather.Shaft.To = ScreenTip
        Feather.Shaft.Visible = true
    end
end

local function GetAlternatingRole(Index, FirstRole, SecondRole)
    if Index % 2 == 0 then
        return FirstRole
    end

    return SecondRole
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

    for Index = 1, 8 do
        Wing.Primary[Index] = CreateFeather(
            GetAlternatingRole(Index, "Core", "Shadow"),
            GetAlternatingRole(Index, "Light", "Highlight"),
            3,
            true
        )
    end

    for Index = 1, 7 do
        Wing.Secondary[Index] = CreateFeather(
            GetAlternatingRole(Index, "Light", "Core"),
            GetAlternatingRole(Index, "Highlight", "Light"),
            5,
            true
        )
    end

    for Index = 1, 6 do
        Wing.Coverts[Index] = CreateFeather(
            GetAlternatingRole(Index, "Core", "Light"),
            GetAlternatingRole(Index, "Light", "Highlight"),
            7,
            false
        )
    end

    for Index = 1, 5 do
        Wing.Upper[Index] = CreateFeather(
            GetAlternatingRole(Index, "Highlight", "Light"),
            GetAlternatingRole(Index, "Light", "Highlight"),
            9,
            false
        )
    end

    for Index = 1, 4 do
        Wing.Inner[Index] = CreateFeather(
            GetAlternatingRole(Index, "Light", "Core"),
            GetAlternatingRole(Index, "Highlight", "Light"),
            11,
            false
        )
    end

    for Index = 1, 6 do
        Wing.Outline[Index] = CreateStroke(
            "Edge",
            2,
            0.92,
            6,
            0.08,
            13
        )
    end

    return Wing
end

local LeftWing = CreateWing()
local RightWing = CreateWing()

local function IsValidNumber(Value)
    return Value == Value
        and Value ~= math.huge
        and Value ~= -math.huge
        and math.abs(Value) < 10000000
end

local function IsValidVector(Value)
    return IsValidNumber(Value.X)
        and IsValidNumber(Value.Y)
        and IsValidNumber(Value.Z)
end

local function ReadFloat(Address)
    return memory_read("float", Address)
end

local function ReadVector3(Address)
    return Vector3.new(
        ReadFloat(Address),
        ReadFloat(Address + 0x4),
        ReadFloat(Address + 0x8)
    )
end

local function GetPrimitiveAddress(Part)
    if CachedAnchorPart ~= Part then
        CachedAnchorPart = Part
        CachedPrimitiveAddress = 0
        StableBack = nil
    end

    if CachedPrimitiveAddress ~= 0 then
        return CachedPrimitiveAddress
    end

    local InstanceAddress = Part.Address

    if not InstanceAddress or InstanceAddress == 0 then
        return 0
    end

    local PrimitiveAddress = memory_read(
        "uintptr_t",
        InstanceAddress + BasePartPrimitiveOffset
    )

    if not PrimitiveAddress or PrimitiveAddress < 0x10000 then
        return 0
    end

    CachedPrimitiveAddress = PrimitiveAddress

    return PrimitiveAddress
end

local function StabilizeBasis(Right, Back)
    if StableBack
        and Back:Dot(StableBack) < -0.85
    then
        Right = -Right
        Back = -Back
    end

    StableBack = Back

    return Right, Back
end

local function ReadPartTransform(Part)
    local PrimitiveAddress = GetPrimitiveAddress(Part)

    if PrimitiveAddress == 0 then
        return nil
    end

    local PositionAddress =
        PrimitiveAddress + PrimitivePositionOffset

    local PositionA =
        ReadVector3(PositionAddress)

    if not IsValidVector(PositionA) then
        CachedPrimitiveAddress = 0
        return nil
    end

    local RotationAddress =
        PrimitiveAddress + PrimitiveRotationOffset

    local M00 = ReadFloat(RotationAddress)
    local M01 = ReadFloat(RotationAddress + 0x4)
    local M02 = ReadFloat(RotationAddress + 0x8)

    local M10 = ReadFloat(RotationAddress + 0xC)
    local M11 = ReadFloat(RotationAddress + 0x10)
    local M12 = ReadFloat(RotationAddress + 0x14)

    local M20 = ReadFloat(RotationAddress + 0x18)
    local M21 = ReadFloat(RotationAddress + 0x1C)
    local M22 = ReadFloat(RotationAddress + 0x20)

    if not IsValidNumber(M00)
        or not IsValidNumber(M01)
        or not IsValidNumber(M02)
        or not IsValidNumber(M10)
        or not IsValidNumber(M11)
        or not IsValidNumber(M12)
        or not IsValidNumber(M20)
        or not IsValidNumber(M21)
        or not IsValidNumber(M22)
    then
        CachedPrimitiveAddress = 0
        return nil
    end

    local PositionB =
        ReadVector3(PositionAddress)

    if not IsValidVector(PositionB)
        or (PositionB - PositionA).Magnitude > 1.5
    then
        CachedPrimitiveAddress = 0
        return nil
    end

    local RightRaw = Vector3.new(M00, M10, M20)
    local BackRaw = Vector3.new(M02, M12, M22)

    if RightRaw.Magnitude < 0.5
        or RightRaw.Magnitude > 1.5
        or BackRaw.Magnitude < 0.5
        or BackRaw.Magnitude > 1.5
    then
        CachedPrimitiveAddress = 0
        return nil
    end

    local Up = Vector3.new(0, 1, 0)

    local FlatBack = Vector3.new(
        BackRaw.X,
        0,
        BackRaw.Z
    )

    local Right = nil
    local Back = nil

    if FlatBack.Magnitude >= 0.5 then
        Back = FlatBack.Unit
        Right = Up:Cross(Back)

        if Right.Magnitude < 0.5 then
            CachedPrimitiveAddress = 0
            return nil
        end

        Right = Right.Unit
        Back = Right:Cross(Up).Unit
    else
        local FlatRight = Vector3.new(
            RightRaw.X,
            0,
            RightRaw.Z
        )

        if FlatRight.Magnitude < 0.5 then
            CachedPrimitiveAddress = 0
            return nil
        end

        Right = FlatRight.Unit
        Back = Right:Cross(Up)

        if Back.Magnitude < 0.5 then
            CachedPrimitiveAddress = 0
            return nil
        end

        Back = Back.Unit
    end

    Right, Back =
        StabilizeBasis(Right, Back)

    return {
        Position = PositionB,
        Right = Right,
        Up = Up,
        Back = Back
    }
end

local function GetWingAnchor(Character)
    local UpperTorso =
        Character:FindFirstChild("UpperTorso")

    local Torso =
        Character:FindFirstChild("Torso")

    if Torso and not UpperTorso then
        return Torso, true
    end

    local RootPart =
        Character:FindFirstChild("HumanoidRootPart")
        or Character.PrimaryPart

    return RootPart, false
end

local function GetAttachmentHeight(IsR6)
    if IsR6 then
        return R6AttachmentHeight
    end

    return R15AttachmentHeight
end

local function CalculateWingPoints(Origin, SideVector, Up, Back, Flap, Fold)
    local Raised = math.max(Flap, 0)
    local Lowered = math.max(-Flap, 0)

    local Root =
        Origin
        + SideVector * (RootGap * Scale)

    local Shoulder =
        Origin
        + SideVector * ((1.24 - Fold * 0.06) * Scale)
        + Up * ((0.62 + Flap * 0.14) * Scale)
        + Back * (0.06 * Scale)

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
            * Scale
        )
        + Up * ((2.76 + Flap * 0.62) * Scale)
        + Back * ((0.18 + Fold * 0.13) * Scale)

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
            * Scale
        )
        + Up * ((2.38 + Flap * 0.91) * Scale)
        + Back
        * (
            (
                0.34
                + Raised * 0.31
                + Fold * 0.21
            )
            * Scale
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
            * Scale
        )
        + Up * ((1.34 + Flap * 1.18) * Scale)
        + Back
        * (
            (
                0.49
                + Raised * 0.49
                + Fold * 0.37
            )
            * Scale
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
            * Scale
        )
        + Up * ((-0.12 + Flap * 0.79) * Scale)
        + Back
        * (
            (
                0.54
                + Raised * 0.42
                + Fold * 0.31
            )
            * Scale
        )

    local LowerInner =
        Origin
        + SideVector * ((2.14 - Fold * 0.10) * Scale)
        + Up * ((-0.48 + Flap * 0.22) * Scale)
        + Back * ((0.23 + Fold * 0.08) * Scale)

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
    Up,
    Back,
    CurrentTime,
    FlapPhase,
    Configuration
)
    local Count = #Feathers

    for Index = 1, Count do
        local Alpha =
            (Index - 1)
            / math.max(Count - 1, 1)

        local RootPosition = RootFunction(Alpha)

        local DelayedFlap =
            math.sin(
                FlapPhase
                - Alpha * Configuration.FlapDelay
            )

        local Ripple =
            math.sin(
                CurrentTime * Configuration.RippleSpeed
                - Alpha * Configuration.RippleDelay
                + Index * Configuration.RippleSpacing
            )
            * Configuration.RippleStrength

        local FineRipple =
            math.sin(
                CurrentTime * Configuration.FineSpeed
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
                    + Ripple * Configuration.OutwardRipple
                    - math.max(DelayedFlap, 0)
                    * Alpha
                    * Configuration.FoldInfluence
                )
                * Scale
            )
            - Up
            * (
                (
                    Downward
                    - Ripple * Configuration.UpRipple
                    - DelayedFlap
                    * Alpha
                    * Configuration.FlapInfluence
                )
                * Scale
            )
            + Back
            * (
                (
                    Depth
                    + FineRipple
                    + math.max(DelayedFlap, 0)
                    * Alpha
                    * Configuration.DepthInfluence
                )
                * Scale
            )

        DrawFeather(
            Feathers[Index],
            RootPosition,
            TipPosition,
            Width * Scale,
            Back,
            LerpNumber(
                Configuration.BendStart,
                Configuration.BendEnd,
                Alpha
            ) * Scale,
            Ripple * Configuration.CurveInfluence * Scale
        )
    end
end

local function RenderWing(
    Wing,
    Points,
    SideVector,
    Up,
    Back,
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
        Up,
        Back,
        CurrentTime,
        FlapPhase,
        {
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
            RippleStrength = FeatherWaveStrength,
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
        Up,
        Back,
        CurrentTime,
        FlapPhase - 0.08,
        {
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
        Up,
        Back,
        CurrentTime,
        FlapPhase - 0.13,
        {
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
                (Alpha - 0.48) / 0.52
            )
        end,
        SideVector,
        Up,
        Back,
        CurrentTime,
        FlapPhase - 0.18,
        {
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
        Up,
        Back,
        CurrentTime,
        FlapPhase - 0.22,
        {
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

function Controller:SetEnabled(Value)
    local NewState = Value == true

    if self.Enabled == NewState then
        if not NewState then
            HideAll()
        end

        return
    end

    self.Enabled = NewState
    RenderRevision = RenderRevision + 1

    if not NewState then
        HideAll()

        task.defer(function()
            if self.Running
                and not self.Enabled
            then
                HideAll()
            end
        end)
    end
end

function Controller:SetColor(Value)
    if typeof(Value) ~= "Color3" then
        return
    end

    self.Color = Value
    BuildPalette(Value)
    ApplyPalette()
end

function Controller:SetScale(Value)
    if type(Value) ~= "number" then
        return
    end

    Scale = Clamp(Value, 0.6, 1.8)
end

function Controller:SetSwingSpeed(Value)
    if type(Value) ~= "number" then
        return
    end

    FlapSpeed = Clamp(Value, 0.1, 6)
    self.SwingSpeed = FlapSpeed
end

function Controller:Stop()
    if not self.Running then
        return
    end

    self.Running = false
    self.Enabled = false
    RenderRevision = RenderRevision + 1

    for Index = 1, #Drawings do
        local DrawingObject = Drawings[Index]

        DrawingObject.Visible = false

        pcall(function()
            DrawingObject:Remove()
        end)
    end

    Drawings = {}
    DrawingRoles = {}
    CachedAnchorPart = nil
    CachedPrimitiveAddress = 0
    StableBack = nil

    if _G.NightfallWingsController == self then
        _G.NightfallWingsController = nil
    end
end

RunService.RenderStepped:Connect(function(DeltaTime)
    if not Controller.Running then
        return
    end

    if not Controller.Enabled then
        HideAll()
        return
    end

    local FrameRevision = RenderRevision

    if type(DeltaTime) ~= "number" then
        DeltaTime = 0.016
    end

    DeltaTime = Clamp(DeltaTime, 0.001, 0.05)

    Camera = Workspace.CurrentCamera

    local Character = LocalPlayer.Character

    if not Character or not Camera then
        HideAll()
        return
    end

    local AnchorPart, IsR6 =
        GetWingAnchor(Character)

    if not AnchorPart then
        HideAll()
        return
    end

    if ActiveCharacter ~= Character then
        ActiveCharacter = Character
        CachedAnchorPart = nil
        CachedPrimitiveAddress = 0
        StableBack = nil
    end

    local Transform =
        ReadPartTransform(AnchorPart)

    if not Transform then
        HideAll()
        return
    end

    AnimationTime = AnimationTime + DeltaTime

    local FlapPhase = AnimationTime * FlapSpeed

    local MainWave = math.sin(FlapPhase)
    local HarmonicWave = math.sin(FlapPhase * 2 - 0.88)
    local SlowWave = math.sin(FlapPhase * 0.5 + 0.31)

    local Flap =
        (
            MainWave * 0.81
            + HarmonicWave * 0.14
            + SlowWave * 0.05
        )
        * FlapStrength

    local Fold =
        SmoothStep(
            0.5
            + 0.5
            * math.sin(
                FlapPhase - math.pi * 0.5
            )
        )

    local Right = Transform.Right
    local Up = Transform.Up
    local Back = Transform.Back

    local AttachmentHeight =
        GetAttachmentHeight(IsR6)

    local Origin =
        Transform.Position
        + Up * AttachmentHeight
        + Back * BackOffset

    local LeftPoints =
        CalculateWingPoints(
            Origin,
            -Right,
            Up,
            Back,
            Flap,
            Fold
        )

    local RightPoints =
        CalculateWingPoints(
            Origin,
            Right,
            Up,
            Back,
            Flap,
            Fold
        )

    RenderWing(
        LeftWing,
        LeftPoints,
        -Right,
        Up,
        Back,
        AnimationTime,
        FlapPhase
    )

    RenderWing(
        RightWing,
        RightPoints,
        Right,
        Up,
        Back,
        AnimationTime + 0.018,
        FlapPhase + 0.012
    )

    if not Controller.Enabled
        or FrameRevision ~= RenderRevision
    then
        HideAll()
    end
end)

return Controller
