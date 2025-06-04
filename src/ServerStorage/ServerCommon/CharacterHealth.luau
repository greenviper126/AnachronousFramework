--!strict

local MAX_HEALTH = 100 --can connect to global instead

local CharacterHealth = {}

function CharacterHealth.Set(player: Player, health: number)
	player:SetAttribute("_Health", health)
end

function CharacterHealth.Get(player: Player): number
	return player:GetAttribute("_Health") :: number or 0
end

function CharacterHealth.Damage(player: Player, damage: number)
	player:SetAttribute("_Health", CharacterHealth.Get(player) - damage)
end

function CharacterHealth.Heal(player: Player, heal: number)
	player:SetAttribute("_Health", CharacterHealth.Get(player) + heal)
end

function CharacterHealth.Kill(player: Player)
	CharacterHealth.Set(player, 0)
end

function CharacterHealth.SetFullHealth(player: Player)
	CharacterHealth.Set(player, CharacterHealth.MaxHealth())
end

function CharacterHealth.MaxHealth(): number
	return MAX_HEALTH
end

function CharacterHealth.Dead(player: Player): boolean
	return player:GetAttribute("_Dead") and true or false
end

return CharacterHealth
