--!strict

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local DeviceInfo = {}

function DeviceInfo.GetPlatform(): "Console" | "Phone" | "Desktop"
	if GuiService:IsTenFootInterface() then
		return "Console"
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return "Phone"
	else
		return "Desktop"
	end
end

function DeviceInfo.GetInputType(): "Controller" | "Keyboard" | "Touch"
	if UserInputService.GamepadEnabled then
		return "Controller"
	end
	if DeviceInfo.GetPlatform() == "Phone" then
		return "Touch"
	end
	return "Keyboard"
end

return DeviceInfo
