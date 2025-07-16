--!strict

--[[
    Sets CFrame values onto payer so its not just local
    Should be fine since player cannot see them self in game
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

RedEvents.Network.Client.BodyCFrame:SetServerListener(function(player: Player, neckCFrame: CFrame, waistCFrame: CFrame)
	RedEvents.Network.Server.ServerBodyCFrame:FireAllClientsExcept(player, player, neckCFrame, waistCFrame)
end)

return {}
