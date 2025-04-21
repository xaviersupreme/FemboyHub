-- FemboyHub (Single File Version)
-- Supports: Aimbot, ESP, Visuals, Movement, Combat, Camera, Settings
-- Paste this into loadstring(game:HttpGet("your_raw_url_here"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // Theme
local Theme = {
    GlassColor = Color3.fromRGB(232, 230, 255),
    GlassDecor = Color3.fromRGB(255, 239, 255),
    AccentPink = Color3.fromRGB(244, 189, 255),
    AccentBlue = Color3.fromRGB(190, 225, 255),
    AccentWhite = Color3.fromRGB(235, 235, 240),
    MonoChrome = Color3.fromRGB(215, 215, 215),
    Neon = Color3.fromRGB(255, 174, 255),
    GlassTransparency = 0.22,
}

local function ApplyUICorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = instance
end

local function ApplyOutline(instance, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Theme.Neon
    stroke.Thickness = 2
    stroke.Parent = instance
end

-- // Drag w/ Inertia
local function EnableDrag(frame)
    local dragging = false
    local dragStart, startPos, velocity = nil, nil, Vector2.zero

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            velocity = velocity:Lerp(delta, 0.25)
            frame.Position = startPos + UDim2.new(0, velocity.X, 0, velocity.Y)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not dragging then
            velocity *= 0.85
            frame.Position += UDim2.new(0, velocity.X, 0, velocity.Y)
        end
    end)
end

-- // UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.Name = "FemboyHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 600, 0, 400)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.GlassColor
MainFrame.BackgroundTransparency = Theme.GlassTransparency
ApplyUICorner(MainFrame, 12)
ApplyOutline(MainFrame)

EnableDrag(MainFrame)

-- Tab bar (top)
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, 0, 0, 40)
TabBar.BackgroundColor3 = Theme.AccentPink
ApplyUICorner(TabBar, 8)

-- Content holder
local ContentFrame = Instance.new("Frame", MainFrame)
ContentFrame.Position = UDim2.new(0, 0, 0, 40)
ContentFrame.Size = UDim2.new(1, 0, 1, -40)
ContentFrame.BackgroundTransparency = 1

local Tabs = {}
local function CreateTab(name)
    local button = Instance.new("TextButton", TabBar)
    button.Text = name
    button.Size = UDim2.new(0, 80, 1, 0)
    button.BackgroundColor3 = Theme.MonoChrome
    button.TextColor3 = Theme.Neon
    ApplyUICorner(button, 6)

    local tabContent = Instance.new("Frame", ContentFrame)
    tabContent.Name = name
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false

    button.MouseButton1Click:Connect(function()
        for _, t in pairs(ContentFrame:GetChildren()) do
            if t:IsA("Frame") then t.Visible = false end
        end
        tabContent.Visible = true
    end)

    Tabs[name] = tabContent
    return tabContent
end

-- Create Tabs
local tabNames = { "Aimbot", "ESP", "Visuals", "Movement", "Combat", "Camera", "Settings" }
for i, name in ipairs(tabNames) do
    local tab = CreateTab(name)
    local btn = TabBar:GetChildren()[i + 1] -- skip UI corner
    btn.Position = UDim2.new(0, (i - 1) * 90, 0, 0)
end

-- // Aimbot
do
    local holding = false
    local tab = Tabs["Aimbot"]
    if tab then
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Q then holding = true end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Q then holding = false end
        end)

        RunService.RenderStepped:Connect(function()
            if holding then
                local closest, dist = nil, math.huge
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                        if onScreen then
                            local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if mag < dist then
                                closest, dist = p, mag
                            end
                        end
                    end
                end
                if closest then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Character.HumanoidRootPart.Position)
                end
            end
        end)
    end
end

-- // ESP
do
    local Drawing = Drawing or getgenv().Drawing
    local tab = Tabs["ESP"]
    if tab then
        local toggle = Instance.new("TextButton", tab)
        toggle.Text = "ESP: OFF"
        toggle.Size = UDim2.new(0, 120, 0, 30)
        toggle.Position = UDim2.new(0, 10, 0, 10)
        toggle.BackgroundColor3 = Theme.AccentWhite
        toggle.TextColor3 = Color3.new(0, 0.7, 0)
        ApplyUICorner(toggle, 6)

        local enabled = false
        toggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            toggle.Text = enabled and "ESP: ON" or "ESP: OFF"
        end)

        RunService.RenderStepped:Connect(function()
            if enabled then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local screenPos, visible = workspace.CurrentCamera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                        if visible then
                            local text = Drawing.new("Text")
                            text.Text = p.Name
                            text.Position = Vector2.new(screenPos.X, screenPos.Y)
                            text.Size = 14
                            text.Center = true
                            text.Outline = true
                            text.Visible = true
                            task.delay(0.02, function() text:Remove() end)
                        end
                    end
                end
            end
        end)
    end
