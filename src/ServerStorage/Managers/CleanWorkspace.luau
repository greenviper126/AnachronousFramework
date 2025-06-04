--!strict

--[[
	cleans up the workspace when game runs
]]

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local storedWorkspace = Instance.new("Folder")
storedWorkspace.Name = "StoredWorkspace"
storedWorkspace.Parent = ServerStorage

task.wait(1)

for _, inst in pairs(workspace:GetChildren()) do
	if inst:IsA("Terrain") or inst:IsA("Camera") then
		continue
	end

	if not inst:IsA("Folder") then
		inst.Parent = storedWorkspace
	elseif not inst:HasTag("KeepOnRun") then
		inst.Parent = ServerStorage
	end
end

task.wait()

Players:SetAttribute("WorkspaceConfigured", true)

return {}
