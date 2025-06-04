--!strict

--[[
Item connection for handling player clicking on things you can pickup

searches for a part called doorRight and doorLeft, 
meaning this works for single and double doors,
the doors to click should be put in a Clickable folder

//special attributes:
-neccesary:

-optional:
DoorRotation --how much the door will open
DoorOpenSound --sound when door opens
DoorCloseSound --sound when door closes

]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local PartTween = require(ReplicatedStorage.Common.PartTween)
local Sounds = require(ReplicatedStorage.Common.Sounds)

return {
	First = function(_cleaner: typeof(Trove.new()), _linkModel: Model)
		--should consider adding a function to the cleaner to close the dooe on tag remove
	end,

	Activated = function(_cleaner: typeof(Trove.new()), _linkModel: Model, _player: Player, _attempts: number) --error if activation not excepted
		local base = _linkModel.PrimaryPart :: BasePart
		local doorRight = _linkModel:FindFirstChild("RightDoor", true) :: BasePart?
		local doorLeft = _linkModel:FindFirstChild("LeftDoor", true) :: BasePart?

		local rotation = _linkModel:GetAttribute("DoorRotation") :: number or 90

		local doorOpenSound = _linkModel:GetAttribute("DoorOpenSound") :: string or "DoorOpen"
		local doorCloseSound = _linkModel:GetAttribute("DoorCloseSound") :: string or "DoorClose"

		local doorSound: Sound? = nil
		local trueRotation = 0

		local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine)

		--door  close
		if _attempts % 2 == 0 then
			trueRotation = -rotation
			doorSound = Sounds.FindSoundByName(doorCloseSound, base)
		else --door open
			trueRotation = rotation
			doorSound = Sounds.FindSoundByName(doorOpenSound, base)
		end

		if doorSound then
			doorSound.PlayOnRemove = true
			doorSound:Destroy()
		end

		if doorRight then
			PartTween.Move(doorRight, doorRight:GetPivot() * CFrame.Angles(0, trueRotation, 0), tweenInfo)
		end
		if doorLeft then
			PartTween.Move(doorLeft, doorLeft:GetPivot() * CFrame.Angles(0, -trueRotation, 0), tweenInfo)
		end

		task.wait(tweenInfo.Time)
	end,
}
