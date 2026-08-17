local Game = game
local Players = Game:GetService("Players")
local RunService = Game:GetService("RunService")
local Workspace = Game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Clock = os.clock
local Clamp = math.clamp
local Sin = math.sin
local Cos = math.cos
local Max = math.max
local ReadMemory = memory_read
local ProjectWorld = WorldToScreen

local PrimitiveOffsets = {0x188, 0x128}
local RotationOffset = 0xC8

local Previous = _G.NightfallWingsController
if type(Previous) == "table" and type(Previous.Stop) == "function" then Previous:Stop() end

local WingColor = Color3.fromRGB(120, 60, 220)
local OutlineColor = Color3.fromRGB(185, 125, 255)
local Scale = 1.12
local Height = 0
local BackOffset = 0.72
local SwingSpeed = 1.45
local FlapStrength = 1
local Spread = 1
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
    Color = WingColor,
    OutlineColor = OutlineColor,
    Scale = Scale,
    Height = Height,
    BackOffset = BackOffset,
    SwingSpeed = SwingSpeed,
    FlapStrength = FlapStrength,
    Spread = Spread
}

_G.NightfallWingsController = Controller

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
    if Role == "Glow" then return Mix(OutlineColor, Color3.new(1, 1, 1), 0.18) end
    if Role == "Accent" then return Mix(WingColor, OutlineColor, 0.42) end
    return WingColor
end

