--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)

local sendSignal = RedEvents.SystemConnect.FireClient("CameraBobbing")

local cameraUtility = {}

--[[
    Sets the camera to fist person or unlocks it.

    @param set boolean - Set to first person or unlock
]]
function cameraUtility.SetFirstPerson(set: boolean)
	sendSignal("SetFirstPerson", set)
end

--[[
    Gets the camera state of fist person or unlock.

    @return boolean - current state of first person or unlock
]]
function cameraUtility.GetFirstPerson(): boolean
	return sendSignal("GetFirstPerson")
end

--[[
    Connect a function to the FirstPerson camera type
	
	Will run when the character dies or the camera type was switched to unlock

    @param func () -> () - function you want to run
]]
function cameraUtility.ConnectFunctionToFirstPersonType(func: () -> ())
	sendSignal("ConnectFunctionToFirstPersonType", func)
end

--[[
    Connect a function to the FirstPerson camera type to run while in first person
	
	Cleanup function will run when the character dies or the camera type was switched to unlock

    @param run () -> () - function you want to run in first person
	@param cleanup () -> () - function you want to cleanup the run
]]
function cameraUtility.ConnectAndListenToFirstPersonType(run: () -> (), cleanup: () -> ())
	sendSignal("ConnectFunctionToFirstPersonType", run, cleanup)
end

return cameraUtility
