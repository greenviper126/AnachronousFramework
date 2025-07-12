--!strict

--[[
	need to add in new UI for this
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DeviceInfo = require(ReplicatedStorage.ClientCommon.DeviceInfo)
local Sounds = require(ReplicatedStorage.Common.Sounds)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- local tasks = Instance.new("ScreenGui")
-- tasks.Name = "Tasks"
-- tasks.DisplayOrder = 20
-- tasks.IgnoreGuiInset = true
-- tasks.ResetOnSpawn = false
-- tasks.ScreenInsets = Enum.ScreenInsets.None
-- tasks.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- local holder = Instance.new("CanvasGroup")
-- holder.Name = "Holder"
-- holder.AnchorPoint = Vector2.new(1, 0.5)
-- holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
-- holder.BackgroundTransparency = 1
-- holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
-- holder.BorderSizePixel = 0
-- holder.Position = UDim2.fromScale(1, 0.5)
-- holder.Size = UDim2.new(0.1, 20, 0.6, 50)

-- local uIListLayout = Instance.new("UIListLayout")
-- uIListLayout.Name = "UIListLayout"
-- uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
-- uIListLayout.Padding = UDim.new(0.01, 5)
-- uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
-- uIListLayout.Parent = holder

-- local uIPadding = Instance.new("UIPadding")
-- uIPadding.Name = "UIPadding"
-- uIPadding.PaddingBottom = UDim.new(0.01, 5)
-- uIPadding.PaddingLeft = UDim.new(0.05, 5)
-- uIPadding.PaddingRight = UDim.new(0.05, 5)
-- uIPadding.PaddingTop = UDim.new(0.01, 5)
-- uIPadding.Parent = holder

-- local header = Instance.new("TextLabel")
-- header.Name = "Header"
-- header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
-- header.BackgroundTransparency = 1
-- header.BorderColor3 = Color3.fromRGB(0, 0, 0)
-- header.BorderSizePixel = 0
-- header.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
-- header.LayoutOrder = 1
-- header.Size = UDim2.fromScale(1, 0.1)
-- header.Text = "Task"
-- header.TextColor3 = Color3.fromRGB(255, 255, 255)
-- header.TextScaled = true
-- header.TextSize = 40
-- header.TextWrapped = true

-- local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
-- uITextSizeConstraint.Name = "UITextSizeConstraint"
-- uITextSizeConstraint.MaxTextSize = 40
-- uITextSizeConstraint.MinTextSize = 10
-- uITextSizeConstraint.Parent = header

-- local uIStroke = Instance.new("UIStroke")
-- uIStroke.Name = "UIStroke"
-- uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- uIStroke.Color = Color3.fromRGB(255, 255, 255)
-- uIStroke.Thickness = 3
-- uIStroke.Transparency = 0.2
-- uIStroke.Parent = header

-- local uICorner = Instance.new("UICorner")
-- uICorner.Name = "UICorner"
-- uICorner.CornerRadius = UDim.new(0.2, 0)
-- uICorner.Parent = header

-- header.Parent = holder

-- local textHolder = Instance.new("Frame")
-- textHolder.Name = "TextHolder"
-- textHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
-- textHolder.BackgroundTransparency = 1
-- textHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
-- textHolder.BorderSizePixel = 0
-- textHolder.LayoutOrder = 2
-- textHolder.Size = UDim2.fromScale(1, 0.75)

-- local uIStroke1 = Instance.new("UIStroke")
-- uIStroke1.Name = "UIStroke"
-- uIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
-- uIStroke1.Color = Color3.fromRGB(255, 255, 255)
-- uIStroke1.Thickness = 3
-- uIStroke1.Transparency = 0.2
-- uIStroke1.Parent = textHolder

-- local uICorner1 = Instance.new("UICorner")
-- uICorner1.Name = "UICorner"
-- uICorner1.CornerRadius = UDim.new(0.1, 0)
-- uICorner1.Parent = textHolder

-- local uIPadding1 = Instance.new("UIPadding")
-- uIPadding1.Name = "UIPadding"
-- uIPadding1.PaddingBottom = UDim.new(0.01, 5)
-- uIPadding1.PaddingLeft = UDim.new(0.05, 5)
-- uIPadding1.PaddingRight = UDim.new(0.05, 5)
-- uIPadding1.PaddingTop = UDim.new(0.01, 5)
-- uIPadding1.Parent = textHolder

-- local text = Instance.new("TextLabel")
-- text.Name = "Text"
-- text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
-- text.BackgroundTransparency = 1
-- text.BorderColor3 = Color3.fromRGB(0, 0, 0)
-- text.BorderSizePixel = 0
-- text.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
-- text.Size = UDim2.fromScale(1, 1)
-- text.Text = ""
-- text.TextColor3 = Color3.fromRGB(255, 255, 255)
-- text.TextSize = 20
-- text.TextWrapped = true
-- text.TextScaled = true
-- text.TextXAlignment = Enum.TextXAlignment.Left
-- text.TextYAlignment = Enum.TextYAlignment.Top
-- text.Parent = textHolder

-- local uITextSizeConstraint1 = Instance.new("UITextSizeConstraint")
-- uITextSizeConstraint1.Name = "UITextSizeConstraint"
-- uITextSizeConstraint1.MaxTextSize = 30
-- uITextSizeConstraint1.MinTextSize = 5
-- uITextSizeConstraint1.Parent = text

-- textHolder.Parent = holder

-- local controlInfo = Instance.new("TextLabel")
-- controlInfo.Name = "ControlInfo"
-- controlInfo.AnchorPoint = Vector2.new(1, 0)
-- controlInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
-- controlInfo.BackgroundTransparency = 1
-- controlInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
-- controlInfo.BorderSizePixel = 0
-- controlInfo.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
-- controlInfo.LayoutOrder = 3
-- controlInfo.Position = UDim2.fromScale(1, 0.78)
-- controlInfo.Size = UDim2.new(1, 0, 0.05, 7)
-- controlInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
-- controlInfo.TextScaled = true
-- controlInfo.TextSize = 16
-- controlInfo.TextWrapped = true
-- controlInfo.Parent = holder

-- holder.Parent = tasks

-- tasks.Parent = player.PlayerGui

local function updateTask()
	-- text.Text = Players:GetAttribute("_Task") or ""

	-- if text.Text ~= "" then
	-- 	Sounds.PlaySoundByName("NewTask")
	-- end
end

updateTask()
Players.AttributeChanged:Connect(updateTask)

RunService.Heartbeat:Connect(function()
	-- local inputType = DeviceInfo.GetInputType()

	-- if inputType == "Keyboard" then
	-- 	controlInfo.Text = '"K" for Controls.'
	-- elseif inputType == "Controller" then
	-- 	controlInfo.Text = '"Dpad Up" for Controls.'
	-- elseif inputType == "Touch" then
	-- 	controlInfo.Text = "Top-Right for Controls."
	-- end
end)

return {}
