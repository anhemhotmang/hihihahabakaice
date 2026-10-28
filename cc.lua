-- ==========================================================
-- ICELAND HUB - FAKE AN EGG
-- Giao diện: Đen mờ, Viền chạy Đen-Trắng-Xám, Menu vừa phải lệch trái
-- ==========================================================

local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local UIModule = {}
UIModule.__index = UIModule
local GUI_NAME = "Iceland_Hub_V3"

local oldGui = CoreGui:FindFirstChild(GUI_NAME)
if oldGui then oldGui:Destroy() end

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

-- Hàm tạo hiệu ứng viền chạy (Gradient)
local function createAnimatedStroke(parentFrame)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Color = Color3.fromRGB(255, 255, 255) -- Màu gốc
    stroke.Parent = parentFrame

    -- Sử dụng UIGradient để tạo hiệu ứng chuyển màu Đen-Trắng-Xám
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 50, 50)),   -- Xám tối
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 255)), -- Trắng
        ColorSequenceKeypoint.new(0.6, Color3.fromRGB(10, 10, 10)),  -- Đen
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))  -- Xám nhạt
    }
    gradient.Parent = stroke

    -- Hiệu ứng xoay vòng màu liên tục
    task.spawn(function()
        while stroke.Parent do
            gradient.Rotation = (gradient.Rotation + 2) % 360
            task.wait(0.02)
        end
    end)
    return stroke
end

function UIModule.CreateWindow(titleText)
    local self = setmetatable({}, UIModule)
    local ApexHub = Instance.new("ScreenGui")
    ApexHub.Name = GUI_NAME
    ApexHub.Parent = CoreGui
    ApexHub.ResetOnSpawn = false
    ApexHub.IgnoreGuiInset = true
    self.Gui = ApexHub

    -- Bảng điều khiển chính (Kích thước vừa phải)
    local Main = Instance.new("Frame")
    Main.Parent = ApexHub
    Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Màu đen
    Main.BackgroundTransparency = 0.25 -- Độ mờ (0 là đặc, 1 là trong suốt)
    Main.BorderSizePixel = 0
    -- Vị trí: Lệch sang trái, thu nhỏ kích thước
    Main.Position = UDim2.new(0, 20, 0.5, -150) 
    Main.Size = UDim2.new(0, 240, 0, 80) 
    Main.Active = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = Main

    -- Thêm hiệu ứng viền chạy Đen-Trắng-Xám
    local UIStroke = createAnimatedStroke(Main)

    -- Tiêu đề
    local Title = Instance.new("TextLabel")
    Title.Parent = Main
    Title.Size = UDim2.new(1, -50, 0, 35)
    Title.Position = UDim2.new(0, 12, 0, 5)
    Title.Text = titleText or "ICELAND HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255) -- Màu trắng
    Title.Font = Enum.Font.GothamBold
    Title.BackgroundTransparency = 1
    Title.TextXAlignment = Enum.TextXAlignment.Left
    applyTextSettings(Title, 12, 18)
    self.TitleLabel = Title

    -- Vùng chứa nội dung
    local Content = Instance.new("ScrollingFrame")
    Content.Parent = Main
    Content.Position = UDim2.new(0, 10, 0, 40)
    Content.Size = UDim2.new(1, -20, 0, 0)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = Color3.fromRGB(150, 150, 150) -- Xám
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    self.Content = Content

    local UIList = Instance.new("UIListLayout")
    UIList.Parent = Content
    UIList.Padding = UDim.new(0, 6)
    UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    self.UIList = UIList

    -- Nút thu nhỏ
    local isMinimized = false
    local MINIMIZED_SIZE = UDim2.new(0, 240, 0, 35)
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 22, 0, 22)
    MinBtn.Position = UDim2.new(1, -30, 0, 6)
    MinBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) -- Đen xám
    MinBtn.Text = "-"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 16
    MinBtn.Parent = Main
    local MinBtnCorner = Instance.new("UICorner")
    MinBtnCorner.CornerRadius = UDim.new(0, 5)
    MinBtnCorner.Parent = MinBtn

    local TITLE_PADDING = 50
    local MAX_HEIGHT = 350
    local function updateMainSize()
        if not isMinimized then
            local contentHeight = UIList.AbsoluteContentSize.Y
            local targetContentHeight = math.min(contentHeight, MAX_HEIGHT)
            Content.Size = UDim2.new(1, -20, 0, targetContentHeight)
            Main.Size = UDim2.new(0, 240, 0, targetContentHeight + TITLE_PADDING)
        end
    end
    self.UpdateSize = updateMainSize
    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateMainSize)

    MinBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Content.Visible = false
            Main.Size = MINIMIZED_SIZE
            MinBtn.Text = "+"
        else
            Content.Visible = true
            updateMainSize()
            MinBtn.Text = "-"
        end
    end)

    -- Kéo thả
    local dragToggle, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragToggle = false end
            end)
        end
    end)
    Main.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragToggle then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return self
