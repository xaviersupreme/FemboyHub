---------------------------------------------------------------------
-- UTILITIES: error handling, tween, color helpers, etc.
---------------------------------------------------------------------
local TweenService = game:GetService("TweenService") or {};

local Util = {}
function Util.Error(msg) print("FemboyHub ERROR: "..tostring(msg)) end
function Util.Warn(msg) print("FemboyHub WARN: "..tostring(msg)) end
function Util.Tween(obj, props, duration, style, direction, cb)
    local t; if TweenService and TweenService.Create then
        t = TweenService:Create(obj, TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), props)
        t.Completed:Connect(function() if cb then cb() end end)
        t:Play()
    else
        for k,v in pairs(props) do pcall(function() obj[k]=v end) end
        if cb then cb() end
    end
    return t
end
function Util.ColorLerp(c1, c2, t)
    return Color3.new(c1.R+(c2.R-c1.R)*t, c1.G+(c2.G-c1.G)*t, c1.B+(c2.B-c1.B)*t)
end
function Util.Clamp(v,min,max) return (v<min) and min or ((v>max) and max or v) end
function Util.DeepCopy(tbl)
    local r = {}; for k,v in pairs(tbl) do r[k]=type(v)=="table" and Util.DeepCopy(v) or v end; return r
end
function Util.SerializeColor(c) return {r=c.R,g=c.G,b=c.B} end
function Util.DeserializeColor(t) return typeof(t)=="Color3" and t or Color3.new(t.r or 0, t.g or 0, t.b or 0) end
function Util.SerializeKeycode(kc) return typeof(kc)=="EnumItem" and kc.Name or kc end
function Util.DeserializeKeycode(s) return (typeof(s)=="EnumItem" and s) or (Enum.KeyCode[s] or Enum.KeyCode.Unknown) end
Util.JSON = game:GetService("HttpService")

---------------------------------------------------------------------
-- SETTINGS, PROFILES, PERSISTENCE
---------------------------------------------------------------------
local SETTINGS_PATH = "workspace/FemboyHubSettings.json"
local default_settings = {
    aimbot_enabled=false, aimbot_hold=true, aimbot_key=Enum.KeyCode.LeftAlt, aimbot_fov_enabled=true,
    aimbot_fov_radius=95, aimbot_fov_thickness=2, aimbot_fov_color=Color3.fromRGB(244,189,255), aimbot_fov_transparency=0.16, aimbot_fov_filled=false,
    aimbot_target="Head", aimbot_smoothing=0, aimbot_prediction=false, aimbot_silent=false, aimbot_ignore_list={},
    esp_enabled=true, esp_box=true, esp_box_color=Color3.fromRGB(190,225,255), esp_box_thickness=2, esp_box_fill=false, esp_box_filltrans=0.6,
    esp_line=false, esp_line_color=Color3.fromRGB(255,174,255), esp_line_thickness=1,
    esp_name=true, esp_name_color=Color3.fromRGB(244,189,255), esp_name_size=14,
    esp_distance=true, esp_distance_color=Color3.fromRGB(127,255,127), esp_distance_size=13,
    esp_max_distance=2500, esp_team_check=false, esp_key=Enum.KeyCode.E,
    esp_offscreen=true, esp_healthbar=true, esp_tracers=true, esp_tracer_color=Color3.fromRGB(255,127,255),
    visuals_theme="Glass", visuals_fullbright=false, visuals_fog=false, visuals_customtitle="femboy hub",
    movement_fly=false, movement_fly_key=Enum.KeyCode.F, movement_noclip=false, movement_noclip_key=Enum.KeyCode.N,
    movement_speed=false, movement_speed_key=Enum.KeyCode.LeftShift, movement_speed_value=48,
    movement_infjump=false, movement_infjump_key=Enum.KeyCode.Space,
    combat_triggerbot=false, combat_triggerbot_key=Enum.KeyCode.Q,
    camera_fov=70, camera_fov_min=30, camera_fov_max=120, camera_fov_step=1, camera_freecam=false, camera_freecam_key=Enum.KeyCode.V,
    profiles={},
    current_profile="default"
}
local settings = Util.DeepCopy(default_settings)

local function saveSettings()
    local to_save = {}
    for k,v in pairs(settings) do
        if typeof(v)=="Color3" then to_save[k]=Util.SerializeColor(v)
        elseif typeof(v)=="EnumItem" and v.EnumType==Enum.KeyCode then to_save[k]=v.Name
        elseif type(v)=="table" then
            if k=="aimbot_ignore_list" or k=="profiles" then to_save[k]=v else to_save[k]=v end
        else to_save[k]=v end
    end
    pcall(function()
        if writefile then writefile(SETTINGS_PATH, Util.JSON:JSONEncode(to_save)) end
    end)
end
local function loadSettings()
    if isfile and isfile(SETTINGS_PATH) then
        local ok,dat=pcall(function() return readfile(SETTINGS_PATH) end)
        if ok and dat then
            local ok2,js=pcall(function() return Util.JSON:JSONDecode(dat) end)
            if ok2 and js then
                for k,v in pairs(js) do
                    if k:find("_color") then settings[k]=Util.DeserializeColor(v)
                    elseif k:find("_key") then settings[k]=Util.DeserializeKeycode(v)
                    elseif k=="aimbot_ignore_list" or k=="profiles" then settings[k]=v
                    else settings[k]=v end
                end
            end
        end
    end
end
loadSettings()

local function switchProfile(name)
    if settings.profiles and settings.profiles[name] then
        for k,_ in pairs(settings) do if k~="profiles" then settings[k]=nil end end
        for k,v in pairs(settings.profiles[name]) do settings[k]=v end
        settings.current_profile=name
        saveSettings()
    end
