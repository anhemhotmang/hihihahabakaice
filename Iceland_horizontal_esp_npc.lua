local players = game:GetService("Players")
local v1 = game:GetService("Workspace")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local teleportService = game:GetService("TeleportService")
local lighting = game:GetService("Lighting")
local virtualUser = game:GetService("VirtualUser")
local httpService = game:GetService("HttpService")
local localPlayer = players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local currentCamera = workspace.CurrentCamera

localPlayer.Idled:Connect(function()
  pcall(function()
    virtualUser:CaptureController()
    virtualUser:ClickButton2(Vector2.new())
  end)
end)

local function f1()
  local viewportSize = currentCamera.ViewportSize
  local v2 = math.min(viewportSize.X, viewportSize.Y)
  return math.clamp(v2 / 800, 0.7, 1.2)
end

local v3 = {
  FarmLevel = false,
  SafeFarm = false,
  FarmBoss = false,
  FarmMode = 1,
  Model1Speed = 50,
  Model2Speed = 3,
  Model3Speed = 8,
  Model4Speed = 150,
  AutoHeal = false,
  AutoLoot = false,
  LootDistance = 30,
  Distance = 25,
  HealDelay = 0.1,
  FreeCam = false,
  CustomRankText = "Cậu Cả💸",
  CustomRankColor = Color3.fromRGB(255, 215, 0),
  RankRainbow = false,
  CustomUsername = "Iceland",
  UsernameColor = Color3.fromRGB(255, 255, 255),
  UsernameRainbow = false,
  CustomDisplayname = "Iceland",
  DisplaynameColor = Color3.fromRGB(255, 255, 255),
  DisplaynameRainbow = false,
  LevelText = "30",
  LevelColor = Color3.fromRGB(76, 255, 121),
  LevelRainbow = false,
  AutoBuyBandage = false,
  BuyBandageAmount = 10,
  BandageMax = 50,
  FreezeBoss = false,
  FreezeNPC = false,
  ShowNPC2HpBar = true,
  AutoAttack = false,
  AimNearest = false,
  PlayerHPESP = false,
  PlayerHighlight = false,
  RainbowGUI = false,
  UIScale = f1(),
  GuiSizeMode = "Mặc Định",
  BandageCount = 0,
  FakeAniEnabled = false,
  FakeAniApplyAll = false,
  SelectedToolName = nil,
  AnimSet = "BVK",
  SafeFarmDepth = 15,
  FreezeMoveOnFarm = false,
}

local buyItem

pcall(function()
  buyItem = replicatedStorage.KnitPackages._Index["sleitnick_knit@1.7.0"].knit.Services.ShopService.RE.buyItem
end)

local waitForChild

pcall(function()
  waitForChild = replicatedStorage:WaitForChild("Remotes", 2):WaitForChild("Heal", 2)
end)

local updateInventory

pcall(function()
  updateInventory = replicatedStorage.KnitPackages._Index["sleitnick_knit@1.7.0"].knit.Services.InventoryService.RE.updateInventory
end)

if updateInventory then
  updateInventory.OnClientEvent:Connect(function(p1, p2)
    if type(p2) == "table" then
      local total = 0
      for _, value in pairs(p2) do
        if type(value) == "table"
          and (value.Name == "băng gạc" or (value.Id and string.find(value.Id, "băng gạc"))) then
          total = total + (value.Quantity or 1)
        end
      end
      v3.BandageCount = total
    end
  end)
end


local function f2(p3)
  return string.format(
    "%02X%02X%02X", math.floor(p3.R * 255), math.floor(p3.G * 255), math.floor(p3.B * 255)
  )
end

task.spawn(function()
  while true do
    pcall(function()
      local character = localPlayer.Character

      if character then
        for key2, value2 in pairs(character:GetDescendants()) do
          if value2:IsA("BillboardGui") and string.find(string.lower(value2.Name), "nametag") then
            value2.AlwaysOnTop = true

            for key3, value3 in pairs(value2:GetDescendants()) do
              if value3:IsA("TextLabel") then
                local v4 = string.lower(value3.Name)

                if string.find(v4, "rank") then
                  value3.RichText = true
                  value3.Text = v3.CustomRankText

                  if not v3.RankRainbow then
                    value3.TextColor3 = v3.CustomRankColor
                  end
                elseif string.find(v4, "display") then
                  value3.RichText = true
                  local v5 = f2(v3.LevelColor)
                  local v6 = f2(v3.DisplaynameColor)

                  local v7 = v3.CustomDisplayname ~= ""
                      and " <font color=\"#" .. v6 .. "\">" .. v3.CustomDisplayname .. "</font>"
                    or ""

                  value3.Text = string.format(
                    "<font color=\"#%s\">(Lv %s)</font>%s", v5, v3.LevelText, v7
                  )
                elseif (string.find(v4, "user") or string.find(v4, "name"))
                  and not string.find(v4, "display") then
                  value3.RichText = true
                  local v8 = f2(v3.UsernameColor)

                  value3.Text = string.format(
                    "<font color=\"#%s\">%s</font>", v8, v3.CustomUsername
                  )
                end
              end
            end
          end
        end
      end
    end)

    task.wait(0.3)
  end
end)

task.spawn(function()
  local v9 = 0

  while true do
    if v3.RankRainbow or v3.UsernameRainbow or v3.DisplaynameRainbow or v3.LevelRainbow then
      v9 = (v9 + 0.01) % 1
      local color = Color3.fromHSV(v9, 0.85, 1)

      if v3.RankRainbow then
        v3.CustomRankColor = color
      end

      if v3.UsernameRainbow then
        v3.UsernameColor = color
      end

      if v3.DisplaynameRainbow then
        v3.DisplaynameColor = color
      end

      if v3.LevelRainbow then
        v3.LevelColor = color
      end
    end

    task.wait(0.05)
  end
end)

local v10 = false
local zero = Vector3.zero
local v11 = 0
local v12 = 0

local function f3()
  v10 = true
  zero = currentCamera.CFrame.Position
  local lookVector = currentCamera.CFrame.LookVector
  v12 = math.atan2(lookVector.X, -lookVector.Z)
  v11 = math.asin(lookVector.Y)
  currentCamera.CameraType = Enum.CameraType.Scriptable
  local character2 = localPlayer.Character

  if character2 then
    local humanoid = character2:FindFirstChildOfClass("Humanoid")

    if humanoid then
      humanoid.AutoRotate = false
      humanoid.WalkSpeed = 0
      humanoid.JumpPower = 0
    end
  end
end

local v13 = 50
local v14 = {}
local v15 = {}
local f4

local function f5()
  if not v10 then
    return
  else
    local character3 = localPlayer.Character
    local humanoidRootPart = character3 and character3:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart then
      humanoidRootPart.CFrame = CFrame.new(zero)
    end

    f4()
    return
  end
end

local v16

function f4()
  v10 = false
  currentCamera.CameraType = Enum.CameraType.Custom
  local character4 = localPlayer.Character

  if character4 then
    local humanoid2 = character4:FindFirstChildOfClass("Humanoid")

    if humanoid2 then
      currentCamera.CameraSubject = humanoid2

      humanoid2.AutoRotate = true
      humanoid2.WalkSpeed = 16
      humanoid2.JumpPower = 50
    end
  end

  v16 = nil
  v15 = {}
end

userInputService.InputBegan:Connect(function(input, p4)
  if p4 then
    return
  end

  if input.UserInputType == Enum.UserInputType.Keyboard then
    v14[input.KeyCode] = true
  elseif input.UserInputType == Enum.UserInputType.Touch then
    v15[input] = { startPos = input.Position }
  end
end)

userInputService.InputEnded:Connect(function(input2)
  if input2.UserInputType == Enum.UserInputType.Keyboard then
    v14[input2.KeyCode] = nil
  elseif input2.UserInputType == Enum.UserInputType.Touch then
    v15[input2] = nil
    local v17 = false

    for key4, value4 in pairs(v15) do
      if value4.startPos.X < currentCamera.ViewportSize.X / 2 then
        v17 = true
      end
    end

    if not v17 then
      v16 = nil
    end
  end
end)

userInputService.InputChanged:Connect(function(input3)
  if not v10 then
    return
  elseif input3.UserInputType == Enum.UserInputType.Touch then
    local v18 = v15[input3]

    if not v18 then
      return
    end

    if v18.startPos.X < currentCamera.ViewportSize.X / 2 then
      if not v16 then
        v16 = { position = Vector2.zero }
      end

      v16.position = input3.Position - v18.startPos
    else
      local delta = input3.Delta

      if delta.Magnitude > 0 then
        v12 = v12 - delta.X * 0.005
        v11 = math.clamp(v11 - delta.Y * 0.005, -1.4, 1.4)
      end
    end

    return
  elseif input3.UserInputType == Enum.UserInputType.MouseMovement
    and not userInputService.TouchEnabled then
    local delta2 = input3.Delta
    v12 = v12 - delta2.X * 0.003
    v11 = math.clamp(v11 - delta2.Y * 0.003, -1.4, 1.4)
  end
end)

local function f6()
  local zero2 = Vector3.zero
  local v19 = CFrame.Angles(0, v12, 0) * CFrame.Angles(v11, 0, 0)
  local rightVector = v19.RightVector
  local lookVector2 = v19.LookVector

  if v14[Enum.KeyCode.W] then
    zero2 = zero2 + lookVector2
  end

  if v14[Enum.KeyCode.S] then
    zero2 = zero2 - lookVector2
  end

  if v14[Enum.KeyCode.A] then
    zero2 = zero2 - rightVector
  end

  if v14[Enum.KeyCode.D] then
    zero2 = zero2 + rightVector
  end

  if v14[Enum.KeyCode.E] then
    zero2 = zero2 + Vector3.yAxis
  end

  if v14[Enum.KeyCode.Q] then
    zero2 = zero2 - Vector3.yAxis
  end

  if v16 then
    local position = v16.position

    if position.Magnitude > 5 then
      local unit = position.Unit
      zero2 = zero2 + lookVector2 * -unit.Y + rightVector * unit.X
    end
  end

  return zero2.Magnitude > 0 and zero2.Unit or Vector3.zero
end

runService.RenderStepped:Connect(function(delta3)
  if not v10 then
    return
  else
    local v20 = f6()

    local touchEnabled = (v14[Enum.KeyCode.LeftShift] or userInputService.TouchEnabled) and 150
      or 50

    if v20.Magnitude > 0 then
      v13 = math.min(v13 + delta3 * 200, touchEnabled)
      zero = zero + v20 * v13 * delta3
    else
      v13 = 50
    end

    currentCamera.CFrame = CFrame.new(zero) * CFrame.Angles(0, v12, 0)
      * CFrame.Angles(v11, 0, 0)

    return
  end
end)

local lwginSzZUI = playerGui:FindFirstChild("Iceland_UI")

if lwginSzZUI then
  lwginSzZUI:Destroy()
end

local lwginSzZUI2 = Instance.new("ScreenGui")
lwginSzZUI2.Name = "Iceland_UI"
lwginSzZUI2.ResetOnSpawn = false
lwginSzZUI2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
lwginSzZUI2.IgnoreGuiInset = true
lwginSzZUI2.DisplayOrder = 999
lwginSzZUI2.Parent = playerGui

local instance = Instance.new("UIScale", lwginSzZUI2)
instance.Scale = v3.UIScale

