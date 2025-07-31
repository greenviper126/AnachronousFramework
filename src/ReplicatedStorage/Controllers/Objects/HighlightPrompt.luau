--!strict

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

	self._cleaner:Add(HighlightUtility.CreateHighlightPrompt(base))

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

task.delay(1, function()
	local _cleanup, _objects = Utility.Tags.SetObjectListner(HighlightPrompt.new(), HighlightPrompt)
end)

-------------------------------------------------------------------------------------------

return {}
