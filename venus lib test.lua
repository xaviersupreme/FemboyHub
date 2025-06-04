local VENUS_LIB_URL = "https://raw.githubusercontent.com/weakhoes/Roblox-UI-Libs/refs/heads/main/Venus%20Lib/Venus%20Lib%20Source.lua"
local VenusLoadSuccess, Venus = pcall(loadstring(game:HttpGet(VENUS_LIB_URL)))

if not VenusLoadSuccess or not Venus then
    warn("FEMBOY HUB CRITICAL ERROR: Failed to load Venus UI Library from: " .. VENUS_LIB_URL)
    warn("Error: " .. tostring(Venus))
    game:GetService("CoreGui"):FindFirstChild("FemboyHubErrorGui")_DESTR0Y_()
    local errGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
    errGui.Name = "FemboyHubError"
    errGui.ResetOnSpawn = false
    local errMsg = Instance.new("TextLabel", errGui)
    errMsg.Size = UDim2.new(1, -20, 0, 100)
    errMsg.Position = UDim2.new(0, 10, 0.5, -50)
    errMsg.BackgroundColor3 = Color3.fromRGB(20,20,20)
    errMsg.BorderColor3 = Color3.fromRGB(255,0,0)
    errMsg.BorderSizePixel = 2
    errMsg.TextColor3 = Color3.fromRGB(255, 50, 50)
    errMsg.Font = Enum.Font.SourceSansSemibold
    errMsg.TextSize = 18
    errMsg.TextWrapped = true
    errMsg.Text = "FEMBOY HUB CRITICAL ERROR:\nFailed to load the Venus UI Library. This script cannot function.\n\nPossible reasons:\n- No internet connection.\n- The library URL is incorrect or the source is down.\n- Your executor doesn't support HttpGet or loadstring correctly.\n\nPlease check the console (F9) for more details."
    return
end
_G.Venus = Venus

local FemboyHub = {
    Name = "Femboy Hub",
    Version = "3.7.2",
    Author = "Xavier :3",
    DebugMode = false,

    Services = {},
    Player = {},
    Camera = nil,
    Mouse = nil,

    Settings = {},
    RuntimeState = {},
    Logic = {},
    UI = {Elements = {}, Window = nil, Tabs = {}, Sections = {}},
    Utils = {},
    Connections = {},
    DrawingCache = {},
    
    Constants = {
        DefaultWalkSpeed = 16,
        DefaultJumpPower = 50,
        MaxRaycastDistance = 10000,
        HumanoidRigTypes = { R6 = "R6", R15 = "R15", Unknown = "Unknown" },
    }
}

function FemboyHub:Log(message)
    if self.DebugMode then
        print("[" .. self.Name .. " Debug] " .. tostring(message))
    end
end

function FemboyHub:LoadServices()
    local servicesToGet = {
        "Players", "RunService", "UserInputService", "Workspace", "CoreGui", "Lighting",
        "Stats", "TeleportService", "TweenService", "HttpService", "SoundService", "TextService"
    }
    for _, name in ipairs(servicesToGet) do
        local success, service = pcall(function() return game:GetService(name) end)
        if success and service then
            self.Services[name] = service
            self:Log("Loaded Service: " .. name)
        else
            warn("[" .. self.Name .. "] Failed to load service: " .. name .. " (" .. tostring(service) .. ")")
        end
    end

    if self.Services.Players then
        self.Player.Local = self.Services.Players.LocalPlayer
        if not self.Player.Local then
            repeat task.wait() 
                   self.Player.Local = self.Services.Players.LocalPlayer
            until self.Player.Local
        end
        self.Mouse = self.Player.Local:GetMouse()
    end
    if self.Services.Workspace then
        self.Camera = self.Services.Workspace.CurrentCamera
    end
    self:Log("Essential references set up.")
end

FemboyHub.Utils = {
    GetCharacter = function(player)
        player = player or FemboyHub.Player.Local
        return player and player.Character
    end,

    GetHumanoid = function(player)
        player = player or FemboyHub.Player.Local
        local char = FemboyHub.Utils.GetCharacter(player)
        return char and char:FindFirstChildOfClass("Humanoid")
    end,

    GetRootPart = function(player)
        player = player or FemboyHub.Player.Local
        local char = FemboyHub.Utils.GetCharacter(player)
        if not char then return nil end
        return char.PrimaryPart or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end,

    GetPlayerTeam = function(player)
        player = player or FemboyHub.Player.Local
        return player and player.Team
    end,

    IsTeamMate = function(player1, player2)
        player1 = player1 or FemboyHub.Player.Local
        if not player1 or not player2 then return false end
        local team1 = FemboyHub.Utils.GetPlayerTeam(player1)
        local team2 = FemboyHub.Utils.GetPlayerTeam(player2)
        return team1 and team2 and team1 == team2
    end,

    GetHumanoidRigType = function(humanoid)
        if not humanoid then return FemboyHub.Constants.HumanoidRigTypes.Unknown end
        return humanoid.RigType == Enum.HumanoidRigType.R6 and FemboyHub.Constants.HumanoidRigTypes.R6 or FemboyHub.Constants.HumanoidRigTypes.R15
    end,

    WorldToViewportPoint = function(worldPos)
        if not FemboyHub.Camera then return Vector2.new(), false, 0 end
        local screenPos, onScreen = FemboyHub.Camera:WorldToViewportPoint(worldPos)
        return Vector2.new(screenPos.X, screenPos.Y), onScreen, screenPos.Z
    end,

    Raycast = function(origin, direction, distance, ignoreList)
        ignoreList = ignoreList or {FemboyHub.Utils.GetCharacter(FemboyHub.Player.Local), FemboyHub.Camera}
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = ignoreList
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local result = FemboyHub.Services.Workspace:Raycast(origin, direction * distance, rayParams)
        return result
    end,

    CheckVisibility = function(targetPart, customOrigin)
        if not targetPart or not targetPart.Parent then return false end
        local origin = customOrigin or (FemboyHub.Camera and FemboyHub.Camera.CFrame.Position)
        if not origin then return false end

        local distance = (targetPart.Position - origin).Magnitude
        if distance < 1 then return true end

        local result = FemboyHub.Utils.Raycast(origin, (targetPart.Position - origin).Unit, distance - 0.1)

        if result and result.Instance then
            return result.Instance:IsDescendantOf(targetPart.Parent) or result.Instance == targetPart
        end
        return true
    end,

    GetPlayers = function(options)
        options = options or {}
        local playersList = {}
        for _, player in ipairs(FemboyHub.Services.Players:GetPlayers()) do
            if not options.IncludeSelf and player == FemboyHub.Player.Local then continue end
            
            local char = FemboyHub.Utils.GetCharacter(player)
            local hum = FemboyHub.Utils.GetHumanoid(player)
            if not char or not hum or hum.Health <= 0 then continue end

            if options.TeamCheck and FemboyHub.Settings.Global.TeamCheck and FemboyHub.Utils.IsTeamMate(FemboyHub.Player.Local, player) then continue end
            if options.IgnoreNPCs and player.UserId <= 0 then continue end
            if options.MaxDistance and (FemboyHub.Utils.GetRootPart(FemboyHub.Player.Local).Position - FemboyHub.Utils.GetRootPart(player).Position).Magnitude > options.MaxDistance then continue end
            if options.VisibilityCheck and not FemboyHub.Utils.CheckVisibility(FemboyHub.Utils.GetRootPart(player)) then continue end
            
            table.insert(playersList, player)
        end
        return playersList
    end,

    GetDrawing = function(id, className, group)
        group = group or "Default"
        FemboyHub.DrawingCache[group] = FemboyHub.DrawingCache[group] or {}
        FemboyHub.DrawingCache[group][id] = FemboyHub.DrawingCache[group][id] or {}

        for _, obj in ipairs(FemboyHub.DrawingCache[group][id]) do
            if not obj.InUse and obj.ClassName == className then
                obj.InUse = true
                obj.Visible = false
                return obj
            end
        end

        local newObj = Drawing.new(className)
        newObj.InUse = true
        newObj.Visible = false
        newObj.ClassName = className
        table.insert(FemboyHub.DrawingCache[group][id], newObj)
        return newObj
    end,

    ReleaseDrawings = function(group, id)
        if id and group and FemboyHub.DrawingCache[group] and FemboyHub.DrawingCache[group][id] then
            for _, obj in ipairs(FemboyHub.DrawingCache[group][id]) do
                obj.InUse = false
                obj.Visible = false
            end
        elseif group and FemboyHub.DrawingCache[group] then
             for _, idCache in pairs(FemboyHub.DrawingCache[group]) do
                for _, obj in ipairs(idCache) do
                    obj.InUse = false
                    obj.Visible = false
                end
            end
        end
    end,
    
    CleanupDrawings = function()
        for groupName, groupCache in pairs(FemboyHub.DrawingCache) do
            for idName, idCache in pairs(groupCache) do
                for i = #idCache, 1, -1 do
                    local obj = idCache[i]
                    if not obj.InUse then
                        obj:Remove()
                        table.remove(idCache, i)
                    end
                end
                 if #idCache == 0 then FemboyHub.DrawingCache[groupName][idName] = nil end
            end
            if next(FemboyHub.DrawingCache[groupName]) == nil then FemboyHub.DrawingCache[groupName] = nil end
        end
    end,

    IsValidVector = function(vec)
        return typeof(vec) == "Vector3" and vec.X == vec.X
    end,

    CreateNotification = function(title, text, duration, color)
        if FemboyHub.Settings.Global.ShowNotifications and FemboyHub.UI.Window and Venus.Notify then
            Venus:Notify({
                Title = title or FemboyHub.Name,
                Text = text,
                Duration = duration or 3,
                Color = color
            })
        else
            print("[" .. (title or FemboyHub.Name) .. "] " .. text)
        end
    end,
}

