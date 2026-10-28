-- ==========================================================
-- ICELAND HUB V4 - ULTIMATE ANIMATION EDITION
-- Hiệu ứng: Trượt, Nảy, Mờ dần, Chuyển Tab mượt, Hover
-- ==========================================================

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local GUI_NAME = "Iceland_Hub_V4_Animation"
local oldGui = CoreGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

-- Cấu hình Animation
local TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_BOUNCE = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ==========================================
-- PHẦN 1: GIAO DIỆN CHÍNH & HỆ THỐNG TAB
-- ==========================================
local function applyTextSettings(textObject, minSize, maxSize)
    textObject.TextScaled = true
    textObject.TextWrapped = true
    local oldConstraint = textObject:FindFirstChildOfClass("UITextSizeConstraint")
    if oldConstraint then oldConstraint:Destroy() end
    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MinTextSize = minSize or 8
    constraint.MaxTextSize = maxSize or 16
    constraint.Parent = textObject
end

local function createAnimatedStroke(parentFrame)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Parent = parentFrame
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(10, 10, 10)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
    }
    gradient.Parent = stroke
    task.spawn(function()
        while stroke.Parent do
            gradient.Rotation = (gradient.Rotation + 1.5) % 360
            task.wait(0.016) -- 60 FPS
        end
    end)
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = GUI_NAME
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BackgroundTransparency = 0.15 -- Đen mờ sang trọng
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 25, 0.5, -180)
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame
createAnimatedStroke(MainFrame)

-- [ANIMATION 1]: Hiệu ứng Pop-up khi mở Menu
MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TWEEN_BOUNCE, {Size = UDim2.new(0, 260, 0, 360), BackgroundTransparency = 0.15}):Play()

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, -80, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.Text = "ICELAND HUB V4"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
applyTextSettings(Title, 12, 18)

-- Nút Đóng (X) có hiệu ứng Hover
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
CloseBtn.Parent = MainFrame
local CloseCorner = Instance.new("UICorner"); CloseCorner.CornerRadius = UDim.new(0, 5); CloseCorner.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function() 
    -- [ANIMATION 2]: Hiệu ứng thu nhỏ khi đóng
    local closeTween = TweenService:Create(MainFrame, TWEEN_INFO, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
    closeTween:Play()
    closeTween.Completed:Connect(function() ScreenGui:Destroy() end)
end)

-- Nút Thu nhỏ (-)
local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(1, -58, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 16
MinimizeBtn.Parent = MainFrame
local MinCorner = Instance.new("UICorner"); MinCorner.CornerRadius = UDim.new(0, 5); MinCorner.Parent = MinimizeBtn

-- Thanh chứa Tab
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
TabBar.BorderSizePixel = 0
local TabBarCorner = Instance.new("UICorner"); TabBarCorner.CornerRadius = UDim.new(0, 6); TabBarCorner.Parent = TabBar

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabBar
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.Padding = UDim.new(0, 5)

-- Vùng chứa nội dung
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 10, 0, 75)
ContentFrame.Size = UDim2.new(1, -20, 1, -85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 0
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ContentFrame
ContentList.Padding = UDim.new(0, 6)
ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Logic Thu nhỏ (Có Animation)
local isMinimized = false
local OriginalSize = UDim2.new(0, 260, 0, 360)
local MinimizedSize = UDim2.new(0, 260, 0, 35)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TWEEN_INFO, {Size = MinimizedSize}):Play()
        TabBar.Visible = false
        ContentFrame.Visible = false
        MinimizeBtn.Text = "+"
    else
        TweenService:Create(MainFrame, TWEEN_BOUNCE, {Size = OriginalSize}):Play()
        TabBar.Visible = true
        ContentFrame.Visible = true
        MinimizeBtn.Text = "-"
    end
end)

