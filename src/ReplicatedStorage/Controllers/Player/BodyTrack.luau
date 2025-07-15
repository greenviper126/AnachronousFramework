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

	-- this will set it locally for the player
	--local neck, waist = head.Neck, upperTorso.Waist
	--neck.C0 = neckC0 * CFrame.Angles(theta * 0.5, -theta2, 0)
	--waist.C0 = waistC0 * CFrame.Angles(theta * 0.5, 0, 0)

	local neckCFrame = neckC0 * CFrame.Angles(theta * 0.5, -theta2, 0)
	local waistCFrame = waistC0 * CFrame.Angles(theta * 0.5, 0, 0)
	RedEvents.Network.Client.BodyCFrame:FireServer(neckCFrame, waistCFrame)
end)

return {}
