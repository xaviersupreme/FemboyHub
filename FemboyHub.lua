-- env and module loader
getgenv().AirHub = {}

-- load the core logic modules
pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/xaviersupreme/venuslibtest/refs/heads/main/modules/aimbot.lua"))() end)
pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/xaviersupreme/venuslibtest/refs/heads/main/modules/esp.lua"))() end)

-- splix ui shit
local SplixLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/SplixUiLib/main/Main"))()
if not SplixLib or not SplixLib.new then
    warn("FEMBOY HUB: CRITICAL FAILURE - Could not load Splix UI Library.")
    return
end

-- services and refs

task.wait(0.5) -- wait for modules to populate the env
local Aimbot, WallHack = getgenv().AirHub.Aimbot, getgenv().AirHub.WallHack
if not (Aimbot and WallHack) then
    warn("CRITICAL FAILURE - AirHub modules did not load correctly. The script cannot continue.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Parts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
local Fonts = {"UI", "System", "Plex", "Monospace"}
local TracersType = {"Bottom", "Center", "Mouse"}
local HealthBarPos = {"Top", "Bottom", "Left", "Right"}

-- runtime variables for player mods
local IsFlying = false
local FlyBodyGyro, FlyBodyVelocity = nil, nil
local OriginalWalkSpeed, OriginalJumpPower = 16, 50
getgenv().Player_FlySpeed = 50
getgenv().Player_FlyKey = Enum.KeyCode.F
getgenv().Player_WalkSpeedValue = 32
getgenv().Player_JumpPowerValue = 75

-- ui deffinitiotdkgdnkand

local Window = SplixLib:new({
    textsize = 13,
    font = Enum.Font.RobotoMono,
    name = "Femboy Hub",
    color = Color3.fromRGB(255, 182, 193) --  theme (soft pink)
})

local AimbotTab = Window:page({name = "Aimbot"})
local VisualsTab = Window:page({name = "Visuals"})
local CrosshairTab = Window:page({name = "Crosshair"})
local PlayerTab = Window:page({name = "Player Mods"})
local FunctionsTab = Window:page({name = "Functions"})


-- aimbot tab  shit

local AimbotValuesSection = AimbotTab:section({name = "Values", side = "left", size = 200})
local AimbotChecksSection = AimbotTab:section({name = "Checks", side = "left", size = 120})
local AimbotThirdPersonSection = AimbotTab:section({name = "Third Person", side = "left", size = 90})
local FOVValuesSection = AimbotTab:section({name = "Field Of View", side = "right", size = 120})
local FOVAppearanceSection = AimbotTab:section({name = "FOV Circle Appearance", side = "right", size = 220})

AimbotValuesSection:toggle({name = "Enable Aimbot", def = Aimbot.Settings.Enabled, callback = function(v) Aimbot.Settings.Enabled = v end})
AimbotValuesSection:toggle({name = "Toggle Mode", def = Aimbot.Settings.Toggle, callback = function(v) Aimbot.Settings.Toggle = v end})
AimbotValuesSection:dropdown({name = "Lock Part", def = Aimbot.Settings.LockPart, max = #Parts, options = Parts, callback = function(v) Aimbot.Settings.LockPart = v end})
AimbotValuesSection:textbox({name = "Hotkey", def = Aimbot.Settings.TriggerKey, placeholder = "MouseButton2, E, etc.", callback = function(v) Aimbot.Settings.TriggerKey = v end})
AimbotValuesSection:slider({name = "Smoothing", def = Aimbot.Settings.Sensitivity, max = 2, min = 0, rounding = false, measuring = "s", callback = function(v) Aimbot.Settings.Sensitivity = v end})

AimbotChecksSection:toggle({name = "Team Check", def = Aimbot.Settings.TeamCheck, callback = function(v) Aimbot.Settings.TeamCheck = v end})
AimbotChecksSection:toggle({name = "Wall Check", def = Aimbot.Settings.WallCheck, callback = function(v) Aimbot.Settings.WallCheck = v end})
AimbotChecksSection:toggle({name = "Alive Check", def = Aimbot.Settings.AliveCheck, callback = function(v) Aimbot.Settings.AliveCheck = v end})

AimbotThirdPersonSection:toggle({name = "Enable Third Person", def = Aimbot.Settings.ThirdPerson, callback = function(v) Aimbot.Settings.ThirdPerson = v end})
AimbotThirdPersonSection:slider({name = "3P Sensitivity", def = Aimbot.Settings.ThirdPersonSensitivity, max = 5, min = 0.1, rounding = false, callback = function(v) Aimbot.Settings.ThirdPersonSensitivity = v end})

FOVValuesSection:toggle({name = "Enable FOV", def = Aimbot.FOVSettings.Enabled, callback = function(v) Aimbot.FOVSettings.Enabled = v end})
FOVValuesSection:toggle({name = "Visible", def = Aimbot.FOVSettings.Visible, callback = function(v) Aimbot.FOVSettings.Visible = v end})
FOVValuesSection:slider({name = "Amount (Radius)", def = Aimbot.FOVSettings.Amount, max = 500, min = 10, rounding = true, callback = function(v) Aimbot.FOVSettings.Amount = v end})

FOVAppearanceSection:toggle({name = "Filled", def = Aimbot.FOVSettings.Filled, callback = function(v) Aimbot.FOVSettings.Filled = v end})
FOVAppearanceSection:slider({name = "Transparency", def = Aimbot.FOVSettings.Transparency, max = 1, min = 0, rounding = false, callback = function(v) Aimbot.FOVSettings.Transparency = v end})
FOVAppearanceSection:slider({name = "Sides", def = Aimbot.FOVSettings.Sides, max = 60, min = 3, rounding = true, callback = function(v) Aimbot.FOVSettings.Sides = v end})
FOVAppearanceSection:slider({name = "Thickness", def = Aimbot.FOVSettings.Thickness, max = 10, min = 1, rounding = true, callback = function(v) Aimbot.FOVSettings.Thickness = v end})
FOVAppearanceSection:colorpicker({name = "Color", def = Aimbot.FOVSettings.Color, callback = function(v) Aimbot.FOVSettings.Color = v end})
FOVAppearanceSection:colorpicker({name = "Locked Color", def = Aimbot.FOVSettings.LockedColor, callback = function(v) Aimbot.FOVSettings.LockedColor = v end})


-- esp tab stuff

local ESPChecksSection = VisualsTab:section({name = "Checks", side = "left", size = 120})
local ESPSettingsSection = VisualsTab:section({name = "ESP Settings", side = "left", size = 320})
local BoxesSettingsSection = VisualsTab:section({name = "Boxes Settings", side = "left", size = 250})
local ChamsSettingsSection = VisualsTab:section({name = "Chams Settings", side = "right", size = 220})
local TracersSettingsSection = VisualsTab:section({name = "Tracers Settings", side = "right", size = 150})
local HeadDotsSettingsSection = VisualsTab:section({name = "Head Dots", side = "right", size = 220})
local HealthBarSettingsSection = VisualsTab:section({name = "Health Bar", side = "right", size = 220})

ESPChecksSection:toggle({name = "Enable Visuals", def = WallHack.Settings.Enabled, callback = function(v) WallHack.Settings.Enabled = v end})
ESPChecksSection:toggle({name = "Team Check", def = WallHack.Settings.TeamCheck, callback = function(v) WallHack.Settings.TeamCheck = v end})
ESPChecksSection:toggle({name = "Alive Check", def = WallHack.Settings.AliveCheck, callback = function(v) WallHack.Settings.AliveCheck = v end})

ESPSettingsSection:toggle({name = "Enable Text ESP", def = WallHack.Visuals.ESPSettings.Enabled, callback = function(v) WallHack.Visuals.ESPSettings.Enabled = v end})
ESPSettingsSection:toggle({name = "Outline", def = WallHack.Visuals.ESPSettings.Outline, callback = function(v) WallHack.Visuals.ESPSettings.Outline = v end})
ESPSettingsSection:toggle({name = "Display Distance", def = WallHack.Visuals.ESPSettings.DisplayDistance, callback = function(v) WallHack.Visuals.ESPSettings.DisplayDistance = v end})
ESPSettingsSection:toggle({name = "Display Health", def = WallHack.Visuals.ESPSettings.DisplayHealth, callback = function(v) WallHack.Visuals.ESPSettings.DisplayHealth = v end})
ESPSettingsSection:toggle({name = "Display Name", def = WallHack.Visuals.ESPSettings.DisplayName, callback = function(v) WallHack.Visuals.ESPSettings.DisplayName = v end})
ESPSettingsSection:slider({name = "Text Offset", def = WallHack.Visuals.ESPSettings.Offset, max = 50, min = -50, rounding = true, callback = function(v) WallHack.Visuals.ESPSettings.Offset = v end})
ESPSettingsSection:colorpicker({name = "Text Color", def = WallHack.Visuals.ESPSettings.TextColor, callback = function(v) WallHack.Visuals.ESPSettings.TextColor = v end})
ESPSettingsSection:colorpicker({name = "Outline Color", def = WallHack.Visuals.ESPSettings.OutlineColor, callback = function(v) WallHack.Visuals.ESPSettings.OutlineColor = v end})
ESPSettingsSection:slider({name = "Text Size", def = WallHack.Visuals.ESPSettings.TextSize, max = 24, min = 8, rounding = true, callback = function(v) WallHack.Visuals.ESPSettings.TextSize = v end})
ESPSettingsSection:slider({name = "Text Transparency", def = WallHack.Visuals.ESPSettings.TextTransparency, max = 1, min = 0, rounding = false, callback = function(v) WallHack.Visuals.ESPSettings.TextTransparency = v end})
ESPSettingsSection:dropdown({name = "Font", def = "UI", max = #Fonts, options = Fonts, callback = function(v) WallHack.Visuals.ESPSettings.TextFont = Drawing.Fonts[v] end})

BoxesSettingsSection:toggle({name = "Enable Boxes", def = WallHack.Visuals.BoxSettings.Enabled, callback = function(v) WallHack.Visuals.BoxSettings.Enabled = v end})
BoxesSettingsSection:toggle({name = "Filled (2D)", def = WallHack.Visuals.BoxSettings.Filled, callback = function(v) WallHack.Visuals.BoxSettings.Filled = v end})
BoxesSettingsSection:dropdown({name = "Box Type", def = "3D", max = 2, options = {"3D", "2D"}, callback = function(v) WallHack.Visuals.BoxSettings.Type = (v == "3D" and 1 or 2) end})
BoxesSettingsSection:colorpicker({name = "Box Color", def = WallHack.Visuals.BoxSettings.Color, callback = function(v) WallHack.Visuals.BoxSettings.Color = v end})
BoxesSettingsSection:slider({name = "Thickness", def = WallHack.Visuals.BoxSettings.Thickness, max = 5, min = 1, rounding = true, callback = function(v) WallHack.Visuals.BoxSettings.Thickness = v end})
BoxesSettingsSection:slider({name = "Transparency", def = WallHack.Visuals.BoxSettings.Transparency, max = 1, min = 0, rounding = false, callback = function(v) WallHack.Visuals.BoxSettings.Transparency = v end})
BoxesSettingsSection:slider({name = "Scale Increase (3D)", def = WallHack.Visuals.BoxSettings.Increase, max = 5, min = 1, rounding = true, callback = function(v) WallHack.Visuals.BoxSettings.Increase = v end})

ChamsSettingsSection:toggle({name = "Enable Chams", def = WallHack.Visuals.ChamsSettings.Enabled, callback = function(v) WallHack.Visuals.ChamsSettings.Enabled = v end})
ChamsSettingsSection:toggle({name = "Filled", def = WallHack.Visuals.ChamsSettings.Filled, callback = function(v) WallHack.Visuals.ChamsSettings.Filled = v end})
ChamsSettingsSection:toggle({name = "Entire Body (R15)", def = WallHack.Visuals.ChamsSettings.EntireBody, callback = function(v) WallHack.Visuals.ChamsSettings.EntireBody = v end})
ChamsSettingsSection:colorpicker({name = "Chams Color", def = WallHack.Visuals.ChamsSettings.Color, callback = function(v) WallHack.Visuals.ChamsSettings.Color = v end})
ChamsSettingsSection:slider({name = "Transparency", def = WallHack.Visuals.ChamsSettings.Transparency, max = 1, min = 0, rounding = false, callback = function(v) WallHack.Visuals.ChamsSettings.Transparency = v end})
ChamsSettingsSection:slider({name = "Thickness", def = WallHack.Visuals.ChamsSettings.Thickness, max = 3, min = 0, rounding = true, callback = function(v) WallHack.Visuals.ChamsSettings.Thickness = v end})

TracersSettingsSection:toggle({name = "Enable Tracers", def = WallHack.Visuals.TracersSettings.Enabled, callback = function(v) WallHack.Visuals.TracersSettings.Enabled = v end})
TracersSettingsSection:dropdown({name = "Start From", def = "Bottom", max = #TracersType, options = TracersType, callback = function(v) WallHack.Visuals.TracersSettings.Type = (v == "Bottom" and 1 or (v == "Center" and 2 or 3)) end})
TracersSettingsSection:colorpicker({name = "Tracer Color", def = WallHack.Visuals.TracersSettings.Color, callback = function(v) WallHack.Visuals.TracersSettings.Color = v end})
TracersSettingsSection:slider({name = "Thickness", def = WallHack.Visuals.TracersSettings.Thickness, max = 5, min = 1, rounding = true, callback = function(v) WallHack.Visuals.TracersSettings.Thickness = v end})

HeadDotsSettingsSection:toggle({name = "Enable Head Dots", def = WallHack.Visuals.HeadDotSettings.Enabled, callback = function(v) WallHack.Visuals.HeadDotSettings.Enabled = v end})
HeadDotsSettingsSection:toggle({name = "Filled", def = WallHack.Visuals.HeadDotSettings.Filled, callback = function(v) WallHack.Visuals.HeadDotSettings.Filled = v end})
HeadDotsSettingsSection:slider({name = "Sides", def = WallHack.Visuals.HeadDotSettings.Sides, max = 60, min = 3, rounding = true, callback = function(v) WallHack.Visuals.HeadDotSettings.Sides = v end})
HeadDotsSettingsSection:slider({name = "Thickness", def = WallHack.Visuals.HeadDotSettings.Thickness, max = 5, min = 1, rounding = true, callback = function(v) WallHack.Visuals.HeadDotSettings.Thickness = v end})
HeadDotsSettingsSection:colorpicker({name = "Head Dot Color", def = WallHack.Visuals.HeadDotSettings.Color, callback = function(v) WallHack.Visuals.HeadDotSettings.Color = v end})

HealthBarSettingsSection:toggle({name = "Enable Health Bar", def = WallHack.Visuals.HealthBarSettings.Enabled, callback = function(v) WallHack.Visuals.HealthBarSettings.Enabled = v end})
HealthBarSettingsSection:dropdown({name = "Position", def = "Left", max = #HealthBarPos, options = HealthBarPos, callback = function(New) WallHack.Visuals.HealthBarSettings.Type = (New == "Top" and 1 or New == "Bottom" and 2 or New == "Left" and 3 or 4) end})
HealthBarSettingsSection:slider({name = "Transparency", def = WallHack.Visuals.HealthBarSettings.Transparency, max = 1, min = 0, rounding = false, callback = function(v) WallHack.Visuals.HealthBarSettings.Transparency = v end})
HealthBarSettingsSection:slider({name = "Size", def = WallHack.Visuals.HealthBarSettings.Size, max = 10, min = 2, rounding = true, callback = function(v) WallHack.Visuals.HealthBarSettings.Size = v end})
HealthBarSettingsSection:slider({name = "Offset", def = WallHack.Visuals.HealthBarSettings.Offset, max = 30, min = -30, rounding = true, callback = function(v) WallHack.Visuals.HealthBarSettings.Offset = v end})
HealthBarSettingsSection:colorpicker({name = "Outline Color", def = WallHack.Visuals.HealthBarSettings.OutlineColor, callback = function(v) WallHack.Visuals.HealthBarSettings.OutlineColor = v end})


-- crosshair UI

local CrosshairSettingsSection = CrosshairTab:section({name = "Settings", side = "left", size = 300})
local CenterDotSettingsSection = CrosshairTab:section({name = "Center Dot Settings", side = "right", size = 200})

CrosshairSettingsSection:toggle({name = "Enable Crosshair", def = WallHack.Crosshair.Settings.Enabled, callback = function(v) WallHack.Crosshair.Settings.Enabled = v end})
CrosshairSettingsSection:toggle({name = "Mouse Cursor", def = UserInputService.MouseIconEnabled, callback = function(v) UserInputService.MouseIconEnabled = v end})
CrosshairSettingsSection:dropdown({name = "Position", def = "Mouse", max = 2, options = {"Mouse", "Center"}, callback = function(v) WallHack.Crosshair.Settings.Type = (v == "Mouse" and 1 or 2) end})
CrosshairSettingsSection:colorpicker({name = "Color", def = WallHack.Crosshair.Settings.Color, callback = function(v) WallHack.Crosshair.Settings.Color = v end})
CrosshairSettingsSection:slider({name = "Transparency", def = WallHack.Crosshair.Settings.Transparency, max = 1, min = 0, rounding = false, callback = function(v) WallHack.Crosshair.Settings.Transparency = v end})
CrosshairSettingsSection:slider({name = "Size", def = WallHack.Crosshair.Settings.Size, max = 24, min = 8, rounding = true, callback = function(v) WallHack.Crosshair.Settings.Size = v end})
CrosshairSettingsSection:slider({name = "Thickness", def = WallHack.Crosshair.Settings.Thickness, max = 5, min = 1, rounding = true, callback = function(v) WallHack.Crosshair.Settings.Thickness = v end})
CrosshairSettingsSection:slider({name = "Gap Size", def = WallHack.Crosshair.Settings.GapSize, max = 20, min = 0, rounding = true, callback = function(v) WallHack.Crosshair.Settings.GapSize = v end})
CrosshairSettingsSection:slider({name = "Rotation", def = WallHack.Crosshair.Settings.Rotation, max = 180, min = -180, rounding = true, callback = function(v) WallHack.Crosshair.Settings.Rotation = v end})

CenterDotSettingsSection:toggle({name = "Enable Center Dot", def = WallHack.Crosshair.Settings.CenterDot, callback = function(v) WallHack.Crosshair.Settings.CenterDot = v end})
CenterDotSettingsSection:toggle({name = "Filled", def = WallHack.Crosshair.Settings.CenterDotFilled, callback = function(v) WallHack.Crosshair.Settings.CenterDotFilled = v end})
CenterDotSettingsSection:colorpicker({name = "Dot Color", def = WallHack.Crosshair.Settings.CenterDotColor, callback = function(v) WallHack.Crosshair.Settings.CenterDotColor = v end})
CenterDotSettingsSection:slider({name = "Dot Size", def = WallHack.Crosshair.Settings.CenterDotSize, max = 6, min = 1, rounding = true, callback = function(v) WallHack.Crosshair.Settings.CenterDotSize = v end})
CenterDotSettingsSection:slider({name = "Dot Transparency", def = WallHack.Crosshair.Settings.CenterDotTransparency, max = 1, min = 0, rounding = false, callback = function(v) WallHack.Crosshair.Settings.CenterDotTransparency = v end})


-- player mods tab

local FlyToggleObject = PlayerTab:section({name = "Fly", side = "left", size = 120})
local WSJSTab = PlayerTab:section({name = "WalkSpeed / JumpPower", side = "right", size = 180})

local function ApplyFly(state)
    IsFlying = state; local char, root, hum = LocalPlayer.Character, LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"), LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if not (char and root and hum) then return end
    if IsFlying then
        if FlyBodyGyro then FlyBodyGyro:Destroy() end; if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        FlyBodyGyro = Instance.new("BodyGyro", root); FlyBodyGyro.MaxTorque, FlyBodyGyro.P = Vector3.new(math.huge, math.huge, math.huge), 20000
        FlyBodyVelocity = Instance.new("BodyVelocity", root); FlyBodyVelocity.MaxForce, FlyBodyVelocity.P = Vector3.new(math.huge, math.huge, math.huge), 10000
        hum:ChangeState(Enum.HumanoidStateType.Physics)
    else
        if FlyBodyGyro then FlyBodyGyro:Destroy(); FlyBodyGyro = nil end; if FlyBodyVelocity then FlyBodyVelocity:Destroy(); FlyBodyVelocity = nil end
        hum:ChangeState(Enum.HumanoidStateType.Running)
    end
end
local FlyToggle = FlyToggleObject:toggle({name = "Enable Fly", def = false, callback = ApplyFly})
FlyToggleObject:slider({name = "Fly Speed", def = 50, max = 100, min = 1, rounding = true, callback = function(v) getgenv().Player_FlySpeed = v end})
FlyToggleObject:keybind({name = "Fly Key", def = Enum.KeyCode.F, callback = function(key) getgenv().Player_FlyKey = key end})

local WalkSpeedToggle = WSJSTab:toggle({name = "WalkSpeed", def = false, callback = function(v) local hum = GetHumanoid(LocalPlayer); if hum then hum.WalkSpeed = v and getgenv().Player_WalkSpeedValue or OriginalWalkSpeed end end})
WSJSTab:slider({name = "Speed Value", def = 32, max = 200, min = 16, rounding = true, callback = function(v) getgenv().Player_WalkSpeedValue = v; if WalkSpeedToggle.current then local hum = GetHumanoid(LocalPlayer); if hum then hum.WalkSpeed = v end end end})
local JumpPowerToggle = WSJSTab:toggle({name = "JumpPower", def = false, callback = function(v) local hum = GetHumanoid(LocalPlayer); if hum then hum.JumpPower = v and getgenv().Player_JumpPowerValue or OriginalJumpPower end end})
WSJSTab:slider({name = "JS Value", def = 75, max = 300, min = 50, rounding = true, callback = function(v) getgenv().Player_JumpPowerValue = v; if JumpPowerToggle.current then local hum = GetHumanoid(LocalPlayer); if hum then hum.JumpPower = v end end end})


-- functions tab & cons

local FunctionsSection = FunctionsTab:section({name = "Functions", side="left", size=150})
FunctionsSection:button({name = "Reset Settings", callback = function() Aimbot.Functions:ResetSettings(); WallHack.Functions:ResetSettings(); print("Settings Reset") end}) -- Note: Splix does not have a native reset all function.
FunctionsSection:button({name = "Restart Modules", callback = function() Aimbot.Functions:Restart(); WallHack.Functions:Restart() end})

RunService.RenderStepped:Connect(function()
    pcall(function()
        if IsFlying then
            local camCF, moveVector = Camera.CFrame, Vector3.new(); if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += camCF.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector -= camCF.LookVector end; if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector -= camCF.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += camCF.RightVector end; if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0,1,0) end; if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector -= Vector3.new(0,1,0) end
            if FlyBodyGyro then FlyBodyGyro.CFrame = camCF end; if FlyBodyVelocity then FlyBodyVelocity.Velocity = moveVector.Magnitude > 0 and moveVector.Unit * getgenv().Player_FlySpeed or Vector3.new(0,0,0) end
        end
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == getgenv().Player_FlyKey then
        FlyToggle:set(not FlyToggle.current)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5)
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then OriginalWalkSpeed, OriginalJumpPower = hum.WalkSpeed, hum.JumpPower end
    if WalkSpeedToggle.current then hum.WalkSpeed = getgenv().Player_WalkSpeedValue end
    if JumpPowerToggle.current then hum.JumpPower = getgenv().Player_JumpPowerValue end
end)

local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then OriginalWalkSpeed, OriginalJumpPower = hum.WalkSpeed, hum.JumpPower end -- i dont know what the point of this is, but it made it work
