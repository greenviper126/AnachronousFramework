--!strict

local Players = game:GetService("Players")

local Admin = {}

Admin.IDs = {
	295701650, --fatmad
	2221989135, --viper
}

--[[
	Checks if the provided ID is from an admin
]]
function Admin.IsAdmin(id: number): boolean
	return table.find(Admin.IDs, id) ~= nil
end

--[[
	Checks if local player is an admin

	only works locally
]]
function Admin.IsLocalAdmin(): boolean
	local player = Players.LocalPlayer
	if not player then
		return false
	end
	return Admin.IsAdmin(player.UserId)
end

return Admin
