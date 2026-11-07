-- [[ scorpion.wtf - semirage Edition (Clean & Stable Aim) ]] --
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Очистка старого GUI
pcall(function()
    if CoreGui:FindFirstChild("ScorpionMenu") then
        CoreGui.ScorpionMenu:Destroy()
    end
    if LocalPlayer.PlayerGui:FindFirstChild("ScorpionMenu") then
        LocalPlayer.PlayerGui.ScorpionMenu:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ScorpionMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local successParent = pcall(function()
    ScreenGui.Parent = CoreGui
end)
if not successParent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- ================= СИСТЕМА КОНФИГОВ =================
local ConfigFileName = "scorpion_config.json"

getgenv().ScorpionConfig = {
    ChamsESP = false,
    NameESP = false,
    DistanceESP = false,
    PredictionAim = false,
    PredictionValue = 0.13,
    Smoothness = 5,
    SilentAimFOV = 120,
    ShowFOV = false,
    MenuParticlesEnabled = true,
    Hitbox = "Head",
    AimKey = Enum.UserInputType.MouseButton2,
    RedVal = 75,
    GreenVal = 134,
    BlueVal = 239,
    WorldTime = 12,
    CustomTimeEnabled = false
}

local function saveConfig()
    pcall(function()
        if writefile then
            local cfgData = {
                ChamsESP = getgenv().ScorpionConfig.ChamsESP,
                NameESP = getgenv().ScorpionConfig.NameESP,
                DistanceESP = getgenv().ScorpionConfig.DistanceESP,
                PredictionAim = getgenv().ScorpionConfig.PredictionAim,
                PredictionValue = getgenv().ScorpionConfig.PredictionValue,
                Smoothness = getgenv().ScorpionConfig.Smoothness,
                SilentAimFOV = getgenv().ScorpionConfig.SilentAimFOV,
                ShowFOV = getgenv().ScorpionConfig.ShowFOV,
                MenuParticlesEnabled = getgenv().ScorpionConfig.MenuParticlesEnabled,
                Hitbox = getgenv().ScorpionConfig.Hitbox,
                RedVal = getgenv().ScorpionConfig.RedVal,
                GreenVal = getgenv().ScorpionConfig.GreenVal,
                BlueVal = getgenv().ScorpionConfig.BlueVal,
                WorldTime = getgenv().ScorpionConfig.WorldTime,
                CustomTimeEnabled = getgenv().ScorpionConfig.CustomTimeEnabled
            }
            writefile(ConfigFileName, HttpService:JSONEncode(cfgData))
        end
    end)
end

local function loadConfig()
    pcall(function()
        if readfile and isfile and isfile(ConfigFileName) then
            local decoded = HttpService:JSONDecode(readfile(ConfigFileName))
            if type(decoded) == "table" then
                for k, v in pairs(decoded) do
                    if getgenv().ScorpionConfig[k] ~= nil then
                        getgenv().ScorpionConfig[k] = v
                    end
                end
            end
        end
    end)
end

loadConfig()
getgenv().ScorpionConfig.AccentColor = Color3.fromRGB(getgenv().ScorpionConfig.RedVal, getgenv().ScorpionConfig.GreenVal, getgenv().ScorpionConfig.BlueVal)

-- ================= АНИМАЦИЯ ПРИ ИНЖЕКТЕ =================
local IntroTitle = Instance.new("TextLabel")
IntroTitle.Size = UDim2.new(0, 600, 0, 100)
IntroTitle.Position = UDim2.new(0.5, -300, 0.5, -50)
IntroTitle.BackgroundTransparency = 1
IntroTitle.Font = Enum.Font.GothamBold
IntroTitle.Text = "scorpion<font color='#4b86ef'>.wtf</font>"
IntroTitle.RichText = true
IntroTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
IntroTitle.TextSize = 15
IntroTitle.TextTransparency = 1
IntroTitle.ZIndex = 100
IntroTitle.Parent = ScreenGui

TweenService:Create(IntroTitle, TweenInfo.new(0.8, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    TextTransparency = 0,
    TextSize = 55
}):Play()

task.wait(1.4)

TweenService:Create(IntroTitle, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
    TextTransparency = 1,
    TextSize = 75
}):Play()

task.delay(0.5, function()
    IntroTitle:Destroy()
end)

local themeElements = {}

