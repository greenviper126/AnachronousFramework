--!strict

local ServerStorage = game:GetService("ServerStorage")

local PlayerStatus = require(ServerStorage.ServerCommon.PlayerStatus)

return function(_data, players)
	local names = {}
	for _, player in pairs(players) do
		PlayerStatus.KillPlayer(player)
		table.insert(names, player.Name)
	end

	return table.concat(names, ", ") .. ": were killed!"
end