local mainFrame = Instance.new("Frame", lwginSzZUI2)
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 320)
mainFrame.Position = UDim2.new(0.35, 0, 0.15, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
mainFrame.BackgroundTransparency = 0.18
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Visible = false

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local instance2 = Instance.new("UIStroke", mainFrame)
instance2.Thickness = 2
instance2.Color = Color3.fromRGB(245, 245, 245)

local openCloseButton = Instance.new("TextButton", lwginSzZUI2)
openCloseButton.Name = "OpenCloseButton"
openCloseButton.Size = UDim2.new(0, 90, 0, 36)
openCloseButton.Position = mainFrame.Position
openCloseButton.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
openCloseButton.Text = "Iceland"
openCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openCloseButton.Font = Enum.Font.GothamBold
openCloseButton.TextSize = 12
openCloseButton.Visible = false
openCloseButton.Active = true

Instance.new("UICorner", openCloseButton).CornerRadius = UDim.new(0, 12)

local instance3 = Instance.new("UIStroke", openCloseButton)
instance3.Thickness = 2
instance3.Color = Color3.fromRGB(0, 0, 0)

-- Giao diện nhập key Iceland (key mặc định: Iceland; có thể đổi ACCESS_KEY).
local ACCESS_KEY = "Iceland"
local KEY_FILE = "Iceland_key.txt"
local savedKey = nil
pcall(function() if isfile and readfile and isfile(KEY_FILE) then savedKey = readfile(KEY_FILE) end end)
local keyFrame = Instance.new("Frame", lwginSzZUI2)
keyFrame.Name = "IcelandKeyPanel"
keyFrame.Size = UDim2.new(0, 300, 0, 190)
keyFrame.Position = UDim2.new(0.5, -150, 0.5, -95)
keyFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
keyFrame.BorderSizePixel = 0
keyFrame.ZIndex = 20
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 12)
local keyStroke = Instance.new("UIStroke", keyFrame)
keyStroke.Thickness = 2
keyStroke.Color = Color3.fromRGB(245, 245, 245)

local keyTitle = Instance.new("TextLabel", keyFrame)
keyTitle.Size = UDim2.new(1, -24, 0, 35)
keyTitle.Position = UDim2.new(0, 12, 0, 10)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "Iceland | Nhập Key"
keyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 17
keyTitle.ZIndex = 21

local keyBox = Instance.new("TextBox", keyFrame)
keyBox.Size = UDim2.new(1, -32, 0, 38)
keyBox.Position = UDim2.new(0, 16, 0, 57)
keyBox.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Nhập key tại đây..."
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(160, 160, 160)
keyBox.Font = Enum.Font.Gotham
keyBox.TextSize = 14
keyBox.ZIndex = 21
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 7)

local keyStatus = Instance.new("TextLabel", keyFrame)
keyStatus.Size = UDim2.new(1, -32, 0, 22)
keyStatus.Position = UDim2.new(0, 16, 0, 98)
keyStatus.BackgroundTransparency = 1
keyStatus.Text = "Nhập key để mở menu"
keyStatus.TextColor3 = Color3.fromRGB(190, 190, 190)
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 11
keyStatus.ZIndex = 21

local keySubmit = Instance.new("TextButton", keyFrame)
keySubmit.Size = UDim2.new(1, -32, 0, 36)
keySubmit.Position = UDim2.new(0, 16, 0, 132)
keySubmit.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
keySubmit.BorderSizePixel = 0
keySubmit.Text = "XÁC NHẬN KEY"
keySubmit.TextColor3 = Color3.fromRGB(15, 15, 18)
keySubmit.Font = Enum.Font.GothamBold
keySubmit.TextSize = 13
keySubmit.ZIndex = 21
Instance.new("UICorner", keySubmit).CornerRadius = UDim.new(0, 7)

local function submitIcelandKey()
  local candidate = keyBox.Text
  if candidate == "" and savedKey then candidate = savedKey end
  if candidate == ACCESS_KEY then
    pcall(function() if writefile then writefile(KEY_FILE, candidate) end end)
    mainFrame.Visible = true
    keyFrame:Destroy()
  else
    keyStatus.Text = "Key không đúng, thử lại nhé"
    keyStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
    keyBox.Text = ""
  end
end
keySubmit.MouseButton1Click:Connect(submitIcelandKey)
keyBox.FocusLost:Connect(function(enterPressed)
  if enterPressed then submitIcelandKey() end
end)
if savedKey == ACCESS_KEY then
  mainFrame.Visible = true
  keyFrame:Destroy()
end

local v21, position2, position3

openCloseButton.InputBegan:Connect(function(input4)
  if input4.UserInputType == Enum.UserInputType.MouseButton1
    or input4.UserInputType == Enum.UserInputType.Touch then
    v21 = true
    position2 = input4.Position
    position3 = openCloseButton.Position
  end
end)

openCloseButton.InputEnded:Connect(function(input5)
  if input5.UserInputType == Enum.UserInputType.MouseButton1
    or input5.UserInputType == Enum.UserInputType.Touch then
    v21 = false
  end
end)

userInputService.InputChanged:Connect(function(input6)
  if v21
    and (input6.UserInputType == Enum.UserInputType.MouseMovement
      or input6.UserInputType == Enum.UserInputType.Touch) then
    local v22 = input6.Position - position2

    openCloseButton.Position = UDim2.new(
      position3.X.Scale, position3.X.Offset + v22.X, position3.Y.Scale,
      position3.Y.Offset + v22.Y
    )
  end
end)

local function f7(p5)
  p5.TextColor3 = Color3.fromRGB(255, 255, 255)

  local instance4 = Instance.new("UIGradient", p5)
  instance4.Rotation = 90

  instance4.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150)),
  })
end

local instance5 = Instance.new("Frame", mainFrame)
instance5.Size = UDim2.new(1, 0, 0, 34)
instance5.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
instance5.BackgroundTransparency = 0.12
instance5.BorderSizePixel = 0

Instance.new("UICorner", instance5).CornerRadius = UDim.new(0, 10)

local instance6 = Instance.new("TextLabel", instance5)
instance6.Size = UDim2.new(0.8, 0, 1, 0)
instance6.Position = UDim2.new(0.04, 0, 0, 0)
instance6.BackgroundTransparency = 1
instance6.Text = "Iceland"
instance6.Font = Enum.Font.GothamBold
instance6.TextSize = 13
instance6.TextXAlignment = Enum.TextXAlignment.Left

f7(instance6)

local instance7 = Instance.new("TextButton", instance5)
instance7.Size = UDim2.new(0, 18, 0, 18)
instance7.Position = UDim2.new(1, -24, 0, 8)
instance7.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
instance7.Text = "-"
instance7.Font = Enum.Font.GothamBold
instance7.TextSize = 12

Instance.new("UICorner", instance7).CornerRadius = UDim.new(0, 4)
f7(instance7)

local instance8 = Instance.new("Frame", mainFrame)
instance8.Size = UDim2.new(0, 88, 1, -44)
instance8.Position = UDim2.new(0, 5, 0, 40)
instance8.BackgroundTransparency = 1

local instance9 = Instance.new("UIListLayout", instance8)
instance9.FillDirection = Enum.FillDirection.Vertical
instance9.Padding = UDim.new(0, 6)

local v23 = {}

local function f8(p6)
  local instance10 = Instance.new("TextButton", instance8)
  instance10.Size = UDim2.new(1, 0, 0, 30)
  instance10.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
  instance10.Text = p6
  instance10.Font = Enum.Font.GothamBold
  instance10.TextSize = 9

  Instance.new("UICorner", instance10).CornerRadius = UDim.new(0, 6)
  f7(instance10)

  local instance11 = Instance.new("ScrollingFrame", mainFrame)
  instance11.Size = UDim2.new(1, -110, 1, -44)
  instance11.Position = UDim2.new(0, 100, 0, 40)
  instance11.BackgroundTransparency = 1
  instance11.ScrollBarThickness = 3
  instance11.CanvasSize = UDim2.new(0, 0, 0, 0)
  instance11.Visible = false
  instance11.AutomaticCanvasSize = Enum.AutomaticSize.Y

  local instance12 = Instance.new("UIListLayout", instance11)
  instance12.SortOrder = Enum.SortOrder.LayoutOrder
  instance12.Padding = UDim.new(0, 6)

  v23[p6] = { Btn = instance10, Container = instance11 }

  instance10.MouseButton1Click:Connect(function()
    for key5, value5 in pairs(v23) do
      value5.Container.Visible = false
      value5.Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    end

    instance11.Visible = true
    instance10.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
  end)

  return instance11
end

local main = f8("Main")
local pvP = f8("PvP")
local npcFarm = f8("NPC Farm")
local espTab = f8("ESP")
local setting = f8("Setting")

v23.Main.Container.Visible = true
v23.Main.Btn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)

local v24 = false

instance7.MouseButton1Click:Connect(function()
  local position4 = mainFrame.Position

  tweenService:Create(mainFrame, TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
    Size = UDim2.new(0, 50, 0, 50),
    BackgroundTransparency = 1,
    Position = UDim2.new(
      position4.X.Scale, position4.X.Offset + 20, position4.Y.Scale, position4.Y.Offset + 20
    ),
  }):Play()

  task.wait(0.28)

  mainFrame.Visible = false
  mainFrame.Size = UDim2.new(0, 520, 0, 320)
  mainFrame.BackgroundTransparency = 0

  openCloseButton.Position = position4
  openCloseButton.Visible = true
  openCloseButton.Size = UDim2.new(0, 0, 0, 0)

  tweenService:Create(
    openCloseButton, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    { Size = UDim2.new(0, 90, 0, 36) }
  ):Play()
end)

openCloseButton.MouseButton1Click:Connect(function()
  local position5 = openCloseButton.Position
  openCloseButton.Visible = false

  mainFrame.Position = UDim2.new(
    position5.X.Scale, position5.X.Offset - 20, position5.Y.Scale, position5.Y.Offset - 20
  )

  mainFrame.Visible = true
  mainFrame.Size = UDim2.new(0, 50, 0, 50)
  mainFrame.BackgroundTransparency = 1

  tweenService:Create(mainFrame, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 520, 0, 320),
    BackgroundTransparency = 0,
    Position = position5,
  }):Play()
end)

local v25, position6, position7

instance5.InputBegan:Connect(function(input7)
  if (input7.UserInputType == Enum.UserInputType.MouseButton1
      or input7.UserInputType == Enum.UserInputType.Touch)
    and not v24 then
    v25 = true
    position6 = input7.Position
    position7 = mainFrame.Position
  end
end)

instance5.InputEnded:Connect(function(input8)
  if input8.UserInputType == Enum.UserInputType.MouseButton1
    or input8.UserInputType == Enum.UserInputType.Touch then
    v25 = false
  end
end)

userInputService.InputChanged:Connect(function(input9)
  if v25
    and not v24
    and (input9.UserInputType == Enum.UserInputType.MouseMovement
      or input9.UserInputType == Enum.UserInputType.Touch) then
    local v26 = input9.Position - position6

    mainFrame.Position = UDim2.new(
      position7.X.Scale, position7.X.Offset + v26.X, position7.Y.Scale,
      position7.Y.Offset + v26.Y
    )
  end
end)

local function f9(p7, text, fn)
  local instance13 = Instance.new("TextButton", p7)
  instance13.Size = UDim2.new(1, -5, 0, 26)
  instance13.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
  instance13.Text = text
  instance13.Font = Enum.Font.GothamSemibold
  instance13.TextSize = 11
  instance13.AutoButtonColor = false

  Instance.new("UICorner", instance13).CornerRadius = UDim.new(0, 6)
  f7(instance13)

  instance13.MouseEnter:Connect(function()
    tweenService:Create(instance13, TweenInfo.new(0.15), {
      BackgroundColor3 = Color3.fromRGB(45, 45, 58),
    }):Play()
  end)

  instance13.MouseLeave:Connect(function()
    tweenService:Create(instance13, TweenInfo.new(0.15), {
      BackgroundColor3 = Color3.fromRGB(32, 32, 40),
    }):Play()
  end)

  instance13.MouseButton1Click:Connect(function() fn(instance13) end)

  return instance13
end

