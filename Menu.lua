--скрипты
loadstring(game:HttpGet("https://raw.githubusercontent.com/Robanik/Pizzapromax/refs/heads/main/Espnormal.lua"))()

--начало
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--settings
local KEY_SYSTEM_ENABLED = true
local COPY_LINK = "https://discord.gg/3mVUh2RWsp"

-- Key validation
local function IsValidKey(key)
    return #key == 21 and string.sub(key, 1, 5) == "FREE_" and string.sub(key, 6):match("^%d+$") ~= nil
end

-- Utility function for creating UI elements with common properties
local function CreateUIElement(class, parent, props)
    local element = Instance.new(class)
    for prop, value in pairs(props) do
        element[prop] = value
    end
    element.Parent = parent
    return element
end

-- Apply corner radius
local function ApplyCorner(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = element
end

-- Apply gradient
local function ApplyGradient(element)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 50))
    })
    gradient.Rotation = 45
    gradient.Parent = element
end

-- Rainbow effect
local function RainbowEffect(element)
    while true do
        for hue = 0, 1, 0.01 do
            TweenService:Create(element, TweenInfo.new(0.05, Enum.EasingStyle.Linear), {TextColor3 = Color3.fromHSV(hue, 0.8, 1)}):Play()
            wait(0.05)
        end
    end
end

-- Create ScreenGui
local ScreenGui = CreateUIElement("ScreenGui", PlayerGui, {Name = "ROBANIKCheatMenu", ResetOnSpawn = false})

-- Key Frame
local KeyFrame = CreateUIElement("Frame", ScreenGui, {
    Size = UDim2.new(0, 300, 0, 180),
    Position = UDim2.new(0.5, -150, 0.5, -90),
    BackgroundColor3 = Color3.fromRGB(20, 20, 25),
    BackgroundTransparency = 0.3,
    Visible = KEY_SYSTEM_ENABLED
})
ApplyCorner(KeyFrame, 12)
ApplyGradient(KeyFrame)

local KeyLabel = CreateUIElement("TextLabel", KeyFrame, {
    Size = UDim2.new(0, 280, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundTransparency = 1,
    Text = "KeySystem",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold
})

local KeyTextBox = CreateUIElement("TextBox", KeyFrame, {
    Size = UDim2.new(0, 260, 0, 40),
    Position = UDim2.new(0, 20, 0, 50),
    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
    Text = "",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.Gotham
})
ApplyCorner(KeyTextBox, 8)

local KeySubmit = CreateUIElement("TextButton", KeyFrame, {
    Size = UDim2.new(0, 120, 0, 40),
    Position = UDim2.new(0, 20, 0, 100),
    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
    Text = "Submit",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.Gotham
})
ApplyCorner(KeySubmit, 8)

local KeyCopy = CreateUIElement("TextButton", KeyFrame, {
    Size = UDim2.new(0, 120, 0, 40),
    Position = UDim2.new(0, 160, 0, 100),
    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
    Text = "Copy Link",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 14,
    Font = Enum.Font.Gotham
})
ApplyCorner(KeyCopy, 8)

-- Main Frame
local MainFrame = CreateUIElement("Frame", ScreenGui, {
    Size = UDim2.new(0, 350, 0, 300),
    Position = UDim2.new(0.5, -175, 0.5, -150),
    BackgroundColor3 = Color3.fromRGB(20, 20, 25),
    BackgroundTransparency = 0.3,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Visible = not KEY_SYSTEM_ENABLED
})
ApplyCorner(MainFrame, 12)
ApplyGradient(MainFrame)

-- Watermark
local Watermark = CreateUIElement("TextLabel", ScreenGui, {
    Size = UDim2.new(0, 200, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
    BackgroundTransparency = 0.3,
    Text = "ROBANIK | UNIVERSAL",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 16,
    Font = Enum.Font.GothamBold
})
ApplyCorner(Watermark, 8)
coroutine.wrap(RainbowEffect)(Watermark)

-- Toggle Button
local ToggleButton = CreateUIElement("TextButton", ScreenGui, {
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0, 10, 0, 50),
    BackgroundColor3 = Color3.fromRGB(40, 40, 45),
    Text = "☰",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 20,
    Font = Enum.Font.Gotham,
    Visible = not KEY_SYSTEM_ENABLED
})
ApplyCorner(ToggleButton, 10)

-- Toggle Button Animations
ToggleButton.MouseEnter:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
end)
ToggleButton.MouseLeave:Connect(function()
    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
end)
ToggleButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
    local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, MainFrame.Visible and Enum.EasingDirection.Out or Enum.EasingDirection.In)
    TweenService:Create(MainFrame, tweenInfo, {
        Size = MainFrame.Visible and UDim2.new(0, 350, 0, 300) or UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = MainFrame.Visible and 0.3 or 1
    }):Play()
end)

-- Tab Frame
local TabFrame = CreateUIElement("Frame", MainFrame, {
    Size = UDim2.new(0, 100, 0, 280),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(25, 25, 30),
    BackgroundTransparency = 0.4
})
ApplyCorner(TabFrame, 8)

local TabLayout = CreateUIElement("UIListLayout", TabFrame, {Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder})

local CreatorLabel = CreateUIElement("TextLabel", TabFrame, {
    Size = UDim2.new(0, 100, 0, 20),
    Position = UDim2.new(0, 0, 1, -30),
    BackgroundTransparency = 1,
    Text = "BY ROBANIK",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    Font = Enum.Font.Gotham
})
coroutine.wrap(RainbowEffect)(CreatorLabel)

