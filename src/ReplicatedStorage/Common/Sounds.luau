--!strict

export type SoundTable = { Sound: { [string]: any }, Children: { [string]: { [string]: any } } }

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")

local RedEvents = require(ReplicatedStorage.RedEvents)
local Properties = require(ReplicatedStorage.Common.Properties)

local UnParentedSounds: Folder = nil

local _soundGroups: { [string]: SoundGroup } = {}
local _sounds: { [string]: SoundTable } = nil

if RunService:IsServer() then
	local ServerStorage = game:GetService("ServerStorage")
	local soundFolder = ServerStorage.Sounds

	UnParentedSounds = Instance.new("Folder")
	UnParentedSounds.Name = "UnParentedSounds"
	UnParentedSounds.Parent = SoundService

	local soundTable = {}

	local function getSoundChildren(sound: Sound): { [string]: { [string]: any } }
		local children = {}

		for _, child in pairs(sound:GetChildren()) do
			children[child.ClassName] = Properties.InstanceToProperties(child)
		end

		return children
	end

	local soundGroupConfig = Instance.new("Configuration")
	soundGroupConfig.Name = "SoundGroups"

	for _, childFolder in pairs(soundFolder:GetChildren()) do
		local soundGroup = Instance.new("SoundGroup")
		soundGroup.Name = childFolder.Name
		soundGroup.Parent = soundGroupConfig

		_soundGroups[childFolder.Name] = soundGroup

		for _, sound in pairs(childFolder:GetDescendants()) do
			if not sound:IsA("Sound") then
				continue
			end

			local success, errorMessage = pcall(function()
				soundTable[sound.Name] = { --create sound and its children
					Sound = Properties.InstanceToProperties(sound),
					Children = getSoundChildren(sound),
				}

				soundTable[sound.Name].Sound.Name = sound.Name --add to sound group
				soundTable[sound.Name].Sound.SoundGroup = childFolder.Name --add to sound group
			end)

			if not success then
				warn(errorMessage)
			end
		end
	end

	soundGroupConfig.Parent = SoundService
	_sounds = soundTable

	local soundRequestLimit = RedEvents.Ratelimit(5, 2)
	RedEvents.Network.Client.SoundsRequest:SetCallback(function(_player)
		if not soundRequestLimit(_player) then
			warn("Sound Data was request to many times by, ", _player)
			return {}
		end

		return soundTable
	end)
elseif RunService:IsClient() then
	local function getSoundForClient()
		local success, sounds = RedEvents.Network.Client.SoundsRequest:Call():Await()
		if success then
			_sounds = sounds
		else
			warn("Server did not return sounds to local player, reattempting!")

			task.wait(0.5)

			getSoundForClient()
		end
	end

	getSoundForClient()

	UnParentedSounds = SoundService:WaitForChild("UnParentedSounds")

	local soundGroupInstances = SoundService:WaitForChild("SoundGroups")
	for _, soundGroup in pairs(soundGroupInstances:GetChildren()) do
		_soundGroups[soundGroup.Name] = soundGroup
	end
end

local Sounds = {}

function Sounds.FindSoundGroup(name: string): SoundGroup?
	return _soundGroups[name]
end

function Sounds.GetSoundGroups(): { [string]: SoundGroup }
	return _soundGroups
end

function Sounds.CreateSound(soundData: SoundTable): Sound
	local newSound = Instance.new("Sound")

	if not _sounds then
		newSound.Name = "SoundsNotLoadedYet"
		return newSound
	end

	for property, value in pairs(soundData.Sound) do --create new sound
		Properties.ApplyPropertyValueToInstance(newSound, property, value)
	end

	local realSoundGroup = Sounds.FindSoundGroup(soundData.Sound.SoundGroup)
	newSound.SoundGroup = realSoundGroup and realSoundGroup or nil

	for class, properties in pairs(soundData.Children) do --create new sound
		pcall(function()
			local newClass = Instance.new(class)

			for property, value in pairs(properties) do --create new child class
				Properties.ApplyPropertyValueToInstance(newClass, property, value)
			end

			newClass.Parent = newSound
		end)
	end

	return newSound
end

function Sounds.FindSoundByName(name: string, parent: Instance?): Sound?
	local soundData = _sounds[name]
	if not soundData then
		return
	end

	local newSound = Sounds.CreateSound(soundData)
	if newSound then
		newSound.Parent = parent and parent or UnParentedSounds
	end

	return newSound
end

function Sounds.PlaySoundByName(name: string, parent: Instance?)
	local sound = Sounds.FindSoundByName(name, parent)
	if not sound then
		return
	end

	sound:Play()
end

return Sounds
