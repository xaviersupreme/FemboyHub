local Camera = {}

function Camera:Init(ui)
    local tab = ui.Content["Camera"]
    if not tab then return end

    local fovSlider = Instance.new("TextButton")
    fovSlider.Text = "Toggle Wide FOV"
    fovSlider.Size = UDim2.new(0, 180, 0, 30)
    fovSlider.Position = UDim2.new(0, 10, 0, 10)
    fovSlider.BackgroundColor3 = Color3.fromRGB(180, 180, 255)
    fovSlider.Parent = tab

    local wide = false
    fovSlider.MouseButton1Click:Connect(function()
        wide = not wide
        workspace.CurrentCamera.FieldOfView = wide and 100 or 70
        fovSlider.Text = wide and "FOV: 100" or "FOV: 70"
    end)
end

return Camera
