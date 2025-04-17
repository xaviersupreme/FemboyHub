local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera

-- ==== THEME COLORS ====
local GlassColor = Color3.fromRGB(232, 230, 255)
local GlassDecor = Color3.fromRGB(255, 239, 255)
local AccentPink = Color3.fromRGB(244, 189, 255)
local AccentBlue = Color3.fromRGB(190, 225, 255)
local AccentWhite = Color3.fromRGB(235, 235, 240)
local Monochrome = Color3.fromRGB(215, 215, 215)
local Neon = Color3.fromRGB(255, 174, 255)
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
main.Size = UDim2.new(0, 560, 0, 670)
main.Position = UDim2.new(0.5, -280, 0.5, -335)
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

-- tab bar
local tabBar = Instance.new("Frame")
tabBar.Position = UDim2.new(0, 0, 0, 62)
tabBar.Size = UDim2.new(1, 0, 0, 50)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabs = {
    "Aimbot", "ESP", "Visuals", "Movement", "Combat", "Camera", "Fun", "Settings"
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
    btn.Position = UDim2.new(0, (i-1)*70+16, 0.5, -20)
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

-- ==== SMOOTH DRAG & INERTIA ====
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
main.Position = UDim2.new(0.5, -280, 1, 0)
main.Size = UDim2.new(0, 560, 0, 0)
TweenService:Create(main, TweenInfo.new(0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, -280, 0.5, -335),
    Size = UDim2.new(0, 560, 0, 670),
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


-- utility
local function makeToggle(parent, label, pos, default)
    local t = Instance.new("TextButton")
    t.Text = label .. ": " .. (default and "ON" or "OFF")
    t.Font = Enum.Font.GothamBold
    t.TextColor3 = default and Color3.fromRGB(127,255,127) or AccentBlue
    t.TextSize = 24
    t.BackgroundColor3 = AccentWhite
    t.BackgroundTransparency = 0.5
    t.Size = UDim2.new(0, 200, 0, 46)
    t.Position = pos
    t.Parent = parent
    local c = Instance.new("UICorner") c.Parent = t
    return t
end

-- ========== AIMBOT ==========
local aimbotTab = Instance.new("Frame")
aimbotTab.Size = UDim2.new(1, -36, 1, -36)
aimbotTab.Position = UDim2.new(0, 18, 0, 18)
aimbotTab.BackgroundTransparency = 1
aimbotTab.Visible = false
aimbotTab.Parent = contentFrame
tabContents["Aimbot"] = aimbotTab

local aimbotEnabled, aiming, aimKey, aimFOV, aimSmooth = false, false, Enum.KeyCode.LeftAlt, 90, 0.28
local aimbotToggle = makeToggle(aimbotTab, "Aimbot", UDim2.new(0,0,0,0), false)

local aimInfo = Instance.new("TextLabel")
aimInfo.Text = "Hold ["..aimKey.Name.."] to aim at closest player\nFOV: "..aimFOV
aimInfo.Font = Enum.Font.Gotham
aimInfo.TextColor3 = AccentPink
aimInfo.TextSize = 18
aimInfo.Position = UDim2.new(0,0,0,52)
aimInfo.Size = UDim2.new(1,0,0,44)
aimInfo.BackgroundTransparency = 1
aimInfo.TextXAlignment = Enum.TextXAlignment.Left
aimInfo.Parent = aimbotTab

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

local espEnabled = false
local espToggle = makeToggle(espTab, "Player ESP", UDim2.new(0,0,0,0), false)
local nameESPEnabled = true
local nameESPToggle = makeToggle(espTab, "Name ESP", UDim2.new(0,220,0,0), true)
local distESPEnabled = true
local distESPToggle = makeToggle(espTab, "Dist ESP", UDim2.new(0,440,0,0), true)

espToggle.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espToggle.Text = "Player ESP: "..(espEnabled and "ON" or "OFF")
    espToggle.TextColor3 = espEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)
nameESPToggle.MouseButton1Click:Connect(function()
    nameESPEnabled = not nameESPEnabled
    nameESPToggle.Text = "Name ESP: "..(nameESPEnabled and "ON" or "OFF")
    nameESPToggle.TextColor3 = nameESPEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)
distESPToggle.MouseButton1Click:Connect(function()
    distESPEnabled = not distESPEnabled
    distESPToggle.Text = "Dist ESP: "..(distESPEnabled and "ON" or "OFF")
    distESPToggle.TextColor3 = distESPEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)

-- ESP Drawing
local espBoxes = {}
local function clearESP()
    for _, adorn in pairs(workspace:GetChildren()) do
        if adorn.Name == "FemboyESPBox" and adorn:IsA("BoxHandleAdornment") then
            adorn:Destroy()
        end
    end
    for _, gui in pairs(workspace:GetChildren()) do
        if gui.Name == "FemboyESPBill" and gui:IsA("BillboardGui") then
            gui:Destroy()
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then clearESP() return end
    clearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            -- Box ESP
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
            -- name/dist ESP
            if nameESPEnabled or distESPEnabled then
                local bill = Instance.new("BillboardGui")
                bill.Name = "FemboyESPBill"
                bill.Adornee = player.Character.Head
                bill.Size = UDim2.new(0,200,0,36)
                bill.StudsOffset = Vector3.new(0,2.5,0)
                bill.AlwaysOnTop = true
                bill.Parent = workspace
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.Font = Enum.Font.GothamBold
                label.TextColor3 = AccentPink
                label.TextSize = 16
                label.Text = (nameESPEnabled and player.Name or "") .. (distESPEnabled and (" ["..math.floor((Camera.CFrame.Position-player.Character.Head.Position).Magnitude).."m]") or "")
                label.Parent = bill
            end
        end
    end
end)

