-- Aimbot Module Patch
-- Extends the existing FemboyHub aimbot module with advanced features

-- Wait for the aimbot module to load
local function waitForAimbot()
    local attempts = 0
    while not getgenv().AirHub or not getgenv().AirHub.Aimbot do
        task.wait(0.1)
        attempts = attempts + 1
        if attempts > 100 then
            warn("Aimbot module not found after 10 seconds")
            return false
        end
    end
    return true
end

if not waitForAimbot() then
    return
end

local Aimbot = getgenv().AirHub.Aimbot

-- Extend Aimbot Settings with new features
Aimbot.Settings.SmoothingEnabled = false
Aimbot.Settings.SmoothingFactor = 0.5
Aimbot.Settings.MovementPrediction = false
Aimbot.Settings.PredictionStrength = 0.3
Aimbot.Settings.AccelerationEnabled = false
Aimbot.Settings.AccelerationSpeed = 0.2
Aimbot.Settings.TargetPriority = "Closest to Crosshair"
Aimbot.Settings.DynamicFOV = false
Aimbot.Settings.MaxTargetDistance = 1000
Aimbot.Settings.MaxAngleToTarget = 180
Aimbot.Settings.TriggerBotEnabled = false
Aimbot.Settings.TriggerBotKey = "MouseButton1"
Aimbot.Settings.TriggerDelay = 50
Aimbot.Settings.BurstFire = false
Aimbot.Settings.BurstRounds = 3
Aimbot.Settings.MissPercentageEnabled = false
Aimbot.Settings.MissPercentage = 15
Aimbot.Settings.HumanLikeMovement = false
Aimbot.Settings.MovementRandomness = 0.2
Aimbot.Settings.ReactionTimeSimulation = false
Aimbot.Settings.ReactionTime = 150
Aimbot.Settings.RecoilControlEnabled = false
Aimbot.Settings.RecoilCompensation = 0.5
Aimbot.Settings.SpreadControlEnabled = false
Aimbot.Settings.SpreadCompensation = 0.3
Aimbot.Settings.AutoWeaponDetection = false
Aimbot.Settings.TargetHighlighting = false
Aimbot.Settings.TargetHighlightColor = Color3.fromRGB(255, 0, 0)
Aimbot.Settings.TargetInformation = false
Aimbot.Settings.HitMarkers = false
Aimbot.Settings.HitMarkerColor = Color3.fromRGB(0, 255, 0)
Aimbot.Settings.TargetLines = false
Aimbot.Settings.TargetLineColor = Color3.fromRGB(255, 255, 0)

-- Variables for advanced features
local lastTargetTime = 0
local currentTarget = nil
local burstCount = 0
local lastShotTime = 0
local recoilOffset = Vector3.new(0, 0, 0)
local spreadOffset = Vector3.new(0, 0, 0)
local targetHighlight = nil
local targetLine = nil
local hitMarker = nil

