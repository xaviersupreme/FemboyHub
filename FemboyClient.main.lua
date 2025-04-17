
-- services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

-- ui configuration (Customizable)
local Config = {
    UI = {
        MainColor = Color3.fromRGB(45, 45, 45),
        AccentColor = Color3.fromRGB(0, 170, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamSemibold,
        CornerRadius = UDim.new(0, 8),
        Transparency = 0.1,
    },
    Animation = {
        TweenSpeed = 0.3,
        EasingStyle = Enum.EasingStyle.Quint,
        EasingDirection = Enum.EasingDirection.Out,
    },
    Aimbot = {
        Enabled = false,
        TeamCheck = true,
        TargetPart = "Head",
        Sensitivity = 0.5,
        FOV = 250,
        ShowFOV = true,
        FOVColor = Color3.fromRGB(255, 255, 255),
    },
    ESP = {
        Enabled = false,
        TeamCheck = true,
        BoxesEnabled = true,
        NamesEnabled = true,
        DistanceEnabled = true,
        TracersEnabled = false,
        BoxColor = Color3.fromRGB(255, 255, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
    }
}

-- create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ExecutorUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- create Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 350)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -175)
MainFrame.BackgroundColor3 = Config.UI.MainColor
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- add corner radius
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = Config.UI.CornerRadius
UICorner.Parent = MainFrame

-- create title bar
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Config.UI.AccentColor
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

-- add corner radius to title bar
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = Config.UI.CornerRadius
TitleCorner.Parent = TitleBar

-- fix title bar corners
local TitleFix = Instance.new("Frame")
TitleFix.Name = "TitleFix"
TitleFix.Size = UDim2.new(1, 0, 0.5, 0)
TitleFix.Position = UDim2.new(0, 0, 0.5, 0)
TitleFix.BackgroundColor3 = Config.UI.AccentColor
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

-- title text
local TitleText = Instance.new("TextLabel")
TitleText.Name = "TitleText"
TitleText.Size = UDim2.new(1, -40, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Sleek Executor"
TitleText.TextColor3 = Config.UI.TextColor
TitleText.TextSize = 18
TitleText.Font = Config.UI.Font
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- close button
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.Text = "X"
CloseButton.TextColor3 = Config.UI.TextColor
CloseButton.TextSize = 16
CloseButton.Font = Config.UI.Font
CloseButton.Parent = TitleBar

-- add corner radius to close button
local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseButton

-- tab container
local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Size = UDim2.new(0, 120, 1, -40)
TabContainer.Position = UDim2.new(0, 0, 0, 40)
TabContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainer.BorderSizePixel = 0
TabContainer.Parent = MainFrame

-- add corner radius to tab container
local TabContainerCorner = Instance.new("UICorner")
TabContainerCorner.CornerRadius = Config.UI.CornerRadius
TabContainerCorner.Parent = TabContainer

-- fix tab container corners
local TabContainerFix = Instance.new("Frame")
TabContainerFix.Name = "TabContainerFix"
TabContainerFix.Size = UDim2.new(0.5, 0, 1, 0)
TabContainerFix.Position = UDim2.new(0.5, 0, 0, 0)
TabContainerFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TabContainerFix.BorderSizePixel = 0
TabContainerFix.Parent = TabContainer

-- content frame
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -130, 1, -50)
ContentFrame.Position = UDim2.new(0, 125, 0, 45)
ContentFrame.BackgroundTransparency = 1
ContentFrame.Parent = MainFrame

-- create tab buttons
local function CreateTab(name, icon)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Size = UDim2.new(1, -10, 0, 35)
    TabButton.Position = UDim2.new(0, 5, 0, (#TabContainer:GetChildren() - 2) * 40 + 10)
    TabButton.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    TabButton.Text = name
    TabButton.TextColor3 = Config.UI.TextColor
    TabButton.TextSize = 14
    TabButton.Font = Config.UI.Font
    TabButton.Parent = TabContainer
    
    -- add corner radius to tab button
    local TabButtonCorner = Instance.new("UICorner")
    TabButtonCorner.CornerRadius = UDim.new(0, 6)
    TabButtonCorner.Parent = TabButton
    
    -- create content frame for this tab
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.BackgroundTransparency = 1
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarThickness = 4
    TabContent.Visible = false
    TabContent.ScrollingDirection = Enum.ScrollingDirection.Y
    TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.Parent = ContentFrame
    
    -- add padding to content
    local UIPadding = Instance.new("UIPadding")
    UIPadding.PaddingLeft = UDim.new(0, 10)
    UIPadding.PaddingRight = UDim.new(0, 10)
    UIPadding.PaddingTop = UDim.new(0, 10)
    UIPadding.PaddingBottom = UDim.new(0, 10)
    UIPadding.Parent = TabContent
    
    -- add list layout to content
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Padding = UDim.new(0, 10)
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Parent = TabContent
    
    TabButton.MouseButton1Click:Connect(function()
        -- hide all tab contents
        for _, child in pairs(ContentFrame:GetChildren()) do
            if child:IsA("ScrollingFrame") then
                child.Visible = false
            end
        end
        
        -- reset all tab button colors
        for _, child in pairs(TabContainer:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(
                    Config.Animation.TweenSpeed, 
                    Config.Animation.EasingStyle, 
                    Config.Animation.EasingDirection
                ), {
                    BackgroundColor3 = Color3.fromRGB(55, 55, 55)
                }):Play()
            end
        end
        
        -- show this tab content and highlight button
        TabContent.Visible = true
        TweenService:Create(TabButton, TweenInfo.new(
            Config.Animation.TweenSpeed, 
            Config.Animation.EasingStyle, 
            Config.Animation.EasingDirection
        ), {
            BackgroundColor3 = Config.UI.AccentColor
        }):Play()
    end)
    
    return TabContent
end

-- create UI elements
local function CreateLabel(parent, text)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Config.UI.TextColor
    Label.TextSize = 14
    Label.Font = Config.UI.Font
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = parent
    return Label
end

local function CreateButton(parent, text, callback)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 35)
    Button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Button.Text = text
    Button.TextColor3 = Config.UI.TextColor
    Button.TextSize = 14
    Button.Font = Config.UI.Font
    Button.Parent = parent
    
    -- add corner radius to button
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = Button
    
    -- button animation
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(
            Config.Animation.TweenSpeed, 
            Config.Animation.EasingStyle, 
            Config.Animation.EasingDirection
        ), {
            BackgroundColor3 = Config.UI.AccentColor
        }):Play()
    end)
    
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(
            Config.Animation.TweenSpeed, 
            Config.Animation.EasingStyle, 
            Config.Animation.EasingDirection
        ), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        }):Play()
    end)
    
    Button.MouseButton1Click:Connect(function()
        callback()
    end)
    
    return Button
end

