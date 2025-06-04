--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Topbarplus = require(ReplicatedStorage.Packages.topbarplus)

local Admin = require(ReplicatedStorage.Common.Admin)

--local Settings = require(script:WaitForChild("Settings"))
--local Controls = require(script:WaitForChild("Controls"))

if Admin.IsLocalAdmin() then
	local _cmdr = Topbarplus.new()
		:setImage(14906357941)
		:setCaption("CMDR")
		:bindEvent("toggled", function(_, enabled: boolean)
			print(enabled)
		end)
		:setRight()
end

local _controlsIcon = Topbarplus.new()
	:setImage(13868180009)
	:setCaption("Controls")
	:bindToggleKey(Enum.KeyCode.K)
	:bindEvent("toggled", function(_, enabled: boolean)
		print(enabled)
	end)
	:setRight()

local _settingsIcon = Topbarplus.new()
	:setImage(14897655548)
	:setCaption("Options")
	:bindToggleKey(Enum.KeyCode.L)
	:bindEvent("toggled", function(_, enabled: boolean)
		print(enabled)
	end)
	:setRight()

return {}
