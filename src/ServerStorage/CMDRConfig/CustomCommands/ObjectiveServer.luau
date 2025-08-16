--!strict

local ServerStorage = game:GetService("ServerStorage")

local Task = require(ServerStorage.ServerCommon.Task)

local function update(name: string, description: string)
	local result = Task.Update(name, description)

	if result then
		return ("Objective was successfully updated using name %s."):format(name)
	else
		return ("There currently is no objective to update called %s."):format(name)
	end
end

return function(_data, action, name, description)
	if action == "New" then
		Task.New(name, description)

		return ("A new Objective was added named %s."):format(name)
	elseif action == "Update" then
		local fetchedName = Task.FetchCurrentName()
		if fetchedName then
			return update(fetchedName, name)
		else
			return "There currently is no objective to update!"
		end
	elseif action == "Remove" then
		Task.Remove()

		return "The current Objective was removed."
	end

	return ("%s is not a valid action of Objectives!"):format(action)
end
