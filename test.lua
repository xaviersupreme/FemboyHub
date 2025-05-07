local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local TextService = game:GetService("TextService")

local localPlayer = Players.LocalPlayer
local guiParent = CoreGui or localPlayer:WaitForChild("PlayerGui")

local function CreateInstance(className, properties)
    local inst = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        if type(prop) == "string" then
            pcall(function() inst[prop] = value end)
        end
    end
    return inst
end

local Signal = {}
Signal.__index = Signal
function Signal.new()
    local self = setmetatable({}, Signal)
    self._connections = {}
    return self
end
function Signal:Connect(func)
    local connection = {Function = func, Connected = true}
    table.insert(self._connections, connection)
    return {
        Disconnect = function()
            connection.Connected = false
            for i, conn in ipairs(self._connections) do
                if conn == connection then
                    table.remove(self._connections, i)
                    break
                end
            end
        end,
        Connected = function() return connection.Connected end
    }
end
function Signal:Fire(...)
    local args = {...}
    for _, conn in ipairs(self._connections) do
        if conn.Connected then
            task.spawn(conn.Function, unpack(args))
        end
    end
end
function Signal:Wait()
    local thread = coroutine.running()
    local connection
    connection = self:Connect(function(...)
        if connection and connection.Connected then connection.Disconnect() end
        task.spawn(thread, ...)
    end)
    return coroutine.yield()
end
function Signal:Destroy()
    for _, connWrapper in ipairs(self._connections) do
        connWrapper.Connected = false
    end
    self._connections = {}
end

local UI_GLOBALS = {
    Z_BASE = 6000,
    Z_STEP = 100,
    Z_WINDOW_ACTIVE_OFFSET = 500,
    DRAG_CURSOR = "rbxasset://textures/MouseCursors/NinjaFileNoWriteCursors/IBeamCursor.png",
    RESIZE_CURSORS = {
        N = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeVertCursor.png",
        S = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeVertCursor.png",
        E = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeHorzCursor.png",
        W = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeHorzCursor.png",
        NW = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeDiagonal2Cursor.png",
        SE = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeDiagonal2Cursor.png",
        NE = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeDiagonal1Cursor.png",
        SW = "rbxasset://textures/MouseCursors/MouseCursorFrames/ResizeDiagonal1Cursor.png",
    },
    THEME = {
        ACCENT_PRIMARY = Color3.fromRGB(0, 122, 204),
        ACCENT_SECONDARY = Color3.fromRGB(0, 90, 158),
        BACKGROUND = Color3.fromRGB(30, 30, 30),
        SURFACE_1 = Color3.fromRGB(45, 45, 48),
        SURFACE_2 = Color3.fromRGB(60, 60, 63),
        INPUT_BACKGROUND = Color3.fromRGB(25, 25, 28),
        TEXT_PRIMARY = Color3.fromRGB(240, 240, 240),
        TEXT_SECONDARY = Color3.fromRGB(180, 180, 180),
        TEXT_DISABLED = Color3.fromRGB(120, 120, 120),
        ERROR = Color3.fromRGB(240, 60, 60),
        SUCCESS = Color3.fromRGB(60, 200, 60),
        WARNING = Color3.fromRGB(240, 180, 60),
        STROKE_COLOR = Color3.fromRGB(80, 80, 80),
        STROKE_ACCENT = Color3.fromRGB(0, 122, 204),
        FONT_PRIMARY = Enum.Font.SourceSans,
        FONT_SEMIBOLD = Enum.Font.SourceSansSemibold,
        FONT_BOLD = Enum.Font.SourceSansBold,
        FONT_CODE = Enum.Font.RobotoMono,
        CORNER_RADIUS_S = UDim.new(0, 3),
        CORNER_RADIUS_M = UDim.new(0, 5),
        CORNER_RADIUS_L = UDim.new(0, 8),
        STROKE_THICKNESS_S = 1,
        STROKE_THICKNESS_M = 2,
        STROKE_THICKNESS_L = 3,
    },
    WINDOWS = {},
    ACTIVE_WINDOW = nil,
    NEXT_WINDOW_ID = 1,
    EVENT_BUS = Signal.new(),
}
UI_GLOBALS.EVENT_BUS:Connect(function(event, ...)
    if event == "THEME_CHANGED" then
        UI_GLOBALS.THEME = ...
        for _, window in pairs(UI_GLOBALS.WINDOWS) do
            if window.ApplyTheme then window:ApplyTheme() end
        end
    end
end)

local WindowManager = {}
function WindowManager.GetNextZIndex()
    local maxZ = UI_GLOBALS.Z_BASE
    for _, win in pairs(UI_GLOBALS.WINDOWS) do
        if win.mainFrame and win.mainFrame.ZIndex > maxZ then
            maxZ = win.mainFrame.ZIndex
        end
    end
    return maxZ + UI_GLOBALS.Z_STEP
end
function WindowManager.BringToFront(window)
    if UI_GLOBALS.ACTIVE_WINDOW == window then return end
    local oldActive = UI_GLOBALS.ACTIVE_WINDOW
    UI_GLOBALS.ACTIVE_WINDOW = window

    local currentMaxZ = UI_GLOBALS.Z_BASE
    for id, win in pairs(UI_GLOBALS.WINDOWS) do
        if win ~= window and win.screenGui then
            win.baseZIndex = win.baseZIndex or UI_GLOBALS.Z_BASE + (id * UI_GLOBALS.Z_STEP / 10) 
            win.screenGui.DisplayOrder = math.floor(win.baseZIndex / UI_GLOBALS.Z_STEP) * UI_GLOBALS.Z_STEP
            win:_updateZIndices(win.baseZIndex)
            if win.baseZIndex > currentMaxZ then currentMaxZ = win.baseZIndex end
        end
    end
    
    window.baseZIndex = currentMaxZ + UI_GLOBALS.Z_WINDOW_ACTIVE_OFFSET
    window.screenGui.DisplayOrder = math.floor(window.baseZIndex / UI_GLOBALS.Z_STEP) * UI_GLOBALS.Z_STEP
    window:_updateZIndices(window.baseZIndex)

    if oldActive and oldActive.OnDeactivated then oldActive:OnDeactivated() end
    if window.OnActivated then window:OnActivated() end
    UI_GLOBALS.EVENT_BUS:Fire("WINDOW_FOCUS_CHANGED", window, oldActive)
