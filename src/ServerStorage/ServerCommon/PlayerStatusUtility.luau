--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.CreateSender("PlayerStatusServer")

local PlayerStatus = {}

--[[
    Set the current health of the specified player.

    @param player Player - player to set health
    @param amount number - amount of health to set
]]
function PlayerStatus.SetHealth(player: Player, amount: number)
	sendSignal("SetHealth", player, amount)
end

--[[
    Get the current health of the specified player.

    @param player Player - player to get health

    @return number - amount of current health
]]
function PlayerStatus.GetHealth(player: Player): number
	return sendSignal("GetHealth", player)
end

--[[
    Get the max health all players can have.

]]
function PlayerStatus.GetMaxHealth()
	return sendSignal("GetMaxHealth")
end

--[[
    Add from current health of specified player.
    negative numbers damage player.

    @param player Player - player to get health

    @return number - amount of health to add
]]
function PlayerStatus.AddHealth(player: Player, amount: number)
	sendSignal("AddHealth", player, amount)
end

--[[
    Checks if player is currently dead.

    @param player Player - player to check death

    @return boolean - current death status
]]
function PlayerStatus.GetDeadStatus(player: Player): boolean
	return sendSignal("GetDeadStatus", player)
end

--[[
    Instantly Kills the specified player.

    @param player Player - player to kill
]]
function PlayerStatus.KillPlayer(player: Player)
	sendSignal("KillPlayer", player)
end

--[[
    Gets the current walk state of the specified player.
    This does not check if they are moving or not.

    @param player Player - player to kill

    @return "Crouch" | "Walk" | "Sprint" - current player state
]]
function PlayerStatus.CurrentMovementState(player: Player): "Crouch" | "Walk" | "Sprint"
	return sendSignal("CurrentMovementState", player)
end

return PlayerStatus