local function f10(p8, text2, p9, p10, p11, fn2)
  local instance14 = Instance.new("Frame", p8)
  instance14.Size = UDim2.new(1, -5, 0, 38)
  instance14.BackgroundColor3 = Color3.fromRGB(24, 24, 30)

  Instance.new("UICorner", instance14).CornerRadius = UDim.new(0, 6)

  local instance15 = Instance.new("TextLabel", instance14)
  instance15.Size = UDim2.new(0.6, 0, 0, 16)
  instance15.Position = UDim2.new(0, 6, 0, 2)
  instance15.BackgroundTransparency = 1
  instance15.Text = text2
  instance15.Font = Enum.Font.GothamSemibold
  instance15.TextSize = 10
  instance15.TextXAlignment = Enum.TextXAlignment.Left

  f7(instance15)

  local instance16 = Instance.new("TextBox", instance14)
  instance16.Size = UDim2.new(0.3, -5, 0, 16)
  instance16.Position = UDim2.new(0.7, 0, 0, 2)
  instance16.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
  instance16.Text = tostring(p11)
  instance16.TextColor3 = Color3.fromRGB(255, 255, 255)
  instance16.Font = Enum.Font.GothamBold
  instance16.TextSize = 10
  instance16.ClearTextOnFocus = false

  Instance.new("UICorner", instance16).CornerRadius = UDim.new(0, 4)

  local instance17 = Instance.new("Frame", instance14)
  instance17.Size = UDim2.new(1, -12, 0, 8)
  instance17.Position = UDim2.new(0, 6, 0, 24)
  instance17.BackgroundColor3 = Color3.fromRGB(40, 40, 50)

  Instance.new("UICorner", instance17).CornerRadius = UDim.new(0, 4)

  local instance18 = Instance.new("Frame", instance17)
  instance18.Size = UDim2.new((p11 - p9) / (p10 - p9), 0, 1, 0)
  instance18.BackgroundColor3 = Color3.fromRGB(180, 180, 180)

  Instance.new("UICorner", instance18).CornerRadius = UDim.new(0, 4)
  local v27 = p9
  local v28 = p10

  local function f11(p12)
    local v29 = math.clamp(p12, v27, v28)
    instance18.Size = UDim2.new((v29 - v27) / (v28 - v27), 0, 1, 0)
    instance16.Text = tostring(v29)
    fn2(v29)
  end

  instance16.FocusLost:Connect(function()
    local v30 = tonumber(instance16.Text)

    if v30 then
      f11(v30)
    else
      instance16.Text = tostring(p11)
    end
  end)

  instance17.InputBegan:Connect(function(input10)
    local v31 = input10.UserInputType == Enum.UserInputType.MouseButton1
      or input10.UserInputType == Enum.UserInputType.Touch

    local connect, connect2

    if v31 then
      v24 = true
      connect = nil
      connect2 = nil

      connect = userInputService.InputChanged:Connect(function(input11)
        if input11.UserInputType == Enum.UserInputType.MouseMovement
          or input11.UserInputType == Enum.UserInputType.Touch then
          local v32 = math.clamp(
            input11.Position.X - instance17.AbsolutePosition.X, 0, instance17.AbsoluteSize.X
          )

          f11(math.floor((v27 + (v28 - v27) * (v32 / instance17.AbsoluteSize.X)) * 10) / 10)
        end
      end)

      connect2 = userInputService.InputEnded:Connect(function(input12)
        if input12.UserInputType == Enum.UserInputType.MouseButton1
          or input12.UserInputType == Enum.UserInputType.Touch then
          v24 = false
          connect:Disconnect()
          connect2:Disconnect()
        end
      end)
    end
  end)

  return instance14, function(p13, p14, p15, p16)
    v27 = p13
    v28 = p14

    if p16 then
      instance15.Text = p16
    end

    f11(p15)
  end
end

local function f12(p17, text3, text4, fn3)
  local instance19 = Instance.new("Frame", p17)
  instance19.Size = UDim2.new(1, -5, 0, 30)
  instance19.BackgroundColor3 = Color3.fromRGB(24, 24, 30)

  Instance.new("UICorner", instance19).CornerRadius = UDim.new(0, 6)

  local instance20 = Instance.new("TextLabel", instance19)
  instance20.Size = UDim2.new(0.4, 0, 1, 0)
  instance20.Position = UDim2.new(0, 6, 0, 0)
  instance20.BackgroundTransparency = 1
  instance20.Text = text3
  instance20.Font = Enum.Font.GothamSemibold
  instance20.TextSize = 10
  instance20.TextXAlignment = Enum.TextXAlignment.Left

  f7(instance20)

  local instance21 = Instance.new("TextBox", instance19)
  instance21.Size = UDim2.new(0.55, -5, 0, 20)
  instance21.Position = UDim2.new(0.43, 0, 0.16, 0)
  instance21.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
  instance21.Text = text4
  instance21.TextColor3 = Color3.fromRGB(255, 255, 255)
  instance21.Font = Enum.Font.Gotham
  instance21.TextSize = 10
  instance21.ClearTextOnFocus = false
  instance21.TextEditable = true

  Instance.new("UICorner", instance21).CornerRadius = UDim.new(0, 4)
  instance21.FocusLost:Connect(function() fn3(instance21.Text) end)
  return instance21
end

local function f13(p18, p19, p20, fn4)
  local instance22 = Instance.new("Frame", p18)
  instance22.Size = UDim2.new(1, -5, 0, 28)
  instance22.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
  instance22.ClipsDescendants = true

  Instance.new("UICorner", instance22).CornerRadius = UDim.new(0, 6)

  local instance23 = Instance.new("TextButton", instance22)
  instance23.Size = UDim2.new(1, 0, 0, 28)
  instance23.BackgroundTransparency = 1
  instance23.Text = p19 .. ": " .. tostring(p20[1] or "")
  instance23.Font = Enum.Font.GothamSemibold
  instance23.TextSize = 11
  instance23.AutoButtonColor = false

  f7(instance23)

  local instance24 = Instance.new("Frame", instance22)
  instance24.Size = UDim2.new(1, 0, 0, #p20 * 24)
  instance24.Position = UDim2.new(0, 0, 0, 28)
  instance24.BackgroundTransparency = 1

  Instance.new("UIListLayout", instance24)
  local v33 = false

  instance23.MouseButton1Click:Connect(function()
    v33 = not v33

    instance22:TweenSize(
      UDim2.new(1, -5, 0, v33 and 28 + #p20 * 24 or 28), "Out", "Quad", 0.15, true
    )
  end)

  for index, value6 in ipairs(p20) do
    local v34 = value6

    local instance25 = Instance.new("TextButton", instance24)
    instance25.Size = UDim2.new(1, 0, 0, 24)
    instance25.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    instance25.Text = tostring(v34)
    instance25.Font = Enum.Font.Gotham
    instance25.TextSize = 10
    instance25.AutoButtonColor = false

    f7(instance25)

    instance25.MouseButton1Click:Connect(function()
      v33 = false
      instance23.Text = p19 .. ": " .. tostring(v34)
      instance22:TweenSize(UDim2.new(1, -5, 0, 28), "Out", "Quad", 0.15, true)
      fn4(v34)
    end)
  end
end

local v35 = {
  Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 120, 255),
  Color3.fromRGB(255, 255, 0), Color3.fromRGB(255, 0, 255), Color3.fromRGB(0, 255, 255),
  Color3.fromRGB(255, 165, 0), Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 255, 255),
  Color3.fromRGB(128, 0, 128), Color3.fromRGB(255, 105, 180), Color3.fromRGB(100, 100, 100),
  Color3.fromRGB(0, 0, 0), Color3.fromRGB(139, 69, 19), Color3.fromRGB(50, 205, 50),
  Color3.fromRGB(76, 255, 121), Color3.fromRGB(240, 128, 128), Color3.fromRGB(0, 128, 128),
}

