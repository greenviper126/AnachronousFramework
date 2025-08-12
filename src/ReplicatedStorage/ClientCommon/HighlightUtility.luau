--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("Highlight")

--[[
    This is were you create highlight prompts

    since click detectors are outdated prompts are used instead

    Also note that prompts will only run locally

    Name a part or bool attribute "NoHighlight" to skip highlighting it
]]
local highlightUtility = {}

function highlightUtility.CreateHighlightPrompt(parent: BasePart | Attachment): ProximityPrompt
	return sendSignal("CreateHighlightPrompt", parent)
end

return highlightUtility
