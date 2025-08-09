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
	base: Instance,

	highlights: { Highlight },

	_cleaner: typeof(Trove.new()),
}

export type HighlightHover = typeof(setmetatable({} :: self, HighlightHover))

function HighlightHover.new(base: Instance?)
	local self = setmetatable({} :: self, HighlightHover)
	self._cleaner = Trove.new()

	if not base then --helps with types
		return self
	end

	self.base = base

	self.highlights = {}

	self:_init()

	return self
end

function HighlightHover._init(self: HighlightHover)
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

	local function getHighlights(Instances: { Instance })
		local index = 0
		for _, inst in pairs(Instances) do
			if not inst:IsA("BasePart") then
				continue
			end

			index += 1

			if index > OBJECT_HIGHLIGHT_LIMIT then
				break
			end

			AddHighlight(inst)
		end
	end

	local basePart = self.base:IsA("BasePart") and self.base or self.base:FindFirstAncestorWhichIsA("BasePart")

	if basePart then
		local hasBasePartChildren = basePart:FindFirstChildWhichIsA("BasePart", true)
		if hasBasePartChildren then
			getHighlights(basePart:GetChildren())
		else
			AddHighlight(basePart)
		end
	end
	if self.base:IsA("BasePart") then
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

	self._cleaner:Add(function() --remove all highlight attributes when cleaning up
		for k, _ in pairs(Utility.Properties.InstanceToProperties(self.base)) do
			self.base:SetAttribute("HighlightPrompt" .. k, nil)
		end
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
		local self = HighlightHover.new(prompt)
		cleaner:Add(function()
			self:Cleanup()
		end)

		cleaner:Connect(prompt.PromptShown, function()
			prompt:SetAttribute("HighlightPromptEnabled", true)
		end)

		cleaner:Connect(prompt.PromptHidden, function()
			prompt:SetAttribute("HighlightPromptEnabled", false)
		end)

		cleaner:Add(function()
			prompt:SetAttribute("HighlightPromptEnabled", nil)
		end)
	else
		warn("Could not find base to attach HighlightPrompt, Parent: " .. parent:GetFullName())
	end

	return prompt
end)

return {}