local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.Parent = parent
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = text
    ToggleLabel.TextColor3 = Config.UI.TextColor
    ToggleLabel.TextSize = 14
    ToggleLabel.Font = Config.UI.Font
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("Frame")
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -50, 0, 5)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    ToggleButton.Parent = ToggleFrame
    
    -- add corner radius to toggle button
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
    ToggleButtonCorner.Parent = ToggleButton
    
    local ToggleCircle = Instance.new("Frame")
    ToggleCircle.Size = UDim2.new(0, 21, 0, 21)
    ToggleCircle.Position = UDim2.new(0, 2, 0, 2)
    ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleCircle.Parent = ToggleButton
    
    -- add corner radius to toggle circle
    local ToggleCircleCorner = Instance.new("UICorner")
    ToggleCircleCorner.CornerRadius = UDim.new(1, 0)
    
    -- set default state
    local Enabled = default or false
    
    -- update toggle appearance based on state
    local function UpdateToggle()
        if Enabled then
            TweenService:Create(ToggleButton, TweenInfo.new(
                Config.Animation.TweenSpeed, 
                Config.Animation.EasingStyle, 
                Config.Animation.EasingDirection
            ), {
                BackgroundColor3 = Config.UI.AccentColor
            }):Play()
            
            TweenService:Create(ToggleCircle, TweenInfo.new(
                Config.Animation.TweenSpeed, 
                Config.Animation.EasingStyle, 
                Config.Animation.EasingDirection
            ), {
                Position = UDim2.new(0, 27, 0, 2)
            }):Play()
        else
            TweenService:Create(ToggleButton, TweenInfo.new(
                Config.Animation.TweenSpeed, 
                Config.Animation.EasingStyle, 
                Config.Animation.EasingDirection
            ), {
                BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            }):Play()
            
            TweenService:Create(ToggleCircle, TweenInfo.new(
                Config.Animation.TweenSpeed, 
                Config.Animation.EasingStyle, 
                Config.Animation.EasingDirection
            ), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
        end
    end
    
    -- initialize toggle
    UpdateToggle()
    
    -- make toggle clickable
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Enabled = not Enabled
            UpdateToggle()
            callback(Enabled)
        end
    end)
    
    -- make label clickable too
    ToggleLabel.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Enabled = not Enabled
            UpdateToggle()
            callback(Enabled)
        end
    end)
    
    return {
        SetValue = function(value)
            Enabled = value
            UpdateToggle()
            callback(Enabled)
        end,
        GetValue = function()
            return Enabled
        end
    }
end

local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 50)
    SliderFrame.BackgroundTransparency = 1
    SliderFrame.Parent = parent
    
    local SliderLabel = Instance.new("TextLabel")
    SliderLabel.Size = UDim2.new(1, 0, 0, 20)
    SliderLabel.Position = UDim2.new(0, 0, 0, 0)
    SliderLabel.BackgroundTransparency = 1
    SliderLabel.Text = text
    SliderLabel.TextColor3 = Config.UI.TextColor
    SliderLabel.TextSize = 14
    SliderLabel.Font = Config.UI.Font
    SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    SliderLabel.Parent = SliderFrame
    
    local SliderValueLabel = Instance.new("TextLabel")
    SliderValueLabel.Size = UDim2.new(0, 50, 0, 20)
    SliderValueLabel.Position = UDim2.new(1, -50, 0, 0)
    SliderValueLabel.BackgroundTransparency = 1
    SliderValueLabel.Text = tostring(default)
    SliderValueLabel.TextColor3 = Config.UI.TextColor
    SliderValueLabel.TextSize = 14
    SliderValueLabel.Font = Config.UI.Font
    SliderValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    SliderValueLabel.Parent = SliderFrame
    
    local SliderBackground = Instance.new("Frame")
    SliderBackground.Size = UDim2.new(1, 0, 0, 10)
    SliderBackground.Position = UDim2.new(0, 0, 0, 30)
    SliderBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    SliderBackground.Parent = SliderFrame
    
    -- add corner radius to slider background
    local SliderBackgroundCorner = Instance.new("UICorner")
    SliderBackgroundCorner.CornerRadius = UDim.new(0, 5)
    SliderBackgroundCorner.Parent = SliderBackground
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Config.UI.AccentColor
    SliderFill.Parent = SliderBackground
    
    -- add corner radius to slider fill
    local SliderFillCorner = Instance.new("UICorner")
    SliderFillCorner.CornerRadius = UDim.new(0, 5)
    SliderFillCorner.Parent = SliderFill
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Size = UDim2.new(0, 20, 0, 20)
    SliderButton.Position = UDim2.new((default - min) / (max - min), -10, 0, 25)
    SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    SliderButton.Text = ""
    SliderButton.Parent = SliderFrame
    
    -- add corner radius to slider button
    local SliderButtonCorner = Instance.new("UICorner")
    SliderButtonCorner.CornerRadius = UDim.new(1, 0)
    SliderButtonCorner.Parent = SliderButton
    
    -- variables
    local Value = default
    local Dragging = false
    
    -- update slider appearance
    local function UpdateSlider()
        local Percent = (Value - min) / (max - min)
        SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
        SliderButton.Position = UDim2.new(Percent, -10, 0, 25)
        SliderValueLabel.Text = tostring(math.floor(Value * 100) / 100)
    end
    
    -- handle slider interaction
    SliderButton.MouseButton1Down:Connect(function()
        Dragging = true
    end)
    
    SliderBackground.MouseButton1Down:Connect(function(x)
        Dragging = true
        local RelativeX = x - SliderBackground.AbsolutePosition.X
        local Percent = math.clamp(RelativeX / SliderBackground.AbsoluteSize.X, 0, 1)
        Value = min + (max - min) * Percent
        UpdateSlider()
        callback(Value)
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
            local MousePosition = UserInputService:GetMouseLocation()
            local RelativeX = MousePosition.X - SliderBackground.AbsolutePosition.X
            local Percent = math.clamp(RelativeX / SliderBackground.AbsoluteSize.X, 0, 1)
            Value = min + (max - min) * Percent
            UpdateSlider()
            callback(Value)
        end
    end)
    
    -- initialize slider
    UpdateSlider()
    
    return {
        SetValue = function(value)
            Value = math.clamp(value, min, max)
            UpdateSlider()
            callback(Value)
        end,
        GetValue = function()
            return Value
        end
    }
end

