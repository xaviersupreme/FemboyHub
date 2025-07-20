getgenv().AirHub = {}

pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/xaviersupreme/FemboyHub/refs/heads/main/modules/aimbot.lua"))() end)
pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/xaviersupreme/FemboyHub/refs/heads/main/modules/esp.lua"))() end)

-- lload the provided config Library
local ConfigLib = (loadstring(game:HttpGet("https://raw.githubusercontent.com/xaviersupreme/FemboyHub/main/modules/Config.lua")))()

-- Load the functional Void UI Library
local VoidLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/GhostDuckyy/UI-Libraries/refs/heads/main/Void/source.lua"))()
if not VoidLib or not VoidLib.Load then
    warn("FEMBOY HUB: CRITICAL FAILURE - Could not load Void UI Library.")
    return
end

task.wait(0.5) -- wait for modules to fully load\
local Aimbot, WallHack = getgenv().AirHub.Aimbot, getgenv().AirHub.WallHack
if not (Aimbot and WallHack) then
    warn("FEMBOY HUB: CRITICAL FAILURE - AirHub modules did not load correctly. The script cannot continue.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Parts = {"Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "LeftHand", "RightHand", "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm", "LeftFoot", "LeftLowerLeg", "UpperTorso", "LeftUpperLeg", "RightFoot", "RightLowerLeg", "LowerTorso", "RightUpperLeg"}
local Fonts = {"UI", "System", "Plex", "Monospace"}
local TracersType = {"Bottom", "Center", "Mouse"}
local HealthBarPos = {"Top", "Bottom", "Left", "Right"}

-- Runtime variables
local IsFlying = false
local FlyBodyGyro, FlyBodyVelocity = nil, nil
local OriginalWalkSpeed, OriginalJumpPower, OriginalGravity = 16, 50, workspace.Gravity
local IsNoclipping = false
local NoclipConnection = nil
getgenv().Player_FlySpeed = 50
getgenv().Player_FlyKey = Enum.KeyCode.F
getgenv().Player_WalkSpeedValue = 32
getgenv().Player_JumpPowerValue = 75


local Watermark = VoidLib:Watermark("Femboy Hub | 0 fps")
local MainFrame = VoidLib:Load({
    Name = "Femboy Hub",
    SizeX = 600,
    SizeY = 700,
    Theme = "Midnight",
    Folder = "FemboyHub"
})
VoidLib:ChangeThemeOption("Accent", Color3.fromRGB(255, 182, 193))


local AimbotTab = MainFrame:Tab("Aimbot")
local VisualsTab = MainFrame:Tab("Visuals")
local CrosshairTab = MainFrame:Tab("Crosshair")
local PlayerTab = MainFrame:Tab("Player Mods")
local ConfigsTab = MainFrame:Tab("Configuration")


local AimbotValuesSection = AimbotTab:Section({ Name = "Values", Side = "Left" })
local AimbotChecksSection = AimbotTab:Section({ Name = "Checks", Side = "Left" })
local AimbotThirdPersonSection = AimbotTab:Section({ Name = "Third Person", Side = "Left" })
local FOVValuesSection = AimbotTab:Section({ Name = "Field Of View", Side = "Right" })
local FOVAppearanceSection = AimbotTab:Section({ Name = "FOV Circle Appearance", Side = "Right" })

AimbotValuesSection:Toggle({ Name = "Enable Aimbot", Flag = "Aimbot_Enabled", Default = Aimbot.Settings.Enabled, Callback = function(v) Aimbot.Settings.Enabled = v end})
AimbotValuesSection:Toggle({ Name = "Toggle Mode", Flag = "Aimbot_Toggle", Default = Aimbot.Settings.Toggle, Callback = function(v) Aimbot.Settings.Toggle = v end})
AimbotValuesSection:Dropdown({ Name = "Lock Part", Flag = "Aimbot_LockPart", Default = Aimbot.Settings.LockPart, Content = Parts, Callback = function(v) Aimbot.Settings.LockPart = v end})
AimbotValuesSection:Box({ Name = "Hotkey", Flag = "Aimbot_Hotkey", Default = Aimbot.Settings.TriggerKey, Placeholder = "MouseButton2, E, etc.", Callback = function(v) Aimbot.Settings.TriggerKey = v end})
AimbotValuesSection:Slider({ Name = "Smoothing", Text = "[value]s", Flag = "Aimbot_Smoothing", Default = Aimbot.Settings.Sensitivity, Min = 0, Max = 1, Float = 0.01, Callback = function(v) Aimbot.Settings.Sensitivity = v end})