end

-- Nút Toggle (Bật/Tắt) Tone Đen-Trắng
function UIModule:CreateToggle(txt, defaultState, cb)
    local state = defaultState or false
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Đen mờ
    btn.BackgroundTransparency = 0.1
    btn.Text = ""
    btn.Parent = self.Content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    local BtnStroke = Instance.new("UIStroke")
    BtnStroke.Thickness = 1
    BtnStroke.Color = Color3.fromRGB(60, 60, 60) -- Viền xám tối
    BtnStroke.Parent = btn

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = txt
    label.TextColor3 = Color3.fromRGB(200, 200, 200) -- Xám sáng
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn
    applyTextSettings(label, 9, 13)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(1, -25, 0.5, -7)
    dot.BackgroundColor3 = Color3.fromRGB(80, 80, 80) -- Xám tối (Trạng thái tắt)
    dot.Parent = btn
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot

    local function updateState()
        if state then
            dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Trắng sáng (Trạng thái bật)
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            dot.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end
    updateState()

    btn.MouseButton1Click:Connect(function()
        state = not state
        updateState()
        if cb then cb(state) end
    end)
    self.UpdateSize()
    return btn
end

-- Nút bấm thường
function UIModule:CreateButton(txt, cb)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.95, 0, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35) -- Xám đậm
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = self.Content
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 5)
    c.Parent = btn
    applyTextSettings(btn, 9, 13)
    btn.MouseButton1Click:Connect(function()
        if cb then cb() end
    end)
    self.UpdateSize()
    return btn
end

-- ==========================================================
-- [PHẦN 2: LOGIC GAME & TÍNH NĂNG]
-- ==========================================================

local espEnabled = false
local autoHatchEnabled = false
local instantCollectEnabled = false
local equipBestEnabled = false
local autoRebirthEnabled = false
local smartStealEnabled = false
local espDrawings = {}

-- Hàm ESP
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
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255) -- ESP màu trắng
    box.Thickness = 1
    box.Filled = false
    local tracer = Drawing.new("Line")
    tracer.Visible = false
    tracer.Color = Color3.fromRGB(255, 255, 255)
    tracer.Thickness = 1
    espDrawings[player] = {Box = box, Tracer = tracer}
end
Players.PlayerAdded:Connect(setupESP)
Players.PlayerRemoving:Connect(removeESP)
for _, player in ipairs(Players:GetPlayers()) do setupESP(player) end

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, drawings in pairs(espDrawings) do
            drawings.Box.Visible = false
            drawings.Tracer.Visible = false
        end
        return
    end
    for player, drawings in pairs(espDrawings) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if character and hrp and humanoid and humanoid.Health > 0 then
            local rootPos = hrp.Position
            local topPos = rootPos + Vector3.new(0, 3, 0)
            local bottomPos = rootPos - Vector3.new(0, 3.5, 0)
            local topScreen, topOnScreen = Camera:WorldToViewportPoint(topPos)
            local bottomScreen, bottomOnScreen = Camera:WorldToViewportPoint(bottomPos)
            if topOnScreen or bottomOnScreen then
                local height = math.abs(topScreen.Y - bottomScreen.Y)
                local width = height / 2
                drawings.Box.Size = Vector2.new(width, height)
                drawings.Box.Position = Vector2.new(topScreen.X - width / 2, topScreen.Y)
                drawings.Box.Visible = true
                drawings.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                drawings.Tracer.To = Vector2.new(topScreen.X, topScreen.Y + height)
                drawings.Tracer.Visible = true
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

-- Tìm Base
local function getMyBasePart()
    local bases = Workspace:FindFirstChild("Bases")
    if not bases then return nil end
    local accountName = LocalPlayer.Name:lower()
    local displayName = LocalPlayer.DisplayName:lower()
    for i = 1, 10 do
        local baseFolder = bases:FindFirstChild(tostring(i))
        if baseFolder then
            local sign = baseFolder:FindFirstChild("Sign")
            if sign then
                local display = sign:FindFirstChild("Display")
                if display then
                    local gui = display:FindFirstChild("BaseDisplayGui")
                    if gui then
                        local frame = gui:FindFirstChild("Frame")
                        if frame then
                            local info = frame:FindFirstChild("Info")
                            if info then
                                local playerNameLabel = info:FindFirstChild("PlayerName")
                                if playerNameLabel and playerNameLabel:IsA("TextLabel") then
                                    local text = playerNameLabel.Text
                                    if text then
                                        local cleanText = text:match("^%s*(.-)%s*$") or text
                                        cleanText = cleanText:lower()
                                        if cleanText == accountName or cleanText == displayName or cleanText:find(accountName, 1, true) or cleanText:find(displayName, 1, true) then
                                            local part = baseFolder:FindFirstChild("Part")
                                            if part and part:IsA("BasePart") then return part end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return nil
