local Settings = {}

function Settings:Init(ui)
    local tab = ui.Content["Settings"]
    if not tab then return end

    local credits = Instance.new("TextLabel")
    credits.Size = UDim2.new(1, -20, 0, 40)
    credits.Position = UDim2.new(0, 10, 0, 10)
    credits.BackgroundTransparency = 1
    credits.TextColor3 = Color3.fromRGB(150, 150, 150)
    credits.Text = "made with HATE by xavier <3"
    credits.TextScaled = true
    credits.Parent = tab
end

return Settings
