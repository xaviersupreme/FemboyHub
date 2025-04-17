local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- ==== COLOR PALETTE ====
local GlassColor = Color3.fromRGB(232, 230, 255)
local GlassDecor = Color3.fromRGB(255, 239, 255)
local AccentPink = Color3.fromRGB(244, 189, 255)
local AccentBlue = Color3.fromRGB(190, 225, 255)
local AccentWhite = Color3.fromRGB(235, 235, 240)
local Monochrome = Color3.fromRGB(215, 215, 215)
local Neon = Color3.fromRGB(255, 174, 255)
local FemboyFaint = Color3.fromRGB(255, 210, 250)
local GlassTransparency = 0.22

-- ==== UI CONSTRUCTION ====
local gui = Instance.new("ScreenGui")
gui.Name = "FemboyHub"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = LocalPlayer.PlayerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 520, 0, 650)
main.Position = UDim2.new(0.5, -260, 0.5, -325)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = GlassColor
main.BackgroundTransparency = GlassTransparency
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 36)
mainCorner.Parent = main

local glassDecor = Instance.new("Frame")
glassDecor.Size = UDim2.new(1, 0, 1, 0)
glassDecor.BackgroundColor3 = GlassDecor
glassDecor.BackgroundTransparency = 0.94
glassDecor.BorderSizePixel = 0
glassDecor.ZIndex = 2
glassDecor.Parent = main

local glassCorner = Instance.new("UICorner")
glassCorner.CornerRadius = UDim.new(0, 36)
glassCorner.Parent = glassDecor

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 62)
header.BackgroundColor3 = AccentPink
header.BackgroundTransparency = 0.18
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 36)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Text = "Femboy Hub"
title.Font = Enum.Font.GothamBold
title.TextColor3 = AccentBlue
title.TextSize = 44
title.AnchorPoint = Vector2.new(0,0.5)
title.Position = UDim2.new(0.05,0,0.5,0)
title.Size = UDim2.new(0.7,0,1,0)
title.BackgroundTransparency = 1
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Tab bar
local tabBar = Instance.new("Frame")
tabBar.Position = UDim2.new(0, 0, 0, 62)
tabBar.Size = UDim2.new(1, 0, 0, 50)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabs = {
    "Aimbot", "ESP", "Triggerbot", "Player", "Visuals", "Settings"
}
local tabBtns, tabContents = {}, {}

for i, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Name = tabName
    btn.Text = tabName
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = (i%2==0) and AccentPink or AccentBlue
    btn.TextSize = 24
    btn.Size = UDim2.new(0, 106, 0, 40)
    btn.Position = UDim2.new(0, (i-1)*90+16, 0.5, -20)
    btn.BackgroundColor3 = Monochrome
    btn.BackgroundTransparency = 0.82
    btn.AutoButtonColor = true
    btn.ZIndex = 6
    btn.Parent = tabBar
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 24)
    btnCorner.Parent = btn
    tabBtns[tabName] = btn
end

local contentFrame = Instance.new("Frame")
contentFrame.Position = UDim2.new(0, 0, 0, 112)
contentFrame.Size = UDim2.new(1, 0, 1, -112)
contentFrame.BackgroundTransparency = 1
contentFrame.ClipsDescendants = true
contentFrame.Parent = main

-- ==== SMOOTH DRAG & INERTIA (nerd stuff)  ====
local dragging, dragInput, dragStart, startPos
local velocity = Vector2.new(0,0)
local lastUpdate = tick()
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        velocity = Vector2.new(0,0)
        lastUpdate = tick()
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
header.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local dt = math.max(tick() - lastUpdate, 0.01)
        velocity = velocity:Lerp(Vector2.new(delta.X/dt, delta.Y/dt), 0.2)
        main.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
        lastUpdate = tick()
    end
