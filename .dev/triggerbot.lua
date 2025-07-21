if not getgenv().FemboyHub then getgenv().FemboyHub = {} end
if getgenv().FemboyHub.Triggerbot then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


getgenv().FemboyHub.Triggerbot = {
    Settings = {
       
        Enabled = false,
        Hotkey = Enum.KeyCode.LeftAlt,
        Delay = 0.1, 
        
        
        Mode = "Hold", 
        TeamCheck = true,
        WallCheck = true,
        DistanceLimit = 500, 
        TargetParts = {
            "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" 
        },
        ReactionTime = {
            Enabled = true,
            Min = 0.01, 
            Max = 0.05  
        },
        Overshoot = {
            Enabled = false, 
            Chance = 20, 
            Distance = 15, 
            Delay = 0.05 
        }
    },
    Runtime = {
        IsActive = false,
        LastFire = 0,
        Typing = false
    },
    Functions = {}
}

local Environment = getgenv().FemboyHub.Triggerbot
local Settings = Environment.Settings
local Runtime = Environment.Runtime
local ServiceConnections = {}



ServiceConnections.RenderStepped = RunService.RenderStepped:Connect(function()
    if not Settings.Enabled or not Runtime.IsActive or Runtime.Typing then return end

    if (tick() - Runtime.LastFire) < Settings.Delay then return end

    local mousePos = UserInputService:GetMouseLocation()
    local unitRay = Camera:ScreenPointToRay(mousePos.X, mousePos.Y)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local rayResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * Settings.DistanceLimit, rayParams)

    local targetValid = false
    if rayResult and rayResult.Instance then
        local model = rayResult.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local player = Players:GetPlayerFromCharacter(model)
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            
            if player and player ~= LocalPlayer and humanoid and humanoid.Health > 0 then
                if not (Settings.TeamCheck and player.TeamColor == LocalPlayer.TeamColor) then
                    if table.find(Settings.TargetParts, rayResult.Instance.Name) then
                        targetValid = true
                    end
                end
            end
        end
    end
    
    if targetValid then
        
        if Settings.ReactionTime.Enabled then
            task.wait(math.random() * (Settings.ReactionTime.Max - Settings.ReactionTime.Min) + Settings.ReactionTime.Min)
        end

        
        if Settings.Overshoot.Enabled and math.random(1, 100) <= Settings.Overshoot.Chance then
            local x, y = math.random(-Settings.Overshoot.Distance, Settings.Overshoot.Distance), math.random(-Settings.Overshoot.Distance, Settings.Overshoot.Distance)
            pcall(mousemoverel, x, y)
            task.wait(Settings.Overshoot.Delay)
            pcall(mousemoverel, -x, -y)
            task.wait(0.01) 
        end

     
        pcall(mouse1press)
        task.wait(0.03)
        pcall(mouse1release)
        Runtime.LastFire = tick()
    end
end)


ServiceConnections.InputBegan = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.Hotkey then
        if Settings.Mode == "Toggle" then
            Runtime.IsActive = not Runtime.IsActive
        else -- hold
            Runtime.IsActive = true
        end
    end
end)

ServiceConnections.InputEnded = UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.Hotkey then
        if Settings.Mode == "Hold" then
            Runtime.IsActive = false
        end
    end
end)

ServiceConnections.TypingStarted = UserInputService.TextBoxFocused:Connect(function() Runtime.Typing = true end)
ServiceConnections.TypingEnded = UserInputService.TextBoxFocusReleased:Connect(function() Runtime.Typing = false end)


function Environment.Functions:Exit()
	for _, connection in pairs(ServiceConnections) do
		connection:Disconnect()
	end
	getgenv().FemboyHub.Triggerbot = nil
end

function Environment.Functions:Restart()
    -- this function is a placeholder; re executing the script is the most reliable way to restart.
end
