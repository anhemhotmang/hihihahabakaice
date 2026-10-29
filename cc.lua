-- ==========================================================
-- ICELAND HUB V5.0 - FULL SCRIPT (KHÔNG TỐI ƯU - FULL FEATURES)
-- Bao gồm: UI Animation, Tabs, ESP, Auto Hatch, Steal Egg/Pet, 
-- Anti Văng, Xem trước trứng, Hop Server nâng cao, Nút Copy Discord
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
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local GUI_NAME = "Iceland_Hub_V5_Full"
local oldGui = CoreGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

local TWEEN_INFO = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local TWEEN_BOUNCE = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_FAST = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- ==========================================
-- PHẦN 1: GIAO DIỆN & ANIMATION
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
            task.wait(0.016)
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
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 25, 0.5, -180)
MainFrame.Size = UDim2.new(0, 260, 0, 380)
MainFrame.Active = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
createAnimatedStroke(MainFrame)

MainFrame.Size = UDim2.new(0, 0, 0, 0)
MainFrame.BackgroundTransparency = 1
TweenService:Create(MainFrame, TWEEN_BOUNCE, {Size = UDim2.new(0, 260, 0, 380), BackgroundTransparency = 0.15}):Play()

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -80, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 5)
Title.Text = "ICELAND HUB V5.0"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
applyTextSettings(Title, 12, 18)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

CloseBtn.MouseEnter:Connect(function() TweenService:Create(CloseBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play() end)
CloseBtn.MouseLeave:Connect(function() TweenService:Create(CloseBtn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play() end)
CloseBtn.MouseButton1Click:Connect(function() 
    local closeTween = TweenService:Create(MainFrame, TWEEN_INFO, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1})
    closeTween:Play()
    closeTween.Completed:Connect(function() ScreenGui:Destroy() end)
end)

local MinimizeBtn = Instance.new("TextButton", MainFrame)
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(1, -58, 0, 6)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 5)

local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local TabList = Instance.new("UIListLayout", TabBar)
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.Padding = UDim.new(0, 5)

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.Position = UDim2.new(0, 10, 0, 75)
ContentFrame.Size = UDim2.new(1, -20, 1, -85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 0
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ClipsDescendants = true

local ContentList = Instance.new("UIListLayout", ContentFrame)
ContentList.Padding = UDim.new(0, 6)
ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local isMinimized = false
local OriginalSize = UDim2.new(0, 260, 0, 380)
local MinimizedSize = UDim2.new(0, 260, 0, 35)

MinimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TWEEN_INFO, {Size = MinimizedSize}):Play()
        TabBar.Visible = false; ContentFrame.Visible = false; MinimizeBtn.Text = "+"
    else
        TweenService:Create(MainFrame, TWEEN_BOUNCE, {Size = OriginalSize}):Play()
        TabBar.Visible = true; ContentFrame.Visible = true; MinimizeBtn.Text = "-"
    end
end)

local Tabs = {}
local function CreateTab(name)
    local btn = Instance.new("TextButton", TabBar)
    btn.Size = UDim2.new(0.3, 0, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = name; btn.TextColor3 = Color3.fromRGB(150, 150, 150); btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    
    local tabContent = Instance.new("Frame", ContentFrame)
    tabContent.Size = UDim2.new(1, 0, 1, 0); tabContent.BackgroundTransparency = 1; tabContent.Visible = false
    local tabList = Instance.new("UIListLayout", tabContent)
    tabList.Padding = UDim.new(0, 6); tabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    Tabs[name] = {Button = btn, Content = tabContent}
    btn.MouseButton1Click:Connect(function()
        for _, tData in pairs(Tabs) do
            tData.Content.Visible = false
            TweenService:Create(tData.Button, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(35, 35, 35), TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
        end
        tabContent.Visible = true
        TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(255, 255, 255), TextColor3 = Color3.fromRGB(0, 0, 0)}):Play()
        tabContent.Position = UDim2.new(0, 0, 0, 10)
        TweenService:Create(tabContent, TWEEN_INFO, {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)
    return tabContent
end

local MainTabContent = CreateTab("Main")
local EspTabContent = CreateTab("ESP")
local HopTabContent = CreateTab("Hop")

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

local function CreateToggle(parent, txt, defaultState, cb)
    local state = defaultState or false
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 34); btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22); btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -50, 1, 0); label.Position = UDim2.new(0, 12, 0, 0); label.BackgroundTransparency = 1
    label.Text = txt; label.TextColor3 = Color3.fromRGB(200, 200, 200); label.Font = Enum.Font.Gotham; label.TextXAlignment = Enum.TextXAlignment.Left
    applyTextSettings(label, 9, 13)
    
    local pillBg = Instance.new("Frame", btn)
    pillBg.Size = UDim2.new(0, 30, 0, 16); pillBg.Position = UDim2.new(1, -40, 0.5, -8); pillBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", pillBg).CornerRadius = UDim.new(1, 0)
    
    local dot = Instance.new("Frame", pillBg)
    dot.Size = UDim2.new(0, 12, 0, 12); dot.Position = UDim2.new(0, 2, 0.5, -6); dot.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

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
        end
    end
    updateState(false)
    
    btn.MouseButton1Click:Connect(function()
        state = not state; updateState(true)
        local bounce = TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.92, 0, 0, 32)}); bounce:Play()
        bounce.Completed:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 34)}):Play() end)
        if cb then cb(state) end
    end)
    return btn