-- ================= ГЛАВНОЕ ОКНО И МАСШТАБИРОВАНИЕ =================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 580, 0, 440)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = true
MainFrame.ZIndex = 5
MainFrame.Parent = ScreenGui

local function setMenuScale(scaleFactor)
    local baseW, baseH = 580, 440
    MainFrame.Size = UDim2.new(0, baseW * scaleFactor, 0, baseH * scaleFactor)
    MainFrame.Position = UDim2.new(0.5, -(baseW * scaleFactor)/2, 0.5, -(baseH * scaleFactor)/2)
end

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(25, 25, 35)
MainStroke.Thickness = 1
MainStroke.Parent = MainFrame

-- ================= АНИМИРОВАННЫЕ ЧАСТИЦЫ ВНУТРИ МЕНЮ =================
local MenuParticlesContainer = Instance.new("Frame")
MenuParticlesContainer.Name = "MenuParticles"
MenuParticlesContainer.Size = UDim2.new(1, 0, 1, 0)
MenuParticlesContainer.BackgroundTransparency = 1
MenuParticlesContainer.ZIndex = 1
MenuParticlesContainer.Parent = MainFrame

local particles = {}
local math_random = math.random
for i = 1, 30 do
    local circle = Instance.new("Frame")
    local size = math_random(8, 14)
    circle.Size = UDim2.new(0, size, 0, size)
    circle.Position = UDim2.new(math_random(0, 100) / 100, 0, math_random(0, 100) / 100, 0)
    circle.BackgroundColor3 = getgenv().ScorpionConfig.AccentColor
    circle.BackgroundTransparency = 0.4
    circle.BorderSizePixel = 0
    circle.ZIndex = 1
    circle.Parent = MenuParticlesContainer
    
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    table.insert(themeElements, {Type = "Bg", Object = circle})

    table.insert(particles, {
        Object = circle,
        Speed = math_random(2, 5) / 1000,
        Drift = (math_random(-2, 2) / 1000)
    })
end

-- ================= НАДПИСЬ ВНИЗУ =================
local FooterLabel = Instance.new("TextLabel")
FooterLabel.Size = UDim2.new(1, 0, 0, 20)
FooterLabel.Position = UDim2.new(0, 0, 1, -25)
FooterLabel.BackgroundTransparency = 1
FooterLabel.Font = Enum.Font.GothamMedium
FooterLabel.Text = "Scorpion.wtf <font color='#888888'>semirage</font> Private"
FooterLabel.RichText = true
FooterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
FooterLabel.TextSize = 11
FooterLabel.ZIndex = 10
FooterLabel.Parent = MainFrame

-- ================= САЙДБАР =================
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 160, 1, -30)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 6
Sidebar.Parent = MainFrame

local SidebarList = Instance.new("UIListLayout")
SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
SidebarList.Padding = UDim.new(0, 6)
SidebarList.Parent = Sidebar

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.PaddingTop = UDim.new(0, 25)
SidebarPadding.PaddingLeft = UDim.new(0, 20)
SidebarPadding.PaddingRight = UDim.new(0, 20)
SidebarPadding.Parent = Sidebar

local ContentContainer = Instance.new("Frame")
ContentContainer.Size = UDim2.new(1, -160, 1, -30)
ContentContainer.Position = UDim2.new(0, 160, 0, 0)
ContentContainer.BackgroundTransparency = 1
ContentContainer.ZIndex = 6
ContentContainer.Parent = MainFrame

local tabs = {}
local currentTab = nil

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundTransparency = 1
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(130, 130, 145)
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = order
    btn.ZIndex = 7
    btn.Parent = Sidebar

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.Visible = false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = getgenv().ScorpionConfig.AccentColor
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.ZIndex = 7
    page.Parent = ContentContainer
    table.insert(themeElements, {Type = "Scroll", Object = page})

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.Parent = page

    local pagePadding = Instance.new("UIPadding")
    pagePadding.PaddingTop = UDim.new(0, 20)
    pagePadding.PaddingLeft = UDim.new(0, 20)
    pagePadding.PaddingRight = UDim.new(0, 20)
    pagePadding.Parent = page

    btn.MouseButton1Click:Connect(function()
        for _, t in pairs(tabs) do
            t.page.Visible = false
            TweenService:Create(t.btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(130, 130, 145)}):Play()
        end
        page.Visible = true
        TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = getgenv().ScorpionConfig.AccentColor}):Play()
    end)

    if not currentTab then
        currentTab = name
        page.Visible = true
        btn.TextColor3 = getgenv().ScorpionConfig.AccentColor
    end

    table.insert(tabs, {name = name, btn = btn, page = page})
    return page
