--!strict

--[[
Item connection for handling player clicking on things you can pickup
this just links a inventory module to this caller function
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local Inventory = require(ReplicatedStorage.Common.Inventory)

local effects = ReplicatedStorage.Effects

return {
	First = function(_cleaner: typeof(Trove.new()), _linkModel: Model)
		local sparkle = _cleaner:Add(require(effects.Sparkle).New())
		sparkle.Parent = _linkModel.PrimaryPart
	end,

	Activated = function(_cleaner: typeof(Trove.new()), _linkModel: Model, _player: Player, _attempts: number) --error if activation not excepted
		local result = Inventory.AddedItemByLink(_linkModel)
		if not result then
			error("Item Link was not succesfull, Error: " .. _linkModel:GetFullName())
		end
	end,
}