end

local function saveProfile(name)
    settings.profiles = settings.profiles or {}
    local prof = {}
    for k,v in pairs(settings) do
        if k~="profiles" and k~="current_profile" then prof[k]=v end
    end
    settings.profiles[name]=prof
    settings.current_profile=name
    saveSettings()
end

local function exportProfile(name)
    if settings.profiles and settings.profiles[name] then
        return Util.JSON:JSONEncode(settings.profiles[name])
    end
end

local function importProfile(name, jsonStr)
    local ok, tbl = pcall(function() return Util.JSON:JSONDecode(jsonStr) end)
    if ok and type(tbl)=="table" then
        settings.profiles[name]=tbl
        saveSettings()
        return true
    end
    return false
end

---------------------------------------------------------------------
-- UI FRAMEWORK
---------------------------------------------------------------------
local players = game:GetService("Players")
local localplayer = players.LocalPlayer
local userinput = game:GetService("UserInputService")
local runservice = game:GetService("RunService")
local camera = workspace.CurrentCamera

local function themeColor()
    return settings.visuals_theme=="Glass" and Color3.fromRGB(232,230,255) or Color3.fromRGB(255,174,255)
end
local function accentColor()
    return settings.visuals_theme=="Glass" and Color3.fromRGB(244,189,255) or Color3.fromRGB(255,174,255)
end

local gui=Instance.new("ScreenGui",localplayer.PlayerGui)
gui.Name="FemboyHubProUI"
local main=Instance.new("Frame",gui)
main.Size=UDim2.new(0,700,0,700);main.Position=UDim2.new(0.5,-350,0.5,-350)
main.BackgroundTransparency=0.22;main.BackgroundColor3=themeColor();main.BorderSizePixel=0
Instance.new("UICorner",main).CornerRadius=UDim.new(0,40)
local header=Instance.new("Frame",main);header.Size=UDim2.new(1,0,0,68);header.BackgroundColor3=accentColor();header.BackgroundTransparency=0.11;header.BorderSizePixel=0
Instance.new("UICorner",header).CornerRadius=UDim.new(0,40)
local title=Instance.new("TextLabel",header)
title.Text=settings.visuals_customtitle;title.Font=Enum.Font.GothamBlack;title.TextColor3=Color3.fromRGB(190,225,255);title.TextSize=44;title.AnchorPoint=Vector2.new(0,0.5);title.Position=UDim2.new(0.05,0,0.5,0);title.Size=UDim2.new(0.7,0,1,0);title.BackgroundTransparency=1;title.TextXAlignment=Enum.TextXAlignment.Left

local tabnames={"Aimbot","ESP","Visuals","Movement","Combat","Camera","Profiles","Settings"}
local tabframes, tabbtns = {},{}
local tabbar=Instance.new("Frame",main);tabbar.Position=UDim2.new(0,0,0,68);tabbar.Size=UDim2.new(1,0,0,52);tabbar.BackgroundTransparency=1
local tablayout=Instance.new("UIListLayout",tabbar);tablayout.FillDirection=Enum.FillDirection.Horizontal;tablayout.HorizontalAlignment=Enum.HorizontalAlignment.Center;tablayout.Padding=UDim.new(0,12)
for i,tabn in ipairs(tabnames) do
    local btn=Instance.new("TextButton");btn.Name=tabn;btn.Text=tabn;btn.Font=Enum.Font.GothamMedium
    btn.TextColor3=(i%2==0)and accentColor() or Color3.fromRGB(190,225,255);btn.TextSize=22
    btn.Size=UDim2.new(0,math.floor(660/#tabnames),0,38)
    btn.BackgroundColor3=Color3.fromRGB(215,215,215);btn.BackgroundTransparency=0.82
    btn.AutoButtonColor=false;btn.ZIndex=4;btn.Parent=tabbar
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,24);tabbtns[tabn]=btn
end
local contentframe=Instance.new("Frame",main)
contentframe.Position=UDim2.new(0,0,0,120);contentframe.Size=UDim2.new(1,0,1,-120)
contentframe.BackgroundColor3=themeColor();contentframe.BackgroundTransparency=0.64;contentframe.BorderSizePixel=0;contentframe.ClipsDescendants=true
Instance.new("UICorner",contentframe).CornerRadius=UDim.new(0,36)
for _,tabn in ipairs(tabnames) do
    local f=Instance.new("Frame",contentframe);f.Visible=false;f.Size=UDim2.new(1,-32,1,-32);f.Position=UDim2.new(0,16,0,16);f.BackgroundTransparency=1;tabframes[tabn]=f
end

---------------------------------------------------------------------
-- UI CONTROLS (toggle, slider, colorpicker, keybindpicker, dropdown)
---------------------------------------------------------------------
local function keybindPicker(parent,label,getValue,setValue)
    local picking=false
    local btn=Instance.new("TextButton")
    btn.Text=label..": ["..getValue().Name.."]"
    btn.Size=UDim2.new(0,130,0,32)
    btn.Font=Enum.Font.GothamBold
    btn.TextColor3=Color3.fromRGB(190,225,255)
    btn.BackgroundColor3=Color3.fromRGB(245,245,255)
    btn.BackgroundTransparency=0.18
    btn.Parent=parent
    btn.MouseButton1Click:Connect(function() btn.Text=label..": [Press any key]"; picking=true end)
    userinput.InputBegan:Connect(function(input)
        if picking and input.UserInputType==Enum.UserInputType.Keyboard then
            setValue(input.KeyCode); btn.Text=label..": ["..input.KeyCode.Name.."]"; picking=false; saveSettings()
        end
    end)
    return btn
end
local function colorPicker(parent,label,getValue,setValue,presets)
    local idx=1; local btn=Instance.new("TextButton")
    btn.Text=label; btn.Size=UDim2.new(0,70,0,32); btn.Font=Enum.Font.Gotham; btn.TextColor3=getValue()
    btn.BackgroundColor3=Color3.fromRGB(32,32,32); btn.BackgroundTransparency=0.34; btn.Parent=parent
    btn.MouseButton1Click:Connect(function()
        idx=idx%#presets+1; local col=presets[idx]; setValue(col); btn.TextColor3=col; saveSettings()
    end) return btn
end
local function slider(parent,label,min,max,getValue,setValue)
    local frame=Instance.new("Frame");frame.Size=UDim2.new(0,240,0,48);frame.BackgroundTransparency=1;frame.Parent=parent
    local txt=Instance.new("TextLabel");txt.Text=label..": "..getValue();txt.Font=Enum.Font.Gotham;txt.TextSize=16;txt.TextColor3=Color3.fromRGB(170,170,220);txt.BackgroundTransparency=1;txt.Size=UDim2.new(1,0,0,20);txt.Parent=frame
    local sld=Instance.new("Frame");sld.Size=UDim2.new(0,180,0,5);sld.Position=UDim2.new(0,0,0,28);sld.BackgroundColor3=Color3.fromRGB(230,230,255);sld.Parent=frame
    local knob=Instance.new("Frame");knob.Size=UDim2.new(0,12,0,20);knob.Position=UDim2.new((getValue()-min)/(max-min),-6,0,-8);knob.BackgroundColor3=Color3.fromRGB(190,225,255);knob.Parent=sld
    local dragging=false
    knob.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end end)
    userinput.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    userinput.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local x=math.clamp((input.Position.X-sld.AbsolutePosition.X)/sld.AbsoluteSize.X,0,1)
            local val=math.floor(min+x*(max-min)); setValue(val); txt.Text=label..": "..val; knob.Position=UDim2.new(x,-6,0,-8); saveSettings()
        end
    end) return frame
