--!strict

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GlobalInfo = require(ReplicatedStorage.Common.GlobalInfo)
local Modal = require(ReplicatedStorage.ClientCommon.Modal)

local modal = Modal.new("UnlockMouse")

local debounce = false
UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessedEvent: boolean)
	if gameProcessedEvent then
		return
	end
	if not GlobalInfo.UniversalInput.U(input) then
		return
	end
	debounce = not debounce

	modal:Enable(debounce)
end)

return {}