end

local function CreateButton(parent, txt, cb)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0.95, 0, 0, 32); btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = txt; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5); applyTextSettings(btn, 9, 13)
    
    btn.MouseEnter:Connect(function() TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn, TWEEN_FAST, {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play() end)
    btn.MouseButton1Click:Connect(function() 
        if cb then cb() end
        local bounce = TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.92, 0, 0, 30)}); bounce:Play()
        bounce.Completed:Connect(function() TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0.95, 0, 0, 32)}):Play() end)
    end)
    return btn
end

-- ==========================================
-- PHẦN 2: LOGIC TÍNH NĂNG
-- ==========================================
local espEnabled, autoHatchEnabled, instantCollectEnabled, equipBestEnabled = false, false, false, false
local autoRebirthEnabled, smartStealEnabled, antiHitEnabled, autoRetaliateEnabled = false, false, false, false
local eggPreviewEnabled = false
local espDrawings = {}

local function GetServerList()
    local servers = {}
    local success, pages = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and pages and pages.data then
        for _, server in ipairs(pages.data) do table.insert(servers, server) end
    end
    return servers
end

local function removeESP(player)
    if espDrawings[player] then
        if espDrawings[player].Box then espDrawings[player].Box:Remove() end
        if espDrawings[player].Tracer then espDrawings[player].Tracer:Remove() end
        espDrawings[player] = nil
    end
end

local function setupESP(player)
    if player == LocalPlayer then return end
    local box = Drawing.new("Square")
    box.Visible = false; box.Color = Color3.fromRGB(255, 255, 255); box.Thickness = 1; box.Filled = false
    local tracer = Drawing.new("Line")
    tracer.Visible = false; tracer.Color = Color3.fromRGB(255, 255, 255); tracer.Thickness = 1
    espDrawings[player] = {Box = box, Tracer = tracer}
end

Players.PlayerAdded:Connect(setupESP)
Players.PlayerRemoving:Connect(removeESP)
for _, player in ipairs(Players:GetPlayers()) do setupESP(player) end

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, drawings in pairs(espDrawings) do drawings.Box.Visible = false; drawings.Tracer.Visible = false end
        return
    end
    for player, drawings in pairs(espDrawings) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local head = character and character:FindFirstChild("Head")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        
        if character and hrp and head and humanoid and humanoid.Health > 0 then
            local rootPos = hrp.Position
            local topPos = rootPos + Vector3.new(0, 3, 0)
            local bottomPos = rootPos - Vector3.new(0, 3.5, 0)
            local topScreen, topOnScreen = Camera:WorldToViewportPoint(topPos)
            local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomPos)
            local headScreen, headOnScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            
            if topOnScreen or bottomOnScreen then
                local height = math.abs(topScreen.Y - bottomScreen.Y)
                local width = height / 2
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(topScreen.X - width / 2, topScreen.Y)
                drawings.Box.Visible = true
                
                if headOnScreen then
                    drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                    drawings.Tracer.To = Vector2.new(headScreen.X, headScreen.Y)
                    drawings.Tracer.Visible = true
                else
                    drawings.Tracer.Visible = false
                end
            else
                drawings.Box.Visible = false
                drawings.Tracer.Visible = false
            end
        else
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
        end
    end
end)