end
function WindowManager.RegisterWindow(window)
    window.id = UI_GLOBALS.NEXT_WINDOW_ID
    UI_GLOBALS.NEXT_WINDOW_ID += 1
    UI_GLOBALS.WINDOWS[window.id] = window
end
function WindowManager.UnregisterWindow(window)
    if UI_GLOBALS.WINDOWS[window.id] then
        UI_GLOBALS.WINDOWS[window.id] = nil
        if UI_GLOBALS.ACTIVE_WINDOW == window then
            local highestZ, nextActive = -1, nil
            for _, win in pairs(UI_GLOBALS.WINDOWS) do
                if win.mainFrame and win.mainFrame.ZIndex > highestZ then
                    highestZ = win.mainFrame.ZIndex
                    nextActive = win
                end
            end
            if nextActive then WindowManager.BringToFront(nextActive)
            else UI_GLOBALS.ACTIVE_WINDOW = nil
            end
        end
    end
end

local DraggableWindow = {}
DraggableWindow.__index = DraggableWindow

function DraggableWindow.new(params)
    local self = setmetatable({}, DraggableWindow)
    self.title = params.title or "Window"
    self.initialSize = params.size or UDim2.new(0, 500, 0, 400)
    self.minSize = params.minSize or Vector2.new(200, 150)
    self.initialPosition = params.position or UDim2.new(0.5, -self.initialSize.X.Offset / 2, 0.5, -self.initialSize.Y.Offset / 2)
    self.isResizable = params.resizable ~= false
    self.hasCloseButton = params.closeButton ~= false
    self.hasMinimizeButton = params.minimizeButton == true
    self.hasMaximizeButton = params.maximizeButton == true
    self.features = {}
    self.connections = {}
    self.uiElements = {}
    self.isDragging = false
    self.isResizing = false
    self.resizeDirection = nil
    self.dragStartMouse = Vector2.zero
    self.dragStartPos = UDim2.new()
    self.dragStartSize = Vector2.zero
    self.velocity = Vector2.zero
    self.lastMousePos = Vector2.zero
    self.inertiaFriction = 0.92
    self.minInertiaSpeed = 0.5
    self.boundaryPadding = 10
    self.isDestroyed = false
    self.isMinimized = false
    self.isMaximized = false
    self.preMaximizeState = {}
    self.id = -1 
    self.baseZIndex = UI_GLOBALS.Z_BASE

    self.OnResized = Signal.new()
    self.OnMoved = Signal.new()
    self.OnClosed = Signal.new()
    self.OnMinimized = Signal.new()
    self.OnMaximized = Signal.new()
    self.OnRestored = Signal.new()
    self.OnActivated = Signal.new()
    self.OnDeactivated = Signal.new()

    self:_createBaseUI()
    self:_connectBaseEvents()
    WindowManager.RegisterWindow(self)
    WindowManager.BringToFront(self) 
    self:ApplyTheme()
    return self
end

function DraggableWindow:_createBaseUI()
    self.screenGui = CreateInstance("ScreenGui", {
        Name = "WindowScreenGui_" .. self.title:gsub("%W", "") .. "_" .. math.random(1,1e5),
        Parent = guiParent,
        ResetOnSpawn = false,
        DisplayOrder = math.floor(self.baseZIndex / UI_GLOBALS.Z_STEP) * UI_GLOBALS.Z_STEP,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    self.mainFrame = CreateInstance("Frame", {
        Name = "MainFrame",
        Size = self.initialSize,
        Position = self.initialPosition,
        Active = true,
        Selectable = true,
        ClipsDescendants = true,
        Parent = self.screenGui,
    })
    self.uiElements.mainFrame = self.mainFrame

    self.uiElements.mainFrameCorner = CreateInstance("UICorner", {Parent = self.mainFrame})
    self.uiElements.mainFrameStroke = CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = self.mainFrame})
    self.uiElements.mainFrameShadowStroke = CreateInstance("UIStroke", {ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = self.mainFrame})

    self.headerBar = CreateInstance("Frame", {
        Name = "HeaderBar",
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.mainFrame,
    })
    self.uiElements.headerBar = self.headerBar
    self.uiElements.headerBarStroke = CreateInstance("UIStroke", {Parent = self.headerBar})

    self.titleLabel = CreateInstance("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, 0, 1, 0), 
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = self.headerBar,
    })
    self.uiElements.titleLabel = self.titleLabel

    local buttonContainer = CreateInstance("Frame", {
        Name = "ButtonContainer",
        Size = UDim2.new(0,0,1,-8),
        Position = UDim2.new(1,0,0.5,0),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = self.headerBar
    })
    self.uiElements.buttonContainer = buttonContainer
    local buttonLayout = CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 4),
        Parent = buttonContainer
    })
    self.uiElements.buttonLayout = buttonLayout
    
    local currentButtonX = -10
    if self.hasCloseButton then
        self.closeButton = self:_createHeaderButton("Close", "rbxassetid://13516659053", function() self:Close() end) -- Placeholder X icon
        currentButtonX = currentButtonX - self.closeButton.AbsoluteSize.X - 4
        buttonContainer.Size = UDim2.new(0, buttonContainer.Size.X.Offset + self.closeButton.AbsoluteSize.X + 4, 1, -8)
    end
    if self.hasMaximizeButton then
        self.maximizeButton = self:_createHeaderButton("Maximize", "rbxassetid://13516659053", function() self:ToggleMaximize() end) -- Placeholder Max icon
        currentButtonX = currentButtonX - self.maximizeButton.AbsoluteSize.X - 4
        buttonContainer.Size = UDim2.new(0, buttonContainer.Size.X.Offset + self.maximizeButton.AbsoluteSize.X + 4, 1, -8)
    end
    if self.hasMinimizeButton then
        self.minimizeButton = self:_createHeaderButton("Minimize", "rbxassetid://13516659053", function() self:SetMinimized(true) end) -- Placeholder Min icon
        currentButtonX = currentButtonX - self.minimizeButton.AbsoluteSize.X - 4
        buttonContainer.Size = UDim2.new(0, buttonContainer.Size.X.Offset + self.minimizeButton.AbsoluteSize.X + 4, 1, -8)
    end
    buttonContainer.Position = UDim2.new(1, - (buttonContainer.Size.X.Offset + 10), 0.5, 0)
    self.titleLabel.Size = UDim2.new(1, -(buttonContainer.Size.X.Offset + 20), 1, 0)


    self.contentFrame = CreateInstance("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, 0, 1, -self.headerBar.Size.Y.Offset),
        Position = UDim2.new(0, 0, 0, self.headerBar.Size.Y.Offset),
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Parent = self.mainFrame,
    })
    self.uiElements.contentFrame = self.contentFrame

    if self.isResizable then
        self.resizeHandles = {}
        local directions = {"N", "S", "E", "W", "NW", "NE", "SW", "SE"}
        local handleSize = 8
        for _, dir in ipairs(directions) do
            local handle = CreateInstance("Frame", {
                Name = "ResizeHandle" .. dir,
                Size = UDim2.new(0, handleSize, 0, handleSize),
                BackgroundTransparency = 1, -- Make transparent for production
                --BackgroundColor3 = Color3.new(1,0,0), Transparency = 0.5, -- For debugging
                Parent = self.mainFrame,
                ZIndex = self.mainFrame.ZIndex + 10, 
            })
            self.resizeHandles[dir] = handle
            self:_positionResizeHandle(dir, handle, handleSize)
        end
    end
    self:_updateZIndices(self.baseZIndex)
