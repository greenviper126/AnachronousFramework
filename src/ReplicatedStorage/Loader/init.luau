--!strict

local RunService = game:GetService("RunService")

local assetsLoader = require(script.AssetLoader)

--starts modules from selected folder
local function LoadFromFile(file: Instance)
	local _files: { any } = {}
	local fileRead = ""

	local function addModules(currentFile: Instance)
		for _, v in pairs(currentFile:GetChildren()) do
			if v:IsA("Folder") then
				addModules(v)
			elseif v:IsA("ModuleScript") then
				local success, result = pcall(function()
					return require(v) :: any
				end)

				if not success then
					fileRead = fileRead .. "\t" .. v.Name .. " ERROR \n"
					warn(v.Name .. " module did not load correctly!")
				else
					fileRead = fileRead .. "\t" .. v.Name .. "\n"
					table.insert(_files, result)
				end
			end
		end
	end

	addModules(file)

	local isServer = RunService:IsServer()

	print(
		string.format(
			"\n[[------------loading %s file on %s------------]]\n %s --------------------------------------------------------\n\n",
			file.Name,
			isServer and "Server" or "Client",
			fileRead
		)
	)
end

--[[
	Initializes Modules depending on it running in server or on client

	@return () -> () - Will setup modules on server or client depending on where this is called
]]
return function()
	if RunService:IsServer() then
		assetsLoader()

		local ServerStorage = game:GetService("ServerStorage")
		local managers = ServerStorage:FindFirstChild("Managers")

		LoadFromFile(managers)
	elseif RunService:IsClient() then
		task.wait(1) --let instances load in

		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local controllers = ReplicatedStorage:WaitForChild("Controllers")

		LoadFromFile(controllers)
	end
end
