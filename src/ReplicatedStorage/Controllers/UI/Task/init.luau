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

	local self = setmetatable({} :: self, Task)
	self._cleaner = Trove.new()

	local gui, canvas, description = taskUI.New(player.PlayerGui)
	self.gui = gui
	self.canvas = canvas
	self.description = description

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
	return Players:GetAttribute("_TaskName"), Players:GetAttribute("_Task")
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
	Creates a new task

	@param self Task - object
	@param name string? - name of the task
	@param description string? - description of the text
]]
function Task.NewTask(self: Task, name: string?, description: string?)
	self.prevName = name
	self.prevDescription = description

	self.description.Text = description or ""
	self:FadeUI("In")
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

	self.description.Text = ""

	self:FadeUI("Out")
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

		local description = Players:GetAttribute("_Task")
		local name = Players:GetAttribute("_TaskName")

		if name == nil or description == nil then -- no data
			self:RemoveTask()
		elseif self.prevName ~= name then -- name changed
			self:NewTask(name, description)
		elseif self.prevDescription ~= description then -- description changed
			self:UpdateTask(name, description)
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
local _cleanup, _objects = Utility.Tags.SetObjectListner(Task.new(), Task)
local _uniqueClass = Utility.Tags.GetUniqueClass(Task.TAG_NAME, _objects)

-------------------------------------------------------------------------------------------

return {}
