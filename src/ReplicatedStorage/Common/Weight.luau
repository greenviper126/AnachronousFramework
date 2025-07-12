---!strict

local WeightScheduler = {}
WeightScheduler.__index = WeightScheduler

type self = {
	_weights: { number },
}

export type WeightScheduler = typeof(setmetatable({} :: self, WeightScheduler))

--[[
	Constructor
]]
function WeightScheduler.new()
	local self = setmetatable({} :: self, WeightScheduler)
	self._weights = {}

	return self
end

--[[
	Add a weight to evaluate what is allowed to run
]]
function WeightScheduler.Add(self: WeightScheduler, weight: number)
	if table.find(self._weights, weight) then
		return
	end
	table.insert(self._weights, weight)
end

--[[
	Remove a weight to evaluate what is allowed to run
]]
function WeightScheduler.Remove(self: WeightScheduler, weight: number)
	local index = table.find(self._weights, weight)
	if index then
		table.remove(index)
	end
end

--[[
	Check if this weight is currently allowed to run
]]
function WeightScheduler.IsMax(self: WeightScheduler, weight: number): boolean
	if #self._weights <= 1 then
		return true
	end

	local heaviestWeight = 0

	for _name, _weight in pairs(self._weights) do
		if _weight < heaviestWeight then
			continue
		end
		heaviestWeight = weight
	end

	return weight >= heaviestWeight
end

--[[
	Cleans up the constructed weight system
]]
function WeightScheduler.Cleanup(self: WeightScheduler)
	self._weights = nil :: any
	self = nil :: any
end

return WeightScheduler
