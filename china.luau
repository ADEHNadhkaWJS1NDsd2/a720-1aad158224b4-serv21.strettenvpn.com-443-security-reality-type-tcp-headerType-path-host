local Game = game
local Players = Game:GetService("Players")
local RunService = Game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Clock = os.clock
local Clamp = math.clamp
local Cos = math.cos
local Sin = math.sin
local ReadMemory = memory_read
local ProjectWorld = WorldToScreen

local PrimitiveOffsets = {0x188, 0x128}
local RotationOffset = 0xC8

local Previous = _G.NightfallChinaHatController
if type(Previous) == "table" and type(Previous.Stop) == "function" then Previous:Stop() end

local HatColor = Color3.fromRGB(112, 64, 225)
local OutlineColor = Color3.fromRGB(190, 135, 255)
local Scale = 1
local Height = 0
local Radius = 1.55
local ConeHeight = 1.3
local Glow = 0.45
local Thickness = 2
local SegmentCount = 24
local SpokeStep = 2
local RenderFps = 144
local RenderInterval = 1 / RenderFps
local LastRender = Clock()

local Drawings = {}
local Roles = {}
local PrimitiveCache = {}
local ActiveCharacter = nil
local RenderConnection = nil

local Controller = {
    Version = 3,
    Running = true,
    Enabled = true,
    Color = HatColor,
    OutlineColor = OutlineColor,
    Scale = Scale,
    Height = Height,
    Radius = Radius,
    ConeHeight = ConeHeight,
    Glow = Glow,
    Thickness = Thickness
}

_G.NightfallChinaHatController = Controller

local function IsNumber(Value)
    return type(Value) == "number" and Value == Value and Value ~= math.huge and Value ~= -math.huge and math.abs(Value) < 10000000
end

local function IsVector(Value)
    return typeof(Value) == "Vector3" and IsNumber(Value.X) and IsNumber(Value.Y) and IsNumber(Value.Z)
end

local function Mix(A, B, Alpha)
    return Color3.new(A.R + (B.R - A.R) * Alpha, A.G + (B.G - A.G) * Alpha, A.B + (B.B - A.B) * Alpha)
end

local function RoleColor(Role)
    if Role == "Outline" then return OutlineColor end
    if Role == "Glow" then return Mix(OutlineColor, Color3.new(1, 1, 1), 0.22) end
    if Role == "Light" then return Mix(HatColor, Color3.new(1, 1, 1), 0.48) end
    if Role == "Shadow" then return Mix(HatColor, Color3.new(0.04, 0.02, 0.10), 0.48) end
    return HatColor
end

