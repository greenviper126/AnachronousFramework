--!strict

local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

PhysicsService:RegisterCollisionGroup("Player")
PhysicsService:CollisionGroupSetCollidable("Default", "Player", true)
PhysicsService:CollisionGroupSetCollidable("Player", "Player", false)

Players.PlayerAdded:Connect(function(player: Player)
	player.CharacterAdded:Connect(function(character: Model)
		task.delay(0.5, function()
			if not character then
				return
			end

			for _, inst in pairs(character:GetChildren()) do
				if not inst:IsA("BasePart") then
					continue
				end
				inst.CollisionGroup = "Player"
			end
		end)
	end)
end)

return {}