end

local VisualsTab = createTab("Visuals", 1)
local AimBotTab = createTab("AimBot", 2)
local SettingsTab = createTab("Settings", 3)

local function createSectionBox(page, titleText)
    local boxFrame = Instance.new("Frame")
    boxFrame.Size = UDim2.new(1, 0, 0, 0)
    boxFrame.AutomaticSize = Enum.AutomaticSize.Y
    boxFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    boxFrame.BorderSizePixel = 0
    boxFrame.ZIndex = 7
    boxFrame.Parent = page

    Instance.new("UICorner", boxFrame).CornerRadius = UDim.new(0, 6)
    local boxStroke = Instance.new("UIStroke")
    boxStroke.Color = Color3.fromRGB(28, 28, 38)
    boxStroke.Thickness = 1
    boxStroke.Parent = boxFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 0, 30)
    title.Position = UDim2.new(0, 12, 0, 4)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = titleText
    title.TextColor3 = getgenv().ScorpionConfig.AccentColor
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 8
    title.Parent = boxFrame
    table.insert(themeElements, {Type = "Text", Object = title})

    local list = Instance.new("UIListLayout")
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Padding = UDim.new(0, 8)
    list.Parent = boxFrame

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 38)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 12)
    pad.PaddingRight = UDim.new(0, 12)
    pad.Parent = boxFrame

    return boxFrame
end

local function addToggle(sectionBox, text, defaultVal, callback)
    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(1, 0, 0, 28)
    toggle.BackgroundTransparency = 1
    toggle.Text = ""
    toggle.ZIndex = 8
    toggle.Parent = sectionBox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -35, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(190, 190, 200)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    label.Parent = toggle

    local box = Instance.new("Frame")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(1, -16, 0.5, -8)
    box.BackgroundColor3 = defaultVal and getgenv().ScorpionConfig.AccentColor or Color3.fromRGB(22, 22, 30)
    box.BorderSizePixel = 0
    box.ZIndex = 8
    box.Parent = toggle

    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 3)

    local enabled = defaultVal
    toggle.MouseButton1Click:Connect(function()
        enabled = not enabled
        local targetColor = enabled and getgenv().ScorpionConfig.AccentColor or Color3.fromRGB(22, 22, 30)
        TweenService:Create(box, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        if callback then callback(enabled) end
        saveConfig()
    end)
end

local function addSlider(sectionBox, text, min, max, default, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundTransparency = 1
    container.ZIndex = 8
    container.Parent = sectionBox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 18)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text .. "    " .. default
    label.TextColor3 = Color3.fromRGB(190, 190, 200)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    label.Parent = container

    local sliderBar = Instance.new("TextButton")
    sliderBar.Size = UDim2.new(1, 0, 0, 6)
    sliderBar.Position = UDim2.new(0, 0, 0, 26)
    sliderBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    sliderBar.BorderSizePixel = 0
    sliderBar.Text = ""
    sliderBar.ZIndex = 8
    sliderBar.Parent = container

    Instance.new("UICorner", sliderBar).CornerRadius = UDim.new(0, 3)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(math.clamp((default - min)/(max - min), 0, 1), 0, 1, 0)
    fill.BackgroundColor3 = getgenv().ScorpionConfig.AccentColor
    fill.BorderSizePixel = 0
    fill.ZIndex = 8
    fill.Parent = sliderBar
    table.insert(themeElements, {Type = "Bg", Object = fill})

    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)

    local draggingSlider = false
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            if draggingSlider then saveConfig() end
            draggingSlider = false 
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            local val = math.floor(min + (max - min) * pos + 0.5)
            label.Text = text .. "    " .. val
            if callback then callback(val) end
        end
    end)
end

