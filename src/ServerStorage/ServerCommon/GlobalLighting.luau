--!strict

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Properties = require(ReplicatedStorage.Common.Properties)

local lightingConfigs = ReplicatedStorage.Configs.GlobalLighting

Lighting:ClearAllChildren() --clear everything

local GlobalLighting = {}

function GlobalLighting.SetLighting(name: string)
	local config = lightingConfigs:WaitForChild(name, 2)
	if not config then
		return
	end

	Lighting:ClearAllChildren()

	for property, value in pairs(Properties.AttributesToProperties(config)) do
		if property == "ExposureCompensation" then
			Lighting[property] = 0 --fixes dithering bug
		else
			Lighting[property] = value
		end
	end

	for _, inst in pairs(config:GetChildren()) do
		if inst:IsA("ColorCorrectionEffect") then -- for local dithering effect
			local colorCorrectionConfig = Instance.new("Configuration")
			colorCorrectionConfig.Name = inst.Name

			colorCorrectionConfig:AddTag("DitheringColorCorrection")
			for property, value in pairs(Properties.InstanceToProperties(inst)) do
				colorCorrectionConfig:SetAttribute(property, value)
			end

			colorCorrectionConfig.Parent = Lighting
		else
			inst:Clone().Parent = Lighting
		end
	end
end

return GlobalLighting
