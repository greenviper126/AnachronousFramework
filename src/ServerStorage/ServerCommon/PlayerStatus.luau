--!strict

local PLAYER_MAX_HEALTH = 100

local Players = game:GetService("Players")

function SetHealth(player: Player, amount: number)
	player:SetAttribute("_Health", math.clamp(amount, 0, PLAYER_MAX_HEALTH))
end

function GetHealth(player: Player): number
	return player:GetAttribute("_Health") :: number or PLAYER_MAX_HEALTH
end

function AddHealth(player: Player, amount: number)
	SetHealth(player, GetHealth(player) + amount)
end

function GetDeadStatus(player: Player): boolean
	return player:GetAttribute("_Dead") :: boolean or false
end

function KillPlayer(player: Player)
	SetHealth(player, 0)
end

function SetDeath(player: Player)
	player:SetAttribute("_Dead", GetHealth(player) == 0)
end

local regenConnections: { [number]: thread } = {}
local function PassiveRegen(player: Player)
	if regenConnections[player.UserId] then
		task.cancel(regenConnections[player.UserId])
	end

	regenConnections[player.UserId] = task.spawn(function()
		while task.wait(1) do
			if GetDeadStatus(player) then
				task.cancel(regenConnections[player.UserId])
				break
			end

			AddHealth(player, 1)
		end
	end)
end

local function CharacterAdded(player: Player)
	player.CharacterAdded:Connect(function()
		SetHealth(player, PLAYER_MAX_HEALTH)
		PassiveRegen(player)
	end)

	player:GetAttributeChangedSignal("_Health"):Connect(function()
		SetDeath(player)
	end)

	SetHealth(player, PLAYER_MAX_HEALTH)
end

for _, player in ipairs(Players:GetPlayers()) do
	CharacterAdded(player)
end
Players.PlayerAdded:Connect(function(player: Player)
	CharacterAdded(player)
end)

---------------------------------------------------------------------------------------

local PlayerStatus = {}

--[[
    Set the current health of the specified player.

    @param player Player - player to set health
    @param amount number - amount of health to set
]]
function PlayerStatus.SetHealth(player: Player, amount: number)
	SetHealth(player, amount)
end

--[[
    Get the current health of the specified player.

    @param player Player - player to get health

    @return number - amount of current health
]]
function PlayerStatus.GetHealth(player: Player): number
	return GetHealth(player)
end

--[[
    Get the max health all players can have.

]]
function PlayerStatus.GetMaxHealth()
	return PLAYER_MAX_HEALTH
end

--[[
    Add from current health of specified player.
    negative numbers damage player.

    @param player Player - player to get health

    @return number - amount of health to add
]]
function PlayerStatus.AddHealth(player: Player, amount: number)
	AddHealth(player, amount)
end

--[[
    Checks if player is currently dead.

    @param player Player - player to check death

    @return boolean - current death status
]]
function PlayerStatus.GetDeadStatus(player: Player): boolean
	return GetDeadStatus(player)
end

--[[
    Instantly Kills the specified player.

    @param player Player - player to kill
]]
function PlayerStatus.KillPlayer(player: Player)
	KillPlayer(player)
end

--[[
    Gets the current walk state of the specified player.
    This does not check if they are moving or not.

    @param player Player - player to kill

    @return "Crouch" | "Walk" | "Sprint" - current player state
]]
function PlayerStatus.CurrentMovementState(player: Player): "Crouch" | "Walk" | "Sprint"
	return "Walk" -- logic will be added in later if this even gets used.
end

return PlayerStatus
