--// Cache

local pcall, getgenv, next, setmetatable, Vector2new, CFramenew, Color3fromRGB, Drawingnew, TweenInfonew, stringupper, mousemoverel = pcall, getgenv, next, setmetatable, Vector2.new, CFrame.new, Color3.fromRGB, Drawing.new, TweenInfo.new, string.upper, mousemoverel or (Input and Input.MouseMove)

--// Launching checks

if not getgenv().AirHub or getgenv().AirHub.Aimbot then return end

--// Services

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Variables

local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}

--// Environment

getgenv().AirHub.Aimbot = {
	Settings = {
		Enabled = false,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0, -- Animation length (in seconds) before fully locking onto target
		ThirdPerson = false, -- Uses mousemoverel instead of CFrame to support locking in third person (could be choppy)
		ThirdPersonSensitivity = 3,
		TriggerKey = "MouseButton2",
		Toggle = false,
		LockPart = "Head", -- Body part to lock on
		
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
		TargetHighlightColor = Color3fromRGB(255, 0, 0),
		TargetInformation = false,
		HitMarkers = false,
		HitMarkerColor = Color3fromRGB(0, 255, 0),
		TargetLines = false,
		TargetLineColor = Color3fromRGB(255, 255, 0),
		
		-- Internal Variables
		lastTargetTime = 0,
		currentTarget = nil,
		burstCount = 0,
		lastShotTime = 0,
		recoilOffset = Vector3.new(0, 0, 0),
		spreadOffset = Vector3.new(0, 0, 0),
		targetHighlight = nil,
		targetLine = nil,
		hitMarker = nil
	},

	FOVSettings = {
		Enabled = true,
		Visible = true,
		Amount = 90,
		Color = Color3fromRGB(255, 255, 255),
		LockedColor = Color3fromRGB(255, 70, 70),
		Transparency = 0.5,
		Sides = 30,
		Thickness = 1,
		Filled = false
	},

	FOVCircle = Drawingnew("Circle")
}

local Environment = getgenv().AirHub.Aimbot

--// Utility Functions

