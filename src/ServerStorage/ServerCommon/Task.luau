--!strict

local Players = game:GetService("Players")

local Task = {}

--[[
	Create a new task for the player to follow.

	@param name string - the unique name of the objective
	@param text string - the text of the new objective
]]
function Task.New(name: string, text: string)
	Players:SetAttribute("_TaskName", name)
	Players:SetAttribute("_Task", text)
end

--[[
	Update the current task if the name matches. And return a result depending on the task being the same or not.

	@param name string - the unique name of the objective
	@param text string - the text of the new objective

	@return boolean - success of update
]]
function Task.Update(name: string, text: string): boolean
	if Players:GetAttribute("_TaskName") ~= name then
		return false
	end
	Players:SetAttribute("_Task", text)

	return true
end

--[[
	Clear the player of the current task.
]]
function Task.Remove()
	Players:SetAttribute("_TaskName", nil)
	Players:SetAttribute("_Task", nil)
end

--[[
	Get the name of the current Task.

	@return string? - name of the objective
]]
function Task.FetchCurrentName(): string?
	return Players:GetAttribute("_TaskName") :: string?
end

return Task
