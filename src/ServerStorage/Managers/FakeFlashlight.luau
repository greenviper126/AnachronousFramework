--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local fakeFlashlight = ReplicatedStorage.PlayerFlashlight:WaitForChild("FakeFlashlight") :: Part

local function SetFlashlight(player: Player, character: Model)
	local leftHand = character:WaitForChild("LeftHand") :: BasePart
	local attachment = leftHand:WaitForChild("LeftGripAttachment") :: Attachment

	local currentLight: Part? = nil
	local function removeFlashlight()
		if currentLight then
			currentLight:Destroy()
		end
	end

	local function createFlashlight()
		removeFlashlight()

		local newFakeFlashlight = fakeFlashlight:Clone()
		newFakeFlashlight:PivotTo(attachment.WorldCFrame * CFrame.new(0.2, 0, 0) * CFrame.Angles(math.rad(-90), 0, 0))
		newFakeFlashlight.Parent = leftHand
		currentLight = newFakeFlashlight

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = leftHand
		weld.Part1 = newFakeFlashlight
		weld.Parent = leftHand
	end

	local connection = RedEvents.Network.Client.FlashlightState:OnServer(function(playerWhoFired, on)
		if playerWhoFired ~= player then
			return
		end

		if on then
			createFlashlight()
		else
			removeFlashlight()
		end
	end)

	character.AncestryChanged:Once(connection)
end

local function GetCharacter(player: Player)
	if player.Character then
		SetFlashlight(player, player.Character)
	end

	player.CharacterAdded:Connect(function(character: Model)
		SetFlashlight(player, character)
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	GetCharacter(player)
end
Players.PlayerAdded:Connect(GetCharacter)

return {}
