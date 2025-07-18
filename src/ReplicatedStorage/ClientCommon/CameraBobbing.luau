--!strict

local IDLE_STRENGTH = 3.5
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
local Utility = require(ReplicatedStorage.Utility)

--local Market = require(ReplicatedStorage.Common.Market)
--local Sounds = require(ReplicatedStorage.Common.Sounds)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

--local random = Random.new()
local camera = workspace.CurrentCamera

--variables across objects
local func1, func2, func3 = 0, 0, 0

local function lerp(a: number, b: number, c: number): number
	return a + (b - a) * c
end

local Stamina = {}
Stamina.__index = Stamina
Stamina.TAG_NAME = "Stamina"

type self = {
	root: Part,
	humanoid: Humanoid,
	head: BasePart,

	_cleaner: typeof(Trove.new()),
}

export type Stamina = typeof(setmetatable({} :: self, Stamina))

--[[
	Constructor

	@return self - the new object
]]
function Stamina.new(root: Part)
	local humanoid = root.Parent and root.Parent:FindFirstChildWhichIsA("Humanoid") or nil
	assert(humanoid, "Could not find humanoid for CameraBobbing, Player:" .. player.Name)

	local head = root.Parent and root.Parent:FindFirstChild("Head") :: BasePart or nil
	assert(head, "Could not find Head for CameraBobbing, Player:" .. player.Name)

	if not Utility.Tags.GetUnique(Stamina.TAG_NAME) then
		warn("There is more than one object with the Stamina Tag")
	end

	local self = setmetatable({} :: self, Stamina)
	self._cleaner = Trove.new()

	self.root = root
	self.humanoid = humanoid
	self.head = head

	self:OnStart()
	self:Track()

	return self
end

--[[
	Will turn the Stamina on and off with added sounds and timing.

	@param self Stamina - object
]]
function Stamina.OnStart(self: Stamina)
	self.humanoid.CameraOffset = (self.root.CFrame + Vector3.new(0, 2, 0)):ToObjectSpace(self.head.CFrame).Position
end

--[[
	Will turn the Stamina on and off with added sounds and timing.

	@param type "Crouch" | "Walk" | "Sprint" | "Idle"  - type of bobbing
]]
function Stamina.GetBobbingValues(type: "Crouch" | "Walk" | "Sprint" | "Idle"): (number, number)
	local tickMultiplier, verticalMultiplier, horizontalMultiplier = 1, 0.001, 0.001

	if type == "Walk" then
		tickMultiplier = 4.5
		verticalMultiplier = 0.0015
		horizontalMultiplier = 0.002
	elseif type == "Crouch" then
		tickMultiplier = 3.5
		verticalMultiplier = 0.0013
		horizontalMultiplier = 0.0016
	elseif type == "Sprint" then
		tickMultiplier = 7.5
		verticalMultiplier = 0.002
		horizontalMultiplier = 0.003
	elseif type == "Idle" then
		tickMultiplier = 0
		verticalMultiplier = 0
		horizontalMultiplier = 0
	end

	--creates an arc shape
	local t = tick() * tickMultiplier
	local x = math.sin(t * 2)
	local y = math.sin(t)

	local verticalBob = x * verticalMultiplier
	local horizontalBob = y * horizontalMultiplier

	return verticalBob, horizontalBob
end

--[[
	Will turn the Stamina on and off with added sounds and timing.

	@param self Stamina - object
]]
function Stamina.Track(self: Stamina)
	local function bobbing(delta: number)
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
			verticalBob, horizontalBob = self.GetBobbingValues("Sprint")
		elseif speed > GlobalInfo.MOVEMENT.SPEED.WALKING - 0.5 then
			verticalBob, horizontalBob = self.GetBobbingValues("Walk")
		elseif speed > GlobalInfo.MOVEMENT.SPEED.CROUCHING - 0.5 then
			verticalBob, horizontalBob = self.GetBobbingValues("Crouch")
		else
			verticalBob, horizontalBob = self.GetBobbingValues("Idle")
		end

		camera.CFrame = camera.CFrame
			* CFrame.fromEulerAnglesXYZ(math.rad(func1 * 0.2), math.rad(func2), math.rad(func2 * 10)) --rnd bobbing
			* CFrame.fromEulerAnglesXYZ(0, 0, math.rad(func3)) --turning
			* CFrame.fromEulerAnglesXYZ(verticalBob, horizontalBob, 0) -- bobbing

		func3 = lerp(func3, math.clamp(UserInputService:GetMouseDelta().X, -2.5, 2.5) * TURN_STRENGTH, 0.25 * delta) -- turn func
	end

	RunService:BindToRenderStep("CustomCamera", Enum.RenderPriority.Camera.Value + 1, bobbing)

	self._cleaner:Add(function()
		RunService:UnbindFromRenderStep("CustomCamera")
	end)
end

--[[
	Cleans up the Stamina object.

	@param self Stamina - object
]]
function Stamina.Cleanup(self: Stamina)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _cleanup, objects = Utility.Tags.SetObjectListner(Stamina)

local function _getObject(): typeof(Stamina.new(Instance.new("Part")))?
	local instance = Utility.Tags.GetUnique(Stamina.TAG_NAME)
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
		warn("Could not find root to attach Stamina tag")
		return
	end

	root:AddTag(Stamina.TAG_NAME)
end

tagCharacter()
player.CharacterAdded:Connect(function()
	tagCharacter()
end)

-------------------------------------------------------------------------------------------

local StaminaBar = {}

--[[
    Will determine if the player is allowed to use there Stamina or not.

    @param activate boolean - can it be activated by player?
]]
function Stamina.SetCanSprint(activate: boolean) end

--[[
    Checks if the Stamina was activated so it can be used.

    @return boolean - is it possible to activate?
]]
function Stamina.GetCanSprint(): boolean
	return true
end

return StaminaBar
