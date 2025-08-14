--!strict

--[[
	Highlights objects

	replaces proximity prompts
]]

local CollectionService = game:GetService("CollectionService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Input = require(ReplicatedStorage.Packages.input)
local Trove = require(ReplicatedStorage.Packages.trove)

local RedEvents = require(ReplicatedStorage.RedEvents)

local Highlighter = require(script:WaitForChild("Highlighter"))

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local buttonActivated = RedEvents.NewSignal()

type HighlightPrompt = {
	ClickablePrompt: boolean,
	Enabled: boolean,
	MaxActivationDistance: number,

	HighlightDepthMode: Enum.HighlightDepthMode,
	HighlightOutlineColor: Color3,
	HighlightFillColor: Color3,
	HighlightOutlineTransparency: number,
	HighlightFillTransparency: number,

	HoverEnter: RBXScriptSignal,
	HoverEscape: RBXScriptSignal,
	Activated: RBXScriptSignal,

	Destroy: () -> (),
}

local function createPrompt(parent: Instance): HighlightPrompt
	local cleaner = Trove.new()
	local hoverEnter = cleaner:Add(Instance.new("BindableEvent"))
	local hoverEscape = cleaner:Add(Instance.new("BindableEvent"))
	local activated = cleaner:Add(Instance.new("BindableEvent"))

	local base = parent:IsA("BasePart") and parent or parent:FindFirstAncestorWhichIsA("BasePart")

	local results = {
		ClickablePrompt = true,
		Enabled = true,
		MaxActivationDistance = 8,

		HighlightDepthMode = Enum.HighlightDepthMode.Occluded,
		HighlightOutlineColor = Color3.new(1, 1, 1),
		HighlightFillColor = Color3.new(1, 1, 1),
		HighlightOutlineTransparency = 0.25,
		HighlightFillTransparency = 0.7,

		HoverEnter = hoverEnter.Event,
		HoverEscape = hoverEscape.Event,
		Activated = activated.Event,

		Destroy = function()
			cleaner:Destroy()
		end,
	} :: HighlightPrompt

	if base then
		local self = Highlighter.new(parent)

		parent:AddTag("HighlightHover")

		local function foundTaggedObject(object: BasePart)
			local isHover = CollectionService:HasTag(object, "HighlightHover")
			return isHover and object == parent
		end

		local function hitBase(raycast: RaycastResult)
			local directTag = foundTaggedObject(raycast.Instance)
			local indirectTag = nil

			local ancestorBase = raycast.Instance:FindFirstAncestorWhichIsA("BasePart")
			if ancestorBase then
				indirectTag = foundTaggedObject(ancestorBase)
			end

			return directTag or indirectTag
		end

		local function inRange(raycast: RaycastResult)
			return results.MaxActivationDistance > raycast.Distance
		end

		local function hitHighlightPrompt(): boolean
			if not player.Character then
				return false
			end

			local raycastParams = RaycastParams.new()
			raycastParams.IgnoreWater = true
			raycastParams.FilterDescendantsInstances = { player.Character:GetDescendants() }

			local ray = Input.Mouse:Raycast(raycastParams)

			if ray and hitBase(ray) and inRange(ray) then
				return true
			else
				return false
			end
		end

		parent:SetAttribute("HighlightEnabled", false)
		cleaner:Connect(RunService.RenderStepped, function()
			parent:SetAttribute("HighlightDepthMode", results.HighlightDepthMode)
			parent:SetAttribute("HighlightOutlineColor", results.HighlightOutlineColor)
			parent:SetAttribute("HighlightFillColor", results.HighlightFillColor)
			parent:SetAttribute("HighlightOutlineTransparency", results.HighlightOutlineTransparency)
			parent:SetAttribute("HighlightFillTransparency", results.HighlightFillTransparency)

			if not results.Enabled then
				parent:SetAttribute("HighlightEnabled", false)
				return
			end

			if hitHighlightPrompt() then
				parent:SetAttribute("HighlightEnabled", true)
			else
				parent:SetAttribute("HighlightEnabled", false)
			end
		end)

		cleaner:Connect(parent.AttributeChanged, function(attribute: string)
			if not results.Enabled then
				return
			end
			if attribute ~= "HighlightEnabled" then
				return
			end

			local highlightHoverEnabled = parent:GetAttribute("HighlightEnabled")
			if highlightHoverEnabled then
				hoverEnter:Fire()
			else
				hoverEscape:Fire()
			end
		end)

		local lastActivationTime = 0
		local connection = buttonActivated:Connect(function()
			if not results.ClickablePrompt then
				return
			end
			if not results.Enabled then
				return
			end

			if time() - lastActivationTime < 0.1 then
				return
			end
			lastActivationTime = time()

			local highlightEnabled = parent:GetAttribute("HighlightEnabled")
			if not highlightEnabled then
				return
			end

			activated:Fire()
		end)

		cleaner:Add(function()
			parent:SetAttribute("HighlightEnabled", nil)
			parent:RemoveTag("HighlightHover")
			connection()
			self:Cleanup()
		end)
	else
		warn("Could not find base to attach HighlightHover, Parent: " .. parent:GetFullName())
	end

	return results
end

-------------------------------------------------------------------------------------------

local lastClickState = false
RunService.RenderStepped:Connect(function()
	if Input.Mouse:IsLeftDown() then
		if lastClickState then
			return
		end
		lastClickState = true

		buttonActivated:Fire()
	else
		lastClickState = false
	end
end)

local function buttonPressed(_actionName: string, inputState: Enum.UserInputState, _inputObject: InputObject)
	if inputState == Enum.UserInputState.End then
		return Enum.ContextActionResult.Pass
	end

	buttonActivated:Fire()

	return Enum.ContextActionResult.Sink
end

ContextActionService:BindActionAtPriority(
	"HighlightPrompt",
	buttonPressed,
	true,
	3000,
	Enum.KeyCode.E,
	Enum.KeyCode.ButtonR1
)

-------------------------------------------------------------------------------------------

local HighlightPrompt = {}

function HighlightPrompt.SetHighlightPreset(prompt: HighlightPrompt, preset: "Confirm" | "Deny")
	if preset == "Confirm" then
		prompt.HighlightOutlineColor = Color3.new(0.55, 1, 0.55)
		prompt.HighlightFillColor = Color3.new(0.48, 0.89, 0.48)
		prompt.HighlightOutlineTransparency = 0.25
		prompt.HighlightFillTransparency = 0.7
	elseif preset == "Deny" then
		prompt.HighlightOutlineColor = Color3.new(1, 0.27, 0.27)
		prompt.HighlightFillColor = Color3.new(0.81, 0.34, 0.34)
		prompt.HighlightOutlineTransparency = 0.25
		prompt.HighlightFillTransparency = 0.7
	end
end

function HighlightPrompt.Create(parent: BasePart): HighlightPrompt
	return createPrompt(parent)
end

return HighlightPrompt
