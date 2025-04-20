local Settings = {}
local WorkspaceUtil = require(script.Parent.Parent.utils.workspace)

local ESPModule = require(script.Parent.esp)
local AimbotModule = require(script.Parent.aimbot)

function Settings:Init(ui)
    local tab = ui.Content["Settings"]
    if not tab then return end

    -- AUto load on init
    local data = WorkspaceUtil:Load()
    if data then
        print("✅ Auto-loaded workspace save:")
        print(data)

        -- Apply settings if present
        if data.espEnabled ~= nil then
            ESPModule:SetEnabled(data.espEnabled)
        end

        if data.aimbotHoldKey ~= nil then
            AimbotModule:SetKey(data.aimbotHoldKey)
        end
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
            espEnabled = ESPModule:IsEnabled(),
            aimbotHoldKey = AimbotModule:GetKey(),
            username = game.Players.LocalPlayer.Name,
            time = os.date(),
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
            print("📂 Manually loaded save:")
            print(loaded)

            if loaded.espEnabled ~= nil then
                ESPModule:SetEnabled(loaded.espEnabled)
            end

            if loaded.aimbotHoldKey ~= nil then
                AimbotModule:SetKey(loaded.aimbotHoldKey)
            end
        end
    end)
end

return Settings
