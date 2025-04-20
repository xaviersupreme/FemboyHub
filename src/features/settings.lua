-- File: src/features/settings.lua
local Settings = {}
local WorkspaceUtil = require(script.Parent.Parent.utils.workspace)

function Settings:Init(ui)
    local tab = ui.Content["Settings"]
    if not tab then return end

    -- 🔁 Auto-load settings on init
    local data = WorkspaceUtil:Load()
    if data then
        print("Auto-loaded workspace save:")
        print(data)

        -- ✅ Apply data if needed
        if data.espEnabled and ui.ToggleESP then
            ui.ToggleESP:Set(true)
        end

        if data.flyEnabled and ui.ToggleFly then
            ui.ToggleFly:Set(true)
        end

        -- Add more as needed...
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
            espEnabled = ui.ToggleESP and ui.ToggleESP:Get(),
            flyEnabled = ui.ToggleFly and ui.ToggleFly:Get(),
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

            if loaded.espEnabled and ui.ToggleESP then
                ui.ToggleESP:Set(true)
            end

            if loaded.flyEnabled and ui.ToggleFly then
                ui.ToggleFly:Set(true)
            end

        end
    end)
end

return Settings
