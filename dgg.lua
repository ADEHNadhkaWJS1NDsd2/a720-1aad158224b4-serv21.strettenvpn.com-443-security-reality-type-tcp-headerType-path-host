local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer
setrobloxinput(true)

local BallEngine = {}
BallEngine.__index = BallEngine

function BallEngine.new(Ball, Callback)
	local self = setmetatable({}, BallEngine)
	self.Ball = Ball
	self.Callback = Callback
	self.LastPos = nil
	self.LastTick = 0
	self.Running = false
	return self
end

function BallEngine:Start()
	self.Running = true

	task.spawn(function()
		while self.Running and self.Ball and self.Ball.Parent do
			task.wait()

			local Pos = self.Ball.Position
			if not Pos then continue end

			local Now = tick()
			local DT = Now - self.LastTick

			if self.LastPos and DT > 0.001 then
				local DX = Pos.X - self.LastPos.X
				local DY = Pos.Y - self.LastPos.Y
				local DZ = Pos.Z - self.LastPos.Z
				local Dist = math.sqrt(DX * DX + DY * DY + DZ * DZ)

				if Dist < 30 then
					local Velocity = Dist / DT
					self.Callback(Pos, self.LastPos, Velocity, DT, Dist)
				end
			end

			self.LastPos = Pos
			self.LastTick = Now
		end
	end)
end

function BallEngine:Stop()
	self.Running = false
end

local LastParry = 0
local BUFFER_SIZE = 8
local PosBuffer = {}
local TimeBuffer = {}

local MAX_SPEED = 500
local MIN_SPEED = 6.5
local TTI_THRESHOLD = 0.22

local function IsTarget()
	local Char = Player.Character
	if not Char then return false end
	local Highlight = Char:FindFirstChild("Highlight")
	if not Highlight then return false end
	local Val = memory_read("float", Highlight.Address + 228)
	return Val > 0.3 and Val < 0.4
end

local function Parry()
	keypress(70)
	keyrelease(70)
end

local function GetFocus()
	local Char = Player.Character
	if Char then
		local HRP = Char:FindFirstChild("HumanoidRootPart")
		if HRP then return HRP.Position end
	end
	return nil
end

local function Vec3Dist(A, B)
	local DX = A.X - B.X
	local DY = A.Y - B.Y
	local DZ = A.Z - B.Z
	return math.sqrt(DX * DX + DY * DY + DZ * DZ)
end

local function IsApproaching(BP, Focus, VX, VY, VZ)
	local DX = Focus.X - BP.X
	local DY = Focus.Y - BP.Y
	local DZ = Focus.Z - BP.Z
	local Agree = 0
	if VX * DX > 0 then Agree = Agree + 1 end
	if VY * DY > 0 then Agree = Agree + 1 end
	if VZ * DZ > 0 then Agree = Agree + 1 end
	return Agree >= 2
end

local function OnBallMove(NewPos, OldPos, Velocity, DT, StepDist)
	if not IsTarget() then
		PosBuffer = {}
		TimeBuffer = {}
		return
	end

	if Velocity < MIN_SPEED or Velocity > MAX_SPEED then return end

	local Focus = GetFocus()
	if not Focus then return end

	table.insert(PosBuffer, NewPos)
	table.insert(TimeBuffer, tick())

	if #PosBuffer > BUFFER_SIZE then
		table.remove(PosBuffer, 1)
		table.remove(TimeBuffer, 1)
	end

	if #PosBuffer < 3 then return end

	local P1 = PosBuffer[1]
	local PLast = PosBuffer[#PosBuffer]
	local T1 = TimeBuffer[1]
	local TLast = TimeBuffer[#TimeBuffer]
	local TotalDT = TLast - T1

	if TotalDT < 0.01 then return end

	local AvgVelocity = Vec3Dist(PLast, P1) / TotalDT
	if AvgVelocity < MIN_SPEED or AvgVelocity > MAX_SPEED then return end

	local Distance = Vec3Dist(NewPos, Focus)
	local TimeToImpact = Distance / AvgVelocity

	local VX = (PLast.X - P1.X) / TotalDT
	local VY = (PLast.Y - P1.Y) / TotalDT
	local VZ = (PLast.Z - P1.Z) / TotalDT

	local Approaching = IsApproaching(NewPos, Focus, VX, VY, VZ)

	if Approaching and TimeToImpact <= TTI_THRESHOLD then
		if tick() - LastParry >= 0.25 then
			Parry()
			LastParry = tick()
		end
	end
end

local ActiveEngines = {}

local function ScanWorkspace()
	for _, Obj in pairs(workspace:GetChildren()) do
		if Obj.ClassName == "MeshPart" and Obj.Name == "Part" then
			if not ActiveEngines[Obj] then
				local Engine = BallEngine.new(Obj, OnBallMove)
				Engine:Start()
				ActiveEngines[Obj] = Engine
			end
		end
	end

	for Ball, Engine in pairs(ActiveEngines) do
		if not Ball.Parent then
			Engine:Stop()
			ActiveEngines[Ball] = nil
		end
	end
end

task.spawn(function()
	while true do
		ScanWorkspace()
		task.wait(0.5)
	end
end)
