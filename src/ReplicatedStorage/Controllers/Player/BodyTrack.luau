--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RedEvents = require(ReplicatedStorage.RedEvents)

local GlobalInfo = require(ReplicatedStorage.GlobalInfo)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

RunService.RenderStepped:Connect(function(delta: number)
	if player.Character == nil then
		return
	end

	local camera = workspace.CurrentCamera
	local root = player.Character:FindFirstChild("HumanoidRootPart") :: Part

	if not root or not camera then
		return
	end

	local head = player.Character.Head
	local upperTorso = player.Character.UpperTorso

	if head == nil or head:FindFirstChild("Neck") == nil then
		return
	end
	if upperTorso == nil or upperTorso:FindFirstChild("Waist") == nil then
		return
	end

	-- for looking up and down
	local theta = math.asin(camera.CFrame.LookVector.y)

	-- this is for rotating the waist
	local rotationVelocity = -math.sin(root.AssemblyAngularVelocity.Unit.Y) * GlobalInfo.MOVEMENT.TRACKING.TURN_STRENGTH
	local currentWaistRotation = waistC0.Rotation.Y + (rotationVelocity - waistC0.Rotation.Y) * delta
	if currentWaistRotation ~= currentWaistRotation then --can be NAN on start
		currentWaistRotation = 0
	end

	--to help prevent snapping on waist
	if math.abs(rotationVelocity) < 0.01 then
		currentWaistRotation = currentWaistRotation * 0.95
	end

	-- this will set it locally for this player
	local neck, waist = head.Neck, upperTorso.Waist
	local neckCFrame = neckC0 * CFrame.Angles(theta * 0.5, 0, 0)
	local waistCFrame = waistC0 * CFrame.Angles(theta * 0.5, currentWaistRotation, 0)

	neck.C0 = neck.C0:Lerp(neckCFrame, GlobalInfo.MOVEMENT.TRACKING.LOOK_LERP_SPEED)
	waist.C0 = waist.C0:Lerp(waistCFrame, GlobalInfo.MOVEMENT.TRACKING.LOOK_LERP_SPEED)

	-- this is for other players to see
	RedEvents.Network.Client.BodyCFrame:FireServer(neckCFrame, waistCFrame)
end)

--Other Players

local targetCFrames: { [number]: { neckCFrame: CFrame, waistCFrame: CFrame } } = {}

local function setMotors(playerTriggered: Player, neckCFrame: CFrame, waistCFrame: CFrame)
	if playerTriggered.Character == nil then
		return
	end

	local head = playerTriggered.Character:FindFirstChild("Head")
	local upperTorso = playerTriggered.Character:FindFirstChild("UpperTorso")

	if head == nil or upperTorso == nil then
		return
	end

	local neck = head:FindFirstChild("Neck") :: Motor6D?
	local waist = upperTorso:FindFirstChild("Waist") :: Motor6D?

	if neck == nil or waist == nil then
		return
	end

	neck.C0 = neck.C0:Lerp(neckCFrame, GlobalInfo.MOVEMENT.TRACKING.LOOK_LERP_SPEED)
	waist.C0 = waist.C0:Lerp(waistCFrame, GlobalInfo.MOVEMENT.TRACKING.LOOK_LERP_SPEED)
end

Players.PlayerRemoving:Connect(function(playerRemoved: Player)
	targetCFrames[playerRemoved.UserId] = nil
end)

RedEvents.Network.Server.ServerBodyCFrame:SetClientListener(
	function(playerTriggered: Player, neckCFrame: CFrame, waistCFrame: CFrame)
		if playerTriggered == player then
			return
		end

		if not targetCFrames[playerTriggered.UserId] then
			targetCFrames[playerTriggered.UserId] = { neckCFrame = neckCFrame, waistCFrame = waistCFrame }
		end

		local playerTargets = targetCFrames[playerTriggered.UserId]
		playerTargets.neckCFrame = neckCFrame
		playerTargets.waistCFrame = waistCFrame
	end
)

RunService.RenderStepped:Connect(function()
	for playerId, info in pairs(targetCFrames) do
		local playerTriggered = Players:GetPlayerByUserId(playerId)
		if not playerTriggered then
			continue
		end

		setMotors(playerTriggered, info.neckCFrame, info.waistCFrame)
	end
end)

return {}