local function f14(text5, p21, fn5)
  local instance26 = Instance.new("TextButton", lwginSzZUI2)
  instance26.Size = UDim2.new(1, 0, 1, 0)
  instance26.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  instance26.BackgroundTransparency = 0.5
  instance26.Text = ""
  instance26.AutoButtonColor = false
  instance26.ZIndex = 200

  local instance27 = Instance.new("Frame", instance26)
  instance27.Size = UDim2.new(0, 250, 0, 240)
  instance27.Position = UDim2.new(0.5, -125, 0.5, -120)
  instance27.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
  instance27.BorderSizePixel = 0
  instance27.ZIndex = 201

  Instance.new("UICorner", instance27).CornerRadius = UDim.new(0, 10)

  local instance28 = Instance.new("UIStroke", instance27)
  instance28.Color = Color3.fromRGB(120, 120, 160)
  instance28.Thickness = 2

  local instance29 = Instance.new("TextLabel", instance27)
  instance29.Size = UDim2.new(1, 0, 0, 26)
  instance29.Position = UDim2.new(0, 0, 0, 4)
  instance29.BackgroundTransparency = 1
  instance29.Text = text5
  instance29.Font = Enum.Font.GothamBold
  instance29.TextSize = 12
  instance29.TextColor3 = Color3.fromRGB(255, 255, 255)
  instance29.ZIndex = 202

  local instance30 = Instance.new("Frame", instance27)
  instance30.Size = UDim2.new(1, -20, 0, 70)
  instance30.Position = UDim2.new(0, 10, 0, 34)
  instance30.BackgroundTransparency = 1
  instance30.ZIndex = 202

  local instance31 = Instance.new("UIGridLayout", instance30)
  instance31.CellSize = UDim2.new(0, 28, 0, 20)
  instance31.CellPadding = UDim2.new(0, 4, 0, 4)

  local v36, v37, v38 = Color3.toHSV(p21)
  local v39 = v37
  local v40 = v38
  local color2 = p21

  local instance32 = Instance.new("Frame", instance27)
  instance32.Size = UDim2.new(1, -20, 0, 20)
  instance32.Position = UDim2.new(0, 10, 0, 112)
  instance32.ZIndex = 202

  Instance.new("UICorner", instance32).CornerRadius = UDim.new(0, 4)

  Instance.new("UIGradient", instance32).Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
  })

  local instance33 = Instance.new("Frame", instance32)
  instance33.Size = UDim2.new(0, 4, 1, 0)
  instance33.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  instance33.BorderSizePixel = 0
  instance33.ZIndex = 203
  instance33.Position = UDim2.new(v36, -2, 0, 0)

  local instance34 = Instance.new("Frame", instance27)
  instance34.Size = UDim2.new(1, -20, 0, 50)
  instance34.Position = UDim2.new(0, 10, 0, 138)
  instance34.BackgroundColor3 = Color3.fromHSV(v36, 1, 1)
  instance34.ZIndex = 202

  Instance.new("UICorner", instance34).CornerRadius = UDim.new(0, 4)

  local instance35 = Instance.new("Frame", instance34)
  instance35.Size = UDim2.new(1, 0, 1, 0)
  instance35.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  instance35.BorderSizePixel = 0
  instance35.ZIndex = 202

  Instance.new("UICorner", instance35).CornerRadius = UDim.new(0, 4)

  Instance.new("UIGradient", instance35).Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1),
  })

  local instance36 = Instance.new("Frame", instance34)
  instance36.Size = UDim2.new(1, 0, 1, 0)
  instance36.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
  instance36.BorderSizePixel = 0
  instance36.ZIndex = 202

  Instance.new("UICorner", instance36).CornerRadius = UDim.new(0, 4)

  local instance37 = Instance.new("UIGradient", instance36)
  instance37.Rotation = 90

  instance37.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0),
  })

  local instance38 = Instance.new("Frame", instance34)
  instance38.Size = UDim2.new(0, 10, 0, 10)
  instance38.BackgroundTransparency = 1
  instance38.ZIndex = 203
  instance38.Position = UDim2.new(v39, -5, 1 - v40, -5)

  local instance39 = Instance.new("UIStroke", instance38)
  instance39.Color = Color3.fromRGB(255, 255, 255)
  instance39.Thickness = 2

  Instance.new("UICorner", instance38).CornerRadius = UDim.new(1, 0)

  local instance40 = Instance.new("TextLabel", instance27)
  instance40.Size = UDim2.new(1, -20, 0, 16)
  instance40.Position = UDim2.new(0, 10, 0, 192)
  instance40.BackgroundTransparency = 1
  instance40.Text = "#" .. f2(p21)
  instance40.Font = Enum.Font.GothamBold
  instance40.TextSize = 10
  instance40.TextColor3 = Color3.fromRGB(220, 220, 220)
  instance40.ZIndex = 202

  local function f15()
    color2 = Color3.fromHSV(v36, v39, v40)
    instance40.Text = "#" .. f2(color2)
  end

  for index2, value7 in ipairs(v35) do
    local v41 = value7

    local instance41 = Instance.new("TextButton", instance30)
    instance41.BackgroundColor3 = v41
    instance41.Text = ""
    instance41.ZIndex = 203
    instance41.AutoButtonColor = false

    Instance.new("UICorner", instance41).CornerRadius = UDim.new(0, 3)

    instance41.MouseButton1Click:Connect(function()
      local v42, v43, v44 = Color3.toHSV(v41)
      v36 = v42
      v39 = v43
      v40 = v44
      instance34.BackgroundColor3 = Color3.fromHSV(v36, 1, 1)
      instance33.Position = UDim2.new(v36, -2, 0, 0)
      instance38.Position = UDim2.new(v39, -5, 1 - v40, -5)
      f15()
    end)
  end

  local v45 = false
  local v46 = false

  local function f16(p22)
    local v47 = math.clamp((p22.Position.X - instance32.AbsolutePosition.X)
      / instance32.AbsoluteSize.X, 0, 1)

    v36 = v47
    instance33.Position = UDim2.new(v47, -2, 0, 0)
    instance34.BackgroundColor3 = Color3.fromHSV(v36, 1, 1)
    f15()
  end

  local function f17(p23)
    local v48 = math.clamp((p23.Position.X - instance34.AbsolutePosition.X)
      / instance34.AbsoluteSize.X, 0, 1)

    local v49 = math.clamp((p23.Position.Y - instance34.AbsolutePosition.Y)
      / instance34.AbsoluteSize.Y, 0, 1)

    v39 = v48
    v40 = 1 - v49
    instance38.Position = UDim2.new(v48, -5, v49, -5)
    f15()
  end

  instance32.InputBegan:Connect(function(input13)
    if input13.UserInputType == Enum.UserInputType.MouseButton1
      or input13.UserInputType == Enum.UserInputType.Touch then
      v45 = true
      f16(input13)
    end
  end)

  instance34.InputBegan:Connect(function(input14)
    if input14.UserInputType == Enum.UserInputType.MouseButton1
      or input14.UserInputType == Enum.UserInputType.Touch then
      v46 = true
      f17(input14)
    end
  end)

  local connect3 = userInputService.InputChanged:Connect(function(input15)
    if input15.UserInputType == Enum.UserInputType.MouseMovement
      or input15.UserInputType == Enum.UserInputType.Touch then
      if v45 then
        f16(input15)
      elseif v46 then
        f17(input15)
      end
    end
  end)

  local connect4 = userInputService.InputEnded:Connect(function(input16)
    if input16.UserInputType == Enum.UserInputType.MouseButton1
      or input16.UserInputType == Enum.UserInputType.Touch then
      v45 = false
      v46 = false
    end
  end)

  local instance42 = Instance.new("TextButton", instance27)
  instance42.Size = UDim2.new(0.45, 0, 0, 26)
  instance42.Position = UDim2.new(0.03, 0, 1, -32)
  instance42.BackgroundColor3 = Color3.fromRGB(60, 120, 70)
  instance42.Text = "OK"
  instance42.Font = Enum.Font.GothamBold
  instance42.TextSize = 11
  instance42.TextColor3 = Color3.fromRGB(255, 255, 255)
  instance42.ZIndex = 203
  instance42.AutoButtonColor = false

  Instance.new("UICorner", instance42).CornerRadius = UDim.new(0, 5)

  instance42.MouseButton1Click:Connect(function()
    fn5(color2)
    connect3:Disconnect()
    connect4:Disconnect()
    instance26:Destroy()
  end)

  local instance43 = Instance.new("TextButton", instance27)
  instance43.Size = UDim2.new(0.45, 0, 0, 26)
  instance43.Position = UDim2.new(0.52, 0, 1, -32)
  instance43.BackgroundColor3 = Color3.fromRGB(120, 60, 60)
  instance43.Text = "Cancel"
  instance43.Font = Enum.Font.GothamBold
  instance43.TextSize = 11
  instance43.TextColor3 = Color3.fromRGB(255, 255, 255)
  instance43.ZIndex = 203
  instance43.AutoButtonColor = false

  Instance.new("UICorner", instance43).CornerRadius = UDim.new(0, 5)

  instance43.MouseButton1Click:Connect(function()
    connect3:Disconnect()
    connect4:Disconnect()
    instance26:Destroy()
  end)
end

local v50 = 0
local v51

local function f18()
  local v52 = v51
  local v53 = tick()

  if v52 and v51.Parent then
    local humanoid3 = v51:FindFirstChildOfClass("Humanoid")

    if humanoid3 and humanoid3.Health > 0 then
      return v51
    end
  end

  if v53 - v50 < 0.4 then
    return v51
  else
    local health = -1
    v50 = v53
    v51 = nil

    for key6, value8 in pairs(v1:GetDescendants()) do
      if value8:IsA("Model") and string.find(string.lower(value8.Name), "npc2") then
        local humanoid4 = value8:FindFirstChildOfClass("Humanoid")

        if humanoid4 and value8:FindFirstChild("HumanoidRootPart") and humanoid4.Health > 0
          and not players:GetPlayerFromCharacter(value8) then
          if humanoid4.Health > health then
            health = humanoid4.Health
            v51 = value8
          end
        end
      end
    end

    return v51
  end
end

local function f19(p24)
  local position8

  if not p24 then
    return
  else
    local humanoidRootPart2 = p24:FindFirstChild("HumanoidRootPart")

    if not humanoidRootPart2 then
      return
    else
      position8 = humanoidRootPart2.Position
      pcall(function() localPlayer:RequestStreamAroundAsync(position8, 2) end)
      local character5 = localPlayer.Character
      local humanoidRootPart3 = character5 and character5:FindFirstChild("HumanoidRootPart")

      if not humanoidRootPart3 then
        return
      else
        local v54 = humanoidRootPart3.Position - position8
        local vector = Vector3.new(v54.X, 0, v54.Z)

        if vector.Magnitude < 0.1 then
          vector = Vector3.new(0, 0, 1)
        end

        local unit2 = vector.Unit

        humanoidRootPart3.CFrame = CFrame.lookAt(position8 + unit2 * 4, Vector3.new(
          position8.X, position8.Y, position8.Z
        ))

        humanoidRootPart3.AssemblyLinearVelocity = Vector3.zero
        humanoidRootPart3.AssemblyAngularVelocity = Vector3.zero

        return
      end
    end
  end
end

local v55 = 0
local v56

local function f20()
  local v57 = tick()

  if v56 and v56.Parent then
    local humanoid5 = v56:FindFirstChildOfClass("Humanoid")

    if humanoid5 and humanoid5.Health > 0 then
      return v56
    end
  end

  if v57 - v55 < 0.3 then
    return v56
  end

  v55 = v57
  v56 = nil

  for key7, value9 in pairs(v1:GetDescendants()) do
    if value9:IsA("Model") and string.find(string.lower(value9.Name), "citynpc") then
      local humanoid6 = value9:FindFirstChildOfClass("Humanoid")

      if humanoid6 and value9:FindFirstChild("HumanoidRootPart") and humanoid6.Health > 0
        and not players:GetPlayerFromCharacter(value9) then
        v56 = value9
        break
      end
    end
  end

  return v56
end

local v58, v59

local function f21()
  v3.AutoHeal = not v3.AutoHeal
  local text6 = "Auto Sử Dụng Băng Gạc (HP<100): " .. (v3.AutoHeal and "ON" or "OFF")

  if v58 then v58.Text = text6 end
  if v59 then v59.Text = text6 end
end

f9(main, "FreeCam Mobile: OFF", function(p25)
  if not v10 then
    f3()
  else
    f4()
  end

  p25.Text = "FreeCam Mobile: " .. (v10 and "ON" or "OFF")
end)

f9(main, "TP TO CAM", function() f5() end)

f9(main, "Dịch Chuyển Đến NPC2", function()
  local v60 = f18()

  if v60 then
    f19(v60)
  end
end)

f9(main, "Dịch Chuyển Đến CityNPC", function()
  local v61 = f20()

  if v61 then
    f19(v61)
  end
end)

v58 = f9(main, "Auto Sử Dụng Băng Gạc (HP<100): OFF", function() f21() end)

f13(main, "Kiểu Farm", { "Farm Bình Thường", "Farm An Toàn" }, function(p26)
  if p26 == "Farm Bình Thường" then
    v3.SafeFarm = false
  elseif p26 == "Farm An Toàn" then
    v3.SafeFarm = true
  end
end)

local v62, v63 = f10(main, "Tốc Độ Model 1", 10, 500, v3.Model1Speed, function(p27)
  if v3.FarmMode == 1 then
    v3.Model1Speed = p27
  elseif v3.FarmMode == 2 then
    v3.Model2Speed = p27
  elseif v3.FarmMode == 3 then
    v3.Model3Speed = p27
  elseif v3.FarmMode == 4 then
    v3.Model4Speed = p27
  end
end)

f13(main, "Chọn Model", {
  "Model 1 (Xoay)", "Model 2 (4 Hướng)", "Model 3 (Trái/Phải Nhanh)",
  "Model 4 (Spin 360)",
}, function(p28)
  if p28 == "Model 1 (Xoay)" then
    v3.FarmMode = 1
    v63(10, 500, v3.Model1Speed, "Tốc Độ Model 1")
  elseif p28 == "Model 2 (4 Hướng)" then
    v3.FarmMode = 2
    v63(1, 20, v3.Model2Speed, "Tốc Độ Model 2 (Hz)")
  elseif p28 == "Model 3 (Trái/Phải Nhanh)" then
    v3.FarmMode = 3
    v63(1, 30, v3.Model3Speed, "Tốc Độ Model 3 (Hz)")
  elseif p28 == "Model 4 (Spin 360)" then
    v3.FarmMode = 4
    v63(50, 500, v3.Model4Speed, "Tốc Độ Model 4")
  end
end)

f9(main, "Auto Farm Level: OFF", function(p29)
  v3.FarmLevel = not v3.FarmLevel

  if v3.FarmLevel then
    v3.FarmBoss = false
  end

  p29.Text = "Auto Farm Level: " .. (v3.FarmLevel and "ON" or "OFF")
end)

f9(main, "Auto Farm Boss: OFF", function(p30)
  v3.FarmBoss = not v3.FarmBoss

  if v3.FarmBoss then
    v3.FarmLevel = false
    v3.SafeFarm = false
  end

  p30.Text = "Auto Farm Boss: " .. (v3.FarmBoss and "ON" or "OFF")
end)

f9(main, "Khoá Di Chuyển Khi Farm: OFF", function(p31)
  v3.FreezeMoveOnFarm = not v3.FreezeMoveOnFarm
  p31.Text = "Khoá Di Chuyển Khi Farm: " .. (v3.FreezeMoveOnFarm and "ON" or "OFF")
end)

f9(main, "Khóa NPC: OFF", function(p32)
  v3.FreezeNPC = not v3.FreezeNPC
  p32.Text = "Khóa NPC: " .. (v3.FreezeNPC and "ON" or "OFF")
end)

f9(main, "Khóa Boss: OFF", function(p33)
  v3.FreezeBoss = not v3.FreezeBoss
  p33.Text = "Khóa Boss: " .. (v3.FreezeBoss and "ON" or "OFF")
end)

