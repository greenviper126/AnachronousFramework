--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Trove = require(ReplicatedStorage.Packages.trove)
local Dash = require(ReplicatedStorage.Packages.dash)

export type MapModule = { Start: () -> (), Stop: () -> (), Name: string }
export type MapConfig = { [number]: { { Chance: number, Map: ModuleScript } } }

local function createFolderRead()
	local maps = ServerStorage:WaitForChild("Maps")

	local newMaps = Instance.new("Configuration")
	newMaps.Name = "MapReader"
	newMaps:AddTag("KeepOnRun") --keep on workspace cleanup
	newMaps.Parent = workspace

	for _, map in pairs(maps:GetChildren()) do
		local newMap = Instance.new("Configuration")
		newMap.Name = map.Name
		newMap.Parent = newMaps
	end
end

local function storeMaps(): { string: () -> () }
	local storedMaps = {}

	createFolderRead()

	local maps = ServerStorage:WaitForChild("Maps")

	local currentMap = Instance.new("Folder")
	currentMap.Name = "CurrentMap"
	currentMap:AddTag("KeepOnRun")
	currentMap.Parent = workspace

	local mapStorage = Instance.new("Folder")
	mapStorage.Name = "CurrentMapStorage"
	mapStorage:AddTag("KeepOnRun")
	mapStorage.Parent = ServerStorage

	for _, map in pairs(maps:GetChildren()) do
		storedMaps[map.Name] = function()
			local oldMap = currentMap:GetChildren()
			local oldMapStorage = mapStorage:GetChildren()
			task.delay(5, function()
				for _, v in pairs(oldMap) do
					v:Destroy() --remove old map
				end
				for _, v in pairs(oldMapStorage) do
					v:Destroy() --remove old map storage
				end
			end)

			local newMap = map:Clone()
			newMap.Parent = currentMap

			local scriptedFolder = newMap:FindFirstChild("Scripted") :: Folder

			return newMap, scriptedFolder, mapStorage
		end
	end

	return storedMaps
end

local function setProggression(complete: () -> (), config: MapConfig): ((string) -> (), () -> ())
	local cleaner: typeof(Trove.new())
	local function stop()
		if cleaner then
			cleaner:Destroy()
		end
	end

	local function findInstFromName(tbl: { { Chance: number, Map: ModuleScript } }, name: string): ModuleScript?
		local result = Dash.find(tbl, function(a0)
			return a0.Map.Name == name
		end)

		return result and result.Map or nil
	end

	local function selectRndMap(tbl: { { Chance: number, Map: ModuleScript } }): ModuleScript?
		local sum = Dash.reduce(tbl, function(a0: number, a1)
			return a0 + a1.Chance
		end, 0)

		local currentSum = 0
		local rnd = Random.new():NextInteger(1, sum)
		local rndModule = Dash.find(tbl, function(module)
			currentSum += module.Chance
			return currentSum >= rnd
		end)

		local rndBackup = table.unpack(tbl) --just in case it cant find a map
		local rndMap: ModuleScript? = rndModule and rndModule.Map or (rndBackup and rndBackup.Map or nil)

		if not rndMap then
			warn("Could not find a map in config, config file: ", config)
		end

		return rndMap
	end

	local function start(map: string)
		stop()
		cleaner = Trove.new()

		local foundFirstMap = false
		cleaner:Add(task.spawn(function()
			for i = 1, 1000 do --cant use ipairs because it skips part of the array
				if not config[i] then
					continue
				end
				local maps = config[i]

				local firstMap = findInstFromName(maps, map)
				local mapToLoad: ModuleScript? = nil

				if firstMap and not foundFirstMap then
					foundFirstMap = true
					mapToLoad = firstMap
				else
					mapToLoad = selectRndMap(maps)
				end

				if not foundFirstMap then
					continue
				end

				local mapModule = require(mapToLoad) :: any

				workspace:SetAttribute("Map", mapModule.Name)
				print("Loaded " .. mapModule.Name)

				mapModule.Start()
			end

			complete()
		end))
	end

	return start, stop
end

local maps = storeMaps()
local MapManager = {}

MapManager.Maps = maps

function MapManager.SetMapProgression(config: MapConfig, complete: () -> ()): ((string) -> (), () -> ())
	assert(typeof(complete) == "function", typeof(complete) .. " is not a function.")
	assert(typeof(config) == "table", typeof(config) .. " is not a table.")

	return setProggression(complete, config)
end

function MapManager.TryLoad(map: string): (Folder, Folder, Folder)
	local newMap = maps[map]
	assert(newMap, "Could not load map named " .. map .. ".")

	return newMap()
end

return MapManager
