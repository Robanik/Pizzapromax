local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPObjects = {}

-- Настройки ESP
local ESPSettings = {
    Enabled = false,
    BoxColor = Color3.fromRGB(255, 50, 50),
    BoxOutlineColor = Color3.fromRGB(0, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    LineColor = Color3.fromRGB(0, 255, 255),
    LineOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxThickness = 2.5,
    LineThickness = 2,
    TextSize = 15,
    MaxDistance = 2000,
    FadeDistance = 500,
    ShowDistance = true,
    ShowLine = true,
    ShowBox = true,
    RainbowMode = false
}

local rainbowHue = 0

-- Создание Drawing объектов
local function createESP()
    local esp = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        LineOutline = Drawing.new("Line"),
        DistanceText = Drawing.new("Text"),
        DistanceOutline = Drawing.new("Text")
    }
    
    -- Box настройки
    esp.Box.Thickness = ESPSettings.BoxThickness
    esp.Box.Color = ESPSettings.BoxColor
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Visible = false
    esp.Box.ZIndex = 2
    
    esp.BoxOutline.Thickness = ESPSettings.BoxThickness + 2
    esp.BoxOutline.Color = ESPSettings.BoxOutlineColor
    esp.BoxOutline.Transparency = 0.8
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Visible = false
    esp.BoxOutline.ZIndex = 1
    
    -- Line настройки
    esp.Line.Thickness = ESPSettings.LineThickness
    esp.Line.Color = ESPSettings.LineColor
    esp.Line.Transparency = 1
    esp.Line.Visible = false
    esp.Line.ZIndex = 2
    
    esp.LineOutline.Thickness = ESPSettings.LineThickness + 2
    esp.LineOutline.Color = ESPSettings.LineOutlineColor
    esp.LineOutline.Transparency = 0.5
    esp.LineOutline.Visible = false
    esp.LineOutline.ZIndex = 1
    
    -- Distance Text настройки
    esp.DistanceText.Size = ESPSettings.TextSize
    esp.DistanceText.Color = ESPSettings.TextColor
    esp.DistanceText.Center = true
    esp.DistanceText.Outline = false
    esp.DistanceText.Visible = false
    esp.DistanceText.Font = 2
    esp.DistanceText.ZIndex = 3
    
    esp.DistanceOutline.Size = ESPSettings.TextSize
    esp.DistanceOutline.Color = ESPSettings.BoxOutlineColor
    esp.DistanceOutline.Center = true
    esp.DistanceOutline.Outline = false
    esp.DistanceOutline.Visible = false
    esp.DistanceOutline.Font = 2
    esp.DistanceOutline.ZIndex = 2
    
    return esp
end

-- Удаление ESP
local function removeESP(esp)
    if esp then
        for _, drawing in pairs(esp) do
            if drawing and drawing.Remove then
                pcall(function()
                    drawing:Remove()
                end)
            end
        end
    end
end

-- HSV в RGB для rainbow режима
local function HSVToRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q
    end
    
    return Color3.new(r, g, b)
end

-- Получение углов 3D бокса
local function getCorners(cf, size)
    local corners = {}
    for x = -1, 1, 2 do
        for y = -1, 1, 2 do
            for z = -1, 1, 2 do
                table.insert(corners, cf * CFrame.new(
                    size.X / 2 * x,
                    size.Y / 2 * y,
                    size.Z / 2 * z
                ))
            end
        end
    end
    return corners
end

-- Получение 2D бокса
local function get2DBox(corners)
    local min = Vector2.new(math.huge, math.huge)
    local max = Vector2.new(-math.huge, -math.huge)
    local allOnScreen = true
    
    for _, corner in ipairs(corners) do
        local pos, onScreen = Camera:WorldToViewportPoint(corner.Position)
        if onScreen then
            min = Vector2.new(math.min(min.X, pos.X), math.min(min.Y, pos.Y))
            max = Vector2.new(math.max(max.X, pos.X), math.max(max.Y, pos.Y))
        else
            allOnScreen = false
        end
    end
    
    if allOnScreen then
        return min, max
    else
        return nil, nil
    end
end

