--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InfoBoxUtility = require(ReplicatedStorage.ClientCommon.InfoBoxUtility)

task.spawn(function()
	while task.wait(Random.new():NextNumber(0.5, 10)) do
		InfoBoxUtility.AddFullLocalLine(
			tostring(Random.new():NextInteger(0, 99999999))
				.. "This is to test how long an info line can be AHHHHHHHHHHHHH!!!!!!",
			10
		)
	end
end)

return {}