-- Content Frame
local ContentFrame = CreateUIElement("ScrollingFrame", MainFrame, {
    Size = UDim2.new(0, 220, 0, 280),
    Position = UDim2.new(0, 120, 0, 10),
    BackgroundTransparency = 1,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
})
local ContentLayout = CreateUIElement("UIListLayout", ContentFrame, {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)

-- Tab Management
local Tabs = {}
local CurrentTab = nil

local function CreateTab(name)
    local TabButton = CreateUIElement("TextButton", TabFrame, {
        Size = UDim2.new(0, 90, 0, 40),
        BackgroundColor3 = Color3.fromRGB(40, 40, 45),
        Text = name,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham
    })
    ApplyCorner(TabButton, 6)

    local TabContent = CreateUIElement("ScrollingFrame", MainFrame, {
        Size = UDim2.new(0, 220, 0, 280),
        Position = UDim2.new(0, 120, 0, 10),
        BackgroundTransparency = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255),
        Visible = false
    })
    local TabContentLayout = CreateUIElement("UIListLayout", TabContent, {Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder})
    TabContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContentLayout.AbsoluteContentSize.Y + 20)
    end)

    TabButton.MouseButton1Click:Connect(function()
        if CurrentTab then
            CurrentTab.Visible = false
            for _, tab in ipairs(Tabs) do
                TweenService:Create(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
            end
        end
        TabContent.Visible = true
        CurrentTab = TabContent
        TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)

    table.insert(Tabs, {Button = TabButton, Content = TabContent})
    return TabContent
end

local function CreateButton(parent, text, callback)
    local Button = CreateUIElement("TextButton", parent, {
        Size = UDim2.new(0, 200, 0, 40),
        BackgroundColor3 = Color3.fromRGB(40, 40, 45),
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham
    })
    ApplyCorner(Button, 8)
    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 45)}):Play()
    end)
    Button.MouseButton1Click:Connect(callback)
    return Button
end

local function CreateToggle(parent, text, callback)
    local ToggleFrame = CreateUIElement("Frame", parent, {Size = UDim2.new(0, 200, 0, 40), BackgroundTransparency = 1})
    CreateUIElement("TextLabel", ToggleFrame, {
        Size = UDim2.new(0, 140, 0, 40),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local ToggleButton = CreateUIElement("TextButton", ToggleFrame, {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(0, 150, 0, 10),
        BackgroundColor3 = Color3.fromRGB(80, 80, 80),
        Text = "OFF",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.Gotham
    })
    ApplyCorner(ToggleButton, 10)
    local isOn = false
    ToggleButton.MouseButton1Click:Connect(function()
        isOn = not isOn
        ToggleButton.Text = isOn and "ON" or "OFF"
        ToggleButton.BackgroundColor3 = isOn and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(80, 80, 80)
        callback(isOn)
    end)
    return ToggleFrame
end

local function CreateSlider(parent, text, min, max, callback)
    local SliderFrame = CreateUIElement("Frame", parent, {Size = UDim2.new(0, 200, 0, 60), BackgroundTransparency = 1})
    CreateUIElement("TextLabel", SliderFrame, {
        Size = UDim2.new(0, 140, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local ValueLabel = CreateUIElement("TextLabel", SliderFrame, {
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(0, 140, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(min),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham
    })
    local SliderBar = CreateUIElement("Frame", SliderFrame, {
        Size = UDim2.new(0, 180, 0, 10),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    })
    ApplyCorner(SliderBar, 5)
    local SliderFill = CreateUIElement("Frame", SliderBar, {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(100, 100, 255)
    })
    ApplyCorner(SliderFill, 5)
    local SliderButton = CreateUIElement("TextButton", SliderBar, {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = ""
    })
    local SliderValue, Dragging = min, false
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            SliderValue = math.floor(min + (max - min) * relativeX)
            TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
            ValueLabel.Text = tostring(SliderValue)
            callback(SliderValue)
        end
    end)
    SliderButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local relativeX = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
            SliderValue = math.floor(min + (max - min) * relativeX)
            TweenService:Create(SliderFill, TweenInfo.new(0.1), {Size = UDim2.new(relativeX, 0, 1, 0)}):Play()
            ValueLabel.Text = tostring(SliderValue)
            callback(SliderValue)
        end
    end)
    return SliderFrame
end

local function CreateTextBox(parent, text, callback)
    local TextBoxFrame = CreateUIElement("Frame", parent, {Size = UDim2.new(0, 200, 0, 40), BackgroundTransparency = 1})
    CreateUIElement("TextLabel", TextBoxFrame, {
        Size = UDim2.new(0, 80, 0, 40),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    local TextBox = CreateUIElement("TextBox", TextBoxFrame, {
        Size = UDim2.new(0, 110, 0, 30),
        Position = UDim2.new(0, 80, 0, 5),
        BackgroundColor3 = Color3.fromRGB(40, 40, 45),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Font = Enum.Font.Gotham
    })
    ApplyCorner(TextBox, 8)
    TextBox.FocusLost:Connect(function()
        callback(TextBox.Text)
    end)
    return TextBoxFrame
end

-- Key Logic
KeySubmit.MouseButton1Click:Connect(function()
    if IsValidKey(KeyTextBox.Text) then
        KeyFrame.Visible = false
        MainFrame.Visible = true
        ToggleButton.Visible = true
        print("Key accepted!")
    else
        KeyTextBox.Text = "Invalid Key"
        wait(1)
        KeyTextBox.Text = ""
    end
end)

KeyCopy.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(COPY_LINK)
        KeyCopy.Text = "Copied!"
        wait(1)
        KeyCopy.Text = "Copy Link"
    else
        print("Clipboard not supported")
    end
end)

-- Create Tabs
local EspTab = CreateTab("Esp")

--=================================--

CreateButton(EspTab, "esp def | on/off", function()
G.ToggleESP()
end)
