local Settings = {}
local WorkspaceUtil = require(game:GetService("ReplicatedStorage"):WaitForChild("WorkspaceUtil") or script.Parent.Parent.Parent:WaitForChild("utils"):WaitForChild("workspace"))

function Settings:Init(ui)
    local tab = ui.Content["Settings"]
    if not tab then return end

    -- AUto load settings on init
    local data = WorkspaceUtil:Load()
    if data then
        print("Auto loaded workspace save:")
        print(data)
        -- Example: Apply saved settings here
        -- Example: toggleFeature = data.toggleFeature
    end

    -- Save button
    local saveBtn = Instance.new("TextButton")
    saveBtn.Text = "💾 Save Settings"
    saveBtn.Size = UDim2.new(0, 180, 0, 30)
    saveBtn.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
    saveBtn.TextColor3 = Color3.new(0, 0.7, 0)
    saveBtn.Parent = tab
    saveBtn.MouseButton1Click:Connect(function()
        WorkspaceUtil:Save({
            someSetting = true,
            user = game.Players.LocalPlayer.Name,
            timestamp = tick()
        })
    end)

    -- Load button
    local loadBtn = Instance.new("TextButton")
    loadBtn.Text = "📂 Load Settings"
    loadBtn.Size = UDim2.new(0, 180, 0, 30)
    loadBtn.Position = UDim2.new(0, 0, 0, 40)
    loadBtn.BackgroundColor3 = Color3.fromRGB(235, 235, 240)
    loadBtn.TextColor3 = Color3.new(0.2, 0.4, 1)
    loadBtn.Parent = tab
    loadBtn.MouseButton1Click:Connect(function()
        local loaded = WorkspaceUtil:Load()
        if loaded then
            print("Manually loaded save:")
            print(loaded)
        end
    end)
end

return Settings
