--!strict

--[[
this links the local player interating with an object to a unique function
to add settings give the linkModel attributes to read

NOTE, should consider adding a animation module for using Items/Keys on objects. Like in FHT
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local RedEvents = require(ReplicatedStorage.RedEvents)
local Tags = require(ReplicatedStorage.Common.Tags)

local linkers = ServerStorage.Linkers

export type linkerClass = {
	First: (cleaner: typeof(Trove.new()), linkModel: Model) -> (),
	Activated: (cleaner: typeof(Trove.new()), linkModel: Model, player: Player, attempts: number) -> (),
}

local Linker = {}
Linker.__index = Linker
Linker.TAG_NAME = "Link"

type self = {
	object: Model,
	linkerClass: linkerClass,
	interactAttempts: number,

	_cleaner: typeof(Trove.new()),
}

export type Linker = typeof(setmetatable({} :: self, Linker))

function Linker.new(object: Model): Linker
	local linkType = object:GetAttribute("LinkType") :: string
	assert(linkType, "Object does not have LinkType, " .. object:GetFullName())

	local linkerModule = linkers:WaitForChild(linkType)
	assert(linkerModule, "LinkType does not exist, " .. object:GetFullName())

	local self = setmetatable({} :: self, Linker)
	self._cleaner = Trove.new()

	self.object = object
	self.interactAttempts = 0

	self.linkerClass = require(linkerModule) :: linkerClass

	--setup
	self.linkerClass.First(self._cleaner, self.object)

	return self
end

function Linker.HasAttempts(self: Linker): boolean
	local maxActivation = self.object:GetAttribute("MaxActivation") :: number? or nil

	if maxActivation and self.interactAttempts >= maxActivation then
		return false
	else
		return true
	end
end

function Linker.Activate(self: Linker, player: Player): boolean
	self.object:RemoveTag("Clickable") --cant click

	if not self:HasAttempts() then
		return true
	end

	self.object:RemoveTag("Clickable") --cant click

	local success, errorMessage = pcall(function()
		self.linkerClass.Activated(self._cleaner, self.object, player, self.interactAttempts)
	end)

	if success then
		self.interactAttempts += 1

		if self:HasAttempts() then
			self.object:AddTag("Clickable")
		end
	else
		warn(errorMessage)
		self.object:AddTag("Clickable")
	end

	return success
end

function Linker.Cleanup(self: Linker)
	self._cleaner:Destroy()
	self = nil :: any
end

local _, instances = Tags.SetObjectListner(Linker)

RedEvents.Network.Client.LinkAttempt:SetCallback(function(player, linkModel)
	local instance = instances[linkModel] :: any
	if not instance then
		return false
	end

	return instance:Activate(player)
end)

return {}
