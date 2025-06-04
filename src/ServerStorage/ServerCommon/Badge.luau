--!strict

local BadgeService = game:GetService("BadgeService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Promise = require(ReplicatedStorage.Packages.promise)

local Badge = {}

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

return Badge
