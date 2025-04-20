local Combat = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

function GetClosestToCrosshair()
    local closest, dist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = game:GetService("UserInputService"):GetMouseLocation()
                local magnitude = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if magnitude < dist then
                    closest = player
                    dist = magnitude
                end
            end
        end
    end
    return closest
end

function Combat:Init(ui)
    local tab = ui.Content["Combat"]
    if not tab then return end

    local triggerbotEnabled = false

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 180, 0, 30)
    button.Position = UDim2.new(0, 10, 0, 10)
    button.Text = "Triggerbot: OFF"
    button.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    button.Parent = tab

    button.MouseButton1Click:Connect(function()
        triggerbotEnabled = not triggerbotEnabled
        button.Text = triggerbotEnabled and "Triggerbot: ON" or "Triggerbot: OFF"
    end)

    RunService.RenderStepped:Connect(function()
        if triggerbotEnabled then
            local target = GetClosestToCrosshair()
            if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                mouse1click()
            end
        end
    end)
end

return Combat
