local Modules = {}
local function requireModule(path)
    if Modules[path] then return Modules[path] end
    local moduleScript = script:FindFirstChild(path, true)
    assert(moduleScript, "Module '" .. path .. "' not found")
    local module = require(moduleScript)
    Modules[path] = module
    return module
end

local Init = {}

function Init:Init()
    local theme = requireModule("ui.theme")
    local uiMain = requireModule("ui.main")
    local ui = uiMain:CreateMainFrame(theme)

    local features = { "aimbot", "esp", "visuals", "movement", "combat", "camera", "settings" }
    for _, featureName in ipairs(features) do
        local featureModule = requireModule("features." .. featureName)
        featureModule:Init(ui)
    end
end

return Init