FemboyHub.Settings = {
    Global = {
        MasterToggleKey = Enum.KeyCode.RightShift,
        TeamCheck = true,
        ShowNotifications = true,
        ConfigName = "DefaultFemboyConfig",
    },
    ESP = {
        Enabled = false,
        MasterKey = {Key = Enum.KeyCode.None, Mode = "Toggle"},
        
        PlayerESP = {
            Enabled = true,
            Boxes = true,
            BoxType = "2D",
            BoxColor = Color3.fromRGB(255, 0, 255),
            BoxVisibleColor = Color3.fromRGB(0, 255, 255),
            BoxOutlineColor = Color3.fromRGB(0,0,0),
            Names = true,
            NameColor = Color3.fromRGB(255, 105, 180),
            HealthBars = true,
            HealthBarType = "HorizontalTop",
            HealthColorDynamic = true,
            HealthColorHigh = Color3.fromRGB(0, 255, 0),
            HealthColorMid = Color3.fromRGB(255,255,0),
            HealthColorLow = Color3.fromRGB(255, 0, 0),
            Skeletons = false,
            SkeletonColor = Color3.fromRGB(200, 200, 200),
            SkeletonVisibleColor = Color3.fromRGB(255,255,255),
            Tracers = false,
            TracerColor = Color3.fromRGB(255, 255, 0),
            TracerOrigin = "BottomScreen",
            TracerThickness = 1,
            Distance = false,
            DistanceColor = Color3.fromRGB(220, 220, 220),
            Weapon = false,
            WeaponColor = Color3.fromRGB(150,150,255),
            OffScreenArrows = true,
            ArrowColor = Color3.fromRGB(255,100,0),
            ArrowSize = 20,
            ArrowRadius = 150,
            MaxDistance = 800,
            MinTextSize = 8,
            MaxTextSize = 14,
            TextOutline = true,
            TargetNPCs = false,
            OnlyVisible = false,
        },
        ObjectESP = {
            Enabled = false,
            Filter = {"Tool", "Part"},
            ShowNames = true,
            ShowDistance = true,
            Color = Color3.fromRGB(0,255,0),
            MaxDistance = 200,
        },
        Chams = {
            Enabled = false,
            Mode = "SolidColor",
            VisibleColor = Color3.fromRGB(0,255,0),
            OccludedColor = Color3.fromRGB(255,0,0),
            Transparency = 0.5,
            ApplyToArms = true,
        }
    },
    Aimbot = {
        Enabled = false,
        AimKey = {Key = Enum.KeyCode.E, Mode = "Hold"},
        TargetParts = {"Head", "UpperTorso", "HumanoidRootPart"},
        TargetSelection = "CrosshairDistance",
        FieldOfView = 120,
        ShowFOV = true,
        FOVCircleColor = Color3.fromRGB(255, 255, 255),
        FOVSides = 32,
        Smoothing = {
            Enabled = true,
            Factor = 5,
            Dynamic = true,
        },
        Prediction = {
            Enabled = true,
            VelocityFactor = 0.07,
            GravityFactor = 0.005,
        },
        VisibilityCheck = true,
        TargetNPCs = false,
        TargetFriends = false,
        SilentAim = {
            Enabled = false, 
            Mode = "CameraManipulate",
        },
        RecoilControlSystem = {
            Enabled = false,
            StrengthVertical = 0.8,
            StrengthHorizontal = 0.5,
            Timing = "OnFire",
        },
        Triggerbot = {
            Enabled = false,
            TriggerKey = {Key = Enum.KeyCode.LeftAlt, Mode = "Hold"},
            Delay = 0.05,
            OnlyScoped = false,
            CheckFriendly = true,
            CheckWall = true,
        },
        AimLock = false,
        AutoWall = {
            Enabled = false, 
            MaxPenetrationDepth = 2,
        }
    },
    PlayerMods = {
        WalkSpeed = { Enabled = false, Value = 32, Original = 16, Key = {Key = Enum.KeyCode.None, Mode = "Toggle"} },
        JumpPower = { Enabled = false, Value = 75, Original = 50, Key = {Key = Enum.KeyCode.None, Mode = "Toggle"} },
        HipHeight = { Enabled = false, Value = 0.1, Original = nil },
        Noclip = { Enabled = false, Key = {Key = Enum.KeyCode.N, Mode = "Toggle"} },
        Fly = { Enabled = false, Speed = 2, SprintSpeed = 5, Key = {Key = Enum.KeyCode.F, Mode = "Toggle"} },
        InfiniteJump = { Enabled = false, Key = {Key = Enum.KeyCode.None, Mode = "Toggle"} },
        NoFallDamage = { Enabled = false },
        AntiAFK = { Enabled = false, Interval = 60 },
        BTools = { Enabled = false, Key = {Key = Enum.KeyCode.None, Mode = "Toggle"} },
        ClickTeleport = { Enabled = false, Key = {Key = Enum.KeyCode.X, Mode = "Hold"}, MaxDistance = 500, ShowMarker = true },
        GodMode = { Enabled = false },
        InfiniteStamina = { Enabled = false },
        CharacterVisuals = {
            Highlight = { Enabled = false, Color = Color3.fromRGB(255,255,0), FillTransparency = 0.5, OutlineTransparency = 0 },
            ForceField = { Enabled = false },
        }
    },
    VisualTweaks = {
        FullBright = { Enabled = false },
        RemoveFog = { Enabled = false, OriginalStart = nil, OriginalEnd = nil, OriginalColor = nil },
        SkyboxChanger = { Enabled = false, CurrentSkybox = "Default", CustomSkyboxID = "" },
        NoParticles = { Enabled = false },
        NoDecals = { Enabled = false },
        NoTextures = { Enabled = false },
        ThirdPerson = { Enabled = false, Distance = 15},
        FirstPerson = { Enabled = true },
        FreeCam = { Enabled = false, Speed = 1, Key = {Key = Enum.KeyCode.None, Mode = "Toggle"} },
    },
    Misc = {
        ServerHop = { Enabled = false, AutoRejoin = false },
        ChatSpammer = { Enabled = false, Message = "Femboy Hub User!", Delay = 5, Mode = "RandomPlayer", RandomMessages = {"Hello!", "Nice shot!", "GG!"} },
        AutoFarm = { Enabled = false },
        UnlockMouse = { Enabled = false },
        CustomCrosshair = {
            Enabled = false,
            Type = "Dot",
            Color = Color3.fromRGB(0,255,0),
            Size = 5,
            Thickness = 1,
            Gap = 3,
        },
        FPSUnlocker = { Enabled = false },
        StreamerMode = { Enabled = false, HideNames = true, ObfuscateSelfName = true },
        Watermark = { Enabled = true, Text = FemboyHub.Name .. " " .. FemboyHub.Version, Position = "TopLeft", Color = Color3.fromRGB(255,182,193) }
    },
    UITheme = {
        CurrentTheme = "FemboyPink",
        AccentColor = Color3.fromRGB(255, 105, 180),
        BackgroundColor = Color3.fromRGB(30, 30, 40),
        TextColor = Color3.fromRGB(240, 240, 240),
        Font = "SourceSansSemibold",
    }
}

FemboyHub.RuntimeState = {
    Aimbot = {
        Target = nil,
        IsAiming = false,
        LastFireTime = 0,
    },
    PlayerMods = {
        Fly = { BodyGyro = nil, BodyVelocity = nil, IsFlying = false },
        Noclip = { OriginalCollisions = {}, IsNoclipping = false },
        OriginalWalkSpeed = FemboyHub.Constants.DefaultWalkSpeed,
        OriginalJumpPower = FemboyHub.Constants.DefaultJumpPower,
        OriginalHipHeight = nil,
        BToolsInstance = nil,
        ClickTeleportMarker = nil,
    },
    VisualTweaks = {
        OriginalFog = {},
        FreeCamObj = { CFrame = nil, IsActive = false },
    },
    Keybinds = {},
    MainLoopConnection = nil,
    CharacterAddedConnection = nil,
    CharacterRemovingConnection = nil,
    InputBeganConnection = nil,
    InputEndedConnection = nil,
    RenderSteppedFPS = 0,
    SteppedDeltaTime = 0,
}

