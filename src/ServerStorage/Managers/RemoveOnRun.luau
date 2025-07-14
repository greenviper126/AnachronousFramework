--!strict

local folder = workspace:FindFirstChild("RemoveOnRun")
if folder then
	folder:Destroy()
else
	warn("Could not locate the RemoveOnRun Folder in Workspace")
end

return {}