end

-- Auto Hatch
task.spawn(function()
    while true do
        if autoHatchEnabled then
            pcall(function()
                local nestEggs = Workspace:FindFirstChild("NestEggs")
                if nestEggs then
                    for _, child in ipairs(nestEggs:GetChildren()) do
                        if child:IsA("Model") then
                            local hatchPrompt = child:FindFirstChild("HatchPrompt", true)
                            if hatchPrompt and hatchPrompt:IsA("ProximityPrompt") then
                                fireproximityprompt(hatchPrompt)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(0.2)
    end
end)

-- Equip Best
task.spawn(function()
    while true do
        if equipBestEnabled then
            pcall(function()
                local equipBestEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and ReplicatedStorage.RemoteEvents:FindFirstChild("EquipBestEvent")
                if equipBestEvent then equipBestEvent:FireServer() end
            end)
        end
        task.wait(2)
    end
end)

-- Hook Instant Collect
local function setupInstantCollectHook()
    task.spawn(function()
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
                if args[1] == "Buy" then
                    local result = oldNamecall(self, unpack(args))
                    task.spawn(function()
                        task.wait(1)
                        local character = LocalPlayer.Character
                        local hrp = character and character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local originalCFrame = hrp.CFrame
                            local basePart = getMyBasePart()
                            if basePart then
                                hrp.CFrame = basePart.CFrame + Vector3.new(0, 3, 0)
                                task.wait(1)
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
end
setupInstantCollectHook()

-- Auto Rebirth
local function AutoRebirth()
    task.spawn(function()
        while task.wait(2) do
            if not autoRebirthEnabled then continue end
            local rebirthBtn = LocalPlayer.PlayerGui:FindFirstChild("--- SỬA TÊN GUI REBIRTH ---", true)
            if rebirthBtn and (rebirthBtn:IsA("TextButton") or rebirthBtn:IsA("ImageButton")) then
                rebirthBtn:Activate()
                print("[ICELAND] Đã bấm nút Tái Sinh!")
            end
        end
    end)
end

-- Smart Steal Pet
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

local function SmartStealPet()
    task.spawn(function()
        while task.wait(0.4) do
            if not smartStealEnabled then continue end
            local myChar = LocalPlayer.Character
            if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then continue end
            local myHRP = myChar.HumanoidRootPart
            
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
                task.wait(0.15)
                local prompt = bestPetPart:FindFirstChildOfClass("ProximityPrompt")
                if prompt then fireproximityprompt(prompt) end
                task.wait(0.5)
                
                local basePart = getMyBasePart()
                if basePart then
                    myHRP.CFrame = basePart.CFrame + Vector3.new(0, 5, 0)
                    print("[ICELAND] Đã lấy " .. bestPet.Name .. " và về base!")
                else
                    myHRP.CFrame = myHRP.CFrame + Vector3.new(0, 150, 0)
                end
                task.wait(1)
            end
        end
    end)
end

-- ==========================================================
-- [PHẦN 3: KHỞI TẠO GIAO DIỆN]
-- ==========================================================

local Hub = UIModule.CreateWindow("ICELAND HUB")

Hub:CreateToggle("Hiển thị người chơi (ESP)", false, function(on)
    espEnabled = on
end)

Hub:CreateToggle("Tự động ấp trứng", false, function(on)
    autoHatchEnabled = on
end)

Hub:CreateToggle("Nhặt trứng siêu tốc", false, function(on)
    instantCollectEnabled = on
end)

Hub:CreateToggle("Trang bị Pet mạnh nhất", false, function(on)
    equipBestEnabled = on
end)

Hub:CreateToggle("Tự động Tái Sinh (Rebirth)", false, function(on)
    autoRebirthEnabled = on
    if on then AutoRebirth() end
end)

Hub:CreateToggle("Trộm Pet Thông Minh", false, function(on)
    smartStealEnabled = on
    if on then SmartStealPet() end
end)

Hub:CreateButton("BAY LÊN TRỜI (THOÁT HIỂM)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 200, 0)
        print("[ICELAND] Đã bay lên cao thoát hiểm!")
    end
end)

print("[ICELAND] Script đã tải thành công!")