-- Utility functions
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
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(Aimbot.Settings.LockPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Basic checks
                if Aimbot.Settings.TeamCheck and player.TeamColor == localPlayer.TeamColor then
                    continue
                end
                
                if Aimbot.Settings.WallCheck then
                    local parts = camera:GetPartsObscuringTarget({player.Character[Aimbot.Settings.LockPart].Position}, player.Character:GetDescendants())
                    if #parts > 0 then
                        continue
                    end
                end
                
                -- Distance check
                local distance = (player.Character[Aimbot.Settings.LockPart].Position - localPlayer.Character[Aimbot.Settings.LockPart].Position).Magnitude
                if distance > Aimbot.Settings.MaxTargetDistance then
                    continue
                end
                
                -- Angle check
                local targetPos = camera:WorldToViewportPoint(player.Character[Aimbot.Settings.LockPart].Position)
                local mousePos = UserInputService:GetMouseLocation()
                local angle = math.deg(math.atan2(targetPos.Y - mousePos.Y, targetPos.X - mousePos.X))
                if math.abs(angle) > Aimbot.Settings.MaxAngleToTarget then
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
    if Aimbot.Settings.TargetPriority == "Closest to Crosshair" then
        table.sort(validTargets, function(a, b) return a.Angle < b.Angle end)
    elseif Aimbot.Settings.TargetPriority == "Closest to Player" then
        table.sort(validTargets, function(a, b) return a.Distance < b.Distance end)
    elseif Aimbot.Settings.TargetPriority == "Lowest Health" then
        table.sort(validTargets, function(a, b) return a.Health < b.Health end)
    elseif Aimbot.Settings.TargetPriority == "Moving Targets Only" then
        local movingTargets = {}
        for _, target in pairs(validTargets) do
            if target.IsMoving then
                table.insert(movingTargets, target)
            end
        end
        if #movingTargets > 0 then
            validTargets = movingTargets
        end
    elseif Aimbot.Settings.TargetPriority == "Random Selection" then
        return validTargets[math.random(1, #validTargets)].Player
    end
    
    return validTargets[1].Player
end

local function applySmoothing(currentCFrame, targetCFrame, smoothingFactor)
    if not Aimbot.Settings.SmoothingEnabled then
        return targetCFrame
    end
    
    return currentCFrame:Lerp(targetCFrame, smoothingFactor)
end

local function applyPrediction(targetPosition, targetVelocity)
    if not Aimbot.Settings.MovementPrediction then
        return targetPosition
    end
    
    local prediction = targetVelocity * Aimbot.Settings.PredictionStrength
    return targetPosition + prediction
end

local function shouldMiss()
    if not Aimbot.Settings.MissPercentageEnabled then
        return false
    end
    
    return math.random(1, 100) <= Aimbot.Settings.MissPercentage
end

local function getHumanizedOffset()
    if not Aimbot.Settings.HumanLikeMovement then
        return Vector3.new(0, 0, 0)
    end
    
    local randomness = Aimbot.Settings.MovementRandomness
    return Vector3.new(
        (math.random() - 0.5) * randomness * 10,
        (math.random() - 0.5) * randomness * 10,
        0
    )
end

local function checkReactionTime()
    if not Aimbot.Settings.ReactionTimeSimulation then
        return true
    end
    
    local currentTime = tick()
    if currentTime - lastTargetTime < (Aimbot.Settings.ReactionTime / 1000) then
        return false
    end
    
    lastTargetTime = currentTime
    return true
end

-- Override the original GetClosestPlayer function
local originalGetClosestPlayer = Aimbot.GetClosestPlayer
Aimbot.GetClosestPlayer = function()
    if not Aimbot.Locked then
        RequiredDistance = (Aimbot.FOVSettings.Enabled and Aimbot.FOVSettings.Amount or 2000)
        
        local target = getTargetPriority(Players:GetPlayers(), LocalPlayer, Camera)
        
        if target then
            local Vector, OnScreen = Camera:WorldToViewportPoint(target.Character[Aimbot.Settings.LockPart].Position)
            Vector = ConvertVector(Vector)
            local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude
            
            if Distance < RequiredDistance and OnScreen then
                RequiredDistance = Distance
                Aimbot.Locked = target
                currentTarget = target
            end
        end
    elseif (UserInputService:GetMouseLocation() - ConvertVector(Camera:WorldToViewportPoint(Aimbot.Locked.Character[Aimbot.Settings.LockPart].Position))).Magnitude > RequiredDistance then
        CancelLock()
    end
end

-- Override the original Load function to add new features
local originalLoad = Aimbot.Load
Aimbot.Load = function()
    originalLoad()
    
    -- Create visual elements
    if Aimbot.Settings.TargetHighlighting then
        targetHighlight = Drawing.new("Square")
        targetHighlight.Visible = false
        targetHighlight.Thickness = 2
        targetHighlight.Filled = false
        targetHighlight.Color = Aimbot.Settings.TargetHighlightColor
    end
    
    if Aimbot.Settings.TargetLines then
        targetLine = Drawing.new("Line")
        targetLine.Visible = false
        targetLine.Thickness = 1
        targetLine.Color = Aimbot.Settings.TargetLineColor
    end
    
    if Aimbot.Settings.HitMarkers then
        hitMarker = Drawing.new("Text")
        hitMarker.Visible = false
        hitMarker.Size = 20
        hitMarker.Center = true
        hitMarker.Color = Aimbot.Settings.HitMarkerColor
        hitMarker.Text = "X"
    end
    
    -- Override the RenderStepped connection
    ServiceConnections.RenderSteppedConnection:Disconnect()
    ServiceConnections.RenderSteppedConnection = RunService.RenderStepped:Connect(function()
        if Environment.FOVSettings.Enabled and Environment.Settings.Enabled then
            Environment.FOVCircle.Radius = Environment.FOVSettings.Amount
            Environment.FOVCircle.Thickness = Environment.FOVSettings.Thickness
            Environment.FOVCircle.Filled = Environment.FOVSettings.Filled
            Environment.FOVCircle.NumSides = Environment.FOVSettings.Sides
            Environment.FOVCircle.Color = Environment.FOVSettings.Color
            Environment.FOVCircle.Transparency = Environment.FOVSettings.Transparency
            Environment.FOVCircle.Visible = Environment.FOVSettings.Visible
            Environment.FOVCircle.Position = Vector2new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y)
        else
            Environment.FOVCircle.Visible = false
        end

        if Running and Environment.Settings.Enabled then
            Aimbot.GetClosestPlayer()

            if Aimbot.Locked and checkReactionTime() then
                local targetPart = Aimbot.Locked.Character[Aimbot.Settings.LockPart]
                local targetPosition = targetPart.Position
                
                -- Apply prediction
                if Aimbot.Settings.MovementPrediction then
                    local humanoid = Aimbot.Locked.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        targetPosition = applyPrediction(targetPosition, humanoid.MoveDirection)
                    end
                end
                
                -- Apply miss percentage
                if shouldMiss() then
                    targetPosition = targetPosition + getRandomOffset(Aimbot.Settings.MissPercentage)
                end
                
                -- Apply humanized movement
                targetPosition = targetPosition + getHumanizedOffset()
                
                -- Apply recoil and spread compensation
                if Aimbot.Settings.RecoilControlEnabled then
                    targetPosition = targetPosition + recoilOffset * Aimbot.Settings.RecoilCompensation
                end
                
                if Aimbot.Settings.SpreadControlEnabled then
                    targetPosition = targetPosition + spreadOffset * Aimbot.Settings.SpreadCompensation
                end
                
                if Environment.Settings.ThirdPerson then
                    local Vector = Camera:WorldToViewportPoint(targetPosition)
                    mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
                else
                    local targetCFrame = CFramenew(Camera.CFrame.Position, targetPosition)
                    
                    -- Apply smoothing
                    targetCFrame = applySmoothing(Camera.CFrame, targetCFrame, Aimbot.Settings.SmoothingFactor)
                    
                    if Environment.Settings.Sensitivity > 0 then
                        Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = targetCFrame})
                        Animation:Play()
                    else
                        Camera.CFrame = targetCFrame
                    end

                    UserInputService.MouseDeltaSensitivity = 0
                end

                Environment.FOVCircle.Color = Environment.FOVSettings.LockedColor
                
                -- Update visual elements
                if targetHighlight and Aimbot.Settings.TargetHighlighting then
                    local screenPos = Camera:WorldToViewportPoint(targetPosition)
                    targetHighlight.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                    targetHighlight.Size = Vector2.new(40, 40)
                    targetHighlight.Visible = true
                end
                
                if targetLine and Aimbot.Settings.TargetLines then
                    local screenPos = Camera:WorldToViewportPoint(targetPosition)
                    targetLine.From = UserInputService:GetMouseLocation()
                    targetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                    targetLine.Visible = true
                end
            else
                -- Hide visual elements when no target
                if targetHighlight then targetHighlight.Visible = false end
                if targetLine then targetLine.Visible = false end
            end
        end
    end)
