--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local GlobalInfo = require(ReplicatedStorage.Common.GlobalInfo)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local hoverFocus = player:WaitForChild("HoverFocus") :: ObjectValue

local HoverClick = {}

--make a basepart clickable
function HoverClick.New(parent: BasePart, imageId: number?)
	local hoverId = Instance.new("IntValue")
	hoverId.Name = "Hover"
	hoverId.Parent = parent
	hoverId.Value = imageId or 0

	return hoverId
end

--current object that the player is hover over if any
function HoverClick.CurrentHover(): Instance?
	return hoverFocus.Value
end

--returns a hoverId if found in the instance
function HoverClick.GetHoverFromInstance(parent: Instance): IntValue?
	local object = parent:FindFirstChild("HoverId", true)
	return (object and object:IsA("IntValue")) and object or nil
end

--checks if the given instances contains the given focus
function HoverClick.InstanceContainsUniqueInstance(parent: Instance, child: Instance): boolean
	for _, inst in pairs(parent:GetDescendants()) do
		if inst ~= child then
			continue
		end

		return true
	end

	return false
end

--clickspeed determines how fast a basepart can be clicked and detected
--func  for feeding a function on click event
function HoverClick.OnObjectClick(clickSpeed: number?, func: (object: Instance) -> ()): RBXScriptConnection
	local running = false
	return UserInputService.InputEnded:Connect(function(input: InputObject)
		if not hoverFocus.Value then
			return
		end
		if not GlobalInfo.UniversalInput.LeftClick(input) then
			return
		end
		if running then
			return
		end
		running = true

		func(hoverFocus.Value)

		task.wait(clickSpeed or 0.1)

		running = false
	end)
end

return HoverClick
