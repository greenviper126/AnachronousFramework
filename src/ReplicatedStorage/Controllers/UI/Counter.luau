--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalInfo = require(ReplicatedStorage.Common.GlobalInfo)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local counter = Instance.new("ScreenGui")
counter.Name = "Counter"
counter.DisplayOrder = 20
counter.IgnoreGuiInset = true
counter.ResetOnSpawn = false
counter.ScreenInsets = Enum.ScreenInsets.None
counter.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local clock = Instance.new("TextLabel")
clock.Name = "Clock"
clock.AnchorPoint = Vector2.new(1, 1)
clock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
clock.BackgroundTransparency = 1
clock.BorderColor3 = Color3.fromRGB(0, 0, 0)
clock.BorderSizePixel = 0
clock.FontFace = Font.new("rbxassetid://12187371840")
clock.Position = UDim2.new(1, -3, 1, -3)
clock.RichText = true
clock.Size = UDim2.new(0.1, 15, 0.03, 5)
clock.Text = "00 : 00 : 00"
clock.TextColor3 = Color3.fromRGB(255, 255, 255)
clock.TextScaled = true
clock.TextSize = 20
clock.TextWrapped = true
clock.Parent = counter

counter.Parent = player.PlayerGui

local prevTime = 0
RunService.Heartbeat:Connect(function()
	local intTime = math.round(time())

	if intTime == prevTime then
		return
	end
	prevTime = intTime

	local hr, min, sec = (intTime / 60 / 60) % 60, (intTime / 60) % 60, intTime % 60

	clock.Text = string.format("%02i : %02i : %02i", hr, min, sec)

	local rVal = math.clamp((intTime / GlobalInfo.Clock.BADGE_TIME) ^ 12, 0, 1)
	clock.TextColor3 = Color3.new(1, 1 - rVal, 1 - rVal)
end)

return {}