end)
RunService.RenderStepped:Connect(function(dt)
    if not dragging and (math.abs(velocity.X) > 1 or math.abs(velocity.Y) > 1) then
        main.Position = main.Position + UDim2.new(0, velocity.X * dt, 0, velocity.Y * dt)
        velocity = velocity * 0.85
    end
end)

-- ==== ANIMATED OPENING ====
main.Position = UDim2.new(0.5, -260, 1, 0)
main.Size = UDim2.new(0, 520, 0, 0)
TweenService:Create(main, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -260, 0.5, -325),
    Size = UDim2.new(0, 520, 0, 650),
}):Play()

-- ==== TAB SYSTEM HANDLING ====
local function clearTabs()
    for _, v in ipairs(contentFrame:GetChildren()) do
        if v:IsA("Frame") then v.Visible = false end
    end
end
local function showTab(tab)
    clearTabs()
    if tabContents[tab] then tabContents[tab].Visible = true end
end
for name, btn in pairs(tabBtns) do
    btn.MouseButton1Click:Connect(function()
        for _, b in pairs(tabBtns) do b.BackgroundTransparency = 0.82 end
        btn.BackgroundTransparency = 0.38
        showTab(name)
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundTransparency=0.22}):Play()
    end)
    btn.MouseLeave:Connect(function()
        if not btn.Visible or btn.BackgroundTransparency == 0.38 then return end
        TweenService:Create(btn, TweenInfo.new(0.18), {BackgroundTransparency=0.82}):Play()
    end)
end

-- ==== ADVANCED THINGS ====
-- ========== AIMBOT ==========
local aimbotTab = Instance.new("Frame")
aimbotTab.Size = UDim2.new(1, -36, 1, -36)
aimbotTab.Position = UDim2.new(0, 18, 0, 18)
aimbotTab.BackgroundTransparency = 1
aimbotTab.Visible = false
aimbotTab.Parent = contentFrame
tabContents["Aimbot"] = aimbotTab

local aimbotEnabled, aiming, aimKey, aimFOV, aimTeamIgnore, aimSmooth = false, false, Enum.KeyCode.LeftAlt, 90, true, 0.28
local aimbotToggle = Instance.new("TextButton")
aimbotToggle.Text = "Aimbot: OFF"
aimbotToggle.Font = Enum.Font.GothamBold
aimbotToggle.TextColor3 = AccentBlue
aimbotToggle.TextSize = 24
aimbotToggle.BackgroundColor3 = AccentWhite
aimbotToggle.BackgroundTransparency = 0.5
aimbotToggle.Size = UDim2.new(0, 220, 0, 46)
aimbotToggle.Position = UDim2.new(0, 0, 0, 0)
aimbotToggle.Parent = aimbotTab
local abCorner = Instance.new("UICorner") abCorner.Parent = aimbotToggle

local aimbotInfo = Instance.new("TextLabel")
aimbotInfo.Text = "Hold ["..aimKey.Name.."] to aim at closest enemy\nFOV: "..aimFOV.." | Team Ignore: "..tostring(aimTeamIgnore)
aimbotInfo.Font = Enum.Font.Gotham
aimbotInfo.TextColor3 = AccentPink
aimbotInfo.TextSize = 18
aimbotInfo.Position = UDim2.new(0,0,0,52)
aimbotInfo.Size = UDim2.new(1,0,0,44)
aimbotInfo.BackgroundTransparency = 1
aimbotInfo.TextXAlignment = Enum.TextXAlignment.Left
aimbotInfo.TextYAlignment = Enum.TextYAlignment.Top
aimbotInfo.Parent = aimbotTab

aimbotToggle.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotToggle.Text = "Aimbot: "..(aimbotEnabled and "ON" or "OFF")
    aimbotToggle.TextColor3 = aimbotEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if aimbotEnabled and input.KeyCode == aimKey then
        aiming = true
    end
end)
UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == aimKey then
        aiming = false
    end
end)

