local Visuals = {}

function Visuals:Init(ui)
    local tab = ui.Content["Visuals"]
    if not tab then return end

    local label = Instance.new("TextLabel")
    label.Text = "Visual stuff coming soon!"
    label.Size = UDim2.new(1, 0, 0, 30)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Parent = tab
end

return Visuals
