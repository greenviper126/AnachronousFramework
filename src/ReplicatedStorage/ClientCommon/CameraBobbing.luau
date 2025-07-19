--!strict

local IDLE_STRENGTH = 1
local TURN_STRENGTH = 1

--[[
    This should have a signal to send to body tracking so it gets camera CFrame without the bobbing

    may need some functions to stop camera bobbing on cutscenes
]]

---------------------------------------------------------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local RedEvents = require(ReplicatedStorage.RedEvents)
local Utility = require(ReplicatedStorage.Utility)

--local Market = require(ReplicatedStorage.Common.Market)
--local Sounds = require(ReplicatedStorage.Common.Sounds)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

--local random = Random.new()
local camera = workspace.CurrentCamera
player:SetAttribute("IsFirstPerson", true)

--variables across objects
local func1, func2, func3 = 0, 0, 0

local function lerp(a: number, b: number, c: number): number
	return a + (b - a) * c
end

local CameraBobber = {}
CameraBobber.__index = CameraBobber
CameraBobber.TAG_NAME = "CameraBobber"

type self = {
	root: Part,
	humanoid: Humanoid,
	head: BasePart,

	rightStep: boolean,

	_cameraCleaner: typeof(Trove.new()),
	_cleaner: typeof(Trove.new()),
}

export type CameraBobber = typeof(setmetatable({} :: self, CameraBobber))

--[[
	Constructor

	@return self - the new object
]]
function CameraBobber.new(root: Part)
	local humanoid = root.Parent and root.Parent:FindFirstChildWhichIsA("Humanoid") or nil
	assert(humanoid, "Could not find humanoid for CameraBobbing, Player:" .. player.Name)

	local head = root.Parent and root.Parent:FindFirstChild("Head") :: BasePart or nil
	assert(head, "Could not find Head for CameraBobbing, Player:" .. player.Name)

	if not Utility.Tags.GetUnique(CameraBobber.TAG_NAME) then
		warn("There is more than one object with the CameraBobber Tag")
	end

	local self = setmetatable({} :: self, CameraBobber)
	self._cleaner = Trove.new()

	self.root = root
	self.humanoid = humanoid
	self.head = head

	self:OnStart()
	self:Track()

	return self
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param self CameraBobber - object
]]
function CameraBobber.OnStart(self: CameraBobber)
	--self.humanoid.CameraOffset = (self.root.CFrame + Vector3.new(0, 1, 0)):ToObjectSpace(self.head.CFrame).Position
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param type "Crouch" | "Walk" | "Sprint" | "Idle"  - type of bobbing
]]
function CameraBobber.GetBobbingValues(
	self: CameraBobber,
	type: "Crouch" | "Walk" | "Sprint" | "Idle"
): (number, number)
	local tickMultiplier, verticalMultiplier, horizontalMultiplier = 1, 0.001, 0.001

	if type == "Walk" then
		tickMultiplier = 4.5
		verticalMultiplier = 0.07
		horizontalMultiplier = 0.03
	elseif type == "Crouch" then
		tickMultiplier = 3
		verticalMultiplier = 0.05
		horizontalMultiplier = 0.018
	elseif type == "Sprint" then
		tickMultiplier = 7
		verticalMultiplier = 0.13
		horizontalMultiplier = 0.07
	elseif type == "Idle" then
		tickMultiplier = 0
		verticalMultiplier = 0
		horizontalMultiplier = 0
	end

	--creates an arc shape
	local t = tick() * tickMultiplier
	local x = math.sin(t * 2)
	local y = math.sin(t)

	local isRightStep = y < 0 and true or false
	if self.rightStep ~= isRightStep and math.abs(y) >= 0.99 then
		self.rightStep = isRightStep

		RedEvents.Signal.Client.FootStep:Fire(isRightStep)
	end

	local verticalBob = x * verticalMultiplier * 0.01
	local horizontalBob = y * horizontalMultiplier * 0.01

	return verticalBob, horizontalBob
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param self CameraBobber - object
]]
function CameraBobber.BobbingFrame(self: CameraBobber, delta: number)
	delta = delta * 30

	local velocity = self.root.AssemblyLinearVelocity
	local speed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude
	local strength = IDLE_STRENGTH * (1 - (speed / GlobalInfo.MOVEMENT.SPEED.RUNNING))

	if delta > 1.5 then
		func1, func2 = 0, 0
	else
		func1 = lerp(
			func1,
			math.cos(time() * 0.5 * math.random(5, 7.5)) * (math.random(2.5, 10) / 100) * strength * delta,
			0.05 * delta
		)
		func2 = lerp(
			func2,
			math.cos(time() * 0.5 * math.random(2.5, 5)) * (math.random(1, 5) / 100) * strength * delta,
			0.05 * delta
		)
	end

	--check the bobbing type that should be used
	local verticalBob, horizontalBob = 0, 0
	if speed > GlobalInfo.MOVEMENT.SPEED.RUNNING - 0.5 then
		verticalBob, horizontalBob = self:GetBobbingValues("Sprint")
	elseif speed > GlobalInfo.MOVEMENT.SPEED.WALKING - 0.5 then
		verticalBob, horizontalBob = self:GetBobbingValues("Walk")
	elseif speed > GlobalInfo.MOVEMENT.SPEED.CROUCHING - 0.5 then
		verticalBob, horizontalBob = self:GetBobbingValues("Crouch")
	else
		verticalBob, horizontalBob = self:GetBobbingValues("Idle")
	end

	camera.CFrame = camera.CFrame
		* CFrame.fromEulerAnglesXYZ(math.rad(func1 * 0.2), math.rad(func2), math.rad(func2 * 10)) --rnd bobbing
		* CFrame.fromEulerAnglesXYZ(0, 0, math.rad(func3)) --turning
		* CFrame.fromEulerAnglesXYZ(verticalBob, horizontalBob, 0) -- bobbing

	func3 = lerp(func3, math.clamp(UserInputService:GetMouseDelta().X, -2.5, 2.5) * TURN_STRENGTH, 0.25 * delta) -- turn func
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param self CameraBobber - object
]]
function CameraBobber.ConnectFunctionToFirstPersonType(self: CameraBobber, func: () -> ())
	if self._cameraCleaner then
		self._cameraCleaner:Add(func)
	else
		func()
	end