end
local function dropdown(parent,label,options,getValue,setValue)
    local btn=Instance.new("TextButton");btn.Text=label..": ["..getValue().."]";btn.Size=UDim2.new(0,120,0,32)
    btn.Font=Enum.Font.Gotham;btn.TextColor3=Color3.fromRGB(200,200,255);btn.BackgroundColor3=Color3.fromRGB(44,44,54);btn.BackgroundTransparency=0.28;btn.Parent=parent
    local idx=table.find(options,getValue())or 1;btn.MouseButton1Click:Connect(function() idx=idx%#options+1;setValue(options[idx]);btn.Text=label..": ["..options[idx].."]";saveSettings() end)
    return btn
end
local function toggle(parent,label,getValue,setValue)
    local btn=Instance.new("TextButton")
    btn.Text=label..": "..(getValue()and"ON"or"OFF")
    btn.Size=UDim2.new(0,90,0,32)
    btn.Font=Enum.Font.GothamBold
    btn.TextColor3=getValue()and Color3.fromRGB(80,255,100)or Color3.fromRGB(80,120,255)
    btn.BackgroundColor3=Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency=0.11
    btn.Parent=parent
    btn.MouseButton1Click:Connect(function() setValue(not getValue());btn.Text=label..": "..(getValue()and"ON"or"OFF");btn.TextColor3=getValue()and Color3.fromRGB(80,255,100)or Color3.fromRGB(80,120,255);saveSettings() end)
    return btn
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TABS: aimbot, ESP, visuals, movement, combat, camera, profiles, settings (i lowkey should have put the aimbot into combat and esp into visuals but whatever)
---------------------------------------------------------------------------------------------------------------------------------------------------------------

do -- aimbot
    local tab=tabframes["Aimbot"]
    local y=0
    toggle(tab,"Enabled",function()return settings.aimbot_enabled end,function(v)settings.aimbot_enabled=v end).Position=UDim2.new(0,8,0,y)
    toggle(tab,"Hold",function()return settings.aimbot_hold end,function(v)settings.aimbot_hold=v end).Position=UDim2.new(0,110,0,y)
    keybindPicker(tab,"Key",function()return settings.aimbot_key end,function(v)settings.aimbot_key=v end).Position=UDim2.new(0,220,0,y)
    y=y+36
    toggle(tab,"FOV Draw",function()return settings.aimbot_fov_enabled end,function(v)settings.aimbot_fov_enabled=v end).Position=UDim2.new(0,8,0,y)
    slider(tab,"FOV Radius",30,300,function()return settings.aimbot_fov_radius end,function(v)settings.aimbot_fov_radius=v end).Position=UDim2.new(0,110,0,y)
    slider(tab,"FOV Thickness",1,8,function()return settings.aimbot_fov_thickness end,function(v)settings.aimbot_fov_thickness=v end).Position=UDim2.new(0,350,0,y)
    colorPicker(tab,"FOV",function()return settings.aimbot_fov_color end,function(v)settings.aimbot_fov_color=v end,{Color3.fromRGB(244,189,255),Color3.fromRGB(190,225,255),Color3.fromRGB(127,255,127)}).Position=UDim2.new(0,8,0,y+44)
    toggle(tab,"FOV Fill",function()return settings.aimbot_fov_filled end,function(v)settings.aimbot_fov_filled=v end).Position=UDim2.new(0,200,0,y+44)
    slider(tab,"Smoothing",0,10,function()return settings.aimbot_smoothing end,function(v)settings.aimbot_smoothing=v end).Position=UDim2.new(0,320,0,y+44)
    dropdown(tab,"Target",{"Head","Torso","HumanoidRootPart"},function()return settings.aimbot_target end,function(v)settings.aimbot_target=v end).Position=UDim2.new(0,8,0,y+88)
    toggle(tab,"Prediction",function()return settings.aimbot_prediction end,function(v)settings.aimbot_prediction=v end).Position=UDim2.new(0,180,0,y+88)
    toggle(tab,"SilentAim",function()return settings.aimbot_silent end,function(v)settings.aimbot_silent=v end).Position=UDim2.new(0,320,0,y+88)
end

do -- ESP
    local tab=tabframes["ESP"]
    local y=0
    toggle(tab,"Enabled",function() return settings.esp_enabled end,function(v)settings.esp_enabled=v end).Position=UDim2.new(0,8,0,y)
    keybindPicker(tab,"Key",function() return settings.esp_key end,function(v)settings.esp_key=v end).Position=UDim2.new(0,110,0,y)
    y=y+36
    toggle(tab,"Box",function() return settings.esp_box end,function(v)settings.esp_box=v end).Position=UDim2.new(0,8,0,y)
    colorPicker(tab,"BoxCol",function() return settings.esp_box_color end,function(v)settings.esp_box_color=v end,{Color3.fromRGB(190,225,255),Color3.fromRGB(255,174,255),Color3.fromRGB(244,189,255)}).Position=UDim2.new(0,110,0,y)
    slider(tab,"BoxThick",1,5,function() return settings.esp_box_thickness end,function(v)settings.esp_box_thickness=v end).Position=UDim2.new(0,210,0,y)
    toggle(tab,"BoxFill",function() return settings.esp_box_fill end,function(v)settings.esp_box_fill=v end).Position=UDim2.new(0,320,0,y)
    toggle(tab,"Tracers",function() return settings.esp_tracers end,function(v)settings.esp_tracers=v end).Position=UDim2.new(0,420,0,y)
    colorPicker(tab,"TracerCol",function() return settings.esp_tracer_color end,function(v)settings.esp_tracer_color=v end,{Color3.fromRGB(255,127,255),Color3.fromRGB(127,255,127)}).Position=UDim2.new(0,520,0,y)
    y=y+44
    toggle(tab,"Line",function() return settings.esp_line end,function(v)settings.esp_line=v end).Position=UDim2.new(0,8,0,y)
    colorPicker(tab,"LineCol",function() return settings.esp_line_color end,function(v)settings.esp_line_color=v end,{Color3.fromRGB(255,174,255),Color3.fromRGB(190,225,255)}).Position=UDim2.new(0,110,0,y)
    slider(tab,"LineThick",1,5,function() return settings.esp_line_thickness end,function(v)settings.esp_line_thickness=v end).Position=UDim2.new(0,210,0,y)
    y=y+44
    toggle(tab,"Names",function() return settings.esp_name end,function(v)settings.esp_name=v end).Position=UDim2.new(0,8,0,y)
    colorPicker(tab,"NameCol",function() return settings.esp_name_color end,function(v)settings.esp_name_color=v end,{Color3.fromRGB(244,189,255),Color3.fromRGB(127,255,127)}).Position=UDim2.new(0,110,0,y)
    slider(tab,"NameSize",10,20,function() return settings.esp_name_size end,function(v)settings.esp_name_size=v end).Position=UDim2.new(0,210,0,y)
    y=y+44
    toggle(tab,"Dist",function() return settings.esp_distance end,function(v)settings.esp_distance=v end).Position=UDim2.new(0,8,0,y)
    colorPicker(tab,"DistCol",function() return settings.esp_distance_color end,function(v)settings.esp_distance_color=v end,{Color3.fromRGB(127,255,127),Color3.fromRGB(244,189,255)}).Position=UDim2.new(0,110,0,y)
    slider(tab,"DistSize",10,20,function() return settings.esp_distance_size end,function(v)settings.esp_distance_size=v end).Position=UDim2.new(0,210,0,y)
    y=y+44
    slider(tab,"MaxDist",500,5000,function() return settings.esp_max_distance end,function(v)settings.esp_max_distance=v end).Position=UDim2.new(0,8,0,y)
    toggle(tab,"TeamCheck",function() return settings.esp_team_check end,function(v)settings.esp_team_check=v end).Position=UDim2.new(0,220,0,y)
    toggle(tab,"Offscreen",function() return settings.esp_offscreen end,function(v)settings.esp_offscreen=v end).Position=UDim2.new(0,320,0,y)
    toggle(tab,"Healthbar",function() return settings.esp_healthbar end,function(v)settings.esp_healthbar=v end).Position=UDim2.new(0,420,0,y)
end

do -- visuals
    local tab=tabframes["Visuals"]
    local y=0
    toggle(tab,"Fullbright",function()return settings.visuals_fullbright end,function(v)settings.visuals_fullbright=v end).Position=UDim2.new(0,8,0,y)
    toggle(tab,"Fog Remove",function()return settings.visuals_fog end,function(v)settings.visuals_fog=v end).Position=UDim2.new(0,120,0,y)
    dropdown(tab,"Theme",{"Glass","Neon","Dark","Light"},function()return settings.visuals_theme end,function(v)settings.visuals_theme=v end).Position=UDim2.new(0,8,0,y+44)
    local box = Instance.new("TextBox",tab)
    box.Text = settings.visuals_customtitle or "femboy hub"
    box.Size = UDim2.new(0,260,0,38)
    box.Position = UDim2.new(0,8,0,88)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 20
    box.BackgroundColor3 = Color3.fromRGB(235,235,240)
    box.BackgroundTransparency = 0.14
    box.TextColor3 = Color3.fromRGB(190,225,255)
    Instance.new("UICorner",box).CornerRadius = UDim.new(0,16)
    box.FocusLost:Connect(function()
        settings.visuals_customtitle = box.Text
        saveSettings()
    end)
end

do -- movement
    local tab=tabframes["Movement"]
    local y=0
    toggle(tab,"Fly",function()return settings.movement_fly end,function(v)settings.movement_fly=v end).Position=UDim2.new(0,8,0,y)
    keybindPicker(tab,"Fly Key",function()return settings.movement_fly_key end,function(v)settings.movement_fly_key=v end).Position=UDim2.new(0,110,0,y)
    toggle(tab,"Noclip",function()return settings.movement_noclip end,function(v)settings.movement_noclip=v end).Position=UDim2.new(0,270,0,y)
    keybindPicker(tab,"Noclip Key",function()return settings.movement_noclip_key end,function(v)settings.movement_noclip_key=v end).Position=UDim2.new(0,370,0,y)
    y=y+44
    toggle(tab,"Speedhack",function()return settings.movement_speed end,function(v)settings.movement_speed=v end).Position=UDim2.new(0,8,0,y)
    slider(tab,"Speed",16,200,function()return settings.movement_speed_value end,function(v)settings.movement_speed_value=v end).Position=UDim2.new(0,110,0,y)
    keybindPicker(tab,"Speed Key",function()return settings.movement_speed_key end,function(v)settings.movement_speed_key=v end).Position=UDim2.new(0,370,0,y)
    y=y+44
    toggle(tab,"Inf Jump",function()return settings.movement_infjump end,function(v)settings.movement_infjump=v end).Position=UDim2.new(0,8,0,y)
    keybindPicker(tab,"InfJump Key",function()return settings.movement_infjump_key end,function(v)settings.movement_infjump_key=v end).Position=UDim2.new(0,110,0,y)
end

do -- combat
    local tab=tabframes["Combat"]
    local y=0
    toggle(tab,"Triggerbot",function()return settings.combat_triggerbot end,function(v)settings.combat_triggerbot=v end).Position=UDim2.new(0,8,0,y)
    keybindPicker(tab,"Triggerbot Key",function()return settings.combat_triggerbot_key end,function(v)settings.combat_triggerbot_key=v end).Position=UDim2.new(0,110,0,y)
end

do -- camera
    local tab=tabframes["Camera"]
    local y=0
    slider(tab,"FOV",settings.camera_fov_min,settings.camera_fov_max,function()return settings.camera_fov end,function(v)settings.camera_fov=v end).Position=UDim2.new(0,8,0,y)
    toggle(tab,"Freecam",function()return settings.camera_freecam end,function(v)settings.camera_freecam=v end).Position=UDim2.new(0,260,0,y)
    keybindPicker(tab,"Freecam Key",function()return settings.camera_freecam_key end,function(v)settings.camera_freecam_key=v end).Position=UDim2.new(0,370,0,y)
end

do -- profiles
    local tab=tabframes["Profiles"]
    local y=0
    local list = Instance.new("ScrollingFrame",tab)
    list.Position=UDim2.new(0,8,0,y)
    list.Size=UDim2.new(0,380,0,180)
    list.CanvasSize=UDim2.new(0,0,0,400)
    list.BackgroundTransparency=0.14
    list.BackgroundColor3=Color3.fromRGB(235,235,240)
    Instance.new("UICorner",list).CornerRadius=UDim.new(0,16)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local function updateList()
        list:ClearAllChildren()
        local n=0
        for name,_ in pairs(settings.profiles or {}) do
            n=n+1
            local btn=Instance.new("TextButton",list)
            btn.Size=UDim2.new(1,0,0,32)
            btn.Position=UDim2.new(0,0,0,(n-1)*36)
            btn.Text=name..(settings.current_profile==name and " [ACTIVE]" or "")
            btn.Font=Enum.Font.Gotham
            btn.TextSize=18
            btn.BackgroundColor3=settings.current_profile==name and Color3.fromRGB(255,200,255) or Color3.fromRGB(245,245,255)
            btn.BackgroundTransparency=0.1
            btn.MouseButton1Click:Connect(function() switchProfile(name); updateList() end)
        end
    end
    updateList()
    local box = Instance.new("TextBox",tab)
    box.Text = "new_profile"
    box.Size = UDim2.new(0,180,0,38)
    box.Position = UDim2.new(0,8,0,190)
    box.Font = Enum.Font.GothamBold
    box.TextSize = 20
    box.BackgroundColor3 = Color3.fromRGB(235,235,240)
    box.BackgroundTransparency = 0.14
    box.TextColor3 = Color3.fromRGB(190,225,255)
    Instance.new("UICorner",box).CornerRadius = UDim.new(0,16)
    local saveBtn=Instance.new("TextButton",tab)
    saveBtn.Text="Save Profile"
    saveBtn.Size=UDim2.new(0,120,0,32)
    saveBtn.Position=UDim2.new(0,200,0,190)
    saveBtn.Font=Enum.Font.GothamBold
    saveBtn.TextSize=18
    saveBtn.BackgroundColor3=Color3.fromRGB(180,255,200)
    saveBtn.MouseButton1Click:Connect(function() saveProfile(box.Text); updateList() end)
    local exportBtn=Instance.new("TextButton",tab)
    exportBtn.Text="Export"
    exportBtn.Size=UDim2.new(0,80,0,32)
    exportBtn.Position=UDim2.new(0,8,0,232)
    exportBtn.Font=Enum.Font.GothamBold
    exportBtn.TextSize=18
    exportBtn.BackgroundColor3=Color3.fromRGB(190,225,255)
    exportBtn.MouseButton1Click:Connect(function()
        setclipboard(exportProfile(settings.current_profile) or "")
    end)
    local importBtn=Instance.new("TextButton",tab)
    importBtn.Text="Import"
    importBtn.Size=UDim2.new(0,80,0,32)
    importBtn.Position=UDim2.new(0,100,0,232)
    importBtn.Font=Enum.Font.GothamBold
    importBtn.TextSize=18
    importBtn.BackgroundColor3=Color3.fromRGB(244,189,255)
    importBtn.MouseButton1Click:Connect(function()
        local ok = importProfile(box.Text, tostring(box.Text))
        if ok then updateList() end
    end)
end

do -- settings
    local tab=tabframes["Settings"]
    local y=0
    local wipeBtn=Instance.new("TextButton",tab)
    wipeBtn.Text="Reset All Settings"
    wipeBtn.Size=UDim2.new(0,200,0,38)
    wipeBtn.Position=UDim2.new(0,8,0,y)
    wipeBtn.Font=Enum.Font.GothamBold
    wipeBtn.TextSize=18
    wipeBtn.BackgroundColor3=Color3.fromRGB(255,100,120)
    wipeBtn.BackgroundTransparency=0.13
    wipeBtn.TextColor3=Color3.fromRGB(255,255,255)
    Instance.new("UICorner",wipeBtn).CornerRadius=UDim.new(0,12)
    wipeBtn.MouseButton1Click:Connect(function()
        for k,v in pairs(default_settings) do settings[k]=Util.DeepCopy(v) end
        saveSettings()
    end)
    y=y+44
    local reloadBtn=Instance.new("TextButton",tab)
    reloadBtn.Text="Reload Settings"
    reloadBtn.Size=UDim2.new(0,200,0,38)
    reloadBtn.Position=UDim2.new(0,8,0,y)
    reloadBtn.Font=Enum.Font.GothamBold
    reloadBtn.TextSize=18
    reloadBtn.BackgroundColor3=Color3.fromRGB(100,200,255)
    reloadBtn.BackgroundTransparency=0.13
    reloadBtn.TextColor3=Color3.fromRGB(255,255,255)
    Instance.new("UICorner",reloadBtn).CornerRadius=UDim.new(0,12)
    reloadBtn.MouseButton1Click:Connect(function()
        loadSettings()
    end)
    y=y+44
    local copyBtn=Instance.new("TextButton",tab)
    copyBtn.Text="Copy All Settings (JSON)"
    copyBtn.Size=UDim2.new(0,260,0,38)
    copyBtn.Position=UDim2.new(0,8,0,y)
    copyBtn.Font=Enum.Font.GothamBold
    copyBtn.TextSize=18
    copyBtn.BackgroundColor3=Color3.fromRGB(200,255,200)
    copyBtn.BackgroundTransparency=0.13
    copyBtn.TextColor3=Color3.fromRGB(90,120,90)
    Instance.new("UICorner",copyBtn).CornerRadius=UDim.new(0,12)
    copyBtn.MouseButton1Click:Connect(function()
        setclipboard(Util.JSON:JSONEncode(settings))
    end)
end

---------------------------------------------------------------------
-- TAB SWITCHING & DRAGGING
---------------------------------------------------------------------
local function switchTab(tabn)
    for name,frame in pairs(tabframes) do frame.Visible=(name==tabn) end
    for name,btn in pairs(tabbtns) do
        btn.BackgroundTransparency=(name==tabn)and 0.38 or 0.82
        btn.TextColor3=(name==tabn)and Color3.fromRGB(255,174,255)or((table.find(tabnames,name)%2==0)and accentColor()or Color3.fromRGB(190,225,255))
    end
end
for name,btn in pairs(tabbtns) do btn.MouseButton1Click:Connect(function()switchTab(name)end) end
switchTab("Aimbot")

local dragging,draginput,dragstart,startpos,velocity,lastupdate=false,nil,nil,nil,Vector2.new(0,0),tick()
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true;dragstart=input.Position;startpos=main.Position;velocity=Vector2.new(0,0);lastupdate=tick()
        input.Changed:Connect(function()if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
header.InputChanged:Connect(function(input)if input.UserInputType==Enum.UserInputType.MouseMovement then draginput=input end end)
userinput.InputChanged:Connect(function(input)
    if input==draginput and dragging then
        local delta=input.Position-dragstart;local dt=math.max(tick()-lastupdate,0.01)
        velocity=velocity:Lerp(Vector2.new(delta.X/dt,delta.Y/dt),0.2)
        main.Position=startpos+UDim2.new(0,delta.X,0,delta.Y);lastupdate=tick()
    end
end)
runservice.RenderStepped:Connect(function(dt)
    if not dragging and(math.abs(velocity.X)>1 or math.abs(velocity.Y)>1)then
        main.Position=main.Position+UDim2.new(0,velocity.X*dt,0,velocity.Y*dt);velocity=velocity*0.88
    end
end)

---------------------------------------------------------------------
-- MAIN LOGIC LOOPS (ESP, AIMBOT, MOVEMENT, CAMERA, VISUALS, ETC)
---------------------------------------------------------------------
local Drawing = (Drawing or getgenv().Drawing)
if not Drawing then Util.Error("Drawing API not found. ESP, FOV visuals disabled.") end

-- ESP
local esp_objects = {}
function clear_esp() for _,obj in ipairs(esp_objects)do pcall(function() if obj and obj.Remove then obj:Remove() end end) end esp_objects={} end
function render_esp()
    clear_esp(); if not Drawing or not settings.esp_enabled then return end
    for _,player in ipairs(players:GetPlayers())do
        pcall(function()
            if player~=localplayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid")and player.Character.Humanoid.Health>0 then
                if settings.esp_team_check and player.Team==localplayer.Team then return end
                local hrp=player.Character.HumanoidRootPart
                local pos,onscreen=camera:WorldToViewportPoint(hrp.Position)
                local dist=(hrp.Position-camera.CFrame.Position).Magnitude
                if onscreen and dist<=settings.esp_max_distance then
                    if settings.esp_box then local obj=Drawing.new("Square")
                        obj.Visible=true;obj.Color=settings.esp_box_color;obj.Thickness=settings.esp_box_thickness
                        obj.Filled=settings.esp_box_fill;obj.Transparency=1-(settings.esp_box_fill and settings.esp_box_filltrans or 0)
                        obj.Size=Vector2.new(48,96);obj.Position=Vector2.new(pos.X-24,pos.Y-48);table.insert(esp_objects,obj) end
                    if settings.esp_healthbar and player.Character:FindFirstChild("Humanoid") then
                        local hum=player.Character.Humanoid; local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
                        local bar=Drawing.new("Line")
                        bar.From=Vector2.new(pos.X-30,pos.Y-48)
                        bar.To=Vector2.new(pos.X-30,pos.Y-48+96*pct)
                        bar.Color=Color3.fromRGB(0,255,0):Lerp(Color3.fromRGB(255,0,0),1-pct)
                        bar.Thickness=4; bar.Visible=true; table.insert(esp_objects,bar)
                    end
                    if settings.esp_tracers then
                        local obj=Drawing.new("Line")
                        obj.From=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y)
                        obj.To=Vector2.new(pos.X,pos.Y+48);obj.Color=settings.esp_tracer_color;obj.Thickness=2;obj.Visible=true;table.insert(esp_objects,obj)
                    end
                    if settings.esp_name then local obj=Drawing.new("Text")
                        obj.Visible=true;obj.Center=true;obj.Outline=true;obj.Size=settings.esp_name_size;obj.Text=player.Name;obj.Color=settings.esp_name_color
                        obj.Position=Vector2.new(pos.X,pos.Y-54);table.insert(esp_objects,obj) end
                    if settings.esp_distance then local obj=Drawing.new("Text")
                        obj.Visible=true;obj.Center=true;obj.Outline=true;obj.Size=settings.esp_distance_size;obj.Text=tostring(math.floor(dist)).."m";obj.Color=settings.esp_distance_color
                        obj.Position=Vector2.new(pos.X,pos.Y+54);table.insert(esp_objects,obj) end
                elseif settings.esp_offscreen then
                    local v2 = Vector2.new(pos.X,pos.Y)
                    local cx,cy = camera.ViewportSize.X/2,camera.ViewportSize.Y/2
                    local dir = (v2-Vector2.new(cx,cy)).Unit
                    local edge = Vector2.new(cx,cy) + dir*math.min(cx,cy)*0.95
                    local arrow=Drawing.new("Triangle")
                    local perp=Vector2.new(-dir.Y,dir.X)*10
                    arrow.PointA=edge+dir*24
                    arrow.PointB=edge+perp
                    arrow.PointC=edge-perp
                    arrow.Color=settings.esp_tracer_color
                    arrow.Filled=true
                    arrow.Transparency=0.7
                    arrow.Visible=true
                    table.insert(esp_objects,arrow)
                end
            end
        end)
    end
end

-- aimbot
local aimbot_held=false
local function getClosestTarget()
    local best,bestdist=nil,settings.aimbot_fov_radius
    for _,player in ipairs(players:GetPlayers())do
        pcall(function()
            if player~=localplayer and player.Character and player.Character:FindFirstChild(settings.aimbot_target) and player.Character:FindFirstChild("Humanoid")and player.Character.Humanoid.Health>0 then
                if settings.aimbot_ignore_list and table.find(settings.aimbot_ignore_list,player.Name) then return end
                local part=player.Character[settings.aimbot_target]
                local pos,onscreen=camera:WorldToViewportPoint(part.Position)
                if onscreen then
                    local dist=(Vector2.new(pos.X,pos.Y)-Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)).Magnitude
                    if dist<bestdist then best,bestdist=player,dist end
                end
            end
        end)
    end return best