f9(main, "HPBar NPC2: ON", function(p34)
  v3.ShowNPC2HpBar = not v3.ShowNPC2HpBar
  p34.Text = "HPBar NPC2: " .. (v3.ShowNPC2HpBar and "ON" or "OFF")

  if BossBarFrame then
    BossBarFrame.Visible = v3.ShowNPC2HpBar
  end
end)

f10(main, "Khoảng Cách Farm (studs)", 5, 100, v3.Distance, function(distance)
  v3.Distance = distance
end)

f10(main, "Độ Sâu An Toàn (studs)", 5, 30, v3.SafeFarmDepth, function(safeFarmDepth)
  v3.SafeFarmDepth = safeFarmDepth
end)

f9(main, "Auto Lụm Proximity: OFF", function(p35)
  v3.AutoLoot = not v3.AutoLoot
  p35.Text = "Auto Lụm Proximity: " .. (v3.AutoLoot and "ON" or "OFF")
end)

f10(main, "Stud Nhặt Proximity", 5, 100, v3.LootDistance, function(lootDistance)
  v3.LootDistance = lootDistance
end)

v59 = f9(pvP, "Auto Sử Dụng Băng Gạc (HP<100): OFF", function() f21() end)

f9(main, "Auto Buy Băng Gạc: OFF", function(p36)
  v3.AutoBuyBandage = not v3.AutoBuyBandage
  p36.Text = "Auto Buy Băng Gạc: " .. (v3.AutoBuyBandage and "ON" or "OFF")
end)

f10(main, "Số Băng Mua Mỗi Lần", 1, 50, v3.BuyBandageAmount, function(p37)
  v3.BuyBandageAmount = math.floor(p37)
end)

local attackToggleBtn = Instance.new("TextButton", lwginSzZUI2)
attackToggleBtn.Name = "AttackToggleBtn"
attackToggleBtn.Size = UDim2.new(0, 50, 0, 50)
attackToggleBtn.Position = UDim2.new(0, 20, 0, 200)
attackToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
attackToggleBtn.BackgroundTransparency = 0.3
attackToggleBtn.Text = "ATK"
attackToggleBtn.Font = Enum.Font.GothamBold
attackToggleBtn.TextSize = 12
attackToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
attackToggleBtn.Visible = false
attackToggleBtn.Active = true
attackToggleBtn.AutoButtonColor = false
attackToggleBtn.ZIndex = 100

Instance.new("UICorner", attackToggleBtn).CornerRadius = UDim.new(1, 0)

local instance44 = Instance.new("UIStroke", attackToggleBtn)
instance44.Thickness = 3
instance44.Color = Color3.fromRGB(255, 255, 255)

local v64, position9, position10, v65

attackToggleBtn.InputBegan:Connect(function(input17)
  if input17.UserInputType == Enum.UserInputType.MouseButton1
    or input17.UserInputType == Enum.UserInputType.Touch then
    v64 = true
    v65 = false
    position9 = input17.Position
    position10 = attackToggleBtn.Position
  end
end)

attackToggleBtn.InputEnded:Connect(function(input18)
  if input18.UserInputType == Enum.UserInputType.MouseButton1
    or input18.UserInputType == Enum.UserInputType.Touch then
    v64 = false

    if not v65 then
      v3.AutoAttack = false
      attackToggleBtn.Visible = false

      if AutoAttackBtnUI then
        AutoAttackBtnUI.Text = "Auto Attack Tool: OFF"
      end
    end
  end
end)

userInputService.InputChanged:Connect(function(input19)
  if v64
    and (input19.UserInputType == Enum.UserInputType.MouseMovement
      or input19.UserInputType == Enum.UserInputType.Touch) then
    local v66 = input19.Position - position9

    if math.abs(v66.X) > 4 or math.abs(v66.Y) > 4 then
      v65 = true
    end

    attackToggleBtn.Position = UDim2.new(
      position10.X.Scale, position10.X.Offset + v66.X, position10.Y.Scale,
      position10.Y.Offset + v66.Y
    )
  end
end)

f9(pvP, "Auto Attack Tool: OFF", function(p38)
  v3.AutoAttack = not v3.AutoAttack
  p38.Text = "Auto Attack Tool: " .. (v3.AutoAttack and "ON" or "OFF")
  attackToggleBtn.Visible = v3.AutoAttack
end)

f9(pvP, "Aim Nearest Player: OFF", function(p39)
  v3.AimNearest = not v3.AimNearest
  p39.Text = "Aim Nearest Player: " .. (v3.AimNearest and "ON" or "OFF")
end)

f9(pvP, "HP ESP All Player: OFF", function(p40)
  v3.PlayerHPESP = not v3.PlayerHPESP
  p40.Text = "HP ESP All Player: " .. (v3.PlayerHPESP and "ON" or "OFF")
end)

f9(pvP, "Highlight Player ESP: OFF", function(p41)
  v3.PlayerHighlight = not v3.PlayerHighlight
  p41.Text = "Highlight Player ESP: " .. (v3.PlayerHighlight and "ON" or "OFF")
end)

-- Hidden compatibility label retained for legacy animation callbacks; no Fake Ani tab is shown.
local instance45 = Instance.new("TextLabel", npcFarm)
instance45.Visible = false
instance45.Size = UDim2.new(1, -5, 0, 20)
instance45.Text = ""

-- NPC Farm tab: scan NPCs and teleport to the selected NPC.
local npcList = {}
local selectedNpc = nil
local npcStatus = f9(npcFarm, "Quét NPC / Boss", function(btn)
  npcList = {}
  for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") and obj ~= player.Character then
      local hum = obj:FindFirstChildOfClass("Humanoid")
      local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
      if hum and root and hum.Health > 0 then
        table.insert(npcList, obj)
      end
    end
  end
  btn.Text = "Đã quét: " .. tostring(#npcList) .. " NPC"
  selectedNpc = npcList[1]
end)
f9(npcFarm, "Chọn NPC tiếp theo", function(btn)
  if #npcList == 0 then btn.Text = "Hãy quét NPC trước"; return end
  local idx = 1
  for i, model in ipairs(npcList) do if model == selectedNpc then idx = i; break end end
  idx = idx % #npcList + 1
  selectedNpc = npcList[idx]
  btn.Text = "NPC: " .. selectedNpc.Name
end)
f9(npcFarm, "Teleport tới NPC đã chọn", function(btn)
  local char = player.Character
  local root = char and char:FindFirstChild("HumanoidRootPart")
  local targetRoot = selectedNpc and (selectedNpc:FindFirstChild("HumanoidRootPart") or selectedNpc.PrimaryPart)
  if root and targetRoot then
    root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 8)
    btn.Text = "Đã tới: " .. selectedNpc.Name
  else
    btn.Text = "Quét và chọn NPC trước"
  end
end)

-- ESP tab: highlight NPCs and bosses locally.
local npcEspOn, bossEspOn = false, false
local espObjects = {}
local function clearEsp()
  for model, gui in pairs(espObjects) do if gui and gui.Parent then gui:Destroy() end end
  table.clear(espObjects)
end
local function refreshEsp()
  clearEsp()
  if not npcEspOn and not bossEspOn then return end
  for _, obj in ipairs(workspace:GetDescendants()) do
    if obj:IsA("Model") and obj ~= player.Character then
      local hum = obj:FindFirstChildOfClass("Humanoid")
      local root = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart
      if hum and root and hum.Health > 0 then
        local isBoss = string.find(string.lower(obj.Name), "boss", 1, true) ~= nil
        if (isBoss and bossEspOn) or (not isBoss and npcEspOn) then
          local gui = Instance.new("BillboardGui")
          gui.Name = "IcelandESP"; gui.Adornee = root; gui.Size = UDim2.new(0, 150, 0, 42)
          gui.StudsOffset = Vector3.new(0, 3, 0); gui.AlwaysOnTop = true; gui.Parent = root
          local label = Instance.new("TextLabel", gui)
          label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
          label.TextColor3 = isBoss and Color3.fromRGB(255, 90, 90) or Color3.fromRGB(240, 240, 240)
          label.TextStrokeTransparency = 0.25; label.Font = Enum.Font.GothamBold; label.TextSize = 12
          label.Text = obj.Name .. " | HP " .. math.floor(hum.Health) .. "/" .. math.floor(hum.MaxHealth)
          espObjects[obj] = gui
        end
      end
    end
  end
end
f9(espTab, "ESP NPC: OFF", function(btn)
  npcEspOn = not npcEspOn; btn.Text = "ESP NPC: " .. (npcEspOn and "ON" or "OFF"); refreshEsp()
end)
f9(espTab, "ESP Boss: OFF", function(btn)
  bossEspOn = not bossEspOn; btn.Text = "ESP Boss: " .. (bossEspOn and "ON" or "OFF"); refreshEsp()
end)
f9(espTab, "Cập nhật ESP / HP Boss", function(btn)
  refreshEsp(); btn.Text = "Đã cập nhật ESP"
end)

local v73 = {
  BVK = {
    idle = "rbxassetid://105595991838451",
    run = "rbxassetid://79060388054386",
    attack = nil,
  },
  HLONG = {
    idle = "rbxassetid://98041738504976",
    run = "rbxassetid://80944746788194",
    attack = "rbxassetid://104679203126070",
  },
  NHULAI = {
    idle = "rbxassetid://115749069647823",
    run = "rbxassetid://109302802567600",
    attack = "rbxassetid://115749069647823",
  },
}

local function f27()
  return v73[v3.AnimSet] or v73.BVK
end

local v74 = {
  active = false,
  char = nil,
  tool = nil,
  animator = nil,
  hum = nil,
  idleTrack = nil,
  runTrack = nil,
  atkTrack = nil,
  interceptConn = nil,
  moveConn = nil,
  guardConn = nil,
  atkConns = {},
  savedAnimate = nil,
  set = nil,
  allowOriginalAttack = false,
}

local function f28()
  for key10, value16 in pairs(v74.savedAnimate or {}) do
    local v75 = key10
    local disabled = value16

    pcall(function()
      if v75 and v75.Parent then
        v75.Disabled = disabled
      end
    end)
  end

  v74.savedAnimate = {}
end

local function f29(p48, p49)
  if p48 == v74.idleTrack or p48 == v74.runTrack or p48 == v74.atkTrack then
    return true
  else
    local animationId = p48.Animation and p48.Animation.AnimationId or ""

    if animationId == p49.idle or animationId == p49.run then
      return true
    end

    if p49.attack and animationId == p49.attack then
      return true
    elseif v74.allowOriginalAttack then
      local priority = p48.Priority

      if priority == Enum.AnimationPriority.Action or priority == Enum.AnimationPriority.Action2
        or priority == Enum.AnimationPriority.Action3
        or priority == Enum.AnimationPriority.Action4 then
        return true
      end

      return false
    else
      return false
    end
  end
end

local function f30(p50)
  v74.savedAnimate = {}

  if p50 then
    local animate = p50:FindFirstChild("Animate")

    if animate and animate:IsA("BaseScript") then
      v74.savedAnimate[animate] = animate.Disabled
      animate.Disabled = true
    end
  end
end

local function f31(p51)
  pcall(function() p51:Stop(0) end)
end

local function f32(p52)
  if v74.interceptConn then
    pcall(function() v74.interceptConn:Disconnect() end)
    v74.interceptConn = nil
  end

  if v74.moveConn then
    pcall(function() v74.moveConn:Disconnect() end)
    v74.moveConn = nil
  end

  if v74.guardConn then
    pcall(function() v74.guardConn:Disconnect() end)
    v74.guardConn = nil
  end

  for index7, value17 in ipairs(v74.atkConns) do
    local v76 = value17
    pcall(function() v76:Disconnect() end)
  end

  v74.atkConns = {}

  if v74.idleTrack then
    pcall(function() v74.idleTrack:Stop(0) end)
  end

  if v74.runTrack then
    pcall(function() v74.runTrack:Stop(0) end)
  end

  if v74.atkTrack then
    pcall(function() v74.atkTrack:Stop(0) end)
  end

  f28()

  v74.active = false
  v74.char = nil
  v74.tool = nil
  v74.animator = nil
  v74.hum = nil
  v74.idleTrack = nil
  v74.runTrack = nil
  v74.atkTrack = nil
  v74.set = nil
  v74.allowOriginalAttack = false
