--!strict

--[[
	This is static information
]]

local GlobalInfo = {}

GlobalInfo.MAX_PLAYERS = 6 --int

GlobalInfo.FLASHLIGHT = {
	LIGHT_SWITCH_SPEED = 1, -- float - should be greater than 0.7
}

GlobalInfo.CAMERA = {
	DEFAULT_FOV = 80,
}

GlobalInfo.MOVEMENT = {
	SPEED = { --character speed
		WALKING = 8,
		RUNNING = 16,
		CROUCHING = 5,
	},
	TRACKING = { --body to camera tracking
		LOOK_LERP_SPEED = 0.2, --float
		TURN_STRENGTH = 70, --float
	},
	STAMINA = { --stamina bar
		MAX_STAMINA = 100, --int
		STAMINA_REGEN = 0.07, --float
		STAMINA_DRAIN = 0.11, --float

		FOV_ZOOM_OUT = 7, --int
		REGEN_PAUSE = 1.5, --float
		FULL_STAMIN_WAIT_TIME = 1.5, --float
		FULL_STAMIN_FADE_TIME = 1, --float
		TIRED_TRANSITION_TIME = 1.5, --float
		DEFAULT_BAR_COLOR = Color3.new(1, 1, 0.93), --Color3
		TIRED_BAR_COLOR = Color3.new(0.27, 0.27, 0.266), --Color3
	},
}

GlobalInfo.INFO_TEXT = {
	CHAR_PER_MIN = 17, --int
	BASE_TEXT_COLOR = Color3.new(1, 1, 0.93),
	PLAYER_COLORS = { --Color3
		[1] = Color3.fromRGB(194, 68, 43),
		[2] = Color3.fromRGB(70, 136, 28),
		[3] = Color3.fromRGB(46, 57, 156),
		[4] = Color3.fromRGB(106, 44, 126),
		[5] = Color3.fromRGB(179, 170, 57),
		[6] = Color3.fromRGB(45, 180, 169),
		[GlobalInfo.MAX_PLAYERS + 1] = Color3.fromRGB(255, 140, 250), --reserved for loading issues
	},
}

GlobalInfo.SPAWN = {
	SPAWN_TIME = 6, --float
}

GlobalInfo.VIEWER = {
	DISPLAY_DIST = 2, --float, stud
	ROTATE_SPEED = 1.5, --float, deg
}

return GlobalInfo