local function getClosestPlayer()
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            if not aimTeamIgnore or player.Team ~= LocalPlayer.Team then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < aimFOV and dist < closestDist then
                        closest = player
                        closestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and aiming then
        local plr = getClosestPlayer()
        if plr and plr.Character and plr.Character:FindFirstChild("Head") then
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, plr.Character.Head.Position), aimSmooth)
        end
    end
end)

-- ========== ESP ==========
local espTab = Instance.new("Frame")
espTab.Size = UDim2.new(1, -36, 1, -36)
espTab.Position = UDim2.new(0, 18, 0, 18)
espTab.BackgroundTransparency = 1
espTab.Visible = false
espTab.Parent = contentFrame
tabContents["ESP"] = espTab

local espEnabled, espNames, espTracers = false, true, true
local espToggle = Instance.new("TextButton")
espToggle.Text = "ESP: OFF"
espToggle.Font = Enum.Font.GothamBold
espToggle.TextColor3 = AccentPink
espToggle.TextSize = 24
espToggle.BackgroundColor3 = AccentWhite
espToggle.BackgroundTransparency = 0.5
espToggle.Size = UDim2.new(0, 180, 0, 46)
espToggle.Position = UDim2.new(0, 0, 0, 0)
espToggle.Parent = espTab
local espCorner = Instance.new("UICorner") espCorner.Parent = espToggle

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = "ESP: "..(espEnabled and "ON" or "OFF")
    espToggle.TextColor3 = espEnabled and Color3.fromRGB(127,255,127) or AccentPink
end)

-- ========== TRIGGERBOT ==========
local triggerTab = Instance.new("Frame")
triggerTab.Size = UDim2.new(1, -36, 1, -36)
triggerTab.Position = UDim2.new(0, 18, 0, 18)
triggerTab.BackgroundTransparency = 1
triggerTab.Visible = false
triggerTab.Parent = contentFrame
tabContents["Triggerbot"] = triggerTab

local triggerEnabled = false
local triggerToggle = Instance.new("TextButton")
triggerToggle.Text = "Triggerbot: OFF"
triggerToggle.Font = Enum.Font.GothamBold
triggerToggle.TextColor3 = AccentBlue
triggerToggle.TextSize = 24
triggerToggle.BackgroundColor3 = AccentWhite
triggerToggle.BackgroundTransparency = 0.5
triggerToggle.Size = UDim2.new(0, 220, 0, 46)
triggerToggle.Position = UDim2.new(0, 0, 0, 0)
triggerToggle.Parent = triggerTab
local trigCorner = Instance.new("UICorner") trigCorner.Parent = triggerToggle

triggerToggle.MouseButton1Click:Connect(function()
    triggerEnabled = not triggerEnabled
    triggerToggle.Text = "Triggerbot: "..(triggerEnabled and "ON" or "OFF")
    triggerToggle.TextColor3 = triggerEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)

-- ========== PLAYER ==========
local playerTab = Instance.new("Frame")
playerTab.Size = UDim2.new(1, -36, 1, -36)
playerTab.Position = UDim2.new(0, 18, 0, 18)
playerTab.BackgroundTransparency = 1
playerTab.Visible = false
playerTab.Parent = contentFrame
tabContents["Player"] = playerTab

local flyEnabled, noclipEnabled, speedEnabled = false, false, false
local speedValue, fovValue = 60, 70

-- fly
local flyToggle = Instance.new("TextButton")
flyToggle.Text = "Fly: OFF"
flyToggle.Font = Enum.Font.GothamBold
flyToggle.TextColor3 = AccentPink
flyToggle.TextSize = 22
flyToggle.BackgroundColor3 = AccentWhite
flyToggle.BackgroundTransparency = 0.6
flyToggle.Size = UDim2.new(0, 120, 0, 40)
flyToggle.Position = UDim2.new(0, 0, 0, 0)
flyToggle.Parent = playerTab
local flyCorner = Instance.new("UICorner") flyCorner.Parent = flyToggle