end

function DraggableWindow:_createHeaderButton(name, iconId, callback)
    local button = CreateInstance("ImageButton", {
        Name = name .. "Button",
        Size = UDim2.new(0, 20, 0, 20),
        BackgroundTransparency = 1,
        Image = iconId,
        ScaleType = Enum.ScaleType.Fit,
        LayoutOrder = name == "Close" and 3 or (name == "Maximize" and 2 or 1),
        Parent = self.uiElements.buttonContainer,
    })
    self.uiElements[name.."Button"] = button
    self.connections[name.."ButtonClick"] = button.MouseButton1Click:Connect(callback)
    
    button.MouseEnter:Connect(function() button.ImageColor3 = UI_GLOBALS.THEME.ACCENT_PRIMARY end)
    button.MouseLeave:Connect(function() button.ImageColor3 = UI_GLOBALS.THEME.TEXT_SECONDARY end)
    return button
end


function DraggableWindow:_positionResizeHandle(dir, handle, size)
    if dir == "N" then handle.Size = UDim2.new(1, -size*2, 0, size); handle.Position = UDim2.new(0,size,0,0)
    elseif dir == "S" then handle.Size = UDim2.new(1, -size*2, 0, size); handle.Position = UDim2.new(0,size,1,-size)
    elseif dir == "E" then handle.Size = UDim2.new(0, size, 1, -size*2); handle.Position = UDim2.new(1,-size,0,size)
    elseif dir == "W" then handle.Size = UDim2.new(0, size, 1, -size*2); handle.Position = UDim2.new(0,0,0,size)
    elseif dir == "NW" then handle.Position = UDim2.new(0,0,0,0)
    elseif dir == "NE" then handle.Position = UDim2.new(1,-size,0,0)
    elseif dir == "SW" then handle.Position = UDim2.new(0,0,1,-size)
    elseif dir == "SE" then handle.Position = UDim2.new(1,-size,1,-size)
    end
end

function DraggableWindow:ApplyTheme()
    local theme = UI_GLOBALS.THEME
    self.mainFrame.BackgroundColor3 = theme.BACKGROUND
    self.uiElements.mainFrameCorner.CornerRadius = theme.CORNER_RADIUS_L
    self.uiElements.mainFrameStroke.Thickness = theme.STROKE_THICKNESS_M
    self.uiElements.mainFrameStroke.Color = theme.STROKE_ACCENT
    self.uiElements.mainFrameShadowStroke.Thickness = theme.STROKE_THICKNESS_M + 2
    self.uiElements.mainFrameShadowStroke.Color = Color3.new(0,0,0)
    self.uiElements.mainFrameShadowStroke.Transparency = 0.7

    self.headerBar.BackgroundColor3 = theme.SURFACE_1
    self.uiElements.headerBarStroke.Thickness = theme.STROKE_THICKNESS_S
    self.uiElements.headerBarStroke.Color = theme.STROKE_COLOR
    self.titleLabel.Font = theme.FONT_SEMIBOLD
    self.titleLabel.TextColor3 = theme.TEXT_PRIMARY
    self.titleLabel.TextSize = 16
    self.titleLabel.PaddingLeft = UDim.new(0,10)

    for btnName, btn in pairs(self.uiElements) do
        if btn and btn:IsA("ImageButton") and btn.Parent == self.uiElements.buttonContainer then
            btn.ImageColor3 = theme.TEXT_SECONDARY
        end
    end
    
    for _, feature in pairs(self.features) do
        if feature.ApplyTheme then feature:ApplyTheme(theme) end
    end