local function CreateDropdown(parent, text, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Size = UDim2.new(1, 0, 0, 60)
    DropdownFrame.BackgroundTransparency = 1
    DropdownFrame.Parent = parent
    
    local DropdownLabel = Instance.new("TextLabel")
    DropdownLabel.Size = UDim2.new(1, 0, 0, 20)
    DropdownLabel.Position = UDim2.new(0, 0, 0, 0)
    DropdownLabel.BackgroundTransparency = 1
    DropdownLabel.Text = text
    DropdownLabel.TextColor3 = Config.UI.TextColor
    DropdownLabel.TextSize = 14
    DropdownLabel.Font = Config.UI.Font
    DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    DropdownLabel.Parent = DropdownFrame
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Size = UDim2.new(1, 0, 0, 35)
    DropdownButton.Position = UDim2.new(0, 0, 0, 25)
    DropdownButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    DropdownButton.Text = default or options[1] or "Select..."
    DropdownButton.TextColor3 = Config.UI.TextColor
    DropdownButton.TextSize = 14
    DropdownButton.Font = Config.UI.Font
    DropdownButton.Parent = DropdownFrame
    
    -- add corner radius to dropdown button
    local DropdownButtonCorner = Instance.new("UICorner")
    DropdownButtonCorner.CornerRadius = UDim.new(0, 6)
    DropdownButtonCorner.Parent = DropdownButton
    
    -- create dropdown menu
    local DropdownMenu = Instance.new("Frame")
    DropdownMenu.Size = UDim2.new(1, 0, 0, #options * 30)
    DropdownMenu.Position = UDim2.new(0, 0, 1, 5)
    DropdownMenu.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    DropdownMenu.Visible = false
    DropdownMenu.ZIndex = 10
    DropdownMenu.Parent = DropdownButton
    
    -- add corner radius to dropdown menu
    local DropdownMenuCorner = Instance.new("UICorner")
    DropdownMenuCorner.CornerRadius = UDim.new(0, 6)
    DropdownMenuCorner.Parent = DropdownMenu
    
    -- create dropdown options
    for i, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
        OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        OptionButton.BackgroundTransparency = 0.5
        OptionButton.Text = option
        OptionButton.TextColor3 = Config.UI.TextColor
        OptionButton.TextSize = 14
        OptionButton.Font = Config.UI.Font
        OptionButton.ZIndex = 11
        OptionButton.Parent = DropdownMenu
        
        -- option button hover effect
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(
                Config.Animation.TweenSpeed, 
                Config.Animation.EasingStyle, 
                Config.Animation.EasingDirection
            ), {
                BackgroundColor3 = Config.UI.AccentColor
            }):Play()
        end)
        
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(
                Config.Animation.TweenSpeed, 
                Config.Animation.EasingStyle, 
                Config.Animation.EasingDirection
            ), {
                BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            }):Play()
        end)
        
        -- option selection
        OptionButton.MouseButton1Click:Connect(function()
            DropdownButton.Text = option
            DropdownMenu.Visible = false
            callback(option)
        end)
    end
    
    -- toggle dropdown menu
    DropdownButton.MouseButton1Click:Connect(function()
        DropdownMenu.Visible = not DropdownMenu.Visible
    end)
    
    -- close dropdown when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local MousePosition = UserInputService:GetMouseLocation()
            if DropdownMenu.Visible then
                local AbsPos = DropdownMenu.AbsolutePosition
                local AbsSize = DropdownMenu.AbsoluteSize
                if MousePosition.X < AbsPos.X or MousePosition.X > AbsPos.X + AbsSize.X or
                   MousePosition.Y < AbsPos.Y or MousePosition.Y > AbsPos.Y + AbsSize.Y then
                    if not (MousePosition.X >= DropdownButton.AbsolutePosition.X and
                           MousePosition.X <= DropdownButton.AbsolutePosition.X + DropdownButton.AbsoluteSize.X and
                           MousePosition.Y >= DropdownButton.AbsolutePosition.Y and
                           MousePosition.Y <= DropdownButton.AbsolutePosition.Y + DropdownButton.AbsoluteSize.Y) then
                        DropdownMenu.Visible = false
                    end
                end
            end
        end
    end)
    
    return {
        SetValue = function(value)
            if table.find(options, value) then
                DropdownButton.Text = value
                callback(value)
            end
        end,
        GetValue = function()
            return DropdownButton.Text
        end,
        Refresh = function(newOptions, keepSelection)
            -- clear existing options
            for _, child in pairs(DropdownMenu:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- update size
            DropdownMenu.Size = UDim2.new(1, 0, 0, #newOptions * 30)
            
            -- add new options
            for i, option in ipairs(newOptions) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.Position = UDim2.new(0, 0, 0, (i-1) * 30)
                OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                OptionButton.BackgroundTransparency = 0.5
                OptionButton.Text = option
                OptionButton.TextColor3 = Config.UI.TextColor
                OptionButton.TextSize = 14
                OptionButton.Font = Config.UI.Font
                OptionButton.ZIndex = 11
                OptionButton.Parent = DropdownMenu
                
                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(
                        Config.Animation.TweenSpeed, 
                        Config.Animation.EasingStyle, 
                        Config.Animation.EasingDirection
                    ), {
                        BackgroundColor3 = Config.UI.AccentColor
                    }):Play()
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(
                        Config.Animation.TweenSpeed, 
                        Config.Animation.EasingStyle, 
                        Config.Animation.EasingDirection
                    ), {
                        BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    }):Play()
                end)
                
                OptionButton.MouseButton1Click:Connect(function()
                    DropdownButton.Text = option
                    DropdownMenu.Visible = false
                    callback(option)
                end)
            end
            
            -- update current selection
            if not keepSelection or not table.find(newOptions, DropdownButton.Text) then
                DropdownButton.Text = newOptions[1] or "Select..."
            end
        end
    }
end

local function CreateTextBox(parent, text, placeholder, callback)
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Size = UDim2.new(1, 0, 0, 60)
    TextBoxFrame.BackgroundTransparency = 1
    TextBoxFrame.Parent = parent
    
    local TextBoxLabel = Instance.new("TextLabel")
    TextBoxLabel.Size = UDim2.new(1, 0, 0, 20)
    TextBoxLabel.Position = UDim2.new(0, 0, 0, 0)
    TextBoxLabel.BackgroundTransparency = 1
    TextBoxLabel.Text = text
    TextBoxLabel.TextColor3 = Config.UI.TextColor
    TextBoxLabel.TextSize = 14
    TextBoxLabel.Font = Config.UI.Font
    TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextBoxLabel.Parent = TextBoxFrame
    
    local TextBoxBackground = Instance.new("Frame")
    TextBoxBackground.Size = UDim2.new(1, 0, 0, 35)
    TextBoxBackground.Position = UDim2.new(0, 0, 0, 25)
    TextBoxBackground.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    TextBoxBackground.Parent = TextBoxFrame
    
    -- add corner radius to textbox background
    local TextBoxBackgroundCorner = Instance.new("UICorner")
    TextBoxBackgroundCorner.CornerRadius = UDim.new(0, 6)
    TextBoxBackgroundCorner.Parent = TextBoxBackground
    
    local TextBox = Instance.new("TextBox")
    TextBox.Size = UDim2.new(1, -10, 1, -10)
    TextBox.Position = UDim2.new(0, 5, 0, 5)
    TextBox.BackgroundTransparency = 1
    TextBox.Text = ""
    TextBox.PlaceholderText = placeholder or "Type here..."
    TextBox.TextColor3 = Config.UI.TextColor
    TextBox.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
    TextBox.TextSize = 14
    TextBox.Font = Config.UI.Font
    TextBox.TextXAlignment = Enum.TextXAlignment.Left
    TextBox.ClearTextOnFocus = false
    TextBox.Parent = TextBoxBackground
    
    TextBox.FocusLost:Connect(function(enterPressed)
        callback(TextBox.Text, enterPressed)
    end)
    
    return {
        SetValue = function(value)
            TextBox.Text = value
        end,
        GetValue = function()
            return TextBox.Text
        end
    }
end