end
runservice.RenderStepped:Connect(function()
    pcall(function()
        if settings.aimbot_enabled and(settings.aimbot_hold and aimbot_held or not settings.aimbot_hold)then
            local target=getClosestTarget()
            if target and target.Character and target.Character:FindFirstChild(settings.aimbot_target)then
                local targetPart=target.Character[settings.aimbot_target]
                local targetPos=targetPart.Position
                if settings.aimbot_prediction then
                    local hum=target.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.MoveDirection.Magnitude>0 then
                        targetPos=targetPos+hum.MoveDirection*0.12*math.clamp((targetPos-camera.CFrame.Position).Magnitude/100,0.5,3)
                    end
                end
                local camPos=camera.CFrame.Position
                local newcf=CFrame.new(camPos,targetPos)
                if settings.aimbot_silent then
                    -- Silent aim: manipulate mouse target (executor-specific, may require metamethod hook; not implemented here)
                end
                if settings.aimbot_smoothing and settings.aimbot_smoothing>0 then
                    camera.CFrame=camera.CFrame:Lerp(newcf,math.clamp(settings.aimbot_smoothing/10,0,1))
                else camera.CFrame=newcf end
            end
        end
    end)
end)

-- FOV circle
local fovdraw
function drawFov()
    if not Drawing then return end
    if fovdraw then pcall(function() fovdraw:Remove() end) end
    if settings.aimbot_fov_enabled then
        fovdraw=Drawing.new("Circle")
        fovdraw.Position=Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)
        fovdraw.Color=settings.aimbot_fov_color
        fovdraw.Radius=settings.aimbot_fov_radius
        fovdraw.Thickness=settings.aimbot_fov_thickness
        fovdraw.Filled=settings.aimbot_fov_filled
        fovdraw.Transparency=1-settings.aimbot_fov_transparency
        fovdraw.Visible=true
    end