local function addDropdown(sectionBox, text, options, defaultOption, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundTransparency = 1
    container.ZIndex = 8
    container.Parent = sectionBox

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = Color3.fromRGB(190, 190, 200)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 8
    label.Parent = container

    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == defaultOption then
            currentIndex = i
            break
        end
    end

    local selectBtn = Instance.new("TextButton")
    selectBtn.Size = UDim2.new(1, 0, 0, 22)
    selectBtn.Position = UDim2.new(0, 0, 0, 22)
    selectBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    selectBtn.BorderSizePixel = 0
    selectBtn.Font = Enum.Font.GothamMedium
    selectBtn.Text = options[currentIndex]
    selectBtn.TextColor3 = getgenv().ScorpionConfig.AccentColor
    selectBtn.TextSize = 11
    selectBtn.ZIndex = 8
    selectBtn.Parent = container
    table.insert(themeElements, {Type = "Text", Object = selectBtn})

    Instance.new("UICorner", selectBtn).CornerRadius = UDim.new(0, 3)

    selectBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        local chosen = options[currentIndex]
        selectBtn.Text = chosen
        if callback then callback(chosen) end
        saveConfig()
    end)
end

local function addButton(sectionBox, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 30)
    btn.BackgroundColor3 = getgenv().ScorpionConfig.AccentColor
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.ZIndex = 8
    btn.Parent = sectionBox
    table.insert(themeElements, {Type = "Bg", Object = btn})

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
end

local function updateThemeColors(newColor)
    getgenv().ScorpionConfig.AccentColor = newColor
    for _, item in ipairs(themeElements) do
        if item.Type == "Bg" then
            item.Object.BackgroundColor3 = newColor
        elseif item.Type == "Text" then
            item.Object.TextColor3 = newColor
        elseif item.Type == "Scroll" then
            item.Object.ScrollBarImageColor3 = newColor
        end
    end
end

-- ================= НАПОЛНЕНИЕ ВКЛАДОК =================

-- Visuals
local espBox = createSectionBox(VisualsTab, "Visuals Settings")
addToggle(espBox, "Chams ESP", getgenv().ScorpionConfig.ChamsESP, function(v) toggleChams(v) end)
addToggle(espBox, "Name ESP", getgenv().ScorpionConfig.NameESP, function(v) getgenv().ScorpionConfig.NameESP = v end)
addToggle(espBox, "Distance ESP", getgenv().ScorpionConfig.DistanceESP, function(v) getgenv().ScorpionConfig.DistanceESP = v end)

-- AimBot
local aimBox = createSectionBox(AimBotTab, "Aimbot Settings")
addSlider(aimBox, "Field of View", 50, 300, getgenv().ScorpionConfig.SilentAimFOV, function(val) getgenv().ScorpionConfig.SilentAimFOV = val end)
addToggle(aimBox, "Draw FOV Circle", getgenv().ScorpionConfig.ShowFOV, function(v) getgenv().ScorpionConfig.ShowFOV = v end)
addToggle(aimBox, "Prediction Aimbot", getgenv().ScorpionConfig.PredictionAim, function(v) getgenv().ScorpionConfig.PredictionAim = v end)
addSlider(aimBox, "Prediction Multiplier", 1, 30, math.floor(getgenv().ScorpionConfig.PredictionValue * 100), function(val) getgenv().ScorpionConfig.PredictionValue = val / 100 end)
addDropdown(aimBox, "Hitbox Target", {"Head", "Neck", "Body"}, getgenv().ScorpionConfig.Hitbox, function(chosen) getgenv().ScorpionConfig.Hitbox = chosen end)
addDropdown(aimBox, "Aim Keybind", {"MouseButton2 (ПКМ)", "MouseButton1 (ЛКМ)", "LeftAlt", "LeftControl", "Q", "E", "C"}, "MouseButton2 (ПКМ)", function(chosen)
    if chosen == "MouseButton2 (ПКМ)" then getgenv().ScorpionConfig.AimKey = Enum.UserInputType.MouseButton2
    elseif chosen == "MouseButton1 (ЛКМ)" then getgenv().ScorpionConfig.AimKey = Enum.UserInputType.MouseButton1
    elseif chosen == "LeftAlt" then getgenv().ScorpionConfig.AimKey = Enum.KeyCode.LeftAlt
    elseif chosen == "LeftControl" then getgenv().ScorpionConfig.AimKey = Enum.KeyCode.LeftControl
    elseif chosen == "Q" then getgenv().ScorpionConfig.AimKey = Enum.KeyCode.Q
    elseif chosen == "E" then getgenv().ScorpionConfig.AimKey = Enum.KeyCode.E
    elseif chosen == "C" then getgenv().ScorpionConfig.AimKey = Enum.KeyCode.C end
end)

