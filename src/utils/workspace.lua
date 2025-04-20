local HttpService = game:GetService("HttpService")
local WorkspaceUtil = {}

local saveFile = "FemboyClient_Workspace.json"

function WorkspaceUtil:Save(data)
    if writefile then
        writefile(saveFile, HttpService:JSONEncode(data))
        print("✅ Saved workspace to", saveFile)
    else
        warn("❌ writefile is not supported in this executor.")
    end
end

function WorkspaceUtil:Load()
    if isfile and isfile(saveFile) then
        local raw = readfile(saveFile)
        local success, result = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if success then
            return result
        else
            warn("⚠️ Failed to decode save:", result)
        end
    end
    return nil
end

return WorkspaceUtil
