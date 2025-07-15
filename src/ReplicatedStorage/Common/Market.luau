--!strict

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.promise)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local Market = {}

Market.Id = {
	GamePasses = {
		BetterFlashlight = 0,
	},
	Subscriptions = {},
}

--[[
	Checks if the local player has the specified Gamepass

	@param Id number -  the ID of the Gamepass

	@return boolean - was it successful
]]
function Market.LocalPlayerOwnsGamepass(Id: number, attempts: number?): boolean
	local maxAttempts = attempts or 5
	local currentAttempts = 0

	local function giveGamepass()
		local success, result = pcall(function()
			return MarketplaceService:UserOwnsGamePassAsync(player, Id)
		end)

		if success then
			return result
		else
			if currentAttempts >= maxAttempts then
				return false
			end
			currentAttempts += 1

			warn("Could not find Gamepass with an Id of " .. Id .. " for player:" .. player.Name)

			giveGamepass()
		end

		return false
	end
	giveGamepass()

	return false
end

return Market
