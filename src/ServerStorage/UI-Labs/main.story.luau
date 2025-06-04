local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIUtility = require(ReplicatedStorage.Packages["ui-labs"])

local controls = {
	Visible = true,
	Time = UIUtility.Slider(0, 0, (60 * 60 * 60) - 1),
	Stamina = UIUtility.Slider(1, 0, 1),
	Task = "",
	Items = UIUtility.Slider(6, 0, 6, 1),
}

local story = {
	controls = controls,
	render = function(props)
		local mainScreen = Instance.new("Frame")
		mainScreen.Name = "Main"
		mainScreen.Size = UDim2.fromScale(1, 1)
		mainScreen.BackgroundTransparency = 1
		mainScreen.Visible = props.controls.Visible

		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Name = "ImageLabel"
		imageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		imageLabel.BackgroundTransparency = 1
		imageLabel.BorderColor3 = Color3.fromRGB(27, 42, 53)
		imageLabel.Image = "http://www.roblox.com/asset/?id=4649823677"
		imageLabel.ImageColor3 = Color3.fromRGB(255, 251, 248)
		imageLabel.ImageTransparency = 0.85
		imageLabel.Position = UDim2.fromOffset(0, -36)
		imageLabel.Size = UDim2.new(1, 0, 1, 36)
		imageLabel.ZIndex = 999
		imageLabel.Parent = mainScreen

		local staticframe = Instance.new("ImageLabel")
		staticframe.Name = "staticframe"
		staticframe.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
		staticframe.BackgroundTransparency = 0.8
		staticframe.BorderColor3 = Color3.fromRGB(17, 17, 17)
		staticframe.Image = "http://www.roblox.com/asset/?id=4388380012"
		staticframe.ImageTransparency = 0.95
		staticframe.Position = UDim2.fromScale(0, -0.1)
		staticframe.Size = UDim2.fromScale(1, 1.2)
		staticframe.ZIndex = 999
		staticframe.Parent = mainScreen

		--background
		local background = Instance.new("CanvasGroup")
		background.Name = "Background"
		background.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		background.BackgroundTransparency = 1
		background.BorderColor3 = Color3.fromRGB(0, 0, 0)
		background.BorderSizePixel = 0
		background.GroupColor3 = Color3.fromRGB(0, 0, 0)
		background.Size = UDim2.fromScale(1, 1)
		background.ZIndex = 0

		local frame = Instance.new("Frame")
		frame.Name = "Frame"
		frame.AnchorPoint = Vector2.new(1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame.BorderSizePixel = 0
		frame.Position = UDim2.fromScale(1, 0)
		frame.Size = UDim2.new(0.1, 20, 1, 0)
		frame.Parent = background

		local frame1 = Instance.new("Frame")
		frame1.Name = "Frame"
		frame1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame1.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame1.BorderSizePixel = 0
		frame1.Size = UDim2.new(1, 0, 0.03, 5)
		frame1.Parent = background

		local frame2 = Instance.new("Frame")
		frame2.Name = "Frame"
		frame2.AnchorPoint = Vector2.new(0, 1)
		frame2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame2.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame2.BorderSizePixel = 0
		frame2.Position = UDim2.fromScale(0, 1)
		frame2.Size = UDim2.new(1, 0, 0.03, 5)
		frame2.Parent = background

		local frame3 = Instance.new("Frame")
		frame3.Name = "Frame"
		frame3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		frame3.BorderColor3 = Color3.fromRGB(0, 0, 0)
		frame3.BorderSizePixel = 0
		frame3.Size = UDim2.new(0.1, 20, 1, 0)
		frame3.Parent = background

		background.Parent = mainScreen

		--clock
		local clock = Instance.new("TextLabel")
		clock.Name = "Clock"
		clock.AnchorPoint = Vector2.new(1, 1)
		clock.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		clock.BackgroundTransparency = 1
		clock.BorderColor3 = Color3.fromRGB(0, 0, 0)
		clock.BorderSizePixel = 0
		clock.FontFace = Font.new("rbxassetid://12187371840")
		clock.Position = UDim2.new(1, -3, 1, -3)
		clock.RichText = true
		clock.Size = UDim2.new(0.1, 15, 0.03, 5)
		clock.Text = "00 : 00 : 00"
		clock.TextColor3 = Color3.fromRGB(255, 255, 255)
		clock.TextScaled = true
		clock.TextSize = 20
		clock.TextWrapped = true
		clock.Parent = mainScreen

		local function updateClock(intTime)
			local hr, min, sec = (intTime / 60 / 60) % 60, (intTime / 60) % 60, intTime % 60

			clock.Text = string.format("%02i : %02i : %02i", hr, min, sec)

			local rVal = math.clamp((intTime / (2 * 60 * 60)) ^ 12, 0, 1)
			clock.TextColor3 = Color3.new(1, 1 - rVal, 1 - rVal)
		end
		updateClock(props.controls.Time)

		--stamina
		local stamina = Instance.new("CanvasGroup")
		stamina.Name = "Stamina"
		stamina.AnchorPoint = Vector2.new(0.5, 1)
		stamina.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		stamina.BackgroundTransparency = 1
		stamina.BorderColor3 = Color3.fromRGB(0, 0, 0)
		stamina.BorderSizePixel = 0
		stamina.Position = UDim2.fromScale(0.5, 1)
		stamina.Size = UDim2.new(0.6, 0, 0.03, 5)

		local stamina1 = Instance.new("TextLabel")
		stamina1.Name = "Stamina"
		stamina1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		stamina1.BackgroundTransparency = 1
		stamina1.BorderColor3 = Color3.fromRGB(0, 0, 0)
		stamina1.BorderSizePixel = 0
		stamina1.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
		stamina1.Size = UDim2.fromScale(0.2, 1)
		stamina1.Text = "Stamina"
		stamina1.TextColor3 = Color3.fromRGB(255, 255, 255)
		stamina1.TextScaled = true
		stamina1.TextSize = 14
		stamina1.TextWrapped = true
		stamina1.Parent = stamina

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.FillDirection = Enum.FillDirection.Horizontal
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		uIListLayout.Parent = stamina

		local bar = Instance.new("ImageLabel")
		bar.Name = "Bar"
		bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bar.BackgroundTransparency = 1
		bar.BorderColor3 = Color3.fromRGB(0, 0, 0)
		bar.BorderSizePixel = 0
		bar.LayoutOrder = 2
		bar.Image = "rbxassetid://18850854978"
		bar.ImageTransparency = 0.6
		bar.Size = UDim2.fromScale(0.8, 0.7)

		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.Parent = bar

		local amount = Instance.new("ImageLabel")
		amount.Name = "Amount"
		amount.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		amount.BackgroundTransparency = 1
		amount.BorderColor3 = Color3.fromRGB(0, 0, 0)
		amount.BorderSizePixel = 0
		amount.Image = "rbxassetid://18850854978"
		amount.Size = UDim2.fromScale(props.controls.Stamina, 1)

		local uICorner1 = Instance.new("UICorner")
		uICorner1.Name = "UICorner"
		uICorner1.Parent = amount

		amount.Parent = bar
		bar.Parent = stamina

		stamina.Parent = mainScreen

		--task
		local holder = Instance.new("CanvasGroup")
		holder.Name = "Holder"
		holder.AnchorPoint = Vector2.new(1, 0.5)
		holder.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		holder.BackgroundTransparency = 1
		holder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		holder.BorderSizePixel = 0
		holder.Position = UDim2.fromScale(1, 0.5)
		holder.Size = UDim2.new(0.1, 20, 0.6, 50)

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.Padding = UDim.new(0.01, 5)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.Parent = holder

		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingBottom = UDim.new(0.01, 5)
		uIPadding.PaddingLeft = UDim.new(0.05, 5)
		uIPadding.PaddingRight = UDim.new(0.05, 5)
		uIPadding.PaddingTop = UDim.new(0.01, 5)
		uIPadding.Parent = holder

		local header = Instance.new("TextLabel")
		header.Name = "Header"
		header.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		header.BackgroundTransparency = 1
		header.BorderColor3 = Color3.fromRGB(0, 0, 0)
		header.BorderSizePixel = 0
		header.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
		header.LayoutOrder = 1
		header.Size = UDim2.fromScale(1, 0.1)
		header.Text = "Task"
		header.TextColor3 = Color3.fromRGB(255, 255, 255)
		header.TextScaled = true
		header.TextSize = 40
		header.TextWrapped = true

		local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint.Name = "UITextSizeConstraint"
		uITextSizeConstraint.MaxTextSize = 40
		uITextSizeConstraint.MinTextSize = 10
		uITextSizeConstraint.Parent = header

		local uIStroke = Instance.new("UIStroke")
		uIStroke.Name = "UIStroke"
		uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke.Color = Color3.fromRGB(255, 255, 255)
		uIStroke.Thickness = 3
		uIStroke.Transparency = 0.2
		uIStroke.Parent = header

		local uICorner = Instance.new("UICorner")
		uICorner.Name = "UICorner"
		uICorner.CornerRadius = UDim.new(0.2, 0)
		uICorner.Parent = header

		header.Parent = holder

		local textHolder = Instance.new("Frame")
		textHolder.Name = "TextHolder"
		textHolder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		textHolder.BackgroundTransparency = 1
		textHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
		textHolder.BorderSizePixel = 0
		textHolder.LayoutOrder = 2
		textHolder.Size = UDim2.fromScale(1, 0.75)

		local uIStroke1 = Instance.new("UIStroke")
		uIStroke1.Name = "UIStroke"
		uIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		uIStroke1.Color = Color3.fromRGB(255, 255, 255)
		uIStroke1.Thickness = 3
		uIStroke1.Transparency = 0.2
		uIStroke1.Parent = textHolder

		local uICorner1 = Instance.new("UICorner")
		uICorner1.Name = "UICorner"
		uICorner1.CornerRadius = UDim.new(0.1, 0)
		uICorner1.Parent = textHolder

		local uIPadding1 = Instance.new("UIPadding")
		uIPadding1.Name = "UIPadding"
		uIPadding1.PaddingBottom = UDim.new(0.01, 5)
		uIPadding1.PaddingLeft = UDim.new(0.05, 5)
		uIPadding1.PaddingRight = UDim.new(0.05, 5)
		uIPadding1.PaddingTop = UDim.new(0.01, 5)
		uIPadding1.Parent = textHolder

		local text = Instance.new("TextLabel")
		text.Name = "Text"
		text.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		text.BackgroundTransparency = 1
		text.BorderColor3 = Color3.fromRGB(0, 0, 0)
		text.BorderSizePixel = 0
		text.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
		text.Size = UDim2.fromScale(1, 1)
		text.Text = props.controls.Task or ""
		text.TextColor3 = Color3.fromRGB(255, 255, 255)
		text.TextSize = 20
		text.TextWrapped = true
		text.TextScaled = true
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.TextYAlignment = Enum.TextYAlignment.Top
		text.Parent = textHolder

		local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
		uITextSizeConstraint.Name = "UITextSizeConstraint"
		uITextSizeConstraint.MaxTextSize = 30
		uITextSizeConstraint.MinTextSize = 5
		uITextSizeConstraint.Parent = text

		textHolder.Parent = holder

		local controlInfo = Instance.new("TextLabel")
		controlInfo.Name = "ControlInfo"
		controlInfo.AnchorPoint = Vector2.new(1, 0)
		controlInfo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		controlInfo.BackgroundTransparency = 1
		controlInfo.BorderColor3 = Color3.fromRGB(0, 0, 0)
		controlInfo.BorderSizePixel = 0
		controlInfo.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
		controlInfo.LayoutOrder = 3
		controlInfo.Position = UDim2.fromScale(1, 0.78)
		controlInfo.Size = UDim2.new(1, 0, 0.05, 7)
		controlInfo.TextColor3 = Color3.fromRGB(255, 255, 255)
		controlInfo.TextScaled = true
		controlInfo.TextSize = 16
		controlInfo.TextWrapped = true
		controlInfo.Parent = holder

		holder.Parent = mainScreen

		--inventory
		local holder1 = Instance.new("CanvasGroup")
		holder1.Name = "Holder"
		holder1.AnchorPoint = Vector2.new(0, 0.5)
		holder1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		holder1.BackgroundTransparency = 1
		holder1.BorderColor3 = Color3.fromRGB(0, 0, 0)
		holder1.BorderSizePixel = 0
		holder1.Position = UDim2.fromScale(0, 0.5)
		holder1.Size = UDim2.new(0.1, 20, 0.95, 0)
		holder1.ZIndex = 0

		local uIListLayout = Instance.new("UIListLayout")
		uIListLayout.Name = "UIListLayout"
		uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		uIListLayout.Padding = UDim.new(0.01, 5)
		uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		uIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		uIListLayout.Parent = holder1

		local uIPadding = Instance.new("UIPadding")
		uIPadding.Name = "UIPadding"
		uIPadding.PaddingBottom = UDim.new(0.01, 5)
		uIPadding.Parent = holder1
		holder1.Parent = mainScreen

		function SlotNew(txtname)
			local item = Instance.new("Frame")
			item.Name = "Item"
			item.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			item.BackgroundTransparency = 1
			item.BorderColor3 = Color3.fromRGB(0, 0, 0)
			item.BorderSizePixel = 0
			item.Size = UDim2.fromScale(1, 0.8)
			item.SizeConstraint = Enum.SizeConstraint.RelativeXX

			local viewer = Instance.new("ViewportFrame")
			viewer.Name = "Viewer"
			viewer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			viewer.BackgroundTransparency = 1
			viewer.BorderColor3 = Color3.fromRGB(0, 0, 0)
			viewer.BorderSizePixel = 0
			viewer.LayoutOrder = 1
			viewer.Size = UDim2.fromScale(0.55, 0.55)
			viewer.SizeConstraint = Enum.SizeConstraint.RelativeXX

			local uIStroke = Instance.new("UIStroke")
			uIStroke.Name = "UIStroke"
			uIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			uIStroke.Color = Color3.fromRGB(255, 255, 255)
			uIStroke.Thickness = 2
			uIStroke.Transparency = 0.2
			uIStroke.Parent = viewer

			local uICorner = Instance.new("UICorner")
			uICorner.Name = "UICorner"
			uICorner.CornerRadius = UDim.new(0.1, 0)
			uICorner.Parent = viewer

			viewer.Parent = item

			local uIListLayout = Instance.new("UIListLayout")
			uIListLayout.Name = "UIListLayout"
			uIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			uIListLayout.Padding = UDim.new(0.01, 5)
			uIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uIListLayout.Parent = item

			local name = Instance.new("TextLabel")
			name.Name = "Name"
			name.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			name.BackgroundTransparency = 1
			name.BorderColor3 = Color3.fromRGB(0, 0, 0)
			name.BorderSizePixel = 0
			name.FontFace = Font.new("rbxasset://fonts/families/PressStart2P.json")
			name.LayoutOrder = 2
			name.Text = txtname or ""
			name.Size = UDim2.new(1, 0, 0.12, 5)
			name.TextColor3 = Color3.fromRGB(255, 255, 255)
			name.TextScaled = true
			name.TextSize = 17
			name.TextWrapped = true

			local uITextSizeConstraint = Instance.new("UITextSizeConstraint")
			uITextSizeConstraint.Name = "UITextSizeConstraint"
			uITextSizeConstraint.MaxTextSize = 30
			uITextSizeConstraint.MinTextSize = 5
			uITextSizeConstraint.Parent = name

			name.Parent = item

			return item
		end

		local function giveItems(amount)
			for _, inst in pairs(holder1:GetChildren()) do
				if not inst:IsA("Frame") then
					continue
				end
				inst:Destroy()
			end

			for i = 1, amount or 6 do
				local item1 = SlotNew("Item" .. i)
				item1.Parent = holder1
			end
		end
		giveItems(props.controls.Items)

		mainScreen.Parent = props.target
		local _unsubscribe = props.subscribe(function(values, infos) -- //
			local info = infos.Visible -- This will be a GenericInfo<boolean>
			if info.__new ~= info.__old then
				background.Visible = info.__new
			end

			local _time = infos.Time
			if _time.__new ~= _time.__old then
				updateClock(_time.__new)
			end

			local _stamina = infos.Stamina
			if _stamina.__new ~= _stamina.__old then
				amount.Size = UDim2.fromScale(_stamina.__new, 1)
			end

			local items = infos.Items
			if items.__new ~= items.__old then
				giveItems(items.__new)
			end

			local task = infos.Task
			if task.__new ~= task.__old then
				text.Text = task.__new
			end
		end)

		return function()
			mainScreen:Destroy()
		end
	end,
}

return story
