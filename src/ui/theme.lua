local Theme = {
    GlassColor        = Color3.fromRGB(232, 230, 255),
    GlassDecor        = Color3.fromRGB(255, 239, 255),
    AccentPink        = Color3.fromRGB(244, 189, 255),
    AccentBlue        = Color3.fromRGB(190, 225, 255),
    AccentWhite       = Color3.fromRGB(235, 235, 240),
    MonoChrome        = Color3.fromRGB(215, 215, 215),
    Neon              = Color3.fromRGB(255, 174, 255),
    GlassTransparency = 0.22,
}

function Theme:ApplyUICorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 12)
    corner.Parent = instance
end

function Theme:ApplyOutline(instance, color)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or self.Neon
    stroke.Thickness = 2
    stroke.Parent = instance
end

return Theme
