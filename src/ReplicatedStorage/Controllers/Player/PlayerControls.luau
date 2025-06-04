--!strict

--[==[
controller for players movement and camera
]==]

local DEFAULT_MOUSE_IMAGE = 9129033463 --white circle
local DEFUALT_HOVER_IMAGE = 5107199773 --magnify glass
local CLICK_DISTANCE = 9 --studs

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RedEvents = require(ReplicatedStorage.RedEvents)
local clientSignal = RedEvents.Signal.Client

local Modal = require(ReplicatedStorage.ClientCommon.Modal)
local Weight = require(ReplicatedStorage.Common.Weight)

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
local camera = workspace.CurrentCamera

local Controls = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls() :: any

--------------------------------------------

local MouseGUI = Instance.new("ScreenGui")
MouseGUI.DisplayOrder = 499
MouseGUI.ResetOnSpawn = false
MouseGUI.Name = "Mouse"

local dot = Instance.new("ImageLabel")
dot.Name = "Dot"
dot.AnchorPoint = Vector2.new(0.5, 0.5)
dot.Position = UDim2.new(0.5, 0, 0.5, 0)
dot.Size = UDim2.new(0.03, 10, 0.03, 10)
dot.SizeConstraint = Enum.SizeConstraint.RelativeXX
dot.Image = "rbxassetid://" .. DEFAULT_MOUSE_IMAGE
dot.BackgroundTransparency = 1
dot.ScaleType = Enum.ScaleType.Crop
dot.Parent = MouseGUI

MouseGUI.Parent = player.PlayerGui

-------------------------------------------

local movementWeight = Weight.new()
player:SetAttribute("_MovementControls", true)
function MovementEnabled(enable: boolean, weight: number)
	if enable then
		movementWeight:Add(weight)
	else
		movementWeight:Remove(weight)
	end

	if not movementWeight:IsMax(weight) then
		return
	end

	player:SetAttribute("_MovementControls", enable)

	--seems to work with physics controller too
	Controls:Enable(enable)
end

local mouseWeight = Weight.new()
local mouseOn = true
player:SetAttribute("_MouseControls", mouseOn)
function MouseEnabled(enable: boolean, weight: number)
	if enable then
		mouseWeight:Add(weight)
	else
		mouseWeight:Remove(weight)
	end

	if not mouseWeight:IsMax(weight) then
		return
	end

	player:SetAttribute("_MouseControls", enable)

	mouseOn = enable
end

function MouseImage(imageID: number?)
	dot.Image = "rbxassetid://" .. (imageID or DEFAULT_MOUSE_IMAGE)
end

local lookWeight = Weight.new()
local lockPosition = false
player:SetAttribute("_LookControls", not lockPosition)
function LookEnabled(enable: boolean, weight: number)
	if enable then
		lookWeight:Add(weight)
	else
		lookWeight:Remove(weight)
	end

	if not lookWeight:IsMax(weight) then
		return
	end

	player:SetAttribute("_LookControls", enable)

	lockPosition = enable
end

local jumpWeight = Weight.new()
local canJump = true
player:SetAttribute("_JumpControls", canJump)
function JumpEnabled(enable: boolean, weight: number)
	if enable then
		jumpWeight:Add(weight)
	else
		jumpWeight:Remove(weight)
	end

	if not jumpWeight:IsMax(weight) then
		return
	end

	player:SetAttribute("_JumpControls", enable)

	canJump = enable
end

-------------------------------------------

do --GUI mouse
	local mouse: Mouse = nil

	local HoverFocus = Instance.new("ObjectValue")
	HoverFocus.Name = "HoverFocus"
	HoverFocus.Parent = player

	local function GetHover()
		if not mouse or not mouse.Target or not player.Character then
			return
		end

		local HoverId = mouse.Target:FindFirstChild("Hover", true)
		HoverFocus.Value = HoverId

		if not HoverId or not HoverId:IsA("IntValue") then
			return
		end

		local params = RaycastParams.new()
		params.FilterDescendantsInstances =
			{ HoverId:FindFirstAncestorWhichIsA("BasePart") :: any, player.Character:GetDescendants() }
		params.FilterType = Enum.RaycastFilterType.Include

		local ray = workspace:Raycast(camera.CFrame.Position, camera.CFrame.LookVector * CLICK_DISTANCE, params)

		if ray then
			return (HoverId.Value ~= 0) and HoverId.Value or DEFUALT_HOVER_IMAGE
		end

		return nil
	end

	UserInputService.MouseIconEnabled = false

	local prevTime = 0
	RunService.RenderStepped:Connect(function()
		if mouse then
			dot.Position = UDim2.fromOffset(mouse.X, mouse.Y)
			dot.Position = UDim2.fromOffset(mouse.X, mouse.Y)

			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			mouse = player:GetMouse()
		end

		dot.Visible = mouseOn

		if Modal.AnyIsOn() then
			dot.Visible = true
		end

		if time() - prevTime < 0.2 then
			return
		end
		prevTime = time()

		MouseImage(GetHover())
	end)
end

do --set jump state
	local humanoid: Humanoid = nil
	local prevTime = 0
	RunService.Heartbeat:Connect(function()
		if time() - prevTime < 1 then
			return
		end
		prevTime = time()

		if not humanoid and player.Character then
			humanoid = player.Character:FindFirstChildWhichIsA("Humanoid")
		end

		if not humanoid then
			return
		end

		humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, canJump)
	end)
end

--lock camera and run before any other camera code
RunService:BindToRenderStep("CamLock", Enum.RenderPriority.Camera.Value - 1, function()
	if lockPosition then
		camera.CameraSubject = Enum.CameraType.Track
	end
end)

clientSignal.DisablePlayerControls:Connect(function(controlType: number, enable: boolean, weight: number)
	if controlType == 1 then
		MovementEnabled(enable, weight)
	elseif controlType == 2 then
		MouseEnabled(enable, weight)
	elseif controlType == 3 then
		MouseImage(weight)
	elseif controlType == 4 then
		LookEnabled(enable, weight)
	elseif controlType == 5 then
		JumpEnabled(enable, weight)
	else
		warn(controlType, " is not an accepted number for control type.")
	end
end)

return {}