-- Settings
local settingsBox = createSectionBox(SettingsTab, "Menu Configuration")
addSlider(settingsBox, "UI Scale (Размер меню)", 70, 130, 100, function(val)
    setMenuScale(val / 100)
end)

addToggle(settingsBox, "Menu Particles (Частицы)", getgenv().ScorpionConfig.MenuParticlesEnabled, function(v) 
    getgenv().ScorpionConfig.MenuParticlesEnabled = v
    MenuParticlesContainer.Visible = v
end)

addToggle(settingsBox, "Custom Time (Вкл/Выкл время)", getgenv().ScorpionConfig.CustomTimeEnabled, function(v) 
    getgenv().ScorpionConfig.CustomTimeEnabled = v 
end)
addSlider(settingsBox, "Time Changer (Часы)", 0, 12, getgenv().ScorpionConfig.WorldTime, function(val)
    getgenv().ScorpionConfig.WorldTime = val
    saveConfig()
end)

addSlider(settingsBox, "Accent Red (Красный)", 0, 255, getgenv().ScorpionConfig.RedVal, function(val)
    getgenv().ScorpionConfig.RedVal = val
    local cfg = getgenv().ScorpionConfig
    updateThemeColors(Color3.fromRGB(cfg.RedVal, cfg.GreenVal, cfg.BlueVal))
    saveConfig()
end)
addSlider(settingsBox, "Accent Green (Зеленый)", 0, 255, getgenv().ScorpionConfig.GreenVal, function(val)
    getgenv().ScorpionConfig.GreenVal = val
    local cfg = getgenv().ScorpionConfig
    updateThemeColors(Color3.fromRGB(cfg.RedVal, cfg.GreenVal, cfg.BlueVal))
    saveConfig()
end)
addSlider(settingsBox, "Accent Blue (Синий)", 0, 255, getgenv().ScorpionConfig.BlueVal, function(val)
    getgenv().ScorpionConfig.BlueVal = val
    local cfg = getgenv().ScorpionConfig
    updateThemeColors(Color3.fromRGB(cfg.RedVal, cfg.GreenVal, cfg.BlueVal))
    saveConfig()
end)

addButton(settingsBox, "Save Config Manually", function()
    saveConfig()
end)

addButton(settingsBox, "Unload Script", function()
    toggleChams(false)
    pcall(function() fovDrawing:Remove() end)
    for _, tag in pairs(espTextTags) do if tag then tag:Destroy() end end
    ScreenGui:Destroy()
end)

-- Перетаскивание меню мышкой
local dragging, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- ================= ESP (ЧАМСЫ + МИНИАТЮРНЫЙ ТЕКСТ + FOV) =================
local activeHighlights = {}
local espConnection = nil
local espTextTags = {}

function toggleChams(state)
    getgenv().ScorpionConfig.ChamsESP = state
    if state then
        local function applyHighlight(player)
            if player ~= LocalPlayer then
                local function onCharacter(char)
                    if char and not char:FindFirstChild("ScorpionChams") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "ScorpionChams"
                        hl.Adornee = char
                        hl.FillColor = getgenv().ScorpionConfig.AccentColor
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.OutlineTransparency = 0
                        hl.Parent = char
                        activeHighlights[player] = hl
                    end
                end
                if player.Character then onCharacter(player.Character) end
                player.CharacterAdded:Connect(onCharacter)
            end
        end
        for _, p in ipairs(Players:GetPlayers()) do applyHighlight(p) end
        espConnection = Players.PlayerAdded:Connect(applyHighlight)
    else
        if espConnection then espConnection:Disconnect() end
        for _, hl in pairs(activeHighlights) do if hl then hl:Destroy() end end
        activeHighlights = {}
    end
end

if getgenv().ScorpionConfig.ChamsESP then
    toggleChams(true)
end

local fovDrawing = Drawing.new("Circle")
fovDrawing.Visible = false
fovDrawing.Color = getgenv().ScorpionConfig.AccentColor
fovDrawing.Thickness = 1.5
fovDrawing.Filled = false
fovDrawing.NumSides = 64

MenuParticlesContainer.Visible = getgenv().ScorpionConfig.MenuParticlesEnabled