local function getMyBasePart()
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then return nil end
    local accountName = LocalPlayer.Name:lower()
    local displayName = LocalPlayer.DisplayName:lower()
    for i = 1, 10 do
        local baseFolder = bases:FindFirstChild(tostring(i))
        if baseFolder then
            local sign = baseFolder:FindFirstChild("Sign")
            if sign and sign:FindFirstChild("Display") and sign.Display:FindFirstChild("BaseDisplayGui") then
                local frame = sign.Display.BaseDisplayGui:FindFirstChild("Frame")
                if frame and frame:FindFirstChild("Info") and frame.Info:FindFirstChild("PlayerName") then
                    local text = frame.Info.PlayerName.Text
                    if text then
                        local cleanText = text:match("^%s*(.-)%s*$"):lower()
                        if cleanText == accountName or cleanText == displayName or cleanText:find(accountName, 1, true) or cleanText:find(displayName, 1, true) then
                            local part = baseFolder:FindFirstChild("Part")
                            if part and part:IsA("BasePart") then return part end
                        end
                    end
                end
            end
        end
    end
    return nil
end

task.spawn(function()
    while true do
        if autoHatchEnabled then
            pcall(function()
                local nestEggs = Workspace:FindFirstChild("NestEggs")
                if nestEggs then
                    for _, child in ipairs(nestEggs:GetChildren()) do
                        if child:IsA("Model") then
                            local hatchPrompt = child:FindFirstChild("HatchPrompt", true)
                            if hatchPrompt and hatchPrompt:IsA("ProximityPrompt") then fireproximityprompt(hatchPrompt) end
                        end
                    end
                end
            end)
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    while true do
        if equipBestEnabled then
            pcall(function()
                local equipBestEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("EquipBestEvent")
                if equipBestEvent then equipBestEvent:FireServer() end
            end)
        end
        task.wait(1)
    end
end)

task.spawn(function()
    pcall(function()
        local eggRemotes = ReplicatedStorage:WaitForChild("EggRemotes", 8)
        if not eggRemotes then return end
        local eggEvent = eggRemotes:WaitForChild("EggEvent", 8)
        if not eggEvent then return end
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            if not instantCollectEnabled then return oldNamecall(self, ...) end
            local method = getnamecallmethod()
            local args = {...}
            if self == eggEvent and (method == "FireServer" or method == "InvokeServer") then
                if args[1] == "Buy" or args[1] == "Hatch" then
                    local result = oldNamecall(self, unpack(args))
                    task.spawn(function()
                        local character = LocalPlayer.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local originalCFrame = hrp.CFrame
                            local basePart = getMyBasePart()
                            if basePart then
                                task.wait(0.1)
                                hrp.CFrame = basePart.CFrame + Vector3.new(0, 3, 0)
                                hrp.Velocity = Vector3.zero
                                task.wait(0.1)
                                hrp.CFrame = originalCFrame
                            end
                        end
                    end)
                    return result
                end
            end
            return oldNamecall(self, ...)
        end)
    end)
end)

-- CƯỚP TRỨNG THÔNG MINH
task.spawn(function()
    while task.wait(0.3) do 
        if smartStealEnabled then
            pcall(function()
                local myChar = LocalPlayer.Character
                if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
                local myHRP = myChar.HumanoidRootPart
                local originalCFrame = myHRP.CFrame 
                
                local bestEgg, bestEggPart, bestPrompt = nil, nil, nil
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (string.find(obj.Name, "Egg") or obj.Name == "NestEgg") then
                        local eggPart = obj:FindFirstChildWhichIsA("BasePart")
                        if eggPart then
                            local prompt = eggPart:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                bestEgg = obj; bestEggPart = eggPart; bestPrompt = prompt
                                break 
                            end
                        end
                    end
                end
                
                if bestEgg and bestEggPart and bestPrompt then
                    myHRP.CFrame = bestEggPart.CFrame + Vector3.new(0, 3, 0) 
                    task.wait(0.2) 
                    fireproximityprompt(bestPrompt)
                    task.wait(0.5) 
                    
                    if not bestEgg.Parent then
                        local basePart = getMyBasePart()
                        if basePart then
                            myHRP.CFrame = basePart.CFrame + Vector3.new(0, 5, 0)
                            myHRP.Velocity = Vector3.zero
                        else
                            myHRP.CFrame = originalCFrame
                        end
                    else
                        fireproximityprompt(bestPrompt)
                        task.wait(0.3)
                    end
                    task.wait(0.5) 
                end
            end)
        end
    end
end)

