--!strict

--[[these need to run once on server before client joins]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

require(ReplicatedStorage.RedEvents)
require(ReplicatedStorage.Common.Inventory)
require(ReplicatedStorage.Common.Sounds)

return {}
