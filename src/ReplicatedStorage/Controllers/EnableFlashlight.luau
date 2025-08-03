--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FlashlightUtility = require(ReplicatedStorage.ClientCommon.FlashlightUtility)

task.delay(1, function()
	FlashlightUtility.SetCanActivate(true)
end)

return {}
