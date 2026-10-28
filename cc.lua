-- ==========================================================
-- ICELAND HUB V3 - TABS & TRACER UPGRADE
-- Tính năng: Tabs (Main/ESP/Hop) | Tracer kéo lên đầu | Trả lại vị trí cũ
-- ==========================================================

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local GUI_NAME = "Iceland_Hub_V3_Tabs"
local oldGui = CoreGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

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
            gradient.Rotation = (gradient.Rotation + 2) % 360
            task.wait(0.02)
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
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0, 20, 0.5, -180)
MainFrame.Size = UDim2.new(0, 260, 0, 360)
MainFrame.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame
createAnimatedStroke(MainFrame)

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.Size = UDim2.new(1, -50, 0, 35)
Title.Position = UDim2.new(0, 12, 0, 5)
Title.Text = "ICELAND HUB V3"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left
applyTextSettings(Title, 12, 18)

-- Thanh chứa các Tab
local TabBar = Instance.new("Frame")
TabBar.Parent = MainFrame
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 40)
TabBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TabBar.BorderSizePixel = 0
local TabBarCorner = Instance.new("UICorner")
TabBarCorner.CornerRadius = UDim.new(0, 6)
TabBarCorner.Parent = TabBar

local TabList = Instance.new("UIListLayout")
TabList.Parent = TabBar
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.Padding = UDim.new(0, 5)

-- Nơi chứa nội dung của từng Tab
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Parent = MainFrame
ContentFrame.Position = UDim2.new(0, 10, 0, 75)
ContentFrame.Size = UDim2.new(1, -20, 1, -85)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 2
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150)
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local ContentList = Instance.new("UIListLayout")
ContentList.Parent = ContentFrame
ContentList.Padding = UDim.new(0, 6)
ContentList.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Hàm tạo Tab
local Tabs = {}
local ActiveTab = nil
local function CreateTab(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.3, 0, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.Parent = TabBar
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 4)
    c.Parent = btn
    
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
            tData.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            tData.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        tabContent.Visible = true
        btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        ActiveTab = name
    end)
    
    return tabContent
end

local MainTabContent = CreateTab("Main")
local EspTabContent = CreateTab("ESP")
local HopTabContent = CreateTab("Hop")

-- Kích hoạt tab Main mặc định
Tabs["Main"].Button:GetPropertyChangedSignal("BackgroundColor3"):Wait() -- Đợi load xong
Tabs["Main"].Content.Visible = true
Tabs["Main"].Button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Tabs["Main"].Button.TextColor3 = Color3.fromRGB(0, 0, 0)

-- Kéo thả Menu
local dragToggle, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
        dragToggle = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
        end)
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragToggle then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Hàm tạo Toggle & Button cho từng Tab
local function CreateToggle(parent, txt, defaultState, cb)
    local state = defaultState or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    btn.BackgroundTransparency = 0.1
    btn.Text = ""
    btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 6); c.Parent = btn
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0); label.Position = UDim2.new(0, 10, 0, 0); label.BackgroundTransparency = 1
    label.Text = txt; label.TextColor3 = Color3.fromRGB(200, 200, 200); label.Font = Enum.Font.Gotham; label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn; applyTextSettings(label, 9, 13)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14); dot.Position = UDim2.new(1, -25, 0.5, -7); dot.BackgroundColor3 = Color3.fromRGB(80, 80, 80); dot.Parent = btn
    local dotCorner = Instance.new("UICorner"); dotCorner.CornerRadius = UDim.new(1, 0); dotCorner.Parent = dot
    local function updateState()
        if state then dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255); label.TextColor3 = Color3.fromRGB(255, 255, 255)
        else dot.BackgroundColor3 = Color3.fromRGB(80, 80, 80); label.TextColor3 = Color3.fromRGB(200, 200, 200) end
    end
    updateState()
    btn.MouseButton1Click:Connect(function() state = not state; updateState(); if cb then cb(state) end end)
    return btn
end

local function CreateButton(parent, txt, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    btn.Text = txt; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.GothamBold; btn.Parent = parent
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 5); c.Parent = btn
    applyTextSettings(btn, 9, 13)
    btn.MouseButton1Click:Connect(function() if cb then cb() end end)
    return btn
end

-- ==========================================
-- PHẦN 2: LOGIC TÍNH NĂNG
-- ==========================================
local espEnabled = false
local autoHatchEnabled = false
local instantCollectEnabled = false
local equipBestEnabled = false
local autoRebirthEnabled = false
local smartStealEnabled = false
local antiHitEnabled = false
local autoRetaliateEnabled = false
local espDrawings = {}

-- Hàm Tìm Server (Hop)
local function GetServerList()
    local servers = {}
    local success, pages = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and pages and pages.data then
        for _, server in ipairs(pages.data) do
            table.insert(servers, server)
        end
    end
    return servers
end

