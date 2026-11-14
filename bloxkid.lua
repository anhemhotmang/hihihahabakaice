-- Meta Hub - Blox Fruits (Obscura-ready build, external key gate removed)
-- Halloween core loader from the supplied v2_clean.lua.txt source.
do
    local loaded = Core and Core.Halloween
    if not loaded then
        for attempt = 1, 2 do
            local ok, err = pcall(function()
                local source = game:HttpGet("https://raw.githubusercontent.com/scriptpastebin/Blox-Fruits/refs/heads/main/core.luau")
                local loader = loadstring(source)
                assert(type(loader) == "function", "Halloween core source did not compile")
                loader()
            end)
            if ok then break end
            warn("[Meta Hub] Could not load Halloween core (try " .. attempt .. "): " .. tostring(err))
            task.wait(1)
        end
    end
end

-- ============ MAIN ============
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
if not game:IsLoaded() then game.Loaded:Wait() end
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local replicated = game:GetService("ReplicatedStorage")
local plr = player
local Lighting = game:GetService("Lighting")

-- Core đã được nạp ở đầu file trước khi tạo GUI.

-- ============ THEME (kiểu iOS glass, đổi màu ở đây) ============
local THEME = {
    bg = Color3.fromRGB(20, 20, 26),
    white = Color3.fromRGB(255, 255, 255),
    text = Color3.fromRGB(245, 245, 247),
    sub = Color3.fromRGB(152, 152, 160),
    accent = Color3.fromRGB(10, 132, 255),
    accentText = Color3.fromRGB(110, 175, 255),
    green = Color3.fromRGB(48, 209, 88),
    red = Color3.fromRGB(255, 69, 58),
    yellow = Color3.fromRGB(255, 214, 10),
    track = Color3.fromRGB(88, 88, 96),
}
local OPEN_BTN_IMAGE_ID = "rbxassetid://96209229699816" -- ảnh nút bật menu
local ROW_T, ROW_HOVER_T = 0.93, 0.88                   -- độ trong suốt của hàng
local FONT, FONT_MED, FONT_BOLD = Enum.Font.BuilderSans, Enum.Font.BuilderSansMedium, Enum.Font.BuilderSansBold
local QUINT, BACK, QUAD = Enum.EasingStyle.Quint, Enum.EasingStyle.Back, Enum.EasingStyle.Quad
local notifyToggles = true -- bật/tắt banner khi gạt công tắc (đổi trong tab Info)

-- ============ SMALL HELPERS ============
local function new(class, props, parent)
    local o = Instance.new(class)
    if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
    if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
        o.Font = FONT_MED
        o.TextSize = 14
        o.TextColor3 = THEME.text
        if not o:IsA("TextBox") then o.Text = "" end
    end
    if o:IsA("TextButton") or o:IsA("ImageButton") then o.AutoButtonColor = false end
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(obj, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r)}, obj)
end

local function stroke(obj, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or THEME.white,
        Thickness = thickness or 1,
        Transparency = transparency or 0.9,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function tween(obj, t, props, style, dir)
    local tw = TweenService:Create(obj, TweenInfo.new(t, style or QUAD, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
    return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

-- hiệu ứng nhún khi bấm
local function pressable(obj, hit, amount)
    local sc = new("UIScale", {Scale = 1}, obj)
    hit.MouseButton1Down:Connect(function() tween(sc, 0.1, {Scale = amount or 0.97}) end)
    local function release() tween(sc, 0.25, {Scale = 1}, BACK) end
    hit.MouseButton1Up:Connect(release)
    hit.MouseLeave:Connect(release)
    return sc
end

-- ============ GUI SETUP ============
for _, n in ipairs({"MetaHubGui", "MeoDogHubGui"}) do
    local old = playerGui:FindFirstChild(n)
    if old then old:Destroy() end
end

local screenGui = new("ScreenGui", {Name = "MetaHubGui", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
pcall(function() screenGui.DisplayOrder = 50 end)
screenGui.Parent = playerGui

local function viewport()
    local c = workspace.CurrentCamera
    return (c and c.ViewportSize) or Vector2.new(1280, 720)
end
local vp = viewport()
local originalSize = UDim2.new(0, math.clamp(vp.X - 40, 320, 520), 0, math.clamp(vp.Y - 40, 220, 330))
local function maximizedSize()
    local v = viewport()
    return UDim2.new(0, math.clamp(v.X - 30, 320, 740), 0, math.clamp(v.Y - 30, 220, 470))
end
local centerPos = UDim2.new(0.5, 0, 0.5, 0)
local isMaximized = false

-- Main Frame
local mainFrame = new("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = originalSize,
    Position = centerPos,
    BackgroundColor3 = THEME.bg,
    BackgroundTransparency = 0.08,
    ClipsDescendants = true,
}, screenGui)
corner(mainFrame, 18)
stroke(mainFrame, THEME.white, 1, 0.88)
local winScale = new("UIScale", {Scale = 1}, mainFrame)

-- Top Bar
local topBar = new("Frame", {Name = "TopBar", Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1, Active = true}, mainFrame)
new("Frame", {
    Size = UDim2.new(1, 0, 0, 1),
    Position = UDim2.new(0, 0, 1, -1),
    BackgroundColor3 = THEME.white,
    BackgroundTransparency = 0.92,
}, topBar)

new("TextLabel", {
    Name = "Title",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Size = UDim2.new(0, 140, 0, 22),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    BackgroundTransparency = 1,
    Text = "Meta Hub",
    Font = FONT_BOLD,
    TextSize = 16,
}, topBar)
new("TextLabel", {
    Size = UDim2.new(0, 100, 1, 0),
    Position = UDim2.new(1, -112, 0, 0),
    BackgroundTransparency = 1,
    Text = "Blox Fruits",
    TextColor3 = THEME.sub,
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Right,
}, topBar)

local openMenuBtn

-- Show / hide có animation
local visToken = 0
local function showMain()
    visToken = visToken + 1
    if openMenuBtn then openMenuBtn.Visible = false end
    winScale.Scale = 0.9
    mainFrame.Visible = true
    tween(winScale, 0.4, {Scale = 1}, BACK)
end
local function hideMain()
    visToken = visToken + 1
    local my = visToken
    tween(winScale, 0.18, {Scale = 0.9}, QUAD, Enum.EasingDirection.In)
    task.delay(0.18, function()
        if my == visToken then
            mainFrame.Visible = false
            winScale.Scale = 1
            if openMenuBtn then openMenuBtn.Visible = true end
        end
    end)
end

-- Traffic lights: đỏ = đóng, vàng = ẩn, xanh = phóng to
local function trafficLight(x, color, glyph, callback)
    local b = new("TextButton", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, x, 0.5, -8),
        BackgroundColor3 = color,
    }, topBar)
    corner(b, 8)
    local g = new("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = glyph,
        TextColor3 = Color3.fromRGB(40, 20, 20),
        Font = FONT_BOLD,
        TextSize = 12,
        TextTransparency = 1,
    }, b)
    b.MouseEnter:Connect(function() tween(g, 0.1, {TextTransparency = 0.1}) end)
    b.MouseLeave:Connect(function() tween(g, 0.1, {TextTransparency = 1}) end)
    b.MouseButton1Click:Connect(callback)
    return b
end
trafficLight(14, THEME.red, "×", function() screenGui:Destroy() end)
trafficLight(38, THEME.yellow, "−", hideMain)
trafficLight(62, THEME.green, "+", function()
    isMaximized = not isMaximized
    tween(mainFrame, 0.4, {Size = isMaximized and maximizedSize() or originalSize, Position = centerPos}, QUINT)
end)

-- Open Menu Button (kéo được, bấm để mở lại menu)
openMenuBtn = new("ImageButton", {
    Name = "OpenMenu",
    Size = UDim2.new(0, 54, 0, 54),
    Position = UDim2.new(0, 20, 0, 20),
    BackgroundColor3 = THEME.bg,
    Image = OPEN_BTN_IMAGE_ID,
    ScaleType = Enum.ScaleType.Crop,
    Visible = false,
}, screenGui)
corner(openMenuBtn, 27)
stroke(openMenuBtn, THEME.white, 1.5, 0.75)
pressable(openMenuBtn, openMenuBtn, 0.92)

local obDragging, obInput, obStart, obStartPos, obMoved = false, nil, nil, nil, 0
openMenuBtn.InputBegan:Connect(function(input)
    if isPress(input) then
        obDragging = true
        obMoved = 0
        obStart = input.Position
        obStartPos = openMenuBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then obDragging = false end
        end)
    end
end)
openMenuBtn.InputChanged:Connect(function(input)
    if isMove(input) then obInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == obInput and obDragging then
        local delta = input.Position - obStart
        obMoved = math.max(obMoved, delta.Magnitude)
        openMenuBtn.Position = UDim2.new(obStartPos.X.Scale, obStartPos.X.Offset + delta.X, obStartPos.Y.Scale, obStartPos.Y.Offset + delta.Y)
    end
end)
openMenuBtn.MouseButton1Click:Connect(function()
    if obMoved > 8 then return end
    showMain()
end)

-- ============ NotifyIOS27 (banner kiểu iOS, xếp chồng, vuốt lên để tắt) ============
local notifyWidth = math.clamp(vp.X - 24, 240, 360)
local notifyHolder = new("Frame", {
    Name = "Notifications",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 10),
    Size = UDim2.new(0, notifyWidth, 1, -20),
    BackgroundTransparency = 1,
}, screenGui)

local notifs = {}
local NOTIF_H, NOTIF_GAP, NOTIF_MAX = 68, 8, 4
local KIND_COLOR = {info = THEME.accent, ok = THEME.green, warn = THEME.yellow, error = THEME.red}
local KIND_GLYPH = {info = "M", ok = "✓", warn = "!", error = "✕"}

local function layoutNotifs()
    local y = 0
    for _, n in ipairs(notifs) do
        tween(n.frame, 0.45, {Position = UDim2.new(0, 0, 0, y)}, QUINT)
        y = y + NOTIF_H + NOTIF_GAP
    end
end

local function removeNotif(n)
    if n.removed then return end
    n.removed = true
    for i, v in ipairs(notifs) do
        if v == n then table.remove(notifs, i) break end
    end
    tween(n.frame, 0.3, {Position = UDim2.new(0, 0, 0, -NOTIF_H - 30), GroupTransparency = 1}, QUINT, Enum.EasingDirection.In)
    task.delay(0.35, function() n.frame:Destroy() end)
    layoutNotifs()
end