end

-- // Visuals
do
    local tab = Tabs["Visuals"]
    if tab then
        local toggle = Instance.new("TextButton", tab)
        toggle.Text = "Fullbright: OFF"
        toggle.Size = UDim2.new(0, 140, 0, 30)
        toggle.Position = UDim2.new(0, 10, 0, 10)
        toggle.BackgroundColor3 = Theme.AccentWhite
        toggle.TextColor3 = Theme.AccentPink
        ApplyUICorner(toggle, 6)

        local fullbright = false
        local oldLighting = {}

        toggle.MouseButton1Click:Connect(function()
            fullbright = not fullbright
            toggle.Text = fullbright and "Fullbright: ON" or "Fullbright: OFF"

            local lighting = game:GetService("Lighting")
            if fullbright then
                oldLighting.Ambient = lighting.Ambient
                oldLighting.Brightness = lighting.Brightness
                oldLighting.ClockTime = lighting.ClockTime
                oldLighting.FogEnd = lighting.FogEnd

                lighting.Ambient = Color3.new(1, 1, 1)
                lighting.Brightness = 3
                lighting.ClockTime = 14
                lighting.FogEnd = 100000
            else
                for prop, val in pairs(oldLighting) do
                    lighting[prop] = val
                end
            end
        end)
    end
end

-- // Movement
do
    local tab = Tabs["Movement"]
    if tab then
        local flyToggle = Instance.new("TextButton", tab)
        flyToggle.Text = "Fly: OFF"
        flyToggle.Size = UDim2.new(0, 120, 0, 30)
        flyToggle.Position = UDim2.new(0, 10, 0, 10)
        flyToggle.BackgroundColor3 = Theme.AccentWhite
        flyToggle.TextColor3 = Theme.AccentBlue
        ApplyUICorner(flyToggle, 6)

        local flying = false
        local vel = nil

        flyToggle.MouseButton1Click:Connect(function()
            flying = not flying
            flyToggle.Text = flying and "Fly: ON" or "Fly: OFF"

            if flying then
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    vel = Instance.new("BodyVelocity", hrp)
                    vel.MaxForce = Vector3.new(1, 1, 1) * 1e5
                    vel.Velocity = Vector3.zero
                end
            else
                if vel then
                    vel:Destroy()
                    vel = nil
                end
            end
        end)

        RunService.RenderStepped:Connect(function()
            if flying and vel then
                local cam = workspace.CurrentCamera
                vel.Velocity = cam.CFrame.LookVector * 100
            end
        end)
    end
end

-- // Combat (Triggerbot)
do
    local tab = Tabs["Combat"]
    if tab then
        local triggerToggle = Instance.new("TextButton", tab)
        triggerToggle.Text = "Triggerbot: OFF"
        triggerToggle.Size = UDim2.new(0, 150, 0, 30)
        triggerToggle.Position = UDim2.new(0, 10, 0, 10)
        triggerToggle.BackgroundColor3 = Theme.AccentWhite
        triggerToggle.TextColor3 = Theme.AccentPink
        ApplyUICorner(triggerToggle, 6)

        local enabled = false
        triggerToggle.MouseButton1Click:Connect(function()
            enabled = not enabled
            triggerToggle.Text = enabled and "Triggerbot: ON" or "Triggerbot: OFF"
        end)

        RunService.RenderStepped:Connect(function()
            if enabled then
                local target = Mouse.Target
                if target and target.Parent and target.Parent:FindFirstChild("Humanoid") then
                    mouse1click()
                end
            end
        end)
    end
end

-- // Camera (FOV Changer)
do
    local tab = Tabs["Camera"]
    if tab then
        local fovButton = Instance.new("TextButton", tab)
        fovButton.Text = "FOV: 70"
        fovButton.Size = UDim2.new(0, 120, 0, 30)
        fovButton.Position = UDim2.new(0, 10, 0, 10)
        fovButton.BackgroundColor3 = Theme.AccentWhite
        fovButton.TextColor3 = Theme.AccentBlue
        ApplyUICorner(fovButton, 6)

        local fov = 70
        fovButton.MouseButton1Click:Connect(function()
            fov = (fov >= 120) and 70 or fov + 10
            workspace.CurrentCamera.FieldOfView = fov
            fovButton.Text = "FOV: " .. fov
        end)
    end
end

-- // Settings
do
    local tab = Tabs["Settings"]
    if tab then
        local unloadButton = Instance.new("TextButton", tab)
        unloadButton.Text = "Unload Hub"
        unloadButton.Size = UDim2.new(0, 140, 0, 30)
        unloadButton.Position = UDim2.new(0, 10, 0, 10)
        unloadButton.BackgroundColor3 = Theme.AccentWhite
        unloadButton.TextColor3 = Color3.new(1, 0, 0)
        ApplyUICorner(unloadButton, 6)

        unloadButton.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)
    end
end