-- noclip
local noclipToggle = Instance.new("TextButton")
noclipToggle.Text = "Noclip: OFF"
noclipToggle.Font = Enum.Font.GothamBold
noclipToggle.TextColor3 = AccentPink
noclipToggle.TextSize = 22
noclipToggle.BackgroundColor3 = AccentWhite
noclipToggle.BackgroundTransparency = 0.6
noclipToggle.Size = UDim2.new(0, 120, 0, 40)
noclipToggle.Position = UDim2.new(0, 140, 0, 0)
noclipToggle.Parent = playerTab
local noclipCorner = Instance.new("UICorner") noclipCorner.Parent = noclipToggle

-- speed
local speedToggle = Instance.new("TextButton")
speedToggle.Text = "Speed: OFF"
speedToggle.Font = Enum.Font.GothamBold
speedToggle.TextColor3 = AccentBlue
speedToggle.TextSize = 22
speedToggle.BackgroundColor3 = AccentWhite
speedToggle.BackgroundTransparency = 0.6
speedToggle.Size = UDim2.new(0, 120, 0, 40)
speedToggle.Position = UDim2.new(0, 280, 0, 0)
speedToggle.Parent = playerTab
local speedCorner = Instance.new("UICorner") speedCorner.Parent = speedToggle

local speedLabel = Instance.new("TextLabel")
speedLabel.Text = "WalkSpeed: "..speedValue
speedLabel.Font = Enum.Font.Gotham
speedLabel.TextColor3 = AccentBlue
speedLabel.TextSize = 18
speedLabel.Position = UDim2.new(0, 0, 0, 50)
speedLabel.Size = UDim2.new(0, 200, 0, 36)
speedLabel.BackgroundTransparency = 1
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = playerTab

local fovLabel = Instance.new("TextLabel")
fovLabel.Text = "FOV: "..fovValue
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextColor3 = AccentPink
fovLabel.TextSize = 18
fovLabel.Position = UDim2.new(0, 220, 0, 50)
fovLabel.Size = UDim2.new(0, 200, 0, 36)
fovLabel.BackgroundTransparency = 1
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = playerTab

-- FOV changer
local plusFOV = Instance.new("TextButton")
plusFOV.Text = "+"
plusFOV.Font = Enum.Font.GothamBold
plusFOV.TextColor3 = AccentPink
plusFOV.TextSize = 20
plusFOV.BackgroundColor3 = AccentWhite
plusFOV.BackgroundTransparency = 0.7
plusFOV.Size = UDim2.new(0, 36, 0, 36)
plusFOV.Position = UDim2.new(0, 420, 0, 50)
plusFOV.Parent = playerTab
local plusFOVCorner = Instance.new("UICorner") plusFOVCorner.Parent = plusFOV

local minusFOV = plusFOV:Clone()
minusFOV.Text = "-"
minusFOV.Position = UDim2.new(0, 380, 0, 50)
minusFOV.Parent = playerTab

plusFOV.MouseButton1Click:Connect(function()
    fovValue = math.clamp(fovValue+5, 30, 120)
    Camera.FieldOfView = fovValue
    fovLabel.Text = "FOV: "..fovValue
end)
minusFOV.MouseButton1Click:Connect(function()
    fovValue = math.clamp(fovValue-5, 30, 120)
    Camera.FieldOfView = fovValue
    fovLabel.Text = "FOV: "..fovValue
end)

flyToggle.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyToggle.Text = "Fly: "..(flyEnabled and "ON" or "OFF")
    flyToggle.TextColor3 = flyEnabled and Color3.fromRGB(127,255,127) or AccentPink
end)
noclipToggle.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipToggle.Text = "Noclip: "..(noclipEnabled and "ON" or "OFF")
    noclipToggle.TextColor3 = noclipEnabled and Color3.fromRGB(127,255,127) or AccentPink
end)
speedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedToggle.Text = "Speed: "..(speedEnabled and "ON" or "OFF")
    speedToggle.TextColor3 = speedEnabled and Color3.fromRGB(127,255,127) or AccentBlue
    LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and speedValue or 16