end

local function f33(p53, p54)
  if not p53 or not p54 then
    return
  end

  local humanoid7, v77, loadAnimation, loadAnimation2, loadAnimation3

  if v74.active and v74.tool == p54 and v74.char == p53 then
    return
  else
    f32(p53)
    humanoid7 = p53:FindFirstChildOfClass("Humanoid")
    local animator = humanoid7 and humanoid7:FindFirstChildOfClass("Animator")

    if not animator then
      return
    else
      v77 = f27()

      v74.active = true
      v74.char = p53
      v74.tool = p54
      v74.animator = animator
      v74.hum = humanoid7
      v74.set = v77
      v74.allowOriginalAttack = v77.attack == nil

      f30(p53)

      for index8, value18 in ipairs(animator:GetPlayingAnimationTracks()) do
        f31(value18)
      end

      local animation = Instance.new("Animation")
      animation.AnimationId = v77.idle

      loadAnimation = animator:LoadAnimation(animation)
      loadAnimation.Priority = Enum.AnimationPriority.Action
      loadAnimation.Looped = true

      local animation2 = Instance.new("Animation")
      animation2.AnimationId = v77.run

      loadAnimation2 = animator:LoadAnimation(animation2)
      loadAnimation2.Priority = Enum.AnimationPriority.Action
      loadAnimation2.Looped = true

      v74.idleTrack = loadAnimation
      v74.runTrack = loadAnimation2

      loadAnimation:Play(0.1)

      if v77.attack then
        local animation3 = Instance.new("Animation")
        animation3.AnimationId = v77.attack

        loadAnimation3 = animator:LoadAnimation(animation3)
        loadAnimation3.Priority = Enum.AnimationPriority.Action4
        loadAnimation3.Looped = true

        v74.atkTrack = loadAnimation3

        local connect5 = p54.Activated:Connect(function()
          pcall(function()
            if not loadAnimation3.IsPlaying then
              loadAnimation3:Play(0.05)
            end
          end)
        end)

        local connect6 = p54.Deactivated:Connect(function()
          pcall(function() loadAnimation3:Stop(0.1) end)
        end)

        table.insert(v74.atkConns, connect5)
        table.insert(v74.atkConns, connect6)
      end

      v74.moveConn = runService.Heartbeat:Connect(function()
        if not v74.active or v74.animator ~= animator then
          return
        end

        if humanoid7.MoveDirection.Magnitude > 0.1 then
          if not loadAnimation2.IsPlaying then
            pcall(function() loadAnimation:Stop(0.1) end)
            pcall(function() loadAnimation2:Play(0.1) end)
          end
        elseif not loadAnimation.IsPlaying then
          pcall(function() loadAnimation2:Stop(0.1) end)
          pcall(function() loadAnimation:Play(0.1) end)
        end
      end)

      v74.interceptConn = animator.AnimationPlayed:Connect(function(p55)
        if not v74.active then
          return
        end

        if not f29(p55, v77) then
          f31(p55)
        end
      end)

      v74.guardConn = runService.Heartbeat:Connect(function()
        if not v74.active then
          return
        end

        if humanoid7.MoveDirection.Magnitude > 0.1 then
          if not loadAnimation2.IsPlaying and not (v74.atkTrack and v74.atkTrack.IsPlaying) then
            pcall(function() loadAnimation2:Play(0.1) end)
          end
        elseif not loadAnimation.IsPlaying and not (v74.atkTrack and v74.atkTrack.IsPlaying) then
          pcall(function() loadAnimation:Play(0.1) end)
        end
      end)

      return
    end
  end
end

f9(npcFarm, "Fake Ani Hiện Tại: OFF", function(p56)
  if not v3.SelectedToolName and not v3.FakeAniApplyAll then
    instance45.Text = "⚠ Chưa chọn Tool (Cách 1) hoặc chưa bật Cách 2!"
    return
  end

  v3.FakeAniEnabled = not v3.FakeAniEnabled
  p56.Text = "Fake Ani Hiện Tại: " .. (v3.FakeAniEnabled and "ON" or "OFF")

  if not v3.FakeAniEnabled then
    local character6 = localPlayer.Character

    if character6 then
      pcall(f32, character6)
    end
  end
end)

local function f34(p57)
  p57.ChildAdded:Connect(function(child)
    if child:IsA("Tool") and v3.FakeAniEnabled then
      if v3.FakeAniApplyAll or v3.SelectedToolName and child.Name == v3.SelectedToolName then
        pcall(f33, p57, child)
      end
    end
  end)

  p57.ChildRemoved:Connect(function(child2)
    if child2:IsA("Tool") and v74.tool == child2 then
      pcall(f32, p57)
    end
  end)
end

task.spawn(function()
  while true do
    local character7 = localPlayer.Character

    if character7 then
      pcall(f34, character7)
      local tool = character7:FindFirstChildOfClass("Tool")

      if v3.FakeAniEnabled and tool then
        local npcFarmApplyAll = v3.FakeAniApplyAll
          or v3.SelectedToolName and tool.Name == v3.SelectedToolName

        if npcFarmApplyAll and v74.tool ~= tool then
          pcall(f33, character7, tool)
        elseif not npcFarmApplyAll and v74.tool then
          pcall(f32, character7)
        end
      elseif not v3.FakeAniEnabled and v74.tool then
        pcall(f32, character7)
      end
    end

    task.wait(1)
  end
end)

f12(setting, "Tên Rank:", v3.CustomRankText, function(p58)
  if p58 and p58 ~= "" then
    v3.CustomRankText = p58
  end
end)

f12(setting, "Username:", v3.CustomUsername, function(p59) v3.CustomUsername = p59 or "" end)
f12(setting, "Level (Lv):", v3.LevelText, function(p60) v3.LevelText = p60 or "1" end)

f12(setting, "Displayname:", v3.CustomDisplayname, function(p61)
  v3.CustomDisplayname = p61 or ""
end)

f9(setting, "Chọn Màu Rank", function()
  f14("Màu Rank", v3.CustomRankColor, function(customRankColor)
    v3.CustomRankColor = customRankColor
  end)
end)

f9(setting, "Chọn Màu Level", function()
  f14("Màu Level", v3.LevelColor, function(levelColor) v3.LevelColor = levelColor end)
end)

f9(setting, "Chọn Màu Username", function()
  f14("Màu Username", v3.UsernameColor, function(usernameColor)
    v3.UsernameColor = usernameColor
  end)
end)

f9(setting, "Chọn Màu Displayname", function()
  f14("Màu Displayname", v3.DisplaynameColor, function(displaynameColor)
    v3.DisplaynameColor = displaynameColor
  end)
end)

f9(setting, "Màu Rank Rainbow: OFF", function(p62)
  v3.RankRainbow = not v3.RankRainbow
  p62.Text = "Màu Rank Rainbow: " .. (v3.RankRainbow and "ON" or "OFF")
end)

f9(setting, "Level Rainbow: OFF", function(p63)
  v3.LevelRainbow = not v3.LevelRainbow
  p63.Text = "Level Rainbow: " .. (v3.LevelRainbow and "ON" or "OFF")
end)

f9(setting, "Username Rainbow: OFF", function(p64)
  v3.UsernameRainbow = not v3.UsernameRainbow
  p64.Text = "Username Rainbow: " .. (v3.UsernameRainbow and "ON" or "OFF")
end)

f9(setting, "Displayname Rainbow: OFF", function(p65)
  v3.DisplaynameRainbow = not v3.DisplaynameRainbow
  p65.Text = "Displayname Rainbow: " .. (v3.DisplaynameRainbow and "ON" or "OFF")
end)

f9(setting, "Gui Nhỏ", function()
  v3.GuiSizeMode = "Nhỏ"
  v3.UIScale = 0.7
  instance.Scale = 0.7
end)

f9(setting, "Gui Vừa", function()
  v3.GuiSizeMode = "Vừa"
  v3.UIScale = 0.85
  instance.Scale = 0.85
end)

f9(setting, "Gui Mặc Định (Auto)", function()
  v3.GuiSizeMode = "Mặc Định"
  v3.UIScale = f1()
  instance.Scale = v3.UIScale
end)

f9(setting, "Gui To", function()
  v3.GuiSizeMode = "To"
  v3.UIScale = 1.3
  instance.Scale = 1.3
end)

f9(setting, "Viền Đen/Trắng: Đổi Màu", function(p66)
  local isWhite = instance2.Color.R < 0.5
  instance2.Color = isWhite and Color3.fromRGB(245, 245, 245) or Color3.fromRGB(0, 0, 0)
  instance3.Color = isWhite and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(245, 245, 245)
  p66.Text = isWhite and "Viền Trắng/Đen: ON" or "Viền Đen/Trắng: ON"
end)

-- Hiệu ứng mưa và sao băng chỉ chạy trong khung menu Iceland.
local rainEnabled = false
local meteorEnabled = false
local effectLayer = Instance.new("Frame", mainFrame)
effectLayer.Name = "IcelandEffects"
effectLayer.Size = UDim2.new(1, 0, 1, 0)
effectLayer.BackgroundTransparency = 1
effectLayer.BorderSizePixel = 0
effectLayer.ClipsDescendants = true
effectLayer.ZIndex = 0

local rainFolder = Instance.new("Folder", effectLayer)
rainFolder.Name = "RainDrops"
local meteorFolder = Instance.new("Folder", effectLayer)
meteorFolder.Name = "Meteors"

local function makeRainDrop()
  local drop = Instance.new("Frame")
  drop.Name = "RainDrop"
  drop.BorderSizePixel = 0
  drop.BackgroundColor3 = Color3.fromRGB(210, 225, 255)
  drop.BackgroundTransparency = 0.35
  drop.Size = UDim2.new(0, 1, 0, math.random(7, 13))
  drop.Position = UDim2.new(math.random(), 0, 0, -15)
  drop.Rotation = 12
  drop.ZIndex = 1
  drop.Parent = rainFolder
  return drop
end

local function makeMeteor()
  local meteor = Instance.new("Frame")
  meteor.Name = "ShootingStar"
  meteor.BorderSizePixel = 0
  meteor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  meteor.BackgroundTransparency = 0.05
  meteor.Size = UDim2.new(0, math.random(18, 34), 0, 2)
  meteor.Position = UDim2.new(math.random(25, 100) / 100, 0, math.random(0, 35) / 100, 0)
  meteor.Rotation = 35
  meteor.ZIndex = 1
  meteor.Parent = meteorFolder
  local stroke = Instance.new("UIStroke", meteor)
  stroke.Color = Color3.fromRGB(180, 205, 255)
  stroke.Thickness = 1
  tweenService:Create(meteor, TweenInfo.new(0.8, Enum.EasingStyle.Linear), {
    Position = UDim2.new(-0.15, 0, math.random(45, 85) / 100, 0),
    BackgroundTransparency = 1
  }):Play()
  task.delay(0.85, function()
    if meteor and meteor.Parent then meteor:Destroy() end
  end)
end

f9(setting, "Hiệu Ứng Mưa: OFF", function(btn)
  rainEnabled = not rainEnabled
  btn.Text = "Hiệu Ứng Mưa: " .. (rainEnabled and "ON" or "OFF")
  if not rainEnabled then rainFolder:ClearAllChildren() end
end)

f9(setting, "Sao Băng: OFF", function(btn)
  meteorEnabled = not meteorEnabled
  btn.Text = "Sao Băng: " .. (meteorEnabled and "ON" or "OFF")
  if not meteorEnabled then meteorFolder:ClearAllChildren() end
end)

