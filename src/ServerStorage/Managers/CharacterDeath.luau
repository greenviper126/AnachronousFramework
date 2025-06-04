--!strict

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CharacterHealth = require(ServerStorage.ServerCommon.CharacterHealth)
local CharacterSpawner = require(ServerStorage.ServerCommon.CharacterSpawner)

local RedEvents = require(ReplicatedStorage.RedEvents)

--client asked to respawn
local respawnLimit = RedEvents.Ratelimit(1, 5) --1 respawn per 5 sec
RedEvents.Network.Client.Respawn:OnServer(function(player: Player)
	if not respawnLimit(player) then
		warn(player.Name .. " requested for respawn to many times.")
		return
	end

	CharacterHealth.Kill(player)
	task.wait()
	CharacterSpawner.ReloadPlayer(player) --load player on request
end)

local function playerAdded(player: Player)
	player:SetAttribute("_Dead", false)
	CharacterHealth.SetFullHealth(player)
	CharacterSpawner.ReloadPlayer(player) -- first real load

	player.AttributeChanged:Connect(function(attribute)
		if attribute == "_Health" then
			return
		end

		local dead = player:GetAttribute("_Health") <= 0
		player:SetAttribute("_Dead", dead)

		if dead then
			CharacterHealth.Kill(player)
			CharacterSpawner.ReloadPlayer(player, function()
				CharacterHealth.SetFullHealth(player)
			end) -- died
		end
	end)
end

for _, player in pairs(Players:GetPlayers()) do
	task.spawn(playerAdded, player)
end
Players.PlayerAdded:Connect(playerAdded)

return {}