local function ConvertVector(Vector)
	return Vector2new(Vector.X, Vector.Y)
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
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild(Environment.Settings.LockPart) then
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                -- Basic checks
                if Environment.Settings.TeamCheck and player.TeamColor == localPlayer.TeamColor then
                    continue
                end
                
                if Environment.Settings.WallCheck then
                    local parts = camera:GetPartsObscuringTarget({player.Character[Environment.Settings.LockPart].Position}, player.Character:GetDescendants())
                    if #parts > 0 then
                        continue
                    end
                end
                
                -- Distance check
                local distance = (player.Character[Environment.Settings.LockPart].Position - localPlayer.Character[Environment.Settings.LockPart].Position).Magnitude
                if distance > Environment.Settings.MaxTargetDistance then
                    continue
                end
                
                -- Angle check
                local targetPos = camera:WorldToViewportPoint(player.Character[Environment.Settings.LockPart].Position)
                local mousePos = UserInputService:GetMouseLocation()
                local angle = math.deg(math.atan2(targetPos.Y - mousePos.Y, targetPos.X - mousePos.X))
                if math.abs(angle) > Environment.Settings.MaxAngleToTarget then
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
    if Environment.Settings.TargetPriority == "Closest to Crosshair" then
        table.sort(validTargets, function(a, b) return a.Angle < b.Angle end)
    elseif Environment.Settings.TargetPriority == "Closest to Player" then
        table.sort(validTargets, function(a, b) return a.Distance < b.Distance end)
    elseif Environment.Settings.TargetPriority == "Lowest Health" then
        table.sort(validTargets, function(a, b) return a.Health < b.Health end)
    elseif Environment.Settings.TargetPriority == "Moving Targets Only" then
        local movingTargets = {}
        for _, target in pairs(validTargets) do
            if target.IsMoving then
                table.insert(movingTargets, target)
            end
        end
        if #movingTargets > 0 then
            validTargets = movingTargets
        end
    elseif Environment.Settings.TargetPriority == "Random Selection" then
        return validTargets[math.random(1, #validTargets)].Player
    end
    
    return validTargets[1].Player
end

local function applySmoothing(currentCFrame, targetCFrame, smoothingFactor)
    if not Environment.Settings.SmoothingEnabled then
        return targetCFrame
    end
    
    return currentCFrame:Lerp(targetCFrame, smoothingFactor)
end

local function applyPrediction(targetPosition, targetVelocity)
    if not Environment.Settings.MovementPrediction then
        return targetPosition
    end
    
    local prediction = targetVelocity * Environment.Settings.PredictionStrength
    return targetPosition + prediction
end

local function shouldMiss()
    if not Environment.Settings.MissPercentageEnabled then
        return false
    end
    
    return math.random(1, 100) <= Environment.Settings.MissPercentage
end

local function getHumanizedOffset()
    if not Environment.Settings.HumanLikeMovement then
        return Vector3.new(0, 0, 0)
    end
    
    local randomness = Environment.Settings.MovementRandomness
    return Vector3.new(
        (math.random() - 0.5) * randomness * 10,
        (math.random() - 0.5) * randomness * 10,
        0
    )
end

local function checkReactionTime()
    if not Environment.Settings.ReactionTimeSimulation then
        return true
    end
    
    local currentTime = tick()
    if currentTime - Environment.Settings.lastTargetTime < (Environment.Settings.ReactionTime / 1000) then
        return false
    end
    
    Environment.Settings.lastTargetTime = currentTime
    return true
end

local function handleTriggerBot()
    if not Environment.Settings.TriggerBotEnabled then
        return
    end
    
    if Environment.Locked then
        local currentTime = tick()
        
        -- Check trigger delay
        if currentTime - Environment.Settings.lastShotTime < (Environment.Settings.TriggerDelay / 1000) then
            return
        end
        
        -- Handle burst fire
        if Environment.Settings.BurstFire and Environment.Settings.burstCount < Environment.Settings.BurstRounds then
            mouse1click()
            Environment.Settings.burstCount = Environment.Settings.burstCount + 1
            Environment.Settings.lastShotTime = currentTime
            
            -- Show hit marker
            if Environment.Settings.hitMarker and Environment.Settings.HitMarkers then
                Environment.Settings.hitMarker.Position = UserInputService:GetMouseLocation()
                Environment.Settings.hitMarker.Visible = true
                task.delay(0.5, function()
                    Environment.Settings.hitMarker.Visible = false
                end)
            end
        elseif not Environment.Settings.BurstFire then
            mouse1click()
            Environment.Settings.lastShotTime = currentTime
            
            -- Show hit marker
            if Environment.Settings.hitMarker and Environment.Settings.HitMarkers then
                Environment.Settings.hitMarker.Position = UserInputService:GetMouseLocation()
                Environment.Settings.hitMarker.Visible = true
                task.delay(0.5, function()
                    Environment.Settings.hitMarker.Visible = false
                end)
            end
        end
    else
        Environment.Settings.burstCount = 0
    end
end

local function trackRecoil()
    if not Environment.Settings.RecoilControlEnabled then
        return
    end
    
    -- Simulate recoil pattern
    local currentTime = tick()
    Environment.Settings.recoilOffset = Vector3.new(
        math.sin(currentTime * 10) * 0.1,
        math.cos(currentTime * 8) * 0.15,
        0
    )
end

local function trackSpread()
    if not Environment.Settings.SpreadControlEnabled then
        return
    end
    
    -- Simulate spread pattern
    Environment.Settings.spreadOffset = Vector3.new(
        (math.random() - 0.5) * 0.2,
        (math.random() - 0.5) * 0.2,
        0
    )
end

local function updateVisualElements(targetPosition)
    -- Update target highlighting
    if Environment.Settings.targetHighlight and Environment.Settings.TargetHighlighting then
        local screenPos = Camera:WorldToViewportPoint(targetPosition)
        Environment.Settings.targetHighlight.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
        Environment.Settings.targetHighlight.Size = Vector2.new(40, 40)
        Environment.Settings.targetHighlight.Visible = true
    end
    
    -- Update target lines
    if Environment.Settings.targetLine and Environment.Settings.TargetLines then
        local screenPos = Camera:WorldToViewportPoint(targetPosition)
        Environment.Settings.targetLine.From = UserInputService:GetMouseLocation()
        Environment.Settings.targetLine.To = Vector2.new(screenPos.X, screenPos.Y)
        Environment.Settings.targetLine.Visible = true
    end
end

local function hideVisualElements()
    if Environment.Settings.targetHighlight then
        Environment.Settings.targetHighlight.Visible = false
    end
    if Environment.Settings.targetLine then
        Environment.Settings.targetLine.Visible = false
    end
end

--// Core Functions

local function CancelLock()
	Environment.Locked = nil
	Environment.Settings.currentTarget = nil
	Environment.Settings.burstCount = 0
	Environment.FOVCircle.Color = Environment.FOVSettings.Color
	UserInputService.MouseDeltaSensitivity = OriginalSensitivity

	if Animation then
		Animation:Cancel()
	end
	
	hideVisualElements()
end

local function GetClosestPlayer()
	if not Environment.Locked then
		RequiredDistance = (Environment.FOVSettings.Enabled and Environment.FOVSettings.Amount or 2000)

		-- Use advanced target priority if enabled
		if Environment.Settings.TargetPriority and Environment.Settings.TargetPriority ~= "Closest to Crosshair" then
			local target = getTargetPriority(Players:GetPlayers(), LocalPlayer, Camera)
			if target then
				local Vector, OnScreen = Camera:WorldToViewportPoint(target.Character[Environment.Settings.LockPart].Position); Vector = ConvertVector(Vector)
				local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude
				
				if Distance < RequiredDistance and OnScreen then
					RequiredDistance = Distance
					Environment.Locked = target
					Environment.Settings.currentTarget = target
				end
			end
		else
			-- Original targeting logic
			for _, v in next, Players:GetPlayers() do
				if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Environment.Settings.LockPart) and v.Character:FindFirstChildOfClass("Humanoid") then
					if Environment.Settings.TeamCheck and v.TeamColor == LocalPlayer.TeamColor then continue end
					if Environment.Settings.AliveCheck and v.Character:FindFirstChildOfClass("Humanoid").Health <= 0 then continue end
					if Environment.Settings.WallCheck and #(Camera:GetPartsObscuringTarget({v.Character[Environment.Settings.LockPart].Position}, v.Character:GetDescendants())) > 0 then continue end

					local Vector, OnScreen = Camera:WorldToViewportPoint(v.Character[Environment.Settings.LockPart].Position); Vector = ConvertVector(Vector)
					local Distance = (UserInputService:GetMouseLocation() - Vector).Magnitude

					if Distance < RequiredDistance and OnScreen then
						RequiredDistance = Distance
						Environment.Locked = v
						Environment.Settings.currentTarget = v
					end
				end
			end
		end
	elseif (UserInputService:GetMouseLocation() - ConvertVector(Camera:WorldToViewportPoint(Environment.Locked.Character[Environment.Settings.LockPart].Position))).Magnitude > RequiredDistance then
		CancelLock()
	end
end

local function Load()
	OriginalSensitivity = UserInputService.MouseDeltaSensitivity

	-- Create visual elements
	if Environment.Settings.TargetHighlighting then
		Environment.Settings.targetHighlight = Drawingnew("Square")
		Environment.Settings.targetHighlight.Visible = false
		Environment.Settings.targetHighlight.Thickness = 2
		Environment.Settings.targetHighlight.Filled = false
		Environment.Settings.targetHighlight.Color = Environment.Settings.TargetHighlightColor
	end
	
	if Environment.Settings.TargetLines then
		Environment.Settings.targetLine = Drawingnew("Line")
		Environment.Settings.targetLine.Visible = false
		Environment.Settings.targetLine.Thickness = 1
		Environment.Settings.targetLine.Color = Environment.Settings.TargetLineColor
	end
	
	if Environment.Settings.HitMarkers then
		Environment.Settings.hitMarker = Drawingnew("Text")
		Environment.Settings.hitMarker.Visible = false
		Environment.Settings.hitMarker.Size = 20
		Environment.Settings.hitMarker.Center = true
		Environment.Settings.hitMarker.Color = Environment.Settings.HitMarkerColor
		Environment.Settings.hitMarker.Text = "X"
	end

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
			GetClosestPlayer()

			if Environment.Locked and checkReactionTime() then
				local targetPart = Environment.Locked.Character[Environment.Settings.LockPart]
				local targetPosition = targetPart.Position
				
				-- Apply prediction
				if Environment.Settings.MovementPrediction then
					local humanoid = Environment.Locked.Character:FindFirstChildOfClass("Humanoid")
					if humanoid then
						targetPosition = applyPrediction(targetPosition, humanoid.MoveDirection)
					end
				end
				
				-- Apply miss percentage
				if shouldMiss() then
					targetPosition = targetPosition + getRandomOffset(Environment.Settings.MissPercentage)
				end
				
				-- Apply humanized movement
				targetPosition = targetPosition + getHumanizedOffset()
				
				-- Apply recoil and spread compensation
				if Environment.Settings.RecoilControlEnabled then
					targetPosition = targetPosition + Environment.Settings.recoilOffset * Environment.Settings.RecoilCompensation
				end
				
				if Environment.Settings.SpreadControlEnabled then
					targetPosition = targetPosition + Environment.Settings.spreadOffset * Environment.Settings.SpreadCompensation
				end
				
				if Environment.Settings.ThirdPerson then
					local Vector = Camera:WorldToViewportPoint(targetPosition)
					mousemoverel((Vector.X - UserInputService:GetMouseLocation().X) * Environment.Settings.ThirdPersonSensitivity, (Vector.Y - UserInputService:GetMouseLocation().Y) * Environment.Settings.ThirdPersonSensitivity)
				else
					-- Move camera to target
					local targetCFrame = CFramenew(Camera.CFrame.Position, targetPosition)
					
					-- Apply smoothing
					targetCFrame = applySmoothing(Camera.CFrame, targetCFrame, Environment.Settings.SmoothingFactor)
					
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
				updateVisualElements(targetPosition)
			else
				-- Hide visual elements when no target
				hideVisualElements()
			end
		end
		
		-- Track recoil and spread
		trackRecoil()
		trackSpread()
	end)

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
				if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[Environment.Settings.TriggerBotKey] or Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerBotKey] then
					handleTriggerBot()
				end
			end)
		end
	end)

	ServiceConnections.InputEndedConnection = UserInputService.InputEnded:Connect(function(Input)
		if not Typing then
			if not Environment.Settings.Toggle then
				pcall(function()
					if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == Enum.KeyCode[#Environment.Settings.TriggerKey == 1 and stringupper(Environment.Settings.TriggerKey) or Environment.Settings.TriggerKey] or Input.UserInputType == Enum.UserInputType[Environment.Settings.TriggerKey] then
						Running = false; CancelLock()
					end
				end)
			end
		end
	end)
end

--// Typing Check

ServiceConnections.TypingStartedConnection = UserInputService.TextBoxFocused:Connect(function()
	Typing = true
end)

ServiceConnections.TypingEndedConnection = UserInputService.TextBoxFocusReleased:Connect(function()
	Typing = false
end)

--// Functions

Environment.Functions = {}

function Environment.Functions:Exit()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	Environment.FOVCircle:Remove()
	
	-- Remove visual elements
	if Environment.Settings.targetHighlight then
		Environment.Settings.targetHighlight:Remove()
	end
	if Environment.Settings.targetLine then
		Environment.Settings.targetLine:Remove()
	end
	if Environment.Settings.hitMarker then
		Environment.Settings.hitMarker:Remove()
	end

	getgenv().AirHub.Aimbot.Functions = nil
	getgenv().AirHub.Aimbot = nil

	Load = nil; ConvertVector = nil; CancelLock = nil; GetClosestPlayer = nil;
end

function Environment.Functions:Restart()
	for _, v in next, ServiceConnections do
		v:Disconnect()
	end

	Load()
end

function Environment.Functions:ResetSettings()
	Environment.Settings = {
		Enabled = false,
		TeamCheck = false,
		AliveCheck = true,
		WallCheck = false,
		Sensitivity = 0,
		ThirdPerson = false,
		ThirdPersonSensitivity = 3,
		TriggerKey = "MouseButton2",
		Toggle = false,
		LockPart = "Head",
		
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
		TargetHighlightColor = Color3fromRGB(255, 0, 0),
		TargetInformation = false,
		HitMarkers = false,
		HitMarkerColor = Color3fromRGB(0, 255, 0),
		TargetLines = false,
		TargetLineColor = Color3fromRGB(255, 255, 0),
		
		-- Internal Variables
		lastTargetTime = 0,
		currentTarget = nil,
		burstCount = 0,
		lastShotTime = 0,
		recoilOffset = Vector3.new(0, 0, 0),
		spreadOffset = Vector3.new(0, 0, 0),
		targetHighlight = nil,
		targetLine = nil,
		hitMarker = nil
	}

	Environment.FOVSettings = {
		Enabled = true,
		Visible = true,
		Amount = 90,
		Color = Color3fromRGB(255, 255, 255),
		LockedColor = Color3fromRGB(255, 70, 70),
		Transparency = 0.5,
		Sides = 30,
		Thickness = 1,
		Filled = false
	}
end

setmetatable(Environment.Functions, {
	__newindex = warn
})

--// Load

Load()
