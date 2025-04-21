-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source.lua"))()

-- Create the base UI window
local Window = Rayfield:CreateWindow({
	Name = "Glass UI Sample",
	LoadingTitle = "Welcome to Glass UI",
	LoadingSubtitle = "Styled with ✨ aesthetic",
	ConfigurationSaving = {
		Enabled = false
	},
	KeySystem = false
})

-- Restyle to make it *not look like Rayfield*
local function restyleRayfield()
	for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
		if v:IsA("Frame") or v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
			v.BackgroundColor3 = Color3.fromRGB(240, 220, 255) -- soft pastel
			v.BackgroundTransparency = 0.2
			v.BorderSizePixel = 0

			if not v:FindFirstChildOfClass("UICorner") then
				local corner = Instance.new("UICorner")
				corner.CornerRadius = UDim.new(0, 12)
				corner.Parent = v
			end
		end
		if v:IsA("UIStroke") then
			v.Color = Color3.fromRGB(255, 174, 255)
			v.Thickness = 1.4
		end
	end
end

-- Delay to let Rayfield finish loading before applying the style
task.delay(1, restyleRayfield)

-- Create tabs + elements
local MainTab = Window:CreateTab("Main", 4483362458) -- Icon ID is optional

MainTab:CreateToggle({
	Name = "Enable Feature",
	CurrentValue = false,
	Callback = function(Value)
		print("Toggle is now", Value)
	end,
})

MainTab:CreateSlider({
	Name = "Adjust Power",
	Range = {1, 100},
	Increment = 1,
	Suffix = "%",
	CurrentValue = 50,
	Callback = function(Value)
		print("Slider set to", Value)
	end,
})

MainTab:CreateButton({
	Name = "Click Me",
	Callback = function()
		Rayfield:Notify({
			Title = "Hello!",
			Content = "You clicked the button.",
			Duration = 3
		})
	end,
})