local function Register(Object, Role)
    Drawings[#Drawings + 1] = Object
    Roles[Object] = Role
    Object.Color = RoleColor(Role)
    return Object
end

local function NewLine(Role, Thickness, Transparency, ZIndex)
    local Line = Drawing.new("Line")
    Line.Thickness, Line.Transparency, Line.ZIndex, Line.Visible = Thickness, Transparency, ZIndex, false
    return Register(Line, Role)
end

local function NewTriangle(Role, Transparency, ZIndex)
    local Triangle = Drawing.new("Triangle")
    Triangle.Transparency, Triangle.ZIndex, Triangle.Visible = Transparency, ZIndex, false
    return Register(Triangle, Role)
end

local function NewStroke(ZIndex)
    return {
        Glow = NewLine("Glow", 6, 0.08, ZIndex),
        Main = NewLine("Outline", 2, 0.96, ZIndex + 1)
    }
end

local function NewFeather(Shaft, ZIndex)
    return {
        Left = NewTriangle("Fill", 0.93, ZIndex),
        Right = NewTriangle("Accent", 0.86, ZIndex + 1),
        Shaft = Shaft and NewLine("Outline", 1, 0.64, ZIndex + 2) or nil
    }
end

local function CreateWing()
    local Wing = {Primary = {}, Secondary = {}, Coverts = {}, Outline = {}}
    for Index = 1, 7 do Wing.Primary[Index] = NewFeather(true, 4) end
    for Index = 1, 5 do Wing.Secondary[Index] = NewFeather(true, 7) end
    for Index = 1, 4 do Wing.Coverts[Index] = NewFeather(false, 10) end
    for Index = 1, 6 do Wing.Outline[Index] = NewStroke(13) end
    return Wing
end

local LeftWing = CreateWing()
local RightWing = CreateWing()

local function HideObject(Object)
    if Object then Object.Visible = false end
end

local function HideFeather(Feather)
    HideObject(Feather.Left)
    HideObject(Feather.Right)
    HideObject(Feather.Shaft)
end

local function HideAll()
    for Index = 1, #Drawings do Drawings[Index].Visible = false end
end

local function ApplyColors()
    for Index = 1, #Drawings do
        local Object = Drawings[Index]
        Object.Color = RoleColor(Roles[Object])
    end
end

local function Project(Position)
    if type(ProjectWorld) ~= "function" or not IsVector(Position) then return nil end
    local Point, OnScreen = ProjectWorld(Position)
    if typeof(Point) ~= "Vector2" or OnScreen == false then return nil end
    return Point
end

local function SetLine(Line, A, B)
    local PointA, PointB = Project(A), Project(B)
    if not PointA or not PointB then
        Line.Visible = false
        return false
    end
    Line.From, Line.To, Line.Visible = PointA, PointB, true
    return true
end

local function SetStroke(Stroke, A, B)
    local Visible = SetLine(Stroke.Main, A, B)
    if Visible then SetLine(Stroke.Glow, A, B) else Stroke.Glow.Visible = false end
end

local function DrawFeather(Feather, Root, Tip, Width, Plane, Bend)
    local Direction = Tip - Root
    if Direction.Magnitude <= 0.001 then HideFeather(Feather) return end

    local WidthDirection = Plane:Cross(Direction)
    if WidthDirection.Magnitude <= 0.001 then HideFeather(Feather) return end
    WidthDirection = WidthDirection.Unit

    local Center = Root + Direction * 0.38 + Plane * Bend
    local Left = Center + WidthDirection * Width
    local Right = Center - WidthDirection * Width
    local ScreenRoot, ScreenLeft, ScreenRight, ScreenTip = Project(Root), Project(Left), Project(Right), Project(Tip)

    if not ScreenRoot or not ScreenLeft or not ScreenRight or not ScreenTip then HideFeather(Feather) return end

    Feather.Left.PointA, Feather.Left.PointB, Feather.Left.PointC, Feather.Left.Visible = ScreenRoot, ScreenLeft, ScreenTip, true
    Feather.Right.PointA, Feather.Right.PointB, Feather.Right.PointC, Feather.Right.Visible = ScreenRoot, ScreenTip, ScreenRight, true

    if Feather.Shaft then
        Feather.Shaft.From, Feather.Shaft.To, Feather.Shaft.Visible = ScreenRoot, ScreenTip, true
    end
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

local function GetAnchor()
    local Character = LocalPlayer and LocalPlayer.Character
    if not Character then return nil end
    if Character ~= ActiveCharacter then
        ActiveCharacter = Character
        PrimitiveCache = {}
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    local Upper = Character:FindFirstChild("UpperTorso")
    local Torso = Character:FindFirstChild("Torso")
    local Anchor = Root or Upper or Torso
    if not Anchor or not Anchor:IsA("BasePart") then return nil end

    local Position = Anchor.Position
    if not IsVector(Position) then return nil end

    local Right, Up, Back = GetBasis(Root or Anchor)
    if not Right then return nil end

    local R6 = Torso ~= nil and Upper == nil
    return Position, Right, Up, Back, R6
end

local function BuildPoints(Origin, Side, Up, Back, Flap)
    local Span = Spread * Scale
    local Raised = Max(Flap, 0)
    local Root = Origin + Side * (0.42 * Scale)
    local Shoulder = Origin + Side * (1.18 * Span) + Up * ((0.72 + Flap * 0.16) * Scale)
    local Elbow = Origin + Side * ((2.55 - Raised * 0.28) * Span) + Up * ((2.55 + Flap * 0.58) * Scale) + Back * (0.18 * Scale)
    local Wrist = Origin + Side * ((4.05 - Raised * 0.52) * Span) + Up * ((2.05 + Flap * 0.88) * Scale) + Back * ((0.36 + Raised * 0.22) * Scale)
    local Outer = Origin + Side * ((5.35 - Raised * 0.76) * Span) + Up * ((0.96 + Flap * 1.12) * Scale) + Back * ((0.58 + Raised * 0.34) * Scale)
    local Lower = Origin + Side * (4.18 * Span) - Up * ((0.54 - Flap * 0.22) * Scale) + Back * (0.58 * Scale)
    local Inner = Origin + Side * (1.72 * Span) - Up * (0.48 * Scale) + Back * (0.24 * Scale)
    return {Root = Root, Shoulder = Shoulder, Elbow = Elbow, Wrist = Wrist, Outer = Outer, Lower = Lower, Inner = Inner}
end

local Primary = {LengthA = 1.95, LengthB = 3.05, DropA = 0.42, DropB = 1.64, DepthA = 0.16, DepthB = 0.42, WidthA = 0.34, WidthB = 0.21, BendA = 0.04, BendB = 0.17}
local Secondary = {LengthA = 1.35, LengthB = 2.18, DropA = 0.26, DropB = 1.08, DepthA = 0.11, DepthB = 0.30, WidthA = 0.31, WidthB = 0.20, BendA = 0.03, BendB = 0.13}
local Coverts = {LengthA = 0.78, LengthB = 1.34, DropA = 0.12, DropB = 0.56, DepthA = 0.08, DepthB = 0.20, WidthA = 0.26, WidthB = 0.17, BendA = 0.02, BendB = 0.09}

local function Lerp(A, B, Alpha)
    return A + (B - A) * Alpha
end

local function RenderLayer(Feathers, StartPoint, EndPoint, Side, Up, Back, Time, Flap, Config)
    local Count = #Feathers
    for Index = 1, Count do
        local Alpha = Count > 1 and (Index - 1) / (Count - 1) or 0
        local Root = StartPoint:Lerp(EndPoint, Alpha)
        local Wave = Sin(Time * SwingSpeed * 3.8 - Alpha * 0.72 - Index * 0.11) * 0.10 * FlapStrength
        local Length = Lerp(Config.LengthA, Config.LengthB, Alpha)
        local Drop = Lerp(Config.DropA, Config.DropB, Alpha)
        local Depth = Lerp(Config.DepthA, Config.DepthB, Alpha)
        local Width = Lerp(Config.WidthA, Config.WidthB, Alpha)
        local Bend = Lerp(Config.BendA, Config.BendB, Alpha)
        local Tip = Root + Side * ((Length + Wave) * Spread * Scale) - Up * ((Drop - Flap * Alpha * 0.38) * Scale) + Back * ((Depth + Wave * 0.35) * Scale)
        DrawFeather(Feathers[Index], Root, Tip, Width * Scale, Back, Bend * Scale)
    end
end

local function RenderWing(Wing, Origin, Side, Up, Back, Time, Flap)
    local Points = BuildPoints(Origin, Side, Up, Back, Flap)
    RenderLayer(Wing.Primary, Points.Elbow, Points.Wrist, Side, Up, Back, Time, Flap, Primary)
    RenderLayer(Wing.Secondary, Points.Shoulder, Points.Elbow, Side, Up, Back, Time, Flap, Secondary)
    RenderLayer(Wing.Coverts, Points.Root, Points.Shoulder, Side, Up, Back, Time, Flap, Coverts)

    SetStroke(Wing.Outline[1], Points.Root, Points.Shoulder)
    SetStroke(Wing.Outline[2], Points.Shoulder, Points.Elbow)
    SetStroke(Wing.Outline[3], Points.Elbow, Points.Wrist)
    SetStroke(Wing.Outline[4], Points.Wrist, Points.Outer)
    SetStroke(Wing.Outline[5], Points.Outer, Points.Lower)
    SetStroke(Wing.Outline[6], Points.Lower, Points.Inner)
end

function Controller:SetEnabled(Value)
    self.Enabled = Value == true
    if not self.Enabled then HideAll() end
end

function Controller:SetColor(Value)
    if typeof(Value) ~= "Color3" then return end
    WingColor, self.Color = Value, Value
    ApplyColors()
end

function Controller:SetOutlineColor(Value)
    if typeof(Value) ~= "Color3" then return end
    OutlineColor, self.OutlineColor = Value, Value
    ApplyColors()
end

function Controller:SetScale(Value)
    if type(Value) ~= "number" then return end
    Scale = Clamp(Value, 0.55, 2.25)
    self.Scale = Scale
end

function Controller:SetHeight(Value)
    if type(Value) ~= "number" then return end
    Height = Clamp(Value, -2, 2.5)
    self.Height = Height
end

function Controller:SetBackOffset(Value)
    if type(Value) ~= "number" then return end
    BackOffset = Clamp(Value, 0, 2)
    self.BackOffset = BackOffset
end

function Controller:SetSwingSpeed(Value)
    if type(Value) ~= "number" then return end
    SwingSpeed = Clamp(Value, 0.1, 6)
    self.SwingSpeed = SwingSpeed
end

function Controller:SetFlapStrength(Value)
    if type(Value) ~= "number" then return end
    FlapStrength = Clamp(Value, 0.2, 2)
    self.FlapStrength = FlapStrength
end

function Controller:SetSpread(Value)
    if type(Value) ~= "number" then return end
    Spread = Clamp(Value, 0.6, 1.6)
    self.Spread = Spread
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
    if _G.NightfallWingsController == self then _G.NightfallWingsController = nil end
end

ApplyColors()

RenderConnection = RunService.RenderStepped:Connect(function()
    if not Controller.Running then return end

    local Now = Clock()
    if Now - LastRender < RenderInterval then return end
    LastRender = Now

    if not Controller.Enabled then HideAll() return end

    local Position, Right, Up, Back, R6 = GetAnchor()
    if not Position then HideAll() return end

    local BaseHeight = R6 and 1.05 or 1.18
    local Origin = Position + Up * ((BaseHeight + Height) * Scale) - Back * (BackOffset * Scale)
    local Flap = Sin(Now * SwingSpeed * 3.35) * FlapStrength

    RenderWing(LeftWing, Origin, -Right, Up, Back, Now, Flap)
    RenderWing(RightWing, Origin, Right, Up, Back, Now + 0.04, Flap)
end)

return Controller
