--!strict

--roblox/luau-tag-utils

local CollectionService = game:GetService("CollectionService")

--[[
	Get instances with all specified tags
]]
local function getAll(...: string): { Instance }
	local totalTags = select("#", ...)
	assert(totalTags ~= 0, "getAll should receive at least one tag")

	local firstTag = ...

	if totalTags == 1 then
		return CollectionService:GetTagged(firstTag)
	else
		local instances = {}
		for _, instance in ipairs(CollectionService:GetTagged(firstTag)) do
			local hasAllTags = true
			for i = 2, totalTags do
				local otherTag = select(i, ...)
				if not CollectionService:HasTag(instance, otherTag) then
					hasAllTags = false
					break
				end
			end

			if hasAllTags then
				table.insert(instances, instance)
			end
		end
		return instances
	end
end

--[[
	Get all instances with at least one specified tag
]]
local function getAny(...: string): { Instance }
	local totalTags = select("#", ...)
	assert(totalTags ~= 0, "getAny should receive at least one tag")

	if totalTags == 1 then
		local firstTag = ...
		return CollectionService:GetTagged(firstTag)
	else
		local inserted = {}
		local instances = {}
		for i = 1, totalTags do
			local tag = select(i, ...)
			for _, taggedInstance in ipairs(CollectionService:GetTagged(tag)) do
				if not inserted[taggedInstance] then
					inserted[taggedInstance] = true
					table.insert(instances, taggedInstance)
				end
			end
		end
		return instances
	end
end

--[[
	If the specified tags only contain one instance across them

	Useful for special tags that are used in making specific cutscenes and events in game progression
]]
local function getUnique(...: string): Instance
	local tagged = getAll(...)
	local total = #tagged

	if total == 1 then
		return tagged[1]
	end

	if total == 0 then
		error(("unable to find instance tagged with %s"):format(table.concat({ ... }, ", ")))
	end

	error(
		("expected to find only one instance tagged with %s, but found %d"):format(table.concat({ ... }, ", "), #tagged)
	)
end

-- made by VIPER

--[[
	Basic setup for listening in on tags for OOP structures
]]
local function setObjectListner<T>(class: T & any): (() -> (), { [Instance]: T })
	local instances = {}

	local instanceAddedSignal = CollectionService:GetInstanceAddedSignal(class.TAG_NAME)
	local instanceRemovedSignal = CollectionService:GetInstanceRemovedSignal(class.TAG_NAME)

	local function onInstanceAdded(instance)
		instances[instance] = class.new(instance)
	end

	local function onInstanceRemoved(instance)
		instances[instance]:Cleanup()
		instances[instance] = nil
	end

	for _, instance in pairs(CollectionService:GetTagged(class.TAG_NAME)) do
		task.spawn(onInstanceAdded, instance)
	end
	local listiner1 = instanceAddedSignal:Connect(onInstanceAdded)
	local listiner2 = instanceRemovedSignal:Connect(onInstanceRemoved)

	return function()
		if listiner1 then
			listiner1:Disconnect()
		end
		if listiner2 then
			listiner2:Disconnect()
		end
	end,
		instances
end

--[[
	Small taging library with some custom extensions
]]
return {
	GetUnique = getUnique,
	GetAll = getAll,
	GetAny = getAny,
	SetObjectListner = setObjectListner,
}
