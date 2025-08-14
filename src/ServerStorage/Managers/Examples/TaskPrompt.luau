--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Task = require(ServerStorage.ServerCommon.Task)

local RedEvents = require(ReplicatedStorage.RedEvents)

RedEvents.Network.Client.Examples:OnServer(function(_player: Player, class: string, name: string)
	if class ~= "Task" then
		return
	end

	if name == "New" then
		Task.New("Test1", "Find all items in the map (0/2)")
	elseif name == "Update" then
		Task.Update("Test1", "Find all items in the map (1/2)")
	elseif name == "Remove" then
		Task.Remove()
	end
end)

return {}
