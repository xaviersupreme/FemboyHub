local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Rayfield/main/source.lua"))()

local Window = Rayfield:CreateWindow({
	Name = "Aurora Hub",
	LoadingTitle = "Aurora is loading...",
	LoadingSubtitle = "Smooth. Soft. Clean.",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "AuroraHub",
		FileName = "Config"
	},
	Discord = {
		Enabled = false,
	},
	KeySystem = false
})

-- Notification
Rayfield:Notify({
	Title = "Aurora Hub",
	Content = "UI successfully loaded with custom theme.",
	Duration = 4,
	Actions = {}
})

-- Tabs
local MainTab = Window:CreateTab("Home", 4483362458) -- replace with your own icon asset if needed

-- Button
MainTab:CreateButton({
	Name = "Click Me",
	Callback = function()
		Rayfield:Notify({
			Title = "Button Clicked",
			Content = "You clicked the custom pastel button.",
			Duration = 3
		})
	end
})

-- Toggle
MainTab:CreateToggle({
	Name = "Custom Toggle",
	CurrentValue = false,
	Callback = function(Value)
		print("Toggle:", Value)
	end,
})

-- Slider
MainTab:CreateSlider({
	Name = "Smooth Slider",
	Range = {0, 100},
	Increment = 5,
	Suffix = "%",
	CurrentValue = 50,
	Callback = function(Value)
		print("Slider Value:", Value)
	end,
})
