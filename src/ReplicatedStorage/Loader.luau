--!strict

local RunService = game:GetService("RunService")

--starts modules from selected folder
local function LoadFromFile(file: Instance)
	local files: { any } = {}
	local fileRead = ""

	local function addModules(currentFile: Instance)
		for _, v in pairs(currentFile:GetChildren()) do
			if v:IsA("Folder") then
				addModules(v)
			elseif v:IsA("ModuleScript") then
				fileRead = fileRead .. "\t" .. v.Name .. "\n"

				task.spawn(function()
					table.insert(files, require(v) :: any)
				end)
			end
		end
	end

	addModules(file)

	--may not need this, lets modules know when other modules are ready
	for _, v in pairs(files) do
		pcall(function()
			v.OnStart()
		end)
	end

	print(
		string.format(
			"\n[[------------loading %s file------------]]\n %s ------------------------------------\n\n",
			file.Name,
			fileRead
		)
	)
end

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
