--!strict

-- A simple state machine implementation for hooking a ControllerManager to a Humanoid.
-- Runs an update function on the PreAnimate event that sets ControllerManager movement inputs
-- and checks for state transition events.
-- Creates a Jump action and "JumpImpulse" attribute on the ControllerManager.

--TODO , fix the rest of this module

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local GlobalInfo = require(ReplicatedStorage.Common.GlobalInfo)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local character, ControllerManager, humanoid, root = nil, nil, nil, nil
local function updateCharacter()
	character = player.Character or player.CharacterAdded:Wait()

	ControllerManager = character:WaitForChild("ControllerManager")
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	root = character:WaitForChild("HumanoidRootPart")
end

--update variables on new character
updateCharacter()
player.CharacterAdded:Connect(updateCharacter)

-- Returns true if the controller is assigned, in world, and being simulated
local function isControllerActive(controller: ControllerBase)
	return ControllerManager.ActiveController == controller and controller.Active
end

-- Returns true if the Buoyancy sensor detects the root part is submerged in water, and we aren't already swimming
local function checkSwimmingState()
	return root.BuoyancySensor.TouchingSurface and humanoid:GetState() ~= Enum.HumanoidStateType.Swimming
end

-- Returns true if neither the GroundSensor or ClimbSensor found a Part and, we don't have the AirController active.
local function checkFreefallState()
	return (
		ControllerManager.GroundSensor.SensedPart == nil
		and ControllerManager.ClimbSensor.SensedPart == nil
		and not (isControllerActive(ControllerManager.AirController) or root.BuoyancySensor.TouchingSurface)
	) or humanoid:GetState() == Enum.HumanoidStateType.Jumping
end

-- Returns true if the GroundSensor found a Part, we don't have the GroundController active, and we didn't just Jump
local function checkRunningState()
	return ControllerManager.GroundSensor.SensedPart ~= nil
		and not isControllerActive(ControllerManager.GroundController)
		and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping
end

-- Returns true of the ClimbSensor found a Part and we don't have the ClimbController active.
local function checkClimbingState()
	return ControllerManager.ClimbSensor.SensedPart ~= nil and not isControllerActive(ControllerManager.ClimbController)
end

-- The Controller determines the type of locomotion and physics behavior
-- Setting the humanoid state is just so animations will play, not required
local function updateStateAndActiveController()
	if checkSwimmingState() then
		ControllerManager.ActiveController = ControllerManager.SwimController
		humanoid:ChangeState(Enum.HumanoidStateType.Swimming)
	elseif checkClimbingState() then
		ControllerManager.ActiveController = ControllerManager.ClimbController
		humanoid:ChangeState(Enum.HumanoidStateType.Climbing)
	elseif checkRunningState() then
		ControllerManager.ActiveController = ControllerManager.GroundController
		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	elseif checkFreefallState() then
		ControllerManager.ActiveController = ControllerManager.AirController
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end

-- Take player input from Humanoid and apply directly to the ControllerManager.
local function updateMovementDirection()
	local dir = character.Humanoid.MoveDirection
	ControllerManager.MovingDirection = dir

	if dir.Magnitude > 0 then
		ControllerManager.FacingDirection = dir
	else
		if isControllerActive(ControllerManager.SwimController) then
			ControllerManager.FacingDirection = ControllerManager.RootPart.CFrame.UpVector
		else
			ControllerManager.FacingDirection = ControllerManager.RootPart.CFrame.LookVector
		end
	end
end

local function stepController()
	if not character then
		return
	end
	if not (player:GetAttribute("_Dead") and true or false) then
		updateMovementDirection()
	end

	updateStateAndActiveController()
end
RunService.PreAnimation:Connect(stepController)

-- Jump input
local function doJump(_actionName, inputState, _inputObject)
	if inputState == Enum.UserInputState.Begin and isControllerActive(ControllerManager.GroundController) then
		local jumpImpulse = Vector3.new(0, humanoid.UseJumpPower and humanoid.JumpPower or humanoid.JumpHeight, 0)
		ControllerManager.RootPart:ApplyImpulse(jumpImpulse)

		character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		ControllerManager.ActiveController = ControllerManager.AirController

		-- floor receives equal and opposite force
		local floor = ControllerManager.GroundSensor.SensedPart
		if floor then
			floor:ApplyImpulseAtPosition(-jumpImpulse, ControllerManager.GroundSensor.HitFrame.Position)
		end
	end
end

local function setJump(set: boolean)
	if set then
		ContextActionService:BindActionAtPriority("Jump", doJump, true, 3000, Enum.KeyCode.Space, Enum.KeyCode.ButtonA)
	else
		ContextActionService:UnbindAction("Jump")
	end
end
setJump(true)

-----------------
-- Debug info ---

--humanoid.StateChanged:Connect(function(oldState, newState)
--	print("Change state: " .. tostring(newState) .. " | Change controller: " .. tostring(ControllerManager.ActiveController))
--end)

local speedMult = 1
local isRunning = false
local strained = false
local function sprintHandler(_actionName, userInputState, _inputObject)
	if not strained and userInputState == Enum.UserInputState.Begin then
		isRunning = true

		ControllerManager.BaseMoveSpeed = (GlobalInfo.Movement.SPEED.Running or 16) * speedMult
	else
		isRunning = false

		ControllerManager.BaseMoveSpeed = (GlobalInfo.Movement.SPEED.Walking or 8) * speedMult
	end
end

local function setSprint(set: boolean)
	if set then
		ContextActionService:BindActionAtPriority(
			"Sprint",
			sprintHandler,
			true,
			3000,
			Enum.KeyCode.LeftShift,
			Enum.KeyCode.ButtonL2
		)
	else
		ContextActionService:UnbindAction("Sprint")
	end
end
setSprint(true)

player.AttributeChanged:Connect(function(attribute: string)
	if attribute ~= "Strained" then
		return
	end
	strained = player:GetAttribute("Strained") or false

	if strained then
		ControllerManager.BaseMoveSpeed = GlobalInfo.Movement.SPEED.Walking or 8
	end
end)
--[[
Events.Enable3rdPerson.OnClientEvent:Connect(function(enable: boolean)
	if enable then
		player.CameraMode = Enum.CameraMode.Classic
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 30
	else
		player.CameraMode = Enum.CameraMode.LockFirstPerson
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 0.5
	end
end)

Events.PlayerDied.OnClientEvent:Connect(function(playerWhoDied: Player)
	if died or player ~= playerWhoDied then
		return
	end
	died = true

	setSprint(false)
	ControllerManager:SetAttribute("JumpImpulse", Vector3.new(0, 0, 0))
	ContextActionService:UnbindAction("Jump")
end)

Events.SpeedMult.OnClientEvent:Connect(function(speed: number)
	speedMult = speed

	ControllerManager.BaseMoveSpeed = (GlobalInfo.Movement.SPEED.Walking or 8) * speedMult
end)
]]

return {}
