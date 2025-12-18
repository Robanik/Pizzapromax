local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")

local MonsterESPObjects = {}
local NotificationEnabled = true

-- Настройки ESP для монстров
local MonsterESPSettings = {
    Enabled = false,
    BoxColor = Color3.fromRGB(255, 0, 0),
    BoxOutlineColor = Color3.fromRGB(10, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    LineColor = Color3.fromRGB(255, 0, 0),
    LineOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxThickness = 3,
    LineThickness = 2.5,
    TextSize = 16,
    MaxDistance = 3000,
    FadeDistance = 800,
    ShowDistance = true,
    ShowLine = true,
    ShowBox = true,
    PulseEffect = true
}

local pulseValue = 0

-- Создание уведомления
local function createNotification(monsterName)
    if not NotificationEnabled then return end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MonsterNotification"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Защита от удаления
    pcall(function()
        screenGui.Parent = game:GetService("CoreGui")
    end)
    if not screenGui.Parent then
        screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Главный фрейм
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 400, 0, 100)
    mainFrame.Position = UDim2.new(0.5, -200, 0, -120)
    mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Градиент
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 0, 0)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 0))
    }
    gradient.Rotation = 45
    gradient.Parent = mainFrame
    
    -- Обводка
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 0, 0)
    stroke.Thickness = 2
    stroke.Parent = mainFrame
    
    -- Скругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Красная полоса сверху
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 4)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 12)
    topCorner.Parent = topBar
    
    -- Иконка предупреждения
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 50, 0, 50)
    icon.Position = UDim2.new(0, 15, 0.5, -25)
    icon.BackgroundTransparency = 1
    icon.Text = "⚠"
    icon.TextColor3 = Color3.fromRGB(255, 0, 0)
    icon.TextSize = 40
    icon.Font = Enum.Font.GothamBold
    icon.Parent = mainFrame
    
    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0, 300, 0, 30)
    title.Position = UDim2.new(0, 75, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "⚠ DANGER ALERT ⚠"
    title.TextColor3 = Color3.fromRGB(255, 50, 50)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = mainFrame
    
    -- Текст монстра
    local monsterText = Instance.new("TextLabel")
    monsterText.Size = UDim2.new(0, 300, 0, 40)
    monsterText.Position = UDim2.new(0, 75, 0, 45)
    monsterText.BackgroundTransparency = 1
    monsterText.Text = monsterName .. " DETECTED!"
    monsterText.TextColor3 = Color3.fromRGB(255, 255, 255)
    monsterText.TextSize = 16
    monsterText.Font = Enum.Font.Gotham
    monsterText.TextXAlignment = Enum.TextXAlignment.Left
    monsterText.TextWrapped = true
    monsterText.Parent = mainFrame
    
    -- Анимация появления
    mainFrame.BackgroundTransparency = 1
    for _, obj in ipairs(mainFrame:GetDescendants()) do
        if obj:IsA("GuiObject") then
            obj.BackgroundTransparency = 1
            if obj:IsA("TextLabel") then
                obj.TextTransparency = 1
            end
        end
    end
    
    local slideIn = TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(0.5, -200, 0, 20)
    })
    
    local fadeIn = TweenService:Create(mainFrame, TweenInfo.new(0.3), {
        BackgroundTransparency = 0
    })
    
    -- Fade in для всех элементов
    slideIn:Play()
    fadeIn:Play()
    
    task.wait(0.1)
    for _, obj in ipairs(mainFrame:GetDescendants()) do
        if obj:IsA("GuiObject") and obj ~= mainFrame then
            TweenService:Create(obj, TweenInfo.new(0.3), {
                BackgroundTransparency = obj == topBar and 0 or 1
            }):Play()
            if obj:IsA("TextLabel") then
                TweenService:Create(obj, TweenInfo.new(0.3), {
                    TextTransparency = 0
                }):Play()
            end
        end
    end
    
    -- Пульсация обводки
    task.spawn(function()
        for i = 1, 6 do
            TweenService:Create(stroke, TweenInfo.new(0.5), {Thickness = 4}):Play()
            task.wait(0.5)
            TweenService:Create(stroke, TweenInfo.new(0.5), {Thickness = 2}):Play()
            task.wait(0.5)
        end
    end)
    
    -- Удаление через 6 секунд
    task.wait(6)
    local fadeOut = TweenService:Create(mainFrame, TweenInfo.new(0.5), {
        Position = UDim2.new(0.5, -200, 0, -120)
    })
    fadeOut:Play()
    fadeOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
end

