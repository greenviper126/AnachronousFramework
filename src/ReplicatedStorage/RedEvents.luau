--!strict

--[[
    Red library should only be called here
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Guard = require(ReplicatedStorage.Packages._Index["red-blox_guard@1.0.1"].guard)
local Ratelimit = require(ReplicatedStorage.Packages.ratelimit)
local Red = require(ReplicatedStorage.Packages.red)
local Signal = require(ReplicatedStorage.Packages._Index["red-blox_signal@2.0.2"].signal)

--[[network connections]]
----------------------------------------------------------------------------------------------------

--fired from server
local fromNetworkServer = {

	RoleCredits = Red.SharedSignalEvent("RoleCredits", function()
		return nil
	end),

	--functions

	--unreliable
	ServerBodyCFrame = Red.SharedEvent({ --send character CFrame info to players
		Name = "ServerBodyCFrame",
		Unreliable = true,
	}, function(player, neck, waist)
		return Guard.Any(player), Guard.CFrame(neck), Guard.CFrame(waist)
	end),
}

--fired from client
local fromNetworkClient = {
	FlashlightState = Red.SharedSignalEvent("FlashlightState", function(on)
		return Guard.Boolean(on)
	end),

	Respawn = Red.SharedSignalEvent("Respawn", function()
		return nil
	end),
	DeathScreenFinished = Red.SharedSignalEvent("DeathScreenFinished", function()
		return nil
	end),

	--functions
	SoundsRequest = Red.Function(
		"SoundsRequest",
		function() end,
		function(Table) --send sound table to client on request
			return Guard.Map(Guard.String, Guard.Any)(Table)
		end
	),

	--unreliable
	BodyCFrame = Red.SharedEvent({ --send character CFrame info to server
		Name = "BodyCFrame",
		Unreliable = true,
	}, function(neck, waist)
		return Guard.CFrame(neck), Guard.CFrame(waist)
	end),
}

--[[signal connections]]
----------------------------------------------------------------------------------------------------

--server side
local fromSignalServer = {}

--client side
local fromSignalClient = {
	SystemResponse = Signal(),
	SystemSignal = Signal(),

	FootStep = Signal(), --isRightFoot Boolean
	WalkState = Signal(), --state ("Crouch" | "Walk" | "Sprint")
}

--[[system connections]]
----------------------------------------------------------------------------------------------------

local function FireClientSystem(class: string): (string, ...any) -> ...any
	local function sendInfo(name: string, ...: any): ...any
		local results = { "nil" }
		local connection = fromSignalClient.SystemResponse:Connect(function(newClass: string, newName: string, ...: any)
			if newClass ~= class or newName ~= name then
				return
			end

			results = { ... }
		end)

		fromSignalClient.SystemSignal:Fire(class, name, ...)

		local function cleanup()
			if connection then
				connection()
			end
		end

		--took to long to send back
		task.delay(10, function()
			if results[1] == "nil" then
				warn("System Signal not received, class: " .. class .. ", name: " .. name .. ", Input: ", results)
				cleanup()
			end
		end)

		repeat
			task.wait()
		until results[1] ~= "nil"

		cleanup()

		return table.unpack(results)
	end

	return sendInfo
end

local function ConnectClientSystem(class: string)
	local function connectInfo(name: string, signal: (...any) -> ...any): () -> ()
		local cleanup = fromSignalClient.SystemSignal:Connect(function(newClass: string, newName: string, ...: any)
			if newClass ~= class or newName ~= name then
				return
			end
			fromSignalClient.SystemResponse:Fire(class, name, signal(...))
		end)

		return cleanup
	end

	return connectInfo
end

----------------------------------------------------------------------------------------------------

--[[
	Anything that needs an event or signal should go through here for security.

	All Events will be created within this Module.

	Signals should be made using NewSignal if it will stay within the module using it.
	If that is not the case it should be created in RedEvents Module.
]]
local RedSignalNetwork = {
	-- client to server and server to client communications
	Network = {
		Server = fromNetworkServer,
		Client = fromNetworkClient,
	},
	-- client to client and server to server communications
	Signal = {
		Server = fromSignalServer,
		Client = fromSignalClient,
	},
	SystemConnect = {
		FireClient = FireClientSystem,
		ConnectClient = ConnectClientSystem,
	},
	Ratelimit = Ratelimit,
	NewSignal = Signal,
}

return RedSignalNetwork
