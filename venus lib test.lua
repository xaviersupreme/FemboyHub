loadstring(game:HttpGet("https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/refs/heads/main/Venus%20Lib/Venus%20Lib%20Source.lua"))()

local Venus
pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/refs/heads/main/Venus%20Lib/Venus%20Lib%20Source.lua"))()
    Venus = Venus.new("Femboy Hub")
end)

if not Venus then
    warn("Venus Lib failed to load. Make sure you are running this script in a compatible executor.")
    return
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CurrentCamera = Workspace.CurrentCamera

local Settings = {
    Aimbot = false,
    SilentAim = false,
    AimbotFOV = 90,
    AimbotSmoothness = 0.1,
    AimbotTargetPart = "Head",
    AimKey = Enum.KeyCode.RightClick,

    BoxESP = false,
    NameESP = false,
    HealthESP = false,
    Tracers = false,
    ESPColor = Color3.fromRGB(255, 0, 0),
    ESPRadius = 500,

    WalkSpeed = 16,
    JumpPower = 50,
    Noclip = false,
    Fly = false,
    GodMode = false,
    FOVChanger = 70,
}

local CombatTab = Venus:AddTab("Combat")
local VisualsTab = Venus:AddTab("Visuals")
local PlayerTab = Venus:AddTab("Player")

