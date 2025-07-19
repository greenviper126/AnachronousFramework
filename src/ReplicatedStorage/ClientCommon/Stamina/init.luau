--!strict

--[[
	crouch and run and walk state should be connected through signal for other things to read
	
	anim will be connected through these signals
]]

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local Utility = require(ReplicatedStorage.Utility)

--local Market = require(ReplicatedStorage.Common.Market)
local Sounds = require(ReplicatedStorage.Common.Sounds)

local CameraBobbing = require(ReplicatedStorage.ClientCommon.CameraBobbing)

local StaminaUI = require(script.StaminaUI)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local camera = workspace.CurrentCamera

--variables across objects
local canSprint = true
local canCrouch = true
local speedMultiplier = 1
local regenMultiplier = 1
local drainMultiplier = 1

local Stamina = {}
Stamina.__index = Stamina
Stamina.TAG_NAME = "Stamina"

type self = {
	root: Part,
	humanoid: Humanoid,

	staminaHolder: CanvasGroup,
	staminaBar: Frame,
	breathingSound: Sound,

	currentStamina: number,
	prevClick: number,
	regenPauseTime: number,

	reachedTop: boolean,
	reachedBottom: boolean,
	requestingSprint: boolean,
	requestingCrouch: boolean,

	prevFovState: boolean,
	isFirstPerson: boolean,

	_cleaner: typeof(Trove.new()),
}

export type Stamina = typeof(setmetatable({} :: self, Stamina))

--[[
	Constructor

	@return self - the new object
]]
function Stamina.new(root: Part)
	local humanoid = root.Parent and root.Parent:FindFirstChildWhichIsA("Humanoid") or nil
	assert(humanoid, "Could not find humanoid for StaminaBar, Player:" .. player.Name)

	local breathingSound = Sounds.FindSoundByName("StaminaBreathing", nil, root)
	assert(breathingSound, "Could not find Sound for StaminaBar, Player:" .. player.Name)

	if not Utility.Tags.GetUnique(Stamina.TAG_NAME) then
		warn("There is more than one object with the Stamina Tag")
	end

	local self = setmetatable({} :: self, Stamina)
	self._cleaner = Trove.new()

	self.root = root
	self.prevClick = 0
	self.currentStamina = GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA

	local staminaGUI, staminaHolder, staminaBar = StaminaUI.New(player.PlayerGui)
	self._cleaner:Add(staminaGUI)
	self.staminaHolder = staminaHolder
	self.staminaBar = staminaBar

	self.humanoid = humanoid

	self.breathingSound = breathingSound
	self.breathingSound.Looped = true
	self.breathingSound.Volume = 0
	self.breathingSound:Play()

	self.staminaHolder.GroupTransparency = 1
	self.regenPauseTime = 0

	self:SetWalkSpeed("Walk")
	self:Track()
	self:ConnectKey()

	return self
end

--[[
	Returns current percentage of stamina

	@param self Stamina - object
	@return number - percentage of current stamina
]]
function Stamina.GetStaminaPercentage(self: Stamina): number
	return self.currentStamina / GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA
end

--[[
	Sets the speed of the player

	@param self Stamina - object
	@param speed number - speed of player
]]
function Stamina.SetWalkSpeed(self: Stamina, type: "Crouch" | "Walk" | "Sprint")
	local setMultiplier = speedMultiplier or 1

	if type == "Crouch" then
		self.humanoid.WalkSpeed = GlobalInfo.MOVEMENT.SPEED.CROUCHING * setMultiplier
	elseif type == "Walk" then
		self.humanoid.WalkSpeed = GlobalInfo.MOVEMENT.SPEED.WALKING * setMultiplier
	elseif type == "Sprint" then
		self.humanoid.WalkSpeed = GlobalInfo.MOVEMENT.SPEED.RUNNING * setMultiplier
	end
end

--[[
	Regen stamina for that frame

	@param self Stamina - object
]]
function Stamina.Regen(self: Stamina)
	if self.requestingCrouch then
		self:SetWalkSpeed("Crouch")
	elseif not self.requestingSprint then
		self:SetWalkSpeed("Walk")
	end

	if time() - self.regenPauseTime < GlobalInfo.MOVEMENT.STAMINA.REGEN_PAUSE then
		return
	end

	self.currentStamina = math.clamp(
		self.currentStamina + GlobalInfo.MOVEMENT.STAMINA.STAMINA_REGEN * regenMultiplier,
		0,
		GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA
	)

	TweenService:Create(self.staminaBar, TweenInfo.new(0.1), { Size = UDim2.new(self:GetStaminaPercentage(), 0, 1, 0) })
		:Play()