-- ========== VISUALS ==========
local visualsTab = Instance.new("Frame")
visualsTab.Size = UDim2.new(1, -36, 1, -36)
visualsTab.Position = UDim2.new(0, 18, 0, 18)
visualsTab.BackgroundTransparency = 1
visualsTab.Visible = false
visualsTab.Parent = contentFrame
tabContents["Visuals"] = visualsTab

local fullbrightEnabled = false
local fullbrightToggle = makeToggle(visualsTab, "Fullbright", UDim2.new(0,0,0,0), false)
local fogToggle = makeToggle(visualsTab, "No Fog", UDim2.new(0,220,0,0), false)
local themeLabel = Instance.new("TextLabel")
themeLabel.Text = "Femboy Hub Glass Theme"
themeLabel.Font = Enum.Font.GothamBold
themeLabel.TextColor3 = AccentBlue
themeLabel.TextSize = 28
themeLabel.Size = UDim2.new(1, 0, 0, 40)
themeLabel.Position = UDim2.new(0,0,0,60)
themeLabel.BackgroundTransparency = 1
themeLabel.Parent = visualsTab

fullbrightToggle.MouseButton1Click:Connect(function()
    fullbrightEnabled = not fullbrightEnabled
    fullbrightToggle.Text = "Fullbright: "..(fullbrightEnabled and "ON" or "OFF")
    fullbrightToggle.TextColor3 = fullbrightEnabled and Color3.fromRGB(127,255,127) or AccentBlue
    if fullbrightEnabled then
        Lighting.Brightness = 6
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.OutdoorAmbient = Color3.new(1,1,1)
        Lighting.ClockTime = 14
    else
        Lighting.Brightness = 2
        Lighting.Ambient = Color3.fromRGB(128,128,128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
        Lighting.ClockTime = 14
    end
end)
fogToggle.MouseButton1Click:Connect(function()
    local noFog = not (Lighting.FogEnd > 10000)
    fogToggle.Text = "No Fog: "..(noFog and "ON" or "OFF")
    fogToggle.TextColor3 = noFog and Color3.fromRGB(127,255,127) or AccentBlue
    Lighting.FogEnd = noFog and 1e9 or 1000
end)

-- ========== MOVEMENT ==========
local movementTab = Instance.new("Frame")
movementTab.Size = UDim2.new(1, -36, 1, -36)
movementTab.Position = UDim2.new(0, 18, 0, 18)
movementTab.BackgroundTransparency = 1
movementTab.Visible = false
movementTab.Parent = contentFrame
tabContents["Movement"] = movementTab

local flyEnabled, noclipEnabled, speedEnabled = false, false, false
local speedValue, jumpValue = 60, 100
local infJumpEnabled = false

local flyToggle = makeToggle(movementTab, "Fly", UDim2.new(0,0,0,0), false)
local noclipToggle = makeToggle(movementTab, "Noclip", UDim2.new(0,220,0,0), false)
local speedToggle = makeToggle(movementTab, "Speed", UDim2.new(0,440,0,0), false)
local infJumpToggle = makeToggle(movementTab, "Inf Jump", UDim2.new(0,0,0,60), false)

flyToggle.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyToggle.Text = "Fly: "..(flyEnabled and "ON" or "OFF")
    flyToggle.TextColor3 = flyEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)
