--!strict

--[[
	Highlights objects using proximity prompts
]]

local OBJECT_HIGHLIGHT_LIMIT = 15

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local RedEvents = require(ReplicatedStorage.RedEvents)
local Utility = require(ReplicatedStorage.Utility)

local HighlightHover = {}
HighlightHover.__index = HighlightHover
HighlightHover.TAG_NAME = "Highlight"

type self = {
	base: BasePart,
	highlights: { Highlight },

	_cleaner: typeof(Trove.new()),
}

export type HighlightHover = typeof(setmetatable({} :: self, HighlightHover))

function HighlightHover.new(base: BasePart?)
	if not base then
		return
	end

	local self = setmetatable({} :: self, HighlightHover)
	self._cleaner = Trove.new()

	self.base = base

	self.highlights = {}

	self:_init()

	return self
end

function HighlightHover._init(self: HighlightHover)
	local index = 0

	local function AddHighlight(inst: BasePart)
		if not inst:IsA("BasePart") then
			return
		end
		if inst.Name == "NoHighlight" then
			return
		end --will not highlight anything with this name
		if inst:GetAttribute("NoHighlight") then
			return
		end --will not highlight anything with this attribute

		local highlight = self._cleaner:Add(Instance.new("Highlight"))
		highlight.Adornee = inst
		highlight.DepthMode = Enum.HighlightDepthMode.Occluded
		highlight.OutlineColor = Color3.new(1, 1, 1)
		highlight.FillColor = Color3.new(1, 1, 1)
		highlight.OutlineTransparency = 0.4
		highlight.FillTransparency = 0.8
		highlight.Enabled = false
		highlight.Parent = inst

		table.insert(self.highlights, highlight)
	end

	if self.base:FindFirstAncestorWhichIsA("BasePart") then
		for _, inst in pairs(self.base:GetChildren()) do
			if not inst:IsA("BasePart") then
				continue
			end

			index += 1

			if index > OBJECT_HIGHLIGHT_LIMIT then
				break
			end

			AddHighlight(inst)
		end
	else
		AddHighlight(self.base)
	end

	local function setProperties()
		for k, v in pairs(Utility.Properties.AttributesToProperties(self.base)) do
			pcall(function()
				for _, highlight: any in pairs(self.highlights) do
					highlight[k:gsub("HighlightPrompt", "")] = v
				end
			end)
		end
	end

	setProperties()
	self._cleaner:Connect(self.base.AttributeChanged, function()
		setProperties()
	end)
end

function HighlightHover.Cleanup(self: HighlightHover)
	self._cleaner:Destroy()
	self._cleaner = nil :: any
end

-------------------------------------------------------------------------------------------

local _cleanup, _objects = Utility.Tags.SetObjectListner(HighlightHover.new(), HighlightHover)

-------------------------------------------------------------------------------------------

local receiveSignal = RedEvents.SystemConnect.ConnectClient("Highlight")

receiveSignal("CreateHighlightPrompt", function(parent: BasePart | Attachment): ProximityPrompt
	local cleaner = Trove.new()

	local prompt = Instance.new("ProximityPrompt")
	prompt.Style = Enum.ProximityPromptStyle.Custom
	prompt.RequiresLineOfSight = true
	prompt.Parent = parent

	cleaner:AttachToInstance(prompt)

	local base = parent:IsA("BasePart") and parent or parent:FindFirstAncestorWhichIsA("BasePart")

	if base then
		base:AddTag("Highlight")

		cleaner:Connect(prompt.PromptShown, function()
			base:SetAttribute("HighlightPromptEnabled", true)
		end)

		cleaner:Connect(prompt.PromptHidden, function()
			base:SetAttribute("HighlightPromptEnabled", false)
		end)

		cleaner:Add(function()
			base:RemoveTag("Highlight")
			base:SetAttribute("HighlightPromptEnabled", nil)
		end)
	else
		warn("Could not find base to attach HighlightPrompt, Parent: " .. parent:GetFullName())
	end

	return prompt
end)

return {}