end

function DraggableWindow:_updateZIndices(baseZ)
    if not self.mainFrame or self.isDestroyed then return end
    baseZ = baseZ or self.baseZIndex

    self.mainFrame.ZIndex = baseZ
    self.headerBar.ZIndex = baseZ + 2
    self.titleLabel.ZIndex = baseZ + 3
    if self.closeButton then self.closeButton.ZIndex = baseZ + 3 end
    if self.minimizeButton then self.minimizeButton.ZIndex = baseZ + 3 end
    if self.maximizeButton then self.maximizeButton.ZIndex = baseZ + 3 end
    self.contentFrame.ZIndex = baseZ + 1

    if self.resizeHandles then
        for _, handle in pairs(self.resizeHandles) do
            handle.ZIndex = baseZ + 5
        end
    end
    
    for _, feature in pairs(self.features) do
        if feature.UpdateZIndex then feature:UpdateZIndex(baseZ + 1) end
    end
end

function DraggableWindow:_connectBaseEvents()
    self.connections.mainFrameInputBegan = self.mainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            WindowManager.BringToFront(self)
            if input.UserInputObject == self.headerBar or input.UserInputObject == self.titleLabel then
                self:_startDrag(input)
            elseif self.isResizable and self.resizeHandles then
                for dir, handle in pairs(self.resizeHandles) do
                    if input.UserInputObject == handle then
                        self:_startResize(input, dir)
                        break
                    end
                end
            end
        end
    end)

    self.connections.mainFrameInputChanged = self.mainFrame.InputChanged:Connect(function(input)
        if self.isResizable and not self.isDragging and not self.isResizing then
             if input.UserInputType == Enum.UserInputType.MouseMovement then
                local mousePos = UserInputService:GetMouseLocation() - self.mainFrame.AbsolutePosition
                local dir = self:_getResizeDirectionFromPosition(mousePos, self.mainFrame.AbsoluteSize, 8)
                if dir then
                    GuiService.MouseIcon = UI_GLOBALS.RESIZE_CURSORS[dir]
                else
                    GuiService.MouseIcon = ""
                end
            end
        end
    end)
    self.connections.mainFrameMouseLeave = self.mainFrame.MouseLeave:Connect(function()
        if not self.isResizing and not self.isDragging then GuiService.MouseIcon = "" end
    end)


    self.connections.globalInputChanged = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if self.isDragging then self:_handleDrag(input)
            elseif self.isResizing then self:_handleResize(input)
            end
        end
    end)

    self.connections.globalInputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            if self.isDragging then self:_endDrag()
            elseif self.isResizing then self:_endResize()
            end
        end
    end)

    if self.headerBar.InputBegan then -- Check in case headerBar is nil during rapid destruction
        self.connections.headerDoubleClick = self.headerBar.MouseButton1DoubleClick:Connect(function()
            if self.hasMaximizeButton then self:ToggleMaximize() end
        end)
    end
end

function DraggableWindow:_getResizeDirectionFromPosition(mousePos, windowSize, handleThickness)
    local onLeft = mousePos.X < handleThickness
    local onRight = mousePos.X > windowSize.X - handleThickness
    local onTop = mousePos.Y < handleThickness
    local onBottom = mousePos.Y > windowSize.Y - handleThickness

    if onTop then
        if onLeft then return "NW"
        elseif onRight then return "NE"
        else return "N" end
    elseif onBottom then
        if onLeft then return "SW"
        elseif onRight then return "SE"
        else return "S" end
    elseif onLeft then return "W"
    elseif onRight then return "E"
    end
    return nil
end

function DraggableWindow:_startDrag(input)
    if self.isMaximized then return end
    self.isDragging = true
    if self.inertiaConnection then self.inertiaConnection:Disconnect(); self.inertiaConnection = nil end
    self.velocity = Vector2.zero
    self.dragStartMouse = input.Position
    self.dragStartPos = self.mainFrame.Position
    self.lastMousePos = input.Position
    GuiService.MouseIcon = UI_GLOBALS.DRAG_CURSOR
end

function DraggableWindow:_handleDrag(input)
    local delta = input.Position - self.dragStartMouse
    local newX = self.dragStartPos.X.Offset + delta.X
    local newY = self.dragStartPos.Y.Offset + delta.Y
    local newPos = UDim2.new(self.dragStartPos.X.Scale, newX, self.dragStartPos.Y.Scale, newY)
    self.mainFrame.Position = self:_getClampedPosition(newPos, self.mainFrame.AbsoluteSize)
    self.velocity = input.Position - self.lastMousePos
    self.lastMousePos = input.Position
    self.OnMoved:Fire(self.mainFrame.Position)
end

function DraggableWindow:_endDrag()
    self.isDragging = false
    GuiService.MouseIcon = ""
    if self.velocity.Magnitude > self.minInertiaSpeed then self:_startInertia() end
end

function DraggableWindow:_startInertia()
    if self.inertiaConnection then self.inertiaConnection:Disconnect() end
    self.inertiaConnection = RunService.RenderStepped:Connect(function()
        if self.isDragging or self.isDestroyed then
            if self.inertiaConnection then self.inertiaConnection:Disconnect(); self.inertiaConnection = nil end
            return
        end
        local currentPos = self.mainFrame.Position
        local newX = currentPos.X.Offset + self.velocity.X
        local newY = currentPos.Y.Offset + self.velocity.Y
        local newPos = UDim2.new(currentPos.X.Scale, newX, currentPos.Y.Scale, newY)
        self.mainFrame.Position = self:_getClampedPosition(newPos, self.mainFrame.AbsoluteSize)
        self.velocity *= self.inertiaFriction
        if self.velocity.Magnitude < self.minInertiaSpeed then
            self.velocity = Vector2.zero
            if self.inertiaConnection then self.inertiaConnection:Disconnect(); self.inertiaConnection = nil end
        end
        self.OnMoved:Fire(self.mainFrame.Position)
    end)