noclipToggle.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipToggle.Text = "Noclip: "..(noclipEnabled and "ON" or "OFF")
    noclipToggle.TextColor3 = noclipEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)
speedToggle.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedToggle.Text = "Speed: "..(speedEnabled and "ON" or "OFF")
    speedToggle.TextColor3 = speedEnabled and Color3.fromRGB(127,255,127) or AccentBlue
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedEnabled and speedValue or 16
    end
end)
infJumpToggle.MouseButton1Click:Connect(function()
    infJumpEnabled = not infJumpEnabled
    infJumpToggle.Text = "Inf Jump: "..(infJumpEnabled and "ON" or "OFF")
    infJumpToggle.TextColor3 = infJumpEnabled and Color3.fromRGB(127,255,127) or AccentBlue
end)

-- infinite jump logic
UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- fly/noclip/speed logic
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
    -- oclip
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
    -- speed
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = speedValue
    end
end)

-- ========== COMBAT ==========
local combatTab = Instance.new("Frame")
combatTab.Size = UDim2.new(1, -36, 1, -36)
combatTab.Position = UDim2.new(0, 18, 0, 18)
combatTab.BackgroundTransparency = 1
combatTab.Visible = false
combatTab.Parent = contentFrame
tabContents["Combat"] = combatTab

local triggerEnabled = false
local triggerToggle = makeToggle(combatTab, "Triggerbot", UDim2.new(0,0,0,0), false)
triggerToggle.MouseButton1Click:Connect(function()
    triggerEnabled = not triggerEnabled
    triggerToggle.Text = "Triggerbot: "..(triggerEnabled and "ON" or "OFF")
    triggerToggle.TextColor3 = triggerEnabled and Color3.fromRGB(127,255,127) or AccentBlue
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

-- ========== CAMERA ==========
local cameraTab = Instance.new("Frame")
cameraTab.Size = UDim2.new(1, -36, 1, -36)
cameraTab.Position = UDim2.new(0, 18, 0, 18)
cameraTab.BackgroundTransparency = 1
cameraTab.Visible = false
cameraTab.Parent = contentFrame
tabContents["Camera"] = cameraTab

local fovValue = 70
local fovLabel = Instance.new("TextLabel")
fovLabel.Text = "FOV: "..fovValue
fovLabel.Font = Enum.Font.Gotham
fovLabel.TextColor3 = AccentPink
fovLabel.TextSize = 18
fovLabel.Position = UDim2.new(0, 0, 0, 0)
fovLabel.Size = UDim2.new(0, 200, 0, 36)
fovLabel.BackgroundTransparency = 1
fovLabel.TextXAlignment = Enum.TextXAlignment.Left
fovLabel.Parent = cameraTab

local plusFOV = Instance.new("TextButton")
plusFOV.Text = "+"
plusFOV.Font = Enum.Font.GothamBold
plusFOV.TextColor3 = AccentPink
plusFOV.TextSize = 20
plusFOV.BackgroundColor3 = AccentWhite
plusFOV.BackgroundTransparency = 0.7
plusFOV.Size = UDim2.new(0, 36, 0, 36)
plusFOV.Position = UDim2.new(0, 220, 0, 0)
plusFOV.Parent = cameraTab
local plusFOVCorner = Instance.new("UICorner") plusFOVCorner.Parent = plusFOV

local minusFOV = plusFOV:Clone()
minusFOV.Text = "-"
minusFOV.Position = UDim2.new(0, 180, 0, 0)
minusFOV.Parent = cameraTab

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

-- freecam (camera detachment)
local freecamEnabled = false
local freecamToggle = makeToggle(cameraTab, "Freecam", UDim2.new(0, 0, 0, 50), false)
freecamToggle.MouseButton1Click:Connect(function()
    freecamEnabled = not freecamEnabled
    freecamToggle.Text = "Freecam: "..(freecamEnabled and "ON" or "OFF")
    freecamToggle.TextColor3 = freecamEnabled and Color3.fromRGB(127,255,127) or AccentBlue
    if freecamEnabled then
        Camera.CameraType = Enum.CameraType.Scriptable
    else
        Camera.CameraType = Enum.CameraType.Custom
    end
end)
RunService.RenderStepped:Connect(function()
    if freecamEnabled then
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0,1,0) end
        Camera.CFrame = Camera.CFrame + move * 2
    end
end)