local function HopToServer(serverId)
    if serverId then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, serverId, LocalPlayer)
    end
end

-- ==========================================
-- PHẦN 3: ESP (ĐÃ KÉO TRACER LÊN ĐẦU)
-- ==========================================
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
                
                -- Tracer: Từ dưới màn hình kéo lên đúng đỉnh đầu nhân vật
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

-- ==========================================
-- CÁC TÍNH NĂNG KHÁC (Viết tắt)
-- ==========================================
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

local PRIORITY_KEYWORDS = {"Gold", "Diamond", "Rainbow", "Dragon", "Unicorn", "Kitsune", "Secret", "Divine", "Mythic", "Legendary"}
local function GetPetPriority(petModel)
    local name = petModel.Name
    local score = 0
    for _, keyword in ipairs(PRIORITY_KEYWORDS) do
        if string.find(name, keyword, 1, true) then score = score + 100 end
    end
    local incomeVal = petModel:FindFirstChild("Income") or petModel:FindFirstChild("CPS")
    if incomeVal and incomeVal:IsA("NumberValue") then score = score + incomeVal.Value end
    return score
end

task.spawn(function()
    while task.wait(0.2) do
        if smartStealEnabled then
            pcall(function()
                local myChar = LocalPlayer.Character
                if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
                local myHRP = myChar.HumanoidRootPart
                local originalCFrame = myHRP.CFrame 
                
                local bestPet, bestScore, bestPetPart = nil, -1, nil
                
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") and (obj.Name == "Pet" or obj.Name == "Monster" or string.find(obj.Name, "Pet")) then
                        local ownerValue = obj:FindFirstChild("Owner") or obj:FindFirstChild("OwnerId")
                        if ownerValue and ownerValue.Value ~= LocalPlayer then
                            local petPart = obj:FindFirstChildWhichIsA("BasePart") or obj:FindFirstChild("HumanoidRootPart")
                            if petPart then
                                local score = GetPetPriority(obj)
                                if score > bestScore then
                                    bestScore = score
                                    bestPet = obj
                                    bestPetPart = petPart
                                end
                            end
                        end
                    end
                end
                
                if bestPet and bestPetPart then
                    myHRP.CFrame = bestPetPart.CFrame
                    task.wait(0.1)
                    local prompt = bestPetPart:FindFirstChildOfClass("ProximityPrompt")
                    if prompt then fireproximityprompt(prompt) end
                    task.wait(0.1)
                    myHRP.CFrame = originalCFrame
                    myHRP.Velocity = Vector3.zero
                    task.wait(0.2)
                end
            end)
        end
    end
end)

-- Anti Hit (Viết tắt vì đã có ở trên)
local savedPosition = nil
local function EnableAntiHit()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if humanoid and root then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid.PlatformStand = false
        root.CustomPhysicalProperties = PhysicalProperties.new(10000, 0.3, 0.5)
        savedPosition = root.CFrame
    end
end

task.spawn(function()
    while task.wait(0.1) do
        if antiHitEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.Health = char.Humanoid.MaxHealth
                    char.Humanoid.PlatformStand = false
                end
            end)
        end
    end
end)

-- ==========================================
-- PHẦN 4: GẮN TÍNH NĂNG VÀO CÁC TAB
-- ==========================================

-- Gắn vào Tab Main
CreateToggle(MainTabContent, "Tự Động Ấp Trứng", false, function(on) autoHatchEnabled = on end)
CreateToggle(MainTabContent, "Mua Trứng Siêu Tốc", false, function(on) instantCollectEnabled = on end)
CreateToggle(MainTabContent, "Trang Bị Pet Mạnh Nhất", false, function(on) equipBestEnabled = on end)
CreateToggle(MainTabContent, "Cướp Pet (Trả lại chỗ cũ)", false, function(on) smartStealEnabled = on end)
CreateToggle(MainTabContent, "Anti Bị Đánh (Bất Tử)", false, function(on) 
    antiHitEnabled = on 
    if on then EnableAntiHit() end
end)
CreateButton(MainTabContent, "BAY LÊN TRỜI (THOÁT HIỂM)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 200, 0)
    end
end)

-- Gắn vào Tab ESP
CreateToggle(EspTabContent, "Bật ESP (Box & Tracer)", false, function(on) espEnabled = on end)

-- Gắn vào Tab Hop
CreateButton(HopTabContent, "Tìm Server Ít Người (Hop)", function()
    local servers = GetServerList()
    table.sort(servers, function(a, b) return a.playing < b.playing end)
    if servers[1] then
        HopToServer(servers[1].id)
    end
end)

CreateButton(HopTabContent, "Tìm Server Nhiều Người (Hop)", function()
    local servers = GetServerList()
    table.sort(servers, function(a, b) return a.playing > b.playing end)
    if servers[1] then
        HopToServer(servers[1].id)
    end
end)

print("[ICELAND] Script V3 (Tabs) đã tải hoàn tất!")