local function NotifyIOS27(title, body, kind, duration)
    if body == nil then body, title = title, "Meta Hub" end
    title, body = tostring(title), tostring(body)
    if not KIND_COLOR[kind] then kind = "info" end
    duration = duration or 4

    -- cùng tiêu đề đang hiện thì cập nhật nội dung, không xếp thêm
    for _, n in ipairs(notifs) do
        if n.title == title and not n.removed then
            n.bodyLabel.Text = body
            n.icon.BackgroundColor3 = KIND_COLOR[kind]
            n.glyph.Text = KIND_GLYPH[kind]
            n.gen = n.gen + 1
            local g = n.gen
            task.delay(duration, function() if n.gen == g then removeNotif(n) end end)
            return n
        end
    end

    local frame = new("CanvasGroup", {
        Size = UDim2.new(1, 0, 0, NOTIF_H),
        Position = UDim2.new(0, 0, 0, -NOTIF_H - 30),
        BackgroundColor3 = Color3.fromRGB(30, 30, 36),
        BackgroundTransparency = 0.06,
        GroupTransparency = 1,
    }, notifyHolder)
    corner(frame, 22)
    stroke(frame, THEME.white, 1, 0.86)

    local icon = new("Frame", {
        Size = UDim2.new(0, 38, 0, 38),
        Position = UDim2.new(0, 14, 0, 15),
        BackgroundColor3 = KIND_COLOR[kind],
    }, frame)
    corner(icon, 10)
    local glyph = new("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = KIND_GLYPH[kind],
        Font = FONT_BOLD,
        TextSize = 19,
        TextColor3 = (kind == "warn") and Color3.fromRGB(40, 30, 0) or Color3.new(1, 1, 1),
    }, icon)
    new("TextLabel", {
        Size = UDim2.new(1, -130, 0, 18),
        Position = UDim2.new(0, 62, 0, 11),
        BackgroundTransparency = 1,
        Text = title,
        Font = FONT_BOLD,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, frame)
    new("TextLabel", {
        Size = UDim2.new(0, 50, 0, 18),
        Position = UDim2.new(1, -62, 0, 11),
        BackgroundTransparency = 1,
        Text = "now",
        TextColor3 = THEME.sub,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, frame)
    local bodyLabel = new("TextLabel", {
        Size = UDim2.new(1, -76, 0, 32),
        Position = UDim2.new(0, 62, 0, 30),
        BackgroundTransparency = 1,
        Text = body,
        TextColor3 = Color3.fromRGB(215, 215, 222),
        TextSize = 13,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, frame)
    local hit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1}, frame)

    local n = {frame = frame, title = title, bodyLabel = bodyLabel, icon = icon, glyph = glyph, gen = 1, removed = false}
    table.insert(notifs, 1, n)
    if #notifs > NOTIF_MAX then removeNotif(notifs[#notifs]) end
    layoutNotifs()
    tween(frame, 0.35, {GroupTransparency = 0})

    hit.MouseButton1Click:Connect(function() removeNotif(n) end)
    local dragStart
    hit.InputBegan:Connect(function(input)
        if isPress(input) then dragStart = input.Position end
    end)
    hit.InputChanged:Connect(function(input)
        if dragStart and isMove(input) and (input.Position.Y - dragStart.Y) < -16 then
            dragStart = nil
            removeNotif(n)
        end
    end)
    hit.InputEnded:Connect(function(input)
        if isPress(input) then dragStart = nil end
    end)

    task.delay(duration, function() if n.gen == 1 then removeNotif(n) end end)
    return n
end
pcall(function()
    getgenv().NotifyIOS27 = NotifyIOS27
    getgenv().NotifyIOS = NotifyIOS27
end)

-- ============ SIDEBAR + CONTENT ============
local TAB_H, TAB_GAP, TAB_PAD = 34, 4, 6

local sidebar = new("ScrollingFrame", {
    Name = "Sidebar",
    Size = UDim2.new(0, 122, 1, -52),
    Position = UDim2.new(0, 10, 0, 46),
    BackgroundColor3 = THEME.white,
    BackgroundTransparency = 0.95,
    ScrollBarThickness = 0,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    CanvasSize = UDim2.new(),
}, mainFrame)
corner(sidebar, 14)

-- thanh chọn trượt (pill), tạo trước tabHolder để nằm dưới chữ
local pill = new("Frame", {
    Size = UDim2.new(1, -12, 0, TAB_H),
    Position = UDim2.new(0, 6, 0, TAB_PAD),
    BackgroundColor3 = THEME.accent,
    BackgroundTransparency = 0.72,
    Visible = false,
}, sidebar)
corner(pill, 10)

local tabHolder = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1}, sidebar)
new("UIListLayout", {Padding = UDim.new(0, TAB_GAP), SortOrder = Enum.SortOrder.LayoutOrder}, tabHolder)
new("UIPadding", {PaddingTop = UDim.new(0, TAB_PAD), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, tabHolder)

local contentArea = new("Frame", {
    Name = "Content",
    Size = UDim2.new(1, -150, 1, -52),
    Position = UDim2.new(0, 140, 0, 46),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
}, mainFrame)

-- mỗi tab có 1 trang riêng (CanvasGroup để fade mượt), giữ nguyên trạng thái khi đổi tab
local function newPage()
    local holder = new("CanvasGroup", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Visible = false,
    }, contentArea)
    local page = new("ScrollingFrame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = THEME.sub,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, holder)
    new("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, page)
    new("UIPadding", {PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 8)}, page)
    return page, holder
end

-- Vòng lặp cập nhật trạng thái chỉ chạy khi trang đang hiện (đỡ lag, đỡ spam remote)
local function pwait(page, t)
    task.wait(t)
    while page:IsDescendantOf(game) and not (page.Parent.Visible and mainFrame.Visible) do
        task.wait(0.4)
    end
    return page:IsDescendantOf(game)
end

-- ============ UI HELPERS ============
local function rowFrame(parent, height)
    local f = new("Frame", {
        Size = UDim2.new(1, -4, 0, height),
        BackgroundColor3 = THEME.white,
        BackgroundTransparency = ROW_T,
        LayoutOrder = #parent:GetChildren(),
    }, parent)
    corner(f, 12)
    return f
end

local function createSection(parent, titleText)
    local s = new("Frame", {
        Size = UDim2.new(1, -4, 0, 24),
        BackgroundTransparency = 1,
        LayoutOrder = #parent:GetChildren(),
    }, parent)
    new("TextLabel", {
        Size = UDim2.new(1, -12, 1, 0),
        Position = UDim2.new(0, 8, 0, 4),
        BackgroundTransparency = 1,
        Text = string.upper((tostring(titleText):gsub("^%s+", ""))),
        TextColor3 = THEME.sub,
        Font = FONT_BOLD,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, s)
    return s
end

local function createParagraph(parent, titleText, contentText)
    local f = new("Frame", {
        Size = UDim2.new(1, -4, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = THEME.white,
        BackgroundTransparency = ROW_T,
        LayoutOrder = #parent:GetChildren(),
    }, parent)
    corner(f, 12)
    new("UIPadding", {PaddingTop = UDim.new(0, 9), PaddingBottom = UDim.new(0, 9), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}, f)
    new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, f)
    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = tostring(titleText),
        TextColor3 = THEME.sub,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
    }, f)
    local ct = new("TextLabel", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 18),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = tostring(contentText or ""),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = 2,
    }, f)
    return {Frame = f, ContentLabel = ct, SetContent = function(self, txt) ct.Text = tostring(txt) end}
end

local function createToggle(parent, name, default, callback)
    local f = rowFrame(parent, 42)
    new("TextLabel", {
        Size = UDim2.new(1, -84, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(name),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, f)

    local sw = new("Frame", {
        Size = UDim2.new(0, 48, 0, 28),
        Position = UDim2.new(1, -60, 0.5, -14),
        BackgroundColor3 = THEME.track,
    }, f)
    corner(sw, 14)
    local knob = new("Frame", {
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 2, 0.5, -12),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, sw)
    corner(knob, 12)

    local state = default and true or false
    local function render(animate)
        local goal = state and THEME.green or THEME.track
        local pos = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
        if animate then
            tween(sw, 0.25, {BackgroundColor3 = goal})
            tween(knob, 0.3, {Position = pos}, BACK)
        else
            sw.BackgroundColor3 = goal
            knob.Position = pos
        end
    end
    render(false)

    local function fire()
        if not callback then return end
        task.spawn(function()
            local ok, err = pcall(callback, state)
            if not ok then
                warn("[Meta Hub] " .. tostring(name) .. ": " .. tostring(err))
                NotifyIOS27("Lỗi: " .. tostring(name), tostring(err), "error", 5)
            end
        end)
    end

    local hit = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1}, f)
    pressable(f, hit, 0.98)
    hit.MouseEnter:Connect(function() tween(f, 0.15, {BackgroundTransparency = ROW_HOVER_T}) end)
    hit.MouseLeave:Connect(function() tween(f, 0.2, {BackgroundTransparency = ROW_T}) end)
    hit.MouseButton1Click:Connect(function()
        state = not state
        render(true)
        fire()
        if notifyToggles then
            NotifyIOS27(tostring(name), state and "Đã bật" or "Đã tắt", state and "ok" or "info", 1.8)
        end
    end)

    -- Công tắc hiện BẬT thì chức năng cũng phải bật thật
    if state then fire() end
    return f
end

local function createButton(parent, name, callback)
    local b = new("TextButton", {
        Size = UDim2.new(1, -4, 0, 40),
        BackgroundColor3 = THEME.accent,
        BackgroundTransparency = 0.82,
        Text = tostring(name),
        TextColor3 = THEME.accentText,
        Font = FONT_BOLD,
        TextSize = 14,
        LayoutOrder = #parent:GetChildren(),
    }, parent)
    corner(b, 12)
    pressable(b, b, 0.97)
    b.MouseEnter:Connect(function() tween(b, 0.15, {BackgroundTransparency = 0.72}) end)
    b.MouseLeave:Connect(function() tween(b, 0.2, {BackgroundTransparency = 0.82}) end)
    b.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(function()
                local ok, err = pcall(callback)
                if not ok then
                    warn("[Meta Hub] " .. tostring(name) .. ": " .. tostring(err))
                    NotifyIOS27("Lỗi: " .. tostring(name), tostring(err), "error", 5)
                end
            end)
        end
    end)
    return b
end

local function createDropdown(parent, name, options, default, callback)
    options = options or {}
    local HEAD = 62
    local searchable = #options > 10
    local listY = searchable and 96 or 62

    local f = rowFrame(parent, HEAD)
    f.ClipsDescendants = true

    new("TextLabel", {
        Size = UDim2.new(1, -28, 0, 18),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(name),
        TextColor3 = THEME.sub,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, f)

    local current = default
    if current == nil then current = options[1] end

    local btn = new("TextButton", {
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 26),
        BackgroundColor3 = THEME.white,
        BackgroundTransparency = 0.9,
    }, f)
    corner(btn, 9)
    local curLabel = new("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(current == nil and "-" or current),
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, btn)
    local arrow = new("TextLabel", {
        Size = UDim2.new(0, 22, 1, 0),
        Position = UDim2.new(1, -28, 0, 0),
        BackgroundTransparency = 1,
        Text = "›",
        TextColor3 = THEME.sub,
        Font = FONT_BOLD,
        TextSize = 22,
        Rotation = 90,
    }, btn)
    pressable(btn, btn, 0.985)

    local box
    if searchable then
        box = new("TextBox", {
            Size = UDim2.new(1, -20, 0, 28),
            Position = UDim2.new(0, 10, 0, 62),
            BackgroundColor3 = THEME.white,
            BackgroundTransparency = 0.93,
            Text = "",
            PlaceholderText = "Tìm...",
            PlaceholderColor3 = THEME.sub,
            ClearTextOnFocus = false,
            Visible = false,
        }, f)
        corner(box, 9)
        new("UIPadding", {PaddingLeft = UDim.new(0, 12)}, box)
        box.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- Danh sách cuộn được (bản cũ bị cắt ở 5 mục đầu, không cuộn được)
    local list = new("ScrollingFrame", {
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, listY),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = THEME.sub,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
    }, f)
    new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, list)

    local optionButtons = {}
    local open = false

    local function refresh()
        for _, o in ipairs(optionButtons) do
            local sel = (o.value == current)
            tween(o.btn, 0.15, {
                BackgroundColor3 = sel and THEME.accent or THEME.white,
                BackgroundTransparency = sel and 0.7 or 0.94,
            })
            o.btn.TextColor3 = sel and THEME.accentText or THEME.text
        end
    end

    local function relayout()
        if not open then
            tween(f, 0.28, {Size = UDim2.new(1, -4, 0, HEAD)}, QUINT)
            return
        end
        local n = 0
        for _, o in ipairs(optionButtons) do
            if o.btn.Visible then n = n + 1 end
        end
        local h = math.clamp(n * 31, 31, 155)
        list.Size = UDim2.new(1, -20, 0, h)
        tween(f, 0.28, {Size = UDim2.new(1, -4, 0, listY + h + 10)}, QUINT)
    end

    local function setOpen(v)
        open = v
        if v then
            list.Visible = true
            if box then box.Visible = true end
        else
            task.delay(0.28, function()
                if not open then
                    list.Visible = false
                    if box then box.Visible = false end
                end
            end)
        end
        tween(arrow, 0.25, {Rotation = v and -90 or 90}, QUINT)
        relayout()
    end

    btn.MouseButton1Click:Connect(function() setOpen(not open) end)

    for i, opt in ipairs(options) do
        local text = tostring(opt)
        local ob = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = THEME.white,
            BackgroundTransparency = 0.94,
            Text = text,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = i,
        }, list)
        corner(ob, 8)
        new("UIPadding", {PaddingLeft = UDim.new(0, 12)}, ob)
        table.insert(optionButtons, {btn = ob, value = opt, text = text})
        ob.MouseButton1Click:Connect(function()
            current = opt
            curLabel.Text = text
            refresh()
            setOpen(false)
            if callback then pcall(callback, opt) end
        end)
    end

    if box then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local q = box.Text:lower()
            for _, o in ipairs(optionButtons) do
                o.btn.Visible = (q == "" or o.text:lower():find(q, 1, true) ~= nil)
            end
            relayout()
        end)
    end

    refresh()
    if callback and current ~= nil then pcall(callback, current) end
    return f
