--!strict

local Players = game:GetService("Players")

local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local ModalGUI = Instance.new("ScreenGui")
ModalGUI.DisplayOrder = 499
ModalGUI.ResetOnSpawn = false
ModalGUI.Name = "MainModal"

ModalGUI.Parent = player.PlayerGui

local function newModal(name: string?): TextButton
	local modal = Instance.new("TextButton")
	modal.BackgroundTransparency = 0.99
	modal.Size = UDim2.new(0, 1, 0, 1)
	modal.Modal = true
	modal.ZIndex = 50
	modal.Name = name or "Modal"
	modal.Text = ""
	modal.Visible = false
	modal.Parent = ModalGUI

	return modal
end

local Modal = {}
Modal.__index = Modal

type self = {
	name: string,
	_modal: TextButton,
}

export type Modal = typeof(setmetatable({} :: self, Modal))

--modal system constructor
function Modal.new(name: string)
	local self = setmetatable({} :: self, Modal)
	self.name = name
	self._modal = newModal(name)

	return self
end

--enables modal
function Modal.Enable(self: Modal, enable: boolean)
	self._modal.Visible = enable
end

--checks this modals state
function Modal.IsOn(self: Modal): boolean
	return self._modal.Visible
end

--checks for any modals state thats true
function Modal.AnyIsOn(): boolean
	local isOn = false

	for _, modal in pairs(ModalGUI:GetChildren()) do
		if not modal:IsA("TextButton") then
			continue
		end
		if not modal.Visible then
			continue
		end
		isOn = true
		break
	end

	return isOn
end

--cleans up the constructed modal system
function Modal.Cleanup(self: Modal)
	self._modal:Destroy()
	self = nil :: any
end

return Modal
