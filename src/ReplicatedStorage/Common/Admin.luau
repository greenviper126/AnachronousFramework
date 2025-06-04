--!strict

local Players = game:GetService("Players")

local Admin = {}

Admin.IDs = {
	2221989135, --viper
	295701650, --endy
}

--checks if the provided ID is from an admin
function Admin.IsAdmin(id: number): boolean
	return table.find(Admin.IDs, id) ~= nil
end

--checks if local player is an admin
function Admin.IsLocalAdmin(): boolean
	local player = Players.LocalPlayer
	if not player then
		return false
	end
	return Admin.IsAdmin(player.UserId)
end

return Admin