AimbotChecksSection:Toggle({ Name = "Team Check", Flag = "Aimbot_TeamCheck", Default = Aimbot.Settings.TeamCheck, Callback = function(v) Aimbot.Settings.TeamCheck = v end})
AimbotChecksSection:Toggle({ Name = "Wall Check", Flag = "Aimbot_WallCheck", Default = Aimbot.Settings.WallCheck, Callback = function(v) Aimbot.Settings.WallCheck = v end})
AimbotChecksSection:Toggle({ Name = "Alive Check", Flag = "Aimbot_AliveCheck", Default = Aimbot.Settings.AliveCheck, Callback = function(v) Aimbot.Settings.AliveCheck = v end})

AimbotThirdPersonSection:Toggle({Name = "Enable Third Person", Flag="Aimbot_3P", Default=Aimbot.Settings.ThirdPerson, Callback=function(v) Aimbot.Settings.ThirdPerson = v end})
AimbotThirdPersonSection:Slider({Name = "3P Sensitivity", Text="[value]", Flag="Aimbot_3PSens", Default=Aimbot.Settings.ThirdPersonSensitivity, Min=0.1, Max=5, Float=0.1, Callback=function(v) Aimbot.Settings.ThirdPersonSensitivity = v end})

FOVValuesSection:Toggle({ Name = "Enable FOV", Flag = "FOV_Enabled", Default = Aimbot.FOVSettings.Enabled, Callback = function(v) Aimbot.FOVSettings.Enabled = v end})
FOVValuesSection:Toggle({ Name = "Visible", Flag = "FOV_Visible", Default = Aimbot.FOVSettings.Visible, Callback = function(v) Aimbot.FOVSettings.Visible = v end})
FOVValuesSection:Slider({ Name = "Amount (Radius)", Text = "[value]", Flag = "FOV_Amount", Default = Aimbot.FOVSettings.Amount, Min = 10, Max = 500, Float = 1, Callback = function(v) Aimbot.FOVSettings.Amount = v end})

FOVAppearanceSection:Toggle({ Name = "Filled", Flag = "FOV_Filled", Default = Aimbot.FOVSettings.Filled, Callback = function(v) Aimbot.FOVSettings.Filled = v end})
FOVAppearanceSection:Slider({ Name = "Transparency", Text = "[value]%", Flag = "FOV_Transparency", Default = Aimbot.FOVSettings.Transparency, Min = 0, Max = 1, Float = 0.01, Callback = function(v) Aimbot.FOVSettings.Transparency = v end})
FOVAppearanceSection:Slider({ Name = "Sides", Text = "[value]", Flag = "FOV_Sides", Default = Aimbot.FOVSettings.Sides, Min = 3, Max = 60, Float = 1, Callback = function(v) Aimbot.FOVSettings.Sides = v end})
FOVAppearanceSection:Slider({ Name = "Thickness", Text = "[value]", Flag = "FOV_Thickness", Default = Aimbot.FOVSettings.Thickness, Min = 1, Max = 10, Float = 1, Callback = function(v) Aimbot.FOVSettings.Thickness = v end})
FOVAppearanceSection:ColorPicker({ Name = "Color", Flag = "FOV_Color", Default = Aimbot.FOVSettings.Color, Callback = function(v) Aimbot.FOVSettings.Color = v end})
FOVAppearanceSection:ColorPicker({ Name = "Locked Color", Flag = "FOV_LockedColor", Default = Aimbot.FOVSettings.LockedColor, Callback = function(v) Aimbot.FOVSettings.LockedColor = v end})


