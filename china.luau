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
local SmoothedPosition = nil
local SmoothedBack = nil

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

local function ReadPartVelocity(Part)
    local Success, Velocity =
        pcall(function()
            return Part.AssemblyLinearVelocity
        end)

    if Success
        and typeof(Velocity) == "Vector3"
        and IsValidVector(Velocity)
    then
        return Velocity
    end

    Success, Velocity =
        pcall(function()
            return Part.Velocity
        end)

    if Success
        and typeof(Velocity) == "Vector3"
        and IsValidVector(Velocity)
    then
        return Velocity
    end

    return Vector3.zero
end

local function ReadPartTransform(
    Part,
    DeltaTime
)
    local PrimitiveAddress =
        GetPrimitiveAddress(Part)

    if PrimitiveAddress == 0 then
        return nil
    end

    local PositionA =
        ReadPartPosition(Part)

    if not PositionA then
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

    local M10 =
        ReadFloat(
            RotationAddress + 0xC
        )

    local M12 =
        ReadFloat(
            RotationAddress + 0x14
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
        or not IsValidNumber(M10)
        or not IsValidNumber(M12)
        or not IsValidNumber(M20)
        or not IsValidNumber(M22)
    then
        PrimitiveCache[Part] = nil
        return nil
    end

    local PositionB =
        ReadPartPosition(Part)

    if not PositionB
        or (
            PositionB
            - PositionA
        ).Magnitude > 2
    then
        return nil
    end

    local CurrentPosition =
        (
            PositionA
            + PositionB
        ) * 0.5

    local Velocity =
        ReadPartVelocity(Part)

    local TargetPosition =
        CurrentPosition
        + Velocity * 0.012

    local Back =
        Vector3.new(
            M02,
            0,
            M22
        )

    local RightRaw =
        Vector3.new(
            M00,
            M10,
            M20
        )

    local Up =
        Vector3.new(0, 1, 0)

    if Back.Magnitude < 0.5 then
        local RightFallback =
            Vector3.new(
                RightRaw.X,
                0,
                RightRaw.Z
            )

        if RightFallback.Magnitude < 0.5 then
            PrimitiveCache[Part] = nil
            return nil
        end

        local Right =
            RightFallback.Unit

        Back =
            Right:Cross(Up)

        if Back.Magnitude < 0.5 then
            PrimitiveCache[Part] = nil
            return nil
        end

        Back = Back.Unit
    else
        Back = Back.Unit
    end

    if SmoothedBack
        and Back:Dot(SmoothedBack) < 0
    then
        Back = -Back
    end

    local PositionAlpha =
        Clamp(
            DeltaTime * 42,
            0,
            1
        )

    local RotationAlpha =
        Clamp(
            DeltaTime * 32,
            0,
            1
        )

    if not SmoothedPosition
        or (
            TargetPosition
            - SmoothedPosition
        ).Magnitude > 12
    then
        SmoothedPosition =
            TargetPosition
    else
        SmoothedPosition =
            SmoothedPosition:Lerp(
                TargetPosition,
                PositionAlpha
            )
    end

    if not SmoothedBack then
        SmoothedBack = Back
    else
        local MixedBack =
            SmoothedBack:Lerp(
                Back,
                RotationAlpha
            )

        if MixedBack.Magnitude < 0.001 then
            SmoothedBack = Back
        else
            SmoothedBack =
                MixedBack.Unit
        end
    end

    local Right =
        Up:Cross(SmoothedBack)

    if Right.Magnitude < 0.001 then
        return nil
    end

    Right = Right.Unit

    local StableBack =
        Right:Cross(Up)

    if StableBack.Magnitude < 0.001 then
        return nil
    end

    StableBack = StableBack.Unit
    SmoothedBack = StableBack

    return {
        Position = SmoothedPosition,
        Right = Right,
        Up = Up,
        Back = StableBack
    }
end

local function GetCharacterParts(Character)
    local Head =
        Character:FindFirstChild(
            "Head"
        )

    if Head then
        return Head
    end

    return Character:FindFirstChild(
        "HumanoidRootPart"
    ) or Character.PrimaryPart
end

local function GetCharacterParts(Character)
    local Head =
        Character:FindFirstChild("Head")

    local UpperTorso =
        Character:FindFirstChild("UpperTorso")

    local Torso =
        Character:FindFirstChild("Torso")

    if Torso and not UpperTorso then
        return Head, Torso, true
    end

    local RootPart =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )
        or Character.PrimaryPart

    return Head, RootPart, false
end

local function ProjectPoint(WorldPoint)
    local ScreenPoint, Visible =
        WorldToScreen(WorldPoint)

    if not Visible then
        return nil
    end

    return ScreenPoint
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
    SmoothedPosition = nil
    SmoothedBack = nil

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

    Camera = Workspace.CurrentCamera

    local Character =
        LocalPlayer.Character

    if not Character or not Camera then
        HideAll()
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
        SmoothedPosition = nil
        SmoothedBack = nil
    end

    local AnchorPart =
        GetCharacterParts(Character)

    if not AnchorPart then
        HideAll()
        return
    end

    local Transform =
        ReadPartTransform(
            AnchorPart,
            DeltaTime
        )

    if not Transform then
        HideAll()
        return
    end

    RenderHat(
        Transform.Position,
        Transform.Right,
        Transform.Up,
        Transform.Back
    )
end)

return Controller
