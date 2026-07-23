local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local BasePartPrimitiveOffset = 0x128
local PrimitiveRotationOffset = 0xC8
local PrimitivePositionOffset = 0xEC

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
local StableBack = nil

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
    local PrimitiveAddress =
        GetPrimitiveAddress(Part)

    if PrimitiveAddress == 0 then
        return nil
    end

    local Position =
        ReadVector3(
            PrimitiveAddress
            + PrimitivePositionOffset
        )

    if not IsValidVector(Position) then
        PrimitiveCache[Part] = nil
        return nil
    end

    return Position
end

local function ReadHorizontalBasis(RootPart)
    local PrimitiveAddress =
        GetPrimitiveAddress(RootPart)

    if PrimitiveAddress == 0 then
        return nil
    end

    local RotationAddress =
        PrimitiveAddress
        + PrimitiveRotationOffset

    local M02 =
        ReadFloat(
            RotationAddress + 0x8
        )

    local M12 =
        ReadFloat(
            RotationAddress + 0x14
        )

    local M22 =
        ReadFloat(
            RotationAddress + 0x20
        )

    if not IsValidNumber(M02)
        or not IsValidNumber(M12)
        or not IsValidNumber(M22)
    then
        PrimitiveCache[RootPart] = nil
        return nil
    end

    local BackRaw =
        Vector3.new(
            M02,
            M12,
            M22
        )

    local Back =
        Vector3.new(
            BackRaw.X,
            0,
            BackRaw.Z
        )

    if Back.Magnitude < 0.5 then
        return nil
    end

    Back = Back.Unit

    if StableBack
        and Back:Dot(StableBack) < -0.85
    then
        Back = -Back
    end

    StableBack = Back

    local Up =
        Vector3.new(0, 1, 0)

    local Right =
        Up:Cross(Back)

    if Right.Magnitude < 0.5 then
        return nil
    end

    Right = Right.Unit
    Back = Right:Cross(Up).Unit

    return Right, Up, Back
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
    StableBack = nil

    if _G.NightfallChinaHatController == self then
        _G.NightfallChinaHatController = nil
    end
end

RunService.RenderStepped:Connect(function()
    if not Controller.Running then
        return
    end

    if not Controller.Enabled then
        return
    end

    Camera = Workspace.CurrentCamera

    local Character =
        LocalPlayer.Character

    if not Character or not Camera then
        HideAll()
        return
    end

    if ActiveCharacter ~= Character then
        ActiveCharacter = Character
        PrimitiveCache = {}
        StableBack = nil
    end

    local Head, OrientationPart, IsR6 =
        GetCharacterParts(Character)

    if not Head or not OrientationPart then
        HideAll()
        return
    end

    local Right, Up, Back =
        ReadHorizontalBasis(OrientationPart)

    if not Right then
        HideAll()
        return
    end

    local HeadPosition = nil

    if IsR6 then
        local TorsoPosition =
            ReadPartPosition(OrientationPart)

        if TorsoPosition then
            HeadPosition =
                TorsoPosition
                + Up * 1.5
        end
    else
        HeadPosition =
            ReadPartPosition(Head)
    end

    if not HeadPosition then
        HideAll()
        return
    end

    RenderHat(
        HeadPosition,
        Right,
        Up,
        Back
    )
end)

return Controller
