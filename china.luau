local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local BasePartPrimitiveOffset = 0x128
local PrimitiveRotationOffset = 0xC8

local DefaultColor = Color3.fromRGB(112, 64, 225)

local Scale = 1
local BrimRadius = 1.55
local InnerRadius = 1.08
local BrimHeight = 0.58
local ApexHeight = 1.30
local HeightOffset = 0
local SegmentCount = 32
local SpokeStep = 2

local PreviousController = _G.NightfallChinaHatController

if PreviousController and PreviousController.Stop then
    pcall(function()
        PreviousController:Stop()
    end)
end

local Controller = {
    Running = true,
    Enabled = true,
    Color = DefaultColor
}

_G.NightfallChinaHatController = Controller

local Drawings = {}
local DrawingRoles = {}
local PrimitiveCache = {}

local ActiveCharacter = nil
local CameraState = nil
local BufferFromPosition = nil
local BufferToPosition = nil
local BufferFromUp = nil
local BufferToUp = nil
local BufferFromBack = nil
local BufferToBack = nil
local BufferStartTime = 0
local BufferDuration = 1 / 60
local SampleInterval = 1 / 60
local LastAcceptedTime = 0
local LastObservedRootPosition = nil
local LastObservedCameraPosition = nil
local LastObservedCameraLook = nil
local LastObservedCameraUp = nil
local LastObservedWorldBack = nil
local PendingPosition = nil
local PendingUp = nil
local PendingBack = nil
local PendingSince = 0
local PendingRootChanged = false
local PendingCameraChanged = false
local PendingRotationChanged = false
local LastValidFrameTime = 0

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

local function MixColor(A, B, Alpha)
    return Color3.new(
        LerpNumber(A.R, B.R, Alpha),
        LerpNumber(A.G, B.G, Alpha),
        LerpNumber(A.B, B.B, Alpha)
    )
end

local function BuildPalette(BaseColor)
    local Night = Color3.fromRGB(5, 3, 18)
    local Indigo = Color3.fromRGB(30, 14, 90)
    local Violet = Color3.fromRGB(145, 82, 255)
    local Ice = Color3.fromRGB(190, 228, 255)
    local White = Color3.fromRGB(255, 252, 255)

    Palette.Core = MixColor(
        BaseColor,
        Violet,
        0.24
    )

    Palette.Dark = MixColor(
        BaseColor,
        Night,
        0.70
    )

    Palette.Shadow = MixColor(
        BaseColor,
        Indigo,
        0.56
    )

    Palette.Light = MixColor(
        BaseColor,
        White,
        0.58
    )

    Palette.Highlight = MixColor(
        BaseColor,
        Ice,
        0.76
    )

    Palette.Edge = MixColor(
        BaseColor,
        White,
        0.82
    )

    Palette.Glow = MixColor(
        BaseColor,
        Violet,
        0.50
    )
end

BuildPalette(DefaultColor)