end

-- Add trigger bot functionality
local function handleTriggerBot()
    if not Aimbot.Settings.TriggerBotEnabled then
        return
    end
    
    if Aimbot.Locked then
        local currentTime = tick()
        
        -- Check trigger delay
        if currentTime - lastShotTime < (Aimbot.Settings.TriggerDelay / 1000) then
            return
        end
        
        -- Handle burst fire
        if Aimbot.Settings.BurstFire and burstCount < Aimbot.Settings.BurstRounds then
            mouse1click()
            burstCount = burstCount + 1
            lastShotTime = currentTime
            
            -- Show hit marker
            if hitMarker and Aimbot.Settings.HitMarkers then
                hitMarker.Position = UserInputService:GetMouseLocation()
                hitMarker.Visible = true
                task.delay(0.5, function()
                    hitMarker.Visible = false
                end)
            end
        elseif not Aimbot.Settings.BurstFire then
            mouse1click()
            lastShotTime = currentTime
            
            -- Show hit marker
            if hitMarker and Aimbot.Settings.HitMarkers then
                hitMarker.Position = UserInputService:GetMouseLocation()
                hitMarker.Visible = true
                task.delay(0.5, function()
                    hitMarker.Visible = false
                end)
            end
        end
    else
        burstCount = 0
    end
end

-- Add trigger bot to input handling
local originalInputBegan = ServiceConnections.InputBeganConnection
ServiceConnections.InputBeganConnection = UserInputService.InputBegan:Connect(function(Input)
    if not Typing then
        pcall(function()
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[#Environment.Settings.TriggerKey == 1 and stringupper(Environment.Settings.TriggerKey) or Environment.Settings.TriggerKey] or Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
                if Environment.Settings.Toggle then
                    Running = not Running

                    if not Running then
                        CancelLock()
                    end
                else
                    Running = true
                end
            end
            
            -- Handle trigger bot key
            if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[Aimbot.Settings.TriggerBotKey] or Input.UserInputType == Enum.UserInputType[Aimbot.Settings.TriggerBotKey] then
                handleTriggerBot()
            end
        end)
    end
end)

-- Add recoil tracking
local function trackRecoil()
    if not Aimbot.Settings.RecoilControlEnabled then
        return
    end
    
    -- Simulate recoil pattern (this would need to be customized per weapon)
    local currentTime = tick()
    recoilOffset = Vector3.new(
        math.sin(currentTime * 10) * 0.1,
        math.cos(currentTime * 8) * 0.15,
        0
    )
end

-- Add spread tracking
local function trackSpread()
    if not Aimbot.Settings.SpreadControlEnabled then
        return
    end
    
    -- Simulate spread pattern
    spreadOffset = Vector3.new(
        (math.random() - 0.5) * 0.2,
        (math.random() - 0.5) * 0.2,
        0
    )
end

-- Connect recoil and spread tracking
RunService.RenderStepped:Connect(function()
    trackRecoil()
    trackSpread()
end)

print("Aimbot module successfully patched with advanced features!") 