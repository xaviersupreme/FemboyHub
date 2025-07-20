
if not getgenv().FemboyHub then getgenv().FemboyHub = {} end
if getgenv().FemboyHub.PlayerMods then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer


getgenv().FemboyHub.PlayerMods = {
    Settings = {
        Fly = false,
        FlySpeed = 50,
        FlyKey = Enum.KeyCode.F,

        Noclip = false,
        NoclipKey = Enum.KeyCode.N,

        WalkSpeed = false,
        WalkSpeedValue = 32,

        JumpPower = false,
        JumpPowerValue = 75,

        Gravity = workspace.Gravity
    },
    Runtime = {
        IsFlying = false,
        FlyBodyGyro = nil,
        FlyBodyVelocity = nil,

        IsNoclipping = false,
        NoclipConnection = nil,

        OriginalWalkSpeed = 16,
        OriginalJumpPower = 50,
        OriginalGravity = workspace.Gravity
    }
}

local Environment = getgenv().FemboyHub.PlayerMods
local Settings = Environment.Settings
local Runtime = Environment.Runtime


local function UpdateFly(state)
    Runtime.IsFlying = state
    local char, root, hum = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not (char and root and hum) then return end

    if Runtime.IsFlying then
        if Runtime.FlyBodyGyro then Runtime.FlyBodyGyro:Destroy() end
        if Runtime.FlyBodyVelocity then Runtime.FlyBodyVelocity:Destroy() end
        Runtime.FlyBodyGyro = Instance.new("BodyGyro", root); Runtime.FlyBodyGyro.MaxTorque, Runtime.FlyBodyGyro.P = Vector3.new(math.huge, math.huge, math.huge), 20000
        Runtime.FlyBodyVelocity = Instance.new("BodyVelocity", root); Runtime.FlyBodyVelocity.MaxForce, Runtime.FlyBodyVelocity.P = Vector3.new(math.huge, math.huge, math.huge), 10000
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    else
        if Runtime.FlyBodyGyro then Runtime.FlyBodyGyro:Destroy(); Runtime.FlyBodyGyro = nil end
        if Runtime.FlyBodyVelocity then Runtime.FlyBodyVelocity:Destroy(); Runtime.FlyBodyVelocity = nil end
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end

local function UpdateNoclip(state)
    Runtime.IsNoclipping = state
    if Runtime.IsNoclipping then
        if Runtime.NoclipConnection then Runtime.NoclipConnection:Disconnect() end
        Runtime.NoclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    elseif Runtime.NoclipConnection then
        Runtime.NoclipConnection:Disconnect()
        Runtime.NoclipConnection = nil
    end
end


RunService.RenderStepped:Connect(function()
    pcall(function()
        if Runtime.IsFlying then
            local camCF, moveVector = workspace.CurrentCamera.CFrame, Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector -= camCF.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector -= camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += camCF.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector -= Vector3.new(0,1,0) end
            if Runtime.FlyBodyGyro then Runtime.FlyBodyGyro.CFrame = camCF end
            if Runtime.FlyBodyVelocity then Runtime.FlyBodyVelocity.Velocity = moveVector.Magnitude > 0 and moveVector.Unit * Settings.FlySpeed or Vector3.new(0,0,0) end
        end
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    local hum = character:WaitForChild("Humanoid")
    Runtime.OriginalWalkSpeed, Runtime.OriginalJumpPower = hum.WalkSpeed, hum.JumpPower
    
    if Settings.WalkSpeed then hum.WalkSpeed = Settings.WalkSpeedValue end
    if Settings.JumpPower then hum.JumpPower = Settings.JumpPowerValue end
    
    -- re apply fly/noclip state if it was active before death
    if Settings.Fly then UpdateFly(true) end
    if Settings.Noclip then UpdateNoclip(true) end
end)

-- initial setup
if LocalPlayer.Character then
    local hum = LocalPlayer.Character:WaitForChild("Humanoid")
    Runtime.OriginalWalkSpeed, Runtime.OriginalJumpPower = hum.WalkSpeed, hum.JumpPower
end

-- expose control functions to the getgenv table so the UI can call them
Environment.Functions = {
    UpdateFly = UpdateFly,
    UpdateNoclip = UpdateNoclip
}