local function RegisterDrawing(
    DrawingObject,
    Role
)
    Drawings[#Drawings + 1] =
        DrawingObject

    DrawingRoles[DrawingObject] =
        Role

    DrawingObject.Color =
        Palette[Role]

    return DrawingObject
end

local function CreateLine(
    Role,
    Thickness,
    Transparency,
    ZIndex
)
    local Line =
        Drawing.new("Line")

    Line.Color = Palette[Role]
    Line.Thickness = Thickness
    Line.Transparency = Transparency
    Line.ZIndex = ZIndex
    Line.Visible = false

    return RegisterDrawing(
        Line,
        Role
    )
end

local function CreateStroke(
    Role,
    Thickness,
    Transparency,
    GlowThickness,
    GlowTransparency,
    ZIndex
)
    return {
        Glow = CreateLine(
            "Glow",
            GlowThickness,
            GlowTransparency,
            ZIndex
        ),

        Main = CreateLine(
            Role,
            Thickness,
            Transparency,
            ZIndex + 1
        )
    }
end

local OuterRing = {}
local InnerRing = {}
local Spokes = {}
local DetailSpokes = {}

for Index = 1, SegmentCount do
    OuterRing[Index] = CreateStroke(
        "Edge",
        2,
        0.96,
        7,
        0.075,
        20
    )

    InnerRing[Index] = CreateLine(
        Index % 2 == 0
            and "Core"
            or "Highlight",
        1,
        0.64,
        17
    )
end

for Index = 1, SegmentCount, SpokeStep do
    local Role =
        Index % 4 == 1
            and "Highlight"
            or "Light"

    Spokes[#Spokes + 1] = CreateStroke(
        Role,
        1,
        0.88,
        4,
        0.055,
        18
    )

    DetailSpokes[#DetailSpokes + 1] =
        CreateLine(
            Index % 4 == 1
                and "Core"
                or "Shadow",
            1,
            0.48,
            16
        )
end

local function ApplyPalette()
    for Index = 1, #Drawings do
        local DrawingObject =
            Drawings[Index]

        local Role =
            DrawingRoles[DrawingObject]

        if Role and Palette[Role] then
            DrawingObject.Color =
                Palette[Role]
        end
    end
end

local function HideAll()
    for Index = 1, #Drawings do
        Drawings[Index].Visible = false
    end
end

local function HoldLastFrame()
    if tick() - LastValidFrameTime > 0.20 then
        HideAll()
    end
end

local function SafeMemoryRead(
    TypeName,
    Address
)
    local Success, Value =
        pcall(
            memory_read,
            TypeName,
            Address
        )

    if Success then
        return Value
    end

    return nil
end

local function IsValidNumber(Value)
    return type(Value) == "number"
        and Value == Value
        and Value ~= math.huge
        and Value ~= -math.huge
        and math.abs(Value) < 10000000
end

local function IsValidVector(Value)
    return Value
        and IsValidNumber(Value.X)
        and IsValidNumber(Value.Y)
        and IsValidNumber(Value.Z)
end

local function ReadFloat(Address)
    return SafeMemoryRead(
        "float",
        Address
    )
end

local function ReadVector3(Address)
    local X = ReadFloat(Address)
    local Y = ReadFloat(Address + 0x4)
    local Z = ReadFloat(Address + 0x8)

    if not IsValidNumber(X)
        or not IsValidNumber(Y)
        or not IsValidNumber(Z)
    then
        return nil
    end

    return Vector3.new(X, Y, Z)
end

local function GetPrimitiveAddress(Part)
    local CachedAddress =
        PrimitiveCache[Part]

    if CachedAddress
        and CachedAddress > 0
    then
        return CachedAddress
    end

    local InstanceAddress =
        Part.Address

    if not InstanceAddress
        or InstanceAddress == 0
    then
        return 0
    end

    local PrimitiveAddress =
        SafeMemoryRead(
            "uintptr_t",
            InstanceAddress
            + BasePartPrimitiveOffset
        )

    if not PrimitiveAddress
        or PrimitiveAddress < 0x10000
    then
        return 0
    end

    PrimitiveCache[Part] =
        PrimitiveAddress

    return PrimitiveAddress
end

local function ReadPartPosition(Part)
    local Success, Position =
        pcall(function()
            return Part.Position
        end)

    if not Success
        or typeof(Position) ~= "Vector3"
        or not IsValidVector(Position)
    then
        return nil
    end

    return Position
end

local function ReadHorizontalBasis(Part)
    local PrimitiveAddress =
        GetPrimitiveAddress(Part)

    if PrimitiveAddress == 0 then
        return nil
    end

    local RotationAddress =
        PrimitiveAddress
        + PrimitiveRotationOffset

    local M00 =
        ReadFloat(RotationAddress)

    local M02 =
        ReadFloat(
            RotationAddress + 0x8
        )

    local M20 =
        ReadFloat(
            RotationAddress + 0x18
        )

    local M22 =
        ReadFloat(
            RotationAddress + 0x20
        )

    if not IsValidNumber(M00)
        or not IsValidNumber(M02)
        or not IsValidNumber(M20)
        or not IsValidNumber(M22)
    then
        PrimitiveCache[Part] = nil
        return nil
    end

    local Up =
        Vector3.new(0, 1, 0)

    local Back =
        Vector3.new(
            M02,
            0,
            M22
        )

    if Back.Magnitude < 0.5 then
        local RightFallback =
            Vector3.new(
                M00,
                0,
                M20
            )

        if RightFallback.Magnitude < 0.5 then
            PrimitiveCache[Part] = nil
            return nil
        end

        local Right =
            RightFallback.Unit

        Back =
            Right:Cross(Up)
    end

    if Back.Magnitude < 0.5 then
        PrimitiveCache[Part] = nil
        return nil
    end

    Back = Back.Unit

    local Right =
        Up:Cross(Back)

    if Right.Magnitude < 0.001 then
        return nil
    end

    Right = Right.Unit
    Back = Right:Cross(Up).Unit

    return Right, Up, Back
end

local function GetHatParts(Character)
    local RootPart =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )
        or Character.PrimaryPart

    local UpperTorso =
        Character:FindFirstChild(
            "UpperTorso"
        )

    local Torso =
        Character:FindFirstChild(
            "Torso"
        )

    local IsR6 =
        Torso ~= nil
        and UpperTorso == nil

    if IsR6 then
        return RootPart,
            RootPart,
            1.5
    end

    local Head =
        Character:FindFirstChild(
            "Head"
        )

    return Head or RootPart,
        RootPart or Head,
        0
end

local function ReadCameraState()
    Camera = Workspace.CurrentCamera

    if not Camera then
        return nil
    end

    local Success,
        CameraCFrame,
        ViewportSize,
        FieldOfView =
        pcall(function()
            return Camera.CFrame,
                Camera.ViewportSize,
                Camera.FieldOfView
        end)

    if not Success
        or typeof(CameraCFrame) ~= "CFrame"
        or typeof(ViewportSize) ~= "Vector2"
        or type(FieldOfView) ~= "number"
        or ViewportSize.X <= 0
        or ViewportSize.Y <= 0
        or FieldOfView <= 1
        or FieldOfView >= 179
    then
        return nil
    end

    local Position =
        CameraCFrame.Position

    local Right =
        CameraCFrame.RightVector

    local Up =
        CameraCFrame.UpVector

    local Look =
        CameraCFrame.LookVector

    if not IsValidVector(Position)
        or not IsValidVector(Right)
        or not IsValidVector(Up)
        or not IsValidVector(Look)
    then
        return nil
    end

    local FocalLength =
        ViewportSize.Y
        / (
            2
            * math.tan(
                math.rad(FieldOfView) * 0.5
            )
        )

    if not IsValidNumber(FocalLength)
        or FocalLength <= 0
    then
        return nil
    end

    return {
        Position = Position,
        Right = Right,
        Up = Up,
        Look = Look,
        CenterX = ViewportSize.X * 0.5,
        CenterY = ViewportSize.Y * 0.5,
        Width = ViewportSize.X,
        Height = ViewportSize.Y,
        FocalLength = FocalLength
    }
end

local function WorldPointToCamera(
    WorldPoint,
    State
)
    local Delta =
        WorldPoint - State.Position

    return Vector3.new(
        Delta:Dot(State.Right),
        Delta:Dot(State.Up),
        Delta:Dot(State.Look)
    )
end

local function WorldVectorToCamera(
    WorldVector,
    State
)
    return Vector3.new(
        WorldVector:Dot(State.Right),
        WorldVector:Dot(State.Up),
        WorldVector:Dot(State.Look)
    )
end

local function VectorChanged(
    Current,
    Previous,
    Epsilon
)
    if not Current
        or not Previous
    then
        return true
    end

    return (
        Current - Previous
    ).Magnitude > Epsilon
end

local function ReadBufferedTransform(
    Now
)
    if not BufferToPosition
        or not BufferToUp
        or not BufferToBack
    then
        return nil
    end

    local Alpha =
        Clamp(
            (
                Now
                - BufferStartTime
            )
            / math.max(
                BufferDuration,
                0.001
            ),
            0,
            1
        )

    local Position =
        BufferFromPosition:Lerp(
            BufferToPosition,
            Alpha
        )

    local Up =
        BufferFromUp:Lerp(
            BufferToUp,
            Alpha
        )

    local Back =
        BufferFromBack:Lerp(
            BufferToBack,
            Alpha
        )

    if Up.Magnitude < 0.001
        or Back.Magnitude < 0.001
    then
        return nil
    end

    Up = Up.Unit
    Back = Back.Unit

    local Right =
        Up:Cross(Back)

    if Right.Magnitude < 0.001 then
        return nil
    end

    Right = Right.Unit
    Back = Right:Cross(Up)

    if Back.Magnitude < 0.001 then
        return nil
    end

    Back = Back.Unit

    return Position,
        Right,
        Up,
        Back
end

local function CommitBufferedTransform(
    Now,
    Position,
    Up,
    Back
)
    local CurrentPosition,
        CurrentRight,
        CurrentUp,
        CurrentBack =
        ReadBufferedTransform(Now)

    if not CurrentPosition then
        CurrentPosition = Position
        CurrentUp = Up
        CurrentBack = Back
    end

    if Back:Dot(CurrentBack) < 0 then
        Back = -Back
    end

    if LastAcceptedTime > 0 then
        local Interval =
            Clamp(
                Now - LastAcceptedTime,
                1 / 120,
                1 / 30
            )

        SampleInterval =
            LerpNumber(
                SampleInterval,
                Interval,
                0.25
            )
    end

    BufferFromPosition =
        CurrentPosition

    BufferToPosition =
        Position

    BufferFromUp =
        CurrentUp

    BufferToUp =
        Up

    BufferFromBack =
        CurrentBack

    BufferToBack =
        Back

    BufferStartTime =
        Now

    BufferDuration =
        Clamp(
            SampleInterval * 1.10,
            1 / 100,
            1 / 30
        )

    LastAcceptedTime =
        Now
end

local function QueueBufferedTransform(
    Now,
    RootPosition,
    State,
    WorldUp,
    WorldBack
)
    local RootChanged =
        VectorChanged(
            RootPosition,
            LastObservedRootPosition,
            0.000001
        )

    local CameraChanged =
        VectorChanged(
            State.Position,
            LastObservedCameraPosition,
            0.000001
        )
        or VectorChanged(
            State.Look,
            LastObservedCameraLook,
            0.000001
        )
        or VectorChanged(
            State.Up,
            LastObservedCameraUp,
            0.000001
        )

    local RotationChanged =
        VectorChanged(
            WorldBack,
            LastObservedWorldBack,
            0.00001
        )

    LastObservedRootPosition =
        RootPosition

    LastObservedCameraPosition =
        State.Position

    LastObservedCameraLook =
        State.Look

    LastObservedCameraUp =
        State.Up

    LastObservedWorldBack =
        WorldBack

    if RootChanged
        or CameraChanged
        or RotationChanged
        or not BufferToPosition
    then
        PendingPosition =
            WorldPointToCamera(
                RootPosition,
                State
            )

        PendingUp =
            WorldVectorToCamera(
                WorldUp,
                State
            )

        PendingBack =
            WorldVectorToCamera(
                WorldBack,
                State
            )

        if PendingSince == 0 then
            PendingSince = Now
        end

        PendingRootChanged =
            PendingRootChanged
            or RootChanged

        PendingCameraChanged =
            PendingCameraChanged
            or CameraChanged

        PendingRotationChanged =
            PendingRotationChanged
            or RotationChanged
    end

    local PendingReady =
        PendingPosition
        and (
            not BufferToPosition
            or (
                PendingRootChanged
                and PendingCameraChanged
            )
            or (
                PendingRotationChanged
                and not PendingRootChanged
                and not PendingCameraChanged
            )
            or Now - PendingSince >= 0.018
        )

    if PendingReady then
        CommitBufferedTransform(
            Now,
            PendingPosition,
            PendingUp,
            PendingBack
        )

        PendingPosition = nil
        PendingUp = nil
        PendingBack = nil
        PendingSince = 0
        PendingRootChanged = false
        PendingCameraChanged = false
        PendingRotationChanged = false
    end
end

local function ResetBufferedTransform()
    BufferFromPosition = nil
    BufferToPosition = nil
    BufferFromUp = nil
    BufferToUp = nil
    BufferFromBack = nil
    BufferToBack = nil
    BufferStartTime = 0
    BufferDuration = 1 / 60
    SampleInterval = 1 / 60
    LastAcceptedTime = 0
    LastObservedRootPosition = nil
    LastObservedCameraPosition = nil
    LastObservedCameraLook = nil
    LastObservedCameraUp = nil
    LastObservedWorldBack = nil
    PendingPosition = nil
    PendingUp = nil
    PendingBack = nil
    PendingSince = 0
    PendingRootChanged = false
    PendingCameraChanged = false
    PendingRotationChanged = false
end

local function ProjectPoint(CameraPoint)
    local State =
        CameraState

    if not State
        or not CameraPoint
        or CameraPoint.Z <= 0.05
    then
        return nil
    end

    local InverseDepth =
        State.FocalLength
        / CameraPoint.Z

    local ScreenX =
        State.CenterX
        + CameraPoint.X * InverseDepth

    local ScreenY =
        State.CenterY
        - CameraPoint.Y * InverseDepth

    if not IsValidNumber(ScreenX)
        or not IsValidNumber(ScreenY)
        or math.abs(ScreenX) > State.Width * 8
        or math.abs(ScreenY) > State.Height * 8
    then
        return nil
    end

    return Vector2.new(
        ScreenX,
        ScreenY
    )
end

local function SetLine(
    Line,
    PointA,
    PointB
)
    if not PointA or not PointB then
        Line.Visible = false
        return false
    end

    Line.From = PointA
    Line.To = PointB
    Line.Visible = true

    return true
end

local function SetStroke(
    Stroke,
    PointA,
    PointB
)
    local Visible =
        SetLine(
            Stroke.Main,
            PointA,
            PointB
        )

    if Visible then
        SetLine(
            Stroke.Glow,
            PointA,
            PointB
        )
    else
        Stroke.Glow.Visible = false
    end
end

local function GetRingPoint(
    Center,
    Right,
    Back,
    Radius,
    Angle,
    Height
)
    return Center
        + Right
        * (
            math.cos(Angle)
            * Radius
            * Scale
        )
        + Back
        * (
            math.sin(Angle)
            * Radius
            * Scale
        )
        + Vector3.new(
            0,
            Height * Scale,
            0
        )
end

local function BuildProjectedRing(
    Center,
    Right,
    Back,
    Radius,
    Height
)
    local Points = {}

    for Index = 1, SegmentCount do
        local Angle =
            (
                Index - 1
            )
            / SegmentCount
            * math.pi
            * 2

        Points[Index] =
            ProjectPoint(
                GetRingPoint(
                    Center,
                    Right,
                    Back,
                    Radius,
                    Angle,
                    Height
                )
            )
    end

    return Points
end

local function RenderRing(
    Ring,
    Points,
    IsStroke
)
    for Index = 1, SegmentCount do
        local NextIndex =
            Index % SegmentCount + 1

        if IsStroke then
            SetStroke(
                Ring[Index],
                Points[Index],
                Points[NextIndex]
            )
        else
            SetLine(
                Ring[Index],
                Points[Index],
                Points[NextIndex]
            )
        end
    end
end

local function RenderHat(
    HeadPosition,
    Right,
    Up,
    Back
)
    local Center =
        HeadPosition
        + Up
        * (
            (
                BrimHeight
                + HeightOffset
            )
            * Scale
        )

    local Apex =
        HeadPosition
        + Up
        * (
            (
                ApexHeight
                + HeightOffset
            )
            * Scale
        )

    local OuterPoints =
        BuildProjectedRing(
            Center,
            Right,
            Back,
            BrimRadius,
            0
        )

    local InnerPoints =
        BuildProjectedRing(
            Center,
            Right,
            Back,
            InnerRadius,
            0.015
        )

    local ScreenApex =
        ProjectPoint(Apex)

    RenderRing(
        OuterRing,
        OuterPoints,
        true
    )

    RenderRing(
        InnerRing,
        InnerPoints,
        false
    )

    local SpokeIndex = 1

    for Index = 1, SegmentCount, SpokeStep do
        SetStroke(
            Spokes[SpokeIndex],
            ScreenApex,
            OuterPoints[Index]
        )

        SetLine(
            DetailSpokes[SpokeIndex],
            InnerPoints[Index],
            OuterPoints[Index]
        )

        SpokeIndex = SpokeIndex + 1
    end
end

function Controller:SetEnabled(Value)
    self.Enabled = Value == true

    if not self.Enabled then
        HideAll()
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

    Scale = Clamp(
        Value,
        0.55,
        1.65
    )
end

function Controller:SetHeight(Value)
    if type(Value) ~= "number" then
        return
    end

    HeightOffset = Clamp(
        Value,
        -1.25,
        2.5
    )
end

function Controller:SetRadius(Value)
    if type(Value) ~= "number" then
        return
    end

    BrimRadius = Clamp(
        Value,
        0.75,
        3.25
    )

    InnerRadius = Clamp(
        BrimRadius * 0.70,
        0.5,
        2.5
    )
end

function Controller:SetConeHeight(Value)
    if type(Value) ~= "number" then
        return
    end

    ApexHeight = Clamp(
        Value,
        0.7,
        3.5
    )
end

function Controller:Stop()
    if not self.Running then
        return
    end

    self.Running = false
    self.Enabled = false

    for Index = 1, #Drawings do
        local DrawingObject =
            Drawings[Index]

        DrawingObject.Visible = false

        pcall(function()
            DrawingObject:Remove()
        end)
    end

    Drawings = {}
    DrawingRoles = {}
    PrimitiveCache = {}
    CameraState = nil
    ResetBufferedTransform()
    LastValidFrameTime = 0

    if _G.NightfallChinaHatController == self then
        _G.NightfallChinaHatController = nil
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

    local Character =
        LocalPlayer.Character

    if not Character then
        HoldLastFrame()
        return
    end

    if type(DeltaTime) ~= "number" then
        DeltaTime = 0.016
    end

    DeltaTime =
        Clamp(
            DeltaTime,
            0.001,
            0.05
        )

    if ActiveCharacter ~= Character then
        ActiveCharacter = Character
        PrimitiveCache = {}
        CameraState = nil
        ResetBufferedTransform()
    end

    local PositionPart,
        OrientationPart,
        HeightFromRoot =
        GetHatParts(Character)

    if not PositionPart
        or not OrientationPart
    then
        HoldLastFrame()
        return
    end

    local State =
        ReadCameraState()

    local CurrentPosition =
        ReadPartPosition(
            PositionPart
        )

    local WorldRight,
        WorldUp,
        WorldBack =
        ReadHorizontalBasis(
            OrientationPart
        )

    if not State
        or not CurrentPosition
        or not WorldRight
    then
        HoldLastFrame()
        return
    end

    CameraState = State

    local Now =
        tick()

    QueueBufferedTransform(
        Now,
        CurrentPosition,
        State,
        WorldUp,
        WorldBack
    )

    local Position,
        Right,
        Up,
        Back =
        ReadBufferedTransform(Now)

    if not Position
        or not Right
    then
        HoldLastFrame()
        return
    end

    Position =
        Position
        + Up * HeightFromRoot

    RenderHat(
        Position,
        Right,
        Up,
        Back
    )

    LastValidFrameTime =
        Now
end)

return Controller