local function CreateColorPicker(parent, text, default, callback)
    local ColorPickerFrame = Instance.new("Frame")
    ColorPickerFrame.Size = UDim2.new(1, 0, 0, 60)
    ColorPickerFrame.BackgroundTransparency = 1
    ColorPickerFrame.Parent = parent
    
    local ColorPickerLabel = Instance.new("TextLabel")
    ColorPickerLabel.Size = UDim2.new(1, -60, 0, 20)
    ColorPickerLabel.Position = UDim2.new(0, 0, 0, 0)
    ColorPickerLabel.BackgroundTransparency = 1
    ColorPickerLabel.Text = text
    ColorPickerLabel.TextColor3 = Config.UI.TextColor
    ColorPickerLabel.TextSize = 14
    ColorPickerLabel.Font = Config.UI.Font
    ColorPickerLabel.TextXAlignment = Enum.TextXAlignment.Left
    ColorPickerLabel.Parent = ColorPickerFrame
    
    local ColorDisplay = Instance.new("Frame")
    ColorDisplay.Size = UDim2.new(0, 50, 0, 25)
    ColorDisplay.Position = UDim2.new(1, -50, 0, 0)
    ColorDisplay.BackgroundColor3 = default or Color3.fromRGB(255, 255, 255)
    ColorDisplay.Parent = ColorPickerFrame
    
    -- add corner radius to color display
    local ColorDisplayCorner = Instance.new("UICorner")
    ColorDisplayCorner.CornerRadius = UDim.new(0, 4)
    ColorDisplayCorner.Parent = ColorDisplay
    
    -- create color picker popup
    local ColorPickerPopup = Instance.new("Frame")
    ColorPickerPopup.Size = UDim2.new(0, 200, 0, 220)
    ColorPickerPopup.Position = UDim2.new(1, -200, 1, 10)
    ColorPickerPopup.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    ColorPickerPopup.Visible = false
    ColorPickerPopup.ZIndex = 100
    ColorPickerPopup.Parent = ColorPickerFrame
    
    -- add corner radius to color picker popup
    local ColorPickerPopupCorner = Instance.new("UICorner")
    ColorPickerPopupCorner.CornerRadius = UDim.new(0, 6)
    ColorPickerPopupCorner.Parent = ColorPickerPopup
    
    -- create color picker components (simplified version)
    local ColorArea = Instance.new("ImageButton")
    ColorArea.Size = UDim2.new(1, -20, 0, 150)
    ColorArea.Position = UDim2.new(0, 10, 0, 10)
    ColorArea.Image = "rbxassetid://4155801252" -- color picker image
    ColorArea.ZIndex = 101
    ColorArea.Parent = ColorPickerPopup
    
    -- add corner radius to color area
    local ColorAreaCorner = Instance.new("UICorner")
    ColorAreaCorner.CornerRadius = UDim.new(0, 4)
    ColorAreaCorner.Parent = ColorArea
    
    -- RGB inputs
    local RInput = Instance.new("TextBox")
    RInput.Size = UDim2.new(0, 40, 0, 25)
    RInput.Position = UDim2.new(0, 10, 0, 170)
    RInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    RInput.Text = tostring(math.floor(default.R * 255))
    RInput.TextColor3 = Config.UI.TextColor
    RInput.PlaceholderText = "R"
    RInput.TextSize = 14
    RInput.Font = Config.UI.Font
    RInput.ZIndex = 101
    RInput.Parent = ColorPickerPopup
    
    local GInput = Instance.new("TextBox")
    GInput.Size = UDim2.new(0, 40, 0, 25)
    GInput.Position = UDim2.new(0, 60, 0, 170)
    GInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    GInput.Text = tostring(math.floor(default.G * 255))
    GInput.TextColor3 = Config.UI.TextColor
    GInput.PlaceholderText = "G"
    GInput.TextSize = 14
    GInput.Font = Config.UI.Font
    GInput.ZIndex = 101
    GInput.Parent = ColorPickerPopup
    
    local BInput = Instance.new("TextBox")
    BInput.Size = UDim2.new(0, 40, 0, 25)
    BInput.Position = UDim2.new(0, 110, 0, 170)
    BInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    BInput.Text = tostring(math.floor(default.B * 255))
    BInput.TextColor3 = Config.UI.TextColor
    BInput.PlaceholderText = "B"
    BInput.TextSize = 14
    BInput.Font = Config.UI.Font
    BInput.ZIndex = 101
    BInput.Parent = ColorPickerPopup
    
    -- add corner radius to RGB inputs
    local RInputCorner = Instance.new("UICorner")
    RInputCorner.CornerRadius = UDim.new(0, 4)
    RInputCorner.Parent = RInput
    
    local GInputCorner = Instance.new("UICorner")
    GInputCorner.CornerRadius = UDim.new(0, 4)
    GInputCorner.Parent = GInput
    
    local BInputCorner = Instance.new("UICorner")
    BInputCorner.CornerRadius = UDim.new(0, 4)
    BInputCorner.Parent = BInput
    
    -- apply button
    local ApplyButton = Instance.new("TextButton")
    ApplyButton.Size = UDim2.new(0, 80, 0, 25)
    ApplyButton.Position = UDim2.new(1, -90, 0, 170)
    ApplyButton.BackgroundColor3 = Config.UI.AccentColor
    ApplyButton.Text = "Apply"
    ApplyButton.TextColor3 = Config.UI.TextColor
    ApplyButton.TextSize = 14
    ApplyButton.Font = Config.UI.Font
    ApplyButton.ZIndex = 101
    ApplyButton.Parent = ColorPickerPopup
    
    -- add corner radius to apply button
    local ApplyButtonCorner = Instance.new("UICorner")
    ApplyButtonCorner.CornerRadius = UDim.new(0, 4)
    ApplyButtonCorner.Parent = ApplyButton
    
    -- current selected color
    local SelectedColor = default
    
    -- update color from RGB inputs
    local function UpdateColorFromInputs()
        local r = tonumber(RInput.Text) or 0
        local g = tonumber(GInput.Text) or 0
        local b = tonumber(BInput.Text) or 0
        
        r = math.clamp(r, 0, 255) / 255
        g = math.clamp(g, 0, 255) / 255
        b = math.clamp(b, 0, 255) / 255
        
        SelectedColor = Color3.new(r, g, b)
        ColorDisplay.BackgroundColor3 = SelectedColor
    end
    
    -- update RGB inputs from color
    local function UpdateInputsFromColor()
        RInput.Text = tostring(math.floor(SelectedColor.R * 255))
        GInput.Text = tostring(math.floor(SelectedColor.G * 255))
        BInput.Text = tostring(math.floor(SelectedColor.B * 255))
    end
    
    -- handle color area click
    ColorArea.MouseButton1Down:Connect(function()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local MousePosition = UserInputService:GetMouseLocation()
                local RelativeX = math.clamp((MousePosition.X - ColorArea.AbsolutePosition.X) / ColorArea.AbsoluteSize.X, 0, 1)
                local RelativeY = math.clamp((MousePosition.Y - ColorArea.AbsolutePosition.Y) / ColorArea.AbsoluteSize.Y, 0, 1)
                
                -- simple HSV to RGB conversion (simplified)
                local h = RelativeX
                local s = 1 - RelativeY
                local v = 1
                
                -- convert HSV to RGB (simplified)
                local r, g, b
                local i = math.floor(h * 6)
                local f = h * 6 - i
                local p = v * (1 - s)
                local q = v * (1 - f * s)
                local t = v * (1 - (1 - f) * s)
                
                i = i % 6
                
                if i == 0 then
                    r, g, b = v, t, p
                elseif i == 1 then
                    r, g, b = q, v, p
                elseif i == 2 then
                    r, g, b = p, v, t
                elseif i == 3 then
                    r, g, b = p, q, v
                elseif i == 4 then
                    r, g, b = t, p, v
                elseif i == 5 then
                    r, g, b = v, p, q
                end
                
                SelectedColor = Color3.new(r, g, b)
                ColorDisplay.BackgroundColor3 = SelectedColor
                UpdateInputsFromColor()
            else
                Connection:Disconnect()
            end
        end)
    end)
    
    -- handle RGB input changes
    RInput.FocusLost:Connect(function() UpdateColorFromInputs() end)
    GInput.FocusLost:Connect(function() UpdateColorFromInputs() end)
    BInput.FocusLost:Connect(function() UpdateColorFromInputs() end)
    
    -- apply button
    ApplyButton.MouseButton1Click:Connect(function()
        ColorPickerPopup.Visible = false
        callback(SelectedColor)
    end)
    
    -- toggle color picker popup
    ColorDisplay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            ColorPickerPopup.Visible = not ColorPickerPopup.Visible
        end
    end)
    
    -- close color picker when clicking elsewhere
    UserInputService.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and ColorPickerPopup.Visible then
            local MousePosition = UserInputService:GetMouseLocation()
            local AbsPos = ColorPickerPopup.AbsolutePosition
            local AbsSize = ColorPickerPopup.AbsoluteSize
            
            if MousePosition.X < AbsPos.X or MousePosition.X > AbsPos.X + AbsSize.X or
               MousePosition.Y < AbsPos.Y or MousePosition.Y > AbsPos.Y + AbsSize.Y then
                if not (MousePosition.X >= ColorDisplay.AbsolutePosition.X and
                       MousePosition.X <= ColorDisplay.AbsolutePosition.X + ColorDisplay.AbsoluteSize.X and
                       MousePosition.Y >= ColorDisplay.AbsolutePosition.Y and
                       MousePosition.Y <= ColorDisplay.AbsolutePosition.Y + ColorDisplay.AbsoluteSize.Y) then
                    ColorPickerPopup.Visible = false
                end
            end
        end
    end)
    
    return {
        SetValue = function(color)
            SelectedColor = color
            ColorDisplay.BackgroundColor3 = color
            UpdateInputsFromColor()
            callback(color)
        end,
        GetValue = function()
            return SelectedColor
        end
    }