-- Создание Drawing объектов для монстра
local function createMonsterESP()
    local esp = {
        Box = Drawing.new("Square"),
        BoxOutline = Drawing.new("Square"),
        Line = Drawing.new("Line"),
        LineOutline = Drawing.new("Line"),
        NameText = Drawing.new("Text"),
        NameOutline = Drawing.new("Text"),
        DistanceText = Drawing.new("Text"),
        DistanceOutline = Drawing.new("Text")
    }
    
    -- Box
    esp.Box.Thickness = MonsterESPSettings.BoxThickness
    esp.Box.Color = MonsterESPSettings.BoxColor
    esp.Box.Transparency = 1
    esp.Box.Filled = false
    esp.Box.Visible = false
    esp.Box.ZIndex = 2
    
    esp.BoxOutline.Thickness = MonsterESPSettings.BoxThickness + 2
    esp.BoxOutline.Color = MonsterESPSettings.BoxOutlineColor
    esp.BoxOutline.Transparency = 0.9
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Visible = false
    esp.BoxOutline.ZIndex = 1
    
    -- Line
    esp.Line.Thickness = MonsterESPSettings.LineThickness
    esp.Line.Color = MonsterESPSettings.LineColor
    esp.Line.Transparency = 1
    esp.Line.Visible = false
    esp.Line.ZIndex = 2
    
    esp.LineOutline.Thickness = MonsterESPSettings.LineThickness + 2
    esp.LineOutline.Color = MonsterESPSettings.LineOutlineColor
    esp.LineOutline.Transparency = 0.6
    esp.LineOutline.Visible = false
    esp.LineOutline.ZIndex = 1
    
    -- Name Text
    esp.NameText.Size = MonsterESPSettings.TextSize + 2
    esp.NameText.Color = Color3.fromRGB(255, 0, 0)
    esp.NameText.Center = true
    esp.NameText.Outline = false
    esp.NameText.Visible = false
    esp.NameText.Font = 3
    esp.NameText.ZIndex = 3
    
    esp.NameOutline.Size = MonsterESPSettings.TextSize + 2
    esp.NameOutline.Color = MonsterESPSettings.BoxOutlineColor
    esp.NameOutline.Center = true
    esp.NameOutline.Outline = false
    esp.NameOutline.Visible = false
    esp.NameOutline.Font = 3
    esp.NameOutline.ZIndex = 2
    
    -- Distance Text
    esp.DistanceText.Size = MonsterESPSettings.TextSize
    esp.DistanceText.Color = MonsterESPSettings.TextColor
    esp.DistanceText.Center = true
    esp.DistanceText.Outline = false
    esp.DistanceText.Visible = false
    esp.DistanceText.Font = 2
    esp.DistanceText.ZIndex = 3
    
    esp.DistanceOutline.Size = MonsterESPSettings.TextSize
    esp.DistanceOutline.Color = MonsterESPSettings.BoxOutlineColor
    esp.DistanceOutline.Center = true
    esp.DistanceOutline.Outline = false
    esp.DistanceOutline.Visible = false
    esp.DistanceOutline.Font = 2
    esp.DistanceOutline.ZIndex = 2
    
    return esp
end

-- Удаление ESP
local function removeMonsterESP(esp)
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

-- Получение углов
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

-- Обновление ESP монстра
local function updateMonsterESP(monster, esp, monsterName)
    if not monster or not monster.Parent then
        for _, drawing in pairs(esp) do
            if drawing then drawing.Visible = false end
        end
        return
    end
    
    local distance = (monster.Position - Camera.CFrame.Position).Magnitude
    
    if distance > MonsterESPSettings.MaxDistance then
        for _, drawing in pairs(esp) do
            if drawing then drawing.Visible = false end
        end
        return
    end
    
    local size = monster.Size
    local cf = monster.CFrame
    local corners = getCorners(cf, size * 2)
    local min, max = get2DBox(corners)
    
    if min and max then
        local boxSize = max - min
        
        -- Прозрачность
        local fadeAlpha = 1
        if distance > MonsterESPSettings.FadeDistance then
            fadeAlpha = 1 - ((distance - MonsterESPSettings.FadeDistance) / (MonsterESPSettings.MaxDistance - MonsterESPSettings.FadeDistance))
            fadeAlpha = math.clamp(fadeAlpha, 0.4, 1)
        end
        
        -- Пульсация
        local pulseAlpha = fadeAlpha
        if MonsterESPSettings.PulseEffect then
            pulseAlpha = fadeAlpha * (0.7 + math.sin(pulseValue) * 0.3)
        end
        
        -- Box
        if MonsterESPSettings.ShowBox then
            esp.BoxOutline.Size = boxSize
            esp.BoxOutline.Position = min
            esp.BoxOutline.Visible = MonsterESPSettings.Enabled
            esp.BoxOutline.Transparency = 0.9 * pulseAlpha
            
            esp.Box.Size = boxSize
            esp.Box.Position = min
            esp.Box.Visible = MonsterESPSettings.Enabled
            esp.Box.Transparency = pulseAlpha
        else
            esp.Box.Visible = false
            esp.BoxOutline.Visible = false
        end
        
        -- Line
        if MonsterESPSettings.ShowLine then
            local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            local objBottom = Vector2.new(min.X + boxSize.X / 2, max.Y)
            
            esp.LineOutline.From = screenBottom
            esp.LineOutline.To = objBottom
            esp.LineOutline.Visible = MonsterESPSettings.Enabled
            esp.LineOutline.Transparency = 0.6 * fadeAlpha
            
            esp.Line.From = screenBottom
            esp.Line.To = objBottom
            esp.Line.Visible = MonsterESPSettings.Enabled
            esp.Line.Transparency = pulseAlpha
        else
            esp.Line.Visible = false
            esp.LineOutline.Visible = false
        end
        
        -- Name Text
        local nameText = "☠ " .. monsterName .. " ☠"
        local namePos = Vector2.new(min.X + boxSize.X / 2, min.Y - 36)
        
        for i = -1, 1 do
            for j = -1, 1 do
                if i ~= 0 or j ~= 0 then
                    esp.NameOutline.Text = nameText
                    esp.NameOutline.Position = namePos + Vector2.new(i, j)
                    esp.NameOutline.Visible = MonsterESPSettings.Enabled
                    esp.NameOutline.Transparency = fadeAlpha
                end
            end
        end
        
        esp.NameText.Text = nameText
        esp.NameText.Position = namePos
        esp.NameText.Visible = MonsterESPSettings.Enabled
        esp.NameText.Transparency = pulseAlpha
        
        -- Distance Text
        if MonsterESPSettings.ShowDistance then
            local distanceText = string.format("%.0fm", distance)
            local textPos = Vector2.new(min.X + boxSize.X / 2, min.Y - 18)
            
            for i = -1, 1 do
                for j = -1, 1 do
                    if i ~= 0 or j ~= 0 then
                        esp.DistanceOutline.Text = distanceText
                        esp.DistanceOutline.Position = textPos + Vector2.new(i, j)
                        esp.DistanceOutline.Visible = MonsterESPSettings.Enabled
                        esp.DistanceOutline.Transparency = fadeAlpha
                    end
                end
            end
            
            esp.DistanceText.Text = distanceText
            esp.DistanceText.Position = textPos
            esp.DistanceText.Visible = MonsterESPSettings.Enabled
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

