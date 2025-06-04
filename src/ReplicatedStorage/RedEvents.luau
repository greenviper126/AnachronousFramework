--!strict

--[[
    Red library should only be called here
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Red = require(ReplicatedStorage.Packages.red)
local Signal = require(ReplicatedStorage.Packages._Index["red-blox_signal@2.0.2"].signal)
local Guard = require(ReplicatedStorage.Packages._Index["red-blox_guard@1.0.1"].guard)
local Ratelimit = require(ReplicatedStorage.Packages.ratelimit)

--[[network connections]]
----------------------------------------------------------------------------------------------------

--fired from server
local fromNetworkServer = {
	RoleCredits = Red.SharedSignalEvent("RoleCredits", function()
		return nil
	end),

	--functions
}

--fired from client
local fromNetworkClient = {
	Respawn = Red.SharedSignalEvent("Respawn", function()
		return nil
	end),
	DeathScreenFinished = Red.SharedSignalEvent("DeathScreenFinished", function()
		return nil
	end),

	--functions
	SoundsRequest = Red.Function("SoundsRequest", function() end, function(Table)
		return Guard.Map(Guard.String, Guard.Any)(Table)
	end),
	LinkAttempt = Red.Function("LinkAttempt", function(linkModel)
		return Guard.Instance(linkModel)
	end, function(success)
		return Guard.Boolean(success)
	end),
}

--[[signal connections]]
----------------------------------------------------------------------------------------------------

--server side
local fromSignalServer = {
	LoadMap = Signal(),
	NewItem = Signal(),
}

--client side
local fromSignalClient = {
	DisablePlayerControls = Signal(),
	Link = Signal(),
}

return {
	Network = {
		Server = fromNetworkServer,
		Client = fromNetworkClient,
	},
	Signal = {
		Server = fromSignalServer,
		Client = fromSignalClient,
	},
	Ratelimit = Ratelimit,
	NewSignal = Signal,
}
