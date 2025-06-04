--!strict

local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Properties = require(ReplicatedStorage.Common.Properties)

local soundConfigs = ReplicatedStorage.Configs.GlobalSound

local AudioManager = {}

function AudioManager.SetAudio(name: string)
	local config = soundConfigs:WaitForChild(name, 2)
	if not config then
		return
	end

	for property, value in pairs(Properties.AttributesToProperties(config)) do
		SoundService[property] = value
	end
end

return AudioManager