FemboyHub.Logic.ESP = {
    BonesR15 = {
        Head = {"Head", "Neck"}, Torso = {"Neck", "UpperTorso", "UpperTorso", "LeftUpperArm", "UpperTorso", "RightUpperArm", "UpperTorso", "LowerTorso"},
        LeftArm = {"LeftUpperArm", "LeftLowerArm", "LeftLowerArm", "LeftHand"}, RightArm = {"RightUpperArm", "RightLowerArm", "RightLowerArm", "RightHand"},
        LeftLeg = {"LowerTorso", "LeftUpperLeg", "LeftUpperLeg", "LeftLowerLeg", "LeftLowerLeg", "LeftFoot"}, RightLeg = {"LowerTorso", "RightUpperLeg", "RightUpperLeg", "RightLowerLeg", "RightLowerLeg", "RightFoot"},
    },
    BonesR6 = {
        Head = {"Head", "Torso"}, Body = {"Torso", "Left Arm", "Torso", "Right Arm", "Torso", "Left Leg", "Torso", "Right Leg"},
    },
    Update = function()
        if not FemboyHub.Settings.ESP.Enabled then FemboyHub.Utils.ReleaseDrawings("ESP"); return end
        FemboyHub.Utils.ReleaseDrawings("ESP")

        local S_ESP = FemboyHub.Settings.ESP
        local S_PlayerESP = S_ESP.PlayerESP
        local Cam = FemboyHub.Camera
        local LocalChar = FemboyHub.Utils.GetCharacter()
        if not Cam or not LocalChar then return end
        local ViewportSize = Cam.ViewportSize

        if FemboyHub.Settings.Misc.Watermark.Enabled then
            local watermark = FemboyHub.Utils.GetDrawing("WatermarkText", "Watermark", "Text")
            watermark.Text = FemboyHub.Settings.Misc.Watermark.Text
            watermark.Color = FemboyHub.Settings.Misc.Watermark.Color
            watermark.Size = 14
            watermark.Outline = true
            watermark.OutlineColor = Color3.new(0,0,0)
            if FemboyHub.Settings.Misc.Watermark.Position == "TopLeft" then
                watermark.Position = Vector2.new(5,5)
            elseif FemboyHub.Settings.Misc.Watermark.Position == "TopRight" then
                local textSize = FemboyHub.Services.TextService:GetTextSize(watermark.Text, watermark.Size, Enum.Font.SourceSans, Vector2.new(ViewportSize.X, ViewportSize.Y))
                watermark.Position = Vector2.new(ViewportSize.X - textSize.X - 5, 5)
            end
            watermark.Visible = true
        end

        if FemboyHub.Settings.Misc.CustomCrosshair.Enabled then
            local CH_S = FemboyHub.Settings.Misc.CustomCrosshair
            local center = ViewportSize / 2
            if CH_S.Type == "Dot" then
                local dot = FemboyHub.Utils.GetDrawing("CrosshairDot", "Crosshair", "Circle")
                dot.Radius = CH_S.Size / 2
                dot.Color = CH_S.Color
                dot.Filled = true
                dot.NumSides = 12
                dot.Position = center
                dot.Visible = true
            elseif CH_S.Type == "Cross" then
                local L1 = FemboyHub.Utils.GetDrawing("CH_L1", "Crosshair", "Line")
                L1.From = Vector2.new(center.X - CH_S.Size - CH_S.Gap, center.Y); L1.To = Vector2.new(center.X - CH_S.Gap, center.Y)
                L1.Color = CH_S.Color; L1.Thickness = CH_S.Thickness; L1.Visible = true;
                local L2 = FemboyHub.Utils.GetDrawing("CH_L2", "Crosshair", "Line")
                L2.From = Vector2.new(center.X + CH_S.Gap, center.Y); L2.To = Vector2.new(center.X + CH_S.Size + CH_S.Gap, center.Y)
                L2.Color = CH_S.Color; L2.Thickness = CH_S.Thickness; L2.Visible = true;
                local L3 = FemboyHub.Utils.GetDrawing("CH_L3", "Crosshair", "Line")
                L3.From = Vector2.new(center.X, center.Y - CH_S.Size - CH_S.Gap); L3.To = Vector2.new(center.X, center.Y - CH_S.Gap)
                L3.Color = CH_S.Color; L3.Thickness = CH_S.Thickness; L3.Visible = true;
                local L4 = FemboyHub.Utils.GetDrawing("CH_L4", "Crosshair", "Line")
                L4.From = Vector2.new(center.X, center.Y + CH_S.Gap); L4.To = Vector2.new(center.X, center.Y + CH_S.Size + CH_S.Gap)
                L4.Color = CH_S.Color; L4.Thickness = CH_S.Thickness; L4.Visible = true;
            elseif CH_S.Type == "Circle" then
                 local circ = FemboyHub.Utils.GetDrawing("CrosshairCircle", "Crosshair", "Circle")
                 circ.Radius = CH_S.Size
                 circ.Color = CH_S.Color
                 circ.Filled = false
                 circ.Thickness = CH_S.Thickness
                 circ.NumSides = 24
                 circ.Position = center
                 circ.Visible = true
            end
        end


        if S_PlayerESP.Enabled then
            local players = FemboyHub.Utils.GetPlayers({
                TeamCheck = true,
                IgnoreNPCs = not S_PlayerESP.TargetNPCs,
                MaxDistance = S_PlayerESP.MaxDistance,
            })

            for i, player in ipairs(players) do
                local char = FemboyHub.Utils.GetCharacter(player)
                local hum = FemboyHub.Utils.GetHumanoid(player)
                local rootPart = FemboyHub.Utils.GetRootPart(player)
                if not (char and hum and rootPart) then continue end

                local isVisible = FemboyHub.Utils.CheckVisibility(rootPart)
                if S_PlayerESP.OnlyVisible and not isVisible then continue end
                
                local distance = (FemboyHub.Utils.GetRootPart(LocalChar).Position - rootPart.Position).Magnitude
                local uniquePlayerID = "PlayerESP_" .. player.UserId

                local modelCFrame, modelSize = char:GetBoundingBox()
                if not FemboyHub.Utils.IsValidVector(modelSize) or modelSize.X == 0 or modelSize.Y == 0 or modelSize.Z == 0 then 
                    modelSize = Vector3.new(4,6,2) 
                    modelCFrame = rootPart.CFrame * CFrame.new(0, -modelSize.Y/2 + hum.HipHeight, 0)
                end

                local cornersWorld = {
                    modelCFrame * Vector3.new(modelSize.X/2, modelSize.Y/2, modelSize.Z/2), modelCFrame * Vector3.new(modelSize.X/2, modelSize.Y/2, -modelSize.Z/2),
                    modelCFrame * Vector3.new(modelSize.X/2, -modelSize.Y/2, modelSize.Z/2), modelCFrame * Vector3.new(modelSize.X/2, -modelSize.Y/2, -modelSize.Z/2),
                    modelCFrame * Vector3.new(-modelSize.X/2, modelSize.Y/2, modelSize.Z/2), modelCFrame * Vector3.new(-modelSize.X/2, modelSize.Y/2, -modelSize.Z/2),
                    modelCFrame * Vector3.new(-modelSize.X/2, -modelSize.Y/2, modelSize.Z/2), modelCFrame * Vector3.new(-modelSize.X/2, -modelSize.Y/2, -modelSize.Z/2)
                }
                
                local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
                local anyCornerOnScreen = false
                for _, cornerPos in ipairs(cornersWorld) do
                    local screenPos, onScreen = FemboyHub.Utils.WorldToViewportPoint(cornerPos)
                    if onScreen then
                        anyCornerOnScreen = true
                        minX = math.min(minX, screenPos.X); minY = math.min(minY, screenPos.Y)
                        maxX = math.max(maxX, screenPos.X); maxY = math.max(maxY, screenPos.Y)
                    end
                end

                local rootScreenPos, rootOnScreen = FemboyHub.Utils.WorldToViewportPoint(rootPart.Position)
                if not anyCornerOnScreen and not rootOnScreen and not S_PlayerESP.OffScreenArrows then continue end

                if not anyCornerOnScreen and rootOnScreen then
                    local estimatedSize = math.clamp(ViewportSize.Y / rootScreenPos.Z * 10, 20, 200)
                    minX = rootScreenPos.X - estimatedSize/3; maxX = rootScreenPos.X + estimatedSize/3
                    minY = rootScreenPos.Y - estimatedSize/2; maxY = rootScreenPos.Y + estimatedSize/2
                end
                
                local boxWidth = maxX - minX
                local boxHeight = maxY - minY
                local boxColor = isVisible and S_PlayerESP.BoxVisibleColor or S_PlayerESP.BoxColor
                
                local textSizeScale = math.clamp(1 - (distance / S_PlayerESP.MaxDistance), 0.5, 1)
                local textSize = math.floor(math.clamp(S_PlayerESP.MinTextSize + (S_PlayerESP.MaxTextSize - S_PlayerESP.MinTextSize) * textSizeScale, S_PlayerESP.MinTextSize, S_PlayerESP.MaxTextSize))
                local textYOffset = minY - 2
                
                if S_PlayerESP.OffScreenArrows and (not anyCornerOnScreen or boxWidth <=0 or boxHeight <=0) then
                    local angle = math.atan2(rootScreenPos.Y - ViewportSize.Y/2, rootScreenPos.X - ViewportSize.X/2)
                    local arrowX = ViewportSize.X/2 + S_PlayerESP.ArrowRadius * math.cos(angle)
                    local arrowY = ViewportSize.Y/2 + S_PlayerESP.ArrowRadius * math.sin(angle)
                    
                    local arrow = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Arrow", "ESP", "Triangle")
                    arrow.PointA = Vector2.new(arrowX + S_PlayerESP.ArrowSize * math.cos(angle), arrowY + S_PlayerESP.ArrowSize * math.sin(angle))
                    arrow.PointB = Vector2.new(arrowX + S_PlayerESP.ArrowSize*0.5 * math.cos(angle + math.pi/2), arrowY + S_PlayerESP.ArrowSize*0.5 * math.sin(angle + math.pi/2))
                    arrow.PointC = Vector2.new(arrowX + S_PlayerESP.ArrowSize*0.5 * math.cos(angle - math.pi/2), arrowY + S_PlayerESP.ArrowSize*0.5 * math.sin(angle - math.pi/2))
                    arrow.Color = S_PlayerESP.ArrowColor
                    arrow.Filled = true
                    arrow.Visible = true
                    if S_PlayerESP.Distance then
                        local distText = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_ArrowDist", "ESP", "Text")
                        distText.Text = string.format("%dm", distance)
                        distText.Size = textSize * 0.8
                        distText.Color = S_PlayerESP.DistanceColor
                        distText.Outline = S_PlayerESP.TextOutline
                        distText.Position = Vector2.new(arrowX, arrowY - S_PlayerESP.ArrowSize - 5)
                        distText.Center = true
                        distText.Visible = true
                    end
                    continue
                end

                if not anyCornerOnScreen or boxWidth <=0 or boxHeight <=0 then continue end

                if S_PlayerESP.Boxes then
                    if S_PlayerESP.BoxType == "2D" then
                        local box = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Box2D", "ESP", "Quad")
                        box.PointA = Vector2.new(minX, minY); box.PointB = Vector2.new(maxX, minY)
                        box.PointC = Vector2.new(maxX, maxY); box.PointD = Vector2.new(minX, maxY)
                        box.Color = boxColor; box.Thickness = 1; box.Filled = false; box.Visible = true
                    elseif S_PlayerESP.BoxType == "2D_Filled" then
                        local box = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Box2DFill", "ESP", "Quad")
                        box.PointA = Vector2.new(minX, minY); box.PointB = Vector2.new(maxX, minY)
                        box.PointC = Vector2.new(maxX, maxY); box.PointD = Vector2.new(minX, maxY)
                        box.Color = boxColor; box.Transparency = 0.7; box.Filled = true; box.Visible = true
                        local outline = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Box2DFillOutline", "ESP", "Quad")
                        outline.PointA = Vector2.new(minX, minY); outline.PointB = Vector2.new(maxX, minY)
                        outline.PointC = Vector2.new(maxX, maxY); outline.PointD = Vector2.new(minX, maxY)
                        outline.Color = S_PlayerESP.BoxOutlineColor; outline.Thickness = 1; outline.Filled = false; outline.Visible = true
                    elseif S_PlayerESP.BoxType == "3D_Corner" then
                        local cornerLength = math.min(boxWidth, boxHeight) * 0.2
                        local cornersData = {
                            {minX, minY, minX+cornerLength, minY, minX, minY+cornerLength},
                            {maxX, minY, maxX-cornerLength, minY, maxX, minY+cornerLength},
                            {minX, maxY, minX+cornerLength, maxY, minX, maxY-cornerLength},
                            {maxX, maxY, maxX-cornerLength, maxY, maxX, maxY-cornerLength},
                        }
                        for ci, cData in ipairs(cornersData) do
                            local l1 = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_CornerL1_"..ci, "ESP", "Line")
                            l1.From = Vector2.new(cData[1], cData[2]); l1.To = Vector2.new(cData[3], cData[2])
                            l1.Color = boxColor; l1.Thickness = 1.5; l1.Visible = true;
                            local l2 = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_CornerL2_"..ci, "ESP", "Line")
                            l2.From = Vector2.new(cData[1], cData[2]); l2.To = Vector2.new(cData[1], cData[4])
                            l2.Color = boxColor; l2.Thickness = 1.5; l2.Visible = true;
                        end
                    end
                end

                if S_PlayerESP.Names then
                    local nameTxt = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Name", "ESP", "Text")
                    nameTxt.Text = FemboyHub.Settings.Misc.StreamerMode.Enabled and FemboyHub.Settings.Misc.StreamerMode.HideNames and "Player" or player.DisplayName
                    nameTxt.Size = textSize; nameTxt.Color = S_PlayerESP.NameColor; nameTxt.Outline = S_PlayerESP.TextOutline
                    nameTxt.Position = Vector2.new(minX + boxWidth/2, textYOffset - textSize); nameTxt.Center = true; nameTxt.Visible = true
                    textYOffset = textYOffset - textSize - 2
                end
                
                if S_PlayerESP.Distance then
                    local distTxt = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Dist", "ESP", "Text")
                    distTxt.Text = string.format("[%d m]", distance)
                    distTxt.Size = textSize * 0.9; distTxt.Color = S_PlayerESP.DistanceColor; distTxt.Outline = S_PlayerESP.TextOutline
                    distTxt.Position = Vector2.new(minX + boxWidth/2, textYOffset - (textSize*0.9)); distTxt.Center = true; distTxt.Visible = true
                    textYOffset = textYOffset - (textSize*0.9) - 2
                end

                if S_PlayerESP.Weapon then
                    local tool = char:FindFirstChildOfClass("Tool")
                    if tool then
                        local wepTxt = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Wep", "ESP", "Text")
                        wepTxt.Text = tool.Name
                        wepTxt.Size = textSize * 0.8; wepTxt.Color = S_PlayerESP.WeaponColor; wepTxt.Outline = S_PlayerESP.TextOutline
                        wepTxt.Position = Vector2.new(minX + boxWidth/2, maxY + 2); wepTxt.Center = true; wepTxt.Visible = true
                    end
                end

                if S_PlayerESP.HealthBars then
                    local hp = hum.Health / hum.MaxHealth
                    local healthColor = S_PlayerESP.HealthColorLow:Lerp(S_PlayerESP.HealthColorHigh, hp)
                    if S_PlayerESP.HealthColorDynamic then
                        if hp > 0.5 then healthColor = S_PlayerESP.HealthColorMid:Lerp(S_PlayerESP.HealthColorHigh, (hp-0.5)*2)
                        else healthColor = S_PlayerESP.HealthColorLow:Lerp(S_PlayerESP.HealthColorMid, hp*2) end
                    end
                    
                    local barHeight = math.max(3, boxHeight / 30)
                    local barWidth = math.max(3, boxWidth / 30)

                    if S_PlayerESP.HealthBarType == "HorizontalTop" then
                        local yPos = minY - barHeight - 2
                        local bg = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_HPBG_H", "ESP", "Line")
                        bg.From = Vector2.new(minX, yPos); bg.To = Vector2.new(maxX, yPos)
                        bg.Color = Color3.new(0.1,0.1,0.1); bg.Thickness = barHeight; bg.Visible = true
                        local fg = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_HPFG_H", "ESP", "Line")
                        fg.From = Vector2.new(minX, yPos); fg.To = Vector2.new(minX + boxWidth * hp, yPos)
                        fg.Color = healthColor; fg.Thickness = barHeight; fg.Visible = true
                    elseif S_PlayerESP.HealthBarType == "VerticalLeft" then
                        local xPos = minX - barWidth - 2
                        local bg = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_HPBG_VL", "ESP", "Line")
                        bg.From = Vector2.new(xPos, minY); bg.To = Vector2.new(xPos, maxY)
                        bg.Color = Color3.new(0.1,0.1,0.1); bg.Thickness = barWidth; bg.Visible = true
                        local fg = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_HPFG_VL", "ESP", "Line")
                        fg.From = Vector2.new(xPos, maxY - boxHeight * (1-hp)); fg.To = Vector2.new(xPos, maxY)
                        fg.Color = healthColor; fg.Thickness = barWidth; fg.Visible = true
                    end
                end

                if S_PlayerESP.Skeletons then
                    local skeletonColor = isVisible and S_PlayerESP.SkeletonVisibleColor or S_PlayerESP.SkeletonColor
                    local rigType = FemboyHub.Utils.GetHumanoidRigType(hum)
                    local bonesSet = (rigType == FemboyHub.Constants.HumanoidRigTypes.R15 and FemboyHub.Logic.ESP.BonesR15) or FemboyHub.Logic.ESP.BonesR6
                    
                    for boneGroupName, bonePairs in pairs(bonesSet) do
                        for bonePairIdx = 1, #bonePairs -1, 2 do
                            local p1Name, p2Name = bonePairs[bonePairIdx], bonePairs[bonePairIdx+1]
                            local p1, p2 = char:FindFirstChild(p1Name), char:FindFirstChild(p2Name)
                            if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                                local v1, onScreen1 = FemboyHub.Utils.WorldToViewportPoint(p1.Position)
                                local v2, onScreen2 = FemboyHub.Utils.WorldToViewportPoint(p2.Position)
                                if onScreen1 and onScreen2 then
                                    local boneLine = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Skel_" .. boneGroupName .. "_" .. bonePairIdx, "ESP", "Line")
                                    boneLine.From = v1; boneLine.To = v2
                                    boneLine.Color = skeletonColor; boneLine.Thickness = 1; boneLine.Visible = true
                                end
                            end
                        end
                    end
                end

                if S_PlayerESP.Tracers then
                    local tracer = FemboyHub.Utils.GetDrawing(uniquePlayerID .. "_Tracer", "ESP", "Line")
                    local originVec
                    if S_PlayerESP.TracerOrigin == "Mouse" then originVec = FemboyHub.Mouse.X, FemboyHub.Mouse.Y
                    elseif S_PlayerESP.TracerOrigin == "Crosshair" then originVec = ViewportSize.X/2, ViewportSize.Y/2
                    else originVec = ViewportSize.X/2, ViewportSize.Y end

                    tracer.From = Vector2.new(originVec)
                    tracer.To = rootScreenPos
                    tracer.Color = S_PlayerESP.TracerColor; tracer.Thickness = S_PlayerESP.TracerThickness; tracer.Visible = rootOnScreen
                end

                if S_ESP.Chams.Enabled then
                    local chamColor = isVisible and S_ESP.Chams.VisibleColor or S_ESP.Chams.OccludedColor
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") or part:IsA("Decal") then
                            FemboyHub.RuntimeState.ESP_OriginalPartProps = FemboyHub.RuntimeState.ESP_OriginalPartProps or {}
                            local partUID = player.UserId .. "_" .. part:GetFullName()
                            if not FemboyHub.RuntimeState.ESP_OriginalPartProps[partUID] then
                                FemboyHub.RuntimeState.ESP_OriginalPartProps[partUID] = {
                                    Color = part:IsA("BasePart") and part.Color or nil,
                                    Material = part:IsA("BasePart") and part.Material or nil,
                                    Transparency = part.Transparency,
                                    TextureID = part:IsA("Decal") and part.Texture or (part:IsA("Texture") and part.Texture or nil)
                                }
                            end

                            if part:IsA("BasePart") then
                                part.Material = Enum.Material.Plastic
                                part.Color = chamColor
                            end
                            part.Transparency = S_ESP.Chams.Transparency
                            if part:IsA("Decal") or part:IsA("Texture") then part.Texture = "" end
                        end
                    end
                elseif FemboyHub.RuntimeState.ESP_OriginalPartProps then
                    for partUID, props in pairs(FemboyHub.RuntimeState.ESP_OriginalPartProps) do
                        local userId, partPath = partUID:match("^(%d+)_(.+)$")
                        local p = FemboyHub.Services.Players:GetPlayerByUserId(tonumber(userId))
                        if p and p.Character then
                            local actualPart = p.Character:FindFirstChild(partPath, true)
                            if actualPart then
                                if actualPart:IsA("BasePart") then
                                    if props.Color then actualPart.Color = props.Color end
                                    if props.Material then actualPart.Material = props.Material end
                                end
                                actualPart.Transparency = props.Transparency
                                if (actualPart:IsA("Decal") or actualPart:IsA("Texture")) and props.TextureID then actualPart.Texture = props.TextureID end
                            end
                        end
                    end
                    FemboyHub.RuntimeState.ESP_OriginalPartProps = nil
                end

            end
        end

        if S_ESP.ObjectESP.Enabled then
            for _,obj in ipairs(FemboyHub.Services.Workspace:GetDescendants()) do
                local shouldEsp = false
                for _,filterName in ipairs(S_ESP.ObjectESP.Filter) do
                    if obj:IsA(filterName) or obj.Name == filterName then
                        shouldEsp = true; break
                    end
                end
                if shouldEsp then
                    local root = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                    if root then
                        local dist = (FemboyHub.Utils.GetRootPart(LocalChar).Position - root.Position).Magnitude
                        if dist <= S_ESP.ObjectESP.MaxDistance then
                            local screenPos, onScreen = FemboyHub.Utils.WorldToViewportPoint(root.Position)
                            if onScreen then
                                local objID = "ObjectESP_"..obj:GetFullName()
                                if S_ESP.ObjectESP.ShowNames then
                                    local nameTxt = FemboyHub.Utils.GetDrawing(objID .. "_Name", "ESP", "Text")
                                    nameTxt.Text = obj.Name
                                    nameTxt.Size = 10; nameTxt.Color = S_ESP.ObjectESP.Color; nameTxt.Outline = true
                                    nameTxt.Position = screenPos - Vector2.new(0,10); nameTxt.Center = true; nameTxt.Visible = true
                                end
                                if S_ESP.ObjectESP.ShowDistance then
                                     local distTxt = FemboyHub.Utils.GetDrawing(objID .. "_Dist", "ESP", "Text")
                                    distTxt.Text = string.format("[%dm]", dist)
                                    distTxt.Size = 9; distTxt.Color = S_ESP.ObjectESP.Color; distTxt.Outline = true
                                    distTxt.Position = screenPos + Vector2.new(0,2); distTxt.Center = true; distTxt.Visible = true
                                end
                            end
                        end
                    end
                end
            end
        end

        local AS = FemboyHub.Settings.Aimbot
        if AS.Enabled and AS.ShowFOV and (AS.AimKey.Mode == "Always" or FemboyHub.RuntimeState.Aimbot.IsAiming) then
            local fovCircle = FemboyHub.Utils.GetDrawing("AimbotFOVCircle", "Aimbot", "Circle")
            fovCircle.Radius = AS.FieldOfView
            fovCircle.Position = ViewportSize / 2
            fovCircle.Color = AS.FOVCircleColor; fovCircle.Thickness = 1; fovCircle.NumSides = AS.FOVSides; fovCircle.Filled = false; fovCircle.Visible = true
        else
            FemboyHub.Utils.ReleaseDrawings("Aimbot", "AimbotFOVCircle")
        end
    end
}

