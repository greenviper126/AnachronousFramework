--!strict

--[[
main intended way to interact with any class of object
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)
local RedEvents = require(ReplicatedStorage.RedEvents)

local Tags = require(ReplicatedStorage.Common.Tags)
local HoverClick = require(ReplicatedStorage.ClientCommon.HoverClick)
local Inventory = require(ReplicatedStorage.Common.Inventory)

local Link = {}
Link.__index = Link
Link.TAG_NAME = "Link"

type self = {
	clickLink: Model,

	_cleaner: typeof(Trove.new()),
}

export type Link = typeof(setmetatable({} :: self, Link))

function Link.new(clickLink: Model): Link
	local self = setmetatable({} :: self, Link)
	self._cleaner = Trove.new()

	self.clickLink = clickLink

	--part was clicked using hover
	self._cleaner:Add(HoverClick.OnObjectClick(nil, function(clickedPart: Instance)
		if not HoverClick.InstanceContainsUniqueInstance(clickLink, clickedPart) then
			return
		end
		print("Clicked")
		if not self.clickLink:HasTag("Clickable") then
			return
		end

		local key = self.clickLink:GetAttribute("Key")
		if key ~= nil and typeof(key) ~= "string" then
			return
		end

		if typeof(key) == "string" and not Inventory.HasItem(key) then
			self:_NewLine(1)
			return
		end

		self:_Activate()
	end))

	--activated manually
	if self.clickLink:GetAttribute("Key") == true then
		self:_Activate()
	end

	self._cleaner:Connect(self.clickLink:GetAttributeChangedSignal("Key"), function()
		local key = self.clickLink:GetAttribute("Key")
		if not key or key ~= true then
			return
		end

		self:_Activate()
	end)

	return self
end

--this isnt actually finished, It should read from a table outside of this prob and have the option to change it from attribute
function Link._NewLine(self: Link, index: number)
	if index == 1 then
		print("looks like im missing an item for this.")
	elseif index == 2 then
		print("looks like this worked.")
	end
end

function Link._Activate(self: Link)
	local success, worked = RedEvents.Network.Client.LinkAttempt:Call(self.clickLink):Await()
	if success and worked then
		self:_NewLine(2)
	end
end

function Link.Cleanup(self: Link)
	self._cleaner:Destroy()
	self = nil :: any
end

Tags.SetObjectListner(Link)

return {}
