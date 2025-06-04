--!strict

-- Replace Humanoid physics with a ControllerManager when a character loads into the workspace

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalInfo = require(ReplicatedStorage.Common.GlobalInfo)

local function initialize(character: Model)
	local cm = Instance.new("ControllerManager")

	local gc = Instance.new("GroundController")
	gc.Parent = cm
	local ac = Instance.new("AirController")
	ac.Parent = cm
	local cc = Instance.new("ClimbController")
	cc.Parent = cm
	local sc = Instance.new("SwimController")
	sc.Parent = cm

	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	cm.RootPart = humanoid.RootPart :: any
	gc.GroundOffset = humanoid.HipHeight
	cm.FacingDirection = cm.RootPart and cm.RootPart.CFrame.LookVector or Vector3.new(0, 1, 0)
	cm.BaseMoveSpeed = GlobalInfo.Movement.SPEED.Walking
	gc.FrictionWeight = 10

	local floorSensor = Instance.new("ControllerPartSensor")
	floorSensor.SensorMode = Enum.SensorMode.Floor
	floorSensor.SearchDistance = gc.GroundOffset + 0.5
	floorSensor.Name = "GroundSensor"

	local ladderSensor = Instance.new("ControllerPartSensor")
	ladderSensor.SensorMode = Enum.SensorMode.Ladder
	ladderSensor.SearchDistance = 1.5
	ladderSensor.Name = "ClimbSensor"

	local waterSensor = Instance.new("BuoyancySensor")

	cm.GroundSensor = floorSensor
	cm.ClimbSensor = ladderSensor

	waterSensor.Parent = cm.RootPart
	floorSensor.Parent = cm.RootPart
	ladderSensor.Parent = cm.RootPart
	cm.Parent = character
end

local function connectToCharacter(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		if humanoid then
			humanoid.EvaluateStateMachine = false
		end

		wait() -- ensure post-load Humanoid computations are complete (such as hip height)
		initialize(character)
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	connectToCharacter(player)
end

Players.PlayerAdded:Connect(function(player)
	connectToCharacter(player)
end)

return {}
