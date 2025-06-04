--!strict

--[[
might not be added to actual game, good for debuging though
]]

local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:Connect(function()
	print("Reset")
	RedEvents.Network.Client.Respawn:FireServer()
end)

StarterGui:SetCore("ResetButtonCallback", resetBindable)

return {}