end)
speedLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        speedValue = math.clamp(speedValue + 10, 16, 200)
        speedLabel.Text = "WalkSpeed: "..speedValue
        if speedEnabled then LocalPlayer.Character.Humanoid.WalkSpeed = speedValue end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
        speedValue = math.clamp(speedValue - 10, 16, 200)
        speedLabel.Text = "WalkSpeed: "..speedValue
        if speedEnabled then LocalPlayer.Character.Humanoid.WalkSpeed = speedValue end
    end
end)

-- fly/noclip logic
local flyVelocity = Vector3.new()
RunService.RenderStepped:Connect(function()
    -- fly
    if flyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        flyVelocity = flyVelocity:Lerp(move.Unit * (speedValue or 60), 0.25)
        if move.Magnitude > 0 then
            root.Velocity = flyVelocity
        else
            root.Velocity = Vector3.new(0,0,0)
        end
        LocalPlayer.Character.Humanoid.PlatformStand = true
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.PlatformStand = false
    end
    -- noclip
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- ========== VISUALS (UI theme etc) ==========
local visualsTab = Instance.new("Frame")
visualsTab.Size = UDim2.new(1, -36, 1, -36)
visualsTab.Position = UDim2.new(0, 18, 0, 18)
visualsTab.BackgroundTransparency = 1
visualsTab.Visible = false
visualsTab.Parent = contentFrame
tabContents["Visuals"] = visualsTab

local themeLabel = Instance.new("TextLabel")
themeLabel.Text = "Glass/Femboy Theme Applied"
themeLabel.Font = Enum.Font.GothamBold
themeLabel.TextColor3 = AccentBlue
themeLabel.TextSize = 28
themeLabel.Size = UDim2.new(1, 0, 0, 40)
themeLabel.BackgroundTransparency = 1
themeLabel.Parent = visualsTab

-- ========== SETTINGS ==========
local settingsTab = Instance.new("Frame")
settingsTab.Size = UDim2.new(1, -36, 1, -36)
settingsTab.Position = UDim2.new(0, 18, 0, 18)
settingsTab.BackgroundTransparency = 1
settingsTab.Visible = false
settingsTab.Parent = contentFrame
tabContents["Settings"] = settingsTab

local settingsLabel = Instance.new("TextLabel")
settingsLabel.Text = "Femboy Hub\nby Copilot\n"
settingsLabel.Font = Enum.Font.Gotham
settingsLabel.TextColor3 = AccentBlue
settingsLabel.TextSize = 20
settingsLabel.Size = UDim2.new(1, 0, 0, 60)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Parent = settingsTab

-- ==== OPEN DEFAULT TAB ====
showTab("Aimbot")
tabBtns["Aimbot"].BackgroundTransparency = 0.38

-- ==== BASIC FUNCTIONALITY FOR ESP/TRIGGERBOT ====
-- ESP logic
local espBoxes = {}
local function clearESP()
    for _, adorn in pairs(workspace:GetChildren()) do
        if adorn.Name == "FemboyESPBox" and adorn:IsA("BoxHandleAdornment") then
            adorn:Destroy()
        end
    end
    espBoxes = {}
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then clearESP() return end
    clearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "FemboyESPBox"
            box.Adornee = player.Character
            box.Size = Vector3.new(4,6,2)
            box.Color3 = AccentBlue
            box.AlwaysOnTop = true
            box.ZIndex = 10
            box.Transparency = 0.5
            box.Parent = workspace
            table.insert(espBoxes, box)
        end
    end
end)

-- triggerbot logic
local Mouse = LocalPlayer:GetMouse()
RunService.RenderStepped:Connect(function()
    if not triggerEnabled then return end
    local target = Mouse.Target
    if target then
        local plr = Players:GetPlayerFromCharacter(target.Parent)
        if plr and plr ~= LocalPlayer then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Activate") then
                tool:Activate()
            end
        end
    end
end)
