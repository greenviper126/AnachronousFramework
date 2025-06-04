--!strict

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local MapLoader = require(ServerStorage.ServerCommon.MapLoader)
local MapConfig = require(ServerStorage.ServerCommon.MapConfig)

local function gameComplete()
	print("Game Complete")

	--have credits UI run
	RedEvents.Network.Server.RoleCredits:FireAllClients()
end

print("Start of Game")

local start, _stop = MapLoader.SetMapProgression(MapConfig.Data, gameComplete)
start(MapConfig.Data[1] or "Intro") --whatever needs to be first

RedEvents.Signal.Server.LoadMap:Connect(function(mapName: string)
	start(mapName) --load map command
end)

return {}
