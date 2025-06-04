--!strict

--[[
	This is static information
]]

local UserInputService = game:GetService("UserInputService")

local GlobalInfo = {}

GlobalInfo.MaxPlayers = 4 --4

GlobalInfo.Spawn = {
	SPAWN_TIME = 10,
}

GlobalInfo.Movement = {
	SPEED = {
		Walking = 8, --8
		Running = 16, --16
	},

	MAX_STAMINA = 100, --100
	STAMINA_REGEN = 0.1, --0.05
	STAMINA_DRAIN = 0.2, --0.1
}

GlobalInfo.InfoText = {
	CHAR_PER_SEC = 17, --17
	INFO_CLICK_SPEED = 1, --1
	ACT_DIST = 9, --9
}

GlobalInfo.Clock = {
	BADGE_TIME = 2 * 60 * 60, --2hr in sec
}

GlobalInfo.Viewer = {
	DISPLAY_DIST = 2, --stud
	ROTATE_SPEED = 1.5, --deg
}

function GlobalInfo.NewHoverId(parent: Instance, id: number?): IntValue
	local HoverId = Instance.new("IntValue")
	HoverId.Name = "HoverId"
	HoverId.Value = id or 0
	HoverId.Parent = parent

	return HoverId
end

--no touchy
GlobalInfo.UniversalInput = {
	LeftClick = function(input: InputObject): boolean
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			return true
		elseif input.KeyCode == Enum.KeyCode.ButtonR2 then
			return true
		elseif input.UserInputType == Enum.UserInputType.Touch then
			return true
		else
			return false
		end
	end,

	LeftShift = function(input: InputObject?): boolean
		if input then
			if input.KeyCode == Enum.KeyCode.LeftShift then
				return true
			elseif input.KeyCode == Enum.KeyCode.ButtonL2 then
				return true
			elseif input.UserInputType == Enum.UserInputType.Touch then
				return true
			end
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			return true
		elseif UserInputService:IsKeyDown(Enum.KeyCode.ButtonL2) then
			return true
		end

		return false
	end,

	U = function(input: InputObject?): boolean
		if input then
			if input.KeyCode == Enum.KeyCode.U then
				return true
			elseif input.KeyCode == Enum.KeyCode.ButtonSelect then
				return true
			end
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.U) then
			return true
		elseif UserInputService:IsKeyDown(Enum.KeyCode.ButtonL3) then
			return true
		end

		return false
	end,

	K = function(input: InputObject?): boolean
		if input then
			if input.KeyCode == Enum.KeyCode.K then
				return true
			elseif input.KeyCode == Enum.KeyCode.DPadRight then
				return true
			end
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.K) then
			return true
		elseif UserInputService:IsKeyDown(Enum.KeyCode.DPadRight) then
			return true
		end

		return false
	end,

	O = function(input: InputObject?): boolean
		if input then
			if input.KeyCode == Enum.KeyCode.O then
				return true
			elseif input.KeyCode == Enum.KeyCode.DPadUp then
				return true
			end
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.O) then
			return true
		elseif UserInputService:IsKeyDown(Enum.KeyCode.DPadUp) then
			return true
		end

		return false
	end,
}

return GlobalInfo