end

local function createSlider(parent, name, min, max, default, callback)
    local f = rowFrame(parent, 54)

    new("TextLabel", {
        Size = UDim2.new(1, -96, 0, 22),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(name),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, f)
    local vl = new("TextLabel", {
        Size = UDim2.new(0, 70, 0, 22),
        Position = UDim2.new(1, -84, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = THEME.accentText,
        Font = FONT_BOLD,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, f)

    local span = math.max(max - min, 1)
    local startPct = math.clamp((default - min) / span, 0, 1)
    local track = new("Frame", {
        Size = UDim2.new(1, -28, 0, 4),
        Position = UDim2.new(0, 14, 0, 38),
        BackgroundColor3 = THEME.white,
        BackgroundTransparency = 0.8,
    }, f)
    corner(track, 2)
    local fill = new("Frame", {
        Size = UDim2.new(startPct, 0, 1, 0),
        BackgroundColor3 = THEME.accent,
    }, track)
    corner(fill, 2)
    local knob = new("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(startPct, 0, 0.5, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, track)
    corner(knob, 9)
    local knobScale = new("UIScale", {Scale = 1}, knob)

    local dragging = false
    local function setFromX(x)
        local pct = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local v = math.floor(min + (max - min) * pct + 0.5)
        local p2 = math.clamp((v - min) / span, 0, 1)
        fill.Size = UDim2.new(p2, 0, 1, 0)
        knob.Position = UDim2.new(p2, 0, 0.5, 0)
        vl.Text = tostring(v)
        if callback then pcall(callback, v) end
    end

    local hit = new("TextButton", {
        Size = UDim2.new(1, -16, 0, 30),
        Position = UDim2.new(0, 8, 0, 24),
        BackgroundTransparency = 1,
    }, f)
    hit.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            tween(knobScale, 0.15, {Scale = 1.25}, BACK)
            if parent:IsA("ScrollingFrame") then parent.ScrollingEnabled = false end
            setFromX(input.Position.X)
            local conn
            conn = UserInputService.InputChanged:Connect(function(inp)
                if dragging and isMove(inp) then setFromX(inp.Position.X) end
            end)
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    tween(knobScale, 0.2, {Scale = 1}, BACK)
                    if parent:IsA("ScrollingFrame") then parent.ScrollingEnabled = true end
                    conn:Disconnect()
                end
            end)
        end
    end)

    if callback then pcall(callback, default) end
    return f
end

-- ============ TAB SYSTEM (pill trượt + trang fade/slide) ============
local tabs = {}
local tabList = {}
local currentTab = nil

local function createTab(text, yPos, icon, contentFunc)
    local index = #tabList + 1
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, TAB_H),
        BackgroundTransparency = 1,
        LayoutOrder = index,
    }, tabHolder)
    local label = new("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = THEME.sub,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, btn)
    sidebar.CanvasSize = UDim2.new(0, 0, 0, TAB_PAD * 2 + index * (TAB_H + TAB_GAP))

    local page, holder = newPage()
    local entry = {name = text, index = index, btn = btn, label = label, page = page, holder = holder, built = false}

    function entry.build()
        if entry.built then return end
        entry.built = true
        local ok, err = pcall(contentFunc, page)
        if not ok then
            warn("[Meta Hub] tab " .. text .. ": " .. tostring(err))
            createParagraph(page, "Tab error: " .. text, tostring(err))
        end
    end

    local function select()
        entry.build()
        if currentTab == entry then return end
        local old = currentTab
        currentTab = entry

        -- pill trượt tới tab mới
        local y = TAB_PAD + (index - 1) * (TAB_H + TAB_GAP)
        if not pill.Visible then
            pill.Position = UDim2.new(0, 6, 0, y)
            pill.Visible = true
        else
            tween(pill, 0.35, {Position = UDim2.new(0, 6, 0, y)}, QUINT)
        end
        for _, e in ipairs(tabList) do
            tween(e.label, 0.2, {TextColor3 = (e == entry) and THEME.text or THEME.sub})
        end

        -- trang cũ mờ dần, trang mới trượt lên + hiện dần
        if old then
            local oh = old.holder
            tween(oh, 0.14, {GroupTransparency = 1})
            task.delay(0.15, function()
                if currentTab ~= old then oh.Visible = false end
            end)
        end
        holder.Position = UDim2.new(0, 0, 0, 16)
        holder.GroupTransparency = 1
        holder.Visible = true
        task.delay(old and 0.08 or 0, function()
            if currentTab == entry then
                tween(holder, 0.4, {GroupTransparency = 0, Position = UDim2.new()}, QUINT)
            end
        end)
    end

    btn.MouseButton1Click:Connect(select)
    btn.MouseEnter:Connect(function()
        if currentTab ~= entry then tween(label, 0.15, {TextColor3 = THEME.text}) end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= entry then tween(label, 0.2, {TextColor3 = THEME.sub}) end
    end)

    tabs[text] = select
    table.insert(tabList, entry)
    return btn
end


-- ============ TABS CONTENT (Full Eclipse Features) ============

-- TAB 1: Info And Status
createTab("Info", 5, nil, function(p)
    createSection(p, "Interface")
    createToggle(p, "Thông báo khi bật/tắt chức năng", true, function(s) notifyToggles = s end)
    createSection(p, "Server Status")
    local tz = createParagraph(p, "Time Zone", "")
    local gt = createParagraph(p, "Game Time", "")
    spawn(function()
        while true do
            pcall(function()
                local v = os.date("*t")
                local n = v.hour % 24
                local str = n < 12 and "AM" or "PM"
                tz:SetContent(string.format("%02d/%02d/%04d - %02i:%02i:%02i %s", v.day, v.month, v.year, (n-1)%12+1, v.min, v.sec, str))
            end)
            wait(1)
        end
    end)
    spawn(function()
        while true do
            pcall(function()
                local n = math.floor(workspace.DistributedGameTime + 0.5)
                gt:SetContent(string.format("%dh %dm %ds", math.floor(n/3600)%24, math.floor(n/60)%60, n%60))
            end)
            wait(1)
        end
    end)
    local mi = createParagraph(p, "Mirage Island", "Status: ")
    spawn(function()
        while pwait(p, 1) do
            pcall(function()
                local flag = game.Workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island") ~= nil
                mi:SetContent("Status: " .. (flag and "Active" or "Not found"))
            end)
        end
    end)
    local cp = createParagraph(p, "Cake Prince", "")
    spawn(function()
        while pwait(p, 3) do
            pcall(function()
                local ok, result = pcall(function() return game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner") end)
                if ok and type(result) == "string" and #result >= 86 then
                    cp:SetContent("Killed: " .. string.sub(result, 39, 41))
                else
                    cp:SetContent("Not spawned")
                end
            end)
        end
    end)
    local bone = createParagraph(p, "Bones", "")
    spawn(function()
        while pwait(p, 3) do
            pcall(function()
                local r = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Bones", "Check")
                bone:SetContent("You Have: " .. tostring(r) .. " Bones")
            end)
        end
    end)
end)

-- TAB 2: Farming
createTab("Farming", 42, nil, function(p)
    -- Core đọc _G.ChooseWP (Melee / Sword / Gun / Blox Fruit) mỗi 0.5s rồi tự set _G.SelectWeapon,
    -- và mọi hàm farm của core tự equip theo _G.SelectWeapon. Menu chỉ set _G.ChooseWP,
    -- KHÔNG tự equip lặp (bản trước equip Sword song song với core equip Melee nên bị nháy qua lại).
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local weaponTypes = {"Auto", "Melee", "Sword", "Gun", "Blox Fruit"}
    local weaponStatus = createParagraph(p, "Weapon status", "")

    local function findToolName(tip)
        for _, container in ipairs({LocalPlayer.Character, LocalPlayer:FindFirstChildOfClass("Backpack")}) do
            if container then
                for _, tool in ipairs(container:GetChildren()) do
                    if tool:IsA("Tool") and tool.ToolTip == tip then return tool.Name end
                end
            end
        end
        return nil
    end

    createSection(p, " Weapon Selection")
    createDropdown(p, "Choose weapon for farming", weaponTypes, _G.ChooseWP or "Auto", function(choice)
        if choice == "Auto" then
            _G.ChooseWP = nil -- core mặc định dùng Melee
        else
            _G.ChooseWP = choice
        end
        local name = findToolName(_G.ChooseWP or "Melee")
        if name then _G.SelectWeapon = name end
    end)
    task.spawn(function()
        while pwait(p, 0.5) do
            pcall(function()
                local want = _G.ChooseWP or "Melee"
                local name = findToolName(want)
                weaponStatus:SetContent(name and (want .. " → " .. name) or ("Không có tool " .. want .. " trong Backpack/Character"))
            end)
        end
    end)
    createParagraph(p, "Info", "Auto = Melee (mặc định của core). Melee = Fighting Style; Blox Fruit = Devil Fruit.")

    createSection(p, "Auto Farm")
    createToggle(p, "Auto Farm Level", false, function(s) _G.Level = s if not s then alreadyTeleported = false; teleporting = false end end)
    createToggle(p, "Auto Farm Nearest", false, function(s) _G.AutoFarmNear = s end)
    createToggle(p, "Auto Factory Raid", false, function(s) _G.AutoFactory = s end)
    createToggle(p, "Auto Pirate Raid", false, function(s) _G.AutoRaidCastle = s end)
    createToggle(p, "Auto Farm Ectoplasm", false, function(s) _G.AutoEctoplasm = s end)

    createSection(p, "Chest")
    createToggle(p, "Auto Farm Chest", false, function(s) _G.AutoFarmChest = s end)
    createToggle(p, "Auto Chest Bypass", false, function(s)
        _G.AutoChestBP = s
        if s then
            local lp = game:GetService("Players").LocalPlayer
            local flag = false
            local tbl2 = {}
            local flag2 = true
            local function fn()
                if not lp.Character then lp.CharacterAdded:Wait() end
                lp.Character:WaitForChild("HumanoidRootPart")
                return lp.Character
            end
            local function fn2()
                if flag2 then
                    flag2 = false
                    for k, d in pairs(game:GetDescendants()) do
                        if d.Name:find("Chest") and d.ClassName == "Part" then table.insert(tbl2, d) end
                    end
                end
                local tbl3 = {}
                for k, v in pairs(tbl2) do if v:FindFirstChild("TouchInterest") then table.insert(tbl3, v) end end
                local lt = fn().LowerTorso
                table.sort(tbl3, function(a, b) return (lt.Position - a.Position).Magnitude < (lt.Position - b.Position).Magnitude end)
                return tbl3
            end
            local function fn3()
                if flag then return end
                flag = true
                task.spawn(function()
                    while _G.AutoChestBP and lp.Character and lp.Character.Parent do
                        local v = fn2()
                        if #v > 0 then fn().HumanoidRootPart.CFrame = v[1].CFrame end
                        task.wait(0.1)
                    end
                    flag = false
                end)
            end
            lp.CharacterAdded:Connect(function() fn(); task.wait(0.5); if _G.AutoChestBP then fn3() end end)
            fn3()
        end
    end)
    createToggle(p, "Stop Items", true, function(s) _G.StopWhenChalice = s end)

    createSection(p, "Collect Berry")
    createToggle(p, "Auto Farm Berry", false, function(s) _G.AutoBerry = s end)
    createToggle(p, "Auto Farm Berry + Hop", false, function(s) _G.AutoBerryH = s end)

    createSection(p, "Farm Mob")
    local mobOpts = {"Bandit","Monkey","Gorilla","Pirate","Brute","Desert Bandit","Desert Officer","Snow Bandit","Snowman","Chief Petty Officer","Sky Bandit","Dark Master","Toga Warrior","Gladiator","Military Soldier","Military Spy","Fishman Warrior","Fishman Commando","God's Guard","Shanda","Royal Squad","Royal Soldier","Galley Pirate","Galley Captain","Raider","Mercenary","Swan Pirate","Factory Staff","Marine Lieutenant","Marine Captain","Zombie","Vampire","Snow Trooper","Winter Warrior","Lab Subordinate","Horned Warrior","Magma Ninja","Lava Pirate","Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Eclipsetic Warrior","Snow Lurker","Sea Soldier","Water Fighter","Pirate Millionaire","Dragon Crew Warrior","Dragon Crew Archer","Female Islander","Giant Islander","Marine Commodore","Marine Rear Admiral","Fishman Raider","Fishman Captain","Forest Pirate","Mythological Pirate","Jungle Pirate","Musketeer Pirate","Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy","Peanut Scout","Peanut President","Ice Cream Chef","Ice Cream Commander","Cookie Crafter","Cake Guard","Baking Staff","Head Baker","Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel","Candy Pirate","Snow Demon","Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion"}
    createDropdown(p, "Select Mob", mobOpts, "Bandit", function(s) getgenv().SelectMob = s end)
    createToggle(p, "Auto Kill Mob", false, function(s) _G.AutoKillMob = s end)

    createSection(p, "Farm Elite Hunter")
    local ep = createParagraph(p, "Elite Progress", "")
    spawn(function()
        while pwait(p, 2) do
            pcall(function()
                local r = replicated.Remotes.CommF_:InvokeServer("EliteHunter", "Progress")
                ep:SetContent("Elite Progress: " .. tostring(r or 0))
            end)
        end
    end)
    createToggle(p, "Auto Farm Elite", false, function(s) _G.FarmEliteHunt = s end)
    createToggle(p, "Auto Farm Elite + Hop", false, function(s) _G.FarmEliteH = s end)

    createSection(p, "Farm Rip Indra")
    createToggle(p, "Auto Attack Rip Indra", false, function(s) _G.AutoRipIngay = s end)
    createToggle(p, "Auto Unlocked Haki", false, function(s) _G.AutoUnHaki = s end)

    createSection(p, "Farming Cake")
    local cpk = createParagraph(p, "Cake Princes", "")
    spawn(function()
        while pwait(p, 2) do
            pcall(function()
                local v = string.match(replicated.Remotes.CommF_:InvokeServer("CakePrinceSpawner"), "%d+")
                if v then cpk:SetContent("Killed: " .. tostring(500 - tonumber(v))) end
            end)
        end
    end)
    createToggle(p, "Auto Farm Cake Prince", false, function(s) _G.Auto_Cake_Prince = s end)
    createToggle(p, "Accept Quests", false, function(s) _G.AcceptQuestC = s end)
    createToggle(p, "Auto Summon Cake Prince", false, function(s) _G.AutoSpawnCP = s end)
    createToggle(p, "Auto Dough King [Fully]", false, function(s) _G.AutoDoughKing = s end)
    createToggle(p, "Auto Farm Dough King", false, function(s) _G.AutoAttackDoughKing = s end)
    createToggle(p, "Auto Farm Dough King + Hop", false, function(s) _G.AutoHop_Dough = s end)

    createSection(p, "Farming Bone")
    createToggle(p, "Auto Farm Bone", false, function(s) _G.AutoFarm_Bone = s end)
    createToggle(p, "Accept Quests (Bone)", false, function(s) _G.AcceptQuestB = s end)
    createToggle(p, "Auto Soul Reaper", false, function(s) _G.AutoHytHallow = s end)
    createToggle(p, "Auto Random Bones", false, function(s) _G.Auto_Random_Bone = s end)
    createToggle(p, "Auto Try Luck Gravestone", false, function(s) _G.TryLucky = s end)
    createToggle(p, "Auto Pray Gravestone", false, function(s) _G.Praying = s end)

    createSection(p, "Farm Boss")
    local bossOptions = {"The Gorilla King", "Bobby", "Yeti", "Mob Leader", "Vice Admiral", "Warden", "Chief Warden", "Saber Expert", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Ice Admiral", "Greybeard", "Diamond", "Jeremy", "Fajita", "Don Swan", "Smoke Admiral", "Cursed Captain", "Awakened Ice Admiral", "Tide Keeper", "Order", "Darkbeard", "Cake Queen", "Beautiful Pirate", "rip_indra", "Longma", "Soul Reaper", "Dough King", "Cake Prince", "Tyrant of the Skies"}
    createDropdown(p, "Select Boss", bossOptions, bossOptions[1], function(v) _G.FindBoss = v end)
    createToggle(p, "Auto Farm Boss", false, function(s) _G.FarmBoss = s end)
    createToggle(p, "Accept Quests (Boss)", true, function(s) _G.AcceptQuestBoss = s end)
    createToggle(p, "Auto Farm All Boss", false, function(s) _G.AutoFarmAllBoss = s end)

    createSection(p, "Farming Mastery")
    createToggle(p, "Auto Mastery Fruits", false, function(s) _G.FarmMastery_Dev = s end)
    createToggle(p, "Auto Mastery Gun", false, function(s) _G.FarmMastery_G = s end)
    createToggle(p, "Auto Mastery All Sword", false, function(s) _G.FarmMastery_S = s end)
    createSlider(p, "NPC Health % Switch Weapon", 10, 95, 70, function(v) _G.MasteryHealthPct = v end)
    createDropdown(p, "Choose Mastery Island", {"Cake", "Bone"}, "Bone", function(v) _G.SelectIsland = v end)
    createSection(p, "Mastery Skills")
    _G.SelectedMasterySkills = _G.SelectedMasterySkills or {"Z", "X", "C", "V", "F"}
    for _, skillName in ipairs({"Z", "X", "C", "V", "F", "Y"}) do
        local enabled = table.find(_G.SelectedMasterySkills, skillName) ~= nil
        createToggle(p, "Use Skill " .. skillName, enabled, function(on)
            local selected = _G.SelectedMasterySkills or {}
            local index = table.find(selected, skillName)
            if on and not index then table.insert(selected, skillName) end
            if not on and index then table.remove(selected, index) end
            _G.SelectedMasterySkills = selected
        end)
    end

    createSection(p, "Farm All Island")
    local islandOptions = {}
    pcall(function()
        if Core and type(Core.Island) == "table" then
            for islandName in pairs(Core.Island) do table.insert(islandOptions, tostring(islandName)) end
            table.sort(islandOptions)
        end
    end)
    if #islandOptions == 0 then islandOptions = {"Sea 1", "Sea 2", "Sea 3"} end
    createDropdown(p, "Select Island", islandOptions, islandOptions[1], function(v) _G.SelectIsland = v end)
    createToggle(p, "Auto Farm All Island", false, function(s) _G.AutoFarmIsland = s end)

    createSection(p, "Farm Material")
    local materialOptions = {
        "Scrap Metal", "Leather", "Angel Wings", "Magma Ore", "Fish Tail", "Vampire Fang",
        "Mystic Droplet", "Radioactive Material", "Ectoplasm", "Demonic Wisp", "Conjured Cocoa",
        "Dragon Scale", "Gunpowder", "Mini Tusk", "Yeti Fur", "Bones"
    }
    if type(MaterialList) == "table" and #MaterialList > 0 then materialOptions = MaterialList end
    createDropdown(p, "Choose Material", materialOptions, materialOptions[1], function(v) getgenv().SelectMaterial = v end)
    createToggle(p, "Auto Farm Materials", false, function(s) getgenv().AutoMaterial = s end)

    createSection(p, "Tyrant of the Skies")
    local tyrantStatus = createParagraph(p, "Boss Spawn", "Checking...")
    task.spawn(function()
        while pwait(p, 1) do
            pcall(function()
                local found = workspace:FindFirstChild("Enemies") and workspace.Enemies:FindFirstChild("Tyrant of the Skies")
                tyrantStatus:SetContent(found and " Tyrant of the Skies spawned" or " Not spawned")
            end)
        end
    end)
    local eyesStatus = createParagraph(p, "Check Status Eyes", "Eyes: --/4")
    task.spawn(function()
        while pwait(p, 1) do
            pcall(function()
                if type(Check_Eye) == "function" then
                    local count = Check_Eye()
                    eyesStatus:SetContent("Eyes: " .. tostring(count) .. "/4")
                end
            end)
        end
    end)
    createToggle(p, "Auto Farm Boss TOTS", false, function(s) _G.FarmTyrant = s end)
    createToggle(p, "Auto Summon Boss", false, function(s) _G.FarmPhaBinh = s end)

    createSection(p, "Magnet Token Event")
    local magnetStatus = createParagraph(p, "Magnet Event Status", "Waiting for event")
    local magnetRunStatus = createParagraph(p, "Farm Status", "Idle")
    task.spawn(function()
        while pwait(p, 1) do
            pcall(function()
                local t = os.date("*t")
                local active = t.min < 10
                local left = active and ((10 - t.min) * 60 - t.sec) or ((60 - t.min) * 60 - t.sec)
                local label = active and "ACTIVE" or "INACTIVE"
                magnetStatus:SetContent(string.format("%s — %02d:%02d", label, math.floor(math.max(left, 0) / 60), math.max(left, 0) % 60))
            end)
        end
    end)
    createToggle(p, "Auto Farm Magnet Token", false, function(s)
        _G.AutoMagnetToken = s
        _G.MagnetEventSpawnIndex = _G.MagnetEventSpawnIndex or 1
        magnetRunStatus:SetContent(s and "Starting..." or "Idle")
        if not s then _G.MagnetEventSpawnIndex = 1 end
    end)
end)


-- TAB: Halloween Event (module dựng sẵn trong menu — core hiện tại không có Core.Halloween)
createTab("Halloween", 449, nil, function(p)
    local HW = {}
    getgenv().__MetaHW = HW
    local token = {}
    HW.token = token
    local VirtualUser = game:GetService("VirtualUser")
    local function running() return HW.token == token and p:IsDescendantOf(game) end

    createSection(p, "Halloween Event")
    local status = createParagraph(p, "Status", "Sẵn sàng")
    local function setStatus(t) status:SetContent(t) end

    -- ===== tiện ích =====
    local function matches(name, pats)
        local n = tostring(name):lower()
        for _, pat in ipairs(pats) do
            if n:find(pat, 1, true) then return true end
        end
        return false
    end
    local function root()
        local c = plr.Character
        return c and c:FindFirstChild("HumanoidRootPart")
    end
    local function isAlive(m)
        local h = m:FindFirstChildOfClass("Humanoid")
        return h and h.Health > 0
    end
    local function goTo(cf)
        if type(_tp) == "function" then
            pcall(_tp, cf)
        else
            local r = root()
            if r then r.CFrame = cf end
        end
    end
    local function equip()
        if type(EquipWeapon) == "function" and _G.SelectWeapon then pcall(EquipWeapon, _G.SelectWeapon) end
    end
    local function swing()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
        end)
    end
    local function nodePos(node)
        if node:IsA("Model") then return node:GetPivot().Position end
        return node.Position
    end
    local function inCharacter(node)
        local a = node.Parent
        while a and a ~= workspace do
            if a:FindFirstChildOfClass("Humanoid") then return true end
            a = a.Parent
        end
        return false
    end
    local function hasInteract(node)
        return node:FindFirstChildWhichIsA("ProximityPrompt", true) ~= nil or node:FindFirstChildWhichIsA("ClickDetector", true) ~= nil
    end
    local function interact(node)
        local prompt = node:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and type(fireproximityprompt) == "function" then
            pcall(function() prompt.HoldDuration = 0 end)
            pcall(fireproximityprompt, prompt)
            return "prompt"
        end
        local click = node:FindFirstChildWhichIsA("ClickDetector", true)
        if click and type(fireclickdetector) == "function" then
            pcall(fireclickdetector, click)
            return "click"
        end
        return nil
    end
    local function partsAround(radius)
        local r = root()
        if not r then return {} end
        local params = OverlapParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {plr.Character}
        return workspace:GetPartBoundsInRadius(r.Position, radius, params)
    end

    -- ===== tìm mục tiêu =====
    local function findEnemy(pats)
        local r = root()
        if not r then return nil end
        local best, bd
        local function consider(m)
            if m:IsA("Model") and matches(m.Name, pats) and isAlive(m) and not Players:GetPlayerFromCharacter(m) then
                local hrp = m:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - r.Position).Magnitude
                    if not bd or d < bd then best, bd = m, d end
                end
            end
        end
        local en = workspace:FindFirstChild("Enemies")
        if en then
            for _, m in ipairs(en:GetChildren()) do consider(m) end
        end
        for _, m in ipairs(workspace:GetChildren()) do consider(m) end
        return best
    end

    local function findNode(pats, radius, requireInteract)
        local r = root()
        if not r then return nil end
        local best, bd
        local seen = {}
        for _, part in ipairs(partsAround(radius)) do
            local node = part
            for _ = 1, 4 do
                if not node or node == workspace then break end
                if not seen[node] and matches(node.Name, pats) then
                    seen[node] = true
                    if not node:FindFirstChildOfClass("Humanoid") and not inCharacter(node) and (not requireInteract or hasInteract(node)) then
                        local ok, pos = pcall(nodePos, node)
                        if ok then
                            local d = (pos - r.Position).Magnitude
                            if not bd or d < bd then best, bd = node, d end
                        end
                    end
                end
                node = node.Parent
            end
        end
        return best
    end

    local npcCache = {}
    local function findNpc(key, pats)
        local c = npcCache[key]
        if c and c:IsDescendantOf(workspace) then return c end
        npcCache[key] = nil
        local function scanFolder(folder)
            if not folder then return nil end
            for _, m in ipairs(folder:GetChildren()) do
                if (m:IsA("Model") or m:IsA("BasePart")) and matches(m.Name, pats) then return m end
            end
            return nil
        end
        local found = scanFolder(workspace:FindFirstChild("NPCs")) or scanFolder(workspace)
        if not found then
            for _, d in ipairs(workspace:GetDescendants()) do
                if d:IsA("Model") and matches(d.Name, pats) and d:FindFirstChildOfClass("Humanoid") then
                    found = d
                    break
                end
            end
        end
        npcCache[key] = found
        return found
    end

    -- ===== thân vòng lặp cho từng chức năng =====
    local function fightBody(pats, label)
        return function()
            local target = findEnemy(pats)
            if target then
                local hrp = target:FindFirstChild("HumanoidRootPart")
                setStatus(label .. ": " .. target.Name)
                equip()
                goTo(hrp.CFrame * CFrame.new(0, 22, 0))
            else
                setStatus(label .. ": chưa thấy mục tiêu (" .. table.concat(pats, "/") .. ")")
                task.wait(0.6)
            end
        end
    end

    local function nodeBody(pats, radius, label, canSwing, requireInteract)
        return function()
            local node = findNode(pats, radius, requireInteract)
            if node then
                local ok, pos = pcall(nodePos, node)
                if ok then
                    setStatus(label .. ": " .. node.Name)
                    equip()
                    goTo(CFrame.new(pos + Vector3.new(0, 4, 0)))
                    local how = interact(node)
                    if not how and canSwing then swing() end
                end
            else
                setStatus(label .. ": không thấy trong " .. radius .. " studs")
                task.wait(0.8)
            end
        end
    end

    local function npcBody(key, pats, label)
        return function()
            local npc = findNpc(key, pats)
            if not npc then
                setStatus(label .. ": không tìm thấy NPC (" .. table.concat(pats, "/") .. ") — bấm Scan")
                task.wait(3)
                return
            end
            local ok, pos = pcall(nodePos, npc)
            if not ok then
                task.wait(1)
                return
            end
            goTo(CFrame.new(pos + Vector3.new(0, 3, 6)))
            local r = root()
            if r and (r.Position - pos).Magnitude < 25 then
                local how = interact(npc)
                setStatus(label .. ": " .. (how and ("đã gọi " .. how .. " của " .. npc.Name) or ("đã tới " .. npc.Name .. " — không có prompt, cần thao tác tay")))
                task.wait(2.5)
            else
                setStatus(label .. ": đang bay tới " .. npc.Name)
            end
        end
    end

    local bodies = {
        TrickOrTreat = nodeBody({"trick", "treat", "door"}, 350, "Trick or Treat", false, true),
        Pumpkins = nodeBody({"pumpkin"}, 600, "Pumpkins", true, false),
        Jack = fightBody({"jack", "lantern", "snowman"}, "Jack o' Lantern"),
        Bosses = fightBody({"hellfire", "hell rider", "great pumpkin", "pumpkin king", "werewolf"}, "Boss"),
        Summon = npcBody("witch", {"witch"}, "Summon"),
        Gacha = npcBody("gacha", {"zioles", "gacha", "spooky"}, "Gacha"),
    }

    local gen = {}
    local function startLoop(key, body)
        gen[key] = (gen[key] or 0) + 1
        local g = gen[key]
        task.spawn(function()
            while running() and HW[key] and gen[key] == g do
                local ok, err = pcall(body)
                if not ok then warn("[Meta Hub] Halloween " .. key .. ": " .. tostring(err)) end
                task.wait(0.15)
            end
        end)
    end

    -- ===== Scan: in ra các object/remote/prompt liên quan Halloween =====
    local function scan()
        local lines = {}
        local function add(s)
            if #lines < 150 then lines[#lines + 1] = s end
        end
        local pats = {"halloween", "pumpkin", "jack", "lantern", "witch", "candy", "trick", "treat", "hellfire", "hell rider", "werewolf", "gacha", "spooky", "zioles", "snowman", "cauldron", "potion", "seed", "bits"}
        for _, container in ipairs({workspace, workspace:FindFirstChild("NPCs"), workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Map"), workspace:FindFirstChild("_WorldOrigin")}) do
            if container then
                for _, ch in ipairs(container:GetChildren()) do
                    if matches(ch.Name, pats) then add("[obj] " .. ch:GetFullName() .. " (" .. ch.ClassName .. ")") end
                end
            end
        end
        for _, d in ipairs(replicated:GetDescendants()) do
            if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and matches(d.Name, pats) then
                add("[remote] " .. d:GetFullName())
            end
        end
        local data = plr:FindFirstChild("Data")
        if data then
            for _, v in ipairs(data:GetChildren()) do
                if matches(v.Name, pats) then add("[data] " .. v.Name .. " = " .. tostring(v:IsA("ValueBase") and v.Value or v.ClassName)) end
            end
        end
        local seen = {}
        for _, part in ipairs(partsAround(300)) do
            local pr = part:FindFirstChildOfClass("ProximityPrompt")
            if pr and not seen[pr] then
                seen[pr] = true
                add("[prompt] " .. part:GetFullName() .. " action=" .. tostring(pr.ActionText) .. " object=" .. tostring(pr.ObjectText))
            end
        end
        for _, l in ipairs(lines) do print("[Meta Hub][scan] " .. l) end
        local copied = false
        if type(setclipboard) == "function" and #lines > 0 then
            copied = pcall(setclipboard, table.concat(lines, "\n"))
        end
        setStatus("Scan: " .. #lines .. " mục" .. (copied and " (đã copy clipboard)" or "") .. " — xem console (F9)")
        NotifyIOS27("Scan Halloween", #lines .. " mục" .. (copied and ", đã copy clipboard" or ", xem console") , #lines > 0 and "ok" or "warn", 4)
    end

    -- ===== công tắc =====
    local options = {
        {"TrickOrTreat", "Auto Trick Or Treat"},
        {"Pumpkins", "Auto Farm Pumpkins"},
        {"Jack", "Auto Kill Event Enemy"},
        {"Bosses", "Auto Halloween Bosses"},
        {"Summon", "Auto Summon Great Pumpkin"},
        {"Gacha", "Auto Spooky Gacha"},
    }
    for _, option in ipairs(options) do
        local key, label = option[1], option[2]
        createToggle(p, label, false, function(on)
            if Core and Core.Halloween and type(Core.Halloween.SetEnabled) == "function" then
                Core.Halloween:SetEnabled(key, on)
                return
            end
            HW[key] = on
            if on then
                startLoop(key, bodies[key])
            else
                setStatus("Đã tắt " .. label)
            end
        end)
    end

    createSection(p, "Công cụ")
    createButton(p, "Scan Halloween (console + clipboard)", scan)
    createParagraph(p, "Lưu ý", "Core hiện tại không có module Halloween nên các chức năng này chạy bằng tên NPC/boss theo guide, chưa test trong game. Bấm Scan rồi gửi kết quả để chỉnh cho đúng.")
end)

-- TAB 3: Setting
createTab("Setting", 79, nil, function(p)
    createSection(p, "Combat Settings")
    createToggle(p, "Fast Attack", true, function(s) _G.Seriality = s end)
    createToggle(p, "Bring Mobs", true, function(s) _B = s end)
    createToggle(p, "Auto Turn on Buso", true, function(s) Boud = s end)
    createToggle(p, "Auto Haki Observation", false, function(s) getgenv().Observation = s end)
    createToggle(p, "Auto Turn on Race V3", false, function(s) _G.RaceClickAutov3 = s end)
    createToggle(p, "Auto Turn on Race V4", false, function(s) _G.RaceClickAutov4 = s end)
    createToggle(p, "Safe Mode", false, function(s) _G.Safemode = s end)
    createToggle(p, "Remove Hit VFX", false, function(s) _G.DestroyHit = s end)
    createToggle(p, "Remove Death & Respawned VFX", false, function(s) RDeath = s end)
    createToggle(p, "Disable Notify", false, function(s) RemoveDamage = s end)
    createToggle(p, "No Clip", false, function(s) getgenv().NoClip = s end)
    createToggle(p, "Anti AFK", true, function(s)
        if s then
            local VirtualUser = game:GetService("VirtualUser")
            repeat wait() until game:IsLoaded()
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end)
    createToggle(p, "Auto Anti - Admin Join Server", true, function(s) getgenv().HopServerAdmin = s end)
    createToggle(p, "Auto Set Spawn Point", false, function(s)
        getgenv().Set = s
        if s then pcall(function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("SetSpawnPoint") end) end
    end)

    createSection(p, "Server Hop")
    createToggle(p, "Auto Hop Server with time", false, function(s) _G.AutoHopServer = s if not s then _G.HopTimer = nil end end)
    createSlider(p, "Hop Delay (Minutes)", 5, 120, 30, function(v) _G.HopDelay = v * 60 end)
end)

-- TAB 4: Quest And Item
createTab("Quest", 116, nil, function(p)
    createSection(p, "Sea Quests")
    createToggle(p, "Auto Quest Sea 2", false, function(s) _G.TravelDres = s end)
    createToggle(p, "Auto Quest Sea 3", false, function(s) _G.AutoZou = s end)

    createSection(p, "Tushita + Yama")
    createToggle(p, "Auto Tushita Sword", false, function(s) _G.Auto_Tushita = s end)
    createToggle(p, "Auto Yama Sword", false, function(s) _G.Auto_Yama = s end)

    createSection(p, "Cursed Dual Katana")
    createToggle(p, "Auto Get CDK [Last Quest]", false, function(s) _G.CDK = s end)
    createToggle(p, "Auto Yama CDK", false, function(s) _G.CDK_YM = s end)
    createToggle(p, "Auto Tushita CDK", false, function(s) _G.CDK_TS = s end)

    createSection(p, "Skull Guitar")
    createToggle(p, "Auto Skull Guitar", false, function(s) _G.Auto_Soul_Guitar = s end)
    createToggle(p, "Auto Farm Material Skull Guitar", false, function(s) _G.AutoMatSoul = s end)

    createSection(p, "Legendary Swords")
    createButton(p, "Buy Legendary Sword", function()
        replicated.Remotes.CommF_:InvokeServer("LegendarySwordDealer","1")
        replicated.Remotes.CommF_:InvokeServer("LegendarySwordDealer","2")
        replicated.Remotes.CommF_:InvokeServer("LegendarySwordDealer","3")
    end)
    createButton(p, "Buy True Triple Katana Sword", function()
        replicated.Remotes.CommF_:InvokeServer("MysteriousMan","2")
    end)
    createToggle(p, "Tween to Legendary Sword Dealer", false, function(s) _G.Tp_LgS = s end)

    createSection(p, "Fighting Styles")
    createToggle(p, "Auto Superhuman", false, function(s) _G.Auto_SuperHuman = s end)
    createToggle(p, "Auto DeathStep", false, function(s) _G.AutoDeathStep = s end)
    createToggle(p, "Auto Sharkman Karate", false, function(s) _G.Auto_SharkMan_Karate = s end)
    createToggle(p, "Auto ElectricClaw", false, function(s) _G.Auto_Electric_Claw = s end)
    createToggle(p, "Auto DragonTalon", false, function(s) _G.AutoDragonTalon = s end)
    createToggle(p, "Auto Godhuman", false, function(s) _G.Auto_God_Human = s end)
    createToggle(p, "Auto SanguineArt", false, function(s) _G.Snaguine = s end)

    createSection(p, "Observation / Instinct")
    createToggle(p, "Auto Farm Observation", false, function(s) _G.obsFarm = s end)
    createToggle(p, "Auto Observation V2", false, function(s) _G.AutoKenVTWO = s end)
    createToggle(p, "Auto Done Bartilo Quest", false, function(s) _G.Bartilo_Quest = s end)
    createToggle(p, "Auto Done Citizen Quest", false, function(s) _G.CitizenQuest = s end)
    createToggle(p, "Auto Training Dummy", false, function(s) _G.DummyMan = s end)

    createSection(p, "Misc Items")
    createToggle(p, "Auto Pole V1", false, function(s) _G.AutoPole = s end)
    createToggle(p, "Auto Pole V2", false, function(s) _G.AutoPoleV2 = s end)
    createToggle(p, "Auto Saw Sword", false, function(s) _G.AutoSaw = s end)
    createToggle(p, "Auto Saber Sword", false, function(s) _G.AutoSaber = s end)
    createToggle(p, "Auto Cybrog", false, function(s) _G.AutoColShad = s end)
    createToggle(p, "Auto Usoap's Hat", false, function(s) _G.AutoGetUsoap = s end)
    createToggle(p, "Auto Bisento V2", false, function(s) _G.Greybeard = s end)
    createToggle(p, "Auto Warden Sword", false, function(s) _G.WardenBoss = s end)
    createToggle(p, "Auto Marine Coat", false, function(s) _G.MarinesCoat = s end)
    createToggle(p, "Auto Swan Coat", false, function(s) _G.SwanCoat = s end)
    createToggle(p, "Auto Rengoku Sword", false, function(s) _G.IceBossRen = s end)
    createToggle(p, "Auto Key Rengoku", false, function(s) _G.KeysRen = s end)
    createToggle(p, "Auto Dragon Trident", false, function(s) _G.AutoTridentW2 = s end)
    createToggle(p, "Auto Long Sword", false, function(s) _G.LongsWord = s end)
    createToggle(p, "Auto Black Spikey", false, function(s) _G.BlackSpikey = s end)
    createToggle(p, "Auto Dark Blade V3", false, function(s) _G.DarkBladev3 = s end)
    createToggle(p, "Auto Midnight Blade", false, function(s) _G.AutoEcBoss = s end)
    createToggle(p, "Auto Darkbeard", false, function(s) _G.Auto_Def_DarkCoat = s end)
    createToggle(p, "Auto Unlocked DonSwan", false, function(s) _G.Auto_DonAcces = s end)
    createToggle(p, "Auto Swan Glasses", false, function(s) _G.Auto_SwanGG = s end)
    createToggle(p, "Auto Bigmom", false, function(s) _G.AutoBigmom = s end)
    createToggle(p, "Auto Cavendish Sword", false, function(s) _G.Auto_Cavender = s end)
    createToggle(p, "Auto Twin Hooks", false, function(s) _G.TwinHook = s end)
    createToggle(p, "Auto Serpent Bow", false, function(s) _G.AutoSerpentBow = s end)
    createToggle(p, "Auto Lei Accessory", false, function(s) _G.AutoKilo = s end)

    createSection(p, "Buso/Aura Colors")
    createToggle(p, "Auto Teleport Barista Cousin", false, function(s) _G.Tp_MasterA = s end)
    createButton(p, "Buy Buso Colors", function() replicated.Remotes.CommF_:InvokeServer("ColorsDealer","2") end)
    createToggle(p, "Auto Rainbow Colors", false, function(s) _G.Auto_Rainbow_Haki = s end)
    createToggle(p, "Accept Rainbow Quest Faster", false, function(s) _G.GetQFast = s end)
end)

-- TAB 5: Sea Event
createTab("SeaEvent", 153, nil, function(p)
    createSection(p, "Ship Settings")
    createButton(p, "Remove Lighting Effect", function() game:GetService("Lighting").BaseAtmosphere:Destroy() end)
    createToggle(p, "Ship Speed Modifier", false, function(s) getgenv().SpeedBoat = s end)
    createSlider(p, "Ship Speed", 0, 1000, 300, function(v) SetSpeedBoat = v end)
    createToggle(p, "Auto Press W", false, function(s) getgenv().AutoPressW = s end)
    createToggle(p, "No Clip Ship", false, function(s) getgenv().NoClipShip = s end)

    createSection(p, "Crafting Items")
    for _, item in ipairs({"SharkTooth","TerrorJaw","SharkAnchor","LeviathanCrown","LeviathanShield","LeviathanBoat","LegendaryScroll","MythicalScroll"}) do
        createButton(p, "Craft " .. item, function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CraftItem","Craft",item) end)
    end

    createSection(p, "Sea Event Mobs")
    createToggle(p, "Auto Shark", false, function(s) _G.Shark = s end)
    createToggle(p, "Auto Piranha", false, function(s) _G.Piranha = s end)
    createToggle(p, "Auto Terror Shark", false, function(s) _G.TerrorShark = s end)
    createToggle(p, "Auto Fish Crew Member", false, function(s) _G.MobCrew = s end)
    createToggle(p, "Auto Haunted Crew Member", false, function(s) _G.HCM = s end)
    createToggle(p, "Auto Attack PirateGrandBrigade", false, function(s) _G.PGB = s end)
    createToggle(p, "Auto Attack Fish Boat", false, function(s) _G.FishBoat = s end)
    createToggle(p, "Auto Attack Sea Beast", false, function(s) _G.SeaBeast1 = s end)

    createSection(p, "Kitsune Island")
    local ki = createParagraph(p, "Kitsune Island Status", "")
    spawn(function()
        while pwait(p, 0.5) do
            pcall(function()
                local f = workspace.Map:FindFirstChild("KitsuneIsland") or workspace._WorldOrigin.Locations:FindFirstChild("Kitsune Island")
                ki:SetContent(f and "Spawned" or "Not spawned")
            end)
        end
    end)
    createToggle(p, "Auto Find Kitsune Island", false, function(s) _G.AutofindKitIs = s end)
    createToggle(p, "Auto Teleport to Shrine Actived", false, function(s) _G.tweenShrine = s end)
    createToggle(p, "Auto Collect Azure Ember", false, function(s) _G.Collect_Ember = s end)
    createToggle(p, "Auto Trade Azure Ember", false, function(s) _G.Trade_Ember = s end)
    createButton(p, "Trade Items Azure", function() replicated.Modules.Net:FindFirstChild("RF/KitsuneStatuePray"):InvokeServer() end)
    createButton(p, "Talk with kitsune statue", function() replicated.Modules.Net:FindFirstChild("RE/TouchKitsuneStatue"):FireServer() end)

    createSection(p, "Frozen Dimension")
    local fd = createParagraph(p, "FrozenDimension Status", "")
    spawn(function()
        while pwait(p, 0.5) do
            pcall(function()
                local f = workspace._WorldOrigin.Locations:FindFirstChild("Frozen Dimension")
                fd:SetContent(f and "Spawned" or "Not spawned")
            end)
        end
    end)
    createToggle(p, "Auto Teleport Frozen Dimension", false, function(s) _G.FrozenTP = s end)
    createToggle(p, "Auto Drive To Hydra Island", false, function(s) _G.SailBoat_Hydra = s end)
    createToggle(p, "Auto Attack Leviathan", false, function(s) _G.Leviathan1 = s end)
end)

-- TAB 6: Race
createTab("Race", 190, nil, function(p)
    createSection(p, "Mirage Island / Full Moon")
    local mi = createParagraph(p, "Mirage Island Status", "")
    spawn(function()
        while pwait(p, 0.5) do
            pcall(function()
                local f = workspace.Map:FindFirstChild("MysticIsland") or workspace._WorldOrigin.Locations:FindFirstChild("Mirage Island")
                mi:SetContent(f and " True" or " False")
            end)
        end
    end)
    createToggle(p, "Auto Find Mirage Island", false, function(s) _G.FindMirage = s end)
    createToggle(p, "Esp Mirage Island", false, function(s) MirageIslandESP = s end)
    createToggle(p, "Auto Tween To Mirage Island", false, function(s) _G.AutoMysticIsland = s end)
    createToggle(p, "Auto Tween To Highest Point", false, function(s) _G.HighestMirage = s end)
    createToggle(p, "Auto Collect Gear", false, function(s) _G.TPGEAR = s end)
    createToggle(p, "Change Transparency can see", false, function(s) _G.can = s end)
    createToggle(p, "Auto Tween Advanced Fruit Dealer", false, function(s) _G.Addealer = s end)
    createToggle(p, "Auto Collect Mirage Chest", false, function(s) _G.FarmChestM = s end)
    createButton(p, "Talk With Stone", function()
        replicated:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Begin")
        replicated:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Check")
        replicated:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Teleport")
        replicated:WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer("RaceV4Progress","Continue")
    end)
    createToggle(p, "Auto Look At Moon", false, function(s) LookM = s end)
    createToggle(p, "Look Moon + Auto V3", false, function(s) LookMV3 = s end)

    createSection(p, "Upgrade Races V2/V3")
    createToggle(p, "Auto Upgrade Mink", false, function(s) _G.Auto_Mink = s end)
    createToggle(p, "Auto Upgrade Human", false, function(s) _G.Auto_Human = s end)
    createToggle(p, "Auto Upgrade Angel", false, function(s) _G.Auto_Skypiea = s end)
    createToggle(p, "Auto Upgrade FishMan", false, function(s) _G.Auto_Fish = s end)

    createSection(p, "Trials Quest V4")
    local tv = createParagraph(p, "Tiers V4 Status", "")
    spawn(function()
        while pwait(p, 0.5) do
            pcall(function() tv:SetContent("Tiers - V4: " .. tostring(plr.Data.Race.C.Value)) end)
        end
    end)
    createToggle(p, "Auto Pull Lever", false, function(s) _G.Lver = s end)
    createToggle(p, "Auto Train V4", false, function(s) _G.AcientOne = s end)
    createButton(p, "Teleport to Temple of Time", function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(28286.355, 14895.302, 102.625) end
    end)
    createButton(p, "Teleport to Ancient One", function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(28286.355, 14895.302, 102.625) end
        task.wait(2)
        if hrp then hrp.CFrame = CFrame.new(28981.553, 14888.427, -120.246) end
    end)
    createButton(p, "Teleport to Ancient Clock", function()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(28286.355, 14895.302, 102.625) end
        task.delay(2, function() if hrp then hrp.CFrame = CFrame.new(29549, 15069, -88) end end)
    end)
    createToggle(p, "Auto Teleport to Race Doors", false, function(s) _G.TPDoor = s end)
    createToggle(p, "Auto Complete Trial Race", false, function(s) _G.Complete_Trials = s end)
    createToggle(p, "Auto Kill Player After Trial", false, function(s) _G.Defeating = s end)
end)

-- TAB 7: Esp
createTab("Esp", 227, nil, function(p)
    createSection(p, "Stats Upgrade")
    createSlider(p, "Stats Value", 0, 1000, 10, function(v) pSats = v end)
    createToggle(p, "Auto Melee", false, function(s) _G.Auto_Melee = s end)
    createToggle(p, "Auto Swords", false, function(s) _G.Auto_Sword = s end)
    createToggle(p, "Auto Gun", false, function(s) _G.Auto_Gun = s end)
    createToggle(p, "Auto Blox Fruit", false, function(s) _G.Auto_DevilFruit = s end)
    createToggle(p, "Auto Defense", false, function(s) _G.Auto_Defense = s end)

    createSection(p, "ESP")
    createToggle(p, "Esp Berry", false, function(s) BerryEsp = s end)
    createToggle(p, "Esp Player", false, function(s) PlayerEsp = s end)
    createToggle(p, "Esp Chest", false, function(s) ChestESP = s end)
    createToggle(p, "Esp Fruit", false, function(s) DevilFruitESP = s end)
    createToggle(p, "Esp Island", false, function(s) IslandESP = s end)
    createToggle(p, "Esp Flower", false, function(s) FlowerESP = s end)
    createToggle(p, "Esp Legendary Sword", false, function(s) LegenS = s end)
    createToggle(p, "Esp Haki Color", false, function(s) ColorEsp = s end)
    createToggle(p, "Esp Gear", false, function(s) ESPGear = s end)
    createToggle(p, "Esp SeaEvent Island", false, function(s) EspEventIsland = s end)
    createToggle(p, "Esp Advanced Dealer", false, function(s) advanEsp = s end)

    -- Core chỉ định nghĩa hàm ESP (Core.EspPly, Core.DevEsp...) mà không tự gọi -> phải có vòng lặp gọi chúng
    local function mirageEsp()
        local wo = workspace:FindFirstChild("_WorldOrigin")
        local locs = wo and wo:FindFirstChild("Locations")
        if not locs then return end
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        for _, child in ipairs(locs:GetChildren()) do
            if child.Name == "Mirage Island" then
                local gui = child:FindFirstChild("MetaMirageEsp")
                if MirageIslandESP and head then
                    if not gui then
                        gui = Instance.new("BillboardGui")
                        gui.Name = "MetaMirageEsp"
                        gui.Size = UDim2.new(0, 220, 0, 40)
                        gui.AlwaysOnTop = true
                        gui.Adornee = child
                        gui.Parent = child
                        local tl = Instance.new("TextLabel")
                        tl.Name = "L"
                        tl.Size = UDim2.fromScale(1, 1)
                        tl.BackgroundTransparency = 1
                        tl.Font = Enum.Font.Code
                        tl.TextSize = 14
                        tl.TextColor3 = Color3.fromRGB(80, 245, 245)
                        tl.TextStrokeTransparency = 0.5
                        tl.Parent = gui
                    end
                    gui.L.Text = "Mirage Island\n" .. math.floor((head.Position - child.Position).Magnitude / 3) .. " M"
                elseif gui then
                    gui:Destroy()
                end
            end
        end
    end

    local espJobs = {
        {"EspPly", function() return PlayerEsp end},
        {"LocationEsp", function() return IslandESP end},
        {"DevEsp", function() return DevilFruitESP end},
        {"flowerEsp", function() return FlowerESP end},
        {"EventIslandEsp", function() return EspEventIsland end},
        {"gearEsp", function() return ESPGear end},
        {"AdvanFruitEsp", function() return advanEsp end},
        {"HakiClorEsp", function() return ColorEsp end},
        {"LegenSword", function() return LegenS end},
        {"ChestEsp", function() return ChestESP end},
        {"berriesEsp", function() return BerryEsp end},
        {"__mirage", function() return MirageIslandESP end, mirageEsp},
    }
    local espToken = {}
    getgenv().__MetaEspToken = espToken
    local espWasOn = {}
    task.spawn(function()
        while screenGui.Parent and getgenv().__MetaEspToken == espToken do
            for _, job in ipairs(espJobs) do
                local on = job[2]() and true or false
                if on or espWasOn[job[1]] then -- chạy khi đang bật, và thêm 1 nhịp sau khi tắt để dọn nhãn
                    local fn = job[3] or (Core and Core[job[1]]) or getgenv()[job[1]]
                    if type(fn) == "function" then pcall(fn) end
                end
                espWasOn[job[1]] = on
            end
            task.wait(0.3)
        end
    end)
end)

-- TAB 8: Fruit And Raid
createTab("Raids", 264, nil, function(p)
    createSection(p, "Fruits Options")
    local sf = createParagraph(p, "Stock Fruit", "Loading...")
    createToggle(p, "Auto Random Fruit", false, function(s) _G.Random_Auto = s; _G.RandomFruitCooldown = nil end)
    createToggle(p, "Auto Drop Fruit", false, function(s) _G.DropFruit = s end)
    createToggle(p, "Auto Store Fruit", false, function(s) _G.StoreF = s end)
    createToggle(p, "Auto Tween to Fruit", false, function(s) _G.TwFruits = s end)
    createToggle(p, "Auto Collect Fruit", false, function(s) _G.InstanceF = s end)

    local fruitOpts = {"Rocket","Spin","Blade","Spring","Bomb","Smoke","Spike","Flame","Ice","Sand","Dark","Eagle","Diamond","Light","Rubber","Ghost","Magma","Quake","Buddha","Love","Creation","Spider","Sound","Phoenix","Portal","Lightning","Pain","Blizzard","Gravity","T-Rex","Mammoth","Dough","Shadow","Venom","Gas","Control","Spirit","Leopard","Yeti","Kitsune","Dragon"}
    createDropdown(p, "Select Fruit Shop", fruitOpts, "Rocket", function(s) getgenv().SelectFruit = s end)
    createToggle(p, "Auto Buy Fruit Shop", false, function(s) getgenv().AutoBuyFruitSniper = s end)

    createSection(p, "Dungeon / Raiding")
    local chipOpts = {"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}
    createDropdown(p, "Select Chip", chipOpts, "Flame", function(s) _G.SelectChip = s end)
    createToggle(p, "Auto Select Dungeon Chip", false, function(s) _G.AutoSelectDungeon = s end)
    createToggle(p, "Get Fruit In Inventory Below 1M", false, function(s) getgenv().AutoGetFruit = s end)
    createButton(p, "Buy Dungeon Chips [Beli]", function()
        if not GetBP("Special Microchip") then
            replicated.Remotes.CommF_:InvokeServer("RaidsNpc","Select",_G.SelectChip)
        end
    end)
    createToggle(p, "Auto Buy Chip [Beli]", false, function(s) _G.AutoChipBeli = s end)
    createToggle(p, "Auto Buy Chip [Devil Fruit]", false, function(s) _G.AutoChipFruit = s end)
    createToggle(p, "Auto Start Raid", false, function(s) _G.Auto_StartRaid = s end)
    createToggle(p, "Auto Raid + Next Island", false, function(s) _G.Raiding = s end)
    createToggle(p, "Kill Aura (Island 4 & 5)", false, function(s) _G.KillAuraRaid = s end)
    createToggle(p, "Auto Awakening", false, function(s) _G.Auto_Awakener = s end)
    createToggle(p, "Auto Teleport To Lab", false, function(s)
        _G.TpLab = s
        while _G.TpLab do
            wait()
            if World2 then _tp(CFrame.new(-6438.735, 250.645, -4501.507))
            elseif World3 then _tp(CFrame.new(-5046, 314, -2960)) end
        end
    end)

    createSection(p, "Law Raids")
    createButton(p, "Buy Microchip Law", function() replicated.Remotes.CommF_:InvokeServer("BlackbeardReward","Microchip","2") end)
    createButton(p, "Start Law Raids", function() fireclickdetector(workspace.Map.CircleIsland.RaidSummon.Button.Main.ClickDetector) end)
    createToggle(p, "Auto Buy Microchip Law", false, function(s) getgenv().AutoBuyMicrochipLaw = s end)
    createToggle(p, "Auto Start Law Raids", false, function(s) getgenv().AutoStartLawRaids = s end)
    createToggle(p, "Auto Kill Law", false, function(s) _G.AutoLawKak = s end)

    createSection(p, "Dungeon Floors")
    createToggle(p, "Auto Farm Dungeon", false, function(s) _G.AutoFarmDungeon = s end)
    createToggle(p, "TP Exit (1)", false, function(s) _G.TPFloor1 = s end)
    createToggle(p, "TP Exit (2)", false, function(s) _G.TPFloor2 = s end)
    createToggle(p, "TP Exit (3)", false, function(s) _G.TPFloor3 = s end)
    createToggle(p, "TP Exit (4)", false, function(s) _G.TPFloor4 = s end)
end)

-- TAB 9: Local Player (Combat)
createTab("Combat", 301, nil, function(p)
    createSection(p, "Combat / AimBot")
    local ap = createParagraph(p, "All Players On Server", "")
    spawn(function()
        while pwait(p, 1) do
            pcall(function()
                local n = #game:GetService("Players"):GetPlayers()
                ap:SetContent("All Players: " .. n .. " / 12")
            end)
        end
    end)
    local ab = createParagraph(p, "Aimbot Status", "")
    spawn(function()
        while pwait(p, 0.2) do
            pcall(function()
                if _G.AimMethod then
                    if not _G.AimCam and not _G.AimbotGun then ab:SetContent("Aimbot - Skills: True")
                    else ab:SetContent("Aimbot: True") end
                else ab:SetContent("Aimbot - Skills: False") end
            end)
        end
    end)

    createToggle(p, "Aimbot Method Skills", false, function(s) _G.AimMethod = s end)
    createToggle(p, "Aimbot Camera Closet Players", false, function(s) _G.AimCam = s end)

    createSection(p, "Player Hunter")
    createButton(p, "Get player quests", function() pcall(function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("PlayerHunter") end) end)
    createToggle(p, "Auto Get PlayerQuest", false, function(s) _G.AutoReceivePlayerQuest = s end)
    createToggle(p, "Auto Kill Player Quest", false, function(s) _G.AutoPlayerHunter = s if not s then Useskill = false end end)
    createToggle(p, "Auto Enable PvP", false, function(s) _G.AutoPvP = s end)
    createToggle(p, "Auto Safe Mode", false, function(s) _G.SafeMode = s end)

    createSection(p, "LocalPlayer Settings")
    createToggle(p, "Enable Fly", false, function(s) toggleFly(s) end)
    createSlider(p, "Speed Fly Mode", 10, 200, 50, function(v) updateFlySpeed(v) end)
    createToggle(p, "Dash No Cooldown", false, function(s) getgenv().DodgeNoCD = s end)
    createToggle(p, "Instance Mink V3 [INF]", false, function(s) InfAblities = s end)
    createToggle(p, "Instance Energy [INF]", false, function(s) infEnergy = s if s then getInfinity_Ability("Energy", infEnergy) end end)
    createToggle(p, "Instance Soru [INF]", false, function(s) _G.InfSoru = s if s then getInfinity_Ability("Soru", _G.InfSoru) end end)
    createToggle(p, "Instance Observation Range [INF]", false, function(s) _G.InfiniteObRange = s if s then getInfinity_Ability("Observation", _G.InfiniteObRange) end end)
    createToggle(p, "Ignore Same Teams", false, function(s) _G.NoAimTeam = s end)
    createToggle(p, "Accept Allies", false, function(s) _G.AcceptAlly = s end)
end)

-- TAB 10: Teleport
createTab("Teleport", 338, nil, function(p)
    createSection(p, "Travel Worlds")
    createButton(p, "Travel East Blue (World 1)", function() replicated.Remotes.CommF_:InvokeServer("TravelMain") end)
    createButton(p, "Travel Dressrosa (World 2)", function() replicated.Remotes.CommF_:InvokeServer("TravelDressrosa") end)
    createButton(p, "Travel Zou (World 3)", function() replicated.Remotes.CommF_:InvokeServer("TravelZou") end)

    createSection(p, "Travel Islands")
    local locs = {}
    for k, child in pairs(workspace._WorldOrigin.Locations:GetChildren()) do table.insert(locs, child.Name) end
    createDropdown(p, "Select Travelling", locs, locs[1], function(s) _G.Island = s end)
    createToggle(p, "Auto Travel", false, function(s)
        _G.Teleport = s
        if s then
            task.spawn(function()
                while _G.Teleport do
                    wait()
                    for k, v in pairs(workspace._WorldOrigin.Locations:GetChildren()) do
                        if v.Name == _G.Island then
                            _tp(v.CFrame * CFrame.new(0, 30, 0))
                            break
                        end
                    end
                end
            end)
        end
    end)

    createSection(p, "Travel Portal")
    local portals = {"Sky","UnderWater","SwanRoom","Cursed Ship","Castle On The Sea","Mansion Cafe","Hydra Teleport","Canvendish Room","Temple of Time"}
    createDropdown(p, "Select Portal", portals, "Sky", function(s) _G.Island_PT = s end)
    createButton(p, "requestEntrance", function()
        local map = {
            ["Sky"] = Vector3.new(-7894, 5547, -380),
            ["UnderWater"] = Vector3.new(61163, 11, 1819),
            ["SwanRoom"] = Vector3.new(2285, 15, 905),
            ["Cursed Ship"] = Vector3.new(923, 126, 32852),
            ["Castle On The Sea"] = Vector3.new(-5097.93, 316.45, -3142.67),
            ["Mansion Cafe"] = Vector3.new(-12471.17, 374.94, -7551.68),
            ["Hydra Teleport"] = Vector3.new(5643.45, 1013.09, -340.51),
            ["Canvendish Room"] = Vector3.new(5314.55, 22.56, -127.07),
            ["Temple of Time"] = Vector3.new(28310.02, 14895.11, 109.46)
        }
        if map[_G.Island_PT] then
            replicated.Remotes.CommF_:InvokeServer("requestEntrance", map[_G.Island_PT])
        end
    end)

    createSection(p, "Travel NPCs")
    local npcs = {}
    for k, child in pairs(replicated.NPCs:GetChildren()) do table.insert(npcs, child.Name) end
    createDropdown(p, "Select NPCs", npcs, npcs[1], function(s) NPClist = s end)
    createToggle(p, "Auto Tween to NPC", false, function(s) _G.TPNpc = s end)
end)

-- TAB 11: Shopping
createTab("Shop", 375, nil, function(p)
    createSection(p, "Haki")
    createButton(p, "Buy Buso", function() replicated.Remotes.CommF_:InvokeServer("BuyHaki","Buso") end)
    createButton(p, "Buy Geppo", function() replicated.Remotes.CommF_:InvokeServer("BuyHaki","Geppo") end)
    createButton(p, "Buy Soru", function() replicated.Remotes.CommF_:InvokeServer("BuyHaki","Soru") end)
    createButton(p, "Buy Ken", function() replicated.Remotes.CommF_:InvokeServer("KenTalk","Buy") end)

    createSection(p, "Fighting Style")
    for _, item in ipairs({"Black Leg","Electro","Fishman Karate","Superhuman","Death Step","Sharkman Karate","ElectricClaw","DragonTalon","Godhuman","SanguineArt"}) do
        local cmd = "Buy" .. item:gsub(" ","")
        if item == "Black Leg" then cmd = "BuyBlackLeg"
        elseif item == "Electro" then cmd = "BuyElectro"
        elseif item == "Fishman Karate" then cmd = "BuyFishmanKarate" end
        createButton(p, "Buy " .. item, function() replicated.Remotes.CommF_:InvokeServer(cmd) end)
    end
    createButton(p, "Buy DragonClaw", function() replicated.Remotes.CommF_:InvokeServer("BlackbeardReward","DragonClaw","2") end)

    createSection(p, "Accessory")
    for _, item in ipairs({"Tomoe Ring","Black Cape","Swordsman Hat"}) do
        createButton(p, "Buy " .. item, function() replicated.Remotes.CommF_:InvokeServer("BuyItem", item) end)
    end
    createButton(p, "Buy Bizarre Rifle", function() replicated.Remotes.CommF_:InvokeServer("Ectoplasm","Buy",1) end)
    createButton(p, "Buy Ghoul Mask", function() replicated.Remotes.CommF_:InvokeServer("Ectoplasm","Buy",2) end)

    createSection(p, "Fragments Shop")
    createButton(p, "Buy Refund Stats", function() replicated.Remotes.CommF_:InvokeServer("BlackbeardReward","Refund","2") end)
    createButton(p, "Buy Reroll Race", function() replicated.Remotes.CommF_:InvokeServer("BlackbeardReward","Reroll","2") end)
    createButton(p, "Buy Ghoul Race", function() replicated.Remotes.CommF_:InvokeServer("Ectoplasm"," Change",4) end)
    createButton(p, "Buy Cyborg Race (2.5k)", function() replicated.Remotes.CommF_:InvokeServer("CyborgTrainer"," Buy") end)
end)

-- TAB 12: Miscellaneous
createTab("Misc", 412, nil, function(p)
    createSection(p, "Server Function")
    createButton(p, "Redeem All Codes", function()
        local codes = {"LIGHTNINGABUSE","1LOSTADMIN","ADMINFIGHT","GIFTING_HOURS","NOMOREHACK","BANEXPLOIT","WildDares","BossBuild","GetPranked","EARN_FRUITS","SUB2GAMERROBOT_RESET1","KITT_RESET","Bignews","CHANDLER","Fudd10","fudd10_v2","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE","Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","StEclipseodeheo","Bluxxy","SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2Daigrock","Axiore","TantaiGaming","StrawHatMaine","Sub2OfficialNoobie","TheGreatAce","JULYUPDATE_RESET","ADMINHACKED","SEATROLLING","24NOADMIN","ADMIN_TROLL","NEWTROLL","SECRET_ADMIN","staffbattle","NOEXPLOIT","NOOB2ADMIN","CODESLIDE","fruitconcepts","krazydares"}
        local redeem = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):FindFirstChild("Redeem")
        if not redeem then return end
        for i, code in ipairs(codes) do
            task.wait(0)
            pcall(function()
                if redeem.InvokeServer then redeem:InvokeServer(code) else redeem:FireServer(code) end
            end)
        end
    end)
    createButton(p, "Rejoin Server", function() game:GetService("TeleportService"):Teleport(game.PlaceId, player) end)
    createButton(p, "Hop Server", function()
        task.spawn(function()
            local HttpService = game:GetService("HttpService")
            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local ok, result = pcall(function()
                local response = game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100")
                return HttpService:JSONDecode(response).data
            end)
            if ok and result then
                local id = nil
                for k, v in pairs(result) do
                    if v.playing < v.maxPlayers then id = v.id end
                end
                if id then pcall(function() TeleportService:TeleportToPlaceInstance(placeId, id, player) end) end
            end
        end)
    end)
    createButton(p, "Hop to Lowest Players", function()
        local TeleportService = game:GetService("TeleportService")
        local placeId = game.PlaceId
        local str = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
        local nextPageCursor = nil
        local v8, v9
        repeat
            v8 = ListServers(nextPageCursor)
            v9 = v8.data[1]
            nextPageCursor = v8.nextPageCursor
        until v9
        TeleportService:TeleportToPlaceInstance(placeId, v9.id, plr)
    end)

    createSection(p, "Player Gui")
    createButton(p, "Open Awakenings Expert", function() plr.PlayerGui.Main.AwakeningToggler.Visible = true end)
    createButton(p, "Open Title Selection", function()
        replicated.Remotes.CommF_:InvokeServer("getTitles", true)
        plr.PlayerGui.Main.Titles.Visible = true
    end)
    createToggle(p, "Disable Chat GUI", false, function(s)
        _G.Rechat = s
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Chat, not s)
    end)
    createToggle(p, "Disable Leader Board GUI", false, function(s)
        ReLeader = s
        game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, not s)
    end)
    createButton(p, "Set Pirate Team", function() Pirates() end)
    createButton(p, "Set Marine Team", function() Marines() end)
    createToggle(p, "Unlock All Portals", false, function(s) _G.PortalUnLock = s end)

    createSection(p, "Graphics / Haki")
    local hakiOpts = {"State 0","State 1","State 2","State 3","State 4","State 5"}
    createDropdown(p, "Select Haki States", hakiOpts, "State 0", function(s) _G.SelectStateHaki = s end)
    createButton(p, "ChangeBusoStage", function()
        local map = {["State 0"]=0,["State 1"]=1,["State 2"]=2,["State 3"]=3,["State 4"]=4,["State 5"]=5}
        replicated.Remotes.CommF_:InvokeServer("ChangeBusoStage", map[_G.SelectStateHaki] or 0)
    end)
    createToggle(p, "Turn on RTX Mode", false, function(s)
        _G.RTXMode = s
        local lighting = game.Lighting
        if not s then return end
        task.spawn(function()
            while _G.RTXMode do
                wait()
                lighting.Ambient = Color3.fromRGB(33, 33, 33)
                lighting.Brightness = 0.3
                game.Lighting.FogEnd = 999
            end
        end)
    end)
    createButton(p, "Turn on Fast Mode", function()
        for k, d in pairs(workspace:GetDescendants()) do
            if table.find({"Part","MeshPart","TrussPart"}, d.ClassName) then d.Material = "Plastic" end
        end
    end)
    createButton(p, "Turn on Low CPU", function() LowCpu() end)
    createButton(p, "Remove Sky Fog", function()
        if Lighting:FindFirstChild("LightingLayers") then Lighting.LightingLayers:Destroy() end
        if Lighting:FindFirstChild("SeaTerrorCC") then Lighting.SeaTerrorCC:Destroy() end
        if Lighting:FindFirstChild("FantasySky") then Lighting.FantasySky:Destroy() end
    end)
    createToggle(p, "Turn on Full Bright", false, function(s)
        if s then
            Lighting.Ambient = Color3.new(1,1,1)
            Lighting.ColorShift_Bottom = Color3.new(1,1,1)
            Lighting.ColorShift_Top = Color3.new(1,1,1)
        else
            Lighting.Ambient = Color3.new(0,0,0)
            Lighting.ColorShift_Bottom = Color3.new(0,0,0)
            Lighting.ColorShift_Top = Color3.new(0,0,0)
        end
    end)
    createToggle(p, "Turn on Walk on Water", true, function(s)
        _G.WalkWater_Part = s
        game:GetService("Workspace").Map["WaterBase-Plane"].Size = Vector3.new(1000, s and 112 or 80, 1000)
    end)
    createToggle(p, "Turn on Ice Walk", false, function(s) _G.WalkWater = s end)
end)



-- ============ DRAG MAIN FRAME (chuot + cam ung) ============
local dragging, dragInput, dragStart, startPos
topBar.InputBegan:Connect(function(input)
    if isPress(input) then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if isMove(input) then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ============ TOGGLE KEY ============
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if mainFrame.Visible then hideMain() else showMain() end
    end
end)

-- ============ LAUNCH ============
-- Mở tab đầu ngay, các tab còn lại dựng ngầm sau khi map đã load
if tabs["Info"] then tabs["Info"]() end

task.spawn(function()
    pcall(function() workspace:WaitForChild("_WorldOrigin", 15) end)
    for _, entry in ipairs(tabList) do
        entry.build()
        task.wait()
    end
end)

NotifyIOS27("Meta Hub", "Đã tải xong. RightCtrl hoặc nút vàng để ẩn/hiện menu.", "ok", 4)