end

function DraggableWindow:_startResize(input, direction)
    if self.isMaximized then return end
    self.isResizing = true
    self.resizeDirection = direction
    self.dragStartMouse = input.Position
    self.dragStartPos = self.mainFrame.AbsolutePosition
    self.dragStartSize = self.mainFrame.AbsoluteSize
    GuiService.MouseIcon = UI_GLOBALS.RESIZE_CURSORS[direction] or ""
end

function DraggableWindow:_handleResize(input)
    local mouseDelta = input.Position - self.dragStartMouse
    local newPos = self.dragStartPos
    local newSize = self.dragStartSize

    if string.find(self.resizeDirection, "N") then
        local deltaY = math.min(mouseDelta.Y, newSize.Y - self.minSize.Y)
        newPos = Vector2.new(newPos.X, newPos.Y + deltaY)
        newSize = Vector2.new(newSize.X, newSize.Y - deltaY)
    elseif string.find(self.resizeDirection, "S") then
        newSize = Vector2.new(newSize.X, math.max(self.minSize.Y, newSize.Y + mouseDelta.Y))
    end

    if string.find(self.resizeDirection, "W") then
        local deltaX = math.min(mouseDelta.X, newSize.X - self.minSize.X)
        newPos = Vector2.new(newPos.X + deltaX, newPos.Y)
        newSize = Vector2.new(newSize.X - deltaX, newSize.Y)
    elseif string.find(self.resizeDirection, "E") then
        newSize = Vector2.new(math.max(self.minSize.X, newSize.X + mouseDelta.X), newSize.Y)
    end
    
    local viewport = workspace.CurrentCamera.ViewportSize
    newPos = Vector2.new(math.max(self.boundaryPadding, newPos.X), math.max(self.boundaryPadding, newPos.Y))
    newSize = Vector2.new(
        math.min(newSize.X, viewport.X - newPos.X - self.boundaryPadding),
        math.min(newSize.Y, viewport.Y - newPos.Y - self.boundaryPadding)
    )

    self.mainFrame.Position = UDim2.fromOffset(newPos.X, newPos.Y)
    self.mainFrame.Size = UDim2.fromOffset(newSize.X, newSize.Y)
    self.OnResized:Fire(self.mainFrame.Size)
end

function DraggableWindow:_endResize()
    self.isResizing = false
    self.resizeDirection = nil
    GuiService.MouseIcon = ""
end

function DraggableWindow:_getClampedPosition(newPos, frameSize)
    local viewport = workspace.CurrentCamera.ViewportSize
    local minX = self.boundaryPadding - (newPos.X.Scale * viewport.X)
    local minY = self.boundaryPadding - (newPos.Y.Scale * viewport.Y)
    local maxX = viewport.X - frameSize.X - self.boundaryPadding - (newPos.X.Scale * viewport.X)
    local maxY = viewport.Y - frameSize.Y - self.boundaryPadding - (newPos.Y.Scale * viewport.Y)
    return UDim2.new(
        newPos.X.Scale, math.clamp(newPos.X.Offset, minX, maxX),
        newPos.Y.Scale, math.clamp(newPos.Y.Offset, minY, maxY)
    )
end

function DraggableWindow:SetMinimized(isMinimized)
    if self.isDestroyed or self.isMinimized == isMinimized then return end
    self.isMinimized = isMinimized
    self.mainFrame.Visible = not isMinimized
    if isMinimized then
        self.OnMinimized:Fire()
        if UI_GLOBALS.ACTIVE_WINDOW == self then
            local highestZ, nextActive = -1, nil
            for _, win in pairs(UI_GLOBALS.WINDOWS) do
                if win ~= self and not win.isMinimized and win.mainFrame and win.mainFrame.ZIndex > highestZ then
                    highestZ = win.mainFrame.ZIndex
                    nextActive = win
                end
            end
            if nextActive then WindowManager.BringToFront(nextActive) end
        end
    else
        self.OnRestored:Fire()
        WindowManager.BringToFront(self)
    end
end

function DraggableWindow:ToggleMaximize()
    if self.isDestroyed or self.isMinimized then return end
    self.isMaximized = not self.isMaximized
    if self.isMaximized then
        self.preMaximizeState.Position = self.mainFrame.Position
        self.preMaximizeState.Size = self.mainFrame.Size
        local viewport = workspace.CurrentCamera.ViewportSize
        self.mainFrame.Position = UDim2.fromOffset(0,0)
        self.mainFrame.Size = UDim2.fromOffset(viewport.X, viewport.Y)
        if self.isResizable then for _,h in pairs(self.resizeHandles) do h.Visible = false end end
        self.OnMaximized:Fire()
    else
        self.mainFrame.Position = self.preMaximizeState.Position
        self.mainFrame.Size = self.preMaximizeState.Size
        if self.isResizable then for _,h in pairs(self.resizeHandles) do h.Visible = true end end
        self.OnRestored:Fire()
    end
    self.OnResized:Fire(self.mainFrame.Size) 
end


function DraggableWindow:Close()
    if self.isDestroyed then return end
    self.isDestroyed = true
    self.OnClosed:Fire()
    WindowManager.UnregisterWindow(self)
    for _, conn in pairs(self.connections) do if conn and conn.Disconnect then conn:Disconnect() end end
    if self.inertiaConnection then self.inertiaConnection:Disconnect() end
    for _, sig in pairs({self.OnResized, self.OnMoved, self.OnClosed, self.OnMinimized, self.OnMaximized, self.OnRestored, self.OnActivated, self.OnDeactivated}) do sig:Destroy() end
    for _, feature in pairs(self.features) do if feature.Destroy then feature:Destroy() end end
    self.features = {}
    if self.screenGui then self.screenGui:Destroy() end
    for k in pairs(self) do self[k] = nil end
    setmetatable(self, nil)
