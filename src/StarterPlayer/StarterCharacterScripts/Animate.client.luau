--!strict

local ALMOST_ZERO = 0.001 -- to fix weight issue
export type animations<T> = {
	Idle: T,
	Walk: T,
	Run: T,
	Fall: T,
	CrouchWalk: T,
	CrouchIdle: T,
}

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GlobalInfo = require(ReplicatedStorage.GlobalInfo)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid") :: Humanoid
local animator = humanoid:WaitForChild("Animator") :: Animator
local root = character:WaitForChild("HumanoidRootPart") :: BasePart

local crouching = false

local loadedAnimations = {} :: animations<AnimationTrack>
local animNames: animations<number> = {
	Idle = 507766388,
	Walk = 913402848,
	Run = 913376220,
	Fall = 507767968,
	CrouchWalk = 119591081252846,
	CrouchIdle = 102924379198805,
}

local animationPriority: animations<Enum.AnimationPriority> = {
	Idle = Enum.AnimationPriority.Idle,
	Walk = Enum.AnimationPriority.Movement,
	Run = Enum.AnimationPriority.Movement,
	Fall = Enum.AnimationPriority.Movement,
	CrouchWalk = Enum.AnimationPriority.Movement,
	CrouchIdle = Enum.AnimationPriority.Idle,
}

local function newAnimation(name: string, id: number): Animation
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. id
	animation.Name = name
	animation.Parent = script

	return animation
end

local function SetAndLoadAnimation(animation: Animation, priority: Enum.AnimationPriority): AnimationTrack
	local loadedAnimation = animator:LoadAnimation(animation)
	loadedAnimation.Priority = priority
	loadedAnimation.Looped = true
	loadedAnimation:AdjustSpeed(1)
	loadedAnimation:Play()

	loadedAnimation:AdjustWeight(ALMOST_ZERO)

	return loadedAnimation
end

-- load animation tracks
for name, id in pairs(animNames) do
	loadedAnimations[name] = SetAndLoadAnimation(newAnimation(name, id), animationPriority[name])
end

--run and walk and crouch animation
RunService.Heartbeat:Connect(function()
	local velocity = root.AssemblyLinearVelocity
	local velocityXZ = Vector3.new(velocity.X, 0, velocity.Z)

	local crouchingRatio = math.clamp(
		math.floor(velocityXZ.Magnitude / GlobalInfo.MOVEMENT.SPEED.CROUCHING * 100) / 100,
		0,
		GlobalInfo.MOVEMENT.SPEED.RUNNING
	)
	local walkingRatio = math.clamp(
		math.floor(velocityXZ.Magnitude / GlobalInfo.MOVEMENT.SPEED.WALKING * 100) / 100,
		0,
		GlobalInfo.MOVEMENT.SPEED.RUNNING
	)
	local runningRatio = math.clamp(
		math.floor(velocityXZ.Magnitude / GlobalInfo.MOVEMENT.SPEED.RUNNING * 100) / 100,
		0,
		GlobalInfo.MOVEMENT.SPEED.RUNNING
	)

	if walkingRatio >= 1.1 then -- running
		loadedAnimations.Run:AdjustWeight(runningRatio)
		loadedAnimations.Walk:AdjustWeight(ALMOST_ZERO)
	else -- walking
		loadedAnimations.Walk:AdjustWeight(walkingRatio)
		loadedAnimations.Run:AdjustWeight(ALMOST_ZERO, 0.5)
	end

	--idle
	if crouching then
		loadedAnimations.CrouchIdle:AdjustWeight(math.clamp(1 - crouchingRatio, ALMOST_ZERO, 1))
		loadedAnimations.Idle:AdjustWeight(0)
	else -- regular
		loadedAnimations.Idle:AdjustWeight(math.clamp(1 - walkingRatio, ALMOST_ZERO, 1))
		loadedAnimations.CrouchIdle:AdjustWeight(ALMOST_ZERO)
	end

	--loadedAnimations.Fall:AdjustWeight(math.clamp( velocity.Y, ALMOST_ZERO, 1))

	loadedAnimations.CrouchIdle:AdjustWeight(ALMOST_ZERO)
	loadedAnimations.CrouchWalk:AdjustWeight(ALMOST_ZERO)
	loadedAnimations.Fall:AdjustWeight(ALMOST_ZERO)
end)
