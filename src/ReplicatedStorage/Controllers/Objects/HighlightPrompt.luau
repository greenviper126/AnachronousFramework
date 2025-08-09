--!strict

--[[
	This may just be more used for testing Highlights as I don't see many uses for this in the real game.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local Utility = require(ReplicatedStorage.Utility)

local HighlightUtility = require(ReplicatedStorage.ClientCommon.HighlightUtility)

local HighlightPrompt = {}
HighlightPrompt.__index = HighlightPrompt
HighlightPrompt.TAG_NAME = "HighlightPrompt"

type self = {
	base: Instance,
	root: BasePart,

	prompt: ProximityPrompt,

	_cleaner: typeof(Trove.new()),
}

export type HighlightPrompt = typeof(setmetatable({} :: self, HighlightPrompt))

--[[
	Constructor

	@return self - the new object
]]
function HighlightPrompt.new(base: (BasePart | Attachment)?)
	if not base then
		return
	end

	local self = setmetatable({} :: self, HighlightPrompt)
	self._cleaner = Trove.new()

	self.base = base

	self.prompt = self._cleaner:Add(HighlightUtility.CreateHighlightPrompt(base))

	local function setProperties()
		for k, v in pairs(Utility.Properties.AttributesToProperties(self.base)) do
			pcall(function()
				local prompt = self.prompt :: any --fix type error
				prompt[k:gsub("Prompt", "")] = v
			end)
		end
	end

	setProperties()
	self._cleaner:Connect(self.base.AttributeChanged, function()
		setProperties()
	end)

	return self
end

--[[
	Cleans up the HighlightPrompt object.

	@param self HighlightPrompt - object
]]
function HighlightPrompt.Cleanup(self: HighlightPrompt)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _cleanup, _objects = Utility.Tags.SetObjectListner(HighlightPrompt.new(), HighlightPrompt)

-------------------------------------------------------------------------------------------

return {}
