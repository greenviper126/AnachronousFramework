--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Trove = require(ReplicatedStorage.Packages.trove)

local LevelUtil = require(ServerStorage.ServerCommon.LevelUtil)

local Section = {}
Section.Name = script.Name

local cleaner: typeof(Trove.new()) = nil
function Section.Start()
	cleaner = Trove.new()

	--[[
	local map, scripted, storage = GameplayTools.InitMap(Section.Name, nil)

	if RunService:IsStudio() and ReplicatedStorage:GetAttribute("SkipIntro") then
		task.wait(2)
	else
		GameplayTools.EventSync.GlobalStart("IntroCutscene", Players:GetPlayers()):Wait()
	end
	]]

	Section.Stop()
end

function Section.Stop()
	if cleaner then
		cleaner:Destroy()
	end
end

return Section
