local Theme = require(script.Parent.theme)

local UI = {}
UI.__index = UI

function UI:CreateMainFrame(theme)
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "GlassHub"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = game:GetService("CoreGui")

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 650, 0, 420)
	MainFrame.Position = UDim2.new(0.5, -325, 0.5, -210)
	MainFrame.BackgroundColor3 = theme.GlassColor
	MainFrame.BackgroundTransparency = theme.GlassTransparency
	MainFrame.Parent = ScreenGui

	Theme:ApplyUICorner(MainFrame)
	Theme:ApplyOutline(MainFrame, theme.Neon)

	-- Header
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundColor3 = theme.AccentPink
	Theme:ApplyUICorner(Header)
	Header.Parent = MainFrame

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.BackgroundTransparency = 1
	Title.Text = "GlassHub"
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 24
	Title.TextColor3 = theme.MonoChrome
	Title.Parent = Header

	-- Tab bar
	local TabBar = Instance.new("Frame")
	TabBar.Name = "TabBar"
	TabBar.Position = UDim2.new(0, 0, 0, 50)
	TabBar.Size = UDim2.new(1, 0, 0, 40)
	TabBar.BackgroundTransparency = 1
	TabBar.Parent = MainFrame

	-- Content container
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Position = UDim2.new(0, 0, 0, 90)
	Content.Size = UDim2.new(1, 0, 1, -90)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = MainFrame

	return {
		MainFrame = MainFrame,
		Header = Header,
		TabBar = TabBar,
		Content = Content,
		Tabs = {}
	}
end

function UI:CreateTab(ui, name)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, 90, 1, 0)
	button.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
	button.Text = name
	button.Font = Enum.Font.Gotham
	button.TextColor3 = Color3.fromRGB(100, 100, 255)
	button.TextSize = 16
	button.Parent = ui.TabBar

	local tabFrame = Instance.new("Frame")
	tabFrame.Name = name
	tabFrame.Size = UDim2.new(1, 0, 1, 0)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Visible = false
	tabFrame.Parent = ui.Content

	ui.Tabs[name] = tabFrame

	button.MouseButton1Click:Connect(function()
		for _, tab in pairs(ui.Tabs) do tab.Visible = false end
		tabFrame.Visible = true
	end)

	return tabFrame
end

function UI:CreateToggle(parent, label, callback)
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 180, 0, 32)
	toggle.BackgroundColor3 = Theme.AccentWhite
	toggle.TextColor3 = Theme.AccentBlue
	toggle.Text = label .. ": OFF"
	toggle.Font = Enum.Font.Gotham
	toggle.TextSize = 16
	toggle.Parent = parent

	local state = false
	toggle.MouseButton1Click:Connect(function()
		state = not state
		toggle.Text = label .. ": " .. (state and "ON" or "OFF")
		toggle.TextColor3 = state and Color3.fromRGB(0, 200, 100) or Theme.AccentBlue
		callback(state)
	end)
end

return UI
