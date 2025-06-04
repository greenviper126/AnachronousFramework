--!strict

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalInfo = require(ReplicatedStorage.Common.GlobalInfo)
local Badge = require(ServerStorage.ServerCommon.Badge)

task.wait(GlobalInfo.Clock.BADGE_TIME)

print("Clock Badge Awarded")
for _, player in pairs(Players:GetPlayers()) do
	Badge.Give(player, 19273629)
end

return {}