local function getNearestTarget()
    local bestTarget = nil
    local shortestDistance = math.huge
    local localCharacter = LocalPlayer.Character
    if not localCharacter or not localCharacter:FindFirstChildOfClass("Humanoid") then return nil end
    local localHumanoidRootPart = localCharacter:FindFirstChild("HumanoidRootPart")
    if not localHumanoidRootPart then return nil end

    local cameraViewportSize = CurrentCamera.ViewportSize
    local screenCenter = Vector2.new(cameraViewportSize.X / 2, cameraViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
            local targetHumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if targetHumanoidRootPart then
                local distance = (localHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude
                if distance < shortestDistance and distance <= Settings.ESPRadius then
                    local screenPos, onScreen = CurrentCamera:WorldToScreenPoint(targetHumanoidRootPart.Position)
                    if onScreen then
                        local distSqToCenter = (screenPos.X - screenCenter.X)^2 + (screenPos.Y - screenCenter.Y)^2
                        local fovRadius = Settings.AimbotFOV / CurrentCamera.FieldOfView * (math.min(cameraViewportSize.X, cameraViewportSize.Y) / 2)

                        if distSqToCenter <= fovRadius^2 then
                            bestTarget = player.Character
                            shortestDistance = distance
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

local function getTargetPart(targetCharacter)
    if not targetCharacter then return nil end

    if Settings.AimbotTargetPart == "Head" then
        return targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("HumanoidRootPart")
    elseif Settings.AimbotTargetPart == "Torso" then
        return targetCharacter:FindFirstChild("Torso") or targetCharacter:FindFirstChild("UpperTorso") or targetCharacter:FindFirstChild("HumanoidRootPart")
    else
        local localCharacter = LocalPlayer.Character
        if not localCharacter or not localCharacter:FindFirstChild("HumanoidRootPart") then return targetCharacter:FindFirstChild("HumanoidRootPart") end

        local nearestPart = nil
        local shortestDist = math.huge
        for _, part in ipairs(targetCharacter:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide and part.Transparency < 1 and part.Name ~= "HumanoidRootPart" then
                local dist = (part.Position - localCharacter.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    nearestPart = part
                end
            end
        end
        return nearestPart or targetCharacter:FindFirstChild("HumanoidRootPart")
    end
end

local function aimbotLogic()
    if not Settings.Aimbot or not UserInputService:IsKeyDown(Settings.AimKey) then return end

    local target = getNearestTarget()
    if not target then return end

    local targetPart = getTargetPart(target)
    if not targetPart then return end

    local currentCFrame = CurrentCamera.CFrame
    local targetPosition = targetPart.Position

    local lookVector = (targetPosition - currentCFrame.Position).Unit
    local desiredCFrame = CFrame.new(currentCFrame.Position, currentCFrame.Position + lookVector)

    CurrentCamera.CFrame = currentCFrame:Lerp(desiredCFrame, Settings.AimbotSmoothness)
end

local function silentAimLogic()
    if not Settings.SilentAim or not UserInputService:IsKeyDown(Settings.AimKey) then return end

    local target = getNearestTarget()
    if not target then return end

    local targetPart = getTargetPart(target)
    if not targetPart then return end
end

CombatTab:AddToggle("Aimbot", Settings.Aimbot, function(state)
    Settings.Aimbot = state
    if state then
        Settings.SilentAim = false
        CombatTab:GetElement("Silent Aim"):SetState(false)
    end
end)
CombatTab:AddToggle("Silent Aim", Settings.SilentAim, function(state)
    Settings.SilentAim = state
    if state then
        Settings.Aimbot = false
        CombatTab:GetElement("Aimbot"):SetState(false)
    end
end)
CombatTab:AddSlider("Aimbot FOV", 0, 360, Settings.AimbotFOV, function(value)
    Settings.AimbotFOV = value
end)
CombatTab:AddSlider("Aimbot Smoothness", 0, 1, Settings.AimbotSmoothness, function(value)
    Settings.AimbotSmoothness = value
end)
CombatTab:AddDropdown("Aimbot Target Part", {"Head", "Torso", "NearestPart"}, Settings.AimbotTargetPart, function(value)
    Settings.AimbotTargetPart = value
end)
local aimKeyOptions = {
    "RightClick", "LeftClick", "E", "Q", "X", "C", "V", "LeftShift", "LeftAlt", "Space",
    "F", "R", "T", "G", "Z", "1", "2", "3", "4", "5"
}
CombatTab:AddDropdown("Aim Key", aimKeyOptions, tostring(Settings.AimKey):gsub("Enum.KeyCode.", ""), function(value)
    Settings.AimKey = Enum.KeyCode[value]
end)


local espContainer = Instance.new("Folder")
espContainer.Name = "FemboyHub_ESP_Container"
espContainer.Parent = game:GetService("CoreGui")

local espObjects = {}

local function createESPObject(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not hrp then return nil end

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Size = UDim2.new(0, 150, 0, 100)
    billboardGui.StudsOffset = Vector3.new(0, character:GetExtentsSize().Y / 2 + 0.5, 0)
    billboardGui.Adornee = hrp
    billboardGui.AlwaysOnTop = true
    billboardGui.ExtentsOffset = Vector3.new(0, character:GetExtentsSize().Y / 2, 0)
    billboardGui.Name = "FemboyHub_ESP_" .. character.Name
    billboardGui.Parent = espContainer

    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 1, 0)
    boxFrame.BackgroundTransparency = 1
    boxFrame.BorderSizePixel = 2
    boxFrame.BorderColor3 = Settings.ESPColor
    boxFrame.Name = "BoxFrame"
    boxFrame.Parent = billboardGui

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, -20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextColor3 = Settings.ESPColor
    nameLabel.Font = Enum.Font.SourceSansBold
    nameLabel.TextSize = 18
    nameLabel.TextScaled = true
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center
    nameLabel.Name = "NameLabel"
    nameLabel.Text = character.Name
    nameLabel.Parent = billboardGui

    local healthBar = Instance.new("Frame")
    healthBar.Size = UDim2.new(1, 0, 0, 5)
    healthBar.Position = UDim2.new(0, 0, 0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    healthBar.BorderSizePixel = 0
    healthBar.Name = "HealthBar"
    healthBar.Parent = billboardGui

    local healthText = Instance.new("TextLabel")
    healthText.Size = UDim2.new(1, 0, 0, 15)
    healthText.Position = UDim2.new(0, 0, 0, 5)
    healthText.BackgroundTransparency = 1
    healthText.TextColor3 = Settings.ESPColor
    healthText.Font = Enum.Font.SourceSansBold
    healthText.TextSize = 14
    healthText.Text = ""
    healthText.Name = "HealthText"
    healthText.Parent = billboardGui

    local tracerLine = Instance.new("LineHandleAdornment")
    tracerLine.Color3 = Settings.ESPColor
    tracerLine.Thickness = 2
    tracerLine.Adornee = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    tracerLine.Parent = espContainer
    tracerLine.Visible = false

    return {
        billboardGui = billboardGui,
        boxFrame = boxFrame,
        nameLabel = nameLabel,
        healthBar = healthBar,
        healthText = healthText,
        tracerLine = tracerLine,
        character = character
    }
end

local function updateESPObjects()
    local localCharacter = LocalPlayer.Character
    local localHumanoidRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
    if not localCharacter or not localHumanoidRootPart then return end

    local activeCharacters = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChildOfClass("Humanoid") and player.Character.Humanoid.Health > 0 then
            activeCharacters[player.Character] = true
            if not espObjects[player.Character] then
                espObjects[player.Character] = createESPObject(player.Character)
            end
        end
    end

    for char, obj in pairs(espObjects) do
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if not activeCharacters[char] or not char.Parent or not humanoid or humanoid.Health <= 0 then
            if obj.billboardGui then obj.billboardGui:Destroy() end
            if obj.tracerLine then obj.tracerLine:Destroy() end
            espObjects[char] = nil
        else
            local distance = (localHumanoidRootPart.Position - hrp.Position).Magnitude
            local shouldBeVisible = distance <= Settings.ESPRadius and (Settings.BoxESP or Settings.NameESP or Settings.HealthESP or Settings.Tracers)

            obj.billboardGui.Enabled = shouldBeVisible
            obj.tracerLine.Visible = shouldBeVisible and Settings.Tracers
            obj.tracerLine.Adornee = localHumanoidRootPart

            if shouldBeVisible then
                obj.billboardGui.Adornee = hrp

                if Settings.BoxESP and obj.boxFrame then
                    obj.boxFrame.Visible = true
                    obj.boxFrame.BorderColor3 = Settings.ESPColor
                else
                    if obj.boxFrame then obj.boxFrame.Visible = false end
                end

                if Settings.NameESP and obj.nameLabel then
                    obj.nameLabel.Visible = true
                    obj.nameLabel.TextColor3 = Settings.ESPColor
                    obj.nameLabel.Text = char.Name .. " [" .. math.floor(distance) .. "m]"
                else
                    if obj.nameLabel then obj.nameLabel.Visible = false end
                end

                if Settings.HealthESP and obj.healthBar and obj.healthText then
                    obj.healthBar.Visible = true
                    obj.healthText.Visible = true
                    local healthRatio = humanoid.Health / humanoid.MaxHealth
                    obj.healthBar.Size = UDim2.new(healthRatio, 0, 1, 0)
                    obj.healthBar.BackgroundColor3 = Color3.fromRGB(255 * (1 - healthRatio), 255 * healthRatio, 0)
                    obj.healthText.Text = math.floor(humanoid.Health) .. " / " .. math.floor(humanoid.MaxHealth)
                    obj.healthText.TextColor3 = Settings.ESPColor
                else
                    if obj.healthBar then obj.healthBar.Visible = false end
                    if obj.healthText then obj.healthText.Visible = false end
                end
            end
        end
    end
end

VisualsTab:AddToggle("Box ESP", Settings.BoxESP, function(state)
    Settings.BoxESP = state
end)
VisualsTab:AddToggle("Name ESP", Settings.NameESP, function(state)
    Settings.NameESP = state
end)
VisualsTab:AddToggle("Health ESP", Settings.HealthESP, function(state)
    Settings.HealthESP = state
end)
VisualsTab:AddToggle("Tracers", Settings.Tracers, function(state)
    Settings.Tracers = state
end)
VisualsTab:AddSlider("ESP Render Distance", 0, 2000, Settings.ESPRadius, function(value)
    Settings.ESPRadius = value
end)
VisualsTab:AddColorPicker("ESP Color", Settings.ESPColor, function(color)
    Settings.ESPColor = color
    for _, obj in pairs(espObjects) do
        if obj.boxFrame then obj.boxFrame.BorderColor3 = color end
        if obj.nameLabel then obj.nameLabel.TextColor3 = color end
        if obj.healthText then obj.healthText.TextColor3 = color end
        if obj.tracerLine then obj.tracerLine.Color3 = color end
    end
end)

local noclipConnection = nil
local flyConnection = nil

local function applyContinuousPlayerMods()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    if Settings.GodMode then
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end
end

local function toggleNoclip(enabled)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if enabled then
        humanoid.PlatformStand = true
        noclipConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Noclip or not character or not humanoid or not rootPart then return end

            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then moveDirection = moveDirection - Vector3.new(0,1,0) end

            local speed = Settings.WalkSpeed / 2
            if moveDirection.Magnitude > 0 then
                rootPart.CFrame = rootPart.CFrame + moveDirection.Unit * speed
            end

            for _, part in ipairs(character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        humanoid.PlatformStand = false
        for _, part in ipairs(character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

local function toggleFly(enabled)
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end

    if enabled then
        humanoid.PlatformStand = true
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        flyConnection = RunService.Heartbeat:Connect(function()
            if not Settings.Fly or not character or not humanoid or not rootPart then return end

            local moveDirection = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection - CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection - CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.C) then moveDirection = moveDirection - Vector3.new(0,1,0) end

            local speed = Settings.WalkSpeed * 2
            if moveDirection.Magnitude > 0 then
                rootPart.CFrame = rootPart.CFrame + moveDirection.Unit * speed
            end
        end)
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        humanoid.PlatformStand = false
        humanoid.WalkSpeed = Settings.WalkSpeed
        humanoid.JumpPower = Settings.JumpPower
    end
end

PlayerTab:AddSlider("WalkSpeed", 0, 100, Settings.WalkSpeed, function(value)
    Settings.WalkSpeed = value
    local character = LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") and not Settings.Fly then
        character.Humanoid.WalkSpeed = value
    end
end)
PlayerTab:AddSlider("JumpPower", 0, 500, Settings.JumpPower, function(value)
    Settings.JumpPower = value
    local character = LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") and not Settings.Fly then
        character.Humanoid.JumpPower = value
    end
end)
PlayerTab:AddToggle("Noclip", Settings.Noclip, function(state)
    Settings.Noclip = state
    toggleNoclip(state)
    if state then
        Settings.Fly = false
        PlayerTab:GetElement("Fly"):SetState(false)
    end
end)
PlayerTab:AddToggle("Fly", Settings.Fly, function(state)
    Settings.Fly = state
    toggleFly(state)
    if state then
        Settings.Noclip = false
        PlayerTab:GetElement("Noclip"):SetState(false)
    end
end)
PlayerTab:AddToggle("God Mode (Client-Sided)", Settings.GodMode, function(state)
    Settings.GodMode = state
end)
PlayerTab:AddSlider("Camera FOV", 1, 120, Settings.FOVChanger, function(value)
    Settings.FOVChanger = value
    CurrentCamera.FieldOfView = value
end)

RunService.RenderStepped:Connect(function()
    aimbotLogic()
    silentAimLogic()
    updateESPObjects()
    applyContinuousPlayerMods()
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    character:WaitForChild("Humanoid").WalkSpeed = Settings.WalkSpeed
    character:WaitForChild("Humanoid").JumpPower = Settings.JumpPower
    CurrentCamera.FieldOfView = Settings.FOVChanger

    if Settings.Noclip then toggleNoclip(true) end
    if Settings.Fly then toggleFly(true) end

    for _, obj in pairs(espObjects) do
        if obj.tracerLine then
            obj.tracerLine.Adornee = character:FindFirstChild("HumanoidRootPart")
        end
    end
end)

if LocalPlayer.Character then
    LocalPlayer.Character:WaitForChild("Humanoid").WalkSpeed = Settings.WalkSpeed
    LocalPlayer.Character:WaitForChild("Humanoid").JumpPower = Settings.JumpPower
    CurrentCamera.FieldOfView = Settings.FOVChanger
    if Settings.Noclip then toggleNoclip(true) end
    if Settings.Fly then toggleFly(true) end
end

Venus:AddCloseButton(function()
    if noclipConnection then noclipConnection:Disconnect() end
    if flyConnection then flyConnection:Disconnect() end

    if espContainer then espContainer:Destroy() end
    for char, obj in pairs(espObjects) do
        if obj.billboardGui then obj.billboardGui:Destroy() end
        if obj.tracerLine then obj.tracerLine:Destroy() end
    end
    espObjects = {}

    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
            humanoid.JumpPower = 50
        end
    end
    CurrentCamera.FieldOfView = 70

    print("Script Unloaded.")
end)

print("Femboy Hub Loaded!")
