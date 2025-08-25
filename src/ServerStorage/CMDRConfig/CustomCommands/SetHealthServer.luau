--!strict

local ServerStorage = game:GetService("ServerStorage")

local PlayerStatus = require(ServerStorage.ServerCommon.PlayerStatus)

return function(_data, players, amount)
	local names = {}
	for _, player in pairs(players) do
		PlayerStatus.SetHealth(player, amount)
		table.insert(names, player.Name)
	end

	local setAmount = math.clamp(amount, 0, PlayerStatus.GetMaxHealth())

	return table.concat(names, ", ") .. ": had there health set too " .. tostring(setAmount) .. "."
end
