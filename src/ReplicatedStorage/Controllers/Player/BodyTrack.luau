--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local RedEvents = require(ReplicatedStorage.RedEvents)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local neckC0 = CFrame.new(0, 0.8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
local waistC0 = CFrame.new(0, 0.2, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)

RunService.RenderStepped:Connect(function()
	if player.Character == nil then
		return
	end

	local camera = workspace.CurrentCamera
	local root = player.Character:FindFirstChild("HumanoidRootPart")

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

	local theta = math.asin(camera.CFrame.LookVector.y) -- for looking up and down

	local camera_angle = math.atan2(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Z)
	local body_angle = math.atan2(root.CFrame.LookVector.X, root.CFrame.LookVector.Z)
	local theta2 = (camera_angle - body_angle) % (2 * math.pi) -- for looking left and right

	if theta2 > math.pi / 2 and theta2 < math.pi * 1.5 then
		theta2 = math.pi - theta2
	end

	-- this will set it locally for this player
	local neck, waist = head.Neck, upperTorso.Waist
	neck.C0 = neckC0 * CFrame.Angles(theta * 0.5, -theta2, 0)
	waist.C0 = waistC0 * CFrame.Angles(theta * 0.5, 0, 0)

	-- this is for other players to see
	local neckCFrame = neckC0 * CFrame.Angles(theta * 0.5, -theta2, 0)
	local waistCFrame = waistC0 * CFrame.Angles(theta * 0.5, 0, 0)
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

	neck.C0 = neckC0:Lerp(neckCFrame, 0.2)
	waist.C0 = waist.C0:Lerp(waistC0, 0.2)
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
			targetCFrames[playerTriggered.UserId] = { neckCFrame = CFrame.new(), waistCFrame = CFrame.new() }
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
