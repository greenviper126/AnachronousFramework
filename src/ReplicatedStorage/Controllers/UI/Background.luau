--!strict

local Players = game:GetService("Players")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local mainScreen = Instance.new("ScreenGui")
mainScreen.Name = "Background"
mainScreen.DisplayOrder = 1
mainScreen.IgnoreGuiInset = true
mainScreen.ResetOnSpawn = false
mainScreen.ScreenInsets = Enum.ScreenInsets.None
mainScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local background = Instance.new("CanvasGroup")
background.Name = "Background"
background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
background.BackgroundTransparency = 1
background.BorderColor3 = Color3.fromRGB(0, 0, 0)
background.BorderSizePixel = 0
background.GroupColor3 = Color3.fromRGB(0, 0, 0)
background.Size = UDim2.fromScale(1, 1)
background.ZIndex = 0

local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.AnchorPoint = Vector2.new(1, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Position = UDim2.fromScale(1, 0)
frame.Size = UDim2.new(0.085, 36, 1, 0)
frame.Parent = background

local frame1 = Instance.new("Frame")
frame1.Name = "Frame"
frame1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame1.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame1.BorderSizePixel = 0
frame1.Size = UDim2.new(1, 0, 0.01, 36)
frame1.Parent = background

local frame2 = Instance.new("Frame")
frame2.Name = "Frame"
frame2.AnchorPoint = Vector2.new(0, 1)
frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame2.BorderSizePixel = 0
frame2.Position = UDim2.fromScale(0, 1)
frame2.Size = UDim2.new(1, 0, 0.01, 36)
frame2.Parent = background

local frame3 = Instance.new("Frame")
frame3.Name = "Frame"
frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
frame3.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame3.BorderSizePixel = 0
frame3.Size = UDim2.new(0.085, 36, 1, 0)
frame3.Parent = background

background.Parent = mainScreen

mainScreen.Parent = player.PlayerGui

return {}