local function Register(Object, Role)
    Drawings[#Drawings + 1] = Object
    Roles[Object] = Role
    Object.Color = RoleColor(Role)
    return Object
end

local function NewLine(Role, Width, Transparency, ZIndex)
    local Line = Drawing.new("Line")
    Line.Thickness, Line.Transparency, Line.ZIndex, Line.Visible = Width, Transparency, ZIndex, false
    return Register(Line, Role)
end

local function NewStroke(ZIndex)
    return {
        Glow = NewLine("Glow", Thickness + 5, 0.04 + Glow * 0.16, ZIndex),
        Main = NewLine("Outline", Thickness, 0.96, ZIndex + 1)
    }
end

local OuterRing, InnerRing, MidRing, Spokes, Details = {}, {}, {}, {}, {}

for Index = 1, SegmentCount do
    OuterRing[Index] = NewStroke(20)
    InnerRing[Index] = NewLine(Index % 2 == 0 and "Core" or "Light", 1, 0.70, 18)
    MidRing[Index] = NewLine(Index % 2 == 0 and "Shadow" or "Core", 1, 0.54, 17)
end

for Index = 1, SegmentCount, SpokeStep do
    Spokes[#Spokes + 1] = NewStroke(19)
    Details[#Details + 1] = NewLine("Light", 1, 0.52, 18)
end

local function ApplyStyle()
    for Index = 1, #Drawings do
        local Object = Drawings[Index]
        Object.Color = RoleColor(Roles[Object])
    end

    for Index = 1, #OuterRing do
        OuterRing[Index].Main.Thickness = Thickness
        OuterRing[Index].Glow.Thickness = Thickness + 5
        OuterRing[Index].Glow.Transparency = 0.04 + Glow * 0.16
    end

    for Index = 1, #Spokes do
        Spokes[Index].Main.Thickness = math.max(1, Thickness - 0.5)
        Spokes[Index].Glow.Thickness = Thickness + 3
        Spokes[Index].Glow.Transparency = 0.025 + Glow * 0.12
    end
end

local function HideAll()
    for Index = 1, #Drawings do Drawings[Index].Visible = false end
end

local function Project(Position)
    if type(ProjectWorld) ~= "function" or not IsVector(Position) then return nil end
    local Point, OnScreen = ProjectWorld(Position)
    if typeof(Point) ~= "Vector2" or OnScreen == false then return nil end
    return Point
end

local function SetLine(Line, A, B)
    if not A or not B then Line.Visible = false return false end
    Line.From, Line.To, Line.Visible = A, B, true
    return true
end

local function SetStroke(Stroke, A, B)
    local Visible = SetLine(Stroke.Main, A, B)
    if Visible then SetLine(Stroke.Glow, A, B) else Stroke.Glow.Visible = false end
end

local function ReadFloat(Address)
    if type(Address) ~= "number" or Address < 0x10000 then return nil end
    local Value = ReadMemory("float", Address)
    return IsNumber(Value) and Value or nil
end

local function IsPrimitiveValid(Primitive)
    if type(Primitive) ~= "number" or Primitive < 0x10000 then return false end

    local Address = Primitive + RotationOffset
    local M00, M02 = ReadFloat(Address), ReadFloat(Address + 0x8)
    local M20, M22 = ReadFloat(Address + 0x18), ReadFloat(Address + 0x20)
    if not M00 or not M02 or not M20 or not M22 then return false end
    if math.abs(M00) > 1.25 or math.abs(M02) > 1.25 or math.abs(M20) > 1.25 or math.abs(M22) > 1.25 then return false end

    local RightLength = M00 * M00 + M20 * M20
    local BackLength = M02 * M02 + M22 * M22
    return RightLength > 0.15 and RightLength < 1.5 and BackLength > 0.15 and BackLength < 1.5
end

local function GetPrimitive(Part)
    if not Part then return 0 end

    local Cached = PrimitiveCache[Part]
    if type(Cached) == "number" and IsPrimitiveValid(Cached) then return Cached end
    PrimitiveCache[Part] = nil

    local Address = Part.Address
    if type(Address) ~= "number" or Address < 0x10000 then return 0 end

    for Index = 1, #PrimitiveOffsets do
        local Primitive = ReadMemory("uintptr_t", Address + PrimitiveOffsets[Index])
        if IsPrimitiveValid(Primitive) then
            PrimitiveCache[Part] = Primitive
            return Primitive
        end
    end

    return 0
end

local function GetBasis(Part)
    local Primitive = GetPrimitive(Part)
    if Primitive == 0 then return nil end

    local Address = Primitive + RotationOffset
    local M00, M02 = ReadFloat(Address), ReadFloat(Address + 0x8)
    local M20, M22 = ReadFloat(Address + 0x18), ReadFloat(Address + 0x20)
    if not M00 or not M02 or not M20 or not M22 then PrimitiveCache[Part] = nil return nil end

    local Up = Vector3.new(0, 1, 0)
    local Back = Vector3.new(M02, 0, M22)
    if Back.Magnitude < 0.5 then
        local Right = Vector3.new(M00, 0, M20)
        if Right.Magnitude < 0.5 then PrimitiveCache[Part] = nil return nil end
        Back = Right.Unit:Cross(Up)
    end

    if Back.Magnitude < 0.001 then return nil end
    Back = Back.Unit

    local Right = Up:Cross(Back)
    if Right.Magnitude < 0.001 then return nil end
    Right = Right.Unit
    Back = Right:Cross(Up)
    if Back.Magnitude < 0.001 then return nil end

    return Right, Up, Back.Unit
end

local function GetTransform()
    local Character = LocalPlayer and LocalPlayer.Character
    if not Character then return nil end
    if Character ~= ActiveCharacter then
        ActiveCharacter = Character
        PrimitiveCache = {}
    end

    local Head = Character:FindFirstChild("Head")
    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Upper = Character:FindFirstChild("UpperTorso")
    local Torso = Character:FindFirstChild("Torso")
    local PositionPart = Head or Upper or Torso or Root
    local OrientationPart = Root or Upper or Torso or Head
    if not PositionPart or not OrientationPart or not PositionPart:IsA("BasePart") or not OrientationPart:IsA("BasePart") then return nil end

    local Position = PositionPart.Position
    if not IsVector(Position) then return nil end

    local Right, Up, Back = GetBasis(OrientationPart)
    if not Right then return nil end
    return Position, Right, Up, Back
end

local function RingPoint(Center, Right, Back, RingRadius, HeightOffset, Angle)
    return Center + Right * (Cos(Angle) * RingRadius * Scale) + Back * (Sin(Angle) * RingRadius * Scale) + Vector3.new(0, HeightOffset * Scale, 0)
end

local function BuildRing(Center, Right, Back, RingRadius, HeightOffset)
    local Points = {}
    for Index = 1, SegmentCount do
        local Angle = (Index - 1) / SegmentCount * math.pi * 2
        Points[Index] = Project(RingPoint(Center, Right, Back, RingRadius, HeightOffset, Angle))
    end
    return Points
end

local function RenderRing(Ring, Points, Stroke)
    for Index = 1, SegmentCount do
        local Next = Index % SegmentCount + 1
        if Stroke then SetStroke(Ring[Index], Points[Index], Points[Next]) else SetLine(Ring[Index], Points[Index], Points[Next]) end
    end
end

local function RenderHat(Position, Right, Up, Back)
    local Center = Position + Up * ((0.58 + Height) * Scale)
    local Apex = Position + Up * ((0.58 + Height + ConeHeight) * Scale)
    local InnerRadius = Radius * 0.69
    local MidRadius = Radius * 0.43

    local Outer = BuildRing(Center, Right, Back, Radius, 0)
    local Inner = BuildRing(Center, Right, Back, InnerRadius, 0.02)
    local MidCenter = Center + Up * (ConeHeight * 0.48 * Scale)
    local Mid = BuildRing(MidCenter, Right, Back, MidRadius, 0)
    local ScreenApex = Project(Apex)

    RenderRing(OuterRing, Outer, true)
    RenderRing(InnerRing, Inner, false)
    RenderRing(MidRing, Mid, false)

    local SpokeIndex = 1
    for Index = 1, SegmentCount, SpokeStep do
        SetStroke(Spokes[SpokeIndex], ScreenApex, Outer[Index])
        SetLine(Details[SpokeIndex], Mid[Index], Outer[Index])
        SpokeIndex = SpokeIndex + 1
    end
end

function Controller:SetEnabled(Value)
    self.Enabled = Value == true
    if not self.Enabled then HideAll() end
end

function Controller:SetColor(Value)
    if typeof(Value) ~= "Color3" then return end
    HatColor, self.Color = Value, Value
    ApplyStyle()
end

function Controller:SetOutlineColor(Value)
    if typeof(Value) ~= "Color3" then return end
    OutlineColor, self.OutlineColor = Value, Value
    ApplyStyle()
end

function Controller:SetScale(Value)
    if type(Value) ~= "number" then return end
    Scale = Clamp(Value, 0.55, 1.8)
    self.Scale = Scale
end

function Controller:SetHeight(Value)
    if type(Value) ~= "number" then return end
    Height = Clamp(Value, -1.25, 2.5)
    self.Height = Height
end

function Controller:SetRadius(Value)
    if type(Value) ~= "number" then return end
    Radius = Clamp(Value, 0.75, 3.25)
    self.Radius = Radius
end

function Controller:SetConeHeight(Value)
    if type(Value) ~= "number" then return end
    ConeHeight = Clamp(Value, 0.7, 3.5)
    self.ConeHeight = ConeHeight
end

function Controller:SetGlow(Value)
    if type(Value) ~= "number" then return end
    Glow = Clamp(Value, 0, 1)
    self.Glow = Glow
    ApplyStyle()
end

function Controller:SetThickness(Value)
    if type(Value) ~= "number" then return end
    Thickness = Clamp(Value, 1, 4)
    self.Thickness = Thickness
    ApplyStyle()
end

function Controller:SetFps(Value)
    if type(Value) ~= "number" then return end
    RenderFps = Clamp(math.floor(Value + 0.5), 30, 240)
    RenderInterval = 1 / RenderFps
end

function Controller:GetFps()
    return RenderFps
end

function Controller:Stop()
    if not self.Running then return end
    self.Running, self.Enabled = false, false
    HideAll()

    for Index = 1, #Drawings do
        local Object = Drawings[Index]
        if Object and type(Object.Remove) == "function" then Object:Remove() end
    end

    if RenderConnection then RenderConnection:Disconnect() RenderConnection = nil end
    Drawings, Roles, PrimitiveCache, ActiveCharacter = {}, {}, {}, nil
    if _G.NightfallChinaHatController == self then _G.NightfallChinaHatController = nil end
end

ApplyStyle()

RenderConnection = RunService.RenderStepped:Connect(function()
    if not Controller.Running then return end

    local Now = Clock()
    if Now - LastRender < RenderInterval then return end
    LastRender = Now

    if not Controller.Enabled then HideAll() return end

    local Position, Right, Up, Back = GetTransform()
    if not Position then HideAll() return end
    RenderHat(Position, Right, Up, Back)
end)

return Controller
