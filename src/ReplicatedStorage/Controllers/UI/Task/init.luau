--!strict

--[[
	need to add in new UI for this
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Trove = require(ReplicatedStorage.Packages.trove)

local Utility = require(ReplicatedStorage.Utility)

local Sounds = require(ReplicatedStorage.Common.Sounds)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local taskUI = require(script:WaitForChild("TaskUI"))

local Task = {}
Task.__index = Task
Task.TAG_NAME = "Task"
Task.PrevNameUsed = nil :: string?

type self = {
	gui: ScreenGui,
	canvas: CanvasGroup,
	description: TextLabel,
	divider: Frame,

	newObjectiveThread: thread?,
	removeObjectiveThread: thread?,

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
	local sizeValue = direction == "In" and 1 or 0.001
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
			task.wait(1)
		end

		--add new task
		self.prevName = name
		self.prevDescription = description
		self.description.Text = description or ""

		if Task.PrevNameUsed ~= name then -- no sound if you respawn unless its new
			Sounds.PlaySoundByName("NewTask")
		end

		--fade in
		self:FadeUI("In")

		task.wait(0.3)

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
function Task.RemoveTask(self: Task, quite: boolean?)
	if self.removeObjectiveThread then
		task.cancel(self.removeObjectiveThread)
	end

	self.prevName = nil
	self.prevDescription = nil

	if not quite and self.canvas.GroupTransparency == 0 then
		Sounds.PlaySoundByName("RemoveTask")
	end

	self.removeObjectiveThread = task.spawn(function()
		self:AnimateLine("Out")

		task.wait(0.3)

		self:FadeUI("Out")
	end)
end

--[[
	Listens to player service for any changes in the task

	@param self Task - object
]]
function Task.Listen(self: Task)
	local function addOrRemove()
		local description = Players:GetAttribute("_Task") :: string?
		local name = Players:GetAttribute("_TaskName") :: string?

		if not name then
			self:RemoveTask()
		elseif self.prevName ~= name then
			self:NewTask(name, description)
		end
	end

	local function update()
		local description = Players:GetAttribute("_Task") :: string?
		local name = Players:GetAttribute("_TaskName") :: string?

		if self.prevName == name and self.prevDescription ~= description then
			self:UpdateTask(name, description)
		end
	end

	addOrRemove()
	self._cleaner:Connect(Players:GetAttributeChangedSignal("_TaskName"), function()
		addOrRemove()
	end)

	self._cleaner:Connect(Players:GetAttributeChangedSignal("_Task"), function()
		update()
	end)
end

--[[
	Cleans up the Task object.

	@param self Task - object
]]
function Task.Cleanup(self: Task)
	Task.PrevNameUsed = self.prevName
	self:RemoveTask(true)

	task.wait(1.2)

	self._cleaner:Destroy()
end

-------------------------------------------------------------------------------------------

local _characterTagConnection = Utility.Tags.TagCharacterConnection(Task.TAG_NAME)
local _cleanup, _objects = Utility.Tags.SetObjectListener(Task)
local _uniqueClass = Utility.Tags.GetUniqueClass(Task.TAG_NAME, _objects)

-------------------------------------------------------------------------------------------

return {}
