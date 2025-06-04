--!strict

local Players = game:GetService("Players")

local Task = {}

function Task.New(text: string)
	Players:SetAttribute("_Task", text)
end

function Task.Remove()
	Players:SetAttribute("_Task", nil)
end

return Task
