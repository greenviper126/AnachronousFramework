--!strict

--[[
    These need to run once locally for client

    These are mostly meant for modules that need to be accessed by other scripts but still need initialization
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.Common.Sounds)
require(ReplicatedStorage.Common.Inventory)

require(ReplicatedStorage.ClientCommon.CameraBobbing)
require(ReplicatedStorage.ClientCommon.Flashlight).SetCanActivate(true)

--UI
require(ReplicatedStorage.ClientCommon.Mouse)
require(ReplicatedStorage.ClientCommon.Stamina)

return {}