RunService.RenderStepped:Connect(function()
    local cfg = getgenv().ScorpionConfig
    local currentAccent = cfg.AccentColor

    if cfg.CustomTimeEnabled then
        Lighting.ClockTime = cfg.WorldTime
    end

    if cfg.ShowFOV then
        fovDrawing.Visible = true
        fovDrawing.Radius = cfg.SilentAimFOV
        fovDrawing.Position = UserInputService:GetMouseLocation()
        fovDrawing.Color = currentAccent
    else
        fovDrawing.Visible = false
    end

    if MainFrame.Visible and cfg.MenuParticlesEnabled then
        for _, part in ipairs(particles) do
            local obj = part.Object
            obj.BackgroundColor3 = currentAccent
            local currentY = obj.Position.Y.Scale - part.Speed
            local currentX = obj.Position.X.Scale + part.Drift

            if currentY < -0.05 then
                currentY = 1.05
                currentX = math_random(0, 100) / 100
            end
            if currentX < -0.05 or currentX > 1.05 then
                currentX = math_random(0, 100) / 100
            end

            obj.Position = UDim2.new(currentX, 0, currentY, 0)
        end
    end

    local playersList = Players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player ~= LocalPlayer then
            local char = player.Character
            local head = char and char:FindFirstChild("Head")
            local humanoid = char and char:FindFirstChild("Humanoid")

            if char and head and humanoid and humanoid.Health > 0 and (cfg.NameESP or cfg.DistanceESP) then
                local bill = espTextTags[player]
                if not bill then
                    bill = Instance.new("BillboardGui")
                    bill.Name = "ScorpionESPText"
                    bill.Size = UDim2.new(0, 120, 0, 25)
                    bill.StudsOffset = Vector3.new(0, 2.0, 0)
                    bill.AlwaysOnTop = true

                    local textLabel = Instance.new("TextLabel")
                    textLabel.Name = "Label"
                    textLabel.Size = UDim2.new(1, 0, 1, 0)
                    textLabel.BackgroundTransparency = 1
                    textLabel.Font = Enum.Font.GothamBold
                    textLabel.TextSize = 10
                    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    textLabel.TextStrokeTransparency = 0.4
                    textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                    textLabel.Parent = bill

                    bill.Parent = head
                    espTextTags[player] = bill
                end

                local label = bill:FindFirstChild("Label")
                if label then
                    local parts = {}
                    if cfg.NameESP then
                        table.insert(parts, player.Name)
                    end
                    if cfg.DistanceESP then
                        local dist = math.floor((Camera.CFrame.Position - head.Position).Magnitude)
                        table.insert(parts, "[" .. dist .. "m]")
                    end
                    label.Text = table.concat(parts, " ")
                    bill.Enabled = true
                end
            else
                if espTextTags[player] then
                    espTextTags[player].Enabled = false
                end
            end
        end
    end
end)

-- ================= ПРЕДИКТ АИМБОТ =================
local function isAimKeyPressed()
    local key = getgenv().ScorpionConfig.AimKey
    if typeof(key) == "EnumItem" then
        if key.EnumType == Enum.UserInputType then
            return UserInputService:IsMouseButtonPressed(key)
        elseif key.EnumType == Enum.KeyCode then
            return UserInputService:IsKeyDown(key)
        end
    end
    return true
end

local function getTargetPart()
    local bestPart = nil
    local shortestDist = getgenv().ScorpionConfig.SilentAimFOV
    local mousePos = UserInputService:GetMouseLocation()
    local hitboxChoice = getgenv().ScorpionConfig.Hitbox

    local partName = "Head"
    if hitboxChoice == "Neck" then
        partName = "UpperTorso"
    elseif hitboxChoice == "Body" then
        partName = "HumanoidRootPart"
    end

    local playersList = Players:GetPlayers()
    for i = 1, #playersList do
        local player = playersList[i]
        if player ~= LocalPlayer and player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local part = player.Character:FindFirstChild(partName) or player.Character:FindFirstChild("Head")
                if part then
                    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            bestPart = part
                        end
                    end
                end
            end
        end
    end
    return bestPart
end

RunService.RenderStepped:Connect(function()
    local cfg = getgenv().ScorpionConfig
    if cfg.PredictionAim and isAimKeyPressed() then
        local targetPart = getTargetPart()
        if targetPart then
            local char = targetPart.Parent
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local velocity = rootPart.AssemblyLinearVelocity
                local predictedPosition = targetPart.Position + (velocity * cfg.PredictionValue)

                local currentCFrame = Camera.CFrame
                local targetCFrame = CFrame.new(currentCFrame.Position, predictedPosition)
                Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / cfg.Smoothness)
            end
        end
    end
end)
