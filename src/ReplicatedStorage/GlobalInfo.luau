--!strict

--[[
	This is static information
]]

local GlobalInfo = {}

GlobalInfo.MaxPlayers = 6 --int

GlobalInfo.Flashlight = {
	LIGHT_SWITCH_SPEED = 1, -- should be greater than 0.7
}

GlobalInfo.Spawn = {
	SPAWN_TIME = 6, --float
}

GlobalInfo.Movement = {
	SPEED = { --float, stud
		Walking = 8,
		Running = 16,
		Crouching = 6,
	},

	MAX_STAMINA = 100, --int
	STAMINA_REGEN = 0.1, --float
	STAMINA_DRAIN = 0.2, --float
}

GlobalInfo.InfoText = {
	CHAR_PER_SEC = 17, --int
}

GlobalInfo.Viewer = {
	DISPLAY_DIST = 2, --float, stud
	ROTATE_SPEED = 1.5, --float, deg
}

return GlobalInfo
