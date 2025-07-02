local MacLib = loadstring(game:HttpGet("https://github.com/biggaboy212/Maclib/releases/latest/download/maclib.txt"))()

local Window = MacLib:Window({
    Title = "blossom.lua",
    Subtitle = "blossom.lua best trash universal",
    Size = UDim2.fromOffset(900, 700),
    DragStyle = 1,
    Keybind = Enum.KeyCode.RightControl,
    AcrylicBlur = true,
})

local TabGroup = Window:TabGroup()
local mainTab = TabGroup:Tab({ Name = "Main" })
local visualsTab = TabGroup:Tab({ Name = "Visuals" })
local configTab = TabGroup:Tab({ Name = "Config" })

local mainSection = mainTab:Section({ Side = "Left" })
local spinSection = mainTab:Section({ Side = "Right", Name = "Spin Bot" })
local visualsSection = visualsTab:Section({ Side = "Left" })
local espColorSection = visualsTab:Section({ Side = "Right", Name = "ESP Colors" })

local settings = {
    Enabled = false,
    FOV = 100,
    Smoothness = 0.15,
    Prediction = 0.13,
    AimPart = "Head",
    FOVColor = Color3.fromRGB(0,255,0),
    Key = Enum.KeyCode.E,
    AimMode = "Hold",
    AimType = "Camera",
    ESP_Enabled = false,
    ESP_Types = {},
    BoxColor = Color3.fromRGB(0,255,0),
    TracerColor = Color3.fromRGB(255,255,0),
    NameColor = Color3.fromRGB(255,255,255),
    HealthBarColor = Color3.fromRGB(0,255,0),
    DistanceColor = Color3.fromRGB(0,255,255),
    HeadDotColor = Color3.fromRGB(255,0,0),
    ChamsColor = Color3.fromRGB(0,255,255),
    ChamsOutlineColor = Color3.fromRGB(0,0,0),
    SpinEnabled = false,
    SpinSpeed = 50
}

mainSection:Toggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(val) settings.Enabled = val end,
})

mainSection:Slider({
    Name = "FOV",
    Default = 100,
    Minimum = 20,
    Maximum = 300,
    Callback = function(val) settings.FOV = val end,
})

mainSection:Slider({
    Name = "Smoothness",
    Default = 0.15,
    Minimum = 0.01,
    Maximum = 1,
    Precision = 2,
    Callback = function(val) settings.Smoothness = val end,
})

mainSection:Slider({
    Name = "Prediction",
    Default = 0.13,
    Minimum = 0,
    Maximum = 0.5,
    Precision = 2,
    Callback = function(val) settings.Prediction = val end,
})

mainSection:Dropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart"},
    Default = "Head",
    Callback = function(val) settings.AimPart = val end,
})

mainSection:Colorpicker({
    Name = "FOV Color",
    Default = Color3.fromRGB(0,255,0),
    Callback = function(val) settings.FOVColor = val end,
})

mainSection:Keybind({
    Name = "Aimbot Keybind",
    Blacklist = false,
    Callback = function(bind)
        settings.Key = bind
    end,
    onBinded = function(bind)
        settings.Key = bind
    end,
}, "AimbotKeybind")

mainSection:Dropdown({
    Name = "Aim Mode",
    Options = {"Hold", "Toggle"},
    Default = "Hold",
    Callback = function(val) settings.AimMode = val end,
})

mainSection:Dropdown({
    Name = "Aim Type",
    Options = {"Camera", "Cursor"},
    Default = "Camera",
    Callback = function(val) settings.AimType = val end,
})

spinSection:Toggle({
    Name = "Enable Spin Bot",
    Default = false,
    Callback = function(val) settings.SpinEnabled = val end,
})

spinSection:Slider({
    Name = "Spin Speed",
    Default = 50,
    Minimum = 1,
    Maximum = 100,
    Callback = function(val) settings.SpinSpeed = val end,
})

visualsSection:Toggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(val) settings.ESP_Enabled = val end,
})

local espTypes = {
    "Box",
    "Tracer",
    "Name",
    "HealthBar",
    "Distance",
    "HeadDot",
    "Chams"
}

visualsSection:Dropdown({
    Name = "ESP Types",
    Options = espTypes,
    Multi = true,
    Required = false,
    Default = {},
    Callback = function(val)
        local selected = {}
        for k, v in pairs(val) do
            if v then table.insert(selected, k) end
        end
        settings.ESP_Types = selected
    end,
})

espColorSection:Colorpicker({
    Name = "Box Color",
    Default = Color3.fromRGB(0,255,0),
    Callback = function(val) settings.BoxColor = val end,
})

espColorSection:Colorpicker({
    Name = "Tracer Color",
    Default = Color3.fromRGB(255,255,0),
    Callback = function(val) settings.TracerColor = val end,
})

espColorSection:Colorpicker({
    Name = "Name Color",
    Default = Color3.fromRGB(255,255,255),
    Callback = function(val) settings.NameColor = val end,
})

espColorSection:Colorpicker({
    Name = "HealthBar Color",
    Default = Color3.fromRGB(0,255,0),
    Callback = function(val) settings.HealthBarColor = val end,
})