end

--[[
	Drain stamina for that frame

	@param self Stamina - object
]]
function Stamina.Drain(self: Stamina)
	self.regenPauseTime = time()

	self:SetWalkSpeed("Sprint")

	local velocity = self.root.AssemblyLinearVelocity
	local velocityXZ = Vector3.new(velocity.X, 0, velocity.Z)
	if velocityXZ.Magnitude < GlobalInfo.MOVEMENT.SPEED.WALKING + 0.5 then -- not running when holding shift
		self:Regen()
		return
	end

	local localVelocity = self.root.CFrame:VectorToObjectSpace(velocity)
	if localVelocity.Z > 0.03 then --backwards (its a positive number)
		self.requestingSprint = false
		self:Regen()
		return
	end

	self.currentStamina = math.clamp(
		self.currentStamina - GlobalInfo.MOVEMENT.STAMINA.STAMINA_DRAIN * drainMultiplier,
		0,
		GlobalInfo.MOVEMENT.STAMINA.MAX_STAMINA
	)

	TweenService:Create(self.staminaBar, TweenInfo.new(0.1), { Size = UDim2.new(self:GetStaminaPercentage(), 0, 1, 0) })
		:Play()
end

--[[
	determines when the player drained there stamina too much

	@param self Stamina - object
]]
function Stamina.SetReachBottom(self: Stamina)
	if self:GetStaminaPercentage() == 0 then
		self.reachedBottom = true
		self:SetWalkSpeed("Walk")
		self.staminaBar.BackgroundColor3 = GlobalInfo.MOVEMENT.STAMINA.TIRED_BAR_COLOR
	elseif self:GetStaminaPercentage() >= 0.5 then
		self.reachedBottom = false

		if self.staminaBar.BackgroundColor3 == GlobalInfo.MOVEMENT.STAMINA.TIRED_BAR_COLOR then
			TweenService:Create(
				self.staminaBar,
				TweenInfo.new(GlobalInfo.MOVEMENT.STAMINA.TIRED_TRANSITION_TIME, Enum.EasingStyle.Sine),
				{ BackgroundColor3 = GlobalInfo.MOVEMENT.STAMINA.DEFAULT_BAR_COLOR }
			):Play()
		end
	end
end

--[[
	Plays Breathing sound by using a curve

	@param self Stamina - object
]]
function Stamina.SetBreathingSound(self: Stamina)
	self.breathingSound.Volume = (1 - self:GetStaminaPercentage()) ^ 6 / 4
end

--[[
	Plays Breathing sound by using a curve

	@param self Stamina - object
]]
function Stamina.SetFade(self: Stamina)
	if not self.reachedTop and self:GetStaminaPercentage() == 1 then
		self.reachedTop = true

		TweenService:Create(
			self.staminaHolder,
			TweenInfo.new(
				GlobalInfo.MOVEMENT.STAMINA.FULL_STAMIN_FADE_TIME,
				Enum.EasingStyle.Sine,
				Enum.EasingDirection.InOut,
				0,
				false,
				GlobalInfo.MOVEMENT.STAMINA.FULL_STAMIN_WAIT_TIME
			),
			{ GroupTransparency = 1 }
		):Play()
	elseif self.reachedTop and self:GetStaminaPercentage() ~= 1 then
		self.reachedTop = false

		TweenService:Create(
			self.staminaHolder,
			TweenInfo.new(GlobalInfo.MOVEMENT.STAMINA.FULL_STAMIN_FADE_TIME, Enum.EasingStyle.Sine),
			{ GroupTransparency = 0 }
		):Play()
	end
end