local ESPChecksSection = VisualsTab:Section({ Name = "Checks", Side = "Left" })
local ESPSettingsSection = VisualsTab:Section({ Name = "ESP Settings", Side = "Left" })
local BoxesSettingsSection = VisualsTab:Section({ Name = "Boxes Settings", Side = "Left" })
local ChamsSettingsSection = VisualsTab:Section({ Name = "Chams Settings", Side = "Right" })
local TracersSettingsSection = VisualsTab:Section({ Name = "Tracers Settings", Side = "Right" })
local HeadDotsSettingsSection = VisualsTab:Section({ Name = "Head Dots", Side = "Right" })
local HealthBarSettingsSection = VisualsTab:Section({ Name = "Health Bar", Side = "Right" })

ESPChecksSection:Toggle({ Name = "Enable Visuals", Flag = "WH_Enabled", Default = WallHack.Settings.Enabled, Callback = function(v) WallHack.Settings.Enabled = v end})
ESPChecksSection:Toggle({ Name = "Team Check", Flag = "WH_TeamCheck", Default = WallHack.Settings.TeamCheck, Callback = function(v) WallHack.Settings.TeamCheck = v end})
ESPChecksSection:Toggle({ Name = "Alive Check", Flag = "WH_AliveCheck", Default = WallHack.Settings.AliveCheck, Callback = function(v) WallHack.Settings.AliveCheck = v end})

ESPSettingsSection:Toggle({ Name = "Enable Text ESP", Flag = "ESP_TextEnabled", Default = WallHack.Visuals.ESPSettings.Enabled, Callback = function(v) WallHack.Visuals.ESPSettings.Enabled = v end})
ESPSettingsSection:Toggle({ Name = "Outline", Flag = "ESP_Outline", Default = WallHack.Visuals.ESPSettings.Outline, Callback = function(v) WallHack.Visuals.ESPSettings.Outline = v end})
ESPSettingsSection:Toggle({ Name = "Display Distance", Flag = "ESP_Distance", Default = WallHack.Visuals.ESPSettings.DisplayDistance, Callback = function(v) WallHack.Visuals.ESPSettings.DisplayDistance = v end})
ESPSettingsSection:Toggle({ Name = "Display Health", Flag = "ESP_Health", Default = WallHack.Visuals.ESPSettings.DisplayHealth, Callback = function(v) WallHack.Visuals.ESPSettings.DisplayHealth = v end})
ESPSettingsSection:Toggle({ Name = "Display Name", Flag = "ESP_Name", Default = WallHack.Visuals.ESPSettings.DisplayName, Callback = function(v) WallHack.Visuals.ESPSettings.DisplayName = v end})
ESPSettingsSection:Slider({ Name = "Text Offset", Text = "[value]", Flag = "ESP_Offset", Default = WallHack.Visuals.ESPSettings.Offset, Max = 50, Min = -50, Float = 1, Callback = function(v) WallHack.Visuals.ESPSettings.Offset = v end})
ESPSettingsSection:ColorPicker({ Name = "Text Color", Flag = "ESP_TextColor", Default = WallHack.Visuals.ESPSettings.TextColor, Callback = function(v) WallHack.Visuals.ESPSettings.TextColor = v end})
ESPSettingsSection:ColorPicker({ Name = "Outline Color", Flag = "ESP_OutlineColor", Default = WallHack.Visuals.ESPSettings.OutlineColor, Callback = function(v) WallHack.Visuals.ESPSettings.OutlineColor = v end})
ESPSettingsSection:Slider({ Name = "Text Size", Text = "[value]", Flag = "ESP_TextSize", Default = WallHack.Visuals.ESPSettings.TextSize, Max = 24, Min = 8, Float = 1, Callback = function(v) WallHack.Visuals.ESPSettings.TextSize = v end})
ESPSettingsSection:Slider({ Name = "Text Transparency", Text = "[value]%", Flag = "ESP_TextTransparency", Default = WallHack.Visuals.ESPSettings.TextTransparency, Max = 1, Min = 0, Float = 0.01, Callback = function(v) WallHack.Visuals.ESPSettings.TextTransparency = v end})
ESPSettingsSection:Dropdown({ Name = "Font", Flag = "ESP_Font", Default = "UI", Content = Fonts, Callback = function(v) WallHack.Visuals.ESPSettings.TextFont = Drawing.Fonts[v] end})

