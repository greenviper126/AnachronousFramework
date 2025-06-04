--!strict

local Attributes = {}

--adds multiple attributes at one time with the same value
function Attributes.Add(instance: Instance, value: any, ...: string)
	for _, attribute in pairs({ ... }) do
		instance:SetAttribute(attribute, value)
	end
end

--listens for given attributes on an instance, can be disconncetd
function Attributes.Listen(instance: Instance, func: () -> (), ...: string): { Disconnect: (self: any) -> () }
	local connections = {}

	local event = Instance.new("BindableEvent")

	event.Event:Connect(function()
		func()
	end)

	for _, attribute in pairs({ ... }) do
		local connection = instance:GetAttributeChangedSignal(attribute):Connect(function()
			event:Fire()
		end)

		table.insert(connections, connection)
	end

	return {
		Disconnect = function()
			for _, connection in pairs(connections) do
				connection:Disconnect()
			end

			event:Destroy()
		end,
	}
end

--checks if atleast 1 given attributes exist on the given instance
function Attributes.Exists(instance: Instance, ...: string): boolean
	for _, attribute in pairs({ ... }) do
		if instance:GetAttribute(attribute) ~= nil and true or false then
			return true
		end
	end

	return false
end

--checks if all given attributes exist on the given instance
function Attributes.AllExists(instance: Instance, ...: string): boolean
	for _, attribute in pairs({ ... }) do
		if not (instance:GetAttribute(attribute) ~= nil and true or false) then
			return false
		end
	end

	return true
end

--get all decendants that have atleast 1 given attributes
function Attributes.GetAny(folder: Instance, ...: string): { Instance }
	local instances = {}

	for _, inst in pairs(folder:GetDescendants()) do
		if not Attributes.Exists(inst, ...) then
			continue
		end
		table.insert(instances, inst)
	end

	return instances
end

--get all decendants that have all given attributes
function Attributes.GetAll(folder: Instance, ...: string): { Instance }
	local instances = {}

	for _, inst in pairs(folder:GetDescendants()) do
		if not Attributes.AllExists(inst, ...) then
			continue
		end
		table.insert(instances, inst)
	end

	return instances
end

--clear all attributes on an instance
function Attributes.Clear(instance: Instance)
	for attribute, _ in pairs(instance:GetAttributes()) do
		instance:SetAttribute(attribute, nil)
	end
end

return Attributes