FemboyHub.Logic.Aimbot = {
    Update = function(deltaTime)
        local S_Aimbot = FemboyHub.Settings.Aimbot
        local RS_Aimbot = FemboyHub.RuntimeState.Aimbot
        
        if S_Aimbot.AimKey.Mode == "Always" then RS_Aimbot.IsAiming = true
        end

        if not S_Aimbot.Enabled or not RS_Aimbot.IsAiming then
            RS_Aimbot.Target = nil
            return
        end

        local potentialTargets = {}
        local players = FemboyHub.Utils.GetPlayers({
            TeamCheck = true,
            IgnoreNPCs = not S_Aimbot.TargetNPCs,
            MaxDistance = FemboyHub.Settings.ESP.PlayerESP.MaxDistance,
            VisibilityCheck = S_Aimbot.VisibilityCheck,
        })

        if #players == 0 then RS_Aimbot.Target = nil; return end

        local camCF = FemboyHub.Camera.CFrame
        local mousePos = FemboyHub.Services.UserInputService:GetMouseLocation()
        local screenCenter = FemboyHub.Camera.ViewportSize / 2

        for _, p in ipairs(players) do
            local char = FemboyHub.Utils.GetCharacter(p)
            local hum = FemboyHub.Utils.GetHumanoid(p)
            local root = FemboyHub.Utils.GetRootPart(p)
            if not (char and hum and root) then continue end

            for _, partName in ipairs(S_Aimbot.TargetParts) do
                local targetPart = char:FindFirstChild(partName)
                if targetPart and targetPart:IsA("BasePart") then
                    local partPos = targetPart.Position
                    if S_Aimbot.Prediction.Enabled and root.AssemblyLinearVelocity.Magnitude > 1 then
                        local travelTime = (partPos - camCF.Position).Magnitude / 300
                        partPos = partPos + (root.AssemblyLinearVelocity * travelTime)
                        partPos = partPos - Vector3.new(0, 0.5 * FemboyHub.Services.Workspace.Gravity * FemboyHub.Settings.Aimbot.Prediction.GravityFactor * travelTime^2, 0)
                    end

                    local screenPos, onScreen, depth = FemboyHub.Utils.WorldToViewportPoint(partPos)
                    if not onScreen then continue end
                    
                    local distToCrosshair = (screenPos - screenCenter).Magnitude
                    if distToCrosshair > S_Aimbot.FieldOfView then continue end
                    
                    if S_Aimbot.VisibilityCheck and not FemboyHub.Utils.CheckVisibility(targetPart, camCF.Position) then continue end
                    
                    table.insert(potentialTargets, {
                        Player = p, Part = targetPart, PredictedPos = partPos,
                        ScreenPos = screenPos, Depth = depth,
                        Distance = (camCF.Position - partPos).Magnitude,
                        CrosshairDist = distToCrosshair,
                        Health = hum.Health,
                    })
                    break
                end
            end
        end

        if #potentialTargets == 0 then RS_Aimbot.Target = nil; return end

        table.sort(potentialTargets, function(a,b)
            if S_Aimbot.TargetSelection == "CrosshairDistance" then return a.CrosshairDist < b.CrosshairDist end
            if S_Aimbot.TargetSelection == "Distance" then return a.Distance < b.Distance end
            if S_Aimbot.TargetSelection == "Health" then return a.Health < b.Health end
            return a.CrosshairDist < b.CrosshairDist
        end)
        
        RS_Aimbot.Target = potentialTargets[1]

        if RS_Aimbot.Target then
            local targetLookCF = CFrame.new(camCF.Position, RS_Aimbot.Target.PredictedPos)
            local newCF
            if S_Aimbot.SilentAim.Enabled then
                newCF = targetLookCF 
            elseif S_Aimbot.Smoothing.Enabled then
                local factor = S_Aimbot.Smoothing.Factor
                if S_Aimbot.Smoothing.Dynamic then
                    local angleToTarget = math.acos(math.clamp(camCF.LookVector:Dot((RS_Aimbot.Target.PredictedPos - camCF.Position).Unit), -1, 1))
                    factor = math.max(1, factor * (angleToTarget / (math.pi/4)))
                end
                newCF = camCF:Lerp(targetLookCF, 1 / math.max(1, factor))
            else
                newCF = targetLookCF
            end
            FemboyHub.Camera.CFrame = newCF

            if S_Aimbot.Triggerbot.Enabled and FemboyHub.RuntimeState.Keybinds["TriggerbotActive"] then
                local targetScreenPos = FemboyHub.Utils.WorldToViewportPoint(RS_Aimbot.Target.Part.Position)
                local crosshairDistToActual = (targetScreenPos - screenCenter).Magnitude
                if crosshairDistToActual < 10 then
                    if (tick() - RS_Aimbot.LastFireTime) > S_Aimbot.Triggerbot.Delay then
                        if FemboyHub.Mouse and FemboyHub.Mouse.Button1Down and FemboyHub.Mouse.Button1Up then
                            FemboyHub.Mouse:Button1Down(RS_Aimbot.Target.ScreenPos.X, RS_Aimbot.Target.ScreenPos.Y)
                            task.wait(0.03)
                            FemboyHub.Mouse:Button1Up(RS_Aimbot.Target.ScreenPos.X, RS_Aimbot.Target.ScreenPos.Y)
                            RS_Aimbot.LastFireTime = tick()
                            FemboyHub:Log("Triggerbot Fired")
                        end
                    end
                end
            end
        end
    end
}