BoxesSettingsSection:Toggle({ Name = "Enable Boxes", Flag = "Box_Enabled", Default = WallHack.Visuals.BoxSettings.Enabled, Callback = function(v) WallHack.Visuals.BoxSettings.Enabled = v end})
BoxesSettingsSection:Toggle({ Name = "Filled (2D)", Flag = "Box_Filled", Default = WallHack.Visuals.BoxSettings.Filled, Callback = function(v) WallHack.Visuals.BoxSettings.Filled = v end})
BoxesSettingsSection:Dropdown({ Name = "Box Type", Flag = "Box_Type", Default = "3D", Content = {"3D", "2D"}, Callback = function(v) WallHack.Visuals.BoxSettings.Type = (v == "3D" and 1 or 2) end})
BoxesSettingsSection:ColorPicker({ Name = "Box Color", Flag = "Box_Color", Default = WallHack.Visuals.BoxSettings.Color, Callback = function(v) WallHack.Visuals.BoxSettings.Color = v end})
BoxesSettingsSection:Slider({ Name = "Thickness", Text = "[value]", Flag = "Box_Thickness", Default = WallHack.Visuals.BoxSettings.Thickness, Max = 5, Min = 1, Float = 1, Callback = function(v) WallHack.Visuals.BoxSettings.Thickness = v end})
BoxesSettingsSection:Slider({ Name = "Transparency", Text = "[value]%", Flag = "Box_Transparency", Default = WallHack.Visuals.BoxSettings.Transparency, Max = 1, Min = 0, Float = 0.01, Callback = function(v) WallHack.Visuals.BoxSettings.Transparency = v end})
BoxesSettingsSection:Slider({ Name = "Scale Increase (3D)", Text = "[value]x", Flag = "Box_Scale", Default = WallHack.Visuals.BoxSettings.Increase, Max = 5, Min = 1, Float = 1, Callback = function(v) WallHack.Visuals.BoxSettings.Increase = v end})

ChamsSettingsSection:Toggle({ Name = "Enable Chams", Flag = "Chams_Enabled", Default = WallHack.Visuals.ChamsSettings.Enabled, Callback = function(v) WallHack.Visuals.ChamsSettings.Enabled = v end})
ChamsSettingsSection:Toggle({ Name = "Filled", Flag = "Chams_Filled", Default = WallHack.Visuals.ChamsSettings.Filled, Callback = function(v) WallHack.Visuals.ChamsSettings.Filled = v end})
ChamsSettingsSection:Toggle({ Name = "Entire Body (R15)", Flag = "Chams_Body", Default = WallHack.Visuals.ChamsSettings.EntireBody, Callback = function(v) WallHack.Visuals.ChamsSettings.EntireBody = v end})
ChamsSettingsSection:ColorPicker({ Name = "Chams Color", Flag = "Chams_Color", Default = WallHack.Visuals.ChamsSettings.Color, Callback = function(v) WallHack.Visuals.ChamsSettings.Color = v end})
ChamsSettingsSection:Slider({ Name = "Transparency", Text = "[value]%", Flag = "Chams_Transparency", Default = WallHack.Visuals.ChamsSettings.Transparency, Max = 1, Min = 0, Float = 0.01, Callback = function(v) WallHack.Visuals.ChamsSettings.Transparency = v end})
ChamsSettingsSection:Slider({ Name = "Thickness", Text = "[value]", Flag = "Chams_Thickness", Default = WallHack.Visuals.ChamsSettings.Thickness, Max = 3, Min = 0, Float = 1, Callback = function(v) WallHack.Visuals.ChamsSettings.Thickness = v end})

TracersSettingsSection:Toggle({ Name = "Enable Tracers", Flag = "Tracers_Enabled", Default = WallHack.Visuals.TracersSettings.Enabled, Callback = function(v) WallHack.Visuals.TracersSettings.Enabled = v end})
TracersSettingsSection:Dropdown({ Name = "Start From", Flag = "Tracers_Type", Default = "Bottom", Content = TracersType, Callback = function(v) WallHack.Visuals.TracersSettings.Type = (v == "Bottom" and 1 or (v == "Center" and 2 or 3)) end})
TracersSettingsSection:ColorPicker({ Name = "Tracer Color", Flag = "Tracers_Color", Default = WallHack.Visuals.TracersSettings.Color, Callback = function(v) WallHack.Visuals.TracersSettings.Color = v end})
TracersSettingsSection:Slider({ Name = "Thickness", Text = "[value]", Flag = "Tracers_Thickness", Default = WallHack.Visuals.TracersSettings.Thickness, Max = 5, Min = 1, Float = 1, Callback = function(v) WallHack.Visuals.TracersSettings.Thickness = v end})