task.spawn(function()
  while lwginSzZUI2.Parent do
    if rainEnabled and mainFrame.Visible then
      for _ = 1, 3 do
        local drop = makeRainDrop()
        tweenService:Create(drop, TweenInfo.new(0.55, Enum.EasingStyle.Linear), {
          Position = UDim2.new(drop.Position.X.Scale, 0, 1.05, 0),
          BackgroundTransparency = 1
        }):Play()
        task.delay(0.6, function()
          if drop and drop.Parent then drop:Destroy() end
        end)
      end
    end
    if meteorEnabled and mainFrame.Visible and math.random() < 0.22 then
      makeMeteor()
    end
    task.wait(0.12)
  end
end)

local function f35(p67)
  local v79 = "https://games.roblox.com/v1/games/" .. game.PlaceId
    .. "/servers/Public?sortOrder=" .. (p67 and "Asc" or "Desc") .. "&limit=100"

  local v80, v81 = pcall(function() return game:HttpGet(v79) end)

  if v80 then
    for key11, value19 in pairs(httpService:JSONDecode(v81).data) do
      if value19.playing < value19.maxPlayers and value19.id ~= game.JobId then
        teleportService:TeleportToPlaceInstance(game.PlaceId, value19.id, localPlayer)
        break
      end
    end
  end
end

f9(setting, "Rejoin Server", function()
  teleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, localPlayer)
end)

f9(setting, "Server Hop (Ít Người)", function() f35(true) end)
f9(setting, "Server Hop (Nhiều Người)", function() f35(false) end)

local function f36(p68)
  if p68 == "Nhẹ" then
    for key12, value20 in pairs(v1:GetDescendants()) do
      if value20:IsA("ParticleEmitter") or value20:IsA("Trail") or value20:IsA("Smoke")
        or value20:IsA("Fire") then
        value20.Enabled = false
      end
    end
  elseif p68 == "Trung Bình" then
    lighting.GlobalShadows = false
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
  elseif p68 == "Mạnh" then
    for key13, value21 in pairs(v1:GetDescendants()) do
      if value21:IsA("Decal") or value21:IsA("Texture") then
        value21:Destroy()
      end
    end
  elseif p68 == "Siêu Mạnh" then
    for key14, value22 in pairs(v1:GetDescendants()) do
      if value22:IsA("BasePart") then
        value22.Material = Enum.Material.SmoothPlastic
      end
    end
  end
end

f13(
  setting, "Chế Độ Đồ Họa",
  { "Mặc Định", "Nhẹ", "Trung Bình", "Mạnh", "Siêu Mạnh" },
  function(p69) f36(p69) end
)

local v82 = {
  ["Mặc Định"] = Color3.fromRGB(18, 18, 22),
  ["Đen"] = Color3.fromRGB(10, 10, 10),
  ["Trắng"] = Color3.fromRGB(220, 220, 220),
  ["Xanh Lá"] = Color3.fromRGB(20, 60, 35),
  ["Xanh Dương"] = Color3.fromRGB(20, 45, 75),
  ["Đỏ"] = Color3.fromRGB(75, 20, 25),
  ["Hồng"] = Color3.fromRGB(75, 25, 55),
  ["Vàng"] = Color3.fromRGB(75, 65, 20),
  Cam = Color3.fromRGB(80, 45, 15),
  ["Tím"] = Color3.fromRGB(50, 20, 75),
}

f13(setting, "Màu Giao Diện", {
  "Mặc Định", "Đen", "Trắng", "Xanh Lá", "Xanh Dương", "Đỏ", "Hồng", "Vàng",
  "Cam", "Tím",
}, function(p70)
  if v82[p70] then
    mainFrame.BackgroundColor3 = v82[p70]
  end
end)

local bossBarFrame = Instance.new("Frame", lwginSzZUI2)
bossBarFrame.Name = "BossBarFrame"
bossBarFrame.Size = UDim2.new(0, 260, 0, 78)
bossBarFrame.Position = UDim2.new(0.5, -130, 0, 10)
bossBarFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
bossBarFrame.BorderSizePixel = 0
bossBarFrame.Visible = v3.ShowNPC2HpBar
bossBarFrame.Active = true

Instance.new("UICorner", bossBarFrame).CornerRadius = UDim.new(0, 8)

local instance53 = Instance.new("UIStroke", bossBarFrame)
instance53.Thickness = 2
instance53.Color = Color3.fromRGB(120, 40, 40)

local instance54 = Instance.new("Frame", bossBarFrame)
instance54.Size = UDim2.new(1, 0, 0, 20)
instance54.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
instance54.BorderSizePixel = 0

Instance.new("UICorner", instance54).CornerRadius = UDim.new(0, 8)

local instance55 = Instance.new("TextLabel", instance54)
instance55.Size = UDim2.new(1, -8, 1, 0)
instance55.Position = UDim2.new(0, 4, 0, 0)
instance55.BackgroundTransparency = 1
instance55.Text = "NPC2 - Boss"
instance55.Font = Enum.Font.GothamBold
instance55.TextSize = 11
instance55.TextXAlignment = Enum.TextXAlignment.Left

f7(instance55)

local instance56 = Instance.new("Frame", bossBarFrame)
instance56.Size = UDim2.new(1, -16, 0, 14)
instance56.Position = UDim2.new(0, 8, 0, 24)
instance56.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
instance56.BorderSizePixel = 0

Instance.new("UICorner", instance56).CornerRadius = UDim.new(1, 0)

local instance57 = Instance.new("Frame", instance56)
instance57.Size = UDim2.new(1, 0, 1, 0)
instance57.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
instance57.BorderSizePixel = 0

Instance.new("UICorner", instance57).CornerRadius = UDim.new(1, 0)

local instance58 = Instance.new("TextLabel", bossBarFrame)
instance58.Size = UDim2.new(1, -16, 0, 12)
instance58.Position = UDim2.new(0, 8, 0, 40)
instance58.BackgroundTransparency = 1
instance58.Text = "100 / 100"
instance58.Font = Enum.Font.GothamBold
instance58.TextSize = 10
instance58.TextColor3 = Color3.fromRGB(255, 255, 255)
instance58.TextXAlignment = Enum.TextXAlignment.Left

f7(instance58)

local instance59 = Instance.new("TextButton", bossBarFrame)
instance59.Size = UDim2.new(1, -16, 0, 22)
instance59.Position = UDim2.new(0, 8, 0, 54)
instance59.BackgroundColor3 = Color3.fromRGB(55, 35, 35)
instance59.Text = "Dịch Chuyển Đến Boss"
instance59.Font = Enum.Font.GothamBold
instance59.TextSize = 10
instance59.TextColor3 = Color3.fromRGB(255, 255, 255)
instance59.AutoButtonColor = false

Instance.new("UICorner", instance59).CornerRadius = UDim.new(0, 5)
f7(instance59)

instance59.MouseButton1Click:Connect(function()
  local v83 = f18()

  if not v83 then
    instance55.Text = "Không tìm thấy NPC2!"
    task.wait(2)
    instance55.Text = "NPC2 - Boss"
    return
  end

  f19(v83)
end)

local v84, position11, position12

instance54.InputBegan:Connect(function(input20)
  if input20.UserInputType == Enum.UserInputType.MouseButton1
    or input20.UserInputType == Enum.UserInputType.Touch then
    v84 = true
    position11 = input20.Position
    position12 = bossBarFrame.Position
  end
end)

instance54.InputEnded:Connect(function(input21)
  if input21.UserInputType == Enum.UserInputType.MouseButton1
    or input21.UserInputType == Enum.UserInputType.Touch then
    v84 = false
  end
end)

userInputService.InputChanged:Connect(function(input22)
  if v84
    and (input22.UserInputType == Enum.UserInputType.MouseMovement
      or input22.UserInputType == Enum.UserInputType.Touch) then
    local v85 = input22.Position - position11

    bossBarFrame.Position = UDim2.new(
      position12.X.Scale, position12.X.Offset + v85.X, position12.Y.Scale,
      position12.Y.Offset + v85.Y
    )
  end
end)

task.spawn(function()
  while true do
    pcall(function()
      if not v3.ShowNPC2HpBar then
        bossBarFrame.Visible = false
      else
        local v86 = f18()

        if v86 then
          bossBarFrame.Visible = true
          local humanoid8 = v86.Humanoid
          local v87 = math.clamp(humanoid8.Health / math.max(humanoid8.MaxHealth, 1), 0, 1)
          instance57.Size = UDim2.new(v87, 0, 1, 0)

          if v87 > 0.5 then
            instance57.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
          elseif v87 > 0.25 then
            instance57.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
          else
            instance57.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
          end

          instance58.Text = string.format(
            "%d / %d", math.floor(humanoid8.Health), math.floor(humanoid8.MaxHealth)
          )

          instance55.Text = "NPC2 - Boss"
        else
          bossBarFrame.Visible = false
        end
      end
    end)

    task.wait(0.3)
  end
end)

task.spawn(function()
  while true do
    if v3.AutoBuyBandage and buyItem then
      pcall(function()
        if v3.BandageCount < v3.BandageMax then
          buyItem:FireServer("băng gạc", v3.BuyBandageAmount)
        end
      end)
    end

    task.wait(1.5)
  end
end)

task.spawn(function()
  while true do
    if v3.AutoLoot then
      pcall(function()
        local character8 = localPlayer.Character
        local humanoidRootPart4 = character8 and character8:FindFirstChild("HumanoidRootPart")

        if humanoidRootPart4 then
          for key15, value23 in pairs(v1:GetDescendants()) do
            if value23:IsA("ProximityPrompt") and value23.Enabled then
              local parent = value23.Parent

              if parent and parent:IsA("BasePart") then
                if (humanoidRootPart4.Position - parent.Position).Magnitude <= v3.LootDistance then
                  fireproximityprompt(value23)
                end
              end
            end
          end
        end
      end)
    end

    task.wait(0.3)
  end
end)

local function f37()
  local character9 = localPlayer.Character

  if not character9 then
    return
  else
    local tool2 = character9:FindFirstChildOfClass("Tool")

    if not tool2 then
      local backpack = localPlayer:FindFirstChildOfClass("Backpack")
        or localPlayer:FindFirstChild("Backpack")

      if backpack then
        local tool3 = backpack:FindFirstChildOfClass("Tool")

        if tool3 then
          local humanoid9 = character9:FindFirstChildOfClass("Humanoid")

          if humanoid9 then
            humanoid9:EquipTool(tool3)
          end
        end
      end
    else
      tool2:Activate()
    end

    return
  end
end

runService.RenderStepped:Connect(function()
  if v3.AutoAttack or v3.FarmLevel or v3.FarmBoss or v3.SafeFarm then
    pcall(f37)
  end

  if v3.AimNearest then
    pcall(function()
      local character10 = localPlayer.Character

      if character10 and character10:FindFirstChild("HumanoidRootPart") then
        local position13 = character10.HumanoidRootPart.Position
        local v88 = nil
        local huge = math.huge

        for key16, value24 in pairs(players:GetPlayers()) do
          if value24 ~= localPlayer and value24.Character
            and value24.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid10 = value24.Character:FindFirstChildOfClass("Humanoid")

            if humanoid10 and humanoid10.Health > 0 then
              local magnitude = (value24.Character.HumanoidRootPart.Position - position13).Magnitude

              if magnitude < huge then
                v88 = value24
                huge = magnitude
              end
            end
          end
        end

        if v88 then
          character10.HumanoidRootPart.CFrame = CFrame.new(position13, Vector3.new(
            v88.Character.HumanoidRootPart.Position.X, position13.Y,
            v88.Character.HumanoidRootPart.Position.Z
          ))
        end
      end
    end)
  end
end)