end

-- create script editor
local function CreateScriptEditor(parent)
    local EditorFrame = Instance.new("Frame")
    EditorFrame.Size = UDim2.new(1, 0, 1, -50)
    EditorFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    EditorFrame.Parent = parent
    
    -- add corner radius to editor frame
    local EditorFrameCorner = Instance.new("UICorner")
    EditorFrameCorner.CornerRadius = UDim.new(0, 6)
    EditorFrameCorner.Parent = EditorFrame
    
    local EditorScrollFrame = Instance.new("ScrollingFrame")
    EditorScrollFrame.Size = UDim2.new(1, -10, 1, -10)
    EditorScrollFrame.Position = UDim2.new(0, 5, 0, 5)
    EditorScrollFrame.BackgroundTransparency = 1
    EditorScrollFrame.ScrollBarThickness = 4
    EditorScrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    EditorScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    EditorScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    EditorScrollFrame.Parent = EditorFrame
    
    local EditorTextBox = Instance.new("TextBox")
    EditorTextBox.Size = UDim2.new(1, -10, 1, 0)
    EditorTextBox.Position = UDim2.new(0, 5, 0, 0)
    EditorTextBox.BackgroundTransparency = 1
    EditorTextBox.Text = ""
    EditorTextBox.PlaceholderText = "-- Enter your script here"
    EditorTextBox.TextColor3 = Config.UI.TextColor
    EditorTextBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    EditorTextBox.TextSize = 14
    EditorTextBox.Font = Enum.Font.Code
    EditorTextBox.TextXAlignment = Enum.TextXAlignment.Left
    EditorTextBox.TextYAlignment = Enum.TextYAlignment.Top
    EditorTextBox.ClearTextOnFocus = false
    EditorTextBox.MultiLine = true
    EditorTextBox.Parent = EditorScrollFrame
    
    -- button container
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Size = UDim2.new(1, 0, 0, 40)
    ButtonContainer.Position = UDim2.new(0, 0, 1, -40)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = parent
    
    -- execute button
    local ExecuteButton = Instance.new("TextButton")
    ExecuteButton.Size = UDim2.new(0.3, -10, 1, -10)
    ExecuteButton.Position = UDim2.new(0, 5, 0, 5)
    ExecuteButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    ExecuteButton.Text = "Execute"
    ExecuteButton.TextColor3 = Config.UI.TextColor
    ExecuteButton.TextSize = 14
    ExecuteButton.Font = Config.UI.Font
    ExecuteButton.Parent = ButtonContainer
    
    -- add corner radius to execute button
    local ExecuteButtonCorner = Instance.new("UICorner")
    ExecuteButtonCorner.CornerRadius = UDim.new(0, 6)
    ExecuteButtonCorner.Parent = ExecuteButton
    
    -- clear button
    local ClearButton = Instance.new("TextButton")
    ClearButton.Size = UDim2.new(0.3, -10, 1, -10)
    ClearButton.Position = UDim2.new(0.35, 0, 0, 5)
    ClearButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    ClearButton.Text = "Clear"
    ClearButton.TextColor3 = Config.UI.TextColor
    ClearButton.TextSize = 14
    ClearButton.Font = Config.UI.Font
    ClearButton.Parent = ButtonContainer
    
    -- add corner radius to clear button
    local ClearButtonCorner = Instance.new("UICorner")
    ClearButtonCorner.CornerRadius = UDim.new(0, 6)
    ClearButtonCorner.Parent = ClearButton
    
    -- save Button
    local SaveButton = Instance.new("TextButton")
    SaveButton.Size = UDim2.new(0.3, -10, 1, -10)
    SaveButton.Position = UDim2.new(0.7, 0, 0, 5)
    SaveButton.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
    SaveButton.Text = "Save"
    SaveButton.TextColor3 = Config.UI.TextColor
    SaveButton.TextSize = 14
    SaveButton.Font = Config.UI.Font
    SaveButton.Parent = ButtonContainer
    
    -- add corner radius to save button
    local SaveButtonCorner = Instance.new("UICorner")
    SaveButtonCorner.CornerRadius = UDim.new(0, 6)
    SaveButtonCorner.Parent = SaveButton
    
    -- button functionality
    ExecuteButton.MouseButton1Click:Connect(function()
        local success, err = pcall(function()
            loadstring(EditorTextBox.Text)()
        end)
        
        if not success then
            warn("Script execution error: " .. err)
        end
    end)
    
    ClearButton.MouseButton1Click:Connect(function()
        EditorTextBox.Text = ""
    end)
    
    -- saved scripts system
    local SavedScripts = {}
    
    SaveButton.MouseButton1Click:Connect(function()
        -- create a simple save dialog
        local SaveDialog = Instance.new("Frame")
        SaveDialog.Size = UDim2.new(0, 250, 0, 100)
        SaveDialog.Position = UDim2.new(0.5, -125, 0.5, -50)
        SaveDialog.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        SaveDialog.ZIndex = 100
        SaveDialog.Parent = ScreenGui
        
        -- add corner radius to Save Dialog
        local SaveDialogCorner = Instance.new("UICorner")
        SaveDialogCorner.CornerRadius = UDim.new(0, 6)
        SaveDialogCorner.Parent = SaveDialog
        
        local SaveDialogTitle = Instance.new("TextLabel")
        SaveDialogTitle.Size = UDim2.new(1, 0, 0, 30)
        SaveDialogTitle.BackgroundTransparency = 1
        SaveDialogTitle.Text = "Save Script"
        SaveDialogTitle.TextColor3 = Config.UI.TextColor
        SaveDialogTitle.TextSize = 16
        SaveDialogTitle.Font = Config.UI.Font
        SaveDialogTitle.ZIndex = 101
        SaveDialogTitle.Parent = SaveDialog
        
        local SaveNameInput = Instance.new("TextBox")
        SaveNameInput.Size = UDim2.new(1, -20, 0, 30)
        SaveNameInput.Position = UDim2.new(0, 10, 0, 35)
        SaveNameInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        SaveNameInput.Text = ""
        SaveNameInput.PlaceholderText = "Script name..."
        SaveNameInput.TextColor3 = Config.UI.TextColor
        SaveNameInput.PlaceholderColor3 = Color3.fromRGB(180, 180, 180)
        SaveNameInput.TextSize = 14
        SaveNameInput.Font = Config.UI.Font
        SaveNameInput.ZIndex = 101
        SaveNameInput.Parent = SaveDialog
        
        -- add corner radius to save name input
        local SaveNameInputCorner = Instance.new("UICorner")
        SaveNameInputCorner.CornerRadius = UDim.new(0, 4)
        SaveNameInputCorner.Parent = SaveNameInput
        
        local SaveConfirmButton = Instance.new("TextButton")
        SaveConfirmButton.Size = UDim2.new(0.5, -15, 0, 25)
        SaveConfirmButton.Position = UDim2.new(0, 10, 1, -30)
        SaveConfirmButton.BackgroundColor3 = Config.UI.AccentColor
        SaveConfirmButton.Text = "Save"
        SaveConfirmButton.TextColor3 = Config.UI.TextColor
        SaveConfirmButton.TextSize = 14
        SaveConfirmButton.Font = Config.UI.Font
        SaveConfirmButton.ZIndex = 101
        SaveConfirmButton.Parent = SaveDialog
        
        -- add corner radius to save confirm button
        local SaveConfirmButtonCorner = Instance.new("UICorner")
        SaveConfirmButtonCorner.CornerRadius = UDim.new(0, 4)
        SaveConfirmButtonCorner.Parent = SaveConfirmButton
        
        local CancelButton = Instance.new("TextButton")
        CancelButton.Size = UDim2.new(0.5, -15, 0, 25)
        CancelButton.Position = UDim2.new(0.5, 5, 1, -30)
        CancelButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        CancelButton.Text = "Cancel"
        CancelButton.TextColor3 = Config.UI.TextColor
        CancelButton.TextSize = 14
        CancelButton.Font = Config.UI.Font
        CancelButton.ZIndex = 101
        CancelButton.Parent = SaveDialog
        
        -- add corner radius to cancel button
        local CancelButtonCorner = Instance.new("UICorner")
        CancelButtonCorner.CornerRadius = UDim.new(0, 4)
        CancelButtonCorner.Parent = CancelButton
        
        SaveConfirmButton.MouseButton1Click:Connect(function()
            local scriptName = SaveNameInput.Text
            if scriptName ~= "" then
                SavedScripts[scriptName] = EditorTextBox.Text
                SaveDialog:Destroy()
                
                -- update saved scripts list if it exists
                if parent:FindFirstChild("SavedScriptsContent") then
                    RefreshSavedScripts(parent.SavedScriptsContent)
                end
            end
        end)
        
        CancelButton.MouseButton1Click:Connect(function()
            SaveDialog:Destroy()
        end)
    end)
    
    -- function to refresh saved scripts list
    function RefreshSavedScripts(container)
        -- clear existing items
        for _, child in pairs(container:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        
        -- add saved scripts
        local index = 0
        for name, script in pairs(SavedScripts) do
            local ScriptItem = Instance.new("Frame")
            ScriptItem.Size = UDim2.new(1, 0, 0, 30)
            ScriptItem.Position = UDim2.new(0, 0, 0, index * 35)
            ScriptItem.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            ScriptItem.Parent = container
            
            -- add corner radius to script item
            local ScriptItemCorner = Instance.new("UICorner")
            ScriptItemCorner.CornerRadius = UDim.new(0, 4)
            ScriptItemCorner.Parent = ScriptItem
            
            local ScriptName = Instance.new("TextLabel")
            ScriptName.Size = UDim2.new(1, -100, 1, 0)
            ScriptName.BackgroundTransparency = 1
            ScriptName.Text = name
            ScriptName.TextColor3 = Config.UI.TextColor
            ScriptName.TextSize = 14
            ScriptName.Font = Config.UI.Font
            ScriptName.TextXAlignment = Enum.TextXAlignment.Left
            ScriptName.Parent = ScriptItem
            
            local LoadButton = Instance.new("TextButton")
            LoadButton.Size = UDim2.new(0, 40, 0, 20)
            LoadButton.Position = UDim2.new(1, -90, 0, 5)
            LoadButton.BackgroundColor3 = Config.UI.AccentColor
            LoadButton.Text = "Load"
            LoadButton.TextColor3 = Config.UI.TextColor
            LoadButton.TextSize = 12
            LoadButton.Font = Config.UI.Font
            LoadButton.Parent = ScriptItem
            
            -- add corner radius to road button
            local LoadButtonCorner = Instance.new("UICorner")
            LoadButtonCorner.CornerRadius = UDim.new(0, 4)
            LoadButtonCorner.Parent = LoadButton
            
            local DeleteButton = Instance.new("TextButton")
            DeleteButton.Size = UDim2.new(0, 40, 0, 20)
            DeleteButton.Position = UDim2.new(1, -45, 0, 5)
            DeleteButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
            DeleteButton.Text = "Delete"
            DeleteButton.TextColor3 = Config.UI.TextColor
            DeleteButton.TextSize = 12
            DeleteButton.Font = Config.UI.Font
            DeleteButton.Parent = ScriptItem
            
            -- add corner radius to delete button
            local DeleteButtonCorner = Instance.new("UICorner")
            DeleteButtonCorner.CornerRadius = UDim.new(0, 4)
            DeleteButtonCorner.Parent = DeleteButton
            
            LoadButton.MouseButton1Click:Connect(function()
                EditorTextBox.Text = script
            end)
            
            DeleteButton.MouseButton1Click:Connect(function()
                SavedScripts[name] = nil
                RefreshSavedScripts(container)
            end)
            
            index = index + 1
        end
    end
    
    return {
        GetText = function()
            return EditorTextBox.Text
        end,
        SetText = function(text)
            EditorTextBox.Text = text
        end,
        ClearText = function()
            EditorTextBox.Text = ""
        end
    }
end

-- utility functions
local function GetClosestPlayer()
    local closestPlayer = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            -- tteam check
            if not Config.Aimbot.TeamCheck or player.Team ~= LocalPlayer.Team then
                local character = player.Character
                if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                    local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart) or character:FindFirstChild("HumanoidRootPart")
                    if targetPart then
                        local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                        if onScreen then
                            local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                            if distance < shortestDistance and distance <= Config.Aimbot.FOV then
                                closestPlayer = player
                                shortestDistance = distance
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