-- ANTI VĂNG
local savedPosition = nil
local function EnableAntiHit()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if humanoid and root then
        humanoid.MaxHealth = math.huge; humanoid.Health = math.huge
        humanoid.PlatformStand = false; humanoid.Sit = false
        root.Massless = false
        root.CustomPhysicalProperties = PhysicalProperties.new(100000, 0.3, 0.5)
        savedPosition = root.CFrame
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if antiHitEnabled then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") then
                if char.Humanoid.MoveDirection.Magnitude > 0 then
                    savedPosition = char.HumanoidRootPart.CFrame
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if antiHitEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if humanoid and root then
                    humanoid.MaxHealth = math.huge; humanoid.Health = math.huge
                    humanoid.PlatformStand = false; humanoid.Sit = false
                    if root.Velocity.Magnitude > 10 then 
                        root.Velocity = Vector3.zero
                        root.RotVelocity = Vector3.zero
                    end
                    if savedPosition and (root.Position - savedPosition.Position).Magnitude > 2 then
                        root.CFrame = savedPosition
                        root.Velocity = Vector3.zero
                    end
                end
            end
        end)
    end
end)

task.spawn(function()
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if antiHitEnabled and (method == "TakeDamage" or method == "BreakJoints") then 
                return nil 
            end
            return oldNamecall(self, ...)
        end)
    end)
end)

-- EGG PREVIEW (XEM TRƯỚC GIÁ TRỊ TRỨNG)
local function CreateEggPreviewUI(targetEgg)
    if targetEgg:FindFirstChild("IcelandPreviewGui") then targetEgg.IcelandPreviewGui:Destroy() end
    local foundValues = {}
    for _, child in pairs(targetEgg:GetDescendants()) do
        if child:IsA("NumberValue") or child:IsA("StringValue") or child:IsA("IntValue") then
            if string.find(child.Name:lower(), "price") or string.find(child.Name:lower(), "value") or string.find(child.Name:lower(), "cost") or string.find(child.Name:lower(), "coin") then
                table.insert(foundValues, child.Name .. ": " .. tostring(child.Value))
            end
        end
    end
    if #foundValues == 0 then
        local petInside = targetEgg:FindFirstChildWhichIsA("Model")
        if petInside then table.insert(foundValues, "Pet: " .. petInside.Name)
        else table.insert(foundValues, "Không rõ giá trị") end
    end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "IcelandPreviewGui"
    billboard.Size = UDim2.new(0, 200, 0, 60)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = targetEgg

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    frame.BackgroundTransparency = 0.2
    frame.Parent = billboard
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -10, 1, -10)
    textLabel.Position = UDim2.new(0, 5, 0, 5)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = 12
    textLabel.TextWrapped = true
    textLabel.Text = table.concat(foundValues, "\n")
    textLabel.Parent = frame
end

task.spawn(function()
    while task.wait(1) do 
        if eggPreviewEnabled then
            pcall(function()
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (string.find(obj.Name, "Egg") or obj.Name == "NestEgg") then
                        if not obj:FindFirstChild("IcelandPreviewGui") then
                            CreateEggPreviewUI(obj)
                        end
                    end
                end
            end)
        end
    end
end)

local function ClearAllPreviews()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "IcelandPreviewGui" then obj:Destroy() end
    end
end

-- ==========================================
-- PHẦN 3: GẮN TÍNH NĂNG VÀO TABS
-- ==========================================

-- TAB MAIN
CreateToggle(MainTabContent, "Tự Động Ấp Trứng", false, function(on) autoHatchEnabled = on end)
CreateToggle(MainTabContent, "Trang Bị Pet Mạnh Nhất", false, function(on) equipBestEnabled = on end)
CreateToggle(MainTabContent, "Cướp Trứng Thông Minh", false, function(on) smartStealEnabled = on end)
CreateToggle(MainTabContent, "Anti Bị Đánh (Chống Văng)", false, function(on) 
    antiHitEnabled = on 
    if on then EnableAntiHit() end
end)
CreateToggle(MainTabContent, "Xem Trước Giá Trị Trứng", false, function(on)
    eggPreviewEnabled = on
    if not on then ClearAllPreviews() end
end)

CreateButton(MainTabContent, "SAO CHÉP BẢN CẬP NHẬT (DISCORD)", function()
    local textToCopy = [[
📌 TÓM TẮT CẬP NHẬT SCRIPT ICELAND HUB V5.0

1️⃣ Sửa lỗi Giao diện (UI): Menu cố định, không bị vỡ khung.
2️⃣ Nâng cấp Animation: Menu Pop-up, nút nhún, viền chạy.
3️⃣ Tối ưu ESP: Tracer kéo thẳng lên đỉnh đầu.
4️⃣ Tối ưu Cướp Trứng: Tự động nhặt, đợi xác nhận, không bị chập chờn.
5️⃣ Tăng tốc độ: Delay Teleport cực thấp (0.1s).
6️⃣ Nâng cấp Anti-Đánh: Bất tử, khóa vị trí, chống văng (Knockback).
7️⃣ Tab Hop Nâng Cao: Quét danh sách Server, nút Join nhanh, tự động quét trứng khi vào Server mới.
8️⃣ Thêm tính năng Xem Trước Giá Trị Trứng (Egg Preview).
    ]]
    if setclipboard then
        setclipboard(textToCopy)
        print("[ICELAND] Đã sao chép đoạn text!")
    end
end)