-- Обновление ESP
local function updateESP(rig, esp)
    if not rig or not rig.Parent or not rig:IsA("Model") then
        for _, drawing in pairs(esp) do
            if drawing then drawing.Visible = false end
        end
        return
    end
    
    local primaryPart = rig.PrimaryPart or rig:FindFirstChildWhichIsA("BasePart")
    if not primaryPart then
        for _, drawing in pairs(esp) do
            if drawing then drawing.Visible = false end
        end
        return
    end
    
    local distance = (primaryPart.Position - Camera.CFrame.Position).Magnitude
    
    if distance > ESPSettings.MaxDistance then
        for _, drawing in pairs(esp) do
            if drawing then drawing.Visible = false end
        end
        return
    end
    
    local cf, size = rig:GetBoundingBox()
    local corners = getCorners(cf, size)
    local min, max = get2DBox(corners)
    
    if min and max then
        local boxSize = max - min
        
        -- Прозрачность в зависимости от дистанции
        local fadeAlpha = 1
        if distance > ESPSettings.FadeDistance then
            fadeAlpha = 1 - ((distance - ESPSettings.FadeDistance) / (ESPSettings.MaxDistance - ESPSettings.FadeDistance))
            fadeAlpha = math.clamp(fadeAlpha, 0.3, 1)
        end
        
        -- Rainbow цвет
        local boxColor = ESPSettings.BoxColor
        local lineColor = ESPSettings.LineColor
        if ESPSettings.RainbowMode then
            boxColor = HSVToRGB(rainbowHue, 1, 1)
            lineColor = HSVToRGB((rainbowHue + 0.5) % 1, 1, 1)
        end
        
        -- Box
        if ESPSettings.ShowBox then
            esp.BoxOutline.Size = boxSize
            esp.BoxOutline.Position = min
            esp.BoxOutline.Visible = ESPSettings.Enabled
            esp.BoxOutline.Transparency = 0.8 * fadeAlpha
            
            esp.Box.Size = boxSize
            esp.Box.Position = min
            esp.Box.Color = boxColor
            esp.Box.Visible = ESPSettings.Enabled
            esp.Box.Transparency = fadeAlpha
        else
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
        end
        
        -- Line
        if ESPSettings.ShowLine then
            local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local objBottom = Vector2.new(min.X + boxSize.X / 2, max.Y)
            
            esp.LineOutline.From = screenBottom
            esp.LineOutline.To = objBottom
            esp.LineOutline.Visible = ESPSettings.Enabled
            esp.LineOutline.Transparency = 0.5 * fadeAlpha
            
            esp.Line.From = screenBottom
            esp.Line.To = objBottom
            esp.Line.Color = lineColor
            esp.Line.Visible = ESPSettings.Enabled
            esp.Line.Transparency = fadeAlpha
        else
            esp.Line.Visible = false
            esp.LineOutline.Visible = false
        end
        
        -- Distance Text
        if ESPSettings.ShowDistance then
            local distanceText = string.format("%.0fm", distance)
            local textPos = Vector2.new(min.X + boxSize.X / 2, min.Y - 18)
            
            for i = -1, 1 do
                for j = -1, 1 do
                    if i ~= 0 or j ~= 0 then
                        esp.DistanceOutline.Text = distanceText
                        esp.DistanceOutline.Position = textPos + Vector2.new(i, j)
                        esp.DistanceOutline.Visible = ESPSettings.Enabled
                        esp.DistanceOutline.Transparency = fadeAlpha
                    end
                end
            end
            
            esp.DistanceText.Text = distanceText
            esp.DistanceText.Position = textPos
            esp.DistanceText.Visible = ESPSettings.Enabled
            esp.DistanceText.Transparency = fadeAlpha
        else
            esp.DistanceText.Visible = false
            esp.DistanceOutline.Visible = false
        end
    else
        for _, drawing in pairs(esp) do
            if drawing then drawing.Visible = false end
        end
    end
end

-- Добавление ESP
local function addESP(rig)
    if ESPObjects[rig] then return end
    
    local esp = createESP()
    ESPObjects[rig] = esp
    
    rig.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeESP(esp)
            ESPObjects[rig] = nil
        end
    end)
end

-- Инициализация
local function initESP()
    local interactables = workspace:FindFirstChild("Interactables")
    if not interactables then return end
    
    for _, child in ipairs(interactables:GetChildren()) do
        if child.Name == "EmptyRig" then
            addESP(child)
        end
    end
    
    interactables.ChildAdded:Connect(function(child)
        if child.Name == "EmptyRig" then
            task.wait(0.05)
            addESP(child)
        end
    end)
end

-- Главный цикл
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function()
    if not ESPSettings.Enabled then 
        for rig, esp in pairs(ESPObjects) do
            for _, drawing in pairs(esp) do
                if drawing then drawing.Visible = false end
            end
        end
        return 
    end
    
    if ESPSettings.RainbowMode then
        rainbowHue = (rainbowHue + 0.001) % 1
    end
    
    for rig, esp in pairs(ESPObjects) do
        pcall(function()
            updateESP(rig, esp)
        end)
    end
end)

-- Запуск
initESP()

-- Функции управления
_G.ToggleESP = function()
    ESPSettings.Enabled = not ESPSettings.Enabled
end

_G.ToggleRainbow = function()
    ESPSettings.RainbowMode = not ESPSettings.RainbowMode
end

_G.SetESPDistance = function(dist)
    ESPSettings.MaxDistance = dist or 2000
end
