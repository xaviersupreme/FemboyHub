--// Main Glass UI - Rayfield-inspired, One File Version
local Tabs = { "Aimbot", "ESP", "Visuals", "Movement", "Combat", "Camera", "Settings" }

-- Theme settings
local Theme = {
    GlassColor        = Color3.fromRGB(232, 230, 255),
    GlassDecor        = Color3.fromRGB(255, 239, 255),
    AccentPink        = Color3.fromRGB(244, 189, 255),
    AccentBlue        = Color3.fromRGB(190, 225, 255),
    AccentWhite       = Color3.fromRGB(235, 235, 240),
    MonoChrome        = Color3.fromRGB(215, 215, 215),
    Neon              = Color3.fromRGB(255, 174, 255),
    GlassTransparency = 0.22,
    Font              = Enum.Font.Gotham,
    CornerRadius      = UDim.new(0, 12)
}

-- Utility functions
local function ApplyUICorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerRadius
    corner.Parent = instance
end

local function ApplyOutline(instance, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Neon
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = instance
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GlassUI"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = game:GetService("CoreGui") end)

-- Create Main Frame
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 600, 0, 400)
main.Position = UDim2.new(0.5, -300, 0.5, -200)
main.BackgroundColor3 = Theme.GlassColor
main.BackgroundTransparency = Theme.GlassTransparency
main.Name = "Main"
main.Parent = screenGui
ApplyUICorner(main)
ApplyOutline(main)

-- Create Tab Bar
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 40)
tabBar.BackgroundColor3 = Theme.AccentWhite
tabBar.Parent = main
ApplyUICorner(tabBar, UDim.new(0, 8))

-- Create Content Holder
local tabHolder = Instance.new("Frame")
tabHolder.Position = UDim2.new(0, 0, 0, 40)
tabHolder.Size = UDim2.new(1, 0, 1, -40)
tabHolder.BackgroundTransparency = 1
tabHolder.Name = "Content"
tabHolder.Parent = main

local uiContent = {}

-- Tab Switch Logic
local function switchTab(tabName)
    for name, tab in pairs(uiContent) do
        tab.Visible = (name == tabName)
    end
end

-- Create Tabs
for i, tabName in ipairs(Tabs) do
    local button = Instance.new("TextButton")
    button.Text = tabName
    button.Size = UDim2.new(0, 80, 1, 0)
    button.Position = UDim2.new(0, (i - 1) * 85, 0, 0)
    button.BackgroundColor3 = Theme.AccentBlue
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Theme.Font
    button.TextSize = 14
    button.Parent = tabBar
    ApplyUICorner(button, UDim.new(0, 6))

    local content = Instance.new("Frame")
    content.Name = tabName
    content.Size = UDim2.new(1, 0, 1, 0)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.Parent = tabHolder

    uiContent[tabName] = content

    button.MouseButton1Click:Connect(function()
        switchTab(tabName)
    end)
end

switchTab("Aimbot") -- default selected