--[[
	Plays Breathing sound by using a curve

	@param self Stamina - object
]]
function Stamina.SetFOV(self: Stamina)
	if not self.isFirstPerson then
		return
	end

	if self.root.AssemblyLinearVelocity.Magnitude >= GlobalInfo.MOVEMENT.SPEED.RUNNING - 1 then
		if self.prevFovState == true then
			return
		end
		self.prevFovState = true

		TweenService:Create(
			camera,
			TweenInfo.new(0.3, Enum.EasingStyle.Sine),
			{ FieldOfView = GlobalInfo.CAMERA.DEFAULT_FOV + GlobalInfo.MOVEMENT.STAMINA.FOV_ZOOM_OUT }
		):Play()
	else
		if self.prevFovState == false then
			return
		end
		self.prevFovState = false

		TweenService
			:Create(
				camera,
				TweenInfo.new(0.3, Enum.EasingStyle.Sine),
				{ FieldOfView = GlobalInfo.CAMERA.DEFAULT_FOV + 0 }
			)
			:Play()
	end
end

--[[
	Will turn the Stamina on and off with added sounds and timing.

	@param self Stamina - object
	@param on boolean - turn the Stamina on?
]]
function Stamina.Track(self: Stamina)
	self._cleaner:Connect(RunService.Heartbeat, function()
		self:SetFade()
		self:SetReachBottom()
		self:SetBreathingSound()
		self:SetFOV()

		if not self.requestingSprint or self.reachedBottom then
			self:Regen()
		else
			self:Drain()
		end
	end)

	CameraBobbing.ConnectAndListenToFirstPersonType(function()
		self.isFirstPerson = true
	end, function()
		self.isFirstPerson = false
		camera.FieldOfView = GlobalInfo.CAMERA.DEFAULT_FOV
	end)
end

--[[
	Connects key binds to running

	@param self Stamina - object
]]
function Stamina.ConnectKey(self: Stamina)
	--sprint
	local function activatedStamina(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		if inputState == Enum.UserInputState.End then
			self.requestingSprint = false
			return Enum.ContextActionResult.Pass
		end

		if not canSprint then
			self:SetWalkSpeed("Walk")
			return Enum.ContextActionResult.Pass
		end

		if time() - self.prevClick < 0.1 then
			return Enum.ContextActionResult.Pass
		end
		self.prevClick = time()

		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		self.requestingSprint = true

		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"Stamina",
		activatedStamina,
		true,
		3000,
		Enum.KeyCode.LeftShift,
		Enum.KeyCode.ButtonR2
	)

	self._cleaner:Add(function()
		ContextActionService:UnbindAction("Stamina")
	end)

	--crouch
	local function activatedCrouch(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		if inputState == Enum.UserInputState.End then
			self.requestingCrouch = false
			return Enum.ContextActionResult.Pass
		end

		if not canCrouch then
			self:SetWalkSpeed("Walk")
			return Enum.ContextActionResult.Pass
		end

		if time() - self.prevClick < 0.1 then
			return Enum.ContextActionResult.Pass
		end
		self.prevClick = time()

		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		self.requestingCrouch = true

		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"Crouch",
		activatedCrouch,
		true,
		3000,
		Enum.KeyCode.LeftControl,
		Enum.KeyCode.ButtonR1
	)

	self._cleaner:Add(function()
		ContextActionService:UnbindAction("Crouch")
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
function Stamina.SetCanSprint(activate: boolean)
	canSprint = activate
end

--[[
    Checks if the Stamina was activated so it can be used.

    @return boolean - is it possible to activate?
]]
function Stamina.GetCanSprint(): boolean
	return canSprint
end

--[[
    Will determine if the player is allowed to use there Crouch or not.

    @param activate boolean - can it be activated by player?
]]
function Stamina.SetCanCrouch(activate: boolean)
	canCrouch = activate
end

--[[
    Checks if the Crouch was activated so it can be used.

    @return boolean - is it possible to activate?
]]
function Stamina.GetCanCrouch(): boolean
	return canCrouch
end

--[[
    Sets the speed multiplier

	Used for side meter

    @param multiplier number - The number to multiply the speed
]]
function Stamina.SetSpeedMultiplier(multiplier: number?)
	Stamina.speedMultiplier = multiplier or 1
end

--[[
    Sets the regen multiplier

	Used for side meter

    @param multiplier number - The number to multiply the regen speed
]]
function Stamina.SetRegenMultiplier(multiplier: number?)
	Stamina.regenMultiplier = multiplier or 1
end

--[[
    Sets the drain multiplier

	Used for side meter

    @param multiplier number - The number to multiply the drain speed
]]
function Stamina.SetDrainMultiplier(multiplier: number?)
	Stamina.drainMultiplier = multiplier or 1
end

return StaminaBar
