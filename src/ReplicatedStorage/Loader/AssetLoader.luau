--!strict

local FLASHLIGHT_ASSET_ID = 136192578782497

local InsertService = game:GetService("InsertService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--locations
local playerFlashlight = ReplicatedStorage:FindFirstChild("PlayerFlashlight")

local function loadTo(assetId: number, parent: Instance)
	local success, asset = pcall(InsertService.LoadAsset, InsertService, assetId)
	if success and asset then
		local model = asset:GetChildren()[1]
		model.Parent = parent
		asset:Destroy()
	else
		print("Model with assetId of " .. assetId .. " failed to load!")
	end
end

--[[
    loads any assets that cannot be converted into script
]]
return function()
	loadTo(FLASHLIGHT_ASSET_ID, playerFlashlight) -- player flashlight
end
