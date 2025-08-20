--!strict

--[[
	Highlights objects using proximity prompts
]]

local OBJECT_HIGHLIGHT_LIMIT = 15

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local Utility = require(ReplicatedStorage.Utility)

local Highlighter = {}
Highlighter.__index = Highlighter

type self = {
	base: Instance,

	highlights: { Highlight },

	_cleaner: typeof(Trove.new()),
}

export type Highlighter = typeof(setmetatable({} :: self, Highlighter))

function Highlighter.new(base: Instance?)
	local self = setmetatable({} :: self, Highlighter)
	self._cleaner = Trove.new()

	if not base then --helps with types
		return self
	end

	self.base = base

	self.highlights = {}

	self:_init()

	return self
end

function Highlighter._init(self: Highlighter)
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
	elseif self.base:IsA("BasePart") then
		AddHighlight(self.base)
	end
end

function Highlighter.SetProperty(self: Highlighter, property: string, value: any)
	for _, highlight in pairs(self.highlights) do
		Utility.Properties.ApplyPropertyValueToInstance(highlight, property, value)
	end
end

function Highlighter.GetProperty(self: Highlighter, property: string): any?
	local result = nil
	for _, highlight in pairs(self.highlights) do
		result = Utility.Properties.InstanceToProperties(highlight)[property]
		break
	end

	return result
end

function Highlighter.Cleanup(self: Highlighter)
	self._cleaner:Destroy()
	self._cleaner = nil :: any
end

return Highlighter