FemboyHub.Logic.PlayerMods = {
    ApplyWalkSpeed = function(enable, value)
        local hum = FemboyHub.Utils.GetHumanoid()
        if not hum then return end
        if enable then
            if FemboyHub.RuntimeState.PlayerMods.OriginalWalkSpeed == FemboyHub.Constants.DefaultWalkSpeed then
                 FemboyHub.RuntimeState.PlayerMods.OriginalWalkSpeed = hum.WalkSpeed
            end
            hum.WalkSpeed = value
        else
            hum.WalkSpeed = FemboyHub.RuntimeState.PlayerMods.OriginalWalkSpeed
        end
        FemboyHub.Settings.PlayerMods.WalkSpeed.Enabled = enable
    end,
    ToggleNoclip = function()
        local S_Noclip = FemboyHub.Settings.PlayerMods.Noclip
        S_Noclip.Enabled = not S_Noclip.Enabled
        local RS_Noclip = FemboyHub.RuntimeState.PlayerMods.Noclip
        local char = FemboyHub.Utils.GetCharacter()
        if not char then S_Noclip.Enabled = false; return end

        RS_Noclip.IsNoclipping = S_Noclip.Enabled
        FemboyHub.Utils.CreateNotification("Noclip", RS_Noclip.IsNoclipping and "Enabled" or "Disabled")

        if RS_Noclip.IsNoclipping then
            RS_Noclip.OriginalCollisions = {}
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    RS_Noclip.OriginalCollisions[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
            local hum = FemboyHub.Utils.GetHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics) end
        else
            for part, canCollide in pairs(RS_Noclip.OriginalCollisions) do
                if part and part.Parent then part.CanCollide = canCollide end
            end
            RS_Noclip.OriginalCollisions = {}
            local hum = FemboyHub.Utils.GetHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Running) end
        end
    end,

    ToggleFly = function()
        local S_Fly = FemboyHub.Settings.PlayerMods.Fly
        S_Fly.Enabled = not S_Fly.Enabled
        local RS_Fly = FemboyHub.RuntimeState.PlayerMods.Fly
        local char = FemboyHub.Utils.GetCharacter()
        local root = FemboyHub.Utils.GetRootPart()
        local hum = FemboyHub.Utils.GetHumanoid()
        if not (char and root and hum) then S_Fly.Enabled = false; return end

        RS_Fly.IsFlying = S_Fly.Enabled
        FemboyHub.Utils.CreateNotification("Fly", RS_Fly.IsFlying and "Enabled" or "Disabled")

        if RS_Fly.IsFlying then
            if RS_Fly.BodyGyro then RS_Fly.BodyGyro:Destroy() end
            if RS_Fly.BodyVelocity then RS_Fly.BodyVelocity:Destroy() end

            RS_Fly.BodyGyro = Instance.new("BodyGyro", root)
            RS_Fly.BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            RS_Fly.BodyGyro.P = 20000
            RS_Fly.BodyGyro.D = 800

            RS_Fly.BodyVelocity = Instance.new("BodyVelocity", root)
            RS_Fly.BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            RS_Fly.BodyVelocity.P = 10000
            RS_Fly.BodyVelocity.Velocity = Vector3.new(0,0,0)
            hum:ChangeState(Enum.HumanoidStateType.Physics)
        else
            if RS_Fly.BodyGyro then RS_Fly.BodyGyro:Destroy(); RS_Fly.BodyGyro = nil end
            if RS_Fly.BodyVelocity then RS_Fly.BodyVelocity:Destroy(); RS_Fly.BodyVelocity = nil end
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            task.wait(0.1)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end,
    UpdateFly = function()
        local S_Fly = FemboyHub.Settings.PlayerMods.Fly
        local RS_Fly = FemboyHub.RuntimeState.PlayerMods.Fly
        if not RS_Fly.IsFlying or not RS_Fly.BodyGyro or not RS_Fly.BodyVelocity then return end
        
        local camCF = FemboyHub.Camera.CFrame
        local moveVector = Vector3.new()
        if FemboyHub.Services.UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector = moveVector + camCF.LookVector end
        if FemboyHub.Services.UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector = moveVector - camCF.LookVector end
        if FemboyHub.Services.UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector = moveVector - camCF.RightVector end
        if FemboyHub.Services.UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector = moveVector + camCF.RightVector end
        if FemboyHub.Services.UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector = moveVector + Vector3.new(0,1,0) end
        if FemboyHub.Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector = moveVector - Vector3.new(0,1,0) end

        local currentSpeed = FemboyHub.Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and S_Fly.SprintSpeed or S_Fly.Speed
        
        RS_Fly.BodyGyro.CFrame = camCF
        if moveVector.Magnitude > 0 then
            RS_Fly.BodyVelocity.Velocity = moveVector.Unit * currentSpeed * 30
        else
            RS_Fly.BodyVelocity.Velocity = Vector3.new(0,0,0)
        end
    end,
}

