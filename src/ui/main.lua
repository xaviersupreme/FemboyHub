local Theme = require(script.Parent.theme)
local DragUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("src").utils.drag)

local MainUI = {}

function MainUI:CreateMainFrame(theme)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlassOrcaUI"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 600, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = theme.GlassColor
    mainFrame.BackgroundTransparency = theme.GlassTransparency
    mainFrame.Parent = screenGui

    Theme:ApplyUICorner(mainFrame, 14)
    Theme:ApplyOutline(mainFrame, theme.Neon)
    DragUtil:EnableDrag(mainFrame)

    -- Glass Overlay
    local decor = Instance.new("Frame")
    decor.Name = "GlassDecor"
    decor.Size = UDim2.new(1, -20, 1, -20)
    decor.Position = UDim2.new(0, 10, 0, 10)
    decor.BackgroundColor3 = theme.GlassDecor
    decor.BackgroundTransparency = theme.GlassTransparency + 0.1
    decor.Parent = mainFrame
    Theme:ApplyUICorner(decor, 14)

    -- Header
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundColor3 = theme.AccentPink
    header.TextColor3 = theme.MonoChrome
    header.Text = "Glass Orca Fork"
    header.Font = Enum.Font.GothamMedium
    header.TextSize = 20
    header.Parent = mainFrame
    Theme:ApplyUICorner(header, 12)

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.Size = UDim2.new(1, 0, 0, 35)
    tabBar.Position = UDim2.new(0, 0, 0, 40)
    tabBar.BackgroundTransparency = 1
    tabBar.Parent = mainFrame

    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -90)
    content.Position = UDim2.new(0, 10, 0, 85)
    content.BackgroundTransparency = 1
    content.Parent = mainFrame

    local tabButtons = {}
    local contentFrames = {}

    local tabNames = { "Aimbot", "ESP", "Visuals", "Movement", "Combat", "Camera", "Settings" }
    local spacing = 10
    local btnWidth = (600 - ((#tabNames + 1) * spacing)) / #tabNames

    for i, name in ipairs(tabNames) do
        local tabBtn = Instance.new("TextButton")
        tabBtn.Name = name .. "Tab"
        tabBtn.Text = name
        tabBtn.Size = UDim2.new(0, btnWidth, 0, 30)
        tabBtn.Position = UDim2.new(0, spacing + (i - 1) * (btnWidth + spacing), 0, 0)
        tabBtn.BackgroundColor3 = theme.AccentWhite
        tabBtn.TextColor3 = theme.AccentBlue
        tabBtn.Font = Enum.Font.GothamSemibold
        tabBtn.TextSize = 14
        tabBtn.Parent = tabBar
        Theme:ApplyUICorner(tabBtn, 8)

        local tabContent = Instance.new("Frame")
        tabContent.Name = name
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.Visible = i == 1
        tabContent.Parent = content

        tabBtn.MouseButton1Click:Connect(function()
            for _, frame in pairs(content:GetChildren()) do
                frame.Visible = false
            end
            tabContent.Visible = true
        end)

        tabButtons[name] = tabBtn
        contentFrames[name] = tabContent
    end

    return {
        Screen = screenGui,
        MainFrame = mainFrame,
        Content = contentFrames,
        Tabs = tabButtons,
    }
end

return MainUI
