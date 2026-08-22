local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local MemoryRead = memory_read
local Type = type
local TypeOf = typeof
local Clamp = math.clamp
local Floor = math.floor
local Sin = math.sin
local Cos = math.cos
local Tan = math.tan
local Rad = math.rad
local Pi = math.pi
local Clock = os.clock
local Tick = tick
local NewVector2 = Vector2.new
local NewVector3 = Vector3.new
local NewRGB = Color3.fromRGB
local NewColor = Color3.new

local PrimitiveOffset = 0x188
local RotationOffset = 0xC8
local MinimumAddress = 0x100000000
local HornSegments = 8
local TailSegments = 16

local Previous = _G.NightfallDemonController
if Type(Previous) == "table" and Type(Previous.Stop) == "function" then Previous:Stop() end

local State = {
    Enabled = false,
    Horns = false,
    Tail = false,
    HornsColor = NewRGB(120, 60, 220),
    HornsOutline = NewRGB(190, 135, 255),
    HornsScale = 1,
    HornsHeight = 0,
    HornsSpread = 1,
    TailColor = NewRGB(120, 60, 220),
    TailOutline = NewRGB(190, 135, 255),
    TailScale = 1,
    TailLength = 4.8,
    TailSpeed = 2.4,
    TailStrength = 1,
    Thickness = 1,
    Fps = 144
}

local Controller = {
    Version = 1,
    Running = true,
    Enabled = false,
    State = State
}

_G.NightfallDemonController = Controller

local Drawings = {}
local Roles = {}
local Widths = {}
local Primitives = {}
local TailDrawings