HeadDotsSettingsSection:Toggle({ Name = "Enable Head Dots", Flag = "HeadDot_Enabled", Default = WallHack.Visuals.HeadDotSettings.Enabled, Callback = function(v) WallHack.Visuals.HeadDotSettings.Enabled = v end})
HeadDotsSettingsSection:Toggle({ Name = "Filled", Flag = "HeadDot_Filled", Default = WallHack.Visuals.HeadDotSettings.Filled, Callback = function(v) WallHack.Visuals.HeadDotSettings.Filled = v end})
HeadDotsSettingsSection:Slider({ Name = "Sides", Text = "[value]", Flag = "HeadDot_Sides", Default = WallHack.Visuals.HeadDotSettings.Sides, Max = 60, Min = 3, Float = 1, Callback = function(v) WallHack.Visuals.HeadDotSettings.Sides = v end})
HeadDotsSettingsSection:Slider({ Name = "Thickness", Text = "[value]", Flag = "HeadDot_Thickness", Default = WallHack.Visuals.HeadDotSettings.Thickness, Max = 5, Min = 1, Float = 1, Callback = function(v) WallHack.Visuals.HeadDotSettings.Thickness = v end})
HeadDotsSettingsSection:ColorPicker({ Name = "Head Dot Color", Flag = "HeadDot_Color", Default = WallHack.Visuals.HeadDotSettings.Color, Callback = function(v) WallHack.Visuals.HeadDotSettings.Color = v end})

HealthBarSettingsSection:Toggle({ Name = "Enable Health Bar", Flag = "HealthBar_Enabled", Default = WallHack.Visuals.HealthBarSettings.Enabled, Callback = function(v) WallHack.Visuals.HealthBarSettings.Enabled = v end})
HealthBarSettingsSection:Dropdown({ Name = "Position", Flag = "HealthBar_Position", Default = "Left", Content = HealthBarPos, Callback = function(v) WallHack.Visuals.HealthBarSettings.Type = (v == "Top" and 1 or v == "Bottom" and 2 or v == "Left" and 3 or 4) end})
HealthBarSettingsSection:Slider({ Name = "Size", Text = "[value]", Flag = "HealthBar_Size", Default = WallHack.Visuals.HealthBarSettings.Size, Max = 10, Min = 2, Float = 1, Callback = function(v) WallHack.Visuals.HealthBarSettings.Size = v end})
HealthBarSettingsSection:Slider({ Name = "Offset", Text = "[value]", Flag = "HealthBar_Offset", Default = WallHack.Visuals.HealthBarSettings.Offset, Max = 30, Min = -30, Float = 1, Callback = function(v) WallHack.Visuals.HealthBarSettings.Offset = v end})
HealthBarSettingsSection:ColorPicker({ Name = "Outline Color", Flag = "HealthBar_OutlineColor", Default = WallHack.Visuals.HealthBarSettings.OutlineColor, Callback = function(v) WallHack.Visuals.HealthBarSettings.OutlineColor = v end})


local CrosshairSettingsSection = CrosshairTab:Section({ Name = "Settings", Side = "Left" })
local CenterDotSettingsSection = CrosshairTab:Section({ Name = "Center Dot Settings", Side = "Right" })

