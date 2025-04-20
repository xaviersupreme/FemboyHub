local Movement = {}
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

function Movement:Init(ui)
    local tab = ui.Content["Movement"]
    if not tab then return end

    local flyEnabled = false
    local flySpeed = 2

    local function Fly()
        local char = LP.Character
        if not char then return end
        local hrp = char:WaitForChild("HumanoidRootPart")

        local bodyGyro = Instance.new("BodyGyro", hrp)
        bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.P = 100000

        local bodyVel = Instance.new("BodyVelocity", hrp)
        bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        RunService.RenderStepped:Connect(function()
            if flyEnabled then
                bodyGyro.CFrame = workspace.CurrentCamera.CFrame
                bodyVel.Velocity = workspace.CurrentCamera.CFrame.LookVector * flySpeed
            else
                bodyGyro:Destroy()
                bodyVel:Destroy()
            end
        end)
    end

    local toggle = Instance.new("TextButton")
    toggle.Text = "Toggle Fly"
    toggle.Size = UDim2.new(0, 180, 0, 30)
    toggle.Position = UDim2.new(0, 10, 0, 10)
    toggle.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
    toggle.Parent = tab

    toggle.MouseButton1Click:Connect(function()
        flyEnabled = not flyEnabled
        if flyEnabled then
            Fly()
        end
    end)
end

return Movement
