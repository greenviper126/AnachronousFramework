--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Admin = {}

Admin.IDs = {
	295701650, --fatmad
	2221989135, --viper
}

--[[
	Checks if the provided ID is from an admin

	@param id number - id of a roblox player

	@return boolean - was that id an admin?
]]
function Admin.IsAdmin(id: number): boolean
	local isRegular = Players:GetAttribute("AdminIsRegularPlayer") and RunService:IsStudio() --only for studio testing.
	local existsOnLookup = table.find(Admin.IDs, id) ~= nil

	if not isRegular and existsOnLookup then
		return true
	elseif not isRegular and id < 0 then
		return true
	else
		return false
	end
end

--[[
	Checks if local player is an admin
	
	@note only works locally

	@return boolean - is local player admin?
]]
function Admin.IsLocalAdmin(): boolean
	local player = Players.LocalPlayer
	if not player then
		return false
	end
	return Admin.IsAdmin(player.UserId)
end

return Admin
