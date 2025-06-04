--!strict

--[[
	functions and stuff to help with level design
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

--[[
local MapManager = require(ServerStorage.Modules.MapManager)
local TaskManager = require(ServerStorage.Modules.TaskManager)
local SpawnManager = require(ServerStorage.Modules.SpawnManager)
local AudioManager = require(ServerStorage.Modules.AudioManager)
local LightingManager = require(ServerStorage.Modules.LightingManager)

local GlobalInfo = require(ReplicatedStorage.Common.GlobalInfo)
local Sounds = require(ReplicatedStorage.Common.Sounds)
local PivotTween = require(ReplicatedStorage.Common.PivotTween)
local EventSync = require(ReplicatedStorage.Common.EventSync)


local Events = ReplicatedStorage:WaitForChild("Events")

export type MapModule = MapManager.MapModule
export type MapConfig = MapManager.MapConfig



local GameplayTools = {}

GameplayTools.Trove = Trove

GameplayTools.MapManager = MapManager
GameplayTools.TaskManager = TaskManager
GameplayTools.SpawnManager = SpawnManager
GameplayTools.AudioManager = AudioManager
GameplayTools.LightingManager = LightingManager

GameplayTools.Sounds = Sounds
GameplayTools.GlobalInfo = GlobalInfo
GameplayTools.PivotTween = PivotTween
GameplayTools.EventSync = EventSync

GameplayTools.Events = Events

function GameplayTools.InitMap(mapName:string, spawns:{string}?):(Folder, Folder, Folder)
	local map, scripted, storage = MapManager.TryLoad(mapName)
	
	if spawns then
		SpawnManager.SetNewSpawns(table.unpack(spawns))
	end
	
	LightingManager.SetLighting(mapName)
	AudioManager.SetAudio(mapName)
	
	task.delay(3, function()
		if spawns then
			SpawnManager.ReloadPlayers()
		end
	end)
	
	return map, scripted, storage
end

function GameplayTools.Info(text:string, weight:number, player:Player?, name:string?, pitch:number?):number
	if player then
		Events.GlobalInfo:FireClient(player, name, pitch, text, weight)
	else
		Events.GlobalInfo:FireAllClients(name, pitch, text, weight)
	end
	
	return (#text/GlobalInfo.InfoText.CHAR_PER_SEC + 3)--time it takes to talk
end

function GameplayTools.GlobalConversation(config:Configuration):number
	Events.GlobalConversation:FireAllClients(config)
	
	local waitTime = 3
	
	for _, line in pairs(config:GetChildren()) do
		if not line:IsA("StringValue") then continue end
		waitTime += (#line.Value/GlobalInfo.InfoText.CHAR_PER_SEC + 3)
	end
	
	return waitTime
end

function GameplayTools.PlayerTouchedPart(part:BasePart, once:boolean, func:()->()):RBXScriptConnection
	local connection:RBXScriptConnection
	connection = part.Touched:Connect(function(part)
		if not Players:GetPlayerFromCharacter(part.Parent) then return end
		
		func()
		
		if connection and once then
			connection:Disconnect()
		end
	end)
	return connection
end
]]

return {}