-- drawing utilities
local DrawingObjects = {}

local function CreateDrawing(type, properties)
    local obj = Drawing.new(type)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    table.insert(DrawingObjects, obj)
    return obj
end

local function ClearDrawings()
    for _, obj in pairs(DrawingObjects) do
        obj:Remove()
    end
    DrawingObjects = {}
end

-- create FOV circle
local FOVCircle = CreateDrawing("Circle", {
    Visible = Config.Aimbot.ShowFOV,
    Color = Config.Aimbot.FOVColor,
    Transparency = 0.5,
    Thickness = 1,
    NumSides = 64,
    Radius = Config.Aimbot.FOV,
    Filled = false
})

-- create tabs
local HomeTab = CreateTab("Home")
local ScriptsTab = CreateTab("Scripts")
local AimbotTab = CreateTab("Aimbot")
local ESPTab = CreateTab("ESP")
local SettingsTab = CreateTab("Settings")

-- home tab content
CreateLabel(HomeTab, "Welcome to Sleek Executor")
CreateLabel(HomeTab, "Version 1.0")

local StatusLabel = CreateLabel(HomeTab, "Status: Ready")
StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)

CreateButton(HomeTab, "Check for Updates", function()
    StatusLabel.Text = "Status: Checking for updates..."
    wait(1)
    StatusLabel.Text = "Status: Up to date!"
end)

-- scripts tab content
local ScriptEditor = CreateScriptEditor(ScriptsTab)

-- create saved scripts section
local SavedScriptsLabel = CreateLabel(ScriptsTab, "Saved Scripts")
SavedScriptsLabel.Position = UDim2.new(0, 0, 0, ScriptsTab.CanvasSize.Y.Offset + 10)

local SavedScriptsContent = Instance.new("Frame")
SavedScriptsContent.Name = "SavedScriptsContent"
SavedScriptsContent.Size = UDim2.new(1, 0, 0, 200)
SavedScriptsContent.Position = UDim2.new(0, 0, 0, ScriptsTab.CanvasSize.Y.Offset + 35)
SavedScriptsContent.BackgroundTransparency = 1
SavedScriptsContent.Parent = ScriptsTab