-- ========== FUN ==========
local funTab = Instance.new("Frame")
funTab.Size = UDim2.new(1, -36, 1, -36)
funTab.Position = UDim2.new(0, 18, 0, 18)
funTab.BackgroundTransparency = 1
funTab.Visible = false
funTab.Parent = contentFrame
tabContents["Fun"] = funTab

local rainbowTrailEnabled = false
local rainbowTrailToggle = makeToggle(funTab, "Rainbow Trail", UDim2.new(0, 0, 0, 0), false)
rainbowTrailToggle.MouseButton1Click:Connect(function()
    rainbowTrailEnabled = not rainbowTrailEnabled
    rainbowTrailToggle.Text = "Rainbow Trail: "..(rainbowTrailEnabled and "ON" or "OFF")
    rainbowTrailToggle.TextColor3 = rainbowTrailEnabled and Color3.fromRGB(127,255,127) or AccentBlue
    if rainbowTrailEnabled then
        -- add a trail to HumanoidRootPart
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and not LocalPlayer.Character:FindFirstChild("FemboyTrail") then
            local trail = Instance.new("Trail")
            trail.Name = "FemboyTrail"
            trail.Attachment0 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
            trail.Attachment1 = Instance.new("Attachment", LocalPlayer.Character.HumanoidRootPart)
            trail.Attachment1.Position = Vector3.new(0, -2, 0)
            trail.Lifetime = 0.7
            trail.LightEmission = 1
            trail.Parent = LocalPlayer.Character.HumanoidRootPart
            coroutine.wrap(function()
                while rainbowTrailEnabled and trail do
                    local t = tick()
                    trail.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromHSV((t%5)/5,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(((t+1)%5)/5,1,1))
                    }
                    wait(0.1)
                end
                if trail then trail:Destroy() end
            end)()
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local t = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FemboyTrail")
            if t then t:Destroy() end
        end
    end
end)

-- ========== SETTINGS ==========
local settingsTab = Instance.new("Frame")
settingsTab.Size = UDim2.new(1, -36, 1, -36)
settingsTab.Position = UDim2.new(0, 18, 0, 18)
settingsTab.BackgroundTransparency = 1
settingsTab.Visible = false
settingsTab.Parent = contentFrame
tabContents["Settings"] = settingsTab

local settingsLabel = Instance.new("TextLabel")
settingsLabel.Text = "Femboy Hub\nUniversal LocalScript - For Any Game"
settingsLabel.Font = Enum.Font.Gotham
settingsLabel.TextColor3 = AccentBlue
settingsLabel.TextSize = 20
settingsLabel.Size = UDim2.new(1, 0, 0, 60)
settingsLabel.BackgroundTransparency = 1
settingsLabel.Parent = settingsTab

-- ==== OPEN DEFAULT TAB ====
showTab("Aimbot")
tabBtns["Aimbot"].BackgroundTransparency = 0.38