FemboyHub.Logic.VisualTweaks = {
    ApplyFullBright = function(enable)
        local Lighting = FemboyHub.Services.Lighting
        if enable then
            FemboyHub.RuntimeState.VisualTweaks.OriginalLighting = {
                Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, Brightness = Lighting.Brightness,
                GlobalShadows = Lighting.GlobalShadows, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd
            }
            Lighting.Ambient = Color3.fromRGB(180,180,180)
            Lighting.OutdoorAmbient = Color3.fromRGB(180,180,180)
            Lighting.Brightness = 0.5
            Lighting.GlobalShadows = false
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
        else
            if FemboyHub.RuntimeState.VisualTweaks.OriginalLighting then
                local OL = FemboyHub.RuntimeState.VisualTweaks.OriginalLighting
                Lighting.Ambient = OL.Ambient; Lighting.OutdoorAmbient = OL.OutdoorAmbient; Lighting.Brightness = OL.Brightness;
                Lighting.GlobalShadows = OL.GlobalShadows; Lighting.ClockTime = OL.ClockTime; Lighting.FogEnd = OL.FogEnd;
            end
        end
        FemboyHub.Settings.VisualTweaks.FullBright.Enabled = enable
    end,
}

FemboyHub.Logic.Misc = {
    UpdateWatermark = function()
    end,
    UpdateCustomCrosshair = function()
    end,
}