local function f38()
  for key17, value25 in pairs(players:GetPlayers()) do
    if value25 ~= localPlayer and value25.Character
      and value25.Character:FindFirstChild("HumanoidRootPart") then
      local humanoidRootPart5 = value25.Character.HumanoidRootPart
      local humanoid11 = value25.Character:FindFirstChildOfClass("Humanoid")

      if not humanoid11 then
      else
        local playerHPESP = humanoidRootPart5:FindFirstChild("Player_HPESP")

        if v3.PlayerHPESP then
          if not playerHPESP then
            playerHPESP = Instance.new("BillboardGui")
            playerHPESP.Name = "Player_HPESP"
            playerHPESP.Size = UDim2.new(0, 60, 0, 16)
            playerHPESP.StudsOffset = Vector3.new(0, 3.5, 0)
            playerHPESP.AlwaysOnTop = true
            playerHPESP.MaxDistance = 600
            playerHPESP.Parent = humanoidRootPart5

            local hpText = Instance.new("TextLabel", playerHPESP)
            hpText.Name = "HPText"
            hpText.Size = UDim2.new(1, 0, 1, 0)
            hpText.BackgroundTransparency = 1
            hpText.TextColor3 = Color3.fromRGB(0, 255, 120)
            hpText.Font = Enum.Font.GothamBold
            hpText.TextSize = 11
            hpText.TextStrokeTransparency = 0.3
          end

          playerHPESP.HPText.Text = math.floor(humanoid11.Health) .. " HP"
        elseif playerHPESP then
          playerHPESP:Destroy()
        end

        local playerHighlight = value25.Character:FindFirstChild("Player_Highlight")

        if v3.PlayerHighlight then
          if not playerHighlight then
            local playerHighlight2 = Instance.new("Highlight", value25.Character)
            playerHighlight2.Name = "Player_Highlight"
            playerHighlight2.FillColor = Color3.fromRGB(255, 50, 50)
            playerHighlight2.OutlineColor = Color3.fromRGB(255, 255, 255)
          end
        elseif playerHighlight then
          playerHighlight:Destroy()
        end
      end
    end
  end
end

task.spawn(function()
  while true do
    pcall(f38)
    task.wait(0.1)
  end
end)

task.spawn(function()
  while true do
    if v3.AutoHeal and waitForChild then
      pcall(function()
        local character11 = localPlayer.Character
        local humanoid12 = character11 and character11:FindFirstChildOfClass("Humanoid")

        if humanoid12 and humanoid12.Health < 100 and humanoid12.Health > 0 then
          waitForChild:FireServer()
        end
      end)
    end

    task.wait(v3.HealDelay)
  end
end)

local v89 = {}

runService.Heartbeat:Connect(function()
  if v3.FreezeBoss then
    for key18, value26 in pairs(v1:GetDescendants()) do
      if value26:IsA("Model") and string.find(string.lower(value26.Name), "npc2")
        and value26:FindFirstChild("Humanoid") and value26.Humanoid.Health > 0
        and value26:FindFirstChild("HumanoidRootPart") then
        if not players:GetPlayerFromCharacter(value26) then
          local humanoidRootPart6 = value26.HumanoidRootPart

          if not v89[value26] then
            v89[value26] = humanoidRootPart6.CFrame
          end

          humanoidRootPart6.CFrame = v89[value26]
          humanoidRootPart6.AssemblyLinearVelocity = Vector3.zero
          humanoidRootPart6.AssemblyAngularVelocity = Vector3.zero

          value26.Humanoid.WalkSpeed = 0
        end
      end
    end
  elseif next(v89) then
    for key19 in pairs(v89) do
      if key19 and key19:FindFirstChild("Humanoid") then
        key19.Humanoid.WalkSpeed = 16
      end
    end

    table.clear(v89)
  end
end)

local v90 = {}

runService.Heartbeat:Connect(function()
  if v3.FreezeNPC then
    for key20, value27 in pairs(v1:GetDescendants()) do
      if value27:IsA("Model") and string.find(string.lower(value27.Name), "npc")
        and not string.find(string.lower(value27.Name), "npc2") then
        if value27:FindFirstChild("Humanoid") and value27.Humanoid.Health > 0
          and value27:FindFirstChild("HumanoidRootPart") then
          if not players:GetPlayerFromCharacter(value27) then
            local humanoidRootPart7 = value27.HumanoidRootPart

            if not v90[value27] then
              v90[value27] = humanoidRootPart7.CFrame
            end

            humanoidRootPart7.CFrame = v90[value27]
            humanoidRootPart7.AssemblyLinearVelocity = Vector3.zero
            humanoidRootPart7.AssemblyAngularVelocity = Vector3.zero

            value27.Humanoid.WalkSpeed = 0
          end
        end
      end
    end
  elseif next(v90) then
    for key21 in pairs(v90) do
      if key21 and key21:FindFirstChild("Humanoid") then
        key21.Humanoid.WalkSpeed = 16
      end
    end

    table.clear(v90)
  end
end)

task.spawn(function()
  while true do
    pcall(function()
      if v3.ShowNPC2HpBar then
        for key22, value28 in pairs(v1:GetDescendants()) do
          if value28:IsA("Model") and string.find(string.lower(value28.Name), "npc2")
            and value28:FindFirstChild("Humanoid")
            and value28:FindFirstChild("HumanoidRootPart") then
            local humanoidRootPart8 = value28.HumanoidRootPart
            local humanoid13 = value28.Humanoid
            local npc2HpBar = humanoidRootPart8:FindFirstChild("NPC2_HpBar")

            if not npc2HpBar then
              npc2HpBar = Instance.new("BillboardGui")
              npc2HpBar.Name = "NPC2_HpBar"
              npc2HpBar.Size = UDim2.new(0, 120, 0, 32)
              npc2HpBar.StudsOffset = Vector3.new(0, 4, 0)
              npc2HpBar.AlwaysOnTop = true
              npc2HpBar.MaxDistance = 600
              npc2HpBar.Parent = humanoidRootPart8

              local bg = Instance.new("Frame", npc2HpBar)
              bg.Name = "BG"
              bg.Size = UDim2.new(1, 0, 0, 12)
              bg.Position = UDim2.new(0, 0, 0.6, 0)
              bg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
              bg.BorderSizePixel = 0

              Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

              local fill = Instance.new("Frame", bg)
              fill.Name = "Fill"
              fill.Size = UDim2.new(1, 0, 1, 0)
              fill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
              fill.BorderSizePixel = 0

              Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

              local hpTxt = Instance.new("TextLabel", npc2HpBar)
              hpTxt.Name = "HpTxt"
              hpTxt.Size = UDim2.new(1, 0, 0.5, 0)
              hpTxt.BackgroundTransparency = 1
              hpTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
              hpTxt.Font = Enum.Font.GothamBold
              hpTxt.TextSize = 12
              hpTxt.TextStrokeTransparency = 0.3
            end

            local bg2 = npc2HpBar:FindFirstChild("BG")

            local fill2 = bg2
            fill2 = bg2 and bg2:FindFirstChild("Fill")

            if fill2 then
              local v91 = math.clamp(
                humanoid13.Health / math.max(humanoid13.MaxHealth, 1), 0, 1
              )

              fill2.Size = UDim2.new(v91, 0, 1, 0)

              if v91 > 0.5 then
                fill2.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
              elseif v91 > 0.25 then
                fill2.BackgroundColor3 = Color3.fromRGB(255, 200, 60)
              else
                fill2.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
              end
            end

            local hpTxt2 = npc2HpBar:FindFirstChild("HpTxt")

            if hpTxt2 then
              hpTxt2.Text = "NPC2: " .. math.floor(humanoid13.Health) .. " / "
                .. math.floor(humanoid13.MaxHealth)
            end
          end
        end
      else
        for key23, value29 in pairs(v1:GetDescendants()) do
          if value29:IsA("BillboardGui") and value29.Name == "NPC2_HpBar" then
            value29:Destroy()
          end
        end
      end
    end)

    task.wait(0.3)
  end
end)

local v92 = 0
local v93 = 0
local v94 = false
local v95

runService.Heartbeat:Connect(function(delta4)
  if v3.FreezeMoveOnFarm and (v3.FarmLevel or v3.FarmBoss or v3.SafeFarm) then
    local character12 = localPlayer.Character
    local humanoid14 = character12 and character12:FindFirstChildOfClass("Humanoid")

    if humanoid14 then
      humanoid14.WalkSpeed = 0
      humanoid14.JumpPower = 0
    end
  end

  if not (v3.FarmLevel or v3.FarmBoss or v3.SafeFarm) then
    if v94 then
      v94 = false
      v95 = nil
      local character13 = localPlayer.Character

      if character13 then
        for key24, value30 in pairs(character13:GetDescendants()) do
          if value30:IsA("BasePart") then
            value30.CanCollide = true
          end
        end
      end
    end

    return
  else
    local character14 = localPlayer.Character

    if not character14 or not character14:FindFirstChild("HumanoidRootPart") then
      return
    else
      local farmBoss = v3.FarmBoss and f18() or f20()

      if v3.SafeFarm then
        if not farmBoss then
          if not v94 then
            v94 = true
            local getDescendants = character14.GetDescendants
            v95 = character14.HumanoidRootPart.Position.Y - v3.SafeFarmDepth

            for key25, value31 in pairs(getDescendants(character14)) do
              if value31:IsA("BasePart") then
                value31.CanCollide = false
              end
            end
          end

          local position14 = character14.HumanoidRootPart.Position

          character14.HumanoidRootPart.CFrame = CFrame.new(Vector3.new(
            position14.X, v95, position14.Z
          ))

          character14.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
          character14.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

          return
        elseif v94 then
          v94 = false
          v95 = nil

          for key26, value32 in pairs(character14:GetDescendants()) do
            if value32:IsA("BasePart") then
              value32.CanCollide = true
            end
          end
        end
      end

      if farmBoss and farmBoss:FindFirstChild("HumanoidRootPart") then
        local position15 = farmBoss.HumanoidRootPart.Position
        local humanoidRootPart9 = character14.HumanoidRootPart

        if v3.FarmMode == 1 then
          local v96 = os.clock() * v3.Model1Speed % (math.pi * 2)

          humanoidRootPart9.CFrame = CFrame.new(Vector3.new(position15.X
            + math.cos(v96) * v3.Distance, position15.Y, position15.Z
            + math.sin(v96) * v3.Distance), position15)
        elseif v3.FarmMode == 2 then
          local v97 = os.clock()

          if v97 - v93 >= 1 / math.max(v3.Model2Speed, 0.1) then
            v92 = v92 % 4 + 1
            v93 = v97
          end

          local v98 = {
            Vector3.new(v3.Distance, 0, 0), Vector3.new(-v3.Distance, 0, 0),
            Vector3.new(0, 0, v3.Distance), Vector3.new(0, 0, -v3.Distance),
          }

          humanoidRootPart9.CFrame = CFrame.new(position15 + v98[v92], position15)
        elseif v3.FarmMode == 3 then
          local v99 = os.clock()

          if v99 - v93 >= 1 / math.max(v3.Model3Speed, 0.1) then
            v92 = v92 % 2 + 1
            v93 = v99
          end

          local v100 = {
            Vector3.new(v3.Distance * 1.2, 0, 0), Vector3.new(-v3.Distance * 1.2, 0, 0),
          }

          humanoidRootPart9.CFrame = CFrame.new(position15 + v100[v92], position15)
        elseif v3.FarmMode == 4 then
          local v101 = os.clock()
          local model4Speed = v3.Model4Speed
          local v102 = v101 * model4Speed * 0.15 % (math.pi * 2)
          local v103 = v3.Distance + math.sin(v101 * model4Speed * 0.3) * 4
          local v104 = math.cos(v102)
          local v105 = math.sin(v102)

          local vector2 = Vector3.new(
            position15.X + v104 * v103, position15.Y, position15.Z + v105 * v103
          )

          humanoidRootPart9.CFrame = CFrame.new(vector2, position15) * CFrame.Angles(
            0, v101 * model4Speed * 1.2 % (math.pi * 2), 0
          )
        end
      end

      return
    end
  end
end)

print("[Iceland] Loaded! (PlayerGui mode)")