CrosshairSettingsSection:Toggle({ Name = "Enable Crosshair", Flag = "Crosshair_Enabled", Default = WallHack.Crosshair.Settings.Enabled, Callback = function(v) WallHack.Crosshair.Settings.Enabled = v end})
CrosshairSettingsSection:Dropdown({ Name = "Position", Flag = "Crosshair_Pos", Default = "Mouse", Content = {"Mouse", "Center"}, Callback = function(v) WallHack.Crosshair.Settings.Type = (v == "Mouse" and 1 or 2) end})
CrosshairSettingsSection:ColorPicker({ Name = "Color", Flag = "Crosshair_Color", Default = WallHack.Crosshair.Settings.Color, Callback = function(v) WallHack.Crosshair.Settings.Color = v end})
CrosshairSettingsSection:Slider({ Name = "Size", Text = "[value]", Flag = "Crosshair_Size", Default = WallHack.Crosshair.Settings.Size, Max = 24, Min = 8, Float = 1, Callback = function(v) WallHack.Crosshair.Settings.Size = v end})
CrosshairSettingsSection:Slider({ Name = "Gap Size", Text = "[value]", Flag = "Crosshair_Gap", Default = WallHack.Crosshair.Settings.GapSize, Max = 20, Min = 0, Float = 1, Callback = function(v) WallHack.Crosshair.Settings.GapSize = v end})
CrosshairSettingsSection:Slider({ Name = "Thickness", Text = "[value]", Flag = "Crosshair_Thickness", Default = WallHack.Crosshair.Settings.Thickness, Max = 5, Min = 1, Float = 1, Callback = function(v) WallHack.Crosshair.Settings.Thickness = v end})
CrosshairSettingsSection:Slider({ Name = "Rotation", Text = "[value]°", Flag = "Crosshair_Rotation", Default = WallHack.Crosshair.Settings.Rotation, Max = 180, Min = -180, Float = 1, Callback = function(v) WallHack.Crosshair.Settings.Rotation = v end})

CenterDotSettingsSection:Toggle({ Name = "Enable Center Dot", Flag = "Dot_Enabled", Default = WallHack.Crosshair.Settings.CenterDot, Callback = function(v) WallHack.Crosshair.Settings.CenterDot = v end})
CenterDotSettingsSection:Toggle({ Name = "Filled", Flag = "Dot_Filled", Default = WallHack.Crosshair.Settings.CenterDotFilled, Callback = function(v) WallHack.Crosshair.Settings.CenterDotFilled = v end})
CenterDotSettingsSection:ColorPicker({ Name = "Dot Color", Flag = "Dot_Color", Default = WallHack.Crosshair.Settings.CenterDotColor, Callback = function(v) WallHack.Crosshair.Settings.CenterDotColor = v end})
CenterDotSettingsSection:Slider({ Name = "Dot Size", Text = "[value]", Flag = "Dot_Size", Default = WallHack.Crosshair.Settings.CenterDotSize, Max = 6, Min = 1, Float = 1, Callback = function(v) WallHack.Crosshair.Settings.CenterDotSize = v end})


local FlySection = PlayerTab:Section({Name = "Fly", Side = "Left"})
local MovementSection = PlayerTab:Section({Name = "Movement", Side = "Left"})
local CharacterSection = PlayerTab:Section({Name = "Character", Side = "Right"})

local FlyToggle = FlySection:Toggle({Name = "Enable Fly", Flag = "Player_Fly", Default = false, Callback = function(state)
    IsFlying = state; local char, root, hum = LocalPlayer.Character, GetRootPart(LocalPlayer), GetHumanoid(LocalPlayer)
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
end})
FlySection:Slider({Name = "Fly Speed", Text = "[value]", Flag = "Player_FlySpeed", Default = 50, Min = 10, Max = 200, Float = 1, Callback = function(v) getgenv().Player_FlySpeed = v end})
FlySection:Keybind({Name = "Fly Keybind", Flag = "Player_FlyKey", Default = Enum.KeyCode.F, Callback = function(key) getgenv().Player_FlyKey = key end})

local WalkSpeedToggle = MovementSection:Toggle({Name = "WalkSpeed", Flag = "Player_WS", Default = false, Callback = function(v) local hum = GetHumanoid(LocalPlayer); if hum then hum.WalkSpeed = v and getgenv().Player_WalkSpeedValue or OriginalWalkSpeed end end})
WalkSpeedToggle:Slider({Text = "[value]", Flag = "Player_WSValue", Default = 32, Min = 16, Max = 200, Float = 1, Callback = function(v) getgenv().Player_WalkSpeedValue = v; if WalkSpeedToggle.Enabled then local hum = GetHumanoid(LocalPlayer); if hum then hum.WalkSpeed = v end end end})
local JumpPowerToggle = MovementSection:Toggle({Name = "JumpPower", Flag = "Player_JP", Default = false, Callback = function(v) local hum = GetHumanoid(LocalPlayer); if hum then hum.JumpPower = v and getgenv().Player_JumpPowerValue or OriginalJumpPower end end})
JumpPowerToggle:Slider({Text = "[value]", Flag = "Player_JPValue", Default = 75, Min = 50, Max = 300, Float = 1, Callback = function(v) getgenv().Player_JumpPowerValue = v; if JumpPowerToggle.Enabled then local hum = GetHumanoid(LocalPlayer); if hum then hum.JumpPower = v end end end})

