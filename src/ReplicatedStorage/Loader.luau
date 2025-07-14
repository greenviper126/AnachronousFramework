--!strict

local RunService = game:GetService("RunService")

--starts modules from selected folder
local function LoadFromFile(file: Instance)
	local _files: { any } = {}
	local fileRead = ""

	local function addModules(currentFile: Instance)
		for _, v in pairs(currentFile:GetChildren()) do
			if v:IsA("Folder") then
				addModules(v)
			elseif v:IsA("ModuleScript") then
				fileRead = fileRead .. "\t" .. v.Name .. "\n"

				task.spawn(function()
					table.insert(_files, require(v) :: any)
				end)
			end
		end
	end

	addModules(file)

	local isServer = RunService:IsServer()

	print(
		string.format(
			"\n[[------------loading %s file on %s------------]]\n %s ------------------------------------\n\n",
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