FemboyHub.UI.Create = function()
    FemboyHub.UI.Window = Venus:CreateWindow({
        Title = FemboyHub.Name .. " " .. FemboyHub.Version,
        Size = UDim2.fromOffset(650, 500),
        Theme = FemboyHub.Settings.UITheme.CurrentTheme,
        Draggable = true,
        RobloxLocked = false,
    })
    FemboyHub.UI.Window:Toggle(FemboyHub.Settings.Global.MasterToggleKey)

    local function createKeybindInput(section, settingPath, name)
        local keySetting = FemboyHub.Settings
        local pathParts = string.split(settingPath, ".")
        for i=1, #pathParts -1 do keySetting = keySetting[pathParts[i]] end
        local keybindName = pathParts[#pathParts]

        section:CreateKeybind({
            Name = name,
            Default = keySetting[keybindName].Key,
            Mode = keySetting[keybindName].Mode,
            Callback = function(newKey, newMode, isDown)
                keySetting[keybindName].Key = newKey
                keySetting[keybindName].Mode = newMode

                local stateKey = settingPath
                if newMode == "Toggle" then
                    if isDown == nil then
                         FemboyHub.RuntimeState.Keybinds[stateKey] = not FemboyHub.RuntimeState.Keybinds[stateKey]
                         if stateKey == "Aimbot.AimKey" then FemboyHub.RuntimeState.Aimbot.IsAiming = FemboyHub.RuntimeState.Keybinds[stateKey] end
                         if stateKey == "PlayerMods.Noclip.Key" then FemboyHub.Logic.PlayerMods.ToggleNoclip() end
                         if stateKey == "PlayerMods.Fly.Key" then FemboyHub.Logic.PlayerMods.ToggleFly() end
                         if stateKey == "Aimbot.Triggerbot.TriggerKey" then FemboyHub.RuntimeState.Keybinds["TriggerbotActive"] = FemboyHub.RuntimeState.Keybinds[stateKey] end
                    end
                elseif newMode == "Hold" then
                     FemboyHub.RuntimeState.Keybinds[stateKey] = isDown
                     if stateKey == "Aimbot.AimKey" then FemboyHub.RuntimeState.Aimbot.IsAiming = isDown end
                     if stateKey == "Aimbot.Triggerbot.TriggerKey" then FemboyHub.RuntimeState.Keybinds["TriggerbotActive"] = isDown end
                     if stateKey == "PlayerMods.ClickTeleport.Key" and isDown then FemboyHub.Logic.PlayerMods.ClickTeleport() end
                end
                FemboyHub:Log(name .. " Keybind: Key=" .. tostring(newKey) .. ", Mode=" .. newMode .. ", IsDown=" .. tostring(isDown) .. ", ActiveState=" .. tostring(FemboyHub.RuntimeState.Keybinds[stateKey]))
            end
        })
    end
    
    local TabESP = FemboyHub.UI.Window:CreateTab({Name = "ESP"})
    local SecPlayerESP = TabESP:CreateSection({Name = "Player ESP"})
    SecPlayerESP:CreateToggle({ Name = "Enable Player ESP", Default = FemboyHub.Settings.ESP.PlayerESP.Enabled, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.Enabled = v end })
    SecPlayerESP:CreateToggle({ Name = "Boxes", Default = FemboyHub.Settings.ESP.PlayerESP.Boxes, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.Boxes = v end })
    SecPlayerESP:CreateDropdown({ Name = "Box Type", Items = {"2D", "2D_Filled", "3D_Corner"}, Default = FemboyHub.Settings.ESP.PlayerESP.BoxType, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.BoxType = v end })
    SecPlayerESP:CreateToggle({ Name = "Names", Default = FemboyHub.Settings.ESP.PlayerESP.Names, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.Names = v end })
    SecPlayerESP:CreateColorpicker({Name = "Name Color", Default = FemboyHub.Settings.ESP.PlayerESP.NameColor, Callback = function(c) FemboyHub.Settings.ESP.PlayerESP.NameColor = c end})
    SecPlayerESP:CreateToggle({ Name = "Health Bars", Default = FemboyHub.Settings.ESP.PlayerESP.HealthBars, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.HealthBars = v end })
    SecPlayerESP:CreateToggle({ Name = "Skeletons", Default = FemboyHub.Settings.ESP.PlayerESP.Skeletons, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.Skeletons = v end })
    SecPlayerESP:CreateToggle({ Name = "Tracers", Default = FemboyHub.Settings.ESP.PlayerESP.Tracers, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.Tracers = v end })
    SecPlayerESP:CreateToggle({ Name = "Distance Text", Default = FemboyHub.Settings.ESP.PlayerESP.Distance, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.Distance = v end })
    SecPlayerESP:CreateToggle({ Name = "Off-Screen Arrows", Default = FemboyHub.Settings.ESP.PlayerESP.OffScreenArrows, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.OffScreenArrows = v end })
    SecPlayerESP:CreateSlider({ Name = "Max ESP Distance", Min = 50, Max = 2000, Default = FemboyHub.Settings.ESP.PlayerESP.MaxDistance, Increment = 25, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.MaxDistance = v end })
    SecPlayerESP:CreateToggle({ Name = "Target NPCs", Default = FemboyHub.Settings.ESP.PlayerESP.TargetNPCs, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.TargetNPCs = v end })
    SecPlayerESP:CreateToggle({ Name = "Only Visible Players", Default = FemboyHub.Settings.ESP.PlayerESP.OnlyVisible, Callback = function(v) FemboyHub.Settings.ESP.PlayerESP.OnlyVisible = v end })

    local SecChams = TabESP:CreateSection({Name = "Chams"})
    SecChams:CreateToggle({Name="Enable Chams", Default = FemboyHub.Settings.ESP.Chams.Enabled, Callback = function(v) FemboyHub.Settings.ESP.Chams.Enabled = v; if not v and FemboyHub.RuntimeState.ESP_OriginalPartProps then for _,props in pairs(FemboyHub.RuntimeState.ESP_OriginalPartProps) do task.spawn(function() FemboyHub.Logic.ESP.RestorePart(props.PartRef, props) end) end; FemboyHub.RuntimeState.ESP_OriginalPartProps = nil; end end})
    SecChams:CreateColorpicker({Name = "Visible Color", Default = FemboyHub.Settings.ESP.Chams.VisibleColor, Callback = function(c) FemboyHub.Settings.ESP.Chams.VisibleColor = c end})
    SecChams:CreateColorpicker({Name = "Occluded Color", Default = FemboyHub.Settings.ESP.Chams.OccludedColor, Callback = function(c) FemboyHub.Settings.ESP.Chams.OccludedColor = c end})
    SecChams:CreateSlider({Name = "Transparency", Min = 0, Max = 1, Default = FemboyHub.Settings.ESP.Chams.Transparency, Increment = 0.05, Callback = function(v) FemboyHub.Settings.ESP.Chams.Transparency = v end})

    local TabAimbot = FemboyHub.UI.Window:CreateTab({Name = "Aimbot"})
    local SecAimbotMain = TabAimbot:CreateSection({Name = "Main Aimbot"})
    SecAimbotMain:CreateToggle({ Name = "Enable Aimbot", Default = FemboyHub.Settings.Aimbot.Enabled, Callback = function(v) FemboyHub.Settings.Aimbot.Enabled = v end })
    createKeybindInput(SecAimbotMain, "Aimbot.AimKey", "Aimbot Key")
    SecAimbotMain:CreateDropdown({Name="Target Part Priority", Items = {"Head", "UpperTorso", "HumanoidRootPart"}, Default = FemboyHub.Settings.Aimbot.TargetParts[1], Multiple = true, Callback = function(t) FemboyHub.Settings.Aimbot.TargetParts = t end})
    SecAimbotMain:CreateDropdown({Name="Target Selection", Items = {"CrosshairDistance", "Distance", "Health"}, Default = FemboyHub.Settings.Aimbot.TargetSelection, Callback = function(v) FemboyHub.Settings.Aimbot.TargetSelection = v end})
    SecAimbotMain:CreateSlider({ Name = "Field of View", Min = 10, Max = 500, Default = FemboyHub.Settings.Aimbot.FieldOfView, Increment = 5, Callback = function(v) FemboyHub.Settings.Aimbot.FieldOfView = v end })
    SecAimbotMain:CreateToggle({ Name = "Show FOV Circle", Default = FemboyHub.Settings.Aimbot.ShowFOV, Callback = function(v) FemboyHub.Settings.Aimbot.ShowFOV = v end })
    SecAimbotMain:CreateToggle({ Name = "Visibility Check", Default = FemboyHub.Settings.Aimbot.VisibilityCheck, Callback = function(v) FemboyHub.Settings.Aimbot.VisibilityCheck = v end })
    
    local SecAimbotExtra = TabAimbot:CreateSection({Name = "Aimbot Enhancements"})
    SecAimbotExtra:CreateToggle({ Name = "Smoothing", Default = FemboyHub.Settings.Aimbot.Smoothing.Enabled, Callback = function(v) FemboyHub.Settings.Aimbot.Smoothing.Enabled = v end })
    SecAimbotExtra:CreateSlider({ Name = "Smooth Factor", Min = 1, Max = 30, Default = FemboyHub.Settings.Aimbot.Smoothing.Factor, Increment = 1, Callback = function(v) FemboyHub.Settings.Aimbot.Smoothing.Factor = v end })
    SecAimbotExtra:CreateToggle({ Name = "Prediction", Default = FemboyHub.Settings.Aimbot.Prediction.Enabled, Callback = function(v) FemboyHub.Settings.Aimbot.Prediction.Enabled = v end })
    SecAimbotExtra:CreateToggle({ Name = "Silent Aim (Snappy)", Default = FemboyHub.Settings.Aimbot.SilentAim.Enabled, Callback = function(v) FemboyHub.Settings.Aimbot.SilentAim.Enabled = v end })

    local SecTrigger = TabAimbot:CreateSection({Name = "Triggerbot"})
    SecTrigger:CreateToggle({Name="Enable Triggerbot", Default = FemboyHub.Settings.Aimbot.Triggerbot.Enabled, Callback = function(v)FemboyHub.Settings.Aimbot.Triggerbot.Enabled = v end})
    createKeybindInput(SecTrigger, "Aimbot.Triggerbot.TriggerKey", "Trigger Key")
    SecTrigger:CreateSlider({Name="Delay (ms)", Min=0, Max=500, Default=FemboyHub.Settings.Aimbot.Triggerbot.Delay*1000, Increment=10, Callback = function(v)FemboyHub.Settings.Aimbot.Triggerbot.Delay = v/1000 end})

    local TabPlayer = FemboyHub.UI.Window:CreateTab({Name = "Player"})
    local SecMovement = TabPlayer:CreateSection({Name = "Movement Mods"})
    SecMovement:CreateToggle({Name="WalkSpeed", Default=FemboyHub.Settings.PlayerMods.WalkSpeed.Enabled, Callback = function(v) FemboyHub.Logic.PlayerMods.ApplyWalkSpeed(v, FemboyHub.Settings.PlayerMods.WalkSpeed.Value) end})
    SecMovement:CreateSlider({Name="Speed Value", Min=16,Max=200,Default=FemboyHub.Settings.PlayerMods.WalkSpeed.Value,Increment=1,Callback=function(v)FemboyHub.Settings.PlayerMods.WalkSpeed.Value=v;if FemboyHub.Settings.PlayerMods.WalkSpeed.Enabled then FemboyHub.Logic.PlayerMods.ApplyWalkSpeed(true,v)end end})
    SecMovement:CreateToggle({Name="Noclip", Default=FemboyHub.Settings.PlayerMods.Noclip.Enabled, Callback = function(v) if FemboyHub.Settings.PlayerMods.Noclip.Enabled ~= v then FemboyHub.Logic.PlayerMods.ToggleNoclip() end end})
    createKeybindInput(SecMovement, "PlayerMods.Noclip.Key", "Noclip Key")
    SecMovement:CreateToggle({Name="Fly", Default=FemboyHub.Settings.PlayerMods.Fly.Enabled, Callback = function(v) if FemboyHub.Settings.PlayerMods.Fly.Enabled ~= v then FemboyHub.Logic.PlayerMods.ToggleFly() end end})
    createKeybindInput(SecMovement, "PlayerMods.Fly.Key", "Fly Key")
    SecMovement:CreateSlider({Name="Fly Speed", Min=1, Max=10, Default=FemboyHub.Settings.PlayerMods.Fly.Speed, Callback=function(v)FemboyHub.Settings.PlayerMods.Fly.Speed=v end})
    SecMovement:CreateSlider({Name="Fly Sprint Speed", Min=2, Max=20, Default=FemboyHub.Settings.PlayerMods.Fly.SprintSpeed, Callback=function(v)FemboyHub.Settings.PlayerMods.Fly.SprintSpeed=v end})

    local TabVisuals = FemboyHub.UI.Window:CreateTab({Name = "Visuals"})
    local SecWorldVis = TabVisuals:CreateSection({Name = "World Visuals"})
    SecWorldVis:CreateToggle({Name="Full Bright", Default=FemboyHub.Settings.VisualTweaks.FullBright.Enabled, Callback=function(v)FemboyHub.Logic.VisualTweaks.ApplyFullBright(v)end})

    local SecClientVis = TabVisuals:CreateSection({Name = "Client Visuals"})
    SecClientVis:CreateToggle({Name="Custom Crosshair", Default=FemboyHub.Settings.Misc.CustomCrosshair.Enabled, Callback=function(v)FemboyHub.Settings.Misc.CustomCrosshair.Enabled = v end})
    SecClientVis:CreateDropdown({Name="Crosshair Type", Items={"Dot", "Cross", "Circle"}, Default=FemboyHub.Settings.Misc.CustomCrosshair.Type, Callback=function(v)FemboyHub.Settings.Misc.CustomCrosshair.Type=v end})
    SecClientVis:CreateColorpicker({Name="Crosshair Color", Default=FemboyHub.Settings.Misc.CustomCrosshair.Color, Callback=function(c)FemboyHub.Settings.Misc.CustomCrosshair.Color=c end})
    SecClientVis:CreateSlider({Name="Crosshair Size", Min=1, Max=20, Default=FemboyHub.Settings.Misc.CustomCrosshair.Size, Callback=function(v)FemboyHub.Settings.Misc.CustomCrosshair.Size=v end})

    local TabMisc = FemboyHub.UI.Window:CreateTab({Name = "Misc"})
    local SecGeneralMisc = TabMisc:CreateSection({Name = "General"})
    SecGeneralMisc:CreateToggle({Name="Watermark", Default=FemboyHub.Settings.Misc.Watermark.Enabled, Callback=function(v) FemboyHub.Settings.Misc.Watermark.Enabled=v end})
    SecGeneralMisc:CreateTextbox({Name="Watermark Text", Default=FemboyHub.Settings.Misc.Watermark.Text, Placeholder="Enter watermark text...", Callback=function(t)FemboyHub.Settings.Misc.Watermark.Text = t end})
    SecGeneralMisc:CreateKeybind({ Name = "Master UI Toggle Key", Default = FemboyHub.Settings.Global.MasterToggleKey, Mode = "Toggle", Callback = function(key) FemboyHub.Settings.Global.MasterToggleKey = key; FemboyHub.UI.Window:Toggle(key) end })
    
    local SecConfigs = TabMisc:CreateSection({Name="Configuration (Conceptual)"})
    SecConfigs:CreateLabel({Name="Save/Load functionality is executor dependent and not fully implemented here."})
    SecConfigs:CreateTextbox({Name="Config Name", Default=FemboyHub.Settings.Global.ConfigName, Callback=function(v) FemboyHub.Settings.Global.ConfigName=v end})
    SecConfigs:CreateButton({Name="Save Config", Callback=function() FemboyHub.Utils.CreateNotification(FemboyHub.Name, "Config saving is conceptual.") end})
    SecConfigs:CreateButton({Name="Load Config", Callback=function() FemboyHub.Utils.CreateNotification(FemboyHub.Name, "Config loading is conceptual.") end})

    FemboyHub.UI.Window:SelectTab(1)
    FemboyHub:Log("UI Created Successfully.")
end

function FemboyHub:Initialize()
    self:Log("Initializing Femboy Hub " .. self.Version)
    self:LoadServices()

    if self.Player.Local and self.Player.Local.Character then
        local hum = self.Utils.GetHumanoid()
        if hum then
            self.RuntimeState.PlayerMods.OriginalWalkSpeed = hum.WalkSpeed
            self.RuntimeState.PlayerMods.OriginalJumpPower = hum.JumpPower
            self.RuntimeState.PlayerMods.OriginalHipHeight = hum.HipHeight
        end
    end

    local success, err = pcall(self.UI.Create, self)
    if not success then
        warn("[" .. self.Name .. "] CRITICAL UI ERROR: " .. tostring(err))
        self.Utils.CreateNotification(self.Name .. " UI Error", "Failed to create UI. Check console (F9). Some features may not be configurable.", 10)
    end

    self.RuntimeState.MainLoopConnection = self.Services.RunService.RenderStepped:Connect(function(deltaTime)
        pcall(self.Logic.ESP.Update, self.Logic.ESP)
        pcall(self.Logic.Aimbot.Update, self.Logic.Aimbot, deltaTime)
        if self.RuntimeState.PlayerMods.Fly.IsFlying then
            pcall(self.Logic.PlayerMods.UpdateFly, self.Logic.PlayerMods)
        end
        self.RuntimeState.RenderSteppedFPS = 1/deltaTime
        if tick() % 5 < deltaTime then
            self.Utils.CleanupDrawings()
        end
    end)

    self.RuntimeState.CharacterAddedConnection = self.Services.Players.LocalPlayer.CharacterAdded:Connect(function(character)
        self:Log("LocalPlayer Character Added.")
        task.wait(0.5)
        local hum = self.Utils.GetHumanoid()
        if hum then
            self.RuntimeState.PlayerMods.OriginalWalkSpeed = hum.WalkSpeed
            self.RuntimeState.PlayerMods.OriginalJumpPower = hum.JumpPower
            self.RuntimeState.PlayerMods.OriginalHipHeight = hum.HipHeight
            
            if self.Settings.PlayerMods.WalkSpeed.Enabled then self.Logic.PlayerMods.ApplyWalkSpeed(true, self.Settings.PlayerMods.WalkSpeed.Value) end
            if self.Settings.PlayerMods.Noclip.Enabled then self.Logic.PlayerMods.ToggleNoclip(); self.Logic.PlayerMods.ToggleNoclip() end
            if self.Settings.PlayerMods.Fly.Enabled then self.Logic.PlayerMods.ToggleFly(); self.Logic.PlayerMods.ToggleFly() end
        end
        FemboyHub.Camera = FemboyHub.Services.Workspace.CurrentCamera
    end)

    self.RuntimeState.InputBeganConnection = FemboyHub.Services.UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed and not FemboyHub.UI.Window.MainFrame.Visible then return end
        
        for settingPath, keybindState in pairs(FemboyHub.RuntimeState.Keybinds) do
            local keySetting = FemboyHub.Settings
            local pathParts = string.split(settingPath, ".")
            for i=1, #pathParts -1 do keySetting = keySetting[pathParts[i]] end
            local keybindInfo = keySetting[pathParts[#pathParts]]

            if input.KeyCode == keybindInfo.Key then
                if keybindInfo.Mode == "Hold" then
                    FemboyHub.RuntimeState.Keybinds[settingPath] = true
                    if settingPath == "Aimbot.AimKey" then FemboyHub.RuntimeState.Aimbot.IsAiming = true end
                    if settingPath == "Aimbot.Triggerbot.TriggerKey" then FemboyHub.RuntimeState.Keybinds["TriggerbotActive"] = true end
                    if settingPath == "PlayerMods.ClickTeleport.Key" and FemboyHub.Settings.PlayerMods.ClickTeleport.Enabled then FemboyHub.Logic.PlayerMods.ClickTeleport() end
                elseif keybindInfo.Mode == "Toggle" then
                end
            end
        end
    end)

    FemboyHub.RuntimeState.InputEndedConnection = FemboyHub.Services.UserInputService.InputEnded:Connect(function(input)
         for settingPath, keybindState in pairs(FemboyHub.RuntimeState.Keybinds) do
            local keySetting = FemboyHub.Settings 
            local pathParts = string.split(settingPath, ".")
            for i=1, #pathParts -1 do keySetting = keySetting[pathParts[i]] end
            local keybindInfo = keySetting[pathParts[#pathParts]]

            if input.KeyCode == keybindInfo.Key then
                if keybindInfo.Mode == "Hold" then
                    FemboyHub.RuntimeState.Keybinds[settingPath] = false
                     if settingPath == "Aimbot.AimKey" then FemboyHub.RuntimeState.Aimbot.IsAiming = false end
                     if settingPath == "Aimbot.Triggerbot.TriggerKey" then FemboyHub.RuntimeState.Keybinds["TriggerbotActive"] = false end
                end
            end
        end
    end)

    self.Utils.CreateNotification(self.Name, self.Version .. " Initialized!", 5)
    print("[" .. self.Name .. "] " .. self.Version .. " loaded successfully. UI Toggle: " .. FemboyHub.Settings.Global.MasterToggleKey.Name)
end

function FemboyHub:Destroy()
    self:Log("Destroying Femboy Hub...")
    if self.RuntimeState.MainLoopConnection then self.RuntimeState.MainLoopConnection:Disconnect() end
    if self.RuntimeState.CharacterAddedConnection then self.RuntimeState.CharacterAddedConnection:Disconnect() end
    if self.RuntimeState.InputBeganConnection then self.RuntimeState.InputBeganConnection:Disconnect() end
    if self.RuntimeState.InputEndedConnection then self.RuntimeState.InputEndedConnection:Disconnect() end
    
    if self.Settings.VisualTweaks.FullBright.Enabled then self.Logic.VisualTweaks.ApplyFullBright(false) end
    if self.Settings.PlayerMods.Noclip.Enabled then self.Logic.PlayerMods.ToggleNoclip() end
    if self.Settings.PlayerMods.Fly.Enabled then self.Logic.PlayerMods.ToggleFly() end
    self.Logic.PlayerMods.ApplyWalkSpeed(false, self.RuntimeState.PlayerMods.OriginalWalkSpeed)

    self.Utils.CleanupDrawings()
     for groupName, groupCache in pairs(FemboyHub.DrawingCache) do
        for idName, idCache in pairs(groupCache) do
            for i = #idCache, 1, -1 do
                local obj = table.remove(idCache, i)
                obj:Remove()
            end
        end
    end
    FemboyHub.DrawingCache = {}

    if self.UI.Window then self.UI.Window:Destroy() end
    if _G.FemboyHubInstance then _G.FemboyHubInstance = nil end
    
    local femboyHubErrorGui = game:GetService("CoreGui"):FindFirstChild("FemboyHubErrorGui")
    if femboyHubErrorGui then femboyHubErrorGui:Destroy() end

    print("[" .. self.Name .. "] Destroyed and cleaned up.")
end

_G.FemboyHubInstance = FemboyHub

local success, err = pcall(FemboyHub.Initialize, FemboyHub)
if not success then
    warn("[" .. FemboyHub.Name .. "] FATAL INITIALIZATION ERROR: " .. tostring(err))
    FemboyHub.Utils.CreateNotification(FemboyHub.Name .. " FATAL ERROR", "Initialization failed. Check console (F9) for details. Script may not work.", 10)
    if FemboyHub.UI.Window and FemboyHub.UI.Window.MainFrame then FemboyHub.UI.Window.MainFrame.Visible = false end
    pcall(FemboyHub.Destroy, FemboyHub)
end
