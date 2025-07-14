--!strict

local Players = game:GetService("Players")

local Task = {}

--[[
	Create a new task for the player to follow

	@param text string - the text of the new objective
]]
function Task.New(text: string)
	Players:SetAttribute("_Task", text)
end

--[[
	Clear the player of tasks
]]
function Task.Remove()
	Players:SetAttribute("_Task", nil)
end

return Task