-- Добавление ESP к монстру
local function addMonsterESP(monster, monsterName)
    if MonsterESPObjects[monster] then return end
    
    local esp = createMonsterESP()
    MonsterESPObjects[monster] = {esp = esp, name = monsterName}
    
    createNotification(monsterName)
    
    monster.AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeMonsterESP(esp)
            MonsterESPObjects[monster] = nil
        end
    end)
end

-- Мониторинг монстров
local function monitorMonsters()
    local interactables = workspace:WaitForChild("Interactables", 10)
    if not interactables then return end
    
    -- Проверка CarStalkerMonster
    local function checkCarStalker()
        local carStalker = interactables:FindFirstChild("CarStalkerMonster")
        if carStalker then
            local upperTorso = carStalker:FindFirstChild("UpperTorso")
            if upperTorso and not MonsterESPObjects[upperTorso] then
                addMonsterESP(upperTorso, "CAR STALKER")
            end
        end
    end
    
    -- Проверка ChaseMonster
    local function checkChaseMonster()
        local chaseMonster = interactables:FindFirstChild("ChaseMonster")
        if chaseMonster then
            local upperTorso = chaseMonster:FindFirstChild("UpperTorso")
            if upperTorso and not MonsterESPObjects[upperTorso] then
                addMonsterESP(upperTorso, "CHASE MONSTER")
            end
        end
    end
    
    -- Постоянный мониторинг
    task.spawn(function()
        while true do
            checkCarStalker()
            checkChaseMonster()
            task.wait(0.5)
        end
    end)
    
    -- Слушаем новых детей
    interactables.ChildAdded:Connect(function(child)
        if child.Name == "CarStalkerMonster" or child.Name == "ChaseMonster" then
            task.wait(0.1)
            if child.Name == "CarStalkerMonster" then
                checkCarStalker()
            else
                checkChaseMonster()
            end
        end
    end)
end

-- Главный цикл
local monsterRenderConnection
monsterRenderConnection = RunService.RenderStepped:Connect(function()
    if MonsterESPSettings.PulseEffect then
        pulseValue = pulseValue + 0.05
    end
    
    if not MonsterESPSettings.Enabled then 
        for monster, data in pairs(MonsterESPObjects) do
            for _, drawing in pairs(data.esp) do
                if drawing then drawing.Visible = false end
            end
        end
        return 
    end
    
    for monster, data in pairs(MonsterESPObjects) do
        pcall(function()
            updateMonsterESP(monster, data.esp, data.name)
        end)
    end
end)

-- Запуск
monitorMonsters()

-- Функции управления
_G.ToggleESPMonster = function()
    MonsterESPSettings.Enabled = not MonsterESPSettings.Enabled
end

_G.ToggleNotify = function()
    NotificationEnabled = not NotificationEnabled
end

_G.TogglePulse = function()
    MonsterESPSettings.PulseEffect = not MonsterESPSettings.PulseEffect
end