-- aimbot tab content
CreateLabel(AimbotTab, "Aimbot Settings")

local AimbotToggle = CreateToggle(AimbotTab, "Enable Aimbot", Config.Aimbot.Enabled, function(value)
    Config.Aimbot.Enabled = value
end)

local TeamCheckToggle = CreateToggle(AimbotTab, "Team Check", Config.Aimbot.TeamCheck, function(value)
    Config.Aimbot.TeamCheck = value
end)

local ShowFOVToggle = CreateToggle(AimbotTab, "Show FOV Circle", Config.Aimbot.ShowFOV, function(value)
    Config.Aimbot.ShowFOV = value
    FOVCircle.Visible = value
end)

local FOVSlider = CreateSlider(AimbotTab, "FOV Size", 50, 500, Config.Aimbot.FOV, function(value)
    Config.Aimbot.FOV = value
    FOVCircle.Radius = value
end)

local SensitivitySlider = CreateSlider(AimbotTab, "Sensitivity", 0.1, 1, Config.Aimbot.Sensitivity, function(value)
    Config.Aimbot.Sensitivity = value
end)

local TargetPartDropdown = CreateDropdown(AimbotTab, "Target Part", {"Head", "HumanoidRootPart", "Torso"}, Config.Aimbot.TargetPart, function(value)
    Config.Aimbot.TargetPart = value
end)

local FOVColorPicker = CreateColorPicker(AimbotTab, "FOV Circle Color", Config.Aimbot.FOVColor, function(color)
    Config.Aimbot.FOVColor = color
    FOVCircle.Color = color
end)

-- ESP Tab Content
CreateLabel(ESPTab, "ESP Settings")

local ESPToggle = CreateToggle(ESPTab, "Enable ESP", Config.ESP.Enabled, function(value)
    Config.ESP.Enabled = value
end)

local ESPTeamCheckToggle = CreateToggle(ESPTab, "Team Check", Config.ESP.TeamCheck, function(value)
    Config.ESP.TeamCheck = value
end)

local BoxESPToggle = CreateToggle(ESPTab, "Box ESP", Config.ESP.BoxesEnabled, function(value)
    Config.ESP.BoxesEnabled = value
end)

local NameESPToggle = CreateToggle(ESPTab, "Name ESP", Config.ESP.NamesEnabled, function(value)
    Config.ESP.NamesEnabled = value
end)

local DistanceESPToggle = CreateToggle(ESPTab, "Distance ESP", Config.ESP.DistanceEnabled, function(value)
    Config.ESP.DistanceEnabled = value
end)

local TracerESPToggle = CreateToggle(ESPTab, "Tracers", Config.ESP.TracersEnabled, function(value)
    Config.ESP.TracersEnabled = value
end)

local ESPColorPicker = CreateColorPicker(ESPTab, "ESP Color", Config.ESP.BoxColor, function(color)
    Config.ESP.BoxColor = color
end)

-- Settings Tab Content
CreateLabel(SettingsTab, "UI Settings")

local MainColorPicker = CreateColorPicker(SettingsTab, "Main Color", Config.UI.MainColor, function(color)
    Config.UI.MainColor = color
    MainFrame.BackgroundColor3 = color
end)

local AccentColorPicker = CreateColorPicker(SettingsTab, "Accent Color", Config.UI.AccentColor, function(color)
    Config.UI.AccentColor = color
    TitleBar.BackgroundColor3 = color
    TitleFix.BackgroundColor3 = color
    
    -- Update all accent-colored elements
    for _, child in pairs(MainFrame:GetDescendants()) do
        if child:IsA("TextButton") and child.BackgroundColor3 == Config.UI.AccentColor then
            child.BackgroundColor3 = color
        end
    end
end)