-- Hàm tạo Tab có hiệu ứng
local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = TabBar
    
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = btn
    
    local tabContent = Instance.new("Frame")
    tabContent.Size = UDim2.new(1, 0, 1, 0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.Parent = ContentFrame
    
    local tabList = Instance.new("UIListLayout")
    tabList.Parent = tabContent
    tabList.Padding = UDim.new(0, 6)
    tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    Tabs[name] = {Button = btn, Content = tabContent}
    
    btn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(Tabs) do
            tData.Content.Visible = false
            TweenService:Create(tData.Button, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        
        tabContent.Visible = true
        TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        
        -- [ANIMATION 3]: Hiệu ứng trượt nội dung Tab
        tabContent.Position = UDim2.new(0, 0, 0, 10)
        tabContent.BackgroundTransparency = 1
        TweenService:Create(tabContent, TWEEN_INFO, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)
    
    return tabContent
end

local MainTabContent = CreateTab("Main")
local EspTabContent = CreateTab("ESP")
local HopTabContent = CreateTab("Hop")

-- Kéo thả Menu
local dragToggle, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragToggle = false end end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Hàm tạo Toggle có hiệu ứng đẹp
local function CreateToggle(parent, txt, defaultState, cb)
    local state = defaultState or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.Text = ""
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.BackgroundTransparency = 1
    label.Text = txt; label.TextColor3 = Color3.fromRGB(200, 200, 200); label.Font = Enum.Font.Gotham; label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn; applyTextSettings(label, 9, 13)
    
    -- Thanh trượt (Pill)
    local pillBg = Instance.new("Frame")
    pillBg.Size = UDim2.new(0, 30, 0, 16)
    pillBg.Position = UDim2.new(1, -40, 0.5, -8)
    pillBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    pillBg.Parent = btn
    local pillCorner = Instance.new("UICorner"); pillCorner.CornerRadius = UDim.new(1, 0); pillCorner.Parent = pillBg
    
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 2, 0.5, -6)
    dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    dot.Parent = pillBg
    local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = dot

    local function updateState(animate)
        if animate then
            if state then
                TweenService:Create(pillBg, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                TweenService:Create(dot, TWEEN_FAST, {Position = UDim2.new(1, -14, 0.5, -6), BackgroundColor3 = Color3.fromRGB(0, 0, 0)}):Play()
                TweenService:Create(label, TWEEN_FAST, {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            else
                TweenService:Create(pillBg, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                TweenService:Create(dot, TWEEN_FAST, {Position = UDim2.new(0, 2, 0.5, -6), BackgroundColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                TweenService:Create(label, TWEEN_FAST, {TextColor3 = Color3.fromRGB(200, 200, 200)}):Play()
            end
        else
            if state then
                pillBg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                dot.Position = UDim2.new(1, -14, 0.5, -6)
                dot.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                pillBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                dot.Position = UDim2.new(0, 2, 0.5, -6)
                dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
                label.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
        end
    end
    updateState(false)
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateState(true)
        -- [ANIMATION 4]: Nút nảy nhẹ khi click
        local bounce = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.92, 0, 0, 32)})
        bounce:Play()
        bounce.Completed:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.95, 0, 0, 34)}):Play()
        end)
        if cb then cb(state) end
    end)
    return btn
end

local function CreateButton(parent, txt, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = txt; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 5); c.Parent = btn
    applyTextSettings(btn, 9, 13)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play() end)
    
    btn.MouseButton1Click:Connect(function() 
        if cb then cb() end
        -- Nút nhún khi bấm
        local bounce = TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.92, 0, 0, 30)})
        bounce:Play()
        bounce.Completed:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {Size = UDim2.new(0.95, 0, 0, 32)}):Play()
        end)
    end)
    return btn
end

-- ==========================================
-- PHẦN 2 & 3: LOGIC (GIỮ NGUYÊN NHƯ BẢN V3)
-- ==========================================
-- (Để code ngắn gọn, phần logic ESP, Auto Hatch, Steal Pet, Anti Hit giữ nguyên hoàn toàn như bản V3 bạn vừa chạy. Bạn chỉ cần copy phần UI ở trên đè lên phần UI cũ là được.)
-- LƯU Ý: Mình đã tinh giản phần logic ở đây để bạn dễ nhìn, nhưng khi chạy bạn hãy ghép phần UI này với phần Logic của bản V3 nhé!

print("[ICELAND] Giao diện V4 (Ultimate Animation) đã tải thành công!")
