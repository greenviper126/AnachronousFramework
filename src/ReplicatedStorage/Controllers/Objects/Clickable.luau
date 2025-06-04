--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)
local Tags = require(ReplicatedStorage.Common.Tags)

local HoverClick = require(ReplicatedStorage.ClientCommon.HoverClick)

local Clickable = {}
Clickable.__index = Clickable
Clickable.TAG_NAME = "Clickable"

type self = {
	holder: Model | BasePart,

	hoverParts: { BasePart },
	hovers: { IntValue },
	hoverId: number,

	_cleaner: typeof(Trove.new()),
}

export type Clickable = typeof(setmetatable({} :: self, Clickable))

function Clickable.new(holder: Model | BasePart): Clickable
	local clickHolder = holder:FindFirstChild("Clickable") :: Folder or holder
	assert(clickHolder, "Could not Find Click Part to attach too, " .. holder:GetFullName())

	local self = setmetatable({} :: self, Clickable)
	self._cleaner = Trove.new()

	self.holder = holder
	self.hoverParts = {}
	self.hovers = {}

	if clickHolder:IsA("Folder") then
		for _, hoverPart in pairs(clickHolder:GetChildren()) do
			if not hoverPart:IsA("BasePart") then
				continue
			end
			table.insert(self.hoverParts, hoverPart)
		end
	elseif clickHolder:IsA("BasePart") then
		table.insert(self.hoverParts, clickHolder)
	elseif clickHolder:IsA("Model") and clickHolder.PrimaryPart then
		table.insert(self.hoverParts, clickHolder.PrimaryPart)
	else
		warn("Could not Find Click Part to attach too, " .. holder:GetFullName())
	end

	self:_addHovers()

	--can add functionality to update icon here

	return self
end

function Clickable._addHovers(self: Clickable)
	for _, hoverPart in pairs(self.hoverParts) do
		if not hoverPart:IsA("BasePart") then
			continue
		end

		local hover = self._cleaner:Add(HoverClick.New(hoverPart))
		table.insert(self.hovers, hover)
	end
end

function Clickable.Cleanup(self: Clickable)
	self._cleaner:Destroy()
	self = nil :: any
end

--COLLECTION---------------------------------------------------------------------------

Tags.SetObjectListner(Clickable)

return {}