CreateButton(MainTabContent, "BAY LÊN TRỜI (THOÁT HIỂM)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 200, 0)
    end
end)

-- TAB ESP
CreateToggle(EspTabContent, "Bật ESP (Box & Tracer)", false, function(on) espEnabled = on end)

-- TAB HOP (NÂNG CAO)
local ServerListFrame = Instance.new("ScrollingFrame")
ServerListFrame.Parent = HopTabContent
ServerListFrame.Size = UDim2.new(0.95, 0, 0.8, 0)
ServerListFrame.BackgroundTransparency = 1
ServerListFrame.BorderSizePixel = 0
ServerListFrame.ScrollBarThickness = 2
ServerListFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)

local ServerListLayout = Instance.new("UIListLayout")
ServerListLayout.Parent = ServerListFrame
ServerListLayout.Padding = UDim.new(0, 5)

CreateButton(HopTabContent, "LÀM MỚI DANH SÁCH SERVER", function()
    for _, child in ipairs(ServerListFrame:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    
    local servers = GetServerList()
    if #servers == 0 then return end
    
    table.sort(servers, function(a, b) return a.playing > b.playing end)
    
    for i = 1, math.min(#servers, 15) do
        local server = servers[i]
        
        local ServerFrame = Instance.new("Frame")
        ServerFrame.Size = UDim2.new(1, -10, 0, 55)
        ServerFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
        ServerFrame.Parent = ServerListFrame
        Instance.new("UICorner", ServerFrame).CornerRadius = UDim.new(0, 6)
        
        local InfoText = Instance.new("TextLabel")
        InfoText.Size = UDim2.new(0.6, 0, 0.5, 0)
        InfoText.Position = UDim2.new(0, 10, 0, 5)
        InfoText.BackgroundTransparency = 1
        InfoText.Text = "Server: " .. (server.id):sub(1, 8) .. "..."
        InfoText.TextColor3 = Color3.fromRGB(200, 200, 200)
        InfoText.Font = Enum.Font.GothamBold
        InfoText.TextScaled = true
        InfoText.TextXAlignment = Enum.TextXAlignment.Left
        InfoText.Parent = ServerFrame
        
        local PlayerCount = Instance.new("TextLabel")
        PlayerCount.Size = UDim2.new(0.6, 0, 0.4, 0)
        PlayerCount.Position = UDim2.new(0, 10, 0.5, 0)
        PlayerCount.BackgroundTransparency = 1
        PlayerCount.Text = "Người chơi: " .. server.playing .. "/" .. server.maxPlayers
        PlayerCount.TextColor3 = Color3.fromRGB(150, 150, 150)
        PlayerCount.Font = Enum.Font.Gotham
        PlayerCount.TextScaled = true
        PlayerCount.TextXAlignment = Enum.TextXAlignment.Left
        PlayerCount.Parent = ServerFrame
        
        local JoinBtn = Instance.new("TextButton")
        JoinBtn.Size = UDim2.new(0.3, 0, 0.7, 0)
        JoinBtn.Position = UDim2.new(0.65, 0, 0.15, 0)
        JoinBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        JoinBtn.Text = "JOIN"
        JoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        JoinBtn.Font = Enum.Font.GothamBold
        JoinBtn.TextSize = 12
        JoinBtn.Parent = ServerFrame
        Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 4)
        
        JoinBtn.MouseButton1Click:Connect(function()
            JoinBtn.Text = "ĐANG VÀO..."
            JoinBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
            getgenv().AutoScanEggs = true 
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
        end)
    end
end)

-- TỰ ĐỘNG QUÉT KHI VÀO SERVER MỚI
if getgenv().AutoScanEggs then
    getgenv().AutoScanEggs = false 
    task.wait(5) 
    espEnabled = true 
    eggPreviewEnabled = true
    print("[ICELAND] Đã tự động bật ESP & Quét trứng cho Server mới!")
end

print("[ICELAND] Script V5.0 (Full) đã tải hoàn tất!")
