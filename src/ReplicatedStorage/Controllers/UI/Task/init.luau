--!strict

--[[
	need to add in new UI for this
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Trove = require(ReplicatedStorage.Packages.trove)

local Utility = require(ReplicatedStorage.Utility)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local taskUI = require(script:WaitForChild("TaskUI"))

local Task = {}
Task.__index = Task
Task.TAG_NAME = "Task"

type self = {
	gui: ScreenGui,
	canvas: CanvasGroup,
	description: TextLabel,
	divider: Frame,

	newObjectiveThread: thread?,

	fadeTween: Tween,

	prevName: string?,
	prevDescription: string?,

	_cleaner: typeof(Trove.new()),
}

export type Task = typeof(setmetatable({} :: self, Task))

--[[
	Constructor

	@return self - the new object
]]
function Task.new()
	if not Utility.Tags.GetUnique(Task.TAG_NAME) then
		warn("There is more than one object with the " .. Task.TAG_NAME .. " Tag")
	end
	print("AHHHHHHHHHHHHH!!!!!!!!!!!!!!!!!!!")

	local self = setmetatable({} :: self, Task)
	self._cleaner = Trove.new()

	local gui, canvas, description, divider = taskUI.New(player.PlayerGui)
	self.gui = gui
	self.canvas = canvas
	self.description = description
	self.divider = divider

	self._cleaner:Add(gui)

	self:Listen()

	return self
end

--[[
	Read player task data.

	@return string? - name of task
	@return string? - description of task
]]
function Task.GetData(): (string?, string?)
	return Players:GetAttribute("_TaskName") :: string, Players:GetAttribute("_Task") :: string
end

--[[
	Creates a new task

	@param self Task - object

	@return number - wait time
]]
function Task.FadeUI(self: Task, direction: "In" | "Out"): number
	local transparencyValue = direction == "In" and 0 or 1
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	TweenService:Create(self.canvas, tweenInfo, { GroupTransparency = transparencyValue }):Play()

	return tweenInfo.Time + tweenInfo.DelayTime
end

--[[
	Animates the separator line

	@param self Task - object

	@return number - wait time
]]
function Task.AnimateLine(self: Task, direction: "In" | "Out"): number
	local sizeValue = direction == "In" and 1 or 0.1
	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine)

	TweenService:Create(self.divider, tweenInfo, { Size = UDim2.new(sizeValue, 0, 0, 10) }):Play()

	return tweenInfo.Time + tweenInfo.DelayTime
end

--[[
	Creates a new task

	@param self Task - object
	@param name string? - name of the task
	@param description string? - description of the text
]]
function Task.NewTask(self: Task, name: string?, description: string?)
	if self.newObjectiveThread then
		task.cancel(self.newObjectiveThread)
	end

	self.newObjectiveThread = task.spawn(function()
		--fade out

		if self.prevName then
			self:RemoveTask()
			task.wait(1 + 0.5)
		end

		--add new task
		self.prevName = name
		self.prevDescription = description
		self.description.Text = description or ""

		--fade in
		self:FadeUI("In")
		self:AnimateLine("In")
	end)
end

--[[
	Updates the current task.

	@param self Task - object
]]
function Task.UpdateTask(self: Task, name: string?, description: string?)
	if self.prevName ~= name then
		return
	end

	self.description.Text = description or ""
end

--[[
	Removes the current task.

	@param self Task - object
]]
function Task.RemoveTask(self: Task)
	self.prevName = nil
	self.prevDescription = nil

	self:FadeUI("Out")
	self:AnimateLine("Out")
end

--[[
	Listens to player service for any changes in the task

	@param self Task - object
]]
function Task.Listen(self: Task)
	self._cleaner:Connect(Players.AttributeChanged, function(attribute: string)
		if attribute ~= "_TaskName" and attribute ~= "_Task" then
			return
		end

		local description = Players:GetAttribute("_Task") :: string?
		local name = Players:GetAttribute("_TaskName") :: string?

		if attribute == "_TaskName" then
			if name == nil then -- no data
				print("remove")
				self:RemoveTask()
			elseif self.prevName ~= name then -- name changed
				print("add", name)
				self:NewTask(name, description)
			end
		elseif attribute == "_Task" then
			if self.prevName == name then
				self:UpdateTask(name, description) --update
			end
		end
	end)
end

--[[
	Cleans up the Task object.

	@param self Task - object
]]
function Task.Cleanup(self: Task)
	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _characterTagConnection = Utility.Tags.TagCharacterConnection(Task.TAG_NAME)
local _cleanup, _objects = Utility.Tags.SetObjectListener(Task)
local _uniqueClass = Utility.Tags.GetUniqueClass(Task.TAG_NAME, _objects)

-------------------------------------------------------------------------------------------

return {}
