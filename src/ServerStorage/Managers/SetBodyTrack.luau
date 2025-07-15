--!strict

--[[
    Sets CFrame values onto payer so its not just local
    Should be fine since player cannot see them self in game
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

RedEvents.Network.Client.BodyCFrame:SetServerListener(function(player: Player, neckCFrame: CFrame, waistCFrame: CFrame)
	if player.Character == nil then
		return
	end

	local head = player.Character:FindFirstChild("Head")
	local upperTorso = player.Character:FindFirstChild("UpperTorso")

	if head == nil or upperTorso == nil then
		return
	end

	local neck = head:FindFirstChild("Neck") :: Motor6D?
	local waist = upperTorso:FindFirstChild("Waist") :: Motor6D?

	if neck == nil or waist == nil then
		return
	end

	neck.C0 = neckCFrame
	waist.C0 = waistCFrame
end)

return {}
