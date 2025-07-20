-- Advanced Aimbot Module
-- A complete aimbot module with advanced features for FemboyHub
-- Based on the original FemboyHub aimbot with enhanced functionality

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Module Settings
local AdvancedAimbot = {
    Enabled = false,
    Toggle = true,
    TriggerKey = "E",
    
    -- Basic Settings
    LockPart = "Head",
    TeamCheck = false,
    WallCheck = false,
    VisibilityCheck = true,
    Sensitivity = 0.1,
    
    -- FOV Settings
    FOV = {
        Enabled = true,
        Amount = 100,
        Thickness = 1,
        Filled = false,
        Sides = 60,
        Color = Color3.fromRGB(255, 255, 255),
        Transparency = 1,
        Visible = true,
        LockedColor = Color3.fromRGB(255, 0, 0)
    },
    
    -- Advanced Features
    SmoothingEnabled = false,
    SmoothingFactor = 0.5,
    MovementPrediction = false,
    PredictionStrength = 0.3,
    AccelerationEnabled = false,
    AccelerationSpeed = 0.2,
    TargetPriority = "Closest to Crosshair",
    DynamicFOV = false,
    MaxTargetDistance = 1000,
    MaxAngleToTarget = 180,
    
    -- Trigger Bot
    TriggerBotEnabled = false,
    TriggerBotKey = "MouseButton1",
    TriggerDelay = 50,
    BurstFire = false,
    BurstRounds = 3,
    
    -- Anti-Detection
    MissPercentageEnabled = false,
    MissPercentage = 15,
    HumanLikeMovement = false,
    MovementRandomness = 0.2,
    ReactionTimeSimulation = false,
    ReactionTime = 150,
    
    -- Weapon Control
    RecoilControlEnabled = false,
    RecoilCompensation = 0.5,
    SpreadControlEnabled = false,
    SpreadCompensation = 0.3,
    AutoWeaponDetection = false,
    
    -- Visual Features
    TargetHighlighting = false,
    TargetHighlightColor = Color3.fromRGB(255, 0, 0),
    TargetInformation = false,
    HitMarkers = false,
    HitMarkerColor = Color3.fromRGB(0, 255, 0),
    TargetLines = false,
    TargetLineColor = Color3.fromRGB(255, 255, 0),
    
    -- Internal Variables
    Locked = nil,
    RequiredDistance = 2000,
    Running = false,
    lastTargetTime = 0,
    currentTarget = nil,
    burstCount = 0,
    lastShotTime = 0,
    recoilOffset = Vector3.new(0, 0, 0),
    spreadOffset = Vector3.new(0, 0, 0),
    targetHighlight = nil,
    targetLine = nil,
    hitMarker = nil,
    FOVCircle = nil,
    ServiceConnections = {}
}

-- Utility Functions
local function ConvertVector(Vector)
    return Vector2.new(Vector.X, Vector.Y)
end

local function getRandomOffset(percentage)
    if math.random(1, 100) <= percentage then
        local angle = math.random() * math.pi * 2
        local distance = math.random(10, 50)
        return Vector3.new(
            math.cos(angle) * distance,
            math.sin(angle) * distance,
            0
        )
    end
    return Vector3.new(0, 0, 0)
end

