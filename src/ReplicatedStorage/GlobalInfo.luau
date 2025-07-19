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
		DEFAULT_BAR_COLOR = Color3.new(1, 1, 1), --Color3
		TIRED_BAR_COLOR = Color3.new(0.6, 0.6, 0.6), --Color3
	},
}

GlobalInfo.SPAWN = {
	SPAWN_TIME = 6, --float
}

GlobalInfo.INFO_TEXT = {
	CHAR_PER_SEC = 17, --int
}

GlobalInfo.VIEWER = {
	DISPLAY_DIST = 2, --float, stud
	ROTATE_SPEED = 1.5, --float, deg
}

return GlobalInfo
