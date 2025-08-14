--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local HighlightPrompt = require(ReplicatedStorage.ClientCommon.HighlightPrompt)

local exampleFolder = workspace:WaitForChild("Examples")
local taskExamples = exampleFolder:WaitForChild("Task")

local newTask = taskExamples:FindFirstChild("NewTask") :: Part
local updateTask = taskExamples:FindFirstChild("UpdateTask") :: Part
local removeTask = taskExamples:FindFirstChild("RemoveTask") :: Part

local newTaskPrompt = HighlightPrompt.Create(newTask)
HighlightPrompt.SetHighlightPreset(newTaskPrompt, "Confirm")
newTaskPrompt.Activated:Connect(function()
	RedEvents.Network.Client.Examples:FireServer("Task", "New")
end)

local updateTaskPrompt = HighlightPrompt.Create(updateTask)
HighlightPrompt.SetHighlightPreset(updateTaskPrompt, "Confirm")
updateTaskPrompt.Activated:Connect(function()
	RedEvents.Network.Client.Examples:FireServer("Task", "Update")
end)

local removeTaskPrompt = HighlightPrompt.Create(removeTask)
HighlightPrompt.SetHighlightPreset(removeTaskPrompt, "Deny")
removeTaskPrompt.Activated:Connect(function()
	RedEvents.Network.Client.Examples:FireServer("Task", "Remove")
end)

return {}