end
runservice.RenderStepped:Connect(function() render_esp(); drawFov() end)

-- keybind logic
userinput.InputBegan:Connect(function(input,gpe)
    if gpe then return end
    if input.KeyCode==settings.aimbot_key then
        if settings.aimbot_hold then aimbot_held=true else settings.aimbot_enabled=not settings.aimbot_enabled end
    end
    if input.KeyCode==settings.esp_key then settings.esp_enabled=not settings.esp_enabled; saveSettings() end
    if input.KeyCode==settings.movement_fly_key then settings.movement_fly=not settings.movement_fly; saveSettings() end
    if input.KeyCode==settings.movement_noclip_key then settings.movement_noclip=not settings.movement_noclip; saveSettings() end
    if input.KeyCode==settings.movement_speed_key then settings.movement_speed=not settings.movement_speed; saveSettings() end
    if input.KeyCode==settings.movement_infjump_key then settings.movement_infjump=not settings.movement_infjump; saveSettings() end
    if input.KeyCode==settings.combat_triggerbot_key then settings.combat_triggerbot=not settings.combat_triggerbot; saveSettings() end
    if input.KeyCode==settings.camera_freecam_key then settings.camera_freecam=not settings.camera_freecam; saveSettings() end
end)
userinput.InputEnded:Connect(function(input,gpe)
    if input.KeyCode==settings.aimbot_key then aimbot_held=false end
end)

