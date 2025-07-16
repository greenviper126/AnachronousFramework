--!strict

local DEFAULT_MOUSE_IMAGE = 9129033463 --white circle
local MOUSE_OFFSET = 57 -- I think what causes this is the Roblox TopBar

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Input = require(ReplicatedStorage.Packages.input)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local mouse = {}

--mouse dot
local MouseGUI = Instance.new("ScreenGui")
MouseGUI.DisplayOrder = 499
MouseGUI.ResetOnSpawn = false
MouseGUI.Name = "Mouse"

local dot = Instance.new("ImageLabel")
dot.Name = "Dot"
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.fromScale(0.5, 0.5)
dot.Size = UDim2.new(0.03, 10, 0.03, 10)
dot.SizeConstraint = Enum.SizeConstraint.RelativeXX
dot.Image = "rbxassetid://" .. DEFAULT_MOUSE_IMAGE
dot.BackgroundTransparency = 1
dot.ScaleType = Enum.ScaleType.Crop
dot.Parent = MouseGUI

MouseGUI.Parent = player.PlayerGui

--moves the dot to the real mouse position
RunService.PreRender:Connect(function()
	local mousePosition = Input.Mouse:GetPosition()
	dot.Position = UDim2.fromOffset(mousePosition.X, mousePosition.Y - MOUSE_OFFSET)

	UserInputService.MouseIconEnabled = false --this should never appear
end)

--[[
	Set the image used for the players mouse
]]
function mouse.SetImage(imageID: number?)
	dot.Image = "rbxassetid://" .. (imageID or DEFAULT_MOUSE_IMAGE)
end

--[[
	Sets the visibility of the mouse
]]
function mouse.SetOn(on: boolean)
	dot.Visible = on
end

return mouse
