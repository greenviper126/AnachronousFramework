local ServerStorage = game:GetService("ServerStorage")

local InfoBox = require(ServerStorage.ServerCommon.InfoBox)

return function(_data, players, action, v1, v2, v3)
	local length = 0
	for _, player in pairs(players) do
		if action == "LocalHeader" then
			length = InfoBox.SendLineToPlayer(player, player, v1, v2)
		elseif action == "CustomHeader" then
			length = InfoBox.SendLineToPlayer(player, v1, v2, v3)
		end
	end

	return ("Sent a line that will exist for %s seconds."):format(tostring(length))
end
