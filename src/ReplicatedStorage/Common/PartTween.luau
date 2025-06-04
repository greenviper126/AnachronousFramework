--!strict

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local PartTween = {}

--move and rotate a part from its pivot point by tween
function PartTween.Move(part: BasePart, target: CFrame, info: TweenInfo?)
	local value = Instance.new("CFrameValue")
	value.Value = part:GetPivot()

	value.Changed:Connect(function(v)
		part:PivotTo(v)
	end)

	local newInfo = info or TweenInfo.new(1, Enum.EasingStyle.Sine)
	local tween = TweenService:Create(value, newInfo, { Value = target })
	tween:Play()

	local waitTime = newInfo.Time or 0 + newInfo.DelayTime
	task.delay(waitTime, function()
		value:Destroy()
	end)

	return waitTime
end

--this function will need to be updated
--move and rotate a part from its pivot point by lerp
function PartTween.Lerp(part: BasePart, target: CFrame, alpha: number?)
	local newAlpha = alpha or 1
	local start = 0

	local connection: RBXScriptConnection = nil
	connection = (RunService:IsClient() and RunService.RenderStepped or RunService.Heartbeat):Connect(
		function(delta: number)
			if start >= newAlpha then
				connection:Disconnect()
			end
			start += delta

			part:PivotTo(part:GetPivot():Lerp(target, start * delta))
		end
	)
end

return PartTween