espColorSection:Colorpicker({
    Name = "Distance Color",
    Default = Color3.fromRGB(0,255,255),
    Callback = function(val) settings.DistanceColor = val end,
})

espColorSection:Colorpicker({
    Name = "HeadDot Color",
    Default = Color3.fromRGB(255,0,0),
    Callback = function(val) settings.HeadDotColor = val end,
})

espColorSection:Colorpicker({
    Name = "Chams Fill Color",
    Default = Color3.fromRGB(0,255,255),
    Callback = function(val) settings.ChamsColor = val end,
})

espColorSection:Colorpicker({
    Name = "Chams Outline Color",
    Default = Color3.fromRGB(0,0,0),
    Callback = function(val) settings.ChamsOutlineColor = val end,
})

MacLib:SetFolder("AimbotConfig")
configTab:InsertConfigSection("Left")
MacLib:LoadAutoLoadConfig()

local camera = workspace.CurrentCamera
local players = game:GetService("Players")
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local lp = players.LocalPlayer

local playerCache = {}

local function cleanupPlayerData(player)
    if playerCache[player] then
        playerCache[player] = nil
    end
    removeChams(player)
end

local chamsTable = {}

local function clearChams()
    for plr, highlight in pairs(chamsTable) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    chamsTable = {}
end

local function applyChams(plr)
    if not plr.Character then return end
    if chamsTable[plr] and chamsTable[plr].Parent then
        chamsTable[plr].FillColor = settings.ChamsColor
        chamsTable[plr].OutlineColor = settings.ChamsOutlineColor
        return
    end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = plr.Character
    highlight.FillColor = settings.ChamsColor
    highlight.OutlineColor = settings.ChamsOutlineColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = game:GetService("CoreGui")
    chamsTable[plr] = highlight
end

local function removeChams(plr)
    if chamsTable[plr] and chamsTable[plr].Parent then
        chamsTable[plr]:Destroy()
        chamsTable[plr] = nil
    end
end

local function getClosestPlayer()
    local closest, dist = nil, settings.FOV
    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= lp and plr.Character and (not plr.Team or plr.Team ~= lp.Team) then
            local part = plr.Character:FindFirstChild(settings.AimPart)
            if part then
                local pos = part.Position + (part.Velocity * settings.Prediction)
                local screen, onScreen = camera:WorldToViewportPoint(pos)
                if onScreen then
                    local mousePos = uis:GetMouseLocation()
                    local mag = (Vector2.new(screen.X, screen.Y) - Vector2.new(mousePos.X, mousePos.Y)).Magnitude
                    if mag < dist then
                        dist = mag
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

local fovCircle = Drawing.new("Circle")
fovCircle.Color = settings.FOVColor
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Transparency = 0.5
fovCircle.Radius = settings.FOV

rs.RenderStepped:Connect(function()
    fovCircle.Position = uis:GetMouseLocation()
    fovCircle.Radius = settings.FOV
    fovCircle.Color = settings.FOVColor
    fovCircle.Visible = settings.Enabled
end)

local spinConnection = nil
local currentSpin = 0

local function startSpinBot()
    if spinConnection then return end
    
    spinConnection = rs.Heartbeat:Connect(function(dt)
        if not settings.SpinEnabled then
            spinConnection:Disconnect()
            spinConnection = nil
            return
        end
        
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            currentSpin = (currentSpin + dt * settings.SpinSpeed * 10) % (math.pi * 2)
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(lp.Character.HumanoidRootPart.Position) * CFrame.Angles(0, currentSpin, 0)
        end
    end)
end

rs.Heartbeat:Connect(function()
    if settings.SpinEnabled and not spinConnection then
        startSpinBot()
    end
end)

players.PlayerAdded:Connect(function(player)
    playerCache[player] = true
end)

players.PlayerRemoving:Connect(function(player)
    cleanupPlayerData(player)
end)

lp.CharacterAdded:Connect(function(char)
    if settings.SpinEnabled and not spinConnection then
        startSpinBot()
    end
end)

local espObjects = {}

local function clearESP()
    for _, obj in ipairs(espObjects) do
        if obj.Remove then
            obj:Remove()
        elseif obj.Destroy then
            obj:Destroy()
        elseif typeof(obj) == "table" and obj.Visible ~= nil then
            obj.Visible = false
        end
    end
    espObjects = {}
end