end

function DraggableWindow:AddFeature(featureName, featureInstance)
    self.features[featureName] = featureInstance
    if featureInstance.Initialize then
        featureInstance:Initialize(self, self.contentFrame)
    end
    if featureInstance.ApplyTheme then
        featureInstance:ApplyTheme(UI_GLOBALS.THEME)
    end
    if featureInstance.UpdateZIndex then
        featureInstance:UpdateZIndex(self.baseZIndex + 1)
    end
end

function DraggableWindow:GetFeature(featureName)
    return self.features[featureName]
end

function DraggableWindow:SetTitle(title)
    self.title = title
    if self.titleLabel then self.titleLabel.Text = title end
end

-- Example Feature: TabManager
local TabManagerFeature = {}
TabManagerFeature.__index = TabManagerFeature
function TabManagerFeature.new()
    local self = setmetatable({}, TabManagerFeature)
    self.tabs = {}
    self.activeTab = nil
    self.uiElements = {}
    self.connections = {}
    self.window = nil
    self.parentFrame = nil
    return self
end
function TabManagerFeature:Initialize(window, parentFrame)
    self.window = window
    self.parentFrame = parentFrame
    self:_createUI()
end
function TabManagerFeature:_createUI()
    self.uiElements.tabBar = CreateInstance("Frame", {
        Name = "TabBar", Size = UDim2.new(1,0,0,30), BackgroundColor = UI_GLOBALS.THEME.SURFACE_2, Parent = self.parentFrame
    })
    self.uiElements.tabBarLayout = CreateInstance("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0,4), Parent = self.uiElements.tabBar
    })
    self.uiElements.tabContentContainer = CreateInstance("Frame", {
        Name = "TabContentContainer", Size = UDim2.new(1,0,1,-30), Position = UDim2.new(0,0,0,30), BackgroundTransparency = 1, Parent = self.parentFrame
    })
end
function TabManagerFeature:AddTab(tabTitle, featureInstance)
    local tabData = {title = tabTitle, feature = featureInstance, ui = {}}
    tabData.ui.button = CreateInstance("TextButton", {
        Name = tabTitle .. "Tab", Text = tabTitle, AutoButtonColor = false, Size = UDim2.new(0,100,1,0), Parent = self.uiElements.tabBar
    })
    tabData.ui.buttonCorner = CreateInstance("UICorner", {CornerRadius = UI_GLOBALS.THEME.CORNER_RADIUS_S, Parent = tabData.ui.button})
    
    if featureInstance.Initialize then featureInstance:Initialize(self.window, self.uiElements.tabContentContainer) end
    if featureInstance.GetRootInstance then 
        local root = featureInstance:GetRootInstance()
        root.Visible = false
        root.Parent = self.uiElements.tabContentContainer
    end

    self.connections["TabClick_"..tabTitle] = tabData.ui.button.MouseButton1Click:Connect(function() self:SelectTab(tabData) end)
    table.insert(self.tabs, tabData)
    if not self.activeTab then self:SelectTab(tabData) end
    self:ApplyTheme(UI_GLOBALS.THEME) 
    return tabData
end
function TabManagerFeature:SelectTab(tabData)
    if self.activeTab then
        self.activeTab.ui.button.BackgroundColor = UI_GLOBALS.THEME.SURFACE_2
        self.activeTab.ui.button.TextColor3 = UI_GLOBALS.THEME.TEXT_SECONDARY
        if self.activeTab.feature.GetRootInstance then self.activeTab.feature:GetRootInstance().Visible = false end
        if self.activeTab.feature.Deactivate then self.activeTab.feature:Deactivate() end
    end
    self.activeTab = tabData
    self.activeTab.ui.button.BackgroundColor = UI_GLOBALS.THEME.BACKGROUND
    self.activeTab.ui.button.TextColor3 = UI_GLOBALS.THEME.TEXT_PRIMARY
    if self.activeTab.feature.GetRootInstance then self.activeTab.feature:GetRootInstance().Visible = true end
    if self.activeTab.feature.Activate then self.activeTab.feature:Activate() end
end
function TabManagerFeature:ApplyTheme(theme)
    self.uiElements.tabBar.BackgroundColor3 = theme.SURFACE_2
    for _, tabData in ipairs(self.tabs) do
        tabData.ui.button.Font = theme.FONT_PRIMARY
        tabData.ui.button.TextSize = 14
        if tabData == self.activeTab then
            tabData.ui.button.BackgroundColor3 = theme.BACKGROUND
            tabData.ui.button.TextColor3 = theme.TEXT_PRIMARY
        else
            tabData.ui.button.BackgroundColor3 = theme.SURFACE_2
            tabData.ui.button.TextColor3 = theme.TEXT_SECONDARY
        end
        if tabData.feature.ApplyTheme then tabData.feature:ApplyTheme(theme) end
    end
end
function TabManagerFeature:UpdateZIndex(baseZ)
    self.uiElements.tabBar.ZIndex = baseZ + 1
    self.uiElements.tabContentContainer.ZIndex = baseZ
    for _, tabData in ipairs(self.tabs) do
        tabData.ui.button.ZIndex = baseZ + 2
        if tabData.feature.UpdateZIndex then tabData.feature:UpdateZIndex(baseZ)
        elseif tabData.feature.GetRootInstance then tabData.feature:GetRootInstance().ZIndex = baseZ
        end
    end
end
function TabManagerFeature:Destroy()
    for _, conn in pairs(self.connections) do conn:Disconnect() end
    for _, tabData in ipairs(self.tabs) do
        if tabData.feature.Destroy then tabData.feature:Destroy() end
        if tabData.ui.button then tabData.ui.button:Destroy() end
    end
    if self.uiElements.tabBar then self.uiElements.tabBar:Destroy() end
    if self.uiElements.tabContentContainer then self.uiElements.tabContentContainer:Destroy() end
