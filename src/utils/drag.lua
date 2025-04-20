local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local DragUtil = {}

function DragUtil:EnableDrag(frame)
    local dragging, dragStart, startPos, velocity = false, nil, nil, Vector2.zero

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            velocity = velocity:Lerp(delta, 0.2)
            frame.Position = startPos + UDim2.new(0, velocity.X, 0, velocity.Y)
        end
    end)

    RunService.RenderStepped:Connect(function()
        if not dragging then
            velocity = velocity * 0.85
            frame.Position = frame.Position + UDim2.new(0, velocity.X, 0, velocity.Y)
        end
    end)
end

return DragUtil