local TextColorPicker = CreateColorPicker(SettingsTab, "Text Color", Config.UI.TextColor, function(color)
    Config.UI.TextColor = color
    
    -- Update all text elements
    for _, child in pairs(MainFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            if child.TextColor3 == Config.UI.TextColor then
                child.TextColor3 = color
            end
        end
    end
end)

local FontDropdown = CreateDropdown(SettingsTab, "Font", {"GothamSemibold", "SourceSans", "Arcade", "Fantasy", "Highway", "SciFi"}, Config.UI.Font.Name, function(value)
    local fontMap = {
        GothamSemibold = Enum.Font.GothamSemibold,
        SourceSans = Enum.Font.SourceSans,
        Arcade = Enum.Font.Arcade,
        Fantasy = Enum.Font.Fantasy,
        Highway = Enum.Font.Highway,
        SciFi = Enum.Font.SciFi
    }
    
    Config.UI.Font = fontMap[value]
    
    -- Update all text elements
    for _, child in pairs(MainFrame:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            child.Font = Config.UI.Font
        end
    end
end)

local TransparencySlider = CreateSlider(SettingsTab, "UI Transparency", 0, 0.9, Config.UI.Transparency, function(value)
    Config.UI.Transparency = value
    MainFrame.BackgroundTransparency = value
    TabContainer.BackgroundTransparency = value
    TitleBar.BackgroundTransparency = value
end)

local ResetButton = CreateButton(SettingsTab, "Reset Settings", function()
    -- Reset to default settings
    Config = {
        UI = {
            MainColor = Color3.fromRGB(45, 45, 45),
            AccentColor = Color3.fromRGB(0, 170, 255),
            TextColor = Color3.fromRGB(255, 255, 255),
            Font = Enum.Font.GothamSemibold,
            CornerRadius = UDim.new(0, 8),
            Transparency = 0.1,
        },
        Animation = {
            TweenSpeed = 0.3,
            EasingStyle = Enum.EasingStyle.Quint,
            EasingDirection = Enum.EasingDirection.Out,
        },
        Aimbot = {
            Enabled = false,
            TeamCheck = true,
            TargetPart = "Head",
            Sensitivity = 0.5,
            FOV = 250,
            ShowFOV = true,
            FOVColor = Color3.fromRGB(255, 255, 255),
        },
        ESP = {
            Enabled = false,
            TeamCheck = true,
            BoxesEnabled = true,
            NamesEnabled = true,
            DistanceEnabled = true,
            TracersEnabled = false,
            BoxColor = Color3.fromRGB(255, 255, 255),
            TextColor = Color3.fromRGB(255, 255, 255),
        }
    }
    
    -- Update UI to reflect reset settings
    MainFrame.BackgroundColor3 = Config.UI.MainColor
    TitleBar.BackgroundColor3 = Config.UI.AccentColor
    TitleFix.BackgroundColor3 = Config.UI.AccentColor
    
    -- Update all UI elements
    AimbotToggle.SetValue(Config.Aimbot.Enabled)
    TeamCheckToggle.SetValue(Config.Aimbot.TeamCheck)
    ShowFOVToggle.SetValue(Config.Aimbot.ShowFOV)
    FOVSlider.SetValue(Config.Aimbot.FOV)
    SensitivitySlider.SetValue(Config.Aimbot.Sensitivity)
    TargetPartDropdown.SetValue(Config.Aimbot.TargetPart)
    FOVColorPicker.SetValue(Config.Aimbot.FOVColor)
    
    ESPToggle.SetValue(Config.ESP.Enabled)
    ESPTeamCheckToggle.SetValue(Config.ESP.TeamCheck)
    BoxESPToggle.SetValue(Config.ESP.BoxesEnabled)
    NameESPToggle.SetValue(Config.ESP.NamesEnabled)
    DistanceESPToggle.SetValue(Config.ESP.DistanceEnabled)
    TracerESPToggle.SetValue(Config.ESP.TracersEnabled)
    ESPColorPicker.SetValue(Config.ESP.BoxColor)
    
    MainColorPicker.SetValue(Config.UI.MainColor)
    AccentColorPicker.SetValue(Config.UI.AccentColor)
    TextColorPicker.SetValue(Config.UI.TextColor)
    TransparencySlider.SetValue(Config.UI.Transparency)
end)

-- Close button functionality
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    ClearDrawings()
end)

-- Show Home tab by default
for _, child in pairs(TabContainer:GetChildren()) do
    if child:IsA("TextButton") and child.Name == "HomeTab" then
        child.BackgroundColor3 = Config.UI.AccentColor
    end
end

for _, child in pairs(ContentFrame:GetChildren()) do
    if child:IsA("ScrollingFrame") and child.Name == "HomeContent" then
        child.Visible = true
    else
        child.Visible = false
    end
end

-- Aimbot functionality
RunService.RenderStepped:Connect(function()
    -- Update FOV Circle position
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
    
    -- Aimbot logic
    if Config.Aimbot.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.E) then -- E key for aiming
        local target = GetClosestPlayer()
        if target then
            local character = target.Character
            if character then
                local targetPart = character:FindFirstChild(Config.Aimbot.TargetPart) or character:FindFirstChild("HumanoidRootPart")
                if targetPart then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        -- Calculate aim position with sensitivity
                        local aimPos = Vector2.new(pos.X, pos.Y)
                        local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                        local newPos = mousePos:Lerp(aimPos, Config.Aimbot.Sensitivity)
                        
                        -- Move mouse to target
                        mousemoveabs(newPos.X, newPos.Y)
                    end
                end
            end
        end
    end
    
    -- ESP Logic
    if Config.ESP.Enabled then
        ClearDrawings() -- Clear previous drawings
        
        -- Recreate FOV Circle since it was cleared
        FOVCircle = CreateDrawing("Circle", {
            Visible = Config.Aimbot.ShowFOV,
            Color = Config.Aimbot.FOVColor,
            Transparency = 0.5,
            Thickness = 1,
            NumSides = 64,
            Radius = Config.Aimbot.FOV,
            Filled = false,
            Position = Vector2.new(Mouse.X, Mouse.Y)
        })
        
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                -- Team check
                if not Config.ESP.TeamCheck or player.Team ~= LocalPlayer.Team then
                    local character = player.Character
                    if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        local head = character:FindFirstChild("Head")
                        
                        if rootPart and head then
                            local rootPos, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
                            
                            if rootOnScreen then
                                -- Calculate character size for ESP box
                                local hrp = rootPart.Position
                                local headPos = head.Position + Vector3.new(0, 0.5, 0)
                                local legPos = rootPart.Position - Vector3.new(0, 3, 0)
                                
                                local headScreenPos = Camera:WorldToViewportPoint(headPos)
                                local legScreenPos = Camera:WorldToViewportPoint(legPos)
                                
                                local boxHeight = math.abs(headScreenPos.Y - legScreenPos.Y)
                                local boxWidth = boxHeight * 0.6
                                
                                -- Box ESP
                                if Config.ESP.BoxesEnabled then
                                    local box = CreateDrawing("Square", {
                                        Visible = true,
                                        Color = Config.ESP.BoxColor,
                                        Thickness = 1,
                                        Transparency = 1,
                                        Filled = false,
                                        Size = Vector2.new(boxWidth, boxHeight),
                                        Position = Vector2.new(rootPos.X - boxWidth / 2, rootPos.Y - boxHeight / 2)
                                    })
                                end
                                
                                -- Name ESP
                                if Config.ESP.NamesEnabled then
                                    local nameText = CreateDrawing("Text", {
                                        Visible = true,
                                        Text = player.Name,
                                        Color = Config.ESP.TextColor,
                                        Transparency = 1,
                                        Size = 18,
                                        Center = true,
                                        Outline = true,
                                        OutlineColor = Color3.new(0, 0, 0),
                                        Position = Vector2.new(rootPos.X, headScreenPos.Y - 20)
                                    })
                                end
                                
                                -- Distance ESP
                                if Config.ESP.DistanceEnabled then
                                    local distance = math.floor((rootPart.Position - Camera.CFrame.Position).Magnitude)
                                    local distanceText = CreateDrawing("Text", {
                                        Visible = true,
                                        Text = tostring(distance) .. "m",
                                        Color = Config.ESP.TextColor,
                                        Transparency = 1,
                                        Size = 16,
                                        Center = true,
                                        Outline = true,
                                        OutlineColor = Color3.new(0, 0, 0),
                                        Position = Vector2.new(rootPos.X, legScreenPos.Y + 5)
                                    })
                                end
                                
                                -- Tracers
                                if Config.ESP.TracersEnabled then
                                    local tracer = CreateDrawing("Line", {
                                        Visible = true,
                                        Color = Config.ESP.BoxColor,
                                        Thickness = 1,
                                        Transparency = 1,
                                        From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y),
                                        To = Vector2.new(rootPos.X, rootPos.Y)
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Make UI draggable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Save settings when the UI is closed
ScreenGui.Destroying:Connect(function()
        
    writefile("executor_settings.json", game:GetService("HttpService"):JSONEncode(Config))
end)


local success, result = pcall(function()
     return readfile("executor_settings.json")
 end)
if success then
     local loadedConfig = game:GetService("HttpService"):JSONDecode(result)
end

-- show the UI
MainFrame.Visible = true

-- add a welcome notification
local NotificationFrame = Instance.new("Frame")
NotificationFrame.Size = UDim2.new(0, 250, 0, 80)
NotificationFrame.Position = UDim2.new(1, -260, 0, 10)
NotificationFrame.BackgroundColor3 = Config.UI.MainColor
NotificationFrame.BackgroundTransparency = 0.1
NotificationFrame.Parent = ScreenGui

-- add corner radius to notification frame
local NotificationFrameCorner = Instance.new("UICorner")
NotificationFrameCorner.CornerRadius = UDim.new(0, 6)
NotificationFrameCorner.Parent = NotificationFrame

local NotificationTitle = Instance.new("TextLabel")
NotificationTitle.Size = UDim2.new(1, 0, 0, 30)
NotificationTitle.BackgroundTransparency = 1
NotificationTitle.Text = "Sleek Executor"
NotificationTitle.TextColor3 = Config.UI.AccentColor
NotificationTitle.TextSize = 16
NotificationTitle.Font = Config.UI.Font
NotificationTitle.Parent = NotificationFrame

local NotificationText = Instance.new("TextLabel")
NotificationText.Size = UDim2.new(1, 0, 0, 40)
NotificationText.Position = UDim2.new(0, 0, 0, 30)
NotificationText.BackgroundTransparency = 1
NotificationText.Text = "Welcome! Press RightShift to toggle UI"
NotificationText.TextColor3 = Config.UI.TextColor
NotificationText.TextSize = 14
NotificationText.Font = Config.UI.Font
NotificationText.Parent = NotificationFrame

-- animate notification
NotificationFrame:TweenPosition(UDim2.new(1, -260, 0, 10), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)

-- remove notification after 5 seconds
spawn(function()
    wait(5)
    NotificationFrame:TweenPosition(UDim2.new(1, 10, 0, 10), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
    wait(0.5)
    NotificationFrame:Destroy()
end)

-- toggle UI with rightshift
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- return the main UI object for external access
return {
    ScreenGui = ScreenGui,
    Config = Config,
    SetVisible = function(visible)
        MainFrame.Visible = visible
    end,
    IsVisible = function()
        return MainFrame.Visible
    end
}