end

-- Example Feature: ExecutorCore
local ExecutorCoreFeature = {}
ExecutorCoreFeature.__index = ExecutorCoreFeature
function ExecutorCoreFeature.new()
    local self = setmetatable({}, ExecutorCoreFeature)
    self.uiElements = {}
    self.connections = {}
    self.outputLines = {}
    self.maxOutputLines = 200
    self.currentScript = ""
    self.executeFunc = getfenv().loadstring or loadstring
    return self
end
function ExecutorCoreFeature:Initialize(window, parentFrame)
    self.window = window
    self.rootFrame = CreateInstance("Frame", {Name = "ExecutorCoreRoot", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=parentFrame})
    self.uiElements.rootFrame = self.rootFrame
    self:_createUI()
end
function ExecutorCoreFeature:GetRootInstance() return self.rootFrame end
function ExecutorCoreFeature:_createUI()
    local padding = CreateInstance("UIPadding", {PaddingTop=UDim.new(0,5), PaddingBottom=UDim.new(0,5), PaddingLeft=UDim.new(0,5), PaddingRight=UDim.new(0,5), Parent=self.rootFrame})
    local layout = CreateInstance("UIListLayout", {FillDirection=Enum.FillDirection.Vertical, Padding=UDim.new(0,5), Parent=self.rootFrame})

    self.uiElements.scriptInput = CreateInstance("TextBox", {
        Name = "ScriptInput", Size = UDim2.new(1,0,0.6,0), PlaceholderText = "-- Enter script here...", MultiLine = true, TextWrapped = true, ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = self.rootFrame
    })
    self.uiElements.scriptInputCorner = CreateInstance("UICorner", {Parent=self.uiElements.scriptInput})
    
    local buttonRow = CreateInstance("Frame", {Name="ButtonRow", Size=UDim2.new(1,0,0,30), BackgroundTransparency=1, Parent=self.rootFrame})
    local buttonRowLayout = CreateInstance("UIListLayout", {FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5), VerticalAlignment=Enum.VerticalAlignment.Center, Parent=buttonRow})
    self.uiElements.executeButton = CreateInstance("TextButton", {Name="Execute", Text="Execute", Size=UDim2.new(0,100,1,0), Parent=buttonRow})
    self.uiElements.clearInputButton = CreateInstance("TextButton", {Name="ClearInput", Text="Clear Input", Size=UDim2.new(0,100,1,0), Parent=buttonRow})
    self.uiElements.clearOutputButton = CreateInstance("TextButton", {Name="ClearOutput", Text="Clear Output", Size=UDim2.new(0,100,1,0), Parent=buttonRow})

    self.uiElements.outputScroll = CreateInstance("ScrollingFrame", {
        Name = "OutputScroll", Size = UDim2.new(1,0,0.4,-35), CanvasSize = UDim2.new(0,0,0,0), ScrollBarThickness=8, Parent = self.rootFrame
    })
    self.uiElements.outputScrollCorner = CreateInstance("UICorner", {Parent=self.uiElements.outputScroll})
    self.uiElements.outputList = CreateInstance("UIListLayout", {Padding = UDim.new(0,2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.uiElements.outputScroll})

    self.connections.Execute = self.uiElements.executeButton.MouseButton1Click:Connect(function() self:ExecuteScript(self.uiElements.scriptInput.Text) end)
    self.connections.ClearInput = self.uiElements.clearInputButton.MouseButton1Click:Connect(function() self.uiElements.scriptInput.Text = "" end)
    self.connections.ClearOutput = self.uiElements.clearOutputButton.MouseButton1Click:Connect(function() self:ClearOutput() end)
    self:AddOutput("Executor Initialized.", UI_GLOBALS.THEME.TEXT_SECONDARY)
end
function ExecutorCoreFeature:AddOutput(text, color)
    if #self.outputLines >= self.maxOutputLines then
        table.remove(self.outputLines, 1):Destroy()
    end
    local label = CreateInstance("TextLabel", {
        Name = "OutputLine", Text = tostring(text), TextColor3 = color or UI_GLOBALS.THEME.TEXT_PRIMARY,
        Font = UI_GLOBALS.THEME.FONT_CODE, TextSize = 12, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency=1,
        Size = UDim2.new(1, -5, 0,0), AutomaticSize = Enum.AutomaticSize.Y,
        Parent = self.uiElements.outputScroll
    })
    table.insert(self.outputLines, label)
    task.defer(function()
        if self.uiElements.outputScroll then self.uiElements.outputScroll.CanvasPosition = Vector2.new(0, self.uiElements.outputList.AbsoluteContentSize.Y) end
    end)
end
function ExecutorCoreFeature:ClearOutput()
    for _,line in ipairs(self.outputLines) do line:Destroy() end
    self.outputLines = {}
end
function ExecutorCoreFeature:ExecuteScript(scriptText)
    if not self.executeFunc then self:AddOutput("Error: loadstring not available.", UI_GLOBALS.THEME.ERROR); return end
    if not scriptText or scriptText:match("^%s*$") then self:AddOutput("Script is empty.", UI_GLOBALS.THEME.WARNING); return end
    self:AddOutput("Executing script...", UI_GLOBALS.THEME.ACCENT_SECONDARY)
    
    local oldPrint = print; local prints = {}
    local tempEnv = getfenv()
    tempEnv.print = function(...) local args={...}; local sArgs={}; for _,v in ipairs(args) do table.insert(sArgs,tostring(v)) end; table.insert(prints,table.concat(sArgs,"\t")); return oldPrint(...) end
    
    local success, result = pcall(function() return self.executeFunc(scriptText)() end)
    
    tempEnv.print = oldPrint 

    for _,pMsg in ipairs(prints) do self:AddOutput(" > " .. pMsg, UI_GLOBALS.THEME.TEXT_PRIMARY) end
    if success then
        self:AddOutput("Execution successful.", UI_GLOBALS.THEME.SUCCESS)
        if result ~= nil then self:AddOutput("Result: " .. tostring(result), UI_GLOBALS.THEME.SUCCESS) end
    else
        self:AddOutput("Execution Error: " .. tostring(result), UI_GLOBALS.THEME.ERROR)
    end
end
function ExecutorCoreFeature:ApplyTheme(theme)
    self.uiElements.scriptInput.Font = theme.FONT_CODE; self.uiElements.scriptInput.TextSize = 14
    self.uiElements.scriptInput.BackgroundColor3 = theme.INPUT_BACKGROUND; self.uiElements.scriptInput.TextColor3 = theme.TEXT_PRIMARY
    self.uiElements.scriptInput.PlaceholderColor3 = theme.TEXT_DISABLED
    self.uiElements.scriptInputCorner.CornerRadius = theme.CORNER_RADIUS_M
    
    for _, btnName in ipairs({"executeButton", "clearInputButton", "clearOutputButton"}) do
        local btn = self.uiElements[btnName]
        btn.BackgroundColor3 = theme.SURFACE_2; btn.TextColor3 = theme.TEXT_PRIMARY
        btn.Font = theme.FONT_PRIMARY; btn.TextSize = 14
        CreateInstance("UICorner", {CornerRadius=theme.CORNER_RADIUS_S, Parent=btn})
    end
    self.uiElements.executeButton.BackgroundColor3 = theme.ACCENT_PRIMARY
    self.uiElements.executeButton.TextColor3 = Color3.new(1,1,1)

    self.uiElements.outputScroll.BackgroundColor3 = theme.INPUT_BACKGROUND
    self.uiElements.outputScroll.ScrollBarImageColor3 = theme.ACCENT_SECONDARY
    self.uiElements.outputScrollCorner.CornerRadius = theme.CORNER_RADIUS_M
    for _,label in ipairs(self.outputLines) do if label.Name == "OutputLine" then label.Font = theme.FONT_CODE; label.TextColor3 = theme.TEXT_PRIMARY end end
end
function ExecutorCoreFeature:Activate() if self.uiElements.scriptInput then self.uiElements.scriptInput:CaptureFocus() end end
function ExecutorCoreFeature:Deactivate() if self.uiElements.scriptInput then self.uiElements.scriptInput:ReleaseFocus() end end
function ExecutorCoreFeature:Destroy()
    for _, conn in pairs(self.connections) do conn:Disconnect() end
    if self.rootFrame then self.rootFrame:Destroy() end
end

-- Placeholder Feature: Simple Text
local SimpleTextFeature = {}
SimpleTextFeature.__index = SimpleTextFeature
function SimpleTextFeature.new(text)
    local self = setmetatable({}, SimpleTextFeature)
    self.text = text or "Placeholder Content"
    return self
end
function SimpleTextFeature:Initialize(window, parentFrame)
    self.rootFrame = CreateInstance("Frame", {Name="SimpleTextRoot", Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Parent=parentFrame})
    self.label = CreateInstance("TextLabel", {
        Name="InfoLabel", Text=self.text, Size=UDim2.new(1,-20,1,-20), Position=UDim2.new(0,10,0,10),
        TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, TextYAlignment=Enum.TextYAlignment.Top,
        BackgroundTransparency=1, Parent=self.rootFrame
    })
end
function SimpleTextFeature:GetRootInstance() return self.rootFrame end
function SimpleTextFeature:ApplyTheme(theme)
    if self.label then self.label.Font=theme.FONT_PRIMARY; self.label.TextColor3=theme.TEXT_SECONDARY; self.label.TextSize=16 end
end
function SimpleTextFeature:Activate() end
function SimpleTextFeature:Deactivate() end
function SimpleTextFeature:Destroy() if self.rootFrame then self.rootFrame:Destroy() end end


-- Main UI Setup
task.spawn(function()
    local mainWindow = DraggableWindow.new({
        title = "Super Advanced Executor UI",
        size = UDim2.new(0, 800, 0, 600),
        minimizeButton = true,
        maximizeButton = true,
    })

    local tabManager = TabManagerFeature.new()
    mainWindow:AddFeature("TabManager", tabManager)

    local executorFeature = ExecutorCoreFeature.new()
    tabManager:AddTab("Executor", executorFeature)

    local scriptHubFeature = SimpleTextFeature.new("Script Hub Feature - Content coming soon!")
    tabManager:AddTab("Script Hub", scriptHubFeature)

    local settingsFeature = SimpleTextFeature.new("Settings Feature - Configuration options will appear here.")
    tabManager:AddTab("Settings", settingsFeature)
    
    -- Example of a second window
    -- local consoleWindow = DraggableWindow.new({
    -- title = "Mini Console",
    -- size = UDim2.new(0,450,0,300),
    -- position = UDim2.new(0.1,0,0.1,0)
    -- })
    -- local miniExec = ExecutorCoreFeature.new()
    -- consoleWindow:AddFeature("MiniExecutor", miniExec) -- This would directly add, no tabs
    -- if miniExec.Initialize then miniExec:Initialize(consoleWindow, consoleWindow.contentFrame) end
    -- if miniExec.GetRootInstance then miniExec:GetRootInstance().Parent = consoleWindow.contentFrame end

end)


-- For cleanup on script removal in some environments
-- if script and script.Destroying then
-- script.Destroying:Connect(function()
-- for _, window in pairs(UI_GLOBALS.WINDOWS) do
-- if window.Close then window:Close() end
-- end
-- UI_GLOBALS.EVENT_BUS:Destroy()
-- end)
-- end

return UI_GLOBALS -- For potential external control if run as a module
