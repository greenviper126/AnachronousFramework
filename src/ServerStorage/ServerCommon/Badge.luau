--!strict

local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Promise = require(ReplicatedStorage.Packages.promise)

local Badge = {}

--[[
	badge id's that can be used in the give function
]]
Badge.Badges = {
	JoinedTheGame = 00000,
	Test = 00000,
}

--[[
	Attempts to give the given badge to the given player

	there is an optional parameter for retry's
]]
function Badge.Give(player: Player, badgeId: number, attempts: number?)
	local function giveBadge()
		return Promise.new(function(resolve, reject)
			local success = BadgeService:AwardBadge(player.UserId, badgeId)

			if not success then
				reject("Could not award Badge to " .. player.Name)
			else
				resolve()
			end
		end):catch(warn)
	end

	Promise.retry(giveBadge, attempts or 5):catch(warn)
end

--[[
	Similar to give function but gives badges to all current players
]]
function Badge.GiveAll(badgeId: number, attempts: number?)
	for player in Players:GetPlayers() do
		Badge.Give(player, badgeId, attempts)
	end
end

return Badge
