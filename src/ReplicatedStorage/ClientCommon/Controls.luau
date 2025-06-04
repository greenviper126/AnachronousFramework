--!strict

--[==[
Module for enabling and disabling player controls / local only
]==]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)
local clientSignal = RedEvents.Signal.Client

local Controls = {}

-- stops you from moving
function Controls.MovementEnabled(enable: boolean, weight: number)
	clientSignal.DisablePlayerControls:Fire(1, enable, weight)
end

-- stops you from seeing your mouse
function Controls.MouseEnabled(enable: boolean, weight: number)
	clientSignal.DisablePlayerControls:Fire(2, enable, weight)
end

-- changes the image of the mouse
function Controls.MouseImage(imageID: number?)
	clientSignal.DisablePlayerControls:Fire(3, nil, imageID)
end

-- stops you from looking around
function Controls.LookEnabled(enable: boolean, weight: number)
	clientSignal.DisablePlayerControls:Fire(4, enable, weight)
end

-- stops you from jumping
function Controls.JumpEnabled(enable: boolean, weight: number)
	clientSignal.DisablePlayerControls:Fire(5, enable, weight)
end

-- stops all controls
function Controls.ControlsEnabled(enable: boolean, weight: number)
	Controls.MovementEnabled(enable, weight)
	Controls.MouseEnabled(enable, weight)
	Controls.LookEnabled(enable, weight)
	Controls.JumpEnabled(enable, weight)
end

return Controls
