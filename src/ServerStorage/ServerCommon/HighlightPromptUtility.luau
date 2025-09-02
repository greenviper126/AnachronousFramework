--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("HighlightPromptServer")

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
	return sendSignal("ListenToClass", class, instance, onActivation)
end

return HighlightPrompt