-- movement
runservice.RenderStepped:Connect(function()
    pcall(function()
        local char=localplayer.Character;if not char then return end;local hum=char:FindFirstChildOfClass("Humanoid")
        if settings.movement_fly and char:FindFirstChild("HumanoidRootPart")then
            local root=char.HumanoidRootPart;local move=Vector3.new(0,0,0)
            if userinput:IsKeyDown(Enum.KeyCode.W)then move=move+camera.CFrame.LookVector end
            if userinput:IsKeyDown(Enum.KeyCode.S)then move=move-camera.CFrame.LookVector end
            if userinput:IsKeyDown(Enum.KeyCode.A)then move=move-camera.CFrame.RightVector end
            if userinput:IsKeyDown(Enum.KeyCode.D)then move=move+camera.CFrame.RightVector end
            if userinput:IsKeyDown(Enum.KeyCode.Space)then move=move+Vector3.new(0,1,0)end
            if userinput:IsKeyDown(Enum.KeyCode.LeftShift)then move=move-Vector3.new(0,1,0)end
            root.Velocity=move.Unit*60;if hum then hum.PlatformStand=true end
        elseif hum then hum.PlatformStand=false end
        if settings.movement_noclip then for _,v in pairs(char:GetDescendants())do if v:IsA("BasePart")then v.CanCollide=false end end end
        if settings.movement_speed and hum then hum.WalkSpeed=settings.movement_speed_value elseif hum then hum.WalkSpeed=16 end
    end)
end)
userinput.JumpRequest:Connect(function()
    pcall(function()
        if settings.movement_infjump and localplayer.Character and localplayer.Character:FindFirstChildOfClass("Humanoid")then
            localplayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end)

-- combat (triggerbot)
local mouse=localplayer:GetMouse()
runservice.RenderStepped:Connect(function()
    pcall(function()
        if settings.combat_triggerbot then
            local target=mouse.Target
            if target then
                local plr=players:GetPlayerFromCharacter(target.Parent)
                if plr and plr~=localplayer then
                    local tool=localplayer.Character and localplayer.Character:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Activate")then tool:Activate()end
                end
            end
        end
    end)
end)

-- camera/FOV
camera.FieldOfView=settings.camera_fov
runservice.RenderStepped:Connect(function()
    pcall(function()
        if settings.camera_freecam then
            camera.CameraType=Enum.CameraType.Scriptable
            local move=Vector3.new(0,0,0)
            if userinput:IsKeyDown(Enum.KeyCode.W)then move=move+camera.CFrame.LookVector end
            if userinput:IsKeyDown(Enum.KeyCode.S)then move=move-camera.CFrame.LookVector end
            if userinput:IsKeyDown(Enum.KeyCode.A)then move=move-camera.CFrame.RightVector end
            if userinput:IsKeyDown(Enum.KeyCode.D)then move=move+camera.CFrame.RightVector end
            if userinput:IsKeyDown(Enum.KeyCode.Space)then move=move+Vector3.new(0,1,0)end
            if userinput:IsKeyDown(Enum.KeyCode.LeftShift)then move=move-Vector3.new(0,1,0)end
            camera.CFrame=camera.CFrame+move*2
        else camera.CameraType=Enum.CameraType.Custom end
        camera.FieldOfView=settings.camera_fov
    end)
end)

-- visuals
runservice.RenderStepped:Connect(function()
    pcall(function()
        local lighting=game:GetService("Lighting")
        if settings.visuals_fullbright then
            lighting.Brightness=7;lighting.Ambient=Color3.new(1,1,1);lighting.OutdoorAmbient=Color3.new(1,1,1);lighting.ClockTime=14
        else
            lighting.Brightness=2;lighting.Ambient=Color3.fromRGB(128,128,128);lighting.OutdoorAmbient=Color3.fromRGB(128,128,128)
        end
        if settings.visuals_fog then lighting.FogEnd=999999 else lighting.FogEnd=1000 end
    end)
end)

print("FemboyHub loaded successfully. Enjoy!")