local function drawESP()
    clearESP()
    if not settings.ESP_Enabled then
        clearChams()
        return
    end
    
    for _, plr in ipairs(players:GetPlayers()) do
        if plr ~= lp then
            playerCache[plr] = true
        end
    end
    
    for plr, _ in pairs(playerCache) do
        if plr ~= lp and plr.Character and (not plr.Team or plr.Team ~= lp.Team) then
            local char = plr.Character
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            
            if hrp and head then
                local headScreen, headOnScreen = camera:WorldToViewportPoint(head.Position)
                local hrpScreen, hrpOnScreen = camera:WorldToViewportPoint(hrp.Position)
                
                if headOnScreen and hrpOnScreen then
                    local distance = (hrp.Position - camera.CFrame.Position).Magnitude
                    local baseHeight = 160
                    local baseWidth = 80
                    local scale = 25 / math.max(distance, 1)
                    local height = baseHeight * scale
                    local width = baseWidth * scale
                    height = math.clamp(height, 15, 200)
                    width = math.clamp(width, 8, 100)
                    local boxX = headScreen.X - width/2
                    local boxY = headScreen.Y - height/6
                    
                    if table.find(settings.ESP_Types, "Box") then
                        local box = Drawing.new("Square")
                        box.Size = Vector2.new(width, height)
                        box.Position = Vector2.new(boxX, boxY)
                        box.Color = settings.BoxColor
                        box.Thickness = 2
                        box.Filled = false
                        box.Visible = true
                        table.insert(espObjects, box)
                    end
                    
                    if table.find(settings.ESP_Types, "HealthBar") and humanoid then
                        local health = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                        local barHeight = height * health
                        local barY = boxY + (height - barHeight)
                        local barWidth = math.max(4, width * 0.05)
                        
                        local bar = Drawing.new("Square")
                        bar.Size = Vector2.new(barWidth, barHeight)
                        bar.Position = Vector2.new(boxX - barWidth - 2, barY)
                        bar.Color = settings.HealthBarColor
                        bar.Filled = true
                        bar.Visible = true
                        table.insert(espObjects, bar)
                        
                        local outline = Drawing.new("Square")
                        outline.Size = Vector2.new(barWidth, height)
                        outline.Position = Vector2.new(boxX - barWidth - 2, boxY)
                        outline.Color = Color3.fromRGB(0,0,0)
                        outline.Thickness = 1
                        outline.Filled = false
                        outline.Visible = true
                        table.insert(espObjects, outline)
                    end
                    
                    if table.find(settings.ESP_Types, "Name") then
                        local textSize = math.max(12, math.min(18, 14 * scale * 1.2))
                        local name = Drawing.new("Text")
                        name.Text = plr.Name
                        name.Position = Vector2.new(boxX + width/2, boxY - textSize - 2)
                        name.Size = textSize
                        name.Color = settings.NameColor
                        name.Center = true
                        name.Outline = true
                        name.Visible = true
                        table.insert(espObjects, name)
                    end
                    
                    if table.find(settings.ESP_Types, "HeadDot") then
                        local dotRadius = math.max(2, math.min(8, width/10))
                        local dot = Drawing.new("Circle")
                        dot.Position = Vector2.new(headScreen.X, headScreen.Y)
                        dot.Radius = dotRadius
                        dot.Color = settings.HeadDotColor
                        dot.Filled = true
                        dot.Visible = true
                        table.insert(espObjects, dot)
                    end
                    
                    if table.find(settings.ESP_Types, "Distance") then
                        local textSize = math.max(10, math.min(16, 12 * scale * 1.2))
                        local dist = Drawing.new("Text")
                        dist.Text = tostring(math.floor(distance)).."м"
                        dist.Position = Vector2.new(boxX + width/2, boxY + height + 2)
                        dist.Size = textSize
                        dist.Color = settings.DistanceColor
                        dist.Center = true
                        dist.Outline = true
                        dist.Visible = true
                        table.insert(espObjects, dist)
                    end
                    
                    if table.find(settings.ESP_Types, "Tracer") then
                        local tracer = Drawing.new("Line")
                        tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                        tracer.To = Vector2.new(hrpScreen.X, hrpScreen.Y)
                        tracer.Color = settings.TracerColor
                        tracer.Thickness = 1
                        tracer.Visible = true
                        table.insert(espObjects, tracer)
                    end
                    
                    if table.find(settings.ESP_Types, "Chams") then
                        applyChams(plr)
                    else
                        removeChams(plr)
                    end
                else
                    removeChams(plr)
                end
            else
                removeChams(plr)
            end
        else
            removeChams(plr)
        end
    end
end

rs.RenderStepped:Connect(drawESP)

local aiming = false

uis.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == settings.Key then
        if settings.AimMode == "Hold" then
            aiming = true
        elseif settings.AimMode == "Toggle" then
            aiming = not aiming
        end
    end
end)

uis.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == settings.Key and settings.AimMode == "Hold" then
        aiming = false
    end
end)

rs.RenderStepped:Connect(function()
    if settings.Enabled and aiming then
        local target = getClosestPlayer()
        if target then
            local camPos = camera.CFrame.Position
            local targetPos = target.Position + (target.Velocity * settings.Prediction)
            local direction = (targetPos - camPos).Unit
            local newCFrame = CFrame.new(camPos, camPos + direction)
            camera.CFrame = camera.CFrame:Lerp(newCFrame, settings.Smoothness)
            if settings.AimType == "Cursor" then
                local screenPos = camera:WorldToViewportPoint(target.Position + (target.Velocity * settings.Prediction))
                local mousePos = uis:GetMouseLocation()
                local targetVec = Vector2.new(screenPos.X, screenPos.Y)
                local moveVec = (targetVec - mousePos) * settings.Smoothness
                if mousemoverel then
                    mousemoverel(moveVec.X, moveVec.Y)
                end
            end
        end
    end
end)
