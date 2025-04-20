local Aimbot = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

function GetClosestPlayer()
    local closest, distance = nil, math.huge
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local screenPoint, onScreen = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < distance then
                    closest, distance = player, dist
                end
            end
        end
    end
    return closest
end

function Aimbot:Init(ui)
    local tab = ui.Content["Aimbot"]
    if not tab then return end

    local holding = false
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Q then holding = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Q then holding = false end
    end)

    RunService.RenderStepped:Connect(function()
        if holding then
            local target = GetClosestPlayer()
            if target and target.Character then
                workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Character.HumanoidRootPart.Position)
            end
        end
    end)
end

return Aimbot