end

--[[
	Will turn the CameraBobber on and off with added sounds and timing.

	@param self CameraBobber - object
]]
function CameraBobber.Track(self: CameraBobber)
	local function setCameraType()
		local isFirstPerson = player:GetAttribute("IsFirstPerson")
		print(isFirstPerson)
		if isFirstPerson then
			self._cameraCleaner = self._cleaner:Extend()

			self._cameraCleaner:BindToRenderStep(
				"CustomCamera",
				Enum.RenderPriority.Camera.Value + 1,
				function(delta: number)
					self:BobbingFrame(delta)
				end
			)

			self._cameraCleaner:Add(function()
				RunService:UnbindFromRenderStep("CustomCamera")
			end)
		else
			if self._cameraCleaner then
				self._cameraCleaner:Destroy()
			end
		end
	end

	setCameraType()
	self._cleaner:Connect(player.AttributeChanged, function(attribute: string)
		if attribute ~= "IsFirstPerson" then
			return
		end

		setCameraType()
	end)
end

--[[
	Cleans up the CameraBobber object.

	@param self CameraBobber - object
]]
function CameraBobber.Cleanup(self: CameraBobber)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _cleanup, objects = Utility.Tags.SetObjectListner(CameraBobber)

local function _getObject(): typeof(CameraBobber.new(Instance.new("Part")))?
	local instance = Utility.Tags.GetUnique(CameraBobber.TAG_NAME)
	if not instance then
		return
	end
	return objects()[instance] :: any
end

local function tagCharacter()
	if not player.Character then
		return
	end

	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		warn("Could not find root to attach CameraBobber tag")
		return
	end

	root:AddTag(CameraBobber.TAG_NAME)
end

tagCharacter()
player.CharacterAdded:Connect(function()
	tagCharacter()
end)

-------------------------------------------------------------------------------------------

local CameraBobbing = {}

--[[
    Sets the camera to fist person or unlocks it.

    @param set boolean - Set to first person or unlock
]]
function CameraBobbing.SetFirstPerson(set: boolean)
	player:SetAttribute("IsFirstPerson", set)
end

--[[
    Gets the camera state of fist person or unlock.

    @return boolean - current state of first person or unlock
]]
function CameraBobbing.GetFirstPerson(): boolean
	return player:GetAttribute("IsFirstPerson")
end

--[[
    Connect a function to the FirstPerson camera type
	
	Will run when the character dies or the camera type was switched to unlock

    @param func () -> () - function you want to run
]]
function CameraBobbing.ConnectFunctionToFirstPersonType(func: () -> ())
	local object = _getObject()
	if not object then
		return
	end

	object:ConnectFunctionToFirstPersonType(func)
end

--[[
    Connect a function to the FirstPerson camera type to run while in first person
	
	Cleanup function will run when the character dies or the camera type was switched to unlock

    @param run () -> () - function you want to run in first person
	@param cleanup () -> () - function you want to cleanup the run
]]
function CameraBobbing.ConnectAndListenToFirstPersonType(run: () -> (), cleanup: () -> ())
	local object = _getObject()
	if not object then
		return
	end

	object:ConnectFunctionToFirstPersonType(cleanup)
	run()
	object._cleaner:Connect(player.AttributeChanged, function(attribute: string)
		if attribute ~= "IsFirstPerson" then
			return
		end

		local isFirstPerson = player:GetAttribute("IsFirstPerson")

		object:ConnectFunctionToFirstPersonType(cleanup)
		if isFirstPerson then
			run()
		end
	end)
end

return CameraBobbing
