--!strict

local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.trove)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)
local Utility = require(ReplicatedStorage.Utility)

local Market = require(ReplicatedStorage.Common.Market)
local Sounds = require(ReplicatedStorage.Common.Sounds)

local LightInstance = require(script.LightInstance)

local camera = workspace.CurrentCamera
local player = Players.LocalPlayer

local canActivate = false

local Light = {}
Light.__index = Light
Light.TAG_NAME = "Light"

type self = {
	ring: Part,
	light1: SpotLight,
	light2: SpotLight,
	alignPosition: AlignPosition,
	alignOrientation: AlignOrientation,

	prevClick: number,
	isHeld: boolean,

	_cleaner: typeof(Trove.new()),
}

export type Light = typeof(setmetatable({} :: self, Light))

--[[
	Constructor

	@return self - the new object
]]
function Light.new()
	if not Utility.Tags.GetUnique(Light.TAG_NAME) then
		warn("There is more than one object with the Flashlight Tag")
	end

	local self = setmetatable({} :: self, Light)
	self._cleaner = Trove.new()

	local r, l1, l2, aP, aO = LightInstance.New(camera)
	self.ring = r
	self.light1 = l1
	self.light2 = l2
	self.alignPosition = aP
	self.alignOrientation = aO

	self.prevClick = 0

	self:SetGamepass()
	self:Track()
	self:ConnectKey()

	print("set")

	return self
end

--[[
	Turn the Flashlight on and off directly.

	@param self Light - object
	@param on boolean - Set Light
]]
function Light.On(self: Light, on: boolean)
	self.light1.Enabled = on
	self.light2.Enabled = on

	player:SetAttribute("_LightIsOn", on)
end

--[[
	Will set gamepass flashlight if the player purchased it.

	@param self Light - object
	@param gamepass boolean - Does this person have gamepass?
]]
function Light.SetGamepass(self: Light)
	if Market.LocalPlayerOwnsGamepass(Market.Id.GamePasses.BetterFlashlight) then
		self.light1.Range = 70
		self.light2.Range = 70

		self.light1.Brightness = 0.4
		self.light2.Brightness = 1.7
	else
		self.light1.Range = 40
		self.light2.Range = 40

		self.light1.Brightness = 0.3
		self.light2.Brightness = 1.2
	end
end

--[[
	Will turn the light on and off with added sounds and timing.

	@param self Light - object
	@param on boolean - turn the light on?
]]
function Light.TurnOn(self: Light, on: boolean)
	self.isHeld = on

	if on then
		self:On(true)
		Sounds.PlaySoundByName("FlashlightClick", Sounds.Variance(1, 1.03, 1, 1.05), self.ring)
	else
		task.wait(0.2)
		self:On(false)
		Sounds.PlaySoundByName("FlashlightClick", Sounds.Variance(0.93, 0.97, 0.95, 1), self.ring)
	end
end

--[[
	Tells you if the Flashlight is currently being held or not.

	@param self Light - object

	@return boolean - is it currently held?
]]
function Light.IsHeld(self: Light): boolean
	return self.isHeld
end

--[[
	Will turn the light on and off with added sounds and timing.

	@param self Light - object
	@param on boolean - turn the light on?
]]
function Light.Track(self: Light)
	self._cleaner:Connect(RunService.PreRender, function()
		if not canActivate and self:IsHeld() then
			self:TurnOn(false)
			return
		end

		local goal: CFrame

		if self:IsHeld() then
			goal = camera.CFrame * CFrame.new(0.75, 0, 0) * CFrame.Angles(0, math.rad(0.716), 0)
		else
			goal = camera.CFrame * CFrame.new(1, -3, 0) * CFrame.Angles(math.rad(-90), 0, 0)
		end

		self.ring.LocalTransparencyModifier = -math.huge

		self.alignPosition.Position = goal.Position
		self.alignOrientation.CFrame = goal
	end)
end

--[[
	Tells you if the Flashlight is currently being held or not.

	@param self Light - object
]]
function Light.ConnectKey(self: Light)
	local function activatedFlashlight(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end

		if not canActivate then
			return Enum.ContextActionResult.Pass
		end

		if time() - self.prevClick < GlobalInfo.Flashlight.LIGHT_SWITCH_SPEED then
			return Enum.ContextActionResult.Pass
		end
		self.prevClick = time()

		self:TurnOn(not self:IsHeld())

		return Enum.ContextActionResult.Sink
	end

	ContextActionService:BindActionAtPriority(
		"Flashlight",
		activatedFlashlight,
		true,
		3000,
		Enum.KeyCode.F
		--Enum.KeyCode.ButtonL1
	)

	self._cleaner:Add(function()
		ContextActionService:UnbindAction("Flashlight")
	end)
end

--[[
	Cleans up the Light object.

	@param self Light - object
]]
function Light.Cleanup(self: Light)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _cleanup, objects = Utility.Tags.SetObjectListner(Light)

local function getObject(): typeof(Light.new())?
	local instance = Utility.Tags.GetUnique(Light.TAG_NAME)
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
		return
	end

	root:AddTag(Light.TAG_NAME)
end

tagCharacter()
player.CharacterAdded:Connect(function()
	tagCharacter()
end)

-------------------------------------------------------------------------------------------

local Flashlight = {}

--[[
    Will determine if the player is allowed to use there flashlight or not.

    @param activate boolean - can it be activated by player?
]]
function Flashlight.SetCanActivate(activate: boolean)
	canActivate = activate
end

--[[
    Checks if the flashlight was activated so it can be used.

    @return boolean - is it possible to activate?
]]
function Flashlight.GetCanActivate(): boolean
	return canActivate
end

--[[
    Checks if the Player is currently holding there light or not.

    @return boolean - is the player holding a light?
]]
function Flashlight.HoldingLight(): boolean
	local object = getObject()
	if not object then
		return false
	end

	return object:IsHeld()
end

--[[
    Puts the light in the players hand or puts it away.

    This only works if there Flashlight is Active.

    @param holding boolean - should the player be holding the light currently?
]]
function Flashlight.SetLight(holding: boolean)
	local object = getObject()
	if not object then
		return
	end

	object:TurnOn(holding)
end

return Flashlight
