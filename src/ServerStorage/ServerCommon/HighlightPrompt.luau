--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local classActivated = RedEvents.NewSignal()

local limit = RedEvents.Ratelimit(15, 1)
RedEvents.Network.Client.PromptClassActivation:OnServer(function(player: Player, class: string, instance: Instance)
	if not limit(player) then
		warn(player.Name .. " requested promptClassActivation too many times!")
		return
	end

	classActivated:Fire(player, class, instance)
end)

local HighlightPrompt = {}

--[[
	This is for listening to players activating prompts on the server
	more meant for objects like vents, doors, etc

	@param class string - name of the class to track
	@param instance Instance - specific instance with class
	@param onActivation () -> () - function to run when player clicks a ClassPrompt

	@return (Player) -> () - cleanup
]]
function HighlightPrompt.ListenToClass(class: string, instance: Instance, onActivation: (Player) -> ()): () -> ()
	return classActivated:Connect(function(player, newClass, newInstance)
		if newClass ~= class or newInstance ~= instance then
			return
		end

		onActivation(player)
	end)
end

return HighlightPrompt