local function AddDrawing(Object, Role, Width)
    Drawings[#Drawings + 1] = Object
    Roles[Object] = Role
    if Width then Widths[Object] = Width end
    return Object
end

local function CreateLine(Role, Width, Transparency, ZIndex)
    local Line = Drawing.new("Line")
    Line.Thickness = Width * State.Thickness
    Line.Transparency = Transparency
    Line.ZIndex = ZIndex
    Line.Visible = false
    return AddDrawing(Line, Role, Width)
end

local function CreateTriangle(Role, Transparency, ZIndex)
    local Triangle = Drawing.new("Triangle")
    Triangle.Transparency = Transparency
    Triangle.ZIndex = ZIndex
    Triangle.Filled = true
    Triangle.Visible = false
    return AddDrawing(Triangle, Role)
end

local function SetLine(Line, From, To)
    if not From or not To then
        Line.Visible = false
        return
    end

    Line.From = From
    Line.To = To
    Line.Visible = true
end

local function SetTriangle(Triangle, A, B, C)
    if not A or not B or not C then
        Triangle.Visible = false
        return
    end

    Triangle.PointA = A
    Triangle.PointB = B
    Triangle.PointC = C
    Triangle.Visible = true
end

local function HideAll()
    for Index = 1, #Drawings do Drawings[Index].Visible = false end
end

local function HideHorn(Horn)
    for Segment = 1, HornSegments do
        for Rail = 1, 4 do Horn.Rails[Rail][Segment].Visible = false end
        for Edge = 1, 4 do Horn.Rings[Segment][Edge].Visible = false end
    end
end

local function HideTail()
    for Segment = 1, TailSegments do
        for Rail = 1, 4 do TailDrawings.Rails[Rail][Segment].Visible = false end
        for Edge = 1, 4 do TailDrawings.Rings[Segment][Edge].Visible = false end
    end

    for Index = 1, 4 do TailDrawings.TipFaces[Index].Visible = false end
    for Index = 1, 5 do TailDrawings.TipLines[Index].Visible = false end
end

local function Lighten(Color, Amount)
    return NewColor(
        Clamp(Color.R * Amount, 0, 1),
        Clamp(Color.G * Amount, 0, 1),
        Clamp(Color.B * Amount, 0, 1)
    )
end

local function RefreshColors()
    local HornLight = Lighten(State.HornsColor, 1.3)
    local TailLight = Lighten(State.TailColor, 1.3)

    for Object, Role in pairs(Roles) do
        if Role == "Horns" then Object.Color = State.HornsColor
        elseif Role == "HornsLight" then Object.Color = HornLight
        elseif Role == "HornsOutline" then Object.Color = State.HornsOutline
        elseif Role == "Tail" then Object.Color = State.TailColor
        elseif Role == "TailLight" then Object.Color = TailLight
        elseif Role == "TailOutline" then Object.Color = State.TailOutline
        end
    end
end

local function CreateHorn()
    local Horn = {Rails = {}, Rings = {}}

    for Rail = 1, 4 do
        Horn.Rails[Rail] = {}
        for Segment = 1, HornSegments do
            local Role = Rail == 1 and "HornsOutline" or Rail == 2 and "HornsLight" or "Horns"
            local Width = Rail == 1 and 2 or 1
            Horn.Rails[Rail][Segment] = CreateLine(Role, Width, Rail == 1 and 0.98 or 0.72, 22 + Rail)
        end
    end

    for Segment = 1, HornSegments do
        Horn.Rings[Segment] = {}
        for Edge = 1, 4 do
            Horn.Rings[Segment][Edge] = CreateLine(Edge == 1 and "HornsLight" or "Horns", 1, 0.58, 21)
        end
    end

    return Horn
end

local LeftHorn = CreateHorn()
local RightHorn = CreateHorn()

TailDrawings = {Rails = {}, Rings = {}, TipFaces = {}, TipLines = {}}

for Rail = 1, 4 do
    TailDrawings.Rails[Rail] = {}
    for Segment = 1, TailSegments do
        local Role = Rail == 1 and "TailOutline" or Rail == 2 and "TailLight" or "Tail"
        local Width = Rail == 1 and 2.2 or 1.2
        TailDrawings.Rails[Rail][Segment] = CreateLine(Role, Width, Rail == 1 and 0.98 or 0.75, 17 + Rail)
    end
end

for Segment = 1, TailSegments do
    TailDrawings.Rings[Segment] = {}
    for Edge = 1, 4 do
        TailDrawings.Rings[Segment][Edge] = CreateLine(Edge == 1 and "TailLight" or "Tail", 1, 0.58, 16)
    end
end

for Index = 1, 4 do
    TailDrawings.TipFaces[Index] = CreateTriangle(Index % 2 == 0 and "TailLight" or "Tail", 0.92, 25)
end

for Index = 1, 5 do
    TailDrawings.TipLines[Index] = CreateLine("TailOutline", 2, 0.98, 26)
end

RefreshColors()

local function ReadFloat(Address)
    if Type(MemoryRead) ~= "function" or Type(Address) ~= "number" or Address < MinimumAddress then return nil end
    local Value = MemoryRead("float", Address)
    if Type(Value) ~= "number" or Value ~= Value or Value == math.huge or Value == -math.huge then return nil end
    return Value
end

local function GetPrimitive(Part)
    local Cached = Primitives[Part]
    if Cached and Cached >= MinimumAddress then return Cached end

    local Address = Part and Part.Address
    if Type(Address) ~= "number" or Address < MinimumAddress or Type(MemoryRead) ~= "function" then return nil end

    local Primitive = MemoryRead("uintptr_t", Address + PrimitiveOffset)
    if Type(Primitive) ~= "number" or Primitive < MinimumAddress then return nil end

    Primitives[Part] = Primitive
    return Primitive
end

local function GetBasis(Part)
    local Primitive = GetPrimitive(Part)
    if not Primitive then return nil end

    local Rotation = Primitive + RotationOffset
    local M00 = ReadFloat(Rotation)
    local M02 = ReadFloat(Rotation + 0x08)
    local M20 = ReadFloat(Rotation + 0x18)
    local M22 = ReadFloat(Rotation + 0x20)
    if not M00 or not M02 or not M20 or not M22 then
        Primitives[Part] = nil
        return nil
    end

    local Up = NewVector3(0, 1, 0)
    local Back = NewVector3(M02, 0, M22)

    if Back.Magnitude < 0.5 then
        local Right = NewVector3(M00, 0, M20)
        if Right.Magnitude < 0.5 then return nil end
        Back = Right.Unit:Cross(Up)
    end

    if Back.Magnitude < 0.5 then return nil end
    Back = Back.Unit

    local Right = Up:Cross(Back)
    if Right.Magnitude < 0.001 then return nil end

    Right = Right.Unit
    Back = Right:Cross(Up).Unit
    return Right, Up, Back
end

local function GetCamera()
    local Camera = Workspace.CurrentCamera
    if not Camera then return nil end

    local CFrame = Camera.CFrame
    local Viewport = Camera.ViewportSize
    local FieldOfView = Camera.FieldOfView
    if TypeOf(CFrame) ~= "CFrame" or TypeOf(Viewport) ~= "Vector2" or Type(FieldOfView) ~= "number" then return nil end
    if Viewport.X <= 0 or Viewport.Y <= 0 or FieldOfView <= 1 or FieldOfView >= 179 then return nil end

    return {
        Position = CFrame.Position,
        Right = CFrame.RightVector,
        Up = CFrame.UpVector,
        Look = CFrame.LookVector,
        CenterX = Viewport.X * 0.5,
        CenterY = Viewport.Y * 0.5,
        Width = Viewport.X,
        Height = Viewport.Y,
        Focal = Viewport.Y / (2 * Tan(Rad(FieldOfView) * 0.5))
    }
end

local function Project(Position, Camera)
    if not Position or not Camera then return nil end

    local Delta = Position - Camera.Position
    local X = Delta:Dot(Camera.Right)
    local Y = Delta:Dot(Camera.Up)
    local Z = Delta:Dot(Camera.Look)
    if Z <= 0.03 then return nil end

    local ScreenX = Camera.CenterX + X / Z * Camera.Focal
    local ScreenY = Camera.CenterY - Y / Z * Camera.Focal
    if ScreenX < -200 or ScreenY < -200 or ScreenX > Camera.Width + 200 or ScreenY > Camera.Height + 200 then return nil end

    return NewVector2(ScreenX, ScreenY)
end

local function GetRig()
    local Character = LocalPlayer.Character
    if not Character then return nil end

    local Head = Character:FindFirstChild("Head")
    local Torso =
        Character:FindFirstChild("LowerTorso")
        or Character:FindFirstChild("Torso")
        or Character:FindFirstChild("HumanoidRootPart")

    if not Head or not Torso then return nil end
    return Head, Torso
end

local function BuildHorn(Base, Forward, Up, Right, Side)
    local Points = {}
    local Scale = State.HornsScale
    local Spread = State.HornsSpread
    local Sign = Side and 1 or -1

    for Segment = 0, HornSegments do
        local Alpha = Segment / HornSegments
        local Out = Sin(Alpha * 1.8) * 1.15 * Sign * Scale * Spread
        local Rise = (Alpha * 1.65 - Alpha ^ 2.2 * 0.45) * Scale
        local Back = -(Alpha ^ 1.8) * 1.1 * Scale
        local Center =
            Base
            + Right * (0.42 * Sign * Scale * Spread + Out)
            + Up * (0.35 * Scale + Rise)
            + Forward * (0.1 * Scale + Back)

        local Radius = (1 - Alpha) * 0.24 * Scale
        Points[Segment] = {
            Top = Center + Up * Radius,
            Right = Center + Right * Radius * 0.85,
            Bottom = Center - Up * Radius * 0.85,
            Left = Center - Right * Radius * 0.85
        }
    end

    return Points
end

local function BuildTail(Base, Back, Up, Right, Time)
    local Length = State.TailLength * State.TailScale / TailSegments
    local Speed = Time * State.TailSpeed
    local Strength = State.TailStrength * State.TailScale
    local Spine = {[0] = Base}
    local Position = Base
    local Direction = (Back * 0.9 - Up * 0.45).Unit

    for Segment = 1, TailSegments do
        local Alpha = Segment / TailSegments
        local Sway = Sin(Speed - Alpha * 3.4) * (0.28 + Alpha * 0.65) * Strength
        local Lift = Cos(Speed * 0.85 - Alpha * 2.6) * (0.15 + Alpha * 0.35) * Strength
        local Arch = Sin(Alpha * Pi) * 0.38 * State.TailScale
        local Step = (Direction + Right * Sway + Up * (Lift + Arch * 0.15)).Unit

        Position = Position + Step * Length
        Spine[Segment] = Position
    end

    local Nodes = {}

    for Segment = 0, TailSegments do
        local Alpha = Segment / TailSegments
        local Tangent

        if Segment == 0 then Tangent = (Spine[1] - Spine[0]).Unit
        elseif Segment == TailSegments then Tangent = (Spine[TailSegments] - Spine[TailSegments - 1]).Unit
        else Tangent = (Spine[Segment + 1] - Spine[Segment - 1]).Unit end

        local Normal = Up - Tangent * Up:Dot(Tangent)
        Normal = Normal.Magnitude < 0.001 and Up or Normal.Unit

        local Binormal = Tangent:Cross(Normal)
        if Binormal.Magnitude < 0.001 then Binormal = Right else Binormal = Binormal.Unit end

        local Radius = math.max((1 - Alpha * 0.88) * 0.35 * State.TailScale, 0.04)
        local Center = Spine[Segment]

        Nodes[Segment] = {
            Center = Center,
            Top = Center + Normal * Radius * 1.3,
            Right = Center + Binormal * Radius,
            Bottom = Center - Normal * Radius * 0.9,
            Left = Center - Binormal * Radius,
            Tangent = Tangent,
            Normal = Normal,
            Binormal = Binormal
        }
    end

    return Nodes
end

local function DrawHorn(Horn, Points, Camera)
    for Segment = 1, HornSegments do
        local A = Points[Segment - 1]
        local B = Points[Segment]

        local ATop = Project(A.Top, Camera)
        local ARight = Project(A.Right, Camera)
        local ABottom = Project(A.Bottom, Camera)
        local ALeft = Project(A.Left, Camera)
        local BTop = Project(B.Top, Camera)
        local BRight = Project(B.Right, Camera)
        local BBottom = Project(B.Bottom, Camera)
        local BLeft = Project(B.Left, Camera)

        SetLine(Horn.Rails[1][Segment], ATop, BTop)
        SetLine(Horn.Rails[2][Segment], ARight, BRight)
        SetLine(Horn.Rails[3][Segment], ABottom, BBottom)
        SetLine(Horn.Rails[4][Segment], ALeft, BLeft)

        SetLine(Horn.Rings[Segment][1], BTop, BRight)
        SetLine(Horn.Rings[Segment][2], BRight, BBottom)
        SetLine(Horn.Rings[Segment][3], BBottom, BLeft)
        SetLine(Horn.Rings[Segment][4], BLeft, BTop)
    end
end

local function DrawTail(Nodes, Camera)
    for Segment = 1, TailSegments do
        local A = Nodes[Segment - 1]
        local B = Nodes[Segment]

        local ATop = Project(A.Top, Camera)
        local ARight = Project(A.Right, Camera)
        local ABottom = Project(A.Bottom, Camera)
        local ALeft = Project(A.Left, Camera)
        local BTop = Project(B.Top, Camera)
        local BRight = Project(B.Right, Camera)
        local BBottom = Project(B.Bottom, Camera)
        local BLeft = Project(B.Left, Camera)

        SetLine(TailDrawings.Rails[1][Segment], ATop, BTop)
        SetLine(TailDrawings.Rails[2][Segment], ARight, BRight)
        SetLine(TailDrawings.Rails[3][Segment], ABottom, BBottom)
        SetLine(TailDrawings.Rails[4][Segment], ALeft, BLeft)

        SetLine(TailDrawings.Rings[Segment][1], BTop, BRight)
        SetLine(TailDrawings.Rings[Segment][2], BRight, BBottom)
        SetLine(TailDrawings.Rings[Segment][3], BBottom, BLeft)
        SetLine(TailDrawings.Rings[Segment][4], BLeft, BTop)
    end

    local Tip = Nodes[TailSegments]
    local Scale = 0.95 * State.TailScale
    local Apex = Tip.Center + Tip.Tangent * 1.2 * Scale
    local Right = Tip.Center + Tip.Binormal * 0.65 * Scale - Tip.Tangent * 0.2 * Scale
    local Left = Tip.Center - Tip.Binormal * 0.65 * Scale - Tip.Tangent * 0.2 * Scale
    local Top = Tip.Center + Tip.Normal * 0.22 * Scale
    local Bottom = Tip.Center - Tip.Normal * 0.22 * Scale

    local Base2D = Project(Tip.Center, Camera)
    local Apex2D = Project(Apex, Camera)
    local Right2D = Project(Right, Camera)
    local Left2D = Project(Left, Camera)
    local Top2D = Project(Top, Camera)
    local Bottom2D = Project(Bottom, Camera)

    SetTriangle(TailDrawings.TipFaces[1], Base2D, Right2D, Apex2D)
    SetTriangle(TailDrawings.TipFaces[2], Base2D, Apex2D, Left2D)
    SetTriangle(TailDrawings.TipFaces[3], Base2D, Top2D, Apex2D)
    SetTriangle(TailDrawings.TipFaces[4], Base2D, Apex2D, Bottom2D)

    SetLine(TailDrawings.TipLines[1], Base2D, Right2D)
    SetLine(TailDrawings.TipLines[2], Right2D, Apex2D)
    SetLine(TailDrawings.TipLines[3], Apex2D, Left2D)
    SetLine(TailDrawings.TipLines[4], Left2D, Base2D)
    SetLine(TailDrawings.TipLines[5], Top2D, Apex2D)
end

local LastRender = 0
local RenderInterval = 1 / State.Fps
local RenderConnection

RenderConnection = RunService.RenderStepped:Connect(function()
    if not Controller.Running then return end

    local Now = Clock()
    if Now - LastRender < RenderInterval then return end
    LastRender = Now

    if not Controller.Enabled or not State.Enabled or not State.Horns and not State.Tail then
        HideAll()
        return
    end

    local Head, Torso = GetRig()
    if not Head or not Torso then
        HideAll()
        return
    end

    local HeadRight, HeadUp, HeadBack = GetBasis(Head)
    local TorsoRight, TorsoUp, TorsoBack = GetBasis(Torso)
    local Camera = GetCamera()
    if not HeadRight or not TorsoRight or not Camera then
        HideAll()
        return
    end

    if State.Horns then
        local Base = Head.Position + HeadUp * (0.75 * State.HornsScale + State.HornsHeight)
        DrawHorn(LeftHorn, BuildHorn(Base, -HeadBack, HeadUp, HeadRight, false), Camera)
        DrawHorn(RightHorn, BuildHorn(Base, -HeadBack, HeadUp, HeadRight, true), Camera)
    else
        HideHorn(LeftHorn)
        HideHorn(RightHorn)
    end

    if State.Tail then
        local Base = Torso.Position + TorsoBack * (0.65 * State.TailScale) - TorsoUp * (0.55 * State.TailScale)
        DrawTail(BuildTail(Base, TorsoBack, TorsoUp, TorsoRight, Tick()), Camera)
    else
        HideTail()
    end
end)

function Controller:SetEnabled(Value)
    self.Enabled = Value == true
    State.Enabled = self.Enabled
    if not self.Enabled then HideAll() end
end

function Controller:SetHorns(Value)
    State.Horns = Value == true
    if not State.Horns then
        HideHorn(LeftHorn)
        HideHorn(RightHorn)
    end
end

function Controller:SetTail(Value)
    State.Tail = Value == true
    if not State.Tail then HideTail() end
end

function Controller:SetHornsColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    State.HornsColor = Value
    RefreshColors()
end

function Controller:SetHornsOutline(Value)
    if TypeOf(Value) ~= "Color3" then return end
    State.HornsOutline = Value
    RefreshColors()
end

function Controller:SetHornsScale(Value)
    if Type(Value) ~= "number" then return end
    State.HornsScale = Clamp(Value, 0.4, 2.5)
end

function Controller:SetHornsHeight(Value)
    if Type(Value) ~= "number" then return end
    State.HornsHeight = Clamp(Value, -1.5, 2)
end

function Controller:SetHornsSpread(Value)
    if Type(Value) ~= "number" then return end
    State.HornsSpread = Clamp(Value, 0.5, 1.8)
end

function Controller:SetTailColor(Value)
    if TypeOf(Value) ~= "Color3" then return end
    State.TailColor = Value
    RefreshColors()
end

function Controller:SetTailOutline(Value)
    if TypeOf(Value) ~= "Color3" then return end
    State.TailOutline = Value
    RefreshColors()
end

function Controller:SetTailScale(Value)
    if Type(Value) ~= "number" then return end
    State.TailScale = Clamp(Value, 0.4, 2.5)
end

function Controller:SetTailLength(Value)
    if Type(Value) ~= "number" then return end
    State.TailLength = Clamp(Value, 2.5, 8)
end

function Controller:SetTailSpeed(Value)
    if Type(Value) ~= "number" then return end
    State.TailSpeed = Clamp(Value, 0.2, 6)
end

function Controller:SetTailStrength(Value)
    if Type(Value) ~= "number" then return end
    State.TailStrength = Clamp(Value, 0.1, 2.5)
end

function Controller:SetThickness(Value)
    if Type(Value) ~= "number" then return end
    State.Thickness = Clamp(Value, 0.5, 3)

    for Object, Width in pairs(Widths) do Object.Thickness = Width * State.Thickness end
end

function Controller:SetFps(Value)
    if Type(Value) ~= "number" then return end
    State.Fps = Clamp(Floor(Value + 0.5), 30, 240)
    RenderInterval = 1 / State.Fps
end

function Controller:Stop()
    if not self.Running then return end

    self.Running = false
    self.Enabled = false
    State.Enabled = false

    if RenderConnection then
        RenderConnection:Disconnect()
        RenderConnection = nil
    end

    for Index = 1, #Drawings do
        local Object = Drawings[Index]
        Object.Visible = false
        Object:Remove()
    end

    Drawings = {}
    Roles = {}
    Widths = {}
    Primitives = {}

    if _G.NightfallDemonController == self then _G.NightfallDemonController = nil end
end

return Controller
