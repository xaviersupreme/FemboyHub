local ESP = {}
local Drawing = Drawing or getgenv().Drawing

function ESP:Init(ui)
    local tab = ui.Content["ESP"]
    if not tab then return end

    local enabled = false
    local function DrawESP()
        for _, player in pairs(game:GetService("Players"):GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local espText = Drawing.new("Text")
                espText.Text = player.Name
                espText.Size = 14
                espText.Center = true
                espText.Outline = true
                espText.Color = Color3.new(1, 1, 1)
                espText.Visible = true
                game:GetService("RunService").RenderStepped:Connect(function()
                    local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                    espText.Position = Vector2.new(screenPos.X, screenPos.Y)
                    espText.Visible = visible and enabled
                end)
            end
        end
    end

    local toggle = Instance.new("TextButton")
    toggle.Text = "Toggle ESP"
    toggle.Size = UDim2.new(0, 180, 0, 30)
    toggle.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
    toggle.TextColor3 = Color3.fromRGB(0, 200, 100)
    toggle.Parent = tab

    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        toggle.Text = enabled and "ESP: ON" or "ESP: OFF"
        DrawESP()
    end)
end

return ESP