local function getTargetPriority(players, localPlayer, camera)
    local validTargets = {}
    
    for _, player in pairs(players) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(AdvancedAimbot.LockPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Basic checks
                if AdvancedAimbot.TeamCheck and player.TeamColor == localPlayer.TeamColor then
                    continue
                end
                
                if AdvancedAimbot.WallCheck then
                    local parts = camera:GetPartsObscuringTarget({player.Character[AdvancedAimbot.LockPart].Position}, player.Character:GetDescendants())
                    if #parts > 0 then
                        continue
                    end
                end
                
                -- Distance check
                local distance = (player.Character[AdvancedAimbot.LockPart].Position - localPlayer.Character[AdvancedAimbot.LockPart].Position).Magnitude
                if distance > AdvancedAimbot.MaxTargetDistance then
                    continue
                end
                
                -- Angle check
                local targetPos = camera:WorldToViewportPoint(player.Character[AdvancedAimbot.LockPart].Position)
                local mousePos = UserInputService:GetMouseLocation()
                local angle = math.deg(math.atan2(targetPos.Y - mousePos.Y, targetPos.X - mousePos.X))
                if math.abs(angle) > AdvancedAimbot.MaxAngleToTarget then
                    continue
                end
                
                table.insert(validTargets, {
                    Player = player,
                    Distance = distance,
                    Angle = angle,
                    Health = humanoid.Health,
                    IsMoving = humanoid.MoveDirection.Magnitude > 0
                })
            end
        end
    end
    
    if #validTargets == 0 then
        return nil
    end
    
    -- Sort based on priority
    if AdvancedAimbot.TargetPriority == "Closest to Crosshair" then
        table.sort(validTargets, function(a, b) return a.Angle < b.Angle end)
    elseif AdvancedAimbot.TargetPriority == "Closest to Player" then
        table.sort(validTargets, function(a, b) return a.Distance < b.Distance end)
    elseif AdvancedAimbot.TargetPriority == "Lowest Health" then
        table.sort(validTargets, function(a, b) return a.Health < b.Health end)
    elseif AdvancedAimbot.TargetPriority == "Moving Targets Only" then
        local movingTargets = {}
        for _, target in pairs(validTargets) do
            if target.IsMoving then
                table.insert(movingTargets, target)
            end
        end
        if #movingTargets > 0 then
            validTargets = movingTargets
        end
    elseif AdvancedAimbot.TargetPriority == "Random Selection" then
        return validTargets[math.random(1, #validTargets)].Player
    end
    
    return validTargets[1].Player
end

local function applySmoothing(currentCFrame, targetCFrame, smoothingFactor)
    if not AdvancedAimbot.SmoothingEnabled then
        return targetCFrame
    end
    
    return currentCFrame:Lerp(targetCFrame, smoothingFactor)
end

local function applyPrediction(targetPosition, targetVelocity)
    if not AdvancedAimbot.MovementPrediction then
        return targetPosition
    end
    
    local prediction = targetVelocity * AdvancedAimbot.PredictionStrength
    return targetPosition + prediction
end

local function shouldMiss()
    if not AdvancedAimbot.MissPercentageEnabled then
        return false
    end
    
    return math.random(1, 100) <= AdvancedAimbot.MissPercentage
end

local function getHumanizedOffset()
    if not AdvancedAimbot.HumanLikeMovement then
        return Vector3.new(0, 0, 0)
    end
    
    local randomness = AdvancedAimbot.MovementRandomness
    return Vector3.new(
        (math.random() - 0.5) * randomness * 10,
        (math.random() - 0.5) * randomness * 10,
        0
    )
end

local function checkReactionTime()
    if not AdvancedAimbot.ReactionTimeSimulation then
        return true
    end
    
    local currentTime = tick()
    if currentTime - AdvancedAimbot.lastTargetTime < (AdvancedAimbot.ReactionTime / 1000) then
        return false
    end
    
    AdvancedAimbot.lastTargetTime = currentTime
    return true
end

-- Core Functions
function AdvancedAimbot:GetClosestPlayer()
    if not self.Locked then
        self.RequiredDistance = (self.FOV.Enabled and self.FOV.Amount or 2000)
        
        local target = getTargetPriority(Players:GetPlayers(), LocalPlayer, Camera)
        
        if target then
            local Vector, OnScreen = Camera:WorldToViewportPoint(target.Character[self.LockPart].Position)
            Vector = ConvertVector(Vector)
            local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude
            
            if Distance < self.RequiredDistance and OnScreen then
                self.RequiredDistance = Distance
                self.Locked = target
                self.currentTarget = target
            end
        end
    elseif (UserInputService:GetMouseLocation() - ConvertVector(Camera:WorldToViewportPoint(self.Locked.Character[self.LockPart].Position))).Magnitude > self.RequiredDistance then
        self:CancelLock()
    end
end

function AdvancedAimbot:CancelLock()
    self.Locked = nil
    self.currentTarget = nil
    self.burstCount = 0
    
    if self.targetHighlight then
        self.targetHighlight.Visible = false
    end
    if self.targetLine then
        self.targetLine.Visible = false
    end
end

function AdvancedAimbot:HandleTriggerBot()
    if not self.TriggerBotEnabled then
        return
    end
    
    if self.Locked then
        local currentTime = tick()
        
        -- Check trigger delay
        if currentTime - self.lastShotTime < (self.TriggerDelay / 1000) then
            return
        end
        
        -- Handle burst fire
        if self.BurstFire and self.burstCount < self.BurstRounds then
            mouse1click()
            self.burstCount = self.burstCount + 1
            self.lastShotTime = currentTime
            
            -- Show hit marker
            if self.hitMarker and self.HitMarkers then
                self.hitMarker.Position = UserInputService:GetMouseLocation()
                self.hitMarker.Visible = true
                task.delay(0.5, function()
                    self.hitMarker.Visible = false
                end)
            end
        elseif not self.BurstFire then
            mouse1click()
            self.lastShotTime = currentTime
            
            -- Show hit marker
            if self.hitMarker and self.HitMarkers then
                self.hitMarker.Position = UserInputService:GetMouseLocation()
                self.hitMarker.Visible = true
                task.delay(0.5, function()
                    self.hitMarker.Visible = false
                end)
            end
        end
    else
        self.burstCount = 0
    end
end

function AdvancedAimbot:TrackRecoil()
    if not self.RecoilControlEnabled then
        return
    end
    
    -- Simulate recoil pattern (this would need to be customized per weapon)
    local currentTime = tick()
    self.recoilOffset = Vector3.new(
        math.sin(currentTime * 10) * 0.1,
        math.cos(currentTime * 8) * 0.15,
        0
    )
end

function AdvancedAimbot:TrackSpread()
    if not self.SpreadControlEnabled then
        return
    end
    
    -- Simulate spread pattern
    self.spreadOffset = Vector3.new(
        (math.random() - 0.5) * 0.2,
        (math.random() - 0.5) * 0.2,
        0
    )
end

function AdvancedAimbot:UpdateVisualElements(targetPosition)
    -- Update target highlighting
    if self.targetHighlight and self.TargetHighlighting then
        local screenPos = Camera:WorldToViewportPoint(targetPosition)
        self.targetHighlight.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
        self.targetHighlight.Size = Vector2.new(40, 40)
        self.targetHighlight.Visible = true
    end
    
    -- Update target lines
    if self.targetLine and self.TargetLines then
        local screenPos = Camera:WorldToViewportPoint(targetPosition)
        self.targetLine.From = UserInputService:GetMouseLocation()
        self.targetLine.To = Vector2.new(screenPos.X, screenPos.Y)
        self.targetLine.Visible = true
    end
end

function AdvancedAimbot:HideVisualElements()
    if self.targetHighlight then
        self.targetHighlight.Visible = false
    end
    if self.targetLine then
        self.targetLine.Visible = false
    end
end

-- Main Functions
function AdvancedAimbot:Load()
    -- Create FOV Circle
    self.FOVCircle = Drawing.new("Circle")
    self.FOVCircle.Radius = self.FOV.Amount
    self.FOVCircle.Thickness = self.FOV.Thickness
    self.FOVCircle.Filled = self.FOV.Filled
    self.FOVCircle.NumSides = self.FOV.Sides
    self.FOVCircle.Color = self.FOV.Color
    self.FOVCircle.Transparency = self.FOV.Transparency
    self.FOVCircle.Visible = self.FOV.Visible
    self.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
    
    -- Create visual elements
    if self.TargetHighlighting then
        self.targetHighlight = Drawing.new("Square")
        self.targetHighlight.Visible = false
        self.targetHighlight.Thickness = 2
        self.targetHighlight.Filled = false
        self.targetHighlight.Color = self.TargetHighlightColor
    end
    
    if self.TargetLines then
        self.targetLine = Drawing.new("Line")
        self.targetLine.Visible = false
        self.targetLine.Thickness = 1
        self.targetLine.Color = self.TargetLineColor
    end
    
    if self.HitMarkers then
        self.hitMarker = Drawing.new("Text")
        self.hitMarker.Visible = false
        self.hitMarker.Size = 20
        self.hitMarker.Center = true
        self.hitMarker.Color = self.HitMarkerColor
        self.hitMarker.Text = "X"
    end
    
    -- Connect RenderStepped
    self.ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        -- Update FOV Circle
        if self.FOV.Enabled and self.Enabled then
            self.FOVCircle.Radius = self.FOV.Amount
            self.FOVCircle.Thickness = self.FOV.Thickness
            self.FOVCircle.Filled = self.FOV.Filled
            self.FOVCircle.NumSides = self.FOV.Sides
            self.FOVCircle.Color = self.FOV.Color
            self.FOVCircle.Transparency = self.FOV.Transparency
            self.FOVCircle.Visible = self.FOV.Visible
            self.FOVCircle.Position = Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            self.FOVCircle.Visible = false
        end

        if self.Running and self.Enabled then
            self:GetClosestPlayer()

            if self.Locked and checkReactionTime() then
                local targetPart = self.Locked.Character[self.LockPart]
                local targetPosition = targetPart.Position
                
                -- Apply prediction
                if self.MovementPrediction then
                    local humanoid = self.Locked.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        targetPosition = applyPrediction(targetPosition, humanoid.MoveDirection)
                    end
                end
                
                -- Apply miss percentage
                if shouldMiss() then
                    targetPosition = targetPosition + getRandomOffset(self.MissPercentage)
                end
                
                -- Apply humanized movement
                targetPosition = targetPosition + getHumanizedOffset()
                
                -- Apply recoil and spread compensation
                if self.RecoilControlEnabled then
                    targetPosition = targetPosition + self.recoilOffset * self.RecoilCompensation
                end
                
                if self.SpreadControlEnabled then
                    targetPosition = targetPosition + self.spreadOffset * self.SpreadCompensation
                end
                
                -- Move camera to target
                local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPosition)
                
                -- Apply smoothing
                targetCFrame = applySmoothing(Camera.CFrame, targetCFrame, self.SmoothingFactor)
                
                if self.Sensitivity > 0 then
                    local Animation = TweenService:Create(Camera, TweenInfo.new(self.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = targetCFrame})
                    Animation:Play()
                else
                    Camera.CFrame = targetCFrame
                end

                UserInputService.MouseDeltaSensitivity = 0

                self.FOVCircle.Color = self.FOV.LockedColor
                
                -- Update visual elements
                self:UpdateVisualElements(targetPosition)
            else
                -- Hide visual elements when no target
                self:HideVisualElements()
            end
        end
    end)
    
    -- Connect Input Handling
    self.ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
        pcall(function()
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[self.TriggerKey] then
                if self.Toggle then
                    self.Running = not self.Running

                    if not self.Running then
                        self:CancelLock()
                    end
                else
                    self.Running = true
                end
            end
            
            -- Handle trigger bot key
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[self.TriggerBotKey] or Input.UserInputType == Enum.UserInputType[self.TriggerBotKey] then
                self:HandleTriggerBot()
            end
        end)
    end)
    
    -- Connect recoil and spread tracking
    self.ServiceConnections.TrackingConnection = RunService.RenderStepped:Connect(function()
        self:TrackRecoil()
        self:TrackSpread()
    end)
    
    print("Advanced Aimbot Module loaded successfully!")
end

function AdvancedAimbot:Unload()
    -- Disconnect all connections
    for _, connection in pairs(self.ServiceConnections) do
        if connection then
            connection:Disconnect()
        end
    end
    
    -- Remove visual elements
    if self.FOVCircle then
        self.FOVCircle:Remove()
    end
    if self.targetHighlight then
        self.targetHighlight:Remove()
    end
    if self.targetLine then
        self.targetLine:Remove()
    end
    if self.hitMarker then
        self.hitMarker:Remove()
    end
    
    -- Reset variables
    self.Locked = nil
    self.Running = false
    self.ServiceConnections = {}
    
    print("Advanced Aimbot Module unloaded!")
end

-- Return the module
return AdvancedAimbot 