local NoclipToggle = CharacterSection:Toggle({Name = "Noclip", Flag = "Player_Noclip", Default = false, Callback = function(state)
    IsNoclipping = state
    if IsNoclipping then
        NoclipConnection = RunService.Stepped:Connect(function() if LocalPlayer.Character then for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end end)
    elseif NoclipConnection then
        NoclipConnection:Disconnect(); NoclipConnection = nil
    end
end})
NoclipToggle:Keybind({Flag = "Player_NoclipKey", Default = Enum.KeyCode.N, Mode = "Toggle"})

CharacterSection:Slider({Name = "Gravity", Text="[value]", Flag="Player_Gravity", Default=OriginalGravity, Min=1, Max=200, Float=1, Callback=function(v) workspace.Gravity = v end})
CharacterSection:Button({Name="Reset Gravity", Callback=function() workspace.Gravity = OriginalGravity; VoidLib.flags["Player_Gravity"]=OriginalGravity end})


local ConfigSection = ConfigsTab:Section{Name = "Configs", Side = "Left"}
local KeybindSection = ConfigsTab:Section{Name = "UI Toggle Keybind", Side = "Left"}

if not isfolder("FemboyHub") then makefolder("FemboyHub") end
local ConfigList = ConfigSection:Dropdown{ Name = "Configs", Content = (function() local t = {}; for _, f in ipairs(listfiles("FemboyHub")) do table.insert(t, f:gsub(".json", "")) end return t end)(), Flag = "Config_Dropdown" }
ConfigSection:Button{ Name = "Load Config", Callback = function() if VoidLib.flags["Config_Dropdown"] ~= "" then MainFrame:LoadConfig(VoidLib.flags["Config_Dropdown"]) end end }
ConfigSection:Button{ Name = "Delete Config", Callback = function() if VoidLib.flags["Config_Dropdown"] ~= "" then VoidLib:DeleteConfig(VoidLib.flags["Config_Dropdown"]); ConfigList:Refresh(VoidLib:GetConfigs()) end end }
local ConfigBox = ConfigSection:Box{ Name = "Config Name", Placeholder = "New config name...", Flag = "Config_Name" }
ConfigSection:Button{ Name = "Save Config", Callback = function()
    local name = VoidLib.flags["Config_Name"] or VoidLib.flags["Config_Dropdown"]
    if name and name ~= "" then VoidLib:SaveConfig(name) ConfigList:Refresh(VoidLib:GetConfigs()) end
end}
KeybindSection:Keybind{ Name = "UI Toggle", Flag = "UI_Toggle", Default = Enum.KeyCode.RightShift, Callback = function(_, fromsetting) if not fromsetting then VoidLib:Close() end end }

local FrameCount = 0
RunService.RenderStepped:Connect(function(step)
    FrameCount = FrameCount + 1
    if FrameCount % 15 == 0 then Watermark:Set("Femboy Hub | " .. tostring(math.floor(1/step)) .. " fps") end
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
        FlyToggle:Toggle(not IsFlying)
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.5); local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then OriginalWalkSpeed, OriginalJumpPower = hum.WalkSpeed, hum.JumpPower end
    if WalkSpeedToggle.Enabled then hum.WalkSpeed = getgenv().Player_WalkSpeedValue end
    if JumpPowerToggle.Enabled then hum.JumpPower = getgenv().Player_JumpPowerValue end
end)

local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then OriginalWalkSpeed, OriginalJumpPower = hum.WalkSpeed, hum.JumpPower end
ESP()
Aimbot()
